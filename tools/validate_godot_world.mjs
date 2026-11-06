#!/usr/bin/env node

import { readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  BRIDGE_SOURCE_KEYS,
  BOUNDARY_ATTACHED_SOURCE_KEYS,
  CATEGORY_MEMBERSHIPS,
  CHUNK_SCHEMA,
  CONCRETE_ROAD_SURFACE,
  COORDINATE_ROUNDING_M,
  CONTEXT_SCHEMA,
  COVERAGE_HEADERS,
  DRAPED_LAYER_STEP_M,
  EXPECTED_COUNTS,
  FEATURE_KINDS,
  ISLE_HOUSE_PARENT_KEY,
  ISLE_HOUSE_PART_KEYS,
  MATERIAL_KEYS,
  PIER_DECK_SOURCE_KEYS,
  PLAYABLE_BOUNDARY_SOURCE_KEY,
  ROAD_SURFACE_BIASES_M,
  ROAD_VISUAL_CLASSES,
  SHARED_COASTLINE_SOURCE_KEY,
  SOURCE_CONTRACT,
  WORLD_SCHEMA,
  YBI_SOURCE_KEY,
  compareChunkIds,
  contentIndexSha256,
  invariant,
  parseCsv,
  sha256File,
  stableJson,
  verifySourceContract,
} from "./lib/world-contract.mjs";
import { validateMesh } from "./lib/mesh-output.mjs";
import {
  differenceMultiPolygons,
  geometryToMultiPolygon,
  intersectMultiPolygons,
  multiPolygonArea,
  multiPolygonBounds,
  pointInMultiPolygon,
  rectangleMultiPolygon,
  signedRingArea,
} from "./lib/osm-geometry.mjs";
import { loadTerrainOverrides } from "./lib/terrain-overrides.mjs";
import { loadTerrainRaster } from "./lib/terrain-raster.mjs";
import {
  SHORELINE_BANDS,
  SHORELINE_BOULDER_MATERIAL,
  SHORELINE_CLOSURE_KINDS,
  SHORELINE_COBBLE_MAX_TOP_M,
  SHORELINE_DRIFTWOOD_MATERIAL,
  SHORELINE_OUTSIDE_CLEARANCE_M,
  SHORELINE_OVERLAY_MATERIAL,
  SHORELINE_OVERLAY_PREFIX,
  SHORELINE_PROTOTYPE_KINDS,
  SHORELINE_RECORD_MATERIALS,
  SHORELINE_SCHEMA,
  SHORELINE_SLOPE_MATERIAL,
  SHORELINE_TONE_LENGTH,
  SHORELINE_VERGE_MATERIAL,
  WATER_Y_M,
  unpackShorelineBatch,
  unpackShorelineRecord,
} from "./lib/shoreline-generation.mjs";
import {
  STREET_DETAIL_GROUND_LAYER,
  STREET_DETAIL_KINDS,
  STREET_DETAIL_LAYERS,
  STREET_DETAIL_SCHEMA,
  STREET_DETAIL_SOURCES,
} from "./lib/street-detail-generation.mjs";
import { CAR_BODY_NAMES, CAR_FINISHES, CAR_PAINTS, MAX_TWIST_M, STREET_CLUTTER_PROPS, visibleGroundIndex } from "./lib/street-clutter-generation.mjs";
import { carBodyGeometry } from "./lib/street-clutter-kit.mjs";
import {
  fenceHeight, fenceParamsError, GATE_LEAF_LIFT_M, gateLeaves, STREET_FENCE_BANNER_TYPES, STREET_FENCE_GATE_HINGES, STREET_FENCE_GATE_STYLES, STREET_FENCE_GATED_TYPES, STREET_FENCE_INSIDE,
  STREET_FENCE_TYPES,
} from "./lib/street-fence-generation.mjs";
import {
  BIKE_RACK_HOOP_SPACING_M, BIKE_RACK_MAX_HOOPS, MAX_LEG_DROP_M, MAX_REST_TILT_RAD, MAX_SPUR_M, PAD_SKIRT_M, restTilt, STREET_FURNITURE_FEET, STREET_FURNITURE_PADS, STREET_FURNITURE_PROPS,
  streetFurnitureFootprint,
} from "./lib/street-furniture-generation.mjs";
import { YARD_KIT_KEYS, YARD_KIT_PARTS, YARD_KIT_PROPS, YARD_MAX_FLOAT_M, yardMaxSink, yardPropFootprint, yardPropParamsError, yardPropRests, yardRestGaps } from "./lib/street-yard-kit.mjs";
import { BERM_MODULE, BERM_SPECS, RIDGE_MODULE, yardKitMeshes } from "./lib/street-yard-meshes.mjs";
import { isDeckRow, isMooredRow, isYardRow, MOORED_PROP_VARIANTS } from "./lib/street-yard-generation.mjs";
import {
  STREET_VEGETATION_BURY_M,
  STREET_VEGETATION_MAX_FOOT_SPREAD_M,
  STREET_VEGETATION_PROPS,
  STREET_VEGETATION_SCALE_RANGE,
  footSamples,
} from "./lib/street-vegetation-generation.mjs";
import { crownRadius, pavingUnder, unpackPlantingRows } from "./lib/street-planting-generation.mjs";
import {
  STREET_GROUND_EDGE_MERGE_M,
  STREET_GROUND_FEATURE_KINDS,
  STREET_GROUND_MAXIMUM_HEIGHT_M,
  STREET_GROUND_MINIMUM_HEIGHT_M,
} from "./lib/street-ground-generation.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(scriptDirectory, "..");
const EXPECTED_FERRY_SPAWN = Object.freeze({
  origin: Object.freeze([-104.364, 3.457, 786.024]),
  yaw: -0.119,
});
const EXPECTED_TERRAIN_STATISTICS = Object.freeze({
  valid_sample_count: 2_492_288,
  minimum_elevation_m: -1.08,
  maximum_elevation_m: 104.756,
});
// Street-ground record kinds: object key prefix -> feature kind, material,
// collision and spray opacity. Every record holds one chunk's share of a layer.
// A deliberate copy of RECORD_KINDS in tools/lib/street-ground-generation.mjs:
// the validator states what it accepts on its own, so a generator change that
// adds or reroutes a record kind fails here until it is reviewed into both.
const STREET_GROUND_RECORDS = Object.freeze({
  "street-kerb": ["street_kerb", "street_kerb_concrete", "world_solid", true],
  "street-planting": ["street_kerb", "street_kerb_planting", "world_solid", true],
  "street-plaza": ["street_kerb", "street_plaza_pavers", "world_solid", true],
  "street-verge": ["street_kerb", "street_kerb_verge", "world_solid", true],
  "street-ramp": ["street_kerb_support", "street_kerb_support", "world_solid", false],
  "street-gutter": ["street_paint", "street_gutter", "none", false],
  "street-parking": ["street_paint", "street_parking", "none", false],
  "street-marking": ["street_paint", "street_marking", "none", false],
  "street-wear": ["street_paint", "street_wear", "none", false],
  // A zone's flat-lying ground (tools/lib/street-ground-generation.mjs PARK_SURFACE_MATERIALS):
  // the yards' shared surfaces and Cityside Park's.
  "black-plastic": ["street_paint", "black_plastic", "none", false],
  "rubble-grey": ["street_paint", "rubble_grey", "none", false],
  "yard-asphalt": ["street_paint", "yard_asphalt", "none", false],
  "yard-asphalt-pale": ["street_paint", "yard_asphalt_pale", "none", false],
  "yard-asphalt-fresh": ["street_paint", "yard_asphalt_fresh", "none", false],
  "yard-gravel": ["street_paint", "yard_gravel", "none", false],
  "yard-gravel-pale": ["street_paint", "yard_gravel_pale", "none", false],
  "yard-concrete": ["street_paint", "yard_concrete", "none", false],
  "yard-pond": ["street_paint", "yard_pond", "none", false],
  "yard-sand-pale": ["street_paint", "yard_sand_pale", "none", false],
  "yard-soil-dark": ["street_paint", "yard_soil_dark", "none", false],
  "park-asphalt": ["street_paint", "park_asphalt", "none", false],
  "park-concrete": ["street_paint", "park_concrete", "none", false],
  "park-dg": ["street_paint", "park_dg", "none", false],
  "park-gravel": ["street_paint", "park_gravel", "none", false],
  "park-lawn": ["street_paint", "park_lawn", "none", false],
  "park-mulch": ["street_paint", "park_mulch", "none", false],
  "park-paint-pink": ["street_paint", "park_paint_pink", "none", false],
  "park-plaza-lens": ["street_paint", "park_plaza_lens", "none", false],
  "park-plaza-zigzag": ["street_paint", "park_plaza_zigzag", "none", false],
});

function listFiles(root, current = root) {
  const files = [];
  for (const entry of readdirSync(current, { withFileTypes: true }).sort((left, right) => left.name.localeCompare(right.name))) {
    const path = join(current, entry.name);
    if (entry.isDirectory()) files.push(...listFiles(root, path));
    else files.push(relative(root, path).replaceAll("\\", "/"));
  }
  return files;
}

function descriptor(root, path) {
  const absolutePath = resolve(root, path);
  return { path, sha256: sha256File(absolutePath), bytes: statSync(absolutePath).size };
}

function splitValues(value) {
  return value === "" ? [] : value.split(";");
}

function validateCoverage(worldRoot, manifest) {
  const text = readFileSync(resolve(worldRoot, manifest.coverage_ledger.path), "utf8");
  invariant(!text.includes("unresolved"), "Coverage ledger contains unresolved text");
  const rows = parseCsv(text);
  invariant(stableJson(Object.keys(rows[0])) === stableJson(COVERAGE_HEADERS), "Coverage headers drifted");
  invariant(rows.length === EXPECTED_COUNTS.source_rows, `Expected 739 coverage rows, found ${rows.length}`);
  invariant(new Set(rows.map((row) => row.source_key)).size === rows.length, "Coverage has duplicate source keys");
  invariant(rows.filter((row) => row.scope === "playable").length === EXPECTED_COUNTS.playable_rows, "Playable coverage count drift");
  invariant(rows.filter((row) => row.scope === "context").length === EXPECTED_COUNTS.context_rows, "Context coverage count drift");
  // Buildings left out as demolished (tools/config/demolished-buildings.json, listed
  // in the manifest) keep their row with the status demolished and no geometry.
  const demolished = new Set(manifest.demolished_buildings?.source_keys ?? []);
  invariant(Array.isArray(manifest.demolished_buildings?.source_keys) && stableJson([...demolished].sort()) === stableJson(manifest.demolished_buildings.source_keys), "Manifest demolished buildings must be a sorted, unique key list");
  for (const row of rows) {
    if (row.derived_world_status !== "demolished" && !demolished.has(row.source_key)) continue;
    invariant(demolished.has(row.source_key) && row.derived_world_status === "demolished", `${row.source_key} demolished status and manifest list disagree`);
    invariant(row.scope === "playable" && row.categories === "building" && row.derived_object_key === `building:${row.source_key}` && row.representation_kind === "direct", `${row.source_key} demolished row is not a standalone building`);
    invariant(row.part_keys === "" && row.chunk_ids === "" && row.vertex_count === "0" && row.triangle_count === "0" && row.collision_triangle_count === "0", `${row.source_key} demolished row keeps geometry`);
  }
  invariant(rows.filter((row) => row.derived_world_status === "demolished").length === demolished.size, "A manifest demolished building has no coverage row");
  invariant(rows.every((row) => ["represented", "composite_member", "context", "demolished"].includes(row.derived_world_status)), "Coverage has an invalid status");
  invariant(rows.every((row) => row.validation === "pass"), "Coverage has a non-pass validation cell");
  const byKey = new Map(rows.map((row) => [row.source_key, row]));
  const landCompositeKey = `land:${PLAYABLE_BOUNDARY_SOURCE_KEY}`;
  invariant(byKey.get(PLAYABLE_BOUNDARY_SOURCE_KEY)?.derived_object_key === landCompositeKey, "Land object key drift");
  invariant(byKey.get(PLAYABLE_BOUNDARY_SOURCE_KEY)?.composite_key === landCompositeKey, "Land composite declaration drift");
  invariant(byKey.get(SHARED_COASTLINE_SOURCE_KEY)?.derived_object_key === landCompositeKey, "Coastline composite drift");
  invariant(byKey.get(SHARED_COASTLINE_SOURCE_KEY)?.composite_key === landCompositeKey, "Coastline composite declaration drift");
  for (const key of [ISLE_HOUSE_PARENT_KEY, ...ISLE_HOUSE_PART_KEYS]) {
    invariant(byKey.get(key)?.derived_object_key === `building-composite:${ISLE_HOUSE_PARENT_KEY}`, `Isle House composite drift for ${key}`);
  }
  for (const key of BRIDGE_SOURCE_KEYS) {
    invariant(byKey.get(key)?.derived_object_key === "context:bay-bridge", `Bridge composite drift for ${key}`);
  }
  for (const key of BOUNDARY_ATTACHED_SOURCE_KEYS) {
    const row = byKey.get(key);
    invariant(row?.scope === "playable", `${key} boundary-attached scope drift`);
    invariant(row?.derived_world_status === "composite_member", `${key} must be a composite member`);
    invariant(row?.derived_object_key === `boundary_context:${key}`, `${key} boundary composite key drift`);
    invariant(row?.chunk_ids === "", `${key} must not enter playable chunks`);
  }
  // A pier deck past the outline keeps its playable overlay and adds its deck.
  for (const key of PIER_DECK_SOURCE_KEYS) {
    const row = byKey.get(key);
    invariant(row?.scope === "playable" && row.derived_object_key === `terrain:${key}`, `${key} pier deck source drift`);
    invariant(splitValues(row.part_keys).includes(`boundary_context:${key}`) && row.chunk_ids !== "", `${key} pier deck parts drift`);
  }
  invariant(byKey.get(YBI_SOURCE_KEY)?.derived_object_key === "context:ybi", "YBI context key drift");
  const playable = rows.filter((row) => row.scope === "playable");
  for (const [category, expected] of Object.entries(CATEGORY_MEMBERSHIPS)) {
    const actual = playable.filter((row) => splitValues(row.categories).includes(category)).length;
    invariant(actual === expected, `${category} membership drift: expected ${expected}, found ${actual}`);
  }
  const buildingRules = { osm_height: 0, osm_levels: 0, default_6m: 0 };
  const partRules = { osm_height: 0, osm_levels: 0, default_6m: 0 };
  for (const row of playable) {
    const categories = splitValues(row.categories);
    if (categories.includes("building")) buildingRules[row.dimension_rule] += 1;
    if (categories.includes("building_part")) partRules[row.dimension_rule] += 1;
  }
  invariant(stableJson(buildingRules) === stableJson({ osm_height: 176, osm_levels: 10, default_6m: 27 }), "Building height rule counts drift");
  invariant(stableJson(partRules) === stableJson({ osm_height: 1, osm_levels: 1, default_6m: 0 }), "Building-part height rule counts drift");
  return { rows, byKey };
}

