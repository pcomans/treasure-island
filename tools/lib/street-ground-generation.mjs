// Street ground: the always-on kerbs, raised sidewalks, curb ramps, road markings
// and asphalt wear of the street-detail pilot zones, emitted as chunk mesh records.
//
// The inputs are the frozen OSM geometry the world generator already built (road
// ribbons, sidewalks, crossings, parking lots, buildings) and the "ground" blocks
// of tools/config/street-detail-zones.json. Every dimension is production
// inference for game art read from the dated pilot photos, not survey data.
//
// Plan geometry is east/north (the generator frame); records use world x, y, z
// with z = -north. Heights are given above the generated land: each emitted
// vertex sits at land(x, z) + h, where h is affine over the piece it belongs to,
// so a piece clipped to one land triangle stays planar.
//
// Records, one of each per chunk the pilot touches:
//   street-kerb   street_kerb          concrete sidewalk tops (road-aligned
//                                      panels), curb faces, curb ramps and paved
//                                      back slopes; solid
//   street-planting street_kerb        raised mulch planting strips; solid
//   street-plaza  street_kerb          banded plaza paving; solid
//   street-verge  street_kerb          grassed back slopes behind sidewalks; solid
//   street-ramp   street_kerb_support  invisible ramps in front of every curb
//                                      face, so the stock player (no step-up)
//                                      walks on and off a kerb; solid
//   street-parking street_paint        asphalt parking lanes beyond the frozen
//                                      road ribbon, up to the moved curb; visual only
//   street-gutter street_paint         concrete gutter pans; visual only
//   street-wear   street_paint         cracks, patches, stains, manholes, drains
//   street-marking street_paint        road paint, crosswalks, stop bars, stalls,
//                                      tactile pads; visual only
//   park-*        street_paint         a park zone's ground (ground.surfaces): mulch
//                                      and gravel beds, lawn, concrete, asphalt and
//                                      decomposed-granite paths, painted plazas,
//                                      draped flat over the land; visual only

import { createHash } from "node:crypto";
import earcut from "earcut";
import polygonClipping from "polygon-clipping";

import { projectLonLat } from "./coordinates.mjs";
import { meshRecord } from "./mesh-output.mjs";
import { lineRibbon, pointInRing, rawWayLine } from "./osm-geometry.mjs";
import {
  CHUNK_SIZE_M,
  ROAD_SURFACE_BIASES_M,
  ROAD_WIDTHS_M,
  chunkId,
  compareChunkIds,
  compareSourceKeys,
  invariant,
  roundCoordinate,
} from "./world-contract.mjs";

export const STREET_GROUND_FEATURE_KINDS = Object.freeze(["street_kerb", "street_kerb_support", "street_paint"]);
// Record kinds in emission order: [object key prefix, feature kind, material, collision, opaque].
// Park surfaces (a zone's ground.surfaces): material key -> record key prefix.
export const PARK_SURFACE_MATERIALS = Object.freeze({
  park_asphalt: "park-asphalt",
  park_concrete: "park-concrete",
  park_dg: "park-dg",
  park_gravel: "park-gravel",
  park_lawn: "park-lawn",
  park_mulch: "park-mulch",
  park_paint_pink: "park-paint-pink",
  park_plaza_lens: "park-plaza-lens",
  park_plaza_zigzag: "park-plaza-zigzag",
});
const RECORD_KINDS = Object.freeze({
  ...Object.fromEntries(Object.entries(PARK_SURFACE_MATERIALS).map(([material, prefix]) => [material, [prefix, "street_paint", material, "none", false]])),
  kerb: ["street-kerb", "street_kerb", "street_kerb_concrete", "world_solid", true],
  planting: ["street-planting", "street_kerb", "street_kerb_planting", "world_solid", true],
  plaza: ["street-plaza", "street_kerb", "street_plaza_pavers", "world_solid", true],
  verge: ["street-verge", "street_kerb", "street_kerb_verge", "world_solid", true],
  ramp: ["street-ramp", "street_kerb_support", "street_kerb_support", "world_solid", false],
  parking: ["street-parking", "street_paint", "street_parking", "none", false],
  gutter: ["street-gutter", "street_paint", "street_gutter", "none", false],
  wear: ["street-wear", "street_paint", "street_wear", "none", false],
  marking: ["street-marking", "street_paint", "street_marking", "none", false],
});
// Paint kinds (street-marking UV.x integer part) and wear atlas cells
// (street-wear UV.x integer part); the shader reads the same numbers.
export const STREET_PAINT_KINDS = Object.freeze({ white: 0, yellow: 1, red: 2, green: 3, tactile: 4, stop_legend: 5, yellow_faded: 6 });
export const STREET_WEAR_CELLS = Object.freeze({ crack_a: 0, crack_b: 1, oil_a: 2, oil_b: 3, patch: 4, manhole: 5, drain: 6 });
// The deepest any street-ground vertex may sit above the land under it (m);
// validators reuse it.
export const STREET_GROUND_MAXIMUM_HEIGHT_M = 0.3;
export const STREET_GROUND_MINIMUM_HEIGHT_M = -0.02;

const ROAD_TOP_M = ROAD_SURFACE_BIASES_M.base;
const SKIRT_FOOT_M = -0.01;
const MINIMUM_TRIANGLE_AREA_M2 = 1e-6;
const EDGE_MERGE_M = 0.01;
// Parking strips start this far inside the frozen carriageway (and are then cut
// back to it), so where a ribbon bends their inner edge leaves no gap.
const CARRIAGEWAY_OVERLAP_M = 0.5;
// Plaza paving (tapered strip ends) and parking-lot tips narrower than twice
// these are dropped.
const PLAZA_OPENING_M = 1.5;
const LOT_OPENING_M = 1.5;
// boundaryBand merges ring vertices closer than this.
const BAND_VERTEX_MERGE_M = 0.05;
// Concrete kept beyond the top of a curb ramp before any mulch bed.
const RAMP_LANDING_M = 1.5;
// Road classes in order of which owns the sidewalk panel frame where reaches overlap.
const FRAME_ROAD_RANK = Object.freeze(["trunk", "primary", "secondary", "tertiary", "unclassified", "residential", "service"]);
const SAFE_ID = /^[a-z0-9_]+$/u;

const GROUND_SCHEMA = Object.freeze({
  kerb: ["back_slope_run_m", "building_clearance_m", "closing_m", "flare_run_m", "gutter_width_m", "minimum_width_m", "panel_m", "planting_gap_m", "reveal_m", "sidewalk_reach_m", "sidewalk_width_m", "support_run_m"],
  crossings: ["bar_gap_m", "bar_width_m", "ramp_depth_m", "ramp_width_m", "tactile_depth_m", "walk_width_m"],
  lines: ["bike_lane_width_m", "bus_lane_width_m", "conflict_length_m", "dash_gap_m", "dash_m", "double_gap_m", "edge_inset_m", "stall_length_m", "stall_spacing_m", "stop_bar_width_m", "stop_legend_gap_m", "stop_legend_length_m", "width_m"],
  lifts: ["gutter_m", "paint_m"],
});
const ZONE_GROUND_FIELDS = ["centerlines", "kerbs", "lane_markings", "parking_lanes", "parking_stalls", "planting", "planting_behind_walk", "plazas", "wear"];
const PARKING_LANE_FIELDS = ["reason", "source_keys", "width_m"];
const BEHIND_WALK_FIELDS = ["reason", "source_keys"];
const CENTERLINE_STYLES = Object.freeze(["double_yellow", "dashed_faded"]);
const PLANTING_MODES = Object.freeze(["none", "curb_strip"]);
const PLAZA_FIELDS = ["depth_m", "paver_tile_m", "reason", "side_point_xz", "source_keys", "walk_m"];
const WEAR_FIELDS = ["crack_per_100m2", "drain_spacing_m", "manhole_spacing_m", "oil_per_100m2", "patch_per_100m2"];
const SURFACE_LAYER_FIELDS = ["evidence", "id", "material", "reason", "shape"];
// Cut a path's surface into cells this size so its panel frame follows its bends.
const PATH_FRAME_CELL_M = 8;
// Park path markings (a layer's markings): line width, the edge lines' inset
// from the path edge, the centre line's dash and gap, and their lift over the path.
const PARK_LINE_WIDTH_M = 0.1;
const PARK_EDGE_LINE_INSET_M = 0.25;
const PARK_DASH_M = 3;
const PARK_PAINT_LIFT_M = 0.006;

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

function exactKeys(value, keys, label) {
  invariant(value != null && typeof value === "object" && !Array.isArray(value), `${label} must be an object`);
  invariant(JSON.stringify(Object.keys(value).sort()) === JSON.stringify([...keys].sort()), `${label} must define exactly ${[...keys].sort().join(", ")}`);
}

// A park zone's ground: its OSM source, the lift above the land and the layers,
// each a material over a shape; later layers replace earlier ones where they
// overlap, so the zone ends up one partition of flat-lying ground.
//   shape {zone: true}                    the zone itself
//   shape {points_xz: [...]}              a traced polygon
//   shape {line_xz: [...], width_m}       a ribbon along a traced line
//   shape {way: "w...", width_m, offset_m} a ribbon along an OSM way, moved
//                                         offset_m to its left
//   shape {osm_paths: true}               the zone's OSM footway and cycleway ribbons
// Any shape may add minus_sources: OSM areas cut out of it (a breakwater). A
// layer may add frame {origin_xz, axis_xz}: plaza paint is laid out in metres
// along axis_xz from origin_xz. A way or line layer may add markings {edges,
// centre}: painted edge lines and a dashed centre line along it (STREET_PAINT_KINDS
// names, or null for none), as on a two-way cycle track.
function validateParkSurfaces(surfaces, label) {
  exactKeys(surfaces, ["layers", "lift_m", "source_keys"], label);
  invariant(isFiniteNumber(surfaces.lift_m) && surfaces.lift_m > ROAD_SURFACE_BIASES_M.pedestrian && surfaces.lift_m < STREET_GROUND_MAXIMUM_HEIGHT_M, `${label} lift_m must lie above the pedestrian path skin and inside the street-ground band`);
  invariant(Array.isArray(surfaces.source_keys) && surfaces.source_keys.length > 0 && surfaces.source_keys.every((key) => /^[wr]\d+$/u.test(key)), `${label} needs OSM source_keys`);
  invariant(Array.isArray(surfaces.layers) && surfaces.layers.length > 0, `${label} needs layers`);
  const ids = new Set();
  for (const layer of surfaces.layers) {
    const layerLabel = `${label} layer ${layer?.id}`;
    exactKeys(layer, [...SURFACE_LAYER_FIELDS, ...["frame", "markings"].filter((field) => field in (layer ?? {}))], layerLabel);
    invariant(typeof layer.id === "string" && SAFE_ID.test(layer.id) && !ids.has(layer.id), `${layerLabel} needs a unique lower_snake id`);
    ids.add(layer.id);
    invariant(PARK_SURFACE_MATERIALS[layer.material] !== undefined, `${layerLabel} material must be one of ${Object.keys(PARK_SURFACE_MATERIALS).join(", ")}`);
    for (const field of ["reason", "evidence"]) invariant(typeof layer[field] === "string" && layer[field].trim() !== "", `${layerLabel} needs ${field}`);
    const shape = layer.shape;
    invariant(shape != null && typeof shape === "object", `${layerLabel} needs a shape`);
    const minus = "minus_sources" in shape ? ["minus_sources"] : [];
    if (minus.length > 0) invariant(Array.isArray(shape.minus_sources) && shape.minus_sources.every((key) => /^[wr]\d+$/u.test(key)), `${layerLabel} minus_sources must be OSM area keys`);
    const isXZ = (point) => Array.isArray(point) && point.length === 2 && point.every(isFiniteNumber);
    if (shape.zone === true) exactKeys(shape, ["zone", ...minus], `${layerLabel} zone shape`);
    else if (shape.osm_paths === true) exactKeys(shape, ["osm_paths", ...minus], `${layerLabel} osm_paths shape`);
    else if (shape.points_xz) {
      exactKeys(shape, ["points_xz", ...minus], `${layerLabel} polygon shape`);
      invariant(shape.points_xz.length >= 3 && shape.points_xz.every(isXZ), `${layerLabel} polygon needs 3+ [x, z] points`);
    } else if (shape.line_xz) {
      exactKeys(shape, ["line_xz", "width_m", ...minus], `${layerLabel} line shape`);
      invariant(shape.line_xz.length >= 2 && shape.line_xz.every(isXZ) && isFiniteNumber(shape.width_m) && shape.width_m > 0, `${layerLabel} line needs 2+ [x, z] points and a positive width_m`);
    } else if (shape.way) {
      exactKeys(shape, ["offset_m", "way", "width_m", ...minus], `${layerLabel} way shape`);
      invariant(/^w\d+$/u.test(shape.way) && isFiniteNumber(shape.width_m) && shape.width_m > 0 && isFiniteNumber(shape.offset_m), `${layerLabel} way shape needs an OSM way, a positive width_m and offset_m`);
    } else {
      throw new Error(`${layerLabel} shape must be zone, osm_paths, points_xz, line_xz or way`);
    }
    if (layer.frame !== undefined) {
      exactKeys(layer.frame, ["axis_xz", "origin_xz"], `${layerLabel} frame`);
      invariant(isXZ(layer.frame.origin_xz) && isXZ(layer.frame.axis_xz) && Math.hypot(...layer.frame.axis_xz) > 1e-6, `${layerLabel} frame needs origin_xz and a non-zero axis_xz`);
    }
    invariant(!layer.material.startsWith("park_plaza_") || layer.frame !== undefined, `${layerLabel}: painted plazas need a frame`);
    if (layer.markings !== undefined) {
      exactKeys(layer.markings, ["centre", "edges"], `${layerLabel} markings`);
      invariant((shape.way || shape.line_xz) && ["centre", "edges"].every((field) => layer.markings[field] === null || STREET_PAINT_KINDS[layer.markings[field]] !== undefined), `${layerLabel} markings go on a way or line layer and name paint kinds (or null)`);
    }
  }
}

