#!/usr/bin/env node
// Checks the built street-car meshes (street_clutter_kit.glb and
// street_car_hero_kit.glb, as committed) for the faults a car body must never
// show: triangles with no area, faces turned inside out (facing against their
// own shading), neighbours wound against each other (a fold), panel gaps and
// shut lines broken into fragments or ending in a wedge wider than the groove
// (a dark notch), see-through spots (a ray from where a
// player or a camera stands, around and above the car, whose first hit on the
// body is a face seen from behind), side windows painted over (a ray
// straight in at a side window that meets anything but glass first), number
// plates hidden (a ray straight in at either plate that meets anything but the
// plate or its characters first), regions in the wrong material (a ray at the
// windshield, the rear glass and each head and tail lamp, aimed where the
// near level draws them, that meets anything else first, at every level)
// and, at the hero level, the cabin poking out (a seat, dashboard or lining
// point with neither shell nor glass above it).
//
//   node tools/check_street_car_meshes.mjs [CLUTTER_KIT.glb HERO_KIT.glb]
//
// Prints one line per failing mesh and exits 1 on any failure;
// CAR_CHECK_VERBOSE=1 also prints each see-through ray.

import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { CALIPER_ANGLE, CAR_BODIES, bodyShape } from "./lib/street-car-kit.mjs";
import { CAR_PARTS } from "./lib/street-car-parts.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const [clutterPath, heroPath] = process.argv.length > 3
  ? process.argv.slice(2, 4)
  : ["game/resources/models/street/street_clutter_kit.glb", "game/resources/models/street/street_car_hero_kit.glb"].map((path) => resolve(projectRoot, path));

// A face smaller than this covers no pixel from any place the game's camera can
// be, so its facing is not judged (m^2).
const MIN_JUDGED_AREA_M2 = 1e-7;
// A broken panel gap: a run of gap triangles shorter than this (m).
const MIN_GAP_RUN_M = 0.04;
// A groove's triangle no wider than this (m: twice its area over its longest
// edge) at the hero level and the others; the groove is 7 mm and 12 mm across.
const MAX_GAP_WIDTH_M = { hero: 0.0085, other: 0.014 };
// A pixel's height (m) on the owner's display (a Mac drawing about 2170 rows
// over a 70 degree view: 0.645 mm a metre away) at the nearest distance each
// level is drawn from: the hero level from about 0.4 m, the near level (a
// seventh car within the hero range draws it) from about 2 m, the far level
// from 43 m (game/scripts/world/street_clutter_kit.gd LOD_NEAR_M less half
// the diagonal of a 24 m clutter cell). A see-through hit counts when at
// least CRACK_RAYS of nine rays half a pixel apart round it see a back face
// too, so a crack a third of a pixel wide fails and only a pinhole passes.
const PIXEL_PER_M = (2 * Math.tan((35 * Math.PI) / 180)) / 2170;
const FOOTPRINT_M = { hero: 0.4 * PIXEL_PER_M, near: 2 * PIXEL_PER_M, far: 43 * PIXEL_PER_M };
const CRACK_RAYS = 3;
// Interior parts (seen through the glass, never from outside directly).
const INTERIOR = new Set(["cabin", "seat", "headliner", "screen"]);
const VERBOSE = process.env.CAR_CHECK_VERBOSE === "1";

