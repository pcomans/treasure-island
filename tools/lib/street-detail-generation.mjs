// Street detail: the data behind PlayableWorld/StreetDetail.
//
// Three sources feed one output, generated/world/street_detail.json:
//   (a) osm       - frozen OSM nodes and ways, one row per source element;
//   (b) scatter   - seeded zone scatter from tools/config/street-detail-zones.json;
//   (c) set_piece - hand-picked entries from data/street_detail/set_pieces.json.
// Every row is checked against one shared exclusion mask (doors, stairs and
// their approaches, spawn, ferry path and QA corridors, buildings, roads).
// Coordinates are world metres: +X east, +Z south (-Z north), Y up (NAVD 88).

import { createHash } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

import { projectLonLat } from "./coordinates.mjs";
import { geometryToLine, pointInMultiPolygon, pointInRing, selectGeometry } from "./osm-geometry.mjs";
import { footprintPiece, placeStreetClutter, STREET_CLUTTER_FOOTPRINTS, STREET_CLUTTER_PROPS, validateClutterRules, visibleGroundIndex } from "./street-clutter-generation.mjs";
import { placeStreetFences, validateFenceRules } from "./street-fence-generation.mjs";
import { placeStreetFurniture, settleOnFeet, STREET_FURNITURE_FEET, STREET_FURNITURE_PROPS, streetFurnitureFootprint, validateFurnitureRules } from "./street-furniture-generation.mjs";
import {
  PAVING_CLEAR_M,
  crownRadius,
  packPlantingRows,
  pavingUnder,
  planDrifts,
  planFill,
  plantingState,
  validatePlantingRule,
} from "./street-planting-generation.mjs";
import {
  STREET_VEGETATION_PROPS,
  bedOffsets,
  drawVegetationVariant,
  footSamples,
  plantRow,
  validateVegetationRuleParams,
  validateVegetationSetPieceParams,
} from "./street-vegetation-generation.mjs";
import {
  BOUNDARY_ATTACHED_SOURCE_KEYS,
  PLAYABLE_BOUNDARY_SOURCE_KEY,
  ROAD_SURFACE_BIASES_M,
  SHARED_COASTLINE_SOURCE_KEY,
  SOURCE_CONTRACT,
  compareSourceKeys,
  invariant,
  roundCoordinate,
  sha256File,
} from "./world-contract.mjs";

export const STREET_DETAIL_SCHEMA = "ti.street-detail/1";
export const STREET_DETAIL_ZONES_SCHEMA = "ti.street-detail-zones/1";
export const STREET_DETAIL_SET_PIECES_SCHEMA = "ti.street-detail-set-pieces/1";
export const STREET_DETAIL_INPUTS = Object.freeze({
  zones: "tools/config/street-detail-zones.json",
  set_pieces: "data/street_detail/set_pieces.json",
  stair_catalog: "discovery/facades/facade-recognition-catalog.json",
});
// Runtime subtrees under PlayableWorld/StreetDetail, in node order; each one
// can be switched off. "ground" rows (crossings, kerbs) feed the always-on
// chunk surfaces in a later step and are never switched off.
export const STREET_DETAIL_LAYERS = Object.freeze(["vegetation", "furniture", "fences", "clutter"]);
export const STREET_DETAIL_GROUND_LAYER = "ground";
export const STREET_DETAIL_SOURCES = Object.freeze(["osm", "scatter", "set_piece"]);
export const STREET_DETAIL_EXCLUSION_KEYS = Object.freeze([
  "approach_half_width_m",
  "approach_length_m",
  "building_buffer_m",
  "door_radius_m",
  "ferry_path_half_width_m",
  "land_edge_buffer_m",
  "qa_route_half_width_m",
  "road_buffer_m",
  "spawn_forward_half_width_m",
  "spawn_forward_length_m",
  "spawn_radius_m",
  "stair_half_width_m",
  "wall_buffer_m",
  "whole_island_anchor_radius_m",
]);
// The automated route QA's walks (game/tests/automated_route_qa.gd and the
// whole-island anchors in game/tests/regional_qa_anchors.gd), as world [x, z]:
// street detail keeps clear of them (streetDetailHardShapes).
const NORMAL_QA_ROUTE = Object.freeze([
  [-104.364, 786.024], [-93.682, 780.044], [-91.651, 778.897], [-84.414, 774.734],
  [-96.25, 754.195], [-108.833, 730.206], [-112.174, 722.948], [-112.666, 718.005],
  [-111.532, 712.884], [-110.152, 711.081], [-103.53, 705.972], [-68.085, 685.812],
  [-4.951, 652.705], [38.743, 629.439],
]);
const QA_CORRIDORS = Object.freeze({
  ferry_arrival_path: Object.freeze(NORMAL_QA_ROUTE.slice(0, 7)),
  normal_qa_route: NORMAL_QA_ROUTE,
  // Its first point is the normal route's end.
  whole_island_qa_route: Object.freeze([
    NORMAL_QA_ROUTE.at(-1), [-293.543, 335.72], [-159.292, -104.818], [-159.535, -879.905], [606.249, 385.227],
  ]),
});
// Gameplay clearances every switchable item must keep, in reporting order.
export const STREET_DETAIL_HARD_COMPONENTS = Object.freeze([
  "spawn",
  "spawn_forward",
  "ferry_path",
  "qa_route",
  "whole_island_anchor",
  "stair",
  "door",
  "approach",
]);

function pointKind(layer, footprintRadiusM, yawRule) {
  return Object.freeze({ layer, geometry: "point", footprint_radius_m: footprintRadiusM, yaw_rule: yawRule, overhead: false });
}

function lineKind(layer, halfWidthM, overhead = false) {
  return Object.freeze({ layer, geometry: "polyline", footprint_radius_m: halfWidthM, yaw_rule: "none", overhead });
}

// footprint_radius_m is the plan radius (points) or half width (lines) used for
// clearance; production inference, not measured. Slot kinds are step-0 scatter
// placeholders that later steps fill with assets.
export const STREET_DETAIL_KINDS = Object.freeze({
  // A park's sculpture (Cityside Park's Canopy of Sky): the pole bases stand
  // outside its walkway, the radius is the walkway under it.
  artwork: pointKind("furniture", 0.6, "seeded"),
  barricade: pointKind("clutter", 0.4, "seeded"),
  barrier_line: lineKind("fences", 0.15),
  barrier_point: pointKind("fences", 0.5, "host_barrier"),
  bbq: pointKind("furniture", 0.45, "seeded"),
  bench: pointKind("furniture", 0.9, "faces_road"),
  bicycle_parking: pointKind("furniture", 1.0, "faces_road"),
  bollard: pointKind("furniture", 0.15, "host_barrier"),
  bus_stop: pointKind("furniture", 1.5, "faces_road"),
  chair: pointKind("furniture", 0.45, "seeded"),
  clutter_slot: pointKind("clutter", 0.4, "seeded"),
  crossing: pointKind(STREET_DETAIL_GROUND_LAYER, 0, "crossing"),
  fence: lineKind("fences", 0.05),
  fire_hydrant: pointKind("furniture", 0.25, "faces_road"),
  gate: pointKind("fences", 0.1, "host_barrier"),
  grass_clump: pointKind("vegetation", 0.35, "seeded"),
  hedge: lineKind("vegetation", 0.5),
  information_board: pointKind("furniture", 0.6, "faces_road"),
  jersey_barrier: lineKind("fences", 0.35),
  kerb: pointKind(STREET_DETAIL_GROUND_LAYER, 0, "crossing"),
  log_barrier: lineKind("fences", 0.25),
  // A fan palm's foot (its flared trunk and roots); date palms and cypresses are trees.
  palm_slot: pointKind("vegetation", 0.4, "seeded"),
  // A parked car's footprint is its own rectangle (footprint_m on the row);
  // the radius is its half width for whoever reads only the kind.
  parked_car: pointKind("clutter", 1.0, "seeded"),
  picnic_table: pointKind("furniture", 1.0, "seeded"),
  planting_slot: pointKind("vegetation", 0.8, "seeded"),
  post_box: pointKind("furniture", 0.35, "faces_road"),
  power_line: lineKind("clutter", 0, true),
  power_pole: pointKind("clutter", 0.2, "host_power_line"),
  retaining_wall: lineKind("fences", 0.2),
  // A small park building outside the OSM inventory (Cityside Park's pump
  // station): its footprint is its own rectangle (footprint_m on the row).
  site_structure: pointKind("furniture", 3.8, "seeded"),
  stop_sign: pointKind("furniture", 0.15, "host_road"),
  street_cabinet: pointKind("furniture", 0.6, "faces_road"),
  street_lamp: pointKind("furniture", 0.25, "faces_road"),
  street_sign: pointKind("furniture", 0.15, "faces_road"),
  traffic_cone: pointKind("clutter", 0.2, "seeded"),
  traffic_signals: pointKind("furniture", 0.25, "host_road"),
  tree: pointKind("vegetation", 0.8, "seeded"),
  wall: lineKind("fences", 0.15),
  waste_basket: pointKind("furniture", 0.35, "faces_road"),
});

const AMENITY_KINDS = Object.freeze(["bench", "bicycle_parking", "post_box", "waste_basket"]);
// Scatter patterns that plant naturalistic beds (tools/lib/street-planting-generation.mjs).
const PLANTING_PATTERNS = Object.freeze(["drifts", "fill"]);
const GATE_VALUES = Object.freeze(["gate", "hampshire_gate", "kissing_gate", "lift_gate", "sliding_gate", "swing_gate", "wicket_gate"]);
const LINE_BARRIER_KINDS = Object.freeze({
  fence: "fence",
  hedge: "hedge",
  jersey_barrier: "jersey_barrier",
  log: "log_barrier",
  retaining_wall: "retaining_wall",
  wall: "wall",
});
const COMPASS_DEGREES = Object.freeze({ N: 0, NE: 45, E: 90, SE: 135, S: 180, SW: 225, W: 270, NW: 315 });
const FACES_ROAD_MAXIMUM_M = 30;
// Hard or built surfaces where a vegetation slot cannot stand.
const UNPLANTABLE_MATERIALS = Object.freeze([
  "major_area_paved",
  "park_asphalt",
  "park_concrete",
  "park_dg",
  "park_plaza_lens",
  "park_plaza_zigzag",
  "road_path",
  "road_path_pedestrian",
  "street_kerb_concrete",
  "street_parking",
  "street_plaza_pavers",
  "terrain_breakwater",
  "terrain_marina",
  "terrain_pier",
]);
const LAND_EDGE_EPSILON_M = 0.01;
// Street-prop set pieces keep the street furniture's site margins
// (tools/lib/street-furniture-generation.mjs): from the carriageway, from a curb
// ramp, and a player's width between two items.
const PROP_KERB_CLEAR_M = 0.3;
const PROP_RAMP_CLEAR_M = 0.9;
const PLAYER_WIDTH_M = 0.7;
const SAFE_ID = /^[a-z0-9_]+$/u;

function osmPointKind(tags) {
  if (tags.highway === "street_lamp") return ["street_lamp", "highway=street_lamp"];
  if (tags.highway === "traffic_signals") return ["traffic_signals", "highway=traffic_signals"];
  if (tags.highway === "stop") return ["stop_sign", "highway=stop"];
  if (tags.highway === "bus_stop") return ["bus_stop", "highway=bus_stop"];
  if (tags.highway === "crossing") return ["crossing", "highway=crossing"];
  if (tags.emergency === "fire_hydrant") return ["fire_hydrant", "emergency=fire_hydrant"];
  if (tags.power === "pole") return ["power_pole", "power=pole"];
  if (tags.man_made === "street_cabinet") return ["street_cabinet", "man_made=street_cabinet"];
  if (AMENITY_KINDS.includes(tags.amenity)) return [tags.amenity, `amenity=${tags.amenity}`];
  if (tags.barrier != null) {
    if (tags.barrier === "kerb") return ["kerb", "barrier=kerb"];
    if (GATE_VALUES.includes(tags.barrier)) return ["gate", `barrier=${tags.barrier}`];
    if (tags.barrier === "bollard") return ["bollard", "barrier=bollard"];
    return ["barrier_point", `barrier=${tags.barrier}`];
  }
  return null;
}

