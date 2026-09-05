#!/usr/bin/env node

import { createHash } from "node:crypto";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(HERE, "../../..");
const IDS = Object.freeze([
  "w96665904", "w96665906", "w96665907", "w96665908", "w96665909",
  "w96665910", "w96665911", "w96665912", "w96665915", "w96665916",
  "w96665918", "w96665919", "w96665920", "w96665922", "w96665923",
]);
const PACKET_FILENAMES = Object.freeze({
  w96665904: "w96665904_1237_northpoint_drive.md",
  w96665906: "w96665906_1147_ozbourn_court.md",
  w96665907: "w96665907_1129_mason_court.md",
  w96665908: "w96665908_1203_bayside_drive.md",
  w96665909: "w96665909_1149_ozbourn_court.md",
  w96665910: "w96665910_1110_hutchins_court.md",
  w96665911: "w96665911_1229_northpoint_drive.md",
  w96665912: "w96665912_901_1304_avenue_b.md",
  w96665915: "w96665915_1109_keppler_court.md",
  w96665916: "w96665916_1242_northpoint_drive.md",
  w96665918: "w96665918_1310_gateview_avenue.md",
  w96665919: "w96665919_1116_hutchins_court.md",
  w96665920: "w96665920_1131_mason_court.md",
  w96665922: "w96665922_1114_hutchins_court.md",
  w96665923: "w96665923_1120_reeves_court.md",
});
const COMPONENT_READY_IDS = new Set(["w96665907", "w96665910", "w96665915", "w96665920", "w96665922"]);
const APPEARANCE_BLOCKED_IDS = new Set(["w96665923"]);
const PACKET_TIME_CATALOG_SNAPSHOT = Object.freeze({
  schema: "ti.facade-recognition-catalog/4",
  sha256: "2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311",
});
const PACKET_TIME_REGISTRY_SNAPSHOT = Object.freeze({
  schema: "ti.facade-runtime-registry/4",
  sha256: "acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af",
});
const PACKET_TIME_STATE = Object.freeze({ recognition_metric: "5/213" });
const AUTHORITY = Object.freeze({
  catalog: { path: "discovery/facades/facade-recognition-catalog.json", schema: "ti.facade-recognition-catalog/6" },
  inventory: { path: "discovery/FACADE_RECEIVER_INVENTORY.json", schema: "ti.facade-receiver-inventory/1", sha256: "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f" },
  registry: { path: "game/resources/facades/facade-runtime-registry.json", schema: "ti.facade-runtime-registry/6" },
  manifest: { path: "generated/world/manifest.json", schema: "ti.godot-world/2", sha256: "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3" },
  osm: { path: "data/osm/treasure-island-2026-08-27.osm", sha256: "3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549" },
});
const PRIOR_PACKET_DIRS = Object.freeze([
  "p1_reference_packets", "p2_reference_packets", "p3_reference_packets",
  "d1_reference_packets", "d2_reference_packets", "d3_reference_packets",
  "d4_reference_packets", "d5_reference_packets", "d6_reference_packets",
  "d7_reference_packets", "d8_reference_packets",
]);
const CARDINAL_16 = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];

function invariant(condition, message) { if (!condition) throw new Error(message); }
function absolute(path) { return resolve(ROOT, path); }
function readJson(path) { return JSON.parse(readFileSync(absolute(path), "utf8")); }
function sorted(value) {
  if (Array.isArray(value)) return value.map(sorted);
  if (value !== null && typeof value === "object") return Object.fromEntries(Object.entries(value).sort(([a], [b]) => a.localeCompare(b)).map(([key, child]) => [key, sorted(child)]));
  return value;
}
function sha256(value) { return createHash("sha256").update(value).digest("hex"); }
function stableSha256(value) { return sha256(`${JSON.stringify(sorted(value), null, 2)}\n`); }
function fileSha256(path) { return sha256(readFileSync(absolute(path))); }
function occurrences(text, token) { return text.split(token).length - 1; }

function priorPacketIds() {
  const ids = new Set();
  for (const directory of PRIOR_PACKET_DIRS) {
    const path = absolute(`discovery/facades/${directory}`);
    invariant(existsSync(path), `Missing prior packet directory ${directory}`);
    for (const filename of readdirSync(path)) {
      if (filename === "README.md" || !filename.endsWith(".md")) continue;
      const match = filename.match(/^([rw]\d+)/u);
      invariant(match, `Prior packet filename lacks source key: ${directory}/${filename}`);
      ids.add(match[1]);
    }
  }
  return ids;
}

