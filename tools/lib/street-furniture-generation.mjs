// Street furniture: the vertical street objects of PlayableWorld/StreetDetail/Furniture.
//
// Two sources, both resolved to rows of generated/world/street_detail.json:
//   - OSM rows of a furniture kind (lamps, hydrants, bus stops, stop signs) get a
//     kit prop; a stop sign moves from its node on the road to the right-hand
//     curb of the approach it controls, beside the painted stop bar;
//   - rule rows from the "furniture" lists of tools/config/street-detail-zones.json
//     fill what OSM leaves out (lamps along curbs, signal poles at signalized
//     crossings, the controller cabinet, street-name signs at junctions, the
//     other approaches of an all-way stop, a stop sign for traffic turning into
//     a drive, lights around a parking lot). Every rule says it is production
//     inference and names its dated photo evidence.
// Only pilot zones get props; other rows stay data until the rollout.
//
// Plan geometry here is east/north (the ground generator's frame); rows use
// world x, z with z = -north. A prop's front is its local -Z (the lamp arm, the
// signal mast arm, a sign's face); yaw turns it toward the given direction.

import { projectLonLat } from "./coordinates.mjs";
import { pointInMultiPolygon } from "./osm-geometry.mjs";
import { compareSourceKeys, invariant, roundCoordinate } from "./world-contract.mjs";

// Kit props built by game/scripts/world/street_furniture_kit.gd, with the row
// kind each one stands for.
export const STREET_FURNITURE_PROPS = Object.freeze({
  adirondack_chair: "chair",
  bench_park: "bench",
  bench_wedge: "bench",
  bike_rack: "bicycle_parking",
  bus_stop_sign: "bus_stop",
  hydrant: "fire_hydrant",
  lamp_cobra: "street_lamp",
  lamp_lot: "street_lamp",
  lamp_plaza: "street_lamp",
  map_board: "information_board",
  name_sign: "street_sign",
  signal_cabinet: "street_cabinet",
  signal_mast: "traffic_signals",
  stop_sign: "stop_sign",
  waste_basket: "waste_basket",
});
// Plan sizes {x_m, z_m} (along the prop's local X and Z) of the kit props that
// are longer than their kind's radius covers; set pieces carry them as their
// footprint for the shared mask.
export const STREET_FURNITURE_FOOTPRINTS = Object.freeze({
  adirondack_chair: Object.freeze({ x_m: 0.8, z_m: 0.92 }),
  bench_park: Object.freeze({ x_m: 1.9, z_m: 0.66 }),
  bench_wedge: Object.freeze({ x_m: 4.1, z_m: 0.6 }),
  bike_rack: Object.freeze({ x_m: 0.8, z_m: 0.12 }),
  map_board: Object.freeze({ x_m: 1.34, z_m: 0.2 }),
  waste_basket: Object.freeze({ x_m: 0.6, z_m: 0.6 }),
});
export const STREET_FURNITURE_PATTERNS = Object.freeze(["kerb", "signalized_crossings", "near_signals", "junctions", "all_way_stops", "drive_entries", "lot_edge"]);
// Default props for OSM rows in pilot zones; kinds without one stay unbuilt.
const OSM_PROPS = Object.freeze({
  bench: () => ({ prop: "bench_park", params: {} }),
  bicycle_parking: () => ({ prop: "bike_rack", params: {} }),
  bus_stop: (tags) => (tags.shelter === "yes" ? null : { prop: "bus_stop_sign", params: {} }),
  fire_hydrant: () => ({ prop: "hydrant", params: {} }),
  stop_sign: (tags) => ({ prop: "stop_sign", params: { all_way: tags.stop === "all" } }),
  street_lamp: () => ({ prop: "lamp_cobra", params: {} }),
  waste_basket: (tags) => ({ prop: "waste_basket", params: { style: tags.material === "wood" ? "timber" : "steel" } }),
});
const STOP_SIGN = Object.freeze({ setback_m: 0.55, upstream_m: Array.from({ length: 20 }, (_, index) => roundCoordinate(0.6 * (index + 1))) });
// Site margins (m) beyond an item's footprint: from the carriageway edge, and
// from a curb ramp (its flares and landing). Footprint radii are at least each
// prop's collision extent, so two items keep at least the stock player's width
// (capsule radius 0.35 m) between their collision surfaces: no pinch the player
// cannot pass.
const KERB_CLEAR_M = 0.3;
const RAMP_CLEAR_M = 0.9;
const PLAYER_WIDTH_M = 0.7;
// At a junction, the angle between two neighbouring arms above which the corner
// is the straight side of a T rather than a street corner (about 170 degrees).
const STRAIGHT_CORNER_RAD = 2.97;
// Ground probed around a cabinet candidate (m): a 5 x 5 grid this far apart.
const CABINET_SITE_STEP_M = 1.0;
// Street-name abbreviations used on the blades (the last word only).
const NAME_SUFFIXES = Object.freeze({ Avenue: "Av", Boulevard: "Blvd", Court: "Ct", Drive: "Dr", Lane: "Ln", Place: "Pl", Road: "Rd", Street: "St" });
const SAFE_ID = /^[a-z0-9_]+$/u;
const RULE_FIELDS = Object.freeze({
  kerb: ["source_keys", "sides", "spacing_m", "phase_m", "setback_m", "slide_m"],
  signalized_crossings: ["setback_m", "beyond_m"],
  near_signals: ["back_m", "along_m"],
  junctions: ["setback_m"],
  all_way_stops: ["clear_m"],
  drive_entries: ["clear_m"],
  lot_edge: ["source_keys", "spacing_m", "phase_m", "setback_m", "slide_m"],
});
const COMMON_FIELDS = Object.freeze(["basis", "evidence", "id", "kind", "params", "pattern", "prop", "rule"]);

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