function osmLineKind(tags) {
  if (tags.power === "minor_line") return ["power_line", "power=minor_line"];
  if (tags.barrier != null) return [LINE_BARRIER_KINDS[tags.barrier] ?? "barrier_line", `barrier=${tags.barrier}`];
  return null;
}

function compareText(left, right) {
  // Code-point order, identical to GDScript String comparison for these ASCII ids.
  return left < right ? -1 : left > right ? 1 : 0;
}

function round3(value) {
  return roundCoordinate(value);
}

function normalizedYaw(radians) {
  let yaw = round3(Math.atan2(Math.sin(radians), Math.cos(radians)));
  if (yaw > Math.PI) yaw = round3(yaw - Math.PI * 2);
  if (yaw < -Math.PI) yaw = round3(yaw + Math.PI * 2);
  return yaw;
}

// Turns the asset's local -Z front toward world direction (dx, dz).
function yawFacing(dx, dz) {
  invariant(Math.hypot(dx, dz) > 1e-9, "Cannot face a zero direction");
  return normalizedYaw(Math.atan2(-dx, -dz));
}

function hashBytes(seed, identity) {
  return createHash("sha256").update(`${seed}|${identity}`, "utf8").digest();
}

function unit(bytes, offset) {
  return bytes.readUInt32BE(offset) / 0xffffffff;
}

function toWorld(eastNorth) {
  return [eastNorth[0], -eastNorth[1]];
}

function toEastNorth(xz) {
  return [xz[0], -xz[1]];
}

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

function isXZ(value) {
  return Array.isArray(value) && value.length === 2 && value.every(isFiniteNumber);
}

function pointSegmentDistance(point, start, end) {
  const dx = end[0] - start[0];
  const dz = end[1] - start[1];
  const lengthSquared = dx * dx + dz * dz;
  if (lengthSquared === 0) return Math.hypot(point[0] - start[0], point[1] - start[1]);
  const fraction = Math.max(0, Math.min(1, ((point[0] - start[0]) * dx + (point[1] - start[1]) * dz) / lengthSquared));
  return Math.hypot(point[0] - (start[0] + dx * fraction), point[1] - (start[1] + dz * fraction));
}

function closestOnSegment(point, start, end) {
  const dx = end[0] - start[0];
  const dz = end[1] - start[1];
  const lengthSquared = dx * dx + dz * dz;
  const fraction = lengthSquared === 0 ? 0 : Math.max(0, Math.min(1, ((point[0] - start[0]) * dx + (point[1] - start[1]) * dz) / lengthSquared));
  return [start[0] + dx * fraction, start[1] + dz * fraction];
}

function orientation(a, b, c) {
  return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]);
}

function segmentsCross(a, b, c, d) {
  const d1 = orientation(c, d, a);
  const d2 = orientation(c, d, b);
  const d3 = orientation(a, b, c);
  const d4 = orientation(a, b, d);
  return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
}

function segmentSegmentDistance(a, b, c, d) {
  if (segmentsCross(a, b, c, d)) return 0;
  return Math.min(pointSegmentDistance(a, c, d), pointSegmentDistance(b, c, d), pointSegmentDistance(c, a, b), pointSegmentDistance(d, a, b));
}

function polylineDistance(point, points) {
  if (points.length === 1) return Math.hypot(point[0] - points[0][0], point[1] - points[0][1]);
  let minimum = Infinity;
  for (let index = 1; index < points.length; index += 1) {
    minimum = Math.min(minimum, pointSegmentDistance(point, points[index - 1], points[index]));
  }
  return minimum;
}

// Plan distance between two polylines; a single point is a one-vertex polyline.
// Exported as planDistance for tools/check_street_detail_clearance.mjs.
function polylinePolylineDistance(left, right) {
  if (left.length === 1) return polylineDistance(left[0], right);
  if (right.length === 1) return polylineDistance(right[0], left);
  let minimum = Infinity;
  for (let i = 1; i < left.length; i += 1) {
    for (let j = 1; j < right.length; j += 1) {
      minimum = Math.min(minimum, segmentSegmentDistance(left[i - 1], left[i], right[j - 1], right[j]));
    }
  }
  return minimum;
}

function polylineLength(points) {
  let length = 0;
  for (let index = 1; index < points.length; index += 1) {
    length += Math.hypot(points[index][0] - points[index - 1][0], points[index][1] - points[index - 1][1]);
  }
  return length;
}

function boundsOf(points) {
  return {
    min_x: Math.min(...points.map((point) => point[0])),
    min_y: Math.min(...points.map((point) => point[1])),
    max_x: Math.max(...points.map((point) => point[0])),
    max_y: Math.max(...points.map((point) => point[1])),
  };
}

function boundsDistance(point, bounds) {
  const dx = Math.max(bounds.min_x - point[0], 0, point[0] - bounds.max_x);
  const dy = Math.max(bounds.min_y - point[1], 0, point[1] - bounds.max_y);
  return Math.hypot(dx, dy);
}

function distanceToRingEdges(point, ring) {
  let minimum = Infinity;
  for (let index = 0; index < ring.length; index += 1) {
    minimum = Math.min(minimum, pointSegmentDistance(point, ring[index], ring[(index + 1) % ring.length]));
  }
  return minimum;
}

function distanceToMultiPolygonEdges(point, geometry) {
  let minimum = Infinity;
  for (const polygon of geometry) for (const ring of polygon) minimum = Math.min(minimum, distanceToRingEdges(point, ring));
  return minimum;
}

// Multipolygons in the generator's east/north frame, queried with world points.
function polygonSet(entries) {
  const items = entries.map((entry) => ({
    ...entry,
    bounds: boundsOf(entry.geometry.flatMap((polygon) => polygon.flatMap((ring) => ring))),
  }));
  return {
    items,
    containing(xz) {
      const point = toEastNorth(xz);
      return items.filter((item) => boundsDistance(point, item.bounds) === 0 && pointInMultiPolygon(point, item.geometry, true));
    },
    // Nearest plan distance (0 inside) within limit, or {distance: Infinity}.
    nearest(xz, limit = Infinity) {
      const point = toEastNorth(xz);
      let best = { distance: Infinity, key: null };
      for (const item of items) {
        const lower = boundsDistance(point, item.bounds);
        if (lower > limit || lower > best.distance) continue;
        const distance = pointInMultiPolygon(point, item.geometry, true) ? 0 : distanceToMultiPolygonEdges(point, item.geometry);
        if (distance < best.distance || (distance === best.distance && compareSourceKeys(item.key, best.key ?? item.key) < 0)) {
          best = { distance, key: item.key };
        }
      }
      return best;
    },
  };
}

function readJson(projectRoot, path) {
  const absolute = resolve(projectRoot, path);
  invariant(existsSync(absolute), `Street detail input is missing: ${path}`);
  return JSON.parse(readFileSync(absolute, "utf8"));
}

function validateExclusions(exclusions) {
  invariant(exclusions != null && typeof exclusions === "object" && !Array.isArray(exclusions), "Street detail exclusions must be an object");
  invariant(
    JSON.stringify(Object.keys(exclusions).sort()) === JSON.stringify([...STREET_DETAIL_EXCLUSION_KEYS]),
    `Street detail exclusions must define exactly ${STREET_DETAIL_EXCLUSION_KEYS.join(", ")}`,
  );
  for (const key of STREET_DETAIL_EXCLUSION_KEYS) {
    invariant(isFiniteNumber(exclusions[key]) && exclusions[key] >= 0, `Street detail exclusion ${key} must be a non-negative number`);
  }
  invariant(exclusions.approach_length_m > 0, "Street detail approach length must be positive");
}

// A scatter rule places point rows of its kind: on a grid over the zone, along
// OSM ways at fixed offsets, or (along_beds) at the middle of the planting bed
// found across a way on each named side. A vegetation rule may also plant: a
// kit prop (tools/lib/street-vegetation-generation.mjs) with the variants and
// scale it draws, the surfaces it may stand on, a polygon it keeps within and,
// like the furniture rules, its basis, rule and dated evidence.
function validateScatterRule(rule, zoneId, ruleIds) {
  const label = `Street detail zone ${zoneId} scatter rule ${rule?.id}`;
  invariant(typeof rule?.id === "string" && SAFE_ID.test(rule.id) && !ruleIds.has(rule.id), `${label} needs a unique lower_snake id`);
  ruleIds.add(rule.id);
  const kind = STREET_DETAIL_KINDS[rule.kind];
  invariant(kind && kind.geometry === "point" && STREET_DETAIL_LAYERS.includes(kind.layer), `${label} has a non-scatter kind ${rule.kind}`);
  if (PLANTING_PATTERNS.includes(rule.pattern)) {
    // Naturalistic beds (tools/lib/street-planting-generation.mjs): a mix of kit plants.
    invariant(kind.layer === "vegetation", `${label}: ${rule.pattern} rules plant vegetation`);
    validatePlantingRule(rule, label, (prop, kindName, params, entryLabel) => {
      invariant(STREET_VEGETATION_PROPS[prop]?.kinds.includes(kindName), `${entryLabel}: prop ${prop} does not plant a ${kindName}`);
      validateVegetationRuleParams(prop, params, entryLabel);
    }, (prop) => STREET_VEGETATION_PROPS[prop]?.variants ?? 0);
    return;
  }
  invariant(["grid", "along", "along_beds"].includes(rule.pattern), `${label} pattern must be grid, along, along_beds, drifts or fill`);
  invariant(isFiniteNumber(rule.spacing_m) && rule.spacing_m > 0, `${label} spacing must be positive`);
  invariant(isFiniteNumber(rule.jitter_m) && rule.jitter_m >= 0 && rule.jitter_m < rule.spacing_m, `${label} jitter must be below spacing`);
  invariant(isFiniteNumber(rule.acceptance) && rule.acceptance > 0 && rule.acceptance <= 1, `${label} acceptance must be in (0, 1]`);
  if (rule.pattern === "grid") {
    invariant(rule.source_keys == null && rule.offsets_m == null && rule.sides == null && rule.reach_m == null, `${label}: grid rules take no source_keys, offsets_m, sides or reach_m`);
  } else if (rule.pattern === "along" && rule.line_xz != null) {
    // A traced line instead of OSM ways (a double tree row along a plaza).
    invariant(rule.source_keys == null && Array.isArray(rule.line_xz) && rule.line_xz.length >= 2 && rule.line_xz.every(isXZ), `${label} line_xz must be 2+ [x, z] points, without source_keys`);
  } else {
    invariant(Array.isArray(rule.source_keys) && rule.source_keys.length > 0 && rule.source_keys.every((key) => /^w\d+$/u.test(key)), `${label} needs OSM way source_keys`);
  }
  if (rule.stagger_m != null) invariant(rule.pattern === "along" && isFiniteNumber(rule.stagger_m) && rule.stagger_m >= 0 && rule.stagger_m < rule.spacing_m, `${label}: stagger_m (shifting every other offset along the line) goes with along and stays below spacing`);
  if (rule.pattern === "along") {
    invariant(Array.isArray(rule.offsets_m) && rule.offsets_m.length > 0 && rule.offsets_m.every(isFiniteNumber), `${label} needs numeric offsets_m`);
    invariant(rule.sides == null && rule.reach_m == null, `${label}: along rules take offsets_m, not sides or reach_m`);
  }
  if (rule.pattern === "along_beds") {
    invariant(rule.offsets_m == null, `${label}: along_beds rules take sides and reach_m, not offsets_m`);
    invariant(Array.isArray(rule.sides) && rule.sides.length > 0 && rule.sides.every((side) => ["left", "right"].includes(side)) && new Set(rule.sides).size === rule.sides.length, `${label} sides must list left and/or right`);
    invariant(Array.isArray(rule.reach_m) && rule.reach_m.length === 2 && rule.reach_m.every(isFiniteNumber) && rule.reach_m[0] >= 0 && rule.reach_m[1] > rule.reach_m[0], `${label} reach_m must be [near, far] metres from the way`);
    invariant(isFiniteNumber(rule.min_bed_m) && rule.min_bed_m > 0, `${label} needs a positive min_bed_m`);
    invariant(Array.isArray(rule.surfaces), `${label}: along_beds needs the bed surfaces`);
  } else {
    invariant(rule.min_bed_m == null, `${label}: only along_beds takes min_bed_m`);
  }
  if (rule.surfaces != null) {
    invariant(Array.isArray(rule.surfaces) && rule.surfaces.length > 0 && rule.surfaces.every((key) => typeof key === "string" && key !== "") && new Set(rule.surfaces).size === rule.surfaces.length, `${label} surfaces must list material keys`);
  }
  if (rule.within_xz != null) {
    invariant(Array.isArray(rule.within_xz) && rule.within_xz.length >= 3 && rule.within_xz.every(isXZ), `${label} within_xz must be a polygon of 3+ [x, z] points`);
  }
  if (rule.prop != null) {
    invariant(kind.layer === "vegetation" && STREET_VEGETATION_PROPS[rule.prop]?.kinds.includes(rule.kind), `${label}: prop ${rule.prop} does not plant a ${rule.kind}`);
    validateVegetationRuleParams(rule.prop, rule.params, label);
    invariant(rule.basis === "production_inference", `${label} basis must be production_inference`);
    for (const field of ["rule", "evidence"]) invariant(typeof rule[field] === "string" && rule[field].trim() !== "", `${label} needs ${field}`);
  } else {
    invariant(rule.params == null && rule.basis == null, `${label}: params and basis go with a prop`);
  }
}

