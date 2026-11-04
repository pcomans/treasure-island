// Street fences: the fence lines of PlayableWorld/StreetDetail/Fences.
//
// Two sources, both resolved to fence rows of generated/world/street_detail.json:
//   - OSM barrier=fence ways (rows made by street-detail-generation.mjs); their
//     fence type comes from fence_type, else from the way's other tags;
//   - rule rows from the "fences" lists of tools/config/street-detail-zones.json,
//     where dated photos show fencing OSM lacks (pattern legs), or a different
//     fence along a stretch of an OSM fence way (pattern osm_way: that stretch is
//     cut out of the OSM row and built as the rule's own row of the photographed
//     type, or left open with fence_type none where something else, such as a
//     container wall, stands on the line). Every rule is production inference and
//     names its dated photo evidence.
// A fence stays solid except where it opens: where a road or path crosses it, at
// an OSM gate on it, where it would enter a gameplay clearance of the shared mask
// (spawn, QA corridors, stairs, doors, approaches) or a building, or off the land.
// Those stretches are cut out (fence.openings) rather than the whole fence dropped;
// what is left is fence.runs, each a grounded polyline: the posts of a built row,
// the line's own vertices and cut ends otherwise.
// Only rows in pilot zones get a kit prop (the fence type) and are built; the rest
// stay data until the rollout.
//
// Geometry here is in world x, z (+X east, +Z south), like the rows.

import { pointInMultiPolygon } from "./osm-geometry.mjs";
import { compareSourceKeys, invariant, roundCoordinate } from "./world-contract.mjs";

// The fence kit types game/scripts/world/street_fence_kit.gd builds. post_spacing_m
// is the longest bay (a panel for construction panels); half_thickness_m the
// collision and clearance half width (construction panels stand on wide feet).
// Dimensions are US fence-trade sizes (6 ft fabric, 10 ft line-post spacing,
// 6 x 12 ft temporary panels, 8 ft wood bays), production inference, not survey.
export const STREET_FENCE_TYPES = Object.freeze({
  // Chain-link with privacy slats woven through it (storage yards: green on 9th
  // St, Sep 2025, and Avenue M, Mar 2025; brown on 12th St, Jul 2023), 6 or 8 ft.
  chain_link_slatted: Object.freeze({ height_m: 1.83, post_spacing_m: 3.05, half_thickness_m: 0.06, heights_m: Object.freeze([1.83, 2.44]) }),
  chain_link: Object.freeze({ height_m: 1.83, post_spacing_m: 3.05, half_thickness_m: 0.06 }),
  chain_link_barbed: Object.freeze({ height_m: 2.13, post_spacing_m: 3.05, half_thickness_m: 0.25 }),
  chain_link_screened: Object.freeze({ height_m: 1.83, post_spacing_m: 3.05, half_thickness_m: 0.06 }),
  construction_panel: Object.freeze({ height_m: 1.83, post_spacing_m: 3.66, half_thickness_m: 0.3 }),
  wood_privacy: Object.freeze({ height_m: 1.83, post_spacing_m: 2.44, half_thickness_m: 0.08 }),
});
// Windscreen colours; orange is the open safety mesh of construction sites
// (9th St, Sep 2025: about 1.2 m high behind construction panels).
export const STREET_FENCE_SCREENS = Object.freeze(["black", "green", "orange"]);
// A screen may stop below the fence top (screen_height_m), the wire bare above it.
export const STREET_FENCE_SCREEN_MIN_M = 0.6;
export const STREET_FENCE_SLATS = Object.freeze(["green", "brown", "black"]);
// Gates stand open (the owner's fence rule): their leaves are drawn swung or
// slid back on the inside of the fence. A slatted fence draws the leaves of
// every gate opening; plain and screened chain-link those of its rule gates
// (Seven Seas Ave Gate 5, Nov 2025: one leaf swung in from its post). A
// single leaf hangs on the gate's start post (first along the line) unless
// the rule hinges it at the end.
export const STREET_FENCE_GATE_STYLES = Object.freeze(["swing_single", "swing_double", "sliding"]);
export const STREET_FENCE_GATED_TYPES = Object.freeze(["chain_link_slatted", "chain_link", "chain_link_screened"]);
export const STREET_FENCE_GATE_HINGES = Object.freeze(["start", "end"]);
// A banner tied to a chain-link fence: a plain white sheet, no text, centred
// on the fence's height (Gate 5, Nov 2025: a contractor's banner on the green
// screen).
export const STREET_FENCE_BANNER_TYPES = Object.freeze(["chain_link_slatted", "chain_link", "chain_link_screened"]);
export const STREET_FENCE_INSIDE = Object.freeze(["left", "right", "center"]);
// Along-fence sampling step (m) for openings, and the clear margin (m) an opening
// keeps on both sides of a crossing road or path.
const SAMPLE_STEP_M = 0.1;
const CROSSING_MARGIN_M = 0.5;
// A solid stretch shorter than this between two openings, or at an end, is dropped.
const MINIMUM_RUN_M = 1.2;
// An OSM gate opens this much unless the node gives a width.
const GATE_WIDTH_M = 1.5;
// A gate wider than this is a vehicle gate, which a road crossing already opens.
const MAXIMUM_GATE_WIDTH_M = 8;
const SAFE_ID = /^[a-z0-9_]+$/u;
const RULE_FIELDS = Object.freeze(["basis", "evidence", "fence_type", "id", "kind", "legs", "params", "pattern", "rule"]);
// Optional rule fields along the rule's line: gates [{at_m, width_m, style,
// hinge?}] and banners [{at_m, width_m, height_m}]; and deck, the OSM way key
// of a boundary-attached context deck (a pier drawn as visual-only context
// beyond the playable boundary) the fence stands on instead of the land: its
// posts stand on the deck's triangles, it opens only where it leaves the deck,
// and it is drawn without collision, as the deck itself is.
const OPTIONAL_RULE_FIELDS = Object.freeze(["banners", "deck", "gates"]);
const OSM_WAY_RULE_FIELDS = Object.freeze(["basis", "evidence", "fence_type", "from_m", "id", "kind", "params", "pattern", "rule", "to_m", "way"]);
// An osm_way rule may also shift its row sideways off the OSM line (offset_m,
// + to the left of the way), where the line is mapped on a sidewalk's edge,
// and name gates along its stretch like a traced rule.
const OSM_WAY_RULE_OPTIONAL = Object.freeze(["gates", "offset_m"]);
// The fence_type of an osm_way rule that only cuts its stretch out of the OSM fence.
export const FENCE_TYPE_NONE = "none";
// An osm_way rule's along-distance may run this far past its way's end, which
// then means the end (along-distances are read off a map to the decimetre).
const OSM_WAY_END_SLACK_M = 1.0;
const OSM_FENCE_TYPES = Object.freeze({
  chain_link: "chain_link",
  metal: "chain_link",
  mesh: "chain_link",
  railing: "chain_link",
  bars: "chain_link",
  barbed_wire: "chain_link_barbed",
  wire: "chain_link_barbed",
  electric: "chain_link_barbed",
  wood: "wood_privacy",
  board: "wood_privacy",
  split_rail: "wood_privacy",
  hoarding: "construction_panel",
  panel: "construction_panel",
});
const GATE_VALUES = Object.freeze(["gate", "hampshire_gate", "kissing_gate", "lift_gate", "sliding_gate", "swing_gate", "wicket_gate"]);

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

