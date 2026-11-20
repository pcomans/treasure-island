#!/usr/bin/env node
// Street-detail clearance: with every street-detail layer switched on, nothing
// they would build (OSM-placed items, scatter and set pieces) intrudes on a
// door, stair or approach buffer, a mid-rise door landing or ramp (its top, as
// data/street_detail/door_landings.json gives it, and landing_buffer_m round it;
// fences follow OSM and are not held to it), the ferry spawn and the walk straight
// ahead from it, the ferry path, the normal QA route or a whole-island QA landing
// anchor.
//
//   node tools/check_street_detail_clearance.mjs [WORLD_DIR]   (default generated/world)
//
// Buffers come from tools/config/street-detail-zones.json and are rebuilt here
// from their own sources: the manifest spawn and its yaw, the QA routes and the stairs in
// the building catalog as it is now, so a stair added after the last world
// generation is checked as well. The buffer shapes and the plan distance are the
// generator's own (streetDetailHardShapes, planDistance); what this check adds is
// a catalog read independent of the last build.
// Prints PASS or one FAIL line per intrusion. The always-on street ground
// (raised sidewalks, plaza, curb ramps) is walkable, not an intrusion: where it
// covers the spawn, the ferry path, the QA route or a landing anchor that is
// reported on a NOTE line, so tests that probe those places know to expect it.
//
// A fence counts by its solid runs (its openings are walkable) and its collision
// half thickness; an item with a footprint (a parked car, a long bench) by the
// stadium that holds its rectangle; any other by its point or line and its
// kind's radius (streetDetailPieces). Built fences must also never shut walkable
// ground in: around each one, the ground no building, built fence, street prop,
// parked car, tree trunk or the island's edge covers, at the stock capsule's
// reach, must all connect to the open ground beyond, so a player anywhere near a
// fence can walk out without the jetpack. Grass clumps, perennials and shrubs (the
// vegetation props without a trunk) have no collision. Each yard (a zone with yard
// rules, tools/lib/street-yard-generation.mjs) is flooded the same way over its
// whole polygon, walls, shed rows, containers and vehicles included, so no yard
// shuts walkable ground in (its gates stay open).
//
// No solid street prop a car cannot knock over stands on the paving of an OSM
// footway that a park zone draws as a band (owner, 2026-11-17: two salvaged stump
// seats inferred onto the Cityside Park promenade stopped every car driven along
// it). A band is a zone surface layer drawn along an OSM way tagged
// highway=footway, its centre line offset_m to the way's left and width_m wide,
// as the street ground draws it (offsetPolyline). A prop stands on the band when
// its foot lies within it and on the band's own material: one on a later layer
// drawn over the strip (plaza paint, a tree strip's mulch) stands on that layer.
// Solid is a point row isStreetSolid counts (a street prop, a parked car, a tree
// trunk); the props a car knocks over are the furniture kit's FELLABLE, read from
// the kit itself.
//
// No plant stands on the paving a housing building draws for itself (its parking pad,
// aprons, walks and door paths, as data/street_detail/building_paving.json gives them,
// tools/export_building_paving.gd): a tree's or palm's trunk keeps pavingReach clear
// of it, and a low plant's foot or a hedge's line stays off it.

import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { parseRawOsmXml, rawWayLine } from "./lib/osm-geometry.mjs";
import { STREET_FURNITURE_PROPS } from "./lib/street-furniture-generation.mjs";
import {
  POCKET_CELL_M,
  STREET_DETAIL_KINDS,
  STREET_DETAIL_LAYERS,
  buildingPavingIndex,
  hardShapeDistance,
  isStreetSolid,
  loadBuildingPaving,
  loadDoorLandings,
  loadStreetDetailStairFlights,
  loadStreetDetailZones,
  planDistance,
  pavingReach,
  pocketRegions,
  roofTriangles,
  shutInPockets,
  streetDetailHardShapes,
  streetDetailPieces,
  streetSolids,
} from "./lib/street-detail-generation.mjs";
import { offsetPolyline } from "./lib/street-ground-generation.mjs";
import { unpackPlantingRows } from "./lib/street-planting-generation.mjs";
import { isYardZone } from "./lib/street-yard-generation.mjs";
import { SOURCE_CONTRACT } from "./lib/world-contract.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const worldRoot = resolve(projectRoot, process.argv[2] ?? "generated/world");

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