function ranges(indices) {
  const pieces = [];
  let start = indices[0];
  let end = start;
  for (const value of indices.slice(1)) {
    if (value === end + 1) end = value;
    else { pieces.push(start === end ? `${start}` : `${start}–${end}`); start = value; end = value; }
  }
  pieces.push(start === end ? `${start}` : `${start}–${end}`);
  return pieces.join(",");
}

function facingPartition(record) {
  const groups = new Map();
  const count = record.vertices.length / 12;
  invariant(Number.isInteger(count) && record.normals.length === record.vertices.length, `${record.object_key} malformed wall quads`);
  for (let run = 0; run < count; run += 1) {
    const offset = run * 12;
    const azimuth = (Math.atan2(-record.normals[offset], record.normals[offset + 2]) * 180 / Math.PI + 360) % 360;
    const cardinal = CARDINAL_16[Math.round(azimuth / 22.5) % CARDINAL_16.length];
    if (!groups.has(cardinal)) groups.set(cardinal, { azimuths: [], indices: [] });
    groups.get(cardinal).azimuths.push(azimuth);
    groups.get(cardinal).indices.push(run);
  }
  return [...groups.entries()].sort(([, a], [, b]) => Math.min(...a.azimuths) - Math.min(...b.azimuths)).map(([cardinal, group]) => ({
    cardinal, min: Number(Math.min(...group.azimuths).toFixed(1)), max: Number(Math.max(...group.azimuths).toFixed(1)), ranges: ranges(group.indices),
  }));
}

function formattedFacing(partition) {
  return partition.map(({ cardinal, min, max, ranges: runRanges }) => `${cardinal} \`${min.toFixed(1)}${min === max ? "" : `–${max.toFixed(1)}`}°\`: \`${runRanges}\``).join("; ");
}

function visiblePerimeter(record) {
  let total = 0;
  for (let offset = 0; offset < record.vertices.length; offset += 12) total += Math.hypot(record.vertices[offset + 3] - record.vertices[offset], record.vertices[offset + 5] - record.vertices[offset + 2]);
  return total;
}

