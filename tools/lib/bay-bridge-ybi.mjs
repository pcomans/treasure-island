// The Bay Bridge's Yerba Buena Island crossing (tools/lib/bay-bridge-generation.mjs
// builds the rest): the Yerba Buena Tunnel's two portals, the double-deck concrete
// viaduct from the west portal to the western span's cable bent and its pier
// (OSM w1136339259, "W7"), the bridge-tagged I-80 ramps and road bridges, and the
// I-80 and ramp roadways at grade, laid on the island's drawn terrain.
//
// The tunnel and portal figures are HAER CA-32's (540 ft bore, 76-79 ft wide, 58 ft
// high, 79 ft arches with a 21 ft rise; portals of three segmental arches in
// receding planes between large blocks). Everything else here (wall depths, bent
// spacing, ramp sections, heights between their ends) is production inference.
// None of it is visible from Treasure Island's shores (the ridge hides it); it
// carries the bridge's decks and roads continuously across the island.

import earcut from "earcut";

import { invariant } from "./world-contract.mjs";
import { rawWayLine } from "./osm-geometry.mjs";
import { isBridgeTrackHighway } from "./ybi-context-generation.mjs";
import { BRIDGE_CLASSES as C, BRIDGE_ROLES as R, OCCLUSION as O, TUNNEL, WEST_SPAN, YBITS, YBI_RAMP_WAYS, shade } from "./bay-bridge-design.mjs";
import { add, lerp, offsetPlan, planRectangle, pointAt, polylineLength, project, scale, smoothLine, sub, sweep, unit, world } from "./bay-bridge-kit.mjs";

const yes = (value) => value === "yes" || value === "true" || value === "1";

// --- Portals -----------------------------------------------------------------------

const PORTAL = Object.freeze({
  wallWidth: 50,
  wallBelow: 3,
  wallAbove: 25,
  thickness: 2.4,
  ringStep: 1.6,
  ringSetback: 1.1,
  pylon: Object.freeze({ width: 8, depth: 7, above: 28 }),
  slab: 1.6,
  voidDepth: 9,
});

// The arch-topped opening of half width `half` (springing `spring` and crown `crown`
// above `base`) in facade coordinates (u across, v up), counterclockwise.
function archOpening(half, base, spring, crown, segments = 14) {
  // A segmental arch through (half, spring), (0, crown) and (-half, spring).
  const rise = crown - spring;
  const radius = (half * half + rise * rise) / (2 * rise);
  const centerV = crown - radius;
  const sweepAngle = Math.asin(half / radius);
  const points = [[-half, base], [half, base]];
  for (let k = 0; k <= segments; k += 1) {
    const angle = sweepAngle - (2 * sweepAngle * k) / segments;
    points.push([Math.sin(angle) * radius, centerV + Math.cos(angle) * radius]);
  }
  return points;
}

