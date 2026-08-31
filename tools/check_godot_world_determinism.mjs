#!/usr/bin/env node

import { mkdtempSync, readFileSync, readdirSync, rmSync, statSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

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
    const vegetationPath = "vegetation.json";
    invariant(firstInventory.some((file) => file.path === vegetationPath), "Clean generation omitted vegetation.json");
    invariant(
      readFileSync(resolve(first, vegetationPath)).equals(readFileSync(resolve(second, vegetationPath))),
      "Clean generations differ byte-for-byte at vegetation.json",
    );
    const manifest = JSON.parse(readFileSync(resolve(first, "manifest.json"), "utf8"));
    process.stdout.write(stableJson({
      status: "deterministic",
      clean_generations: 2,
      files_compared: firstInventory.length,
      content_sha256: manifest.content_sha256,
      vegetation_sha256: firstInventory.find((file) => file.path === vegetationPath).sha256,
    }));
  } finally {
    rmSync(temporaryDirectory, { recursive: true, force: true });
  }
}

main();