const sub = (a, b) => [a[0] - b[0], a[1] - b[1]];
const add = (a, b) => [a[0] + b[0], a[1] + b[1]];
const scale = (a, s) => [a[0] * s, a[1] * s];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1];
const length = (a) => Math.hypot(a[0], a[1]);
const unit = (a) => {
  const l = length(a);
  invariant(l > 1e-9, "Street furniture direction has no length");
  return [a[0] / l, a[1] / l];
};
const leftOf = (d) => [-d[1], d[0]];

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

// World xz <-> east/north.
const toWorld = (en) => [en[0], -en[1]];
const toEastNorth = (xz) => [xz[0], -xz[1]];

// Yaw that turns the local -Z front toward the east/north direction d: about +Y,
// local -Z goes to world (-sin yaw, -cos yaw), which is east/north (-sin yaw, cos yaw).
function yawToward(d) {
  return roundCoordinate(Math.atan2(-d[0], d[1]));
}

// Yaw that turns the local +X axis along the east/north direction d.
function yawAlong(d) {
  return yawToward(leftOf(d));
}

function relativeYaw(yaw, base) {
  const delta = yaw - base;
  return roundCoordinate(Math.atan2(Math.sin(delta), Math.cos(delta)));
}

export function abbreviateStreetName(name) {
  const words = String(name).trim().split(/\s+/u);
  if (words.length > 1 && NAME_SUFFIXES[words.at(-1)]) words[words.length - 1] = NAME_SUFFIXES[words.at(-1)];
  return words.join(" ");
}

export function validateFurnitureRules(zone, kinds) {
  if (zone.furniture == null) return;
  invariant(Array.isArray(zone.furniture), `Street detail zone ${zone.id} furniture must be a list`);
  const ids = new Set();
  for (const rule of zone.furniture) {
    const label = `Street detail zone ${zone.id} furniture rule ${rule?.id}`;
    invariant(typeof rule?.id === "string" && SAFE_ID.test(rule.id) && !ids.has(rule.id), `${label} needs a unique lower_snake id`);
    ids.add(rule.id);
    invariant(STREET_FURNITURE_PATTERNS.includes(rule.pattern), `${label} pattern must be one of ${STREET_FURNITURE_PATTERNS.join(", ")}`);
    const allowed = [...COMMON_FIELDS, ...RULE_FIELDS[rule.pattern]].sort();
    const present = Object.keys(rule).sort();
    invariant(present.every((key) => allowed.includes(key)), `${label} has fields outside ${allowed.join(", ")}`);
    invariant(RULE_FIELDS[rule.pattern].every((key) => key in rule), `${label} needs ${RULE_FIELDS[rule.pattern].join(", ")}`);
    invariant(STREET_FURNITURE_PROPS[rule.prop] === rule.kind && kinds[rule.kind]?.layer === "furniture", `${label}: prop ${rule.prop} does not build kind ${rule.kind} in the furniture layer`);
    invariant(rule.basis === "production_inference", `${label}: rule-based furniture is production_inference`);
    for (const field of ["rule", "evidence"]) invariant(typeof rule[field] === "string" && rule[field].trim() !== "", `${label} needs ${field}`);
    invariant(rule.params != null && typeof rule.params === "object" && !Array.isArray(rule.params), `${label} params must be an object`);
    for (const field of ["spacing_m", "setback_m", "beyond_m", "back_m"]) {
      if (field in rule) invariant(isFiniteNumber(rule[field]) && rule[field] > 0, `${label} ${field} must be positive`);
    }
    for (const field of ["phase_m", "slide_m", "along_m", "clear_m"]) {
      if (field in rule) invariant(isFiniteNumber(rule[field]) && rule[field] >= 0, `${label} ${field} must be non-negative`);
    }
    if ("source_keys" in rule) invariant(Array.isArray(rule.source_keys) && rule.source_keys.length > 0 && rule.source_keys.every((key) => /^w\d+$/u.test(key)), `${label} needs OSM way source_keys`);
    if ("sides" in rule) invariant(Array.isArray(rule.sides) && rule.sides.length > 0 && rule.sides.every((side) => ["left", "right"].includes(side)), `${label} sides are left and/or right`);
  }
}

