// Yerba Buena Island L1 context scenery: non-playable, non-colliding terrain with its
// ground cover, the island's buildings and at-grade roads and paths from the frozen OSM
// snapshot, and its procedural vegetation (rules in tools/config/ybi-context.json, the
// aerial's land cover in data/ybi/). tools/build_godot_world.mjs calls buildYbiContext
// and writes its records, ground-cover map and vegetation into generated/world/context.json;
// tools/build_source_inventory.mjs uses ybiContextCategories for the ledger's YBI rows.
//
// Coordinates: plan geometry is metres east/north (tools/lib/coordinates.mjs); records
// are world [x, y, z] with z = -north, triangles counter-clockwise round their outward
// normal, like every generated record.

import { readFileSync } from "node:fs";
import { deflateSync, inflateSync } from "node:zlib";
import { resolve } from "node:path";

import earcut from "earcut";
import polygonClipping from "polygon-clipping";

import { projectGeoJsonGeometry, projectLonLat } from "./coordinates.mjs";
import { distanceToMask, rasterizeTriangle } from "./ground-cover-map.mjs";
import {
  geometryToLine,
  geometryToMultiPolygon,
  multiPolygonArea,
  multiPolygonBounds,
  multiPolygonCentroid,
  pointInMultiPolygon,
  rectangleMultiPolygon,
  selectGeometry,
} from "./osm-geometry.mjs";
import { invariant, roundCoordinate, sha256Bytes, stableJson } from "./world-contract.mjs";

export const YBI_CONFIG_PATH = "tools/config/ybi-context.json";
export const YBI_LAND_COVER_PATH = "data/ybi/ybi-land-cover-2026-05-26.json";
export const YBI_LAND_COVER_SCHEMA = "ti.ybi-land-cover/1";
// World x, z of the north-west corner, cell size and size in cells.
export const YBI_LAND_COVER_GRID = Object.freeze({ origin_xz: Object.freeze([-180, 920]), cell_m: 2, width: 630, height: 480 });
export const YBI_LAND_COVER_CLASSES = Object.freeze(["canopy", "green", "dry", "bare"]);
// Beside the classes, the share of deep-shadow pixels: tall trees throw long shadows
// into and beside their crowns in the late-morning aerial, low scrub hardly any.
export const YBI_LAND_COVER_LAYERS = Object.freeze([...YBI_LAND_COVER_CLASSES, "shadow"]);
export const YBI_VEGETATION_SCHEMA = "ti.ybi-vegetation/1";
// The plant scales and crown stretches the game draws (ybi_vegetation_builder.gd document_error).
export const YBI_VEGETATION_LIMITS = Object.freeze({ scale: Object.freeze([0.4, 1.8]), stretch: Object.freeze([1, 1.6]) });
export const YBI_GROUND_COVER_SCHEMA = "ti.ybi-ground-cover/1";
// The ground-cover map's channels, in RGBA order; the rest of a cell is dry straw.
export const YBI_GROUND_COVER_CHANNELS = Object.freeze(["dark_vegetation", "green", "bare", "rock"]);

export const YBI_CATEGORIES = Object.freeze([
  "context_ybi_building",
  "context_ybi_building_part",
  "context_ybi_structure",
  "context_ybi_road",
  "context_ybi_paved_area",
  "context_ybi_wall",
  "context_ybi_water",
]);
// Context records YBI's detail rows draw into (all composites of their sources).
export const YBI_BUILDINGS_KEY = "context:ybi-buildings";
export const YBI_WALLS_KEY = "context:ybi-walls";
// The summit reservoir (OSM natural=water): its water and the pale concrete lining round it.
export const YBI_BASIN_RECORDS = Object.freeze({
  water: Object.freeze({ object_key: "context:ybi-basin", material_key: "context_ybi_water" }),
  lining: Object.freeze({ object_key: "context:ybi-basin-lining", material_key: "context_ybi_wall" }),
});
export const YBI_SURFACE_RECORDS = Object.freeze({
  vehicle: Object.freeze({ object_key: "context:ybi-roads", material_key: "context_ybi_road" }),
  pedestrian: Object.freeze({ object_key: "context:ybi-paths", material_key: "context_ybi_path" }),
  paved: Object.freeze({ object_key: "context:ybi-paved", material_key: "context_ybi_paved" }),
  construction: Object.freeze({ object_key: "context:ybi-construction", material_key: "context_ybi_construction" }),
});
export const YBI_MATERIAL_KEYS = Object.freeze([
  "context_ybi_building_roof",
  "context_ybi_building_wall",
  "context_ybi_construction",
  "context_ybi_facade_bristol",
  "context_ybi_facade_cove",
  "context_ybi_facade_meadow",
  "context_ybi_path",
  "context_ybi_paved",
  "context_ybi_road",
  "context_ybi_spire",
  "context_ybi_wall",
  "context_ybi_water",
]);
// Playable roads and paths whose frozen ways run on from the causeway onto YBI: their
// part past the Treasure Island outline is drawn as boundary-attached context
// (boundary_context:KEY), as a pier deck past the outline is.
export const YBI_CONTINUATION_SOURCE_KEYS = Object.freeze([
  "w1115934722",
  "w1212173456",
  "w1248964738",
  "w1248964740",
  "w1248964743",
  "w1249797943",
  "w1472754371",
]);

const VEHICLE_HIGHWAYS = new Set(["residential", "tertiary", "tertiary_link", "unclassified", "service", "track"]);
const PEDESTRIAN_HIGHWAYS = new Set(["footway", "path", "steps", "cycleway", "pedestrian"]);
const YBI_HIGHWAYS = new Set([...VEHICLE_HIGHWAYS, ...PEDESTRIAN_HIGHWAYS, "construction"]);

const yes = (value) => value != null && value !== "no";

export function compareCodePoints(left, right) {
  return left < right ? -1 : left > right ? 1 : 0;
}

// Boolean operations straight from polygon-clipping, with open rings and empty pieces
// dropped. YBI's surfaces only triangulate and rasterize these, so rings that touch at a
// vertex (a loop road's ribbon) need no canonical repair.
function openRings(multiPolygon) {
  const out = [];
  for (const polygon of multiPolygon) {
    const rings = [];
    for (const ring of polygon) {
      const open = ring.length > 1 && ring[0][0] === ring.at(-1)[0] && ring[0][1] === ring.at(-1)[1] ? ring.slice(0, -1) : ring;
      if (open.length >= 3) rings.push(open);
    }
    if (rings.length > 0) out.push(rings);
  }
  return out;
}
function rawUnion(...multiPolygons) {
  const parts = multiPolygons.filter((item) => item.length > 0);
  if (parts.length === 0) return [];
  return openRings(polygonClipping.union(...parts));
}
function rawIntersect(left, right) {
  if (left.length === 0 || right.length === 0) return [];
  return openRings(polygonClipping.intersection(left, right));
}
function rawDifference(subject, ...clips) {
  const parts = clips.filter((item) => item.length > 0);
  if (subject.length === 0) return [];
  if (parts.length === 0) return subject;
  return openRings(polygonClipping.difference(subject, ...parts));
}
// A polygon view projected as it is mapped, without canonical repair (cover hints only).
function rawGeometry(geometry) {
  const projected = projectGeoJsonGeometry(geometry);
  return openRings(projected.type === "Polygon" ? [projected.coordinates] : projected.coordinates);
}
// Douglas-Peucker: the line's points within toleranceM of the simplified line.
function simplifyLine(line, toleranceM) {
  if (line.length <= 2) return line;
  const keep = new Uint8Array(line.length);
  keep[0] = 1;
  keep[line.length - 1] = 1;
  const stack = [[0, line.length - 1]];
  while (stack.length > 0) {
    const [first, last] = stack.pop();
    let worst = -1;
    let worstIndex = -1;
    for (let index = first + 1; index < last; index += 1) {
      const distance = distanceToSegment(line[index], line[first], line[last]);
      if (distance > worst) {
        worst = distance;
        worstIndex = index;
      }
    }
    if (worst > toleranceM) {
      keep[worstIndex] = 1;
      stack.push([first, worstIndex], [worstIndex, last]);
    }
  }
  return line.filter((_point, index) => keep[index]);
}
// A road's ribbon: its simplified centreline swept at width, with octagonal joins.
function ribbon(line, width, label) {
  const simple = simplifyLine(line, 0.25);
  const radius = width / 2;
  const parts = [];
  for (let index = 1; index < simple.length; index += 1) {
    const [a, b] = [simple[index - 1], simple[index]];
    const length = Math.hypot(b[0] - a[0], b[1] - a[1]);
    if (length <= 1e-6) continue;
    const nx = (-(b[1] - a[1]) / length) * radius;
    const ny = ((b[0] - a[0]) / length) * radius;
    parts.push([[[a[0] + nx, a[1] + ny], [a[0] - nx, a[1] - ny], [b[0] - nx, b[1] - ny], [b[0] + nx, b[1] + ny]]]);
  }
  invariant(parts.length > 0, `${label} has no non-zero segment`);
  for (const point of simple) {
    const ring = [];
    for (let k = 0; k < 8; k += 1) {
      const angle = ((k + 0.5) / 8) * Math.PI * 2;
      ring.push([point[0] + Math.cos(angle) * radius, point[1] + Math.sin(angle) * radius]);
    }
    parts.push([ring]);
  }
  // Millimetre-snapped primitives, folded pairwise (polygon-clipping completes its rings
  // far more reliably so, as the Treasure Island road ribbons found).
  let queue = parts.map((part) => part.map((ring) => ring.map((point) => point.map(round3))));
  while (queue.length > 1) {
    const next = [];
    for (let index = 0; index < queue.length; index += 2) {
      next.push(index + 1 < queue.length ? polygonClipping.union(queue[index], queue[index + 1]) : queue[index]);
    }
    queue = next;
  }
  return openRings(queue[0]);
}

// The Bay Bridge track (a separate owner): I-80, its ramps (built or under
// construction) and every bridge- or tunnel-tagged way.
export function isBridgeTrackHighway(tags) {
  return tags.highway === "motorway" || tags.highway === "motorway_link" || yes(tags.bridge) || yes(tags.tunnel)
    || (tags.highway === "construction" && ["motorway", "motorway_link"].includes(tags.construction));
}

// The YBI context categories of a frozen OSM way or relation that stands on YBI's land
// (the caller checks that). hasArea: its export has a polygon view.
export function ybiContextCategories(tags, osmType, hasArea) {
  if (osmType !== "way" && osmType !== "relation") return [];
  const categories = [];
  if (tags.building != null && hasArea) categories.push("context_ybi_building");
  if (tags["building:part"] != null && hasArea) categories.push("context_ybi_building_part");
  if (tags.tourism === "artwork" && tags.height != null && tags.building == null && hasArea) categories.push("context_ybi_structure");
  if (osmType === "way" && YBI_HIGHWAYS.has(tags.highway) && tags.area !== "yes" && !isBridgeTrackHighway(tags)) {
    categories.push("context_ybi_road");
  }
  if (hasArea && (tags.amenity === "parking" || (tags.highway === "pedestrian" && tags.area === "yes")
    || (tags.tourism === "viewpoint" && tags.surface === "paved") || tags.leisure === "pitch" || tags.leisure === "sports_centre")) {
    categories.push("context_ybi_paved_area");
  }
  if (osmType === "way" && ["retaining_wall", "wall"].includes(tags.barrier) && tags.leisure == null && tags.landuse == null) {
    categories.push("context_ybi_wall");
  }
  if (hasArea && tags.natural === "water") categories.push("context_ybi_water");
  return categories;
}

// The surface record of a paved area: pedestrian plazas and the paved summit viewpoint are
// light concrete like the paths; parking lots, pitches and courts stay asphalt.
function pavedAreaClass(tags) {
  return tags.highway === "pedestrian" || tags.tourism === "viewpoint" ? "pedestrian" : "paved";
}

export function roadClass(tags) {
  if (VEHICLE_HIGHWAYS.has(tags.highway)) return "vehicle";
  if (PEDESTRIAN_HIGHWAYS.has(tags.highway)) return "pedestrian";
  if (tags.highway === "construction") return "construction";
  throw new Error(`No YBI road class for highway=${tags.highway}`);
}

export function loadYbiConfig(projectRoot) {
  const config = JSON.parse(readFileSync(resolve(projectRoot, YBI_CONFIG_PATH), "utf8"));
  invariant(config.schema_version === "ti.ybi-context/1", "YBI context config schema drift");
  return config;
}

export function loadYbiLandCover(projectRoot) {
  const document = JSON.parse(readFileSync(resolve(projectRoot, YBI_LAND_COVER_PATH), "utf8"));
  invariant(document.schema_version === YBI_LAND_COVER_SCHEMA, "YBI land cover schema drift");
  invariant(stableJson(document.grid) === stableJson(YBI_LAND_COVER_GRID), "YBI land cover grid drift");
  const { width, height } = YBI_LAND_COVER_GRID;
  const layers = {};
  for (const name of YBI_LAND_COVER_LAYERS) {
    const bytes = inflateSync(Buffer.from(document.layers[name], "base64"));
    invariant(bytes.length === width * height, `YBI land cover layer ${name} has ${bytes.length} cells`);
    layers[name] = new Uint8Array(bytes);
  }
  return { grid: YBI_LAND_COVER_GRID, layers };
}

