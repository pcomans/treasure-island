// Street furniture: the vertical street objects of PlayableWorld/StreetDetail/Furniture.
//
// Three sources, all resolved to rows of generated/world/street_detail.json:
//   - OSM rows of a furniture kind get a kit prop. The kinds in
//     ISLAND_STREET_OBJECT_KINDS (utility poles, lamps, hydrants, transformer
//     cabinets, bus stops and stop signs) and ISLAND_FURNITURE_KINDS (benches,
//     waste baskets, bike racks) get it island-wide, the others in the pilot
//     zones only. A stop sign moves from its node on the road to the right-hand
//     curb of the approach it controls, beside the painted stop bar; an item
//     mapped on the frozen carriageway (a generator width, not the surveyed
//     curb) steps off it; a bus stop with a shelter gets one beside its road;
//     and the OSM power lines carry wires between their built poles (power_wires).
//   - rule rows from the "furniture" lists of the zones in
//     tools/config/street-detail-zones.json fill what OSM leaves out in the
//     pilot zones (lamps along curbs, signal poles at signalized crossings, the
//     controller cabinet, street-name signs at junctions, the other approaches
//     of an all-way stop, a stop sign for traffic turning into a drive, lights
//     around a parking lot);
//   - the island-wide rules of its "island_furniture" block, applied to every
//     matching OSM feature: street lights on the road-side utility poles and
//     along named streets, stop signs on the minor approaches of junctions,
//     street names at the junctions of named streets (on a photographed stop
//     post or lamp, else on their own corner post), the other approaches of
//     all-way stops and signal poles at signalized crossings.
// Every rule says it is production inference and names its dated photo evidence.
//
// Plan geometry here is east/north (the ground generator's frame); rows use
// world x, z with z = -north. A prop's front is its local -Z (the lamp arm, the
// signal mast arm, a sign's face); yaw turns it toward the given direction.

import { createHash } from "node:crypto";
import { projectLonLat } from "./coordinates.mjs";
import { pointInMultiPolygon } from "./osm-geometry.mjs";
import { compareSourceKeys, invariant, roundCoordinate } from "./world-contract.mjs";

// Kit props built by game/scripts/world/street_furniture_kit.gd, with the row
// kind each one stands for.
export const STREET_FURNITURE_PROPS = Object.freeze({
  adirondack_chair: "chair",
  bbq_grill: "bbq",
  bench_long: "bench",
  bench_park: "bench",
  bench_wedge: "bench",
  bike_rack: "bicycle_parking",
  bus_shelter: "bus_stop",
  bus_stop_sign: "bus_stop",
  canopy_of_sky: "artwork",
  ev_charger_bay: "charging_station",
  event_pole: "street_lamp",
  hydrant: "fire_hydrant",
  lamp_cobra: "street_lamp",
  lamp_disc: "street_lamp",
  lamp_lot: "street_lamp",
  lamp_plaza: "street_lamp",
  log_seat: "bench",
  map_board: "information_board",
  monument_sign: "street_sign",
  name_sign: "street_sign",
  picnic_table_long: "picnic_table",
  power_wires: "power_line",
  post_sign: "street_sign",
  pump_station: "site_structure",
  restroom_cottage: "site_structure",
  galvanised_tub: "site_structure",
  water_block: "site_structure",
  cobble_pile: "site_structure",
  signal_cabinet: "street_cabinet",
  signal_mast: "traffic_signals",
  stop_sign: "stop_sign",
  transformer_pad: "street_cabinet",
  utility_pole: "power_pole",
  waste_basket: "waste_basket",
});
// A bike rack's row: at most this many hoops, this far apart along its local Z,
// centred on its origin (street_furniture_kit.gd).
export const BIKE_RACK_MAX_HOOPS = 10;
export const BIKE_RACK_HOOP_SPACING_M = 0.9;
// Each hoop's legs reach 0.1 m below the rack's origin: the ground under every
// hoop stays this close to the ground at its centre (m).
const BIKE_RACK_LEVEL_M = 0.06;
// Plan sizes {x_m, z_m} (along the prop's local X and Z) of the kit props that
// are longer than their kind's radius covers; set pieces and the rows of these
// props carry them as their footprint for the shared mask.
export const STREET_FURNITURE_FOOTPRINTS = Object.freeze({
  adirondack_chair: Object.freeze({ x_m: 0.8, z_m: 0.92 }),
  bbq_grill: Object.freeze({ x_m: 0.8, z_m: 0.6 }),
  bench_park: Object.freeze({ x_m: 1.9, z_m: 0.66 }),
  bench_wedge: Object.freeze({ x_m: 4.1, z_m: 0.6 }),
  bike_rack: Object.freeze({ x_m: 0.8, z_m: 0.12 }),
  bus_shelter: Object.freeze({ x_m: 3.9, z_m: 1.8 }),
  ev_charger_bay: Object.freeze({ x_m: 3.4, z_m: 1.3 }),
  map_board: Object.freeze({ x_m: 1.34, z_m: 0.2 }),
  monument_sign: Object.freeze({ x_m: 1.3, z_m: 0.3 }),
  pump_station: Object.freeze({ x_m: 16.3, z_m: 11.2 }),
  // The cottage block with the enclosure on its +X end, as one plan rectangle round
  // the prop's origin (street_furniture_kit.gd COTTAGE_PLAN_CENTRE).
  restroom_cottage: Object.freeze({ x_m: 9.1, z_m: 4.45 }),
  galvanised_tub: Object.freeze({ x_m: 1.1, z_m: 1.1 }),
  water_block: Object.freeze({ x_m: 1.86, z_m: 0.5 }),
  transformer_pad: Object.freeze({ x_m: 1.5, z_m: 1.35 }),
  waste_basket: Object.freeze({ x_m: 0.6, z_m: 0.6 }),
});
// The plan size of a kit prop whose size comes from its params (the long park
// bench, the salvaged log seats and the long picnic table, drawn by
// street_furniture_kit.gd within the same clamps), else its fixed footprint.
export function streetFurnitureFootprint(prop, params) {
  const number = (key, fallback, low, high) => Math.min(high, Math.max(low, isFiniteNumber(params?.[key]) ? params[key] : fallback));
  if (prop === "bench_long") return { x_m: roundCoordinate(number("length_m", 2.4, 1.2, 6.0) + 0.1), z_m: 0.7 };
  if (prop === "bike_rack") return { x_m: 0.8, z_m: roundCoordinate(0.12 + BIKE_RACK_HOOP_SPACING_M * (Math.round(number("hoops", 1, 1, BIKE_RACK_MAX_HOOPS)) - 1)) };
  if (prop === "picnic_table_long") return { x_m: roundCoordinate(number("length_m", 6.1, 2.0, 7.0) + 0.1), z_m: 2.1 };
  // The player walks through a cobble pile, so only its spine claims ground.
  if (prop === "cobble_pile") return { x_m: roundCoordinate(number("length_m", 5.0, 1.0, 9.0) + 0.2), z_m: 0.4 };
  if (prop === "log_seat") {
    const size = number("size_m", 3.2, 0.5, 5.0);
    if (params?.form === "stump") return { x_m: roundCoordinate(size + 0.06), z_m: roundCoordinate(size + 0.06) };
    if (params?.form === "slab") return { x_m: roundCoordinate(size + 0.1), z_m: roundCoordinate(size * 0.65) };
    if (params?.form === "baulk") return { x_m: roundCoordinate(size + 0.1), z_m: 0.72 };
    return { x_m: roundCoordinate(size + 0.1), z_m: 0.7 };
  }
  return STREET_FURNITURE_FOOTPRINTS[prop] ?? null;
}
// Kit props that stand on legs: the flat bottom of each foot, {x, z, half_x,
// half_z} in the prop's frame (front -Z, right +X), in the kit's leg order
// (front-left, front-right, back-left, back-right). This is the one table of
// the feet: the generated street detail carries it as prop_feet, and
// game/tests/validate_generated_world.gd checks that the legs
// game/scripts/world/street_furniture_kit.gd draws stand on it. A set piece of
// such a prop settles on the visible ground under its feet (settleOnFeet).
export const STREET_FURNITURE_FEET = Object.freeze({
  adirondack_chair: Object.freeze([
    Object.freeze({ x: -0.3, z: -0.305, half_x: 0.0115, half_z: 0.037 }),
    Object.freeze({ x: 0.3, z: -0.305, half_x: 0.0115, half_z: 0.037 }),
    Object.freeze({ x: -0.3, z: 0.373, half_x: 0.0115, half_z: 0.034 }),
    Object.freeze({ x: 0.3, z: 0.373, half_x: 0.0115, half_z: 0.034 }),
  ]),
});
// The most a settled prop's leg may be lengthened or shortened (m); uneven
// ground that needs more stops the build.
export const MAX_LEG_DROP_M = 0.03;
// Leg changes are made in these steps (m), so props on similar ground share a
// mesh; when every change rounds to nothing the prop rests on its plane alone.
const LEG_DROP_STEP_M = 0.005;
// The steepest rest a prop on feet may take (radians from upright): steeper
// ground stops the build, and the tilted collision box stays inside the
// footprint's clearance stadium.
export const MAX_REST_TILT_RAD = 0.15;
export const STREET_FURNITURE_PATTERNS = Object.freeze([
  "kerb", "signalized_crossings", "near_signals", "junctions", "all_way_stops", "drive_entries", "lot_edge",
  "pole_fixtures", "street_lamps", "junction_stops", "junction_names", "hydrant_style",
]);
// The patterns of the island-wide block: they need no zone of their own.
const ISLAND_PATTERNS = Object.freeze(["pole_fixtures", "street_lamps", "junction_stops", "junction_names", "hydrant_style", "all_way_stops", "signalized_crossings", "near_signals"]);
const ZONE_PATTERNS = Object.freeze(["kerb", "signalized_crossings", "near_signals", "junctions", "all_way_stops", "drive_entries", "lot_edge"]);
// Default props for OSM rows; kinds without one stay unbuilt.
// A bench OSM tags backless is the park's backless bench on its plinth.
const OSM_PROPS = Object.freeze({
  bench: (tags) => (tags.backrest === "no" ? { prop: "bench_long", params: { length_m: 1.8, back: false } } : { prop: "bench_park", params: {} }),
  // A row of hoops for the bikes OSM's capacity counts, two to a hoop (one hoop takes no params).
  bicycle_parking: (tags) => {
    const hoops = Math.min(BIKE_RACK_MAX_HOOPS, Math.ceil((Number.parseInt(tags.capacity ?? "2", 10) || 2) / 2));
    return { prop: "bike_rack", params: hoops > 1 ? { hoops } : {} };
  },
  bus_stop: (tags) => ({ prop: tags.shelter === "yes" ? "bus_shelter" : "bus_stop_sign", params: {} }),
  fire_hydrant: () => ({ prop: "hydrant", params: { style: "yellow" } }),
  power_pole: (tags) => ({ prop: "utility_pole", params: tags["location:transition"] === "yes" ? { riser: true } : {} }),
  stop_sign: (tags) => ({ prop: "stop_sign", params: { all_way: tags.stop === "all" } }),
  street_cabinet: () => ({ prop: "transformer_pad", params: {} }),
  street_lamp: () => ({ prop: "lamp_cobra", params: {} }),
  waste_basket: (tags) => ({ prop: "waste_basket", params: { style: tags.material === "wood" ? "timber" : "steel" } }),
});
// The OSM kinds that get their prop island-wide, the street-objects rollout's
// and the street-clutter rollout's; the others only in pilot zones.
const ISLAND_STREET_OBJECT_KINDS = Object.freeze(["bus_stop", "fire_hydrant", "power_pole", "stop_sign", "street_cabinet", "street_lamp"]);
// Benches, waste baskets and bike racks stand at their OSM nodes. One whose node
// lies on a road or path moves beside it (ISLAND_NUDGES_M).
const ISLAND_FURNITURE_KINDS = Object.freeze(["bench", "bicycle_parking", "waste_basket"]);
const ISLAND_NUDGES_M = Object.freeze([0.6, 1.2, 1.8, 2.4]);
// ... and one whose node lies on ground drawn off its surface's height (a
// verge's sloped back, which the street ground's surface query does not give)
// moves to the nearest level spot: the visible ground within this of the
// surface's height (m).
const ISLAND_LEVEL_M = 0.03;
// How far a post's base may stand from the visible ground (m), inside the
// validator's rest limit for a prop (0.08 m).
const PROP_REST_M = 0.07;
const STOP_SIGN = Object.freeze({ setback_m: 0.55, upstream_m: Array.from({ length: 20 }, (_, index) => roundCoordinate(0.6 * (index + 1))) });
// How far up an approach (m) the street ground looks for what a stop line must
// clear: a crosswalk this close to the junction comes before the stop sign.
const STOP_WALK_REACH_M = 16;
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
// How far an OSM item mapped on the carriageway may step past the road edge
// (m, beyond its own clearance) to find a clear spot on its side.
const STEP_OFF_EXTRA_M = Object.freeze([0, 0.25, 0.5, 0.75, 1, 1.5, 2, 2.5, 3, 4, 5, 6, 7]);
const STEP_OFF_SLIDES_M = Object.freeze([0, 1.5, -1.5, 3, -3]);
// A bus shelter beside its road: the gaps (m) tried between the road edge and
// its open front, and the slides (m) along the road from its OSM node.
const SHELTER_GAPS_M = Object.freeze([0.9, 1.4, 2.0, 2.8, 3.6]);
const SHELTER_SLIDES_M = Object.freeze([0, 1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 6, -6, 7, -7, 8, -8]);
// A cabinet's pad mapped on a paved path (an OSM footway) steps across it, away
// from the road first, by these distances (m) to the first spot clear of it.
const PAD_PATH_STEPS_M = Object.freeze([1, 1.5, 2, 2.5, 3, 3.5, 4, -1, -1.5, -2, -2.5]);
// Props on a level concrete pad (STREET_FURNITURE_PADS): the pad's skirt runs
// PAD_SKIRT_M below its top's foot, so a pad settled on sloping ground (raised
// to its highest corner by its params' lift) may float that much at its low
// side; a rest that would float more stops the build or takes another spot.
// The kit draws its skirt 2 cm deeper (PAD_SKIRT_M 0.32 in
// game/scripts/world/street_furniture_kit.gd), so the drawn skirt always meets
// the ground at the most float this allows (the validator's limit too).
export const STREET_FURNITURE_PADS = Object.freeze(["bus_shelter", "ev_charger_bay", "transformer_pad"]);
export const PAD_SKIRT_M = 0.3;
// The ground is sampled at the pad's corners and this many points along each side.
const PAD_SIDE_SAMPLES = 4;
// A junction's through street: two arms of the same name at least this far
// apart (radians), or failing that the straightest pair at least STRAIGHT_PAIR_RAD apart.
const SAME_STREET_PAIR_RAD = (110 * Math.PI) / 180;
const STRAIGHT_PAIR_RAD = (150 * Math.PI) / 180;
// A road class's rank for choosing a junction's major street.
const ROAD_RANK = Object.freeze({ tertiary: 2, unclassified: 1, residential: 1, track: 0, service: 0 });
// A second crossarm turns with a line that leaves a pole more than this far off
// the pole's own line (radians, either way along it).
const SECOND_ARM_RAD = (25 * Math.PI) / 180;
// A street corner's signal mast serves every crosswalk landing within this (m).
const MAST_CORNER_M = 9;
// A signal mast drops its pole-top luminaire where a utility pole within this
// (m) already carries a street light (pole_lights): one lamp per corner.
const MAST_LIT_POLE_M = 8;
// A signal mast's arm reaches MAST_ARM_PAST_M past the centre line of the road
// it spans, between these lengths (m), with two heads over the lanes from an
// arm of MAST_TWO_HEADS_M and three from MAST_THREE_HEADS_M; a junction within
// SIGNAL_NAMES_M of a mast takes its street names from the masts' arm signs,
// not from a name post.
const MAST_ARM_MIN_M = 3;
const MAST_ARM_MAX_M = 11;
const MAST_ARM_PAST_M = 1;
const MAST_TWO_HEADS_M = 4;
const MAST_THREE_HEADS_M = 8.5;
const SIGNAL_NAMES_M = 25;
// A name post keeps this far (m) from a junction's stop signs: the dated photos
// show the stop posts bare except where on_stops lists them.
const NAME_POST_STOP_CLEAR_M = 6;
// How far (m) from an on_lamps entry's near_xz the lamp carrying its names may stand.
const NAME_LAMP_REACH_M = 5;
// A junction-anchored lamp (street_lamps anchor "junctions") stands this far (m)
// past the crossing street's curb, and keeps only this far (m) from another
// lamp: the cross street's own lamps stand near the same corner (the dated
// photos show a davit at each of Halibut Court's and 12th Street's corners on
// Avenue B), so a corner lamp yields only to one at its own corner.
const LAMP_CORNER_M = 1.5;
const LAMP_CORNER_CLEAR_M = 8;
// The longest spur (m) a photographed pole's wires may run to a pole it names
// (params.wires_to): about one ordinary span.
export const MAX_SPUR_M = 60;
// The share of utility poles with a darker creosote shaft (prop_params.wood
// "dark", chosen by a hash of the row id); the rest are weathered grey. The dated
// photos show both, weathered poles far more often (production inference).
const DARK_POLE_SHARE = 0.2;
const darkPole = (id) => createHash("sha256").update(`pole_wood|${id}`, "utf8").digest().readUInt32BE(0) / 0xffffffff < DARK_POLE_SHARE;
const SAFE_ID = /^[a-z0-9_]+$/u;
// Fields a rule may leave out: photographed exceptions.
const OPTIONAL_RULE_FIELDS = Object.freeze({ street_lamps: ["except_cells"], junction_names: ["on_posts"] });
const RULE_FIELDS = Object.freeze({
  kerb: ["source_keys", "sides", "spacing_m", "phase_m", "setback_m", "slide_m"],
  signalized_crossings: ["setback_m", "beyond_m"],
  near_signals: ["back_m", "along_m"],
  junctions: ["setback_m"],
  all_way_stops: ["clear_m"],
  drive_entries: ["clear_m"],
  lot_edge: ["source_keys", "spacing_m", "phase_m", "setback_m", "slide_m"],
  pole_fixtures: ["max_gap_m", "min_spacing_m", "except_streets"],
  street_lamps: ["streets", "sides", "spacing_m", "phase_m", "setback_m", "slide_m", "anchor"],
  junction_stops: ["clear_m", "except"],
  junction_names: ["setback_m", "on_stops", "on_lamps"],
  hydrant_style: ["streets"],
});
const COMMON_FIELDS = Object.freeze(["basis", "evidence", "id", "kind", "params", "pattern", "prop", "rule"]);

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