function contracts() {
  const catalog = readJson(AUTHORITY.catalog.path);
  const inventory = readJson(AUTHORITY.inventory.path);
  const registry = readJson(AUTHORITY.registry.path);
  const logical = readJson("generated/world/logical-objects.json");
  const priorIds = priorPacketIds();
  invariant(priorIds.size === 136, `Expected 136 unique prior packet IDs, found ${priorIds.size}`);
  const derivedCatalog = catalog.units.filter((unit) => unit.unit_kind === "standalone_building" && !priorIds.has(unit.anchor_source_key)).slice(0, IDS.length).map((unit) => unit.anchor_source_key);
  const derivedRegistry = registry.units.filter((unit) => unit.unit_kind === "standalone_building" && !priorIds.has(unit.source_records[0]?.source_key)).slice(0, IDS.length).map((unit) => unit.source_records[0]?.source_key);
  invariant(JSON.stringify(derivedCatalog) === JSON.stringify(IDS), `D9 current catalog cohort/order drifted: ${derivedCatalog.join(", ")}`);
  invariant(JSON.stringify(derivedRegistry) === JSON.stringify(IDS), `D9 current registry cohort/order drifted: ${derivedRegistry.join(", ")}`);
  const bySource = new Map(inventory.objects.map((object) => [object.source.source_key, object]));
  const catalogByUnit = new Map(catalog.units.map((unit) => [unit.unit_id, unit]));
  const byUnit = new Map(registry.units.map((unit) => [unit.unit_id, unit]));
  const byLogical = new Map(logical.objects.map((object) => [object.logical_object_key, object]));
  return IDS.map((sourceKey) => {
    const object = bySource.get(sourceKey);
    invariant(object?.footprint_relationship.kind === "standalone_building_footprint", `${sourceKey} is not standalone`);
    invariant(object.footprint_relationship.part_source_keys.length === 0, `${sourceKey} unexpectedly owns part children`);
    const logicalKey = `building:${sourceKey}`;
    const wallKey = `${logicalKey}:wall`;
    const roofKey = `${logicalKey}:roof`;
    invariant(JSON.stringify(object.generated_receiver.direct_wall_object_keys) === JSON.stringify([wallKey]), `${sourceKey} wall binding drifted`);
    invariant(JSON.stringify(object.generated_receiver.direct_roof_object_keys) === JSON.stringify([roofKey]), `${sourceKey} roof binding drifted`);
    const catalogUnit = catalogByUnit.get(`physical-building:${sourceKey}`);
    invariant(catalogUnit?.anchor_source_key === sourceKey, `${sourceKey} current catalog unit binding drifted`);
    invariant(JSON.stringify(catalogUnit.receiver_keys) === JSON.stringify([wallKey]), `${sourceKey} current catalog receiver binding drifted`);
    const unit = byUnit.get(`physical-building:${sourceKey}`);
    invariant(unit?.direct_receivers.length === 1, `${sourceKey} must have one direct facade receiver`);
    const receiver = unit.direct_receivers[0];
    invariant(receiver.receiver_key === wallKey, `${sourceKey} registry receiver drifted`);
    const chunkPath = `generated/world/chunks/${receiver.chunk_id}.json`;
    const chunk = readJson(chunkPath);
    const wall = chunk.records.find((record) => record.object_key === wallKey);
    const roof = chunk.records.find((record) => record.object_key === roofKey);
    invariant(wall && roof, `${sourceKey} wall/roof records missing`);
    const wallGeometryHash = stableSha256({ flat_base_elevation_m: wall.flat_base_elevation_m, indices: wall.indices, normals: wall.normals, top_elevation_m: wall.top_elevation_m, uvs: wall.uvs, vertices: wall.vertices });
    invariant(wallGeometryHash === receiver.geometry_sha256, `${sourceKey} wall geometry hash mismatch`);
    invariant(stableSha256(wall) === receiver.record_sha256, `${sourceKey} wall record hash mismatch`);
    invariant(fileSha256(chunkPath) === receiver.chunk_sha256, `${sourceKey} chunk hash mismatch`);
    const logicalObject = byLogical.get(logicalKey);
    invariant(logicalObject?.source_geometry?.length === 1, `${sourceKey} source geometry is not singular`);
    return { sourceKey, object, receiver, wall, logicalObject, logicalKey, wallKey, roofKey, chunkPath, wallGeometryHash, partition: facingPartition(wall), visible: visiblePerimeter(wall) };
  });
}

for (const authority of Object.values(AUTHORITY)) {
  if (authority.schema) invariant(readJson(authority.path).schema_version === authority.schema, `${authority.path} schema drifted`);
  if (authority.sha256) invariant(fileSha256(authority.path) === authority.sha256, `${authority.path} SHA-256 drifted`);
}
invariant(
  PACKET_TIME_CATALOG_SNAPSHOT.schema === "ti.facade-recognition-catalog/4"
    && AUTHORITY.catalog.schema === "ti.facade-recognition-catalog/6"
    && PACKET_TIME_REGISTRY_SNAPSHOT.schema === "ti.facade-runtime-registry/4"
    && AUTHORITY.registry.schema === "ti.facade-runtime-registry/6",
  "D9 packet-time v4 receipts and current v6 authorities must remain explicitly separate",
);
const localContracts = contracts();
const readme = readFileSync(resolve(HERE, "README.md"), "utf8");
const packetTimeCatalogRow = `| D9 packet-time catalog snapshot receipt | \`${PACKET_TIME_CATALOG_SNAPSHOT.schema}\`; \`${PACKET_TIME_CATALOG_SNAPSHOT.sha256}\` | immutable packet-time provenance; same bytes as the then-current catalog at seal time |`;
const packetTimeRow = `| D9 packet-time registry snapshot receipt | \`${PACKET_TIME_REGISTRY_SNAPSHOT.schema}\`; \`${PACKET_TIME_REGISTRY_SNAPSHOT.sha256}\` | immutable packet-time provenance; same bytes as the then-current registry at seal time |`;
const metricRow = `| D9 packet-time recognition rollup | \`${PACKET_TIME_STATE.recognition_metric}\` | immutable five-unit acceptance state at the v4 authority boundary; not a claim about current compiler output |`;
const currentCatalogRow = `| \`${AUTHORITY.catalog.path}\` (current checkout) | \`${AUTHORITY.catalog.schema}\`; SHA-256 emitted by validator | used only to rederive the exact 15-ID cohort and order |`;
const currentRow = `| \`${AUTHORITY.registry.path}\` (current checkout) | \`${AUTHORITY.registry.schema}\`; SHA-256 emitted by validator | used only to verify those 15 current direct bindings; global counts and recognition rollup remain compiler-owned |`;
invariant(readme.includes(packetTimeCatalogRow), "README lost exact D9 packet-time catalog receipt");
invariant(readme.includes(packetTimeRow), "README lost exact D9 packet-time registry receipt");
invariant(readme.includes(metricRow), "README lost historical D9 packet-time recognition rollup");
invariant(readme.includes(currentCatalogRow), "README lost separately labeled current catalog authority");
invariant(readme.includes(currentRow), "README lost separately labeled current registry authority");

