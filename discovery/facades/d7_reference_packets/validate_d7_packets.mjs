#!/usr/bin/env node

import { createHash } from "node:crypto";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(HERE, "../../..");

const IDS = Object.freeze([
  "w96215669",
  "w96215670",
  "w96215671",
  "w96215672",
  "w96215673",
  "w96215674",
  "w96215676",
  "w96215677",
  "w96215678",
  "w96215680",
  "w96215682",
  "w96215685",
  "w96215688",
  "w96215690",
  "w96215691",
]);

const PACKET_FILENAMES = Object.freeze({
  w96215669: "w96215669_1238_northpoint_drive.md",
  w96215670: "w96215670_1246_1397_gateview_court.md",
  w96215671: "w96215671_1244_northpoint_drive.md",
  w96215672: "w96215672_1201_bayside_drive.md",
  w96215673: "w96215673_1232_northpoint_drive.md",
  w96215674: "w96215674_1241_northpoint_drive.md",
  w96215676: "w96215676_1143_ozbourn_court.md",
  w96215677: "w96215677_1206_mariner_drive.md",
  w96215678: "w96215678_1205_bayside_drive.md",
  w96215680: "w96215680_1219_mariner_drive.md",
  w96215682: "w96215682_1221_mariner_drive.md",
  w96215685: "w96215685_1226_bayside_drive.md",
  w96215688: "w96215688_1240_northpoint_drive.md",
  w96215690: "w96215690_1141_ozbourn_court.md",
  w96215691: "w96215691_1204_mariner_drive.md",
});

const COMPONENT_READY_IDS = Object.freeze(new Set(["w96215671", "w96215690"]));

const PACKET_TIME_REGISTRY_SNAPSHOT = Object.freeze({
  schema: "ti.facade-runtime-registry/4",
  sha256: "c60e20fb625fa98809975f08357370d71c330443a7546d88fadfcd7df3584d19",
  validation: "recorded_receipt_only_not_current_file_bytes",
});

const EXPECTED_ACCEPTED_PHYSICAL_UNIT_IDS = Object.freeze([
  "physical-building:r16681702",
  "physical-building:w1222720021",
  "physical-building:w1249412093",
  "physical-building:w1249412094",
  "physical-building:w34313540",
]);

const AUTHORITY = Object.freeze({
  catalog: Object.freeze({
    path: "discovery/facades/facade-recognition-catalog.json",
    schema: "ti.facade-recognition-catalog/4",
    sha256: "2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311",
  }),
  inventory: Object.freeze({
    path: "discovery/FACADE_RECEIVER_INVENTORY.json",
    schema: "ti.facade-receiver-inventory/1",
    sha256: "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f",
  }),
  registry: Object.freeze({
    path: "game/resources/facades/facade-runtime-registry.json",
    schema: "ti.facade-runtime-registry/4",
    sha256: "dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab",
  }),
  manifest: Object.freeze({
    path: "generated/world/manifest.json",
    schema: "ti.godot-world/2",
    sha256: "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
  }),
  osm: Object.freeze({
    path: "data/osm/treasure-island-2026-08-27.osm",
    sha256: "3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549",
  }),
});

const PRIOR_PACKET_DIRS = Object.freeze([
  "p1_reference_packets",
  "p2_reference_packets",
  "p3_reference_packets",
  "d1_reference_packets",
  "d2_reference_packets",
  "d3_reference_packets",
  "d4_reference_packets",
  "d5_reference_packets",
  "d6_reference_packets",
]);

const CARDINAL_16 = Object.freeze([
  "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
  "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW",
]);

function invariant(condition, message) {
  if (!condition) throw new Error(message);
}

function absolute(relativePath) {
  return resolve(ROOT, relativePath);
}

function readJson(relativePath) {
  return JSON.parse(readFileSync(absolute(relativePath), "utf8"));
}

function sortedJson(value) {
  if (Array.isArray(value)) return value.map(sortedJson);
  if (value !== null && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([key, child]) => [key, sortedJson(child)]),
    );
  }
  return value;
}

function stableJson(value) {
  return `${JSON.stringify(sortedJson(value), null, 2)}\n`;
}

function sha256(value) {
  return createHash("sha256").update(value).digest("hex");
}

