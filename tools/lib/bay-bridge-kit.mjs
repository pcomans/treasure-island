// Mesh kit for the Bay Bridge scenery (tools/lib/bay-bridge-generation.mjs): one
// emitter for the whole bridge, cross-sections swept along an alignment, tapered
// prisms, wires, and the plan and profile helpers the parts share.
//
// The emitter writes the generated contract's mesh arrays in world coordinates
// (x east, y up, z = -north), triangles counterclockwise around their outward
// normals. Each vertex's UV carries the bridge's own data, which the runtime
// builder (game/scripts/world/bay_bridge_builder.gd) reads back: x the material
// role (BRIDGE_ROLES), y the detail class (BRIDGE_CLASSES).
//
// A wire is a straight ribbon of the member's true width: four fresh vertices in
// the fixed order [start - side, start + side, end + side, end - side] and the
// indices [0, 1, 2, 0, 2, 3], every normal the member's direction. The runtime
// recovers each member's centre line and radius from that order and draws it as
// a camera-facing strip at least a pixel or so wide, its opacity the share of
// that width the member really covers.

import earcut from "earcut";

import { invariant, roundCoordinate } from "./world-contract.mjs";
import { BRIDGE_CLASSES } from "./bay-bridge-design.mjs";

// --- Vectors ----------------------------------------------------------------------