// ---------------------------------------------------------------- reading
function readGlb(path) {
  const data = readFileSync(path);
  if (data.readUInt32LE(0) !== 0x46546c67) throw new Error(`${path} is not a binary glTF`);
  const jsonLength = data.readUInt32LE(12);
  const json = JSON.parse(data.subarray(20, 20 + jsonLength).toString("utf8"));
  const binStart = 20 + jsonLength + 8;
  const bin = data.subarray(binStart, binStart + data.readUInt32LE(20 + jsonLength));
  const accessor = (index) => {
    const a = json.accessors[index];
    const view = json.bufferViews[a.bufferView];
    const width = { SCALAR: 1, VEC2: 2, VEC3: 3 }[a.type];
    const offset = view.byteOffset + (a.byteOffset ?? 0);
    const count = a.count * width;
    if (a.componentType === 5126) return new Float32Array(bin.buffer.slice(bin.byteOffset + offset, bin.byteOffset + offset + count * 4));
    if (a.componentType === 5125) return new Uint32Array(bin.buffer.slice(bin.byteOffset + offset, bin.byteOffset + offset + count * 4));
    return new Uint16Array(bin.buffer.slice(bin.byteOffset + offset, bin.byteOffset + offset + count * 2));
  };
  const meshes = new Map();
  for (const mesh of json.meshes) {
    const primitive = mesh.primitives[0];
    meshes.set(mesh.name, {
      positions: accessor(primitive.attributes.POSITION),
      normals: accessor(primitive.attributes.NORMAL),
      uvs: accessor(primitive.attributes.TEXCOORD_0),
      indices: accessor(primitive.indices),
    });
  }
  const markers = new Map();
  for (const node of json.nodes) if (node.mesh === undefined && node.translation) markers.set(node.name, node.translation);
  return { meshes, markers };
}

// ---------------------------------------------------------------- geometry
const sub = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
const cross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
const length = (a) => Math.hypot(a[0], a[1], a[2]);

// Triangles of a mesh (optionally moved: turned rotX radians round X, then
// flipped round Y for a left wheel, then offset by [x, y, z]).
function triangles(mesh, { offset = [0, 0, 0], turned = false, rotX = 0 } = {}) {
  const { positions: P, normals: N, uvs: U, indices: I } = mesh;
  const out = [];
  const [c, s] = [Math.cos(rotX), Math.sin(rotX)];
  const spin = (v) => {
    const r = [v[0], v[1] * c - v[2] * s, v[1] * s + v[2] * c];
    return turned ? [-r[0], r[1], -r[2]] : r;
  };
  const place = (i) => {
    const r = spin([P[i * 3], P[i * 3 + 1], P[i * 3 + 2]]);
    return [offset[0] + r[0], offset[1] + r[1], offset[2] + r[2]];
  };
  const turn = (i) => spin([N[i * 3], N[i * 3 + 1], N[i * 3 + 2]]);
  for (let t = 0; t < I.length; t += 3) {
    const ids = [I[t], I[t + 1], I[t + 2]];
    const p = ids.map(place);
    const n = ids.map(turn);
    const part = CAR_PARTS[Math.min(CAR_PARTS.length - 1, Math.floor(U[ids[0] * 2] * CAR_PARTS.length))];
    const c = cross(sub(p[1], p[0]), sub(p[2], p[0]));
    out.push({ ids, p, n, part, face: c, area: length(c) / 2 });
  }
  return out;
}

