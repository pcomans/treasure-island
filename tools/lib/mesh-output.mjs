import earcut from "earcut";

import {
  intersectMultiPolygons,
  multiPolygonArea,
  multiPolygonBounds,
  pointInMultiPolygon,
  rectangleMultiPolygon,
  serializedAreaTolerance,
  signedRingArea,
} from "./osm-geometry.mjs";
import { invariant, roundCoordinate } from "./world-contract.mjs";

function emptyMesh() {
  return { vertices: [], normals: [], uvs: [], indices: [] };
}

function pushVertex(mesh, position, normal, uv) {
  const index = mesh.vertices.length / 3;
  mesh.vertices.push(...position.map(roundCoordinate));
  mesh.normals.push(...normal.map(roundCoordinate));
  mesh.uvs.push(...uv.map(roundCoordinate));
  return index;
}

function triangleCross(a, b, c) {
  const ab = [b[0] - a[0], b[1] - a[1], b[2] - a[2]];
  const ac = [c[0] - a[0], c[1] - a[1], c[2] - a[2]];
  return [
    ab[1] * ac[2] - ab[2] * ac[1],
    ab[2] * ac[0] - ab[0] * ac[2],
    ab[0] * ac[1] - ab[1] * ac[0],
  ];
}

function triangleArea3d(a, b, c) {
  const cross = triangleCross(a, b, c);
  return Math.hypot(...cross) / 2;
}

function vertexAt(vertices, index) {
  return vertices.slice(index * 3, index * 3 + 3);
}

function pushTriangleWithNormal(mesh, indices, desiredNormal, label) {
  let [a, b, c] = indices;
  const first = vertexAt(mesh.vertices, a);
  const second = vertexAt(mesh.vertices, b);
  const third = vertexAt(mesh.vertices, c);
  const cross = triangleCross(first, second, third);
  const area = Math.hypot(...cross) / 2;
  invariant(area > 1e-8, `${label} emitted a degenerate triangle`);
  if (cross[0] * desiredNormal[0] + cross[1] * desiredNormal[1] + cross[2] * desiredNormal[2] < 0) {
    [b, c] = [c, b];
  }
  mesh.indices.push(a, b, c);
}

function earcutPolygon(polygon, label) {
  const flat = [];
  const holes = [];
  const points = [];
  for (const [ringIndex, ring] of polygon.entries()) {
    if (ringIndex > 0) holes.push(points.length);
    for (const point of ring) {
      flat.push(point[0], point[1]);
      points.push(point);
    }
  }
  const indices = earcut(flat, holes, 2);
  invariant(indices.length > 0 && indices.length % 3 === 0, `${label} triangulation is empty or malformed`);
  return { points, indices };
}

export function topSurfaceMesh(multiPolygon, elevationM, label = "top surface") {
  const mesh = emptyMesh();
  let triangleArea = 0;
  let rejectedDegenerateTriangles = 0;
  for (const [polygonIndex, polygon] of multiPolygon.entries()) {
    const triangulated = earcutPolygon(polygon, `${label}[${polygonIndex}]`);
    const vertexOffset = mesh.vertices.length / 3;
    for (const point of triangulated.points) {
      pushVertex(
        mesh,
        [point[0], elevationM, -point[1]],
        [0, 1, 0],
        [point[0] / 10, -point[1] / 10],
      );
    }
    for (let index = 0; index < triangulated.indices.length; index += 3) {
      const triangle = triangulated.indices.slice(index, index + 3).map((value) => value + vertexOffset);
      const serializedArea = triangleArea3d(
        vertexAt(mesh.vertices, triangle[0]),
        vertexAt(mesh.vertices, triangle[1]),
        vertexAt(mesh.vertices, triangle[2]),
      );
      if (serializedArea <= 1e-8) {
        rejectedDegenerateTriangles += 1;
        continue;
      }
      pushTriangleWithNormal(mesh, triangle, [0, 1, 0], label);
      triangleArea += serializedArea;
    }
  }
  const polygonArea = multiPolygonArea(multiPolygon);
  // Positions above are the serialized millimeter coordinates. The exact
  // unrounded triangulation is audited separately with the stricter tolerance.
  const tolerance = serializedAreaTolerance(multiPolygon).tolerance_m2;
  invariant(
    Math.abs(triangleArea - polygonArea) <= tolerance,
    `${label} triangle area ${triangleArea} differs from polygon area ${polygonArea} by more than ${tolerance}`,
  );
  validateMesh(mesh, label);
  return {
    ...mesh,
    plan_area_m2: polygonArea,
    triangle_area_m2: triangleArea,
    rejected_degenerate_triangles: rejectedDegenerateTriangles,
  };
}

