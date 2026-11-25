// Plan measures for tools/building_plan.mjs, in the game's plan frame: x east,
// z south (north is -z), metres. Pure functions; nothing here reads or writes
// files. A ring is an array of [x, z] points without a repeated closing point.
import { pointInRing, signedRingArea } from "./osm-geometry.mjs";

export const ON_LINE_M = 0.02; // a point this close to a line lies on it
const DEGREES = 180 / Math.PI;

export function ringArea(ring) {
  return Math.abs(signedRingArea(ring));
}

export function ringPerimeter(ring) {
  let total = 0;
  for (let index = 0; index < ring.length; index += 1) {
    const next = ring[(index + 1) % ring.length];
    total += Math.hypot(next[0] - ring[index][0], next[1] - ring[index][1]);
  }
  return total;
}

// Positive signed area in (x, z) is clockwise on a plan drawn north up.
export function orientRing(ring, clockwise = true) {
  return (signedRingArea(ring) > 0) === clockwise ? ring : [...ring].reverse();
}

export function dropClosingPoint(points) {
  const ring = [];
  for (const point of points) {
    if (ring.length === 0 || ring.at(-1)[0] !== point[0] || ring.at(-1)[1] !== point[1]) ring.push(point);
  }
  if (ring.length > 1 && ring[0][0] === ring.at(-1)[0] && ring[0][1] === ring.at(-1)[1]) ring.pop();
  return ring;
}

export function bounds(points) {
  const box = { minX: Infinity, minZ: Infinity, maxX: -Infinity, maxZ: -Infinity };
  for (const [x, z] of points) {
    box.minX = Math.min(box.minX, x);
    box.minZ = Math.min(box.minZ, z);
    box.maxX = Math.max(box.maxX, x);
    box.maxZ = Math.max(box.maxZ, z);
  }
  return box;
}

// Compass bearing of a direction in the plan frame: 0 north, 90 east.
export function bearingOf(dx, dz) {
  const bearing = Math.atan2(dx, -dz) * DEGREES;
  return bearing < 0 ? bearing + 360 : bearing;
}

export function lineBearing(dx, dz) {
  const bearing = bearingOf(dx, dz) % 180;
  return bearing >= 179.995 ? 0 : bearing;
}

function wrapDegrees(value) {
  let wrapped = value;
  while (wrapped <= -180) wrapped += 360;
  while (wrapped > 180) wrapped -= 360;
  return wrapped;
}

function cross(o, a, b) {
  return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
}

export function convexHull(points) {
  const sorted = [...points].sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  if (sorted.length < 3) return sorted;
  const lower = [];
  for (const point of sorted) {
    while (lower.length >= 2 && cross(lower.at(-2), lower.at(-1), point) <= 0) lower.pop();
    lower.push(point);
  }
  const upper = [];
  for (const point of [...sorted].reverse()) {
    while (upper.length >= 2 && cross(upper.at(-2), upper.at(-1), point) <= 0) upper.pop();
    upper.push(point);
  }
  return [...lower.slice(0, -1), ...upper.slice(0, -1)];
}

// The minimum-area rectangle round the points (rotating calipers over the
// hull): its long and short side, the bearing of the long side and its corners.
export function principalRectangle(points) {
  const hull = convexHull(points);
  let best = null;
  for (let index = 0; index < hull.length; index += 1) {
    const a = hull[index];
    const b = hull[(index + 1) % hull.length];
    const length = Math.hypot(b[0] - a[0], b[1] - a[1]);
    if (length < 1e-9) continue;
    const ux = (b[0] - a[0]) / length;
    const uz = (b[1] - a[1]) / length;
    let minU = Infinity;
    let maxU = -Infinity;
    let minV = Infinity;
    let maxV = -Infinity;
    for (const point of hull) {
      const u = point[0] * ux + point[1] * uz;
      const v = -point[0] * uz + point[1] * ux;
      minU = Math.min(minU, u);
      maxU = Math.max(maxU, u);
      minV = Math.min(minV, v);
      maxV = Math.max(maxV, v);
    }
    const area = (maxU - minU) * (maxV - minV);
    if (best == null || area < best.area - 1e-9) best = { area, ux, uz, minU, maxU, minV, maxV };
  }
  if (best == null) return null;
  const along = best.maxU - best.minU;
  const across = best.maxV - best.minV;
  const corner = (u, v) => [u * best.ux - v * best.uz, u * best.uz + v * best.ux];
  const corners = [
    corner(best.minU, best.minV),
    corner(best.maxU, best.minV),
    corner(best.maxU, best.maxV),
    corner(best.minU, best.maxV),
  ];
  const longAlong = along >= across;
  const longDirection = longAlong ? [best.ux, best.uz] : [-best.uz, best.ux];
  return {
    length: Math.max(along, across),
    width: Math.min(along, across),
    long_bearing: lineBearing(longDirection[0], longDirection[1]),
    corners,
  };
}

