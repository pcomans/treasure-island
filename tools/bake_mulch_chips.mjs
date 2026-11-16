#!/usr/bin/env node
// Paints the shared wood-chip mulch tile (game/resources/textures/world/street/mulch_chips.png):
// shredded wood chips seen from straight above, RGB their colour in sRGB and alpha
// their height, a seamless square TILE_M across. Deterministic: the same seed paints
// the same image. Nothing is copied from a photograph; the sizes, shapes and colours
// are production inference from the owner's video of the park outside Isle House
// (2026-11-15, f_090 and f_103: shredded chips, mostly 2-5 cm long and about a
// centimetre wide, with fibrous slivers, a few larger flat chips and crumbs; weathered
// silver-grey on top of browner ones, with dark gaps between them).
//
// Chips are dropped one after another, wrapping round the tile's edges, so later
// chips lie on earlier ones and the tile has no seam. A chip is an uneven sliver with
// slanted ends, now and then split at one end, a slight bow, and fibres and cracks
// running along it. Chips near the top of the
// pile are mostly weathered silver-grey, deeper ones browner. Heights rise with the
// order of dropping, plus each chip's tilt and a dome across it. A cavity term from
// the height map darkens the gaps and the edges under higher chips; no light
// direction is painted in (time of day stays dynamic).
//
//   node tools/bake_mulch_chips.mjs OUT.png [size_px]
import { writeFileSync } from "node:fs";
import { deflateSync } from "node:zlib";

const OUT = process.argv[2];
const SIZE = Number(process.argv[3] ?? 1024);
if (!OUT || !Number.isInteger(SIZE) || SIZE % 4 !== 0 || SIZE < 64) {
  console.error("usage: node tools/bake_mulch_chips.mjs OUT.png [size_px, a multiple of 4]");
  process.exit(2);
}
// The tile's width on the ground, metres; the shader uses the same (MulchGround.TILE_M).
const TILE_M = 1.25;
// Painted at SUPER times the size, then averaged down, for clean chip edges.
const SUPER = 2;
const N = SIZE * SUPER;
const MM = (TILE_M * 1000) / N; // millimetres per painted pixel
const SEED = 20261116;

