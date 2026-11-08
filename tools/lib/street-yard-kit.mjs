// The yard kit: the large clutter of Treasure Island's storage, truck and
// construction yards (shipping containers, container walls, self-storage shed
// rows, RVs, buses, trucks, trailers, boats, fabric sheds, equipment, material
// piles, plastic-covered berms, pole flags and the Pier 1 crane barges), written to
// game/resources/models/street/street_yard_kit.glb by
// tools/build_street_yard_kit.mjs and drawn at runtime by
// game/scripts/world/street_yard_kit.gd (through the street-clutter builder)
// with one shader (game/resources/materials/world/street/street_yard.gdshader).
//
// It follows the street-clutter kit (tools/lib/street-clutter-kit.mjs) and
// shares its mesh builder: every vertex names a part in UV.x and carries baked
// occlusion in UV.y; the shader turns the part into its colour and finish.
// Paint is not in the mesh: a prop's MultiMesh instance data picks up to three
// palette colours (body, accent, trim) and its weathering. Corrugation, ribs and
// weathering are drawn by the shader from the vertex's model-space position, so
// one box of a container wall carries its trapezoid corrugation without the
// triangles.
//
// Prop frame (as the car kit): origin on the ground under the middle of the
// plan rectangle, +Y up, front -Z (a vehicle's nose, a trailer's coupler, a
// container's blank end), +X the right side; a container's doors face +Z, a
// long prop (shed row, wall, berm, fabric shed) runs along Z. A barge's origin
// is on its waterline. Footprints {x_m, z_m, h_m} are the plan rectangle
// (mirrors excluded) and the height.
//
// Sizes are trade sizes (ISO containers, US vehicle classes, 10 ft storage
// units) and production inference from the dated 2023-2025 Street View and the
// May 2026 aerial of the yards (large-clutter research, 2026-11-04), generic
// rather than any make. Nothing here copies a photo.

import { carBodyGeometry, CLUTTER_KIT_PARTS } from "./street-clutter-kit.mjs";
import { leastSquaresPlane, restOffset } from "./street-furniture-generation.mjs";
import { roundCoordinate } from "./world-contract.mjs";

// ---------------------------------------------------------------- parts
// The first sixteen are the car kit's (so a car body re-encodes by its UV.x
// alone); the rest are the yard's. UV.x = (part + 0.5) / YARD_KIT_PART_SLOTS.
export const YARD_KIT_PARTS = Object.freeze([
  ...CLUTTER_KIT_PARTS,
  "corrugated", // container side and end walls: body colour, trapezoid corrugation
  "container_roof", // container roof: body colour, faded, shallow transverse ribs
  "container_door", // container door leaves: body colour, door corrugation
  "container_frame", // corner posts, rails and castings: body colour, darker
  "lock_bar", // door lock rods, cams and handles: galvanised grey
  "accent", // a vehicle's stripes and bands: accent colour
  "rollup", // roll-up doors: trim colour, horizontal ribs
  "shed_wall", // storage shed walls: body colour, vertical ribs
  "shed_roof", // storage shed roof: accent colour, ribs down the slope
  "fabric", // fabric shed membrane: body colour
  "timber", // crane mats, blocking
  "earth", // soil
  "gravel", // crushed aggregate
  "rubble", // broken concrete
  "plastic", // black plastic sheeting
  "concrete", // concrete: body colour (cylinder sections, blocks)
  "crane_red", // crane and excavator paint: body colour
  "hull", // barge hull: dark steel
  "tarp", // tarp over a pile: body colour
  "deck", // barge and trailer decks: worn steel or plank
  "cab_paint", // a truck cab or an RV's lower body: trim colour
  "inside", // the dark inside of a hollow piece
  "fiberglass", // a boat hull: body colour, gloss
  "canvas", // a boat cover: accent colour
  "window_frame", // RV and office window frames: dark grey
  "seal", // rubber seals and gaskets
  "white_body", // fixed white (RV caps, office trim)
  "vent", // roof vents and AC units
  "tank", // hoppers and tanks: body colour, welded, weathered
  "belt", // a conveyor's rubber belt
  "earth_dark", // freshly dumped soil: darker and browner than the tan earth
  "ramp_soil", // a dirt car ramp's packed soil: worn on top, rills down its sides
]);
export const YARD_KIT_PART_SLOTS = 64;
const P = Object.freeze(Object.fromEntries(YARD_KIT_PARTS.map((name, index) => [name, index])));
if (YARD_KIT_PARTS.length > YARD_KIT_PART_SLOTS) throw new Error("Yard kit has more parts than UV slots");

