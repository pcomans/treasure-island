// Ground-cover map: a world-space RGBA map of recipe weights that the shared
// ground-cover shader (game/resources/materials/world/ground_cover/
// ground_cover.gdshader) reads on every ground-cover family
// (game/scripts/world/ground_cover.gd). Each channel is the weight of one
// recipe family drawn over the record's own mix: red the maintained lawn,
// green the dry straw, blue the drier, barer field, alpha bare fill soil.
// Where every weight is 0 the record keeps its family; the weights never sum
// past 1.
//
// The rules (tools/config/ground-cover.json) say where each recipe applies:
// on the cells whose top drawn ground is a given OSM area or surface (every
// rule names one, so a rule never reaches other records; a surface rule may be
// narrowed to the surface drawn inside some areas, such as the kerb verges over
// the residential grounds), inside a traced polygon, or near buildings, roads and
// lots. Each names its dated aerial or photo evidence; widths, distances and
// traced outlines are production inference, not survey data. Drawn cells off
// the ruled ground (roads, paths, kerb tops and paint, roofs, lots, and kerb
// verges no rule drew on) then take the weights of the nearest ruled cell: an
// unruled verge matches the ground behind it, and the texture's filtering and
// mipmaps never blend a lawn or straw edge toward the record's own family at a
// road or wall; cells with no generated ground (the shoreline's shoulder, the
// water) keep none. The map
// is drawn from the generated world's records, so it follows the drawn
// buildings and roads; tools/build_ground_cover_map.mjs writes it, and so does
// tools/build_godot_world.mjs each time it writes the committed generated/world;
// tools/check_godot_world_determinism.mjs checks the committed copy against a
// fresh draw. World x, z (+X east, +Z south), metres.

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { deflateSync, inflateSync } from "node:zlib";

import { invariant } from "./world-contract.mjs";

export const GROUND_COVER_SCHEMA = "ti.ground-cover/1";
export const GROUND_COVER_CONFIG_PATH = "tools/config/ground-cover.json";
export const GROUND_COVER_MAP_PATH = "game/resources/textures/world/ground_cover/cover_map.png";
// The marsh's plan for the ground shader: signed distance from the outline of the
// terrain_wetland overlay, on the cover map's grid. Grey 0.5 lies on the outline,
// and MARSH_MAP_RANGE_M inside it is white, as far outside it black.
export const MARSH_MAP_PATH = "game/resources/textures/world/ground_cover/marsh_map.png";
export const MARSH_MAP_RANGE_M = 32;
// Map channels in RGBA order: the recipe family each one draws.
export const GROUND_COVER_CHANNELS = Object.freeze(["lawn", "straw", "dry_field", "bare"]);
// What a rule may measure distance from ("near"): generated record kinds.
export const GROUND_COVER_NEAR_KINDS = Object.freeze(["building", "vehicle_road", "paved_area", "street_kerb"]);
// The ground the rules draw on: material keys of land, areas, the ground-cover
// overlays and the street ground's planted kerb verges (street_kerb_verge, the
// grass strips behind kerbs). Other drawn cells take the weights of the nearest
// cell of this ground, and so does a kerb verge no rule draws on.
export const GROUND_COVER_SURFACES = Object.freeze(["land_ground", "major_area_amenity", "major_area_landuse", "major_area_leisure", "street_kerb_verge", "terrain_riprap", "terrain_sand", "terrain_wetland"]);
const SAFE_ID = /^[a-z0-9_]+$/u;
const RULE_FIELDS = Object.freeze(["basis", "channel", "evidence", "feather_m", "id", "inside_sources", "near", "reason", "surfaces", "weight", "within_sources", "within_xz"]);

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

function isXZ(value) {
  return Array.isArray(value) && value.length === 2 && value.every(isFiniteNumber);
}

function validateRange(value, label) {
  invariant(value != null && typeof value === "object" && !Array.isArray(value)
    && isFiniteNumber(value.full_m) && isFiniteNumber(value.zero_m) && value.full_m >= 0 && value.zero_m > value.full_m,
  `${label} needs full_m >= 0 below zero_m`);
}

