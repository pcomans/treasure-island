// Shoreline riprap: the rock armour along the island edge, for the segments in
// the "shoreline" block of tools/config/street-detail-zones.json. Always-on
// ground, not a switchable street-detail layer.
//
// Almost the whole Treasure Island edge is OSM man_made=breakwater,
// material=rock. Each breakwater polygon straddles the island outline
// (w26767313): its part inside is the band from the crest to the outline, which
// the world builder drapes as a flat terrain overlay; its part outside is the
// slope down to the water, which the playable land (clipped at the outline)
// leaves open. For each configured segment this module
//   1. plans the inside band (planShoreline), which the world builder drapes as
//      a riprap terrain_overlay instead of the flat breakwater overlay. It has
//      no collision: land_ground stays the only support inside the outline, so
//      route QA, the regional anchors and boundary recovery are unchanged;
//   2. builds the outside slope and its boulders (generateShoreline) as
//      non-colliding visual geometry outside the playable land, like the Yerba
//      Buena context, for generated/world/shoreline.json.
//
// Plan geometry is east/north; records and placements use world x, y, z with
// z = -north. Every number in the config is production inference for game art
// (dated photos and the USGS DEM), not survey data.

import polygonClipping from "polygon-clipping";

import { rawWayFootprint } from "./osm-geometry.mjs";
import {
  CHUNK_SIZE_M,
  PLAYABLE_BOUNDARY_SOURCE_KEY,
  chunkId,
  invariant,
  roundCoordinate,
} from "./world-contract.mjs";

export const SHORELINE_SCHEMA = "ti.shoreline/1";
// The riprap overlay inside the outline and the material of the slope and boulders.
export const SHORELINE_OVERLAY_MATERIAL = "terrain_riprap";
export const SHORELINE_SLOPE_MATERIAL = "shoreline_riprap";
export const SHORELINE_DRIFTWOOD_MATERIAL = "shoreline_driftwood";
// The overlay's object key prefix: "<prefix>:<source key>:<chunk>".
export const SHORELINE_OVERLAY_PREFIX = "shoreline";
export const SHORELINE_BANDS = Object.freeze(["crest", "top", "slope", "toe", "driftwood"]);
// The game's water plane (world_root.tscn ContextWorld/Water).
export const WATER_Y_M = -0.12;
// How far the window around a segment reaches inland and out over the water.
const WINDOW_REACH_M = 40;
// Land vertices closer than this to the outline are land-edge breakpoints.
const EDGE_VERTEX_TOLERANCE_M = 0.003;
const MINIMUM_TRIANGLE_AREA_M2 = 1e-6;
const SAFE_ID = /^[a-z0-9_]+$/u;

const SHORELINE_FIELDS = ["boulders", "notes", "overlay_bias_m", "segments", "slope"];
const SLOPE_FIELDS = ["columns", "dem_fit_m", "end_cap_bottom_y_m", "gradient_m_per_m", "gradient_smoothing_m", "relief_m", "relief_wavelength_m", "section_m", "station_m", "toe_y_m", "top_blend_m"];
const BOULDER_FIELDS = ["crest", "driftwood", "pier_clearance_m", "prototypes", "slope", "toe", "top", "visibility_range_m"];
const BAND_FIELDS = {
  crest: ["acceptance", "inset_m", "protrude_m", "size_m", "spacing_m"],
  top: ["acceptance", "out_m", "rise_m", "size_m", "spacing_m"],
  slope: ["acceptance", "cell_m", "embed", "size_m"],
  toe: ["acceptance", "size_m", "spacing_m", "submerge"],
  driftwood: ["acceptance", "band_y_m", "length_m", "spacing_m"],
};
const SEGMENT_FIELDS = ["id", "outline_source_key", "reason", "reference", "s_m", "source_key"];

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

function exactKeys(value, keys, label) {
  invariant(value != null && typeof value === "object" && !Array.isArray(value), `${label} must be an object`);
  invariant(JSON.stringify(Object.keys(value).sort()) === JSON.stringify([...keys].sort()), `${label} must define exactly ${[...keys].sort().join(", ")}`);
}

function isRange(value, minimum = -Infinity) {
  return Array.isArray(value) && value.length === 2 && value.every(isFiniteNumber) && value[0] >= minimum && value[0] <= value[1];
}

