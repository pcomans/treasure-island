#!/usr/bin/env node
// Street-detail clearance: with every street-detail layer switched on, nothing
// they would build (OSM-placed items, scatter, set pieces and the placeholder
// vegetation) intrudes on a door, stair or approach buffer, the ferry spawn,
// the ferry path, the normal QA route or a whole-island QA landing anchor.
//
//   node tools/check_street_detail_clearance.mjs [WORLD_DIR]   (default generated/world)
//
// Buffers come from tools/config/street-detail-zones.json and are rebuilt here
// from their own sources: the manifest spawn, the QA routes and the stairs in
// the building catalog as it is now, so a stair added after the last world
// generation is checked as well. The buffer shapes and the plan distance are the
// generator's own (streetDetailHardShapes, planDistance); what this check adds is
// the placeholder vegetation and a catalog read independent of the last build.
// Prints PASS or one FAIL line per intrusion.

import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  STREET_DETAIL_KINDS,
  STREET_DETAIL_LAYERS,
  loadStreetDetailStairFlights,
  loadStreetDetailZones,
  planDistance,
  streetDetailHardShapes,
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
  const spawn = manifest.initial_spawn.origin;
  const zones = streetDetailHardShapes(exclusions, [spawn[0], spawn[2]], loadStreetDetailStairFlights(projectRoot))
    .map((shape) => ({ name: shape.component, id: shape.source_id, points: shape.points, radius: shape.radius_m }));

  // Everything the switchable layers build when they are all on. Overhead lines
  // never reach the ground; ground rows (crossings, kerbs) are always-on surfaces.
  const items = [];
  for (const row of detail.rows) {
    const kind = STREET_DETAIL_KINDS[row.kind];
    if (row.status !== "placed" || !STREET_DETAIL_LAYERS.includes(row.layer) || kind.overhead) continue;
    const points = row.geometry === "point" ? [[row.position_m[0], row.position_m[2]]] : row.points_m.map((point) => [point[0], point[2]]);
    items.push({ id: row.id, layer: row.layer, points, radius: kind.footprint_radius_m });
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
  const stairs = zones.filter((zone) => zone.name === "stair").length;
  // A check with nothing to compare would pass untested.
  if (items.length === 0 || stairs === 0) failures.push(`nothing to check: ${items.length} items, ${stairs} stair flights`);
  for (const message of failures) console.log(`FAIL: ${message}`);
  if (failures.length > 0) process.exit(1);
  const byLayer = STREET_DETAIL_LAYERS.map((layer) => `${items.filter((item) => item.layer === layer).length} ${layer}`).join(", ");
  const closest = Object.entries(minimum).map(([name, value]) => `${name} ${value.toFixed(2)} m`).join(", ");
  console.log(`PASS: street detail with all layers on (${byLayer}) clears ${stairs} stair flights with their doors and approaches, the spawn and the QA corridors; closest: ${closest}`);
}

main();
