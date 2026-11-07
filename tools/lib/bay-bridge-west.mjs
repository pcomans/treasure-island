// The Bay Bridge's western suspension span (1936; tools/lib/bay-bridge-generation.mjs
// builds the rest): two suspension bridges end to end on one axis, joined at the
// concrete centre anchorage W4. From Yerba Buena Island's cable bent (W7) to San
// Francisco: side span, tower W6, main span, tower W5, side span, W4, side span,
// tower W3, main span, tower W2, side span, the San Francisco anchorage, and the
// approach viaduct.
//
// Measured (HAER CA-32; OSM): the piers' spans (704.1 m main, 353.6 m side), the
// stiffening truss (66 x 35 ft, double deck, Warren with verticals), the towers'
// two legs with X-bracing (three crossings above the deck, two below), W6's place
// and footprint. Inferred (design data): the deck profile, the tower heights within
// the conflicting sources (inner towers taller), cable sags (equal horizontal
// tension through every span), panel spacing, member sizes and the approach. Seen
// from Treasure Island this span is a silhouette at one to five kilometres, so its
// lattice members are wires.

import { BRIDGE_CLASSES as C, BRIDGE_ROLES as R, OCCLUSION as O, WEST_DECK_PROFILE, WEST_SPAN, shade } from "./bay-bridge-design.mjs";
import { lerp, planRectangle, smoothProfile, sweep, world } from "./bay-bridge-kit.mjs";

// Proportions (inferred).
const TRUSS = Object.freeze({
  chordLateral: WEST_SPAN.truss_width_m / 2,
  chordHalf: 0.42,
  topBand: Object.freeze({ above: 1.05, below: 1.5 }),
  bottomBand: 1.5,
  memberRadius: 0.38,
  verticalRadius: 0.32,
  slab: 0.8,
  lowerLateral: 9.4,
});
const LEG = Object.freeze({
  baseAlong: 9.0,
  topAlong: 5.4,
  baseAcross: 6.0,
  topAcross: 3.8,
  baseLateral: 13.2,
  topLateral: 12.6,
  chamfer: 0.9,
  pedestalTop: 12,
});
const TOWER_TOP = Object.freeze({ strutDepth: 6, strutBelowTop: 4, saddleHeight: 4, braceRadius: 1.05, deckClearAbove: 6.5, deckClearBelow: 1.8 });
const PIER = Object.freeze({ along: 22, across: 44, top: 4.5, chamfer: 6 });
const CABLE = Object.freeze({ lateral: 10.6, radius: 0.42, step: 10, saddleDrop: 1.6, midspanRise: 3.0, bentRise: 6.0 });
const SUSPENDER_RADIUS = 0.14;
const ANCHORAGE = Object.freeze({
  center: Object.freeze({ baseAlong: 54, baseAcross: 42, topAlong: 46, topAcross: 36, above: 9 }),
  sf: Object.freeze({ along: 44, across: 46, above: 7 }),
});
const APPROACH = Object.freeze({ halfWidth: 10.0, upperDepth: 2.0, lowerDepth: 1.6, bentSpacing: 40, column: 2.4 });
// The approach carries on past the snapshot's end, behind the skyline billboard.
const SF_EXTENSION_M = 250;
const WATER_FOOTING_M = -2;

export function westSpanFrame() {
  const bearing = WEST_SPAN.axis_bearing_deg * Math.PI / 180;
  const along = [Math.sin(bearing), Math.cos(bearing)];
  const across = [-along[1], along[0]];
  const start = WEST_SPAN.axis_start_en;
  const top = smoothProfile(WEST_DECK_PROFILE, 300);
  return {
    along,
    across,
    top,
    plan: (s, lateral = 0) => [start[0] + along[0] * s + across[0] * lateral, start[1] + along[1] * s + across[1] * lateral],
  };
}

// Sweep stations along the axis from s0 to s1.
function stations(frame, s0, s1, step) {
  const result = [];
  const count = Math.max(1, Math.ceil((s1 - s0) / step));
  for (let k = 0; k <= count; k += 1) {
    const s = s0 + ((s1 - s0) * k) / count;
    const point = frame.plan(s);
    result.push({ s, e: point[0], n: point[1], y: frame.top(s), t: frame.along });
  }
  return result;
}

