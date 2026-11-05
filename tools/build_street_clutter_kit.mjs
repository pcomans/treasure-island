#!/usr/bin/env node
// Writes the street-clutter kit (tools/lib/street-clutter-kit.mjs) as one
// binary glTF: game/resources/models/street/street_clutter_kit.glb, one node
// and mesh per kit mesh (car_<body>_lod<n>, <prop>_lod<n>), positions, normals
// and the part/occlusion UVs, no materials (the runtime shader colours them).
// The output is deterministic; rerun after changing the kit and commit both.
//
//   node tools/build_street_clutter_kit.mjs

import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { clutterKitMeshes } from "./lib/street-clutter-kit.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
export const STREET_CLUTTER_KIT_PATH = "game/resources/models/street/street_clutter_kit.glb";

const ARRAY_BUFFER = 34962;
const ELEMENT_ARRAY_BUFFER = 34963;
const FLOAT = 5126;
const UNSIGNED_SHORT = 5123;
const UNSIGNED_INT = 5125;

export function buildStreetClutterKitGlb() {
  return glbFromMeshes(clutterKitMeshes(), { generator: "tools/build_street_clutter_kit.mjs", scene: "street_clutter_kit" });
}

// One binary glTF of named meshes ({name, positions, normals, uvs, indices}),
// one node each; also used for the yard kit (tools/build_street_yard_kit.mjs).
export function glbFromMeshes(meshes, { generator, scene }) {
  const chunks = [];
  let byteLength = 0;
  const bufferViews = [];
  const accessors = [];
  const align = () => {
    const pad = (4 - (byteLength % 4)) % 4;
    if (pad > 0) {
      chunks.push(Buffer.alloc(pad));
      byteLength += pad;
    }
  };
  const addView = (buffer, target) => {
    align();
    bufferViews.push({ buffer: 0, byteOffset: byteLength, byteLength: buffer.length, target });
    chunks.push(buffer);
    byteLength += buffer.length;
    return bufferViews.length - 1;
  };
  const floats = (values) => Buffer.from(new Float32Array(values).buffer);
  const gltfMeshes = [];
  const nodes = [];
  for (const mesh of meshes) {
    const count = mesh.positions.length / 3;
    const min = [Infinity, Infinity, Infinity];
    const max = [-Infinity, -Infinity, -Infinity];
    for (let i = 0; i < count; i += 1) {
      for (let k = 0; k < 3; k += 1) {
        const value = Math.fround(mesh.positions[i * 3 + k]);
        min[k] = Math.min(min[k], value);
        max[k] = Math.max(max[k], value);
      }
    }
    accessors.push({ bufferView: addView(floats(mesh.positions), ARRAY_BUFFER), componentType: FLOAT, count, type: "VEC3", min, max });
    const position = accessors.length - 1;
    accessors.push({ bufferView: addView(floats(mesh.normals), ARRAY_BUFFER), componentType: FLOAT, count, type: "VEC3" });
    const normal = accessors.length - 1;
    accessors.push({ bufferView: addView(floats(mesh.uvs), ARRAY_BUFFER), componentType: FLOAT, count, type: "VEC2" });
    const uv = accessors.length - 1;
    const wide = count > 65535;
    const indexBuffer = wide ? Buffer.from(new Uint32Array(mesh.indices).buffer) : Buffer.from(new Uint16Array(mesh.indices).buffer);
    accessors.push({ bufferView: addView(indexBuffer, ELEMENT_ARRAY_BUFFER), componentType: wide ? UNSIGNED_INT : UNSIGNED_SHORT, count: mesh.indices.length, type: "SCALAR" });
    const indices = accessors.length - 1;
    gltfMeshes.push({ name: mesh.name, primitives: [{ attributes: { POSITION: position, NORMAL: normal, TEXCOORD_0: uv }, indices, mode: 4 }] });
    nodes.push({ name: mesh.name, mesh: gltfMeshes.length - 1 });
  }
  align();
  const json = {
    asset: { version: "2.0", generator },
    scene: 0,
    scenes: [{ name: scene, nodes: nodes.map((_, index) => index) }],
    nodes,
    meshes: gltfMeshes,
    accessors,
    bufferViews,
    buffers: [{ byteLength }],
  };
  let jsonBuffer = Buffer.from(JSON.stringify(json), "utf8");
  const jsonPad = (4 - (jsonBuffer.length % 4)) % 4;
  if (jsonPad > 0) jsonBuffer = Buffer.concat([jsonBuffer, Buffer.alloc(jsonPad, 0x20)]);
  const bin = Buffer.concat(chunks);
  const header = Buffer.alloc(12);
  header.writeUInt32LE(0x46546c67, 0);
  header.writeUInt32LE(2, 4);
  header.writeUInt32LE(12 + 8 + jsonBuffer.length + 8 + bin.length, 8);
  const jsonHeader = Buffer.alloc(8);
  jsonHeader.writeUInt32LE(jsonBuffer.length, 0);
  jsonHeader.writeUInt32LE(0x4e4f534a, 4);
  const binHeader = Buffer.alloc(8);
  binHeader.writeUInt32LE(bin.length, 0);
  binHeader.writeUInt32LE(0x004e4942, 4);
  return { glb: Buffer.concat([header, jsonHeader, jsonBuffer, binHeader, bin]), meshes };
}

function main() {
  const { glb, meshes } = buildStreetClutterKitGlb();
  const target = resolve(projectRoot, STREET_CLUTTER_KIT_PATH);
  mkdirSync(dirname(target), { recursive: true });
  writeFileSync(target, glb);
  const triangles = meshes.map((mesh) => `${mesh.name} ${mesh.indices.length / 3}`).join(", ");
  console.log(`wrote ${STREET_CLUTTER_KIT_PATH} (${glb.length} bytes): ${triangles}`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
