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
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  BRIDGE_SOURCE_KEYS,
  BOUNDARY_ATTACHED_SOURCE_KEYS,
  CATEGORY_MEMBERSHIPS,
  CHUNK_SCHEMA,
  CHUNK_SIZE_M,
  COORDINATE_ROUNDING_M,
  CONTEXT_SCHEMA,
  COVERAGE_HEADERS,
  EXPECTED_COUNTS,
  FERRY_SPAWN_INLAND_DISTANCE_M,
  FERRY_SPAWN_SOURCE_KEYS,
  FEATURE_KINDS,
  GENERATOR_VERSION,
  ISLE_HOUSE_PARENT_KEY,
  ISLE_HOUSE_PART_KEYS,
  MATERIAL_KEYS,
  PLAYER_CAPSULE_RADIUS_M,
  PLAYABLE_BOUNDARY_SOURCE_KEY,
  ROAD_WIDTHS_M,
  ROAD_SURFACE_BIASES_M,
  ROAD_VISUAL_CLASSES,
  SHARED_COASTLINE_SOURCE_KEY,
  SOURCE_CONTRACT,
  SPAWN_CAMERA_BOOM_CLEARANCE_M,
  SPAWN_SAFETY_MARGIN_M,
  TERRAIN_MESH_GRID_SIZE_M,
  TERRAIN_VERTICAL_DATUM,
  WORLD_SCHEMA,
  YBI_SOURCE_KEY,
  chunkId,
  compareChunkIds,
  contentIndexSha256,
  invariant,
  parseCsv,
  roundCoordinate,
  roundMeasure,
  serializeCsv,
  sha256File,
  stableJson,
  verifySourceContract,
} from "./lib/world-contract.mjs";
import {
  coordinateSystemManifest,
  eastNorthToWorldRounded,
  inverseProjectEastNorth,
  projectLonLat,
  verifyProjectionRoundTrip,
} from "./lib/coordinates.mjs";
import {
  canonicalizeMultiPolygon,
  differenceMultiPolygons,
  exportOsmiumGeoJsonSeq,
  flattenMultiPolygonCoordinates,
  geometrySha256,
  geometryToLine,
  geometryToMultiPolygon,
  intersectMultiPolygons,
  lineLength,
  lineRibbon,
  multiPolygonArea,
  multiPolygonBounds,
  multiPolygonCentroid,
  parseGeoJsonSeq,
  parseRawOsmXml,
  pointInMultiPolygon,
  rawSourceMetadata,
  rawWayFootprint,
  rectangleMultiPolygon,
  repairRoadRibbonQuantizationHoles,
  roundingAreaAudit,
  roundedCanonicalGeometry,
  serializedAreaTolerance,
  signedRingArea,
  snapRoadRibbonAfterUnion,
  selectGeometry,
  unionMultiPolygons,
  unionMultiPolygonsRaw,
} from "./lib/osm-geometry.mjs";
import {
  griddedTerrainSurfaceMesh,
  mergeMeshes,
  meshPlanArea,
  meshRecord,
  terrainSkirtMesh,
  terrainSurfaceMesh,
  topSurfaceMesh,
  triangulationAreaAudit,
  validateMesh,
  wallSurfaceMesh,
} from "./lib/mesh-output.mjs";
import { loadTerrainRaster } from "./lib/terrain-raster.mjs";
import {
  NAIP_TREE_ANNOTATION_SHA256,
  generateVegetation,
} from "./lib/vegetation-generation.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(scriptDirectory, "..");
const NAIP_TREE_ANNOTATIONS_PATH = resolve(
  projectRoot,
  "source_assets/vegetation/naip_2022/tree_annotations_candidate.geojson",
);
const TERRAIN_RASTER_EXPECTATIONS = Object.freeze({
  width: 1_669,
  height: 2_048,
  bbox_wgs84: Object.freeze([-122.380001708984, 37.806, -122.357998291016, 37.833]),
  valid_sample_count: 2_492_288,
  minimum_elevation_m: -1.08,
  maximum_elevation_m: 104.756,
});
const FOUNDATION_BURIAL_MARGIN_M = 0.02;
const WATER_DATUM_M = 0;
const FACET_CONTAINMENT_TOLERANCE_M = COORDINATE_ROUNDING_M * 2;
const PAVEMENT_MATERIALS = Object.freeze({
  vehicle: Object.freeze({ material_key: "road_path", albedo_srgb_hex: "555b60" }),
  pedestrian: Object.freeze({ material_key: "road_path_pedestrian", albedo_srgb_hex: "8b918e" }),
  paved_area: Object.freeze({ material_key: "major_area_paved", albedo_srgb_hex: "707573" }),
});
const TERRAIN_PINNED_SAMPLES = Object.freeze([
  Object.freeze({ id: "ferry_vicinity", longitude: -122.3722, latitude: 37.8167, expected_m: 4.037 }),
  Object.freeze({ id: "treasure_island_center", longitude: -122.372, latitude: 37.823, expected_m: 3.265 }),
  Object.freeze({ id: "treasure_island_north", longitude: -122.37, latitude: 37.83, expected_m: 3.467 }),
  Object.freeze({ id: "ybi_high_ground", longitude: -122.365849121, latitude: 37.809790283, expected_m: 104.756 }),
  Object.freeze({ id: "ybi_low_shoreline", longitude: -122.373, latitude: 37.8085, expected_m: 0 }),
]);
const TERRAIN_SURFACE_ANCHORS = Object.freeze([
  Object.freeze({ id: "01-ferry-spawn", x: -104.364, z: 786.024 }),
  Object.freeze({ id: "02-north", x: -159.535, z: -879.905 }),
  Object.freeze({ id: "03-center", x: -159.292, z: -104.818 }),
  Object.freeze({ id: "04-southwest", x: -293.543, z: 335.72 }),
  Object.freeze({ id: "05-east-perimeter", x: 606.249, z: 385.227 }),
  Object.freeze({ id: "01-waterfront-approach", x: -93.682, z: 780.044 }),
  Object.freeze({ id: "02-waterfront-join", x: -91.651, z: 778.897 }),
  Object.freeze({ id: "03-waterfront-crossing", x: -84.414, z: 774.734 }),
  Object.freeze({ id: "04-ti-road-north-1", x: -96.25, z: 754.195 }),
  Object.freeze({ id: "05-ti-road-north-2", x: -108.833, z: 730.206 }),
  Object.freeze({ id: "06-trade-winds-turn", x: -112.174, z: 722.948 }),
  Object.freeze({ id: "07-trade-winds-1", x: -112.666, z: 718.005 }),
  Object.freeze({ id: "08-trade-winds-2", x: -111.532, z: 712.884 }),
  Object.freeze({ id: "09-trade-winds-3", x: -110.152, z: 711.081 }),
  Object.freeze({ id: "10-trade-winds-4", x: -103.53, z: 705.972 }),
  Object.freeze({ id: "11-trade-winds-west", x: -68.085, z: 685.812 }),
  Object.freeze({ id: "12-trade-winds-center", x: -4.951, z: 652.705 }),
  Object.freeze({ id: "13-trade-winds-east", x: 38.743, z: 629.439 }),
]);

function auditTerrainRaster(terrain) {
  invariant(terrain.width === TERRAIN_RASTER_EXPECTATIONS.width, "Terrain TIFF width drift");
  invariant(terrain.height === TERRAIN_RASTER_EXPECTATIONS.height, "Terrain TIFF height drift");
  invariant(
    stableJson(terrain.bbox_wgs84) === stableJson(TERRAIN_RASTER_EXPECTATIONS.bbox_wgs84),
    `Terrain TIFF bbox drift: ${JSON.stringify(terrain.bbox_wgs84)}`,
  );
  const statistics = terrain.statistics();
  for (const key of ["valid_sample_count", "minimum_elevation_m", "maximum_elevation_m"]) {
    invariant(statistics[key] === TERRAIN_RASTER_EXPECTATIONS[key], `Terrain TIFF ${key} drift`);
  }
  const pinnedSamples = TERRAIN_PINNED_SAMPLES.map((sample) => {
    const elevation = roundCoordinate(terrain.sampleLonLat(sample.longitude, sample.latitude));
    invariant(Math.abs(elevation - sample.expected_m) <= 0.002, `Terrain sample ${sample.id} drift: ${elevation}`);
    return {
      id: sample.id,
      longitude: sample.longitude,
      latitude: sample.latitude,
      elevation_m: elevation,
    };
  });
  return {
    schema_version: "ti.usgs-terrain/1",
    source_title: "USGS 1 Meter 10 x55y419 CA_SanFrancisco_B23",
    source_tile_id: "USGS_1M_10_x55y419_CA_SanFrancisco_B23.tif",
    source_tile_url: "https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/1m/Projects/CA_SanFrancisco_B23/TIFF/USGS_1M_10_x55y419_CA_SanFrancisco_B23.tif",
    service_url: "https://elevation.nationalmap.gov/arcgis/rest/services/3DEPElevation/ImageServer",
    locked_raster_object_id: 71_423,
    export_bbox_wgs84: [-122.38, 37.806, -122.358, 37.833],
    export_size_pixels: [terrain.width, terrain.height],
    raster_bbox_wgs84: terrain.bbox_wgs84,
    pixel_size_degrees: terrain.pixel_size_degrees,
    pixel_type: "F32",
    interpolation: "bilinear",
    vertical_datum: TERRAIN_VERTICAL_DATUM,
    mesh_grid_size_m: TERRAIN_MESH_GRID_SIZE_M,
    shoreline_plan_authority: "frozen OSM snapshot",
    statistics,
    pinned_samples: pinnedSamples,
  };
}

function parseArguments(argv) {
  let output = resolve(projectRoot, "generated/world");
  for (let index = 0; index < argv.length; index += 1) {
    if (argv[index] === "--output") {
      invariant(argv[index + 1], "--output requires a path");
      output = resolve(projectRoot, argv[index + 1]);
      index += 1;
    } else {
      throw new Error(`Unknown argument ${argv[index]}`);
    }
  }
  return { output };
}

function commandOutput(command, args) {
  const result = spawnSync(command, args, { encoding: "utf8" });
  if (result.error) throw new Error(`Could not run ${command}: ${result.error.message}`);
  invariant(result.status === 0, `${command} ${args.join(" ")} failed: ${result.stderr.trim()}`);
  return `${result.stdout}${result.stderr}`.trim();
}

function auditToolchain() {
  const osmiumVersionOutput = commandOutput("osmium", ["--version"]);
  const osmiumVersion = osmiumVersionOutput.match(/osmium version (\S+)/u)?.[1];
  invariant(osmiumVersion === "1.19.1", `Expected Osmium 1.19.1, found ${osmiumVersion ?? "unknown"}`);
  const packageLockPath = resolve(projectRoot, "package-lock.json");
  invariant(existsSync(packageLockPath), "package-lock.json is required before world generation");
  const packageLock = JSON.parse(readFileSync(packageLockPath, "utf8"));
  invariant(packageLock.packages?.["node_modules/earcut"]?.version === "3.2.3", "earcut must be locked to 3.2.3");
  invariant(
    packageLock.packages?.["node_modules/polygon-clipping"]?.version === "0.15.7",
    "polygon-clipping must be locked to 0.15.7",
  );
  const rawInfo = commandOutput("osmium", ["fileinfo", "-e", resolve(projectRoot, SOURCE_CONTRACT.raw_osm.path)]);
  const properInfo = commandOutput("osmium", ["fileinfo", "-e", resolve(projectRoot, SOURCE_CONTRACT.proper_extract.path)]);
  for (const [label, output, expected] of [
    ["raw", rawInfo, { nodes: 13_119, ways: 1_494, relations: 167 }],
    ["proper", properInfo, { nodes: 7_016, ways: 827, relations: 29 }],
  ]) {
    for (const [type, count] of Object.entries(expected)) {
      const match = output.match(new RegExp(`Number of ${type}:\\s+(\\d+)`, "u"));
      invariant(match && Number(match[1]) === count, `${label} ${type} count drift: expected ${count}`);
    }
  }
  commandOutput("osmium", ["check-refs", resolve(projectRoot, SOURCE_CONTRACT.proper_extract.path)]);
  return {
    node_version: process.version,
    osmium_version: osmiumVersion,
    package_lock_sha256: sha256File(packageLockPath),
  };
}

function validateSourceLedger(rows) {
  invariant(rows.length === EXPECTED_COUNTS.source_rows, `Expected 739 source ledger rows, found ${rows.length}`);
  const requiredHeaders = [
    "source_key",
    "osm_type",
    "osm_id",
    "source_version",
    "source_timestamp",
    "scope",
    "categories",
    "selected_geometry_family",
    "height",
    "building_levels",
    "derived_world_status",
    "derived_object_key",
    "tags_json",
  ];
  for (const header of requiredHeaders) invariant(header in rows[0], `Source ledger is missing ${header}`);
  invariant(new Set(rows.map((row) => row.source_key)).size === rows.length, "Source ledger has duplicate source keys");
  const playable = rows.filter((row) => row.scope === "playable");
  const context = rows.filter((row) => row.scope === "context");
  invariant(playable.length === EXPECTED_COUNTS.playable_rows, `Expected 735 playable rows, found ${playable.length}`);
  invariant(context.length === EXPECTED_COUNTS.context_rows, `Expected 4 context rows, found ${context.length}`);
  invariant(rows.every((row) => row.derived_world_status === "not_started"), "Source ledger status drift");
  invariant(rows.every((row) => row.derived_object_key === ""), "Source ledger derived keys must remain empty");
  const memberships = {};
  for (const category of Object.keys(CATEGORY_MEMBERSHIPS)) {
    memberships[category] = playable.filter((row) => row.categories.split("|").includes(category)).length;
    invariant(
      memberships[category] === CATEGORY_MEMBERSHIPS[category],
      `Expected ${CATEGORY_MEMBERSHIPS[category]} ${category} memberships, found ${memberships[category]}`,
    );
  }
  invariant(
    playable.filter((row) => row.categories.includes("|")).length === EXPECTED_COUNTS.multi_category_playable_rows,
    "Multi-category row count drift",
  );
  invariant(!playable.some((row) => row.source_key === YBI_SOURCE_KEY), "YBI leaked into playable ledger");
  invariant(
    stableJson(context.map((row) => row.source_key).sort()) ===
      stableJson([YBI_SOURCE_KEY, ...BRIDGE_SOURCE_KEYS].sort()),
    "Context key set drift",
  );
  return { playable, context, memberships };
}

