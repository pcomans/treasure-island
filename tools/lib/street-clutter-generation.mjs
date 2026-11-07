// Street clutter: the movable things of PlayableWorld/StreetDetail/Clutter.
//
// Parked cars and bus-stop cans come from the "clutter" rules of
// tools/config/street-detail-zones.json (photographed cones, barricades and
// dumpsters are set pieces, data/street_detail/set_pieces.json):
//   - curb_parking: cars along the curbs of the street ground's parking lanes,
//     side by side stretches each filled at its own ratio; the curb stays clear
//     at junctions, crosswalks (daylighting), fire hydrants and bus stops;
//   - curb_stretches: the same along every stretch the street ground marks
//     parked, with the number of cars the dated aerial shows per way side;
//   - bay_occupancy: the street ground's street-side bays, with the aerial's
//     number of cars per way side;
//   - bus_stop_bins: a litter can beside every OSM bus stop with a shelter or
//     a bin that has no OSM basket of its own;
//   - lot_stalls: the painted stalls of an OSM parking lot, filled at a ratio
//     that falls from fill_near beside a named building to fill_far away from it;
//   - lot_occupancy: the OSM parking lots across the island, each with the
//     number of cars the dated aerial shows in it. A lot's stalls are its
//     painted ones where the street ground has them, else stalls laid along its
//     OSM parking aisles as the ground paints them (or along its edges where no
//     aisle is mapped); drivers take the stalls nearest where the aerial shows
//     the lot's cars gathered (its focus points), else nearest a building, with
//     some scatter, so a part-full lot fills from there out.
// All are production inference from dated photos or aerials (each rule names
// them); the body type, paint and finish of each car are drawn from the rule's
// mix, seeded by the row id. Rows are deterministic and checked against the
// shared gameplay mask with the car's footprint, and keep clear of the OSM
// building entrances.
//
// Plan geometry is east/north (the ground generator's frame); rows use world
// x, z with z = -north. A car's front is its local -Z.

import { createHash } from "node:crypto";

import { projectLonLat } from "./coordinates.mjs";
import { pointInMultiPolygon } from "./osm-geometry.mjs";
import { carBodyGeometry, CAR_BODIES } from "./street-clutter-kit.mjs";
import { STREET_VEGETATION_PROPS } from "./street-vegetation-generation.mjs";
import { YARD_KIT_KEYS } from "./street-yard-kit.mjs";
import { compareSourceKeys, invariant, roundCoordinate } from "./world-contract.mjs";

