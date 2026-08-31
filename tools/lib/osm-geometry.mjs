import polygonClipping from "polygon-clipping";
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";

import { projectGeoJsonGeometry, projectLonLat } from "./coordinates.mjs";
import { invariant, roundCoordinate, stableJson } from "./world-contract.mjs";

const EPSILON = 1e-10;
export const QUANTIZATION_VERTEX_DELTA_M = Math.SQRT2 * 0.0005;

function samePoint(left, right) {
  return left[0] === right[0] && left[1] === right[1];
}

function comparePoint(left, right) {
  return left[0] - right[0] || left[1] - right[1];
}

function compareRingSequence(left, right) {
  const length = Math.min(left.length, right.length);
  for (let index = 0; index < length; index += 1) {
    const comparison = comparePoint(left[index], right[index]);
    if (comparison !== 0) return comparison;
  }
  return left.length - right.length;
}

export function signedRingArea(ring) {
  let doubledArea = 0;
  for (let index = 0; index < ring.length; index += 1) {
    const next = ring[(index + 1) % ring.length];
    doubledArea += ring[index][0] * next[1] - next[0] * ring[index][1];
  }
  return doubledArea / 2;
}

function orientation(a, b, c) {
  const value = (b[0] - a[0]) * (c[1] - a[1]) -
    (b[1] - a[1]) * (c[0] - a[0]);
  if (Math.abs(value) <= EPSILON) return 0;
  return value > 0 ? 1 : -1;
}

function pointOnSegment(point, start, end) {
  return orientation(start, end, point) === 0 &&
    point[0] >= Math.min(start[0], end[0]) - EPSILON &&
    point[0] <= Math.max(start[0], end[0]) + EPSILON &&
    point[1] >= Math.min(start[1], end[1]) - EPSILON &&
    point[1] <= Math.max(start[1], end[1]) + EPSILON;
}

function segmentsIntersect(a, b, c, d) {
  const abC = orientation(a, b, c);
  const abD = orientation(a, b, d);
  const cdA = orientation(c, d, a);
  const cdB = orientation(c, d, b);
  if (abC !== abD && cdA !== cdB) return true;
  return (abC === 0 && pointOnSegment(c, a, b)) ||
    (abD === 0 && pointOnSegment(d, a, b)) ||
    (cdA === 0 && pointOnSegment(a, c, d)) ||
    (cdB === 0 && pointOnSegment(b, c, d));
}

export function validateSimpleRing(ring, label = "ring") {
  invariant(ring.length >= 3, `${label} has fewer than three vertices`);
  for (let left = 0; left < ring.length; left += 1) {
    const leftNext = (left + 1) % ring.length;
    invariant(!samePoint(ring[left], ring[leftNext]), `${label} has a zero-length edge`);
    for (let right = left + 1; right < ring.length; right += 1) {
      const rightNext = (right + 1) % ring.length;
      if (left === right || leftNext === right || rightNext === left) continue;
      if (left === 0 && rightNext === 0) continue;
      invariant(
        !segmentsIntersect(ring[left], ring[leftNext], ring[right], ring[rightNext]),
        `${label} self-intersects at edges ${left} and ${right}`,
      );
    }
  }
}

function rotateRingCanonical(ring) {
  let best = ring;
  for (let index = 1; index < ring.length; index += 1) {
    if (comparePoint(ring[index], best[0]) > 0) continue;
    const candidate = [...ring.slice(index), ...ring.slice(0, index)];
    if (compareRingSequence(candidate, best) < 0) best = candidate;
  }
  return best;
}

export function canonicalizeRing(input, counterClockwise, label = "ring", round = false) {
  invariant(Array.isArray(input), `${label} is not an array`);
  const cleaned = [];
  for (const rawPoint of input) {
    invariant(Array.isArray(rawPoint) && rawPoint.length >= 2, `${label} has a malformed point`);
    const point = [Number(rawPoint[0]), Number(rawPoint[1])];
    invariant(Number.isFinite(point[0]) && Number.isFinite(point[1]), `${label} has non-finite data`);
    const normalized = round
      ? [roundCoordinate(point[0]), roundCoordinate(point[1])]
      : point;
    if (cleaned.length === 0 || !samePoint(cleaned.at(-1), normalized)) cleaned.push(normalized);
  }
  if (cleaned.length > 1 && samePoint(cleaned[0], cleaned.at(-1))) cleaned.pop();
  invariant(new Set(cleaned.map((point) => `${point[0]},${point[1]}`)).size >= 3, `${label} collapses below three distinct vertices`);
  const area = signedRingArea(cleaned);
  invariant(Math.abs(area) > EPSILON, `${label} has zero signed area`);
  const oriented = (area > 0) === counterClockwise ? cleaned : [...cleaned].reverse();
  const canonical = rotateRingCanonical(oriented);
  validateSimpleRing(canonical, label);
  return canonical;
}