const box = (u0, u1, v0, v1, role, cls = C.structure, skip = []) => ({
  points: [[u0, v0], [u1, v0], [u1, v1], [u0, v1]],
  roles: [role, role, role, role],
  cls,
  skip,
});

// The double-deck truss between s0 and s1: the top band (barrier, upper deck edge and
// top chord) and the bottom chord as solids on each side, both deck slabs between
// them, and the verticals and Warren diagonals as wires at every panel point.
function buildTruss(mesh, frame, s0, s1, report) {
  const c = TRUSS.chordLateral;
  const h = TRUSS.chordHalf;
  const depth = WEST_SPAN.truss_depth_m;
  const drop = WEST_SPAN.lower_deck_drop_m;
  const under = shade(R.steel_silver, O.under);
  const soffit = shade(R.steel_silver, O.soffit);
  sweep(mesh, stations(frame, s0, s1, 20), () => [
    { ...box(c - h, c + h, -TRUSS.topBand.below, TRUSS.topBand.above, R.steel_silver), roles: [soffit, R.steel_silver, R.steel_silver, R.steel_silver] },
    { ...box(-c - h, -c + h, -TRUSS.topBand.below, TRUSS.topBand.above, R.steel_silver), roles: [soffit, R.steel_silver, R.steel_silver, R.steel_silver] },
    { ...box(c - h, c + h, -depth, -depth + TRUSS.bottomBand, R.steel_silver), roles: [soffit, under, under, under] },
    { ...box(-c - h, -c + h, -depth, -depth + TRUSS.bottomBand, R.steel_silver), roles: [soffit, under, under, under] },
    { ...box(-c + h, c - h, -TRUSS.slab, 0, R.steel_silver), roles: [soffit, under, R.roadway, under] },
    { ...box(-TRUSS.lowerLateral, TRUSS.lowerLateral, -drop - TRUSS.slab, -drop, R.steel_silver), roles: [soffit, under, shade(R.roadway, O.under), under] },
  ]);
  const panels = Math.floor((s1 - s0) / WEST_SPAN.panel_m);
  const offset = (s1 - s0 - panels * WEST_SPAN.panel_m) / 2;
  const node = (s, side, level) => {
    const plan = frame.plan(s, side * c);
    const top = frame.top(s);
    return world(plan[0], plan[1], level === "top" ? top - TRUSS.topBand.below : top - depth + TRUSS.bottomBand);
  };
  for (const side of [-1, 1]) {
    for (let k = 0; k <= panels; k += 1) {
      const s = s0 + offset + k * WEST_SPAN.panel_m;
      mesh.wire(node(s, side, "bottom"), node(s, side, "top"), TRUSS.verticalRadius, R.steel_silver);
      if (k < panels) {
        const next = s + WEST_SPAN.panel_m;
        const rising = k % 2 === 0;
        mesh.wire(node(s, side, rising ? "bottom" : "top"), node(next, side, rising ? "top" : "bottom"), TRUSS.memberRadius, R.steel_silver);
      }
      report.west_panels += 1;
    }
  }
}

