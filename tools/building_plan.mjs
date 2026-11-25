#!/usr/bin/env node
// Draws a building's plan from the frozen map data and the generated world, for
// the describe step and the owner's sheets (tools/building-plan; README "Plan
// view of a building"):
//
//   node tools/building_plan.mjs <source-key> [--out DIR]
//
// <source-key> is a way or relation id as the catalog uses it (w24274434,
// r16681702). It writes plan.svg, plan.png (when ImageMagick's `magick` is on
// PATH) and plan.md into DIR, by default <worktree parent>/building-plans/<key>/,
// and refuses a DIR inside this repository. It reads the frozen OSM snapshot
// (the file the world generator reads), generated/world's record and roof mesh
// for the building, the facade catalog's passages and stairs, and any recorded
// osm_exception outline (an approved departure from the map footprint); it
// writes nothing else. The same sources give the same files.
import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, readdirSync, realpathSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { basename, dirname, join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";
import polygonClipping from "polygon-clipping";

import { projectLonLat } from "./lib/coordinates.mjs";
import { parseRawOsmXml, pointInRing } from "./lib/osm-geometry.mjs";
import { GENERATOR_VERSION, ROAD_WIDTHS_M, SOURCE_CONTRACT } from "./lib/world-contract.mjs";
import {
  ON_LINE_M,
  arcTolerance,
  bearingOf,
  bounds,
  distanceToSegments,
  dropClosingPoint,
  fitConcentric,
  inscribedCircle,
  lineSegments,
  orientRing,
  pointInShape,
  principalRectangle,
  ringArea,
  ringPerimeter,
  ringRuns,
  ringSegments,
  sampleBoundary,
  selfIntersections,
  shapeArea,
  shapeRings,
  stretches,
} from "./lib/plan-geometry.mjs";
import { clipLine, clipRing, textWidth, toMvg, toSvg, wrapText } from "./lib/plan-drawing.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const NEIGHBOUR_M = 15; // context drawn and listed round the building
const THIN_STRIP_M = 6; // a member narrower than this is a strip
const ALONG_M = 1; // a member edge this close to another member's lies along it
const DEPARTURE_M = 1; // the generated outline differing more than this from the largest member is flagged
const SHORT_RUN_M = 1.5; // an outline step shorter than this is flagged
const LEVEL_M = 0.3; // arcs about one centre within this of each other stand at one radius
const SAMPLE_M = 0.1;
const OUTER_ROLES = new Set(["outer", "way", "outline", "outer (joined)", "outline (joined)"]);
// Tags that describe a built form (an inner ring without them is a courtyard).
const FORM_TAG_KEYS = [
  "building", "building:part", "height", "min_height", "building:levels", "building:min_level",
  "roof:shape", "roof:levels", "roof:height", "layer", "level", "location", "covered", "man_made", "amenity",
];
const isInner = (member) => member.role.startsWith("inner");
const isPart = (member) => member.role.startsWith("building:part") || member.role.startsWith("part");
const roleFamily = (member) => (isInner(member) ? "inner" : isPart(member) ? "part" : "outer");

// Tags that say a member is raised, roofed or apart from the ground-floor walls.
function raisedOrRoofTags(tags) {
  return [
    ["building", ["roof", "canopy", "carport", "shelter", "bridge", "balcony"]],
    ["building:part", ["roof", "canopy", "balcony", "bridge", "porch"]],
    ["man_made", ["canopy", "tower"]],
    ["amenity", ["shelter"]],
    ["covered", ["yes", "arcade", "colonnade"]],
  ].filter(([key, values]) => values.includes(tags[key]))
    .map(([key]) => `${key}=${tags[key]}`)
    .concat(["min_height", "building:min_level", "location", "layer", "roof:shape", "roof:levels", "roof:height"]
      .filter((key) => tags[key] != null)
      .map((key) => `${key}=${tags[key]}`));
}

class UsageError extends Error {}

const USAGE = `Usage: tools/building-plan <source-key> [--out DIR]

Draws the plan of one building from the frozen map data: each map member
labelled with its role and tags, the outline the world generator uses on top,
neighbours, roads and areas within ${NEIGHBOUR_M} m, the catalog's passages and
stairs, a north arrow, scale bar and 1 m ticks (plan.svg, and plan.png when
ImageMagick's magick is on PATH), with its measures and flags in plan.md.

  <source-key>  a way or relation id as in the facade catalog (w24274434, r16681702)
  --out DIR     where to write (default: <worktree parent>/building-plans/<key>);
                never inside this repository`;

function parseArguments(argv) {
  const options = { key: null, out: null };
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--help" || argument === "-h") return { help: true };
    if (argument === "--out") {
      options.out = argv[index + 1];
      index += 1;
      if (!options.out) throw new UsageError("--out needs a directory");
    } else if (argument.startsWith("--out=")) {
      options.out = argument.slice("--out=".length);
      if (!options.out) throw new UsageError("--out needs a directory");
    } else if (argument.startsWith("-")) {
      throw new UsageError(`unknown option ${argument}`);
    } else if (options.key == null) {
      options.key = argument;
    } else {
      throw new UsageError(`one source key only (got ${options.key} and ${argument})`);
    }
  }
  if (options.key == null) throw new UsageError("a source key is required");
  if (!/^[wr][1-9][0-9]*$/u.test(options.key)) {
    throw new UsageError(`${options.key} is not a way or relation source key (w<id> or r<id>)`);
  }
  return options;
}

function outputDirectory(requested, key) {
  const out = resolve(requested ?? join(projectRoot, "..", "building-plans", key));
  let probe = out;
  const rest = [];
  while (!existsSync(probe)) {
    rest.unshift(basename(probe));
    probe = dirname(probe);
  }
  const real = join(realpathSync(probe), ...rest);
  const repository = realpathSync(projectRoot);
  if (real === repository || real.startsWith(repository + sep)) {
    throw new UsageError(`--out ${out} lies inside the repository (${repository}); plans are written outside Git`);
  }
  return out;
}

// --- Map data ---------------------------------------------------------------

function toPlan(lonLat) {
  const [east, north] = projectLonLat(lonLat);
  return [east, -north];
}

function decode(value) {
  return value.replaceAll("&quot;", '"').replaceAll("&apos;", "'").replaceAll("&lt;", "<")
    .replaceAll("&gt;", ">").replaceAll("&amp;", "&")
    .replace(/&#(\d+);/gu, (_match, digits) => String.fromCodePoint(Number(digits)))
    .replace(/&#x([0-9a-f]+);/giu, (_match, digits) => String.fromCodePoint(Number.parseInt(digits, 16)));
}

// Tags of tagged nodes, which the shared raw parser leaves out. A self-closing
// <node .../> has no tags and must not reach the next node's </node>.
function nodeTags(xml) {
  const tags = new Map();
  for (const match of xml.matchAll(/<node\b([^>]*[^/>])>([\s\S]*?)<\/node>/gu)) {
    const id = /\bid="(\d+)"/u.exec(match[1])?.[1];
    if (!id) continue;
    const entries = [...match[2].matchAll(/<tag\b[^>]*\bk="([^"]*)"[^>]*\bv="([^"]*)"[^>]*\/>/gu)]
      .map((tag) => [decode(tag[1]), decode(tag[2])]);
    if (entries.length > 0) tags.set(id, Object.fromEntries(entries.sort(([a], [b]) => a.localeCompare(b))));
  }
  return tags;
}

function wayGeometry(osm, wayId) {
  const way = osm.ways.get(wayId);
  if (!way) return null;
  const points = [];
  for (const ref of way.node_refs) {
    const node = osm.nodes.get(ref);
    if (!node) return null;
    points.push(toPlan(node.coordinate));
  }
  const closed = way.node_refs.length >= 4 && way.node_refs[0] === way.node_refs.at(-1);
  return { way, points, closed, ring: closed ? orientRing(dropClosingPoint(points)) : null };
}

// Joins open member ways of one role end to end into closed rings.
function joinOpenWays(pieces) {
  const rings = [];
  const left = pieces.map((piece) => ({ refs: [...piece.way.node_refs], points: [...piece.points] }));
  while (left.length > 0) {
    const current = left.shift();
    let grown = true;
    while (grown && current.refs[0] !== current.refs.at(-1)) {
      grown = false;
      for (let index = 0; index < left.length; index += 1) {
        const piece = left[index];
        if (piece.refs[0] === current.refs.at(-1)) {
          current.refs.push(...piece.refs.slice(1));
          current.points.push(...piece.points.slice(1));
        } else if (piece.refs.at(-1) === current.refs.at(-1)) {
          current.refs.push(...[...piece.refs].reverse().slice(1));
          current.points.push(...[...piece.points].reverse().slice(1));
        } else {
          continue;
        }
        left.splice(index, 1);
        grown = true;
        break;
      }
    }
    if (current.refs[0] === current.refs.at(-1) && current.refs.length >= 4) rings.push(orientRing(dropClosingPoint(current.points)));
  }
  return rings;
}

// --- Polygon helpers (polygon-clipping takes closed rings) ------------------

const closeRing = (ring) => [...ring, ring[0]];
const toClip = (shape) => shape.map((polygon) => [closeRing(polygon.outer), ...polygon.holes.map(closeRing)]);
const ringShape = (ring) => [{ outer: ring, holes: [] }];

function fromClip(multiPolygon) {
  return multiPolygon.map((polygon) => ({
    outer: orientRing(dropClosingPoint(polygon[0]), true),
    holes: polygon.slice(1).map((ring) => orientRing(dropClosingPoint(ring), false)),
  })).filter((polygon) => polygon.outer.length >= 3);
}

function clipped(operation, ...shapes) {
  try {
    return fromClip(polygonClipping[operation](...shapes.map(toClip)));
  } catch {
    return null;
  }
}

function clippedArea(operation, ...shapes) {
  const result = clipped(operation, ...shapes);
  return result ? shapeArea(result) : null;
}

// --- The generated outline: the roof mesh's boundary ------------------------

function meshRings(record) {
  const { vertices, indices } = record;
  const counts = new Map();
  for (let index = 0; index < indices.length; index += 3) {
    const triangle = [indices[index], indices[index + 1], indices[index + 2]];
    for (let corner = 0; corner < 3; corner += 1) {
      const a = triangle[corner];
      const b = triangle[(corner + 1) % 3];
      const key = a < b ? `${a},${b}` : `${b},${a}`;
      counts.set(key, (counts.get(key) ?? 0) + 1);
    }
  }
  const neighbours = new Map();
  for (const [key, count] of counts) {
    if (count !== 1) continue;
    const [a, b] = key.split(",").map(Number);
    if (!neighbours.has(a)) neighbours.set(a, []);
    if (!neighbours.has(b)) neighbours.set(b, []);
    neighbours.get(a).push(b);
    neighbours.get(b).push(a);
  }
  const visited = new Set();
  const rings = [];
  for (const start of [...neighbours.keys()].sort((a, b) => a - b)) {
    if (visited.has(start)) continue;
    const ring = [];
    let previous = -1;
    let current = start;
    for (;;) {
      if (neighbours.get(current).length !== 2) throw new Error(`${record.object_key}: the roof mesh's boundary branches at vertex ${current}`);
      ring.push([vertices[current * 3], vertices[current * 3 + 2]]);
      visited.add(current);
      const next = neighbours.get(current).find((candidate) => candidate !== previous);
      previous = current;
      current = next;
      if (current === start) break;
      if (visited.has(current)) throw new Error(`${record.object_key}: the roof mesh's boundary does not close`);
    }
    rings.push(ring);
  }
  // Even nesting depth is an outline, odd a hole.
  const inside = (ring, other) => ring.filter((point) => pointInRing(point, other)).length * 2 > ring.length;
  const depth = (ring) => rings.filter((other) => other !== ring && inside(ring, other)).length;
  return rings.filter((ring) => depth(ring) % 2 === 0).map((outer) => ({
    outer: orientRing(outer, true),
    holes: rings.filter((ring) => depth(ring) === depth(outer) + 1 && inside(ring, outer)).map((ring) => orientRing(ring, false)),
  }));
}

function generatedRecord(key) {
  const logical = JSON.parse(readFileSync(join(projectRoot, "generated/world/logical-objects.json"), "utf8")).objects;
  const object = logical.find((candidate) => candidate.source_keys.includes(key) &&
    (candidate.roles.includes("building") || candidate.roles.includes("building_part")));
  if (!object) return null;
  const anchor = object.logical_object_key.endsWith(`:${key}`);
  const wanted = new Set(object.physical_object_keys.filter((physical) => physical.endsWith(":roof")));
  const roofs = [];
  for (const chunkId of [...object.chunk_ids].sort()) {
    const chunk = JSON.parse(readFileSync(join(projectRoot, "generated/world/chunks", `${chunkId}.json`), "utf8"));
    for (const record of chunk.records) {
      if (wanted.has(record.object_key) && (anchor || record.source_keys.includes(key))) roofs.push(record);
    }
  }
  roofs.sort((a, b) => a.object_key.localeCompare(b.object_key));
  let shape = null;
  if (roofs.length === 1) shape = meshRings(roofs[0]);
  else if (roofs.length > 1) shape = clipped("union", ...roofs.map(meshRings));
  const measure = object.source_geometry.find((entry) => entry.source_key === key)?.clipped_measure ?? null;
  return {
    object,
    roofs: roofs.map((roof) => ({ key: roof.object_key, base: roof.flat_base_elevation_m, top: roof.top_elevation_m, height: roof.source_height_m })),
    shape,
    measure,
  };
}

// --- Catalog and approved departures ----------------------------------------

function catalogUnit(key) {
  const catalog = JSON.parse(readFileSync(join(projectRoot, "discovery/facades/facade-recognition-catalog.json"), "utf8"));
  return catalog.units.find((unit) => unit.anchor_source_key === key) ??
    catalog.units.find((unit) => unit.source_records.some((record) => record.source_key === key)) ?? null;
}

function filesNamed(directory, name) {
  const found = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) found.push(...filesNamed(path, name));
    else if (entry.name === name) found.push(path);
  }
  return found.sort();
}

