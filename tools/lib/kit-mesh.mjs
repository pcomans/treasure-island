// Mesh helpers shared by the street kits (tools/lib/street-clutter-kit.mjs,
// street-car-kit.mjs, street-yard-kit.mjs): vectors, a monotone curve and the
// mesh builder. Every vertex names a part in UV.x, (part + 0.5) / partCount,
// and carries a baked occlusion factor in UV.y.

// The first sixteen parts every kit shares, in order (the clutter kit's part
// list; the car kit and the yard kit each add their own after them).
export const KIT_BASE_PARTS = Object.freeze([
  "paint",
  "roof",
  "glass",
  "tire",
  "rim",
  "hub",
  "trim",
  "chrome",
  "head_lamp",
  "tail_lamp",
  "plate",
  "under",
  "grille",
  "orange",
  "white",
  "metal",
]);

// ---------------------------------------------------------------- vectors
export const v3 = (x, y, z) => [x, y, z];
export const vsub = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
export const vadd = (a, b) => [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
export const vscale = (a, s) => [a[0] * s, a[1] * s, a[2] * s];
export const vdot = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
export const vcross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
export const vlen = (a) => Math.hypot(a[0], a[1], a[2]);
export const vnorm = (a) => {
  const l = vlen(a);
  return l > 1e-12 ? [a[0] / l, a[1] / l, a[2] / l] : [0, 1, 0];
};
export const lerp = (a, b, t) => a + (b - a) * t;
export const clamp = (x, a, b) => Math.max(a, Math.min(b, x));
export const smooth = (t) => {
  const c = clamp(t, 0, 1);
  return c * c * (3 - 2 * c);
};

// Monotone cubic interpolation through [x, y] keys (Fritsch-Carlson), flat beyond the ends.
export function curve(input) {
  // Keys sharing an x (one profile's end and the next one's start) collapse to the later one.
  const keys = [];
  for (const key of input) {
    if (keys.length > 0 && Math.abs(key[0] - keys.at(-1)[0]) < 1e-9) keys[keys.length - 1] = key;
    else keys.push(key);
  }
  const xs = keys.map((key) => key[0]);
  const ys = keys.map((key) => key[1]);
  const n = keys.length;
  if (n === 1) return () => ys[0];
  const d = [];
  for (let i = 0; i < n - 1; i += 1) d.push((ys[i + 1] - ys[i]) / (xs[i + 1] - xs[i]));
  const m = [d[0]];
  for (let i = 1; i < n - 1; i += 1) m.push(d[i - 1] * d[i] <= 0 ? 0 : (d[i - 1] + d[i]) / 2);
  m.push(d[n - 2]);
  for (let i = 0; i < n - 1; i += 1) {
    if (d[i] === 0) {
      m[i] = 0;
      m[i + 1] = 0;
      continue;
    }
    const a = m[i] / d[i];
    const b = m[i + 1] / d[i];
    const s = a * a + b * b;
    if (s > 9) {
      const t = 3 / Math.sqrt(s);
      m[i] = t * a * d[i];
      m[i + 1] = t * b * d[i];
    }
  }
  return (x) => {
    if (x <= xs[0]) return ys[0];
    if (x >= xs[n - 1]) return ys[n - 1];
    let i = 0;
    while (i < n - 2 && x > xs[i + 1]) i += 1;
    const h = xs[i + 1] - xs[i];
    const t = (x - xs[i]) / h;
    const t2 = t * t;
    const t3 = t2 * t;
    return (2 * t3 - 3 * t2 + 1) * ys[i] + (t3 - 2 * t2 + t) * h * m[i] + (-2 * t3 + 3 * t2) * ys[i + 1] + (t3 - t2) * h * m[i + 1];
  };
}

// ---------------------------------------------------------------- mesh builder
// partCount is the size of the part list UV.x indexes (each kit has its own).
export class MeshBuilder {
  constructor(partCount = KIT_BASE_PARTS.length) {
    this.partCount = partCount;
    this.positions = [];
    this.normals = [];
    this.uvs = [];
    this.indices = [];
  }

  vertex(position, normal, part, ao = 1) {
    this.positions.push(position[0], position[1], position[2]);
    this.normals.push(normal[0], normal[1], normal[2]);
    this.uvs.push((part + 0.5) / this.partCount, clamp(ao, 0, 1));
    return this.positions.length / 3 - 1;
  }

  // One triangle, counterclockwise seen from outside (glTF front face); a
  // triangle with almost no area is dropped.
  triangle(a, b, c, normals, part, ao = [1, 1, 1]) {
    const n = vcross(vsub(b, a), vsub(c, a));
    if (vlen(n) < 1e-9) return;
    const flat = vnorm(n);
    const [na, nb, nc] = normals ?? [flat, flat, flat];
    this.indices.push(this.vertex(a, na, part, ao[0]), this.vertex(b, nb, part, ao[1]), this.vertex(c, nc, part, ao[2]));
  }

  // A quad a-b-c-d counterclockwise seen from outside.
  quad(a, b, c, d, normals, part, ao = [1, 1, 1, 1]) {
    const [na, nb, nc, nd] = normals ?? [null, null, null, null];
    if (normals) {
      this.triangle(a, b, c, [na, nb, nc], part, [ao[0], ao[1], ao[2]]);
      this.triangle(a, c, d, [na, nc, nd], part, [ao[0], ao[2], ao[3]]);
    } else {
      this.triangle(a, b, c, null, part, [ao[0], ao[1], ao[2]]);
      this.triangle(a, c, d, null, part, [ao[0], ao[2], ao[3]]);
    }
  }

  // An oriented box: centre, half sizes along the given unit axes.
  box(center, half, part, axes = [v3(1, 0, 0), v3(0, 1, 0), v3(0, 0, 1)], skip = {}) {
    const [ax, ay, az] = axes;
    const corner = (sx, sy, sz) => vadd(center, vadd(vscale(ax, sx * half[0]), vadd(vscale(ay, sy * half[1]), vscale(az, sz * half[2]))));
    const faces = [
      ["+x", ax, [[1, -1, -1], [1, 1, -1], [1, 1, 1], [1, -1, 1]]],
      ["-x", vscale(ax, -1), [[-1, -1, 1], [-1, 1, 1], [-1, 1, -1], [-1, -1, -1]]],
      ["+y", ay, [[-1, 1, -1], [-1, 1, 1], [1, 1, 1], [1, 1, -1]]],
      ["-y", vscale(ay, -1), [[-1, -1, 1], [-1, -1, -1], [1, -1, -1], [1, -1, 1]]],
      ["+z", az, [[1, -1, 1], [1, 1, 1], [-1, 1, 1], [-1, -1, 1]]],
      ["-z", vscale(az, -1), [[-1, -1, -1], [-1, 1, -1], [1, 1, -1], [1, -1, -1]]],
    ];
    for (const [name, normal, corners] of faces) {
      if (skip[name]) continue;
      const [a, b, c, d] = corners.map(([sx, sy, sz]) => corner(sx, sy, sz));
      // Orient each face outward whatever the axes' handedness.
      const n = vcross(vsub(b, a), vsub(c, a));
      const partOf = typeof part === "function" ? part(name) : part;
      if (vdot(n, normal) >= 0) this.quad(a, b, c, d, [normal, normal, normal, normal], partOf);
      else this.quad(a, d, c, b, [normal, normal, normal, normal], partOf);
    }
  }

  // A surface of revolution about the axis from `origin` along unit `axis`:
  // profile is [[radius, along], ...]; parts per profile segment.
  lathe(origin, axis, profile, sides, partOf, phase = 0, aoOf = () => 1) {
    const helper = Math.abs(axis[1]) < 0.9 ? v3(0, 1, 0) : v3(1, 0, 0);
    const u = vnorm(vcross(axis, helper));
    const w = vcross(axis, u);
    const point = (r, a, angle) => vadd(origin, vadd(vscale(axis, a), vadd(vscale(u, r * Math.cos(angle)), vscale(w, r * Math.sin(angle)))));
    // Profile normals in the (radial, axial) plane, averaged at shared points.
    const segNormals = [];
    for (let i = 0; i < profile.length - 1; i += 1) {
      const dr = profile[i + 1][0] - profile[i][0];
      const da = profile[i + 1][1] - profile[i][1];
      const l = Math.hypot(dr, da) || 1;
      // Outward in the profile plane: rotate the tangent (dr, da) by -90 degrees.
      segNormals.push([da / l, -dr / l]);
    }
    const pointNormal = (i, segment) => {
      const own = segNormals[segment];
      const neighbor = i === segment ? segNormals[segment - 1] : segNormals[segment + 1];
      if (!neighbor || own[0] * neighbor[0] + own[1] * neighbor[1] < Math.cos((40 * Math.PI) / 180)) return own;
      const s = [own[0] + neighbor[0], own[1] + neighbor[1]];
      const l = Math.hypot(s[0], s[1]) || 1;
      return [s[0] / l, s[1] / l];
    };
    const normalAt = (pn, angle) => vnorm(vadd(vscale(axis, pn[1]), vadd(vscale(u, pn[0] * Math.cos(angle)), vscale(w, pn[0] * Math.sin(angle)))));
    for (let i = 0; i < profile.length - 1; i += 1) {
      const part = partOf(i);
      if (part === null) continue;
      const n0 = pointNormal(i, i);
      const n1 = pointNormal(i + 1, i);
      for (let s = 0; s < sides; s += 1) {
        const t0 = phase + (2 * Math.PI * s) / sides;
        const t1 = phase + (2 * Math.PI * (s + 1)) / sides;
        const a = point(profile[i][0], profile[i][1], t0);
        const b = point(profile[i][0], profile[i][1], t1);
        const c = point(profile[i + 1][0], profile[i + 1][1], t1);
        const d = point(profile[i + 1][0], profile[i + 1][1], t0);
        const normals = [normalAt(n0, t0), normalAt(n0, t1), normalAt(n1, t1), normalAt(n1, t0)];
        const ao = [aoOf(i), aoOf(i), aoOf(i + 1), aoOf(i + 1)];
        // Orient outward against the averaged normal.
        const n = vcross(vsub(b, a), vsub(c, a));
        const avg = vadd(vadd(normals[0], normals[1]), vadd(normals[2], normals[3]));
        if (vlen(n) > 1e-12 && vdot(n, avg) < 0) this.quad(a, d, c, b, [normals[0], normals[3], normals[2], normals[1]], part, [ao[0], ao[3], ao[2], ao[1]]);
        else this.quad(a, b, c, d, normals, part, ao);
      }
    }
  }

  // A loft over a grid of points grid[k][j] (k along +Z, j up the right side
  // from bottom centre to top centre), mirrored to the left side. partOf(k, j)
  // names the part of the quad between stations k, k+1 and ring points j, j+1
  // (null leaves it out). Normals are smoothed across quads that meet at less
  // than the crease angle.
  loft(grid, partOf, { crease = 48, aoOf = () => 1 } = {}) {
    const K = grid.length;
    const M = grid[0].length;
    const quadNormal = [];
    for (let k = 0; k < K - 1; k += 1) {
      quadNormal.push([]);
      for (let j = 0; j < M - 1; j += 1) {
        const a = grid[k][j];
        const c = grid[k + 1][j + 1];
        const b = grid[k][j + 1];
        const d = grid[k + 1][j];
        // Outward for the right side is (j direction) x (k direction).
        const n = vcross(vsub(c, a), vsub(d, b));
        quadNormal[k].push({ n: vlen(n) > 1e-10 ? vnorm(n) : null, area: vlen(n) / 2 });
      }
    }
    const cosCrease = Math.cos((crease * Math.PI) / 180);
    const cornerNormal = (k, j, own) => {
      let sum = v3(0, 0, 0);
      for (const [qk, qj] of [[k - 1, j - 1], [k - 1, j], [k, j - 1], [k, j]]) {
        if (qk < 0 || qj < 0 || qk >= K - 1 || qj >= M - 1) continue;
        const q = quadNormal[qk][qj];
        if (!q.n || vdot(q.n, own) < cosCrease) continue;
        sum = vadd(sum, vscale(q.n, Math.max(q.area, 1e-6)));
      }
      // The centre line: the mirrored neighbour across x = 0 joins the average.
      if (Math.abs(grid[k][j][0]) < 1e-6) sum[0] = 0;
      return vlen(sum) > 1e-9 ? vnorm(sum) : own;
    };
    const mirror = (p) => [-p[0], p[1], p[2]];
    for (let k = 0; k < K - 1; k += 1) {
      for (let j = 0; j < M - 1; j += 1) {
        const q = quadNormal[k][j];
        const part = partOf(k, j);
        if (!q.n || part === null || part === undefined) continue;
        const a = grid[k][j];
        const b = grid[k][j + 1];
        const c = grid[k + 1][j + 1];
        const d = grid[k + 1][j];
        const na = cornerNormal(k, j, q.n);
        const nb = cornerNormal(k, j + 1, q.n);
        const nc = cornerNormal(k + 1, j + 1, q.n);
        const nd = cornerNormal(k + 1, j, q.n);
        const ao = [aoOf(k, j), aoOf(k, j + 1), aoOf(k + 1, j + 1), aoOf(k + 1, j)];
        this.quad(a, b, c, d, [na, nb, nc, nd], part, ao);
        this.quad(mirror(a), mirror(d), mirror(c), mirror(b), [mirror(na), mirror(nd), mirror(nc), mirror(nb)], part, [ao[0], ao[3], ao[2], ao[1]]);
      }
    }
  }

  // Shares identical vertices (position, normal and part), keeping triangle order.
  result() {
    const key = (i) => [
      ...this.positions.slice(i * 3, i * 3 + 3).map((v) => Math.round(v * 1e5)),
      ...this.normals.slice(i * 3, i * 3 + 3).map((v) => Math.round(v * 1e4)),
      ...this.uvs.slice(i * 2, i * 2 + 2).map((v) => Math.round(v * 1e4)),
    ].join(",");
    const seen = new Map();
    const positions = [];
    const normals = [];
    const uvs = [];
    const remap = [];
    for (let i = 0; i < this.positions.length / 3; i += 1) {
      const k = key(i);
      if (!seen.has(k)) {
        seen.set(k, positions.length / 3);
        positions.push(...this.positions.slice(i * 3, i * 3 + 3));
        normals.push(...this.normals.slice(i * 3, i * 3 + 3));
        uvs.push(...this.uvs.slice(i * 2, i * 2 + 2));
      }
      remap.push(seen.get(k));
    }
    return { positions, normals, uvs, indices: this.indices.map((index) => remap[index]) };
  }
}