// One portal facade: three walls in receding planes, each with an arched opening a
// ring step narrower than the one in front, flanking pylons, the upper deck's slab
// across the opening and a dark void behind it.
function buildPortal(mesh, center, outward, lowerTop, upperTop) {
  const across = [-outward[1], outward[0]];
  const at = (u, v, depth) => world(center[0] + across[0] * u - outward[0] * depth, center[1] + across[1] * u - outward[1] * depth, v);
  const base = lowerTop - PORTAL.wallBelow;
  const top = lowerTop + PORTAL.wallAbove;
  const half = TUNNEL.bore_width_m / 2;
  const spring = lowerTop + TUNNEL.bore_height_m - TUNNEL.arch_rise_m;
  const crown = lowerTop + TUNNEL.bore_height_m;
  const out = [outward[0], 0, -outward[1]];
  for (let ring = 2; ring >= 0; ring -= 1) {
    const grow = ring * PORTAL.ringStep;
    const front = (2 - ring) * PORTAL.ringSetback;
    const hole = archOpening(half + grow, lowerTop - 0.4, spring + grow * 0.5, crown + grow);
    const wallHalf = PORTAL.wallWidth / 2 - ring * 2.5;
    const outer = [[-wallHalf, base], [wallHalf, base], [wallHalf, top - ring * 2], [-wallHalf, top - ring * 2]];
    facadeSlab(mesh, outer, hole, (u, v, d) => at(u, v, front + d), PORTAL.thickness, out, shade(R.concrete, O.overhang));
  }
  for (const side of [-1, 1]) {
    const u0 = side * (PORTAL.wallWidth / 2 + PORTAL.pylon.width / 2 - 1);
    const ring = [[u0 - PORTAL.pylon.width / 2, -1.5], [u0 + PORTAL.pylon.width / 2, -1.5], [u0 + PORTAL.pylon.width / 2, PORTAL.pylon.depth], [u0 - PORTAL.pylon.width / 2, PORTAL.pylon.depth]]
      .map(([u, d]) => [center[0] + across[0] * u - outward[0] * d, center[1] + across[1] * u - outward[1] * d]);
    mesh.prism([{ ring, y: base }, { ring, y: lowerTop + PORTAL.pylon.above }], shade(R.concrete, O.overhang), C.structure);
  }
  // Upper deck slab across the opening, and the dark void behind the opening.
  const slab = [[-half, -2], [half, -2], [half, 14], [-half, 14]]
    .map(([u, d]) => [center[0] + across[0] * u - outward[0] * d, center[1] + across[1] * u - outward[1] * d]);
  mesh.prism([{ ring: slab, y: upperTop - PORTAL.slab }, { ring: slab, y: upperTop }], shade(R.concrete, O.under), C.detail, { capBottom: true });
  const voidCorners = [[-half - 1, lowerTop - 1], [half + 1, lowerTop - 1], [half + 1, crown + 1], [-half - 1, crown + 1]];
  mesh.face(voidCorners.map(([u, v]) => at(u, v, PORTAL.voidDepth)), out, R.tunnel_void, C.structure);
}

// A wall slab of `thickness` with an opening: its front face, the opening's reveal
// and its outer edges. `place(u, v, depth)` maps facade coordinates (u across, v up,
// depth back from the front) to the world; both rings run counterclockwise in (u, v).
function facadeSlab(mesh, outer, hole, place, thickness, outward, role) {
  const triangles = earcut([...outer, ...hole].flatMap((point) => point), [outer.length], 2);
  const first = mesh.vertexCount;
  for (const [u, v] of [...outer, ...hole]) mesh.vertex(place(u, v, 0), outward, role, C.structure);
  for (let k = 0; k < triangles.length; k += 3) mesh.triangle(first + triangles[k], first + triangles[k + 1], first + triangles[k + 2], outward);
  const acrossWorld = unit(sub(place(1, 0, 0), place(0, 0, 0)));
  for (const [ring, sign] of [[outer, 1], [hole, -1]]) {
    for (let k = 0; k < ring.length; k += 1) {
      const a = ring[k];
      const b = ring[(k + 1) % ring.length];
      const du = b[0] - a[0];
      const dv = b[1] - a[1];
      const size = Math.hypot(du, dv);
      if (size < 1e-6) continue;
      // Out of the wall's material: away from the outer ring, into the opening.
      const normal = add(scale(acrossWorld, (sign * dv) / size), [0, (-sign * du) / size, 0]);
      mesh.quad(place(a[0], a[1], 0), place(b[0], b[1], 0), place(b[0], b[1], thickness), place(a[0], a[1], thickness), normal, role, C.structure);
    }
  }
}

// --- West approach and cable bent -------------------------------------------------

const APPROACH = Object.freeze({ halfWidth: 10.5, upperDepth: 2.2, lowerDepth: 1.8, bentSpacing: 24, column: 1.8 });