// Resolves furniture for the pilot zones. Mutates the OSM rows it gives props
// (and moves stop signs); returns the new rule rows and an audit.
export function placeStreetFurniture({
  kinds,
  rows,
  occupied,
  zoneShapes,
  site,
  rawOsm,
  hardViolation,
  hardShapes,
  buildings,
  exclusions,
  onLand,
  grounded,
  surfaceAt,
}) {
  const pilotShapes = zoneShapes.filter(({ zone }) => zone.pilot);
  const inPilot = (xz) => pilotShapes.some(({ contains }) => contains(xz));
  const audit = { osm_props: 0, osm_unbuilt: [], stops_moved: 0, rules: {}, rejected_by_reason: {} };
  const count = (table, key) => {
    table[key] = (table[key] ?? 0) + 1;
  };

  // The furniture site check: gameplay mask, walls, kerb and ramps, other items.
  // options.raised: must stand on the raised street ground; options.ignore: ids
  // whose footprints do not count (the row being moved).
  const reject = (kindName, xz, options = {}) => {
    const radius = kinds[kindName].footprint_radius_m;
    if (!onLand(xz, exclusions.land_edge_buffer_m + radius)) return "land_edge";
    const hard = hardViolation(hardShapes, [xz], radius);
    if (hard) return hard.reason;
    const building = buildings.nearest(xz, exclusions.wall_buffer_m + radius);
    if (building.distance < exclusions.wall_buffer_m + radius) return building.distance === 0 ? "inside_building" : "wall_buffer";
    const en = toEastNorth(xz);
    if (site.carriagewayDistance(en) < KERB_CLEAR_M + radius) return "carriageway";
    if (site.rampDistance(en) < RAMP_CLEAR_M + radius) return "curb_ramp";
    if (options.raised && !site.raised(en)) return "off_sidewalk";
    for (const item of occupied) {
      if (options.ignore?.has(item.id)) continue;
      // A line item (a fence run) counts by its segments, not only its vertices.
      const distance = item.points.length > 1 ? closestOnPolyline(item.points, xz).distance : Math.hypot(item.points[0][0] - xz[0], item.points[0][1] - xz[1]);
      if (distance < item.radius_m + radius + PLAYER_WIDTH_M) return "overlap";
    }
    return null;
  };
  const occupy = (id, kindName, xz) => occupied.push({ id, points: [xz], radius_m: kinds[kindName].footprint_radius_m });
  const surfaceRow = (xz) => {
    const { y, support } = grounded(xz);
    return {
      position_m: [xz[0], y, xz[1]],
      terrain_support: { object_key: support.object_key, triangle_index: support.triangle_index, elevation_m: support.elevation_m },
      surface: surfaceAt(xz),
    };
  };
  const round2 = (en) => [roundCoordinate(en[0]), roundCoordinate(en[1])];

  // --- OSM rows: props, and stop signs moved to their curbs.
  const stopBar = new Map(site.stop_bars.map((bar) => [bar.node_key, bar]));
  const kerbLines = site.kerb_roads;
  const nodePoint = (ref) => {
    const node = rawOsm.nodes.get(ref);
    invariant(node, `Street furniture needs OSM node n${ref}, which the raw extract lacks`);
    return projectLonLat(node.coordinate);
  };
  // Nodes where two kerbed roads meet.
  const meetings = new Map();
  const wayRefs = (road) => {
    const way = rawOsm.ways.get(road.source_key.slice(1));
    invariant(way, `Street furniture needs OSM way ${road.source_key}, which the raw extract lacks`);
    return new Set(way.node_refs);
  };
  for (const road of kerbLines) {
    for (const ref of wayRefs(road)) meetings.set(ref, [...(meetings.get(ref) ?? []), road]);
  }
  const junctionPoints = [...meetings.entries()].filter(([, roads]) => roads.length > 1)
    .map(([ref]) => ({ ref, point: nodePoint(ref) }));
  // Stop signs placed so far, by approach: the junction, the road and the direction of travel.
  const stopSigns = [];
  const coveredBy = (junction, roadKey, travel) => stopSigns.find((sign) => sign.road_key === roadKey && dot(sign.travel, travel) > 0.7 &&
    sign.junction === junction);
  // The nearest junction on a road ahead of a point, within 30 m.
  const junctionAhead = (road, point, travel) => {
    let best = null;
    for (const junction of junctionPoints) {
      if (closestOnPolyline(road.line, junction.point).distance > 0.5 || dot(sub(junction.point, point), travel) < -1) continue;
      const distance = length(sub(junction.point, point));
      if (distance <= 30 && (!best || distance < best.distance)) best = { ...junction, distance };
    }
    return best;
  };
  // How far from a junction a sign on one of its arms must stand: past the
  // crossing street's curb and upstream of any crosswalk across the arm.
  const armClearance = (center, road, outward, crossKerb, clear) => {
    let distance = crossKerb + clear;
    for (const walk of site.crosswalks) {
      const along = dot(sub(walk.center, center), outward);
      if (along <= 0 || along > 25 || closestOnPolyline(road.line, walk.center).distance > 2) continue;
      distance = Math.max(distance, along + site.walk_width_m / 2 + clear);
    }
    return distance;
  };
  // The first clear spot on the right-hand curb of traffic moving along travel,
  // stepping from base upstream (step -1) or downstream (step 1).
  const stopPosition = (id, base, travel, reach, step = -1) => {
    const right = [travel[1], -travel[0]];
    for (const distance of STOP_SIGN.upstream_m) {
      const xz = toWorld(add(add(base, scale(right, reach + STOP_SIGN.setback_m)), scale(travel, step * distance)));
      const problem = reject("stop_sign", xz, { ignore: new Set([id]) });
      if (!problem) return round2(xz);
      count(audit.rejected_by_reason, `stop_sign:${problem}`);
    }
    return null;
  };
  const candidates = rows.filter((row) => row.source === "osm" && row.geometry === "point" && row.status === "placed" &&
    kinds[row.kind].layer === "furniture" && inPilot([row.position_m[0], row.position_m[2]]));
  // Stops with a painted bar first: a stop node beside the road then joins the
  // sign already on its approach rather than doubling it.
  candidates.sort((left, right) => (left.kind === "stop_sign" && !stopBar.has(left.source_id)) - (right.kind === "stop_sign" && !stopBar.has(right.source_id)));
  for (const row of candidates) {
    const at = [row.position_m[0], row.position_m[2]];
    const choice = OSM_PROPS[row.kind]?.(row.tags ?? {});
    if (!choice) {
      audit.osm_unbuilt.push({ id: row.id, kind: row.kind });
      continue;
    }
    if (row.kind === "stop_sign") {
      // A painted bar gives the approach; a stop node beside the road marks the
      // approach of the nearest kerbed road toward its nearest junction.
      const bar = stopBar.get(row.source_id);
      let road;
      let base;
      let travel;
      if (bar) {
        road = kerbLines.find((candidate) => candidate.source_key === bar.host_key);
        ({ travel } = bar);
        base = bar.bar_center;
      } else {
        const en = toEastNorth(at);
        let best = null;
        for (const candidate of kerbLines) {
          const near = closestOnPolyline(candidate.line, en);
          if (!best || near.distance - candidate.kerb_offset_m < best.gap) best = { road: candidate, near, gap: near.distance - candidate.kerb_offset_m };
        }
        invariant(best, `${row.id}: no kerbed road for a stop sign`);
        road = best.road;
        base = best.near.point;
        const ahead = [1, -1].map((sign) => junctionAhead(road, base, scale(best.near.tangent, sign))).filter(Boolean)
          .sort((left, right) => left.distance - right.distance)[0];
        if (!ahead) {
          audit.osm_unbuilt.push({ id: row.id, kind: row.kind, reason: "no junction within 30 m along its road" });
          continue;
        }
        travel = scale(best.near.tangent, dot(sub(ahead.point, base), best.near.tangent) >= 0 ? 1 : -1);
        // At least as far out as a crosswalk across this arm of the junction.
        const outward = scale(travel, -1);
        const others = (meetings.get(ahead.ref) ?? []).filter((other) => other !== road);
        const needed = armClearance(ahead.point, road, outward, Math.max(0, ...others.map((other) => other.kerb_offset_m)), 1.0);
        const out = dot(sub(base, ahead.point), outward);
        if (out < needed) base = add(base, scale(outward, needed - out));
      }
      invariant(road, `${row.id}: stop bar road is not kerbed`);
      const junction = meetings.get(row.source_id.slice(1))?.length > 1 ? row.source_id.slice(1) : junctionAhead(road, base, travel)?.ref ?? null;
      const covering = coveredBy(junction, road.source_key, travel);
      if (covering) {
        audit.osm_unbuilt.push({ id: row.id, kind: row.kind, reason: `same approach as ${covering.id}` });
        continue;
      }
      const xz = stopPosition(row.id, base, travel, road.kerb_offset_m);
      if (!xz) {
        audit.osm_unbuilt.push({ id: row.id, kind: row.kind, reason: "no clear curb position" });
        continue;
      }
      row.source_position_m = [...row.position_m];
      Object.assign(row, surfaceRow(xz));
      row.yaw_radians = yawToward(scale(travel, -1));
      row.yaw_source = bar ? `stop_bar:${bar.host_key}` : `approach:${road.source_key}`;
      row.placement = bar
        ? "right-hand curb of the approach beside its painted stop bar (production_inference)"
        : "right-hand curb of the nearest kerbed road's approach to its nearest junction (production_inference)";
      const index = occupied.findIndex((item) => item.id === row.id);
      if (index >= 0) occupied.splice(index, 1);
      occupy(row.id, row.kind, xz);
      stopSigns.push({ id: row.id, junction, road_key: road.source_key, travel });
      audit.stops_moved += 1;
    }
    row.prop = choice.prop;
    row.prop_params = choice.params;
    audit.osm_props += 1;
  }

  // --- Rule rows.
  const ruleRows = [];
  const kerbByKey = new Map(kerbLines.map((road) => [road.source_key, road]));
  const addRow = (zone, rule, cell, en, front, params = {}, yawSource = `rule:${zone.id}/${rule.id}`) => {
    const xz = round2(toWorld(en));
    const row = {
      id: `scatter:${zone.id}:${rule.id}:${cell}`,
      source: "scatter",
      source_id: `zone:${zone.id}/${rule.id}`,
      kind: rule.kind,
      layer: kinds[rule.kind].layer,
      geometry: "point",
      ...surfaceRow(xz),
      yaw_radians: yawToward(front),
      yaw_source: yawSource,
      status: "placed",
      exclusion: null,
      prop: rule.prop,
      prop_params: { ...rule.params, ...params },
      basis: rule.basis,
    };
    ruleRows.push(row);
    occupy(row.id, rule.kind, xz);
    count(audit.rules, `${zone.id}/${rule.id}`);
    return row;
  };
  // Tries the candidates in order; returns the first clear east/north point, or
  // null. With options.spacing_m, a row with the same prop from another source
  // (an OSM lamp, say) within half of it takes the station, which is skipped.
  const sameKindNear = (rule, xz, distance) => [...rows, ...ruleRows].some((row) => row.prop === rule.prop && row.source_id !== rule.source_id &&
    row.status === "placed" && row.geometry === "point" && Math.hypot(row.position_m[0] - xz[0], row.position_m[2] - xz[1]) < distance);
  const firstClear = (rule, contains, candidates, options) => {
    for (const en of candidates) {
      const xz = toWorld(en);
      if (!contains(xz)) {
        count(audit.rejected_by_reason, `${rule.id}:outside_zone`);
        continue;
      }
      if (options.spacing_m && sameKindNear(rule, xz, options.spacing_m / 2)) {
        count(audit.rejected_by_reason, `${rule.id}:same_kind_near`);
        return null;
      }
      const problem = reject(rule.kind, xz, options);
      if (!problem) return en;
      count(audit.rejected_by_reason, `${rule.id}:${problem}`);
    }
    return null;
  };
  // A crossing or junction shared by two zones is furnished once.
  const done = new Set();
  const once = (key) => {
    if (done.has(key)) return false;
    done.add(key);
    return true;
  };
  const slides = (slide) => {
    const values = [0];
    for (let step = 0.5; step <= slide + 1e-9; step += 0.5) values.push(step, -step);
    return values;
  };
  const chains = (keys) => {
    // Consecutive listed ways that share an end node walk as one curb line.
    const result = [];
    for (const key of keys) {
      const road = kerbByKey.get(key);
      invariant(road, `Street furniture kerb rule names ${key}, which is not a kerbed road`);
      const line = road.line.map((point) => [...point]);
      const last = result.at(-1);
      if (last) {
        const end = last.line.at(-1);
        if (length(sub(end, line[0])) < 0.01) {
          last.line.push(...line.slice(1));
          last.offsets.push(...line.slice(1).map(() => road.kerb_offset_m));
          continue;
        }
        if (length(sub(end, line.at(-1))) < 0.01) {
          const reversed = line.reverse();
          last.line.push(...reversed.slice(1));
          last.offsets.push(...reversed.slice(1).map(() => road.kerb_offset_m));
          continue;
        }
      }
      result.push({ key, line, offsets: line.map(() => road.kerb_offset_m) });
    }
    return result;
  };
  const offsetAt = (chain, s) => {
    // The curb offset of the segment that holds distance s.
    let walked = 0;
    for (let index = 1; index < chain.line.length; index += 1) {
      walked += length(sub(chain.line[index], chain.line[index - 1]));
      if (walked >= s) return chain.offsets[index];
    }
    return chain.offsets.at(-1);
  };

  // Junctions of differently named kerbed roads, from the raw topology.
  const junctions = () => {
    const use = new Map();
    for (const road of kerbLines) {
      if (road.name == null) continue;
      for (const ref of wayRefs(road)) {
        const list = use.get(ref) ?? [];
        list.push({ road });
        use.set(ref, list);
      }
    }
    const found = [];
    for (const [ref, list] of [...use.entries()].sort(([left], [right]) => compareSourceKeys(`n${left}`, `n${right}`))) {
      if (new Set(list.map((entry) => entry.road.name)).size < 2) continue;
      const center = nodePoint(ref);
      // One arm per direction a road leaves the junction, 8 m out along it.
      const arms = [];
      for (const { road } of list) {
        const total = polylineLength(road.line);
        const at = closestOnPolyline(road.line, center).along;
        for (const sign of [-1, 1]) {
          const target = at + sign * Math.min(8, sign > 0 ? total - at : at);
          if (Math.abs(target - at) < 1) continue;
          arms.push({ road, direction: unit(sub(pointAlong(road.line, target).point, center)) });
        }
      }
      found.push({ ref, center, arms });
    }
    return found;
  };

  // Stop signs on the arms of `road` at junction `ref`, on the right-hand curb,
  // past the crossing roads' curbs and any crosswalk across the arm. They face
  // traffic approaching the junction, or with inbound traffic leaving it into
  // the arm (and stand downstream of that crosswalk).
  const signArms = (zone, rule, ref, center, road, crossing, inbound = false) => {
    const total = polylineLength(road.line);
    const at = closestOnPolyline(road.line, center).along;
    for (const sign of [-1, 1]) {
      const room = sign > 0 ? total - at : at;
      if (room < 6) continue;
      const outward = unit(sub(pointAlong(road.line, at + sign * Math.min(8, room)).point, center));
      const travel = inbound ? outward : scale(outward, -1);
      if (!inbound && coveredBy(ref, road.source_key, travel)) continue;
      const cross = Math.max(0, ...crossing.map((other) => other.kerb_offset_m));
      const cell = `n${ref}_${road.source_key}_${sign > 0 ? "b" : "a"}`;
      const base = add(center, scale(outward, armClearance(center, road, outward, cross, rule.clear_m)));
      const xz = stopPosition(`scatter:${zone.id}:${rule.id}:${cell}`, base, travel, road.kerb_offset_m, inbound ? 1 : -1);
      if (!xz) {
        count(audit.rejected_by_reason, `${rule.id}:no_clear_curb`);
        continue;
      }
      const row = addRow(zone, rule, cell, toEastNorth(xz), scale(travel, -1), {}, `${inbound ? "inbound" : "approach"}:${road.source_key}`);
      if (!inbound) stopSigns.push({ id: row.id, junction: ref, road_key: road.source_key, travel });
    }
  };

  for (const { zone, contains } of pilotShapes) {
    for (const zoneRule of zone.furniture ?? []) {
      const rule = { ...zoneRule, source_id: `zone:${zone.id}/${zoneRule.id}` };
      if (rule.pattern === "kerb") {
        for (const chain of chains(rule.source_keys)) {
          const total = polylineLength(chain.line);
          for (const sideName of rule.sides) {
            const side = sideName === "left" ? 1 : -1;
            for (let station = 0, s = rule.phase_m; s <= total; station += 1, s += rule.spacing_m) {
              const candidates = slides(rule.slide_m).filter((delta) => s + delta >= 0 && s + delta <= total).map((delta) => {
                const along = pointAlong(chain.line, s + delta);
                return add(along.point, scale(leftOf(along.tangent), side * (offsetAt(chain, s + delta) + rule.setback_m)));
              });
              const en = firstClear(rule, contains, candidates, { raised: true, spacing_m: rule.spacing_m });
              if (!en) continue;
              const near = closestOnPolyline(chain.line, en);
              addRow(zone, rule, `${chain.key}_${sideName}_${String(station).padStart(3, "0")}`, en, unit(sub(near.point, en)));
            }
          }
        }
      } else if (rule.pattern === "signalized_crossings" || rule.pattern === "near_signals") {
        for (const walk of site.crosswalks.filter((candidate) => candidate.signals && contains(toWorld(candidate.center)))) {
          if (!once(`${rule.pattern}:${walk.source_key}`)) continue;
          // Each landing gets the far-side pole of the traffic that keeps that curb on its right.
          const landings = [[-1, walk.span[0]], [1, walk.span[1]]].map(([sign, s]) => {
            const outward = scale(walk.direction, sign);
            return { sign, s, outward, travel: leftOf(outward), landing: add(walk.center, scale(walk.direction, s)) };
          });
          if (rule.pattern === "signalized_crossings") {
            for (const landing of landings) {
              const candidates = [0, 0.5, 1, 1.5, 2, 3, 4].map((extra) => add(add(landing.landing, scale(landing.outward, rule.setback_m)),
                scale(landing.travel, site.walk_width_m / 2 + rule.beyond_m + extra)));
              const en = firstClear(rule, contains, candidates, { raised: true });
              if (!en) continue;
              // The mast arm reaches over the lanes of its own direction, toward
              // the centre line of the road the crosswalk crosses.
              const reach = Math.min(...kerbLines.map((road) => closestOnPolyline(road.line, en).distance));
              const arm = Math.round(Math.max(3, Math.min(7, 0.85 * reach)) * 2) / 2;
              addRow(zone, rule, `${walk.source_key}_${landing.sign > 0 ? "b" : "a"}`, en, scale(landing.outward, -1), { arm_m: arm, head_m: roundCoordinate(Math.min(arm - 0.4, 0.7 * reach)) });
            }
          } else {
            // One cabinet per crossing, behind the far-side pole of the landing with
            // the most paved street ground around it (a plaza or a wide sidewalk).
            let best = null;
            for (const landing of landings) {
              const pole = add(add(landing.landing, scale(landing.outward, 0.6)), scale(landing.travel, site.walk_width_m / 2 + 1));
              const candidates = [0, 0.5, 1, 1.5].map((extra) => add(add(pole, scale(landing.outward, rule.back_m + extra)), scale(landing.travel, rule.along_m)));
              const en = firstClear(rule, contains, candidates, {});
              if (!en) continue;
              let paved = 0;
              for (let i = -2; i <= 2; i += 1) {
                for (let j = -2; j <= 2; j += 1) {
                  if (site.raised(add(en, [i * CABINET_SITE_STEP_M, j * CABINET_SITE_STEP_M]))) paved += 1;
                }
              }
              if (!best || paved > best.paved) best = { landing, en, paved };
            }
            if (best) addRow(zone, rule, `${walk.source_key}_${best.landing.sign > 0 ? "b" : "a"}`, best.en, scale(best.landing.outward, -1));
          }
        }
      } else if (rule.pattern === "junctions") {
        for (const junction of junctions()) {
          if (!contains(toWorld(junction.center)) || !once(`junction:${junction.ref}`)) continue;
          const arms = junction.arms.map((arm) => ({ ...arm, angle: Math.atan2(arm.direction[1], arm.direction[0]) })).sort((left, right) => left.angle - right.angle);
          // Corners between two streets first (widest first), the straight side of a T last.
          const corners = arms.map((arm, index) => {
            const next = arms[(index + 1) % arms.length];
            let gap = next.angle - arm.angle;
            if (gap <= 0) gap += Math.PI * 2;
            const bisector = unit([Math.cos(arm.angle + gap / 2), Math.sin(arm.angle + gap / 2)]);
            const offset = Math.max(arm.road.kerb_offset_m, next.road.kerb_offset_m) + rule.setback_m;
            const radius = Math.min(14, offset / Math.max(0.2, Math.sin(Math.min(gap, Math.PI) / 2)));
            return { gap, bisector, point: add(junction.center, scale(bisector, radius)) };
          }).sort((left, right) => (left.gap >= STRAIGHT_CORNER_RAD) - (right.gap >= STRAIGHT_CORNER_RAD) || right.gap - left.gap);
          const en = firstClear(rule, contains, corners.map((corner) => corner.point), { raised: true });
          if (!en) continue;
          const front = unit(sub(junction.center, en));
          const yaw = yawToward(front);
          const names = [];
          for (const arm of arms) if (!names.some((entry) => entry.name === arm.road.name)) names.push({ name: arm.road.name, direction: arm.direction });
          const blades = names.slice(0, 2).map((entry) => ({ text: abbreviateStreetName(entry.name), yaw: relativeYaw(yawAlong(entry.direction), yaw) }));
          addRow(zone, rule, `n${junction.ref}`, en, front, { blades });
        }
      } else if (rule.pattern === "all_way_stops") {
        // An OSM stop=all junction stops every approach: a sign on the right-hand
        // curb of each arm not already signed, clear of the crossing street.
        for (const stop of rows.filter((row) => row.source === "osm" && row.kind === "stop_sign" && row.tags?.stop === "all")) {
          const ref = stop.source_id.slice(1);
          const roads = meetings.get(ref) ?? [];
          if (roads.length < 2) continue;
          const center = nodePoint(ref);
          if (!contains(toWorld(center)) || !once(`all_way:${ref}`)) continue;
          for (const road of roads) signArms(zone, rule, ref, center, road, roads.filter((other) => other !== road));
        }
      } else if (rule.pattern === "drive_entries") {
        // Traffic turning off a named road into a kerbed service drive stops: a
        // sign on its right-hand curb, just past any crosswalk across the drive.
        for (const [ref, roads] of [...meetings.entries()].sort(([left], [right]) => compareSourceKeys(`n${left}`, `n${right}`))) {
          const named = roads.filter((road) => road.name != null);
          const drives = roads.filter((road) => road.name == null && road.highway === "service");
          if (named.length === 0 || drives.length === 0) continue;
          const center = nodePoint(ref);
          if (!contains(toWorld(center)) || !once(`drive_entry:${ref}`)) continue;
          for (const road of drives) signArms(zone, rule, ref, center, road, named, true);
        }
      } else if (rule.pattern === "lot_edge") {
        // Lights around a parking lot: just outside its outer edge, facing in.
        for (const key of rule.source_keys) {
          const lot = site.lots.find((candidate) => candidate.source_key === key);
          invariant(lot, `Street furniture lot rule names ${key}, which is not a parking lot near the pilot`);
          lot.geometry.forEach((polygon, polygonIndex) => {
            const ring = polygon[0];
            const line = length(sub(ring[0], ring.at(-1))) < 1e-9 ? ring : [...ring, ring[0]];
            const total = polylineLength(line);
            const inside = (point) => pointInMultiPolygon(point, lot.geometry, false);
            for (let station = 0, s = rule.phase_m; s < total; station += 1, s += rule.spacing_m) {
              const candidates = slides(rule.slide_m).map((delta) => {
                const along = pointAlong(line, ((s + delta) % total + total) % total);
                const left = leftOf(along.tangent);
                const outward = inside(add(along.point, scale(left, 0.5))) ? scale(left, -1) : left;
                return add(along.point, scale(outward, rule.setback_m));
              });
              // A lot can reach past its own zone; its lights follow it anywhere in the pilot.
              const en = firstClear(rule, inPilot, candidates, { spacing_m: rule.spacing_m });
              if (!en) continue;
              const near = closestOnPolyline(line, en);
              addRow(zone, rule, `${key}_p${polygonIndex}_s${String(station).padStart(3, "0")}`, en, unit(sub(near.point, en)));
            }
          });
        }
      }
    }
  }
  audit.osm_unbuilt.sort((left, right) => (left.id < right.id ? -1 : left.id > right.id ? 1 : 0));
  return { rows: ruleRows, audit };
}