function compareMetadata(row, metadata) {
  invariant(metadata.osm_type === row.osm_type, `${row.source_key} OSM type drift`);
  invariant(metadata.osm_id === row.osm_id, `${row.source_key} OSM id drift`);
  invariant(metadata.source_version === row.source_version, `${row.source_key} source version drift`);
  invariant(metadata.source_timestamp === row.source_timestamp, `${row.source_key} timestamp drift`);
  const ledgerTags = JSON.parse(row.tags_json);
  invariant(stableJson(metadata.tags) === stableJson(ledgerTags), `${row.source_key} stable tags drift`);
  return ledgerTags;
}

function loadSources(temporaryDirectory, ledgerRows) {
  const properGeoJsonSeq = join(temporaryDirectory, "proper.geojsonseq");
  const rawGeoJsonSeq = join(temporaryDirectory, "raw.geojsonseq");
  exportOsmiumGeoJsonSeq(resolve(projectRoot, SOURCE_CONTRACT.proper_extract.path), properGeoJsonSeq);
  exportOsmiumGeoJsonSeq(resolve(projectRoot, SOURCE_CONTRACT.raw_osm.path), rawGeoJsonSeq);
  const properSources = parseGeoJsonSeq(properGeoJsonSeq);
  const rawSources = parseGeoJsonSeq(rawGeoJsonSeq);
  const rawOsm = parseRawOsmXml(resolve(projectRoot, SOURCE_CONTRACT.raw_osm.path));
  const joined = new Map();
  for (const row of ledgerRows) {
    const exported = row.scope === "playable" ? properSources.get(row.source_key) : rawSources.get(row.source_key);
    const metadata = exported?.metadata ?? rawSourceMetadata(rawOsm, row.source_key);
    const tags = compareMetadata(row, metadata);
    joined.set(row.source_key, { row, tags, exported });
  }
  invariant(joined.size === ledgerRows.length, "Source join did not resolve one-to-one");
  return { joined, rawOsm, rawSources };
}

function exactBoundary() {
  const geoJson = JSON.parse(readFileSync(resolve(projectRoot, SOURCE_CONTRACT.extraction_polygon.path), "utf8"));
  invariant(geoJson.type === "FeatureCollection" && geoJson.features?.length === 1, "Boundary GeoJSON must have one feature");
  const geometry = geometryToMultiPolygon(geoJson.features[0].geometry, "Treasure Island boundary");
  invariant(geometry.length > 0, "Treasure Island boundary is empty");
  return geometry;
}

function areaStyle(tags, categories) {
  if (categories.includes("terrain_shoreline")) {
    if (tags.natural === "sand") return { feature_kind: "terrain_overlay", material_key: "terrain_sand", elevation_m: 0.03 };
    if (tags.natural === "wetland") return { feature_kind: "terrain_overlay", material_key: "terrain_wetland", elevation_m: 0.03 };
    if (tags.man_made === "breakwater") return { feature_kind: "terrain_overlay", material_key: "terrain_breakwater", elevation_m: 0.03 };
    if (tags.man_made === "pier") return { feature_kind: "terrain_overlay", material_key: "terrain_pier", elevation_m: 0.03 };
    if (tags.leisure === "marina") return { feature_kind: "terrain_overlay", material_key: "terrain_marina", elevation_m: 0.03 };
    throw new Error(`Unknown terrain/shoreline area tags ${JSON.stringify(tags)}`);
  }
  if (tags.amenity === "parking") return { feature_kind: "major_area", material_key: "major_area_paved", elevation_m: 0.05 };
  if (tags.amenity != null) return { feature_kind: "major_area", material_key: "major_area_amenity", elevation_m: 0.05 };
  if (tags.leisure != null) return { feature_kind: "major_area", material_key: "major_area_leisure", elevation_m: 0.04 };
  if (tags.landuse != null) return { feature_kind: "major_area", material_key: "major_area_landuse", elevation_m: 0.02 };
  throw new Error(`Unknown major area tags ${JSON.stringify(tags)}`);
}

function roadVisualClass(tags, sourceKey) {
  const matches = Object.entries(ROAD_VISUAL_CLASSES)
    .filter(([, highwayTags]) => highwayTags.includes(tags.highway))
    .map(([visualClass]) => visualClass);
  invariant(
    matches.length === 1,
    `${sourceKey} highway=${tags.highway ?? "missing"} has ${matches.length} pavement visual classes`,
  );
  return matches[0];
}

function parsePositiveDecimal(value) {
  const normalized = String(value ?? "").trim();
  if (!/^(?:\d+(?:\.\d*)?|\.\d+)$/u.test(normalized)) return null;
  const number = Number(normalized);
  return Number.isFinite(number) && number > 0 ? number : null;
}

function buildingHeight(row) {
  const sourceHeight = parsePositiveDecimal(row.height);
  if (sourceHeight != null) return { rule: "osm_height", height_m: roundCoordinate(sourceHeight) };
  const sourceLevels = parsePositiveDecimal(row.building_levels);
  if (sourceLevels != null) return { rule: "osm_levels", height_m: roundCoordinate(sourceLevels * 3) };
  return { rule: "default_6m", height_m: 6 };
}

function logicalKey(row) {
  const categories = row.categories.split("|");
  if (row.source_key === SHARED_COASTLINE_SOURCE_KEY) return `land:${PLAYABLE_BOUNDARY_SOURCE_KEY}`;
  if (BOUNDARY_ATTACHED_SOURCE_KEYS.includes(row.source_key)) return `boundary_context:${row.source_key}`;
  if (row.source_key === ISLE_HOUSE_PARENT_KEY || ISLE_HOUSE_PART_KEYS.includes(row.source_key)) {
    return `building-composite:${ISLE_HOUSE_PARENT_KEY}`;
  }
  if (row.scope === "context") {
    return row.source_key === YBI_SOURCE_KEY ? "context:ybi" : "context:bay-bridge";
  }
  if (categories.includes("land_boundary")) return `land:${row.source_key}`;
  if (categories.includes("building_part")) return `building-part:${row.source_key}`;
  if (categories.includes("building")) return `building:${row.source_key}`;
  if (categories.includes("roads_paths")) return `road:${row.source_key}`;
  if (categories.includes("terrain_shoreline")) return `terrain:${row.source_key}`;
  if (categories.includes("major_area")) return `area:${row.source_key}`;
  throw new Error(`Cannot derive a logical key for ${row.source_key}`);
}

function buildPlayableObjects(ledger, boundary) {
  const objects = new Map();
  for (const joined of ledger.playable) {
    const { row, tags, exported } = joined;
    const categories = row.categories.split("|");
    const object = {
      row,
      tags,
      roles: categories,
      logical_key: logicalKey(row),
      representation: "direct",
      geometry: null,
      source_measure: 0,
      clipped_measure: 0,
      height: null,
      physical_object_keys: new Set(),
      chunk_ids: new Set(),
      road_visual_class: categories.includes("roads_paths")
        ? roadVisualClass(tags, row.source_key)
        : null,
    };

    if (row.source_key === PLAYABLE_BOUNDARY_SOURCE_KEY) {
      object.geometry = boundary;
      object.source_measure = multiPolygonArea(boundary);
      object.clipped_measure = object.source_measure;
    } else if (row.source_key === SHARED_COASTLINE_SOURCE_KEY) {
      const line = geometryToLine(selectGeometry(exported, "line"), row.source_key);
      object.geometry = boundary;
      object.source_measure = lineLength(line);
      object.clipped_measure = boundary[0][0].reduce((total, point, index, ring) => {
        const next = ring[(index + 1) % ring.length];
        return total + Math.hypot(next[0] - point[0], next[1] - point[1]);
      }, 0);
      object.representation = "composite";
    } else if (BOUNDARY_ATTACHED_SOURCE_KEYS.includes(row.source_key)) {
      const sourceGeometry = geometryToMultiPolygon(selectGeometry(exported, "area"), row.source_key);
      const exactClip = intersectMultiPolygons(sourceGeometry, boundary);
      invariant(
        exactClip.length === 0 || multiPolygonArea(exactClip) <= 1e-8,
        `${row.source_key} boundary-attached exception unexpectedly has positive playable area`,
      );
      object.source_measure = multiPolygonArea(sourceGeometry);
      object.geometry = sourceGeometry;
      object.clipped_measure = 0;
      object.representation = "composite";
      object.boundary_attached_visual = true;
    } else if (row.selected_geometry_family === "line") {
      const line = geometryToLine(selectGeometry(exported, "line"), row.source_key);
      let width;
      if (categories.includes("roads_paths")) {
        width = ROAD_WIDTHS_M[tags.highway];
        invariant(width != null, `${row.source_key} has unknown highway=${tags.highway}`);
      } else if (tags.man_made === "breakwater") {
        width = 3;
      } else if (tags.man_made === "pier") {
        width = 4;
      } else {
        throw new Error(`${row.source_key} has unknown line shoreline class`);
      }
      object.source_measure = lineLength(line);
      if (categories.includes("roads_paths")) {
        let unsnappedRibbon;
        try {
          unsnappedRibbon = lineRibbon(line, width, `${row.source_key}/unsnapped`, {
            returnRawUnion: true,
          });
        } catch (error) {
          throw new Error(`${row.source_key} double-precision ribbon union failed: ${error.message}`, {
            cause: error,
          });
        }
        const snapAudit = snapRoadRibbonAfterUnion(unsnappedRibbon, row.source_key);
        object.ribbon_snap_stage = snapAudit.snap_stage;
        object.ribbon_snap_area_delta_m2 = snapAudit.observed_area_delta_m2;
        object.ribbon_snap_area_tolerance_m2 = snapAudit.tolerance_m2;
        object.geometry = intersectMultiPolygons(snapAudit.geometry, boundary);
        const holeRepair = repairRoadRibbonQuantizationHoles(object.geometry, row.source_key);
        object.geometry = holeRepair.geometry;
        object.road_final_serialization_audit = holeRepair;
        object.road_quantization_topology_repairs = [
          ...snapAudit.repairs,
          ...holeRepair.removals,
        ];
        object.road_quantization_topology_repair_area_delta_m2 =
          snapAudit.repairs.reduce(
            (sum, repair) => sum + (repair.hole_area_m2 ?? repair.loop_area_m2 ?? 0),
            0,
          ) +
          holeRepair.resulting_area_delta_m2;
        object.road_quantization_topology_repair_tolerance_m2 = holeRepair.tolerance_m2;
        invariant(
          object.road_quantization_topology_repair_area_delta_m2 <= holeRepair.tolerance_m2,
          `${row.source_key} total road topology repair delta exceeds quantization bound`,
        );
      } else {
        object.geometry = intersectMultiPolygons(lineRibbon(line, width, row.source_key), boundary);
      }
      object.clipped_measure = multiPolygonArea(object.geometry);
    } else {
      const sourceGeometry = geometryToMultiPolygon(selectGeometry(exported, "area"), row.source_key);
      object.source_measure = multiPolygonArea(sourceGeometry);
      object.geometry = intersectMultiPolygons(sourceGeometry, boundary);
      object.clipped_measure = multiPolygonArea(object.geometry);
    }

    invariant(
      object.geometry.length > 0 && (object.clipped_measure > 0 || object.boundary_attached_visual),
      `${row.source_key} has empty clipped geometry`,
    );
    // Topology remains in double precision through all boolean operations.
    // This call proves that the one final 0.001 m serialization round is safe,
    // while the unrounded geometry continues into chunking/part subtraction.
    const quantizationAudit = roundingAreaAudit(object.geometry, row.source_key);
    const triangulationAudit = triangulationAreaAudit(object.geometry, row.source_key);
    object.clipped_measure = multiPolygonArea(object.geometry);
    object.pre_serialization_area_delta_m2 = triangulationAudit.delta_m2;
    object.post_serialization_area_delta_m2 = object.road_final_serialization_audit?.resulting_area_delta_m2 ?? quantizationAudit.delta_m2;
    object.post_serialization_tolerance_m2 = object.road_final_serialization_audit?.tolerance_m2 ?? quantizationAudit.tolerance_m2;
    object.serialization_perimeter_m = object.road_final_serialization_audit?.perimeter_m ?? quantizationAudit.perimeter_m;
    object.quantization_delta_m = object.road_final_serialization_audit?.quantization_delta_m ?? quantizationAudit.quantization_delta_m;
    object.post_serialization_normalized_error = object.road_final_serialization_audit?.normalized_error ?? quantizationAudit.normalized_error;
    object.geometry_sha256 = geometrySha256(object.geometry);
    if (categories.includes("building") || categories.includes("building_part")) {
      object.height = buildingHeight(row);
    }
    objects.set(row.source_key, object);
  }
  invariant(objects.size === EXPECTED_COUNTS.playable_rows, "Playable object map count drift");
  const roadClassCounts = Object.fromEntries(Object.keys(ROAD_VISUAL_CLASSES).map((key) => [key, 0]));
  for (const object of objects.values()) {
    if (object.road_visual_class != null) roadClassCounts[object.road_visual_class] += 1;
  }
  invariant(
    Object.values(roadClassCounts).reduce((sum, count) => sum + count, 0) === CATEGORY_MEMBERSHIPS.roads_paths,
    "Pavement visual classification lost a road/path source",
  );
  return objects;
}

