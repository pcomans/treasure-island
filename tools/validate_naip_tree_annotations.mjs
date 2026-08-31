import { readFileSync, readdirSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

import { pointInMultiPolygon } from "./lib/osm-geometry.mjs";
import { eastNorthToWorldRounded, projectLonLat } from "./lib/coordinates.mjs";

const ROOT = resolve(import.meta.dirname, "..");
const ANNOTATION_PATH = resolve(ROOT, "source_assets/vegetation/naip_2022/tree_annotations_candidate.geojson");
const FOOTPRINT_PATH = resolve(ROOT, "source_assets/vegetation/naip_2022/treasure_island_footprint.geojson");
const REJECTION_AUDIT_PATH = resolve(ROOT, "source_assets/vegetation/naip_2022/tree_annotations_rejection_audit.geojson");
const CHUNK_ROOT = resolve(ROOT, "generated/world/chunks");
const REPORT_PATH = resolve(ROOT, "source_assets/vegetation/naip_2022/validation_report.json");
const ALLOWED_TYPES = new Set(["palm", "conifer", "broadleaf", "unknown"]);
const ALLOWED_CONFIDENCE = new Set(["high", "medium", "low"]);

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function equalJson(left, right) {
  return JSON.stringify(left) === JSON.stringify(right);
}

function pointInTriangle2d(point, a, b, c, epsilon = 1e-8) {
  const sign = (p1, p2, p3) => (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1]);
  const d1 = sign(point, a, b);
  const d2 = sign(point, b, c);
  const d3 = sign(point, c, a);
  const hasNegative = d1 < -epsilon || d2 < -epsilon || d3 < -epsilon;
  const hasPositive = d1 > epsilon || d2 > epsilon || d3 > epsilon;
  return !(hasNegative && hasPositive);
}

function horizontalTriangles(featureKinds) {
  const triangles = [];
  for (const file of readdirSync(CHUNK_ROOT).filter((name) => name.endsWith(".json")).sort()) {
    const chunk = JSON.parse(readFileSync(resolve(CHUNK_ROOT, file), "utf8"));
    for (const record of chunk.records) {
      if (!featureKinds.has(record.feature_kind)) continue;
      assert(Array.isArray(record.vertices) && Array.isArray(record.indices), `${file}/${record.object_key} lacks mesh arrays`);
      for (let offset = 0; offset < record.indices.length; offset += 3) {
        const triangle = record.indices.slice(offset, offset + 3).map((index) => [record.vertices[index * 3], record.vertices[index * 3 + 2]]);
        triangles.push({ feature_kind: record.feature_kind, object_key: record.object_key, triangle });
      }
    }
  }
  return triangles;
}

const annotations = JSON.parse(readFileSync(ANNOTATION_PATH, "utf8"));
const footprint = JSON.parse(readFileSync(FOOTPRINT_PATH, "utf8"));
const rejectionAudit = JSON.parse(readFileSync(REJECTION_AUDIT_PATH, "utf8"));
assert(annotations.type === "FeatureCollection", "Annotations must be a FeatureCollection");
assert(annotations.schema === "ti.naip-tree-annotations-candidate/1", "Annotation schema drift");
assert(footprint.type === "FeatureCollection" && footprint.features.length === 1, "Footprint must contain one feature");
const boundary = footprint.features[0].geometry.coordinates;
assert(footprint.features[0].geometry.type === "MultiPolygon", "Footprint must be a MultiPolygon");
assert(rejectionAudit.schema === "ti.naip-tree-annotation-rejections/1", "Rejection audit schema drift");
assert(rejectionAudit.features.length === 30, "Rejection audit must preserve exactly 30 surface-intersection marks");

const expectedOrder = [...annotations.features].sort((left, right) => {
  const [lx, ly] = left.properties.source_pixel_xy;
  const [rx, ry] = right.properties.source_pixel_xy;
  return ly - ry || lx - rx || left.id.localeCompare(right.id);
});
assert(equalJson(annotations.features.map((feature) => feature.id), expectedOrder.map((feature) => feature.id)), "Features are not in canonical north-to-south/west-to-east pixel order");

