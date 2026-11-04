// Street yards: the storage, vehicle and food-truck yards of
// PlayableWorld/StreetDetail (the large clutter). A zone of
// tools/config/street-detail-zones.json becomes a yard by listing "yard" rules,
// each one production inference from the dated aerial and Street View it names:
//
//   pack       kit props packed along straight lines (container rows, vehicle
//              rows, boats on trailers): each line is filled slot by slot from
//              a weighted item mix, with a gap between items and a fill ratio;
//   span       one long kit prop per line, sized to the line (a self-storage
//              shed row by its bays, a fabric shed, a berm, a container wall);
//   wall       container walls along a traced perimeter polyline: one
//              container_wall prop per straight leg, trimmed at the corners and
//              cut open at the gates (openings).
//
// pack and span lines are [u0, v0, u1, v1]: in the rule's frame (metres along
// U = (cos a, sin a) and V = (-sin a, cos a) in world x, z from origin_xz, a =
// angle_deg), or in world x, z without a frame. Seen from above with north up,
// a line's left is (dz, -dx) of its direction (dx, dz), as for the fences. A
// pack line may add a fifth value, its own facing. facing names where an
// item's local -Z points (a vehicle's nose, a container's blank end; its doors
// face +Z): left or right of the line across it, forward or backward along it.
// anchor (across only) puts the item's -Z end (minus_z) or +Z end (plus_z) on
// the line instead of its middle, so back-to-back container rows share a spine.
// skew_deg (across, middle anchor only) turns every item by that angle from
// across the line, as in angled parking; side by side, the items stand that
// much further apart along the line, so their gap stays gap_m.
// allow_roads names OSM roads the items may stand over (a parking-lot aisle
// mapped through the parked vans, or one a container wall now closes); every
// other OSM road stays clear. Long props rest without roll and with a small
// pitch along their length; segment_m splits a span line or a wall stretch
// into equal parts no longer than it, each resting on its own, so a long row
// steps down a steeper slope.
//
// Items are the yard kit's props (tools/lib/street-yard-kit.mjs, drawn by the
// street-clutter builder): clutter-layer rows of the prop's own kind with their
// plan rectangle (footprint_m), at rest on the visible ground (pitch, roll and
// lift in prop_params). A param given as {value: weight, ...} is drawn per item.
// Every draw is seeded by the row's identity, so the yards are deterministic.
// An item keeps the gameplay mask, the land, OSM buildings and roads and every
// placed row; one that cannot is left out and counted in the audit.

import { createHash } from "node:crypto";

import { YARD_KIT_KEYS, YARD_KIT_PROPS, YARD_MAX_FLOAT_M, YARD_MAX_SINK_M, containerWallLayout, yardCornerGaps, yardPropFootprint, yardPropParamsError } from "./street-yard-kit.mjs";
import { invariant, roundCoordinate } from "./world-contract.mjs";

export const STREET_YARD_PATTERNS = Object.freeze(["pack", "span", "wall"]);
const COMMON_FIELDS = Object.freeze(["basis", "evidence", "id", "pattern", "rule"]);
const PATTERN_FIELDS = Object.freeze({
  pack: { required: ["lines", "orient", "facing", "items", "gap_m", "fill"], optional: ["frame", "anchor", "align", "jitter_m", "jitter_deg", "skew_deg", "allow_roads"] },
  span: { required: ["lines", "prop", "params", "facing"], optional: ["frame", "align", "allow_roads", "segment_m"] },
  wall: { required: ["line_xz", "inside", "params"], optional: ["closed", "openings", "align", "segment_m", "allow_roads"] },
});
const SAFE_ID = /^[a-z0-9_]+$/u;
// The prop a wall rule places, and the params a span sizes to its line.
const WALL_PROP = "container_wall";
const SIZE_PARAMS = Object.freeze({ storage_shed_row: "bays", fabric_shed: "bays", plastic_berm: "modules", container_wall: "length_m" });
// Long props rest without roll and at most LONG_MAX_PITCH_RAD of pitch along
// their length, as the kit asks; on steeper ground segment_m steps them down.
const LONG_PROPS = Object.freeze(Object.keys(SIZE_PARAMS));
const LONG_MAX_PITCH_RAD = 0.03;
// An item may sink this far into the visible ground at its lowest point (the
// corner castings and tyres hide it), which keeps its other corners down. A
// long prop on uneven ground splits the difference, sinking at most
// LONG_REST_SINK_M (its walls run into the ground) rather than floating.
const REST_SINK_M = 0.03;
const LONG_REST_SINK_M = 0.15;
// Clear space an item keeps (m): from an OSM building wall, and between two
// items of the yards (they may stand close, as containers do, but not touch).
const BUILDING_CLEAR_M = 0.3;
const ITEM_CLEAR_M = 0.05;
// Clearance pieces: the rectangle in strips along its long side, each at most
// this wide, each held by a stadium this much wider than the strip.
const STRIP_MAX_M = 0.8;
const STRIP_EXTRA_M = 0.05;
// Plan sampling for the building and road tests (m).
const SAMPLE_STEP_M = 0.5;
// Back-to-back rows anchored on one spine keep this much between them (m).
const SPINE_GAP_M = 0.12;
// The gap between the parts of a span or wall split by segment_m (m): a long
// shed row or container wall steps with the ground part by part.
const SEGMENT_GAP_M = 0.12;
// The steepest rest the kit takes (radians, its pitch and roll params).
const MAX_REST_RAD = 0.35;
// Ground samples along a long side are at most this far apart (m).
const REST_SAMPLE_M = 3;