// Every osm_exception with an outline_xz recorded for the building: in its
// catalog unit, or in a game/resources config named after its source key.
function approvedDepartures(key, unit) {
  const found = [];
  const visit = (value, path, file) => {
    if (Array.isArray(value)) {
      value.forEach((item, index) => visit(item, `${path}[${index}]`, file));
    } else if (value && typeof value === "object") {
      const exception = value.osm_exception;
      if (exception && Array.isArray(exception.outline_xz) && exception.outline_xz.length >= 3) {
        found.push({
          file,
          path: `${path}.osm_exception`,
          approved: exception.approved,
          ring: orientRing(exception.outline_xz.map(([x, z]) => [Number(x), Number(z)])),
        });
      }
      for (const [name, child] of Object.entries(value)) if (name !== "osm_exception") visit(child, `${path}.${name}`, file);
    }
  };
  if (unit) visit(unit, "unit", "discovery/facades/facade-recognition-catalog.json");
  for (const file of filesNamed(join(projectRoot, "game/resources"), `${key}.json`)) {
    visit(JSON.parse(readFileSync(file, "utf8")), "", relative(projectRoot, file));
  }
  return found;
}

// --- Measures ---------------------------------------------------------------

function ringMeasures(ring) {
  const circle = inscribedCircle(ring);
  return {
    area: ringArea(ring),
    perimeter: ringPerimeter(ring),
    rectangle: principalRectangle(ring),
    width: 2 * circle.radius,
    widthAt: circle.centre,
    runs: ringRuns(ring),
    crossings: selfIntersections(ring),
  };
}

function shapeMeasures(shape) {
  const outerPoints = shape.flatMap((polygon) => polygon.outer);
  return {
    area: shapeArea(shape),
    perimeter: shapeRings(shape).reduce((sum, ring) => sum + ringPerimeter(ring), 0),
    rectangle: principalRectangle(outerPoints),
    box: bounds(outerPoints),
    rings: shape.flatMap((polygon, polygonIndex) => [
      { label: shape.length > 1 ? `outline ${polygonIndex + 1}` : "outline", ring: polygon.outer, hole: false },
      ...polygon.holes.map((hole, holeIndex) => ({ label: `hole ${holeIndex + 1}${shape.length > 1 ? ` of outline ${polygonIndex + 1}` : ""}`, ring: hole, hole: true })),
    ]).map((entry) => ({ ...entry, runs: ringRuns(entry.ring), crossings: selfIntersections(entry.ring) })),
  };
}

function segmentDistance(a, b, c, d) {
  const cross = (o, p, q) => (p[0] - o[0]) * (q[1] - o[1]) - (p[1] - o[1]) * (q[0] - o[0]);
  const d1 = cross(c, d, a);
  const d2 = cross(c, d, b);
  const d3 = cross(a, b, c);
  const d4 = cross(a, b, d);
  if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) return 0;
  return Math.min(
    distanceToSegments(a, [[c, d]]), distanceToSegments(b, [[c, d]]),
    distanceToSegments(c, [[a, b]]), distanceToSegments(d, [[a, b]]),
  );
}

function gap(segmentsA, segmentsB) {
  let best = Infinity;
  for (const [a, b] of segmentsA) {
    for (const [c, d] of segmentsB) {
      const distance = segmentDistance(a, b, c, d);
      if (distance < best) best = distance;
      if (best === 0) return 0;
    }
  }
  return best;
}

function lengthNear(ring, segments, within) {
  let length = 0;
  for (const sample of sampleBoundary(ring, SAMPLE_M)) if (distanceToSegments(sample.point, segments) <= within) length += sample.weight;
  return length;
}

// Arcs of the members and the generated outline that share a centre. Long arcs
// (60 degrees or more) set the centres; a shorter arc joins a centre when its
// vertices lie within the arc tolerance of one distance from it, so a short
// stretch of a long curve is measured about the curve's own centre. Within a
// group, arcs at one distance (within LEVEL_M) form a level.
function arcGroups(closedMembers, generatedMeasures) {
  const arcs = [];
  for (const member of closedMembers) {
    for (const run of member.runs) if (run.kind === "arc") arcs.push({ owner: `${member.letter} ${member.key}`, colour: member.colour, generated: false, run });
  }
  for (const entry of generatedMeasures?.rings ?? []) {
    for (const run of entry.runs) if (run.kind === "arc") arcs.push({ owner: `generated ${entry.label}`, generated: true, run });
  }
  const about = (arc, centre) => {
    const radii = arc.run.points.map((point) => Math.hypot(point[0] - centre[0], point[1] - centre[1]));
    return { mean: radii.reduce((sum, value) => sum + value, 0) / radii.length, min: Math.min(...radii), max: Math.max(...radii) };
  };
  const groups = [];
  const alone = [];
  for (const arc of [...arcs].sort((a, b) => b.run.span - a.run.span || b.run.points.length - a.run.points.length)) {
    let home = null;
    for (const group of groups) {
      const distances = about(arc, group.centre);
      if (distances.max - distances.min <= 2 * arcTolerance(distances.mean)) {
        home = group;
        arc.about = distances;
        break;
      }
    }
    if (home == null && arc.run.span >= 60) {
      home = { centre: arc.run.centre, arcs: [] };
      groups.push(home);
      arc.about = about(arc, home.centre);
    }
    if (home) home.arcs.push(arc);
    else alone.push(arc);
  }
  for (const group of groups) {
    group.arcs.sort((a, b) => b.about.mean - a.about.mean || Number(a.generated) - Number(b.generated) || a.owner.localeCompare(b.owner));
    group.levels = [];
    for (const arc of group.arcs) {
      const level = group.levels.at(-1);
      if (level && level.arcs.at(-1).about.mean - arc.about.mean <= LEVEL_M) level.arcs.push(arc);
      else group.levels.push({ arcs: [arc] });
    }
    // One centre for all levels: a joint fit over each level's distinct
    // vertices (the members' where a member has an arc there).
    const pointSets = group.levels.map((level) => {
      const memberArcs = level.arcs.filter((arc) => !arc.generated);
      const seen = new Set();
      const points = [];
      for (const arc of memberArcs.length ? memberArcs : level.arcs) {
        for (const point of arc.run.points) {
          const pointKey = `${point[0]},${point[1]}`;
          if (!seen.has(pointKey)) {
            seen.add(pointKey);
            points.push(point);
          }
        }
      }
      return points;
    });
    const joint = fitConcentric(pointSets, group.centre);
    group.centre = joint.centre;
    for (const arc of group.arcs) arc.about = about(arc, group.centre);
    group.levels.forEach((level, index) => {
      level.radius = joint.radii[index];
      level.fit = joint.errors[index];
      level.min = Math.min(...level.arcs.map((arc) => arc.about.min));
      level.max = Math.max(...level.arcs.map((arc) => arc.about.max));
      // The longest member arc names the level (a generated arc where no member has one).
      level.longest = [...level.arcs].sort((a, b) => Number(a.generated) - Number(b.generated) || b.run.span - a.run.span)[0];
    });
  }
  return { groups, alone };
}

// --- Formatting -------------------------------------------------------------

const f1 = (value) => (Math.abs(value) < 0.05 ? 0 : value).toFixed(1);
const f2 = (value) => (Math.abs(value) < 0.005 ? 0 : value).toFixed(2);
const f3 = (value) => value.toFixed(3);
const xz = (point) => `(${f2(point[0])}, ${f2(point[1])})`;
const deg = (value) => `${((Math.round(value * 10) / 10) % 360).toFixed(1)}°`;
const LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

function tagText(tags, keys = null) {
  const entries = Object.entries(tags).filter(([key]) => keys == null || keys.includes(key));
  return entries.length ? entries.map(([key, value]) => `${key}=${value}`).join(", ") : "untagged";
}

function runText(run) {
  if (run.kind === "arc") {
    return `arc R ${f2(run.radius)} about ${xz(run.centre)}, ${f1(run.span)}° span, ${run.concave ? "concave" : "convex"}; fit error rms ${f3(run.fit_rms)} m, max ${f3(run.fit_max)} m`;
  }
  return `straight, heading ${deg(run.bearing)}${run.deviation >= 0.05 ? `, vertices up to ${f2(run.deviation)} m off the chord` : ""}`;
}

// --- Analysis ---------------------------------------------------------------