function validateRecords(worldRoot, manifest, coverage) {
  const physical = new Map();
  const chunkIds = manifest.chunks.map((chunk) => chunk.chunk_id);
  invariant(new Set(chunkIds).size === chunkIds.length, "Manifest has duplicate chunk ids");
  invariant(stableJson(chunkIds) === stableJson([...chunkIds].sort(compareChunkIds)), "Manifest chunks are not sorted");
  for (const chunkDescriptor of manifest.chunks) {
    invariant(chunkDescriptor.path === `chunks/${chunkDescriptor.chunk_id}.json`, `${chunkDescriptor.chunk_id} path mismatch`);
    const chunk = JSON.parse(readFileSync(resolve(worldRoot, chunkDescriptor.path), "utf8"));
    invariant(chunk.schema_version === CHUNK_SCHEMA, `${chunkDescriptor.chunk_id} schema mismatch`);
    invariant(chunk.chunk_id === chunkDescriptor.chunk_id, `${chunkDescriptor.chunk_id} internal id mismatch`);
    invariant(Array.isArray(chunk.records) && chunk.records.length > 0, `${chunk.chunk_id} has no records`);
    invariant(
      stableJson(chunk.records.map((record) => record.object_key)) ===
        stableJson(chunk.records.map((record) => record.object_key).sort()),
      `${chunk.chunk_id} records are not sorted`,
    );
    for (const record of chunk.records) {
      invariant(FEATURE_KINDS.includes(record.feature_kind), `${record.object_key} has unknown feature kind`);
      invariant(["none", "world_solid"].includes(record.collision_kind), `${record.object_key} invalid collision kind`);
      invariant(["none", "building_wall"].includes(record.receiver_kind), `${record.object_key} invalid receiver kind`);
      if (record.receiver_kind === "building_wall") {
        invariant(["building_wall", "building_part_wall"].includes(record.feature_kind), `${record.object_key} receiver is not a wall`);
        invariant(record.collision_kind === "world_solid" && record.opaque === true, `${record.object_key} wall receiver semantics drift`);
      }
      if (record.feature_kind === "road_path" || record.feature_kind === "major_area" || record.feature_kind === "terrain_overlay") {
        invariant(record.collision_kind === "none" && record.receiver_kind === "none", `${record.object_key} overlay collision leak`);
      }
      if (STREET_GROUND_FEATURE_KINDS.includes(record.feature_kind)) {
        const [prefix, chunkId] = record.object_key.split(":");
        const expected = STREET_GROUND_RECORDS[prefix];
        invariant(expected && chunkId === chunk.chunk_id, `${record.object_key} is not a street-ground record key for its chunk`);
        const [featureKind, materialKey, collisionKind, opaque] = expected;
        invariant(
          record.feature_kind === featureKind && record.material_key === materialKey && record.collision_kind === collisionKind &&
            record.opaque === opaque && record.receiver_kind === "none",
          `${record.object_key} street-ground semantics drift`,
        );
      }
      validateMesh(record, record.object_key);
      invariant(!physical.has(record.object_key), `Duplicate physical key ${record.object_key}`);
      physical.set(record.object_key, { record, chunk_id: chunk.chunk_id });
    }
  }

  const context = JSON.parse(readFileSync(resolve(worldRoot, manifest.context.path), "utf8"));
  invariant(context.schema_version === CONTEXT_SCHEMA, "Context schema mismatch");
  invariant(context.records.length === 2, `Expected 2 context records, found ${context.records.length}`);
  const expectedContext = new Map([
    ["context:ybi", [YBI_SOURCE_KEY]],
    ["context:bay-bridge", [...BRIDGE_SOURCE_KEYS].sort()],
  ]);
  for (const record of context.records) {
    invariant(expectedContext.has(record.object_key), `Unexpected context record ${record.object_key}`);
    invariant(stableJson(record.source_keys) === stableJson(expectedContext.get(record.object_key)), `${record.object_key} source anchors drift`);
    invariant(record.collision_kind === "none" && record.receiver_kind === "none" && record.opaque === false, `${record.object_key} context semantics leak`);
    validateMesh(record, record.object_key);
    if (record.object_key === "context:ybi") {
      const elevations = record.vertices.filter((_value, index) => index % 3 === 1);
      invariant(Math.min(...elevations) === 0, "YBI shoreline sides no longer meet the NAVD 88 waterline");
      invariant(Math.max(...elevations) >= 100, "YBI terrain no longer contains its USGS high ground");
    }
    if (record.object_key === "context:bay-bridge") {
      invariant(record.material_key === "context_bay_bridge", "Bay Bridge material contract drift");
    }
    invariant(!physical.has(record.object_key), `Duplicate context physical key ${record.object_key}`);
    physical.set(record.object_key, { record, chunk_id: null });
  }
  const boundaryVisualSources = [...BOUNDARY_ATTACHED_SOURCE_KEYS, ...PIER_DECK_SOURCE_KEYS];
  invariant(
    Array.isArray(context.boundary_attached_visuals) && context.boundary_attached_visuals.length === boundaryVisualSources.length,
    "Context must contain exactly the approved boundary-attached visuals and pier decks",
  );
  for (const record of context.boundary_attached_visuals) {
    invariant(record.context_kind === "boundary_attached_visual", `${record.object_key} boundary context kind drift`);
    invariant(record.source_keys.length === 1 && boundaryVisualSources.includes(record.source_keys[0]), `${record.object_key} invalid boundary-attached source`);
    if (PIER_DECK_SOURCE_KEYS.includes(record.source_keys[0])) {
      invariant(record.material_key === "context_boundary_pier", `${record.object_key} pier deck material drift`);
    }
    invariant(record.object_key === `boundary_context:${record.source_keys[0]}`, `${record.object_key} boundary context object key drift`);
    invariant(record.collision_kind === "none" && record.receiver_kind === "none" && record.opaque === false, `${record.object_key} boundary context semantics leak`);
    validateMesh(record, record.object_key);
    invariant(!physical.has(record.object_key), `Duplicate boundary context key ${record.object_key}`);
    physical.set(record.object_key, { record, chunk_id: null });
  }

  for (const row of coverage.rows) {
    const partKeys = splitValues(row.part_keys);
    invariant(partKeys.length > 0 || row.derived_world_status === "demolished", `${row.source_key} has no part keys`);
    for (const key of partKeys) invariant(physical.has(key), `${row.source_key} references missing physical ${key}`);
    for (const chunkId of splitValues(row.chunk_ids)) {
      invariant(chunkIds.includes(chunkId), `${row.source_key} references missing chunk ${chunkId}`);
      invariant(partKeys.some((key) => physical.get(key)?.chunk_id === chunkId), `${row.source_key}/${chunkId} has no matching physical part`);
    }
  }
  for (const { record } of physical.values()) {
    invariant(Array.isArray(record.source_keys) && record.source_keys.length > 0, `${record.object_key} has no source keys`);
    for (const sourceKey of record.source_keys) {
      invariant(coverage.byKey.has(sourceKey), `${record.object_key} references unknown source ${sourceKey}`);
      invariant(coverage.byKey.get(sourceKey).derived_world_status !== "demolished", `${record.object_key} builds the demolished ${sourceKey}`);
    }
  }
  return { physical, context };
}

function landFacet(record, offset, chunkId) {
  const vertices = record.indices.slice(offset, offset + 3).map((index) => ({
    east: record.vertices[index * 3],
    elevation: record.vertices[index * 3 + 1],
    north: -record.vertices[index * 3 + 2],
  }));
  return { id: `${chunkId}/${offset / 3}`, vertices };
}

function facetSample(facet, east, north) {
  const [a, b, c] = facet.vertices;
  const denominator = (b.north - c.north) * (a.east - c.east) +
    (c.east - b.east) * (a.north - c.north);
  invariant(Math.abs(denominator) > 1e-10, `${facet.id} is degenerate`);
  const weights = [
    ((b.north - c.north) * (east - c.east) + (c.east - b.east) * (north - c.north)) / denominator,
    ((c.north - a.north) * (east - c.east) + (a.east - c.east) * (north - c.north)) / denominator,
  ];
  weights.push(1 - weights[0] - weights[1]);
  const doubleArea = Math.abs(denominator);
  const oppositeLengths = [
    Math.hypot(b.east - c.east, b.north - c.north),
    Math.hypot(c.east - a.east, c.north - a.north),
    Math.hypot(a.east - b.east, a.north - b.north),
  ];
  const tolerances = oppositeLengths.map((length) =>
    COORDINATE_ROUNDING_M * 2 / (doubleArea / length));
  return {
    elevation: weights[0] * a.elevation + weights[1] * b.elevation + weights[2] * c.elevation,
    inside: weights.every((weight, index) => weight >= -tolerances[index]),
  };
}

function facetSerializationTolerance(facet) {
  const origin = facetSample(facet, facet.vertices[0].east, facet.vertices[0].north).elevation;
  const eastGradient = facetSample(facet, facet.vertices[0].east + 1, facet.vertices[0].north).elevation - origin;
  const northGradient = facetSample(facet, facet.vertices[0].east, facet.vertices[0].north + 1).elevation - origin;
  return COORDINATE_ROUNDING_M * 0.5 * (1 + Math.abs(eastGradient) + Math.abs(northGradient));
}

function containingFacet(facets, east, north) {
  for (const facet of facets) {
    const sample = facetSample(facet, east, north);
    if (sample.inside) return { facet, elevation: sample.elevation };
  }
  return null;
}

function owningFacetForPoints(facets, points) {
  for (const facet of facets) {
    if (points.every((point) => facetSample(facet, point[0], point[1]).inside)) return facet;
  }
  return null;
}

function owningSurfaceFacet(facets, triangle, biasM) {
  const planPoints = triangle.map((point) => [point[0], point[2]]);
  const candidates = facets.filter((facet) =>
    planPoints.every((point) => facetSample(facet, point[0], point[1]).inside));
  candidates.sort((left, right) => {
    const score = (facet) => Math.max(...triangle.map((point) =>
      Math.abs((point[1] - facetSample(facet, point[0], point[2]).elevation) - biasM)));
    return score(left) - score(right);
  });
  return candidates[0] ?? null;
}

function recordVertex(record, index) {
  return [record.vertices[index * 3], record.vertices[index * 3 + 1], -record.vertices[index * 3 + 2]];
}

function validateCoherentGeometry(records, terrain) {
  const facetsByChunk = new Map();
  for (const { record, chunk_id: chunkId } of records.physical.values()) {
    if (chunkId == null || record.feature_kind !== "land_ground") continue;
    const facets = facetsByChunk.get(chunkId) ?? [];
    for (let offset = 0; offset < record.indices.length; offset += 3) {
      facets.push(landFacet(record, offset, chunkId));
    }
    facetsByChunk.set(chunkId, facets);
  }
  const allFacets = [...facetsByChunk.values()].flat();

  let surfaceSamples = 0;
  let maximumBiasDeviation = 0;
  let exteriorSegments = 0;
  let sharedSegments = 0;
  let foundationSamples = 0;
  let waterSupportedSegments = 0;
  let roofCells = 0;
  let maximumRoofRange = 0;
  let maximumHeightDeviation = 0;
  let maximumFoundationGap = -Infinity;

  let streetGroundSamples = 0;
  for (const { record, chunk_id: chunkId } of records.physical.values()) {
    if (STREET_GROUND_FEATURE_KINDS.includes(record.feature_kind)) {
      // Every street-ground vertex sits on its chunk's land, within the kerb band.
      const facets = facetsByChunk.get(chunkId) ?? [];
      for (let index = 0; index < record.vertices.length / 3; index += 1) {
        const [east, elevation, north] = recordVertex(record, index);
        const land = containingFacet(facets, east, north);
        invariant(land, `${record.object_key} vertex ${index} is off its chunk's land`);
        const height = elevation - land.elevation;
        invariant(
          height >= STREET_GROUND_MINIMUM_HEIGHT_M - COORDINATE_ROUNDING_M * 2 && height <= STREET_GROUND_MAXIMUM_HEIGHT_M,
          `${record.object_key} vertex ${index} sits ${height} m above land, outside the street-ground band`,
        );
        streetGroundSamples += 1;
      }
      continue;
    }
    const isOverlay = ["road_path", "major_area", "terrain_overlay"].includes(record.feature_kind);
    if (isOverlay) {
      invariant(Number.isFinite(record.surface_bias_m), `${record.object_key} has no surface bias`);
      const facets = facetsByChunk.get(chunkId) ?? [];
      invariant(facets.length > 0, `${record.object_key} has no chunk land facets`);
      for (let offset = 0; offset < record.indices.length; offset += 3) {
        const triangle = record.indices.slice(offset, offset + 3).map((index) => recordVertex(record, index));
        const centroid = [
          triangle.reduce((sum, point) => sum + point[0], 0) / 3,
          triangle.reduce((sum, point) => sum + point[1], 0) / 3,
          triangle.reduce((sum, point) => sum + point[2], 0) / 3,
        ];
        const owner = owningSurfaceFacet(facets, triangle, record.surface_bias_m);
        invariant(owner, `${record.object_key} triangle ${offset / 3} has no single underlying land triangle`);
        const samples = [
          ...triangle,
          ...triangle.map((point, index) => {
            const next = triangle[(index + 1) % 3];
            return [(point[0] + next[0]) / 2, (point[1] + next[1]) / 2, (point[2] + next[2]) / 2];
          }),
          centroid,
        ];
        const tolerance = facetSerializationTolerance(owner);
        for (const [east, elevation, north] of samples) {
          const plane = facetSample(owner, east, north);
          invariant(plane.inside, `${record.object_key} triangle ${offset / 3} crosses a land-triangle boundary`);
          const deviation = Math.abs((elevation - plane.elevation) - record.surface_bias_m);
          invariant(deviation <= tolerance + 1e-9, `${record.object_key} bias deviation ${deviation} exceeds ${tolerance}`);
          maximumBiasDeviation = Math.max(maximumBiasDeviation, deviation);
          surfaceSamples += 1;
        }
      }
    }

    const isRoof = ["building_roof", "building_part_roof"].includes(record.feature_kind);
    const isWall = ["building_wall", "building_part_wall"].includes(record.feature_kind);
    if (!isRoof && !isWall) continue;
    for (const field of ["flat_base_elevation_m", "top_elevation_m", "source_height_m"]) {
      invariant(Number.isFinite(record[field]), `${record.object_key} is missing ${field}`);
    }
    maximumHeightDeviation = Math.max(
      maximumHeightDeviation,
      Math.abs((record.top_elevation_m - record.flat_base_elevation_m) - record.source_height_m),
    );
    if (isRoof) {
      const elevations = record.vertices.filter((_value, index) => index % 3 === 1);
      const range = Math.max(...elevations) - Math.min(...elevations);
      maximumRoofRange = Math.max(maximumRoofRange, range);
      invariant(range <= COORDINATE_ROUNDING_M && elevations.every((value) => Math.abs(value - record.top_elevation_m) <= COORDINATE_ROUNDING_M), `${record.object_key} roof flatness/top drift`);
      roofCells += 1;
      continue;
    }

    invariant(record.vertices.length % 12 === 0 && record.indices.length % 6 === 0, `${record.object_key} wall quad layout drift`);
    const facets = allFacets;
    let recordExterior = 0;
    let recordShared = 0;
    for (let vertexOffset = 0; vertexOffset < record.vertices.length / 3; vertexOffset += 4) {
      const start = recordVertex(record, vertexOffset);
      const end = recordVertex(record, vertexOffset + 1);
      const topEnd = recordVertex(record, vertexOffset + 2);
      const topStart = recordVertex(record, vertexOffset + 3);
      invariant(Math.abs(topStart[1] - record.top_elevation_m) <= COORDINATE_ROUNDING_M && Math.abs(topEnd[1] - record.top_elevation_m) <= COORDINATE_ROUNDING_M, `${record.object_key} wall top drift`);
      if (start[1] > record.flat_base_elevation_m + COORDINATE_ROUNDING_M && end[1] > record.flat_base_elevation_m + COORDINATE_ROUNDING_M) {
        sharedSegments += 1;
        recordShared += 1;
        continue;
      }
      const midpoint = [(start[0] + end[0]) / 2, (start[2] + end[2]) / 2];
      const owner = owningFacetForPoints(facets, [[start[0], start[2]], midpoint, [end[0], end[2]]]);
      if (owner == null) {
        invariant(start[1] <= terrain.building_foundations.water_datum_m - terrain.building_foundations.burial_margin_m + COORDINATE_ROUNDING_M && end[1] <= terrain.building_foundations.water_datum_m - terrain.building_foundations.burial_margin_m + COORDINATE_ROUNDING_M, `${record.object_key} unsupported wall floats above water datum`);
        waterSupportedSegments += 1;
      } else {
        for (const fraction of [0, 0.5, 1]) {
          const east = start[0] + (end[0] - start[0]) * fraction;
          const north = start[2] + (end[2] - start[2]) * fraction;
          const bottom = start[1] + (end[1] - start[1]) * fraction;
          const plane = facetSample(owner, east, north);
          invariant(plane.inside, `${record.object_key} foundation segment crosses a land-triangle boundary`);
          const gap = bottom - plane.elevation;
          invariant(gap <= COORDINATE_ROUNDING_M, `${record.object_key} foundation gap ${gap}`);
          maximumFoundationGap = Math.max(maximumFoundationGap, gap);
          foundationSamples += 1;
        }
      }
      exteriorSegments += 1;
      recordExterior += 1;
    }
    invariant(recordExterior === record.exterior_foundation_segments, `${record.object_key} exterior segment count drift`);
    invariant(recordShared === record.shared_wall_segments, `${record.object_key} shared segment count drift`);
  }

  const surface = terrain.playable_surface_conformance;
  const foundations = terrain.building_foundations;
  invariant(surfaceSamples === surface.sample_points, `Surface audit sample count ${surfaceSamples} != ${surface.sample_points}`);
  invariant(maximumBiasDeviation <= surface.maximum_serialization_tolerance_m + 1e-9, "Surface audit exceeds declared serialization tolerance");
  invariant(exteriorSegments === foundations.exterior_segments && sharedSegments === foundations.shared_segments, "Foundation segment totals drift");
  invariant(foundationSamples === foundations.sample_points && waterSupportedSegments === foundations.water_supported_exterior_segments, "Foundation support sample totals drift");
  invariant(roofCells === foundations.flat_roof_cells && maximumRoofRange <= foundations.tolerance_m && maximumHeightDeviation <= foundations.tolerance_m, "Building roof/base/height contract drift");
  invariant(maximumFoundationGap <= foundations.tolerance_m, "Foundation gap exceeds descriptor tolerance");
  return { surfaceSamples, maximumBiasDeviation, exteriorSegments, foundationSamples, waterSupportedSegments, roofCells, streetGroundSamples };
}