// ---------------------------------------------------------------- registry
// Container trade sizes (ISO 668): 8 ft wide, 8 ft 6 in (high cube 9 ft 6 in) tall.
const CONTAINER_W = 2.438;
const CONTAINER_H = 2.591;
const CONTAINER_HC_H = 2.896;
const CONTAINER_20_L = 6.058;
const CONTAINER_40_L = 12.192;
const CONTAINER_10_L = 2.991;
// Self-storage door module (a 10 ft unit) and the shed row's end allowance.
const SHED_BAY_M = 3.05;
const SHED_ENDS_M = 0.3;
// Fabric shed frame bay and end allowance.
const FABRIC_BAY_M = 5.0;
const FABRIC_ENDS_M = 0.4;
// A plastic berm's module length, and a soil ridge's (windrow).
const BERM_MODULE_M = 6.0;
const RIDGE_MODULE_M = 4.0;

const CONTAINER_COLOURS = ["white", "beige", "red", "rust", "orange", "green", "grey", "blue_grey", "blue", "brown"];
const WALL_COLOURS = ["green", "beige", "white", "grey", "blue_grey", "red", "rust", "blue"];

const intRange = (min, max) => Object.freeze({ type: "int", min, max });
const numRange = (min, max, step = null) => Object.freeze({ type: "number", min, max, step });
const oneOf = (...values) => Object.freeze({ type: "enum", values: Object.freeze(values.flat()) });

// ---------------------------------------------------------------- stunt ramps
// Each ramp's dirt profile is the outline both finishes share: the run up
// from the toe (+Z) to the lip, curving up toward the lip (a kicker) or
// straight (a tabletop's faces, a landing's slope), a flat top, and the
// faces down. Plywood stops square where dirt slopes away at STUNT_RAMP_BACK
// behind a lip and in front of a landing; dirt also slopes out at
// STUNT_RAMP_SIDE beside the deck.
// up: run to the lip; height; top: flat after the lip; down: a falling face
// after it (a tabletop) or the landing's whole slope (a landing starts high
// at its +Z end, facing the gap); run_up_m and landing_m: the clear ground a
// car needs before and after it (tools/lib/street-yard-generation.mjs ramps).
export const STUNT_RAMP_VARIANTS = Object.freeze([
  Object.freeze({ name: "kicker_small", width: 4.0, up: 4.0, height: 0.6, top: 0, down: 0, run_up_m: 16, landing_m: 12 }),
  Object.freeze({ name: "kicker_medium", width: 4.5, up: 7.0, height: 1.2, top: 0, down: 0, run_up_m: 35, landing_m: 22 }),
  Object.freeze({ name: "kicker_large", width: 5.0, up: 10.0, height: 2.0, top: 0, down: 0, run_up_m: 40, landing_m: 35 }),
  Object.freeze({ name: "tabletop", width: 5.0, up: 8.0, height: 1.5, top: 6.0, down: 9.0, run_up_m: 35, landing_m: 12 }),
  Object.freeze({ name: "gap_kicker", width: 4.5, up: 7.0, height: 1.4, top: 0, down: 0, run_up_m: 35, landing_m: 0 }),
  Object.freeze({ name: "landing", width: 4.5, up: 0, height: 1.4, top: 0, down: 9.0, run_up_m: 0, landing_m: 12 }),
]);
// The gap a gap pair leaves between its kicker's lip and its landing's top (m).
export const STUNT_RAMP_GAP_M = 10.0;
export const STUNT_RAMP_BACK = Math.tan((35 * Math.PI) / 180);
export const STUNT_RAMP_SIDE = Math.tan((40 * Math.PI) / 180);
const RAMP_CURVE = Object.freeze([0, 0.3, 0.55, 0.8, 1]);
const RAMP_CURVE_POWER = 1.6;

// A ramp's top outline in its frame, [[z, y], ...] from its +Z end to its -Z
// end, starting and ending on the ground, centred so the dirt outline's plan
// is centred on the origin.
export function stuntRampProfile(ramp, finish) {
  const points = rampOutline(ramp, finish === "dirt");
  // Centre on the dirt outline, so both finishes share one plan.
  const zs = rampOutline(ramp, true).map(([z]) => z);
  const shift = -(Math.max(...zs) + Math.min(...zs)) / 2;
  return points.map(([z, y]) => [Math.round((z + shift) * 1e4) / 1e4, Math.round(y * 1e4) / 1e4]);
}

// The outline from the toe at z = 0 (a landing: its high end at z = 0).
function rampOutline(ramp, dirt) {
  const h = ramp.height;
  const points = [];
  if (ramp.name === "landing") {
    points.push([dirt ? h / STUNT_RAMP_BACK : 0, 0], [0, h], [-ramp.down, 0]);
  } else {
    for (const t of RAMP_CURVE) points.push([-ramp.up * t, ramp.top === 0 ? h * Math.pow(t, RAMP_CURVE_POWER) : h * t]);
    if (ramp.top > 0) points.push([-ramp.up - ramp.top, h], [-ramp.up - ramp.top - ramp.down, 0]);
    else if (dirt) points.push([-ramp.up - 0.3, h - 0.04], [-ramp.up - 0.3 - (h - 0.04) / STUNT_RAMP_BACK, 0]);
    else points.push([-ramp.up, 0]);
  }
  return points;
}

