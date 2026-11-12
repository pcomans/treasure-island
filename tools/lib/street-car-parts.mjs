// Parts of the street cars that are not the body shell (tools/lib/street-car-kit.mjs):
// the mesh builder's smooth primitives, the wheels and brakes, the cabin and
// the underbody. Everything is generic, typical 2020s cars, no make.

import { KIT_BASE_PARTS, MeshBuilder, clamp, lerp, v3, vadd, vcross, vdot, vlen, vnorm, vscale, vsub } from "./kit-mesh.mjs";

// The car kit's parts: the sixteen shared ones, then the cars' own. UV.x =
// (part + 0.5) / CAR_PART_COUNT in the car and clutter kits' meshes.
export const CAR_PARTS = Object.freeze([
  ...KIT_BASE_PARTS,
  "gap", // panel gaps and shut lines
  "cabin", // dashboard, door cards, carpet: charcoal plastic
  "seat", // seat upholstery
  "headliner", // roof lining and pillar trims
  "gloss_black", // piano-black pillar covers, grille surrounds, mirror feet
  "lamp_housing", // the reflector bowl behind a clear lens
  "lamp_drl", // daytime running light: white, lit
  "lamp_red", // tail light bar: red, lit
  "lamp_amber", // amber reflector or turn lamp
  "brake_disc",
  "caliper",
  "exhaust", // exhaust, suspension and subframe steel
  "screen", // instrument and centre displays
  "rubber", // wiper blades, seals, mud flaps
  "mirror", // mirror glass
  "lamp_white", // reversing lamp, licence lamp
]);
export const CAR_PART_COUNT = CAR_PARTS.length;
export const P = Object.freeze(Object.fromEntries(CAR_PARTS.map((name, index) => [name, index])));
// What a shared-part consumer (the yard kit's cargo van) draws a car part as.
export const CAR_PART_AS_BASE = Object.freeze(CAR_PARTS.map((name, index) => {
  if (index < KIT_BASE_PARTS.length) return index;
  return P[{ lamp_housing: "head_lamp", lamp_drl: "head_lamp", lamp_red: "tail_lamp", lamp_amber: "orange", brake_disc: "metal", caliper: "metal", exhaust: "metal", screen: "glass", mirror: "chrome", lamp_white: "white" }[name] ?? "trim"];
}));

const X = v3(1, 0, 0);
const Y = v3(0, 1, 0);
const Z = v3(0, 0, 1);

export class CarMesh extends MeshBuilder {
  constructor() {
    super(CAR_PART_COUNT);
  }

  // A triangle with no area, or with an edge shorter than the welding's grain
  // (MeshBuilder.result()), draws nothing: it is left out.
  triangle(a, b, c, normals, part, ao) {
    const n = vcross(vsub(b, a), vsub(c, a));
    if (vlen(n) < 2e-9 || Math.min(vlen(vsub(b, a)), vlen(vsub(c, b)), vlen(vsub(a, c))) < 3e-5) return;
    super.triangle(a, b, c, normals, part, ao);
  }

  // One triangle with its three normals, wound to face them.
  face(a, b, c, na, nb, nc, part, aoA = 1, aoB = aoA, aoC = aoA) {
    const n = vcross(vsub(b, a), vsub(c, a));
    if (vlen(n) < 1e-10) return;
    if (vdot(n, vadd(na, vadd(nb, nc))) >= 0) this.triangle(a, b, c, [na, nb, nc], part, [aoA, aoB, aoC]);
    else this.triangle(a, c, b, [na, nc, nb], part, [aoA, aoC, aoB]);
  }

  // A smooth grid of points pts[i][j] with normals nrm[i][j]; each quad faces its normals.
  grid(pts, nrm, part, ao = 1) {
    const aoOf = typeof ao === "function" ? ao : () => ao;
    for (let i = 0; i < pts.length - 1; i += 1) {
      for (let j = 0; j < pts[i].length - 1; j += 1) {
        const partOf = typeof part === "function" ? part(i, j) : part;
        if (partOf === null || partOf === undefined) continue;
        const a = [i, j];
        const b = [i + 1, j];
        const c = [i + 1, j + 1];
        const d = [i, j + 1];
        const at = (q) => pts[q[0]][q[1]];
        const no = (q) => nrm[q[0]][q[1]];
        this.face(at(a), at(b), at(c), no(a), no(b), no(c), partOf, aoOf(...a), aoOf(...b), aoOf(...c));
        this.face(at(a), at(c), at(d), no(a), no(c), no(d), partOf, aoOf(...a), aoOf(...c), aoOf(...d));
      }
    }
  }

  // A surface of revolution about unit `axis` through `center`: profile is
  // [[radius, along], ...] and the surface faces the right of its travel
  // (radius outward for a profile running along +axis). Normals are smooth
  // across profile points that turn less than `crease` degrees. partOf(i) names
  // segment i's part (null leaves it out); vOf(i) is profile point i's UV.y.
  revolve(center, axis, profile, sides, partOf, { phase = 0, crease = 40, vOf = () => 1, from = 0, to = sides } = {}) {
    const helper = Math.abs(axis[1]) < 0.9 ? Y : X;
    const u = vnorm(vcross(axis, helper));
    const w = vcross(axis, u);
    const seg = [];
    for (let i = 0; i < profile.length - 1; i += 1) {
      const dr = profile[i + 1][0] - profile[i][0];
      const da = profile[i + 1][1] - profile[i][1];
      const l = Math.hypot(dr, da) || 1;
      seg.push([da / l, -dr / l]);
    }
    const cosCrease = Math.cos((crease * Math.PI) / 180);
    const pointNormal = (i, s) => {
      const own = seg[s];
      const other = i === s ? seg[s - 1] : seg[s + 1];
      if (!other || own[0] * other[0] + own[1] * other[1] < cosCrease) return own;
      const sum = [own[0] + other[0], own[1] + other[1]];
      const l = Math.hypot(sum[0], sum[1]) || 1;
      return [sum[0] / l, sum[1] / l];
    };
    const dir = (t) => vadd(vscale(u, Math.cos(t)), vscale(w, Math.sin(t)));
    for (let i = 0; i < profile.length - 1; i += 1) {
      const part = typeof partOf === "function" ? partOf(i) : partOf;
      if (part === null || part === undefined) continue;
      const n0 = pointNormal(i, i);
      const n1 = pointNormal(i + 1, i);
      for (let s = from; s < to; s += 1) {
        const t0 = phase + (2 * Math.PI * s) / sides;
        const t1 = phase + (2 * Math.PI * (s + 1)) / sides;
        const d0 = dir(t0);
        const d1 = dir(t1);
        const pt = (p, d) => vadd(center, vadd(vscale(axis, p[1]), vscale(d, p[0])));
        const no = (n, d) => vnorm(vadd(vscale(axis, n[1]), vscale(d, n[0])));
        const a = pt(profile[i], d0);
        const b = pt(profile[i], d1);
        const c = pt(profile[i + 1], d1);
        const e = pt(profile[i + 1], d0);
        const na = no(n0, d0);
        const nb = no(n0, d1);
        const nc = no(n1, d1);
        const ne = no(n1, d0);
        this.face(a, b, c, na, nb, nc, part, vOf(i), vOf(i), vOf(i + 1));
        this.face(a, c, e, na, nc, ne, part, vOf(i), vOf(i + 1), vOf(i + 1));
      }
    }
  }