// The part of a convex polygon ([x, z] corners) where the linear f(point) >= 0.
function clipConvex(polygon, f) {
  const kept = [];
  for (let index = 0; index < polygon.length; index += 1) {
    const point = polygon[index];
    const next = polygon[(index + 1) % polygon.length];
    const here = f(point);
    const there = f(next);
    if (here >= 0) kept.push(point);
    if ((here >= 0) !== (there >= 0)) {
      const t = here / (here - there);
      kept.push([point[0] + (next[0] - point[0]) * t, point[1] + (next[1] - point[1]) * t]);
    }
  }
  return kept;
}

// Every visual-only draped surface (OSM areas, shoreline overlays, roads and
// paths, the street-ground layers and the zones' ground) must lie a layer step
// (DRAPED_LAYER_STEP_M) from any other it overlaps: two surfaces in one plane
// fight in the depth buffer and draw in stripes. Millimetre vertex rounding can
// bring a step down to DRAPED_LAYER_STEP_M - COORDINATE_ROUNDING_M, so for each
// overlapping pair of triangles this measures the plan area where their planes
// come closer than that. Pieces no wider (2 area / perimeter) than the street
// ground's vertex merge, which two layers that each build a shared edge can
// differ by along it, and record pairs under the 0.01 m2 floor of the
// serialization area tolerance are construction residue, not a drawn layer.
function validateDrapedLayers(records) {
  const limit = DRAPED_LAYER_STEP_M - COORDINATE_ROUNDING_M - 1e-9;
  const byChunk = new Map();
  for (const { record, chunk_id: chunkId } of records.physical.values()) {
    if (chunkId == null || record.collision_kind !== "none" ||
      !["major_area", "terrain_overlay", "road_path", "street_paint"].includes(record.feature_kind)) continue;
    const triangles = byChunk.get(chunkId) ?? [];
    for (let offset = 0; offset < record.indices.length; offset += 3) {
      const corners = [0, 1, 2].map((corner) => {
        const index = record.indices[offset + corner] * 3;
        return record.vertices.slice(index, index + 3);
      });
      const points = corners.map(([x, , z]) => [x, z]);
      const doubled = 2 * signedRingArea(points);
      if (Math.abs(doubled) < 1e-9) continue;
      // The triangle's plane, y = y0 + slopeX (x - x0) + slopeZ (z - z0).
      const [[x0, y0, z0], [x1, y1, z1], [x2, y2, z2]] = corners;
      const slopeX = ((y1 - y0) * (z2 - z0) - (y2 - y0) * (z1 - z0)) / doubled;
      const slopeZ = ((x1 - x0) * (y2 - y0) - (x2 - x0) * (y1 - y0)) / doubled;
      const heightAt = ([x, z]) => y0 + slopeX * (x - x0) + slopeZ * (z - z0);
      if (doubled < 0) points.reverse();
      const xs = points.map((point) => point[0]);
      const zs = points.map((point) => point[1]);
      triangles.push({ record, points, heightAt, minX: Math.min(...xs), maxX: Math.max(...xs), minZ: Math.min(...zs), maxZ: Math.max(...zs) });
    }
    byChunk.set(chunkId, triangles);
  }
  const crowded = new Map();
  for (const triangles of byChunk.values()) {
    triangles.sort((left, right) => left.minX - right.minX);
    for (let first = 0; first < triangles.length; first += 1) {
      const a = triangles[first];
      for (let second = first + 1; second < triangles.length && triangles[second].minX < a.maxX; second += 1) {
        const b = triangles[second];
        if (a.record === b.record || a.maxZ <= b.minZ || b.maxZ <= a.minZ) continue;
        let piece = a.points;
        for (let edge = 0; edge < 3 && piece.length > 0; edge += 1) {
          const [ax, az] = b.points[edge];
          const [bx, bz] = b.points[(edge + 1) % 3];
          piece = clipConvex(piece, ([x, z]) => (bx - ax) * (z - az) - (bz - az) * (x - ax));
        }
        if (piece.length < 3) continue;
        const separation = (point) => a.heightAt(point) - b.heightAt(point);
        const near = clipConvex(clipConvex(piece, (point) => limit - separation(point)), (point) => limit + separation(point));
        if (near.length < 3) continue;
        const area = signedRingArea(near);
        const perimeter = near.reduce((sum, point, index) => sum + Math.hypot(...[0, 1].map((axis) => near[(index + 1) % near.length][axis] - point[axis])), 0);
        if (area <= 0 || (2 * area) / perimeter <= STREET_GROUND_EDGE_MERGE_M) continue;
        const pair = [a.record.object_key, b.record.object_key].sort().join(" and ");
        crowded.set(pair, (crowded.get(pair) ?? 0) + area);
      }
    }
  }
  const failing = [...crowded].filter(([, area]) => area >= 0.01).sort((left, right) => right[1] - left[1] || left[0].localeCompare(right[0]));
  invariant(
    failing.length === 0,
    `${failing.length} pairs of overlapping draped surfaces lie less than ${DRAPED_LAYER_STEP_M} m apart: ` +
      failing.map(([pair, area]) => `${pair} (${area.toFixed(3)} m2)`).join("; "),
  );
}

function validateTerrain(worldRoot, manifest) {
  invariant(manifest.terrain?.path === "terrain.json", "Manifest terrain descriptor is missing");
  invariant(
    stableJson(descriptor(worldRoot, manifest.terrain.path)) === stableJson(manifest.terrain),
    "Terrain descriptor hash or byte count drift",
  );
  const terrain = JSON.parse(readFileSync(resolve(worldRoot, manifest.terrain.path), "utf8"));
  invariant(terrain.schema_version === "ti.usgs-terrain/1", "Terrain schema drift");
  invariant(terrain.locked_raster_object_id === 71_423, "Terrain source is not locked to USGS raster 71423");
  invariant(terrain.source_tile_id === "USGS_1M_10_x55y419_CA_SanFrancisco_B23.tif", "Terrain source tile drift");
  invariant(terrain.vertical_datum === "NAVD 88" && terrain.mesh_grid_size_m === 32, "Terrain vertical/grid contract drift");
  for (const [key, expected] of Object.entries(EXPECTED_TERRAIN_STATISTICS)) {
    invariant(terrain.statistics?.[key] === expected, `Terrain ${key} drift`);
  }
  invariant(Array.isArray(terrain.pinned_samples) && terrain.pinned_samples.length === 5, "Terrain pinned sample contract drift");
  invariant(terrain.pinned_samples.some((sample) => sample.id === "ybi_high_ground" && sample.elevation_m === 104.756), "YBI high-ground pin drift");
  invariant(terrain.pinned_samples.some((sample) => sample.id === "ybi_low_shoreline" && sample.elevation_m === 0), "YBI shoreline pin drift");
  invariant(Array.isArray(terrain.surface_anchors) && terrain.surface_anchors.length === 18, "Derived terrain surface-anchor contract drift");
  invariant(terrain.surface_anchors.some((anchor) => anchor.id === "01-ferry-spawn" && anchor.elevation_m === 3.457), "Ferry terrain surface anchor drift");
  return terrain;
}

function pointToSegmentDistance2d(point, start, end) {
  const deltaX = end[0] - start[0];
  const deltaZ = end[1] - start[1];
  const lengthSquared = deltaX * deltaX + deltaZ * deltaZ;
  if (lengthSquared === 0) return Math.hypot(point[0] - start[0], point[1] - start[1]);
  const fraction = Math.max(0, Math.min(1,
    ((point[0] - start[0]) * deltaX + (point[1] - start[1]) * deltaZ) / lengthSquared));
  return Math.hypot(
    point[0] - (start[0] + deltaX * fraction),
    point[1] - (start[1] + deltaZ * fraction),
  );
}

function pointInTriangle2d(point, triangle) {
  const [a, b, c] = triangle;
  const sign = (left, right) => (point[0] - right[0]) * (left[1] - right[1]) -
    (left[0] - right[0]) * (point[1] - right[1]);
  const values = [sign(a, b), sign(b, c), sign(c, a)];
  return !(values.some((value) => value < -1e-7) && values.some((value) => value > 1e-7));
}

function pointToRecordDistance(point, record) {
  let minimum = Infinity;
  for (let offset = 0; offset < record.indices.length; offset += 3) {
    const triangle = record.indices.slice(offset, offset + 3).map((index) => [
      record.vertices[index * 3], record.vertices[index * 3 + 2],
    ]);
    if (pointInTriangle2d(point, triangle)) return 0;
    for (let index = 0; index < 3; index += 1) {
      minimum = Math.min(minimum, pointToSegmentDistance2d(point, triangle[index], triangle[(index + 1) % 3]));
    }
  }
  return minimum;
}

function pointInRingXZ(point, ring) {
  let inside = false;
  for (let index = 0, previous = ring.length - 1; index < ring.length; previous = index, index += 1) {
    const [ax, az] = ring[previous];
    const [bx, bz] = ring[index];
    if ((az > point[1]) !== (bz > point[1]) && point[0] < ((bx - ax) * (point[1] - az)) / (bz - az) + ax) inside = !inside;
  }
  return inside;
}

function pointInPlayableBoundary(point, boundary) {
  return boundary.components.some((component) =>
    pointInRingXZ(point, component.outer) && !component.holes.some((hole) => pointInRingXZ(point, hole)));
}

// A terrain override re-meshes only land its config names: each cell it
// declares must overlap the scope of a site in tools/config/terrain-overrides.json,
// that is the generated surfaces of the site's OSM areas or its traced polygons,
// less its traced exclusions. Its protected way corridors stay in, so this bound
// is never stricter than the generator's own.
function assertOverrideCellsInScope(cells, records) {
  if (cells.length === 0) return;
  const { config } = loadTerrainOverrides(projectRoot);
  const eastNorth = (points) => [[points.map(([x, z]) => [x, -z])]];
  const sites = config.sites.map((site) => {
    const keys = new Set(site.scope.source_keys);
    const parts = site.scope.add_xz.map(eastNorth);
    for (const { record } of records.physical.values()) {
      if (!["major_area", "terrain_overlay"].includes(record.feature_kind) || record.source_keys.length !== 1 || !keys.has(record.source_keys[0])) continue;
      for (let offset = 0; offset < record.indices.length; offset += 3) {
        parts.push(eastNorth([0, 1, 2].map((corner) => {
          const index = record.indices[offset + corner] * 3;
          return [record.vertices[index], record.vertices[index + 2]];
        })));
      }
    }
    return { parts, exclusions: site.scope.exclude_xz.map((entry) => eastNorth(entry.points_xz)) };
  });
  for (const [minX, minZ, maxX, maxZ] of cells) {
    const cell = rectangleMultiPolygon(minX, -maxZ, maxX, -minZ);
    const inScope = sites.some(({ parts, exclusions }) => parts.some((part) => {
      const bounds = multiPolygonBounds(part);
      if (bounds.max_x <= minX || bounds.min_x >= maxX || bounds.max_y <= -maxZ || bounds.min_y >= -minZ) return false;
      return multiPolygonArea(differenceMultiPolygons(intersectMultiPolygons(cell, part), ...exclusions)) > 1e-6;
    }));
    invariant(inScope, `Terrain override cell [${minX}, ${minZ}, ${maxX}, ${maxZ}] lies outside every site scope in tools/config/terrain-overrides.json`);
  }
}