// A ramp's plan and height: the dirt outline with its side slopes.
function stuntRampPlan(ramp) {
  const zs = stuntRampProfile(ramp, "dirt").map(([z]) => z);
  return { x_m: Math.round((ramp.width + (2 * ramp.height) / STUNT_RAMP_SIDE) * 1000) / 1000, z_m: Math.round((Math.max(...zs) - Math.min(...zs)) * 1000) / 1000, h_m: ramp.height };
}

// Every prop: its variants in index order with their plan size and height,
// its collision kind and its params (the runtime, street_yard_kit.gd, holds
// its far range and colour values). A param list's first value is its
// default. Every row may also carry seed (int), and pitch, roll (radians) and
// lift (metres) for its rest on uneven ground (settleYardProp).
//   collision: box (one box per body), boxes (one per container or part),
//   hull (convex prisms over a shed's bays and ends), floor (the floor the kit
//   lays over a heap's visible mesh, no triangle steeper than 45 degrees, so
//   the player walks up it), cylinder, or none (a barge floats; it rests on
//   no ground).
export const YARD_KIT_PROPS = Object.freeze({
  shipping_container: {
    collision: "box",
    variants: [
      { name: "20ft", x_m: CONTAINER_W, z_m: CONTAINER_20_L, h_m: CONTAINER_H },
      { name: "40ft", x_m: CONTAINER_W, z_m: CONTAINER_40_L, h_m: CONTAINER_H },
      { name: "40ft_hc", x_m: CONTAINER_W, z_m: CONTAINER_40_L, h_m: CONTAINER_HC_H },
      // A roll-up door cut into the +X side (3rd St, Mar 2025).
      { name: "20ft_rollup", x_m: CONTAINER_W, z_m: CONTAINER_20_L, h_m: CONTAINER_H },
      // An office: windows and a personnel door in the +X side (801 Avenue H, Sep 2025: a 40 ft box).
      { name: "40ft_office", x_m: CONTAINER_W, z_m: CONTAINER_40_L, h_m: CONTAINER_H },
      // The 10 ft box container walls use to fill a run.
      { name: "10ft", x_m: CONTAINER_W, z_m: CONTAINER_10_L, h_m: CONTAINER_H },
    ],
    params: { colour: oneOf(CONTAINER_COLOURS), stack: intRange(1, 2), colour_top: oneOf(CONTAINER_COLOURS), weathering: numRange(0, 1) },
  },
  container_wall: {
    collision: "boxes",
    variants: [
      { name: "single", x_m: CONTAINER_W, z_m: null, h_m: CONTAINER_H },
      { name: "double", x_m: CONTAINER_W, z_m: null, h_m: 2 * CONTAINER_H },
    ],
    params: { length_m: numRange(CONTAINER_20_L, 400), colour: oneOf(WALL_COLOURS), colour_top: oneOf(WALL_COLOURS), weathering: numRange(0, 1) },
    required: ["length_m"],
  },
  storage_shed_row: {
    collision: "hull",
    variants: [
      // Units back to back, doors on both long sides.
      { name: "double", x_m: 7.32, z_m: null, h_m: 3.1, eave_m: 2.62, doors: [1, -1] },
      // Doors on +X only; the roof slopes down to the back.
      { name: "single", x_m: 4.57, z_m: null, h_m: 2.9, eave_m: 2.44, doors: [1] },
      { name: "wide", x_m: 12.19, z_m: null, h_m: 3.8, eave_m: 2.9, doors: [1, -1] },
    ],
    params: { bays: intRange(2, 60), roof: oneOf("beige", "white", "grey", "rust"), wall: oneOf("beige", "white", "grey"), doors: oneOf("white", "beige", "grey") },
    required: ["bays"],
  },
  rv: {
    collision: "box",
    variants: [
      { name: "class_a", x_m: 2.55, z_m: 11.6, h_m: 3.75 },
      { name: "class_c", x_m: 2.4, z_m: 8.5, h_m: 3.45 },
      { name: "travel_trailer", x_m: 2.44, z_m: 9.0, h_m: 3.25 },
      { name: "fifth_wheel", x_m: 2.5, z_m: 10.5, h_m: 3.9 },
    ],
    params: { paint: oneOf("white", "cream"), stripe: oneOf("grey", "brown", "black", "blue", "red") },
  },
  bus: {
    collision: "box",
    variants: [
      { name: "coach", x_m: 2.6, z_m: 13.7, h_m: 3.7 },
      { name: "shuttle", x_m: 2.4, z_m: 8.2, h_m: 3.2 },
    ],
    params: { paint: oneOf("white", "red", "silver", "black", "blue"), accent: oneOf("none", "grey", "red", "blue", "black") },
  },
  box_truck: {
    collision: "box",
    variants: [
      { name: "medium", x_m: 2.4, z_m: 7.4, h_m: 3.5 },
      { name: "large", x_m: 2.6, z_m: 10.4, h_m: 4.0 },
    ],
    params: { cab: oneOf("white", "red", "blue", "grey", "black"), box: oneOf("white", "grey") },
  },
  van: {
    collision: "box",
    variants: [
      // The car kit's high-roof cargo van body.
      { name: "cargo", x_m: null, z_m: null, h_m: null, car_body: "van" },
      { name: "step", x_m: 2.4, z_m: 7.0, h_m: 3.0 },
    ],
    params: { paint: oneOf("white", "silver", "grey", "dark_grey", "black") },
  },
  food_truck: {
    collision: "box",
    variants: [
      { name: "step_van", x_m: 2.4, z_m: 7.3, h_m: 3.3 },
      { name: "trailer", x_m: 2.44, z_m: 6.2, h_m: 3.0 },
    ],
    params: { paint: oneOf("white", "silver", "red", "blue", "black") },
  },
  boat_on_trailer: {
    collision: "box",
    variants: [
      { name: "runabout", x_m: 2.5, z_m: 7.3, h_m: 2.2 },
      { name: "cabin", x_m: 2.6, z_m: 8.8, h_m: 2.9 },
    ],
    params: { hull: oneOf("white", "cream", "blue", "grey"), cover: oneOf("none", "blue", "grey", "tan", "black") },
  },
  trailer: {
    collision: "box",
    variants: [
      { name: "cargo", x_m: 2.6, z_m: 7.3, h_m: 3.0 },
      { name: "utility", x_m: 2.4, z_m: 4.5, h_m: 1.55 },
      { name: "semi", x_m: 2.6, z_m: 16.2, h_m: 4.1 },
      { name: "office", x_m: 3.66, z_m: 14.6, h_m: 3.5 },
    ],
    params: { paint: oneOf("white", "grey", "beige", "blue") },
  },
  fabric_shed: {
    collision: "hull",
    variants: [
      { name: "span10", x_m: 10, z_m: null, h_m: 5.2, eave_m: 3.5 },
      { name: "span15", x_m: 15, z_m: null, h_m: 6.4, eave_m: 4.0 },
      { name: "span20", x_m: 20, z_m: null, h_m: 7.6, eave_m: 4.5 },
      { name: "span30", x_m: 30, z_m: null, h_m: 9.6, eave_m: 5.0 },
    ],
    params: { bays: intRange(2, 40), fabric: oneOf("white", "tan", "grey") },
    required: ["bays"],
  },
  equipment: {
    collision: "box",
    variants: [
      // Parked with the arm hanging and the bucket curled under the boom tip;
      // the boom's knee stands highest.
      { name: "excavator", x_m: 3.2, z_m: 10.0, h_m: 4.5 },
      { name: "wheel_loader", x_m: 3.0, z_m: 8.0, h_m: 3.5 },
      { name: "crane_mats", x_m: 1.2, z_m: 9.1, h_m: 1.2 },
      // Short hollow cylinder sections standing on end (Gate 5 yard, May 2026
      // aerial: light rims, dark centres, ~1.8 m across, ~1.3 m from shadows).
      { name: "cylinder_section", x_m: 1.8, z_m: 1.8, h_m: 1.3, collision: "cylinder" },
      // An open-top steel bin (roll-off container; Avenue M, Nov 2025: blue, rusted).
      { name: "open_bin", x_m: 2.44, z_m: 6.9, h_m: 1.85 },
      // A cone-bottomed hopper on four legs (SFFD training yard, 10th St, Nov 2025).
      { name: "hopper", x_m: 4.0, z_m: 4.0, h_m: 8.0 },
      // A long inclined belt conveyor on legs (recycling yard, May 2026 aerial:
      // plain form), rising toward +Z; length_m is its plan length.
      { name: "conveyor", x_m: 1.4, z_m: null, h_m: null, required: ["length_m"], only: ["length_m"] },
      // A water-filled plastic barrier, jersey profile, one unit (Gate 5 yard,
      // Nov 2025, and Avenue H, Jun 2021: red barriers in clusters and lines);
      // red unless the row paints it.
      { name: "water_barrier", x_m: 0.6, z_m: 1.9, h_m: 1.0 },
    ],
    // paint: a machine's (or bin's, or hopper's) colour; house: an excavator's
    // upper structure, the paint unless it differs (Avenue M, Nov 2025: a red
    // boom on a white house); tone: a cylinder section's concrete.
    params: { paint: oneOf("yellow", "red", "orange", "blue", "white"), house: oneOf("same", "white", "light_grey"), tone: oneOf("light", "dark"), length_m: numRange(12, 60) },
  },
  material_pile: {
    collision: "floor",
    variants: [
      { name: "gravel", x_m: 8, z_m: 8, h_m: 3 },
      { name: "rubble", x_m: 12, z_m: 12, h_m: 4.5 },
      { name: "soil", x_m: 12, z_m: 12, h_m: 4 },
      { name: "tarp", x_m: 6, z_m: 8, h_m: 2.2 },
      // A windrow: a long low soil ridge in 4 m modules (505 Avenue N, May 2026
      // aerial: ~12 parallel ridges ~3 m wide, ~1 m high, ~60 m long).
      { name: "ridge", x_m: 3, z_m: null, h_m: 1, required: ["length_m"], only: ["length_m"] },
      // Truckloads of soil dumped together on a construction site: darker and
      // lumpier than the stockpiled soil, a few loads merged with saddles
      // between their tops and loose clods on them (the wastewater plant site:
      // Esri aerials Aug 2025 and May 2026, Street View 13th St Sep 2025).
      { name: "dumped", x_m: 12, z_m: 12, h_m: 3.6 },
    ],
    // scale (in steps of 0.05, so piles share their floor shapes) and shape for
    // the mounds; length_m (rounded to whole 4 m modules) for a ridge.
    params: { scale: numRange(0.5, 3, 0.05), shape: intRange(0, 2), length_m: numRange(RIDGE_MODULE_M, 240) },
  },
  plastic_berm: {
    collision: "floor",
    variants: [
      { name: "low", x_m: 9, z_m: null, h_m: 1.8 },
      // Its rounded ends take a whole module each, so it needs two.
      { name: "high", x_m: 15, z_m: null, h_m: 3.2, minimum: { modules: 2 } },
    ],
    params: { modules: intRange(1, 60) },
    required: ["modules"],
  },
  // A flag on a slim galvanised pole (9th St, Sep 2025: two above the
  // storage yard's fence; the 810 Avenue D lot corner): a 1.5 x 0.9 m flag in
  // red, white and blue bands, SELF STORAGE on the white band (legible in the
  // photo) or plain, flying along +X from the pole's top. The plan is the
  // pole's foot; height_m is the pole's height.
  pole_flag: {
    collision: "cylinder",
    variants: [{ name: "flag", x_m: 0.15, z_m: 0.15, h_m: 6.5 }],
    params: { height_m: numRange(5, 8), text: oneOf("self_storage", "none") },
  },
  // Car ramps (owner request, 2026-11-08): a few in three empty lots so the
  // player can jump cars, an invented gameplay feature rather than anything
  // photographed on the island. Generic stunt ramps, production inference: a
  // graded dirt kicker or a plywood deck on a galvanised frame (finish). A car
  // drives toward -Z over one; each variant's profile (stuntRampProfile) gives
  // its plan, with a dirt ramp's side and back slopes, which both finishes keep.
  stunt_ramp: {
    collision: "prisms",
    variants: STUNT_RAMP_VARIANTS.map((ramp) => Object.freeze({ name: ramp.name, ...stuntRampPlan(ramp) })),
    params: { finish: oneOf("dirt", "plywood") },
  },
  // Pier 1's work barges and crane (May 2026 aerial, Mar 2025 Avenue N view).
  // Visual context outside the playable boundary: no collision. A barge's
  // origin is on its waterline; width_m x length_m is its deck, raked at both
  // ends. The crane barge carries a red crawler crane at its +Z end, its boom
  // over the deck toward -Z (lowered: nearly level, out past the bow).
  crane_barge: {
    collision: "none",
    variants: [
      { name: "crane", x_m: 30, z_m: 40, h_m: 46, only: ["length_m", "width_m", "hull", "deck", "cargo", "deckhouse", "boom"] },
      { name: "deck", x_m: 18, z_m: 36, h_m: 4.2, only: ["length_m", "width_m", "hull", "deck", "cargo", "deckhouse"] },
      // A crawler crane standing on the pier: its origin is on the ground.
      { name: "pier_crane", x_m: 6, z_m: 9, h_m: 60, only: [] },
    ],
    params: {
      length_m: numRange(15, 100),
      width_m: numRange(8, 40),
      hull: oneOf("dark_grey", "rust", "light_grey"),
      deck: oneOf("dark_grey", "rust", "light_grey", "red"),
      // On the deck, generic shapes as the aerial shows them: nothing,
      // containers (one red 40 ft and white 20 ft boxes in a row), materials
      // (stacked mats and beams), a box block (white 20 ft boxes two rows
      // wide, three or four long) or equipment (red machinery and stacked
      // materials, the crane decks' clutter).
      cargo: oneOf("none", "containers", "materials", "box_block", "equipment"),
      deckhouse: oneOf("none", "small"),
      boom: oneOf("raised", "lowered"),
    },
  },
});
export const YARD_KIT_KEYS = Object.freeze(Object.keys(YARD_KIT_PROPS));
// Params every row may carry besides the prop's own.
const COMMON_PARAMS = Object.freeze({ variant: intRange(0, 15), seed: intRange(0, 0x7fffffff), pitch: numRange(-0.35, 0.35), roll: numRange(-0.35, 0.35), lift: numRange(-1, 1) });

