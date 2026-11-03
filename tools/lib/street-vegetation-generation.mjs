// Street vegetation: the trees and grass clumps of PlayableWorld/StreetDetail/Vegetation.
//
// A vegetation row is built when it carries a prop of the street-vegetation kit
// (game/scripts/world/street_vegetation_kit.gd, which keeps the same variant
// counts and foot radii as STREET_VEGETATION_PROPS). Props come from:
//   - zone scatter rules that name one (tools/config/street-detail-zones.json):
//     the Avenue of the Palms fan palms and the grass clumps of the mulch beds;
//   - set pieces (data/street_detail/set_pieces.json) where dated photos show
//     particular trees: Building 1's date palms, tall fan palms and cypresses,
//     the Waterfront Plaza's young cypresses.
// Only species photographed on Treasure Island are props. Each rule and set
// piece names its dated evidence; positions, sizes and counts are production
// inference, not survey data.
//
// Every planted row rests on the visible ground (the draped lawn, the raised
// mulch beds and sidewalks, the land; groundAt is visibleGroundIndex of
// tools/lib/street-clutter-generation.mjs), not only on the land under it: the
// foot is settled at the lowest visible surface round its trunk (settlePlant),
// so it never floats, and the kit runs the trunk on below the foot so the higher
// side never shows a gap. World x, z with z = -north, as everywhere in street detail.

import { createHash } from "node:crypto";

import { invariant, roundCoordinate } from "./world-contract.mjs";

// Kit props, the row kinds that may carry each, how many fixed variants the kit
// draws and the radius of the foot the generator settles (m).
export const STREET_VEGETATION_PROPS = Object.freeze({
  canary_date_palm: Object.freeze({ kinds: Object.freeze(["palm_slot", "tree"]), variants: 4, foot_m: 0.7 }),
  clump_grass: Object.freeze({ kinds: Object.freeze(["grass_clump"]), variants: 4, foot_m: 0.3 }),
  mexican_fan_palm: Object.freeze({ kinds: Object.freeze(["palm_slot", "tree"]), variants: 6, foot_m: 0.45 }),
  monterey_cypress: Object.freeze({ kinds: Object.freeze(["tree"]), variants: 3, foot_m: 0.8 }),
});
// How far the kit runs a trunk on below its foot (street_vegetation_kit.gd BURY_M):
// the visible ground round a foot may rise at most this far above it.
export const STREET_VEGETATION_BURY_M = 0.35;
// The most the visible ground may rise and fall under one foot; beyond it the
// spot is too uneven (a curb edge, a step) and the plant is not placed there.
export const STREET_VEGETATION_MAX_FOOT_SPREAD_M = 0.25;
// The uniform scale an instance may take.
export const STREET_VEGETATION_SCALE_RANGE = Object.freeze([0.8, 1.25]);
// The foot is sampled at its centre and on two rings (fractions of its radius).
const FOOT_RINGS = Object.freeze([0.5, 1.0]);
const FOOT_RING_SAMPLES = 12;
const PARAM_FIELDS = Object.freeze(["scale", "variants"]);
const SET_PIECE_PARAM_FIELDS = Object.freeze(["scale", "variant"]);

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

function hashUnit(seed, identity, slot) {
  return createHash("sha256").update(`${seed}|${identity}|vegetation`, "utf8").digest().readUInt32BE(slot * 4) / 0xffffffff;
}

// The variants and scale range a scatter rule draws from: {variants: [first,
// last], scale: [low, high]}.
export function validateVegetationRuleParams(prop, params, label) {
  const spec = STREET_VEGETATION_PROPS[prop];
  invariant(spec, `${label}: ${prop} is not a street-vegetation prop`);
  invariant(params != null && typeof params === "object" && !Array.isArray(params)
    && JSON.stringify(Object.keys(params).sort()) === JSON.stringify(PARAM_FIELDS), `${label} params must be exactly {variants: [first, last], scale: [low, high]}`);
  const [first, last] = params.variants;
  invariant(Array.isArray(params.variants) && params.variants.length === 2 && Number.isInteger(first) && Number.isInteger(last)
    && first >= 0 && last >= first && last < spec.variants, `${label} variants must be [first, last] within ${prop}'s ${spec.variants}`);
  validateScale(params.scale, label);
}

