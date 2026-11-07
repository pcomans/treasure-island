#!/usr/bin/env node
// Bakes the bay water's wave tile: a seamless, looping animation of wind waves
// that game/resources/materials/world/water/bay_water.gdshader samples at several
// scales. FRAMES frames of a SIZE x SIZE tile, packed as an 8 x 8 atlas PNG that the
// 2d_array_texture importer turns into a CompressedTexture2DArray (one layer per
// frame; see bay_waves.png.import).
//
// The tile is a sum of deep-water waves on the tile's integer wave lattice, so it
// wraps in space, and each wave's frequency is a whole number of cycles per loop,
// so it wraps in time. Wave numbers run from BAND[0] to BAND[1] cycles per tile;
// the frequency of wave number n is round(LOOP_CYCLES * sqrt(n / BAND[0]))
// cycles per loop, which is deep-water dispersion (frequency grows with the
// square root of wave number) rounded to whole cycles. The shader plays a tile of
// L metres over a loop of LOOP_CYCLES periods of a wave L / BAND[0] long, so
// every scale keeps the right speed.
//
// The shader repeats these numbers by hand: its FRAMES and TILE_TEXELS are FRAMES and
// SIZE here, its slope decode (s.rg - 0.5) * 6.0 is 2 * CLIP, its MIP_KEPT is the
// printed `mip_retained`, and its LAYER_LOOP_S follow from BAND[0] and LOOP_CYCLES
// (see LAYER_M there). Change both.
//
// Amplitudes follow a saturation-range spectrum (elevation ~ k^-3), so every
// octave holds about the same slope variance and the shader can stack scaled
// copies of one tile. Waves run mainly along +x (the shader turns +x downwind),
// spread as cos^(2s) of half the angle off the wind; phases and Rayleigh
// amplitudes come from a fixed seed, so the bake is deterministic.
//
// Channels: red and green the slope along x and z, blue the height, alpha how
// sharply the surface curves down (wave crests); all normalized by their RMS over
// the whole loop and stored as 0.5 + value / (2 * CLIP), alpha as min(1, crest /
// CLIP). The printed `mip_retained` lists the share of slope variance each mip
// level keeps (Godot averages 2 x 2 texels per level); the shader turns the lost
// share into roughness so distant water neither shimmers nor loses its sheen.
//
// The texture is generated, not taken from any photo.
//
//   node tools/bake_water_waves.mjs [--output PATH]

import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { encodeGroundCoverPng } from "./lib/ground-cover-map.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
export const WATER_WAVES_PATH = "game/resources/textures/world/water/bay_waves.png";
export const SIZE = 128;
export const FRAMES = 64;
export const ATLAS_COLUMNS = 8;
export const BAND = [4, 11.3];
export const LOOP_CYCLES = 6;
const SPREAD_S = 3;
const CLIP = 3;
const SEED = 20261107;