  // A box with rounded edges and corners: half sizes along the unit axes, edge
  // radius, smooth normals. n = 3 gives one facet per rounded edge and face.
  roundedBox(center, half, radius, part, { axes = [X, Y, Z], ao = 1, taper = null } = {}) {
    const r = Math.min(radius, half[0], half[1], half[2]);
    const cuts = (h) => (h - r > 1e-6 ? [-h, -(h - r), h - r, h] : [-h, 0, h]);
    const place = (p) => {
      const inner = p.map((value, k) => clamp(value, -(half[k] - r), half[k] - r));
      const d = vnorm(vsub(p, inner));
      let local = vadd(inner, vscale(d, r));
      // taper: [axis, along, factor]: the cross-section shrinks toward +along.
      if (taper) {
        const [k, along, factor] = taper;
        const t = (local[along] / half[along] + 1) / 2;
        local = [...local];
        local[k] *= lerp(1, factor, t);
      }
      const world = vadd(center, vadd(vscale(axes[0], local[0]), vadd(vscale(axes[1], local[1]), vscale(axes[2], local[2]))));
      const normal = vnorm(vadd(vscale(axes[0], d[0]), vadd(vscale(axes[1], d[1]), vscale(axes[2], d[2]))));
      return [world, normal];
    };
    for (let k = 0; k < 3; k += 1) {
      const i = (k + 1) % 3;
      const j = (k + 2) % 3;
      for (const sign of [-1, 1]) {
        const us = cuts(half[i]);
        const vs = cuts(half[j]);
        const pts = [];
        const nrm = [];
        for (const uu of us) {
          const rowP = [];
          const rowN = [];
          for (const vv of vs) {
            const p = [0, 0, 0];
            p[k] = sign * half[k];
            p[i] = uu;
            p[j] = vv;
            const [world, normal] = place(p);
            rowP.push(world);
            rowN.push(normal);
          }
          pts.push(rowP);
          nrm.push(rowN);
        }
        this.grid(pts, nrm, typeof part === "function" ? () => part(k, sign) : part, ao);
      }
    }
  }

  // A round tube along a path of points (closed: the path is a loop), with flat
  // end caps on an open one. radius may be a function of the point's index.
  tube(path, radius, sides, part, { closed = false, caps = true, ao = 1 } = {}) {
    const count = path.length;
    const radiusAt = typeof radius === "function" ? radius : () => radius;
    const tangentAt = (i) => {
      const prev = path[closed ? (i - 1 + count) % count : Math.max(0, i - 1)];
      const next = path[closed ? (i + 1) % count : Math.min(count - 1, i + 1)];
      return vnorm(vsub(next, prev));
    };
    let t0 = tangentAt(0);
    let side = vnorm(vcross(t0, Math.abs(t0[1]) < 0.9 ? Y : X));
    const rings = [];
    const normals = [];
    for (let i = 0; i < count; i += 1) {
      const t = tangentAt(i);
      // Parallel transport of the frame.
      side = vnorm(vsub(side, vscale(t, vdot(side, t))));
      const up = vcross(t, side);
      const ringP = [];
      const ringN = [];
      for (let s = 0; s <= sides; s += 1) {
        const a = (2 * Math.PI * s) / sides;
        const n = vadd(vscale(side, Math.cos(a)), vscale(up, Math.sin(a)));
        ringP.push(vadd(path[i], vscale(n, radiusAt(i))));
        ringN.push(n);
      }
      rings.push(ringP);
      normals.push(ringN);
      t0 = t;
    }
    if (closed) {
      rings.push(rings[0]);
      normals.push(normals[0]);
    }
    this.grid(rings, normals, part, ao);
    if (!closed && caps) {
      for (const [i, sign] of [[0, -1], [count - 1, 1]]) {
        const n = vscale(tangentAt(i), sign);
        for (let s = 0; s < sides; s += 1) this.face(path[i], rings[i][s], rings[i][s + 1], n, n, n, part, ao);
      }
    }
  }

  // A flat quad a-b-c-d facing normal.
  flat(a, b, c, d, normal, part, ao = 1) {
    this.face(a, b, c, normal, normal, normal, part, ao);
    this.face(a, c, d, normal, normal, normal, part, ao);
  }

  // A flat polygon fan round `center`, facing normal.
  fan(center, ring, normal, part, ao = 1) {
    for (let s = 0; s < ring.length; s += 1) this.face(center, ring[s], ring[(s + 1) % ring.length], normal, normal, normal, part, ao);
  }

  // Appends another mesh's triangles, each point and normal through `xf`
  // ({point, normal}), a mirror flipping the winding.
  append(other, xf = null, mirror = false) {
    const base = this.positions.length / 3;
    for (let i = 0; i < other.positions.length; i += 3) {
      const p = [other.positions[i], other.positions[i + 1], other.positions[i + 2]];
      const n = [other.normals[i], other.normals[i + 1], other.normals[i + 2]];
      const q = xf ? xf.point(p) : p;
      const m = xf ? xf.normal(n) : n;
      this.positions.push(q[0], q[1], q[2]);
      this.normals.push(m[0], m[1], m[2]);
    }
    for (const uv of other.uvs) this.uvs.push(uv);
    for (let i = 0; i < other.indices.length; i += 3) {
      if (mirror) this.indices.push(base + other.indices[i], base + other.indices[i + 2], base + other.indices[i + 1]);
      else this.indices.push(base + other.indices[i], base + other.indices[i + 1], base + other.indices[i + 2]);
    }
  }
}

// ---------------------------------------------------------------- wheels
// Wheel detail by level: sides round the tyre, tyre section points, spoke
// segments along a spoke, lug nuts and a hollow barrel (the brake shows through).
export const WHEEL_LEVELS = Object.freeze({
  hero: { sides: 36, section: 13, spokeSeg: 5, spokeSection: 6, lugs: true, barrel: true },
  // (Sixteen sides: the desktop draws it from 13 m out, the hero level nearer;
  // what it saves pays for the near level's refined D pillars on the web.)
  near: { sides: 16, section: 7, spokeSeg: 2, spokeSection: 4, lugs: false, barrel: false },
  mid: { sides: 16, section: 7, spokeSeg: 1, spokeSection: 2, lugs: false, barrel: false },
  // (Ten sides: a far wheel is 13 to 17 pixels across, and its spokes cost the difference.)
  far: { sides: 10, section: 0, spokeSeg: 0, spokeSection: 0, lugs: false, barrel: false },
  // The shadow caster's: the far level's tyre with a plain disc (spokes cast nothing seen).
  shadow: { sides: 12, section: 0, spokeSeg: 0, spokeSection: 0, lugs: false, barrel: false, plain: true },
});

export const rimRadius = (body) => body.wheel_radius * 0.66;