export function loadStreetDetailZones(projectRoot) {
  const config = readJson(projectRoot, STREET_DETAIL_INPUTS.zones);
  invariant(config.schema_version === STREET_DETAIL_ZONES_SCHEMA, "Street detail zones schema drift");
  invariant(Number.isInteger(config.seed) && config.seed >= 0 && config.seed <= 0xffffffff, "Street detail seed must be a 32-bit integer");
  validateExclusions(config.exclusions);
  invariant(Array.isArray(config.zones), "Street detail zones must be a list");
  const zoneIds = new Set();
  for (const zone of config.zones) {
    invariant(typeof zone?.id === "string" && SAFE_ID.test(zone.id) && !zoneIds.has(zone.id), `Street detail zone ${zone?.id} needs a unique lower_snake id`);
    zoneIds.add(zone.id);
    for (const field of ["name", "reason", "reference"]) {
      invariant(typeof zone[field] === "string" && zone[field].trim() !== "", `Street detail zone ${zone.id} needs ${field}`);
    }
    invariant(typeof zone.pilot === "boolean", `Street detail zone ${zone.id} needs a boolean pilot flag`);
    const shape = zone.shape;
    if (shape?.type === "polygon") {
      invariant(Array.isArray(shape.points_xz) && shape.points_xz.length >= 3 && shape.points_xz.every(isXZ), `Street detail zone ${zone.id} polygon needs 3+ [x, z] points`);
    } else if (shape?.type === "corridor") {
      invariant(Array.isArray(shape.source_keys) && shape.source_keys.length > 0 && shape.source_keys.every((key) => /^w\d+$/u.test(key)), `Street detail zone ${zone.id} corridor needs OSM way source_keys`);
      invariant(isFiniteNumber(shape.half_width_m) && shape.half_width_m > 0, `Street detail zone ${zone.id} corridor needs a positive half_width_m`);
    } else {
      throw new Error(`Street detail zone ${zone.id} shape must be polygon or corridor`);
    }
    invariant(Array.isArray(zone.scatter), `Street detail zone ${zone.id} scatter must be a list`);
    const ruleIds = new Set();
    for (const rule of zone.scatter) validateScatterRule(rule, zone.id, ruleIds);
    validateFurnitureRules(zone, STREET_DETAIL_KINDS);
    validateFenceRules(zone, STREET_DETAIL_KINDS);
    validateClutterRules(zone, STREET_DETAIL_KINDS);
    for (const rule of [...(zone.furniture ?? []), ...(zone.fences ?? []), ...(zone.clutter ?? [])]) {
      invariant(!ruleIds.has(rule.id), `Street detail zone ${zone.id} rule id ${rule.id} is used twice`);
      ruleIds.add(rule.id);
    }
  }
  validateFencedApproaches(config.fenced_approaches);
  return config;
}

// Scored-building sides a real fence closes, which the building fit may then skip
// (game/tests/shared/building_fit.gd). Each entry names the side, the fence rows
// that close it, and why, with dated evidence. The generator checks that every
// named fence is a built fence row.
export const STREET_DETAIL_FENCED_SIDES = Object.freeze(["north", "south", "west", "east"]);
function validateFencedApproaches(value) {
  invariant(value != null && typeof value === "object" && !Array.isArray(value), "Street detail fenced_approaches must be an object");
  invariant(Array.isArray(value.notes) && value.notes.every((note) => typeof note === "string"), "Street detail fenced_approaches needs notes");
  invariant(Array.isArray(value.entries), "Street detail fenced_approaches needs an entries list");
  const seen = new Set();
  for (const entry of value.entries) {
    const label = `Street detail fenced approach ${entry?.source_key}/${entry?.side}`;
    invariant(JSON.stringify(Object.keys(entry ?? {}).sort()) === JSON.stringify(["evidence", "fence_ids", "reason", "side", "source_key"]), `${label} must have exactly {source_key, side, fence_ids, reason, evidence}`);
    invariant(/^[nwr]\d+$/u.test(entry.source_key) && STREET_DETAIL_FENCED_SIDES.includes(entry.side), `${label} needs an OSM source key and a side ${STREET_DETAIL_FENCED_SIDES.join("/")}`);
    invariant(!seen.has(`${entry.source_key}/${entry.side}`), `${label} is listed twice`);
    seen.add(`${entry.source_key}/${entry.side}`);
    invariant(Array.isArray(entry.fence_ids) && entry.fence_ids.length > 0 && entry.fence_ids.every((id) => typeof id === "string" && id !== ""), `${label} needs fence_ids`);
    for (const field of ["reason", "evidence"]) invariant(typeof entry[field] === "string" && entry[field].trim() !== "", `${label} needs ${field}`);
  }
}

export function loadStreetDetailSetPieces(projectRoot) {
  const document = readJson(projectRoot, STREET_DETAIL_INPUTS.set_pieces);
  invariant(document.schema_version === STREET_DETAIL_SET_PIECES_SCHEMA, "Street detail set-piece schema drift");
  invariant(Array.isArray(document.set_pieces), "Street detail set pieces must be a list");
  const ids = new Set();
  for (const entry of document.set_pieces) {
    const label = `Street detail set piece ${entry?.id}`;
    const keys = JSON.stringify(Object.keys(entry ?? {}).sort());
    // An entry either names an asset file or a kit prop of its kind's layer with its params.
    const assetShape = JSON.stringify(["asset", "id", "kind", "reason", "reference", "xz", "yaw"]);
    const propShape = JSON.stringify(["id", "kind", "params", "prop", "reason", "reference", "xz", "yaw"]);
    invariant(keys === assetShape || keys === propShape, `${label} must have exactly {id, kind, asset, xz, yaw, reason, reference} or {id, kind, prop, params, xz, yaw, reason, reference}`);
    invariant(typeof entry.id === "string" && SAFE_ID.test(entry.id) && !ids.has(entry.id), `${label} needs a unique lower_snake id`);
    ids.add(entry.id);
    const kind = STREET_DETAIL_KINDS[entry.kind];
    invariant(kind && kind.geometry === "point" && STREET_DETAIL_LAYERS.includes(kind.layer), `${label} has a non-point or ground kind ${entry.kind}`);
    if (keys === assetShape) {
      invariant(
        typeof entry.asset === "string" && entry.asset.startsWith("res://game/resources/") && existsSync(resolve(projectRoot, entry.asset.slice("res://".length))),
        `${label} asset must be an existing res://game/resources/ file`,
      );
    } else {
      // Trees of the street-vegetation kit (street_vegetation_kit.gd), or a
      // furniture or clutter kit prop of its kind's layer.
      if (kind.layer === "vegetation") {
        validateVegetationSetPieceParams(entry.prop, entry.kind, entry.params, label);
      } else {
        const props = kind.layer === "furniture" ? STREET_FURNITURE_PROPS : kind.layer === "clutter" ? STREET_CLUTTER_PROPS : {};
        invariant(props[entry.prop] === entry.kind, `${label}: prop ${entry.prop} does not build a ${entry.kind} in the ${kind.layer} layer`);
        invariant(entry.params != null && typeof entry.params === "object" && !Array.isArray(entry.params), `${label} params must be an object`);
      }
    }
    invariant(isXZ(entry.xz), `${label} xz must be [x, z]`);
    invariant(isFiniteNumber(entry.yaw) && entry.yaw >= -Math.PI && entry.yaw <= Math.PI, `${label} yaw must be radians in [-pi, pi]`);
    for (const field of ["reason", "reference"]) {
      invariant(typeof entry[field] === "string" && entry[field].trim() !== "", `${label} needs ${field}`);
    }
  }
  return document;
}

// Every catalog stair flight, accepted or not: the stairs exist either way.
export function loadStreetDetailStairFlights(projectRoot) {
  const catalog = readJson(projectRoot, STREET_DETAIL_INPUTS.stair_catalog);
  invariant(Array.isArray(catalog.units), "Building catalog units are missing");
  const flights = [];
  for (const unit of catalog.units) {
    if (unit.stairs == null) continue;
    invariant(typeof unit.anchor_source_key === "string" && Array.isArray(unit.stairs), `Catalog stairs are malformed for ${unit.unit_id}`);
    unit.stairs.forEach((flight, index) => {
      invariant(isXZ(flight?.bottom) && isXZ(flight?.top), `Catalog stair ${index} of ${unit.anchor_source_key} needs bottom/top [x, z]`);
      invariant(Math.hypot(flight.top[0] - flight.bottom[0], flight.top[1] - flight.bottom[1]) > 0.1, `Catalog stair ${index} of ${unit.anchor_source_key} has no run`);
      flights.push({ source_key: unit.anchor_source_key, index, bottom: [...flight.bottom], top: [...flight.top] });
    });
  }
  flights.sort((left, right) => compareSourceKeys(left.source_key, right.source_key) || left.index - right.index);
  return flights;
}