// A tower at axis station s, top height `height`: the pier and pedestals, two
// tapering legs, the top strut and saddles, X-bracing above and below the truss.
function buildTower(mesh, frame, s, height) {
  const center = frame.plan(s);
  const along = frame.along;
  const pierRing = planRectangle(center, along, PIER.along / 2, PIER.across / 2, PIER.chamfer);
  mesh.prism([{ ring: pierRing, y: WATER_FOOTING_M }, { ring: pierRing, y: 1.4 }], shade(R.concrete_dark, O.overhang), C.structure, { capTop: false });
  mesh.prism([{ ring: pierRing, y: 1.4 }, { ring: pierRing, y: PIER.top }], shade(R.concrete, O.overhang), C.structure);
  const legTop = height - TOWER_TOP.saddleHeight;
  const legAt = (y, side) => {
    const t = (y - LEG.pedestalTop) / (legTop - LEG.pedestalTop);
    const lateral = lerp(LEG.baseLateral, LEG.topLateral, t);
    return {
      center: frame.plan(s, side * lateral),
      along: lerp(LEG.baseAlong, LEG.topAlong, t),
      across: lerp(LEG.baseAcross, LEG.topAcross, t),
      lateral,
    };
  };
  for (const side of [-1, 1]) {
    const base = legAt(LEG.pedestalTop, side);
    const pedestal = planRectangle(base.center, along, base.along / 2 + 1.4, base.across / 2 + 1.4, 1.0);
    mesh.prism([{ ring: pedestal, y: PIER.top }, { ring: pedestal, y: LEG.pedestalTop }], shade(R.concrete, O.overhang), C.structure);
    const levels = [LEG.pedestalTop, legTop].map((y) => {
      const leg = legAt(y, side);
      return { ring: planRectangle(leg.center, along, leg.along / 2, leg.across / 2, LEG.chamfer), y };
    });
    mesh.prism(levels, R.steel_silver, C.structure);
    // Saddle housing on the leg's top.
    const top = legAt(legTop, side);
    const saddle = planRectangle(top.center, along, top.along / 2 + 0.4, top.across / 2 + 0.3, 0.6);
    mesh.prism([{ ring: saddle, y: legTop }, { ring: saddle, y: height }], R.steel_silver, C.structure);
  }
  // Top strut between the legs.
  const strutY = legTop - TOWER_TOP.strutBelowTop;
  const inner = (y, side) => {
    const leg = legAt(y, side);
    return frame.plan(s, side * (leg.lateral - leg.across / 2 + 0.2));
  };
  const left = inner(strutY, -1);
  const right = inner(strutY, 1);
  mesh.beam(world(left[0], left[1], strutY - TOWER_TOP.strutDepth / 2), world(right[0], right[1], strutY - TOWER_TOP.strutDepth / 2), 3.6, TOWER_TOP.strutDepth, R.steel_silver, C.structure);
  // X-bracing: three crossings from just above the deck to the strut, two from the
  // pedestals to just under the truss, with struts closing each run.
  const deckTop = frame.top(s);
  const runs = [
    { from: deckTop + TOWER_TOP.deckClearAbove, to: strutY - TOWER_TOP.strutDepth, count: 3 },
    { from: LEG.pedestalTop + 3, to: deckTop - WEST_SPAN.truss_depth_m - TOWER_TOP.deckClearBelow, count: 2 },
  ];
  for (const run of runs) {
    for (let k = 0; k < run.count; k += 1) {
      const y0 = lerp(run.from, run.to, k / run.count);
      const y1 = lerp(run.from, run.to, (k + 1) / run.count);
      const a = inner(y0, -1);
      const b = inner(y1, 1);
      const c = inner(y0, 1);
      const d = inner(y1, -1);
      mesh.wire(world(a[0], a[1], y0), world(b[0], b[1], y1), TOWER_TOP.braceRadius, R.steel_silver);
      mesh.wire(world(c[0], c[1], y0), world(d[0], d[1], y1), TOWER_TOP.braceRadius, R.steel_silver);
    }
    const lowA = inner(run.from, -1);
    const lowB = inner(run.from, 1);
    mesh.beam(world(lowA[0], lowA[1], run.from - 1), world(lowB[0], lowB[1], run.from - 1), 2.4, 2.0, R.steel_silver, C.structure);
  }
  return { saddleY: height - CABLE.saddleDrop };
}

// The concrete centre anchorage W4: a battered block from the water to under the
// truss, and above it the cable housing the decks run into, its top a darker steel
// shroud.
function buildCenterAnchorage(mesh, frame, s) {
  const center = frame.plan(s);
  const a = ANCHORAGE.center;
  const deckTop = frame.top(s);
  const split = deckTop - WEST_SPAN.truss_depth_m - 1;
  const base = planRectangle(center, frame.along, a.baseAlong / 2, a.baseAcross / 2, 4);
  const waist = planRectangle(center, frame.along, a.topAlong / 2, a.topAcross / 2, 3);
  mesh.prism([{ ring: base, y: WATER_FOOTING_M }, { ring: base, y: 1.5 }], shade(R.concrete_dark, O.overhang), C.structure, { capTop: false });
  mesh.prism([{ ring: base, y: 1.5 }, { ring: waist, y: split }], shade(R.concrete, O.overhang), C.structure);
  const housing = planRectangle(center, frame.along, a.topAlong / 2 - 3, a.topAcross / 2 - 2, 2.5);
  mesh.prism([{ ring: housing, y: split }, { ring: housing, y: deckTop + a.above - 4 }], R.concrete, C.structure, { capTop: false });
  mesh.prism([{ ring: housing, y: deckTop + a.above - 4 }, { ring: housing, y: deckTop + a.above }], R.steel_silver, C.structure);
  return { saddleY: deckTop + a.above - 1 };
}