// One right-hand wheel round the origin, its face toward +X, axle along X: a
// tyre with rounded shoulders, a rim with a lip, sculpted spokes sunk toward
// the hub and a hub with its cap (and lug nuts). The lowest and highest points
// are exactly a radius from the axle and the sidewalls exactly half a tyre
// width from the middle, as the drivable car reads them from the mesh's box.
// A tyre vertex's UV.y is its place across the section (0 inner bead, 0.5 the
// middle of the tread, 1 outer bead), for the shader's tread and sidewall.
export function buildWheel(body, levelName) {
  const level = WHEEL_LEVELS[levelName];
  const out = new CarMesh();
  const R = body.wheel_radius;
  const tw = body.tire_width;
  const rimR = rimRadius(body);
  const o = v3(0, 0, 0);
  const sides = level.sides;
  if (level.section === 0) {
    // Far: tread, outer sidewall, the rim's lip, five flat spokes over a dark
    // dish and a dark back. A plain pale rim disc read as a white button with
    // a black dot beside the near level's spoked wheel at the hand-over.
    const face = tw / 2;
    const lipR = rimR * 0.86;
    out.revolve(o, X, [[R, -tw / 2], [R, tw / 2 - 0.04], [R - 0.05, tw / 2], [rimR, tw / 2]], sides, () => P.tire);
    if (level.plain) {
      out.revolve(o, X, [[rimR, face], [0, face - 0.03]], sides, () => P.hub);
      out.revolve(o, X, [[0, -tw / 2], [R, -tw / 2]], sides, () => P.hub);
      return out;
    }
    out.revolve(o, X, [[rimR, face], [lipR, face - 0.008]], sides, () => P.rim);
    out.revolve(o, X, [[lipR, face - 0.008], [0, face - 0.03]], sides, () => P.hub);
    const radial = (angle) => v3(0, -Math.sin(angle), Math.cos(angle));
    const tangent = (angle) => v3(0, -Math.cos(angle), -Math.sin(angle));
    for (let k = 0; k < 5; k += 1) {
      const angle = (2 * Math.PI * k) / 5 + Math.PI / 2;
      const at = (r, w) => vadd(vadd(vscale(radial(angle), r), vscale(tangent(angle), w)), vscale(X, face - 0.006));
      out.flat(at(0.05, -0.024), at(0.05, 0.024), at(lipR + 0.004, 0.018), at(lipR + 0.004, -0.018), X, P.rim);
    }
    out.revolve(o, X, [[0.06, face - 0.005], [0, face - 0.003]], 6, () => P.rim);
    out.revolve(o, X, [[0, -tw / 2], [R, -tw / 2]], sides, () => P.hub);
    return out;
  }
  // Tyre: a rounded section from the inner bead over the tread to the outer bead.
  const rc = (R + rimR) / 2;
  const hr = (R - rimR) / 2;
  // The section's samples include its widest points (a quarter turn each way).
  const reach = 0.75 * Math.PI;
  const power = 2 / 3.4;
  const section = [];
  const vs = [];
  for (let i = 0; i < level.section; i += 1) {
    const t = i / (level.section - 1);
    const phi = lerp(-reach, reach, t);
    const c = Math.cos(phi);
    const s = Math.sin(phi);
    section.push([rc + hr * Math.sign(c) * Math.abs(c) ** power, (tw / 2) * Math.sign(s) * Math.abs(s) ** power]);
    vs.push(t);
  }
  out.revolve(o, X, section, sides, () => P.tire, { crease: 70, vOf: (i) => vs[i] });
  // Rim: the lip round the outer bead, then (hollow) the barrel back to the inner bead.
  const beadR = section.at(-1)[0];
  const face = tw / 2 - 0.006;
  const lip = [[beadR + 0.002, section.at(-1)[1]], [beadR + 0.004, face], [beadR - 0.012, face], [beadR - 0.02, face - 0.014]];
  out.revolve(o, X, lip, sides, () => P.rim, { crease: 80 });
  const barrelR = beadR - 0.02;
  const backA = level.barrel ? -tw / 2 + 0.03 : face - 0.05;
  if (level.barrel) {
    out.revolve(o, X, [[barrelR, face - 0.014], [barrelR - 0.004, backA]], sides, () => P.hub, { vOf: (i) => (i === 0 ? 0.75 : 0.35) });
    // The back of the wheel, seen under the car: the inner bead's ring and a closed drum.
    out.revolve(o, X, [[0, -tw / 2 + 0.02], [section[0][0] + 0.002, -tw / 2 + 0.02]], sides, () => P.hub, { vOf: () => 0.5 });
    out.revolve(o, X, [[barrelR - 0.004, backA], [0.05, backA]], sides, () => P.hub, { vOf: () => 0.3 });
  } else {
    // A dark dish behind the spokes and a dark back.
    out.revolve(o, X, [[barrelR, face - 0.014], [barrelR - 0.01, backA], [0, backA]], sides, () => P.hub, { vOf: (i) => (i === 0 ? 0.7 : 0.4) });
    out.revolve(o, X, [[0, -tw / 2 + 0.01], [section[0][0] + 0.002, -tw / 2 + 0.01]], sides, () => P.hub, { vOf: () => 0.5 });
  }
  // Spokes: five pairs, each a bar from the hub out to the rim, deepest at the hub.
  const hubR = 0.062;
  const hubA = face - Math.min(0.05, tw * 0.2);
  const spokeDepth = (t) => lerp(hubA, face - 0.012, t ** 1.6);
  const outerR = barrelR + 0.002;
  const pairs = 5;
  const split = (7.5 * Math.PI) / 180;
  const radial = (angle) => v3(0, -Math.sin(angle), Math.cos(angle));
  const tangent = (angle) => v3(0, -Math.cos(angle), -Math.sin(angle));
  for (let k = 0; k < pairs; k += 1) {
    for (const half of [-1, 1]) {
      const angle0 = (2 * Math.PI * k) / pairs + Math.PI / 2;
      const pts = [];
      const nrm = [];
      for (let i = 0; i <= level.spokeSeg; i += 1) {
        const t = i / level.spokeSeg;
        const r = lerp(hubR * 0.8, outerR, t);
        // The pair splits toward the rim.
        const angle = angle0 + half * split * (0.25 + 1.2 * t);
        const width = lerp(0.03, 0.019, t);
        const thick = lerp(0.034, 0.02, t);
        const a = spokeDepth(t);
        const centre = vadd(vscale(radial(angle), r), vscale(X, a));
        const tg = tangent(angle);
        // Section: back edge, side, crowned top, side, back edge.
        const sectionPts = level.spokeSection >= 6
          ? [[-1, -thick], [-1, -0.004], [-0.55, 0], [0.55, 0], [1, -0.004], [1, -thick]]
          : level.spokeSection >= 4 ? [[-1, -thick], [-0.8, 0], [0.8, 0], [1, -thick]] : [[-1, 0], [1, 0]];
        const sectionNrm = level.spokeSection >= 6
          ? [[-1, 0], [-0.8, 0.6], [-0.15, 1], [0.15, 1], [0.8, 0.6], [1, 0]]
          : level.spokeSection >= 4 ? [[-1, 0.25], [-0.3, 1], [0.3, 1], [1, 0.25]] : [[0, 1], [0, 1]];
        pts.push(sectionPts.map(([s, d]) => vadd(centre, vadd(vscale(tg, s * width), vscale(X, d)))));
        nrm.push(sectionNrm.map(([s, d]) => vnorm(vadd(vscale(tg, s), vscale(X, d)))));
      }
      out.grid(pts, nrm, P.rim);
    }
  }
  // Hub: a dished plate with a cap; lug nuts round it.
  const hubFace = hubA + 0.012;
  out.revolve(o, X, [[hubR + 0.012, hubA - 0.02], [hubR + 0.008, hubFace - 0.006], [hubR, hubFace], [0.034, hubFace], [0.03, hubFace + 0.008], [0, hubFace + 0.01]], Math.max(10, sides / 2), (i) => (i >= 3 && level.lugs ? P.chrome : P.rim), { crease: 50 });
  if (level.lugs) {
    for (let k = 0; k < 5; k += 1) {
      const angle = (2 * Math.PI * (k + 0.5)) / 5 + Math.PI / 2;
      const c = vadd(vscale(radial(angle), 0.048), vscale(X, hubFace - 0.002));
      out.revolve(c, X, [[0.0105, 0], [0.0105, 0.011], [0.006, 0.014], [0, 0.014]], 6, () => P.chrome, { crease: 30 });
    }
  }
  return out;
}

