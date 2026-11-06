#!/usr/bin/env node
// Street-detail clearance: with every street-detail layer switched on, nothing
// they would build (OSM-placed items, scatter and set pieces) intrudes on a
// door, stair or approach buffer, the ferry spawn and the walk straight ahead
// from it, the ferry path, the normal QA route or a whole-island QA landing
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

import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  POCKET_CELL_M,
  STREET_DETAIL_KINDS,
  STREET_DETAIL_LAYERS,
  loadStreetDetailStairFlights,
  loadStreetDetailZones,
  planDistance,
  pocketRegions,
  roofTriangles,
  shutInPockets,
  streetDetailHardShapes,
  streetDetailPieces,
  streetSolids,
} from "./lib/street-detail-generation.mjs";
import { unpackPlantingRows } from "./lib/street-planting-generation.mjs";
import { isYardZone } from "./lib/street-yard-generation.mjs";

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
  const zones = streetDetailHardShapes(exclusions, spawn, loadStreetDetailStairFlights(projectRoot))
    .map((shape) => ({ name: shape.component, id: shape.source_id, points: shape.points, radius: shape.radius_m }));

  // Everything the switchable layers build when they are all on. Overhead lines
  // never reach the ground; ground rows (crossings, kerbs) are always-on surfaces.
  const items = [];
  for (const row of detail.rows) {
    const kind = STREET_DETAIL_KINDS[row.kind];
    if (row.status !== "placed" || !STREET_DETAIL_LAYERS.includes(row.layer) || kind.overhead) continue;
    streetDetailPieces(row).forEach((piece, index) => {
      items.push({ id: row.fence ? `${row.id} ${piece.label ?? index}` : row.id, layer: row.layer, points: piece.points, radius: piece.radius });
    });
  }

  const failures = [];
  const minimum = {};
  for (const item of items) {
    for (const zone of zones) {
      const clearance = planDistance(item.points, zone.points) - item.radius;
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
  const stairs = zones.filter((zone) => zone.name === "stair").length;
  // A check with nothing to compare would pass untested.
  if (items.length === 0 || stairs === 0) failures.push(`nothing to check: ${items.length} items, ${stairs} stair flights`);
  for (const message of failures) console.log(`FAIL: ${message}`);
  if (failures.length > 0) process.exit(1);
  const byLayer = STREET_DETAIL_LAYERS.map((layer) => `${items.filter((item) => item.layer === layer).length} ${layer}`).join(", ");
  const closest = Object.entries(minimum).map(([name, value]) => `${name} ${value.toFixed(2)} m`).join(", ");
  console.log(`PASS: street detail with all layers on (${byLayer}) clears ${stairs} stair flights with their doors and approaches, the spawn, its walk-forward line and the QA corridors; closest: ${closest}`);
  console.log(`PASS: ${pockets.fences} built fences and ${pockets.yards} yards shut no walkable ground in (${pockets.cells} cells of ${POCKET_CELL_M} m checked)`);
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
  const inRing = (point, ring) => {
    let inside = false;
    for (let i = 0, j = ring.length - 1; i < ring.length; j = i, i += 1) {
      if ((ring[i][1] > point[1]) !== (ring[j][1] > point[1]) && point[0] < ((ring[j][0] - ring[i][0]) * (point[1] - ring[i][1])) / (ring[j][1] - ring[i][1]) + ring[i][0]) inside = !inside;
    }
    return inside;
  };
  const onIsland = (point) => manifest.playable_boundary.components.some((component) => inRing(point, component.outer) && !component.holes.some((hole) => inRing(point, hole)));
  const pockets = shutInPockets({ regions, roofs: roofTriangles(records), solids: streetSolids(detail.rows), onIsland });
  for (const region of pockets.regions) {
    failures.push(`${region.id} shuts ${region.shut_m2.toFixed(1)} m2 of walkable ground in, e.g. at (${region.example.map((value) => value.toFixed(1)).join(", ")}); leave an opening`);
  }
  return { fences, yards, cells: pockets.cells, failures };
}

main();