// Mulberry32: a small seeded generator.
function generator(seed) {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
const random = generator(SEED);
const between = (low, high) => low + (high - low) * random();
const gauss = () => {
  let u = 0;
  for (let i = 0; i < 4; i += 1) u += random();
  return (u - 2) / 0.577;
};

// Linear-light colour arithmetic, sRGB in and out.
const toLinear = (c) => { const v = c / 255; return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; };
const toSrgb = (v) => { const c = v <= 0.0031308 ? v * 12.92 : 1.055 * v ** (1 / 2.4) - 0.055; return Math.max(0, Math.min(255, Math.round(c * 255))); };
const rgb = (r, g, b) => [toLinear(r), toLinear(g), toLinear(b)];

// Chip classes: sRGB colour, spread, and the share of chips of each class at the top
// of the pile and at its bottom (mixed by the chip's depth in the pile).
const CLASSES = [
  { name: "weathered", colour: rgb(176, 170, 161), spread: 0.16, top: 0.56, bottom: 0.16 },
  { name: "pale", colour: rgb(196, 186, 170), spread: 0.12, top: 0.1, bottom: 0.04 },
  { name: "tan", colour: rgb(146, 127, 106), spread: 0.15, top: 0.1, bottom: 0.18 },
  { name: "brown", colour: rgb(106, 88, 72), spread: 0.16, top: 0.18, bottom: 0.38 },
  { name: "dark", colour: rgb(66, 55, 46), spread: 0.15, top: 0.06, bottom: 0.24 },
];
// The fines and soil between the chips.
const GAP = rgb(44, 36, 29);

// Value noise on a periodic lattice (period in lattice cells), for grain and fines.
function periodicNoise(period, seed) {
  const r = generator(seed);
  const lattice = new Float32Array(period * period).map(() => r());
  return (x, y) => {
    const xi = Math.floor(x); const yi = Math.floor(y);
    const fx = x - xi; const fy = y - yi;
    const ux = fx * fx * (3 - 2 * fx); const uy = fy * fy * (3 - 2 * fy);
    const at = (i, j) => lattice[(((j % period) + period) % period) * period + (((i % period) + period) % period)];
    const a = at(xi, yi); const b = at(xi + 1, yi); const c = at(xi, yi + 1); const d = at(xi + 1, yi + 1);
    return a + (b - a) * ux + (c - a) * uy + (a - b - c + d) * ux * uy;
  };
}
const finesNoise = periodicNoise(256, SEED + 1);
const finesCoarse = periodicNoise(32, SEED + 2);

const colour = new Float32Array(N * N * 3);
const height = new Float32Array(N * N);
// The fines: dark soil with a fine speckle of crumbs, lowest in the pile.
for (let y = 0; y < N; y += 1) {
  for (let x = 0; x < N; x += 1) {
    const u = (x / N) * 256; const v = (y / N) * 256;
    const speck = finesNoise(u, v);
    const coarse = finesCoarse((x / N) * 32, (y / N) * 32);
    const shade = 0.7 + 0.5 * speck + 0.25 * (coarse - 0.5);
    const i = (y * N + x) * 3;
    colour[i] = GAP[0] * shade; colour[i + 1] = GAP[1] * shade; colour[i + 2] = GAP[2] * shade;
    height[y * N + x] = 0.04 * speck;
  }
}

// A chip: length and width in millimetres, from a long-tailed spread of sizes.
function chipSize() {
  const roll = random();
  if (roll < 0.14) return [between(7, 16), between(4, 9)]; // crumbs and short bits
  if (roll < 0.2) return [between(40, 80), between(2.5, 4.5)]; // fibrous slivers
  if (roll < 0.3) return [between(45, 90), between(14, 26)]; // large flat chips
  return [between(20, 50), between(7, 14)]; // the common shred
}

const fibre = periodicNoise(64, SEED + 3);
// Chips dropped on the tile (about 6,100 a square metre, most of them hidden under later ones).
const CHIPS = Math.round(6144 * TILE_M * TILE_M);
let painted = 0;
for (let k = 0; k < CHIPS; k += 1) {
  const depth = k / CHIPS; // 0 bottom of the pile, 1 top
  const [lengthMm, widthMm] = chipSize();
  const length = lengthMm / MM; const width = widthMm / MM;
  const cx = random() * N; const cy = random() * N;
  const angle = random() * Math.PI;
  const ax = Math.cos(angle); const ay = Math.sin(angle);
  // Class by depth.
  let pick = random(); let chosen = CLASSES[CLASSES.length - 1];
  for (const c of CLASSES) {
    const share = c.bottom + (c.top - c.bottom) * depth;
    if (pick < share) { chosen = c; break; }
    pick -= share;
  }
  const tone = Math.exp(gauss() * chosen.spread);
  const warm = 1 + gauss() * 0.035;
  const base = [chosen.colour[0] * tone * warm, chosen.colour[1] * tone, chosen.colour[2] * tone / warm];
  // Shape: half widths at five stations along the chip (an uneven sliver), a slight
  // bow, ends cut on a slant, and a split at one end of some.
  const knots = [0, 1, 2, 3, 4].map((i) => (i === 0 || i === 4 ? between(0.6, 1.0) : between(0.72, 1.12)) * width * 0.5);
  const bow = gauss() * 0.1 * width;
  const cutA = between(-0.22, 0.22); const cutB = between(-0.22, 0.22);
  const split = random() < 0.3 ? { at: between(-0.4, 0.4), half: between(0.06, 0.14), from: between(0.55, 0.8), end: random() < 0.5 ? 1 : -1 } : null;
  const tilt = gauss() * 0.06;
  const fibreScale = between(0.9, 1.5) * MM; // fibres about a millimetre apart
  const fibreOffset = random() * 64;
  const lift = 0.12 + 0.8 * depth + between(-0.05, 0.05);
  const reach = length * 0.5 + width + Math.abs(bow) + 2;
  const x0 = Math.floor(cx - reach); const x1 = Math.ceil(cx + reach);
  const y0 = Math.floor(cy - reach); const y1 = Math.ceil(cy + reach);
  for (let py = y0; py <= y1; py += 1) {
    for (let px = x0; px <= x1; px += 1) {
      const dx = px + 0.5 - cx; const dy = py + 0.5 - cy;
      const along = dx * ax + dy * ay;
      const s = along / (length * 0.5); // -1 .. 1
      if (s < -1.4 || s > 1.4) continue;
      const across = -dx * ay + dy * ax - bow * (1 - Math.min(1, s * s));
      const station = Math.min(3.999, Math.max(0, (s + 1) * 2));
      const i = Math.floor(station); const f = station - i;
      const half = Math.max(0.5, knots[i] + (knots[i + 1] - knots[i]) * f);
      const t = across / half; // -1 .. 1 across
      if (t < -1 || t > 1) continue;
      if (s > 1 - cutA * t || s < -1 + cutB * t) continue;
      if (split && s * split.end > split.from && Math.abs(t - split.at) < split.half) continue;
      const wx = ((px % N) + N) % N; const wy = ((py % N) + N) % N;
      const index = wy * N + wx;
      const h = lift + tilt * s + 0.05 * (1 - t * t);
      if (h < height[index] - 0.02) continue; // under what already lies here
      // Fibres along the chip, a darker crack now and then, darker long edges.
      const fibres = 0.62 * fibre(fibreOffset + across * MM / fibreScale, fibreOffset * 0.5 + s * 0.8) + 0.38 * fibre(fibreOffset * 1.3 + across * MM / (fibreScale * 0.45), s * 2.1);
      const crack = fibres < 0.18 ? 0.72 : 1;
      const edge = 1 - 0.3 * Math.max(0, Math.abs(t) - 0.72) / 0.28;
      const shade = (0.8 + 0.36 * fibres) * crack * edge;
      colour[index * 3] = base[0] * shade;
      colour[index * 3 + 1] = base[1] * shade;
      colour[index * 3 + 2] = base[2] * shade;
      height[index] = h;
    }
  }
  painted += 1;
}

// Cavity: darken each pixel by how far it lies below the highest ground round it,
// gaps most, a chip's edge under a higher neighbour a little.
function boxMax(field, radius) {
  const out = new Float32Array(N * N);
  const tmp = new Float32Array(N * N);
  for (let y = 0; y < N; y += 1) for (let x = 0; x < N; x += 1) {
    let m = -1; for (let d = -radius; d <= radius; d += 1) m = Math.max(m, field[y * N + (((x + d) % N) + N) % N]);
    tmp[y * N + x] = m;
  }
  for (let y = 0; y < N; y += 1) for (let x = 0; x < N; x += 1) {
    let m = -1; for (let d = -radius; d <= radius; d += 1) m = Math.max(m, tmp[((((y + d) % N) + N) % N) * N + x]);
    out[y * N + x] = m;
  }
  return out;
}
const near = boxMax(height, Math.round(6 / MM));
for (let i = 0; i < N * N; i += 1) {
  const below = Math.max(0, near[i] - height[i]);
  const cavity = Math.max(0.35, 1 - 1.6 * below);
  colour[i * 3] *= cavity; colour[i * 3 + 1] *= cavity; colour[i * 3 + 2] *= cavity;
}

// Average down to SIZE, encode sRGB and height, write a PNG.
let low = Infinity; let high = -Infinity;
for (let i = 0; i < N * N; i += 1) { low = Math.min(low, height[i]); high = Math.max(high, height[i]); }
const pixels = Buffer.alloc(SIZE * SIZE * 4);
const sums = [0, 0, 0];
for (let y = 0; y < SIZE; y += 1) {
  for (let x = 0; x < SIZE; x += 1) {
    let r = 0; let g = 0; let b = 0; let h = 0;
    for (let sy = 0; sy < SUPER; sy += 1) for (let sx = 0; sx < SUPER; sx += 1) {
      const i = (y * SUPER + sy) * N + x * SUPER + sx;
      r += colour[i * 3]; g += colour[i * 3 + 1]; b += colour[i * 3 + 2]; h += height[i];
    }
    const n = SUPER * SUPER;
    const o = (y * SIZE + x) * 4;
    pixels[o] = toSrgb(r / n); pixels[o + 1] = toSrgb(g / n); pixels[o + 2] = toSrgb(b / n);
    pixels[o + 3] = Math.round(255 * ((h / n - low) / (high - low)));
    sums[0] += pixels[o]; sums[1] += pixels[o + 1]; sums[2] += pixels[o + 2];
  }
}

function crc32(buffer) {
  let crc = ~0;
  for (const byte of buffer) {
    crc ^= byte;
    for (let k = 0; k < 8; k += 1) crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
  }
  return ~crc >>> 0;
}
function chunk(type, data) {
  const length = Buffer.alloc(4); length.writeUInt32BE(data.length);
  const body = Buffer.concat([Buffer.from(type, "ascii"), data]);
  const crc = Buffer.alloc(4); crc.writeUInt32BE(crc32(body));
  return Buffer.concat([length, body, crc]);
}
const header = Buffer.alloc(13);
header.writeUInt32BE(SIZE, 0); header.writeUInt32BE(SIZE, 4);
header[8] = 8; header[9] = 6; header[10] = 0; header[11] = 0; header[12] = 0;
const raw = Buffer.alloc(SIZE * (SIZE * 4 + 1));
for (let y = 0; y < SIZE; y += 1) {
  raw[y * (SIZE * 4 + 1)] = 0;
  pixels.copy(raw, y * (SIZE * 4 + 1) + 1, y * SIZE * 4, (y + 1) * SIZE * 4);
}
const png = Buffer.concat([
  Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  chunk("IHDR", header),
  chunk("IDAT", deflateSync(raw, { level: 9 })),
  chunk("IEND", Buffer.alloc(0)),
]);
writeFileSync(OUT, png);
const count = SIZE * SIZE;
// The gaps' rise as mulch.gdshaderinc reads it (smoothstep of the height up to
// GAP_RISE), averaged over the tile weighted by each texel's brightness: what an
// averaged pixel's light keeps of it far off (MulchGround.GAP_COVER).
const GAP_RISE = 0.3;
let lit = 0;
let litRisen = 0;
for (let i = 0; i < count; i += 1) {
  const o = i * 4;
  const luminance = 0.2126 * toLinear(pixels[o]) + 0.7152 * toLinear(pixels[o + 1]) + 0.0722 * toLinear(pixels[o + 2]);
  const t = Math.min(1, pixels[o + 3] / 255 / GAP_RISE);
  lit += luminance;
  litRisen += luminance * t * t * (3 - 2 * t);
}
console.log(`MULCH_CHIPS ${OUT} ${SIZE}x${SIZE} tile_m=${TILE_M} chips=${painted} mean_srgb=(${(sums[0] / count).toFixed(0)},${(sums[1] / count).toFixed(0)},${(sums[2] / count).toFixed(0)}) gap_cover=${(litRisen / lit).toFixed(3)}`);
