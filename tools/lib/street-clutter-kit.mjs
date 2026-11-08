// The street-clutter kit: low-poly meshes for PlayableWorld/StreetDetail/Clutter
// (parked cars, cones, A-frame barricades), written to
// game/resources/models/street/street_clutter_kit.glb by
// tools/build_street_clutter_kit.mjs and drawn at runtime by
// game/scripts/world/street_clutter_builder.gd with one shader
// (game/resources/shaders/street_clutter.gdshader).
//
// Every vertex names a part (glass, tyre, lamp, ...) in UV.x and carries a baked
// occlusion factor in UV.y; the shader turns the part into its colour and
// finish. The body paint is not in the mesh: each parked car is a MultiMesh
// instance whose colour is the paint, so one mesh per body type serves every
// colour. Meshes face -Z (the front), +Y up, +X the car's right; the origin is
// on the ground under the middle of the body.
//
// Body dimensions are production inference: typical 2020s Bay Area models
// photographed parked in the pilot zones (Sep and Nov 2025 Street View: compact
// SUVs, sedans, an EV fastback, hatchbacks and wagons, white utility pickups
// and a high-roof van), generic rather than any make.

export const CLUTTER_KIT_PARTS = Object.freeze([
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
const PART = Object.freeze(Object.fromEntries(CLUTTER_KIT_PARTS.map((name, index) => [name, index])));
export const CLUTTER_KIT_PART_COUNT = CLUTTER_KIT_PARTS.length;

// ---------------------------------------------------------------- vectors
// Shared with the yard kit (tools/lib/street-yard-kit.mjs).
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
const smooth = (t) => {
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
// partCount is the size of the part list UV.x indexes (the yard kit has its own).
export class MeshBuilder {
  constructor(partCount = CLUTTER_KIT_PART_COUNT) {
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

// ---------------------------------------------------------------- car bodies
// Lengths in metres. Profiles run from the front bumper (0) to the rear (length).
//   hood: [distance from front, top of the body] from the front face to the windshield base
//   cabin: windshield base and top, roof end, rear glass base, roof height and crown
//   deck: [distance, top] behind the cabin (trunk, bed or tailgate top)
//   nose/tail: bumper bottom, face lean (top set back), corner radius in plan
export const CAR_BODIES = Object.freeze({
  // Compact crossover SUV: the commonest parked car in the photos (BMW X3 /
  // Mercedes GLC / Ford Edge / Nissan Rogue / VW ID.4 class).
  crossover: {
    length: 4.62, width: 1.87, wheelbase: 2.76, front_overhang: 0.9, wheel_radius: 0.36, tire_width: 0.24, clearance: 0.2,
    nose: { bumper_bottom: 0.3, lean: 0.16, corner: 0.42, face_top: 0.84 },
    tail: { bumper_bottom: 0.36, lean: 0.05, corner: 0.36, face_top: 1.04 },
    hood: [[0.0, 0.84], [0.35, 0.93], [1.0, 1.0], [1.35, 1.04]],
    belt: [[1.35, 1.04], [3.6, 1.1], [4.55, 1.08]],
    deck: [[4.55, 1.08], [4.62, 1.04]],
    cabin: { windshield_base: 1.35, windshield_top: 2.18, roof_end: 4.25, rear_base: 4.58, roof: 1.66, crown: 0.025, tumblehome: 0.2, rear_drop: 0.07 },
    pillars: { b: 2.72, c: 3.55, quarter_glass: true },
    cladding: 0.33, roof_rails: true, grille: "wide",
  },
  // Larger three-row SUV / minivan class (Highlander, Sienna).
  suv: {
    length: 4.98, width: 1.95, wheelbase: 2.9, front_overhang: 0.98, wheel_radius: 0.375, tire_width: 0.25, clearance: 0.21,
    nose: { bumper_bottom: 0.32, lean: 0.14, corner: 0.42, face_top: 0.92 },
    tail: { bumper_bottom: 0.38, lean: 0.04, corner: 0.34, face_top: 1.08 },
    hood: [[0.0, 0.92], [0.4, 1.0], [1.15, 1.08], [1.42, 1.1]],
    belt: [[1.42, 1.1], [4.0, 1.15], [4.9, 1.13]],
    deck: [[4.9, 1.13], [4.98, 1.08]],
    cabin: { windshield_base: 1.42, windshield_top: 2.25, roof_end: 4.7, rear_base: 4.94, roof: 1.76, crown: 0.025, tumblehome: 0.19, rear_drop: 0.05 },
    pillars: { b: 2.8, c: 3.75, quarter_glass: true },
    cladding: 0.28, roof_rails: true, grille: "wide",
  },
  // Mid-size sedan (Camry, Accord, WRX, E-class).
  sedan: {
    length: 4.82, width: 1.83, wheelbase: 2.82, front_overhang: 0.95, wheel_radius: 0.335, tire_width: 0.225, clearance: 0.15,
    nose: { bumper_bottom: 0.25, lean: 0.18, corner: 0.34, face_top: 0.7 },
    tail: { bumper_bottom: 0.3, lean: 0.1, corner: 0.32, face_top: 0.98 },
    hood: [[0.0, 0.7], [0.35, 0.79], [1.0, 0.87], [1.42, 0.93]],
    belt: [[1.42, 0.93], [3.35, 1.01]],
    deck: [[3.98, 1.03], [4.55, 1.04], [4.82, 1.0]],
    cabin: { windshield_base: 1.42, windshield_top: 2.3, roof_end: 3.35, rear_base: 3.98, roof: 1.44, crown: 0.02, tumblehome: 0.21, rear_drop: 0.06 },
    pillars: { b: 2.78, c: null, quarter_glass: false },
    cladding: 0, roof_rails: false, grille: "sedan",
  },
  // EV fastback sedan (Tesla Model 3 class): short nose, no grille, long glass roof.
  fastback: {
    length: 4.72, width: 1.85, wheelbase: 2.88, front_overhang: 0.85, wheel_radius: 0.34, tire_width: 0.235, clearance: 0.14,
    nose: { bumper_bottom: 0.24, lean: 0.22, corner: 0.38, face_top: 0.66 },
    tail: { bumper_bottom: 0.3, lean: 0.08, corner: 0.34, face_top: 0.98 },
    hood: [[0.0, 0.66], [0.3, 0.75], [0.8, 0.83], [1.22, 0.89]],
    belt: [[1.22, 0.89], [3.4, 0.99]],
    deck: [[4.3, 1.02], [4.55, 1.03], [4.72, 0.99]],
    cabin: { windshield_base: 1.22, windshield_top: 2.15, roof_end: 3.3, rear_base: 4.3, roof: 1.43, crown: 0.025, tumblehome: 0.22, rear_drop: 0.07 },
    pillars: { b: 2.72, c: null, quarter_glass: false },
    cladding: 0, roof_rails: false, grille: "none", glass_roof: true,
  },
  // Hatchback (Civic hatch, Golf, Elantra GT).
  hatchback: {
    length: 4.38, width: 1.79, wheelbase: 2.68, front_overhang: 0.9, wheel_radius: 0.32, tire_width: 0.215, clearance: 0.15,
    nose: { bumper_bottom: 0.26, lean: 0.18, corner: 0.35, face_top: 0.72 },
    tail: { bumper_bottom: 0.32, lean: 0.06, corner: 0.32, face_top: 1.0 },
    hood: [[0.0, 0.72], [0.35, 0.8], [0.95, 0.88], [1.36, 0.94]],
    belt: [[1.36, 0.94], [3.6, 1.02], [4.3, 1.01]],
    deck: [[4.3, 1.01], [4.38, 0.99]],
    cabin: { windshield_base: 1.36, windshield_top: 2.2, roof_end: 3.62, rear_base: 4.32, roof: 1.46, crown: 0.02, tumblehome: 0.2, rear_drop: 0.08 },
    pillars: { b: 2.62, c: null, quarter_glass: false },
    cladding: 0, roof_rails: false, grille: "sedan",
  },
  // Wagon (Subaru Outback / Impreza wagon, photographed silver at 5107 Ave of the Palms).
  wagon: {
    length: 4.86, width: 1.84, wheelbase: 2.75, front_overhang: 0.94, wheel_radius: 0.345, tire_width: 0.225, clearance: 0.2,
    nose: { bumper_bottom: 0.3, lean: 0.18, corner: 0.42, face_top: 0.8 },
    tail: { bumper_bottom: 0.36, lean: 0.05, corner: 0.36, face_top: 1.02 },
    hood: [[0.0, 0.8], [0.35, 0.88], [1.05, 0.95], [1.5, 0.99]],
    belt: [[1.5, 0.99], [4.0, 1.04], [4.8, 1.03]],
    deck: [[4.8, 1.03], [4.86, 0.99]],
    cabin: { windshield_base: 1.5, windshield_top: 2.36, roof_end: 4.5, rear_base: 4.82, roof: 1.58, crown: 0.02, tumblehome: 0.2, rear_drop: 0.08 },
    pillars: { b: 2.86, c: 3.72, quarter_glass: true },
    cladding: 0.24, roof_rails: true, grille: "sedan",
  },
  // Full-size pickup with a tonneau-covered bed (F-150 class).
  pickup: {
    length: 5.86, width: 2.0, wheelbase: 3.68, front_overhang: 0.98, wheel_radius: 0.4, tire_width: 0.27, clearance: 0.24,
    nose: { bumper_bottom: 0.38, lean: 0.06, corner: 0.3, face_top: 1.12 },
    tail: { bumper_bottom: 0.48, lean: 0.0, corner: 0.12, face_top: 1.18 },
    hood: [[0.0, 1.12], [0.25, 1.18], [1.2, 1.22], [1.75, 1.25]],
    belt: [[1.75, 1.25], [3.78, 1.28]],
    deck: [[3.86, 1.22], [5.86, 1.2]],
    cabin: { windshield_base: 1.75, windshield_top: 2.38, roof_end: 3.7, rear_base: 3.8, roof: 1.95, crown: 0.02, tumblehome: 0.16, rear_drop: 0.03 },
    pillars: { b: 2.92, c: null, quarter_glass: false },
    cladding: 0.0, roof_rails: false, grille: "truck", bed: "tonneau",
  },
  // White utility pickup with a service body (the trucks photographed in the
  // Building 1 forecourt lot, Sep 2025).
  utility: {
    length: 6.2, width: 2.03, wheelbase: 3.68, front_overhang: 0.98, wheel_radius: 0.4, tire_width: 0.27, clearance: 0.24,
    nose: { bumper_bottom: 0.38, lean: 0.06, corner: 0.3, face_top: 1.12 },
    tail: { bumper_bottom: 0.5, lean: 0.0, corner: 0.06, face_top: 1.42 },
    hood: [[0.0, 1.12], [0.25, 1.18], [1.2, 1.22], [1.75, 1.25]],
    belt: [[1.75, 1.25], [3.78, 1.28]],
    deck: [[3.84, 1.5], [6.2, 1.5]],
    cabin: { windshield_base: 1.75, windshield_top: 2.38, roof_end: 3.7, rear_base: 3.8, roof: 1.95, crown: 0.02, tumblehome: 0.16, rear_drop: 0.03 },
    pillars: { b: 2.92, c: null, quarter_glass: false },
    cladding: 0.0, roof_rails: false, grille: "truck", bed: "service",
  },
  // High-roof cargo van (Sprinter / Transit class, the dark van at 1 Avenue of the Palms).
  van: {
    length: 5.93, width: 2.02, wheelbase: 3.66, front_overhang: 0.98, wheel_radius: 0.37, tire_width: 0.235, clearance: 0.2,
    nose: { bumper_bottom: 0.34, lean: 0.12, corner: 0.36, face_top: 1.05 },
    tail: { bumper_bottom: 0.42, lean: 0.0, corner: 0.16, face_top: 1.1 },
    hood: [[0.0, 1.05], [0.3, 1.14], [0.7, 1.2], [0.98, 1.24]],
    belt: [[0.98, 1.24], [2.0, 1.28], [5.85, 1.28]],
    deck: [[5.85, 1.28], [5.93, 1.24]],
    cabin: { windshield_base: 0.98, windshield_top: 1.82, roof_end: 5.82, rear_base: 5.9, roof: 2.62, crown: 0.03, tumblehome: 0.12, rear_drop: 0.03 },
    pillars: { b: 2.12, c: 2.2, quarter_glass: false, cargo_from: 2.2 },
    cladding: 0.22, roof_rails: false, grille: "wide",
  },
});

// Each tyre's outer face sits this far inside the body side; the mirror
// housings reach this far beyond it.
const WHEEL_INSET_M = 0.035;
const MIRROR_REACH_M = 0.14;

// Detail levels: stations per arch, ring resolution and wheel sides.
const LODS = Object.freeze([
  { arch: 7, mid: 0.6, corner: 4, face: [0, 0.18, 0.42, 0.62, 0.8, 1], glass: [4, 3], sides: 14, spokes: true, mirrors: true },
  { arch: 3, mid: 1.3, corner: 2, face: [0, 0.55, 1], glass: [2, 2], sides: 8, spokes: false, mirrors: false },
]);

// Door seams along the side, from the cabin layout: the front door's front edge
// behind the windshield base, the B pillar, and the rear door's rear edge (or a
// pickup's cab back, a van's sliding door).
const SEAM_HALF_M = 0.006;
function doorSeams(body) {
  const cab = body.cabin;
  const seams = [cab.windshield_base + 0.07];
  if (body.pillars.b) seams.push(body.pillars.b);
  if (body.pillars.cargo_from) seams.push(body.pillars.cargo_from + 1.25);
  else if (body.bed) seams.push(cab.rear_base - 0.08);
  else if (body.pillars.c) seams.push(body.pillars.c - 0.04);
  else seams.push(cab.roof_end + 0.08);
  return seams;
}

// The tub: the body below the glasshouse, a loft from nose to tail.
// Ring (one side, bottom centre to top centre):
//   0 bottom centre, 1 bottom edge, 2 rocker, 3 lower side, 4 upper side,
//   5 shoulder, 6 top edge, 7 deck middle, 8 deck centre.
const TUB_RING = 9;

function bodyFunctions(body) {
  const L = body.length;
  const W = body.width / 2;
  const axles = [body.front_overhang, body.front_overhang + body.wheelbase];
  const archRadius = body.wheel_radius + 0.055;
  const top = curve([...body.hood, ...body.belt.slice(1), ...body.deck]);
  const nose = body.nose;
  const tail = body.tail;
  const bottom = (zf) => {
    let y = body.clearance;
    // Bumpers lift toward the ends.
    y = Math.max(y, lerp(nose.bumper_bottom, body.clearance, smooth(zf / Math.max(0.3, axles[0] - archRadius))));
    y = Math.max(y, lerp(tail.bumper_bottom, body.clearance, smooth((L - zf) / Math.max(0.3, L - axles[1] - archRadius))));
    for (const axle of axles) {
      const d = Math.abs(zf - axle);
      if (d < archRadius) y = Math.max(y, body.wheel_radius + Math.sqrt(archRadius * archRadius - d * d) * 0.98);
    }
    return y;
  };
  // Plan half width: rounded corners at both ends.
  const halfWidth = (zf) => {
    if (zf < nose.corner) {
      const t = (nose.corner - zf) / nose.corner;
      return W - nose.corner + nose.corner * Math.sqrt(Math.max(0, 1 - t * t));
    }
    if (zf > L - tail.corner) {
      const t = (zf - (L - tail.corner)) / tail.corner;
      return W - tail.corner + tail.corner * Math.sqrt(Math.max(0, 1 - t * t));
    }
    return W;
  };
  return { L, W, axles, archRadius, top, bottom, halfWidth };
}

// Height fractions of ring points 3 and 4 along the side and at the faces
// (the faces carry the lamp band just under their top).
function tubRing(fns, body, zf, hw, end) {
  const yb = fns.bottom(zf);
  const yt = fns.top(zf);
  const h = Math.max(0.05, yt - yb);
  const f3 = lerp(0.3, 0.42, end);
  const f4 = lerp(0.72, Math.max(0.5, 1 - 0.19 / h), end);
  const shoulder = Math.min(0.045, h * 0.2);
  const crown = lerp(0.03, 0.005, end);
  return [
    [0, yb],
    [hw * 0.84, yb],
    [hw * 0.965, yb + Math.min(0.09, h * 0.2)],
    [hw, yb + h * f3],
    [hw * 0.998, yb + h * f4],
    [hw * 0.975, yt - shoulder],
    [hw * 0.93, yt],
    [hw * 0.5, yt + crown * 0.8],
    [0, yt + crown],
  ];
}

// Exported for the yard kit's cargo van (tools/lib/street-yard-kit.mjs).
// wheels: false leaves the four wheels out (the drivable car's chassis).
export function buildCar(name, lodIndex, { wheels = true } = {}) {
  const body = CAR_BODIES[name];
  const lod = LODS[lodIndex];
  const fns = bodyFunctions(body);
  const { L, W, axles, archRadius } = fns;
  const out = new MeshBuilder();
  const zOf = (zf) => zf - L / 2;

  // --- Tub stations: face steps, corners, arches, the rest.
  const stations = [];
  // Front face: from the centre line out to the corner start (x fraction of
  // the corner start), all at the very front with a small bow.
  const noseEdge = W - body.nose.corner;
  const tailEdge = W - body.tail.corner;
  const frontFace = lod.face;
  for (const f of frontFace) stations.push({ zf: -0.06 * (1 - f) * (1 - f), hw: noseEdge * f, end: 1, face: "front", fx: f });
  for (let i = 1; i <= lod.corner; i += 1) {
    const a = ((Math.PI / 2) * i) / lod.corner;
    stations.push({ zf: body.nose.corner * (1 - Math.cos(a)), hw: noseEdge + body.nose.corner * Math.sin(a), end: 1 - i / lod.corner, face: null });
  }
  const middle = [];
  for (const axle of axles) {
    middle.push(axle - archRadius - 0.015, axle + archRadius + 0.015);
    for (let i = 0; i < lod.arch; i += 1) middle.push(axle - archRadius + (2 * archRadius * (i + 0.5)) / lod.arch);
  }
  const cab = body.cabin;
  // Door seams (near detail only): thin dark strips down the side from the
  // shoulder to the rocker, at the door edges.
  const seams = lodIndex === 0 ? doorSeams(body) : [];
  for (const seam of seams) middle.push(seam - SEAM_HALF_M, seam + SEAM_HALF_M);
  const span0 = body.nose.corner + 0.05;
  const span1 = L - body.tail.corner - 0.05;
  for (let z = span0; z < span1; z += lod.mid) middle.push(z);
  middle.push(span1);
  const sortedMiddle = [...new Set(middle.map((z) => Math.round(z * 1000) / 1000))]
    .filter((z) => z > body.nose.corner + 0.01 && z < L - body.tail.corner - 0.01)
    .sort((a, b) => a - b);
  for (const zf of sortedMiddle) stations.push({ zf, hw: W, end: 0, face: null });
  for (let i = lod.corner - 1; i >= 0; i -= 1) {
    const a = ((Math.PI / 2) * i) / lod.corner;
    stations.push({ zf: L - body.tail.corner * (1 - Math.cos(a)), hw: tailEdge + body.tail.corner * Math.sin(a), end: 1 - i / lod.corner, face: null });
  }
  for (const f of [...frontFace].reverse()) stations.push({ zf: L + 0.04 * (1 - f) * (1 - f), hw: tailEdge * f, end: 1, face: "rear", fx: f });

  // Lean: the upper part of each end face is set in toward the middle of the
  // car (a positive lean), fading out around the corners; the top points then
  // take the hood or deck height where they land, so the top stays continuous.
  const grid = stations.map((station) => {
    const front = station.zf < L / 2;
    const evalZf = station.face ? (front ? 0 : L) : clamp(station.zf, 0, L);
    const ring = tubRing(fns, body, evalZf, station.hw, station.end);
    const yb = ring[0][1];
    const yt = ring[TUB_RING - 1][1];
    const lean = (front ? body.nose.lean : body.tail.lean) * station.end;
    // The far detail level drops the deck crown point (its band collapses).
    if (lodIndex > 0) ring[7] = [...ring[6]];
    return ring.map(([x, y], j) => {
      const frac = clamp((y - yb) / Math.max(0.05, yt - yb), 0, 1);
      const zf = station.zf + (front ? 1 : -1) * lean * frac * frac;
      const lift = j >= 5 ? fns.top(clamp(zf, 0, L)) - fns.top(evalZf) : 0;
      return v3(x, y + lift, zOf(zf));
    });
  });

  // Parts of the tub.
  const lampFront = (station) => station.zf < L / 2;
  const tubPart = (k, j) => {
    const s0 = stations[k];
    const s1 = stations[k + 1];
    const zf = (s0.zf + s1.zf) / 2;
    const atFace = s0.face && s1.face;
    const front = zf < L / 2;
    const fx = atFace ? (s0.fx + s1.fx) / 2 : 1;
    const end = (s0.end + s1.end) / 2;
    // The underbody band only shows from close to the ground.
    if (j === 0) return lodIndex === 0 ? PART.under : null;
    // Wheel wells: the bottom bands over the arches.
    const inArch = axles.some((axle) => Math.abs(zf - axle) < archRadius);
    if (j === 1) return inArch ? PART.under : PART.under;
    if (atFace) {
      // Front: lamps out at the corners in the band under the top, grille
      // between, plate and intake low in the middle.
      if (front) {
        // Upper band: lamps at the corners, the grille (or plain body) between.
        if (j === 4) {
          if (fx > 0.6) return PART.head_lamp;
          if (body.grille === "truck") return PART.chrome;
          return body.grille === "wide" ? PART.grille : PART.paint;
        }
        // Lower band: plate in the middle, the lower grille or intake beside it.
        if (j === 3) {
          if (fx < 0.2) return PART.plate;
          if (body.grille === "truck") return PART.grille;
          return fx > 0.66 ? PART.paint : PART.grille;
        }
        if (j === 2) return PART.trim;
        return PART.paint;
      }
      if (j === 4) return fx > 0.58 ? PART.tail_lamp : body.bed === "service" ? PART.paint : PART.trim;
      if (j === 3) return fx < 0.24 ? PART.plate : body.bed === "service" ? PART.metal : PART.paint;
      if (j === 2) return PART.trim;
      return PART.paint;
    }
    // Corners: lamps wrap a little around the sides.
    if (j === 4 && end > 0.35) return front ? PART.head_lamp : PART.tail_lamp;
    if (body.cladding > 0 && (j === 2 || (inArch && j === 3))) return PART.trim;
    if (j >= 2 && j <= 5 && seams.some((seam) => Math.abs(zf - seam) < SEAM_HALF_M * 1.5)) return PART.trim;
    return PART.paint;
  };
  const tubAo = (k, j) => (j <= 1 ? 0.35 : j === 2 ? 0.7 : j === 3 ? 0.88 : 1);
  out.loft(grid, tubPart, { aoOf: tubAo });

  // --- Glasshouse: from the windshield base to the rear glass base.
  // Roof line: a nearly straight windshield easing into an arched roof, then
  // the rear glass down to the deck.
  const cowl = fns.top(cab.windshield_base);
  const tailTop = fns.top(cab.rear_base);
  const roofLine = curve([
    [cab.windshield_base, cowl],
    [lerp(cab.windshield_base, cab.windshield_top, 0.3), lerp(cowl, cab.roof, 0.34)],
    [lerp(cab.windshield_base, cab.windshield_top, 0.7), lerp(cowl, cab.roof, 0.78)],
    [cab.windshield_top, cab.roof - 0.03],
    [lerp(cab.windshield_top, cab.roof_end, 0.42), cab.roof],
    [cab.roof_end, cab.roof - cab.rear_drop],
    [lerp(cab.roof_end, cab.rear_base, 0.5), lerp(cab.roof - cab.rear_drop, tailTop, 0.52)],
    [cab.rear_base, tailTop],
  ]);
  const roofCurve = (zf) => Math.max(fns.top(zf), roofLine(clamp(zf, cab.windshield_base, cab.rear_base)));
  const gStations = [];
  const gz = [cab.windshield_base, cab.windshield_top, cab.roof_end, cab.rear_base];
  const glassSteps = lod.glass[0];
  for (let i = 0; i <= glassSteps; i += 1) gStations.push(lerp(cab.windshield_base, cab.windshield_top, i / glassSteps));
  const roofSteps = lodIndex === 0 ? Math.max(3, Math.ceil((cab.roof_end - cab.windshield_top) / 0.45)) : 2;
  for (let i = 1; i < roofSteps; i += 1) gStations.push(lerp(cab.windshield_top, cab.roof_end, i / roofSteps));
  const rearSteps = lod.glass[1];
  for (let i = 0; i <= rearSteps; i += 1) gStations.push(lerp(cab.roof_end, cab.rear_base, i / rearSteps));
  const pillarEdges = [];
  if (body.pillars.b) pillarEdges.push(body.pillars.b - 0.07, body.pillars.b + 0.07);
  if (body.pillars.c) pillarEdges.push(body.pillars.c - 0.08, body.pillars.c + 0.08);
  if (body.pillars.cargo_from) pillarEdges.push(body.pillars.cargo_from);
  const glassZ = [...new Set([...gStations, ...pillarEdges, ...gz].map((z) => Math.round(z * 1000) / 1000))]
    .filter((z) => z >= cab.windshield_base && z <= cab.rear_base)
    .sort((a, b) => a - b);
  const gGrid = glassZ.map((zf) => {
    const hw = fns.halfWidth(zf);
    const belt = fns.top(zf);
    const roof = roofCurve(zf);
    const H = Math.max(0, roof - belt);
    const bottomHalf = hw * 0.925;
    const roofHalf = Math.min(bottomHalf, hw - cab.tumblehome);
    const g = (x, y) => v3(x, y, zOf(zf));
    // Collapse cleanly where the glasshouse has no height.
    const seal = Math.min(0.025, H * 0.2);
    return [
      g(bottomHalf, belt),
      g(lerp(bottomHalf, roofHalf, seal / Math.max(H, 1e-6)), belt + seal),
      g(lerp(bottomHalf, roofHalf, 0.45) + 0.012 * Math.min(1, H / 0.3), belt + H * 0.45),
      g(roofHalf + 0.004, belt + Math.max(0, H - 0.05)),
      g(Math.max(0, roofHalf - 0.07), belt + Math.max(0, H - 0.006)),
      g(roofHalf * 0.5, belt + H + cab.crown * 0.75 * Math.min(1, H / 0.2)),
      g(0, belt + H + cab.crown * Math.min(1, H / 0.2)),
    ];
  });
  const inWindow = (zf) => {
    if (body.pillars.cargo_from && zf > body.pillars.cargo_from) return false;
    if (body.pillars.b && Math.abs(zf - body.pillars.b) < 0.07) return false;
    if (body.pillars.c && Math.abs(zf - body.pillars.c) < 0.08) return body.pillars.quarter_glass ? false : false;
    if (!body.pillars.quarter_glass && body.pillars.c === null) {
      // Sedans and hatches: the last side window ends where the rear glass starts to fall.
      return zf < cab.roof_end + 0.1;
    }
    return zf < cab.rear_base - 0.16;
  };
  const glassPart = (k, j) => {
    const zf = (glassZ[k] + glassZ[k + 1]) / 2;
    const windshield = zf < cab.windshield_top;
    const rear = zf > cab.roof_end;
    // The black seal along the bottom of the side glass.
    if (j === 0) return windshield && zf < cab.windshield_base + 0.12 ? PART.paint : PART.trim;
    j -= 1;
    if (j <= 1) {
      // Side glass, the pillars in body colour or black.
      if (windshield) return zf > cab.windshield_base + 0.12 ? PART.glass : PART.paint;
      if (body.pillars.b && Math.abs(zf - body.pillars.b) < 0.07) return PART.trim;
      return inWindow(zf) ? PART.glass : PART.paint;
    }
    if (j === 2) return windshield ? PART.paint : PART.roof;
    if (windshield) return PART.glass;
    if (rear) return PART.glass;
    return body.glass_roof ? PART.glass : PART.roof;
  };
  out.loft(gGrid, glassPart, { crease: 40 });

  // --- Wheels (centres from carBodyGeometry). Without wheels (the drivable
  // car's chassis, carKitExtras) the wells keep their liners.
  const R = body.wheel_radius;
  const tw = body.tire_width;
  const xOut = W - WHEEL_INSET_M;
  for (const axle of axles) {
    for (const side of [1, -1]) {
      if (wheels) addWheel(out, body, lodIndex, v3(side * (xOut - tw / 2), R, zOf(axle)), side);
      // Wheel-well liner behind the tyre, so the well reads dark and closed.
      const innerX = side * (xOut - tw - 0.05);
      const top = R + archRadius;
      const wellNormal = v3(side, 0, 0);
      const z0 = zOf(axle - archRadius);
      const z1 = zOf(axle + archRadius);
      const a = v3(innerX, 0.12, z0);
      const b = v3(innerX, 0.12, z1);
      const c = v3(innerX, top, z1);
      const d = v3(innerX, top, z0);
      const cr = vcross(vsub(b, a), vsub(c, a));
      if (vdot(cr, wellNormal) >= 0) out.quad(a, b, c, d, null, PART.under, [0.3, 0.3, 0.3, 0.3]);
      else out.quad(a, d, c, b, null, PART.under, [0.3, 0.3, 0.3, 0.3]);
    }
  }

  // --- Mirrors, roof rails, bed.
  if (lod.mirrors) {
    const zf = cab.windshield_base + 0.3;
    const belt = fns.top(zf);
    for (const side of [1, -1]) {
      const hw = fns.halfWidth(zf);
      // Housing on a short stalk at the front corner of the side glass; its
      // back (toward the rear) is the mirror glass.
      const inner = hw * 0.9;
      const outer = hw + MIRROR_REACH_M;
      out.box(v3(side * ((inner + outer) / 2), belt + 0.07, zOf(zf)), [(outer - inner) / 2, 0.052, 0.04], (face) => (face === "+z" ? PART.glass : PART.paint));
      out.box(v3(side * (hw * 0.93), belt + 0.015, zOf(zf + 0.02)), [hw * 0.03 + 0.02, 0.02, 0.05], PART.trim);
    }
  }
  if (lodIndex === 0) {
    // Door handles: short dark bars near the rear edge of each door.
    const seams2 = doorSeams(body);
    for (let i = 1; i < seams2.length; i += 1) {
      const zf = seams2[i] - 0.24;
      const y = fns.top(zf) - 0.1;
      const hw = fns.halfWidth(zf);
      for (const side of [1, -1]) out.box(v3(side * (hw + 0.004), y, zOf(zf)), [0.012, 0.016, 0.07], PART.trim);
    }
  }
  if (body.roof_rails) {
    const z0 = cab.windshield_top + 0.15;
    const z1 = cab.roof_end - 0.08;
    const zm = (z0 + z1) / 2;
    for (const side of [1, -1]) {
      const hw = fns.halfWidth(zm);
      const x = side * (Math.min(hw * 0.925, hw - cab.tumblehome) - 0.05);
      const yAt = (zf) => roofCurve(zf) + 0.02;
      const len = z1 - z0;
      const dir = vnorm(v3(0, yAt(z1) - yAt(z0), len));
      out.box(v3(x, (yAt(z0) + yAt(z1)) / 2 + 0.03, zOf(zm)), [0.025, 0.022, len / 2], PART.trim, [v3(1, 0, 0), vnorm(vcross(dir, v3(1, 0, 0))), dir]);
    }
  }
  if (body.bed === "service" && lodIndex === 0) {
    // Compartment doors on the service body: dark seams as thin trim strips.
    for (const side of [1, -1]) {
      for (const zf of [4.3, 5.0, 5.75]) {
        out.box(v3(side * (W + 0.004), 0.98, zOf(zf)), [0.006, 0.4, 0.012], PART.trim);
      }
      out.box(v3(side * (W + 0.005), 1.42, zOf(5.0)), [0.006, 0.012, 1.15], PART.chrome);
    }
  }
  if (body.bed === "tonneau" && lodIndex === 0) {
    // Bed rails.
    for (const side of [1, -1]) out.box(v3(side * (W - 0.06), 1.24, zOf(4.85)), [0.04, 0.02, 0.98], PART.trim);
  }

  return out.result();
}

// One wheel: the tyre's outer half (the inner half is hidden in the wheel well)
// and the rim face with its spokes, round the axis (side, 0, 0) through centre,
// its face toward side. The parked cars' wheels and the drivable car's are the same.
function addWheel(out, body, lodIndex, center, side) {
  const lod = LODS[lodIndex];
  const R = body.wheel_radius;
  const tw = body.tire_width;
  const axis = v3(side, 0, 0);
  const rimR = R * 0.64;
  const profile = lodIndex === 0
    ? [[R - 0.01, -tw / 2], [R, -tw / 2 + 0.05], [R, tw / 2 - 0.06], [R - 0.014, tw / 2 - 0.022], [R - 0.055, tw / 2], [rimR, tw / 2], [rimR * 0.97, tw / 2 - 0.02]]
    : [[R, -tw / 2], [R, tw / 2 - 0.04], [R - 0.05, tw / 2], [rimR, tw / 2]];
  const rimSegment = profile.length - 2;
  out.lathe(center, axis, profile, lod.sides, (i) => (i >= rimSegment ? PART.rim : PART.tire), Math.PI / lod.sides, (i) => (i <= 1 ? 0.85 : 1));
  // Rim face: spokes (rim colour) and the dark gaps between them.
  const face = vadd(center, vscale(axis, tw / 2 - 0.02));
  const helper = v3(0, 1, 0);
  const u = vnorm(vcross(axis, helper));
  const w = vcross(axis, u);
  const at = (r, angle, depth = 0) => vadd(face, vadd(vscale(axis, -depth), vadd(vscale(u, r * Math.cos(angle)), vscale(w, r * Math.sin(angle)))));
  const segments = lod.spokes ? 15 : 8;
  const rings = lod.spokes ? [0.0, 0.17, 0.86, 0.98] : [0.0, 0.98];
  for (let s = 0; s < segments; s += 1) {
    const a0 = (2 * Math.PI * s) / segments;
    const a1 = (2 * Math.PI * (s + 1)) / segments;
    for (let r = 0; r < rings.length - 1; r += 1) {
      const spoke = lod.spokes ? s % 3 === 0 : true;
      const part = r === 0 ? PART.hub : r === rings.length - 2 ? PART.rim : spoke ? PART.rim : PART.hub;
      const depth = part === PART.hub && r > 0 ? 0.03 : r === 0 ? -0.005 : 0;
      const a = at(rimR * rings[r], a0, depth);
      const b = at(rimR * rings[r], a1, depth);
      const c = at(rimR * rings[r + 1], a1, depth);
      const d = at(rimR * rings[r + 1], a0, depth);
      const n = axis;
      // Counterclockwise seen from outside along +axis.
      const cr = vcross(vsub(b, a), vsub(c, a));
      if (vdot(cr, n) >= 0) out.quad(a, b, c, d, [n, n, n, n], part);
      else out.quad(a, d, c, b, [n, n, n, n], part);
    }
  }
}

// One right-hand wheel of a body round the origin, its face toward +X: the
// drivable car turns it about Y for the left side and spins it on X.
export function buildCarTyre(name, lodIndex) {
  const out = new MeshBuilder();
  addWheel(out, CAR_BODIES[name], lodIndex, v3(0, 0, 0), 1);
  return out.result();
}

// ---------------------------------------------------------------- small props
// A 28 inch traffic cone: orange body, two white reflective collars, black base.
function buildCone(lodIndex) {
  const out = new MeshBuilder();
  const sides = lodIndex === 0 ? 14 : 7;
  const base = 0.36 / 2;
  out.box(v3(0, 0.015, 0), [base, 0.015, base], PART.trim);
  const profile = [
    [0.13, 0.03],
    [0.115, 0.17],
    [0.1, 0.27],
    [0.088, 0.36],
    [0.078, 0.44],
    [0.068, 0.52],
    [0.042, 0.69],
    [0.03, 0.71],
    [0.0, 0.71],
  ];
  const partOf = (i) => (i === 2 || i === 4 ? PART.white : PART.orange);
  // The lathe axis is +Y; the profile is [radius, height].
  out.lathe(v3(0, 0, 0), v3(0, 1, 0), profile, sides, partOf);
  return out.result();
}

// A type I A-frame barricade: two hinged galvanised frames with one orange and
// white striped board across the top on each face (Ave of the Palms, Sep 2025).
function buildBarricade(lodIndex) {
  const out = new MeshBuilder();
  const width = 0.62;
  const height = 1.02;
  const spread = 0.36;
  const tilt = Math.atan2(spread / 2, height);
  for (const side of [1, -1]) {
    const lean = v3(0, Math.cos(tilt), side * Math.sin(tilt));
    const across = v3(1, 0, 0);
    const normal = vnorm(vcross(across, lean));
    const axes = [across, lean, vscale(normal, side)];
    for (const x of [-width / 2 + 0.02, width / 2 - 0.02]) {
      const foot = v3(x, 0, side * spread / 2);
      out.box(vadd(foot, vscale(lean, height / 2)), [0.017, height / 2, 0.012], PART.metal, axes);
    }
    // Board: alternating orange and white diagonal-looking blocks.
    const boardCenter = vadd(v3(0, 0, side * spread / 2), vscale(lean, height - 0.17));
    const stripes = lodIndex === 0 ? 6 : 2;
    for (let i = 0; i < stripes; i += 1) {
      const x0 = -width / 2 + (width * i) / stripes;
      const cx = x0 + width / stripes / 2;
      out.box(vadd(boardCenter, vadd(vscale(across, cx), vscale(axes[2], 0.014))), [width / stripes / 2, 0.1, 0.009], i % 2 === 0 ? PART.orange : PART.white, axes);
    }
    // A white sign panel lower down, facing outward.
    out.box(vadd(v3(0, 0, side * spread / 2), vadd(vscale(lean, 0.55), vscale(axes[2], 0.014))), [0.26, 0.19, 0.006], PART.white, axes);
  }
  return out.result();
}

// A two-yard front-load dumpster on casters (the Mersea lot, Sep 2025 photos:
// three grey steel bins at the lot's west end): a box with a vertical back and a
// front that leans out toward the top, two lids falling toward the front, fork
// sleeves along both sides and a white label on the front. The body takes the
// instance paint (a matte finish), the lids (the roof part) the body's or their
// own (params.lid: a darker grey, or green plastic); about 1.8 m wide, 1.3 m deep at the
// top and 1.25 m tall, production inference from the photos and common
// two-yard bins, not measured. Front (the leaning side) toward -Z.
export const DUMPSTER_SIZE = Object.freeze({ width_m: 1.8, back_z: 0.55, front_bottom_z: -0.45, front_top_z: -0.72, base_y: 0.17, back_top_y: 1.22, front_top_y: 1.06 });
function buildDumpster(lodIndex) {
  const out = new MeshBuilder();
  const { width_m: width, back_z: zb, front_bottom_z: zf0, front_top_z: zf1, base_y: y0, back_top_y: yb, front_top_y: yf } = DUMPSTER_SIZE;
  const hx = width / 2;
  const sideProfile = [v3(0, y0, zb), v3(0, yb, zb), v3(0, yf, zf1), v3(0, y0, zf0)];
  const at = (point, x) => v3(x, point[1], point[2]);
  // Back, lid deck, leaning front and bottom: quads across the width.
  for (let index = 0; index < 4; index += 1) {
    const a = sideProfile[index];
    const b = sideProfile[(index + 1) % 4];
    const tangent = vnorm(vsub(b, a));
    // Outward in the (z, y) plane: the profile runs clockwise seen from +X.
    const normal = vnorm(v3(0, -tangent[2], tangent[1]));
    const corners = [at(a, -hx), at(b, -hx), at(b, hx), at(a, hx)];
    const n = vcross(vsub(corners[1], corners[0]), vsub(corners[2], corners[0]));
    const part = index === 1 ? PART.paint : PART.paint;
    if (vdot(n, normal) >= 0) out.quad(corners[0], corners[1], corners[2], corners[3], [normal, normal, normal, normal], part, index === 3 ? [0.4, 0.4, 0.4, 0.4] : [1, 1, 1, 1]);
    else out.quad(corners[0], corners[3], corners[2], corners[1], [normal, normal, normal, normal], part, index === 3 ? [0.4, 0.4, 0.4, 0.4] : [1, 1, 1, 1]);
  }
  // The two sides: the quad of the profile at each end.
  for (const side of [1, -1]) {
    const normal = v3(side, 0, 0);
    const corners = sideProfile.map((point) => at(point, side * hx));
    const n = vcross(vsub(corners[1], corners[0]), vsub(corners[2], corners[0]));
    if (vdot(n, normal) >= 0) out.quad(corners[0], corners[1], corners[2], corners[3], [normal, normal, normal, normal], PART.paint, [0.85, 1, 1, 0.85]);
    else out.quad(corners[0], corners[3], corners[2], corners[1], [normal, normal, normal, normal], PART.paint, [0.85, 0.85, 1, 1]);
  }
  // Lids: two plates along the deck, a little proud of it and over the front, with a dark seam between.
  const deck = vnorm(vsub(sideProfile[2], sideProfile[1]));
  const deckNormal = vnorm(v3(0, -deck[2], deck[1]));
  const deckLength = vlen(vsub(sideProfile[2], sideProfile[1]));
  const deckMiddle = vscale(vadd(sideProfile[1], sideProfile[2]), 0.5);
  const lidAxes = [v3(1, 0, 0), deckNormal, deck];
  for (const side of [1, -1]) {
    out.box(vadd(vadd(deckMiddle, vscale(deckNormal, 0.025)), vadd(v3(side * hx / 2, 0, 0), vscale(deck, 0.03))), [hx / 2 - 0.02, 0.018, deckLength / 2 + 0.03], PART.roof, lidAxes);
  }
  out.box(vadd(deckMiddle, vscale(deckNormal, 0.012)), [0.03, 0.012, deckLength / 2], PART.trim, lidAxes);
  // Fork sleeves along both sides.
  for (const side of [1, -1]) out.box(v3(side * (hx + 0.045), 0.86, (zb + zf0) / 2 - 0.02), [0.045, 0.075, (zb - zf0) / 2 + 0.06], PART.paint);
  // The white label on the leaning front.
  const front = vnorm(vsub(sideProfile[2], sideProfile[3]));
  const frontNormal = vnorm(v3(0, front[2], -front[1]));
  const frontMiddle = vadd(vscale(vadd(sideProfile[2], sideProfile[3]), 0.5), v3(0.45, 0, 0));
  out.box(vadd(frontMiddle, vscale(frontNormal, 0.006)), [0.2, 0.004, 0.14], PART.white, [v3(1, 0, 0), frontNormal, front]);
  // Casters: a bracket and a dark wheel under each corner.
  for (const x of [-hx + 0.16, hx - 0.16]) {
    for (const z of [zb - 0.16, zf0 + 0.16]) {
      if (lodIndex === 0) out.box(v3(x, y0 - 0.035, z), [0.05, 0.035, 0.05], PART.metal);
      out.box(v3(x, 0.065, z), [0.03, 0.065, 0.065], PART.tire);
    }
  }
  return out.result();
}

// A galvanised oval stock tank used as a planter, on a wooden pallet (the
// Mersea lot, Sep 2025: a row of eight along the strip's fence): an 8 x 2.5 ft
// tank 2 ft deep with a rolled rim and three ribs, filled with soil to a hand
// below the rim (the dark tyre part). The pallet takes the instance paint
// (matte, its weathered wood). Production inference from the photos and the
// common stock tank sizes, not measured. Long axis along Z.
export const STOCK_TANK_SIZE = Object.freeze({ length_m: 2.44, width_m: 0.76, height_m: 0.61, pallet_m: 0.14, pallet_length_m: 2.5, pallet_width_m: 1.0 });
// The tank's soil below its rim, and above the ground (a plant in it stands there).
const STOCK_TANK_SOIL_DROP_M = 0.08;
export const STOCK_TANK_SOIL_M = STOCK_TANK_SIZE.pallet_m + STOCK_TANK_SIZE.height_m - STOCK_TANK_SOIL_DROP_M;
function buildStockTankPlanter(lodIndex) {
  const out = new MeshBuilder();
  const { length_m: length, width_m: width, height_m: height, pallet_m: pallet, pallet_length_m: palletLength, pallet_width_m: palletWidth } = STOCK_TANK_SIZE;
  const radius = width / 2;
  const straight = (length - width) / 2;
  const arc = lodIndex === 0 ? 8 : 4;
  // The tank's outline (x, z) counter-clockwise seen from above, with outward directions.
  const outline = [];
  // The back half circle round (0, +straight), then the front one round (0, -straight).
  for (const [centre, start] of [[straight, 0], [-straight, Math.PI]]) {
    for (let k = 0; k <= arc; k += 1) {
      const angle = start + (Math.PI * k) / arc;
      outline.push({ x: radius * Math.cos(angle), z: centre + radius * Math.sin(angle), nx: Math.cos(angle), nz: Math.sin(angle) });
    }
  }
  const y0 = pallet;
  const y1 = pallet + height;
  const ring = (offset, y) => outline.map((p) => v3(p.x + p.nx * offset, y, p.z + p.nz * offset));
  const normals = outline.map((p) => v3(p.nx, 0, p.nz));
  // A band of the wall between two heights at an outward offset, facing out (or in).
  const band = (offset, yLow, yHigh, part, inward = false, ao = [1, 1]) => {
    const low = ring(offset, yLow);
    const high = ring(offset, yHigh);
    for (let k = 0; k < outline.length; k += 1) {
      const next = (k + 1) % outline.length;
      const n = [normals[k], normals[next]].map((normal) => (inward ? vscale(normal, -1) : normal));
      const corners = [low[k], low[next], high[next], high[k]];
      const facing = vcross(vsub(corners[1], corners[0]), vsub(corners[2], corners[0]));
      const want = vadd(n[0], n[1]);
      const aoQuad = [ao[0], ao[0], ao[1], ao[1]];
      if (vdot(facing, want) >= 0) out.quad(corners[0], corners[1], corners[2], corners[3], [n[0], n[1], n[1], n[0]], part, aoQuad);
      else out.quad(corners[0], corners[3], corners[2], corners[1], [n[0], n[0], n[1], n[1]], part, [aoQuad[0], aoQuad[3], aoQuad[2], aoQuad[1]]);
    }
  };
  // A flat ring between two outward offsets at one height, facing up.
  const flat = (inner, outer, y, part) => {
    const a = ring(inner, y);
    const b = ring(outer, y);
    for (let k = 0; k < outline.length; k += 1) {
      const next = (k + 1) % outline.length;
      const up = v3(0, 1, 0);
      const corners = [a[k], a[next], b[next], b[k]];
      const facing = vcross(vsub(corners[1], corners[0]), vsub(corners[2], corners[0]));
      if (vdot(facing, up) >= 0) out.quad(corners[0], corners[1], corners[2], corners[3], [up, up, up, up], part);
      else out.quad(corners[0], corners[3], corners[2], corners[1], [up, up, up, up], part);
    }
  };
  band(0, y0, y1, PART.metal, false, [0.62, 1]);
  if (lodIndex === 0) {
    for (const rib of [0.14, 0.3, 0.46]) {
      band(0.01, y0 + rib - 0.02, y0 + rib + 0.02, PART.metal, false, [0.85, 1]);
      flat(0, 0.01, y0 + rib + 0.02, PART.metal);
    }
  }
  // Rolled rim: out, over the top and back down the inside to the soil.
  band(0.014, y1 - 0.035, y1 + 0.01, PART.metal);
  flat(-0.006, 0.014, y1 + 0.01, PART.metal);
  const soil = y1 - STOCK_TANK_SOIL_DROP_M;
  band(-0.006, soil, y1 + 0.01, PART.metal, true, [0.55, 0.9]);
  // The soil: a fan over the inside of the outline.
  const surface = ring(-0.006, soil);
  const centre = v3(0, soil, 0);
  const up = v3(0, 1, 0);
  for (let k = 0; k < outline.length; k += 1) {
    const next = (k + 1) % outline.length;
    const facing = vcross(vsub(surface[k], centre), vsub(surface[next], centre));
    if (vdot(facing, up) >= 0) out.triangle(centre, surface[k], surface[next], [up, up, up], PART.tire, [0.8, 0.95, 0.95]);
    else out.triangle(centre, surface[next], surface[k], [up, up, up], PART.tire, [0.8, 0.95, 0.95]);
  }
  // The pallet: deck boards across it over three runners (one box far away).
  if (lodIndex === 0) {
    for (const x of [-palletWidth / 2 + 0.05, 0, palletWidth / 2 - 0.05]) out.box(v3(x, 0.05, 0), [0.04, 0.05, palletLength / 2], PART.paint);
    const boards = 9;
    for (let k = 0; k < boards; k += 1) {
      const z = -palletLength / 2 + 0.06 + ((palletLength - 0.12) * k) / (boards - 1);
      out.box(v3(0, pallet - 0.02, z), [palletWidth / 2, 0.02, 0.05], PART.paint);
    }
  } else {
    out.box(v3(0, pallet / 2, 0), [palletWidth / 2, pallet / 2, palletLength / 2], PART.paint);
  }
  return out.result();
}

export const CLUTTER_PROPS_KIT = Object.freeze({
  traffic_cone: { build: buildCone },
  barricade: { build: buildBarricade },
  dumpster: { build: buildDumpster },
  stock_tank_planter: { build: buildStockTankPlanter },
});

export const CLUTTER_LOD_COUNT = LODS.length;

// Every mesh of the kit, by name: car_<body>_lod<n> and <prop>_lod<n>.
export function clutterKitMeshes() {
  const meshes = [];
  for (const name of Object.keys(CAR_BODIES)) {
    for (let lod = 0; lod < LODS.length; lod += 1) meshes.push({ name: `car_${name}_lod${lod}`, ...buildCar(name, lod) });
  }
  for (const [name, prop] of Object.entries(CLUTTER_PROPS_KIT)) {
    for (let lod = 0; lod < LODS.length; lod += 1) meshes.push({ name: `${name}_lod${lod}`, ...prop.build(lod) });
  }
  return [...meshes, ...carKitExtras()];
}

// The drivable car's parts of each body (game/scripts/vehicles/drivable_car.gd),
// after the parked meshes so those stay as they were: the chassis without its
// wheels, one wheel round the origin (named tyre: Godot's importer turns a node
// whose name ends in "wheel" into a VehicleWheel3D) and two empty nodes at the
// right-hand front and rear wheel centres (the left ones mirror them in x).
export function carKitExtras() {
  const extras = [];
  for (const name of Object.keys(CAR_BODIES)) {
    const geometry = carBodyGeometry(name);
    extras.push({ name: `car_${name}_chassis_lod0`, ...buildCar(name, 0, { wheels: false }) });
    extras.push({ name: `car_${name}_tyre_lod0`, ...buildCarTyre(name, 0) });
    extras.push({ name: `car_${name}_axle_front`, marker: true, translation: [...geometry.wheels.front_right] });
    extras.push({ name: `car_${name}_axle_rear`, marker: true, translation: [...geometry.wheels.rear_right] });
  }
  return extras;
}

// Key dimensions of a car body, in one place for whatever places (or later
// drives) a car. Car frame in metres: origin on the ground under the middle of
// the body's plan rectangle, +Y up, front -Z, +X the right side. length_m and
// width_m are the body's plan rectangle (mirrors excluded); the track is
// between the tyre centre planes; each wheel centre is [x, y, z] in the car
// frame; bounds_m is the near mesh's box (mirrors and roof rails included).
const geometryCache = new Map();
export function carBodyGeometry(name) {
  if (geometryCache.has(name)) return geometryCache.get(name);
  const body = CAR_BODIES[name];
  if (!body) throw new Error(`Unknown car body ${name}`);
  const round = (value) => Math.round(value * 1e4) / 1e4;
  const wheelX = round(body.width / 2 - WHEEL_INSET_M - body.tire_width / 2);
  const frontZ = round(body.front_overhang - body.length / 2);
  const rearZ = round(frontZ + body.wheelbase);
  const centre = (x, z) => Object.freeze([x, body.wheel_radius, z]);
  const { positions } = buildCar(name, 0);
  const min = [Infinity, Infinity, Infinity];
  const max = [-Infinity, -Infinity, -Infinity];
  for (let index = 0; index < positions.length; index += 3) {
    for (let axis = 0; axis < 3; axis += 1) {
      min[axis] = Math.min(min[axis], positions[index + axis]);
      max[axis] = Math.max(max[axis], positions[index + axis]);
    }
  }
  const geometry = Object.freeze({
    length_m: body.length,
    width_m: body.width,
    height_m: round(max[1]),
    wheelbase_m: body.wheelbase,
    track_m: round(2 * wheelX),
    wheel_radius_m: body.wheel_radius,
    tire_width_m: body.tire_width,
    ground_clearance_m: body.clearance,
    wheels: Object.freeze({
      front_left: centre(-wheelX, frontZ),
      front_right: centre(wheelX, frontZ),
      rear_left: centre(-wheelX, rearZ),
      rear_right: centre(wheelX, rearZ),
    }),
    bounds_m: Object.freeze({ min: Object.freeze(min.map(round)), max: Object.freeze(max.map(round)) }),
  });
  geometryCache.set(name, geometry);
  return geometry;
}
