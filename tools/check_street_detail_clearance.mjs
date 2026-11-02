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
// generation is checked as well. Prints PASS or one FAIL line per intrusion.

import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  STREET_DETAIL_INPUTS,
  STREET_DETAIL_KINDS,
  STREET_DETAIL_LAYERS,
  loadStreetDetailZones,
} from "./lib/street-detail-generation.mjs";
import { VEGETATION_QA_CORRIDORS } from "./lib/vegetation-generation.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const worldRoot = resolve(projectRoot, process.argv[2] ?? "generated/world");

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

function segmentDistance(point, start, end) {
  const dx = end[0] - start[0];
  const dz = end[1] - start[1];
  const lengthSquared = dx * dx + dz * dz;
  const t = lengthSquared === 0 ? 0 : Math.max(0, Math.min(1, ((point[0] - start[0]) * dx + (point[1] - start[1]) * dz) / lengthSquared));
  return Math.hypot(point[0] - start[0] - dx * t, point[1] - start[1] - dz * t);
}

function cross(a, b, c) {
  return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]);
}

// Plan distance between two polylines (a single point is a one-vertex polyline).
function distance(left, right) {
  if (left.length === 1 && right.length === 1) return Math.hypot(left[0][0] - right[0][0], left[0][1] - right[0][1]);
  if (left.length === 1 || right.length === 1) {
    const [point, line] = left.length === 1 ? [left[0], right] : [right[0], left];
    let minimum = Infinity;
    for (let index = 1; index < line.length; index += 1) minimum = Math.min(minimum, segmentDistance(point, line[index - 1], line[index]));
    return minimum;
  }
  let minimum = Infinity;
  for (let i = 1; i < left.length; i += 1) {
    for (let j = 1; j < right.length; j += 1) {
      const [a, b, c, d] = [left[i - 1], left[i], right[j - 1], right[j]];
      if (Math.sign(cross(c, d, a)) * Math.sign(cross(c, d, b)) < 0 && Math.sign(cross(a, b, c)) * Math.sign(cross(a, b, d)) < 0) return 0;
      minimum = Math.min(minimum, segmentDistance(a, c, d), segmentDistance(b, c, d), segmentDistance(c, a, b), segmentDistance(d, a, b));
    }
  }
  return minimum;
}

function buffers(exclusions, manifest, catalog) {
  const spawn = manifest.initial_spawn.origin;
  const list = [
    { name: "spawn", id: "ferry spawn", points: [[spawn[0], spawn[2]]], radius: exclusions.spawn_radius_m },
    { name: "ferry path", id: "ferry_arrival_path", points: VEGETATION_QA_CORRIDORS.ferry_arrival_path, radius: exclusions.ferry_path_half_width_m },
    { name: "QA route", id: "normal_qa_route", points: VEGETATION_QA_CORRIDORS.normal_qa_route, radius: exclusions.qa_route_half_width_m },
  ];
  VEGETATION_QA_CORRIDORS.whole_island_qa_route.slice(1).forEach((anchor, index) => {
    list.push({ name: "whole-island QA anchor", id: `anchor ${index + 1}`, points: [anchor], radius: exclusions.whole_island_anchor_radius_m });
  });
  for (const unit of catalog.units) {
    (unit.stairs ?? []).forEach(({ bottom, top }, index) => {
      const id = `${unit.anchor_source_key} stair ${index}`;
      const run = Math.hypot(bottom[0] - top[0], bottom[1] - top[1]);
      const outward = [(bottom[0] - top[0]) / run, (bottom[1] - top[1]) / run];
      list.push({ name: "stair", id, points: [bottom, top], radius: exclusions.stair_half_width_m });
      list.push({ name: "door", id, points: [top], radius: exclusions.door_radius_m });
      list.push({
        name: "approach",
        id,
        points: [bottom, [bottom[0] + outward[0] * exclusions.approach_length_m, bottom[1] + outward[1] * exclusions.approach_length_m]],
        radius: exclusions.approach_half_width_m,
      });
    });
  }
  return list;
}

function main() {
  const manifest = readJson(resolve(worldRoot, "manifest.json"));
  const detail = readJson(resolve(worldRoot, manifest.street_detail.path));
  const vegetation = readJson(resolve(worldRoot, manifest.vegetation.path));
  const exclusions = loadStreetDetailZones(projectRoot).exclusions;
  const catalog = readJson(resolve(projectRoot, STREET_DETAIL_INPUTS.stair_catalog));
  const zones = buffers(exclusions, manifest, catalog);

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
      const clearance = distance(item.points, zone.points) - item.radius;
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
