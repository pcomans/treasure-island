// The San Francisco-Oakland Bay Bridge as one non-playable, non-colliding scenery
// structure (the context:bay-bridge record): the eastern span (the self-anchored
// suspension span, SAS, and the Skyway), the Yerba Buena Island crossing and the
// western suspension span, all from the shared profiles, proportions and roles of
// tools/lib/bay-bridge-design.mjs and the mesh kit of tools/lib/bay-bridge-kit.mjs.
// The runtime builder (game/scripts/world/bay_bridge_builder.gd) draws it.
//
// Plan geometry is the frozen OSM snapshot: the I-80 ways for the deck
// alignments, the SAS tower and crossbeam polygons for its stations, the western
// span's tower W6 for its piers. Heights, depths, sags and spacings are production
// inference from the published figures and dated photographs named in the design
// data; none is surveyed. The Oakland touchdown lies outside the snapshot: the
// deck carries on past its end, falling to a touchdown abutment, so the bridge ends
// in the distance rather than in mid-air.

import { invariant } from "./world-contract.mjs";
import { rawWayLine } from "./osm-geometry.mjs";
import {
  BRIDGE_CLASSES as C,
  BRIDGE_ROLES as R,
  EAST_DECK_PROFILE,
  MAIN_LINE_WAYS,
  SAS,
  SKYWAY,
  YBITS,
} from "./bay-bridge-design.mjs";
import {
  BridgeMesh,
  add,
  extendLine,
  hermite,
  joinLines,
  lerp,
  offsetPlan,
  planRectangle,
  pointAt,
  polylineLength,
  project,
  smoothLine,
  smoothProfile,
  sweep,
  world,
} from "./bay-bridge-kit.mjs";

// --- Proportions (inferred unless noted) ------------------------------------------

const DEG = Math.PI / 180;
// The deck carries on this far past the snapshot's end to the touchdown abutment.
const OAKLAND_EXTENSION_M = 345;
// Concrete traffic barrier on each deck edge.
const BARRIER = Object.freeze({ width: 0.55, height: 1.1 });
// SAS steel box girder: depth (5.5 m published), a vertical fascia under the
// barrier, then a sloped web to the flat bottom.
const SAS_BOX = Object.freeze({ depth: 5.5, fascia: 1.4, webInset: 4.6 });
// The steel box runs from the hinge with the YBI transition structure (11.68 m
// west of W2, Dameron 2015) to its east hinge just past the last crossbeam.
const SAS_WEST_HINGE_OFFSET_M = 11.68;
const SAS_EAST_HINGE_STATION_M = 428;
// Concrete box girders with cantilevered wings (Skyway, YBI transition, Oakland
// touchdown): wing tip and root thickness, wing length, web batter.
const CONCRETE_BOX = Object.freeze({ tip: 0.35, root: 0.8, wing: 4.6, batter: 0.25 });
// YBI transition: shallow reinforced-concrete frame 1 (spans 21.6-36.7 m), deeper
// post-tensioned frame 2 (59.2-84.8 m).
const YBITS_DEPTH = Object.freeze({ frame1: 2.4, frame2: 4.2, frame1Spans: 4 });
// The westbound deck holds the tunnel's upper-deck height from the portal to the
// start of the YBI transition structure's W line.
const UPPER_TRANSITION_TOP_M = 59.2;
// Oakland touchdown: 55 m spans of a 3 m deep box east of the last Skyway pier.
const TOUCHDOWN = Object.freeze({ span: 55, depth: 3.0 });
// SAS tower: legs split by a cruciform gap, tapering from the OSM footprint at the
// pile cap to the head; shear links bridge the gap; a head block and the saddle.
const TOWER = Object.freeze({
  baseY: 3.0,
  topAlong: 11.5,
  topAcross: 8.5,
  baseAcross: 13.0,
  gap: 1.6,
  chamfer: 0.3,
  headBottom: 151.5,
  headTop: 157.0,
  saddle: Object.freeze({ along: 6.0, across: 4.2, top: 160.0 }),
  linkBottom: 10,
  linkTop: 148,
  links: 20,
  linkHeight: 1.3,
  pileCap: Object.freeze({ along: 26, across: 22, top: 3.0 }),
});
// Main cables and suspenders: drawn a little thicker than real (0.78 m cable,
// suspender pairs) so they hold at a kilometre. The suspenders anchor at the
// outer edge of each box, the cable planes leaning in to the saddle.
const CABLE = Object.freeze({ radius: 0.45, saddleY: 158.4, saddleOffset: SAS.saddle_offset_m, landingRise: 1.2, step: 5 });
const SUSPENDER = Object.freeze({ radius: 0.11, towerClear: 12 });
// Piers.
const PILE_CAP_TOP_M = 2.2;
const WATER_FOOTING_M = -2.0;
const GROUND_BURY_M = 3.0;
const SKYWAY_COLUMN = Object.freeze({ across: 7.5, along: 4.5, flareAcross: 10.5, flareAlong: 6.2, flareHeight: 5, cap: Object.freeze({ across: 13, along: 9.5 }) });
const YBITS_COLUMN = Object.freeze({ across: 4.6, along: 2.6, cap: Object.freeze({ across: 9, along: 3.6, depth: 1.6 }) });
const TOUCHDOWN_COLUMN = Object.freeze({ across: 4.2, along: 2.4 });
const END_PIER = Object.freeze({ capAlong: 8, capDepth: 4.5, columnAcross: 8, columnAlong: 6 });
// Light masts (273 white pentagonal poles, 23-65 ft, on the east span: fact sheet)
// along both deck edges, staggered.
const POLES = Object.freeze({ spacing: 45, height: 13, sasHeight: 16, radius: 0.32, inset: 0.35 });