// Topology and facing: degenerate, inside-out, wound against a neighbour,
// broken gap runs and gap triangles wider than maxGapWidth (m).
function surfaceFaults(tris, maxGapWidth) {
  const faults = { degenerate: 0, insideOut: 0, insideOutArea: 0, foldEdges: 0, gapFragments: 0, gapWedges: 0, where: [] };
  const key = (p) => `${Math.round(p[0] * 1e5)},${Math.round(p[1] * 1e5)},${Math.round(p[2] * 1e5)}`;
  const ids = new Map();
  const vid = (p) => {
    const k = key(p);
    if (!ids.has(k)) ids.set(k, ids.size);
    return ids.get(k);
  };
  const edges = new Map();
  tris.forEach((tri, index) => {
    if (tri.area < 1e-10) {
      faults.degenerate += 1;
      faults.where.push(["degenerate", tri.p[0]]);
      return;
    }
    if (tri.part === "gap") {
      const longest = Math.max(length(sub(tri.p[1], tri.p[0])), length(sub(tri.p[2], tri.p[1])), length(sub(tri.p[0], tri.p[2])));
      if ((2 * tri.area) / longest > maxGapWidth) {
        faults.gapWedges += 1;
        faults.where.push(["wedge of groove", tri.p[0]]);
      }
    }
    if (tri.area >= MIN_JUDGED_AREA_M2) {
      const shading = [tri.n[0][0] + tri.n[1][0] + tri.n[2][0], tri.n[0][1] + tri.n[1][1] + tri.n[2][1], tri.n[0][2] + tri.n[1][2] + tri.n[2][2]];
      if (dot(tri.face, shading) < 0) {
        faults.insideOut += 1;
        faults.insideOutArea += tri.area;
        faults.where.push(["inside out", tri.p[0]]);
      }
    }
    const v = tri.p.map(vid);
    tri.v = v;
    for (let k = 0; k < 3; k += 1) {
      const a = v[k];
      const b = v[(k + 1) % 3];
      if (a === b) continue;
      const ek = a < b ? `${a}_${b}` : `${b}_${a}`;
      if (!edges.has(ek)) edges.set(ek, []);
      edges.get(ek).push([index, a < b]);
    }
  });
  for (const list of edges.values()) {
    if (list.length === 2 && list[0][1] === list[1][1]) {
      faults.foldEdges += 1;
      faults.where.push(["wound against its neighbour", tris[list[0][0]].p[0]]);
    }
  }
  // Panel gaps: runs of gap triangles joined by edges.
  const gap = tris.map((tri, index) => [tri, index]).filter(([tri]) => tri.part === "gap" && tri.v);
  const parent = new Map(gap.map(([, index]) => [index, index]));
  const find = (x) => {
    while (parent.get(x) !== x) {
      parent.set(x, parent.get(parent.get(x)));
      x = parent.get(x);
    }
    return x;
  };
  for (const list of edges.values()) {
    const members = list.map(([index]) => index).filter((index) => parent.has(index));
    for (let i = 1; i < members.length; i += 1) parent.set(find(members[i]), find(members[0]));
  }
  const runs = new Map();
  for (const [tri, index] of gap) {
    const root = find(index);
    if (!runs.has(root)) runs.set(root, { lo: [Infinity, Infinity, Infinity], hi: [-Infinity, -Infinity, -Infinity] });
    const box = runs.get(root);
    for (const p of tri.p) for (let k = 0; k < 3; k += 1) {
      box.lo[k] = Math.min(box.lo[k], p[k]);
      box.hi[k] = Math.max(box.hi[k], p[k]);
    }
  }
  for (const box of runs.values()) {
    if (length(sub(box.hi, box.lo)) < MIN_GAP_RUN_M) {
      faults.gapFragments += 1;
      faults.where.push(["broken panel gap", box.lo]);
    }
  }
  return faults;
}

// The nearest face along a ray (origin, unit direction), or null.
function rayCaster(tris, bounds) {
  const shell = tris.filter((tri) => tri.area > 1e-12);
  // A uniform grid over the triangles' boxes.
  const cell = 0.12;
  const grid = new Map();
  shell.forEach((tri, index) => {
    const lo = [0, 1, 2].map((k) => Math.min(tri.p[0][k], tri.p[1][k], tri.p[2][k]));
    const hi = [0, 1, 2].map((k) => Math.max(tri.p[0][k], tri.p[1][k], tri.p[2][k]));
    for (let x = Math.floor(lo[0] / cell); x <= Math.floor(hi[0] / cell); x += 1)
      for (let y = Math.floor(lo[1] / cell); y <= Math.floor(hi[1] / cell); y += 1)
        for (let z = Math.floor(lo[2] / cell); z <= Math.floor(hi[2] / cell); z += 1) {
          const k = `${x},${y},${z}`;
          if (!grid.has(k)) grid.set(k, []);
          grid.get(k).push(index);
        }
  });
  // The nearest face along a ray: the grid's cells walked in order (3D DDA).
  const hit = (origin, dir) => {
    let best = Infinity;
    let found = null;
    const seen = new Set();
    const cellIndex = origin.map((v) => Math.floor(v / cell));
    const step = dir.map((v) => (v > 0 ? 1 : v < 0 ? -1 : 0));
    const next = origin.map((v, k) => (dir[k] === 0 ? Infinity : (((cellIndex[k] + (step[k] > 0 ? 1 : 0)) * cell - v) / dir[k])));
    const delta = dir.map((v) => (v === 0 ? Infinity : Math.abs(cell / v)));
    const limit = length(sub(origin, bounds.lo)) + length(sub(bounds.hi, bounds.lo)) + cell;
    let travelled = 0;
    while (travelled < limit && travelled < best) {
      for (const index of grid.get(cellIndex.join(",")) ?? []) {
        if (seen.has(index)) continue;
        seen.add(index);
        const tri = shell[index];
        const e1 = sub(tri.p[1], tri.p[0]);
        const e2 = sub(tri.p[2], tri.p[0]);
        const h = cross(dir, e2);
        const det = dot(e1, h);
        if (Math.abs(det) < 1e-14) continue;
        const f = 1 / det;
        const q = sub(origin, tri.p[0]);
        const u = f * dot(q, h);
        if (u < 0 || u > 1) continue;
        const r = cross(q, e1);
        const v = f * dot(dir, r);
        if (v < 0 || u + v > 1) continue;
        const t = f * dot(e2, r);
        if (t > 1e-6 && t < best) {
          best = t;
          found = tri;
        }
      }
      const k = next[0] < next[1] ? (next[0] < next[2] ? 0 : 2) : next[1] < next[2] ? 1 : 2;
      travelled = next[k];
      next[k] += delta[k];
      cellIndex[k] += step[k];
    }
    return found;
  };
  return hit;
}

