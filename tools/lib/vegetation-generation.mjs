import { createHash } from "node:crypto";

import { pointInMultiPolygon } from "./osm-geometry.mjs";

export const VEGETATION_SCHEMA = "ti.vegetation/1";
export const VEGETATION_SEED = 0x54495631;
export const VEGETATION_ASSET_ROOT = "res://game/resources/models/vegetation/kenney_nature_kit/";
export const NAIP_TREE_ANNOTATION_SCHEMA = "ti.naip-tree-annotations-candidate/1";
export const NAIP_TREE_ANNOTATION_SHA256 = "03f858180c6ff0d25b974b1fbb0fc82a91139afe91e83b2e3291ef2dd49ade11";
export const NAIP_UNKNOWN_SHRUB_ZONE_ID = "naip_unknown_shrubs";
export const VEGETATION_CLEARANCES_M = Object.freeze({
  boundary_shoreline: 14,
  roads_paths: 4,
  buildings_foundations: 5,
  terrain_shoreline_overlays: 3,
  ferry_spawn: 24,
  ferry_arrival_path: 16,
  normal_qa_route: 7,
  whole_island_qa_route: 5,
});
// Manually accepted satellite crown centers are fixed source coordinates, not
// procedural candidates. They retain every non-surface clearance, but use a
// 1 mm exterior test for roads/buildings so a valid roadside crown is not
// silently displaced or discarded by the procedural 4-5 m aesthetic buffer.
export const NAIP_UNKNOWN_CLEARANCES_M = Object.freeze({
  ...VEGETATION_CLEARANCES_M,
  roads_paths: 0.001,
  buildings_foundations: 0.001,
});

export const VEGETATION_ASSETS = Object.freeze([
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}grass.glb`, species: "ornamental_grass" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}grass_large.glb`, species: "ornamental_grass" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}grass_leafsLarge.glb`, species: "ornamental_grass" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}plant_bushDetailed.glb`, species: "shrub" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}plant_bushLarge.glb`, species: "shrub" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}plant_bushSmall.glb`, species: "shrub" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}tree_detailed.glb`, species: "broadleaf" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}tree_oak.glb`, species: "broadleaf" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}tree_palmBend.glb`, species: "palm" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}tree_palmDetailedShort.glb`, species: "palm" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}tree_palmDetailedTall.glb`, species: "palm" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}tree_pineTallA_detailed.glb`, species: "conifer" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}tree_pineTallB_detailed.glb`, species: "conifer" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}tree_plateau.glb`, species: "broadleaf" }),
  Object.freeze({ path: `${VEGETATION_ASSET_ROOT}tree_thin.glb`, species: "broadleaf" }),
]);

const NORMAL_QA_ROUTE = Object.freeze([
  [-104.364, 786.024], [-93.682, 780.044], [-91.651, 778.897], [-84.414, 774.734],
  [-96.25, 754.195], [-108.833, 730.206], [-112.174, 722.948], [-112.666, 718.005],
  [-111.532, 712.884], [-110.152, 711.081], [-103.53, 705.972], [-68.085, 685.812],
  [-4.951, 652.705], [38.743, 629.439],
]);
const FERRY_ARRIVAL_PATH = Object.freeze(NORMAL_QA_ROUTE.slice(0, 7));
const WHOLE_ISLAND_QA_ROUTE = Object.freeze([
  NORMAL_QA_ROUTE.at(-1), [-293.543, 335.72], [-159.292, -104.818], [-159.535, -879.905], [606.249, 385.227],
]);
export const VEGETATION_QA_CORRIDORS = Object.freeze({
  ferry_arrival_path: FERRY_ARRIVAL_PATH,
  normal_qa_route: NORMAL_QA_ROUTE,
  whole_island_qa_route: WHOLE_ISLAND_QA_ROUTE,
});