export function pointSegmentDistance(point, a, b) {
  const dx = b[0] - a[0];
  const dz = b[1] - a[1];
  const lengthSquared = dx * dx + dz * dz;
  let t = lengthSquared > 0 ? ((point[0] - a[0]) * dx + (point[1] - a[1]) * dz) / lengthSquared : 0;
  t = Math.max(0, Math.min(1, t));
  const qx = a[0] + t * dx;
  const qz = a[1] + t * dz;
  return Math.hypot(point[0] - qx, point[1] - qz);
}

// Every edge of the rings as [a, b] pairs, for distance queries.
export function ringSegments(rings) {
  const segments = [];
  for (const ring of rings) {
    for (let index = 0; index < ring.length; index += 1) segments.push([ring[index], ring[(index + 1) % ring.length]]);
  }
  return segments;
}

export function lineSegments(line) {
  const segments = [];
  for (let index = 1; index < line.length; index += 1) segments.push([line[index - 1], line[index]]);
  return segments;
}

export function distanceToSegments(point, segments) {
  let best = Infinity;
  for (const [a, b] of segments) {
    const distance = pointSegmentDistance(point, a, b);
    if (distance < best) best = distance;
  }
  return best;
}

// A polygon is { outer, holes }; a shape is an array of polygons.
export function pointInShape(point, shape) {
  return shape.some((polygon) => pointInRing(point, polygon.outer) &&
    polygon.holes.every((hole) => !pointInRing(point, hole)));
}

export function shapeRings(shape) {
  return shape.flatMap((polygon) => [polygon.outer, ...polygon.holes]);
}

export function shapeArea(shape) {
  return shape.reduce((total, polygon) =>
    total + ringArea(polygon.outer) - polygon.holes.reduce((sum, hole) => sum + ringArea(hole), 0), 0);
}

// Points every `step` metres along a ring's (or line's) edges, each standing for
// the length after it up to the next point.
export function sampleBoundary(points, step = 0.1, closed = true) {
  const samples = [];
  const edgeCount = closed ? points.length : points.length - 1;
  for (let edge = 0; edge < edgeCount; edge += 1) {
    const a = points[edge];
    const b = points[(edge + 1) % points.length];
    const length = Math.hypot(b[0] - a[0], b[1] - a[1]);
    if (length === 0) continue;
    const count = Math.max(1, Math.ceil(length / step));
    for (let index = 0; index < count; index += 1) {
      const t = index / count;
      samples.push({ point: [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t], weight: length / count, edge });
    }
  }
  return samples;
}

// Turn at each vertex in degrees: positive turns with the ring (a convex
// corner of a ring that runs clockwise on the plan), negative against it.
export function vertexTurns(ring) {
  const sign = Math.sign(signedRingArea(ring)) || 1;
  const turns = [];
  for (let index = 0; index < ring.length; index += 1) {
    const previous = ring[(index - 1 + ring.length) % ring.length];
    const point = ring[index];
    const next = ring[(index + 1) % ring.length];
    const before = Math.atan2(point[1] - previous[1], point[0] - previous[0]);
    const after = Math.atan2(next[1] - point[1], next[0] - point[0]);
    turns.push(sign * wrapDegrees((after - before) * DEGREES));
  }
  return turns;
}