// Kit props of the clutter layer, with the row kind each one stands for: the
// street-clutter kit's, and the yard kit's (tools/lib/street-yard-kit.mjs),
// each the kind of its own name.
export const STREET_CLUTTER_PROPS = Object.freeze({
  barricade: "barricade",
  dumpster: "dumpster",
  parked_car: "parked_car",
  stock_tank_planter: "planter",
  traffic_cone: "traffic_cone",
  ...Object.fromEntries(YARD_KIT_KEYS.map((key) => [key, key])),
});
export const STREET_CLUTTER_PATTERNS = Object.freeze(["bay_occupancy", "bus_stop_bins", "curb_parking", "curb_stretches", "lot_occupancy", "lot_stalls"]);
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
  // The street ground's street-side bays: per way side, the cars the dated aerial shows in them.
  bay_occupancy: ["cars", "head_in", "mix", "paints"],
  // A litter can beside every OSM bus stop tagged with a shelter or a bin.
  bus_stop_bins: ["params"],
  curb_parking: ["source_keys", "sides", "curb_gap_m", "gap_m", "daylight_m", "hydrant_m", "mix", "paints"],
  // Every stretch the street ground marks parked (its parking lanes' parked
  // stretches, where the dated aerial shows cars at the curb): per way side,
  // the number of cars the aerial shows there. open_curbs lists, per way side,
  // the roads joining across from a curb where the aerial shows cars parked, so
  // their junction clearance leaves that curb open.
  curb_stretches: ["cars", "open_curbs", "curb_gap_m", "gap_m", "daylight_m", "hydrant_m", "mix", "paints"],
  lot_occupancy: ["lots", "head_in", "mix", "paints"],
  lot_stalls: ["source_keys", "near_key", "near_m", "far_m", "fill_near", "fill_far", "head_in", "mix", "paints"],
});
// The kit prop and kind each pattern places.
const PATTERN_PROPS = Object.freeze({
  bay_occupancy: { prop: "parked_car", kind: "parked_car" },
  bus_stop_bins: { prop: "waste_basket", kind: "waste_basket" },
  curb_stretches: { prop: "parked_car", kind: "parked_car" },
  curb_parking: { prop: "parked_car", kind: "parked_car" },
  lot_occupancy: { prop: "parked_car", kind: "parked_car" },
  lot_stalls: { prop: "parked_car", kind: "parked_car" },
});
// A lot_occupancy rule's entry per lot: the OSM lot, the cars the dated aerial
// shows in it and what was seen, and optionally focus_xz, the world [x, z]
// points where the aerial shows them gathered, or [x, z, cars] to give each
// point its share of the lot's cars (each takes the free stalls nearest it in
// its row), and cross_runs: true where the aerial shows a row along an aisle's
// runs across its main direction (a loop's ends) as well.
const LOT_ENTRY_FIELDS = Object.freeze(["cars", "observed", "source_key"]);
const LOT_ENTRY_OPTIONAL_FIELDS = Object.freeze(["cross_runs", "focus_xz"]);
const COMMON_FIELDS = Object.freeze(["basis", "evidence", "id", "kind", "pattern", "prop", "rule"]);
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
// A car keeps its footprint this far from an OSM building entrance (a node
// tagged entrance on the wall), so no door is parked across.
const ENTRANCE_CLEAR_M = 2.5;
// lot_occupancy: the stalls nearest a building fill first, each stall's
// distance to it jittered by up to this much (m), so a part-full lot is
// fullest by the buildings without filling in strict order.
const LOT_PRIORITY_JITTER_M = 12;
// Stall rows laid along a lot's edges (where no aisle is mapped) keep their
// stall centres at least this far apart, so rows from opposite edges of a
// narrow lot don't overlap.
const EDGE_STALL_MIN_SPACING_M = 2.6;
// ... and stalls along a lot's edges at least this deep (m): a compact car
// with the overhang lot cars may take.
const EDGE_STALL_MIN_DEPTH_M = 3.6;
// ... and open onto the lot, or onto a road ribbon at most this far from the
// stall's front plus its aisle (m).
const EDGE_STALL_ROAD_REACH_M = 4;
// Cars in one island lot keep their footprints this far apart (m): stalls of
// rows from different drives or edges can meet.
const LOT_CAR_CLEAR_M = 0.3;
// A lot car's gap to a wall, a fence run or a built prop is either shut (under
// SHUT_GAP_M: no capsule fits) or clearly open (at least OPEN_GAP_M: a capsule
// walks it end to end); a gap between leaves dead ends and slivers the
// player can be shut in (the street-detail clearance check's flood).
const SHUT_GAP_M = 0.45;
const OPEN_GAP_M = 1.3;
// An island lot car turns at most this much from square to its stall (radians).
const LOT_YAW_JITTER_RAD = 0.01;
// A bus stop's can: rings searched round the stop (m), the clearance it keeps
// from a road ribbon and the farthest it may stand from one (m).
const BIN_RINGS_M = Object.freeze([1.5, 2.5, 3.5]);
const BIN_ROAD_CLEAR_M = 0.6;
const BIN_ROAD_REACH_M = 4.0;
// A basket within this much of a stop already serves it (m).
const BIN_STOP_REACH_M = 6.0;
// A focus share's row: stalls facing within 30 degrees of, and standing within
// this depth (m) of the line of, the stall nearest its point.
const SHARE_ROW_FACING_COS = Math.cos((30 * Math.PI) / 180);
const SHARE_ROW_DEPTH_M = 1.5;
// An aisle's rows stop where it turns more than this from its main direction (radians).
const AISLE_ROW_TURN_RAD = (25 * Math.PI) / 180;
// The occupied-item grid for the site checks (m).
const OCCUPIED_CELL_M = 8;
// A car in a lot stall stops 0.3 m short of the stall's back; a body longer
// than that pulls in to 0.1 m (over the curb stop) and may reach out into the
// aisle up to LOT_OVERHANG_M, as the photographed utility trucks do.
const LOT_BACK_GAP_M = 0.3;
const LOT_LONG_BACK_GAP_M = 0.1;
const LOT_OVERHANG_M = 1.3;
// The street ground's stalls that are not lot stalls: street-side bays and shoulders.
const NON_LOT_STALLS = Object.freeze(["bay", "shoulder"]);
// Chunk record kinds the visible ground is made of, and the surfaces (by
// material) a parked car's tyre may stand on.
const VISIBLE_GROUND_KINDS = new Set(["land_ground", "major_area", "road_path", "street_kerb", "street_paint", "terrain_overlay"]);
// The street ground drapes some lots with a yard pavement (asphalt or concrete).
const WHEEL_SURFACES = new Set(["major_area_paved", "road_path", "road_path_concrete", "street_gutter", "street_marking", "street_parking", "street_wear", "yard_asphalt", "yard_asphalt_pale", "yard_asphalt_fresh", "yard_concrete"]);
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
    invariant(rule.prop === PATTERN_PROPS[rule.pattern].prop && rule.kind === PATTERN_PROPS[rule.pattern].kind && kinds[rule.kind] != null,
      `${label}: ${rule.pattern} rules place ${PATTERN_PROPS[rule.pattern].prop} props`);
    invariant(rule.basis === "production_inference", `${label}: rule-based clutter is production_inference`);
    for (const field of ["rule", "evidence"]) invariant(typeof rule[field] === "string" && rule[field].trim() !== "", `${label} needs ${field}`);
    if (rule.pattern === "bus_stop_bins") {
      invariant(rule.params != null && typeof rule.params === "object" && JSON.stringify(Object.keys(rule.params)) === JSON.stringify(["style"]) && typeof rule.params.style === "string",
        `${label} params must be {style} (a waste basket style)`);
      continue;
    }
    validateWeights(rule.mix, CAR_BODY_NAMES, `${label} mix`);
    validateWeights(rule.paints, CAR_PAINTS, `${label} paints`);
    if (rule.pattern === "curb_stretches" || rule.pattern === "bay_occupancy") {
      invariant(rule.cars != null && typeof rule.cars === "object" && Object.entries(rule.cars).every(([way, sides]) => /^w\d+$/u.test(way) && sides != null && typeof sides === "object"
        && Object.entries(sides).every(([side, cars]) => ["left", "right"].includes(side) && Number.isInteger(cars) && cars >= 0)), `${label} cars must map OSM ways to {left, right} car counts`);
      if (rule.pattern === "bay_occupancy") {
        invariant(isFiniteNumber(rule.head_in) && rule.head_in >= 0 && rule.head_in <= 1, `${label} head_in must be in [0, 1]`);
      } else {
        invariant(Array.isArray(rule.gap_m) && rule.gap_m.length === 2 && rule.gap_m.every(isFiniteNumber) && rule.gap_m[0] >= 1.0 && rule.gap_m[1] >= rule.gap_m[0],
          `${label} gap_m is [min, max] with min at least 1 m (a player passes between two cars)`);
        for (const field of ["curb_gap_m", "daylight_m", "hydrant_m"]) invariant(isFiniteNumber(rule[field]) && rule[field] >= 0, `${label} ${field} must be non-negative`);
        invariant(rule.open_curbs != null && typeof rule.open_curbs === "object" && Object.entries(rule.open_curbs).every(([way, sides]) => /^w\d+$/u.test(way) && sides != null && typeof sides === "object"
          && Object.entries(sides).every(([side, roads]) => ["left", "right"].includes(side) && Array.isArray(roads) && roads.every((road) => /^w\d+$/u.test(road)))), `${label} open_curbs must map OSM ways to {left, right} lists of OSM ways`);
      }
      continue;
    }
    if (rule.pattern !== "lot_occupancy") {
      invariant(Array.isArray(rule.source_keys) && rule.source_keys.length > 0 && rule.source_keys.every((key) => /^w\d+$/u.test(key)), `${label} needs OSM way source_keys`);
    }
    if (rule.pattern === "lot_occupancy") {
      invariant(Array.isArray(rule.lots) && rule.lots.length > 0, `${label} needs lots`);
      const keys = new Set();
      for (const entry of rule.lots) {
        const entryLabel = `${label} lot ${entry?.source_key}`;
        invariant(entry != null && typeof entry === "object" && LOT_ENTRY_FIELDS.every((key) => key in entry) && Object.keys(entry).every((key) => LOT_ENTRY_FIELDS.includes(key) || LOT_ENTRY_OPTIONAL_FIELDS.includes(key)),
          `${entryLabel} must have ${LOT_ENTRY_FIELDS.join(", ")} and optionally ${LOT_ENTRY_OPTIONAL_FIELDS.join(", ")}`);
        invariant(entry.focus_xz === undefined || (Array.isArray(entry.focus_xz) && entry.focus_xz.length > 0 && entry.focus_xz.every((point) => Array.isArray(point)
          && ((point.length === 2 && point.every(isFiniteNumber)) || (point.length === 3 && isFiniteNumber(point[0]) && isFiniteNumber(point[1]) && Number.isInteger(point[2]) && point[2] > 0)))),
          `${entryLabel} focus_xz must list world [x, z] points, or [x, z, cars] with the lot's cars shared out`);
        const counted = (entry.focus_xz ?? []).filter((point) => point.length === 3);
        invariant(counted.length === 0 || (counted.length === entry.focus_xz.length && counted.reduce((sum, point) => sum + point[2], 0) === entry.cars),
          `${entryLabel}: when focus_xz gives cars, every point gives them and they add up to cars`);
        invariant(entry.cross_runs === undefined || entry.cross_runs === true, `${entryLabel} cross_runs is true or left out`);
        invariant(/^w\d+$/u.test(entry.source_key) && !keys.has(entry.source_key), `${entryLabel} needs a unique OSM way source_key`);
        keys.add(entry.source_key);
        invariant(Number.isInteger(entry.cars) && entry.cars > 0, `${entryLabel} cars must be a positive whole number (leave an empty lot out)`);
        invariant(typeof entry.observed === "string" && entry.observed.trim() !== "", `${entryLabel} needs what was observed`);
      }
      invariant(isFiniteNumber(rule.head_in) && rule.head_in >= 0 && rule.head_in <= 1, `${label} head_in must be in [0, 1]`);
    } else if (rule.pattern === "curb_parking") {
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
  // The dumpster's sleeves and its leaning front reach past the box.
  dumpster: Object.freeze({ x_m: 1.98, z_m: 1.58 }),
  // A stock-tank planter's pallet.
  stock_tank_planter: Object.freeze({ x_m: 1.0, z_m: 2.5 }),
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

// Places the parked cars and cans of the clutter rules (the pilot zones' and
// the island-wide ones). Returns the rows and an audit.
//   parkingLots: OSM parking lots by source key ({geometry}, east/north);
//   parkingAisles: OSM parking aisles and plain service roads ({source_key, line
//   (east/north), half_width_m, parking_aisle}), a lot's drives;
//   roads: the road ribbons (polygonSet over world x, z), which a stall stops at;
//   entrances: OSM building entrances (world [x, z]), kept clear;
//   stallLines: the painted stall size the street ground uses ({length_m, spacing_m});
//   islandRules: the island-wide clutter rules (the config's top-level clutter
//   list), which name their own lots or streets; their rows take "island" in
//   place of a zone id;
//   barredIds: row ids of island places not to use (a lot stall, curb place,
//   bay or bus stop's can): the generator bars a place whose row shuts
//   walkable ground in or leaves a scored side too few free walk-up lanes, and
//   places the clutter again.
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
  parkingLots = new Map(),
  parkingAisles = [],
  roads = null,
  entrances = [],
  stallLines = null,
  islandRules = [],
  barredIds = new Set(),
}) {
  const pilotShapes = zoneShapes.filter(({ zone }) => zone.pilot);
  // Cars along a road's parking lanes: per side, its curb offset and the
  // stretches [from_m, to_m, fill] along the way to fill, nose to tail with the
  // rule's gaps, the curb kept clear at junctions and crosswalks (daylight_m),
  // fire hydrants (hydrant_m) and bus stops.
  const placeCurbRuns = (zone, rule, contains, lane, sides) => {
    const key = lane.source_key;
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
      const others = (roadsAtNode.get(ref) ?? []).filter((other) => other !== key);
      if (others.length === 0) continue;
      const node = rawOsm.nodes.get(ref);
      if (!node) continue;
      const near = closestOnPolyline(line, projectLonLat(node.coordinate));
      // Past the crossing road's curb and the daylighting, on each curb not kept open across it.
      for (const side of ["left", "right"]) {
        if (others.every((other) => rule.open_curbs?.[key]?.[side]?.includes(other))) continue;
        blocked[side].push([near.along - rule.daylight_m - 8, near.along + rule.daylight_m + 8]);
      }
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
    for (const [sideName, { kerb_offset_m: kerbOffset, stretches, cars = null }] of Object.entries(sides)) {
      const side = sideName === "left" ? 1 : -1;
      let index = 0;
      // With a car count, the run is walked nose to tail at the shortest gap and
      // that many of the places that fit are taken (by seeded rank).
      const places = [];
      for (const [from, to, fill] of stretches) {
        let s = Math.max(0, from);
        const end = Math.min(total, to);
        while (s < end) {
          const cell = `${key}_${sideName}_${String(index).padStart(3, "0")}`;
          const identity = `${zone.id}:${rule.id}:${cell}`;
          const params = carParams(rule, identity);
          const dims = carBodyGeometry(params.body);
          const footprint = { x_m: dims.width_m, z_m: dims.length_m };
          const gap = cars === null ? rule.gap_m[0] + (rule.gap_m[1] - rule.gap_m[0]) * hashUnit(seed, identity, "gap") : rule.gap_m[0];
          index += 1;
          const startS = s;
          const endS = s + footprint.z_m;
          if (endS > end) break;
          // A barred place stays empty and keeps its length, so the places after it keep their ids.
          if (barredIds.has(`scatter:${zone.id}:${rule.id}:${cell}`)) {
            count(audit.rejected_by_reason, `${rule.id}:barred`);
            s = endS + gap;
            continue;
          }
          const clash = blocked[sideName].find(([a, b]) => endS > a && startS < b);
          if (clash) {
            count(audit.rejected_by_reason, `${rule.id}:curb_kept_clear`);
            s = Math.max(s + 0.5, clash[1] + 0.3);
            continue;
          }
          const taken = cars !== null || hashUnit(seed, identity, "fill") < fill;
          if (!taken) {
            count(audit.rejected_by_reason, `${rule.id}:fill`);
            s = endS + gap;
            continue;
          }
          const at = pointAlong(line, (startS + endS) / 2);
          // Right-hand traffic: a car faces along the travel of its curb's lane.
          const front = side > 0 ? scale(at.tangent, -1) : at.tangent;
          const offset = kerbOffset - rule.curb_gap_m - footprint.x_m / 2 - 0.05 * hashUnit(seed, identity, "offset");
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
          if (cars === null) addCar(zone, rule, cell, center, facing, params, footprint, rest);
          else places.push({ cell, center, facing, params, footprint, rest, rank: hashUnit(seed, identity, "pick") });
          s = endS + gap;
        }
      }
      if (cars !== null) {
        const picked = new Set([...places].sort((left, right) => left.rank - right.rank).slice(0, cars));
        for (const place of places) {
          if (picked.has(place)) addCar(zone, rule, place.cell, place.center, place.facing, place.params, place.footprint, place.rest);
          else count(audit.rejected_by_reason, `${rule.id}:fill`);
        }
        audit.curbs ??= {};
        audit.curbs[`${key}/${sideName}`] = { cars, places: places.length, placed: Math.min(cars, places.length) };
      }
    }
  };
  // The rule sets: each pilot zone's clutter rules within its shape, then the island-wide rules.
  const ruleSets = [
    ...pilotShapes.map(({ zone, contains }) => ({ zone, contains, rules: zone.clutter ?? [] })),
    { zone: { id: "island", island: true }, contains: () => true, rules: islandRules },
  ];
  const groundAt = visibleGroundIndex(chunks);
  // The occupied items on a grid of their reach, for the site checks: each one
  // in every cell its points' box, grown by its radius, touches.
  const occupiedCells = new Map();
  const cellKey = (i, j) => `${i},${j}`;
  for (const item of occupied) {
    const xs = item.points.map((point) => point[0]);
    const zs = item.points.map((point) => point[1]);
    for (let i = Math.floor((Math.min(...xs) - item.radius_m) / OCCUPIED_CELL_M); i <= Math.floor((Math.max(...xs) + item.radius_m) / OCCUPIED_CELL_M); i += 1) {
      for (let j = Math.floor((Math.min(...zs) - item.radius_m) / OCCUPIED_CELL_M); j <= Math.floor((Math.max(...zs) + item.radius_m) / OCCUPIED_CELL_M); j += 1) {
        const key = cellKey(i, j);
        if (!occupiedCells.has(key)) occupiedCells.set(key, []);
        occupiedCells.get(key).push(item);
      }
    }
  }
  // The occupied items whose grown box meets the box of points grown by reach.
  const occupiedNear = (points, reach) => {
    const xs = points.map((point) => point[0]);
    const zs = points.map((point) => point[1]);
    const found = new Set();
    for (let i = Math.floor((Math.min(...xs) - reach) / OCCUPIED_CELL_M); i <= Math.floor((Math.max(...xs) + reach) / OCCUPIED_CELL_M); i += 1) {
      for (let j = Math.floor((Math.min(...zs) - reach) / OCCUPIED_CELL_M); j <= Math.floor((Math.max(...zs) + reach) / OCCUPIED_CELL_M); j += 1) {
        for (const item of occupiedCells.get(cellKey(i, j)) ?? []) found.add(item);
      }
    }
    return found;
  };
  // Rows the runtime builds (a fence's runs are claimed as "<id>#run<n>"), and the
  // built point props standing on the raised street ground (sidewalk, verge,
  // planting or plaza paving above the curb).
  const builtIds = new Set(rows.filter((row) => row.status === "placed" && row.prop != null).map((row) => row.id));
  // Rows the runtime builds with collision: every built prop but low plants
  // (only trees have a trunk that collides).
  const solidIds = new Set(rows
    .filter((row) => builtIds.has(row.id) && (row.layer !== "vegetation" || STREET_VEGETATION_PROPS[row.prop]?.trunk))
    .map((row) => row.id));
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
  // carriageway, a parking lane or the lot, never the raised street ground),
  // clear of the building entrances and of placed items. An island lot
  // (lot_occupancy) is its own OSM polygon, which the ground's lot index may not
  // cover; a car may overhang a road (its aisle) there too.
  const reject = (center, front, footprint, surface, lot = null) => {
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
      if ((surface === "road" || surface === "bay") && site.carriagewayDistance(corner, 1) > 0) return "off_asphalt";
      if (surface === "lot" && !lot && !site.inLot(corner) && site.carriagewayDistance(corner, 1) > 0) return "off_lot";
      // An island lot car stands wholly off the drives (their ribbons), inside its lot.
      if (lot && (!pointInMultiPolygon(corner, lot.geometry, true) || roads.containing(toWorld(corner)).length > 0)) return "off_lot";
    }
    const samples = piece.points.length > 1 ? sampleSegment(piece.points) : piece.points;
    for (const entrance of entrances) {
      if (Math.abs(entrance[0] - xz[0]) > footprint.z_m + ENTRANCE_CLEAR_M || Math.abs(entrance[1] - xz[1]) > footprint.z_m + ENTRANCE_CLEAR_M) continue;
      if (samples.some((point) => Math.hypot(point[0] - entrance[0], point[1] - entrance[1]) < piece.radius + ENTRANCE_CLEAR_M)) return "entrance";
    }
    for (const item of occupiedNear(samples, piece.radius + ITEM_CLEAR_M)) {
      const clear = itemClearance(item, surface);
      for (const point of samples) {
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
  // Whether a lot car's rectangle stands a trap-band gap (SHUT_GAP_M to
  // OPEN_GAP_M) from a building wall, a fence run or a built prop: its edge
  // sampled every quarter metre against each of them.
  const trapGap = (center, front, footprint) => {
    const right = [front[1], -front[0]];
    const edge = [];
    const hl = footprint.z_m / 2;
    const hw = footprint.x_m / 2;
    for (const [from, to] of [[[hl, hw], [hl, -hw]], [[hl, -hw], [-hl, -hw]], [[-hl, -hw], [-hl, hw]], [[-hl, hw], [hl, hw]]]) {
      const steps = Math.max(1, Math.ceil(Math.hypot(to[0] - from[0], to[1] - from[1]) / 0.25));
      for (let step = 0; step < steps; step += 1) {
        const a = from[0] + ((to[0] - from[0]) * step) / steps;
        const b = from[1] + ((to[1] - from[1]) * step) / steps;
        edge.push(toWorld(add(add(center, scale(front, a)), scale(right, b))));
      }
    }
    const inBand = (gap) => gap >= SHUT_GAP_M && gap < OPEN_GAP_M;
    let wall = Infinity;
    for (const point of edge) wall = Math.min(wall, buildings.nearest(point, OPEN_GAP_M).distance);
    if (inBand(wall)) return true;
    for (const item of occupiedNear(edge, OPEN_GAP_M + 1)) {
      if (!solidIds.has(item.id.split("#")[0])) continue;
      let gap = Infinity;
      for (const point of edge) {
        gap = Math.min(gap, (item.points.length > 1 ? distanceToPolyline(point, item.points) : Math.hypot(point[0] - item.points[0][0], point[1] - item.points[0][1])) - item.radius_m);
      }
      if (inBand(gap)) return true;
    }
    return false;
  };
  // Every car placed so far: no two may overlap, whichever rules placed them
  // (stalls fan in round a bend, and rows of different drives can meet).
  const carBoxes = [];
  const carBox = (center, front, footprint) => ({ center, front, half_length: footprint.z_m / 2, half_width: footprint.x_m / 2 });
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
      source_id: zone.island ? `island:${rule.id}` : `zone:${zone.id}/${rule.id}`,
      kind: rule.kind,
      layer: kinds[rule.kind].layer,
      geometry: "point",
      ...ground,
      yaw_radians: yaw,
      yaw_source: zone.island ? `rule:island/${rule.id}` : `rule:${zone.id}/${rule.id}`,
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
    carBoxes.push(carBox(center, front, footprint));
    count(audit.rules, `${zone.id}/${rule.id}`);
    return row;
  };
  // The site checks, then the rest on the ground; the reason when either fails.
  const fit = (center, front, footprint, surface, body, lot = null) => {
    const box = carBox(center, front, footprint);
    if (carBoxes.some((other) => boxesOverlap(box, other))) return { problem: "car" };
    const problem = reject(center, front, footprint, surface, lot);
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

  for (const { zone, contains, rules } of ruleSets) {
    for (const rule of rules) {
      if (rule.pattern === "bus_stop_bins") {
        // A litter can beside each OSM bus stop tagged with a shelter or a bin:
        // the first clear spot on rings round the stop, off the roads (by a curb
        // clearance) and within reach of the nearest one, clear of the mask,
        // walls, built items and the cars placed so far by a player's width.
        const stops = rows.filter((row) => row.source === "osm" && row.kind === "bus_stop" && row.status === "placed" && (row.tags?.shelter === "yes" || row.tags?.bin === "yes"))
          .sort((left, right) => (left.id < right.id ? -1 : 1));
        const radius = kinds[rule.kind].footprint_radius_m;
        const baskets = rows.filter((row) => row.kind === "waste_basket" && row.status === "placed" && row.prop != null);
        for (const stop of stops) {
          const at = [stop.position_m[0], stop.position_m[2]];
          if (barredIds.has(`scatter:${zone.id}:${rule.id}:${stop.source_id}`)) {
            count(audit.rejected_by_reason, `${rule.id}:barred`);
            continue;
          }
          // A stop OSM already gives a waste basket keeps that one.
          if (baskets.some((row) => Math.hypot(row.position_m[0] - at[0], row.position_m[2] - at[1]) <= BIN_STOP_REACH_M)) {
            count(audit.rejected_by_reason, `${rule.id}:has_a_basket`);
            continue;
          }
          let spot = null;
          for (const ring of BIN_RINGS_M) {
            for (let step = 0; step < 16 && !spot; step += 1) {
              const angle = (step * Math.PI) / 8;
              const xz = [roundCoordinate(at[0] + ring * Math.cos(angle)), roundCoordinate(at[1] + ring * Math.sin(angle))];
              const road = roads.nearest(xz, BIN_ROAD_REACH_M + radius);
              if (road.distance < BIN_ROAD_CLEAR_M + radius || road.distance > BIN_ROAD_REACH_M + radius) continue;
              if (!onLand(xz, exclusions.land_edge_buffer_m + radius) || hardViolation(hardShapes, [xz], radius)) continue;
              if (buildings.nearest(xz, exclusions.wall_buffer_m + radius).distance < exclusions.wall_buffer_m + radius) continue;
              if ([...occupiedNear([xz], radius + ITEM_CLEAR_M)].some((item) => item.id !== stop.id && (item.points.length > 1 ? distanceToPolyline(xz, item.points) : length(sub(xz, item.points[0]))) < item.radius_m + radius + ITEM_CLEAR_M)) continue;
              if (ruleRows.some((row) => row.footprint_m && streetFootprintDistance(row, xz) < radius + ITEM_CLEAR_M)) continue;
              if (stop.footprint_m && inFootprint(stop, xz, radius)) continue;
              spot = xz;
            }
            if (spot) break;
          }
          if (!spot) {
            count(audit.rejected_by_reason, `${rule.id}:no_clear_spot`);
            continue;
          }
          // Facing the road: down the slope of the road distance round the spot.
          const near = (dx, dz) => roads.nearest([spot[0] + dx, spot[1] + dz], BIN_ROAD_REACH_M + 2).distance;
          const toward = [near(-0.3, 0) - near(0.3, 0), near(0, -0.3) - near(0, 0.3)];
          const yaw = length(toward) > 1e-6 ? roundCoordinate(Math.atan2(-toward[0], -toward[1])) : 0;
          const row = {
            id: `scatter:${zone.id}:${rule.id}:${stop.source_id}`,
            source: "scatter",
            source_id: zone.island ? `island:${rule.id}` : `zone:${zone.id}/${rule.id}`,
            kind: rule.kind,
            layer: kinds[rule.kind].layer,
            geometry: "point",
            ...surfaceRow(spot),
            yaw_radians: yaw,
            yaw_source: `faces_road:${stop.source_id}`,
            status: "placed",
            exclusion: null,
            prop: rule.prop,
            prop_params: { ...rule.params },
            basis: rule.basis,
          };
          ruleRows.push(row);
          count(audit.rules, `${zone.id}/${rule.id}`);
        }
      } else if (rule.pattern === "curb_parking") {
        for (const key of rule.source_keys) {
          const lane = site.parking_lanes.find((candidate) => candidate.source_key === key);
          invariant(lane, `Street clutter curb rule names ${key}, which has no parking lane in the street ground`);
          placeCurbRuns(zone, rule, contains, lane, Object.fromEntries(Object.entries(rule.sides).map(([side, stretches]) => [side, { kerb_offset_m: lane.kerb_offset_m, stretches }])));
        }
      } else if (rule.pattern === "curb_stretches") {
        // Every lane the street ground marks parked (none on a ground without them).
        for (const lane of site.parking_lanes) {
          if (!lane.parked) continue;
          const sides = {};
          for (const side of ["left", "right"]) {
            const stretches = (lane.parked[side] ?? []).map(([from, to]) => [from, to, 1]);
            const cars = rule.cars[lane.source_key]?.[side];
            if (stretches.length === 0) continue;
            if (!Number.isInteger(cars)) {
              count(audit.rejected_by_reason, `${rule.id}:no_count:${lane.source_key}/${side}`);
              continue;
            }
            sides[side] = { kerb_offset_m: lane[`kerb_offset_${side}_m`] ?? lane.kerb_offset_m, stretches, cars };
          }
          if (Object.keys(sides).length > 0) placeCurbRuns(zone, rule, contains, lane, sides);
        }
      } else if (rule.pattern === "bay_occupancy") {
        // The street ground's street-side bays (none on a ground without them):
        // each way side's first cars[way][side] bays in seeded rank that fit
        // take a car, mostly nose in, centred and square.
        const baySlots = site.stalls.filter((candidate) => candidate.kind === "bay");
        const taken = new Map();
        const ranked = baySlots.map((slot) => {
          const cell = `${slot.aisle_key}_${slot.side}_b${String(Math.round(slot.s * 10)).padStart(4, "0")}`;
          return { slot, cell, identity: `${zone.id}:${rule.id}:${cell}` };
        }).sort((left, right) => hashUnit(seed, left.identity, "pick") - hashUnit(seed, right.identity, "pick") || (left.cell < right.cell ? -1 : 1));
        for (const { slot, cell, identity } of ranked) {
          if (barredIds.has(`scatter:${zone.id}:${rule.id}:${cell}`)) {
            count(audit.rejected_by_reason, `${rule.id}:barred`);
            continue;
          }
          const wanted = rule.cars[slot.aisle_key]?.[slot.side];
          if (!Number.isInteger(wanted)) {
            count(audit.rejected_by_reason, `${rule.id}:no_count:${slot.aisle_key}/${slot.side}`);
            continue;
          }
          const sideKey = `${slot.aisle_key}/${slot.side}`;
          if ((taken.get(sideKey) ?? 0) >= wanted) {
            count(audit.rejected_by_reason, `${rule.id}:fill`);
            continue;
          }
          const params = carParams(rule, identity);
          const dims = carBodyGeometry(params.body);
          const footprint = { x_m: dims.width_m, z_m: dims.length_m };
          if (footprint.z_m > slot.depth_m - LOT_BACK_GAP_M) {
            count(audit.rejected_by_reason, `${rule.id}:too_long`);
            continue;
          }
          const center = add(slot.entry, scale(slot.outward, slot.depth_m - LOT_BACK_GAP_M - footprint.z_m / 2));
          const headIn = hashUnit(seed, identity, "head_in") < rule.head_in;
          const jitter = (hashUnit(seed, identity, "yaw") - 0.5) * LOT_YAW_JITTER_RAD * 2;
          const base = headIn ? slot.outward : scale(slot.outward, -1);
          const facing = [base[0] * Math.cos(jitter) - base[1] * Math.sin(jitter), base[0] * Math.sin(jitter) + base[1] * Math.cos(jitter)];
          const rest = fit(center, facing, footprint, "bay", params.body);
          if (rest.problem) {
            count(audit.rejected_by_reason, `${rule.id}:${rest.problem}`);
            continue;
          }
          addCar(zone, rule, cell, center, facing, params, footprint, rest);
          taken.set(sideKey, (taken.get(sideKey) ?? 0) + 1);
        }
        audit.bays = Object.fromEntries([...taken.entries()].sort());
      } else if (rule.pattern === "lot_stalls") {
        const near = buildings.items.find((item) => item.key === rule.near_key);
        invariant(near, `Street clutter lot rule names ${rule.near_key}, which is not a building`);
        let stallsInLots = 0;
        const lots = new Set(rule.source_keys);
        for (const stall of site.stalls) {
          if (NON_LOT_STALLS.includes(stall.kind)) continue;
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
      } else if (rule.pattern === "lot_occupancy") {
        invariant(roads && stallLines, `Street clutter lot rule ${rule.id} needs the road ribbons and the stall size`);
        audit.lots ??= {};
        const lotEntries = [...parkingLots.values()];
        // A stall line stops at the lot's edge (any OSM lot: lots can adjoin),
        // a road other than its own aisle, or a building.
        // Why a stall line must stop at a point, or null: "road" for another
        // road (the rows of two drives share the space between them, back to
        // back), "edge" for the edge of the lots or a building.
        const blockedFor = (aisleKey) => (en) => {
          const xz = toWorld(en);
          if (!lotEntries.some((lot) => pointInMultiPolygon(en, lot.geometry, false))) return "edge";
          if (roads.containing(xz).some((item) => item.key !== aisleKey)) return "road";
          return buildings.nearest(xz, 0).distance === 0 ? "edge" : null;
        };
        for (const entry of rule.lots) {
          const lot = parkingLots.get(entry.source_key);
          invariant(lot, `Street clutter lot rule ${rule.id} names ${entry.source_key}, which is not an OSM parking lot`);
          const inLot = (en) => pointInMultiPolygon(en, lot.geometry, false);
          const middleOf = (slot) => add(slot.entry, scale(slot.outward, slot.depth_m / 2));
          // The painted stalls where the street ground has them, else stalls
          // along the lot's mapped aisles, else along its edges.
          let layout = "painted";
          let slots = site.stalls.filter((slot) => !NON_LOT_STALLS.includes(slot.kind) && inLot(middleOf(slot)));
          if (slots.length === 0) {
            layout = "aisles";
            // Its parking aisles, and a service road with at least 10 m inside it.
            const aisles = parkingAisles.filter((aisle) => samplePolyline(aisle.line, 2).filter(inLot).length >= (aisle.parking_aisle ? 1 : 5));
            slots = aisles.flatMap((aisle) => aisleStallSlots(aisle, stallLines, blockedFor(aisle.source_key), entry.cross_runs === true)).filter((slot) => inLot(middleOf(slot)));
          }
          if (slots.length === 0) {
            layout = "edges";
            // A stall's front opens onto the lot, or onto a road within EDGE_STALL_ROAD_REACH_M
            // (a street-side lot along its street, whose frozen ribbon is narrower than the street).
            slots = edgeStallSlots(lot, stallLines, (en) => !inLot(en) || blockedFor(null)(en) !== null, (en) => inLot(en) || roads.nearest(toWorld(en), EDGE_STALL_ROAD_REACH_M).distance <= EDGE_STALL_ROAD_REACH_M);
          }
          invariant(slots.length > 0, `Street clutter lot rule ${rule.id} found no stalls in ${entry.source_key}`);
          const ranked = slots.map((slot) => {
            const cell = slot.edge_cell ?? `${slot.aisle_key}_${slot.side}_s${String(Math.round(slot.s * 10)).padStart(4, "0")}`;
            const identity = `${zone.id}:${rule.id}:${cell}`;
            const middle = toWorld(middleOf(slot));
            const nearest = entry.focus_xz
              ? Math.min(...entry.focus_xz.map((point) => Math.hypot(point[0] - middle[0], point[1] - middle[1])))
              : buildings.nearest(middle, 400).distance;
            return { slot, cell, identity, priority: (Number.isFinite(nearest) ? nearest : 400) + LOT_PRIORITY_JITTER_M * hashUnit(seed, identity, "priority") };
          }).sort((left, right) => left.priority - right.priority || (left.cell < right.cell ? -1 : left.cell > right.cell ? 1 : 0));
          let placed = 0;
          const rejected = {};
          const reject_ = (reason) => {
            count(audit.rejected_by_reason, `${rule.id}:${reason}`);
            rejected[reason] = (rejected[reason] ?? 0) + 1;
          };
          // The footprints of the cars placed in this lot so far.
          const parked = [];
          // Tries one stall; true when a car now stands in it.
          const tryStall = ({ slot, cell, identity }) => {
            if (barredIds.has(`scatter:${zone.id}:${rule.id}:${cell}`)) {
              reject_("shuts_ground_in");
              return false;
            }
            const params = carParams(rule, identity);
            const dims = carBodyGeometry(params.body);
            const footprint = { x_m: dims.width_m, z_m: dims.length_m };
            const backGap = footprint.z_m > slot.depth_m - LOT_BACK_GAP_M ? LOT_LONG_BACK_GAP_M : LOT_BACK_GAP_M;
            if (footprint.z_m - (slot.depth_m - backGap) > LOT_OVERHANG_M) {
              reject_("too_long");
              return false;
            }
            // Centred in its stall and nearly square to it: neighbours in a row
            // then stand a stall's spacing less their half widths apart (0.67 to
            // 0.91 m), too narrow for the flood's capsule to pass and leave slivers.
            const center = add(slot.entry, scale(slot.outward, slot.depth_m - backGap - footprint.z_m / 2));
            const headIn = hashUnit(seed, identity, "head_in") < rule.head_in;
            const jitter = (hashUnit(seed, identity, "yaw") - 0.5) * LOT_YAW_JITTER_RAD * 2;
            const base = headIn ? slot.outward : scale(slot.outward, -1);
            const facing = [base[0] * Math.cos(jitter) - base[1] * Math.sin(jitter), base[0] * Math.sin(jitter) + base[1] * Math.cos(jitter)];
            const box = { center, front: facing, half_length: footprint.z_m / 2 + LOT_CAR_CLEAR_M / 2, half_width: footprint.x_m / 2 + LOT_CAR_CLEAR_M / 2 };
            if (parked.some((other) => boxesOverlap(box, other))) {
              reject_("car");
              return false;
            }
            const rest = fit(center, facing, footprint, "lot", params.body, lot);
            if (rest.problem) {
              reject_(rest.problem);
              return false;
            }
            if (trapGap(center, facing, footprint)) {
              reject_("trap_gap");
              return false;
            }
            addCar(zone, rule, cell, center, facing, params, footprint, rest);
            parked.push(box);
            return true;
          };
          const shares = (entry.focus_xz ?? []).filter((point) => point.length === 3);
          if (shares.length > 0) {
            // Each focus point takes its share from the free stalls nearest it in
            // its row: the stalls in line with, and facing the same way as, the
            // stall nearest the point (then from the others, nearest first).
            const used = new Set();
            for (const [fx, fz, share] of shares) {
              const distance = (item) => {
                const middle = toWorld(middleOf(item.slot));
                return Math.hypot(fx - middle[0], fz - middle[1]);
              };
              const first = ranked.reduce((best, item) => (best === null || distance(item) < distance(best) ? item : best), null);
              const inRow = (item) => dot(item.slot.outward, first.slot.outward) >= SHARE_ROW_FACING_COS
                && Math.abs(dot(sub(middleOf(item.slot), middleOf(first.slot)), first.slot.outward)) <= SHARE_ROW_DEPTH_M;
              const order = ranked.map((item) => ({ ...item, row: inRow(item) ? 0 : 1, near: distance(item) + LOT_PRIORITY_JITTER_M * hashUnit(seed, item.identity, "priority") }))
                .sort((left, right) => left.row - right.row || left.near - right.near || (left.cell < right.cell ? -1 : left.cell > right.cell ? 1 : 0));
              let here = 0;
              for (const item of order) {
                if (here >= share) break;
                if (used.has(item.cell)) continue;
                used.add(item.cell);
                if (tryStall(item)) here += 1;
              }
              placed += here;
            }
          } else {
            for (const item of ranked) {
              if (placed >= entry.cars) break;
              if (tryStall(item)) placed += 1;
            }
          }
          audit.lots[entry.source_key] = { layout, stalls: slots.length, cars: entry.cars, placed, rejected };
        }
      }
    }
  }
  return { rows: ruleRows, audit };
}

// Stall slots along one OSM parking aisle, laid as the street ground paints its
// stall lines (generateStreetGround): a line every stall spacing from 1.5 m
// along the aisle on both sides, reaching out from the aisle's edge as far as the
// lot allows up to the stall length (half the reach where the row meets another
// drive's row back to back), less 0.1 m; a slot lies between two neighbouring
// lines at least 2.5 m long. Only the aisle's main runs take stalls: where it
// turns more than AISLE_ROW_TURN_RAD from its length-weighted main direction
// (the ends of a loop round a lot's middle) the rows stop, so a lot's cars
// stand in rows square to its drives; with crossRuns, every run takes stalls
// (a lot whose aerial shows a row along a loop's ends). blocked(en) says why a
// line must stop ("road" or "edge") or null. Slots are {aisle_key, side, s,
// entry, outward, along, depth_m, width_m}, east/north.
function aisleStallSlots(aisle, stallLines, blocked, crossRuns = false) {
  const slots = [];
  const total = polylineLength(aisle.line);
  // The aisle's main direction: the length-weighted mean of its segments' doubled angles.
  let c2 = 0;
  let s2 = 0;
  for (let index = 1; index < aisle.line.length; index += 1) {
    const d = sub(aisle.line[index], aisle.line[index - 1]);
    const l = length(d);
    if (l < 1e-9) continue;
    const angle = Math.atan2(d[1], d[0]);
    c2 += l * Math.cos(2 * angle);
    s2 += l * Math.sin(2 * angle);
  }
  const main = Math.atan2(s2, c2) / 2;
  const onMainRun = (tangent) => {
    const turn = Math.abs(Math.atan2(tangent[1], tangent[0]) - main) % Math.PI;
    return Math.min(turn, Math.PI - turn) <= AISLE_ROW_TURN_RAD;
  };
  for (const sign of [1, -1]) {
    let previous = null;
    for (let s = 1.5; s <= total - 1.5; s += stallLines.spacing_m) {
      const at = pointAlong(aisle.line, s);
      if (!crossRuns && !onMainRun(at.tangent)) {
        previous = null;
        continue;
      }
      const outward = scale(leftOf(at.tangent), sign);
      const base = add(at.point, scale(outward, aisle.half_width_m + 0.05));
      let reach = 0;
      let stop = null;
      for (let step = 1; step <= Math.ceil((stallLines.length_m * 2 + 1) / 0.2); step += 1) {
        stop = blocked(add(base, scale(outward, step * 0.2)));
        if (stop) break;
        reach = step * 0.2;
      }
      const shared = stop === "road" && reach <= stallLines.length_m * 1.6;
      const stall = Math.min(stallLines.length_m, shared ? reach / 2 : reach) - 0.1;
      if (stall < 2.5) {
        previous = null;
        continue;
      }
      if (previous !== null) {
        const middle = pointAlong(aisle.line, s - stallLines.spacing_m / 2);
        const middleOut = scale(leftOf(middle.tangent), sign);
        slots.push({
          aisle_key: aisle.source_key,
          side: sign > 0 ? "left" : "right",
          s: roundCoordinate(s - stallLines.spacing_m / 2),
          entry: add(middle.point, scale(middleOut, aisle.half_width_m + 0.05)),
          outward: middleOut,
          along: middle.tangent,
          depth_m: roundCoordinate(Math.min(stall, previous)),
          width_m: stallLines.spacing_m,
        });
      }
      previous = stall;
    }
  }
  return slots;
}

// Stall slots along the edges of a lot no aisle is mapped in: a row of stalls
// every stall spacing along each outer edge within AISLE_ROW_TURN_RAD of the
// lot's main direction (its long sides), as deep into the lot as it is clear
// (up to the stall length, less 0.1 m, at least EDGE_STALL_MIN_DEPTH_M), kept
// where the whole stall is clear (blocked(en) false across it) and the ground in
// front of it is drivable (reachable(en)), with no two stall centres closer
// than EDGE_STALL_MIN_SPACING_M (rows from opposite edges of a narrow lot).
// Slots carry their own cell name (edge_cell).
function edgeStallSlots(lot, stallLines, blocked, reachable) {
  const slots = [];
  const centres = [];
  lot.geometry.forEach((polygon, polygonIndex) => {
    const ring = polygon[0].slice(0, polygon[0].length - (polygon[0].length > 1 && polygon[0][0][0] === polygon[0].at(-1)[0] && polygon[0][0][1] === polygon[0].at(-1)[1] ? 1 : 0));
    let area = 0;
    for (let index = 0; index < ring.length; index += 1) {
      const a = ring[index];
      const b = ring[(index + 1) % ring.length];
      area += a[0] * b[1] - b[0] * a[1];
    }
    // Left of a counter-clockwise ring's edge is inside.
    const inwardSign = area > 0 ? 1 : -1;
    // The ring's main direction: the length-weighted mean of its edges' doubled angles.
    let c2 = 0;
    let s2 = 0;
    for (let index = 0; index < ring.length; index += 1) {
      const d = sub(ring[(index + 1) % ring.length], ring[index]);
      const angle = Math.atan2(d[1], d[0]);
      c2 += length(d) * Math.cos(2 * angle);
      s2 += length(d) * Math.sin(2 * angle);
    }
    const main = Math.atan2(s2, c2) / 2;
    for (let index = 0; index < ring.length; index += 1) {
      const a = ring[index];
      const b = ring[(index + 1) % ring.length];
      const edge = length(sub(b, a));
      const count = Math.floor((edge - 0.6) / stallLines.spacing_m);
      if (count < 1) continue;
      const turn = Math.abs(Math.atan2(b[1] - a[1], b[0] - a[0]) - main) % Math.PI;
      if (Math.min(turn, Math.PI - turn) > AISLE_ROW_TURN_RAD) continue;
      const along = unit(sub(b, a));
      const inward = scale(leftOf(along), inwardSign);
      const start = (edge - count * stallLines.spacing_m) / 2;
      for (let k = 0; k < count; k += 1) {
        const mid = add(a, scale(along, start + (k + 0.5) * stallLines.spacing_m));
        const halfWidth = stallLines.spacing_m / 2 - 0.15;
        // As deep as the stall's middle and sides stay clear, in 0.2 m steps.
        let reach = 0;
        for (let step = 1; step <= Math.ceil(stallLines.length_m / 0.2) + 1; step += 1) {
          if ([-halfWidth, 0, halfWidth].some((across) => blocked(add(add(mid, scale(along, across)), scale(inward, step * 0.2))))) break;
          reach = step * 0.2;
        }
        const depth = Math.min(stallLines.length_m, reach) - 0.1;
        if (depth < EDGE_STALL_MIN_DEPTH_M) continue;
        if (!reachable(add(mid, scale(inward, depth + 2.5)))) continue;
        const centre = add(mid, scale(inward, depth / 2));
        if (centres.some((other) => length(sub(other, centre)) < EDGE_STALL_MIN_SPACING_M)) continue;
        centres.push(centre);
        slots.push({
          edge_cell: `${lot.source_key}_p${polygonIndex}e${String(index).padStart(2, "0")}k${String(k).padStart(2, "0")}`,
          entry: add(mid, scale(inward, depth)),
          outward: scale(inward, -1),
          along,
          depth_m: roundCoordinate(depth),
          width_m: stallLines.spacing_m,
        });
      }
    }
  });
  return slots;
}

// Whether two plan rectangles ({center, front (unit), half_length, half_width},
// east/north) overlap: no separating axis among their four sides.
function boxesOverlap(left, right) {
  const axes = (box) => [box.front, leftOf(box.front)];
  const extent = (box, axis) => {
    const reach = box.half_length * Math.abs(dot(box.front, axis)) + box.half_width * Math.abs(dot(leftOf(box.front), axis));
    const middle = dot(box.center, axis);
    return [middle - reach, middle + reach];
  };
  return [...axes(left), ...axes(right)].every((axis) => {
    const [a0, a1] = extent(left, axis);
    const [b0, b1] = extent(right, axis);
    return a1 > b0 && b1 > a0;
  });
}

// Whether a point lies within margin of a placed row's footprint rectangle. The rings
// round a stop start inside its shelter's plan, which the occupied items leave out.
function inFootprint(row, xz, margin) {
  const [dx, dz] = [xz[0] - row.position_m[0], xz[1] - row.position_m[2]];
  const [c, s] = [Math.cos(row.yaw_radians), Math.sin(row.yaw_radians)];
  return Math.abs(dx * c - dz * s) < row.footprint_m.x_m / 2 + margin && Math.abs(dx * s + dz * c) < row.footprint_m.z_m / 2 + margin;
}

// Plan distance (m) from a point to a placed row's footprint rectangle (its stadium).
function streetFootprintDistance(row, xz) {
  const piece = footprintPiece([row.position_m[0], row.position_m[2]], row.yaw_radians, row.footprint_m);
  return (piece.points.length > 1 ? distanceToPolyline(xz, piece.points) : length(sub(xz, piece.points[0]))) - piece.radius;
}

// Points along a polyline about every step metres, its vertices included.
function samplePolyline(points, step) {
  const samples = [points[0]];
  for (let index = 1; index < points.length; index += 1) {
    const a = points[index - 1];
    const b = points[index];
    const steps = Math.max(1, Math.ceil(length(sub(b, a)) / step));
    for (let k = 1; k <= steps; k += 1) samples.push(add(a, scale(sub(b, a), k / steps)));
  }
  return samples;
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