// See-through: rays from round the car at a player's and a chase camera's
// heights, aimed into its box; the first face each meets must face it.
function seeThrough(tris, bounds, name = "", footprint = 0) {
  const hit = rayCaster(tris, bounds);
  // The first face drawn along a ray: the game culls back faces, so a cabin
  // face seen from behind (a seat or the lining poking out through the shell)
  // is not drawn and the ray goes on to whatever is drawn behind it.
  const drawn = (origin, unit) => {
    let from = origin;
    let tri = hit(from, unit);
    for (let skip = 0; tri && skip < 8 && INTERIOR.has(tri.part) && dot(tri.face, unit) > 0; skip += 1) {
      const t = dot(sub(tri.p[0], from), tri.face) / dot(unit, tri.face);
      from = [from[0] + unit[0] * (t + 1e-5), from[1] + unit[1] * (t + 1e-5), from[2] + unit[2] * (t + 1e-5)];
      tri = hit(from, unit);
    }
    return tri;
  };
  // Is a back face seen along this ray and most of its neighbours a pixel
  // around it (footprint metres apart)? A crack narrower than a pixel at the
  // nearest distance the level is drawn from shows nothing.
  const seenBehind = (origin, unit) => {
    const tri = drawn(origin, unit);
    return tri !== null && dot(tri.face, unit) > 0;
  };
  const wide = (origin, unit) => {
    if (footprint <= 0) return true;
    const side = length(cross(unit, [0, 1, 0])) > 0.1 ? cross(unit, [0, 1, 0]) : cross(unit, [1, 0, 0]);
    const u = side.map((v) => v / length(side));
    const w = cross(unit, u);
    let behind = 0;
    for (const a of [-0.5, 0, 0.5]) for (const b of [-0.5, 0, 0.5]) {
      const o = [0, 1, 2].map((k) => origin[k] + (u[k] * a + w[k] * b) * footprint);
      if (seenBehind(o, unit)) behind += 1;
    }
    return behind >= CRACK_RAYS;
  };
  const centre = [(bounds.lo[0] + bounds.hi[0]) / 2, (bounds.lo[1] + bounds.hi[1]) / 2, (bounds.lo[2] + bounds.hi[2]) / 2];
  const reach = length(sub(bounds.hi, bounds.lo));
  let random = 12345;
  const next = () => {
    random = (random * 1103515245 + 12345) % 2147483648;
    return random / 2147483648;
  };
  const faults = { rays: 0, backFirst: 0, interiorFirst: 0, where: [] };
  for (let i = 0; i < 2400; i += 1) {
    // From 0.3 m to 4 m up, all round, 1.5 to 3 car lengths out.
    const turn = next() * Math.PI * 2;
    const out = reach * (0.75 + next() * 0.75);
    const origin = [centre[0] + Math.sin(turn) * out, 0.3 + next() * 3.7, centre[2] + Math.cos(turn) * out];
    const target = [lerp(bounds.lo[0], bounds.hi[0], next()), lerp(bounds.lo[1], bounds.hi[1], next()), lerp(bounds.lo[2], bounds.hi[2], next())];
    const dir = sub(target, origin);
    const l = length(dir);
    const unit = [dir[0] / l, dir[1] / l, dir[2] / l];
    const tri = drawn(origin, unit);
    if (!tri) continue;
    faults.rays += 1;
    if (dot(tri.face, unit) > 0 && wide(origin, unit)) {
      faults.backFirst += 1;
      faults.where.push([`seen from behind (${tri.part})`, tri.p[0]]);
      if (VERBOSE) console.log(`  ${name}: ray from ${origin.map((v) => v.toFixed(3))} to ${target.map((v) => v.toFixed(3))} meets the back of ${tri.part} ${tri.p.map((q) => q.map((v) => v.toFixed(3)).join(",")).join(" | ")}`);
    } else if (INTERIOR.has(tri.part)) {
      faults.interiorFirst += 1;
      faults.where.push([`interior seen through the shell (${tri.part})`, tri.p[0]]);
      if (VERBOSE) console.log(`  ${name}: ray from ${origin.map((v) => v.toFixed(3))} to ${target.map((v) => v.toFixed(3))} meets ${tri.part} first ${tri.p.map((q) => q.map((v) => v.toFixed(3)).join(",")).join(" | ")}`);
    }
  }
  return faults;
}
const lerp = (a, b, t) => a + (b - a) * t;

