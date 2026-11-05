// Street clutter: the movable things of PlayableWorld/StreetDetail/Clutter.
//
// Parked cars come from the "clutter" rules of tools/config/street-detail-zones.json
// (photographed cones and barricades are set pieces, data/street_detail/set_pieces.json):
//   - curb_parking: cars along the curbs of the street ground's parking lanes,
//     side by side stretches each filled at its own ratio; the curb stays clear
//     at junctions, crosswalks (daylighting), fire hydrants and bus stops;
//   - lot_stalls: the painted stalls of an OSM parking lot, filled at a ratio
//     that falls from fill_near beside a named building to fill_far away from it.
// Both are production inference from dated photos (each rule names them); the
// body type, paint and finish of each car are drawn from the rule's mix, seeded
// by the row id. Rows are deterministic and checked against the shared
// gameplay mask with the car's footprint.
//
// Plan geometry is east/north (the ground generator's frame); rows use world
// x, z with z = -north. A car's front is its local -Z.

import { createHash } from "node:crypto";

import { projectLonLat } from "./coordinates.mjs";
import { pointInMultiPolygon } from "./osm-geometry.mjs";
import { carBodyGeometry, CAR_BODIES } from "./street-clutter-kit.mjs";
import { YARD_KIT_KEYS } from "./street-yard-kit.mjs";
import { compareSourceKeys, invariant, roundCoordinate } from "./world-contract.mjs";

// Kit props of the clutter layer, with the row kind each one stands for: the
// street-clutter kit's, and the yard kit's (tools/lib/street-yard-kit.mjs),
// each the kind of its own name.
export const STREET_CLUTTER_PROPS = Object.freeze({
  barricade: "barricade",
  parked_car: "parked_car",
  traffic_cone: "traffic_cone",
  ...Object.fromEntries(YARD_KIT_KEYS.map((key) => [key, key])),
});
export const STREET_CLUTTER_PATTERNS = Object.freeze(["curb_parking", "lot_stalls"]);
export const CAR_BODY_NAMES = Object.freeze(Object.keys(CAR_BODIES));
export const CAR_PAINTS = Object.freeze(["beige", "black", "blue", "brown", "dark_grey", "green", "grey", "light_grey", "navy", "pearl_white", "red", "silver", "white"]);
export const CAR_FINISHES = Object.freeze(["solid", "metallic", "pearl"]);
// Finishes a paint comes in (first is the commonest).
const PAINT_FINISHES = Object.freeze({
  beige: ["metallic"],
  black: ["metallic", "solid"],
  blue: ["metallic", "pearl"],
  brown: ["metallic"],
  dark_grey: ["metallic"],
  green: ["metallic", "solid"],
  grey: ["metallic", "solid"],
  light_grey: ["metallic"],
  navy: ["metallic", "pearl"],
  pearl_white: ["pearl"],
  red: ["pearl", "solid", "metallic"],
  silver: ["metallic"],
  white: ["solid"],
});
const RULE_FIELDS = Object.freeze({
  curb_parking: ["source_keys", "sides", "curb_gap_m", "gap_m", "daylight_m", "hydrant_m"],
  lot_stalls: ["source_keys", "near_key", "near_m", "far_m", "fill_near", "fill_far", "head_in"],
});
const COMMON_FIELDS = Object.freeze(["basis", "evidence", "id", "kind", "mix", "paints", "pattern", "prop", "rule"]);
const SAFE_ID = /^[a-z0-9_]+$/u;
// A car's footprint for the shared mask: a stadium that holds its rectangle
// (radius this far beyond its half width, the straight part shortened to fit).
const FOOTPRINT_EXTRA_M = 0.1;
// Clear space kept between a car and what stands near it:
//   - ITEM_CLEAR_M, the player's width, from a built prop (one with a kit prop,
//     so it collides) on the car's own walking level (the road, a parking lane or
//     the lot) and from every fence run, so no gap beside a car pinches shut;
//   - OTHER_LEVEL_CLEAR_M between a curbside car (on the road, below the curb)
//     and a built prop standing on the raised street ground behind the curb (a
//     lamp post or a sign on the sidewalk or verge): the two are on different
//     walking levels, so there is no pinch (the player walks the sidewalk on the
//     prop's far side or stays in the road) and the margin only keeps the meshes
//     apart, as along a real curb;
//   - DATA_ROW_CLEAR_M from data-only rows (placeholder slots, unbuilt OSM
//     features), which have no collision.
// Cars are not checked against each other: stall neighbours and curb gaps have
// their own rules.
const ITEM_CLEAR_M = 0.7;
const OTHER_LEVEL_CLEAR_M = 0.15;
const DATA_ROW_CLEAR_M = 0.15;
// Paints a van comes in (the rule's weights, these only).
const VAN_PAINTS = Object.freeze(["black", "dark_grey", "grey", "silver", "white"]);
const pickFrom = (weights, names) => Object.fromEntries(Object.entries(weights).filter(([name]) => names.includes(name)));
// Bus stops keep this much curb clear on each side.
const BUS_STOP_CLEAR_M = 12;
// A car in a lot stall stops 0.3 m short of the stall's back; a body longer
// than that pulls in to 0.1 m (over the curb stop) and may reach out into the
// aisle up to LOT_OVERHANG_M, as the photographed utility trucks do.
const LOT_BACK_GAP_M = 0.3;
const LOT_LONG_BACK_GAP_M = 0.1;
const LOT_OVERHANG_M = 1.3;
// Chunk record kinds the visible ground is made of, and the surfaces (by
// material) a parked car's tyre may stand on.
const VISIBLE_GROUND_KINDS = new Set(["land_ground", "major_area", "road_path", "street_kerb", "street_paint", "terrain_overlay"]);
const WHEEL_SURFACES = new Set(["major_area_paved", "road_path", "street_gutter", "street_marking", "street_parking", "street_wear"]);
const GROUND_CELL_M = 4;
// A tyre's contact patch, sampled across its width (fractions) and along it (m).
const PATCH_ACROSS = Object.freeze([-0.35, 0, 0.35]);
const PATCH_ALONG_M = Object.freeze([-0.08, 0, 0.08]);
// Suspension travel a parked car may use to keep all four tyres down (m).
export const MAX_TWIST_M = 0.04;