// The land the player walks on is the frozen USGS surface (the generator's
// sampler, at the serialized millimetre position) everywhere except the cells a
// configured terrain override re-meshes, edges included (terrain.json
// terrain_overrides, tools/lib/terrain-overrides.mjs). Visual passes (pavement,
// areas, street paint) add no land collision; their records are checked above.
function validateLandProvenance(records, terrain) {
  const raster = loadTerrainRaster(resolve(projectRoot, SOURCE_CONTRACT.terrain_dem.path));
  const cells = terrain.terrain_overrides?.refined_cell_bounds_m ?? [];
  invariant(Array.isArray(cells) && cells.every((cell) => Array.isArray(cell) && cell.length === 4 && cell.every(Number.isFinite)), "Terrain override cell bounds are malformed");
  assertOverrideCellsInScope(cells, records);
  const overridden = (x, z) => cells.some(([minX, minZ, maxX, maxZ]) =>
    x >= minX - COORDINATE_ROUNDING_M && x <= maxX + COORDINATE_ROUNDING_M && z >= minZ - COORDINATE_ROUNDING_M && z <= maxZ + COORDINATE_ROUNDING_M);
  let sampled = 0;
  let corrected = 0;
  for (const { record } of records.physical.values()) {
    if (record.feature_kind !== "land_ground") continue;
    invariant(record.collision_kind === "world_solid" && record.opaque === true, `${record.object_key} land lost its collision`);
    for (let index = 0; index < record.vertices.length; index += 3) {
      const [x, y, z] = [record.vertices[index], record.vertices[index + 1], record.vertices[index + 2]];
      if (overridden(x, z)) {
        corrected += 1;
        continue;
      }
      const expected = raster.sampleTerrainEastNorth(x, -z);
      invariant(
        Math.abs(y - expected) <= COORDINATE_ROUNDING_M * 2,
        `${record.object_key} land vertex at ${x},${z} sits at ${y}, off the USGS surface (${expected}) outside every terrain override`,
      );
      sampled += 1;
    }
  }
  invariant(sampled > 0, "No land vertex was checked against the USGS surface");
  return { usgs_vertices: sampled, terrain_override_vertices: corrected };
}

function validatePavementSkin(worldRoot, manifest, coverage, records, terrain) {
  const auditPath = "qa/pavement-skin.json";
  const auditDescriptor = manifest.files.find((entry) => entry.path === auditPath);
  invariant(auditDescriptor, "Manifest does not index the pavement-skin audit");
  invariant(
    stableJson(descriptor(worldRoot, auditPath)) === stableJson(auditDescriptor),
    "Pavement-skin audit descriptor drift",
  );
  const audit = JSON.parse(readFileSync(resolve(worldRoot, auditPath), "utf8"));
  invariant(audit.schema_version === "ti.pavement-skin/1" && audit.visual_only === true, "Pavement-skin schema/visual-only contract drift");
  invariant(
    stableJson(audit.source_classification.highway_tags_by_visual_class) === stableJson(ROAD_VISUAL_CLASSES),
    "Pavement highway classification drift",
  );
  invariant(
    stableJson(audit.source_classification.by_visual_class) === stableJson({ pedestrian: 219, vehicle: 208 }) &&
      audit.source_classification.source_count === 427,
    "Pavement class/source counts drift",
  );
  invariant(
    audit.materials.vehicle.material_key === "road_path" &&
      audit.materials.vehicle.albedo_srgb_hex === "555b60" &&
      audit.materials.vehicle.surface_bias_m === ROAD_SURFACE_BIASES_M.base &&
      audit.materials.pedestrian.material_key === "road_path_pedestrian" &&
      audit.materials.pedestrian.albedo_srgb_hex === "8b918e" &&
      audit.materials.pedestrian.surface_bias_m === ROAD_SURFACE_BIASES_M.pedestrian &&
      audit.materials.concrete.material_key === "road_path_concrete" &&
      audit.materials.concrete.surface_bias_m === ROAD_SURFACE_BIASES_M.pedestrian &&
      audit.materials.paved_area.material_key === "major_area_paved" &&
      audit.materials.paved_area.albedo_srgb_hex === "707573" &&
      audit.materials.paved_area.source_count === 17,
    "Pavement material palette or surface bias drift",
  );
  invariant(
    audit.materials.pedestrian_vs_vehicle_relative_luminance_difference >= 0.12,
    "Vehicle/pedestrian relative luminance differs by less than 12%",
  );
  invariant(
    audit.materials.paved_area.relative_luminance > audit.materials.vehicle.relative_luminance &&
      audit.materials.paved_area.relative_luminance < audit.materials.pedestrian.relative_luminance,
    "Paved-area luminance is not intermediate",
  );
  invariant(
    audit.topology.continuous_filled_base_union === true &&
      audit.topology.base_source_count === 427 &&
      audit.topology.vehicle_precedence_at_crossings === true &&
      audit.topology.maximum_pedestrian_vehicle_overlap_m2 === 0 &&
      audit.topology.vertical_separation_m >= 0.002 &&
      audit.topology.physical_collision_changed === false,
    "Pavement topology, precedence, or vertical-separation contract drift",
  );
  invariant(Array.isArray(audit.topology.batches) && audit.topology.batches.length > 0, "Pavement batch audit is empty");
  invariant(audit.topology.batches.every((batch) =>
    batch.base_object_key === `roads:${batch.chunk_id}` &&
      batch.plan_area_m2.base_union > 0 &&
      batch.plan_area_m2.pedestrian_vehicle_overlap === 0 &&
      batch.source_counts.all === batch.source_counts.vehicle + batch.source_counts.pedestrian),
  "Pavement batch union or vehicle-precedence audit failed");

  const sourceRows = parseCsv(readFileSync(resolve(projectRoot, SOURCE_CONTRACT.source_ledger.path), "utf8"));
  const sourceRoads = sourceRows.filter((row) => row.categories.split("|").includes("roads_paths"));
  const expectedByClass = { pedestrian: new Set(), vehicle: new Set() };
  const parkingSourceKeys = new Set();
  for (const row of sourceRows) {
    const tags = JSON.parse(row.tags_json);
    if (row.categories.split("|").includes("major_area") && tags.amenity === "parking") {
      parkingSourceKeys.add(row.source_key);
    }
  }
  const expectedConcrete = new Set();
  for (const row of sourceRoads) {
    const tags = JSON.parse(row.tags_json);
    const matches = Object.entries(ROAD_VISUAL_CLASSES)
      .filter(([, values]) => values.includes(tags.highway))
      .map(([visualClass]) => visualClass);
    invariant(matches.length === 1, `${row.source_key} has ${matches.length} pavement classes in independent validation`);
    expectedByClass[matches[0]].add(row.source_key);
    if (matches[0] === "vehicle" && tags.surface === CONCRETE_ROAD_SURFACE) expectedConcrete.add(row.source_key);
  }
  invariant(audit.materials.concrete.source_count === expectedConcrete.size, "Concrete vehicle-way count drift");
  invariant(
    expectedByClass.vehicle.size === 208 && expectedByClass.pedestrian.size === 219 && parkingSourceKeys.size === 17,
    "Independent OSM pavement classification counts drift",
  );

  const roadEntries = [...records.physical.values()].filter(({ record }) => record.feature_kind === "road_path");
  const baseEntries = roadEntries.filter(({ record }) => record.material_key === "road_path");
  const pedestrianEntries = roadEntries.filter(({ record }) => record.material_key === "road_path_pedestrian");
  const concreteEntries = roadEntries.filter(({ record }) => record.material_key === "road_path_concrete");
  invariant(
    baseEntries.length === audit.topology.base_record_count &&
      pedestrianEntries.length === audit.topology.pedestrian_record_count &&
      concreteEntries.length === audit.topology.concrete_record_count &&
      roadEntries.length === baseEntries.length + pedestrianEntries.length + concreteEntries.length,
    "Generated pavement record/material counts drift",
  );
  const baseByChunk = new Map(baseEntries.map((entry) => [entry.chunk_id, entry.record]));
  invariant(baseByChunk.size === baseEntries.length, "A chunk has more than one continuous pavement base");
  const baseSourceKeys = new Set(baseEntries.flatMap(({ record }) => record.source_keys));
  invariant(
    stableJson([...baseSourceKeys].sort()) === stableJson(sourceRoads.map((row) => row.source_key).sort()),
    "Continuous pavement base does not retain all 427 road/path source keys",
  );
  for (const row of coverage.rows.filter((candidate) => splitValues(candidate.categories).includes("roads_paths"))) {
    const parts = new Set(splitValues(row.part_keys));
    for (const chunkId of splitValues(row.chunk_ids)) {
      invariant(parts.has(`roads:${chunkId}`), `${row.source_key}/${chunkId} is not backed by the filled pavement base`);
    }
  }
  const visiblePedestrianSourceKeys = new Set();
  for (const { record, chunk_id: chunkId } of pedestrianEntries) {
    invariant(record.surface_bias_m === ROAD_SURFACE_BIASES_M.pedestrian, `${record.object_key} pedestrian bias drift`);
    invariant(record.object_key === `roads-pedestrian:${chunkId}`, `${record.object_key} pedestrian chunk ownership drift`);
    const base = baseByChunk.get(chunkId);
    invariant(base && base.surface_bias_m === ROAD_SURFACE_BIASES_M.base, `${record.object_key} has no lower filled base`);
    for (const sourceKey of record.source_keys) {
      invariant(expectedByClass.pedestrian.has(sourceKey), `${record.object_key} contains vehicle source ${sourceKey}`);
      visiblePedestrianSourceKeys.add(sourceKey);
    }
    for (let offset = 0; offset < record.indices.length; offset += 3) {
      const triangle = record.indices.slice(offset, offset + 3).map((index) => [
        record.vertices[index * 3], record.vertices[index * 3 + 2],
      ]);
      const samples = [
        ...triangle,
        [
          triangle.reduce((sum, point) => sum + point[0], 0) / 3,
          triangle.reduce((sum, point) => sum + point[1], 0) / 3,
        ],
      ];
      invariant(
        samples.every((point) => pointToRecordDistance(point, base) <= COORDINATE_ROUNDING_M * 2),
        `${record.object_key} escapes its continuous pavement base`,
      );
    }
  }
  invariant(
    visiblePedestrianSourceKeys.size === audit.topology.pedestrian_sources_with_visible_skin,
    "Pedestrian visible-source audit drift",
  );
  // The concrete skin: only concrete-surfaced vehicle ways, at the pedestrian
  // height, on its chunk's base, and never over the pedestrian skin.
  const visibleConcreteSourceKeys = new Set();
  const pedestrianByChunk = new Map(pedestrianEntries.map((entry) => [entry.chunk_id, entry.record]));
  for (const { record, chunk_id: chunkId } of concreteEntries) {
    invariant(record.surface_bias_m === ROAD_SURFACE_BIASES_M.pedestrian, `${record.object_key} concrete skin bias drift`);
    invariant(record.object_key === `roads-concrete:${chunkId}`, `${record.object_key} concrete chunk ownership drift`);
    const base = baseByChunk.get(chunkId);
    invariant(base && base.surface_bias_m === ROAD_SURFACE_BIASES_M.base, `${record.object_key} has no lower filled base`);
    for (const sourceKey of record.source_keys) {
      invariant(expectedConcrete.has(sourceKey), `${record.object_key} contains non-concrete source ${sourceKey}`);
      visibleConcreteSourceKeys.add(sourceKey);
    }
    const pedestrian = pedestrianByChunk.get(chunkId);
    for (let offset = 0; offset < record.indices.length; offset += 3) {
      const triangle = record.indices.slice(offset, offset + 3).map((index) => [
        record.vertices[index * 3], record.vertices[index * 3 + 2],
      ]);
      const centroid = [
        triangle.reduce((sum, point) => sum + point[0], 0) / 3,
        triangle.reduce((sum, point) => sum + point[1], 0) / 3,
      ];
      invariant(
        [...triangle, centroid].every((point) => pointToRecordDistance(point, base) <= COORDINATE_ROUNDING_M * 2),
        `${record.object_key} escapes its continuous pavement base`,
      );
      invariant(
        !pedestrian || pointToRecordDistance(centroid, pedestrian) > 0,
        `${record.object_key} overlaps the pedestrian skin`,
      );
    }
  }
  invariant(
    visibleConcreteSourceKeys.size === audit.topology.concrete_sources_with_visible_skin,
    "Concrete visible-source audit drift",
  );

  for (const sourceKey of parkingSourceKeys) {
    const row = coverage.byKey.get(sourceKey);
    invariant(row, `Parking source ${sourceKey} is absent from coverage`);
    const sourceRecords = splitValues(row.part_keys).map((key) => records.physical.get(key)?.record).filter(Boolean);
    invariant(
      sourceRecords.some((record) => record.feature_kind === "major_area" && record.material_key === "major_area_paved"),
      `${sourceKey} does not use the intermediate paved-area material`,
    );
  }
  invariant(MATERIAL_KEYS.every((key) => manifest.material_keys.includes(key)), "Manifest omits a declared world material key");
  invariant(
    terrain.playable_surface_conformance.minimum_clearance_m >= 0.019 &&
      terrain.playable_surface_conformance.maximum_clearance_m <= 0.081,
    "Pavement skin left the established 0.019-0.081 m surface envelope",
  );
  invariant(terrain.building_foundations.maximum_positive_gap_m === 0, "Pavement pass changed the zero-gap foundation contract");

  return {
    base_records: baseEntries.length,
    pedestrian_records: pedestrianEntries.length,
    visible_pedestrian_sources: visiblePedestrianSourceKeys.size,
    relative_luminance_difference: audit.materials.pedestrian_vs_vehicle_relative_luminance_difference,
  };
}

// The serialized records grouped back into chunks with plan bounds, for the
// street-vegetation visible-ground query.
function chunksOf(records) {
  const chunks = new Map();
  for (const { record, chunk_id: chunkId } of records.physical.values()) {
    if (!chunks.has(chunkId)) chunks.set(chunkId, { chunk_id: chunkId, records: [], bounds_m: { min_x: Infinity, max_x: -Infinity, min_z: Infinity, max_z: -Infinity } });
    const chunk = chunks.get(chunkId);
    chunk.records.push(record);
    for (let index = 0; index < record.vertices.length; index += 3) {
      chunk.bounds_m.min_x = Math.min(chunk.bounds_m.min_x, record.vertices[index]);
      chunk.bounds_m.max_x = Math.max(chunk.bounds_m.max_x, record.vertices[index]);
      chunk.bounds_m.min_z = Math.min(chunk.bounds_m.min_z, record.vertices[index + 2]);
      chunk.bounds_m.max_z = Math.max(chunk.bounds_m.max_z, record.vertices[index + 2]);
    }
  }
  return chunks;
}

// A low plant's crown is sampled more densely here than the generator samples
// it (which also keeps PAVING_CLEAR_M from paving): [fraction of the radius, points].
const CROWN_CHECK_RINGS = Object.freeze([[1 / 3, 8], [2 / 3, 16], [1, 32]]);