function fileSha256(relativePath) {
  return sha256(readFileSync(absolute(relativePath)));
}

function stableSha256(value) {
  return sha256(stableJson(value));
}

function sortedStrings(values) {
  return [...values].sort((left, right) => left.localeCompare(right));
}

function occurrences(haystack, needle) {
  return haystack.split(needle).length - 1;
}

function priorPacketIds() {
  const result = new Set();
  for (const directory of PRIOR_PACKET_DIRS) {
    const path = absolute(`discovery/facades/${directory}`);
    invariant(existsSync(path), `Missing prior packet directory ${directory}`);
    for (const filename of readdirSync(path)) {
      if (filename === "README.md" || !filename.endsWith(".md")) continue;
      const match = filename.match(/^([rw]\d+)/u);
      invariant(match, `Prior packet filename lacks source key: ${directory}/${filename}`);
      result.add(match[1]);
    }
  }
  return result;
}

function azimuthForNormal(normalX, normalZ) {
  return (Math.atan2(-normalX, normalZ) * 180 / Math.PI + 360) % 360;
}

function cardinalForAzimuth(azimuth) {
  return CARDINAL_16[Math.round(azimuth / 22.5) % CARDINAL_16.length];
}

function ranges(indices) {
  const pieces = [];
  let start = indices[0];
  let end = indices[0];
  for (const value of indices.slice(1)) {
    if (value === end + 1) {
      end = value;
      continue;
    }
    pieces.push(start === end ? `${start}` : `${start}–${end}`);
    start = value;
    end = value;
  }
  pieces.push(start === end ? `${start}` : `${start}–${end}`);
  return pieces.join(",");
}

function facingPartition(record) {
  const groups = new Map();
  const runCount = record.vertices.length / 12;
  invariant(Number.isInteger(runCount), `${record.object_key} wall vertices are not quads`);
  invariant(record.normals.length === record.vertices.length, `${record.object_key} normal count drifted`);
  for (let run = 0; run < runCount; run += 1) {
    const offset = run * 12;
    const azimuth = azimuthForNormal(record.normals[offset], record.normals[offset + 2]);
    const cardinal = cardinalForAzimuth(azimuth);
    if (!groups.has(cardinal)) groups.set(cardinal, { azimuths: [], indices: [] });
    groups.get(cardinal).azimuths.push(azimuth);
    groups.get(cardinal).indices.push(run);
  }
  return [...groups.entries()]
    .sort(([, left], [, right]) => Math.min(...left.azimuths) - Math.min(...right.azimuths))
    .map(([cardinal, group]) => ({
      cardinal,
      azimuth_max: Number(Math.max(...group.azimuths).toFixed(1)),
      azimuth_min: Number(Math.min(...group.azimuths).toFixed(1)),
      indices: group.indices,
      ranges: ranges(group.indices),
    }));
}

function visiblePerimeter(record) {
  let total = 0;
  for (let offset = 0; offset < record.vertices.length; offset += 12) {
    const dx = record.vertices[offset + 3] - record.vertices[offset];
    const dz = record.vertices[offset + 5] - record.vertices[offset + 2];
    total += Math.hypot(dx, dz);
  }
  return total;
}

function formattedFacingPartition(partition) {
  return partition.map((group) => {
    const angle = group.azimuth_min === group.azimuth_max
      ? `${group.azimuth_min.toFixed(1)}°`
      : `${group.azimuth_min.toFixed(1)}–${group.azimuth_max.toFixed(1)}°`;
    return `${group.cardinal} \`${angle}\`: \`${group.ranges}\``;
  }).join("; ");
}

function validatePacketTimeRegistryReceipt(readme) {
  const receiptRow = `| D7 packet-time registry snapshot receipt (historical; bytes superseded) | \`${PACKET_TIME_REGISTRY_SNAPSHOT.schema}\`; \`${PACKET_TIME_REGISTRY_SNAPSHOT.sha256}\` | immutable packet-time provenance only; validator verifies this recorded receipt, not current file bytes |`;
  invariant(readme.includes(receiptRow), "README lost the exact historical D7 packet-time registry receipt or its non-current boundary");
  invariant(
    PACKET_TIME_REGISTRY_SNAPSHOT.sha256 !== AUTHORITY.registry.sha256,
    "Historical and current registry identities must remain explicitly separate",
  );
}