const sub = (a, b) => [a[0] - b[0], a[1] - b[1]];
const add = (a, b) => [a[0] + b[0], a[1] + b[1]];
const scale = (a, s) => [a[0] * s, a[1] * s];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1];
const length = (a) => Math.hypot(a[0], a[1]);
const unit = (a) => {
  const l = length(a);
  invariant(l > 1e-9, "Street clutter direction has no length");
  return [a[0] / l, a[1] / l];
};
const leftOf = (d) => [-d[1], d[0]];
const toWorld = (en) => [en[0], -en[1]];
const toEastNorth = (xz) => [xz[0], -xz[1]];
const isFiniteNumber = (value) => typeof value === "number" && Number.isFinite(value);

function polylineLength(points) {
  let total = 0;
  for (let index = 1; index < points.length; index += 1) total += length(sub(points[index], points[index - 1]));
  return total;
}

function pointAlong(points, s) {
  let walked = 0;
  for (let index = 1; index < points.length; index += 1) {
    const segment = length(sub(points[index], points[index - 1]));
    if (segment <= 1e-9) continue;
    if (walked + segment >= s || index === points.length - 1) {
      const fraction = Math.max(0, Math.min(1, (s - walked) / segment));
      return { point: add(points[index - 1], scale(sub(points[index], points[index - 1]), fraction)), tangent: unit(sub(points[index], points[index - 1])) };
    }
    walked += segment;
  }
  invariant(false, "pointAlong on a degenerate polyline");
  return null;
}

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
    if (!best || distance < best.distance) best = { point: closest, distance, along: walked + fraction * segment, tangent: scale(delta, 1 / segment), side: Math.sign(dot(sub(point, closest), leftOf(scale(delta, 1 / segment)))) };
    walked += segment;
  }
  return best;
}

// Yaw that turns the local -Z front toward the east/north direction d.
function yawToward(d) {
  return roundCoordinate(Math.atan2(-d[0], d[1]));
}

function hashUnit(seed, identity, slot) {
  const bytes = createHash("sha256").update(`${seed}|${identity}|${slot}`, "utf8").digest();
  return bytes.readUInt32BE(0) / 0xffffffff;
}

function pickWeighted(weights, u) {
  const entries = Object.entries(weights).sort(([left], [right]) => (left < right ? -1 : left > right ? 1 : 0));
  const total = entries.reduce((sum, [, weight]) => sum + weight, 0);
  let cursor = u * total;
  for (const [name, weight] of entries) {
    if (cursor < weight) return name;
    cursor -= weight;
  }
  return entries.at(-1)[0];
}

function validateWeights(weights, allowed, label) {
  invariant(weights != null && typeof weights === "object" && !Array.isArray(weights) && Object.keys(weights).length > 0, `${label} must be a non-empty object`);
  for (const [name, weight] of Object.entries(weights)) {
    invariant(allowed.includes(name), `${label} names unknown ${name}`);
    invariant(isFiniteNumber(weight) && weight > 0, `${label} ${name} weight must be positive`);
  }
}