const ids = new Set();
for (const feature of annotations.features) {
  assert(feature.type === "Feature" && feature.geometry?.type === "Point", `${feature.id} is not a Point feature`);
  assert(feature.id === feature.properties.id, `${feature.id} property ID mismatch`);
  assert(!ids.has(feature.id), `Duplicate ID ${feature.id}`);
  ids.add(feature.id);
  const [longitude, latitude] = feature.geometry.coordinates;
  assert(Number.isFinite(longitude) && Number.isFinite(latitude), `${feature.id} has non-finite WGS84 coordinates`);
  assert(longitude >= -180 && longitude <= 180 && latitude >= -90 && latitude <= 90, `${feature.id} has invalid WGS84 range`);
  assert(pointInMultiPolygon([longitude, latitude], boundary, true), `${feature.id} is outside the Treasure Island footprint (water or YBI)`);
  assert(ALLOWED_TYPES.has(feature.properties.tree_type), `${feature.id} has invalid tree type`);
  assert(ALLOWED_CONFIDENCE.has(feature.properties.confidence), `${feature.id} has invalid confidence`);
  assert(feature.properties.imagery_date === "2022-05-18", `${feature.id} imagery date drift`);
  assert(/^tile-(0\d|1\d)$/.test(feature.properties.source_cell), `${feature.id} source cell is invalid`);
  assert(Array.isArray(feature.properties.source_pixel_xy) && feature.properties.source_pixel_xy.every(Number.isInteger), `${feature.id} pixel evidence missing`);
  assert(typeof feature.properties.evidence === "string" && feature.properties.evidence.length > 0, `${feature.id} evidence note missing`);
  const expectedWorld = eastNorthToWorldRounded(projectLonLat(feature.geometry.coordinates));
  assert(equalJson(expectedWorld, feature.properties.world_position_m), `${feature.id} existing-coordinate projection mismatch`);
}

const surfaceTriangles = horizontalTriangles(new Set(["road_path", "building_roof", "building_part_roof"]));
const intersections = [];
for (const feature of annotations.features) {
  const world = feature.properties.world_position_m;
  const point = [world[0], world[2]];
  for (const surface of surfaceTriangles) {
    if (pointInTriangle2d(point, ...surface.triangle)) {
      intersections.push({ id: feature.id, feature_kind: surface.feature_kind, object_key: surface.object_key });
      break;
    }
  }
}
assert(intersections.length === 0, `Candidate points intersect serialized road/building surfaces:\n${JSON.stringify(intersections, null, 2)}`);

const rejectedIds = new Set();
for (const feature of rejectionAudit.features) {
  assert(!ids.has(feature.id), `${feature.id} is both accepted and rejected`);
  assert(!rejectedIds.has(feature.id), `Duplicate rejected ID ${feature.id}`);
  rejectedIds.add(feature.id);
  assert(feature.properties.review_status === "rejected", `${feature.id} rejection status drift`);
  assert(feature.properties.decision === "omit_without_snapping", `${feature.id} rejection decision drift`);
  const [worldX, , worldZ] = feature.properties.world_position_m;
  const matches = surfaceTriangles.some((surface) =>
    surface.feature_kind === feature.properties.intersected_feature_kind &&
    surface.object_key === feature.properties.intersected_object_key &&
    pointInTriangle2d([worldX, worldZ], ...surface.triangle));
  assert(matches, `${feature.id} no longer intersects its audited serialized surface`);
}

const typeCounts = Object.fromEntries([...ALLOWED_TYPES].map((value) => [value, 0]));
const confidenceCounts = Object.fromEntries([...ALLOWED_CONFIDENCE].map((value) => [value, 0]));
for (const feature of annotations.features) {
  typeCounts[feature.properties.tree_type] += 1;
  confidenceCounts[feature.properties.confidence] += 1;
}

const report = {
  schema: "ti.naip-tree-annotation-validation/1",
  status: "passed",
  features: annotations.features.length,
  unique_ids: ids.size,
  finite_wgs84: annotations.features.length,
  inside_treasure_island: annotations.features.length,
  ybi_annotations: 0,
  road_or_building_intersections: intersections.length,
  rejected_surface_intersections_preserved: rejectedIds.size,
  serialized_surface_triangles_checked: surfaceTriangles.length,
  canonical_order: "source pixel y ascending, x ascending, id ascending",
  type_counts: typeCounts,
  confidence_counts: confidenceCounts,
};
writeFileSync(REPORT_PATH, `${JSON.stringify(report, null, 2)}\n`);
process.stdout.write(`${JSON.stringify({ ...report, report: REPORT_PATH }, null, 2)}\n`);