function analyse(key) {
  const osmPath = join(projectRoot, SOURCE_CONTRACT.raw_osm.path);
  const osm = parseRawOsmXml(osmPath);
  const tagsOfNodes = nodeTags(readFileSync(osmPath, "utf8"));
  const id = key.slice(1);
  const target = key[0] === "w" ? osm.ways.get(id) : osm.relations.get(id);
  if (!target) throw new UsageError(`${key} is not in the frozen map snapshot (${SOURCE_CONTRACT.raw_osm.path})`);
  if (target.tags.building == null && target.tags["building:part"] == null) {
    throw new UsageError(`${key} is not a building in the frozen map snapshot: it has no building or building:part tag`);
  }

  // Members: the way itself, or the relation's members in order.
  const members = [];
  const notes = [];
  if (key[0] === "w") {
    members.push({ key, role: "way", tags: target.tags, ...wayGeometry(osm, id) });
  } else {
    for (const member of target.members) {
      const role = member.role || "(no role)";
      if (member.type === "way") {
        const geometry = wayGeometry(osm, member.ref);
        if (geometry == null) notes.push(`member w${member.ref} (${role}) is missing from the snapshot or lacks nodes`);
        else members.push({ key: `w${member.ref}`, role, tags: geometry.way.tags, ...geometry });
      } else if (member.type === "node") {
        const node = osm.nodes.get(member.ref);
        if (node) members.push({ key: `n${member.ref}`, role, tags: tagsOfNodes.get(member.ref) ?? {}, point: toPlan(node.coordinate) });
      } else {
        notes.push(`member r${member.ref} (${role}) is a relation; it is listed, not drawn`);
      }
    }
    for (const role of ["outer", "inner", "outline", "part"]) {
      const open = members.filter((member) => member.role === role && member.points && !member.closed);
      if (open.length === 0) continue;
      const rings = joinOpenWays(open);
      notes.push(`${open.length} open ${role} member way(s) join into ${rings.length} closed ring(s)`);
      rings.forEach((ring, index) => members.push({ key: `${role} ring ${index + 1}`, role: `${role} (joined)`, tags: {}, ring, points: closeRing(ring), closed: true }));
    }
  }
  const memberWayIds = new Set(members.filter((member) => member.way).map((member) => member.way.id));
  const generated = generatedRecord(key);
  const unit = catalogUnit(key);
  const departures = approvedDepartures(key, unit);

  // The map's own footprint (outer rings less inner ones) stands in for a
  // missing generated outline.
  const outerRings = members.filter((member) => member.ring && OUTER_ROLES.has(member.role)).map((member) => member.ring);
  const innerRings = members.filter((member) => member.ring && isInner(member)).map((member) => member.ring);
  let mapShape = outerRings.length ? clipped("union", ...outerRings.map(ringShape)) : null;
  if (mapShape && innerRings.length) mapShape = clipped("difference", mapShape, ...innerRings.map(ringShape)) ?? mapShape;
  const footprint = generated?.shape?.length ? generated.shape : mapShape ?? [];

  // building:part ways standing at least half inside the footprint.
  if (footprint.length) {
    for (const [wayId, way] of [...osm.ways].sort(([a], [b]) => Number(a) - Number(b))) {
      if (way.tags["building:part"] == null || wayId === id || memberWayIds.has(wayId)) continue;
      const geometry = wayGeometry(osm, wayId);
      if (!geometry?.ring) continue;
      const inside = clippedArea("intersection", ringShape(geometry.ring), footprint);
      if (inside != null && inside * 2 >= ringArea(geometry.ring)) {
        members.push({ key: `w${wayId}`, role: "building:part inside", tags: way.tags, ...geometry });
        memberWayIds.add(wayId);
      }
    }
  }
  members.forEach((member, index) => {
    member.letter = LETTERS[index] ?? `#${index + 1}`;
  });
  for (const member of members) if (member.ring) Object.assign(member, ringMeasures(member.ring));
  const closedMembers = members.filter((member) => member.ring);
  const counters = { outer: 0, inner: 0, part: 0 };
  for (const member of members) {
    const list = PALETTE[roleFamily(member)];
    member.colour = list[counters[roleFamily(member)] % list.length];
    counters[roleFamily(member)] += 1;
  }

  // Tagged nodes on the member ways (entrances, addresses, others).
  const nodes = [];
  const seenNodes = new Set();
  for (const member of members) {
    if (!member.way) continue;
    for (const ref of member.way.node_refs) {
      if (seenNodes.has(ref) || !tagsOfNodes.has(ref)) continue;
      seenNodes.add(ref);
      nodes.push({ id: `n${ref}`, member: member.letter, point: toPlan(osm.nodes.get(ref).coordinate), tags: tagsOfNodes.get(ref) });
    }
  }

  const generatedMeasures = generated?.shape?.length ? shapeMeasures(generated.shape) : null;
  const generatedSegments = generatedMeasures ? ringSegments(shapeRings(generated.shape)) : [];
  const generatedOuter = generatedMeasures ? generated.shape.map((polygon) => ({ outer: polygon.outer, holes: [] })) : [];
  const generatedOuterSegments = ringSegments(generatedOuter.map((polygon) => polygon.outer));

  // Each member's boundary and area against the generated outline.
  const comparisons = [];
  if (generatedMeasures) {
    for (const member of closedMembers) {
      const located = sampleBoundary(member.ring, SAMPLE_M).map((sample) => {
        const distance = distanceToSegments(sample.point, generatedSegments);
        const cls = distance <= ON_LINE_M ? "on" : pointInShape(sample.point, generated.shape) ? "inside" : "outside";
        return { ...sample, distance, cls };
      });
      const totals = { on: 0, inside: 0, outside: 0 };
      for (const sample of located) totals[sample.cls] += sample.weight;
      const inside = clippedArea("intersection", ringShape(member.ring), generated.shape);
      const withinOuter = clippedArea("intersection", ringShape(member.ring), generatedOuter);
      comparisons.push({
        member,
        totals,
        inside,
        inHoles: inside != null && withinOuter != null ? Math.max(0, withinOuter - inside) : null,
        outside: withinOuter != null ? Math.max(0, member.area - withinOuter) : null,
        stretches: stretches(located, (sample) => sample.cls, (sample) => sample.distance).filter((stretch) => stretch.cls !== "on" && stretch.length >= 1),
      });
    }
  }

  // Which member each part of the generated outline follows.
  const memberSegments = closedMembers.map((member) => ({ member, segments: ringSegments([member.ring]) }));
  const attribution = [];
  if (generatedMeasures) {
    for (const entry of generatedMeasures.rings) {
      const totals = new Map();
      for (const sample of sampleBoundary(entry.ring, SAMPLE_M)) {
        let follows = "no member";
        let nearest = Infinity;
        for (const { member, segments } of memberSegments) {
          const distance = distanceToSegments(sample.point, segments);
          if (distance <= ON_LINE_M && distance < nearest) {
            nearest = distance;
            follows = member.letter;
          }
        }
        totals.set(follows, (totals.get(follows) ?? 0) + sample.weight);
      }
      const sorted = [...totals].sort(([a], [b]) => a.localeCompare(b));
      const onInner = sorted.filter(([letter]) => members.find((member) => member.letter === letter && isInner(member))).reduce((sum, [, length]) => sum + length, 0);
      attribution.push({ entry, totals: sorted, matchesInner: entry.hole && onInner >= 0.9 * ringPerimeter(entry.ring) });
    }
  }

  // The generated outline against the largest outer member, both ways round
  // (outer edges only: holes have their own entries).
  const outerMembers = closedMembers.filter((member) => OUTER_ROLES.has(member.role));
  const largest = [...outerMembers].sort((a, b) => b.area - a.area)[0] ?? null;
  let departure = null;
  if (generatedMeasures && largest) {
    const largestSegments = ringSegments([largest.ring]);
    const outward = [];
    for (const polygon of generatedOuter) {
      const samples = sampleBoundary(polygon.outer, SAMPLE_M).map((sample) => ({ ...sample, distance: distanceToSegments(sample.point, largestSegments) }));
      for (const stretch of stretches(samples, (sample) => (sample.distance > DEPARTURE_M ? "away" : "near"), (sample) => sample.distance)) {
        if (stretch.cls !== "away") continue;
        const followed = memberSegments.filter(({ segments }) => distanceToSegments(stretch.at, segments) <= ON_LINE_M).map(({ member }) => member);
        outward.push({ ...stretch, followed, outside: !pointInRing(stretch.at, largest.ring) });
      }
    }
    const samples = sampleBoundary(largest.ring, SAMPLE_M).map((sample) => ({ ...sample, distance: distanceToSegments(sample.point, generatedOuterSegments) }));
    const inward = stretches(samples, (sample) => (sample.distance > DEPARTURE_M ? "away" : "near"), (sample) => sample.distance)
      .filter((stretch) => stretch.cls === "away")
      .map((stretch) => ({ ...stretch, inside: pointInShape(stretch.at, generatedOuter) }));
    departure = { largest, outward, inward };
  }

  // Pairs of members that share boundary, or overlap within one role (an inner
  // ring or a part inside its outline is expected).
  const pairs = [];
  for (let first = 0; first < closedMembers.length; first += 1) {
    for (let second = first + 1; second < closedMembers.length; second += 1) {
      const a = closedMembers[first];
      const b = closedMembers[second];
      const shared = lengthNear(a.ring, ringSegments([b.ring]), ON_LINE_M);
      const overlap = roleFamily(a) === roleFamily(b) ? clippedArea("intersection", ringShape(a.ring), ringShape(b.ring)) ?? 0 : 0;
      const sharedNodes = a.way && b.way ? a.way.node_refs.slice(0, -1).filter((ref) => b.way.node_refs.includes(ref)).length : 0;
      if (shared >= 0.5 || overlap >= 0.05 || sharedNodes >= 2) pairs.push({ a, b, shared, sharedNodes, overlap, sameRole: roleFamily(a) === roleFamily(b) });
    }
  }

  // How much of each member lies along (within ALONG_M of) another member.
  for (const member of closedMembers) {
    member.along = memberSegments.filter(({ member: other }) => other !== member)
      .map(({ member: other, segments }) => ({ other, length: lengthNear(member.ring, segments, ALONG_M) }))
      .filter((entry) => entry.length > 0);
  }

  const arcs = arcGroups(closedMembers, generatedMeasures);

  // Neighbours: buildings, roads and ground areas within NEIGHBOUR_M.
  const footprintRings = [...shapeRings(footprint), ...closedMembers.map((member) => member.ring)];
  const footprintSegments = ringSegments(footprintRings);
  const footprintBox = bounds(footprintRings.flat().concat(members.flatMap((member) => member.points ?? [])));
  const near = {
    minX: footprintBox.minX - NEIGHBOUR_M, maxX: footprintBox.maxX + NEIGHBOUR_M,
    minZ: footprintBox.minZ - NEIGHBOUR_M, maxZ: footprintBox.maxZ + NEIGHBOUR_M,
  };
  // Ground areas the generator draws (major areas and shore overlays); the
  // island, the bay and the coastline are lines here, not surfaces.
  const surfaceTag = (tags) => ["landuse", "leisure", "amenity", "area:highway", "parking"].find((tagKey) => tags[tagKey] != null) ??
    (["sand", "wetland", "scrub", "grassland", "beach"].includes(tags.natural) ? "natural" : null) ??
    (["pier", "breakwater"].includes(tags.man_made) ? "man_made" : null);
  const lineTag = (tags) => (["coastline", "water", "bay"].includes(tags.natural) ? "natural" : null);
  const neighbours = [];
  const consider = (sourceKey, tags, lines, kind) => {
    const all = lines.flat();
    if (all.length === 0) return;
    const box = bounds(all);
    if (box.maxX < near.minX || box.minX > near.maxX || box.maxZ < near.minZ || box.minZ > near.maxZ) return;
    const distance = gap(lines.flatMap((line) => lineSegments(line)), footprintSegments);
    const closedLine = lines.length === 1 && lines[0].length >= 4 && lines[0][0][0] === lines[0].at(-1)[0] && lines[0][0][1] === lines[0].at(-1)[1];
    const ring = closedLine ? dropClosingPoint(lines[0]) : null;
    const contains = kind === "area" && ring != null && footprint.length > 0 && distance > 0 && pointInRing(footprint[0].outer[0], ring);
    if (distance > NEIGHBOUR_M && !contains) return;
    const overlap = ring && kind === "building" && footprint.length ? clippedArea("intersection", ringShape(orientRing(ring)), footprint) ?? 0 : 0;
    neighbours.push({ key: sourceKey, kind, tags, lines, ring: kind === "line" ? null : ring, distance, contains, overlap });
  };
  for (const [wayId, way] of [...osm.ways].sort(([a], [b]) => Number(a) - Number(b))) {
    if (wayId === id || memberWayIds.has(wayId)) continue;
    const tags = way.tags;
    const kind = tags.building != null || tags["building:part"] != null ? "building"
      : tags.highway != null && tags.area !== "yes" ? "road"
        : surfaceTag(tags) != null ? "area"
          : lineTag(tags) != null ? "line" : null;
    if (kind == null) continue;
    const geometry = wayGeometry(osm, wayId);
    if (geometry) consider(`w${wayId}`, tags, [geometry.points], kind);
  }
  for (const [relationId, relation] of [...osm.relations].sort(([a], [b]) => Number(a) - Number(b))) {
    if (key === `r${relationId}` || relation.tags.type !== "multipolygon") continue;
    const tags = relation.tags;
    const kind = tags.building != null || tags["building:part"] != null ? "building"
      : surfaceTag(tags) != null ? "area" : lineTag(tags) != null ? "line" : null;
    if (kind == null) continue;
    const lines = relation.members.filter((member) => member.type === "way" && !memberWayIds.has(member.ref))
      .map((member) => wayGeometry(osm, member.ref)?.points).filter(Boolean);
    consider(`r${relationId}`, tags, lines, kind);
  }
  neighbours.sort((a, b) => a.distance - b.distance || a.key.localeCompare(b.key));

  // Departures recorded by the owner: how far they stand outside the outline.
  for (const record of departures) {
    record.area = ringArea(record.ring);
    record.rectangle = principalRectangle(record.ring);
    if (footprint.length) {
      record.outsideArea = clippedArea("difference", ringShape(record.ring), footprint);
      const segments = ringSegments(shapeRings(footprint));
      record.reach = Math.max(...record.ring.map((point) => (pointInShape(point, footprint) ? 0 : distanceToSegments(point, segments))));
    }
  }

  return {
    key, target, members, closedMembers, nodes, notes, generated, generatedMeasures, unit, departures,
    comparisons, attribution, departure, pairs, arcs, neighbours, footprint,
  };
}