export function validateGroundCoverConfig(config) {
  invariant(config?.schema_version === GROUND_COVER_SCHEMA, "Ground-cover config schema drift");
  invariant(Array.isArray(config.notes) && config.notes.every((note) => typeof note === "string"), "Ground-cover config needs notes");
  const map = config.map;
  invariant(map != null && isXZ(map.origin_xz) && isXZ(map.size_m) && isFiniteNumber(map.cell_m) && map.cell_m > 0, "Ground-cover map needs origin_xz, size_m and cell_m");
  for (const size of map.size_m) invariant(size > 0 && Number.isInteger(size / map.cell_m), "Ground-cover map size must be a whole number of cells");
  invariant(Array.isArray(config.rules) && config.rules.length > 0, "Ground-cover config needs rules");
  const ids = new Set();
  for (const rule of config.rules) {
    const label = `Ground-cover rule ${rule?.id}`;
    invariant(typeof rule?.id === "string" && SAFE_ID.test(rule.id) && !ids.has(rule.id), `${label} needs a unique lower_snake id`);
    ids.add(rule.id);
    invariant(Object.keys(rule).every((key) => RULE_FIELDS.includes(key)), `${label} has an unknown field`);
    invariant(GROUND_COVER_CHANNELS.includes(rule.channel), `${label} channel must be one of ${GROUND_COVER_CHANNELS.join(", ")}`);
    invariant(rule.basis === "production_inference", `${label} basis must be production_inference`);
    for (const field of ["reason", "evidence"]) invariant(typeof rule[field] === "string" && rule[field].trim() !== "", `${label} needs ${field}`);
    // The map is read by every ground-cover family, so each rule names the ground it may draw on.
    invariant(rule.within_sources != null || rule.surfaces != null, `${label} needs within_sources or surfaces`);
    if (rule.weight != null) invariant(isFiniteNumber(rule.weight) && rule.weight > 0 && rule.weight <= 1, `${label} weight must be in (0, 1]`);
    if (rule.within_sources != null) {
      invariant(Array.isArray(rule.within_sources) && rule.within_sources.length > 0 && rule.within_sources.every((key) => /^[wr]\d+$/u.test(key)), `${label} within_sources must list OSM area keys`);
    }
    if (rule.surfaces != null) {
      invariant(Array.isArray(rule.surfaces) && rule.surfaces.length > 0 && rule.surfaces.every((key) => GROUND_COVER_SURFACES.includes(key)),
        `${label} surfaces must list ground material keys: ${GROUND_COVER_SURFACES.join(", ")}`);
    }
    // inside_sources reaches surfaces drawn over an area (a kerb verge over the
    // residential grounds), so it only narrows a surfaces rule.
    if (rule.inside_sources != null) {
      invariant(Array.isArray(rule.inside_sources) && rule.inside_sources.length > 0 && rule.inside_sources.every((key) => /^[wr]\d+$/u.test(key)), `${label} inside_sources must list OSM area keys`);
      invariant(rule.surfaces != null, `${label}: inside_sources goes with surfaces`);
    }
    if (rule.within_xz != null) {
      invariant(Array.isArray(rule.within_xz) && rule.within_xz.length >= 3 && rule.within_xz.every(isXZ), `${label} within_xz must be a polygon of 3+ [x, z] points`);
      invariant(isFiniteNumber(rule.feather_m) && rule.feather_m >= 0, `${label} within_xz needs a feather_m >= 0`);
    } else {
      invariant(rule.feather_m == null, `${label}: feather_m goes with within_xz`);
    }
    if (rule.near != null) {
      validateRange(rule.near, `${label} near`);
      invariant(Array.isArray(rule.near.kinds) && rule.near.kinds.length > 0 && rule.near.kinds.every((kind) => GROUND_COVER_NEAR_KINDS.includes(kind)),
        `${label} near.kinds must list ${GROUND_COVER_NEAR_KINDS.join(", ")}`);
      invariant(["full_m,kinds,zero_m", "full_m,kinds,wobble_m,zero_m"].includes(Object.keys(rule.near).sort().join(",")), `${label} near must be {kinds, full_m, zero_m} with an optional wobble_m`);
      if (rule.near.wobble_m != null) invariant(isFiniteNumber(rule.near.wobble_m) && rule.near.wobble_m > 0 && rule.near.wobble_m <= rule.near.full_m, `${label} near wobble_m must be in (0, full_m]`);
    }
  }
  return config;
}

export function loadGroundCoverConfig(projectRoot) {
  return validateGroundCoverConfig(JSON.parse(readFileSync(resolve(projectRoot, GROUND_COVER_CONFIG_PATH), "utf8")));
}