// Least-squares circle through the points: an algebraic fit refined by
// Gauss-Newton on the radial distances. Null for nearly straight points.
export function fitCircle(points) {
  if (points.length < 3) return null;
  const meanX = points.reduce((sum, point) => sum + point[0], 0) / points.length;
  const meanZ = points.reduce((sum, point) => sum + point[1], 0) / points.length;
  const local = points.map((point) => [point[0] - meanX, point[1] - meanZ]);
  let suu = 0;
  let suv = 0;
  let svv = 0;
  let suuu = 0;
  let svvv = 0;
  let suvv = 0;
  let svuu = 0;
  for (const [u, v] of local) {
    suu += u * u;
    suv += u * v;
    svv += v * v;
    suuu += u * u * u;
    svvv += v * v * v;
    suvv += u * v * v;
    svuu += v * u * u;
  }
  const determinant = suu * svv - suv * suv;
  if (Math.abs(determinant) < 1e-12) return null;
  const rightU = (suuu + suvv) / 2;
  const rightV = (svvv + svuu) / 2;
  let cu = (rightU * svv - rightV * suv) / determinant;
  let cv = (suu * rightV - suv * rightU) / determinant;
  let radius = Math.sqrt(cu * cu + cv * cv + (suu + svv) / points.length);
  for (let iteration = 0; iteration < 50; iteration += 1) {
    // Gauss-Newton on r_i = |p_i - c| - R for (cu, cv, R).
    let a11 = 0; let a12 = 0; let a13 = 0; let a22 = 0; let a23 = 0; let a33 = 0;
    let b1 = 0; let b2 = 0; let b3 = 0;
    for (const [u, v] of local) {
      const distance = Math.hypot(u - cu, v - cv);
      if (distance < 1e-12) continue;
      const ju = -(u - cu) / distance;
      const jv = -(v - cv) / distance;
      const jr = -1;
      const residual = distance - radius;
      a11 += ju * ju; a12 += ju * jv; a13 += ju * jr; a22 += jv * jv; a23 += jv * jr; a33 += jr * jr;
      b1 -= ju * residual; b2 -= jv * residual; b3 -= jr * residual;
    }
    const det = a11 * (a22 * a33 - a23 * a23) - a12 * (a12 * a33 - a23 * a13) + a13 * (a12 * a23 - a22 * a13);
    if (Math.abs(det) < 1e-15) break;
    const du = (b1 * (a22 * a33 - a23 * a23) - a12 * (b2 * a33 - a23 * b3) + a13 * (b2 * a23 - a22 * b3)) / det;
    const dv = (a11 * (b2 * a33 - a23 * b3) - b1 * (a12 * a33 - a23 * a13) + a13 * (a12 * b3 - b2 * a13)) / det;
    const dr = (a11 * (a22 * b3 - b2 * a23) - a12 * (a12 * b3 - b2 * a13) + b1 * (a12 * a23 - a22 * a13)) / det;
    cu += du;
    cv += dv;
    radius += dr;
    if (Math.hypot(du, dv, dr) < 1e-10) break;
  }
  if (!Number.isFinite(radius) || radius <= 0 || radius > 1e4) return null;
  const errors = local.map(([u, v]) => Math.abs(Math.hypot(u - cu, v - cv) - radius));
  return {
    centre: [cu + meanX, cv + meanZ],
    radius,
    rms: Math.sqrt(errors.reduce((sum, error) => sum + error * error, 0) / errors.length),
    max: Math.max(...errors),
  };
}

