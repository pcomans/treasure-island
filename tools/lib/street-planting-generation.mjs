// Naturalistic planting: the "drifts" scatter pattern of tools/config/street-detail-zones.json.
//
// A drifts rule fills a traced bed polygon (within_xz) with a seeded mix of kit
// props laid out like a planting a year after install, not a nursery grid:
//   - plants stand at irregular spacing (blue noise whose radius wanders with a
//     smooth noise), so there are no rows outside deliberate tree rows;
//   - density is uneven and a share of the bed (gaps.cover) is left as small
//     irregular open patches;
//   - each species grows in drifts about drift_m across whose edges are ragged
//     (the drift field is looked up at a noise-displaced point), and the mix's
//     shares set how much of the bed each species takes;
//   - every species draws from its whole size range;
//   - band_m keeps a species within a distance band from the bed's edge (low
//     mats along the paths, tall shrubs inward), max_slope keeps one off ground
//     steeper than that (drift rows, which are not settled plant by plant), and
//     spill_m lets low plants lean out over the bed edge onto the path margin.
// Positions, mixes and sizes are production inference; each rule names its
// dated evidence. World x, z throughout, z = -north as in street detail.

import { createHash } from "node:crypto";

import { invariant, roundCoordinate } from "./world-contract.mjs";

export const DRIFT_RULE_FIELDS = Object.freeze([
  "basis", "drift_m", "evidence", "gaps", "id", "kind", "mix", "pattern", "ragged_m", "rule", "spacing_m", "surfaces", "within_xz",
]);
const MIX_FIELDS = Object.freeze(["band_m", "max_slope", "prop", "scale", "share", "spill_m", "variants"]);

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

// Validates a drifts rule; checkProp(prop, kind, params, label) checks a mix
// entry's prop against the street-vegetation kit.
export function validateDriftRule(rule, label, checkProp) {
  invariant(JSON.stringify(Object.keys(rule).sort()) === JSON.stringify([...DRIFT_RULE_FIELDS].sort()), `${label}: a drifts rule has exactly ${DRIFT_RULE_FIELDS.join(", ")}`);
  invariant(Array.isArray(rule.within_xz) && rule.within_xz.length >= 3 && rule.within_xz.every((point) => Array.isArray(point) && point.length === 2 && point.every(isFiniteNumber)), `${label} within_xz must be a polygon of 3+ [x, z] points`);
  invariant(Array.isArray(rule.surfaces) && rule.surfaces.length > 0 && rule.surfaces.every((key) => typeof key === "string" && key !== ""), `${label} surfaces must list the bed's material keys`);
  invariant(isFiniteNumber(rule.spacing_m) && rule.spacing_m >= 0.3, `${label} spacing_m must be at least 0.3`);
  invariant(isFiniteNumber(rule.drift_m) && rule.drift_m >= rule.spacing_m, `${label} drift_m must be at least spacing_m`);
  invariant(isFiniteNumber(rule.ragged_m) && rule.ragged_m >= 0, `${label} ragged_m must be non-negative`);
  invariant(rule.gaps != null && JSON.stringify(Object.keys(rule.gaps).sort()) === JSON.stringify(["cover", "scale_m"]) && isFiniteNumber(rule.gaps.cover) && rule.gaps.cover >= 0 && rule.gaps.cover < 0.8 && isFiniteNumber(rule.gaps.scale_m) && rule.gaps.scale_m > 0, `${label} gaps must be {cover in [0, 0.8), scale_m > 0}`);
  invariant(rule.basis === "production_inference", `${label} basis must be production_inference`);
  for (const field of ["rule", "evidence"]) invariant(typeof rule[field] === "string" && rule[field].trim() !== "", `${label} needs ${field}`);
  invariant(Array.isArray(rule.mix) && rule.mix.length > 0, `${label} needs a mix`);
  for (const [index, entry] of rule.mix.entries()) {
    const entryLabel = `${label} mix ${index} (${entry?.prop})`;
    const keys = Object.keys(entry ?? {});
    const optional = keys.includes("stand_in_for") ? ["stand_in_for"] : [];
    invariant(JSON.stringify(keys.sort()) === JSON.stringify([...MIX_FIELDS, ...optional].sort()), `${entryLabel} must have exactly ${[...MIX_FIELDS, ...optional].join(", ")}`);
    checkProp(entry.prop, rule.kind, { variants: entry.variants, scale: entry.scale }, entryLabel);
    invariant(isFiniteNumber(entry.share) && entry.share > 0, `${entryLabel} share must be positive`);
    invariant(Array.isArray(entry.band_m) && entry.band_m.length === 2 && entry.band_m.every(isFiniteNumber) && entry.band_m[0] >= 0 && entry.band_m[1] > entry.band_m[0], `${entryLabel} band_m must be [near, far] metres from the bed edge`);
    invariant(isFiniteNumber(entry.max_slope) && entry.max_slope > 0, `${entryLabel} max_slope must be positive (rise per metre)`);
    invariant(isFiniteNumber(entry.spill_m) && entry.spill_m >= 0 && entry.spill_m <= 0.6, `${entryLabel} spill_m must be in [0, 0.6]`);
    if (optional.length > 0) invariant(typeof entry.stand_in_for === "string" && /^[a-z0-9_]+$/u.test(entry.stand_in_for), `${entryLabel} stand_in_for names the species this kit prop stands in for`);
  }
}