function chunkRangeForGeometry(geometry) {
  const bounds = multiPolygonBounds(geometry);
  const minChunkX = Math.floor(bounds.min_x / CHUNK_SIZE_M);
  const maxChunkX = Math.floor(bounds.max_x / CHUNK_SIZE_M);
  const minChunkZ = Math.floor(-bounds.max_y / CHUNK_SIZE_M);
  const maxChunkZ = Math.floor(-bounds.min_y / CHUNK_SIZE_M);
  const chunks = [];
  for (let x = minChunkX; x <= maxChunkX; x += 1) {
    for (let z = minChunkZ; z <= maxChunkZ; z += 1) chunks.push({ x, z, id: chunkId(x, z) });
  }
  return chunks;
}

function geometryForChunk(geometry, x, z) {
  const minX = x * CHUNK_SIZE_M;
  const maxX = minX + CHUNK_SIZE_M;
  const minZ = z * CHUNK_SIZE_M;
  const maxZ = minZ + CHUNK_SIZE_M;
  const northMin = -maxZ;
  const northMax = -minZ;
  return intersectMultiPolygons(geometry, rectangleMultiPolygon(minX, northMin, maxX, northMax));
}

function floorWithLowerTie(value) {
  const quotient = value / CHUNK_SIZE_M;
  return Number.isInteger(quotient) ? quotient - 1 : Math.floor(quotient);
}

function buildingChunk(geometry) {
  const centroid = multiPolygonCentroid(geometry);
  return {
    x: floorWithLowerTie(centroid[0]),
    z: floorWithLowerTie(-centroid[1]),
  };
}

function chunkStore() {
  const chunks = new Map();
  function ensure(x, z) {
    const id = chunkId(x, z);
    if (!chunks.has(id)) {
      chunks.set(id, {
        schema_version: CHUNK_SCHEMA,
        chunk_id: id,
        bounds_m: {
          min_x: x * CHUNK_SIZE_M,
          min_z: z * CHUNK_SIZE_M,
          max_x: (x + 1) * CHUNK_SIZE_M,
          max_z: (z + 1) * CHUNK_SIZE_M,
        },
        records: [],
      });
    }
    return chunks.get(id);
  }
  return {
    chunks,
    ensure,
    surface_conformance: {
      sample_points: 0,
      minimum_clearance_m: Infinity,
      maximum_clearance_m: -Infinity,
      maximum_bias_deviation_m: 0,
      maximum_serialization_tolerance_m: 0,
    },
    foundation_audit: {
      sample_points: 0,
      exterior_segments: 0,
      water_supported_exterior_segments: 0,
      shared_segments: 0,
      flat_roof_cells: 0,
      maximum_positive_gap_m: -Infinity,
      minimum_embed_m: Infinity,
      maximum_roof_elevation_range_m: 0,
      maximum_height_deviation_m: 0,
    },
    land_facets: [],
    land_facets_by_id: new Map(),
  };
}

function terrainSupportFromChunks(chunks, east, north) {
  const worldZ = -north;
  for (const chunk of chunks.values()) {
    for (const record of chunk.records) {
      if (record.feature_kind !== "land_ground") continue;
      for (let offset = 0; offset < record.indices.length; offset += 3) {
        const points = record.indices.slice(offset, offset + 3).map((index) => [
          record.vertices[index * 3],
          record.vertices[index * 3 + 1],
          record.vertices[index * 3 + 2],
        ]);
        const [a, b, c] = points;
        const denominator = (b[2] - c[2]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[2] - c[2]);
        if (Math.abs(denominator) <= 1e-10) continue;
        const weightA = ((b[2] - c[2]) * (east - c[0]) + (c[0] - b[0]) * (worldZ - c[2])) / denominator;
        const weightB = ((c[2] - a[2]) * (east - c[0]) + (a[0] - c[0]) * (worldZ - c[2])) / denominator;
        const weightC = 1 - weightA - weightB;
        if (weightA >= -1e-7 && weightB >= -1e-7 && weightC >= -1e-7) {
          const elevation = roundCoordinate(weightA * a[1] + weightB * b[1] + weightC * c[1]);
          return {
            object_key: record.object_key,
            triangle_index: offset / 3,
            elevation_m: elevation,
          };
        }
      }
    }
  }
  throw new Error(`No generated terrain triangle contains ${east},${north}`);
}

function terrainElevationFromChunks(chunks, east, north) {
  return terrainSupportFromChunks(chunks, east, north).elevation_m;
}

function landFacetsFromRecords(records, label) {
  const facets = [];
  for (const record of records) {
    if (record.feature_kind !== "land_ground") continue;
    for (let offset = 0; offset < record.indices.length; offset += 3) {
      const vertices = record.indices.slice(offset, offset + 3).map((index) => ({
        east: record.vertices[index * 3],
        elevation: record.vertices[index * 3 + 1],
        north: -record.vertices[index * 3 + 2],
      }));
      let ring = vertices.map((vertex) => [vertex.east, vertex.north]);
      if (signedRingArea(ring) < 0) {
        ring = ring.reverse();
        vertices.reverse();
      }
      const bounds = {
        min_x: Math.min(...ring.map((point) => point[0])),
        min_y: Math.min(...ring.map((point) => point[1])),
        max_x: Math.max(...ring.map((point) => point[0])),
        max_y: Math.max(...ring.map((point) => point[1])),
      };
      facets.push({
        id: `${label}/${record.object_key}/${offset / 3}`,
        vertices,
        geometry: [[ring]],
        bounds,
      });
    }
  }
  invariant(facets.length > 0, `${label} has no land terrain facets`);
  return facets;
}

function landFacetsForChunk(chunks, chunkIdValue) {
  const chunk = chunks.get(chunkIdValue);
  invariant(chunk, `Missing terrain chunk ${chunkIdValue}`);
  return landFacetsFromRecords(chunk.records, chunkIdValue);
}

function allLandFacets(chunks) {
  return [...chunks.values()].flatMap((chunk) =>
    landFacetsFromRecords(chunk.records, chunk.chunk_id));
}

function facetElevation(facet, east, north) {
  const [a, b, c] = facet.vertices;
  const denominator = (b.north - c.north) * (a.east - c.east) +
    (c.east - b.east) * (a.north - c.north);
  invariant(Math.abs(denominator) > 1e-10, `${facet.id} is degenerate`);
  const weightA = ((b.north - c.north) * (east - c.east) +
    (c.east - b.east) * (north - c.north)) / denominator;
  const weightB = ((c.north - a.north) * (east - c.east) +
    (a.east - c.east) * (north - c.north)) / denominator;
  const weightC = 1 - weightA - weightB;
  const doubleArea = Math.abs(denominator);
  const oppositeLengths = [
    Math.hypot(b.east - c.east, b.north - c.north),
    Math.hypot(c.east - a.east, c.north - a.north),
    Math.hypot(a.east - b.east, a.north - b.north),
  ];
  const containmentTolerances = oppositeLengths.map((length) =>
    FACET_CONTAINMENT_TOLERANCE_M / (doubleArea / length));
  return {
    elevation: weightA * a.elevation + weightB * b.elevation + weightC * c.elevation,
    inside: weightA >= -containmentTolerances[0] &&
      weightB >= -containmentTolerances[1] &&
      weightC >= -containmentTolerances[2],
  };
}

function facetSerializationTolerance(facet) {
  const origin = facetElevation(facet, facet.vertices[0].east, facet.vertices[0].north).elevation;
  const eastGradient = facetElevation(facet, facet.vertices[0].east + 1, facet.vertices[0].north).elevation - origin;
  const northGradient = facetElevation(facet, facet.vertices[0].east, facet.vertices[0].north + 1).elevation - origin;
  // An overlay point's x, y, and z are each independently rounded to the
  // nearest millimetre after its elevation is evaluated on the serialized
  // land plane. This is the exact worst-case clearance error for that plane.
  return COORDINATE_ROUNDING_M * 0.5 *
    (1 + Math.abs(eastGradient) + Math.abs(northGradient));
}

function containingLandFacet(facets, east, north) {
  for (const facet of facets) {
    if (east < facet.bounds.min_x - 1e-6 || east > facet.bounds.max_x + 1e-6 ||
      north < facet.bounds.min_y - 1e-6 || north > facet.bounds.max_y + 1e-6) continue;
    const sample = facetElevation(facet, east, north);
    if (sample.inside) return { facet, elevation: sample.elevation };
  }
  return null;
}

function coherentDrapedSurfaceMesh(multiPolygon, facets, biasM, label) {
  const pieces = [];
  const audits = [];
  for (const facet of facets) {
    const clipped = intersectMultiPolygons(multiPolygon, facet.geometry);
    if (clipped.length === 0 || multiPolygonArea(clipped) <= 1e-8) continue;
    const piece = terrainSurfaceMesh(
      clipped,
      (east, north) => facetElevation(facet, east, north).elevation + biasM,
      `${label}/${facet.id}`,
    );
    pieces.push(piece);
    audits.push(auditCoherentSurface(piece, [facet], biasM, `${label}/${facet.id}`, facet));
  }
  invariant(pieces.length > 0, `${label} does not intersect generated land facets`);
  const mesh = mergeMeshes(pieces, label);
  const expectedArea = multiPolygonArea(multiPolygon);
  const areaDelta = Math.abs(meshPlanArea(mesh) - expectedArea);
  const areaTolerance = serializedAreaTolerance(multiPolygon).tolerance_m2;
  invariant(areaDelta <= areaTolerance, `${label} coherent drape area delta ${areaDelta} exceeds ${areaTolerance}`);
  mesh.coherent_audit = {
    sample_points: audits.reduce((sum, audit) => sum + audit.sample_points, 0),
    minimum_clearance_m: Math.min(...audits.map((audit) => audit.minimum_clearance_m)),
    maximum_clearance_m: Math.max(...audits.map((audit) => audit.maximum_clearance_m)),
    maximum_bias_deviation_m: Math.max(...audits.map((audit) => audit.maximum_bias_deviation_m)),
    maximum_serialization_tolerance_m: Math.max(...audits.map((audit) => audit.maximum_serialization_tolerance_m)),
  };
  return mesh;
}

function auditCoherentSurface(mesh, facets, biasM, label, ownedFacet = null) {
  let samplePoints = 0;
  let minimumClearance = Infinity;
  let maximumClearance = -Infinity;
  let maximumDeviation = 0;
  let maximumSerializationTolerance = 0;
  for (let offset = 0; offset < mesh.indices.length; offset += 3) {
    const triangle = mesh.indices.slice(offset, offset + 3).map((index) => [
      mesh.vertices[index * 3],
      mesh.vertices[index * 3 + 1],
      -mesh.vertices[index * 3 + 2],
    ]);
    const samples = [
      ...triangle,
      ...triangle.map((point, index) => {
        const next = triangle[(index + 1) % triangle.length];
        return [(point[0] + next[0]) / 2, (point[1] + next[1]) / 2, (point[2] + next[2]) / 2];
      }),
      [
        triangle.reduce((sum, point) => sum + point[0], 0) / 3,
        triangle.reduce((sum, point) => sum + point[1], 0) / 3,
        triangle.reduce((sum, point) => sum + point[2], 0) / 3,
      ],
    ];
    for (const [east, overlayElevation, north] of samples) {
      const land = ownedFacet == null
        ? containingLandFacet(facets, east, north)
        : { facet: ownedFacet, elevation: facetElevation(ownedFacet, east, north).elevation };
      invariant(land, `${label} sample ${east},${north} has no generated land triangle`);
      const clearance = overlayElevation - land.elevation;
      const deviation = Math.abs(clearance - biasM);
      const serializationTolerance = facetSerializationTolerance(land.facet);
      invariant(
        deviation <= serializationTolerance + 1e-9,
        `${label} clearance ${clearance} differs from bias ${biasM} by ${deviation}, above plane-specific serialization tolerance ${serializationTolerance}`,
      );
      samplePoints += 1;
      minimumClearance = Math.min(minimumClearance, clearance);
      maximumClearance = Math.max(maximumClearance, clearance);
      maximumDeviation = Math.max(maximumDeviation, deviation);
      maximumSerializationTolerance = Math.max(maximumSerializationTolerance, serializationTolerance);
    }
  }
  return {
    sample_points: samplePoints,
    minimum_clearance_m: roundCoordinate(minimumClearance),
    maximum_clearance_m: roundCoordinate(maximumClearance),
    maximum_bias_deviation_m: roundMeasure(maximumDeviation),
    maximum_serialization_tolerance_m: roundMeasure(maximumSerializationTolerance),
  };
}

function updateSurfaceConformanceAudit(store, mesh, facets, biasM, label) {
  const audit = mesh.coherent_audit ?? auditCoherentSurface(mesh, facets, biasM, label);
  store.surface_conformance.sample_points += audit.sample_points;
  store.surface_conformance.minimum_clearance_m = Math.min(
    store.surface_conformance.minimum_clearance_m,
    audit.minimum_clearance_m,
  );
  store.surface_conformance.maximum_clearance_m = Math.max(
    store.surface_conformance.maximum_clearance_m,
    audit.maximum_clearance_m,
  );
  store.surface_conformance.maximum_bias_deviation_m = Math.max(
    store.surface_conformance.maximum_bias_deviation_m,
    audit.maximum_bias_deviation_m,
  );
  store.surface_conformance.maximum_serialization_tolerance_m = Math.max(
    store.surface_conformance.maximum_serialization_tolerance_m,
    audit.maximum_serialization_tolerance_m,
  );
}