function variantOf(key, params) {
  const prop = YARD_KIT_PROPS[key];
  if (!prop) throw new Error(`Unknown yard prop ${key}`);
  const index = params?.variant ?? 0;
  const variant = prop.variants[index];
  if (!variant) throw new Error(`Yard prop ${key} has no variant ${index}`);
  return { prop, variant, index };
}

// Why a row's prop params are unusable for a yard prop, or null.
export function yardPropParamsError(key, params) {
  const prop = YARD_KIT_PROPS[key];
  if (!prop) return `unknown yard prop ${key}`;
  if (params === null || typeof params !== "object" || Array.isArray(params)) return "params must be an object";
  if (!Number.isInteger(params.variant) || prop.variants[params.variant] === undefined) return `variant must be an index 0..${prop.variants.length - 1}`;
  const specs = { ...COMMON_PARAMS, ...prop.params };
  for (const [name, value] of Object.entries(params)) {
    const spec = specs[name];
    if (!spec) return `${key} takes no param ${name}`;
    if (spec.type === "enum" && !spec.values.includes(value)) return `${name} must be one of ${spec.values.join(", ")}`;
    if (spec.type === "int" && !(Number.isInteger(value) && value >= spec.min && value <= spec.max)) return `${name} must be an integer ${spec.min}..${spec.max}`;
    if (spec.type === "number" && !(typeof value === "number" && Number.isFinite(value) && value >= spec.min && value <= spec.max)) return `${name} must be a number ${spec.min}..${spec.max}`;
    if (spec.step && Math.abs(value / spec.step - Math.round(value / spec.step)) > 1e-6) return `${name} must be a multiple of ${spec.step}`;
  }
  const variant = prop.variants[params.variant];
  for (const name of [...(prop.required ?? []), ...(variant.required ?? [])]) if (params[name] === undefined) return `${key} ${variant.name} needs ${name}`;
  for (const [name, least] of Object.entries(variant.minimum ?? {})) if (params[name] !== undefined && params[name] < least) return `${key} ${variant.name} needs ${name} >= ${least}`;
  // A variant may take only some of its prop's params (a ridge takes length_m, not scale).
  if (variant.only) {
    for (const name of Object.keys(prop.params)) {
      if (params[name] !== undefined && !variant.only.includes(name)) return `${key} ${variant.name} takes no ${name}`;
    }
  } else {
    for (const name of Object.keys(prop.params)) {
      const onlyElsewhere = prop.variants.some((other) => other.only?.includes(name));
      if (params[name] !== undefined && onlyElsewhere) return `${key} ${variant.name} takes no ${name}`;
    }
  }
  return null;
}

