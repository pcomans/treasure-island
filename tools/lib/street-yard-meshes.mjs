// The yard kit's meshes (the registry, footprints and container-wall layout
// are in tools/lib/street-yard-kit.mjs). Every mesh has two detail levels:
// _lod0 for near views (frames, door hardware, wheel faces, window frames) and
// _lod1 for distance (the same silhouette, panels flush, no small parts). Long
// props are modules the runtime repeats along Z (shed and fabric-shed bays,
// berm modules, their ends), so any length is a few instances of one mesh.
//
// Geometry conventions: see tools/lib/street-yard-kit.mjs (front -Z, +Y up,
// +X right, origin on the ground under the middle). Counterclockwise triangles
// seen from outside (glTF front faces); MeshBuilder orients each face from the
// normal it is given.

import earcut from "earcut";

import { buildCar, clamp, lerp, MeshBuilder, v3, vadd, vcross, vdot, vlen, vnorm, vscale, vsub } from "./street-clutter-kit.mjs";
import { CONTAINER_LENGTHS, CONVEYOR_FOOT_M, CONVEYOR_INCLINE, CONVEYOR_MODULE_M, YARD_KIT_PART_SLOTS, YARD_KIT_PARTS } from "./street-yard-kit.mjs";

const P = Object.freeze(Object.fromEntries(YARD_KIT_PARTS.map((name, index) => [name, index])));
const X = v3(1, 0, 0);
const Y = v3(0, 1, 0);
const Z = v3(0, 0, 1);
const NX = v3(-1, 0, 0);
const NY = v3(0, -1, 0);
const NZ = v3(0, 0, -1);

// A small deterministic hash in [0, 1) for jitter and noise.
function hash(...values) {
  let h = 2166136261;
  for (const value of values) {
    const v = Math.round(value * 1000) | 0;
    h ^= v & 0xff;
    h = Math.imul(h, 16777619);
    h ^= (v >>> 8) & 0xff;
    h = Math.imul(h, 16777619);
    h ^= (v >>> 16) & 0xffff;
    h = Math.imul(h, 16777619);
  }
  h ^= h >>> 13;
  h = Math.imul(h, 0x5bd1e995);
  h ^= h >>> 15;
  return (h >>> 0) / 4294967296;
}

function smoothstep(edge0, edge1, x) {
  const t = clamp((x - edge0) / (edge1 - edge0), 0, 1);
  return t * t * (3 - 2 * t);
}

// ---------------------------------------------------------------- builder
class YardBuilder extends MeshBuilder {
  // lod: the detail level being built (swept bodies use fewer round slices far away).
  constructor(lod = 0) {
    super(YARD_KIT_PART_SLOTS);
    this.lod = lod;
  }

  // A planar quad from four corners (in order around it), facing `normal`.
  // Its winding comes from the whole outline (Newell), so a quad with two
  // corners in one point (a disc's centre) still faces the right way.
  face(corners, normal, part, ao = [1, 1, 1, 1]) {
    const [a, b, c, d] = corners;
    let n = v3(0, 0, 0);
    for (let i = 0; i < 4; i += 1) n = vadd(n, vcross(corners[i], corners[(i + 1) % 4]));
    const aoList = typeof ao === "number" ? [ao, ao, ao, ao] : ao;
    if (vdot(n, normal) >= 0) this.quad(a, b, c, d, [normal, normal, normal, normal], part, aoList);
    else this.quad(a, d, c, b, [normal, normal, normal, normal], part, [aoList[0], aoList[3], aoList[2], aoList[1]]);
  }

  // A triangle facing `normal`.
  tri(a, b, c, normal, part, ao = 1) {
    const n = vcross(vsub(b, a), vsub(c, a));
    if (vdot(n, normal) >= 0) this.triangle(a, b, c, [normal, normal, normal], part, [ao, ao, ao]);
    else this.triangle(a, c, b, [normal, normal, normal], part, [ao, ao, ao]);
  }

  // A rectangle on the plane through `origin` spanned by unit vectors u and v,
  // covering u0..u1 and v0..v1, facing `normal`, with holes [{u0, u1, v0, v1,
  // part}] cut out and filled with their own part (coplanar, so nothing
  // fights for depth). Holes must not overlap.
  panel(origin, u, v, u0, u1, v0, v1, normal, part, { holes = [], ao = 1 } = {}) {
    const at = (a, b) => vadd(origin, vadd(vscale(u, a), vscale(v, b)));
    const inside = holes.filter((hole) => hole.u1 > u0 && hole.u0 < u1 && hole.v1 > v0 && hole.v0 < v1)
      .map((hole) => ({ ...hole, u0: Math.max(u0, hole.u0), u1: Math.min(u1, hole.u1), v0: Math.max(v0, hole.v0), v1: Math.min(v1, hole.v1) }));
    // Split into a grid on every hole edge; each cell takes its hole's part or the panel's.
    const us = [...new Set([u0, u1, ...inside.flatMap((hole) => [hole.u0, hole.u1])].map((value) => Math.round(value * 1e5) / 1e5))].sort((a, b) => a - b);
    const vs = [...new Set([v0, v1, ...inside.flatMap((hole) => [hole.v0, hole.v1])].map((value) => Math.round(value * 1e5) / 1e5))].sort((a, b) => a - b);
    const aoOf = typeof ao === "function" ? ao : () => ao;
    for (let i = 0; i < us.length - 1; i += 1) {
      for (let j = 0; j < vs.length - 1; j += 1) {
        const cu = (us[i] + us[i + 1]) / 2;
        const cv = (vs[j] + vs[j + 1]) / 2;
        const hole = inside.find((candidate) => cu > candidate.u0 && cu < candidate.u1 && cv > candidate.v0 && cv < candidate.v1);
        if (hole?.part === null) continue;
        const cellPart = hole ? hole.part : part;
        this.face([at(us[i], vs[j]), at(us[i + 1], vs[j]), at(us[i + 1], vs[j + 1]), at(us[i], vs[j + 1])], normal, cellPart,
          [aoOf(us[i], vs[j]), aoOf(us[i + 1], vs[j]), aoOf(us[i + 1], vs[j + 1]), aoOf(us[i], vs[j + 1])]);
      }
    }
  }

  // An axis-aligned box from min to max. part: a part or a function of the face
  // name (+x, -x, +y, -y, +z, -z), null leaves that face out; ao likewise.
  aabb(min, max, part, { ao = 1, holes = {} } = {}) {
    const [x0, y0, z0] = min;
    const [x1, y1, z1] = max;
    const partOf = typeof part === "function" ? part : () => part;
    const aoOf = typeof ao === "function" ? ao : () => ao;
    const faces = [
      ["+x", v3(x1, 0, 0), Z, Y, z0, z1, y0, y1, X],
      ["-x", v3(x0, 0, 0), Z, Y, z0, z1, y0, y1, NX],
      ["+y", v3(0, y1, 0), X, Z, x0, x1, z0, z1, Y],
      ["-y", v3(0, y0, 0), X, Z, x0, x1, z0, z1, NY],
      ["+z", v3(0, 0, z1), X, Y, x0, x1, y0, y1, Z],
      ["-z", v3(0, 0, z0), X, Y, x0, x1, y0, y1, NZ],
    ];
    for (const [name, origin, u, v, a0, a1, b0, b1, normal] of faces) {
      const facePart = partOf(name);
      if (facePart === null || facePart === undefined) continue;
      this.panel(origin, u, v, a0, a1, b0, b1, normal, facePart, { holes: holes[name] ?? [], ao: aoOf(name) });
    }
  }

  // A beam of section w x h from a to b; `up` orients its h side.
  beam(a, b, w, h, part, up = Y) {
    const along = vnorm(vsub(b, a));
    let side = vcross(along, up);
    if (vlen(side) < 1e-6) side = vcross(along, X);
    side = vnorm(side);
    const top = vnorm(vcross(side, along));
    this.box(vscale(vadd(a, b), 0.5), [w / 2, h / 2, vlen(vsub(b, a)) / 2], part, [side, top, along]);
  }

  // A closed cylinder (or open ends) from `base` along unit `axis`.
  cylinder(base, axis, radius, length, sides, part, { caps = true, phase = 0, ao = 1 } = {}) {
    const profile = caps ? [[0, 0], [radius, 0], [radius, length], [0, length]] : [[radius, 0], [radius, length]];
    this.lathe(base, axis, profile, sides, () => part, phase, () => ao);
  }
}

// A planar polygon (in a plane with unit axes u, v through origin) with holes,
// triangulated with earcut; points are [u, v] pairs.
function polygonFace(out, origin, u, v, outer, holes, normal, part, ao = 1) {
  const flat = [];
  const holeStarts = [];
  const points = [];
  for (const ring of [outer, ...holes]) {
    if (ring !== outer) holeStarts.push(points.length);
    for (const point of ring) {
      flat.push(point[0], point[1]);
      points.push(point);
    }
  }
  const indices = earcut(flat, holeStarts, 2);
  const at = (point) => vadd(origin, vadd(vscale(u, point[0]), vscale(v, point[1])));
  for (let index = 0; index < indices.length; index += 3) {
    out.tri(at(points[indices[index]]), at(points[indices[index + 1]]), at(points[indices[index + 2]]), normal, part, ao);
  }
}

// ---------------------------------------------------------------- swept bodies
// A vehicle or cabin body: a side profile in (z, y), extruded across X to
// ±hw with rounded side edges of radius r (a quarter circle in `steps`).
// Profile points run counterclockwise seen from +X (z to the left... any
// winding works: faces are oriented by the profile's centroid). Each profile
// edge is swept as a band; partEdge(j, mid, band) names the part of edge j
// (mid: its [z, y] midpoint, band: "face" across the flat middle of the
// width, "round" over the rounded edges); return null to leave it out.
// side: {part, holes: [{points: [[z, y]...], part}]} draws the two flat side
// faces (holes filled with their own part, coplanar).
function sweptBody(out, { profile, hw, r = 0.08, steps = 3, partEdge, side, smoothDeg = 30, aoEdge = () => 1 }) {
  // The far level draws rounded window corners chamfered.
  if (side && out.lod > 0) side = { ...side, holes: (side.holes ?? []).map((hole) => (hole.rect ? { ...hole, points: hole.rect } : hole)) };
  const n = profile.length;
  // Orientation: outward normals of the profile edges in the (z, y) plane.
  let area = 0;
  for (let i = 0; i < n; i += 1) {
    const [z0, y0] = profile[i];
    const [z1, y1] = profile[(i + 1) % n];
    area += z0 * y1 - z1 * y0;
  }
  const ccw = area > 0;
  const edgeNormal = (i) => {
    const [z0, y0] = profile[i];
    const [z1, y1] = profile[(i + 1) % n];
    const dz = z1 - z0;
    const dy = y1 - y0;
    const l = Math.hypot(dz, dy) || 1;
    // Outward: rotate the edge direction by -90 degrees for a counterclockwise ring.
    return ccw ? [dy / l, -dz / l] : [-dy / l, dz / l];
  };
  const normals = profile.map((_, i) => edgeNormal(i));
  // Inset polygon by d (mitred), for the rounded side edges. A vertex moves
  // no further than 0.45 of its shorter edge, so short edges at concave corners
  // (wheel arches, cab steps) don't fold over.
  const edgeLength = (i) => Math.hypot(profile[(i + 1) % n][0] - profile[i][0], profile[(i + 1) % n][1] - profile[i][1]);
  const inset = (d) => profile.map((point, i) => {
    const before = normals[(i - 1 + n) % n];
    const after = normals[i];
    const sum = [before[0] + after[0], before[1] + after[1]];
    const l = Math.hypot(sum[0], sum[1]);
    const miter = l > 1e-9 ? [sum[0] / l, sum[1] / l] : after;
    const cos = Math.max(0.35, miter[0] * after[0] + miter[1] * after[1]);
    const reach = Math.min(d / cos, 0.45 * Math.min(edgeLength((i - 1 + n) % n), edgeLength(i)) + d * 0.2);
    return [point[0] - miter[0] * reach, point[1] - miter[1] * reach];
  });
  // Slices over the rounded edge: from the flat middle (a = 0: x = hw - r,
  // the full profile) out to the side face (a = 90 deg: x = hw, inset by r).
  const rings = [];
  for (let s = 0; s <= steps; s += 1) {
    const a = (Math.PI / 2) * (s / steps);
    const d = r * (1 - Math.cos(a));
    rings.push({ x: hw - r + r * Math.sin(a), d, a, points: inset(d) });
  }
  // Smoothed vertex normals across edges meeting at a shallow angle.
  const cosSmooth = Math.cos((smoothDeg * Math.PI) / 180);
  const vertexNormal = (i, edge) => {
    const own = normals[edge];
    const other = i === edge ? normals[(edge - 1 + n) % n] : normals[(edge + 1) % n];
    if (own[0] * other[0] + own[1] * other[1] < cosSmooth) return own;
    const s = [own[0] + other[0], own[1] + other[1]];
    const l = Math.hypot(s[0], s[1]) || 1;
    return [s[0] / l, s[1] / l];
  };
  // The normal over the rounded edge: the profile's at the middle, ±X at the side face.
  const normal3 = (nzy, a, sign) => vnorm(v3(sign * Math.sin(a), nzy[1] * Math.cos(a), nzy[0] * Math.cos(a)));
  for (let j = 0; j < n; j += 1) {
    const j1 = (j + 1) % n;
    const mid = [(profile[j][0] + profile[j1][0]) / 2, (profile[j][1] + profile[j1][1]) / 2];
    const n0 = vertexNormal(j, j);
    const n1 = vertexNormal(j1, j);
    // The flat middle band across the width.
    const facePart = partEdge(j, mid, "face");
    const ao = aoEdge(j, mid);
    if (facePart !== null && facePart !== undefined) {
      const ring = rings[0];
      const p = (i, sign) => v3(sign * ring.x, ring.points[i][1], ring.points[i][0]);
      const nn0 = v3(0, n0[1], n0[0]);
      const nn1 = v3(0, n1[1], n1[0]);
      const [a, b, c, d] = [p(j, 1), p(j1, 1), p(j1, -1), p(j, -1)];
      if (vdot(vcross(vsub(b, a), vsub(c, a)), vadd(nn0, nn1)) >= 0) out.quad(a, b, c, d, [nn0, nn1, nn1, nn0], facePart, [ao, ao, ao, ao]);
      else out.quad(a, d, c, b, [nn0, nn0, nn1, nn1], facePart, [ao, ao, ao, ao]);
    }
    const roundPart = partEdge(j, mid, "round");
    if (roundPart === null || roundPart === undefined) continue;
    for (let s = 0; s < rings.length - 1; s += 1) {
      const ra = rings[s];
      const rb = rings[s + 1];
      for (const sign of [1, -1]) {
        const pa0 = v3(sign * ra.x, ra.points[j][1], ra.points[j][0]);
        const pa1 = v3(sign * ra.x, ra.points[j1][1], ra.points[j1][0]);
        const pb1 = v3(sign * rb.x, rb.points[j1][1], rb.points[j1][0]);
        const pb0 = v3(sign * rb.x, rb.points[j][1], rb.points[j][0]);
        const na0 = normal3(n0, ra.a, sign);
        const na1 = normal3(n1, ra.a, sign);
        const nb1 = normal3(n1, rb.a, sign);
        const nb0 = normal3(n0, rb.a, sign);
        const cross = vcross(vsub(pa1, pa0), vsub(pb1, pa0));
        const avg = vadd(vadd(na0, na1), vadd(nb0, nb1));
        if (vdot(cross, avg) >= 0) out.quad(pa0, pa1, pb1, pb0, [na0, na1, nb1, nb0], roundPart, [ao, ao, ao, ao]);
        else out.quad(pa0, pb0, pb1, pa1, [na0, nb0, nb1, na1], roundPart, [ao, ao, ao, ao]);
      }
    }
  }
  // Side faces: the inset profile at x = ±hw, with coplanar holes.
  if (side) {
    const ring = rings.at(-1).points;
    const outer = ring.map((point) => [point[0], point[1]]);
    for (const sign of [1, -1]) {
      // A hole may belong to one side only (a door on the right).
      const holes = (side.holes ?? []).filter((hole) => !hole.side || hole.side === sign);
      polygonFace(out, v3(sign * hw, 0, 0), Z, Y, outer, holes.map((hole) => hole.points), v3(sign, 0, 0), side.part, side.ao ?? 1);
      for (const hole of holes) {
        // A hole is filled with its part, or with its own fills (panes and
        // pillars of one window band, which must not touch as separate holes).
        for (const fill of hole.fills ?? [hole]) {
          if (fill.part === null) continue;
          polygonFace(out, v3(sign * hw, 0, 0), Z, Y, fill.points, [], v3(sign, 0, 0), fill.part, fill.ao ?? 1);
        }
      }
    }
  }
}

// A window band for sweptBody sides: one hole from z0 to z1, filled with
// panes of `part` and pillars of `pillarPart` between them.
function bandHole(z0, z1, y0, y1, panes, pillar, part, pillarPart, { side = null } = {}) {
  const pane = (z1 - z0 - pillar * (panes - 1)) / panes;
  const fills = [];
  for (let i = 0; i < panes; i += 1) {
    const a = z0 + i * (pane + pillar);
    fills.push({ points: [[a, y0], [a + pane, y0], [a + pane, y1], [a, y1]], part });
    if (i < panes - 1) fills.push({ points: [[a + pane, y0], [a + pane + pillar, y0], [a + pane + pillar, y1], [a + pane, y1]], part: pillarPart });
  }
  return { points: [[z0, y0], [z1, y0], [z1, y1], [z0, y1]], part, side, fills };
}

// A rectangle hole for sweptBody sides: z0..z1, y0..y1 (optionally rounded corners).
function rectHole(z0, z1, y0, y1, part, { radius = 0, side = null, ao = 1 } = {}) {
  if (radius <= 0) return { points: [[z0, y0], [z1, y0], [z1, y1], [z0, y1]], part, side, ao };
  // (sweptBody draws the chamfered rectangle, rect, on the far level.)
  const points = [];
  const corners = [[z1 - radius, y0 + radius, -90], [z1 - radius, y1 - radius, 0], [z0 + radius, y1 - radius, 90], [z0 + radius, y0 + radius, 180]];
  for (const [cz, cy, start] of corners) {
    for (let k = 0; k <= 3; k += 1) {
      const a = ((start + k * 30) * Math.PI) / 180;
      points.push([cz + radius * Math.cos(a), cy + radius * Math.sin(a)]);
    }
  }
  const c = radius;
  return { points, part, side, ao, rect: [[z0 + c, y0], [z1 - c, y0], [z1, y0 + c], [z1, y1 - c], [z1 - c, y1], [z0 + c, y1], [z0, y1 - c], [z0, y0 + c]] };
}

// A profile point list with rounded corners: each entry [z, y, radius].
function roundedProfile(points, segments = 3) {
  const out = [];
  const n = points.length;
  for (let i = 0; i < n; i += 1) {
    const [z, y, r] = points[i];
    if (!r) {
      out.push([z, y]);
      continue;
    }
    const prev = points[(i - 1 + n) % n];
    const next = points[(i + 1) % n];
    const d0 = vnorm2([prev[0] - z, prev[1] - y]);
    const d1 = vnorm2([next[0] - z, next[1] - y]);
    const angle = Math.acos(clamp(d0[0] * d1[0] + d0[1] * d1[1], -1, 1));
    const t = r / Math.tan(angle / 2);
    const a = [z + d0[0] * t, y + d0[1] * t];
    const b = [z + d1[0] * t, y + d1[1] * t];
    // Quadratic Bezier through the corner (close enough to an arc for these radii).
    for (let k = 0; k <= segments; k += 1) {
      const u = k / segments;
      out.push([
        (1 - u) * (1 - u) * a[0] + 2 * (1 - u) * u * z + u * u * b[0],
        (1 - u) * (1 - u) * a[1] + 2 * (1 - u) * u * y + u * u * b[1],
      ]);
    }
  }
  return out;
}

function vnorm2(a) {
  const l = Math.hypot(a[0], a[1]) || 1;
  return [a[0] / l, a[1] / l];
}

// ---------------------------------------------------------------- wheels
// A road wheel on an axle at (x centre of the tyre, radius, z), its outer face
// toward `side` (+1 right, -1 left). dual: twin rear tyres (one wide tyre with
// a deep-dish rim face). inner: close the tyre's inner side (a wheel no body
// hides from below, such as a loader's).
function wheel(out, x, z, radius, width, side, lod, { dual = false, rimColour = P.rim, inner = false } = {}) {
  const center = v3(x, radius, z);
  const axis = v3(side, 0, 0);
  const tw = dual ? width * 2 + 0.03 : width;
  const rimR = radius * (dual ? 0.56 : 0.6);
  // The far wheel is a short hexagonal drum with a flat rim face.
  const profile = lod === 0
    ? [[radius - 0.02, -tw / 2], [radius, -tw / 2 + 0.05], [radius, tw / 2 - 0.05], [radius - 0.025, tw / 2 - 0.012], [radius - 0.07, tw / 2], [rimR, tw / 2], [rimR * 0.96, tw / 2 - (dual ? 0.09 : 0.03)]]
    : [[radius, -tw / 2], [radius, tw / 2], [rimR, tw / 2]];
  const rimSegment = profile.length - (lod === 0 ? 2 : 1);
  const sides = lod === 0 ? 16 : 6;
  out.lathe(center, axis, profile, sides, (i) => (i >= rimSegment ? rimColour : P.tire), Math.PI / sides, (i) => (i <= 1 ? 0.8 : 1));
  if (inner) out.lathe(center, axis, [[0, -tw / 2], [profile[0][0], -tw / 2]], sides, () => P.tire, Math.PI / sides, () => 0.6);
  // The rim face: a disc (dished on a dual) with a darker hub and nut ring.
  const depth = lod > 0 ? 0.005 : dual ? 0.09 : 0.03;
  const face = vadd(center, vscale(axis, tw / 2 - depth));
  const u = vnorm(vcross(axis, Y));
  const w = vcross(axis, u);
  const at = (r, angle, d = 0) => vadd(face, vadd(vscale(axis, d), vadd(vscale(u, r * Math.cos(angle)), vscale(w, r * Math.sin(angle)))));
  const segments = lod === 0 ? 16 : 6;
  const rings = lod === 0 ? [[0, P.hub, 0.012], [0.32, P.hub, 0.01], [0.4, rimColour, 0], [0.96, rimColour, 0]] : [[0, P.hub, 0], [0.96, rimColour, 0]];
  for (let s = 0; s < segments; s += 1) {
    const a0 = (2 * Math.PI * s) / segments;
    const a1 = (2 * Math.PI * (s + 1)) / segments;
    for (let k = 0; k < rings.length - 1; k += 1) {
      const [r0, part, d0] = rings[k];
      const [r1, , d1] = rings[k + 1];
      const holeRing = lod === 0 && k === 2 && s % 2 === 0 && !dual;
      out.face([at(rimR * r0, a0, d0), at(rimR * r0, a1, d0), at(rimR * r1, a1, d1), at(rimR * r1, a0, d1)], axis, holeRing ? P.hub : part);
    }
  }
}