// Side windows: rays straight in at each side's glass, between the windshield
// and where the side glass ends (clear of the pillars), low, middle and high
// between the belt and the roof; the first face each meets must be glass (the
// hero level's darker rear glass included).
const GLASS_PARTS = new Set(["glass", "grille"]);
function paintedWindows(tris, bounds, bodyName, hero) {
  const body = CAR_BODIES[bodyName];
  const shape = bodyShape(bodyName);
  const cab = body.cabin;
  const hit = rayCaster(tris, bounds);
  const end = body.pillars.cargo_from ?? (body.bed ? cab.rear_base - 0.1 : cab.roof_end);
  const faults = { rays: 0, painted: 0, where: [] };
  for (let zf = cab.windshield_top + 0.1; zf < end - 0.25; zf += 0.12) {
    if ([body.pillars.b, body.pillars.c].some((pillar) => pillar && Math.abs(zf - pillar) < 0.12)) continue;
    const belt = shape.top(zf);
    // A high-roof van's side glass stops at glass_top, under its painted side.
    const top = cab.glass_top ? cab.glass_top - 0.02 : cab.roof;
    for (const up of [0.3, 0.5, 0.7]) {
      const y = lerp(belt, top, up);
      for (const side of [1, -1]) {
        const tri = hit([side * (shape.W + 1), y, zf - shape.L / 2], [-side, 0, 0]);
        faults.rays += 1;
        if (tri && (hero ? GLASS_PARTS : new Set(["glass"])).has(tri.part)) continue;
        faults.painted += 1;
        faults.where.push([`${tri ? tri.part : "nothing"} where the side glass is`, [side * shape.W, y, zf - shape.L / 2]]);
      }
    }
  }
  return faults;
}

// Number plates: rays straight in at each face's plate, over a grid across
// it; the first face each meets must be the plate or its characters.
const PLATE_PARTS = new Set(["plate", "rubber"]);
function hiddenPlates(tris, bounds) {
  const hit = rayCaster(tris, bounds);
  const faults = { rays: 0, hidden: 0, where: [] };
  for (const front of [true, false]) {
    const plate = tris.filter((tri) => tri.part === "plate" && (front ? tri.p[0][2] < 0 : tri.p[0][2] > 0));
    if (plate.length === 0) {
      faults.hidden += 1;
      faults.where.push([`no ${front ? "front" : "rear"} plate`, [0, 0, front ? bounds.lo[2] : bounds.hi[2]]]);
      continue;
    }
    const { lo, hi } = boundsOf(plate);
    for (let i = 1; i < 12; i += 1) {
      for (let j = 1; j < 6; j += 1) {
        const x = lerp(lo[0], hi[0], i / 12);
        const y = lerp(lo[1], hi[1], j / 6);
        const tri = hit([x, y, front ? bounds.lo[2] - 1 : bounds.hi[2] + 1], [0, 0, front ? 1 : -1]);
        faults.rays += 1;
        if (tri && PLATE_PARTS.has(tri.part)) continue;
        faults.hidden += 1;
        faults.where.push([`${tri ? tri.part : "nothing"} over the ${front ? "front" : "rear"} plate`, [x, y, front ? lo[2] : hi[2]]]);
      }
    }
  }
  return faults;
}