function rng(seed) {
  let state = seed >>> 0;
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = state;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// The wave set: [{nx, nz, cycles, amplitude, phase}], phase in table steps.
export function waveSet() {
  const random = rng(SEED);
  const waves = [];
  const reach = Math.ceil(BAND[1]);
  for (let nz = -reach; nz <= reach; nz += 1) {
    for (let nx = -reach; nx <= reach; nx += 1) {
      const n = Math.hypot(nx, nz);
      if (n < BAND[0] || n > BAND[1]) continue;
      const angle = Math.atan2(nz, nx);
      const spread = Math.pow(Math.cos(angle / 2), 2 * SPREAD_S);
      // Elevation spectrum ~ k^-4 per unit area (k^-3 per unit k): amplitude ~ k^-2.
      const amplitude = Math.pow(n, -2) * Math.sqrt(spread) * Math.sqrt(-2 * Math.log(1 - random()));
      const phase = Math.floor(random() * SIZE);
      const cycles = Math.round(LOOP_CYCLES * Math.sqrt(n / BAND[0]));
      if (amplitude > 0) waves.push({ nx, nz, cycles, amplitude, phase });
    }
  }
  return waves;
}

// Raw height, slopes and crest (minus the Laplacian) for every frame, as Float32Arrays.
export function bakeFields(waves) {
  const count = SIZE * SIZE * FRAMES;
  const height = new Float32Array(count);
  const slopeX = new Float32Array(count);
  const slopeZ = new Float32Array(count);
  const crest = new Float32Array(count);
  const cos = new Float64Array(SIZE);
  const sin = new Float64Array(SIZE);
  for (let k = 0; k < SIZE; k += 1) {
    cos[k] = Math.cos((2 * Math.PI * k) / SIZE);
    sin[k] = Math.sin((2 * Math.PI * k) / SIZE);
  }
  const timeStep = SIZE / FRAMES;
  for (const wave of waves) {
    const tau = 2 * Math.PI;
    const a = wave.amplitude;
    const gx = -a * tau * wave.nx;
    const gz = -a * tau * wave.nz;
    const lap = a * tau * tau * (wave.nx * wave.nx + wave.nz * wave.nz);
    for (let f = 0; f < FRAMES; f += 1) {
      const shift = ((wave.phase - wave.cycles * f * timeStep) % SIZE + SIZE * FRAMES) % SIZE;
      const base = f * SIZE * SIZE;
      for (let j = 0; j < SIZE; j += 1) {
        const row = base + j * SIZE;
        let index = ((wave.nz * j + shift) % SIZE + SIZE) % SIZE;
        const stepX = ((wave.nx % SIZE) + SIZE) % SIZE;
        for (let i = 0; i < SIZE; i += 1) {
          const c = cos[index];
          const s = sin[index];
          height[row + i] += a * c;
          slopeX[row + i] += gx * s;
          slopeZ[row + i] += gz * s;
          crest[row + i] += lap * c;
          index += stepX;
          if (index >= SIZE) index -= SIZE;
        }
      }
    }
  }
  return { height, slopeX, slopeZ, crest };
}

function rms(values) {
  let sum = 0;
  for (const value of values) sum += value * value;
  return Math.sqrt(sum / values.length);
}

const encode = (value) => Math.max(0, Math.min(255, Math.round((0.5 + value / (2 * CLIP)) * 255)));

// The atlas RGBA and the normalization used.
export function bakeAtlas() {
  const waves = waveSet();
  const fields = bakeFields(waves);
  const slopeRms = Math.hypot(rms(fields.slopeX), rms(fields.slopeZ));
  const heightRms = rms(fields.height);
  const crestRms = rms(fields.crest);
  const width = SIZE * ATLAS_COLUMNS;
  const rows = FRAMES / ATLAS_COLUMNS;
  const rgba = new Uint8Array(width * SIZE * rows * 4);
  for (let f = 0; f < FRAMES; f += 1) {
    const ox = (f % ATLAS_COLUMNS) * SIZE;
    const oy = Math.floor(f / ATLAS_COLUMNS) * SIZE;
    for (let j = 0; j < SIZE; j += 1) {
      for (let i = 0; i < SIZE; i += 1) {
        const source = f * SIZE * SIZE + j * SIZE + i;
        const target = ((oy + j) * width + ox + i) * 4;
        rgba[target] = encode(fields.slopeX[source] / slopeRms);
        rgba[target + 1] = encode(fields.slopeZ[source] / slopeRms);
        rgba[target + 2] = encode(fields.height[source] / heightRms);
        rgba[target + 3] = Math.max(0, Math.min(255, Math.round(Math.min(1, Math.max(0, fields.crest[source] / crestRms) / CLIP) * 255)));
      }
    }
  }
  return { waves, rgba, width, height: SIZE * rows, slopeRms, heightRms, crestRms, fields };
}

// Share of the decoded slope variance each mip level keeps, averaged over frames
// (Godot's mipmaps average 2 x 2 texels of the 8-bit values, rounding).
export function mipRetained(atlas) {
  const levels = Math.log2(SIZE) + 1;
  const kept = new Float64Array(levels);
  for (let f = 0; f < FRAMES; f += 1) {
    const ox = (f % ATLAS_COLUMNS) * SIZE;
    const oy = Math.floor(f / ATLAS_COLUMNS) * SIZE;
    let size = SIZE;
    let r = new Float64Array(SIZE * SIZE);
    let g = new Float64Array(SIZE * SIZE);
    for (let j = 0; j < SIZE; j += 1) {
      for (let i = 0; i < SIZE; i += 1) {
        const index = ((oy + j) * atlas.width + ox + i) * 4;
        r[j * SIZE + i] = atlas.rgba[index];
        g[j * SIZE + i] = atlas.rgba[index + 1];
      }
    }
    for (let level = 0; level < levels; level += 1) {
      let variance = 0;
      for (let k = 0; k < size * size; k += 1) {
        const x = (r[k] / 255 - 0.5) * 2 * CLIP;
        const z = (g[k] / 255 - 0.5) * 2 * CLIP;
        variance += x * x + z * z;
      }
      kept[level] += variance / (size * size) / FRAMES;
      if (size === 1) break;
      const half = size / 2;
      const nr = new Float64Array(half * half);
      const ng = new Float64Array(half * half);
      for (let j = 0; j < half; j += 1) {
        for (let i = 0; i < half; i += 1) {
          const a = 2 * j * size + 2 * i;
          nr[j * half + i] = Math.floor((r[a] + r[a + 1] + r[a + size] + r[a + size + 1] + 2) / 4);
          ng[j * half + i] = Math.floor((g[a] + g[a + 1] + g[a + size] + g[a + size + 1] + 2) / 4);
        }
      }
      r = nr;
      g = ng;
      size = half;
    }
  }
  return Array.from(kept, (value) => +(value / kept[0]).toFixed(4));
}

function main() {
  const index = process.argv.indexOf("--output");
  const output = resolve(projectRoot, index >= 0 ? process.argv[index + 1] : WATER_WAVES_PATH);
  const atlas = bakeAtlas();
  const png = encodeGroundCoverPng(atlas.width, atlas.height, atlas.rgba);
  mkdirSync(dirname(output), { recursive: true });
  writeFileSync(output, png);
  const cycles = atlas.waves.map((wave) => wave.cycles);
  process.stdout.write(`${JSON.stringify({
    status: "baked",
    output,
    bytes: png.length,
    size: SIZE,
    frames: FRAMES,
    band: BAND,
    waves: atlas.waves.length,
    loop_cycles: [Math.min(...cycles), Math.max(...cycles)],
    clip_rms: CLIP,
    mip_retained: mipRetained(atlas),
  })}\n`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