function validateCurrentRecognitionState() {
  const catalog = readJson(AUTHORITY.catalog.path);
  const registry = readJson(AUTHORITY.registry.path);
  const catalogCounts = catalog.expected_counts;
  const registryCounts = registry.counts;
  const metric = registry.recognition_metric;
  const acceptedFromCatalog = sortedStrings(catalog.units
    .filter((unit) => unit.claim_status.reference_recognizable === "accepted")
    .map((unit) => unit.unit_id));
  const acceptedFromRegistry = sortedStrings(registry.units
    .filter((unit) => unit.claim_status.reference_recognizable === "accepted")
    .map((unit) => unit.unit_id));
  const expectedAccepted = sortedStrings(EXPECTED_ACCEPTED_PHYSICAL_UNIT_IDS);
  const catalogReceiverCount = catalog.units.reduce((total, unit) => total + unit.receiver_keys.length, 0);
  const catalogSourceRecordCount = catalog.units.reduce((total, unit) => total + unit.source_records.length, 0);
  const registryReceiverCount = registry.units.reduce((total, unit) => total + unit.direct_receivers.length, 0);
  const registrySourceRecordCount = registry.units.reduce((total, unit) => total + unit.source_records.length, 0);
  const unitIds = new Set(registry.units.map((unit) => unit.unit_id));

  invariant(catalog.units.length === 213 && registry.units.length === 213, "Current catalog/registry recognition-unit count is not 213");
  invariant(catalogCounts.recognition_units === 213 && registryCounts.recognition_units === 213, "Current declared recognition-unit count drifted");
  invariant(catalogCounts.direct_wall_receivers === 214 && registryCounts.direct_wall_receivers === 214, "Current declared direct-receiver count drifted");
  invariant(catalogCounts.source_records === 215 && registryCounts.source_record_memberships === 215, "Current declared source-record count drifted");
  invariant(catalogReceiverCount === 214 && registryReceiverCount === 214, "Current derived direct-receiver count is not 214");
  invariant(catalogSourceRecordCount === 215 && registrySourceRecordCount === 215, "Current derived source-record membership count is not 215");
  invariant(JSON.stringify(acceptedFromCatalog) === JSON.stringify(expectedAccepted), `Current catalog accepted set drifted: ${acceptedFromCatalog.join(", ")}`);
  invariant(JSON.stringify(acceptedFromRegistry) === JSON.stringify(expectedAccepted), `Current registry accepted set drifted: ${acceptedFromRegistry.join(", ")}`);
  invariant(metric.numerator === 5 && metric.denominator === 213 && metric.display === "5/213", "Current registry recognition metric is not exactly 5/213");
  invariant(
    JSON.stringify(sortedStrings(metric.accepted_physical_unit_ids)) === JSON.stringify(expectedAccepted),
    "Current registry recognition-metric accepted set drifted",
  );
  invariant(registry.claim_totals.reference_recognizable.accepted === 5, "Current registry accepted recognition total is not 5");
  invariant(registry.claim_totals.reference_recognizable.not_evaluated === 208, "Current registry unevaluated recognition total is not 208");
  invariant(!unitIds.has("physical-building:w1282547786") && !unitIds.has("physical-building:w1282547787"), "Isle House part records became physical numerator units");
  invariant(
    JSON.stringify(metric.isle_house_non_numerator_source_keys) === JSON.stringify(["w1282547786", "w1282547787"]),
    "Current Isle House non-numerator source boundary drifted",
  );

  return Object.freeze({
    catalog_sha256: fileSha256(AUTHORITY.catalog.path),
    registry_sha256: fileSha256(AUTHORITY.registry.path),
    recognition_units: registry.units.length,
    direct_receivers: registryReceiverCount,
    source_record_memberships: registrySourceRecordCount,
    recognition_metric: metric.display,
    accepted_physical_unit_ids: expectedAccepted,
  });
}