function flagsFor(plan) {
  const flags = [];
  const { key, target, members, closedMembers, generated, generatedMeasures, departure, pairs, attribution } = plan;
  const label = (member) => `${member.letter} ${member.key}`;
  const look = "worth a look against photos";
  const outers = closedMembers.filter((member) => OUTER_ROLES.has(member.role));
  if (key[0] === "r" && outers.length > 1) {
    flags.push(`The relation has ${outers.length} outer members, which the generator joins into one outline: ${outers.map((member) => `${label(member)} ${f2(member.area)} m² (${tagText(member.tags)})`).join("; ")}.`);
  }
  for (const member of closedMembers) {
    if (member.width >= THIN_STRIP_M || closedMembers.length < 2) continue;
    const along = member.along.filter((entry) => entry.length >= Math.min(5, member.perimeter / 4));
    if (along.length === 0) continue;
    const length = Math.max(0, (member.perimeter - 2 * member.width) / 2);
    flags.push(`${label(member)} (${member.role}) is a thin strip: greatest width ${f2(member.width)} m, about ${f1(length)} m long, ${f2(member.area)} m²; it lies along ${along.map((entry) => `${label(entry.other)} for ${f1(entry.length)} m (within ${ALONG_M} m)`).join(" and ")}.`);
  }
  // Outer (or inner) members that touch or overlap; parts tile their building,
  // so only parts that overlap each other are flagged.
  for (const pair of pairs) {
    if (!pair.sameRole) continue;
    if (roleFamily(pair.a) === "part" && pair.overlap < 0.05) continue;
    flags.push(`${label(pair.a)} and ${label(pair.b)} share ${f1(pair.shared)} m of boundary${pair.sharedNodes ? ` (${pair.sharedNodes} shared nodes)` : ""} and overlap by ${f2(pair.overlap)} m².`);
  }
  if (departure) {
    for (const stretch of departure.outward) {
      flags.push(`Over ${f1(stretch.length)} m, from ${xz(stretch.from)} to ${xz(stretch.to)}, the generated outline stands up to ${f2(stretch.max)} m ${stretch.outside ? "outside" : "inside"} the largest member ${label(departure.largest)}${stretch.followed.length ? `, along ${stretch.followed.map(label).join(" and ")}` : ""}.`);
    }
    for (const stretch of departure.inward) {
      flags.push(`Over ${f1(stretch.length)} m, from ${xz(stretch.from)} to ${xz(stretch.to)}, the largest member ${label(departure.largest)}'s edge lies up to ${f2(stretch.max)} m ${stretch.inside ? "inside" : "outside"} the generated outline.`);
    }
  }
  // An inner ring with form tags (a tower, a roofed court) rather than a plain courtyard.
  const formTagged = (member) => FORM_TAG_KEYS.some((tagKey) => member.tags[tagKey] != null);
  for (const member of closedMembers) {
    if (!isInner(member) || !formTagged(member)) continue;
    const comparison = plan.comparisons.find((entry) => entry.member === member);
    flags.push(`Inner member ${label(member)} carries ${tagText(member.tags)}${comparison?.inHoles != null ? `; the generated outline has a ${f2(comparison.inHoles)} m² hole there` : ""}.`);
  }
  for (const member of members) {
    // The building's own tags count only when they say roof, canopy or shelter.
    const raised = member.key === key ? raisedOrRoofTags(member.tags).filter((tag) => !/^(layer|roof:)/u.test(tag)) : raisedOrRoofTags(member.tags);
    if (raised.length === 0 || (isInner(member) && member.ring && formTagged(member))) continue;
    flags.push(`${label(member)} (${member.role}) carries ${raised.join(", ")}.`);
  }
  const formKeys = ["height", "min_height", "building:levels", "building:min_level", "roof:levels", "roof:shape"];
  for (const member of members) {
    if (member.key === key) continue;
    const differing = formKeys.filter((tagKey) => member.tags[tagKey] != null && member.tags[tagKey] !== target.tags[tagKey]);
    if (differing.length) flags.push(`${label(member)} (${member.role}) has ${differing.map((tagKey) => `${tagKey}=${member.tags[tagKey]}`).join(", ")} against the building's ${differing.map((tagKey) => `${tagKey}=${target.tags[tagKey] ?? "(none)"}`).join(", ")}.`);
  }
  const ringsToCheck = [
    ...closedMembers.map((member) => ({ owner: label(member), crossings: member.crossings })),
    ...(generatedMeasures?.rings ?? []).map((entry) => ({ owner: `The generated ${entry.label}`, crossings: entry.crossings })),
  ];
  for (const { owner, crossings } of ringsToCheck) {
    if (crossings.length) flags.push(`${owner} crosses or touches itself ${crossings.length} time(s), at ${crossings.slice(0, 4).map((crossing) => xz(crossing.point)).join(", ")}${crossings.length > 4 ? ", …" : ""}.`);
  }
  if (generatedMeasures) {
    // Where the generated outline follows no member, the generator cut it (at
    // the island's edge, or by a rule of its own).
    for (const { entry, totals } of attribution) {
      const unattributed = totals.find(([letter]) => letter === "no member")?.[1] ?? 0;
      if (entry.hole || unattributed < 0.5) continue;
      const lost = plan.comparisons.filter((comparison) => comparison.outside >= 0.05)
        .map((comparison) => `${f2(comparison.outside)} m² of ${label(comparison.member)}`);
      flags.push(`The generated ${entry.label} follows no map member's edge for ${f1(unattributed)} m, where the generator cut it${lost.length ? `; ${lost.join(" and ")} lie${lost.length > 1 ? "" : "s"} outside it` : ""}.`);
    }
    for (const { entry, totals, matchesInner } of attribution) {
      if (!entry.hole || matchesInner) continue;
      const box = bounds(entry.ring);
      flags.push(`The generated outline has a ${f2(ringArea(entry.ring))} m² hole (${entry.label}, ${entry.ring.length} vertices, about ${xz([(box.minX + box.maxX) / 2, (box.minZ + box.maxZ) / 2])}) that matches no inner member; its edges follow ${totals.map(([letter, length]) => `${letter} for ${f1(length)} m`).join(", ")}.`);
    }
    // One line for all short steps; the run tables in plan.md mark each one.
    const steps = attribution.filter(({ entry, matchesInner }) => !entry.hole || matchesInner)
      .map(({ entry }) => ({ entry, runs: entry.runs.filter((run) => isStep(run, entry.runs)) }))
      .filter(({ runs }) => runs.length > 0);
    const stepCount = steps.reduce((sum, { runs }) => sum + runs.length, 0);
    if (stepCount > 0) {
      const where = steps.map(({ entry, runs }) => `${entry.label} run${runs.length > 1 ? "s" : ""} ${runs.map((run) => run.index).join(", ")}`).join("; ");
      flags.push(`The generated outline has ${stepCount} step${stepCount > 1 ? "s" : ""} under ${SHORT_RUN_M} m between corners (${where}; see the run tables).`);
    }
    if (generated.measure != null && Math.abs(generatedMeasures.area - generated.measure) > 0.5) {
      flags.push(`The outline traced from the generated roof mesh measures ${f2(generatedMeasures.area)} m², the generated record ${f2(generated.measure)} m².`);
    }
  } else {
    flags.push(generated ? "The generated record has no roof for this building." : "The generated world has no building record for this source key.");
  }
  for (const neighbour of plan.neighbours) {
    if (neighbour.kind === "building" && neighbour.overlap >= 0.05) flags.push(`Neighbour ${neighbour.key} (${tagText(neighbour.tags, ["building", "building:part", "name"])}) overlaps the footprint by ${f2(neighbour.overlap)} m².`);
  }
  if (plan.unit?.demolition) flags.push("The catalog marks this building demolished.");
  for (const note of plan.notes) flags.push(`${note[0].toUpperCase()}${note.slice(1)}.`);
  return { flags, look };
}

// --- Drawing ----------------------------------------------------------------

const PALETTE = {
  outer: ["#0072b2", "#e69f00", "#009e73", "#56b4e9", "#8c564b", "#999933"],
  inner: ["#cc79a7", "#882255", "#aa4499"],
  part: ["#9467bd", "#44aa99", "#117733"],
  generated: "#d62728",
  departure: "#00703c",
  passage: "#111111",
  node: "#6a3d9a",
};

// Keeps labels apart: each label tries its candidate places in order and takes
// the first that overlaps no earlier label or mark and stays in the plot; a
// label that must show takes its first place anyway, an optional one is left out.
class Labels {
  constructor(plot) {
    this.plot = plot;
    this.boxes = [];
  }

  static box(item) {
    const width = textWidth(item.text, item.size ?? 12);
    const height = item.size ?? 12;
    const anchor = item.anchor ?? "start";
    const x0 = anchor === "middle" ? -width / 2 : anchor === "end" ? -width : 0;
    const corners = [[x0, -height * 0.8], [x0 + width, -height * 0.8], [x0 + width, height * 0.25], [x0, height * 0.25]];
    const angle = ((item.rotate ?? 0) * Math.PI) / 180;
    const placed = corners.map(([x, y]) => [
      item.at[0] + x * Math.cos(angle) - y * Math.sin(angle),
      item.at[1] + x * Math.sin(angle) + y * Math.cos(angle),
    ]);
    const xs = placed.map((point) => point[0]);
    const ys = placed.map((point) => point[1]);
    return { x0: Math.min(...xs) - 1, y0: Math.min(...ys) - 1, x1: Math.max(...xs) + 1, y1: Math.max(...ys) + 1 };
  }

  reserve(box) {
    this.boxes.push(box);
  }

  free(box) {
    const inPlot = box.x0 >= this.plot.minX && box.x1 <= this.plot.maxX && box.y0 >= this.plot.minY && box.y1 <= this.plot.maxY;
    return inPlot && !this.boxes.some((other) => box.x0 < other.x1 && box.x1 > other.x0 && box.y0 < other.y1 && box.y1 > other.y0);
  }