// Both wheels of an axle: track between tyre centres, and a dark axle bar.
// well: the wheel arch's radius, to close the arch behind each tyre with a
// dark liner, so the arch never shows through the body.
function axle(out, z, track, radius, width, lod, options = {}) {
  for (const side of [1, -1]) wheel(out, side * track / 2, z, radius, width, side, lod, options);
  if (lod === 0) out.aabb([-track / 2 + 0.1, radius - 0.06, z - 0.06], [track / 2 - 0.1, radius + 0.06, z + 0.06], P.under, { ao: 0.4 });
  if (options.well) {
    const tyre = options.dual ? width * 2 + 0.03 : width;
    for (const side of [1, -1]) {
      const x = side * (track / 2 - tyre / 2 - 0.04);
      out.face([v3(x, 0.08, z - options.well), v3(x, 0.08, z + options.well), v3(x, radius + options.well, z + options.well), v3(x, radius + options.well, z - options.well)], v3(side, 0, 0), P.under, 0.3);
    }
  }
}

// ---------------------------------------------------------------- containers
const CONTAINER_W = 2.438;
const CONTAINER_HEIGHTS = Object.freeze({ standard: 2.591, high: 2.896 });

// One container: size 10ft/20ft/40ft, height standard/high, feature
// plain/rollup/office. Doors face +Z.
function buildContainer(size, height, feature, lod) {
  const out = new YardBuilder();
  const W = CONTAINER_W;
  const H = CONTAINER_HEIGHTS[height];
  const L = CONTAINER_LENGTHS[size];
  const hw = W / 2;
  const hl = L / 2;
  const post = 0.152; // corner post width from the outside
  const side = sideFeatures(feature, L, H, hw);
  if (lod === 1) {
    out.aabb([-hw, 0, -hl], [hw, H, hl], (face) => ({ "+y": P.container_roof, "+z": P.container_door, "-y": P.under }[face] ?? P.corrugated), {
      holes: { "+x": side.holes.map((hole) => ({ ...hole, part: hole.flushPart })) },
      ao: (face) => (face === "-y" ? 0.4 : 1),
    });
    return out.result();
  }
  // Frame: corner posts and castings.
  const casting = { z: 0.178, x: 0.162, y: 0.118 };
  for (const sx of [1, -1]) {
    for (const sz of [1, -1]) {
      const xs = [sx * (hw - post), sx * hw].sort((a, b) => a - b);
      const zs = [sz * (hl - 0.15), sz * hl].sort((a, b) => a - b);
      out.aabb([xs[0], casting.y, zs[0]], [xs[1], H - casting.y, zs[1]], P.container_frame);
      for (const [y0, y1] of [[0, casting.y], [H - casting.y, H]]) {
        const cx = [sx * (hw - casting.x), sx * (hw + 0.004)].sort((a, b) => a - b);
        const cz = [sz * (hl - casting.z), sz * (hl + 0.004)].sort((a, b) => a - b);
        // The casting's apertures: dark slots on its outer side, end and top or bottom face.
        const slot = (u, v) => ({ u0: u - 0.03, u1: u + 0.03, v0: v - 0.022, v1: v + 0.022, part: P.under });
        const zMid = sz * (hl - casting.z / 2);
        const xMid = sx * (hw - casting.x / 2);
        const yMid = (y0 + y1) / 2;
        out.aabb([cx[0], y0, cz[0]], [cx[1], y1, cz[1]], P.container_frame, {
          holes: {
            [sx > 0 ? "+x" : "-x"]: [slot(zMid, yMid)],
            [sz > 0 ? "+z" : "-z"]: [slot(xMid, yMid)],
            [y0 === 0 ? "-y" : "+y"]: [{ u0: xMid - 0.03, u1: xMid + 0.03, v0: zMid - 0.05, v1: zMid + 0.05, part: P.under }],
          },
        });
      }
    }
  }
  // Side rails (top and bottom) between the posts, with forklift pockets on 20 ft boxes.
  const railZ = [-(hl - 0.15), hl - 0.15];
  for (const sx of [1, -1]) {
    const xsTop = [sx * (hw - 0.07), sx * hw].sort((a, b) => a - b);
    out.aabb([xsTop[0], H - 0.105, railZ[0]], [xsTop[1], H, railZ[1]], P.container_frame);
    const xsBottom = [sx * (hw - 0.08), sx * hw].sort((a, b) => a - b);
    const pockets = size === "20ft" ? [-1.025, 1.025].map((z) => ({ u0: z - 0.178, u1: z + 0.178, v0: 0.02, v1: 0.135, part: P.under })) : [];
    out.aabb([xsBottom[0], 0, railZ[0]], [xsBottom[1], 0.155, railZ[1]], P.container_frame, { holes: { [sx > 0 ? "+x" : "-x"]: pockets }, ao: (face) => (face === "-y" ? 0.4 : 1) });
  }
  // Front end rails and the door end's header and sill.
  out.aabb([-(hw - post), H - 0.11, -hl], [hw - post, H, -(hl - 0.07)], P.container_frame);
  out.aabb([-(hw - post), 0, -hl], [hw - post, 0.13, -(hl - 0.07)], P.container_frame);
  out.aabb([-(hw - post), H - 0.21, hl - 0.08], [hw - post, H, hl], P.container_frame);
  out.aabb([-(hw - post), 0, hl - 0.08], [hw - post, 0.1, hl], P.container_frame);
  // Walls, recessed between the frame members: the corrugation is the shader's.
  for (const sx of [1, -1]) {
    const holes = sx > 0 ? side.holes : [];
    out.panel(v3(sx * (hw - 0.025), 0, 0), Z, Y, railZ[0], railZ[1], 0.155, H - 0.105, v3(sx, 0, 0), P.corrugated, { holes: holes.map((hole) => ({ ...hole, part: null })) });
  }
  out.panel(v3(0, 0, -(hl - 0.025)), X, Y, -(hw - post), hw - post, 0.13, H - 0.11, NZ, P.corrugated);
  out.panel(v3(0, H - 0.015, 0), X, Z, -(hw - 0.07), hw - 0.07, railZ[0], railZ[1], Y, P.container_roof);
  out.panel(v3(0, 0.0, 0), X, Z, -hw, hw, -hl, hl, NY, P.under, { ao: 0.35 });
  // The +X side's openings: recessed doors and windows with their reveals.
  for (const hole of side.holes) side.build(out, hole);
  // Doors: two leaves with a centre seam and gaskets, four lock bars with cams,
  // guides and handles, hinges on the outer edges.
  const doorZ = hl - 0.02;
  const leafX = hw - post;
  const doorTop = H - 0.21;
  out.panel(v3(0, 0, doorZ), X, Y, -leafX, leafX, 0.1, doorTop, Z, P.container_door, {
    holes: [
      { u0: -0.012, u1: 0.012, v0: 0.1, v1: doorTop, part: P.seal },
      { u0: -leafX, u1: -leafX + 0.025, v0: 0.1, v1: doorTop, part: P.seal },
      { u0: leafX - 0.025, u1: leafX, v0: 0.1, v1: doorTop, part: P.seal },
    ],
  });
  const front = doorZ + 0.03;
  for (const bx of [-0.62, -0.18, 0.18, 0.62]) {
    out.aabb([bx - 0.017, 0.16, front - 0.017], [bx + 0.017, doorTop - 0.06, front + 0.017], P.lock_bar);
    for (const cy of [0.13, doorTop - 0.04]) out.aabb([bx - 0.035, cy - 0.03, front - 0.03], [bx + 0.035, cy + 0.03, front + 0.03], P.lock_bar);
    for (const gy of [0.85, 1.75 * (H / 2.591)]) out.aabb([bx - 0.04, gy - 0.02, doorZ], [bx + 0.04, gy + 0.02, front + 0.02], P.lock_bar);
    const out1 = bx + Math.sign(bx) * 0.24;
    const hx = [bx, out1].sort((a, b) => a - b);
    out.aabb([hx[0], 1.06, front + 0.012], [hx[1], 1.1, front + 0.045], P.lock_bar);
  }
  for (const sx of [1, -1]) {
    for (const hy of [0.32, 0.98, 1.62, H - 0.42]) {
      const hx = [sx * (leafX - 0.08), sx * (leafX + 0.01)].sort((a, b) => a - b);
      out.aabb([hx[0], hy - 0.05, doorZ], [hx[1], hy + 0.05, doorZ + 0.04], P.lock_bar);
    }
  }
  return out.result();
}

// The +X side openings of a container feature: holes in the wall (flushPart
// for the far mesh) and how the near mesh builds each one.
function sideFeatures(feature, L, H, hw) {
  const wallX = hw - 0.025;
  if (feature === "rollup") {
    const hole = { u0: L / 2 - 2.2, u1: L / 2 - 0.4, v0: 0.155, v1: 2.15, flushPart: P.rollup };
    return {
      holes: [hole],
      build(out, h) {
        recessed(out, wallX, h, 0.045, P.rollup, P.container_frame);
        // A bottom bar and a pull handle on the door.
        out.aabb([wallX - 0.045, h.v0, h.u0], [wallX - 0.03, h.v0 + 0.06, h.u1], P.lock_bar);
        out.aabb([wallX - 0.035, h.v0 + 0.12, (h.u0 + h.u1) / 2 - 0.08], [wallX - 0.02, h.v0 + 0.15, (h.u0 + h.u1) / 2 + 0.08], P.lock_bar);
      },
    };
  }
  if (feature === "office") {
    // As photographed at 801 Avenue H: three white-framed windows and a personnel door.
    const windows = [-4.4, 1.3, 4.7].map((z) => ({ u0: z - 0.5, u1: z + 0.5, v0: 1.05, v1: 1.9, flushPart: P.glass, kind: "window" }));
    const door = { u0: -2.55, u1: -1.6, v0: 0.18, v1: 2.2, flushPart: P.container_frame, kind: "door" };
    return {
      holes: [...windows, door],
      build(out, h) {
        if (h.kind === "door") {
          recessed(out, wallX, h, 0.04, P.container_frame, P.container_frame);
          out.aabb([wallX - 0.03, 1.0, h.u0 + 0.08], [wallX - 0.0, 1.04, h.u0 + 0.2], P.lock_bar);
          return;
        }
        // A sliding window: white frame, two panes and a mullion.
        recessed(out, wallX, h, 0.06, P.glass, P.white);
        const x = wallX + 0.004;
        const frame = 0.05;
        for (const [z0, z1, y0, y1] of [[h.u0, h.u1, h.v0, h.v0 + frame], [h.u0, h.u1, h.v1 - frame, h.v1], [h.u0, h.u0 + frame, h.v0, h.v1], [h.u1 - frame, h.u1, h.v0, h.v1], [(h.u0 + h.u1) / 2 - 0.025, (h.u0 + h.u1) / 2 + 0.025, h.v0, h.v1]]) {
          out.aabb([x - 0.06, y0, z0], [x, y1, z1], P.white);
        }
      },
    };
  }
  return { holes: [], build() {} };
}

// A recessed opening in a wall facing +X at wallX: reveals of `revealPart`
// and the inner panel of `part` `depth` behind the wall.
function recessed(out, wallX, h, depth, part, revealPart) {
  const inner = wallX - depth;
  out.panel(v3(inner, 0, 0), Z, Y, h.u0, h.u1, h.v0, h.v1, X, part);
  out.face([v3(wallX, h.v0, h.u0), v3(inner, h.v0, h.u0), v3(inner, h.v1, h.u0), v3(wallX, h.v1, h.u0)], Z, revealPart, 0.7);
  out.face([v3(wallX, h.v0, h.u1), v3(inner, h.v0, h.u1), v3(inner, h.v1, h.u1), v3(wallX, h.v1, h.u1)], NZ, revealPart, 0.7);
  out.face([v3(wallX, h.v1, h.u0), v3(inner, h.v1, h.u0), v3(inner, h.v1, h.u1), v3(wallX, h.v1, h.u1)], NY, revealPart, 0.6);
  out.face([v3(wallX, h.v0, h.u0), v3(inner, h.v0, h.u0), v3(inner, h.v0, h.u1), v3(wallX, h.v0, h.u1)], Y, revealPart, 0.8);
}


// ---------------------------------------------------------------- shed rows
// Self-storage shed rows: modules the runtime repeats along Z. A bay is one
// 10 ft unit on each door side (8 x 7 ft roll-up door, posts and header), with
// its share of the roof; the ends close the row with a gable wall and the roof
// overhang. Sizes: 10 ft units, low-slope metal roofs (production inference;
// no ground photo of the TI unit doors).
const SHED_BAY = 3.05;
const SHED_END = 0.15;
const SHED_OVERHANG = 0.2;
const SHED_CURB = 0.12;
const SHED_ROOF_T = 0.1;
export const SHED_SPECS = Object.freeze({
  double: { hw: 3.66, eave: 2.62, ridge: 3.1, doors: [1, -1], mono: false },
  single: { hw: 2.285, eave: 2.44, front: 2.86, doors: [1], mono: true },
  wide: { hw: 6.095, eave: 2.9, ridge: 3.8, doors: [1, -1], mono: false },
});

// The roof's top surface height at x (continuing its slope over the overhang).
function shedRoofY(spec, x) {
  if (spec.mono) return spec.eave + ((spec.front - spec.eave) * (x + spec.hw)) / (2 * spec.hw);
  return spec.ridge - ((spec.ridge - spec.eave) * Math.abs(x)) / spec.hw;
}

// The roof's slopes as [x0, x1] spans out to the overhang edges.
function shedSlopes(spec) {
  const edge = spec.hw + SHED_OVERHANG;
  return spec.mono ? [[-edge, edge]] : [[0, edge], [-edge, 0]];
}

function shedRoof(out, spec, z0, z1, lod) {
  for (const [xa, xb] of shedSlopes(spec)) {
    const a = v3(xa, shedRoofY(spec, xa), z0);
    const b = v3(xb, shedRoofY(spec, xb), z0);
    const up = vnorm(vcross(vsub(v3(xb, shedRoofY(spec, xb), z1), b), vsub(a, b)));
    const normal = up[1] < 0 ? vscale(up, -1) : up;
    out.face([a, b, v3(xb, shedRoofY(spec, xb), z1), v3(xa, shedRoofY(spec, xa), z1)], normal, P.shed_roof);
    if (lod > 0) continue;
    // Fascia along the overhang edge and the soffit under the overhang.
    const edgeX = Math.abs(xa) > Math.abs(xb) ? xa : xb;
    const wallX = Math.sign(edgeX) * spec.hw;
    const yEdge = shedRoofY(spec, edgeX);
    const yWall = shedRoofY(spec, wallX);
    out.face([v3(edgeX, yEdge - 0.16, z0), v3(edgeX, yEdge - 0.16, z1), v3(edgeX, yEdge + 0.01, z1), v3(edgeX, yEdge + 0.01, z0)], v3(Math.sign(edgeX), 0, 0), P.shed_wall);
    out.face([v3(wallX, yWall - SHED_ROOF_T, z0), v3(edgeX, yEdge - 0.16, z0), v3(edgeX, yEdge - 0.16, z1), v3(wallX, yWall - SHED_ROOF_T, z1)], NY, P.shed_roof, 0.55);
  }
  if (!spec.mono && lod === 0) {
    // A ridge cap.
    out.aabb([-0.14, spec.ridge - 0.01, z0], [0.14, spec.ridge + 0.035, z1], (face) => (face === "-y" ? null : P.shed_roof));
  }
}

function buildShedBay(variant, lod) {
  const spec = SHED_SPECS[variant];
  const out = new YardBuilder();
  const hz = SHED_BAY / 2;
  const door = { u0: -1.22, u1: 1.22, v0: SHED_CURB, v1: SHED_CURB + 2.13 };
  for (const s of [1, -1]) {
    const wallX = s * spec.hw;
    const top = shedRoofY(spec, wallX) - SHED_ROOF_T;
    const hasDoor = spec.doors.includes(s);
    const base = lod === 0 ? SHED_CURB : 0;
    if (lod === 0) out.aabb([s > 0 ? wallX - 0.02 : wallX - 0.06, 0, -hz], [s > 0 ? wallX + 0.06 : wallX + 0.02, SHED_CURB, hz], (face) => (face === "-y" ? null : P.concrete));
    if (!hasDoor) {
      out.panel(v3(wallX, 0, 0), Z, Y, -hz, hz, base, top, v3(s, 0, 0), P.shed_wall);
      continue;
    }
    if (lod === 1) {
      out.panel(v3(wallX, 0, 0), Z, Y, -hz, hz, 0, top, v3(s, 0, 0), P.shed_wall, { holes: [{ ...door, part: P.rollup }] });
      continue;
    }
    out.panel(v3(wallX, 0, 0), Z, Y, -hz, hz, base, top, v3(s, 0, 0), P.shed_wall, { holes: [{ ...door, part: null }] });
    // The door, recessed, with its jambs, head and a bottom bar with a latch.
    const inner = wallX - s * 0.06;
    out.panel(v3(inner, 0, 0), Z, Y, door.u0, door.u1, door.v0, door.v1, v3(s, 0, 0), P.rollup);
    for (const [z, n] of [[door.u0, Z], [door.u1, NZ]]) {
      out.face([v3(wallX, door.v0, z), v3(inner, door.v0, z), v3(inner, door.v1, z), v3(wallX, door.v1, z)], n, P.shed_wall, 0.7);
    }
    out.face([v3(wallX, door.v1, door.u0), v3(inner, door.v1, door.u0), v3(inner, door.v1, door.u1), v3(wallX, door.v1, door.u1)], NY, P.shed_wall, 0.55);
    const xs = [inner, inner + s * 0.035].sort((a, b) => a - b);
    out.aabb([xs[0], door.v0, door.u0 + 0.02], [xs[1], door.v0 + 0.07, door.u1 - 0.02], P.lock_bar);
    out.aabb([Math.min(inner, inner + s * 0.05), door.v0 + 0.06, -0.06], [Math.max(inner, inner + s * 0.05), door.v0 + 0.14, 0.06], P.lock_bar);
    // A trim band over the door.
    const hx = [wallX, wallX + s * 0.025].sort((a, b) => a - b);
    out.aabb([hx[0], door.v1, door.u0 - 0.06], [hx[1], door.v1 + 0.08, door.u1 + 0.06], P.rollup);
  }
  shedRoof(out, spec, -hz, hz, lod);
  return out.result();
}

// A row end: the gable wall (at the joint, z = 0) and the roof overhang
// beyond it, outward toward `dir` (-1: the -Z end, +1: the +Z end).
function buildShedEnd(variant, dir, lod) {
  const spec = SHED_SPECS[variant];
  const out = new YardBuilder();
  const wall = spec.mono
    ? [[-spec.hw, 0], [spec.hw, 0], [spec.hw, shedRoofY(spec, spec.hw) - SHED_ROOF_T], [-spec.hw, shedRoofY(spec, -spec.hw) - SHED_ROOF_T]]
    : [[-spec.hw, 0], [spec.hw, 0], [spec.hw, shedRoofY(spec, spec.hw) - SHED_ROOF_T], [0, spec.ridge - SHED_ROOF_T], [-spec.hw, shedRoofY(spec, -spec.hw) - SHED_ROOF_T]];
  polygonFace(out, v3(0, 0, 0), X, Y, wall, [], v3(0, 0, dir), P.shed_wall);
  const zs = [0, dir * SHED_END].sort((a, b) => a - b);
  shedRoof(out, spec, zs[0], zs[1], lod);
  if (lod === 0) {
    // The curb along the end and the barge boards along the gable edges.
    out.aabb([-spec.hw - 0.06, 0, Math.min(0, dir * 0.06)], [spec.hw + 0.06, SHED_CURB, Math.max(0, dir * 0.06)], (face) => (face === "-y" ? null : P.concrete));
    const edgeZ = dir * SHED_END;
    for (const [xa, xb] of shedSlopes(spec)) {
      out.face([v3(xa, shedRoofY(spec, xa) - 0.16, edgeZ), v3(xb, shedRoofY(spec, xb) - 0.16, edgeZ), v3(xb, shedRoofY(spec, xb) + 0.01, edgeZ), v3(xa, shedRoofY(spec, xa) + 0.01, edgeZ)], v3(0, 0, dir), P.shed_wall);
    }
    // Corner trims.
    for (const s of [1, -1]) {
      const x = s * spec.hw;
      const xs = [x - 0.04, x + 0.04].sort((a, b) => a - b);
      const zz = [0, dir * 0.04].sort((a, b) => a - b);
      out.aabb([xs[0], SHED_CURB, zz[0]], [xs[1], shedRoofY(spec, x) - SHED_ROOF_T, zz[1]], (face) => (face === "-y" || face === "+y" ? null : P.shed_wall));
    }
  }
  return out.result();
}

// ---------------------------------------------------------------- fabric sheds
// White fabric storage buildings (City View Commissary, May 2026 aerial: white
// roofs with a ridge and bay lines): a membrane over portal frames every 5 m,
// sagging a little between them. Spans and heights are production inference.
const FABRIC_BAY = 5.0;
const FABRIC_END = 0.2;
export const FABRIC_SPECS = Object.freeze({
  span10: { hw: 5, eave: 3.5, ridge: 5.2 },
  span15: { hw: 7.5, eave: 4.0, ridge: 6.4 },
  span20: { hw: 10, eave: 4.5, ridge: 7.6 },
  span30: { hw: 15, eave: 5.0, ridge: 9.6 },
});

// The membrane's cross-section, from the left foot over the ridge to the right
// foot: [x, y] points with their outward normal.
function fabricSection(spec) {
  return [
    [-spec.hw, 0.16],
    [-spec.hw, spec.eave],
    [0, spec.ridge],
    [spec.hw, spec.eave],
    [spec.hw, 0.16],
  ];
}