function comparePolygon(left, right) {
  return comparePoint(left[0][0], right[0][0]) ||
    Math.abs(signedRingArea(right[0])) - Math.abs(signedRingArea(left[0])) ||
    compareRingSequence(left[0], right[0]);
}

export function canonicalizeMultiPolygon(input, options = {}) {
  const {
    label = "multipolygon",
    round = false,
    allowEmpty = false,
    invalidHoleTolerance = null,
    invalidHoleRemovals = null,
  } = options;
  invariant(Array.isArray(input), `${label} is not an array`);
  if (input.length === 0) {
    invariant(allowEmpty, `${label} is empty`);
    return [];
  }
  const polygons = input.map((polygon, polygonIndex) => {
    invariant(Array.isArray(polygon) && polygon.length >= 1, `${label}[${polygonIndex}] has no outer ring`);
    const outer = canonicalizeRing(
      polygon[0],
      true,
      `${label}[${polygonIndex}].outer`,
      round,
    );
    const holes = [];
    for (const [holeIndex, ring] of polygon.slice(1).entries()) {
      let hole;
      try {
        hole = canonicalizeRing(
          ring,
          false,
          `${label}[${polygonIndex}].hole[${holeIndex}]`,
          round,
        );
      } catch (error) {
        const holeArea = Math.abs(signedRingArea(ring));
        if (invalidHoleTolerance != null && holeArea <= invalidHoleTolerance) {
          invalidHoleRemovals?.push({
            repair_kind: "micro_hole",
            polygon_index: polygonIndex,
            hole_index: holeIndex,
            hole_area_m2: holeArea,
            reason: "boolean-created snapped road ribbon hole is invalid before serialization",
          });
          continue;
        }
        throw error;
      }
      if (!pointInRing(hole[0], outer, false)) {
        const holeArea = Math.abs(signedRingArea(hole));
        if (invalidHoleTolerance != null && holeArea <= invalidHoleTolerance) {
          invalidHoleRemovals?.push({
            repair_kind: "micro_hole",
            polygon_index: polygonIndex,
            hole_index: holeIndex,
            hole_area_m2: holeArea,
            reason: "boolean-created snapped road ribbon hole touches or lies outside its outer ring",
          });
          continue;
        }
        throw new Error(`${label}[${polygonIndex}].hole[${holeIndex}] lies outside its outer ring`);
      }
      holes.push(hole);
    }
    holes.sort((left, right) =>
      comparePoint(left[0], right[0]) ||
      Math.abs(signedRingArea(left)) - Math.abs(signedRingArea(right)) ||
      compareRingSequence(left, right));
    return [outer, ...holes];
  });
  polygons.sort(comparePolygon);
  return polygons;
}

export function closeMultiPolygon(multiPolygon) {
  return multiPolygon.map((polygon) => polygon.map((ring) => [...ring, ring[0]]));
}

export function geometryToMultiPolygon(geometry, label = "geometry") {
  invariant(geometry && typeof geometry.type === "string", `${label} is missing`);
  const projected = projectGeoJsonGeometry(geometry);
  if (projected.type === "Polygon") {
    return canonicalizeMultiPolygon([projected.coordinates], { label });
  }
  if (projected.type === "MultiPolygon") {
    return canonicalizeMultiPolygon(projected.coordinates, { label });
  }
  throw new Error(`${label} expected Polygon or MultiPolygon, found ${geometry.type}`);
}

export function geometryToLine(geometry, label = "line") {
  invariant(geometry?.type === "LineString", `${label} expected LineString, found ${geometry?.type}`);
  const projected = projectGeoJsonGeometry(geometry).coordinates;
  const points = [];
  for (const point of projected) {
    if (points.length === 0 || !samePoint(points.at(-1), point)) points.push(point);
  }
  invariant(points.length >= 2, `${label} has no non-zero segment`);
  return points;
}