// The plan rectangle and height of a placed yard prop: {x_m, z_m, h_m}, with
// x_m along the prop's local X and z_m along its local Z.
export function yardPropFootprint(key, params) {
  const error = yardPropParamsError(key, params);
  if (error) throw new Error(`Yard prop ${key}: ${error}`);
  const { variant } = variantOf(key, params);
  const round = (value) => Math.round(value * 1000) / 1000;
  switch (key) {
    case "shipping_container":
      return { x_m: variant.x_m, z_m: variant.z_m, h_m: round(variant.h_m * (params.stack ?? 1)) };
    case "container_wall": {
      const layout = containerWallLayout(params);
      return { x_m: variant.x_m, z_m: round(params.length_m), h_m: variant.h_m, covered_m: layout.covered_m };
    }
    case "storage_shed_row":
      return { x_m: variant.x_m, z_m: round(params.bays * SHED_BAY_M + SHED_ENDS_M), h_m: variant.h_m };
    case "fabric_shed":
      return { x_m: variant.x_m, z_m: round(params.bays * FABRIC_BAY_M + FABRIC_ENDS_M), h_m: variant.h_m };
    case "plastic_berm":
      return { x_m: variant.x_m, z_m: round(params.modules * BERM_MODULE_M), h_m: variant.h_m };
    case "material_pile": {
      if (variant.name === "ridge") return { x_m: variant.x_m, z_m: ridgeModules(params.length_m) * RIDGE_MODULE_M, h_m: variant.h_m };
      const s = params.scale ?? 1;
      return { x_m: round(variant.x_m * s), z_m: round(variant.z_m * s), h_m: round(variant.h_m * s) };
    }
    case "equipment":
      if (variant.name === "conveyor") {
        const modules = conveyorModules(params.length_m);
        const plan = modules * CONVEYOR_MODULE_M * Math.cos(CONVEYOR_INCLINE);
        return { x_m: variant.x_m, z_m: round(plan), h_m: round(modules * CONVEYOR_MODULE_M * Math.sin(CONVEYOR_INCLINE) + CONVEYOR_FOOT_M + 1.0) };
      }
      return { x_m: variant.x_m, z_m: variant.z_m, h_m: variant.h_m };
    case "pole_flag":
      return { x_m: variant.x_m, z_m: variant.z_m, h_m: round(params.height_m ?? variant.h_m) };
    case "crane_barge":
      if (variant.name === "pier_crane") return { x_m: variant.x_m, z_m: variant.z_m, h_m: variant.h_m };
      return { x_m: round(params.width_m ?? variant.x_m), z_m: round(params.length_m ?? variant.z_m), h_m: variant.h_m };
    case "van":
      if (variant.car_body) {
        const body = carBodyGeometry(variant.car_body);
        return { x_m: body.width_m, z_m: body.length_m, h_m: body.height_m };
      }
      return { x_m: variant.x_m, z_m: variant.z_m, h_m: variant.h_m };
    default:
      return { x_m: variant.x_m, z_m: variant.z_m, h_m: variant.h_m };
  }
}