// Materials: every level of every body draws its windshield and (unless a
// van's rear doors stand there) rear glass as glass, its head and tail lamps
// as lamps, both sides. Each region's probe is the near level's own triangle
// nearest that region's middle; a ray straight in at it must meet the
// region's material first at each level.
const HEAD_PARTS = new Set(["head_lamp", "lamp_housing", "lamp_drl", "lamp_amber", "chrome", "mirror"]);
const TAIL_PARTS = new Set(["tail_lamp", "lamp_red", "lamp_white"]);
function materialProbes(near, bodyName) {
  const unit = (v) => {
    const l = length(v);
    return l > 0 ? v.map((x) => x / l) : v;
  };
  const probe = (label, keep, want) => {
    const picked = near.filter((tri) => tri.area > 1e-6 && keep(tri, unit(tri.face)));
    if (picked.length === 0) return { label, want, missing: true };
    let area = 0;
    const mid = [0, 0, 0];
    for (const tri of picked) {
      area += tri.area;
      for (let k = 0; k < 3; k += 1) mid[k] += (tri.area * (tri.p[0][k] + tri.p[1][k] + tri.p[2][k])) / 3;
    }
    const centre = mid.map((v) => v / area);
    let best = null;
    let bestD = Infinity;
    for (const tri of picked) {
      const c = [0, 1, 2].map((k) => (tri.p[0][k] + tri.p[1][k] + tri.p[2][k]) / 3);
      const d = length(sub(c, centre));
      if (d < bestD) {
        bestD = d;
        best = { point: c, normal: unit(tri.face) };
      }
    }
    return { label, want, ...best };
  };
  const glass = (tri) => tri.part === "glass";
  const probes = [
    probe("windshield", (tri, n) => glass(tri) && n[2] < -0.3 && n[1] > 0.15, new Set(["glass"])),
  ];
  if (CAR_BODIES[bodyName].doors?.rear !== "barn") probes.push(probe("rear glass", (tri, n) => glass(tri) && n[2] > 0.3 && Math.abs(n[0]) < 0.7, new Set(["glass", "grille"])));
  // Lamps: outboard (not the third brake light) and within 0.7 m of their end.
  const { lo, hi } = boundsOf(near);
  const middle = (tri) => [0, 1, 2].map((k) => (tri.p[0][k] + tri.p[1][k] + tri.p[2][k]) / 3);
  for (const [side, sign] of [["right", 1], ["left", -1]]) {
    probes.push(probe(`${side} head lamp`, (tri, n) => HEAD_PARTS.has(tri.part) && tri.part !== "chrome" && tri.part !== "mirror" && sign * middle(tri)[0] > 0.3 && middle(tri)[2] < lo[2] + 0.7 && n[2] < -0.2, HEAD_PARTS));
    probes.push(probe(`${side} tail lamp`, (tri, n) => TAIL_PARTS.has(tri.part) && sign * middle(tri)[0] > 0.3 && middle(tri)[2] > hi[2] - 0.7 && n[2] > 0.2, TAIL_PARTS));
  }
  return probes;
}
function wrongMaterials(tris, bounds, probes) {
  const hit = rayCaster(tris, bounds);
  const faults = { rays: 0, wrong: 0, where: [] };
  for (const p of probes) {
    faults.rays += 1;
    if (p.missing) {
      faults.wrong += 1;
      faults.where.push([`no ${p.label} at the near level`, [0, 0, 0]]);
      continue;
    }
    const tri = hit(p.point.map((v, k) => v + p.normal[k] * 0.6), p.normal.map((v) => -v));
    if (tri && p.want.has(tri.part)) continue;
    faults.wrong += 1;
    faults.where.push([`${tri ? tri.part : "nothing"} where the ${p.label} is`, p.point]);
  }
  return faults;
}