// A planted vegetation row: a kit prop of its kind with a variant and scale in
// range, and a foot that meets the visible ground: nowhere under the foot is the
// ground lower than the foot (it would float) and nowhere is it higher than the
// trunk runs on below it (it would show a gap round a buried foot). A low plant
// (no trunk) holds its whole crown off sidewalks, roads, paths and plazas.
function validatePlantedRow(row, groundAt) {
  const spec = STREET_VEGETATION_PROPS[row.prop];
  invariant(spec && spec.kinds.includes(row.kind) && row.status === "placed", `${row.id} prop ${row.prop} does not plant a placed ${row.kind} row`);
  const params = row.prop_params ?? {};
  invariant(Number.isInteger(params.variant) && params.variant >= 0 && params.variant < spec.variants, `${row.id} variant is invalid`);
  invariant(Number.isFinite(params.scale) && params.scale >= STREET_VEGETATION_SCALE_RANGE[0] && params.scale <= STREET_VEGETATION_SCALE_RANGE[1], `${row.id} scale is invalid`);
  invariant(Number.isFinite(params.lift_m) && Number.isFinite(params.foot_spread_m) && Number.isFinite(params.well_m) && params.well_m >= 0, `${row.id} foot settling is invalid`);
  invariant(Number.isFinite(row.yaw_radians), `${row.id} needs a yaw`);
  const foot = row.position_m[1] + row.surface.bias_m + params.lift_m;
  let low = Infinity;
  let high = -Infinity;
  for (const point of footSamples([row.position_m[0], row.position_m[2]], spec.foot_m * params.scale)) {
    const ground = groundAt(point);
    invariant(ground, `${row.id} has no visible ground under its foot`);
    low = Math.min(low, ground.y);
    high = Math.max(high, ground.y);
  }
  // Coordinates are rounded to the millimetre on both sides of this comparison.
  invariant(foot <= low + 0.002, `${row.id} floats ${(foot - low).toFixed(3)} m above the visible ground`);
  invariant(high - foot <= Math.min(STREET_VEGETATION_MAX_FOOT_SPREAD_M, STREET_VEGETATION_BURY_M) + 0.002, `${row.id} foot is buried ${(high - foot).toFixed(3)} m deep on one side`);
  if (!spec.trunk) {
    const paving = pavingUnder([row.position_m[0], row.position_m[2]], crownRadius(row.prop, params.variant, params.scale), groundAt, CROWN_CHECK_RINGS);
    invariant(paving === null, `${row.id} (${row.prop}) reaches over ${paving} at ${row.position_m[0]}, ${row.position_m[2]}`);
  }
  if (params.well_m > 0) {
    invariant(Number.isFinite(params.well_lift_m) && Array.isArray(params.well_slope) && params.well_slope.length === 2 && params.well_slope.every(Number.isFinite), `${row.id} mulch pit is invalid`);
    // The pit's rim lies on the plane of the paving, within a centimetre and a half.
    for (const point of footSamples([row.position_m[0], row.position_m[2]], params.well_m / 2)) {
      const ground = groundAt(point);
      invariant(ground, `${row.id} mulch pit has no paving under it`);
      const plane = foot + params.well_lift_m + params.well_slope[0] * (point[0] - row.position_m[0]) + params.well_slope[1] * (point[1] - row.position_m[2]);
      invariant(Math.abs(plane - ground.y) <= 0.015, `${row.id} mulch pit leaves its paving by ${(plane - ground.y).toFixed(3)} m`);
    }
  }
}

// A street prop stands on the visible ground, never sunk into a sidewalk or
// floating over it. Furniture and the anchored clutter (barricades, cones)
// keep their base, the row's y with its surface bias and any lift, within these
// of the ground at their anchor (m): the yard rows' float limit both ways, as a
// prop on paving has no reason to sink (they rest within a millimetre). A
// parked car's tyres, set from its pitch, roll, twist and lift, rest on the
// ground at their centres: they float at most the yard vehicles' 0.1 m (the
// settle lifts a car about a centimetre off a lip or paint line) and sink 2 cm
// at most. A yard kit prop (isYardRow) rests on its plan's corners and a grid
// over it, checked there (validateYardRest). Any other clutter prop fails: a
// new prop needs its own branch here, so none is placed unchecked.
const PROP_REST_FLOAT_M = 0.08;
const PROP_REST_SINK_M = 0.08;
const ANCHORED_CLUTTER = Object.freeze(["barricade", "dumpster", "stock_tank_planter", "traffic_cone"]);
const TYRE_REST_FLOAT_M = 0.1;
const TYRE_REST_SINK_M = 0.02;

function validatePropRest(row, groundAt) {
  const params = row.prop_params ?? {};
  const base = row.position_m[1] + row.surface.bias_m + (Number.isFinite(params.lift) ? params.lift : 0);
  const rests = (gap, what, where) => invariant(gap !== null && gap <= (row.prop === "parked_car" ? TYRE_REST_FLOAT_M : PROP_REST_FLOAT_M) && gap >= -(row.prop === "parked_car" ? TYRE_REST_SINK_M : PROP_REST_SINK_M),
    `${row.id} ${what} ${gap === null ? "has no visible ground under it" : gap > 0 ? `floats ${gap.toFixed(3)} m above the visible ground` : `sinks ${(-gap).toFixed(3)} m into the visible ground`} at ${where.map((value) => value.toFixed(2)).join(", ")}`);
  if (row.prop === "parked_car") {
    const geometry = carBodyGeometry(params.body);
    const front = [-Math.sin(row.yaw_radians), Math.cos(row.yaw_radians)];
    const right = [front[1], -front[0]];
    for (const [name, [x, , z]] of Object.entries(geometry.wheels)) {
      // The tyre's centre in world x, z (z = -north); the car frame's z runs back.
      const point = [row.position_m[0] + right[0] * x - front[0] * z, row.position_m[2] - right[1] * x + front[1] * z];
      const ground = groundAt(point);
      const tyre = base - Math.tan(params.pitch) * z - Math.tan(params.roll) * x + params.twist * Math.sign(x) * Math.sign(z);
      rests(ground ? tyre - ground.y : null, `${name} tyre`, point);
    }
  } else if (row.layer === "furniture" && STREET_FURNITURE_PADS.includes(row.prop)) {
    // A prop on a level pad (a bus shelter, a transformer, a charger bay): at
    // its centre and round the edge of its plan the pad's foot sinks at most
    // the props' limit and floats at most its skirt (settlePad).
    invariant(row.footprint_m !== undefined && Number.isFinite(params.lift) && params.lift >= 0, `${row.id} ${row.prop} needs its footprint and pad lift`);
    const [c, s] = [Math.cos(row.yaw_radians ?? 0), Math.sin(row.yaw_radians ?? 0)];
    const points = [[0, 0]];
    for (const [lx, lz] of [[-1, -1], [1, -1], [1, 1], [-1, 1], [0, -1], [1, 0], [0, 1], [-1, 0]]) points.push([(lx * row.footprint_m.x_m) / 2, (lz * row.footprint_m.z_m) / 2]);
    for (const [x, z] of points) {
      const point = [row.position_m[0] + x * c + z * s, row.position_m[2] - x * s + z * c];
      const ground = groundAt(point);
      const gap = ground ? base - ground.y : null;
      invariant(gap !== null && gap >= -PROP_REST_SINK_M && gap <= PAD_SKIRT_M + 0.005,
        `${row.id} ${row.prop} pad ${gap === null ? "has no visible ground under it" : gap > 0 ? `floats ${gap.toFixed(3)} m, past its skirt,` : `sinks ${(-gap).toFixed(3)} m into the visible ground`} at ${point.map((value) => value.toFixed(2)).join(", ")}`);
    }
  } else if (row.prop === "bike_rack" && params.hoops !== undefined) {
    // A row of bike-rack hoops rests at every hoop (along its local Z, centred)
    // and carries the row's rectangle as its footprint.
    invariant(Number.isInteger(params.hoops) && params.hoops > 1 && params.hoops <= BIKE_RACK_MAX_HOOPS
      && row.footprint_m?.z_m === streetFurnitureFootprint("bike_rack", params).z_m, `${row.id} bike rack hoops or footprint are invalid`);
    for (let index = 0; index < params.hoops; index += 1) {
      const offset = BIKE_RACK_HOOP_SPACING_M * (index - (params.hoops - 1) / 2);
      const point = [row.position_m[0] + Math.sin(row.yaw_radians) * offset, row.position_m[2] + Math.cos(row.yaw_radians) * offset];
      const ground = groundAt(point);
      rests(ground ? base - ground.y : null, `bike_rack hoop ${index}`, point);
    }
  } else if (row.layer === "furniture" || ANCHORED_CLUTTER.includes(row.prop)) {
    const point = [row.position_m[0], row.position_m[2]];
    const ground = groundAt(point);
    rests(ground ? base - ground.y : null, row.prop, point);
  } else if (isYardRow(row)) {
    validateYardRest(row, groundAt);
  } else {
    invariant(false, `${row.id} clutter prop ${row.prop} has no rest check: give it a branch in validatePropRest`);
  }
}

// A yard kit prop rests on the visible ground: no point of its plan (corners
// and a grid no coarser than 3 m) floats or sinks past the limits at its
// pitch, roll and lift. A barge floats instead: its prop collides with
// nothing and rests on no ground (yardPropRests).
function validateYardRest(row, groundAt) {
  if (!yardPropRests(row.prop)) return;
  const gaps = yardRestGaps(row.footprint_m, [row.position_m[0], row.position_m[2]], row.yaw_radians, row.position_m[1] + (row.surface?.bias_m ?? 0), row.prop_params, groundAt);
  const sink = yardMaxSink(row.prop, row.prop_params);
  const bad = gaps.filter((gap) => gap === null || gap > YARD_MAX_FLOAT_M + 0.005 || gap < -sink - 0.005);
  const known = gaps.filter((gap) => gap !== null);
  invariant(bad.length === 0, `${row.id} ${row.prop} does not rest on the ground: ${bad.length} of its ${gaps.length} rest points float more than ${YARD_MAX_FLOAT_M} m or sink more than ${sink} m `
    + `(${gaps.length - known.length} off the ground, highest ${Math.max(...known).toFixed(3)} m, lowest ${Math.min(...known).toFixed(3)} m)`);
}