export function multiPolygonArea(multiPolygon) {
  return multiPolygon.reduce((total, polygon) => total + polygon.reduce(
    (polygonArea, ring, index) => polygonArea + (index === 0 ? 1 : -1) * Math.abs(signedRingArea(ring)),
    0,
  ), 0);
}

export function multiPolygonPerimeter(multiPolygon) {
  let perimeter = 0;
  for (const polygon of multiPolygon) {
    for (const ring of polygon) {
      for (let index = 0; index < ring.length; index += 1) {
        const next = ring[(index + 1) % ring.length];
        perimeter += Math.hypot(next[0] - ring[index][0], next[1] - ring[index][1]);
      }
    }
  }
  return perimeter;
}

export function serializedAreaTolerance(multiPolygon) {
  const area = multiPolygonArea(multiPolygon);
  const perimeter = multiPolygonPerimeter(multiPolygon);
  const tolerance = Math.max(
    0.01,
    perimeter * QUANTIZATION_VERTEX_DELTA_M + Math.PI * QUANTIZATION_VERTEX_DELTA_M ** 2,
    area * 1e-8,
  );
  return { area_m2: area, perimeter_m: perimeter, delta_m: QUANTIZATION_VERTEX_DELTA_M, tolerance_m2: tolerance };
}

function segmentIntersectionPoint(a, b, c, d) {
  const r = [b[0] - a[0], b[1] - a[1]];
  const s = [d[0] - c[0], d[1] - c[1]];
  const denominator = r[0] * s[1] - r[1] * s[0];
  if (Math.abs(denominator) > EPSILON) {
    const ca = [c[0] - a[0], c[1] - a[1]];
    const t = (ca[0] * s[1] - ca[1] * s[0]) / denominator;
    return [a[0] + t * r[0], a[1] + t * r[1]];
  }
  const candidates = [a, b, c, d]
    .filter((point) => pointOnSegment(point, a, b) && pointOnSegment(point, c, d))
    .sort(comparePoint);
  invariant(candidates.length > 0, "Intersecting collinear segments have no shared point");
  return candidates[0];
}

function firstRingSelfIntersection(ring) {
  for (let left = 0; left < ring.length; left += 1) {
    const leftNext = (left + 1) % ring.length;
    for (let right = left + 1; right < ring.length; right += 1) {
      const rightNext = (right + 1) % ring.length;
      if (leftNext === right || rightNext === left || (left === 0 && rightNext === 0)) continue;
      if (segmentsIntersect(ring[left], ring[leftNext], ring[right], ring[rightNext])) {
        return {
          left_edge: left,
          right_edge: right,
          intersection: segmentIntersectionPoint(
            ring[left],
            ring[leftNext],
            ring[right],
            ring[rightNext],
          ),
        };
      }
    }
  }
  return null;
}

function removeRoadOuterSpikeLoops(
  inputRing,
  toleranceM2,
  label,
  polygonIndex,
  ringRole = "outer",
  holeIndex = null,
) {
  let ring = [...inputRing];
  if (ring.length > 1 && samePoint(ring[0], ring.at(-1))) ring.pop();
  const repairs = [];
  for (let repairIndex = 0; repairIndex < 100; repairIndex += 1) {
    const crossing = firstRingSelfIntersection(ring);
    if (!crossing) return { ring, repairs };
    const { left_edge: left, right_edge: right, intersection } = crossing;
    const firstLoop = [
      intersection,
      ...ring.slice(left + 1, right + 1),
    ];
    const secondLoop = [
      intersection,
      ...ring.slice(right + 1),
      ...ring.slice(0, left + 1),
    ];
    const loopArea = (loop) => loop.length >= 3 ? Math.abs(signedRingArea(loop)) : 0;
    const firstArea = loopArea(firstLoop);
    const secondArea = loopArea(secondLoop);
    const removeFirst = firstArea <= secondArea;
    const removed = removeFirst ? firstLoop : secondLoop;
    const removedArea = removeFirst ? firstArea : secondArea;
    const kept = removeFirst ? secondLoop : firstLoop;
    invariant(
      removedArea <= toleranceM2,
      `${label} outer spike loop area ${removedArea} exceeds ${toleranceM2}`,
    );
    invariant(kept.length >= 3 && Math.abs(signedRingArea(kept)) > EPSILON, `${label} outer spike repair collapses the main ring`);
    repairs.push({
      repair_kind: "outer_spike_loop",
      polygon_index: polygonIndex,
      ring_role: ringRole,
      hole_index: holeIndex,
      intersection,
      intersecting_edges: [left, right],
      removed_vertices: removed,
      loop_area_m2: removedArea,
      reason: "boolean-created snapped road ribbon outer backtrack/spike loop",
    });
    ring = kept;
  }
  throw new Error(`${label} exceeds 100 outer-spike repairs`);
}