// The validated "ground" settings: config.ground plus each pilot zone's ground block.
export function streetGroundSettings(config) {
  const ground = config.ground;
  invariant(ground != null, "Street detail config needs a ground block");
  exactKeys(ground, ["crossings", "kerb", "lifts", "lines", "notes"], "Street ground config");
  invariant(Array.isArray(ground.notes) && ground.notes.every((note) => typeof note === "string"), "Street ground notes must be strings");
  for (const [section, keys] of Object.entries(GROUND_SCHEMA)) {
    exactKeys(ground[section], keys, `Street ground ${section}`);
    for (const key of keys) {
      invariant(isFiniteNumber(ground[section][key]) && ground[section][key] >= 0, `Street ground ${section}.${key} must be a non-negative number`);
    }
  }
  const { kerb, crossings, lines, lifts } = ground;
  invariant(kerb.reveal_m > 0 && kerb.reveal_m < STREET_GROUND_MAXIMUM_HEIGHT_M - ROAD_TOP_M, "Kerb reveal must keep the sidewalk below the height bound");
  // A collision ramp steeper than 40 degrees would turn into a wall for the stock
  // controller (floor_max_angle 48 degrees); keep a margin.
  const top = ROAD_TOP_M + kerb.reveal_m;
  for (const key of ["support_run_m", "back_slope_run_m", "flare_run_m"]) {
    invariant(kerb[key] > 0 && Math.atan2(top - SKIRT_FOOT_M, kerb[key]) <= (40 * Math.PI) / 180, `Kerb ${key} makes a slope steeper than 40 degrees`);
  }
  invariant(crossings.ramp_depth_m > 0 && Math.atan2(kerb.reveal_m, crossings.ramp_depth_m) <= (15 * Math.PI) / 180, "Curb ramps must stay gentler than 15 degrees");
  invariant(crossings.ramp_width_m > 2 * kerb.flare_run_m, "Curb ramps must be wider than their two flares");
  invariant(lifts.paint_m > lifts.gutter_m && lifts.gutter_m > 0, "Paint must sit above the gutter, which sits above the road");
  invariant(lines.width_m > 0 && lines.stall_spacing_m > lines.width_m && crossings.bar_width_m > 0, "Line widths must be positive");
  invariant(lines.dash_m > 0 && lines.dash_gap_m > 0 && kerb.panel_m > 0 && kerb.closing_m >= 0, "Dashes, panels and gap closing need positive sizes");
  const zones = [];
  for (const zone of config.zones) {
    if (!zone.pilot || zone.ground == null) continue;
    exactKeys(zone.ground, "surfaces" in zone.ground ? [...ZONE_GROUND_FIELDS, "surfaces"] : ZONE_GROUND_FIELDS, `Street ground zone ${zone.id}`);
    const settings = zone.ground;
    if (settings.surfaces !== undefined) validateParkSurfaces(settings.surfaces, `Street ground zone ${zone.id} surfaces`);
    for (const key of ["kerbs", "lane_markings", "parking_stalls"]) {
      invariant(typeof settings[key] === "boolean", `Street ground zone ${zone.id} ${key} must be boolean`);
    }
    invariant(
      settings.centerlines != null && typeof settings.centerlines === "object" && !Array.isArray(settings.centerlines) &&
        Object.entries(settings.centerlines).every(([highway, style]) => ROAD_WIDTHS_M[highway] != null && CENTERLINE_STYLES.includes(style)),
      `Street ground zone ${zone.id} centerlines must map highway classes to ${CENTERLINE_STYLES.join(" or ")}`,
    );
    invariant(PLANTING_MODES.includes(settings.planting), `Street ground zone ${zone.id} planting must be ${PLANTING_MODES.join(" or ")}`);
    invariant(Array.isArray(settings.plazas), `Street ground zone ${zone.id} plazas must be a list`);
    invariant(Array.isArray(settings.parking_lanes), `Street ground zone ${zone.id} parking_lanes must be a list`);
    invariant(Array.isArray(settings.planting_behind_walk), `Street ground zone ${zone.id} planting_behind_walk must be a list`);
    for (const entry of settings.planting_behind_walk) {
      exactKeys(entry, BEHIND_WALK_FIELDS, `Street ground zone ${zone.id} planting_behind_walk entry`);
      invariant(settings.planting === "curb_strip", `Street ground zone ${zone.id} planting_behind_walk needs planting curb_strip`);
      invariant(Array.isArray(entry.source_keys) && entry.source_keys.length > 0 && entry.source_keys.every((key) => /^w\d+$/u.test(key)), `Street ground zone ${zone.id} planting_behind_walk needs OSM sidewalk source_keys`);
      invariant(typeof entry.reason === "string" && entry.reason.trim() !== "", `Street ground zone ${zone.id} planting_behind_walk needs a reason`);
    }
    for (const lane of settings.parking_lanes) {
      exactKeys(lane, PARKING_LANE_FIELDS, `Street ground zone ${zone.id} parking lane`);
      invariant(Array.isArray(lane.source_keys) && lane.source_keys.length > 0 && lane.source_keys.every((key) => /^w\d+$/u.test(key)), `Street ground zone ${zone.id} parking lane needs OSM way source_keys`);
      invariant(isFiniteNumber(lane.width_m) && lane.width_m > 0 && lane.width_m <= 3.5, `Street ground zone ${zone.id} parking lane width must be in (0, 3.5] m`);
      invariant(typeof lane.reason === "string" && lane.reason.trim() !== "", `Street ground zone ${zone.id} parking lane needs a reason`);
    }
    for (const plaza of settings.plazas) {
      exactKeys(plaza, PLAZA_FIELDS, `Street ground zone ${zone.id} plaza`);
      invariant(Array.isArray(plaza.source_keys) && plaza.source_keys.length > 0 && plaza.source_keys.every((key) => /^w\d+$/u.test(key)), `Street ground zone ${zone.id} plaza needs OSM way source_keys`);
      invariant(Array.isArray(plaza.side_point_xz) && plaza.side_point_xz.length === 2 && plaza.side_point_xz.every(isFiniteNumber), `Street ground zone ${zone.id} plaza needs side_point_xz`);
      invariant(isFiniteNumber(plaza.walk_m) && isFiniteNumber(plaza.depth_m) && plaza.walk_m > 0 && plaza.depth_m > plaza.walk_m && isFiniteNumber(plaza.paver_tile_m) && plaza.paver_tile_m > 0, `Street ground zone ${zone.id} plaza needs walk_m < depth_m and a paver_tile_m`);
      invariant(typeof plaza.reason === "string" && plaza.reason.trim() !== "", `Street ground zone ${zone.id} plaza needs a reason`);
    }
    exactKeys(settings.wear, WEAR_FIELDS, `Street ground zone ${zone.id} wear`);
    for (const key of WEAR_FIELDS) {
      invariant(isFiniteNumber(settings.wear[key]) && settings.wear[key] >= 0, `Street ground zone ${zone.id} wear.${key} must be non-negative`);
    }
    invariant(SAFE_ID.test(zone.id), `Street ground zone id ${zone.id} is unsafe`);
    zones.push({ id: zone.id, zone, settings });
  }
  invariant(zones.length > 0, "No pilot zone has a ground block");
  return { ...ground, top_m: top, zones };
}

// ---------------------------------------------------------------- geometry

function hashUnit(seed, identity, slot = 0) {
  return createHash("sha256").update(`${seed}|${identity}`, "utf8").digest().readUInt32BE(slot * 4) / 0xffffffff;
}

function sub(a, b) {
  return [a[0] - b[0], a[1] - b[1]];
}

function add(a, b) {
  return [a[0] + b[0], a[1] + b[1]];
}

function scale(a, s) {
  return [a[0] * s, a[1] * s];
}

function dot(a, b) {
  return a[0] * b[0] + a[1] * b[1];
}

function cross(a, b) {
  return a[0] * b[1] - a[1] * b[0];
}

function length(a) {
  return Math.hypot(a[0], a[1]);
}

function unit(a) {
  const l = length(a);
  invariant(l > 1e-12, "Cannot normalize a zero vector");
  return [a[0] / l, a[1] / l];
}

// Left normal of a direction in the east/north frame.
function leftOf(direction) {
  return [-direction[1], direction[0]];
}

function emptyBox() {
  return { min_x: Infinity, min_y: Infinity, max_x: -Infinity, max_y: -Infinity };
}

function growBox(box, point) {
  box.min_x = Math.min(box.min_x, point[0]);
  box.min_y = Math.min(box.min_y, point[1]);
  box.max_x = Math.max(box.max_x, point[0]);
  box.max_y = Math.max(box.max_y, point[1]);
  return box;
}

function boxOfPoints(points) {
  return points.reduce(growBox, emptyBox());
}

function boxOfMulti(multi) {
  const box = emptyBox();
  for (const polygon of multi) for (const point of polygon[0]) growBox(box, point);
  return box;
}

function boxesOverlap(left, right, margin = 0) {
  return left.min_x <= right.max_x + margin && right.min_x <= left.max_x + margin &&
    left.min_y <= right.max_y + margin && right.min_y <= left.max_y + margin;
}

function inBox(box, point, margin = 0) {
  return point[0] >= box.min_x - margin && point[0] <= box.max_x + margin && point[1] >= box.min_y - margin && point[1] <= box.max_y + margin;
}

function openRing(ring) {
  const points = ring.length > 1 && ring[0][0] === ring.at(-1)[0] && ring[0][1] === ring.at(-1)[1] ? ring.slice(0, -1) : ring.slice();
  const merged = [];
  for (const point of points) {
    if (merged.length === 0 || length(sub(point, merged.at(-1))) > EDGE_MERGE_M) merged.push(point);
  }
  while (merged.length > 2 && length(sub(merged[0], merged.at(-1))) <= EDGE_MERGE_M) merged.pop();
  return merged;
}

function ringArea(ring) {
  let doubled = 0;
  for (let index = 0; index < ring.length; index += 1) doubled += cross(ring[index], ring[(index + 1) % ring.length]);
  return doubled / 2;
}

function multiArea(multi) {
  let total = 0;
  for (const polygon of multi) {
    polygon.forEach((ring, index) => {
      total += (index === 0 ? 1 : -1) * Math.abs(ringArea(openRing(ring)));
    });
  }
  return total;
}

function multiPerimeter(multi) {
  let total = 0;
  for (const polygon of multi) {
    for (const raw of polygon) {
      const ring = openRing(raw);
      for (let index = 0; index < ring.length; index += 1) total += length(sub(ring[(index + 1) % ring.length], ring[index]));
    }
  }
  return total;
}

function pointInPolygon(point, polygon) {
  if (!pointInRing(point, openRing(polygon[0]), true)) return false;
  return !polygon.slice(1).some((hole) => pointInRing(point, openRing(hole), false));
}

// pointInPolygon on rings already opened.
function pointInOpenRings(point, rings) {
  if (!pointInRing(point, rings[0], true)) return false;
  return !rings.slice(1).some((hole) => pointInRing(point, hole, false));
}

function rectangle(origin, along, across, alongMin, alongMax, acrossMin, acrossMax) {
  const corner = (s, t) => add(origin, add(scale(along, s), scale(across, t)));
  const ring = [corner(alongMin, acrossMin), corner(alongMax, acrossMin), corner(alongMax, acrossMax), corner(alongMin, acrossMax)];
  return [[ringArea(ring) > 0 ? ring : ring.reverse()]];
}

function circle(center, radius, sides = 12) {
  const ring = [];
  for (let index = 0; index < sides; index += 1) {
    const angle = (index * 2 * Math.PI) / sides;
    ring.push([center[0] + Math.cos(angle) * radius, center[1] + Math.sin(angle) * radius]);
  }
  return [[ring]];
}

function convexHull(points) {
  const sorted = [...points].sort((left, right) => left[0] - right[0] || left[1] - right[1]);
  const half = (list) => {
    const hull = [];
    for (const point of list) {
      while (hull.length >= 2 && cross(sub(hull.at(-1), hull.at(-2)), sub(point, hull.at(-2))) <= 1e-12) hull.pop();
      hull.push(point);
    }
    return hull;
  };
  const lower = half(sorted);
  const upper = half([...sorted].reverse());
  return [...lower.slice(0, -1), ...upper.slice(0, -1)];
}

// Boolean operations on raw polygon-clipping multipolygons. A failure names the
// step: the output is deterministic, so a throw is a real geometry problem.
function guarded(label, operation) {
  try {
    return operation();
  } catch (error) {
    throw new Error(`Street ground ${label} boolean failed: ${error.message}`, { cause: error });
  }
}

function union(label, parts) {
  let queue = parts.filter((part) => part.length > 0);
  if (queue.length === 0) return [];
  while (queue.length > 1) {
    const next = [];
    for (let index = 0; index < queue.length; index += 2) {
      next.push(index + 1 < queue.length ? guarded(label, () => polygonClipping.union(queue[index], queue[index + 1])) : queue[index]);
    }
    queue = next;
  }
  return guarded(label, () => polygonClipping.union(queue[0]));
}

function intersect(label, left, right) {
  if (left.length === 0 || right.length === 0) return [];
  return guarded(label, () => polygonClipping.intersection(left, right));
}

function difference(label, subject, clips) {
  const nonEmpty = clips.filter((clip) => clip.length > 0);
  if (subject.length === 0 || nonEmpty.length === 0) return subject;
  return guarded(label, () => polygonClipping.difference(subject, ...nonEmpty));
}

// Individual polygons with bounds, so local operations only touch nearby parts.
function polygonIndex(multi) {
  const items = multi.map((polygon) => ({ polygon, box: boxOfPoints(polygon[0]), rings: null }));
  return {
    multi,
    near(box, margin = 0) {
      return items.filter((item) => boxesOverlap(item.box, box, margin)).map((item) => item.polygon);
    },
    contains(point) {
      return items.some((item) => inBox(item.box, point) && pointInOpenRings(point, item.rings ??= item.polygon.map(openRing)));
    },
  };
}

