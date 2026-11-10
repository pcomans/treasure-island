// The street cars: nine generic bodies ("typical 2020s Bay Area", no make),
// each built from one parameter row at several detail levels:
//
//   hero    the driven car and the parked cars nearest the camera: body with
//           cabin and underbody, see-through glass, one wheel and one brake
//           (drawn four times), in street_car_hero_kit.glb (desktop only)
//   near    one mesh, wheels and all, opaque glass (car_<body>_lod0), and the
//           same without wheels plus one wheel for a driven car on the web
//   mid     the yard kit's cargo van (tools/lib/street-yard-meshes.mjs)
//   far     about a thousand triangles (car_<body>_lod1)
//   shadow  the far body drawn a little inside the surface: what casts a car's
//           shadow at the hero and near levels (car_<body>_shadow)
//
// The body is one smooth surface, not an extruded profile. A wall is swept
// round the plan outline (rounded superellipse corners, a bowed nose and tail)
// with a side section that tucks under at the sill, is widest at mid height and
// rolls in at the shoulder; a lid over it is a height field: the hood, roof and
// deck line with their crown, cut by the side-glass plane with a rounded roof
// rail between them. Normals come from that surface, not from the triangles,
// so reflections flow across it at every level. Everything drawn on it
// (windows, lamps, grille, panel gaps, cladding, wheel arches) is a region cut
// into the mesh along its own outline, so edges are crisp at any tessellation.
//
// Car frame in metres: origin on the ground under the middle of the body's
// plan rectangle, +Y up, front -Z, +X the right side. zf is the distance from
// the front bumper (z + length / 2).

import { clamp, curve, lerp, smooth, v3, vadd, vcross, vdot, vlen, vnorm, vscale, vsub } from "./kit-mesh.mjs";
import { CALIPER_ANGLE, CAR_PART_AS_BASE, CAR_PART_COUNT, CAR_PARTS, CarMesh, P, buildBrake, buildCabin, buildUnderbody, buildWheel } from "./street-car-parts.mjs";

export { CALIPER_ANGLE, CAR_PART_COUNT, CAR_PARTS };