// One centre shared by several point sets, each at its own radius (concentric
// arcs): least squares on the radial distances by Gauss-Newton from `start`.
export function fitConcentric(pointSets, start) {
  let centre = [...start];
  const meanDistance = (points) => points.reduce((sum, point) => sum + Math.hypot(point[0] - centre[0], point[1] - centre[1]), 0) / points.length;
  let radii = pointSets.map(meanDistance);
  const size = 2 + pointSets.length;
  for (let iteration = 0; iteration < 50; iteration += 1) {
    const normal = Array.from({ length: size }, () => new Array(size).fill(0));
    const right = new Array(size).fill(0);
    pointSets.forEach((points, set) => {
      for (const point of points) {
        const distance = Math.hypot(point[0] - centre[0], point[1] - centre[1]);
        if (distance < 1e-12) continue;
        const jacobian = new Array(size).fill(0);
        jacobian[0] = -(point[0] - centre[0]) / distance;
        jacobian[1] = -(point[1] - centre[1]) / distance;
        jacobian[2 + set] = -1;
        const residual = distance - radii[set];
        for (let row = 0; row < size; row += 1) {
          if (jacobian[row] === 0) continue;
          right[row] -= jacobian[row] * residual;
          for (let column = 0; column < size; column += 1) normal[row][column] += jacobian[row] * jacobian[column];
        }
      }
    });
    const step = solveLinear(normal, right);
    if (step == null) break;
    centre = [centre[0] + step[0], centre[1] + step[1]];
    radii = radii.map((radius, set) => radius + step[2 + set]);
    if (Math.hypot(...step) < 1e-10) break;
  }
  return {
    centre,
    radii,
    errors: pointSets.map((points, set) => {
      const errors = points.map((point) => Math.abs(Math.hypot(point[0] - centre[0], point[1] - centre[1]) - radii[set]));
      return { rms: Math.sqrt(errors.reduce((sum, error) => sum + error * error, 0) / errors.length), max: Math.max(...errors) };
    }),
  };
}

// Gaussian elimination with partial pivoting; null for a singular system.
function solveLinear(matrix, vector) {
  const size = vector.length;
  const rows = matrix.map((row, index) => [...row, vector[index]]);
  for (let column = 0; column < size; column += 1) {
    let pivot = column;
    for (let row = column + 1; row < size; row += 1) if (Math.abs(rows[row][column]) > Math.abs(rows[pivot][column])) pivot = row;
    if (Math.abs(rows[pivot][column]) < 1e-12) return null;
    [rows[column], rows[pivot]] = [rows[pivot], rows[column]];
    for (let row = column + 1; row < size; row += 1) {
      const factor = rows[row][column] / rows[column][column];
      for (let index = column; index <= size; index += 1) rows[row][index] -= factor * rows[column][index];
    }
  }
  const solution = new Array(size).fill(0);
  for (let row = size - 1; row >= 0; row -= 1) {
    let sum = rows[row][size];
    for (let index = row + 1; index < size; index += 1) sum -= rows[row][index] * solution[index];
    solution[row] = sum / rows[row][row];
  }
  return solution;
}

const ARC_MAX_TURN_DEGREES = 25; // a vertex turning more is a corner
const ARC_NEUTRAL_TURN_DEGREES = 0.5; // a turn this small fits either way
const ARC_MAX_EDGE_SPAN_DEGREES = 25; // an edge subtending more is a wall, not a facet
const ARC_MIN_SPAN_DEGREES = 10;
const ARC_MIN_EDGES = 3;
const STRAIGHT_JOIN_DEGREES = 1.5; // edges meeting at a smaller turn make one straight run
const ARC_TRIM_ERROR_M = 0.12; // a fit this good keeps its end vertices

// Traced map arcs wander a few decimetres about their circle; each fit's own
// error is reported beside it.
export function arcTolerance(radius) {
  return Math.min(0.5, Math.max(0.15, 0.01 * radius));
}

function arcFit(ring, startEdge, edgeCount) {
  const points = [];
  for (let index = 0; index <= edgeCount; index += 1) points.push(ring[(startEdge + index) % ring.length]);
  const fit = fitCircle(points);
  if (fit == null || fit.max > arcTolerance(fit.radius)) return null;
  let span = 0;
  for (let index = 1; index < points.length; index += 1) {
    const chord = Math.hypot(points[index][0] - points[index - 1][0], points[index][1] - points[index - 1][1]);
    const edgeSpan = 2 * Math.asin(Math.min(1, chord / (2 * fit.radius))) * DEGREES;
    if (edgeSpan > ARC_MAX_EDGE_SPAN_DEGREES) return null;
    span += edgeSpan;
  }
  return { ...fit, span, points };
}