// --- Small deterministic helpers --------------------------------------------------

function hash32(...values) {
  let h = 0x811c9dc5;
  for (const value of values) {
    let v = Math.round(value * 1000) | 0;
    for (let k = 0; k < 4; k += 1) {
      h ^= v & 0xff;
      h = Math.imul(h, 0x01000193);
      v >>>= 8;
    }
  }
  h ^= h >>> 15;
  h = Math.imul(h, 0x2c1b3c6d);
  h ^= h >>> 12;
  return (h >>> 0) / 4294967296;
}

function valueNoise(x, y, seed) {
  const x0 = Math.floor(x);
  const y0 = Math.floor(y);
  const fx = x - x0;
  const fy = y - y0;
  const u = fx * fx * (3 - 2 * fx);
  const v = fy * fy * (3 - 2 * fy);
  const a = hash32(x0, y0, seed);
  const b = hash32(x0 + 1, y0, seed);
  const c = hash32(x0, y0 + 1, seed);
  const d = hash32(x0 + 1, y0 + 1, seed);
  return (a * (1 - u) + b * u) * (1 - v) + (c * (1 - u) + d * u) * v;
}

// Two octaves of value noise in [0, 1) at a scale in metres.
function fractalNoise(x, z, scale, seed) {
  return 0.65 * valueNoise(x / scale, z / scale, seed) + 0.35 * valueNoise((2.1 * x) / scale + 17.3, (2.1 * z) / scale + 5.9, seed + 1);
}

function smoothstep(edge0, edge1, value) {
  const t = Math.max(0, Math.min(1, (value - edge0) / (edge1 - edge0)));
  return t * t * (3 - 2 * t);
}

const round2 = (value) => Math.round(value * 100) / 100;
const round3 = (value) => roundCoordinate(value);

function emptyMesh() {
  return { vertices: [], normals: [], uvs: [], indices: [] };
}

// One vertex per distinct rounded position (and normal, unless byPosition; and UV, with
// withUv, for a texture seam) within a mesh.
function vertexWriter(mesh, byPosition = false, withUv = false) {
  const seen = new Map();
  return (position, normal, uv) => {
    const p = position.map(round3);
    const n = normal.map(round3);
    const t = withUv ? `|${uv.map(round3).join(",")}` : "";
    const key = (byPosition ? `${p[0]},${p[1]},${p[2]}` : `${p[0]},${p[1]},${p[2]}|${n[0]},${n[1]},${n[2]}`) + t;
    const existing = seen.get(key);
    if (existing != null) return existing;
    const index = mesh.vertices.length / 3;
    mesh.vertices.push(...p);
    mesh.normals.push(...n);
    mesh.uvs.push(...uv.map(round3));
    seen.set(key, index);
    return index;
  };
}

function vertexAt(mesh, index) {
  return [mesh.vertices[index * 3], mesh.vertices[index * 3 + 1], mesh.vertices[index * 3 + 2]];
}

// A triangle wound counter-clockwise round desired (the generated contract's
// convention), dropping triangles that round to zero area.
function pushTriangle(mesh, a, b, c, desired) {
  if (a === b || b === c || a === c) return false;
  const pa = vertexAt(mesh, a);
  const pb = vertexAt(mesh, b);
  const pc = vertexAt(mesh, c);
  const ab = [pb[0] - pa[0], pb[1] - pa[1], pb[2] - pa[2]];
  const ac = [pc[0] - pa[0], pc[1] - pa[1], pc[2] - pa[2]];
  const cross = [ab[1] * ac[2] - ab[2] * ac[1], ab[2] * ac[0] - ab[0] * ac[2], ab[0] * ac[1] - ab[1] * ac[0]];
  if (Math.hypot(...cross) / 2 <= 1e-6) return false;
  if (cross[0] * desired[0] + cross[1] * desired[1] + cross[2] * desired[2] < 0) mesh.indices.push(a, c, b);
  else mesh.indices.push(a, b, c);
  return true;
}

function distanceToSegment(point, a, b) {
  const dx = b[0] - a[0];
  const dy = b[1] - a[1];
  const lengthSquared = dx * dx + dy * dy;
  const t = lengthSquared > 0 ? Math.max(0, Math.min(1, ((point[0] - a[0]) * dx + (point[1] - a[1]) * dy) / lengthSquared)) : 0;
  return Math.hypot(point[0] - a[0] - t * dx, point[1] - a[1] - t * dy);
}

function ringSegments(multiPolygon) {
  const segments = [];
  for (const polygon of multiPolygon) {
    for (const ring of polygon) {
      for (let index = 0; index < ring.length; index += 1) segments.push([ring[index], ring[(index + 1) % ring.length]]);
    }
  }
  return segments;
}

function distanceToMultiPolygon(point, multiPolygon) {
  if (pointInMultiPolygon(point, multiPolygon, true)) return 0;
  let best = Infinity;
  for (const [a, b] of ringSegments(multiPolygon)) best = Math.min(best, distanceToSegment(point, a, b));
  return best;
}

function earcutMultiPolygon(multiPolygon) {
  const triangles = [];
  for (const polygon of multiPolygon) {
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
    for (let index = 0; index < indices.length; index += 3) {
      triangles.push([points[indices[index]], points[indices[index + 1]], points[indices[index + 2]]]);
    }
  }
  return triangles;
}

// --- Terrain -----------------------------------------------------------------------

// YBI's land as a grid of cellM cells aligned to world multiples of cellM (so Treasure
// Island's 32 m land grid's crossings on the shared causeway seam are vertices of both),
// each whole cell two triangles on shared vertices split along the diagonal that best
// fits the DEM, each cell the shore or seam crosses clipped and triangulated on its own.
// Vertices on the seam take the Treasure Island land surface's height (seamElevation),
// so the two meshes meet without a step; the shore's edges drop to the water as sides.
function buildTerrain({ land, seam, sampleDem, seamElevation, cellM, normalSampleM, skirtBottomM }) {
  const bounds = multiPolygonBounds(land);
  const i0 = Math.floor(bounds.min_x / cellM);
  const i1 = Math.ceil(bounds.max_x / cellM);
  const j0 = Math.floor(bounds.min_y / cellM);
  const j1 = Math.ceil(bounds.max_y / cellM);
  const onSeam = (point) => seam.some(([a, b]) => distanceToSegment(point, a, b) <= 0.002);
  const elevation = (east, north) => (onSeam([east, north]) ? seamElevation(east, north) : sampleDem(east, north));
  const normalAt = (east, north) => {
    const d = normalSampleM;
    const slopeEast = (sampleDem(east + d, north) - sampleDem(east - d, north)) / (2 * d);
    const slopeNorth = (sampleDem(east, north + d) - sampleDem(east, north - d)) / (2 * d);
    const length = Math.hypot(slopeEast, 1, slopeNorth);
    return [-slopeEast / length, 1 / length, slopeNorth / length];
  };
  // Cells the land's edges pass through (and their neighbours) are clipped.
  const edgeCells = new Set();
  for (const [a, b] of ringSegments(land)) {
    const length = Math.hypot(b[0] - a[0], b[1] - a[1]);
    const steps = Math.max(1, Math.ceil(length / 1.0));
    for (let step = 0; step <= steps; step += 1) {
      const east = a[0] + ((b[0] - a[0]) * step) / steps;
      const north = a[1] + ((b[1] - a[1]) * step) / steps;
      const ci = Math.floor(east / cellM);
      const cj = Math.floor(north / cellM);
      for (let di = -1; di <= 1; di += 1) for (let dj = -1; dj <= 1; dj += 1) edgeCells.add(`${ci + di},${cj + dj}`);
    }
  }
  const mesh = emptyMesh();
  const gridVertex = new Map();
  const vertexFor = (east, north) => {
    const key = `${Math.round(east * 1000)},${Math.round(north * 1000)}`;
    const existing = gridVertex.get(key);
    if (existing != null) return existing;
    const index = mesh.vertices.length / 3;
    mesh.vertices.push(round3(east), round3(elevation(east, north)), round3(-north));
    mesh.normals.push(...normalAt(east, north).map(round3));
    mesh.uvs.push(round3(east / 10), round3(-north / 10));
    gridVertex.set(key, index);
    return index;
  };
  const up = [0, 1, 0];
  let wholeCells = 0;
  let clippedCells = 0;
  for (let i = i0; i < i1; i += 1) {
    for (let j = j0; j < j1; j += 1) {
      const west = i * cellM;
      const south = j * cellM;
      const east = west + cellM;
      const north = south + cellM;
      if (!edgeCells.has(`${i},${j}`)) {
        if (!pointInMultiPolygon([west + cellM / 2, south + cellM / 2], land, false)) continue;
        const sw = vertexFor(west, south);
        const se = vertexFor(east, south);
        const ne = vertexFor(east, north);
        const nw = vertexFor(west, north);
        // The diagonal whose midpoint the DEM agrees with best.
        const mid = sampleDem(west + cellM / 2, south + cellM / 2);
        const first = Math.abs((vertexAt(mesh, sw)[1] + vertexAt(mesh, ne)[1]) / 2 - mid);
        const second = Math.abs((vertexAt(mesh, se)[1] + vertexAt(mesh, nw)[1]) / 2 - mid);
        if (first <= second) {
          pushTriangle(mesh, sw, se, ne, up);
          pushTriangle(mesh, sw, ne, nw, up);
        } else {
          pushTriangle(mesh, sw, se, nw, up);
          pushTriangle(mesh, se, ne, nw, up);
        }
        wholeCells += 1;
        continue;
      }
      const clipped = rawIntersect(land, rectangleMultiPolygon(west, south, east, north));
      if (clipped.length === 0 || multiPolygonArea(clipped) <= 1e-6) continue;
      for (const triangle of earcutMultiPolygon(clipped)) {
        const [a, b, c] = triangle.map((point) => vertexFor(point[0], point[1]));
        pushTriangle(mesh, a, b, c, up);
      }
      clippedCells += 1;
    }
  }
  const topTriangleCount = mesh.indices.length / 3;
  // Sides: every top edge used by one triangle, but for the seam, down to the water.
  const edgeUse = new Map();
  for (let t = 0; t < topTriangleCount; t += 1) {
    for (let k = 0; k < 3; k += 1) {
      const a = mesh.indices[t * 3 + k];
      const b = mesh.indices[t * 3 + ((k + 1) % 3)];
      const key = a < b ? `${a},${b}` : `${b},${a}`;
      const entry = edgeUse.get(key);
      if (entry) entry.count += 1;
      else edgeUse.set(key, { count: 1, a, b, triangle: t });
    }
  }
  const sideMesh = emptyMesh();
  const sideVertex = vertexWriter(sideMesh);
  let sideEdges = 0;
  for (const { count, a, b, triangle } of [...edgeUse.values()].sort((l, r) => l.triangle - r.triangle || l.a - r.a || l.b - r.b)) {
    if (count !== 1) continue;
    const pa = vertexAt(mesh, a);
    const pb = vertexAt(mesh, b);
    const middle = [(pa[0] + pb[0]) / 2, -(pa[2] + pb[2]) / 2];
    if (onSeam(middle)) continue;
    if (Math.max(pa[1], pb[1]) - skirtBottomM <= 0.001) continue;
    // Outward: away from the triangle's third vertex.
    const third = [0, 1, 2].map((k) => mesh.indices[triangle * 3 + k]).find((index) => index !== a && index !== b);
    const pc = vertexAt(mesh, third);
    const along = [pb[0] - pa[0], pb[2] - pa[2]];
    const length = Math.hypot(...along);
    let outward = [along[1] / length, 0, -along[0] / length];
    if ((pc[0] - pa[0]) * outward[0] + (pc[2] - pa[2]) * outward[2] > 0) outward = outward.map((value) => -value);
    const width = length;
    const bottomA = sideVertex([pa[0], skirtBottomM, pa[2]], outward, [0, skirtBottomM / 10]);
    const bottomB = sideVertex([pb[0], skirtBottomM, pb[2]], outward, [width / 10, skirtBottomM / 10]);
    const topB = sideVertex(pb, outward, [width / 10, pb[1] / 10]);
    const topA = sideVertex(pa, outward, [0, pa[1] / 10]);
    pushTriangle(sideMesh, bottomA, bottomB, topB, outward);
    pushTriangle(sideMesh, bottomA, topB, topA, outward);
    sideEdges += 1;
  }
  // The top's triangles, bucketed for point queries on the consumed (rounded) mesh.
  const bucketM = cellM;
  const buckets = new Map();
  const triangles = [];
  for (let t = 0; t < topTriangleCount; t += 1) {
    const corners = [0, 1, 2].map((k) => vertexAt(mesh, mesh.indices[t * 3 + k]));
    const plan = corners.map((p) => [p[0], -p[2]]);
    const area2 = (plan[1][0] - plan[0][0]) * (plan[2][1] - plan[0][1]) - (plan[2][0] - plan[0][0]) * (plan[1][1] - plan[0][1]);
    // Counter-clockwise in plan (east/north) for clipping.
    const ordered = area2 >= 0 ? [0, 1, 2] : [0, 2, 1];
    const entry = { plan: ordered.map((k) => plan[k]), y: ordered.map((k) => corners[k][1]) };
    const ab = [corners[1][0] - corners[0][0], corners[1][1] - corners[0][1], corners[1][2] - corners[0][2]];
    const ac = [corners[2][0] - corners[0][0], corners[2][1] - corners[0][1], corners[2][2] - corners[0][2]];
    let normal = [ab[1] * ac[2] - ab[2] * ac[1], ab[2] * ac[0] - ab[0] * ac[2], ab[0] * ac[1] - ab[1] * ac[0]];
    const length = Math.hypot(...normal);
    normal = normal.map((value) => value / length);
    if (normal[1] < 0) normal = normal.map((value) => -value);
    entry.normal = normal;
    triangles.push(entry);
    const xs = entry.plan.map((p) => p[0]);
    const ys = entry.plan.map((p) => p[1]);
    for (let bi = Math.floor(Math.min(...xs) / bucketM); bi <= Math.floor(Math.max(...xs) / bucketM); bi += 1) {
      for (let bj = Math.floor(Math.min(...ys) / bucketM); bj <= Math.floor(Math.max(...ys) / bucketM); bj += 1) {
        const key = `${bi},${bj}`;
        if (!buckets.has(key)) buckets.set(key, []);
        buckets.get(key).push(t);
      }
    }
  }
  const barycentric = (entry, east, north) => {
    const [a, b, c] = entry.plan;
    const det = (b[1] - c[1]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[1] - c[1]);
    const wa = ((b[1] - c[1]) * (east - c[0]) + (c[0] - b[0]) * (north - c[1])) / det;
    const wb = ((c[1] - a[1]) * (east - c[0]) + (a[0] - c[0]) * (north - c[1])) / det;
    return [wa, wb, 1 - wa - wb];
  };
  const locate = (east, north) => {
    const candidates = buckets.get(`${Math.floor(east / bucketM)},${Math.floor(north / bucketM)}`) ?? [];
    let best = null;
    for (const t of candidates) {
      const weights = barycentric(triangles[t], east, north);
      const worst = Math.min(...weights);
      if (best == null || worst > best.worst) best = { t, weights, worst };
    }
    return best && best.worst >= -1e-6 ? best : null;
  };
  const groundAt = (east, north) => {
    const hit = locate(east, north);
    if (!hit) return null;
    const entry = triangles[hit.t];
    return hit.weights[0] * entry.y[0] + hit.weights[1] * entry.y[1] + hit.weights[2] * entry.y[2];
  };
  const candidatesIn = (minE, minN, maxE, maxN) => {
    const found = new Set();
    for (let bi = Math.floor(minE / bucketM); bi <= Math.floor(maxE / bucketM); bi += 1) {
      for (let bj = Math.floor(minN / bucketM); bj <= Math.floor(maxN / bucketM); bj += 1) {
        for (const t of buckets.get(`${bi},${bj}`) ?? []) found.add(t);
      }
    }
    return [...found].sort((l, r) => l - r);
  };
  return {
    top: mesh,
    sides: sideMesh,
    triangles,
    cellM,
    groundAt,
    normalAt,
    normalAtTriangle: (east, north) => {
      const hit = locate(east, north);
      return hit ? triangles[hit.t].normal : null;
    },
    candidatesIn,
    stats: { whole_cells: wholeCells, clipped_cells: clippedCells, side_edges: sideEdges },
  };
}