function localContracts() {
  const catalog = readJson("discovery/facades/facade-recognition-catalog.json");
  const inventory = readJson("discovery/FACADE_RECEIVER_INVENTORY.json");
  const registry = readJson("game/resources/facades/facade-runtime-registry.json");
  const logical = readJson("generated/world/logical-objects.json");
  invariant(catalog.units.length === 213, `Expected stable 213-unit catalog, found ${catalog.units.length}`);
  const priorIds = priorPacketIds();
  invariant(priorIds.size === 106, `Expected 106 unique prior packet IDs, found ${priorIds.size}`);
  const derived = catalog.units
    .filter((unit) => unit.unit_kind === "standalone_building" && !priorIds.has(unit.anchor_source_key))
    .slice(0, IDS.length)
    .map((unit) => unit.anchor_source_key);
  invariant(JSON.stringify(derived) === JSON.stringify(IDS), `D7 catalog cohort drifted: ${derived.join(", ")}`);

  const inventoryBySource = new Map(inventory.objects.map((object) => [object.source.source_key, object]));
  const registryByUnit = new Map(registry.units.map((unit) => [unit.unit_id, unit]));
  const logicalByKey = new Map(logical.objects.map((object) => [object.logical_object_key, object]));

  return IDS.map((sourceKey) => {
    const object = inventoryBySource.get(sourceKey);
    invariant(object, `${sourceKey} missing from receiver inventory`);
    invariant(object.footprint_relationship.kind === "standalone_building_footprint", `${sourceKey} is not standalone`);
    invariant(object.footprint_relationship.part_source_keys.length === 0, `${sourceKey} unexpectedly owns part children`);
    const logicalKey = `building:${sourceKey}`;
    const wallKey = `${logicalKey}:wall`;
    const roofKey = `${logicalKey}:roof`;
    invariant(JSON.stringify(object.generated_receiver.direct_wall_object_keys) === JSON.stringify([wallKey]), `${sourceKey} wall binding drifted`);
    invariant(JSON.stringify(object.generated_receiver.direct_roof_object_keys) === JSON.stringify([roofKey]), `${sourceKey} roof binding drifted`);
    const unit = registryByUnit.get(`physical-building:${sourceKey}`);
    invariant(unit, `${sourceKey} missing from runtime registry`);
    invariant(unit.direct_receivers.length === 1, `${sourceKey} must have one direct facade receiver`);
    const receiver = unit.direct_receivers[0];
    invariant(receiver.receiver_key === wallKey, `${sourceKey} registry receiver drifted`);
    const chunkPath = `generated/world/chunks/${receiver.chunk_id}.json`;
    const chunk = readJson(chunkPath);
    const wall = chunk.records.find((record) => record.object_key === wallKey);
    const roof = chunk.records.find((record) => record.object_key === roofKey);
    invariant(wall && roof, `${sourceKey} wall/roof records missing from ${receiver.chunk_id}`);
    const wallGeometryHash = stableSha256({
      flat_base_elevation_m: wall.flat_base_elevation_m,
      indices: wall.indices,
      normals: wall.normals,
      top_elevation_m: wall.top_elevation_m,
      uvs: wall.uvs,
      vertices: wall.vertices,
    });
    const wallRecordHash = stableSha256(wall);
    const chunkHash = fileSha256(chunkPath);
    invariant(wallGeometryHash === receiver.geometry_sha256, `${sourceKey} wall geometry hash mismatch`);
    invariant(wallRecordHash === receiver.record_sha256, `${sourceKey} wall record hash mismatch`);
    invariant(chunkHash === receiver.chunk_sha256, `${sourceKey} chunk hash mismatch`);
    const logicalObject = logicalByKey.get(logicalKey);
    invariant(logicalObject, `${sourceKey} logical object missing`);
    invariant(logicalObject.source_geometry.length === 1, `${sourceKey} source geometry is not singular`);
    invariant(logicalObject.source_geometry[0].geometry_sha256 === object.source_geometry.geometry_sha256, `${sourceKey} source geometry hash drifted`);
    invariant(wall.exterior_foundation_segments === receiver.run_count, `${sourceKey} run count drifted`);
    return {
      source_key: sourceKey,
      address: object.identity.address.formatted,
      osm_version: object.source.osm_version,
      osm_timestamp: object.source.osm_timestamp,
      tags: object.source.tags,
      logical_key: logicalKey,
      wall_key: wallKey,
      roof_key: roofKey,
      chunk_id: receiver.chunk_id,
      area_m2: object.source_geometry.serialized_area_m2,
      height_m: object.current_generated_massing.height_m,
      base_m: wall.flat_base_elevation_m,
      top_m: wall.top_elevation_m,
      serialized_perimeter_m: logicalObject.source_geometry[0].serialization_perimeter_m,
      visible_perimeter_m: visiblePerimeter(wall),
      run_count: receiver.run_count,
      facing_partition: facingPartition(wall),
      source_geometry_sha256: object.source_geometry.geometry_sha256,
      wall_geometry_sha256: wallGeometryHash,
      wall_record_sha256: wallRecordHash,
      chunk_sha256: chunkHash,
      wall_material_key: object.runtime_material_assignment.wall_material_key,
      wall_texture_set: object.runtime_material_assignment.wall_texture_set,
      roof_material_key: object.runtime_material_assignment.roof_material_key,
      roof_texture_set: object.runtime_material_assignment.roof_texture_set,
    };
  });
}