// A set piece names one variant and its scale: {variant, scale}.
export function validateVegetationSetPieceParams(prop, kind, params, label) {
  const spec = STREET_VEGETATION_PROPS[prop];
  invariant(spec && spec.kinds.includes(kind), `${label}: prop ${prop} does not build a ${kind}`);
  invariant(params != null && typeof params === "object" && !Array.isArray(params)
    && JSON.stringify(Object.keys(params).sort()) === JSON.stringify(SET_PIECE_PARAM_FIELDS), `${label} params must be exactly {variant, scale}`);
  invariant(Number.isInteger(params.variant) && params.variant >= 0 && params.variant < spec.variants, `${label} variant must be within ${prop}'s ${spec.variants}`);
  invariant(isFiniteNumber(params.scale) && params.scale >= STREET_VEGETATION_SCALE_RANGE[0] && params.scale <= STREET_VEGETATION_SCALE_RANGE[1], `${label} scale must be in [${STREET_VEGETATION_SCALE_RANGE.join(", ")}]`);
}

function validateScale(scale, label) {
  invariant(Array.isArray(scale) && scale.length === 2 && scale.every(isFiniteNumber) && scale[0] <= scale[1]
    && scale[0] >= STREET_VEGETATION_SCALE_RANGE[0] && scale[1] <= STREET_VEGETATION_SCALE_RANGE[1], `${label} scale must be [low, high] within [${STREET_VEGETATION_SCALE_RANGE.join(", ")}]`);
}

// A rule's draw for one candidate: its variant and scale, keyed by the row identity.
export function drawVegetationVariant(seed, identity, params) {
  const [first, last] = params.variants;
  const variant = Math.min(last, first + Math.floor(hashUnit(seed, identity, 0) * (last - first + 1)));
  const scale = roundCoordinate(params.scale[0] + (params.scale[1] - params.scale[0]) * hashUnit(seed, identity, 1));
  return { variant, scale };
}

// Plan sample points of a foot of radius footM at [x, z]: its centre and two rings.
export function footSamples(xz, footM) {
  const points = [[xz[0], xz[1]]];
  for (const ring of FOOT_RINGS) {
    for (let index = 0; index < FOOT_RING_SAMPLES; index += 1) {
      const angle = (Math.PI * 2 * index) / FOOT_RING_SAMPLES;
      points.push([xz[0] + Math.cos(angle) * footM * ring, xz[1] + Math.sin(angle) * footM * ring]);
    }
  }
  return points;
}

// A plant's foot on the visible ground: it rests at the lowest visible surface
// under its foot, so no part of it floats; the trunk runs on below the foot, so
// the rest of the foot, up to STREET_VEGETATION_MAX_FOOT_SPREAD_M higher, is
// covered. Returns {rest_y, spread_m, materials} or {problem}.
export function settlePlant(xz, footM, groundAt) {
  let low = Infinity;
  let high = -Infinity;
  const materials = new Set();
  for (const point of footSamples(xz, footM)) {
    const ground = groundAt(point);
    if (!ground) return { problem: "no_visible_ground" };
    low = Math.min(low, ground.y);
    high = Math.max(high, ground.y);
    materials.add(ground.material_key);
  }
  if (high - low > STREET_VEGETATION_MAX_FOOT_SPREAD_M) return { problem: "uneven_foot" };
  return { rest_y: low, spread_m: high - low, materials: [...materials].sort() };
}

// Paving a tree may stand in only inside a round mulch cut-out (a tree pit), and
// how far the pit reaches beyond the foot (m). The pit is drawn flat on the
// plane that fits the paving under it, so that paving must be close to a plane.
const WELL_SURFACES = Object.freeze(["major_area_paved", "street_kerb_concrete", "street_plaza_pavers"]);
const WELL_MARGIN_M = 0.75;
const WELL_MAX_RESIDUAL_M = 0.012;
// The pit lies this far above the plane of the paving, clear of its decals.
export const STREET_VEGETATION_WELL_LIFT_M = 0.015;

