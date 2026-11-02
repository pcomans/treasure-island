#!/usr/bin/env node
// Street-detail clearance: with every street-detail layer switched on, nothing
// they would build (OSM-placed items, scatter, set pieces and the placeholder
// vegetation) intrudes on a door, stair or approach buffer, the ferry spawn and
// the walk straight ahead from it, the ferry path, the normal QA route or a
// whole-island QA landing anchor.
//
//   node tools/check_street_detail_clearance.mjs [WORLD_DIR]   (default generated/world)
//
// Buffers come from tools/config/street-detail-zones.json and are rebuilt here
// from their own sources: the manifest spawn and its yaw, the QA routes and the stairs in
// the building catalog as it is now, so a stair added after the last world
// generation is checked as well. The buffer shapes and the plan distance are the
// generator's own (streetDetailHardShapes, planDistance); what this check adds is
// the placeholder vegetation and a catalog read independent of the last build.
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
// parked car or the island's edge covers, at the stock capsule's reach, must all
// connect to the open ground beyond, so a player anywhere near a fence can walk
// out without the jetpack.

import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { PLAYER_CAPSULE_RADIUS_M } from "./lib/world-contract.mjs";
import {
  STREET_DETAIL_KINDS,
  STREET_DETAIL_LAYERS,
  loadStreetDetailStairFlights,
  loadStreetDetailZones,
  planDistance,
  streetDetailHardShapes,
  streetDetailPieces,
} from "./lib/street-detail-generation.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const worldRoot = resolve(projectRoot, process.argv[2] ?? "generated/world");

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

function main() {
  const manifest = readJson(resolve(worldRoot, "manifest.json"));
  const detail = readJson(resolve(worldRoot, manifest.street_detail.path));
  const vegetation = readJson(resolve(worldRoot, manifest.vegetation.path));
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
      items.push({ id: row.fence ? `${row.id} run ${index}` : row.id, layer: row.layer, points: piece.points, radius: piece.radius });
    });
  }
  for (const placement of vegetation.placements) {
    items.push({ id: placement.id, layer: "vegetation", points: [[placement.position_m[0], placement.position_m[2]]], radius: exclusions.vegetation_placeholder_radius_m });
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
  console.log(`PASS: ${pockets.fences} built fences shut no walkable ground in (${pockets.cells} cells of ${POCKET_CELL_M} m checked)`);
}