// Splits a ring into straight runs and fitted arcs, numbered clockwise on the
// plan from its north-westernmost run start. Each run gives its length, ends,
// the interior angle at its start (90 a square corner, 270 a re-entrant one)
// and, for a straight run, its bearing and how far its vertices stray from the
// chord; for an arc, its circle (centre, radius), span and fit error.
export function ringRuns(inputRing) {
  // Start the search at the sharpest corner, so that no arc straddles the
  // ring's first vertex and gets split in two.
  const oriented = orientRing(inputRing, true);
  const orientedTurns = vertexTurns(oriented);
  let sharpest = 0;
  for (let index = 1; index < oriented.length; index += 1) {
    if (Math.abs(orientedTurns[index]) > Math.abs(orientedTurns[sharpest])) sharpest = index;
  }
  const ring = [...oriented.slice(sharpest), ...oriented.slice(0, sharpest)];
  const count = ring.length;
  const turns = vertexTurns(ring);
  const edgeInArc = new Array(count).fill(-1);
  const arcs = [];
  const arcLike = (vertex, sign) => {
    const turn = turns[vertex % count];
    if (Math.abs(turn) <= ARC_NEUTRAL_TURN_DEGREES) return true;
    return Math.abs(turn) <= ARC_MAX_TURN_DEGREES && Math.sign(turn) === sign;
  };
  // A candidate grows edge by edge from a start whose first inner vertex turns
  // gently and every inner vertex turns the same way; its longest stretch (the
  // earliest of equal length) whose points fit one circle is an arc.
  for (let start = 0; start < count; start += 1) {
    if (edgeInArc[start] >= 0) continue;
    const firstTurn = turns[(start + 1) % count];
    if (Math.abs(firstTurn) <= ARC_NEUTRAL_TURN_DEGREES || Math.abs(firstTurn) > ARC_MAX_TURN_DEGREES) continue;
    const sign = Math.sign(firstTurn);
    let edges = 1;
    while (edges < count - 1 && edgeInArc[(start + edges) % count] < 0 && arcLike(start + edges, sign)) edges += 1;
    let best = null;
    search: for (let take = edges; take >= ARC_MIN_EDGES; take -= 1) {
      for (let offset = 0; offset + take <= edges; offset += 1) {
        const first = (start + offset) % count;
        const fit = arcFit(ring, first, take);
        if (fit != null && fit.span >= ARC_MIN_SPAN_DEGREES) {
          best = { start: first, edges: take, fit, sign };
          break search;
        }
      }
    }
    if (best == null) continue;
    // An end vertex well off the circle (a corner where the curve meets a
    // straight wall) can bend a short fit to a wrong radius: drop it when that
    // cuts a poor fit's worst error by more than half.
    let trimmed = true;
    while (trimmed && best.edges > ARC_MIN_EDGES && best.fit.max > ARC_TRIM_ERROR_M) {
      trimmed = false;
      for (const shift of [0, 1]) {
        const first = (best.start + shift) % count;
        const fit = arcFit(ring, first, best.edges - 1);
        if (fit != null && fit.span >= ARC_MIN_SPAN_DEGREES && fit.max < 0.5 * best.fit.max) {
          best = { start: first, edges: best.edges - 1, fit, sign: best.sign };
          trimmed = true;
          break;
        }
      }
    }
    for (let index = 0; index < best.edges; index += 1) edgeInArc[(best.start + index) % count] = arcs.length;
    arcs.push(best);
  }
  const runs = [];
  let edge = 0;
  // Begin at a run boundary so no run wraps past the ring's first vertex.
  const boundary = (index) => {
    const previous = (index - 1 + count) % count;
    if (edgeInArc[index] >= 0 || edgeInArc[previous] >= 0) return edgeInArc[index] !== edgeInArc[previous];
    return Math.abs(turns[index]) > STRAIGHT_JOIN_DEGREES;
  };
  const starts = [];
  for (let index = 0; index < count; index += 1) if (boundary(index)) starts.push(index);
  if (starts.length === 0) starts.push(0);
  for (let startIndex = 0; startIndex < starts.length; startIndex += 1) {
    edge = starts[startIndex];
    const end = starts[(startIndex + 1) % starts.length];
    const edgeTotal = ((end - edge + count) % count) || count;
    const points = [];
    for (let index = 0; index <= edgeTotal; index += 1) points.push(ring[(edge + index) % count]);
    let length = 0;
    for (let index = 1; index < points.length; index += 1) {
      length += Math.hypot(points[index][0] - points[index - 1][0], points[index][1] - points[index - 1][1]);
    }
    const run = {
      first_vertex: edge,
      edges: edgeTotal,
      from: points[0],
      to: points.at(-1),
      length,
      corner: 180 - turns[edge],
      points,
    };
    if (edgeInArc[edge] >= 0) {
      const arc = arcs[edgeInArc[edge]];
      run.kind = "arc";
      run.centre = arc.fit.centre;
      run.radius = arc.fit.radius;
      run.span = arc.fit.span;
      run.fit_rms = arc.fit.rms;
      run.fit_max = arc.fit.max;
      run.concave = arc.sign < 0;
      run.from_bearing = bearingOf(points[0][0] - arc.fit.centre[0], points[0][1] - arc.fit.centre[1]);
      run.to_bearing = bearingOf(points.at(-1)[0] - arc.fit.centre[0], points.at(-1)[1] - arc.fit.centre[1]);
    } else {
      run.kind = "straight";
      run.bearing = bearingOf(run.to[0] - run.from[0], run.to[1] - run.from[1]);
      run.chord = Math.hypot(run.to[0] - run.from[0], run.to[1] - run.from[1]);
      run.deviation = Math.max(0, ...points.slice(1, -1).map((point) => pointSegmentDistance(point, run.from, run.to)));
    }
    runs.push(run);
  }
  // Number clockwise from the north-westernmost run start.
  let first = 0;
  for (let index = 1; index < runs.length; index += 1) {
    const [x, z] = runs[index].from;
    const [bestX, bestZ] = runs[first].from;
    if (z < bestZ - 1e-9 || (Math.abs(z - bestZ) <= 1e-9 && x < bestX)) first = index;
  }
  return [...runs.slice(first), ...runs.slice(0, first)].map((run, index) => ({ ...run, index: index + 1 }));
}

