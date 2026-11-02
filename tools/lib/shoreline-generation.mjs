// Shoreline riprap: the rock armour along the island edge, for the segments in
// tools/config/shoreline.json. Always-on scenery, not a switchable street-detail
// layer.
//
// Almost the whole Treasure Island edge is OSM man_made=breakwater,
// material=rock. Each breakwater polygon straddles the island outline
// (w26767313): its part inside is the band from the crest to the outline; its
// part outside is the slope down to the water, which the playable land (clipped
// at the outline) leaves open. For each configured segment this module
//   1. plans the inside band (planShoreline). The world builder drapes it as a
//      terrain_overlay (the dry dirt verge at the top of the riprap) instead of
//      the flat breakwater overlay. It has no collision: land_ground stays the
//      only support inside the outline, so route QA, the regional anchors and
//      boundary recovery are unchanged;
//   2. builds the visual-only rock armour (generateShoreline) for
//      generated/world/shoreline.json: a flat shoulder just outside the outline
//      that continues the verge's ground cover, an underlay slope behind it to
//      under the water, and angular quarry stones over them (a top row just
//      beyond the outline and a back row behind it at the crest, small stones
//      in the shoulder, then the heap down past the waterline, largest stones
//      first), low cobbles set in the inside band that the player walks over,
//      and bleached driftwood resting on the stones.
//
// The player is recovered as soon as it leaves the outline, so nothing beyond
// the outline needs collision. Every stone and log outside stays clear of the
// outline (the top row sets back by about the player's radius) and every cobble
// inside the band stays low enough to walk over; tools/validate_godot_world.mjs
// checks both.
//
// Plan geometry is east/north; placements use world x, y, z with z = -north.
// Every number in the config is production inference for game art (dated
// photos and the USGS DEM), not survey data.

import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import polygonClipping from "polygon-clipping";

import {
  multiPolygonArea,
  multiPolygonBounds,
  pointInMultiPolygon,
  rawWayFootprint,
  signedRingArea,
} from "./osm-geometry.mjs";
import {
  CHUNK_SIZE_M,
  PLAYABLE_BOUNDARY_SOURCE_KEY,
  chunkId,
  invariant,
  roundCoordinate,
  sha256File,
} from "./world-contract.mjs";

export const SHORELINE_SCHEMA = "ti.shoreline/3";
export const SHORELINE_CONFIG_SCHEMA = "ti.shoreline-config/1";
export const SHORELINE_CONFIG_PATH = "tools/config/shoreline.json";
// The riprap overlay inside the outline and the materials of the slope, the
// stones and the wood.
export const SHORELINE_OVERLAY_MATERIAL = "terrain_riprap";
export const SHORELINE_SLOPE_MATERIAL = "shoreline_riprap";
// The flat shoulder between the outline and the stones: the verge's ground
// cover, continued past the outline (its records carry the land's UVs).
export const SHORELINE_VERGE_MATERIAL = "shoreline_verge";
export const SHORELINE_BOULDER_MATERIAL = "shoreline_boulder";
export const SHORELINE_DRIFTWOOD_MATERIAL = "shoreline_driftwood";
// The overlay's object key prefix: "<prefix>:<source key>:<chunk>".
export const SHORELINE_OVERLAY_PREFIX = "shoreline";
// Placement batches: cobbles inside the outline; the top row, the heap and the
// driftwood outside it.
export const SHORELINE_BANDS = Object.freeze(["cobble", "driftwood", "heap", "top"]);
export const SHORELINE_PROTOTYPE_KINDS = Object.freeze(["boulder", "log", "plank"]);
// One placement: position x, y, z; rotation quaternion x, y, z, w; scale x, y,
// z; tint r, g, b.
export const SHORELINE_PLACEMENT_LENGTH = 13;
// Cobbles stand on walkable land with no collision: at most this far above it.
export const SHORELINE_COBBLE_MAX_TOP_M = 0.15;
// Stones and logs outside keep at least this far beyond the outline.
export const SHORELINE_OUTSIDE_CLEARANCE_M = 0.1;
// The game's water plane (world_root.tscn ContextWorld/Water).
export const WATER_Y_M = -0.12;
// How far the window around a segment reaches inland and out over the water.
const WINDOW_REACH_M = 40;
// Land vertices closer than this to the outline are land-edge breakpoints.
const EDGE_VERTEX_TOLERANCE_M = 0.003;
const MINIMUM_TRIANGLE_AREA_M2 = 1e-6;
const SAFE_ID = /^[a-z0-9_]+$/u;

const CONFIG_FIELDS = ["notes", "overlay_bias_m", "schema_version", "seed", "segments", "slope", "stones", "structures"];
const SLOPE_FIELDS = ["columns", "dem_fit_m", "end_cap_bottom_y_m", "gradient_m_per_m", "gradient_smoothing_m", "relief_m", "relief_wavelength_m", "section_m", "shoulder_m", "station_m", "toe_y_m", "top_blend_m"];
const STONE_FIELDS = ["cobble", "crest", "driftwood", "heap", "planks", "prototypes", "section_m", "setback_m", "shoulder", "top", "visibility_m"];
const SHOULDER_FIELDS = ["fill", "rise_m", "size_m"];
const TOP_FIELDS = ["bury", "max_rise_m", "out_jitter_m", "size_m", "spacing", "tilt_deg"];
const CREST_FIELDS = ["depth_m", "drop_per_m", "fill", "rise_m", "size_m"];
const HEAP_FIELDS = ["bury", "classes", "lift", "overlap", "tilt_deg", "toe_extra_m"];
const COBBLE_FIELDS = ["edge_m", "fill", "outline_bias", "path_clearance_m", "size_m", "top_m"];
const DRIFTWOOD_FIELDS = ["acceptance", "d_m", "length_m", "radius_m", "spacing_m", "yaw_jitter_deg"];
const PLANK_FIELDS = ["above_water_m", "length_m", "near_xz", "segment", "width_m", "yaw_deg"];
const STRUCTURE_FIELDS = ["clearance_m", "slope", "tags", "under_drop_m"];
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

function requireRange(value, minimum, label) {
  invariant(isRange(value, minimum), `${label} must be a [low, high] range from ${minimum}`);
}

