// The modern eastern span of the Bay Bridge (OSM site relation r13543937) as
// simple non-playable polygonal context that reads from Treasure Island's
// shores: the two decks as box girders on a deck profile, the self-anchored
// suspension span's single tower and main cables, the crossbeams between its
// twin decks and the pier columns under the decks. Seen from Pier 1 (dated
// Street View, Mar 2025) and Gate 5 (Nov 2025) the bridge is the tall white
// tower with its cables over a long elevated deck on paired columns; a flat
// sheet at one height has no vertical extent and vanishes edge-on.
//
// Plan geometry is the frozen OSM: the two deck outlines (westbound w1006027483
// and eastbound w1000066963, Yerba Buena Island to Oakland), the Yerba Buena
// Island ramps (w1000066953), the tower footprint (w237735191, height=160) and
// the small closed ways between the decks along the suspension span, drawn as
// its crossbeams. Heights, girder depth, column sizes and pier spacing are
// production inference from published figures (160 m tower, 385 m main span,
// girders lifted about 46 m above the water, 160 m Skyway spans on piers 14-35
// m tall) and the dated photographs; they are not surveyed.
//
// Everything is one mesh in the generated context record, built without
// collision like the rest of the context. Each face's UV picks its role's texel
// in the runtime's bay bridge palette (EAST_SPAN_PALETTE_UV): light concrete
// for the tower, columns and cables, mid grey girder sides, darker undersides
// and a road-grey deck top.

import earcut from "earcut";

import { invariant, roundCoordinate } from "./world-contract.mjs";
import { rawWayFootprint } from "./osm-geometry.mjs";

const DECK_WAY_IDS = Object.freeze(["1006027483", "1000066963"]);
const RAMP_WAY_ID = "1000066953";
const TOWER_WAY_ID = "237735191";
// Deck top above the water datum (m) by east coordinate: level across the
// Yerba Buena Island transition and the suspension span (its tops about 54 m
// up beside the tower in the dated Pier 1 view), then the Skyway's descent to
// the Oakland touchdown.
const DECK_PROFILE = Object.freeze([
  Object.freeze([540, 55]),
  Object.freeze([1100, 54]),
  Object.freeze([1440, 52]),
  Object.freeze([3550, 22]),
  Object.freeze([3810, 14]),
]);
const GIRDER_DEPTH_M = 5.5;
// Deck outlines are subdivided to edges no longer than this, so the girder
// sides and the triangulated top follow the profile.
const OUTLINE_STEP_M = 40;
// The centreline is sampled at this east spacing.
const CENTRELINE_STEP_M = 5;
const TOWER_HEIGHT_M = 160;
// The tower is one slender shaft (the dated photos show a single white shaft
// about 0.07-0.09 as wide as it is tall above the deck): TOWER_BASE_HALF_M half
// sizes along and across the deck at the water, tapering by TOWER_SHAFT_TAPER
// to TOWER_SHAFT_TOP_M and by TOWER_CROWN_TAPER more to its top.
const TOWER_BASE_HALF_M = Object.freeze({ along: 4.5, across: 3.5 });
const TOWER_SHAFT_TOP_M = 150;
const TOWER_SHAFT_TAPER = 0.67;
const TOWER_CROWN_TAPER = 0.9;
// Main cables: one over each deck, from deck anchorages at the ends of the
// suspension span to the saddle; drawn a little thicker than the real 0.78 m
// so they hold together at a kilometre.
const CABLE_SIZE_M = 1.1;
const CABLE_SEGMENTS = 24;
const CABLE_ANCHOR_RISE_M = 1.5;
const CABLE_SADDLE_DROP_M = 2.5;
// The main span's cables meet the deck this far (in plan) from the tower and
// run on along it to their anchorage at the span's east end; the back span's
// meet it at W2. Fitted on the dated Pier 1 and Gate 5 photos, reprojected
// into render cameras at their poses: at 350 m the cable's height over the
// deck matches both within a few photo pixels. A landing at 280 m hangs it
// too low in both, and a parabola down to the span's east end (400-435 m) too
// high from Pier 1, meeting the deck half as far again from the tower as the
// Gate 5 photo shows.
const MAIN_CABLE_LANDING_M = 350;
// The low run along the deck to the anchorage, in pieces about this long.
const CABLE_DECK_STEP_M = 20;
// Suspenders (50 groups a side on the real span) hang every SUSPENDER_SPACING_M
// of the cable's plan length, a little thicker than real so they read as the
// span's fine comb; none in the last stretch at the tower.
const SUSPENDER_SPACING_M = 12.5;
const SUSPENDER_SIZE_M = 0.5;
const SUSPENDER_TOWER_CLEAR_M = 8;
const CROSSBEAM_TOP_DROP_M = 0.6;
const CROSSBEAM_DEPTH_M = 3;
// Skyway piers: a column under each deck every SKYWAY_SPAN_M from the east end
// of the suspension span (14 pier pairs, E3-E16), then shorter touchdown spans.
const SKYWAY_SPAN_M = 160;
const SKYWAY_PIER_COUNT = 14;
const TOUCHDOWN_SPAN_M = 55;
const COLUMN_ACROSS_M = 7;
const COLUMN_ALONG_M = 4.5;
const COLUMN_CAP = Object.freeze({ across: 10, along: 6.5, height: 3 });
// Bents under the Yerba Buena Island transition, every TRANSITION_SPAN_M west
// of the suspension span while the deck stands clear of the island.
const TRANSITION_SPAN_M = 55;
const TRANSITION_CLEARANCE_M = 8;
// The suspension span's end piers carry a cap beam across both decks.
const END_CAP_DEPTH_M = 4.5;
const END_CAP_ALONG_M = 8;
const END_COLUMN = Object.freeze({ across: 9, along: 6.5 });
// About half a deck's width: the end cap beams reach the decks' outer edges.
const DECK_HALF_WIDTH_M = 13;
// Footings of the tower and columns, under the water line.
const FOOTING_M = -1;