function buildFabricBay(span, lod, length = FABRIC_BAY, sag = true, rails = true) {
  const spec = FABRIC_SPECS[span];
  const out = new YardBuilder();
  // The far mesh has no base rail: its membrane reaches the ground.
  const section = fabricSection(spec).map(([x, y]) => [x, lod > 0 && y < 1 ? 0 : y]);
  const strips = lod === 0 && sag ? 8 : 1;
  const amp = (j) => (j === 1 || j === 2 ? 0.13 : 0.07);
  for (let j = 0; j < section.length - 1; j += 1) {
    const [x0, y0] = section[j];
    const [x1, y1] = section[j + 1];
    const t = vnorm2([x1 - x0, y1 - y0]);
    // Outward normal of the segment in the x-y plane (the section runs left to right over the top).
    const n0 = [t[1], -t[0]];
    const n = n0[0] * (x0 + x1) + n0[1] * ((y0 + y1) / 2 - spec.eave / 2) < 0 ? [-n0[0], -n0[1]] : n0;
    for (let k = 0; k < strips; k += 1) {
      const za = -length / 2 + (length * k) / strips;
      const zb = -length / 2 + (length * (k + 1)) / strips;
      const sagAt = (z) => (strips > 1 ? amp(j) * Math.sin((Math.PI * (z + length / 2)) / length) : 0);
      const slopeAt = (z) => (strips > 1 ? ((amp(j) * Math.PI) / length) * Math.cos((Math.PI * (z + length / 2)) / length) : 0);
      const p = (x, y, z) => v3(x - n[0] * sagAt(z), y - n[1] * sagAt(z), z);
      const nn = (z) => vnorm(v3(n[0], n[1], slopeAt(z)));
      const a = p(x0, y0, za);
      const b = p(x1, y1, za);
      const c = p(x1, y1, zb);
      const d = p(x0, y0, zb);
      const normals = [nn(za), nn(za), nn(zb), nn(zb)];
      const cross = vcross(vsub(b, a), vsub(c, a));
      if (vdot(cross, normals[0]) >= 0) out.quad(a, b, c, d, normals, P.fabric);
      else out.quad(a, d, c, b, [normals[0], normals[3], normals[2], normals[1]], P.fabric);
    }
  }
  if (lod === 0 && rails) {
    // Steel base rails along both sides.
    for (const s of [1, -1]) {
      const xs = [s * (spec.hw - 0.03), s * (spec.hw + 0.05)].sort((a, b) => a - b);
      out.aabb([xs[0], 0, -length / 2], [xs[1], 0.16, length / 2], (face) => (face === "-y" ? null : P.metal));
    }
  }
  return out.result();
}

// A fabric shed's end: the end arch (a short membrane band) and the end wall
// recessed 0.1 m behind it, outward toward dir.
function buildFabricEnd(span, dir, lod) {
  const spec = FABRIC_SPECS[span];
  const band = buildFabricBay(span, lod, FABRIC_END, false, false);
  const out = new YardBuilder();
  // Re-centre the band on [0, dir * FABRIC_END].
  const offset = (dir * FABRIC_END) / 2;
  for (let i = 0; i < band.indices.length; i += 3) {
    const corner = (k) => {
      const index = band.indices[i + k];
      return {
        p: v3(band.positions[index * 3], band.positions[index * 3 + 1], band.positions[index * 3 + 2] + offset),
        n: v3(band.normals[index * 3], band.normals[index * 3 + 1], band.normals[index * 3 + 2]),
        part: Math.floor(band.uvs[index * 2] * YARD_KIT_PART_SLOTS),
        ao: band.uvs[index * 2 + 1],
      };
    };
    const [a, b, c] = [corner(0), corner(1), corner(2)];
    out.triangle(a.p, b.p, c.p, [a.n, b.n, c.n], a.part, [a.ao, b.ao, c.ao]);
  }
  const wallZ = dir * 0.1;
  const wall = [[-spec.hw, 0], [spec.hw, 0], [spec.hw, spec.eave], [0, spec.ridge], [-spec.hw, spec.eave]];
  polygonFace(out, v3(0, 0, wallZ), X, Y, wall, [], v3(0, 0, dir), P.fabric, 0.92);
  if (lod === 0) out.aabb([-spec.hw - 0.05, 0, Math.min(0, dir * FABRIC_END)], [spec.hw + 0.05, 0.16, Math.max(0, dir * FABRIC_END)], (face) => (face === "-y" ? null : P.metal));
  return out.result();
}

// ---------------------------------------------------------------- berms
// Earth berms under black plastic sheeting (hangar earthworks pad, May 2026
// aerial and Jun 2021 Avenue H view): a long, low trapezoid with rounded
// shoulders, extruded in 6 m modules with rounded ends; the sheets overlap
// down the slope at every module joint.
// cap_m: the rounded end's length (half a module on the low berm, a whole one
// on the high berm, whose 3.2 m would otherwise end steeper than 45 degrees).
export const BERM_SPECS = Object.freeze({
  low: { sx: 1, sy: 1, cap_m: 3 },
  high: { sx: 15 / 9, sy: 3.2 / 1.8, cap_m: 6 },
});
const BERM_PROFILE = Object.freeze([[-4.5, 0], [-3.9, 0.2], [-3.1, 0.7], [-2.4, 1.22], [-1.9, 1.55], [-1.3, 1.72], [-0.65, 1.79], [0, 1.8], [0.65, 1.79], [1.3, 1.72], [1.9, 1.55], [2.4, 1.22], [3.1, 0.7], [3.9, 0.2], [4.5, 0]]);
const BERM_MODULE = 6;

// The berm surface as a grid: rows of profile points along z stations.
function bermGrid(variant, stations, scaleAt, wrinkle) {
  const spec = BERM_SPECS[variant];
  return stations.map((z) => {
    const s = scaleAt(z);
    return BERM_PROFILE.map(([x, y], i) => {
      const w = wrinkle(i, z) * (i === 0 || i === BERM_PROFILE.length - 1 ? 0 : 1);
      return v3(x * spec.sx * s.x, Math.max(0, y * spec.sy * s.y + w), z);
    });
  });
}

function gridSurface(out, grid, part) {
  // Quads between stations k, k+1 and profile points i, i+1, smooth normals.
  const K = grid.length;
  const N = grid[0].length;
  const normals = grid.map((row, k) => row.map((point, i) => {
    const prev = grid[Math.max(0, k - 1)][i];
    const next = grid[Math.min(K - 1, k + 1)][i];
    const left = row[Math.max(0, i - 1)];
    const right = row[Math.min(N - 1, i + 1)];
    let n = vcross(vsub(right, left), vsub(next, prev));
    if (vlen(n) < 1e-9) n = Y;
    n = vnorm(n);
    return n[1] < 0 ? vscale(n, -1) : n;
  }));
  for (let k = 0; k < K - 1; k += 1) {
    for (let i = 0; i < N - 1; i += 1) {
      const a = grid[k][i];
      const b = grid[k][i + 1];
      const c = grid[k + 1][i + 1];
      const d = grid[k + 1][i];
      const ns = [normals[k][i], normals[k][i + 1], normals[k + 1][i + 1], normals[k + 1][i]];
      const avg = vnorm(vadd(vadd(ns[0], ns[1]), vadd(ns[2], ns[3])));
      const cross = vcross(vsub(b, a), vsub(c, a));
      if (vlen(cross) < 1e-10) {
        // A collapsed end row: one triangle.
        const cross2 = vcross(vsub(c, a), vsub(d, a));
        if (vlen(cross2) < 1e-10) continue;
        if (vdot(cross2, avg) >= 0) out.triangle(a, c, d, [ns[0], ns[2], ns[3]], part);
        else out.triangle(a, d, c, [ns[0], ns[3], ns[2]], part);
        continue;
      }
      if (vdot(cross, avg) >= 0) out.quad(a, b, c, d, ns, part);
      else out.quad(a, d, c, b, [ns[0], ns[3], ns[2], ns[1]], part);
    }
  }
}

function bermWrinkle(lod) {
  if (lod > 0) return () => 0;
  return (i, z) => {
    const phase = hash(i, 7) * Math.PI * 2;
    const t = (2 * Math.PI * z) / BERM_MODULE;
    // Periodic over a module, so modules meet; a sheet overlap at the joints.
    const seam = Math.exp(-(((Math.abs(z) - BERM_MODULE / 2) / 0.12) ** 2)) * 0.04;
    return 0.035 * Math.sin(t * 2 + phase) + 0.02 * Math.sin(t * 3 + phase * 1.7) + seam;
  };
}

function buildBermMid(variant, lod) {
  const out = new YardBuilder();
  const steps = lod === 0 ? 12 : 1;
  const stations = Array.from({ length: steps + 1 }, (_, k) => -BERM_MODULE / 2 + (BERM_MODULE * k) / steps);
  gridSurface(out, bermGrid(variant, stations, () => ({ x: 1, y: 1 }), bermWrinkle(lod)), P.plastic);
  return out.result();
}

function buildBermEnd(variant, dir, lod) {
  const out = new YardBuilder();
  const fractions = lod === 0 ? [0, 0.3, 0.52, 0.7, 0.83, 0.92, 0.97, 1] : [0, 0.55, 0.85, 1];
  const cap = BERM_SPECS[variant].cap_m;
  const stations = fractions.map((f) => dir * f * cap);
  // Round in plan; its height falls as a cosine, so its slope stays finite
  // at the tip (under 45 degrees).
  const grid = bermGrid(variant, stations, (z) => {
    const t = Math.min(1, Math.abs(z) / cap);
    return { x: Math.max(Math.sqrt(Math.max(0, 1 - t * t)), 0.001), y: Math.cos((Math.PI / 2) * t) };
  }, (i, z) => {
    if (lod > 0) return 0;
    // The ring the cap shares with a middle module (or the other cap) takes the
    // middle's wrinkle at its end, fading toward the tip, so they meet without
    // a gap; the cap's own wrinkle grows toward the tip.
    const t = Math.abs(z) / cap;
    const shared = bermWrinkle(lod)(i, BERM_MODULE / 2) * Math.max(0, 1 - t / 0.52);
    return shared + (t < 0.95 ? 0.025 * Math.sin(5 * z + hash(i, 3) * 6) * t : 0);
  });
  gridSurface(out, grid, P.plastic);
  return out.result();
}

// ---------------------------------------------------------------- piles
// Plan sizes as the registry's (x by z at scale 1) and heights. Rubble is
// broken concrete over its own fines (3rd St, Mar 2025); a tarp pile is black
// sheeting folded over a mound, its hem loose on the ground and held by
// tyres (Avenue N, Nov 2025).
export const PILE_SPECS = Object.freeze({
  gravel: { x: 8, z: 8, h: 3, part: "gravel", rough: 0.05 },
  rubble: { x: 12, z: 12, h: 4.5, part: "rubble", rough: 0.16, lumps: 0.18, chunks: [260, 60], fit: 0.92 },
  soil: { x: 12, z: 12, h: 4, part: "earth", rough: 0.1 },
  tarp: { x: 6, z: 8, h: 2.2, part: "tarp", rough: 0.04, flat: true, folds: 0.24, fit: 0.86 },
});

// A broken concrete chunk: a box with its corners pushed about, faceted, its
// buried bottom left out.
function chunk(out, center, axes, half, seed, part, ao) {
  const [ax, ay, az] = axes;
  const corners = [];
  for (let i = 0; i < 8; i += 1) {
    const jitter = (k) => 1 + 0.9 * (hash(seed, i, k) - 0.5);
    corners.push(vadd(center, vadd(vscale(ax, (i & 1 ? 1 : -1) * half[0] * jitter(0)), vadd(vscale(ay, (i & 2 ? 1 : -1) * half[1] * jitter(1)), vscale(az, (i & 4 ? 1 : -1) * half[2] * jitter(2))))));
  }
  for (const [a, b, c, d] of [[0, 2, 6, 4], [1, 5, 7, 3], [2, 3, 7, 6], [0, 1, 3, 2], [4, 6, 7, 5]]) {
    for (const [i, j, k] of [[a, b, c], [a, c, d]]) {
      const [p, q, r] = [corners[i], corners[j], corners[k]];
      const mid = vscale(vadd(vadd(p, q), r), 1 / 3);
      if (vdot(vcross(vsub(q, p), vsub(r, p)), vsub(mid, center)) >= 0) out.triangle(p, q, r, null, part, [ao, ao, ao]);
      else out.triangle(p, r, q, null, part, [ao, ao, ao]);
    }
  }
}

// Smooth value noise round a circle: angle a over `cells` cells (periodic, so
// a ring closes without a step) by a second, open coordinate v.
function ringNoise(a, v, cells, seed) {
  const x = (((a / (2 * Math.PI)) % 1) + 1) % 1 * cells;
  const i = Math.floor(x);
  const j = Math.floor(v);
  const fx = x - i;
  const fy = v - j;
  const at = (ii, jj) => hash(((ii % cells) + cells) % cells, jj, seed);
  const tx = fx * fx * (3 - 2 * fx);
  const ty = fy * fy * (3 - 2 * fy);
  return lerp(lerp(at(i, j), at(i + 1, j), tx), lerp(at(i, j + 1), at(i + 1, j + 1), tx), ty);
}

// A stockpile's profile, 1 at its middle and 0 at its foot: nearly a cone
// (its sides about the angle of repose) with a crown rounded over STOCKPILE_CROWN
// of its radius, so it has no point for a foot to catch on.
const STOCKPILE_CROWN = 0.15;
const STOCKPILE_POWER = 1.15;
function stockpile(rho) {
  const f = (r) => -((r * r + STOCKPILE_CROWN * STOCKPILE_CROWN) ** (STOCKPILE_POWER / 2));
  return (f(rho) - f(1)) / (f(0) - f(1));
}

// Smooth 2D value noise (plan coordinates; no period).
function noise2(x, z, seed) {
  const i = Math.floor(x);
  const j = Math.floor(z);
  const fx = x - i;
  const fz = z - j;
  const tx = fx * fx * (3 - 2 * fx);
  const tz = fz * fz * (3 - 2 * fz);
  return lerp(lerp(hash(i, j, seed), hash(i + 1, j, seed), tx), lerp(hash(i, j + 1, seed), hash(i + 1, j + 1, seed), tx), tz);
}

// A pile: a radial mound with an irregular outline (shape seeds 0..2), fitted
// to its plan rectangle and height.
function buildPile(material, shape, lod) {
  const spec = PILE_SPECS[material];
  const out = new YardBuilder(lod);
  const segments = lod === 0 ? (spec.folds ? 60 : spec.chunks ? 40 : 28) : 12;
  const rings = lod === 0 ? (spec.chunks ? 12 : 9) : 4;
  const seed = 31 * (shape + 1) + material.length;
  // Folds: ridges of a sheet draped over the mound, running down to the hem.
  const fold = (a) => (spec.folds ? 0.6 * (1 - Math.abs(Math.sin(3.5 * a + seed))) ** 3 + 0.4 * (1 - Math.abs(Math.sin(5.5 * a + 2.1 * seed))) ** 4 : 0);
  const outline = (a) => {
    return 1 + 0.14 * (ringNoise(a, 0, 6, seed) - 0.5) * 2 + 0.06 * (ringNoise(a, 0.5, 14, seed + 9) - 0.5) * 2 + 0.05 * fold(a);
  };
  const elongation = material === "tarp" ? 1.3 : 1 + 0.15 * hash(seed, 2);
  const nominal = Math.max(spec.x, spec.z / elongation) / 2;
  // A tarp drapes over two or three mounds of what it covers, sagging
  // between them (plan positions in units of the nominal radius).
  const mounds = [0, 1, 2].map((k) => ({
    x: (hash(seed, k, 11) - 0.5) * 0.9,
    z: (hash(seed, k, 12) - 0.5) * 0.9,
    r: 0.7 + 0.3 * hash(seed, k, 13),
    h: k === 0 ? 1 : 0.55 + 0.35 * hash(seed, k, 14),
  }));
  const draped = (rho, a) => {
    const x = rho * Math.cos(a);
    const z = rho * Math.sin(a);
    let top = 0;
    for (const mound of mounds) {
      const d = Math.hypot(x - mound.x, z - mound.z) / mound.r;
      top = Math.max(top, mound.h * Math.max(0, 1 - d ** 1.15));
    }
    return top * Math.pow(Math.max(0, 1 - rho ** 6), 0.5);
  };
  const heightAt = (rho, a) => {
    // A tarp drapes over its mounds; a stockpile is a cone with a rounded
    // crown (no point for a foot to catch on), its sides about the angle of
    // repose (under 45 degrees, so its hull is walkable).
    const base = spec.flat ? draped(rho, a) : Math.max(0, stockpile(rho));
    // Bumps (and a rubble pile's lumps of a metre or so) in plan coordinates.
    const r = nominal * outline(a) * rho;
    const px = r * Math.cos(a);
    const pz = r * Math.sin(a) * elongation;
    let bump = lod === 0 ? spec.rough * ((noise2(px / 2.6, pz / 2.6, seed + 3) - 0.5) * 2 + 0.5 * (noise2(px / 1.2, pz / 1.2, seed + 5) - 0.5)) : 0;
    if (spec.lumps && lod === 0) bump += spec.lumps * (noise2(px / 0.75, pz / 0.75, seed + 7) - 0.5);
    const folds = spec.folds ? spec.folds * fold(a) * Math.sin(Math.PI * Math.min(1, rho)) ** 0.8 : 0;
    return Math.max(0, spec.h * base * (1 + bump * Math.min(1, rho * 6)) + folds);
  };
  // The tallest point of the mound, to fit its height to the plan's (a rubble
  // pile's surface stays a little lower: its chunks stand proud of it).
  let peak = 0;
  for (let i = 0; i <= 40; i += 1) for (let k = 0; k < 120; k += 1) peak = Math.max(peak, heightAt(i / 40, (2 * Math.PI * k) / 120));
  const sy = (spec.chunks ? spec.h - 0.25 : spec.h) / peak;
  // A tarp's hem lies loose on the ground beyond the mound, wider in places.
  const hemWidth = (a) => 0.07 + 0.08 * ringNoise(a, 0.3, 14, seed + 13) + 0.04 * fold(a);
  const raw = (rho, a, hem = 0) => {
    const r = nominal * outline(a) * (rho + hem * hemWidth(a));
    const y = hem > 0 ? (hem < 1 ? 0.035 : 0.008) : rho >= 1 ? (spec.folds ? 0.035 : 0) : heightAt(rho, a) * sy;
    return v3(r * Math.cos(a), y, r * Math.sin(a) * elongation);
  };
  // Fit the outermost ring to the plan (sampled finer than any level's mesh).
  const outermost = spec.folds ? (a) => raw(1, a, 1) : (a) => raw(1, a);
  let maxX = 0;
  let maxZ = 0;
  for (let i = 0; i < 720; i += 1) {
    const p = outermost((2 * Math.PI * i) / 720);
    maxX = Math.max(maxX, Math.abs(p[0]));
    maxZ = Math.max(maxZ, Math.abs(p[2]));
  }
  // (A heap whose foot is steep fits a little inside its plan, so the foot of
  // its collision hull, which reaches past it, still keeps to the plan.)
  const fit = spec.fit ?? 0.98;
  const sx = (spec.x / 2) * fit / maxX;
  const sz = (spec.z / 2) * fit / maxZ;
  const surface = (rho, a, hem = 0) => {
    const p = raw(rho, a, hem);
    return v3(p[0] * sx, p[1], p[2] * sz);
  };
  const rows = [];
  for (let ring = 0; ring <= rings; ring += 1) {
    const rho = ring === 0 ? 0 : Math.pow(ring / rings, 0.85);
    rows.push((a) => surface(rho, a));
  }
  if (spec.folds) for (const hem of lod === 0 ? [0.55, 1] : [1]) rows.push((a) => surface(1, a, hem));
  const grid = rows.map((row) => Array.from({ length: segments + 1 }, (_, k) => row((2 * Math.PI * (k % segments)) / segments)));
  gridSurface(out, grid, P[spec.part]);
  const normalAt = (rho, a) => {
    const n = vnorm(vcross(vsub(surface(Math.min(1, rho + 0.02), a), surface(Math.max(0, rho - 0.02), a)), vsub(surface(rho, a + 0.02), surface(rho, a - 0.02))));
    return n[1] < 0 ? vscale(n, -1) : n;
  };
  if (spec.chunks) {
    // Broken concrete all over, bedded about a third deep: area-weighted
    // positions, mostly small pieces with a few slabs; the far level keeps
    // the biggest.
    const count = spec.chunks[0];
    const keep = spec.chunks[lod];
    const pieces = [];
    for (let i = 0; i < count; i += 1) {
      const rho = Math.sqrt(0.003 + 0.9 * hash(i, seed, 1));
      const a = hash(i, seed, 2) * Math.PI * 2;
      // Smaller toward the foot, which stays walkable.
      const size = (0.12 + 0.28 * hash(i, seed, 3) ** 2.2) * (1 - 0.6 * smoothstep(0.7, 0.95, rho));
      pieces.push({ i, rho, a, size });
    }
    pieces.sort((p, q) => q.size - p.size);
    for (const { i, rho, a, size } of pieces.slice(0, keep)) {
      const n = normalAt(rho, a);
      const ref = Math.abs(n[1]) < 0.95 ? Y : X;
      const t1 = vnorm(vcross(ref, n));
      const t2 = vcross(n, t1);
      const yaw = hash(i, seed, 4) * Math.PI * 2;
      const ax0 = vnorm(vadd(vscale(t1, Math.cos(yaw)), vscale(t2, Math.sin(yaw))));
      const tilt = (hash(i, seed, 5) - 0.5) * 0.5;
      const ay = vnorm(vadd(n, vscale(ax0, tilt)));
      const ax = vnorm(vsub(ax0, vscale(ay, vdot(ax0, ay))));
      const az = vcross(ax, ay);
      const half = [size * (0.75 + 0.4 * hash(i, 6)), size * (0.42 + 0.25 * hash(i, 8)), size * (0.55 + 0.35 * hash(i, 7))];
      const center = vadd(surface(rho, a), vscale(n, half[1] * 0.25));
      chunk(out, center, [ax, ay, az], half, seed * 1000 + i, P.concrete, 0.72 + 0.28 * hash(i, seed, 9));
    }
  }
  if (lod === 0 && spec.folds) {
    // Tyres holding the sheeting down on the mounds, square to the sheet and
    // bedded a little into it.
    for (let i = 0; i < 7; i += 1) {
      const mound = mounds[i % mounds.length];
      const angle = hash(i, seed, 9) * Math.PI * 2;
      const reach = mound.r * (0.15 + 0.45 * hash(i, seed, 8));
      const x = mound.x + reach * Math.cos(angle);
      const z = mound.z + reach * Math.sin(angle);
      const rho = Math.min(0.85, Math.hypot(x, z));
      const a = Math.atan2(z, x);
      const n = normalAt(rho, a);
      out.lathe(vadd(surface(rho, a), vscale(n, -0.06)), n, [[0.2, 0], [0.33, 0.02], [0.36, 0.11], [0.3, 0.2], [0.2, 0.2], [0.2, 0.02]], 10, () => P.tire);
    }
  }
  return out.result();
}

// ---------------------------------------------------------------- small yard pieces
function buildCylinderSection(lod) {
  const out = new YardBuilder();
  const sides = lod === 0 ? 24 : 12;
  const R = 0.9;
  const r = 0.75;
  const H = 1.3;
  out.lathe(v3(0, 0, 0), Y, [[R, 0], [R, H]], sides, () => P.concrete, 0, () => 1);
  out.lathe(v3(0, 0, 0), Y, [[R, H], [r, H]], sides, () => P.concrete, 0, () => 1);
  out.lathe(v3(0, 0, 0), Y, [[r, H], [r, 0.02]], sides, () => P.inside, 0, (i) => (i === 0 ? 0.8 : 0.45));
  out.lathe(v3(0, 0, 0), Y, [[r, 0.02], [0, 0.02]], sides, () => P.inside, 0, () => 0.35);
  return out.result();
}