// --- Alignments --------------------------------------------------------------------

function wayLine(rawOsm, id, reverse = false) {
  const line = rawWayLine(rawOsm, id);
  return reverse ? [...line].reverse() : line;
}

// A deck line: a smoothed plan polyline plus helpers by chainage s (metres from its
// west end at the tunnel's east portal).
function deckLine(points) {
  const total = polylineLength(points);
  return {
    points,
    length: total,
    at: (s) => pointAt(points, Math.min(total, Math.max(0, s))),
    chainageOf: (point) => project(points, point).s,
  };
}

// The chainage at which a line crosses the perpendicular to the SAS axis at axis
// station `sigma`.
function chainageAtAxis(line, sigma, axis) {
  const step = 1;
  let previous = null;
  for (let s = 0; s <= line.length; s += step) {
    const { point } = line.at(s);
    const value = axis.station(point) - sigma;
    if (previous != null && Math.sign(value) !== Math.sign(previous.value)) {
      return lerp(previous.s, s, previous.value / (previous.value - value));
    }
    previous = { s, value };
  }
  invariant(false, `Deck line never crosses SAS station ${sigma}`);
  return 0;
}

function sasAxis() {
  const bearing = SAS.axis_bearing_deg * DEG;
  const along = [Math.sin(bearing), Math.cos(bearing)];
  const across = [-along[1], along[0]];
  const center = SAS.tower_center_en;
  return {
    along,
    across,
    center,
    station: (point) => (point[0] - center[0]) * along[0] + (point[1] - center[1]) * along[1],
    lateral: (point) => (point[0] - center[0]) * across[0] + (point[1] - center[1]) * across[1],
    plan: (sigma, lateral) => [
      center[0] + along[0] * sigma + across[0] * lateral,
      center[1] + along[1] * sigma + across[1] * lateral,
    ],
  };
}

// --- Cross-sections ----------------------------------------------------------------

const barrierLoop = (edge, side, cls = C.structure) => {
  // A barrier standing on the deck edge at lateral `edge`, its body inward of it.
  const inner = edge - side * BARRIER.width;
  return {
    points: [[inner, 0], [edge, 0], [edge, BARRIER.height], [inner, BARRIER.height]],
    roles: [R.barrier, R.barrier, R.barrier, R.barrier],
    cls,
    skip: [0],
  };
};

// SAS steel box, deck top at v = 0, lateral -right..left; optional bike path
// cantilever on the right (south) with its railing.
function sasLoops(left, right, bike) {
  const { depth, fascia, webInset } = SAS_BOX;
  const loops = [{
    points: [[left, 0], [left, -fascia], [left - webInset, -depth], [right + webInset, -depth], [right, -fascia], [right, 0]],
    roles: [R.sas_white, R.sas_white, R.sas_white, R.sas_white, R.sas_white, R.roadway],
    cls: C.structure,
  }, barrierLoop(left, 1), barrierLoop(right, -1)];
  if (bike > 0) loops.push(...bikeLoops(right, bike, R.sas_white));
  return loops;
}

function bikeLoops(edge, width, underRole) {
  const outer = edge - width;
  return [{
    points: [[edge, 0], [edge, -0.9], [outer, -0.45], [outer, 0]],
    roles: [R.concrete, underRole, underRole, R.concrete],
    cls: C.structure,
    skip: [0],
  }, {
    points: [[outer + 0.14, 0], [outer, 0], [outer, 1.3], [outer + 0.14, 1.3]],
    roles: [R.barrier, R.barrier, R.barrier, R.barrier],
    cls: C.detail,
    skip: [0],
  }];
}