export function validateClutterRules(zone, kinds) {
  if (zone.clutter == null) return;
  invariant(Array.isArray(zone.clutter), `Street detail zone ${zone.id} clutter must be a list`);
  const ids = new Set();
  for (const rule of zone.clutter) {
    const label = `Street detail zone ${zone.id} clutter rule ${rule?.id}`;
    invariant(typeof rule?.id === "string" && SAFE_ID.test(rule.id) && !ids.has(rule.id), `${label} needs a unique lower_snake id`);
    ids.add(rule.id);
    invariant(STREET_CLUTTER_PATTERNS.includes(rule.pattern), `${label} pattern must be one of ${STREET_CLUTTER_PATTERNS.join(", ")}`);
    const allowed = [...COMMON_FIELDS, ...RULE_FIELDS[rule.pattern]].sort();
    invariant(Object.keys(rule).every((key) => allowed.includes(key)), `${label} has fields outside ${allowed.join(", ")}`);
    invariant([...COMMON_FIELDS, ...RULE_FIELDS[rule.pattern]].every((key) => key in rule), `${label} needs ${[...COMMON_FIELDS, ...RULE_FIELDS[rule.pattern]].join(", ")}`);
    invariant(rule.prop === "parked_car" && rule.kind === "parked_car" && kinds[rule.kind]?.layer === "clutter", `${label}: clutter rules place parked_car props`);
    invariant(rule.basis === "production_inference", `${label}: rule-based clutter is production_inference`);
    for (const field of ["rule", "evidence"]) invariant(typeof rule[field] === "string" && rule[field].trim() !== "", `${label} needs ${field}`);
    validateWeights(rule.mix, CAR_BODY_NAMES, `${label} mix`);
    validateWeights(rule.paints, CAR_PAINTS, `${label} paints`);
    invariant(Array.isArray(rule.source_keys) && rule.source_keys.length > 0 && rule.source_keys.every((key) => /^w\d+$/u.test(key)), `${label} needs OSM way source_keys`);
    if (rule.pattern === "curb_parking") {
      invariant(rule.sides != null && typeof rule.sides === "object" && Object.keys(rule.sides).every((side) => ["left", "right"].includes(side)), `${label} sides are left and/or right`);
      for (const [side, stretches] of Object.entries(rule.sides)) {
        invariant(Array.isArray(stretches) && stretches.length > 0, `${label} side ${side} needs stretches`);
        let previous = -Infinity;
        for (const stretch of stretches) {
          invariant(Array.isArray(stretch) && stretch.length === 3 && stretch.every(isFiniteNumber) && stretch[0] >= previous && stretch[1] > stretch[0] && stretch[2] >= 0 && stretch[2] <= 1,
            `${label} side ${side} stretches are ordered [from_m, to_m, fill] with fill in [0, 1]`);
          previous = stretch[1];
        }
      }
      invariant(Array.isArray(rule.gap_m) && rule.gap_m.length === 2 && rule.gap_m.every(isFiniteNumber) && rule.gap_m[0] >= 1.0 && rule.gap_m[1] >= rule.gap_m[0],
        `${label} gap_m is [min, max] with min at least 1 m (a player passes between two cars)`);
      for (const field of ["curb_gap_m", "daylight_m", "hydrant_m"]) invariant(isFiniteNumber(rule[field]) && rule[field] >= 0, `${label} ${field} must be non-negative`);
    } else {
      invariant(/^[wr]\d+$/u.test(rule.near_key), `${label} near_key must be an OSM building key`);
      invariant(isFiniteNumber(rule.near_m) && isFiniteNumber(rule.far_m) && rule.far_m > rule.near_m && rule.near_m >= 0, `${label} needs near_m < far_m`);
      for (const field of ["fill_near", "fill_far", "head_in"]) invariant(isFiniteNumber(rule[field]) && rule[field] >= 0 && rule[field] <= 1, `${label} ${field} must be in [0, 1]`);
    }
  }
}

// Plan sizes of the clutter kit's small props, {x_m, z_m} along their local X
// and Z (cars take theirs from the kit's body dimensions).
export const STREET_CLUTTER_FOOTPRINTS = Object.freeze({
  barricade: Object.freeze({ x_m: 0.66, z_m: 0.42 }),
  traffic_cone: Object.freeze({ x_m: 0.36, z_m: 0.36 }),
});