// Structure and grounding only: the street-detail content changes as steps add it.
function validateStreetDetail(worldRoot, manifest, records) {
  invariant(manifest.street_detail?.path === "street_detail.json", "Manifest street-detail descriptor is missing");
  invariant(stableJson(descriptor(worldRoot, manifest.street_detail.path)) === stableJson(manifest.street_detail), "Street-detail descriptor drift");
  const document = unpackPlantingRows(JSON.parse(readFileSync(resolve(worldRoot, manifest.street_detail.path), "utf8")));
  invariant(document.schema_version === STREET_DETAIL_SCHEMA, "Street-detail schema drift");
  invariant(Number.isInteger(document.seed), "Street-detail seed is missing");
  invariant(stableJson(document.layers) === stableJson(STREET_DETAIL_LAYERS) && document.ground_layer === STREET_DETAIL_GROUND_LAYER, "Street-detail layer list drift");
  invariant(stableJson(document.kinds) === stableJson(STREET_DETAIL_KINDS), "Street-detail kind table differs from the generator");
  invariant(stableJson(document.prop_feet) === stableJson(STREET_FURNITURE_FEET), "Street-detail prop feet differ from the generator");
  const landByKey = new Map([...records.physical.values()]
    .filter(({ record }) => record.feature_kind === "land_ground")
    .map(({ record }) => [record.object_key, record]));
  // The boundary-attached context decks (a pier drawn beyond the playable
  // boundary): a deck rule's items and fence posts stand on their triangles.
  const deckByKey = new Map([...records.physical.values()]
    .filter(({ record }) => record.context_kind === "boundary_attached_visual")
    .map(({ record }) => [record.object_key, record]));
  // The visible ground of a context deck at a plan point ({y}), or null off it.
  const deckGround = (deck) => {
    const record = deckByKey.get(`boundary_context:${deck}`);
    return ([x, z]) => {
      for (let offset = 0; offset < record.indices.length; offset += 3) {
        const [a, b, c] = [0, 1, 2].map((corner) => record.vertices.slice(record.indices[offset + corner] * 3, record.indices[offset + corner] * 3 + 3));
        const denominator = (b[2] - c[2]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[2] - c[2]);
        if (Math.abs(denominator) <= 1e-10) continue;
        const wa = ((b[2] - c[2]) * (x - c[0]) + (c[0] - b[0]) * (z - c[2])) / denominator;
        const wb = ((c[2] - a[2]) * (x - c[0]) + (a[0] - c[0]) * (z - c[2])) / denominator;
        const wc = 1 - wa - wb;
        if (wa >= -1e-7 && wb >= -1e-7 && wc >= -1e-7) return { y: wa * a[1] + wb * b[1] + wc * c[1] };
      }
      return null;
    };
  };
  // On its land triangle, or with deck (an OSM key) on that deck's triangle.
  const grounded = (id, x, y, z, objectKey, triangleIndex, deck = null) => {
    const support = deck === null ? landByKey.get(objectKey) : objectKey === `boundary_context:${deck}` ? deckByKey.get(objectKey) : undefined;
    const what = deck === null ? "land" : `deck ${deck}`;
    invariant(support && Number.isInteger(triangleIndex) && triangleIndex >= 0 && triangleIndex * 3 + 2 < support.indices.length, `${id} has no serialized ${what} support`);
    const sample = facetSample(landFacet(support, triangleIndex * 3, objectKey), x, -z);
    invariant(sample.inside && Math.abs(sample.elevation - y) <= COORDINATE_ROUNDING_M + 1e-9, `${id} is not grounded on its ${what} triangle`);
  };
  const inBoundary = (x, z) => pointInPlayableBoundary([x, z], manifest.playable_boundary);
  const groundAt = visibleGroundIndex(chunksOf(records));
  const zoneIds = new Set(document.zones.map((zone) => zone.id));
  const rows = document.rows;
  invariant(Array.isArray(rows), "Street-detail rows are missing");
  const ids = rows.map((row) => row.id);
  invariant(new Set(ids).size === ids.length, "Street-detail row ids are not unique");
  invariant(ids.every((id, index) => index === 0 || ids[index - 1] < id), "Street-detail rows are not in code-point id order");
  for (const row of rows) {
    const kind = STREET_DETAIL_KINDS[row.kind];
    invariant(kind && row.layer === kind.layer && row.geometry === kind.geometry, `${row.id} kind/layer/geometry mismatch`);
    invariant(STREET_DETAIL_SOURCES.includes(row.source) && row.id.startsWith(`${row.source}:`) && typeof row.source_id === "string" && row.source_id !== "", `${row.id} source identity is invalid`);
    if (row.source === "osm") invariant(row.id === `osm:${row.source_id}` && /^[nw]\d+$/u.test(row.source_id), `${row.id} OSM identity is invalid`);
    invariant(row.status === "placed" ? row.exclusion === null : row.status === "excluded" && typeof row.exclusion?.reason === "string", `${row.id} status/exclusion mismatch`);
    invariant(Array.isArray(row.zones) && row.zones.every((zone) => zoneIds.has(zone)), `${row.id} names an unknown zone`);
    if (row.geometry === "point") {
      const [x, y, z] = row.position_m;
      if (isMooredRow(row)) {
        // A moored vessel (yard pattern moored): on the water off the playable land, at the water plane, no land support.
        invariant(row.position_m.length === 3 && [x, y, z].every(Number.isFinite) && !inBoundary(x, z) && y === WATER_Y_M, `${row.id} moored position is invalid or on the island`);
        invariant(row.terrain_support === null && row.surface.bias_m === 0 && MOORED_PROP_VARIANTS[row.prop]?.includes(row.prop_params?.variant), `${row.id} moored row is not a floating yard prop`);
      } else if (isDeckRow(row)) {
        // A deck item (a yard pack rule with a deck): a yard prop on its context deck, off the playable land.
        const deck = deckByKey.get(`boundary_context:${row.surface.source_key}`);
        invariant(row.position_m.length === 3 && [x, y, z].every(Number.isFinite) && !inBoundary(x, z), `${row.id} deck position is invalid or on the island`);
        invariant(isYardRow(row) && deck && row.surface.bias_m === 0 && row.surface.material_key === deck.material_key, `${row.id} deck row is not a yard prop on a context deck`);
        grounded(row.id, x, y, z, row.terrain_support?.object_key, row.terrain_support?.triangle_index, row.surface.source_key);
        invariant(row.terrain_support.elevation_m === y, `${row.id} terrain_support elevation differs from its position`);
      } else {
        invariant(row.position_m.length === 3 && [x, y, z].every(Number.isFinite) && inBoundary(x, z), `${row.id} position is invalid or off the island`);
        grounded(row.id, x, y, z, row.terrain_support?.object_key, row.terrain_support?.triangle_index);
        invariant(row.terrain_support.elevation_m === y, `${row.id} terrain_support elevation differs from its position`);
      }
      invariant(row.yaw_radians === null ? row.yaw_source === null : Number.isFinite(row.yaw_radians) && Math.abs(row.yaw_radians) <= Math.PI && typeof row.yaw_source === "string", `${row.id} yaw is invalid`);
      invariant(Number.isFinite(row.surface?.bias_m) && row.surface.bias_m >= 0 && typeof row.surface.material_key === "string", `${row.id} surface is invalid`);
      // A kit prop is built at runtime: a placed row of the kind its prop draws,
      // in the layer whose kit has it (furniture or clutter), or a planted
      // vegetation row (validatePlantedRow).
      if (row.prop !== undefined && row.layer === "vegetation") {
        validatePlantedRow(row, groundAt);
      } else if (row.prop !== undefined) {
        const props = row.layer === "furniture" ? STREET_FURNITURE_PROPS : row.layer === "clutter" ? STREET_CLUTTER_PROPS : {};
        invariant(props[row.prop] === row.kind && row.status === "placed", `${row.id} prop ${row.prop} does not match a placed ${row.kind} ${row.layer} row`);
        invariant(row.prop_params !== null && typeof row.prop_params === "object" && !Array.isArray(row.prop_params), `${row.id} prop_params must be an object`);
      }
      // A parked car: a known body, paint and finish, a small tilt, and its footprint.
      if (row.kind === "parked_car") {
        const params = row.prop_params ?? {};
        invariant(row.prop === "parked_car" && CAR_BODY_NAMES.includes(params.body) && CAR_PAINTS.includes(params.paint) && CAR_FINISHES.includes(params.finish)
          && ["body", "black"].includes(params.roof) && ["alloy", "dark"].includes(params.rims), `${row.id} car params are invalid`);
        invariant(["pitch", "roll", "lift"].every((key) => Number.isFinite(params[key]) && Math.abs(params[key]) < 0.25), `${row.id} car tilt is invalid`);
        invariant(Number.isFinite(params.twist) && Math.abs(params.twist) <= MAX_TWIST_M, `${row.id} car twist is invalid`);
        invariant(row.footprint_m !== undefined, `${row.id} parked car has no footprint`);
      }
      // A dumpster or a planter: a known paint (the car paints) and its rectangle.
      if (row.prop === "dumpster" || row.prop === "stock_tank_planter") {
        invariant(CAR_PAINTS.includes(row.prop_params?.paint) && row.footprint_m !== undefined, `${row.id} ${row.prop} needs a known paint and its footprint`);
        invariant(row.prop_params.lid === undefined || (row.prop === "dumpster" && (row.prop_params.lid === "body" || CAR_PAINTS.includes(row.prop_params.lid))), `${row.id} ${row.prop} lid must be body or a known paint`);
      }
      // A yard kit prop: usable params and its own rectangle as its footprint
      // (its rest on the ground: validatePropRest, below).
      if (row.layer === "clutter" && YARD_KIT_KEYS.includes(row.prop)) {
        const error = yardPropParamsError(row.prop, row.prop_params);
        invariant(error === null, `${row.id} ${row.prop} params are invalid: ${error}`);
        const plan = yardPropFootprint(row.prop, row.prop_params);
        invariant(row.footprint_m !== undefined && Math.abs(row.footprint_m.x_m - plan.x_m) <= 0.002 && Math.abs(row.footprint_m.z_m - plan.z_m) <= 0.002,
          `${row.id} footprint_m differs from its ${row.prop} plan ${plan.x_m} x ${plan.z_m}`);
      }
      // A furniture prop on legs: its rest on the ground under its feet, a small tilt and lift.
      if (row.layer === "furniture" && row.prop !== undefined && STREET_FURNITURE_FEET[row.prop] !== undefined) {
        const params = row.prop_params ?? {};
        invariant(["pitch", "roll", "lift"].every((key) => Number.isFinite(params[key])) && restTilt(params.pitch, params.roll) <= MAX_REST_TILT_RAD
          && Math.abs(params.lift) < 0.25, `${row.id} rest on its feet is invalid`);
        invariant(params.leg_drops_m === undefined || (Array.isArray(params.leg_drops_m) && params.leg_drops_m.length === STREET_FURNITURE_FEET[row.prop].length
          && params.leg_drops_m.every((drop) => Number.isFinite(drop) && Math.abs(drop) <= MAX_LEG_DROP_M)), `${row.id} leg drops are invalid`);
      }
      if (row.footprint_m !== undefined) {
        invariant(Number.isFinite(row.footprint_m.x_m) && row.footprint_m.x_m > 0 && Number.isFinite(row.footprint_m.z_m) && row.footprint_m.z_m > 0 && Number.isFinite(row.yaw_radians), `${row.id} footprint is invalid`);
      }
      // A deck row rests on its context deck rather than the land.
      if (row.status === "placed" && row.prop !== undefined && (row.layer === "furniture" || row.layer === "clutter")) validatePropRest(row, isDeckRow(row) ? deckGround(row.surface.source_key) : groundAt);
    } else {
      const points = row.points_m;
      invariant(Array.isArray(points) && points.length >= 2 && row.terrain_supports?.length === points.length && row.vertex_source_ids?.length === points.length, `${row.id} polyline arrays are inconsistent`);
      // A rule fence on a context deck stands on the deck, off the playable land.
      const deck = row.fence?.deck ?? null;
      invariant(deck === null || (row.source === "scatter" && deckByKey.has(`boundary_context:${deck}`)), `${row.id} names no context deck ${deck}`);
      points.forEach((point, index) => {
        invariant(point.length === 3 && point.every(Number.isFinite) && (deck !== null || inBoundary(point[0], point[2])), `${row.id} vertex ${index} is invalid or off the island`);
        grounded(`${row.id} vertex ${index}`, point[0], point[1], point[2], row.terrain_supports[index][0], row.terrain_supports[index][1], deck);
      });
      invariant((row.kind === "fence") === (row.fence !== undefined), `${row.id}: every fence row, and only a fence row, carries a fence block`);
      if (row.fence !== undefined) validateFenceRow(row, grounded, inBoundary, groundAt);
    }
  }
  // The power lines' wires: a power_wires row is a placed power line whose pole
  // list names, in order along it, placed utility poles (null where a vertex
  // has none), with at least one span of two built poles side by side.
  const utilityPoles = new Set(rows.filter((row) => row.prop === "utility_pole" && row.status === "placed").map((row) => row.id));
  for (const row of rows.filter((candidate) => candidate.prop === "power_wires")) {
    const poles = row.prop_params?.poles;
    invariant(row.kind === "power_line" && row.layer === "furniture" && row.status === "placed" && Array.isArray(poles) && poles.every((id) => id === null || utilityPoles.has(id)),
      `${row.id} power_wires must list placed utility poles`);
    invariant(poles.some((id, index) => index > 0 && id !== null && poles[index - 1] !== null), `${row.id} power_wires has no span between two built poles`);
  }
  // A photographed pole's spur: its wires_to names other placed utility poles,
  // each at most MAX_SPUR_M away.
  const rowById = new Map(rows.map((row) => [row.id, row]));
  for (const row of rows.filter((candidate) => candidate.prop === "utility_pole" && candidate.prop_params?.wires_to !== undefined)) {
    const targets = row.prop_params.wires_to;
    invariant(row.source === "set_piece" && Array.isArray(targets) && targets.length > 0 && targets.every((id) => id !== row.id && utilityPoles.has(id)
      && Math.hypot(rowById.get(id).position_m[0] - row.position_m[0], rowById.get(id).position_m[2] - row.position_m[2]) <= MAX_SPUR_M),
    `${row.id} wires_to must name other placed utility poles within ${MAX_SPUR_M} m`);
  }
  const builtFences = new Set(rows.filter((row) => row.fence && row.prop !== undefined).map((row) => row.id));
  invariant(Array.isArray(document.fenced_approaches) && document.fenced_approaches.every((entry) =>
    typeof entry.source_key === "string" && ["north", "south", "west", "east"].includes(entry.side) && entry.fence_ids.every((id) => builtFences.has(id))), "Street-detail fenced approaches must name built fence rows");
  const tally = (field, values) => Object.fromEntries(values.map((value) => [value, rows.filter((row) => row[field] === value).length]));
  const layerNames = [...STREET_DETAIL_LAYERS, STREET_DETAIL_GROUND_LAYER];
  invariant(document.counts.total === rows.length, "Street-detail total count differs from its rows");
  invariant(stableJson(document.counts.by_layer) === stableJson(tally("layer", layerNames)), "Street-detail layer counts differ from its rows");
  const placedByLayer = Object.fromEntries(layerNames.map((layer) => [layer, rows.filter((row) => row.status === "placed" && row.layer === layer).length]));
  invariant(stableJson(document.counts.placed_by_layer) === stableJson(placedByLayer), "Street-detail placed-layer counts differ from its rows");
  invariant(stableJson(document.counts.by_source) === stableJson(tally("source", STREET_DETAIL_SOURCES)), "Street-detail source counts differ from its rows");
  invariant(stableJson(document.counts.by_status) === stableJson(tally("status", ["excluded", "placed"])), "Street-detail status counts differ from its rows");
  return document;
}

// A fence row: its kit type, openings along the line and solid runs of grounded
// posts. A built row (with a prop) is placed and its prop is its type.
function validateFenceRow(row, grounded, inBoundary, groundAt) {
  const fence = row.fence;
  // A fence on a context deck: every post on the deck's triangles, wherever the playable land ends.
  const deck = fence.deck ?? null;
  const spec = STREET_FENCE_TYPES[fence.type];
  invariant(spec && fence.height_m === fenceHeight(fence.type, fence.params) && fence.half_thickness_m === spec.half_thickness_m && typeof fence.type_basis === "string", `${row.id} fence type is invalid`);
  invariant(STREET_FENCE_INSIDE.includes(fence.params?.inside) && (fence.type !== "chain_link_screened" || row.source === "osm" || fenceParamsError(fence.type, fence.params) === null)
    && (fence.type !== "chain_link_slatted" || fenceParamsError(fence.type, fence.params) === null), `${row.id} fence params are invalid`);
  // Open gate leaves: a style, optionally a hinge side, the two grounded ends
  // of their opening, and the leaves' plan segments as the fence kit draws
  // and collides them (the clearance checks read them).
  if (fence.gates !== undefined) {
    invariant(STREET_FENCE_GATED_TYPES.includes(fence.type) && Array.isArray(fence.gates), `${row.id} a ${fence.type} fence carries no gates`);
    fence.gates.forEach((gate, index) => {
      invariant(STREET_FENCE_GATE_STYLES.includes(gate.style) && (gate.hinge === undefined || STREET_FENCE_GATE_HINGES.includes(gate.hinge))
        && gate.points_m?.length === 2 && gate.terrain_supports?.length === 2 && gate.surface_bias_m?.length === 2, `${row.id} gate ${index} is invalid`);
      gate.points_m.forEach((point, end) => grounded(`${row.id} gate ${index} end ${end}`, point[0], point[1], point[2], gate.terrain_supports[end][0], gate.terrain_supports[end][1], deck));
      const expected = gateLeaves(gate.points_m.map((point) => [point[0], point[2]]), gate.style, gate.hinge, fence.params.inside);
      invariant(stableJson(gate.leaves) === stableJson(expected), `${row.id} gate ${index} leaves differ from its ends, style and hinge`);
      // A leaf hangs level from its post: the ground under it, to its tip,
      // stays below its bottom rail (where it rises from the post, the gate
      // needs its other hinge or style).
      expected.forEach((leaf, side) => {
        const rail = gate.points_m[leaf.post][1] + gate.surface_bias_m[leaf.post] + GATE_LEAF_LIFT_M;
        for (let step = 0; step <= 8; step += 1) {
          const t = step / 8;
          const ground = groundAt([leaf.xz[0][0] + (leaf.xz[1][0] - leaf.xz[0][0]) * t, leaf.xz[0][1] + (leaf.xz[1][1] - leaf.xz[0][1]) * t]);
          invariant(!ground || ground.y <= rail + 0.005, `${row.id} gate ${index} leaf ${side} meets ground rising ${(ground?.y - rail).toFixed(3)} m into its bottom rail ${(t * 100).toFixed(0)}% of the way to its tip`);
        }
      });
    });
  }
  // Banners: a white sheet between two grounded ends on a solid run, lower than the fence.
  if (fence.banners !== undefined) {
    invariant(STREET_FENCE_BANNER_TYPES.includes(fence.type) && Array.isArray(fence.banners) && fence.banners.length > 0, `${row.id} a ${fence.type} fence carries no banners`);
    fence.banners.forEach((banner, index) => {
      invariant(Number.isFinite(banner.height_m) && banner.height_m >= 0.3 && banner.height_m <= fence.height_m - 0.2 && banner.to_m > banner.from_m
        && banner.points_m?.length === 2 && banner.terrain_supports?.length === 2 && banner.surface_bias_m?.length === 2, `${row.id} banner ${index} is invalid`);
      banner.points_m.forEach((point, end) => grounded(`${row.id} banner ${index} end ${end}`, point[0], point[1], point[2], banner.terrain_supports[end][0], banner.terrain_supports[end][1], deck));
    });
  }
  invariant(Number.isFinite(fence.length_m) && fence.length_m > 0, `${row.id} fence length is invalid`);
  let previous = 0;
  for (const opening of fence.openings) {
    invariant(Number.isFinite(opening.from_m) && Number.isFinite(opening.to_m) && opening.from_m >= previous && opening.to_m > opening.from_m && opening.to_m <= fence.length_m + 1e-6, `${row.id} fence openings are not ordered stretches of the line`);
    invariant(typeof opening.reason === "string" && opening.reason !== "" && Array.isArray(opening.source_ids), `${row.id} fence opening is unnamed`);
    previous = opening.to_m;
  }
  invariant(row.status === (fence.runs.length > 0 || (fence.gates?.length ?? 0) > 0 ? "placed" : "excluded"), `${row.id} status does not match its fence runs and gates`);
  fence.runs.forEach((run, runIndex) => {
    invariant(Array.isArray(run.points_m) && run.points_m.length >= 2 && run.terrain_supports?.length === run.points_m.length && run.surface_bias_m?.length === run.points_m.length, `${row.id} run ${runIndex} arrays are inconsistent`);
    run.points_m.forEach((point, index) => {
      const label = `${row.id} run ${runIndex} post ${index}`;
      invariant(point.length === 3 && point.every(Number.isFinite) && (deck !== null || inBoundary(point[0], point[2])), `${label} is invalid or off the island`);
      grounded(label, point[0], point[1], point[2], run.terrain_supports[index][0], run.terrain_supports[index][1], deck);
      invariant(Number.isFinite(run.surface_bias_m[index]) && run.surface_bias_m[index] >= 0, `${label} surface bias is invalid`);
      invariant(index === 0 || point[0] !== run.points_m[index - 1][0] || point[2] !== run.points_m[index - 1][2], `${label} repeats the post before it`);
    });
  });
  if (row.prop !== undefined) {
    invariant(row.prop === fence.type && row.status === "placed" && stableJson(row.prop_params) === stableJson(fence.params), `${row.id} fence prop does not match its placed fence`);
  }
}

