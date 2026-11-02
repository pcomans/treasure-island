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
import { carBodyDimensions, CAR_BODIES } from "./street-clutter-kit.mjs";
import { compareSourceKeys, invariant, roundCoordinate } from "./world-contract.mjs";

// Kit props of the clutter layer, with the row kind each one stands for.
export const STREET_CLUTTER_PROPS = Object.freeze({
  barricade: "barricade",
  parked_car: "parked_car",
  traffic_cone: "traffic_cone",
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
// Clear space kept between a car and street furniture or fence runs.
const ITEM_CLEAR_M = 0.15;
// Bus stops keep this much curb clear on each side.
const BUS_STOP_CLEAR_M = 12;

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
}) {
  const pilotShapes = zoneShapes.filter(({ zone }) => zone.pilot);
  const audit = { rules: {}, rejected_by_reason: {} };
  const count = (table, key) => {
    table[key] = (table[key] ?? 0) + 1;
  };
  const ruleRows = [];
  const placedSegments = [];

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
  const reject = (center, front, footprint, surface, ignoreIds = new Set()) => {
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
      if (ignoreIds.has(item.id)) continue;
      for (const point of piece.points.length > 1 ? sampleSegment(piece.points) : piece.points) {
        const near = item.points.length > 1 ? distanceToPolyline(point, item.points) : Math.hypot(point[0] - item.points[0][0], point[1] - item.points[0][1]);
        if (near < item.radius_m + piece.radius + ITEM_CLEAR_M) return "item";
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
    const paint = body === "utility" ? "white" : pickWeighted(rule.paints, hashUnit(seed, identity, "paint"));
    const finishes = PAINT_FINISHES[paint];
    const finish = finishes[Math.min(finishes.length - 1, Math.floor(hashUnit(seed, identity, "finish") * (finishes.length + 1)) % finishes.length)];
    const roof = body === "crossover" && !["black", "dark_grey", "navy"].includes(paint) && hashUnit(seed, identity, "roof") < 0.22 ? "black" : "body";
    const rims = hashUnit(seed, identity, "rims") < 0.28 ? "dark" : "alloy";
    return { body, paint, finish, roof, rims };
  };
  // Slight tilt with the ground under the wheels (the road drapes the terrain).
  const tilt = (center, front, footprint) => {
    const right = [front[1], -front[0]];
    const reach = footprint.z_m * 0.3;
    const across = footprint.x_m * 0.4;
    const y = (point) => grounded(toWorld(point)).y;
    const yFront = y(add(center, scale(front, reach)));
    const yRear = y(add(center, scale(front, -reach)));
    const yRight = y(add(center, scale(right, across)));
    const yLeft = y(add(center, scale(right, -across)));
    const yCenter = y(center);
    return {
      pitch: roundCoordinate(Math.atan2(yFront - yRear, 2 * reach)),
      roll: roundCoordinate(Math.atan2(yLeft - yRight, 2 * across)),
      lift: roundCoordinate((yFront + yRear + yRight + yLeft) / 4 - yCenter),
    };
  };
  const addCar = (zone, rule, cell, center, front, params, footprint) => {
    const xz = [roundCoordinate(toWorld(center)[0]), roundCoordinate(toWorld(center)[1])];
    const yaw = yawToward(front);
    const row = {
      id: `scatter:${zone.id}:${rule.id}:${cell}`,
      source: "scatter",
      source_id: `zone:${zone.id}/${rule.id}`,
      kind: rule.kind,
      layer: kinds[rule.kind].layer,
      geometry: "point",
      ...surfaceRow(xz),
      yaw_radians: yaw,
      yaw_source: `rule:${zone.id}/${rule.id}`,
      status: "placed",
      exclusion: null,
      prop: rule.prop,
      prop_params: { ...params, ...tilt(center, front, footprint) },
      footprint_m: footprint,
      basis: rule.basis,
    };
    ruleRows.push(row);
    const piece = footprintPiece(xz, yaw, footprint);
    placedSegments.push({ id: row.id, ...piece });
    count(audit.rules, `${zone.id}/${rule.id}`);
    return row;
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
                const dims = carBodyDimensions(params.body);
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
                const problem = reject(center, facing, footprint, "road");
                if (problem) {
                  count(audit.rejected_by_reason, `${rule.id}:${problem}`);
                  s = endS + gap;
                  continue;
                }
                addCar(zone, rule, cell, center, facing, params, footprint);
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
          const dims = carBodyDimensions(params.body);
          const footprint = { x_m: dims.width_m, z_m: dims.length_m };
          // The car's far end 0.3 m short of the stall's back; a long body (a
          // pickup or a van) may reach up to 1.1 m into the aisle, as they do.
          const reachIn = Math.min(stall.depth_m - 0.3, footprint.z_m);
          if (footprint.z_m - reachIn > 1.1) {
            count(audit.rejected_by_reason, `${rule.id}:too_long`);
            continue;
          }
          const along = (hashUnit(seed, identity, "lateral") - 0.5) * 0.24;
          const center = add(add(entry, scale(stall.outward, stall.depth_m - 0.3 - footprint.z_m / 2)), scale(stall.along, along));
          const headIn = hashUnit(seed, identity, "head_in") < rule.head_in;
          const jitter = (hashUnit(seed, identity, "yaw") - 0.5) * 0.06;
          const base = headIn ? stall.outward : scale(stall.outward, -1);
          const facing = [base[0] * Math.cos(jitter) - base[1] * Math.sin(jitter), base[0] * Math.sin(jitter) + base[1] * Math.cos(jitter)];
          const problem = reject(center, facing, footprint, "lot");
          if (problem) {
            count(audit.rejected_by_reason, `${rule.id}:${problem}`);
            continue;
          }
          addCar(zone, rule, cell, center, facing, params, footprint);
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