  // Returns the placed label (or labels, for a multi-line one), or null.
  place(candidates, required = false) {
    for (const candidate of candidates) {
      const lines = Array.isArray(candidate) ? candidate : [candidate];
      const boxes = lines.map((item) => Labels.box(item));
      if (boxes.every((box) => this.free(box))) {
        boxes.forEach((box) => this.reserve(box));
        return lines;
      }
    }
    if (!required || candidates.length === 0) return null;
    const lines = Array.isArray(candidates[0]) ? candidates[0] : [candidates[0]];
    lines.forEach((item) => this.reserve(Labels.box(item)));
    return lines;
  }
}

function uprightAngle(a, b) {
  let angle = (Math.atan2(b[1] - a[1], b[0] - a[0]) * 180) / Math.PI;
  if (angle > 90) angle -= 180;
  if (angle <= -90) angle += 180;
  return angle;
}

function draw(plan, flags) {
  const { members, closedMembers, generated, generatedMeasures, departures, neighbours, unit, nodes, arcs } = plan;
  const extent = bounds([
    ...shapeRings(plan.footprint).flat(),
    ...members.flatMap((member) => member.points ?? (member.point ? [member.point] : [])),
    ...departures.flatMap((record) => record.ring),
    ...(unit?.passages ?? []).flatMap((passage) => [passage.outside, passage.inside]),
    ...(unit?.stairs ?? []).flatMap((flight) => [flight.bottom, flight.top]),
  ]);
  const view = {
    minX: Math.floor(extent.minX - NEIGHBOUR_M), maxX: Math.ceil(extent.maxX + NEIGHBOUR_M),
    minZ: Math.floor(extent.minZ - NEIGHBOUR_M), maxZ: Math.ceil(extent.maxZ + NEIGHBOUR_M),
  };
  const scale = Math.max(4, Math.min(40, 1400 / Math.max(view.maxX - view.minX, view.maxZ - view.minZ)));
  const left = 64;
  const top = 92;
  const plotW = (view.maxX - view.minX) * scale;
  const plotH = (view.maxZ - view.minZ) * scale;
  const plot = { minX: left, minY: top, maxX: left + plotW, maxY: top + plotH };
  const panelX = plot.maxX + 40;
  const panelW = 440;
  const px = (point) => [left + (point[0] - view.minX) * scale, top + (point[1] - view.minZ) * scale];
  const inPlot = (at, margin = 0) => at[0] >= plot.minX + margin && at[0] <= plot.maxX - margin && at[1] >= plot.minY + margin && at[1] <= plot.maxY - margin;
  const base = [];
  const marks = [];
  const texts = [];
  const labels = new Labels(plot);
  const ring = (target, rings, style) => target.push({ type: "polygon", rings: rings.map((points) => points.map(px)), ...style });
  const line = (target, points, style) => {
    for (const piece of clipLine(points.map(px), plot)) target.push({ type: "line", points: piece, ...style });
  };

  // Fixed marks first, so labels keep off them: north arrow and scale bar.
  const north = [plot.maxX - 34, plot.minY + 18];
  marks.push({ type: "circle", centre: [north[0], north[1] + 22], radius: 20, fill: "#ffffff", stroke: "#555555", width: 1 });
  marks.push({ type: "polygon", rings: [[[north[0], north[1] + 4], [north[0] + 8, north[1] + 32], [north[0], north[1] + 26], [north[0] - 8, north[1] + 32]]], fill: "#222222" });
  marks.push({ type: "text", at: [north[0], north[1] + 1], text: "N", size: 13, anchor: "middle", fill: "#222222", bold: true });
  labels.reserve({ x0: north[0] - 24, y0: north[1] - 14, x1: north[0] + 24, y1: north[1] + 46 });
  const barMetres = [5, 10, 20, 25, 50, 100].filter((metres) => metres * scale <= plotW / 3).at(-1) ?? 5;
  const barSteps = barMetres >= 20 ? 4 : 5;
  const bar = [plot.minX + 16, plot.maxY - 22];
  marks.push({ type: "polygon", rings: [[[bar[0] - 8, bar[1] - 20], [bar[0] + barMetres * scale + 30, bar[1] - 20], [bar[0] + barMetres * scale + 30, bar[1] + 14], [bar[0] - 8, bar[1] + 14]]], fill: "#ffffff", fillOpacity: 0.85 });
  for (let step = 0; step < barSteps; step += 1) {
    const x0 = bar[0] + (barMetres * scale * step) / barSteps;
    const x1 = bar[0] + (barMetres * scale * (step + 1)) / barSteps;
    marks.push({ type: "polygon", rings: [[[x0, bar[1]], [x1, bar[1]], [x1, bar[1] + 6], [x0, bar[1] + 6]]], fill: step % 2 ? "#ffffff" : "#333333", stroke: "#333333", width: 1 });
  }
  marks.push({ type: "text", at: [bar[0], bar[1] - 5], text: "0", size: 10, anchor: "middle", fill: "#333333" });
  marks.push({ type: "text", at: [bar[0] + barMetres * scale, bar[1] - 5], text: `${barMetres} m`, size: 10, anchor: "middle", fill: "#333333" });
  labels.reserve({ x0: bar[0] - 8, y0: bar[1] - 20, x1: bar[0] + barMetres * scale + 30, y1: bar[1] + 14 });

  // Ground areas, then the 10 m grid, roads and other buildings.
  for (const neighbour of neighbours.filter((entry) => entry.kind === "area" || entry.kind === "line")) {
    const fill = neighbour.kind === "area" && neighbour.ring ? clipRing(neighbour.ring.map(px), plot) : [];
    if (fill.length >= 3) base.push({ type: "polygon", rings: [fill], fill: "#f1f1ec", stroke: "#cfcfcf", width: 1 });
    else for (const points of neighbour.lines) line(base, points, { stroke: neighbour.kind === "line" ? "#9ecae1" : "#cfcfcf", width: neighbour.kind === "line" ? 2 : 1 });
  }
  for (let x = Math.ceil(view.minX / 10) * 10; x <= view.maxX; x += 10) line(base, [[x, view.minZ], [x, view.maxZ]], { stroke: "#e4e4e4", width: 1 });
  for (let z = Math.ceil(view.minZ / 10) * 10; z <= view.maxZ; z += 10) line(base, [[view.minX, z], [view.maxX, z]], { stroke: "#e4e4e4", width: 1 });
  for (const neighbour of neighbours.filter((entry) => entry.kind === "road")) {
    const width = ROAD_WIDTHS_M[neighbour.tags.highway];
    for (const points of neighbour.lines) {
      if (width) line(base, points, { stroke: "#dedede", width: width * scale, cap: "round" });
      line(base, points, { stroke: "#b5b5b5", width: 1, dash: [6, 4] });
    }
  }
  for (const neighbour of neighbours.filter((entry) => entry.kind === "building")) {
    const fill = neighbour.ring ? clipRing(neighbour.ring.map(px), plot) : [];
    if (fill.length >= 3) base.push({ type: "polygon", rings: [fill], fill: "#e6e6e6", stroke: "#a8a8a8", width: 1 });
    else for (const points of neighbour.lines) line(base, points, { stroke: "#a8a8a8", width: 1 });
  }

  // Members: fills, then edges widest first (the largest member) so a shared
  // edge shows both colours; the generated outline over them on a white casing.
  for (const member of closedMembers) ring(base, [member.ring], { fill: member.colour, fillOpacity: isInner(member) ? 0.14 : 0.17, name: "member-fill" });
  const widths = [8, 5.5, 3.5];
  [...members].sort((a, b) => (b.area ?? 0) - (a.area ?? 0)).forEach((member, rank) => {
    const width = widths[Math.min(rank, widths.length - 1)];
    const dash = isInner(member) ? [8, 4] : isPart(member) ? [3, 3] : null;
    const name = `member member-${member.letter}`;
    if (member.ring) ring(base, [member.ring], { stroke: member.colour, width, dash, name });
    else if (member.points) line(base, member.points, { stroke: member.colour, width, dash, name });
  });
  for (const record of departures) ring(base, [record.ring], { fill: PALETTE.departure, fillOpacity: 0.12, stroke: PALETTE.departure, width: 2.5, dash: [6, 3], name: "departure" });
  if (generatedMeasures) {
    ring(base, shapeRings(generated.shape), { stroke: "#ffffff", width: 3.6 });
    ring(base, shapeRings(generated.shape), { stroke: PALETTE.generated, width: 1.8, name: "generated-outline" });
  }

  // Marks first, so that labels keep off them: member letters, tagged nodes,
  // catalog arrows, arc centres and radius lines.
  const letters = [];
  for (const member of members) {
    const anchorPoint = member.widthAt ?? member.point ?? member.points?.[0];
    if (!anchorPoint) continue;
    let at = px(anchorPoint);
    while (letters.some((other) => Math.hypot(other.at[0] - at[0], other.at[1] - at[1]) < 24)) at = [at[0] + 16, at[1] + 16];
    letters.push({ member, at });
    marks.push({ type: "circle", centre: at, radius: 10, fill: "#ffffff", stroke: member.colour, width: 2.5 });
    marks.push({ type: "text", at: [at[0], at[1] + 4.5], text: member.letter, size: 13, anchor: "middle", fill: member.colour, bold: true, halo: false });
    labels.reserve({ x0: at[0] - 11, y0: at[1] - 11, x1: at[0] + 11, y1: at[1] + 11 });
  }
  for (const node of nodes) {
    const at = px(node.point);
    const entrance = node.tags.entrance != null || node.tags.door != null;
    if (entrance) marks.push({ type: "polygon", rings: [[[at[0], at[1] - 6], [at[0] + 5, at[1] + 4], [at[0] - 5, at[1] + 4]]], fill: PALETTE.node, stroke: "#ffffff", width: 1 });
    else marks.push({ type: "circle", centre: at, radius: 3.5, fill: PALETTE.node, stroke: "#ffffff", width: 1 });
    labels.reserve({ x0: at[0] - 6, y0: at[1] - 7, x1: at[0] + 6, y1: at[1] + 5 });
  }
  const arrows = [];
  const arrow = (from, to, text) => {
    const a = px(from);
    const b = px(to);
    const length = Math.hypot(b[0] - a[0], b[1] - a[1]) || 1;
    const ux = (b[0] - a[0]) / length;
    const uy = (b[1] - a[1]) / length;
    marks.push({ type: "line", points: [a, b], stroke: "#ffffff", width: 5 });
    marks.push({ type: "line", points: [a, b], stroke: PALETTE.passage, width: 2.5 });
    marks.push({ type: "polygon", rings: [[b, [b[0] - ux * 11 - uy * 5, b[1] - uy * 11 + ux * 5], [b[0] - ux * 11 + uy * 5, b[1] - uy * 11 - ux * 5]]], fill: PALETTE.passage });
    marks.push({ type: "circle", centre: a, radius: 3.5, fill: PALETTE.passage });
    for (let along = 0; along <= length; along += 6) labels.reserve({ x0: a[0] + ux * along - 4, y0: a[1] + uy * along - 4, x1: a[0] + ux * along + 4, y1: a[1] + uy * along + 4 });
    arrows.push({ a, ux, uy, text });
  };
  for (const passage of unit?.passages ?? []) arrow(passage.outside, passage.inside, `passage: ${passage.name ?? "door"}`);
  (unit?.stairs ?? []).forEach((flight, index) => arrow(flight.bottom, flight.top, `stairs ${index + 1}, up`));

  // Arc radii. A shared centre in view gets a cross and one radial dimension
  // line per level; otherwise each level's longest arc gets a short guide
  // toward its centre. Labels take the colour of the member whose arc it is.
  const radiusLabels = [];
  const radiusLines = [];
  for (const group of arcs.groups) {
    const centre = px(group.centre);
    const visible = inPlot(centre, 8);
    if (visible) {
      marks.push({ type: "line", points: [[centre[0] - 7, centre[1]], [centre[0] + 7, centre[1]]], stroke: "#444444", width: 1.2 });
      marks.push({ type: "line", points: [[centre[0], centre[1] - 7], [centre[0], centre[1] + 7]], stroke: "#444444", width: 1.2 });
      labels.reserve({ x0: centre[0] - 8, y0: centre[1] - 8, x1: centre[0] + 8, y1: centre[1] + 8 });
    }
    const used = [];
    for (const level of group.levels) {
      const arc = level.longest;
      const colour = arc.generated ? PALETTE.generated : arc.colour;
      const text = `R ${f2(level.radius)}`;
      const points = arc.run.points;
      if (visible) {
        // A bearing inside the arc, kept 10 degrees from the other levels' lines.
        const bearings = points.map((point) => bearingOf(point[0] - group.centre[0], point[1] - group.centre[1]));
        const middle = Math.floor(bearings.length / 2);
        const ordered = bearings.map((bearing, index) => ({ bearing, order: Math.abs(index - middle) })).sort((p, q) => p.order - q.order).map((entry) => entry.bearing);
        const bearing = ordered.find((candidate) => used.every((other) => Math.abs(((candidate - other + 540) % 360) - 180) >= 10)) ?? ordered[0];
        used.push(bearing);
        const radians = (bearing * Math.PI) / 180;
        const end = [group.centre[0] + Math.sin(radians) * level.radius, group.centre[1] - Math.cos(radians) * level.radius];
        line(marks, [group.centre, end], { stroke: colour, width: 1, dash: [4, 3] });
        const tip = px(end);
        radiusLines.push([centre, tip]);
        marks.push({ type: "circle", centre: tip, radius: 2.5, fill: colour });
        const angle = uprightAngle(centre, tip);
        radiusLabels.push([0.8, 0.7, 0.6, 0.5, 0.4, 0.3].map((share) => {
          const at = [centre[0] + (tip[0] - centre[0]) * share, centre[1] + (tip[1] - centre[1]) * share];
          return { type: "text", at: [at[0], at[1] - 3], text, size: 11, anchor: "middle", fill: colour, bold: true, rotate: angle };
        }));
      } else {
        const middle = points[Math.floor(points.length / 2)];
        const toward = [group.centre[0] - middle[0], group.centre[1] - middle[1]];
        const length = Math.hypot(...toward);
        const reach = Math.min(length, 70 / scale);
        const end = [middle[0] + (toward[0] / length) * reach, middle[1] + (toward[1] / length) * reach];
        line(marks, [middle, end], { stroke: colour, width: 1, dash: [3, 3] });
        const at = px(end);
        radiusLines.push([px(middle), at]);
        radiusLabels.push([0, 14, -14, 28].map((dy) => ({ type: "text", at: [at[0], at[1] + 4 + dy], text, size: 11, anchor: "middle", fill: colour, bold: true })));
      }
    }
  }
  for (const arc of arcs.alone) {
    if (arc.run.span < 20) continue;
    const colour = arc.generated ? PALETTE.generated : arc.colour;
    const points = arc.run.points;
    const middle = points[Math.floor(points.length / 2)];
    const toward = [arc.run.centre[0] - middle[0], arc.run.centre[1] - middle[1]];
    const length = Math.hypot(...toward);
    const reach = Math.min(length, 60 / scale);
    const end = [middle[0] + (toward[0] / length) * reach, middle[1] + (toward[1] / length) * reach];
    line(marks, [middle, end], { stroke: colour, width: 1, dash: [3, 3] });
    const at = px(end);
    radiusLines.push([px(middle), at]);
    radiusLabels.push([0, 14, -14].map((dy) => ({ type: "text", at: [at[0], at[1] + 4 + dy], text: `R ${f2(arc.run.radius)}`, size: 11, anchor: "middle", fill: colour, bold: true })));
  }

  // Labels, most important first: radii (on their own lines), then, kept off
  // those lines, members (key, role, tags), catalog arrows, and tagged nodes
  // and run lengths where there is room.
  for (const candidates of radiusLabels) texts.push(...labels.place(candidates, true));
  for (const [from, to] of radiusLines) {
    const length = Math.hypot(to[0] - from[0], to[1] - from[1]);
    for (let along = 0; along <= length; along += 6) {
      const at = [from[0] + ((to[0] - from[0]) * along) / (length || 1), from[1] + ((to[1] - from[1]) * along) / (length || 1)];
      labels.reserve({ x0: at[0] - 3, y0: at[1] - 3, x1: at[0] + 3, y1: at[1] + 3 });
    }
  }
  for (const { member, at } of letters) {
    const tagLines = wrapText(tagText(member.tags), 44);
    const shown = tagLines.slice(0, 2).map((text, index) => (index === 1 && tagLines.length > 2 ? `${text} …` : text));
    const block = (dx, dy, anchor) => [
      { type: "text", at: [at[0] + dx, at[1] + dy], text: `${member.key} · ${member.role}`, size: 11, fill: member.colour, bold: true, anchor },
      ...shown.map((text, index) => ({ type: "text", at: [at[0] + dx, at[1] + dy + 13 * (index + 1)], text, size: 10, fill: "#333333", anchor })),
    ];
    texts.push(...labels.place([block(15, 4, "start"), block(-15, 4, "end"), block(15, -24, "start"), block(-15, -24, "end"), block(0, 26, "middle"), block(0, -36, "middle")], true));
  }
  for (const { a, ux, uy, text } of arrows) {
    const item = (dx, dy, anchor) => ({ type: "text", at: [a[0] + dx, a[1] + dy], text, size: 11, anchor, fill: PALETTE.passage, bold: true });
    texts.push(...labels.place([
      item(-ux * 10, -uy * 10 + 4, ux > 0.3 ? "end" : ux < -0.3 ? "start" : "middle"),
      item(0, 18, "middle"), item(0, -10, "middle"), item(-8, 4, "end"), item(8, 4, "start"), item(0, 32, "middle"), item(0, -24, "middle"),
    ], true));
  }
  for (const node of nodes) {
    const at = px(node.point);
    const tags = node.tags;
    const text = tags["addr:housenumber"] ?? (tags.entrance != null ? `entrance ${tags.entrance}` : tags.door != null ? `door ${tags.door}` : `${Object.keys(tags)[0]}=${Object.values(tags)[0]}`);
    const item = (dx, dy, anchor) => ({ type: "text", at: [at[0] + dx, at[1] + dy], text, size: 10, anchor, fill: PALETTE.node });
    texts.push(...(labels.place([item(8, -6, "start"), item(-8, -6, "end"), item(8, 12, "start"), item(-8, 12, "end"), item(0, -12, "middle"), item(0, 20, "middle"), item(10, 26, "start"), item(-10, 26, "end")]) ?? []));
  }

  // Lengths of the generated outline's straight runs, just outside it.
  for (const entry of generatedMeasures?.rings ?? []) {
    for (const run of entry.runs) {
      if (run.kind !== "straight") continue;
      const text = f2(run.length);
      const a = px(run.from);
      const b = px(run.to);
      const pixels = Math.hypot(b[0] - a[0], b[1] - a[1]);
      if (pixels < textWidth(text, 10) + 14) continue;
      // Runs go clockwise on the plan: the ring's outside is on the left of travel.
      const normal = [(b[1] - a[1]) / pixels, -(b[0] - a[0]) / pixels];
      const item = (offset) => ({ type: "text", at: [(a[0] + b[0]) / 2 + normal[0] * offset, (a[1] + b[1]) / 2 + normal[1] * offset + 3], text, size: 10, anchor: "middle", fill: "#9b1c1c", rotate: uprightAngle(a, b) });
      texts.push(...(labels.place([item(13), item(22), item(-13)]) ?? []));
    }
  }

  // Context labels last: they give way to everything above.
  for (const neighbour of neighbours.filter((entry) => entry.kind === "road")) {
    const text = `${neighbour.tags.highway}${neighbour.tags.name ? ` · ${neighbour.tags.name}` : ""}`;
    for (const points of neighbour.lines) {
      const pieces = clipLine(points.map(px), plot).flatMap((piece) => piece.slice(1).map((point, index) => [piece[index], point]))
        .filter(([a, b]) => Math.hypot(b[0] - a[0], b[1] - a[1]) > textWidth(text, 10) + 16)
        .sort((first, second) => Math.hypot(second[1][0] - second[0][0], second[1][1] - second[0][1]) - Math.hypot(first[1][0] - first[0][0], first[1][1] - first[0][1]));
      const candidates = pieces.slice(0, 3).flatMap(([a, b]) => [0.5, 0.3, 0.7].map((share) => ({ type: "text", at: [a[0] + (b[0] - a[0]) * share, a[1] + (b[1] - a[1]) * share - 3], text, size: 10, anchor: "middle", fill: "#808080", rotate: uprightAngle(a, b) })));
      const placed = labels.place(candidates);
      if (placed) {
        texts.push(...placed);
        break;
      }
    }
  }
  for (const neighbour of neighbours.filter((entry) => entry.kind === "building" || (entry.kind === "area" && entry.ring))) {
    // Label the part in view: the widest point of the ring clipped to the plot.
    const visible = clipRing((neighbour.ring ?? dropClosingPoint(neighbour.lines[0])).map(px), plot);
    if (visible.length < 3 || ringArea(visible) < 200) continue;
    const at = inscribedCircle(orientRing(visible)).centre;
    const tags = neighbour.tags;
    const what = neighbour.kind === "building" ? tags.building ?? `part ${tags["building:part"]}` : `${surfaceName(tags)}${tags.name ? ` · ${tags.name}` : ""}`;
    const text = `${neighbour.key} ${what}`;
    const item = (dy) => ({ type: "text", at: [at[0], at[1] + dy], text, size: 10, anchor: "middle", fill: "#7a7a7a" });
    texts.push(...(labels.place([item(4), item(18), item(-10)]) ?? []));
  }

  // Frame, 1 m ticks with labels every 10 m.
  const frame = [];
  frame.push({ type: "polygon", rings: [[[plot.minX, plot.minY], [plot.maxX, plot.minY], [plot.maxX, plot.maxY], [plot.minX, plot.maxY]]], stroke: "#555555", width: 1 });
  for (let x = view.minX; x <= view.maxX; x += 1) {
    const length = x % 10 === 0 ? 9 : x % 5 === 0 ? 6 : 3;
    const [sx] = px([x, view.minZ]);
    frame.push({ type: "line", points: [[sx, plot.minY], [sx, plot.minY - length]], stroke: "#555555", width: 1 });
    frame.push({ type: "line", points: [[sx, plot.maxY], [sx, plot.maxY + length]], stroke: "#555555", width: 1 });
    if (x % 10 === 0) {
      frame.push({ type: "text", at: [sx, plot.minY - 12], text: String(x), size: 10, anchor: "middle", fill: "#555555", halo: false, name: "ruler-x", data: { metres: x, px: sx.toFixed(2) } });
      frame.push({ type: "text", at: [sx, plot.maxY + 21], text: String(x), size: 10, anchor: "middle", fill: "#555555", halo: false, name: "ruler-x", data: { metres: x, px: sx.toFixed(2) } });
    }
  }
  for (let z = view.minZ; z <= view.maxZ; z += 1) {
    const length = z % 10 === 0 ? 9 : z % 5 === 0 ? 6 : 3;
    const [, sy] = px([view.minX, z]);
    frame.push({ type: "line", points: [[plot.minX, sy], [plot.minX - length, sy]], stroke: "#555555", width: 1 });
    frame.push({ type: "line", points: [[plot.maxX, sy], [plot.maxX + length, sy]], stroke: "#555555", width: 1 });
    if (z % 10 === 0) frame.push({ type: "text", at: [plot.minX - 12, sy + 3.5], text: String(z), size: 10, anchor: "end", fill: "#555555", halo: false, name: "ruler-z", data: { metres: z, px: sy.toFixed(2) } });
  }
  frame.push({ type: "text", at: [plot.minX, plot.maxY + 40], text: "x: metres east, z: metres south (north up) in the game's frame; ticks every 1 m, labels every 10 m", size: 11, fill: "#555555", halo: false });

  // Title and panel.
  const name = plan.target.tags.name ?? unit?.identity?.canonical_name ?? "";
  const panel = [];
  panel.push({ type: "text", at: [left, 28], text: `${plan.key}${name ? ` · ${name}` : ""}: plan from the frozen map data`, size: 18, bold: true, fill: "#111111", halo: false });
  panel.push({ type: "text", at: [left, 50], text: `${basename(SOURCE_CONTRACT.raw_osm.path)} and the generated world (generator ${GENERATOR_VERSION}); ${f1(scale)} px per metre. Measures, runs and arcs: plan.md.`, size: 12, fill: "#555555", halo: false });
  let y = top;
  const write = (text, options = {}) => {
    panel.push({ type: "text", at: [panelX + (options.indent ?? 0), y], text, size: options.size ?? 12, fill: options.fill ?? "#222222", bold: options.bold, halo: false });
    y += options.step ?? 17;
  };
  const wrapped = (text, options = {}) => {
    for (const piece of wrapText(text, Math.floor((panelW - (options.indent ?? 0)) / ((options.size ?? 12) * 0.6)))) write(piece, options);
  };
  write("Map members", { bold: true, size: 14, step: 20 });
  for (const member of members) {
    panel.push({ type: "circle", centre: [panelX + 9, y - 4], radius: 9, fill: "#ffffff", stroke: member.colour, width: 2.5 });
    panel.push({ type: "text", at: [panelX + 9, y + 0.5], text: member.letter, size: 12, anchor: "middle", fill: member.colour, bold: true, halo: false });
    write(`${member.key} · ${member.role}`, { indent: 26, bold: true, fill: member.colour });
    wrapped(tagText(member.tags), { indent: 26, size: 11, fill: "#444444", step: 15 });
    if (member.ring) wrapped(`${f2(member.area)} m² · ${member.ring.length} vertices · ${f2(member.rectangle.length)} × ${f2(member.rectangle.width)} m along ${deg(member.rectangle.long_bearing)} · greatest width ${f2(member.width)} m`, { indent: 26, size: 11, fill: "#444444", step: 15 });
    else if (member.points) write(`open way, ${member.points.length} nodes`, { indent: 26, size: 11, fill: "#444444", step: 15 });
    y += 6;
  }
  if (generatedMeasures) {
    y += 2;
    write("Generated outline", { bold: true, size: 14, step: 20 });
    wrapped(`${f2(generatedMeasures.area)} m², ${f2(generatedMeasures.rectangle.length)} × ${f2(generatedMeasures.rectangle.width)} m along ${deg(generatedMeasures.rectangle.long_bearing)}; ${generatedMeasures.rings.map((entry) => `${entry.label} ${f2(ringArea(entry.ring))} m²`).join(", ")}; height ${generated.object.heights.map((height) => `${height.height_m} m`).join(", ")}`, { size: 11, step: 15 });
    y += 6;
  }
  if (departures.length) {
    write("Approved departures (osm_exception)", { bold: true, size: 14, step: 20 });
    for (const record of departures) {
      const reach = record.reach != null ? `, reaching ${f2(record.reach)} m beyond the generated outline` : "";
      wrapped(`${record.path.replace(/^\./u, "")} in ${basename(record.file)}: ${f2(record.area)} m², ${f2(record.rectangle.length)} × ${f2(record.rectangle.width)} m${reach}`, { size: 11, step: 15 });
    }
    y += 6;
  }
  write("Lines", { bold: true, size: 14, step: 20 });
  const legendRow = (paint, text) => {
    paint(y - 4);
    write(text, { indent: 40, size: 11 });
  };
  legendRow((ky) => panel.push({ type: "line", points: [[panelX, ky], [panelX + 30, ky]], stroke: PALETTE.generated, width: 1.8 }), "outline the world generator uses (its roof mesh)");
  legendRow((ky) => panel.push({ type: "line", points: [[panelX, ky], [panelX + 30, ky]], stroke: "#555555", width: 5 }), "map member edge, wider for larger members (inner dashed)");
  if (departures.length) legendRow((ky) => panel.push({ type: "line", points: [[panelX, ky], [panelX + 30, ky]], stroke: PALETTE.departure, width: 2.5, dash: [6, 3] }), "approved departure (osm_exception outline)");
  legendRow((ky) => panel.push({ type: "polygon", rings: [[[panelX, ky - 6], [panelX + 30, ky - 6], [panelX + 30, ky + 5], [panelX, ky + 5]]], fill: "#e6e6e6", stroke: "#a8a8a8", width: 1 }), `other buildings within ${NEIGHBOUR_M} m`);
  legendRow((ky) => panel.push({ type: "line", points: [[panelX, ky], [panelX + 30, ky]], stroke: "#dedede", width: 8 }), "roads at the generator's widths; ground areas pale");
  if ((unit?.passages ?? []).length || (unit?.stairs ?? []).length) legendRow((ky) => panel.push({ type: "line", points: [[panelX, ky], [panelX + 30, ky]], stroke: PALETTE.passage, width: 2.5 }), "catalog passage or stair flight (to the arrow)");
  if (nodes.length) legendRow((ky) => panel.push({ type: "polygon", rings: [[[panelX + 15, ky - 6], [panelX + 20, ky + 4], [panelX + 10, ky + 4]]], fill: PALETTE.node }), "tagged map node on a member (triangle: entrance)");
  legendRow((ky) => panel.push({ type: "text", at: [panelX + 15, ky + 4], text: "12.40", size: 10, anchor: "middle", fill: "#9b1c1c", halo: false }), "straight-run length on the generated outline, m");
  legendRow((ky) => panel.push({ type: "text", at: [panelX + 15, ky + 4], text: "R", size: 11, anchor: "middle", fill: PALETTE.generated, bold: true, halo: false }), "arc radius, m, from a shared centre (+) where in view");
  y += 6;
  write(`Flags worth a look against photos (${flags.length})`, { bold: true, size: 14, step: 20 });
  if (flags.length === 0) write("none", { size: 11 });
  flags.forEach((flag, index) => {
    wrapped(`${index + 1}. ${flag}`, { size: 11, step: 15 });
    y += 3;
  });
  // White margins hide whatever a wide stroke carried past the plot's edge.
  const canvas = { width: Math.ceil(panelX + panelW + 24), height: Math.ceil(Math.max(plot.maxY + 56, y + 16)) };
  const masks = [
    [0, 0, canvas.width, plot.minY],
    [0, plot.maxY, canvas.width, canvas.height],
    [0, plot.minY, plot.minX, plot.maxY],
    [plot.maxX, plot.minY, canvas.width, plot.maxY],
  ].map(([x0, y0, x1, y1]) => ({ type: "polygon", rings: [[[x0, y0], [x1, y0], [x1, y1], [x0, y1]]], fill: "#ffffff" }));
  const items = [...base, ...marks, ...texts, ...masks, ...frame, ...panel];
  return { items, width: canvas.width, height: canvas.height, title: `${plan.key} plan`, scale };
}

