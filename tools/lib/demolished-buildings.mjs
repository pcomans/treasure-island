// Demolished buildings: an owner-approved exception (2026-11-04) to the OSM time
// setting and the building inventory. A building the dated imagery shows
// demolished is left out of the generated world: it keeps its coverage row (with
// the status "demolished" and no geometry), its catalog unit is marked
// demolished, and nothing is built, scored or fitted for it. The frozen OSM
// snapshot is not edited. Each entry names the OSM building, the dated evidence
// and the approval (tools/config/demolished-buildings.json).

import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

import { invariant, sha256File } from "./world-contract.mjs";

export const DEMOLISHED_BUILDINGS_PATH = "tools/config/demolished-buildings.json";
export const DEMOLISHED_BUILDINGS_SCHEMA = "ti.demolished-buildings/1";
export const DEMOLISHED_STATUS = "demolished";
const ENTRY_FIELDS = Object.freeze(["approval", "evidence", "name", "source_key"]);

// The validated config: {entries (sorted by source key), byKey, descriptor}.
export function loadDemolishedBuildings(projectRoot) {
  const path = resolve(projectRoot, DEMOLISHED_BUILDINGS_PATH);
  invariant(existsSync(path), `Demolished buildings config is missing: ${DEMOLISHED_BUILDINGS_PATH}`);
  const config = JSON.parse(readFileSync(path, "utf8"));
  invariant(config.schema_version === DEMOLISHED_BUILDINGS_SCHEMA, "Demolished buildings schema drift");
  invariant(Array.isArray(config.notes) && config.notes.every((note) => typeof note === "string"), "Demolished buildings need notes");
  invariant(Array.isArray(config.entries), "Demolished buildings need an entries list");
  const byKey = new Map();
  for (const entry of config.entries) {
    const label = `Demolished building ${entry?.source_key}`;
    invariant(JSON.stringify(Object.keys(entry ?? {}).sort()) === JSON.stringify(ENTRY_FIELDS), `${label} must have exactly ${ENTRY_FIELDS.join(", ")}`);
    invariant(/^w\d+$/u.test(entry.source_key), `${label} needs an OSM way key`);
    invariant(!byKey.has(entry.source_key), `${label} is listed twice`);
    for (const field of ["name", "evidence", "approval"]) invariant(typeof entry[field] === "string" && entry[field].trim() !== "", `${label} needs ${field}`);
    byKey.set(entry.source_key, entry);
  }
  const entries = [...byKey.values()].sort((left, right) => (left.source_key < right.source_key ? -1 : left.source_key > right.source_key ? 1 : 0));
  return {
    entries,
    byKey,
    descriptor: { path: DEMOLISHED_BUILDINGS_PATH, sha256: sha256File(path), source_keys: entries.map((entry) => entry.source_key) },
  };
}
