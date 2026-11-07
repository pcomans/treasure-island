#!/usr/bin/env node

import { mkdtempSync, readFileSync, readdirSync, rmSync, statSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { buildStreetClutterKitGlb, STREET_CLUTTER_KIT_PATH } from "./build_street_clutter_kit.mjs";
import { buildStreetYardKitGlb, STREET_YARD_KIT_PATH } from "./build_street_yard_kit.mjs";
import { buildGroundCoverMap, buildMarshMap, decodeGroundCoverPng, GROUND_COVER_MAP_PATH, MARSH_MAP_PATH } from "./lib/ground-cover-map.mjs";
import { buildWaterShoreMap, WATER_SHORE_MAP_PATH } from "./lib/water-shore-map.mjs";
import { invariant, sha256File, stableJson } from "./lib/world-contract.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(scriptDirectory, "..");

function run(script, args) {
  const result = spawnSync(process.execPath, [resolve(projectRoot, script), ...args], {
    cwd: projectRoot,
    encoding: "utf8",
    maxBuffer: 50 * 1024 * 1024,
  });
  if (result.error) throw result.error;
  invariant(result.status === 0, `${script} failed:\n${result.stdout}\n${result.stderr}`);
  return result.stdout.trim();
}

function list(root, current = root) {
  const files = [];
  for (const entry of readdirSync(current, { withFileTypes: true }).sort((left, right) => left.name.localeCompare(right.name))) {
    const path = join(current, entry.name);
    if (entry.isDirectory()) files.push(...list(root, path));
    else files.push(relative(root, path).replaceAll("\\", "/"));
  }
  return files;
}

function inventory(root) {
  return list(root).map((path) => ({
    path,
    bytes: statSync(resolve(root, path)).size,
    sha256: sha256File(resolve(root, path)),
  }));
}

function main() {
  const temporaryDirectory = mkdtempSync(join(tmpdir(), "ti-world-determinism-"));
  try {
    const first = resolve(temporaryDirectory, "first");
    const second = resolve(temporaryDirectory, "second");
    run("tools/build_godot_world.mjs", ["--output", first]);
    run("tools/validate_godot_world.mjs", [first]);
    run("tools/build_godot_world.mjs", ["--output", second]);
    run("tools/validate_godot_world.mjs", [second]);
    const firstInventory = inventory(first);
    const secondInventory = inventory(second);
    invariant(stableJson(firstInventory) === stableJson(secondInventory), "Clean generations differ by path, byte count, or hash");
    for (const file of firstInventory) {
      invariant(
        readFileSync(resolve(first, file.path)).equals(readFileSync(resolve(second, file.path))),
        `Clean generations differ byte-for-byte at ${file.path}`,
      );
    }
    // The committed world must be exactly what the sources produce. Only the
    // manifest's record of the local tool versions may differ.
    const committed = resolve(projectRoot, "generated/world");
    const withoutTools = (path) => {
      const manifest = JSON.parse(readFileSync(path, "utf8"));
      delete manifest.generator;
      return stableJson(manifest);
    };
    const committedFiles = list(committed).filter((path) => path !== ".gdignore");
    invariant(stableJson(committedFiles) === stableJson(firstInventory.map((file) => file.path)),
      "Committed generated/world has different files than a fresh build");
    for (const file of firstInventory) {
      const fresh = resolve(first, file.path);
      const kept = resolve(committed, file.path);
      invariant(
        file.path === "manifest.json"
          ? withoutTools(fresh) === withoutTools(kept)
          : readFileSync(fresh).equals(readFileSync(kept)),
        `Committed generated/world/${file.path} differs from a fresh build; regenerate with tools/build_godot_world.mjs`,
      );
    }
    // The committed street-clutter kit must be exactly what its generator writes:
    // the world rows take wheel positions and car sizes from the same kit module.
    const kit = buildStreetClutterKitGlb().glb;
    invariant(
      kit.equals(readFileSync(resolve(projectRoot, STREET_CLUTTER_KIT_PATH))),
      `Committed ${STREET_CLUTTER_KIT_PATH} differs from a fresh build; rebuild it with tools/build_street_clutter_kit.mjs`,
    );
    // Likewise the yard kit: the rows take its footprints from the same registry.
    const yardKit = buildStreetYardKitGlb().glb;
    invariant(
      yardKit.equals(readFileSync(resolve(projectRoot, STREET_YARD_KIT_PATH))),
      `Committed ${STREET_YARD_KIT_PATH} differs from a fresh build; rebuild it with tools/build_street_yard_kit.mjs`,
    );
    // And the ground-cover map: its pixels are what the tool draws from this
    // world and tools/config/ground-cover.json (compared decoded, so a zlib
    // version cannot fail it).
    const coverMap = buildGroundCoverMap({ projectRoot, worldRoot: first });
    const committedMap = decodeGroundCoverPng(readFileSync(resolve(projectRoot, GROUND_COVER_MAP_PATH)));
    invariant(
      committedMap.width === coverMap.grid.width && committedMap.height === coverMap.grid.height
        && Buffer.from(committedMap.rgba).equals(Buffer.from(coverMap.rgba)),
      `Committed ${GROUND_COVER_MAP_PATH} differs from a fresh draw; redraw it with tools/build_ground_cover_map.mjs`,
    );
    const marshMap = buildMarshMap({ projectRoot, worldRoot: first });
    const committedMarsh = decodeGroundCoverPng(readFileSync(resolve(projectRoot, MARSH_MAP_PATH)));
    invariant(
      committedMarsh.width === marshMap.grid.width && committedMarsh.height === marshMap.grid.height
        && Buffer.from(committedMarsh.rgba).equals(Buffer.from(marshMap.rgba)),
      `Committed ${MARSH_MAP_PATH} differs from a fresh draw; redraw it with tools/build_ground_cover_map.mjs`,
    );
    // And the water's shore map, drawn from the same world.
    const shoreMap = buildWaterShoreMap({ worldRoot: first });
    const committedShore = decodeGroundCoverPng(readFileSync(resolve(projectRoot, WATER_SHORE_MAP_PATH)));
    invariant(
      committedShore.width === shoreMap.grid.width && committedShore.height === shoreMap.grid.height
        && Buffer.from(committedShore.rgba).equals(Buffer.from(shoreMap.rgba)),
      `Committed ${WATER_SHORE_MAP_PATH} differs from a fresh draw; redraw it with tools/build_water_shore_map.mjs`,
    );
    const streetDetailPath = "street_detail.json";
    invariant(firstInventory.some((file) => file.path === streetDetailPath), "Clean generation omitted street_detail.json");
    const manifest = JSON.parse(readFileSync(resolve(first, "manifest.json"), "utf8"));
    process.stdout.write(stableJson({
      status: "deterministic",
      clean_generations: 2,
      files_compared: firstInventory.length,
      street_clutter_kit_bytes: kit.length,
      street_yard_kit_bytes: yardKit.length,
      ground_cover_map_cells: coverMap.grid.width * coverMap.grid.height,
      content_sha256: manifest.content_sha256,
      street_detail_sha256: firstInventory.find((file) => file.path === streetDetailPath).sha256,
    }));
  } finally {
    rmSync(temporaryDirectory, { recursive: true, force: true });
  }
}

main();
