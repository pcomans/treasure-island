#!/usr/bin/env node
// Draws the ground-cover map (tools/lib/ground-cover-map.mjs) from the
// generated world and tools/config/ground-cover.json, and writes it to
// game/resources/textures/world/ground_cover/cover_map.png. Run it after
// regenerating the world or changing the config; the determinism check
// (tools/check_godot_world_determinism.mjs) fails while the committed map
// differs from a fresh draw.
//
//   node tools/build_ground_cover_map.mjs [--world generated/world] [--output PATH]

import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { buildGroundCoverMap, encodeGroundCoverPng, GROUND_COVER_MAP_PATH } from "./lib/ground-cover-map.mjs";
import { stableJson } from "./lib/world-contract.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");

function argument(name, fallback) {
  const index = process.argv.indexOf(name);
  return index >= 0 && index + 1 < process.argv.length ? process.argv[index + 1] : fallback;
}

const worldRoot = resolve(projectRoot, argument("--world", "generated/world"));
const output = resolve(projectRoot, argument("--output", GROUND_COVER_MAP_PATH));
const map = buildGroundCoverMap({ projectRoot, worldRoot });
const png = encodeGroundCoverPng(map.grid.width, map.grid.height, map.rgba);
mkdirSync(dirname(output), { recursive: true });
writeFileSync(output, png);
process.stdout.write(`${stableJson({ status: "drawn", output, width: map.grid.width, height: map.grid.height, cell_m: map.grid.cell, bytes: png.length, rules: map.rules })}\n`);