function surfaceName(tags) {
  for (const key of ["leisure", "landuse", "amenity", "area:highway", "natural", "man_made"]) if (tags[key] != null) return `${key}=${tags[key]}`;
  return "area";
}

// --- plan.md ----------------------------------------------------------------

function table(header, rows) {
  const escape = (cell) => String(cell).replaceAll("|", "\\|").replaceAll("\n", " ");
  return [`| ${header.join(" | ")} |`, `| ${header.map(() => "---").join(" | ")} |`, ...rows.map((row) => `| ${row.map(escape).join(" | ")} |`)].join("\n");
}

const RUN_HEADER = ["run", "kind", "length m", "form", "from (x, z)", "to (x, z)", "corner at start °", "note"];

function runRows(runs) {
  return runs.map((run) => [
    run.index, run.kind, f2(run.length), runText(run), xz(run.from), xz(run.to), f1(run.corner),
    isStep(run, runs) ? `step under ${SHORT_RUN_M} m` : "",
  ]);
}

// A short straight run between two real corners (each at least 30 degrees
// from straight on), not a facet of a traced curve.
function isStep(run, runs) {
  const next = runs[run.index % runs.length];
  return run.kind === "straight" && run.length < SHORT_RUN_M &&
    Math.abs(run.corner - 180) >= 30 && Math.abs(next.corner - 180) >= 30;
}