function main() {
  const manifest = readJson(resolve(worldRoot, "manifest.json"));
  const detail = unpackPlantingRows(readJson(resolve(worldRoot, manifest.street_detail.path)));
  const exclusions = loadStreetDetailZones(projectRoot).exclusions;
  const spawn = { xz: [manifest.initial_spawn.origin[0], manifest.initial_spawn.origin[2]], yaw: manifest.initial_spawn.yaw };
  const zones = streetDetailHardShapes(exclusions, spawn, loadStreetDetailStairFlights(projectRoot), loadDoorLandings(projectRoot))
    .map((shape) => ({ name: shape.component, id: shape.source_id, points: shape.points, radius: shape.radius_m, shape }));

  // Everything the switchable layers build when they are all on. Overhead lines
  // never reach the ground; ground rows (crossings, kerbs) are always-on surfaces.
  const items = [];
  for (const row of detail.rows) {
    const kind = STREET_DETAIL_KINDS[row.kind];
    if (row.status !== "placed" || !STREET_DETAIL_LAYERS.includes(row.layer) || kind.overhead) continue;
    streetDetailPieces(row).forEach((piece, index) => {
      items.push({ id: row.fence ? `${row.id} ${piece.label ?? index}` : row.id, layer: row.layer, fence: Boolean(row.fence), points: piece.points, radius: piece.radius });
    });
  }

  const failures = [];
  const minimum = {};
  for (const item of items) {
    for (const zone of zones) {
      if (zone.name === "landing" && item.fence) continue;
      const clearance = hardShapeDistance(zone.shape, item.points) - item.radius;
      minimum[zone.name] = Math.min(minimum[zone.name] ?? Infinity, clearance);
      if (clearance < zone.radius) {
        failures.push(`${item.id} (${item.layer}) is ${Math.max(0, clearance).toFixed(3)} m from ${zone.name} ${zone.id}; needs ${zone.radius} m`);
      }
    }
  }
  // Always-on street ground under the walked places: information, never a failure.
  const walked = zones.filter((zone) => ["spawn", "spawn_forward", "ferry_path", "qa_route", "whole_island_anchor"].includes(zone.name));
  const groundHits = {};
  for (const entry of manifest.chunks) {
    for (const record of readJson(resolve(worldRoot, entry.path)).records) {
      if (!["street_kerb", "street_kerb_support"].includes(record.feature_kind)) continue;
      for (let index = 0; index < record.indices.length; index += 3) {
        const corners = [0, 1, 2].map((corner) => record.indices[index + corner] * 3);
        const centroid = [
          corners.reduce((sum, at) => sum + record.vertices[at], 0) / 3,
          corners.reduce((sum, at) => sum + record.vertices[at + 2], 0) / 3,
        ];
        for (const zone of walked) {
          if (planDistance([centroid], zone.points) < zone.radius) {
            const key = `${zone.name} ${zone.id}`;
            groundHits[key] = (groundHits[key] ?? 0) + 1;
          }
        }
      }
    }
  }
  const covered = Object.entries(groundHits).map(([key, count]) => `${key} (${count} triangles)`);
  if (covered.length > 0) console.log(`NOTE: always-on street ground (walkable, not an intrusion) lies on ${covered.join(", ")}`);
  const pockets = fencedPockets(manifest, detail);
  failures.push(...pockets.failures);
  const footways = footwayObstacles(detail);
  failures.push(...footways.failures);
  const paving = pavedPlants(detail);
  failures.push(...paving.failures);
  const stairs = zones.filter((zone) => zone.name === "stair").length;
  // A check with nothing to compare would pass untested.
  if (items.length === 0 || stairs === 0) failures.push(`nothing to check: ${items.length} items, ${stairs} stair flights`);
  if (footways.bands.length === 0 || footways.solids === 0) failures.push(`nothing to check: ${footways.bands.length} footway bands, ${footways.solids} solid props a car cannot knock over`);
  if (paving.buildings === 0 || paving.plants === 0) failures.push(`nothing to check: ${paving.buildings} buildings' paving, ${paving.plants} plants`);
  for (const message of failures) console.log(`FAIL: ${message}`);
  if (failures.length > 0) process.exit(1);
  const byLayer = STREET_DETAIL_LAYERS.map((layer) => `${items.filter((item) => item.layer === layer).length} ${layer}`).join(", ");
  const closest = Object.entries(minimum).map(([name, value]) => `${name} ${value.toFixed(2)} m`).join(", ");
  const landings = zones.filter((zone) => zone.name === "landing").length;
  console.log(`PASS: street detail with all layers on (${byLayer}) clears ${stairs} stair flights with their doors and approaches, ${landings} mid-rise door landings and ramps, the spawn, its walk-forward line and the QA corridors; closest: ${closest}`);
  console.log(`PASS: ${pockets.fences} built fences and ${pockets.yards} yards shut no walkable ground in (${pockets.cells} cells of ${POCKET_CELL_M} m checked)`);
  console.log(`PASS: none of ${footways.solids} solid street props a car cannot knock over stands on the paving of ${footways.bands.length} OSM footway band(s) (${footways.bands.map((band) => `${band.id} ${band.way}`).join(", ")})`);
  console.log(`PASS: none of ${paving.plants} plants stands on the paving ${paving.buildings} housing buildings draw for themselves`);
}