// The validated shoreline config.
export function shorelineSettings(config) {
  exactKeys(config, CONFIG_FIELDS, "Shoreline config");
  invariant(config.schema_version === SHORELINE_CONFIG_SCHEMA, "Shoreline config schema drift");
  invariant(Number.isInteger(config.seed) && config.seed >= 0 && config.seed <= 0xffffffff, "Shoreline seed must be a 32-bit integer");
  invariant(Array.isArray(config.notes) && config.notes.every((note) => typeof note === "string"), "Shoreline notes must be strings");
  invariant(isFiniteNumber(config.overlay_bias_m) && config.overlay_bias_m > 0.05 && config.overlay_bias_m < 0.078,
    "Shoreline overlay_bias_m must lie above the area overlays (0.05 m) and under the paths (0.078 m)");
  const slope = config.slope;
  exactKeys(slope, SLOPE_FIELDS, "Shoreline slope");
  for (const key of ["station_m", "relief_wavelength_m", "top_blend_m", "section_m", "gradient_smoothing_m", "shoulder_m"]) {
    invariant(isFiniteNumber(slope[key]) && slope[key] > 0, `Shoreline slope.${key} must be positive`);
  }
  invariant(Number.isInteger(slope.columns) && slope.columns >= 4 && slope.columns <= 64, "Shoreline slope.columns must be an integer in [4, 64]");
  invariant(isRange(slope.gradient_m_per_m, 0.1) && slope.gradient_m_per_m[1] <= 1.0, "Shoreline slope.gradient_m_per_m must be [low, high] in (0.1, 1]");
  invariant(isRange(slope.dem_fit_m, 0) && slope.dem_fit_m[1] > slope.dem_fit_m[0], "Shoreline slope.dem_fit_m must be [near, far]");
  invariant(isFiniteNumber(slope.toe_y_m) && slope.toe_y_m < WATER_Y_M, "Shoreline slope.toe_y_m must lie under the water plane");
  invariant(isFiniteNumber(slope.end_cap_bottom_y_m) && slope.end_cap_bottom_y_m < slope.toe_y_m, "Shoreline end caps must reach below the toe");
  invariant(isFiniteNumber(slope.relief_m) && slope.relief_m >= 0 && slope.relief_m < 0.5, "Shoreline slope.relief_m must be in [0, 0.5)");
  const stones = config.stones;
  exactKeys(stones, STONE_FIELDS, "Shoreline stones");
  invariant(Number.isInteger(stones.prototypes) && stones.prototypes >= 3 && stones.prototypes <= 12, "Shoreline stones.prototypes must be 3-12 boulder shapes");
  invariant(isFiniteNumber(stones.section_m) && stones.section_m >= 10, "Shoreline stones.section_m must be at least 10 m");
  invariant(isFiniteNumber(stones.setback_m) && stones.setback_m >= SHORELINE_OUTSIDE_CLEARANCE_M, `Shoreline stones.setback_m must be at least ${SHORELINE_OUTSIDE_CLEARANCE_M} m`);
  exactKeys(stones.visibility_m, SHORELINE_BANDS, "Shoreline stones.visibility_m");
  for (const band of SHORELINE_BANDS) {
    const [end, margin] = stones.visibility_m[band] ?? [];
    invariant(isFiniteNumber(end) && end > 20 && isFiniteNumber(margin) && margin > 0 && margin < end, `Shoreline stones.visibility_m.${band} must be [end, fade margin]`);
  }
  exactKeys(stones.top, TOP_FIELDS, "Shoreline stones.top");
  for (const key of ["size_m", "out_jitter_m", "bury"]) requireRange(stones.top[key], 0, `Shoreline stones.top.${key}`);
  invariant(stones.top.bury[1] < 1, "Shoreline stones.top.bury must leave part of each stone above ground");
  invariant(isFiniteNumber(stones.top.max_rise_m) && stones.top.max_rise_m > 0, "Shoreline stones.top.max_rise_m must be positive");
  invariant(isFiniteNumber(stones.top.tilt_deg) && stones.top.tilt_deg >= 0 && stones.top.tilt_deg < 45, "Shoreline stones.top.tilt_deg must be in [0, 45)");
  requireRange(stones.top.spacing, 0.3, "Shoreline stones.top.spacing");
  invariant(stones.top.spacing[1] <= 1.2, "Shoreline stones.top.spacing must stay within 1.2 stone sizes");
  exactKeys(stones.crest, CREST_FIELDS, "Shoreline stones.crest");
  requireRange(stones.crest.size_m, 0.2, "Shoreline stones.crest.size_m");
  requireRange(stones.crest.rise_m, -2, "Shoreline stones.crest.rise_m");
  invariant(isFiniteNumber(stones.crest.depth_m) && stones.crest.depth_m > 0 && isFiniteNumber(stones.crest.fill) && stones.crest.fill > 0 && stones.crest.fill <= 1.5,
    "Shoreline stones.crest needs a positive depth_m and a fill in (0, 1.5]");
  invariant(isFiniteNumber(stones.crest.drop_per_m) && stones.crest.drop_per_m >= 0, "Shoreline stones.crest.drop_per_m must be non-negative");
  exactKeys(stones.shoulder, SHOULDER_FIELDS, "Shoreline stones.shoulder");
  requireRange(stones.shoulder.size_m, 0.1, "Shoreline stones.shoulder.size_m");
  requireRange(stones.shoulder.rise_m, -1, "Shoreline stones.shoulder.rise_m");
  invariant(isFiniteNumber(stones.shoulder.fill) && stones.shoulder.fill > 0 && stones.shoulder.fill <= 1.5, "Shoreline stones.shoulder.fill must be in (0, 1.5]");
  exactKeys(stones.heap, HEAP_FIELDS, "Shoreline stones.heap");
  for (const key of ["bury", "lift"]) requireRange(stones.heap[key], 0, `Shoreline stones.heap.${key}`);
  invariant(stones.heap.lift[1] < stones.heap.bury[0], "Shoreline stones.heap.lift must stay under bury, so no cut base lifts out of the slope");
  invariant(isFiniteNumber(stones.heap.overlap) && stones.heap.overlap > 0.4 && stones.heap.overlap <= 1, "Shoreline stones.heap.overlap must be in (0.4, 1]");
  invariant(isFiniteNumber(stones.heap.tilt_deg) && stones.heap.tilt_deg >= 0 && stones.heap.tilt_deg < 45, "Shoreline stones.heap.tilt_deg must be in [0, 45)");
  invariant(isFiniteNumber(stones.heap.toe_extra_m) && stones.heap.toe_extra_m >= 0, "Shoreline stones.heap.toe_extra_m must be non-negative");
  invariant(Array.isArray(stones.heap.classes) && stones.heap.classes.length > 0, "Shoreline stones.heap.classes must list size classes");
  for (const [index, size] of stones.heap.classes.entries()) {
    exactKeys(size, ["fill", "size_m"], `Shoreline stones.heap.classes[${index}]`);
    requireRange(size.size_m, 0.2, `Shoreline stones.heap.classes[${index}].size_m`);
    invariant(isFiniteNumber(size.fill) && size.fill > 0 && size.fill <= 1.5, `Shoreline stones.heap.classes[${index}].fill must be in (0, 1.5]`);
  }
  exactKeys(stones.cobble, COBBLE_FIELDS, "Shoreline stones.cobble");
  for (const key of ["size_m", "top_m"]) requireRange(stones.cobble[key], 0, `Shoreline stones.cobble.${key}`);
  invariant(stones.cobble.top_m[1] <= SHORELINE_COBBLE_MAX_TOP_M, `Shoreline cobbles may rise at most ${SHORELINE_COBBLE_MAX_TOP_M} m above the walkable land`);
  for (const key of ["fill", "edge_m", "path_clearance_m", "outline_bias"]) invariant(isFiniteNumber(stones.cobble[key]) && stones.cobble[key] >= 0, `Shoreline stones.cobble.${key} must be non-negative`);
  exactKeys(stones.driftwood, DRIFTWOOD_FIELDS, "Shoreline stones.driftwood");
  for (const key of ["d_m", "length_m", "radius_m"]) requireRange(stones.driftwood[key], 0, `Shoreline stones.driftwood.${key}`);
  invariant(isFiniteNumber(stones.driftwood.spacing_m) && stones.driftwood.spacing_m > 2, "Shoreline stones.driftwood.spacing_m must exceed 2 m");
  invariant(isFiniteNumber(stones.driftwood.acceptance) && stones.driftwood.acceptance >= 0 && stones.driftwood.acceptance <= 1, "Shoreline stones.driftwood.acceptance must be in [0, 1]");
  invariant(isFiniteNumber(stones.driftwood.yaw_jitter_deg) && stones.driftwood.yaw_jitter_deg >= 0, "Shoreline stones.driftwood.yaw_jitter_deg must be non-negative");
  invariant(Array.isArray(stones.planks), "Shoreline stones.planks must be a list");
  for (const [index, plank] of stones.planks.entries()) {
    exactKeys(plank, PLANK_FIELDS, `Shoreline stones.planks[${index}]`);
    for (const key of ["above_water_m", "length_m", "width_m", "yaw_deg"]) invariant(isFiniteNumber(plank[key]), `Shoreline stones.planks[${index}].${key} must be a number`);
    invariant(Array.isArray(plank.near_xz) && plank.near_xz.length === 2 && plank.near_xz.every(isFiniteNumber), `Shoreline stones.planks[${index}].near_xz must be a world [x, z] point`);
  }
  invariant(config.structures != null && typeof config.structures === "object" && Object.keys(config.structures).length > 0, "Shoreline structures must name the structures that clear the riprap");
  for (const [kind, rule] of Object.entries(config.structures)) {
    invariant(SAFE_ID.test(kind), `Shoreline structure kind ${kind} must be lower_snake`);
    exactKeys(rule, STRUCTURE_FIELDS, `Shoreline structures.${kind}`);
    invariant(["cut", "keep"].includes(rule.slope), `Shoreline structures.${kind}.slope must be cut or keep`);
    invariant(isFiniteNumber(rule.clearance_m) && rule.clearance_m >= 0, `Shoreline structures.${kind}.clearance_m must be non-negative`);
    // Stones may pass under a kept structure when they top out this far below the land edge (null: never).
    invariant(rule.under_drop_m === null || (isFiniteNumber(rule.under_drop_m) && rule.under_drop_m > 0 && rule.slope === "keep"),
      `Shoreline structures.${kind}.under_drop_m must be null or a positive drop for a kept slope`);
    invariant(Array.isArray(rule.tags) && rule.tags.length > 0 && rule.tags.every((tag) => typeof tag === "string" && /^[a-z_:]+=[a-z_]+$/u.test(tag)), `Shoreline structures.${kind}.tags must be key=value OSM tags`);
  }
  invariant(Array.isArray(config.segments) && config.segments.length > 0, "Shoreline needs at least one segment");
  const ids = new Set();
  for (const segment of config.segments) {
    exactKeys(segment, SEGMENT_FIELDS, `Shoreline segment ${segment?.id}`);
    invariant(typeof segment.id === "string" && SAFE_ID.test(segment.id) && !ids.has(segment.id), `Shoreline segment ${segment.id} needs a unique lower_snake id`);
    ids.add(segment.id);
    invariant(segment.outline_source_key === PLAYABLE_BOUNDARY_SOURCE_KEY, `Shoreline segment ${segment.id} must run along the island outline ${PLAYABLE_BOUNDARY_SOURCE_KEY}`);
    invariant(/^w\d+$/u.test(segment.source_key), `Shoreline segment ${segment.id} needs an OSM breakwater way source_key`);
    // [start, end] along the outline; start > end runs across the outline's start (s = 0).
    invariant(Array.isArray(segment.s_m) && segment.s_m.length === 2 && segment.s_m.every((value) => isFiniteNumber(value) && value >= 0),
      `Shoreline segment ${segment.id} s_m must be [start, end] distances along the outline`);
    for (const field of ["reason", "reference"]) {
      invariant(typeof segment[field] === "string" && segment[field].trim() !== "", `Shoreline segment ${segment.id} needs ${field}`);
    }
  }
  for (const plank of stones.planks) invariant(ids.has(plank.segment), `Shoreline plank names unknown segment ${plank.segment}`);
  return config;
}

export function loadShorelineConfig(projectRoot) {
  const path = resolve(projectRoot, SHORELINE_CONFIG_PATH);
  const config = shorelineSettings(JSON.parse(readFileSync(path, "utf8")));
  return { config, descriptor: { path: SHORELINE_CONFIG_PATH, sha256: sha256File(path) } };
}

// ---------------------------------------------------------------- 2D helpers

const sub = (a, b) => [a[0] - b[0], a[1] - b[1]];
const add = (a, b) => [a[0] + b[0], a[1] + b[1]];
const scale = (a, s) => [a[0] * s, a[1] * s];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1];
const length = (a) => Math.hypot(a[0], a[1]);