function terrainNormal(east, north, elevationSampler, sampleDistanceM = 2) {
  const west = elevationSampler(east - sampleDistanceM, north);
  const eastValue = elevationSampler(east + sampleDistanceM, north);
  const south = elevationSampler(east, north - sampleDistanceM);
  const northValue = elevationSampler(east, north + sampleDistanceM);
  const slopeEast = (eastValue - west) / (sampleDistanceM * 2);
  const slopeNorth = (northValue - south) / (sampleDistanceM * 2);
  const length = Math.hypot(slopeEast, 1, slopeNorth);
  return [-slopeEast / length, 1 / length, slopeNorth / length];
}

export function terrainSurfaceMesh(multiPolygon, elevationSampler, label = "terrain surface") {
  const mesh = emptyMesh();
  let trianglePlanArea = 0;
  let rejectedDegenerateTriangles = 0;
  for (const [polygonIndex, polygon] of multiPolygon.entries()) {
    const triangulated = earcutPolygon(polygon, `${label}[${polygonIndex}]`);
    const vertexOffset = mesh.vertices.length / 3;
    for (const point of triangulated.points) {
      const elevation = elevationSampler(point[0], point[1]);
      pushVertex(
        mesh,
        [point[0], elevation, -point[1]],
        terrainNormal(point[0], point[1], elevationSampler),
        [point[0] / 10, -point[1] / 10],
      );
    }
    for (let index = 0; index < triangulated.indices.length; index += 3) {
      const triangle = triangulated.indices.slice(index, index + 3).map((value) => value + vertexOffset);
      const first = vertexAt(mesh.vertices, triangle[0]);
      const second = vertexAt(mesh.vertices, triangle[1]);
      const third = vertexAt(mesh.vertices, triangle[2]);
      const serializedArea = triangleArea3d(first, second, third);
      if (serializedArea <= 1e-8) {
        rejectedDegenerateTriangles += 1;
        continue;
      }
      pushTriangleWithNormal(mesh, triangle, [0, 1, 0], label);
      trianglePlanArea += Math.abs(
        (second[0] - first[0]) * (third[2] - first[2]) -
        (third[0] - first[0]) * (second[2] - first[2]),
      ) / 2;
    }
  }
  const polygonArea = multiPolygonArea(multiPolygon);
  const tolerance = serializedAreaTolerance(multiPolygon).tolerance_m2;
  invariant(
    Math.abs(trianglePlanArea - polygonArea) <= tolerance,
    `${label} plan triangle area ${trianglePlanArea} differs from polygon area ${polygonArea} by more than ${tolerance}`,
  );
  validateMesh(mesh, label);
  return {
    ...mesh,
    plan_area_m2: polygonArea,
    triangle_plan_area_m2: trianglePlanArea,
    rejected_degenerate_triangles: rejectedDegenerateTriangles,
  };
}

export function griddedTerrainSurfaceMesh(multiPolygon, cellSizeM, elevationSampler, label = "gridded terrain") {
  invariant(Number.isFinite(cellSizeM) && cellSizeM > 0, `${label} has invalid grid size`);
  const bounds = multiPolygonBounds(multiPolygon);
  const minimumX = Math.floor(bounds.min_x / cellSizeM) * cellSizeM;
  const maximumX = Math.ceil(bounds.max_x / cellSizeM) * cellSizeM;
  const minimumY = Math.floor(bounds.min_y / cellSizeM) * cellSizeM;
  const maximumY = Math.ceil(bounds.max_y / cellSizeM) * cellSizeM;
  const pieces = [];
  for (let west = minimumX; west < maximumX; west += cellSizeM) {
    for (let south = minimumY; south < maximumY; south += cellSizeM) {
      const clipped = intersectMultiPolygons(
        multiPolygon,
        rectangleMultiPolygon(west, south, west + cellSizeM, south + cellSizeM),
      );
      if (clipped.length === 0 || multiPolygonArea(clipped) <= 1e-8) continue;
      pieces.push(terrainSurfaceMesh(clipped, elevationSampler, `${label}/${west}/${south}`));
    }
  }
  const mesh = mergeMeshes(pieces, label);
  invariant(mesh.indices.length > 0, `${label} produced no gridded triangles`);
  return mesh;
}

export function terrainSkirtMesh(multiPolygon, elevationSampler, baseElevationM = 0, label = "terrain skirt") {
  const mesh = emptyMesh();
  for (const polygon of multiPolygon) {
    for (const ring of polygon) {
      for (let index = 0; index < ring.length; index += 1) {
        const start = ring[index];
        const end = ring[(index + 1) % ring.length];
        const startTop = elevationSampler(start[0], start[1]);
        const endTop = elevationSampler(end[0], end[1]);
        if (Math.max(startTop, endTop) - baseElevationM <= 0.001) continue;
        const normal = outwardNormal(start, end);
        const width = Math.hypot(end[0] - start[0], end[1] - start[1]);
        const a = pushVertex(mesh, [start[0], baseElevationM, -start[1]], normal, [0, 0]);
        const b = pushVertex(mesh, [end[0], baseElevationM, -end[1]], normal, [width / 10, 0]);
        const c = pushVertex(mesh, [end[0], endTop, -end[1]], normal, [width / 10, endTop / 10]);
        const d = pushVertex(mesh, [start[0], startTop, -start[1]], normal, [0, startTop / 10]);
        pushTriangleWithNormal(mesh, [a, b, c], normal, label);
        pushTriangleWithNormal(mesh, [a, c, d], normal, label);
      }
    }
  }
  validateMesh(mesh, label);
  return mesh;
}