const ZONE_SPECS = Object.freeze([
  Object.freeze({
    id: "south_palm_rows",
    source_id: "streetview:37.82080,-122.37400",
    kind: "lines",
    species: "palm",
    acceptance: 0.92,
    spacing_m: 18,
    jitter_m: 1.2,
    lines: Object.freeze([
      Object.freeze([[-321, 218], [-376, 82]]),
      Object.freeze([[-343, 208], [-398, 93]]),
      Object.freeze([[-14, 827], [127, 750]]),
    ]),
  }),
  Object.freeze({
    id: "south_ornamental_beds",
    source_id: "streetview:37.82080,-122.37400",
    kind: "grid",
    species: "ornamental",
    acceptance: 0.34,
    spacing_m: 11,
    jitter_m: 2.4,
    bounds: Object.freeze([-350, 210, -170, 445]),
  }),
  Object.freeze({
    id: "legacy_grid_broadleaf",
    source_id: "osm:w8921372:avenue-m",
    kind: "lines",
    species: "broadleaf",
    acceptance: 0.74,
    spacing_m: 34,
    jitter_m: 3,
    lines: Object.freeze([
      Object.freeze([[280, -268], [488, 112]]),
      Object.freeze([[305, -285], [511, 94]]),
      Object.freeze([[110, 165], [520, 380]]),
    ]),
  }),
  Object.freeze({
    id: "north_west_lawn_broadleaf",
    source_id: "streetview:37.83110,-122.37455|37.82568,-122.37696",
    kind: "grid",
    species: "broadleaf",
    acceptance: 0.22,
    spacing_m: 49,
    jitter_m: 10,
    bounds: Object.freeze([-550, -845, -115, -10]),
  }),
  Object.freeze({
    id: "central_conifer_groves",
    source_id: "streetview:37.82690,-122.37108",
    kind: "clusters",
    species: "conifer",
    acceptance: 0.84,
    spacing_m: 13,
    jitter_m: 2.8,
    centers: Object.freeze([[-73, -305], [115, -112], [28, -440]]),
    radius_cells: 2,
  }),
  Object.freeze({
    id: "south_shrub_groups",
    source_id: "streetview:37.81663,-122.37035|37.82080,-122.37400",
    kind: "clusters",
    species: "shrub",
    acceptance: 0.58,
    spacing_m: 8,
    jitter_m: 1.8,
    centers: Object.freeze([[-254, 356], [-210, 300], [58, 730]]),
    radius_cells: 2,
  }),
]);

function round(value) {
  return Math.round((value + Number.EPSILON) * 1000) / 1000;
}

function hashBytes(identity) {
  return createHash("sha256").update(`${VEGETATION_SEED}|${identity}`, "utf8").digest();
}

function unit(bytes, offset) {
  return bytes.readUInt32BE(offset) / 0xffffffff;
}

function pointToSegmentDistance(point, start, end) {
  const dx = end[0] - start[0];
  const dz = end[1] - start[1];
  const lengthSquared = dx * dx + dz * dz;
  if (lengthSquared === 0) return Math.hypot(point[0] - start[0], point[1] - start[1]);
  const fraction = Math.max(0, Math.min(1,
    ((point[0] - start[0]) * dx + (point[1] - start[1]) * dz) / lengthSquared));
  return Math.hypot(point[0] - (start[0] + dx * fraction), point[1] - (start[1] + dz * fraction));
}

function distanceToPolyline(point, line) {
  let minimum = Infinity;
  for (let index = 1; index < line.length; index += 1) {
    minimum = Math.min(minimum, pointToSegmentDistance(point, line[index - 1], line[index]));
  }
  return minimum;
}

function distanceToGeometryEdges(point, geometry) {
  let minimum = Infinity;
  for (const polygon of geometry) {
    for (const ring of polygon) {
      for (let index = 0; index < ring.length; index += 1) {
        minimum = Math.min(minimum, pointToSegmentDistance(point, ring[index], ring[(index + 1) % ring.length]));
      }
    }
  }
  return minimum;
}

function distanceToGeometry(point, geometry) {
  return pointInMultiPolygon(point, geometry, true) ? 0 : distanceToGeometryEdges(point, geometry);
}

function candidatesFor(spec) {
  const candidates = [];
  if (spec.kind === "lines") {
    spec.lines.forEach((line, rowIndex) => {
      const [start, end] = line;
      const length = Math.hypot(end[0] - start[0], end[1] - start[1]);
      const steps = Math.floor(length / spec.spacing_m);
      for (let cell = 0; cell <= steps; cell += 1) {
        const fraction = steps === 0 ? 0.5 : cell / steps;
        candidates.push({
          id: `${spec.id}:row_${String(rowIndex).padStart(2, "0")}:cell_${String(cell).padStart(3, "0")}`,
          base: [start[0] + (end[0] - start[0]) * fraction, start[1] + (end[1] - start[1]) * fraction],
        });
      }
    });
  } else if (spec.kind === "grid") {
    const [minX, minZ, maxX, maxZ] = spec.bounds;
    for (let row = 0, z = minZ; z <= maxZ; row += 1, z += spec.spacing_m) {
      for (let column = 0, x = minX; x <= maxX; column += 1, x += spec.spacing_m) {
        candidates.push({
          id: `${spec.id}:row_${String(row).padStart(3, "0")}:column_${String(column).padStart(3, "0")}`,
          base: [x, z],
        });
      }
    }
  } else if (spec.kind === "clusters") {
    spec.centers.forEach((center, clusterIndex) => {
      for (let row = -spec.radius_cells; row <= spec.radius_cells; row += 1) {
        for (let column = -spec.radius_cells; column <= spec.radius_cells; column += 1) {
          if (Math.hypot(row, column) > spec.radius_cells + 0.01) continue;
          candidates.push({
            id: `${spec.id}:cluster_${String(clusterIndex).padStart(2, "0")}:row_${row + spec.radius_cells}:column_${column + spec.radius_cells}`,
            base: [center[0] + column * spec.spacing_m, center[1] + row * spec.spacing_m],
          });
        }
      }
    });
  }
  return candidates;
}