// The plan footprint of a row with a rectangular footprint ({x_m, z_m} along
// its local X and Z, turned by its yaw) for the shared mask: a stadium (a
// segment along the long side and a radius) that holds the rectangle.
export function footprintPiece(position, yaw, footprint) {
  const long = Math.max(footprint.x_m, footprint.z_m);
  const short = Math.min(footprint.x_m, footprint.z_m);
  const radius = short / 2 + FOOTPRINT_EXTRA_M;
  const half = Math.max(0, long / 2 - Math.sqrt(radius * radius - (short / 2) ** 2));
  // A square footprint is a circle about its point.
  if (half < 1e-6) return { points: [[position[0], position[1]]], radius };
  // Godot yaw about +Y: local X is (cos yaw, -sin yaw), local Z (sin yaw, cos yaw) in world x, z.
  const axis = footprint.x_m >= footprint.z_m ? [Math.cos(yaw), -Math.sin(yaw)] : [Math.sin(yaw), Math.cos(yaw)];
  return {
    points: [
      [position[0] - axis[0] * half, position[1] - axis[1] * half],
      [position[0] + axis[0] * half, position[1] + axis[1] * half],
    ],
    radius,
  };
}

// The top of the visible ground, from the generated chunk records: a function
// of world [x, z] returning {y, material_key} of the highest surface there (the
// draped roads, paint and areas sit their small bias above the land), or null.
// Each chunk is indexed on first use.
export function visibleGroundIndex(chunks) {
  const indexed = new Map();
  const cellKey = (x, z) => `${Math.floor(x / GROUND_CELL_M)},${Math.floor(z / GROUND_CELL_M)}`;
  const indexChunk = (chunk) => {
    const cells = new Map();
    for (const record of chunk.records) {
      if (!VISIBLE_GROUND_KINDS.has(record.feature_kind)) continue;
      const vertices = record.vertices;
      for (let offset = 0; offset < record.indices.length; offset += 3) {
        const corners = [0, 1, 2].map((corner) => {
          const index = record.indices[offset + corner] * 3;
          return [vertices[index], vertices[index + 1], vertices[index + 2]];
        });
        const [a, b, c] = corners;
        const denominator = (b[2] - c[2]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[2] - c[2]);
        // Vertical faces (kerb sides) hold no plan area.
        if (Math.abs(denominator) <= 1e-10) continue;
        const triangle = { a, b, c, denominator, material_key: record.material_key };
        const xs = corners.map((point) => point[0]);
        const zs = corners.map((point) => point[2]);
        for (let x = Math.floor(Math.min(...xs) / GROUND_CELL_M); x <= Math.floor(Math.max(...xs) / GROUND_CELL_M); x += 1) {
          for (let z = Math.floor(Math.min(...zs) / GROUND_CELL_M); z <= Math.floor(Math.max(...zs) / GROUND_CELL_M); z += 1) {
            const key = `${x},${z}`;
            if (!cells.has(key)) cells.set(key, []);
            cells.get(key).push(triangle);
          }
        }
      }
    }
    return cells;
  };
  return (xz) => {
    let best = null;
    for (const chunk of chunks.values()) {
      const bounds = chunk.bounds_m;
      if (xz[0] < bounds.min_x || xz[0] > bounds.max_x || xz[1] < bounds.min_z || xz[1] > bounds.max_z) continue;
      if (!indexed.has(chunk.chunk_id)) indexed.set(chunk.chunk_id, indexChunk(chunk));
      for (const { a, b, c, denominator, material_key } of indexed.get(chunk.chunk_id).get(cellKey(xz[0], xz[1])) ?? []) {
        const weightA = ((b[2] - c[2]) * (xz[0] - c[0]) + (c[0] - b[0]) * (xz[1] - c[2])) / denominator;
        const weightB = ((c[2] - a[2]) * (xz[0] - c[0]) + (a[0] - c[0]) * (xz[1] - c[2])) / denominator;
        const weightC = 1 - weightA - weightB;
        if (weightA < -1e-7 || weightB < -1e-7 || weightC < -1e-7) continue;
        const y = weightA * a[1] + weightB * b[1] + weightC * c[1];
        if (!best || y > best.y || (y === best.y && material_key < best.material_key)) best = { y, material_key };
      }
    }
    return best;
  };
}