function repairRoadRibbonOuterSpikes(rawResult, toleranceM2, label) {
  const repairs = [];
  const geometry = rawResult.map((polygon, polygonIndex) => {
    const repaired = removeRoadOuterSpikeLoops(
      polygon[0],
      toleranceM2,
      `${label}[${polygonIndex}].outer`,
      polygonIndex,
      "outer",
      null,
    );
    repairs.push(...repaired.repairs);
    return [repaired.ring, ...polygon.slice(1)];
  });
  const removedArea = repairs.reduce((sum, repair) => sum + repair.loop_area_m2, 0);
  invariant(removedArea <= toleranceM2, `${label} total outer spike area exceeds quantization bound`);
  return { geometry, repairs, removed_area_m2: removedArea };
}

export function snapRoadRibbonAfterUnion(multiPolygon, label = "road ribbon") {
  const bound = serializedAreaTolerance(multiPolygon);
  const snapped = multiPolygon.map((polygon) => polygon.map((ring) =>
    ring.map((point) => point.map(roundCoordinate))));
  const outerRepair = repairRoadRibbonOuterSpikes(
    snapped,
    bound.tolerance_m2,
    `${label}/post-union-snap`,
  );
  const holeSpikeRepairs = [];
  const spikeRepairedGeometry = outerRepair.geometry.map((polygon, polygonIndex) => {
    const holes = polygon.slice(1).map((hole, holeIndex) => {
      const repaired = removeRoadOuterSpikeLoops(
        hole,
        bound.tolerance_m2,
        `${label}/post-union-snap[${polygonIndex}].hole[${holeIndex}]`,
        polygonIndex,
        "hole",
        holeIndex,
      );
      holeSpikeRepairs.push(...repaired.repairs.map((repair) => ({
        ...repair,
        repair_kind: "hole_spike_loop",
        reason: "boolean-created snapped road ribbon hole backtrack/spike loop",
      })));
      return repaired.ring;
    });
    return [polygon[0], ...holes];
  });
  const holeRepairs = [];
  const geometry = canonicalizeMultiPolygon(spikeRepairedGeometry, {
    label: `${label}/post-union-snap`,
    invalidHoleTolerance: bound.tolerance_m2,
    invalidHoleRemovals: holeRepairs,
  });
  const observedDelta = Math.abs(multiPolygonArea(geometry) - multiPolygonArea(multiPolygon));
  invariant(
    observedDelta <= bound.tolerance_m2,
    `${label} post-union snap/repair area delta ${observedDelta} exceeds ${bound.tolerance_m2}`,
  );
  return {
    geometry,
    snap_stage: "post_union",
    repairs: [...outerRepair.repairs, ...holeSpikeRepairs, ...holeRepairs],
    observed_area_delta_m2: observedDelta,
    tolerance_m2: bound.tolerance_m2,
    perimeter_m: bound.perimeter_m,
    quantization_delta_m: bound.delta_m,
  };
}

export function repairRoadRibbonQuantizationHoles(multiPolygon, label = "road ribbon") {
  const audit = snapRoadRibbonAfterUnion(multiPolygon, `${label}/clipped`);
  return {
    geometry: audit.geometry,
    removals: audit.repairs,
    resulting_area_delta_m2: audit.observed_area_delta_m2,
    tolerance_m2: audit.tolerance_m2,
    perimeter_m: audit.perimeter_m,
    quantization_delta_m: audit.quantization_delta_m,
    normalized_error: audit.observed_area_delta_m2 / audit.tolerance_m2,
  };
}

export function lineLength(line) {
  let length = 0;
  for (let index = 1; index < line.length; index += 1) {
    length += Math.hypot(
      line[index][0] - line[index - 1][0],
      line[index][1] - line[index - 1][1],
    );
  }
  return length;
}

