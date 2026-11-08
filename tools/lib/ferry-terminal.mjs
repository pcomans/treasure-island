// The Treasure Island ferry terminal's float, gangway, mooring dolphins, ferry
// stop and the breakwater off it (owner decisions 2026-11-07): scenery beyond the island's source
// extract, read straight from the frozen raw OSM and written into
// generated/world/context.json as its ferry_terminal section. The runtime
// (game/scripts/world/ferry_terminal.gd) draws the float, gangway, piles and the
// docked Sammy J from it. None of these are playable rows: the float stays
// outside the playable outline, and the ferry spawn (findInitialSpawn in
// tools/build_godot_world.mjs) only checks the float and stop, as before.
//
// Positions are world x, z (+X east, +Z south), metres, rounded to the
// coordinate contract's millimetre.

import { projectLonLat } from "./coordinates.mjs";
import { multiPolygonArea, intersectMultiPolygons, rawWayFootprint } from "./osm-geometry.mjs";
import { invariant, roundCoordinate } from "./world-contract.mjs";

export const FERRY_TERMINAL_SOURCE_KEYS = Object.freeze({
  float: "w1036802529",
  gangway: "w1036802528",
  pier: "w1011830367",
  dolphins: Object.freeze(["w1222514696", "w1222514697"]),
  stop: "n9335172179",
  breakwater: "w1011830371",
});
// The float outline turns by more than this at its four corners; the nodes
// along its sides (the stop among them) turn by less.
const CORNER_TURN_DEGREES = 45;
// Its sides, as drawn: about 41 m along and 13 m across (OSM 533.6 m²).
const FLOAT_LENGTH_RANGE_M = Object.freeze([35, 48]);
const FLOAT_WIDTH_RANGE_M = Object.freeze([10, 16]);
const GANGWAY_LENGTH_RANGE_M = Object.freeze([18, 30]);
const DOLPHIN_RADIUS_RANGE_M = Object.freeze([0.5, 1.5]);
// The breakwater off the terminal: one straight frozen line of about 207 m.
const BREAKWATER_LENGTH_RANGE_M = Object.freeze([150, 260]);

function world(point) {
  return [roundCoordinate(point[0]), roundCoordinate(-point[1])];
}

function nodePoint(rawOsm, nodeId, label) {
  const node = rawOsm.nodes.get(nodeId);
  invariant(node, `${label} references missing node n${nodeId}`);
  return projectLonLat(node.coordinate);
}

function way(rawOsm, sourceKey) {
  invariant(sourceKey.startsWith("w"), `${sourceKey} is not a way`);
  const found = rawOsm.ways.get(sourceKey.slice(1));
  invariant(found, `Frozen ferry terminal source ${sourceKey} is missing`);
  return found;
}

function distance(a, b) {
  return Math.hypot(b[0] - a[0], b[1] - a[1]);
}

function pointToSegment(point, start, end) {
  const dx = end[0] - start[0];
  const dy = end[1] - start[1];
  const t = Math.max(0, Math.min(1, ((point[0] - start[0]) * dx + (point[1] - start[1]) * dy) / (dx * dx + dy * dy)));
  return Math.hypot(point[0] - (start[0] + dx * t), point[1] - (start[1] + dy * t));
}

// The float's four corners in ring order, as [{id, point}], from the frozen
// closed outline: the vertices where it turns by more than CORNER_TURN_DEGREES.
function floatCorners(rawOsm, floatWay) {
  const ids = floatWay.node_refs.slice(0, -1);
  invariant(floatWay.node_refs[0] === floatWay.node_refs.at(-1) && ids.length >= 4, "The ferry float outline is not a closed ring");
  const points = ids.map((id) => nodePoint(rawOsm, id, FERRY_TERMINAL_SOURCE_KEYS.float));
  const corners = [];
  for (let index = 0; index < points.length; index += 1) {
    const before = points[(index + points.length - 1) % points.length];
    const here = points[index];
    const after = points[(index + 1) % points.length];
    const a = Math.atan2(here[1] - before[1], here[0] - before[0]);
    const b = Math.atan2(after[1] - here[1], after[0] - here[0]);
    const turn = Math.abs(((b - a + 3 * Math.PI) % (2 * Math.PI)) - Math.PI);
    if (turn > (CORNER_TURN_DEGREES * Math.PI) / 180) corners.push({ id: ids[index], point: here, index });
  }
  invariant(corners.length === 4, `The ferry float outline has ${corners.length} corners, not 4`);
  return { corners, ids, points };
}

// The ring's nodes from corner a to corner b (inclusive), following ring order.
function edgeNodes(ids, a, b) {
  const nodes = [];
  for (let index = a.index; ; index = (index + 1) % ids.length) {
    nodes.push(ids[index]);
    if (index === b.index) return nodes;
  }
}