// The map grid: cell (i, j) is centred at (x0 + (i + 0.5) cell, z0 + (j + 0.5) cell);
// rows run from north (-Z) to south, like the image's rows.
export function groundCoverGrid(config) {
  const [x0, z0] = config.map.origin_xz;
  const cell = config.map.cell_m;
  const width = Math.round(config.map.size_m[0] / cell);
  const height = Math.round(config.map.size_m[1] / cell);
  return { x0, z0, cell, width, height, centerX: (i) => x0 + (i + 0.5) * cell, centerZ: (j) => z0 + (j + 0.5) * cell };
}

// Calls fill(index) for every grid cell whose centre lies inside the plan
// triangle [[x, z], [x, z], [x, z]] (edges count as inside).
export function rasterizeTriangle(grid, triangle, fill) {
  const zs = triangle.map((point) => point[1]);
  const firstRow = Math.max(0, Math.ceil((Math.min(...zs) - grid.z0) / grid.cell - 0.5));
  const lastRow = Math.min(grid.height - 1, Math.floor((Math.max(...zs) - grid.z0) / grid.cell - 0.5));
  for (let j = firstRow; j <= lastRow; j += 1) {
    const z = grid.centerZ(j);
    let low = Infinity;
    let high = -Infinity;
    for (let k = 0; k < 3; k += 1) {
      const [ax, az] = triangle[k];
      const [bx, bz] = triangle[(k + 1) % 3];
      if ((az <= z && bz >= z) || (bz <= z && az >= z)) {
        if (az === bz) {
          low = Math.min(low, ax, bx);
          high = Math.max(high, ax, bx);
        } else {
          const x = ax + ((z - az) * (bx - ax)) / (bz - az);
          low = Math.min(low, x);
          high = Math.max(high, x);
        }
      }
    }
    if (low > high) continue;
    const first = Math.max(0, Math.ceil((low - grid.x0) / grid.cell - 0.5));
    const last = Math.min(grid.width - 1, Math.floor((high - grid.x0) / grid.cell - 0.5));
    for (let i = first; i <= last; i += 1) fill(j * grid.width + i);
  }
}

// Every cell whose centre lies inside the polygon (even-odd), as a 0/1 mask.
export function rasterizePolygon(grid, ring) {
  const mask = new Uint8Array(grid.width * grid.height);
  for (let j = 0; j < grid.height; j += 1) {
    const z = grid.centerZ(j);
    const crossings = [];
    for (let k = 0; k < ring.length; k += 1) {
      const [ax, az] = ring[k];
      const [bx, bz] = ring[(k + 1) % ring.length];
      if ((az > z) !== (bz > z)) crossings.push(ax + ((z - az) * (bx - ax)) / (bz - az));
    }
    crossings.sort((left, right) => left - right);
    for (let k = 0; k + 1 < crossings.length; k += 2) {
      const first = Math.max(0, Math.ceil((crossings[k] - grid.x0) / grid.cell - 0.5));
      const last = Math.min(grid.width - 1, Math.floor((crossings[k + 1] - grid.x0) / grid.cell - 0.5));
      for (let i = first; i <= last; i += 1) mask[j * grid.width + i] = 1;
    }
  }
  return mask;
}

// Exact Euclidean distance (metres, between cell centres) from every cell to
// the nearest cell of the mask (Felzenszwalb and Huttenlocher's two-pass
// squared-distance transform); Infinity everywhere when the mask is empty.
export function distanceToMask(grid, mask) {
  const { width, height, cell } = grid;
  const big = 1e20;
  const field = new Float64Array(width * height);
  for (let index = 0; index < field.length; index += 1) field[index] = mask[index] ? 0 : big;
  const line = new Float64Array(Math.max(width, height));
  const out = new Float64Array(Math.max(width, height));
  const parabolas = new Int32Array(Math.max(width, height));
  const bounds = new Float64Array(Math.max(width, height) + 1);
  const pass = (count) => {
    let k = 0;
    parabolas[0] = 0;
    bounds[0] = -Infinity;
    bounds[1] = Infinity;
    for (let q = 1; q < count; q += 1) {
      let s;
      for (;;) {
        const p = parabolas[k];
        s = ((line[q] + q * q) - (line[p] + p * p)) / (2 * q - 2 * p);
        if (s <= bounds[k] && k > 0) k -= 1;
        else break;
      }
      if (s <= bounds[k]) {
        parabolas[0] = q;
        bounds[0] = -Infinity;
        bounds[1] = Infinity;
        k = 0;
        continue;
      }
      k += 1;
      parabolas[k] = q;
      bounds[k] = s;
      bounds[k + 1] = Infinity;
    }
    k = 0;
    for (let q = 0; q < count; q += 1) {
      while (bounds[k + 1] < q) k += 1;
      const p = parabolas[k];
      out[q] = (q - p) * (q - p) + line[p];
    }
  };
  for (let j = 0; j < height; j += 1) {
    for (let i = 0; i < width; i += 1) line[i] = field[j * width + i];
    pass(width);
    for (let i = 0; i < width; i += 1) field[j * width + i] = out[i];
  }
  for (let i = 0; i < width; i += 1) {
    for (let j = 0; j < height; j += 1) line[j] = field[j * width + i];
    pass(height);
    for (let j = 0; j < height; j += 1) field[j * width + i] = out[j];
  }
  const distance = new Float32Array(width * height);
  for (let index = 0; index < distance.length; index += 1) distance[index] = field[index] >= big / 2 ? Infinity : Math.sqrt(field[index]) * cell;
  return distance;
}