function unit(a) {
  const l = length(a);
  invariant(l > 1e-12, "Cannot normalize a zero vector");
  return [a[0] / l, a[1] / l];
}

function openRing(ring) {
  const same = ring.length > 1 && ring[0][0] === ring.at(-1)[0] && ring[0][1] === ring.at(-1)[1];
  return same ? ring.slice(0, -1) : ring.slice();
}

function distanceToSegment(point, a, b) {
  const delta = sub(b, a);
  const span = dot(delta, delta);
  const t = span > 0 ? Math.max(0, Math.min(1, dot(sub(point, a), delta) / span)) : 0;
  return length(sub(point, add(a, scale(delta, t))));
}

// A multipolygon with its bounds and edge list, for repeated distance and
// containment queries.
function indexedArea(multi) {
  const edges = [];
  for (const polygon of multi) {
    for (const raw of polygon) {
      const ring = openRing(raw);
      for (let index = 0; index < ring.length; index += 1) edges.push([ring[index], ring[(index + 1) % ring.length]]);
    }
  }
  return { multi, edges, bounds: multi.length > 0 ? multiPolygonBounds(multi) : null };
}

function nearBounds(area, point, margin) {
  const b = area.bounds;
  return b != null && point[0] >= b.min_x - margin && point[0] <= b.max_x + margin && point[1] >= b.min_y - margin && point[1] <= b.max_y + margin;
}

function boundsOverlap(a, b) {
  return a != null && b != null && a.max_x >= b.min_x && a.min_x <= b.max_x && a.max_y >= b.min_y && a.min_y <= b.max_y;
}