// The cabin inside the shell: from every seat, dashboard and lining point
// higher than a sill (0.6 m), a ray straight up must meet the shell or the
// glass, or the point pokes out through the roof, a pillar or the glass.
const SILL_Y_M = 0.6;
function cabinOutside(interior, shell) {
  const cell = 0.1;
  const grid = new Map();
  shell.forEach((tri, index) => {
    const xs = tri.p.map((q) => q[0]);
    const zs = tri.p.map((q) => q[2]);
    for (let x = Math.floor(Math.min(...xs) / cell); x <= Math.floor(Math.max(...xs) / cell); x += 1)
      for (let z = Math.floor(Math.min(...zs) / cell); z <= Math.floor(Math.max(...zs) / cell); z += 1) {
        const key = `${x},${z}`;
        if (!grid.has(key)) grid.set(key, []);
        grid.get(key).push(index);
      }
  });
  // The height of a triangle over a plan point, or null outside it.
  const above = (q, tri) => {
    const [a, b, c] = tri.p;
    const d = (b[2] - c[2]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[2] - c[2]);
    if (Math.abs(d) < 1e-14) return null;
    const l1 = ((b[2] - c[2]) * (q[0] - c[0]) + (c[0] - b[0]) * (q[2] - c[2])) / d;
    const l2 = ((c[2] - a[2]) * (q[0] - c[0]) + (a[0] - c[0]) * (q[2] - c[2])) / d;
    const l3 = 1 - l1 - l2;
    if (l1 < 0 || l2 < 0 || l3 < 0) return null;
    return l1 * a[1] + l2 * b[1] + l3 * c[1];
  };
  const faults = { points: 0, outside: 0, where: [] };
  const seen = new Set();
  for (const tri of interior) {
    for (const q of tri.p) {
      const key = q.join();
      if (q[1] < SILL_Y_M || seen.has(key)) continue;
      seen.add(key);
      faults.points += 1;
      const near = grid.get(`${Math.floor(q[0] / cell)},${Math.floor(q[2] / cell)}`) ?? [];
      if (near.some((index) => (above(q, shell[index]) ?? -Infinity) > q[1] + 1e-4)) continue;
      faults.outside += 1;
      faults.where.push([`${tri.part} with no shell or glass above it`, q]);
    }
  }
  return faults;
}

// ---------------------------------------------------------------- the check
function boundsOf(tris) {
  const lo = [Infinity, Infinity, Infinity];
  const hi = [-Infinity, -Infinity, -Infinity];
  for (const tri of tris) for (const p of tri.p) for (let k = 0; k < 3; k += 1) {
    lo[k] = Math.min(lo[k], p[k]);
    hi[k] = Math.max(hi[k], p[k]);
  }
  return { lo, hi };
}