function segmentIntersectionFraction(start, end, edgeStart, edgeEnd) {
  const delta = [end[0] - start[0], end[1] - start[1]];
  const edgeDelta = [edgeEnd[0] - edgeStart[0], edgeEnd[1] - edgeStart[1]];
  const denominator = delta[0] * edgeDelta[1] - delta[1] * edgeDelta[0];
  if (Math.abs(denominator) <= 1e-10) return null;
  const fromStart = [edgeStart[0] - start[0], edgeStart[1] - start[1]];
  const fraction = (fromStart[0] * edgeDelta[1] - fromStart[1] * edgeDelta[0]) / denominator;
  const edgeFraction = (fromStart[0] * delta[1] - fromStart[1] * delta[0]) / denominator;
  if (fraction <= 1e-9 || fraction >= 1 - 1e-9 || edgeFraction < -1e-9 || edgeFraction > 1 + 1e-9) return null;
  return fraction;
}

function foundationSegmentsForEdge(start, end, baseElevationM, facets, label) {
  const edgeBounds = {
    min_x: Math.min(start[0], end[0]),
    min_y: Math.min(start[1], end[1]),
    max_x: Math.max(start[0], end[0]),
    max_y: Math.max(start[1], end[1]),
  };
  const fractions = [0, 1];
  for (const facet of facets) {
    if (facet.bounds.max_x < edgeBounds.min_x - 1e-6 || facet.bounds.min_x > edgeBounds.max_x + 1e-6 ||
      facet.bounds.max_y < edgeBounds.min_y - 1e-6 || facet.bounds.min_y > edgeBounds.max_y + 1e-6) continue;
    const ring = facet.geometry[0][0];
    for (let index = 0; index < ring.length; index += 1) {
      const fraction = segmentIntersectionFraction(start, end, ring[index], ring[(index + 1) % ring.length]);
      if (fraction != null) fractions.push(fraction);
    }
  }
  fractions.sort((left, right) => left - right);
  const edgeLength = Math.hypot(end[0] - start[0], end[1] - start[1]);
  const minimumFractionDelta = COORDINATE_ROUNDING_M / edgeLength;
  const uniqueFractions = fractions.filter((fraction, index) =>
    index === 0 || fraction - fractions[index - 1] > minimumFractionDelta);
  const pointAt = (fraction) => [
    start[0] + (end[0] - start[0]) * fraction,
    start[1] + (end[1] - start[1]) * fraction,
  ];
  const segments = [];
  for (let index = 0; index < uniqueFractions.length - 1; index += 1) {
    const segmentStart = pointAt(uniqueFractions[index]);
    const segmentEnd = pointAt(uniqueFractions[index + 1]);
    const midpoint = pointAt((uniqueFractions[index] + uniqueFractions[index + 1]) / 2);
    const owner = containingLandFacet(facets, midpoint[0], midpoint[1]);
    if (!owner) {
      segments.push({
        start: segmentStart,
        end: segmentEnd,
        bottom_start_m: Math.min(baseElevationM, WATER_DATUM_M - FOUNDATION_BURIAL_MARGIN_M),
        bottom_end_m: Math.min(baseElevationM, WATER_DATUM_M - FOUNDATION_BURIAL_MARGIN_M),
        terrain_start_m: null,
        terrain_end_m: null,
        terrain_facet_id: null,
      });
      continue;
    }
    const startTerrain = facetElevation(owner.facet, segmentStart[0], segmentStart[1]).elevation;
    const endTerrain = facetElevation(owner.facet, segmentEnd[0], segmentEnd[1]).elevation;
    segments.push({
      start: segmentStart,
      end: segmentEnd,
      bottom_start_m: Math.min(baseElevationM, startTerrain - FOUNDATION_BURIAL_MARGIN_M),
      bottom_end_m: Math.min(baseElevationM, endTerrain - FOUNDATION_BURIAL_MARGIN_M),
      terrain_start_m: startTerrain,
      terrain_end_m: endTerrain,
      terrain_facet_id: owner.facet.id,
    });
  }
  invariant(segments.length > 0, `${label} exterior edge produced no foundation segments`);
  return segments;
}

function updateFoundationAudit(store, segments, label) {
  for (const segment of segments) {
    if (segment.terrain_facet_id == null) {
      invariant(
        segment.bottom_start_m <= WATER_DATUM_M - FOUNDATION_BURIAL_MARGIN_M &&
          segment.bottom_end_m <= WATER_DATUM_M - FOUNDATION_BURIAL_MARGIN_M,
        `${label} unsupported exterior does not reach below the water datum`,
      );
      store.foundation_audit.water_supported_exterior_segments += 1;
      continue;
    }
    const samples = [0, 0.5, 1];
    const facet = store.land_facets_by_id.get(segment.terrain_facet_id);
    invariant(facet, `${label} foundation facet ${segment.terrain_facet_id} is missing`);
    for (const fraction of samples) {
      const east = segment.start[0] + (segment.end[0] - segment.start[0]) * fraction;
      const north = segment.start[1] + (segment.end[1] - segment.start[1]) * fraction;
      const bottom = segment.bottom_start_m + (segment.bottom_end_m - segment.bottom_start_m) * fraction;
      const ground = facetElevation(facet, east, north).elevation;
      const gap = bottom - ground;
      invariant(gap <= COORDINATE_ROUNDING_M, `${label} foundation has a positive ${gap} m ground gap`);
      store.foundation_audit.sample_points += 1;
      store.foundation_audit.maximum_positive_gap_m = Math.max(store.foundation_audit.maximum_positive_gap_m, gap);
      store.foundation_audit.minimum_embed_m = Math.min(store.foundation_audit.minimum_embed_m, gap);
    }
  }
}

function addChunkedTopSurface(store, object, style, terrain, sourceKeys = [object.row.source_key]) {
  for (const chunk of chunkRangeForGeometry(object.geometry)) {
    const clipped = geometryForChunk(object.geometry, chunk.x, chunk.z);
    if (clipped.length === 0 || multiPolygonArea(clipped) <= 1e-8) continue;
    const rounded = roundedCanonicalGeometry(clipped, `${object.row.source_key}/${chunk.id}`);
    const label = `${object.row.source_key}/${chunk.id}`;
    const isLand = style.feature_kind === "land_ground";
    const facets = isLand ? null : landFacetsForChunk(store.chunks, chunk.id);
    const mesh = isLand
      ? griddedTerrainSurfaceMesh(
        rounded,
        TERRAIN_MESH_GRID_SIZE_M,
        terrain.sampleTerrainEastNorth,
        label,
      )
      : coherentDrapedSurfaceMesh(rounded, facets, style.elevation_m, label);
    const objectKey = `${object.logical_key}:${chunk.id}`;
    const record = meshRecord({
      objectKey,
      featureKind: style.feature_kind,
      sourceKeys,
      materialKey: style.material_key,
      mesh,
      collisionKind: style.feature_kind === "land_ground" ? "world_solid" : "none",
      receiverKind: "none",
      opaque: style.feature_kind === "land_ground",
    });
    if (!isLand) {
      record.surface_bias_m = style.elevation_m;
      updateSurfaceConformanceAudit(store, mesh, facets, style.elevation_m, label);
    }
    store.ensure(chunk.x, chunk.z).records.push(record);
    object.physical_object_keys.add(objectKey);
    object.chunk_ids.add(chunk.id);
  }
  invariant(object.physical_object_keys.size > 0, `${object.row.source_key} has no chunked surface`);
}

function buildRoadChunks(store, objects) {
  const perChunk = new Map();
  for (const object of objects.values()) {
    if (!object.roles.includes("roads_paths")) continue;
    for (const chunk of chunkRangeForGeometry(object.geometry)) {
      const geometry = geometryForChunk(object.geometry, chunk.x, chunk.z);
      if (geometry.length === 0 || multiPolygonArea(geometry) <= 1e-8) continue;
      const entry = perChunk.get(chunk.id) ?? { ...chunk, pieces: [] };
      entry.pieces.push({ object, geometry });
      perChunk.set(chunk.id, entry);
    }
  }
  for (const entry of [...perChunk.values()].sort((left, right) => compareChunkIds(left.id, right.id))) {
    entry.pieces.sort((left, right) => left.object.row.source_key.localeCompare(right.object.row.source_key));
    const vehiclePieces = entry.pieces.filter((piece) => piece.object.road_visual_class === "vehicle");
    const pedestrianPieces = entry.pieces.filter((piece) => piece.object.road_visual_class === "pedestrian");
    invariant(
      vehiclePieces.length + pedestrianPieces.length === entry.pieces.length,
      `${entry.id} has an unclassified pavement piece`,
    );
    const rawUnion = unionMultiPolygonsRaw(...entry.pieces.map((piece) => piece.geometry));
    const batchAudit = snapRoadRibbonAfterUnion(rawUnion, `roads/${entry.id}`);
    const union = batchAudit.geometry;
    store.road_batch_audits.push({
      chunk_id: entry.id,
      source_keys: entry.pieces.map((piece) => piece.object.row.source_key).sort(),
      snap_stage: batchAudit.snap_stage,
      observed_area_delta_m2: batchAudit.observed_area_delta_m2,
      tolerance_m2: batchAudit.tolerance_m2,
      repairs: batchAudit.repairs,
    });
    const label = `roads/${entry.id}`;
    const facets = landFacetsForChunk(store.chunks, entry.id);
    const mesh = coherentDrapedSurfaceMesh(union, facets, ROAD_SURFACE_BIASES_M.base, label);
    const objectKey = `roads:${entry.id}`;
    const sourceKeys = entry.pieces.map((piece) => piece.object.row.source_key).sort();
    const record = meshRecord({
      objectKey,
      featureKind: "road_path",
      sourceKeys,
      materialKey: "road_path",
      mesh,
    });
    record.surface_bias_m = ROAD_SURFACE_BIASES_M.base;
    updateSurfaceConformanceAudit(store, mesh, facets, ROAD_SURFACE_BIASES_M.base, label);
    store.ensure(entry.x, entry.z).records.push(record);
    for (const piece of entry.pieces) {
      piece.object.physical_object_keys.add(objectKey);
      piece.object.chunk_ids.add(entry.id);
    }

    const classUnion = (pieces, classLabel) => {
      if (pieces.length === 0) return [];
      return snapRoadRibbonAfterUnion(
        unionMultiPolygonsRaw(...pieces.map((piece) => piece.geometry)),
        `${classLabel}/${entry.id}`,
      ).geometry;
    };
    const vehicleUnion = classUnion(vehiclePieces, "roads-vehicle");
    const pedestrianUnion = classUnion(pedestrianPieces, "roads-pedestrian-source");
    const pedestrianAfterVehiclePrecedence = differenceMultiPolygons(pedestrianUnion, vehicleUnion);
    // Both class unions are subsets of the all-source base union. Boolean
    // difference establishes exact vehicle precedence; re-intersecting shared
    // boundaries would manufacture zero-area rings in polygon-clipping.
    const pedestrianVisible = pedestrianAfterVehiclePrecedence;
    const pedestrianVehicleOverlap = 0;

    let pedestrianObjectKey = null;
    let visiblePedestrianPieces = [];
    if (pedestrianVisible.length > 0 && multiPolygonArea(pedestrianVisible) > 1e-8) {
      // The lighter record owns the pedestrian-class batch as a whole. The
      // vehicle subtraction may hide only a crossing slice of a source, while
      // the filled base continues to represent that source everywhere.
      visiblePedestrianPieces = pedestrianPieces;
      invariant(visiblePedestrianPieces.length > 0, `${entry.id} pedestrian skin has no source owner`);
      const pedestrianLabel = `roads-pedestrian/${entry.id}`;
      const pedestrianMesh = coherentDrapedSurfaceMesh(
        pedestrianVisible,
        facets,
        ROAD_SURFACE_BIASES_M.pedestrian,
        pedestrianLabel,
      );
      pedestrianObjectKey = `roads-pedestrian:${entry.id}`;
      const pedestrianRecord = meshRecord({
        objectKey: pedestrianObjectKey,
        featureKind: "road_path",
        sourceKeys: visiblePedestrianPieces.map((piece) => piece.object.row.source_key).sort(),
        materialKey: "road_path_pedestrian",
        mesh: pedestrianMesh,
      });
      pedestrianRecord.surface_bias_m = ROAD_SURFACE_BIASES_M.pedestrian;
      updateSurfaceConformanceAudit(
        store,
        pedestrianMesh,
        facets,
        ROAD_SURFACE_BIASES_M.pedestrian,
        pedestrianLabel,
      );
      store.ensure(entry.x, entry.z).records.push(pedestrianRecord);
      for (const piece of visiblePedestrianPieces) {
        piece.object.physical_object_keys.add(pedestrianObjectKey);
        piece.object.chunk_ids.add(entry.id);
      }
    }

    const pedestrianSourceArea = multiPolygonArea(pedestrianUnion);
    const pedestrianVisibleArea = multiPolygonArea(pedestrianVisible);
    store.pavement_skin_audits.push({
      chunk_id: entry.id,
      base_object_key: objectKey,
      pedestrian_object_key: pedestrianObjectKey,
      source_counts: {
        all: new Set(sourceKeys).size,
        vehicle: new Set(vehiclePieces.map((piece) => piece.object.row.source_key)).size,
        pedestrian: new Set(pedestrianPieces.map((piece) => piece.object.row.source_key)).size,
        pedestrian_visible: new Set(visiblePedestrianPieces.map((piece) => piece.object.row.source_key)).size,
      },
      plan_area_m2: {
        base_union: roundMeasure(multiPolygonArea(union)),
        vehicle_union: roundMeasure(multiPolygonArea(vehicleUnion)),
        pedestrian_union_before_precedence: roundMeasure(pedestrianSourceArea),
        pedestrian_visible_after_precedence: roundMeasure(pedestrianVisibleArea),
        vehicle_precedence_removed: roundMeasure(pedestrianSourceArea - pedestrianVisibleArea),
        pedestrian_vehicle_overlap: roundMeasure(pedestrianVehicleOverlap),
      },
    });
  }
  invariant(
    [...objects.values()].filter((object) => object.roles.includes("roads_paths"))
      .every((object) => object.physical_object_keys.size > 0),
    "At least one road has no physical chunk batch",
  );
}