if (process.argv.includes("--dump-contracts")) {
  process.stdout.write(`${JSON.stringify(localContracts.map(({ sourceKey, object, receiver, wall, logicalObject, wallGeometryHash, partition, visible }) => ({
    source_key: sourceKey, osm_version: object.source.osm_version, osm_timestamp: object.source.osm_timestamp, tags: object.source.tags,
    chunk_id: receiver.chunk_id, area_m2: object.source_geometry.serialized_area_m2, height_m: object.current_generated_massing.height_m,
    base_m: wall.flat_base_elevation_m, top_m: wall.top_elevation_m, serialized_perimeter_m: logicalObject.source_geometry[0].serialization_perimeter_m,
    visible_perimeter_m: visible, run_count: receiver.run_count, facing_partition: partition, source_geometry_sha256: object.source_geometry.geometry_sha256,
    wall_geometry_sha256: wallGeometryHash, wall_record_sha256: stableSha256(wall), chunk_sha256: fileSha256(`generated/world/chunks/${receiver.chunk_id}.json`),
  })), null, 2)}\n`);
  process.exit(0);
}

const expectedFiles = new Set(["README.md", "validate_d9_packets.mjs", ...Object.values(PACKET_FILENAMES)]);
const actualFiles = readdirSync(HERE);
invariant(actualFiles.length === expectedFiles.size, `Expected ${expectedFiles.size} D9 files, found ${actualFiles.length}`);
for (const filename of actualFiles) invariant(expectedFiles.has(filename), `Unexpected D9 file (including binary/image): ${filename}`);