// The index of the nearest mask cell to every cell (Euclidean between cell
// centres: the nearest mask column of each row, then the lower envelope of
// those rows' parabolas down each column); -1 everywhere when the mask is empty.
export function nearestMaskCell(grid, mask) {
  const { width, height } = grid;
  const rowNearest = new Int32Array(width * height).fill(-1);
  for (let j = 0; j < height; j += 1) {
    let last = -1;
    for (let i = 0; i < width; i += 1) {
      if (mask[j * width + i]) last = i;
      rowNearest[j * width + i] = last;
    }
    let next = -1;
    for (let i = width - 1; i >= 0; i -= 1) {
      if (mask[j * width + i]) next = i;
      const before = rowNearest[j * width + i];
      if (next >= 0 && (before < 0 || next - i < i - before)) rowNearest[j * width + i] = next;
    }
  }
  const nearest = new Int32Array(width * height).fill(-1);
  const cost = new Float64Array(height);
  const rows = new Int32Array(height);
  const bounds = new Float64Array(height + 1);
  for (let i = 0; i < width; i += 1) {
    let k = -1;
    for (let q = 0; q < height; q += 1) {
      const column = rowNearest[q * width + i];
      if (column < 0) continue;
      cost[q] = (i - column) * (i - column);
      if (k < 0) {
        k = 0;
        rows[0] = q;
        bounds[0] = -Infinity;
        bounds[1] = Infinity;
        continue;
      }
      let s;
      for (;;) {
        const p = rows[k];
        s = ((cost[q] + q * q) - (cost[p] + p * p)) / (2 * q - 2 * p);
        if (s <= bounds[k]) k -= 1;
        else break;
      }
      k += 1;
      rows[k] = q;
      bounds[k] = s;
      bounds[k + 1] = Infinity;
    }
    if (k < 0) continue;
    let r = 0;
    for (let q = 0; q < height; q += 1) {
      while (bounds[r + 1] < q) r += 1;
      const p = rows[r];
      nearest[q * width + i] = p * width + rowNearest[p * width + i];
    }
  }
  return nearest;
}

// Smooth noise in [0, 1] over a lattice of WOBBLE_SCALE_M, so a band's width wanders.
const WOBBLE_SCALE_M = 26;
function latticeUnit(i, j) {
  let hash = Math.imul(i, 374761393) + Math.imul(j, 668265263);
  hash = Math.imul(hash ^ (hash >>> 13), 1274126177);
  return ((hash ^ (hash >>> 16)) >>> 0) / 4294967296;
}

function wobbleNoise(x, z) {
  const u = x / WOBBLE_SCALE_M;
  const v = z / WOBBLE_SCALE_M;
  const i = Math.floor(u);
  const j = Math.floor(v);
  const fu = smoothstep(0, 1, u - i);
  const fv = smoothstep(0, 1, v - j);
  const top = latticeUnit(i, j) * (1 - fu) + latticeUnit(i + 1, j) * fu;
  const bottom = latticeUnit(i, j + 1) * (1 - fu) + latticeUnit(i + 1, j + 1) * fu;
  return top * (1 - fv) + bottom * fv;
}

function smoothstep(edge0, edge1, value) {
  const t = Math.min(1, Math.max(0, (value - edge0) / (edge1 - edge0)));
  return t * t * (3 - 2 * t);
}

// The plan triangles of a generated record: world x, z.
function recordTriangles(record) {
  const triangles = [];
  for (let offset = 0; offset < record.indices.length; offset += 3) {
    triangles.push([0, 1, 2].map((k) => {
      const vertex = record.indices[offset + k] * 3;
      return [record.vertices[vertex], record.vertices[vertex + 2]];
    }));
  }
  return triangles;
}