// Concrete box with cantilevered wings and battered webs, depth d.
function concreteLoops(left, right, depth, bike) {
  const { tip, root, wing, batter } = CONCRETE_BOX;
  const webTopL = left - wing;
  const webTopR = right + wing;
  const webBotL = webTopL - batter * (depth - root);
  const webBotR = webTopR + batter * (depth - root);
  const loops = [{
    points: [[left, 0], [left, -tip], [webTopL, -root], [webBotL, -depth], [webBotR, -depth], [webTopR, -root], [right, -tip], [right, 0]],
    roles: [R.concrete, R.concrete, R.concrete, R.concrete, R.concrete, R.concrete, R.concrete, R.roadway],
    cls: C.structure,
  }, barrierLoop(left, 1), barrierLoop(right, -1)];
  if (bike > 0) loops.push(...bikeLoops(right, bike, R.concrete));
  return loops;
}

// --- Profiles ----------------------------------------------------------------------

const eastProfile = smoothProfile(EAST_DECK_PROFILE, 220);

// Deck top along a line by chainage: the shared east-span profile east of the SAS's
// west hinge, the YBI transition's own grade west of it.
function lineProfile(line, hingeS, westTop, beginS, beginTop) {
  const hingePoint = line.at(hingeS).point;
  const hingeTop = eastProfile(hingePoint[0]);
  const ahead = line.at(hingeS + 10).point;
  const slope = (eastProfile(ahead[0]) - hingeTop) / 10;
  const rise = hermite(beginS, beginTop, 0, hingeS, hingeTop, slope);
  return (s) => {
    if (s >= hingeS) return eastProfile(line.at(s).point[0]);
    if (s >= beginS) return rise(s);
    return lerp(westTop, beginTop, s / Math.max(1, beginS));
  };
}

// --- Stations -----------------------------------------------------------------------

// Sweep stations from s0 to s1 at most `step` apart, including every s in `extra`.
function stationsAlong(line, top, s0, s1, step, extra = []) {
  const values = new Set();
  const count = Math.max(1, Math.ceil((s1 - s0) / step));
  for (let k = 0; k <= count; k += 1) values.add(Number((s0 + ((s1 - s0) * k) / count).toFixed(3)));
  for (const s of extra) if (s > s0 + 0.5 && s < s1 - 0.5) values.add(Number(s.toFixed(3)));
  return [...values].sort((a, b) => a - b).map((s) => {
    const { point, tangent } = line.at(s);
    return { s, e: point[0], n: point[1], y: top(s), t: tangent };
  });
}

// --- Piers ---------------------------------------------------------------------------

function groundOrFooting(groundAt, point) {
  const ground = groundAt(point[0], point[1]);
  return ground == null ? WATER_FOOTING_M : ground - GROUND_BURY_M;
}

function pileCap(mesh, center, axis, halfAlong, halfAcross) {
  const ring = planRectangle(center, axis, halfAlong, halfAcross, Math.min(halfAlong, halfAcross) * 0.35);
  mesh.prism([{ ring, y: WATER_FOOTING_M - 1 }, { ring, y: 1.0 }], R.concrete_dark, C.structure, { capTop: false });
  mesh.prism([{ ring, y: 1.0 }, { ring, y: PILE_CAP_TOP_M }], R.concrete, C.structure);
}

// A column from the ground (or a pile cap in the water) up to `top`, optionally
// flaring over its last metres.
function column(mesh, groundAt, center, axis, size, top, flare = null) {
  const ground = groundAt(center[0], center[1]);
  const inWater = ground == null;
  if (inWater) pileCap(mesh, center, axis, (size.cap?.along ?? size.along + 4) / 2, (size.cap?.across ?? size.across + 4) / 2);
  const base = inWater ? PILE_CAP_TOP_M - 0.05 : ground - GROUND_BURY_M;
  if (top - base < 1) return;
  const chamfer = Math.min(size.along, size.across) * 0.18;
  const shaft = planRectangle(center, axis, size.along / 2, size.across / 2, chamfer);
  if (flare && top - flare.height > base + 2) {
    const head = planRectangle(center, axis, flare.along / 2, flare.across / 2, chamfer * 1.3);
    mesh.prism([{ ring: shaft, y: base }, { ring: shaft, y: top - flare.height }, { ring: head, y: top }], R.concrete, C.structure);
  } else {
    mesh.prism([{ ring: shaft, y: base }, { ring: shaft, y: top }], R.concrete, C.structure);
  }
}