function report(plan, flags, drawing, files) {
  const { key, target, members, closedMembers, generated, generatedMeasures, unit, departures, comparisons, attribution, departure, pairs, arcs, neighbours, nodes } = plan;
  const lines = [];
  const push = (...text) => lines.push(...text);
  const name = target.tags.name ?? unit?.identity?.canonical_name ?? "";
  push(`# Plan view: ${key}${name ? `, ${name}` : ""}`, "");
  push(`Made by \`tools/building-plan ${key}\` from the frozen map snapshot (\`${SOURCE_CONTRACT.raw_osm.path}\`, the file the world generator reads) and the generated world (\`generated/world\`, generator ${GENERATOR_VERSION}). Measures come from the map data and the generated record, in the game's plan frame: x east, z south (north is −z), metres. ${files.join(" and ")} draw it north up at ${f1(drawing.scale)} px per metre. Nothing here is estimated from photos or judges what the building looks like.`, "");

  push("## Building", "");
  push(`- Map object: ${key[0] === "w" ? "way" : "relation"} ${key}${target.tags.type ? ` (type=${target.tags.type})` : ""}, version ${target.metadata.source_version}, ${target.metadata.source_timestamp}.`);
  push(`- Tags: ${tagText(target.tags)}.`);
  if (unit) push(`- Catalog: ${unit.identity?.canonical_name ?? unit.identity?.formatted_address ?? "(no name)"} (${unit.unit_kind}), reference_recognizable ${unit.claim_status?.reference_recognizable ?? "?"}${unit.demolition ? ", marked demolished" : ""}.`);
  else push("- Catalog: no unit for this source key.");
  if (generated) {
    push(`- Generated record: ${generated.object.logical_object_key}; heights ${generated.object.heights.map((height) => `${height.source_key} ${height.height_m} m (${height.rule})`).join(", ") || "none"}.`);
    for (const roof of generated.roofs) push(`- Generated roof ${roof.key}: base ${f3(roof.base)} m, top ${f3(roof.top)} m (${roof.height} m tall).`);
  } else {
    push("- Generated record: none for this source key.");
  }
  push("");

  if (generatedMeasures) {
    const box = generatedMeasures.box;
    push("## Overall size (the generated outline)", "");
    push(table(["measure", "value"], [
      ["area", `${f2(generatedMeasures.area)} m² traced from the roof mesh (generated record: ${generated.measure != null ? `${f3(generated.measure)} m²` : "n/a"})`],
      ["perimeter", `${f2(generatedMeasures.perimeter)} m, holes included`],
      ["principal axes (minimum-area rectangle)", `${f2(generatedMeasures.rectangle.length)} m × ${f2(generatedMeasures.rectangle.width)} m, long side along ${deg(generatedMeasures.rectangle.long_bearing)}`],
      ["east-west × north-south", `${f2(box.maxX - box.minX)} m × ${f2(box.maxZ - box.minZ)} m (x ${f2(box.minX)} to ${f2(box.maxX)}, z ${f2(box.minZ)} to ${f2(box.maxZ)})`],
      ["rings", generatedMeasures.rings.map((entry) => `${entry.label} (${entry.ring.length} vertices, ${f2(ringArea(entry.ring))} m²)`).join("; ")],
    ]), "");
  }

  push("## Map members", "");
  push(table(["", "member", "role", "tags", "area m²", "perimeter m", "principal size m (long side along)", "greatest width m", "vertices"], members.map((member) => [
    member.letter, member.key, member.role, tagText(member.tags),
    member.ring ? f2(member.area) : "",
    member.ring ? f2(member.perimeter) : member.points ? "open way" : "node",
    member.ring ? `${f2(member.rectangle.length)} × ${f2(member.rectangle.width)} (${deg(member.rectangle.long_bearing)})` : "",
    member.ring ? f2(member.width) : "",
    member.ring ? member.ring.length : member.points?.length ?? 1,
  ])), "");
  push("Greatest width is the diameter of the largest circle that fits inside the member.", "");

  push(`## Flags ${flags.look}`, "");
  if (flags.flags.length) flags.flags.forEach((flag, index) => push(`${index + 1}. ${flag}`));
  else push("None.");
  push("");

  if (generatedMeasures) {
    push("## The generated outline against the map members", "");
    for (const comparison of comparisons) {
      const { member, totals } = comparison;
      const areas = comparison.inside != null
        ? `${f2(comparison.inside)} m² inside the generated outline, ${f2(comparison.inHoles)} m² in its holes, ${f2(comparison.outside)} m² outside it`
        : "area comparison not available";
      push(`- ${member.letter} ${member.key} (${member.role}): ${areas}; its edge runs ${f1(totals.on)} m on the outline, ${f1(totals.inside)} m inside it and ${f1(totals.outside)} m outside it.`);
      for (const stretch of comparison.stretches) push(`  - ${f1(stretch.length)} m ${stretch.cls} the outline from ${xz(stretch.from)} to ${xz(stretch.to)}, up to ${f2(stretch.max)} m from it (at ${xz(stretch.at)}).`);
    }
    for (const { entry, totals, matchesInner } of attribution) {
      push(`- The generated ${entry.label} (${f1(ringPerimeter(entry.ring))} m) follows ${totals.map(([letter, length]) => `${letter === "no member" ? "no member's edge" : letter} for ${f1(length)} m`).join(", ")}${entry.hole && !matchesInner ? "; it matches no inner member" : ""}.`);
    }
    if (departure) {
      const { largest, outward, inward } = departure;
      if (outward.length === 0 && inward.length === 0) {
        push(`- Against the largest outer member, ${largest.letter} ${largest.key}: the generated outline stays within ${DEPARTURE_M} m of it everywhere.`);
      } else {
        push(`- Against the largest outer member, ${largest.letter} ${largest.key}, more than ${DEPARTURE_M} m apart:`);
        for (const stretch of outward) push(`  - the generated outline stands up to ${f2(stretch.max)} m ${stretch.outside ? "outside" : "inside"} it over ${f1(stretch.length)} m, from ${xz(stretch.from)} to ${xz(stretch.to)}${stretch.followed.length ? `, along ${stretch.followed.map((member) => member.letter).join(" and ")}` : ""};`);
        for (const stretch of inward) push(`  - its edge lies up to ${f2(stretch.max)} m ${stretch.inside ? "inside" : "outside"} the generated outline over ${f1(stretch.length)} m, from ${xz(stretch.from)} to ${xz(stretch.to)}.`);
      }
    }
    push("");
  }

  const sharedGroups = arcs.groups.filter((group) => group.levels.length > 1 || group.arcs.length > 1);
  if (sharedGroups.length) {
    push("## Arcs about a shared centre", "");
    push(`Long arcs (60° or more) set a centre; a shorter arc joins it when its vertices lie at one distance from it within the arc tolerance. Arcs within ${LEVEL_M} m of one distance form a level. The centre and each level's distance are then fitted together (least squares over the members' vertices), so the steps between levels are radial depths about one centre.`, "");
    for (const group of sharedGroups) {
      push(`Centre ${xz(group.centre)}:`, "");
      push(table(["distance from the centre m (vertex range; fit error)", "arcs at this distance (own fit R)", "step to the next level m"], group.levels.map((level, index) => [
        `${f2(level.radius)} (${f2(level.min)}–${f2(level.max)}; rms ${f3(level.fit.rms)}, max ${f3(level.fit.max)})`,
        level.arcs.map((arc) => `${arc.owner} run ${arc.run.index}, ${arc.run.concave ? "concave" : "convex"}, ${f1(arc.run.span)}° (R ${f2(arc.run.radius)})`).join("; "),
        index + 1 < group.levels.length ? f2(level.radius - group.levels[index + 1].radius) : "",
      ])), "");
    }
  }

  if (pairs.length) {
    push("## Members that touch or overlap", "");
    push(table(["pair", "shared boundary m", "shared nodes", "overlap m²"], pairs.map((pair) => [`${pair.a.letter} ${pair.a.key} · ${pair.b.letter} ${pair.b.key}`, f1(pair.shared), pair.sharedNodes, pair.sameRole ? f2(pair.overlap) : "(different roles)"])), "");
  }

  push("## Runs", "");
  push("Each ring runs clockwise on the plan from its north-westernmost run. Edges meeting at less than 1.5° join one straight run; an arc is a stretch of three or more edges turning the same way that fits one circle (tolerance the larger of 0.15 m and 1 % of the radius, at most 0.5 m). The corner is the inside angle at the run's start: 90 a square corner, 270 a re-entrant one, about 180 a bend.", "");
  for (const entry of generatedMeasures?.rings ?? []) push(`### Generated ${entry.label}`, "", table(RUN_HEADER, runRows(entry.runs)), "");
  for (const member of closedMembers) push(`### ${member.letter} ${member.key} (${member.role})`, "", table(RUN_HEADER, runRows(member.runs)), "");

  if (nodes.length) {
    push("## Tagged nodes on the member ways", "");
    push(table(["node", "on member", "at (x, z)", "tags"], nodes.map((node) => [node.id, node.member, xz(node.point), tagText(node.tags)])), "");
  }

  if (departures.length) {
    push("## Approved departures from the map footprint (osm_exception)", "");
    for (const record of departures) {
      const against = record.outsideArea != null ? `${f2(record.outsideArea)} m² outside the generated outline, reaching ${f2(record.reach)} m beyond it` : "no generated outline to compare";
      push(`- \`${record.file}\` ${record.path.replace(/^\./u, "")}: ${f2(record.area)} m² (${f2(record.rectangle.length)} × ${f2(record.rectangle.width)} m), ${against}. Approved: ${record.approved ?? "(not recorded)"}`);
    }
    push("");
  }

  if (unit?.passages?.length || unit?.stairs?.length) {
    push("## Catalog passages and stairs", "");
    for (const passage of unit.passages ?? []) push(`- Passage "${passage.name ?? "door"}": outside ${xz(passage.outside)}, inside ${xz(passage.inside)}.`);
    (unit.stairs ?? []).forEach((flight, index) => push(`- Stair flight ${index + 1}: bottom ${xz(flight.bottom)}, top ${xz(flight.top)}.`));
    push("");
  }

  push(`## Neighbours within ${NEIGHBOUR_M} m`, "");
  if (neighbours.length) {
    push(table(["object", "kind", "tags", "nearest gap m", "note"], neighbours.map((neighbour) => {
      const width = neighbour.kind === "road" ? ROAD_WIDTHS_M[neighbour.tags.highway] : null;
      const notes = [];
      if (width) notes.push(`drawn ${width} m wide; its edge ${f2(Math.max(0, neighbour.distance - width / 2))} m away`);
      if (neighbour.overlap >= 0.05) notes.push(`overlaps the footprint by ${f2(neighbour.overlap)} m²`);
      if (neighbour.contains) notes.push("the building stands inside it");
      return [neighbour.key, neighbour.kind, tagText(neighbour.tags, ["building", "building:part", "highway", "name", "landuse", "leisure", "amenity", "natural", "man_made", "area:highway", "surface", "building:levels", "height"]), f2(neighbour.distance), notes.join("; ")];
    })), "");
  } else {
    push("None.", "");
  }

  push("## What the map data cannot give", "");
  push("- Which physical edge a line follows: a wall, a canopy's outer edge, a roof overhang or a podium. Photos decide that (a footprint follows the photos only where they clearly contradict it; see AGENTS.md).");
  push("- Heights, storeys and roof form beyond the tags printed above; most members carry none.");
  push("- Where doors and windows are, beyond nodes tagged as entrances.");
  push("- Exact positions: the snapshot's nodes were traced by volunteers, mostly from aerial imagery, and traced arcs wander a few decimetres about their fitted circles (fit errors above).");
  const snapshotDate = /\d{4}-\d{2}-\d{2}/u.exec(basename(SOURCE_CONTRACT.raw_osm.path))?.[0];
  push(`- Anything built or demolished after the snapshot${snapshotDate ? ` (${snapshotDate})` : ""}.`);
  push("");
  return `${lines.join("\n")}\n`;
}

