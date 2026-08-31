#!/usr/bin/env node

import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  readdirSync,
  renameSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { createHash } from "node:crypto";
import { spawnSync } from "node:child_process";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(scriptDirectory, "..");
const DEFAULT_WORLD = resolve(projectRoot, "generated/world");
const DEFAULT_OUTPUT = resolve(projectRoot, "evidence/first-playable/coverage");
const SOURCE_LEDGER = "data/osm/treasure-island-source-inventory.csv";
const SOURCE_POLYGON = "data/osm/treasure-island-polygon.geojson";
const EXPECTED_CATEGORY_COUNTS = Object.freeze({
  land_boundary: 1,
  terrain_shoreline: 22,
  roads_paths: 427,
  major_area: 80,
  building: 213,
  building_part: 2,
});
const EXPECTED_CONTEXT_KEYS = Object.freeze([
  "r13543937",
  "r13543938",
  "w1011568818",
  "w26767311",
]);
const EXPECTED_BOUNDARY_ATTACHED_KEYS = Object.freeze([
  "w319406837",
  "w644986117",
]);
const SVG_WIDTH = 1600;
const SVG_HEIGHT = 1200;

function invariant(condition, message) {
  if (!condition) throw new Error(message);
}

function sha256Bytes(value) {
  return createHash("sha256").update(value).digest("hex");
}

function sha256File(path) {
  return sha256Bytes(readFileSync(path));
}

function descriptor(root, path) {
  const absolute = resolve(root, path);
  return { path, bytes: statSync(absolute).size, sha256: sha256File(absolute) };
}

function sortJson(value) {
  if (Array.isArray(value)) return value.map(sortJson);
  if (value != null && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([key, child]) => [key, sortJson(child)]),
    );
  }
  return value;
}

function stableJson(value) {
  return `${JSON.stringify(sortJson(value), null, 2)}\n`;
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value, "utf8");
}