// --- Eastern span --------------------------------------------------------------------

function buildEastSpan(mesh, { rawOsm, groundAt }, report) {
  const axis = sasAxis();
  const westbound = deckLine(smoothLine(extendLine(joinLines(MAIN_LINE_WAYS.westbound_east.map((id) => wayLine(rawOsm, id, true))), OAKLAND_EXTENSION_M)));
  const eastbound = deckLine(smoothLine(extendLine(joinLines(MAIN_LINE_WAYS.eastbound_east.map((id) => wayLine(rawOsm, id))), OAKLAND_EXTENSION_M)));
  const hingeSigma = SAS.w2_station_m - SAS_WEST_HINGE_OFFSET_M;

  // Each deck: [left, right] extents on the SAS and on the concrete spans (from
  // the OSM deck outlines), bike path on the eastbound deck's south edge.
  const decks = [
    {
      name: "westbound",
      line: westbound,
      sas: { left: 15.1, right: -15.1, bike: 0 },
      concrete: { left: SKYWAY.westbound_extent_m[1], right: SKYWAY.westbound_extent_m[0], bike: 0 },
      ybits: { left: YBITS.westbound_width_m / 2, right: -YBITS.westbound_width_m / 2, bike: 0 },
    },
    {
      name: "eastbound",
      line: eastbound,
      sas: { left: 14.0, right: -14.0, bike: 7.0 },
      // The Skyway outline's south edge is the bike path's: -18.6 m from the way.
      concrete: { left: 13.5, right: -13.5, bike: -SKYWAY.eastbound_extent_m[0] - 13.5 },
      ybits: { left: YBITS.eastbound_width_m / 2, right: -YBITS.eastbound_width_m / 2, bike: YBITS.bikeway_width_m },
    },
  ];
  for (const deck of decks) {
    const line = deck.line;
    deck.hingeS = chainageAtAxis(line, hingeSigma, axis);
    deck.w2S = chainageAtAxis(line, SAS.w2_station_m, axis);
    deck.e2S = chainageAtAxis(line, SAS.e2_station_m, axis);
    deck.sasEndS = chainageAtAxis(line, SAS_EAST_HINGE_STATION_M, axis);
  }
  // The YBI transition's begin-bridge points (measured elevations): the E line where
  // the eastbound way turns into a bridge at (634.1, -1385.9); the W line 461.3 m
  // before the westbound hinge.
  const [wb, eb] = decks;
  eb.beginS = eb.line.chainageOf([634.1, -1385.9]);
  wb.beginS = wb.hingeS - 461.3;
  invariant(wb.beginS > 50 && eb.beginS > 50, "YBI transition begins too close to the tunnel portal");
  wb.top = lineProfile(wb.line, wb.hingeS, UPPER_TRANSITION_TOP_M, wb.beginS, YBITS.upper_portal_m);
  eb.top = lineProfile(eb.line, eb.hingeS, YBITS.lower_portal_m, eb.beginS, YBITS.lower_portal_m);
  wb.structureStartS = 0;
  eb.structureStartS = eb.beginS;

  // Skyway piers: every 160 m from E2 along the westbound line, the eastbound pier
  // of each pair across from it; then the touchdown's 55 m spans.
  const piersWb = [];
  for (let k = 1; k <= SKYWAY.pier_pairs; k += 1) piersWb.push(wb.e2S + SKYWAY.span_m * k);
  const lastSkyway = piersWb.at(-1);
  const touchdownWb = [];
  for (let s = lastSkyway + TOUCHDOWN.span; s < wb.line.length - TOUCHDOWN.span * 0.6; s += TOUCHDOWN.span) touchdownWb.push(s);
  const across = (s) => eb.line.chainageOf(wb.line.at(s).point);
  wb.skywayPiers = [wb.e2S, ...piersWb];
  eb.skywayPiers = [eb.e2S, ...piersWb.map(across)];
  wb.touchdownPiers = touchdownWb;
  eb.touchdownPiers = touchdownWb.map(across);
  wb.touchdownS = lastSkyway;
  eb.touchdownS = across(lastSkyway);

  for (const deck of decks) {
    const { line, top } = deck;
    // YBI transition: concrete box, frame 1 shallow, frame 2 deeper.
    const frame2S = deck.name === "westbound"
      ? deck.beginS + YBITS.w_line_spans_m.slice(0, YBITS_DEPTH.frame1Spans).reduce((a, b) => a + b, 0)
      : deck.beginS + (deck.hingeS - deck.beginS) * (YBITS.w_line_spans_m.slice(0, YBITS_DEPTH.frame1Spans).reduce((a, b) => a + b, 0) / 461.3);
    deck.frame2S = frame2S;
    const ybitsDepth = (s) => (s < frame2S - 15 ? YBITS_DEPTH.frame1 : s > frame2S + 15 ? YBITS_DEPTH.frame2 : lerp(YBITS_DEPTH.frame1, YBITS_DEPTH.frame2, (s - frame2S + 15) / 30));
    sweep(mesh, stationsAlong(line, top, deck.structureStartS, deck.hingeS, 6, [frame2S - 15, frame2S + 15]),
      (station) => concreteLoops(deck.ybits.left, deck.ybits.right, ybitsDepth(station.s), deck.ybits.bike));
    // SAS steel box.
    sweep(mesh, stationsAlong(line, top, deck.hingeS, deck.sasEndS, 10, [deck.w2S, deck.e2S]),
      () => sasLoops(deck.sas.left, deck.sas.right, deck.sas.bike));
    // Skyway: haunched between piers.
    const piers = deck.skywayPiers;
    const skywayDepth = (s) => {
      for (let k = 1; k < piers.length; k += 1) {
        if (s <= piers[k]) {
          const t = (s - piers[k - 1]) / (piers[k] - piers[k - 1]);
          return lerp(SKYWAY.depth_midspan_m, SKYWAY.depth_pier_m, (2 * t - 1) ** 2);
        }
      }
      return SKYWAY.depth_midspan_m;
    };
    const skywayEnd = deck.touchdownS;
    const haunchStations = [];
    for (let k = 1; k < piers.length; k += 1) {
      for (const f of [0.08, 0.17, 0.28, 0.4, 0.5, 0.6, 0.72, 0.83, 0.92]) haunchStations.push(lerp(piers[k - 1], piers[k], f));
    }
    sweep(mesh, stationsAlong(line, top, deck.sasEndS, skywayEnd, 16, [...piers, ...haunchStations]),
      (station) => concreteLoops(deck.concrete.left, deck.concrete.right, skywayDepth(station.s), deck.concrete.bike));
    // Oakland touchdown to the abutment.
    sweep(mesh, stationsAlong(line, top, skywayEnd, line.length, 18, deck.touchdownPiers),
      () => concreteLoops(deck.concrete.left, deck.concrete.right, TOUCHDOWN.depth, deck.concrete.bike));
    deck.skywayDepth = skywayDepth;
    deck.ybitsDepth = ybitsDepth;
  }

  // Skyway and touchdown piers (one column per deck), the YBI transition's bents.
  for (const deck of decks) {
    const { line, top } = deck;
    for (const s of deck.skywayPiers.slice(1)) {
      const { point, tangent } = line.at(s);
      column(mesh, groundAt, point, tangent, { ...SKYWAY_COLUMN, cap: SKYWAY_COLUMN.cap }, top(s) - deck.skywayDepth(s) + 0.2,
        { across: SKYWAY_COLUMN.flareAcross, along: SKYWAY_COLUMN.flareAlong, height: SKYWAY_COLUMN.flareHeight });
      report.skyway_piers += 1;
    }
    for (const s of deck.touchdownPiers) {
      const { point, tangent } = line.at(s);
      column(mesh, groundAt, point, tangent, { ...TOUCHDOWN_COLUMN, cap: { across: 8, along: 6 } }, top(s) - TOUCHDOWN.depth + 0.2);
    }
    // Abutment at the touchdown.
    const end = line.at(line.length);
    const ring = planRectangle(add2(end.point, end.tangent, -1), end.tangent, 4, (deck.concrete.left - deck.concrete.right + deck.concrete.bike) / 2 + 1);
    mesh.prism([{ ring, y: WATER_FOOTING_M }, { ring, y: top(line.length) + 0.3 }], R.concrete, C.structure);
  }
  buildTransitionBents(mesh, decks, groundAt, report);

  buildSasTower(mesh, axis);
  buildSasCrossbeams(mesh, axis, decks);
  buildSasEndPiers(mesh, axis, decks, groundAt);
  buildSasCables(mesh, axis, decks, report);
  buildLightPoles(mesh, decks, report);
  report.east_deck_m = Math.round(wb.line.length + eb.line.length);
  return { decks, axis };
}