// The shoreline: its riprap overlays are ordinary terrain overlays (checked
// with the other coherent surfaces). Here, on the unpacked document: the
// visual-only slope, shoulder and closure faces stay outside the exact island
// polygon (closure faces stand on it) and the slope reaches under the water;
// prototypes and their LOD index sets are valid meshes; every placement is a
// unit rotation with positive, and for a stone uniform, scale. Then each stone
// is placed and checked against the island the player walks on: cobbles lie
// wholly inside it and no higher than SHORELINE_COBBLE_MAX_TOP_M above the
// land (the player walks over them, with no collision); every other stone and
// log keeps SHORELINE_OUTSIDE_CLEARANCE_M clear of it on the water side, and
// one that lies under a walkable pier (the playable boundary's pier
// extensions) tops out at least 1 m below the land edge, under the deck.
function validateShoreline(worldRoot, manifest, records) {
  invariant(manifest.shoreline?.path === "shoreline.json", "Manifest shoreline descriptor is missing");
  invariant(stableJson(descriptor(worldRoot, manifest.shoreline.path)) === stableJson(manifest.shoreline), "Shoreline descriptor drift");
  const document = JSON.parse(readFileSync(resolve(worldRoot, manifest.shoreline.path), "utf8"));
  invariant(document.schema_version === SHORELINE_SCHEMA && document.visual_only === true, "Shoreline schema or visual-only contract drift");
  invariant(document.water_y_m === WATER_Y_M, "Shoreline water level drift");
  invariant(document.overlay?.material_key === SHORELINE_OVERLAY_MATERIAL, "Shoreline overlay material drift");
  // The exact island polygon in world x, z (z = -north).
  const island = geometryToMultiPolygon(
    JSON.parse(readFileSync(resolve(projectRoot, SOURCE_CONTRACT.extraction_polygon.path), "utf8")).features[0].geometry,
    "Treasure Island boundary",
  );
  // Island edges in an 8 m grid: distance queries near the shore stay cheap.
  const cell = 8;
  const edges = island.flatMap((polygon) => polygon.flatMap((ring) => ring.map((point, index) => [[point[0], -point[1]], [ring[(index + 1) % ring.length][0], -ring[(index + 1) % ring.length][1]]])));
  const grid = new Map();
  edges.forEach(([a, b], index) => {
    for (let x = Math.floor(Math.min(a[0], b[0]) / cell); x <= Math.floor(Math.max(a[0], b[0]) / cell); x += 1) {
      for (let z = Math.floor(Math.min(a[1], b[1]) / cell); z <= Math.floor(Math.max(a[1], b[1]) / cell); z += 1) {
        const key = `${x},${z}`;
        if (!grid.has(key)) grid.set(key, []);
        grid.get(key).push(index);
      }
    }
  });
  // Distance to the island edge, exact within one grid cell (Infinity beyond).
  const nearBoundary = (x, z) => {
    let best = Infinity;
    const cx = Math.floor(x / cell);
    const cz = Math.floor(z / cell);
    for (let dx = -1; dx <= 1; dx += 1) {
      for (let dz = -1; dz <= 1; dz += 1) {
        for (const index of grid.get(`${cx + dx},${cz + dz}`) ?? []) best = Math.min(best, pointToSegmentDistance2d([x, z], edges[index][0], edges[index][1]));
      }
    }
    return best;
  };
  const inside = (x, z) => pointInMultiPolygon([x, -z], island, false);
  const walkable = (x, z) => pointInPlayableBoundary([x, z], manifest.playable_boundary);
  invariant(Array.isArray(document.segments) && document.segments.length > 0 && Array.isArray(document.closures), "Shoreline segments or closures are missing");
  // The thinning the shader applies, and each segment's stone tone with the
  // joints at its ends that it blends across.
  const finiteArray = (value, size) => Array.isArray(value) && value.length === size && value.every(Number.isFinite);
  const lod = document.lod;
  invariant(lod && ["reach_per_m", "min_m", "max_m", "start"].every((key) => Number.isFinite(lod[key])) && lod.reach_per_m > 0 && lod.min_m > 0 && lod.max_m >= lod.min_m
    && lod.start > 0 && lod.start <= 1 && finiteArray(lod.underlay_fade_m, 2) && lod.underlay_fade_m[1] > lod.underlay_fade_m[0], "Shoreline thinning (lod) is malformed");
  for (const segment of document.segments) {
    const tone = segment.tone;
    invariant(tone && finiteArray(tone.stone, SHORELINE_TONE_LENGTH) && Number.isFinite(tone.blend_m) && tone.blend_m > 0
      && ["start", "end"].every((end) => tone[end] && finiteArray(tone[end].at, 2) && finiteArray(tone[end].along, 2) && finiteArray(tone[end].stone, SHORELINE_TONE_LENGTH)),
    `Shoreline segment ${segment.id} tone is malformed`);
  }
  // Every segment's source keeps its riprap overlay in the chunks.
  for (const segment of document.segments) {
    const overlays = [...records.physical.values()].filter(({ record }) => record.object_key.startsWith(`${SHORELINE_OVERLAY_PREFIX}:${segment.source_key}:`));
    invariant(overlays.length > 0, `Shoreline segment ${segment.id} has no riprap overlay`);
    for (const { record } of overlays) {
      invariant(
        record.feature_kind === "terrain_overlay" && record.material_key === SHORELINE_OVERLAY_MATERIAL && record.collision_kind === "none" &&
          record.surface_bias_m === document.overlay.bias_m && stableJson(record.source_keys) === stableJson([segment.source_key]),
        `${record.object_key} riprap overlay semantics drift`,
      );
    }
  }
  const pieces = new Set();
  for (const piece of [...document.segments, ...document.closures]) {
    invariant(typeof piece.id === "string" && !pieces.has(piece.id), `Shoreline piece ${piece.id} is not unique`);
    pieces.add(piece.id);
  }
  for (const closure of document.closures) invariant(SHORELINE_CLOSURE_KINDS.includes(closure.kind), `Shoreline closure ${closure.id} kind drift`);
  const keys = new Set();
  let minimumY = Infinity;
  // The slope, the shoulder strip (it carries the land's UVs, world x / 10 and
  // z / 10) and the closure faces.
  for (const record of document.records) {
    const kind = record.object_key.split(":")[0];
    invariant(SHORELINE_RECORD_MATERIALS[kind] !== undefined && !keys.has(record.object_key) && pieces.has(record.segment), `${record.object_key} is not a unique shoreline slope, shoulder or closure key of a known piece`);
    keys.add(record.object_key);
    invariant(record.material_key === SHORELINE_RECORD_MATERIALS[kind], `${record.object_key} material drift`);
    const mesh = unpackShorelineRecord(record);
    invariant((kind === "shoreline-verge") === Array.isArray(mesh.uvs), `${record.object_key} UVs drift`);
    validateMesh(kind === "shoreline-verge" ? mesh : { ...mesh, uvs: new Array((mesh.vertices.length / 3) * 2).fill(0) }, record.object_key);
    for (let index = 0; index < mesh.vertices.length; index += 3) {
      const [x, y, z] = [mesh.vertices[index], mesh.vertices[index + 1], mesh.vertices[index + 2]];
      invariant(!inside(x, z) || nearBoundary(x, z) <= 0.01, `${record.object_key} vertex ${index / 3} lies inside the island`);
      if (kind === "shoreline-slope") minimumY = Math.min(minimumY, y);
    }
  }
  invariant(minimumY < WATER_Y_M, "Shoreline slope never reaches under the water plane");
  const prototypes = new Map();
  for (const prototype of document.prototypes) {
    invariant(!prototypes.has(prototype.id) && SHORELINE_PROTOTYPE_KINDS.includes(prototype.kind) &&
      prototype.material_key === (prototype.kind === "boulder" ? SHORELINE_BOULDER_MATERIAL : SHORELINE_DRIFTWOOD_MATERIAL), `Shoreline prototype ${prototype.id} identity drift`);
    const uvs = new Array((prototype.vertices.length / 3) * 2).fill(0);
    validateMesh({ ...prototype, uvs }, `shoreline prototype ${prototype.id}`);
    let error = 0;
    for (const lod of prototype.lods) {
      invariant(Number.isFinite(lod.error_m) && lod.error_m > error, `Shoreline prototype ${prototype.id} LOD errors must grow`);
      error = lod.error_m;
      validateMesh({ ...prototype, uvs, indices: lod.indices }, `shoreline prototype ${prototype.id} LOD ${lod.error_m}`);
    }
    prototypes.set(prototype.id, prototype);
  }
  const segments = new Set(document.segments.map((segment) => segment.id));
  const landByChunk = new Map();
  for (const { record, chunk_id: chunkId } of records.physical.values()) {
    if (record.feature_kind !== "land_ground") continue;
    if (!landByChunk.has(chunkId)) landByChunk.set(chunkId, []);
    for (let offset = 0; offset < record.indices.length; offset += 3) landByChunk.get(chunkId).push(landFacet(record, offset, chunkId));
  }
  const landAt = (x, z) => {
    const chunkId = `x_${Math.floor(x / 256)}__z_${Math.floor(z / 256)}`;
    for (const facet of landByChunk.get(chunkId) ?? []) {
      const sample = facetSample(facet, x, -z);
      if (sample.inside) return sample.elevation;
    }
    return null;
  };
  // The land at the island edge nearest a point outside (sampled 5 cm inland).
  const edgeLandAt = (x, z) => {
    let best = null;
    for (const [a, b] of edges) {
      const dx = b[0] - a[0];
      const dz = b[1] - a[1];
      const t = Math.max(0, Math.min(1, ((x - a[0]) * dx + (z - a[1]) * dz) / (dx * dx + dz * dz)));
      const point = [a[0] + t * dx, a[1] + t * dz];
      const distance = Math.hypot(x - point[0], z - point[1]);
      if (!best || distance < best.distance) best = { distance, point };
    }
    const scale = 0.05 / Math.max(best.distance, 1e-9);
    return landAt(best.point[0] + (best.point[0] - x) * scale, best.point[1] + (best.point[1] - z) * scale);
  };
  const batchIds = new Set();
  let placements = 0;
  for (const batch of document.batches) {
    invariant(!batchIds.has(batch.id) && SHORELINE_BANDS.includes(batch.band) && prototypes.has(batch.prototype) && segments.has(batch.segment) &&
      Number.isInteger(batch.section) && batch.section >= 0 && typeof batch.cast_shadow === "boolean" &&
      Number.isFinite(batch.visibility_end_m) && Number.isFinite(batch.visibility_margin_m) && batch.visibility_margin_m > 0 && batch.visibility_end_m > batch.visibility_margin_m,
    `Shoreline batch ${batch.id} identity or visibility drift`);
    batchIds.add(batch.id);
    const prototype = prototypes.get(batch.prototype);
    invariant((batch.band === "driftwood") === (prototype.kind !== "boulder"), `Shoreline batch ${batch.id} puts ${prototype.kind} in ${batch.band}`);
    for (const placement of unpackShorelineBatch(batch, prototype.kind)) {
      invariant(placement.every(Number.isFinite), `Shoreline batch ${batch.id} has a malformed placement`);
      const [ox, oy, oz, qx, qy, qz, qw, sx, sy, sz] = placement;
      invariant(Math.abs(Math.hypot(qx, qy, qz, qw) - 1) <= 1e-9 && sx > 0 && sy > 0 && sz > 0, `Shoreline batch ${batch.id} has a placement that is not a scaled rotation`);
      // The stone shader turns normals by the model matrix alone: stones scale uniformly.
      invariant(prototype.kind !== "boulder" || (sx === sy && sy === sz), `Shoreline batch ${batch.id} scales a stone unevenly`);
      const columns = [
        [(1 - 2 * (qy * qy + qz * qz)) * sx, 2 * (qx * qy + qz * qw) * sx, 2 * (qx * qz - qy * qw) * sx],
        [2 * (qx * qy - qz * qw) * sy, (1 - 2 * (qx * qx + qz * qz)) * sy, 2 * (qy * qz + qx * qw) * sy],
        [2 * (qx * qz + qy * qw) * sz, 2 * (qy * qz - qx * qw) * sz, (1 - 2 * (qx * qx + qy * qy)) * sz],
      ];
      let top = -Infinity;
      let underPier = false;
      for (let index = 0; index < prototype.vertices.length; index += 3) {
        const [vx, vy, vz] = [prototype.vertices[index], prototype.vertices[index + 1], prototype.vertices[index + 2]];
        const x = ox + columns[0][0] * vx + columns[1][0] * vy + columns[2][0] * vz;
        const y = oy + columns[0][1] * vx + columns[1][1] * vy + columns[2][1] * vz;
        const z = oz + columns[0][2] * vx + columns[1][2] * vy + columns[2][2] * vz;
        top = Math.max(top, y);
        const distance = nearBoundary(x, z);
        if (batch.band === "cobble") {
          invariant(inside(x, z) && distance > 0.005, `Shoreline cobble in ${batch.id} at (${ox}, ${oz}) reaches the playable boundary`);
        } else {
          invariant(!inside(x, z) && distance >= SHORELINE_OUTSIDE_CLEARANCE_M - 0.005, `Shoreline ${batch.band} stone in ${batch.id} at (${ox}, ${oz}) comes within ${distance.toFixed(3)} m of the island edge`);
          underPier ||= walkable(x, z);
        }
      }
      if (batch.band === "cobble") {
        const land = landAt(ox, oz);
        invariant(land != null && top <= land + SHORELINE_COBBLE_MAX_TOP_M + 1e-6, `Shoreline cobble in ${batch.id} at (${ox}, ${oz}) rises ${(top - land).toFixed(3)} m above the land`);
      } else if (underPier) {
        const land = edgeLandAt(ox, oz);
        invariant(land != null && top <= land - 1.0, `Shoreline ${batch.band} stone in ${batch.id} at (${ox}, ${oz}) under a walkable pier reaches ${top.toFixed(3)} m, within 1 m of the land edge`);
      }
      placements += 1;
    }
  }
  return { document, placements };
}