// One right-hand brake round the origin (the wheel's centre), facing +X: a
// vented disc on its hat and a caliper over it toward the rear (+Z) and up.
// CALIPER_ANGLE is the caliper's place from +Z toward +Y, for whoever turns
// the left-hand brakes.
export const CALIPER_ANGLE = (32 * Math.PI) / 180;
export function buildBrake(body) {
  const out = new CarMesh();
  const tw = body.tire_width;
  const rimR = rimRadius(body);
  const o = v3(0, 0, 0);
  const discR = rimR - 0.035;
  const a1 = tw / 2 - 0.075;
  const a0 = a1 - 0.026;
  // The disc and its hat, their profiles run so their faces turn outward (the
  // other way round, the disc was drawn inside out and its far face showed
  // through its near one).
  out.revolve(o, X, [[0.07, a0], [discR, a0], [discR, a1], [0.085, a1], [0.085, a1 + 0.02]], 28, (i) => P.brake_disc, { crease: 30, vOf: (i) => (i <= 1 ? 0.5 : 1) });
  out.revolve(o, X, [[0.085, a1 + 0.02], [0, a1 + 0.024]], 28, () => P.exhaust);
  // Caliper: a block bent round the disc's edge.
  const span = (56 * Math.PI) / 180;
  const steps = 6;
  const rows = [];
  const normals = [];
  for (let i = 0; i <= steps; i += 1) {
    const angle = CALIPER_ANGLE + span * (i / steps - 0.5);
    const rad = v3(0, Math.sin(angle), Math.cos(angle));
    const rIn = discR - 0.062;
    const rOut = discR + 0.012;
    const ring = [[rIn, a0 - 0.012, -1, -0.4], [rIn, a1 + 0.022, -0.6, 0.8], [lerp(rIn, rOut, 0.5), a1 + 0.03, 0, 1], [rOut, a1 + 0.022, 0.7, 0.7], [rOut, a0 - 0.012, 1, -0.3]];
    rows.push(ring.map(([r, a]) => vadd(vscale(rad, r), vscale(X, a))));
    normals.push(ring.map(([, , nr, na]) => vnorm(vadd(vscale(rad, nr), vscale(X, na)))));
  }
  out.grid(rows, normals, P.caliper);
  for (const [i, sign] of [[0, -1], [steps, 1]]) {
    const angle = CALIPER_ANGLE + span * (i / steps - 0.5);
    const n = vscale(v3(0, Math.cos(angle), -Math.sin(angle)), sign);
    out.fan(vscale(vadd(rows[i][0], rows[i][3]), 0.5), rows[i], n, P.caliper);
  }
  return out;
}