// Draw order of the generated ground, low to high: the land, then areas and
// overlays by their surface bias, roads and paths, the street ground and
// paint, buildings. -1 for records that are not ground.
function groundRank(record) {
  switch (record.feature_kind) {
    case "land_ground": return 0;
    case "major_area":
    case "terrain_overlay": return 1 + Number(record.surface_bias_m ?? 0);
    case "road_path": return 2;
    case "street_kerb":
    case "street_paint": return 3;
    case "building_roof":
    case "building_part_roof": return 4;
    default: return -1;
  }
}

function nearKind(record) {
  if (record.feature_kind === "building_roof" || record.feature_kind === "building_part_roof") return "building";
  if (record.feature_kind === "road_path" && record.material_key === "road_path") return "vehicle_road";
  // A street's parking lanes (the street ground's parking paint) are part of its carriageway.
  if (record.feature_kind === "street_paint" && record.material_key === "street_parking") return "vehicle_road";
  if (record.material_key === "major_area_paved") return "paved_area";
  if (record.feature_kind === "street_kerb") return "street_kerb";
  return null;
}

// Whether the rules draw on a record's cells: land, areas other than lots, the
// ground-cover overlays and the planted kerb verges.
function takesRules(record) {
  return (record.feature_kind === "land_ground" || record.feature_kind === "major_area" || record.feature_kind === "terrain_overlay" || record.feature_kind === "street_kerb")
    && GROUND_COVER_SURFACES.includes(record.material_key);
}

// Reads the generated world's chunk records.
export function loadGroundCoverWorld(worldRoot) {
  const manifest = JSON.parse(readFileSync(resolve(worldRoot, "manifest.json"), "utf8"));
  const records = [];
  for (const entry of manifest.chunks) {
    const chunk = JSON.parse(readFileSync(resolve(worldRoot, entry.path), "utf8"));
    records.push(...chunk.records);
  }
  return { records };
}