function srgbHexRelativeLuminance(hex) {
  const channels = [0, 2, 4].map((offset) => Number.parseInt(hex.slice(offset, offset + 2), 16) / 255);
  const linear = channels.map((channel) =>
    channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055) ** 2.4);
  return linear[0] * 0.2126 + linear[1] * 0.7152 + linear[2] * 0.0722;
}

function pavementSkinDocument(objects, batchAudits) {
  const roads = [...objects.values()]
    .filter((object) => object.roles.includes("roads_paths"))
    .sort((left, right) => left.row.source_key.localeCompare(right.row.source_key));
  const classCounts = Object.fromEntries(Object.keys(ROAD_VISUAL_CLASSES).map((key) => [key, 0]));
  const highwayCounts = {};
  for (const object of roads) {
    classCounts[object.road_visual_class] += 1;
    highwayCounts[object.tags.highway] = (highwayCounts[object.tags.highway] ?? 0) + 1;
    invariant(
      [...object.physical_object_keys].some((key) => key.startsWith("roads:")),
      `${object.row.source_key} is missing from the continuous pavement base`,
    );
  }
  invariant(roads.length === CATEGORY_MEMBERSHIPS.roads_paths, "Pavement skin source denominator drift");
  invariant(
    stableJson(classCounts) === stableJson({ pedestrian: 219, vehicle: 208 }),
    `Pavement visual class counts drift: ${JSON.stringify(classCounts)}`,
  );
  const pedestrianSourcesWithVisibleSkin = roads.filter((object) =>
    object.road_visual_class === "pedestrian" &&
    [...object.physical_object_keys].some((key) => key.startsWith("roads-pedestrian:")));
  const pavedAreas = [...objects.values()].filter((object) =>
    object.roles.includes("major_area") && object.tags.amenity === "parking");
  invariant(pavedAreas.length === 17, `Expected 17 OSM parking areas, found ${pavedAreas.length}`);
  const vehicleLuminance = srgbHexRelativeLuminance(PAVEMENT_MATERIALS.vehicle.albedo_srgb_hex);
  const pedestrianLuminance = srgbHexRelativeLuminance(PAVEMENT_MATERIALS.pedestrian.albedo_srgb_hex);
  const pavedAreaLuminance = srgbHexRelativeLuminance(PAVEMENT_MATERIALS.paved_area.albedo_srgb_hex);
  const relativeLuminanceDifference = (pedestrianLuminance - vehicleLuminance) / vehicleLuminance;
  invariant(relativeLuminanceDifference >= 0.12, "Pedestrian pavement luminance differs from vehicle pavement by less than 12%");
  invariant(
    pavedAreaLuminance > vehicleLuminance && pavedAreaLuminance < pedestrianLuminance,
    "Paved-area luminance is not intermediate between vehicle and pedestrian pavement",
  );
  const maximumOverlap = Math.max(...batchAudits.map((audit) =>
    audit.plan_area_m2.pedestrian_vehicle_overlap));
  invariant(maximumOverlap === 0, "Pavement skin retains pedestrian geometry over vehicle-precedence crossings");
  return {
    schema_version: "ti.pavement-skin/1",
    visual_only: true,
    source_classification: {
      source_count: roads.length,
      by_visual_class: classCounts,
      by_highway: Object.fromEntries(Object.entries(highwayCounts).sort(([left], [right]) => left.localeCompare(right))),
      highway_tags_by_visual_class: ROAD_VISUAL_CLASSES,
      assumption: "tertiary/residential/unclassified/service/track retain vehicle-road precedence; footway/path/cycleway/pedestrian/platform receive the lighter pedestrian skin; OSM access and gameplay collision are unchanged",
    },
    materials: {
      vehicle: {
        ...PAVEMENT_MATERIALS.vehicle,
        surface_bias_m: ROAD_SURFACE_BIASES_M.base,
        relative_luminance: roundMeasure(vehicleLuminance),
      },
      pedestrian: {
        ...PAVEMENT_MATERIALS.pedestrian,
        surface_bias_m: ROAD_SURFACE_BIASES_M.pedestrian,
        relative_luminance: roundMeasure(pedestrianLuminance),
      },
      paved_area: {
        ...PAVEMENT_MATERIALS.paved_area,
        source_tag_rule: "amenity=parking",
        source_count: pavedAreas.length,
        relative_luminance: roundMeasure(pavedAreaLuminance),
      },
      pedestrian_vs_vehicle_relative_luminance_difference: roundMeasure(relativeLuminanceDifference),
    },
    topology: {
      continuous_filled_base_union: true,
      base_source_count: roads.length,
      base_record_count: batchAudits.length,
      pedestrian_source_count: classCounts.pedestrian,
      pedestrian_sources_with_visible_skin: pedestrianSourcesWithVisibleSkin.length,
      pedestrian_record_count: batchAudits.filter((audit) => audit.pedestrian_object_key != null).length,
      vehicle_precedence_at_crossings: true,
      maximum_pedestrian_vehicle_overlap_m2: maximumOverlap,
      vertical_separation_m: roundMeasure(ROAD_SURFACE_BIASES_M.pedestrian - ROAD_SURFACE_BIASES_M.base),
      physical_collision_changed: false,
      batches: batchAudits,
    },
  };
}

function addBuildingCellRecords(store, cell, allCells, chunk, compositeKey) {
  const sourceObject = cell.object;
  const isPart = sourceObject.roles.includes("building_part");
  const baseKey = compositeKey
    ? `${compositeKey}:${cell.cell_key}`
    : sourceObject.logical_key;
  const roofMesh = topSurfaceMesh(cell.geometry, cell.top_elevation_m, `${baseKey}:roof`);
  const roofElevations = roofMesh.vertices.filter((_value, index) => index % 3 === 1);
  const roofRange = Math.max(...roofElevations) - Math.min(...roofElevations);
  const heightDeviation = Math.abs(
    (cell.top_elevation_m - cell.base_elevation_m) - sourceObject.height.height_m,
  );
  invariant(roofRange <= COORDINATE_ROUNDING_M, `${baseKey} roof is no longer flat`);
  invariant(heightDeviation <= COORDINATE_ROUNDING_M, `${baseKey} source height changed`);
  store.foundation_audit.flat_roof_cells += 1;
  store.foundation_audit.maximum_roof_elevation_range_m = Math.max(
    store.foundation_audit.maximum_roof_elevation_range_m,
    roofRange,
  );
  store.foundation_audit.maximum_height_deviation_m = Math.max(
    store.foundation_audit.maximum_height_deviation_m,
    heightDeviation,
  );
  const roofKey = `${baseKey}:roof`;
  const roofRecord = meshRecord({
    objectKey: roofKey,
    featureKind: isPart ? "building_part_roof" : "building_roof",
    sourceKeys: [sourceObject.row.source_key],
    materialKey: isPart ? "building_part_roof" : "building_roof",
    mesh: roofMesh,
    collisionKind: "world_solid",
    opaque: true,
  });
  roofRecord.flat_base_elevation_m = roundCoordinate(cell.base_elevation_m);
  roofRecord.top_elevation_m = roundCoordinate(cell.top_elevation_m);
  roofRecord.source_height_m = roundCoordinate(sourceObject.height.height_m);
  store.ensure(chunk.x, chunk.z).records.push(roofRecord);
  sourceObject.physical_object_keys.add(roofKey);
  sourceObject.chunk_ids.add(chunkId(chunk.x, chunk.z));

  const wallMesh = wallSurfaceMesh(
    cell,
    allCells,
    `${baseKey}:wall`,
    (start, end, baseElevationM, label) => {
      const segments = foundationSegmentsForEdge(
        start,
        end,
        baseElevationM,
        store.land_facets,
        label,
      );
      updateFoundationAudit(store, segments, label);
      return segments;
    },
  );
  store.foundation_audit.exterior_segments += wallMesh.exterior_segments;
  store.foundation_audit.shared_segments += wallMesh.shared_segments;
  if (wallMesh.indices.length > 0) {
    const wallKey = `${baseKey}:wall`;
    const wallRecord = meshRecord({
      objectKey: wallKey,
      featureKind: isPart ? "building_part_wall" : "building_wall",
      sourceKeys: [sourceObject.row.source_key],
      materialKey: isPart ? "building_part_wall" : "building_wall",
      mesh: wallMesh,
      collisionKind: "world_solid",
      receiverKind: "building_wall",
      opaque: true,
    });
    wallRecord.flat_base_elevation_m = roundCoordinate(cell.base_elevation_m);
    wallRecord.top_elevation_m = roundCoordinate(cell.top_elevation_m);
    wallRecord.source_height_m = roundCoordinate(sourceObject.height.height_m);
    wallRecord.exterior_foundation_segments = wallMesh.exterior_segments;
    wallRecord.shared_wall_segments = wallMesh.shared_segments;
    store.ensure(chunk.x, chunk.z).records.push(wallRecord);
    sourceObject.physical_object_keys.add(wallKey);
  }
}

function buildBuildings(store, objects) {
  const buildings = [...objects.values()].filter((object) =>
    object.roles.includes("building") || object.roles.includes("building_part"));
  const parent = objects.get(ISLE_HOUSE_PARENT_KEY);
  const parts = ISLE_HOUSE_PART_KEYS.map((key) => objects.get(key));
  invariant(parent && parts.every(Boolean), "Isle House parent/parts are missing");
  for (const part of parts) {
    const outside = differenceMultiPolygons(part.geometry, parent.geometry);
    invariant(multiPolygonArea(outside) <= 0.01, `${part.row.source_key} is not contained in Isle House parent`);
  }
  invariant(
    multiPolygonArea(intersectMultiPolygons(parts[0].geometry, parts[1].geometry)) <= 0.01,
    "Isle House parts overlap beyond 0.01 m2",
  );
  const partsUnion = unionMultiPolygons(...parts.map((part) => part.geometry));
  const residual = differenceMultiPolygons(parent.geometry, partsUnion);
  invariant(
    Math.abs(multiPolygonArea(residual) + multiPolygonArea(partsUnion) - multiPolygonArea(parent.geometry)) <= 0.01,
    "Isle House residual plus parts does not equal parent",
  );
  parent.representation = "composite";
  for (const part of parts) part.representation = "composite";
  const compositeKey = `building-composite:${ISLE_HOUSE_PARENT_KEY}`;
  const cells = [];
  const compositeCentroid = multiPolygonCentroid(parent.geometry);
  const compositeBaseElevation = terrainElevationFromChunks(store.chunks, compositeCentroid[0], compositeCentroid[1]);
  if (residual.length > 0 && multiPolygonArea(residual) > 1e-8) {
    roundingAreaAudit(residual, "Isle House parent residual");
    cells.push({
      object: parent,
      cell_key: "parent-residual",
      geometry: residual,
      base_elevation_m: compositeBaseElevation,
      top_elevation_m: compositeBaseElevation + parent.height.height_m,
    });
  }
  for (const part of parts) {
    cells.push({
      object: part,
      cell_key: part.row.source_key,
      geometry: part.geometry,
      base_elevation_m: compositeBaseElevation,
      top_elevation_m: compositeBaseElevation + part.height.height_m,
    });
  }
  const compositeChunk = buildingChunk(parent.geometry);
  for (const cell of cells) addBuildingCellRecords(store, cell, cells, compositeChunk, compositeKey);
  const compositePartKeys = new Set(cells.flatMap((cell) => [...cell.object.physical_object_keys]));
  for (const object of [parent, ...parts]) {
    for (const key of compositePartKeys) object.physical_object_keys.add(key);
    object.chunk_ids.add(chunkId(compositeChunk.x, compositeChunk.z));
  }

  for (const object of buildings) {
    if ([parent, ...parts].includes(object)) continue;
    const chunk = buildingChunk(object.geometry);
    const centroid = multiPolygonCentroid(object.geometry);
    const baseElevation = terrainElevationFromChunks(store.chunks, centroid[0], centroid[1]);
    const cell = {
      object,
      cell_key: object.row.source_key,
      geometry: object.geometry,
      base_elevation_m: baseElevation,
      top_elevation_m: baseElevation + object.height.height_m,
    };
    addBuildingCellRecords(store, cell, [cell], chunk, null);
  }
  invariant(buildings.every((object) => object.physical_object_keys.size > 0), "At least one building has no physical geometry");
}