function edgeDistance(area, point) {
  let best = Infinity;
  for (const [a, b] of area.edges) best = Math.min(best, distanceToSegment(point, a, b));
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

const pick = (range, rng) => lerp(range[0], range[1], rng());

// Lattice hash in [0, 1) for integer cell coordinates.
function cellHash(seed, x, y, salt) {
  let h = Math.imul(x | 0, 0x27d4eb2d) ^ Math.imul(y | 0, 0x165667b1) ^ Math.imul(salt | 0, 0x3c6ef372) ^ seed;
  h = Math.imul(h ^ (h >>> 15), 0x85ebca6b);
  h = Math.imul(h ^ (h >>> 13), 0xc2b2ae35);
  return ((h ^ (h >>> 16)) >>> 0) / 4294967296;
}

// Boulder-scale relief of the underlay in about [-1, 1]: rounded domes on a
// jittered cell grid (inverse distance to the nearest cell point).
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
  return Math.max(-1, Math.min(1, Math.min(1, second - nearest) * 1.6 - 0.55));
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

function round3(value) {
  const rounded = Math.round(value * 1000) / 1000;
  return Object.is(rounded, -0) ? 0 : rounded;
}

function round2(value) {
  const rounded = Math.round(value * 100) / 100;
  return Object.is(rounded, -0) ? 0 : rounded;
}

// Appends one triangle wound counterclockwise around desiredNormal (the
// generated-world convention; the runtime turns it clockwise for Godot).
function pushTriangle(mesh, indices, desiredNormal, target = mesh.indices) {
  const vertex = (index) => mesh.vertices.slice(index * 3, index * 3 + 3);
  let [a, b, c] = indices;
  const normal = cross3(sub3(vertex(b), vertex(a)), sub3(vertex(c), vertex(a)));
  if (length3(normal) / 2 < MINIMUM_TRIANGLE_AREA_M2) return false;
  if (dot3(normal, desiredNormal) < 0) [b, c] = [c, b];
  target.push(a, b, c);
  return true;
}

function pushVertex(mesh, position, normal) {
  const index = mesh.vertices.length / 3;
  mesh.vertices.push(...position.map(roundCoordinate));
  mesh.normals.push(...normal.map(round3));
  return index;
}

function axisQuaternion(axis, angle) {
  return [axis[0] * Math.sin(angle / 2), axis[1] * Math.sin(angle / 2), axis[2] * Math.sin(angle / 2), Math.cos(angle / 2)];
}

function quaternionMultiply(a, b) {
  return [
    a[3] * b[0] + a[0] * b[3] + a[1] * b[2] - a[2] * b[1],
    a[3] * b[1] - a[0] * b[2] + a[1] * b[3] + a[2] * b[0],
    a[3] * b[2] + a[0] * b[1] - a[1] * b[0] + a[2] * b[3],
    a[3] * b[3] - a[0] * b[0] - a[1] * b[1] - a[2] * b[2],
  ];
}

// Rotation (unit quaternion [x, y, z, w]): local x turned by yaw about +y (so
// it points along plan angle yaw), then tilted so local +y meets `up`.
function quaternionFor(up, yaw) {
  const u = unit3(up);
  const tilt = u[1] > 0.999999 ? [0, 0, 0, 1] : axisQuaternion(unit3(cross3([0, 1, 0], u)), Math.acos(Math.max(-1, Math.min(1, u[1]))));
  const q = quaternionMultiply(tilt, axisQuaternion([0, 1, 0], yaw));
  const l = Math.hypot(...q);
  return q.map((value) => value / l);
}

// The basis columns of quaternion q, scaled per local axis.
function basisOf(q, scales) {
  const [x, y, z, w] = q;
  const columns = [
    [1 - 2 * (y * y + z * z), 2 * (x * y + z * w), 2 * (x * z - y * w)],
    [2 * (x * y - z * w), 1 - 2 * (x * x + z * z), 2 * (y * z + x * w)],
    [2 * (x * z + y * w), 2 * (y * z - x * w), 1 - 2 * (x * x + y * y)],
  ];
  return columns.map((column, axis) => scale3(column, scales[axis]));
}

// World positions of a prototype's LOD-0 vertices under a placement.
function placedVertices(prototype, q, scales, origin) {
  const basis = basisOf(q, scales);
  const points = [];
  for (let index = 0; index < prototype.vertices.length; index += 3) {
    const v = [prototype.vertices[index], prototype.vertices[index + 1], prototype.vertices[index + 2]];
    points.push(add3(origin, add3(add3(scale3(basis[0], v[0]), scale3(basis[1], v[1])), scale3(basis[2], v[2]))));
  }
  return points;
}

// ---------------------------------------------------------------- prototypes

// One quarry stone, as split rock armour is: a block cut by random planes
// into a convex polytope with flat broken faces and sharp edges. The block's
// six faces are tilted and set in a little (split, not sawn); further cuts
// take off corners and edges, deep or shallow, so each stone has faces of
// many sizes. Flat-shaded: every face has its own normal, so the edges stay
// sharp. Normalized so the widest horizontal extent is 1 and the lowest
// vertex lies at y = 0; size_m gives [1, height, depth]. relative_height (0 at
// the bottom, 1 at the top) lets the shader darken the buried base.
function quarryPrototype(seed, index) {
  const rng = random(seed, `boulder:${index}`);
  const half = [1, 0.5 + 0.38 * rng(), 0.55 + 0.42 * rng()];
  const support = (n) => Math.abs(n[0]) * half[0] + Math.abs(n[1]) * half[1] + Math.abs(n[2]) * half[2];
  const jitter = (amount) => [(rng() - 0.5) * amount, (rng() - 0.5) * amount, (rng() - 0.5) * amount];
  const planes = [];
  for (const axis of [[1, 0, 0], [-1, 0, 0], [0, 1, 0], [0, -1, 0], [0, 0, 1], [0, 0, -1]]) {
    const n = unit3(add3(axis, jitter(0.55)));
    planes.push({ n, o: support(n) * (0.8 + 0.18 * rng()) });
  }
  const cuts = 7 + (index % 4);
  for (let k = 0; k < cuts; k += 1) {
    const z = rng() * 2 - 1;
    const theta = rng() * Math.PI * 2;
    const r = Math.sqrt(1 - z * z);
    const n = [r * Math.cos(theta), z, r * Math.sin(theta)];
    planes.push({ n, o: support(n) * (0.66 + 0.24 * rng()) });
  }
  // Vertices: every point where three planes meet inside all the others.
  const points = [];
  for (let i = 0; i < planes.length; i += 1) {
    for (let j = i + 1; j < planes.length; j += 1) {
      for (let k = j + 1; k < planes.length; k += 1) {
        const [a, b, c] = [planes[i], planes[j], planes[k]];
        const bc = cross3(b.n, c.n);
        const determinant = dot3(a.n, bc);
        if (Math.abs(determinant) < 1e-9) continue;
        const p = scale3(add3(add3(scale3(bc, a.o), scale3(cross3(c.n, a.n), b.o)), scale3(cross3(a.n, b.n), c.o)), 1 / determinant);
        if (planes.some((plane) => dot3(plane.n, p) > plane.o + 1e-7)) continue;
        if (!points.some((q) => length3(sub3(p, q)) < 1e-6)) points.push(p);
      }
    }
  }
  invariant(points.length >= 8, `Quarry stone ${index} is degenerate`);
  const extent = (axis) => [Math.min(...points.map((p) => p[axis])), Math.max(...points.map((p) => p[axis]))];
  const [minX, maxX] = extent(0);
  const [minY, maxY] = extent(1);
  const [minZ, maxZ] = extent(2);
  const widest = Math.max(maxX - minX, maxZ - minZ);
  const height = (maxY - minY) / widest;
  const placed = points.map((p) => [(p[0] - (minX + maxX) / 2) / widest, (p[1] - minY) / widest, (p[2] - (minZ + maxZ) / 2) / widest]);
  // Faces: the vertices on each plane, in order around their centroid.
  const mesh = { vertices: [], normals: [], indices: [] };
  const relative = [];
  let faces = 0;
  for (const plane of planes) {
    const on = points.map((p, index2) => [p, index2]).filter(([p]) => Math.abs(dot3(plane.n, p) - plane.o) < 1e-6).map(([, index2]) => index2);
    if (on.length < 3) continue;
    const centroid = scale3(on.reduce((sum, index2) => add3(sum, points[index2]), [0, 0, 0]), 1 / on.length);
    const u = unit3(Math.abs(plane.n[1]) < 0.9 ? cross3(plane.n, [0, 1, 0]) : cross3(plane.n, [1, 0, 0]));
    const w = cross3(plane.n, u);
    on.sort((left, right) => {
      const a = sub3(points[left], centroid);
      const b = sub3(points[right], centroid);
      return Math.atan2(dot3(a, w), dot3(a, u)) - Math.atan2(dot3(b, w), dot3(b, u));
    });
    // Normalization only translates and scales uniformly: the plane normal stays the face normal.
    const ids = on.map((index2) => {
      relative.push(round2(Math.max(0, Math.min(1, placed[index2][1] / height))));
      return pushVertex(mesh, placed[index2], plane.n);
    });
    for (let k = 1; k + 1 < ids.length; k += 1) pushTriangle(mesh, [ids[0], ids[k], ids[k + 1]], plane.n);
    faces += 1;
  }
  invariant(faces >= 6 && mesh.indices.length >= 24, `Quarry stone ${index} has too few faces`);
  return {
    id: `boulder_${index}`,
    kind: "boulder",
    material_key: SHORELINE_BOULDER_MATERIAL,
    size_m: [1, round3(height), round3((maxZ - minZ) / widest)],
    ...mesh,
    relative_height: relative,
    lods: [],
  };
}

// One bleached driftwood log, 1 long along x and 1 thick, bent, tapered and
// gnarled (its girth wanders around and along it), its axis at y = 0;
// instances scale it to length (x) and thickness (y and z alike).
function logPrototype(seed) {
  const rng = random(seed, "log");
  const mesh = { vertices: [], normals: [], indices: [] };
  const sides = 9;
  const stations = [[-0.5, 0.72], [-0.36, 0.95], [-0.15, 1.0], [0.08, 0.86], [0.3, 0.9], [0.5, 0.55]];
  const bend = (x) => 0.05 * Math.cos(x * Math.PI) + 0.02 * Math.sin(x * 7);
  const rings = stations.map(([x, radius]) => {
    const ring = [];
    for (let k = 0; k < sides; k += 1) {
      const angle = (k / sides) * Math.PI * 2;
      const girth = radius * 0.5 * (0.84 + 0.3 * rng());
      ring.push([x, Math.sin(angle) * girth * 0.9, bend(x) + Math.cos(angle) * girth]);
    }
    return ring;
  });
  const axisAt = (x) => [x, 0, bend(x)];
  for (let s = 0; s + 1 < rings.length; s += 1) {
    for (let k = 0; k < sides; k += 1) {
      const quad = [rings[s][k], rings[s][(k + 1) % sides], rings[s + 1][(k + 1) % sides], rings[s + 1][k]];
      const middle = scale3(quad.reduce((sum, p) => add3(sum, p), [0, 0, 0]), 0.25);
      const outward = unit3(sub3(middle, axisAt(middle[0])));
      const corners = quad.map((p) => pushVertex(mesh, p, unit3(sub3(p, axisAt(p[0])))));
      pushTriangle(mesh, [corners[0], corners[1], corners[2]], outward);
      pushTriangle(mesh, [corners[0], corners[2], corners[3]], outward);
    }
  }
  for (const [ring, normal] of [[rings[0], [-1, 0, 0]], [rings.at(-1), [1, 0, 0]]]) {
    const middle = scale3(ring.reduce((sum, p) => add3(sum, p), [0, 0, 0]), 1 / ring.length);
    const centerIndex = pushVertex(mesh, middle, normal);
    const corners = ring.map((p) => pushVertex(mesh, p, normal));
    for (let k = 0; k < sides; k += 1) pushTriangle(mesh, [centerIndex, corners[k], corners[(k + 1) % sides]], normal);
  }
  return { id: "log", kind: "log", material_key: SHORELINE_DRIFTWOOD_MATERIAL, ...mesh, lods: [] };
}

// One weathered plank: a unit box along x (y up, z across) whose far end has
// broken off unevenly.
function plankPrototype() {
  const mesh = { vertices: [], normals: [], indices: [] };
  const end = (z) => (z < 0 ? 0.5 : 0.36);
  const quad = (points, normal) => {
    const ids = points.map((p) => pushVertex(mesh, p, normal));
    pushTriangle(mesh, [ids[0], ids[1], ids[2]], normal);
    pushTriangle(mesh, [ids[0], ids[2], ids[3]], normal);
  };
  for (const y of [-0.5, 0.5]) quad([[-0.5, y, -0.5], [end(-0.5), y, -0.5], [end(0.5), y, 0.5], [-0.5, y, 0.5]], [0, Math.sign(y), 0]);
  for (const z of [-0.5, 0.5]) quad([[-0.5, -0.5, z], [end(z), -0.5, z], [end(z), 0.5, z], [-0.5, 0.5, z]], [0, 0, Math.sign(z)]);
  quad([[-0.5, -0.5, -0.5], [-0.5, 0.5, -0.5], [-0.5, 0.5, 0.5], [-0.5, -0.5, 0.5]], [-1, 0, 0]);
  quad([[end(-0.5), -0.5, -0.5], [end(-0.5), 0.5, -0.5], [end(0.5), 0.5, 0.5], [end(0.5), -0.5, 0.5]], unit3([1, 0, 0.14]));
  return { id: "plank", kind: "plank", material_key: SHORELINE_DRIFTWOOD_MATERIAL, ...mesh, lods: [] };
}

// ---------------------------------------------------------------- outline

// The island outline (counterclockwise, land on the left) with distance s
// along it. s may run past the perimeter: segments that cross the outline's
// start (s = 0) wrap around.
function outlineOf(boundary) {
  invariant(boundary.length === 1, "Shoreline expects a single island polygon");
  const ring = openRing(boundary[0][0]);
  invariant(signedRingArea(ring) > 0, "The island outline must run counterclockwise (land on its left)");
  const cumulative = [0];
  for (let index = 1; index <= ring.length; index += 1) {
    cumulative.push(cumulative[index - 1] + length(sub(ring[index % ring.length], ring[index - 1])));
  }
  const perimeter = cumulative.at(-1);
  const wrap = (s) => ((s % perimeter) + perimeter) % perimeter;
  const segmentAt = (s) => {
    const t = wrap(s);
    let low = 0;
    let high = ring.length - 1;
    while (low < high) {
      const middle = (low + high + 1) >> 1;
      if (cumulative[middle] <= t) low = middle;
      else high = middle - 1;
    }
    return low;
  };
  const pointAt = (s) => {
    const t = wrap(s);
    const index = segmentAt(t);
    const a = ring[index];
    const b = ring[(index + 1) % ring.length];
    return add(a, scale(sub(b, a), (t - cumulative[index]) / (cumulative[index + 1] - cumulative[index])));
  };
  // Outward normal (toward the water) of segment index: right of travel.
  const segmentNormal = (index) => {
    const direction = unit(sub(ring[(index + 1) % ring.length], ring[index]));
    return [direction[1], -direction[0]];
  };
  // Ring edges overlapping [s - radius, s + radius], across the start too.
  const edgesNear = (s, radius) => {
    const found = [];
    for (const offset of [-perimeter, 0, perimeter]) {
      const lo = s - radius - offset;
      const hi = s + radius - offset;
      if (hi < 0 || lo >= perimeter) continue;
      for (let index = segmentAt(Math.max(0, lo)); index < ring.length; index += 1) {
        if (cumulative[index] > hi) break;
        if (cumulative[index + 1] >= lo) found.push(index);
      }
    }
    return found;
  };
  // Smoothed outward normal: segment normals weighted by their overlap with
  // [s - radius, s + radius], so cross-sections never fold at a bend.
  const normalAt = (s, radius) => {
    let sum = [0, 0];
    for (const offset of [-perimeter, 0, perimeter]) {
      const lo = s - radius - offset;
      const hi = s + radius - offset;
      if (hi < 0 || lo >= perimeter) continue;
      for (let index = segmentAt(Math.max(0, lo)); index < ring.length; index += 1) {
        if (cumulative[index] > hi) break;
        const overlap = Math.min(cumulative[index + 1], hi) - Math.max(cumulative[index], lo);
        if (overlap > 0) sum = add(sum, scale(segmentNormal(index), overlap));
      }
    }
    return unit(sum);
  };
  // Signed distance of a point from the outline near s: positive over the
  // water. At a ring vertex the sign comes from the bisector of its edges.
  const outsideDistance = (point, s, radius = 12) => {
    let best = null;
    for (const index of edgesNear(s, radius)) {
      const a = ring[index];
      const delta = sub(ring[(index + 1) % ring.length], a);
      const t = Math.max(0, Math.min(1, dot(sub(point, a), delta) / dot(delta, delta)));
      const closest = add(a, scale(delta, t));
      const distance = length(sub(point, closest));
      if (!best || distance < best.distance) best = { distance, index, t, closest };
    }
    invariant(best, `No outline edge near s=${s}`);
    let normal = segmentNormal(best.index);
    if (best.t <= 1e-9 || best.t >= 1 - 1e-9) {
      const vertex = best.t <= 1e-9 ? best.index : (best.index + 1) % ring.length;
      normal = unit(add(segmentNormal((vertex - 1 + ring.length) % ring.length), segmentNormal(vertex)));
    }
    return (dot(sub(point, best.closest), normal) >= 0 ? 1 : -1) * best.distance;
  };
  // Ring-vertex distances strictly between s0 and s1 (s1 may pass the perimeter).
  const breakpoints = (s0, s1) => {
    const found = [];
    for (const offset of [0, perimeter]) {
      for (let index = 0; index < ring.length; index += 1) {
        const s = cumulative[index] + offset;
        if (s > s0 && s < s1) found.push(s);
      }
    }
    return found.sort((left, right) => left - right);
  };
  // Distance along the outline of the outline point nearest a plan point, in [0, perimeter).
  const nearestS = (point) => {
    let best = null;
    for (let index = 0; index < ring.length; index += 1) {
      const a = ring[index];
      const delta = sub(ring[(index + 1) % ring.length], a);
      const span = dot(delta, delta);
      const t = Math.max(0, Math.min(1, dot(sub(point, a), delta) / span));
      const distance = length(sub(point, add(a, scale(delta, t))));
      if (!best || distance < best.distance) best = { distance, s: cumulative[index] + t * Math.sqrt(span) };
    }
    return best.s;
  };
  // Distance along the outline of a point lying on it (or null), in [0, perimeter).
  const distanceOf = (point, tolerance) => {
    let best = null;
    for (let index = 0; index < ring.length; index += 1) {
      const a = ring[index];
      const delta = sub(ring[(index + 1) % ring.length], a);
      const span = dot(delta, delta);
      const t = Math.max(0, Math.min(1, dot(sub(point, a), delta) / span));
      const distance = length(sub(point, add(a, scale(delta, t))));
      if (distance <= tolerance && (!best || distance < best.distance)) best = { distance, s: cumulative[index] + t * Math.sqrt(span) };
    }
    return best?.s ?? null;
  };
  return { ring, perimeter, wrap, pointAt, normalAt, outsideDistance, breakpoints, distanceOf, nearestS };
}

// The region swept by cross-sections from s0 to s1, reaching `reach` inland and
// out over the water.
function windowPolygon(outline, s0, s1, reach) {
  const stations = [s0, ...outline.breakpoints(s0, s1), s1];
  const inner = stations.map((s) => add(outline.pointAt(s), scale(outline.normalAt(s, 6), -reach)));
  const outer = stations.map((s) => add(outline.pointAt(s), scale(outline.normalAt(s, 6), reach)));
  const ring = [...inner, ...outer.reverse()];
  return [[signedRingArea(ring) > 0 ? ring : ring.reverse()]];
}

// [s0, s1] of a segment, s1 > s0, s1 past the perimeter when it wraps.
function segmentRange(segment, perimeter) {
  const [start, end] = segment.s_m;
  invariant(start < perimeter && end <= perimeter, `Shoreline segment ${segment.id} runs past the end of the outline (${perimeter.toFixed(1)} m)`);
  const s1 = end > start ? end : end + perimeter;
  invariant(s1 - start >= 10 && s1 - start < perimeter, `Shoreline segment ${segment.id} must span 10 m to less than the whole outline`);
  return [start, s1];
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
    const [s0, s1] = segmentRange(segment, outline.perimeter);
    const window = windowPolygon(outline, s0, s1, WINDOW_REACH_M);
    const inner = guarded(`segment ${segment.id} inner band`, () => polygonClipping.intersection(object.geometry, window));
    invariant(multiPolygonArea(inner) > 1, `Shoreline segment ${segment.id} has no breakwater inside the outline`);
    const footprint = rawWayFootprint(rawOsm, segment.source_key.slice(1));
    const outer = guarded(`segment ${segment.id} outer band`, () => polygonClipping.intersection(polygonClipping.difference(footprint, boundary), window));
    const previous = innerBySource.get(segment.source_key);
    innerBySource.set(segment.source_key, previous ? guarded("inner union", () => polygonClipping.union(previous, inner)) : inner);
    return { ...segment, s0, s1, window, inner, outer };
  });
  return { settings, outline, segments, innerBySource, overlay_bias_m: settings.overlay_bias_m };
}