function buildWestApproach(mesh, rawOsm, groundAt, westTop) {
  const upper = rawWayLine(rawOsm, "23874736");
  const lower = [...rawWayLine(rawOsm, "179235221"), ...rawWayLine(rawOsm, "52721870").slice(1)].reverse();
  // The stacked decks share one line, from the west portal to the cable bent.
  const count = 20;
  const line = [];
  for (let k = 0; k <= count; k += 1) {
    const a = pointAt(upper, (polylineLength(upper) * k) / count).point;
    const b = pointAt(lower, (polylineLength(lower) * k) / count).point;
    line.push([(a[0] + b[0]) / 2, (a[1] + b[1]) / 2]);
  }
  const total = polylineLength(line);
  const upperAt = (s) => lerp(YBITS.upper_portal_m + 0.15, westTop, s / total);
  const lowerAt = (s) => upperAt(s) - WEST_SPAN.lower_deck_drop_m;
  const stations = [];
  for (let k = 0; k <= 12; k += 1) {
    const s = (total * k) / 12;
    const { point, tangent } = pointAt(line, s);
    stations.push({ s, e: point[0], n: point[1], y: 0, t: tangent });
  }
  const deck = (topAt, depth, withBarriers) => (station) => {
    const y = topAt(station.s);
    const loops = [{
      points: [[APPROACH.halfWidth, y], [APPROACH.halfWidth, y - depth], [-APPROACH.halfWidth, y - depth], [-APPROACH.halfWidth, y]],
      roles: [shade(R.concrete, O.overhang), shade(R.concrete, O.soffit), shade(R.concrete, O.overhang), withBarriers ? R.roadway : shade(R.roadway, O.under)],
      cls: C.structure,
    }];
    if (withBarriers) {
      for (const side of [-1, 1]) {
        const e = side * APPROACH.halfWidth;
        const i = e - side * 0.5;
        loops.push({ points: [[i, y], [e, y], [e, y + 1.1], [i, y + 1.1]], roles: [R.barrier, R.barrier, R.barrier, R.barrier], cls: C.structure, skip: [0] });
      }
    }
    return loops;
  };
  sweep(mesh, stations, deck(upperAt, APPROACH.upperDepth, true));
  sweep(mesh, stations, deck(lowerAt, APPROACH.lowerDepth, false));
  // Frame bents: a column each side up to the upper deck, a cap under each deck.
  for (let s = APPROACH.bentSpacing; s < total - 6; s += APPROACH.bentSpacing) {
    const { point, tangent } = pointAt(line, s);
    for (const side of [-1, 1]) {
      const foot = offsetPlan(point, tangent, side * (APPROACH.halfWidth - 1.2));
      const ground = groundAt(foot[0], foot[1]);
      const bottom = (ground ?? 0) - 3;
      const ring = planRectangle(foot, tangent, APPROACH.column / 2, APPROACH.column / 2, 0.3);
      mesh.prism([{ ring, y: bottom }, { ring, y: upperAt(s) - APPROACH.upperDepth }], shade(R.concrete, O.under), C.structure);
    }
  }
  return { line, total, upperAt };
}

// The cable bent pier under the western span's YBI end (OSM w1136339259): a concrete
// pier oriented on the span's axis, with an inclined steel bent carrying the main
// cables over to their anchorage tunnels in the rock.
function buildCableBent(mesh, rawOsm, groundAt, westTop) {
  const outline = rawWayLine(rawOsm, "1136339259");
  const bearing = WEST_SPAN.axis_bearing_deg * Math.PI / 180;
  const along = [Math.sin(bearing), Math.cos(bearing)];
  const acrossDir = [-along[1], along[0]];
  const points = outline.slice(0, -1);
  const center = [points.reduce((sum, p) => sum + p[0], 0) / points.length, points.reduce((sum, p) => sum + p[1], 0) / points.length];
  let minA = Infinity; let maxA = -Infinity; let minC = Infinity; let maxC = -Infinity;
  for (const p of points) {
    const d = [p[0] - center[0], p[1] - center[1]];
    const a = d[0] * along[0] + d[1] * along[1];
    const c = d[0] * acrossDir[0] + d[1] * acrossDir[1];
    minA = Math.min(minA, a); maxA = Math.max(maxA, a); minC = Math.min(minC, c); maxC = Math.max(maxC, c);
  }
  const mid = [center[0] + along[0] * (minA + maxA) / 2 + acrossDir[0] * (minC + maxC) / 2, center[1] + along[1] * (minA + maxA) / 2 + acrossDir[1] * (minC + maxC) / 2];
  const ground = groundAt(mid[0], mid[1]) ?? 20;
  const pierTop = westTop - WEST_SPAN.truss_depth_m - 0.8;
  const ring = planRectangle(mid, along, (maxA - minA) / 2 * 0.7, (maxC - minC) / 2 * 0.8, 1.5);
  mesh.prism([{ ring, y: ground - 4 }, { ring, y: pierTop }], shade(R.concrete, O.under), C.structure);
  return { center: mid, along, across: acrossDir, pierTop };
}