function buildCraneMats(lod) {
  const out = new YardBuilder();
  for (let layer = 0; layer < 4; layer += 1) {
    const y0 = layer * 0.3;
    const dz = (hash(layer, 11) - 0.5) * 0.16;
    const dx = (hash(layer, 12) - 0.5) * 0.06;
    if (lod > 0) {
      out.aabb([-0.6 + dx, y0, -4.55 + dz], [0.6 + dx, y0 + 0.3, 4.55 + dz], (face) => (face === "-y" && layer > 0 ? null : P.timber));
      continue;
    }
    for (let t = 0; t < 4; t += 1) {
      const x0 = -0.6 + t * 0.3 + dx;
      out.aabb([x0 + 0.004, y0, -4.55 + dz], [x0 + 0.296, y0 + 0.296, 4.55 + dz], (face) => (face === "-y" && layer > 0 ? null : P.timber), { ao: (face) => (face === "-y" ? 0.5 : 1) });
    }
    // Bolt plates near the ends.
    for (const z of [-3.9, 0, 3.9]) {
      out.aabb([-0.62 + dx, y0 + 0.08, z + dz - 0.05], [-0.6 + dx, y0 + 0.22, z + dz + 0.05], P.hub);
      out.aabb([0.6 + dx, y0 + 0.08, z + dz - 0.05], [0.62 + dx, y0 + 0.22, z + dz + 0.05], P.hub);
    }
  }
  return out.result();
}


// ---------------------------------------------------------------- vehicles
// Generic forms of the vehicle types photographed in and around the yards
// (box trucks, cargo and step vans, coaches and shuttles, class A and C
// motorhomes, travel and fifth-wheel trailers, food trucks, boats on
// trailers, cargo, utility, semi and office trailers), not any make. Bodies
// are swept side profiles (sweptBody) with tagged edges; windows and doors
// are coplanar panels of the side faces.

// Points on an arc about (cz, cy) from angle a0 to a1 (degrees, 0 = +z, 90 = +y).
function arcPts(cz, cy, r, a0, a1, n) {
  const points = [];
  for (let i = 0; i <= n; i += 1) {
    const a = ((a0 + ((a1 - a0) * i) / n) * Math.PI) / 180;
    points.push([cz + r * Math.cos(a), cy + r * Math.sin(a)]);
  }
  return points;
}

// A profile assembled from tagged runs; edge j (point j to j+1) takes the tag
// of the run point j+1 belongs to: a run lists the points its edges reach.
function profileOf(runs) {
  const points = [];
  const tags = [];
  for (const [tag, list] of runs) {
    for (const point of list) {
      if (points.length > 0) {
        const last = points.at(-1);
        if (Math.hypot(point[0] - last[0], point[1] - last[1]) < 1e-4) continue;
      }
      points.push(point);
      tags.push(tag);
    }
  }
  // Drop a closing point equal to the first.
  if (Math.hypot(points[0][0] - points.at(-1)[0], points[0][1] - points.at(-1)[1]) < 1e-4) {
    points.pop();
    tags.pop();
  }
  return { points, tags };
}

// A wheel arch along a bottom edge running toward -z: from the sill up over
// the wheel (a circle of radius ra about the wheel centre) and back down. When
// the sill stands above the wheel centre the arch starts where the circle
// meets the sill.
function archRun(zc, wheelR, ra, sill) {
  if (sill >= wheelR) {
    const start = (Math.asin(clamp((sill - wheelR) / ra, -1, 0.95)) * 180) / Math.PI;
    return arcPts(zc, wheelR, ra, start, 180 - start, 7);
  }
  return [[zc + ra, sill], ...arcPts(zc, wheelR, ra, 0, 180, 7), [zc - ra, sill]];
}

// A wheel well for a bogie of axles along a bottom edge running toward -z: a
// notch from z1 down to z0 (z1 > z0) up to `top`, its upper corners rounded.
function wellRun(z0, z1, top, sill, radius = 0.25) {
  return [[z1, sill], ...arcPts(z1 - radius, top - radius, radius, 0, 90, 3), ...arcPts(z0 + radius, top - radius, radius, 90, 180, 3), [z0, sill]];
}

// Sweeps a tagged profile; parts: {tag: part | {face, round}} (null: leave out).
function sweepTagged(out, profile, hw, parts, { r = 0.06, steps = 2, side, smoothDeg = 30 } = {}) {
  sweptBody(out, {
    profile: profile.points,
    hw,
    r,
    steps: out.lod > 0 ? 1 : steps,
    smoothDeg,
    side,
    partEdge: (j, mid, band) => {
      const entry = parts[profile.tags[(j + 1) % profile.tags.length]];
      if (entry === undefined) return P.paint;
      if (entry === null || typeof entry === "number") return entry;
      return entry[band];
    },
    aoEdge: (j) => (["under", "arch"].includes(profile.tags[(j + 1) % profile.tags.length]) ? 0.45 : 1),
  });
}

// A lamp or reflector: a small box standing proud of a face.
function lamp(out, center, half, part) {
  out.aabb(vsub(center, half), vadd(center, half), part);
}

// Rear-view mirror on an arm from a body corner.
function mirror(out, side, base, reach, lod) {
  if (lod > 0) return;
  const tip = vadd(base, v3(side * reach[0], reach[1], reach[2]));
  out.beam(base, tip, 0.03, 0.03, P.trim);
  out.aabb(vadd(tip, v3(-0.05, -0.2, -0.04)), vadd(tip, v3(0.05, 0.12, 0.04)), (face) => (face === "+z" ? P.glass : P.trim));
}

// A trailer tongue: an A-frame from the body front to a coupler, with a jack.
function tongue(out, zBody, zTip, y, halfSpread, lod, { tanks = false } = {}) {
  for (const s of [1, -1]) out.beam(v3(s * halfSpread, y, zBody), v3(0, y, zTip + 0.25), 0.1, 0.12, P.trim);
  out.aabb([-0.09, y - 0.08, zTip], [0.09, y + 0.08, zTip + 0.35], P.trim);
  if (lod === 0) {
    out.cylinder(v3(0.18, 0, zTip + 0.6), Y, 0.04, y + 0.25, 8, P.metal);
    out.cylinder(v3(0.18, 0, zTip + 0.6), Y, 0.09, 0.05, 8, P.trim);
  }
  if (tanks) {
    for (const s of [1, -1]) {
      const zc = zBody - 0.45;
      out.lathe(v3(s * 0.2, y + 0.06, zc), Y, [[0, 0], [0.16, 0.02], [0.16, 0.6], [0.11, 0.72], [0.05, 0.75], [0, 0.75]], lod === 0 ? 10 : 6, () => P.white_body);
    }
  }
}

// A rear roll-up door frame on a box end facing dir at z, from x -hw..hw (LOD0 detail).
function boxRearDetails(out, z, dir, hw, y0, y1, lod, { kind = "rollup" } = {}) {
  if (lod > 0) return;
  const zz = [z, z + dir * 0.03].sort((a, b) => a - b);
  if (kind === "swing") {
    // Swing doors with four lock bars (semi trailers).
    out.aabb([-0.008, y0 + 0.05, zz[0]], [0.008, y1 - 0.05, zz[1] + 0.004], P.seal);
    for (const bx of [-0.75, -0.25, 0.25, 0.75]) {
      out.aabb([bx - 0.016, y0 + 0.08, zz[0]], [bx + 0.016, y1 - 0.08, zz[1] + 0.03], P.lock_bar);
      out.aabb([bx, y0 + 0.95, zz[0]], [bx + Math.sign(bx) * 0.22, y0 + 0.99, zz[1] + 0.05], P.lock_bar);
    }
    return;
  }
  // Roll-up: a door frame and a pull strap.
  for (const x of [-hw + 0.06, hw - 0.06]) out.aabb([x - 0.04, y0, zz[0]], [x + 0.04, y1, zz[1]], P.metal);
  out.aabb([-hw + 0.06, y1 - 0.08, zz[0]], [hw - 0.06, y1, zz[1]], P.metal);
  out.aabb([-0.05, y0 + 0.05, zz[0]], [0.05, y0 + 0.5, zz[1] + 0.01], P.trim);
}

// ---- box trucks
function buildBoxTruck(variant, lod) {
  const out = new YardBuilder(lod);
  const large = variant === "large";
  const L = large ? 10.4 : 7.4;
  const hl = L / 2;
  const R = large ? 0.5 : 0.42;
  const cabHw = large ? 1.17 : 1.0;
  const boxHw = large ? 1.3 : 1.2;
  const boxTop = large ? 4.0 : 3.5;
  const boxBottom = large ? 1.18 : 0.98;
  const front = -hl;
  const frontAxle = large ? front + 1.05 : front + 0.95;
  const rearAxle = large ? hl - 2.35 : hl - 1.95;
  const cabBack = large ? front + 2.75 : front + 2.05;
  const boxFront = cabBack + 0.12;
  // Cab.
  if (large) {
    const p = profileOf([
      ["bumper", [[front, 0.42], [front, 0.75]]],
      ["grille", [[front + 0.02, 0.78], [front + 0.04, 1.5]]],
      ["hood", [[front + 0.12, 1.62], ...arcPts(front + 0.45, 1.35, 0.33, 90, 75, 2), [front + 1.25, 1.72]]],
      ["windshield", [[front + 1.32, 1.76], [front + 1.62, 2.66]]],
      ["roof", [...arcPts(front + 1.75, 2.66, 0.14, 160, 90, 3), [cabBack - 0.12, 2.8], ...arcPts(cabBack - 0.12, 2.68, 0.12, 90, 0, 2)]],
      ["back", [[cabBack, 2.5], [cabBack, 0.62]]],
      ["under", [[frontAxle + R + 0.08, 0.62]]],
      ["arch", archRun(frontAxle, R, R + 0.07, 0.62)],
      ["under", [[front + 0.1, 0.55]]],
    ]);
    sweepTagged(out, p, cabHw, {
      bumper: P.chrome, grille: { face: P.grille, round: P.chrome }, hood: P.paint, windshield: { face: P.glass, round: P.trim },
      roof: P.paint, back: P.paint, under: P.under, arch: P.under,
    }, {
      r: 0.12,
      side: {
        part: P.paint,
        holes: [rectHole(front + 1.55, cabBack - 0.15, 1.75, 2.55, P.glass, { radius: 0.05 })],
      },
    });
  } else {
    const p = profileOf([
      ["bumper", [[front, 0.45], [front, 0.78]]],
      ["grille", [[front + 0.01, 0.8], [front + 0.02, 1.25]]],
      ["windshield", [[front + 0.03, 1.3], [front + 0.12, 2.3]]],
      ["roof", [...arcPts(front + 0.28, 2.3, 0.18, 165, 90, 3), [cabBack - 0.1, 2.48], ...arcPts(cabBack - 0.1, 2.38, 0.1, 90, 0, 2)]],
      ["back", [[cabBack, 2.2], [cabBack, 0.6]]],
      ["under", [[frontAxle + R + 0.08, 0.6]]],
      ["arch", archRun(frontAxle, R, R + 0.07, 0.6)],
      ["under", [[front + 0.1, 0.55]]],
    ]);
    sweepTagged(out, p, cabHw, {
      bumper: P.trim, grille: { face: P.grille, round: P.paint }, windshield: { face: P.glass, round: P.trim },
      roof: P.paint, back: P.paint, under: P.under, arch: P.under,
    }, {
      r: 0.14,
      side: {
        part: P.paint,
        holes: [rectHole(front + 0.25, front + 1.25, 1.4, 2.2, P.glass, { radius: 0.06 })],
      },
    });
  }
  // Box body (the secondary colour), a roll-up door at the rear.
  const box = profileOf([
    ["front", [[boxFront, boxBottom], [boxFront, boxTop - 0.05]]],
    ["top", [[boxFront + 0.05, boxTop], [hl - 0.05, boxTop]]],
    ["rear", [[hl, boxTop - 0.05], [hl, boxBottom]]],
    ["bottom", [[hl - 0.02, boxBottom - 0.02], [boxFront + 0.02, boxBottom - 0.02]]],
  ]);
  sweepTagged(out, box, boxHw, { front: P.accent, top: P.accent, rear: { face: P.rollup, round: P.accent }, bottom: P.under }, {
    r: 0.04,
    steps: 1,
    side: { part: P.accent },
  });
  boxRearDetails(out, hl, 1, boxHw, boxBottom + 0.08, boxTop - 0.15, lod);
  // Chassis rails, rear bumper, fuel tank, lamps.
  out.aabb([-0.45, 0.62, cabBack - 0.3], [0.45, boxBottom, hl - 0.25], P.under, { ao: 0.4 });
  out.aabb([-boxHw + 0.05, 0.55, hl - 0.12], [boxHw - 0.05, 0.72, hl + 0.03], P.trim);
  if (lod === 0) {
    out.cylinder(v3(-0.62, 0.75, cabBack + 0.15), Z, 0.25, 0.9, 12, P.metal);
    for (const s of [1, -1]) {
      lamp(out, v3(s * (cabHw - 0.18), large ? 1.35 : 1.05, front - 0.005), v3(0.13, 0.07, 0.012), P.head_lamp);
      lamp(out, v3(s * (boxHw - 0.12), 0.85, hl + 0.035), v3(0.09, 0.07, 0.012), P.tail_lamp);
      mirror(out, s, v3(s * cabHw, 2.0, front + (large ? 1.6 : 0.3)), [0.22, 0.05, -0.05], lod);
    }
    lamp(out, v3(0, 0.66, hl + 0.04), v3(0.15, 0.06, 0.01), P.plate);
  }
  // Wheels: single front, dual rear.
  const tw = large ? 0.28 : 0.23;
  axle(out, frontAxle, 2 * cabHw - tw - 0.04, R, tw, lod, { well: R + 0.07 });
  axle(out, rearAxle, 2 * boxHw - tw * 2 - 0.12, R, tw, lod, { dual: true });
  return out.result();
}

// ---- buses
function buildBus(variant, lod) {
  const out = new YardBuilder(lod);
  if (variant === "shuttle") return buildShuttle(out, lod);
  const hl = 6.85;
  const hw = 1.3;
  const R = 0.51;
  const roof = 3.5;
  const sill = 0.34;
  const front = -hl;
  const axles = [-4.75, 2.35, 3.75];
  const p = profileOf([
    ["bumper", [[front, sill + 0.08], [front, 0.75]]],
    ["nose", [[front, 0.8], [front + 0.02, 1.18]]],
    ["windshield", [[front + 0.03, 1.24], [front + 0.2, 3.05]]],
    ["sign", [[front + 0.22, 3.12], ...arcPts(front + 0.55, roof - 0.33, 0.33, 165, 90, 3)]],
    ["roof", [[hl - 0.3, roof], ...arcPts(hl - 0.3, roof - 0.3, 0.3, 90, 0, 3)]],
    ["rear", [[hl, 2.9], [hl, sill + 0.1]]],
    ["under", [[hl - 0.12, sill]]],
    ["arch", archRun(axles[2], R, R + 0.07, sill)],
    ["arch", archRun(axles[1], R, R + 0.07, sill)],
    ["under", [[axles[0] + R + 0.07, sill]]],
    ["arch", archRun(axles[0], R, R + 0.07, sill)],
    ["under", [[front + 0.12, sill]]],
  ]);
  const holes = [];
  // Passenger windows: dark panes with black pillars, a driver's window, the door on the right.
  holes.push(bandHole(-4.85, 6.27, 1.95, 3.18, 7, 0.12, P.glass, P.trim));
  holes.push(rectHole(front + 0.45, -5.0, 1.3, 3.1, P.glass, { side: -1, radius: 0.04 }));
  holes.push(rectHole(front + 0.45, -5.4, 0.56, 3.1, P.glass, { side: 1, radius: 0.04 }));
  // Luggage bays in brushed metal and the accent band under the windows.
  for (const [z0, z1] of [[-3.95, -2.15], [-2.05, -0.25], [-0.15, 1.65]]) holes.push(rectHole(z0, z1, 0.52, 1.42, P.metal));
  holes.push(rectHole(-4.85, hl - 0.2, 1.56, 1.76, P.accent));
  sweepTagged(out, p, hw, {
    bumper: P.trim, nose: P.paint, windshield: { face: P.glass, round: P.trim }, sign: { face: P.trim, round: P.paint },
    roof: P.paint, rear: P.paint, under: P.under, arch: P.under,
  }, { r: 0.12, steps: 2, side: { part: P.paint, holes } });
  // Roof pod, rear grille and lamps, mirrors.
  out.aabb([-0.95, roof - 0.02, -1.0], [0.95, roof + 0.2, 3.8], (face) => (face === "-y" ? null : P.vent));
  if (lod === 0) {
    lamp(out, v3(0, 1.2, hl + 0.012), v3(0.95, 0.42, 0.012), P.grille);
    for (const s of [1, -1]) {
      lamp(out, v3(s * (hw - 0.12), 1.3, hl + 0.012), v3(0.07, 0.35, 0.012), P.tail_lamp);
      lamp(out, v3(s * (hw - 0.3), 0.68, front - 0.012), v3(0.2, 0.08, 0.012), P.head_lamp);
      mirror(out, s, v3(s * (hw - 0.05), 2.95, front + 0.15), [0.18, 0.25, -0.45], lod);
    }
    lamp(out, v3(0, 0.6, hl + 0.015), v3(0.16, 0.08, 0.008), P.plate);
  }
  axle(out, axles[0], 2 * hw - 0.34, R, 0.3, lod, { well: R + 0.07 });
  axle(out, axles[1], 2 * hw - 0.66, R, 0.28, lod, { dual: true, well: R + 0.07 });
  axle(out, axles[2], 2 * hw - 0.34, R, 0.28, lod, { well: R + 0.07 });
  return out.result();
}

// A cutaway van cab (shuttle bus, class C motorhome): hood and windshield,
// cab doors; the box body sits behind it.
function cutawayCab(out, front, cabBack, hw, R, frontAxle, lod) {
  const p = profileOf([
    ["bumper", [[front, 0.4], [front, 0.68]]],
    ["grille", [[front + 0.02, 0.72], [front + 0.08, 1.08]]],
    ["hood", [[front + 0.2, 1.18], [front + 0.75, 1.3]]],
    ["windshield", [[front + 0.82, 1.35], [front + 1.38, 2.18]]],
    ["roof", [...arcPts(front + 1.5, 2.12, 0.12, 120, 90, 2), [cabBack, 2.24]]],
    ["back", [[cabBack, 0.55]]],
    ["under", [[frontAxle + R + 0.07, 0.55]]],
    ["arch", archRun(frontAxle, R, R + 0.06, 0.55)],
    ["under", [[front + 0.1, 0.5]]],
  ]);
  sweepTagged(out, p, hw, {
    bumper: P.trim, grille: { face: P.grille, round: P.paint }, hood: P.paint, windshield: { face: P.glass, round: P.trim },
    roof: P.paint, back: P.paint, under: P.under, arch: P.under,
  }, { r: 0.14, side: { part: P.paint, holes: [rectHole(front + 1.05, cabBack - 0.08, 1.38, 2.08, P.glass, { radius: 0.05 })] } });
  if (lod === 0) {
    for (const s of [1, -1]) {
      lamp(out, v3(s * (hw - 0.2), 0.95, front + 0.04), v3(0.14, 0.07, 0.012), P.head_lamp);
      mirror(out, s, v3(s * hw, 1.8, front + 1.1), [0.2, 0.05, -0.05], lod);
    }
  }
}

function buildShuttle(out, lod) {
  const hl = 4.1;
  const hw = 1.2;
  const R = 0.4;
  const front = -hl;
  const frontAxle = -3.0;
  const rearAxle = 1.75;
  const cabBack = front + 1.95;
  cutawayCab(out, front, cabBack, 1.0, R, frontAxle, lod);
  const boxFront = cabBack - 0.15;
  const p = profileOf([
    ["front", [[boxFront, 0.72], [boxFront, 2.2], [boxFront - 0.35, 2.36], ...arcPts(boxFront - 0.1, 2.95, 0.25, 180, 90, 3)]],
    ["roof", [[hl - 0.18, 3.2], ...arcPts(hl - 0.18, 3.02, 0.18, 90, 0, 2)]],
    ["rear", [[hl, 0.75]]],
    ["under", [[rearAxle + R + 0.07, 0.72]]],
    ["arch", archRun(rearAxle, R, R + 0.07, 0.72)],
    ["under", [[boxFront + 0.05, 0.72]]],
  ]);
  const holes = [];
  for (let i = 0; i < 4; i += 1) {
    const z0 = -1.1 + i * 1.28;
    holes.push(rectHole(z0, z0 + 1.16, 1.58, 2.6, P.glass, { radius: 0.05 }));
  }
  holes.push(rectHole(boxFront + 0.12, boxFront + 1.0, 0.88, 2.75, P.glass, { side: 1, radius: 0.04 }));
  holes.push(rectHole(-1.15, hl - 0.2, 1.3, 1.45, P.accent));
  sweepTagged(out, p, hw, { front: P.paint, roof: P.paint, rear: { face: P.paint, round: P.paint }, under: P.under, arch: P.under }, { r: 0.14, side: { part: P.paint, holes } });
  if (lod === 0) {
    lamp(out, v3(0, 2.55, hl + 0.012), v3(0.7, 0.32, 0.012), P.glass);
    for (const s of [1, -1]) lamp(out, v3(s * (hw - 0.12), 1.15, hl + 0.012), v3(0.07, 0.25, 0.012), P.tail_lamp);
  }
  out.aabb([-hw + 0.05, 0.45, hl - 0.1], [hw - 0.05, 0.62, hl + 0.05], P.trim);
  out.aabb([-0.4, 0.5, frontAxle + 0.5], [0.4, 0.75, hl - 0.4], P.under, { ao: 0.4 });
  axle(out, frontAxle, 1.75, R, 0.22, lod, { well: R + 0.06 });
  axle(out, rearAxle, 2 * hw - 0.62, R, 0.22, lod, { dual: true, well: R + 0.07 });
  return out.result();
}