const add2 = (point, tangent, distance) => [point[0] + tangent[0] * distance, point[1] + tangent[1] * distance];

// YBI transition structure bents: the W line's published spans from its begin, the
// E line's scaled to its length; below the westbound deck where it stands over the
// eastbound one, a straddle bent. Short bents west of the begin carry the
// westbound deck from the portal.
function buildTransitionBents(mesh, decks, groundAt, report) {
  const [wb, eb] = decks;
  const spans = YBITS.w_line_spans_m;
  const total = spans.reduce((a, b) => a + b, 0);
  for (const deck of decks) {
    const other = deck === wb ? eb : wb;
    const scale = (deck.hingeS - deck.beginS) / total;
    const stations = [];
    let s = deck.beginS;
    for (const span of spans.slice(0, -1)) {
      s += span * scale;
      stations.push(s);
    }
    if (deck === wb) for (let t = deck.beginS - 28; t > 30; t -= 28) stations.push(t);
    for (const s0 of stations) {
      const { point, tangent } = deck.line.at(s0);
      const soffit = deck.top(s0) - deck.ybitsDepth(s0);
      const ground = groundAt(point[0], point[1]);
      if (ground != null && soffit - ground < 2.5) continue;
      // Does the other deck pass under this one here?
      const near = project(other.line.points, point);
      const otherTop = other.top(near.s);
      const underneath = near.distance < (other.ybits.left - other.ybits.right) / 2 + 2 && otherTop < soffit - 1;
      if (underneath && deck === wb) {
        const otherPoint = other.line.at(near.s);
        const halfOther = (other.ybits.left - other.ybits.right + other.ybits.bike) / 2 + 2.2;
        const legs = [offsetPlan(otherPoint.point, otherPoint.tangent, halfOther), offsetPlan(otherPoint.point, otherPoint.tangent, -halfOther)];
        for (const leg of legs) column(mesh, groundAt, leg, otherPoint.tangent, { across: 2.4, along: 2.4 }, soffit - 1.4);
        const capY = soffit - 0.7;
        mesh.beam(world(legs[0][0], legs[0][1], capY), world(legs[1][0], legs[1][1], capY), 2.6, 1.6, R.concrete, C.structure);
        report.ybits_bents += 1;
        continue;
      }
      if (near.distance < (other.ybits.left - other.ybits.right) / 2 + 1 && otherTop > soffit) continue;
      column(mesh, groundAt, point, tangent, YBITS_COLUMN, soffit - YBITS_COLUMN.cap.depth + 0.1);
      const cap = planRectangle(point, tangent, YBITS_COLUMN.cap.along / 2, YBITS_COLUMN.cap.across / 2, 0.5);
      mesh.prism([{ ring: cap, y: soffit - YBITS_COLUMN.cap.depth }, { ring: cap, y: soffit + 0.1 }], R.concrete, C.structure);
      report.ybits_bents += 1;
    }
  }
}