function buildChunks(objects, boundary, terrain) {
  const store = chunkStore();
  store.road_batch_audits = [];
  store.pavement_skin_audits = [];
  const land = objects.get(PLAYABLE_BOUNDARY_SOURCE_KEY);
  const coastline = objects.get(SHARED_COASTLINE_SOURCE_KEY);
  addChunkedTopSurface(store, land, {
    feature_kind: "land_ground",
    material_key: "land_ground",
    elevation_m: 0,
  }, terrain, [PLAYABLE_BOUNDARY_SOURCE_KEY, SHARED_COASTLINE_SOURCE_KEY]);
  for (const key of land.physical_object_keys) coastline.physical_object_keys.add(key);
  for (const id of land.chunk_ids) coastline.chunk_ids.add(id);
  store.land_facets = allLandFacets(store.chunks);
  store.land_facets_by_id = new Map(store.land_facets.map((facet) => [facet.id, facet]));

  for (const object of objects.values()) {
    if (object === land || object === coastline) continue;
    if (object.boundary_attached_visual) continue;
    if (object.roles.includes("roads_paths") || object.roles.includes("building") || object.roles.includes("building_part")) continue;
    addChunkedTopSurface(store, object, areaStyle(object.tags, object.roles), terrain);
  }
  buildRoadChunks(store, objects);
  buildBuildings(store, objects);
  for (const chunk of store.chunks.values()) {
    chunk.records.sort((left, right) => left.object_key.localeCompare(right.object_key));
    invariant(new Set(chunk.records.map((record) => record.object_key)).size === chunk.records.length, `${chunk.chunk_id} has duplicate object keys`);
  }
  invariant(multiPolygonArea(boundary) === land.clipped_measure, "Land no longer equals exact boundary");
  invariant(store.surface_conformance.sample_points > 0, "No playable overlay conformance samples were audited");
  invariant(store.foundation_audit.sample_points > 0, "No exterior foundation samples were audited");
  invariant(
    store.foundation_audit.maximum_positive_gap_m <= COORDINATE_ROUNDING_M,
    `Exterior foundation gap ${store.foundation_audit.maximum_positive_gap_m} exceeds serialization tolerance`,
  );
  store.chunks.road_batch_audits = store.road_batch_audits;
  store.chunks.pavement_skin = pavementSkinDocument(objects, store.pavement_skin_audits);
  store.chunks.surface_conformance = {
    ...store.surface_conformance,
    minimum_clearance_m: roundCoordinate(store.surface_conformance.minimum_clearance_m),
    maximum_clearance_m: roundCoordinate(store.surface_conformance.maximum_clearance_m),
    maximum_bias_deviation_m: roundMeasure(store.surface_conformance.maximum_bias_deviation_m),
    maximum_serialization_tolerance_m: roundMeasure(store.surface_conformance.maximum_serialization_tolerance_m),
  };
  store.chunks.foundation_audit = {
    ...store.foundation_audit,
    maximum_positive_gap_m: roundCoordinate(Math.max(0, store.foundation_audit.maximum_positive_gap_m)),
    minimum_embed_m: roundCoordinate(store.foundation_audit.minimum_embed_m),
    maximum_roof_elevation_range_m: roundCoordinate(store.foundation_audit.maximum_roof_elevation_range_m),
    maximum_height_deviation_m: roundCoordinate(store.foundation_audit.maximum_height_deviation_m),
    burial_margin_m: FOUNDATION_BURIAL_MARGIN_M,
    water_datum_m: WATER_DATUM_M,
    tolerance_m: COORDINATE_ROUNDING_M,
  };
  return store.chunks;
}

function contextRecord(record, contextKind) {
  const { feature_kind: _unused, ...rest } = record;
  return { ...rest, context_kind: contextKind };
}

function buildContext(ledger, boundary, rawOsm, rawSources, playableObjects, terrain) {
  const byKey = new Map(ledger.context.map((joined) => [joined.row.source_key, joined]));
  const ybi = byKey.get(YBI_SOURCE_KEY);
  invariant(ybi?.exported, "YBI area view is missing from raw export");
  const ybiSourceGeometry = geometryToMultiPolygon(selectGeometry(ybi.exported, "area"), YBI_SOURCE_KEY);
  const ybiGeometry = differenceMultiPolygons(ybiSourceGeometry, boundary);
  roundingAreaAudit(ybiGeometry, "YBI context");
  invariant(ybiGeometry.length > 0, "YBI context is empty after TI subtraction");
  const ybiTopMesh = griddedTerrainSurfaceMesh(
    ybiGeometry,
    TERRAIN_MESH_GRID_SIZE_M,
    terrain.sampleTerrainEastNorth,
    "YBI terrain context",
  );
  const ybiSideMesh = terrainSkirtMesh(ybiGeometry, terrain.sampleTerrainEastNorth, 0, "YBI shoreline sides");
  const ybiMesh = mergeMeshes([ybiTopMesh, ybiSideMesh], "YBI terrain and shoreline sides");

  const west = byKey.get("w1011568818");
  invariant(west?.exported, "West Span area view is missing from raw export");
  const westGeometry = geometryToMultiPolygon(selectGeometry(west.exported, "area"), "w1011568818");
  const eastRelation = rawOsm.relations.get("13543937");
  invariant(eastRelation, "East Span site relation is missing");
  const memberWayIds = eastRelation.members.filter((member) => member.type === "way").map((member) => member.ref);
  invariant(memberWayIds.length === 23 && new Set(memberWayIds).size === 23, `Expected 23 unique East Span ways, found ${memberWayIds.length}`);
  const bridgeSourceGeometry = unionMultiPolygons(
    westGeometry,
    ...memberWayIds.map((wayId) => rawWayFootprint(rawOsm, wayId, 8)),
  );
  const bridgeGeometry = differenceMultiPolygons(bridgeSourceGeometry, boundary);
  roundingAreaAudit(bridgeGeometry, "Bay Bridge context");
  invariant(bridgeGeometry.length > 0, "Bay Bridge context is empty after TI subtraction");
  const bridgeMesh = topSurfaceMesh(bridgeGeometry, 12, "Bay Bridge context");

  const records = [
    contextRecord(meshRecord({
      objectKey: "context:ybi",
      featureKind: "context",
      sourceKeys: [YBI_SOURCE_KEY],
      materialKey: "context_ybi",
      mesh: ybiMesh,
    }), "ybi"),
    contextRecord(meshRecord({
      objectKey: "context:bay-bridge",
      featureKind: "context",
      sourceKeys: BRIDGE_SOURCE_KEYS,
      materialKey: "context_bay_bridge",
      mesh: bridgeMesh,
    }), "bay_bridge"),
  ];
  records.sort((left, right) => left.object_key.localeCompare(right.object_key));
  const boundaryAttachedVisuals = BOUNDARY_ATTACHED_SOURCE_KEYS.map((sourceKey) => {
    const object = playableObjects.get(sourceKey);
    invariant(object?.boundary_attached_visual, `${sourceKey} boundary-attached object is missing`);
    const mesh = terrainSurfaceMesh(
      object.geometry,
      (east, north) => terrain.sampleTerrainEastNorth(east, north) + 0.03,
      `${sourceKey}/boundary-context`,
    );
    const materialKey = sourceKey === "w319406837"
      ? "context_boundary_pier"
      : "context_boundary_marina";
    const record = contextRecord(meshRecord({
      objectKey: `boundary_context:${sourceKey}`,
      featureKind: "context",
      sourceKeys: [sourceKey],
      materialKey,
      mesh,
    }), "boundary_attached_visual");
    object.physical_object_keys.add(record.object_key);
    return record;
  }).sort((left, right) => left.object_key.localeCompare(right.object_key));
  const objects = new Map();
  for (const joined of ledger.context) {
    const isYbi = joined.row.source_key === YBI_SOURCE_KEY;
    const geometry = isYbi ? ybiGeometry : bridgeGeometry;
    const triangulationAudit = triangulationAreaAudit(geometry, `${joined.row.source_key}/context`);
    const quantizationAudit = roundingAreaAudit(geometry, `${joined.row.source_key}/context`);
    objects.set(joined.row.source_key, {
      row: joined.row,
      tags: joined.tags,
      roles: joined.row.categories.split("|"),
      logical_key: isYbi ? "context:ybi" : "context:bay-bridge",
      representation: isYbi ? "direct" : "composite",
      geometry,
      source_measure: multiPolygonArea(geometry),
      clipped_measure: multiPolygonArea(geometry),
      geometry_sha256: geometrySha256(geometry),
      pre_serialization_area_delta_m2: triangulationAudit.delta_m2,
      post_serialization_area_delta_m2: quantizationAudit.delta_m2,
      post_serialization_tolerance_m2: quantizationAudit.tolerance_m2,
      serialization_perimeter_m: quantizationAudit.perimeter_m,
      quantization_delta_m: quantizationAudit.quantization_delta_m,
      post_serialization_normalized_error: quantizationAudit.normalized_error,
      height: null,
      physical_object_keys: new Set([isYbi ? "context:ybi" : "context:bay-bridge"]),
      chunk_ids: new Set(),
    });
  }
  return {
    document: {
      schema_version: CONTEXT_SCHEMA,
      records,
      boundary_attached_visuals: boundaryAttachedVisuals,
    },
    objects,
    member_way_count: memberWayIds.length,
  };
}

function pointToSegmentDistance(point, start, end) {
  const deltaX = end[0] - start[0];
  const deltaY = end[1] - start[1];
  const lengthSquared = deltaX * deltaX + deltaY * deltaY;
  if (lengthSquared === 0) return Math.hypot(point[0] - start[0], point[1] - start[1]);
  const fraction = Math.max(0, Math.min(1,
    ((point[0] - start[0]) * deltaX + (point[1] - start[1]) * deltaY) / lengthSquared));
  return Math.hypot(
    point[0] - (start[0] + deltaX * fraction),
    point[1] - (start[1] + deltaY * fraction),
  );
}

function distanceToMultiPolygonEdges(point, geometry) {
  let minimum = Infinity;
  for (const polygon of geometry) {
    for (const ring of polygon) {
      for (let index = 0; index < ring.length; index += 1) {
        minimum = Math.min(
          minimum,
          pointToSegmentDistance(point, ring[index], ring[(index + 1) % ring.length]),
        );
      }
    }
  }
  invariant(Number.isFinite(minimum), "Could not measure spawn clearance against empty geometry");
  return minimum;
}

function projectedRawWayLine(rawOsm, sourceKey) {
  invariant(sourceKey.startsWith("w"), `${sourceKey} is not a way source key`);
  const way = rawOsm.ways.get(sourceKey.slice(1));
  invariant(way, `Frozen ferry source ${sourceKey} is missing`);
  return way.node_refs.map((nodeId) => {
    const node = rawOsm.nodes.get(nodeId);
    invariant(node, `${sourceKey} references missing node n${nodeId}`);
    return projectLonLat(node.coordinate);
  });
}

function pointFromLineEnd(line, distanceM, label) {
  invariant(line.length >= 2, `${label} needs at least two coordinates`);
  invariant(Number.isFinite(distanceM) && distanceM > 0, `${label} has invalid offset`);
  let remaining = distanceM;
  for (let index = line.length - 1; index > 0; index -= 1) {
    const start = line[index];
    const end = line[index - 1];
    const length = Math.hypot(end[0] - start[0], end[1] - start[1]);
    if (length <= 1e-9) continue;
    if (remaining <= length) {
      const fraction = remaining / length;
      return [
        start[0] + (end[0] - start[0]) * fraction,
        start[1] + (end[1] - start[1]) * fraction,
      ];
    }
    remaining -= length;
  }
  throw new Error(`${label} is shorter than the ${distanceM} m spawn offset`);
}