// The validated "shoreline" block of the street-detail zones config.
export function shorelineSettings(config) {
  const shoreline = config.shoreline;
  invariant(shoreline != null, "Street detail config needs a shoreline block");
  exactKeys(shoreline, SHORELINE_FIELDS, "Shoreline config");
  invariant(Array.isArray(shoreline.notes) && shoreline.notes.every((note) => typeof note === "string"), "Shoreline notes must be strings");
  invariant(isFiniteNumber(shoreline.overlay_bias_m) && shoreline.overlay_bias_m > 0.05 && shoreline.overlay_bias_m < 0.078,
    "Shoreline overlay_bias_m must lie above the area overlays (0.05 m) and under the paths (0.078 m)");
  const slope = shoreline.slope;
  exactKeys(slope, SLOPE_FIELDS, "Shoreline slope");
  for (const key of ["station_m", "relief_wavelength_m", "top_blend_m", "section_m", "gradient_smoothing_m"]) {
    invariant(isFiniteNumber(slope[key]) && slope[key] > 0, `Shoreline slope.${key} must be positive`);
  }
  invariant(Number.isInteger(slope.columns) && slope.columns >= 4 && slope.columns <= 64, "Shoreline slope.columns must be an integer in [4, 64]");
  invariant(isRange(slope.gradient_m_per_m, 0.1) && slope.gradient_m_per_m[1] <= 1.0, "Shoreline slope.gradient_m_per_m must be [low, high] in (0.1, 1]");
  invariant(isRange(slope.dem_fit_m, 0) && slope.dem_fit_m[1] > slope.dem_fit_m[0], "Shoreline slope.dem_fit_m must be [near, far]");
  invariant(isFiniteNumber(slope.toe_y_m) && slope.toe_y_m < WATER_Y_M, "Shoreline slope.toe_y_m must lie under the water plane");
  invariant(isFiniteNumber(slope.end_cap_bottom_y_m) && slope.end_cap_bottom_y_m < slope.toe_y_m, "Shoreline end caps must reach below the toe");
  invariant(isFiniteNumber(slope.relief_m) && slope.relief_m >= 0 && slope.relief_m < 0.5, "Shoreline slope.relief_m must be in [0, 0.5)");
  const boulders = shoreline.boulders;
  exactKeys(boulders, BOULDER_FIELDS, "Shoreline boulders");
  invariant(Number.isInteger(boulders.prototypes) && boulders.prototypes >= 4 && boulders.prototypes <= 6, "Shoreline boulders.prototypes must be 4-6 rock shapes");
  invariant(isFiniteNumber(boulders.pier_clearance_m) && boulders.pier_clearance_m >= 0, "Shoreline boulders.pier_clearance_m must be non-negative");
  invariant(isFiniteNumber(boulders.visibility_range_m) && boulders.visibility_range_m > 50, "Shoreline boulders.visibility_range_m must exceed 50 m");
  for (const [band, keys] of Object.entries(BAND_FIELDS)) {
    const rule = boulders[band];
    exactKeys(rule, keys, `Shoreline boulders.${band}`);
    invariant(isFiniteNumber(rule.acceptance) && rule.acceptance > 0 && rule.acceptance <= 1, `Shoreline boulders.${band}.acceptance must be in (0, 1]`);
    for (const key of keys) {
      if (key === "acceptance") continue;
      const value = rule[key];
      invariant(isFiniteNumber(value) ? value > 0 : isRange(value, 0), `Shoreline boulders.${band}.${key} must be positive or a [low, high] range`);
    }
  }
  invariant(Array.isArray(shoreline.segments) && shoreline.segments.length > 0, "Shoreline needs at least one segment");
  const ids = new Set();
  for (const segment of shoreline.segments) {
    exactKeys(segment, SEGMENT_FIELDS, `Shoreline segment ${segment?.id}`);
    invariant(typeof segment.id === "string" && SAFE_ID.test(segment.id) && !ids.has(segment.id), `Shoreline segment ${segment.id} needs a unique lower_snake id`);
    ids.add(segment.id);
    invariant(segment.outline_source_key === PLAYABLE_BOUNDARY_SOURCE_KEY, `Shoreline segment ${segment.id} must run along the island outline ${PLAYABLE_BOUNDARY_SOURCE_KEY}`);
    invariant(/^w\d+$/u.test(segment.source_key), `Shoreline segment ${segment.id} needs an OSM breakwater way source_key`);
    invariant(isRange(segment.s_m, 0) && segment.s_m[1] - segment.s_m[0] >= 10, `Shoreline segment ${segment.id} s_m must be [start, end] at least 10 m apart`);
    for (const field of ["reason", "reference"]) {
      invariant(typeof segment[field] === "string" && segment[field].trim() !== "", `Shoreline segment ${segment.id} needs ${field}`);
    }
  }
  return shoreline;
}

// ---------------------------------------------------------------- 2D helpers

const sub = (a, b) => [a[0] - b[0], a[1] - b[1]];
const add = (a, b) => [a[0] + b[0], a[1] + b[1]];
const scale = (a, s) => [a[0] * s, a[1] * s];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1];
const cross = (a, b) => a[0] * b[1] - a[1] * b[0];
const length = (a) => Math.hypot(a[0], a[1]);

function unit(a) {
  const l = length(a);
  invariant(l > 1e-12, "Cannot normalize a zero vector");
  return [a[0] / l, a[1] / l];
}

function ringArea(ring) {
  let doubled = 0;
  for (let index = 0; index < ring.length; index += 1) doubled += cross(ring[index], ring[(index + 1) % ring.length]);
  return doubled / 2;
}

function openRing(ring) {
  const same = ring.length > 1 && ring[0][0] === ring.at(-1)[0] && ring[0][1] === ring.at(-1)[1];
  return same ? ring.slice(0, -1) : ring.slice();
}

function multiArea(multi) {
  let total = 0;
  for (const polygon of multi) {
    polygon.forEach((ring, index) => {
      total += (index === 0 ? 1 : -1) * Math.abs(ringArea(openRing(ring)));
    });
  }
  return total;
}

function pointInRing(point, ring) {
  let inside = false;
  for (let index = 0, previous = ring.length - 1; index < ring.length; previous = index, index += 1) {
    const a = ring[index];
    const b = ring[previous];
    if ((a[1] > point[1]) !== (b[1] > point[1]) && point[0] < ((b[0] - a[0]) * (point[1] - a[1])) / (b[1] - a[1]) + a[0]) inside = !inside;
  }
  return inside;
}

function pointInMulti(multi, point) {
  return multi.some((polygon) => pointInRing(point, openRing(polygon[0])) && !polygon.slice(1).some((hole) => pointInRing(point, openRing(hole))));
}

function distanceToSegment(point, a, b) {
  const delta = sub(b, a);
  const span = dot(delta, delta);
  const t = span > 0 ? Math.max(0, Math.min(1, dot(sub(point, a), delta) / span)) : 0;
  return length(sub(point, add(a, scale(delta, t))));
}

function distanceToMultiEdges(multi, point) {
  let best = Infinity;
  for (const polygon of multi) {
    for (const raw of polygon) {
      const ring = openRing(raw);
      for (let index = 0; index < ring.length; index += 1) best = Math.min(best, distanceToSegment(point, ring[index], ring[(index + 1) % ring.length]));
    }
  }
  return best;
}

function guarded(label, operation) {
  try {
    return operation();
  } catch (error) {
    throw new Error(`Shoreline ${label} boolean failed: ${error.message}`, { cause: error });
  }
}

// ---------------------------------------------------------------- randomness

// FNV-1a over a string, then a mulberry32 stream: deterministic, fast, and the
// same in every run.
function hashString(text) {
  let hash = 0x811c9dc5;
  for (let index = 0; index < text.length; index += 1) {
    hash ^= text.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193) >>> 0;
  }
  return hash >>> 0;
}