// Plants standing on a building's drawn paving (see the header): {buildings, plants, failures}.
function pavedPlants(detail) {
  const paving = loadBuildingPaving(projectRoot);
  const onPaving = buildingPavingIndex(paving);
  const failures = [];
  let plants = 0;
  for (const row of detail.rows) {
    if (row.status !== "placed" || row.layer !== "vegetation") continue;
    plants += 1;
    const points = row.geometry === "point" ? [[row.position_m[0], row.position_m[2]]] : row.points_m.map((point) => [point[0], point[2]]);
    for (const point of points) {
      const paved = onPaving(point, pavingReach(row.kind));
      if (paved) {
        failures.push(`${row.id} (${row.kind}) stands within ${pavingReach(row.kind)} m of the paving ${paved} draws at [${point.map((value) => value.toFixed(2)).join(", ")}]`);
        break;
      }
    }
  }
  return { buildings: paving.length, plants, failures };
}

// Solid props a car cannot knock over standing on a zone's OSM footway band
// (see the header): {bands, solids, failures}.
function footwayObstacles(detail) {
  const osm = parseRawOsmXml(resolve(projectRoot, SOURCE_CONTRACT.raw_osm.path));
  const bands = [];
  for (const zone of loadStreetDetailZones(projectRoot).zones) {
    for (const layer of zone.ground?.surfaces?.layers ?? []) {
      const way = layer.shape.way;
      if (way === undefined || osm.ways.get(way.slice(1))?.tags.highway !== "footway") continue;
      // The layer's centre line in the east/north frame, then in world x, z.
      const centre = offsetPolyline(rawWayLine(osm, way.slice(1)), layer.shape.offset_m).map(([east, north]) => [east, -north]);
      bands.push({ id: `${zone.id}/${layer.id}`, way, material: layer.material, centre, half: layer.shape.width_m / 2 });
    }
  }
  const fellable = fellableProps();
  const failures = [];
  let solids = 0;
  for (const row of detail.rows) {
    if (row.geometry !== "point" || !isStreetSolid(row) || fellable.has(row.prop)) continue;
    solids += 1;
    const foot = [row.position_m[0], row.position_m[2]];
    for (const band of bands) {
      if (row.surface?.material_key !== band.material || planDistance([foot], band.centre) > band.half) continue;
      failures.push(`${row.id} (${row.prop}) stands on the paving of ${band.id} (OSM footway ${band.way}) at (${foot.map((value) => value.toFixed(2)).join(", ")}), and a car cannot knock it over; keep it off the footway`);
    }
  }
  return { bands, solids, failures };
}