// The top of a mesh's triangles over a plan point (0 where it has none).
function meshTop(mesh, cell = 0.5) {
  const bins = new Map();
  const triangles = [];
  for (let index = 0; index < mesh.indices.length; index += 3) {
    const corners = [0, 1, 2].map((k) => mesh.positions.slice(mesh.indices[index + k] * 3, mesh.indices[index + k] * 3 + 3));
    const [a, b, c] = corners;
    const det = (b[2] - c[2]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[2] - c[2]);
    if (Math.abs(det) < 1e-12) continue;
    triangles.push({ a, b, c, det });
    const xs = corners.map((corner) => corner[0]);
    const zs = corners.map((corner) => corner[2]);
    for (let i = Math.floor(Math.min(...xs) / cell); i <= Math.floor(Math.max(...xs) / cell); i += 1) {
      for (let j = Math.floor(Math.min(...zs) / cell); j <= Math.floor(Math.max(...zs) / cell); j += 1) {
        if (!bins.has(`${i},${j}`)) bins.set(`${i},${j}`, []);
        bins.get(`${i},${j}`).push(triangles.at(-1));
      }
    }
  }
  return (x, z) => {
    let top = 0;
    for (const { a, b, c, det } of bins.get(`${Math.floor(x / cell)},${Math.floor(z / cell)}`) ?? []) {
      const l1 = ((b[2] - c[2]) * (x - c[0]) + (c[0] - b[0]) * (z - c[2])) / det;
      const l2 = ((c[2] - a[2]) * (x - c[0]) + (a[0] - c[0]) * (z - c[2])) / det;
      if (l1 < -1e-9 || l2 < -1e-9 || 1 - l1 - l2 < -1e-9) continue;
      top = Math.max(top, l1 * a[1] + l2 * b[1] + (1 - l1 - l2) * c[1]);
    }
    return top;
  };
}

// How far a heap's floor may stand above its visible mesh, at the largest
// scale the heap takes.
const YARD_FLOOR_FLOAT_M = 0.3;

// The heaps the player walks on, each with the plan its floor keeps to (x0,
// x1, z0, z1, at scale 1), the largest scale it takes and the edges where a
// module meets the next (z values).
function yardHeaps() {
  const heaps = [];
  const pile = YARD_KIT_PROPS.material_pile;
  for (const variant of pile.variants) {
    if (variant.name === "ridge") continue;
    for (let shape = pile.params.shape.min; shape <= pile.params.shape.max; shape += 1) {
      heaps.push({ name: `pile_${variant.name}_${shape}`, x0: -variant.x_m / 2, x1: variant.x_m / 2, z0: -variant.z_m / 2, z1: variant.z_m / 2, scale: pile.params.scale.max, joints: [] });
    }
  }
  const modular = [
    ...YARD_KIT_PROPS.plastic_berm.variants.map((variant) => [`berm_${variant.name}`, variant.x_m, BERM_MODULE, BERM_SPECS[variant.name].cap_m]),
    ["ridge", pile.variants.find((variant) => variant.name === "ridge").x_m, RIDGE_MODULE, RIDGE_MODULE / 2],
  ];
  for (const [base, width, length, cap] of modular) {
    const [x0, x1] = [-width / 2, width / 2];
    heaps.push({ name: `${base}_mid`, base, x0, x1, z0: -length / 2, z1: length / 2, scale: 1, joints: [-length / 2, length / 2] });
    heaps.push({ name: `${base}_end_neg`, base, x0, x1, z0: -cap, z1: 0, scale: 1, joints: [0] });
    heaps.push({ name: `${base}_end_pos`, base, x0, x1, z0: 0, z1: cap, scale: 1, joints: [0] });
  }
  return heaps;
}

// The yard kit (tools/lib/street-yard-kit.mjs, -meshes.mjs): its shader and
// runtime keep one entry per kit part and name the parts they treat specially
// by their place in YARD_KIT_PARTS. Every heap collides as the floor the kit
// lays over its visible (near) mesh (<mesh>_floor), and the player walks on
// it: no triangle steeper than 45 degrees (the floor limit is 48); the near
// mesh at most 0.1 m above it (a foot beds into a loose chunk or tyre) and,
// on a 0.2 m grid, it at most YARD_FLOOR_FLOAT_M above the near mesh at the
// heap's largest scale; within the heap's plan and down to the ground at its
// edges, but where a module meets the next, along which the two floors are
// the same.
function validateYardKit() {
  const parts = YARD_KIT_PARTS;
  const shader = readFileSync(resolve(projectRoot, "game/resources/materials/world/street/street_yard.gdshader"), "utf8");
  const arrays = [...shader.matchAll(/const (int|float) ([A-Z]+)\[(\d+)\] = \1\[\3\]\(([^;]*)\);/gu)];
  invariant(arrays.length > 0, "The yard shader has no part arrays");
  for (const [, , name, size, values] of arrays) {
    invariant(Number(size) === parts.length && values.split(",").length === parts.length, `The yard shader's ${name} is not one entry per kit part (${parts.length})`);
  }
  invariant(Number(shader.match(/const int PART_COUNT = (\d+);/u)?.[1]) === parts.length, "The yard shader's PART_COUNT is not the kit's part count");
  for (const [, name, index] of shader.matchAll(/const int PART_([A-Z_]+) = (\d+);/gu)) {
    if (name !== "COUNT") invariant(parts[Number(index)] === name.toLowerCase(), `The yard shader's PART_${name} is part ${index}, ${parts[Number(index)]}`);
  }
  const kit = readFileSync(resolve(projectRoot, "game/scripts/world/street_yard_kit.gd"), "utf8");
  const colours = kit.slice(kit.indexOf("const PART_COLORS := ["), kit.indexOf("]", kit.indexOf("const PART_COLORS := [")));
  invariant((colours.match(/Color\(/gu) ?? []).length === parts.length, "The yard kit's PART_COLORS is not one colour per kit part");
  const meshes = new Map(yardKitMeshes().map((mesh) => [mesh.name, mesh]));
  const floors = new Map();
  for (const heap of yardHeaps()) {
    const [floor, near] = [meshes.get(`${heap.name}_floor`), meshes.get(`${heap.name}_lod0`)];
    invariant(floor && near, `The yard kit has no floor for ${heap.name}`);
    const label = `The yard kit's ${heap.name} floor`;
    for (let index = 0; index < floor.indices.length; index += 3) {
      const [a, b, c] = [0, 1, 2].map((corner) => floor.positions.slice(floor.indices[index + corner] * 3, floor.indices[index + corner] * 3 + 3));
      const u = [b[0] - a[0], b[1] - a[1], b[2] - a[2]];
      const v = [c[0] - a[0], c[1] - a[1], c[2] - a[2]];
      const normal = [u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0]];
      const tilt = Math.atan2(Math.hypot(normal[0], normal[2]), normal[1]);
      invariant(tilt <= (45.05 * Math.PI) / 180, `${label} has a triangle at ${((tilt * 180) / Math.PI).toFixed(2)} degrees near ${a.map((value) => value.toFixed(2)).join(", ")}`);
    }
    for (let index = 0; index < floor.positions.length; index += 3) {
      const [x, y, z] = floor.positions.slice(index, index + 3);
      invariant(x >= heap.x0 - 1e-6 && x <= heap.x1 + 1e-6 && z >= heap.z0 - 1e-6 && z <= heap.z1 + 1e-6, `${label} leaves its plan at ${x.toFixed(2)}, ${z.toFixed(2)}`);
      const edge = Math.abs(x - heap.x0) < 1e-6 || Math.abs(x - heap.x1) < 1e-6
        || ([heap.z0, heap.z1].some((end) => Math.abs(z - end) < 1e-6) && !heap.joints.some((joint) => Math.abs(z - joint) < 1e-6));
      invariant(!edge || y <= 0.02, `${label} ends ${y.toFixed(3)} m above the ground at ${x.toFixed(2)}, ${z.toFixed(2)}`);
    }
    const [floorTop, nearTop] = [meshTop(floor), meshTop(near)];
    // A foot may bed into a loose chunk or tyre: the near mesh stands at most
    // 0.1 m above the floor at scale 1, so 0.3 m at a pile's largest scale (3),
    // as far as the floor may stand above the near mesh.
    for (let index = 0; index < near.positions.length; index += 3) {
      const [x, y, z] = near.positions.slice(index, index + 3);
      const above = y - floorTop(x, z);
      invariant(above <= 0.1 + 1e-6, `${label} leaves its visible mesh ${above.toFixed(3)} m above it at ${x.toFixed(2)}, ${z.toFixed(2)}`);
    }
    for (let x = heap.x0 + 0.1; x < heap.x1; x += 0.2) {
      for (let z = heap.z0 + 0.1; z < heap.z1; z += 0.2) {
        const height = floorTop(x, z);
        if (height <= 0.005) continue;
        const float = (height - nearTop(x, z)) * heap.scale;
        invariant(float <= YARD_FLOOR_FLOAT_M + 1e-6, `${label} stands ${float.toFixed(3)} m above its visible mesh at ${x.toFixed(2)}, ${z.toFixed(2)} (scale ${heap.scale})`);
      }
    }
    floors.set(heap.name, { heap, top: floorTop });
  }
  // Where modules meet (a middle's end and an end's start, or two ends), their floors are the same.
  for (const { heap } of floors.values()) {
    if (!heap.name.endsWith("_mid")) continue;
    const pairs = [[`${heap.base}_mid`, heap.z1, `${heap.base}_end_pos`, 0], [`${heap.base}_end_neg`, 0, `${heap.base}_mid`, heap.z0], [`${heap.base}_end_neg`, 0, `${heap.base}_end_pos`, 0], [`${heap.base}_mid`, heap.z1, `${heap.base}_mid`, heap.z0]];
    for (const [first, firstZ, second, secondZ] of pairs) {
      for (let x = heap.x0; x <= heap.x1 + 1e-9; x += 0.05) {
        const step = floors.get(first).top(x, firstZ) - floors.get(second).top(x, secondZ);
        invariant(Math.abs(step) <= 0.005, `The yard kit's ${first} and ${second} floors meet ${step.toFixed(3)} m apart at x ${x.toFixed(2)}`);
      }
    }
  }
}

function validateManifest(worldRoot) {
  verifySourceContract(projectRoot);
  const manifestPath = resolve(worldRoot, "manifest.json");
  const manifestText = readFileSync(manifestPath, "utf8");
  invariant(!/generated_at|timestamp|\/Users\//u.test(manifestText), "Manifest contains a timestamp or absolute user path");
  const manifest = JSON.parse(manifestText);
  invariant(manifest.schema_version === WORLD_SCHEMA, `Unexpected world schema ${manifest.schema_version}`);
  invariant(manifest.coordinate_system?.world_axes === "+X east,+Y up,-Z north", "World-axis contract drift");
  invariant(manifest.coordinate_system?.coordinate_rounding_m === 0.001, "Coordinate-rounding contract drift");
  invariant(manifest.coordinate_system?.ground_model === "USGS 3DEP bare-earth terrain", "Terrain ground model drift");
  invariant(manifest.coordinate_system?.vertical_datum === "NAVD 88", "Terrain vertical datum drift");
  invariant(manifest.boundary_source_key === PLAYABLE_BOUNDARY_SOURCE_KEY, "Boundary source key drift");
  invariant(manifest.chunk_size_m === 256, "Chunk size drift");
  invariant(manifest.counts.source_rows === 739 && manifest.counts.playable_rows === 735 && manifest.counts.context_rows === 4, "Manifest denominator drift");
  invariant(manifest.counts.unresolved_rows === 0 && manifest.counts.duplicate_source_keys === 0, "Manifest error counts are non-zero");
  invariant(Array.isArray(manifest.playable_boundary.components) && manifest.playable_boundary.components.length > 0, "Manifest boundary missing");
  invariant(Array.isArray(manifest.initial_spawn.origin) && manifest.initial_spawn.origin.length === 3, "Manifest spawn missing");
  invariant(
    stableJson(manifest.initial_spawn) === stableJson(EXPECTED_FERRY_SPAWN),
    "Manifest ferry spawn transform drift",
  );
  invariant(manifest.feature_kinds.every((kind) => FEATURE_KINDS.includes(kind)), "Manifest feature kinds drift");

  const actualPaths = listFiles(worldRoot).filter((path) => path !== "manifest.json");
  const listedPaths = manifest.files.map((file) => file.path);
  invariant(stableJson(actualPaths) === stableJson(listedPaths), "Manifest file list does not exactly match output tree");
  const actualDescriptors = actualPaths.map((path) => descriptor(worldRoot, path));
  invariant(stableJson(actualDescriptors) === stableJson(manifest.files), "Manifest file hashes or byte counts drift");
  invariant(contentIndexSha256(actualDescriptors) === manifest.content_sha256, "Manifest content index hash drift");
  invariant(stableJson(descriptor(worldRoot, manifest.coverage_ledger.path)) === stableJson(manifest.coverage_ledger), "Coverage descriptor drift");
  invariant(stableJson(descriptor(worldRoot, manifest.context.path)) === stableJson(manifest.context), "Context descriptor drift");
  for (const source of Object.values(manifest.sources)) {
    invariant(!source.path.startsWith("/"), `Absolute source path in manifest: ${source.path}`);
    const expected = Object.values(SOURCE_CONTRACT).find((contract) => contract.path === source.path);
    invariant(expected && source.sha256 === expected.sha256, `Unknown or drifted manifest source ${source.path}`);
  }
  return manifest;
}

function main() {
  const worldRoot = resolve(projectRoot, process.argv[2] ?? "generated/world");
  const manifest = validateManifest(worldRoot);
  const coverage = validateCoverage(worldRoot, manifest);
  const terrain = validateTerrain(worldRoot, manifest);
  const records = validateRecords(worldRoot, manifest, coverage);
  const coherentGeometry = validateCoherentGeometry(records, terrain);
  validateDrapedLayers(records);
  const pavement = validatePavementSkin(worldRoot, manifest, coverage, records, terrain);
  const land = validateLandProvenance(records, terrain);
  const streetDetail = validateStreetDetail(worldRoot, manifest, records);
  const shoreline = validateShoreline(worldRoot, manifest, records);
  validateYardKit();
  process.stdout.write(stableJson({
    status: "valid",
    world: relative(projectRoot, worldRoot).replaceAll("\\", "/"),
    content_sha256: manifest.content_sha256,
    source_rows: coverage.rows.length,
    chunks: manifest.chunks.length,
    physical_objects: records.physical.size,
    terrain_valid_samples: terrain.statistics.valid_sample_count,
    terrain_elevation_range_m: [terrain.statistics.minimum_elevation_m, terrain.statistics.maximum_elevation_m],
    coherent_surface_samples: coherentGeometry.surfaceSamples,
    foundation_samples: coherentGeometry.foundationSamples,
    flat_roof_cells: coherentGeometry.roofCells,
    street_ground_samples: coherentGeometry.streetGroundSamples,
    pavement,
    land,
    street_detail_rows: streetDetail.counts.total,
    shoreline_placements: shoreline.placements,
  }));
}

main();