function main() {
  const clutter = readGlb(clutterPath);
  const hero = readGlb(heroPath);
  const bodies = [...clutter.meshes.keys()].filter((name) => /^car_[a-z]+_lod0$/.test(name)).map((name) => name.slice(4, -5));
  if (bodies.length === 0) throw new Error(`${clutterPath} has no car meshes`);
  const failures = [];
  const report = (name, kind, count, where) => {
    const at = where.slice(0, 3).map(([what, p]) => `${what} at ${p.map((v) => v.toFixed(3)).join(",")}`).join("; ");
    failures.push(`${name}: ${count} ${kind}${at ? ` (${at})` : ""}`);
  };
  for (const body of bodies) {
    const levels = [];
    for (const suffix of ["lod0", "lod1", "shadow", "chassis_lod0", "tyre_lod0"]) {
      const mesh = clutter.meshes.get(`car_${body}_${suffix}`);
      if (mesh) levels.push([`car_${body}_${suffix}`, triangles(mesh), suffix === "lod0" || suffix === "lod1"]);
    }
    const front = clutter.markers.get(`car_${body}_axle_front`);
    const rear = clutter.markers.get(`car_${body}_axle_rear`);
    const heroBody = hero.meshes.get(`car_${body}_hero_body`);
    if (heroBody && front && rear) {
      const shell = [...triangles(heroBody), ...triangles(hero.meshes.get(`car_${body}_hero_glass`))];
      const tyre = hero.meshes.get(`car_${body}_hero_tyre`);
      const brake = hero.meshes.get(`car_${body}_hero_brake`);
      // Wheels and brakes as the game places them (street_clutter_kit.gd
      // wheel_transforms): a left brake turned so its caliper stays behind.
      for (const centre of [front, rear]) {
        shell.push(...triangles(tyre, { offset: centre }), ...triangles(tyre, { offset: [-centre[0], centre[1], centre[2]], turned: true }));
        shell.push(...triangles(brake, { offset: centre }), ...triangles(brake, { offset: [-centre[0], centre[1], centre[2]], turned: true, rotX: 2 * CALIPER_ANGLE - Math.PI }));
      }
      levels.push([`car_${body}_hero`, shell, true]);
      const c = cabinOutside(shell.filter((tri) => INTERIOR.has(tri.part)), shell.filter((tri) => !INTERIOR.has(tri.part)));
      if (c.outside) report(`car_${body}_hero`, `cabin points of ${c.points} poking out of the shell`, c.outside, c.where);
      for (const piece of ["glass", "tyre", "brake"]) levels.push([`car_${body}_hero_${piece}`, triangles(hero.meshes.get(`car_${body}_hero_${piece}`)), false]);
    }
    const nearMesh = clutter.meshes.get(`car_${body}_lod0`);
    const probes = nearMesh ? materialProbes(triangles(nearMesh), body) : [];
    for (const [name, tris, rays] of levels) {
      const s = surfaceFaults(tris, name.includes("_hero") ? MAX_GAP_WIDTH_M.hero : MAX_GAP_WIDTH_M.other);
      if (s.degenerate) report(name, "triangles with no area", s.degenerate, s.where.filter(([w]) => w === "degenerate"));
      if (s.insideOut) report(name, `faces turned inside out (${(s.insideOutArea * 1e4).toFixed(2)} cm2)`, s.insideOut, s.where.filter(([w]) => w === "inside out"));
      if (s.foldEdges) report(name, "edges whose two faces are wound against each other", s.foldEdges, s.where.filter(([w]) => w.startsWith("wound")));
      if (s.gapFragments) report(name, "broken panel gaps", s.gapFragments, s.where.filter(([w]) => w.startsWith("broken")));
      if (s.gapWedges) report(name, "groove triangles wider than the groove", s.gapWedges, s.where.filter(([w]) => w.startsWith("wedge")));
      if (rays) {
        const r = seeThrough(tris, boundsOf(tris), name, FOOTPRINT_M[name.endsWith("_hero") ? "hero" : name.endsWith("_lod1") ? "far" : "near"]);
        if (r.backFirst || r.interiorFirst) report(name, `see-through hits of ${r.rays} rays`, r.backFirst + r.interiorFirst, r.where);
        const w = paintedWindows(tris, boundsOf(tris), body, name.endsWith("_hero"));
        if (w.painted) report(name, `side-window rays of ${w.rays} meeting no glass`, w.painted, w.where);
        const p = hiddenPlates(tris, boundsOf(tris));
        if (p.hidden) report(name, `plate rays of ${p.rays} meeting no plate`, p.hidden, p.where);
        const m = wrongMaterials(tris, boundsOf(tris), probes);
        if (m.wrong) report(name, `material probes of ${m.rays} meeting the wrong material`, m.wrong, m.where);
      }
    }
  }
  if (failures.length) {
    for (const line of failures) console.log(`FAIL ${line}`);
    console.log(`FAIL street car meshes: ${failures.length} faults in ${bodies.length} bodies`);
    process.exit(1);
  }
  console.log(`PASS street car meshes: ${bodies.length} bodies, every level, no faults`);
}

main();