// One way's area: its centre and the mean distance from it to the outline.
function roundFootprint(rawOsm, sourceKey) {
  const dolphin = way(rawOsm, sourceKey);
  invariant(
    dolphin.tags.man_made === "pier" && dolphin.tags["seamark:type"] === "mooring" &&
      dolphin.tags["seamark:mooring:category"] === "dolphin" && dolphin.node_refs[0] === dolphin.node_refs.at(-1),
    `${sourceKey} is not a frozen closed mooring dolphin`,
  );
  const points = dolphin.node_refs.slice(0, -1).map((id) => nodePoint(rawOsm, id, sourceKey));
  const center = [
    points.reduce((sum, point) => sum + point[0], 0) / points.length,
    points.reduce((sum, point) => sum + point[1], 0) / points.length,
  ];
  const radius = points.reduce((sum, point) => sum + distance(point, center), 0) / points.length;
  invariant(radius >= DOLPHIN_RADIUS_RANGE_M[0] && radius <= DOLPHIN_RADIUS_RANGE_M[1], `${sourceKey} radius ${radius} m is not a dolphin's`);
  return { source_key: sourceKey, center_xz: world(center), radius_m: roundCoordinate(radius) };
}

// The context.json ferry_terminal section: the float as its two long sides
// (each [landing end, far end]; berth_side holds the ferry stop), the gangway
// from the pier end down to the float's landing end, the dolphins, the stop, and
// the straight breakwater in the water NW of the float, wholly off the island.
export function ferryTerminalDocument(rawOsm, rawSources, boundary, waterY) {
  const keys = FERRY_TERMINAL_SOURCE_KEYS;
  const floatWay = way(rawOsm, keys.float);
  invariant(
    floatWay.tags.man_made === "pier" && floatWay.tags.floating === "yes" && floatWay.tags.public_transport === "platform" &&
      floatWay.tags.name === "Treasure Island Ferry Terminal",
    `${keys.float} is not the frozen floating terminal platform`,
  );
  invariant(
    multiPolygonArea(intersectMultiPolygons(rawWayFootprint(rawOsm, keys.float.slice(1)), boundary)) <= 1e-8,
    "The ferry float unexpectedly enters the exact island boundary",
  );
  const gangway = way(rawOsm, keys.gangway);
  invariant(gangway.tags.man_made === "pier" && gangway.node_refs.length === 2, `${keys.gangway} is not the frozen two-node gangway`);
  const pier = way(rawOsm, keys.pier);
  invariant(pier.tags.man_made === "pier" && pier.tags.area === "yes", `${keys.pier} is not the frozen landing pier`);
  const [topId, bottomId] = gangway.node_refs;
  invariant(pier.node_refs.includes(topId), "The gangway does not start on the landing pier");
  invariant(floatWay.node_refs.includes(bottomId), "The gangway does not land on the float");
  const stopId = keys.stop.slice(1);
  const stopNode = rawOsm.nodes.get(stopId);
  // The raw parser leaves node tags out; the source ledger has the stop's.
  const stopTags = rawSources.get(keys.stop)?.metadata.tags;
  invariant(
    stopNode && stopTags?.amenity === "ferry_terminal" && floatWay.node_refs.includes(stopId),
    `${keys.stop} is not the frozen ferry stop on the floating terminal platform`,
  );

  const { corners, ids } = floatCorners(rawOsm, floatWay);
  const top = nodePoint(rawOsm, topId, keys.gangway);
  const bottom = nodePoint(rawOsm, bottomId, keys.gangway);
  const stop = projectLonLat(stopNode.coordinate);
  const edges = corners.map((corner, index) => {
    const next = corners[(index + 1) % corners.length];
    return { from: corner, to: next, nodes: edgeNodes(ids, corner, next) };
  });
  const landing = edges.filter((edge) => edge.nodes.includes(bottomId));
  invariant(landing.length === 1, "The gangway's landing node is not on exactly one float side");
  const landingIndex = edges.indexOf(landing[0]);
  const sideA = edges[(landingIndex + 1) % 4];
  const sideB = edges[(landingIndex + 3) % 4];
  const berth = [sideA, sideB].filter((edge) => edge.nodes.includes(stopId));
  invariant(berth.length === 1, "The ferry stop is not on exactly one long side of the float");
  const berthEdge = berth[0];
  const otherEdge = berthEdge === sideA ? sideB : sideA;
  // Each long side from its landing-end corner to its far-end corner.
  const fromLanding = (edge) => (landing[0].nodes.includes(edge.from.id) ? [edge.from.point, edge.to.point] : [edge.to.point, edge.from.point]);
  const berthSide = fromLanding(berthEdge);
  const farSide = fromLanding(otherEdge);
  const length = (distance(berthSide[0], berthSide[1]) + distance(farSide[0], farSide[1])) / 2;
  const width = (distance(berthSide[0], farSide[0]) + distance(berthSide[1], farSide[1])) / 2;
  invariant(length >= FLOAT_LENGTH_RANGE_M[0] && length <= FLOAT_LENGTH_RANGE_M[1], `Ferry float length ${length} m is out of range`);
  invariant(width >= FLOAT_WIDTH_RANGE_M[0] && width <= FLOAT_WIDTH_RANGE_M[1], `Ferry float width ${width} m is out of range`);
  invariant(pointToSegment(stop, berthSide[0], berthSide[1]) <= 0.01, "The ferry stop is off its float side");
  const gangwayLength = distance(top, bottom);
  invariant(
    gangwayLength >= GANGWAY_LENGTH_RANGE_M[0] && gangwayLength <= GANGWAY_LENGTH_RANGE_M[1],
    `Gangway length ${gangwayLength} m is out of range`,
  );
  // The pier's water-end side the gangway hangs from: the pier outline's edge
  // through the gangway's top node.
  const pierRing = pier.node_refs.slice(0, -1);
  const topIndex = pierRing.indexOf(topId);
  const pierEnd = [pierRing[(topIndex + pierRing.length - 1) % pierRing.length], pierRing[(topIndex + 1) % pierRing.length]]
    .map((id) => nodePoint(rawOsm, id, keys.pier));
  invariant(pointToSegment(top, pierEnd[0], pierEnd[1]) <= 0.05, "The gangway's top node is not on the pier's water end");
  const breakwater = way(rawOsm, keys.breakwater);
  invariant(breakwater.tags.man_made === "breakwater" && breakwater.node_refs.length === 2, `${keys.breakwater} is not the frozen two-node breakwater`);
  const breakwaterLine = breakwater.node_refs.map((id) => nodePoint(rawOsm, id, keys.breakwater));
  const breakwaterLength = distance(breakwaterLine[0], breakwaterLine[1]);
  invariant(
    breakwaterLength >= BREAKWATER_LENGTH_RANGE_M[0] && breakwaterLength <= BREAKWATER_LENGTH_RANGE_M[1],
    `Breakwater length ${breakwaterLength} m is out of range`,
  );
  invariant(
    multiPolygonArea(intersectMultiPolygons(rawWayFootprint(rawOsm, keys.breakwater.slice(1), 2), boundary)) <= 1e-8,
    "The breakwater unexpectedly reaches the exact island boundary",
  );
  const document = {
    water_y_m: waterY,
    breakwater: { source_key: keys.breakwater, line_xz: breakwaterLine.map(world) },
    float: {
      source_key: keys.float,
      berth_side_xz: berthSide.map(world),
      far_side_xz: farSide.map(world),
    },
    gangway: {
      source_key: keys.gangway,
      pier_source_key: keys.pier,
      top_xz: world(top),
      bottom_xz: world(bottom),
      pier_end_xz: pierEnd.map(world),
    },
    dolphins: keys.dolphins.map((sourceKey) => roundFootprint(rawOsm, sourceKey)),
    stop: { source_key: keys.stop, xz: world(stop) },
  };
  validateFerryTerminal(document);
  return document;
}