// --- Draping -----------------------------------------------------------------------

// A convex polygon (counter-clockwise, east/north) clipped to a counter-clockwise triangle.
function clipConvex(polygon, triangle) {
  let output = polygon;
  for (let k = 0; k < 3 && output.length > 0; k += 1) {
    const a = triangle[k];
    const b = triangle[(k + 1) % 3];
    const inside = (p) => (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0]) >= -1e-9;
    const input = output;
    output = [];
    for (let index = 0; index < input.length; index += 1) {
      const current = input[index];
      const previous = input[(index + input.length - 1) % input.length];
      const currentIn = inside(current);
      const previousIn = inside(previous);
      if (currentIn !== previousIn) {
        const d1 = (b[0] - a[0]) * (previous[1] - a[1]) - (b[1] - a[1]) * (previous[0] - a[0]);
        const d2 = (b[0] - a[0]) * (current[1] - a[1]) - (b[1] - a[1]) * (current[0] - a[0]);
        const t = d1 / (d1 - d2);
        output.push([previous[0] + (current[0] - previous[0]) * t, previous[1] + (current[1] - previous[1]) * t]);
      }
      if (currentIn) output.push(current);
    }
  }
  return output;
}

// A plan multipolygon laid on the terrain's own triangles, bias metres above them: every
// piece lies in one terrain triangle's plane, so the surface follows the drawn ground
// exactly. The polygon is cut into the terrain's cells first (through 8-cell tiles), so
// each cell's few pieces meet only that cell's triangles.
function drapeMultiPolygon(multiPolygon, terrain, biasM) {
  const mesh = emptyMesh();
  const vertex = vertexWriter(mesh, true);
  const up = [0, 1, 0];
  if (multiPolygon.length === 0) return mesh;
  const cellM = terrain.cellM;
  const tileM = cellM * 8;
  const bounds = multiPolygonBounds(multiPolygon);
  for (let ti = Math.floor(bounds.min_x / tileM); ti * tileM < bounds.max_x; ti += 1) {
    for (let tj = Math.floor(bounds.min_y / tileM); tj * tileM < bounds.max_y; tj += 1) {
      const tile = rawIntersect(multiPolygon, rectangleMultiPolygon(ti * tileM, tj * tileM, (ti + 1) * tileM, (tj + 1) * tileM));
      if (tile.length === 0) continue;
      const tileBounds = multiPolygonBounds(tile);
      for (let ci = Math.floor(tileBounds.min_x / cellM); ci * cellM < tileBounds.max_x; ci += 1) {
        for (let cj = Math.floor(tileBounds.min_y / cellM); cj * cellM < tileBounds.max_y; cj += 1) {
          const west = ci * cellM;
          const south = cj * cellM;
          const piece = rawIntersect(tile, rectangleMultiPolygon(west, south, west + cellM, south + cellM));
          if (piece.length === 0) continue;
          const candidates = terrain.candidatesIn(west + 1e-6, south + 1e-6, west + cellM - 1e-6, south + cellM - 1e-6);
          for (const triangle of earcutMultiPolygon(piece)) {
            const area2 = (triangle[1][0] - triangle[0][0]) * (triangle[2][1] - triangle[0][1]) - (triangle[2][0] - triangle[0][0]) * (triangle[1][1] - triangle[0][1]);
            if (Math.abs(area2) <= 1e-9) continue;
            const ccw = area2 > 0 ? triangle : [triangle[0], triangle[2], triangle[1]];
            for (const t of candidates) {
              const entry = terrain.triangles[t];
              const clipped = clipConvex(ccw, entry.plan);
              if (clipped.length < 3) continue;
              const [a, b, c] = entry.plan;
              const det = (b[1] - c[1]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[1] - c[1]);
              const heightAt = (p) => {
                const wa = ((b[1] - c[1]) * (p[0] - c[0]) + (c[0] - b[0]) * (p[1] - c[1])) / det;
                const wb = ((c[1] - a[1]) * (p[0] - c[0]) + (a[0] - c[0]) * (p[1] - c[1])) / det;
                return wa * entry.y[0] + wb * entry.y[1] + (1 - wa - wb) * entry.y[2] + biasM;
              };
              // Shaded like the terrain under it (its normals come from the same DEM).
              const indices = clipped.map((p) => vertex([p[0], heightAt(p), -p[1]], terrain.normalAt(p[0], p[1]), [p[0] / 10, -p[1] / 10]));
              for (let k = 1; k + 1 < indices.length; k += 1) pushTriangle(mesh, indices[0], indices[k], indices[k + 1], up);
            }
          }
        }
      }
    }
  }
  return mesh;
}

// --- Buildings ---------------------------------------------------------------------