const sub = (a, b) => [a[0] - b[0], a[1] - b[1]];
const add = (a, b) => [a[0] + b[0], a[1] + b[1]];
const scale = (a, s) => [a[0] * s, a[1] * s];
const length = (a) => Math.hypot(a[0], a[1]);
const unit = (a) => {
  const l = length(a);
  invariant(l > 1e-9, "Street fence direction has no length");
  return [a[0] / l, a[1] / l];
};
// Seen from above with north (-Z) up, the left of world direction (dx, dz) is (dz, -dx).
const leftOf = (d) => [d[1], -d[0]];

function cumulative(points) {
  const lengths = [0];
  for (let index = 1; index < points.length; index += 1) lengths.push(lengths[index - 1] + length(sub(points[index], points[index - 1])));
  return lengths;
}

// The point at along-distance s of a polyline with cumulative lengths.
function pointAt(points, lengths, s) {
  const target = Math.max(0, Math.min(lengths.at(-1), s));
  for (let index = 1; index < points.length; index += 1) {
    if (lengths[index] >= target || index === points.length - 1) {
      const span = lengths[index] - lengths[index - 1];
      const fraction = span > 1e-12 ? (target - lengths[index - 1]) / span : 0;
      return add(points[index - 1], scale(sub(points[index], points[index - 1]), fraction));
    }
  }
  return points.at(-1);
}

// The piece of a polyline between along-distances s0 < s1, with its inner vertices.
function slice(points, lengths, s0, s1) {
  const piece = [pointAt(points, lengths, s0)];
  for (let index = 1; index < points.length - 1; index += 1) {
    if (lengths[index] > s0 + 1e-6 && lengths[index] < s1 - 1e-6) piece.push(points[index]);
  }
  piece.push(pointAt(points, lengths, s1));
  return piece;
}

// A polyline offset sideways by d (left of travel when positive), with mitred joins.
function offsetLine(points, d) {
  const directions = [];
  for (let index = 1; index < points.length; index += 1) directions.push(unit(sub(points[index], points[index - 1])));
  return points.map((point, index) => {
    const before = directions[Math.max(0, index - 1)];
    const after = directions[Math.min(directions.length - 1, index)];
    const normalBefore = leftOf(before);
    const normalAfter = leftOf(after);
    const sum = add(normalBefore, normalAfter);
    const miter = length(sum) > 1e-9 ? unit(sum) : normalAfter;
    const cosine = miter[0] * normalAfter[0] + miter[1] * normalAfter[1];
    invariant(cosine > 0.5, "Street fence leg turns too sharply to offset");
    return add(point, scale(miter, d / cosine));
  });
}

function segmentsCross(a, b, c, d) {
  const orientation = (p, q, r) => (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0]);
  const d1 = orientation(c, d, a);
  const d2 = orientation(c, d, b);
  const d3 = orientation(a, b, c);
  const d4 = orientation(a, b, d);
  return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
}

