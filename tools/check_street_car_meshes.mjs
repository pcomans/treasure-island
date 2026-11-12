#!/usr/bin/env node
// Checks the built street-car meshes (street_clutter_kit.glb and
// street_car_hero_kit.glb, as committed) for the faults a car body must never
// show: triangles with no area, faces turned inside out (facing against their
// own shading), neighbours wound against each other (a fold), panel gaps and
// shut lines broken into fragments or ending in a wedge wider than the groove
// (a dark notch), see-through spots (a ray from where a
// player or a camera stands, around and above the car, whose first hit on the
// body is a face seen from behind) and side windows painted over (a ray
// straight in at a side window that meets anything but glass first).
//
//   node tools/check_street_car_meshes.mjs [CLUTTER_KIT.glb HERO_KIT.glb]
//
// Prints one line per failing mesh and exits 1 on any failure;
// CAR_CHECK_VERBOSE=1 also prints each see-through ray.

import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { CAR_BODIES, bodyShape } from "./lib/street-car-kit.mjs";
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

// Triangles of a mesh (optionally moved: [x, y, z] offset, flipped round Y for a left wheel).
function triangles(mesh, { offset = [0, 0, 0], turned = false } = {}) {
  const { positions: P, normals: N, uvs: U, indices: I } = mesh;
  const out = [];
  const place = (i) => (turned ? [offset[0] - P[i * 3], offset[1] + P[i * 3 + 1], offset[2] - P[i * 3 + 2]] : [offset[0] + P[i * 3], offset[1] + P[i * 3 + 1], offset[2] + P[i * 3 + 2]]);
  const turn = (i) => (turned ? [-N[i * 3], N[i * 3 + 1], -N[i * 3 + 2]] : [N[i * 3], N[i * 3 + 1], N[i * 3 + 2]]);
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
function seeThrough(tris, bounds, name = "") {
  const hit = rayCaster(tris, bounds);
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
    const tri = hit(origin, unit);
    if (!tri) continue;
    faults.rays += 1;
    if (dot(tri.face, unit) > 0) {
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
    for (const up of [0.3, 0.5, 0.7]) {
      const y = lerp(belt, cab.roof, up);
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
      for (const centre of [front, rear]) {
        shell.push(...triangles(tyre, { offset: centre }), ...triangles(tyre, { offset: [-centre[0], centre[1], centre[2]], turned: true }));
      }
      levels.push([`car_${body}_hero`, shell, true]);
      for (const piece of ["glass", "tyre", "brake"]) levels.push([`car_${body}_hero_${piece}`, triangles(hero.meshes.get(`car_${body}_hero_${piece}`)), false]);
    }
    for (const [name, tris, rays] of levels) {
      const s = surfaceFaults(tris, name.includes("_hero") ? MAX_GAP_WIDTH_M.hero : MAX_GAP_WIDTH_M.other);
      if (s.degenerate) report(name, "triangles with no area", s.degenerate, s.where.filter(([w]) => w === "degenerate"));
      if (s.insideOut) report(name, `faces turned inside out (${(s.insideOutArea * 1e4).toFixed(2)} cm2)`, s.insideOut, s.where.filter(([w]) => w === "inside out"));
      if (s.foldEdges) report(name, "edges whose two faces are wound against each other", s.foldEdges, s.where.filter(([w]) => w.startsWith("wound")));
      if (s.gapFragments) report(name, "broken panel gaps", s.gapFragments, s.where.filter(([w]) => w.startsWith("broken")));
      if (s.gapWedges) report(name, "groove triangles wider than the groove", s.gapWedges, s.where.filter(([w]) => w.startsWith("wedge")));
      if (rays) {
        const r = seeThrough(tris, boundsOf(tris), name);
        if (r.backFirst || r.interiorFirst) report(name, `see-through hits of ${r.rays} rays`, r.backFirst + r.interiorFirst, r.where);
        const w = paintedWindows(tris, boundsOf(tris), body, name.endsWith("_hero"));
        if (w.painted) report(name, `side-window rays of ${w.rays} meeting no glass`, w.painted, w.where);
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
