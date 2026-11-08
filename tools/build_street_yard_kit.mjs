#!/usr/bin/env node
// Writes the yard kit (tools/lib/street-yard-meshes.mjs) as one binary glTF:
// game/resources/models/street/street_yard_kit.glb, one node and mesh per kit
// mesh (<name>_lod0, <name>_lod1), positions, normals and the part/occlusion
// UVs, no materials (game/resources/materials/world/street/street_yard.gdshader
// colours them). The output is deterministic; rerun after changing the kit
// and commit both.
//
//   node tools/build_street_yard_kit.mjs

import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { glbFromMeshes } from "./build_street_clutter_kit.mjs";
import { yardKitMeshes } from "./lib/street-yard-meshes.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
export const STREET_YARD_KIT_PATH = "game/resources/models/street/street_yard_kit.glb";

export function buildStreetYardKitGlb() {
  return glbFromMeshes(yardKitMeshes(), { generator: "tools/build_street_yard_kit.mjs", scene: "street_yard_kit" });
}

function main() {
  const { glb, meshes } = buildStreetYardKitGlb();
  const target = resolve(projectRoot, STREET_YARD_KIT_PATH);
  mkdirSync(dirname(target), { recursive: true });
  writeFileSync(target, glb);
  const solid = meshes.filter((mesh) => !mesh.marker);
  const triangles = solid.reduce((sum, mesh) => sum + mesh.indices.length / 3, 0);
  console.log(`wrote ${STREET_YARD_KIT_PATH} (${glb.length} bytes, ${solid.length} meshes, ${meshes.length - solid.length} markers, ${triangles} triangles)`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