export function validateFenceRules(zone, kinds) {
  if (zone.fences == null) return;
  invariant(Array.isArray(zone.fences), `Street detail zone ${zone.id} fences must be a list`);
  const ids = new Set();
  for (const rule of zone.fences) {
    const label = `Street detail zone ${zone.id} fence rule ${rule?.id}`;
    invariant(typeof rule?.id === "string" && SAFE_ID.test(rule.id) && !ids.has(rule.id), `${label} needs a unique lower_snake id`);
    ids.add(rule.id);
    invariant(["legs", "osm_way"].includes(rule?.pattern), `${label} pattern must be legs or osm_way`);
    const fields = rule.pattern === "legs" ? RULE_FIELDS : OSM_WAY_RULE_FIELDS;
    const optional = rule.pattern === "legs" ? OPTIONAL_RULE_FIELDS : OSM_WAY_RULE_OPTIONAL;
    invariant(JSON.stringify(Object.keys(rule).filter((key) => !optional.includes(key)).sort()) === JSON.stringify([...fields]),
      `${label} must have exactly ${fields.join(", ")} (and optionally ${optional.join(", ")})`);
    invariant(rule.kind === "fence" && kinds.fence?.layer === "fences", `${label} kind must be fence`);
    invariant(rule.basis === "production_inference", `${label}: rule-based fences are production_inference`);
    for (const field of ["rule", "evidence"]) invariant(typeof rule[field] === "string" && rule[field].trim() !== "", `${label} needs ${field}`);
    invariant(rule.params != null && typeof rule.params === "object" && !Array.isArray(rule.params), `${label} params must be an object`);
    if (rule.pattern === "osm_way") {
      invariant(/^w\d+$/u.test(rule.way), `${label} way must be an OSM way key`);
      invariant([rule.from_m, rule.to_m].every(isFiniteNumber) && rule.from_m >= 0 && rule.to_m >= 0 && Math.abs(rule.to_m - rule.from_m) >= MINIMUM_RUN_M, `${label} needs from_m and to_m at least ${MINIMUM_RUN_M} m apart`);
      invariant(rule.offset_m === undefined || (isFiniteNumber(rule.offset_m) && rule.offset_m !== 0 && Math.abs(rule.offset_m) <= 3), `${label} offset_m must be a non-zero shift of at most 3 m`);
      if (rule.fence_type === FENCE_TYPE_NONE) {
        invariant(Object.keys(rule.params).length === 0 && rule.offset_m === undefined && rule.gates === undefined, `${label}: fence_type none takes no params, offset_m or gates`);
        continue;
      }
    }
    invariant(fenceParamsError(rule.fence_type, rule.params) === null, `${label}: ${fenceParamsError(rule.fence_type, rule.params)}`);
    if (rule.gates !== undefined) {
      invariant(STREET_FENCE_GATED_TYPES.includes(rule.fence_type), `${label}: only ${STREET_FENCE_GATED_TYPES.join(", ")} rules take gates`);
      invariant(Array.isArray(rule.gates) && rule.gates.length > 0, `${label} gates must be a nonempty list`);
      for (const gate of rule.gates) {
        invariant(JSON.stringify(Object.keys(gate ?? {}).filter((key) => key !== "hinge").sort()) === JSON.stringify(["at_m", "style", "width_m"]), `${label}: a gate is {at_m, width_m, style} and optionally hinge`);
        invariant(isFiniteNumber(gate.at_m) && gate.at_m >= 0 && isFiniteNumber(gate.width_m) && gate.width_m >= 0.9 && gate.width_m <= 12, `${label}: a gate needs at_m >= 0 and width_m 0.9..12`);
        invariant(STREET_FENCE_GATE_STYLES.includes(gate.style), `${label}: gate style must be ${STREET_FENCE_GATE_STYLES.join(", ")}`);
        invariant(gate.hinge === undefined || STREET_FENCE_GATE_HINGES.includes(gate.hinge), `${label}: gate hinge must be ${STREET_FENCE_GATE_HINGES.join(" or ")}`);
      }
    }
    if (rule.banners !== undefined) {
      invariant(STREET_FENCE_BANNER_TYPES.includes(rule.fence_type), `${label}: only ${STREET_FENCE_BANNER_TYPES.join(", ")} rules take banners`);
      invariant(Array.isArray(rule.banners) && rule.banners.length > 0, `${label} banners must be a nonempty list`);
      const height = fenceHeight(rule.fence_type, rule.params);
      for (const banner of rule.banners) {
        invariant(JSON.stringify(Object.keys(banner ?? {}).sort()) === JSON.stringify(["at_m", "height_m", "width_m"]), `${label}: a banner is exactly {at_m, width_m, height_m}`);
        invariant(isFiniteNumber(banner.at_m) && banner.at_m >= 0 && isFiniteNumber(banner.width_m) && banner.width_m >= 0.5 && banner.width_m <= 6
          && isFiniteNumber(banner.height_m) && banner.height_m >= 0.3 && banner.height_m <= height - 0.2, `${label}: a banner needs at_m >= 0, width_m 0.5..6 and height_m 0.3..${(height - 0.2).toFixed(2)}`);
      }
    }
    if (rule.pattern === "osm_way") continue;
    invariant(rule.deck === undefined || /^w\d+$/u.test(rule.deck), `${label} deck must be the OSM way key of a context deck`);
    invariant(Array.isArray(rule.legs) && rule.legs.length > 0, `${label} needs legs`);
    for (const leg of rule.legs) {
      if ("xz" in leg) {
        invariant(Object.keys(leg).length === 1 && Array.isArray(leg.xz) && leg.xz.length === 2 && leg.xz.every(isFiniteNumber), `${label}: a point leg is exactly {xz: [x, z]}`);
      } else {
        invariant(JSON.stringify(Object.keys(leg).sort()) === JSON.stringify(["from_m", "offset_m", "side", "to_m", "way"]), `${label}: a way leg is exactly {way, side, offset_m, from_m, to_m}`);
        invariant(/^w\d+$/u.test(leg.way) && ["left", "right"].includes(leg.side), `${label}: a way leg needs an OSM way and side left or right`);
        invariant([leg.offset_m, leg.from_m, leg.to_m].every(isFiniteNumber) && leg.offset_m > 0 && leg.from_m >= 0 && leg.to_m >= 0 && leg.from_m !== leg.to_m, `${label}: way leg offset and along-distances are invalid`);
      }
    }
  }
}

