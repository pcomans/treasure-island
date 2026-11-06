// Naturalistic planting: the "drifts" and "fill" scatter patterns of
// tools/config/street-detail-zones.json, for park beds laid out like a designed
// planting a year or two after install rather than a nursery grid.
//
// A zone's planting rules share one planting state and run in config order, so a
// bed is built in layers: trees, then drifts of shrubs and grasses, then
// groundcover filled into the bare ground left between them.
//   - drifts: drift centres at irregular spacing (blue noise about drift_m apart
//     whose radius wanders with a smooth noise); each takes one species of the
//     mix by share and plants a group of count plants of it round the centre,
//     within spread x sqrt(count) of the species' half width. A plant keeps
//     spacing.same times the summed half widths from plants of its own species
//     and spacing.other from every other plant, so crowns overlap and drifts
//     interlock at ragged edges;
//   - fill: groundcover into the bare bed, trying the largest variant first,
//     until the plants cover `cover` of the bed (each plant covering a disc of
//     COVER_FACTOR times its width) or max_per_m2 is reached; a plant keeps a
//     factor times the summed half widths from every plant, the factor wandering
//     between spacing[0] (dense patches whose mats merge) and spacing[1] (open
//     ones) with a smooth noise about clump_m across. The species come in patches
//     about drift_m across with ragged edges (the nearest of a jittered lattice
//     of seeds, each with a species by share, to a noise-displaced point), with
//     MIX_RATIO of the plants drawn from the whole mix so the patches intermix;
//   - field: plants sown over ground that was never laid out as a bed (a ditch's
//     bank, a scruffy strip), by a density field that reads the site. Candidates
//     fall at random over the zone, per_m2 of them, with no lattice, so nothing
//     lines up from any angle; each survives with the field's value there. The
//     field is the land's height (a trapezoid, height_m), a band of distances from
//     the land's edge or the nearest road (edge_m, road_m), distance from a site's
//     axis (axis), ramps across the site (ramps), and clusters from two octaves of rotated, warped noise: drift_cover
//     of the ground lies in drifts about drift_m across with clumps about clump_m
//     across inside them, and lone plants stand at lone of the density outside
//     them. The same value picks the plant: a mix entry grows where the field lies
//     in its `at` range, and a plant's scale rises with the field through that
//     range. A plant keeps a factor times the summed half widths from every plant,
//     spacing[0] where the field is full, spacing[1] where it is thin. The field
//     may also read the land's slope (slope: [none, full], so a band keeps to a
//     bank and off the flat), and groups {count, spread_m} sows tight groups: each
//     candidate that survives is a group's centre, with plants fallen round it in
//     a bell curve, most groups small and a few large, so real gaps lie between;
//   - gaps: drifts and fill leave the bed bare where a smooth noise at gaps.scale_m
//     falls below gaps.cover, so small irregular patches of mulch show;
//   - margin_m: a rule plants the bed within that distance outside its traced
//     polygon too, so zones traced to a few metres still reach the paths and
//     each other (the shared state keeps overlapping rules apart);
//   - band_m keeps a species within a band of distances from the bed edge (tall
//     plants inward, low ones along the paths), spill_m lets a single plant's
//     crown reach that far past the edge over soft ground, mulch, gravel or lawn
//     (its centre stays EDGE_CLEAR_M inside the bed), and max_slope keeps it off
//     steeper ground. A drift variant, several plants in one row that is settled
//     as one, keeps its whole drift on the bed (its centre half the drift's width
//     at the rule's largest scale inside) and stays on ground flatter than
//     DRIFT_ROW_MAX_SLOPE;
//   - paving: no crown, nor a drift's whole width, comes within PAVING_CLEAR_M
//     of a walking or driving surface (any visible ground but SPILL_GROUNDS:
//     sidewalks, roads, paths, plazas), so nothing grows out over a sidewalk.
// Every draw is seeded from the world seed, the zone and the rule, so the world
// generator stays deterministic. The plants' widths are the street-vegetation
// kit's (game/scripts/world/street_vegetation_kit.gd). Positions, mixes and
// sizes are production inference; each rule names its dated evidence. World
// x, z throughout, z = -north as in street detail.

import { createHash } from "node:crypto";

import { invariant, roundCoordinate } from "./world-contract.mjs";