function segmentCrossing(a, b, c, d) {
  const r = [b[0] - a[0], b[1] - a[1]];
  const s = [d[0] - c[0], d[1] - c[1]];
  const denominator = r[0] * s[1] - r[1] * s[0];
  const ca = [c[0] - a[0], c[1] - a[1]];
  if (Math.abs(denominator) < 1e-12) {
    // Parallel: overlapping collinear edges touch.
    if (Math.abs(ca[0] * r[1] - ca[1] * r[0]) > 1e-9) return null;
    const lengthSquared = r[0] * r[0] + r[1] * r[1];
    const t0 = (ca[0] * r[0] + ca[1] * r[1]) / lengthSquared;
    const t1 = t0 + (s[0] * r[0] + s[1] * r[1]) / lengthSquared;
    const low = Math.max(0, Math.min(t0, t1));
    const high = Math.min(1, Math.max(t0, t1));
    return low <= high ? [a[0] + r[0] * low, a[1] + r[1] * low] : null;
  }
  const t = (ca[0] * s[1] - ca[1] * s[0]) / denominator;
  const u = (ca[0] * r[1] - ca[1] * r[0]) / denominator;
  if (t < -1e-12 || t > 1 + 1e-12 || u < -1e-12 || u > 1 + 1e-12) return null;
  return [a[0] + r[0] * t, a[1] + r[1] * t];
}

// Every place where two non-adjacent edges of a ring cross or touch.
export function selfIntersections(ring) {
  const found = [];
  const count = ring.length;
  for (let left = 0; left < count; left += 1) {
    for (let right = left + 1; right < count; right += 1) {
      if (right === left + 1 || (left === 0 && right === count - 1)) continue;
      const point = segmentCrossing(ring[left], ring[(left + 1) % count], ring[right], ring[(right + 1) % count]);
      if (point) found.push({ edges: [left, right], point });
    }
  }
  return found;
}