// ---------------------------------------------------------------- car bodies
// Lengths in metres. Profiles run from the front bumper (0) to the rear (length).
//   height: the top of the car (the roof's crown, or the roof rails)
//   hood: [distance from front, top of the body] from the front face to the windshield base
//   cabin: windshield base and top, roof end, rear glass base, roof height and crown
//   deck: [distance, top] behind the cabin (trunk, bed or tailgate top)
//   nose/tail: bumper bottom, face lean (top set back), corner radius in plan
// Dimensions are production inference: typical 2020s Bay Area models
// photographed parked in the pilot zones (Sep and Nov 2025 Street View).
export const CAR_BODIES = Object.freeze({
  // Compact crossover SUV: the commonest parked car in the photos.
  crossover: {
    length: 4.62, width: 1.87, height: 1.715, wheelbase: 2.76, front_overhang: 0.9, wheel_radius: 0.36, tire_width: 0.24, clearance: 0.2,
    nose: { bumper_bottom: 0.3, lean: 0.16, corner: 0.42, face_top: 0.84 },
    tail: { bumper_bottom: 0.36, lean: 0.05, corner: 0.36, face_top: 1.04 },
    hood: [[0.0, 0.84], [0.35, 0.93], [1.0, 1.0], [1.35, 1.04]],
    belt: [[1.35, 1.04], [3.6, 1.1], [4.55, 1.08]],
    deck: [[4.55, 1.08], [4.62, 1.04]],
    cabin: { windshield_base: 1.35, windshield_top: 2.18, roof_end: 4.25, rear_base: 4.58, roof: 1.66, crown: 0.025, tumblehome: 0.2, rear_drop: 0.07 },
    pillars: { b: 2.72, c: 3.55, quarter_glass: true },
    cladding: 0.33, roof_rails: true, grille: "wide",
  },
  // Larger three-row SUV / minivan class.
  suv: {
    length: 4.98, width: 1.95, height: 1.8133, wheelbase: 2.9, front_overhang: 0.98, wheel_radius: 0.375, tire_width: 0.25, clearance: 0.21,
    nose: { bumper_bottom: 0.32, lean: 0.14, corner: 0.42, face_top: 0.92 },
    tail: { bumper_bottom: 0.38, lean: 0.04, corner: 0.34, face_top: 1.08 },
    hood: [[0.0, 0.92], [0.4, 1.0], [1.15, 1.08], [1.42, 1.1]],
    belt: [[1.42, 1.1], [4.0, 1.15], [4.9, 1.13]],
    deck: [[4.9, 1.13], [4.98, 1.08]],
    cabin: { windshield_base: 1.42, windshield_top: 2.25, roof_end: 4.7, rear_base: 4.94, roof: 1.76, crown: 0.025, tumblehome: 0.19, rear_drop: 0.05 },
    pillars: { b: 2.8, c: 3.75, quarter_glass: true },
    cladding: 0.28, roof_rails: true, grille: "wide",
  },
  // Mid-size sedan.
  sedan: {
    length: 4.82, width: 1.83, height: 1.46, wheelbase: 2.82, front_overhang: 0.95, wheel_radius: 0.335, tire_width: 0.225, clearance: 0.15,
    nose: { bumper_bottom: 0.25, lean: 0.18, corner: 0.34, face_top: 0.7 },
    tail: { bumper_bottom: 0.3, lean: 0.1, corner: 0.32, face_top: 0.98 },
    hood: [[0.0, 0.7], [0.35, 0.79], [1.0, 0.87], [1.42, 0.93]],
    belt: [[1.42, 0.93], [3.35, 1.01]],
    deck: [[3.98, 1.03], [4.55, 1.04], [4.82, 1.0]],
    cabin: { windshield_base: 1.42, windshield_top: 2.3, roof_end: 3.35, rear_base: 3.98, roof: 1.44, crown: 0.02, tumblehome: 0.21, rear_drop: 0.06 },
    pillars: { b: 2.78, c: null, quarter_glass: false },
    cladding: 0, roof_rails: false, grille: "sedan",
  },
  // EV fastback sedan: short nose, no grille, long glass roof.
  fastback: {
    length: 4.72, width: 1.85, height: 1.455, wheelbase: 2.88, front_overhang: 0.85, wheel_radius: 0.34, tire_width: 0.235, clearance: 0.14,
    nose: { bumper_bottom: 0.24, lean: 0.22, corner: 0.38, face_top: 0.66 },
    tail: { bumper_bottom: 0.3, lean: 0.08, corner: 0.34, face_top: 0.98 },
    hood: [[0.0, 0.66], [0.3, 0.75], [0.8, 0.83], [1.22, 0.89]],
    belt: [[1.22, 0.89], [3.4, 0.99]],
    deck: [[4.3, 1.02], [4.55, 1.03], [4.72, 0.99]],
    cabin: { windshield_base: 1.22, windshield_top: 2.15, roof_end: 3.3, rear_base: 4.3, roof: 1.43, crown: 0.025, tumblehome: 0.22, rear_drop: 0.07 },
    pillars: { b: 2.72, c: null, quarter_glass: false },
    cladding: 0, roof_rails: false, grille: "none", glass_roof: true,
  },
  // Hatchback.
  hatchback: {
    length: 4.38, width: 1.79, height: 1.4798, wheelbase: 2.68, front_overhang: 0.9, wheel_radius: 0.32, tire_width: 0.215, clearance: 0.15,
    nose: { bumper_bottom: 0.26, lean: 0.18, corner: 0.35, face_top: 0.72 },
    tail: { bumper_bottom: 0.32, lean: 0.06, corner: 0.32, face_top: 1.0 },
    hood: [[0.0, 0.72], [0.35, 0.8], [0.95, 0.88], [1.36, 0.94]],
    belt: [[1.36, 0.94], [3.6, 1.02], [4.3, 1.01]],
    deck: [[4.3, 1.01], [4.38, 0.99]],
    cabin: { windshield_base: 1.36, windshield_top: 2.2, roof_end: 3.62, rear_base: 4.32, roof: 1.46, crown: 0.02, tumblehome: 0.2, rear_drop: 0.08 },
    pillars: { b: 2.62, c: null, quarter_glass: false },
    cladding: 0, roof_rails: false, grille: "sedan",
  },
  // Wagon (photographed silver at 5107 Ave of the Palms).
  wagon: {
    length: 4.86, width: 1.84, height: 1.6346, wheelbase: 2.75, front_overhang: 0.94, wheel_radius: 0.345, tire_width: 0.225, clearance: 0.2,
    nose: { bumper_bottom: 0.3, lean: 0.18, corner: 0.42, face_top: 0.8 },
    tail: { bumper_bottom: 0.36, lean: 0.05, corner: 0.36, face_top: 1.02 },
    hood: [[0.0, 0.8], [0.35, 0.88], [1.05, 0.95], [1.5, 0.99]],
    belt: [[1.5, 0.99], [4.0, 1.04], [4.8, 1.03]],
    deck: [[4.8, 1.03], [4.86, 0.99]],
    cabin: { windshield_base: 1.5, windshield_top: 2.36, roof_end: 4.5, rear_base: 4.82, roof: 1.58, crown: 0.02, tumblehome: 0.2, rear_drop: 0.08 },
    pillars: { b: 2.86, c: 3.72, quarter_glass: true },
    cladding: 0.24, roof_rails: true, grille: "sedan",
  },
  // Full-size pickup with a tonneau-covered bed.
  pickup: {
    length: 5.86, width: 2.0, height: 1.97, wheelbase: 3.68, front_overhang: 0.98, wheel_radius: 0.4, tire_width: 0.27, clearance: 0.24,
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
    length: 6.2, width: 2.03, height: 1.97, wheelbase: 3.68, front_overhang: 0.98, wheel_radius: 0.4, tire_width: 0.27, clearance: 0.24,
    nose: { bumper_bottom: 0.38, lean: 0.06, corner: 0.3, face_top: 1.12 },
    tail: { bumper_bottom: 0.5, lean: 0.0, corner: 0.06, face_top: 1.42 },
    hood: [[0.0, 1.12], [0.25, 1.18], [1.2, 1.22], [1.75, 1.25]],
    belt: [[1.75, 1.25], [3.78, 1.28]],
    deck: [[3.84, 1.5], [6.2, 1.5]],
    cabin: { windshield_base: 1.75, windshield_top: 2.38, roof_end: 3.7, rear_base: 3.8, roof: 1.95, crown: 0.02, tumblehome: 0.16, rear_drop: 0.03 },
    pillars: { b: 2.92, c: null, quarter_glass: false },
    cladding: 0.0, roof_rails: false, grille: "truck", bed: "service",
  },
  // High-roof cargo van (the dark van at 1 Avenue of the Palms).
  van: {
    length: 5.93, width: 2.02, height: 2.65, wheelbase: 3.66, front_overhang: 0.98, wheel_radius: 0.37, tire_width: 0.235, clearance: 0.2,
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
// housings reach this far beyond it. The nose and tail bow this far past the
// body's plan rectangle at the centre line.
const WHEEL_INSET_M = 0.035;
const MIRROR_REACH_M = 0.14;
const NOSE_BOW_M = 0.06;
const TAIL_BOW_M = 0.04;

// Detail levels: stations across each end face and round each corner, the
// station step along the sides, the wall's height fractions and the lid's
// points from shoulder to centre line.
const LEVELS = Object.freeze({
  hero: { face: 6, corner: 7, step: 0.11, wall: [0, 0.035, 0.09, 0.18, 0.3, 0.42, 0.54, 0.66, 0.77, 0.86, 0.93, 0.97, 1], lid: 12, detail: 3, wheel: "hero" },
  near: { face: 4, corner: 5, step: 0.19, wall: [0, 0.05, 0.14, 0.3, 0.48, 0.66, 0.82, 0.93, 1], lid: 8, detail: 2, wheel: "near" },
  mid: { face: 3, corner: 3, step: 0.34, wall: [0, 0.08, 0.3, 0.6, 0.88, 1], lid: 6, detail: 1, wheel: "mid" },
  far: { face: 2, corner: 2, step: 0.7, wall: [0, 0.3, 0.75, 1], lid: 4, detail: 0, wheel: "far" },
});
export const CAR_LEVELS = Object.freeze(Object.keys(LEVELS));

const smoothstep = (a, b, x) => smooth((x - a) / (b - a));
const smin = (a, b, k) => {
  const h = Math.max(k - Math.abs(a - b), 0) / k;
  return Math.min(a, b) - h * h * k * 0.25;
};
const smax = (a, b, k) => -smin(-a, -b, k);
// A rounded box's signed distance (negative inside).
const box2 = (px, py, hx, hy, r) => {
  const qx = Math.abs(px) - hx + r;
  const qy = Math.abs(py) - hy + r;
  return Math.min(Math.max(qx, qy), 0) + Math.hypot(Math.max(qx, 0), Math.max(qy, 0)) - r;
};
const BIG = 9;

// Door seams along the side, from the cabin layout: the front door's front edge
// behind the windshield base, the B pillar, and the rear door's rear edge (or a
// pickup's cab back, a van's sliding door).
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

// ---------------------------------------------------------------- body shape
// The body's surface as functions: the plan outline, the wall swept round it
// and the lid's height over the plan.
const LAME = 2.6;
const shapeCache = new Map();
export function bodyShape(name) {
  if (shapeCache.has(name)) return shapeCache.get(name);
  const body = CAR_BODIES[name];
  const L = body.length;
  const W = body.width / 2;
  const cab = body.cabin;
  const nose = body.nose;
  const tail = body.tail;
  const axles = [body.front_overhang, body.front_overhang + body.wheelbase];
  const archRadius = body.wheel_radius + 0.055;
  const top = curve([...body.hood, ...body.belt.slice(1), ...body.deck]);
  // The wall's lower edge without the wheel arches: bumpers lift toward the ends.
  const bottom = (zf) => {
    let y = body.clearance;
    y = Math.max(y, lerp(nose.bumper_bottom, body.clearance, smooth(zf / Math.max(0.3, axles[0] - archRadius))));
    y = Math.max(y, lerp(tail.bumper_bottom, body.clearance, smooth((L - zf) / Math.max(0.3, L - axles[1] - archRadius))));
    return y;
  };
  // Roof line along the centre: a nearly straight windshield easing into an
  // arched roof, then the rear glass down to the deck. Its highest point is
  // the car's height (below the rails on a body that has them).
  const cowl = top(cab.windshield_base);
  const tailTop = top(cab.rear_base);
  const peakZ = lerp(cab.windshield_top, cab.roof_end, 0.42);
  const roofLine = curve([
    [cab.windshield_base, cowl],
    [lerp(cab.windshield_base, cab.windshield_top, 0.3), lerp(cowl, cab.roof, 0.34)],
    [lerp(cab.windshield_base, cab.windshield_top, 0.7), lerp(cowl, cab.roof, 0.78)],
    [cab.windshield_top, cab.roof - 0.03],
    [peakZ, cab.roof],
    [cab.roof_end, cab.roof - cab.rear_drop],
    [lerp(cab.roof_end, cab.rear_base, 0.5), lerp(cab.roof - cab.rear_drop, tailTop, 0.52)],
    [cab.rear_base, tailTop],
  ]);
  const crown = body.roof_rails ? cab.crown : body.height - cab.roof;
  const hasTrunk = cab.rear_base < L - 0.3;
  const sideEnd = hasTrunk ? cab.rear_base - 0.12 : L + 1;
  const bedFrom = body.bed ? cab.rear_base : L + 1;
  // Behind a body without a trunk the lid rises from the tail steeper than the hatch falls.
  let hatchSlope = 0;
  for (let i = 0; i < 24; i += 1) {
    const z0 = lerp(cab.roof_end, cab.rear_base, i / 24);
    const z1 = lerp(cab.roof_end, cab.rear_base, (i + 1) / 24);
    hatchSlope = Math.max(hatchSlope, (roofLine(z0) - roofLine(z1)) / (z1 - z0));
  }
  const tailSlope = hasTrunk || body.bed ? 0.9 : Math.max(0.9, 1.6 * hatchSlope);

  // Plan outline at the widest line, a in [0, 3]: the front cap from the
  // centre line round the corner (0..1), the side (1..2), the rear cap back to
  // the centre line (2..3). A cap is a bowed face and a superellipse corner,
  // which meets the face and the side with no jump in curvature.
  const ease = (t) => {
    const m = LAME / 2;
    const a = t ** m;
    const b = (1 - t) ** m;
    return a / (a + b);
  };
  const cap = (q, corner, bow) => {
    const edge = W - corner;
    let x;
    let zc = 0;
    if (q <= 0.5) x = edge * (q / 0.5);
    else {
      const theta = (Math.PI / 2) * ease(Math.min(1, (q - 0.5) / 0.5));
      x = edge + corner * Math.sin(theta) ** (2 / LAME);
      zc = corner * (1 - Math.max(0, Math.cos(theta)) ** (2 / LAME));
    }
    return [x, zc - bow * (1 - (x / W) ** 2)];
  };
  const outlinePoint = (a) => {
    if (a <= 1) return cap(a, nose.corner, NOSE_BOW_M);
    if (a < 2) return [W, lerp(nose.corner, L - tail.corner, a - 1)];
    const [x, zz] = cap(3 - a, tail.corner, TAIL_BOW_M);
    return [x, L - zz];
  };
  const outline = (a) => {
    const h = 1e-4;
    const [x, zf] = outlinePoint(a);
    const p0 = outlinePoint(a - h);
    const p1 = outlinePoint(a + h);
    const tx = p1[0] - p0[0];
    const tz = p1[1] - p0[1];
    const l = Math.hypot(tx, tz) || 1;
    return { x, zf, nx: tz / l, nz: -tx / l };
  };

  // What the shoulder is like where the wall's top lands: 1 under the side
  // glass (the wall rolls a little into the glass plane), 0 along the hood,
  // deck and end faces (it rolls over into the lid); square along a bed.
  const styleAt = (zf, e, front) => {
    const up = smoothstep(cab.windshield_base - 0.34, cab.windshield_base + 0.06, zf);
    const down = 1 - smoothstep(sideEnd - 0.05, sideEnd + 0.32, zf);
    const round = front ? 1 : 1 - smoothstep(0.2, 0.85, e);
    const zeta = up * down * round;
    const bed = body.bed ? smoothstep(bedFrom, bedFrom + 0.08, zf) * round : 0;
    // The lid's rise from the shoulder where it is not the side glass: gentle
    // over a hood or a deck, as steep as the hatch behind a body without a trunk.
    const roll = lerp(front ? 0.9 : lerp(0.9, tailSlope, smoothstep(0.2, 0.85, e)), 2.6, bed);
    return {
      zeta,
      bed,
      roll,
      drop: 0.032 * (1 - zeta) * (1 - bed),
      // How far the wall's top rolls in: less under a steep lid (a bed's side, a hatch).
      dUp: lerp(lerp(0.065, 0.045, zeta), 0.02, Math.max(bed, (1 - zeta) * smoothstep(1.2, 3, roll))),
      slope: lerp(roll, GLASS_START_SLOPE, zeta),
      // The rounding between the lid and the side: a slim A pillar, a fuller roof rail.
      k: lerp(lerp(0.03, lerp(0.034, 0.065, smoothstep(cab.windshield_top - 0.35, cab.windshield_top + 0.25, zf)), zeta), 0.012, bed),
    };
  };
  // The side glass plane over the belt: it rises glassRise over glassInset,
  // steeper at the belt than at the roof rail (a slight barrel).
  const beltMid = top(lerp(cab.windshield_top, Math.min(cab.roof_end, L), 0.5));
  const glassRise = Math.max(0.2, cab.roof - 0.045 - beltMid);
  const glassInset = Math.max(0.07, cab.tumblehome - 0.045);
  const GLASS_BARREL = 0.25;
  const GLASS_START_SLOPE = glassRise / ((1 - GLASS_BARREL) * glassInset);
  const glassHeight = (d) => {
    const u = d / glassInset;
    if (u >= 1) return glassRise * (1 + (u - 1) / (1 + GLASS_BARREL));
    return (glassRise * (-(1 - GLASS_BARREL) + Math.sqrt((1 - GLASS_BARREL) ** 2 + 4 * GLASS_BARREL * u))) / (2 * GLASS_BARREL);
  };

  // A point of the wall: a round the outline, f from its lower edge (0) to the shoulder (1).
  const FACE_F = 0.3;
  const wall = (a, f) => {
    const o = outline(a);
    const front = a < 1.5;
    const e = Math.abs(o.nz);
    const es = e ** 1.5;
    const end = front ? nose : tail;
    const sign = front ? 1 : -1;
    const zfTop = clamp(o.zf + sign * end.lean * es, 0, L);
    const st = styleAt(zfTop, e, front);
    const yTop = top(zfTop) - st.drop;
    const yBottom = bottom(clamp(o.zf, 0, L));
    const h = Math.max(0.08, yTop - yBottom);
    const widest = lerp(0.5, FACE_F, e);
    // Inward along the plan normal: the tuck under at the sill, the roll in at the shoulder, a crease below it.
    let inward = lerp(0.05, 0, e) * Math.max(0, (widest - f) / widest) ** 2.2 + 0.04 * Math.max(0, (0.07 - f) / 0.07) ** 2;
    const leanSlope = (end.lean * es * 1.8) / ((1 - FACE_F) * h);
    const power = clamp((Math.max(0.08, 1 / st.slope - leanSlope) * h * (1 - widest)) / st.dUp, 1.6, 14);
    inward += st.dUp * Math.max(0, (f - widest) / (1 - widest)) ** power;
    const crease = 1 - 0.17 / h;
    inward += 0.007 * (1 - e) * (1 - st.bed) * smoothstep(crease - 0.035, crease + 0.035, f);
    // Along the car at the ends: the face leans back above the bumper line and tucks under below it.
    const lean = f < FACE_F ? 0 : ((f - FACE_F) / (1 - FACE_F)) ** 1.8;
    const under = f < FACE_F ? ((FACE_F - f) / FACE_F) ** 2 : 0;
    const shift = sign * es * (end.lean * lean + 0.05 * under);
    return { x: o.x - o.nx * inward, y: yBottom + f * h, zf: o.zf - o.nz * inward + shift, e, front, yTop, yBottom, h, st };
  };

  // The shoulder line (the wall's top) as a polyline, for the lid.
  const SHOULDER_STEPS = 420;
  const shoulder = [];
  for (let i = 0; i <= SHOULDER_STEPS; i += 1) {
    const point = wall((3 * i) / SHOULDER_STEPS, 1);
    shoulder.push({ x: point.x, zf: point.zf, y: point.y, zeta: point.st.zeta, bed: point.st.bed, k: point.st.k, slope: point.st.roll });
  }
  const nearest = (x, zf) => {
    let best = Infinity;
    let at = null;
    for (let i = 0; i < SHOULDER_STEPS; i += 1) {
      const p = shoulder[i];
      const q = shoulder[i + 1];
      const dx = q.x - p.x;
      const dz = q.zf - p.zf;
      const len2 = dx * dx + dz * dz;
      const t = len2 > 1e-14 ? clamp(((x - p.x) * dx + (zf - p.zf) * dz) / len2, 0, 1) : 0;
      const ex = x - (p.x + dx * t);
      const ez = zf - (p.zf + dz * t);
      const d2 = ex * ex + ez * ez;
      if (d2 < best) {
        best = d2;
        at = [i, t];
      }
    }
    const p = shoulder[at[0]];
    const q = shoulder[at[0] + 1];
    const t = at[1];
    return { dist: Math.sqrt(best), y: lerp(p.y, q.y, t), zeta: lerp(p.zeta, q.zeta, t), bed: lerp(p.bed, q.bed, t), k: lerp(p.k, q.k, t), slope: lerp(p.slope, q.slope, t) };
  };

  // The roof surface: the centre profile (hood, windshield, roof, rear glass,
  // deck), bowed in plan (the windshield's sides sit further back, the rear
  // glass's further forward) and crowned across the car.
  const frontBow = 0.2;
  const rearBow = hasTrunk ? 0.12 : 0.05;
  const roofHalf = W - cab.tumblehome + 0.08;
  const roofAt = (x, zf) => {
    const bow = frontBow * (1 - smoothstep(cab.windshield_top - 0.15, cab.windshield_top + 0.45, zf)) - rearBow * smoothstep(cab.roof_end - 0.45, cab.roof_end + 0.02, zf);
    const zq = zf - bow * (x / W) ** 2;
    const hood = top(clamp(zq, 0, L)) + 0.03;
    const roof = zq > cab.windshield_base && zq < cab.rear_base ? roofLine(zq) + crown * smoothstep(0, 0.2, roofLine(zq) - top(clamp(zq, 0, L))) : -1;
    const cabin = smoothstep(0.02, 0.3, roof - hood);
    const centre = smax(hood, roof, 0.012);
    return { y: centre - lerp(0.03 * (x / W) ** 2, 0.05 * Math.abs(x / roofHalf) ** 2.2, cabin), zq };
  };
  // The lid's height at a plan point, and what the regions on it read.
  const lid = (x, zf) => {
    const nb = nearest(x, zf);
    const side = nb.y + lerp(nb.slope * nb.dist, glassHeight(nb.dist), nb.zeta);
    const roof = roofAt(x, zf);
    return { y: smin(roof.y, side, nb.k), g: side - roof.y, zq: roof.zq, dist: nb.dist, belt: nb.y, zeta: nb.zeta, bed: nb.bed, k: nb.k };
  };

  // Arc length along the outline from the front centre line, by a.
  const ARC_STEPS = 600;
  const arc = [0];
  for (let i = 1; i <= ARC_STEPS; i += 1) {
    const p = outlinePoint((3 * (i - 1)) / ARC_STEPS);
    const q = outlinePoint((3 * i) / ARC_STEPS);
    arc.push(arc[i - 1] + Math.hypot(q[0] - p[0], q[1] - p[1]));
  }
  const arcAt = (a) => {
    const s = clamp((a / 3) * ARC_STEPS, 0, ARC_STEPS);
    const i = Math.min(ARC_STEPS - 1, Math.floor(s));
    return lerp(arc[i], arc[i + 1], s - i);
  };
  const shape = { body, L, W, axles, archRadius, top, bottom, roofLine, peakZ, crown, cowl, tailTop, hasTrunk, sideEnd, outline, wall, lid, roofAt, arcAt, arcTotal: arc[ARC_STEPS], glassInset, FACE_F };
  shapeCache.set(name, shape);
  return shape;
}

// ---------------------------------------------------------------- the shell
// The body shell of one level as a mesh in the shape's (station, ring)
// parameters, cut along every region's outline, then written out with normals
// from the surface. options: inner (the cabin's lining: the shell a little
// inside, facing in, open where the glass is), inset (metres inside the
// surface: the shadow caster).
function buildShell(name, levelName, { inner = false, inset = 0 } = {}) {
  const shape = bodyShape(name);
  const { body, L, W, axles, archRadius, wall, lid } = shape;
  const level = LEVELS[levelName];
  const detail = inner ? 1 : inset > 0 ? 0 : level.detail;
  const cab = body.cabin;
  const nose = body.nose;
  const tail = body.tail;
  const R = body.wheel_radius;

  // --- Stations round the outline.
  const stations = [];
  for (let i = 0; i <= level.face; i += 1) stations.push((0.5 * i) / level.face);
  for (let i = 1; i <= level.corner; i += 1) stations.push(0.5 + (0.5 * i) / level.corner);
  const sideFrom = nose.corner;
  const sideTo = L - tail.corner;
  const keys = [shape.peakZ, cab.windshield_base, cab.windshield_top, cab.roof_end, cab.rear_base];
  if (detail >= 2) keys.push(cab.windshield_base - 0.07, cab.rear_base + 0.04, cab.roof_end + 0.04);
  const steps = Math.max(2, Math.ceil((sideTo - sideFrom) / level.step));
  const regular = [];
  for (let i = 1; i < steps; i += 1) regular.push(lerp(sideFrom, sideTo, i / steps));
  const minGap = level.step * 0.3;
  const sideZ = keys.filter((zf) => zf > sideFrom + 0.02 && zf < sideTo - 0.02);
  for (const zf of regular) if (sideZ.every((key) => Math.abs(key - zf) > minGap)) sideZ.push(zf);
  sideZ.sort((a, b) => a - b);
  for (const zf of sideZ) stations.push(1 + (zf - sideFrom) / (sideTo - sideFrom));
  for (let i = 0; i <= level.corner; i += 1) stations.push(2 + (0.5 * i) / level.corner);
  for (let i = 1; i <= level.face; i += 1) stations.push(2.5 + (0.5 * i) / level.face);
  // More stations where the roof line is steep (a windshield, a hatch, a van's
  // back), so no triangle spans much of its height.
  const centreHeight = (a) => lid(0, wall(a, 1).zf).y;
  const maxDrop = { hero: 0.13, near: 0.2, mid: 0.3, far: 0.5 }[levelName];
  for (let i = 0; i < stations.length - 1; i += 1) {
    if (stations[i + 1] - stations[i] > 2e-4 && Math.abs(centreHeight(stations[i + 1]) - centreHeight(stations[i])) > maxDrop) {
      stations.splice(i + 1, 0, (stations[i] + stations[i + 1]) / 2);
      i -= 1;
    }
  }
  const K = stations.length;
  const wallF = level.wall;
  const nW = wallF.length - 1;
  const nL = level.lid;

  // --- Each station's lid points, spread by the section's length so the steep
  // side glass and the roof rail get their share.
  const spread = stations.map((a) => {
    const edge = wall(a, 1);
    const samples = 40;
    const lengths = [0];
    let last = [edge.x, edge.y];
    for (let i = 1; i <= samples; i += 1) {
      const x = edge.x * (1 - i / samples);
      const y = i === 0 ? edge.y : lid(x, edge.zf).y;
      lengths.push(lengths[i - 1] + Math.hypot(x - last[0], y - last[1]));
      last = [x, y];
    }
    const total = lengths[samples] || 1;
    const table = [0];
    let s = 0;
    for (let j = 1; j < nL; j += 1) {
      const want = j / nL;
      while (s < samples - 1 && 0.7 * (lengths[s + 1] / total) + 0.3 * ((s + 1) / samples) < want) s += 1;
      const lo = 0.7 * (lengths[s] / total) + 0.3 * (s / samples);
      const hi = 0.7 * (lengths[s + 1] / total) + 0.3 * ((s + 1) / samples);
      table.push((s + (hi > lo ? (want - lo) / (hi - lo) : 0)) / samples);
    }
    table.push(1);
    return table;
  });

  // --- A record of the surface at (station, ring): position and what the regions read.
  const record = (kf, v) => {
    const k0 = clamp(Math.floor(kf), 0, K - 2);
    const t = kf - k0;
    const a = lerp(stations[k0], stations[k0 + 1], t);
    if (v <= nW) {
      const j = clamp(Math.floor(v), 0, nW - 1);
      const f = lerp(wallF[j], wallF[j + 1], v - j);
      const p = wall(a, f);
      const w = shape.arcAt(a);
      return { kf, v, wall: true, a, f, x: p.x, y: p.y, zf: p.zf, e: p.e, front: p.front, top: p.yTop, bottom: p.yBottom, h: p.h, w, wr: shape.arcTotal - w, zeta: p.st.zeta, bed: p.st.bed };
    }
    const u = v - nW;
    const j = clamp(Math.floor(u), 0, nL - 1);
    const xi = lerp(lerp(spread[k0][j], spread[k0][j + 1], u - j), lerp(spread[k0 + 1][j], spread[k0 + 1][j + 1], u - j), t);
    const edge = wall(a, 1);
    const x = edge.x * (1 - xi);
    const at = lid(x, edge.zf);
    return { kf, v, wall: false, a, x, y: at.y, zf: edge.zf, zq: at.zq, g: at.g, dist: at.dist, belt: at.belt, zeta: at.zeta, bed: at.bed, k: at.k, front: a < 1.5, e: edge.e };
  };
  // The surface normal at a record (outward).
  const baseNormal = (rec) => {
    if (rec.wall) {
      const ha = 2e-4;
      const hf = 1e-3;
      const f0 = Math.max(0, rec.f - hf);
      const f1 = Math.min(1, rec.f + hf);
      const pa0 = wall(rec.a - ha, rec.f);
      const pa1 = wall(rec.a + ha, rec.f);
      const pf0 = wall(rec.a, f0);
      const pf1 = wall(rec.a, f1);
      const da = v3(pa1.x - pa0.x, pa1.y - pa0.y, pa1.zf - pa0.zf);
      const df = v3(pf1.x - pf0.x, pf1.y - pf0.y, pf1.zf - pf0.zf);
      const n = vcross(df, da);
      if (vlen(n) > 1e-14) return vnorm(n);
    }
    const h = 4e-4;
    const x = Math.max(rec.x, h);
    const dx = (lid(x + h, rec.zf).y - lid(x - h, rec.zf).y) / (2 * h);
    const dz = (lid(x, rec.zf + h).y - lid(x, rec.zf - h).y) / (2 * h);
    const n = vnorm(v3(-dx, 1, -dz));
    if (rec.x < 1e-6) n[0] = 0;
    return vnorm(n);
  };

  // --- Regions. Each is a signed function of a record, negative inside,
  // smooth over a domain (`where`): the mesh is cut along its zero line only
  // inside the domain, and a triangle belongs to it by its middle.
  const region = (where, fn) => {
    const value = (rec) => (where(rec) ? fn(rec) : BIG);
    value.where = where;
    value.fn = fn;
    return value;
  };
  // A rounded box in two coordinates of a record. The mesh is first cut along
  // the box's four edge lines, so a box thinner than a triangle is still cut out whole.
  // insets: bands inside the box's edge that are cut out too (a frame, a bevel), each with its own edge lines.
  const boxRegion = (where, px, py, hx, hy, r, insets = []) => {
    const value = region(where, (rec) => box2(px(rec), py(rec), hx, hy, r));
    const closeTo = (margin) => (rec) => where(rec) && Math.abs(px(rec)) < hx + margin && Math.abs(py(rec)) < hy + margin;
    value.pre = [];
    // insets: [[inset, the least detail that cuts it], ...].
    for (const inset of [0, ...insets.filter((entry) => detail >= entry[1]).map((entry) => entry[0])]) {
      const close = closeTo(inset === 0 && detail === 2 ? 0.12 : detail >= 2 ? 0.05 : 0.03);
      value.pre.push(region(close, (rec) => px(rec) - (hx - inset)), region(close, (rec) => px(rec) + (hx - inset)), region(close, (rec) => py(rec) - (hy - inset)), region(close, (rec) => py(rec) + (hy - inset)));
    }
    return value;
  };
  const onLid = (rec) => !rec.wall;
  const onSide = (rec) => rec.wall && rec.e <= 0.3;
  const seams = doorSeams(body);
  const gapHalf = detail >= 3 ? 0.0035 : 0.006;
  const sideGlassEnd = body.pillars.cargo_from ? body.pillars.cargo_from - 0.05 : body.bed ? cab.rear_base - 0.1 : body.pillars.quarter_glass ? cab.rear_base - 0.16 : cab.roof_end + 0.1;
  const max3 = (a, b, c, k) => smax(smax(a, b, k), c, k);
  const archDistance = (rec) => Math.min(Math.hypot(rec.zf - axles[0], rec.y - R), Math.hypot(rec.zf - axles[1], rec.y - R));
  const nearArch = (rec) => rec.wall && (Math.abs(rec.zf - axles[0]) < archRadius + 0.25 || Math.abs(rec.zf - axles[1]) < archRadius + 0.25);
  const fArch = region(nearArch, (rec) => archDistance(rec) - archRadius);
  const fSide = region(onLid, (rec) => smax(max3(rec.belt + 0.028 - rec.y, rec.g + rec.k + 0.006, cab.windshield_base + 0.16 - rec.zf, 0.03), rec.zf - sideGlassEnd, 0.03));
  const pillarEdges = [];
  if (body.pillars.b) pillarEdges.push(body.pillars.b - 0.05, body.pillars.b + 0.05);
  if (body.pillars.c && !body.pillars.cargo_from) pillarEdges.push(body.pillars.c - 0.055, body.pillars.c + 0.055);
  const nearSideGlass = (rec) => !rec.wall && fSide.fn(rec) < 0.08;
  const fPillar = region(nearSideGlass, (rec) => {
    let f = BIG;
    for (let i = 0; i < pillarEdges.length; i += 2) f = Math.min(f, Math.max(pillarEdges[i] - rec.zf, rec.zf - pillarEdges[i + 1]));
    return f;
  });
  fPillar.pre = pillarEdges.map((zf) => region(nearSideGlass, (rec) => rec.zf - zf));
  const fWind = region(onLid, (rec) => max3(cab.windshield_base + 0.06 - rec.zq, rec.zq - (cab.windshield_top - 0.035), rec.k + 0.016 - rec.g, 0.03));
  // The windshield's deeper frit band along its foot.
  const fritFoot = region((rec) => !rec.wall && fWind.fn(rec) < 0.02, (rec) => rec.zq - (cab.windshield_base + 0.12));
  const rearSpan = cab.rear_base - cab.roof_end;
  const fRear = region(onLid, (rec) => smax(max3(cab.roof_end + Math.min(0.035, 0.2 * rearSpan) - rec.zq, rec.zq - (cab.rear_base - Math.min(0.045, 0.25 * rearSpan)), rec.k + 0.03 - rec.g, 0.03), shape.tailTop + 0.05 - rec.y, 0.03));
  const fGlassRoof = region((rec) => !rec.wall && body.glass_roof === true, (rec) => max3(cab.windshield_top + 0.1 - rec.zq, rec.zq - (cab.roof_end - 0.1), rec.k + 0.07 - rec.g, 0.05));
  const fRoof = region(onLid, (rec) => Math.max(cab.windshield_top - 0.035 - rec.zq, rec.zq - (cab.roof_end + 0.035), -(rec.g + rec.k * 0.6)));
  const fCowl = region(onLid, (rec) => Math.max(Math.abs(rec.zq - cab.windshield_base) - 0.065, 0.02 - rec.g));
  fCowl.pre = [region(onLid, (rec) => rec.zq - (cab.windshield_base - 0.065)), region(onLid, (rec) => rec.zq - (cab.windshield_base + 0.065))];
  const hoodLine = region((rec) => !rec.wall && rec.zq < cab.windshield_base - 0.06 && rec.zeta < 0.6, (rec) => rec.dist - 0.075);
  const deckFrom = cab.rear_base + 0.05;
  const deckLine = region((rec) => !rec.wall && (shape.hasTrunk || body.bed !== undefined) && rec.zq > deckFrom, (rec) => rec.dist - 0.07);
  const fTonneau = region((rec) => !rec.wall && body.bed === "tonneau", (rec) => Math.max(deckFrom + 0.04 - rec.zq, 0.075 - rec.dist));
  const sill = (rec) => rec.bottom + 0.105;
  const seamLines = seams.map((zf) => region((rec) => onSide(rec) && rec.y > sill(rec) - 0.004, (rec) => rec.zf - zf));
  const sillLine = region((rec) => onSide(rec) && rec.zf > seams[0] - 0.004 && rec.zf < seams.at(-1) + 0.004, (rec) => rec.y - sill(rec));
  const cladding = body.cladding > 0;
  const fClad = region((rec) => rec.wall && cladding, (rec) => Math.min(rec.y - (rec.bottom + 0.15), archDistance(rec) - (archRadius + 0.06)));
  // Front face: w is the distance round the outline from the centre line.
  const noseEdge = W - nose.corner;
  const truck = body.grille === "truck";
  const onNose = (rec) => rec.wall && rec.front;
  const onNoseFace = (rec) => rec.wall && rec.front && rec.w < noseEdge + 0.25;
  const lampHalf = truck ? 0.2 : 0.3;
  const lampCentre = truck ? noseEdge + 0.02 : noseEdge + 0.2;
  const lampHigh = truck ? 0.1 : 0.055;
  const lampY = (rec) => rec.top - (truck ? 0.16 : 0.105) + 0.03 * ((rec.w - lampCentre) / lampHalf);
  const fHead = boxRegion(onNose, (rec) => rec.w - lampCentre, (rec) => rec.y - lampY(rec), lampHalf, lampHigh, 0.035, [[0.014, 3], [0.02, 2], [0.038, 2]]);
  const inLamp = (rec) => onNose(rec) && fHead.fn(rec) < 0.12;
  // The running light: a band inside the lamp's lower edge; the amber marker its outer end.
  const fDrl = region(inLamp, (rec) => Math.max(fHead.fn(rec) + 0.02, -(fHead.fn(rec) + 0.038), rec.y - (lampY(rec) - 0.004)));
  fDrl.pre = [region(inLamp, (rec) => fHead.fn(rec) + 0.02), region(inLamp, (rec) => fHead.fn(rec) + 0.038), region(inLamp, (rec) => rec.y - (lampY(rec) - 0.004))];
  const fAmber = region(inLamp, (rec) => Math.max(fHead.fn(rec) + 0.02, lampCentre + lampHalf - 0.085 - rec.w));
  fAmber.pre = [region(inLamp, (rec) => lampCentre + lampHalf - 0.085 - rec.w)];
  const grilleHalf = truck ? lampCentre - lampHalf - 0.03 : body.grille === "wide" ? lampCentre - lampHalf - 0.035 : 0.3;
  const grilleHigh = truck ? 0.17 : body.grille === "wide" ? 0.07 : 0.042;
  const grilleY = (rec) => rec.top - (truck ? 0.22 : 0.125);
  const fGrille = boxRegion((rec) => onNoseFace(rec) && body.grille !== "none", (rec) => rec.x, (rec) => rec.y - grilleY(rec), grilleHalf, grilleHigh, 0.03, [[0.018, 2]]);
  // The lower intake stays under the bumper line, the body's foremost.
  const faceHigh = shape.top(nose.lean) - nose.bumper_bottom;
  const fIntake = boxRegion(onNoseFace, (rec) => rec.x, (rec) => rec.y - (rec.bottom + 0.14 * rec.h), body.grille === "none" ? 0.34 : 0.46, 0.085 * faceHigh, 0.025, [[0.018, 3]]);
  const fFog = boxRegion(onNose, (rec) => rec.w - (noseEdge + 0.12), (rec) => rec.y - (rec.bottom + 0.14 * rec.h), 0.11, 0.07 * faceHigh, 0.025);
  const plateY = (rec) => rec.bottom + (truck ? 0.34 : 0.45) * rec.h;
  const fPlateFront = boxRegion(onNoseFace, (rec) => rec.x, (rec) => rec.y - plateY(rec), 0.153, 0.077, 0.012, [[0.009, 3]]);
  // Rear face: wr is the distance round the outline from the rear centre line.
  const tailEdge = W - tail.corner;
  const onTail = (rec) => rec.wall && !rec.front;
  const onTailFace = (rec) => rec.wall && !rec.front && rec.wr < tailEdge + 0.25;
  const tall = !shape.hasTrunk && !body.bed;
  const tailHalf = body.bed ? 0.07 : tall ? 0.24 : 0.36;
  const tailCentre = body.bed ? tailEdge + tail.corner * 0.5 : tall ? tailEdge + 0.2 : tailEdge + 0.08;
  const tailHigh = body.bed ? 0.17 : tall ? 0.12 : 0.062;
  const tailY = (rec) => rec.top - (body.bed ? 0.26 : tall ? 0.18 : 0.115);
  const fTail = boxRegion(onTail, (rec) => rec.wr - tailCentre, (rec) => rec.y - tailY(rec), tailHalf, tailHigh, 0.03, [[0.014, 3], [0.02, 2], [0.042, 2], [0.05, 3]]);
  const inTail = (rec) => onTail(rec) && fTail.fn(rec) < 0.12;
  // The light bar: a ring inside the lamp's edge; the reversing lamp its inner end.
  const fTailBar = region(inTail, (rec) => Math.max(fTail.fn(rec) + 0.02, -(fTail.fn(rec) + 0.042)));
  fTailBar.pre = [region(inTail, (rec) => fTail.fn(rec) + 0.02), region(inTail, (rec) => fTail.fn(rec) + 0.042)];
  const fReverse = region(inTail, (rec) => Math.max(fTail.fn(rec) + 0.05, rec.wr - (tailCentre - tailHalf + 0.16)));
  fReverse.pre = [region(inTail, (rec) => fTail.fn(rec) + 0.05), region(inTail, (rec) => rec.wr - (tailCentre - tailHalf + 0.16))];
  const rearPlateY = (rec) => rec.bottom + (body.bed ? 0.16 : 0.56) * rec.h;
  const fPocket = boxRegion(onTailFace, (rec) => rec.x, (rec) => rec.y - rearPlateY(rec), 0.25, 0.105, 0.03, [[0.014, 3]]);
  const fPlateRear = boxRegion(onTailFace, (rec) => rec.x, (rec) => rec.y - rearPlateY(rec), 0.153, 0.077, 0.012, [[0.009, 3]]);
  const fGarnish = boxRegion((rec) => onTailFace(rec) && !body.bed, (rec) => rec.x, (rec) => rec.y - (rearPlateY(rec) + 0.135), Math.min(0.34, tailCentre - tailHalf - 0.03), 0.014, 0.012);
  const fReflector = boxRegion(onTail, (rec) => rec.wr - (tailEdge + 0.05), (rec) => rec.y - (rec.bottom + 0.15), 0.1, 0.018, 0.012);
  const bumperLine = region((rec) => onTail(rec) && !body.bed && rec.wr < tailEdge + tail.corner * 1.2, (rec) => rec.y - (rec.bottom + 0.34 * rec.h));
  const gateLine = region((rec) => onTailFace(rec) && rec.y > rec.bottom + 0.34 * rec.h - 0.004 && rec.y < tailY(rec) - tailHigh + 0.02, (rec) => rec.x - (tailCentre - tailHalf - 0.012));
  const fBrake = boxRegion((rec) => !rec.wall && rearSpan > 0.2, (rec) => rec.x, (rec) => rec.zq - (cab.roof_end + 0.012), 0.2, 0.008, 0.004);
  // Door handles' pockets and the filler door.
  const handles = seams.slice(1).map((zf) => zf - 0.2);
  const handleBoxes = handles.map((zf) => boxRegion(onSide, (rec) => rec.zf - zf, (rec) => rec.y - (rec.top - 0.115), 0.1, 0.026, 0.024, [[0.012, 3]]));
  const fHandle = region(onSide, (rec) => Math.min(BIG, ...handleBoxes.map((fn) => fn.fn(rec))));
  fHandle.pre = handleBoxes.flatMap((fn) => fn.pre);
  const fuelZ = axles[1] + archRadius + 0.2;
  const fuelLine = region((rec) => rec.wall && rec.e < 0.5 && !body.bed, (rec) => box2(rec.zf - fuelZ, rec.y - (rec.top - 0.22), 0.085, 0.075, 0.035));
  // A service body's compartment doors.
  const service = body.bed === "service";
  const lockerLines = service ? [4.3, 5.0, 5.75].map((zf) => region((rec) => onSide(rec) && rec.y > 0.6 && rec.y < 1.4, (rec) => rec.zf - zf)) : [];
  const fLockerRail = boxRegion((rec) => onSide(rec) && service, (rec) => rec.zf - 5.0, (rec) => rec.y - 1.41, 1.15, 0.012, 0.004);

  // What to cut at this detail: [region, offsets...].
  const cuts = [];
  const cut = (fn, ...offsets) => cuts.push([fn, offsets.length ? offsets : [0]]);
  const lines = [];
  const line = (fn) => {
    lines.push(fn);
    cut(fn, -gapHalf, gapHalf);
  };
  const frit = detail >= 3 ? 0.022 : null;
  if (!inner) cut(fArch);
  if (inset === 0) {
    cut(fSide);
    if (detail >= 1) cut(fPillar, 9);
    cut(fWind, ...(frit ? [0, -frit] : [0]));
    if (frit) cut(fritFoot);
    cut(fRear, ...(frit ? [0, -frit] : [0]));
    if (body.glass_roof) cut(fGlassRoof, ...(frit ? [0, -frit] : [0]));
  }
  if (!inner && inset === 0) {
    cut(fRoof);
    if (cladding) cut(fClad);
    cut(fHead);
    cut(fTail);
    cut(fPlateFront);
    cut(fPlateRear);
    if (body.grille !== "none") cut(fGrille, ...(detail >= 2 ? [0, -0.018] : [0]));
    if (detail >= 1) cut(fIntake, ...(detail >= 3 ? [0, -0.018] : [0]));
    if (body.bed === "tonneau") cut(fTonneau);
    if (detail >= 1) {
      cut(fCowl);
      cut(fReflector);
    }
    if (detail >= 2) {
      cut(fDrl, 9);
      cut(fTailBar, 9);
      cut(fGarnish);
      cut(fBrake);
      for (const fn of seamLines) line(fn);
      line(sillLine);
      line(hoodLine);
      line(deckLine);
      for (const fn of lockerLines) line(fn);
      if (service) cut(fLockerRail);
    }
    if (detail >= 3) {
      cut(fAmber, 9);
      cut(fReverse, 9);
      cut(fFog);
      cut(fPocket, 0, -0.014);
      line(bumperLine);
      line(gateLine);
      cut(fHead, -0.014);
      cut(fTail, -0.014);
      cut(fPlateFront, -0.009);
      cut(fPlateRear, -0.009);
      cut(fHandle, 9);
      for (const fn of handleBoxes) cut(fn, 0, -0.012);
      line(fuelLine);
    }
  }

  // --- The grid, then the cuts. A vertex on the seam between wall and lid has
  // a lid twin, so each triangle reads the regions of its own patch.
  const verts = [];
  const twins = [];
  const tris = [];
  const onLidPatch = [];
  const addVertex = (rec) => {
    verts.push(rec);
    twins.push(rec.wall && rec.v === nW ? record(rec.kf, nW + 1e-9) : null);
    return verts.length - 1;
  };
  const ids = [];
  for (let k = 0; k < K; k += 1) {
    const row = [];
    for (let v = 0; v <= nW + nL; v += 1) row.push(addVertex(record(k, v)));
    ids.push(row);
  }
  for (let k = 0; k < K - 1; k += 1) {
    for (let v = 0; v < nW + nL; v += 1) {
      tris.push([ids[k][v], ids[k + 1][v], ids[k + 1][v + 1]], [ids[k][v], ids[k + 1][v + 1], ids[k][v + 1]]);
      onLidPatch.push(v >= nW, v >= nW);
    }
  }
  const EPS = 2e-5;
  const edgeKey = (i, j) => (i < j ? i * 1e7 + j : j * 1e7 + i);
  const cutAlong = (fn, offset) => {
    // NaN outside the region's domain: a triangle with such a corner is left whole.
    const read = (rec) => (rec && fn.where(rec) ? fn.fn(rec) - offset : NaN);
    const wallValue = verts.map(read);
    const lidValue = twins.map((twin, id) => (twin ? read(twin) : wallValue[id]));
    if (![...wallValue, ...lidValue].some((x) => x > EPS) || ![...wallValue, ...lidValue].some((x) => x < -EPS)) return;
    const made = new Map();
    const crossing = (i, j, value) => {
      const key = edgeKey(i, j);
      if (made.has(key)) return made.get(key);
      // Find the outline's true place on the edge in the surface's own parameters.
      const lid = value === lidValue;
      const lo = value[i] < 0 ? i : j;
      const hi = value[i] < 0 ? j : i;
      const lift = (id) => (lid && twins[id] ? nW + 1e-9 : verts[id].v);
      let a = [verts[lo].kf, lift(lo)];
      let b = [verts[hi].kf, lift(hi)];
      let fa = value[lo];
      let fb = value[hi];
      let rec = null;
      for (let step = 0; step < 16; step += 1) {
        const t = clamp(fa / (fa - fb), 0.1, 0.9);
        const m = [lerp(a[0], b[0], t), lerp(a[1], b[1], t)];
        rec = record(m[0], m[1]);
        const fm = fn.where(rec) ? fn.fn(rec) - offset : fb;
        if (Math.abs(fm) < 1e-6) break;
        if (fm < 0) {
          a = m;
          fa = fm;
        } else {
          b = m;
          fb = fm;
        }
      }
      // A crossing on the seam itself is a seam vertex again.
      if (verts[i].v === nW && verts[j].v === nW) rec = record(rec.kf, nW);
      const id = addVertex(rec);
      wallValue.push(0);
      lidValue.push(0);
      made.set(key, id);
      return id;
    };
    const count = tris.length;
    for (let t = 0; t < count; t += 1) {
      const tri = tris[t];
      const value = onLidPatch[t] ? lidValue : wallValue;
      if (Number.isNaN(value[tri[0]]) || Number.isNaN(value[tri[1]]) || Number.isNaN(value[tri[2]])) continue;
      const sign = tri.map((id) => (value[id] > EPS ? 1 : value[id] < -EPS ? -1 : 0));
      const pos = sign.filter((x) => x > 0).length;
      const neg = sign.filter((x) => x < 0).length;
      if (pos === 0 || neg === 0) continue;
      // Rotate so the lone vertex (or the one on the line) comes first.
      const lead = pos + neg === 2 ? sign.indexOf(0) : sign.indexOf(pos === 1 ? 1 : -1);
      const [p, q, r] = [tri[lead], tri[(lead + 1) % 3], tri[(lead + 2) % 3]];
      if (pos + neg === 2) {
        const m = crossing(q, r, value);
        tris[t] = [p, q, m];
        tris.push([p, m, r]);
        onLidPatch.push(onLidPatch[t]);
      } else {
        const m1 = crossing(p, q, value);
        const m2 = crossing(r, p, value);
        tris[t] = [p, m1, m2];
        tris.push([m1, q, r], [m1, r, m2]);
        onLidPatch.push(onLidPatch[t], onLidPatch[t]);
      }
    }
    // Keep the mesh whole: a triangle left alone beside a cut one takes the new point on their shared edge.
    for (let t = 0; t < tris.length; t += 1) {
      for (let c = 0; c < 3; c += 1) {
        const tri = tris[t];
        const m = made.get(edgeKey(tri[c], tri[(c + 1) % 3]));
        if (m === undefined || tri.includes(m)) continue;
        const [p, q, r] = [tri[c], tri[(c + 1) % 3], tri[(c + 2) % 3]];
        tris[t] = [p, m, r];
        tris.push([m, q, r]);
        onLidPatch.push(onLidPatch[t]);
        c = -1;
      }
    }
  };
  const precut = new Set();
  for (const [fn, offsets] of cuts) {
    for (const pre of fn.pre ?? []) {
      if (precut.has(pre)) continue;
      precut.add(pre);
      cutAlong(pre, 0);
    }
    // An offset of 9 asks for the region's pre-cuts only.
    for (const offset of offsets) if (offset !== 9) cutAlong(fn, offset);
  }

  // --- What each triangle is, by its middle.
  const lineAt = (rec) => lines.some((fn) => Math.abs(fn(rec)) < gapHalf);
  const classify = (rec) => {
    if (!inner && fArch(rec) < 0) return null;
    if (inner) {
      // The lining: the cabin's length only, down to the floor.
      if ((rec.wall ? rec.zf < cab.windshield_base + 0.05 : rec.zq < cab.windshield_base + 0.04) || (shape.hasTrunk && rec.zf > cab.rear_base + 0.05) || (body.bed && rec.zf > cab.rear_base) || (rec.wall && rec.f < 0.12)) return null;
      if (fSide(rec) < 0 && fPillar(rec) > 0) return null;
      if (fWind(rec) < 0 || fRear(rec) < 0 || fGlassRoof(rec) < 0) return null;
      return { part: rec.wall ? P.cabin : P.headliner };
    }
    if (inset > 0) return { part: P.paint };
    if (detail >= 2 && lineAt(rec)) return { part: P.gap, ao: 0.3, groove: detail >= 3 };
    const side = fSide(rec);
    if (side < 0) {
      if (detail >= 1 && fPillar(rec) < 0) return { part: detail >= 2 ? P.gloss_black : P.trim };
      // Door glass runs in seals, without a frit band.
      return { part: P.glass, glass: true, frit: false, dark: rec.zf > (body.pillars.b ?? L) };
    }
    for (const [fn, dark] of [[fWind, false], [fRear, true], [fGlassRoof, true]]) {
      const f = fn(rec);
      if (f < 0) return { part: P.glass, glass: true, frit: frit !== null && (f > -frit || (fn === fWind && rec.zq < cab.windshield_base + 0.12)), dark };
    }
    if (detail >= 2 && fBrake(rec) < 0) return { part: P.lamp_red };
    if (!rec.wall) {
      if (detail >= 1 && fCowl(rec) < 0) return { part: P.trim, ao: 0.7 };
      if (fTonneau(rec) < 0) return { part: P.trim };
      if (fRoof(rec) < 0) return { part: P.roof };
      return { part: P.paint };
    }
    const head = fHead(rec);
    if (head < 0) {
      if (detail >= 3 && fAmber(rec) < 0) return { part: P.lamp_amber, lens: P.head_lamp, lamp: true };
      if (detail >= 2 && fDrl(rec) < 0) return { part: P.lamp_drl, lens: P.head_lamp, lamp: true, proud: true };
      return { part: detail >= 3 ? P.lamp_housing : P.head_lamp, lens: P.head_lamp, lamp: true };
    }
    const tailLamp = fTail(rec);
    if (tailLamp < 0) {
      if (detail >= 3 && fReverse(rec) < 0) return { part: P.lamp_white, lens: P.tail_lamp, lamp: true };
      if (detail >= 2 && fTailBar(rec) < 0) return { part: P.lamp_red, lens: P.tail_lamp, lamp: true, proud: true };
      return { part: P.tail_lamp, lens: P.tail_lamp, lamp: true };
    }
    const plate = Math.min(fPlateFront(rec), fPlateRear(rec));
    if (plate < 0) return { part: detail >= 3 && plate > -0.009 ? P.trim : P.plate };
    if (detail >= 3 && fPocket(rec) < 0) return { part: P.trim, ao: 0.7 };
    const grille = fGrille(rec);
    if (grille < 0) return { part: detail >= 2 && grille > -0.018 ? (truck || body.grille === "sedan" ? P.chrome : P.gloss_black) : P.grille, ao: grille > -0.018 ? 1 : 0.6 };
    if (detail >= 1 && fIntake(rec) < 0) return { part: P.grille, ao: 0.55 };
    if (detail >= 3 && fFog(rec) < 0) return { part: P.grille, ao: 0.6 };
    if (detail >= 2 && fGarnish(rec) < 0) return { part: P.chrome };
    if (detail >= 1 && fReflector(rec) < 0) return { part: P.tail_lamp };
    if (detail >= 3 && fHandle(rec) < 0) return { part: P.under, ao: 0.5 };
    if (service && detail >= 2 && fLockerRail(rec) < 0) return { part: P.chrome };
    if (fClad(rec) < 0) return { part: P.trim };
    return { part: P.paint };
  };
  // How far in (metres) the surface is pressed at a record: grooves, sunk grilles and lamp bowls, raised plates.
  const ramp = (f, width) => clamp(-f / width, 0, 1);
  const pressed = (rec) => {
    if (inner) return 0.03;
    if (inset > 0) return inset;
    if (detail < 3) return 0;
    let d = 0;
    for (const fn of lines) if (Math.abs(fn(rec)) < gapHalf * 0.98) d = Math.max(d, 0.004);
    if (rec.wall) {
      d = Math.max(d, 0.03 * ramp(fGrille(rec) + 0.018, 0.014), 0.03 * ramp(fIntake(rec), 0.018), 0.012 * ramp(fHandle(rec), 0.012));
      d = Math.max(d, 0.05 * ramp(fHead(rec), 0.014), 0.03 * ramp(fTail(rec), 0.014));
      d = Math.max(d, 0.016 * ramp(fPocket(rec), 0.014));
      // The rear plate stands off its pocket's floor; the front one lies in the bumper's face, the body's foremost.
      d -= 0.006 * ramp(fPlateRear(rec), 0.003);
    }
    return d;
  };

  // --- Write the triangles out: positions pressed along the surface normal,
  // each corner's normal taken a step inside its own triangle (so a crease or
  // a pressed edge keeps its two sides), then welded where they agree.
  const zOf = (zf) => zf - L / 2;
  const point = (rec) => v3(rec.x, rec.y, zOf(rec.zf));
  const normalCache = new Map();
  const vertexNormal = (id) => {
    if (!normalCache.has(id)) normalCache.set(id, baseNormal(verts[id]));
    return normalCache.get(id);
  };
  const placed = (rec, n, d) => vsub(point(rec), vscale(n, d));
  const placeCache = new Map();
  const place = (id) => {
    if (!placeCache.has(id)) placeCache.set(id, placed(verts[id], vertexNormal(id), pressed(verts[id])));
    return placeCache.get(id);
  };
  const moving = detail >= 3 && !inner && inset === 0;
  const cornerNormal = (tri, corner) => {
    const rec = verts[tri[corner]];
    const mid = [(verts[tri[0]].kf + verts[tri[1]].kf + verts[tri[2]].kf) / 3, (verts[tri[0]].v + verts[tri[1]].v + verts[tri[2]].v) / 3];
    const at = record(lerp(rec.kf, mid[0], 0.06), lerp(rec.v, mid[1], 0.06));
    const n = baseNormal(at);
    if (!moving) return n;
    // Is the surface pressed unevenly here? Then the normal of the pressed surface.
    const h = 4e-3;
    const samples = [[h, 0], [-h, 0], [0, h], [0, -h]].map(([dk, dv]) => {
      const lo = at.wall ? 0 : nW + 1e-6;
      const hi = at.wall ? nW : nW + nL;
      const r = record(clamp(at.kf + dk, 0, K - 1), clamp(at.v + dv, lo, hi));
      return [r, pressed(r)];
    });
    const here = pressed(at);
    if (samples.every(([, d]) => Math.abs(d - here) < 1e-5)) return n;
    const pts = samples.map(([r, d]) => placed(r, n, d));
    const m = vcross(vsub(pts[2], pts[3]), vsub(pts[0], pts[1]));
    if (vlen(m) < 1e-14) return n;
    const out = vnorm(m);
    return vdot(out, n) >= 0 ? out : vscale(out, -1);
  };
  const body3 = new CarMesh();
  const glass = new CarMesh();
  const kept = [];
  for (const tri of tris) {
    const mid = record((verts[tri[0]].kf + verts[tri[1]].kf + verts[tri[2]].kf) / 3, (verts[tri[0]].v + verts[tri[1]].v + verts[tri[2]].v) / 3);
    const kind = classify(mid);
    if (kind) kept.push({ tri, kind, normals: [0, 1, 2].map((corner) => cornerNormal(tri, corner)) });
  }
  // Weld each vertex's corner normals that agree within the crease angle.
  const corners = new Map();
  for (const entry of kept) {
    entry.tri.forEach((id, corner) => {
      if (!corners.has(id)) corners.set(id, []);
      corners.get(id).push([entry, corner]);
    });
  }
  const cosWeld = Math.cos((24 * Math.PI) / 180);
  for (const [id, list] of corners) {
    const groups = [];
    for (const [entry, corner] of list) {
      const n = entry.normals[corner];
      let group = groups.find((g) => vdot(g.first, n) > cosWeld);
      if (!group) {
        group = { first: n, sum: v3(0, 0, 0), members: [] };
        groups.push(group);
      }
      group.sum = vadd(group.sum, n);
      group.members.push([entry, corner]);
    }
    for (const group of groups) {
      const n = vnorm(group.sum);
      if (verts[id].x < 1e-7) n[0] = 0;
      const welded = vnorm(n);
      for (const [entry, corner] of group.members) entry.normals[corner] = welded;
    }
  }
  const shade = (rec, kind) => {
    if (kind.ao !== undefined) return kind.ao;
    if (inner) return rec.wall ? 0.6 : 0.8;
    const low = rec.wall ? lerp(0.8, 1, smoothstep(0, 0.22, rec.f)) : 1;
    return low * (1 - Math.min(0.4, 6 * Math.max(0, pressed(rec))));
  };
  const emit = (mesh, pts, normals, part, ao) => {
    if (inner) mesh.face(pts[0], pts[1], pts[2], vscale(normals[0], -1), vscale(normals[1], -1), vscale(normals[2], -1), part, ao[0], ao[1], ao[2]);
    else mesh.face(pts[0], pts[1], pts[2], normals[0], normals[1], normals[2], part, ao[0], ao[1], ao[2]);
  };
  const edgeOwner = new Map();
  for (const entry of kept) {
    const { tri, kind, normals } = entry;
    const ao = tri.map((id) => shade(verts[id], kind));
    const separate = detail >= 3 && !inner;
    if (kind.glass && separate) {
      // See-through glass: the pane (its edge band a black frit) in the glass mesh.
      emit(glass, tri.map(place), normals, kind.frit ? P.trim : kind.dark ? P.grille : P.glass, [1, 1, 1]);
    } else if (kind.glass) {
      emit(body3, tri.map(place), normals, kind.frit ? P.trim : P.glass, [1, 1, 1]);
    } else {
      emit(body3, tri.map(place), normals, kind.part, ao);
      // A lamp's clear lens over its bowl, on the surface itself.
      if (kind.lamp && separate) emit(glass, tri.map((id) => point(verts[id])), tri.map(vertexNormal), kind.lens, [1, 1, 1]);
    }
    if (!inner && inset === 0) {
      for (let c = 0; c < 3; c += 1) {
        const i = tri[c];
        const j = tri[(c + 1) % 3];
        edgeOwner.set(i < j ? i * 1e7 + j : j * 1e7 + i, [i, j, kind.part]);
      }
    }
  }
  // The wheel arches' lips: the cut edge turned in toward the wheel.
  if (!inner && inset === 0 && detail >= 1) {
    const lipDepth = 0.035;
    for (const [i, j, part] of edgeOwner.values()) {
      const a = verts[i];
      const b = verts[j];
      if (!a.wall || !b.wall || Math.abs(fArch(a)) > 1e-4 || Math.abs(fArch(b)) > 1e-4) continue;
      const lip = (rec) => {
        const axle = Math.abs(rec.zf - axles[0]) < Math.abs(rec.zf - axles[1]) ? axles[0] : axles[1];
        return vnorm(v3(0, R - rec.y, axle - rec.zf));
      };
      const pa = place(i);
      const pb = place(j);
      const qa = vadd(pa, v3(-lipDepth, 0, 0));
      const qb = vadd(pb, v3(-lipDepth, 0, 0));
      const na = lip(a);
      const nb = lip(b);
      body3.face(pa, pb, qb, na, nb, nb, part === P.trim ? P.trim : P.paint, 0.7, 0.7, 0.45);
      body3.face(pa, qb, qa, na, nb, na, part === P.trim ? P.trim : P.paint, 0.7, 0.45, 0.45);
    }
  }
  // Where a head lamp's two projectors sit: the surface point and normal at a place along the lamp.
  const lampSpot = (along) => {
    let lo = 0;
    let hi = 1.2;
    const want = lampCentre + along * lampHalf;
    for (let i = 0; i < 30; i += 1) {
      const mid = (lo + hi) / 2;
      if (shape.arcAt(mid) < want) lo = mid;
      else hi = mid;
    }
    const a = (lo + hi) / 2;
    const top = wall(a, 1);
    const rec0 = { top: top.y, w: want };
    const f = clamp((lampY(rec0) - top.yBottom) / top.h, 0, 1);
    const at = wall(a, f);
    const rec = { wall: true, a, f, x: at.x, y: at.y, zf: at.zf };
    return { point: point(rec), normal: baseNormal(rec) };
  };
  return { body: body3, glass, shape, lampSpot, truck };
}

// ---------------------------------------------------------------- assembly
const mirrorX = Object.freeze({ point: (p) => [-p[0], p[1], p[2]], normal: (n) => [-n[0], n[1], n[2]] });
// A wheel put at a centre (flip: turned half round for the left side), fit = [width, radius] factors.
const placeAt = (offset, flip, fit = [1, 1]) => ({
  point: (p) => {
    const q = [p[0] * fit[0], p[1] * fit[1], p[2] * fit[1]];
    return flip ? [offset[0] - q[0], offset[1] + q[1], offset[2] - q[2]] : [offset[0] + q[0], offset[1] + q[1], offset[2] + q[2]];
  },
  normal: (n) => (flip ? [-n[0], n[1], -n[2]] : n),
});
const both = (target, half) => {
  target.append(half);
  target.append(half, mirrorX, true);
};

export function wheelCentres(name) {
  const body = CAR_BODIES[name];
  const x = body.width / 2 - WHEEL_INSET_M - body.tire_width / 2;
  const front = body.front_overhang - body.length / 2;
  return [[x, body.wheel_radius, front], [x, body.wheel_radius, front + body.wheelbase]];
}

// Everything on the right half of the body besides the shell, by detail:
// wheel-well liners, mirror, door handles, roof rail, bed rails.
function rightHalfFittings(out, name, detail) {
  const shape = bodyShape(name);
  const { body, L, W, axles, archRadius } = shape;
  const cab = body.cabin;
  const R = body.wheel_radius;
  const zOf = (zf) => zf - L / 2;
  const X = v3(1, 0, 0);
  // Wheel wells: a dark liner over each wheel and a wall behind it.
  const innerX = W - WHEEL_INSET_M - body.tire_width - 0.05;
  const sides = detail >= 3 ? 20 : detail >= 2 ? 12 : 8;
  for (const axle of axles) {
    const centre = v3(0, R, zOf(axle));
    const r = archRadius + 0.004;
    out.revolve(centre, X, [[r, W - 0.035], [r, innerX]], sides, () => P.under, { from: sides / 2 - 1, to: sides + 1, vOf: (i) => (i === 0 ? 0.45 : 0.25) });
    const n = v3(1, 0, 0);
    out.flat(v3(innerX, 0.12, zOf(axle - archRadius)), v3(innerX, R + archRadius, zOf(axle - archRadius)), v3(innerX, R + archRadius, zOf(axle + archRadius)), v3(innerX, 0.12, zOf(axle + archRadius)), n, P.under, 0.3);
  }
  if (detail >= 2) {
    // Mirror: a housing on a foot at the front corner of the side glass, its glass toward the rear.
    const zf = cab.windshield_base + 0.3;
    const belt = shape.top(zf);
    const reach = W + MIRROR_REACH_M;
    const inner = W - 0.03;
    const centre = v3((inner + reach) / 2, belt + 0.075, zOf(zf));
    if (detail >= 3) {
      out.roundedBox(centre, [(reach - inner) / 2, 0.06, 0.05], 0.026, (k, sign) => (k === 2 && sign > 0 ? P.mirror : P.paint), { taper: [1, 0, 0.72] });
      out.roundedBox(v3(W - 0.06, belt + 0.03, zOf(zf + 0.005)), [0.05, 0.02, 0.035], 0.015, P.gloss_black);
    } else {
      out.box(centre, [(reach - inner) / 2, 0.055, 0.042], (face) => (face === "+z" ? P.glass : P.paint));
      out.box(v3(W - 0.06, belt + 0.025, zOf(zf + 0.01)), [0.05, 0.02, 0.035], P.trim);
    }
    // Door handles: a bar over each pocket.
    for (const seam of doorSeams(body).slice(1)) {
      const hz = seam - 0.2;
      const point = shape.wall(1 + (hz - body.nose.corner) / (L - body.tail.corner - body.nose.corner), 1 - 0.115 / Math.max(0.3, shape.top(hz) - shape.bottom(hz)));
      if (detail >= 3) out.roundedBox(v3(point.x + 0.006, point.y, zOf(hz)), [0.012, 0.014, 0.085], 0.01, P.paint);
      else out.box(v3(point.x + 0.004, point.y, zOf(hz)), [0.01, 0.014, 0.08], P.trim);
    }
  }
  if (body.roof_rails && detail >= 1) {
    // Roof rail: a bar standing off the roof on feet, its top the car's height.
    const z0 = cab.windshield_top + 0.15;
    const z1 = cab.roof_end - 0.08;
    const x = W - cab.tumblehome - 0.05;
    const steps = detail >= 3 ? 14 : detail >= 2 ? 6 : 2;
    const zs = [];
    for (let i = 0; i <= steps; i += 1) zs.push(lerp(z0, z1, i / steps));
    const roof = zs.map((zf) => shape.lid(x, zf).y);
    const stand = body.height - Math.max(...roof);
    const half = 0.019;
    const pts = [];
    const nrm = [];
    zs.forEach((zf, i) => {
      const yTop = Math.min(body.height, roof[i] + stand - (i === 0 || i === steps ? 0.02 : 0));
      const yLow = detail >= 2 && i > 0 && i < steps ? yTop - 0.03 : roof[i] - 0.004;
      pts.push([[x - half, yLow], [x - half, yTop - 0.006], [x - half + 0.008, yTop], [x + half - 0.008, yTop], [x + half, yTop - 0.006], [x + half, yLow]].map(([px, py]) => v3(px, py, zOf(zf))));
      nrm.push([[-1, 0], [-0.9, 0.4], [-0.3, 1], [0.3, 1], [0.9, 0.4], [1, 0]].map(([nx, ny]) => vnorm(v3(nx, ny, 0))));
    });
    out.grid(pts, nrm, P.trim);
    if (detail >= 2) {
      const down = v3(0, -1, 0);
      for (let i = 1; i < steps - 1; i += 1) out.flat(pts[i][0], pts[i][5], pts[i + 1][5], pts[i + 1][0], down, P.trim, 0.6);
      for (const i of [0, steps]) {
        const n = v3(0, 0, i === 0 ? -1 : 1);
        out.flat(pts[i][0], pts[i][1], pts[i][4], pts[i][5], n, P.trim);
      }
    }
  }
  if (body.bed === "tonneau" && detail >= 2) out.box(v3(W - 0.07, shape.top(4.85) + 0.012, zOf(4.85)), [0.035, 0.012, 0.98], P.trim);
}

// Parts on the centre line or on one side only: wipers, antenna fin, the closed underside.
function centreFittings(out, name, detail) {
  const shape = bodyShape(name);
  const { body, L, W } = shape;
  const cab = body.cabin;
  const zOf = (zf) => zf - L / 2;
  if (detail < 3) {
    // The underside as one dark sheet (the hero level has an underbody).
    const y = body.clearance + 0.03;
    const down = v3(0, -1, 0);
    const z0 = zOf(body.nose.corner * 0.7);
    const z1 = zOf(L - body.tail.corner * 0.7);
    out.flat(v3(-W + 0.1, y, z0), v3(W - 0.1, y, z0), v3(W - 0.1, y, z1), v3(-W + 0.1, y, z1), down, P.under, 0.35);
  }
  if (detail >= 2) {
    // Wipers parked on the cowl: an arm and a blade each, lying along the glass's foot.
    for (const [x0, x1] of [[-0.62, -0.05], [0.02, 0.6]]) {
      const span = W * 0.9;
      const at = (x) => {
        const zf = cab.windshield_base + 0.09 + 0.2 * (x / W) ** 2 + 0.03 * ((x - x0 * span) / ((x1 - x0) * span));
        return v3(x, shape.lid(Math.abs(x), zf).y + 0.014, zOf(zf));
      };
      const a = at(x0 * span);
      const b = at(x1 * span);
      if (detail >= 3) {
        out.tube([a, at(lerp(x0, x1, 0.5) * span), b], 0.006, 5, P.rubber);
        out.tube([vadd(a, v3(0.02, 0.012, -0.03)), vadd(at(lerp(x0, x1, 0.55) * span), v3(0, 0.012, 0))], 0.005, 4, P.trim);
      } else out.tube([a, b], 0.008, 3, P.trim, { caps: false });
    }
    // Antenna fin at the back of the roof.
    if (!body.bed) {
      // Where the roof has begun to fall, and no taller than the car's height allows.
      const zf = cab.roof_end - 0.04;
      const y = shape.lid(0, zf).y;
      const high = Math.max(0.012, Math.min(0.05, body.height - 0.004 - y));
      out.roundedBox(v3(0, y + high / 2 - 0.004, zOf(zf)), [0.02, high / 2, 0.08], 0.012, P.gloss_black, { taper: [0, 1, 0.35] });
    }
  }
}

const builtCache = new Map();
// The meshes of one body at one level:
//   hero: {body, glass, wheel, brake}; other levels: {car (wheels and all), chassis (without), wheel}.
// The shadow level is {car}: the far body a little inside the surface, wheels and all.
export function buildCarParts(name, levelName) {
  const key = `${name}:${levelName}`;
  if (builtCache.has(key)) return builtCache.get(key);
  const body = CAR_BODIES[name];
  const shadow = levelName === "shadow";
  const level = LEVELS[shadow ? "far" : levelName];
  const shell = buildShell(name, shadow ? "far" : levelName, shadow ? { inset: 0.025 } : {});
  const detail = shadow ? 0 : level.detail;
  const half = new CarMesh();
  half.append(shell.body);
  if (!shadow) rightHalfFittings(half, name, detail);
  if (levelName === "hero") {
    // Two projectors in each head lamp's bowl: a bright ring round a dark lens.
    for (const along of shell.truck ? [-0.35, 0.35] : [-0.45, 0.1]) {
      const spot = shell.lampSpot(along);
      const centre = vsub(spot.point, vscale(spot.normal, 0.05));
      const r = shell.truck ? 0.05 : 0.036;
      half.revolve(centre, spot.normal, [[r + 0.008, 0], [r + 0.008, 0.03], [r, 0.034], [r - 0.004, 0.022]], 14, () => P.chrome, { crease: 50 });
      half.revolve(centre, spot.normal, [[r - 0.004, 0.022], [r * 0.6, 0.03], [0, 0.033]], 14, () => P.mirror);
    }
  }
  const chassis = new CarMesh();
  both(chassis, half);
  if (!shadow) centreFittings(chassis, name, detail);
  let result;
  if (levelName === "hero") {
    const glass = new CarMesh();
    both(glass, shell.glass);
    const lining = buildShell(name, "mid", { inner: true });
    both(chassis, lining.body);
    buildCabin(chassis, body, shell.shape);
    buildUnderbody(chassis, body, shell.shape);
    result = { body: chassis, glass, wheel: buildWheel(body, "hero"), brake: buildBrake(body) };
  } else {
    const wheel = buildWheel(body, level.wheel);
    const car = new CarMesh();
    car.append(chassis);
    // The shadow caster's wheels are thinner and a little smaller, so they
    // never shade the faces of the wheels drawn over them.
    const fit = shadow ? [0.5, 0.97] : [1, 1];
    for (const centre of wheelCentres(name)) {
      car.append(wheel, placeAt(centre, false, fit));
      car.append(wheel, placeAt([-centre[0], centre[1], centre[2]], true, fit));
    }
    result = { car, chassis, wheel };
  }
  builtCache.set(key, result);
  return result;
}

// A car as one mesh in the sixteen shared parts (UV.x = (part + 0.5) / 16):
// the yard kit's cargo van takes level 0 (mid) and 1 (far) this way.
export function buildCar(name, lodIndex, { wheels = true } = {}) {
  const parts = buildCarParts(name, lodIndex === 0 ? "mid" : "far");
  const mesh = (wheels ? parts.car : parts.chassis).result();
  const uvs = mesh.uvs.slice();
  for (let i = 0; i < uvs.length; i += 2) uvs[i] = (CAR_PART_AS_BASE[Math.floor(uvs[i] * CAR_PART_COUNT)] + 0.5) / 16;
  return { ...mesh, uvs };
}

// The clutter kit's car meshes (the web build and the desktop both ship them):
// near and far, the shadow caster, and the driven car's near chassis, wheel
// and axle markers (named tyre: Godot's importer turns a node whose name ends
// in "wheel" into a VehicleWheel3D).
export function carKitMeshes() {
  const meshes = [];
  for (const name of Object.keys(CAR_BODIES)) {
    meshes.push({ name: `car_${name}_lod0`, ...buildCarParts(name, "near").car.result() });
    meshes.push({ name: `car_${name}_lod1`, ...buildCarParts(name, "far").car.result() });
    meshes.push({ name: `car_${name}_shadow`, ...buildCarParts(name, "shadow").car.result() });
  }
  return meshes;
}
export function carKitExtras() {
  const extras = [];
  for (const name of Object.keys(CAR_BODIES)) {
    const geometry = carBodyGeometry(name);
    extras.push({ name: `car_${name}_chassis_lod0`, ...buildCarParts(name, "near").chassis.result() });
    extras.push({ name: `car_${name}_tyre_lod0`, ...buildCarParts(name, "near").wheel.result() });
    extras.push({ name: `car_${name}_axle_front`, marker: true, translation: [...geometry.wheels.front_right] });
    extras.push({ name: `car_${name}_axle_rear`, marker: true, translation: [...geometry.wheels.rear_right] });
  }
  return extras;
}
// The hero kit's meshes (street_car_hero_kit.glb, left out of the web build).
export function carHeroKitMeshes() {
  const meshes = [];
  for (const name of Object.keys(CAR_BODIES)) {
    const parts = buildCarParts(name, "hero");
    meshes.push({ name: `car_${name}_hero_body`, ...parts.body.result() });
    meshes.push({ name: `car_${name}_hero_glass`, ...parts.glass.result() });
    meshes.push({ name: `car_${name}_hero_tyre`, ...parts.wheel.result() });
    meshes.push({ name: `car_${name}_hero_brake`, ...parts.brake.result() });
  }
  return meshes;
}

// Key dimensions of a car body, in one place for whatever places or drives a
// car. length_m and width_m are the body's plan rectangle (mirrors excluded);
// the track is between the tyre centre planes; each wheel centre is [x, y, z]
// in the car frame; bounds_m is the near mesh's box (mirrors, roof rails and
// the bowed nose and tail included), which the shape is built to fill exactly.
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
  const min = [-(body.width / 2 + MIRROR_REACH_M), 0, -(body.length / 2 + NOSE_BOW_M)];
  const max = [body.width / 2 + MIRROR_REACH_M, body.height, body.length / 2 + TAIL_BOW_M];
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