// Ground a built fence shuts in. Around each built fence (its runs plus a margin)
// a grid marks what the stock capsule's centre cannot reach: buildings, built
// fence runs and street props grown by the capsule radius, and everything off
// the island. Free cells that do not connect to the grid's edge are shut in.
const POCKET_CELL_M = 0.2;
const POCKET_MARGIN_M = 20;
function fencedPockets(manifest, detail) {
  const fences = detail.rows.filter((row) => row.status === "placed" && row.fence && row.prop != null);
  const failures = [];
  if (fences.length === 0) return { fences: 0, cells: 0, failures };
  const roofs = [];
  for (const entry of manifest.chunks) {
    for (const record of readJson(resolve(worldRoot, entry.path)).records) {
      if (!["building_roof", "building_part_roof"].includes(record.feature_kind)) continue;
      for (let index = 0; index < record.indices.length; index += 3) {
        roofs.push([0, 1, 2].map((corner) => [record.vertices[record.indices[index + corner] * 3], record.vertices[record.indices[index + corner] * 3 + 2]]));
      }
    }
  }
  const solids = [];
  for (const row of detail.rows) {
    if (row.status !== "placed") continue;
    // Built fences, street props and parked cars (every row the runtime builds
    // with collision), each grown by the capsule radius.
    if (row.prop != null && (row.fence || ["furniture", "clutter"].includes(row.layer))) {
      for (const piece of streetDetailPieces(row)) solids.push({ points: piece.points, radius: piece.radius + PLAYER_CAPSULE_RADIUS_M });
    }
  }
  const inRing = (point, ring) => {
    let inside = false;
    for (let i = 0, j = ring.length - 1; i < ring.length; j = i, i += 1) {
      if ((ring[i][1] > point[1]) !== (ring[j][1] > point[1]) && point[0] < ((ring[j][0] - ring[i][0]) * (point[1] - ring[i][1])) / (ring[j][1] - ring[i][1]) + ring[i][0]) inside = !inside;
    }
    return inside;
  };
  const onIsland = (point) => manifest.playable_boundary.components.some((component) => inRing(point, component.outer) && !component.holes.some((hole) => inRing(point, hole)));
  let cells = 0;
  for (const fence of fences) {
    const all = streetDetailPieces(fence).flatMap((piece) => piece.points);
    const x0 = Math.min(...all.map((point) => point[0])) - POCKET_MARGIN_M;
    const z0 = Math.min(...all.map((point) => point[1])) - POCKET_MARGIN_M;
    const width = Math.ceil((Math.max(...all.map((point) => point[0])) + POCKET_MARGIN_M - x0) / POCKET_CELL_M);
    const depth = Math.ceil((Math.max(...all.map((point) => point[1])) + POCKET_MARGIN_M - z0) / POCKET_CELL_M);
    const blocked = new Uint8Array(width * depth);
    const centre = (i, j) => [x0 + (i + 0.5) * POCKET_CELL_M, z0 + (j + 0.5) * POCKET_CELL_M];
    const mark = (minX, maxX, minZ, maxZ, test) => {
      const i0 = Math.max(0, Math.floor((minX - x0) / POCKET_CELL_M));
      const i1 = Math.min(width - 1, Math.floor((maxX - x0) / POCKET_CELL_M));
      const j0 = Math.max(0, Math.floor((minZ - z0) / POCKET_CELL_M));
      const j1 = Math.min(depth - 1, Math.floor((maxZ - z0) / POCKET_CELL_M));
      for (let j = j0; j <= j1; j += 1) for (let i = i0; i <= i1; i += 1) if (!blocked[j * width + i] && test(centre(i, j))) blocked[j * width + i] = 1;
    };
    for (let j = 0; j < depth; j += 1) for (let i = 0; i < width; i += 1) if (!onIsland(centre(i, j))) blocked[j * width + i] = 1;
    for (const triangle of roofs) {
      const xs = triangle.map((point) => point[0]);
      const zs = triangle.map((point) => point[1]);
      // Grown by the capsule radius: a centre this close to a wall cannot stand there.
      const grow = PLAYER_CAPSULE_RADIUS_M;
      mark(Math.min(...xs) - grow, Math.max(...xs) + grow, Math.min(...zs) - grow, Math.max(...zs) + grow, (point) => planDistance([point], [...triangle, triangle[0]]) <= grow || insideTriangle(point, triangle));
    }
    for (const solid of solids) {
      const xs = solid.points.map((point) => point[0]);
      const zs = solid.points.map((point) => point[1]);
      mark(Math.min(...xs) - solid.radius, Math.max(...xs) + solid.radius, Math.min(...zs) - solid.radius, Math.max(...zs) + solid.radius, (point) => planDistance([point], solid.points) <= solid.radius);
    }
    // Flood the free cells from the grid's edge.
    const reached = new Uint8Array(width * depth);
    const queue = [];
    for (let i = 0; i < width; i += 1) for (const j of [0, depth - 1]) queue.push(j * width + i);
    for (let j = 0; j < depth; j += 1) for (const i of [0, width - 1]) queue.push(j * width + i);
    for (let head = 0; head < queue.length; head += 1) {
      const index = queue[head];
      if (blocked[index] || reached[index]) continue;
      reached[index] = 1;
      const i = index % width;
      const j = (index - i) / width;
      if (i > 0) queue.push(index - 1);
      if (i < width - 1) queue.push(index + 1);
      if (j > 0) queue.push(index - width);
      if (j < depth - 1) queue.push(index + width);
    }
    let shut = 0;
    let example = null;
    for (let index = 0; index < blocked.length; index += 1) {
      if (blocked[index] || reached[index]) continue;
      shut += 1;
      example ??= centre(index % width, Math.floor(index / width));
    }
    cells += width * depth;
    // A single stray cell is grid noise in a corner; a capsule's footprint is not.
    const footprintCells = Math.ceil((Math.PI * PLAYER_CAPSULE_RADIUS_M ** 2) / POCKET_CELL_M ** 2);
    if (shut >= footprintCells) {
      failures.push(`${fence.id} shuts ${(shut * POCKET_CELL_M ** 2).toFixed(1)} m2 of walkable ground in, e.g. at (${example.map((value) => value.toFixed(1)).join(", ")}); leave an opening`);
    }
  }
  return { fences: fences.length, cells, failures };
}

function insideTriangle(point, [a, b, c]) {
  const sign = (p, q, r) => (p[0] - r[0]) * (q[1] - r[1]) - (q[0] - r[0]) * (p[1] - r[1]);
  const d1 = sign(point, a, b);
  const d2 = sign(point, b, c);
  const d3 = sign(point, c, a);
  return !((d1 < 0 || d2 < 0 || d3 < 0) && (d1 > 0 || d2 > 0 || d3 > 0));
}

main();