// --- Ramps and road bridges ---------------------------------------------------------

const RAMP = Object.freeze({ laneWidth: 3.7, shoulders: 4.2, depth: 2.0, columnSpacing: 30, minClearance: 4, column: Object.freeze({ across: 2.6, along: 1.8 }) });

// Chains of bridge-tagged ramp ways joined end to end; each chain's ends take the
// deck or ground height there, and its heights run straight between them.
function rampChains(rawOsm) {
  const ways = YBI_RAMP_WAYS.map((id) => {
    const way = rawOsm.ways.get(id);
    invariant(way, `YBI ramp way w${id} is missing`);
    return { id, way, line: rawWayLine(rawOsm, id), first: way.node_refs[0], last: way.node_refs.at(-1) };
  });
  const used = new Set();
  const chains = [];
  for (const start of ways) {
    if (used.has(start.id)) continue;
    // Walk back to the chain's first way, then forward.
    // A loop of ramp ways ends the walk where it comes back to a way already passed.
    let head = start;
    const passed = new Set([start.id]);
    for (;;) {
      const previous = ways.find((other) => !used.has(other.id) && other !== head && other.last === head.first);
      if (!previous || passed.has(previous.id)) break;
      passed.add(previous.id);
      head = previous;
    }
    const chain = [head];
    used.add(head.id);
    for (;;) {
      const next = ways.find((other) => !used.has(other.id) && other.first === chain.at(-1).last);
      if (!next) break;
      chain.push(next);
      used.add(next.id);
    }
    chains.push(chain);
  }
  return chains;
}

function buildRamps(mesh, rawOsm, groundAt, endHeight) {
  for (const chain of rampChains(rawOsm)) {
    const points = [];
    for (const piece of chain) for (const point of piece.line) if (points.length === 0 || Math.hypot(point[0] - points.at(-1)[0], point[1] - points.at(-1)[1]) > 0.01) points.push(point);
    const line = smoothLine(points, 4, 3);
    const total = polylineLength(line);
    if (total < 12) continue;
    const startTop = endHeight(line[0]);
    const endTop = endHeight(line.at(-1));
    const top = (s) => lerp(startTop, endTop, s / total);
    const lanes = Math.max(1, Number(chain[0].way.tags.lanes ?? 1) || 1);
    const half = (lanes * RAMP.laneWidth + RAMP.shoulders) / 2;
    const stations = [];
    const count = Math.max(2, Math.ceil(total / 6));
    for (let k = 0; k <= count; k += 1) {
      const s = (total * k) / count;
      const { point, tangent } = pointAt(line, s);
      stations.push({ s, e: point[0], n: point[1], y: top(s), t: tangent });
    }
    sweep(mesh, stations, () => [
      {
        points: [[half, 0], [half, -0.4], [half - 1.4, -RAMP.depth], [-half + 1.4, -RAMP.depth], [-half, -0.4], [-half, 0]],
        roles: [shade(R.concrete, O.overhang), shade(R.concrete, O.under), shade(R.concrete, O.soffit), shade(R.concrete, O.under), shade(R.concrete, O.overhang), R.roadway],
        cls: C.structure,
      },
      { points: [[half - 0.5, 0], [half, 0], [half, 1.1], [half - 0.5, 1.1]], roles: [R.barrier, R.barrier, R.barrier, R.barrier], cls: C.structure, skip: [0] },
      { points: [[-half, 0], [-half + 0.5, 0], [-half + 0.5, 1.1], [-half, 1.1]], roles: [R.barrier, R.barrier, R.barrier, R.barrier], cls: C.structure, skip: [0] },
    ]);
    for (let s = RAMP.columnSpacing / 2; s < total - 4; s += RAMP.columnSpacing) {
      const { point, tangent } = pointAt(line, s);
      const ground = groundAt(point[0], point[1]);
      const soffit = top(s) - RAMP.depth;
      if (ground != null && soffit - ground < RAMP.minClearance) continue;
      const ring = planRectangle(point, tangent, RAMP.column.along / 2, RAMP.column.across / 2, 0.4);
      mesh.prism([{ ring, y: (ground ?? 0) - 3 }, { ring, y: soffit + 0.1 }], shade(R.concrete, O.under), C.structure);
    }
  }
}

