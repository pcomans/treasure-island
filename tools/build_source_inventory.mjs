#!/usr/bin/env node

/**
 * Build the approach-neutral OSM source ledger required by the milestone brief.
 *
 * This does not create game geometry or select a runtime. It records which frozen
 * source objects must later be represented and leaves their derived status as
 * `not_started` until an approved implementation can supply evidence.
 */

import {
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { createHash } from "node:crypto";
import { spawnSync } from "node:child_process";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { tmpdir } from "node:os";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(scriptDirectory, "..");
const properPath = resolve(
  projectRoot,
  "data/osm/treasure-island-proper-2026-08-27.osm.pbf",
);
const rawPath = resolve(
  projectRoot,
  "data/osm/treasure-island-2026-08-27.osm",
);
const outputCsvPath = resolve(
  projectRoot,
  "data/osm/treasure-island-source-inventory.csv",
);
const outputSummaryPath = resolve(
  projectRoot,
  "data/osm/treasure-island-source-inventory-summary.json",
);

const PLAYABLE_BOUNDARY_ID = "w26767313";
const YBI_BOUNDARY_ID = "w26767311";
const SHARED_COASTLINE_ID = "w29399800";
const CONTEXT_IDS = new Map([
  [YBI_BOUNDARY_ID, "context_island"],
  ["w1011568818", "context_bridge"],
  ["r13543937", "context_bridge"],
  ["r13543938", "context_bridge"],
]);

const CATEGORY_ORDER = [
  "land_boundary",
  "terrain_shoreline",
  "roads_paths",
  "major_area",
  "building",
  "building_part",
  "context_island",
  "context_bridge",
];

function fail(message) {
  throw new Error(message);
}

function sha256(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

function exportGeoJsonSeq(inputPath, outputPath) {
  const result = spawnSync(
    "osmium",
    [
      "export",
      "-u",
      "type_id",
      "-a",
      "type,id,version,timestamp",
      "-f",
      "geojsonseq",
      "-o",
      outputPath,
      "--overwrite",
      inputPath,
    ],
    { encoding: "utf8" },
  );

  if (result.error) {
    fail(`Could not run osmium: ${result.error.message}`);
  }
  if (result.status !== 0) {
    fail(`osmium export failed for ${inputPath}: ${result.stderr.trim()}`);
  }
}

function parseGeoJsonSeq(path) {
  const byId = new Map();
  const lines = readFileSync(path, "utf8").split(/\r?\n/u);

  for (const rawLine of lines) {
    const line = rawLine.replace(/^\u001e/u, "").trim();
    if (!line) continue;

    const feature = JSON.parse(line);
    if (feature.type !== "Feature" || typeof feature.id !== "string") {
      fail(`Unexpected GeoJSON sequence record in ${path}`);
    }

    const properties = feature.properties ?? {};
    const prefixByType = { node: "n", way: "w", relation: "r" };
    const prefix = prefixByType[properties["@type"]];
    const sourceId = properties["@id"];
    if (!prefix || !Number.isInteger(sourceId)) {
      fail(`Missing original OSM type/id attributes in ${path}`);
    }
    // `osmium export -u type_id` uses an `a…` feature ID for polygon views of
    // ways/relations. Canonicalize on the original @type/@id so a source object
    // that has both line and area views still receives exactly one ledger row.
    const sourceKey = `${prefix}${sourceId}`;

    const existing = byId.get(sourceKey) ?? {
      id: sourceKey,
      properties,
      geometryTypes: new Set(),
    };
    if (feature.geometry?.type) existing.geometryTypes.add(feature.geometry.type);
    byId.set(sourceKey, existing);
  }

  return byId;
}

function decodeXmlAttribute(value) {
  return value
    .replaceAll("&quot;", '"')
    .replaceAll("&apos;", "'")
    .replaceAll("&lt;", "<")
    .replaceAll("&gt;", ">")
    .replaceAll("&amp;", "&")
    .replace(/&#(\d+);/gu, (_match, digits) =>
      String.fromCodePoint(Number(digits)),
    )
    .replace(/&#x([0-9a-f]+);/giu, (_match, digits) =>
      String.fromCodePoint(Number.parseInt(digits, 16)),
    );
}

function parseXmlAttributes(fragment) {
  const attributes = {};
  for (const match of fragment.matchAll(/([:\w-]+)="([^"]*)"/gu)) {
    attributes[match[1]] = decodeXmlAttribute(match[2]);
  }
  return attributes;
}

function sourceFromRawXml(rawXml, sourceKey) {
  const typeByPrefix = { n: "node", w: "way", r: "relation" };
  const sourceType = typeByPrefix[sourceKey[0]];
  const numericId = sourceKey.slice(1);
  if (!sourceType || !/^\d+$/u.test(numericId)) {
    fail(`Invalid OSM source key ${sourceKey}`);
  }

  const pattern = new RegExp(
    `<${sourceType}\\b([^>]*\\bid="${numericId}"[^>]*)>([\\s\\S]*?)<\\/${sourceType}>`,
    "u",
  );
  const match = rawXml.match(pattern);
  if (!match) return null;

  const attributes = parseXmlAttributes(match[1]);
  const properties = {
    "@type": sourceType,
    "@id": Number(numericId),
    "@version": Number(attributes.version ?? 0),
    "@timestamp": attributes.timestamp ?? "",
  };
  for (const tagMatch of match[2].matchAll(/<tag\b([^>]*)\/>/gu)) {
    const tagAttributes = parseXmlAttributes(tagMatch[1]);
    if (tagAttributes.k != null && tagAttributes.v != null) {
      properties[tagAttributes.k] = tagAttributes.v;
    }
  }

  return { id: sourceKey, properties, geometryTypes: new Set() };
}

function osmTypeFor(source) {
  return source.properties["@type"] ??
    ({ n: "node", w: "way", r: "relation" })[source.id[0]] ??
    "unknown";
}

function hasAreaGeometry(source) {
  return (
    source.geometryTypes.has("Polygon") ||
    source.geometryTypes.has("MultiPolygon")
  );
}

function classifyPlayable(source) {
  const tags = source.properties;
  const sourceType = osmTypeFor(source);
  const categories = [];

  if (source.id === PLAYABLE_BOUNDARY_ID) {
    categories.push("land_boundary");
  }

  const isTerrainOrShoreline =
    source.id === SHARED_COASTLINE_ID ||
    ["sand", "wetland"].includes(tags.natural) ||
    ["breakwater", "pier"].includes(tags.man_made) ||
    tags.leisure === "marina";
  if (
    isTerrainOrShoreline &&
    (sourceType === "way" || sourceType === "relation")
  ) {
    categories.push("terrain_shoreline");
  }

  if (sourceType === "way" && tags.highway != null) {
    categories.push("roads_paths");
  }

  const isMajorArea =
    hasAreaGeometry(source) &&
    (sourceType === "way" || sourceType === "relation") &&
    (tags.landuse != null || tags.leisure != null || tags.amenity != null);
  if (isMajorArea) categories.push("major_area");

  if (
    (sourceType === "way" || sourceType === "relation") &&
    tags.building != null
  ) {
    categories.push("building");
  }

  if (
    (sourceType === "way" || sourceType === "relation") &&
    tags["building:part"] != null
  ) {
    categories.push("building_part");
  }

  return CATEGORY_ORDER.filter((category) => categories.includes(category));
}

function stableTags(properties) {
  return Object.fromEntries(
    Object.entries(properties)
      .filter(([key]) => !key.startsWith("@"))
      .sort(([left], [right]) => left.localeCompare(right)),
  );
}

function primaryTag(tags, categories) {
  const priorityKeys = [
    "place",
    "natural",
    "man_made",
    "highway",
    "landuse",
    "leisure",
    "amenity",
    "building",
    "building:part",
  ];
  for (const key of priorityKeys) {
    if (tags[key] != null) return `${key}=${tags[key]}`;
  }
  return categories[0] ?? "";
}

function selectedGeometryFamily(source, categories) {
  if (
    categories.includes("land_boundary") ||
    categories.includes("major_area") ||
    categories.includes("building") ||
    categories.includes("building_part")
  ) {
    return "area";
  }
  if (categories.includes("roads_paths")) return "line";
  if (categories.includes("terrain_shoreline")) {
    return hasAreaGeometry(source) && source.id !== SHARED_COASTLINE_ID
      ? "area"
      : "line";
  }
  if (hasAreaGeometry(source)) return "area";
  if (source.geometryTypes.has("LineString")) return "line";
  return "collection";
}

function noteFor(id, categories, scope) {
  const notes = [];
  if (id === PLAYABLE_BOUNDARY_ID) {
    notes.push("Exact playable clipping polygon and land-shell source");
  }
  if (id === SHARED_COASTLINE_ID) {
    notes.push(
      `Spans TI and YBI; clip to or document composite representation by ${PLAYABLE_BOUNDARY_ID}`,
    );
  }
  if (categories.includes("building_part")) {
    notes.push("Resolve overlap with parent building without losing either source ID");
  }
  if (scope === "context") {
    notes.push("Non-playable context; excluded from playable completeness denominator");
  }
  return notes.join("; ");
}

function normalizedTimestamp(value) {
  if (typeof value === "number" || /^\d+$/u.test(String(value ?? ""))) {
    const milliseconds = Number(value) * 1000;
    if (Number.isFinite(milliseconds)) {
      return new Date(milliseconds).toISOString().replace(".000Z", "Z");
    }
  }
  return String(value ?? "");
}

function rowFor(source, scope, categories) {
  const properties = source.properties;
  const tags = stableTags(properties);
  return {
    source_key: source.id,
    osm_type: osmTypeFor(source),
    osm_id: String(properties["@id"] ?? source.id.slice(1)),
    source_version: String(properties["@version"] ?? ""),
    source_timestamp: normalizedTimestamp(properties["@timestamp"]),
    scope,
    categories: categories.join("|"),
    source_geometry_types: [...source.geometryTypes].sort().join("|"),
    selected_geometry_family: selectedGeometryFamily(source, categories),
    name: String(tags.name ?? ""),
    primary_tag: primaryTag(tags, categories),
    height: String(tags.height ?? ""),
    building_levels: String(tags["building:levels"] ?? ""),
    derived_world_status: "not_started",
    derived_object_key: "",
    notes: noteFor(source.id, categories, scope),
    tags_json: JSON.stringify(tags),
  };
}

function compareRows(left, right) {
  if (left.scope !== right.scope) return left.scope.localeCompare(right.scope);
  const leftCategory = CATEGORY_ORDER.indexOf(left.categories.split("|")[0]);
  const rightCategory = CATEGORY_ORDER.indexOf(right.categories.split("|")[0]);
  if (leftCategory !== rightCategory) return leftCategory - rightCategory;
  if (left.osm_type !== right.osm_type) {
    return left.osm_type.localeCompare(right.osm_type);
  }
  return Number(left.osm_id) - Number(right.osm_id);
}

function csvCell(value) {
  const stringValue = String(value ?? "");
  return `"${stringValue.replaceAll('"', '""')}"`;
}

function toCsv(rows) {
  if (rows.length === 0) fail("Refusing to write an empty source inventory");
  const headers = Object.keys(rows[0]);
  return `${headers.map(csvCell).join(",")}\n${rows
    .map((row) => headers.map((header) => csvCell(row[header])).join(","))
    .join("\n")}\n`;
}

function countMembership(rows, category) {
  return rows.filter((row) => row.categories.split("|").includes(category)).length;
}

function assertExpectedCounts(rows) {
  const playable = rows.filter((row) => row.scope === "playable");
  const context = rows.filter((row) => row.scope === "context");
  const expected = {
    land_boundary: 1,
    terrain_shoreline: 22,
    roads_paths: 427,
    major_area: 80,
    building: 213,
    building_part: 2,
    context: 4,
  };

  for (const [category, count] of Object.entries(expected)) {
    const actual =
      category === "context"
        ? context.length
        : countMembership(playable, category);
    if (actual !== count) {
      fail(`Expected ${count} ${category} rows, found ${actual}`);
    }
  }

  if (new Set(rows.map((row) => row.source_key)).size !== rows.length) {
    fail("Source inventory contains duplicate source keys");
  }
  if (!playable.some((row) => row.source_key === PLAYABLE_BOUNDARY_ID)) {
    fail(`Playable boundary ${PLAYABLE_BOUNDARY_ID} is missing`);
  }
  if (playable.some((row) => row.source_key === YBI_BOUNDARY_ID)) {
    fail(`YBI boundary ${YBI_BOUNDARY_ID} leaked into playable scope`);
  }
  if (!playable.some((row) => row.source_key === SHARED_COASTLINE_ID)) {
    fail(`Shared coastline ${SHARED_COASTLINE_ID} is missing`);
  }
  if (context.length !== CONTEXT_IDS.size) {
    fail("Context inventory does not match the explicit context ID set");
  }
}

function main() {
  const temporaryDirectory = mkdtempSync(join(tmpdir(), "ti-source-ledger-"));
  try {
    const properGeoJsonSeq = join(temporaryDirectory, "proper.geojsonseq");
    const rawGeoJsonSeq = join(temporaryDirectory, "raw.geojsonseq");
    exportGeoJsonSeq(properPath, properGeoJsonSeq);
    exportGeoJsonSeq(rawPath, rawGeoJsonSeq);

    const properSources = parseGeoJsonSeq(properGeoJsonSeq);
    const rawSources = parseGeoJsonSeq(rawGeoJsonSeq);
    const rawXml = readFileSync(rawPath, "utf8");
    const rows = [];

    for (const source of properSources.values()) {
      if (source.id === YBI_BOUNDARY_ID) continue;
      const categories = classifyPlayable(source);
      if (categories.length > 0) rows.push(rowFor(source, "playable", categories));
    }

    for (const [id, category] of CONTEXT_IDS) {
      const source = rawSources.get(id) ?? sourceFromRawXml(rawXml, id);
      if (!source) fail(`Context source ${id} is absent from the raw snapshot`);
      rows.push(rowFor(source, "context", [category]));
    }

    rows.sort(compareRows);
    assertExpectedCounts(rows);

    const playableRows = rows.filter((row) => row.scope === "playable");
    const contextRows = rows.filter((row) => row.scope === "context");
    const summary = {
      schema_version: 1,
      source: {
        raw_file: "data/osm/treasure-island-2026-08-27.osm",
        raw_sha256: sha256(rawPath),
        proper_file: "data/osm/treasure-island-proper-2026-08-27.osm.pbf",
        proper_sha256: sha256(properPath),
        playable_boundary: PLAYABLE_BOUNDARY_ID,
      },
      status: "source inventory only; no derived game geometry exists",
      one_row_per_source_key: true,
      counts: {
        total_unique_rows: rows.length,
        playable_unique_rows: playableRows.length,
        context_unique_rows: contextRows.length,
        playable_category_memberships: Object.fromEntries(
          CATEGORY_ORDER.filter((category) => !category.startsWith("context_"))
            .map((category) => [category, countMembership(playableRows, category)]),
        ),
        playable_rows_with_multiple_categories: playableRows.filter(
          (row) => row.categories.includes("|"),
        ).length,
        building_rows_missing_height_and_levels: playableRows.filter(
          (row) =>
            row.categories.split("|").includes("building") &&
            !row.height &&
            !row.building_levels,
        ).length,
      },
      validation: {
        all_rows_derived_world_status: "not_started",
        duplicate_source_keys: 0,
        ybi_in_playable_scope: false,
        shared_coastline_requires_ti_clip_or_composite: SHARED_COASTLINE_ID,
        context_ids: [...CONTEXT_IDS.keys()],
      },
    };

    writeFileSync(outputCsvPath, toCsv(rows), "utf8");
    writeFileSync(outputSummaryPath, `${JSON.stringify(summary, null, 2)}\n`, "utf8");
    process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
  } finally {
    rmSync(temporaryDirectory, { recursive: true, force: true });
  }
}

main();