// ---------------------------------------------------------------- cabin
// The top of a front seat's cushion over the cabin floor, and the driver's
// eyes over it (game/scripts/vehicles/car_driver.gd), in metres.
const CUSHION_TOP_M = 0.335;
const DRIVER_EYES_M = 0.52;
// The cabin seen through the glass: floor, dashboard with its screens, steering
// wheel, console, seats with headrests and a rear shelf or load cover. `shape`
// is the body's shape (street-car-kit.mjs bodyShape); zf runs from the front
// bumper, x to the car's right, and the driver sits on the left.
export function buildCabin(out, body, shape, { detail = 1 } = {}) {
  const { L, W } = shape;
  const cab = body.cabin;
  const zOf = (zf) => zf - L / 2;
  const at = (x, y, zf) => v3(x, y, zOf(zf));
  const belt = shape.top(cab.windshield_base + 0.6);
  const cowl = shape.top(cab.windshield_base);
  // High enough that the seat's cushion is at most 0.4 m under the belt and
  // 0.32 m under the cowl, so the driver (car_driver.gd: eyes 0.52 m over the
  // cushion) shows over the door and the windshield's foot (a pickup's, a
  // utility's or a van's high cab).
  // A high-roof van's driver sits higher still, eyes about two fifths up its
  // tall windshield, as a van's cab is built (and so he shows through it).
  const vanFloor = cab.glass_top ? cowl + 0.4 * (cab.glass_top - cowl) - DRIVER_EYES_M - CUSHION_TOP_M : -Infinity;
  const floor = Math.max(body.clearance + 0.14, belt - 0.735, cowl - 0.655, vanFloor);
  const inner = W - 0.14;
  const rows = body.pillars.cargo_from ? 1 : 2;
  const cabinEnd = body.pillars.cargo_from ? body.pillars.cargo_from : cab.rear_base - 0.12;
  const dashZ = cab.windshield_base + 0.22;
  // Floor and the bulkhead behind the seats (a van's partition, a pickup's cab back).
  const up = Y;
  // The floor, narrower over each wheel well, whose wall it stays inside of.
  {
    const wellX = W - 0.035 - body.tire_width - 0.06;
    const zs = [dashZ, cabinEnd];
    for (const axle of shape.axles) for (const edge of [axle - shape.archRadius, axle + shape.archRadius]) if (edge > dashZ && edge < cabinEnd) zs.push(edge);
    zs.sort((p, q) => p - q);
    for (let i = 0; i < zs.length - 1; i += 1) {
      const mid = (zs[i] + zs[i + 1]) / 2;
      const half = shape.axles.some((axle) => Math.abs(mid - axle) < shape.archRadius) ? Math.min(inner, wellX) : inner;
      out.flat(at(-half, floor, zs[i]), at(-half, floor, zs[i + 1]), at(half, floor, zs[i + 1]), at(half, floor, zs[i]), up, P.cabin, 0.5);
    }
  }
  if (body.pillars.cargo_from || body.bed) {
    // Up to just under the roof all the way across, so nothing past it shows
    // over its top and no corner of it pokes out through a cab's roof rail.
    const n = v3(0, 0, -1);
    const xs = [-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1].map((t) => t * (inner - 0.06));
    const topAt = (x) => shape.lid(Math.abs(x), cabinEnd).y - 0.03;
    for (let i = 0; i < xs.length - 1; i += 1) {
      out.flat(at(xs[i], floor, cabinEnd), at(xs[i], topAt(xs[i]), cabinEnd), at(xs[i + 1], topAt(xs[i + 1]), cabinEnd), at(xs[i + 1], floor, cabinEnd), n, P.cabin, 0.5);
    }
  }
  // Dashboard: a section swept across the car, its top under the windshield.
  const dashTop = Math.min(cowl - 0.02, belt - 0.02);
  const dash = [[dashZ - 0.2, dashTop - 0.03], [dashZ + 0.12, dashTop], [dashZ + 0.3, dashTop - 0.035], [dashZ + 0.36, dashTop - 0.14], [dashZ + 0.3, dashTop - 0.33], [dashZ + 0.16, floor + 0.05]];
  const dashN = [[-0.2, 1], [0, 1], [0.5, 0.86], [1, 0.1], [0.9, -0.4], [0.7, -0.7]];
  const cols = detail ? [-inner, -inner * 0.5, 0, inner * 0.5, inner] : [-inner, inner];
  out.grid(cols.map((x) => dash.map(([zf, y]) => at(x, y, zf))), cols.map(() => dashN.map(([nz, ny]) => vnorm(v3(0, ny, nz)))), P.cabin, (i, j) => (j >= 4 ? 0.5 : 0.85));
  // Instrument hood and displays: the driver's cluster and the centre screen.
  const driver = -W * 0.4;
  out.roundedBox(at(driver, dashTop + 0.025, dashZ + 0.2), [0.19, 0.05, 0.1], 0.04, P.cabin, { ao: 0.8 });
  out.box(at(driver, dashTop + 0.02, dashZ + 0.305), [0.13, 0.04, 0.004], P.screen);
  out.roundedBox(at(0, dashTop + 0.055, dashZ + 0.32), [0.16, 0.085, 0.012], 0.01, (k, sign) => (k === 2 && sign > 0 ? P.screen : P.gloss_black));
  // The front seats: by the B pillar, but clear of the dashboard (a van's or a
  // pickup's short cab put them into it).
  const seatZ = Math.max(body.pillars.b ? body.pillars.b - 0.42 : cab.windshield_top + 0.35, dashZ + 0.36 + 0.42);
  // Steering wheel: rim, hub and spokes on a raked column, no further back than a driver's reach.
  const rake = (24 * Math.PI) / 180;
  const wheelC = at(driver, dashTop - 0.05, Math.min(dashZ + 0.5, seatZ - 0.25));
  const axis = vnorm(v3(0, Math.sin(rake), Math.cos(rake)));
  const side = X;
  const upW = vcross(axis, side);
  const ringR = 0.185;
  const ring = [];
  const ringSides = detail ? 20 : 10;
  for (let i = 0; i < ringSides; i += 1) {
    const a = (2 * Math.PI * i) / ringSides;
    ring.push(vadd(wheelC, vadd(vscale(side, ringR * Math.cos(a)), vscale(upW, ringR * Math.sin(a)))));
  }
  out.tube(ring, 0.015, detail ? 7 : 4, P.cabin, { closed: true, ao: 0.9 });
  // Where a driver's hands hold it: ten to two.
  const grip = (side) => vadd(wheelC, vadd(vscale(X, side * ringR * Math.cos(Math.PI / 6)), vscale(upW, ringR * Math.sin(Math.PI / 6))));
  const hubC = vadd(wheelC, vscale(axis, -0.045));
  out.roundedBox(hubC, [0.075, 0.05, 0.03], 0.025, P.cabin, { axes: [side, upW, axis] });
  for (const a of [0, Math.PI, -Math.PI / 2]) {
    const tip = vadd(wheelC, vadd(vscale(side, ringR * Math.cos(a)), vscale(upW, ringR * Math.sin(a))));
    out.tube([hubC, tip], 0.012, 5, P.cabin, { caps: false });
  }
  out.tube([hubC, vadd(hubC, vscale(axis, -0.32))], 0.03, 6, P.cabin, { caps: false, ao: 0.6 });
  // Centre console with its armrest, between the front seats.
  out.roundedBox(at(0, floor + 0.2, (dashZ + 0.3 + seatZ + 0.3) / 2), [0.11, 0.2, (seatZ + 0.3 - dashZ - 0.3) / 2], 0.03, P.cabin, { ao: 0.75 });
  out.roundedBox(at(0, floor + 0.44, seatZ + 0.12), [0.1, 0.035, 0.17], 0.03, P.seat);
  // Seats.
  const recline = (16 * Math.PI) / 180;
  const seatAxes = [X, vnorm(v3(0, Math.cos(recline), Math.sin(recline))), vnorm(v3(0, -Math.sin(recline), Math.cos(recline)))];
  const fullBackH = Math.min(0.31, (body.cabin.roof - 0.3 - (floor + 0.27)) / 2);
  // A seat's back centre and its headrests' centres (x offsets), for a back height.
  const seatParts = (x, zf, width, bench, backH) => {
    const backC = vadd(at(x, floor + 0.27 + 0.03, zf + 0.25), vscale(seatAxes[1], backH + 0.02));
    const heads = (bench ? [-width * 0.3, width * 0.3] : [0]).map((dx) => vadd(vadd(backC, v3(dx, 0, 0)), vscale(seatAxes[1], backH + 0.115)));
    return { backC, heads };
  };
  const seat = (x, zf, width, bench, { backH = fullBackH, headrests = true } = {}) => {
    const hip = floor + 0.27;
    out.roundedBox(at(x, hip, zf - 0.02), [width / 2, 0.065, 0.25], 0.05, P.seat, { axes: [X, vnorm(v3(0, 1, -0.1)), vnorm(v3(0, 0.1, 1))], ao: 0.85 });
    const { backC, heads: headCs } = seatParts(x, zf, width, bench, backH);
    out.roundedBox(backC, [width / 2 - 0.01, backH, 0.06], 0.05, P.seat, { axes: seatAxes, taper: bench ? null : [0, 1, 0.82] });
    for (const headC of headrests ? headCs : []) {
      out.roundedBox(headC, [0.125, 0.085, 0.05], 0.045, P.seat, { axes: seatAxes });
      if (detail) {
        for (const post of [-0.05, 0.05]) out.tube([vadd(headC, vadd(v3(post, 0, 0), vscale(seatAxes[1], -0.07))), vadd(headC, vadd(v3(post, 0, 0), vscale(seatAxes[1], -0.16)))], 0.006, 4, P.chrome, { caps: false });
      }
    }
  };
  const seatX = Math.min(0.39, inner * 0.5);
  seat(-seatX, seatZ, 0.5, false);
  // The driver's seat: the top of its cushion's middle, and the wheel's grips.
  const seated = { seat: at(-seatX, floor + CUSHION_TOP_M, seatZ - 0.04), hands: [grip(-1), grip(1)] };
  seat(seatX, seatZ, 0.5, false);
  if (rows === 2) {
    // The rear seat comes forward until its headrests clear the roof and glass
    // over each of their top corners by 6 cm (a fastback's or a saloon's rear
    // glass falls steeply over them); where even the nearest place leaves too
    // little room, its back is lower, or it has no headrests.
    // Between the rear wheel wells, whose walls it stays inside of.
    const benchW = Math.min(1.36, 2 * inner - 0.1, 2 * (W - 0.035 - body.tire_width - 0.08));
    const clears = (zf, backH, headrests) => {
      const { backC, heads } = seatParts(0, zf, benchW, true, backH);
      const tops = headrests
        ? heads.flatMap((c) => [-0.125, 0.125].flatMap((dx) => [-0.05, 0.05].map((dz) => vadd(c, vadd(v3(dx, 0, 0), vadd(vscale(seatAxes[1], 0.085), vscale(seatAxes[2], dz)))))))
        : [-1, 1].flatMap((sx) => [-0.06, 0.06].map((dz) => vadd(backC, vadd(v3(sx * (benchW / 2 - 0.01), 0, 0), vadd(vscale(seatAxes[1], backH), vscale(seatAxes[2], dz))))));
      return tops.every((p) => p[1] < shape.lid(Math.abs(p[0]), p[2] + L / 2).y - 0.06);
    };
    let rearZ = Math.min(cabinEnd - 0.5, seatZ + 0.95);
    while (rearZ > seatZ + 0.62 && !clears(rearZ, fullBackH, true)) rearZ -= 0.02;
    let rearSeat = { backH: fullBackH, headrests: true };
    if (!clears(rearZ, fullBackH, true)) {
      let backH = fullBackH;
      while (backH > 0.16 && !clears(rearZ, backH, true)) backH -= 0.01;
      rearSeat = clears(rearZ, backH, true) ? { backH, headrests: true } : { backH: fullBackH, headrests: false };
      while (!rearSeat.headrests && rearSeat.backH > 0.12 && !clears(rearZ, rearSeat.backH, false)) rearSeat.backH -= 0.01;
    }
    if (rearZ > seatZ + 0.6) seat(0, rearZ, benchW, true, rearSeat);
    // Rear shelf (a saloon) or load cover (a hatch) behind the rear seat.
    const shelfY = shape.top(Math.min(L, cab.rear_base)) - 0.07;
    const shelf0 = rearZ + 0.42;
    const shelf1 = cab.rear_base - 0.08;
    if (!body.bed && shelf1 > shelf0 + 0.05) {
      // Its rear corners in from the body's rounded rear corners, so none pokes out through them.
      const halfAt = (zf) => {
        let half = inner;
        for (let i = 0; i <= 120; i += 1) {
          const o = shape.outline(2 + i / 120);
          if (o.zf <= zf + 0.12) half = Math.min(half, Math.max(0, o.x - 0.15));
        }
        return half;
      };
      const rearHalf = halfAt(shelf1);
      out.flat(at(-inner, shelfY, shelf0), at(-rearHalf, shelfY, shelf1), at(rearHalf, shelfY, shelf1), at(inner, shelfY, shelf0), up, P.cabin, 0.7);
    }
  }
  // Rear-view mirror under the windshield's top.
  out.roundedBox(at(0, (cab.glass_top ?? cab.roof) - 0.09, cab.windshield_top - 0.02), [0.11, 0.032, 0.012], 0.01, (k, sign) => (k === 2 && sign > 0 ? P.mirror : P.cabin));
  return seated;
}