// A parked car's rest on the visible ground (east/north centre and front). The
// body takes the plane through the ground under its four tyre centres (its
// height at the car's origin, pitch raising the nose, roll the left side) and
// the suspension takes up the twist a plane cannot: the front-left and
// rear-right wheels rise by it in the car frame, the other two drop by it.
// Then the car rises by the most that any point of a tyre's contact patch (a
// gutter lip, a paint line, a fold in the ground) reaches into that tyre's
// round tread, so no tyre sinks. Returns {height, pitch, roll, twist}, or {problem}
// when a tyre is off the pavement or the ground is too uneven.
export function settleParkedCar(body, center, front, groundAt) {
  const geometry = carBodyGeometry(body);
  const right = [front[1], -front[0]];
  // The visible ground under a car-frame point (x right, z back).
  const groundUnder = (x, z) => {
    const ground = groundAt(toWorld(add(add(center, scale(right, x)), scale(front, -z))));
    if (!ground) return { problem: "no_ground" };
    if (!WHEEL_SURFACES.has(ground.material_key)) return { problem: "wheel_off_pavement" };
    return ground;
  };
  const wheels = Object.entries(geometry.wheels).map(([name, [x, , z]]) => ({ name, x, z, side: Math.sign(x) * Math.sign(z) }));
  const centres = {};
  for (const wheel of wheels) {
    const ground = groundUnder(wheel.x, wheel.z);
    if (ground.problem) return ground;
    centres[wheel.name] = ground.y;
  }
  const { front_left: fl, front_right: fr, rear_left: rl, rear_right: rr } = centres;
  const frontZ = geometry.wheels.front_left[2];
  const rearZ = geometry.wheels.rear_left[2];
  // The plane y = height + slopeForward * forward + slopeLeft * left, with
  // forward = -z and left = -x in the car frame.
  const slopeForward = (fl + fr - rl - rr) / (2 * (rearZ - frontZ));
  const slopeLeft = (fl + rl - fr - rr) / (2 * geometry.track_m);
  const height = (fl + fr + rl + rr) / 4 + slopeForward * (frontZ + rearZ) / 2;
  const twist = (fl - fr - rl + rr) / 4;
  if (Math.abs(twist) > MAX_TWIST_M) return { problem: "uneven_ground" };
  const radius = geometry.wheel_radius_m;
  let raise = 0;
  for (const wheel of wheels) {
    for (const along of PATCH_ALONG_M) {
      // The tread curves up away from its lowest line.
      const curve = radius - Math.sqrt(radius * radius - along * along);
      for (const across of PATCH_ACROSS) {
        const x = wheel.x + across * geometry.tire_width_m;
        const z = wheel.z - along;
        const ground = groundUnder(x, z);
        if (ground.problem) return ground;
        raise = Math.max(raise, ground.y - (height - slopeForward * z - slopeLeft * x + twist * wheel.side + curve));
      }
    }
  }
  return { height: height + raise, pitch: Math.atan(slopeForward), roll: Math.atan(slopeLeft), twist };
}