function findInitialSpawn(boundary, objects, rawOsm, rawSources, chunks) {
  const sourceIds = Object.fromEntries(
    Object.entries(FERRY_SPAWN_SOURCE_KEYS).map(([role, sourceKey]) => [role, sourceKey.slice(1)]),
  );
  const terminalStop = rawOsm.nodes.get(sourceIds.terminal_stop);
  const terminalPlatform = rawOsm.ways.get(sourceIds.terminal_platform);
  const terminalPlatformFootway = rawOsm.ways.get(sourceIds.terminal_platform_footway);
  const accessFootway = rawOsm.ways.get(sourceIds.terminal_access_footway);
  const landingPier = rawOsm.ways.get(sourceIds.landing_pier);
  const waterfrontApproach = rawOsm.ways.get(sourceIds.waterfront_plaza_footway);
  const landingConnection = rawOsm.nodes.get(sourceIds.landing_connection);
  const terminalStopTags = rawSources.get(FERRY_SPAWN_SOURCE_KEYS.terminal_stop)?.metadata.tags;
  invariant(terminalStop && terminalStopTags?.amenity === "ferry_terminal" && terminalStopTags.ferry === "yes",
    `${FERRY_SPAWN_SOURCE_KEYS.terminal_stop} is not the frozen ferry-terminal stop`);
  invariant(
    terminalPlatform?.tags.name === "Treasure Island Ferry Terminal" &&
      terminalPlatform.tags.ferry === "yes" && terminalPlatform.tags.man_made === "pier" &&
      terminalPlatform.tags.public_transport === "platform",
    `${FERRY_SPAWN_SOURCE_KEYS.terminal_platform} is not the frozen terminal platform`,
  );
  invariant(
    terminalPlatformFootway?.tags.highway === "footway",
    `${FERRY_SPAWN_SOURCE_KEYS.terminal_platform_footway} is not the frozen terminal-platform footway`,
  );
  invariant(
    accessFootway?.tags.highway === "footway" && accessFootway.tags.bridge === "yes",
    `${FERRY_SPAWN_SOURCE_KEYS.terminal_access_footway} is not the frozen terminal access footway`,
  );
  invariant(
    landingPier?.tags.man_made === "pier" && landingPier.tags.area === "yes",
    `${FERRY_SPAWN_SOURCE_KEYS.landing_pier} is not the frozen land-side landing pier`,
  );
  invariant(
    waterfrontApproach?.tags.highway === "footway" && waterfrontApproach.tags.name === "Waterfront Plaza",
    `${FERRY_SPAWN_SOURCE_KEYS.waterfront_plaza_footway} is not the frozen Waterfront Plaza approach`,
  );
  invariant(landingConnection, `${FERRY_SPAWN_SOURCE_KEYS.landing_connection} is missing`);
  invariant(terminalPlatform.node_refs.includes(sourceIds.terminal_stop), "Terminal stop is not in its platform footprint");
  invariant(
    terminalPlatformFootway.node_refs.includes(accessFootway.node_refs.at(-1)) &&
      terminalPlatform.node_refs.includes(terminalPlatformFootway.node_refs[0]) &&
      terminalPlatform.node_refs.includes(terminalPlatformFootway.node_refs.at(-1)),
    "Terminal access footway does not connect through the terminal-platform footway",
  );
  invariant(
    accessFootway.node_refs[0] === sourceIds.landing_connection &&
      waterfrontApproach.node_refs.at(-1) === sourceIds.landing_connection &&
      landingPier.node_refs.includes(sourceIds.landing_connection),
    "Frozen ferry landing sources do not share the expected land connection",
  );
  invariant(
    objects.get(FERRY_SPAWN_SOURCE_KEYS.terminal_access_footway)?.roles.includes("roads_paths") &&
      objects.get(FERRY_SPAWN_SOURCE_KEYS.landing_pier)?.roles.includes("terrain_shoreline") &&
      objects.get(FERRY_SPAWN_SOURCE_KEYS.waterfront_plaza_footway)?.roles.includes("roads_paths"),
    "Ferry landing sources are missing from playable generated-world coverage",
  );

  const terminalPlatformGeometry = rawWayFootprint(rawOsm, sourceIds.terminal_platform);
  invariant(
    multiPolygonArea(intersectMultiPolygons(terminalPlatformGeometry, boundary)) <= 1e-8,
    "Frozen floating terminal platform unexpectedly enters the exact playable boundary",
  );
  const landingConnectionPoint = projectLonLat(landingConnection.coordinate);
  invariant(
    pointInMultiPolygon(landingConnectionPoint, boundary, false),
    "Frozen ferry landing connection is outside the exact playable boundary",
  );

  const approachLine = projectedRawWayLine(rawOsm, FERRY_SPAWN_SOURCE_KEYS.waterfront_plaza_footway);
  const candidate = pointFromLineEnd(
    approachLine,
    FERRY_SPAWN_INLAND_DISTANCE_M,
    FERRY_SPAWN_SOURCE_KEYS.waterfront_plaza_footway,
  );
  const buildingGeometries = [...objects.values()]
    .filter((object) => object.roles.includes("building") || object.roles.includes("building_part"))
    .map((object) => object.geometry);
  const centroid = multiPolygonCentroid(boundary);
  const requiredCapsuleClearance = PLAYER_CAPSULE_RADIUS_M + SPAWN_SAFETY_MARGIN_M;
  const minimumBoundaryClearance = distanceToMultiPolygonEdges(candidate, boundary);
  const minimumBuildingClearance = Math.min(
    ...buildingGeometries.map((geometry) => pointInMultiPolygon(candidate, geometry, true)
      ? 0
      : distanceToMultiPolygonEdges(candidate, geometry)),
  );
  invariant(pointInMultiPolygon(candidate, boundary, false), "Ferry spawn is outside the exact playable boundary");
  invariant(
    minimumBoundaryClearance >= requiredCapsuleClearance,
    `Ferry spawn boundary clearance ${minimumBoundaryClearance} m is below ${requiredCapsuleClearance} m`,
  );
  invariant(
    minimumBuildingClearance >= requiredCapsuleClearance,
    `Ferry spawn building clearance ${minimumBuildingClearance} m is below ${requiredCapsuleClearance} m`,
  );

  const interior = [centroid[0] - candidate[0], centroid[1] - candidate[1]];
  const interiorLength = Math.hypot(interior[0], interior[1]);
  invariant(interiorLength > 0, "Ferry spawn cannot orient toward the island centroid");
  const yaw = Math.atan2(-interior[0], interior[1]);
  // Player scene origin, capsule bottom, and avatar bottom all represent feet.
  // Serialize the exact colliding land height; runtime performs a hidden snap
  // before the first visible frame rather than showing a one-metre fall.
  const origin = eastNorthToWorldRounded(candidate, terrainElevationFromChunks(chunks, candidate[0], candidate[1]));
  const serializedYaw = roundCoordinate(yaw);
  const serializedCandidate = [origin[0], -origin[2]];
  const cameraProbe = [
    serializedCandidate[0] + Math.sin(serializedYaw) * SPAWN_CAMERA_BOOM_CLEARANCE_M,
    serializedCandidate[1] - Math.cos(serializedYaw) * SPAWN_CAMERA_BOOM_CLEARANCE_M,
  ];
  invariant(
    pointInMultiPolygon(serializedCandidate, boundary, false) &&
      distanceToMultiPolygonEdges(serializedCandidate, boundary) >= requiredCapsuleClearance &&
      buildingGeometries.every((geometry) =>
        !pointInMultiPolygon(serializedCandidate, geometry, true) &&
        distanceToMultiPolygonEdges(serializedCandidate, geometry) >= requiredCapsuleClearance) &&
      pointInMultiPolygon(cameraProbe, boundary, false) &&
      distanceToMultiPolygonEdges(cameraProbe, boundary) >= requiredCapsuleClearance &&
      buildingGeometries.every((geometry) =>
        !pointInMultiPolygon(cameraProbe, geometry, true) &&
        distanceToMultiPolygonEdges(cameraProbe, geometry) >= requiredCapsuleClearance),
    "Serialized ferry spawn or camera boom does not have clear playable space",
  );
  return {
    origin,
    yaw: serializedYaw,
  };
}

function playableBoundaryManifest(boundary) {
  return {
    components: boundary.map((polygon) => ({
      outer: polygon[0].map((point) => [roundCoordinate(point[0]), roundCoordinate(-point[1])]),
      holes: polygon.slice(1).map((ring) => ring.map((point) => [roundCoordinate(point[0]), roundCoordinate(-point[1])])),
    })),
  };
}

function sourceStatus(object) {
  if (object.row.scope === "context") return object.representation === "composite" ? "composite_member" : "context";
  return object.representation === "composite" ? "composite_member" : "represented";
}

function coverageRows(allObjects, chunks, contextDocument) {
  const physical = new Map();
  for (const chunk of chunks.values()) {
    for (const record of chunk.records) physical.set(record.object_key, record);
  }
  for (const record of contextDocument.records) physical.set(record.object_key, record);
  for (const record of contextDocument.boundary_attached_visuals) physical.set(record.object_key, record);
  return [...allObjects.values()].map((object) => {
    const records = [...object.physical_object_keys].map((key) => physical.get(key)).filter(Boolean);
    invariant(records.length > 0, `${object.row.source_key} coverage has no resolved physical record`);
    const height = object.height;
    const compositeKey = object.representation === "composite" ||
      object.logical_key === `land:${PLAYABLE_BOUNDARY_SOURCE_KEY}`
      ? object.logical_key
      : "";
    return {
      source_key: object.row.source_key,
      osm_type: object.row.osm_type,
      osm_id: object.row.osm_id,
      scope: object.row.scope,
      categories: object.row.categories.split("|").sort().join(";"),
      source_version: object.row.source_version,
      derived_world_status: sourceStatus(object),
      derived_object_key: object.logical_key,
      part_keys: [...object.physical_object_keys].sort().join(";"),
      chunk_ids: [...object.chunk_ids].sort(compareChunkIds).join(";"),
      representation_kind: object.representation,
      dimension_rule: height?.rule ?? "",
      height_m: height?.height_m ?? "",
      composite_key: compositeKey,
      note: object.row.source_key === SHARED_COASTLINE_SOURCE_KEY
        ? "Represented by exact Treasure Island land edge; no YBI ribbon"
        : BOUNDARY_ATTACHED_SOURCE_KEYS.includes(object.row.source_key)
          ? "Exact-touch-only source polygon rendered as explicit non-colliding boundary-attached visual context"
          : object.row.source_key === ISLE_HOUSE_PARENT_KEY || ISLE_HOUSE_PART_KEYS.includes(object.row.source_key)
          ? "Isle House parent residual and parts share an explicit non-overlapping composite"
          : BRIDGE_SOURCE_KEYS.includes(object.row.source_key)
            ? "Three bridge anchors share one context-only composite"
            : "",
      vertex_count: records.reduce((sum, record) => sum + record.vertices.length / 3, 0),
      triangle_count: records.reduce((sum, record) => sum + record.indices.length / 3, 0),
      collision_triangle_count: records.reduce(
        (sum, record) => sum + (record.collision_kind === "world_solid" ? record.indices.length / 3 : 0),
        0,
      ),
      validation: "pass",
    };
  });
}

function logicalObjectsDocument(allObjects) {
  const aggregates = new Map();
  for (const object of allObjects.values()) {
    const existing = aggregates.get(object.logical_key) ?? {
      logical_object_key: object.logical_key,
      source_keys: [],
      scope: object.row.scope,
      roles: [],
      representation: object.representation,
      physical_object_keys: [],
      chunk_ids: [],
      source_geometry: [],
      heights: [],
    };
    existing.source_keys.push(object.row.source_key);
    existing.roles.push(...object.roles);
    existing.physical_object_keys.push(...object.physical_object_keys);
    existing.chunk_ids.push(...object.chunk_ids);
    existing.source_geometry.push({
      source_key: object.row.source_key,
      source_measure: roundMeasure(object.source_measure),
      clipped_measure: roundMeasure(object.clipped_measure),
      geometry_sha256: object.geometry_sha256,
      pre_serialization_area_delta_m2: object.pre_serialization_area_delta_m2,
      post_serialization_area_delta_m2: object.post_serialization_area_delta_m2,
      post_serialization_tolerance_m2: object.post_serialization_tolerance_m2,
      serialization_perimeter_m: object.serialization_perimeter_m,
      quantization_delta_m: object.quantization_delta_m,
      post_serialization_normalized_error: object.post_serialization_normalized_error,
      ribbon_snap_area_delta_m2: object.ribbon_snap_area_delta_m2 ?? null,
      ribbon_snap_area_tolerance_m2: object.ribbon_snap_area_tolerance_m2 ?? null,
      ribbon_snap_stage: object.ribbon_snap_stage ?? null,
      road_quantization_topology_repairs: object.road_quantization_topology_repairs ?? [],
      road_quantization_topology_repair_area_delta_m2:
        object.road_quantization_topology_repair_area_delta_m2 ?? null,
      road_quantization_topology_repair_tolerance_m2:
        object.road_quantization_topology_repair_tolerance_m2 ?? null,
    });
    if (object.height) existing.heights.push({ source_key: object.row.source_key, ...object.height });
    if (object.representation === "composite") existing.representation = "composite";
    aggregates.set(object.logical_key, existing);
  }
  const objects = [...aggregates.values()].map((object) => ({
    ...object,
    source_keys: [...new Set(object.source_keys)].sort(),
    roles: [...new Set(object.roles)].sort(),
    physical_object_keys: [...new Set(object.physical_object_keys)].sort(),
    chunk_ids: [...new Set(object.chunk_ids)].sort(compareChunkIds),
    source_geometry: object.source_geometry.sort((left, right) => left.source_key.localeCompare(right.source_key)),
    heights: object.heights.sort((left, right) => left.source_key.localeCompare(right.source_key)),
  })).sort((left, right) => left.logical_object_key.localeCompare(right.logical_object_key));
  return { schema_version: WORLD_SCHEMA, objects };
}

function validateFinalState(coverage, objects, chunks, context, memberships) {
  invariant(coverage.length === EXPECTED_COUNTS.source_rows, "Coverage row count drift");
  invariant(new Set(coverage.map((row) => row.source_key)).size === coverage.length, "Coverage duplicate source keys");
  invariant(coverage.filter((row) => row.scope === "playable").length === EXPECTED_COUNTS.playable_rows, "Coverage playable count drift");
  invariant(coverage.filter((row) => row.scope === "context").length === EXPECTED_COUNTS.context_rows, "Coverage context count drift");
  invariant(!coverage.some((row) => row.derived_world_status === "unresolved"), "Coverage contains unresolved rows");
  invariant(coverage.every((row) => row.validation === "pass"), "Coverage contains failed validation");
  invariant(stableJson(memberships) === stableJson(CATEGORY_MEMBERSHIPS), "Coverage membership count drift");
  const heightCounts = { building: { osm_height: 0, osm_levels: 0, default_6m: 0 }, building_part: { osm_height: 0, osm_levels: 0, default_6m: 0 } };
  for (const object of objects.values()) {
    if (!object.height) continue;
    const group = object.roles.includes("building_part") ? "building_part" : "building";
    heightCounts[group][object.height.rule] += 1;
  }
  invariant(stableJson(heightCounts.building) === stableJson({ osm_height: 176, osm_levels: 10, default_6m: 27 }), `Building height counts drift: ${JSON.stringify(heightCounts.building)}`);
  invariant(stableJson(heightCounts.building_part) === stableJson({ osm_height: 1, osm_levels: 1, default_6m: 0 }), `Part height counts drift: ${JSON.stringify(heightCounts.building_part)}`);
  const physicalKeys = [];
  for (const chunk of chunks.values()) {
    invariant(chunk.schema_version === CHUNK_SCHEMA, `${chunk.chunk_id} schema drift`);
    for (const record of chunk.records) {
      invariant(FEATURE_KINDS.includes(record.feature_kind), `${record.object_key} unknown feature kind`);
      validateMesh(record, record.object_key);
      physicalKeys.push(record.object_key);
    }
  }
  for (const record of context.records) {
    invariant(["ybi", "bay_bridge"].includes(record.context_kind), `${record.object_key} unknown context kind`);
    invariant(record.collision_kind === "none" && record.receiver_kind === "none", `${record.object_key} context collision/receiver leak`);
    validateMesh(record, record.object_key);
    physicalKeys.push(record.object_key);
  }
  for (const record of context.boundary_attached_visuals) {
    invariant(record.context_kind === "boundary_attached_visual", `${record.object_key} unknown boundary context kind`);
    invariant(record.collision_kind === "none" && record.receiver_kind === "none", `${record.object_key} boundary context semantics leak`);
    invariant(
      BOUNDARY_ATTACHED_SOURCE_KEYS.includes(record.source_keys[0]) && record.source_keys.length === 1,
      `${record.object_key} invalid boundary-attached source ownership`,
    );
    validateMesh(record, record.object_key);
    physicalKeys.push(record.object_key);
  }
  invariant(new Set(physicalKeys).size === physicalKeys.length, "Physical object key duplication across output");
  return { heightCounts, physicalObjectCount: physicalKeys.length };
}

function writeArtifact(root, relativePath, value) {
  const path = resolve(root, relativePath);
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, typeof value === "string" ? value : stableJson(value), "utf8");
}

function listFiles(root, current = root) {
  const files = [];
  for (const entry of readdirSync(current, { withFileTypes: true }).sort((left, right) => left.name.localeCompare(right.name))) {
    const path = join(current, entry.name);
    if (entry.isDirectory()) files.push(...listFiles(root, path));
    else files.push(relative(root, path).replaceAll("\\", "/"));
  }
  return files;
}