// ---------------------------------------------------------------- underbody
// The floor under the car: its height by detail (the hero level's underbody
// floor, the others' dark sheet), and the sheet itself from zf0 to zf1 at half
// width hw, narrowed at each wheel to the well's wall so it never shows
// through an arch.
export function underFloorY(body, detail) {
  return body.clearance + (detail >= 3 ? 0.1 : 0.03);
}
// How far inside the wall the underside's skirt meets it (m), and where the
// hero level's underbody meets it (its wall's first ring).
const SKIRT_INSET_M = 0.004;
const UNDERBODY_SEAT_F = 0.035;
// seatF: the share of the wall's height of its level's first ring above the
// lower edge, where the skirt meets it (on the drawn wall at any level).
export function underFloor(out, shape, y, zf0, zf1, hw, ao, step = 0.08, seatF = 0.05) {
  const { body, L, W, axles, archRadius } = shape;
  const zOf = (zf) => zf - L / 2;
  const well = W - 0.035 - body.tire_width - 0.055;
  // The body's bottom edge in plan (its half width at each zf), from the wall's lowest ring.
  const edge = [];
  for (let i = 0; i <= 600; i += 1) {
    const p = shape.wall((3 * i) / 600, 0);
    edge.push([p.zf, p.x]);
  }
  // The wall a little way up from that edge, inside it: where the skirt meets it.
  const seat = [];
  for (let i = 0; i <= 600; i += 1) {
    const p = shape.wall((3 * i) / 600, seatF);
    const o = shape.outline((3 * i) / 600);
    seat.push([p.zf, p.x - o.nx * SKIRT_INSET_M, p.y]);
  }
  const seatAt = (zf) => {
    let best = null;
    for (let i = 0; i < seat.length - 1; i += 1) {
      const [za, xa, ya] = seat[i];
      const [zb, xb, yb] = seat[i + 1];
      if ((za - zf) * (zb - zf) <= 0 && za !== zb) {
        const t = (zf - za) / (zb - za);
        const x = lerp(xa, xb, t);
        if (!best || x > best[0]) best = [x, lerp(ya, yb, t)];
      }
    }
    return best;
  };
  const halfAt = (zf) => {
    let best = 0;
    for (let i = 0; i < edge.length - 1; i += 1) {
      const [za, xa] = edge[i];
      const [zb, xb] = edge[i + 1];
      if ((za - zf) * (zb - zf) <= 0 && za !== zb) best = Math.max(best, lerp(xa, xb, (zf - za) / (zb - za)));
    }
    return best;
  };
  // It rises into the overhangs to just above the bumpers' lower edge and keeps
  // inside the body's bottom edge, so it never shows from beside or behind; at
  // each wheel it narrows to the well's wall.
  const zs = [];
  const steps = Math.max(8, Math.ceil((zf1 - zf0) / step));
  for (let i = 0; i <= steps; i += 1) zs.push(lerp(zf0, zf1, i / steps));
  // The notch for each wheel ends exactly where the well's liner comes down to the floor.
  const linerR = archRadius + 0.004;
  const notch = linerR * Math.cos(Math.asin(clamp((body.wheel_radius - y) / linerR, -1, 1)));
  for (const axle of axles) zs.push(axle - notch, axle + notch);
  const cuts = zs.filter((z) => z >= zf0 && z <= zf1).sort((a, b) => a - b).filter((z, i, all) => i === 0 || z - all[i - 1] > 1e-4);
  const inWell = (zf) => axles.some((axle) => Math.abs(zf - axle) < notch - 1e-6);
  const down = v3(0, -1, 0);
  const height = (zf) => Math.max(y, shape.bottom(zf) + 0.01);
  for (let i = 0; i < cuts.length - 1; i += 1) {
    const [za, zb] = [cuts[i], cuts[i + 1]];
    const mid = (za + zb) / 2;
    const half = (zf) => Math.max(0.05, Math.min(hw, halfAt(zf) - 0.03, inWell(mid) ? well : Infinity));
    const [ha, hb] = [half(za), half(zb)];
    const [ya, yb] = [height(za), height(zb)];
    const n = vnorm(v3(0, -1, (yb - ya) / Math.max(1e-6, zb - za)));
    out.flat(v3(-ha, ya, zOf(za)), v3(ha, ya, zOf(za)), v3(hb, yb, zOf(zb)), v3(-hb, yb, zOf(zb)), n, P.under, ao);
    // Between the wheels a skirt runs from the sheet's edge out to the wall a
    // little way up from its lower edge, just inside it, above the tucked-under
    // lowest band (edge to edge with the lower edge it left a crack a ray
    // slipped through over the sill's inside).
    const [sa, sb] = [seatAt(za), seatAt(zb)];
    if (!inWell(mid) && sa && sb) {
      for (const side of [1, -1]) {
        const ea = Math.max(ha, sa[0]);
        const eb = Math.max(hb, sb[0]);
        const ba = sa[1];
        const bb = sb[1];
        if (ea - ha < 1e-4 && eb - hb < 1e-4 && ya - ba < 1e-4 && yb - bb < 1e-4) continue;
        // Facing down and in, square to the strip (out by ea - ha, down by ya - ba).
        const sn = vnorm(v3(-side * (ya - ba + 1e-3), -(ea - ha + 1e-3), 0));
        out.flat(v3(side * ha, ya, zOf(za)), v3(side * ea, ba, zOf(za)), v3(side * eb, bb, zOf(zb)), v3(side * hb, yb, zOf(zb)), sn, P.under, ao);
      }
    }
  }
  // A valance at each end, from the floor up into the bumper.
  for (const [zf, n] of [[cuts[0], v3(0, 0, -1)], [cuts.at(-1), v3(0, 0, 1)]]) {
    const half = Math.max(0.05, Math.min(hw, halfAt(zf) - 0.03));
    const from = height(zf);
    const to = shape.bottom(zf) + 0.06;
    if (to > from + 0.005) out.flat(v3(-half, from, zOf(zf)), v3(half, from, zOf(zf)), v3(half, to, zOf(zf)), v3(-half, to, zOf(zf)), n, P.under, ao);
  }
}
// What shows under a car from low down or when it lies on its roof: the floor
// with its tunnel, the subframes and suspension arms at each axle, and (unless
// electric) the exhaust with its silencer and tailpipe.
export function buildUnderbody(out, body, shape) {
  const { L, W, axles } = shape;
  const zOf = (zf) => zf - L / 2;
  const at = (x, y, zf) => v3(x, y, zOf(zf));
  // The floor sits over the sills' lower edge; nothing under it hangs below the body's clearance.
  const y0 = body.clearance + 0.1;
  const R = body.wheel_radius;
  const down = v3(0, -1, 0);
  const z0 = 0.07;
  const z1 = L - 0.07;
  const hw = W - 0.2;
  underFloor(out, shape, y0, z0, z1, hw, 0.35, 0.08, UNDERBODY_SEAT_F);
  // Sill rails and the tunnel.
  for (const x of [-hw + 0.08, hw - 0.08]) out.roundedBox(at(x, y0 - 0.02, (axles[0] + axles[1]) / 2), [0.06, 0.03, (axles[1] - axles[0]) / 2 - R - 0.1], 0.02, P.under, { ao: 0.5 });
  out.roundedBox(at(0, y0 - 0.012, (axles[0] + axles[1]) / 2), [0.13, 0.025, (axles[1] - axles[0]) / 2 - 0.1], 0.02, P.under, { ao: 0.45 });
  for (const [index, axle] of axles.entries()) {
    // Subframe cross-member, lower arms out to the hubs, drive shafts.
    out.roundedBox(at(0, y0 - 0.03, axle), [hw - 0.12, 0.035, 0.11], 0.025, P.exhaust, { ao: 0.55 });
    for (const side of [1, -1]) {
      const hub = at(side * (W - 0.035 - body.tire_width - 0.03), R - 0.04, axle);
      out.tube([at(side * (hw - 0.3), y0 - 0.02, axle - 0.12), hub], 0.022, 5, P.exhaust, { ao: 0.5 });
      out.tube([at(side * (hw - 0.3), y0 - 0.02, axle + 0.12), hub], 0.022, 5, P.exhaust, { ao: 0.5 });
      out.tube([at(side * 0.12, R * 0.92, axle), at(side * (W - 0.035 - body.tire_width - 0.02), R, axle)], 0.02, 6, P.exhaust, { ao: 0.5 });
      // Spring and damper up into the well.
      out.tube([hub, at(side * (W - 0.035 - body.tire_width - 0.1), R + shape.archRadius - 0.02, axle + (index === 0 ? 0.02 : 0.05))], 0.035, 6, P.exhaust, { ao: 0.45 });
    }
  }
  if (body.grille !== "none") {
    // Exhaust: down the right of the tunnel to a silencer across the tail and a tailpipe.
    const pipeY = y0 - 0.045;
    // The silencer lies across the tail, or ahead of the rear axle under a truck's high bed.
    const muffZ = body.bed ? axles[1] - R - 0.45 : L - body.tail.corner - 0.32;
    // The pipe only ever runs rearward (a short tail puts the silencer ahead of the axle's kink).
    const route = body.bed ? [at(0.2, pipeY, axles[0] + 0.45), at(0.2, pipeY, muffZ - 0.2)] : [at(0.2, pipeY, axles[0] + 0.45), at(0.2, pipeY, axles[1] - 0.5), at(0.3, pipeY - 0.01, axles[1] + 0.25), at(0.3, pipeY, muffZ - 0.2)];
    const pipe = route.filter((p, i) => i === route.length - 1 || route.slice(i + 1).every((q) => q[2] > p[2] + 0.05));
    out.tube(pipe, 0.028, 6, P.exhaust, { ao: 0.6 });
    out.roundedBox(at(0.1, pipeY - 0.02, muffZ), [0.36, 0.075, 0.13], 0.06, P.exhaust, { ao: 0.6 });
    // The tailpipe shows just under the bumper.
    const tipX = W - 0.36;
    const tipY = body.tail.bumper_bottom - 0.04;
    out.tube([at(tipX - 0.05, pipeY - 0.02, muffZ + 0.1), at(tipX, tipY, L - 0.2), at(tipX, tipY, L - 0.055)], 0.03, 8, P.chrome, { caps: false });
    out.tube([at(tipX, tipY, L - 0.06), at(tipX, tipY, L - 0.16)], 0.024, 8, P.under, { caps: true, ao: 0.2 });
  } else {
    // An electric car's flat battery tray.
    out.roundedBox(at(0, y0 - 0.02, (axles[0] + axles[1]) / 2), [hw - 0.16, 0.025, (axles[1] - axles[0]) / 2 - R - 0.12], 0.02, P.under, { ao: 0.5 });
  }
}