const contracts = localContracts();

for (const authority of Object.values(AUTHORITY)) {
  if (authority.schema) {
    invariant(readJson(authority.path).schema_version === authority.schema, `${authority.path} schema drifted`);
  }
  invariant(fileSha256(authority.path) === authority.sha256, `${authority.path} SHA-256 drifted`);
}

const readme = readFileSync(resolve(HERE, "README.md"), "utf8");
validatePacketTimeRegistryReceipt(readme);
const currentRecognition = validateCurrentRecognitionState();

if (process.argv.includes("--dump-contracts")) {
  process.stdout.write(`${JSON.stringify({
    cohort: IDS,
    authority: {
      catalog_schema: readJson("discovery/facades/facade-recognition-catalog.json").schema_version,
      catalog_sha256: fileSha256("discovery/facades/facade-recognition-catalog.json"),
      inventory_schema: readJson("discovery/FACADE_RECEIVER_INVENTORY.json").schema_version,
      inventory_sha256: fileSha256("discovery/FACADE_RECEIVER_INVENTORY.json"),
      packet_time_registry_snapshot: PACKET_TIME_REGISTRY_SNAPSHOT,
      current_registry_schema: readJson("game/resources/facades/facade-runtime-registry.json").schema_version,
      current_registry_sha256: fileSha256("game/resources/facades/facade-runtime-registry.json"),
      manifest_schema: readJson("generated/world/manifest.json").schema_version,
      manifest_sha256: fileSha256("generated/world/manifest.json"),
      osm_sha256: fileSha256("data/osm/treasure-island-2026-08-27.osm"),
    },
    current_recognition: currentRecognition,
    contracts,
  }, null, 2)}\n`);
  process.exit(0);
}

const expectedFiles = new Set(["README.md", "validate_d7_packets.mjs", ...Object.values(PACKET_FILENAMES)]);
const actualFiles = readdirSync(HERE);
invariant(actualFiles.length === expectedFiles.size, `Expected ${expectedFiles.size} D7 files, found ${actualFiles.length}`);
for (const filename of actualFiles) invariant(expectedFiles.has(filename), `Unexpected D7 file (including binary/image): ${filename}`);

