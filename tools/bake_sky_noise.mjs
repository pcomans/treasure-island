#!/usr/bin/env node
// Bakes the sky's cloud noise: one seamless 3D tile of SIZE x SIZE x DEPTH texels
// that game/resources/materials/world/sky/bay_sky.gdshader samples at several
// scales. The DEPTH slices are packed as an 8 x 8 atlas PNG that the 3d_texture
// importer turns into a CompressedTexture3D (see cloud_noise.png.import).
//
// The tile is twice as wide as it is deep, and every lattice has half as many
// cells along the depth, so a feature is as tall as it is wide when the shader
// maps the tile to a box of that shape (bay_sky.gdshader's SHAPE_TILE_M and half
// of it). Every lattice wraps, so the tile repeats without a seam on all three axes.
//
// Channels:
//   red    billowy Perlin noise lifted onto the green channel's cells (the
//          "Perlin-Worley" cloud shape of Schneider's 2015 Horizon Zero Dawn talk);
//   green  three octaves of inverted cell (Worley) noise, CELLS[0] cells a tile up;
//   blue   two finer octaves of the same, for the wisps at a cloud's edge;
//   alpha  smooth Perlin noise, WEATHER cells a tile: where clouds stand, cirrus.
//
// It holds noise only: no light, no sun direction, no sky colour. The numbers come
// from a fixed seed, so the bake is deterministic. Generated, not taken from any
// photo or third-party texture.
//
//   node tools/bake_sky_noise.mjs [--output PATH]

import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { encodeGroundCoverPng } from "./lib/ground-cover-map.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
export const SKY_NOISE_PATH = "game/resources/textures/world/sky/cloud_noise.png";
export const SIZE = 128;
export const DEPTH = 64;
export const ATLAS_COLUMNS = 8;
// Cells per tile width of the shape's cell noise, the billows and the weather.
const CELLS = [4, 8, 16, 32];
const BILLOW = 4;
const WEATHER = 2;
const SEED = 20261109;

function hash(x, y, z, seed) {
  let h = Math.imul(x, 0x8da6b343) ^ Math.imul(y, 0xd8163841) ^ Math.imul(z, 0xcb1ab31f) ^ Math.imul(seed, 0x9e3779b1);
  h = Math.imul(h ^ (h >>> 15), 0x2c1b3c6d);
  h = Math.imul(h ^ (h >>> 12), 0x297a2d39);
  return (h ^ (h >>> 15)) >>> 0;
}

const wrap = (value, period) => ((value % period) + period) % period;

// Gradient noise on a lattice of `cells` x `cells` x `cells / 2` that wraps, at
// (u, v, w) in tile units; about -1..1.
function perlin(u, v, w, cells, seed) {
  const px = cells;
  const pz = cells / 2;
  const x = u * px;
  const y = v * px;
  const z = w * pz;
  const x0 = Math.floor(x);
  const y0 = Math.floor(y);
  const z0 = Math.floor(z);
  const fx = x - x0;
  const fy = y - y0;
  const fz = z - z0;
  const fade = (t) => t * t * t * (t * (t * 6 - 15) + 10);
  const sx = fade(fx);
  const sy = fade(fy);
  const sz = fade(fz);
  let total = 0;
  for (let k = 0; k < 2; k += 1) {
    for (let j = 0; j < 2; j += 1) {
      for (let i = 0; i < 2; i += 1) {
        const h = hash(wrap(x0 + i, px), wrap(y0 + j, px), wrap(z0 + k, pz), seed);
        // A unit-ish gradient from the hash: a point on the sphere.
        const cz = ((h & 0xffff) / 0xffff) * 2 - 1;
        const angle = ((h >>> 16) / 0xffff) * 2 * Math.PI;
        const r = Math.sqrt(Math.max(0, 1 - cz * cz));
        const dot = r * Math.cos(angle) * (fx - i) + r * Math.sin(angle) * (fy - j) + cz * (fz - k);
        total += dot * (i ? sx : 1 - sx) * (j ? sy : 1 - sy) * (k ? sz : 1 - sz);
      }
    }
  }
  return total * 1.6;
}

// One feature point per cell of a wrapping lattice of `cells` x `cells` x `cells / 2`.
function cellPoints(cells, seed) {
  const pz = cells / 2;
  const points = new Float32Array(cells * cells * pz * 3);
  for (let k = 0; k < pz; k += 1) {
    for (let j = 0; j < cells; j += 1) {
      for (let i = 0; i < cells; i += 1) {
        const at = ((k * cells + j) * cells + i) * 3;
        points[at] = (hash(i, j, k, seed) >>> 8) / 0x1000000;
        points[at + 1] = (hash(i, j, k, seed + 1) >>> 8) / 0x1000000;
        points[at + 2] = (hash(i, j, k, seed + 2) >>> 8) / 0x1000000;
      }
    }
  }
  return points;
}