// ---- motorhomes and RV trailers
// The decal swooshes of an RV side: two bands of the stripe colour, low
// along the body and sweeping up toward the front, broken where a door or a
// window stands in their way (gaps: [[z0, z1], ...]).
function swooshes(z0, z1, yLow, rise, gaps = [], segment = 0.5) {
  const bands = [];
  const yAt = (z, offset) => yLow + offset + rise * Math.pow((z1 - z) / (z1 - z0), 2.2);
  // The pieces of [z0, z1] outside the gaps.
  const pieces = [];
  let start = z0;
  for (const [g0, g1] of [...gaps].sort((a, b) => a[0] - b[0])) {
    if (g0 > start + 0.3) pieces.push([start, Math.min(g0, z1)]);
    start = Math.max(start, g1);
  }
  if (z1 > start + 0.3) pieces.push([start, z1]);
  for (const [offset, height] of [[0, 0.16], [0.26, 0.08]]) {
    for (const [p0, p1] of pieces) {
      const n = Math.max(2, Math.ceil((p1 - p0) / segment));
      const lower = [];
      const upper = [];
      for (let i = 0; i <= n; i += 1) {
        const z = lerp(p1, p0, i / n);
        const y = yAt(z, offset);
        lower.push([z, y]);
        upper.push([z, y + height]);
      }
      bands.push({ points: [...lower, ...upper.reverse()], part: P.accent, ao: 1 });
    }
  }
  return bands;
}

function buildRv(variant, lod) {
  const out = new YardBuilder(lod);
  switch (variant) {
    case "class_a": return classA(out, lod);
    case "class_c": return classC(out, lod);
    case "travel_trailer": return travelTrailer(out, lod);
    default: return fifthWheel(out, lod);
  }
}

function classA(out, lod) {
  const hl = 5.8;
  const hw = 1.275;
  const R = 0.5;
  const roof = 3.45;
  const sill = 0.42;
  const front = -hl;
  const frontAxle = -3.75;
  const rearAxle = 2.55;
  const p = profileOf([
    ["bumper", [[front + 0.05, sill + 0.05], [front, 0.75]]],
    ["grille", [[front - 0.02, 0.8], [front, 1.18]]],
    ["windshield", [[front + 0.02, 1.25], ...arcPts(front + 0.9, 1.6, 0.88, 180, 120, 3), [front + 0.62, 2.6]]],
    ["cap", [...arcPts(front + 1.1, roof - 0.55, 0.55, 150, 90, 4)]],
    ["roof", [[hl - 0.25, roof], ...arcPts(hl - 0.25, roof - 0.25, 0.25, 90, 0, 3)]],
    ["rear", [[hl, sill + 0.15]]],
    ["under", [[hl - 0.15, sill]]],
    ["arch", archRun(rearAxle, R, R + 0.08, sill)],
    ["under", [[frontAxle + R + 0.08, sill]]],
    ["arch", archRun(frontAxle, R, R + 0.08, sill)],
    ["under", [[front + 0.2, sill]]],
  ]);
  const holes = [
    rectHole(front + 0.95, front + 1.75, 1.45, 2.45, P.glass, { radius: 0.08 }),
    rectHole(-2.15, -1.05, 1.85, 2.6, P.glass, { radius: 0.08 }),
    rectHole(-0.25, 1.05, 1.85, 2.6, P.glass, { radius: 0.08 }),
    rectHole(2.35, 3.45, 1.95, 2.6, P.glass, { radius: 0.08 }),
    // The entry door on the right, behind the front axle.
    rectHole(-3.0, -2.35, 0.5, 2.75, P.white_body, { side: 1, radius: 0.04 }),
    ...swooshes(-4.0, hl - 0.3, 1.27, 0.3, [[-3.1, -2.25]], lod === 0 ? 0.5 : 1.6),
  ];
  sweepTagged(out, p, hw, {
    bumper: P.trim, grille: { face: P.grille, round: P.paint }, windshield: { face: P.glass, round: P.trim }, cap: P.paint,
    roof: P.paint, rear: P.paint, under: P.under, arch: P.under,
  }, { r: 0.16, side: { part: P.paint, holes } });
  roofKit(out, lod, roof, [-2.0, 2.4]);
  if (lod === 0) {
    lamp(out, v3(0, 2.75, hl + 0.012), v3(0.75, 0.3, 0.012), P.glass);
    for (const s of [1, -1]) {
      lamp(out, v3(s * (hw - 0.15), 1.2, hl + 0.012), v3(0.08, 0.3, 0.012), P.tail_lamp);
      lamp(out, v3(s * (hw - 0.35), 0.95, front - 0.03), v3(0.2, 0.08, 0.012), P.head_lamp);
      mirror(out, s, v3(s * (hw - 0.05), 2.6, front + 0.4), [0.15, 0.2, -0.35], lod);
    }
    // Ladder up the rear.
    for (const x of [0.55, 0.95]) out.aabb([x - 0.015, 1.0, hl + 0.06], [x + 0.015, roof, hl + 0.09], P.metal);
    for (let y = 1.15; y < roof; y += 0.3) out.aabb([0.55, y - 0.012, hl + 0.06], [0.95, y + 0.012, hl + 0.09], P.metal);
  }
  axle(out, frontAxle, 2 * hw - 0.34, R, 0.28, lod, { well: R + 0.08 });
  axle(out, rearAxle, 2 * hw - 0.64, R, 0.26, lod, { dual: true, well: R + 0.08 });
  return out.result();
}

// Roof AC units and vents of an RV.
function roofKit(out, lod, roof, acZ) {
  for (const z of acZ) {
    out.aabb([-0.38, roof - 0.02, z - 0.5], [0.38, roof + 0.28, z + 0.5], (face) => (face === "-y" ? null : P.vent));
  }
  if (lod === 0) {
    for (const z of [acZ[0] - 1.2, (acZ[0] + acZ.at(-1)) / 2, acZ.at(-1) + 1.1]) {
      out.aabb([0.3, roof - 0.02, z - 0.2], [0.7, roof + 0.1, z + 0.2], (face) => (face === "-y" ? null : P.vent));
    }
  }
}

function classC(out, lod) {
  const hl = 4.25;
  const hw = 1.2;
  const R = 0.38;
  const front = -hl;
  const frontAxle = -2.95;
  const rearAxle = 1.55;
  const cabBack = front + 1.85;
  cutawayCab(out, front, cabBack, 1.0, R, frontAxle, lod);
  const boxFront = cabBack - 0.12;
  const roof = 3.2;
  const p = profileOf([
    ["front", [[boxFront, 0.72], [boxFront, 2.2], [boxFront - 0.25, 2.3]]],
    ["bunk", [[front + 0.95, 2.36], ...arcPts(front + 1.15, 2.72, 0.32, 210, 120, 4), [front + 1.45, roof - 0.05]]],
    ["roof", [[hl - 0.22, roof], ...arcPts(hl - 0.22, roof - 0.22, 0.22, 90, 0, 3)]],
    ["rear", [[hl, 0.78]]],
    ["under", [[rearAxle + R + 0.08, 0.72]]],
    ["arch", archRun(rearAxle, R, R + 0.07, 0.72)],
    ["under", [[boxFront + 0.05, 0.72]]],
  ]);
  const holes = [
    rectHole(front + 1.0, front + 1.6, 2.5, 2.85, P.glass, { radius: 0.06 }),
    rectHole(-1.9, -0.9, 1.7, 2.45, P.glass, { radius: 0.07 }),
    rectHole(1.8, 2.9, 1.8, 2.45, P.glass, { radius: 0.07 }),
    rectHole(-0.6, 0.05, 0.88, 2.7, P.white_body, { side: 1, radius: 0.04 }),
    ...swooshes(-1.85, hl - 0.2, 1.05, 0.25, [[-0.7, 0.15]], lod === 0 ? 0.5 : 1.6),
  ];
  sweepTagged(out, p, hw, { front: P.paint, bunk: P.paint, roof: P.paint, rear: P.paint, under: P.under, arch: P.under }, { r: 0.15, side: { part: P.paint, holes } });
  roofKit(out, lod, roof, [0.6]);
  if (lod === 0) for (const s of [1, -1]) lamp(out, v3(s * (hw - 0.14), 1.2, hl + 0.012), v3(0.07, 0.28, 0.012), P.tail_lamp);
  out.aabb([-0.4, 0.5, frontAxle + 0.5], [0.4, 0.75, hl - 0.4], P.under, { ao: 0.4 });
  axle(out, frontAxle, 1.75, R, 0.22, lod, { well: R + 0.06 });
  axle(out, rearAxle, 2 * hw - 0.6, R, 0.22, lod, { dual: true, well: R + 0.07 });
  return out.result();
}

function travelTrailer(out, lod) {
  const hl = 4.5;
  const hw = 1.22;
  const R = 0.36;
  const bodyFront = -3.1;
  const roof = 3.0;
  const sill = 0.62;
  const axles = [0.75, 1.55];
  const p = profileOf([
    ["front", [[bodyFront + 0.1, sill], [bodyFront - 0.15, 1.15], [bodyFront - 0.18, 2.35], ...arcPts(bodyFront + 0.25, roof - 0.42, 0.42, 165, 90, 4)]],
    ["roof", [[hl - 0.15, roof], ...arcPts(hl - 0.15, roof - 0.15, 0.15, 90, 0, 2)]],
    ["rear", [[hl, sill + 0.05]]],
    ["under", [[axles[1] + R + 0.12, sill]]],
    ["arch", wellRun(axles[0] - R - 0.12, axles[1] + R + 0.12, 2 * R + 0.1, sill)],
    ["under", [[bodyFront + 0.15, sill]]],
  ]);
  const holes = [
    rectHole(-2.4, -1.4, 1.7, 2.35, P.glass, { radius: 0.08 }),
    rectHole(0.0, 0.9, 1.7, 2.35, P.glass, { radius: 0.08 }),
    rectHole(2.6, 3.7, 1.7, 2.35, P.glass, { radius: 0.08 }),
    rectHole(-1.05, -0.4, 0.82, 2.6, P.white_body, { side: 1, radius: 0.04 }),
    ...swooshes(-2.9, hl - 0.2, 1.0, 0.25, [[-1.15, -0.3]], lod === 0 ? 0.5 : 1.6),
  ];
  // The front window across the cap.
  sweepTagged(out, p, hw, { front: { face: P.paint, round: P.paint }, roof: P.paint, rear: P.paint, under: P.under, arch: P.under }, { r: 0.12, side: { part: P.paint, holes } });
  if (lod === 0) {
    lamp(out, v3(0, 1.9, bodyFront - 0.19), v3(0.75, 0.22, 0.012), P.glass);
    for (const s of [1, -1]) lamp(out, v3(s * (hw - 0.12), 1.0, hl + 0.012), v3(0.07, 0.15, 0.012), P.tail_lamp);
  }
  roofKit(out, lod, roof, [0.6]);
  tongue(out, bodyFront + 0.05, -hl, 0.5, 0.8, lod, { tanks: true });
  out.aabb([-0.9, 0.42, bodyFront], [0.9, sill, hl - 0.2], P.under, { ao: 0.4 });
  for (const z of axles) axle(out, z, 2 * hw - 0.3, R, 0.2, lod, { well: 0.48 });
  return out.result();
}

function fifthWheel(out, lod) {
  const hl = 5.25;
  const hw = 1.25;
  const R = 0.4;
  const roof = 3.6;
  const sill = 0.68;
  const neck = -3.15;
  const front = -hl;
  const axles = [1.35, 2.2, 3.05];
  const p = profileOf([
    ["neck", [[neck, sill], [neck, 1.5], [front + 0.35, 1.5]]],
    ["front", [...arcPts(front + 0.35, 1.85, 0.35, 270, 180, 3), [front, 2.6], ...arcPts(front + 0.6, roof - 0.6, 0.6, 180, 90, 5)]],
    ["roof", [[hl - 0.2, roof], ...arcPts(hl - 0.2, roof - 0.2, 0.2, 90, 0, 2)]],
    ["rear", [[hl, sill + 0.05]]],
    ["under", [[axles[2] + R + 0.12, sill]]],
    ["arch", wellRun(axles[0] - R - 0.12, axles[2] + R + 0.12, 2 * R + 0.1, sill)],
    ["under", [[neck + 0.05, sill]]],
  ]);
  const holes = [
    rectHole(front + 0.7, front + 1.6, 2.5, 3.05, P.glass, { radius: 0.08 }),
    rectHole(-2.4, -1.2, 1.9, 2.65, P.glass, { radius: 0.08 }),
    rectHole(0.2, 1.2, 1.9, 2.65, P.glass, { radius: 0.08 }),
    rectHole(3.4, 4.5, 1.95, 2.65, P.glass, { radius: 0.08 }),
    rectHole(-0.65, 0.0, 0.9, 2.85, P.white_body, { side: 1, radius: 0.04 }),
    ...swooshes(-2.9, hl - 0.25, 1.05, 0.45, [[-0.75, 0.1], [0.75, 3.65]], lod === 0 ? 0.5 : 1.6),
  ];
  sweepTagged(out, p, hw, { neck: P.paint, front: { face: P.paint, round: P.paint }, roof: P.paint, rear: P.paint, under: P.under, arch: P.under }, { r: 0.15, side: { part: P.paint, holes } });
  if (lod === 0) {
    // The cap's dark window band, landing legs and the kingpin plate.
    lamp(out, v3(0, 2.75, front - 0.008), v3(0.95, 0.35, 0.012), P.glass);
    for (const s of [1, -1]) {
      out.aabb([s * 0.85 - 0.06, 0, neck - 0.3], [s * 0.85 + 0.06, 1.5, neck - 0.18], P.trim);
      out.aabb([s * 0.85 - 0.12, 0, neck - 0.36], [s * 0.85 + 0.12, 0.04, neck - 0.12], P.trim);
      lamp(out, v3(s * (hw - 0.12), 1.05, hl + 0.012), v3(0.07, 0.15, 0.012), P.tail_lamp);
    }
    out.aabb([-0.5, 1.35, front + 0.5], [0.5, 1.5, front + 1.6], P.under);
  }
  roofKit(out, lod, roof, [-1.5, 2.6]);
  out.aabb([-0.9, 0.48, neck], [0.9, sill, hl - 0.2], P.under, { ao: 0.4 });
  for (const z of axles) axle(out, z, 2 * hw - 0.32, R, 0.22, lod, { well: 0.52 });
  return out.result();
}

// ---- vans
function buildVan(variant, lod) {
  if (variant === "cargo") {
    // The car kit's high-roof cargo van, re-encoded into the yard kit's part slots.
    const car = buildCar("van", lod);
    const uvs = car.uvs.slice();
    for (let i = 0; i < uvs.length; i += 2) {
      const part = Math.floor(uvs[i] * 16);
      uvs[i] = (part + 0.5) / YARD_KIT_PART_SLOTS;
    }
    return { ...car, uvs };
  }
  return stepVan(new YardBuilder(lod), lod, { length: 7.0, height: 2.95, food: false });
}

// A food truck's serving window in its +X side at x = hw: glazing in a
// stainless frame with a sliding sash, a counter ledge under it and a fixed
// stainless awning hood over it (City View Commissary, Mar 2025: the window
// side of a parked truck, closed). The hood and ledge stand out 0.3 m at
// most, so trucks parked a third of a metre apart stay clear of each other.
function servingWindow(out, lod, hw, z0, z1, y0, y1) {
  if (lod === 0) {
    const t = 0.025;
    out.aabb([hw, y0 - 0.05, z0 - 0.05], [hw + t, y0, z1 + 0.05], P.chrome);
    out.aabb([hw, y1, z0 - 0.05], [hw + t, y1 + 0.05, z1 + 0.05], P.chrome);
    out.aabb([hw, y0, z0 - 0.05], [hw + t, y1, z0], P.chrome);
    out.aabb([hw, y0, z1], [hw + t, y1, z1 + 0.05], P.chrome);
    out.aabb([hw, y0, (z0 + z1) / 2 - 0.025], [hw + t, y1, (z0 + z1) / 2 + 0.025], P.chrome);
  }
  out.aabb([hw, y0 - 0.11, z0 - 0.05], [hw + 0.22, y0 - 0.05, z1 + 0.05], P.metal);
  // The hood: a stainless sheet sloping down and out from over the window,
  // closed at its ends.
  const top = y1 + 0.16;
  const reach = 0.28;
  const drop = 0.14;
  const angle = Math.atan2(drop, reach);
  const along = v3(Math.cos(angle), -Math.sin(angle), 0);
  const up = v3(Math.sin(angle), Math.cos(angle), 0);
  const length = Math.hypot(reach, drop);
  out.box(vadd(v3(hw, top, (z0 + z1) / 2), vscale(along, length / 2)), [length / 2, 0.012, (z1 - z0) / 2 + 0.12], (face) => (face === "+y" ? P.chrome : P.metal), [along, up, Z]);
  for (const z of [z0 - 0.12, z1 + 0.12]) {
    const zz = [z - 0.006, z + 0.006];
    out.face([v3(hw, top, zz[0]), v3(hw + reach, top - drop, zz[0]), v3(hw, top - drop, zz[0])].concat([v3(hw, top - drop, zz[0])]), NZ, P.chrome);
    out.face([v3(hw, top, zz[1]), v3(hw + reach, top - drop, zz[1]), v3(hw, top - drop, zz[1])].concat([v3(hw, top - drop, zz[1])]), Z, P.chrome);
  }
}

// A walk-in step van (and the food truck built on one): a tall box body with a
// short nose, a big flat windshield and folding doors at the front.
function stepVan(out, lod, { length, height, food }) {
  const hl = length / 2;
  const hw = 1.2;
  const R = 0.42;
  const front = -hl;
  const frontAxle = front + 1.25;
  const rearAxle = hl - 1.85;
  const sill = 0.55;
  const p = profileOf([
    ["bumper", [[front, 0.42], [front, 0.72]]],
    ["grille", [[front + 0.02, 0.76], [front + 0.05, 1.05]]],
    ["hood", [[front + 0.12, 1.15], [front + 0.38, 1.25]]],
    ["windshield", [[front + 0.42, 1.32], [front + 0.6, 2.55]]],
    ["roof", [...arcPts(front + 0.82, height - 0.22, 0.22, 150, 90, 3), [hl - 0.08, height], ...arcPts(hl - 0.08, height - 0.08, 0.08, 90, 0, 2)]],
    ["rear", [[hl, sill + 0.05]]],
    ["under", [[rearAxle + R + 0.07, sill]]],
    ["arch", archRun(rearAxle, R, R + 0.07, sill)],
    ["under", [[frontAxle + R + 0.07, sill]]],
    ["arch", archRun(frontAxle, R, R + 0.07, sill)],
    ["under", [[front + 0.1, 0.5]]],
  ]);
  const holes = [
    // Folding entry doors at the front of both sides, glazed above.
    rectHole(front + 1.85, front + 2.6, 1.3, 2.45, P.glass, { radius: 0.04 }),
    rectHole(front + 1.85, front + 2.6, sill + 0.16, 1.22, P.seal),
  ];
  if (food) holes.push(rectHole(-0.75, 1.75, 1.3, 2.15, P.glass, { side: 1 }));
  sweepTagged(out, p, hw, {
    bumper: P.trim, grille: { face: P.grille, round: P.paint }, hood: P.paint, windshield: { face: P.glass, round: P.trim },
    roof: P.paint, rear: { face: food ? P.paint : P.rollup, round: P.paint }, under: P.under, arch: P.under,
  }, { r: 0.12, side: { part: P.paint, holes } });
  if (lod === 0) {
    for (const s of [1, -1]) {
      lamp(out, v3(s * (hw - 0.22), 0.92, front - 0.012), v3(0.15, 0.08, 0.012), P.head_lamp);
      lamp(out, v3(s * (hw - 0.1), 1.0, hl + 0.012), v3(0.07, 0.2, 0.012), P.tail_lamp);
      mirror(out, s, v3(s * hw, 2.1, front + 0.65), [0.22, 0.0, -0.1], lod);
    }
    if (!food) boxRearDetails(out, hl, 1, hw, sill + 0.1, height - 0.2, lod);
    lamp(out, v3(0, 0.62, hl + 0.015), v3(0.15, 0.07, 0.008), P.plate);
  }
  if (food) {
    // The serving window on the right, the roof's hood vent and AC.
    servingWindow(out, lod, hw, -0.75, 1.75, 1.3, 2.15);
    out.aabb([0.1, height - 0.02, -0.4], [0.95, height + 0.32, 0.5], (face) => (face === "-y" ? null : P.vent));
    out.aabb([-0.75, height - 0.02, 1.2], [-0.05, height + 0.25, 2.0], (face) => (face === "-y" ? null : P.vent));
  }
  out.aabb([-hw + 0.05, 0.42, hl - 0.1], [hw - 0.05, 0.6, hl + 0.05], P.trim);
  axle(out, frontAxle, 1.95, R, 0.23, lod, { well: R + 0.07 });
  axle(out, rearAxle, 2 * hw - 0.58, R, 0.22, lod, { dual: true, well: R + 0.07 });
  return out.result();
}

// ---- food trucks
function buildFoodTruck(variant, lod) {
  const out = new YardBuilder(lod);
  if (variant === "step_van") return stepVan(out, lod, { length: 7.3, height: 2.98, food: true });
  // A concession trailer.
  const hl = 3.1;
  const hw = 1.22;
  const R = 0.36;
  const bodyFront = -2.0;
  const roof = 2.72;
  const sill = 0.6;
  const p = profileOf([
    ["front", [[bodyFront, sill], ...arcPts(bodyFront + 0.3, roof - 0.3, 0.3, 180, 90, 3)]],
    ["roof", [[hl - 0.15, roof], ...arcPts(hl - 0.15, roof - 0.15, 0.15, 90, 0, 2)]],
    ["rear", [[hl, sill]]],
    ["under", [[0.7 + R + 0.1, sill]]],
    ["arch", archRun(0.7, R, R + 0.12, sill)],
    ["under", [[bodyFront + 0.05, sill]]],
  ]);
  sweepTagged(out, p, hw, { front: P.paint, roof: P.paint, rear: P.paint, under: P.under, arch: P.under }, {
    r: 0.1,
    side: { part: P.paint, holes: [rectHole(-1.25, 1.05, 1.25, 2.1, P.glass, { side: 1 }), rectHole(1.6, 2.4, 0.8, 2.4, P.white_body, { side: -1, radius: 0.03 })] },
  });
  servingWindow(out, lod, hw, -1.25, 1.05, 1.25, 2.1);
  out.aabb([-0.4, roof - 0.02, -0.6], [0.4, roof + 0.28, 0.3], (face) => (face === "-y" ? null : P.vent));
  tongue(out, bodyFront + 0.05, -hl, 0.48, 0.75, lod, { tanks: true });
  out.aabb([-0.9, 0.4, bodyFront], [0.9, sill, hl - 0.2], P.under, { ao: 0.4 });
  axle(out, 0.7, 2 * hw - 0.3, R, 0.2, lod, { well: R + 0.12 });
  if (lod === 0) for (const s of [1, -1]) lamp(out, v3(s * (hw - 0.12), 0.95, hl + 0.012), v3(0.07, 0.12, 0.012), P.tail_lamp);
  return out.result();
}

