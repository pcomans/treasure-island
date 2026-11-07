#!/usr/bin/env node
// Draws the bay water's shore map (tools/lib/water-shore-map.mjs) from the
// generated world and writes it to game/resources/textures/world/water/shore_map.png.
// Regenerating the world (tools/build_godot_world.mjs) redraws it too; the
// determinism check (tools/check_godot_world_determinism.mjs) fails while the
// committed map differs from a fresh draw.
//
//   node tools/build_water_shore_map.mjs [--world generated/world] [--output PATH]

import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { WATER_SHORE_MAP_PATH, writeWaterShoreMap } from "./lib/water-shore-map.mjs";
import { stableJson } from "./lib/world-contract.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");

function argument(name, fallback) {
  const index = process.argv.indexOf(name);
  return index >= 0 && index + 1 < process.argv.length ? process.argv[index + 1] : fallback;
}

const worldRoot = resolve(projectRoot, argument("--world", "generated/world"));
const output = resolve(projectRoot, argument("--output", WATER_SHORE_MAP_PATH));
const { map, bytes } = writeWaterShoreMap({ projectRoot, worldRoot, output });
process.stdout.write(`${stableJson({ status: "drawn", output, width: map.grid.width, height: map.grid.height, cell_m: map.grid.cell, bytes })}\n`);