// The map for a validated config and a loaded world: {grid, rgba (Uint8Array,
// 4 bytes per cell, rows north to south), rules: [{id, channel, area_m2}]}.
// area_m2 is the area where the rule's weight reaches 0.5.
export function drawGroundCoverMap(config, world) {
  const grid = groundCoverGrid(config);
  const cells = grid.width * grid.height;
  // The top drawn ground record of every cell.
  const ground = world.records
    .map((record) => ({ record, rank: groundRank(record) }))
    .filter((entry) => entry.rank >= 0)
    .sort((left, right) => left.rank - right.rank || left.record.object_key.localeCompare(right.record.object_key));
  const top = new Int32Array(cells).fill(-1);
  const nearMasks = Object.fromEntries(GROUND_COVER_NEAR_KINDS.map((kind) => [kind, new Uint8Array(cells)]));
  ground.forEach(({ record }, index) => {
    const kind = nearKind(record);
    for (const triangle of recordTriangles(record)) {
      rasterizeTriangle(grid, triangle, (cell) => {
        top[cell] = index;
        if (kind) nearMasks[kind][cell] = 1;
      });
    }
  });
  const nearDistances = new Map();
  const nearDistance = (kinds) => {
    const key = [...kinds].sort().join("+");
    if (!nearDistances.has(key)) {
      const mask = new Uint8Array(cells);
      for (const kind of kinds) for (let cell = 0; cell < cells; cell += 1) mask[cell] |= nearMasks[kind][cell];
      nearDistances.set(key, distanceToMask(grid, mask));
    }
    return nearDistances.get(key);
  };
  // The cells inside the drawn outline of some OSM areas, whatever lies over them.
  const footprints = new Map();
  const footprint = (keys) => {
    const key = [...keys].sort().join("+");
    if (!footprints.has(key)) {
      const mask = new Uint8Array(cells);
      for (const { record } of ground) {
        if (record.feature_kind !== "major_area" || !record.source_keys.some((source) => keys.includes(source))) continue;
        for (const triangle of recordTriangles(record)) rasterizeTriangle(grid, triangle, (cell) => { mask[cell] = 1; });
      }
      footprints.set(key, mask);
    }
    return footprints.get(key);
  };
  const weights = GROUND_COVER_CHANNELS.map(() => new Float32Array(cells));
  const drawn = new Uint8Array(cells);
  const summaries = [];
  for (const rule of config.rules) {
    const weight = new Float32Array(cells).fill(rule.weight ?? 1);
    if (rule.inside_sources) {
      const inside = footprint(rule.inside_sources);
      for (let cell = 0; cell < cells; cell += 1) if (!inside[cell]) weight[cell] = 0;
    }
    if (rule.within_sources || rule.surfaces) {
      const sources = new Set(rule.within_sources ?? []);
      const surfaces = new Set(rule.surfaces ?? []);
      for (let cell = 0; cell < cells; cell += 1) {
        const owner = top[cell] >= 0 ? ground[top[cell]].record : null;
        const inSources = !rule.within_sources || (owner && owner.feature_kind === "major_area" && owner.source_keys.some((key) => sources.has(key)));
        const onSurface = !rule.surfaces || (owner && surfaces.has(owner.material_key));
        if (!inSources || !onSurface) weight[cell] = 0;
      }
    }
    if (rule.within_xz) {
      const inside = rasterizePolygon(grid, rule.within_xz);
      if (rule.feather_m > 0) {
        const outside = new Uint8Array(cells);
        for (let cell = 0; cell < cells; cell += 1) outside[cell] = inside[cell] ? 0 : 1;
        const toOutside = distanceToMask(grid, outside);
        const toInside = distanceToMask(grid, inside);
        const half = rule.feather_m / 2;
        for (let cell = 0; cell < cells; cell += 1) {
          // Signed distance from the outline between cell centres, + inside.
          const signed = inside[cell] ? toOutside[cell] - grid.cell / 2 : -(toInside[cell] - grid.cell / 2);
          weight[cell] *= smoothstep(-half, half, signed);
        }
      } else {
        for (let cell = 0; cell < cells; cell += 1) if (!inside[cell]) weight[cell] = 0;
      }
    }
    if (rule.near) {
      const distance = nearDistance(rule.near.kinds);
      const wobble = rule.near.wobble_m ?? 0;
      for (let cell = 0; cell < cells; cell += 1) {
        if (weight[cell] <= 0) continue;
        const i = cell % grid.width;
        const j = (cell - i) / grid.width;
        const shift = wobble > 0 ? wobble * (2 * wobbleNoise(grid.centerX(i), grid.centerZ(j)) - 1) : 0;
        weight[cell] *= 1 - smoothstep(rule.near.full_m, rule.near.zero_m, distance[cell] + shift);
      }
    }
    // Over: the rule's recipe covers its weight of whatever lies under it.
    const channel = GROUND_COVER_CHANNELS.indexOf(rule.channel);
    let covered = 0;
    for (let cell = 0; cell < cells; cell += 1) {
      const w = weight[cell];
      if (w <= 0) continue;
      for (const layer of weights) layer[cell] *= 1 - w;
      weights[channel][cell] += w;
      drawn[cell] = 1;
      if (w >= 0.5) covered += 1;
    }
    summaries.push({ id: rule.id, channel: rule.channel, area_m2: Math.round(covered * grid.cell * grid.cell) });
  }
  // Drawn cells off the ruled ground (roads, kerb tops, paint, roofs, lots, and
  // kerb verges no rule drew on) take the weights of the nearest ruled cell, so
  // an unruled verge matches the ground behind it. Cells with no generated ground
  // keep none: the shoreline's shoulder strip there draws the verge family's own mix.
  const ruled = new Uint8Array(cells);
  for (let cell = 0; cell < cells; cell += 1) {
    const record = top[cell] >= 0 ? ground[top[cell]].record : null;
    ruled[cell] = record && takesRules(record) && (record.feature_kind !== "street_kerb" || drawn[cell]) ? 1 : 0;
  }
  const nearest = nearestMaskCell(grid, ruled);
  for (let cell = 0; cell < cells; cell += 1) {
    if (ruled[cell] || top[cell] < 0 || nearest[cell] < 0) continue;
    for (const layer of weights) layer[cell] = layer[nearest[cell]];
  }
  const channels = GROUND_COVER_CHANNELS.length;
  const rgba = new Uint8Array(cells * channels);
  for (let cell = 0; cell < cells; cell += 1) {
    for (let channel = 0; channel < channels; channel += 1) rgba[cell * channels + channel] = Math.round(Math.min(1, Math.max(0, weights[channel][cell])) * 255);
  }
  return { grid, rgba, rules: summaries };
}

// The marsh map for a validated config and a loaded world: {grid, rgba}.
// The lots whose edges the marsh keeps a straw bank from (the map's green channel).
const MARSH_PAVED_MATERIALS = Object.freeze(["yard_asphalt", "yard_asphalt_fresh", "yard_asphalt_pale"]);
// How far inside a mapped pool its mask reaches full strength (m).
const MARSH_POOL_RAMP_M = 5;

