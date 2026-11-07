// Street vegetation: the trees, grasses, perennials and shrubs of
// PlayableWorld/StreetDetail/Vegetation.
//
// A vegetation row is built when it carries a prop of the street-vegetation kit
// (game/scripts/world/street_vegetation_kit.gd, which keeps the same variant
// counts and foot radii as STREET_VEGETATION_PROPS). Props come from:
//   - zone scatter rules that name one (tools/config/street-detail-zones.json):
//     the Avenue of the Palms fan palms, the grass clumps of the mulch beds and
//     the planted beds of parks such as Cityside Park;
//   - set pieces (data/street_detail/set_pieces.json) where dated photos show
//     particular trees: Building 1's date palms, tall fan palms and cypresses,
//     the Waterfront Plaza's young cypresses;
//   - canopy rules, which plant the tree crowns read from the dated aerial
//     (data/street_detail/tree_crowns.json) with a mix of species whose crowns
//     fit: the island's housing, campus and industrial trees; hedge rules lay
//     that file's hedges along the walls.
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
// draws, the radius of the foot the generator settles (m) and whether the prop
// has a trunk. A trunk is solid (the kit gives it a capsule the player meets)
// and stands in a round mulch pit where its foot reaches paving; grasses,
// perennials and shrubs have neither. A species' variants run from its
// smallest (0) to its largest, so a rule picks a size class with [first, last];
// a drift variant packs several plants into one row: variant 3 of dense_sedge,
// blue_eyed_grass, seaside_daisy, sea_thrift, pacific_reedgrass, rush and
// bronze_clump_grass (about 1-2.5 m across) and variant 4 of dense_sedge (twelve
// tussocks, about 2.5 m); its plants' bases run 0.15 m into the ground, so a
// drift row may lie on a bed sloping up to about 10 %. clipped_hedge is not
// planted at a point: a hedge line row carries it with prop_params {variant,
// ground_y_m}, the visible ground's height under each of the line's points
// (the kit's hedge_into lays it there; its foot radius is half its depth).
const vegetationProp = (kinds, variants, footM, trunk) => Object.freeze({ kinds: Object.freeze(kinds), variants, foot_m: footM, trunk });
// Low plants stand in grass_clump rows (a 0.35 m footprint) or, spaced wider,
// in planting_slot rows (0.8 m).
const LOW_PLANT_KINDS = Object.freeze(["grass_clump", "planting_slot"]);
export const STREET_VEGETATION_PROPS = Object.freeze({
  blue_eyed_grass: vegetationProp(LOW_PLANT_KINDS, 4, 0.1, false),
  bronze_clump_grass: vegetationProp(LOW_PLANT_KINDS, 4, 0.18, false),
  california_buckwheat: vegetationProp(LOW_PLANT_KINDS, 3, 0.25, false),
  california_sagebrush: vegetationProp(LOW_PLANT_KINDS, 4, 0.3, false),
  canary_date_palm: vegetationProp(["palm_slot", "tree"], 7, 0.7, true),
  clipped_hedge: vegetationProp(["hedge"], 2, 0.45, false),
  clump_grass: vegetationProp(["grass_clump"], 8, 0.3, false),
  conical_shrub: vegetationProp(["planting_slot", "tree"], 2, 0.4, false),
  dense_sedge: vegetationProp(LOW_PLANT_KINDS, 5, 0.18, false),
  dune_tansy: vegetationProp(LOW_PLANT_KINDS, 3, 0.2, false),
  eucalyptus_mature: vegetationProp(["tree"], 2, 0.9, true),
  indian_hawthorn: vegetationProp(["planting_slot"], 3, 0.6, false),
  island_oak_young: vegetationProp(["tree"], 3, 0.3, true),
  mexican_fan_palm: vegetationProp(["palm_slot", "tree"], 6, 0.45, true),
  monterey_cypress: vegetationProp(["tree"], 5, 0.8, true),
  monterey_pine: vegetationProp(["tree"], 6, 0.6, true),
  norfolk_island_pine: vegetationProp(["tree"], 2, 0.2, true),
  nz_christmas_tree: vegetationProp(["tree"], 2, 0.5, true),
  nz_flax: vegetationProp(LOW_PLANT_KINDS, 3, 0.25, false),
  pacific_reedgrass: vegetationProp(LOW_PLANT_KINDS, 4, 0.25, false),
  pittosporum_tobira: vegetationProp(["planting_slot"], 3, 0.5, false),
  red_tip_shrub: vegetationProp(LOW_PLANT_KINDS, 2, 0.25, false),
  rush: vegetationProp(LOW_PLANT_KINDS, 6, 0.2, false),
  sea_thrift: vegetationProp(LOW_PLANT_KINDS, 4, 0.12, false),
  seaside_daisy: vegetationProp(LOW_PLANT_KINDS, 4, 0.2, false),
  seaside_woolly_sunflower: vegetationProp(LOW_PLANT_KINDS, 3, 0.3, false),
  seep_monkeyflower: vegetationProp(LOW_PLANT_KINDS, 3, 0.15, false),
  shrubby_sage: vegetationProp(LOW_PLANT_KINDS, 3, 0.3, false),
  spreading_broadleaf: vegetationProp(["tree"], 4, 0.7, true),
  weeping_broadleaf: vegetationProp(["tree"], 2, 0.5, true),
  sydney_blue_gum_young: vegetationProp(["tree"], 3, 0.3, true),
  white_umbel_perennial: vegetationProp(LOW_PLANT_KINDS, 3, 0.15, false),
  pale_seeded_shrub: vegetationProp(LOW_PLANT_KINDS, 6, 0.2, false),
  marsh_stems: vegetationProp(LOW_PLANT_KINDS, 2, 0.15, false),
  marsh_mat: vegetationProp(LOW_PLANT_KINDS, 2, 0.2, false),
  marsh_brush: vegetationProp(LOW_PLANT_KINDS, 2, 0.2, false),
  marsh_fringe: vegetationProp(LOW_PLANT_KINDS, 3, 0.2, false),
  marsh_stones: vegetationProp(LOW_PLANT_KINDS, 3, 0.15, false),
  young_planting: vegetationProp(LOW_PLANT_KINDS, 4, 0.2, false),
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
// The Johnson St lot's own ground is listed for its foot's sake: a lot takes no pits
// (it is unplantable too), so a trunk with a foot on it finds no well and stands off it.
const WELL_SURFACES = Object.freeze(["major_area_paved", "street_kerb_concrete", "street_kerb_lot", "street_plaza_pavers", "yard_asphalt_fresh", "yard_shoulder_band", "yard_shoulder_gravel"]);
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
// to the foot. A prop with a trunk whose foot reaches a sidewalk or paving stands in a round
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
  if (spec.trunk && rest.materials.some((material) => WELL_SURFACES.includes(material))) {
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

// Tree crowns and hedges read from the dated aerial, by group: {groups: {group:
// [[x, z, crown_m], ...]}, hedges: {group: [[[x, z], [x, z]], ...]}}.
export const TREE_CROWNS_SCHEMA = "ti.tree-crowns/1";
export function validateTreeCrowns(document) {
  invariant(document?.schema_version === TREE_CROWNS_SCHEMA, "Tree crowns schema drift");
  invariant(document.groups != null && typeof document.groups === "object" && !Array.isArray(document.groups), "Tree crowns need groups");
  for (const [group, crowns] of Object.entries(document.groups)) {
    invariant(Array.isArray(crowns) && crowns.length > 0 && crowns.every((crown) => Array.isArray(crown) && crown.length === 3 && crown.every(isFiniteNumber) && crown[2] > 0),
      `Tree crown group ${group} must list [x, z, crown_m]`);
  }
  invariant(Array.isArray(document.pins), "Tree crowns need pins");
  for (const [index, pin] of document.pins.entries()) {
    const label = `Tree crown pin ${index}`;
    invariant(JSON.stringify(Object.keys(pin).sort()) === JSON.stringify(PIN_FIELDS), `${label} must be exactly {${PIN_FIELDS.join(", ")}}`);
    invariant(Array.isArray(pin.at_xz) && pin.at_xz.length === 2 && pin.at_xz.every(isFiniteNumber) && isFiniteNumber(pin.reach_m) && pin.reach_m > 0 && pin.reach_m <= 10, `${label} needs at_xz and a reach_m up to 10`);
    invariant(typeof pin.evidence === "string" && pin.evidence.trim() !== "", `${label} needs its evidence`);
    invariant(CANOPY_CROWNS_M[pin.prop] != null, `${label}: ${pin.prop} has no canopy crown widths`);
    validateVegetationRuleParams(pin.prop, { variants: pin.variants, scale: [0.8, 1.25] }, label);
    for (let variant = pin.variants[0]; variant <= pin.variants[1]; variant += 1) {
      invariant(CANOPY_CROWNS_M[pin.prop][variant] != null, `${label}: ${pin.prop} variant ${variant} is not a canopy form`);
    }
  }
  invariant(document.hedges != null && typeof document.hedges === "object" && !Array.isArray(document.hedges), "Tree crowns need hedges");
  for (const [group, lines] of Object.entries(document.hedges)) {
    invariant(Array.isArray(lines) && lines.length > 0 && lines.every((line) => Array.isArray(line) && line.length >= 2 && line.every((point) => Array.isArray(point) && point.length === 2 && point.every(isFiniteNumber))),
      `Hedge group ${group} must list lines of [x, z] points`);
  }
  return document;
}

// The crown width (m) of each kit variant a canopy rule may plant (the kit's
// spread or crown), null for a form no canopy rule draws.
const CANOPY_CROWNS_M = Object.freeze({
  canary_date_palm: Object.freeze([6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 5.5]),
  mexican_fan_palm: Object.freeze([null, null, null, null, 5.0, 5.5]),
  eucalyptus_mature: Object.freeze([15.0, 18.0]),
  island_oak_young: Object.freeze([2.5, 2.0, 3.4]),
  monterey_cypress: Object.freeze([17.0, 12.5, null, null, null]),
  monterey_pine: Object.freeze([8.5, 10.0, 11.2, 7.2, 8.2, 8.6]),
  nz_christmas_tree: Object.freeze([7.0, 8.0]),
  spreading_broadleaf: Object.freeze([8.0, 10.0, 15.0, 17.5]),
  weeping_broadleaf: Object.freeze([9.5, 11.2]),
});
// How much further from a crown's width than the closest variant another may be
// and still take its turn, so a stand of one crown size isn't all one model.
const CANOPY_VARIANT_SLACK = 0.25;
const CANOPY_ENTRY_FIELDS = Object.freeze(["prop", "scale", "share", "variants"]);
const PIN_FIELDS = Object.freeze(["at_xz", "evidence", "prop", "reach_m", "variants"]);

// A canopy rule's mix: entries {prop, share, variants: [first, last], scale: [low, high]}.
export function validateCanopyMix(mix, label) {
  invariant(Array.isArray(mix) && mix.length > 0, `${label} needs a mix`);
  mix.forEach((entry, index) => {
    const entryLabel = `${label} mix ${index}`;
    invariant(entry != null && JSON.stringify(Object.keys(entry).sort()) === JSON.stringify(CANOPY_ENTRY_FIELDS), `${entryLabel} must be exactly {prop, scale, share, variants}`);
    invariant(CANOPY_CROWNS_M[entry.prop], `${entryLabel}: ${entry.prop} has no canopy crown widths`);
    invariant(isFiniteNumber(entry.share) && entry.share > 0, `${entryLabel} share must be positive`);
    validateVegetationRuleParams(entry.prop, { variants: entry.variants, scale: entry.scale }, entryLabel);
    for (let variant = entry.variants[0]; variant <= entry.variants[1]; variant += 1) {
      invariant(CANOPY_CROWNS_M[entry.prop][variant] != null, `${entryLabel}: ${entry.prop} variant ${variant} is not a canopy form`);
    }
  });
}

// The tree for a crown crownM wide: each entry's closest variant at the scale
// that best fits the crown, among the entries that come within fit of its width
// (a fraction) the rule's shares pick one by the row identity; failing that, the
// entry that comes closest. Returns {prop, variant, scale}.
export function drawCanopyTree(seed, identity, crownM, mix, fit) {
  const options = mix.map((entry) => {
    const forms = [];
    for (let variant = entry.variants[0]; variant <= entry.variants[1]; variant += 1) {
      const width = CANOPY_CROWNS_M[entry.prop][variant];
      const scale = Math.min(entry.scale[1], Math.max(entry.scale[0], crownM / width));
      forms.push({ prop: entry.prop, variant, scale, miss: Math.abs(width * scale - crownM) / crownM, share: entry.share });
    }
    const closest = Math.min(...forms.map((form) => form.miss));
    const turns = forms.filter((form) => form.miss <= closest + CANOPY_VARIANT_SLACK);
    return { ...turns[Math.floor(hashUnit(seed, `${identity}:${entry.prop}`, 2) * turns.length)], miss: closest };
  });
  const fitting = options.filter((option) => option.miss <= fit);
  const pool = fitting.length > 0 ? fitting : [options.reduce((closest, option) => (option.miss < closest.miss ? option : closest))];
  let pick = hashUnit(seed, identity, 3) * pool.reduce((sum, option) => sum + option.share, 0);
  const chosen = pool.find((option) => {
    pick -= option.share;
    return pick <= 0;
  }) ?? pool[pool.length - 1];
  return { prop: chosen.prop, variant: chosen.variant, scale: roundCoordinate(chosen.scale) };
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