export function triangulationAreaAudit(multiPolygon, label = "triangulation audit") {
  let triangleArea = 0;
  for (const [polygonIndex, polygon] of multiPolygon.entries()) {
    const triangulated = earcutPolygon(polygon, `${label}[${polygonIndex}]`);
    for (let index = 0; index < triangulated.indices.length; index += 3) {
      const a = triangulated.points[triangulated.indices[index]];
      const b = triangulated.points[triangulated.indices[index + 1]];
      const c = triangulated.points[triangulated.indices[index + 2]];
      triangleArea += Math.abs(
        (b[0] - a[0]) * (c[1] - a[1]) -
        (c[0] - a[0]) * (b[1] - a[1]),
      ) / 2;
    }
  }
  const polygonArea = multiPolygonArea(multiPolygon);
  const delta = Math.abs(triangleArea - polygonArea);
  const tolerance = Math.max(0.01, polygonArea * 1e-8);
  invariant(delta <= tolerance, `${label} pre-serialization area delta ${delta} exceeds ${tolerance}`);
  return {
    polygon_area_m2: polygonArea,
    triangle_area_m2: triangleArea,
    delta_m2: delta,
    tolerance_m2: tolerance,
  };
}

function outwardNormal(start, end) {
  const dx = end[0] - start[0];
  const dy = end[1] - start[1];
  const length = Math.hypot(dx, dy);
  invariant(length > 1e-10, "Wall edge is zero-length");
  return [dy / length, 0, dx / length];
}

function neighborHeightForEdge(start, end, cell, allCells) {
  const dx = end[0] - start[0];
  const dy = end[1] - start[1];
  const length = Math.hypot(dx, dy);
  const outwardEast = dy / length;
  const outwardNorth = -dx / length;
  const midpoint = [(start[0] + end[0]) / 2, (start[1] + end[1]) / 2];
  const sampleDistances = [0.002, 0.01, 0.05];
  for (const distance of sampleDistances) {
    const sample = [
      midpoint[0] + outwardEast * distance,
      midpoint[1] + outwardNorth * distance,
    ];
    const neighbor = allCells.find((candidate) =>
      candidate !== cell && pointInMultiPolygon(sample, candidate.geometry, false));
    if (neighbor) return neighbor.top_elevation_m;
  }
  return cell.base_elevation_m;
}

function pushWallSegment(mesh, start, end, bottomStart, bottomEnd, top, normal, label) {
  if (top - Math.min(bottomStart, bottomEnd) <= 0.001) return false;
  const width = Math.hypot(end[0] - start[0], end[1] - start[1]);
  if (width <= 0.001) return false;
  const a = pushVertex(mesh, [start[0], bottomStart, -start[1]], normal, [0, bottomStart / 10]);
  const b = pushVertex(mesh, [end[0], bottomEnd, -end[1]], normal, [width / 10, bottomEnd / 10]);
  const c = pushVertex(mesh, [end[0], top, -end[1]], normal, [width / 10, top / 10]);
  const d = pushVertex(mesh, [start[0], top, -start[1]], normal, [0, top / 10]);
  pushTriangleWithNormal(mesh, [a, b, c], normal, label);
  pushTriangleWithNormal(mesh, [a, c, d], normal, label);
  return true;
}

export function wallSurfaceMesh(
  cell,
  allCells = [cell],
  label = "wall surface",
  exteriorBottomSegments = null,
) {
  const mesh = emptyMesh();
  let exteriorSegments = 0;
  let sharedSegments = 0;
  for (const polygon of cell.geometry) {
    for (const ring of polygon) {
      for (let index = 0; index < ring.length; index += 1) {
        const start = ring[index];
        const end = ring[(index + 1) % ring.length];
        const neighborHeight = neighborHeightForEdge(start, end, cell, allCells);
        const normal = outwardNormal(start, end);
        if (neighborHeight > cell.base_elevation_m + 0.001) {
          const bottom = Math.min(cell.top_elevation_m, neighborHeight);
          if (pushWallSegment(mesh, start, end, bottom, bottom, cell.top_elevation_m, normal, label)) {
            sharedSegments += 1;
          }
          continue;
        }
        const segments = exteriorBottomSegments == null
          ? [{ start, end, bottom_start_m: cell.base_elevation_m, bottom_end_m: cell.base_elevation_m }]
          : exteriorBottomSegments(start, end, cell.base_elevation_m, label);
        invariant(Array.isArray(segments) && segments.length > 0, `${label} exterior edge has no foundation segments`);
        for (const segment of segments) {
          if (pushWallSegment(
            mesh,
            segment.start,
            segment.end,
            segment.bottom_start_m,
            segment.bottom_end_m,
            cell.top_elevation_m,
            normal,
            label,
          )) {
            exteriorSegments += 1;
          }
        }
      }
    }
  }
  validateMesh(mesh, label, { allowEmpty: true });
  return {
    ...mesh,
    exterior_segments: exteriorSegments,
    shared_segments: sharedSegments,
  };
}