// ---- trailers
function buildTrailer(variant, lod) {
  const out = new YardBuilder(lod);
  switch (variant) {
    case "cargo": {
      const hl = 3.65;
      const hw = 1.22;
      const R = 0.35;
      const bodyFront = -2.75;
      const roof = 2.95;
      const sill = 0.5;
      const axles = [0.55, 1.35];
      const p = profileOf([
        ["front", [[bodyFront, sill], [bodyFront - 0.2, 1.0], [bodyFront - 0.2, roof - 0.25], ...arcPts(bodyFront + 0.05, roof - 0.25, 0.25, 180, 90, 3)]],
        ["roof", [[hl - 0.06, roof], ...arcPts(hl - 0.06, roof - 0.06, 0.06, 90, 0, 1)]],
        ["rear", [[hl, sill]]],
        ["under", [[bodyFront + 0.05, sill]]],
      ]);
      sweepTagged(out, p, hw, { front: P.paint, roof: P.paint, rear: { face: P.paint, round: P.paint }, under: P.under }, {
        r: 0.08,
        side: { part: P.paint, holes: [rectHole(-1.9, -1.15, 0.66, 2.35, P.paint, { side: 1 })] },
      });
      if (lod === 0) {
        // Side door outline, rear ramp door hinges and latches.
        for (const [z0, z1] of [[-1.92, -1.9], [-1.15, -1.13]]) out.aabb([hw, 0.6, z0], [hw + 0.01, 2.35, z1], P.seal);
        out.aabb([hw, 2.35, -1.92], [hw + 0.01, 2.37, -1.13], P.seal);
        for (const x of [-0.8, 0.8]) out.aabb([x - 0.02, 1.2, hl], [x + 0.02, 2.3, hl + 0.04], P.lock_bar);
        for (const s of [1, -1]) lamp(out, v3(s * (hw - 0.1), 0.75, hl + 0.012), v3(0.06, 0.06, 0.012), P.tail_lamp);
      }
      // Fenders over the tandem wheels.
      for (const s of [1, -1]) out.aabb([s > 0 ? hw : -hw - 0.1, R * 2 + 0.06, axles[0] - R - 0.15], [s > 0 ? hw + 0.1 : -hw, R * 2 + 0.12, axles[1] + R + 0.15], P.trim);
      tongue(out, bodyFront + 0.05, -hl, 0.45, 0.75, lod);
      out.aabb([-0.9, 0.38, bodyFront], [0.9, sill, hl - 0.1], P.under, { ao: 0.4 });
      for (const z of axles) axle(out, z, 2 * hw + 0.02, R, 0.2, lod);
      return out.result();
    }
    case "utility": {
      const hl = 2.25;
      const hw = 0.95;
      const R = 0.33;
      const deck = 0.55;
      const z0 = -1.4;
      out.aabb([-hw, deck - 0.08, z0], [hw, deck, hl - 0.05], (face) => (face === "+y" ? P.deck : P.paint), { ao: (face) => (face === "-y" ? 0.4 : 1) });
      // Rails, posts and mesh bars round the deck; the rear gate stands up.
      const top = deck + 0.45;
      for (const s of [1, -1]) {
        out.aabb([s * hw - 0.025, top - 0.04, z0], [s * hw + 0.025, top, hl - 0.05], P.paint);
        for (let z = z0; z <= hl - 0.05 + 1e-6; z += lod === 0 ? 0.25 : 3.6) out.aabb([s * hw - 0.012, deck, z - 0.012], [s * hw + 0.012, top, z + 0.012], P.paint);
      }
      out.aabb([-hw, top - 0.04, z0 - 0.025], [hw, top, z0 + 0.025], P.paint);
      for (let x = -hw; x <= hw + 1e-6; x += lod === 0 ? 0.25 : 1.9) out.aabb([x - 0.012, deck, z0 - 0.012], [x + 0.012, top, z0 + 0.012], P.paint);
      const gateTop = deck + 1.0;
      out.aabb([-hw, gateTop - 0.04, hl - 0.05], [hw, gateTop, hl], P.paint);
      for (let x = -hw; x <= hw + 1e-6; x += lod === 0 ? 0.2 : 1.9) out.aabb([x - 0.012, deck, hl - 0.04], [x + 0.012, gateTop, hl - 0.01], P.paint);
      for (const s of [1, -1]) out.aabb([s > 0 ? hw : -hw - 0.24, R * 2 + 0.02, 0.15 - R - 0.1], [s > 0 ? hw + 0.24 : -hw, R * 2 + 0.06, 0.15 + R + 0.1], P.paint);
      tongue(out, z0, -hl, 0.42, 0.55, lod);
      axle(out, 0.15, 2 * hw + 0.2, R, 0.18, lod);
      return out.result();
    }
    case "semi": {
      const hl = 8.1;
      const hw = 1.3;
      const R = 0.5;
      const bottom = 1.25;
      const roof = 4.1;
      const axles = [5.3, 6.55];
      const p = profileOf([
        ["front", [[-hl, bottom], [-hl, roof - 0.05]]],
        ["roof", [[-hl + 0.05, roof], [hl - 0.05, roof]]],
        ["rear", [[hl, roof - 0.05], [hl, bottom]]],
        ["under", [[hl - 0.05, bottom - 0.01], [-hl + 0.05, bottom - 0.01]]],
      ]);
      sweepTagged(out, p, hw, { front: P.paint, roof: P.paint, rear: { face: P.container_door, round: P.paint }, under: P.under }, { r: 0.04, steps: 1, side: { part: P.shed_wall } });
      boxRearDetails(out, hl, 1, hw, bottom + 0.05, roof - 0.1, lod, { kind: "swing" });
      // Rub rail, landing gear, bogie and bumper.
      out.aabb([-hw - 0.02, bottom, -hl], [hw + 0.02, bottom + 0.12, hl], (face) => (face === "-y" ? null : P.trim));
      for (const s of [1, -1]) {
        out.aabb([s * 0.8 - 0.07, 0.05, -5.6], [s * 0.8 + 0.07, bottom, -5.45], P.trim);
        out.aabb([s * 0.8 - 0.15, 0, -5.65], [s * 0.8 + 0.15, 0.06, -5.4], P.trim);
      }
      out.aabb([-0.55, 0.75, axles[0] - 0.9], [0.55, bottom, axles[1] + 0.9], P.under, { ao: 0.4 });
      out.aabb([-hw + 0.1, 0.5, hl - 0.15], [hw - 0.1, 0.65, hl - 0.02], P.trim);
      if (lod === 0) for (const s of [1, -1]) lamp(out, v3(s * (hw - 0.15), 0.95, hl - 0.02), v3(0.1, 0.06, 0.03), P.tail_lamp);
      for (const z of axles) axle(out, z, 2 * hw - 0.6, R, 0.28, lod, { dual: true });
      return out.result();
    }
    default: {
      // A mobile office on blocks: skirting round the base, windows, a door with steps.
      const hl = 7.3;
      const hw = 1.83;
      const bodyFront = -6.6;
      const bottom = 0.6;
      const roof = 3.35;
      const p = profileOf([
        ["front", [[bodyFront, 0.0], [bodyFront, roof - 0.05]]],
        ["roof", [[bodyFront + 0.05, roof], [hl - 0.05, roof]]],
        ["rear", [[hl, roof - 0.05], [hl, 0.0]]],
        ["under", [[hl - 0.05, 0.0], [bodyFront + 0.05, 0.0]]],
      ]);
      const holes = [];
      for (const z of [-5.2, -2.6, 0.9, 3.4, 5.9]) holes.push(rectHole(z - 0.55, z + 0.55, 1.45, 2.4, P.glass));
      holes.push(rectHole(-1.55, -0.65, 0.65, 2.6, P.white_body, { side: 1 }));
      holes.push(rectHole(bodyFront + 0.06, hl - 0.06, 0.06, bottom, P.cab_paint));
      sweepTagged(out, p, hw, { front: P.shed_wall, roof: P.white_body, rear: P.shed_wall, under: P.under }, { r: 0.03, steps: 1, side: { part: P.shed_wall, holes } });
      if (lod === 0) {
        // White window frames, the door's steps and landing, the hitch.
        for (const z of [-5.2, -2.6, 0.9, 3.4, 5.9]) {
          for (const s of [1, -1]) {
            const x = s * hw;
            const xs = [x, x + s * 0.035].sort((a, b) => a - b);
            out.aabb([xs[0], 1.4, z - 0.6], [xs[1], 1.45, z + 0.6], P.white_body);
            out.aabb([xs[0], 2.4, z - 0.6], [xs[1], 2.45, z + 0.6], P.white_body);
            out.aabb([xs[0], 1.45, z - 0.6], [xs[1], 2.4, z - 0.55], P.white_body);
            out.aabb([xs[0], 1.45, z + 0.55], [xs[1], 2.4, z + 0.6], P.white_body);
          }
        }
        out.aabb([hw, 0.55, -1.75], [hw + 1.1, 0.6, -0.45], P.metal);
        for (let i = 0; i < 3; i += 1) out.aabb([hw + 1.1 + i * 0.28, 0.0, -1.55], [hw + 1.38 + i * 0.28, 0.42 - i * 0.18, -0.65], P.metal);
        for (const z of [-1.75, -0.45]) out.aabb([hw + 1.06, 0.6, z - 0.02], [hw + 1.1, 1.5, z + 0.02], P.metal);
        out.aabb([hw + 1.06, 1.46, -1.75], [hw + 1.1, 1.5, -0.45], P.metal);
      }
      tongue(out, bodyFront, -hl, 0.45, 1.2, lod);
      return out.result();
    }
  }
}

// ---- boats on trailers
// A trailer-borne powerboat: a V hull with a raked bow and flat transom, a
// windshield and outboard (runabout) or a cabin (cabin cruiser), open or under
// a fitted cover; on a bunk trailer with a winch post.
function buildBoat(variant, covered, lod) {
  const out = new YardBuilder(lod);
  const cabin = variant === "cabin";
  const length = cabin ? 7.7 : 6.1;
  const beam = cabin ? 2.5 : 2.36;
  const zBow = cabin ? -3.75 : -3.0;
  const zStern = zBow + length;
  const keel = cabin ? 0.72 : 0.66;
  const sheer = cabin ? 1.85 : 1.6;
  const stations = lod === 0 ? 12 : 6;
  // Loft rings (right half, bottom centre to deck centre) along the hull.
  const grid = [];
  for (let k = 0; k <= stations; k += 1) {
    const t = k / stations;
    const z = zBow + length * t;
    const bowT = clamp(t / 0.32, 0, 1);
    const halfBeam = (beam / 2) * Math.sin((Math.PI / 2) * bowT) * (1 - 0.06 * t);
    const keelY = keel + (1 - bowT) ** 2 * 0.55;
    const sheerY = sheer + (1 - t) * 0.22;
    const chine = keelY + 0.22 * (0.4 + 0.6 * bowT);
    const deckY = sheerY + 0.06;
    grid.push([
      v3(0, keelY, z),
      v3(halfBeam * 0.8, chine, z),
      v3(halfBeam, chine + 0.12, z),
      v3(halfBeam * 1.0, sheerY - 0.12, z),
      v3(halfBeam * 0.98, sheerY, z),
      v3(halfBeam * 0.6, deckY, z),
      v3(0, deckY + 0.02, z),
    ]);
  }
  // The transom: close the stern with the last ring's face.
  const cockpit = (z) => z > zBow + length * (cabin ? 0.62 : 0.35) && z < zStern - 0.35;
  // Ring segments: 0 the V bottom, 1 the chine (a dark boot stripe), 2 the
  // topsides, 3 the rub rail, 4 the deck edge, 5 the deck (or the cockpit).
  out.loft(grid, (k, j) => {
    const z = (grid[k][0][2] + grid[k + 1][0][2]) / 2;
    if (j === 1 || j === 3) return P.trim;
    if (j === 5 && cockpit(z)) return covered ? P.canvas : P.inside;
    return P.fiberglass;
  }, { crease: 50 });
  const last = grid.at(-1);
  for (let j = 0; j < last.length - 1; j += 1) {
    for (const sign of [1, -1]) {
      const a = v3(sign * last[j][0], last[j][1], last[j][2]);
      const b = v3(sign * last[j + 1][0], last[j + 1][1], last[j + 1][2]);
      const c = v3(0, b[1], b[2]);
      const d = v3(0, a[1], a[2]);
      out.face([a, b, c, d], Z, P.fiberglass);
    }
  }
  // Windshield, cabin, outboard, cover.
  const midZ = zBow + length * (cabin ? 0.4 : 0.36);
  if (cabin) {
    const c0 = zBow + length * 0.3;
    const c1 = zBow + length * 0.62;
    const top = sheer + 0.95;
    out.aabb([-beam / 2 + 0.25, sheer, c0], [beam / 2 - 0.25, top, c1], (face) => (face === "+x" || face === "-x" ? P.fiberglass : face === "-z" ? P.glass : P.fiberglass), {
      holes: {
        "+x": [{ u0: c0 + 0.4, u1: c1 - 0.3, v0: sheer + 0.45, v1: top - 0.15, part: P.glass }],
        "-x": [{ u0: c0 + 0.4, u1: c1 - 0.3, v0: sheer + 0.45, v1: top - 0.15, part: P.glass }],
      },
    });
  } else {
    out.beam(v3(-beam / 2 + 0.25, sheer + 0.08, midZ), v3(beam / 2 - 0.25, sheer + 0.08, midZ), 0.06, 0.06, P.trim);
    const glass = [v3(-beam / 2 + 0.25, sheer + 0.08, midZ), v3(beam / 2 - 0.25, sheer + 0.08, midZ), v3(beam / 2 - 0.35, sheer + 0.45, midZ + 0.22), v3(-beam / 2 + 0.35, sheer + 0.45, midZ + 0.22)];
    out.face(glass, vnorm(v3(0, 0.5, -1)), P.glass);
    out.face(glass, vnorm(v3(0, -0.5, 1)), P.glass);
  }
  if (covered) {
    // The fitted cover over the cockpit: a low tent to the transom.
    const z0 = cabin ? zBow + length * 0.62 : midZ + 0.22;
    const z1 = zStern - 0.12;
    const hb = beam / 2 - 0.08;
    const top = sheer + (cabin ? 0.65 : 0.55);
    const ridgeZ = [z0 + 0.3, z1 - 0.2];
    out.face([v3(hb, sheer + 0.04, z0), v3(hb, sheer + 0.04, z1), v3(0, top, ridgeZ[1]), v3(0, top, ridgeZ[0])], vnorm(v3(1, 1.6, 0)), P.canvas);
    out.face([v3(-hb, sheer + 0.04, z0), v3(-hb, sheer + 0.04, z1), v3(0, top, ridgeZ[1]), v3(0, top, ridgeZ[0])], vnorm(v3(-1, 1.6, 0)), P.canvas);
    out.tri(v3(hb, sheer + 0.04, z0), v3(-hb, sheer + 0.04, z0), v3(0, top, ridgeZ[0]), vnorm(v3(0, 0.5, -1)), P.canvas);
    out.tri(v3(hb, sheer + 0.04, z1), v3(-hb, sheer + 0.04, z1), v3(0, top, ridgeZ[1]), vnorm(v3(0, 0.5, 1)), P.canvas);
  }
  const motorZ = zStern + 0.05;
  if (cabin) {
    for (const x of [-0.45, 0.45]) out.aabb([x - 0.22, keel + 0.1, motorZ], [x + 0.22, sheer + 0.45, motorZ + 0.42], P.trim);
  } else {
    out.aabb([-0.24, keel + 0.05, motorZ], [0.24, sheer + 0.5, motorZ + 0.5], P.trim);
  }
  // The trailer: frame rails, bunks, winch post, fenders, tongue, axle(s).
  const R = 0.33;
  const axles = cabin ? [0.55, 1.35] : [0.6];
  for (const s of [1, -1]) {
    out.aabb([s * 0.62 - 0.05, 0.38, zBow - 0.2], [s * 0.62 + 0.05, 0.5, zStern - 0.3], P.metal);
    out.aabb([s * 0.5 - 0.06, 0.5, zBow + length * 0.3], [s * 0.5 + 0.06, keel + 0.12, zStern - 0.4], P.timber);
    out.aabb([s > 0 ? beam / 2 - 0.15 : -beam / 2 - 0.05, R * 2 + 0.04, axles[0] - R - 0.12], [s > 0 ? beam / 2 + 0.05 : -beam / 2 + 0.15, R * 2 + 0.08, axles.at(-1) + R + 0.12], P.metal);
  }
  out.aabb([-0.06, 0.4, zBow - 0.35], [0.06, 1.25, zBow - 0.22], P.metal);
  if (lod === 0) out.cylinder(v3(-0.1, 1.05, zBow - 0.28), X, 0.07, 0.2, 8, P.metal);
  tongue(out, zBow - 0.2, cabin ? -4.4 : -3.65, 0.44, 0.6, lod);
  for (const z of axles) axle(out, z, beam - 0.25, R, 0.18, lod);
  return out.result();
}

// ---------------------------------------------------------------- equipment
// Sweeps a tagged profile into a builder of its own and adds it moved by
// offset (a swept body is always centred on x = 0).
function sweepAt(out, profile, hw, parts, offset, options = {}) {
  const local = new YardBuilder(out.lod);
  sweepTagged(local, profile, hw, parts, options);
  appendMesh(out, local.result(), offset);
}

// A hydraulic cylinder from a to b: a painted barrel, then a chrome rod.
function ram(out, a, b, radius, part) {
  const split = vadd(a, vscale(vsub(b, a), 0.58));
  out.beam(a, split, radius * 2, radius * 2, part);
  out.beam(split, b, radius, radius, P.chrome);
}

// A strip of side profile around the line a -> b (z, y), depth da at a and db
// at b: a beam's outline for sweepAt.
function stripProfile(tag, a, b, da, db) {
  const d = vnorm2([b[0] - a[0], b[1] - a[1]]);
  const n = [-d[1], d[0]];
  return profileOf([[tag, [
    [a[0] + n[0] * da / 2, a[1] + n[1] * da / 2], [b[0] + n[0] * db / 2, b[1] + n[1] * db / 2],
    [b[0] - n[0] * db / 2, b[1] - n[1] * db / 2], [a[0] - n[0] * da / 2, a[1] - n[1] * da / 2],
  ]]]);
}

// A crawler excavator parked with its arm hanging and the bucket curled on the
// ground under the boom tip (Avenue M, Nov 2025: a red boom and arm high over
// a white house with a dark cab; Seven Seas Ave, Nov 2025: yellow machines).
// Boom, arm and bucket take the row's paint (primary), the house and its
// counterweight the house colour (secondary). The swing centre stands behind
// the plan's middle so the reach fits the plan.
const EXCAVATOR_SWING_Z = 1.5;
function buildExcavator(lod) {
  const out = new YardBuilder(lod);
  const zc = EXCAVATOR_SWING_Z;
  const R = 0.42;
  // Tracks: rounded track frames, idler at the front, sprocket at the rear.
  const track = profileOf([["track", [...arcPts(zc - 1.85, R, R, 270, 90, 6), ...arcPts(zc + 1.85, R + 0.04, R + 0.04, 90, -90, 6)]]]);
  for (const s of [1, -1]) sweepAt(out, track, 0.3, { track: P.hub }, v3(s * 1.3, 0, 0), { r: 0.04, steps: 1, side: { part: P.trim } });
  out.aabb([-1.0, 0.45, zc - 1.4], [1.0, 1.0, zc + 1.4], P.under, { ao: 0.5 });
  if (lod === 0) {
    // Track rollers along the frames' inner faces.
    for (const s of [1, -1]) for (let k = -2; k <= 2; k += 1) out.aabb([s * 1.0 - 0.02, 0.12, zc + k * 0.62 - 0.15], [s * 1.0 + 0.02, 0.36, zc + k * 0.62 + 0.15], P.under);
  }
  // The house: engine and counterweight across the full width behind the cab
  // and the boom foot; a tool box on the right front, the cab on the left.
  const deck = 1.05;
  const house = profileOf([
    ["front", [[zc + 0.05, deck]]],
    ["bottom", [[zc + 2.15, deck]]],
    ["counterweight", arcPts(zc + 2.15, deck + 0.6, 0.6, -90, 90, lod === 0 ? 6 : 3)],
    ["top", [[zc + 0.05, deck + 1.2]]],
  ]);
  sweepTagged(out, house, 1.45, { front: P.accent, bottom: P.under, counterweight: P.accent, top: P.accent }, { r: 0.1, steps: 2, side: { part: P.accent } });
  out.aabb([0.55, deck, zc - 1.6], [1.45, deck + 0.95, zc + 0.15], (face) => (face === "-y" ? null : P.accent));
  out.aabb([-0.55, deck, zc - 1.5], [0.55, deck + 0.3, zc + 0.15], (face) => (face === "-y" ? null : P.accent));
  const cab = { x0: -1.45, x1: -0.5, z0: zc - 1.6, z1: zc + 0.15, y0: deck, y1: deck + 2.0 };
  out.aabb([cab.x0, cab.y0, cab.z0], [cab.x1, cab.y1, cab.z1], (face) => (face === "-y" ? null : P.trim), {
    holes: {
      "-z": [{ u0: cab.x0 + 0.07, u1: cab.x1 - 0.07, v0: cab.y0 + 0.4, v1: cab.y1 - 0.08, part: P.glass }],
      "-x": [{ u0: cab.z0 + 0.08, u1: cab.z1 - 0.45, v0: cab.y0 + 0.8, v1: cab.y1 - 0.1, part: P.glass }],
      "+x": [{ u0: cab.z0 + 0.08, u1: cab.z1 - 0.25, v0: cab.y0 + 1.0, v1: cab.y1 - 0.1, part: P.glass }],
      "+z": [{ u0: cab.x0 + 0.1, u1: cab.x1 - 0.1, v0: deck + 1.32, v1: cab.y1 - 0.12, part: P.glass }],
    },
  });
  if (lod === 0) {
    // Exhaust, engine grilles on both sides of the house, a rail on top.
    out.cylinder(v3(0.95, deck + 1.2, zc + 1.05), Y, 0.07, 0.5, 8, P.trim);
    for (const s of [1, -1]) {
      const xs = [s * 1.45, s * 1.47].sort((a, b) => a - b);
      out.aabb([xs[0], deck + 0.35, zc + 0.55], [xs[1], deck + 1.0, zc + 1.85], P.grille);
    }
    out.beam(v3(1.3, deck + 1.2, zc + 0.3), v3(1.3, deck + 1.55, zc + 0.3), 0.04, 0.04, P.metal);
    out.beam(v3(1.3, deck + 1.2, zc + 1.9), v3(1.3, deck + 1.55, zc + 1.9), 0.04, 0.04, P.metal);
    out.beam(v3(1.3, deck + 1.55, zc + 0.28), v3(1.3, deck + 1.55, zc + 1.92), 0.04, 0.04, P.metal);
  }
  // Boom: an arch (a quadratic curve) from its foot on the deck, rising
  // steeply, over its crown and down to the tip; deepest at the crown.
  const bx = 0.02;
  const foot = [0.25, 1.75];
  const crown = [-1.6, 5.2];
  const tip = [-4.45, 3.05];
  const curve = (t) => [0, 1].map((k) => (1 - t) * (1 - t) * foot[k] + 2 * t * (1 - t) * crown[k] + t * t * tip[k]);
  const upward = (t) => {
    const d = vnorm2([0, 1].map((k) => 2 * (1 - t) * (crown[k] - foot[k]) + 2 * t * (tip[k] - crown[k])));
    const n = [-d[1], d[0]];
    return n[1] < 0 ? [-n[0], -n[1]] : n;
  };
  const depth = (t) => 0.6 - 0.12 * t + 0.16 * Math.sin(Math.PI * t);
  const edge = (t, side) => {
    const c = curve(t);
    const n = upward(t);
    return [c[0] + side * n[0] * depth(t) / 2, c[1] + side * n[1] * depth(t) / 2];
  };
  const steps = lod === 0 ? 10 : 4;
  const ts = Array.from({ length: steps + 1 }, (_, k) => k / steps);
  const boom = profileOf([["boom", [...ts.map((t) => edge(t, 1)), ...ts.slice().reverse().map((t) => edge(t, -1))]]]);
  sweepAt(out, boom, 0.27, { boom: P.crane_red }, v3(bx, 0, 0), { r: 0.05, steps: 1, side: { part: P.crane_red } });
  // Arm: hangs from the boom tip, leaning back toward the machine, its heel
  // above the tip; the bucket curled under it.
  const pin = [-3.95, 0.95];
  const along = vnorm2([pin[0] - tip[0], pin[1] - tip[1]]);
  const heel = [tip[0] - along[0] * 0.7, tip[1] - along[1] * 0.7];
  sweepAt(out, stripProfile("arm", heel, pin, 0.55, 0.32), 0.2, { arm: P.crane_red }, v3(bx, 0, 0), { r: 0.04, steps: 1, side: { part: P.crane_red } });
  // Bucket, curled: the shell round the front and under, its teeth pointing
  // back toward the machine on the ground; the open mouth faces up and back.
  const at = (dz, dy) => [pin[0] + dz, pin[1] + dy];
  const bucket = profileOf([
    ["mouth", [at(0.32, 0.24)]],
    ["shell", [at(-0.3, 0.26), ...arcPts(pin[0] - 0.03, pin[1] - 0.43, 0.5, 125, 275, lod === 0 ? 6 : 3), at(0.57, -0.93)]],
  ]);
  sweepAt(out, bucket, 0.55, { mouth: P.gravel, shell: P.crane_red }, v3(bx, 0, 0), { r: 0.03, steps: 1, side: { part: P.crane_red } });
  if (lod === 0) {
    for (const x of [-0.39, -0.13, 0.13, 0.39]) out.aabb([bx + x - 0.045, 0.01, pin[0] + 0.52], [bx + x + 0.045, 0.1, pin[0] + 0.68], P.metal);
    // Boom rams from the house front up under the boom; the arm ram from a
    // bracket on the boom's back over the crown to the heel; the bucket ram
    // down the arm's back to the links.
    const under = edge(0.35, -1);
    for (const s of [1, -1]) ram(out, v3(bx + s * 0.36, 1.32, 0.15), v3(bx + s * 0.36, under[1] - 0.05, under[0]), 0.085, P.crane_red);
    const back = edge(0.45, 1);
    out.aabb([bx - 0.1, back[1] - 0.2, back[0] - 0.16], [bx + 0.1, back[1] + 0.22, back[0] + 0.16], P.crane_red);
    ram(out, v3(bx, back[1] + 0.2, back[0]), v3(bx, heel[1] + 0.22, heel[0] + 0.06), 0.08, P.crane_red);
    ram(out, v3(bx, heel[1] - 0.05, heel[0] + 0.32), v3(bx, pin[1] + 0.55, pin[0] + 0.3), 0.07, P.crane_red);
    for (const s of [1, -1]) out.beam(v3(bx + s * 0.24, pin[1] + 0.57, pin[0] + 0.27), v3(bx + s * 0.24, pin[1] + 0.18, pin[0] + 0.3), 0.06, 0.12, P.crane_red);
  }
  return out.result();
}

