// Water shore map: what the bay water shader (game/resources/materials/world/water/
// bay_water.gdshader) knows about the shore near each point of the bay, as an
// 8-bit RGBA PNG on a north-up grid (rows north to south, like the ground-cover map):
//   red    signed distance from the waterline, 0.5 on it, rising over the water and
//          falling over the land, linear over +-SHORE_FINE_RANGE_M (the wash and the
//          shallow toe);
//   green  distance from the waterline over the water, square-root scaled up to
//          SHORE_COARSE_RANGE_M (0 on land; the nearshore water's colour);
//   blue   fetch: how far the prevailing westerly has blown over open water to reach
//          the point, square-root scaled up to SHORE_FETCH_RANGE_M (low in the lee of
//          the islands, where the water lies calmer);
//   alpha  cover: 1 under a pier deck, fading to 0 SHORE_COVER_FADE_M beyond its edge
//          (the deck hides the sky from the water under it).
// The waterline is where the drawn ground meets the water plane (WATER_Y_M): land is
// every cell whose highest drawn surface stands above it, among the playable chunks'
// records, the shoreline's slopes, faces and walls (generated/world/shoreline.json)
// and Yerba Buena Island (context.json). Pier decks stand on piles over the water, so
// they are not shore: the cells under a deck (the playable land's terrain_pier decks
// and the boundary-attached pier decks) are left out of the land and make the cover
// instead. The marina basin, the bridge and the loose stones are not shore either.
// Land is found on a SHORE_LAND_CELL_M grid, the signed distance measured there and
// sampled at the map's cell centres, so the shader's bilinear filtering places the
// waterline between cells. Fetch is the mean over SHORE_WIND_BEARINGS_DEG of the open
// water upwind along each bearing (the map's upwind edge counts as
// SHORE_OPEN_FETCH_M). The prevailing wind through the Golden Gate is a production
// assumption for game art, not a measurement.
//
// The shader repeats these numbers by hand: its shore_rect is SHORE_MAP_ORIGIN_XZ and
// SHORE_MAP_SIZE_M, and it decodes red with SHORE_FINE_RANGE_M (16), green with
// SHORE_COARSE_RANGE_M (1024) and blue with SHORE_FETCH_RANGE_M (4096). Change both.
//
// tools/build_water_shore_map.mjs writes it, and so does tools/build_godot_world.mjs
// each time it writes the committed generated/world; tools/check_godot_world_determinism.mjs
// checks the committed copy against a fresh draw. World x, z (+X east, +Z south), metres.

import { mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";

import { distanceToMask, encodeGroundCoverPng, rasterizeTriangle } from "./ground-cover-map.mjs";
import { unpackShorelineRecord, WATER_Y_M } from "./shoreline-generation.mjs";
import { invariant } from "./world-contract.mjs";

export const WATER_SHORE_MAP_PATH = "game/resources/textures/world/water/shore_map.png";
// The map's north-west corner, size and cell (m); the shader takes the same rectangle.
export const SHORE_MAP_ORIGIN_XZ = Object.freeze([-1120, -1360]);
export const SHORE_MAP_SIZE_M = Object.freeze([2600, 3600]);
export const SHORE_MAP_CELL_M = 4;
export const SHORE_LAND_CELL_M = 1;
export const SHORE_FINE_RANGE_M = 16;
export const SHORE_COARSE_RANGE_M = 1024;
export const SHORE_FETCH_RANGE_M = 4096;
export const SHORE_OPEN_FETCH_M = 4096;
export const SHORE_COVER_FADE_M = 2;
// Bearings (clockwise from north) the waves run toward under a west-south-westerly.
export const SHORE_WIND_BEARINGS_DEG = Object.freeze([62, 66.5, 71, 75.5, 80, 84.5, 89, 93.5, 98]);
// Pier decks: on piles over the water, the cover rather than shore.
const DECK_MATERIALS = Object.freeze(["terrain_pier", "context_boundary_pier"]);
// Other context that stands over the water rather than on a shore (the boundary-
// attached marina basin is water).
const NOT_SHORE_CONTEXT = Object.freeze(["bay_bridge", "boundary_attached_visual"]);

function grid(cell) {
  const [x0, z0] = SHORE_MAP_ORIGIN_XZ;
  const width = Math.round(SHORE_MAP_SIZE_M[0] / cell);
  const height = Math.round(SHORE_MAP_SIZE_M[1] / cell);
  return { x0, z0, cell, width, height, centerX: (i) => x0 + (i + 0.5) * cell, centerZ: (j) => z0 + (j + 0.5) * cell };
}

// Marks every cell whose centre lies under a triangle drawn above the water.
function markLand(land, mask, vertices, indices) {
  for (let offset = 0; offset < indices.length; offset += 3) {
    const a = indices[offset] * 3;
    const b = indices[offset + 1] * 3;
    const c = indices[offset + 2] * 3;
    const ya = vertices[a + 1];
    const yb = vertices[b + 1];
    const yc = vertices[c + 1];
    if (ya <= WATER_Y_M && yb <= WATER_Y_M && yc <= WATER_Y_M) continue;
    const xa = vertices[a], za = vertices[a + 2];
    const xb = vertices[b], zb = vertices[b + 2];
    const xc = vertices[c], zc = vertices[c + 2];
    const det = (zb - zc) * (xa - xc) + (xc - xb) * (za - zc);
    if (Math.abs(det) < 1e-12) continue;
    const allAbove = ya > WATER_Y_M && yb > WATER_Y_M && yc > WATER_Y_M;
    rasterizeTriangle(land, [[xa, za], [xb, zb], [xc, zc]], (index) => {
      if (mask[index] || allAbove) {
        mask[index] = 1;
        return;
      }
      const x = land.centerX(index % land.width);
      const z = land.centerZ(Math.floor(index / land.width));
      const wa = ((zb - zc) * (x - xc) + (xc - xb) * (z - zc)) / det;
      const wb = ((zc - za) * (x - xc) + (xa - xc) * (z - zc)) / det;
      if (wa * ya + wb * yb + (1 - wa - wb) * yc > WATER_Y_M) mask[index] = 1;
    });
  }
}

// Marks every cell whose centre lies under a triangle of the footprint.
function markFootprint(land, mask, vertices, indices) {
  for (let offset = 0; offset < indices.length; offset += 3) {
    const corner = (index) => [vertices[index * 3], vertices[index * 3 + 2]];
    rasterizeTriangle(land, [corner(indices[offset]), corner(indices[offset + 1]), corner(indices[offset + 2])], (index) => {
      mask[index] = 1;
    });
  }
}

// The land and pier-deck masks on the SHORE_LAND_CELL_M grid: {grid, mask, deck};
// a deck's cells are never land.
export function shoreLandMask(worldRoot) {
  const land = grid(SHORE_LAND_CELL_M);
  const mask = new Uint8Array(land.width * land.height);
  const deck = new Uint8Array(land.width * land.height);
  const chunkRoot = join(worldRoot, "chunks");
  for (const name of readdirSync(chunkRoot).filter((entry) => entry.endsWith(".json")).sort()) {
    const chunk = JSON.parse(readFileSync(join(chunkRoot, name), "utf8"));
    for (const record of chunk.records) {
      if (DECK_MATERIALS.includes(record.material_key)) markFootprint(land, deck, record.vertices, record.indices);
      else markLand(land, mask, record.vertices, record.indices);
    }
  }
  const shoreline = JSON.parse(readFileSync(join(worldRoot, "shoreline.json"), "utf8"));
  for (const record of shoreline.records) {
    const mesh = unpackShorelineRecord(record);
    markLand(land, mask, mesh.vertices, mesh.indices);
  }
  const context = JSON.parse(readFileSync(join(worldRoot, "context.json"), "utf8"));
  for (const record of [...context.records, ...context.boundary_attached_visuals]) {
    if (DECK_MATERIALS.includes(record.material_key)) markFootprint(land, deck, record.vertices, record.indices);
    else if (!NOT_SHORE_CONTEXT.includes(record.context_kind)) markLand(land, mask, record.vertices, record.indices);
  }
  for (let index = 0; index < mask.length; index += 1) if (deck[index]) mask[index] = 0;
  invariant(mask.some((cell) => cell === 1), "The world has no land above the water for the shore map");
  invariant(deck.some((cell) => cell === 1), "The world has no pier decks for the shore map's cover");
  return { grid: land, mask, deck };
}

// Bilinear sample of a field on grid g at world (x, z), clamped to the grid.
function sample(g, field, x, z) {
  const u = Math.min(g.width - 1, Math.max(0, (x - g.x0) / g.cell - 0.5));
  const v = Math.min(g.height - 1, Math.max(0, (z - g.z0) / g.cell - 0.5));
  const i = Math.min(g.width - 2, Math.floor(u));
  const j = Math.min(g.height - 2, Math.floor(v));
  const fu = u - i;
  const fv = v - j;
  const at = (di, dj) => field[(j + dj) * g.width + i + di];
  return (at(0, 0) * (1 - fu) + at(1, 0) * fu) * (1 - fv) + (at(0, 1) * (1 - fu) + at(1, 1) * fu) * fv;
}

// Mean fetch over the wind bearings, on grid g with water cells `water` (1 = water).
// Columns run from west to east; each cell takes its upwind neighbour column's
// fetch, interpolated between rows, plus the step's length.
export function fetchField(g, water) {
  const total = new Float64Array(g.width * g.height);
  for (const bearing of SHORE_WIND_BEARINGS_DEG) {
    const angle = (bearing * Math.PI) / 180;
    const dx = Math.sin(angle);
    const dz = -Math.cos(angle);
    invariant(dx > Math.abs(dz), "Fetch bearings must run more east than north or south");
    const rowShift = dz / dx;
    const step = g.cell / dx;
    let previous = new Float64Array(g.height).fill(SHORE_OPEN_FETCH_M);
    for (let i = 0; i < g.width; i += 1) {
      const column = new Float64Array(g.height);
      for (let j = 0; j < g.height; j += 1) {
        if (!water[j * g.width + i]) continue;
        const v = Math.min(g.height - 1, Math.max(0, j - rowShift));
        const low = Math.floor(v);
        const high = Math.min(g.height - 1, low + 1);
        const upwind = previous[low] * (1 - (v - low)) + previous[high] * (v - low);
        column[j] = Math.min(SHORE_OPEN_FETCH_M, upwind + step);
      }
      for (let j = 0; j < g.height; j += 1) total[j * g.width + i] += column[j];
      previous = column;
    }
  }
  return total.map((value) => value / SHORE_WIND_BEARINGS_DEG.length);
}

const byte = (value) => Math.max(0, Math.min(255, Math.round(value * 255)));

// The shore map for a world: {grid, rgba}.
export function drawWaterShoreMap(worldRoot) {
  const { grid: land, mask, deck } = shoreLandMask(worldRoot);
  // Distances between cell centres, less half a cell, so the waterline lies between them.
  const toLand = distanceToMask(land, mask);
  const toWater = distanceToMask(land, mask.map((cell) => 1 - cell));
  const half = land.cell / 2;
  const signed = new Float32Array(mask.length);
  for (let index = 0; index < mask.length; index += 1) {
    signed[index] = mask[index] ? -(Math.min(toWater[index], 1e6) - half) : Math.min(toLand[index], 1e6) - half;
  }
  const toDeck = distanceToMask(land, deck);
  const deckCover = Float32Array.from(toDeck, (value) => Math.max(0, Math.min(1, 1 - (value - half) / SHORE_COVER_FADE_M)));
  const map = grid(SHORE_MAP_CELL_M);
  const distance = new Float32Array(map.width * map.height);
  const cover = new Float32Array(map.width * map.height);
  const water = new Uint8Array(map.width * map.height);
  for (let j = 0; j < map.height; j += 1) {
    for (let i = 0; i < map.width; i += 1) {
      const value = sample(land, signed, map.centerX(i), map.centerZ(j));
      distance[j * map.width + i] = value;
      cover[j * map.width + i] = sample(land, deckCover, map.centerX(i), map.centerZ(j));
      water[j * map.width + i] = value > 0 ? 1 : 0;
    }
  }
  const fetch = fetchField(map, water);
  // Soften the fetch's wind shadows over a 3 x 3 cell box.
  const soft = new Float64Array(fetch.length);
  for (let j = 0; j < map.height; j += 1) {
    for (let i = 0; i < map.width; i += 1) {
      let sum = 0;
      let count = 0;
      for (let dj = -1; dj <= 1; dj += 1) {
        for (let di = -1; di <= 1; di += 1) {
          const ii = Math.min(map.width - 1, Math.max(0, i + di));
          const jj = Math.min(map.height - 1, Math.max(0, j + dj));
          sum += fetch[jj * map.width + ii];
          count += 1;
        }
      }
      soft[j * map.width + i] = sum / count;
    }
  }
  const rgba = new Uint8Array(map.width * map.height * 4);
  for (let index = 0; index < distance.length; index += 1) {
    const d = distance[index];
    rgba[index * 4] = byte(0.5 + Math.max(-SHORE_FINE_RANGE_M, Math.min(SHORE_FINE_RANGE_M, d)) / (2 * SHORE_FINE_RANGE_M));
    rgba[index * 4 + 1] = byte(Math.sqrt(Math.max(0, Math.min(SHORE_COARSE_RANGE_M, d)) / SHORE_COARSE_RANGE_M));
    rgba[index * 4 + 2] = byte(Math.sqrt(Math.max(0, Math.min(SHORE_FETCH_RANGE_M, soft[index])) / SHORE_FETCH_RANGE_M));
    rgba[index * 4 + 3] = byte(cover[index]);
  }
  return { grid: map, rgba };
}

// Draws the map from worldRoot and writes it as the PNG at output (by default the
// committed WATER_SHORE_MAP_PATH); returns the drawn map and the PNG's size.
export function writeWaterShoreMap({ projectRoot, worldRoot, output = resolve(projectRoot, WATER_SHORE_MAP_PATH) }) {
  const map = drawWaterShoreMap(worldRoot);
  const png = encodeGroundCoverPng(map.grid.width, map.grid.height, map.rgba);
  mkdirSync(dirname(output), { recursive: true });
  writeFileSync(output, png);
  return { map, output, bytes: png.length };
}