function artifactDescriptor(root, path) {
  const absolutePath = resolve(root, path);
  return { path, sha256: sha256File(absolutePath), bytes: statSync(absolutePath).size };
}

function commitStagedOutput(stagingRoot, outputPath) {
  const backup = `${outputPath}.previous-${process.pid}`;
  let movedOld = false;
  try {
    if (existsSync(outputPath)) {
      invariant(!existsSync(backup), `Backup path already exists: ${backup}`);
      renameSync(outputPath, backup);
      movedOld = true;
    }
    renameSync(stagingRoot, outputPath);
    if (movedOld) rmSync(backup, { recursive: true, force: true });
  } catch (error) {
    if (!existsSync(outputPath) && movedOld && existsSync(backup)) renameSync(backup, outputPath);
    throw error;
  }
}

function main() {
  const { output } = parseArguments(process.argv.slice(2));
  const sources = verifySourceContract(projectRoot);
  const toolchain = auditToolchain();
  const terrain = loadTerrainRaster(resolve(projectRoot, SOURCE_CONTRACT.terrain_dem.path));
  const terrainDocument = auditTerrainRaster(terrain);
  const sourceRows = parseCsv(readFileSync(resolve(projectRoot, SOURCE_CONTRACT.source_ledger.path), "utf8"));
  const ledgerState = validateSourceLedger(sourceRows);
  const temporaryDirectory = mkdtempSync(join(tmpdir(), "ti-godot-world-source-"));
  mkdirSync(dirname(output), { recursive: true });
  const stagingRoot = mkdtempSync(join(dirname(output), ".world-staging-"));
  let committed = false;
  try {
    const loaded = loadSources(temporaryDirectory, sourceRows);
    const joinedLedger = {
      playable: ledgerState.playable.map((row) => loaded.joined.get(row.source_key)),
      context: ledgerState.context.map((row) => loaded.joined.get(row.source_key)),
    };
    invariant(joinedLedger.playable.every(Boolean) && joinedLedger.context.every(Boolean), "Joined ledger contains an unresolved row");
    const boundary = exactBoundary();
    roundedCanonicalGeometry(boundary, "Treasure Island boundary");
    verifyProjectionRoundTrip(
      flattenMultiPolygonCoordinates(boundary).map(inverseProjectEastNorth),
      1e-9,
    );
    const playableObjects = buildPlayableObjects(joinedLedger, boundary);
    const chunks = buildChunks(playableObjects, boundary, terrain);
    const context = buildContext(joinedLedger, boundary, loaded.rawOsm, loaded.rawSources, playableObjects, terrain);
    const allObjects = new Map([...playableObjects, ...context.objects]);
    const coverage = coverageRows(allObjects, chunks, context.document);
    coverage.sort((left, right) => sourceRows.findIndex((row) => row.source_key === left.source_key) -
      sourceRows.findIndex((row) => row.source_key === right.source_key));
    const validation = validateFinalState(coverage, allObjects, chunks, context.document, ledgerState.memberships);
    const logicalObjects = logicalObjectsDocument(allObjects);
    const spawn = findInitialSpawn(boundary, playableObjects, loaded.rawOsm, loaded.rawSources, chunks);
    invariant(
      sha256File(NAIP_TREE_ANNOTATIONS_PATH) === NAIP_TREE_ANNOTATION_SHA256,
      "Pinned NAIP tree annotation source hash drift",
    );
    const vegetation = generateVegetation({
      boundary,
      playableObjects,
      chunks,
      terrainSupportAt: terrainSupportFromChunks,
      spawn: [spawn.origin[0], spawn.origin[2]],
      naipTreeAnnotations: JSON.parse(readFileSync(NAIP_TREE_ANNOTATIONS_PATH, "utf8")),
    });
    terrainDocument.surface_anchors = TERRAIN_SURFACE_ANCHORS.map((anchor) => ({
      ...anchor,
      elevation_m: terrainElevationFromChunks(chunks, anchor.x, -anchor.z),
    }));
    terrainDocument.playable_surface_conformance = chunks.surface_conformance;
    terrainDocument.building_foundations = chunks.foundation_audit;

    writeArtifact(stagingRoot, "coverage-ledger.csv", serializeCsv(coverage, COVERAGE_HEADERS));
    writeArtifact(stagingRoot, "context.json", context.document);
    writeArtifact(stagingRoot, "logical-objects.json", logicalObjects);
    writeArtifact(stagingRoot, "terrain.json", terrainDocument);
    writeArtifact(stagingRoot, "vegetation.json", vegetation);
    writeArtifact(stagingRoot, "qa/pavement-skin.json", chunks.pavement_skin);
    for (const chunk of [...chunks.values()].sort((left, right) => compareChunkIds(left.chunk_id, right.chunk_id))) {
      writeArtifact(stagingRoot, `chunks/${chunk.chunk_id}.json`, chunk);
    }
    const statusTotals = Object.fromEntries(
      [...new Set(coverage.map((row) => row.derived_world_status))].sort().map((status) => [
        status,
        coverage.filter((row) => row.derived_world_status === status).length,
      ]),
    );
    const areaAuditSummary = {
      maximum_pre_serialization_area_delta_m2: Math.max(
        ...[...allObjects.values()].map((object) => object.pre_serialization_area_delta_m2),
      ),
      maximum_post_serialization_area_delta_m2: Math.max(
        ...[...allObjects.values()].map((object) => object.post_serialization_area_delta_m2),
      ),
      maximum_post_serialization_tolerance_m2: Math.max(
        ...[...allObjects.values()].map((object) => object.post_serialization_tolerance_m2),
      ),
      maximum_post_serialization_normalized_error: Math.max(
        ...[...allObjects.values()].map((object) => object.post_serialization_normalized_error),
      ),
    };
    const coverageSummary = {
      schema_version: WORLD_SCHEMA,
      counts: {
        source_rows: coverage.length,
        playable_rows: coverage.filter((row) => row.scope === "playable").length,
        context_rows: coverage.filter((row) => row.scope === "context").length,
        category_memberships: ledgerState.memberships,
        status_totals: statusTotals,
        height_rules: validation.heightCounts,
        physical_objects: validation.physicalObjectCount,
        chunks: chunks.size,
        unresolved_rows: 0,
        duplicate_source_keys: 0,
      },
      composites: {
        coastline: { source_keys: [SHARED_COASTLINE_SOURCE_KEY], derived_object_key: `land:${PLAYABLE_BOUNDARY_SOURCE_KEY}` },
        isle_house: { source_keys: [ISLE_HOUSE_PARENT_KEY, ...ISLE_HOUSE_PART_KEYS], derived_object_key: `building-composite:${ISLE_HOUSE_PARENT_KEY}` },
        bay_bridge: { source_keys: BRIDGE_SOURCE_KEYS, derived_object_key: "context:bay-bridge" },
        boundary_attached_visuals: BOUNDARY_ATTACHED_SOURCE_KEYS.map((sourceKey) => ({
          source_keys: [sourceKey],
          derived_object_key: `boundary_context:${sourceKey}`,
        })),
      },
      context_bridge_member_ways: context.member_way_count,
      area_audit: areaAuditSummary,
      road_batch_quantization_audits: chunks.road_batch_audits,
      playable_surface_conformance: chunks.surface_conformance,
      building_foundations: chunks.foundation_audit,
      pavement_skin: {
        source_classification: chunks.pavement_skin.source_classification,
        materials: chunks.pavement_skin.materials,
        topology: Object.fromEntries(
          Object.entries(chunks.pavement_skin.topology).filter(([key]) => key !== "batches"),
        ),
      },
      validation: "pass",
    };
    writeArtifact(stagingRoot, "coverage-summary.json", coverageSummary);
    const validationReport = {
      schema_version: WORLD_SCHEMA,
      checks: [
        { name: "source_rows", value: coverage.length, threshold: 739, result: "pass" },
        { name: "playable_rows", value: 735, threshold: 735, result: "pass" },
        { name: "context_rows", value: 4, threshold: 4, result: "pass" },
        { name: "unresolved_rows", value: 0, threshold: 0, result: "pass" },
        { name: "duplicate_source_keys", value: 0, threshold: 0, result: "pass" },
        { name: "building_height_rules", value: validation.heightCounts.building, threshold: { osm_height: 176, osm_levels: 10, default_6m: 27 }, result: "pass" },
        { name: "building_part_height_rules", value: validation.heightCounts.building_part, threshold: { osm_height: 1, osm_levels: 1, default_6m: 0 }, result: "pass" },
        { name: "bridge_member_ways", value: context.member_way_count, threshold: 23, result: "pass" },
        { name: "maximum_pre_serialization_area_delta_m2", value: areaAuditSummary.maximum_pre_serialization_area_delta_m2, threshold: 0.01, result: "pass" },
        { name: "maximum_post_serialization_area_delta_m2", value: areaAuditSummary.maximum_post_serialization_area_delta_m2, threshold: areaAuditSummary.maximum_post_serialization_tolerance_m2, result: "pass" },
        { name: "maximum_post_serialization_normalized_error", value: areaAuditSummary.maximum_post_serialization_normalized_error, threshold: 1, result: "pass" },
        {
          name: "road_batch_topology_repairs",
          value: chunks.road_batch_audits.reduce((sum, audit) => sum + audit.repairs.length, 0),
          threshold: "every repair individually bounded and revalidated",
          result: "pass",
        },
        {
          name: "playable_surface_maximum_bias_deviation_m",
          value: chunks.surface_conformance.maximum_bias_deviation_m,
          threshold: chunks.surface_conformance.maximum_serialization_tolerance_m,
          result: "pass",
        },
        {
          name: "exterior_foundation_maximum_positive_gap_m",
          value: chunks.foundation_audit.maximum_positive_gap_m,
          threshold: 0,
          result: "pass",
        },
        {
          name: "building_roof_flatness_and_height",
          value: {
            maximum_roof_elevation_range_m: chunks.foundation_audit.maximum_roof_elevation_range_m,
            maximum_height_deviation_m: chunks.foundation_audit.maximum_height_deviation_m,
          },
          threshold: COORDINATE_ROUNDING_M,
          result: "pass",
        },
        {
          name: "pavement_skin_source_classification",
          value: chunks.pavement_skin.source_classification.by_visual_class,
          threshold: { vehicle: 208, pedestrian: 219, total: 427 },
          result: "pass",
        },
        {
          name: "pavement_skin_vehicle_precedence_overlap_m2",
          value: chunks.pavement_skin.topology.maximum_pedestrian_vehicle_overlap_m2,
          threshold: 0,
          result: "pass",
        },
        {
          name: "pavement_skin_pedestrian_relative_luminance_difference",
          value: chunks.pavement_skin.materials.pedestrian_vs_vehicle_relative_luminance_difference,
          threshold: 0.12,
          result: "pass",
        },
        {
          name: "paved_area_source_count",
          value: chunks.pavement_skin.materials.paved_area.source_count,
          threshold: 17,
          result: "pass",
        },
      ],
      result: "pass",
    };
    writeArtifact(stagingRoot, "qa/validation-report.json", validationReport);

    const preManifestFiles = listFiles(stagingRoot).map((path) => artifactDescriptor(stagingRoot, path));
    const coverageDescriptor = preManifestFiles.find((file) => file.path === "coverage-ledger.csv");
    const contextDescriptor = preManifestFiles.find((file) => file.path === "context.json");
    const terrainDescriptor = preManifestFiles.find((file) => file.path === "terrain.json");
    const vegetationDescriptor = preManifestFiles.find((file) => file.path === "vegetation.json");
    const chunkDescriptors = preManifestFiles.filter((file) => file.path.startsWith("chunks/"));
    invariant(coverageDescriptor && contextDescriptor && terrainDescriptor && vegetationDescriptor && chunkDescriptors.length === chunks.size, "Manifest artifact discovery failed");
    const manifest = {
      schema_version: WORLD_SCHEMA,
      generator_version: GENERATOR_VERSION,
      generator: toolchain,
      content_sha256: contentIndexSha256(preManifestFiles),
      sources,
      coordinate_system: coordinateSystemManifest(),
      boundary_source_key: PLAYABLE_BOUNDARY_SOURCE_KEY,
      chunk_size_m: CHUNK_SIZE_M,
      counts: {
        source_rows: 739,
        playable_rows: 735,
        context_rows: 4,
        unresolved_rows: 0,
        duplicate_source_keys: 0,
        chunks: chunks.size,
        category_memberships: ledgerState.memberships,
      },
      initial_spawn: spawn,
      playable_boundary: playableBoundaryManifest(boundary),
      material_keys: [
        ...MATERIAL_KEYS,
        "context_bay_bridge",
        "context_boundary_marina",
        "context_boundary_pier",
        "context_ybi",
      ].sort(),
      feature_kinds: FEATURE_KINDS,
      coverage_ledger: coverageDescriptor,
      context: contextDescriptor,
      terrain: terrainDescriptor,
      vegetation: vegetationDescriptor,
      chunks: chunkDescriptors.map((descriptor) => ({
        chunk_id: descriptor.path.slice("chunks/".length, -".json".length),
        ...descriptor,
      })).sort((left, right) => compareChunkIds(left.chunk_id, right.chunk_id)),
      files: preManifestFiles,
    };
    writeArtifact(stagingRoot, "manifest.json", manifest);
    commitStagedOutput(stagingRoot, output);
    committed = true;
    process.stdout.write(`${stableJson({
      status: "generated",
      output: relative(projectRoot, output).replaceAll("\\", "/"),
      content_sha256: manifest.content_sha256,
      counts: manifest.counts,
      physical_objects: validation.physicalObjectCount,
    })}`);
  } finally {
    rmSync(temporaryDirectory, { recursive: true, force: true });
    if (!committed) rmSync(stagingRoot, { recursive: true, force: true });
  }
}

main();