// The gameplay part of the shared mask: shapes no switchable item may enter.
// spawn is the manifest's initial spawn as {xz: [x, z], yaw}.
export function streetDetailHardShapes(exclusions, spawn, stairFlights) {
  invariant(Array.isArray(spawn?.xz) && spawn.xz.length === 2 && spawn.xz.every(isFiniteNumber) && isFiniteNumber(spawn.yaw), "Street detail needs the spawn position and yaw");
  const spawnXZ = [spawn.xz[0], spawn.xz[1]];
  // The player faces local -Z turned by yaw: world direction (-sin yaw, -cos yaw).
  const ahead = [
    round3(spawnXZ[0] - Math.sin(spawn.yaw) * exclusions.spawn_forward_length_m),
    round3(spawnXZ[1] - Math.cos(spawn.yaw) * exclusions.spawn_forward_length_m),
  ];
  const shapes = [
    { component: "spawn", source_id: "manifest:initial_spawn", points: [spawnXZ], radius_m: exclusions.spawn_radius_m },
    // The first walk: straight ahead from the spawn, as a player who just holds W.
    { component: "spawn_forward", source_id: "manifest:initial_spawn_forward", points: [spawnXZ, ahead], radius_m: exclusions.spawn_forward_half_width_m },
    { component: "ferry_path", source_id: "qa:ferry_arrival_path", points: QA_CORRIDORS.ferry_arrival_path, radius_m: exclusions.ferry_path_half_width_m },
    { component: "qa_route", source_id: "qa:normal_qa_route", points: QA_CORRIDORS.normal_qa_route, radius_m: exclusions.qa_route_half_width_m },
  ];
  // The whole-island route flies between anchors; only its vertical take-off and
  // landing columns reach the ground. Its first point is the normal route's end.
  QA_CORRIDORS.whole_island_qa_route.slice(1).forEach((anchor, index) => {
    shapes.push({ component: "whole_island_anchor", source_id: `qa:whole_island_anchor_${index + 1}`, points: [anchor], radius_m: exclusions.whole_island_anchor_radius_m });
  });
  for (const flight of stairFlights) {
    const sourceId = `${flight.source_key}:stair_${flight.index}`;
    const dx = flight.bottom[0] - flight.top[0];
    const dz = flight.bottom[1] - flight.top[1];
    const length = Math.hypot(dx, dz);
    const approachEnd = [
      flight.bottom[0] + (dx / length) * exclusions.approach_length_m,
      flight.bottom[1] + (dz / length) * exclusions.approach_length_m,
    ];
    shapes.push({ component: "stair", source_id: sourceId, points: [flight.bottom, flight.top], radius_m: exclusions.stair_half_width_m });
    // The door landing at the top of the flight.
    shapes.push({ component: "door", source_id: sourceId, points: [flight.top], radius_m: exclusions.door_radius_m });
    shapes.push({ component: "approach", source_id: sourceId, points: [flight.bottom, approachEnd], radius_m: exclusions.approach_half_width_m });
  }
  return shapes;
}

function hardViolation(shapes, points, itemRadius) {
  for (const shape of shapes) {
    const distance = points.length === 1 ? polylineDistance(points[0], shape.points) : polylinePolylineDistance(points, shape.points);
    if (distance < shape.radius_m + itemRadius) {
      return {
        reason: shape.component,
        source_id: shape.source_id,
        observed_m: round3(Math.max(0, distance - itemRadius)),
        required_m: shape.radius_m,
      };
    }
  }
  return null;
}

function hardClearances(shapes, points, itemRadius) {
  const clearances = Object.fromEntries(STREET_DETAIL_HARD_COMPONENTS.map((component) => [component, Infinity]));
  for (const shape of shapes) {
    const distance = points.length === 1 ? polylineDistance(points[0], shape.points) : polylinePolylineDistance(points, shape.points);
    clearances[shape.component] = Math.min(clearances[shape.component], distance - itemRadius);
  }
  return clearances;
}

function polylineTangent(points, index, closed) {
  const last = points.length - 1;
  let previous = index > 0 ? points[index - 1] : null;
  let next = index < last ? points[index + 1] : null;
  if (closed && (index === 0 || index === last)) {
    previous = points[last - 1];
    next = points[1];
  }
  const unitVector = (from, to) => {
    const dx = to[0] - from[0];
    const dz = to[1] - from[1];
    const length = Math.hypot(dx, dz);
    return length > 1e-9 ? [dx / length, dz / length] : [0, 0];
  };
  const incoming = previous ? unitVector(previous, points[index]) : [0, 0];
  const outgoing = next ? unitVector(points[index], next) : [0, 0];
  const sum = [incoming[0] + outgoing[0], incoming[1] + outgoing[1]];
  if (Math.hypot(sum[0], sum[1]) > 1e-6) return sum;
  return Math.hypot(outgoing[0], outgoing[1]) > 0 ? outgoing : incoming;
}

function compassDirectionDegrees(value) {
  const text = String(value ?? "").trim().toUpperCase();
  if (/^-?\d+(\.\d+)?$/u.test(text)) return Number(text);
  return COMPASS_DEGREES[text] ?? null;
}

export const planDistance = polylinePolylineDistance;

// The point target metres along a polyline, stepped offset metres to the left
// of its direction (to the right when negative), in plan with north up.
function alongPoint(line, target, offset) {
  let walked = 0;
  for (let index = 1; index < line.length; index += 1) {
    const segment = Math.hypot(line[index][0] - line[index - 1][0], line[index][1] - line[index - 1][1]);
    if (walked + segment >= target || index === line.length - 1) {
      const fraction = segment > 0 ? Math.min(1, (target - walked) / segment) : 0;
      const dx = (line[index][0] - line[index - 1][0]) / (segment || 1);
      const dz = (line[index][1] - line[index - 1][1]) / (segment || 1);
      // Left of travel with north up: rotate the heading a quarter turn counterclockwise in plan.
      return [
        line[index - 1][0] + dx * segment * fraction + dz * offset,
        line[index - 1][1] + dz * segment * fraction - dx * offset,
      ];
    }
    walked += segment;
  }
  invariant(false, "alongPoint needs a polyline of two or more points");
  return null;
}

// An OSM way of the frozen proper extract as a world [x, z] polyline.
function wayLineIn(properSources) {
  return (sourceKey) => {
    const source = properSources.get(sourceKey);
    invariant(source, `Street detail way ${sourceKey} is not in the frozen OSM extract`);
    return geometryToLine(selectGeometry(source, "line"), sourceKey).map(toWorld);
  };
}

// The zones' shapes, queried with world points: {zone, contains(xz), bounds}.
export function streetDetailZoneShapes(config, properSources) {
  const wayLine = wayLineIn(properSources);
  return config.zones.map((zone) => {
    if (zone.shape.type === "polygon") {
      const ring = zone.shape.points_xz.map((point) => [point[0], point[1]]);
      const bounds = boundsOf(ring);
      return { zone, contains: (xz) => pointInRing(xz, ring, true), bounds };
    }
    const lines = zone.shape.source_keys.map(wayLine);
    const halfWidth = zone.shape.half_width_m;
    const all = boundsOf(lines.flat());
    return {
      zone,
      contains: (xz) => lines.some((line) => polylineDistance(xz, line) <= halfWidth),
      bounds: { min_x: all.min_x - halfWidth, min_y: all.min_y - halfWidth, max_x: all.max_x + halfWidth, max_y: all.max_y + halfWidth },
    };
  });
}

// The plan footprint of a placed row for clearance checks, as pieces of
// {points (world x, z), radius}: a fence's solid runs with its half thickness;
// a row with a footprint (a parked car, a long bench) the stadium that holds
// its rectangle; any other row its point or polyline with its kind's radius.
export function streetDetailPieces(row) {
  if (row.fence) return row.fence.runs.map((run) => ({ points: run.points_m.map((point) => [point[0], point[2]]), radius: row.fence.half_thickness_m }));
  if (row.footprint_m) return [footprintPiece([row.position_m[0], row.position_m[2]], row.yaw_radians, row.footprint_m)];
  const kind = STREET_DETAIL_KINDS[row.kind];
  return [{
    points: row.geometry === "point" ? [[row.position_m[0], row.position_m[2]]] : row.points_m.map((point) => [point[0], point[2]]),
    radius: kind.footprint_radius_m,
  }];
}