// A container wall run, a pure function of length_m (the runtime builder,
// game/scripts/world/street_yard_kit.gd, repeats it exactly): 40 ft
// containers end to end from the run's -Z end, then 20 ft and 10 ft ones to
// fill; the gaps between them widen evenly (up to MAX_WALL_GAP_M, 0.3 m) to take up
// what is left, and anything still left stays open at the +Z end. Returns
// {containers: [{z_m (centre, row frame), length_m, size: "40ft"|"20ft"|"10ft"}],
// covered_m}.
const WALL_GAP_M = 0.12;
const MAX_WALL_GAP_M = 0.3;
export const CONTAINER_LENGTHS = Object.freeze({ "40ft": CONTAINER_40_L, "20ft": CONTAINER_20_L, "10ft": CONTAINER_10_L });
export function containerWallLayout(params) {
  const length = params.length_m;
  const sizes = [];
  let used = -WALL_GAP_M;
  for (const size of ["40ft", "20ft", "10ft"]) {
    while (used + WALL_GAP_M + CONTAINER_LENGTHS[size] <= length + 1e-9) {
      sizes.push(size);
      used += WALL_GAP_M + CONTAINER_LENGTHS[size];
    }
  }
  const gaps = sizes.length - 1;
  const spare = length - used;
  const gap = gaps > 0 ? Math.min(MAX_WALL_GAP_M, WALL_GAP_M + spare / gaps) : 0;
  const containers = [];
  let at = -length / 2;
  for (const size of sizes) {
    const boxLength = CONTAINER_LENGTHS[size];
    containers.push({ z_m: Math.round((at + boxLength / 2) * 1000) / 1000, length_m: boxLength, size });
    at += boxLength + gap;
  }
  const last = containers.at(-1);
  const covered = last ? last.z_m + last.length_m / 2 + length / 2 : 0;
  return { containers, covered_m: Math.round(covered * 1000) / 1000 };
}