function speciesFor(spec, bytes) {
  if (spec.species !== "ornamental") return spec.species;
  return unit(bytes, 16) < 0.58 ? "ornamental_grass" : "shrub";
}

function scaleFor(species, bytes) {
  const ranges = {
    palm: [5.3, 7.4],
    broadleaf: [4.8, 6.8],
    conifer: [4.2, 5.4],
    ornamental_grass: [2.8, 4.6],
    shrub: [3.0, 4.7],
  };
  const [minimum, maximum] = ranges[species];
  return round(minimum + (maximum - minimum) * unit(bytes, 20));
}

export function naipUnknownShrubVariation(annotationId) {
  const bytes = hashBytes(`${NAIP_UNKNOWN_SHRUB_ZONE_ID}:${annotationId}`);
  const assets = VEGETATION_ASSETS.filter((asset) => asset.species === "shrub");
  const asset = assets[Math.min(assets.length - 1, Math.floor(unit(bytes, 12) * assets.length))];
  return {
    asset_path: asset.path,
    yaw_radians: round(unit(bytes, 24) * Math.PI * 2 - Math.PI),
    uniform_scale: scaleFor("shrub", bytes),
  };
}

function classifyClearances(point, boundary, roadGeometries, buildingGeometries, shorelineOverlayGeometries, spawn) {
  const worldPoint = [point[0], -point[1]];
  return {
    boundary_shoreline: distanceToGeometryEdges(point, boundary),
    roads_paths: Math.min(...roadGeometries.map((geometry) => distanceToGeometry(point, geometry))),
    buildings_foundations: Math.min(...buildingGeometries.map((geometry) => distanceToGeometry(point, geometry))),
    terrain_shoreline_overlays: Math.min(...shorelineOverlayGeometries.map((geometry) => distanceToGeometry(point, geometry))),
    ferry_spawn: Math.hypot(point[0] - spawn[0], point[1] - spawn[1]),
    ferry_arrival_path: distanceToPolyline(worldPoint, FERRY_ARRIVAL_PATH),
    normal_qa_route: distanceToPolyline(worldPoint, NORMAL_QA_ROUTE),
    whole_island_qa_route: distanceToPolyline(worldPoint, WHOLE_ISLAND_QA_ROUTE),
  };
}

function acceptedNaipUnknownAnnotations(document) {
  if (document?.type !== "FeatureCollection" || document.schema !== NAIP_TREE_ANNOTATION_SCHEMA ||
      document.review_status !== "candidate" || !Array.isArray(document.features)) {
    throw new Error("NAIP tree annotation source contract drift");
  }
  const seen = new Set();
  return document.features.filter((feature) => {
    const id = feature?.id;
    const properties = feature?.properties;
    if (typeof id !== "string" || id !== properties?.id || seen.has(id)) {
      throw new Error(`Invalid or duplicate NAIP tree annotation ${String(id)}`);
    }
    seen.add(id);
    if (feature.type !== "Feature" || feature.geometry?.type !== "Point" ||
        properties.review_status !== "candidate" || properties.imagery_date !== "2022-05-18" ||
        !["palm", "conifer", "broadleaf", "unknown"].includes(properties.tree_type) ||
        !Array.isArray(properties.world_position_m) || properties.world_position_m.length !== 3 ||
        !properties.world_position_m.every(Number.isFinite)) {
      throw new Error(`Invalid NAIP tree annotation contract for ${id}`);
    }
    return properties.tree_type === "unknown";
  });
}

function clearanceAudit(clearances, requirements) {
  const failed = Object.entries(requirements).find(([key, required]) => clearances[key] < required);
  return failed ? { reason: failed[0], observed_m: round(clearances[failed[0]]), required_m: failed[1] } : null;
}