function convexHull(points) {
  const sorted = [...points].sort((l, r) => l[0] - r[0] || l[1] - r[1]);
  const cross = (o, a, b) => (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
  const lower = [];
  for (const p of sorted) {
    while (lower.length >= 2 && cross(lower.at(-2), lower.at(-1), p) <= 0) lower.pop();
    lower.push(p);
  }
  const upper = [];
  for (const p of [...sorted].reverse()) {
    while (upper.length >= 2 && cross(upper.at(-2), upper.at(-1), p) <= 0) upper.pop();
    upper.push(p);
  }
  return [...lower.slice(0, -1), ...upper.slice(0, -1)];
}

// The footprint's minimum-area bounding rectangle: centre, unit long axis u, half
// length a and half width b (a >= b).
function orientedBox(multiPolygon) {
  const hull = convexHull(multiPolygon.flatMap((polygon) => polygon[0]));
  let best = null;
  for (let index = 0; index < hull.length; index += 1) {
    const p = hull[index];
    const q = hull[(index + 1) % hull.length];
    const length = Math.hypot(q[0] - p[0], q[1] - p[1]);
    if (length <= 1e-9) continue;
    const u = [(q[0] - p[0]) / length, (q[1] - p[1]) / length];
    const v = [-u[1], u[0]];
    let minU = Infinity, maxU = -Infinity, minV = Infinity, maxV = -Infinity;
    for (const h of hull) {
      const du = h[0] * u[0] + h[1] * u[1];
      const dv = h[0] * v[0] + h[1] * v[1];
      minU = Math.min(minU, du); maxU = Math.max(maxU, du);
      minV = Math.min(minV, dv); maxV = Math.max(maxV, dv);
    }
    const area = (maxU - minU) * (maxV - minV);
    if (!best || area < best.area - 1e-9) best = { area, u, v, minU, maxU, minV, maxV };
  }
  const centerU = (best.minU + best.maxU) / 2;
  const centerV = (best.minV + best.maxV) / 2;
  let u = best.u;
  let a = (best.maxU - best.minU) / 2;
  let b = (best.maxV - best.minV) / 2;
  if (b > a) {
    u = best.v;
    [a, b] = [b, a];
  }
  return {
    center: [best.u[0] * centerU + best.v[0] * centerV, best.u[1] * centerU + best.v[1] * centerV],
    u,
    v: [-u[1], u[0]],
    a,
    b,
  };
}

// Roof height over a plan point: flat, or a hip or gable rising at pitch from the eaves
// of the footprint's bounding rectangle (a simple form for the roofs seen in photos).
function roofFunction(form, box, top, pitchDeg) {
  if (form === "flat") return { heightAt: () => top, faces: null };
  const rise = Math.tan((pitchDeg * Math.PI) / 180);
  const local = (p) => {
    const d = [p[0] - box.center[0], p[1] - box.center[1]];
    return [d[0] * box.u[0] + d[1] * box.u[1], d[0] * box.v[0] + d[1] * box.v[1]];
  };
  const toPlan = ([lu, lv]) => [box.center[0] + box.u[0] * lu + box.v[0] * lv, box.center[1] + box.u[1] * lu + box.v[1] * lv];
  const { a, b } = box;
  const grow = 1.02;
  const A = a * grow + 0.5;
  const B = b * grow + 0.5;
  // Each face: its plan region (in local u, v) and its distance to its eave line.
  const faces = form === "hip"
    ? [
      { region: [[-A, B], [-(a - b), 0], [a - b, 0], [A, B]], distance: ([, lv]) => b - lv },
      { region: [[A, -B], [a - b, 0], [-(a - b), 0], [-A, -B]], distance: ([, lv]) => b + lv },
      { region: [[A, B], [a - b, 0], [A, -B]], distance: ([lu]) => a - lu },
      { region: [[-A, -B], [-(a - b), 0], [-A, B]], distance: ([lu]) => a + lu },
    ]
    : [
      { region: [[-A, 0], [A, 0], [A, B], [-A, B]], distance: ([, lv]) => b - lv },
      { region: [[-A, -B], [A, -B], [A, 0], [-A, 0]], distance: ([, lv]) => b + lv },
    ];
  const heightAt = (p) => {
    const l = local(p);
    const nearest = form === "hip" ? Math.min(b - Math.abs(l[1]), a - Math.abs(l[0])) : b - Math.abs(l[1]);
    return top + rise * Math.max(0, nearest);
  };
  return {
    heightAt,
    faces: faces.map((face) => ({
      plan: face.region.map(toPlan),
      heightAt: (p) => top + rise * Math.max(0, face.distance(local(p))),
    })),
  };
}

// Walls from the roof line down into the ground, and the roof, of one footprint.
// facade: {bay_m, base} for a photographed building's banded wall: UVs in metres, u
// along each edge centred on its bays, v the height above the building's base.
function addMassing({ walls, roof, footprint, roofForm, groundAt, wallBottomCap, wallStepM, buryM, facade = null }) {
  const wallVertex = vertexWriter(walls);
  const roofVertex = vertexWriter(roof);
  const up = [0, 1, 0];
  for (const polygon of footprint) {
    for (const ring of polygon) {
      // Outer rings are counter-clockwise and holes clockwise (canonical), so outward
      // is to the right of every edge.
      for (let index = 0; index < ring.length; index += 1) {
        const start = ring[index];
        const end = ring[(index + 1) % ring.length];
        const length = Math.hypot(end[0] - start[0], end[1] - start[1]);
        if (length <= 0.01) continue;
        const outwardPlan = [(end[1] - start[1]) / length, -(end[0] - start[0]) / length];
        const outward = [outwardPlan[0], 0, -outwardPlan[1]];
        const pieces = Math.max(1, Math.ceil(length / wallStepM));
        for (let piece = 0; piece < pieces; piece += 1) {
          const p = [start[0] + ((end[0] - start[0]) * piece) / pieces, start[1] + ((end[1] - start[1]) * piece) / pieces];
          const q = [start[0] + ((end[0] - start[0]) * (piece + 1)) / pieces, start[1] + ((end[1] - start[1]) * (piece + 1)) / pieces];
          const along0 = (length * piece) / pieces;
          const along1 = (length * (piece + 1)) / pieces;
          const bottom = (point) => Math.min(wallBottomCap, (groundAt(point[0], point[1]) ?? wallBottomCap) - buryM);
          const pt = roofForm.heightAt(p);
          const qt = roofForm.heightAt(q);
          const pb = bottom(p);
          const qb = bottom(q);
          const uvAt = (along, y) => facade
            ? [along - (length % facade.bay_m) / 2, y - facade.base]
            : [along / 10, y / 10];
          const a = wallVertex([p[0], pb, -p[1]], outward, uvAt(along0, pb));
          const b = wallVertex([q[0], qb, -q[1]], outward, uvAt(along1, qb));
          const c = wallVertex([q[0], qt, -q[1]], outward, uvAt(along1, qt));
          const d = wallVertex([p[0], pt, -p[1]], outward, uvAt(along0, pt));
          pushTriangle(walls, a, b, c, outward);
          pushTriangle(walls, a, c, d, outward);
        }
      }
    }
  }
  const faces = roofForm.faces ?? [{ plan: null, heightAt: roofForm.heightAt }];
  for (const face of faces) {
    const region = face.plan ? rawIntersect(footprint, [[closeRing(face.plan)]]) : footprint;
    for (const triangle of earcutMultiPolygon(region)) {
      const corners = triangle.map((p) => [p[0], face.heightAt(p), -p[1]]);
      const ab = [corners[1][0] - corners[0][0], corners[1][1] - corners[0][1], corners[1][2] - corners[0][2]];
      const ac = [corners[2][0] - corners[0][0], corners[2][1] - corners[0][1], corners[2][2] - corners[0][2]];
      let normal = [ab[1] * ac[2] - ab[2] * ac[1], ab[2] * ac[0] - ab[0] * ac[2], ab[0] * ac[1] - ab[1] * ac[0]];
      const length = Math.hypot(...normal);
      if (length <= 1e-9) continue;
      normal = normal.map((value) => value / length);
      if (normal[1] < 0) normal = normal.map((value) => -value);
      const [a, b, c] = corners.map((corner, k) => roofVertex(corner, normal, [triangle[k][0] / 10, -triangle[k][1] / 10]));
      pushTriangle(roof, a, b, c, up);
    }
  }
}

function closeRing(ring) {
  // polygon-clipping accepts open or closed rings; orient counter-clockwise.
  let area = 0;
  for (let index = 0; index < ring.length; index += 1) {
    const p = ring[index];
    const q = ring[(index + 1) % ring.length];
    area += p[0] * q[1] - q[0] * p[1];
  }
  return area >= 0 ? ring : [...ring].reverse();
}

// The surface of revolution with constant negative curvature (a pseudosphere), as the
// plaque at Hiroshi Sugimoto's Point of Infinity gives it: x = cos u / cosh v,
// y = sin u / cosh v, z = v - tanh v, scaled by radius (the rim's radius) and cut at the
// v where it reaches height. Rings crowd towards the rim, where the profile turns
// fastest; the tip closes on a point; a short skirt under the rim meets uneven ground.
// UV: u round the axis (0-1), v the height above the rim in metres.
function pseudosphereVMax(radius, height) {
  const target = height / radius;
  let v = target + 1;
  for (let step = 0; step < 60; step += 1) {
    const f = v - Math.tanh(v) - target;
    const slope = Math.tanh(v) ** 2;
    v -= f / slope;
  }
  invariant(Number.isFinite(v) && v > 0 && Math.abs(v - Math.tanh(v) - target) < 1e-9, "Pseudosphere height has no solution");
  return v;
}

function pseudosphereMesh({ center, base, radius, height, rings, segments, power, skirt, bed }) {
  const mesh = emptyMesh();
  const vertex = vertexWriter(mesh, false, true);
  const vMax = pseudosphereVMax(radius, height);
  const ringIndices = [];
  for (let k = 0; k <= rings; k += 1) {
    const v = vMax * (k / rings) ** power;
    const r = radius / Math.cosh(v);
    const z = radius * (v - Math.tanh(v));
    const radial = Math.tanh(v);
    const up = 1 / Math.cosh(v);
    const row = [];
    for (let j = 0; j <= segments; j += 1) {
      const angle = (j / segments) * Math.PI * 2;
      const c = Math.cos(angle);
      const sn = Math.sin(angle);
      row.push(vertex([center[0] + r * c, base + z, -(center[1] + r * sn)], [radial * c, up, -radial * sn], [j / segments, z]));
    }
    ringIndices.push(row);
  }
  const apexHeight = radius * (vMax - Math.tanh(vMax));
  const apex = vertex([center[0], base + apexHeight + 0.004, -center[1]], [0, 1, 0], [0.5, apexHeight + 0.004]);
  for (let k = 0; k < rings; k += 1) {
    for (let j = 0; j < segments; j += 1) {
      const angle = ((j + 0.5) / segments) * Math.PI * 2;
      const outward = [Math.cos(angle), 0.3, -Math.sin(angle)];
      const a = ringIndices[k][j];
      const b = ringIndices[k][j + 1];
      const c = ringIndices[k + 1][j + 1];
      const d = ringIndices[k + 1][j];
      pushTriangle(mesh, a, b, c, outward);
      pushTriangle(mesh, a, c, d, outward);
    }
  }
  for (let j = 0; j < segments; j += 1) {
    const angle = ((j + 0.5) / segments) * Math.PI * 2;
    pushTriangle(mesh, ringIndices[rings][j], ringIndices[rings][j + 1], apex, [Math.cos(angle), 0.5, -Math.sin(angle)]);
  }
  // The skirt: straight down from the rim, its own vertices with level normals.
  for (let j = 0; j < segments; j += 1) {
    const angles = [j, j + 1].map((n) => (n / segments) * Math.PI * 2);
    const middle = ((j + 0.5) / segments) * Math.PI * 2;
    const outward = [Math.cos(middle), 0, -Math.sin(middle)];
    const corner = (angle, y) => vertex([center[0] + radius * Math.cos(angle), y, -(center[1] + radius * Math.sin(angle))], [Math.cos(angle), 0, -Math.sin(angle)], [angle / (Math.PI * 2), y - base]);
    const a = corner(angles[0], base - skirt);
    const b = corner(angles[1], base - skirt);
    const c = corner(angles[1], base);
    const d = corner(angles[0], base);
    pushTriangle(mesh, a, b, c, outward);
    pushTriangle(mesh, a, c, d, outward);
  }
  // The bed it stands in: gravel from just inside the rim out to the curb, burying the
  // rim's last flare, then the curb ring, its outer face down below the plaza. UV.x
  // carries the part (0-1 the sculpture, 2-3 the gravel, 4-5 the curb), UV.y the height
  // above the rim.
  if (bed) {
    invariant(bed.rim_burial_m > 0 && bed.rim_burial_m < radius && bed.gravel_lift_m > 0 && bed.curb_height_m > bed.gravel_lift_m
      && bed.gravel_outer_m > radius && bed.curb_outer_m > bed.gravel_outer_m, "The sculpture's bed does not ring its rim");
    const steps = segments * 2;
    const ring = (part, r, y, normal) => {
      const row = [];
      for (let j = 0; j <= steps; j += 1) {
        const angle = (j / steps) * Math.PI * 2;
        const c = Math.cos(angle);
        const sn = Math.sin(angle);
        const n = normal === "out" ? [c, 0, -sn] : normal === "in" ? [-c, 0, sn] : [0, 1, 0];
        row.push(vertex([center[0] + r * c, y, -(center[1] + r * sn)], n, [part * 2 + j / steps, y - base]));
      }
      return row;
    };
    const band = (inner, outer, facing) => {
      for (let j = 0; j < steps; j += 1) {
        const angle = ((j + 0.5) / steps) * Math.PI * 2;
        const f = facing === "out" ? [Math.cos(angle), 0, -Math.sin(angle)] : facing === "in" ? [-Math.cos(angle), 0, Math.sin(angle)] : [0, 1, 0];
        pushTriangle(mesh, inner[j], inner[j + 1], outer[j + 1], f);
        pushTriangle(mesh, inner[j], outer[j + 1], outer[j], f);
      }
    };
    const gravel = base + bed.gravel_lift_m;
    const curbTop = base + bed.curb_height_m;
    band(ring(1, radius - bed.rim_burial_m, gravel, "up"), ring(1, bed.gravel_outer_m, gravel, "up"), "up");
    band(ring(2, bed.gravel_outer_m, gravel, "in"), ring(2, bed.gravel_outer_m, curbTop, "in"), "in");
    band(ring(2, bed.gravel_outer_m, curbTop, "up"), ring(2, bed.curb_outer_m, curbTop, "up"), "up");
    band(ring(2, bed.curb_outer_m, base - skirt, "out"), ring(2, bed.curb_outer_m, curbTop, "out"), "out");
  }
  return { mesh, vMax, tipDiameter: (2 * radius) / Math.cosh(vMax) };
}

// A wall along an OSM barrier line: its height read from the DEM's step across the line
// (a retaining wall holds back the ground on its high side), else freestanding.
function barrierWallMesh(mesh, line, sampleDem, groundAt, rules) {
  const vertex = vertexWriter(mesh);
  const pieces = [];
  for (let k = 1; k < line.length; k += 1) {
    const length = Math.hypot(line[k][0] - line[k - 1][0], line[k][1] - line[k - 1][1]);
    const steps = Math.max(1, Math.ceil(length / rules.step_m));
    for (let s = 0; s < steps; s += 1) {
      pieces.push([0, 1].map((e) => [
        line[k - 1][0] + ((line[k][0] - line[k - 1][0]) * (s + e)) / steps,
        line[k - 1][1] + ((line[k][1] - line[k - 1][1]) * (s + e)) / steps,
      ]));
    }
  }
  let heightSum = 0;
  for (const [p, q] of pieces) {
    const length = Math.hypot(q[0] - p[0], q[1] - p[1]);
    if (length <= 0.05) continue;
    const across = [-(q[1] - p[1]) / length, (q[0] - p[0]) / length];
    const half = rules.thickness_m / 2;
    const ends = [p, q].map((point) => {
      const left = sampleDem(point[0] + across[0] * rules.probe_m, point[1] + across[1] * rules.probe_m);
      const right = sampleDem(point[0] - across[0] * rules.probe_m, point[1] - across[1] * rules.probe_m);
      const here = groundAt(point[0], point[1]) ?? Math.min(left, right);
      const step = Math.abs(left - right);
      const top = step >= rules.retaining_step_m
        ? Math.max(left, right) + rules.coping_m
        : here + rules.freestanding_m;
      const bottom = Math.min(here, Math.min(left, right)) - rules.bury_m;
      return { point, top: Math.min(top, bottom + rules.bury_m + rules.max_height_m), bottom };
    });
    heightSum += (ends[0].top - ends[0].bottom + ends[1].top - ends[1].bottom) / 2 * length;
    for (const side of [1, -1]) {
      const outward = [across[0] * side, 0, -across[1] * side];
      const offset = (point) => [point[0] + across[0] * half * side, point[1] + across[1] * half * side];
      const [a, b] = ends.map((end) => offset(end.point));
      const ia = vertex([a[0], ends[0].bottom, -a[1]], outward, [0, ends[0].bottom]);
      const ib = vertex([b[0], ends[1].bottom, -b[1]], outward, [length, ends[1].bottom]);
      const ic = vertex([b[0], ends[1].top, -b[1]], outward, [length, ends[1].top]);
      const id = vertex([a[0], ends[0].top, -a[1]], outward, [0, ends[0].top]);
      pushTriangle(mesh, ia, ib, ic, outward);
      pushTriangle(mesh, ia, ic, id, outward);
    }
    // The coping.
    const corners = [[ends[0], 1], [ends[1], 1], [ends[1], -1], [ends[0], -1]].map(([end, side]) => {
      const point = [end.point[0] + across[0] * half * side, end.point[1] + across[1] * half * side];
      return vertex([point[0], end.top, -point[1]], [0, 1, 0], [point[0] / 10, -point[1] / 10]);
    });
    pushTriangle(mesh, corners[0], corners[1], corners[2], [0, 1, 0]);
    pushTriangle(mesh, corners[0], corners[2], corners[3], [0, 1, 0]);
  }
  return heightSum;
}

// A barrier's line where it runs on YBI's land (its vertices inside, kept in order).
function rawLineOnLand(joined, land) {
  const line = geometryToLine(selectGeometry(joined.exported, "line"), joined.row.source_key);
  return line.filter((point) => pointInMultiPolygon(point, land, true));
}

// --- Rasters -----------------------------------------------------------------------

function rasterGrid() {
  const { origin_xz: [x0, z0], cell_m: cell, width, height } = YBI_LAND_COVER_GRID;
  return { x0, z0, cell, width, height, centerX: (i) => x0 + (i + 0.5) * cell, centerZ: (j) => z0 + (j + 0.5) * cell };
}

// Marks the cells of grid whose centres a plan multipolygon covers.
function rasterizeMultiPolygon(grid, mask, multiPolygon, value = 1) {
  for (const triangle of earcutMultiPolygon(multiPolygon)) {
    rasterizeTriangle(grid, triangle.map((p) => [p[0], -p[1]]), (index) => {
      mask[index] = value;
    });
  }
}

function dilate(grid, mask, radiusM) {
  if (radiusM <= 0) return mask;
  const distance = distanceToMask(grid, mask);
  const out = new Uint8Array(mask.length);
  for (let index = 0; index < mask.length; index += 1) out[index] = distance[index] <= radiusM ? 1 : 0;
  return out;
}

function boxBlur(grid, values, radiusCells) {
  const { width, height } = grid;
  const out = new Float32Array(values.length);
  for (let j = 0; j < height; j += 1) {
    for (let i = 0; i < width; i += 1) {
      let sum = 0;
      let count = 0;
      for (let dj = -radiusCells; dj <= radiusCells; dj += 1) {
        const y = j + dj;
        if (y < 0 || y >= height) continue;
        for (let di = -radiusCells; di <= radiusCells; di += 1) {
          const x = i + di;
          if (x < 0 || x >= width) continue;
          sum += values[y * width + x];
          count += 1;
        }
      }
      out[j * width + i] = sum / count;
    }
  }
  return out;
}

// --- The context -------------------------------------------------------------------

function heightFor(tags, config, sourceKey = null) {
  const rules = config.buildings;
  const bySource = rules.inferred_by_source?.[sourceKey];
  const height = Number.parseFloat(tags.height);
  if (/^\d+(\.\d+)?$/u.test(String(tags.height ?? "").trim()) && height > 0) {
    return { rule: "osm_height", height_m: round3(height) };
  }
  const levels = Number.parseFloat(tags["building:levels"]);
  if (/^\d+(\.\d+)?$/u.test(String(tags["building:levels"] ?? "").trim()) && levels > 0) {
    return { rule: "osm_levels", height_m: round3(levels * rules.storey_m + rules.parapet_m) };
  }
  if (bySource) return { rule: "inferred_from_photo", height_m: round3(bySource.height_m) };
  const type = tags.man_made === "storage_tank" ? "storage_tank" : tags.amenity === "shelter" ? "shelter" : String(tags.building ?? tags["building:part"] ?? "yes");
  if (rules.inferred_storeys[type] != null) {
    return { rule: `inferred_${type}_storeys`, height_m: round3(rules.inferred_storeys[type] * rules.storey_m + rules.parapet_m) };
  }
  return { rule: `inferred_${type}`, height_m: round3(rules.inferred_height_m[type] ?? rules.inferred_height_m.yes) };
}

// Samples of a footprint's drawn ground: centre, lowest and highest.
function footprintGround(footprint, groundAt) {
  const bounds = multiPolygonBounds(footprint);
  const values = [];
  const step = Math.max(1, Math.min(bounds.max_x - bounds.min_x, bounds.max_y - bounds.min_y) / 6);
  for (let east = bounds.min_x; east <= bounds.max_x + 1e-9; east += step) {
    for (let north = bounds.min_y; north <= bounds.max_y + 1e-9; north += step) {
      if (!pointInMultiPolygon([east, north], footprint, true)) continue;
      const value = groundAt(east, north);
      if (value != null) values.push(value);
    }
  }
  for (const polygon of footprint) for (const point of polygon[0]) {
    const value = groundAt(point[0], point[1]);
    if (value != null) values.push(value);
  }
  invariant(values.length > 0, "A YBI footprint has no ground under it");
  const centroid = multiPolygonCentroid(footprint);
  const center = pointInMultiPolygon(centroid, footprint, true) ? groundAt(centroid[0], centroid[1]) : null;
  const sorted = [...values].sort((l, r) => l - r);
  return { min: sorted[0], max: sorted.at(-1), center: center ?? sorted[Math.floor(sorted.length / 2)] };
}

// Everything YBI draws. sources: the joined YBI context rows ({row, tags, exported});
// continuations: the playable objects of YBI_CONTINUATION_SOURCE_KEYS.
export function buildYbiContext({ projectRoot, land, boundary, playableBoundary, sources, continuations, rawSources, terrain: dem, seamElevation }) {
  const config = loadYbiConfig(projectRoot);
  const cover = loadYbiLandCover(projectRoot);
  const seam = ringSegments(land).filter(([a, b]) => distanceToMultiPolygon([(a[0] + b[0]) / 2, (a[1] + b[1]) / 2], boundary) <= 0.002);
  const terrain = buildTerrain({
    land,
    seam,
    sampleDem: dem.sampleTerrainEastNorth,
    seamElevation,
    cellM: config.terrain.grid_m,
    normalSampleM: config.terrain.normal_sample_m,
    skirtBottomM: config.terrain.skirt_bottom_m,
  });
  const groundAt = (east, north) => terrain.groundAt(east, north);

  // Objects for the coverage ledger, keyed by source.
  const objects = new Map();
  const addObject = (joined, logicalKey, physicalKeys, geometry, height = null) => {
    objects.set(joined.row.source_key, {
      row: joined.row,
      tags: joined.tags,
      roles: joined.row.categories.split("|"),
      logical_key: logicalKey,
      representation: "composite",
      geometry,
      source_measure: geometry ? multiPolygonArea(geometry) : 0,
      clipped_measure: geometry ? multiPolygonArea(geometry) : 0,
      geometry_sha256: geometry ? sha256Bytes(stableJson(geometry.map((polygon) => polygon.map((ring) => ring.map((point) => point.map(round3)))))) : null,
      // Context composites draw no serialized source polygon of their own, so the
      // playable area audits do not apply; they report zero.
      pre_serialization_area_delta_m2: 0,
      post_serialization_area_delta_m2: 0,
      post_serialization_tolerance_m2: 0,
      serialization_perimeter_m: 0,
      quantization_delta_m: 0,
      post_serialization_normalized_error: 0,
      height,
      physical_object_keys: new Set(physicalKeys),
      chunk_ids: new Set(),
    });
  };

  // The Bay Bridge track (its own owner). Where it runs at grade (I-80 and its ramps
  // from the tunnel's east portal, the ramps' grade points and both portals) the ground
  // is a clear road cut: no trees, no buildings. Under its elevated decks (bridge-tagged
  // ways and the man_made=bridge areas) trees may stand below the deck.
  const track = config.bridge_track;
  const clearParts = [];
  const deckParts = [];
  const circle = ([east, north], radius) => {
    const ring = [];
    for (let k = 0; k < 24; k += 1) {
      const angle = (k / 24) * Math.PI * 2;
      ring.push([east + Math.cos(angle) * radius, north + Math.sin(angle) * radius]);
    }
    return [[ring]];
  };
  for (const source of [...rawSources.values()].sort((l, r) => compareCodePoints(l.source_key, r.source_key))) {
    const tags = source.metadata.tags;
    const elevated = (tags.highway != null && yes(tags.bridge)) || tags.man_made === "bridge";
    const atGrade = tags.highway != null && isBridgeTrackHighway(tags) && !yes(tags.bridge) && !yes(tags.tunnel);
    if (!elevated && !atGrade) continue;
    for (const geometry of source.features) {
      if (geometry.type === "LineString") {
        const width = track.widths_m[tags.highway] ?? track.widths_m.default;
        const margin = elevated ? track.deck_margin_m : track.exclude_margin_m;
        (elevated ? deckParts : clearParts).push(ribbon(geometryToLine(geometry, source.source_key), width + 2 * margin, `${source.source_key}/bridge-track`));
      } else if ((geometry.type === "Polygon" || geometry.type === "MultiPolygon") && elevated) {
        deckParts.push(rawGeometry(geometry));
      }
    }
  }
  for (const portal of track.portals) clearParts.push(circle(portal.east_north, track.portal_radius_m));
  for (const point of track.grade_points) clearParts.push(circle(point.east_north, track.grade_points_radius_m));
  const bridgeClear = rawIntersect(rawUnion(...clearParts), land);
  const bridgeDeck = rawIntersect(rawUnion(...deckParts), land);

  // --- Buildings and structures.
  const walls = emptyMesh();
  const roofs = emptyMesh();
  const buildingFootprints = [];
  const byCategory = (category) => sources.filter((joined) => joined.row.categories.split("|").includes(category));
  const buildingSources = byCategory("context_ybi_building");
  const buildingBase = new Map();
  // Photographed buildings' walls carry their façade's coarse banding (their own
  // records); the summit sculpture is its own record; every other wall shares one.
  const facadeKeys = buildingSources.filter((joined) => config.facades[joined.row.source_key]).map((joined) => joined.row.source_key);
  const facadeMeshes = new Map(facadeKeys.map((key) => [key, emptyMesh()]));
  const structureKeys = byCategory("context_ybi_structure").map((joined) => joined.row.source_key);
  const massingKeys = [
    `${YBI_BUILDINGS_KEY}:roof`,
    `${YBI_BUILDINGS_KEY}:wall`,
    ...facadeKeys.map((key) => `${YBI_BUILDINGS_KEY}:facade:${key}`),
    ...(structureKeys.length > 0 ? [`${YBI_BUILDINGS_KEY}:spire`] : []),
  ];
  const buildingReport = [];
  for (const joined of buildingSources) {
    const footprint = rawIntersect(geometryToMultiPolygon(selectGeometry(joined.exported, "area"), joined.row.source_key), land);
    invariant(footprint.length > 0, `${joined.row.source_key} has no footprint on YBI's land`);
    const height = heightFor(joined.tags, config, joined.row.source_key);
    const ground = footprintGround(footprint, groundAt);
    const base = Math.max(ground.center, ground.max - 0.5 * height.height_m);
    const top = base + height.height_m;
    const roof = config.roofs[joined.row.source_key];
    const roofForm = roofFunction(roof?.form ?? "flat", orientedBox(footprint), top, roof?.pitch_deg ?? 0);
    const facade = config.facades[joined.row.source_key];
    addMassing({
      walls: facade ? facadeMeshes.get(joined.row.source_key) : walls,
      roof: roofs,
      footprint,
      roofForm,
      groundAt,
      wallBottomCap: base,
      wallStepM: config.buildings.wall_step_m,
      buryM: config.buildings.wall_bury_m,
      facade: facade ? { bay_m: facade.bay_m, base } : null,
    });
    buildingFootprints.push(footprint);
    buildingBase.set(joined.row.source_key, { footprint, base, top, height: height.height_m });
    addObject(joined, YBI_BUILDINGS_KEY, massingKeys, footprint, height);
    buildingReport.push({ source_key: joined.row.source_key, rule: height.rule, height_m: height.height_m, base_m: round3(base), roof: roof?.form ?? "flat" });
  }
  for (const joined of byCategory("context_ybi_building_part")) {
    const footprint = rawIntersect(geometryToMultiPolygon(selectGeometry(joined.exported, "area"), joined.row.source_key), land);
    invariant(footprint.length > 0, `${joined.row.source_key} has no footprint on YBI's land`);
    const centroid = multiPolygonCentroid(footprint);
    const parent = [...buildingBase.entries()].find(([, building]) => pointInMultiPolygon(centroid, building.footprint, true));
    let height = heightFor(joined.tags, config);
    if (joined.tags.height == null && parent && joined.tags.man_made === "tower") {
      height = { rule: "inferred_part_tower", height_m: round3(parent[1].height + config.buildings.part_tower_extra_m) };
    } else if (joined.tags.height == null && parent) {
      height = { rule: "inferred_part_parent", height_m: round3(parent[1].height) };
    }
    const ground = footprintGround(footprint, groundAt);
    const base = parent ? parent[1].base : Math.max(ground.center, ground.max - 0.5 * height.height_m);
    const top = base + height.height_m;
    // A part rises from its parent's roof, so the two never share a wall face.
    const floor = parent ? parent[1].top : base;
    if (top > floor + 0.05) {
      addMassing({
        walls,
        roof: roofs,
        footprint,
        roofForm: { heightAt: () => top, faces: null },
        groundAt: parent ? () => floor + 0.6 + 0.05 : groundAt,
        wallBottomCap: floor,
        wallStepM: config.buildings.wall_step_m,
        buryM: config.buildings.wall_bury_m,
      });
    }
    addObject(joined, YBI_BUILDINGS_KEY, massingKeys, footprint, height);
    buildingReport.push({ source_key: joined.row.source_key, rule: height.rule, height_m: height.height_m, base_m: round3(base), roof: "flat", parent: parent?.[0] ?? null });
  }
  // --- Roads, paths and paved areas: disjoint, so equal biases never fight.
  const ribbonFor = (joined, label) => {
    const line = geometryToLine(selectGeometry(joined.exported, "line"), label);
    const width = config.surfaces.road_widths_m[joined.tags.highway];
    invariant(width > 0, `${label} highway=${joined.tags.highway} has no YBI width`);
    return rawIntersect(ribbon(line, joined.tags.highway === "construction" && joined.tags.construction == null ? 4 : width, label), land);
  };
  const drawn = [];
  const claim = (geometry) => {
    const free = rawDifference(geometry, ...drawn);
    if (free.length > 0 && multiPolygonArea(free) > 0.01) drawn.push(free);
    return free;
  };
  const boundaryVisuals = [];
  const continuationRecords = [];
  const addContinuation = (object, klass) => {
    const run = rawIntersect(ribbon(geometryToLine(selectGeometry(object.exported, "line"), object.row.source_key), ROAD_CONTINUATION_WIDTH(object, config), object.row.source_key), land);
    const free = claim(run);
    if (free.length === 0 || multiPolygonArea(free) <= 0.01) return;
    const mesh = drapeMultiPolygon(free, terrain, config.surfaces.bias_m);
    if (mesh.indices.length === 0) return;
    continuationRecords.push({ object, klass, mesh });
  };
  const roadsByClass = { vehicle: [], pedestrian: [], construction: [] };
  for (const joined of byCategory("context_ybi_road")) roadsByClass[roadClass(joined.tags)].push(joined);
  const areasByClass = { pedestrian: [], paved: [] };
  for (const joined of byCategory("context_ybi_paved_area")) areasByClass[pavedAreaClass(joined.tags)].push(joined);
  const areaGeometry = (members) => members.map((joined) =>
    rawIntersect(geometryToMultiPolygon(selectGeometry(joined.exported, "area"), joined.row.source_key), land));
  const surfaceGeometry = {};
  // Vehicle roads first (the playable continuations, then YBI's own), paved lots, plazas,
  // construction, paths; the plazas draw with the paths.
  for (const object of continuations.filter((item) => item.road_visual_class === "vehicle")) addContinuation(object, "vehicle");
  surfaceGeometry.vehicle = claim(rawUnion(...roadsByClass.vehicle.map((joined) => ribbonFor(joined, joined.row.source_key))));
  surfaceGeometry.paved = claim(rawUnion(...areaGeometry(areasByClass.paved)));
  const plazas = claim(rawUnion(...areaGeometry(areasByClass.pedestrian)));
  surfaceGeometry.construction = claim(rawUnion(...roadsByClass.construction.map((joined) => ribbonFor(joined, joined.row.source_key))));
  for (const object of continuations.filter((item) => item.road_visual_class !== "vehicle")) addContinuation(object, "pedestrian");
  const paths = claim(rawUnion(...roadsByClass.pedestrian.map((joined) => ribbonFor(joined, joined.row.source_key))));
  surfaceGeometry.pedestrian = rawUnion(plazas, paths);
  const surfaceMembers = { ...roadsByClass, pedestrian: [...roadsByClass.pedestrian, ...areasByClass.pedestrian], paved: areasByClass.paved };
  const records = [];
  const surfaceReport = {};
  for (const [klass, spec] of Object.entries(YBI_SURFACE_RECORDS)) {
    const members = surfaceMembers[klass];
    if (members.length === 0) continue;
    const geometry = surfaceGeometry[klass];
    const mesh = drapeMultiPolygon(geometry, terrain, config.surfaces.bias_m);
    invariant(mesh.indices.length > 0, `${spec.object_key} draped no triangles`);
    records.push({ object_key: spec.object_key, context_kind: "ybi_surface", material_key: spec.material_key, source_keys: members.map((joined) => joined.row.source_key), mesh });
    for (const joined of members) addObject(joined, spec.object_key, [spec.object_key], null);
    surfaceReport[klass] = { sources: members.length, area_m2: round2(multiPolygonArea(geometry)) };
  }
  // The summit reservoir, under every road and path: its pale concrete banks a band
  // across its mapped edge, its water inside them.
  const basins = byCategory("context_ybi_water");
  if (basins.length > 0) {
    const edges = [];
    for (const polygon of rawUnion(...areaGeometry(basins))) {
      for (const ring of polygon) edges.push(ribbon([...ring, ring[0]], config.basin.lining_m, "context_ybi_water edge"));
    }
    const parts = {
      lining: claim(rawIntersect(rawUnion(...edges), land)),
      water: claim(rawUnion(...areaGeometry(basins))),
    };
    const basinKeys = Object.values(YBI_BASIN_RECORDS).map((spec) => spec.object_key);
    for (const [part, spec] of Object.entries(YBI_BASIN_RECORDS)) {
      const mesh = drapeMultiPolygon(parts[part], terrain, config.surfaces.bias_m);
      invariant(mesh.indices.length > 0, `${spec.object_key} draped no triangles`);
      records.push({ object_key: spec.object_key, context_kind: "ybi_surface", material_key: spec.material_key, source_keys: basins.map((joined) => joined.row.source_key), mesh });
      surfaceReport[`basin_${part}`] = { sources: basins.length, area_m2: round2(multiPolygonArea(parts[part])) };
    }
    for (const joined of basins) addObject(joined, YBI_BASIN_RECORDS.water.object_key, basinKeys, null);
  }
  for (const { object, klass, mesh } of continuationRecords) {
    boundaryVisuals.push({
      object_key: `boundary_context:${object.row.source_key}`,
      context_kind: "boundary_attached_visual",
      material_key: YBI_SURFACE_RECORDS[klass].material_key,
      source_keys: [object.row.source_key],
      mesh,
    });
  }
  // The summit sculpture, on the drawn plaza where OSM's pedestrian area paves it.
  const structureReport = [];
  let spireMesh = null;
  for (const joined of byCategory("context_ybi_structure")) {
    const footprint = rawIntersect(geometryToMultiPolygon(selectGeometry(joined.exported, "area"), joined.row.source_key), land);
    const structure = config.structures[joined.row.source_key];
    invariant(structure?.form === "pseudosphere", `${joined.row.source_key} has no structure rule`);
    const height = { rule: "osm_height", height_m: round3(structure.height_m) };
    invariant(Math.abs(Number.parseFloat(joined.tags.height) - structure.height_m) < 0.1, `${joined.row.source_key} height drifts from its OSM height`);
    const center = multiPolygonCentroid(footprint);
    const ground = groundAt(center[0], center[1]);
    invariant(ground != null, `${joined.row.source_key} stands off YBI's terrain`);
    const onPaving = drawn.some((geometry) => pointInMultiPolygon(center, geometry, true));
    const base = ground + (onPaving ? config.surfaces.bias_m + 0.01 : 0);
    const built = pseudosphereMesh({
      center,
      base,
      radius: structure.radius_m,
      height: structure.height_m,
      rings: structure.rings,
      segments: structure.segments,
      power: structure.ring_power,
      skirt: structure.skirt_m,
      bed: structure.bed,
    });
    spireMesh = built.mesh;
    addObject(joined, YBI_BUILDINGS_KEY, massingKeys, footprint, height);
    const report = {
      source_key: joined.row.source_key,
      rule: height.rule,
      height_m: height.height_m,
      radius_m: structure.radius_m,
      v_max: round3(built.vMax),
      tip_diameter_mm: round2(built.tipDiameter * 1000),
      base_m: round3(base),
      dem_m: round3(dem.sampleTerrainEastNorth(center[0], center[1])),
      world_xz: [round3(center[0]), round3(-center[1])],
      on_paving: onPaving,
    };
    structureReport.push(report);
    buildingReport.push({ ...report, roof: "pseudosphere" });
  }
  const massingSources = [...buildingBase.keys(), ...byCategory("context_ybi_building_part").map((j) => j.row.source_key), ...structureKeys];
  records.push({ object_key: `${YBI_BUILDINGS_KEY}:roof`, context_kind: "ybi_building", material_key: "context_ybi_building_roof", source_keys: massingSources, mesh: roofs });
  records.push({ object_key: `${YBI_BUILDINGS_KEY}:wall`, context_kind: "ybi_building", material_key: "context_ybi_building_wall", source_keys: massingSources, mesh: walls });
  for (const key of facadeKeys) {
    records.push({ object_key: `${YBI_BUILDINGS_KEY}:facade:${key}`, context_kind: "ybi_building", material_key: `context_ybi_facade_${config.facades[key].style}`, source_keys: massingSources, mesh: facadeMeshes.get(key) });
  }
  if (spireMesh) records.push({ object_key: `${YBI_BUILDINGS_KEY}:spire`, context_kind: "ybi_building", material_key: "context_ybi_spire", source_keys: massingSources, mesh: spireMesh });
  // Retaining walls and walls (OSM barriers), heights from the DEM's step across them.
  const wallSources = byCategory("context_ybi_wall");
  const wallReport = [];
  if (wallSources.length > 0) {
    const wallMesh = emptyMesh();
    for (const joined of wallSources) {
      const line = rawLineOnLand(joined, land);
      if (line.length < 2) continue;
      const area = barrierWallMesh(wallMesh, line, dem.sampleTerrainEastNorth, groundAt, config.walls);
      wallReport.push({ source_key: joined.row.source_key, face_m2: round2(area) });
      addObject(joined, YBI_WALLS_KEY, [YBI_WALLS_KEY], null);
    }
    for (const joined of wallSources) if (!objects.has(joined.row.source_key)) addObject(joined, YBI_WALLS_KEY, [YBI_WALLS_KEY], null);
    records.push({ object_key: YBI_WALLS_KEY, context_kind: "ybi_building", material_key: "context_ybi_wall", source_keys: wallSources.map((joined) => joined.row.source_key), mesh: wallMesh });
  }

  // --- Masks on the land-cover grid.
  const grid = rasterGrid();
  const cells = grid.width * grid.height;
  const landMask = new Uint8Array(cells);
  rasterizeMultiPolygon(grid, landMask, land);
  const paved = new Uint8Array(cells);
  for (const geometry of drawn) rasterizeMultiPolygon(grid, paved, geometry);
  const builtMask = new Uint8Array(cells);
  for (const footprint of buildingFootprints) rasterizeMultiPolygon(grid, builtMask, footprint);
  const bridgeMask = new Uint8Array(cells);
  if (bridgeClear.length > 0) rasterizeMultiPolygon(grid, bridgeMask, bridgeClear);
  const deckMask = new Uint8Array(cells);
  if (bridgeDeck.length > 0) rasterizeMultiPolygon(grid, deckMask, bridgeDeck);
  const water = new Uint8Array(cells);
  for (const source of rawSources.values()) {
    if (source.metadata.tags.natural !== "water") continue;
    for (const geometry of source.features) {
      if (geometry.type === "Polygon" || geometry.type === "MultiPolygon") rasterizeMultiPolygon(grid, water, rawIntersect(rawGeometry(geometry), land));
    }
  }
  const osmMask = (predicate) => {
    const mask = new Uint8Array(cells);
    for (const source of rawSources.values()) {
      if (!predicate(source.metadata.tags)) continue;
      for (const geometry of source.features) {
        if (geometry.type !== "Polygon" && geometry.type !== "MultiPolygon") continue;
        const clipped = rawIntersect(rawGeometry(geometry), land);
        if (clipped.length > 0) rasterizeMultiPolygon(grid, mask, clipped);
      }
    }
    return mask;
  };
  const scrubOsm = osmMask((tags) => tags.natural === "scrub");
  const rockOsm = osmMask((tags) => tags.natural === "bare_rock");
  const beachOsm = osmMask((tags) => tags.natural === "beach");
  const lawnOsm = osmMask((tags) => tags.landuse === "grass" || tags.leisure === "garden");
  const woodOsm = osmMask((tags) => tags.natural === "wood");
  const cliffMask = new Uint8Array(cells);
  for (const source of rawSources.values()) {
    if (source.metadata.tags.natural !== "cliff") continue;
    for (const geometry of source.features) {
      if (geometry.type === "LineString") rasterizeMultiPolygon(grid, cliffMask, rawIntersect(ribbon(geometryToLine(geometry, source.source_key), 6, source.source_key), land));
    }
  }
  const keepClear = dilate(grid, builtMask, 3);
  const pavedMargin = dilate(grid, paved, 1.5);
  const blocked = new Uint8Array(cells);
  for (let index = 0; index < cells; index += 1) blocked[index] = !landMask[index] || keepClear[index] || pavedMargin[index] || bridgeMask[index] || water[index] ? 1 : 0;
  // Trees within a crown's reach of a deck keep under it.
  const deckNear = dilate(grid, deckMask, 8);

  const at = (layer, index) => cover.layers[layer][index] / 255;
  // Canopy: the aerial's dark textured green, smoothed over 6 m, on free land.
  const canopyRaw = new Float32Array(cells);
  for (let index = 0; index < cells; index += 1) canopyRaw[index] = landMask[index] ? at("canopy", index) : 0;
  const canopy = boxBlur(grid, canopyRaw, 1);
  const veg = config.vegetation;
  let canopyMask = new Uint8Array(cells);
  for (let index = 0; index < cells; index += 1) canopyMask[index] = canopy[index] >= veg.canopy_threshold && !blocked[index] ? 1 : 0;
  // Open: drop specks of one cell.
  const eroded = new Uint8Array(cells);
  for (let j = 1; j < grid.height - 1; j += 1) for (let i = 1; i < grid.width - 1; i += 1) {
    const index = j * grid.width + i;
    eroded[index] = canopyMask[index] && canopyMask[index - 1] && canopyMask[index + 1] && canopyMask[index - grid.width] && canopyMask[index + grid.width] ? 1 : 0;
  }
  canopyMask = dilate(grid, eroded, 1.01 * grid.cell);
  for (let index = 0; index < cells; index += 1) if (blocked[index] || !(canopy[index] >= veg.canopy_threshold * 0.8)) canopyMask[index] = 0;
  // How tall the canopy stands: the deep shadow in and round it within 10 m, per canopy
  // cell there. Tall trees throw long shadows in the late-morning aerial, into their own
  // crowns in a wide grove and onto the open ground beside a narrow band of them; low
  // scrub throws hardly any. Shadow within reach of a building or the bridge is theirs,
  // not a tree's. OSM's wood is tall and its scrub low.
  const depth = distanceToMask(grid, Uint8Array.from(canopyMask, (value) => (value ? 0 : 1)));
  const structureShade = dilate(grid, Uint8Array.from(builtMask, (value, index) => (value || bridgeMask[index] || deckMask[index] ? 1 : 0)), veg.structure_shadow_m);
  const shadowRaw = new Float32Array(cells);
  for (let index = 0; index < cells; index += 1) shadowRaw[index] = landMask[index] && !water[index] && !structureShade[index] ? at("shadow", index) : 0;
  const canopyNear = boxBlur(grid, Float32Array.from(canopyMask), 2);
  const shadowNear = boxBlur(grid, shadowRaw, 2);
  const tall = new Float32Array(cells);
  for (let index = 0; index < cells; index += 1) {
    if (!canopyMask[index]) continue;
    const shadowShare = canopyNear[index] > 0 ? shadowNear[index] / canopyNear[index] : 0;
    let t = smoothstep(veg.tall_shadow_share[0], veg.tall_shadow_share[1], shadowShare);
    if (woodOsm[index]) t = Math.max(t, 0.7);
    if (scrubOsm[index]) t = Math.min(t, 0.3);
    tall[index] = t;
  }
  // Groves: canopy that stands tall; small trees where it is middling; scrub where low.
  const grovesCells = new Uint8Array(cells);
  const smallCells = new Uint8Array(cells);
  const scrubCells = new Uint8Array(cells);
  for (let index = 0; index < cells; index += 1) {
    if (!canopyMask[index]) continue;
    if (tall[index] >= veg.grove_tallness) grovesCells[index] = 1;
    else if (tall[index] >= veg.small_tree_tallness) smallCells[index] = 1;
    else scrubCells[index] = 1;
  }
  for (let index = 0; index < cells; index += 1) if (scrubOsm[index] && !blocked[index] && !grovesCells[index]) scrubCells[index] = 1;
  // Connected groves, so a grove too small for the lattice still gets its tree.
  const label = new Int32Array(cells).fill(-1);
  const groves = [];
  for (let start = 0; start < cells; start += 1) {
    if (!grovesCells[start] || label[start] >= 0) continue;
    const id = groves.length;
    const stack = [start];
    const members = [];
    label[start] = id;
    while (stack.length > 0) {
      const index = stack.pop();
      members.push(index);
      const i = index % grid.width;
      const j = (index - i) / grid.width;
      for (let dj = -1; dj <= 1; dj += 1) for (let di = -1; di <= 1; di += 1) {
        const x = i + di;
        const y = j + dj;
        if (x < 0 || y < 0 || x >= grid.width || y >= grid.height) continue;
        const next = y * grid.width + x;
        if (grovesCells[next] && label[next] < 0) {
          label[next] = id;
          stack.push(next);
        }
      }
    }
    members.sort((l, r) => l - r);
    let peak = members[0];
    for (const index of members) if (depth[index] > depth[peak]) peak = index;
    groves.push({ id, members, peak, trees: 0 });
  }

  // --- Trees.
  const zoneOf = (east, north, elevation, normal, inWood, shoreDistance) => {
    const x = east;
    const z = -north;
    if (inWood) return "se_wood";
    if (elevation > 66) return "summit";
    if (x < 230 || (normal && normal[0] < -0.3 && x < 420)) return "west_bluffs";
    if (elevation < 9 && shoreDistance <= 45 && z < 1250) return "cove_shore";
    if (normal && normal[2] < -0.15 && z < 1450) return elevation > 35 ? "cove_upper" : "cove_lower";
    return "default";
  };
  const zones = new Map(veg.zones.map((zone) => [zone.id, zone.mix]));
  // A tree takes the roll of the nearest patch seed (seeds jittered on a lattice), so
  // species stand in patches of a few to a few dozen trees rather than salt and pepper;
  // a quarter of the trees roll on their own. Rolls are uniform, so the mixes hold.
  const patchRoll = (east, north) => {
    const size = veg.species_noise_scale_m;
    const ci = Math.floor(east / size);
    const cj = Math.floor(north / size);
    let best = Infinity;
    let roll = 0;
    for (let di = -1; di <= 1; di += 1) for (let dj = -1; dj <= 1; dj += 1) {
      const si = ci + di;
      const sj = cj + dj;
      const seedEast = (si + hash32(si, sj, 61)) * size;
      const seedNorth = (sj + hash32(si, sj, 62)) * size;
      const distance = Math.hypot(east - seedEast, north - seedNorth);
      if (distance < best) {
        best = distance;
        roll = hash32(si, sj, 63);
      }
    }
    return hash32(east, north, 64) < 0.25 ? hash32(east, north, 65) : roll;
  };
  const pickSpecies = (zone, east, north) => {
    const mix = zones.get(zone);
    const names = Object.keys(mix).sort();
    const total = names.reduce((sum, name) => sum + mix[name], 0);
    let r = patchRoll(east, north) * total;
    for (const name of names) {
      r -= mix[name];
      if (r <= 0) return name;
    }
    return names.at(-1);
  };
  const coast = ringSegments(land).filter(([a, b]) => distanceToMultiPolygon([(a[0] + b[0]) / 2, (a[1] + b[1]) / 2], boundary) > 0.002);
  const shoreDistanceAt = (east, north) => {
    let best = Infinity;
    for (const [a, b] of coast) best = Math.min(best, distanceToSegment([east, north], a, b));
    return best;
  };
  const instances = [];
  let deckCapped = 0;
  let deckSkipped = 0;
  const placeTree = (speciesName, east, north, edgeFactor, seed, tallness = 1) => {
    const species = veg.species[speciesName];
    const variant = species.variants[Math.floor(hash32(east, north, seed, 11) * species.variants.length)];
    // From the edge's scale at a grove's rim to the full scale inside it, taller where the
    // canopy stands tall, lower on the upper slopes.
    const low = species.edge_scale[0] + (species.scale[0] - species.edge_scale[0]) * edgeFactor;
    const high = species.edge_scale[1] + (species.scale[1] - species.edge_scale[1]) * edgeFactor;
    let scale = (low + (high - low) * hash32(east, north, seed, 13)) * (veg.tallness_scale[0] + (veg.tallness_scale[1] - veg.tallness_scale[0]) * tallness);
    // Height over width: the blue gums' tall, narrow, streaky crowns.
    const stretchRange = species.stretch ?? [1, 1];
    const stretch = stretchRange[0] + (stretchRange[1] - stretchRange[0]) * hash32(east, north, seed, 19);
    const yaw = (hash32(east, north, seed, 17) * 2 - 1) * Math.PI;
    // The foot rests at the lowest drawn ground within a metre round it.
    let foot = Infinity;
    for (const [de, dn] of [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1], [0.7, 0.7], [-0.7, 0.7], [0.7, -0.7], [-0.7, -0.7]]) {
      const value = groundAt(east + de, north + dn);
      if (value != null) foot = Math.min(foot, value);
    }
    if (!Number.isFinite(foot)) return false;
    // Ground falling more than 1.2 m within a metre of the trunk is a cut or a cliff: no tree.
    const center = groundAt(east, north);
    if (center == null || center - foot > 1.2) return false;
    if (center > veg.upper_slope_m && speciesName !== "garden_tree") scale *= veg.upper_slope_factor;
    // Under a bridge deck the crown stays below it (the deck's reach: the crown's half width).
    const index = cellOf(east, north);
    if (index >= 0 && deckNear[index]) {
      const nominal = veg.prop_heights_m[species.prop][variant] * Math.sqrt(stretch);
      invariant(nominal > 0, `${species.prop} variant ${variant} has no nominal height`);
      const allowed = (track.deck_clear_top_m - foot) / nominal;
      if (allowed < scale) {
        if (allowed < 0.5) {
          deckSkipped += 1;
          return false;
        }
        scale = allowed;
        deckCapped += 1;
      }
    }
    instances.push({ prop: species.prop, variant, x: east, y: foot - 0.05, z: -north, yaw, scale, stretch, species: speciesName });
    return true;
  };
  const cellOf = (east, north) => {
    const i = Math.floor((east - grid.x0) / grid.cell);
    const j = Math.floor((-north - grid.z0) / grid.cell);
    return i < 0 || j < 0 || i >= grid.width || j >= grid.height ? -1 : j * grid.width + i;
  };
  // Grove fill: a jittered lattice at the tree spacing over the tall canopy, thinned by
  // gap noise so groves open in clearings, the tallest where the shadows run deepest.
  const spacing = veg.tree_spacing_m;
  const landBounds = multiPolygonBounds(land);
  const lattice = (step, seed, visit) => {
    for (let east = Math.floor(landBounds.min_x / step) * step; east <= landBounds.max_x; east += step) {
      for (let north = Math.floor(landBounds.min_y / step) * step; north <= landBounds.max_y; north += step) {
        const row = Math.round(north / step);
        const e = east + (hash32(east, north, seed, 3) - 0.5) * step * 0.8 + (row % 2) * step * 0.5;
        const n = north + (hash32(east, north, seed, 4) - 0.5) * step * 0.8;
        visit(e, n);
      }
    }
  };
  const zoneAt = (east, north, index) => {
    const elevation = groundAt(east, north);
    if (elevation == null) return null;
    return zoneOf(east, north, elevation, terrain.normalAtTriangle(east, north), woodOsm[index] === 1, shoreDistanceAt(east, north));
  };
  // A grove's rim stands lower than its heart, except where the shadows say the whole
  // stand is tall: a narrow band of blue gums along a road is all rim, and full height.
  const groveEdge = (index) => Math.max(Math.min(1, depth[index] / veg.edge_depth_m), smoothstep(veg.tall_band[0], veg.tall_band[1], tall[index]));
  lattice(spacing, 1, (east, north) => {
    const index = cellOf(east, north);
    if (index < 0 || !grovesCells[index]) return;
    if (fractalNoise(east, north, veg.gap_noise_scale_m, 29) < veg.gap_noise_cut && canopy[index] < 0.8) return;
    const zone = zoneAt(east, north, index);
    if (zone == null) return;
    if (placeTree(pickSpecies(zone, east, north), east, north, groveEdge(index), 1, tall[index])) groves[label[index]].trees += 1;
  });
  // A grove the lattice missed keeps one tree at its heart.
  for (const grove of groves) {
    if (grove.trees > 0) continue;
    const i = grove.peak % grid.width;
    const j = (grove.peak - i) / grid.width;
    const east = grid.centerX(i);
    const north = -grid.centerZ(j);
    const zone = zoneAt(east, north, grove.peak);
    if (zone != null) placeTree(pickSpecies(zone, east, north), east, north, groveEdge(grove.peak), 2, tall[grove.peak]);
  }
  // Understorey: smaller dense trees between the groves' trunks, thickest at a grove's
  // edge, where the trunks would otherwise stand bare against the light.
  const understorey = veg.understorey;
  lattice(understorey.spacing_m, 5, (east, north) => {
    const index = cellOf(east, north);
    if (index < 0 || !grovesCells[index]) return;
    if (depth[index] > understorey.edge_m && hash32(east, north, 31) > understorey.inner_share) return;
    const names = Object.keys(understorey.mix).sort();
    let r = hash32(east, north, 32) * names.reduce((sum, name) => sum + understorey.mix[name], 0);
    let name = names.at(-1);
    for (const candidate of names) {
      r -= understorey.mix[candidate];
      if (r <= 0) {
        name = candidate;
        break;
      }
    }
    placeTree(name, east, north, 1, 6);
  });
  // Small trees scattered where the canopy stands middling: wind-shaped oaks, acacia and
  // young trees among the scrub.
  const small = veg.small_trees;
  lattice(small.spacing_m, 7, (east, north) => {
    const index = cellOf(east, north);
    if (index < 0 || !smallCells[index] || hash32(east, north, 41) > small.share) return;
    const names = Object.keys(small.mix).sort();
    let r = hash32(east, north, 42) * names.reduce((sum, name) => sum + small.mix[name], 0);
    let name = names.at(-1);
    for (const candidate of names) {
      r -= small.mix[candidate];
      if (r <= 0) {
        name = candidate;
        break;
      }
    }
    placeTree(name, east, north, Math.min(1, depth[index] / veg.edge_depth_m), 8, tall[index]);
  });
  // OSM's mapped trees (data, not hand-placed) and its tree row.
  for (const source of rawSources.values()) {
    const tags = source.metadata.tags;
    if (tags.natural !== "tree" && tags.natural !== "tree_row") continue;
    for (const geometry of source.features) {
      const points = geometry.type === "Point"
        ? [projectLonLat(geometry.coordinates)]
        : geometry.type === "LineString"
          ? (() => {
            const line = geometryToLine(geometry, source.source_key);
            const out = [];
            for (let k = 1; k < line.length; k += 1) {
              const length = Math.hypot(line[k][0] - line[k - 1][0], line[k][1] - line[k - 1][1]);
              const steps = Math.max(1, Math.round(length / 7));
              for (let s = k === 1 ? 0 : 1; s <= steps; s += 1) out.push([line[k - 1][0] + ((line[k][0] - line[k - 1][0]) * s) / steps, line[k - 1][1] + ((line[k][1] - line[k - 1][1]) * s) / steps]);
            }
            return out;
          })()
          : [];
      for (const [east, north] of points) {
        const index = cellOf(east, north);
        if (index < 0 || blocked[index] || !pointInMultiPolygon([east, north], land, false)) continue;
        placeTree("garden_tree", east, north, 1, 3);
      }
    }
  }
  // Scrub: the kit's mounded shrubs over the low canopy, close-set where Treasure Island
  // sees them closely; further off, sparser and larger clumps (coyote brush mounds), so
  // the scrub slopes keep their broken texture from Treasure Island's shore.
  const nearLimit = veg.near_limit_m;
  const distanceToPlayable = (east, north) => distanceToMultiPolygon([east, north], playableBoundary);
  const scrubLattice = (spacingM, share, scaleRange, near) => {
    for (let east = Math.floor(landBounds.min_x / spacingM) * spacingM; east <= landBounds.max_x; east += spacingM) {
      for (let north = Math.floor(landBounds.min_y / spacingM) * spacingM; north <= landBounds.max_y; north += spacingM) {
        const e = east + (hash32(east, north, 21) - 0.5) * spacingM * 0.9;
        const n = north + (hash32(east, north, 22) - 0.5) * spacingM * 0.9;
        const index = cellOf(e, n);
        if (index < 0 || !scrubCells[index] || hash32(e, n, 23) > share) continue;
        if ((distanceToPlayable(e, n) <= nearLimit) !== near) continue;
        const choice = veg.species.scrub.props[Math.floor(hash32(e, n, 24) * veg.species.scrub.props.length)];
        const variant = choice[1][Math.floor(hash32(e, n, 25) * choice[1].length)];
        let ground = Infinity;
        for (const [de, dn] of [[0, 0], [0.6, 0], [-0.6, 0], [0, 0.6], [0, -0.6]]) {
          const value = groundAt(e + de, n + dn);
          if (value != null) ground = Math.min(ground, value);
        }
        const middle = groundAt(e, n);
        if (!Number.isFinite(ground) || middle == null || middle - ground > 1.0) continue;
        instances.push({ prop: choice[0], variant, x: e, y: ground - 0.05, z: -n, yaw: (hash32(e, n, 26) * 2 - 1) * Math.PI, scale: scaleRange[0] + (scaleRange[1] - scaleRange[0]) * hash32(e, n, 27), stretch: 1, species: "scrub" });
      }
    }
  };
  scrubLattice(veg.shrub_spacing_m, veg.shrub_share, veg.species.scrub.scale, true);
  scrubLattice(veg.far_scrub.spacing_m, veg.far_scrub.share, veg.far_scrub.scale, false);
  instances.sort((l, r) => compareCodePoints(l.prop, r.prop) || l.variant - r.variant || l.x - r.x || l.z - r.z);
  const speciesCounts = {};
  for (const item of instances) speciesCounts[item.species] = (speciesCounts[item.species] ?? 0) + 1;
  const vegetation = {
    schema_version: YBI_VEGETATION_SCHEMA,
    near_limit_m: nearLimit,
    fields: ["prop", "variant", "x", "y", "z", "yaw_radians", "scale", "stretch", "near"],
    props: [...new Set(instances.map((item) => item.prop))].sort(compareCodePoints),
    instances: [],
    counts: { total: instances.length, species: Object.fromEntries(Object.entries(speciesCounts).sort(([l], [r]) => compareCodePoints(l, r))) },
  };
  // Each species' tone at a distance (the impostors' tint, YBI only).
  vegetation.tints = vegetation.props.map((prop) => {
    const tint = veg.tints[prop];
    invariant(Array.isArray(tint) && tint.length === 3, `No YBI tint for ${prop}`);
    return tint;
  });
  for (const item of instances) {
    const { scale, stretch } = YBI_VEGETATION_LIMITS;
    invariant(round3(item.scale) >= scale[0] && round3(item.scale) <= scale[1] && round3(item.stretch) >= stretch[0] && round3(item.stretch) <= stretch[1],
      `A YBI ${item.species} at ${round2(item.x)}, ${round2(-item.z)} has scale ${round3(item.scale)} or stretch ${round3(item.stretch)} outside the drawn range`);
    const near = distanceToPlayable(item.x, -item.z) <= nearLimit ? 1 : 0;
    vegetation.instances.push([vegetation.props.indexOf(item.prop), item.variant, round2(item.x), round2(item.y), round2(item.z), round3(item.yaw), round3(item.scale), round3(item.stretch), near]);
  }
  vegetation.counts.near = vegetation.instances.filter((row) => row[8] === 1).length;

  // --- Ground cover: dark vegetation, green, bare and rock over the default dry straw.
  const rgba = new Uint8Array(cells * 4);
  const shoreRock = config.ground.shore_rock_m;
  const treeFloor = new Uint8Array(cells);
  for (const item of instances) {
    if (item.species === "scrub") continue;
    const index = cellOf(item.x, -item.z);
    if (index >= 0) treeFloor[index] = 1;
  }
  const floorNear = dilate(grid, treeFloor, 7);
  for (let index = 0; index < cells; index += 1) {
    if (!landMask[index]) continue;
    const i = index % grid.width;
    const j = (index - i) / grid.width;
    const east = grid.centerX(i);
    const north = -grid.centerZ(j);
    const normal = terrain.normalAtTriangle(east, north) ?? [0, 1, 0];
    const slope = Math.sqrt(Math.max(0, 1 - normal[1] * normal[1])) / Math.max(0.05, normal[1]);
    const noise = fractalNoise(east, north, 9, 41);
    let dark = 0;
    let green = Math.min(1, at("green", index) * 1.3);
    let bare = Math.min(1, at("bare", index));
    let rock = 0;
    if (grovesCells[index] || floorNear[index]) dark = Math.max(dark, Math.min(1, 0.55 + canopy[index] * 0.6));
    if (scrubCells[index] || smallCells[index]) dark = Math.max(dark, 0.8 * Math.min(1, canopy[index] * 1.6));
    else if (scrubOsm[index]) dark = Math.max(dark, 0.45 + 0.3 * noise);
    if (lawnOsm[index]) green = Math.max(green, 0.75);
    if (beachOsm[index]) bare = Math.max(bare, 0.9);
    if (rockOsm[index] || cliffMask[index]) rock = Math.max(rock, 0.85);
    // Steep cuts: rock where steepest, bare soil on the steep slopes round them.
    if (!grovesCells[index]) {
      rock = Math.max(rock, smoothstep(config.ground.steep_rock_slope * 1.8, config.ground.steep_rock_slope * 2.6, slope));
      bare = Math.max(bare, 0.8 * smoothstep(config.ground.steep_bare_slope * 1.6, config.ground.steep_bare_slope * 2.4, slope) * (0.6 + 0.4 * noise));
    }
    // The shore: dark wave-washed rock and riprap along the water where no beach is
    // mapped, the aerial's pale strip there being wet rock and foam, not sand.
    if (!beachOsm[index]) {
      const shore = shoreDistanceAt(east, north);
      if (shore < shoreRock * 2) rock = Math.max(rock, 1 - smoothstep(shoreRock * (0.6 + 0.6 * noise), shoreRock * 2, shore));
      if (shore < shoreRock * 3) bare *= smoothstep(shoreRock, shoreRock * 3, shore);
    }
    // Roadsides: graded verges along the drawn surfaces.
    if (pavedMargin[index] && !paved[index]) bare = Math.max(bare, 0.35 + 0.3 * noise);
    // The bridge track's at-grade cut: bare graded ground, for the bridge owner's road.
    if (bridgeMask[index]) {
      bare = Math.max(bare, 0.75);
      green *= 0.3;
      dark *= 0.2;
    }
    const total = dark + green + bare + rock;
    const scale = total > 1 ? 1 / total : 1;
    rgba[index * 4] = Math.round(dark * scale * 255);
    rgba[index * 4 + 1] = Math.round(green * scale * 255);
    rgba[index * 4 + 2] = Math.round(bare * scale * 255);
    rgba[index * 4 + 3] = Math.round(rock * scale * 255);
  }
  const groundCover = {
    schema_version: YBI_GROUND_COVER_SCHEMA,
    origin_xz: [...YBI_LAND_COVER_GRID.origin_xz],
    cell_m: YBI_LAND_COVER_GRID.cell_m,
    width: grid.width,
    height: grid.height,
    channels: [...YBI_GROUND_COVER_CHANNELS],
    rgba_zlib_base64: deflateSync(Buffer.from(rgba), { level: 9 }).toString("base64"),
  };

  // The terrain record: top and sides.
  const terrainMesh = {
    vertices: [...terrain.top.vertices, ...terrain.sides.vertices],
    normals: [...terrain.top.normals, ...terrain.sides.normals],
    uvs: [...terrain.top.uvs, ...terrain.sides.uvs],
    indices: [...terrain.top.indices, ...terrain.sides.indices.map((index) => index + terrain.top.vertices.length / 3)],
  };
  return {
    terrainMesh,
    records,
    boundaryVisuals,
    vegetation,
    groundCover,
    objects,
    report: {
      terrain: terrain.stats,
      buildings: buildingReport.length,
      surfaces: surfaceReport,
      continuation_visuals: boundaryVisuals.length,
      canopy_cells: { grove: grovesCells.reduce((a, b) => a + b, 0), small: smallCells.reduce((a, b) => a + b, 0), scrub: scrubCells.reduce((a, b) => a + b, 0), groves: groves.length },
      vegetation: vegetation.counts,
      deck: { capped: deckCapped, skipped: deckSkipped },
      structures: structureReport,
      walls: { sources: wallReport.length, face_m2: round2(wallReport.reduce((sum, item) => sum + item.face_m2, 0)) },
    },
    buildingReport,
  };
}

function ROAD_CONTINUATION_WIDTH(object, config) {
  const width = config.surfaces.road_widths_m[object.tags.highway];
  invariant(width > 0, `${object.row.source_key} highway=${object.tags.highway} has no YBI continuation width`);
  return width;
}