// Each face's UV: the centre of its role's texel in the runtime's 4 x 1 bay
// bridge palette (WorldChunkBuilder.BAY_BRIDGE_PALETTE, in this order).
export const EAST_SPAN_PALETTE_UV = Object.freeze({
  structure: Object.freeze([0.125, 0.5]),
  fascia: Object.freeze([0.375, 0.5]),
  soffit: Object.freeze([0.625, 0.5]),
  roadway: Object.freeze([0.875, 0.5]),
});

function emptyMesh() {
  return { vertices: [], normals: [], uvs: [], indices: [] };
}

function pushVertex(mesh, position, normal, uv) {
  const index = mesh.vertices.length / 3;
  mesh.vertices.push(...position.map(roundCoordinate));
  mesh.normals.push(...normal.map(roundCoordinate));
  mesh.uvs.push(...uv.map(roundCoordinate));
  return index;
}

function sub(a, b) {
  return [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
}

function cross(a, b) {
  return [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
}

function unit(vector) {
  const length = Math.hypot(...vector);
  invariant(length > 1e-9, "East span zero-length vector");
  return vector.map((value) => value / length);
}

// A triangle over already pushed vertices, wound counterclockwise around
// `normal` as the generated contract stores every triangle; a sliver left by
// rounding is skipped.
function pushIndexedTriangle(mesh, indices, normal) {
  const [a, b, c] = indices.map((index) => mesh.vertices.slice(index * 3, index * 3 + 3));
  const face = cross(sub(b, a), sub(c, a));
  if (Math.hypot(...face) / 2 <= 1e-6) return;
  if (face[0] * normal[0] + face[1] * normal[1] + face[2] * normal[2] < 0) mesh.indices.push(indices[0], indices[2], indices[1]);
  else mesh.indices.push(...indices);
}

// A flat convex face (corners in order round it) sharing its corners between
// the triangles of its fan, all with the palette UV `uv`.
function pushFace(mesh, corners, normal, uv) {
  const indices = corners.map((corner) => pushVertex(mesh, corner, normal, uv));
  for (let index = 1; index + 1 < indices.length; index += 1) {
    pushIndexedTriangle(mesh, [indices[0], indices[index], indices[index + 1]], normal);
  }
}

// Deck top at an east coordinate, interpolated along DECK_PROFILE.
function eastSpanDeckTop(east) {
  if (east <= DECK_PROFILE[0][0]) return DECK_PROFILE[0][1];
  for (let index = 1; index < DECK_PROFILE.length; index += 1) {
    const [x1, y1] = DECK_PROFILE[index];
    if (east <= x1) {
      const [x0, y0] = DECK_PROFILE[index - 1];
      return y0 + (y1 - y0) * (east - x0) / (x1 - x0);
    }
  }
  return DECK_PROFILE.at(-1)[1];
}

function densifyRing(ring, step) {
  const dense = [];
  for (let index = 0; index < ring.length; index += 1) {
    const start = ring[index];
    const end = ring[(index + 1) % ring.length];
    const count = Math.max(1, Math.ceil(Math.hypot(end[0] - start[0], end[1] - start[1]) / step));
    for (let part = 0; part < count; part += 1) {
      const t = part / count;
      dense.push([start[0] + (end[0] - start[0]) * t, start[1] + (end[1] - start[1]) * t]);
    }
  }
  return dense;
}

// A deck (or ramp) outline as a closed box girder: the triangulated top on the
// profile, the same triangles GIRDER_DEPTH_M lower facing down, and the sides.
function addGirder(mesh, ring) {
  const dense = densifyRing(ring, OUTLINE_STEP_M);
  const triangles = earcut(dense.flatMap((point) => point), [], 2);
  invariant(triangles.length > 0 && triangles.length % 3 === 0, "East span deck triangulation failed");
  const top = (point) => [point[0], eastSpanDeckTop(point[0]), -point[1]];
  const bottom = (point) => [point[0], eastSpanDeckTop(point[0]) - GIRDER_DEPTH_M, -point[1]];
  for (const [level, normal, uv] of [[top, [0, 1, 0], EAST_SPAN_PALETTE_UV.roadway], [bottom, [0, -1, 0], EAST_SPAN_PALETTE_UV.soffit]]) {
    const first = mesh.vertices.length / 3;
    for (const point of dense) pushVertex(mesh, level(point), normal, uv);
    for (let index = 0; index < triangles.length; index += 3) {
      pushIndexedTriangle(mesh, [first + triangles[index], first + triangles[index + 1], first + triangles[index + 2]], normal);
    }
  }
  // Counterclockwise outer ring (east/north): the outward side is to the right.
  for (let index = 0; index < dense.length; index += 1) {
    const start = dense[index];
    const end = dense[(index + 1) % dense.length];
    const length = Math.hypot(end[0] - start[0], end[1] - start[1]);
    if (length <= 1e-6) continue;
    const outward = [(end[1] - start[1]) / length, 0, (end[0] - start[0]) / length];
    pushFace(mesh, [bottom(start), bottom(end), top(end), top(start)], outward, EAST_SPAN_PALETTE_UV.fascia);
  }
}

// A light-concrete box from y0 to y1 over a plan rectangle centred on `center`
// (east/north) with half sizes along `axis` (unit, east/north) and across it,
// tapering to `topScale` of them at y1. The bottom stands in the ground or
// water and is left open, as is a top that something covers (`closed` false).
function addBox(mesh, center, axis, halfAlong, halfAcross, y0, y1, topScale = 1, closed = true) {
  const across = [-axis[1], axis[0]];
  const corner = (sa, sc, scale) => [
    center[0] + axis[0] * sa * halfAlong * scale + across[0] * sc * halfAcross * scale,
    center[1] + axis[1] * sa * halfAlong * scale + across[1] * sc * halfAcross * scale,
  ];
  const signs = [[-1, -1], [1, -1], [1, 1], [-1, 1]];
  const base = signs.map(([sa, sc]) => corner(sa, sc, 1));
  const head = signs.map(([sa, sc]) => corner(sa, sc, topScale));
  const at = (point, y) => [point[0], y, -point[1]];
  for (let index = 0; index < 4; index += 1) {
    const next = (index + 1) % 4;
    const a = at(base[index], y0);
    const b = at(base[next], y0);
    const c = at(head[next], y1);
    const d = at(head[index], y1);
    pushFace(mesh, [a, b, c, d], unit(cross(sub(b, a), sub(d, a))), EAST_SPAN_PALETTE_UV.structure);
  }
  if (closed) pushFace(mesh, head.map((point) => at(point, y1)), [0, 1, 0], EAST_SPAN_PALETTE_UV.structure);
}

// A square-section tube along a polyline of world points (the main cables).
function addTube(mesh, points, size) {
  const half = size / 2;
  for (let index = 1; index < points.length; index += 1) {
    const start = points[index - 1];
    const end = points[index];
    const direction = unit(sub(end, start));
    const side = unit(cross(direction, [0, 1, 0]));
    const up = unit(cross(side, direction));
    const offsets = [[1, 1], [-1, 1], [-1, -1], [1, -1]].map(([s, u]) => [
      side[0] * s * half + up[0] * u * half,
      side[1] * s * half + up[1] * u * half,
      side[2] * s * half + up[2] * u * half,
    ]);
    for (let face = 0; face < 4; face += 1) {
      const o0 = offsets[face];
      const o1 = offsets[(face + 1) % 4];
      const mid = unit([o0[0] + o1[0], o0[1] + o1[1], o0[2] + o1[2]]);
      pushFace(
        mesh,
        [
          [start[0] + o0[0], start[1] + o0[1], start[2] + o0[2]],
          [start[0] + o1[0], start[1] + o1[1], start[2] + o1[2]],
          [end[0] + o1[0], end[1] + o1[1], end[2] + o1[2]],
          [end[0] + o0[0], end[1] + o0[1], end[2] + o0[2]],
        ],
        mid,
        EAST_SPAN_PALETTE_UV.structure,
      );
    }
  }
}

// The deck's centreline (east/north), sampled every CENTRELINE_STEP_M of east:
// the midpoint of the outline's crossings at each east, following the pair
// nearest the previous sample where the outline branches.
function deckCentreline(ring) {
  const east = ring.map((point) => point[0]);
  const west = Math.ceil(Math.min(...east)) + 1;
  const eastEnd = Math.floor(Math.max(...east)) - 1;
  const line = [];
  for (let x = west; x <= eastEnd; x += CENTRELINE_STEP_M) {
    const crossings = [];
    for (let index = 0; index < ring.length; index += 1) {
      const a = ring[index];
      const b = ring[(index + 1) % ring.length];
      if ((a[0] - x) * (b[0] - x) > 0 || a[0] === b[0]) continue;
      if (a[0] === x && b[0] === x) continue;
      crossings.push(a[1] + (b[1] - a[1]) * (x - a[0]) / (b[0] - a[0]));
    }
    crossings.sort((left, right) => left - right);
    if (crossings.length < 2) continue;
    let best = null;
    for (let index = 0; index + 1 < crossings.length; index += 2) {
      const mid = (crossings[index] + crossings[index + 1]) / 2;
      const score = line.length > 0 ? Math.abs(mid - line.at(-1)[1]) : -(crossings[index + 1] - crossings[index]);
      if (best == null || score < best.score) best = { mid, score };
    }
    line.push([x, best.mid]);
  }
  invariant(line.length > 10, "East span deck centreline is too short");
  return line;
}

// Point and unit tangent (east/north) at arc length s along a polyline.
function alongLine(line, distance) {
  let remaining = distance;
  for (let index = 1; index < line.length; index += 1) {
    const a = line[index - 1];
    const b = line[index];
    const length = Math.hypot(b[0] - a[0], b[1] - a[1]);
    if (remaining <= length || index === line.length - 1) {
      const t = Math.min(1, Math.max(0, remaining / length));
      return { point: [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t], tangent: [(b[0] - a[0]) / length, (b[1] - a[1]) / length] };
    }
    remaining -= length;
  }
  throw new Error("East span arc length outside the centreline");
}

function arcLengthAtEast(line, east) {
  let total = 0;
  for (let index = 1; index < line.length; index += 1) {
    const a = line[index - 1];
    const b = line[index];
    const length = Math.hypot(b[0] - a[0], b[1] - a[1]);
    if (east <= b[0]) return total + length * Math.max(0, (east - a[0]) / (b[0] - a[0]));
    total += length;
  }
  return total;
}

function lineLength(line) {
  return arcLengthAtEast(line, Infinity);
}

function closedWay(rawOsm, wayId) {
  const way = rawOsm.ways.get(wayId);
  invariant(way, `East span way w${wayId} is missing`);
  return way.node_refs.length >= 4 && way.node_refs[0] === way.node_refs.at(-1);
}

function rectangleFrame(ring, label) {
  invariant(ring.length === 4, `${label} is not a four-corner footprint`);
  const center = [ring.reduce((sum, point) => sum + point[0], 0) / 4, ring.reduce((sum, point) => sum + point[1], 0) / 4];
  const edgeA = [ring[1][0] - ring[0][0], ring[1][1] - ring[0][1]];
  const edgeB = [ring[2][0] - ring[1][0], ring[2][1] - ring[1][1]];
  const lengthA = Math.hypot(...edgeA);
  const lengthB = Math.hypot(...edgeB);
  return { center, axis: [edgeA[0] / lengthA, edgeA[1] / lengthA], along: lengthA, across: lengthB };
}

// A column on its footing under the water line (on Yerba Buena Island the
// part under the coarse terrain surface stays hidden), capped under the deck.
function addColumn(mesh, center, tangent, across, along, soffit) {
  const capBottom = soffit - COLUMN_CAP.height;
  addBox(mesh, center, tangent, along / 2, across / 2, FOOTING_M, capBottom + 0.2, 1, false);
  addBox(mesh, center, tangent, COLUMN_CAP.along / 2, COLUMN_CAP.across / 2, capBottom, soffit + 0.3, 1, false);
}

// The east span's mesh, in world coordinates (x east, z = -north).
// groundAt(east, north) is Yerba Buena Island's ground height there, or null
// over the water; the transition bents stop where the deck meets the island.
export function eastSpanMesh(rawOsm, memberWayIds, groundAt) {
  const members = new Set(memberWayIds.map(String));
  for (const id of [...DECK_WAY_IDS, RAMP_WAY_ID, TOWER_WAY_ID]) {
    invariant(members.has(id) && closedWay(rawOsm, id), `East span way w${id} is not a closed member of the frozen site relation`);
  }
  const mesh = emptyMesh();

  const decks = DECK_WAY_IDS.map((id) => {
    const geometry = rawWayFootprint(rawOsm, id);
    invariant(geometry.length === 1 && geometry[0].length === 1, `East span deck w${id} is not one simple outline`);
    addGirder(mesh, geometry[0][0]);
    return { id, line: deckCentreline(geometry[0][0]) };
  });
  const ramp = rawWayFootprint(rawOsm, RAMP_WAY_ID);
  invariant(ramp.length === 1 && ramp[0].length === 1, "East span ramp is not one simple outline");
  addGirder(mesh, ramp[0][0]);

  // Crossbeams: the remaining small closed member ways, between the decks
  // along the suspension span. Its ends are the westmost and eastmost.
  const beams = [...members]
    .filter((id) => ![...DECK_WAY_IDS, RAMP_WAY_ID, TOWER_WAY_ID].includes(id) && closedWay(rawOsm, id))
    .map((id) => rectangleFrame(rawWayFootprint(rawOsm, id)[0][0], `East span crossbeam w${id}`))
    .sort((left, right) => left.center[0] - right.center[0]);
  invariant(beams.length >= 10, "East span suspension-span crossbeams are missing");
  for (const beam of beams) {
    const top = eastSpanDeckTop(beam.center[0]) - CROSSBEAM_TOP_DROP_M;
    addBox(mesh, beam.center, beam.axis, beam.along / 2, beam.across / 2, top - CROSSBEAM_DEPTH_M, top);
  }
  const westEnd = beams[0].center;
  const eastEnd = beams.at(-1).center;

  // Tower: one slender shaft on the OSM footprint's centre, its long side along
  // the deck, tapering up to a narrower crown.
  const tower = rectangleFrame(rawWayFootprint(rawOsm, TOWER_WAY_ID)[0][0], "East span tower");
  const spanLength = Math.hypot(eastEnd[0] - westEnd[0], eastEnd[1] - westEnd[1]);
  const spanAxis = [(eastEnd[0] - westEnd[0]) / spanLength, (eastEnd[1] - westEnd[1]) / spanLength];
  addBox(mesh, tower.center, spanAxis, TOWER_BASE_HALF_M.along, TOWER_BASE_HALF_M.across,
    FOOTING_M, TOWER_SHAFT_TOP_M, TOWER_SHAFT_TAPER, false);
  addBox(mesh, tower.center, spanAxis, TOWER_BASE_HALF_M.along * TOWER_SHAFT_TAPER, TOWER_BASE_HALF_M.across * TOWER_SHAFT_TAPER,
    TOWER_SHAFT_TOP_M, TOWER_HEIGHT_M, TOWER_CROWN_TAPER);

  // Main cables over each deck: from the saddle a parabola falls to the deck
  // at its landing (W2 for the back span, MAIN_CABLE_LANDING_M out for the
  // main span), then runs along the deck to the anchorage; the suspenders hang
  // from the parabola to the deck.
  const saddle = [tower.center[0], TOWER_HEIGHT_M - CABLE_SADDLE_DROP_M, -tower.center[1]];
  for (const deck of decks) {
    for (const end of [westEnd, eastEnd]) {
      const anchor = alongLine(deck.line, arcLengthAtEast(deck.line, end[0])).point;
      const reach = Math.hypot(saddle[0] - anchor[0], saddle[2] + anchor[1]);
      const landing = end === eastEnd ? Math.min(MAIN_CABLE_LANDING_M, reach) : reach;
      // A plan point `distance` out from the tower along the line to the anchorage.
      const planAt = (distance) => [
        saddle[0] + (anchor[0] - saddle[0]) * distance / reach,
        -saddle[2] + (anchor[1] + saddle[2]) * distance / reach,
      ];
      const deckAt = (distance) => eastSpanDeckTop(planAt(distance)[0]) + CABLE_ANCHOR_RISE_M;
      const cableAt = (distance) => {
        const [east, north] = planAt(distance);
        const y = distance >= landing
          ? deckAt(distance)
          : deckAt(landing) + (saddle[1] - deckAt(landing)) * ((landing - distance) / landing) ** 2;
        return [east, y, -north];
      };
      const points = [];
      for (let index = 0; index <= CABLE_SEGMENTS; index += 1) points.push(cableAt(landing * index / CABLE_SEGMENTS));
      const runs = Math.ceil((reach - landing) / CABLE_DECK_STEP_M);
      for (let index = 1; index <= runs; index += 1) points.push(cableAt(landing + (reach - landing) * index / runs));
      addTube(mesh, points, CABLE_SIZE_M);
      const axis = [(anchor[0] - saddle[0]) / reach, (anchor[1] + saddle[2]) / reach];
      for (let distance = SUSPENDER_TOWER_CLEAR_M + SUSPENDER_SPACING_M / 2; distance < landing; distance += SUSPENDER_SPACING_M) {
        const [east, y, z] = cableAt(distance);
        const deckTop = eastSpanDeckTop(east);
        if (y - deckTop < 1) continue;
        addBox(mesh, [east, -z], axis, SUSPENDER_SIZE_M / 2, SUSPENDER_SIZE_M / 2, deckTop - 0.2, y, 1, false);
      }
    }
  }

  // Columns under each deck: the suspension span's end piers (a cap beam
  // across both decks on one column per deck), the Skyway and touchdown piers
  // east of it, and the transition bents west of it where the deck stands
  // clear of Yerba Buena Island.
  for (const end of [westEnd, eastEnd]) {
    const soffit = eastSpanDeckTop(end[0]) - GIRDER_DEPTH_M;
    const anchors = decks.map((deck) => alongLine(deck.line, arcLengthAtEast(deck.line, end[0])));
    const between = [(anchors[0].point[0] + anchors[1].point[0]) / 2, (anchors[0].point[1] + anchors[1].point[1]) / 2];
    const span = Math.hypot(anchors[0].point[0] - anchors[1].point[0], anchors[0].point[1] - anchors[1].point[1]);
    const tangent = anchors[0].tangent;
    addBox(mesh, between, tangent, END_CAP_ALONG_M / 2, span / 2 + DECK_HALF_WIDTH_M, soffit - END_CAP_DEPTH_M, soffit + 0.3);
    for (const anchor of anchors) {
      addBox(mesh, anchor.point, tangent, END_COLUMN.along / 2, END_COLUMN.across / 2, FOOTING_M, soffit - END_CAP_DEPTH_M + 0.2, 1, false);
    }
  }
  for (const deck of decks) {
    const total = lineLength(deck.line);
    const start = arcLengthAtEast(deck.line, eastEnd[0]);
    const stations = [];
    for (let index = 1; index <= SKYWAY_PIER_COUNT; index += 1) stations.push(start + SKYWAY_SPAN_M * index);
    for (let station = stations.at(-1) + TOUCHDOWN_SPAN_M; station < total - TOUCHDOWN_SPAN_M / 2; station += TOUCHDOWN_SPAN_M) stations.push(station);
    const westStart = arcLengthAtEast(deck.line, westEnd[0]);
    for (let station = westStart - TRANSITION_SPAN_M; station > 0; station -= TRANSITION_SPAN_M) {
      const { point } = alongLine(deck.line, station);
      const ground = groundAt(point[0], point[1]);
      if (ground != null && eastSpanDeckTop(point[0]) - GIRDER_DEPTH_M - ground < TRANSITION_CLEARANCE_M) break;
      stations.push(station);
    }
    for (const station of stations.filter((value) => value > 0 && value < total)) {
      const { point, tangent } = alongLine(deck.line, station);
      addColumn(mesh, point, tangent, COLUMN_ACROSS_M, COLUMN_ALONG_M, eastSpanDeckTop(point[0]) - GIRDER_DEPTH_M);
    }
  }
  invariant(mesh.indices.length > 0 && mesh.indices.length / 3 < 40_000, "East span mesh is empty or unexpectedly large");
  return mesh;
}