// Why a fence type's params are unusable, or null: every type takes inside;
// a screened fence its screen colour and, optionally, the screen's height; a
// slatted one its slat colour and, optionally, its height (6 or 8 ft).
export function fenceParamsError(type, params) {
  const spec = STREET_FENCE_TYPES[type];
  if (!spec) return `unknown fence type ${type}`;
  if (params === null || typeof params !== "object" || Array.isArray(params)) return "params must be an object";
  const allowed = type === "chain_link_screened" ? ["inside", "screen", "screen_height_m"] : type === "chain_link_slatted" ? ["height_m", "inside", "slats"] : ["inside"];
  if (!Object.keys(params).every((key) => allowed.includes(key))) return `params take only ${allowed.join(", ")}`;
  if (!STREET_FENCE_INSIDE.includes(params.inside)) return `params.inside must be ${STREET_FENCE_INSIDE.join(", ")}`;
  if (type === "chain_link_screened") {
    if (!STREET_FENCE_SCREENS.includes(params.screen)) return `params.screen must be ${STREET_FENCE_SCREENS.join(", ")}`;
    const screen = params.screen_height_m;
    if (screen !== undefined && !(isFiniteNumber(screen) && screen >= STREET_FENCE_SCREEN_MIN_M && screen <= spec.height_m)) return `params.screen_height_m must be ${STREET_FENCE_SCREEN_MIN_M}..${spec.height_m}`;
  }
  if (type === "chain_link_slatted") {
    if (!STREET_FENCE_SLATS.includes(params.slats)) return `params.slats must be ${STREET_FENCE_SLATS.join(", ")}`;
    if (params.height_m !== undefined && !spec.heights_m.includes(params.height_m)) return `params.height_m must be ${spec.heights_m.join(" or ")}`;
  }
  return null;
}

// A fence's height: a slatted fence may be the taller 8 ft kind.
export function fenceHeight(type, params) {
  const spec = STREET_FENCE_TYPES[type];
  return type === "chain_link_slatted" && params?.height_m !== undefined ? params.height_m : spec.height_m;
}

// The style a gate opening of this width gets when no rule names one.
export function defaultGateStyle(widthM) {
  return widthM <= 1.8 ? "swing_single" : widthM <= 5.0 ? "swing_double" : "sliding";
}

// A sliding gate's leaf parks along the run before the gate: this long.
export const SLIDING_LEAF_EXTRA_M = 0.3;
// A gate leaf's collision half thickness (game/scripts/world/street_fence_kit.gd).
export const GATE_LEAF_HALF_M = 0.04;

// The open leaves of a gate between its two ends (plan [x, z], in the line's
// order), as the fence kit draws and collides them: [{xz: [[hinge x, z], [far
// x, z]], post}], post the end (0 or 1) whose height the leaf hangs at. Swing
// leaves stand square to the fence on its inside, hinged 0.06 m in from their
// post (a single leaf on the start post unless hinge is "end"); a sliding leaf
// lies along the fence 0.16 m inside it, back from the start post over the run
// before the gate.
export function gateLeaves(ends, style, hinge, inside) {
  const [a, b] = ends;
  const width = Math.hypot(b[0] - a[0], b[1] - a[1]);
  const along = [(b[0] - a[0]) / width, (b[1] - a[1]) / width];
  const side = inside === "right" ? -1 : 1;
  const into = [along[1] * side, -along[0] * side];
  const leaf = (end, post, offset, direction, length) => {
    const at = [end[0] + into[0] * offset, end[1] + into[1] * offset];
    return { xz: [at, [at[0] + direction[0] * length, at[1] + direction[1] * length]].map((point) => point.map(roundCoordinate)), post };
  };
  if (style === "swing_single") return [hinge === "end" ? leaf(b, 1, 0.06, into, width - 0.12) : leaf(a, 0, 0.06, into, width - 0.12)];
  if (style === "swing_double") return [leaf(a, 0, 0.06, into, width / 2 - 0.08), leaf(b, 1, 0.06, into, width / 2 - 0.08)];
  return [leaf(a, 0, 0.16, [-along[0], -along[1]], width + SLIDING_LEAF_EXTRA_M)];
}

// The kit type for an OSM fence way: its fence_type tag, else its context.
export function osmFenceType(tags) {
  if (typeof tags.fence_type === "string") {
    const value = tags.fence_type.split(";")[0].trim();
    if (OSM_FENCE_TYPES[value]) return { type: OSM_FENCE_TYPES[value], basis: `osm_fence_type:${value}` };
    return { type: "chain_link", basis: `osm_fence_type_unknown:${value}` };
  }
  if (tags.landuse === "construction") return { type: "construction_panel", basis: "osm_context:landuse=construction" };
  for (const key of ["power", "pipeline", "hazard", "military"]) {
    if (tags[key] != null) return { type: "chain_link_barbed", basis: `osm_context:${key}=${tags[key]}` };
  }
  if (tags.man_made === "pumping_station") return { type: "chain_link_barbed", basis: "osm_context:man_made=pumping_station" };
  return { type: "chain_link", basis: "default" };
}