// Drops slivers: parts smaller than minimumArea or thinner than minimumWidth
// (mean width 2 * area / perimeter). Fills holes smaller than holeArea or
// thinner than holeWidth, so no ragged land sliver is left inside a sidewalk.
function cleanPolygons(multi, minimumArea, minimumWidth, holeArea = minimumArea, holeWidth = 0) {
  const kept = [];
  for (const polygon of multi) {
    const outer = polygon[0];
    const holes = polygon.slice(1).filter((hole) => {
      const ring = openRing(hole);
      const area = Math.abs(ringArea(ring));
      return area >= holeArea && (2 * area) / multiPerimeter([[hole]]) >= holeWidth;
    });
    const candidate = [outer, ...holes];
    const area = multiArea([candidate]);
    if (area < minimumArea) continue;
    if ((2 * area) / multiPerimeter([candidate]) < minimumWidth) continue;
    kept.push(candidate);
  }
  return kept;
}

// Offsets a polyline sideways by distance (positive = left), with mitred joins.
function offsetPolyline(points, distance) {
  const result = [];
  for (let index = 0; index < points.length; index += 1) {
    const before = index > 0 ? unit(sub(points[index], points[index - 1])) : null;
    const after = index < points.length - 1 ? unit(sub(points[index + 1], points[index])) : null;
    const normals = [before, after].filter(Boolean).map(leftOf);
    let miter = normals.length === 1 ? normals[0] : add(normals[0], normals[1]);
    if (length(miter) < 1e-9) miter = normals[0];
    miter = unit(miter);
    const cosine = Math.max(0.35, dot(miter, normals[0]));
    result.push(add(points[index], scale(miter, distance / cosine)));
  }
  return result;
}

// Raw band of a given half-width around every ring edge: segment rectangles and
// vertex discs, unioned without the strict canonical-ring checks (touching
// output is fine here). Vertices closer than a few centimetres are merged first:
// the band is a coarse morphological tool, and millimetre edges only give the
// boolean sweep near-degenerate input.
function boundaryBand(label, shape, radius) {
  const parts = [];
  for (const polygon of shape) {
    for (const raw of polygon) {
      const ring = [];
      for (const point of openRing(raw)) {
        if (ring.length === 0 || length(sub(point, ring.at(-1))) >= BAND_VERTEX_MERGE_M) ring.push(point);
      }
      while (ring.length > 1 && length(sub(ring.at(-1), ring[0])) < BAND_VERTEX_MERGE_M) ring.pop();
      ring.forEach((point, index) => {
        const next = ring[(index + 1) % ring.length];
        const edge = sub(next, point);
        if (length(edge) > 1e-6) {
          const normal = scale(leftOf(unit(edge)), radius);
          parts.push([[[add(point, normal), sub(point, normal), sub(next, normal), add(next, normal)]]]);
        }
        parts.push(circle(point, radius, 8));
      });
    }
  }
  // On a 1/1024 m lattice, nearly coincident corners of neighbouring parts coincide exactly.
  const snap = (value) => Math.round(value * 1024) / 1024;
  return union(label, parts.map((part) => part.map((polygon) => polygon.map((ring) => ring.map(([x, y]) => [snap(x), snap(y)])))));
}

// Morphological closing: fills gaps and notches narrower than 2 * radius
// between raised pieces (dilate, then erode by the same radius).
function closeGaps(label, multi, radius) {
  if (radius <= 0 || multi.length === 0) return multi;
  const dilated = union(`${label} dilate`, [multi, boundaryBand(`${label} outline`, multi, radius)]);
  return difference(`${label} erode`, dilated, [boundaryBand(`${label} dilated outline`, dilated, radius)]);
}

// Morphological opening: drops spikes and slivers narrower than twice the radius.
function openShapes(label, multi, radius) {
  if (radius <= 0 || multi.length === 0) return multi;
  const eroded = difference(`${label} erode`, multi, [boundaryBand(`${label} outline`, multi, radius)]);
  if (eroded.length === 0) return eroded;
  return union(`${label} dilate`, [eroded, boundaryBand(`${label} eroded outline`, eroded, radius)]);
}

// Squares of a fixed plan grid covering a box, for splitting large surfaces.
function gridCells(box, size) {
  const cells = [];
  for (let x = Math.floor(box.min_x / size) * size; x < box.max_x; x += size) {
    for (let y = Math.floor(box.min_y / size) * size; y < box.max_y; y += size) {
      cells.push([[[[x, y], [x + size, y], [x + size, y + size], [x, y + size]]]]);
    }
  }
  return cells;
}

// The strip between two sideways offsets of a polyline, as unioned quads.
function strip(label, points, from, to) {
  const near = offsetPolyline(points, from);
  const far = offsetPolyline(points, to);
  const quads = [];
  for (let index = 1; index < points.length; index += 1) {
    const ring = [near[index - 1], near[index], far[index], far[index - 1]];
    if (Math.abs(ringArea(ring)) < 1e-6) continue;
    quads.push([[ringArea(ring) > 0 ? ring : ring.reverse()]]);
  }
  return union(label, quads);
}

// Dashes along a polyline at an offset to its left: dash metres painted, then as
// many left bare, each dash a straight quad between its ends.
function dashedStrip(label, points, offset, width, dash) {
  const quads = [];
  const total = polylineLength(points);
  for (let start = dash / 2; start + dash <= total; start += dash * 2) {
    const ends = [pointAlong(points, start), pointAlong(points, start + dash)];
    const corners = ends.flatMap(({ point, tangent }) => {
      const left = [-tangent[1], tangent[0]];
      return [add(point, scale(left, offset - width / 2)), add(point, scale(left, offset + width / 2))];
    });
    const ring = [corners[0], corners[2], corners[3], corners[1]];
    if (Math.abs(ringArea(ring)) < 1e-6) continue;
    quads.push([[ringArea(ring) > 0 ? ring : ring.reverse()]]);
  }
  return union(label, quads);
}

function polylineLength(points) {
  let total = 0;
  for (let index = 1; index < points.length; index += 1) total += length(sub(points[index], points[index - 1]));
  return total;
}

// Point and unit tangent at distance s along a polyline.
function pointAlong(points, s) {
  let walked = 0;
  for (let index = 1; index < points.length; index += 1) {
    const segment = length(sub(points[index], points[index - 1]));
    if (walked + segment >= s || index === points.length - 1) {
      const fraction = segment > 0 ? Math.max(0, Math.min(1, (s - walked) / segment)) : 0;
      const tangent = unit(sub(points[index], points[index - 1]));
      return { point: add(points[index - 1], scale(sub(points[index], points[index - 1]), fraction)), tangent };
    }
    walked += segment;
  }
  throw new Error("pointAlong on an empty polyline");
}

// Closest point on a polyline: {point, distance, along, tangent}.
function closestOnPolyline(points, point) {
  let best = null;
  let walked = 0;
  for (let index = 1; index < points.length; index += 1) {
    const start = points[index - 1];
    const delta = sub(points[index], start);
    const segment = length(delta);
    if (segment <= 1e-9) continue;
    const fraction = Math.max(0, Math.min(1, dot(sub(point, start), delta) / (segment * segment)));
    const closest = add(start, scale(delta, fraction));
    const distance = length(sub(point, closest));
    if (!best || distance < best.distance) best = { point: closest, distance, along: walked + fraction * segment, tangent: scale(delta, 1 / segment) };
    walked += segment;
  }
  return best;
}

// Parameters (fractions of start->end) where a segment crosses polygon edges.
function segmentPolygonCrossings(start, end, polygons) {
  const fractions = [];
  const delta = sub(end, start);
  for (const polygon of polygons) {
    for (const raw of polygon) {
      const ring = openRing(raw);
      for (let index = 0; index < ring.length; index += 1) {
        const a = ring[index];
        const b = ring[(index + 1) % ring.length];
        const edge = sub(b, a);
        const denominator = cross(delta, edge);
        if (Math.abs(denominator) < 1e-12) continue;
        const t = cross(sub(a, start), edge) / denominator;
        const u = cross(sub(a, start), delta) / denominator;
        if (t > 0 && t < 1 && u >= 0 && u <= 1) fractions.push(t);
      }
    }
  }
  return fractions.sort((left, right) => left - right);
}

// ---------------------------------------------------------------- pieces
// A piece is a plan polygon with an affine height above land and a UV rule.

function affineHeight(points, heights) {
  // Plane h = h0 + he * e + hn * n through three points.
  const [a, b, c] = points;
  const ab = sub(b, a);
  const ac = sub(c, a);
  const determinant = cross(ab, ac);
  invariant(Math.abs(determinant) > 1e-12, "Affine height needs a non-degenerate triangle");
  const dhb = heights[1] - heights[0];
  const dhc = heights[2] - heights[0];
  const he = (dhb * ac[1] - dhc * ab[1]) / determinant;
  const hn = (dhc * ab[0] - dhb * ac[0]) / determinant;
  return { h0: heights[0] - he * a[0] - hn * a[1], he, hn };
}

function constantHeight(value) {
  return { h0: value, he: 0, hn: 0 };
}

function heightAt(height, point) {
  return height.h0 + height.he * point[0] + height.hn * point[1];
}

function worldUv(point) {
  return [point[0] / 10, -point[1] / 10];
}

// World-planar UV in tiles of the given size (for direction-free textures).
function tiledUv(size) {
  return (point) => [point[0] / size, -point[1] / size];
}

// UV in tiles of the given size, in a frame running along a road: u along its
// centre line, v across it. Joints and paver bands follow the street.
function roadFrameUv(line, reference, size) {
  const near = closestOnPolyline(line, reference);
  return (point) => {
    const offset = sub(point, near.point);
    return [(near.along + dot(offset, near.tangent)) / size, cross(near.tangent, offset) / size];
  };
}

// UV for a paint kind with no texture placement (the shader tiles in world space).
function kindUv(kind) {
  return () => [kind + 0.5, 0.5];
}

// UV for a placed glyph or decal: integer part of u picks the cell, the fraction
// and v are the local coordinates over the decal's frame.
function frameUv(cell, origin, alongAxis, acrossAxis, alongSize, acrossSize) {
  return (point) => {
    const local = sub(point, origin);
    const u = Math.max(0.001, Math.min(0.999, dot(local, acrossAxis) / acrossSize + 0.5));
    const v = Math.max(0, Math.min(1, 1 - (dot(local, alongAxis) / alongSize + 0.5)));
    return [cell + u, v];
  };
}

// ---------------------------------------------------------------- main