function isPoint(value) {
  return Array.isArray(value) && value.length === 2 && value.every((number) => typeof number === "number" && Number.isFinite(number));
}

// The section's shape and sources, for the generator and tools/validate_godot_world.mjs.
export function validateFerryTerminal(document) {
  const keys = FERRY_TERMINAL_SOURCE_KEYS;
  invariant(document && typeof document === "object", "Ferry terminal section is missing");
  invariant(
    JSON.stringify(Object.keys(document).sort()) === JSON.stringify(["breakwater", "dolphins", "float", "gangway", "stop", "water_y_m"]),
    "Ferry terminal section has missing or unknown fields",
  );
  invariant(typeof document.water_y_m === "number" && Number.isFinite(document.water_y_m), "Ferry terminal water level is not a number");
  const float = document.float;
  invariant(
    float?.source_key === keys.float && Array.isArray(float.berth_side_xz) && float.berth_side_xz.length === 2 &&
      Array.isArray(float.far_side_xz) && float.far_side_xz.length === 2 && [...float.berth_side_xz, ...float.far_side_xz].every(isPoint),
    "Ferry float sides are malformed",
  );
  const gangway = document.gangway;
  invariant(
    gangway?.source_key === keys.gangway && gangway.pier_source_key === keys.pier && isPoint(gangway.top_xz) && isPoint(gangway.bottom_xz) &&
      Array.isArray(gangway.pier_end_xz) && gangway.pier_end_xz.length === 2 && gangway.pier_end_xz.every(isPoint),
    "Ferry gangway is malformed",
  );
  invariant(
    Array.isArray(document.dolphins) && document.dolphins.length === keys.dolphins.length &&
      document.dolphins.every((dolphin, index) => dolphin.source_key === keys.dolphins[index] && isPoint(dolphin.center_xz) &&
        typeof dolphin.radius_m === "number" && dolphin.radius_m >= DOLPHIN_RADIUS_RANGE_M[0] && dolphin.radius_m <= DOLPHIN_RADIUS_RANGE_M[1]),
    "Ferry mooring dolphins are malformed",
  );
  invariant(document.stop?.source_key === keys.stop && isPoint(document.stop.xz), "Ferry stop is malformed");
  invariant(
    document.breakwater?.source_key === keys.breakwater && Array.isArray(document.breakwater.line_xz) &&
      document.breakwater.line_xz.length === 2 && document.breakwater.line_xz.every(isPoint),
    "Breakwater is malformed",
  );
}