export function intersectMultiPolygons(...multiPolygons) {
  invariant(multiPolygons.length >= 2, "Intersection needs at least two multipolygons");
  const result = polygonClipping.intersection(...multiPolygons.map(closeMultiPolygon));
  return canonicalizeMultiPolygon(result, { label: "intersection result", allowEmpty: true });
}

export function unionMultiPolygons(...multiPolygons) {
  const nonEmpty = multiPolygons.filter((multiPolygon) => multiPolygon.length > 0);
  if (nonEmpty.length === 0) return [];
  const result = polygonClipping.union(...nonEmpty.map(closeMultiPolygon));
  return canonicalizeMultiPolygon(result, { label: "union result", allowEmpty: true });
}

export function unionMultiPolygonsRaw(...multiPolygons) {
  const nonEmpty = multiPolygons.filter((multiPolygon) => multiPolygon.length > 0);
  if (nonEmpty.length === 0) return [];
  return polygonClipping.union(...nonEmpty.map(closeMultiPolygon));
}

export function differenceMultiPolygons(subject, ...clips) {
  if (subject.length === 0) return [];
  if (clips.length === 0 || clips.every((clip) => clip.length === 0)) return subject;
  const result = polygonClipping.difference(
    closeMultiPolygon(subject),
    ...clips.filter((clip) => clip.length > 0).map(closeMultiPolygon),
  );
  return canonicalizeMultiPolygon(result, { label: "difference result", allowEmpty: true });
}

export function lineRibbon(line, widthM, label = "line ribbon", options = {}) {
  const {
    snapPrimitives = false,
    repairQuantizationHoles = false,
    auditSink = null,
    returnRawUnion = false,
  } = options;
  invariant(Number.isFinite(widthM) && widthM > 0, `${label} has invalid width ${widthM}`);
  const radius = widthM / 2;
  const parts = [];
  for (let index = 1; index < line.length; index += 1) {
    const start = line[index - 1];
    const end = line[index];
    const deltaX = end[0] - start[0];
    const deltaY = end[1] - start[1];
    const length = Math.hypot(deltaX, deltaY);
    if (length <= EPSILON) continue;
    const normalX = (-deltaY / length) * radius;
    const normalY = (deltaX / length) * radius;
    const rectangle = [
      [start[0] + normalX, start[1] + normalY],
      [start[0] - normalX, start[1] - normalY],
      [end[0] - normalX, end[1] - normalY],
      [end[0] + normalX, end[1] + normalY],
    ];
    parts.push([[snapPrimitives
      ? rectangle.map((point) => point.map(roundCoordinate))
      : rectangle]]);
  }
  invariant(parts.length > 0, `${label} has no non-zero segment`);
  for (const vertex of line) {
    const circle = [];
    for (let index = 0; index < 12; index += 1) {
      const angle = (index * Math.PI * 2) / 12;
      circle.push([
        vertex[0] + Math.cos(angle) * radius,
        vertex[1] + Math.sin(angle) * radius,
      ]);
    }
    parts.push([[snapPrimitives
      ? circle.map((point) => point.map(roundCoordinate))
      : circle]]);
  }
  if (returnRawUnion) {
    invariant(!repairQuantizationHoles, `${label} raw union cannot also repair`);
    return polygonClipping.union(...parts.map(closeMultiPolygon));
  }
  if (!repairQuantizationHoles) return unionMultiPolygons(...parts);
  invariant(snapPrimitives, `${label} hole repair is limited to snapped road ribbons`);
  // A deterministic balanced fold limits each sweep's active segment set.
  // Primitive order is source centerline order and regular-gon order.
  let unionQueue = parts.map(closeMultiPolygon);
  while (unionQueue.length > 1) {
    const nextQueue = [];
    for (let index = 0; index < unionQueue.length; index += 2) {
      nextQueue.push(index + 1 < unionQueue.length
        ? polygonClipping.union(unionQueue[index], unionQueue[index + 1])
        : unionQueue[index]);
    }
    unionQueue = nextQueue;
  }
  const rawResult = unionQueue[0];
  const bound = serializedAreaTolerance(rawResult);
  const removals = [];
  const outerRepair = repairRoadRibbonOuterSpikes(
    rawResult,
    bound.tolerance_m2,
    `${label}/snapped-union`,
  );
  const geometry = canonicalizeMultiPolygon(outerRepair.geometry, {
    label: `${label}/snapped-union`,
    invalidHoleTolerance: bound.tolerance_m2,
    invalidHoleRemovals: removals,
  });
  const areaDelta = Math.abs(multiPolygonArea(geometry) - multiPolygonArea(rawResult));
  invariant(areaDelta <= bound.tolerance_m2, `${label} snapped union repair delta exceeds quantization bound`);
  auditSink?.push(...outerRepair.repairs, ...removals);
  return geometry;
}