// I-80 and its ramps at grade on the island (bridge-track ways neither bridge nor
// tunnel): roadway strips laid on the drawn terrain.
const AT_GRADE = Object.freeze({ widths: Object.freeze({ motorway: 16, motorway_link: 8.5, construction: 8.5 }), lift: 0.25, step: 2, across: 4 });

function buildAtGradeRoads(mesh, rawOsm, groundAt, skipNear) {
  const ids = [...rawOsm.ways.keys()].filter((id) => {
    const tags = rawOsm.ways.get(id).tags;
    return tags.highway != null && isBridgeTrackHighway(tags) && !yes(tags.bridge) && !yes(tags.tunnel);
  }).sort();
  for (const id of ids) {
    // Every bridge-track way of the snapshot resolves; a missing node is a data error.
    const line = rawWayLine(rawOsm, id);
    const total = polylineLength(line);
    if (total < 4) continue;
    const width = AT_GRADE.widths[rawOsm.ways.get(id).tags.highway] ?? 8.5;
    const count = Math.max(1, Math.ceil(total / AT_GRADE.step));
    // Rows of points across the road every AT_GRADE.step metres, each on the drawn
    // terrain, so the strip follows the ground between the terrain's own vertices.
    const rows = [];
    for (let k = 0; k <= count; k += 1) {
      const { point, tangent } = pointAt(line, (total * k) / count);
      const row = [];
      for (let m = 0; m <= AT_GRADE.across; m += 1) {
        const plan = offsetPlan(point, tangent, width / 2 - (width * m) / AT_GRADE.across);
        const height = groundAt(plan[0], plan[1]);
        row.push(height == null ? null : world(plan[0], plan[1], height + AT_GRADE.lift));
      }
      rows.push(row.every((corner) => corner != null) && !skipNear(point) ? row : null);
    }
    for (let k = 1; k < rows.length; k += 1) {
      const a = rows[k - 1];
      const b = rows[k];
      if (!a || !b) continue;
      for (let m = 0; m < AT_GRADE.across; m += 1) mesh.quad(a[m], a[m + 1], b[m + 1], b[m], [0, 1, 0], R.roadway, C.structure);
    }
  }
}

// --- Entry point ----------------------------------------------------------------------

// decks: the eastern span's westbound and eastbound deck lines and profiles (from the
// tunnel's east portal). westTop: the western span's upper-deck top at the cable bent.
export function buildYbiCrossing(mesh, { rawOsm, groundAt, decks, westTop }) {
  const east = TUNNEL.east_portal_en;
  const west = TUNNEL.west_portal_en;
  const axis = unit([east[0] - west[0], east[1] - west[1], 0]);
  buildPortal(mesh, east, [axis[0], axis[1]], YBITS.lower_portal_m, YBITS.upper_portal_m);
  buildPortal(mesh, west, [-axis[0], -axis[1]], YBITS.lower_portal_m + 0.3, YBITS.upper_portal_m + 0.15);
  buildWestApproach(mesh, rawOsm, groundAt, westTop);
  const bent = buildCableBent(mesh, rawOsm, groundAt, westTop);
  // A ramp end on an elevated main deck takes that deck's height, else the ground's.
  const endHeight = (point) => {
    for (const deck of decks) {
      const near = project(deck.line.points, point);
      if (near.distance < 14 && near.s >= deck.structureStartS - 5) return deck.top(near.s);
    }
    if (Math.hypot(point[0] - WEST_SPAN.axis_start_en[0], point[1] - WEST_SPAN.axis_start_en[1]) < 14) return westTop;
    return (groundAt(point[0], point[1]) ?? 0) + 0.2;
  };
  buildRamps(mesh, rawOsm, groundAt, endHeight);
  const skipNear = (point) => Math.hypot(point[0] - west[0], point[1] - west[1]) < 22 || Math.hypot(point[0] - east[0], point[1] - east[1]) < 22;
  buildAtGradeRoads(mesh, rawOsm, groundAt, skipNear);
  return { bent };
}