export function generateStreetDetail({
  projectRoot,
  boundary,
  playableObjects,
  chunks,
  terrainSupportAt,
  areaStyleFor,
  properSources,
  rawOsm,
  spawn,
  ground,
}) {
  const config = loadStreetDetailZones(projectRoot);
  const setPieceDocument = loadStreetDetailSetPieces(projectRoot);
  const stairFlights = loadStreetDetailStairFlights(projectRoot);
  const exclusions = config.exclusions;
  const seed = config.seed;
  const spawnXZ = [spawn.xz[0], spawn.xz[1]];
  const hardShapes = streetDetailHardShapes(exclusions, spawn, stairFlights);
  // The visible ground (draped areas, raised street ground, land) a planted row rests on.
  const groundAt = visibleGroundIndex(chunks);

  const objects = [...playableObjects.values()];
  const buildings = polygonSet(objects
    .filter((object) => object.roles.includes("building") || object.roles.includes("building_part"))
    .map((object) => ({ key: object.row.source_key, geometry: object.geometry })));
  const roads = polygonSet(objects
    .filter((object) => object.roles.includes("roads_paths"))
    .map((object) => ({ key: object.row.source_key, geometry: object.geometry, visual_class: object.road_visual_class })));
  // Plants keep off roads and paths too, except the OSM sidewalks a zone's
  // street ground photographed at the curb: their mulch bed takes that ground
  // (planting_behind_walk), so a plant may stand where the OSM line runs.
  const bedSidewalks = new Set(config.zones.flatMap((zone) => (zone.ground?.planting_behind_walk ?? []).flatMap((entry) => entry.source_keys)));
  // In a park zone with ground surfaces the photographed layers say what is paved
  // (a plant keeps off them by material), so its OSM paths don't also bar plants.
  const parkZones = streetDetailZoneShapes({ zones: config.zones.filter((zone) => zone.ground?.surfaces) }, properSources);
  const inParkZone = (item) => {
    const ring = item.geometry[0][0];
    return parkZones.some(({ contains }) => ring.filter(([east, north]) => contains([east, -north])).length * 2 >= ring.length);
  };
  const plantRoads = polygonSet(roads.items.filter((item) => !bedSidewalks.has(item.key) && !(item.visual_class === "pedestrian" && inParkZone(item))));
  const shorelineOverlays = polygonSet(objects
    .filter((object) => object.roles.includes("terrain_shoreline") && !object.logical_key.startsWith("land:") && !object.boundary_attached_visual)
    .map((object) => ({ key: object.row.source_key, geometry: object.geometry })));
  const areaSurfaces = polygonSet(objects
    .filter((object) => ![PLAYABLE_BOUNDARY_SOURCE_KEY, SHARED_COASTLINE_SOURCE_KEY, ...BOUNDARY_ATTACHED_SOURCE_KEYS].includes(object.row.source_key))
    .filter((object) => !object.roles.includes("roads_paths") && !object.roles.includes("building") && !object.roles.includes("building_part"))
    .map((object) => {
      const style = areaStyleFor(object);
      return { key: object.row.source_key, geometry: object.geometry, feature_kind: style.feature_kind, material_key: style.material_key, bias_m: style.elevation_m };
    }));

  const wayLine = wayLineIn(properSources);
  // Raw topology (node order and ids) for proper-extract ways; the extract's
  // geometry for these ways matches the raw nodes exactly.
  const rawWay = (sourceKey) => {
    const way = rawOsm.ways.get(sourceKey.slice(1));
    invariant(way, `Street detail way ${sourceKey} has no raw topology`);
    const points = way.node_refs.map((ref) => {
      const node = rawOsm.nodes.get(ref);
      invariant(node, `Way ${sourceKey} references missing node ${ref}`);
      return toWorld(projectLonLat(node.coordinate));
    });
    return { node_refs: way.node_refs, points, closed: way.node_refs.length >= 4 && way.node_refs[0] === way.node_refs.at(-1) };
  };

  // Ways that give a node its yaw: vehicle roads, crossing footways, other
  // pedestrian ways, barrier ways and power lines.
  const nodeHosts = new Map();
  const addHost = (family, sourceKey, way) => {
    way.node_refs.forEach((ref, index) => {
      const hosts = nodeHosts.get(ref) ?? [];
      if (!hosts.some((host) => host.source_key === sourceKey)) hosts.push({ family, source_key: sourceKey, index, way });
      nodeHosts.set(ref, hosts);
    });
  };
  const vehicleLines = [];
  for (const object of [...objects].sort((left, right) => compareSourceKeys(left.row.source_key, right.row.source_key))) {
    if (!object.roles.includes("roads_paths") || object.row.osm_type !== "way") continue;
    const way = rawWay(object.row.source_key);
    const family = object.road_visual_class === "vehicle" ? "vehicle" : object.tags.footway === "crossing" ? "crossing" : "pedestrian";
    addHost(family, object.row.source_key, way);
    if (object.road_visual_class === "vehicle") vehicleLines.push({ source_key: object.row.source_key, points: way.points });
  }

  const landEdgeDistance = (xz) => distanceToMultiPolygonEdges(toEastNorth(xz), boundary);
  const onLand = (xz, margin) => pointInMultiPolygon(toEastNorth(xz), boundary, false) && landEdgeDistance(xz) >= margin;
  const grounded = (xz) => {
    const support = terrainSupportAt(chunks, xz[0], -xz[1]);
    return { y: support.elevation_m, support };
  };
  const surfaceAt = (xz) => {
    // The always-on street ground (raised sidewalks and curb ramps) is the top surface where it exists.
    const raised = ground.surfaceAt(xz);
    if (raised) return raised;
    const containingRoads = roads.containing(xz).sort((left, right) => compareSourceKeys(left.key, right.key));
    const vehicle = containingRoads.find((item) => item.visual_class === "vehicle");
    if (vehicle) return { kind: "road_path", material_key: "road_path", source_key: vehicle.key, bias_m: ROAD_SURFACE_BIASES_M.base };
    if (containingRoads.length > 0) {
      return { kind: "road_path", material_key: "road_path_pedestrian", source_key: containingRoads[0].key, bias_m: ROAD_SURFACE_BIASES_M.pedestrian };
    }
    const areas = areaSurfaces.containing(xz)
      .sort((left, right) => right.bias_m - left.bias_m || compareSourceKeys(left.key, right.key));
    if (areas.length > 0) return { kind: areas[0].feature_kind, material_key: areas[0].material_key, source_key: areas[0].key, bias_m: areas[0].bias_m };
    return { kind: "land_ground", material_key: "land_ground", source_key: PLAYABLE_BOUNDARY_SOURCE_KEY, bias_m: 0 };
  };
  const nearestVehicleRoad = (xz) => {
    let best = null;
    for (const line of vehicleLines) {
      for (let index = 1; index < line.points.length; index += 1) {
        const closest = closestOnSegment(xz, line.points[index - 1], line.points[index]);
        const distance = Math.hypot(closest[0] - xz[0], closest[1] - xz[1]);
        if (!best || distance < best.distance) best = { distance, closest, source_key: line.source_key };
      }
    }
    return best;
  };

  const rows = [];
  const audit = {
    osm: { matched: 0, rows: 0, outside_land: [], excluded_by_reason: {} },
    scatter: { candidates: 0, placed: 0, rejected_by_reason: {} },
    set_pieces: { entries: setPieceDocument.set_pieces.length, placed: 0 },
  };
  const count = (table, key, number = 1) => {
    table[key] = (table[key] ?? 0) + number;
  };

  // A node's yaw from its kind's rule; an explicit OSM direction tag wins.
  const nodeYaw = (kind, sourceKey, tags, xz) => {
    const hosts = (nodeHosts.get(sourceKey.slice(1)) ?? []).slice().sort((left, right) => compareSourceKeys(left.source_key, right.source_key));
    const hostOf = (...families) => {
      for (const family of families) {
        const host = hosts.find((candidate) => candidate.family === family);
        if (host) return host;
      }
      return null;
    };
    const tangent = (host) => polylineTangent(host.way.points, host.index, host.way.closed);
    const directionDegrees = compassDirectionDegrees(tags.direction);
    if (directionDegrees != null) {
      // Compass bearing, clockwise from north: world direction (sin b, -cos b).
      const bearing = (directionDegrees * Math.PI) / 180;
      return { yaw: yawFacing(Math.sin(bearing), -Math.cos(bearing)), source: `osm_direction:${tags.direction}` };
    }
    const rule = STREET_DETAIL_KINDS[kind].yaw_rule;
    if (rule === "host_road") {
      const host = hostOf("vehicle", "pedestrian", "crossing");
      if (!host) return { yaw: null, source: null };
      const t = tangent(host);
      // A sign for traffic travelling with (forward) the way faces back toward it.
      if (tags.direction === "forward") return { yaw: yawFacing(-t[0], -t[1]), source: `osm_direction:forward@${host.source_key}` };
      if (tags.direction === "backward") return { yaw: yawFacing(t[0], t[1]), source: `osm_direction:backward@${host.source_key}` };
      return { yaw: yawFacing(t[0], t[1]), source: `host_way_tangent:${host.source_key}` };
    }
    if (rule === "crossing") {
      // Front along the walking direction: a crossing footway's own line, else
      // across the road, else along whatever path the node is on.
      const footway = hostOf("crossing");
      if (footway) {
        const t = tangent(footway);
        return { yaw: yawFacing(t[0], t[1]), source: `host_way_tangent:${footway.source_key}` };
      }
      const road = hostOf("vehicle");
      if (road) {
        const t = tangent(road);
        return { yaw: yawFacing(-t[1], t[0]), source: `host_way_normal:${road.source_key}` };
      }
      const path = hostOf("pedestrian");
      if (!path) return { yaw: null, source: null };
      const t = tangent(path);
      return { yaw: yawFacing(t[0], t[1]), source: `host_way_tangent:${path.source_key}` };
    }
    if (rule === "host_barrier") {
      // Front along the passage: across a barrier line, along a road.
      const barrier = hostOf("barrier");
      if (barrier) {
        const t = tangent(barrier);
        return { yaw: yawFacing(-t[1], t[0]), source: `host_way_normal:${barrier.source_key}` };
      }
      const road = hostOf("vehicle", "pedestrian", "crossing");
      if (!road) return { yaw: null, source: null };
      const t = tangent(road);
      return { yaw: yawFacing(t[0], t[1]), source: `host_way_tangent:${road.source_key}` };
    }
    if (rule === "host_power_line") {
      const line = hostOf("power");
      if (!line) return { yaw: null, source: null };
      const t = tangent(line);
      return { yaw: yawFacing(t[0], t[1]), source: `host_way_tangent:${line.source_key}` };
    }
    if (rule === "faces_road") {
      const road = nearestVehicleRoad(xz);
      if (!road || road.distance > FACES_ROAD_MAXIMUM_M || road.distance < 0.05) return { yaw: null, source: null };
      return { yaw: yawFacing(road.closest[0] - xz[0], road.closest[1] - xz[1]), source: `faces_road:${road.source_key}` };
    }
    return { yaw: null, source: null };
  };

  const pointExclusion = (kindName, xz, { wallBuffer }) => {
    const kind = STREET_DETAIL_KINDS[kindName];
    if (kind.layer === STREET_DETAIL_GROUND_LAYER) return null;
    const hard = hardViolation(hardShapes, [xz], kind.footprint_radius_m);
    if (hard) return hard;
    const building = buildings.nearest(xz, wallBuffer + kind.footprint_radius_m);
    if (building.distance === 0) return { reason: "inside_building", source_id: building.key, observed_m: 0, required_m: wallBuffer };
    if (building.distance < wallBuffer + kind.footprint_radius_m) {
      return { reason: "wall_buffer", source_id: building.key, observed_m: round3(Math.max(0, building.distance - kind.footprint_radius_m)), required_m: wallBuffer };
    }
    return null;
  };

  // (a) OSM ways first: their vertices give gates and poles a host line.
  const sourceKeys = [...properSources.keys()].sort(compareSourceKeys);
  const lineRows = new Map();
  for (const sourceKey of sourceKeys) {
    if (sourceKey[0] !== "w") continue;
    const source = properSources.get(sourceKey);
    const match = osmLineKind(source.metadata.tags);
    if (!match) continue;
    audit.osm.matched += 1;
    const [kindName, sourceTag] = match;
    const kind = STREET_DETAIL_KINDS[kindName];
    const way = rawWay(sourceKey);
    const exported = selectGeometry(source, "line").coordinates.map((coordinate) => toWorld(projectLonLat(coordinate)));
    invariant(
      exported.length === way.points.length && exported.every((point, index) => point[0] === way.points[index][0] && point[1] === way.points[index][1]),
      `${sourceKey} raw topology differs from the frozen extract geometry`,
    );
    const points = way.points.map((point) => [round3(point[0]), round3(point[1])]);
    if (!points.every((point) => onLand(point, LAND_EDGE_EPSILON_M))) {
      audit.osm.outside_land.push({ source_id: sourceKey, kind: kindName });
      continue;
    }
    for (let index = 1; index < points.length; index += 1) {
      invariant(points[index][0] !== points[index - 1][0] || points[index][1] !== points[index - 1][1], `${sourceKey} has a zero-length segment`);
    }
    const supports = points.map(grounded);
    // A fence opens where it meets the mask (street-fence-generation.mjs) instead of being dropped whole.
    const exclusion = kind.overhead || kind.layer === STREET_DETAIL_GROUND_LAYER || kindName === "fence" ? null : hardViolation(hardShapes, points, kind.footprint_radius_m);
    if (exclusion) count(audit.osm.excluded_by_reason, exclusion.reason);
    const row = {
      id: `osm:${sourceKey}`,
      source: "osm",
      source_id: sourceKey,
      source_tag: sourceTag,
      kind: kindName,
      layer: kind.layer,
      geometry: "polyline",
      points_m: points.map((point, index) => [point[0], supports[index].y, point[1]]),
      terrain_supports: supports.map(({ support }) => [support.object_key, support.triangle_index]),
      vertex_source_ids: way.node_refs.map((ref) => `n${ref}`),
      closed: way.closed,
      length_m: round3(polylineLength(points)),
      attached_ids: [],
      tags: source.metadata.tags,
      status: exclusion ? "excluded" : "placed",
      exclusion,
    };
    rows.push(row);
    lineRows.set(sourceKey, row);
    addHost(kindName === "power_line" ? "power" : "barrier", sourceKey, way);
  }
  for (const sourceKey of sourceKeys) {
    if (sourceKey[0] !== "n") continue;
    const source = properSources.get(sourceKey);
    const match = osmPointKind(source.metadata.tags);
    if (!match) continue;
    audit.osm.matched += 1;
    const [kindName, sourceTag] = match;
    const kind = STREET_DETAIL_KINDS[kindName];
    const point = source.features.find((feature) => feature.type === "Point");
    invariant(point, `${sourceKey} has no point geometry`);
    const raw = toWorld(projectLonLat(point.coordinates));
    const xz = [round3(raw[0]), round3(raw[1])];
    if (!onLand(xz, LAND_EDGE_EPSILON_M)) {
      audit.osm.outside_land.push({ source_id: sourceKey, kind: kindName });
      continue;
    }
    const { y, support } = grounded(xz);
    const yaw = nodeYaw(kindName, sourceKey, source.metadata.tags, xz);
    const exclusion = pointExclusion(kindName, xz, { wallBuffer: exclusions.wall_buffer_m });
    if (exclusion) count(audit.osm.excluded_by_reason, exclusion.reason);
    rows.push({
      id: `osm:${sourceKey}`,
      source: "osm",
      source_id: sourceKey,
      source_tag: sourceTag,
      kind: kindName,
      layer: kind.layer,
      geometry: "point",
      position_m: [xz[0], y, xz[1]],
      terrain_support: { object_key: support.object_key, triangle_index: support.triangle_index, elevation_m: support.elevation_m },
      surface: surfaceAt(xz),
      yaw_radians: yaw.yaw,
      yaw_source: yaw.source,
      tags: source.metadata.tags,
      status: exclusion ? "excluded" : "placed",
      exclusion,
    });
    for (const host of nodeHosts.get(sourceKey.slice(1)) ?? []) {
      const line = lineRows.get(host.source_key);
      if (line && !line.attached_ids.includes(`osm:${sourceKey}`)) line.attached_ids.push(`osm:${sourceKey}`);
    }
  }
  for (const line of lineRows.values()) line.attached_ids.sort(compareText);
  audit.osm.rows = rows.length;

  const zoneShapes = streetDetailZoneShapes(config, properSources);
  // Fences, before anything placed around them: OSM fence ways open where roads,
  // paths, gates and the gameplay mask cross them, and the zones' fence rules add
  // the photographed fencing OSM lacks (tools/lib/street-fence-generation.mjs).
  const fences = placeStreetFences({
    config,
    rows,
    zoneShapes,
    kinds: STREET_DETAIL_KINDS,
    site: ground.site,
    roads,
    buildings,
    hardShapes,
    hardViolation,
    onLand,
    grounded,
    surfaceAt,
    wayLine,
    rawOsm,
    // Raw nodes carry no tags; the proper extract has the tagged ones (gates).
    nodeTags: (ref) => properSources.get(`n${ref}`)?.metadata.tags ?? {},
  });
  rows.push(...fences.rows);
  const builtFences = new Set(rows.filter((row) => row.kind === "fence" && row.prop != null).map((row) => row.id));
  for (const entry of config.fenced_approaches.entries) {
    for (const id of entry.fence_ids) invariant(builtFences.has(id), `Fenced approach ${entry.source_key}/${entry.side} names ${id}, which is not a built fence row`);
  }

  // Footprints already claimed by placed switchable rows, for overlap checks: a
  // fence claims each of its solid runs, its half thickness wide; a parked car
  // or a long prop its footprint (streetDetailPieces); a tree in paving its
  // mulch pit, so nothing later stands or parks in it.
  const occupied = [];
  // planted: the row came from a drifts or fill rule, whose zone's planting
  // state keeps its plants apart by their crown widths.
  const occupy = (row, planted = false) => {
    const kind = STREET_DETAIL_KINDS[row.kind];
    if (row.status !== "placed" || kind.overhead || kind.layer === STREET_DETAIL_GROUND_LAYER) return;
    const pit = (row.prop_params?.well_m ?? 0) / 2;
    // Low plants (grass clumps, planting slots) have no collision; drift planting may overlap them.
    const lowPlant = row.layer === "vegetation" && (row.kind === "grass_clump" || row.kind === "planting_slot");
    streetDetailPieces(row).forEach((piece, index) => {
      occupied.push({ id: row.fence ? `${row.id}#run${index}` : row.id, points: piece.points, radius_m: Math.max(piece.radius, pit), lowPlant, planted });
    });
  };
  rows.forEach(occupy);
  // Site checks for a set piece that is a street prop (it stands on the street
  // ground like the street furniture): the mask, land, walls, the carriageway,
  // curb ramps and crosswalks, and a player's width from every other item.
  const crosswalkAt = (en) => ground.site.crosswalks.some((walk) => {
    const along = (en[0] - walk.center[0]) * walk.direction[0] + (en[1] - walk.center[1]) * walk.direction[1];
    const across = (en[0] - walk.center[0]) * walk.across[0] + (en[1] - walk.center[1]) * walk.across[1];
    return along >= walk.span[0] - 1 && along <= walk.span[1] + 1 && Math.abs(across) <= ground.site.walk_width_m / 2 + 0.5;
  });
  const propSiteViolation = (piece) => {
    const { radius } = piece;
    // The footprint's segment, sampled every half metre for the site tests.
    const samples = [];
    const [a, b] = [piece.points[0], piece.points.at(-1)];
    const steps = Math.max(1, Math.ceil(Math.hypot(b[0] - a[0], b[1] - a[1]) / 0.5));
    for (let step = 0; step <= steps; step += 1) samples.push([a[0] + ((b[0] - a[0]) * step) / steps, a[1] + ((b[1] - a[1]) * step) / steps]);
    const violation = (reason, sourceId = null) => ({ reason, source_id: sourceId, observed_m: null, required_m: null });
    if (!samples.every((xz) => onLand(xz, exclusions.land_edge_buffer_m + radius))) return violation("land_edge", PLAYABLE_BOUNDARY_SOURCE_KEY);
    const hard = hardViolation(hardShapes, piece.points, radius);
    if (hard) return hard;
    for (const xz of samples) {
      const building = buildings.nearest(xz, exclusions.wall_buffer_m + radius);
      if (building.distance < exclusions.wall_buffer_m + radius) return violation(building.distance === 0 ? "inside_building" : "wall_buffer", building.key);
      const en = toEastNorth(xz);
      if (ground.site.carriagewayDistance(en) < PROP_KERB_CLEAR_M + radius) return violation("carriageway");
      if (ground.site.rampDistance(en) < PROP_RAMP_CLEAR_M + radius) return violation("curb_ramp");
      if (crosswalkAt(en)) return violation("crosswalk");
    }
    for (const item of occupied) {
      const distance = polylinePolylineDistance(piece.points, item.points);
      if (distance < item.radius_m + radius + PLAYER_WIDTH_M) return { reason: "overlap", source_id: item.id, observed_m: round3(distance), required_m: round3(item.radius_m + radius + PLAYER_WIDTH_M) };
    }
    return null;
  };

  // Site checks shared by scatter and set pieces, after the gameplay mask.
  const siteViolation = (kindName, xz, buildingBuffer) => {
    const kind = STREET_DETAIL_KINDS[kindName];
    const radius = kind.footprint_radius_m;
    if (!onLand(xz, exclusions.land_edge_buffer_m + radius)) return { reason: "land_edge", source_id: PLAYABLE_BOUNDARY_SOURCE_KEY, observed_m: 0, required_m: exclusions.land_edge_buffer_m };
    const hard = hardViolation(hardShapes, [xz], radius);
    if (hard) return hard;
    const building = buildings.nearest(xz, buildingBuffer + radius);
    if (building.distance < buildingBuffer + radius) {
      return { reason: building.distance === 0 ? "inside_building" : "building_buffer", source_id: building.key, observed_m: round3(Math.max(0, building.distance - radius)), required_m: buildingBuffer };
    }
    const road = (kind.layer === "vegetation" ? plantRoads : roads).nearest(xz, exclusions.road_buffer_m + radius);
    if (road.distance < exclusions.road_buffer_m + radius) {
      return { reason: "road", source_id: road.key, observed_m: round3(Math.max(0, road.distance - radius)), required_m: exclusions.road_buffer_m };
    }
    const overlay = shorelineOverlays.nearest(xz, radius);
    if (overlay.distance < radius || overlay.distance === 0) return { reason: "shoreline_overlay", source_id: overlay.key, observed_m: round3(overlay.distance), required_m: radius };
    for (const item of occupied) {
      const distance = polylineDistance(xz, item.points);
      if (distance < item.radius_m + radius) return { reason: "overlap", source_id: item.id, observed_m: round3(distance), required_m: round3(item.radius_m + radius) };
    }
    return null;
  };

  // (c) Hand-picked set pieces must clear the whole mask and the OSM items; a bad
  // entry stops the build. They come before scatter, which then works around them.
  // A kit tree rests on the visible ground round its foot, a prop on legs on the
  // ground under its feet (groundAt, the one visible-ground index above).
  for (const entry of setPieceDocument.set_pieces) {
    const xz = [round3(entry.xz[0]), round3(entry.xz[1])];
    // A planted tree keeps the scatter's site checks; a street prop the furniture's margins.
    const tree = STREET_DETAIL_KINDS[entry.kind].layer === "vegetation";
    const footprint = entry.prop === undefined || tree ? null : (streetFurnitureFootprint(entry.prop, entry.params) ?? STREET_CLUTTER_FOOTPRINTS[entry.prop] ?? null);
    const piece = footprint
      ? footprintPiece(xz, normalizedYaw(entry.yaw), footprint)
      : { points: [xz], radius: STREET_DETAIL_KINDS[entry.kind].footprint_radius_m };
    const violation = entry.prop === undefined || tree ? siteViolation(entry.kind, xz, exclusions.wall_buffer_m) : propSiteViolation(piece);
    invariant(!violation, `Street detail set piece ${entry.id} fails the exclusion mask: ${JSON.stringify(violation)}`);
    const { y, support } = grounded(xz);
    const surface = surfaceAt(xz);
    let planted = null;
    let params = entry.params;
    if (entry.prop !== undefined && tree) {
      // A kit tree: it must rest on the visible ground round its foot.
      planted = plantRow({ prop: entry.prop, kind: entry.kind, variant: entry.params.variant, scale: entry.params.scale, xz, landY: y, surface, groundAt });
      invariant(!planted.problem, `Street detail set piece ${entry.id} cannot rest on the visible ground: ${planted.problem}`);
    }
    const feet = entry.prop === undefined ? undefined : STREET_FURNITURE_FEET[entry.prop];
    if (feet) {
      const rest = settleOnFeet(feet, xz, normalizedYaw(entry.yaw), y + surface.bias_m, groundAt);
      invariant(!rest.problem, `Street detail set piece ${entry.id} cannot stand on its feet: ${rest.problem}`);
      params = { ...entry.params, ...rest };
    }
    const row = {
      id: `set_piece:${entry.id}`,
      source: "set_piece",
      source_id: entry.id,
      kind: entry.kind,
      layer: STREET_DETAIL_KINDS[entry.kind].layer,
      geometry: "point",
      position_m: [xz[0], y, xz[1]],
      terrain_support: { object_key: support.object_key, triangle_index: support.triangle_index, elevation_m: support.elevation_m },
      surface,
      yaw_radians: normalizedYaw(entry.yaw),
      yaw_source: "set_piece",
      ...(entry.prop === undefined ? { asset: entry.asset } : planted ?? { prop: entry.prop, prop_params: params }),
      ...(footprint ? { footprint_m: { ...footprint } } : {}),
      reason: entry.reason,
      reference: entry.reference,
      status: "placed",
      exclusion: null,
    };
    rows.push(row);
    occupy(row);
    audit.set_pieces.placed += 1;
  }

  // (b) Seeded zone scatter. Candidates are visited in config order, so a later
  // rule never displaces an earlier one; every draw is keyed by the candidate id.
  // The slot rules run here; the planting rules (those with a prop) run after
  // the street furniture (b2), so plants work around the lamps and signs.
  const ruleSummaries = new Map();
  // A drifts or fill rule (tools/lib/street-planting-generation.mjs): its plants
  // keep the gameplay mask, the land, walls and every placed item except low
  // plants and the zone's other planted rows (no collision), which the zone's
  // planting state keeps apart by their crown widths instead; and each stands
  // where its bed is the visible ground (not under a walk drawn over the bed).
  const slopeAt = (xz) => {
    const step = 0.6;
    const at = (dx, dz) => groundAt([xz[0] + dx, xz[1] + dz])?.y;
    const [east, west, south, north] = [at(step, 0), at(-step, 0), at(0, step), at(0, -step)];
    if ([east, west, south, north].some((value) => value === undefined)) return Infinity;
    return Math.hypot((east - west) / (2 * step), (south - north) / (2 * step));
  };
  const plantingStates = new Map();
  const placePlanting = (zone, rule, contains) => {
    if (!plantingStates.has(zone.id)) plantingStates.set(zone.id, plantingState());
    const radius = STREET_DETAIL_KINDS[rule.kind].footprint_radius_m;
    // The items a plant must clear, on a coarse grid of their reach.
    const BLOCK_CELL_M = 8;
    const blockers = new Map();
    for (const item of occupied) {
      if (item.lowPlant || item.planted) continue;
      const reach = item.radius_m + radius;
      const xs = item.points.map((point) => point[0]);
      const zs = item.points.map((point) => point[1]);
      for (let i = Math.floor((Math.min(...xs) - reach) / BLOCK_CELL_M); i <= Math.floor((Math.max(...xs) + reach) / BLOCK_CELL_M); i += 1) {
        for (let j = Math.floor((Math.min(...zs) - reach) / BLOCK_CELL_M); j <= Math.floor((Math.max(...zs) + reach) / BLOCK_CELL_M); j += 1) {
          const key = `${i},${j}`;
          if (!blockers.has(key)) blockers.set(key, []);
          blockers.get(key).push(item);
        }
      }
    }
    let candidates = 0;
    let placed = 0;
    const accept = (candidate) => {
      candidates += 1;
      audit.scatter.candidates += 1;
      const xz = candidate.xz;
      let problem = null;
      if (!contains(xz)) problem = "outside_zone";
      else if (!onLand(xz, exclusions.land_edge_buffer_m + radius * 0.5)) problem = "land_edge";
      else if (hardViolation(hardShapes, [xz], radius)) problem = hardViolation(hardShapes, [xz], radius).reason;
      else if (buildings.nearest(xz, exclusions.building_buffer_m + radius).distance < exclusions.building_buffer_m + radius) problem = "building_buffer";
      else if (shorelineOverlays.nearest(xz, radius).distance < radius) problem = "shoreline_overlay";
      else if (!rule.surfaces.includes(surfaceAt(xz).material_key)) problem = "rule_surface";
      else {
        const near = blockers.get(`${Math.floor(xz[0] / BLOCK_CELL_M)},${Math.floor(xz[1] / BLOCK_CELL_M)}`) ?? [];
        if (near.some((item) => polylineDistance(xz, item.points) < item.radius_m + radius)) problem = "overlap";
      }
      if (problem) {
        count(audit.scatter.rejected_by_reason, problem);
        return false;
      }
      const surface = surfaceAt(xz);
      const { y, support } = grounded(xz);
      const planted = plantRow({ prop: candidate.prop, kind: rule.kind, variant: candidate.variant, scale: candidate.scale, xz, landY: y, surface, groundAt });
      if (planted.problem) {
        count(audit.scatter.rejected_by_reason, planted.problem);
        return false;
      }
      const row = {
        id: `scatter:${zone.id}:${rule.id}:p${String(placed).padStart(5, "0")}`,
        source: "scatter",
        source_id: `zone:${zone.id}/${rule.id}`,
        kind: rule.kind,
        layer: "vegetation",
        geometry: "point",
        position_m: [xz[0], y, xz[1]],
        terrain_support: { object_key: support.object_key, triangle_index: support.triangle_index, elevation_m: support.elevation_m },
        surface,
        yaw_radians: normalizedYaw(unit(hashBytes(seed, `${zone.id}:${rule.id}:${candidate.identity}`), 12) * Math.PI * 2 - Math.PI),
        yaw_source: "seeded",
        ...planted,
        status: "placed",
        exclusion: null,
      };
      rows.push(row);
      occupy(row, true);
      placed += 1;
      audit.scatter.placed += 1;
      return true;
    };
    const plan = (rule.pattern === "drifts" ? planDrifts : planFill)({
      rule,
      zoneId: zone.id,
      seed,
      bed: (xz) => ground.site.parkBed([xz[0], -xz[1]], rule.surfaces),
      onBed: (xz) => ground.site.parkBedOn([xz[0], -xz[1]], rule.surfaces),
      slopeAt,
      paving: (xz, radius) => pavingUnder(xz, radius, groundAt),
      state: plantingStates.get(zone.id),
      accept,
    });
    for (const [reason, number] of Object.entries(plan.rejected)) count(audit.scatter.rejected_by_reason, `planting_${reason}`, number);
    ruleSummaries.set(`${zone.id}/${rule.id}`, { id: rule.id, kind: rule.kind, pattern: rule.pattern, candidates, placed, ...(plan.cover === undefined ? {} : { cover: plan.cover }) });
  };
  // A low plant's spot and variant whose whole crown clears paving, as the
  // planted beds keep theirs: its own point, else one nudged up to 0.45 m round
  // it that still passes problemAt (the rule's own checks), in the drawn variant,
  // else a lower one; null when there is none.
  const CROWN_NUDGES = [[0, 0], ...[0.15, 0.3, 0.45].flatMap((step) =>
    [0, 1, 2, 3, 4, 5, 6, 7].map((k) => [step * Math.cos((k * Math.PI) / 4), step * Math.sin((k * Math.PI) / 4)]))];
  const crownSpot = (prop, params, drawn, xz, problemAt) => {
    for (let variant = drawn.variant; variant >= params.variants[0]; variant -= 1) {
      const reach = crownRadius(prop, variant, drawn.scale) + PAVING_CLEAR_M;
      for (const [dx, dz] of CROWN_NUDGES) {
        const spot = [round3(xz[0] + dx), round3(xz[1] + dz)];
        if ((dx !== 0 || dz !== 0) && problemAt(spot) !== null) continue;
        if (!pavingUnder(spot, reach, groundAt)) return { xz: spot, variant };
      }
    }
    return null;
  };
  const runScatter = (planting) => {
    for (const { zone, contains, bounds } of zoneShapes) {
      for (const rule of zone.scatter) {
        if ((rule.prop != null || PLANTING_PATTERNS.includes(rule.pattern)) !== planting) continue;
        if (PLANTING_PATTERNS.includes(rule.pattern)) {
          placePlanting(zone, rule, contains);
          continue;
        }
        const candidates = [];
        if (rule.pattern === "grid") {
          for (let row = 0, z = bounds.min_y + rule.spacing_m / 2; z <= bounds.max_y; row += 1, z += rule.spacing_m) {
            for (let column = 0, x = bounds.min_x + rule.spacing_m / 2; x <= bounds.max_x; column += 1, x += rule.spacing_m) {
              candidates.push({ cell: `r${String(row).padStart(3, "0")}c${String(column).padStart(3, "0")}`, base: [x, z], along: null });
            }
          }
        } else if (rule.pattern === "along") {
          const lines = rule.line_xz ? [["line", rule.line_xz]] : rule.source_keys.map((wayKey) => [wayKey, wayLine(wayKey)]);
          for (const [lineKey, line] of lines) {
            const length = polylineLength(line);
            rule.offsets_m.forEach((offset, offsetIndex) => {
              // stagger_m shifts every other row along the line (a staggered double row).
              const phase = offsetIndex % 2 === 1 ? (rule.stagger_m ?? 0) : 0;
              for (let step = 0, distance = rule.spacing_m / 2 + phase; distance <= length; step += 1, distance += rule.spacing_m) {
                candidates.push({ cell: `${lineKey}_o${offsetIndex}_s${String(step).padStart(3, "0")}`, base: null, along: { line, length, distance, offset } });
              }
            });
          }
        } else {
          // along_beds: one station per spacing on each side, planted in the bed found across the way there.
          for (const wayKey of rule.source_keys) {
            const line = wayLine(wayKey);
            const length = polylineLength(line);
            for (const side of rule.sides) {
              for (let step = 0, distance = rule.spacing_m / 2; distance <= length; step += 1, distance += rule.spacing_m) {
                candidates.push({ cell: `${wayKey}_${side}_s${String(step).padStart(3, "0")}`, base: null, along: { line, length, distance, side } });
              }
            }
          }
        }
        let placed = 0;
        for (const candidate of candidates) {
          const identity = `${zone.id}:${rule.id}:${candidate.cell}`;
          const bytes = hashBytes(seed, identity);
          audit.scatter.candidates += 1;
          if (unit(bytes, 0) >= rule.acceptance) {
            count(audit.scatter.rejected_by_reason, "seed_acceptance");
            continue;
          }
          // Why a candidate point cannot take a row, or null.
          const placementProblem = (xz) => {
            if (!contains(xz)) return "outside_zone";
            if (rule.within_xz && !pointInRing(xz, rule.within_xz, true)) return "outside_rule_area";
            const violation = siteViolation(rule.kind, xz, exclusions.building_buffer_m);
            if (violation) return violation.reason;
            const material = surfaceAt(xz).material_key;
            if (STREET_DETAIL_KINDS[rule.kind].layer === "vegetation" && UNPLANTABLE_MATERIALS.includes(material)) return "unplantable_surface";
            // The whole footprint stands on the rule's surfaces, so a plant keeps
            // inside its bed, clear of the curb and the cars parked along it.
            if (rule.surfaces && !footSamples(xz, STREET_DETAIL_KINDS[rule.kind].footprint_radius_m).every((point) => rule.surfaces.includes(surfaceAt(point).material_key))) return "rule_surface";
            return null;
          };
          let xz = null;
          let problem = null;
          if (candidate.along) {
            // Jitter along the line, then step off it by the rule's offset (+ is left of the way direction).
            const target = Math.max(0, Math.min(candidate.along.length, candidate.along.distance + (unit(bytes, 4) * 2 - 1) * rule.jitter_m));
            if (candidate.along.side === undefined) {
              const point = alongPoint(candidate.along.line, target, candidate.along.offset);
              xz = [round3(point[0]), round3(point[1])];
              problem = placementProblem(xz);
            } else {
              // The first spot in the bed, from its middle outward, that clears the site checks.
              const sign = candidate.along.side === "left" ? 1 : -1;
              const offsets = bedOffsets((offset) => alongPoint(candidate.along.line, target, sign * offset), rule.reach_m, rule.min_bed_m, rule.surfaces, surfaceAt, STREET_DETAIL_KINDS[rule.kind].footprint_radius_m);
              problem = "no_bed";
              for (const offset of offsets) {
                const point = alongPoint(candidate.along.line, target, sign * offset);
                const spot = [round3(point[0]), round3(point[1])];
                const spotProblem = placementProblem(spot);
                if (spotProblem === null) {
                  xz = spot;
                  problem = null;
                  break;
                }
                if (problem === "no_bed") problem = spotProblem;
              }
            }
          } else {
            xz = [
              round3(candidate.base[0] + (unit(bytes, 4) * 2 - 1) * rule.jitter_m),
              round3(candidate.base[1] + (unit(bytes, 8) * 2 - 1) * rule.jitter_m),
            ];
            problem = placementProblem(xz);
          }
          if (problem) {
            count(audit.scatter.rejected_by_reason, problem);
            continue;
          }
          let drawn = rule.prop ? drawVegetationVariant(seed, identity, rule.params) : null;
          if (drawn && !STREET_VEGETATION_PROPS[rule.prop].trunk) {
            const spot = crownSpot(rule.prop, rule.params, drawn, xz, placementProblem);
            if (!spot) {
              count(audit.scatter.rejected_by_reason, "crown_paving");
              continue;
            }
            xz = spot.xz;
            drawn = { variant: spot.variant, scale: drawn.scale };
          }
          const surface = surfaceAt(xz);
          const { y, support } = grounded(xz);
          let planted = null;
          if (rule.prop) {
            const { variant, scale } = drawn;
            planted = plantRow({ prop: rule.prop, kind: rule.kind, variant, scale, xz, landY: y, surface, groundAt });
            if (planted.problem) {
              count(audit.scatter.rejected_by_reason, planted.problem);
              continue;
            }
          }
          const row = {
            id: `scatter:${identity}`,
            source: "scatter",
            source_id: `zone:${zone.id}/${rule.id}`,
            kind: rule.kind,
            layer: STREET_DETAIL_KINDS[rule.kind].layer,
            geometry: "point",
            position_m: [xz[0], y, xz[1]],
            terrain_support: { object_key: support.object_key, triangle_index: support.triangle_index, elevation_m: support.elevation_m },
            surface,
            yaw_radians: normalizedYaw(unit(bytes, 12) * Math.PI * 2 - Math.PI),
            yaw_source: "seeded",
            ...(planted ?? {}),
            status: "placed",
            exclusion: null,
          };
          rows.push(row);
          occupy(row);
          placed += 1;
          audit.scatter.placed += 1;
        }
        ruleSummaries.set(`${zone.id}/${rule.id}`, { id: rule.id, kind: rule.kind, pattern: rule.pattern, candidates: candidates.length, placed });
      }
    }
  };
  runScatter(false);

  // (d) Street furniture, after everything above so it works around it: kit
  // props for the pilot zones' OSM rows (stop signs move to their curbs) and the
  // zones' furniture rules (tools/lib/street-furniture-generation.mjs).
  const furniture = placeStreetFurniture({
    kinds: STREET_DETAIL_KINDS,
    rows,
    occupied,
    zoneShapes,
    site: ground.site,
    rawOsm,
    hardViolation,
    hardShapes,
    buildings,
    exclusions,
    onLand,
    grounded,
    surfaceAt,
  });
  rows.push(...furniture.rows);
  // (b2) The planting scatter: trees and grass round the furniture placed above.
  runScatter(true);
  const zoneSummaries = config.zones.map((zone) => ({
    id: zone.id,
    name: zone.name,
    pilot: zone.pilot,
    scatter: zone.scatter.map((rule) => ruleSummaries.get(`${zone.id}/${rule.id}`)),
  }));
  for (const summary of zoneSummaries) {
    const zone = config.zones.find((candidate) => candidate.id === summary.id);
    summary.furniture = (zone.furniture ?? []).map((rule) => ({
      id: rule.id,
      kind: rule.kind,
      prop: rule.prop,
      pattern: rule.pattern,
      placed: furniture.audit.rules[`${zone.id}/${rule.id}`] ?? 0,
    }));
    summary.fences = (zone.fences ?? []).map((rule) => {
      const row = rows.find((candidate) => candidate.id === `scatter:${zone.id}:${rule.id}:line`);
      return { id: rule.id, fence_type: rule.fence_type, row: row?.id ?? null, built_runs: row?.fence.runs.length ?? 0 };
    });
  }

  // (e) Street clutter, last: the parked cars of the zones' clutter rules
  // (tools/lib/street-clutter-generation.mjs) along the parking lanes and in
  // the painted lot stalls, clear of everything placed above (the furniture
  // rules have already claimed their footprints).
  const clutter = placeStreetClutter({
    kinds: STREET_DETAIL_KINDS,
    rows,
    occupied,
    zoneShapes,
    site: ground.site,
    rawOsm,
    seed,
    hardViolation,
    hardShapes,
    buildings,
    exclusions,
    onLand,
    grounded,
    surfaceAt,
    chunks,
  });
  rows.push(...clutter.rows);
  for (const summary of zoneSummaries) {
    const zone = config.zones.find((candidate) => candidate.id === summary.id);
    summary.clutter = (zone.clutter ?? []).map((rule) => ({
      id: rule.id,
      kind: rule.kind,
      prop: rule.prop,
      pattern: rule.pattern,
      placed: clutter.audit.rules[`${zone.id}/${rule.id}`] ?? 0,
    }));
  }

  rows.sort((left, right) => compareText(left.id, right.id));
  invariant(new Set(rows.map((row) => row.id)).size === rows.length, "Street detail row ids are not unique");
  const minimumClearances = Object.fromEntries(STREET_DETAIL_HARD_COMPONENTS.map((component) => [component, Infinity]));
  for (const row of rows) {
    const points = row.geometry === "point" ? [[row.position_m[0], row.position_m[2]]] : row.points_m.map((point) => [point[0], point[2]]);
    row.zones = zoneShapes.filter(({ contains }) => points.some((point) => contains(point))).map(({ zone }) => zone.id).sort(compareText);
    const kind = STREET_DETAIL_KINDS[row.kind];
    if (row.status !== "placed" || kind.overhead || kind.layer === STREET_DETAIL_GROUND_LAYER) continue;
    for (const piece of streetDetailPieces(row)) {
      const clearances = hardClearances(hardShapes, piece.points, piece.radius);
      for (const component of STREET_DETAIL_HARD_COMPONENTS) {
        minimumClearances[component] = Math.min(minimumClearances[component], clearances[component]);
      }
    }
  }
  for (const component of STREET_DETAIL_HARD_COMPONENTS) {
    const required = hardShapes.find((shape) => shape.component === component)?.radius_m ?? 0;
    invariant(minimumClearances[component] >= required, `Placed street detail enters the ${component} clearance`);
  }
  audit.osm.outside_land.sort((left, right) => compareSourceKeys(left.source_id, right.source_id));
  const countBy = (field, values) => Object.fromEntries(values.map((value) => [value, rows.filter((row) => row[field] === value).length]));
  const placedBy = (field, values) => Object.fromEntries(values.map((value) => [value, rows.filter((row) => row.status === "placed" && row[field] === value).length]));
  const layerNames = [...STREET_DETAIL_LAYERS, STREET_DETAIL_GROUND_LAYER];
  const pilotZones = new Set(config.zones.filter((zone) => zone.pilot).map((zone) => zone.id));
  // The planting rules' many small rows go in compact blocks (packPlantingRows).
  const plantingSources = new Set(config.zones.flatMap((zone) => (zone.scatter ?? [])
    .filter((rule) => PLANTING_PATTERNS.includes(rule.pattern)).map((rule) => `zone:${zone.id}/${rule.id}`)));
  const packed = packPlantingRows(rows, plantingSources);
  return {
    schema_version: STREET_DETAIL_SCHEMA,
    generator: "tools/lib/street-detail-generation.mjs",
    seed,
    coordinate_system: "+X east,+Y up,-Z north; meters; NAVD 88",
    conventions: {
      position_m: "[x, y, z]; y is the generated land elevation under x, z (terrain_support names the triangle)",
      surface: "the visible ground surface at x, z (generated feature kind and material, including the raised street ground); set an item on it at y + bias_m",
      yaw_radians: "rotation about +Y turning the asset's local -Z front; null when the source gives no direction",
      layers: "switchable runtime subtrees under PlayableWorld/StreetDetail; ground rows feed the always-on chunk surfaces",
      status: "placed rows are built when their layer is on; excluded rows keep their source id and the reason",
      prop: "the kit prop the runtime builds for a placed row, with prop_params: the street-furniture kit (game/scripts/world/street_furniture_kit.gd) for the furniture layer, the street-clutter kit (game/scripts/world/street_clutter_kit.gd) for the clutter layer, the street-vegetation kit (game/scripts/world/street_vegetation_kit.gd) for the vegetation layer; rows without one are data only",
      footprint_m: "the plan size {x_m, z_m} of a parked car or a long prop along its local X and Z; with its position and yaw it is the item's rectangle (the gameplay mask checks a stadium that holds it)",
      parked_car: "a parked car's prop_params: body, paint, finish, roof and rims, and its rest on the visible ground under its four tyres (settleParkedCar in tools/lib/street-clutter-generation.mjs): pitch raises the nose and roll the left side (radians), lift takes the car's origin from y + bias_m to that rest, twist is what the suspension takes up (metres: the front-left and rear-right wheels rise by it in the car frame, the other two drop by it)",
      planted: "a vegetation row's prop_params: the kit variant and uniform scale, and its rest on the visible ground (settlePlant in tools/lib/street-vegetation-generation.mjs): lift_m takes the foot from y + bias_m to the lowest visible surface round it, foot_spread_m is how much higher the rest of that ground lies (the trunk runs on below the foot); a tree whose foot reaches paving stands in a round mulch pit well_m across on the plane of that paving (well_lift_m its height over the foot at the trunk, well_slope its rise per metre along +X and +Z), which other items keep clear of",
      standing_prop: "a furniture set piece on legs (an Adirondack chair) carries its rest on the visible ground under its feet in prop_params (settleOnFeet in tools/lib/street-furniture-generation.mjs): pitch raises its front and roll its left side (radians, together at most 0.15 rad from upright), lift takes its origin from y + bias_m to that rest, and leg_drops_m, where the ground folds under it, lengthens (+) or shortens (-) each leg in the kit's order (front-left, front-right, back-left, back-right; metres, in 5 mm steps)",
      prop_feet: "per kit prop on legs, the flat bottom of each foot {x, z, half_x, half_z} in the prop's frame (front -Z, right +X) in the kit's leg order: the feet a standing prop settles on, which the kit's legs must stand on",
      source_position_m: "a stop sign's OSM node position, kept when the sign moves to the curb of its approach",
      fence: "fence rows: the kit type and why (type_basis), height and collision half thickness, the stretches cut open along points_m (openings, metres along the line, with what opens them) and the solid runs left (posts on the ground: points_m, terrain_supports, surface_bias_m); a fence row with a prop is built (game/scripts/world/street_fence_kit.gd)",
      fenced_approaches: "scored-building sides a built fence closes, which the building fit may skip (game/tests/shared/building_fit.gd)",
      planting_rows: "the rows of drifts and fill rules (park beds) in compact blocks, one per rule: the shared id prefix, kind and source id, the props, surfaces, land records and zone sets the rows index, and one array per row in fields order, its number in the block giving its id; readers expand them into the usual rows (unpackPlantingRows in tools/lib/street-planting-generation.mjs, its twin in game/scripts/world/generated_world_contract.gd), and counts count them",
    },
    layers: STREET_DETAIL_LAYERS,
    ground_layer: STREET_DETAIL_GROUND_LAYER,
    kinds: STREET_DETAIL_KINDS,
    prop_feet: STREET_FURNITURE_FEET,
    inputs: {
      osm_extract: { path: SOURCE_CONTRACT.proper_extract.path, sha256: SOURCE_CONTRACT.proper_extract.sha256 },
      zones: { path: STREET_DETAIL_INPUTS.zones, sha256: sha256File(resolve(projectRoot, STREET_DETAIL_INPUTS.zones)) },
      set_pieces: { path: STREET_DETAIL_INPUTS.set_pieces, sha256: sha256File(resolve(projectRoot, STREET_DETAIL_INPUTS.set_pieces)) },
      // Only the stairs are read; acceptance edits to the catalog do not change this output.
      stair_catalog: { path: STREET_DETAIL_INPUTS.stair_catalog, field: "units[].stairs", flights: stairFlights.length },
    },
    exclusions,
    exclusion_inputs: {
      spawn_xz: spawnXZ,
      spawn_yaw: spawn.yaw,
      spawn_forward_xz: hardShapes.find((shape) => shape.component === "spawn_forward").points,
      ferry_path_xz: QA_CORRIDORS.ferry_arrival_path,
      qa_route_xz: QA_CORRIDORS.normal_qa_route,
      whole_island_anchors_xz: QA_CORRIDORS.whole_island_qa_route.slice(1),
      stair_flights: stairFlights,
    },
    zones: zoneSummaries,
    fenced_approaches: config.fenced_approaches.entries,
    ground: ground.summary,
    counts: {
      total: rows.length,
      by_layer: countBy("layer", layerNames),
      placed_by_layer: placedBy("layer", layerNames),
      by_kind: countBy("kind", Object.keys(STREET_DETAIL_KINDS)),
      by_source: countBy("source", STREET_DETAIL_SOURCES),
      by_status: countBy("status", ["excluded", "placed"]),
      pilot_rows: rows.filter((row) => row.zones.some((zone) => pilotZones.has(zone))).length,
    },
    audit: {
      ...audit,
      furniture: furniture.audit,
      fences: fences.audit,
      clutter: clutter.audit,
      minimum_placed_clearances_m: Object.fromEntries(
        STREET_DETAIL_HARD_COMPONENTS.map((component) => [component, Number.isFinite(minimumClearances[component]) ? round3(minimumClearances[component]) : null]),
      ),
    },
    rows: packed.rows,
    planting_rows: packed.planting_rows,
  };
}