function listFiles(root, current = root) {
  const files = [];
  for (const entry of readdirSync(current, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
    const path = join(current, entry.name);
    if (entry.isDirectory()) files.push(...listFiles(root, path));
    else files.push(relative(root, path).replaceAll("\\", "/"));
  }
  return files;
}

function parseCsv(text) {
  const records = [];
  let record = [];
  let cell = "";
  let quoted = false;
  for (let index = 0; index < text.length; index += 1) {
    const character = text[index];
    if (quoted) {
      if (character === '"') {
        if (text[index + 1] === '"') {
          cell += '"';
          index += 1;
        } else quoted = false;
      } else cell += character;
    } else if (character === '"') {
      invariant(cell.length === 0, `Malformed CSV quote at byte ${index}`);
      quoted = true;
    } else if (character === ",") {
      record.push(cell);
      cell = "";
    } else if (character === "\n") {
      record.push(cell.endsWith("\r") ? cell.slice(0, -1) : cell);
      records.push(record);
      record = [];
      cell = "";
    } else cell += character;
  }
  invariant(!quoted, "Malformed CSV: unterminated quote");
  if (record.length > 0 || cell.length > 0) {
    record.push(cell);
    records.push(record);
  }
  invariant(records.length >= 2, "CSV has no data rows");
  const headers = records[0];
  invariant(new Set(headers).size === headers.length, "CSV has duplicate headers");
  return records.slice(1).map((values, rowIndex) => {
    invariant(values.length === headers.length, `CSV row ${rowIndex + 2} has ${values.length}/${headers.length} cells`);
    return Object.fromEntries(headers.map((header, index) => [header, values[index]]));
  });
}

function splitValues(value, separator = ";") {
  return value === "" ? [] : value.split(separator);
}

function contentIndexSha256(files) {
  const hash = createHash("sha256");
  for (const file of [...files].sort((a, b) => a.path.localeCompare(b.path))) {
    hash.update(`${file.path}\0${file.sha256}\0${file.bytes}\n`, "utf8");
  }
  return hash.digest("hex");
}

function round3(value) {
  const rounded = Math.round(value * 1000) / 1000;
  return Object.is(rounded, -0) ? 0 : rounded;
}

function samePoint(a, b) {
  return a[0] === b[0] && a[1] === b[1];
}

function projectedSourceBoundary(sourcePolygon, coordinateSystem) {
  invariant(sourcePolygon.type === "FeatureCollection" && sourcePolygon.features.length === 1, "Source polygon feature drift");
  const geometry = sourcePolygon.features[0].geometry;
  invariant(geometry.type === "MultiPolygon" && geometry.coordinates.length === 1, "Source polygon geometry drift");
  invariant(geometry.coordinates[0].length === 1, "Unexpected source polygon hole");
  const radians = Math.PI / 180;
  const radius = coordinateSystem.earth_radius_m;
  const lon0 = coordinateSystem.origin_lon * radians;
  const lat0 = coordinateSystem.origin_lat * radians;
  const ring = geometry.coordinates[0][0].map(([longitude, latitude]) => [
    round3(radius * (longitude * radians - lon0) * Math.cos(lat0)),
    round3(-radius * (latitude * radians - lat0)),
  ]);
  if (ring.length > 1 && samePoint(ring[0], ring.at(-1))) ring.pop();
  return ring;
}

function emptyExtent() {
  return { min_x: Infinity, min_north: Infinity, max_x: -Infinity, max_north: -Infinity };
}

function includePoint(extent, x, north) {
  extent.min_x = Math.min(extent.min_x, x);
  extent.max_x = Math.max(extent.max_x, x);
  extent.min_north = Math.min(extent.min_north, north);
  extent.max_north = Math.max(extent.max_north, north);
}

function includeExtent(target, source) {
  if (!Number.isFinite(source.min_x)) return;
  includePoint(target, source.min_x, source.min_north);
  includePoint(target, source.max_x, source.max_north);
}

function extentForRecords(records) {
  const extent = emptyExtent();
  for (const record of records) {
    for (let index = 0; index < record.vertices.length; index += 3) {
      includePoint(extent, record.vertices[index], -record.vertices[index + 2]);
    }
  }
  invariant(Number.isFinite(extent.min_x), "Cannot compute an empty record extent");
  return Object.fromEntries(Object.entries(extent).map(([key, value]) => [key, round3(value)]));
}

function extentForRing(ring) {
  const extent = emptyExtent();
  for (const [x, z] of ring) includePoint(extent, x, -z);
  return Object.fromEntries(Object.entries(extent).map(([key, value]) => [key, round3(value)]));
}

function validateRecord(record, label) {
  invariant(typeof record.object_key === "string" && record.object_key.length > 0, `${label} has no object key`);
  invariant(Array.isArray(record.source_keys) && record.source_keys.length > 0, `${label} has no source keys`);
  invariant(Array.isArray(record.vertices) && record.vertices.length >= 9 && record.vertices.length % 3 === 0, `${label} vertices malformed`);
  invariant(Array.isArray(record.normals) && record.normals.length === record.vertices.length, `${label} normals malformed`);
  invariant(Array.isArray(record.uvs) && record.uvs.length === (record.vertices.length / 3) * 2, `${label} UVs malformed`);
  invariant(Array.isArray(record.indices) && record.indices.length >= 3 && record.indices.length % 3 === 0, `${label} indices malformed`);
  invariant(record.vertices.every(Number.isFinite) && record.normals.every(Number.isFinite) && record.uvs.every(Number.isFinite), `${label} has nonfinite mesh values`);
  const vertexCount = record.vertices.length / 3;
  invariant(record.indices.every((index) => Number.isInteger(index) && index >= 0 && index < vertexCount), `${label} has an invalid index`);
  for (let index = 0; index < record.indices.length; index += 3) {
    const triangle = record.indices.slice(index, index + 3);
    invariant(new Set(triangle).size === 3, `${label} repeats a triangle vertex`);
    const points = triangle.map((vertexIndex) => record.vertices.slice(vertexIndex * 3, vertexIndex * 3 + 3));
    const ab = points[1].map((value, axis) => value - points[0][axis]);
    const ac = points[2].map((value, axis) => value - points[0][axis]);
    const cross = [
      ab[1] * ac[2] - ab[2] * ac[1],
      ab[2] * ac[0] - ab[0] * ac[2],
      ab[0] * ac[1] - ab[1] * ac[0],
    ];
    invariant(cross.some((value) => Math.abs(value) > 1e-10), `${label} has a degenerate 3D triangle`);
  }
}

function validateWorld(worldRoot) {
  const manifestPath = resolve(worldRoot, "manifest.json");
  const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
  invariant(manifest.schema_version === "ti.godot-world/2", `Unexpected manifest schema ${manifest.schema_version}`);
  invariant(manifest.coordinate_system?.world_axes === "+X east,+Y up,-Z north", "World orientation drift");
  invariant(manifest.coordinate_system?.coordinate_rounding_m === 0.001, "Coordinate rounding drift");
  invariant(manifest.counts?.source_rows === 739 && manifest.counts.playable_rows === 735 && manifest.counts.context_rows === 4, "Manifest denominator drift");
  invariant(manifest.counts.unresolved_rows === 0 && manifest.counts.duplicate_source_keys === 0, "Manifest contains coverage errors");

  const actualWorldFiles = listFiles(worldRoot).filter((path) => path !== "manifest.json");
  const listedWorldFiles = manifest.files.map((file) => file.path);
  invariant(stableJson(actualWorldFiles) === stableJson(listedWorldFiles), "Generated world file inventory drift");
  const actualDescriptors = actualWorldFiles.map((path) => descriptor(worldRoot, path));
  invariant(stableJson(actualDescriptors) === stableJson(manifest.files), "Generated world artifact hash/size drift");
  invariant(contentIndexSha256(actualDescriptors) === manifest.content_sha256, "Generated world content-index hash drift");

  const sourceLedgerPath = resolve(projectRoot, SOURCE_LEDGER);
  const sourcePolygonPath = resolve(projectRoot, SOURCE_POLYGON);
  const sourceLedgerHash = sha256File(sourceLedgerPath);
  const sourcePolygonHash = sha256File(sourcePolygonPath);
  invariant(manifest.sources.source_ledger.path === SOURCE_LEDGER && manifest.sources.source_ledger.sha256 === sourceLedgerHash, "Source ledger contract drift");
  invariant(manifest.sources.extraction_polygon.path === SOURCE_POLYGON && manifest.sources.extraction_polygon.sha256 === sourcePolygonHash, "Source polygon contract drift");
  const sourceRows = parseCsv(readFileSync(sourceLedgerPath, "utf8"));
  const coverageRows = parseCsv(readFileSync(resolve(worldRoot, manifest.coverage_ledger.path), "utf8"));
  invariant(sourceRows.length === 739 && coverageRows.length === 739, "Source/coverage row count drift");
  invariant(new Set(sourceRows.map((row) => row.source_key)).size === 739, "Source ledger duplicate key");
  invariant(new Set(coverageRows.map((row) => row.source_key)).size === 739, "Coverage ledger duplicate key");
  const sourceByKey = new Map(sourceRows.map((row) => [row.source_key, row]));
  const coverageByKey = new Map(coverageRows.map((row) => [row.source_key, row]));
  invariant(stableJson([...sourceByKey.keys()].sort()) === stableJson([...coverageByKey.keys()].sort()), "Source-to-coverage join drift");
  for (const sourceRow of sourceRows) {
    const coverageRow = coverageByKey.get(sourceRow.source_key);
    invariant(coverageRow.scope === sourceRow.scope, `${sourceRow.source_key} scope drift`);
    invariant(coverageRow.osm_type === sourceRow.osm_type && coverageRow.osm_id === sourceRow.osm_id, `${sourceRow.source_key} identity drift`);
    invariant(coverageRow.source_version === sourceRow.source_version, `${sourceRow.source_key} version drift`);
    invariant(
      stableJson(splitValues(coverageRow.categories).sort()) === stableJson(splitValues(sourceRow.categories, "|").sort()),
      `${sourceRow.source_key} category drift`,
    );
    invariant(["represented", "composite_member", "context"].includes(coverageRow.derived_world_status), `${sourceRow.source_key} unresolved status`);
    invariant(coverageRow.validation === "pass", `${sourceRow.source_key} coverage validation failed`);
  }

  const chunks = [];
  const chunkRecords = [];
  const chunkIds = new Set();
  const physicalByKey = new Map();
  for (const chunkDescriptor of manifest.chunks) {
    const chunk = JSON.parse(readFileSync(resolve(worldRoot, chunkDescriptor.path), "utf8"));
    invariant(chunk.schema_version === "ti.godot-world-chunk/2" && chunk.chunk_id === chunkDescriptor.chunk_id, `${chunkDescriptor.chunk_id} schema/id drift`);
    invariant(!chunkIds.has(chunk.chunk_id), `${chunk.chunk_id} duplicated`);
    chunkIds.add(chunk.chunk_id);
    chunks.push(chunk);
    for (const record of chunk.records) {
      validateRecord(record, record.object_key);
      invariant(!physicalByKey.has(record.object_key), `Duplicate physical record ${record.object_key}`);
      invariant(record.source_keys.every((key) => coverageByKey.has(key)), `${record.object_key} has unknown source key`);
      physicalByKey.set(record.object_key, { record, chunk_id: chunk.chunk_id, location: "playable" });
      chunkRecords.push(record);
    }
  }
  invariant(chunks.length === 38, `Expected 38 chunks, found ${chunks.length}`);

  const context = JSON.parse(readFileSync(resolve(worldRoot, manifest.context.path), "utf8"));
  invariant(context.schema_version === "ti.godot-world-context/2", "Context schema drift");
  invariant(context.records.length === 2 && context.boundary_attached_visuals.length === 2, "Context record count drift");
  const contextRecords = [...context.records, ...context.boundary_attached_visuals];
  for (const record of contextRecords) {
    validateRecord(record, record.object_key);
    invariant(!physicalByKey.has(record.object_key), `Duplicate context record ${record.object_key}`);
    invariant(record.source_keys.every((key) => coverageByKey.has(key)), `${record.object_key} has unknown context source key`);
    invariant(record.collision_kind === "none" && record.receiver_kind === "none", `${record.object_key} context collision leak`);
    physicalByKey.set(record.object_key, { record, chunk_id: null, location: "context" });
  }
  invariant(physicalByKey.size === 729, `Expected 729 physical records, found ${physicalByKey.size}`);

  const missingPartReferences = [];
  const missingChunkReferences = [];
  for (const row of coverageRows) {
    const partKeys = splitValues(row.part_keys);
    invariant(partKeys.length > 0, `${row.source_key} has no physical part reference`);
    for (const partKey of partKeys) if (!physicalByKey.has(partKey)) missingPartReferences.push(`${row.source_key}:${partKey}`);
    for (const chunkId of splitValues(row.chunk_ids)) if (!chunkIds.has(chunkId)) missingChunkReferences.push(`${row.source_key}:${chunkId}`);
  }
  invariant(missingPartReferences.length === 0, `Missing physical references: ${missingPartReferences.join(",")}`);
  invariant(missingChunkReferences.length === 0, `Missing chunk references: ${missingChunkReferences.join(",")}`);

  const playableRows = coverageRows.filter((row) => row.scope === "playable");
  const contextRows = coverageRows.filter((row) => row.scope === "context");
  invariant(playableRows.length === 735 && contextRows.length === 4, "Coverage scope count drift");
  invariant(stableJson(contextRows.map((row) => row.source_key).sort()) === stableJson([...EXPECTED_CONTEXT_KEYS].sort()), "Context source key drift");
  const categoryCounts = {};
  for (const [category, expected] of Object.entries(EXPECTED_CATEGORY_COUNTS)) {
    categoryCounts[category] = playableRows.filter((row) => splitValues(row.categories).includes(category)).length;
    invariant(categoryCounts[category] === expected, `${category} count drift`);
  }

  const recordsForRow = (row) => splitValues(row.part_keys).map((key) => physicalByKey.get(key).record);
  const rowsWithKind = (category, kinds) => playableRows.filter((row) =>
    splitValues(row.categories).includes(category) && recordsForRow(row).some((record) => kinds.includes(record.feature_kind)));
  const roadBacked = rowsWithKind("roads_paths", ["road_path"]);
  const areaRows = playableRows.filter((row) => splitValues(row.categories).includes("major_area"));
  const areaBacked = areaRows.filter((row) => recordsForRow(row).length > 0);
  const buildingBacked = rowsWithKind("building", ["building_roof", "building_part_roof"]);
  const partBacked = rowsWithKind("building_part", ["building_part_roof"]);
  invariant(roadBacked.length === 427, `Only ${roadBacked.length}/427 roads are backed by road records`);
  invariant(areaBacked.length === 80, `Only ${areaBacked.length}/80 areas are backed by visible generated records`);
  invariant(buildingBacked.length === 213, `Only ${buildingBacked.length}/213 buildings are backed by roof records`);
  invariant(partBacked.length === 2, `Only ${partBacked.length}/2 building parts are backed by part roofs`);

  const ybiKey = "w26767311";
  invariant(!chunkRecords.some((record) => record.source_keys.includes(ybiKey)), "YBI leaked into playable chunk records");
  invariant(context.records.some((record) => record.object_key === "context:ybi" && record.source_keys.length === 1 && record.source_keys[0] === ybiKey), "YBI context record missing");
  invariant(
    stableJson(context.boundary_attached_visuals.map((record) => record.source_keys[0]).sort()) ===
      stableJson([...EXPECTED_BOUNDARY_ATTACHED_KEYS].sort()),
    "Boundary-attached context keys drift",
  );

  const sourcePolygon = JSON.parse(readFileSync(sourcePolygonPath, "utf8"));
  const sourceBoundary = projectedSourceBoundary(sourcePolygon, manifest.coordinate_system);
  const derivedBoundary = manifest.playable_boundary.components[0].outer;
  invariant(manifest.playable_boundary.components.length === 1 && manifest.playable_boundary.components[0].holes.length === 0, "Playable boundary topology drift");
  invariant(stableJson(sourceBoundary) === stableJson(derivedBoundary), "Projected exact source polygon differs from manifest boundary");

  const kindStats = {};
  for (const kind of [...new Set(chunkRecords.map((record) => record.feature_kind))].sort()) {
    const records = chunkRecords.filter((record) => record.feature_kind === kind);
    kindStats[kind] = {
      records: records.length,
      triangles: records.reduce((sum, record) => sum + record.indices.length / 3, 0),
      unique_source_keys: new Set(records.flatMap((record) => record.source_keys)).size,
    };
  }

  const extents = {
    exact_source_boundary_m: extentForRing(sourceBoundary),
    playable_records_m: extentForRecords(chunkRecords),
    land_m: extentForRecords(chunkRecords.filter((record) => record.feature_kind === "land_ground")),
    roads_m: extentForRecords(chunkRecords.filter((record) => record.feature_kind === "road_path")),
    areas_m: extentForRecords(chunkRecords.filter((record) => ["major_area", "terrain_overlay"].includes(record.feature_kind))),
    building_roofs_m: extentForRecords(chunkRecords.filter((record) => ["building_roof", "building_part_roof"].includes(record.feature_kind))),
    ybi_context_m: extentForRecords(context.records.filter((record) => record.context_kind === "ybi")),
    bridge_context_m: extentForRecords(context.records.filter((record) => record.context_kind === "bay_bridge")),
    boundary_attached_visuals_m: extentForRecords(context.boundary_attached_visuals),
  };

  return {
    manifest,
    sourceBoundary,
    derivedBoundary,
    sourceRows,
    coverageRows,
    coverageByKey,
    chunks,
    chunkRecords,
    context,
    physicalByKey,
    categoryCounts,
    kindStats,
    extents,
    inputDescriptors: {
      manifest: descriptor(worldRoot, "manifest.json"),
      coverage_ledger: descriptor(worldRoot, manifest.coverage_ledger.path),
      context: descriptor(worldRoot, manifest.context.path),
      source_ledger: {
        path: SOURCE_LEDGER,
        bytes: statSync(sourceLedgerPath).size,
        sha256: sourceLedgerHash,
      },
      exact_ti_polygon: {
        path: SOURCE_POLYGON,
        bytes: statSync(sourcePolygonPath).size,
        sha256: sourcePolygonHash,
      },
    },
  };
}

function xmlEscape(value) {
  return String(value).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");
}

function number(value) {
  return value.toFixed(3).replace(/\.000$/u, "").replace(/(\.\d*?)0+$/u, "$1");
}

function paddedExtent(extent, fraction = 0.04) {
  const width = extent.max_x - extent.min_x;
  const height = extent.max_north - extent.min_north;
  return {
    min_x: extent.min_x - width * fraction,
    max_x: extent.max_x + width * fraction,
    min_north: extent.min_north - height * fraction,
    max_north: extent.max_north + height * fraction,
  };
}

function mapper(extent, frame) {
  const scale = Math.min(frame.width / (extent.max_x - extent.min_x), frame.height / (extent.max_north - extent.min_north));
  const occupiedWidth = (extent.max_x - extent.min_x) * scale;
  const occupiedHeight = (extent.max_north - extent.min_north) * scale;
  const offsetX = frame.x + (frame.width - occupiedWidth) / 2;
  const offsetY = frame.y + (frame.height - occupiedHeight) / 2;
  return {
    scale,
    point(x, north) {
      return [
        offsetX + (x - extent.min_x) * scale,
        offsetY + (extent.max_north - north) * scale,
      ];
    },
  };
}

function trianglePath(records, map) {
  const commands = [];
  let renderedTriangles = 0;
  let verticalProjectionTriangles = 0;
  for (const record of records) {
    for (let index = 0; index < record.indices.length; index += 3) {
      const points = record.indices.slice(index, index + 3).map((vertexIndex) => {
        const offset = vertexIndex * 3;
        return [record.vertices[offset], -record.vertices[offset + 2]];
      });
      const twiceArea = Math.abs(
        (points[1][0] - points[0][0]) * (points[2][1] - points[0][1]) -
        (points[1][1] - points[0][1]) * (points[2][0] - points[0][0]),
      );
      if (twiceArea <= 1e-10) {
        verticalProjectionTriangles += 1;
        continue;
      }
      const mapped = points.map(([x, north]) => map.point(x, north));
      commands.push(`M${number(mapped[0][0])},${number(mapped[0][1])}L${number(mapped[1][0])},${number(mapped[1][1])}L${number(mapped[2][0])},${number(mapped[2][1])}Z`);
      renderedTriangles += 1;
    }
  }
  return { path: commands.join(""), renderedTriangles, verticalProjectionTriangles };
}

function ringPath(ring, map) {
  return ring.map(([x, z], index) => {
    const [screenX, screenY] = map.point(x, -z);
    return `${index === 0 ? "M" : "L"}${number(screenX)},${number(screenY)}`;
  }).join("") + "Z";
}

function line(x1, y1, x2, y2, attributes = "") {
  return `<line x1="${number(x1)}" y1="${number(y1)}" x2="${number(x2)}" y2="${number(y2)}" ${attributes}/>`;
}

function legendItem(x, y, color, label, options = {}) {
  const dash = options.dash ? ' stroke-dasharray="8 5"' : "";
  const swatch = options.outline
    ? `<line x1="${x}" y1="${y - 7}" x2="${x + 24}" y2="${y - 7}" stroke="${color}" stroke-width="4"${dash}/>`
    : `<rect x="${x}" y="${y - 13}" width="24" height="14" fill="${color}" stroke="#544f46" stroke-width="1"/>`;
  return `${swatch}<text x="${x + 36}" y="${y}" class="legend">${xmlEscape(label)}</text>`;
}

function renderSvg(state, diagnostic = false) {
  const mainRecords = state.chunkRecords;
  const land = mainRecords.filter((record) => record.feature_kind === "land_ground");
  const terrain = mainRecords.filter((record) => record.feature_kind === "terrain_overlay");
  const areas = mainRecords.filter((record) => record.feature_kind === "major_area");
  const roads = mainRecords.filter((record) => record.feature_kind === "road_path");
  const buildings = mainRecords.filter((record) => record.feature_kind === "building_roof");
  const buildingParts = mainRecords.filter((record) => record.feature_kind === "building_part_roof");
  const ybi = state.context.records.filter((record) => record.context_kind === "ybi");
  const bridge = state.context.records.filter((record) => record.context_kind === "bay_bridge");
  const attached = state.context.boundary_attached_visuals;

  const mainExtent = emptyExtent();
  includeExtent(mainExtent, state.extents.exact_source_boundary_m);
  includeExtent(mainExtent, state.extents.boundary_attached_visuals_m);
  const mainMap = mapper(paddedExtent(mainExtent, 0.035), { x: 65, y: 126, width: 910, height: 1010 });
  const contextExtent = emptyExtent();
  includeExtent(contextExtent, state.extents.exact_source_boundary_m);
  includeExtent(contextExtent, state.extents.ybi_context_m);
  includeExtent(contextExtent, state.extents.bridge_context_m);
  includeExtent(contextExtent, state.extents.boundary_attached_visuals_m);
  const contextMap = mapper(paddedExtent(contextExtent, 0.055), { x: 1025, y: 555, width: 520, height: 455 });
  const tiLabel = contextMap.point(
    (state.extents.exact_source_boundary_m.min_x + state.extents.exact_source_boundary_m.max_x) / 2,
    state.extents.exact_source_boundary_m.max_north,
  );
  const ybiLabel = contextMap.point(
    (state.extents.ybi_context_m.min_x + state.extents.ybi_context_m.max_x) / 2,
    (state.extents.ybi_context_m.min_north + state.extents.ybi_context_m.max_north) / 2,
  );

  const rendered = {};
  for (const [name, records] of Object.entries({ land, terrain, areas, roads, buildings, buildingParts, ybi, bridge, attached })) {
    rendered[`${name}Main`] = trianglePath(records, mainMap);
    rendered[`${name}Context`] = trianglePath(records, contextMap);
  }
  const sourceMain = ringPath(state.sourceBoundary, mainMap);
  const derivedMain = ringPath(state.derivedBoundary, mainMap);
  const sourceContext = ringPath(state.sourceBoundary, contextMap);

  const grid = [];
  if (diagnostic) {
    const extent = paddedExtent(mainExtent, 0.035);
    for (let x = Math.ceil(extent.min_x / 256) * 256; x <= extent.max_x; x += 256) {
      const [screenX1, screenY1] = mainMap.point(x, extent.min_north);
      const [screenX2, screenY2] = mainMap.point(x, extent.max_north);
      grid.push(line(screenX1, screenY1, screenX2, screenY2, 'class="grid"'));
    }
    for (let north = Math.ceil(extent.min_north / 256) * 256; north <= extent.max_north; north += 256) {
      const [screenX1, screenY1] = mainMap.point(extent.min_x, north);
      const [screenX2, screenY2] = mainMap.point(extent.max_x, north);
      grid.push(line(screenX1, screenY1, screenX2, screenY2, 'class="grid"'));
    }
  }

  const scaleBarPixels = 250 * mainMap.scale;
  const contextScalePixels = 1000 * contextMap.scale;
  const titleSuffix = diagnostic ? " — diagnostic chunk overlay" : "";
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${SVG_WIDTH}" height="${SVG_HEIGHT}" viewBox="0 0 ${SVG_WIDTH} ${SVG_HEIGHT}" role="img" aria-labelledby="title desc">
  <title id="title">Treasure Island whole-island source and derived coverage${xmlEscape(titleSuffix)}</title>
  <desc id="desc">Top-down evidence made from the actual generated mesh triangles. Treasure Island is shown north-up with its source boundary, all roads, major areas, terrain overlays, and building roofs. Yerba Buena Island and Bay Bridge context are isolated in an orientation inset.</desc>
  <style>
    text { font-family: Arial, sans-serif; fill: #25231f; }
    .title { font-size: 32px; font-weight: 700; letter-spacing: -0.4px; }
    .subtitle { font-size: 14px; fill: #625d54; }
    .section { font-size: 18px; font-weight: 700; }
    .legend { font-size: 14px; }
    .metric { font-size: 16px; font-weight: 650; }
    .detail { font-size: 13px; fill: #625d54; }
    .grid { stroke: #4c7598; stroke-width: 1; stroke-dasharray: 5 7; opacity: .42; }
  </style>
  <rect width="1600" height="1200" fill="#f7f5ef"/>
  <text x="65" y="54" class="title">Treasure Island — complete derived coverage</text>
  <text x="65" y="82" class="subtitle">North-up · Godot +X east / −Z north · generated content ${state.manifest.content_sha256.slice(0, 16)}…${xmlEscape(titleSuffix)}</text>
  <rect x="55" y="112" width="930" height="1038" rx="3" fill="#dbe8ed" stroke="#b7c7cc"/>
  <clipPath id="main-clip"><rect x="55" y="112" width="930" height="1038"/></clipPath>
  <g clip-path="url(#main-clip)" shape-rendering="geometricPrecision">
    <path id="derived-land" d="${rendered.landMain.path}" fill="#e6dfcf"/>
    <path id="derived-terrain" d="${rendered.terrainMain.path}" fill="#9fc8b2" fill-opacity=".88"/>
    <path id="derived-major-areas" d="${rendered.areasMain.path}" fill="#b8cf94" fill-opacity=".9"/>
    <path id="derived-roads" d="${rendered.roadsMain.path}" fill="#6d6860"/>
    <path id="derived-buildings" d="${rendered.buildingsMain.path}" fill="#a95f49"/>
    <path id="derived-building-parts" d="${rendered.buildingPartsMain.path}" fill="#713b32"/>
    <path id="boundary-attached-context" d="${rendered.attachedMain.path}" fill="#5ba6aa" fill-opacity=".72" stroke="#357a80" stroke-width="1"/>
    ${grid.join("\n    ")}
    <path id="source-boundary" d="${sourceMain}" fill="none" stroke="#f09a42" stroke-width="5" stroke-dasharray="11 7" stroke-linejoin="round"/>
    <path id="derived-boundary" d="${derivedMain}" fill="none" stroke="#263f58" stroke-width="2" stroke-linejoin="round"/>
  </g>
  <g aria-label="orientation and scale">
    <path d="M920 160L920 212M920 160L907 183M920 160L933 183" fill="none" stroke="#25231f" stroke-width="3"/>
    <text x="920" y="146" text-anchor="middle" class="section">N</text>
    ${line(105, 1098, 105 + scaleBarPixels, 1098, 'stroke="#25231f" stroke-width="5"')}
    ${line(105, 1089, 105, 1107, 'stroke="#25231f" stroke-width="3"')}
    ${line(105 + scaleBarPixels, 1089, 105 + scaleBarPixels, 1107, 'stroke="#25231f" stroke-width="3"')}
    <text x="${number(105 + scaleBarPixels / 2)}" y="1081" text-anchor="middle" class="legend">250 m</text>
    <text x="930" y="1124" text-anchor="end" class="detail">east →</text>
  </g>
  <g aria-label="legend">
    <text x="1030" y="145" class="section">Actual generated layers</text>
    ${legendItem(1032, 182, "#e6dfcf", "continuous land mesh")}
    ${legendItem(1032, 216, "#9fc8b2", "shoreline / terrain overlays")}
    ${legendItem(1032, 250, "#b8cf94", "major areas")}
    ${legendItem(1032, 284, "#6d6860", "all road / path ribbons")}
    ${legendItem(1032, 318, "#a95f49", "building roofs")}
    ${legendItem(1032, 352, "#713b32", "building-part roofs")}
    ${legendItem(1032, 386, "#5ba6aa", "boundary-attached visual context")}
    ${legendItem(1032, 420, "#f09a42", "exact source polygon", { outline: true, dash: true })}
    ${legendItem(1032, 454, "#263f58", "derived playable edge", { outline: true })}
    ${diagnostic ? legendItem(1032, 488, "#4c7598", "256 m chunk grid", { outline: true, dash: true }) : ""}
  </g>
  <g aria-label="context orientation inset">
    <text x="1030" y="535" class="section">Context orientation — non-playable</text>
    <rect x="1015" y="548" width="540" height="472" fill="#dbe8ed" stroke="#b7c7cc"/>
    <clipPath id="context-clip"><rect x="1015" y="548" width="540" height="472"/></clipPath>
    <g clip-path="url(#context-clip)" shape-rendering="geometricPrecision">
      <path d="${sourceContext}" fill="#e6dfcf" stroke="#263f58" stroke-width="2"/>
      <path id="context-ybi" d="${rendered.ybiContext.path}" fill="#9c927d"/>
      <path id="context-bridge" d="${rendered.bridgeContext.path}" fill="#665e57"/>
      <path d="${rendered.attachedContext.path}" fill="#5ba6aa"/>
    </g>
    <text x="${number(tiLabel[0])}" y="${number(tiLabel[1] - 10)}" text-anchor="middle" class="legend">Treasure Island</text>
    <text x="${number(ybiLabel[0])}" y="${number(ybiLabel[1])}" text-anchor="middle" class="legend">YBI</text>
    <text x="1355" y="963" class="detail">Bay Bridge anchor-derived context</text>
    ${line(1060, 982, 1060 + contextScalePixels, 982, 'stroke="#25231f" stroke-width="4"')}
    ${line(1060, 974, 1060, 990, 'stroke="#25231f" stroke-width="2"')}
    ${line(1060 + contextScalePixels, 974, 1060 + contextScalePixels, 990, 'stroke="#25231f" stroke-width="2"')}
    <text x="${number(1060 + contextScalePixels / 2)}" y="967" text-anchor="middle" class="detail">1 km</text>
  </g>
  <g aria-label="coverage totals">
    <text x="1030" y="1064" class="metric">739 canonical sources · 735 playable + 4 context</text>
    <text x="1030" y="1092" class="detail">427 roads/paths · 80 major areas · 213 buildings + 2 parts</text>
    <text x="1030" y="1116" class="detail">All 38 chunks rendered · zero unresolved · YBI excluded from playable records</text>
    <text x="1030" y="1140" class="detail">Vertical wall triangles omitted only from this top-down projection; roofs show every footprint.</text>
  </g>
</svg>
`;
}

function pngDimensions(buffer) {
  const signature = "89504e470d0a1a0a";
  invariant(buffer.subarray(0, 8).toString("hex") === signature, "Rendered PNG signature is invalid");
  return [buffer.readUInt32BE(16), buffer.readUInt32BE(20)];
}

function renderPng(svgPath, pngPath) {
  const version = spawnSync("magick", ["-version"], { encoding: "utf8" });
  if (version.error?.code === "ENOENT") return { produced: false, renderer: null, dimensions_px: null };
  invariant(version.status === 0, `ImageMagick version check failed: ${version.stderr}`);
  const result = spawnSync("magick", [
    "-font", "/System/Library/Fonts/Supplemental/Arial.ttf",
    "-background", "#f7f5ef",
    svgPath,
    "-alpha", "remove",
    "-alpha", "off",
    "-strip",
    "-define", "png:exclude-chunk=date,time",
    pngPath,
  ], { encoding: "utf8" });
  invariant(result.status === 0, `ImageMagick SVG rendering failed: ${result.stderr}`);
  const dimensions = pngDimensions(readFileSync(pngPath));
  invariant(dimensions[0] === SVG_WIDTH && dimensions[1] === SVG_HEIGHT, `Unexpected PNG dimensions ${dimensions.join("x")}`);
  return {
    produced: true,
    renderer: version.stdout.split("\n")[0].trim(),
    dimensions_px: dimensions,
  };
}

function categoryCompleteness(state, category) {
  const rows = state.coverageRows.filter((row) => row.scope === "playable" && splitValues(row.categories).includes(category));
  const physicalKeys = [...new Set(rows.flatMap((row) => splitValues(row.part_keys)))].sort();
  return {
    expected_rows: EXPECTED_CATEGORY_COUNTS[category],
    observed_rows: rows.length,
    rows_with_resolved_physical_parts: rows.filter((row) => splitValues(row.part_keys).every((key) => state.physicalByKey.has(key))).length,
    unique_physical_record_keys: physicalKeys.length,
    result: "pass",
  };
}

function evidenceSummary(state, pngResult, svgDescriptors) {
  const statusTotals = Object.fromEntries(
    [...new Set(state.coverageRows.map((row) => row.derived_world_status))].sort().map((status) => [
      status,
      state.coverageRows.filter((row) => row.derived_world_status === status).length,
    ]),
  );
  const majorAreaRows = state.coverageRows.filter((row) =>
    row.scope === "playable" && splitValues(row.categories).includes("major_area"));
  const majorAreaVisualModes = { area_or_terrain_layer: 0, building_mass: 0, boundary_attached_context: 0 };
  for (const row of majorAreaRows) {
    const records = splitValues(row.part_keys).map((key) => state.physicalByKey.get(key).record);
    if (records.some((record) => ["major_area", "terrain_overlay"].includes(record.feature_kind))) {
      majorAreaVisualModes.area_or_terrain_layer += 1;
    } else if (records.some((record) => ["building_roof", "building_wall"].includes(record.feature_kind))) {
      majorAreaVisualModes.building_mass += 1;
    } else if (records.every((record) => record.context_kind === "boundary_attached_visual")) {
      majorAreaVisualModes.boundary_attached_context += 1;
    } else throw new Error(`${row.source_key} has an unexplained major-area visual mode`);
  }
  invariant(Object.values(majorAreaVisualModes).reduce((sum, count) => sum + count, 0) === 80, "Major-area visual-mode count drift");
  return {
    schema_version: "ti.coverage-evidence/1",
    result: "pass",
    inputs: {
      ...state.inputDescriptors,
      generated_content_sha256: state.manifest.content_sha256,
    },
    counts: {
      source_rows: state.sourceRows.length,
      coverage_rows: state.coverageRows.length,
      playable_rows: state.coverageRows.filter((row) => row.scope === "playable").length,
      context_rows: state.coverageRows.filter((row) => row.scope === "context").length,
      unresolved_rows: 0,
      duplicate_source_keys: 0,
      chunks: state.chunks.length,
      physical_records: state.physicalByKey.size,
      playable_chunk_records: state.chunkRecords.length,
      status_totals: statusTotals,
      category_memberships: state.categoryCounts,
    },
    representation_completeness: Object.fromEntries(
      Object.keys(EXPECTED_CATEGORY_COUNTS).sort().map((category) => [category, categoryCompleteness(state, category)]),
    ),
    explicit_checks: {
      exact_source_polygon_matches_manifest_boundary_at_0_001m: true,
      every_coverage_part_key_resolves_to_a_physical_record: true,
      all_427_roads_have_a_road_path_record: true,
      all_80_major_areas_have_visible_generated_geometry: true,
      major_area_visual_modes: majorAreaVisualModes,
      all_213_buildings_have_a_roof_record: true,
      both_building_parts_have_a_part_roof_record: true,
      ybi_source_key_absent_from_playable_chunks: true,
      context_source_keys: [...EXPECTED_CONTEXT_KEYS].sort(),
      boundary_attached_visual_source_keys: [...EXPECTED_BOUNDARY_ATTACHED_KEYS],
    },
    derived_feature_kinds: state.kindStats,
    extents: {
      units: "meters from manifest origin; x=east, north=-world_z",
      ...state.extents,
    },
    render_policy: {
      source: "actual generated chunk/context triangle records",
      orientation: "north-up; east-right",
      playable_layers: ["land_ground", "terrain_overlay", "major_area", "road_path", "building_roof", "building_part_roof"],
      excluded_from_top_down_fill: ["building_wall", "building_part_wall"],
      exclusion_reason: "Vertical wall triangles have zero top-down area; their corresponding generated roofs show every footprint.",
      context_is_separate_and_non_playable: true,
      png: pngResult,
      artifacts: svgDescriptors,
    },
  };
}

function renderOnce(root, worldRoot) {
  mkdirSync(root, { recursive: true });
  const state = validateWorld(worldRoot);
  const cleanSvgPath = resolve(root, "whole-island-derived.svg");
  const diagnosticSvgPath = resolve(root, "whole-island-diagnostic.svg");
  writeText(cleanSvgPath, renderSvg(state, false));
  writeText(diagnosticSvgPath, renderSvg(state, true));
  const pngPath = resolve(root, "whole-island-derived.png");
  const pngResult = renderPng(cleanSvgPath, pngPath);
  const renderArtifacts = [
    descriptor(root, "whole-island-derived.svg"),
    descriptor(root, "whole-island-diagnostic.svg"),
  ];
  if (pngResult.produced) renderArtifacts.push(descriptor(root, "whole-island-derived.png"));
  const summary = evidenceSummary(state, pngResult, renderArtifacts);
  writeText(resolve(root, "coverage-comparison-summary.json"), stableJson(summary));
  const readme = `# Whole-island visual coverage evidence

This evidence is deterministically rendered from the actual generated chunk and context triangle records for content \`${state.manifest.content_sha256}\`. It does not read Godot scenes, invent geometry, or mutate generated data.

- \`whole-island-derived.svg\`: clean north-up source/derived comparison with every playable visible layer and a separate context-orientation inset.
- \`whole-island-derived.png\`: rasterization of the clean SVG for visual inspection.
- \`whole-island-diagnostic.svg\`: the same view with the 256 m chunk grid.
- \`coverage-comparison-summary.json\`: independent source-ledger, artifact-hash, physical-reference, category, context-isolation, and extent checks.
- \`determinism-report.json\`: hashes from two clean evidence renders compared byte-for-byte.

The source polygon and derived playable edge coincide at the established 0.001 m coordinate precision. Building roofs represent footprint coverage in plan view; vertical wall triangles are intentionally not filled because they project to zero area from above.

Rebuild and validate with:

\`\`\`sh
node tools/render_world_coverage_evidence.mjs
node tools/render_world_coverage_evidence.mjs --validate-only evidence/first-playable/coverage
\`\`\`
`;
  writeText(resolve(root, "README.md"), readme);
  return state;
}

function inventory(root) {
  return listFiles(root).map((path) => descriptor(root, path));
}

function compareTrees(first, second) {
  const firstInventory = inventory(first);
  const secondInventory = inventory(second);
  invariant(stableJson(firstInventory) === stableJson(secondInventory), "Clean evidence renders differ by path, size, or SHA-256");
  for (const file of firstInventory) {
    invariant(readFileSync(resolve(first, file.path)).equals(readFileSync(resolve(second, file.path))), `Clean evidence renders differ at ${file.path}`);
  }
  return firstInventory;
}

function validateEvidence(evidenceRoot, worldRoot) {
  const state = validateWorld(worldRoot);
  const summary = JSON.parse(readFileSync(resolve(evidenceRoot, "coverage-comparison-summary.json"), "utf8"));
  invariant(summary.schema_version === "ti.coverage-evidence/1" && summary.result === "pass", "Evidence summary status drift");
  invariant(summary.inputs.generated_content_sha256 === state.manifest.content_sha256, "Evidence targets a different generated world");
  invariant(summary.counts.source_rows === 739 && summary.counts.playable_rows === 735 && summary.counts.context_rows === 4, "Evidence denominator drift");
  invariant(summary.counts.unresolved_rows === 0 && summary.counts.duplicate_source_keys === 0, "Evidence error counts are non-zero");
  invariant(stableJson(summary.counts.category_memberships) === stableJson(EXPECTED_CATEGORY_COUNTS), "Evidence category counts drift");
  invariant(Object.values(summary.representation_completeness).every((entry) => entry.result === "pass" && entry.observed_rows === entry.expected_rows && entry.rows_with_resolved_physical_parts === entry.expected_rows), "Evidence representation proof is incomplete");
  for (const artifact of summary.render_policy.artifacts) {
    invariant(stableJson(descriptor(evidenceRoot, artifact.path)) === stableJson(artifact), `Rendered artifact drift: ${artifact.path}`);
  }
  const cleanSvg = readFileSync(resolve(evidenceRoot, "whole-island-derived.svg"), "utf8");
  for (const requiredId of ["derived-land", "derived-terrain", "derived-major-areas", "derived-roads", "derived-buildings", "derived-building-parts", "source-boundary", "derived-boundary", "context-ybi", "context-bridge"]) {
    invariant(cleanSvg.includes(`id="${requiredId}"`), `SVG is missing ${requiredId}`);
  }
  invariant(!/generated_at|timestamp|\/Users\//u.test(cleanSvg), "SVG contains a timestamp or absolute user path");
  if (summary.render_policy.png.produced) {
    invariant(stableJson(pngDimensions(readFileSync(resolve(evidenceRoot, "whole-island-derived.png")))) === stableJson([SVG_WIDTH, SVG_HEIGHT]), "PNG dimension drift");
  }
  const determinism = JSON.parse(readFileSync(resolve(evidenceRoot, "determinism-report.json"), "utf8"));
  invariant(determinism.clean_renders === 2 && determinism.byte_identical === true, "Evidence determinism proof failed");
  invariant(stableJson(determinism.compared_files) === stableJson(inventory(evidenceRoot).filter((file) => file.path !== "determinism-report.json")), "Evidence determinism inventory drift");
  return { state, summary, determinism };
}

function commitDirectory(staging, output) {
  const backup = `${output}.previous-${process.pid}`;
  let movedOld = false;
  try {
    if (existsSync(output)) {
      renameSync(output, backup);
      movedOld = true;
    }
    renameSync(staging, output);
    if (movedOld) rmSync(backup, { recursive: true, force: true });
  } catch (error) {
    if (!existsSync(output) && movedOld && existsSync(backup)) renameSync(backup, output);
    throw error;
  }
}

function parseArguments(argv) {
  let world = DEFAULT_WORLD;
  let output = DEFAULT_OUTPUT;
  let validateOnly = null;
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--world") {
      invariant(argv[index + 1], "--world requires a path");
      world = resolve(projectRoot, argv[++index]);
    } else if (argument === "--output") {
      invariant(argv[index + 1], "--output requires a path");
      output = resolve(projectRoot, argv[++index]);
    } else if (argument === "--validate-only") {
      invariant(argv[index + 1], "--validate-only requires a path");
      validateOnly = resolve(projectRoot, argv[++index]);
    } else throw new Error(`Unknown argument ${argument}`);
  }
  return { world, output, validateOnly };
}

function main() {
  const { world, output, validateOnly } = parseArguments(process.argv.slice(2));
  if (validateOnly) {
    const validated = validateEvidence(validateOnly, world);
    process.stdout.write(stableJson({
      status: "valid",
      evidence: relative(projectRoot, validateOnly).replaceAll("\\", "/"),
      generated_content_sha256: validated.state.manifest.content_sha256,
      source_rows: validated.summary.counts.source_rows,
      playable_rows: validated.summary.counts.playable_rows,
      context_rows: validated.summary.counts.context_rows,
    }));
    return;
  }

  mkdirSync(dirname(output), { recursive: true });
  const runRoot = mkdtempSync(join(dirname(output), ".coverage-evidence-runs-"));
  let committed = false;
  try {
    const first = resolve(runRoot, "first");
    const second = resolve(runRoot, "second");
    const firstState = renderOnce(first, world);
    renderOnce(second, world);
    const comparedFiles = compareTrees(first, second);
    const determinismReport = {
      schema_version: "ti.coverage-evidence-determinism/1",
      clean_renders: 2,
      byte_identical: true,
      generated_content_sha256: firstState.manifest.content_sha256,
      compared_files: comparedFiles,
    };
    writeText(resolve(first, "determinism-report.json"), stableJson(determinismReport));
    writeText(resolve(second, "determinism-report.json"), stableJson(determinismReport));
    compareTrees(first, second);
    validateEvidence(first, world);
    commitDirectory(first, output);
    committed = true;
    const finalValidation = validateEvidence(output, world);
    process.stdout.write(stableJson({
      status: "rendered",
      evidence: relative(projectRoot, output).replaceAll("\\", "/"),
      generated_content_sha256: finalValidation.state.manifest.content_sha256,
      clean_renders: 2,
      byte_identical: true,
      files: listFiles(output).length,
      png: finalValidation.summary.render_policy.png.produced,
    }));
  } finally {
    if (!committed && existsSync(resolve(runRoot, "first"))) {
      // The incomplete first tree is confined to this task-owned staging root.
    }
    rmSync(runRoot, { recursive: true, force: true });
  }
}

main();