// A small seeded generator (mulberry32) for the blue-noise darts.
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

function ringArea(ring) {
  let doubled = 0;
  for (let index = 0; index < ring.length; index += 1) {
    const next = ring[(index + 1) % ring.length];
    doubled += ring[index][0] * next[1] - next[0] * ring[index][1];
  }
  return Math.abs(doubled) / 2;
}

// The candidate plants of a drifts rule: [{xz, prop, variant, scale, identity}].
// bed(xz) tells whether a world point lies on the rule's surfaces and how far it
// is from the bed's edge (inside or out): {on, distance}; slopeAt(xz) gives the
// ground's rise per metre there.
export function planDrifts({ rule, zoneId, seed, bed, slopeAt, footOf }) {
  const tag = `${seed}|${zoneId}|${rule.id}`;
  const random = generator(`${tag}|darts`);
  const spacingNoise = valueNoise(`${tag}|spacing`);
  const gapNoise = valueNoise(`${tag}|gaps`);
  const warpX = valueNoise(`${tag}|warp-x`);
  const warpZ = valueNoise(`${tag}|warp-z`);
  const ring = rule.within_xz;
  const xs = ring.map((point) => point[0]);
  const zs = ring.map((point) => point[1]);
  const box = { min_x: Math.min(...xs), max_x: Math.max(...xs), min_z: Math.min(...zs), max_z: Math.max(...zs) };
  const spacing = rule.spacing_m;

  // Blue-noise darts with a wandering radius: irregular, never gridded.
  const cell = spacing * 0.7;
  const grid = new Map();
  const accepted = [];
  const attempts = Math.ceil((ringArea(ring) / (spacing * spacing)) * 6);
  for (let attempt = 0; attempt < attempts; attempt += 1) {
    const point = [box.min_x + random() * (box.max_x - box.min_x), box.min_z + random() * (box.max_z - box.min_z)];
    if (!pointInPolygon(point, ring)) continue;
    const radius = spacing * (0.72 + 0.56 * spacingNoise(point[0], point[1], 3.5));
    const ci = Math.floor(point[0] / cell);
    const cj = Math.floor(point[1] / cell);
    const reach = Math.ceil((spacing * 1.3) / cell);
    let crowded = false;
    for (let di = -reach; di <= reach && !crowded; di += 1) {
      for (let dj = -reach; dj <= reach && !crowded; dj += 1) {
        for (const other of grid.get(`${ci + di},${cj + dj}`) ?? []) {
          if (Math.hypot(other.point[0] - point[0], other.point[1] - point[1]) < Math.min(radius, other.radius)) {
            crowded = true;
            break;
          }
        }
      }
    }
    if (crowded) continue;
    const entry = { point, radius, order: accepted.length };
    accepted.push(entry);
    const key = `${ci},${cj}`;
    if (!grid.has(key)) grid.set(key, []);
    grid.get(key).push(entry);
  }

  // Drift seeds on a jittered lattice; each takes a species by share.
  const totalShare = rule.mix.reduce((sum, entry) => sum + entry.share, 0);
  const pickByShare = (unit, entries) => {
    const total = entries.reduce((sum, entry) => sum + entry.share, 0);
    let walk = unit * total;
    for (const entry of entries) {
      walk -= entry.share;
      if (walk <= 0) return entry;
    }
    return entries.at(-1);
  };
  const hashUnit = (text, slot = 0) => createHash("sha256").update(`${tag}|${text}`, "utf8").digest().readUInt32BE(slot * 4) / 0xffffffff;
  const seedAt = (i, j) => {
    const id = `seed:${i},${j}`;
    return {
      x: (i + 0.15 + 0.7 * hashUnit(id, 0)) * rule.drift_m,
      z: (j + 0.15 + 0.7 * hashUnit(id, 1)) * rule.drift_m,
      unit: hashUnit(id, 2),
      id,
    };
  };
  const nearestSeeds = (x, z) => {
    const i = Math.floor(x / rule.drift_m);
    const j = Math.floor(z / rule.drift_m);
    const seeds = [];
    for (let di = -1; di <= 1; di += 1) for (let dj = -1; dj <= 1; dj += 1) seeds.push(seedAt(i + di, j + dj));
    return seeds.sort((left, right) => Math.hypot(left.x - x, left.z - z) - Math.hypot(right.x - x, right.z - z) || left.id.localeCompare(right.id));
  };

  const candidates = [];
  const rejected = {};
  const reject = (reason) => {
    rejected[reason] = (rejected[reason] ?? 0) + 1;
  };
  for (const { point, order } of accepted) {
    const identity = `p${String(order).padStart(5, "0")}`;
    if (gapNoise(point[0], point[1], rule.gaps.scale_m) < rule.gaps.cover) {
      reject("gap");
      continue;
    }
    const where = bed(point);
    // Off the bed only a plant that may spill onto the margin, close to the edge.
    const fits = (entry) => (where.on
      ? where.distance >= entry.band_m[0] && where.distance <= entry.band_m[1]
      : entry.spill_m > 0 && where.distance <= entry.spill_m && entry.band_m[0] === 0);
    const allowed = rule.mix.filter(fits);
    if (allowed.length === 0) {
      reject(where.on ? "band" : "off_bed");
      continue;
    }
    // The drift a point belongs to: the nearest seed of a displaced point, so
    // drift edges are ragged; the first seed whose species may stand here wins.
    const warped = [
      point[0] + (warpX(point[0], point[1], rule.drift_m * 0.8) - 0.5) * 2 * rule.ragged_m,
      point[1] + (warpZ(point[0], point[1], rule.drift_m * 0.8) - 0.5) * 2 * rule.ragged_m,
    ];
    let chosen = null;
    for (const seed of nearestSeeds(warped[0], warped[1])) {
      const entry = pickByShare(seed.unit, rule.mix);
      if (allowed.includes(entry)) {
        chosen = entry;
        break;
      }
    }
    chosen ??= pickByShare(hashUnit(`${identity}:fallback`), allowed);
    if (slopeAt(point) > chosen.max_slope) {
      reject("slope");
      continue;
    }
    const [first, last] = chosen.variants;
    const variant = Math.min(last, first + Math.floor(hashUnit(`${identity}:variant`) * (last - first + 1)));
    const scale = roundCoordinate(chosen.scale[0] + (chosen.scale[1] - chosen.scale[0]) * hashUnit(`${identity}:scale`));
    // The whole foot stays on the bed unless the plant may spill over its edge.
    if (where.on && chosen.spill_m === 0 && where.distance < footOf(chosen.prop) * scale) {
      reject("edge");
      continue;
    }
    candidates.push({ xz: [roundCoordinate(point[0]), roundCoordinate(point[1])], prop: chosen.prop, variant, scale, identity, share: chosen.share / totalShare });
  }
  return { candidates, darts: accepted.length, rejected };
}