// The marsh map: red the signed distance from the wetland's outline (0.5 on it, positive
// inside), green the distance from the lots' paving, both up to MARSH_MAP_RANGE_M, and
// blue how far inside the floor's low ground a cell lies (pools: rings [[x, z], ...]).
export function drawMarshMap(config, world, pools = []) {
  const grid = groundCoverGrid(config);
  const wet = new Uint8Array(grid.width * grid.height);
  const paved = new Uint8Array(grid.width * grid.height);
  const low = new Uint8Array(grid.width * grid.height);
  const fill = (mask, triangle) => rasterizeTriangle(grid, triangle, (index) => {
    mask[index] = 1;
  });
  for (const record of world.records) {
    const mask = record.material_key === "terrain_wetland" ? wet : MARSH_PAVED_MATERIALS.includes(record.material_key) ? paved : null;
    if (!mask) continue;
    const v = record.vertices;
    const corner = (index) => [v[index * 3], v[index * 3 + 2]];
    for (let offset = 0; offset < record.indices.length; offset += 3) {
      fill(mask, [corner(record.indices[offset]), corner(record.indices[offset + 1]), corner(record.indices[offset + 2])]);
    }
  }
  invariant(wet.some((cell) => cell === 1), "The world has no terrain_wetland ground for the marsh map");
  for (const ring of pools) {
    // Each cell's centre, even-odd against the pool's ring.
    for (let j = 0; j < grid.height; j += 1) {
      for (let i = 0; i < grid.width; i += 1) {
        const x = grid.centerX(i);
        const z = grid.centerZ(j);
        let inside = false;
        for (let a = 0, b = ring.length - 1; a < ring.length; b = a, a += 1) {
          if ((ring[a][1] > z) !== (ring[b][1] > z) && x < ((ring[b][0] - ring[a][0]) * (z - ring[a][1])) / (ring[b][1] - ring[a][1]) + ring[a][0]) inside = !inside;
        }
        if (inside) low[j * grid.width + i] = 1;
      }
    }
  }
  const toWet = distanceToMask(grid, wet);
  const toDry = distanceToMask(grid, wet.map((cell) => 1 - cell));
  const toPaved = paved.some((cell) => cell === 1) ? distanceToMask(grid, paved) : null;
  const toHigh = low.some((cell) => cell === 1) ? distanceToMask(grid, low.map((cell) => 1 - cell)) : null;
  const rgba = new Uint8Array(wet.length * 4);
  for (let index = 0; index < wet.length; index += 1) {
    const signed = Math.max(-MARSH_MAP_RANGE_M, Math.min(MARSH_MAP_RANGE_M, wet[index] ? toDry[index] : -toWet[index]));
    rgba[index * 4] = Math.round((0.5 + signed / (2 * MARSH_MAP_RANGE_M)) * 255);
    rgba[index * 4 + 1] = Math.round(Math.min(1, (toPaved ? toPaved[index] : MARSH_MAP_RANGE_M) / MARSH_MAP_RANGE_M) * 255);
    rgba[index * 4 + 2] = Math.round(Math.min(1, (toHigh && low[index] ? toHigh[index] : 0) / MARSH_POOL_RAMP_M) * 255);
    rgba[index * 4 + 3] = 255;
  }
  return { grid, rgba };
}

// The floor's mapped low ground: the terrain overrides' sink regions of the ditch's site.
function marshPools(projectRoot) {
  const overrides = JSON.parse(readFileSync(resolve(projectRoot, "tools/config/terrain-overrides.json"), "utf8"));
  const site = overrides.sites.find((candidate) => candidate.id === "mersea_ditch_promenade");
  return (site?.regions ?? []).filter((region) => region.rule.kind === "sink").map((region) => region.shape.points_xz);
}

export function buildMarshMap({ projectRoot, worldRoot }) {
  return drawMarshMap(loadGroundCoverConfig(projectRoot), loadGroundCoverWorld(worldRoot), marshPools(projectRoot));
}

export function buildGroundCoverMap({ projectRoot, worldRoot }) {
  const config = loadGroundCoverConfig(projectRoot);
  return drawGroundCoverMap(config, loadGroundCoverWorld(worldRoot));
}

