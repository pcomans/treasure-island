#!/usr/bin/env node
// Writes the cars' hero level (tools/lib/street-car-kit.mjs carHeroKitMeshes)
// as one binary glTF: game/resources/models/street/street_car_hero_kit.glb,
// four meshes per body (car_<body>_hero_body, _hero_glass, _hero_tyre,
// _hero_brake), positions, normals and the part/occlusion UVs, no materials.
// The desktop builds ship it; the web export leaves it out (export_presets.cfg)
// and draws the near level instead (street_clutter_kit.gd hero_level_enabled).
// The output is deterministic; rerun after changing the car kit and commit both.
//
//   node tools/build_street_car_hero_kit.mjs

import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { glbFromMeshes } from "./build_street_clutter_kit.mjs";
import { carHeroKitMeshes } from "./lib/street-car-kit.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
export const STREET_CAR_HERO_KIT_PATH = "game/resources/models/street/street_car_hero_kit.glb";

export function buildStreetCarHeroKitGlb() {
  return glbFromMeshes(carHeroKitMeshes(), { generator: "tools/build_street_car_hero_kit.mjs", scene: "street_car_hero_kit" });
}

function main() {
  const { glb, meshes } = buildStreetCarHeroKitGlb();
  const target = resolve(projectRoot, STREET_CAR_HERO_KIT_PATH);
  mkdirSync(dirname(target), { recursive: true });
  writeFileSync(target, glb);
  const triangles = meshes.reduce((sum, mesh) => sum + mesh.indices.length / 3, 0);
  console.log(`wrote ${STREET_CAR_HERO_KIT_PATH} (${glb.length} bytes, ${meshes.length} meshes, ${triangles} triangles)`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