// Resolves the fences. Mutates the OSM fence rows (status, exclusion, fence, prop)
// and returns the rule rows plus an audit. ctx carries the generator's site queries.
export function placeStreetFences({
  config,
  rows,
  zoneShapes,
  kinds,
  site,
  roads,
  buildings,
  hardShapes,
  hardViolation,
  onLand,
  grounded,
  deckSupport,
  surfaceAt,
  wayLine,
  rawOsm,
  nodeTags,
}) {
  const audit = { osm_fences: 0, osm_built: 0, rule_fences: 0, built_length_m: 0, openings_by_reason: {}, fully_open: [] };
  const count = (key) => {
    audit.openings_by_reason[key] = (audit.openings_by_reason[key] ?? 0) + 1;
  };
  const pilotShapes = zoneShapes.filter(({ zone }) => zone.pilot);
  const inPilot = (xz) => pilotShapes.some(({ contains }) => contains(xz));
  const toEastNorth = (xz) => [xz[0], -xz[1]];

  // Candidate polygons near a line, so each sample tests only a few.
  const near = (set, line, reach) => {
    const xs = line.map((point) => point[0]);
    const ns = line.map((point) => -point[1]);
    const box = { min_x: Math.min(...xs) - reach, max_x: Math.max(...xs) + reach, min_y: Math.min(...ns) - reach, max_y: Math.max(...ns) + reach };
    return set.items.filter((item) => item.bounds.min_x <= box.max_x && item.bounds.max_x >= box.min_x && item.bounds.min_y <= box.max_y && item.bounds.max_y >= box.min_y);
  };
  // Gameplay buffers whose bounds come within reach of a line.
  const nearShapes = (line, reach) => {
    const xs = line.map((point) => point[0]);
    const zs = line.map((point) => point[1]);
    const box = [Math.min(...xs) - reach, Math.max(...xs) + reach, Math.min(...zs) - reach, Math.max(...zs) + reach];
    return hardShapes.filter((shape) => {
      const sx = shape.points.map((point) => point[0]);
      const sz = shape.points.map((point) => point[1]);
      return Math.min(...sx) - shape.radius_m <= box[1] && Math.max(...sx) + shape.radius_m >= box[0] &&
        Math.min(...sz) - shape.radius_m <= box[3] && Math.max(...sz) + shape.radius_m >= box[2];
    });
  };

  // Where a fence's posts stand: on its deck's triangles, else on the land.
  const supportOn = (deck) => (deck ? (xz) => {
    const at = deckSupport(deck, xz);
    invariant(at, `Street fence post at (${xz.join(", ")}) is off its deck ${deck}`);
    return at;
  } : grounded);
  // Openings along a fence line: [{from_m, to_m, reason, source_id}], sorted;
  // a rule gate's opening keeps its style and hinge. A fence on a deck opens
  // where it leaves the deck rather than the land.
  const openingsOf = (line, halfThickness, { rule, gates, cuts, deck }) => {
    const lengths = cumulative(line);
    const total = lengths.at(-1);
    const nearbyRoads = near(roads, line, 2);
    const nearbyBuildings = near(buildings, line, 2);
    const nearbyShapes = nearShapes(line, halfThickness + 1);
    const blocked = [];
    const steps = Math.max(1, Math.ceil(total / SAMPLE_STEP_M));
    for (let step = 0; step <= steps; step += 1) {
      const s = (total * step) / steps;
      const xz = pointAt(line, lengths, s);
      const en = toEastNorth(xz);
      let reason = null;
      if (deck ? deckSupport(deck, xz) === null : !onLand(xz, halfThickness)) reason = deck ? { reason: "off_deck", source_id: deck } : { reason: "land_edge", source_id: "land" };
      if (!reason) {
        const building = nearbyBuildings.find((item) => pointInMultiPolygon(en, item.geometry, true));
        if (building) reason = { reason: "building", source_id: building.key };
      }
      if (!reason) {
        const hard = hardViolation(nearbyShapes, [xz], halfThickness);
        if (hard) reason = { reason: `mask:${hard.reason}`, source_id: hard.source_id };
      }
      if (!reason) {
        const road = nearbyRoads.filter((item) => pointInMultiPolygon(en, item.geometry, true)).sort((left, right) => compareSourceKeys(left.key, right.key))[0];
        if (road) reason = { reason: "crossing", source_id: road.key };
      }
      if (!reason && site && (site.raised(en) || site.carriagewayDistance(en, 1) === 0)) {
        invariant(!rule, `Street fence rule ${rule} enters the raised street ground or the carriageway at (${xz.map((value) => value.toFixed(2)).join(", ")}); move its legs`);
        reason = { reason: "street_ground", source_id: "street_ground" };
      }
      blocked.push(reason);
    }
    // Maximal blocked stretches, widened by the crossing margin where a road or path crosses.
    const intervals = [];
    for (let step = 0; step <= steps; step += 1) {
      if (!blocked[step]) continue;
      const start = step;
      while (step + 1 <= steps && blocked[step + 1] && blocked[step + 1].reason === blocked[start].reason && blocked[step + 1].source_id === blocked[start].source_id) step += 1;
      const margin = blocked[start].reason === "crossing" ? CROSSING_MARGIN_M : SAMPLE_STEP_M;
      intervals.push({
        from_m: Math.max(0, (total * start) / steps - margin),
        to_m: Math.min(total, (total * step) / steps + margin),
        reason: blocked[start].reason,
        source_id: blocked[start].source_id,
      });
    }
    for (const gate of gates) {
      intervals.push({ from_m: Math.max(0, gate.at_m - gate.width_m / 2), to_m: Math.min(total, gate.at_m + gate.width_m / 2), reason: "gate", source_id: gate.source_id, style: gate.style ?? null, hinge: gate.hinge ?? null });
    }
    for (const cut of cuts) intervals.push({ from_m: cut.from_m, to_m: cut.to_m, reason: "osm_way_rule", source_id: cut.source_id });
    intervals.sort((left, right) => left.from_m - right.from_m || compareSourceKeys(left.source_id, right.source_id));
    // Runs left between openings, dropping stubs too short to stand.
    const runs = [];
    let cursor = 0;
    for (const interval of intervals) {
      if (interval.from_m - cursor >= MINIMUM_RUN_M) runs.push([cursor, interval.from_m]);
      cursor = Math.max(cursor, interval.to_m);
    }
    if (total - cursor >= MINIMUM_RUN_M) runs.push([cursor, total]);
    // Openings are what the runs leave out, each named by the intervals it holds.
    const openings = [];
    let at = 0;
    for (const [s0, s1] of [...runs, [total, total]]) {
      if (s0 - at > 1e-9) {
        const inside = intervals.filter((interval) => interval.to_m > at && interval.from_m < s0);
        const named = inside.length > 0 ? inside : [{ reason: "short_run", source_id: "" }];
        const opening = {
          from_m: roundCoordinate(at),
          to_m: roundCoordinate(s0),
          reason: [...new Set(named.map((interval) => interval.reason))].sort().join("+"),
          source_ids: [...new Set(named.map((interval) => interval.source_id).filter(Boolean))].sort(compareSourceKeys),
        };
        const styled = named.find((interval) => interval.style);
        if (styled) opening.style = styled.style;
        const hinged = named.find((interval) => interval.hinge);
        if (hinged) opening.hinge = hinged.hinge;
        openings.push(opening);
      }
      at = s1;
    }
    return { lengths, total, runs, openings };
  };

  // Posts of one solid run: every bay at most spacing long, a post at each corner.
  const postsOf = (line, lengths, s0, s1, spacing) => {
    const piece = slice(line, lengths, s0, s1);
    const posts = [piece[0]];
    for (let index = 1; index < piece.length; index += 1) {
      const span = length(sub(piece[index], piece[index - 1]));
      const bays = Math.max(1, Math.ceil(span / spacing - 1e-9));
      for (let bay = 1; bay <= bays; bay += 1) posts.push(add(piece[index - 1], scale(sub(piece[index], piece[index - 1]), bay / bays)));
    }
    return posts.map((point) => [roundCoordinate(point[0]), roundCoordinate(point[1])])
      .filter((point, index, all) => index === 0 || point[0] !== all[index - 1][0] || point[1] !== all[index - 1][1]);
  };
  const runRecord = (posts, deck = null) => {
    const supports = posts.map(supportOn(deck));
    return {
      points_m: posts.map((point, index) => [point[0], supports[index].y, point[1]]),
      terrain_supports: supports.map(({ support }) => [support.object_key, support.triangle_index]),
      surface_bias_m: posts.map((point) => (deck ? 0 : surfaceAt(point).bias_m)),
    };
  };
  // A row that will be built gets its posts; a data-only row keeps its vertices.
  const fenceBlock = (line, type, typeBasis, params, label, { rule = null, gates = [], banners = [], cuts = [], posts = true, deck = null } = {}) => {
    const spec = STREET_FENCE_TYPES[type];
    const { lengths, total, runs, openings } = openingsOf(line, spec.half_thickness_m, { rule, gates, cuts, deck });
    for (const opening of openings) count(opening.reason);
    const built = runs.map(([s0, s1]) => runRecord(postsOf(line, lengths, s0, s1, posts ? spec.post_spacing_m : Infinity), deck));
    invariant(built.every((run) => run.points_m.length >= 2), `${label} has a run without two posts`);
    const block = {
      type,
      type_basis: typeBasis,
      height_m: fenceHeight(type, params),
      half_thickness_m: spec.half_thickness_m,
      params,
      length_m: roundCoordinate(total),
      openings,
      runs: built,
    };
    if (deck) block.deck = deck;
    // Gates: posts at both ends of the gate's opening and the open leaves (a
    // gate may fill a whole short line, as between two container walls; one
    // narrower than 0.9 m has none). A slatted fence takes every gate opening,
    // plain and screened chain-link the rule's gates.
    const ends = (from, to) => [pointAt(line, lengths, from), pointAt(line, lengths, to)].map((point) => [roundCoordinate(point[0]), roundCoordinate(point[1])]);
    if (STREET_FENCE_GATED_TYPES.includes(type) && posts) {
      const gateRecords = [];
      for (const opening of openings) {
        if (!opening.reason.split("+").includes("gate")) continue;
        if (type !== "chain_link_slatted" && !opening.style) continue;
        const width = opening.to_m - opening.from_m;
        if (width < 0.9) continue;
        let style = opening.style ?? defaultGateStyle(width);
        // A sliding leaf needs a solid run before the gate at least as long as
        // itself: a rule's sliding gate that has none fails; a default one
        // swings open instead.
        if (style === "sliding") {
          const before = runs.find(([, s1]) => Math.abs(s1 - opening.from_m) < 1e-6);
          const fits = before !== undefined && before[1] - before[0] >= width + SLIDING_LEAF_EXTRA_M;
          invariant(fits || !opening.style, `${label}: its sliding gate at ${opening.from_m}..${opening.to_m} m has no solid run before it as long as its leaf (${(width + SLIDING_LEAF_EXTRA_M).toFixed(2)} m)`);
          if (!fits) style = "swing_double";
        }
        const record = runRecord(ends(opening.from_m, opening.to_m), deck);
        const plan = record.points_m.map((point) => [point[0], point[2]]);
        const gate = { style, from_m: opening.from_m, to_m: opening.to_m, ...record, leaves: gateLeaves(plan, style, opening.hinge, params.inside) };
        if (opening.hinge) gate.hinge = opening.hinge;
        gateRecords.push(gate);
      }
      if (gateRecords.length > 0) block.gates = gateRecords;
    }
    // Banners hang on a solid run, never across an opening.
    if (banners.length > 0 && posts) {
      block.banners = banners.map((banner, index) => {
        const from = roundCoordinate(Math.max(0, banner.at_m - banner.width_m / 2));
        const to = roundCoordinate(Math.min(total, banner.at_m + banner.width_m / 2));
        invariant(runs.some(([s0, s1]) => from >= s0 - 1e-6 && to <= s1 + 1e-6), `${label} banner ${index} (${from}..${to} m) does not hang on one solid run`);
        return { from_m: from, to_m: to, height_m: banner.height_m, ...runRecord(ends(from, to), deck) };
      });
    }
    return block;
  };
  const applyStatus = (row) => {
    // A fence stands where it has solid runs or gates.
    if (row.fence.runs.length > 0 || (row.fence.gates?.length ?? 0) > 0) {
      row.status = "placed";
      row.exclusion = null;
      return;
    }
    row.status = "excluded";
    row.exclusion = { reason: "fully_open", source_id: row.fence.openings.flatMap((opening) => opening.source_ids)[0] ?? "", observed_m: 0, required_m: 0 };
    audit.fully_open.push(row.id);
  };
  // A fence is built when its line reaches a pilot zone (sampled every metre).
  const reachesPilot = (line) => {
    const lengths = cumulative(line);
    for (let s = 0; s <= lengths.at(-1); s += 1) if (inPilot(pointAt(line, lengths, s))) return true;
    return inPilot(line.at(-1));
  };
  const setProp = (row, params) => {
    row.prop = row.fence.type;
    row.prop_params = params;
    audit.built_length_m = roundCoordinate(audit.built_length_m + row.fence.runs.reduce((sum, run) => {
      let total = 0;
      for (let index = 1; index < run.points_m.length; index += 1) total += Math.hypot(run.points_m[index][0] - run.points_m[index - 1][0], run.points_m[index][2] - run.points_m[index - 1][2]);
      return sum + total;
    }, 0));
  };

  // --- OSM fence ways.
  // The stretches the pilot zones' osm_way rules take over, by OSM way.
  const osmFenceRows = new Map(rows.filter((candidate) => candidate.source === "osm" && candidate.kind === "fence").map((row) => [row.source_id, row]));
  const wayRules = new Map();
  for (const { zone } of pilotShapes) {
    for (const rule of zone.fences ?? []) {
      if (rule.pattern !== "osm_way") continue;
      const label = `Street fence rule ${zone.id}/${rule.id}`;
      const target = osmFenceRows.get(rule.way);
      invariant(target, `${label} names ${rule.way}, which is not an OSM fence row on the land`);
      // An end within OSM_WAY_END_SLACK_M past the way's end means its end.
      const total = cumulative(target.points_m.map((point) => [point[0], point[2]])).at(-1);
      invariant(Math.max(rule.from_m, rule.to_m) <= total + OSM_WAY_END_SLACK_M, `${label} runs past the end of ${rule.way} (${roundCoordinate(total)} m)`);
      if (!wayRules.has(rule.way)) wayRules.set(rule.way, []);
      wayRules.get(rule.way).push({ zone, rule, from_m: Math.min(rule.from_m, rule.to_m, total), to_m: Math.min(Math.max(rule.from_m, rule.to_m), total) });
    }
  }
  for (const stretches of wayRules.values()) {
    stretches.sort((left, right) => left.from_m - right.from_m);
    for (let index = 1; index < stretches.length; index += 1) {
      invariant(stretches[index].from_m >= stretches[index - 1].to_m, `Street fence rules ${stretches[index - 1].rule.id} and ${stretches[index].rule.id} overlap on ${stretches[index].rule.way}`);
    }
  }
  // The gates (OSM gate nodes) on a fence way, at along-distances of its line.
  const gatesOf = (row, lengths) => {
    const way = rawOsm.ways.get(row.source_id.slice(1));
    invariant(way, `${row.id} has no raw topology`);
    const gates = [];
    way.node_refs.forEach((ref, index) => {
      const tags = nodeTags(ref);
      if (!GATE_VALUES.includes(tags.barrier)) return;
      const tagged = Number.parseFloat(tags.width);
      const width = Number.isFinite(tagged) && tagged > 0 ? Math.min(tagged, MAXIMUM_GATE_WIDTH_M) : GATE_WIDTH_M;
      gates.push({ at_m: lengths[index], width_m: width + 2 * CROSSING_MARGIN_M, source_id: `n${ref}` });
    });
    return gates;
  };
  for (const row of osmFenceRows.values()) {
    audit.osm_fences += 1;
    const line = row.points_m.map((point) => [point[0], point[2]]);
    const lengths = cumulative(line);
    const gates = gatesOf(row, lengths);
    const cuts = (wayRules.get(row.source_id) ?? []).map(({ zone, rule, from_m, to_m }) => ({ from_m, to_m, source_id: `zone:${zone.id}/${rule.id}` }));
    const { type, basis } = osmFenceType(row.tags ?? {});
    const pilot = reachesPilot(line);
    row.fence = fenceBlock(line, type, basis, { inside: "center" }, row.id, { gates, cuts, posts: pilot });
    applyStatus(row);
    if (row.status === "placed" && pilot) {
      setProp(row, { inside: "center" });
      audit.osm_built += 1;
    }
  }

  // --- Rule fences of the pilot zones.
  const ruleRows = [];
  for (const { zone } of pilotShapes) {
    for (const rule of zone.fences ?? []) {
      const label = `Street fence rule ${zone.id}/${rule.id}`;
      const line = [];
      const vertexSources = [];
      let gates = [];
      if (rule.pattern === "osm_way") {
        if (rule.fence_type === FENCE_TYPE_NONE) continue;
        // The OSM fence's own line between the rule's along-distances, with its gates.
        const target = osmFenceRows.get(rule.way);
        const wayPoints = target.points_m.map((point) => [point[0], point[2]]);
        const wayLengths = cumulative(wayPoints);
        const [s0, s1] = [Math.min(rule.from_m, rule.to_m, wayLengths.at(-1)), Math.min(Math.max(rule.from_m, rule.to_m), wayLengths.at(-1))];
        let piece = slice(wayPoints, wayLengths, s0, s1);
        if (rule.offset_m !== undefined) piece = offsetLine(piece, rule.offset_m);
        if (rule.from_m > rule.to_m) piece.reverse();
        line.push(...piece);
        vertexSources.push(...piece.map(() => rule.way));
        gates = gatesOf(target, wayLengths)
          .filter((gate) => gate.at_m > s0 && gate.at_m < s1)
          .map((gate) => ({ ...gate, at_m: rule.from_m > rule.to_m ? s1 - gate.at_m : gate.at_m - s0 }));
      }
      for (const leg of rule.legs ?? []) {
        if ("xz" in leg) {
          line.push([...leg.xz]);
          vertexSources.push("rule_point");
          continue;
        }
        const wayPoints = wayLine(leg.way);
        const wayLengths = cumulative(wayPoints);
        invariant(Math.max(leg.from_m, leg.to_m) <= wayLengths.at(-1) + 1e-6, `${label}: leg runs past the end of ${leg.way}`);
        const piece = slice(wayPoints, wayLengths, Math.min(leg.from_m, leg.to_m), Math.max(leg.from_m, leg.to_m));
        const shifted = offsetLine(piece, leg.side === "left" ? leg.offset_m : -leg.offset_m);
        if (leg.from_m > leg.to_m) shifted.reverse();
        line.push(...shifted);
        vertexSources.push(...shifted.map(() => leg.way));
      }
      // Rounded once, then no repeated or near-repeated vertices.
      const points = [];
      const sources = [];
      line.forEach((point, index) => {
        const rounded = [roundCoordinate(point[0]), roundCoordinate(point[1])];
        if (points.length > 0 && length(sub(rounded, points.at(-1))) < 0.05) return;
        points.push(rounded);
        sources.push(vertexSources[index]);
      });
      invariant(points.length >= 2, `${label} has fewer than two distinct points`);
      for (let i = 1; i < points.length; i += 1) {
        for (let j = i + 2; j < points.length; j += 1) {
          invariant(!segmentsCross(points[i - 1], points[i], points[j - 1], points[j]), `${label} crosses itself`);
        }
      }
      for (const point of points) invariant(rule.deck ? deckSupport(rule.deck, point) !== null : onLand(point, 0), `${label} has a point off ${rule.deck ? `its deck ${rule.deck}` : "the island"}`);
      const supports = points.map(supportOn(rule.deck));
      const params = { ...rule.params };
      const row = {
        id: `scatter:${zone.id}:${rule.id}:line`,
        source: "scatter",
        source_id: `zone:${zone.id}/${rule.id}`,
        kind: rule.kind,
        layer: kinds[rule.kind].layer,
        geometry: "polyline",
        points_m: points.map((point, index) => [point[0], supports[index].y, point[1]]),
        terrain_supports: supports.map(({ support }) => [support.object_key, support.triangle_index]),
        vertex_source_ids: sources,
        closed: false,
        length_m: roundCoordinate(cumulative(points).at(-1)),
        attached_ids: [],
        status: "placed",
        exclusion: null,
        basis: rule.basis,
      };
      // A rule along an OSM fence opens where that fence would (its gates, roads
      // and street ground); a traced rule must keep off the street ground.
      const ruleGates = (rule.gates ?? []).map((gate, index) => ({ at_m: gate.at_m, width_m: gate.width_m, style: gate.style, hinge: gate.hinge, source_id: `${rule.id}:gate_${index}` }));
      row.fence = fenceBlock(points, rule.fence_type, "rule", params, label, rule.pattern === "osm_way" ? { gates: [...gates, ...ruleGates] } : { rule: `${zone.id}/${rule.id}`, gates: ruleGates, banners: rule.banners ?? [], deck: rule.deck ?? null });
      applyStatus(row);
      invariant(row.status === "placed", `${label} is open along its whole length`);
      setProp(row, params);
      ruleRows.push(row);
      audit.rule_fences += 1;
    }
  }
  audit.fully_open.sort();
  return { rows: ruleRows, audit };
}

// The solid pieces of a placed fence row, as world-xz polylines, for clearance
// and overlap checks; other rows give their own points as one piece.
export function fencePieces(row) {
  if (row.fence) return row.fence.runs.map((run) => run.points_m.map((point) => [point[0], point[2]]));
  return [row.geometry === "point" ? [[row.position_m[0], row.position_m[2]]] : row.points_m.map((point) => [point[0], point[2]])];
}