let fieldChecks = 0;
let facingChecks = 0;
let links = 0;
let readySeen = 0;
let componentSeen = 0;
let blockedSeen = 0;
for (const contract of localContracts) {
  const { sourceKey, object, receiver, wall, logicalObject, wallGeometryHash, partition, visible } = contract;
  const filename = PACKET_FILENAMES[sourceKey];
  const candidates = actualFiles.filter((candidate) => candidate.startsWith(`${sourceKey}_`) && candidate.endsWith(".md"));
  invariant(candidates.length === 1 && candidates[0] === filename, `${sourceKey} packet filename drifted`);
  const packet = readFileSync(resolve(HERE, filename), "utf8");
  const tags = object.source.tags;
  const fieldTokens = [
    sourceKey, `v${object.source.osm_version}`, object.source.osm_timestamp,
    `\`addr:housenumber=${tags["addr:housenumber"]}\``, tags["addr:street"] ? `\`addr:street=${tags["addr:street"]}\`` : "current 901 Avenue B", `\`building=${tags.building}\``, `\`height=${tags.height}\``,
    `building:${sourceKey}`, `building:${sourceKey}:wall`, `building:${sourceKey}:roof`, receiver.chunk_id,
    `area \`${object.source_geometry.serialized_area_m2.toFixed(3)} m²\``, `height \`${Number(object.current_generated_massing.height_m).toFixed(0)} m\``,
    `NAVD88 base/top \`${wall.flat_base_elevation_m.toFixed(3)} / ${wall.top_elevation_m.toFixed(3)} m\``,
    `serialized \`${logicalObject.source_geometry[0].serialization_perimeter_m.toFixed(3)} m\`; visible \`${visible.toFixed(3)} m\`; \`${receiver.run_count}\` runs`,
    object.source_geometry.geometry_sha256, wallGeometryHash, stableSha256(wall), fileSha256(contract.chunkPath),
    `wall key \`${object.runtime_material_assignment.wall_material_key}\`, set \`${object.runtime_material_assignment.wall_texture_set}\`; roof key \`${object.runtime_material_assignment.roof_material_key}\`, set \`${object.runtime_material_assignment.roof_texture_set}\``,
  ];
  invariant(fieldTokens.length === 20, `${sourceKey} internal field-check count drifted`);
  for (const token of fieldTokens) { invariant(packet.includes(token), `${filename} lacks exact field token ${token}`); fieldChecks += 1; }
  for (const [key, value] of Object.entries(tags)) invariant(packet.includes(`\`${key}=${value}\``), `${filename} lacks source tag ${key}=${value}`);
  invariant(packet.includes(`| Facing-run partition | ${formattedFacing(partition)} |`), `${filename} facing-run partition drifted`);
  facingChecks += partition.length;
  for (const heading of ["## Exact receiver contract", "## Identity, lifecycle, and public-side appearance", "## Recognition boundary and handoff"]) invariant(packet.includes(heading), `${filename} lacks ${heading}`);
  invariant(packet.includes("Close confusion:"), `${filename} lacks a confusion set`);
  invariant(/blocker/iu.test(packet), `${filename} lacks a blocker boundary`);
  invariant(/No\s+panorama\s+pixels\s+are\s+retained/iu.test(packet), `${filename} lacks pixel-retention boundary`);
  invariant(packet.includes(PACKET_TIME_REGISTRY_SNAPSHOT.sha256), `${filename} lacks packet-time registry provenance`);
  invariant(occurrences(readme, `](${filename})`) === 1, `README must link ${filename} exactly once`);
  links += 1;
  if (APPEARANCE_BLOCKED_IDS.has(sourceKey)) { invariant(/^Readiness: \*\*appearance-blocked\*\*/mu.test(packet), `${filename} blocked readiness drifted`); blockedSeen += 1; }
  else if (COMPONENT_READY_IDS.has(sourceKey)) { invariant(/^Readiness: \*\*component\//mu.test(packet), `${filename} component readiness drifted`); componentSeen += 1; }
  else { invariant(/^Readiness: \*\*target-side (?:historical )?prototype-ready/mu.test(packet), `${filename} prototype readiness drifted`); readySeen += 1; }
}

invariant(readySeen === 9 && componentSeen === 5 && blockedSeen === 1, `Readiness counts drifted: ${readySeen}/${componentSeen}/${blockedSeen}`);
invariant(fieldChecks === 300 && facingChecks === 60 && links === 15, `Audit totals drifted: ${fieldChecks}/${facingChecks}/${links}`);
invariant(readme.includes("Totals: **9 prototype-ready / 5 component-ready / 1 appearance-blocked**"), "README readiness totals drifted");
for (const authority of Object.values(AUTHORITY)) {
  if (authority.sha256) invariant(readme.includes(authority.sha256), `README lacks authority SHA ${authority.sha256}`);
}
invariant(readme.includes(PACKET_TIME_CATALOG_SNAPSHOT.sha256), `README lacks packet-time catalog SHA ${PACKET_TIME_CATALOG_SNAPSHOT.sha256}`);
invariant(readme.includes(PACKET_TIME_REGISTRY_SNAPSHOT.sha256), `README lacks packet-time registry SHA ${PACKET_TIME_REGISTRY_SNAPSHOT.sha256}`);
for (const sourceId of ["CITY-EAS", "CITY-XWALK", "NAVY-SITE12-2015", "CITY-HOUSING-2017", "GOOGLE-SV"]) invariant(readme.includes(`\`${sourceId}\``), `README lacks source ${sourceId}`);

process.stdout.write(`D9 packet audit: PASS (15 IDs/order/direct bindings, 45 recomputed hashes, ${fieldChecks} exact field checks, ${facingChecks} facing partitions, ${links} packet links, readiness ${readySeen}/${componentSeen}/${blockedSeen}; immutable packet-time catalog/registry ${PACKET_TIME_CATALOG_SNAPSHOT.sha256}/${PACKET_TIME_REGISTRY_SNAPSHOT.sha256}, ${PACKET_TIME_STATE.recognition_metric}; current v6 catalog/registry ${fileSha256(AUTHORITY.catalog.path)}/${fileSha256(AUTHORITY.registry.path)})\n`);