// The plane y = height + slope_x * dx + slope_z * dz through the visible ground
// over a disc of radius r round xz (least squares over its foot samples), and
// how far the ground strays from it. Returns {height, slope, residual, materials} or null.
function groundPlane(xz, radius, groundAt) {
  const points = [];
  const materials = new Set();
  for (const ring of [0, 0.35, 0.7, 1.0]) {
    const count = ring === 0 ? 1 : 16;
    for (let index = 0; index < count; index += 1) {
      const angle = (Math.PI * 2 * index) / count;
      const dx = Math.cos(angle) * radius * ring;
      const dz = Math.sin(angle) * radius * ring;
      const ground = groundAt([xz[0] + dx, xz[1] + dz]);
      if (!ground) return null;
      points.push([dx, dz, ground.y]);
      materials.add(ground.material_key);
    }
  }
  // Least squares for y = a + b dx + c dz (the samples are symmetric round xz,
  // so the normal equations decouple).
  const n = points.length;
  const a = points.reduce((sum, [, , y]) => sum + y, 0) / n;
  const b = points.reduce((sum, [dx, , y]) => sum + dx * y, 0) / Math.max(1e-9, points.reduce((sum, [dx]) => sum + dx * dx, 0));
  const c = points.reduce((sum, [, dz, y]) => sum + dz * y, 0) / Math.max(1e-9, points.reduce((sum, [, dz]) => sum + dz * dz, 0));
  const residual = Math.max(...points.map(([dx, dz, y]) => Math.abs(y - (a + b * dx + c * dz))));
  return { height: a, slope: [b, c], residual, materials: [...materials].sort() };
}

// The prop block of a planted row: its kit prop, variant and scale, and its rest
// on the visible ground as lift_m, the offset from the row's y + surface bias
// to the foot. A tree whose foot reaches a sidewalk or paving stands in a round
// mulch pit well_m across (0 for none) on the plane of that paving: well_lift_m
// is the plane's height at the trunk over the foot, well_slope its rise per
// metre along +X and +Z. Returns {prop, prop_params} or {problem}.
export function plantRow({ prop, kind, variant, scale, xz, landY, surface, groundAt }) {
  const spec = STREET_VEGETATION_PROPS[prop];
  invariant(spec && spec.kinds.includes(kind), `Street vegetation prop ${prop} cannot stand in a ${kind} row`);
  const foot = spec.foot_m * scale;
  const rest = settlePlant(xz, foot, groundAt);
  if (rest.problem) return rest;
  const params = {
    variant,
    scale,
    lift_m: roundCoordinate(rest.rest_y - (landY + surface.bias_m)),
    foot_spread_m: roundCoordinate(rest.spread_m),
    well_m: 0,
  };
  if (kind !== "grass_clump" && rest.materials.some((material) => WELL_SURFACES.includes(material))) {
    const well = roundCoordinate(2 * (foot + WELL_MARGIN_M));
    const plane = groundPlane(xz, well / 2, groundAt);
    if (!plane || !plane.materials.every((material) => WELL_SURFACES.includes(material))) return { problem: "well_off_paving" };
    if (plane.residual > WELL_MAX_RESIDUAL_M) return { problem: "well_uneven" };
    params.well_m = well;
    params.well_lift_m = roundCoordinate(plane.height - rest.rest_y);
    params.well_slope = plane.slope.map((value) => Math.round(value * 1e5) / 1e5);
  }
  return { prop, prop_params: params };
}

// Bed stations: for the along_beds scatter pattern, the offsets across a way
// (from reach_m[0] to reach_m[1] on one side) inside the widest planting bed
// found there (ground of one of the rule's surfaces), at least inset from its
// edges, ordered from the bed's middle outward; [] when no bed there is
// min_bed_m wide. at(offset) maps an offset across the way to a world point;
// surfaceAt is the street-detail surface query.
const BED_STEP_M = 0.2;
const BED_TRY_STEP_M = 0.25;
export function bedOffsets(at, reach, minBed, surfaces, surfaceAt, inset) {
  let best = null;
  let start = null;
  const close = (end) => {
    if (start !== null && end - start >= minBed && (!best || end - start > best.end - best.start)) best = { start, end };
    start = null;
  };
  for (let offset = reach[0]; offset <= reach[1] + 1e-9; offset += BED_STEP_M) {
    const inside = surfaces.includes(surfaceAt(at(offset)).material_key);
    if (inside && start === null) start = offset;
    if (!inside) close(offset);
  }
  close(reach[1]);
  if (!best) return [];
  const middle = (best.start + best.end) / 2;
  const offsets = [middle];
  for (let step = BED_TRY_STEP_M; middle + step <= best.end - inset + 1e-9 || middle - step >= best.start + inset - 1e-9; step += BED_TRY_STEP_M) {
    if (middle - step >= best.start + inset - 1e-9) offsets.push(middle - step);
    if (middle + step <= best.end - inset + 1e-9) offsets.push(middle + step);
  }
  return offsets;
}