// Draws the map from worldRoot and writes it as the PNG at output (by default
// the committed GROUND_COVER_MAP_PATH); returns the drawn map and the PNG's size.
export function writeGroundCoverMap({ projectRoot, worldRoot, output = resolve(projectRoot, GROUND_COVER_MAP_PATH) }) {
  const map = buildGroundCoverMap({ projectRoot, worldRoot });
  const png = encodeGroundCoverPng(map.grid.width, map.grid.height, map.rgba);
  mkdirSync(dirname(output), { recursive: true });
  writeFileSync(output, png);
  const marsh = buildMarshMap({ projectRoot, worldRoot });
  writeFileSync(resolve(dirname(output), "marsh_map.png"), encodeGroundCoverPng(marsh.grid.width, marsh.grid.height, marsh.rgba));
  return { map, output, bytes: png.length };
}

// PNG: 8-bit RGBA (its alpha is the bare weight, not transparency), one
// unfiltered scanline per map row.
const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const CRC_TABLE = (() => {
  const table = new Uint32Array(256);
  for (let n = 0; n < 256; n += 1) {
    let c = n;
    for (let k = 0; k < 8; k += 1) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    table[n] = c >>> 0;
  }
  return table;
})();

function crc32(bytes) {
  let c = 0xffffffff;
  for (const byte of bytes) c = CRC_TABLE[(c ^ byte) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function pngChunk(type, data) {
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  const body = Buffer.concat([Buffer.from(type, "ascii"), data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(body));
  return Buffer.concat([length, body, crc]);
}

export function encodeGroundCoverPng(width, height, rgba) {
  invariant(rgba.length === width * height * 4, "Ground-cover map size mismatch");
  const stride = width * 4;
  const raw = Buffer.alloc((stride + 1) * height);
  for (let row = 0; row < height; row += 1) {
    raw[row * (stride + 1)] = 0;
    Buffer.from(rgba.buffer, rgba.byteOffset + row * stride, stride).copy(raw, row * (stride + 1) + 1);
  }
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width, 0);
  header.writeUInt32BE(height, 4);
  header[8] = 8;
  header[9] = 6;
  return Buffer.concat([PNG_SIGNATURE, pngChunk("IHDR", header), pngChunk("IDAT", deflateSync(raw, { level: 9 })), pngChunk("IEND", Buffer.alloc(0))]);
}

// The pixels of an 8-bit RGBA PNG (any scanline filters): {width, height, rgba}.
export function decodeGroundCoverPng(buffer) {
  invariant(buffer.subarray(0, 8).equals(PNG_SIGNATURE), "Not a PNG");
  let offset = 8;
  let header = null;
  const data = [];
  while (offset < buffer.length) {
    const length = buffer.readUInt32BE(offset);
    const type = buffer.toString("ascii", offset + 4, offset + 8);
    const body = buffer.subarray(offset + 8, offset + 8 + length);
    if (type === "IHDR") header = { width: body.readUInt32BE(0), height: body.readUInt32BE(4), depth: body[8], color: body[9], interlace: body[12] };
    if (type === "IDAT") data.push(body);
    offset += 12 + length;
  }
  invariant(header && header.depth === 8 && header.color === 6 && header.interlace === 0, "The ground-cover map must be an 8-bit RGBA PNG");
  const raw = inflateSync(Buffer.concat(data));
  const stride = header.width * 4;
  const rgba = new Uint8Array(stride * header.height);
  for (let row = 0; row < header.height; row += 1) {
    const filter = raw[row * (stride + 1)];
    const line = raw.subarray(row * (stride + 1) + 1, (row + 1) * (stride + 1));
    for (let i = 0; i < stride; i += 1) {
      const left = i >= 4 ? rgba[row * stride + i - 4] : 0;
      const up = row > 0 ? rgba[(row - 1) * stride + i] : 0;
      const corner = i >= 4 && row > 0 ? rgba[(row - 1) * stride + i - 4] : 0;
      let predictor = 0;
      if (filter === 1) predictor = left;
      else if (filter === 2) predictor = up;
      else if (filter === 3) predictor = (left + up) >> 1;
      else if (filter === 4) {
        const p = left + up - corner;
        const pa = Math.abs(p - left);
        const pb = Math.abs(p - up);
        const pc = Math.abs(p - corner);
        predictor = pa <= pb && pa <= pc ? left : pb <= pc ? up : corner;
      } else invariant(filter === 0, `Unknown PNG filter ${filter}`);
      rgba[row * stride + i] = (line[i] + predictor) & 0xff;
    }
  }
  return { width: header.width, height: header.height, rgba };
}