// The visual crown width of each kit variant (m), in the kit's variant order, for
// spacing, cover, bed edges and paving: the kit's widths, and for a drift variant
// the drift's width as the kit's owner gives it (2026-11-04). A tree's is the clear
// ground round its trunk that low plants keep (a young tree's crown overhangs them;
// an old cypress shades a wide ring). clump_grass, the streets' mulch-bed grass,
// takes its widths from the kit's GRASSES. DRIFT_VARIANTS are the variants that
// hold a drift of several plants in one row.
export const PLANT_WIDTHS_M = Object.freeze({
  blue_eyed_grass: Object.freeze([0.22, 0.28, 0.34, 0.6]),
  bronze_clump_grass: Object.freeze([0.5, 0.62, 0.75, 1.6]),
  california_buckwheat: Object.freeze([0.65, 0.95, 1.25]),
  california_sagebrush: Object.freeze([0.75, 1.1, 1.45, 1.0]),
  clipped_hedge: Object.freeze([1.0, 1.2]),
  clump_grass: Object.freeze([0.92, 1.15, 1.0, 1.25, 1.0, 1.25]),
  conical_shrub: Object.freeze([2.0, 2.4]),
  dense_sedge: Object.freeze([0.55, 0.75, 0.95, 1.6, 2.5]),
  dune_tansy: Object.freeze([0.42, 0.62, 0.82]),
  eucalyptus_mature: Object.freeze([3.0, 3.4]),
  indian_hawthorn: Object.freeze([2.0, 2.5, 3.0]),
  island_oak_young: Object.freeze([1.0, 1.2, 1.4]),
  monterey_cypress: Object.freeze([17.0, 12.5, 2.0, 1.4, 1.1]),
  monterey_pine: Object.freeze([4.0, 5.0, 6.0, 3.0, 3.6, 4.2]),
  norfolk_island_pine: Object.freeze([2.0, 2.4]),
  nz_christmas_tree: Object.freeze([3.0, 3.4]),
  nz_flax: Object.freeze([1.4, 1.7, 2.0]),
  pacific_reedgrass: Object.freeze([0.85, 1.05, 1.3, 2.2]),
  pale_seeded_shrub: Object.freeze([0.7, 1.0, 1.1]),
  pittosporum_tobira: Object.freeze([1.5, 2.0, 2.5]),
  red_tip_shrub: Object.freeze([0.7, 0.9]),
  rush: Object.freeze([0.45, 0.6, 0.75, 1.5, 0.85, 1.05]),
  sea_thrift: Object.freeze([0.24, 0.32, 0.4, 1.1]),
  seaside_daisy: Object.freeze([0.55, 0.8, 1.05, 1.9]),
  seaside_woolly_sunflower: Object.freeze([0.8, 1.15, 1.5]),
  seep_monkeyflower: Object.freeze([0.38, 0.52, 0.66]),
  shrubby_sage: Object.freeze([0.6, 0.85, 1.1]),
  spreading_broadleaf: Object.freeze([3.0, 3.6, 4.4, 5.0]),
  weeping_broadleaf: Object.freeze([2.5, 2.5]),
  sydney_blue_gum_young: Object.freeze([0.8, 0.8, 0.8]),
  white_umbel_perennial: Object.freeze([0.32, 0.42, 0.52]),
});
const DRIFT_VARIANTS = Object.freeze({
  blue_eyed_grass: Object.freeze([3]),
  bronze_clump_grass: Object.freeze([3]),
  dense_sedge: Object.freeze([3, 4]),
  pacific_reedgrass: Object.freeze([3]),
  rush: Object.freeze([3]),
  sea_thrift: Object.freeze([3]),
  seaside_daisy: Object.freeze([3]),
});
// A drift variant's plants run 0.15 m into the ground, so its row may lie on a
// bed this steep (street_vegetation_kit.gd).
export const DRIFT_ROW_MAX_SLOPE = 0.1;
// How far inside its bed's edge a single plant's centre stays (m).
const EDGE_CLEAR_M = 0.1;
// The visible ground a low plant's crown may spill over: mulch, gravel, lawn,
// the streets' planting strips and grass verges, bare land, the grassy area
// overlays and natural shore. Any other ground is paving, a walking or driving
// surface (sidewalks and curb ramps, plaza paving, roads with their paint and
// parking lanes, paths, the parks' paved paths and plazas, parking lots,
// piers), that no crown reaches over; so is any ground added later until it is
// listed here.
export const SPILL_GROUNDS = Object.freeze([
  "land_ground", "major_area_amenity", "major_area_landuse", "major_area_leisure", "park_gravel", "park_lawn", "park_mulch",
  "street_kerb_planting", "street_kerb_verge", "terrain_riprap", "terrain_sand", "terrain_wetland",
]);
const SPILL = new Set(SPILL_GROUNDS);
// How far a low plant's crown, or a drift's whole width, keeps clear of paving (m).
export const PAVING_CLEAR_M = 0.1;
// pavingUnder's sample rings: [fraction of the radius, points].
const PAVING_RINGS = Object.freeze([[0.5, 12], [1, 24]]);
// A plant covers a disc of this times its width (0.9 of its half width).
const COVER_FACTOR = 0.45;
// The cover raster's cell (m) and the plant index's cell.
const COVER_CELL_M = 0.25;
const PLANT_CELL_M = 2.0;
// The share of a fill's plants drawn from the whole mix rather than their patch.
const MIX_RATIO = 0.12;

export const PLANTING_RULE_FIELDS = Object.freeze({
  drifts: Object.freeze(["basis", "count", "drift_m", "evidence", "gaps", "id", "kind", "margin_m", "mix", "pattern", "rule", "spacing", "spread", "surfaces", "within_xz"]),
  fill: Object.freeze(["basis", "clump_m", "cover", "drift_m", "evidence", "gaps", "id", "kind", "margin_m", "max_per_m2", "mix", "pattern", "rule", "spacing", "surfaces", "within_xz"]),
  field: Object.freeze(["basis", "evidence", "field", "id", "kind", "mix", "pattern", "per_m2", "rule", "spacing", "surfaces"]),
});
const MIX_FIELDS = Object.freeze(["band_m", "max_slope", "prop", "scale", "share", "spill_m", "variants"]);
const FIELD_MIX_FIELDS = Object.freeze(["at", "prop", "scale", "share", "variants"]);
const FIELD_TERMS = Object.freeze(["axis", "clump_m", "drift_cover", "drift_m", "edge_m", "groups", "height_m", "lone", "ramps", "road_m", "slope"]);
// A field plant's crown test: its rings, close enough to find a kerb's narrow top.
const FIELD_PAVING_RINGS = Object.freeze([[0.25, 8], [0.5, 16], [0.75, 24], [1, 32]]);

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

const exactKeys = (value, fields) => JSON.stringify(Object.keys(value ?? {}).sort()) === JSON.stringify([...fields].sort());

// Validates a drifts or fill rule; checkProp(prop, kind, params, label) checks a
// mix entry's prop, variants and scale against the street-vegetation kit, and
// variantCount(prop) gives the kit's number of variants.
export function validatePlantingRule(rule, label, checkProp, variantCount) {
  if (rule.pattern === "field") {
    validateFieldRule(rule, label, checkProp, variantCount);
    return;
  }
  const fields = PLANTING_RULE_FIELDS[rule.pattern];
  invariant(fields && exactKeys(rule, fields), `${label}: a ${rule.pattern} rule has exactly ${fields?.join(", ")}`);
  invariant(Array.isArray(rule.within_xz) && rule.within_xz.length >= 3 && rule.within_xz.every((point) => Array.isArray(point) && point.length === 2 && point.every(isFiniteNumber)), `${label} within_xz must be a polygon of 3+ [x, z] points`);
  invariant(Array.isArray(rule.surfaces) && rule.surfaces.length > 0 && rule.surfaces.every((key) => typeof key === "string" && key !== ""), `${label} surfaces must list the bed's material keys`);
  invariant(exactKeys(rule.gaps, ["cover", "scale_m"]) && isFiniteNumber(rule.gaps.cover) && rule.gaps.cover >= 0 && rule.gaps.cover < 0.5 && isFiniteNumber(rule.gaps.scale_m) && rule.gaps.scale_m > 0, `${label} gaps must be {cover in [0, 0.5), scale_m > 0}`);
  invariant(isFiniteNumber(rule.drift_m) && rule.drift_m >= 1, `${label} drift_m must be at least 1`);
  invariant(isFiniteNumber(rule.margin_m) && rule.margin_m >= 0 && rule.margin_m <= 12, `${label} margin_m must be in [0, 12]`);
  if (rule.pattern === "drifts") {
    invariant(Array.isArray(rule.count) && rule.count.length === 2 && rule.count.every(Number.isInteger) && rule.count[0] >= 1 && rule.count[1] >= rule.count[0] && rule.count[1] <= 30, `${label} count must be [fewest, most] plants per drift, 1-30`);
    invariant(isFiniteNumber(rule.spread) && rule.spread >= 0.5 && rule.spread <= 5, `${label} spread must be in [0.5, 5]`);
    invariant(exactKeys(rule.spacing, ["other", "same"]) && [rule.spacing.same, rule.spacing.other].every((value) => isFiniteNumber(value) && value >= 0.3 && value <= 2), `${label} spacing must be {same, other} factors in [0.3, 2]`);
  } else {
    invariant(isFiniteNumber(rule.cover) && rule.cover > 0 && rule.cover <= 0.95, `${label} cover must be in (0, 0.95]`);
    invariant(isFiniteNumber(rule.max_per_m2) && rule.max_per_m2 > 0 && rule.max_per_m2 <= 4, `${label} max_per_m2 must be in (0, 4]`);
    invariant(Array.isArray(rule.spacing) && rule.spacing.length === 2 && rule.spacing.every((value) => isFiniteNumber(value) && value >= 0.2 && value <= 2) && rule.spacing[0] <= rule.spacing[1], `${label} spacing must be [dense, open] factors in [0.2, 2]`);
    invariant(isFiniteNumber(rule.clump_m) && rule.clump_m > 0, `${label} clump_m must be positive`);
  }
  invariant(rule.basis === "production_inference", `${label} basis must be production_inference`);
  for (const field of ["rule", "evidence"]) invariant(typeof rule[field] === "string" && rule[field].trim() !== "", `${label} needs ${field}`);
  invariant(Array.isArray(rule.mix) && rule.mix.length > 0, `${label} needs a mix`);
  for (const [index, entry] of rule.mix.entries()) {
    const entryLabel = `${label} mix ${index} (${entry?.prop})`;
    invariant(exactKeys(entry, MIX_FIELDS), `${entryLabel} must have exactly ${MIX_FIELDS.join(", ")}`);
    checkProp(entry.prop, rule.kind, { variants: entry.variants, scale: entry.scale }, entryLabel);
    invariant(PLANT_WIDTHS_M[entry.prop]?.length === variantCount(entry.prop), `${entryLabel} needs a crown width for each of the kit's variants (PLANT_WIDTHS_M)`);
    invariant(isFiniteNumber(entry.share) && entry.share > 0, `${entryLabel} share must be positive`);
    invariant(Array.isArray(entry.band_m) && entry.band_m.length === 2 && entry.band_m.every(isFiniteNumber) && entry.band_m[0] >= 0 && entry.band_m[1] > entry.band_m[0], `${entryLabel} band_m must be [near, far] metres from the bed edge`);
    invariant(isFiniteNumber(entry.max_slope) && entry.max_slope > 0, `${entryLabel} max_slope must be positive (rise per metre)`);
    invariant(isFiniteNumber(entry.spill_m) && entry.spill_m >= 0 && entry.spill_m <= 0.6, `${entryLabel} spill_m must be in [0, 0.6]`);
  }
}

