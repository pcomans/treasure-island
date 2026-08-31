import { createHash } from "node:crypto";
import { readFileSync, statSync } from "node:fs";

export const WORLD_SCHEMA = "ti.godot-world/2";
export const CHUNK_SCHEMA = "ti.godot-world-chunk/2";
export const CONTEXT_SCHEMA = "ti.godot-world-context/2";
export const GENERATOR_VERSION = "2.1.0";

export const SOURCE_CONTRACT = Object.freeze({
  raw_osm: Object.freeze({
    path: "data/osm/treasure-island-2026-08-27.osm",
    sha256: "3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549",
    bytes: 5_594_888,
  }),
  extraction_polygon: Object.freeze({
    path: "data/osm/treasure-island-polygon.geojson",
    sha256: "43adbe335e87f0d839b56c2f5933ae97d35d4f588ce93bd09923a98620dd2b63",
  }),
  proper_extract: Object.freeze({
    path: "data/osm/treasure-island-proper-2026-08-27.osm.pbf",
    sha256: "13984ed8f70c9d5d39d4ba14f83c7307eb75428af7b07df5774df29bda4ccaf9",
    bytes: 103_207,
  }),
  source_ledger: Object.freeze({
    path: "data/osm/treasure-island-source-inventory.csv",
    sha256: "fdf57f37f5507a7cb9b64a7fc530eabb22e29f3742324d5347c0f6b1949cb4cb",
    bytes: 195_590,
  }),
  source_summary: Object.freeze({
    path: "data/osm/treasure-island-source-inventory-summary.json",
    sha256: "49eb5c9fadd1b81b3fd687beb59cd9f917eb197069bcb993f5a0a3f2588d90d7",
    bytes: 1_220,
  }),
  terrain_dem: Object.freeze({
    path: "data/terrain/treasure-island-ybi-usgs-3dep-2023.tif",
    sha256: "3af54acdd116f3e253af8ece5ec501a08dff94cfca47b7f05f2c326c9ba33f3f",
    bytes: 10_160_678,
  }),
});

export const PLAYABLE_BOUNDARY_SOURCE_KEY = "w26767313";
export const YBI_SOURCE_KEY = "w26767311";
export const SHARED_COASTLINE_SOURCE_KEY = "w29399800";
export const BOUNDARY_ATTACHED_SOURCE_KEYS = Object.freeze([
  "w319406837",
  "w644986117",
]);
export const BRIDGE_SOURCE_KEYS = Object.freeze([
  "r13543937",
  "r13543938",
  "w1011568818",
]);
export const ISLE_HOUSE_PARENT_KEY = "w1249412094";
export const ISLE_HOUSE_PART_KEYS = Object.freeze([
  "w1282547786",
  "w1282547787",
]);

// Frozen OSM anchors for the Treasure Island ferry arrival. The named floating
// terminal is outside the exact playable polygon, so the spawn is derived from
// its in-bound landing connection and the Waterfront Plaza approach instead.
export const FERRY_SPAWN_SOURCE_KEYS = Object.freeze({
  terminal_stop: "n9335172179",
  terminal_platform: "w1036802529",
  terminal_platform_footway: "w1036802526",
  terminal_access_footway: "w1036802527",
  landing_pier: "w1011830367",
  waterfront_plaza_footway: "w1222514694",
  landing_connection: "n9551738109",
});
export const FERRY_SPAWN_INLAND_DISTANCE_M = 8;
export const PLAYER_CAPSULE_RADIUS_M = 0.35;
export const SPAWN_SAFETY_MARGIN_M = 0.65;
// Keep this synchronized with the player scene's 5.5 m SpringArm3D length
// plus its 0.15 m collision margin.
export const SPAWN_CAMERA_BOOM_CLEARANCE_M = 5.65;

export const CATEGORY_MEMBERSHIPS = Object.freeze({
  land_boundary: 1,
  terrain_shoreline: 22,
  roads_paths: 427,
  major_area: 80,
  building: 213,
  building_part: 2,
});

export const EXPECTED_COUNTS = Object.freeze({
  source_rows: 739,
  playable_rows: 735,
  context_rows: 4,
  multi_category_playable_rows: 10,
});

export const CHUNK_SIZE_M = 256;
export const COORDINATE_ROUNDING_M = 0.001;
export const TERRAIN_MESH_GRID_SIZE_M = 32;
export const TERRAIN_VERTICAL_DATUM = "NAVD 88";

export const ROAD_WIDTHS_M = Object.freeze({
  tertiary: 8,
  residential: 6,
  unclassified: 6,
  service: 4,
  pedestrian: 4,
  track: 3,
  cycleway: 3,
  platform: 3,
  footway: 2,
  path: 2,
});

// These classes affect only the generated pavement skin. They do not add
// access rules, collision, vehicle semantics, or change any source footprint.
export const ROAD_VISUAL_CLASSES = Object.freeze({
  vehicle: Object.freeze([
    "residential",
    "service",
    "tertiary",
    "track",
    "unclassified",
  ]),
  pedestrian: Object.freeze([
    "cycleway",
    "footway",
    "path",
    "pedestrian",
    "platform",
  ]),
});

export const ROAD_SURFACE_BIASES_M = Object.freeze({
  base: 0.078,
  pedestrian: 0.08,
});