// Places the parked cars of the pilot zones' clutter rules. Returns the rows and an audit.
export function placeStreetClutter({
  kinds,
  rows,
  occupied,
  zoneShapes,
  site,
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
}) {
  const pilotShapes = zoneShapes.filter(({ zone }) => zone.pilot);
  const groundAt = visibleGroundIndex(chunks);
  // Rows the runtime builds (a fence's runs are claimed as "<id>#run<n>"), and the
  // built point props standing on the raised street ground (sidewalk, verge,
  // planting or plaza paving above the curb).
  const builtIds = new Set(rows.filter((row) => row.status === "placed" && row.prop != null).map((row) => row.id));
  const raisedIds = new Set(rows
    .filter((row) => builtIds.has(row.id) && row.geometry === "point" && row.surface?.kind === "street_kerb")
    .map((row) => row.id));
  // The clear space between a car (on the road at the curb, or in the lot) and an occupied item.
  const itemClearance = (item, surface) => {
    const isFenceRun = item.id.includes("#");
    const id = item.id.split("#")[0];
    if (!builtIds.has(id)) return DATA_ROW_CLEAR_M;
    if (surface === "road" && !isFenceRun && raisedIds.has(id)) return OTHER_LEVEL_CLEAR_M;
    return ITEM_CLEAR_M;
  };
  const audit = { rules: {}, rejected_by_reason: {} };
  const count = (table, key) => {
    table[key] = (table[key] ?? 0) + 1;
  };
  const ruleRows = [];

  // The car's rectangle corners in east/north for a centre, a front direction and size.
  const corners = (center, front, footprint) => {
    const right = [front[1], -front[0]];
    const hl = footprint.z_m / 2;
    const hw = footprint.x_m / 2;
    return [[1, 1], [1, -1], [-1, -1], [-1, 1]].map(([a, b]) => add(add(center, scale(front, a * hl)), scale(right, b * hw)));
  };
  // Site checks for one car: the mask, the land, its surface (the asphalt of the
  // carriageway, a parking lane or the lot, never the raised street ground) and
  // clear of placed items.
  const reject = (center, front, footprint, surface) => {
    const xz = toWorld(center);
    const piece = footprintPiece(xz, yawToward(front), footprint);
    if (!onLand(xz, exclusions.land_edge_buffer_m + footprint.z_m / 2)) return "land_edge";
    const hard = hardViolation(hardShapes, piece.points, piece.radius);
    if (hard) return hard.reason;
    if (buildings.nearest(xz, footprint.z_m).distance < footprint.z_m / 2) {
      for (const corner of corners(center, front, footprint)) {
        if (buildings.nearest(toWorld(corner), 0.5).distance < 0.3) return "building";
      }
    }
    for (const corner of corners(center, front, footprint)) {
      if (site.raised(corner)) return "raised_ground";
      if (surface === "road" && site.carriagewayDistance(corner, 1) > 0) return "off_asphalt";
      if (surface === "lot" && !site.inLot(corner) && site.carriagewayDistance(corner, 1) > 0) return "off_lot";
    }
    for (const item of occupied) {
      const clear = itemClearance(item, surface);
      for (const point of piece.points.length > 1 ? sampleSegment(piece.points) : piece.points) {
        const near = item.points.length > 1 ? distanceToPolyline(point, item.points) : Math.hypot(point[0] - item.points[0][0], point[1] - item.points[0][1]);
        if (near < item.radius_m + piece.radius + clear) return "item";
      }
    }
    return null;
  };
  const surfaceRow = (xz) => {
    const { y, support } = grounded(xz);
    return {
      position_m: [xz[0], y, xz[1]],
      terrain_support: { object_key: support.object_key, triangle_index: support.triangle_index, elevation_m: support.elevation_m },
      surface: surfaceAt(xz),
    };
  };
  // The car's body, paint, finish and details, seeded by its row id.
  const carParams = (rule, identity) => {
    const body = pickWeighted(rule.mix, hashUnit(seed, identity, "body"));
    // Work vehicles keep work colours: utility trucks white, vans white, black or grey.
    const paints = body === "utility" ? { white: 1 } : body === "van" ? pickFrom(rule.paints, VAN_PAINTS) : rule.paints;
    const paint = pickWeighted(paints, hashUnit(seed, identity, "paint"));
    const finishes = PAINT_FINISHES[paint];
    const finish = finishes[Math.min(finishes.length - 1, Math.floor(hashUnit(seed, identity, "finish") * (finishes.length + 1)) % finishes.length)];
    const roof = body === "crossover" && !["black", "dark_grey", "navy"].includes(paint) && hashUnit(seed, identity, "roof") < 0.22 ? "black" : "body";
    const rims = hashUnit(seed, identity, "rims") < 0.28 ? "dark" : "alloy";
    return { body, paint, finish, roof, rims };
  };
  // A car at rest (settleParkedCar): the row keeps the land under its middle
  // and that point's top surface; lift takes the body from there to its rest.
  const addCar = (zone, rule, cell, center, front, params, footprint, rest) => {
    const xz = [roundCoordinate(toWorld(center)[0]), roundCoordinate(toWorld(center)[1])];
    const yaw = yawToward(front);
    const ground = surfaceRow(xz);
    const angle = (value) => Math.round(value * 1e4) / 1e4 || 0;
    const row = {
      id: `scatter:${zone.id}:${rule.id}:${cell}`,
      source: "scatter",
      source_id: `zone:${zone.id}/${rule.id}`,
      kind: rule.kind,
      layer: kinds[rule.kind].layer,
      geometry: "point",
      ...ground,
      yaw_radians: yaw,
      yaw_source: `rule:${zone.id}/${rule.id}`,
      status: "placed",
      exclusion: null,
      prop: rule.prop,
      prop_params: {
        ...params,
        pitch: angle(rest.pitch),
        roll: angle(rest.roll),
        lift: roundCoordinate(rest.height - ground.position_m[1] - ground.surface.bias_m),
        twist: roundCoordinate(rest.twist),
      },
      footprint_m: footprint,
      basis: rule.basis,
    };
    ruleRows.push(row);
    count(audit.rules, `${zone.id}/${rule.id}`);
    return row;
  };
  // The site checks, then the rest on the ground; the reason when either fails.
  const fit = (center, front, footprint, surface, body) => {
    const problem = reject(center, front, footprint, surface);
    if (problem) return { problem };
    return settleParkedCar(body, center, front, groundAt);
  };

  // Junction nodes on a road: other vehicle roads sharing one of its nodes.
  const vehicleHighways = new Set(["primary", "secondary", "tertiary", "residential", "unclassified", "service", "living_street"]);
  const roadsAtNode = new Map();
  for (const [id, way] of [...rawOsm.ways.entries()].sort(([left], [right]) => compareSourceKeys(`w${left}`, `w${right}`))) {
    if (!vehicleHighways.has(way.tags?.highway)) continue;
    for (const ref of new Set(way.node_refs)) roadsAtNode.set(ref, [...(roadsAtNode.get(ref) ?? []), `w${id}`]);
  }

  for (const { zone, contains } of pilotShapes) {
    for (const rule of zone.clutter ?? []) {
      if (rule.pattern === "curb_parking") {
        for (const key of rule.source_keys) {
          const lane = site.parking_lanes.find((candidate) => candidate.source_key === key);
          invariant(lane, `Street clutter curb rule names ${key}, which has no parking lane in the street ground`);
          const line = lane.line;
          const total = polylineLength(line);
          const way = rawOsm.ways.get(key.slice(1));
          invariant(way, `Street clutter road ${key} is missing from the raw extract`);
          // Stretches of curb kept clear, as [from, to] along the road, per side.
          const blocked = { left: [], right: [] };
          const both = (from, to) => {
            blocked.left.push([from, to]);
            blocked.right.push([from, to]);
          };
          for (const ref of new Set(way.node_refs)) {
            if ((roadsAtNode.get(ref) ?? []).filter((other) => other !== key).length === 0) continue;
            const node = rawOsm.nodes.get(ref);
            if (!node) continue;
            const near = closestOnPolyline(line, projectLonLat(node.coordinate));
            // Past the crossing road's curb and the daylighting.
            both(near.along - rule.daylight_m - 8, near.along + rule.daylight_m + 8);
          }
          for (const walk of site.crosswalks) {
            const near = closestOnPolyline(line, walk.center);
            if (near.distance > lane.kerb_offset_m + 3) continue;
            both(near.along - site.walk_width_m / 2 - rule.daylight_m, near.along + site.walk_width_m / 2 + rule.daylight_m);
          }
          for (const row of rows) {
            if (row.status !== "placed" || row.geometry !== "point" || !["fire_hydrant", "bus_stop"].includes(row.kind)) continue;
            const near = closestOnPolyline(line, toEastNorth([row.position_m[0], row.position_m[2]]));
            if (near.distance > lane.kerb_offset_m + 4) continue;
            const side = near.side > 0 ? "left" : "right";
            const reach = row.kind === "fire_hydrant" ? rule.hydrant_m : BUS_STOP_CLEAR_M;
            blocked[side].push([near.along - reach, near.along + reach]);
          }
          for (const [sideName, stretches] of Object.entries(rule.sides)) {
            const side = sideName === "left" ? 1 : -1;
            let index = 0;
            for (const [from, to, fill] of stretches) {
              let s = Math.max(0, from);
              const end = Math.min(total, to);
              while (s < end) {
                const cell = `${key}_${sideName}_${String(index).padStart(3, "0")}`;
                const identity = `${zone.id}:${rule.id}:${cell}`;
                const params = carParams(rule, identity);
                const dims = carBodyGeometry(params.body);
                const footprint = { x_m: dims.width_m, z_m: dims.length_m };
                const gap = rule.gap_m[0] + (rule.gap_m[1] - rule.gap_m[0]) * hashUnit(seed, identity, "gap");
                index += 1;
                const startS = s;
                const endS = s + footprint.z_m;
                if (endS > end) break;
                const clash = blocked[sideName].find(([a, b]) => endS > a && startS < b);
                if (clash) {
                  count(audit.rejected_by_reason, `${rule.id}:curb_kept_clear`);
                  s = Math.max(s + 0.5, clash[1] + 0.3);
                  continue;
                }
                const taken = hashUnit(seed, identity, "fill") < fill;
                if (!taken) {
                  count(audit.rejected_by_reason, `${rule.id}:fill`);
                  s = endS + gap;
                  continue;
                }
                const at = pointAlong(line, (startS + endS) / 2);
                // Right-hand traffic: a car faces along the travel of its curb's lane.
                const front = side > 0 ? scale(at.tangent, -1) : at.tangent;
                const offset = lane.kerb_offset_m - rule.curb_gap_m - footprint.x_m / 2 - 0.05 * hashUnit(seed, identity, "offset");
                const center = add(at.point, scale(leftOf(at.tangent), side * offset));
                const xz = toWorld(center);
                if (!contains(xz)) {
                  count(audit.rejected_by_reason, `${rule.id}:outside_zone`);
                  s = endS + gap;
                  continue;
                }
                const jitter = (hashUnit(seed, identity, "yaw") - 0.5) * 0.02;
                const facing = [front[0] * Math.cos(jitter) - front[1] * Math.sin(jitter), front[0] * Math.sin(jitter) + front[1] * Math.cos(jitter)];
                const rest = fit(center, facing, footprint, "road", params.body);
                if (rest.problem) {
                  count(audit.rejected_by_reason, `${rule.id}:${rest.problem}`);
                  s = endS + gap;
                  continue;
                }
                addCar(zone, rule, cell, center, facing, params, footprint, rest);
                s = endS + gap;
              }
            }
          }
        }
      } else if (rule.pattern === "lot_stalls") {
        const near = buildings.items.find((item) => item.key === rule.near_key);
        invariant(near, `Street clutter lot rule names ${rule.near_key}, which is not a building`);
        let stallsInLots = 0;
        const lots = new Set(rule.source_keys);
        for (const stall of site.stalls) {
          const entry = stall.entry;
          const middle = add(entry, scale(stall.outward, stall.depth_m / 2));
          if (!lots.has(lotKeyAt(site, middle, rule.source_keys))) continue;
          stallsInLots += 1;
          if (!contains(toWorld(middle))) continue;
          const cell = `${stall.aisle_key}_${stall.side}_s${String(Math.round(stall.s * 10)).padStart(4, "0")}`;
          const identity = `${zone.id}:${rule.id}:${cell}`;
          const distance = distanceToMultiPolygon(middle, near.geometry);
          const t = Math.max(0, Math.min(1, (distance - rule.near_m) / (rule.far_m - rule.near_m)));
          const fill = rule.fill_near + (rule.fill_far - rule.fill_near) * t;
          if (hashUnit(seed, identity, "fill") >= fill) {
            count(audit.rejected_by_reason, `${rule.id}:fill`);
            continue;
          }
          const params = carParams(rule, identity);
          const dims = carBodyGeometry(params.body);
          const footprint = { x_m: dims.width_m, z_m: dims.length_m };
          const backGap = footprint.z_m > stall.depth_m - LOT_BACK_GAP_M ? LOT_LONG_BACK_GAP_M : LOT_BACK_GAP_M;
          if (footprint.z_m - (stall.depth_m - backGap) > LOT_OVERHANG_M) {
            count(audit.rejected_by_reason, `${rule.id}:too_long`);
            continue;
          }
          const along = (hashUnit(seed, identity, "lateral") - 0.5) * 0.24;
          const center = add(add(entry, scale(stall.outward, stall.depth_m - backGap - footprint.z_m / 2)), scale(stall.along, along));
          const headIn = hashUnit(seed, identity, "head_in") < rule.head_in;
          const jitter = (hashUnit(seed, identity, "yaw") - 0.5) * 0.06;
          const base = headIn ? stall.outward : scale(stall.outward, -1);
          const facing = [base[0] * Math.cos(jitter) - base[1] * Math.sin(jitter), base[0] * Math.sin(jitter) + base[1] * Math.cos(jitter)];
          const rest = fit(center, facing, footprint, "lot", params.body);
          if (rest.problem) {
            count(audit.rejected_by_reason, `${rule.id}:${rest.problem}`);
            continue;
          }
          addCar(zone, rule, cell, center, facing, params, footprint, rest);
        }
        invariant(stallsInLots > 0, `Street clutter lot rule ${rule.id} found no painted stalls in ${rule.source_keys.join(", ")}`);
      }
    }
  }
  return { rows: ruleRows, audit };
}