const sub = (a, b) => [a[0] - b[0], a[1] - b[1]];
const add = (a, b) => [a[0] + b[0], a[1] + b[1]];
const scale = (a, s) => [a[0] * s, a[1] * s];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1];
const cross = (a, b) => a[0] * b[1] - a[1] * b[0];
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

// Whether the segments ab and cd cross (touching ends do not count).
function segmentsCross(a, b, c, d) {
  const d1 = cross(sub(d, c), sub(a, c));
  const d2 = cross(sub(d, c), sub(b, c));
  const d3 = cross(sub(b, a), sub(c, a));
  const d4 = cross(sub(b, a), sub(d, a));
  return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
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

// The rules of a zone, or with island the rules of the island-wide block.
export function validateFurnitureRules(zone, kinds, island = false) {
  if (zone.furniture == null) return;
  invariant(Array.isArray(zone.furniture), `Street detail zone ${zone.id} furniture must be a list`);
  const ids = new Set();
  for (const rule of zone.furniture) {
    const label = `Street detail zone ${zone.id} furniture rule ${rule?.id}`;
    invariant(typeof rule?.id === "string" && SAFE_ID.test(rule.id) && !ids.has(rule.id), `${label} needs a unique lower_snake id`);
    ids.add(rule.id);
    const patterns = island ? ISLAND_PATTERNS : ZONE_PATTERNS;
    invariant(patterns.includes(rule.pattern), `${label} pattern must be one of ${patterns.join(", ")}`);
    const allowed = [...COMMON_FIELDS, ...RULE_FIELDS[rule.pattern], ...(OPTIONAL_RULE_FIELDS[rule.pattern] ?? [])].sort();
    const present = Object.keys(rule).sort();
    invariant(present.every((key) => allowed.includes(key)), `${label} has fields outside ${allowed.join(", ")}`);
    invariant(RULE_FIELDS[rule.pattern].every((key) => key in rule), `${label} needs ${RULE_FIELDS[rule.pattern].join(", ")}`);
    invariant(STREET_FURNITURE_PROPS[rule.prop] === rule.kind && kinds[rule.kind]?.layer === "furniture", `${label}: prop ${rule.prop} does not build kind ${rule.kind} in the furniture layer`);
    invariant(rule.basis === "production_inference", `${label}: rule-based furniture is production_inference`);
    for (const field of ["rule", "evidence"]) invariant(typeof rule[field] === "string" && rule[field].trim() !== "", `${label} needs ${field}`);
    invariant(rule.params != null && typeof rule.params === "object" && !Array.isArray(rule.params), `${label} params must be an object`);
    for (const field of ["spacing_m", "setback_m", "beyond_m", "back_m", "max_gap_m", "min_spacing_m"]) {
      if (field in rule) invariant(isFiniteNumber(rule[field]) && rule[field] > 0, `${label} ${field} must be positive`);
    }
    for (const field of ["phase_m", "slide_m", "along_m", "clear_m"]) {
      if (field in rule) invariant(isFiniteNumber(rule[field]) && rule[field] >= 0, `${label} ${field} must be non-negative`);
    }
    if ("source_keys" in rule) invariant(Array.isArray(rule.source_keys) && rule.source_keys.length > 0 && rule.source_keys.every((key) => /^w\d+$/u.test(key)), `${label} needs OSM way source_keys`);
    if ("sides" in rule) invariant(Array.isArray(rule.sides) && rule.sides.length > 0 && rule.sides.every((side) => ["left", "right"].includes(side)), `${label} sides are left and/or right`);
    if ("streets" in rule) invariant(Array.isArray(rule.streets) && rule.streets.length > 0 && rule.streets.every((name) => typeof name === "string" && name.trim() !== ""), `${label} streets are OSM street names`);
    if ("except_streets" in rule) invariant(Array.isArray(rule.except_streets) && rule.except_streets.every((name) => typeof name === "string" && name.trim() !== ""), `${label} except_streets are OSM street names`);
    if ("anchor" in rule) invariant(["start", "junctions"].includes(rule.anchor), `${label} anchor is "start" (from phase_m) or "junctions"`);
    if ("on_lamps" in rule) {
      // Junctions whose names the dated photos show on a street lamp's pole:
      // the lamp nearest near_xz (world x, z) within NAME_LAMP_REACH_M carries them.
      invariant(Array.isArray(rule.on_lamps), `${label} on_lamps must be a list`);
      for (const entry of rule.on_lamps) {
        invariant(JSON.stringify(Object.keys(entry ?? {}).sort()) === JSON.stringify(["evidence", "near_xz", "node"]) && /^n\d+$/u.test(entry.node)
          && Array.isArray(entry.near_xz) && entry.near_xz.length === 2 && entry.near_xz.every(isFiniteNumber)
          && typeof entry.evidence === "string" && entry.evidence.trim() !== "", `${label} on_lamps entries are {node: "n<node>", near_xz: [x, z], evidence}`);
      }
    }
    if ("except_cells" in rule) {
      // Stations of a lamp rule the dated photos show empty, by their rule cell
      // (<way>_<side>_<station>), each with its evidence.
      invariant(Array.isArray(rule.except_cells), `${label} except_cells must be a list`);
      for (const entry of rule.except_cells) {
        invariant(JSON.stringify(Object.keys(entry ?? {}).sort()) === JSON.stringify(["cell", "evidence"]) && /^w\d+_(left|right)_\d{3}$/u.test(entry.cell)
          && typeof entry.evidence === "string" && entry.evidence.trim() !== "", `${label} except_cells entries are {cell: "w<way>_<side>_<station>", evidence}`);
      }
    }
    if ("on_posts" in rule) {
      // Junctions whose own name post the dated photos show at a known corner:
      // the post stands at near_xz (world x, z), or the first clear spot beside it.
      invariant(Array.isArray(rule.on_posts), `${label} on_posts must be a list`);
      for (const entry of rule.on_posts) {
        invariant(JSON.stringify(Object.keys(entry ?? {}).sort()) === JSON.stringify(["evidence", "near_xz", "node"]) && /^n\d+$/u.test(entry.node)
          && Array.isArray(entry.near_xz) && entry.near_xz.length === 2 && entry.near_xz.every(isFiniteNumber)
          && typeof entry.evidence === "string" && entry.evidence.trim() !== "", `${label} on_posts entries are {node: "n<node>", near_xz: [x, z], evidence}`);
      }
    }
    if ("on_stops" in rule) {
      // The stop signs the dated photos show carrying name blades, by their rule
      // cell (n<junction>_w<approach way>_<a|b>), each with its evidence.
      invariant(Array.isArray(rule.on_stops), `${label} on_stops must be a list`);
      for (const entry of rule.on_stops) {
        invariant(JSON.stringify(Object.keys(entry ?? {}).sort()) === JSON.stringify(["evidence", "stop"]) && /^n\d+_w\d+_[ab]$/u.test(entry.stop)
          && typeof entry.evidence === "string" && entry.evidence.trim() !== "", `${label} on_stops entries are {stop: "n<node>_w<way>_<a|b>", evidence}`);
      }
    }
    if ("except" in rule) {
      // Photographed junctions where the rule does not hold: the approaches (by
      // OSM street name) at the node that keep no stop sign, and why.
      invariant(Array.isArray(rule.except), `${label} except must be a list`);
      for (const entry of rule.except) {
        invariant(JSON.stringify(Object.keys(entry ?? {}).sort()) === JSON.stringify(["approaches", "evidence", "node", "reason"]), `${label} except entries are {node, approaches, reason, evidence}`);
        invariant(/^n\d+$/u.test(entry.node) && Array.isArray(entry.approaches) && entry.approaches.length > 0 && entry.approaches.every((name) => typeof name === "string" && name !== ""), `${label} except ${entry.node} needs an OSM node and approach street names`);
        for (const field of ["reason", "evidence"]) invariant(typeof entry[field] === "string" && entry[field].trim() !== "", `${label} except ${entry.node} needs ${field}`);
      }
    }
  }
}

// The island-wide block: {notes, rules} with the island patterns.
export function validateIslandFurniture(island, kinds) {
  invariant(island != null && typeof island === "object" && !Array.isArray(island), "Street detail island_furniture must be an object");
  invariant(JSON.stringify(Object.keys(island).sort()) === JSON.stringify(["notes", "rules", "shelter_anchors"]), "Street detail island_furniture must define exactly notes, rules and shelter_anchors");
  invariant(Array.isArray(island.notes) && island.notes.every((note) => typeof note === "string"), "Street detail island_furniture needs notes");
  invariant(Array.isArray(island.rules), "Street detail island_furniture rules must be a list");
  validateFurnitureRules({ id: "island", furniture: island.rules }, kinds, true);
  // Shelters a dated photo places: the OSM stop's shelter is tried first along_m
  // along the road from the node and gap_m past the curb.
  for (const [key, anchor] of Object.entries(island.shelter_anchors ?? {})) {
    invariant(/^osm:n\d+$/u.test(key) && JSON.stringify(Object.keys(anchor ?? {}).sort()) === JSON.stringify(["along_m", "evidence", "gap_m"]) && isFiniteNumber(anchor.along_m)
      && isFiniteNumber(anchor.gap_m) && anchor.gap_m > 0 && typeof anchor.evidence === "string" && anchor.evidence.trim() !== "", `Street detail shelter anchor ${key} is {along_m, gap_m, evidence}`);
  }
}

// Resolves the street furniture. Mutates the OSM rows it gives props (moves
// stop signs and the items it steps off the carriageway, gives the utility poles
// their crossarms and lamps and the power lines their wires); returns the new
// rule rows and an audit.
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
  island,
  islandRoads,
  carriagewayDistance,
  pieceViolation,
  groundAt,
  pathDistance,
  // street-clutter-generation.mjs's footprint stadium, passed in: importing it
  // here would close an import cycle (it reaches this module through the yard kit).
  footprintPiece,
}) {
  const pilotShapes = zoneShapes.filter(({ zone }) => zone.pilot);
  const inPilot = (xz) => pilotShapes.some(({ contains }) => contains(xz));
  const audit = {
    osm_props: 0,
    osm_unbuilt: [],
    racks_as_one_hoop: [],
    stops_moved: 0,
    stepped_off: 0,
    shelters: 0,
    shelter_fallbacks: [],
    pads_off_paths: 0,
    pole_lamps: 0,
    second_arms: 0,
    wire_spans: 0,
    blades_on_stops: 0,
    rules: {},
    rejected_by_reason: {},
  };
  const count = (table, key) => {
    table[key] = (table[key] ?? 0) + 1;
  };

  // The furniture site check: gameplay mask, walls, kerb and ramps, other items.
  // options.raised: must stand on the raised street ground; options.ignore: ids
  // whose footprints do not count (the row being moved); options.radius: the
  // item's radius when it is not its kind's.
  const reject = (kindName, xz, options = {}) => {
    const radius = options.radius ?? kinds[kindName].footprint_radius_m;
    if (!onLand(xz, exclusions.land_edge_buffer_m + radius)) return "land_edge";
    const hard = hardViolation(hardShapes, [xz], radius);
    if (hard) return hard.reason;
    const building = buildings.nearest(xz, exclusions.wall_buffer_m + radius);
    if (building.distance < exclusions.wall_buffer_m + radius) return building.distance === 0 ? "inside_building" : "wall_buffer";
    const en = toEastNorth(xz);
    if (carriagewayDistance(en) < KERB_CLEAR_M + radius) return "carriageway";
    if (site.rampDistance(en) < RAMP_CLEAR_M + radius) return "curb_ramp";
    if (options.raised && !site.raised(en)) return "off_sidewalk";
    if (!options.pad && offRest(xz)) return "off_rest";
    for (const item of occupied) {
      if (options.ignore?.has(item.id)) continue;
      // A line item (a fence run) counts by its segments, not only its vertices.
      const distance = item.points.length > 1 ? closestOnPolyline(item.points, xz).distance : Math.hypot(item.points[0][0] - xz[0], item.points[0][1] - xz[1]);
      if (distance < item.radius_m + radius + PLAYER_WIDTH_M) return "overlap";
    }
    return null;
  };
  const occupy = (id, kindName, xz) => occupied.push({ id, points: [xz], radius_m: kinds[kindName].footprint_radius_m });
  // A row's base at xz: the land plus the surface's bias.
  const baseAt = (xz) => grounded(xz).y + surfaceAt(xz).bias_m;
  const surfaceRow = (xz) => {
    const { y, support } = grounded(xz);
    return {
      position_m: [xz[0], y, xz[1]],
      terrain_support: { object_key: support.object_key, triangle_index: support.triangle_index, elevation_m: support.elevation_m },
      surface: surfaceAt(xz),
    };
  };
  const round2 = (en) => [roundCoordinate(en[0]), roundCoordinate(en[1])];
  // Moves a placed row (keeping its first OSM position as source_position_m)
  // and its claim in the shared mask: its footprint's stadium when it has one.
  const moveRow = (row, xz, placement) => {
    if (row.source === "osm" && row.source_position_m === undefined) row.source_position_m = [...row.position_m];
    Object.assign(row, surfaceRow(xz));
    row.placement = placement;
    const index = occupied.findIndex((item) => item.id === row.id);
    if (index >= 0) occupied.splice(index, 1);
    if (row.footprint_m) {
      const piece = footprintPiece(xz, row.yaw_radians ?? 0, row.footprint_m);
      occupied.push({ id: row.id, points: piece.points, radius_m: piece.radius });
    } else {
      occupy(row.id, row.kind, xz);
    }
  };

  // --- The island's roads: lines in the east/north frame, their edge offsets.
  const kerbLines = islandRoads;
  const nodePoint = (ref) => {
    const node = rawOsm.nodes.get(ref);
    invariant(node, `Street furniture needs OSM node n${ref}, which the raw extract lacks`);
    return projectLonLat(node.coordinate);
  };
  // The road whose edge is nearest an east/north point, among those filter
  // keeps: {road, near, gap} (gap: from the edge, negative inside the ribbon).
  const nearestRoad = (en, filter = () => true) => {
    let best = null;
    for (const road of kerbLines) {
      if (!filter(road)) continue;
      const near = closestOnPolyline(road.line, en);
      if (!near) continue;
      const gap = near.distance - road.kerb_offset_m;
      if (!best || gap < best.gap) best = { road, near, gap };
    }
    return best;
  };
  // Nodes where two roads meet.
  const meetings = new Map();
  for (const road of kerbLines) {
    for (const ref of new Set(road.refs)) meetings.set(ref, [...(meetings.get(ref) ?? []), road]);
  }
  const junctionPoints = [...meetings.entries()].filter(([, roads]) => roads.length > 1)
    .map(([ref]) => ({ ref, point: nodePoint(ref) }));

  // Marked crossings beyond the street ground, from the OSM crossing nodes on a
  // vehicle road: a walk across that road at the node, as wide as its ribbon,
  // signalized when the node says so. The street ground's own walks win where
  // one lies within 6 m.
  const derivedWalks = [];
  for (const row of rows.filter((candidate) => candidate.source === "osm" && candidate.kind === "crossing" && candidate.status === "placed")) {
    const tags = row.tags ?? {};
    if (tags["crossing:markings"] === "no" || tags.crossing === "unmarked") continue;
    const ref = row.source_id.slice(1);
    const host = kerbLines.find((road) => road.refs.includes(ref));
    if (!host) continue;
    const near = closestOnPolyline(host.line, nodePoint(ref));
    if (site.crosswalks.some((walk) => length(sub(walk.center, near.point)) < 6)) continue;
    const direction = leftOf(near.tangent);
    derivedWalks.push({
      source_key: row.source_id,
      host_key: host.source_key,
      center: near.point,
      direction,
      across: leftOf(direction),
      span: [-host.kerb_offset_m, host.kerb_offset_m],
      signals: tags.crossing === "traffic_signals" || tags["crossing:signals"] === "yes",
      width_m: site.walk_width_m,
    });
  }
  const allWalks = [...site.crosswalks, ...derivedWalks];

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
  // crossing street's curb and upstream of any crosswalk across the arm within
  // the stop line's reach, as the dated photos show at 9th/Avenue B and at
  // 13th/Gateview: the sign a step before the crosswalk. A crossing further up
  // the street is its own (Avenue B's, 20 m from Gateview): the sign stays at
  // the corner with the painted bar. Distances run along the road, so a walk
  // on another stretch of a looping way (Bayside Drive) is not this arm's.
  const armClearance = (center, road, outward, crossKerb, clear, walks = site.crosswalks) => {
    const at = closestOnPolyline(road.line, center);
    const sign = dot(at.tangent, outward) >= 0 ? 1 : -1;
    let distance = crossKerb + clear;
    for (const walk of walks) {
      const near = closestOnPolyline(road.line, walk.center);
      const along = sign * (near.along - at.along);
      if (near.distance > 2 || along <= 0 || along > STOP_WALK_REACH_M) continue;
      distance = Math.max(distance, along + walk.width_m / 2 + clear);
    }
    return distance;
  };
  // The first clear spot on the right-hand curb of traffic moving along travel,
  // stepping along the road from base, upstream (step -1) or downstream (step 1);
  // then, where the curb that way has no room (a parking bay, a container wall),
  // up to back metres the other way: the dated photos at 1440 Gateview Court and
  // Bayside/Gateview show the sign level with the crosswalk.
  const stopPosition = (id, road, base, travel, step = -1, back = 0) => {
    const at = closestOnPolyline(road.line, base);
    const direction = dot(at.tangent, travel) >= 0 ? 1 : -1;
    const reach = direction > 0 ? road.kerb_offset_right_m : road.kerb_offset_left_m;
    const total = polylineLength(road.line);
    const shifts = [...STOP_SIGN.upstream_m.map((distance) => step * distance),
      ...STOP_SIGN.upstream_m.filter((distance) => distance <= back).map((distance) => -step * distance)];
    for (const shift of shifts) {
      const station = at.along + direction * shift;
      const along = pointAlong(road.line, station);
      // Past a way's end the curb runs on straight.
      const foot = add(along.point, scale(along.tangent, station < 0 ? station : Math.max(0, station - total)));
      const xz = toWorld(add(foot, scale(leftOf(along.tangent), -direction * (reach + STOP_SIGN.setback_m))));
      const problem = reject("stop_sign", xz, { ignore: new Set([id]) });
      if (!problem) return round2(xz);
      count(audit.rejected_by_reason, `stop_sign:${problem}`);
    }
    return null;
  };
  // An OSM item mapped on (or at the edge of) the frozen carriageway, whose
  // ribbon is a generator width and not the surveyed curb, steps out across the
  // nearest road edge to the first clear spot on its own side. False when it
  // stands clear already or has moved; true when no spot was clear.
  const stepOffCarriageway = (row, radius) => {
    const en = toEastNorth([row.position_m[0], row.position_m[2]]);
    if (carriagewayDistance(en) >= KERB_CLEAR_M + radius) return false;
    const best = nearestRoad(en);
    if (best) {
      const away = best.near.distance > 1e-6 ? unit(sub(en, best.near.point)) : leftOf(best.near.tangent);
      for (const slide of STEP_OFF_SLIDES_M) {
        const foot = pointAlong(best.road.line, best.near.along + slide).point;
        for (const extra of STEP_OFF_EXTRA_M) {
          const xz = round2(toWorld(add(foot, scale(away, best.road.kerb_offset_m + KERB_CLEAR_M + radius + extra))));
          const problem = reject(row.kind, xz, { ignore: new Set([row.id]), radius, pad: row.footprint_m !== undefined });
          if (problem) {
            count(audit.rejected_by_reason, `step_off:${row.kind}:${problem}`);
            continue;
          }
          moveRow(row, xz, `stepped off the frozen carriageway of ${best.road.source_key} to its edge (production_inference)`);
          audit.stepped_off += 1;
          return false;
        }
      }
    }
    return true;
  };
  // Whether a post at xz has its base further from the visible ground than the
  // props' rest limit.
  const offRest = (xz) => {
    const visible = groundAt?.(xz) ?? null;
    return visible !== null && Math.abs(baseAt(xz) - visible.y) > PROP_REST_M;
  };
  // A post that does not rest moves to the nearest clear spot that does, in
  // rings round it. False when it rests already or has moved; true when no spot does.
  const stepOffSlope = (row) => {
    const at = [row.position_m[0], row.position_m[2]];
    if (!offRest(at)) return false;
    for (const radius of ISLAND_NUDGES_M) {
      for (let step = 0; step < 16; step += 1) {
        const angle = (step * Math.PI) / 8;
        const xz = round2([at[0] + radius * Math.cos(angle), at[1] + radius * Math.sin(angle)]);
        if (reject(row.kind, xz, { ignore: new Set([row.id]) }) || offRest(xz)) continue;
        moveRow(row, xz, "moved off the sloped back of a verge to level ground (production_inference)");
        return false;
      }
    }
    return true;
  };
  // A bus shelter beside its street: its open front toward the road, its whole
  // footprint off the carriageway, the mask and every other item; the first
  // clear spot from the OSM node outward and along the road. True when placed.
  const placeShelter = (row) => {
    const en = toEastNorth([row.position_m[0], row.position_m[2]]);
    const best = nearestRoad(en, (road) => road.service == null);
    const reasons = {};
    const fail = () => {
      audit.shelter_fallbacks.push({ id: row.id, reasons: best && best.gap <= 25 ? reasons : { no_road_within_25_m: 1 } });
      return false;
    };
    if (!best || best.gap > 25) return fail();
    const side = cross(best.near.tangent, sub(en, best.near.point)) >= 0 ? 1 : -1;
    const footprint = STREET_FURNITURE_FOOTPRINTS.bus_shelter;
    const anchor = island?.shelter_anchors?.[row.id];
    const spots = [...(anchor ? [[anchor.along_m, anchor.gap_m]] : []), ...SHELTER_SLIDES_M.flatMap((slide) => SHELTER_GAPS_M.map((gap) => [slide, gap]))];
    for (const [slide, gap] of spots) {
      const at = best.near.along + slide;
      if (at < 0 || at > polylineLength(best.road.line)) continue;
      const along = pointAlong(best.road.line, at);
      const away = scale(leftOf(along.tangent), side);
      const xz = round2(toWorld(add(along.point, scale(away, best.road.kerb_offset_m + gap + footprint.z_m / 2))));
      const yaw = yawToward(scale(away, -1));
      const violation = pieceViolation(footprintPiece(xz, yaw, footprint), new Set([row.id]));
      if (violation) {
        count(audit.rejected_by_reason, `bus_shelter:${violation.reason}`);
        count(reasons, violation.source_id ? `${violation.reason}:${violation.source_id}` : violation.reason);
        continue;
      }
      const pad = settlePad(footprint, xz, yaw, groundAt, baseAt(xz));
      if (pad.problem) {
        count(audit.rejected_by_reason, `bus_shelter:${pad.problem}`);
        count(reasons, pad.problem);
        continue;
      }
      row.yaw_radians = yaw;
      row.yaw_source = `faces_road:${best.road.source_key}`;
      row.footprint_m = { ...footprint };
      row.pad_lift = pad.lift;
      moveRow(row, xz, `shelter beside ${best.road.source_key}, its open front to the road (production_inference)`);
      audit.shelters += 1;
      return true;
    }
    return fail();
  };

  // --- OSM rows: props, stop signs moved to their curbs, items off the carriageway.
  const stopBar = new Map(site.stop_bars.map((bar) => [bar.node_key, bar]));
  const candidates = rows.filter((row) => row.source === "osm" && row.geometry === "point" && row.status === "placed" &&
    kinds[row.kind].layer === "furniture" && (ISLAND_STREET_OBJECT_KINDS.includes(row.kind) || ISLAND_FURNITURE_KINDS.includes(row.kind) || inPilot([row.position_m[0], row.position_m[2]])));
  // Stops with a painted bar first: a stop node beside the road then joins the
  // sign already on its approach rather than doubling it.
  candidates.sort((left, right) => (left.kind === "stop_sign" && !stopBar.has(left.source_id)) - (right.kind === "stop_sign" && !stopBar.has(right.source_id)));
  for (const row of candidates) {
    const at = [row.position_m[0], row.position_m[2]];
    let choice = OSM_PROPS[row.kind]?.(row.tags ?? {});
    if (!choice) {
      audit.osm_unbuilt.push({ id: row.id, kind: row.kind });
      continue;
    }
    // Ground drawn off the surface's height at a spot (a verge's sloped back).
    const offLevel = (xz) => {
      const visible = groundAt?.(xz) ?? null;
      return visible !== null && Math.abs(visible.y - (grounded(xz).y + surfaceAt(xz).bias_m)) > ISLAND_LEVEL_M;
    };
    const onRoad = ISLAND_FURNITURE_KINDS.includes(row.kind) && surfaceAt(at).kind === "road_path";
    const sloped = ISLAND_FURNITURE_KINDS.includes(row.kind) && !onRoad && offLevel(at);
    if (onRoad || sloped) {
      // The nearest clear, level spot off the road or path, in rings round the node.
      let moved = null;
      for (const radius of ISLAND_NUDGES_M) {
        for (let step = 0; step < 16 && !moved; step += 1) {
          const angle = (step * Math.PI) / 8;
          const xz = round2([at[0] + radius * Math.cos(angle), at[1] + radius * Math.sin(angle)]);
          if (surfaceAt(xz).kind !== "road_path" && !reject(row.kind, xz, { ignore: new Set([row.id]) }) && !offLevel(xz)) moved = xz;
        }
        if (moved) break;
      }
      const why = onRoad ? "on a road or path" : "on sloped ground";
      if (!moved) {
        audit.osm_unbuilt.push({ id: row.id, kind: row.kind, reason: `${why} with no clear spot beside it` });
        continue;
      }
      row.source_position_m = [...row.position_m];
      Object.assign(row, surfaceRow(moved));
      row.placement = `moved beside the spot its OSM node lies on, ${why} (production_inference)`;
      const index = occupied.findIndex((item) => item.id === row.id);
      if (index >= 0) occupied.splice(index, 1);
      occupy(row.id, row.kind, moved);
    }
    if (row.kind === "stop_sign") {
      // A painted bar gives the approach; a stop node beside the road marks the
      // approach of the nearest road toward its nearest junction.
      const bar = stopBar.get(row.source_id);
      let road;
      let base;
      let travel;
      let back = 0;
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
        invariant(best, `${row.id}: no road for a stop sign`);
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
        const crossKerb = Math.max(0, ...others.map((other) => other.kerb_offset_m));
        const needed = armClearance(ahead.point, road, outward, crossKerb, 1.0);
        const out = dot(sub(base, ahead.point), outward);
        if (out < needed) {
          base = add(base, scale(outward, needed - out));
          back = needed - crossKerb - 1.0;
        }
      }
      invariant(road, `${row.id}: stop bar road is not a vehicle road`);
      const junction = meetings.get(row.source_id.slice(1))?.length > 1 ? row.source_id.slice(1) : junctionAhead(road, base, travel)?.ref ?? null;
      const covering = coveredBy(junction, road.source_key, travel);
      if (covering) {
        audit.osm_unbuilt.push({ id: row.id, kind: row.kind, reason: `same approach as ${covering.id}` });
        continue;
      }
      const xz = stopPosition(row.id, road, base, travel, -1, back);
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
        : "right-hand curb of the nearest road's approach to its nearest junction (production_inference)";
      const index = occupied.findIndex((item) => item.id === row.id);
      if (index >= 0) occupied.splice(index, 1);
      occupy(row.id, row.kind, xz);
      stopSigns.push({ id: row.id, row, junction, road_key: road.source_key, travel });
      audit.stops_moved += 1;
    } else if (row.kind === "bus_stop") {
      // A shelter where OSM has one, else (or with no clear spot for it) the stop's flag.
      if (choice.prop === "bus_shelter" && !placeShelter(row)) {
        count(audit.rejected_by_reason, "bus_shelter:no_clear_spot");
        choice.prop = "bus_stop_sign";
      }
      if (choice.prop === "bus_stop_sign" && stepOffCarriageway(row, 0.3)) {
        audit.osm_unbuilt.push({ id: row.id, kind: row.kind, reason: "on the carriageway, no clear spot beside it" });
        continue;
      }
      if (choice.prop === "bus_stop_sign" && stepOffSlope(row)) {
        audit.osm_unbuilt.push({ id: row.id, kind: row.kind, reason: "on sloped ground with no level spot beside it" });
        continue;
      }
    } else if (ISLAND_STREET_OBJECT_KINDS.includes(row.kind)) {
      // A cabinet claims its whole box and pad.
      if (choice.prop === "transformer_pad") {
        // Doors toward the nearest road, however far it is (a footprint needs a yaw).
        if (row.yaw_radians === null) {
          const best = nearestRoad(toEastNorth(at));
          if (best && best.near.distance > 1e-6) {
            row.yaw_radians = yawToward(unit(sub(best.near.point, toEastNorth(at))));
            row.yaw_source = `faces_road:${best.road.source_key}`;
          } else {
            row.yaw_radians = 0;
            row.yaw_source = "default";
          }
        }
        row.footprint_m = { ...STREET_FURNITURE_FOOTPRINTS.transformer_pad };
        const index = occupied.findIndex((item) => item.id === row.id);
        if (index >= 0) occupied.splice(index, 1);
        const piece = footprintPiece(at, row.yaw_radians ?? 0, row.footprint_m);
        occupied.push({ id: row.id, points: piece.points, radius_m: piece.radius });
      }
      const radius = row.footprint_m ? footprintPiece(at, row.yaw_radians ?? 0, row.footprint_m).radius : kinds[row.kind].footprint_radius_m;
      if (stepOffCarriageway(row, radius)) {
        audit.osm_unbuilt.push({ id: row.id, kind: row.kind, reason: "on the carriageway, no clear spot beside it" });
        continue;
      }
      // A pole or lamp mapped on the sloped back of a verge would sink past the
      // props' rest limit: it moves to the nearest spot that rests.
      if (choice.prop !== "transformer_pad" && stepOffSlope(row)) {
        audit.osm_unbuilt.push({ id: row.id, kind: row.kind, reason: "on sloped ground with no level spot beside it" });
        continue;
      }
      // A cabinet's pad mapped on a paved path (an OSM footway) steps across it,
      // away from the road first, to the first spot clear of the path and of
      // everything else; it settles level on the ground under it.
      if (choice.prop === "transformer_pad") {
        const onPath = (xz) => {
          const piece = footprintPiece(xz, row.yaw_radians ?? 0, row.footprint_m);
          return piece.points.some((point) => pathDistance(toEastNorth(point), 4) < piece.radius + PAD_SKIRT_M);
        };
        if (onPath([row.position_m[0], row.position_m[2]])) {
          const en = toEastNorth([row.position_m[0], row.position_m[2]]);
          const best = nearestRoad(en);
          const away = best && best.near.distance > 1e-6 ? unit(sub(en, best.near.point)) : [-Math.sin(row.yaw_radians ?? 0), Math.cos(row.yaw_radians ?? 0)];
          let moved = false;
          for (const step of PAD_PATH_STEPS_M) {
            const xz = round2(toWorld(add(en, scale(away, step))));
            if (onPath(xz)) continue;
            const violation = pieceViolation(footprintPiece(xz, row.yaw_radians ?? 0, row.footprint_m), new Set([row.id]));
            if (violation || settlePad(row.footprint_m, xz, row.yaw_radians ?? 0, groundAt, baseAt(xz)).problem) continue;
            moveRow(row, xz, `stepped off the paved path beside ${best?.road.source_key ?? "its road"} (production_inference)`);
            audit.pads_off_paths += 1;
            moved = true;
            break;
          }
          if (!moved) count(audit.rejected_by_reason, "transformer_pad:on_path_no_clear_spot");
        }
        const pad = settlePad(row.footprint_m, [row.position_m[0], row.position_m[2]], row.yaw_radians ?? 0, groundAt, baseAt([row.position_m[0], row.position_m[2]]));
        if (pad.problem) {
          audit.osm_unbuilt.push({ id: row.id, kind: row.kind, reason: `its pad cannot rest level here (${pad.problem})` });
          continue;
        }
        choice.params = { ...choice.params, lift: pad.lift };
      }
    }
    if (row.kind === "bicycle_parking" && choice.params.hoops > 1) {
      // A row of hoops runs along the road, each hoop square to it: a quarter
      // turn from facing the road (the kit draws the row along its local Z).
      // Each hoop must pass the site check and stand on ground level with the
      // row's centre; a row that does not, or has no road to face, is one hoop.
      const { hoops } = choice.params;
      const xz = [row.position_m[0], row.position_m[2]];
      const turned = row.yaw_radians === null ? null : row.yaw_radians + Math.PI / 2;
      const yaw = turned === null ? null : roundCoordinate(Math.atan2(Math.sin(turned), Math.cos(turned)));
      // Godot yaw about +Y: local Z is (sin yaw, cos yaw) in world x, z.
      const hoopAt = (index) => round2([
        xz[0] + Math.sin(yaw) * BIKE_RACK_HOOP_SPACING_M * (index - (hoops - 1) / 2),
        xz[1] + Math.cos(yaw) * BIKE_RACK_HOOP_SPACING_M * (index - (hoops - 1) / 2),
      ]);
      // The row's base, and the ground each hoop's legs stand in (the visible
      // ground where the generator has it, else the surface).
      const centreY = grounded(xz).y + surfaceAt(xz).bias_m;
      const visibleY = (point) => groundAt?.(point)?.y ?? grounded(point).y + surfaceAt(point).bias_m;
      const ignore = new Set([row.id]);
      let problem = yaw === null ? "no road to face" : null;
      for (let index = 0; index < hoops && !problem; index += 1) {
        const point = hoopAt(index);
        problem = reject(row.kind, point, { ignore }) ?? (Math.abs(visibleY(point) - centreY) > BIKE_RACK_LEVEL_M ? "uneven ground" : null);
      }
      if (problem) {
        audit.racks_as_one_hoop.push({ id: row.id, hoops, reason: problem });
        choice = { prop: choice.prop, params: {} };
      } else {
        row.yaw_radians = yaw;
        row.yaw_source = `${row.yaw_source}+row_along_road`;
        row.footprint_m = streetFurnitureFootprint("bike_rack", choice.params);
        const index = occupied.findIndex((item) => item.id === row.id);
        if (index >= 0) occupied.splice(index, 1);
        occupied.push({ id: row.id, points: [hoopAt(0), hoopAt(hoops - 1)], radius_m: kinds[row.kind].footprint_radius_m });
      }
    }
    row.prop = choice.prop;
    row.prop_params = row.pad_lift === undefined ? choice.params : { ...choice.params, lift: row.pad_lift };
    if (row.prop === "utility_pole" && darkPole(row.id)) row.prop_params = { ...row.prop_params, wood: "dark" };
    delete row.pad_lift;
    audit.osm_props += 1;
  }

  // --- The utility poles: a second crossarm where another line turns off, or
  // where a line carries two circuits; the power lines' wires between built poles.
  const poleRows = new Map(rows.filter((row) => row.kind === "power_pole").map((row) => [row.id, row]));
  const builtPole = (row) => row !== undefined && row.status === "placed" && row.prop === "utility_pole";
  const powerLines = rows.filter((row) => row.source === "osm" && row.kind === "power_line" && row.status === "placed")
    .sort((left, right) => (left.id < right.id ? -1 : left.id > right.id ? 1 : 0));
  // Each pole's lines with their direction at it (east/north, along the line).
  const poleLines = new Map();
  for (const line of powerLines) {
    const points = line.points_m.map((point) => [point[0], -point[2]]);
    line.vertex_source_ids.forEach((id, index) => {
      const before = index > 0 ? unit(sub(points[index], points[index - 1])) : null;
      const after = index < points.length - 1 ? unit(sub(points[index + 1], points[index])) : null;
      const sum = before && after ? add(before, after) : before ?? after;
      const direction = length(sum) > 1e-6 ? unit(sum) : after ?? before;
      const key = `osm:${id}`;
      poleLines.set(key, [...(poleLines.get(key) ?? []), { line, direction, circuits: line.tags?.cables === "6" || line.tags?.circuits === "2" ? 2 : 1 }]);
    });
  }
  // A photographed pole whose wires OSM lacks (a utility_pole set piece with
  // params.wires_to) hangs a spur to each built pole it names; the far pole
  // turns a second crossarm toward a spur like toward any turned line.
  for (const pole of rows.filter((row) => row.source === "set_piece" && row.prop === "utility_pole" && row.prop_params?.wires_to !== undefined)) {
    const targets = pole.prop_params.wires_to;
    invariant(Array.isArray(targets) && targets.length > 0 && targets.every((id) => typeof id === "string" && id !== pole.id), `${pole.id} wires_to must list other poles' row ids`);
    const at = toEastNorth([pole.position_m[0], pole.position_m[2]]);
    for (const id of targets) {
      const target = poleRows.get(id);
      invariant(builtPole(target), `${pole.id} wires_to ${id}, which is not a built utility pole`);
      const from = toEastNorth([target.position_m[0], target.position_m[2]]);
      const span = length(sub(at, from));
      invariant(span >= 5 && span <= MAX_SPUR_M, `${pole.id} spur to ${id} is ${span.toFixed(1)} m long (5-${MAX_SPUR_M} m)`);
      poleLines.set(id, [...(poleLines.get(id) ?? []), { line: null, direction: unit(sub(at, from)), circuits: 1 }]);
      audit.wire_spans += 1;
    }
  }
  for (const [key, lines] of [...poleLines.entries()].sort(([left], [right]) => (left < right ? -1 : left > right ? 1 : 0))) {
    const pole = poleRows.get(key);
    if (!builtPole(pole)) continue;
    const yaw = pole.yaw_radians ?? 0;
    // The pole's own line runs along its front (-Z): (-sin yaw, cos yaw) east/north.
    const own = [-Math.sin(yaw), Math.cos(yaw)];
    const turned = lines.find((entry) => Math.acos(Math.min(1, Math.abs(dot(entry.direction, own)))) > SECOND_ARM_RAD);
    if (turned) {
      pole.prop_params = { ...pole.prop_params, arm2_yaw: relativeYaw(yawToward(turned.direction), yaw) };
    } else if (lines.some((entry) => entry.circuits === 2)) {
      pole.prop_params = { ...pole.prop_params, arm2_yaw: 0 };
    }
    if (pole.prop_params.arm2_yaw !== undefined) audit.second_arms += 1;
  }
  // A photographed pole OSM lacks (a utility_pole set piece naming its line as
  // params.line) joins that line where it stands along it. Each line's wires
  // run between consecutive built poles of its pole list (null where a vertex
  // has none), in order along the line.
  const insertedPoles = rows.filter((row) => row.source === "set_piece" && row.prop === "utility_pole" && typeof row.prop_params?.line === "string");
  for (const line of powerLines) {
    const points = line.points_m.map((point) => [point[0], -point[2]]);
    const stations = [];
    let walked = 0;
    line.vertex_source_ids.forEach((id, index) => {
      if (index > 0) walked += length(sub(points[index], points[index - 1]));
      stations.push({ along: walked, id: builtPole(poleRows.get(`osm:${id}`)) ? `osm:${id}` : null });
    });
    for (const pole of insertedPoles.filter((row) => row.prop_params.line === line.source_id)) {
      const near = closestOnPolyline(points, toEastNorth([pole.position_m[0], pole.position_m[2]]));
      invariant(near && near.distance < 5, `${pole.id} stands ${near?.distance.toFixed(2)} m off its line ${line.source_id}; a photographed pole must stand under it`);
      stations.push({ along: near.along, id: pole.id });
    }
    stations.sort((left, right) => left.along - right.along);
    let spans = 0;
    for (let index = 1; index < stations.length; index += 1) if (stations[index - 1].id && stations[index].id) spans += 1;
    if (spans === 0) continue;
    line.prop = "power_wires";
    line.prop_params = { circuits: line.tags?.cables === "6" || line.tags?.circuits === "2" ? 2 : 1, poles: stations.map((station) => station.id) };
    audit.wire_spans += spans;
  }

  // --- Rule rows.
  const ruleRows = [];
  const kerbByKey = new Map(kerbLines.map((road) => [road.source_key, road]));
  const addRow = (zone, rule, cell, en, front, params = {}, yawSource = `rule:${zone.id}/${rule.id}`) => {
    const xz = round2(toWorld(en));
    const row = {
      id: `scatter:${zone.id}:${rule.id}:${cell}`,
      source: "scatter",
      source_id: rule.source_id,
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
  // options.raisedAt(en): whether that candidate must stand on the street ground.
  // A lamp rule also counts the lamps on utility poles and, on the island, the
  // luminaires of signal masts, so a lit corner gets no extra lamp post.
  const litByOther = (rule, row) => rule.kind === "street_lamp" && ((row.prop === "utility_pole" && row.prop_params?.lamp)
    || (rule.source_id.startsWith("island:") && row.prop === "signal_mast" && row.prop_params?.lamp !== false));
  // A rule's own rows count too, except those of the same run (options.own, a
  // row id prefix: a street chain, both its sides), which its stations space.
  const sameKindNear = (rule, xz, distance, own = null) => [...rows, ...ruleRows].some((row) => (row.prop === rule.prop || litByOther(rule, row)) &&
    (row.source_id !== rule.source_id || (own !== null && !row.id.startsWith(own))) && row.status === "placed" && row.geometry === "point"
    && Math.hypot(row.position_m[0] - xz[0], row.position_m[2] - xz[1]) < distance);
  const firstClear = (rule, contains, candidates, options) => {
    for (const en of candidates) {
      const xz = toWorld(en);
      if (!contains(xz)) {
        count(audit.rejected_by_reason, `${rule.id}:outside_zone`);
        continue;
      }
      if (options.spacing_m && sameKindNear(rule, xz, options.spacing_m / 2, options.own ?? null)) {
        count(audit.rejected_by_reason, `${rule.id}:same_kind_near`);
        return null;
      }
      const problem = reject(rule.kind, xz, { ...options, raised: options.raisedAt ? options.raisedAt(en) : options.raised });
      if (!problem) return en;
      count(audit.rejected_by_reason, `${rule.id}:${problem}`);
    }
    return null;
  };
  // A crossing or junction shared by two zones (or a zone and the island) is furnished once.
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
      invariant(road, `Street furniture kerb rule names ${key}, which is not a vehicle road`);
      const line = road.line.map((point) => [...point]);
      const last = result.at(-1);
      if (last) {
        const end = last.line.at(-1);
        if (length(sub(end, line[0])) < 0.01) {
          last.line.push(...line.slice(1));
          last.roads.push(...line.slice(1).map(() => road));
          continue;
        }
        if (length(sub(end, line.at(-1))) < 0.01) {
          const reversed = line.reverse();
          last.line.push(...reversed.slice(1));
          last.roads.push(...reversed.slice(1).map(() => road));
          continue;
        }
      }
      result.push({ key, line, roads: line.map(() => road) });
    }
    return result;
  };
  // The ways of the named streets, chained end to end in a stable order: each
  // chain starts at the remaining way with the smallest key and grows at both
  // ends while another way of the same name shares an end node.
  const streetChains = (names) => {
    const ways = kerbLines.filter((road) => names.includes(road.name)).sort((left, right) => compareSourceKeys(left.source_key, right.source_key));
    const left = new Set(ways);
    const result = [];
    while (left.size > 0) {
      const first = [...left][0];
      left.delete(first);
      let refs = [...first.refs];
      let line = first.line.map((point) => [...point]);
      let roads = line.map(() => first);
      for (let grown = true; grown;) {
        grown = false;
        for (const road of [...left]) {
          if (road.name !== first.name) continue;
          const [a, b] = [road.refs[0], road.refs.at(-1)];
          const forward = road.line.map((point) => [...point]);
          if (a === refs.at(-1) || b === refs.at(-1)) {
            const part = a === refs.at(-1) ? forward : forward.reverse();
            const partRefs = a === refs.at(-1) ? road.refs : [...road.refs].reverse();
            line = [...line, ...part.slice(1)];
            refs = [...refs, ...partRefs.slice(1)];
            roads = [...roads, ...part.slice(1).map(() => road)];
          } else if (a === refs[0] || b === refs[0]) {
            const part = b === refs[0] ? forward : forward.reverse();
            const partRefs = b === refs[0] ? road.refs : [...road.refs].reverse();
            line = [...part.slice(0, -1), ...line];
            refs = [...partRefs.slice(0, -1), ...refs];
            roads = [...part.slice(0, -1).map(() => road), ...roads];
          } else {
            continue;
          }
          left.delete(road);
          grown = true;
        }
      }
      result.push({ key: first.source_key, name: first.name, line, refs, roads });
    }
    return result;
  };
  // Whether the street ground is built within 3 m of an east/north point (a
  // lamp beside a kerbed stretch must stand on it; elsewhere on the land).
  const groundBuiltNear = (en) => [0, 1, 2, 3, 4, 5, 6, 7].some((k) => [1.5, 3].some((r) =>
    site.raised(add(en, [r * Math.cos((k * Math.PI) / 4), r * Math.sin((k * Math.PI) / 4)]))));
  const offsetAt = (chain, s, side) => {
    // The curb offset on one side of the chain (1 left, -1 right) at the segment
    // that holds distance s; a chain can run against its ways.
    let walked = 0;
    let index = 1;
    for (; index < chain.line.length - 1; index += 1) {
      walked += length(sub(chain.line[index], chain.line[index - 1]));
      if (walked >= s) break;
    }
    const road = chain.roads[index];
    const segment = sub(chain.line[index], chain.line[index - 1]);
    const alongWay = dot(closestOnPolyline(road.line, add(chain.line[index - 1], scale(segment, 0.5))).tangent, segment) >= 0;
    return side > 0 === alongWay ? road.kerb_offset_left_m : road.kerb_offset_right_m;
  };
  const roadAt = (chain, s) => {
    let walked = 0;
    for (let index = 1; index < chain.line.length; index += 1) {
      walked += length(sub(chain.line[index], chain.line[index - 1]));
      if (walked >= s) return chain.roads[index];
    }
    return chain.roads.at(-1);
  };

  // Junctions of differently named roads, from the raw topology (the pilot's
  // rule: each road's arms, 8 m out along it).
  const junctions = () => {
    const use = new Map();
    for (const road of kerbLines) {
      if (road.name == null) continue;
      for (const ref of new Set(road.refs)) {
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
          arms.push({ road, direction: unit(sub(pointAlong(road.line, target).point, center)), sign });
        }
      }
      found.push({ ref, center, arms });
    }
    return found;
  };

  // A street-name assembly at the corner of a junction: the corner between two
  // streets first (widest first), the straight side of a T last. Returns the
  // row, or null when no corner is clear.
  const nameCorner = (zone, rule, contains, junction, avoid = [], nearXz = null) => {
    const arms = junction.arms.map((arm) => ({ ...arm, angle: Math.atan2(arm.direction[1], arm.direction[0]) })).sort((left, right) => left.angle - right.angle);
    if (nearXz) {
      // A photographed corner: the spot itself, else the first clear one in rings round it.
      const spots = [toEastNorth(nearXz), ...[0.5, 1, 1.5].flatMap((ring) => Array.from({ length: 8 }, (_, step) => add(toEastNorth(nearXz), [ring * Math.cos((step * Math.PI) / 4), ring * Math.sin((step * Math.PI) / 4)])))];
      const en = firstClear(rule, contains, spots, {});
      invariant(en, `Street furniture rule ${rule.id}: no clear spot near on_posts ${junction.ref}`);
      const front = unit(sub(junction.center, en));
      return addRow(zone, rule, `n${junction.ref}`, en, front, { blades: bladesFor(arms, yawToward(front)) });
    }
    const corners = arms.map((arm, index) => {
      const next = arms[(index + 1) % arms.length];
      let gap = next.angle - arm.angle;
      if (gap <= 0) gap += Math.PI * 2;
      const bisector = unit([Math.cos(arm.angle + gap / 2), Math.sin(arm.angle + gap / 2)]);
      const offset = Math.max(arm.road.kerb_offset_m, next.road.kerb_offset_m) + rule.setback_m;
      const radius = Math.min(14, offset / Math.max(0.2, Math.sin(Math.min(gap, Math.PI) / 2)));
      return { gap, bisector, point: add(junction.center, scale(bisector, radius)) };
    }).sort((left, right) => (left.gap >= STRAIGHT_CORNER_RAD) - (right.gap >= STRAIGHT_CORNER_RAD) || right.gap - left.gap)
      .filter((corner) => avoid.every((row) => length(sub(toEastNorth([row.position_m[0], row.position_m[2]]), corner.point)) >= NAME_POST_STOP_CLEAR_M));
    const en = firstClear(rule, contains, corners.map((corner) => corner.point), { raisedAt: groundBuiltNear });
    if (!en) return null;
    const front = unit(sub(junction.center, en));
    return addRow(zone, rule, `n${junction.ref}`, en, front, { blades: bladesFor(arms, yawToward(front)) });
  };
  // The two name blades of a junction's streets, each along its street,
  // relative to a post turned by yaw.
  const bladesFor = (arms, yaw) => {
    const names = [];
    for (const arm of arms) if (!names.some((entry) => entry.name === arm.road.name)) names.push({ name: arm.road.name, direction: arm.direction });
    return names.slice(0, 2).map((entry) => ({ text: abbreviateStreetName(entry.name), yaw: relativeYaw(yawAlong(entry.direction), yaw) }));
  };

  // Stop signs on the arms of `road` at junction `ref`, on the right-hand curb,
  // past the crossing roads' curbs and any crosswalk across the arm. They face
  // traffic approaching the junction, or with inbound traffic leaving it into
  // the arm (and stand downstream of that crosswalk).
  const signArms = (zone, rule, ref, center, road, crossing, inbound = false, walks = site.crosswalks) => {
    const total = polylineLength(road.line);
    const at = closestOnPolyline(road.line, center).along;
    for (const sign of [-1, 1]) {
      const room = sign > 0 ? total - at : at;
      if (room < 6) continue;
      const outward = unit(sub(pointAlong(road.line, at + sign * Math.min(8, room)).point, center));
      const travel = inbound ? outward : scale(outward, -1);
      if (!inbound && coveredBy(ref, road.source_key, travel)) continue;
      const crossKerb = Math.max(0, ...crossing.map((other) => other.kerb_offset_m));
      const cell = `n${ref}_${road.source_key}_${sign > 0 ? "b" : "a"}`;
      const clearance = armClearance(center, road, outward, crossKerb, rule.clear_m, walks);
      const base = add(center, scale(outward, clearance));
      const xz = stopPosition(`scatter:${zone.id}:${rule.id}:${cell}`, road, base, travel, inbound ? 1 : -1, clearance - crossKerb - rule.clear_m);
      if (!xz) {
        count(audit.rejected_by_reason, `${rule.id}:no_clear_curb`);
        continue;
      }
      const row = addRow(zone, rule, cell, toEastNorth(xz), scale(travel, -1), {}, `${inbound ? "inbound" : "approach"}:${road.source_key}`);
      if (!inbound) stopSigns.push({ id: row.id, row, junction: ref, road_key: road.source_key, travel });
    }
  };

  // The island's junctions of named streets for the junction rules: every
  // node of a named road that another named road shares, with an arm for each
  // direction a road leaves it (8 m out along it, at least 1 m), and the
  // distinct street names of its arms.
  const islandJunctions = (() => {
    const use = new Map();
    for (const road of kerbLines) {
      if (road.name == null) continue;
      for (const ref of new Set(road.refs)) use.set(ref, [...(use.get(ref) ?? []), road]);
    }
    const found = [];
    for (const [ref, roads] of [...use.entries()].sort(([left], [right]) => compareSourceKeys(`n${left}`, `n${right}`))) {
      if (roads.length < 2) continue;
      const center = nodePoint(ref);
      const arms = [];
      for (const road of roads) {
        road.refs.forEach((nodeRef, index) => {
          if (nodeRef !== ref) return;
          for (const sign of [-1, 1]) {
            let walked = 0;
            let target = null;
            for (let at = index + sign; at >= 0 && at < road.line.length; at += sign) {
              const step = length(sub(road.line[at], road.line[at - sign]));
              if (walked + step >= 8) {
                target = add(road.line[at - sign], scale(sub(road.line[at], road.line[at - sign]), (8 - walked) / step));
                break;
              }
              walked += step;
              target = road.line[at];
            }
            if (!target || length(sub(target, center)) < 1) continue;
            arms.push({ road, direction: unit(sub(target, center)), sign, index });
          }
        });
      }
      const names = [...new Set(arms.map((arm) => arm.road.name))];
      if (arms.length >= 3 && names.length >= 2) found.push({ ref, center, arms, names });
    }
    return found;
  })();
  const signalNodes = new Set(rows.filter((row) => row.source === "osm" && row.kind === "traffic_signals").map((row) => row.source_id.slice(1)));
  // The approaches of a junction that stop: the arms off its through street
  // (the pair of arms of one street name, else the straightest pair, of the
  // highest road class); at a crossroads of two streets of one class, every arm.
  const minorApproaches = (junction) => {
    const { arms } = junction;
    const rank = (arm) => ROAD_RANK[arm.road.highway] ?? 0;
    const pairs = [];
    for (let i = 0; i < arms.length; i += 1) {
      for (let j = i + 1; j < arms.length; j += 1) {
        const angle = Math.acos(Math.max(-1, Math.min(1, dot(arms[i].direction, arms[j].direction))));
        const same = arms[i].road.name === arms[j].road.name;
        if ((same && angle >= SAME_STREET_PAIR_RAD) || angle >= STRAIGHT_PAIR_RAD) pairs.push({ i, j, same, angle, rank: Math.min(rank(arms[i]), rank(arms[j])) });
      }
    }
    if (pairs.length === 0) return [];
    pairs.sort((left, right) => right.rank - left.rank || Number(right.same) - Number(left.same) || right.angle - left.angle || left.i - right.i || left.j - right.j);
    const through = pairs[0];
    const others = arms.map((arm, index) => ({ arm, index })).filter(({ index }) => index !== through.i && index !== through.j);
    if (others.length === 2) {
      const [a, b] = others;
      const angle = Math.acos(Math.max(-1, Math.min(1, dot(a.arm.direction, b.arm.direction))));
      const crossStreet = (a.arm.road.name === b.arm.road.name && angle >= SAME_STREET_PAIR_RAD) || angle >= STRAIGHT_PAIR_RAD;
      if (crossStreet && Math.min(rank(a.arm), rank(b.arm)) === through.rank) return { arms, allWay: true };
    }
    return { arms: others.map(({ arm }) => arm), allWay: false };
  };
  // A stop sign for the traffic approaching a junction along one arm.
  const signApproach = (zone, rule, junction, arm, allWay) => {
    const outward = arm.direction;
    const travel = scale(outward, -1);
    if (coveredBy(junction.ref, arm.road.source_key, travel)) return;
    const crossing = junction.arms.filter((other) => other.road !== arm.road).map((other) => other.road);
    const crossKerb = Math.max(0, ...crossing.map((road) => road.kerb_offset_m));
    // A way that passes the junction twice (a loop) names each pass by its node index.
    const passes = arm.road.refs.filter((ref) => ref === junction.ref).length;
    const cell = `n${junction.ref}_${arm.road.source_key}_${arm.sign > 0 ? "b" : "a"}${passes > 1 ? `_i${arm.index}` : ""}`;
    const id = `scatter:${zone.id}:${rule.id}:${cell}`;
    if (ruleRows.some((row) => row.id === id)) return;
    const clearance = armClearance(junction.center, arm.road, outward, crossKerb, rule.clear_m);
    const base = add(junction.center, scale(outward, clearance));
    const xz = stopPosition(id, arm.road, base, travel, -1, clearance - crossKerb - rule.clear_m);
    if (!xz) {
      count(audit.rejected_by_reason, `${rule.id}:no_clear_curb`);
      return;
    }
    const row = addRow(zone, rule, cell, toEastNorth(xz), scale(travel, -1), { all_way: allWay }, `approach:${arm.road.source_key}`);
    stopSigns.push({ id: row.id, row, junction: junction.ref, road_key: arm.road.source_key, travel });
  };

  // The stations of a junction-anchored lamp run (street_lamps anchor
  // "junctions"), as distances along a street chain: one LAMP_CORNER_M past the
  // crossing street's curb at each junction with another named street (on the
  // far side, or the near side at the chain's end), the dated photos' corner
  // lamps; then on from each corner lamp at the spacing (Avenue B's mid-block
  // davit stands two spacings past 12th Street's corner), stopping half a
  // spacing short of the next corner lamp, and out to the chain's ends.
  const junctionByRef = new Map(islandJunctions.map((junction) => [junction.ref, junction]));
  const junctionStations = (chain, spacing) => {
    const total = polylineLength(chain.line);
    const anchors = [];
    let walked = 0;
    chain.refs.forEach((ref, index) => {
      if (index > 0) walked += length(sub(chain.line[index], chain.line[index - 1]));
      const junction = junctionByRef.get(ref);
      if (!junction) return;
      const cross = Math.max(0, ...junction.arms.filter((arm) => arm.road.name !== chain.name).map((arm) => arm.road.kerb_offset_m));
      if (cross === 0) return;
      const past = cross + LAMP_CORNER_M;
      anchors.push(walked + past <= total ? walked + past : walked - past);
    });
    const marks = [...new Set(anchors.filter((s) => s >= 0 && s <= total).map((s) => Math.round(s * 10) / 10))].sort((left, right) => left - right);
    // {s, corner}: a corner station keeps LAMP_CORNER_CLEAR_M from other lamps.
    const stations = [];
    if (marks.length === 0) {
      for (let s = 0; s <= total; s += spacing) stations.push({ s, corner: false });
      return stations;
    }
    for (let s = marks[0] - spacing; s >= 0; s -= spacing) stations.push({ s, corner: false });
    marks.forEach((mark, index) => {
      stations.push({ s: mark, corner: true });
      const next = marks[index + 1] ?? total + spacing;
      for (let s = mark + spacing; s <= total && s <= next - spacing / 2; s += spacing) stations.push({ s, corner: false });
    });
    return stations.sort((left, right) => left.s - right.s);
  };

  const runRule = (zone, rule, contains) => {
    if (rule.pattern === "kerb") {
      for (const chain of chains(rule.source_keys)) {
        const total = polylineLength(chain.line);
        for (const sideName of rule.sides) {
          const side = sideName === "left" ? 1 : -1;
          for (let station = 0, s = rule.phase_m; s <= total; station += 1, s += rule.spacing_m) {
            const candidates = slides(rule.slide_m).filter((delta) => s + delta >= 0 && s + delta <= total).map((delta) => {
              const along = pointAlong(chain.line, s + delta);
              return add(along.point, scale(leftOf(along.tangent), side * (offsetAt(chain, s + delta, side) + rule.setback_m)));
            });
            const en = firstClear(rule, contains, candidates, { raised: true, spacing_m: rule.spacing_m });
            if (!en) continue;
            const near = closestOnPolyline(chain.line, en);
            addRow(zone, rule, `${chain.key}_${sideName}_${String(station).padStart(3, "0")}`, en, unit(sub(near.point, en)));
          }
        }
      }
    } else if (rule.pattern === "street_lamps") {
      // Lamps along the named streets, on the street ground where a zone builds
      // it, else beside the frozen road ribbon: from phase_m at a spacing, or
      // (anchor "junctions") at the street corners and evenly between them.
      // A station in except_cells stays empty, as its dated photo shows.
      const exceptCells = new Set((rule.except_cells ?? []).map((entry) => entry.cell));
      for (const chain of streetChains(rule.streets)) {
        const total = polylineLength(chain.line);
        const stations = rule.anchor === "junctions" ? junctionStations(chain, rule.spacing_m) : [];
        if (rule.anchor !== "junctions") for (let s = rule.phase_m; s <= total; s += rule.spacing_m) stations.push({ s, corner: false });
        for (const sideName of rule.sides) {
          const side = sideName === "left" ? 1 : -1;
          stations.forEach(({ s, corner }, station) => {
            const cell = `${chain.key}_${sideName}_${String(station).padStart(3, "0")}`;
            if (exceptCells.delete(cell)) {
              count(audit.rejected_by_reason, `${rule.id}:photographed_exception`);
              return;
            }
            const deltas = slides(rule.slide_m).filter((delta) => s + delta >= 0 && s + delta <= total);
            const candidates = deltas.map((delta) => {
              const along = pointAlong(chain.line, s + delta);
              return add(along.point, scale(leftOf(along.tangent), side * (offsetAt(chain, s + delta, side) + rule.setback_m)));
            });
            const own = `scatter:${zone.id}:${rule.id}:${chain.key}_`;
            const en = firstClear(rule, contains, candidates, { raisedAt: groundBuiltNear, spacing_m: corner ? 2 * LAMP_CORNER_CLEAR_M : rule.spacing_m, own });
            if (!en) return;
            const near = closestOnPolyline(chain.line, en);
            addRow(zone, rule, cell, en, unit(sub(near.point, en)));
          });
        }
      }
      invariant(exceptCells.size === 0, `Street furniture rule ${rule.id}: except_cells ${[...exceptCells].join(", ")} name no station`);
    } else if (rule.pattern === "pole_fixtures") {
      // Street lights on the utility poles beside a named street: a pole whose
      // centre stands within max_gap_m of the street's edge carries a lamp arm
      // reaching over it, unless a lit pole on the same side of that street stands
      // within min_spacing_m; streets in except_streets keep their poles unlit.
      const lit = [];
      const sameSide = (a, b, name) => kerbLines.filter((road) => road.name === name)
        .every((road) => road.line.every((point, index) => index === 0 || !segmentsCross(a, b, road.line[index - 1], point)));
      // OSM poles only: a photographed set-piece pole carries what its photo shows.
      const poles = [...poleRows.values()].filter((row) => row.source === "osm" && builtPole(row) && contains([row.position_m[0], row.position_m[2]]))
        .sort((left, right) => (left.id < right.id ? -1 : left.id > right.id ? 1 : 0));
      for (const pole of poles) {
        const at = toEastNorth([pole.position_m[0], pole.position_m[2]]);
        const best = nearestRoad(at, (road) => road.name != null);
        if (!best || best.gap < 0 || best.gap > rule.max_gap_m) continue;
        if (rule.except_streets.includes(best.road.name)) {
          count(audit.rejected_by_reason, `${rule.id}:except_street`);
          continue;
        }
        if (lit.some((entry) => entry.name === best.road.name && length(sub(entry.at, at)) < rule.min_spacing_m && sameSide(entry.at, at, entry.name))) {
          count(audit.rejected_by_reason, `${rule.id}:spacing`);
          continue;
        }
        const toward = unit(sub(best.near.point, at));
        // The arm reaches about half a metre past the road edge, at most arm_m,
        // in half-metre steps (so poles share their lamp meshes).
        const arm = Math.max(1.5, Math.min(rule.params.arm_m, Math.round((best.gap + 0.5) * 2) / 2));
        pole.prop_params = { ...pole.prop_params, lamp: { ...rule.params, arm_m: arm, yaw: relativeYaw(yawToward(toward), pole.yaw_radians ?? 0) } };
        pole.lamp_rule = rule.source_id;
        lit.push({ name: best.road.name, at });
        count(audit.rules, `${zone.id}/${rule.id}`);
        audit.pole_lamps += 1;
      }
    } else if (rule.pattern === "junction_stops") {
      // Stop signs on the minor approaches of every junction of named streets
      // that OSM leaves unsigned: the photographed exceptions keep none.
      const except = new Map(rule.except.map((entry) => [entry.node, entry]));
      for (const junction of islandJunctions) {
        if (!contains(toWorld(junction.center)) || signalNodes.has(junction.ref)) continue;
        if (!once(`junction_stops:${junction.ref}`)) continue;
        const minor = minorApproaches(junction);
        for (const arm of minor.arms ?? []) {
          if (arm.road.highway === "service") continue;
          if (except.get(`n${junction.ref}`)?.approaches.includes(arm.road.name)) {
            count(audit.rejected_by_reason, `${rule.id}:photographed_exception`);
            continue;
          }
          signApproach(zone, rule, junction, arm, minor.allWay);
        }
      }
    } else if (rule.pattern === "hydrant_style") {
      // The OSM hydrants whose nearest named street is one of the rule's streets
      // take its style (the kit's default is the ochre yellow of the Navy-era streets).
      for (const row of rows.filter((candidate) => candidate.source === "osm" && candidate.prop === "hydrant" && candidate.status === "placed")) {
        const best = nearestRoad(toEastNorth([row.position_m[0], row.position_m[2]]), (road) => road.name != null);
        if (!best || !rule.streets.includes(best.road.name) || !contains([row.position_m[0], row.position_m[2]])) continue;
        row.prop_params = { ...row.prop_params, ...rule.params };
        count(audit.rules, `${zone.id}/${rule.id}`);
      }
    } else if (rule.pattern === "junction_names") {
      // Name blades at each junction of named streets that no zone furnished and
      // no signal mast serves (the masts' arm signs carry its names): on the stop
      // post the dated photos show carrying them (on_stops), else on their own
      // post at a corner clear of the junction's stop signs, whose posts the
      // photos mostly show bare.
      const onStops = new Map(rule.on_stops.map((entry) => [entry.stop, false]));
      const onLamps = new Map(rule.on_lamps.map((entry) => [entry.node.slice(1), entry]));
      const onPosts = new Map((rule.on_posts ?? []).map((entry) => [entry.node.slice(1), entry]));
      for (const junction of islandJunctions) {
        if (!contains(toWorld(junction.center)) || !once(`junction:${junction.ref}`)) continue;
        const lampEntry = onLamps.get(junction.ref);
        if (lampEntry) {
          // The names ride on the photographed lamp's pole, at the blades' height.
          const lamp = [...rows, ...ruleRows].filter((row) => row.prop === "lamp_cobra" && row.status === "placed")
            .map((row) => ({ row, gap: Math.hypot(row.position_m[0] - lampEntry.near_xz[0], row.position_m[2] - lampEntry.near_xz[1]) }))
            .filter((entry) => entry.gap <= NAME_LAMP_REACH_M).sort((left, right) => left.gap - right.gap)[0]?.row;
          invariant(lamp, `Street furniture rule ${rule.id}: no street lamp within ${NAME_LAMP_REACH_M} m of on_lamps ${lampEntry.node} near_xz`);
          lamp.prop_params = { ...lamp.prop_params, blades: bladesFor(junction.arms, lamp.yaw_radians ?? 0) };
          onLamps.delete(junction.ref);
          count(audit.rules, `${zone.id}/${rule.id}`);
          continue;
        }
        if (ruleRows.some((row) => row.prop === "signal_mast" && length(sub(toEastNorth([row.position_m[0], row.position_m[2]]), junction.center)) < SIGNAL_NAMES_M)) {
          count(audit.rejected_by_reason, `${rule.id}:signal_mast_names`);
          continue;
        }
        const signs = stopSigns.filter((entry) => entry.junction === junction.ref && entry.row.prop === "stop_sign");
        const sign = signs.find((entry) => onStops.has(entry.id.split(":").at(-1)));
        if (sign) {
          onStops.set(sign.id.split(":").at(-1), true);
          sign.row.prop_params = { ...sign.row.prop_params, blades: bladesFor(junction.arms, sign.row.yaw_radians) };
          audit.blades_on_stops += 1;
          count(audit.rules, `${zone.id}/${rule.id}`);
          continue;
        }
        nameCorner(zone, rule, contains, junction, signs.map((entry) => entry.row), onPosts.get(junction.ref)?.near_xz ?? null);
        onPosts.delete(junction.ref);
      }
      invariant(onPosts.size === 0, `Street furniture rule ${rule.id}: on_posts ${[...onPosts.values()].map((entry) => entry.node).join(", ")} name no unfurnished junction`);
      const unused = [...onStops.entries()].filter(([, used]) => !used).map(([stop]) => stop);
      invariant(unused.length === 0, `Street furniture rule ${rule.id}: on_stops ${unused.join(", ")} name no rule stop sign at an unfurnished junction`);
      invariant(onLamps.size === 0, `Street furniture rule ${rule.id}: on_lamps ${[...onLamps.values()].map((entry) => entry.node).join(", ")} name no unfurnished junction`);
    } else if (rule.pattern === "signalized_crossings" || rule.pattern === "near_signals") {
      const walks = zone.id === "island" ? allWalks : site.crosswalks;
      for (const walk of walks.filter((candidate) => candidate.signals && contains(toWorld(candidate.center)))) {
        // One crossing way can cross several roads: each of its walks is its own.
        const sameWay = walks.filter((other) => other.source_key === walk.source_key);
        const cell = sameWay.length > 1 ? `${walk.source_key}_${sameWay.indexOf(walk)}` : walk.source_key;
        if (!once(`${rule.pattern}:${cell}`)) continue;
        // Each landing gets the far-side pole of the traffic that keeps that curb on its right.
        const landings = [[-1, walk.span[0]], [1, walk.span[1]]].map(([sign, s]) => {
          const outward = scale(walk.direction, sign);
          return { sign, s, outward, travel: leftOf(outward), landing: add(walk.center, scale(walk.direction, s)) };
        });
        if (rule.pattern === "signalized_crossings") {
          for (const landing of landings) {
            // One mast pole per street corner: on the island a landing whose corner
            // already has one (from a crossing of the other street) adds none.
            if (zone.id === "island" && ruleRows.some((row) => row.prop === rule.prop && length(sub(toEastNorth([row.position_m[0], row.position_m[2]]), landing.landing)) < MAST_CORNER_M)) {
              count(audit.rejected_by_reason, `${rule.id}:corner_has_mast`);
              continue;
            }
            const candidates = [0, 0.5, 1, 1.5, 2, 3, 4].map((extra) => add(add(landing.landing, scale(landing.outward, rule.setback_m)),
              scale(landing.travel, walk.width_m / 2 + rule.beyond_m + extra)));
            const en = firstClear(rule, contains, candidates, { raised: zone.id !== "island" });
            if (!en) continue;
            // The mast arm reaches over the lanes of the road the crosswalk
            // crosses, a metre past its centre line (the dated photos' long
            // arms over the lanes), with its heads spread along it and, at a
            // junction, a green sign naming the crossing street (the photos'
            // arm signs).
            const host = (walk.host_key ? kerbByKey.get(walk.host_key) : null) ?? kerbLines.map((road) => ({ road, gap: closestOnPolyline(road.line, walk.center).distance }))
              .sort((left, right) => left.gap - right.gap)[0]?.road ?? null;
            const reach = host ? closestOnPolyline(host.line, en).distance : MAST_ARM_MIN_M;
            const arm = Math.round(Math.max(MAST_ARM_MIN_M, Math.min(MAST_ARM_MAX_M, reach + MAST_ARM_PAST_M)) * 2) / 2;
            const heads = arm >= MAST_THREE_HEADS_M ? 3 : arm >= MAST_TWO_HEADS_M ? 2 : 1;
            const crossing = host ? kerbLines.filter((road) => road.name && road.name !== host.name && closestOnPolyline(road.line, walk.center).distance < 15)
              .sort((left, right) => closestOnPolyline(left.line, walk.center).distance - closestOnPolyline(right.line, walk.center).distance)[0] : null;
            addRow(zone, rule, `${cell}_${landing.sign > 0 ? "b" : "a"}`, en, scale(landing.outward, -1), {
              arm_m: arm, head_m: roundCoordinate(arm - 0.4), heads, ...(crossing ? { name: abbreviateStreetName(crossing.name) } : {}),
            });
          }
        } else {
          // One cabinet per crossing, behind the far-side pole of the landing with
          // the most paved street ground around it (a plaza or a wide sidewalk).
          let best = null;
          for (const landing of landings) {
            const pole = add(add(landing.landing, scale(landing.outward, 0.6)), scale(landing.travel, walk.width_m / 2 + 1));
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
          if (best) addRow(zone, rule, `${cell}_${best.landing.sign > 0 ? "b" : "a"}`, best.en, scale(best.landing.outward, -1));
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
        addRow(zone, rule, `n${junction.ref}`, en, front, { blades: bladesFor(arms, yawToward(front)) });
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
        for (const road of roads) signArms(zone, rule, ref, center, road, roads.filter((other) => other !== road), false);
      }
    } else if (rule.pattern === "drive_entries") {
      // Traffic turning off a named road into a kerbed service drive stops: a
      // sign on its right-hand curb, just past any crosswalk across the drive.
      for (const [ref, roads] of [...meetings.entries()].sort(([left], [right]) => compareSourceKeys(`n${left}`, `n${right}`))) {
        const named = roads.filter((road) => road.name != null);
        const drives = roads.filter((road) => road.name == null && road.highway === "service" && road.kerbed);
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
  };

  for (const { zone, contains } of pilotShapes) {
    for (const zoneRule of zone.furniture ?? []) runRule(zone, { ...zoneRule, source_id: `zone:${zone.id}/${zoneRule.id}` }, contains);
  }
  // The island-wide rules, after the zones' (which keep their streets and junctions).
  const islandZone = { id: "island" };
  const onIsland = (xz) => onLand(xz, 0);
  for (const islandRule of island?.rules ?? []) runRule(islandZone, { ...islandRule, source_id: `island:${islandRule.id}` }, onIsland);
  // A mast by a lit pole drops its own luminaire. This runs after every rule, so
  // it does not depend on the pole lamps' rule coming before the masts'.
  const litPoles = rows.filter((row) => row.prop === "utility_pole" && row.status === "placed" && row.prop_params?.lamp);
  for (const mast of ruleRows.filter((row) => row.prop === "signal_mast")) {
    const near = litPoles.some((pole) => Math.hypot(pole.position_m[0] - mast.position_m[0], pole.position_m[2] - mast.position_m[2]) < MAST_LIT_POLE_M);
    if (near) mast.prop_params = { ...mast.prop_params, lamp: false };
  }
  audit.osm_unbuilt.sort((left, right) => (left.id < right.id ? -1 : left.id > right.id ? 1 : 0));
  return { rows: ruleRows, audit };
}

// A level pad (a STREET_FURNITURE_PADS prop) of footprint {x_m, z_m} at world
// xz turned by yaw, on the visible ground (groundAt): it rises to the highest
// ground under it, lift metres over base (the row's land plus its surface bias,
// which a verge's sloped back can leave under the visible ground), and its skirt
// hides what its low side floats. {lift}, or {problem} when the ground is
// missing or the low side would float past PAD_SKIRT_M.
export function settlePad(footprint, xz, yaw, groundAt, base) {
  const centre = groundAt(xz);
  if (!centre) return { problem: "no_ground" };
  const [c, s] = [Math.cos(yaw), Math.sin(yaw)];
  const heights = [centre.y];
  const corners = [[-1, -1], [1, -1], [1, 1], [-1, 1]];
  for (let index = 0; index < 4; index += 1) {
    const [a, b] = [corners[index], corners[(index + 1) % 4]];
    for (let step = 0; step < PAD_SIDE_SAMPLES; step += 1) {
      const t = step / PAD_SIDE_SAMPLES;
      const [x, z] = [((a[0] + (b[0] - a[0]) * t) * footprint.x_m) / 2, ((a[1] + (b[1] - a[1]) * t) * footprint.z_m) / 2];
      const ground = groundAt([xz[0] + x * c + z * s, xz[1] - x * s + z * c]);
      if (!ground) return { problem: "no_ground" };
      heights.push(ground.y);
    }
  }
  const lift = roundCoordinate(Math.max(0, Math.max(...heights) - base));
  if (base + lift - Math.min(...heights) > PAD_SKIRT_M) return { problem: "uneven_ground" };
  return { lift };
}

// A local point of a prop at rest, turned as the runtime turns it: Godot's
// Basis(UP, yaw) * Basis(RIGHT, pitch) * Basis(BACK, -roll), in world x, y, z.
export function restOffset([x, y, z], yaw, pitch, roll) {
  const x1 = x * Math.cos(roll) + y * Math.sin(roll);
  const y1 = -x * Math.sin(roll) + y * Math.cos(roll);
  const y2 = y1 * Math.cos(pitch) - z * Math.sin(pitch);
  const z2 = y1 * Math.sin(pitch) + z * Math.cos(pitch);
  return [x1 * Math.cos(yaw) + z2 * Math.sin(yaw), y2, -x1 * Math.sin(yaw) + z2 * Math.cos(yaw)];
}

// The least-squares plane y = h + a x + b z through points {x, z, y}: [h, a, b].
export function leastSquaresPlane(points) {
  const m = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
  const r = [0, 0, 0];
  for (const { x, z, y } of points) {
    const terms = [1, x, z];
    for (let i = 0; i < 3; i += 1) {
      r[i] += terms[i] * y;
      for (let j = 0; j < 3; j += 1) m[i][j] += terms[i] * terms[j];
    }
  }
  const det = (q) => q[0][0] * (q[1][1] * q[2][2] - q[1][2] * q[2][1]) - q[0][1] * (q[1][0] * q[2][2] - q[1][2] * q[2][0]) + q[0][2] * (q[1][0] * q[2][1] - q[1][1] * q[2][0]);
  const d = det(m);
  invariant(Math.abs(d) > 1e-12, "Street furniture feet do not span a plane");
  return [0, 1, 2].map((k) => det(m.map((row, i) => row.map((value, j) => (j === k ? r[i] : value)))) / d);
}

// A prop on feet (STREET_FURNITURE_FEET) at rest on the visible ground, for its
// row at world xz with yaw and base height y + bias_m. It takes the plane
// through the ground under its feet: pitch raises its front and roll its left
// side (radians), lift takes its origin from the base to that plane (metres).
// Where the ground is not one plane under the feet (a fold in the terrain), each
// leg is lengthened by what its foot would still float there or shortened by
// what it would sink: leg_drops_m, in the feet's order and LEG_DROP_STEP_M
// steps, left out when every change rounds to nothing. Returns {pitch, roll,
// lift[, leg_drops_m]}, or {problem} when a foot has no ground, the rest would
// tilt more than MAX_REST_TILT_RAD or a leg needs more than MAX_LEG_DROP_M.
export function settleOnFeet(feet, xz, yaw, base, groundAt) {
  const groundUnder = (foot, pitch, roll) => {
    const offset = restOffset([foot.x, 0, foot.z], yaw, pitch, roll);
    const ground = groundAt([xz[0] + offset[0], xz[1] + offset[2]]);
    return ground ? { offset, y: ground.y } : null;
  };
  const samples = [];
  for (const foot of feet) {
    const ground = groundUnder(foot, 0, 0);
    if (!ground) return { problem: "no_ground" };
    samples.push({ x: foot.x, z: foot.z, y: ground.y });
  }
  const [height, slopeX, slopeZ] = leastSquaresPlane(samples);
  const pitch = Math.round(Math.atan(-slopeZ) * 1e4) / 1e4 || 0;
  const roll = Math.round(Math.atan(-slopeX * Math.cos(pitch)) * 1e4) / 1e4 || 0;
  if (restTilt(pitch, roll) > MAX_REST_TILT_RAD) return { problem: "too_steep" };
  const lift = roundCoordinate(height - base);
  const drops = [];
  for (const foot of feet) {
    const ground = groundUnder(foot, pitch, roll);
    if (!ground) return { problem: "no_ground" };
    drops.push(base + lift + ground.offset[1] - ground.y);
  }
  if (drops.some((drop) => Math.abs(drop) > MAX_LEG_DROP_M)) return { problem: "uneven_ground" };
  const rest = { pitch, roll, lift };
  const steps = drops.map((drop) => roundCoordinate(Math.round(drop / LEG_DROP_STEP_M) * LEG_DROP_STEP_M));
  if (steps.some((drop) => drop !== 0)) rest.leg_drops_m = steps;
  return rest;
}

// How far a rest of pitch and roll (radians) tilts a prop from upright: the
// angle between its up axis, Basis(RIGHT, pitch) * Basis(BACK, -roll) * Y, and +Y.
export function restTilt(pitch, roll) {
  return Math.acos(Math.min(1, Math.cos(pitch) * Math.cos(roll)));
}