// The props a car knocks over: the keys of FELLABLE in
// game/scripts/world/street_furniture_kit.gd, each a kit prop.
function fellableProps() {
  const kit = readFileSync(resolve(projectRoot, "game/scripts/world/street_furniture_kit.gd"), "utf8");
  const start = kit.indexOf("const FELLABLE := {");
  const block = start < 0 ? "" : kit.slice(start, kit.indexOf("\n}", start));
  const props = [...block.matchAll(/^\t"([a-z0-9_]+)":/gmu)].map((match) => match[1]);
  if (props.length === 0 || props.some((prop) => STREET_FURNITURE_PROPS[prop] === undefined)) {
    console.log(`FAIL: could not read the furniture kit's FELLABLE props (read: ${props.join(", ") || "none"})`);
    process.exit(1);
  }
  return new Set(props);
}

// Ground a built fence or a yard shuts in (shutInPockets in
// tools/lib/street-detail-generation.mjs, which the generator also runs to keep
// the island-wide parked cars from shutting ground in).
function fencedPockets(manifest, detail) {
  const regions = pocketRegions(detail.rows, loadStreetDetailZones(projectRoot).zones.filter(isYardZone));
  const fences = regions.filter((region) => !region.id.startsWith("yard ")).length;
  const yards = regions.length - fences;
  const failures = [];
  if (regions.length === 0) return { fences: 0, yards: 0, cells: 0, failures };
  const records = manifest.chunks.flatMap((entry) => readJson(resolve(worldRoot, entry.path)).records);
  // Even-odd ray casting along +x: a point is inside a ring when an odd number
  // of the edges that straddle its z cross that z east of it. The flood asks
  // row by row, every cell of a row at one z, so each ring's crossings at a z
  // are worked out once, edge by edge with the same expression, and sorted; a
  // point then counts those east of it by binary search.
  const rows = new Map();
  const inRing = (point, ring) => {
    let row = rows.get(ring);
    if (row?.z !== point[1]) {
      const crossings = [];
      for (let i = 0, j = ring.length - 1; i < ring.length; j = i, i += 1) {
        if ((ring[i][1] > point[1]) !== (ring[j][1] > point[1])) crossings.push(((ring[j][0] - ring[i][0]) * (point[1] - ring[i][1])) / (ring[j][1] - ring[i][1]) + ring[i][0]);
      }
      row = { z: point[1], crossings: crossings.sort((left, right) => left - right) };
      rows.set(ring, row);
    }
    let low = 0;
    let high = row.crossings.length;
    while (low < high) {
      const middle = (low + high) >> 1;
      if (point[0] < row.crossings[middle]) high = middle;
      else low = middle + 1;
    }
    return (row.crossings.length - low) % 2 === 1;
  };
  const onIsland = (point) => manifest.playable_boundary.components.some((component) => inRing(point, component.outer) && !component.holes.some((hole) => inRing(point, hole)));
  const pockets = shutInPockets({ regions, roofs: roofTriangles(records), solids: streetSolids(detail.rows), onIsland });
  for (const region of pockets.regions) {
    failures.push(`${region.id} shuts ${region.shut_m2.toFixed(1)} m2 of walkable ground in, e.g. at (${region.example.map((value) => value.toFixed(1)).join(", ")}); leave an opening`);
  }
  return { fences, yards, cells: pockets.cells, failures };
}

main();
