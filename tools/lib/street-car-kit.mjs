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
import { CALIPER_ANGLE, CAR_PART_AS_BASE, CAR_PART_COUNT, CAR_PARTS, CarMesh, FILLER_DOOR, P, brakeLight, buildBrake, buildCabin, buildUnderbody, buildWheel, doorHandle, fillerDoor, numberPlate, sideReflector, underFloor, underFloorY } from "./street-car-parts.mjs";

export { CALIPER_ANGLE, CAR_PART_COUNT, CAR_PARTS };

// ---------------------------------------------------------------- car bodies
// Lengths in metres. Profiles run from the front bumper (0) to the rear (length).
//   height: the top of the car (the roof's crown, or the roof rails)
//   hood: [distance from front, top of the body] from the front face to the windshield base
//   cabin: windshield base and top, roof end, rear glass base, roof height and crown;
//     glass_top (a high-roof van): the height the windshield and door glass rise
//     to, under a painted cap that carries on up to the roof
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
    // The cab's belt ends where its back pillar starts, so the step up to the service body's side spans its pillar.
    belt: [[1.75, 1.25], [3.72, 1.28]],
    deck: [[3.84, 1.5], [6.2, 1.5]],
    // The cab back comes down onto the service body's top (rear_base where the body starts).
    cabin: { windshield_base: 1.75, windshield_top: 2.38, roof_end: 3.7, rear_base: 3.84, roof: 1.95, crown: 0.02, tumblehome: 0.16, rear_drop: 0.03 },
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
    cabin: { windshield_base: 0.98, windshield_top: 1.42, glass_top: 1.95, roof_end: 5.82, rear_base: 5.9, roof: 2.62, crown: 0.03, tumblehome: 0.12, rear_drop: 0.03 },
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
  // A high-roof van's windshield stops at glass_top, and a painted cap carries
  // the same rake on up to the roof.
  const glassTop = cab.glass_top ?? cab.roof - 0.03;
  const roofCap = cab.glass_top
    ? [
        [cab.windshield_top + 0.12, lerp(glassTop, cab.roof, 0.5)],
        [cab.windshield_top + 0.3, cab.roof - 0.02],
      ]
    : [];
  const roofLine = curve([
    [cab.windshield_base, cowl],
    [lerp(cab.windshield_base, cab.windshield_top, 0.3), lerp(cowl, glassTop, 0.34)],
    [lerp(cab.windshield_base, cab.windshield_top, 0.7), lerp(cowl, glassTop, 0.78)],
    [cab.windshield_top, glassTop],
    ...roofCap,
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
    // A pickup's tailgate top is square like its bed rails, so the bed's style carries round onto it.
    const bed = body.bed ? smoothstep(bedFrom, bedFrom + 0.08, zf) * (front ? round : 1) : 0;
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

  // The roof surface: the centre profile (hood, windshield, roof, rear glass,
  // deck), bowed in plan (the windshield's sides sit further back, a saloon's
  // rear glass's further forward) and crowned across the car. The bow eases in
  // from the nose and out before the tail, and never changes by as much as the
  // car's length does (|bowAt'| < 1), so the lid's rows can follow it: each row
  // is a line of constant zq = zf - bowAt(zf) (x / W)^2 from the shoulder to the
  // centre line. A hatch's glass and a pickup's cab back run straight across.
  const frontBow = 0.2;
  const rearBow = hasTrunk && !body.bed ? 0.12 : 0;
  // The end faces bulge by NOSE_BOW_M and TAIL_BOW_M at the centre line (u²
  // across, as the plan outline), and the rows near them follow that bulge; the
  // windshield's and rear glass's bow is flat at the shoulder (u²(2 - u²)), so
  // rows leave the shoulder square to the side and never run along it.
  const across = (x) => (x / W) ** 2;
  const acrossFlat = (x) => {
    const s = (x / W) ** 2;
    return s * (2 - s);
  };
  const endBow = (zf) => NOSE_BOW_M * (1 - smoothstep(nose.corner, nose.corner + 0.5, zf)) - TAIL_BOW_M * smoothstep(L - tail.corner - 0.5, L - tail.corner, zf);
  const cabinBow = (zf) =>
    frontBow * smoothstep(nose.corner, Math.max(nose.corner + 0.3, cab.windshield_base - 0.1), zf) * (1 - smoothstep(cab.windshield_top - 0.15, cab.windshield_top + 0.45, zf)) -
    rearBow * smoothstep(cab.roof_end - 0.45, cab.roof_end + 0.02, zf) * (1 - smoothstep(Math.min(cab.rear_base, L - tail.corner - 0.45), L - tail.corner, zf));
  const bowOffset = (x, zf) => endBow(zf) * across(x) + cabinBow(zf) * acrossFlat(x);
  const zqAt = (x, zf) => zf - bowOffset(x, zf);
  // The zf where the row of constant zq crosses x.
  const rowZf = (zq, x) => {
    let zf = zq;
    for (let i = 0; i < 32; i += 1) {
      const next = zq + bowOffset(x, zf);
      if (Math.abs(next - zf) < 1e-10) return next;
      zf = next;
    }
    return zf;
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
    // The shoulder's height follows the lid's (bowed) contours, so the hood
    // and the deck meet it level and never dip inside it.
    const yTop = top(clamp(zqAt(o.x, zfTop), 0, L)) - st.drop;
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
    // The shoulder's inward normal there (it runs round the right half from the
    // front centre line to the rear one, so inward is its direction turned left).
    const tl = Math.hypot(q.x - p.x, q.zf - p.zf) || 1;
    const tx = (q.x - p.x) / tl;
    const tz = (q.zf - p.zf) / tl;
    return { dist: Math.sqrt(best), y: lerp(p.y, q.y, t), zeta: lerp(p.zeta, q.zeta, t), bed: lerp(p.bed, q.bed, t), k: lerp(p.k, q.k, t), slope: lerp(p.slope, q.slope, t), inward: [-tz, tx] };
  };

  const roofHalf = W - cab.tumblehome + 0.08;
  const roofAt = (x, zf) => {
    const zq = zqAt(x, zf);
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
    // Never below the shoulder it rises from (the roof's crown keeps falling
    // past the roof's own width, over a deck or a rear glass's foot).
    const surface = smax(roof.y, nb.y, 0.012);
    // The blend's radius grows from nothing at the shoulder, where the lid must
    // start at the wall's top (a full radius there dips up to k/4 below it).
    const k = nb.k * smooth(nb.dist / nb.k);
    return { y: smin(surface, side, Math.max(1e-4, k)), g: side - surface, zq: roof.zq, dist: nb.dist, belt: nb.y, zeta: nb.zeta, bed: nb.bed, k: nb.k, inward: nb.inward };
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
  const shape = { body, L, W, axles, archRadius, top, bottom, roofLine, peakZ, crown, cowl, tailTop, hasTrunk, sideEnd, outline, wall, lid, roofAt, zqAt, rowZf, arcAt, arcTotal: arc[ARC_STEPS], glassInset, FACE_F };
  shapeCache.set(name, shape);
  return shape;
}

// ---------------------------------------------------------------- the shell
// The body shell of one level as a mesh in the shape's (station, ring)
// parameters, cut along every region's outline, then written out with normals
// from the surface. options: inner (the cabin's lining: the shell a little
// inside, facing in, open where the glass is), inset (metres inside the
// surface: the shadow caster).
// How far in from the shoulder a lid crease is looked for (m), and how wide
// each column before it must stay when one is pulled onto it.
const CREASE_CLEAR_M = 0.003;
const CREASE_COLUMN_MIN_M = 0.006;
// How deep a head lamp's and a tail lamp's bowls are at most (m).
const HEAD_BOWL_M = 0.03;
const TAIL_BOWL_M = 0.015;
// How close to a region's outline a vertex counts as on it, by level (m).
const REGION_SNAP_M = Object.freeze({ hero: 1.5e-3, near: 3e-3, mid: 6e-3, far: 0.012 });
// How far behind the deck line's start a tonneau cover begins (m).
const TONNEAU_SET_BACK_M = 0.04;
// The gap between a pickup's cab and its bed or service body, from the cab
// back's foot (m): it runs across the top and down both sides.
const BED_GAP_M = 0.05;
function buildShell(name, levelName, { inner = false, inset = 0 } = {}) {
  const shape = bodyShape(name);
  const { body, L, W, axles, archRadius, wall, lid, zqAt, rowZf } = shape;
  const level = LEVELS[levelName];
  const detail = inner ? 1 : inset > 0 ? 0 : level.detail;
  const cab = body.cabin;
  const nose = body.nose;
  const tail = body.tail;
  const R = body.wheel_radius;

  // --- Stations round the outline: the wall's columns. Each end face gets as
  // many as the lid has columns, for the face is the lid's first (last) row.
  const C = level.lid;
  const stations = [];
  for (let i = 0; i <= C; i += 1) stations.push((0.5 * i) / C);
  for (let i = 1; i <= level.corner; i += 1) stations.push(0.5 + (0.5 * i) / level.corner);
  const sideFrom = nose.corner;
  const sideTo = L - tail.corner;
  // A station's lid row runs at the zq of its shoulder point; the lid's keys
  // (its creases) are zq values, put on the side station whose row has that zq.
  const rowZq = (a) => {
    const edge = wall(a, 1);
    return zqAt(edge.x, edge.zf);
  };
  const sideStation = (zq) => {
    let lo = 1;
    let hi = 2;
    for (let i = 0; i < 40; i += 1) {
      const mid = (lo + hi) / 2;
      if (rowZq(mid) < zq) lo = mid;
      else hi = mid;
    }
    return (lo + hi) / 2;
  };
  const keys = [shape.peakZ, cab.windshield_base, cab.windshield_top, cab.roof_end, cab.rear_base];
  // Rows on the cowl's, the deck's and the roof's back edges themselves (fCowl;
  // the deck line's start; fRoof and fRear), so their cuts run along a row
  // instead of a few millimetres beside one.
  const roofBack = cab.roof_end + Math.min(0.035, 0.2 * (cab.rear_base - cab.roof_end));
  // The hood's shut line ends on the row whose shoulder turns from the hood's
  // roll to the side glass's (zeta 0.6), so its end runs along that row.
  let hoodEndA = 1;
  {
    let lo = 1;
    let hi = sideStation(cab.windshield_base + 0.06);
    for (let i = 0; i < 40; i += 1) {
      const mid = (lo + hi) / 2;
      if (wall(mid, 1).st.zeta < 0.6) lo = mid;
      else hi = mid;
    }
    hoodEndA = (lo + hi) / 2;
  }
  const hoodEndZq = rowZq(hoodEndA);
  if (detail >= 2) keys.push(cab.windshield_base - 0.065, cab.rear_base + 0.05, roofBack, hoodEndZq);
  // A tonneau cover's front edge runs along a row of its own.
  if (body.bed === "tonneau") keys.push(cab.rear_base + 0.05 + TONNEAU_SET_BACK_M);
  const steps = Math.max(2, Math.ceil((sideTo - sideFrom) / level.step));
  const regular = [];
  for (let i = 1; i < steps; i += 1) regular.push(1 + i / steps);
  const minGap = (level.step * 0.3) / (sideTo - sideFrom);
  const sideA = keys.filter((zq) => zq > rowZq(1) + 0.02 && zq < rowZq(2) - 0.02).map(sideStation);
  for (const a of regular) if (sideA.every((key) => Math.abs(key - a) > minGap)) sideA.push(a);
  // A station at every dip and crest of the centre line (a cab back meeting a
  // service body, a cowl), so no triangle bridges one.
  const centreHeight = (a) => lid(0, rowZq(a)).y;
  {
    const SAMPLES = 600;
    const heights = [];
    for (let i = 0; i <= SAMPLES; i += 1) heights.push(centreHeight(1 + i / SAMPLES));
    for (let i = 1; i < SAMPLES; i += 1) {
      const d0 = heights[i] - heights[i - 1];
      const d1 = heights[i + 1] - heights[i];
      const a = 1 + i / SAMPLES;
      if (d0 * d1 < 0 && Math.abs(d0 - d1) > 2e-4 && sideA.every((b) => Math.abs(b - a) > 0.4 / SAMPLES)) sideA.push(a);
    }
  }
  sideA.sort((a, b) => a - b);
  for (const a of sideA) stations.push(a);
  for (let i = 0; i <= level.corner; i += 1) stations.push(2 + (0.5 * i) / level.corner);
  for (let i = 1; i <= C; i += 1) stations.push(2.5 + (0.5 * i) / C);
  // More stations where the roof line is steep (a windshield, a hatch, a van's
  // back), so no triangle spans much of its height; never on an end face.
  const maxDrop = { hero: 0.13, near: 0.2, mid: 0.3, far: 0.5 }[levelName];
  for (let i = C; i < stations.length - C - 1; i += 1) {
    if (stations[i + 1] - stations[i] > 2e-4 && Math.abs(centreHeight(stations[i + 1]) - centreHeight(stations[i])) > maxDrop) {
      stations.splice(i + 1, 0, (stations[i] + stations[i + 1]) / 2);
      i -= 1;
    }
  }
  const K = stations.length;
  const wallF = level.wall;
  const nW = wallF.length - 1;
  // The lid: rows 0..NR across the car, each a line of constant zq from the
  // shoulder (column 0) to the centre line (column C). Row 0 is the front face's
  // shoulder (its stations, from its edge in to the centre line), row NR the
  // rear face's, and every row between is a corner or side station's. So the
  // lid's steep bands (the roll over a bumper, the side glass, a windshield, a
  // cab back) run along its rows and columns, never across a triangle.
  const FRONT_EDGE = C;
  const REAR_EDGE = K - 1 - C;
  const NR = REAR_EDGE - FRONT_EDGE;
  const rowA = (r) => stations[FRONT_EDGE + r];
  const faceA = (r, cf) => (r === 0 ? (0.5 * (C - cf)) / C : 2.5 + (0.5 * cf) / C);
  const rowShoulder = [];
  for (let r = 0; r <= NR; r += 1) {
    const edge = wall(rowA(r), 1);
    rowShoulder.push({ x: edge.x, zq: zqAt(edge.x, edge.zf) });
  }
  // A row's points along it: spread by the section's length, so the steep side
  // glass and the roof rail get their share, turning to even steps toward the
  // end faces (whose columns are their stations).
  const columnTable = rowShoulder.map((shoulder, r) => {
    const even = Array.from({ length: C + 1 }, (_, c) => c / C);
    if (r === 0 || r === NR) return even;
    const samples = 40;
    const lengths = [0];
    let last = [shoulder.x, lid(shoulder.x, rowZf(shoulder.zq, shoulder.x)).y];
    for (let i = 1; i <= samples; i += 1) {
      const x = shoulder.x * (1 - i / samples);
      const y = lid(x, rowZf(shoulder.zq, x)).y;
      lengths.push(lengths[i - 1] + Math.hypot(x - last[0], y - last[1]));
      last = [x, y];
    }
    const total = lengths[samples] || 1;
    const table = [0];
    let s = 0;
    for (let j = 1; j < C; j += 1) {
      const want = j / C;
      while (s < samples - 1 && 0.7 * (lengths[s + 1] / total) + 0.3 * ((s + 1) / samples) < want) s += 1;
      const lo = 0.7 * (lengths[s] / total) + 0.3 * (s / samples);
      const hi = 0.7 * (lengths[s + 1] / total) + 0.3 * ((s + 1) / samples);
      table.push((s + (hi > lo ? (want - lo) / (hi - lo) : 0)) / samples);
    }
    table.push(1);
    const a = rowA(r);
    const w = a < 1 ? clamp((a - 0.5) / 0.5, 0, 1) : a > 2 ? clamp((2.5 - a) / 0.5, 0, 1) : 1;
    return table.map((xi, c) => lerp(even[c], xi, w));
  });
  // The lid's crease all round (where the roll up from the shoulder meets the
  // top surface: a hood's or a deck's edge, the A pillars, the roof rails, the
  // C and D pillars) runs along one column, so no triangle bridges it.
  {
    const creaseXi = (r) => {
      const shoulder = rowShoulder[r];
      const g = (xi) => {
        const x = shoulder.x * (1 - xi);
        return lid(x, rowZf(shoulder.zq, x)).g;
      };
      // A crease within a centimetre of the shoulder (a hood's or a deck's
      // edge, whose roll is a few millimetres) already runs along column 0:
      // pulling a column onto it squeezed the columns before it into a strip
      // a few millimetres wide, and the cut lines crossing the shoulder there
      // left slivers turned inside out.
      const SAMPLES = 80;
      const xi0 = Math.min(0.1, CREASE_CLEAR_M / Math.max(shoulder.x, 1e-3));
      let prev = g(xi0);
      for (let i = 1; i <= SAMPLES; i += 1) {
        const xi = xi0 + (0.6 * i) / SAMPLES;
        const here = g(xi);
        if (prev < 0 !== here < 0) {
          let lo = xi - 0.6 / SAMPLES;
          let hi = xi;
          for (let k = 0; k < 30; k += 1) {
            const mid = (lo + hi) / 2;
            if (g(mid) < 0 === prev < 0) lo = mid;
            else hi = mid;
          }
          return (lo + hi) / 2;
        }
        prev = here;
      }
      return null;
    };
    const found = [];
    for (let r = 1; r < NR; r += 1) found.push([r, creaseXi(r)]);
    const known = found.filter(([, xi]) => xi !== null).map(([, xi]) => xi).sort((p, q) => p - q);
    if (known.length > 0) {
      const median = known[Math.floor(known.length / 2)];
      // The column whose share along a side row is nearest the crease's; never
      // the first, so the side glass between the belt and the rail keeps a
      // column of its own: its outline is only cut where a column inside it
      // meets one outside (with a long hood and deck, most rows' creases lie
      // close to the shoulder, and the glass was once a single painted strip).
      const sideRow = Math.floor(NR / 2);
      let cr = Math.min(2, C - 1);
      for (let c = cr; c < C; c += 1) if (Math.abs(columnTable[sideRow][c] - median) < Math.abs(columnTable[sideRow][cr] - median)) cr = c;
      for (const [r, xi] of found) {
        if (xi === null) continue;
        const table = columnTable[r];
        const was = table[cr];
        const a = rowA(r);
        const w = a < 1 ? clamp((a - 0.5) / 0.5, 0, 1) : a > 2 ? clamp((2.5 - a) / 0.5, 0, 1) : 1;
        const want = lerp(was, xi, w);
        // Not where the columns before it would be squeezed narrower than
        // CREASE_COLUMN_MIN_M each (a crease close by the shoulder, which
        // column 0 already follows): the cuts crossing such a strip left
        // slivers turned over.
        if (want * rowShoulder[r].x < CREASE_COLUMN_MIN_M * cr) continue;
        // Columns before it squeeze or stretch toward the shoulder, those after toward the centre line.
        for (let c = 1; c < C; c += 1) {
          if (c < cr) table[c] = (table[c] / was) * want;
          else if (c > cr) table[c] = want + ((table[c] - was) / (1 - was)) * (1 - want);
        }
        table[cr] = want;
      }
    }
  }
  // Rows never cross: an inner row whose shoulder sits at or before the row in
  // front of it (a face leaning back round its corner) runs a hair behind it,
  // leaving its own shoulder point within its first column.
  const faceZq = (r) => {
    let best = r === 0 ? -Infinity : Infinity;
    for (let c = 0; c <= C; c += 1) {
      const p = wall(faceA(r, c), 1);
      const zq = zqAt(p.x, p.zf);
      best = r === 0 ? Math.max(best, zq) : Math.min(best, zq);
    }
    return best;
  };
  const rowZqInner = rowShoulder.map((shoulder) => shoulder.zq);
  {
    // Rows whose shoulder lies at or past an end face's line (a face that
    // rolls over further than its corner) are spread evenly between the last
    // row clear of it and the face.
    const ROW_GAP = 2e-3;
    const front = faceZq(0) + ROW_GAP;
    const rear = faceZq(NR) - ROW_GAP;
    let first = 1;
    while (first < NR && rowZqInner[first] <= front + ROW_GAP * (first - 1)) first += 1;
    for (let r = 1; r < first; r += 1) rowZqInner[r] = lerp(front, rowZqInner[first], (r - 1) / Math.max(1, first - 1));
    let last = NR - 1;
    while (last > 0 && rowZqInner[last] >= rear - ROW_GAP * (NR - 1 - last)) last -= 1;
    for (let r = NR - 1; r > last; r -= 1) rowZqInner[r] = lerp(rear, rowZqInner[last], (r - (NR - 1)) / Math.min(-1, last - (NR - 1)));
    // A corner whose face leans back can turn its shoulder a hair backwards:
    // rows keep at least a fraction of a millimetre apart.
    const STEP = 2e-4;
    for (let r = 1; r < NR; r += 1) rowZqInner[r] = Math.max(rowZqInner[r], (r === 1 ? faceZq(0) : rowZqInner[r - 1]) + STEP);
    for (let r = NR - 1; r >= 1; r -= 1) rowZqInner[r] = Math.min(rowZqInner[r], (r === NR - 1 ? faceZq(NR) : rowZqInner[r + 1]) - STEP);
    for (let r = 1; r < NR; r += 1) {
      if (rowZqInner[r] <= (r === 1 ? faceZq(0) : rowZqInner[r - 1]) || rowZqInner[r] >= faceZq(NR)) throw new Error(`${name} ${levelName}: lid rows ${r - 1} and ${r} cross`);
    }
  }
  // [x, zq] on row r (an integer) at column cf.
  const rowPoint = (r, cf) => {
    if (r === 0 || r === NR) {
      const p = wall(faceA(r, cf), 1);
      return [p.x, zqAt(p.x, p.zf)];
    }
    const table = columnTable[r];
    const c0 = clamp(Math.floor(cf), 0, C - 1);
    const xi = lerp(table[c0], table[c0 + 1], cf - c0);
    const zq = cf >= 1 ? rowZqInner[r] : lerp(rowShoulder[r].zq, rowZqInner[r], cf);
    return [rowShoulder[r].x * (1 - xi), zq];
  };

  // --- Records of the surface: position and what the regions read. A wall
  // record sits at (station, ring) of the wall's grid, a lid record at (row,
  // column) of the lid's; the seam between them (the wall's top ring, the
  // lid's column 0 and end rows) is the wall's own top, read from either side.
  const record = (kf, v) => {
    const k0 = clamp(Math.floor(kf), 0, K - 2);
    const t = kf - k0;
    const a = lerp(stations[k0], stations[k0 + 1], t);
    const j = clamp(Math.floor(v), 0, nW - 1);
    const f = lerp(wallF[j], wallF[j + 1], v - j);
    const p = wall(a, f);
    const w = shape.arcAt(a);
    return { kf, v, wall: true, a, f, x: p.x, y: p.y, zf: p.zf, e: p.e, front: p.front, top: p.yTop, bottom: p.yBottom, h: p.h, w, wr: shape.arcTotal - w, zeta: p.st.zeta, bed: p.st.bed };
  };
  const lidRecord = (rf, cf) => {
    const r0 = clamp(Math.floor(rf), 0, NR - 1);
    const t = rf - r0;
    const p0 = rowPoint(r0, cf);
    const p1 = rowPoint(r0 + 1, cf);
    let x = lerp(p0[0], p1[0], t);
    let zq = lerp(p0[1], p1[1], t);
    if (cf < 1 && t > 0 && t < 1) {
      // Near the shoulder the lid follows the wall's top between stations, not its chord.
      const q0 = rowPoint(r0, 0);
      const q1 = rowPoint(r0 + 1, 0);
      const seam = wall(lerp(rowA(r0), rowA(r0 + 1), t), 1);
      const w = 1 - cf;
      x += w * (seam.x - lerp(q0[0], q1[0], t));
      zq += w * (zqAt(seam.x, seam.zf) - lerp(q0[1], q1[1], t));
    }
    x = Math.max(0, x);
    const zf = rowZf(zq, x);
    const at = lid(x, zf);
    return { rf, cf, wall: false, x, y: at.y, zf, zq: at.zq, g: at.g, dist: at.dist, belt: at.belt, zeta: at.zeta, bed: at.bed, k: at.k, inward: at.inward, front: zf < L / 2, e: 0 };
  };
  // A record in a patch's own parameters.
  const recordIn = (lidPatch, p0, p1) => (lidPatch ? lidRecord(p0, p1) : record(p0, p1));
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
    let dx;
    let dz;
    if (rec.inward && rec.dist < 3 * h) {
      // At the shoulder the lid ends: a difference across its edge reads the
      // lid's continuation outside it and tilts the normal toward the wall's,
      // differently a hair either way. Step inward from the shoulder instead,
      // and along it.
      const [ux, uz] = rec.inward;
      const [vx, vz] = [uz, -ux];
      const y0 = lid(x, rec.zf).y;
      const du = (lid(x + 3 * h * ux, rec.zf + 3 * h * uz).y - y0) / (3 * h);
      const dv = (lid(x + h * vx, rec.zf + h * vz).y - lid(x - h * vx, rec.zf - h * vz).y) / (2 * h);
      dx = du * ux + dv * vx;
      dz = du * uz + dv * vz;
    } else {
      dx = (lid(x + h, rec.zf).y - lid(x - h, rec.zf).y) / (2 * h);
      dz = (lid(x, rec.zf + h).y - lid(x, rec.zf - h).y) / (2 * h);
    }
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
  // How close to an outline a vertex counts as on it (the cuts' snap), and so
  // how far past a groove line's end its domain reaches: a vertex snapped onto
  // the end must still read the line, or the triangles round it go uncut.
  const SNAP_M = 1.5e-3;
  // A groove line's ends: cut along each beside the line first (pre-cuts, read
  // across the end), so no triangle reaches past an end uncut and turns into a
  // dark wedge of groove. near: within LINE_END_NEAR_M of the line (wider than
  // a triangle, or one reaching past it is never cut); across: the end's
  // function, zero on it.
  const LINE_END_NEAR_M = 0.25;
  const lineEnds = (fn, near, ...across) => {
    fn.pre = [...(fn.pre ?? []), ...across.map((end) => region(near, end))];
    return fn;
  };
  // Where the side glass ends: a van's cab door, a pickup's cab back less its
  // corner pillar, otherwise a real C or D pillar's width ahead of the rear
  // glass, so the roof never floats on glass that wraps round the corner.
  const sideGlassEnd = body.pillars.cargo_from ? body.pillars.cargo_from - 0.05 : body.bed ? cab.rear_base - 0.1 : body.pillars.quarter_glass ? cab.roof_end - 0.12 : cab.roof_end - 0.05;
  const max3 = (a, b, c, k) => smax(smax(a, b, k), c, k);
  const archDistance = (rec) => Math.min(Math.hypot(rec.zf - axles[0], rec.y - R), Math.hypot(rec.zf - axles[1], rec.y - R));
  const nearArch = (rec) => rec.wall && (Math.abs(rec.zf - axles[0]) < archRadius + 0.25 || Math.abs(rec.zf - axles[1]) < archRadius + 0.25);
  const fArch = region(nearArch, (rec) => archDistance(rec) - archRadius);
  // A high-roof van's door glass stops at glass_top, under the painted side.
  const sideGlassTop = cab.glass_top ?? Infinity;
  const fSide = region(onLid, (rec) => smax(smax(max3(rec.belt + 0.028 - rec.y, rec.g + rec.k + 0.006, cab.windshield_base + 0.16 - rec.zf, 0.03), rec.zf - sideGlassEnd, 0.03), rec.y - (sideGlassTop - 0.02), 0.03));
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
  // The windshield's deeper frit band along its foot: about 7 cm up the glass
  // from where the glass starts (wb + 0.06), however steep it stands (a van's
  // would otherwise rise past a driver's eyes seen from in front).
  const windshieldSlope = (shape.roofLine(cab.windshield_top) - shape.cowl) / (cab.windshield_top - cab.windshield_base);
  const fritFoot = region((rec) => !rec.wall && fWind.fn(rec) < 0.02, (rec) => rec.zq - (cab.windshield_base + 0.06 + 0.07 / Math.hypot(1, windshieldSlope)));
  const rearSpan = cab.rear_base - cab.roof_end;
  const fRear = region(onLid, (rec) => smax(max3(roofBack - rec.zq, rec.zq - (cab.rear_base - Math.min(0.045, 0.25 * rearSpan)), rec.k + 0.03 - rec.g, 0.03), shape.tailTop + 0.05 - rec.y, 0.03));
  const fGlassRoof = region((rec) => !rec.wall && body.glass_roof === true, (rec) => max3(cab.windshield_top + 0.1 - rec.zq, rec.zq - (cab.roof_end - 0.1), rec.k + 0.07 - rec.g, 0.05));
  const fRoof = region(onLid, (rec) => Math.max(cab.windshield_top - 0.035 - rec.zq, rec.zq - roofBack, -(rec.g + rec.k * 0.6)));
  const fCowl = region(onLid, (rec) => Math.max(Math.abs(rec.zq - cab.windshield_base) - 0.065, 0.02 - rec.g));
  fCowl.pre = [region(onLid, (rec) => rec.zq - (cab.windshield_base - 0.065)), region(onLid, (rec) => rec.zq - (cab.windshield_base + 0.065))];
  const hoodLine = lineEnds(
    region((rec) => !rec.wall && rec.zq < hoodEndZq + SNAP_M, (rec) => rec.dist - 0.075),
    (rec) => !rec.wall && Math.abs(rec.dist - 0.075) < LINE_END_NEAR_M,
    (rec) => rec.zq - hoodEndZq,
  );
  const deckFrom = cab.rear_base + 0.05;
  const deckLine = lineEnds(
    region((rec) => !rec.wall && (shape.hasTrunk || body.bed !== undefined) && rec.zq > deckFrom - SNAP_M, (rec) => rec.dist - 0.07),
    (rec) => !rec.wall && (shape.hasTrunk || body.bed !== undefined) && Math.abs(rec.dist - 0.07) < LINE_END_NEAR_M,
    (rec) => rec.zq - deckFrom,
  );
  const fTonneau = region((rec) => !rec.wall && body.bed === "tonneau", (rec) => Math.max(deckFrom + TONNEAU_SET_BACK_M - rec.zq, 0.075 - rec.dist));
  // A pickup's cab and its bed are two bodies: the gap between them (where the
  // cab back's foot, the bed's front and the sides meet, a fan of thin
  // triangles caught the light) reads dark. Its edges are rows and stations.
  const fBedGap = region((rec) => body.bed !== undefined && (rec.wall ? onSide(rec) : true), (rec) => {
    const at = rec.wall ? rec.zf : rec.zq;
    return Math.max(cab.rear_base - at, at - (cab.rear_base + BED_GAP_M));
  });
  const sill = (rec) => rec.bottom + 0.105;
  // A door seam stops on the sill line's centre, the sill line on the first
  // and last seams' centres: both are cut, so no triangle straddles an end.
  const seamLines = seams.map((zf) =>
    lineEnds(
      region((rec) => onSide(rec) && rec.y >= sill(rec) - SNAP_M, (rec) => rec.zf - zf),
      (rec) => onSide(rec) && Math.abs(rec.zf - zf) < LINE_END_NEAR_M,
      (rec) => rec.y - sill(rec),
    ),
  );
  const sillLine = lineEnds(
    region((rec) => onSide(rec) && rec.zf >= seams[0] - SNAP_M && rec.zf <= seams.at(-1) + SNAP_M, (rec) => rec.y - sill(rec)),
    (rec) => onSide(rec) && Math.abs(rec.y - sill(rec)) < LINE_END_NEAR_M,
    (rec) => rec.zf - seams[0],
    (rec) => rec.zf - seams.at(-1),
  );
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
  const fGarnish = boxRegion((rec) => onTailFace(rec) && !body.bed, (rec) => rec.x, (rec) => rec.y - (rearPlateY(rec) + 0.135), Math.min(0.34, tailCentre - tailHalf - 0.03), 0.014, 0.012);
  const bumperLine = lineEnds(
    region((rec) => onTail(rec) && !body.bed && rec.wr < tailEdge + tail.corner * 1.2 + SNAP_M, (rec) => rec.y - (rec.bottom + 0.34 * rec.h)),
    (rec) => onTail(rec) && !body.bed && Math.abs(rec.y - (rec.bottom + 0.34 * rec.h)) < LINE_END_NEAR_M,
    (rec) => rec.wr - (tailEdge + tail.corner * 1.2),
  );
  // The tailgate's sides stop on the bumper line's centre (cut), not near it.
  // On a bed the tailgate's sides run up to its top (its lamps are on the corner posts).
  const gateTop = (rec) => (body.bed ? rec.top - 0.03 : tailY(rec) - tailHigh + 0.02);
  const gateLine = region((rec) => onTailFace(rec) && rec.y >= rec.bottom + 0.34 * rec.h - SNAP_M && rec.y <= gateTop(rec) + SNAP_M, (rec) => rec.x - (tailCentre - tailHalf - 0.012));
  // Its ends are cut too, so the groove stops square.
  const nearGate = (rec) => onTailFace(rec) && Math.abs(rec.x - (tailCentre - tailHalf - 0.012)) < LINE_END_NEAR_M;
  gateLine.pre = [region(nearGate, (rec) => rec.y - (rec.bottom + 0.34 * rec.h)), region(nearGate, (rec) => rec.y - gateTop(rec))];
  // A service body's compartment doors.
  const service = body.bed === "service";
  const lockerLines = service
    ? [4.3, 5.0, 5.75].map((zf) =>
        lineEnds(
          region((rec) => onSide(rec) && rec.y > 0.6 - SNAP_M && rec.y < 1.4 + SNAP_M, (rec) => rec.zf - zf),
          (rec) => onSide(rec) && Math.abs(rec.zf - zf) < LINE_END_NEAR_M,
          (rec) => rec.y - 0.6,
          (rec) => rec.y - 1.4,
        ),
      )
    : [];
  const fLockerRail = boxRegion((rec) => onSide(rec) && service, (rec) => rec.zf - 5.0, (rec) => rec.y - 1.41, 1.15, 0.012, 0.004);

  // What to cut at this detail: [region, offsets...].
  const cuts = [];
  const cut = (fn, ...offsets) => cuts.push([fn, offsets.length ? offsets : [0]]);
  const lines = [];
  const line = (fn) => {
    lines.push(fn);
    cut(fn, -gapHalf, 0, gapHalf);
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
  // The lining's edges (the cabin's length, down to the floor; positive inside
  // it), cut so they run straight: a van's ends at its bulkhead under the roof,
  // in plain sight through the windshield.
  const liningEnd = body.pillars.cargo_from ? body.pillars.cargo_from + 0.02 : body.bed ? cab.rear_base : shape.hasTrunk ? cab.rear_base + 0.05 : null;
  const liningEdges = [
    region((rec) => rec.wall, (rec) => rec.zf - (cab.windshield_base + 0.05)),
    region(onLid, (rec) => rec.zq - (cab.windshield_base + 0.04)),
    region((rec) => rec.wall, (rec) => rec.f - 0.12),
  ];
  if (liningEnd !== null) liningEdges.push(region(() => true, (rec) => liningEnd - rec.zf));
  if (inner) for (const fn of liningEdges) cut(fn);
  if (!inner && inset === 0) {
    cut(fRoof);
    if (cladding) cut(fClad);
    cut(fHead);
    cut(fTail);
    if (body.grille !== "none") cut(fGrille, ...(detail >= 2 ? [0, -0.018] : [0]));
    if (detail >= 1) cut(fIntake, ...(detail >= 3 ? [0, -0.018] : [0]));
    if (body.bed === "tonneau") cut(fTonneau);
    if (body.bed !== undefined && detail >= 2) cut(fBedGap);
    if (detail >= 1) cut(fCowl);
    if (detail >= 2) {
      cut(fDrl, 9);
      cut(fTailBar, 9);
      cut(fGarnish);
      for (const fn of seamLines) line(fn);
      line(sillLine);
      line(hoodLine);
      // A tonneau cover's edge is the bed's line; a shut line beside it left slivers.
      if (body.bed !== "tonneau") line(deckLine);
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
    }
  }

  const zOf = (zf) => zf - L / 2;
  const point = (rec) => v3(rec.x, rec.y, zOf(rec.zf));
  // --- The grid, then the cuts. A vertex on the wall's top ring has a lid
  // twin (the same point read as lid), so each triangle reads the regions of
  // its own patch, and its parameters in either patch.
  const verts = [];
  const twins = [];
  const tris = [];
  const onLidPatch = [];
  const addVertex = (rec, twin = null) => {
    verts.push(rec);
    twins.push(twin);
    return verts.length - 1;
  };
  const seamRC = (k) => (k <= FRONT_EDGE ? [0, FRONT_EDGE - k] : k >= REAR_EDGE ? [NR, k - REAR_EDGE] : [k - FRONT_EDGE, 0]);
  const wallIds = [];
  for (let k = 0; k < K; k += 1) {
    const ring = [];
    for (let v = 0; v <= nW; v += 1) ring.push(addVertex(record(k, v), v === nW ? lidRecord(...seamRC(k)) : null));
    wallIds.push(ring);
  }
  const lidIds = [];
  for (let r = 0; r <= NR; r += 1) {
    const row = [];
    for (let c = 0; c <= C; c += 1) {
      const seam = r === 0 ? FRONT_EDGE - c : r === NR ? REAR_EDGE + c : c === 0 ? FRONT_EDGE + r : -1;
      row.push(seam >= 0 ? wallIds[seam][nW] : addVertex(lidRecord(r, c)));
    }
    lidIds.push(row);
  }
  // Each grid quad (a, b, c, d, counterclockwise in its parameters, so facing
  // in) is split along whichever diagonal leaves both halves facing as the
  // surface does: where the shoulder line bends, one diagonal folds the quad.
  const facing = (ids) => {
    const [pa, pb, pc] = ids.map((id) => point(verts[id]));
    const n = vcross(vsub(pc, pa), vsub(pb, pa));
    const l = vlen(n);
    if (l < 1e-14) return -1;
    const s = vadd(vadd(baseNormal(verts[ids[0]]), baseNormal(verts[ids[1]])), baseNormal(verts[ids[2]]));
    return vdot(n, s) / (l * (vlen(s) || 1));
  };
  const quad = (a, b, c, d, lidPatch) => {
    const first = Math.min(facing([a, b, c]), facing([a, c, d]));
    const second = Math.min(facing([a, b, d]), facing([b, c, d]));
    if (second > first + 1e-9) tris.push([a, b, d], [b, c, d]);
    else tris.push([a, b, c], [a, c, d]);
    onLidPatch.push(lidPatch, lidPatch);
  };
  for (let k = 0; k < K - 1; k += 1) {
    for (let v = 0; v < nW; v += 1) quad(wallIds[k][v], wallIds[k + 1][v], wallIds[k + 1][v + 1], wallIds[k][v + 1], false);
  }
  for (let r = 0; r < NR; r += 1) {
    for (let c = 0; c < C; c += 1) quad(lidIds[r][c], lidIds[r + 1][c], lidIds[r + 1][c + 1], lidIds[r][c + 1], true);
  }
  // A vertex's parameters in a patch (a seam vertex's lid ones are its twin's).
  const paramsIn = (id, lidPatch) => {
    if (!lidPatch) return [verts[id].kf, verts[id].v];
    const rec = twins[id] ?? verts[id];
    return [rec.rf, rec.cf];
  };
  const onSeam = (id) => twins[id] !== null;
  // A vertex this close to an outline (metres, the regions' unit) counts as on
  // it: no crossing is made a hair beside it, which would leave a sliver.
  const EPS = SNAP_M;
  // A region's outline (not a groove line) snaps onto a vertex this close to
  // it, more loosely the further the level is seen from: a crossing a few
  // millimetres from a ring or a column round a tight corner left a sliver
  // turned over.
  const regionEps = inner || inset > 0 ? REGION_SNAP_M[inner ? "mid" : "far"] : REGION_SNAP_M[levelName];
  const epsOf = (fn) => (lines.includes(fn) ? EPS : regionEps);
  const edgeKey = (i, j) => (i < j ? i * 1e7 + j : j * 1e7 + i);
  const cutAlong = (fn, offset, eps = EPS) => {
    // NaN outside the region's domain: a triangle with such a corner is left whole.
    const read = (rec) => (rec && fn.where(rec) ? fn.fn(rec) - offset : NaN);
    const wallValue = verts.map(read);
    const lidValue = twins.map((twin, id) => (twin ? read(twin) : wallValue[id]));
    if (![...wallValue, ...lidValue].some((x) => x > eps) || ![...wallValue, ...lidValue].some((x) => x < -eps)) return;
    const made = new Map();
    const crossing = (i, j, value) => {
      const key = edgeKey(i, j);
      if (made.has(key)) return made.get(key);
      // Find the outline's true place on the edge in the surface's own
      // parameters: an edge along the seam in the wall's (its top exactly).
      const seam = onSeam(i) && onSeam(j);
      const lidPatch = value === lidValue && !seam;
      const lo = value[i] < 0 ? i : j;
      const hi = value[i] < 0 ? j : i;
      let a = paramsIn(lo, lidPatch);
      let b = paramsIn(hi, lidPatch);
      const a0 = a;
      const b0 = b;
      let fa = value[lo];
      let fb = value[hi];
      let rec = null;
      let m = a;
      for (let step = 0; step < 16; step += 1) {
        const t = clamp(fa / (fa - fb), 0.1, 0.9);
        m = [lerp(a[0], b[0], t), lerp(a[1], b[1], t)];
        rec = recordIn(lidPatch, m[0], m[1]);
        const read2 = value === lidValue && seam ? lidRecordAlong(lo, hi, a0, b0, m) : rec;
        const fm = fn.where(read2) ? fn.fn(read2) - offset : fb;
        if (Math.abs(fm) < 1e-6) break;
        if (fm < 0) {
          a = m;
          fa = fm;
        } else {
          b = m;
          fb = fm;
        }
      }
      // A crossing on the seam itself is a seam vertex again, with its lid twin.
      const id = seam ? addVertex(record(m[0], nW), lidRecordAlong(lo, hi, a0, b0, m)) : addVertex(rec);
      wallValue.push(0);
      lidValue.push(0);
      made.set(key, id);
      return id;
    };
    // The lid twin of a point on a seam edge, at the same share of the edge in the lid's parameters.
    const lidRecordAlong = (lo, hi, a0, b0, m) => {
      const t = Math.abs(b0[0] - a0[0]) > 1e-12 ? (m[0] - a0[0]) / (b0[0] - a0[0]) : 0;
      const p = paramsIn(lo, true);
      const q = paramsIn(hi, true);
      return lidRecord(lerp(p[0], q[0], t), lerp(p[1], q[1], t));
    };
    const count = tris.length;
    for (let t = 0; t < count; t += 1) {
      const tri = tris[t];
      const value = onLidPatch[t] ? lidValue : wallValue;
      if (Number.isNaN(value[tri[0]]) || Number.isNaN(value[tri[1]]) || Number.isNaN(value[tri[2]])) continue;
      const sign = tri.map((id) => (value[id] > eps ? 1 : value[id] < -eps ? -1 : 0));
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
    const eps = epsOf(fn);
    for (const pre of fn.pre ?? []) {
      if (precut.has(pre)) continue;
      precut.add(pre);
      cutAlong(pre, 0, eps);
    }
    // An offset of 9 asks for the region's pre-cuts only.
    for (const offset of offsets) if (offset !== 9) cutAlong(fn, offset, eps);
  }

  // --- What each triangle is. Every outline it could straddle has been cut,
  // so a region's values at a triangle's corners all lie on one side of its
  // outline: R(fn) is their mean (read on the triangle's own patch, as the cut
  // read them). Only where a corner is outside a region's domain (never cut
  // there) does the triangle's middle decide.
  const cornerRecords = (tri, lidPatch) => tri.map((id) => (lidPatch && twins[id] ? twins[id] : verts[id]));
  const reader = (tri, lidPatch, mid) => {
    const recs = cornerRecords(tri, lidPatch);
    const cache = new Map();
    return (fn) => {
      if (cache.has(fn)) return cache.get(fn);
      let value;
      if (!recs.every((rec) => fn.where(rec))) value = fn(mid);
      else {
        const values = recs.map((rec) => fn.fn(rec));
        value = values.every((x) => Math.abs(x) <= epsOf(fn)) ? fn(mid) : (values[0] + values[1] + values[2]) / 3;
      }
      cache.set(fn, value);
      return value;
    };
  };
  const classify = (rec, R) => {
    if (!inner && R(fArch) < 0) return null;
    if (inner) {
      // The lining: the cabin's length only, down to the floor.
      if (liningEdges.some((fn) => R(fn) < 0)) return null;
      // Not down into the wheel arches, where it would show from outside.
      if (rec.wall && archDistance(rec) < archRadius + 0.06) return null;
      if (R(fSide) < 0 && R(fPillar) > 0) return null;
      if (R(fWind) < 0 || R(fRear) < 0 || R(fGlassRoof) < 0) return null;
      return { part: rec.wall ? P.cabin : P.headliner };
    }
    if (inset > 0) return { part: P.paint };
    if (detail >= 2 && lines.some((fn) => Math.abs(R(fn)) < gapHalf)) return { part: P.gap, ao: 0.3, groove: detail >= 3 };
    if (body.bed !== undefined && detail >= 2 && R(fBedGap) < 0) return { part: P.under, ao: 0.3 };
    const side = R(fSide);
    if (side < 0) {
      if (detail >= 1 && R(fPillar) < 0) return { part: detail >= 2 ? P.gloss_black : P.trim };
      // Door glass runs in seals, without a frit band.
      return { part: P.glass, glass: true, frit: false, dark: rec.zf > (body.pillars.b ?? L) };
    }
    for (const [fn, dark] of [[fWind, false], [fRear, true], [fGlassRoof, true]]) {
      const f = R(fn);
      if (f < 0) return { part: P.glass, glass: true, frit: frit !== null && (f > -frit || (fn === fWind && R(fritFoot) < 0)), dark };
    }
    if (!rec.wall) {
      if (detail >= 1 && R(fCowl) < 0) return { part: P.trim, ao: 0.7 };
      if (R(fTonneau) < 0) return { part: P.trim };
      if (R(fRoof) < 0) return { part: P.roof };
      return { part: P.paint };
    }
    const head = R(fHead);
    if (head < 0) {
      if (detail >= 3 && R(fAmber) < 0) return { part: P.lamp_amber, lens: P.head_lamp, lamp: true };
      if (detail >= 2 && R(fDrl) < 0) return { part: P.lamp_drl, lens: P.head_lamp, lamp: true, proud: true };
      return { part: detail >= 3 ? P.lamp_housing : P.head_lamp, lens: P.head_lamp, lamp: true };
    }
    const tailLamp = R(fTail);
    if (tailLamp < 0) {
      if (detail >= 3 && R(fReverse) < 0) return { part: P.lamp_white, lens: P.tail_lamp, lamp: true };
      if (detail >= 2 && R(fTailBar) < 0) return { part: P.lamp_red, lens: P.tail_lamp, lamp: true, proud: true };
      return { part: P.tail_lamp, lens: P.tail_lamp, lamp: true };
    }
    if (detail >= 3 && R(fPocket) < 0) return { part: P.trim, ao: 0.7 };
    const grille = R(fGrille);
    if (grille < 0) return { part: detail >= 2 && grille > -0.018 ? (truck || body.grille === "sedan" ? P.chrome : P.gloss_black) : P.grille, ao: grille > -0.018 ? 1 : 0.6 };
    if (detail >= 1 && R(fIntake) < 0) return { part: P.grille, ao: 0.55 };
    if (detail >= 3 && R(fFog) < 0) return { part: P.grille, ao: 0.6 };
    if (detail >= 2 && R(fGarnish) < 0) return { part: P.chrome };
    if (service && detail >= 2 && R(fLockerRail) < 0) return { part: P.chrome };
    if (R(fClad) < 0) return { part: P.trim };
    return { part: P.paint };
  };
  // How far in (metres) the surface is pressed at a record: V grooves, sunk
  // grilles, lamp bowls and the rear plate's pocket; every depth runs smoothly
  // from zero at its outline, so no vertex jumps.
  const ramp = (f, width) => clamp(-f / width, 0, 1);
  const GROOVE_M = 0.004;
  // Over how far a groove runs out to the shoulder (m).
  const GROOVE_FADE_M = 0.012;
  // How deep the hero level's wall is pressed in at a record: sunk grilles,
  // lamp bowls and the rear plate's pocket.
  const recessed = (rec) => {
    if (!rec.wall) return 0;
    let d = Math.max(0.03 * ramp(fGrille(rec) + 0.018, 0.014), 0.03 * ramp(fIntake(rec), 0.018));
    // A lamp's bowl, no deeper than a quarter of the corner it wraps (a truck's tail lamp sits on a tight corner).
    d = Math.max(d, Math.min(HEAD_BOWL_M, 0.25 * nose.corner) * ramp(fHead(rec), 0.014), Math.min(TAIL_BOWL_M, 0.25 * tail.corner) * ramp(fTail(rec), 0.014));
    return Math.max(d, 0.016 * ramp(fPocket(rec), 0.014));
  };
  const pressed = (rec) => {
    // The lining sits 12 mm inside, and further in behind a recess (a plate's
    // pocket, a lamp's bowl), whose floor it would otherwise show through:
    // deeper all over, its offset would turn inside out round the tight roof
    // rails and pillars.
    if (inner) return 0.012 + recessed(rec);
    if (inset > 0) return 0;
    if (detail < 3) return 0;
    let d = 0;
    for (const fn of lines) d = Math.max(d, GROOVE_M * clamp(1 - Math.abs(fn(rec)) / gapHalf, 0, 1));
    // A groove crossing the shoulder runs out to nothing on it: the shoulder's
    // points are pressed along the wall's normal, which lies along the lid
    // there, and the lid's thin wedges between a groove's cuts turned over.
    const fromShoulder = rec.wall ? (1 - rec.f) * rec.h : rec.dist;
    d *= smoothstep(0, GROOVE_FADE_M, fromShoulder);
    return Math.max(d, recessed(rec));
  };

  // --- Write the triangles out: positions pressed along the surface normal,
  // each corner's normal taken a hair inside its own triangle (so a crease or
  // a pressed edge keeps its two sides), then welded where they agree. The
  // winding is the grid's own (the cuts keep it), so neighbours always agree.
  const normalCache = new Map();
  const vertexNormal = (id) => {
    if (!normalCache.has(id)) normalCache.set(id, baseNormal(verts[id]));
    return normalCache.get(id);
  };
  const placed = (rec, n, d) => vsub(point(rec), vscale(n, d));
  const placeCache = new Map();
  const place = (id) => {
    if (!placeCache.has(id)) {
      // The lining's shoulder points go in between the wall's normal and the
      // lid's: along the wall's alone, they stood level with the shoulder a
      // little inside it, above a sill that dips inward (the hero shell's).
      const n = inner && twins[id] ? vnorm(vadd(vertexNormal(id), baseNormal(twins[id]))) : vertexNormal(id);
      placeCache.set(id, placed(verts[id], n, pressed(verts[id])));
    }
    return placeCache.get(id);
  };
  const moving = detail >= 3 && !inner && inset === 0;
  // A triangle's middle in its own patch's parameters.
  const middleOf = (tri, lidPatch) => {
    const ps = tri.map((id) => paramsIn(id, lidPatch));
    return [(ps[0][0] + ps[1][0] + ps[2][0]) / 3, (ps[0][1] + ps[1][1] + ps[2][1]) / 3];
  };
  const cornerNormal = (tri, corner, lidPatch) => {
    const here = paramsIn(tri[corner], lidPatch);
    const mid = middleOf(tri, lidPatch);
    const step = Math.min(0.06, 0.002 / Math.max(1e-9, Math.hypot(mid[0] - here[0], mid[1] - here[1])));
    const p0 = lerp(here[0], mid[0], step);
    const p1 = lerp(here[1], mid[1], step);
    const at = recordIn(lidPatch, p0, p1);
    const n = baseNormal(at);
    if (!moving) return n;
    // A triangle beside a groove or a bowl, not pressed itself (at its middle),
    // keeps the surface's own normal: one sampled across the edge into the
    // groove (a corner snapped onto the edge reads a hair of its depth) tilts
    // its corners there and shades the whole triangle as a sunken step.
    if (pressed(recordIn(lidPatch, mid[0], mid[1])) < 1e-5) return n;
    const depth = pressed(at);
    // Is the surface pressed unevenly here? Then the normal of the pressed surface.
    const h = 4e-3;
    const span = lidPatch ? [NR, C] : [K - 1, nW];
    const samples = [[h, 0], [-h, 0], [0, h], [0, -h]].map(([dk, dv]) => {
      const r = recordIn(lidPatch, clamp(p0 + dk, 0, span[0]), clamp(p1 + dv, 0, span[1]));
      return [r, pressed(r)];
    });
    if (samples.every(([, d]) => Math.abs(d - depth) < 1e-5)) return n;
    const pts = samples.map(([r, d]) => placed(r, n, d));
    const m = vcross(vsub(pts[2], pts[3]), vsub(pts[0], pts[1]));
    if (vlen(m) < 1e-14) return n;
    const out = vnorm(m);
    return vdot(out, n) >= 0 ? out : vscale(out, -1);
  };
  const body3 = new CarMesh();
  const glass = new CarMesh();
  const kept = [];
  const kindOf = (tri, lidPatch) => {
    const mid = recordIn(lidPatch, ...middleOf(tri, lidPatch));
    return classify(mid, reader(tri, lidPatch, mid));
  };
  tris.forEach((tri, t) => {
    const kind = kindOf(tri, onLidPatch[t]);
    if (kind) kept.push({ tri, kind, lidPatch: onLidPatch[t] });
  });
  // A triangle turned over against its own surface (a sliver between a cut
  // and a grid line round a tight bend, or pressed past its neighbour) is
  // mended by flipping the edge it shares with a neighbour of the same kind on
  // the same patch, when the other diagonal leaves both halves facing as the
  // surface does and reading the same.
  const facingOf = (tri, lidPatch) => {
    const [pa, pb, pc] = tri.map(place);
    const n = vcross(vsub(pc, pa), vsub(pb, pa));
    const l = vlen(n);
    if (l < 1e-14) return -1;
    const s = vadd(vadd(cornerNormal(tri, 0, lidPatch), cornerNormal(tri, 1, lidPatch)), cornerNormal(tri, 2, lidPatch));
    return vdot(n, s) / (l * (vlen(s) || 1));
  };
  const sameKind = (a, b) => JSON.stringify(a) === JSON.stringify(b);
  for (let pass = 0; pass < 6; pass += 1) {
    const facing = kept.map((entry) => facingOf(entry.tri, entry.lidPatch));
    if (facing.every((f) => f >= 0)) break;
    const byEdge = new Map();
    kept.forEach((entry, index) => {
      for (let c = 0; c < 3; c += 1) {
        const i = entry.tri[c];
        const j = entry.tri[(c + 1) % 3];
        const key = i < j ? i * 1e7 + j : j * 1e7 + i;
        if (!byEdge.has(key)) byEdge.set(key, []);
        byEdge.get(key).push(index);
      }
    });
    const touched = new Set();
    let flipped = 0;
    kept.forEach((entry, index) => {
      if (facing[index] >= 0 || touched.has(index)) return;
      let best = null;
      for (let c = 0; c < 3; c += 1) {
        const i = entry.tri[c];
        const j = entry.tri[(c + 1) % 3];
        const k = entry.tri[(c + 2) % 3];
        const sharing = byEdge.get(i < j ? i * 1e7 + j : j * 1e7 + i);
        if (sharing.length !== 2) continue;
        const other = sharing[0] === index ? sharing[1] : sharing[0];
        const them = kept[other];
        if (touched.has(other) || them.lidPatch !== entry.lidPatch || !sameKind(them.kind, entry.kind)) continue;
        // Their winding runs j to i along the shared edge; l is their third corner.
        const at = them.tri.indexOf(j);
        if (them.tri[(at + 1) % 3] !== i) continue;
        const l = them.tri[(at + 2) % 3];
        const one = [i, l, k];
        const two = [l, j, k];
        const score = Math.min(facingOf(one, entry.lidPatch), facingOf(two, entry.lidPatch));
        if (score <= Math.max(0, Math.min(facing[index], facing[other])) || (best && score <= best.score)) continue;
        const kindOne = kindOf(one, entry.lidPatch);
        const kindTwo = kindOf(two, entry.lidPatch);
        if (!kindOne || !kindTwo || !sameKind(kindOne, entry.kind) || !sameKind(kindTwo, entry.kind)) continue;
        best = { score, other, one, two };
      }
      if (!best) return;
      entry.tri = best.one;
      kept[best.other].tri = best.two;
      touched.add(index);
      touched.add(best.other);
      flipped += 1;
    });
    if (flipped === 0) break;
  }
  for (const entry of kept) entry.normals = [0, 1, 2].map((corner) => cornerNormal(entry.tri, corner, entry.lidPatch));
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
  // The grid runs round the outline and up the wall, then in over the lid:
  // counterclockwise in (station, ring) it faces in, so the outer shell is
  // written the other way round and the lining as it is.
  const emit = (mesh, pts, normals, part, ao) => {
    if (inner) mesh.triangle(pts[0], pts[1], pts[2], normals.map((n) => vscale(n, -1)), part, ao);
    else mesh.triangle(pts[0], pts[2], pts[1], [normals[0], normals[2], normals[1]], part, [ao[0], ao[2], ao[1]]);
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
  // --- Draping: a fitting modelled once in its own frame (x out of the
  // surface, y up it, z along it) is laid on this level's surface, pressing
  // included, so it sits the same on every body and never floats or sinks.
  const wallRecordAt = (a, f) => {
    const p = wall(a, f);
    const w = shape.arcAt(a);
    return { wall: true, a, f, x: p.x, y: p.y, zf: p.zf, e: p.e, front: p.front, top: p.yTop, bottom: p.yBottom, h: p.h, w, wr: shape.arcTotal - w, zeta: p.st.zeta, bed: p.st.bed };
  };
  // A frame on the wall at station a, height y: point (pressed), normal, and unit
  // tangents along the outline (toward larger a) and up the wall.
  const wallFrame = (a, y) => {
    const top = wall(a, 1);
    const f = clamp((y - top.yBottom) / top.h, 0, 1);
    const rec = wallRecordAt(a, f);
    const n = baseNormal(rec);
    const p = placed(rec, n, pressed(rec));
    const ha = 2e-4;
    const along = vnorm(vsub(point(wallRecordAt(a + ha, f)), point(wallRecordAt(a - ha, f))));
    // (n, up, along) right-handed, as the fittings' (x, y, z).
    const up = vnorm(vcross(along, n));
    return { p, n, along: vnorm(vcross(n, up)), up };
  };
  // Station a at plan zf along the right side, or at distance w round an end face from its centre line.
  const sideStationAt = (zf) => 1 + clamp((zf - nose.corner) / (L - tail.corner - nose.corner), 0, 1);
  const faceStationAt = (front, w) => {
    let lo = front ? 0 : 2;
    let hi = front ? 1 : 3;
    for (let i = 0; i < 40; i += 1) {
      const mid = (lo + hi) / 2;
      const at = front ? shape.arcAt(mid) : shape.arcTotal - shape.arcAt(mid);
      if (front ? at < w : at > w) lo = mid;
      else hi = mid;
    }
    return (lo + hi) / 2;
  };
  // Lays `part` (a CarMesh in its own frame) into `out`, centred at station a0,
  // height y0; its z runs along the outline (dz metres of arc per metre), x out.
  const drape = (out, part, a0, y0, { flipAlong = false } = {}) => {
    // Metres round the outline per unit of a, from a difference that stays inside
    // the outline's own range (at an end face's centre line, a0 0 or 3, a
    // difference across the end read half the slope and drew plates twice as wide).
    const aLo = Math.max(0, a0 - 1e-3);
    const aHi = Math.min(3, a0 + 1e-3);
    const arcPerA = (shape.arcAt(aHi) - shape.arcAt(aLo)) / (aHi - aLo);
    const mapped = new CarMesh();
    for (let i = 0; i < part.positions.length; i += 3) {
      const [lx, ly, lz] = [part.positions[i], part.positions[i + 1], part.positions[i + 2]];
      const frame = wallFrame(a0 + (flipAlong ? -lz : lz) / arcPerA, y0 + ly);
      const along = flipAlong ? vscale(frame.along, -1) : frame.along;
      mapped.positions.push(...vadd(frame.p, vscale(frame.n, lx)));
      const [nx, ny, nz] = [part.normals[i], part.normals[i + 1], part.normals[i + 2]];
      mapped.normals.push(...vnorm(vadd(vscale(frame.n, nx), vadd(vscale(frame.up, ny), vscale(along, nz)))));
    }
    mapped.uvs.push(...part.uvs);
    // The frame (out, up, along) has the handedness of (x, y, z) on the right
    // side (along toward the rear); turned round, the winding flips.
    for (let i = 0; i < part.indices.length; i += 3) {
      if (flipAlong) mapped.indices.push(part.indices[i], part.indices[i + 2], part.indices[i + 1]);
      else mapped.indices.push(part.indices[i], part.indices[i + 1], part.indices[i + 2]);
    }
    out.append(mapped);
  };
  if (inset > 0) {
    // The shadow caster: the shell drawn `inset` inside the body by shrinking
    // it toward the middle of its box (an offset along the normals turned
    // over round the tight rolls and corners, and a fold left a hole in the
    // shadow).
    const sx = 1 - inset / W;
    const sz = 1 - inset / (L / 2);
    const yc = (body.height + body.clearance) / 2;
    const sy = 1 - inset / ((body.height - body.clearance) / 2);
    for (let i = 0; i < body3.positions.length; i += 3) {
      body3.positions[i] *= sx;
      body3.positions[i + 1] = yc + (body3.positions[i + 1] - yc) * sy;
      body3.positions[i + 2] *= sz;
      const n = vnorm(v3(body3.normals[i] / sx, body3.normals[i + 1] / sy, body3.normals[i + 2] / sz));
      body3.normals[i] = n[0];
      body3.normals[i + 1] = n[1];
      body3.normals[i + 2] = n[2];
    }
  }
  return { body: body3, glass, shape, lampSpot, truck, drape, sideStationAt, faceStationAt, wallFrame };
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
    // The liner runs from the floor in front of the wheel over it to the floor
    // behind, so with the wall and the floor it closes the well. Its sides are
    // chords: it rides out so their middles stay over the arch's edge (inside
    // it, a slot opened between the arch and the liner at the coarse levels).
    const floor = underFloorY(body, detail);
    const r0 = archRadius + 0.004;
    const r = r0 / Math.cos((Math.PI + 2 * Math.asin(clamp((R - floor) / r0, -1, 1))) / sides / 2);
    const reach = Math.asin(clamp((R - floor) / r, -1, 1));
    const rows = [];
    const normals = [];
    for (let i = 0; i <= sides; i += 1) {
      const t = Math.PI - reach + ((Math.PI + 2 * reach) * i) / sides;
      const out3 = v3(0, -Math.sin(t), Math.cos(t));
      const at = (x) => vadd(centre, v3(x, -r * Math.sin(t), r * Math.cos(t)));
      // Its outer edge just inside the body's skin there, so no slot opens between them.
      const zf = axle + r * Math.cos(t);
      const y = R - r * Math.sin(t);
      const a = 1 + clamp((zf - body.nose.corner) / (L - body.tail.corner - body.nose.corner), 0, 1);
      const skin = shape.wall(a, clamp((y - shape.bottom(zf)) / Math.max(0.05, shape.wall(a, 1).yTop - shape.bottom(zf)), 0, 1)).x;
      rows.push([at(Math.max(innerX + 0.02, skin - 0.008)), at(innerX)]);
      normals.push([vscale(out3, -1), vscale(out3, -1)]);
    }
    out.grid(rows, normals, P.under, (i, j) => (j === 0 ? 0.45 : 0.25));
    const n = v3(1, 0, 0);
    // The wall stands on the floor (never below the sills, where it would show as a flap).
    const floorY = underFloorY(body, detail);
    out.flat(v3(innerX, floorY, zOf(axle - r)), v3(innerX, R + r, zOf(axle - r)), v3(innerX, R + r, zOf(axle + r)), v3(innerX, floorY, zOf(axle + r)), n, P.under, 0.3);
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
      // The bar curves down into a low foot over its last tenth at each end.
      const end = Math.min(i, steps - i) / steps;
      const yTop = Math.min(body.height, roof[i] + lerp(0.016, stand, smoothstep(0, 0.1, end)));
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
    // The underside as one dark sheet (the hero level has an underbody), in
    // longer steps the further the level is seen from.
    underFloor(out, shape, body.clearance + 0.03, 0.07, L - 0.07, W - 0.1, 0.35, [0.6, 0.35, 0.15][detail]);
  }
  if (detail >= 2) {
    // Wipers parked on the cowl: an arm and a blade each, lying along the
    // glass's (bowed) foot, their outer tips well inside the A pillars.
    for (const [x0, x1] of [[-0.62, -0.05], [0.02, 0.6]]) {
      const span = W * 0.8;
      const at = (x) => {
        const zf = shape.rowZf(cab.windshield_base + 0.09 + 0.03 * ((x - x0 * span) / ((x1 - x0) * span)), Math.abs(x));
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

// Where each body's fittings go (the same parts on every car, street-car-parts.mjs):
// handles on the doors, the filler door on one side (none on the service
// body), number plates on both faces, side reflectors on the rear bumper's
// ends and the third brake light at the top of the rear glass.
const FUEL_SIDE = Object.freeze({ crossover: 1, suv: -1, sedan: -1, fastback: -1, hatchback: 1, wagon: 1, pickup: -1, utility: 0, van: -1 });
function placeFittings(name, detail, shell, half, centre, oneSide) {
  const shape = shell.shape;
  const { body, L, axles, archRadius } = shape;
  const cab = body.cabin;
  if (detail >= 2) {
    for (const seam of doorSeams(body).slice(1)) {
      const a = shell.sideStationAt(seam - 0.2);
      shell.drape(half, doorHandle(detail), a, shape.wall(a, 1).yTop - 0.115);
    }
  }
  if (detail >= 3 && FUEL_SIDE[name] !== 0) {
    // Behind the rear arch where the quarter has room, else over the arch's back; on a van ahead of it.
    const { half_along: hz, half_up: hy } = FILLER_DOOR;
    const behind = axles[1] + archRadius + 0.035 + hz;
    const room = L - body.tail.corner - 0.04 - hz;
    const zf = body.pillars.cargo_from ? axles[1] - archRadius - 0.06 - hz : Math.min(behind, room);
    const a = shell.sideStationAt(zf);
    const top = shape.wall(a, 1).yTop;
    // Clear of the arch below it by 3 cm, and of the shoulder above by 10 cm.
    const dz = Math.max(0, Math.abs(zf - axles[1]) - hz);
    const archTop = dz < archRadius ? body.wheel_radius + Math.sqrt(archRadius ** 2 - dz ** 2) : 0;
    const y = Math.max(archTop + 0.03 + hy, Math.min(top - 0.22, top - 0.1 - hy));
    shell.drape(oneSide, fillerDoor(), a, y);
  }
  if (detail >= 3) {
    const zf = L - body.tail.corner - 0.07;
    const a = shell.sideStationAt(zf);
    shell.drape(half, sideReflector(), a, shape.wall(a, 1).yBottom + 0.15);
  }
  // Number plates, centred on each face.
  for (const front of [true, false]) {
    const a = front ? 0 : 3;
    const top = shape.wall(a, 1);
    const share = front ? (body.grille === "truck" ? 0.34 : 0.45) : body.bed ? 0.16 : 0.56;
    shell.drape(centre, numberPlate(detail), a, top.yBottom + share * top.h, { flipAlong: !front });
  }
  if (detail >= 2) {
    // The third brake light, on the lid at the top of the rear glass (a cab back's top).
    const zq = cab.roof_end + 0.03;
    const y = shape.lid(0, zq).y;
    const h = 4e-3;
    const slope = (shape.lid(0, zq + h).y - shape.lid(0, zq - h).y) / (2 * h);
    const n = vnorm(v3(0, 1, -slope));
    const along = v3(1, 0, 0);
    const up = vnorm(vcross(along, n));
    const part = brakeLight(detail);
    for (let i = 0; i < part.indices.length; i += 3) {
      const ids = [part.indices[i], part.indices[i + 1], part.indices[i + 2]];
      const pt = ids.map((k) => {
        const [lx, ly, lz] = [part.positions[k * 3], part.positions[k * 3 + 1], part.positions[k * 3 + 2]];
        return vadd(v3(0, y, zq - L / 2), vadd(vscale(n, lx - 0.004), vadd(vscale(up, ly), vscale(along, lz))));
      });
      const nm = ids.map((k) => vnorm(vadd(vscale(n, part.normals[k * 3]), vadd(vscale(up, part.normals[k * 3 + 1]), vscale(along, part.normals[k * 3 + 2])))));
      const partOf = Math.floor(part.uvs[ids[0] * 2] * CAR_PART_COUNT);
      centre.face(pt[0], pt[1], pt[2], nm[0], nm[1], nm[2], partOf, part.uvs[ids[0] * 2 + 1], part.uvs[ids[1] * 2 + 1], part.uvs[ids[2] * 2 + 1]);
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
  const centre = new CarMesh();
  const oneSide = new CarMesh();
  if (!shadow) {
    rightHalfFittings(half, name, detail);
    placeFittings(name, detail, shell, half, centre, oneSide);
  }
  if (levelName === "hero") {
    // Two projectors in each head lamp's bowl: a bright ring round a dark lens.
    for (const along of shell.truck ? [-0.35, 0.35] : [-0.45, 0.1]) {
      const spot = shell.lampSpot(along);
      const centre = vsub(spot.point, vscale(spot.normal, HEAD_BOWL_M + 0.01));
      const r = shell.truck ? 0.05 : 0.036;
      half.revolve(centre, spot.normal, [[r + 0.008, 0], [r + 0.008, 0.03], [r, 0.034], [r - 0.004, 0.022]], 14, () => P.chrome, { crease: 50 });
      half.revolve(centre, spot.normal, [[r - 0.004, 0.022], [r * 0.6, 0.03], [0, 0.033]], 14, () => P.mirror);
    }
  }
  const chassis = new CarMesh();
  both(chassis, half);
  chassis.append(centre);
  // A one-sided fitting (the filler door) is laid on the right; on the left it is mirrored over.
  if (FUEL_SIDE[name] < 0) chassis.append(oneSide, mirrorX, true);
  else chassis.append(oneSide);
  if (!shadow) centreFittings(chassis, name, detail);
  let result;
  if (levelName === "hero") {
    const glass = new CarMesh();
    both(glass, shell.glass);
    const lining = buildShell(name, "mid", { inner: true });
    both(chassis, lining.body);
    const driver = buildCabin(chassis, body, shell.shape);
    buildUnderbody(chassis, body, shell.shape);
    result = { body: chassis, glass, wheel: buildWheel(body, "hero"), brake: buildBrake(body), driver };
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
  return asBaseParts((wheels ? parts.car : parts.chassis).result());
}
// One right-hand wheel of a body round its own centre, its face toward +X, at
// buildCar's level and in its sixteen base parts (the yard kit's driven cargo
// van, whose chassis is buildCar's).
export function buildCarTyre(name, lodIndex) {
  return asBaseParts(buildCarParts(name, lodIndex === 0 ? "mid" : "far").wheel.result());
}
function asBaseParts(mesh) {
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
    extras.push(...carHullMeshes(name));
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
    // Where a driver sits and holds the wheel (game/scripts/vehicles/car_driver.gd).
    meshes.push({ name: `car_${name}_driver_seat`, marker: true, translation: parts.driver.seat });
    meshes.push({ name: `car_${name}_driver_hand_left`, marker: true, translation: parts.driver.hands[0] });
    meshes.push({ name: `car_${name}_driver_hand_right`, marker: true, translation: parts.driver.hands[1] });
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

// ---------------------------------------------------------------- collision
// What a car collides as, parked or driven: a few convex pieces along the car
// (the nose to the cowl, the cabin, the deck or bed behind it), each the hull
// of the drawn body over its stretch, so whoever stands on a hood, a roof or a
// bed stands on what is drawn. Their bottoms are the driven car's own lower
// hull as it has always been (game/scripts/vehicles/drivable_car.gd: flat at
// max(0.14, 0.6 wheel radius), raked up 0.17 m over the first 0.42 m and the
// last 0.36 m), so a driven car meets kerbs and ramps as before. Each piece is
// a mesh car_<body>_hull<n> whose vertices are its hull's points (convex
// cross-sections, each a flat fan); the runtime takes the hull of those points.
// A section keeps only the corners that hold it within HULL_TOLERANCE_M of the
// drawn outline, so its roof and sides are flat between them: a car knocked
// over comes to rest on its roof or side, as on its old box hull, instead of
// rolling on like a barrel.
const HULL_TOLERANCE_M = 0.015;
export function carHullMeshes(name) {
  const shape = bodyShape(name);
  const { body, L } = shape;
  const cab = body.cabin;
  const zOf = (zf) => zf - L / 2;
  const near = buildCarParts(name, "near").chassis.result();
  let zMin = Infinity;
  let zMax = -Infinity;
  for (let i = 2; i < near.positions.length; i += 3) {
    zMin = Math.min(zMin, near.positions[i]);
    zMax = Math.max(zMax, near.positions[i]);
  }
  const halfL = (zMax - zMin) / 2;
  const hw = 0.49 * body.width;
  const floor = Math.max(0.14, body.wheel_radius * 0.6);
  const bottomAt = (z) => {
    if (z < -halfL + 0.42) return floor + 0.17 * (1 - (z + halfL) / 0.42);
    if (z > halfL - 0.36) return floor + 0.17 * ((z - (halfL - 0.36)) / 0.36);
    return floor;
  };
  // The deck's piece starts a little behind the rear glass's foot, clear of the
  // cab's or cabin's shoulder there, so its top lies on the deck or bed alone.
  const cuts = [zMin + L / 2, cab.windshield_base];
  if (cab.rear_base < L - 0.2) cuts.push(cab.rear_base + 0.06);
  cuts.push(zMax + L / 2);
  const meshes = [];
  for (let s = 0; s < cuts.length - 1; s += 1) {
    const sections = [];
    const steps = Math.max(2, Math.ceil((cuts[s + 1] - cuts[s]) / 0.25));
    for (let i = 0; i <= steps; i += 1) {
      const zf = lerp(cuts[s], cuts[s + 1], i / steps);
      const z = clamp(zOf(zf), -halfL, halfL);
      const floorHere = bottomAt(z);
      const pts = [[hw, floorHere], [-hw, floorHere]];
      const add = (x, y) => {
        if (y >= floorHere) pts.push([x, y], [-x, y]);
      };
      for (const a of outlineStationsAt(shape, zf)) {
        for (const f of [1, 0.85, 0.55]) {
          const p = shape.wall(a, f);
          add(p.x, p.y);
        }
      }
      // The lid across at this zf (its top over the shoulder in to the centre line).
      const side = outlineStationsAt(shape, zf).map((a) => shape.wall(a, 1).x);
      const reach = side.length ? Math.max(...side) : 0;
      // Over the roof, flat out to the rails at the drawn roof's height 0.7 of
      // the way there (its crowned middle a little under that, its rails a
      // little over), so a car knocked onto its roof lies still on it.
      const rail = zf > cab.windshield_top + 0.05 && zf < cab.roof_end - 0.05 ? railAt(shape, zf, reach) : 0;
      const roofY = rail > 0 ? shape.lid(0.7 * rail, zf).y : 0;
      for (let k = 0; k <= 8; k += 1) {
        const x = reach * (1 - k / 8);
        add(x, x < rail ? roofY : shape.lid(x, zf).y);
      }
      if (rail > 0) add(rail, roofY);
      sections.push([z, simplifyConvex(convexHull2(pts), HULL_TOLERANCE_M)]);
    }
    meshes.push({ name: `car_${name}_hull${s}`, ...sectionsMesh(sections) });
  }
  return meshes;
}

// The stations a of the outline whose wall top is at plan zf.
// Where the roof meets the side glass across the car at zf: the rail, where
// the lid stops following the glass plane (its g turns positive), or 0.
function railAt(shape, zf, reach) {
  if (shape.lid(0, zf).g <= 0 || shape.lid(reach, zf).g > 0) return 0;
  let lo = 0;
  let hi = reach;
  for (let i = 0; i < 40; i += 1) {
    const mid = (lo + hi) / 2;
    if (shape.lid(mid, zf).g > 0) lo = mid;
    else hi = mid;
  }
  return lo;
}
function outlineStationsAt(shape, zf) {
  const found = [];
  const SAMPLES = 300;
  let prev = shape.wall(0, 1);
  for (let i = 1; i <= SAMPLES; i += 1) {
    const a = (3 * i) / SAMPLES;
    const here = shape.wall(a, 1);
    if ((prev.zf - zf) * (here.zf - zf) <= 0 && prev.zf !== here.zf) found.push(lerp((3 * (i - 1)) / SAMPLES, a, (zf - prev.zf) / (here.zf - prev.zf)));
    prev = here;
  }
  return found;
}

// A 2D convex hull ([x, y] points, counterclockwise).
function convexHull2(points) {
  const pts = points.map((p) => [Math.round(p[0] * 1e5) / 1e5, Math.round(p[1] * 1e5) / 1e5]).sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  const crossZ = (o, a, b) => (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
  const lower = [];
  for (const p of pts) {
    while (lower.length >= 2 && crossZ(lower.at(-2), lower.at(-1), p) <= 0) lower.pop();
    lower.push(p);
  }
  const upper = [];
  for (const p of [...pts].reverse()) {
    while (upper.length >= 2 && crossZ(upper.at(-2), upper.at(-1), p) <= 0) upper.pop();
    upper.push(p);
  }
  return [...lower.slice(0, -1), ...upper.slice(0, -1)];
}

// The corners of a convex outline, symmetric about x = 0 (in order round it),
// that keep it within tolerance of the whole: Douglas-Peucker down its right
// half, from the top of the centre line round to its bottom, mirrored to the
// left. Any of a convex outline's corners make a convex outline inside it.
function simplifyConvex(poly, tolerance) {
  const offLine = (p, a, b) => {
    const dx = b[0] - a[0];
    const dy = b[1] - a[1];
    const len = Math.hypot(dx, dy);
    return len < 1e-12 ? Math.hypot(p[0] - a[0], p[1] - a[1]) : Math.abs((p[0] - a[0]) * dy - (p[1] - a[1]) * dx) / len;
  };
  // Where the outline crosses the centre line, at its top and its bottom.
  const crossing = (top) => {
    let best = top ? -Infinity : Infinity;
    for (let i = 0; i < poly.length; i += 1) {
      const a = poly[i];
      const b = poly[(i + 1) % poly.length];
      if ((a[0] <= 0 && b[0] >= 0) || (a[0] >= 0 && b[0] <= 0)) {
        const y = Math.abs(b[0] - a[0]) < 1e-12 ? (top ? Math.max(a[1], b[1]) : Math.min(a[1], b[1])) : a[1] + ((b[1] - a[1]) * (0 - a[0])) / (b[0] - a[0]);
        best = top ? Math.max(best, y) : Math.min(best, y);
      }
    }
    return best;
  };
  const cy = poly.reduce((sum, p) => sum + p[1], 0) / poly.length;
  const side = poly.filter((p) => p[0] > 1e-6).sort((p, q) => Math.atan2(q[1] - cy, q[0]) - Math.atan2(p[1] - cy, p[0]));
  const half = [[0, crossing(true)], ...side, [0, crossing(false)]];
  const keep = new Set([0, half.length - 1]);
  const split = (i, j) => {
    let worst = -1;
    let at = -1;
    for (let k = i + 1; k < j; k += 1) {
      const d = offLine(half[k], half[i], half[j]);
      if (d > worst) {
        worst = d;
        at = k;
      }
    }
    if (worst > tolerance) {
      keep.add(at);
      split(i, at);
      split(at, j);
    }
  };
  split(0, half.length - 1);
  const right = [...keep].sort((a, b) => a - b).map((i) => half[i]);
  const left = right.filter((p) => p[0] > 1e-6).map(([x, y]) => [-x, y]).reverse();
  return [...right, ...left];
}

// A hull piece's points as a mesh: each section a flat fan at its z.
function sectionsMesh(sections) {
  const out = new CarMesh();
  const along = v3(0, 0, 1);
  for (const [z, ring] of sections) {
    const pts = ring.map(([x, y]) => v3(x, y, z));
    for (let k = 1; k < pts.length - 1; k += 1) out.face(pts[0], pts[k], pts[k + 1], along, along, along, P.under);
  }
  return out.result();
}
export function carHullKitMeshes() {
  return Object.keys(CAR_BODIES).flatMap((name) => carHullMeshes(name));
}