function writeAtomically(path, content) {
  const temporary = `${path}.partial`;
  writeFileSync(temporary, content);
  renameSync(temporary, path);
}

function main() {
  let options;
  let plan;
  try {
    options = parseArguments(process.argv.slice(2));
    if (options.help) {
      console.log(USAGE);
      return 0;
    }
    options.outDirectory = outputDirectory(options.out, options.key);
    plan = analyse(options.key);
  } catch (error) {
    if (!(error instanceof UsageError)) throw error;
    console.error(`building-plan: ${error.message}${options ? "" : `\n\n${USAGE}`}`);
    return 2;
  }
  return writePlan(options, plan);
}

function writePlan(options, plan) {
  const flags = flagsFor(plan);
  const drawing = draw(plan, flags.flags);
  mkdirSync(options.outDirectory, { recursive: true });
  const pngPath = join(options.outDirectory, "plan.png");
  writeAtomically(join(options.outDirectory, "plan.svg"), toSvg(drawing.items, drawing.width, drawing.height, drawing.title));
  rmSync(pngPath, { force: true });
  const files = ["plan.svg"];
  // 8-bit, and no metadata chunks (they carry the time it was made).
  const magick = spawnSync("magick", ["mvg:-", "-depth", "8", "-strip", `png:${pngPath}.partial`], { input: toMvg(drawing.items, drawing.width, drawing.height), encoding: "utf8" });
  if (magick.error || magick.status !== 0) {
    rmSync(`${pngPath}.partial`, { force: true });
    console.log(`NOTE: no plan.png: ${magick.error ? `ImageMagick's magick could not run (${magick.error.code ?? magick.error.message})` : `magick exited ${magick.status}: ${magick.stderr.trim().split("\n")[0]}`}`);
  } else {
    renameSync(`${pngPath}.partial`, pngPath);
    files.push("plan.png");
  }
  writeAtomically(join(options.outDirectory, "plan.md"), report(plan, flags, drawing, files));
  console.log(`${options.key}: ${[...files, "plan.md"].map((file) => join(options.outDirectory, file)).join(", ")}`);
  console.log(`${flags.flags.length} flag(s) ${flags.look}${flags.flags.length ? `; the first: ${flags.flags[0]}` : ""}`);
  return 0;
}

// Any other failure (unreadable data, a roof mesh that does not close) ends in
// one line, not a stack trace.
try {
  process.exitCode = main();
} catch (error) {
  console.error(`building-plan: failed: ${error.message}`);
  process.exitCode = 1;
}