// A field rule's own fields; its within_xz is optional (the zone's shape bounds it).
function validateFieldRule(rule, label, checkProp, variantCount) {
  const fields = [...PLANTING_RULE_FIELDS.field, ...("within_xz" in rule ? ["within_xz"] : [])];
  invariant(exactKeys(rule, fields), `${label}: a field rule has exactly ${fields.join(", ")}`);
  if (rule.within_xz !== undefined) {
    invariant(Array.isArray(rule.within_xz) && rule.within_xz.length >= 3 && rule.within_xz.every((point) => Array.isArray(point) && point.length === 2 && point.every(isFiniteNumber)), `${label} within_xz must be a polygon of 3+ [x, z] points`);
  }
  invariant(Array.isArray(rule.surfaces) && rule.surfaces.length > 0 && rule.surfaces.every((key) => typeof key === "string" && key !== ""), `${label} surfaces must list materials`);
  invariant(isFiniteNumber(rule.per_m2) && rule.per_m2 > 0 && rule.per_m2 <= 4, `${label} per_m2 must be in (0, 4]`);
  invariant(Array.isArray(rule.spacing) && rule.spacing.length === 2 && rule.spacing.every((value) => isFiniteNumber(value) && value >= 0.2 && value <= 4) && rule.spacing[0] <= rule.spacing[1], `${label} spacing must be [full, thin] factors in [0.2, 4]`);
  const field = rule.field;
  invariant(field != null && Object.keys(field).every((key) => FIELD_TERMS.includes(key)), `${label} field may hold ${FIELD_TERMS.join(", ")}`);
  invariant(isFiniteNumber(field.drift_m) && field.drift_m >= 1, `${label} field drift_m must be at least 1`);
  invariant(isFiniteNumber(field.clump_m) && field.clump_m >= 0.5 && field.clump_m <= field.drift_m, `${label} field clump_m must be in [0.5, drift_m]`);
  invariant(isFiniteNumber(field.drift_cover) && field.drift_cover > 0 && field.drift_cover < 1, `${label} field drift_cover must be in (0, 1)`);
  invariant(isFiniteNumber(field.lone) && field.lone >= 0 && field.lone < 1, `${label} field lone must be in [0, 1)`);
  if (field.height_m !== undefined) {
    invariant(Array.isArray(field.height_m) && field.height_m.length === 4 && field.height_m.every(isFiniteNumber) && field.height_m.every((value, index, all) => index === 0 || value >= all[index - 1]), `${label} field height_m must be four rising heights`);
  }
  for (const band of ["edge_m", "road_m"]) {
    if (field[band] === undefined) continue;
    invariant(Array.isArray(field[band]) && field[band].length === 2 && field[band].every(isFiniteNumber) && field[band][0] >= 0 && field[band][1] > field[band][0], `${label} field ${band} must be [near, far] metres`);
  }
  if (field.slope !== undefined) {
    invariant(Array.isArray(field.slope) && field.slope.length === 2 && field.slope.every(isFiniteNumber) && field.slope[0] >= 0 && field.slope[1] > field.slope[0], `${label} field slope must be [none, full] rise per metre`);
  }
  if (field.groups !== undefined) {
    const { groups } = field;
    invariant(exactKeys(groups, ["count", "spread_m"]) && Array.isArray(groups.count) && groups.count.length === 2 && groups.count.every(Number.isInteger) && groups.count[0] >= 1 && groups.count[1] >= groups.count[0]
      && Array.isArray(groups.spread_m) && groups.spread_m.length === 2 && groups.spread_m.every(isFiniteNumber) && groups.spread_m[0] > 0 && groups.spread_m[1] >= groups.spread_m[0], `${label} field groups must be {count: [low, high], spread_m: [low, high]}`);
  }
  if (field.axis !== undefined) {
    const { axis } = field;
    invariant(exactKeys(axis, ["from_xz", "full_m", "to_xz", "zero_m"]) && [axis.from_xz, axis.to_xz].every((point) => Array.isArray(point) && point.length === 2 && point.every(isFiniteNumber)) && isFiniteNumber(axis.full_m) && isFiniteNumber(axis.zero_m) && axis.full_m >= 0 && axis.zero_m > axis.full_m, `${label} field axis must be {from_xz, to_xz, full_m, zero_m}`);
  }
  for (const ramp of field.ramps ?? []) {
    invariant(exactKeys(ramp, ["from_xz", "high", "low", "to_xz"]) && [ramp.from_xz, ramp.to_xz].every((point) => Array.isArray(point) && point.length === 2 && point.every(isFiniteNumber)) && isFiniteNumber(ramp.low) && isFiniteNumber(ramp.high) && ramp.low >= 0 && ramp.high <= 1 && ramp.low <= ramp.high, `${label} field ramps must be {from_xz, to_xz, low, high}`);
  }
  invariant(rule.basis === "production_inference", `${label} basis must be production_inference`);
  for (const text of ["rule", "evidence"]) invariant(typeof rule[text] === "string" && rule[text].trim() !== "", `${label} needs ${text}`);
  invariant(Array.isArray(rule.mix) && rule.mix.length > 0, `${label} needs a mix`);
  for (const [index, entry] of rule.mix.entries()) {
    const entryLabel = `${label} mix ${index} (${entry?.prop})`;
    invariant(exactKeys(entry, FIELD_MIX_FIELDS), `${entryLabel} must have exactly ${FIELD_MIX_FIELDS.join(", ")}`);
    checkProp(entry.prop, rule.kind, { variants: entry.variants, scale: entry.scale }, entryLabel);
    invariant(PLANT_WIDTHS_M[entry.prop]?.length === variantCount(entry.prop), `${entryLabel} needs a crown width for each of the kit's variants (PLANT_WIDTHS_M)`);
    invariant(isFiniteNumber(entry.share) && entry.share > 0, `${entryLabel} share must be positive`);
    invariant(Array.isArray(entry.at) && entry.at.length === 2 && entry.at.every(isFiniteNumber) && entry.at[0] >= 0 && entry.at[1] <= 1 && entry.at[0] < entry.at[1], `${entryLabel} at must be a field range in [0, 1]`);
  }
}

