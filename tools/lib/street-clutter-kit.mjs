// The street-clutter kit: meshes for PlayableWorld/StreetDetail/Clutter (parked
// cars, cones, A-frame barricades, dumpsters, stock-tank planters), written to
// game/resources/models/street/street_clutter_kit.glb by
// tools/build_street_clutter_kit.mjs and drawn at runtime by
// game/scripts/world/street_clutter_builder.gd with one shader
// (game/resources/materials/world/street/street_clutter.gdshader).
//
// Every vertex names a part (glass, tyre, lamp, ...) in UV.x and carries a baked
// occlusion factor in UV.y; the shader turns the part into its colour and
// finish. The body paint is not in the mesh: each parked car is a MultiMesh
// instance whose colour is the paint, so one mesh per body type serves every
// colour. Meshes face -Z (the front), +Y up, +X the car's right; the origin is
// on the ground under the middle of the body.
//
// The cars are tools/lib/street-car-kit.mjs (bodies, levels, dimensions); this
// module holds the small props and the kit's mesh list.

import { KIT_BASE_PARTS, MeshBuilder, clamp, curve, lerp, v3, vadd, vcross, vdot, vlen, vnorm, vscale, vsub } from "./kit-mesh.mjs";
import { CAR_BODIES, CAR_PART_COUNT, buildCar, carBodyGeometry, carKitExtras, carKitMeshes } from "./street-car-kit.mjs";

// Re-exported for the kit's other users (the yard kit, the world generator, the validator).
export { CAR_BODIES, MeshBuilder, buildCar, carBodyGeometry, carKitExtras, clamp, curve, lerp, v3, vadd, vcross, vdot, vlen, vnorm, vscale, vsub };

// The sixteen parts the kits share. The kit's meshes name a part in UV.x as
// (part + 0.5) / CLUTTER_KIT_PART_SLOTS: the car kit's longer list
// (street-car-kit.mjs CAR_PARTS), whose first sixteen these are.
export const CLUTTER_KIT_PARTS = KIT_BASE_PARTS;
const PART = Object.freeze(Object.fromEntries(CLUTTER_KIT_PARTS.map((name, index) => [name, index])));
export const CLUTTER_KIT_PART_COUNT = CLUTTER_KIT_PARTS.length;
export const CLUTTER_KIT_PART_SLOTS = CAR_PART_COUNT;

// ---------------------------------------------------------------- small props
// A 28 inch traffic cone: orange body, two white reflective collars, black base.
function buildCone(lodIndex) {
  const out = new MeshBuilder(CLUTTER_KIT_PART_SLOTS);
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
  const out = new MeshBuilder(CLUTTER_KIT_PART_SLOTS);
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
  const out = new MeshBuilder(CLUTTER_KIT_PART_SLOTS);
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
  const out = new MeshBuilder(CLUTTER_KIT_PART_SLOTS);
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

export const CLUTTER_LOD_COUNT = 2;

// Every mesh of the kit, by name: car_<body>_lod<n> and car_<body>_shadow,
// <prop>_lod<n>, then the drivable car's parts (carKitExtras).
export function clutterKitMeshes() {
  const meshes = carKitMeshes();
  for (const [name, prop] of Object.entries(CLUTTER_PROPS_KIT)) {
    for (let lod = 0; lod < CLUTTER_LOD_COUNT; lod += 1) meshes.push({ name: `${name}_lod${lod}`, ...prop.build(lod) });
  }
  return [...meshes, ...carKitExtras()];
}