// A conveyor: 6 m truss modules rising at 16 degrees from a foot 1.2 m up.
export const CONVEYOR_MODULE_M = 6.0;
export const CONVEYOR_INCLINE = (16 * Math.PI) / 180;
export const CONVEYOR_FOOT_M = 1.2;
export function conveyorModules(lengthM) {
  return Math.max(2, Math.round(lengthM / (CONVEYOR_MODULE_M * Math.cos(CONVEYOR_INCLINE))));
}

// A soil ridge's whole 4 m modules for a requested length.
export function ridgeModules(lengthM) {
  return Math.max(1, Math.round(lengthM / RIDGE_MODULE_M));
}

// The kind table radius for a yard prop: half the short side of its smallest
// plan (a long prop at its shortest length, a pile at its smallest scale).
export function yardKindRadius(key) {
  const prop = YARD_KIT_PROPS[key];
  let smallest = Infinity;
  prop.variants.forEach((variant, index) => {
    const params = { variant: index };
    for (const name of [...(prop.required ?? []), ...(variant.required ?? [])]) params[name] = Math.max(prop.params[name].min, variant.minimum?.[name] ?? -Infinity);
    if (key === "material_pile" && variant.name !== "ridge") params.scale = prop.params.scale.min;
    if (key === "crane_barge" && variant.name !== "pier_crane") params.width_m = prop.params.width_m.min;
    const footprint = yardPropFootprint(key, params);
    smallest = Math.min(smallest, footprint.x_m, footprint.z_m);
  });
  return Math.round((smallest / 2) * 1000) / 1000;
}