// A small seeded generator (mulberry32).
function generator(seedText) {
  let state = createHash("sha256").update(seedText, "utf8").digest().readUInt32BE(0);
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = state;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Smooth value noise in [0, 1] on a lattice of the given scale (metres).
function valueNoise(seedText) {
  const lattice = new Map();
  const at = (i, j) => {
    const key = `${i},${j}`;
    if (!lattice.has(key)) lattice.set(key, createHash("sha256").update(`${seedText}|${key}`, "utf8").digest().readUInt32BE(0) / 0xffffffff);
    return lattice.get(key);
  };
  const smooth = (t) => t * t * (3 - 2 * t);
  return (x, z, scale) => {
    const u = x / scale;
    const v = z / scale;
    const i = Math.floor(u);
    const j = Math.floor(v);
    const fu = smooth(u - i);
    const fv = smooth(v - j);
    return (at(i, j) * (1 - fu) + at(i + 1, j) * fu) * (1 - fv) + (at(i, j + 1) * (1 - fu) + at(i + 1, j + 1) * fu) * fv;
  };
}

function pointInPolygon(point, ring) {
  let inside = false;
  for (let index = 0, previous = ring.length - 1; index < ring.length; previous = index, index += 1) {
    const [xi, zi] = ring[index];
    const [xj, zj] = ring[previous];
    if ((zi > point[1]) !== (zj > point[1]) && point[0] < ((xj - xi) * (point[1] - zi)) / (zj - zi) + xi) inside = !inside;
  }
  return inside;
}

function ringDistance(point, ring) {
  let best = Infinity;
  for (let index = 0, previous = ring.length - 1; index < ring.length; previous = index, index += 1) {
    const [ax, az] = ring[previous];
    const [bx, bz] = ring[index];
    const dx = bx - ax;
    const dz = bz - az;
    const t = Math.max(0, Math.min(1, ((point[0] - ax) * dx + (point[1] - az) * dz) / Math.max(1e-12, dx * dx + dz * dz)));
    best = Math.min(best, Math.hypot(point[0] - (ax + dx * t), point[1] - (az + dz * t)));
  }
  return best;
}

// Whether a point lies in a rule's polygon or within its margin outside it.
function inRule(rule, point) {
  return pointInPolygon(point, rule.within_xz) || (rule.margin_m > 0 && ringDistance(point, rule.within_xz) <= rule.margin_m);
}

// The box of a rule's polygon grown by its margin.
function ruleBox(rule) {
  const xs = rule.within_xz.map((point) => point[0]);
  const zs = rule.within_xz.map((point) => point[1]);
  const margin = rule.margin_m;
  return { min_x: Math.min(...xs) - margin, max_x: Math.max(...xs) + margin, min_z: Math.min(...zs) - margin, max_z: Math.max(...zs) + margin };
}

function pickByShare(unit, entries) {
  const total = entries.reduce((sum, entry) => sum + entry.share, 0);
  let walk = unit * total;
  for (const entry of entries) {
    walk -= entry.share;
    if (walk <= 0) return entry;
  }
  return entries.at(-1);
}

// A low plant's crown radius (m): its kit variant's width (PLANT_WIDTHS_M; a
// drift variant's, the whole drift's) at its scale.
export function crownRadius(prop, variant, scale) {
  const width = PLANT_WIDTHS_M[prop]?.[variant];
  invariant(width !== undefined, `No crown width for ${prop} variant ${variant}`);
  return (width * scale) / 2;
}

// The paving (any visible ground but SPILL_GROUNDS) that a disc of the given
// radius round xz reaches, or null: groundAt is the street-vegetation
// visible-ground query (visibleGroundIndex of street-clutter-generation.mjs),
// sampled at the centre and on rings of [fraction of the radius, points]. Where
// there is no visible ground (off the land), there is no paving.
export function pavingUnder(xz, radius, groundAt, rings = PAVING_RINGS) {
  const paving = (point) => {
    const material = groundAt(point)?.material_key;
    return material === undefined || SPILL.has(material) ? null : material;
  };
  let found = paving(xz);
  for (const [fraction, points] of rings) {
    for (let index = 0; index < points && found === null; index += 1) {
      const angle = (2 * Math.PI * index) / points;
      found = paving([xz[0] + Math.cos(angle) * radius * fraction, xz[1] + Math.sin(angle) * radius * fraction]);
    }
  }
  return found;
}

// The plants a zone's planting rules have placed so far, with their widths, and
// the ground they cover. A zone's rules share one.
export function plantingState() {
  return { plants: new Map(), covered: new Set() };
}

function nearbyPlants(state, x, z, reach) {
  const found = [];
  const steps = Math.ceil(reach / PLANT_CELL_M);
  const ci = Math.floor(x / PLANT_CELL_M);
  const cj = Math.floor(z / PLANT_CELL_M);
  for (let di = -steps; di <= steps; di += 1) {
    for (let dj = -steps; dj <= steps; dj += 1) {
      for (const plant of state.plants.get(`${ci + di},${cj + dj}`) ?? []) found.push(plant);
    }
  }
  return found;
}

// Whether a plant of `prop` with half width `half` may stand at x, z: it keeps
// same x the summed half widths from its own species and other x them from the rest.
function fits(state, prop, half, x, z, same, other) {
  for (const plant of nearbyPlants(state, x, z, half + 9)) {
    const limit = (plant.prop === prop ? same : other) * (half + plant.half);
    if (Math.hypot(plant.x - x, plant.z - z) < limit) return false;
  }
  return true;
}

// Records a placed plant and returns the cover cells it newly covers.
function addPlant(state, prop, half, x, z) {
  const key = `${Math.floor(x / PLANT_CELL_M)},${Math.floor(z / PLANT_CELL_M)}`;
  if (!state.plants.has(key)) state.plants.set(key, []);
  state.plants.get(key).push({ prop, half, x, z });
  const radius = COVER_FACTOR * 2 * half;
  const fresh = [];
  for (let i = Math.floor((x - radius) / COVER_CELL_M); i <= Math.floor((x + radius) / COVER_CELL_M); i += 1) {
    for (let j = Math.floor((z - radius) / COVER_CELL_M); j <= Math.floor((z + radius) / COVER_CELL_M); j += 1) {
      const cellKey = `${i},${j}`;
      if (state.covered.has(cellKey)) continue;
      if (Math.hypot((i + 0.5) * COVER_CELL_M - x, (j + 0.5) * COVER_CELL_M - z) > radius) continue;
      state.covered.add(cellKey);
      fresh.push(cellKey);
    }
  }
  return fresh;
}

// What both patterns share: the seeded draws, the gap noise, and the test of a
// species' variant at a point (band, spill, slope, spacing, paving), which
// returns its candidate or null.
function plantingContext({ rule, zoneId, seed, bed, slopeAt, paving }) {
  const tag = `${seed}|${zoneId}|${rule.id}`;
  const gapNoise = valueNoise(`${tag}|gaps`);
  const hashUnit = (text, slot = 0) => createHash("sha256").update(`${tag}|${text}`, "utf8").digest().readUInt32BE(slot * 4) / 0xffffffff;
  const inGap = (x, z) => gapNoise(x, z, rule.gaps.scale_m) < rule.gaps.cover;
  const rejected = {};
  const reject = (reason) => {
    rejected[reason] = (rejected[reason] ?? 0) + 1;
    return null;
  };
  // where = bed(point), slope = slopeAt(point); spacing [same, other].
  const tryVariant = ({ entry, variant, point, where, slope, identity, state, spacing }) => {
    const scale = roundCoordinate(entry.scale[0] + (entry.scale[1] - entry.scale[0]) * hashUnit(`${identity}:scale`));
    const half = (PLANT_WIDTHS_M[entry.prop][variant] * scale) / 2;
    // A drift keeps its whole width on the bed; a single plant's crown may spill.
    const drift = DRIFT_VARIANTS[entry.prop]?.includes(variant);
    const inside = drift ? (PLANT_WIDTHS_M[entry.prop][variant] * entry.scale[1]) / 2 : Math.max(half - entry.spill_m, EDGE_CLEAR_M);
    if (where.distance < Math.max(entry.band_m[0], inside) || where.distance > entry.band_m[1]) return reject("band");
    if (slope > entry.max_slope || (drift && slope > DRIFT_ROW_MAX_SLOPE)) return reject("slope");
    if (!fits(state, entry.prop, half, point[0], point[1], spacing[0], spacing[1])) return reject("spacing");
    if (paving(point, (drift ? (PLANT_WIDTHS_M[entry.prop][variant] * entry.scale[1]) / 2 : half) + PAVING_CLEAR_M)) return reject("paving");
    return { xz: [roundCoordinate(point[0]), roundCoordinate(point[1])], prop: entry.prop, variant, scale, half, identity };
  };
  return { tag, hashUnit, inGap, rejected, reject, tryVariant, bed, slopeAt };
}

// Places a drifts rule's plants. bed(xz) gives {on, distance} (whether a point
// lies on the rule's bed and how far it is from the bed's edge), onBed(xz) the
// "on" alone, cheaply; paving(xz, radius) the paving a disc there reaches, or
// null (pavingUnder). accept(candidate) runs the site's own checks and builds
// the row, returning whether it did; candidate is {xz, prop, variant, scale,
// identity}. Returns {placed, centres, rejected}.
export function planDrifts({ rule, zoneId, seed, bed, onBed, slopeAt, paving, state, accept }) {
  const context = plantingContext({ rule, zoneId, seed, bed, slopeAt, paving });
  const { tag, hashUnit, inGap, reject, tryVariant } = context;
  const random = generator(`${tag}|centres`);
  const spacingNoise = valueNoise(`${tag}|spacing`);
  const box = ruleBox(rule);

  // Drift centres: blue noise whose radius wanders, on the bed and out of the gaps.
  const centres = [];
  const attempts = Math.ceil((((box.max_x - box.min_x) * (box.max_z - box.min_z)) / (rule.drift_m * rule.drift_m)) * 8);
  for (let attempt = 0; attempt < attempts; attempt += 1) {
    const point = [box.min_x + random() * (box.max_x - box.min_x), box.min_z + random() * (box.max_z - box.min_z)];
    if (!inRule(rule, point)) continue;
    const radius = rule.drift_m * (0.75 + 0.5 * spacingNoise(point[0], point[1], rule.drift_m * 1.5));
    if (centres.some((centre) => Math.hypot(centre.point[0] - point[0], centre.point[1] - point[1]) < Math.min(radius, centre.radius))) continue;
    if (inGap(point[0], point[1]) || !onBed(point)) continue;
    centres.push({ point, radius });
  }

  let placed = 0;
  for (const [index, centre] of centres.entries()) {
    const where = bed(centre.point);
    const slope = slopeAt(centre.point);
    const allowed = rule.mix.filter((entry) => where.distance >= entry.band_m[0] && where.distance <= entry.band_m[1] && slope <= entry.max_slope);
    if (allowed.length === 0) {
      reject("centre");
      continue;
    }
    const entry = pickByShare(hashUnit(`centre:${index}`), allowed);
    const count = rule.count[0] + Math.min(rule.count[1] - rule.count[0], Math.floor(hashUnit(`centre:${index}`, 1) * (rule.count[1] - rule.count[0] + 1)));
    const [first, last] = entry.variants;
    const widths = PLANT_WIDTHS_M[entry.prop].slice(first, last + 1);
    const meanHalf = (widths.reduce((sum, width) => sum + width, 0) / widths.length) * ((entry.scale[0] + entry.scale[1]) / 2) / 2;
    const reach = count === 1 ? 0 : rule.spread * Math.sqrt(count) * meanHalf;
    let grown = 0;
    for (let attempt = 0; attempt < count * 30 && grown < count; attempt += 1) {
      const identity = `d${String(index).padStart(4, "0")}t${String(attempt).padStart(3, "0")}`;
      const angle = hashUnit(identity, 0) * Math.PI * 2;
      const distance = reach * Math.sqrt(hashUnit(identity, 1));
      const point = [centre.point[0] + Math.cos(angle) * distance, centre.point[1] + Math.sin(angle) * distance];
      if (!inRule(rule, point)) {
        reject("outside");
        continue;
      }
      if (inGap(point[0], point[1])) {
        reject("gap");
        continue;
      }
      if (!onBed(point)) {
        reject("off_bed");
        continue;
      }
      const pointWhere = bed(point);
      const variant = Math.min(last, first + Math.floor(hashUnit(`${identity}:variant`) * (last - first + 1)));
      const candidate = tryVariant({ entry, variant, point, where: pointWhere, slope: slopeAt(point), identity, state, spacing: [rule.spacing.same, rule.spacing.other] });
      if (!candidate || !accept(candidate)) continue;
      addPlant(state, candidate.prop, candidate.half, point[0], point[1]);
      grown += 1;
      placed += 1;
    }
  }
  return { placed, centres: centres.length, rejected: context.rejected };
}

// Places a fill rule's groundcover into the bare bed until the plants cover
// rule.cover of it or rule.max_per_m2 is reached. Arguments and result as
// planDrifts; the result also gives the cover reached.
export function planFill({ rule, zoneId, seed, bed, onBed, slopeAt, paving, state, accept }) {
  const context = plantingContext({ rule, zoneId, seed, bed, slopeAt, paving });
  const { tag, hashUnit, inGap, reject, tryVariant } = context;
  const random = generator(`${tag}|cells`);
  const spacingNoise = valueNoise(`${tag}|spacing`);
  const warpX = valueNoise(`${tag}|warp-x`);
  const warpZ = valueNoise(`${tag}|warp-z`);
  const box = ruleBox(rule);
  // The species patches: the seeds nearest a noise-displaced point, nearest first.
  const seeds = new Map();
  const seedAt = (i, j) => {
    const id = `${i},${j}`;
    if (!seeds.has(id)) {
      seeds.set(id, {
        x: (i + 0.15 + 0.7 * hashUnit(`seed:${id}`, 0)) * rule.drift_m,
        z: (j + 0.15 + 0.7 * hashUnit(`seed:${id}`, 1)) * rule.drift_m,
        unit: hashUnit(`seed:${id}`, 2),
        id,
      });
    }
    return seeds.get(id);
  };
  const patchSeeds = (x, z) => {
    const ragged = 0.35 * rule.drift_m;
    const wx = x + (warpX(x, z, rule.drift_m * 0.8) - 0.5) * 2 * ragged;
    const wz = z + (warpZ(x, z, rule.drift_m * 0.8) - 0.5) * 2 * ragged;
    const i = Math.floor(wx / rule.drift_m);
    const j = Math.floor(wz / rule.drift_m);
    const seeds = [];
    for (let di = -1; di <= 1; di += 1) for (let dj = -1; dj <= 1; dj += 1) seeds.push(seedAt(i + di, j + dj));
    return seeds.sort((left, right) => Math.hypot(left.x - wx, left.z - wz) - Math.hypot(right.x - wx, right.z - wz) || left.id.localeCompare(right.id));
  };
  const speciesAt = (point, allowed, identity) => {
    if (hashUnit(`${identity}:mix`) < MIX_RATIO) return pickByShare(hashUnit(`${identity}:species`), allowed);
    for (const patch of patchSeeds(point[0], point[1])) {
      const entry = pickByShare(patch.unit, rule.mix);
      if (allowed.includes(entry)) return entry;
    }
    return pickByShare(hashUnit(`${identity}:species`), allowed);
  };

  // The bed's cover cells inside the rule's polygon, in a seeded order.
  const cells = [];
  for (let i = Math.floor(box.min_x / COVER_CELL_M); i <= Math.floor(box.max_x / COVER_CELL_M); i += 1) {
    for (let j = Math.floor(box.min_z / COVER_CELL_M); j <= Math.floor(box.max_z / COVER_CELL_M); j += 1) {
      const point = [(i + 0.5) * COVER_CELL_M, (j + 0.5) * COVER_CELL_M];
      if (inRule(rule, point) && onBed(point)) cells.push(`${i},${j}`);
    }
  }
  const bedCells = new Set(cells);
  for (let index = cells.length - 1; index > 0; index -= 1) {
    const swap = Math.floor(random() * (index + 1));
    [cells[index], cells[swap]] = [cells[swap], cells[index]];
  }
  let covered = cells.reduce((sum, key) => sum + (state.covered.has(key) ? 1 : 0), 0);
  let placed = 0;
  const most = Math.ceil(rule.max_per_m2 * cells.length * COVER_CELL_M * COVER_CELL_M);
  const done = () => covered >= rule.cover * cells.length || placed >= most;

  for (let pass = 0; pass < 2 && !done(); pass += 1) {
    for (const key of cells) {
      if (done()) break;
      if (state.covered.has(key)) continue;
      const [i, j] = key.split(",").map(Number);
      const identity = `f${pass}c${key}`;
      const point = [(i + hashUnit(identity, 0)) * COVER_CELL_M, (j + hashUnit(identity, 1)) * COVER_CELL_M];
      if (inGap(point[0], point[1])) {
        reject("gap");
        continue;
      }
      if (!onBed(point)) {
        reject("off_bed");
        continue;
      }
      const where = bed(point);
      const slope = slopeAt(point);
      const allowed = rule.mix.filter((entry) => where.distance >= entry.band_m[0] && where.distance <= entry.band_m[1] && slope <= entry.max_slope);
      if (allowed.length === 0) {
        reject("band");
        continue;
      }
      const entry = speciesAt(point, allowed, identity);
      const factor = rule.spacing[0] + (rule.spacing[1] - rule.spacing[0]) * spacingNoise(point[0], point[1], rule.clump_m);
      // The largest variant that fits first, so the bed fills with few rows.
      for (let variant = entry.variants[1]; variant >= entry.variants[0]; variant -= 1) {
        const candidate = tryVariant({ entry, variant, point, where, slope, identity, state, spacing: [factor, factor] });
        if (!candidate) continue;
        if (!accept(candidate)) break;
        for (const fresh of addPlant(state, candidate.prop, candidate.half, point[0], point[1])) {
          if (bedCells.has(fresh)) covered += 1;
        }
        placed += 1;
        break;
      }
    }
  }
  return { placed, cells: cells.length, cover: cells.length === 0 ? 0 : roundCoordinate(covered / cells.length), rejected: context.rejected };
}

// ---- compact planting rows
// A park's drifts and fill rules place thousands of small plants. In
// generated/world/street_detail.json their rows are kept as compact blocks under
// planting_rows, one per rule: what the rule's rows share (the id prefix, kind,
// source id, and the lists of props, surfaces, land records and zone sets they
// index) and one array per row in PLANTING_ROW_FIELDS order, the row's number in
// the block giving its id. unpackPlantingRows, and its twin in
// game/scripts/world/generated_world_contract.gd, expand them back into the
// usual rows, merged in id order, before anything validates or builds them.
export const PLANTING_ROWS_SCHEMA = "ti.street-detail-planting-rows/1";
export const PLANTING_ROW_FIELDS = Object.freeze([
  "prop", "variant", "x", "y", "z", "yaw_radians", "scale", "lift_m", "foot_spread_m", "surface", "land", "triangle_index", "zones",
]);
const PACKED_ROW_KEYS = JSON.stringify([
  "exclusion", "geometry", "id", "kind", "layer", "position_m", "prop", "prop_params", "source", "source_id", "status", "surface", "terrain_support", "yaw_radians", "yaw_source", "zones",
]);
const PACKED_PARAM_KEYS = JSON.stringify(["foot_spread_m", "lift_m", "scale", "variant", "well_m"]);
const ROW_NUMBER_DIGITS = 5;

const rowId = (prefix, index) => `${prefix}${String(index).padStart(ROW_NUMBER_DIGITS, "0")}`;
// JSON text with every object's keys in order, for comparing rows.
const stableText = (value) => JSON.stringify(value, (key, entry) => (entry && typeof entry === "object" && !Array.isArray(entry)
  ? Object.fromEntries(Object.keys(entry).sort().map((name) => [name, entry[name]]))
  : entry));

// The row a block's array stands for.
function unpackedRow(block, values) {
  const [prop, variant, x, y, z, yaw, scale, lift, spread, surface, land, triangle, zones] = values;
  return {
    exclusion: null,
    geometry: "point",
    kind: block.kind,
    layer: "vegetation",
    position_m: [x, y, z],
    prop: block.props[prop],
    prop_params: { foot_spread_m: spread, lift_m: lift, scale, variant, well_m: 0 },
    source: "scatter",
    source_id: block.source_id,
    status: "placed",
    surface: block.surfaces[surface],
    terrain_support: { elevation_m: y, object_key: block.lands[land], triangle_index: triangle },
    yaw_radians: yaw,
    yaw_source: "seeded",
    zones: block.zones[zones],
  };
}

// Splits sorted rows into those kept whole and the compact blocks of the rules
// whose source ids are given ("zone:<zone>/<rule>"). A rule whose rows do not all
// fit the block form (an excluded row, a tree in a paving pit, a gap in the
// numbering) keeps them whole. Every packed row must unpack to itself.
export function packPlantingRows(rows, sourceIds) {
  const groups = new Map();
  for (const row of rows) {
    if (!sourceIds.has(row.source_id)) continue;
    if (!groups.has(row.source_id)) groups.set(row.source_id, []);
    groups.get(row.source_id).push(row);
  }
  const packed = new Set();
  const blocks = [];
  for (const [sourceId, group] of [...groups.entries()].sort(([left], [right]) => (left < right ? -1 : left > right ? 1 : 0))) {
    const [zone, rule] = sourceId.slice("zone:".length).split("/");
    const prefix = `scatter:${zone}:${rule}:p`;
    const fits = group.every((row, index) => JSON.stringify(Object.keys(row).sort()) === PACKED_ROW_KEYS
      && row.id === rowId(prefix, index) && row.status === "placed" && row.exclusion === null && row.geometry === "point"
      && row.layer === "vegetation" && row.source === "scatter" && row.yaw_source === "seeded" && row.kind === group[0].kind
      && JSON.stringify(Object.keys(row.prop_params).sort()) === PACKED_PARAM_KEYS && row.prop_params.well_m === 0
      && row.terrain_support.elevation_m === row.position_m[1]);
    if (!fits) continue;
    const block = { id_prefix: prefix, kind: group[0].kind, source_id: sourceId, props: [], surfaces: [], lands: [], zones: [], rows: [] };
    const indexOf = (list, value) => {
      const key = JSON.stringify(value);
      let index = list.findIndex((entry) => JSON.stringify(entry) === key);
      if (index < 0) index = list.push(value) - 1;
      return index;
    };
    for (const row of group) {
      const values = [
        indexOf(block.props, row.prop), row.prop_params.variant, ...row.position_m, row.yaw_radians, row.prop_params.scale,
        row.prop_params.lift_m, row.prop_params.foot_spread_m, indexOf(block.surfaces, row.surface),
        indexOf(block.lands, row.terrain_support.object_key), row.terrain_support.triangle_index, indexOf(block.zones, row.zones),
      ];
      invariant(stableText({ ...unpackedRow(block, values), id: row.id }) === stableText(row), `Planting row ${row.id} does not survive packing`);
      block.rows.push(values);
      packed.add(row);
    }
    blocks.push(block);
  }
  return {
    rows: rows.filter((row) => !packed.has(row)),
    planting_rows: { schema_version: PLANTING_ROWS_SCHEMA, fields: PLANTING_ROW_FIELDS, blocks },
  };
}

// A street-detail document with its compact planting blocks expanded into rows,
// in id order; a document without them is returned as it is.
export function unpackPlantingRows(document) {
  if (document.planting_rows === undefined) return document;
  const packed = document.planting_rows;
  invariant(packed?.schema_version === PLANTING_ROWS_SCHEMA && JSON.stringify(packed.fields) === JSON.stringify(PLANTING_ROW_FIELDS) && Array.isArray(packed.blocks) && Array.isArray(document.rows), "Street-detail planting rows are malformed");
  const rows = [...document.rows];
  for (const block of packed.blocks) {
    invariant(["id_prefix", "kind", "source_id"].every((field) => typeof block?.[field] === "string") && ["props", "surfaces", "lands", "zones", "rows"].every((field) => Array.isArray(block[field])), "Street-detail planting block is malformed");
    block.rows.forEach((values, index) => {
      const id = rowId(block.id_prefix, index);
      invariant(Array.isArray(values) && values.length === PLANTING_ROW_FIELDS.length && values.every(isFiniteNumber), `Street-detail planting row ${id} is malformed`);
      const [prop, , , , , , , , , surface, land, , zones] = values;
      invariant([[prop, block.props], [surface, block.surfaces], [land, block.lands], [zones, block.zones]].every(([index, list]) => Number.isInteger(index) && index >= 0 && index < list.length), `Street-detail planting row ${id} indexes a missing entry`);
      rows.push({ ...unpackedRow(block, values), id });
    });
  }
  rows.sort((left, right) => (left.id < right.id ? -1 : left.id > right.id ? 1 : 0));
  const { planting_rows: _packed, ...rest } = document;
  return { ...rest, rows };
}

const smoothRamp = (from, to, value) => {
  const t = Math.max(0, Math.min(1, (value - from) / Math.max(1e-9, to - from)));
  return t * t * (3 - 2 * t);
};

// The density of a field rule at a point, in [0, 1]: site is {height, edge, road},
// each the site's reading there or undefined for a term the rule does not use.
function fieldDensity(rule, tag) {
  const spec = rule.field;
  const drift = valueNoise(`${tag}|field-drift`);
  const clump = valueNoise(`${tag}|field-clump`);
  const warpX = valueNoise(`${tag}|field-warp-x`);
  const warpZ = valueNoise(`${tag}|field-warp-z`);
  // The value noise's lattices turn away from the axes and from each other, and a
  // warp bends what is left of them, so no drift's edge runs straight.
  const turned = (x, z, angle) => [x * Math.cos(angle) - z * Math.sin(angle), x * Math.sin(angle) + z * Math.cos(angle)];
  const level = 0.5 + (0.5 - spec.drift_cover) * 0.55;
  return (x, z, site) => {
    const reach = 0.45 * spec.drift_m;
    const wx = x + (warpX(x, z, spec.drift_m * 1.3) - 0.5) * 2 * reach;
    const wz = z + (warpZ(x, z, spec.drift_m * 1.3) - 0.5) * 2 * reach;
    const [ax, az] = turned(wx, wz, 0.61);
    const [bx, bz] = turned(wx, wz, 1.27);
    const noise = 0.62 * drift(ax, az, spec.drift_m) + 0.38 * clump(bx, bz, spec.clump_m);
    const clumped = smoothRamp(level - 0.05, level + 0.09, noise);
    let density = spec.lone + (1 - spec.lone) * clumped;
    if (spec.height_m) {
      const [riseFrom, riseTo, fallFrom, fallTo] = spec.height_m;
      density *= smoothRamp(riseFrom, riseTo, site.height) * (1 - smoothRamp(fallFrom, fallTo, site.height));
    }
    if (spec.slope) density *= smoothRamp(spec.slope[0], spec.slope[1], site.slope);
    const lengthAlong = (from, to) => {
      const dx = to[0] - from[0];
      const dz = to[1] - from[1];
      return Math.max(0, Math.min(1, ((x - from[0]) * dx + (z - from[1]) * dz) / Math.max(1e-9, dx * dx + dz * dz)));
    };
    if (spec.axis) {
      const { from_xz: from, to_xz: to, full_m: full, zero_m: zero } = spec.axis;
      const t = lengthAlong(from, to);
      density *= 1 - smoothRamp(full, zero, Math.hypot(x - from[0] - t * (to[0] - from[0]), z - from[1] - t * (to[1] - from[1])));
    }
    for (const { from_xz: from, to_xz: to, low, high } of spec.ramps ?? []) density *= low + (high - low) * lengthAlong(from, to);
    return density;
  };
}

// Places a field rule's plants. box {min_x, max_x, min_z, max_z} bounds them;
// inside(xz) is the zone's and the rule's shape; onGround(xz) whether the visible
// ground is one of the rule's surfaces; heightAt(xz) the land's height, slopeAt(xz)
// its slope, edgeOk and roadOk(xz, [near, far]) whether a point lies in those bands;
// paving and accept as planDrifts. Returns {placed, rejected}.
export function planField({ rule, zoneId, seed, box, inside, onGround, heightAt, slopeAt, edgeOk, roadOk, paving, state, accept }) {
  const tag = `${seed}|${zoneId}|${rule.id}`;
  const random = generator(`${tag}|field`);
  const density = fieldDensity(rule, tag);
  const hashUnit = (text, slot = 0) => createHash("sha256").update(`${tag}|${text}`, "utf8").digest().readUInt32BE(slot * 4) / 0xffffffff;
  const rejected = {};
  const reject = (reason) => {
    rejected[reason] = (rejected[reason] ?? 0) + 1;
  };
  const spec = rule.field;
  // The field's value at a point the rule may plant, or null.
  const fieldAt = (point) => {
    if (!inside(point) || !onGround(point)) return null;
    if (spec.edge_m && !edgeOk(point, spec.edge_m)) return null;
    if (spec.road_m && !roadOk(point, spec.road_m)) return null;
    return density(point[0], point[1], { height: spec.height_m ? heightAt(point) : undefined, slope: spec.slope ? slopeAt(point) : undefined });
  };
  let placed = 0;
  const plant = (point, here, identity) => {
    const allowed = rule.mix.filter((entry) => here >= entry.at[0] && here <= entry.at[1]);
    if (allowed.length === 0) {
      reject("no_entry");
      return;
    }
    const entry = pickByShare(hashUnit(identity, 0), allowed);
    const [first, last] = entry.variants;
    const variant = Math.min(last, first + Math.floor(hashUnit(identity, 1) * (last - first + 1)));
    const grown = (here - entry.at[0]) / (entry.at[1] - entry.at[0]);
    const scale = roundCoordinate(entry.scale[0] + (entry.scale[1] - entry.scale[0]) * (0.65 * grown + 0.35 * hashUnit(identity, 2)));
    const half = (PLANT_WIDTHS_M[entry.prop][variant] * scale) / 2;
    const factor = rule.spacing[1] + (rule.spacing[0] - rule.spacing[1]) * here;
    if (!fits(state, entry.prop, half, point[0], point[1], factor, factor)) {
      reject("spacing");
      return;
    }
    if (paving(point, half + PAVING_CLEAR_M, FIELD_PAVING_RINGS)) {
      reject("paving");
      return;
    }
    const candidate = { xz: [roundCoordinate(point[0]), roundCoordinate(point[1])], prop: entry.prop, variant, scale, half, identity };
    if (!accept(candidate)) return;
    addPlant(state, candidate.prop, candidate.half, point[0], point[1]);
    placed += 1;
  };
  const attempts = Math.ceil((box.max_x - box.min_x) * (box.max_z - box.min_z) * rule.per_m2);
  for (let attempt = 0; attempt < attempts; attempt += 1) {
    const point = [box.min_x + random() * (box.max_x - box.min_x), box.min_z + random() * (box.max_z - box.min_z)];
    const roll = random();
    const here = fieldAt(point);
    if (here === null) continue;
    if (roll >= here) {
      reject("thin");
      continue;
    }
    const identity = `f${String(attempt).padStart(6, "0")}`;
    if (!spec.groups) {
      plant(point, here, identity);
      continue;
    }
    // A group: most small, a few large, its plants in a bell round its centre.
    const [fewest, most] = spec.groups.count;
    const count = fewest + Math.floor(hashUnit(identity, 3) ** 2 * (most - fewest + 1));
    const spread = spec.groups.spread_m[0] + (spec.groups.spread_m[1] - spec.groups.spread_m[0]) * hashUnit(identity, 4);
    for (let member = 0; member < count; member += 1) {
      const memberId = `${identity}m${member}`;
      const reach = member === 0 ? 0 : spread * Math.sqrt(-2 * Math.log(Math.max(1e-6, hashUnit(memberId, 5))));
      const angle = hashUnit(memberId, 6) * Math.PI * 2;
      const spot = [point[0] + Math.cos(angle) * reach, point[1] + Math.sin(angle) * reach];
      const there = fieldAt(spot);
      if (there === null || there <= 0) {
        reject("off_field");
        continue;
      }
      plant(spot, Math.max(there, here * 0.8), memberId);
    }
  }
  return { placed, rejected };
}