export function rectangleMultiPolygon(minX, minY, maxX, maxY) {
  invariant(minX < maxX && minY < maxY, "Invalid rectangle bounds");
  return [[[[minX, minY], [maxX, minY], [maxX, maxY], [minX, maxY]]]];
}

export function multiPolygonBounds(multiPolygon) {
  invariant(multiPolygon.length > 0, "Cannot bound an empty multipolygon");
  const bounds = { min_x: Infinity, min_y: Infinity, max_x: -Infinity, max_y: -Infinity };
  for (const polygon of multiPolygon) {
    for (const ring of polygon) {
      for (const point of ring) {
        bounds.min_x = Math.min(bounds.min_x, point[0]);
        bounds.min_y = Math.min(bounds.min_y, point[1]);
        bounds.max_x = Math.max(bounds.max_x, point[0]);
        bounds.max_y = Math.max(bounds.max_y, point[1]);
      }
    }
  }
  return bounds;
}

function ringCentroid(ring) {
  let crossSum = 0;
  let xSum = 0;
  let ySum = 0;
  for (let index = 0; index < ring.length; index += 1) {
    const point = ring[index];
    const next = ring[(index + 1) % ring.length];
    const cross = point[0] * next[1] - next[0] * point[1];
    crossSum += cross;
    xSum += (point[0] + next[0]) * cross;
    ySum += (point[1] + next[1]) * cross;
  }
  invariant(Math.abs(crossSum) > EPSILON, "Cannot find centroid of zero-area ring");
  return { coordinate: [xSum / (3 * crossSum), ySum / (3 * crossSum)], signed_area: crossSum / 2 };
}

export function multiPolygonCentroid(multiPolygon) {
  let weightedX = 0;
  let weightedY = 0;
  let areaSum = 0;
  for (const polygon of multiPolygon) {
    for (const [index, ring] of polygon.entries()) {
      const centroid = ringCentroid(ring);
      const weight = (index === 0 ? 1 : -1) * Math.abs(centroid.signed_area);
      weightedX += centroid.coordinate[0] * weight;
      weightedY += centroid.coordinate[1] * weight;
      areaSum += weight;
    }
  }
  invariant(areaSum > EPSILON, "Cannot find centroid of empty multipolygon");
  return [weightedX / areaSum, weightedY / areaSum];
}

export function pointInRing(point, ring, includeBoundary = true) {
  let inside = false;
  for (let current = 0, previous = ring.length - 1; current < ring.length; previous = current, current += 1) {
    const a = ring[previous];
    const b = ring[current];
    if (pointOnSegment(point, a, b)) return includeBoundary;
    const crosses = (a[1] > point[1]) !== (b[1] > point[1]) &&
      point[0] < ((b[0] - a[0]) * (point[1] - a[1])) / (b[1] - a[1]) + a[0];
    if (crosses) inside = !inside;
  }
  return inside;
}

export function pointInMultiPolygon(point, multiPolygon, includeBoundary = true) {
  return multiPolygon.some((polygon) => {
    if (!pointInRing(point, polygon[0], includeBoundary)) return false;
    return polygon.slice(1).every((hole) => !pointInRing(point, hole, !includeBoundary));
  });
}

export function roundedCanonicalGeometry(multiPolygon, label = "geometry") {
  return roundingAreaAudit(multiPolygon, label).geometry;
}

export function roundingAreaAudit(multiPolygon, label = "geometry") {
  const beforeArea = multiPolygonArea(multiPolygon);
  const rounded = canonicalizeMultiPolygon(multiPolygon, { label, round: true });
  const afterArea = multiPolygonArea(rounded);
  const delta = Math.abs(afterArea - beforeArea);
  const bound = serializedAreaTolerance(multiPolygon);
  const tolerance = bound.tolerance_m2;
  invariant(
    delta <= tolerance,
    `${label} rounding changes area by ${delta} m2 (quantization tolerance ${tolerance})`,
  );
  return {
    geometry: rounded,
    before_area_m2: beforeArea,
    after_area_m2: afterArea,
    delta_m2: delta,
    tolerance_m2: tolerance,
    perimeter_m: bound.perimeter_m,
    quantization_delta_m: bound.delta_m,
    normalized_error: tolerance === 0 ? 0 : delta / tolerance,
  };
}

