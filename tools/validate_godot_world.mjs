#!/usr/bin/env node

import { createHash } from "node:crypto";
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  BRIDGE_SOURCE_KEYS,
  BOUNDARY_ATTACHED_SOURCE_KEYS,
  CATEGORY_MEMBERSHIPS,
  CHUNK_SCHEMA,
  COORDINATE_ROUNDING_M,
  CONTEXT_SCHEMA,
  COVERAGE_HEADERS,
  EXPECTED_COUNTS,
  FEATURE_KINDS,
  ISLE_HOUSE_PARENT_KEY,
  ISLE_HOUSE_PART_KEYS,
  MATERIAL_KEYS,
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
  NAIP_TREE_ANNOTATION_SCHEMA,
  NAIP_TREE_ANNOTATION_SHA256,
  NAIP_UNKNOWN_CLEARANCES_M,
  NAIP_UNKNOWN_SHRUB_ZONE_ID,
  VEGETATION_ASSETS,
  VEGETATION_ASSET_ROOT,
  VEGETATION_CLEARANCES_M,
  VEGETATION_QA_CORRIDORS,
  VEGETATION_SCHEMA,
  VEGETATION_SEED,
  naipUnknownShrubVariation,
} from "./lib/vegetation-generation.mjs";

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
const NAIP_TREE_ANNOTATIONS_PATH = resolve(
  projectRoot,
  "source_assets/vegetation/naip_2022/tree_annotations_candidate.geojson",
);
const EXPECTED_PHYSICAL_COLLISION_SHA256 = "3c5571828de1498622fbcf074a0f3ec03790b14ad36160c9302652421c345296";

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
  invariant(rows.every((row) => ["represented", "composite_member", "context"].includes(row.derived_world_status)), "Coverage has an invalid status");
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
  invariant(
    Array.isArray(context.boundary_attached_visuals) && context.boundary_attached_visuals.length === 2,
    "Context must contain exactly two boundary-attached visuals",
  );
  for (const record of context.boundary_attached_visuals) {
    invariant(record.context_kind === "boundary_attached_visual", `${record.object_key} boundary context kind drift`);
    invariant(record.source_keys.length === 1 && BOUNDARY_ATTACHED_SOURCE_KEYS.includes(record.source_keys[0]), `${record.object_key} invalid boundary-attached source`);
    invariant(record.object_key === `boundary_context:${record.source_keys[0]}`, `${record.object_key} boundary context object key drift`);
    invariant(record.collision_kind === "none" && record.receiver_kind === "none" && record.opaque === false, `${record.object_key} boundary context semantics leak`);
    validateMesh(record, record.object_key);
    invariant(!physical.has(record.object_key), `Duplicate boundary context key ${record.object_key}`);
    physical.set(record.object_key, { record, chunk_id: null });
  }

  for (const row of coverage.rows) {
    const partKeys = splitValues(row.part_keys);
    invariant(partKeys.length > 0, `${row.source_key} has no part keys`);
    for (const key of partKeys) invariant(physical.has(key), `${row.source_key} references missing physical ${key}`);
    for (const chunkId of splitValues(row.chunk_ids)) {
      invariant(chunkIds.includes(chunkId), `${row.source_key} references missing chunk ${chunkId}`);
      invariant(partKeys.some((key) => physical.get(key)?.chunk_id === chunkId), `${row.source_key}/${chunkId} has no matching physical part`);
    }
  }
  for (const { record } of physical.values()) {
    invariant(Array.isArray(record.source_keys) && record.source_keys.length > 0, `${record.object_key} has no source keys`);
    for (const sourceKey of record.source_keys) invariant(coverage.byKey.has(sourceKey), `${record.object_key} references unknown source ${sourceKey}`);
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

  for (const { record, chunk_id: chunkId } of records.physical.values()) {
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
  return { surfaceSamples, maximumBiasDeviation, exteriorSegments, foundationSamples, waterSupportedSegments, roofCells };
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

function pointToRecordsDistance(point, records) {
  return Math.min(...records.map((record) => pointToRecordDistance(point, record)));
}

function pointToLineDistance(point, line) {
  let minimum = Infinity;
  for (let index = 1; index < line.length; index += 1) {
    minimum = Math.min(minimum, pointToSegmentDistance2d(point, line[index - 1], line[index]));
  }
  return minimum;
}

function pointToBoundaryDistance(point, boundary) {
  let minimum = Infinity;
  for (const component of boundary.components) {
    for (const ring of [component.outer, ...component.holes]) {
      for (let index = 0; index < ring.length; index += 1) {
        minimum = Math.min(minimum, pointToSegmentDistance2d(point, ring[index], ring[(index + 1) % ring.length]));
      }
    }
  }
  return minimum;
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
  for (const row of sourceRoads) {
    const highway = JSON.parse(row.tags_json).highway;
    const matches = Object.entries(ROAD_VISUAL_CLASSES)
      .filter(([, values]) => values.includes(highway))
      .map(([visualClass]) => visualClass);
    invariant(matches.length === 1, `${row.source_key} has ${matches.length} pavement classes in independent validation`);
    expectedByClass[matches[0]].add(row.source_key);
  }
  invariant(
    expectedByClass.vehicle.size === 208 && expectedByClass.pedestrian.size === 219 && parkingSourceKeys.size === 17,
    "Independent OSM pavement classification counts drift",
  );

  const roadEntries = [...records.physical.values()].filter(({ record }) => record.feature_kind === "road_path");
  const baseEntries = roadEntries.filter(({ record }) => record.material_key === "road_path");
  const pedestrianEntries = roadEntries.filter(({ record }) => record.material_key === "road_path_pedestrian");
  invariant(
    baseEntries.length === audit.topology.base_record_count &&
      pedestrianEntries.length === audit.topology.pedestrian_record_count &&
      roadEntries.length === baseEntries.length + pedestrianEntries.length,
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

  const collisionPayload = [...records.physical.values()]
    .map(({ record }) => record)
    .filter((record) => record.collision_kind === "world_solid")
    .sort((left, right) => left.object_key.localeCompare(right.object_key))
    .map((record) => ({
      object_key: record.object_key,
      feature_kind: record.feature_kind,
      vertices: record.vertices,
      indices: record.indices,
    }));
  const collisionSha256 = createHash("sha256").update(stableJson(collisionPayload)).digest("hex");
  invariant(collisionSha256 === EXPECTED_PHYSICAL_COLLISION_SHA256, "Visual pavement pass changed physical collision geometry");
  return {
    base_records: baseEntries.length,
    pedestrian_records: pedestrianEntries.length,
    visible_pedestrian_sources: visiblePedestrianSourceKeys.size,
    collision_sha256: collisionSha256,
    relative_luminance_difference: audit.materials.pedestrian_vs_vehicle_relative_luminance_difference,
  };
}

function validateGlbAsset(resourcePath) {
  invariant(resourcePath.startsWith(VEGETATION_ASSET_ROOT) && resourcePath.endsWith(".glb"), `Unsafe vegetation asset path ${resourcePath}`);
  const relativePath = resourcePath.slice("res://".length);
  const absolutePath = resolve(projectRoot, relativePath);
  invariant(absolutePath.startsWith(resolve(projectRoot, "game/resources/models/vegetation/kenney_nature_kit") + "/"), `Vegetation asset escapes curated root: ${resourcePath}`);
  invariant(existsSync(absolutePath), `Vegetation asset is missing: ${resourcePath}`);
  const bytes = readFileSync(absolutePath);
  invariant(bytes.length >= 20 && bytes.toString("ascii", 0, 4) === "glTF", `${resourcePath} is not a binary glTF`);
  invariant(bytes.readUInt32LE(4) === 2 && bytes.readUInt32LE(8) === bytes.length, `${resourcePath} GLB version/length drift`);
  const jsonLength = bytes.readUInt32LE(12);
  invariant(bytes.toString("ascii", 16, 20) === "JSON", `${resourcePath} first GLB chunk is not JSON`);
  const gltf = JSON.parse(bytes.subarray(20, 20 + jsonLength).toString("utf8").replace(/[\u0000 ]+$/u, ""));
  invariant(gltf.asset?.version === "2.0" && gltf.scenes?.length === 1 && gltf.meshes?.length > 0, `${resourcePath} glTF scene/mesh contract drift`);
  invariant((gltf.buffers ?? []).every((buffer) => buffer.uri == null), `${resourcePath} references an external buffer`);
  invariant((gltf.images ?? []).every((image) => image.uri == null), `${resourcePath} references an external image`);
}

function validateVegetation(worldRoot, manifest, records) {
  invariant(manifest.vegetation?.path === "vegetation.json", "Manifest vegetation descriptor is missing");
  invariant(stableJson(descriptor(worldRoot, manifest.vegetation.path)) === stableJson(manifest.vegetation), "Vegetation descriptor drift");
  const vegetation = JSON.parse(readFileSync(resolve(worldRoot, manifest.vegetation.path), "utf8"));
  invariant(vegetation.schema_version === VEGETATION_SCHEMA, "Vegetation schema drift");
  invariant(vegetation.seed === VEGETATION_SEED && vegetation.visual_only === true, "Vegetation seed or visual-only contract drift");
  invariant(vegetation.asset_root === VEGETATION_ASSET_ROOT, "Vegetation asset root drift");
  invariant(stableJson(vegetation.assets) === stableJson(VEGETATION_ASSETS), "Vegetation allowed asset palette drift");
  invariant(stableJson(vegetation.clearances_m) === stableJson(VEGETATION_CLEARANCES_M), "Vegetation clearance contract drift");
  invariant(sha256File(NAIP_TREE_ANNOTATIONS_PATH) === NAIP_TREE_ANNOTATION_SHA256, "Pinned NAIP tree annotation source hash drift");
  const annotationDocument = JSON.parse(readFileSync(NAIP_TREE_ANNOTATIONS_PATH, "utf8"));
  invariant(annotationDocument.type === "FeatureCollection" && annotationDocument.schema === NAIP_TREE_ANNOTATION_SCHEMA,
    "NAIP tree annotation source schema drift");
  const unknownAnnotations = annotationDocument.features.filter((feature) => feature.properties?.tree_type === "unknown");
  invariant(unknownAnnotations.length === 22, "Expected exactly 22 accepted NAIP unknown annotations");
  const unknownAnnotationsById = new Map(unknownAnnotations.map((feature) => [feature.id, feature]));
  for (const asset of vegetation.assets) validateGlbAsset(asset.path);
  const placements = vegetation.placements;
  invariant(Array.isArray(placements) && placements.length === 124 && vegetation.counts.total === placements.length, "Expected the pinned 124-placement vegetation pass");
  invariant(stableJson(placements.map((placement) => placement.id)) === stableJson(placements.map((placement) => placement.id).sort()), "Vegetation placements are not canonically ordered");
  invariant(new Set(placements.map((placement) => placement.id)).size === placements.length, "Vegetation placement IDs are not unique");
  invariant(stableJson(vegetation.counts.by_species) === stableJson({ broadleaf: 28, conifer: 21, ornamental_grass: 21, palm: 13, shrub: 41 }), "Vegetation species palette/density drift");
  invariant(stableJson(vegetation.counts.by_zone) === stableJson({
    central_conifer_groves: 21,
    legacy_grid_broadleaf: 20,
    naip_unknown_shrubs: 22,
    north_west_lawn_broadleaf: 8,
    south_ornamental_beds: 34,
    south_palm_rows: 13,
    south_shrub_groups: 6,
  }), "Vegetation zone density drift");
  invariant(Object.values(vegetation.counts.by_asset).every((count) => count > 0), "Every curated vegetation GLB must be exercised");
  const assetSpecies = new Map(VEGETATION_ASSETS.map((asset) => [asset.path, asset.species]));
  const landByKey = new Map([...records.physical.values()]
    .filter(({ record }) => record.feature_kind === "land_ground")
    .map(({ record }) => [record.object_key, record]));
  const roadRecords = [...records.physical.values()].map(({ record }) => record)
    .filter((record) => record.feature_kind === "road_path");
  const buildingRecords = [...records.physical.values()].map(({ record }) => record)
    .filter((record) => ["building_roof", "building_part_roof"].includes(record.feature_kind));
  const shorelineOverlayRecords = [...records.physical.values()].map(({ record }) => record)
    .filter((record) => record.feature_kind === "terrain_overlay");
  const observed = Object.fromEntries(Object.keys(VEGETATION_CLEARANCES_M).map((key) => [key, Infinity]));
  const unknownObserved = Object.fromEntries(Object.keys(NAIP_UNKNOWN_CLEARANCES_M).map((key) => [key, Infinity]));
  const seenUnknownAnnotationIds = new Set();
  const expectedProceduralBufferExceptions = [];
  for (const placement of placements) {
    invariant(/^vegetation:[a-z0-9_]+:/u.test(placement.id), `${placement.id} is not a canonical vegetation ID`);
    invariant(assetSpecies.get(placement.asset_path) === placement.species, `${placement.id} asset/species mismatch`);
    invariant(Array.isArray(placement.position_m) && placement.position_m.length === 3 && placement.position_m.every(Number.isFinite), `${placement.id} position is invalid`);
    invariant(Number.isFinite(placement.yaw_radians) && placement.yaw_radians >= -Math.PI && placement.yaw_radians <= Math.PI, `${placement.id} yaw is invalid`);
    invariant(Number.isFinite(placement.uniform_scale) && placement.uniform_scale >= 2.8 && placement.uniform_scale <= 7.4, `${placement.id} scale is invalid`);
    const isUnknownAnnotation = placement.zone === NAIP_UNKNOWN_SHRUB_ZONE_ID;
    if (isUnknownAnnotation) {
      const annotation = unknownAnnotationsById.get(placement.annotation_id);
      invariant(annotation && !seenUnknownAnnotationIds.has(annotation.id), `${placement.id} has a missing or duplicate NAIP unknown annotation`);
      const [sourceX, , sourceZ] = annotation.properties.world_position_m;
      const expectedVariation = naipUnknownShrubVariation(annotation.id);
      invariant(placement.id === `vegetation:${NAIP_UNKNOWN_SHRUB_ZONE_ID}:${annotation.id}` &&
        placement.species === "shrub" && placement.annotation_tree_type === "unknown" &&
        placement.cell_id === annotation.id &&
        placement.source_id === `naip:2022-05-18:${annotation.properties.source_cell}`,
      `${placement.id} NAIP identity/provenance contract drift`);
      invariant(placement.position_m[0] === sourceX && placement.position_m[2] === sourceZ,
        `${placement.id} moved from its fixed projected NAIP location`);
      invariant(placement.asset_path === expectedVariation.asset_path &&
        placement.yaw_radians === expectedVariation.yaw_radians &&
        placement.uniform_scale === expectedVariation.uniform_scale,
      `${placement.id} deterministic shrub variation drift`);
      seenUnknownAnnotationIds.add(annotation.id);
    }
    const support = placement.terrain_support;
    const landRecord = landByKey.get(support?.object_key);
    invariant(landRecord, `${placement.id} is not supported by serialized playable land`);
    const triangleOffset = support.triangle_index * 3;
    invariant(Number.isInteger(support.triangle_index) && triangleOffset >= 0 && triangleOffset + 2 < landRecord.indices.length, `${placement.id} terrain triangle is invalid`);
    const facet = landFacet(landRecord, triangleOffset, support.object_key);
    const sample = facetSample(facet, placement.position_m[0], -placement.position_m[2]);
    invariant(sample.inside, `${placement.id} terrain support triangle does not contain placement`);
    invariant(Math.abs(sample.elevation - placement.position_m[1]) <= COORDINATE_ROUNDING_M + 1e-9 && placement.position_m[1] === support.elevation_m, `${placement.id} is not exactly grounded to serialized terrain`);
    const point = [placement.position_m[0], placement.position_m[2]];
    const measured = {
      boundary_shoreline: pointToBoundaryDistance(point, manifest.playable_boundary),
      roads_paths: pointToRecordsDistance(point, roadRecords),
      buildings_foundations: pointToRecordsDistance(point, buildingRecords),
      terrain_shoreline_overlays: pointToRecordsDistance(point, shorelineOverlayRecords),
      ferry_spawn: Math.hypot(point[0] - manifest.initial_spawn.origin[0], point[1] - manifest.initial_spawn.origin[2]),
      ferry_arrival_path: pointToLineDistance(point, VEGETATION_QA_CORRIDORS.ferry_arrival_path),
      normal_qa_route: pointToLineDistance(point, VEGETATION_QA_CORRIDORS.normal_qa_route),
      whole_island_qa_route: pointToLineDistance(point, VEGETATION_QA_CORRIDORS.whole_island_qa_route),
    };
    const requirements = isUnknownAnnotation ? NAIP_UNKNOWN_CLEARANCES_M : VEGETATION_CLEARANCES_M;
    const observationTarget = isUnknownAnnotation ? unknownObserved : observed;
    for (const [key, required] of Object.entries(requirements)) {
      if (isUnknownAnnotation && ["roads_paths", "buildings_foundations"].includes(key)) {
        invariant(measured[key] >= required - 1e-9, `${placement.id} violates the source-annotation ${key} exterior threshold`);
      } else {
        invariant(measured[key] >= required - 0.002, `${placement.id} ${key} clearance ${measured[key]} < ${required}`);
      }
      observationTarget[key] = Math.min(observationTarget[key], measured[key]);
    }
    if (isUnknownAnnotation) {
      for (const key of ["roads_paths", "buildings_foundations"]) {
        if (measured[key] < VEGETATION_CLEARANCES_M[key]) {
          expectedProceduralBufferExceptions.push({
            annotation_id: placement.annotation_id,
            position_m: [placement.position_m[0], placement.position_m[2]],
            clearance: key,
            observed_m: Math.round((measured[key] + Number.EPSILON) * 1000) / 1000,
            procedural_required_m: VEGETATION_CLEARANCES_M[key],
            source_annotation_required_m: NAIP_UNKNOWN_CLEARANCES_M[key],
            outcome: "placed_at_fixed_source_location",
          });
        }
      }
    }
  }
  invariant(vegetation.audit.terrain_grounded_count === placements.length && vegetation.audit.ybi_placements === 0, "Vegetation terrain/YBI audit drift");
  const annotationAudit = vegetation.audit.naip_unknown_annotations;
  const annotationOrder = new Map(unknownAnnotations.map((feature, index) => [feature.id, index]));
  expectedProceduralBufferExceptions.sort((left, right) =>
    annotationOrder.get(left.annotation_id) - annotationOrder.get(right.annotation_id) ||
    left.clearance.localeCompare(right.clearance));
  invariant(annotationAudit?.source_schema === NAIP_TREE_ANNOTATION_SCHEMA, "NAIP unknown audit source schema drift");
  invariant(annotationAudit.source_sha256 === NAIP_TREE_ANNOTATION_SHA256, "NAIP unknown audit source hash drift");
  invariant(annotationAudit.source_imagery_date === "2022-05-18", "NAIP unknown audit imagery date drift");
  invariant(annotationAudit.input_count === 22 && annotationAudit.placed_count === 22 &&
    annotationAudit.rejected_count === 0 && seenUnknownAnnotationIds.size === 22,
  "NAIP unknown audit count drift");
  invariant(annotationAudit.fixed_projected_locations === true, "NAIP unknown fixed-location audit drift");
  invariant(stableJson(annotationAudit.clearance_policy_m) === stableJson(NAIP_UNKNOWN_CLEARANCES_M),
    "NAIP unknown clearance-policy audit drift");
  invariant(stableJson(annotationAudit.accepted_ids) === stableJson(unknownAnnotations.map((feature) => feature.id)),
    "NAIP unknown accepted-ID audit drift");
  invariant(Array.isArray(annotationAudit.procedural_buffer_exceptions) &&
    annotationAudit.procedural_buffer_exceptions.length === expectedProceduralBufferExceptions.length,
  "NAIP unknown procedural-buffer exception count drift");
  annotationAudit.procedural_buffer_exceptions.forEach((actual, index) => {
    const expected = expectedProceduralBufferExceptions[index];
    invariant(actual.annotation_id === expected.annotation_id && actual.clearance === expected.clearance &&
      stableJson(actual.position_m) === stableJson(expected.position_m) &&
      actual.procedural_required_m === expected.procedural_required_m &&
      actual.source_annotation_required_m === expected.source_annotation_required_m &&
      actual.outcome === expected.outcome && Math.abs(actual.observed_m - expected.observed_m) <= 0.002,
    `NAIP unknown procedural-buffer exception drift at ${actual.annotation_id}`);
  });
  invariant(stableJson(annotationAudit.rejected) === stableJson([]), "NAIP unknown rejection audit is not empty");
  for (const [key, value] of Object.entries(observed)) {
    invariant(Math.abs(value - vegetation.audit.minimum_observed_clearances_m[key]) <= 0.002, `Vegetation ${key} minimum-clearance audit drift`);
  }
  for (const [key, value] of Object.entries(unknownObserved)) {
    invariant(Math.abs(value - annotationAudit.minimum_observed_clearances_m[key]) <= 0.002, `NAIP unknown shrub ${key} minimum-clearance audit drift`);
  }
  return vegetation;
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
  const pavement = validatePavementSkin(worldRoot, manifest, coverage, records, terrain);
  const vegetation = validateVegetation(worldRoot, manifest, records);
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
    pavement,
    vegetation_seed: vegetation.seed,
    vegetation_instances: vegetation.counts.total,
  }));
}

main();