// OSM structures near a window (piers, slipways ...) that clear the riprap,
// from config.structures: kind -> { tags, slope: keep | cut, clearance_m }.
function structuresNear(settings, playableObjects, rawOsm, window) {
  const windowBounds = multiPolygonBounds(window);
  const found = [];
  for (const object of [...playableObjects.values()].sort((left, right) => left.row.source_key.localeCompare(right.row.source_key))) {
    if (object.row.osm_type !== "way") continue;
    const kind = Object.keys(settings.structures).sort().find((name) => settings.structures[name].tags.some((tag) => {
      const [key, value] = tag.split("=");
      return object.tags[key] === value;
    }));
    if (!kind) continue;
    const footprint = rawWayFootprint(rawOsm, object.row.osm_id);
    if (footprint.length === 0 || !boundsOverlap(multiPolygonBounds(footprint), windowBounds)) continue;
    if (guarded(`structure ${object.row.source_key}`, () => polygonClipping.intersection(footprint, window)).length === 0) continue;
    const rule = settings.structures[kind];
    found.push({ source_key: object.row.source_key, kind, slope: rule.slope, clearance_m: rule.clearance_m, under_drop_m: rule.under_drop_m, area: indexedArea(footprint) });
  }
  return found;
}

// ---------------------------------------------------------------- generate