// The OSM lot (of the given keys) holding an east/north point, or null.
function lotKeyAt(site, point, keys) {
  for (const key of keys) {
    const lot = site.lots.find((candidate) => candidate.source_key === key);
    invariant(lot, `Street clutter lot ${key} is not a parking lot near the pilot`);
    if (pointInMultiPolygon(point, lot.geometry, false)) return key;
  }
  return null;
}

// Plan distance from an east/north point to a multipolygon (0 inside).
function distanceToMultiPolygon(point, geometry) {
  if (pointInMultiPolygon(point, geometry, true)) return 0;
  let best = Infinity;
  for (const polygon of geometry) {
    for (const ring of polygon) best = Math.min(best, distanceToPolyline(point, [...ring, ring[0]]));
  }
  return best;
}

function distanceToPolyline(point, points) {
  let best = Infinity;
  for (let index = 1; index < points.length; index += 1) {
    const a = points[index - 1];
    const d = sub(points[index], a);
    const l2 = dot(d, d);
    const f = l2 > 0 ? Math.max(0, Math.min(1, dot(sub(point, a), d) / l2)) : 0;
    best = Math.min(best, length(sub(point, add(a, scale(d, f)))));
  }
  return best;
}

// Points every 0.5 m along a two-point segment, ends included.
function sampleSegment(points) {
  const [a, b] = points;
  const steps = Math.max(1, Math.ceil(length(sub(b, a)) / 0.5));
  return Array.from({ length: steps + 1 }, (_, index) => add(a, scale(sub(b, a), index / steps)));
}