// ---------------------------------------------------------------- fittings
// The fittings every car has, each modelled once in its own frame (x out of
// the body's surface, y up it, z along it, round the fitting's centre) and
// laid on each body's surface where its layout puts it (street-car-kit.mjs
// drape), so a filler door, a handle or a number plate is the same part on
// every car and nothing is cut into the body for it.

// A rounded rectangle's outline in the (z, y) plane: [z, y] points, the same
// count and order for any size (straight runs in `runs` steps, corners in
// `steps`), so rings between two outlines join up.
function roundedRect(hz, hy, r, steps, runs = 4) {
  const pts = [];
  const corners = [[hz - r, hy - r], [-(hz - r), hy - r], [-(hz - r), -(hy - r)], [hz - r, -(hy - r)]];
  corners.forEach(([cz, cy], q) => {
    for (let i = 0; i <= steps; i += 1) {
      const t = ((q + i / steps) * Math.PI) / 2;
      pts.push([cz + r * Math.cos(t), cy + r * Math.sin(t)]);
    }
    // The straight run to the next corner.
    const [nz, ny] = corners[(q + 1) % 4];
    const t1 = (((q + 1) % 4) * Math.PI) / 2;
    const from = pts.at(-1);
    const to = [nz + r * Math.cos(t1), ny + r * Math.sin(t1)];
    for (let i = 1; i < runs; i += 1) pts.push([lerp(from[0], to[0], i / runs), lerp(from[1], to[1], i / runs)]);
  });
  return pts;
}
// A band between two outlines (outer at height xa, inner at xb), facing out
// (+x), tilted where it climbs.
function band(out, outer, inner, xa, xb, part, ao = 1) {
  for (let i = 0; i < outer.length; i += 1) {
    const j = (i + 1) % outer.length;
    const a = v3(xa, outer[i][1], outer[i][0]);
    const b = v3(xa, outer[j][1], outer[j][0]);
    const c = v3(xb, inner[j][1], inner[j][0]);
    const d = v3(xb, inner[i][1], inner[i][0]);
    const radial = vnorm(v3(0, outer[i][1] - inner[i][1], outer[i][0] - inner[i][0]));
    const width = Math.hypot(outer[i][1] - inner[i][1], outer[i][0] - inner[i][0]) || 1;
    const n = vnorm(vadd(v3(1, 0, 0), vscale(radial, (xb - xa) / width)));
    out.flat(a, b, c, d, n, part, ao);
  }
}
// A flat disc filling an outline at height x: rings of the outline scaled in
// toward its middle, then a small fan, so a draped disc follows its surface.
function disc(out, outline, x, part, ao = 1, scales = [1, 0.78, 0.56, 0.36, 0.18]) {
  for (let i = 0; i < scales.length - 1; i += 1) {
    band(out, outline.map(([z, y]) => [z * scales[i], y * scales[i]]), outline.map(([z, y]) => [z * scales[i + 1], y * scales[i + 1]]), x, x, part, ao);
  }
  const last = scales.at(-1);
  out.fan(v3(x, 0, 0), outline.map(([z, y]) => v3(x, y * last, z * last)), v3(1, 0, 0), part, ao);
}
// A flat rectangle at height x facing out (+x), hz by hy half-sizes, in cols
// columns along z.
function strip(out, hz, hy, x, cols, part, ao = 1) {
  const n = v3(1, 0, 0);
  for (let i = 0; i < cols; i += 1) {
    const z0 = lerp(-hz, hz, i / cols);
    const z1 = lerp(-hz, hz, (i + 1) / cols);
    out.flat(v3(x, -hy, z0), v3(x, hy, z0), v3(x, hy, z1), v3(x, -hy, z1), n, part, ao);
  }
}
// A box from x0 (against its mount) to x1, in cols columns along z, closed
// behind too (where the mount curves away under it, its back shows).
function slab(out, hz, hy, x0, x1, cols, part, ao = 1) {
  strip(out, hz, hy, x1, cols, part, ao);
  for (let i = 0; i < cols; i += 1) {
    const z0 = lerp(-hz, hz, i / cols);
    const z1 = lerp(-hz, hz, (i + 1) / cols);
    out.flat(v3(x0, -hy, z0), v3(x0, hy, z0), v3(x0, hy, z1), v3(x0, -hy, z1), v3(-1, 0, 0), part, ao * 0.6);
  }
  for (let i = 0; i < cols; i += 1) {
    const z0 = lerp(-hz, hz, i / cols);
    const z1 = lerp(-hz, hz, (i + 1) / cols);
    out.flat(v3(x0, hy, z0), v3(x0, hy, z1), v3(x1, hy, z1), v3(x1, hy, z0), v3(0, 1, 0), part, ao);
    out.flat(v3(x0, -hy, z1), v3(x0, -hy, z0), v3(x1, -hy, z0), v3(x1, -hy, z1), v3(0, -1, 0), part, ao);
  }
  out.flat(v3(x0, -hy, -hz), v3(x0, hy, -hz), v3(x1, hy, -hz), v3(x1, -hy, -hz), v3(0, 0, -1), part, ao);
  out.flat(v3(x0, hy, hz), v3(x0, -hy, hz), v3(x1, -hy, hz), v3(x1, hy, hz), v3(0, 0, 1), part, ao);
}