let packetFieldChecks = 0;
let facingPartitionChecks = 0;
let packetLinkChecks = 0;
let observedPrototypeReady = 0;
let observedComponentReady = 0;
for (const contract of contracts) {
  const filename = PACKET_FILENAMES[contract.source_key];
  invariant(filename, `${contract.source_key} lacks a frozen packet filename`);
  const candidates = actualFiles.filter((candidate) => candidate.startsWith(`${contract.source_key}_`) && candidate.endsWith(".md"));
  invariant(candidates.length === 1 && candidates[0] === filename, `${contract.source_key} packet filename drifted`);
  const packet = readFileSync(resolve(HERE, filename), "utf8");
  const tags = contract.tags;
  const fieldTokens = [
    contract.source_key,
    `v${contract.osm_version}`,
    contract.osm_timestamp,
    `\`addr:housenumber=${tags["addr:housenumber"]}\``,
    `\`addr:street=${tags["addr:street"]}\``,
    contract.logical_key,
    contract.wall_key,
    contract.roof_key,
    contract.chunk_id,
    `area \`${contract.area_m2.toFixed(3)} m²\``,
    `height \`${Number(contract.height_m).toFixed(0)} m\``,
    `NAVD88 base/top \`${contract.base_m.toFixed(3)} / ${contract.top_m.toFixed(3)} m\``,
    `serialized \`${contract.serialized_perimeter_m.toFixed(3)} m\`; visible \`${contract.visible_perimeter_m.toFixed(3)} m\`; \`${contract.run_count}\` runs`,
    contract.source_geometry_sha256,
    contract.wall_geometry_sha256,
    contract.wall_record_sha256,
    contract.chunk_sha256,
    `wall key \`${contract.wall_material_key}\`, set \`${contract.wall_texture_set}\`; roof key \`${contract.roof_material_key}\`, set \`${contract.roof_texture_set}\``,
  ];
  for (const token of fieldTokens) {
    invariant(packet.includes(token), `${filename} lacks exact field token ${token}`);
    packetFieldChecks += 1;
  }
  const facing = formattedFacingPartition(contract.facing_partition);
  invariant(packet.includes(`| Facing-run partition | ${facing} |`), `${filename} facing-run partition drifted`);
  facingPartitionChecks += contract.facing_partition.length;
  for (const heading of [
    "## Exact receiver contract",
    "## Identity, lifecycle, and public-side appearance",
    "## Recognition boundary and handoff",
  ]) invariant(packet.includes(heading), `${filename} lacks ${heading}`);
  invariant(packet.includes("Close confusion:"), `${filename} lacks an explicit confusion set`);
  invariant(/blocker/iu.test(packet), `${filename} lacks an honest blocker boundary`);
  invariant(/No\s+panorama\s+pixels\s+are\s+retained/iu.test(packet), `${filename} lacks the pixel-retention boundary`);
  invariant(occurrences(readme, `](${filename})`) === 1, `README must link ${filename} exactly once`);
  packetLinkChecks += 1;
  if (COMPONENT_READY_IDS.has(contract.source_key)) {
    invariant(/^Readiness: \*\*component\//mu.test(packet), `${filename} component readiness drifted`);
    observedComponentReady += 1;
  } else {
    invariant(/^Readiness: \*\*target-side (?:historical )?prototype-ready/mu.test(packet), `${filename} prototype readiness drifted`);
    observedPrototypeReady += 1;
  }
}

const prototypeReady = IDS.filter((id) => !COMPONENT_READY_IDS.has(id)).length;
const componentReady = COMPONENT_READY_IDS.size;
const appearanceBlocked = 0;
invariant(prototypeReady === 13 && componentReady === 2, "Frozen readiness distribution drifted");
invariant(observedPrototypeReady === prototypeReady && observedComponentReady === componentReady, "Packet readiness counts drifted");
invariant(packetLinkChecks === IDS.length, `Expected ${IDS.length} packet links, found ${packetLinkChecks}`);
invariant(readme.includes(`Totals: **${prototypeReady} prototype-ready / ${componentReady} component-ready / ${appearanceBlocked} wholly`), "README readiness totals drifted");
for (const authority of Object.values(AUTHORITY)) invariant(readme.includes(authority.sha256), `README lacks authority SHA-256 ${authority.sha256}`);
invariant(readme.includes(PACKET_TIME_REGISTRY_SNAPSHOT.sha256), `README lacks historical packet-time registry receipt ${PACKET_TIME_REGISTRY_SNAPSHOT.sha256}`);
for (const sourceId of ["CITY-EAS", "CITY-XWALK", "NAVY-SITE12-2015", "TIDA-JSCO-2026", "GOOGLE-SV"]) {
  invariant(readme.includes(`\`${sourceId}\``), `README lacks shared source ${sourceId}`);
}
invariant(facingPartitionChecks === 60, `Expected 60 facing partitions, found ${facingPartitionChecks}`);

process.stdout.write(`D7 packet audit: PASS (${IDS.length} IDs, 45 recomputed hashes, ${packetFieldChecks} exact field checks, ${facingPartitionChecks} facing partitions, ${packetLinkChecks} packet links, readiness ${prototypeReady}/${componentReady}/${appearanceBlocked}; historical registry receipt ${PACKET_TIME_REGISTRY_SNAPSHOT.sha256}; current registry ${currentRecognition.registry_sha256}, ${currentRecognition.recognition_metric})\n`);