export const sub = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
export const add = (a, b) => [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
export const scale = (a, s) => [a[0] * s, a[1] * s, a[2] * s];
export const dot = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
export const cross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
export const length = (a) => Math.hypot(a[0], a[1], a[2]);
export function unit(a) {
  const size = length(a);
  invariant(size > 1e-9, "Bay Bridge zero-length vector");
  return [a[0] / size, a[1] / size, a[2] / size];
}
export const lerp = (a, b, t) => a + (b - a) * t;

// Plan (east, north) at height y to world [x, y, z].
export const world = (east, north, y) => [east, y, -north];

// --- Emitter ----------------------------------------------------------------------

export class BridgeMesh {
  constructor() {
    this.vertices = [];
    this.normals = [];
    this.uvs = [];
    this.indices = [];
  }

  get vertexCount() {
    return this.vertices.length / 3;
  }

  vertex(position, normal, role, cls) {
    const index = this.vertices.length / 3;
    this.vertices.push(roundCoordinate(position[0]), roundCoordinate(position[1]), roundCoordinate(position[2]));
    this.normals.push(roundCoordinate(normal[0]), roundCoordinate(normal[1]), roundCoordinate(normal[2]));
    this.uvs.push(role, cls);
    return index;
  }

  position(index) {
    return this.vertices.slice(index * 3, index * 3 + 3);
  }

  // A triangle over emitted vertices, counterclockwise around `outward`; a sliver
  // left by rounding is dropped.
  triangle(a, b, c, outward) {
    const pa = this.position(a);
    const face = cross(sub(this.position(b), pa), sub(this.position(c), pa));
    if (length(face) / 2 <= 1e-6) return false;
    if (dot(face, outward) < 0) this.indices.push(a, c, b);
    else this.indices.push(a, b, c);
    return true;
  }

  // A flat convex polygon (corners in order round it) with its own vertices.
  face(corners, normal, role, cls) {
    const indices = corners.map((corner) => this.vertex(corner, normal, role, cls));
    for (let k = 1; k + 1 < indices.length; k += 1) this.triangle(indices[0], indices[k], indices[k + 1], normal);
  }

  // A quad (corners in order round it, nearly coplanar) shaded flat with the normal
  // of its diagonals, turned to face `outward`.
  quad(a, b, c, d, outward, role, cls) {
    let normal = cross(sub(c, a), sub(d, b));
    if (length(normal) <= 1e-9) return;
    normal = unit(normal);
    if (dot(normal, outward) < 0) normal = scale(normal, -1);
    this.face([a, b, c, d], normal, role, cls);
  }

  // A straight member drawn as a wire (see the header for the ribbon's layout).
  wire(start, end, radius, role, cls = BRIDGE_CLASSES.wire) {
    const direction = sub(end, start);
    if (length(direction) < 0.05) return;
    const tangent = unit(direction);
    const reference = Math.abs(tangent[1]) > 0.98 ? [1, 0, 0] : [0, 1, 0];
    const side = scale(unit(cross(tangent, reference)), radius);
    const corners = [sub(start, side), add(start, side), add(end, side), sub(end, side)];
    const first = this.vertexCount;
    for (const corner of corners) this.vertex(corner, tangent, role, cls);
    this.indices.push(first, first + 1, first + 2, first, first + 2, first + 3);
  }

  // A polyline of world points as consecutive wires.
  wirePath(points, radius, role, cls = BRIDGE_CLASSES.wire) {
    for (let k = 1; k < points.length; k += 1) this.wire(points[k - 1], points[k], radius, role, cls);
  }

  // Loops of plan points (each a closed ring, east/north, counterclockwise or not)
  // stacked at heights, joined by flat faces: a tapered prism, column or tower leg.
  // levels: [{ ring: [[east, north], ...], y }], every ring the same length.
  // capBottom / capTop close the ends.
  prism(levels, role, cls, { capBottom = false, capTop = true, roles = null } = {}) {
    invariant(levels.length >= 2, "Bay Bridge prism needs two levels");
    const count = levels[0].ring.length;
    invariant(levels.every((level) => level.ring.length === count), "Bay Bridge prism rings differ in length");
    const orientation = Math.sign(signedArea(levels[0].ring));
    invariant(orientation !== 0, "Bay Bridge prism ring has no area");
    for (let level = 1; level < levels.length; level += 1) {
      const lower = levels[level - 1];
      const upper = levels[level];
      for (let k = 0; k < count; k += 1) {
        const next = (k + 1) % count;
        const a = world(lower.ring[k][0], lower.ring[k][1], lower.y);
        const b = world(lower.ring[next][0], lower.ring[next][1], lower.y);
        const c = world(upper.ring[next][0], upper.ring[next][1], upper.y);
        const d = world(upper.ring[k][0], upper.ring[k][1], upper.y);
        // Outward in plan: to the right of a counterclockwise ring's edge.
        const edge = [lower.ring[next][0] - lower.ring[k][0], lower.ring[next][1] - lower.ring[k][1]];
        const outwardPlan = orientation > 0 ? [edge[1], -edge[0]] : [-edge[1], edge[0]];
        const outward = [outwardPlan[0], 0, -outwardPlan[1]];
        this.quad(a, b, c, d, outward, roles ? roles[k] : role, cls);
      }
    }
    if (capTop) this.capRing(levels.at(-1).ring, levels.at(-1).y, [0, 1, 0], role, cls);
    if (capBottom) this.capRing(levels[0].ring, levels[0].y, [0, -1, 0], role, cls);
  }

  capRing(ring, y, normal, role, cls) {
    const flat = ring.flatMap((point) => point);
    const triangles = earcut(flat, [], 2);
    const first = this.vertexCount;
    for (const point of ring) this.vertex(world(point[0], point[1], y), normal, role, cls);
    for (let k = 0; k < triangles.length; k += 3) {
      this.triangle(first + triangles[k], first + triangles[k + 1], first + triangles[k + 2], normal);
    }
  }

  // A box between two world points `start` and `end` (its axis), `width` across in
  // the horizontal and `depth` in the vertical plane of the axis (or, for a vertical
  // axis, `width` along plan x and `depth` along plan z).
  beam(start, end, width, depth, role, cls) {
    const axis = unit(sub(end, start));
    const reference = Math.abs(axis[1]) > 0.98 ? [0, 0, 1] : [0, 1, 0];
    const across = unit(cross(axis, reference));
    const up = unit(cross(across, axis));
    const corner = (point, s, t) => add(point, add(scale(across, s * width / 2), scale(up, t * depth / 2)));
    const signs = [[-1, -1], [1, -1], [1, 1], [-1, 1]];
    for (let k = 0; k < 4; k += 1) {
      const [s0, t0] = signs[k];
      const [s1, t1] = signs[(k + 1) % 4];
      const outward = unit(add(scale(across, s0 + s1), scale(up, t0 + t1)));
      this.quad(corner(start, s0, t0), corner(start, s1, t1), corner(end, s1, t1), corner(end, s0, t0), outward, role, cls);
    }
    this.face(signs.map(([s, t]) => corner(start, s, t)), scale(axis, -1), role, cls);
    this.face(signs.map(([s, t]) => corner(end, s, t)), axis, role, cls);
  }

  append(other) {
    const offset = this.vertexCount;
    for (const value of other.vertices) this.vertices.push(value);
    for (const value of other.normals) this.normals.push(value);
    for (const value of other.uvs) this.uvs.push(value);
    for (const index of other.indices) this.indices.push(index + offset);
  }

  toRecordMesh() {
    return { vertices: this.vertices, normals: this.normals, uvs: this.uvs, indices: this.indices };
  }
}

export function signedArea(ring) {
  let area = 0;
  for (let k = 0; k < ring.length; k += 1) {
    const a = ring[k];
    const b = ring[(k + 1) % ring.length];
    area += a[0] * b[1] - b[0] * a[1];
  }
  return area / 2;
}

// A plan rectangle centred on `center` with half sizes along `axis` (a unit plan
// vector) and across it, counterclockwise; `chamfer` cuts each corner.
export function planRectangle(center, axis, halfAlong, halfAcross, chamfer = 0) {
  const across = [-axis[1], axis[0]];
  const at = (a, c) => [center[0] + axis[0] * a + across[0] * c, center[1] + axis[1] * a + across[1] * c];
  if (chamfer <= 0) return [at(-halfAlong, -halfAcross), at(halfAlong, -halfAcross), at(halfAlong, halfAcross), at(-halfAlong, halfAcross)];
  const k = Math.min(chamfer, halfAlong * 0.9, halfAcross * 0.9);
  return [
    at(-halfAlong + k, -halfAcross), at(halfAlong - k, -halfAcross), at(halfAlong, -halfAcross + k), at(halfAlong, halfAcross - k),
    at(halfAlong - k, halfAcross), at(-halfAlong + k, halfAcross), at(-halfAlong, halfAcross - k), at(-halfAlong, -halfAcross + k),
  ];
}

// --- Cross-section sweep ----------------------------------------------------------

// Sweeps cross-sections along stations. Each station is { e, n, y, t: [te, tn] }:
// the plan point and deck-top height of the section's origin and the unit plan
// tangent. section(station, index) returns the same list of loops at every
// station: { points: [[u, v], ...] (u to the left of the tangent, v up from the
// deck top), roles: [one per segment], cls, closed, caps, skip: [segment indices
// left out] }. Each segment becomes a strip along the stations, shaded smoothly
// along its length and flat across it.
export function sweep(mesh, stations, section) {
  invariant(stations.length >= 2, "Bay Bridge sweep needs two stations");
  const shapes = stations.map((station, index) => section(station, index));
  const loopCount = shapes[0].length;
  invariant(shapes.every((loops) => loops.length === loopCount), "Bay Bridge sweep sections differ");
  for (let loopIndex = 0; loopIndex < loopCount; loopIndex += 1) {
    const template = shapes[0][loopIndex];
    const closed = template.closed !== false;
    const pointCount = template.points.length;
    invariant(shapes.every((loops) => loops[loopIndex].points.length === pointCount), "Bay Bridge sweep loop sizes differ");
    // Outward normals assume a counterclockwise loop in (u, v); a clockwise one flips.
    const orientation = closed ? Math.sign(signedArea(template.points)) : 1;
    invariant(orientation !== 0, "Bay Bridge sweep loop has no area");
    const segmentCount = closed ? pointCount : pointCount - 1;
    const skip = new Set(template.skip ?? []);
    const frames = stations.map((station) => frameAt(station));
    for (let segment = 0; segment < segmentCount; segment += 1) {
      if (skip.has(segment)) continue;
      const role = template.roles[segment];
      const ring = [];
      for (let index = 0; index < stations.length; index += 1) {
        const loop = shapes[index][loopIndex];
        const p0 = loop.points[segment];
        const p1 = loop.points[(segment + 1) % pointCount];
        const du = p1[0] - p0[0];
        const dv = p1[1] - p0[1];
        const size = Math.hypot(du, dv);
        const normal2 = size > 1e-9 ? [(dv / size) * orientation, (-du / size) * orientation] : [0, 1];
        if (template.normals) normal2.splice(0, 2, ...template.normals[segment]);
        const frame = frames[index];
        const normal = add(scale(frame.left, normal2[0]), scale(frame.up, normal2[1]));
        ring.push([
          mesh.vertex(frame.at(p0), normal, role, loop.cls),
          mesh.vertex(frame.at(p1), normal, role, loop.cls),
          normal,
        ]);
      }
      for (let index = 1; index < ring.length; index += 1) {
        const [a0, a1, n0] = ring[index - 1];
        const [b0, b1, n1] = ring[index];
        const outward = add(n0, n1);
        mesh.triangle(a0, a1, b1, outward);
        mesh.triangle(a0, b1, b0, outward);
      }
    }
    if (closed && template.caps !== false) {
      for (const [index, sign] of [[0, -1], [stations.length - 1, 1]]) {
        const loop = shapes[index][loopIndex];
        const frame = frames[index];
        const normal = scale(frame.forward, sign);
        const flat = loop.points.flatMap((point) => point);
        const triangles = earcut(flat, [], 2);
        const first = mesh.vertexCount;
        for (const point of loop.points) mesh.vertex(frame.at(point), normal, template.capRole ?? template.roles[0], loop.cls);
        for (let k = 0; k < triangles.length; k += 3) {
          mesh.triangle(first + triangles[k], first + triangles[k + 1], first + triangles[k + 2], normal);
        }
      }
    }
  }
}

// The world frame of a sweep station: forward along the plan tangent, left across
// it, up.
export function frameAt(station) {
  const forward = [station.t[0], 0, -station.t[1]];
  const left = [-station.t[1], 0, -station.t[0]];
  const up = [0, 1, 0];
  const origin = world(station.e, station.n, station.y);
  return {
    forward,
    left,
    up,
    at: ([u, v]) => [origin[0] + left[0] * u, origin[1] + v, origin[2] + left[2] * u],
  };
}

// --- Plan polylines ---------------------------------------------------------------

export function polylineLength(line) {
  let total = 0;
  for (let k = 1; k < line.length; k += 1) total += Math.hypot(line[k][0] - line[k - 1][0], line[k][1] - line[k - 1][1]);
  return total;
}

// Point and unit tangent at arc length s (clamped to the line).
export function pointAt(line, s) {
  let remaining = Math.max(0, s);
  for (let k = 1; k < line.length; k += 1) {
    const a = line[k - 1];
    const b = line[k];
    const size = Math.hypot(b[0] - a[0], b[1] - a[1]);
    if (size <= 1e-9) continue;
    if (remaining <= size || k === line.length - 1) {
      const t = Math.min(1, remaining / size);
      return { point: [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t], tangent: [(b[0] - a[0]) / size, (b[1] - a[1]) / size] };
    }
    remaining -= size;
  }
  invariant(false, "Bay Bridge polyline has no length");
  return null;
}

// Arc length of the point on the line nearest `point`, and its distance.
export function project(line, point) {
  let best = null;
  let total = 0;
  for (let k = 1; k < line.length; k += 1) {
    const a = line[k - 1];
    const b = line[k];
    const dx = b[0] - a[0];
    const dy = b[1] - a[1];
    const size2 = dx * dx + dy * dy;
    const size = Math.sqrt(size2);
    if (size2 > 0) {
      const t = Math.max(0, Math.min(1, ((point[0] - a[0]) * dx + (point[1] - a[1]) * dy) / size2));
      const distance = Math.hypot(point[0] - a[0] - dx * t, point[1] - a[1] - dy * t);
      if (best == null || distance < best.distance) best = { s: total + size * t, distance };
    }
    total += size;
  }
  return best;
}

// Evenly resampled, then smoothed with fixed ends: removes OSM node kinks.
export function smoothLine(line, step = 5, passes = 6) {
  const total = polylineLength(line);
  const count = Math.max(2, Math.ceil(total / step) + 1);
  let points = [];
  for (let k = 0; k < count; k += 1) points.push(pointAt(line, (total * k) / (count - 1)).point);
  for (let pass = 0; pass < passes; pass += 1) {
    const next = points.map((point) => [...point]);
    for (let k = 1; k + 1 < points.length; k += 1) {
      next[k] = [(points[k - 1][0] + 2 * points[k][0] + points[k + 1][0]) / 4, (points[k - 1][1] + 2 * points[k][1] + points[k + 1][1]) / 4];
    }
    points = next;
  }
  return points;
}

// Joins ways into one line (west to east), dropping repeated junction points.
export function joinLines(lines) {
  const joined = [];
  for (const line of lines) {
    for (const point of line) {
      if (joined.length > 0 && Math.hypot(point[0] - joined.at(-1)[0], point[1] - joined.at(-1)[1]) < 0.01) continue;
      joined.push(point);
    }
  }
  return joined;
}

// Extends a line straight on past its end by `extra` metres.
export function extendLine(line, extra) {
  const { tangent } = pointAt(line, polylineLength(line));
  const end = line.at(-1);
  return [...line, [end[0] + tangent[0] * extra, end[1] + tangent[1] * extra]];
}

export const leftOf = (tangent) => [-tangent[1], tangent[0]];
export const offsetPlan = (point, tangent, lateral) => [point[0] - tangent[1] * lateral, point[1] + tangent[0] * lateral];

// --- Profiles ---------------------------------------------------------------------

// A smooth profile through control points [[x, y], ...]: the piecewise-linear line,
// averaged over a window `blend` metres wide (so each break becomes a vertical
// curve), tabulated every metre. Constant beyond the ends.
export function smoothProfile(points, blend) {
  invariant(points.length >= 2 && points.every((point, k) => k === 0 || point[0] > points[k - 1][0]), "Bay Bridge profile points must increase");
  const linear = (x) => {
    if (x <= points[0][0]) return points[0][1];
    for (let k = 1; k < points.length; k += 1) {
      if (x <= points[k][0]) return lerp(points[k - 1][1], points[k][1], (x - points[k - 1][0]) / (points[k][0] - points[k - 1][0]));
    }
    return points.at(-1)[1];
  };
  const x0 = points[0][0];
  const x1 = points.at(-1)[0];
  const half = blend / 2;
  const table = [];
  for (let x = x0; x <= x1 + 1; x += 1) {
    let sum = 0;
    const samples = Math.max(1, Math.round(blend / 2));
    for (let k = 0; k <= samples; k += 1) sum += linear(Math.min(x1, Math.max(x0, x - half + (blend * k) / samples)));
    table.push(sum / (samples + 1));
  }
  // Keep the ends at their control values so joined profiles meet exactly.
  const startOffset = points[0][1] - table[0];
  const endOffset = points.at(-1)[1] - table[Math.round(x1 - x0)];
  return (x) => {
    const position = Math.min(x1 - x0, Math.max(0, x - x0));
    const index = Math.floor(position);
    const fraction = position - index;
    const value = lerp(table[index], table[Math.min(table.length - 1, index + 1)], fraction);
    return value + lerp(startOffset, endOffset, position / (x1 - x0));
  };
}

// A cubic from (x0, y0) with slope g0 to (x1, y1) with slope g1.
export function hermite(x0, y0, g0, x1, y1, g1) {
  const span = x1 - x0;
  return (x) => {
    const t = Math.min(1, Math.max(0, (x - x0) / span));
    const t2 = t * t;
    const t3 = t2 * t;
    return (2 * t3 - 3 * t2 + 1) * y0 + (t3 - 2 * t2 + t) * span * g0 + (-2 * t3 + 3 * t2) * y1 + (t3 - t2) * span * g1;
  };
}

// --- Ground -----------------------------------------------------------------------

// The height of a context mesh's upward faces at a plan point (null off the mesh):
// Yerba Buena Island's terrain as the generator builds it, so columns and roads meet
// the ground that is drawn.
export function meshGroundSampler(mesh, cellM = 16) {
  const buckets = new Map();
  const key = (i, j) => `${i},${j}`;
  for (let k = 0; k < mesh.indices.length; k += 3) {
    const corners = [0, 1, 2].map((m) => {
      const index = mesh.indices[k + m];
      return [mesh.vertices[index * 3], mesh.vertices[index * 3 + 1], -mesh.vertices[index * 3 + 2]];
    });
    // Upward faces only (the skirt down to the water is not ground).
    const ux = corners[1][0] - corners[0][0];
    const uz = corners[1][2] - corners[0][2];
    const vx = corners[2][0] - corners[0][0];
    const vz = corners[2][2] - corners[0][2];
    if (Math.abs(ux * vz - uz * vx) < 1e-6) continue;
    const minE = Math.min(...corners.map((c) => c[0]));
    const maxE = Math.max(...corners.map((c) => c[0]));
    const minN = Math.min(...corners.map((c) => c[2]));
    const maxN = Math.max(...corners.map((c) => c[2]));
    for (let i = Math.floor(minE / cellM); i <= Math.floor(maxE / cellM); i += 1) {
      for (let j = Math.floor(minN / cellM); j <= Math.floor(maxN / cellM); j += 1) {
        const bucket = buckets.get(key(i, j)) ?? [];
        bucket.push(corners);
        buckets.set(key(i, j), bucket);
      }
    }
  }
  return (east, north) => {
    const bucket = buckets.get(key(Math.floor(east / cellM), Math.floor(north / cellM)));
    if (!bucket) return null;
    let best = null;
    for (const [a, b, c] of bucket) {
      const det = (b[2] - c[2]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[2] - c[2]);
      const w0 = ((b[2] - c[2]) * (east - c[0]) + (c[0] - b[0]) * (north - c[2])) / det;
      const w1 = ((c[2] - a[2]) * (east - c[0]) + (a[0] - c[0]) * (north - c[2])) / det;
      const w2 = 1 - w0 - w1;
      if (w0 < -1e-7 || w1 < -1e-7 || w2 < -1e-7) continue;
      const height = w0 * a[1] + w1 * b[1] + w2 * c[1];
      if (best == null || height > best) best = height;
    }
    return best;
  };
}