// Inverted cell noise: 1 at a cell's feature point, 0 a cell away from every point.
function worley(u, v, w, cells, points) {
  const pz = cells / 2;
  const x = u * cells;
  const y = v * cells;
  const z = w * pz;
  const x0 = Math.floor(x);
  const y0 = Math.floor(y);
  const z0 = Math.floor(z);
  let nearest = 4;
  for (let k = -1; k <= 1; k += 1) {
    for (let j = -1; j <= 1; j += 1) {
      for (let i = -1; i <= 1; i += 1) {
        const at = ((wrap(z0 + k, pz) * cells + wrap(y0 + j, cells)) * cells + wrap(x0 + i, cells)) * 3;
        const dx = x0 + i + points[at] - x;
        const dy = y0 + j + points[at + 1] - y;
        const dz = z0 + k + points[at + 2] - z;
        nearest = Math.min(nearest, dx * dx + dy * dy + dz * dz);
      }
    }
  }
  return 1 - Math.min(1, Math.sqrt(nearest));
}

const clamp01 = (value) => Math.min(1, Math.max(0, value));

// The four channels of every texel, 0..1, as Float32Arrays (x fastest, then y, then slice).
export function bakeFields() {
  const count = SIZE * SIZE * DEPTH;
  const red = new Float32Array(count);
  const green = new Float32Array(count);
  const blue = new Float32Array(count);
  const alpha = new Float32Array(count);
  const points = CELLS.map((cells, index) => cellPoints(cells, SEED + 10 * (index + 1)));
  for (let k = 0; k < DEPTH; k += 1) {
    const w = (k + 0.5) / DEPTH;
    for (let j = 0; j < SIZE; j += 1) {
      const v = (j + 0.5) / SIZE;
      for (let i = 0; i < SIZE; i += 1) {
        const u = (i + 0.5) / SIZE;
        const at = (k * SIZE + j) * SIZE + i;
        const cell = CELLS.map((cells, index) => worley(u, v, w, cells, points[index]));
        const coarse = cell[0] * 0.625 + cell[1] * 0.25 + cell[2] * 0.125;
        let billow = 0;
        let weather = 0;
        for (let octave = 0; octave < 4; octave += 1) {
          billow += perlin(u, v, w, BILLOW << octave, SEED + 100 + octave) * 0.5 ** octave;
          weather += perlin(u, v, w, WEATHER << octave, SEED + 200 + octave) * 0.5 ** octave;
        }
        // Billows: the folds of the noise, not its sign.
        const folded = clamp01(Math.abs(billow / 1.2));
        red[at] = coarse + folded * (1 - coarse);
        green[at] = coarse;
        blue[at] = cell[2] * 0.6 + cell[3] * 0.4;
        alpha[at] = clamp01(0.5 + weather / 2.4);
      }
    }
  }
  return { red, green, blue, alpha };
}

// The slices as an atlas, slice 0 top left, row by row.
export function bakeAtlas() {
  const fields = bakeFields();
  const rows = DEPTH / ATLAS_COLUMNS;
  const width = SIZE * ATLAS_COLUMNS;
  const height = SIZE * rows;
  const rgba = new Uint8Array(width * height * 4);
  for (let k = 0; k < DEPTH; k += 1) {
    const ox = (k % ATLAS_COLUMNS) * SIZE;
    const oy = Math.floor(k / ATLAS_COLUMNS) * SIZE;
    for (let j = 0; j < SIZE; j += 1) {
      for (let i = 0; i < SIZE; i += 1) {
        const from = (k * SIZE + j) * SIZE + i;
        const to = ((oy + j) * width + ox + i) * 4;
        rgba[to] = Math.round(fields.red[from] * 255);
        rgba[to + 1] = Math.round(fields.green[from] * 255);
        rgba[to + 2] = Math.round(fields.blue[from] * 255);
        rgba[to + 3] = Math.round(fields.alpha[from] * 255);
      }
    }
  }
  return { width, height, rgba, fields };
}

// Mean and the 5th, 50th and 95th percentiles of a channel, for tuning the shader.
function spread(values) {
  const sorted = Float32Array.from(values).sort();
  const at = (share) => +sorted[Math.floor(share * (sorted.length - 1))].toFixed(3);
  let total = 0;
  for (const value of sorted) total += value;
  return { mean: +(total / sorted.length).toFixed(3), p05: at(0.05), p50: at(0.5), p95: at(0.95) };
}

function main() {
  const index = process.argv.indexOf("--output");
  const output = resolve(projectRoot, index >= 0 ? process.argv[index + 1] : SKY_NOISE_PATH);
  const atlas = bakeAtlas();
  const png = encodeGroundCoverPng(atlas.width, atlas.height, atlas.rgba);
  mkdirSync(dirname(output), { recursive: true });
  writeFileSync(output, png);
  process.stdout.write(`${JSON.stringify({
    status: "baked",
    output,
    bytes: png.length,
    size: [SIZE, SIZE, DEPTH],
    atlas: [atlas.width, atlas.height],
    red: spread(atlas.fields.red),
    green: spread(atlas.fields.green),
    blue: spread(atlas.fields.blue),
    alpha: spread(atlas.fields.alpha),
  })}\n`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