function buildSfAnchorage(mesh, frame, s) {
  const center = frame.plan(s);
  const a = ANCHORAGE.sf;
  const ring = planRectangle(center, frame.along, a.along / 2, a.across / 2, 3.5);
  mesh.prism([{ ring, y: WATER_FOOTING_M }, { ring, y: 1.5 }], shade(R.concrete_dark, O.overhang), C.structure, { capTop: false });
  mesh.prism([{ ring, y: 1.5 }, { ring, y: frame.top(s) + a.above }], shade(R.concrete, O.overhang), C.structure);
  return { saddleY: frame.top(s) + a.above - 1 };
}

// The stacked approach decks on frame bents from s0 to s1.
function buildApproach(mesh, frame, s0, s1) {
  const hw = APPROACH.halfWidth;
  const side = shade(R.concrete, O.overhang);
  const soffit = shade(R.concrete, O.soffit);
  sweep(mesh, stations(frame, s0, s1, 25), () => [
    { ...box(-hw, hw, -APPROACH.upperDepth, 0, R.concrete), roles: [soffit, side, R.roadway, side] },
    box(hw - 0.5, hw, 0, 1.1, R.barrier, C.structure, [0]),
    box(-hw, -hw + 0.5, 0, 1.1, R.barrier, C.structure, [0]),
    { ...box(-hw, hw, -WEST_SPAN.lower_deck_drop_m - APPROACH.lowerDepth, -WEST_SPAN.lower_deck_drop_m, R.concrete), roles: [soffit, shade(R.concrete, O.under), shade(R.roadway, O.under), shade(R.concrete, O.under)] },
  ]);
  for (let s = s0 + APPROACH.bentSpacing; s < s1 - 5; s += APPROACH.bentSpacing) {
    for (const side of [-1, 1]) {
      const foot = frame.plan(s, side * (hw - 1.4));
      const ring = planRectangle(foot, frame.along, APPROACH.column / 2, APPROACH.column / 2, 0.4);
      mesh.prism([{ ring, y: WATER_FOOTING_M }, { ring, y: frame.top(s) - APPROACH.upperDepth }], shade(R.concrete, O.under), C.structure);
    }
  }
}

// One cable side's run from saddle to saddle: a parabola of curvature `curvature`
// (equal horizontal tension in every span) through the two saddles.
function cableSpan(frame, side, s0, y0, s1, y1, curvature) {
  const length = s1 - s0;
  const slope = (y1 - y0 - curvature * length * length) / length;
  const points = [];
  const count = Math.max(2, Math.ceil(length / CABLE.step));
  for (let k = 0; k <= count; k += 1) {
    const x = (length * k) / count;
    const plan = frame.plan(s0 + x, side * CABLE.lateral);
    points.push({ s: s0 + x, world: world(plan[0], plan[1], y0 + slope * x + curvature * x * x) });
  }
  return points;
}