// A wheel loader parked with its bucket flat on the ground: an articulated
// machine, the bucket on two lift arms with a Z-bar tilt linkage, the cab
// over the hinge and the engine under a long hood at the rear (Avenue M and
// Seven Seas Ave yards, Nov 2025: yellow machines). Paint is the row's.
function buildWheelLoader(lod) {
  const out = new YardBuilder(lod);
  const R = 0.78;
  const frontAxle = -1.2;
  const rearAxle = 1.95;
  const track = 2.25;
  // Rear frame: the cab deck, the engine hood and the counterweight.
  const body = profileOf([
    ["front", [[0.25, 0.95]]],
    ["bottom", [[3.4, 0.95]]],
    ["rear", [[3.85, 1.1], [3.92, 1.65]]],
    ["grille", [[3.78, 2.15]]],
    ["hood", [[3.52, 2.33], [1.6, 2.37], [1.47, 2.27]]],
    ["deck", [[1.47, 1.6], [0.25, 1.6]]],
  ]);
  sweepTagged(out, body, 0.82, {
    front: P.crane_red, bottom: P.under, rear: P.crane_red, grille: { face: P.grille, round: P.crane_red }, hood: P.crane_red, deck: P.crane_red,
  }, { r: 0.1, steps: 2, side: { part: P.crane_red } });
  // Fenders over the tyres.
  for (const s of [1, -1]) {
    const xs = [s * 0.8, s * 1.46].sort((a, b) => a - b);
    out.aabb([xs[0], 1.62, rearAxle - 0.72], [xs[1], 1.69, rearAxle + 0.8], P.crane_red);
    out.aabb([xs[0], 1.15, rearAxle + 0.74], [xs[1], 1.69, rearAxle + 0.8], P.crane_red);
    out.aabb([xs[0], 1.62, frontAxle - 0.62], [xs[1], 1.69, frontAxle + 0.45], P.crane_red);
  }
  // Cab with glass all round and a roof slab.
  out.aabb([-0.78, 1.6, -0.1], [0.78, 3.38, 1.5], (face) => (face === "-y" ? null : P.trim), {
    holes: {
      "-z": [{ u0: -0.7, u1: 0.7, v0: 1.85, v1: 3.3, part: P.glass }],
      "+z": [{ u0: -0.66, u1: 0.66, v0: 2.3, v1: 3.3, part: P.glass }],
      "-x": [{ u0: -0.02, u1: 1.32, v0: 1.95, v1: 3.3, part: P.glass }],
      "+x": [{ u0: -0.02, u1: 1.32, v0: 1.95, v1: 3.3, part: P.glass }],
    },
  });
  out.aabb([-0.86, 3.38, -0.18], [0.86, 3.48, 1.58], P.crane_red);
  // Front frame with the arms' tower, and the axle housings.
  out.aabb([-0.5, 0.62, -2.05], [0.5, 1.5, 0.25], P.crane_red);
  out.aabb([-0.55, 1.5, -0.68], [0.55, 2.28, -0.2], P.crane_red);
  out.aabb([-0.85, R - 0.13, frontAxle - 0.16], [0.85, R + 0.13, frontAxle + 0.16], P.under, { ao: 0.5 });
  out.aabb([-0.85, R - 0.13, rearAxle - 0.16], [0.85, R + 0.13, rearAxle + 0.16], P.under, { ao: 0.5 });
  // Lift arms, bent, from the tower to the bucket's back; their cross tube
  // carries the bell crank, tilted by the ram from the tower and linked down
  // to the bucket's top.
  const towerPin = v3(0, 2.08, -0.45);
  const bend = v3(0, 1.62, -1.85);
  const bucketPin = v3(0, 0.62, -3.0);
  for (const s of [1, -1]) {
    const x = v3(s * 0.62, 0, 0);
    out.beam(vadd(towerPin, x), vadd(bend, x), 0.2, 0.42, P.crane_red);
    out.beam(vadd(bend, x), vadd(bucketPin, x), 0.2, 0.4, P.crane_red);
  }
  out.beam(v3(-0.72, 1.62, -1.85), v3(0.72, 1.62, -1.85), 0.3, 0.3, P.crane_red);
  out.beam(v3(0, 2.42, -1.58), v3(0, 1.32, -2.12), 0.26, 0.24, P.crane_red);
  out.beam(v3(0, 1.32, -2.12), v3(0, 1.1, -3.02), 0.16, 0.18, P.crane_red);
  if (lod === 0) {
    ram(out, v3(0, 2.05, -0.62), v3(0, 2.4, -1.6), 0.09, P.crane_red);
    for (const s of [1, -1]) ram(out, v3(s * 0.42, 0.95, -0.55), v3(s * 0.42, 1.48, -1.55), 0.09, P.crane_red);
    out.cylinder(v3(0.45, 2.33, 2.25), Y, 0.08, 0.72, 8, P.trim);
    out.cylinder(v3(-0.45, 2.33, 1.95), Y, 0.13, 0.36, 8, P.trim);
  }
  // The bucket, flat on the ground and open to the front: a steel plate
  // bent into floor, curved back and spill guard between two side plates;
  // the dirty inside shows.
  const arcSteps = lod === 0 ? 7 : 3;
  const outer = [[-4.0, 0.0], [-3.42, 0.0], ...arcPts(-3.42, 0.6, 0.6, 270, 450, arcSteps).slice(1), [-3.76, 1.24]];
  const inner = [[-3.76, 1.17], ...arcPts(-3.42, 0.6, 0.54, 90, -90, arcSteps), [-3.97, 0.06]];
  const plate = profileOf([["edge", [outer[0]]], ["shell", outer.slice(1)], ["inside", inner]]);
  sweepTagged(out, plate, 1.42, { edge: P.metal, shell: P.crane_red, inside: P.gravel }, { r: 0.01, steps: 1, side: { part: P.crane_red } });
  for (const s of [1, -1]) {
    polygonFace(out, v3(s * 1.45, 0, 0), Z, Y, outer, [], v3(s, 0, 0), P.crane_red);
    polygonFace(out, v3(s * 1.42, 0, 0), Z, Y, outer, [], v3(-s, 0, 0), P.gravel, 0.7);
  }
  axle(out, frontAxle, track, R, 0.6, lod, { rimColour: P.crane_red, inner: true });
  axle(out, rearAxle, track, R, 0.6, lod, { rimColour: P.crane_red, inner: true });
  return out.result();
}

// An open-top roll-off bin: a ribbed steel box on two rails, its front raked,
// a hinged rear door; the open top shows the dark inside. Its walls and
// frame rust through the paint (Avenue M, Nov 2025: faded blue, rusted).
function buildOpenBin(lod) {
  const out = new YardBuilder(lod);
  const hw = 1.22;
  const p = profileOf([
    ["bottom", [[3.3, 0.22], [-3.05, 0.22]]],
    ["front", [[-3.45, 1.85]]],
    ["top", [[3.3, 1.85]]],
    ["rear", [[3.3, 0.22]]],
  ]);
  sweepTagged(out, p, hw, { bottom: P.under, front: P.tank, top: { face: P.inside, round: P.container_frame }, rear: P.tank }, { r: 0.04, steps: 1, side: { part: P.tank } });
  for (const s of [1, -1]) out.aabb([s * 0.55 - 0.07, 0, -3.0], [s * 0.55 + 0.07, 0.22, 3.25], P.hub);
  if (lod === 0) {
    // Side stiffeners, the top rail and the rear door's latches.
    for (let z = -2.8; z <= 3.0; z += 0.62) {
      for (const s of [1, -1]) {
        const xs = [s * hw, s * (hw + 0.05)].sort((a, b) => a - b);
        out.aabb([xs[0], 0.25, z - 0.05], [xs[1], 1.8, z + 0.05], P.container_frame);
      }
    }
    for (const s of [1, -1]) {
      const xs = [s * (hw - 0.02), s * (hw + 0.06)].sort((a, b) => a - b);
      out.aabb([xs[0], 1.75, -3.4], [xs[1], 1.88, 3.3], P.container_frame);
    }
    for (const x of [-0.7, 0.7]) out.aabb([x - 0.03, 0.4, 3.3], [x + 0.03, 1.7, 3.36], P.lock_bar);
  }
  return out.result();
}

// A cone-bottomed hopper on four legs, a roof cap and a ladder.
function buildHopper(lod) {
  const out = new YardBuilder(lod);
  const sides = lod === 0 ? 24 : 12;
  const R = 1.9;
  out.lathe(v3(0, 0, 0), Y, [[0.25, 1.35], [0.32, 1.6], [R, 3.4], [R, 7.55], [R - 0.05, 7.62], [0.35, 8.0], [0, 8.0]], sides, (i) => (i === 0 ? P.metal : P.tank), 0, (i) => (i <= 1 ? 0.75 : 1));
  for (const [x, z] of [[1, 1], [1, -1], [-1, 1], [-1, -1]]) {
    const c = v3(x * 1.32, 0, z * 1.32);
    out.aabb([c[0] - 0.1, 0, c[2] - 0.1], [c[0] + 0.1, 3.6, c[2] + 0.1], P.tank);
    if (lod === 0) out.aabb([c[0] - 0.22, 0, c[2] - 0.22], [c[0] + 0.22, 0.03, c[2] + 0.22], P.metal);
  }
  if (lod === 0) {
    for (const [a, b] of [[[1, 1], [1, -1]], [[-1, 1], [-1, -1]], [[1, 1], [-1, 1]], [[1, -1], [-1, -1]]]) {
      out.beam(v3(a[0] * 1.32, 0.4, a[1] * 1.32), v3(b[0] * 1.32, 2.6, b[1] * 1.32), 0.06, 0.06, P.tank);
      out.beam(v3(b[0] * 1.32, 0.4, b[1] * 1.32), v3(a[0] * 1.32, 2.6, a[1] * 1.32), 0.06, 0.06, P.tank);
    }
    for (const x of [-0.22, 0.22]) out.aabb([x - 0.02, 3.6, R + 0.18], [x + 0.02, 8.1, R + 0.22], P.metal);
    for (let y = 3.8; y < 8.0; y += 0.3) out.aabb([-0.22, y - 0.015, R + 0.18], [0.22, y + 0.015, R + 0.22], P.metal);
  }
  return out.result();
}

// A conveyor truss module (6 m along its own Z, belt on top) and a leg (1 m
// tall, scaled in height per instance).
function buildConveyorModule(lod) {
  const out = new YardBuilder(lod);
  const half = CONVEYOR_MODULE_M / 2;
  const hw = 0.55;
  for (const s of [1, -1]) {
    for (const y of [0, 0.75]) out.aabb([s * hw - 0.05, y, -half], [s * hw + 0.05, y + 0.08, half], P.metal);
    if (lod === 0) {
      for (let k = 0; k <= 6; k += 1) {
        const z = -half + k;
        out.aabb([s * hw - 0.03, 0.05, z - 0.03], [s * hw + 0.03, 0.8, z + 0.03], P.metal);
        if (k < 6) out.beam(v3(s * hw, 0.08, z), v3(s * hw, 0.75, z + 1), 0.04, 0.04, P.metal);
      }
    }
  }
  out.aabb([-hw + 0.06, 0.8, -half], [hw - 0.06, 0.86, half], (face) => (face === "+y" ? P.belt : P.under));
  if (lod === 0) for (let k = 0; k < 6; k += 1) out.aabb([-hw, 0.12, -half + k + 0.45], [hw, 0.18, -half + k + 0.55], P.metal);
  return out.result();
}

function buildConveyorLeg(lod) {
  const out = new YardBuilder(lod);
  for (const s of [1, -1]) out.aabb([s * 0.5 - 0.06, 0, -0.06], [s * 0.5 + 0.06, 1, 0.06], P.metal);
  out.aabb([-0.5, 0.85, -0.05], [0.5, 0.95, 0.05], P.metal);
  return out.result();
}

// A cross-section (x, y points round it) extruded along Z from z0 to z1, its
// faces out from the section's middle, both ends capped.
function extrudeZ(out, section, z0, z1, part, endPart = part) {
  const cx = section.reduce((sum, point) => sum + point[0], 0) / section.length;
  const cy = section.reduce((sum, point) => sum + point[1], 0) / section.length;
  for (let i = 0; i < section.length; i += 1) {
    const [x0, y0] = section[i];
    const [x1, y1] = section[(i + 1) % section.length];
    let n = vnorm(v3(y1 - y0, -(x1 - x0), 0));
    if (vdot(n, v3((x0 + x1) / 2 - cx, (y0 + y1) / 2 - cy, 0)) < 0) n = vscale(n, -1);
    out.face([v3(x0, y0, z0), v3(x1, y1, z0), v3(x1, y1, z1), v3(x0, y0, z1)], n, part);
  }
  for (const [z, dir] of [[z0, -1], [z1, 1]]) polygonFace(out, v3(0, 0, z), X, Y, section, [], v3(0, 0, dir), endPart);
}

// A water-filled plastic barrier, one unit 1.9 m long: a jersey section (a
// wide foot, steep lower face, sloped upper face, narrow rounded top), the
// fork pockets through its foot, the interlocking lugs at its ends and the
// fill cap on top. Its plastic is the row's paint.
function buildWaterBarrier(lod) {
  const out = new YardBuilder(lod);
  const hl = 0.9;
  const section = [[0.3, 0.0], [0.3, 0.1], [0.24, 0.3], [0.13, 0.78], [0.1, 0.95], [0.06, 1.0], [-0.06, 1.0], [-0.1, 0.95], [-0.13, 0.78], [-0.24, 0.3], [-0.3, 0.1], [-0.3, 0.0]];
  extrudeZ(out, section, -hl, hl, P.crane_red);
  if (lod === 0) {
    // Fork pockets: dark slots across the foot.
    for (const z of [-0.45, 0.45]) for (const s of [1, -1]) {
      const xs = [s * 0.3, s * 0.303].sort((a, b) => a - b);
      out.aabb([xs[0], 0.02, z - 0.16], [xs[1], 0.16, z + 0.16], P.inside);
    }
    // Lugs at both ends, the fill cap.
    for (const [z0, z1] of [[-hl - 0.06, -hl], [hl, hl + 0.06]]) {
      out.aabb([-0.07, 0.15, z0], [0.07, 0.35, z1], P.crane_red);
      out.aabb([-0.05, 0.62, z0], [0.05, 0.78, z1], P.crane_red);
    }
    out.cylinder(v3(0, 1.0, 0.45), Y, 0.06, 0.03, 8, P.white_body);
  }
  return out.result();
}

// Red machinery on a work barge's deck (Pier 1, May 2026 aerial: red blocks
// beside the cranes), generic: a power pack, a winch skid and a tool
// container, about 7 m by 6 m together. Origin on the deck.
function buildDeckEquipment(lod) {
  const out = new YardBuilder(lod);
  const box = (x0, x1, y1, z0, z1, part = P.crane_red) => out.aabb([x0, 0, z0], [x1, y1, z1], (face) => (face === "-y" ? null : part));
  // Power pack: an enclosure with louvres and an exhaust.
  box(-3.5, -1.3, 1.9, -3.0, 1.2);
  if (lod === 0) {
    for (let k = 0; k < 4; k += 1) out.aabb([-1.3, 0.5, -2.6 + k * 0.9], [-1.28, 1.5, -2.2 + k * 0.9], P.grille);
    out.cylinder(v3(-2.4, 1.9, -0.5), Y, 0.09, 0.7, 8, P.trim);
  }
  // Winch skid: a base frame with a drum.
  box(0.2, 3.2, 0.3, -3.0, -0.6, P.trim);
  out.cylinder(v3(0.4, 0.95, -1.8), X, 0.55, 2.6, lod === 0 ? 16 : 8, P.crane_red);
  // A tool container (a 10 ft box) and a stack of beams beside it.
  box(0.0, 2.4, 2.4, 0.6, 3.6);
  for (let i = 0; i < (lod === 0 ? 4 : 1); i += 1) out.aabb([-3.4 + i * 0.5, 0, 1.8], [-3.0 + i * 0.5, 0.4, 3.6], P.metal);
  return out.result();
}

// ---------------------------------------------------------------- pole flag
// A flag on a slim pole: the pole a galvanised tube one metre tall that the
// runtime stretches to the row's height, a cap for its top, and the flag
// (1.5 x 0.9 m) flying along +X from the pole, waved and drooping a little.
// The flag's UV is a texture coordinate into the pole-flag texture (the upper
// half has SELF STORAGE on its white band, the lower half is plain), not a
// part: the runtime draws it with its own material.
export const POLE_FLAG = Object.freeze({ radius: 0.045, flag_w: 1.5, flag_h: 0.9 });
function buildFlagPole(lod) {
  const out = new YardBuilder(lod);
  out.cylinder(v3(0, 0, 0), Y, POLE_FLAG.radius, 1, lod === 0 ? 10 : 6, P.metal, { caps: false });
  return out.result();
}

function buildFlagCap(lod) {
  const out = new YardBuilder(lod);
  out.lathe(v3(0, 0, 0), Y, [[0, -0.02], [0.055, -0.02], [0.055, 0.02], [0.04, 0.06], [0, 0.08]], lod === 0 ? 10 : 6, () => P.metal);
  return out.result();
}

function buildFlag(text, lod) {
  const columns = lod === 0 ? 12 : 3;
  const rows = lod === 0 ? 4 : 1;
  const { flag_w: w, flag_h: h, radius } = POLE_FLAG;
  const at = (s, t) => v3(
    radius + 0.01 + s * w * (1 - 0.04 * s),
    -t * h - 0.12 * s * s,
    0.1 * Math.sin(Math.PI * s * 1.6) * Math.pow(s, 0.6) + 0.02 * Math.sin(Math.PI * t) * s,
  );
  // Half a texel in from the half's edges, so mipmaps keep the two flags apart.
  const v0 = text ? 1 / 512 : 0.5 + 1 / 512;
  const v1 = text ? 0.5 - 1 / 512 : 1 - 1 / 512;
  const positions = [];
  const normals = [];
  const uvs = [];
  const indices = [];
  for (let j = 0; j <= rows; j += 1) {
    for (let i = 0; i <= columns; i += 1) {
      const s = i / columns;
      const t = j / rows;
      const e = 1e-3;
      const ds = vsub(at(Math.min(1, s + e), t), at(Math.max(0, s - e), t));
      const dt = vsub(at(s, Math.min(1, t + e)), at(s, Math.max(0, t - e)));
      let n = vnorm(vcross(ds, dt));
      if (n[2] < 0) n = vscale(n, -1);
      positions.push(...at(s, t));
      normals.push(...n);
      uvs.push(s, v0 + t * (v1 - v0));
    }
  }
  const index = (i, j) => j * (columns + 1) + i;
  for (let j = 0; j < rows; j += 1) {
    for (let i = 0; i < columns; i += 1) {
      // Counterclockwise seen from +Z (the face the normals take).
      indices.push(index(i, j), index(i, j + 1), index(i + 1, j + 1), index(i, j), index(i + 1, j + 1), index(i + 1, j));
    }
  }
  return { positions, normals, uvs, indices };
}