const fittingCache = new Map();
const cached = (key, build) => {
  if (!fittingCache.has(key)) fittingCache.set(key, build());
  return fittingCache.get(key);
};

// The filler door (a charge port door on the electric fastback): a painted
// flap a millimetre proud of the panel, its shut line dark round it.
export const FILLER_DOOR = Object.freeze({ half_along: 0.085, half_up: 0.075, radius: 0.035 });
export function fillerDoor() {
  return cached("filler", () => {
    const out = new CarMesh();
    const { half_along: hz, half_up: hy, radius: r } = FILLER_DOOR;
    const gap = 0.0035;
    const outer = roundedRect(hz + gap, hy + gap, r + gap, 6);
    const edge = roundedRect(hz, hy, r, 6);
    const face = roundedRect(hz - 0.0015, hy - 0.0015, r - 0.0015, 6);
    band(out, outer, edge, 0.0008, 0.0008, P.gap, 0.35);
    band(out, edge, face, 0.0008, 0.0016, P.paint, 0.85);
    disc(out, face, 0.0016, P.paint);
    return out;
  });
}

// A door handle: a pull bar standing off a dark pocket plate (the hero level),
// or the bar alone (near).
export function doorHandle(detail) {
  return cached(`handle${detail >= 3 ? 3 : 2}`, () => {
    const out = new CarMesh();
    if (detail >= 3) {
      const pocket = roundedRect(0.1, 0.026, 0.024, 5);
      const inner = roundedRect(0.094, 0.02, 0.018, 5);
      band(out, pocket, inner, 0.0008, 0.001, P.under, 0.5);
      disc(out, inner, 0.001, P.under, 0.45);
      out.roundedBox(v3(0.012, 0, 0), [0.011, 0.014, 0.085], 0.01, P.paint);
    } else {
      out.box(v3(0.009, 0, 0), [0.01, 0.014, 0.08], P.trim);
    }
    return out;
  });
}

// A number plate in its frame (a US plate, 305 by 152 mm): the plate 2 mm
// proud of the frame's face, so the frame shows all round it from any side,
// and at the nearer levels its characters, a dark band across its middle, so
// it reads as a plate on a white car too. Below the hero level the frame is a
// plain slab and the plate a strip, in columns so a draped plate follows a
// curved face; the far level has the plate alone.
export function numberPlate(detail) {
  return cached(`plate${detail}`, () => {
    const out = new CarMesh();
    const cols = 4;
    if (detail >= 3) out.roundedBox(v3(0.002, 0, 0), [0.006, 0.088, 0.164], 0.004, P.trim, { ao: 0.8 });
    else if (detail >= 1) slab(out, 0.164, 0.088, -0.004, 0.008, cols, P.trim, 0.8);
    if (detail >= 2) disc(out, roundedRect(0.1525, 0.076, 0.012, detail >= 3 ? 4 : 2, detail >= 3 ? 4 : 2), 0.0102, P.plate, 1, detail >= 3 ? undefined : [1, 0.5]);
    else strip(out, 0.1525, 0.076, 0.0102, cols, P.plate);
    if (detail >= 2) {
      const n = v3(1, 0, 0);
      const steps = 6;
      for (let i = 0; i < steps; i += 1) {
        const z0 = lerp(-0.105, 0.105, i / steps);
        const z1 = lerp(-0.105, 0.105, (i + 1) / steps);
        out.flat(v3(0.0116, -0.028, z0), v3(0.0116, 0.028, z0), v3(0.0116, 0.028, z1), v3(0.0116, -0.028, z1), n, P.rubber);
      }
    }
    return out;
  });
}

// A rear side reflector on the bumper's end.
export function sideReflector() {
  return cached("reflector", () => {
    const out = new CarMesh();
    const edge = roundedRect(0.045, 0.014, 0.01, 4);
    const face = roundedRect(0.042, 0.011, 0.007, 4);
    band(out, edge, face, 0.0004, 0.002, P.tail_lamp, 0.8);
    disc(out, face, 0.002, P.tail_lamp);
    return out;
  });
}

// The third brake light: a red bar at the top of the rear glass (or a cab
// back), along the car's width.
export function brakeLight(detail) {
  return cached(`brake${detail >= 3 ? 3 : 2}`, () => {
    const out = new CarMesh();
    if (detail >= 3) {
      out.roundedBox(v3(0.009, 0, 0), [0.01, 0.016, 0.18], 0.008, P.gloss_black);
      out.roundedBox(v3(0.0185, 0, 0), [0.0015, 0.008, 0.165], 0.0012, P.lamp_red);
    } else out.roundedBox(v3(0.009, 0, 0), [0.01, 0.012, 0.17], 0.007, P.lamp_red);
    return out;
  });
}