function random(seed, identity) {
  let state = hashString(`${seed}|${identity}`) || 0x9e3779b9;
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = state;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function lerp(a, b, t) {
  return a + (b - a) * t;
}

function smoothstep(edge0, edge1, value) {
  const t = Math.max(0, Math.min(1, (value - edge0) / (edge1 - edge0)));
  return t * t * (3 - 2 * t);
}

// Lattice hash in [0, 1) for integer cell coordinates.
function cellHash(seed, x, y, salt) {
  let h = Math.imul(x | 0, 0x27d4eb2d) ^ Math.imul(y | 0, 0x165667b1) ^ Math.imul(salt | 0, 0x3c6ef372) ^ seed;
  h = Math.imul(h ^ (h >>> 15), 0x85ebca6b);
  h = Math.imul(h ^ (h >>> 13), 0xc2b2ae35);
  return ((h ^ (h >>> 16)) >>> 0) / 4294967296;
}

// Boulder-scale relief in about [-1, 1]: rounded domes on a jittered cell grid
// (inverse distance to the nearest cell point) plus a little value noise.
function rockRelief(seed, east, north, wavelength) {
  const x = east / wavelength;
  const y = north / wavelength;
  const cx = Math.floor(x);
  const cy = Math.floor(y);
  let nearest = Infinity;
  let second = Infinity;
  for (let dx = -1; dx <= 1; dx += 1) {
    for (let dy = -1; dy <= 1; dy += 1) {
      const px = cx + dx + 0.15 + 0.7 * cellHash(seed, cx + dx, cy + dy, 1);
      const py = cy + dy + 0.15 + 0.7 * cellHash(seed, cx + dx, cy + dy, 2);
      const distance = Math.hypot(x - px, y - py);
      if (distance < nearest) {
        second = nearest;
        nearest = distance;
      } else if (distance < second) {
        second = distance;
      }
    }
  }
  // Domes rise over each cell point and drop into the cracks between them.
  const dome = Math.min(1, second - nearest) * 1.6 - 0.55;
  const fx = x * 2.7 - Math.floor(x * 2.7);
  const fy = y * 2.7 - Math.floor(y * 2.7);
  const ix = Math.floor(x * 2.7);
  const iy = Math.floor(y * 2.7);
  const u = fx * fx * (3 - 2 * fx);
  const v = fy * fy * (3 - 2 * fy);
  const value = lerp(lerp(cellHash(seed, ix, iy, 3), cellHash(seed, ix + 1, iy, 3), u), lerp(cellHash(seed, ix, iy + 1, 3), cellHash(seed, ix + 1, iy + 1, 3), u), v);
  return Math.max(-1, Math.min(1, dome * 0.8 + (value - 0.5) * 0.5));
}

// ---------------------------------------------------------------- 3D helpers

const sub3 = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
const add3 = (a, b) => [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
const scale3 = (a, s) => [a[0] * s, a[1] * s, a[2] * s];
const dot3 = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
const cross3 = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
const length3 = (a) => Math.hypot(a[0], a[1], a[2]);

function unit3(a) {
  const l = length3(a);
  invariant(l > 1e-12, "Cannot normalize a zero 3D vector");
  return [a[0] / l, a[1] / l, a[2] / l];
}

function round4(value) {
  const rounded = Math.round(value * 10000) / 10000;
  return Object.is(rounded, -0) ? 0 : rounded;
}

// Appends one triangle wound counterclockwise around desiredNormal (the
// generated-world convention; the runtime turns it clockwise for Godot).
function pushTriangle(mesh, indices, desiredNormal) {
  const vertex = (index) => mesh.vertices.slice(index * 3, index * 3 + 3);
  let [a, b, c] = indices;
  const normal = cross3(sub3(vertex(b), vertex(a)), sub3(vertex(c), vertex(a)));
  if (length3(normal) / 2 < MINIMUM_TRIANGLE_AREA_M2) return false;
  if (dot3(normal, desiredNormal) < 0) [b, c] = [c, b];
  mesh.indices.push(a, b, c);
  return true;
}

function pushVertex(mesh, position, normal) {
  const index = mesh.vertices.length / 3;
  mesh.vertices.push(...position.map(roundCoordinate));
  mesh.normals.push(...normal.map(round4));
  return index;
}

// Convex hull of a few points in general position: every triple whose plane
// keeps all other points on one side is a face, wound outward.
function convexHull3(points) {
  const faces = [];
  const n = points.length;
  for (let i = 0; i < n; i += 1) {
    for (let j = i + 1; j < n; j += 1) {
      for (let k = j + 1; k < n; k += 1) {
        const normal = cross3(sub3(points[j], points[i]), sub3(points[k], points[i]));
        if (length3(normal) < 1e-9) continue;
        let above = 0;
        let below = 0;
        for (let m = 0; m < n; m += 1) {
          if (m === i || m === j || m === k) continue;
          const side = dot3(normal, sub3(points[m], points[i]));
          if (side > 1e-9) above += 1;
          else if (side < -1e-9) below += 1;
        }
        if (above === 0) faces.push([i, j, k]);
        else if (below === 0) faces.push([i, k, j]);
      }
    }
  }
  return faces;
}

// One low-poly quarry stone: the hull of a few points on a squashed ellipsoid,
// a couple of them pulled toward cut planes so the stone has broad broken
// faces. Normalized to 1 m across, its bottom at y = 0, facet normals rounded
// halfway toward the centre: weathered, not crisply cut, and shaded faces are
// not black.
function rockPrototype(seed, index) {
  const rng = random(seed, `rock:${index}`);
  const count = 12 + (index % 3) * 2;
  const axes = [1.0, 0.5 + 0.22 * rng(), 0.68 + 0.26 * rng()];
  const cuts = [0, 1, 2].map(() => {
    const theta = rng() * Math.PI * 2;
    const phi = (rng() - 0.35) * 1.2;
    return { normal: [Math.cos(theta) * Math.cos(phi), Math.sin(phi), Math.sin(theta) * Math.cos(phi)], offset: 0.55 + 0.25 * rng() };
  });
  const points = [];
  for (let k = 0; k < count; k += 1) {
    const z = rng() * 2 - 1;
    const theta = rng() * Math.PI * 2;
    const r = Math.sqrt(1 - z * z);
    let p = [r * Math.cos(theta), z, r * Math.sin(theta)];
    const radius = 0.82 + 0.18 * rng();
    p = [p[0] * axes[0] * radius, p[1] * axes[1] * radius, p[2] * axes[2] * radius];
    for (const cut of cuts) {
      const excess = dot3(p, cut.normal) - cut.offset * length3([axes[0] * cut.normal[0], axes[1] * cut.normal[1], axes[2] * cut.normal[2]]);
      if (excess > 0) p = sub3(p, scale3(cut.normal, excess * 0.85));
    }
    points.push(p);
  }
  // A flatter base: the lowest points are lifted toward a common bed.
  const lowest = Math.min(...points.map((p) => p[1]));
  for (const p of points) if (p[1] < lowest + axes[1] * 0.35) p[1] = lerp(p[1], lowest + axes[1] * 0.18, 0.6);
  const faces = convexHull3(points);
  invariant(faces.length >= 12, `Rock prototype ${index} hull is degenerate`);
  const min = [0, 1, 2].map((axis) => Math.min(...points.map((p) => p[axis])));
  const max = [0, 1, 2].map((axis) => Math.max(...points.map((p) => p[axis])));
  const across = Math.max(max[0] - min[0], max[2] - min[2]);
  const center = [(min[0] + max[0]) / 2, min[1], (min[2] + max[2]) / 2];
  const placed = points.map((p) => scale3(sub3(p, center), 1 / across));
  const centroid = scale3(placed.reduce((sum, p) => add3(sum, p), [0, 0, 0]), 1 / placed.length);
  const mesh = { vertices: [], normals: [], indices: [] };
  for (const face of faces) {
    const corners = face.map((i) => placed[i]);
    const faceNormal = unit3(cross3(sub3(corners[1], corners[0]), sub3(corners[2], corners[0])));
    const indices = corners.map((corner) => pushVertex(mesh, corner, unit3(add3(scale3(faceNormal, 0.5), scale3(unit3(sub3(corner, centroid)), 0.5)))));
    pushTriangle(mesh, indices, faceNormal);
  }
  const height = (max[1] - min[1]) / across;
  return { id: `rock_${index}`, material_key: SHORELINE_SLOPE_MATERIAL, size_m: [1, round4(height), round4((max[2] - min[2]) / across)], ...mesh };
}

// One bleached driftwood log, 2.4 m long along +x with a slight bend, lying
// with its axis at y = radius.
function driftwoodPrototype() {
  const mesh = { vertices: [], normals: [], indices: [] };
  const sides = 7;
  const stations = [[-1.2, 0.09], [-0.35, 0.115], [0.4, 0.105], [1.2, 0.075]];
  const bend = (x) => 0.05 * Math.cos((x / 1.2) * Math.PI * 0.5);
  const rings = stations.map(([x, radius]) => {
    const ring = [];
    for (let k = 0; k < sides; k += 1) {
      const angle = (k / sides) * Math.PI * 2;
      ring.push([x, 0.11 + Math.sin(angle) * radius, bend(x) + Math.cos(angle) * radius]);
    }
    return ring;
  });
  for (let s = 0; s + 1 < rings.length; s += 1) {
    for (let k = 0; k < sides; k += 1) {
      const a = rings[s][k];
      const b = rings[s][(k + 1) % sides];
      const c = rings[s + 1][(k + 1) % sides];
      const d = rings[s + 1][k];
      const middle = scale3(add3(add3(a, b), add3(c, d)), 0.25);
      const axisPoint = [middle[0], 0.11, bend(middle[0])];
      const outward = unit3(sub3(middle, axisPoint));
      const corner = (p) => pushVertex(mesh, p, unit3(sub3(p, [p[0], 0.11, bend(p[0])])));
      const quad = [a, b, c, d].map(corner);
      pushTriangle(mesh, [quad[0], quad[1], quad[2]], outward);
      pushTriangle(mesh, [quad[0], quad[2], quad[3]], outward);
    }
  }
  for (const [ring, normal] of [[rings[0], [-1, 0, 0]], [rings.at(-1), [1, 0, 0]]]) {
    const center = scale3(ring.reduce((sum, p) => add3(sum, p), [0, 0, 0]), 1 / ring.length);
    const centerIndex = pushVertex(mesh, center, normal);
    const indices = ring.map((p) => pushVertex(mesh, p, normal));
    for (let k = 0; k < sides; k += 1) pushTriangle(mesh, [centerIndex, indices[k], indices[(k + 1) % sides]], normal);
  }
  return { id: "driftwood", material_key: SHORELINE_DRIFTWOOD_MATERIAL, size_m: [2.4, 0.23, 0.33], ...mesh };
}

// A basis (columns x, y, z) whose y axis is `up`, turned by yaw about it, with
// the given per-axis scale.
function placementBasis(up, yaw, scales) {
  const reference = Math.abs(up[1]) < 0.99 ? [0, 1, 0] : [1, 0, 0];
  let xAxis = unit3(cross3(up, reference));
  if (Math.abs(up[1]) >= 0.99) xAxis = [1, 0, 0];
  else xAxis = unit3(cross3([0, 0, 1], up)[0] === 0 && cross3([0, 0, 1], up)[2] === 0 ? [1, 0, 0] : cross3(up, [0, 0, -1]));
  // Make x horizontal-ish: project world x onto the plane normal to up.
  const worldX = [1, 0, 0];
  const projected = sub3(worldX, scale3(up, dot3(worldX, up)));
  xAxis = length3(projected) > 1e-6 ? unit3(projected) : unit3(cross3(up, [0, 0, 1]));
  const zAxis = unit3(cross3(xAxis, up));
  const cosine = Math.cos(yaw);
  const sine = Math.sin(yaw);
  const x = add3(scale3(xAxis, cosine), scale3(zAxis, -sine));
  const z = add3(scale3(xAxis, sine), scale3(zAxis, cosine));
  return [scale3(x, scales[0]), scale3(up, scales[1]), scale3(z, scales[2])];
}

// ---------------------------------------------------------------- outline

function outlineOf(boundary) {
  invariant(boundary.length === 1, "Shoreline expects a single island polygon");
  const ring = openRing(boundary[0][0]);
  invariant(ringArea(ring) > 0, "The island outline must run counterclockwise (land on its left)");
  const cumulative = [0];
  for (let index = 1; index <= ring.length; index += 1) {
    cumulative.push(cumulative[index - 1] + length(sub(ring[index % ring.length], ring[index - 1])));
  }
  const perimeter = cumulative.at(-1);
  const segmentAt = (s) => {
    invariant(s >= 0 && s <= perimeter, `Outline distance ${s} is off the outline`);
    let low = 0;
    let high = ring.length - 1;
    while (low < high) {
      const middle = (low + high + 1) >> 1;
      if (cumulative[middle] <= s) low = middle;
      else high = middle - 1;
    }
    return low;
  };
  const pointAt = (s) => {
    const index = segmentAt(s);
    const a = ring[index];
    const b = ring[(index + 1) % ring.length];
    const t = (s - cumulative[index]) / (cumulative[index + 1] - cumulative[index]);
    return add(a, scale(sub(b, a), t));
  };
  // Outward normal (toward the water) of segment index: right of travel.
  const segmentNormal = (index) => {
    const direction = unit(sub(ring[(index + 1) % ring.length], ring[index]));
    return [direction[1], -direction[0]];
  };
  // Smoothed outward normal: segment normals weighted by their overlap with
  // [s - radius, s + radius], so cross-sections never fold at a bend.
  const normalAt = (s, radius) => {
    let sum = [0, 0];
    for (let index = segmentAt(Math.max(0, s - radius)); index < ring.length; index += 1) {
      if (cumulative[index] > s + radius) break;
      const overlap = Math.min(cumulative[index + 1], s + radius) - Math.max(cumulative[index], s - radius);
      if (overlap > 0) sum = add(sum, scale(segmentNormal(index), overlap));
    }
    return unit(sum);
  };
  const tangentAt = (s, radius) => {
    const normal = normalAt(s, radius);
    return [-normal[1], normal[0]];
  };
  // Distance along the outline of a point lying on it (or null).
  const distanceOf = (point, tolerance) => {
    let best = null;
    for (let index = 0; index < ring.length; index += 1) {
      const a = ring[index];
      const b = ring[(index + 1) % ring.length];
      const delta = sub(b, a);
      const span = dot(delta, delta);
      const t = Math.max(0, Math.min(1, dot(sub(point, a), delta) / span));
      const distance = length(sub(point, add(a, scale(delta, t))));
      if (distance <= tolerance && (!best || distance < best.distance)) best = { distance, s: cumulative[index] + t * Math.sqrt(span) };
    }
    return best?.s ?? null;
  };
  return { ring, cumulative, perimeter, pointAt, normalAt, tangentAt, segmentAt, distanceOf };
}

// The region swept by cross-sections from s0 to s1, reaching `reach` inland and
// out over the water.
function windowPolygon(outline, s0, s1, reach) {
  const stations = [s0];
  for (let index = 0; index < outline.ring.length; index += 1) {
    if (outline.cumulative[index] > s0 && outline.cumulative[index] < s1) stations.push(outline.cumulative[index]);
  }
  stations.push(s1);
  const inner = stations.map((s) => add(outline.pointAt(s), scale(outline.normalAt(s, 6), -reach)));
  const outer = stations.map((s) => add(outline.pointAt(s), scale(outline.normalAt(s, 6), reach)));
  const ring = [...inner, ...outer.reverse()];
  return [[ringArea(ring) > 0 ? ring : ring.reverse()]];
}

// ---------------------------------------------------------------- plan

// The inside bands, from the config, boundary and OSM sources alone (no land
// facets yet): source key -> the breakwater part inside the outline that the
// world builder drapes as the riprap overlay instead of the flat one.
export function planShoreline({ config, boundary, playableObjects, rawOsm }) {
  const settings = shorelineSettings(config);
  const outline = outlineOf(boundary);
  const innerBySource = new Map();
  const segments = settings.segments.map((segment) => {
    const object = playableObjects.get(segment.source_key);
    invariant(object && object.roles.includes("terrain_shoreline") && object.tags.man_made === "breakwater",
      `Shoreline segment ${segment.id} source ${segment.source_key} is not a playable OSM breakwater`);
    const [s0, s1] = segment.s_m;
    invariant(s1 <= outline.perimeter, `Shoreline segment ${segment.id} runs past the end of the outline`);
    const window = windowPolygon(outline, s0, s1, WINDOW_REACH_M);
    const inner = guarded(`segment ${segment.id} inner band`, () => polygonClipping.intersection(object.geometry, window));
    invariant(multiArea(inner) > 1, `Shoreline segment ${segment.id} has no breakwater inside the outline`);
    const footprint = rawWayFootprint(rawOsm, segment.source_key.slice(1));
    const outer = guarded(`segment ${segment.id} outer band`, () => polygonClipping.intersection(polygonClipping.difference(footprint, boundary), window));
    const previous = innerBySource.get(segment.source_key);
    innerBySource.set(segment.source_key, previous ? guarded("inner union", () => polygonClipping.union(previous, inner)) : inner);
    return { ...segment, s0, s1, window, inner, outer };
  });
  return { settings, outline, segments, innerBySource, overlay_bias_m: settings.overlay_bias_m };
}

// ---------------------------------------------------------------- generate

export function generateShoreline({ plan, seed, facetsForChunk, facetElevation, terrain, spawnXZ, hardShapes, playableObjects, rawOsm }) {
  const { settings, outline } = plan;
  const slope = settings.slope;
  const rules = settings.boulders;
  const bias = settings.overlay_bias_m;
  const facetCache = new Map();
  const facetsNear = (east, north) => {
    const id = chunkId(Math.floor(east / CHUNK_SIZE_M), Math.floor(-north / CHUNK_SIZE_M));
    if (!facetCache.has(id)) facetCache.set(id, facetsForChunk(id));
    return facetCache.get(id);
  };
  // Land elevation at a point on or inside the outline, from the generated
  // land facets (the surface the player stands on).
  const landAt = (point) => {
    for (const facet of facetsNear(point[0], point[1])) {
      if (point[0] < facet.bounds.min_x - 0.01 || point[0] > facet.bounds.max_x + 0.01 || point[1] < facet.bounds.min_y - 0.01 || point[1] > facet.bounds.max_y + 0.01) continue;
      const sample = facetElevation(facet, point[0], point[1]);
      if (sample.inside) return sample.elevation;
    }
    return null;
  };
  // Exclusions for boulders: the landing pier deck and the street-detail hard
  // shapes (spawn, ferry path, QA route, stairs, doors and approaches), plus
  // every road and path ribbon inside the outline.
  const pierKeys = [...playableObjects.values()]
    .filter((object) => object.tags.man_made === "pier" && object.tags.area === "yes" && object.row.osm_type === "way")
    .map((object) => object.row.osm_id);
  const piers = pierKeys.map((id) => rawWayFootprint(rawOsm, id));
  const roads = [...playableObjects.values()].filter((object) => object.roles.includes("roads_paths")).map((object) => object.geometry);
  const hard = hardShapes.map((shape) => ({ ...shape, points: shape.points.map(([x, z]) => [x, -z]) }));
  const blocked = (point, radius, inside) => {
    for (const pier of piers) {
      if (pointInMulti(pier, point) || distanceToMultiEdges(pier, point) < rules.pier_clearance_m + radius) return "pier";
    }
    for (const shape of hard) {
      const distance = shape.points.length === 1
        ? length(sub(point, shape.points[0]))
        : Math.min(...shape.points.slice(1).map((p, index) => distanceToSegment(point, shape.points[index], p)));
      if (distance < shape.radius_m + radius) return shape.component ?? "hard";
    }
    if (spawnXZ && length(sub(point, [spawnXZ[0], -spawnXZ[1]])) < 6.5 + radius) return "spawn";
    if (inside) {
      for (const road of roads) {
        if (pointInMulti(road, point) || distanceToMultiEdges(road, point) < 0.3 + radius) return "path";
      }
    }
    return null;
  };

  const prototypes = [];
  for (let index = 0; index < rules.prototypes; index += 1) prototypes.push(rockPrototype(seed, index));
  prototypes.push(driftwoodPrototype());
  const driftwoodIndex = prototypes.length - 1;

  const records = [];
  const placements = [];
  const rejected = {};
  const segmentSummaries = [];
  for (const segment of plan.segments) {
    const { s0, s1 } = segment;
    // Stations: every station_m, plus each land-edge breakpoint on the outline
    // so the slope's top edge follows the land edge exactly.
    const forced = new Set();
    for (const s of [s0, s1]) forced.add(s);
    for (let index = 0; index < outline.ring.length; index += 1) {
      if (outline.cumulative[index] > s0 && outline.cumulative[index] < s1) forced.add(outline.cumulative[index]);
    }
    const seen = new Set();
    for (let s = s0; s <= s1; s += 20) {
      const p = outline.pointAt(Math.min(s, s1));
      for (const facet of facetsNear(p[0], p[1])) {
        for (const vertex of facet.vertices) {
          const key = `${vertex.east},${vertex.north}`;
          if (seen.has(key)) continue;
          seen.add(key);
          const along = outline.distanceOf([vertex.east, vertex.north], EDGE_VERTEX_TOLERANCE_M);
          if (along != null && along > s0 && along < s1) forced.add(along);
        }
      }
    }
    const stations = [...forced];
    const count = Math.ceil((s1 - s0) / slope.station_m);
    for (let step = 1; step < count; step += 1) {
      const s = s0 + ((s1 - s0) * step) / count;
      if (![...forced].some((f) => Math.abs(f - s) < slope.station_m * 0.35)) stations.push(s);
    }
    stations.sort((left, right) => left - right);

    // Cross-section per station: top on the land edge, DEM gradient clamped to
    // the photographed 2:1-3:1, then the toe under the water.
    const sections = stations.map((s) => {
      const point = outline.pointAt(s);
      const normal = outline.normalAt(s, 3);
      const land = landAt(point);
      invariant(land != null, `Shoreline segment ${segment.id} has no land under the outline at s=${s}`);
      const demNear = terrain.sampleEastNorth(...add(point, scale(normal, slope.dem_fit_m[0])));
      const demFar = terrain.sampleEastNorth(...add(point, scale(normal, slope.dem_fit_m[1])));
      const raw = (demNear - demFar) / (slope.dem_fit_m[1] - slope.dem_fit_m[0]);
      return { s, point, normal, top: land + bias, raw_gradient: raw };
    });
    for (const section of sections) {
      let sum = 0;
      let weight = 0;
      for (const other of sections) {
        const gap = Math.abs(other.s - section.s);
        if (gap > slope.gradient_smoothing_m) continue;
        const w = 1 - gap / (slope.gradient_smoothing_m + 1e-9);
        sum += Math.max(slope.gradient_m_per_m[0], Math.min(slope.gradient_m_per_m[1], other.raw_gradient)) * w;
        weight += w;
      }
      section.gradient = sum / weight;
      section.water_m = (section.top - WATER_Y_M) / section.gradient;
      section.toe_m = (section.top - slope.toe_y_m) / section.gradient;
    }
    const surfaceAt = (section, d, east, north) => {
      const relief = slope.relief_m * rockRelief(seed, east, north, slope.relief_wavelength_m) * smoothstep(0, slope.top_blend_m, d);
      return Math.min(section.top - 0.02 * Math.min(1, d / 0.2), section.top - section.gradient * d + relief);
    };
    // Grid vertices (world) per station and column.
    const grid = sections.map((section) => {
      const row = [];
      for (let column = 0; column <= slope.columns; column += 1) {
        const d = (section.toe_m * column) / slope.columns;
        const plan2 = add(section.point, scale(section.normal, d));
        const y = column === 0 ? section.top : surfaceAt(section, d, plan2[0], plan2[1]);
        row.push({ d, plan: plan2, world: [plan2[0], y, -plan2[1]] });
      }
      return row;
    });
    const vertexNormal = (i, j) => {
      const at = (a, b) => grid[Math.max(0, Math.min(grid.length - 1, a))][Math.max(0, Math.min(slope.columns, b))].world;
      const along = sub3(at(i + 1, j), at(i - 1, j));
      const across = sub3(at(i, j + 1), at(i, j - 1));
      let normal = unit3(cross3(along, across));
      if (normal[1] < 0) normal = scale3(normal, -1);
      return normal;
    };
    // Records split into sections along the outline for culling.
    const sectionCount = Math.max(1, Math.round((s1 - s0) / slope.section_m));
    const sectionOf = (s) => Math.min(sectionCount - 1, Math.floor(((s - s0) / (s1 - s0)) * sectionCount));
    const meshes = Array.from({ length: sectionCount }, () => ({ vertices: [], normals: [], indices: [], shared: new Map() }));
    for (let i = 0; i + 1 < grid.length; i += 1) {
      const mesh = meshes[sectionOf((sections[i].s + sections[i + 1].s) / 2)];
      // Grid vertices are shared by the strips of one record.
      const index = (row, column) => {
        const key = row * (slope.columns + 1) + column;
        if (!mesh.shared.has(key)) mesh.shared.set(key, pushVertex(mesh, grid[row][column].world, vertexNormal(row, column)));
        return mesh.shared.get(key);
      };
      const left = [];
      const right = [];
      for (let column = 0; column <= slope.columns; column += 1) {
        left.push(index(i, column));
        right.push(index(i + 1, column));
      }
      for (let column = 0; column < slope.columns; column += 1) {
        const a = left[column];
        const b = right[column];
        const c = right[column + 1];
        const d = left[column + 1];
        const up = unit3(add3(vertexNormal(i, column), vertexNormal(i + 1, column + 1)));
        // Alternate the diagonal so the relief does not streak one way.
        if ((i + column) % 2 === 0) {
          pushTriangle(mesh, [a, b, c], up);
          pushTriangle(mesh, [a, c, d], up);
        } else {
          pushTriangle(mesh, [a, b, d], up);
          pushTriangle(mesh, [b, c, d], up);
        }
      }
    }
    // End caps: vertical rock faces closing the slope at the segment ends.
    for (const [rowIndex, sign] of [[0, -1], [grid.length - 1, 1]]) {
      const section = sections[rowIndex];
      const tangent = [-section.normal[1], section.normal[0]];
      const facing = [tangent[0] * sign, 0, -tangent[1] * sign];
      const mesh = meshes[rowIndex === 0 ? 0 : sectionCount - 1];
      const row = grid[rowIndex];
      const tops = row.map((cell) => pushVertex(mesh, cell.world, facing));
      const bottoms = row.map((cell) => pushVertex(mesh, [cell.world[0], slope.end_cap_bottom_y_m, cell.world[2]], facing));
      for (let column = 0; column < row.length - 1; column += 1) {
        pushTriangle(mesh, [tops[column], bottoms[column], bottoms[column + 1]], facing);
        pushTriangle(mesh, [tops[column], bottoms[column + 1], tops[column + 1]], facing);
      }
    }
    meshes.forEach((mesh, index) => {
      invariant(mesh.indices.length > 0, `Shoreline segment ${segment.id} section ${index} has no slope triangles`);
      records.push({
        object_key: `shoreline-slope:${segment.id}:${index}`,
        segment: segment.id,
        section: index,
        source_keys: [segment.source_key],
        material_key: SHORELINE_SLOPE_MATERIAL,
        vertices: mesh.vertices,
        normals: mesh.normals,
        indices: mesh.indices,
      });
    });

    // ------------------------------------------------------------ boulders
    const sectionAtS = (s) => {
      let low = 0;
      let high = sections.length - 1;
      while (high - low > 1) {
        const middle = (low + high) >> 1;
        if (sections[middle].s <= s) low = middle;
        else high = middle;
      }
      const span = sections[high].s - sections[low].s;
      const t = span > 0 ? (s - sections[low].s) / span : 0;
      const a = sections[low];
      const b = sections[high];
      return {
        s,
        point: outline.pointAt(s),
        normal: unit(add(scale(a.normal, 1 - t), scale(b.normal, t))),
        top: lerp(a.top, b.top, t),
        gradient: lerp(a.gradient, b.gradient, t),
        water_m: lerp(a.water_m, b.water_m, t),
        toe_m: lerp(a.toe_m, b.toe_m, t),
      };
    };
    const slopeNormal = (section) => unit3([section.gradient * section.normal[0], 1, -section.gradient * section.normal[1]]);
    const place = (band, identity, rng, prototypeIndex, origin, up, yaw, size, tint, s) => {
      const prototype = prototypes[prototypeIndex];
      const scales = prototypeIndex === driftwoodIndex ? [size, size, size] : [size, size * (0.85 + 0.3 * rng()), size];
      const basis = placementBasis(up, yaw, scales);
      placements.push({
        id: `${segment.id}:${band}:${identity}`,
        band,
        prototype: prototype.id,
        section: sectionOf(s),
        basis: basis.flat().map(round4),
        origin: origin.map(roundCoordinate),
        tint: tint.map(round4),
      });
    };
    const tintFor = (rng) => {
      // Grey, tan and brown stones as in the dated photos, multiplied onto the
      // riprap texture; at most 1 so no renderer clips it.
      const family = rng();
      const base = family < 0.55 ? [0.95, 0.95, 0.95] : family < 0.8 ? [1.0, 0.94, 0.83] : [0.94, 0.84, 0.74];
      const shade = 0.76 + 0.24 * rng();
      return base.map((value) => value * shade);
    };
    const pick = (range, rng) => lerp(range[0], range[1], rng());
    const reject = (reason) => {
      rejected[reason] = (rejected[reason] ?? 0) + 1;
    };
    // Crest: the top course along the inside band's landward edge.
    const crest = rules.crest;
    for (let s = s0 + crest.spacing_m * 0.5, k = 0; s < s1; s += crest.spacing_m, k += 1) {
      const rng = random(seed, `${segment.id}:crest:${k}`);
      if (rng() > crest.acceptance) continue;
      const jittered = Math.min(s1, Math.max(s0, s + (rng() - 0.5) * crest.spacing_m * 0.6));
      const section = sectionAtS(jittered);
      // Width of the inside band along the inward normal at this station.
      let width = 0;
      for (let d = 0.1; d <= 15; d += 0.1) {
        if (!pointInMulti(segment.inner, add(section.point, scale(section.normal, -d)))) break;
        width = d;
      }
      if (width < 0.6) {
        reject("crest_band_narrow");
        continue;
      }
      const size = pick(crest.size_m, rng);
      const inset = Math.min(width - size * 0.3, pick(crest.inset_m, rng) + size * 0.3);
      const plan2 = add(section.point, scale(section.normal, -Math.max(0.2, width - inset)));
      const reason = blocked(plan2, size * 0.5, true);
      if (reason) {
        reject(`crest_${reason}`);
        continue;
      }
      const ground = landAt(plan2);
      if (ground == null) {
        reject("crest_no_land");
        continue;
      }
      const prototypeIndex = Math.floor(rng() * rules.prototypes);
      const height = prototypes[prototypeIndex].size_m[1] * size;
      const protrude = Math.min(height * 0.8, pick(crest.protrude_m, rng));
      const up = unit3([0.12 * (rng() - 0.5), 1, 0.12 * (rng() - 0.5)]);
      place("crest", k, rng, prototypeIndex, [plan2[0], ground + bias + protrude - height, -plan2[1]], up, rng() * Math.PI * 2, size, tintFor(rng), jittered);
    }
    // Top: the edge course just outside the outline, big stones standing up to
    // rise_m above the land edge, so the shore reads as a rock band from the
    // plaza and the water (the photographed top course).
    const course = rules.top;
    for (let s = s0 + course.spacing_m * 0.5, k = 0; s < s1; s += course.spacing_m, k += 1) {
      const rng = random(seed, `${segment.id}:top:${k}`);
      if (rng() > course.acceptance) continue;
      const sAt = Math.min(s1, Math.max(s0, s + (rng() - 0.5) * course.spacing_m * 0.5));
      const section = sectionAtS(sAt);
      const size = pick(course.size_m, rng);
      const d = pick(course.out_m, rng) + size * 0.25;
      const plan2 = add(section.point, scale(section.normal, d));
      const reason = blocked(plan2, size * 0.5, false);
      if (reason) {
        reject(`top_${reason}`);
        continue;
      }
      const prototypeIndex = Math.floor(rng() * rules.prototypes);
      const height = prototypes[prototypeIndex].size_m[1] * size;
      const top = section.top + pick(course.rise_m, rng);
      const up = unit3(add3(scale3(slopeNormal(section), 0.45), [0, 0.55, 0]));
      place("top", k, rng, prototypeIndex, [plan2[0], top - height, -plan2[1]], up, rng() * Math.PI * 2, size, tintFor(rng), sAt);
    }
    // Slope: a jittered grid over the outside slope, between the top and the waterline.
    const field = rules.slope;
    for (let s = s0, i = 0; s < s1; s += field.cell_m, i += 1) {
      for (let j = 0; j < 40; j += 1) {
        const rng = random(seed, `${segment.id}:slope:${i}:${j}`);
        const sAt = Math.min(s1, s + rng() * field.cell_m);
        const section = sectionAtS(sAt);
        const d = 0.45 + (j + rng()) * field.cell_m;
        if (d > section.water_m - 0.3) break;
        if (rng() > field.acceptance) continue;
        const plan2 = add(section.point, scale(section.normal, d));
        const size = pick(field.size_m, rng);
        const reason = blocked(plan2, size * 0.5, false);
        if (reason) {
          reject(`slope_${reason}`);
          continue;
        }
        const prototypeIndex = Math.floor(rng() * rules.prototypes);
        const height = prototypes[prototypeIndex].size_m[1] * size;
        const surface = section.top - section.gradient * d;
        const up = unit3(add3(scale3(slopeNormal(section), 0.65), [0, 0.35, 0]));
        place("slope", `${i}_${j}`, rng, prototypeIndex, [plan2[0], surface - height * pick(field.embed, rng), -plan2[1]], up, rng() * Math.PI * 2, size, tintFor(rng), sAt);
      }
    }
    // Toe: larger stones along the waterline, half under the water.
    const toe = rules.toe;
    for (let s = s0 + toe.spacing_m * 0.5, k = 0; s < s1; s += toe.spacing_m, k += 1) {
      const rng = random(seed, `${segment.id}:toe:${k}`);
      if (rng() > toe.acceptance) continue;
      const sAt = Math.min(s1, Math.max(s0, s + (rng() - 0.5) * toe.spacing_m * 0.7));
      const section = sectionAtS(sAt);
      const d = section.water_m + (rng() - 0.45) * 1.1;
      const plan2 = add(section.point, scale(section.normal, d));
      const size = pick(toe.size_m, rng);
      const reason = blocked(plan2, size * 0.5, false);
      if (reason) {
        reject(`toe_${reason}`);
        continue;
      }
      const prototypeIndex = Math.floor(rng() * rules.prototypes);
      const height = prototypes[prototypeIndex].size_m[1] * size;
      const up = unit3(add3(scale3(slopeNormal(section), 0.5), [0, 0.5, 0]));
      place("toe", k, rng, prototypeIndex, [plan2[0], WATER_Y_M - height * pick(toe.submerge, rng), -plan2[1]], up, rng() * Math.PI * 2, size, tintFor(rng), sAt);
    }
    // Driftwood: a few bleached logs caught on the upper slope.
    const wood = rules.driftwood;
    for (let s = s0 + wood.spacing_m * 0.5, k = 0; s < s1; s += wood.spacing_m, k += 1) {
      const rng = random(seed, `${segment.id}:driftwood:${k}`);
      if (rng() > wood.acceptance) continue;
      const sAt = Math.min(s1 - 2, Math.max(s0 + 2, s + (rng() - 0.5) * wood.spacing_m * 0.6));
      const section = sectionAtS(sAt);
      const y = pick(wood.band_y_m, rng);
      const d = (section.top - y) / section.gradient;
      if (d < 0.6 || d > section.water_m - 0.5) {
        reject("driftwood_band");
        continue;
      }
      const plan2 = add(section.point, scale(section.normal, d));
      const lengthM = pick(wood.length_m, rng);
      const reason = blocked(plan2, lengthM * 0.5, false);
      if (reason) {
        reject(`driftwood_${reason}`);
        continue;
      }
      const tangent = [-section.normal[1], section.normal[0]];
      const heading = Math.atan2(-(-tangent[1]), tangent[0]) + (rng() - 0.5) * 0.9;
      place("driftwood", k, rng, driftwoodIndex, [plan2[0], y - 0.05, -plan2[1]], slopeNormal(section), heading, lengthM / 2.4, [0.86, 0.82, 0.76].map((v) => v * (0.9 + 0.15 * rng())), sAt);
    }
    segmentSummaries.push({
      id: segment.id,
      source_key: segment.source_key,
      outline_source_key: segment.outline_source_key,
      s_m: [roundCoordinate(s0), roundCoordinate(s1)],
      sections: sectionCount,
      stations: stations.length,
      inside_band_area_m2: roundCoordinate(multiArea(segment.inner)),
      osm_outside_area_m2: roundCoordinate(multiArea(segment.outer)),
      top_y_m: [roundCoordinate(Math.min(...sections.map((x) => x.top))), roundCoordinate(Math.max(...sections.map((x) => x.top)))],
      gradient_m_per_m: [round4(Math.min(...sections.map((x) => x.gradient))), round4(Math.max(...sections.map((x) => x.gradient)))],
      waterline_m: [roundCoordinate(Math.min(...sections.map((x) => x.water_m))), roundCoordinate(Math.max(...sections.map((x) => x.water_m)))],
      reason: segment.reason,
      reference: segment.reference,
    });
  }
  placements.sort((left, right) => (left.id < right.id ? -1 : left.id > right.id ? 1 : 0));
  const byBand = Object.fromEntries(SHORELINE_BANDS.map((band) => [band, placements.filter((placement) => placement.band === band).length]));
  const byPrototype = Object.fromEntries(prototypes.map((prototype) => [prototype.id, placements.filter((placement) => placement.prototype === prototype.id).length]));
  const document = {
    schema_version: SHORELINE_SCHEMA,
    generator: "tools/lib/shoreline-generation.mjs",
    visual_only: true,
    seed,
    water_y_m: WATER_Y_M,
    overlay: { material_key: SHORELINE_OVERLAY_MATERIAL, bias_m: bias, object_key_prefix: SHORELINE_OVERLAY_PREFIX },
    visibility_range_m: rules.visibility_range_m,
    segments: segmentSummaries,
    records,
    prototypes,
    placements,
    counts: {
      records: records.length,
      slope_triangles: records.reduce((sum, record) => sum + record.indices.length / 3, 0),
      placements: placements.length,
      by_band: byBand,
      by_prototype: byPrototype,
      rejected_by_reason: Object.fromEntries(Object.entries(rejected).sort(([left], [right]) => left.localeCompare(right))),
    },
  };
  return { document };
}