// ---------------------------------------------------------------- barges and cranes
// A deck barge hull module: the box between the rakes (mid, 1 m long and
// 1 m wide, scaled per instance along X and Z), or a raked end (1 m wide,
// scaled along X). Origin on the waterline; the deck 1 m above it.
const BARGE_FREEBOARD = 1.0;
const BARGE_DRAFT = 2.0;
const BARGE_RAKE = 3.0;
// (One detail level serves both: these are a handful of quads.)
function buildBargeMid() {
  const out = new YardBuilder();
  out.aabb([-0.5, -BARGE_DRAFT, -0.5], [0.5, BARGE_FREEBOARD, 0.5], (face) => (face === "+y" ? P.deck : face === "-y" || face === "+z" || face === "-z" ? null : P.hull));
  return out.result();
}

function buildBargeEnd(dir) {
  const out = new YardBuilder();
  const z1 = dir * BARGE_RAKE;
  // Deck triangle strip out to the rake's top edge, the rake face, the sides.
  out.face([v3(-0.5, BARGE_FREEBOARD, 0), v3(0.5, BARGE_FREEBOARD, 0), v3(0.5, BARGE_FREEBOARD, z1), v3(-0.5, BARGE_FREEBOARD, z1)], Y, P.deck);
  // The rake rises from the bottom (y = -draft) at the hull's end to the waterline at z1.
  const rakeNormal = vnorm(v3(0, -BARGE_RAKE, dir * BARGE_DRAFT));
  out.face([v3(-0.5, -BARGE_DRAFT, 0), v3(0.5, -BARGE_DRAFT, 0), v3(0.5, 0.0, z1), v3(-0.5, 0.0, z1)], rakeNormal, P.hull);
  out.face([v3(-0.5, 0.0, z1), v3(0.5, 0.0, z1), v3(0.5, BARGE_FREEBOARD, z1), v3(-0.5, BARGE_FREEBOARD, z1)], v3(0, 0, dir), P.hull);
  for (const s of [-0.5, 0.5]) {
    out.face([v3(s, -BARGE_DRAFT, 0), v3(s, BARGE_FREEBOARD, 0), v3(s, BARGE_FREEBOARD, z1), v3(s, 0.0, z1)], v3(Math.sign(s), 0, 0), P.hull);
  }
  return out.result();
}

// A crawler crane: tracks, car body, a red revolving house with cab and
// counterweight, a lattice boom raised at boomDeg with pendants, hoist line and
// hook block. Origin on its ground (the deck or the pier).
function buildCrawlerCrane(boomLength, boomDeg, lod) {
  const out = new YardBuilder();
  for (const s of [1, -1]) {
    out.aabb([s * 2.4 - 0.55, 0, -3.6], [s * 2.4 + 0.55, 1.1, 3.6], (face) => (face === "-y" ? null : P.hub), { ao: (face) => (face === "+y" ? 1 : 0.7) });
  }
  out.aabb([-1.9, 0.6, -1.4], [1.9, 1.35, 1.4], P.under, { ao: 0.5 });
  const houseY = 1.45;
  out.aabb([-1.75, houseY, -2.2], [1.75, houseY + 2.3, 3.3], (face) => (face === "-y" ? null : P.crane_red));
  out.aabb([-1.8, houseY + 0.1, 3.3], [1.8, houseY + 2.1, 4.6], (face) => (face === "-y" ? null : P.hull));
  out.aabb([-1.75, houseY + 0.35, -3.3], [-0.75, houseY + 2.2, -2.2], (face) => (face === "-y" ? null : face === "+y" ? P.crane_red : P.trim), {
    holes: { "-z": [{ u0: -1.68, u1: -0.82, v0: houseY + 0.7, v1: houseY + 2.1, part: P.glass }], "-x": [{ u0: -3.2, u1: -2.3, v0: houseY + 0.8, v1: houseY + 2.1, part: P.glass }] },
  });
  // The gantry on the house and the boom.
  const gantryTop = v3(0, houseY + 6.5, 2.4);
  for (const s of [1, -1]) {
    out.beam(v3(s * 1.2, houseY + 2.3, 1.2), gantryTop, 0.16, 0.16, P.crane_red);
    out.beam(v3(s * 1.2, houseY + 2.3, 3.2), gantryTop, 0.16, 0.16, P.crane_red);
  }
  const foot = v3(0, houseY + 1.2, -2.0);
  const angle = (boomDeg * Math.PI) / 180;
  const dir = v3(0, Math.sin(angle), -Math.cos(angle));
  const tip = vadd(foot, vscale(dir, boomLength));
  const side = X;
  const up = vnorm(vcross(side, dir));
  const half = (t) => lerp(0.75, 0.42, t);
  const chord = (sx, sy, t) => vadd(vadd(foot, vscale(dir, boomLength * t)), vadd(vscale(side, sx * half(t)), vscale(up, sy * half(t))));
  const sections = lod === 0 ? Math.round(boomLength / 1.6) : 1;
  const corners = [[1, 1], [-1, 1], [-1, -1], [1, -1]];
  for (const [sx, sy] of corners) {
    for (let k = 0; k < (lod === 0 ? sections : 1); k += 1) {
      out.beam(chord(sx, sy, k / sections), chord(sx, sy, (k + 1) / sections), 0.13, 0.13, P.crane_red, up);
    }
  }
  if (lod === 0) {
    // Lacing: a zigzag on each face of the boom.
    for (let f = 0; f < 4; f += 1) {
      const [ax, ay] = corners[f];
      const [bx, by] = corners[(f + 1) % 4];
      for (let k = 0; k < sections; k += 1) {
        const t0 = k / sections;
        const t1 = (k + 1) / sections;
        const a = k % 2 === 0 ? chord(ax, ay, t0) : chord(bx, by, t0);
        const b = k % 2 === 0 ? chord(bx, by, t1) : chord(ax, ay, t1);
        out.beam(a, b, 0.06, 0.06, P.crane_red, vnorm(vsub(chord(ax, ay, t0), chord(-ax, -ay, t0))));
      }
    }
  }
  // Boom head sheaves, pendants to the gantry, hoist line and hook block.
  out.aabb(vadd(tip, v3(-0.45, -0.5, -0.6)), vadd(tip, v3(0.45, 0.6, 0.6)), P.crane_red);
  for (const s of [1, -1]) out.beam(vadd(gantryTop, v3(s * 0.2, 0, 0)), vadd(tip, v3(s * 0.3, 0.3, 0.2)), 0.05, 0.05, P.metal);
  const hookY = Math.max(houseY + 6, tip[1] * 0.35);
  out.beam(vadd(tip, v3(0, -0.5, -0.3)), v3(0, hookY + 0.9, tip[2] - 0.3), 0.04, 0.04, P.metal);
  out.aabb([-0.35, hookY, tip[2] - 0.55], [0.35, hookY + 0.9, tip[2] - 0.05], P.orange);
  return out.result();
}

// A small white deckhouse with windows.
function buildDeckhouse(lod) {
  const out = new YardBuilder();
  out.aabb([-1.6, 0, -2.0], [1.6, 2.6, 2.0], (face) => (face === "-y" ? null : face === "+y" ? P.vent : P.white_body), {
    holes: Object.fromEntries(["+x", "-x"].map((face) => [face, [{ u0: -1.4, u1: -0.4, v0: 1.4, v1: 2.1, part: P.glass }, { u0: 0.4, u1: 1.4, v0: 1.4, v1: 2.1, part: P.glass }]]).concat([["-z", [{ u0: -1.2, u1: 1.2, v0: 1.45, v1: 2.15, part: P.glass }]], ["+z", [{ u0: -0.45, u1: 0.45, v0: 0.05, v1: 2.0, part: P.trim }]]])),
  });
  if (lod === 0) {
    out.aabb([-1.7, 2.6, -2.1], [1.7, 2.68, 2.1], P.white_body);
    out.cylinder(v3(0.9, 2.68, 1.2), Y, 0.05, 1.6, 6, P.metal);
  }
  return out.result();
}

// A materials stack on a barge deck: crane mats and beams under a tarp.
function buildDeckMaterials(lod) {
  const out = new YardBuilder();
  const mats = buildCraneMats(lod);
  for (const [dx, dz] of [[-2.0, -3.0], [0.0, -2.6], [2.0, -3.2]]) appendMesh(out, mats, v3(dx, 0, dz));
  for (let i = 0; i < 6; i += 1) out.aabb([-3.0 + i * 0.55, 0, 3.0], [-2.6 + i * 0.55, 0.45, 9.5], P.metal);
  out.aabb([1.0, 0, 3.4], [3.8, 1.6, 8.6], (face) => (face === "-y" ? null : P.tarp));
  return out.result();
}

function appendMesh(out, mesh, offset) {
  for (let i = 0; i < mesh.indices.length; i += 3) {
    const corner = (k) => {
      const index = mesh.indices[i + k];
      return {
        p: v3(mesh.positions[index * 3] + offset[0], mesh.positions[index * 3 + 1] + offset[1], mesh.positions[index * 3 + 2] + offset[2]),
        n: v3(mesh.normals[index * 3], mesh.normals[index * 3 + 1], mesh.normals[index * 3 + 2]),
        part: Math.floor(mesh.uvs[index * 2] * YARD_KIT_PART_SLOTS),
        ao: mesh.uvs[index * 2 + 1],
      };
    };
    const [a, b, c] = [corner(0), corner(1), corner(2)];
    out.triangle(a.p, b.p, c.p, [a.n, b.n, c.n], a.part, [a.ao, b.ao, c.ao]);
  }
}

// A soil windrow module (4 m, the ends rounded like the berm's).
const RIDGE_MODULE = 4;
const RIDGE_PROFILE = Object.freeze([[-1.5, 0], [-1.05, 0.42], [-0.6, 0.82], [0, 1.0], [0.6, 0.82], [1.05, 0.42], [1.5, 0]]);
function buildRidge(part, lod) {
  const out = new YardBuilder();
  const steps = lod === 0 ? 6 : 1;
  const half = RIDGE_MODULE / 2;
  const grid = [];
  for (let k = 0; k <= steps; k += 1) {
    const z = -half + (RIDGE_MODULE * k) / steps;
    grid.push(RIDGE_PROFILE.map(([x, y], i) => {
      const w = lod === 0 && i > 0 && i < RIDGE_PROFILE.length - 1 ? 0.05 * Math.sin((2 * Math.PI * z) / RIDGE_MODULE * 2 + hash(i, 5) * 6) : 0;
      return v3(x, y + w, z);
    }));
  }
  if (part === "mid") gridSurface(out, grid, P.earth);
  else {
    const dir = part === "end_pos" ? 1 : -1;
    const fractions = lod === 0 ? [0, 0.35, 0.6, 0.8, 0.93, 1] : [0, 0.6, 1];
    const endGrid = fractions.map((f) => {
      const s = Math.sqrt(Math.max(0, 1 - f * f));
      return RIDGE_PROFILE.map(([x, y]) => v3(x * Math.max(s, 0.001), y * Math.cos((Math.PI / 2) * f), dir * f * half));
    });
    gridSurface(out, endGrid, P.earth);
  }
  return out.result();
}



// ---------------------------------------------------------------- collision hulls
// A heap's collision is a convex hull, and its top is walked on, so no face of
// the hull may be steeper than 45 degrees (the player's floor limit is 48).
// The hull is built over the visible (near) mesh's highest point in each
// 0.25 m plan cell, plus a 45-degree slope from each down to the ground: a
// cone round it ("cone") or, for a module that continues along Z (a berm or
// windrow middle), the two slopes across it ("prism"). Every supporting plane
// of that set is at most 45 degrees, and the hull holds the visible mesh, so
// feet never sink into it; where the mesh is steeper than 45 degrees the hull
// reaches a little past it at its foot.
const HULL_CELL_M = 0.25;
const HULL_SLOPE_RING = 12;
// A heap that peaks in one point gets a small flat top instead: walking
// straight over a single topmost vertex, the stock player stops dead on it.
const HULL_PLATEAU_M = 0.35;
const HULL_PLATEAU_DROP_M = 0.03;

// A convex hull of points: [{v: [i, j, k], n, d}] faces, outward normals.
function convexHull(points) {
  const sub = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
  const cross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
  const dot = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
  const n = points.length;
  let i1 = 0;
  let best = 0;
  for (let i = 1; i < n; i += 1) {
    const d = dot(sub(points[i], points[0]), sub(points[i], points[0]));
    if (d > best) [best, i1] = [d, i];
  }
  let i2 = 0;
  best = 0;
  for (let i = 0; i < n; i += 1) {
    const c = cross(sub(points[i1], points[0]), sub(points[i], points[0]));
    if (dot(c, c) > best) [best, i2] = [dot(c, c), i];
  }
  const normal = cross(sub(points[i1], points[0]), sub(points[i2], points[0]));
  let i3 = 0;
  best = 0;
  for (let i = 0; i < n; i += 1) {
    const d = Math.abs(dot(normal, sub(points[i], points[0])));
    if (d > best) [best, i3] = [d, i];
  }
  const centre = [0, 1, 2].map((k) => (points[0][k] + points[i1][k] + points[i2][k] + points[i3][k]) / 4);
  const face = (a, b, c) => {
    let nn = cross(sub(points[b], points[a]), sub(points[c], points[a]));
    if (dot(nn, sub(centre, points[a])) > 0) {
      [b, c] = [c, b];
      nn = nn.map((value) => -value);
    }
    const length = Math.hypot(...nn);
    return { v: [a, b, c], n: nn.map((value) => value / length), d: dot(nn, points[a]) / length };
  };
  let faces = [face(0, i1, i2), face(0, i1, i3), face(0, i2, i3), face(i1, i2, i3)];
  for (let p = 0; p < n; p += 1) {
    const visible = faces.filter((f) => dot(f.n, points[p]) - f.d > 1e-7);
    if (visible.length === 0) continue;
    const edges = new Map();
    for (const f of visible) {
      for (let k = 0; k < 3; k += 1) {
        const a = f.v[k];
        const b = f.v[(k + 1) % 3];
        if (edges.has(`${b},${a}`)) edges.delete(`${b},${a}`);
        else edges.set(`${a},${b}`, [a, b]);
      }
    }
    faces = faces.filter((f) => !visible.includes(f));
    for (const [a, b] of edges.values()) faces.push(face(a, b, p));
  }
  return faces;
}

// The collision hull of a heap from its near mesh, as a mesh of the hull's
// faces (the runtime takes its points).
function heapHull(mesh, mode) {
  const p = mesh.positions;
  const cells = new Map();
  for (let i = 0; i < p.length; i += 3) {
    const point = [p[i], Math.max(0, p[i + 1]), p[i + 2]];
    const key = `${Math.floor(point[0] / HULL_CELL_M)},${Math.floor(point[2] / HULL_CELL_M)}`;
    const held = cells.get(key);
    if (!held || point[1] > held[1]) cells.set(key, point);
  }
  const tops = [...cells.keys()].sort().map((key) => cells.get(key));
  if (mode === "cone") {
    const peak = Math.max(...tops.map((point) => point[1]));
    const apex = tops.filter((point) => point[1] > peak - 0.02);
    if (apex.length < 3) {
      const level = peak - HULL_PLATEAU_DROP_M;
      const [x, z] = [apex[0][0], apex[0][2]];
      for (const point of tops) point[1] = Math.min(point[1], level);
      for (let k = 0; k < 8; k += 1) {
        const a = (2 * Math.PI * k) / 8;
        tops.push([x + HULL_PLATEAU_M * Math.cos(a), level, z + HULL_PLATEAU_M * Math.sin(a)]);
      }
    }
  }
  const points = [];
  for (const point of tops) {
    points.push(point);
    if (point[1] < 0.02) continue;
    if (mode === "prism") {
      for (const s of [1, -1]) points.push([point[0] + s * point[1], 0, point[2]]);
    } else {
      const r = point[1] / Math.cos(Math.PI / HULL_SLOPE_RING);
      for (let k = 0; k < HULL_SLOPE_RING; k += 1) {
        const a = (2 * Math.PI * k) / HULL_SLOPE_RING;
        points.push([point[0] + r * Math.cos(a), 0, point[2] + r * Math.sin(a)]);
      }
    }
  }
  // (One normal for every corner, so each hull point is stored once: only
  // the points matter to the runtime.)
  const out = new YardBuilder(1);
  for (const f of convexHull(points)) {
    const [a, b, c] = f.v.map((index) => points[index]);
    out.triangle(a, b, c, [Y, Y, Y], P.earth);
  }
  return out.result();
}

// The heaps whose collision is a hull, and how their hull slopes.
function hullMode(name) {
  if (/^pile_/.test(name)) return "cone";
  if (/^(berm_[a-z]+|ridge)_mid$/.test(name)) return "prism";
  if (/^(berm_[a-z]+|ridge)_end_(neg|pos)$/.test(name)) return "cone";
  return null;
}

// ---------------------------------------------------------------- the kit
// Every mesh of the kit by name (<name>_lod0, <name>_lod1), as the runtime
// (game/scripts/world/street_yard_kit.gd) looks them up.
export const YARD_KIT_LOD_COUNT = 2;
function kitEntries() {
  const entries = [];
  const add = (name, build) => entries.push([name, build]);
  for (const [name, size, height, feature] of [
    ["container_10ft", "10ft", "standard", "plain"],
    ["container_20ft", "20ft", "standard", "plain"],
    ["container_40ft", "40ft", "standard", "plain"],
    ["container_40ft_hc", "40ft", "high", "plain"],
    ["container_20ft_rollup", "20ft", "standard", "rollup"],
    ["container_40ft_office", "40ft", "standard", "office"],
  ]) add(name, (lod) => buildContainer(size, height, feature, lod));
  for (const variant of Object.keys(SHED_SPECS)) {
    add(`shed_${variant}_bay`, (lod) => buildShedBay(variant, lod));
    add(`shed_${variant}_end_neg`, (lod) => buildShedEnd(variant, -1, lod));
    add(`shed_${variant}_end_pos`, (lod) => buildShedEnd(variant, 1, lod));
  }
  for (const span of Object.keys(FABRIC_SPECS)) {
    add(`fabric_${span}_bay`, (lod) => buildFabricBay(span, lod));
    add(`fabric_${span}_end_neg`, (lod) => buildFabricEnd(span, -1, lod));
    add(`fabric_${span}_end_pos`, (lod) => buildFabricEnd(span, 1, lod));
  }
  for (const variant of Object.keys(BERM_SPECS)) {
    add(`berm_${variant}_mid`, (lod) => buildBermMid(variant, lod));
    add(`berm_${variant}_end_neg`, (lod) => buildBermEnd(variant, -1, lod));
    add(`berm_${variant}_end_pos`, (lod) => buildBermEnd(variant, 1, lod));
  }
  for (const part of ["mid", "end_neg", "end_pos"]) add(`ridge_${part}`, (lod) => buildRidge(part, lod));
  for (const material of Object.keys(PILE_SPECS)) {
    for (let shape = 0; shape < 3; shape += 1) add(`pile_${material}_${shape}`, (lod) => buildPile(material, shape, lod));
  }
  add("cylinder_section", buildCylinderSection);
  add("open_bin", buildOpenBin);
  add("hopper", buildHopper);
  add("conveyor_module", buildConveyorModule);
  add("conveyor_leg", buildConveyorLeg);
  add("water_barrier", buildWaterBarrier);
  add("pole_flag_pole", buildFlagPole);
  add("pole_flag_cap", buildFlagCap);
  add("pole_flag_text", (lod) => buildFlag(true, lod));
  add("pole_flag_plain", (lod) => buildFlag(false, lod));
  add("crane_mats", buildCraneMats);
  add("excavator", buildExcavator);
  add("wheel_loader", buildWheelLoader);
  for (const variant of ["class_a", "class_c", "travel_trailer", "fifth_wheel"]) add(`rv_${variant}`, (lod) => buildRv(variant, lod));
  for (const variant of ["coach", "shuttle"]) add(`bus_${variant}`, (lod) => buildBus(variant, lod));
  for (const variant of ["medium", "large"]) add(`box_truck_${variant}`, (lod) => buildBoxTruck(variant, lod));
  for (const variant of ["cargo", "step"]) add(`van_${variant}`, (lod) => buildVan(variant, lod));
  for (const variant of ["step_van", "trailer"]) add(`food_truck_${variant}`, (lod) => buildFoodTruck(variant, lod));
  for (const variant of ["cargo", "utility", "semi", "office"]) add(`trailer_${variant}`, (lod) => buildTrailer(variant, lod));
  for (const variant of ["runabout", "cabin"]) {
    add(`boat_${variant}_open`, (lod) => buildBoat(variant, false, lod));
    add(`boat_${variant}_covered`, (lod) => buildBoat(variant, true, lod));
  }
  add("barge_mid", () => buildBargeMid());
  add("barge_end_neg", () => buildBargeEnd(-1));
  add("barge_end_pos", () => buildBargeEnd(1));
  add("crawler_crane_barge", (lod) => buildCrawlerCrane(45, 62, lod));
  // The boom lowered nearly level, out over the barge's -Z end.
  add("crawler_crane_barge_lowered", (lod) => buildCrawlerCrane(45, 10, lod));
  add("crawler_crane_pier", (lod) => buildCrawlerCrane(58, 74, lod));
  add("deckhouse", buildDeckhouse);
  add("deck_materials", buildDeckMaterials);
  add("deck_equipment", buildDeckEquipment);
  return entries;
}

export function yardKitMeshes() {
  const meshes = [];
  for (const [name, build] of kitEntries()) {
    for (let lod = 0; lod < YARD_KIT_LOD_COUNT; lod += 1) meshes.push({ name: `${name}_lod${lod}`, ...build(lod) });
    // A heap's collision hull (<name>_hull), from its near mesh.
    const mode = hullMode(name);
    if (mode) meshes.push({ name: `${name}_hull`, ...heapHull(meshes.find((mesh) => mesh.name === `${name}_lod0`), mode) });
  }
  return meshes;
}

export {
  YardBuilder, sweptBody, rectHole, roundedProfile, wheel, axle, polygonFace, recessed, hash, P as YARD_PART,
  buildContainer, buildShedBay, buildShedEnd, buildFabricBay, buildFabricEnd, buildBermMid, buildBermEnd, buildPile, buildCylinderSection, buildCraneMats,
  buildBoxTruck, buildBus, buildRv, buildVan, buildFoodTruck, buildTrailer, buildBoat, buildExcavator, buildWheelLoader,
  buildBargeMid, buildBargeEnd, buildCrawlerCrane, buildDeckhouse, buildDeckMaterials, buildRidge,
  SHED_BAY, SHED_END, FABRIC_BAY, FABRIC_END, BERM_MODULE, RIDGE_MODULE, BARGE_RAKE, BARGE_FREEBOARD,
};