// ---------------------------------------------------------------- rest on the ground
// A yard prop rests on the visible ground on its plan's underside, sampled at
// its corners and on a grid over it no coarser than YARD_REST_STEP_M (so a
// long wall or shed row is sampled along every container, bay or module):
// the plane through the ground there gives its pitch (raising its front, -Z),
// roll (its left side) and lift (metres from the row's base, y + bias_m, to
// that plane at its middle), as the runtime turns it (Basis(UP, yaw) *
// Basis(RIGHT, pitch) * Basis(BACK, -roll)). Resting so, no sample may float
// more than YARD_MAX_FLOAT_M over the ground or sink more than its limit into
// it: YARD_MAX_SINK_M, or YARD_VEHICLE_MAX_SINK_M for a vehicle, boat or
// machine, whose wheels or tracks would show it. A barge floats, so it has no
// rest. Ground that dips or humps along a long prop more than that needs the
// prop split into shorter rows.
export const YARD_REST_STEP_M = 3;
export const YARD_MAX_FLOAT_M = 0.08;
export const YARD_MAX_SINK_M = 0.3;
export const YARD_VEHICLE_MAX_SINK_M = 0.1;
export const YARD_MAX_TILT_RAD = 0.35;
export function yardPropRests(key) {
  return YARD_KIT_PROPS[key]?.collision !== "none";
}

const ON_WHEELS = new Set(["rv", "bus", "box_truck", "van", "food_truck", "trailer", "boat_on_trailer"]);
const MACHINES = new Set(["excavator", "wheel_loader"]);
export function yardMaxSink(key, params = {}) {
  const variant = YARD_KIT_PROPS[key]?.variants[params?.variant ?? 0]?.name;
  return ON_WHEELS.has(key) || (key === "equipment" && MACHINES.has(variant)) ? YARD_VEHICLE_MAX_SINK_M : YARD_MAX_SINK_M;
}

// The plan points ([x, z] in the prop frame) a prop rests on.
export function yardRestPoints(footprint) {
  const stations = (size) => {
    const n = Math.max(1, Math.ceil(size / YARD_REST_STEP_M - 1e-9));
    return Array.from({ length: n + 1 }, (_, i) => -size / 2 + (size * i) / n);
  };
  const points = [];
  for (const z of stations(footprint.z_m)) for (const x of stations(footprint.x_m)) points.push([x, z]);
  return points;
}

// How far each rest point floats over the visible ground (+) or sinks into it
// (-) for a row at world xz, yaw, base height and rest; null where a point
// has no ground.
export function yardRestGaps(footprint, xz, yaw, base, rest, groundAt) {
  return yardRestPoints(footprint).map(([x, z]) => {
    const offset = restOffset([x, 0, z], yaw, rest.pitch ?? 0, rest.roll ?? 0);
    const ground = groundAt([xz[0] + offset[0], xz[1] + offset[2]]);
    return ground ? base + (rest.lift ?? 0) + offset[1] - ground.y : null;
  });
}

// The rest a yard prop takes on the visible ground: {pitch, roll, lift}, or
// {problem} where a rest point has no ground, the ground tilts more than
// YARD_MAX_TILT_RAD or it is too uneven for the points to sit within
// YARD_MAX_FLOAT_M and maxSink (yardMaxSink).
export function settleYardProp(footprint, xz, yaw, base, groundAt, maxSink = YARD_MAX_SINK_M) {
  const samples = [];
  for (const [x, z] of yardRestPoints(footprint)) {
    const offset = restOffset([x, 0, z], yaw, 0, 0);
    const ground = groundAt([xz[0] + offset[0], xz[1] + offset[2]]);
    if (!ground) return { problem: "no_ground" };
    samples.push({ x, z, y: ground.y });
  }
  const [height, slopeX, slopeZ] = leastSquaresPlane(samples);
  const pitch = Math.round(Math.atan(-slopeZ) * 1e4) / 1e4 || 0;
  const roll = Math.round(Math.atan(-slopeX * Math.cos(pitch)) * 1e4) / 1e4 || 0;
  if (Math.abs(pitch) > YARD_MAX_TILT_RAD || Math.abs(roll) > YARD_MAX_TILT_RAD) return { problem: "too_steep" };
  const rest = { pitch, roll, lift: roundCoordinate(height - base) };
  const gaps = yardRestGaps(footprint, xz, yaw, base, rest, groundAt);
  if (gaps.some((gap) => gap === null)) return { problem: "no_ground" };
  // Sit on the highest ground under it rather than float off the lowest.
  const drop = Math.max(...gaps) - YARD_MAX_FLOAT_M;
  if (drop > 0) rest.lift = roundCoordinate(rest.lift - drop);
  if (gaps.some((gap) => gap - Math.max(0, drop) < -maxSink)) return { problem: "uneven_ground" };
  return rest;
}