// The largest circle inside the polygon (outside its holes): its centre and
// radius, so twice the radius is the shape's greatest width. A grid search
// refined by a shrinking pattern search.
export function inscribedCircle(outer, holes = []) {
  const rings = [outer, ...holes];
  const segments = ringSegments(rings);
  const inside = (point) => pointInRing(point, outer) && holes.every((hole) => !pointInRing(point, hole));
  const clearance = (point) => (inside(point) ? distanceToSegments(point, segments) : -1);
  const area = ringArea(outer) - holes.reduce((sum, hole) => sum + ringArea(hole), 0);
  const perimeter = rings.reduce((sum, ring) => sum + ringPerimeter(ring), 0);
  const meanWidth = perimeter > 0 ? (2 * area) / perimeter : 0;
  const box = bounds(outer);
  let step = Math.min(Math.max(Math.sqrt(Math.max(area, 0)) / 150, 0.05), 0.5, Math.max(meanWidth / 4, 0.02));
  let best = { centre: [(box.minX + box.maxX) / 2, (box.minZ + box.maxZ) / 2], radius: -1 };
  for (let x = box.minX + step / 2; x < box.maxX; x += step) {
    for (let z = box.minZ + step / 2; z < box.maxZ; z += step) {
      const radius = clearance([x, z]);
      if (radius > best.radius) best = { centre: [x, z], radius };
    }
  }
  if (best.radius < 0) return { centre: best.centre, radius: 0 };
  while (step > 0.001) {
    step /= 2;
    let moved = true;
    while (moved) {
      moved = false;
      for (const [dx, dz] of [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]]) {
        const candidate = [best.centre[0] + dx * step, best.centre[1] + dz * step];
        const radius = clearance(candidate);
        if (radius > best.radius + 1e-9) {
          best = { centre: candidate, radius };
          moved = true;
        }
      }
    }
  }
  return best;
}

// Stretches of a closed sample sequence whose class stays the same, with their
// length and the largest value seen; a class change shorter than `minimum`
// joins the stretch around it.
export function stretches(samples, classify, valueOf, minimum = 0.5) {
  const runs = [];
  for (const sample of samples) {
    const cls = classify(sample);
    const value = valueOf(sample);
    const last = runs.at(-1);
    if (last && last.cls === cls) {
      last.length += sample.weight;
      last.to = sample.point;
      if (value > last.max) {
        last.max = value;
        last.at = sample.point;
      }
    } else {
      runs.push({ cls, length: sample.weight, max: value, at: sample.point, from: sample.point, to: sample.point });
    }
  }
  // `first` absorbs `second`, which follows it along the ring.
  const absorb = (first, second, sameClass) => {
    first.length += second.length;
    first.to = second.to;
    if (sameClass && second.max > first.max) {
      first.max = second.max;
      first.at = second.at;
    }
  };
  // `second` absorbs `first`, which comes before it.
  const absorbBefore = (second, first) => {
    second.length += first.length;
    second.from = first.from;
  };
  const joinEqualNeighbours = () => {
    for (let index = 0; runs.length > 1 && index < runs.length; index += 1) {
      const nextIndex = (index + 1) % runs.length;
      if (runs[nextIndex].cls !== runs[index].cls) continue;
      absorb(runs[index], runs[nextIndex], true);
      runs.splice(nextIndex, 1);
      index = -1;
    }
  };
  joinEqualNeighbours();
  // Fold short flickers into their longer neighbour, shortest first.
  while (runs.length > 1) {
    let shortest = -1;
    for (let index = 0; index < runs.length; index += 1) {
      if (runs[index].length < minimum && (shortest < 0 || runs[index].length < runs[shortest].length)) shortest = index;
    }
    if (shortest < 0) break;
    const previousIndex = (shortest - 1 + runs.length) % runs.length;
    const nextIndex = (shortest + 1) % runs.length;
    if (runs[previousIndex].length >= runs[nextIndex].length) absorb(runs[previousIndex], runs[shortest], false);
    else absorbBefore(runs[nextIndex], runs[shortest]);
    runs.splice(shortest, 1);
    joinEqualNeighbours();
  }
  return runs;
}