export function generateShoreline({ plan, configDescriptor, facetsForChunk, facetElevation, terrain, spawnXZ, hardShapes, playableObjects, rawOsm }) {
  const { settings, outline } = plan;
  const seed = settings.seed;
  const slope = settings.slope;
  const rules = settings.stones;
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
  const roadAreas = [...playableObjects.values()]
    .filter((object) => object.roles.includes("roads_paths") && object.geometry.length > 0)
    .map((object) => indexedArea(object.geometry));
  const hard = hardShapes.map((shape) => ({ ...shape, points: shape.points.map(([x, z]) => [x, -z]) }));

  const prototypes = [];
  for (let index = 0; index < rules.prototypes; index += 1) prototypes.push(quarryPrototype(seed, index));
  const log = logPrototype(seed);
  const plank = plankPrototype();
  prototypes.push(log, plank);

  const records = [];
  const stones = [];
  const segmentSummaries = [];
  for (const segment of plan.segments) {
    const { s0, s1 } = segment;
    const structures = structuresNear(settings, playableObjects, rawOsm, segment.window);
    const windowBounds = multiPolygonBounds(segment.window);
    const nearRoads = roadAreas.filter((area) => boundsOverlap(area.bounds, windowBounds));
    // Why a point cannot hold a stone of this radius, or null. Structures clear
    // stones, except stones that top out under_drop_m below the land edge
    // (dropBelowLand) under a kept structure; paths only matter inside the outline.
    const blocked = (point, radius, inside, dropBelowLand = 0) => {
      for (const structure of structures) {
        if (!nearBounds(structure.area, point, structure.clearance_m + radius)) continue;
        if (pointInMultiPolygon(point, structure.area.multi) || edgeDistance(structure.area, point) < structure.clearance_m + radius) {
          if (structure.under_drop_m != null && dropBelowLand >= structure.under_drop_m) continue;
          return structure.kind;
        }
      }
      for (const shape of hard) {
        const distance = shape.points.length === 1
          ? length(sub(point, shape.points[0]))
          : Math.min(...shape.points.slice(1).map((p, index) => distanceToSegment(point, shape.points[index], p)));
        if (distance < shape.radius_m + radius) return shape.component ?? "hard";
      }
      if (spawnXZ && length(sub(point, [spawnXZ[0], -spawnXZ[1]])) < 6.5 + radius) return "spawn";
      if (inside) {
        const clearance = rules.cobble.path_clearance_m + radius;
        for (const road of nearRoads) {
          if (!nearBounds(road, point, clearance)) continue;
          if (pointInMultiPolygon(point, road.multi) || edgeDistance(road, point) < clearance) return "path";
        }
      }
      return null;
    };

    // Stations: every station_m, plus each land-edge breakpoint on the outline
    // so the slope's top edge follows the land edge exactly.
    const forced = new Set([s0, s1, ...outline.breakpoints(s0, s1)]);
    const seen = new Set();
    for (let s = s0; s <= s1 + 19.999; s += 20) {
      const p = outline.pointAt(Math.min(s, s1));
      for (const facet of facetsNear(p[0], p[1])) {
        for (const vertex of facet.vertices) {
          const key = `${vertex.east},${vertex.north}`;
          if (seen.has(key)) continue;
          seen.add(key);
          let along = outline.distanceOf([vertex.east, vertex.north], EDGE_VERTEX_TOLERANCE_M);
          if (along == null) continue;
          if (along < s0) along += outline.perimeter;
          if (along > s0 && along < s1) forced.add(along);
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
      return { s, point, normal, land, top: land + bias, raw_gradient: (demNear - demFar) / (slope.dem_fit_m[1] - slope.dem_fit_m[0]) };
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
      section.water_m = slope.shoulder_m + (section.top - WATER_Y_M) / section.gradient;
      section.toe_m = slope.shoulder_m + (section.top - slope.toe_y_m) / section.gradient;
    }
    // The shoulder is flat at the land edge's height; the slope drops behind it.
    const surfaceAt = (section, d, east, north) => {
      const past = Math.max(0, d - slope.shoulder_m);
      const relief = slope.relief_m * rockRelief(seed, east, north, slope.relief_wavelength_m) * smoothstep(0, slope.top_blend_m, past);
      return Math.min(section.top - 0.02 * Math.min(1, past / 0.2), section.top - section.gradient * past + relief);
    };

    // ------------------------------------------------------------ underlay slope
    const grid = sections.map((section) => {
      const row = [];
      for (let column = 0; column <= slope.columns; column += 1) {
        const d = slope.shoulder_m + ((section.toe_m - slope.shoulder_m) * column) / slope.columns;
        const plan2 = add(section.point, scale(section.normal, d));
        const y = column === 0 ? section.top : surfaceAt(section, d, plan2[0], plan2[1]);
        row.push({ d, plan: plan2, world: [plan2[0], y, -plan2[1]] });
      }
      return row;
    });
    const vertexNormal = (i, j) => {
      const at = (a, b) => grid[Math.max(0, Math.min(grid.length - 1, a))][Math.max(0, Math.min(slope.columns, b))].world;
      let normal = unit3(cross3(sub3(at(i + 1, j), at(i - 1, j)), sub3(at(i, j + 1), at(i, j - 1))));
      if (normal[1] < 0) normal = scale3(normal, -1);
      return normal;
    };
    // Structures whose slope is "cut" (slipways, ramps) open a hole in the slope.
    const cuts = structures.filter((structure) => structure.slope === "cut");
    const cutAway = (points) => {
      const centroid = scale(points.reduce((sum, p) => add(sum, p), [0, 0]), 1 / points.length);
      return cuts.some((structure) => nearBounds(structure.area, centroid, structure.clearance_m)
        && (pointInMultiPolygon(centroid, structure.area.multi) || edgeDistance(structure.area, centroid) < structure.clearance_m));
    };
    const sectionCount = Math.max(1, Math.round((s1 - s0) / slope.section_m));
    const recordOf = (s) => Math.min(sectionCount - 1, Math.floor(((s - s0) / (s1 - s0)) * sectionCount));
    const meshes = Array.from({ length: sectionCount }, () => ({ vertices: [], normals: [], indices: [], shared: new Map() }));
    // The shoulder strip, from the outline (d = 0) to the slope's first column,
    // flat at the land edge's height; UVs are the land's (world x / 10, z / 10),
    // so the verge's ground cover continues across the outline without a seam.
    const verges = Array.from({ length: sectionCount }, () => ({ vertices: [], normals: [], uvs: [], indices: [] }));
    const inner = sections.map((section) => [section.point[0], section.top, -section.point[1]]);
    for (let i = 0; i + 1 < grid.length; i += 1) {
      if (cutAway([sections[i].point, sections[i + 1].point, grid[i + 1][0].plan, grid[i][0].plan])) continue;
      const mesh = verges[recordOf((sections[i].s + sections[i + 1].s) / 2)];
      const corners = [inner[i], inner[i + 1], grid[i + 1][0].world, grid[i][0].world];
      const up = unit3(cross3(sub3(corners[1], corners[0]), sub3(corners[3], corners[0])));
      const normal = up[1] < 0 ? scale3(up, -1) : up;
      const ids = corners.map((corner) => {
        mesh.uvs.push(roundCoordinate(corner[0] / 10), roundCoordinate(corner[2] / 10));
        return pushVertex(mesh, corner, normal);
      });
      pushTriangle(mesh, [ids[0], ids[1], ids[2]], normal);
      pushTriangle(mesh, [ids[0], ids[2], ids[3]], normal);
    }
    for (let i = 0; i + 1 < grid.length; i += 1) {
      const mesh = meshes[recordOf((sections[i].s + sections[i + 1].s) / 2)];
      const index = (row, column) => {
        const key = row * (slope.columns + 1) + column;
        if (!mesh.shared.has(key)) mesh.shared.set(key, pushVertex(mesh, grid[row][column].world, vertexNormal(row, column)));
        return mesh.shared.get(key);
      };
      for (let column = 0; column < slope.columns; column += 1) {
        if (cutAway([grid[i][column].plan, grid[i + 1][column].plan, grid[i + 1][column + 1].plan, grid[i][column + 1].plan])) continue;
        const [a, b, c, d] = [index(i, column), index(i + 1, column), index(i + 1, column + 1), index(i, column + 1)];
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
      const row = [{ world: inner[rowIndex] }, ...grid[rowIndex]];
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
    verges.forEach((mesh, index) => {
      if (mesh.indices.length === 0) return;
      records.push({
        object_key: `shoreline-verge:${segment.id}:${index}`,
        segment: segment.id,
        section: index,
        source_keys: [segment.source_key],
        material_key: SHORELINE_VERGE_MATERIAL,
        vertices: mesh.vertices,
        normals: mesh.normals,
        uvs: mesh.uvs,
        indices: mesh.indices,
      });
    });

    // ------------------------------------------------------------ stones
    const sectionAtS = (s) => {
      let low = 0;
      let high = sections.length - 1;
      while (high - low > 1) {
        const middle = (low + high) >> 1;
        if (sections[middle].s <= s) low = middle;
        else high = middle;
      }
      const span = sections[high].s - sections[low].s;
      const t = span > 0 ? Math.max(0, Math.min(1, (s - sections[low].s) / span)) : 0;
      const a = sections[low];
      const b = sections[high];
      return {
        s,
        point: outline.pointAt(s),
        normal: unit(add(scale(a.normal, 1 - t), scale(b.normal, t))),
        land: lerp(a.land, b.land, t),
        top: lerp(a.top, b.top, t),
        gradient: lerp(a.gradient, b.gradient, t),
        water_m: lerp(a.water_m, b.water_m, t),
        toe_m: lerp(a.toe_m, b.toe_m, t),
      };
    };
    const slopeNormal = (section) => unit3([section.gradient * section.normal[0], 1, -section.gradient * section.normal[1]]);
    const planeAt = (section, d) => section.top - section.gradient * Math.max(0, d - slope.shoulder_m);
    const planAt = (section, d) => add(section.point, scale(section.normal, d));
    // Plan angle of the shore direction (counterclockwise along the outline).
    const tangentAngle = (section) => Math.atan2(section.normal[0], -section.normal[1]);
    const batchSection = (s) => Math.max(0, Math.floor((s - s0) / rules.section_m));
    const tintFor = (rng) => {
      // Mid-to-dark grey as in the 2025 photos, with the rust-brown and olive
      // stones of the 2021 photos, some darker and a few paler weathered ones;
      // multiplied onto the boulder texture, at most 1.
      const family = rng();
      const base = family < 0.4 ? [1, 1, 1] : family < 0.64 ? [1, 0.88, 0.74] : family < 0.77 ? [0.9, 0.93, 0.8] : family < 0.9 ? [0.7, 0.7, 0.7] : [1, 0.98, 0.95];
      const shade = family >= 0.9 ? 0.95 + 0.05 * rng() : 0.72 + 0.26 * rng();
      return base.map((value) => value * shade);
    };
    // Spatial hash over every stone of the segment, for overlap tests and for
    // resting wood on the stone tops.
    const cellSize = 1.6;
    const hash = new Map();
    const neighbours = (point) => {
      const found = [];
      const cx = Math.floor(point[0] / cellSize);
      const cy = Math.floor(point[1] / cellSize);
      for (let dx = -1; dx <= 1; dx += 1) for (let dy = -1; dy <= 1; dy += 1) found.push(...(hash.get(`${cx + dx},${cy + dy}`) ?? []));
      return found;
    };
    const fits = (point, radius, overlap) => neighbours(point).every((other) => length(sub(point, other.plan)) >= overlap * (radius + other.radius));
    const remember = (stone) => {
      const key = `${Math.floor(stone.plan[0] / cellSize)},${Math.floor(stone.plan[1] / cellSize)}`;
      if (!hash.has(key)) hash.set(key, []);
      hash.get(key).push(stone);
      stones.push(stone);
    };
    // The closest any LOD-0 vertex of a placement comes to the outline from the
    // water side (negative when it reaches inside).
    const clearOfOutline = (prototype, q, scales, origin, s) => {
      let least = Infinity;
      for (const point of placedVertices(prototype, q, scales, origin)) least = Math.min(least, outline.outsideDistance([point[0], -point[2]], s));
      return least;
    };
    const boulders = prototypes.filter((prototype) => prototype.id.startsWith("boulder_"));
    // One stone of `prototype`, scaled uniformly to `size`, its cut base at
    // bottomY; returns its record with its actual world top and reach.
    const makeStone = ({ band, s, d, plan2, rng, size, prototype, up, yaw, bottomY }) => {
      const q = quaternionFor(up, yaw);
      const scales = [size, size, size];
      const origin = [plan2[0], bottomY, -plan2[1]];
      const points = placedVertices(prototype, q, scales, origin);
      return {
        band, s, d, plan: plan2, radius: (size * (1 + prototype.size_m[2])) / 4, prototype, prototypeId: prototype.id, section: batchSection(s),
        q, scales, origin, tint: tintFor(rng),
        top: Math.max(...points.map((point) => point[1])),
        reach: Math.max(...points.map((point) => Math.hypot(point[0] - origin[0], point[2] - origin[2]))),
      };
    };
    const outsideOk = (stone) => stone.d - stone.reach >= rules.setback_m + 0.3
      || clearOfOutline(stone.prototype, stone.q, stone.scales, stone.origin, stone.s) >= SHORELINE_OUTSIDE_CLEARANCE_M;
    // A stone's height above its base along world y, per unit size.
    const rise = (prototype, up) => prototype.size_m[1] * up[1];
    // Stones never spill past the segment's end caps.
    const insideEnds = (s, size) => s - size * 0.6 >= s0 && s + size * 0.6 <= s1;
    // `base` tilted by up to maxDeg about a random horizontal axis: quarry
    // stones come to rest on whichever face they fall on.
    const leanUp = (base, maxDeg, rng) => {
      const tilt = ((rng() - 0.5) * 2 * maxDeg * Math.PI) / 180;
      const axis = rng() * Math.PI * 2;
      return unit3(add3(unit3(base), [Math.sin(tilt) * Math.cos(axis), 0, Math.sin(tilt) * Math.sin(axis)]));
    };

    // Top row: big quarry stones just beyond the outline, their inner faces at
    // least setback_m out (about the player's radius, so the player is
    // recovered before it can reach into one). Each is buried by a share of
    // its own height, so big stones stand tall and small ones low, up to
    // max_rise_m above the land edge; sizes, spacing and tilt vary stone by
    // stone, so the crest skyline breaks up as in the plaza photos.
    const topRule = rules.top;
    for (let s = s0, k = 0; s < s1; k += 1) {
      const rng = random(seed, `${segment.id}:top:${k}`);
      const size = pick(topRule.size_m, rng);
      const sAt = s + size * 0.5;
      s += size * pick(topRule.spacing, rng);
      if (!insideEnds(sAt, size)) continue;
      const section = sectionAtS(sAt);
      const prototype = boulders[Math.floor(rng() * boulders.length)];
      const yaw = rng() * Math.PI * 2;
      const up = leanUp(add3(scale3(slopeNormal(section), 0.3), [0, 0.7, 0]), topRule.tilt_deg, rng);
      const stoneHeight = size * rise(prototype, up);
      const bury = pick(topRule.bury, rng);
      const bedAt = (d) => Math.min(planeAt(section, d) - stoneHeight * bury, section.land + topRule.max_rise_m - stoneHeight);
      let d = rules.setback_m + size * 0.42 + pick(topRule.out_jitter_m, rng);
      let plan2 = planAt(section, d);
      if (blocked(plan2, size * 0.5, false)) continue;
      let stone = makeStone({ band: "top", s: sAt, d, plan2, rng, size, prototype, up, yaw, bottomY: bedAt(d) });
      const clear = clearOfOutline(prototype, stone.q, stone.scales, stone.origin, sAt);
      if (clear < rules.setback_m) {
        // Push it out just far enough, once.
        d += rules.setback_m - clear + 0.02;
        plan2 = planAt(section, d);
        stone = makeStone({ band: "top", s: sAt, d, plan2, rng, size, prototype, up, yaw, bottomY: bedAt(d) });
        if (!outsideOk(stone) || blocked(plan2, size * 0.5, false)) continue;
      }
      remember(stone);
    }
    // Back row: big stones piled behind the top row, within depth_m of the
    // setback, aiming their tops rise_m above the land edge (less drop_per_m
    // further out) but always bedded at least 0.1 m into the slope, so the big
    // ones rise above the top row and the small ones sit lower in the pile.
    const crest = rules.crest;
    {
      const meanSize = (crest.size_m[0] + crest.size_m[1]) / 2;
      const target = Math.ceil(((s1 - s0) * crest.depth_m * crest.fill) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${segment.id}:crest`);
      let placed = 0;
      for (let attempt = 0; attempt < target * 12 && placed < target; attempt += 1) {
        const size = pick(crest.size_m, rng);
        const sAt = lerp(s0, s1, rng());
        if (!insideEnds(sAt, size)) continue;
        const section = sectionAtS(sAt);
        const prototype = boulders[Math.floor(rng() * boulders.length)];
        const radius = (size * (1 + prototype.size_m[2])) / 4;
        const d = rules.setback_m + radius + rng() * crest.depth_m;
        const plan2 = planAt(section, d);
        if (!fits(plan2, radius, rules.heap.overlap) || blocked(plan2, radius, false)) continue;
        const up = leanUp(add3(scale3(slopeNormal(section), 0.55), [0, 0.45, 0]), topRule.tilt_deg, rng);
        const topY = section.land + pick(crest.rise_m, rng) - crest.drop_per_m * (d - rules.setback_m);
        const bottomY = Math.min(planeAt(section, d) - 0.1, topY - size * rise(prototype, up));
        const stone = makeStone({ band: "top", s: sAt, d, plan2, rng, size, prototype, up, yaw: rng() * Math.PI * 2, bottomY });
        if (!outsideOk(stone)) continue;
        remember(stone);
        placed += 1;
      }
    }
    // Shoulder stones: small stones bedded in the shoulder between the outline
    // and the top row, rising rise_m above it, so the strip reads as the dirt
    // and stone at the top of the riprap in the photos, not as a trench. Like
    // every stone outside, they keep clear of the outline.
    const shoulderRule = rules.shoulder;
    {
      const meanSize = (shoulderRule.size_m[0] + shoulderRule.size_m[1]) / 2;
      const target = Math.ceil(((s1 - s0) * (slope.shoulder_m + 0.4) * shoulderRule.fill) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${segment.id}:shoulder`);
      let placed = 0;
      for (let attempt = 0; attempt < target * 15 && placed < target; attempt += 1) {
        const size = pick(shoulderRule.size_m, rng);
        const sAt = lerp(s0, s1, rng());
        if (!insideEnds(sAt, size)) continue;
        const section = sectionAtS(sAt);
        const prototype = boulders[Math.floor(rng() * boulders.length)];
        const radius = (size * (1 + prototype.size_m[2])) / 4;
        const d = SHORELINE_OUTSIDE_CLEARANCE_M + radius + rng() * (slope.shoulder_m + 0.4);
        const plan2 = planAt(section, d);
        if (!fits(plan2, radius, 0.9) || blocked(plan2, radius, false)) continue;
        const up = leanUp([0, 1, 0], topRule.tilt_deg, rng);
        const bottomY = Math.min(planeAt(section, d) - 0.04, section.top + pick(shoulderRule.rise_m, rng) - size * rise(prototype, up));
        const stone = makeStone({ band: "heap", s: sAt, d, plan2, rng, size, prototype, up, yaw: rng() * Math.PI * 2, bottomY });
        if (clearOfOutline(prototype, stone.q, stone.scales, stone.origin, sAt) < SHORELINE_OUTSIDE_CLEARANCE_M) continue;
        remember(stone);
        placed += 1;
      }
    }
    // Heap: random sequential packing of the slope from behind the crest to
    // just past the toe, largest stones first; neighbours may overlap by up to
    // 1 - overlap of their radii, so the stones close up into one pile. Past
    // the waterline only stones that stand clear of the water are kept: one
    // that would just break the surface would read as a pebble dotted
    // offshore, and a sunk one shows through the water only as a smudge.
    const heap = rules.heap;
    const meanToe = sections.reduce((sum, section) => sum + section.toe_m, 0) / sections.length;
    const heapArea = (s1 - s0) * (meanToe + heap.toe_extra_m);
    for (const [classIndex, sizeClass] of heap.classes.entries()) {
      const meanSize = (sizeClass.size_m[0] + sizeClass.size_m[1]) / 2;
      const target = Math.ceil((heapArea * sizeClass.fill) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${segment.id}:heap:${classIndex}`);
      let placed = 0;
      for (let attempt = 0; attempt < target * 12 && placed < target; attempt += 1) {
        const size = pick(sizeClass.size_m, rng);
        const sAt = lerp(s0, s1, rng());
        if (!insideEnds(sAt, size)) continue;
        const section = sectionAtS(sAt);
        const prototype = boulders[Math.floor(rng() * boulders.length)];
        const radius = (size * (1 + prototype.size_m[2])) / 4;
        const d = lerp(rules.setback_m + radius, section.toe_m + heap.toe_extra_m, rng());
        const plan2 = planAt(section, d);
        const tilt = ((rng() - 0.5) * 2 * heap.tilt_deg * Math.PI) / 180;
        const tiltAxis = rng() * Math.PI * 2;
        const lean = [Math.sin(tilt) * Math.cos(tiltAxis), 0, Math.sin(tilt) * Math.sin(tiltAxis)];
        const up = unit3(add3(add3(scale3(slopeNormal(section), 0.7), [0, 0.3, 0]), lean));
        const plane = planeAt(section, d);
        const bottomY = plane - size * (pick(heap.bury, rng) - pick(heap.lift, rng));
        const top = bottomY + size * rise(prototype, up);
        if (d > section.water_m - 0.2 && top < WATER_Y_M + 0.14) continue;
        if (!fits(plan2, radius, heap.overlap) || blocked(plan2, radius, false, section.land - top - 0.1)) continue;
        const stone = makeStone({ band: "heap", s: sAt, d, plan2, rng, size, prototype, up, yaw: rng() * Math.PI * 2, bottomY });
        if (!outsideOk(stone)) continue;
        remember(stone);
        placed += 1;
      }
    }
    // Cobbles: low stones bedded in the band inside the outline, more of them
    // toward the outline, each wholly inside the band (so the overlay's edge
    // never cuts across one) and no higher than the player can walk over
    // without seeming to sink into rock.
    const cobble = rules.cobble;
    const band = indexedArea(segment.inner);
    {
      const meanSize = (cobble.size_m[0] + cobble.size_m[1]) / 2;
      const target = Math.ceil((multiPolygonArea(segment.inner) * cobble.fill) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${segment.id}:cobble`);
      let placed = 0;
      for (let attempt = 0; attempt < target * 15 && placed < target; attempt += 1) {
        const sAt = lerp(s0, s1, rng());
        const section = sectionAtS(sAt);
        const plan2 = planAt(section, -5 * rng() ** (1 + cobble.outline_bias));
        if (!pointInMultiPolygon(plan2, band.multi, false)) continue;
        const size = pick(cobble.size_m, rng);
        // Mostly buried, a cobble shows only its top: three shapes are enough (fewer batches).
        const prototype = boulders[Math.floor(rng() * Math.min(3, boulders.length))];
        const radius = (size * (1 + prototype.size_m[2])) / 4;
        if (edgeDistance(band, plan2) < size * 0.5 + cobble.edge_m || !fits(plan2, radius, 0.95) || blocked(plan2, size * 0.5, true)) continue;
        const ground = landAt(plan2);
        if (ground == null) continue;
        const up = unit3([0.1 * (rng() - 0.5), 1, 0.1 * (rng() - 0.5)]);
        const yaw = rng() * Math.PI * 2;
        // Bury it so only its cap shows, top_m above the land.
        let bottomY = ground + pick(cobble.top_m, rng) - size * rise(prototype, up);
        let stone = makeStone({ band: "cobble", s: sAt, d: -1, plan2, rng, size, prototype, up, yaw, bottomY });
        if (stone.top > ground + cobble.top_m[1]) {
          // Tilt can lift a vertex past the top: lower it to fit.
          bottomY -= stone.top - (ground + cobble.top_m[1]) + 0.002;
          stone = makeStone({ band: "cobble", s: sAt, d: -1, plan2, rng, size, prototype, up, yaw, bottomY });
        }
        if (stone.top > ground + cobble.top_m[1] + 1e-6 || edgeDistance(band, plan2) < stone.reach + cobble.edge_m) continue;
        remember(stone);
        placed += 1;
      }
    }
    // The top of the heap under a plan point: the highest stone surface there,
    // each stone taken as a dome over its footprint.
    const heapTop = (point) => {
      let best = -Infinity;
      for (const stone of neighbours(point)) {
        if (stone.band === "cobble" || stone.band === "driftwood") continue;
        const rho = length(sub(point, stone.plan)) / Math.max(0.05, stone.radius * 1.1);
        if (rho >= 1) continue;
        best = Math.max(best, stone.origin[1] + (stone.top - stone.origin[1]) * Math.sqrt(1 - rho * rho));
      }
      return best;
    };
    // A log or plank resting on the stone tops along its length: lifted to the
    // highest support under each half and pitched between them.
    const placeWood = (s, d, yaw, lengthM, thickness, width, prototype, rng) => {
      const section = sectionAtS(s);
      const plan2 = planAt(section, d);
      if (blocked(plan2, lengthM * 0.5, false)) return false;
      const along = [Math.cos(yaw), Math.sin(yaw)];
      const halves = [[], []];
      for (let k = 0; k <= 8; k += 1) {
        const t = k / 8 - 0.5;
        const top = heapTop(add(plan2, scale(along, t * lengthM)));
        if (Number.isFinite(top)) halves[t < 0 ? 0 : 1].push(top);
      }
      if (halves.some((half) => half.length === 0)) return false;
      const [low, high] = halves.map((half) => Math.max(...half));
      // At most 10 degrees: a log on a steep step rests on the lower stones,
      // wedged against the higher one, rather than pointing at the sky.
      const pitch = Math.max(-0.17, Math.min(0.17, Math.atan2(high - low, lengthM * 0.5)));
      const q = quaternionMultiply(quaternionFor([0, 1, 0], yaw), axisQuaternion([0, 0, 1], pitch));
      const scales = [lengthM, thickness, width];
      const restY = Math.min(low, high) + thickness * 0.3 + Math.abs(Math.tan(pitch)) * lengthM * 0.25;
      const origin = [plan2[0], restY, -plan2[1]];
      if (clearOfOutline(prototype, q, scales, origin, s) < SHORELINE_OUTSIDE_CLEARANCE_M) return false;
      const points = placedVertices(prototype, q, scales, origin);
      const bleach = 0.86 + 0.14 * rng();
      stones.push({
        band: "driftwood", s, d, plan: plan2, radius: lengthM * 0.5, prototype, prototypeId: prototype.id, section: batchSection(s), q, scales, origin,
        tint: [bleach, bleach * 0.98, bleach * 0.94], top: Math.max(...points.map((point) => point[1])), reach: lengthM * 0.5,
      });
      return true;
    };
    // Driftwood: bleached logs caught on the upper heap, lying roughly along
    // the shore (the 2025 photos show several).
    const wood = rules.driftwood;
    for (let s = s0 + wood.spacing_m * 0.5, k = 0; s < s1; s += wood.spacing_m, k += 1) {
      const rng = random(seed, `${segment.id}:driftwood:${k}`);
      if (rng() > wood.acceptance) continue;
      const sAt = Math.min(s1 - 3, Math.max(s0 + 3, s + (rng() - 0.5) * wood.spacing_m * 0.6));
      const section = sectionAtS(sAt);
      const yaw = tangentAngle(section) + ((rng() - 0.5) * 2 * wood.yaw_jitter_deg * Math.PI) / 180;
      const thickness = 2 * pick(wood.radius_m, rng);
      placeWood(sAt, pick(wood.d_m, rng), yaw, pick(wood.length_m, rng), thickness, thickness, log, rng);
    }
    // Planks: boards washed up at the waterline (the 2021 photo shows one
    // beside the landing pier), each at the shore station nearest near_xz.
    for (const [k, board] of rules.planks.entries()) {
      if (board.segment !== segment.id) continue;
      const rng = random(seed, `${segment.id}:plank:${k}`);
      const nearest = outline.nearestS([board.near_xz[0], -board.near_xz[1]]);
      const sAt = nearest < s0 ? nearest + outline.perimeter : nearest;
      invariant(sAt > s0 && sAt < s1, `Shoreline plank ${k} lies outside segment ${segment.id}`);
      const section = sectionAtS(sAt);
      const d = slope.shoulder_m + (section.top - (WATER_Y_M + board.above_water_m)) / section.gradient;
      invariant(placeWood(sAt, d, tangentAngle(section) + (board.yaw_deg * Math.PI) / 180, board.length_m, 0.05, board.width_m, plank, rng),
        `Shoreline plank ${k} has no stones to rest on`);
    }
    segmentSummaries.push({
      id: segment.id,
      source_key: segment.source_key,
      outline_source_key: segment.outline_source_key,
      s_m: [roundCoordinate(outline.wrap(s0)), roundCoordinate(s1 > outline.perimeter ? outline.wrap(s1) : s1)],
      structures: structures.map((structure) => ({ source_key: structure.source_key, kind: structure.kind, slope: structure.slope })),
      top_y_m: [roundCoordinate(Math.min(...sections.map((x) => x.top))), roundCoordinate(Math.max(...sections.map((x) => x.top)))],
      gradient_m_per_m: [round3(Math.min(...sections.map((x) => x.gradient))), round3(Math.max(...sections.map((x) => x.gradient)))],
      waterline_m: [roundCoordinate(Math.min(...sections.map((x) => x.water_m))), roundCoordinate(Math.max(...sections.map((x) => x.water_m)))],
      reason: segment.reason,
      reference: segment.reference,
    });
    for (const stone of stones) stone.segment ??= segment.id;
  }

  // One batch (one MultiMesh) per segment, section, band and prototype.
  const batches = new Map();
  for (const stone of stones) {
    const id = `${stone.segment}:${String(stone.section).padStart(2, "0")}:${stone.band}:${stone.prototypeId}`;
    if (!batches.has(id)) {
      const [end, margin] = rules.visibility_m[stone.band];
      batches.set(id, {
        id,
        segment: stone.segment,
        section: stone.section,
        band: stone.band,
        prototype: stone.prototypeId,
        // The heap and cobbles are shaded by their texture and the shader's
        // contact darkening; the top row and the wood also cast shadows.
        cast_shadow: stone.band === "top" || stone.band === "driftwood",
        visibility_end_m: end,
        visibility_margin_m: margin,
        placements: [],
      });
    }
    batches.get(id).placements.push(stone);
  }
  const ordered = [...batches.values()].sort((left, right) => (left.id < right.id ? -1 : left.id > right.id ? 1 : 0));
  for (const batch of ordered) {
    batch.placements.sort((left, right) => left.s - right.s || left.plan[0] - right.plan[0] || left.plan[1] - right.plan[1]);
    batch.placements = batch.placements.map((stone) => [
      ...stone.origin.map(roundCoordinate),
      ...stone.q.map(round3),
      ...stone.scales.map(round3),
      ...stone.tint.map(round2),
    ]);
  }
  return {
    document: {
      schema_version: SHORELINE_SCHEMA,
      generator: "tools/lib/shoreline-generation.mjs",
      config: configDescriptor,
      visual_only: true,
      seed,
      water_y_m: WATER_Y_M,
      overlay: { material_key: SHORELINE_OVERLAY_MATERIAL, bias_m: bias, object_key_prefix: SHORELINE_OVERLAY_PREFIX },
      segments: segmentSummaries,
      records,
      prototypes,
      batches: ordered,
    },
    stones,
  };
}