const isFiniteNumber = (value) => typeof value === "number" && Number.isFinite(value);
const isXZ = (value) => Array.isArray(value) && value.length === 2 && value.every(isFiniteNumber);
const isPlainObject = (value) => value != null && typeof value === "object" && !Array.isArray(value);
const sub = (a, b) => [a[0] - b[0], a[1] - b[1]];
const add = (a, b) => [a[0] + b[0], a[1] + b[1]];
const scale = (a, s) => [a[0] * s, a[1] * s];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1];
const length = (a) => Math.hypot(a[0], a[1]);
const unit = (a) => {
  const l = length(a);
  invariant(l > 1e-9, "Street yard direction has no length");
  return [a[0] / l, a[1] / l];
};
const leftOf = (d) => [d[1], -d[0]];
const round3 = (value) => roundCoordinate(value);

export function isYardZone(zone) {
  return Array.isArray(zone?.yard) && zone.yard.length > 0;
}

function hashUnit(seed, identity, slot) {
  return createHash("sha256").update(`${seed}|${identity}|${slot}`, "utf8").digest().readUInt32BE(0) / 0xffffffff;
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

// A param value or a weighted choice of values ({value: weight}); numeric
// choices are written as their decimal text.
function validateParamValue(value, label) {
  if (!isPlainObject(value)) return;
  const entries = Object.entries(value);
  invariant(entries.length > 0 && entries.every(([, weight]) => isFiniteNumber(weight) && weight > 0), `${label} weights must be positive numbers`);
}

function drawParams(params, seed, identity) {
  const drawn = {};
  for (const [name, value] of Object.entries(params).sort(([left], [right]) => (left < right ? -1 : 1))) {
    if (!isPlainObject(value)) {
      drawn[name] = value;
      continue;
    }
    const choice = pickWeighted(value, hashUnit(seed, identity, `param:${name}`));
    drawn[name] = /^-?\d+(\.\d+)?$/u.test(choice) ? Number(choice) : choice;
  }
  return drawn;
}

// Every value a param may draw, for validating the rule against the kit up front.
function paramCombinations(params) {
  let combinations = [{}];
  for (const [name, value] of Object.entries(params)) {
    const options = isPlainObject(value) ? Object.keys(value).map((choice) => (/^-?\d+(\.\d+)?$/u.test(choice) ? Number(choice) : choice)) : [value];
    combinations = combinations.flatMap((combination) => options.map((option) => ({ ...combination, [name]: option })));
  }
  return combinations;
}

function validateLines(lines, label, facings = []) {
  invariant(Array.isArray(lines) && lines.length > 0, `${label} needs lines`);
  for (const line of lines) {
    const own = line?.length === 5 && facings.includes(line[4]);
    invariant(Array.isArray(line) && (line.length === 4 || own) && line.slice(0, 4).every(isFiniteNumber) && Math.hypot(line[2] - line[0], line[3] - line[1]) > 0.5,
      `${label} lines are [u0, v0, u1, v1${facings.length > 0 ? `, optional facing ${facings.join("/")}` : ""}] at least 0.5 m long`);
  }
}

function validateRanges(ranges, label) {
  invariant(Array.isArray(ranges), `${label} must be a list`);
  let previous = -Infinity;
  for (const range of ranges) {
    invariant(Array.isArray(range) && range.length === 2 && range.every(isFiniteNumber) && range[0] >= previous && range[1] > range[0], `${label} are ordered [from_m, to_m]`);
    previous = range[1];
  }
}

export function validateYardRules(zone, kinds) {
  if (zone.yard == null) return;
  invariant(Array.isArray(zone.yard), `Street detail zone ${zone.id} yard must be a list`);
  invariant(zone.shape?.type === "polygon", `Street detail zone ${zone.id}: a yard zone is a polygon (the yard's boundary from the aerial)`);
  const ids = new Set();
  for (const rule of zone.yard) {
    const label = `Street detail zone ${zone.id} yard rule ${rule?.id}`;
    invariant(typeof rule?.id === "string" && SAFE_ID.test(rule.id) && !ids.has(rule.id), `${label} needs a unique lower_snake id`);
    ids.add(rule.id);
    invariant(STREET_YARD_PATTERNS.includes(rule.pattern), `${label} pattern must be one of ${STREET_YARD_PATTERNS.join(", ")}`);
    const fields = PATTERN_FIELDS[rule.pattern];
    const allowed = [...COMMON_FIELDS, ...fields.required, ...fields.optional];
    invariant(Object.keys(rule).every((key) => allowed.includes(key)), `${label} has fields outside ${allowed.sort().join(", ")}`);
    invariant([...COMMON_FIELDS, ...fields.required].every((key) => key in rule), `${label} needs ${[...COMMON_FIELDS, ...fields.required].join(", ")}`);
    invariant(rule.basis === "production_inference", `${label}: yard rules are production_inference`);
    for (const field of ["rule", "evidence"]) invariant(typeof rule[field] === "string" && rule[field].trim() !== "", `${label} needs ${field}`);
    if (rule.frame !== undefined) {
      invariant(isPlainObject(rule.frame) && JSON.stringify(Object.keys(rule.frame).sort()) === JSON.stringify(["angle_deg", "origin_xz"]), `${label} frame is {origin_xz, angle_deg}`);
      invariant(isXZ(rule.frame.origin_xz) && isFiniteNumber(rule.frame.angle_deg), `${label} frame needs origin_xz [x, z] and angle_deg`);
    }
    if (rule.align !== undefined) invariant(["start", "center", "end"].includes(rule.align), `${label} align is start, center or end`);
    if (rule.allow_roads !== undefined) invariant(Array.isArray(rule.allow_roads) && rule.allow_roads.length > 0 && rule.allow_roads.every((key) => /^w\d+$/u.test(key)), `${label} allow_roads lists OSM way keys`);
    if (rule.segment_m !== undefined) invariant(isFiniteNumber(rule.segment_m) && rule.segment_m >= YARD_KIT_PROPS[WALL_PROP].params.length_m.min, `${label} segment_m must be at least ${YARD_KIT_PROPS[WALL_PROP].params.length_m.min} m`);
    const checkProp = (prop, params, itemLabel) => {
      invariant(YARD_KIT_KEYS.includes(prop), `${itemLabel} prop ${prop} is not a yard kit prop`);
      invariant(kinds[prop]?.layer === "clutter", `${itemLabel} prop ${prop} has no clutter kind`);
      invariant(isPlainObject(params) && (Number.isInteger(params.variant) || isPlainObject(params.variant)), `${itemLabel} params need a variant (an index or weighted indices)`);
      for (const [name, value] of Object.entries(params)) validateParamValue(value, `${itemLabel} param ${name}`);
    };
    if (rule.pattern === "pack") {
      invariant(["across", "along"].includes(rule.orient), `${label} orient is across or along`);
      const facings = rule.orient === "across" ? ["left", "right"] : ["forward", "backward"];
      invariant(facings.includes(rule.facing), `${label} facing is left/right across a line, forward/backward along it`);
      validateLines(rule.lines, label, facings);
      invariant(rule.anchor === undefined || (rule.orient === "across" && ["center", "minus_z", "plus_z"].includes(rule.anchor)), `${label} anchor (across only) is center, minus_z or plus_z`);
      invariant(rule.skew_deg === undefined || (rule.orient === "across" && (rule.anchor ?? "center") === "center" && isFiniteNumber(rule.skew_deg) && Math.abs(rule.skew_deg) <= 60), `${label} skew_deg (across, middle anchor only) is at most 60 degrees either way`);
      invariant(Array.isArray(rule.items) && rule.items.length > 0, `${label} needs items`);
      rule.items.forEach((item, index) => {
        const itemLabel = `${label} item ${index}`;
        invariant(isPlainObject(item) && JSON.stringify(Object.keys(item).sort()) === JSON.stringify(["params", "prop", "weight"]), `${itemLabel} is {weight, prop, params}`);
        invariant(isFiniteNumber(item.weight) && item.weight > 0, `${itemLabel} weight must be positive`);
        checkProp(item.prop, item.params, itemLabel);
        for (const params of paramCombinations(item.params)) {
          const error = yardPropParamsError(item.prop, params);
          invariant(error === null, `${itemLabel}: ${error}`);
        }
      });
      invariant(Array.isArray(rule.gap_m) && rule.gap_m.length === 2 && rule.gap_m.every(isFiniteNumber) && rule.gap_m[0] >= 0 && rule.gap_m[1] >= rule.gap_m[0], `${label} gap_m is [min, max]`);
      invariant(isFiniteNumber(rule.fill) && rule.fill > 0 && rule.fill <= 1, `${label} fill must be in (0, 1]`);
      for (const field of ["jitter_m", "jitter_deg"]) invariant(rule[field] === undefined || (isFiniteNumber(rule[field]) && rule[field] >= 0), `${label} ${field} must be non-negative`);
    } else if (rule.pattern === "span") {
      validateLines(rule.lines, label);
      invariant(SIZE_PARAMS[rule.prop] !== undefined, `${label} prop must be one of ${Object.keys(SIZE_PARAMS).join(", ")}`);
      checkProp(rule.prop, rule.params, label);
      invariant(!(SIZE_PARAMS[rule.prop] in rule.params), `${label} params leave out ${SIZE_PARAMS[rule.prop]}, which the line sets`);
      const sizeSpec = YARD_KIT_PROPS[rule.prop].params[SIZE_PARAMS[rule.prop]];
      for (const params of paramCombinations(rule.params)) {
        const error = yardPropParamsError(rule.prop, { ...params, [SIZE_PARAMS[rule.prop]]: sizeSpec.min });
        invariant(error === null, `${label}: ${error}`);
      }
      invariant(["forward", "backward"].includes(rule.facing), `${label} facing is forward or backward`);
    } else if (rule.pattern === "wall") {
      invariant(Array.isArray(rule.line_xz) && rule.line_xz.length >= 2 && rule.line_xz.every(isXZ), `${label} line_xz needs 2+ [x, z] points`);
      invariant(rule.closed === undefined || typeof rule.closed === "boolean", `${label} closed must be boolean`);
      invariant(["left", "right"].includes(rule.inside), `${label} inside is left or right`);
      checkProp(WALL_PROP, rule.params, label);
      invariant(Number.isInteger(rule.params.variant), `${label} needs a fixed variant`);
      invariant(!("length_m" in rule.params), `${label} params leave out length_m, which each leg sets`);
      for (const params of paramCombinations(rule.params)) {
        const error = yardPropParamsError(WALL_PROP, { ...params, length_m: YARD_KIT_PROPS[WALL_PROP].params.length_m.min });
        invariant(error === null, `${label}: ${error}`);
      }
      if (rule.openings !== undefined) validateRanges(rule.openings, `${label} openings`);
    }
  }
}

// The plan of a placed yard row: its centre, local X and Z axes in world x, z
// and half sizes; a container wall counts only the stretch its containers cover.
function rowRectangle(row) {
  const yaw = row.yaw_radians;
  const axisX = [Math.cos(yaw), -Math.sin(yaw)];
  const axisZ = [Math.sin(yaw), Math.cos(yaw)];
  let centre = [row.position_m[0], row.position_m[2]];
  let halfZ = row.footprint_m.z_m / 2;
  if (row.prop === WALL_PROP) {
    const covered = containerWallLayout(row.prop_params).covered_m;
    centre = add(centre, scale(axisZ, -halfZ + covered / 2));
    halfZ = covered / 2;
  }
  return { centre, axisX, axisZ, halfX: row.footprint_m.x_m / 2, halfZ };
}

function rectanglePieces({ centre, axisX, axisZ, halfX, halfZ }) {
  const long = halfZ >= halfX ? { axis: axisZ, half: halfZ } : { axis: axisX, half: halfX };
  const short = halfZ >= halfX ? { axis: axisX, half: halfX } : { axis: axisZ, half: halfZ };
  const strips = Math.max(1, Math.ceil((short.half * 2) / STRIP_MAX_M));
  const width = (short.half * 2) / strips;
  const radius = width / 2 + STRIP_EXTRA_M;
  const half = Math.max(0, long.half - Math.sqrt(radius * radius - (width / 2) ** 2));
  const pieces = [];
  for (let index = 0; index < strips; index += 1) {
    const middle = add(centre, scale(short.axis, -short.half + width * (index + 0.5)));
    pieces.push({
      points: half < 1e-6 ? [middle] : [add(middle, scale(long.axis, -half)), add(middle, scale(long.axis, half))],
      radius,
    });
  }
  return pieces;
}

// Clearance pieces of a placed yard row (the gameplay mask, the overlap checks
// and the shut-in flood of tools/check_street_detail_clearance.mjs): its plan
// rectangle in narrow strips, each held by a stadium, so the pieces stay within
// a few centimetres of the rectangle.
export function yardRowPieces(row) {
  return rectanglePieces(rowRectangle(row));
}

export function isYardRow(row) {
  return row.layer === "clutter" && YARD_KIT_KEYS.includes(row.prop) && row.footprint_m != null;
}

function rectanglesOverlap(left, right, clearance) {
  const axes = [left.axisX, left.axisZ, right.axisX, right.axisZ];
  const offset = sub(right.centre, left.centre);
  for (const axis of axes) {
    const reach = (rect) => Math.abs(dot(rect.axisX, axis)) * rect.halfX + Math.abs(dot(rect.axisZ, axis)) * rect.halfZ;
    if (Math.abs(dot(offset, axis)) >= reach(left) + reach(right) + clearance) return false;
  }
  return true;
}

function rectangleSamples({ centre, axisX, axisZ, halfX, halfZ }, step) {
  const samples = [];
  const nx = Math.max(1, Math.ceil((halfX * 2) / step));
  const nz = Math.max(1, Math.ceil((halfZ * 2) / step));
  for (let i = 0; i <= nx; i += 1) {
    for (let j = 0; j <= nz; j += 1) {
      // The edges and an inner grid at four steps.
      const edge = i === 0 || i === nx || j === 0 || j === nz;
      if (!edge && (i % 4 !== 0 || j % 4 !== 0)) continue;
      samples.push(add(centre, add(scale(axisX, -halfX + (halfX * 2 * i) / nx), scale(axisZ, -halfZ + (halfZ * 2 * j) / nz))));
    }
  }
  return samples;
}

// Places the yards: rows of the zones' yard rules. Returns {rows, audit}.
export function placeStreetYards({ config, kinds, zoneShapes, seed, occupied, hardShapes, hardViolation, buildings, roads, onLand, grounded, surfaceAt, groundAt, exclusions }) {
  const audit = { rules: {}, rejected_by_reason: {}, rest: { max_tilt_rad: 0, max_float_m: 0, max_float_row: null, max_sink_m: 0, max_sink_row: null } };
  const count = (table, key) => {
    table[key] = (table[key] ?? 0) + 1;
  };
  const rows = [];
  const placed = [];
  const yardShapes = zoneShapes.filter(({ zone }) => isYardZone(zone));

  // The visible ground under a plan point, or null off the generated surfaces.
  const groundY = (xz) => groundAt(xz)?.y ?? null;
  // An item's rest on the visible ground: the plane through the ground under
  // its rectangle (least squares), raised until no sample is more than the
  // allowed sink above it; addItem then holds it to the kit's corner limits.
  const rest = (rect, prop) => {
    const samples = [];
    const nx = Math.max(1, Math.ceil((rect.halfX * 2) / REST_SAMPLE_M));
    const nz = Math.max(1, Math.ceil((rect.halfZ * 2) / REST_SAMPLE_M));
    for (let i = 0; i <= nx; i += 1) {
      for (let j = 0; j <= nz; j += 1) {
        const x = -rect.halfX + (rect.halfX * 2 * i) / nx;
        const z = -rect.halfZ + (rect.halfZ * 2 * j) / nz;
        const y = groundY(add(rect.centre, add(scale(rect.axisX, x), scale(rect.axisZ, z))));
        if (y === null) return { problem: "no_ground" };
        samples.push([x, z, y]);
      }
    }
    // y = h + a x + b z through the samples (a long prop: no roll, a capped pitch).
    const long = LONG_PROPS.includes(prop);
    const n = samples.length;
    const sx = samples.reduce((sum, [x]) => sum + x * x, 0);
    const sz = samples.reduce((sum, [, z]) => sum + z * z, 0);
    const mean = samples.reduce((sum, [, , y]) => sum + y, 0) / n;
    const a = sx > 0 && !long ? samples.reduce((sum, [x, , y]) => sum + x * (y - mean), 0) / sx : 0;
    let b = sz > 0 ? samples.reduce((sum, [, z, y]) => sum + z * (y - mean), 0) / sz : 0;
    if (long) b = Math.max(-Math.tan(LONG_MAX_PITCH_RAD), Math.min(Math.tan(LONG_MAX_PITCH_RAD), b));
    // Raised until no sample is more than the allowed sink above it.
    const residuals = samples.map(([x, z, y]) => y - (mean + a * x + b * z));
    const top = Math.max(...residuals);
    const raise = long ? Math.max((top + Math.min(...residuals)) / 2, top - LONG_REST_SINK_M) : top - REST_SINK_M;
    // pitch raises the -Z end, roll the left (-X) side, as for the parked cars.
    const pitch = Math.atan(-b);
    const roll = Math.atan(-a);
    if (Math.abs(pitch) > MAX_REST_RAD || Math.abs(roll) > MAX_REST_RAD) return { problem: "steep_ground" };
    return { height: mean + raise, pitch, roll };
  };

  // Why an item cannot stand at its rectangle, or null.
  const reject = (zoneShape, rect, allowRoads) => {
    if (!zoneShape.contains(rect.centre)) return "outside_zone";
    const corners = [[-1, -1], [1, -1], [1, 1], [-1, 1]].map(([i, j]) => add(rect.centre, add(scale(rect.axisX, i * rect.halfX), scale(rect.axisZ, j * rect.halfZ))));
    if (!corners.every((corner) => onLand(corner, exclusions.land_edge_buffer_m))) return "land_edge";
    const pieces = rectanglePieces(rect);
    for (const piece of pieces) {
      const hard = hardViolation(hardShapes, piece.points, piece.radius);
      if (hard) return hard.reason;
    }
    const reach = Math.hypot(rect.halfX, rect.halfZ) + BUILDING_CLEAR_M;
    if (buildings.nearest(rect.centre, reach).distance < reach) {
      for (const sample of rectangleSamples(rect, SAMPLE_STEP_M)) {
        if (buildings.nearest(sample, BUILDING_CLEAR_M).distance < BUILDING_CLEAR_M) return "building";
      }
      // A small building inside a large item's rectangle.
      for (const item of buildings.items) {
        const first = item.geometry[0][0][0];
        const local = sub([first[0], -first[1]], rect.centre);
        if (Math.abs(dot(local, rect.axisX)) < rect.halfX && Math.abs(dot(local, rect.axisZ)) < rect.halfZ) return "building";
      }
    }
    if (roads.nearest(rect.centre, reach).distance < reach) {
      for (const sample of rectangleSamples(rect, SAMPLE_STEP_M)) {
        if (roads.containing(sample).some((item) => !allowRoads.includes(item.key))) return "road";
      }
    }
    for (const other of placed) {
      if (length(sub(other.rect.centre, rect.centre)) > Math.hypot(rect.halfX, rect.halfZ) + Math.hypot(other.rect.halfX, other.rect.halfZ) + ITEM_CLEAR_M) continue;
      if (rectanglesOverlap(rect, other.rect, ITEM_CLEAR_M)) return "overlap";
    }
    for (const item of occupied) {
      if (item.yard) continue;
      for (const piece of pieces) {
        const near = item.points.length > 1 || piece.points.length > 1
          ? segmentsDistance(piece.points, item.points)
          : length(sub(piece.points[0], item.points[0]));
        if (near < item.radius_m + piece.radius) return "item";
      }
    }
    return null;
  };

  // One item: its row when it stands, else the reason it doesn't.
  const addItem = (zone, rule, cell, prop, params, centre, front) => {
    const footprint = yardPropFootprint(prop, params);
    const yaw = roundCoordinate(Math.atan2(-front[0], -front[1]));
    const rect = rowRectangle({ position_m: [centre[0], 0, centre[1]], yaw_radians: yaw, footprint_m: footprint, prop, prop_params: params });
    const zoneShape = yardShapes.find((shape) => shape.zone === zone);
    const problem = reject(zoneShape, rect, rule.allow_roads ?? []);
    if (problem) return { problem };
    const settled = rest(rect, prop);
    if (settled.problem) return settled;
    const xz = [round3(centre[0]), round3(centre[1])];
    const { y, support } = grounded(xz);
    const surface = surfaceAt(xz);
    const angle = (value) => Math.round(value * 1e4) / 1e4 || 0;
    // The kit's rest limits, as the validator checks them on the plan's
    // corners: lowered until no corner floats more than YARD_MAX_FLOAT_M, and
    // left out where a corner then sinks more than YARD_MAX_SINK_M.
    const base = y + surface.bias_m;
    const restParams = { pitch: angle(settled.pitch), roll: angle(settled.roll), lift: round3(settled.height - base) };
    const gaps = yardCornerGaps(footprint, xz, yaw, base, restParams, groundAt);
    if (gaps.some((gap) => gap === null)) return { problem: "no_ground" };
    const drop = Math.max(0, Math.max(...gaps) - YARD_MAX_FLOAT_M);
    if (gaps.some((gap) => gap - drop < -YARD_MAX_SINK_M)) return { problem: "uneven_ground" };
    restParams.lift = round3(restParams.lift - drop);
    const settledGaps = gaps.map((gap) => gap - drop);
    const row = {
      id: `scatter:${zone.id}:${rule.id}:${cell}`,
      source: "scatter",
      source_id: `zone:${zone.id}/${rule.id}`,
      kind: prop,
      layer: kinds[prop].layer,
      geometry: "point",
      position_m: [xz[0], y, xz[1]],
      terrain_support: { object_key: support.object_key, triangle_index: support.triangle_index, elevation_m: support.elevation_m },
      surface,
      yaw_radians: yaw,
      yaw_source: `rule:${zone.id}/${rule.id}`,
      status: "placed",
      exclusion: null,
      prop,
      prop_params: { ...params, ...restParams },
      footprint_m: { x_m: footprint.x_m, z_m: footprint.z_m },
      basis: rule.basis,
    };
    const paramError = yardPropParamsError(prop, row.prop_params);
    invariant(paramError === null, `${row.id}: ${paramError}`);
    rows.push(row);
    placed.push({ id: row.id, rect: rowRectangle(row) });
    for (const piece of yardRowPieces(row)) occupied.push({ id: row.id, points: piece.points, radius_m: piece.radius, yard: true });
    // The audit reports the corner gaps the validator checks.
    const float = Math.max(0, ...settledGaps);
    const sink = Math.max(0, ...settledGaps.map((gap) => -gap));
    audit.rest.max_tilt_rad = Math.max(audit.rest.max_tilt_rad, Math.abs(restParams.pitch), Math.abs(restParams.roll));
    if (float > audit.rest.max_float_m) Object.assign(audit.rest, { max_float_m: round3(float), max_float_row: row.id });
    if (sink > audit.rest.max_sink_m) Object.assign(audit.rest, { max_sink_m: round3(sink), max_sink_row: row.id });
    count(audit.rules, `${zone.id}/${rule.id}`);
    return { row };
  };

  // A rule's lines in world x, z.
  const worldLines = (rule) => rule.lines.map(([u0, v0, u1, v1]) => {
    if (!rule.frame) return [[u0, v0], [u1, v1]];
    const a = (rule.frame.angle_deg * Math.PI) / 180;
    const axisU = [Math.cos(a), Math.sin(a)];
    const axisV = [-Math.sin(a), Math.cos(a)];
    const at = (u, v) => add(rule.frame.origin_xz, add(scale(axisU, u), scale(axisV, v)));
    return [at(u0, v0), at(u1, v1)];
  });
  const alignShift = (align, free) => (align === "center" ? free / 2 : align === "end" ? free : 0);

  for (const { zone } of yardShapes) {
    for (const rule of zone.yard) {
      audit.rules[`${zone.id}/${rule.id}`] = 0;
      const reasonKey = (problem) => `${zone.id}/${rule.id}:${problem}`;
      if (rule.pattern === "pack") {
        worldLines(rule).forEach(([start, end], lineIndex) => {
          const total = length(sub(end, start));
          const direction = unit(sub(end, start));
          const left = leftOf(direction);
          const facing = rule.lines[lineIndex][4] ?? rule.facing;
          const skew = ((rule.skew_deg ?? 0) * Math.PI) / 180;
          // Side by side, a skewed item takes 1 / cos(skew) more of the line.
          const stretch = 1 / Math.cos(skew);
          // Slots first, so the packed run can be aligned on its line.
          const slots = [];
          let at = 0;
          for (let slot = 0; ; slot += 1) {
            const cell = `l${String(lineIndex).padStart(2, "0")}s${String(slot).padStart(3, "0")}`;
            const identity = `${zone.id}:${rule.id}:${cell}`;
            const weights = Object.fromEntries(rule.items.map((item, index) => [String(index).padStart(2, "0"), item.weight]));
            const item = rule.items[Number(pickWeighted(weights, hashUnit(seed, identity, "item")))];
            const params = drawParams(item.params, seed, identity);
            const footprint = yardPropFootprint(item.prop, params);
            const along = rule.orient === "across" ? footprint.x_m * stretch : footprint.z_m;
            if (at + along > total + 1e-6) break;
            slots.push({ cell, identity, item, params, footprint, at, along, filled: hashUnit(seed, identity, "fill") < rule.fill });
            at += along + (rule.gap_m[0] + (rule.gap_m[1] - rule.gap_m[0]) * hashUnit(seed, identity, "gap")) * stretch;
          }
          if (slots.length === 0) return;
          const shift = alignShift(rule.align, total - (slots.at(-1).at + slots.at(-1).along));
          for (const slot of slots) {
            if (!slot.filled) {
              count(audit.rejected_by_reason, reasonKey("fill"));
              continue;
            }
            const jitter = rule.jitter_m ?? 0;
            const turn = skew + (((rule.jitter_deg ?? 0) * Math.PI) / 180) * (hashUnit(seed, slot.identity, "yaw") * 2 - 1);
            let front = rule.orient === "across" ? (facing === "left" ? left : scale(left, -1)) : (facing === "forward" ? direction : scale(direction, -1));
            const anchor = rule.anchor ?? "center";
            // The item's -Z end (minus_z) or +Z end (plus_z) on the line, else its middle.
            // An anchored end keeps half the spine gap from the line, and its
            // jitter only moves it away from the line.
            const away = SPINE_GAP_M / 2 + jitter * hashUnit(seed, slot.identity, "across");
            const lateral = anchor === "minus_z" ? -(slot.footprint.z_m / 2 + away) : anchor === "plus_z" ? slot.footprint.z_m / 2 + away : 0;
            let centre = add(start, scale(direction, shift + slot.at + slot.along / 2 + jitter * (hashUnit(seed, slot.identity, "along") * 2 - 1)));
            centre = add(centre, scale(front, lateral));
            if (anchor === "center") centre = add(centre, scale(left, jitter * (hashUnit(seed, slot.identity, "across") * 2 - 1)));
            front = [front[0] * Math.cos(turn) - front[1] * Math.sin(turn), front[0] * Math.sin(turn) + front[1] * Math.cos(turn)];
            const result = addItem(zone, rule, slot.cell, slot.item.prop, slot.params, centre, front);
            if (result.problem) count(audit.rejected_by_reason, reasonKey(result.problem));
          }
        });
      } else if (rule.pattern === "span") {
        const sizeParam = SIZE_PARAMS[rule.prop];
        worldLines(rule).forEach(([lineStart, lineEnd], lineIndex) => {
          const lineTotal = length(sub(lineEnd, lineStart));
          const direction = unit(sub(lineEnd, lineStart));
          const front = rule.facing === "forward" ? direction : scale(direction, -1);
          // The line's parts, each sized to its share; the sized parts stand end
          // to end SEGMENT_GAP_M apart and the run is aligned on the line, so
          // any length the sizes leave over goes to the line's ends.
          const parts = segments(lineTotal, rule.segment_m).map((part) => {
            const cell = `l${String(lineIndex).padStart(2, "0")}${part.label}`;
            const params = drawParams(rule.params, seed, `${zone.id}:${rule.id}:${cell}`);
            return { cell, sized: fitSize(rule.prop, params, sizeParam, part.length) };
          });
          if (parts.some((part) => !part.sized)) {
            count(audit.rejected_by_reason, reasonKey("line_too_short"));
            return;
          }
          const used = parts.reduce((sum, part) => sum + part.sized.footprint.z_m, 0) + SEGMENT_GAP_M * (parts.length - 1);
          let at = alignShift(rule.align, lineTotal - used);
          for (const part of parts) {
            const along = part.sized.footprint.z_m;
            const centre = add(lineStart, scale(direction, at + along / 2));
            at += along + SEGMENT_GAP_M;
            const result = addItem(zone, rule, part.cell, rule.prop, part.sized.params, centre, front);
            if (result.problem) count(audit.rejected_by_reason, reasonKey(result.problem));
          }
        });
      } else if (rule.pattern === "wall") {
        const points = rule.line_xz.map((point) => [...point]);
        if (rule.closed) points.push([...points[0]]);
        const half = YARD_KIT_PROPS[WALL_PROP].variants[rule.params.variant].x_m / 2;
        const openings = rule.openings ?? [];
        let walked = 0;
        for (let leg = 1; leg < points.length; leg += 1) {
          const start = points[leg - 1];
          const end = points[leg];
          const total = length(sub(end, start));
          const direction = unit(sub(end, start));
          const inward = rule.inside === "left" ? leftOf(direction) : scale(leftOf(direction), -1);
          // A leg after a corner starts clear of the wall that runs into the corner.
          // Only a corner that turns toward the inside (convex) overlaps.
          let trim = 0;
          if (leg > 1 || rule.closed) {
            const before = unit(sub(start, points[leg === 1 ? points.length - 2 : leg - 2]));
            const turn = Math.atan2(dot(direction, leftOf(before)), dot(before, direction));
            const convex = rule.inside === "left" ? turn > 0 : turn < 0;
            if (convex && Math.abs(turn) > 0.35) trim = Math.min(total, (half * 2) / Math.max(0.5, Math.sin(Math.abs(turn))));
          }
          // The leg's stretches between the openings.
          let pieces = [[trim, total]];
          for (const [from, to] of openings) {
            const a = from - walked;
            const b = to - walked;
            pieces = pieces.flatMap(([p0, p1]) => [[p0, Math.min(p1, a)], [Math.max(p0, b), p1]]).filter(([p0, p1]) => p1 - p0 > 0.05);
          }
          pieces.forEach(([piece0, piece1], pieceIndex) => wallParts(piece0, piece1, rule.segment_m, rule.align === "end").forEach((part) => {
            const [p0, p1] = [part.from, part.to];
            const cell = `g${String(leg - 1).padStart(2, "0")}p${pieceIndex}${part.label}`;
            const params = drawParams(rule.params, seed, `${zone.id}:${rule.id}:${cell}`);
            const run = p1 - p0;
            if (run < containerWallLayoutMinimum()) {
              count(audit.rejected_by_reason, reasonKey("leg_too_short"));
              return;
            }
            const wallParams = { ...params, length_m: round3(run) };
            // The containers fill the run from its -Z end: turn that end to
            // the stretch's start (align start) or its end (align end).
            const fromEnd = rule.align === "end";
            const front = fromEnd ? direction : scale(direction, -1);
            const centre = add(add(start, scale(direction, (p0 + p1) / 2)), scale(inward, half));
            const result = addItem(zone, rule, cell, WALL_PROP, wallParams, centre, front);
            if (result.problem) count(audit.rejected_by_reason, reasonKey(result.problem));
          }));
          walked += total;
        }
      }
    }
  }
  return { rows, audit };
}

// A run split into equal parts no longer than segment_m (all of it when
// segment_m is absent), SEGMENT_GAP_M apart: [{from, length, label}].
function segments(total, segmentM) {
  const count = segmentM === undefined ? 1 : Math.max(1, Math.ceil((total + SEGMENT_GAP_M) / (segmentM + SEGMENT_GAP_M)));
  const part = (total - SEGMENT_GAP_M * (count - 1)) / count;
  return Array.from({ length: count }, (_, index) => ({ from: index * (part + SEGMENT_GAP_M), length: part, label: count === 1 ? "" : `s${String(index).padStart(2, "0")}` }));
}

// A wall stretch [p0, p1] in parts of segment_m (one part without it): each
// part's containers start where the previous part's end, SEGMENT_GAP_M on,
// filling from the stretch's start (from its end when fromEnd), so the parts
// stand container to container; the last part takes what is left.
function wallParts(p0, p1, segmentM, fromEnd) {
  const total = p1 - p0;
  if (segmentM === undefined) return [{ from: p0, to: p1, label: "" }];
  const parts = [];
  let done = 0;
  while (total - done >= containerWallLayoutMinimum()) {
    const last = total - done < segmentM + SEGMENT_GAP_M + containerWallLayoutMinimum();
    const length = last ? total - done : segmentM;
    const label = `s${String(parts.length).padStart(2, "0")}`;
    parts.push(fromEnd ? { from: p1 - done - length, to: p1 - done, label } : { from: p0 + done, to: p0 + done + length, label });
    if (last) break;
    done += containerWallLayout({ length_m: length }).covered_m + SEGMENT_GAP_M;
  }
  return parts.length === 1 ? [{ ...parts[0], label: "" }] : parts;
}

function containerWallLayoutMinimum() {
  return YARD_KIT_PROPS[WALL_PROP].params.length_m.min;
}

// A long prop sized to a line: the largest size param whose plan fits.
function fitSize(prop, params, sizeParam, total) {
  const spec = YARD_KIT_PROPS[prop].params[sizeParam];
  if (spec.type === "number") {
    const value = round3(Math.min(spec.max, total));
    if (value < spec.min) return null;
    const sized = { ...params, [sizeParam]: value };
    return { params: sized, footprint: yardPropFootprint(prop, sized) };
  }
  let best = null;
  for (let value = spec.min; value <= spec.max; value += 1) {
    const sized = { ...params, [sizeParam]: value };
    const footprint = yardPropFootprint(prop, sized);
    if (footprint.z_m > total + 1e-6) break;
    best = { params: sized, footprint };
  }
  return best;
}

// Plan distance between two polylines (a point is a one-point polyline).
function segmentsDistance(left, right) {
  const pointSegment = (p, a, b) => {
    const d = sub(b, a);
    const l2 = dot(d, d);
    const t = l2 > 0 ? Math.max(0, Math.min(1, dot(sub(p, a), d) / l2)) : 0;
    return length(sub(p, add(a, scale(d, t))));
  };
  const pointLine = (p, line) => {
    if (line.length === 1) return length(sub(p, line[0]));
    let best = Infinity;
    for (let index = 1; index < line.length; index += 1) best = Math.min(best, pointSegment(p, line[index - 1], line[index]));
    return best;
  };
  let best = Infinity;
  for (const point of left) best = Math.min(best, pointLine(point, right));
  for (const point of right) best = Math.min(best, pointLine(point, left));
  if (left.length > 1 && right.length > 1) {
    for (let i = 1; i < left.length; i += 1) {
      for (let j = 1; j < right.length; j += 1) {
        if (segmentsCross(left[i - 1], left[i], right[j - 1], right[j])) return 0;
      }
    }
  }
  return best;
}

function segmentsCross(a, b, c, d) {
  const orientation = (p, q, r) => (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0]);
  const d1 = orientation(c, d, a);
  const d2 = orientation(c, d, b);
  const d3 = orientation(a, b, c);
  const d4 = orientation(a, b, d);
  return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
}