export const FEATURE_KINDS = Object.freeze([
  "building_part_roof",
  "building_part_wall",
  "building_roof",
  "building_wall",
  "land_ground",
  "major_area",
  "road_path",
  "terrain_overlay",
]);

export const MATERIAL_KEYS = Object.freeze([
  "building_part_roof",
  "building_part_wall",
  "building_roof",
  "building_wall",
  "land_ground",
  "major_area_amenity",
  "major_area_landuse",
  "major_area_leisure",
  "major_area_paved",
  "road_path",
  "road_path_pedestrian",
  "terrain_breakwater",
  "terrain_marina",
  "terrain_pier",
  "terrain_sand",
  "terrain_wetland",
]);

export const COVERAGE_HEADERS = Object.freeze([
  "source_key",
  "osm_type",
  "osm_id",
  "scope",
  "categories",
  "source_version",
  "derived_world_status",
  "derived_object_key",
  "part_keys",
  "chunk_ids",
  "representation_kind",
  "dimension_rule",
  "height_m",
  "composite_key",
  "note",
  "vertex_count",
  "triangle_count",
  "collision_triangle_count",
  "validation",
]);

export function invariant(condition, message) {
  if (!condition) throw new Error(message);
}

export function sha256Bytes(value) {
  return createHash("sha256").update(value).digest("hex");
}

export function sha256File(path) {
  return sha256Bytes(readFileSync(path));
}

export function sourceDescriptor(projectRoot, contract) {
  const absolutePath = `${projectRoot}/${contract.path}`;
  return {
    path: contract.path,
    sha256: sha256File(absolutePath),
    bytes: statSync(absolutePath).size,
  };
}

export function verifySourceContract(projectRoot) {
  const descriptors = {};
  for (const [name, contract] of Object.entries(SOURCE_CONTRACT)) {
    const descriptor = sourceDescriptor(projectRoot, contract);
    invariant(
      descriptor.sha256 === contract.sha256,
      `Source hash drift for ${contract.path}: expected ${contract.sha256}, found ${descriptor.sha256}`,
    );
    if (contract.bytes != null) {
      invariant(
        descriptor.bytes === contract.bytes,
        `Source byte-count drift for ${contract.path}: expected ${contract.bytes}, found ${descriptor.bytes}`,
      );
    }
    descriptors[name] = descriptor;
  }
  return descriptors;
}

export function parseCsv(text) {
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
        } else {
          quoted = false;
        }
      } else {
        cell += character;
      }
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
    } else {
      cell += character;
    }
  }

  invariant(!quoted, "Malformed CSV: unterminated quoted cell");
  if (cell.length > 0 || record.length > 0) {
    record.push(cell);
    records.push(record);
  }
  invariant(records.length >= 2, "CSV must contain a header and data rows");
  const headers = records[0];
  invariant(new Set(headers).size === headers.length, "CSV contains duplicate headers");
  return records.slice(1).map((values, rowIndex) => {
    invariant(
      values.length === headers.length,
      `CSV row ${rowIndex + 2} has ${values.length} cells; expected ${headers.length}`,
    );
    return Object.fromEntries(headers.map((header, index) => [header, values[index]]));
  });
}

export function csvCell(value) {
  return `"${String(value ?? "").replaceAll('"', '""')}"`;
}

export function serializeCsv(rows, headers = COVERAGE_HEADERS) {
  invariant(rows.length > 0, "Refusing to serialize an empty CSV");
  return `${headers.map(csvCell).join(",")}\n${rows
    .map((row) => headers.map((header) => csvCell(row[header])).join(","))
    .join("\n")}\n`;
}

export function stableJson(value) {
  return `${JSON.stringify(sortJson(value), null, 2)}\n`;
}

export function sortJson(value) {
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

export function roundCoordinate(value) {
  invariant(Number.isFinite(value), `Non-finite coordinate ${value}`);
  const rounded = Math.round(value * 1000) / 1000;
  return Object.is(rounded, -0) ? 0 : rounded;
}

export function roundMeasure(value) {
  return roundCoordinate(value);
}

export function compareSourceKeys(left, right) {
  const prefixOrder = { n: 0, w: 1, r: 2 };
  const leftPrefix = left[0];
  const rightPrefix = right[0];
  if (leftPrefix !== rightPrefix) {
    return (prefixOrder[leftPrefix] ?? 99) - (prefixOrder[rightPrefix] ?? 99);
  }
  return Number(left.slice(1)) - Number(right.slice(1));
}

export function contentIndexSha256(files) {
  const hash = createHash("sha256");
  for (const file of [...files].sort((left, right) => left.path.localeCompare(right.path))) {
    hash.update(`${file.path}\0${file.sha256}\0${file.bytes}\n`, "utf8");
  }
  return hash.digest("hex");
}

export function chunkId(x, z) {
  invariant(Number.isInteger(x) && Number.isInteger(z), "Chunk indices must be integers");
  return `x_${x}__z_${z}`;
}

export function compareChunkIds(left, right) {
  const pattern = /^x_(-?\d+)__z_(-?\d+)$/u;
  const leftMatch = left.match(pattern);
  const rightMatch = right.match(pattern);
  invariant(leftMatch && rightMatch, `Invalid chunk id: ${left} or ${right}`);
  return Number(leftMatch[1]) - Number(rightMatch[1]) ||
    Number(leftMatch[2]) - Number(rightMatch[2]);
}