export function geometrySha256(multiPolygon) {
  return createHash("sha256")
    .update(stableJson(roundedCanonicalGeometry(multiPolygon, "geometry hash")))
    .digest("hex");
}

export function flattenMultiPolygonCoordinates(multiPolygon) {
  return multiPolygon.flatMap((polygon) => polygon.flatMap((ring) => ring));
}

export function exportOsmiumGeoJsonSeq(inputPath, outputPath) {
  const result = spawnSync("osmium", [
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
  ], { encoding: "utf8" });
  if (result.error) throw new Error(`Could not run osmium: ${result.error.message}`);
  invariant(result.status === 0, `osmium export failed: ${result.stderr.trim()}`);
}

function normalizedTimestamp(value) {
  if (typeof value === "number" || /^\d+$/u.test(String(value ?? ""))) {
    const milliseconds = Number(value) * 1000;
    if (Number.isFinite(milliseconds)) return new Date(milliseconds).toISOString().replace(".000Z", "Z");
  }
  return String(value ?? "");
}

function stableTags(properties) {
  return Object.fromEntries(
    Object.entries(properties ?? {})
      .filter(([key]) => !key.startsWith("@"))
      .sort(([left], [right]) => left.localeCompare(right)),
  );
}

export function parseGeoJsonSeq(path) {
  const sources = new Map();
  const lines = readFileSync(path, "utf8").split(/\r?\n/u);
  for (const [lineIndex, rawLine] of lines.entries()) {
    const line = rawLine.replace(/^\u001e/u, "").trim();
    if (!line) continue;
    const feature = JSON.parse(line);
    invariant(feature.type === "Feature", `Unexpected GeoJSON record ${lineIndex + 1}`);
    const properties = feature.properties ?? {};
    const prefix = { node: "n", way: "w", relation: "r" }[properties["@type"]];
    invariant(prefix && Number.isInteger(properties["@id"]), `Missing canonical OSM identity at GeoJSON record ${lineIndex + 1}`);
    const sourceKey = `${prefix}${properties["@id"]}`;
    const metadata = {
      osm_type: properties["@type"],
      osm_id: String(properties["@id"]),
      source_version: String(properties["@version"] ?? ""),
      source_timestamp: normalizedTimestamp(properties["@timestamp"]),
      tags: stableTags(properties),
    };
    const existing = sources.get(sourceKey) ?? { source_key: sourceKey, metadata, features: [] };
    invariant(
      stableJson(existing.metadata) === stableJson(metadata),
      `Conflicting exported metadata views for ${sourceKey}`,
    );
    if (feature.geometry != null) existing.features.push(feature.geometry);
    sources.set(sourceKey, existing);
  }
  return sources;
}

export function selectGeometry(source, family) {
  invariant(source, "Cannot select geometry from an absent source");
  const acceptedTypes = family === "area"
    ? new Set(["Polygon", "MultiPolygon"])
    : new Set(["LineString"]);
  const candidates = source.features.filter((geometry) => acceptedTypes.has(geometry.type));
  invariant(
    candidates.length === 1,
    `${source.source_key} expected exactly one ${family} view, found ${candidates.length}`,
  );
  return candidates[0];
}