// The SAS tower: four tapering legs split by a cruciform gap, shear links across the
// gap at 20 levels, a head block and the cable saddle; the pile cap at the water.
function buildSasTower(mesh, axis) {
  const center = axis.center;
  const { along, across } = axis;
  const baseAlong = SAS.tower_base_m.along;
  const halfAt = (y) => {
    const t = (y - TOWER.baseY) / (TOWER.headTop - TOWER.baseY);
    return { along: lerp(baseAlong, TOWER.topAlong, t) / 2, across: lerp(TOWER.baseAcross, TOWER.topAcross, t) / 2 };
  };
  const cap = TOWER.pileCap;
  const capRing = planRectangle(center, along, cap.along / 2, cap.across / 2, 3);
  mesh.prism([{ ring: capRing, y: WATER_FOOTING_M - 1 }, { ring: capRing, y: 0.8 }], R.concrete_dark, C.structure, { capTop: false });
  mesh.prism([{ ring: capRing, y: 0.8 }, { ring: capRing, y: cap.top }], R.concrete, C.structure);
  const g = TOWER.gap / 2;
  // One leg: the quadrant (sa, sc) of the tower section, its outer corner chamfered.
  const legRing = (y, sa, sc) => {
    const half = halfAt(y);
    const k = TOWER.chamfer * Math.min(half.along - g, half.across - g);
    const at = (a, c) => [center[0] + along[0] * a * sa + across[0] * c * sc, center[1] + along[1] * a * sa + across[1] * c * sc];
    const ring = [at(g, g), at(half.along, g), at(half.along, half.across - k), at(half.along - k, half.across), at(g, half.across)];
    return sa * sc > 0 ? ring : [...ring].reverse();
  };
  const levels = [TOWER.baseY, 52, 104, TOWER.headBottom];
  for (const [sa, sc] of [[1, 1], [1, -1], [-1, 1], [-1, -1]]) {
    mesh.prism(levels.map((y) => ({ ring: legRing(y, sa, sc), y })), R.sas_white, C.structure, { capTop: false });
  }
  // Shear links: plates filling the gap, flush with the leg faces.
  for (let k = 0; k < TOWER.links; k += 1) {
    const y0 = lerp(TOWER.linkBottom, TOWER.linkTop, k / (TOWER.links - 1));
    const y1 = y0 + TOWER.linkHeight;
    const half = halfAt((y0 + y1) / 2);
    mesh.prism([0, 1].map((m) => ({ ring: planRectangle(center, along, half.along - 0.05, g, 0), y: m ? y1 : y0 })), R.sas_white, C.detail, { capBottom: true });
    mesh.prism([0, 1].map((m) => ({ ring: planRectangle(center, along, g, half.across - 0.05, 0), y: m ? y1 : y0 })), R.sas_white, C.detail, { capBottom: true });
  }
  // Head block and saddle.
  const headHalf = halfAt(TOWER.headBottom);
  const head = planRectangle(center, along, headHalf.along + 0.3, headHalf.across + 0.3, 0.8);
  mesh.prism([{ ring: head, y: TOWER.headBottom }, { ring: head, y: TOWER.headTop }], R.sas_white, C.structure, { capBottom: true });
  const saddle = planRectangle(center, along, TOWER.saddle.along / 2, TOWER.saddle.across / 2, 0.6);
  mesh.prism([{ ring: saddle, y: TOWER.headTop }, { ring: saddle, y: TOWER.saddle.top }], R.sas_white, C.structure);
}