export function generateStreetGround({
  config,
  playableObjects,
  rawOsm,
  properSources,
  facetsForChunk,
  facetElevation,
  spawnXZ,
  hardShapes,
  // The land's smooth shading normal at a plan point, or null (terrain overrides):
  // park surfaces over re-meshed land shade with it rather than per land triangle.
  normalAt = null,
}) {
  const settings = streetGroundSettings(config);
  const { kerb, crossings, lines, lifts } = settings;
  const top = settings.top_m;
  const seed = config.seed;
  const objects = [...playableObjects.values()].sort((left, right) => compareSourceKeys(left.row.source_key, right.row.source_key));

  // Zone regions in the east/north frame.
  const zoneRegions = settings.zones.map(({ id, zone, settings: zoneSettings }) => {
    let region;
    if (zone.shape.type === "polygon") {
      const ring = zone.shape.points_xz.map(([x, z]) => [x, -z]);
      region = union(`zone ${id}`, [[[ringArea(ring) > 0 ? ring : ring.reverse()]]]);
    } else {
      region = union(`zone ${id}`, zone.shape.source_keys.map((key) =>
        lineRibbon(rawWayLine(rawOsm, key.slice(1)), zone.shape.half_width_m * 2, `zone ${id} ${key}`)));
    }
    return { id, settings: zoneSettings, region, index: polygonIndex(region), box: boxOfMulti(region) };
  });
  const pilot = union("pilot region", zoneRegions.map((zone) => zone.region));
  const pilotBox = boxOfMulti(pilot);
  const kerbRegion = union("kerb region", zoneRegions.filter((zone) => zone.settings.kerbs).map((zone) => zone.region));
  const zonesAt = (point) => zoneRegions.filter((zone) => inBox(zone.box, point) && zone.index.contains(point));

  // Frozen source geometry near the pilot.
  const nearPilot = (object, margin) => boxesOverlap(boxOfMulti(object.geometry), pilotBox, margin);
  const lineOf = new Map();
  const wayLine = (object) => {
    if (!lineOf.has(object.row.source_key)) lineOf.set(object.row.source_key, rawWayLine(rawOsm, object.row.osm_id));
    return lineOf.get(object.row.source_key);
  };
  const roads = objects.filter((object) => object.roles.includes("roads_paths") && object.row.osm_type === "way" && nearPilot(object, 60));
  const vehicles = roads.filter((object) => object.road_visual_class === "vehicle");
  const osmCarriageway = union("vehicle roads", vehicles.map((object) => object.geometry));
  // Parking lanes widen the carriageway beyond the frozen ribbon where the
  // photographs show cars parked along the curb and the OSM sidewalks sit that
  // far out; the curb then follows the widened edge.
  const parkingParts = [];
  const parkingWidth = new Map();
  for (const zone of zoneRegions) {
    for (const lane of zone.settings.parking_lanes) {
      for (const key of lane.source_keys) {
        parkingWidth.set(key, Math.max(parkingWidth.get(key) ?? 0, lane.width_m));
        const road = vehicles.find((object) => object.row.source_key === key);
        invariant(road, `Street ground parking lane road ${key} is not a vehicle road near the pilot`);
        const hw = ROAD_WIDTHS_M[road.tags.highway] / 2;
        parkingParts.push(intersect(`parking lane ${key}`, union(`parking lane ${key}`, [strip(`parking left ${key}`, wayLine(road), hw - CARRIAGEWAY_OVERLAP_M, hw + lane.width_m), strip(`parking right ${key}`, wayLine(road), -hw - lane.width_m, -hw + CARRIAGEWAY_OVERLAP_M)]), zone.region));
      }
    }
  }
  const parkingSurface = difference("parking lanes", union("parking lanes", parkingParts), [osmCarriageway]);
  const parkingIndex = polygonIndex(parkingSurface);
  const vehicleUnion = union("carriageway", [osmCarriageway, parkingSurface]);
  const vehicleIndex = polygonIndex(vehicleUnion);
  const inKerbRegion = (object) => intersect(`kerb test ${object.row.source_key}`, object.geometry, kerbRegion).length > 0;
  const kerbRoads = vehicles.filter((object) => object.tags.service !== "parking_aisle" && inKerbRegion(object));
  const sidewalks = roads.filter((object) => object.road_visual_class === "pedestrian" && object.tags.footway === "sidewalk");
  const pedestrianIndex = polygonIndex(union("pedestrian ways", roads.filter((object) => object.road_visual_class === "pedestrian").map((object) => object.geometry)));
  const lots = objects.filter((object) => object.roles.includes("major_area") && object.tags.amenity === "parking" && nearPilot(object, 30));
  const lotUnion = union("parking lots", lots.map((object) => object.geometry));
  const lotIndex = polygonIndex(lotUnion);
  const buildings = objects.filter((object) => (object.roles.includes("building") || object.roles.includes("building_part")) && nearPilot(object, 30));
  const buildingUnion = union("buildings", buildings.map((object) => object.geometry));
  const buildingIndex = polygonIndex(buildingUnion);
  const buildingClearance = union("building clearance", buildings.flatMap((object) => [
    object.geometry,
    ...object.geometry.flatMap((polygon) => polygon.map((ring) => {
      const points = openRing(ring);
      return lineRibbon([...points, points[0]], kerb.building_clearance_m * 2, `clearance ${object.row.source_key}`);
    })),
  ]));
  const hardKeepout = union("stair keepout", hardShapes
    .filter((shape) => ["stair", "door", "approach"].includes(shape.component))
    .filter((shape) => shape.points.some(([x, z]) => inBox(pilotBox, [x, -z], 30)))
    .map((shape) => (shape.points.length === 1
      ? circle([shape.points[0][0], -shape.points[0][1]], shape.radius_m)
      : lineRibbon(shape.points.map(([x, z]) => [x, -z]), shape.radius_m * 2, `keepout ${shape.source_id}`))));
  const sameStreet = (left, right) => left === right ||
    (left.tags.name != null && left.tags.name === right.tags.name && left.tags.highway === right.tags.highway);

  // --- Raised band. Flat-ended strips of the default sidewalk width along both
  // sides of every kerbed road, rounded only where ways meet; OSM sidewalks that
  // run alongside within reach join it, with the gap between them filled.
  const kerbSources = new Set(kerbRoads.map((object) => object.row.source_key));
  // Half the carriageway: the frozen ribbon plus any parking lane.
  const halfWidth = (object) => ROAD_WIDTHS_M[object.tags.highway] / 2 + (parkingWidth.get(object.row.source_key) ?? 0);
  const nodeUse = new Map();
  for (const object of vehicles) {
    for (const ref of new Set(rawOsm.ways.get(object.row.osm_id).node_refs)) nodeUse.set(ref, (nodeUse.get(ref) ?? 0) + 1);
  }
  const sideStrips = (label, line, inner, outer) => union(label, [strip(`${label} left`, line, inner, outer), strip(`${label} right`, line, -outer, -inner)]);
  const defaultBand = union("default band", kerbRoads.map((object) => {
    const line = wayLine(object);
    const refs = rawOsm.ways.get(object.row.osm_id).node_refs;
    const outer = halfWidth(object) + kerb.sidewalk_width_m;
    const parts = [sideStrips(`band ${object.row.source_key}`, line, halfWidth(object) - 0.05, outer)];
    if ((nodeUse.get(refs[0]) ?? 0) > 1) parts.push(circle(line[0], outer, 24));
    if ((nodeUse.get(refs.at(-1)) ?? 0) > 1) parts.push(circle(line.at(-1), outer, 24));
    return union(`band ${object.row.source_key}`, parts);
  }));
  const joinedSidewalks = [];
  const sidewalkParts = [];
  const wideGapParts = [];
  const wideGapWalks = [];
  // OSM sidewalks whose walk is photographed at the curb with the bed behind it.
  const behindWalk = new Set(zoneRegions.flatMap((zone) => zone.settings.planting_behind_walk.flatMap((entry) => entry.source_keys)));
  for (const sidewalk of sidewalks) {
    const line = wayLine(sidewalk);
    const total = polylineLength(line);
    const pieces = Math.max(1, Math.ceil(total / 6));
    let joined = false;
    for (let piece = 0; piece < pieces; piece += 1) {
      const a = pointAlong(line, (total * piece) / pieces).point;
      const b = pointAlong(line, (total * (piece + 1)) / pieces).point;
      if (length(sub(b, a)) < 0.2) continue;
      let best = null;
      for (const road of kerbRoads) {
        const nearA = closestOnPolyline(wayLine(road), a);
        const nearB = closestOnPolyline(wayLine(road), b);
        const reach = halfWidth(road) + kerb.sidewalk_reach_m + 1;
        if (nearA.distance > reach || nearB.distance > reach) continue;
        if (!best || nearA.distance + nearB.distance < best.score) best = { score: nearA.distance + nearB.distance, nearA, nearB, road };
      }
      if (!best || best.nearA.distance < 0.5 || best.nearB.distance < 0.5) continue;
      joined = true;
      const along = unit(sub(b, a));
      const walk = rectangle(a, along, leftOf(along), 0, length(sub(b, a)), -1, 1);
      const outA = add(a, scale(unit(sub(a, best.nearA.point)), 1));
      const outB = add(b, scale(unit(sub(b, best.nearB.point)), 1));
      const hull = convexHull([outA, outB, a, b, best.nearA.point, best.nearB.point]);
      sidewalkParts.push(walk);
      if (hull.length >= 3) sidewalkParts.push([[hull]]);
      // Gap between the curb and the sidewalk's inner edge. Normally the bed
      // fills it and the OSM walk stays concrete; a behind-walk sidewalk keeps
      // the default walk at the curb and the bed takes the gap and its line.
      const gap = (best.nearA.distance + best.nearB.distance) / 2 - halfWidth(best.road) - 1;
      if (gap >= kerb.planting_gap_m && hull.length >= 3 && !behindWalk.has(sidewalk.row.source_key)) {
        wideGapParts.push([[hull]]);
        wideGapWalks.push(walk);
      }
    }
    if (joined) joinedSidewalks.push(sidewalk.row.source_key);
  }
  // Plazas: a concrete walk at the curb, then banded paving, along named roads.
  const plazaParts = [];
  const paverParts = [];
  for (const zone of zoneRegions) {
    for (const plaza of zone.settings.plazas) {
      const sidePoint = [plaza.side_point_xz[0], -plaza.side_point_xz[1]];
      const walks = [];
      const pavers = [];
      for (const key of plaza.source_keys) {
        const road = vehicles.find((object) => object.row.source_key === key);
        invariant(road, `Street ground plaza road ${key} is not a vehicle road near the pilot`);
        const line = wayLine(road);
        const near = closestOnPolyline(line, sidePoint);
        const sign = cross(near.tangent, sub(sidePoint, near.point)) >= 0 ? 1 : -1;
        const hw = halfWidth(road);
        const signed = (from, to) => (sign > 0 ? [from, to] : [-to, -from]);
        walks.push(strip(`plaza walk ${key}`, line, ...signed(hw - 0.05, hw + plaza.walk_m)));
        pavers.push(strip(`plaza paving ${key}`, line, ...signed(hw + plaza.walk_m, hw + plaza.depth_m)));
      }
      // Where the road bends, the end of the paving strip tapers to a spike: open it away.
      const paving = openShapes(`plaza paving ${zone.id}`, intersect(`plaza paving ${zone.id}`, union(`plaza pavers ${zone.id}`, pavers), zone.region), PLAZA_OPENING_M);
      plazaParts.push(union(`plaza ${zone.id}`, [intersect(`plaza walk ${zone.id}`, union(`plaza walks ${zone.id}`, walks), zone.region), paving]));
      paverParts.push({ zone, plaza, region: paving });
    }
  }
  const raisedRaw = union("raised band", [defaultBand, ...sidewalkParts, ...plazaParts]);
  // A parking lot's narrow tips (under 3 m) do not notch the sidewalk.
  const blockers = [vehicleUnion, openShapes("parking lot body", lotUnion, LOT_OPENING_M), buildingClearance, hardKeepout];
  const bandOriginal = cleanPolygons(
    difference("band subtraction", closeGaps("band closing", intersect("band zone", raisedRaw, kerbRegion), kerb.closing_m), blockers),
    1.0,
    kerb.minimum_width_m,
    6.0,
    1.5,
  );
  const bandIndex = polygonIndex(bandOriginal);
  invariant(!bandIndex.contains([spawnXZ[0], -spawnXZ[1]]), "Street ground raises the ferry spawn");
  // Surface materials over the raised band: banded plaza paving, mulch planting
  // (curb_strip zones: between the curb and a sidewalk set back from it, and
  // beyond the default sidewalk where the OSM sidewalk crowds the curb) and
  // concrete everywhere else.
  const paverTop = intersect("plaza paving top", bandOriginal, union("plaza paving", paverParts.map((part) => part.region)));
  const paverIndex = polygonIndex(paverTop);

  // --- Crosswalks: from crossing ways, and crossing nodes that no crossing way carries.
  const marked = (tags) => tags["crossing:markings"] !== "no" && tags.crossing !== "unmarked" &&
    (tags["crossing:markings"] != null || ["marked", "zebra", "traffic_signals", "uncontrolled"].includes(tags.crossing));
  const crossingWays = roads.filter((object) => (object.tags.footway === "crossing" || object.tags.cycleway === "crossing") && marked(object.tags));
  const carriedNodes = new Set(roads.filter((object) => object.tags.footway === "crossing" || object.tags.cycleway === "crossing")
    .flatMap((object) => rawOsm.ways.get(object.row.osm_id).node_refs));
  const crosswalks = [];
  // A crossing is signalized when its way or one of its nodes says so; street
  // furniture puts signal poles at these.
  const signalTags = (tags) => tags.crossing === "traffic_signals" || tags.highway === "traffic_signals" || tags["crossing:signals"] === "yes";
  const nodeTags = (ref) => properSources.get(`n${ref}`)?.metadata.tags ?? {};
  const addCrosswalk = (sourceKey, center, direction, signals = false) => {
    if (zonesAt(center).length === 0) return;
    const start = add(center, scale(direction, -25));
    const end = add(center, scale(direction, 25));
    const nearRoads = vehicleIndex.near(boxOfPoints([start, end]), 1);
    const fractions = [0, ...segmentPolygonCrossings(start, end, nearRoads), 1];
    let span = null;
    for (let index = 1; index < fractions.length; index += 1) {
      const middle = (fractions[index - 1] + fractions[index]) / 2;
      if (!vehicleIndex.contains(add(start, scale(sub(end, start), middle)))) continue;
      const s0 = fractions[index - 1] * 50 - 25;
      const s1 = fractions[index] * 50 - 25;
      if (s0 <= 0.5 && s1 >= -0.5 && (!span || Math.abs(s0 + s1) < Math.abs(span[0] + span[1]))) span = [s0, s1];
    }
    if (!span || span[1] - span[0] < 2) return;
    crosswalks.push({ source_key: sourceKey, center, direction, across: leftOf(direction), span, signals });
  };
  for (const way of crossingWays) {
    const line = wayLine(way);
    const middle = pointAlong(line, polylineLength(line) / 2);
    const chord = sub(line.at(-1), line[0]);
    const signals = signalTags(way.tags) || rawOsm.ways.get(way.row.osm_id).node_refs.some((ref) => signalTags(nodeTags(ref)));
    addCrosswalk(way.row.source_key, middle.point, length(chord) > 1 ? unit(chord) : middle.tangent, signals);
  }
  for (const [sourceKey, source] of [...properSources.entries()].sort(([left], [right]) => compareSourceKeys(left, right))) {
    if (sourceKey[0] !== "n" || source.metadata.tags.highway !== "crossing" || !marked(source.metadata.tags) || carriedNodes.has(sourceKey.slice(1))) continue;
    const node = rawOsm.nodes.get(sourceKey.slice(1));
    const host = node ? vehicles.find((object) => rawOsm.ways.get(object.row.osm_id).node_refs.includes(sourceKey.slice(1))) : null;
    if (!host) continue;
    const position = closestOnPolyline(wayLine(host), projectLonLat(node.coordinate));
    addCrosswalk(host.row.source_key, position.point, leftOf(position.tangent), signalTags(source.metadata.tags));
  }
  crosswalks.sort((left, right) => left.center[0] - right.center[0] || left.center[1] - right.center[1]);
  const crosswalkKeepout = union("crosswalk keepout", crosswalks.map((walk) =>
    rectangle(walk.center, walk.direction, walk.across, walk.span[0] - 1, walk.span[1] + 1, -crossings.walk_width_m / 2 - 0.5, crossings.walk_width_m / 2 + 0.5)));
  const keepoutIndex = polygonIndex(crosswalkKeepout);

  // Curb ramps where a crosswalk lands on the raised band.
  const notches = [];
  for (const walk of crosswalks) {
    for (const [sign, s] of [[-1, walk.span[0]], [1, walk.span[1]]]) {
      const outward = scale(walk.direction, sign);
      const landing = add(walk.center, scale(walk.direction, s));
      if (!bandIndex.contains(add(landing, scale(outward, 0.4)))) continue;
      const rect = rectangle(landing, outward, walk.across, -0.05, crossings.ramp_depth_m, -crossings.ramp_width_m / 2, crossings.ramp_width_m / 2);
      const piece = intersect("curb ramp", rect, bandIndex.near(boxOfMulti(rect), 1));
      if (multiArea(piece) < 0.5) continue;
      const rise = top - (ROAD_TOP_M + lifts.paint_m);
      const height = {
        h0: ROAD_TOP_M + lifts.paint_m - (rise / crossings.ramp_depth_m) * dot(landing, outward),
        he: (rise / crossings.ramp_depth_m) * outward[0],
        hn: (rise / crossings.ramp_depth_m) * outward[1],
      };
      notches.push({ source_key: walk.source_key, landing, outward, across: walk.across, rect, piece, height });
    }
  }
  const notchUnion = union("curb ramp notches", notches.map((notch) => notch.rect));
  const notchIndex = polygonIndex(union("curb ramps", notches.map((notch) => notch.piece)));
  // Mulch beds stay clear of a crosswalk's landing: a ramp tops out on concrete.
  const landings = notches.map((notch) => rectangle(notch.landing, notch.outward, notch.across,
    crossings.ramp_depth_m - 0.05, crossings.ramp_depth_m + RAMP_LANDING_M, -crossings.ramp_width_m / 2, crossings.ramp_width_m / 2));
  const curbStripRegion = union("curb-strip zones", zoneRegions.filter((zone) => zone.settings.planting === "curb_strip").map((zone) => zone.region));
  const concreteKeep = union("concrete keep", [difference("default band beside set-back walks", defaultBand, wideGapParts), ...wideGapWalks, ...plazaParts, ...landings]);
  const plantedTop = cleanPolygons(
    intersect("planting", difference("planting candidates", bandOriginal, [concreteKeep, paverTop]), curbStripRegion),
    1.0,
    0.6,
  );
  const plantedIndex = polygonIndex(plantedTop);
  const bandRaised = cleanPolygons(difference("band minus ramps", bandOriginal, [notchUnion]), 0.3, 0.2);
  const raisedIndex = polygonIndex(bandRaised);

  const pieces = [];
  const faces = [];
  const sources = {
    kerb: new Set(kerbSources),
    planting: new Set(kerbSources),
    plaza: new Set(paverParts.flatMap((part) => part.plaza.source_keys)),
    parking: new Set(zoneRegions.flatMap((zone) => zone.settings.parking_lanes.flatMap((lane) => lane.source_keys))),
    verge: new Set(kerbSources),
    ramp: new Set(kerbSources),
    gutter: new Set(kerbSources),
    wear: new Set(),
    marking: new Set(),
    ...Object.fromEntries(Object.keys(PARK_SURFACE_MATERIALS).map((material) => [material, new Set()])),
  };
  for (const key of joinedSidewalks) {
    sources.kerb.add(key);
    sources.planting.add(key);
  }
  const addPiece = (record, polygon, height, uv, smooth = false) => {
    if (polygon.length > 0) pieces.push({ record, polygon, height, uv, smooth });
  };

  // Raised tops take their panel or paver frame from a kerbed road. Each road
  // owns the band within reach of it, the more important (then longer) road
  // first, so a side street's panels meet the main sidewalk along its back edge,
  // as poured, rather than on an arbitrary seam. Owned parts are cut on an 8 m
  // grid so the frame follows curves; parts no road reaches take the nearest
  // road's frame. Ramp floors use their crossing's frame.
  const nearestKerbLine = (point) => {
    let best = null;
    for (const road of kerbRoads) {
      const near = closestOnPolyline(wayLine(road), point);
      if (!best || near.distance < best.distance) best = { line: wayLine(road), distance: near.distance };
    }
    return best.line;
  };
  const rankOf = (road) => {
    const rank = FRAME_ROAD_RANK.indexOf(road.tags.highway);
    return rank < 0 ? FRAME_ROAD_RANK.length : rank;
  };
  const frameOwners = [...kerbRoads].sort((left, right) => rankOf(left) - rankOf(right) ||
    polylineLength(wayLine(right)) - polylineLength(wayLine(left)) ||
    compareSourceKeys(left.row.source_key, right.row.source_key));
  let framed = [];
  const frameRegions = frameOwners.map((road) => {
    const reach = halfWidth(road) + kerb.sidewalk_reach_m + 1;
    const region = strip(`frame ${road.row.source_key}`, wayLine(road), -reach, reach);
    const owned = difference(`frame owned ${road.row.source_key}`, region, [framed]);
    framed = union("framed", [framed, region]);
    return { line: wayLine(road), region: owned };
  });
  const addFramed = (record, polygon, size) => {
    if (polygon.length === 0) return;
    const addCells = (part, line) => {
      if (part.length === 0) return;
      for (const cell of gridCells(boxOfMulti(part), 8)) {
        const piece = intersect(`${record} cell`, part, cell);
        if (multiArea(piece) < 1e-6) continue;
        const box = boxOfMulti(piece);
        const centre = [(box.min_x + box.max_x) / 2, (box.min_y + box.max_y) / 2];
        addPiece(record, piece, constantHeight(top), roadFrameUv(line ?? nearestKerbLine(centre), centre, size));
      }
    };
    for (const owner of frameRegions) addCells(intersect(`${record} owned`, polygon, owner.region), owner.line);
    addCells(difference(`${record} unowned`, polygon, [framed]), null);
  };
  addFramed("kerb", difference("concrete tops", bandRaised, [plantedTop, paverTop]), kerb.panel_m);
  addPiece("parking", parkingSurface, constantHeight(ROAD_TOP_M), worldUv);
  addPiece("planting", intersect("planted tops", bandRaised, plantedTop), constantHeight(top), tiledUv(2));
  for (const part of paverParts) addFramed("plaza", intersect("plaza tops", bandRaised, part.region), part.plaza.paver_tile_m);
  for (const notch of notches) {
    addPiece("kerb", notch.piece, notch.height, (point) => [
      dot(sub(point, notch.landing), notch.across) / kerb.panel_m,
      dot(sub(point, notch.landing), notch.outward) / kerb.panel_m,
    ]);
    sources.kerb.add(notch.source_key);
  }

  // Skirts: walkable slopes around every raised edge. In front of a curb face
  // they are invisible collision ramps; behind a sidewalk they are visible slopes;
  // inside a curb ramp they are its flared sides.
  const skirtPieces = [];
  const edgeLoops = (multi, heightOf, classify) => {
    for (const polygon of multi) {
      polygon.forEach((raw, ringIndex) => {
        let ring = openRing(raw);
        if (ring.length < 3) return;
        const area = ringArea(ring);
        if ((ringIndex === 0) !== (area > 0)) ring = ring.reverse();
        const edges = [];
        for (let index = 0; index < ring.length; index += 1) {
          const a = ring[index];
          const b = ring[(index + 1) % ring.length];
          const direction = unit(sub(b, a));
          const outward = [direction[1], -direction[0]];
          const kind = classify(a, b, outward);
          edges.push({ a, b, outward, kind, ha: heightOf(a), hb: heightOf(b) });
        }
        emitSkirts(edges);
      });
    }
  };
  const runOf = { curb: kerb.support_run_m, flare: kerb.flare_run_m, back: kerb.back_slope_run_m, inner: 0 };
  const footOf = { curb: 0, flare: SKIRT_FOOT_M, back: SKIRT_FOOT_M, inner: 0 };
  const classifyRaised = (a, b, outward) => {
    let curb = 0;
    let flare = 0;
    for (const fraction of [0.25, 0.5, 0.75]) {
      const probe = add(add(a, scale(sub(b, a), fraction)), scale(outward, 0.04));
      if (vehicleIndex.contains(probe)) curb += 1;
      else if (notchIndex.contains(probe)) flare += 1;
    }
    return curb >= 2 ? "curb" : flare >= 2 ? "flare" : "back";
  };
  const classifyRamp = (a, b, outward) => {
    let curb = 0;
    let inner = 0;
    for (const fraction of [0.25, 0.5, 0.75]) {
      const probe = add(add(a, scale(sub(b, a), fraction)), scale(outward, 0.04));
      if (vehicleIndex.contains(probe)) curb += 1;
      else if (raisedIndex.contains(probe)) inner += 1;
    }
    return curb >= 2 ? "curb" : inner >= 2 ? "inner" : "back";
  };
  function emitSkirts(edges) {
    for (let index = 0; index < edges.length; index += 1) {
      const edge = edges[index];
      const run = runOf[edge.kind];
      if (run <= 0) continue;
      const foot = footOf[edge.kind];
      const aOut = add(edge.a, scale(edge.outward, run));
      const bOut = add(edge.b, scale(edge.outward, run));
      skirtPieces.push({ kind: edge.kind, points: [edge.a, edge.b, bOut], heights: [edge.ha, edge.hb, foot], edge });
      skirtPieces.push({ kind: edge.kind, points: [edge.a, bOut, aOut], heights: [edge.ha, foot, foot], edge });
      if (edge.kind === "curb") faces.push(edge);
      // Round the corner to the next edge when the outline turns convex.
      const next = edges[(index + 1) % edges.length];
      const nextRun = runOf[next.kind];
      if (nextRun <= 0 || cross(sub(edge.b, edge.a), sub(next.b, next.a)) <= 1e-9) continue;
      const start = Math.atan2(edge.outward[1], edge.outward[0]);
      let sweep = Math.atan2(next.outward[1], next.outward[0]) - start;
      while (sweep <= 0) sweep += 2 * Math.PI;
      if (sweep >= Math.PI) continue;
      const steps = Math.max(1, Math.ceil(sweep / (Math.PI / 8)));
      const kind = edge.kind === next.kind ? edge.kind : edge.kind === "curb" || next.kind === "curb" ? "curb" : edge.kind;
      for (let step = 0; step < steps; step += 1) {
        const point = (k) => {
          const angle = start + (sweep * k) / steps;
          const r = run + (nextRun - run) * (k / steps);
          return add(edge.b, [Math.cos(angle) * r, Math.sin(angle) * r]);
        };
        skirtPieces.push({ kind, points: [edge.b, point(step), point(step + 1)], heights: [edge.hb, footOf[kind], footOf[kind]], edge });
      }
    }
  }
  edgeLoops(bandRaised, () => top, classifyRaised);
  for (const notch of notches) edgeLoops(notch.piece, (point) => heightAt(notch.height, point), classifyRamp);

  // Split each skirt triangle into its road part (invisible collision ramp) and
  // its open-ground part (visible slope, paved or planted by what lies there).
  for (const skirt of skirtPieces) {
    const triangle = [[skirt.points]];
    if (Math.abs(ringArea(skirt.points)) < 1e-6) continue;
    const height = affineHeight(skirt.points, skirt.heights);
    const box = boxOfPoints(skirt.points);
    const roadParts = vehicleIndex.near(box, 0.01);
    const inRoad = skirt.points.every((point) => vehicleIndex.contains(point));
    const support = roadParts.length === 0 ? [] : inRoad ? triangle : intersect("skirt road part", triangle, roadParts);
    const open = roadParts.length === 0 ? triangle : inRoad ? [] : difference("skirt open part", triangle, roadParts);
    addPiece("ramp", support, height, worldUv);
    const visible = difference("skirt beside buildings", open, buildingIndex.near(box, 0.01));
    if (visible.length === 0) continue;
    // The slope takes the raised top it falls from: a mulch bed's own edge, else
    // concrete where it runs down onto paving and grass where it meets ground.
    const middle = add(skirt.edge.a, scale(sub(skirt.edge.b, skirt.edge.a), 0.5));
    const probe = add(middle, scale(skirt.edge.outward, runOf[skirt.kind] * 0.7));
    const inner = add(middle, scale(skirt.edge.outward, -0.05));
    const planted = skirt.kind === "back" && plantedIndex.contains(inner);
    const paved = skirt.kind === "flare" || skirt.kind === "curb" || notchIndex.contains(probe) || pedestrianIndex.contains(probe) || lotIndex.contains(probe) || vehicleIndex.contains(probe);
    if (planted) addPiece("planting", visible, height, tiledUv(2));
    else if (paved) addPiece("kerb", visible, height, roadFrameUv(nearestKerbLine(middle), middle, kerb.panel_m));
    else addPiece("verge", visible, height, worldUv);
  }

  // Gutter pans along curb faces, on the road.
  const gutterSkirts = [];
  for (const edge of faces) {
    const aOut = add(edge.a, scale(edge.outward, kerb.gutter_width_m));
    const bOut = add(edge.b, scale(edge.outward, kerb.gutter_width_m));
    const ring = [edge.a, edge.b, bOut, aOut];
    gutterSkirts.push([[ringArea(ring) > 0 ? ring : ring.reverse()]]);
  }
  const gutters = intersect("gutters", union("gutter strips", gutterSkirts), vehicleUnion);
  addPiece("gutter", gutters, constantHeight(ROAD_TOP_M + lifts.gutter_m), worldUv);

  // ---------------------------------------------------------------- markings
  const roadPaint = (label, polygon) => intersect(`${label} on road`, intersect(`${label} in zone`, polygon, pilot), vehicleUnion);
  const paint = (kind, polygon, sourceKey) => {
    if (polygon.length === 0) return;
    addPiece("marking", polygon, constantHeight(ROAD_TOP_M + lifts.paint_m), kindUv(kind));
    sources.marking.add(sourceKey);
  };
  const counts = { crosswalks: crosswalks.length, curb_ramps: notches.length, centerline_m: 0, stop_bars: 0, stall_lines: 0, wear: {} };
  // Painted stop bars, for the stop signs beside them.
  const stopBars = [];

  // Crosswalk bars (continental style, bars parallel to traffic).
  for (const walk of crosswalks) {
    const bars = [];
    const pitch = crossings.bar_width_m + crossings.bar_gap_m;
    const count = Math.floor((walk.span[1] - walk.span[0] + crossings.bar_gap_m) / pitch);
    const start = (walk.span[0] + walk.span[1]) / 2 - (count * pitch - crossings.bar_gap_m) / 2;
    for (let bar = 0; bar < count; bar += 1) {
      const s = start + bar * pitch;
      bars.push(rectangle(walk.center, walk.direction, walk.across, s, s + crossings.bar_width_m, -crossings.walk_width_m / 2, crossings.walk_width_m / 2));
    }
    paint(STREET_PAINT_KINDS.white, roadPaint("crosswalk", union("crosswalk bars", bars)), walk.source_key);
  }

  // Tactile pads at the foot of every curb ramp.
  for (const notch of notches) {
    const core = crossings.ramp_width_m / 2 - kerb.flare_run_m - 0.05;
    const pad = intersect("tactile pad", rectangle(notch.landing, notch.outward, notch.across, 0.15, 0.15 + crossings.tactile_depth_m, -core, core), notch.piece);
    if (pad.length === 0) continue;
    addPiece("marking", pad, { ...notch.height, h0: notch.height.h0 + lifts.paint_m }, kindUv(STREET_PAINT_KINDS.tactile));
    sources.marking.add(notch.source_key);
  }

  // Lines along roads: centre lines, bus and bike lanes, edge lines.
  for (const road of kerbRoads) {
    const roadZones = zoneRegions.filter((zone) => intersect(`road zone ${road.row.source_key}`, road.geometry, zone.region).length > 0);
    const line = wayLine(road);
    const half = ROAD_WIDTHS_M[road.tags.highway] / 2;
    const others = vehicles.filter((other) => !sameStreet(other, road)).map((other) => other.geometry);
    const junctions = union(`junctions ${road.row.source_key}`, others);
    const clip = (label, polygon) => difference(label, intersect(`${label} own road`, roadPaint(label, polygon), road.geometry), [junctions, crosswalkKeepout]);
    const zoneWants = (key) => roadZones.some((zone) => zone.settings[key]);
    const centerlineStyle = road.tags.oneway === "yes" ? null : (roadZones.map((zone) => zone.settings.centerlines[road.tags.highway]).find(Boolean) ?? null);
    const centerline = centerlineStyle === "double_yellow";
    const sideLanes = { left: null, right: null };
    if (zoneWants("lane_markings")) {
      const busSide = (value) => typeof value === "string" && value.split("|").includes("designated");
      if (busSide(road.tags["bus:lanes:backward"])) sideLanes.left = "bus";
      if (busSide(road.tags["bus:lanes:forward"])) sideLanes.right = "bus";
      const bike = (value) => value === "lane";
      if (bike(road.tags["cycleway:right"]) || bike(road.tags["cycleway:both"]) || bike(road.tags.cycleway)) sideLanes.right ??= "bike";
      if (bike(road.tags["cycleway:left"]) || bike(road.tags["cycleway:both"]) || (bike(road.tags.cycleway) && road.tags.oneway !== "yes")) sideLanes.left ??= "bike";
    }
    if (centerline) {
      const lineHalf = lines.double_gap_m / 2;
      const yellow = union("centre line", [strip("centre line left", line, lineHalf, lineHalf + lines.width_m), strip("centre line right", line, -lineHalf - lines.width_m, -lineHalf)]);
      const clipped = clip("centre line", yellow);
      paint(STREET_PAINT_KINDS.yellow, clipped, road.row.source_key);
      counts.centerline_m += multiArea(clipped) / (2 * lines.width_m);
    } else if (centerlineStyle === "dashed_faded") {
      // A worn single dashed line, as photographed on the Avenue of the Palms.
      const dashes = [];
      const total = polylineLength(line);
      for (let s = lines.dash_gap_m / 2; s + lines.dash_m <= total; s += lines.dash_m + lines.dash_gap_m) {
        const at = pointAlong(line, s + lines.dash_m / 2);
        dashes.push(rectangle(at.point, at.tangent, leftOf(at.tangent), -lines.dash_m / 2, lines.dash_m / 2, -lines.width_m / 2, lines.width_m / 2));
      }
      const clipped = clip("dashed centre line", union("dashed centre line", dashes));
      paint(STREET_PAINT_KINDS.yellow_faded, clipped, road.row.source_key);
      counts.centerline_m += multiArea(clipped) / lines.width_m;
    }
    for (const [side, sign] of [["left", 1], ["right", -1]]) {
      const lane = sideLanes[side];
      const signed = (from, to) => (sign > 0 ? [from, to] : [-to, -from]);
      if (lane === "bus" || lane === "bike") {
        const width = lane === "bus" ? lines.bus_lane_width_m : lines.bike_lane_width_m;
        const inner = half - width;
        const [lineFrom, lineTo] = signed(inner - lines.width_m, inner);
        paint(STREET_PAINT_KINDS.white, clip(`${lane} lane line`, strip(`${lane} lane line`, line, lineFrom, lineTo)), road.row.source_key);
        const [laneFrom, laneTo] = signed(inner + 0.05, half - 0.05);
        const laneStrip = strip(`${lane} lane`, line, laneFrom, laneTo);
        if (lane === "bus") {
          paint(STREET_PAINT_KINDS.red, clip("bus lane", laneStrip), road.row.source_key);
        } else {
          // Green only in the conflict zones next to crossings, as photographed.
          const conflict = union("bike conflict zones", crosswalks.map((walk) =>
            rectangle(walk.center, walk.direction, walk.across, walk.span[0] - 1, walk.span[1] + 1, -crossings.walk_width_m / 2 - lines.conflict_length_m, crossings.walk_width_m / 2 + lines.conflict_length_m)));
          paint(STREET_PAINT_KINDS.green, clip("bike conflict", intersect("bike conflict lane", laneStrip, conflict)), road.row.source_key);
        }
      } else if (centerline) {
        const [from, to] = signed(half - lines.edge_inset_m - lines.width_m, half - lines.edge_inset_m);
        paint(STREET_PAINT_KINDS.white, clip("edge line", strip("edge line", line, from, to)), road.row.source_key);
      }
    }
  }

  // Stop bars and STOP legends at OSM highway=stop nodes.
  for (const [sourceKey, source] of [...properSources.entries()].sort(([left], [right]) => compareSourceKeys(left, right))) {
    if (sourceKey[0] !== "n" || source.metadata.tags.highway !== "stop") continue;
    const node = rawOsm.nodes.get(sourceKey.slice(1));
    if (!node) continue;
    const position = projectLonLat(node.coordinate);
    if (zonesAt(position).length === 0) continue;
    // Only stops that OSM puts on a vehicle road: a stop node on a footway does
    // not say which approach it controls.
    const host = vehicles.find((object) => rawOsm.ways.get(object.row.osm_id).node_refs.includes(sourceKey.slice(1)));
    if (!host) continue;
    const near = closestOnPolyline(wayLine(host), position);
    const line = wayLine(host);
    const total = polylineLength(line);
    const tags = source.metadata.tags;
    const forward = tags.direction === "forward" ? true : tags.direction === "backward" ? false : near.along > total / 2;
    const travel = scale(near.tangent, forward ? 1 : -1);
    const right = [travel[1], -travel[0]];
    const half = ROAD_WIDTHS_M[host.tags.highway] / 2;
    // A stop node often sits on the junction itself. Back the stop line up the
    // approach until it is clear of every crossing road and crosswalk.
    const crossingRoads = polygonIndex(union(`roads crossing ${host.row.source_key}`, vehicles.filter((other) => !sameStreet(other, host)).map((other) => other.geometry)));
    const barCorners = (center) => [-1, 1].flatMap((side) => [-1, 1].map((end) =>
      add(add(center, scale(travel, end * lines.stop_bar_width_m)), scale(right, side > 0 ? half - 0.1 : 0.15))));
    // The driver meets STOP, the stop line, then any crosswalk, then the
    // junction: put the line just upstream of the last blocked sample within 16 m.
    let lastBlocked = -1;
    for (let step = 0; step <= 32; step += 1) {
      const sample = add(near.point, scale(travel, -0.5 * step));
      if (barCorners(sample).some((corner) => crossingRoads.contains(corner) || keepoutIndex.contains(corner))) lastBlocked = step;
    }
    const barCenter = lastBlocked < 0 ? near.point : add(near.point, scale(travel, -(0.5 * lastBlocked + 1.1)));
    const bar = rectangle(barCenter, travel, right, -lines.stop_bar_width_m / 2, lines.stop_bar_width_m / 2, 0.15, half - 0.1);
    paint(STREET_PAINT_KINDS.white, roadPaint("stop bar", bar), host.row.source_key);
    const legendWidth = Math.min(half - 0.6, 2.4);
    const legendCenter = add(add(barCenter, scale(travel, -(lines.stop_bar_width_m / 2 + lines.stop_legend_gap_m + lines.stop_legend_length_m / 2))), scale(right, half / 2));
    const legend = roadPaint("stop legend", rectangle(legendCenter, travel, right, -lines.stop_legend_length_m / 2, lines.stop_legend_length_m / 2, -legendWidth / 2, legendWidth / 2));
    if (legend.length > 0) {
      addPiece("marking", legend, constantHeight(ROAD_TOP_M + lifts.paint_m), frameUv(STREET_PAINT_KINDS.stop_legend, legendCenter, travel, right, lines.stop_legend_length_m, legendWidth));
    }
    stopBars.push({ node_key: sourceKey, host_key: host.row.source_key, bar_center: barCenter, travel, right, kerb_offset_m: halfWidth(host) });
    counts.stop_bars += 1;
  }

  // Parking stall lines along aisles inside lots. The stalls between two
  // neighbouring lines are kept for the parked cars (street clutter).
  const stallSlots = [];
  for (const zone of zoneRegions.filter((candidate) => candidate.settings.parking_stalls)) {
    const aisles = vehicles.filter((object) => object.tags.service === "parking_aisle" && intersect("aisle zone", object.geometry, zone.region).length > 0);
    for (const aisle of aisles) {
      const line = wayLine(aisle);
      const half = ROAD_WIDTHS_M[aisle.tags.highway] / 2;
      const otherRoads = polygonIndex(union("other aisles", vehicles.filter((other) => other !== aisle).map((other) => other.geometry)));
      const total = polylineLength(line);
      const stalls = [];
      for (const sign of [1, -1]) {
        let previous = null;
        for (let s = 1.5; s <= total - 1.5; s += lines.stall_spacing_m) {
          const at = pointAlong(line, s);
          const outward = scale(leftOf(at.tangent), sign);
          const base = add(at.point, scale(outward, half + 0.05));
          let reach = 0;
          for (let step = 1; step <= Math.ceil((lines.stall_length_m * 2 + 1) / 0.2); step += 1) {
            const probe = add(base, scale(outward, step * 0.2));
            if (!lotIndex.contains(probe) || otherRoads.contains(probe) || buildingIndex.contains(probe) || bandIndex.contains(probe)) break;
            reach = step * 0.2;
          }
          const stall = Math.min(lines.stall_length_m, reach > lines.stall_length_m * 1.6 ? lines.stall_length_m : reach / 2) - 0.1;
          if (stall < 2.5) {
            previous = null;
            continue;
          }
          stalls.push(rectangle(base, outward, at.tangent, 0, stall, -lines.width_m / 2, lines.width_m / 2));
          if (previous) {
            const middle = pointAlong(line, s - lines.stall_spacing_m / 2);
            const middleOut = scale(leftOf(middle.tangent), sign);
            stallSlots.push({
              aisle_key: aisle.row.source_key,
              side: sign > 0 ? "left" : "right",
              s: roundCoordinate(s - lines.stall_spacing_m / 2),
              entry: add(middle.point, scale(middleOut, half + 0.05)),
              outward: middleOut,
              along: middle.tangent,
              depth_m: roundCoordinate(Math.min(stall, previous)),
              width_m: lines.stall_spacing_m,
            });
          }
          previous = stall;
        }
      }
      const painted = intersect("stall lines", union("stall lines", stalls), lotUnion);
      paint(STREET_PAINT_KINDS.white, painted, aisle.row.source_key);
      counts.stall_lines += stalls.length;
    }
  }

  // ---------------------------------------------------------------- wear
  const wearPiece = (cell, center, along, alongSize, acrossSize, sourceKey) => {
    const across = leftOf(along);
    const quad = rectangle(center, along, across, -alongSize / 2, alongSize / 2, -acrossSize / 2, acrossSize / 2);
    if (!openRing(quad[0][0]).every((point) => vehicleIndex.contains(point))) return false;
    addPiece("wear", quad, constantHeight(ROAD_TOP_M + lifts.paint_m * 0.5), frameUv(cell, center, along, across, alongSize, acrossSize));
    sources.wear.add(sourceKey);
    counts.wear[cell] = (counts.wear[cell] ?? 0) + 1;
    return true;
  };
  const nearestRoad = (point) => {
    let best = null;
    for (const road of vehicles) {
      const near = closestOnPolyline(wayLine(road), point);
      if (!best || near.distance < best.near.distance) best = { road, near };
    }
    return best;
  };
  for (const zone of zoneRegions) {
    const wear = zone.settings.wear;
    const asphalt = intersect(`asphalt ${zone.id}`, vehicleUnion, zone.region);
    const area = multiArea(asphalt);
    const box = boxOfMulti(asphalt.length > 0 ? asphalt : zone.region);
    const asphaltIndex = polygonIndex(asphalt);
    const scatter = (kindName, perHundred, cells, size) => {
      const wanted = Math.round((area * perHundred) / 100);
      let placed = 0;
      for (let attempt = 0; placed < wanted && attempt < wanted * 12; attempt += 1) {
        const identity = `${zone.id}:${kindName}:${attempt}`;
        const point = [box.min_x + hashUnit(seed, identity, 0) * (box.max_x - box.min_x), box.min_y + hashUnit(seed, identity, 1) * (box.max_y - box.min_y)];
        if (!asphaltIndex.contains(point) || keepoutIndex.contains(point)) continue;
        const road = nearestRoad(point);
        if (!road) continue;
        const jitter = (hashUnit(seed, identity, 2) - 0.5) * (kindName === "oil" ? 2 * Math.PI : 0.25);
        const angle = Math.atan2(road.near.tangent[1], road.near.tangent[0]) + jitter + (kindName !== "oil" && hashUnit(seed, identity, 3) < 0.3 ? Math.PI / 2 : 0);
        const along = [Math.cos(angle), Math.sin(angle)];
        const cell = cells[Math.floor(hashUnit(seed, identity, 4) * cells.length) % cells.length];
        const sizeScale = 0.75 + hashUnit(seed, identity, 5) * 0.5;
        if (wearPiece(cell, point, along, size[0] * sizeScale, size[1] * sizeScale, road.road.row.source_key)) placed += 1;
      }
    };
    scatter("crack", wear.crack_per_100m2, [STREET_WEAR_CELLS.crack_a, STREET_WEAR_CELLS.crack_b], [3.2, 1.6]);
    scatter("patch", wear.patch_per_100m2, [STREET_WEAR_CELLS.patch], [2.2, 1.4]);
    scatter("oil", wear.oil_per_100m2, [STREET_WEAR_CELLS.oil_a, STREET_WEAR_CELLS.oil_b], [1.4, 1.4]);
    // Manholes along the middle of each kerbed road in the zone.
    if (wear.manhole_spacing_m > 0) {
      for (const road of kerbRoads) {
        const line = wayLine(road);
        const total = polylineLength(line);
        for (let s = wear.manhole_spacing_m / 2, index = 0; s < total; s += wear.manhole_spacing_m, index += 1) {
          const identity = `${zone.id}:manhole:${road.row.source_key}:${index}`;
          const at = pointAlong(line, Math.min(total, s + (hashUnit(seed, identity, 0) - 0.5) * wear.manhole_spacing_m * 0.4));
          const side = (hashUnit(seed, identity, 1) < 0.5 ? -1 : 1) * ROAD_WIDTHS_M[road.tags.highway] * 0.22;
          const point = add(at.point, scale(leftOf(at.tangent), side));
          if (!zone.index.contains(point) || keepoutIndex.contains(point)) continue;
          wearPiece(STREET_WEAR_CELLS.manhole, point, at.tangent, 0.95, 0.95, road.row.source_key);
        }
      }
    }
    // Storm drains in the gutter along curb faces.
    if (wear.drain_spacing_m > 0) {
      let walked = wear.drain_spacing_m / 2;
      for (const edge of faces) {
        const edgeLength = length(sub(edge.b, edge.a));
        let s = walked;
        while (s < edgeLength) {
          const along = unit(sub(edge.b, edge.a));
          const center = add(add(edge.a, scale(along, s)), scale(edge.outward, 0.27));
          if (zone.index.contains(center) && !notchIndex.contains(add(center, scale(edge.outward, -0.5))) && s > 0.6 && s < edgeLength - 0.6) {
            const road = nearestRoad(center);
            if (road) wearPiece(STREET_WEAR_CELLS.drain, center, along, 0.95, 0.5, road.road.row.source_key);
          }
          s += wear.drain_spacing_m;
        }
        walked = s - edgeLength;
      }
    }
  }

  // ---------------------------------------------------------------- park surfaces
  // Each park zone's layers, later ones replacing earlier ones: one partition of
  // the zone into flat-lying ground draped lift_m over the land.
  const pedestrianWays = roads.filter((object) => object.road_visual_class === "pedestrian");
  const sourceGeometry = (key) => {
    const object = playableObjects.get(key);
    invariant(object && object.geometry?.length > 0, `Park surface source ${key} has no geometry`);
    return object.geometry;
  };
  const layerLine = (layer) => {
    const shape = layer.shape;
    if (shape.line_xz) return { line: shape.line_xz.map(([x, z]) => [x, -z]), offset: 0 };
    if (shape.way) return { line: rawWayLine(rawOsm, shape.way.slice(1)), offset: shape.offset_m };
    return null;
  };
  const layerShape = (zone, layer) => {
    const shape = layer.shape;
    let polygon;
    if (shape.zone) {
      polygon = zone.region;
    } else if (shape.osm_paths) {
      polygon = union(`park ${layer.id} paths`, pedestrianWays.filter((object) => intersect(`park ${layer.id} path test`, object.geometry, zone.region).length > 0).map((object) => object.geometry));
    } else if (shape.points_xz) {
      const ring = shape.points_xz.map(([x, z]) => [x, -z]);
      polygon = union(`park ${layer.id}`, [[[ringArea(ring) > 0 ? ring : ring.reverse()]]]);
    } else {
      const { line, offset } = layerLine(layer);
      polygon = strip(`park ${layer.id}`, line, offset - shape.width_m / 2, offset + shape.width_m / 2);
    }
    if (shape.minus_sources) polygon = difference(`park ${layer.id} minus`, polygon, shape.minus_sources.map(sourceGeometry));
    return intersect(`park ${layer.id} in zone`, polygon, zone.region);
  };
  const parkLayers = [];
  const parkLifts = new Map();
  for (const zone of zoneRegions) {
    const surfaces = zone.settings.surfaces;
    if (!surfaces) continue;
    const shapes = surfaces.layers.map((layer) => layerShape(zone, layer));
    let covered = [];
    for (let index = surfaces.layers.length - 1; index >= 0; index -= 1) {
      const layer = surfaces.layers[index];
      const own = cleanPolygons(difference(`park ${layer.id} uncovered`, shapes[index], [covered]), 0.05, 0.05);
      covered = union(`park ${zone.id} cover`, [covered, shapes[index]]);
      if (own.length === 0) continue;
      invariant((parkLifts.get(layer.material) ?? surfaces.lift_m) === surfaces.lift_m, `Park surface ${layer.material} has two lifts`);
      parkLifts.set(layer.material, surfaces.lift_m);
      parkLayers.push({ zone, layer, polygon: own, index: polygonIndex(own), box: boxOfMulti(own), lift: surfaces.lift_m, sources: surfaces.source_keys });
    }
  }
  for (const entry of parkLayers) {
    const { layer, polygon, lift } = entry;
    for (const key of entry.sources) sources[layer.material].add(key);
    const height = constantHeight(lift);
    const path = layer.material === "park_concrete" ? layerLine(layer) : null;
    if (layer.frame) {
      // Plaza paint laid out in metres along the plaza's axis.
      const origin = [layer.frame.origin_xz[0], -layer.frame.origin_xz[1]];
      const axis = unit([layer.frame.axis_xz[0], -layer.frame.axis_xz[1]]);
      addPiece(layer.material, polygon, height, (point) => [dot(sub(point, origin), axis), cross(axis, sub(point, origin))], true);
    } else if (path) {
      // Concrete paths in poured panels that follow the path's bends.
      for (const cell of gridCells(boxOfMulti(polygon), PATH_FRAME_CELL_M)) {
        const piece = intersect(`park ${layer.id} cell`, polygon, cell);
        if (multiArea(piece) < 1e-6) continue;
        const box = boxOfMulti(piece);
        addPiece(layer.material, piece, height, roadFrameUv(path.line, [(box.min_x + box.max_x) / 2, (box.min_y + box.max_y) / 2], kerb.panel_m * 2), true);
      }
    } else {
      // Concrete elsewhere in panels on the world grid; other ground in world UV.
      addPiece(layer.material, polygon, height, layer.material === "park_concrete" ? tiledUv(kerb.panel_m * 2) : worldUv, true);
    }
    if (layer.markings) {
      // Painted lines on the path itself, just above it: edge lines in from
      // both edges and a dashed centre line.
      const { line, offset } = layerLine(layer);
      const half = layer.shape.width_m / 2;
      const lines = [];
      if (layer.markings.edges) {
        for (const side of [-1, 1]) {
          const at = offset + side * (half - PARK_EDGE_LINE_INSET_M);
          lines.push([layer.markings.edges, strip(`park ${layer.id} edge line`, line, at - PARK_LINE_WIDTH_M / 2, at + PARK_LINE_WIDTH_M / 2)]);
        }
      }
      if (layer.markings.centre) lines.push([layer.markings.centre, dashedStrip(`park ${layer.id} centre line`, line, offset, PARK_LINE_WIDTH_M, PARK_DASH_M)]);
      for (const [kind, band] of lines) {
        const painted = intersect(`park ${layer.id} paint`, band, polygon);
        if (painted.length === 0) continue;
        addPiece("marking", painted, constantHeight(lift + PARK_PAINT_LIFT_M), kindUv(STREET_PAINT_KINDS[kind]));
        for (const key of entry.sources) sources.marking.add(key);
      }
    }
  }
  const parkAt = (point) => parkLayers.find((entry) => inBox(entry.box, point) && entry.index.contains(point)) ?? null;
  // Beds of the park layers with the given materials: whether a point lies on
  // one and how far it is from the nearest bed edge (inside or out), searched
  // within BED_REACH_M; for planting drifts (tools/lib/street-planting-generation.mjs).
  const BED_REACH_M = 8;
  const BED_CELL_M = 2;
  // Each cell lists the bed edges that come within BED_EDGE_MARGIN_M of it: a
  // cell that lists none lies wholly on a bed or wholly off it.
  const BED_EDGE_MARGIN_M = 0.001;
  const bedIndexes = new Map();
  // A rule passes the same materials list on every call: look it up by the list.
  const bedIndexesByList = new WeakMap();
  const bedIndex = (materials) => {
    const known = bedIndexesByList.get(materials);
    if (known) return known;
    const key = [...materials].sort().join("|");
    if (!bedIndexes.has(key)) {
      const parts = parkLayers.filter((entry) => materials.includes(entry.layer.material)).map((entry) => entry.polygon);
      const region = union(`park beds ${key}`, parts);
      const cells = new Map();
      for (const polygon of region) {
        for (const raw of polygon) {
          const ring = openRing(raw);
          ring.forEach((a, index) => {
            const b = ring[(index + 1) % ring.length];
            // In pieces of at most half a cell, so a long diagonal edge lists
            // only in the cells along it, not across its whole bounding box.
            const edge = sub(b, a);
            const pieces = Math.max(1, Math.ceil(length(edge) / (BED_CELL_M / 2)));
            const touched = new Set();
            for (let piece = 0; piece < pieces; piece += 1) {
              const p = add(a, scale(edge, piece / pieces));
              const q = piece + 1 === pieces ? b : add(a, scale(edge, (piece + 1) / pieces));
              for (let i = Math.floor((Math.min(p[0], q[0]) - BED_EDGE_MARGIN_M) / BED_CELL_M); i <= Math.floor((Math.max(p[0], q[0]) + BED_EDGE_MARGIN_M) / BED_CELL_M); i += 1) {
                for (let j = Math.floor((Math.min(p[1], q[1]) - BED_EDGE_MARGIN_M) / BED_CELL_M); j <= Math.floor((Math.max(p[1], q[1]) + BED_EDGE_MARGIN_M) / BED_CELL_M); j += 1) touched.add(`${i},${j}`);
              }
            }
            for (const cell of touched) {
              if (!cells.has(cell)) cells.set(cell, []);
              cells.get(cell).push([a, b]);
            }
          });
        }
      }
      // Whether each cell that lists no edge lies on the bed, from its first query.
      bedIndexes.set(key, { index: polygonIndex(region), cells, wholeCells: new Map() });
    }
    bedIndexesByList.set(materials, bedIndexes.get(key));
    return bedIndexes.get(key);
  };
  // Whether a point lies on a bed of the given materials (parkBed's "on" alone).
  const parkBedOn = (point, materials) => {
    const { index, cells, wholeCells } = bedIndex(materials);
    const cell = `${Math.floor(point[0] / BED_CELL_M)},${Math.floor(point[1] / BED_CELL_M)}`;
    if (cells.has(cell)) return index.contains(point);
    if (!wholeCells.has(cell)) wholeCells.set(cell, index.contains(point));
    return wholeCells.get(cell);
  };
  const parkBed = (point, materials) => {
    const { cells } = bedIndex(materials);
    const ci = Math.floor(point[0] / BED_CELL_M);
    const cj = Math.floor(point[1] / BED_CELL_M);
    let best = BED_REACH_M;
    for (let ring = 0; ring * BED_CELL_M <= BED_REACH_M; ring += 1) {
      if ((ring - 1) * BED_CELL_M > best) break;
      for (let di = -ring; di <= ring; di += 1) {
        for (let dj = -ring; dj <= ring; dj += 1) {
          if (Math.max(Math.abs(di), Math.abs(dj)) !== ring) continue;
          for (const [a, b] of cells.get(`${ci + di},${cj + dj}`) ?? []) {
            const edge = sub(b, a);
            const t = Math.max(0, Math.min(1, dot(sub(point, a), edge) / Math.max(1e-12, dot(edge, edge))));
            best = Math.min(best, length(sub(point, add(a, scale(edge, t)))));
          }
        }
      }
    }
    return { on: parkBedOn(point, materials), distance: best };
  };

  // ---------------------------------------------------------------- drape
  const meshes = new Map();
  const meshFor = (record, id) => {
    const key = `${record}|${id}`;
    if (!meshes.has(key)) meshes.set(key, { record, chunk: id, vertices: [], normals: [], uvs: [], indices: [] });
    return meshes.get(key);
  };
  const chunkRange = (box) => {
    const ids = [];
    for (let x = Math.floor(box.min_x / CHUNK_SIZE_M); x <= Math.floor(box.max_x / CHUNK_SIZE_M); x += 1) {
      for (let z = Math.floor(-box.max_y / CHUNK_SIZE_M); z <= Math.floor(-box.min_y / CHUNK_SIZE_M); z += 1) ids.push({ x, z, id: chunkId(x, z) });
    }
    return ids;
  };
  const facetCache = new Map();
  const facetsOf = (id) => {
    if (!facetCache.has(id)) facetCache.set(id, facetsForChunk(id));
    return facetCache.get(id);
  };
  const facetGradient = (facet) => {
    const origin = facetElevation(facet, 0, 0).elevation;
    return [facetElevation(facet, 1, 0).elevation - origin, facetElevation(facet, 0, 1).elevation - origin];
  };
  const drape = (piece) => {
    for (const chunk of chunkRange(boxOfMulti(piece.polygon))) {
      const rect = [[[[chunk.x * CHUNK_SIZE_M, -(chunk.z + 1) * CHUNK_SIZE_M], [(chunk.x + 1) * CHUNK_SIZE_M, -(chunk.z + 1) * CHUNK_SIZE_M], [(chunk.x + 1) * CHUNK_SIZE_M, -chunk.z * CHUNK_SIZE_M], [chunk.x * CHUNK_SIZE_M, -chunk.z * CHUNK_SIZE_M]]]];
      const inChunk = intersect("piece chunk", piece.polygon, rect);
      if (multiArea(inChunk) < 1e-6) continue;
      const box = boxOfMulti(inChunk);
      for (const facet of facetsOf(chunk.id)) {
        if (!boxesOverlap(facet.bounds, box, 1e-6)) continue;
        const part = intersect("piece facet", inChunk, facet.geometry);
        if (multiArea(part) < 1e-6) continue;
        const gradient = facetGradient(facet);
        const surface = [gradient[0] + piece.height.he, gradient[1] + piece.height.hn];
        const normalLength = Math.hypot(surface[0], 1, surface[1]);
        const normal = [-surface[0] / normalLength, 1 / normalLength, surface[1] / normalLength];
        const mesh = meshFor(piece.record, chunk.id);
        for (const polygon of part) {
          const rings = polygon.map(openRing).filter((ring) => ring.length >= 3);
          if (rings.length === 0) continue;
          const flat = [];
          const holes = [];
          const points = [];
          rings.forEach((ring, ringIndex) => {
            if (ringIndex > 0) holes.push(points.length);
            for (const point of ring) {
              flat.push(point[0], point[1]);
              points.push(point);
            }
          });
          const triangles = earcut(flat, holes, 2);
          const offset = mesh.vertices.length / 3;
          for (const point of points) {
            const land = facetElevation(facet, point[0], point[1]).elevation;
            mesh.vertices.push(roundCoordinate(point[0]), roundCoordinate(land + heightAt(piece.height, point)), roundCoordinate(-point[1]));
            mesh.normals.push(...((piece.smooth && normalAt?.(point[0], point[1])) || normal).map(roundCoordinate));
            mesh.uvs.push(...piece.uv(point).map(roundCoordinate));
          }
          pushTriangles(mesh, triangles.map((index) => index + offset), normal);
        }
      }
    }
  };
  for (const piece of pieces) drape(piece);

  // Curb faces: vertical quads from the road surface to the raised edge, split
  // where the land under them changes triangle.
  for (const edge of faces) {
    const edgeTop = (point) => edge.ha + (edge.hb - edge.ha) * (length(sub(point, edge.a)) / Math.max(1e-9, length(sub(edge.b, edge.a))));
    if (Math.max(edge.ha, edge.hb) - ROAD_TOP_M < 0.01) continue;
    for (const chunk of chunkRange(boxOfPoints([edge.a, edge.b]))) {
      const facets = facetsOf(chunk.id);
      const fractions = [0, 1];
      for (const facet of facets) {
        if (!boxesOverlap(facet.bounds, boxOfPoints([edge.a, edge.b]), 1e-6)) continue;
        fractions.push(...segmentPolygonCrossings(edge.a, edge.b, facet.geometry));
      }
      const unique = [...new Set(fractions.map((value) => Math.round(value * 1e9) / 1e9))].sort((left, right) => left - right);
      for (let index = 1; index < unique.length; index += 1) {
        const p0 = add(edge.a, scale(sub(edge.b, edge.a), unique[index - 1]));
        const p1 = add(edge.a, scale(sub(edge.b, edge.a), unique[index]));
        if (length(sub(p1, p0)) < 0.005) continue;
        const middle = scale(add(p0, p1), 0.5);
        const chunkOfMiddle = chunkId(Math.floor(middle[0] / CHUNK_SIZE_M), Math.floor(-middle[1] / CHUNK_SIZE_M));
        if (chunkOfMiddle !== chunk.id) continue;
        const facet = facets.find((candidate) => inBox(candidate.bounds, middle, 1e-6) && facetElevation(candidate, middle[0], middle[1]).inside);
        if (!facet) continue;
        const mesh = meshFor("kerb", chunk.id);
        const normal = [edge.outward[0], 0, -edge.outward[1]];
        const offset = mesh.vertices.length / 3;
        const along0 = length(sub(p0, edge.a));
        const along1 = length(sub(p1, edge.a));
        const corners = [
          [p0, ROAD_TOP_M, along0],
          [p1, ROAD_TOP_M, along1],
          [p1, edgeTop(p1), along1],
          [p0, edgeTop(p0), along0],
        ];
        for (const [point, h, along] of corners) {
          const land = facetElevation(facet, point[0], point[1]).elevation;
          mesh.vertices.push(roundCoordinate(point[0]), roundCoordinate(land + h), roundCoordinate(-point[1]));
          mesh.normals.push(...normal.map(roundCoordinate));
          // v from the face's own foot, inside one panel: no sidewalk joint runs along a curb face.
          mesh.uvs.push(roundCoordinate(along / kerb.panel_m), roundCoordinate((h - ROAD_TOP_M) / kerb.panel_m + 0.1));
        }
        pushTriangles(mesh, [offset, offset + 1, offset + 2, offset, offset + 2, offset + 3], normal);
      }
    }
  }

  // ---------------------------------------------------------------- records
  const records = new Map();
  for (const mesh of [...meshes.values()].sort((left, right) => compareChunkIds(left.chunk, right.chunk) || left.record.localeCompare(right.record))) {
    if (mesh.indices.length === 0) continue;
    const [prefix, featureKind, materialKey, collisionKind, opaque] = RECORD_KINDS[mesh.record];
    const sourceKeys = [...sources[mesh.record]].sort(compareSourceKeys);
    invariant(sourceKeys.length > 0, `Street ground ${mesh.record} in ${mesh.chunk} has no source`);
    const record = meshRecord({
      objectKey: `${prefix}:${mesh.chunk}`,
      featureKind,
      sourceKeys,
      materialKey,
      mesh,
      collisionKind,
      opaque,
    });
    // Park ground is drawn its lift over the land: what the player's feet and
    // props stand on (VisibleGround), though the land is what collides.
    if (parkLifts.has(materialKey)) record.surface_bias_m = parkLifts.get(materialKey);
    if (!records.has(mesh.chunk)) records.set(mesh.chunk, []);
    records.get(mesh.chunk).push(record);
  }

  // The raised surface under a world point, for placing street-detail items on it.
  const surfaceAt = (xz) => {
    const point = [xz[0], -xz[1]];
    const park = parkAt(point);
    if (park) return { kind: "street_paint", material_key: park.layer.material, source_key: park.sources[0], bias_m: roundCoordinate(park.lift) };
    for (const notch of notches) {
      if (notchIndex.contains(point) && pointInMultiCheap(notch.piece, point)) {
        return { kind: "street_kerb", material_key: "street_kerb_concrete", source_key: notch.source_key, bias_m: roundCoordinate(heightAt(notch.height, point)) };
      }
    }
    if (!raisedIndex.contains(point)) {
      // Parking lanes widen the asphalt beyond the frozen road ribbons.
      if (!parkingIndex.contains(point)) return null;
      return { kind: "street_paint", material_key: "street_parking", source_key: nearestRoad(point).road.row.source_key, bias_m: ROAD_TOP_M };
    }
    const near = nearestRoad(point);
    return {
      kind: "street_kerb",
      material_key: plantedIndex.contains(point) ? "street_kerb_planting" : paverIndex.contains(point) ? "street_plaza_pavers" : "street_kerb_concrete",
      source_key: near ? near.road.row.source_key : [...kerbSources][0],
      bias_m: roundCoordinate(top),
    };
  };

  const summary = {
    generator: "tools/lib/street-ground-generation.mjs",
    feature_kinds: STREET_GROUND_FEATURE_KINDS,
    paint_kinds: STREET_PAINT_KINDS,
    wear_cells: STREET_WEAR_CELLS,
    heights_m: {
      road_surface: ROAD_TOP_M,
      sidewalk_top: roundCoordinate(top),
      gutter: roundCoordinate(ROAD_TOP_M + lifts.gutter_m),
      paint: roundCoordinate(ROAD_TOP_M + lifts.paint_m),
    },
    zones: settings.zones.map(({ id }) => id),
    kerbed_roads: [...kerbSources].sort(compareSourceKeys),
    joined_sidewalks: joinedSidewalks.sort(compareSourceKeys),
    counts: {
      crosswalks: counts.crosswalks,
      curb_ramps: counts.curb_ramps,
      stop_bars: counts.stop_bars,
      stall_lines: counts.stall_lines,
      centerline_m: roundCoordinate(counts.centerline_m),
      raised_area_m2: roundCoordinate(multiArea(bandRaised)),
      planted_area_m2: roundCoordinate(multiArea(plantedTop)),
      plaza_paving_area_m2: roundCoordinate(multiArea(paverTop)),
      parking_lane_area_m2: roundCoordinate(multiArea(parkingSurface)),
      curb_face_m: roundCoordinate(faces.reduce((sum, edge) => sum + length(sub(edge.b, edge.a)), 0)),
      wear_by_cell: Object.fromEntries(Object.entries(STREET_WEAR_CELLS).map(([name, cell]) => [name, counts.wear[cell] ?? 0])),
      park_surface_area_m2: Object.fromEntries(Object.keys(PARK_SURFACE_MATERIALS).map((material) => [material,
        roundCoordinate(parkLayers.filter((entry) => entry.layer.material === material).reduce((sum, entry) => sum + multiArea(entry.polygon), 0))])),
    },
    records: [...records.entries()].sort(([left], [right]) => compareChunkIds(left, right))
      .flatMap(([, list]) => list.map((record) => ({ object_key: record.object_key, triangles: record.indices.length / 3 }))),
  };
  // Plan geometry for the street furniture that stands on and beside this
  // ground (tools/lib/street-furniture-generation.mjs), in the east/north frame.
  const distanceTo = (index, point, reach) => {
    if (index.contains(point)) return 0;
    let best = Infinity;
    for (const polygon of index.near({ min_x: point[0], min_y: point[1], max_x: point[0], max_y: point[1] }, reach)) {
      for (const raw of polygon) {
        const ring = openRing(raw);
        for (let at = 0; at < ring.length; at += 1) {
          const a = ring[at];
          const edge = sub(ring[(at + 1) % ring.length], a);
          const fraction = Math.max(0, Math.min(1, dot(sub(point, a), edge) / Math.max(1e-12, dot(edge, edge))));
          best = Math.min(best, length(sub(point, add(a, scale(edge, fraction)))));
        }
      }
    }
    return best;
  };
  const rampIndex = polygonIndex(notchUnion);
  const site = {
    top_m: roundCoordinate(top),
    walk_width_m: crossings.walk_width_m,
    kerb_roads: kerbRoads.map((road) => ({
      source_key: road.row.source_key,
      name: road.tags.name ?? null,
      highway: road.tags.highway,
      line: wayLine(road),
      kerb_offset_m: halfWidth(road),
    })),
    crosswalks: crosswalks.map((walk) => ({ ...walk })),
    stop_bars: stopBars,
    // OSM parking lots near the pilot: multipolygons in the east/north frame.
    lots: lots.map((object) => ({ source_key: object.row.source_key, geometry: object.geometry })),
    // Plan distance (m) to the carriageway (0 inside it), searched within reach.
    carriagewayDistance: (point, reach = 12) => distanceTo(vehicleIndex, point, reach),
    // Plan distance (m) to a curb ramp (0 inside it), searched within reach.
    rampDistance: (point, reach = 6) => distanceTo(rampIndex, point, reach),
    // On the raised street ground: sidewalk, planting strip or plaza top.
    raised: (point) => raisedIndex.contains(point),
    // A park bed of the given materials under an east/north point: {on, distance to its edge}.
    parkBed,
    parkBedOn,
    // Parking lanes: the roads that have them, with the curb's offset from the
    // centre line on both sides (the frozen ribbon's half width plus the lane).
    parking_lanes: [...parkingWidth.entries()].sort(([left], [right]) => compareSourceKeys(left, right)).map(([key, width]) => {
      const road = vehicles.find((object) => object.row.source_key === key);
      return { source_key: key, line: wayLine(road), ribbon_half_m: ROAD_WIDTHS_M[road.tags.highway] / 2, lane_width_m: width, kerb_offset_m: halfWidth(road) };
    }),
    // Painted parking stalls: the entry point on the aisle edge, the direction
    // into the stall, along the aisle, the stall depth and width.
    stalls: stallSlots,
    // Inside an OSM parking lot near the pilot.
    inLot: (point) => lotIndex.contains(point),
  };
  return { records, summary, surfaceAt, site };
}

function pointInMultiCheap(multi, point) {
  return multi.some((polygon) => pointInPolygon(point, polygon));
}

function pushTriangles(mesh, indices, desiredNormal) {
  const vertex = (index) => mesh.vertices.slice(index * 3, index * 3 + 3);
  for (let offset = 0; offset < indices.length; offset += 3) {
    let [a, b, c] = indices.slice(offset, offset + 3);
    const pa = vertex(a);
    const pb = vertex(b);
    const pc = vertex(c);
    const ab = [pb[0] - pa[0], pb[1] - pa[1], pb[2] - pa[2]];
    const ac = [pc[0] - pa[0], pc[1] - pa[1], pc[2] - pa[2]];
    const normal = [ab[1] * ac[2] - ab[2] * ac[1], ab[2] * ac[0] - ab[0] * ac[2], ab[0] * ac[1] - ab[1] * ac[0]];
    if (Math.hypot(...normal) / 2 < MINIMUM_TRIANGLE_AREA_M2) continue;
    if (normal[0] * desiredNormal[0] + normal[1] * desiredNormal[1] + normal[2] * desiredNormal[2] < 0) [b, c] = [c, b];
    mesh.indices.push(a, b, c);
  }
}