function decodeXml(value) {
  return value
    .replaceAll("&quot;", '"')
    .replaceAll("&apos;", "'")
    .replaceAll("&lt;", "<")
    .replaceAll("&gt;", ">")
    .replaceAll("&amp;", "&")
    .replace(/&#(\d+);/gu, (_match, digits) => String.fromCodePoint(Number(digits)))
    .replace(/&#x([0-9a-f]+);/giu, (_match, digits) => String.fromCodePoint(Number.parseInt(digits, 16)));
}

function xmlAttributes(fragment) {
  const attributes = {};
  for (const match of fragment.matchAll(/([:\w-]+)="([^"]*)"/gu)) {
    attributes[match[1]] = decodeXml(match[2]);
  }
  return attributes;
}

function xmlTags(body) {
  const tags = {};
  for (const match of body.matchAll(/<tag\b([^>]*)\/>/gu)) {
    const attributes = xmlAttributes(match[1]);
    if (attributes.k != null && attributes.v != null) tags[attributes.k] = attributes.v;
  }
  return Object.fromEntries(Object.entries(tags).sort(([left], [right]) => left.localeCompare(right)));
}

export function parseRawOsmXml(path) {
  const xml = readFileSync(path, "utf8");
  const nodes = new Map();
  const ways = new Map();
  const relations = new Map();
  for (const match of xml.matchAll(/<node\b([^>]*)>/gu)) {
    const attributes = xmlAttributes(match[1]);
    invariant(attributes.id && attributes.lon && attributes.lat, "Malformed raw OSM node");
    nodes.set(attributes.id, {
      id: attributes.id,
      coordinate: [Number(attributes.lon), Number(attributes.lat)],
      metadata: {
        osm_type: "node",
        osm_id: attributes.id,
        source_version: String(attributes.version ?? ""),
        source_timestamp: String(attributes.timestamp ?? ""),
        tags: {},
      },
    });
  }
  for (const match of xml.matchAll(/<way\b([^>]*)>([\s\S]*?)<\/way>/gu)) {
    const attributes = xmlAttributes(match[1]);
    const nodeRefs = [...match[2].matchAll(/<nd\b([^>]*)\/>/gu)].map((nodeMatch) => xmlAttributes(nodeMatch[1]).ref);
    invariant(attributes.id && nodeRefs.every(Boolean), "Malformed raw OSM way");
    const tags = xmlTags(match[2]);
    ways.set(attributes.id, {
      id: attributes.id,
      node_refs: nodeRefs,
      tags,
      metadata: {
        osm_type: "way",
        osm_id: attributes.id,
        source_version: String(attributes.version ?? ""),
        source_timestamp: String(attributes.timestamp ?? ""),
        tags,
      },
    });
  }
  for (const match of xml.matchAll(/<relation\b([^>]*)>([\s\S]*?)<\/relation>/gu)) {
    const attributes = xmlAttributes(match[1]);
    const members = [...match[2].matchAll(/<member\b([^>]*)\/>/gu)].map((memberMatch) => xmlAttributes(memberMatch[1]));
    invariant(attributes.id && members.every((member) => member.type && member.ref != null), "Malformed raw OSM relation");
    const tags = xmlTags(match[2]);
    relations.set(attributes.id, {
      id: attributes.id,
      members,
      tags,
      metadata: {
        osm_type: "relation",
        osm_id: attributes.id,
        source_version: String(attributes.version ?? ""),
        source_timestamp: String(attributes.timestamp ?? ""),
        tags,
      },
    });
  }
  return { nodes, ways, relations };
}

export function rawWayLine(rawOsm, wayId) {
  const way = rawOsm.ways.get(String(wayId));
  invariant(way, `Raw OSM way ${wayId} is missing`);
  const coordinates = way.node_refs.map((nodeRef) => {
    const node = rawOsm.nodes.get(nodeRef);
    invariant(node, `Way ${wayId} references missing node ${nodeRef}`);
    return projectLonLat(node.coordinate);
  });
  const line = [];
  for (const coordinate of coordinates) {
    if (line.length === 0 || !samePoint(line.at(-1), coordinate)) line.push(coordinate);
  }
  invariant(line.length >= 2, `Raw OSM way ${wayId} has no non-zero segment`);
  return line;
}

export function rawWayFootprint(rawOsm, wayId, openWidthM = 8) {
  const way = rawOsm.ways.get(String(wayId));
  invariant(way, `Raw OSM way ${wayId} is missing`);
  const closed = way.node_refs.length >= 4 && way.node_refs[0] === way.node_refs.at(-1);
  const line = rawWayLine(rawOsm, wayId);
  if (closed) {
    return canonicalizeMultiPolygon([[line]], { label: `raw way w${wayId}` });
  }
  return lineRibbon(line, openWidthM, `raw way w${wayId}`);
}

export function rawSourceMetadata(rawOsm, sourceKey) {
  const collection = sourceKey[0] === "n"
    ? rawOsm.nodes
    : sourceKey[0] === "w"
      ? rawOsm.ways
      : sourceKey[0] === "r"
        ? rawOsm.relations
        : null;
  invariant(collection, `Invalid source key ${sourceKey}`);
  const source = collection.get(sourceKey.slice(1));
  invariant(source, `Raw OSM source ${sourceKey} is missing`);
  return source.metadata;
}