// Crossbeams between the twin decks at the OSM polygons' stations.
function buildSasCrossbeams(mesh, axis, decks) {
  const [wb, eb] = decks;
  for (const sigma of SAS.crossbeam_stations_m) {
    const sw = chainageAtAxis(wb.line, sigma, axis);
    const se = chainageAtAxis(eb.line, sigma, axis);
    const pw = wb.line.at(sw);
    const pe = eb.line.at(se);
    const innerW = offsetPlan(pw.point, pw.tangent, wb.sas.right + SAS_BOX.webInset * 0.6);
    const innerE = offsetPlan(pe.point, pe.tangent, eb.sas.left - SAS_BOX.webInset * 0.6);
    const y = (wb.top(sw) + eb.top(se)) / 2 - 0.8 - 1.6;
    mesh.beam(world(innerW[0], innerW[1], y), world(innerE[0], innerE[1], y), 3.6, 3.2, R.sas_white, C.detail);
  }
}

// W2 and E2: a cap beam under both decks on a column under each.
function buildSasEndPiers(mesh, axis, decks, groundAt) {
  for (const sigma of [SAS.w2_station_m, SAS.e2_station_m]) {
    const points = decks.map((deck) => {
      const s = chainageAtAxis(deck.line, sigma, axis);
      const { point, tangent } = deck.line.at(s);
      return { point, tangent, soffit: deck.top(s) - SAS_BOX.depth, deck };
    });
    const soffit = Math.min(...points.map((p) => p.soffit));
    const outer = [
      offsetPlan(points[0].point, points[0].tangent, points[0].deck.sas.left - 1),
      offsetPlan(points[1].point, points[1].tangent, points[1].deck.sas.right + 1),
    ];
    mesh.beam(world(outer[0][0], outer[0][1], soffit - END_PIER.capDepth / 2 + 0.2), world(outer[1][0], outer[1][1], soffit - END_PIER.capDepth / 2 + 0.2),
      END_PIER.capAlong, END_PIER.capDepth, R.concrete, C.structure);
    for (const p of points) {
      column(mesh, groundAt, p.point, p.tangent, { across: END_PIER.columnAcross, along: END_PIER.columnAlong, cap: { across: 16, along: 13 } }, soffit - END_PIER.capDepth + 0.4);
    }
  }
}