export function generateVegetation({ boundary, playableObjects, chunks, terrainSupportAt, spawn, naipTreeAnnotations }) {
  const roadGeometries = [...playableObjects.values()]
    .filter((object) => object.roles.includes("roads_paths"))
    .map((object) => object.geometry);
  const buildingGeometries = [...playableObjects.values()]
    .filter((object) => object.roles.includes("building") || object.roles.includes("building_part"))
    .map((object) => object.geometry);
  const shorelineOverlayGeometries = [...playableObjects.values()]
    .filter((object) => object.roles.includes("terrain_shoreline") && !object.logical_key.startsWith("land:"))
    .map((object) => object.geometry);
  const placements = [];
  const rejected = Object.fromEntries(Object.keys(VEGETATION_CLEARANCES_M).map((key) => [key, 0]));
  rejected.outside_playable_boundary = 0;
  rejected.seed_acceptance = 0;
  for (const spec of ZONE_SPECS) {
    for (const candidate of candidatesFor(spec)) {
      const bytes = hashBytes(candidate.id);
      if (unit(bytes, 0) >= spec.acceptance) {
        rejected.seed_acceptance += 1;
        continue;
      }
      const point = [
        round(candidate.base[0] + (unit(bytes, 4) * 2 - 1) * spec.jitter_m),
        round(candidate.base[1] + (unit(bytes, 8) * 2 - 1) * spec.jitter_m),
      ];
      if (!pointInMultiPolygon([point[0], -point[1]], boundary, false)) {
        rejected.outside_playable_boundary += 1;
        continue;
      }
      const clearances = classifyClearances([point[0], -point[1]], boundary, roadGeometries, buildingGeometries, shorelineOverlayGeometries, [spawn[0], -spawn[1]]);
      const failed = clearanceAudit(clearances, VEGETATION_CLEARANCES_M);
      if (failed) {
        rejected[failed.reason] += 1;
        continue;
      }
      const species = speciesFor(spec, bytes);
      const assets = VEGETATION_ASSETS.filter((asset) => asset.species === species);
      const asset = assets[Math.min(assets.length - 1, Math.floor(unit(bytes, 12) * assets.length))];
      const support = terrainSupportAt(chunks, point[0], -point[1]);
      placements.push({
        id: `vegetation:${candidate.id}`,
        zone: spec.id,
        species,
        asset_path: asset.path,
        source_id: spec.source_id,
        cell_id: candidate.id.slice(spec.id.length + 1),
        position_m: [point[0], support.elevation_m, point[1]],
        yaw_radians: round(unit(bytes, 24) * Math.PI * 2 - Math.PI),
        uniform_scale: scaleFor(species, bytes),
        terrain_support: {
          object_key: support.object_key,
          triangle_index: support.triangle_index,
          elevation_m: support.elevation_m,
        },
      });
    }
  }
  const unknownAnnotations = acceptedNaipUnknownAnnotations(naipTreeAnnotations);
  const unknownAnnotationAudit = { accepted_ids: [], procedural_buffer_exceptions: [], rejected: [] };
  for (const annotation of unknownAnnotations) {
    const [worldX, , worldZ] = annotation.properties.world_position_m;
    const point = [worldX, worldZ];
    if (!pointInMultiPolygon([worldX, -worldZ], boundary, false)) {
      rejected.outside_playable_boundary += 1;
      unknownAnnotationAudit.rejected.push({
        annotation_id: annotation.id,
        position_m: [worldX, worldZ],
        reason: "outside_playable_boundary",
      });
      continue;
    }
    const clearances = classifyClearances(
      [worldX, -worldZ],
      boundary,
      roadGeometries,
      buildingGeometries,
      shorelineOverlayGeometries,
      [spawn[0], -spawn[1]],
    );
    const failed = clearanceAudit(clearances, NAIP_UNKNOWN_CLEARANCES_M);
    if (failed) {
      rejected[failed.reason] += 1;
      unknownAnnotationAudit.rejected.push({
        annotation_id: annotation.id,
        position_m: [worldX, worldZ],
        ...failed,
      });
      continue;
    }
    for (const key of ["roads_paths", "buildings_foundations"]) {
      if (clearances[key] < VEGETATION_CLEARANCES_M[key]) {
        unknownAnnotationAudit.procedural_buffer_exceptions.push({
          annotation_id: annotation.id,
          position_m: [worldX, worldZ],
          clearance: key,
          observed_m: round(clearances[key]),
          procedural_required_m: VEGETATION_CLEARANCES_M[key],
          source_annotation_required_m: NAIP_UNKNOWN_CLEARANCES_M[key],
          outcome: "placed_at_fixed_source_location",
        });
      }
    }
    const support = terrainSupportAt(chunks, worldX, -worldZ);
    const variation = naipUnknownShrubVariation(annotation.id);
    placements.push({
      id: `vegetation:${NAIP_UNKNOWN_SHRUB_ZONE_ID}:${annotation.id}`,
      zone: NAIP_UNKNOWN_SHRUB_ZONE_ID,
      species: "shrub",
      asset_path: variation.asset_path,
      source_id: `naip:2022-05-18:${annotation.properties.source_cell}`,
      cell_id: annotation.id,
      annotation_id: annotation.id,
      annotation_tree_type: "unknown",
      position_m: [worldX, support.elevation_m, worldZ],
      yaw_radians: variation.yaw_radians,
      uniform_scale: variation.uniform_scale,
      terrain_support: {
        object_key: support.object_key,
        triangle_index: support.triangle_index,
        elevation_m: support.elevation_m,
      },
    });
    unknownAnnotationAudit.accepted_ids.push(annotation.id);
  }
  placements.sort((left, right) => left.id.localeCompare(right.id));
  const countBy = (field, allowed) => Object.fromEntries(allowed.map((key) => [
    key, placements.filter((placement) => placement[field] === key).length,
  ]));
  const minimumObserved = Object.fromEntries(Object.keys(VEGETATION_CLEARANCES_M).map((key) => [key, Infinity]));
  const unknownMinimumObserved = Object.fromEntries(Object.keys(NAIP_UNKNOWN_CLEARANCES_M).map((key) => [key, Infinity]));
  for (const placement of placements) {
    const point = [placement.position_m[0], -placement.position_m[2]];
    const clearances = classifyClearances(point, boundary, roadGeometries, buildingGeometries, shorelineOverlayGeometries, [spawn[0], -spawn[1]]);
    const target = placement.zone === NAIP_UNKNOWN_SHRUB_ZONE_ID ? unknownMinimumObserved : minimumObserved;
    for (const key of Object.keys(target)) target[key] = Math.min(target[key], clearances[key]);
  }
  return {
    schema_version: VEGETATION_SCHEMA,
    generator: "tools/lib/vegetation-generation.mjs",
    seed: VEGETATION_SEED,
    visual_only: true,
    coordinate_system: "+X east,+Y up,-Z north; meters; NAVD 88",
    asset_root: VEGETATION_ASSET_ROOT,
    assets: VEGETATION_ASSETS,
    clearances_m: VEGETATION_CLEARANCES_M,
    counts: {
      total: placements.length,
      by_species: countBy("species", ["broadleaf", "conifer", "ornamental_grass", "palm", "shrub"]),
      by_zone: countBy("zone", [...ZONE_SPECS.map((zone) => zone.id), NAIP_UNKNOWN_SHRUB_ZONE_ID].sort()),
      by_asset: countBy("asset_path", VEGETATION_ASSETS.map((asset) => asset.path)),
    },
    audit: {
      candidate_count: ZONE_SPECS.flatMap(candidatesFor).length + unknownAnnotations.length,
      procedural_candidate_count: ZONE_SPECS.flatMap(candidatesFor).length,
      naip_unknown_annotations: {
        source_schema: NAIP_TREE_ANNOTATION_SCHEMA,
        source_sha256: NAIP_TREE_ANNOTATION_SHA256,
        source_imagery_date: "2022-05-18",
        input_count: unknownAnnotations.length,
        placed_count: unknownAnnotationAudit.accepted_ids.length,
        rejected_count: unknownAnnotationAudit.rejected.length,
        fixed_projected_locations: true,
        clearance_policy_m: NAIP_UNKNOWN_CLEARANCES_M,
        clearance_policy_note: "Fixed source points preserve procedural shoreline, overlay, spawn, and QA-route buffers; road/building buffers are replaced by a 1 mm exterior test with no snapping.",
        deterministic_variation: "sha256(seed|naip_unknown_shrubs:annotation_id) selects approved shrub asset, yaw, and scale",
        accepted_ids: unknownAnnotationAudit.accepted_ids,
        procedural_buffer_exceptions: unknownAnnotationAudit.procedural_buffer_exceptions,
        rejected: unknownAnnotationAudit.rejected,
        minimum_observed_clearances_m: Object.fromEntries(
          Object.entries(unknownMinimumObserved).map(([key, value]) => [key, round(value)]),
        ),
      },
      rejected,
      minimum_observed_clearances_m: Object.fromEntries(
        Object.entries(minimumObserved).map(([key, value]) => [key, round(value)]),
      ),
      terrain_grounded_count: placements.length,
      ybi_placements: 0,
    },
    placements,
  };
}