export function mergeMeshes(meshes, label = "merged mesh") {
  const merged = emptyMesh();
  for (const mesh of meshes) {
    const vertexOffset = merged.vertices.length / 3;
    merged.vertices.push(...mesh.vertices);
    merged.normals.push(...mesh.normals);
    merged.uvs.push(...mesh.uvs);
    merged.indices.push(...mesh.indices.map((index) => index + vertexOffset));
  }
  validateMesh(merged, label, { allowEmpty: true });
  return merged;
}

export function validateMesh(mesh, label = "mesh", options = {}) {
  const { allowEmpty = false } = options;
  invariant(mesh.vertices.length % 3 === 0, `${label} vertex array is malformed`);
  invariant(mesh.normals.length === mesh.vertices.length, `${label} normal count differs from vertex count`);
  invariant(mesh.uvs.length === (mesh.vertices.length / 3) * 2, `${label} UV count differs from vertex count`);
  invariant(mesh.indices.length % 3 === 0, `${label} index array is malformed`);
  invariant(allowEmpty || mesh.indices.length > 0, `${label} has no triangles`);
  invariant([...mesh.vertices, ...mesh.normals, ...mesh.uvs].every(Number.isFinite), `${label} has non-finite values`);
  const vertexCount = mesh.vertices.length / 3;
  for (const index of mesh.indices) {
    invariant(Number.isInteger(index) && index >= 0 && index < vertexCount, `${label} index ${index} is out of range`);
  }
  for (let index = 0; index < mesh.indices.length; index += 3) {
    const area = triangleArea3d(
      vertexAt(mesh.vertices, mesh.indices[index]),
      vertexAt(mesh.vertices, mesh.indices[index + 1]),
      vertexAt(mesh.vertices, mesh.indices[index + 2]),
    );
    invariant(area > 1e-8, `${label} has a degenerate triangle at ${index / 3}`);
  }
  return {
    vertices: vertexCount,
    triangles: mesh.indices.length / 3,
  };
}

export function meshRecord({
  objectKey,
  featureKind,
  sourceKeys,
  materialKey,
  mesh,
  collisionKind = "none",
  receiverKind = "none",
  opaque = false,
}) {
  invariant(typeof objectKey === "string" && objectKey.length > 0, "Mesh record needs an object key");
  invariant(Array.isArray(sourceKeys) && sourceKeys.length > 0, `${objectKey} needs source keys`);
  validateMesh(mesh, objectKey);
  invariant(["none", "world_solid"].includes(collisionKind), `${objectKey} has invalid collision kind`);
  invariant(["none", "building_wall"].includes(receiverKind), `${objectKey} has invalid receiver kind`);
  return {
    object_key: objectKey,
    feature_kind: featureKind,
    source_keys: [...new Set(sourceKeys)].sort(),
    material_key: materialKey,
    vertices: mesh.vertices,
    normals: mesh.normals,
    uvs: mesh.uvs,
    indices: mesh.indices,
    collision_kind: collisionKind,
    receiver_kind: receiverKind,
    opaque: Boolean(opaque),
  };
}

export function meshPlanArea(mesh) {
  let area = 0;
  for (let index = 0; index < mesh.indices.length; index += 3) {
    const a = vertexAt(mesh.vertices, mesh.indices[index]);
    const b = vertexAt(mesh.vertices, mesh.indices[index + 1]);
    const c = vertexAt(mesh.vertices, mesh.indices[index + 2]);
    area += Math.abs((b[0] - a[0]) * (c[2] - a[2]) - (c[0] - a[0]) * (b[2] - a[2])) / 2;
  }
  return area;
}

export function ringOrientationAudit(multiPolygon) {
  for (const polygon of multiPolygon) {
    invariant(signedRingArea(polygon[0]) > 0, "Outer ring is not counter-clockwise");
    for (const hole of polygon.slice(1)) invariant(signedRingArea(hole) < 0, "Hole is not clockwise");
  }
}