// The SAS main cable: per side a back-span and a main-span run over the tower
// saddle, in planes leaning from the saddle out to each deck's outer edge; equal
// horizontal tension on both sides of the tower, so the back span reaches W2 still
// falling while the main span flattens onto the deck at its landing.
function buildSasCables(mesh, axis, decks, report) {
  const [wb, eb] = decks;
  for (const [deck, side] of [[wb, 1], [eb, -1]]) {
    // The deck edge at an axis station: plan point and its top.
    const edgeAt = (sigma) => {
      const s = chainageAtAxis(deck.line, sigma, axis);
      const { point, tangent } = deck.line.at(s);
      const lateral = side > 0 ? deck.sas.left - 0.6 : deck.sas.right + 0.6;
      return { plan: offsetPlan(point, tangent, lateral), top: deck.top(s) };
    };
    const saddleY = CABLE.saddleY;
    const landing = SAS.main_cable_landing_m;
    const edgeLanding = edgeAt(landing);
    const lowY = edgeLanding.top + CABLE.landingRise;
    const curvature = (saddleY - lowY) / (landing * landing);
    const westEdge = edgeAt(SAS.w2_station_m);
    const westY = westEdge.top + CABLE.landingRise;
    const back = -SAS.w2_station_m;
    const fall = (saddleY + curvature * back * back - westY) / back;
    const heightAt = (sigma) => {
      if (sigma >= 0) return sigma <= landing ? lowY + curvature * (sigma - landing) ** 2 : edgeAt(sigma).top + CABLE.landingRise;
      const x = -sigma;
      return saddleY - fall * x + curvature * x * x;
    };
    const saddlePlan = axis.plan(0, side * CABLE.saddleOffset);
    const edge0 = edgeAt(0);
    const span = saddleY - edge0.top - CABLE.landingRise;
    // A point of the leaning cable plane at axis station sigma.
    const cablePoint = (sigma) => {
      const y = heightAt(sigma);
      const edge = edgeAt(sigma);
      const share = Math.min(1, Math.max(0, (y - edge.top - CABLE.landingRise) / span));
      const edgeLateral = axis.lateral(edge.plan);
      const saddleLateral = axis.lateral(saddlePlan);
      const plan = axis.plan(sigma, lerp(edgeLateral, saddleLateral, share));
      return { world: world(plan[0], plan[1], y), edge };
    };
    const points = [];
    for (let sigma = SAS.w2_station_m; sigma < 0; sigma += CABLE.step) points.push(cablePoint(sigma).world);
    for (let sigma = 0; sigma <= SAS.e2_station_m; sigma += CABLE.step) points.push(cablePoint(sigma).world);
    points.push(cablePoint(SAS.e2_station_m).world);
    mesh.wirePath(points, CABLE.radius, R.sas_white);
    report.cable_segments += points.length - 1;
    // Suspenders every 10 m, in the cable plane down to the deck edge.
    for (const direction of [-1, 1]) {
      const limit = direction > 0 ? landing : back;
      for (let x = SUSPENDER.towerClear; x < limit - 2; x += SAS.suspender_spacing_m) {
        const sigma = direction * x;
        const { world: top, edge } = cablePoint(sigma);
        const bottom = world(edge.plan[0], edge.plan[1], edge.top + 0.4);
        if (top[1] - bottom[1] < 2) continue;
        mesh.wire(top, bottom, SUSPENDER.radius, R.suspender);
        report.suspenders += 1;
      }
    }
  }
}

// Light masts along both edges of each deck, staggered, taller on the SAS.
function buildLightPoles(mesh, decks, report) {
  for (const deck of decks) {
    const { line, top } = deck;
    for (const [sideIndex, side] of [[0, 1], [1, -1]]) {
      for (let s = deck.structureStartS + 20 + sideIndex * POLES.spacing / 2; s < line.length - 10; s += POLES.spacing) {
        const onSas = s >= deck.hingeS && s <= deck.sasEndS;
        const extent = s < deck.hingeS ? deck.ybits : onSas ? deck.sas : deck.concrete;
        const lateral = side > 0 ? extent.left - POLES.inset : extent.right + POLES.inset;
        const { point, tangent } = line.at(s);
        const plan = offsetPlan(point, tangent, lateral);
        const base = top(s) + BARRIER.height;
        const height = onSas ? POLES.sasHeight : POLES.height;
        mesh.wire(world(plan[0], plan[1], base), world(plan[0], plan[1], base + height), POLES.radius, R.light_pole);
        report.light_poles += 1;
      }
    }
  }
}

// --- Entry point -----------------------------------------------------------------------

// The whole bridge as one mesh. groundAt(east, north) is the drawn ground of
// Yerba Buena Island (null over the water).
export function bayBridgeMesh({ rawOsm, groundAt }) {
  const mesh = new BridgeMesh();
  const report = {
    skyway_piers: 0,
    ybits_bents: 0,
    suspenders: 0,
    cable_segments: 0,
    light_poles: 0,
    east_deck_m: 0,
  };
  buildEastSpan(mesh, { rawOsm, groundAt }, report);
  invariant(mesh.indices.length > 0, "Bay Bridge mesh is empty");
  report.vertices = mesh.vertexCount;
  report.triangles = mesh.indices.length / 3;
  return { mesh: mesh.toRecordMesh(), report };
}