// Main cables over one suspension bridge's saddles [{ s, y }] (end, tower, tower, end),
// with suspenders every panel down to the truss's top band.
function buildCables(mesh, frame, saddles, report) {
  // Main span: the cable's low point CABLE.midspanRise over the deck at mid-span.
  const [, towerA, towerB] = saddles;
  const length = towerB.s - towerA.s;
  const midTop = frame.top((towerA.s + towerB.s) / 2) + CABLE.midspanRise;
  // y = yA + b x + a x^2 with its minimum midTop; solve a by bisection.
  let low = 1e-6;
  let high = 1e-2;
  for (let k = 0; k < 80; k += 1) {
    const a = (low + high) / 2;
    const b = (towerB.y - towerA.y - a * length * length) / length;
    const minimum = towerA.y - (b * b) / (4 * a);
    if (minimum > midTop) low = a;
    else high = a;
  }
  const curvature = (low + high) / 2;
  for (const side of [-1, 1]) {
    const points = [];
    for (let k = 1; k < saddles.length; k += 1) {
      const run = cableSpan(frame, side, saddles[k - 1].s, saddles[k - 1].y, saddles[k].s, saddles[k].y, curvature);
      points.push(...(points.length ? run.slice(1) : run));
    }
    mesh.wirePath(points.map((point) => point.world), CABLE.radius, R.cable_silver);
    report.west_cable_segments += points.length - 1;
    // Suspenders at the panel points between the end saddles.
    for (let s = saddles[0].s + WEST_SPAN.panel_m; s < saddles.at(-1).s - 4; s += WEST_SPAN.panel_m) {
      if (saddles.some((saddle) => Math.abs(saddle.s - s) < 6)) continue;
      const k = points.findIndex((point) => point.s >= s);
      if (k <= 0) continue;
      const before = points[k - 1];
      const after = points[k];
      const t = (s - before.s) / (after.s - before.s);
      const y = lerp(before.world[1], after.world[1], t);
      const deck = frame.top(s) + TRUSS.topBand.above;
      if (y - deck < 2.5) continue;
      const plan = frame.plan(s, side * CABLE.lateral);
      mesh.wire(world(plan[0], plan[1], y), world(plan[0], plan[1], deck), SUSPENDER_RADIUS, R.steel_silver);
      report.west_suspenders += 1;
    }
  }
}

// The western span from the YBI cable bent (s = 0) to San Francisco. bentTop: the
// cable bent's saddle height; groundAt for the cables' run into the island's rock.
export function buildWestSpan(mesh, { groundAt }, report) {
  report.west_panels = 0;
  report.west_suspenders = 0;
  report.west_cable_segments = 0;
  const frame = westSpanFrame();
  const piers = WEST_SPAN.piers_m;
  const tops = WEST_SPAN.tower_top_m;
  const w4Half = ANCHORAGE.center.baseAlong / 2 - 3;
  const sfHalf = ANCHORAGE.sf.along / 2;
  buildTruss(mesh, frame, 0, piers.w4 - w4Half, report);
  buildTruss(mesh, frame, piers.w4 + w4Half, piers.w1 - sfHalf, report);
  const w6 = buildTower(mesh, frame, piers.w6, tops.w6);
  const w5 = buildTower(mesh, frame, piers.w5, tops.w5);
  const w3 = buildTower(mesh, frame, piers.w3, tops.w3);
  const w2 = buildTower(mesh, frame, piers.w2, tops.w2);
  const w4 = buildCenterAnchorage(mesh, frame, piers.w4);
  const sf = buildSfAnchorage(mesh, frame, piers.w1);
  buildApproach(mesh, frame, piers.w1 + sfHalf, WEST_SPAN.snapshot_end_m + SF_EXTENSION_M);
  // The YBI cable bent's saddle, then the cables dive at 37 degrees into their
  // anchorage tunnels in the rock (HAER).
  const bentY = frame.top(0) + CABLE.bentRise;
  buildCables(mesh, frame, [{ s: 0, y: bentY }, { s: piers.w6, y: w6.saddleY }, { s: piers.w5, y: w5.saddleY }, { s: piers.w4, y: w4.saddleY }], report);
  buildCables(mesh, frame, [{ s: piers.w4, y: w4.saddleY }, { s: piers.w3, y: w3.saddleY }, { s: piers.w2, y: w2.saddleY }, { s: piers.w1, y: sf.saddleY }], report);
  const dive = Math.tan(37 * Math.PI / 180);
  for (const side of [-1, 1]) {
    const start = frame.plan(0, side * CABLE.lateral);
    let s = 0;
    let y = bentY;
    for (; s > -60; s -= 2) {
      y = bentY + s * dive;
      const plan = frame.plan(s, side * CABLE.lateral);
      const ground = groundAt(plan[0], plan[1]);
      if (ground != null && y < ground - 1) break;
    }
    const end = frame.plan(s, side * CABLE.lateral);
    mesh.wire(world(start[0], start[1], bentY), world(end[0], end[1], y), CABLE.radius, R.cable_silver);
    // The inclined cable bent: a steel leg from the pier up to the saddle.
    const foot = frame.plan(-5, side * CABLE.lateral);
    mesh.beam(world(foot[0], foot[1], frame.top(0) - WEST_SPAN.truss_depth_m - 0.8), world(start[0], start[1], bentY - 0.5), 2.2, 1.6, R.steel_silver, C.structure);
  }
  return { frame };
}
