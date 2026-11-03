// Terrain overrides: local, data-driven corrections of the generated land where
// the frozen USGS surface predates what was built (tools/config/terrain-overrides.json).
//
// The island's land is a 32 m grid of triangles sampled from the 2023 USGS raster
// (griddedTerrainSurfaceMesh). A site lists a scope (OSM areas plus traced
// polygons, minus protected way corridors and traced polygons, inside the land)
// and ordered regions, each a shape with a rule:
//   level    a flat elevation (a lawn, a pad)
//   profile  control elevations along a line (a promenade)
//   sink     lowered by depth_m with a side_run_m rim (basins, swales, forebays)
// The site's grade is the smoothest surface (a harmonic membrane on a grid_m grid)
// that takes the generated land's height B everywhere outside the scope and the
// level and profile targets inside their shapes: the 32 m grid's waves across the
// scope smooth out and the designed surfaces meet the surroundings in gentle
// ramps. Sinks are cut into that grade. The correction D = F (grade - sinks - B)
// fades to exactly zero over edge_blend_m at the scope's edge (F), so the land
// outside the scope and on the coastline keeps its generated surface.
//
// Every 32 m cell touching a scope is re-meshed as a quadtree of square leaves
// (down to min_leaf_m) split until each leaf's two triangles stay within
// tolerance_m of the corrected surface. Leaves keep the coarse cells' SW-NE
// diagonal; where a smaller neighbour puts a vertex on a leaf edge, the leaf's
// triangle is fanned through it, and coarse neighbour cells get the same vertices
// on their shared edges (where D is zero, so their surface is unchanged): the
// land stays watertight. Heights are production inference, not survey data.

import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import {
  differenceMultiPolygons,
  intersectMultiPolygons,
  lineRibbon,
  multiPolygonArea,
  multiPolygonBounds,
  pointInMultiPolygon,
  rawWayLine,
  rectangleMultiPolygon,
  signedRingArea,
  unionMultiPolygons,
} from "./osm-geometry.mjs";
import { terrainSurfaceMesh, validateMesh } from "./mesh-output.mjs";
import { invariant, roundCoordinate, sha256File } from "./world-contract.mjs";

export const TERRAIN_OVERRIDES_SCHEMA = "ti.terrain-overrides/1";
export const TERRAIN_OVERRIDES_PATH = "tools/config/terrain-overrides.json";

const RULE_KINDS = Object.freeze(["level", "profile", "sink"]);
const SAFE_ID = /^[a-z0-9_]+$/u;
// Central-difference steps for shading normals (m): the raster's, as the coarse
// land (mesh-output.mjs terrainNormal), and the correction's.
const RASTER_NORMAL_STEP_M = 2;
const DELTA_NORMAL_STEP_M = 0.5;
const MM = 1000;

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

function isXZ(value) {
  return Array.isArray(value) && value.length === 2 && value.every(isFiniteNumber);
}

function exactKeys(value, keys, label) {
  invariant(value != null && typeof value === "object" && !Array.isArray(value), `${label} must be an object`);
  invariant(JSON.stringify(Object.keys(value).sort()) === JSON.stringify([...keys].sort()), `${label} must have exactly ${[...keys].sort().join(", ")}`);
}

function smoothstep(edge0, edge1, value) {
  if (value <= edge0) return 0;
  if (value >= edge1) return 1;
  const t = (value - edge0) / (edge1 - edge0);
  return t * t * (3 - 2 * t);
}

// ---------------------------------------------------------------- config

function validateShape(shape, label) {
  invariant(shape != null && typeof shape === "object", `${label} needs a shape`);
  if (shape.points_xz) {
    exactKeys(shape, Object.keys(shape).includes("buffer_m") ? ["buffer_m", "points_xz"] : ["points_xz"], `${label} polygon shape`);
    invariant(Array.isArray(shape.points_xz) && shape.points_xz.length >= 3 && shape.points_xz.every(isXZ), `${label} polygon needs 3+ [x, z] points`);
    if ("buffer_m" in shape) invariant(isFiniteNumber(shape.buffer_m), `${label} buffer_m must be a number`);
  } else if (shape.line_xz) {
    exactKeys(shape, ["line_xz", "width_m"], `${label} line shape`);
    invariant(Array.isArray(shape.line_xz) && shape.line_xz.length >= 2 && shape.line_xz.every(isXZ), `${label} line needs 2+ [x, z] points`);
    invariant(isFiniteNumber(shape.width_m) && shape.width_m > 0, `${label} line needs a positive width_m`);
  } else if (shape.center_xz) {
    exactKeys(shape, ["center_xz", "radii_m", "rotation_deg"], `${label} ellipse shape`);
    invariant(isXZ(shape.center_xz) && isXZ(shape.radii_m) && shape.radii_m.every((radius) => radius > 0) && isFiniteNumber(shape.rotation_deg), `${label} ellipse needs center_xz, positive radii_m and rotation_deg`);
  } else {
    throw new Error(`${label} shape must be points_xz, line_xz or center_xz`);
  }
}

function validateRule(rule, shape, label) {
  invariant(rule != null && RULE_KINDS.includes(rule.kind), `${label} rule kind must be ${RULE_KINDS.join(", ")}`);
  if (rule.kind === "level") {
    exactKeys(rule, ["elevation_m", "kind"], `${label} level rule`);
    invariant(isFiniteNumber(rule.elevation_m), `${label} level needs elevation_m`);
  } else if (rule.kind === "profile") {
    exactKeys(rule, ["elevations_m", "kind"], `${label} profile rule`);
    invariant(shape.line_xz, `${label} profile needs a line shape`);
    invariant(Array.isArray(rule.elevations_m) && rule.elevations_m.length === shape.line_xz.length && rule.elevations_m.every(isFiniteNumber), `${label} profile needs one elevation per line point`);
  } else {
    exactKeys(rule, ["depth_m", "kind", "side_run_m"], `${label} sink rule`);
    invariant(isFiniteNumber(rule.depth_m) && rule.depth_m > 0 && isFiniteNumber(rule.side_run_m) && rule.side_run_m > 0, `${label} sink needs positive depth_m and side_run_m`);
    // The stock player walks floors up to 48 degrees; keep basin sides well under it.
    invariant(Math.atan2(rule.depth_m * 1.5, rule.side_run_m) <= (35 * Math.PI) / 180, `${label} sink side is steeper than 35 degrees at its steepest`);
  }
}

export function loadTerrainOverrides(projectRoot) {
  const path = resolve(projectRoot, TERRAIN_OVERRIDES_PATH);
  const config = JSON.parse(readFileSync(path, "utf8"));
  invariant(config.schema_version === TERRAIN_OVERRIDES_SCHEMA, "Terrain overrides schema drift");
  exactKeys(config, ["mesh", "notes", "schema_version", "sites"], "Terrain overrides config");
  invariant(Array.isArray(config.notes) && config.notes.every((note) => typeof note === "string"), "Terrain overrides notes must be strings");
  exactKeys(config.mesh, ["min_leaf_m", "sample_m", "tolerance_m"], "Terrain overrides mesh");
  const { min_leaf_m: minLeaf, sample_m: sample, tolerance_m: tolerance } = config.mesh;
  invariant([1, 2, 4, 8].includes(minLeaf), "Terrain overrides min_leaf_m must be 1, 2, 4 or 8");
  invariant([0.25, 0.5, 1].includes(sample) && sample <= minLeaf, "Terrain overrides sample_m must be 0.25, 0.5 or 1 and at most min_leaf_m");
  invariant(isFiniteNumber(tolerance) && tolerance > 0.001 && tolerance <= 0.2, "Terrain overrides tolerance_m must be in (0.001, 0.2]");
  invariant(Array.isArray(config.sites), "Terrain override sites must be a list");
  const siteIds = new Set();
  for (const site of config.sites) {
    const label = `Terrain override site ${site?.id}`;
    exactKeys(site, ["basis", "evidence", "grade", "id", "name", "regions", "scope"], label);
    exactKeys(site.grade, ["grid_m", "iterations", "relaxation"], `${label} grade`);
    invariant([0.5, 1, 2].includes(site.grade.grid_m), `${label} grade grid_m must be 0.5, 1 or 2`);
    invariant(Number.isInteger(site.grade.iterations) && site.grade.iterations >= 100 && site.grade.iterations <= 20000, `${label} grade iterations must be an integer in [100, 20000]`);
    invariant(isFiniteNumber(site.grade.relaxation) && site.grade.relaxation >= 1 && site.grade.relaxation < 2, `${label} grade relaxation must be in [1, 2)`);
    invariant(typeof site.id === "string" && SAFE_ID.test(site.id) && !siteIds.has(site.id), `${label} needs a unique lower_snake id`);
    siteIds.add(site.id);
    invariant(site.basis === "production_inference", `${label} basis must be production_inference`);
    for (const field of ["name", "evidence"]) invariant(typeof site[field] === "string" && site[field].trim() !== "", `${label} needs ${field}`);
    exactKeys(site.scope, ["add_xz", "edge_blend_m", "exclude_ways", "exclude_xz", "source_keys"], `${label} scope`);
    invariant(Array.isArray(site.scope.source_keys) && site.scope.source_keys.every((key) => /^[wr]\d+$/u.test(key)), `${label} scope source_keys must be OSM area keys`);
    invariant(Array.isArray(site.scope.add_xz) && site.scope.add_xz.every((ring) => Array.isArray(ring) && ring.length >= 3 && ring.every(isXZ)), `${label} scope add_xz must be polygons of [x, z] points`);
    invariant(site.scope.source_keys.length + site.scope.add_xz.length > 0, `${label} scope is empty`);
    invariant(Array.isArray(site.scope.exclude_xz) && site.scope.exclude_xz.every((entry) => {
      exactKeys(entry, ["points_xz", "reason"], `${label} exclude_xz entry`);
      return Array.isArray(entry.points_xz) && entry.points_xz.length >= 3 && entry.points_xz.every(isXZ) && typeof entry.reason === "string" && entry.reason.trim() !== "";
    }), `${label} exclude_xz must be polygons of [x, z] points with a reason`);
    invariant(isFiniteNumber(site.scope.edge_blend_m) && site.scope.edge_blend_m > 0, `${label} scope needs a positive edge_blend_m`);
    invariant(Array.isArray(site.scope.exclude_ways), `${label} exclude_ways must be a list`);
    for (const corridor of site.scope.exclude_ways) {
      exactKeys(corridor, ["half_width_m", "reason", "source_keys"], `${label} exclude_ways entry`);
      invariant(Array.isArray(corridor.source_keys) && corridor.source_keys.length > 0 && corridor.source_keys.every((key) => /^w\d+$/u.test(key)), `${label} exclude_ways needs OSM way keys`);
      invariant(isFiniteNumber(corridor.half_width_m) && corridor.half_width_m > 0 && typeof corridor.reason === "string" && corridor.reason.trim() !== "", `${label} exclude_ways needs half_width_m and a reason`);
    }
    invariant(Array.isArray(site.regions) && site.regions.length > 0, `${label} needs regions`);
    const regionIds = new Set();
    for (const region of site.regions) {
      const regionLabel = `${label} region ${region?.id}`;
      exactKeys(region, Object.keys(region).includes("min_leaf_m") ? ["id", "min_leaf_m", "reason", "rule", "shape"] : ["id", "reason", "rule", "shape"], regionLabel);
      if ("min_leaf_m" in region) invariant([1, 2, 4, 8].includes(region.min_leaf_m) && region.min_leaf_m >= sample, `${regionLabel} min_leaf_m must be 1, 2, 4 or 8 and at least sample_m`);
      invariant(typeof region.id === "string" && SAFE_ID.test(region.id) && !regionIds.has(region.id), `${regionLabel} needs a unique lower_snake id`);
      regionIds.add(region.id);
      invariant(typeof region.reason === "string" && region.reason.trim() !== "", `${regionLabel} needs a reason`);
      validateShape(region.shape, regionLabel);
      validateRule(region.rule, region.shape, regionLabel);
    }
  }
  return { config, descriptor: { path: TERRAIN_OVERRIDES_PATH, sha256: sha256File(path) } };
}

// ---------------------------------------------------------------- geometry

function segmentDistance(point, a, b) {
  const dx = b[0] - a[0];
  const dy = b[1] - a[1];
  const lengthSquared = dx * dx + dy * dy;
  const t = lengthSquared === 0 ? 0 : Math.max(0, Math.min(1, ((point[0] - a[0]) * dx + (point[1] - a[1]) * dy) / lengthSquared));
  return { distance: Math.hypot(point[0] - a[0] - t * dx, point[1] - a[1] - t * dy), t };
}

// Boundary edges of a multipolygon with a bounding box, for distance queries.
function edgeIndex(multiPolygon) {
  const edges = [];
  for (const polygon of multiPolygon) {
    for (const ring of polygon) {
      for (let index = 0; index < ring.length; index += 1) edges.push([ring[index], ring[(index + 1) % ring.length]]);
    }
  }
  return edges;
}

function distanceToEdges(point, edges) {
  let minimum = Infinity;
  for (const [a, b] of edges) minimum = Math.min(minimum, segmentDistance(point, a, b).distance);
  return minimum;
}

// Signed distance (negative inside) of a region shape, east/north frame.
function shapeField(shape) {
  if (shape.points_xz) {
    let ring = shape.points_xz.map(([x, z]) => [x, -z]);
    if (signedRingArea(ring) < 0) ring = ring.reverse();
    const geometry = [[ring]];
    const edges = edgeIndex(geometry);
    const buffer = shape.buffer_m ?? 0;
    const bounds = multiPolygonBounds(geometry);
    return {
      signed: (point) => (pointInMultiPolygon(point, geometry, true) ? -1 : 1) * distanceToEdges(point, edges) - buffer,
      bounds: { min_x: bounds.min_x - buffer, min_y: bounds.min_y - buffer, max_x: bounds.max_x + buffer, max_y: bounds.max_y + buffer },
    };
  }
  if (shape.line_xz) {
    const line = shape.line_xz.map(([x, z]) => [x, -z]);
    const half = shape.width_m / 2;
    const xs = line.map((point) => point[0]);
    const ys = line.map((point) => point[1]);
    return {
      signed: (point) => {
        let best = Infinity;
        for (let index = 1; index < line.length; index += 1) best = Math.min(best, segmentDistance(point, line[index - 1], line[index]).distance);
        return best - half;
      },
      bounds: { min_x: Math.min(...xs) - half, min_y: Math.min(...ys) - half, max_x: Math.max(...xs) + half, max_y: Math.max(...ys) + half },
      line,
    };
  }
  const [cx, cz] = shape.center_xz;
  const center = [cx, -cz];
  const [a, b] = shape.radii_m;
  // World yaw turns +X toward +Z; in the east/north frame that is clockwise.
  const angle = (-shape.rotation_deg * Math.PI) / 180;
  const cos = Math.cos(angle);
  const sin = Math.sin(angle);
  const reach = Math.max(a, b);
  return {
    signed: (point) => {
      const dx = point[0] - center[0];
      const dy = point[1] - center[1];
      const u = dx * cos + dy * sin;
      const v = -dx * sin + dy * cos;
      const radial = Math.hypot(u / a, v / b);
      // Scaled radial distance: exact on the axes, close enough between them.
      return (radial - 1) * Math.min(a, b);
    },
    bounds: { min_x: center[0] - reach, min_y: center[1] - reach, max_x: center[0] + reach, max_y: center[1] + reach },
  };
}

// The arc-length position of the closest point on a line and its interpolated control value.
function profileAt(line, values, point) {
  let best = null;
  let walked = 0;
  for (let index = 1; index < line.length; index += 1) {
    const length = Math.hypot(line[index][0] - line[index - 1][0], line[index][1] - line[index - 1][1]);
    const near = segmentDistance(point, line[index - 1], line[index]);
    if (!best || near.distance < best.distance) {
      best = { distance: near.distance, value: values[index - 1] + (values[index] - values[index - 1]) * near.t };
    }
    walked += length;
  }
  return best.value;
}

// The site's grade: on a grid_m grid over the scope, nodes outside the scope
// hold B (the generated land) and nodes inside a level or profile shape hold its
// target (the last such region in order wins); every other node on land relaxes
// to the average of its neighbours (successive over-relaxation, a fixed number
// of sweeps in a fixed order, so the result is deterministic). Scope nodes off
// the land are left out, so the grade runs on level to the coastline, where the
// shoreline's rock slope (built after the land) starts from it. Bilinear lookups.
function harmonicGrade(grade, scope, land, regions, baseAt) {
  const step = grade.grid_m;
  const box = scope.bounds;
  const x0 = Math.floor(box.min_x / step) * step - 2 * step;
  const y0 = Math.floor(box.min_y / step) * step - 2 * step;
  const width = Math.ceil((box.max_x - x0) / step) + 3;
  const height = Math.ceil((box.max_y - y0) / step) + 3;
  const values = new Float64Array(width * height).fill(Number.NaN);
  // 0: outside the scope, 1: in the scope on land, 2: in the scope off the land.
  const kind = new Uint8Array(width * height);
  for (let j = 0; j < height; j += 1) {
    for (let i = 0; i < width; i += 1) {
      const point = [x0 + i * step, y0 + j * step];
      if (!pointInMultiPolygon(point, scope.fadeGeometry, true)) continue;
      kind[j * width + i] = pointInMultiPolygon(point, land, true) ? 1 : 2;
    }
  }
  const free = [];
  const constraints = regions.filter((region) => region.rule.kind !== "sink");
  for (let j = 0; j < height; j += 1) {
    for (let i = 0; i < width; i += 1) {
      const point = [x0 + i * step, y0 + j * step];
      const index = j * width + i;
      if (kind[index] === 2) continue;
      if (kind[index] === 0) {
        // Outside nodes within two steps of the scope's land hold B: the membrane's edge.
        let near = false;
        for (let dj = -2; dj <= 2 && !near; dj += 1) {
          for (let di = -2; di <= 2 && !near; di += 1) {
            const ii = i + di;
            const jj = j + dj;
            if (ii >= 0 && jj >= 0 && ii < width && jj < height && kind[jj * width + ii] === 1) near = true;
          }
        }
        if (near) values[index] = baseAt(point);
        continue;
      }
      let target = null;
      for (const region of constraints) {
        const bounds = region.field.bounds;
        if (point[0] < bounds.min_x || point[0] > bounds.max_x || point[1] < bounds.min_y || point[1] > bounds.max_y) continue;
        if (region.field.signed(point) > 0) continue;
        target = region.rule.kind === "level" ? region.rule.elevation_m : profileAt(region.field.line, region.rule.elevations_m, point);
      }
      if (target !== null) {
        values[index] = target;
        continue;
      }
      values[index] = baseAt(point);
      // The grid's outer ring always lies outside the scope, so a free node has four neighbours.
      free.push(index);
    }
  }
  const omega = grade.relaxation;
  const neighbours = [-1, 1, -width, width];
  let lastChange = 0;
  for (let sweep = 0; sweep < grade.iterations; sweep += 1) {
    lastChange = 0;
    for (const index of free) {
      let sum = 0;
      let count = 0;
      for (const offset of neighbours) {
        const value = values[index + offset];
        if (Number.isFinite(value)) {
          sum += value;
          count += 1;
        }
      }
      const change = omega * (sum / count - values[index]);
      values[index] += change;
      lastChange = Math.max(lastChange, Math.abs(change));
    }
  }
  return {
    free_nodes: free.length,
    final_sweep_change_m: lastChange,
    // Off the land the nearest valued node stands in (the mesh never shows it).
    at: (point) => {
      const fi = (point[0] - x0) / step;
      const fj = (point[1] - y0) / step;
      const i = Math.min(width - 2, Math.max(0, Math.floor(fi)));
      const j = Math.min(height - 2, Math.max(0, Math.floor(fj)));
      const u = Math.max(0, Math.min(1, fi - i));
      const v = Math.max(0, Math.min(1, fj - j));
      let sum = 0;
      let weight = 0;
      for (const [di, dj, w] of [[0, 0, (1 - u) * (1 - v)], [1, 0, u * (1 - v)], [0, 1, (1 - u) * v], [1, 1, u * v]]) {
        const value = values[(j + dj) * width + i + di];
        if (Number.isFinite(value) && w > 0) {
          sum += value * w;
          weight += w;
        }
      }
      if (weight > 0) return sum / weight;
      for (let ring = 1; ring <= 40; ring += 1) {
        for (let dj = -ring; dj <= ring; dj += 1) {
          for (let di = -ring; di <= ring; di += 1) {
            if (Math.max(Math.abs(di), Math.abs(dj)) !== ring) continue;
            const ii = Math.min(width - 1, Math.max(0, i + di));
            const jj = Math.min(height - 1, Math.max(0, j + dj));
            const value = values[jj * width + ii];
            if (Number.isFinite(value)) return value;
          }
        }
      }
      throw new Error(`Terrain override grade has no value near ${point}`);
    },
  };
}

// ---------------------------------------------------------------- plan

// Builds the site fields, the refined cells' quadtree leaves and their vertex
// heights. cellPolygon(west, south) must return the exact rounded land polygon
// the generator meshes for that cell (empty when the cell has no land), and
// sampler(east, north) the generator's terrain sampler.
export function planTerrainOverrides({ loaded, playableObjects, rawOsm, boundary, sampler, cellSizeM, cellPolygon }) {
  const { config, descriptor } = loaded;
  const { min_leaf_m: minLeaf, sample_m: sampleM, tolerance_m: tolerance } = config.mesh;
  const cellKey = (west, south) => `${west},${south}`;

  // The coarse land of any cell, as generated (its original triangles), for the
  // surface B the corrections start from.
  const coarseCells = new Map();
  const coarseCell = (west, south) => {
    const key = cellKey(west, south);
    if (!coarseCells.has(key)) {
      const polygon = cellPolygon(west, south);
      if (polygon.length === 0 || multiPolygonArea(polygon) <= 1e-8) {
        coarseCells.set(key, null);
      } else {
        const coarse = terrainSurfaceMesh(polygon, sampler, `terrain override ${key} coarse`);
        const triangles = [];
        for (let offset = 0; offset < coarse.indices.length; offset += 3) {
          triangles.push([0, 1, 2].map((corner) => {
            const index = coarse.indices[offset + corner] * 3;
            return [coarse.vertices[index], -coarse.vertices[index + 2], coarse.vertices[index + 1]];
          }));
        }
        coarseCells.set(key, {
          key, west, south, polygon, coarse, triangles,
          full: Math.abs(multiPolygonArea(polygon) - cellSizeM * cellSizeM) <= 1e-6,
        });
      }
    }
    return coarseCells.get(key);
  };
  // B inside a cell's land (barycentric), extrapolated from its nearest triangle off it.
  const coarseAt = (cell, point) => {
    let best = null;
    for (const [a, b, c] of cell.triangles) {
      const denominator = (b[1] - c[1]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[1] - c[1]);
      if (Math.abs(denominator) <= 1e-12) continue;
      const wa = ((b[1] - c[1]) * (point[0] - c[0]) + (c[0] - b[0]) * (point[1] - c[1])) / denominator;
      const wb = ((c[1] - a[1]) * (point[0] - c[0]) + (a[0] - c[0]) * (point[1] - c[1])) / denominator;
      const wc = 1 - wa - wb;
      const violation = Math.max(0, -wa, -wb, -wc);
      if (!best || violation < best.violation) best = { violation, value: wa * a[2] + wb * b[2] + wc * c[2] };
      if (violation === 0) break;
    }
    return best.value;
  };
  // B anywhere: from the point's own cell, else (open water) a neighbouring land cell's.
  const baseAnywhere = (point) => {
    const west = Math.floor(point[0] / cellSizeM) * cellSizeM;
    const south = Math.floor(point[1] / cellSizeM) * cellSizeM;
    for (const [dx, dy] of [[0, 0], [-1, 0], [1, 0], [0, -1], [0, 1], [-1, -1], [1, -1], [-1, 1], [1, 1]]) {
      const cell = coarseCell(west + dx * cellSizeM, south + dy * cellSizeM);
      if (cell) return coarseAt(cell, point);
    }
    throw new Error(`Terrain overrides find no land near ${point}`);
  };

  const sites = config.sites.map((site) => {
    const parts = [
      ...site.scope.source_keys.map((key) => {
        const object = playableObjects.get(key);
        invariant(object && object.roles.includes("major_area"), `Terrain override scope ${key} is not an OSM area`);
        return object.geometry;
      }),
      ...site.scope.add_xz.map((ring) => {
        let points = ring.map(([x, z]) => [x, -z]);
        if (signedRingArea(points) < 0) points = points.reverse();
        return [[points]];
      }),
    ];
    const corridors = [
      ...site.scope.exclude_ways.flatMap((corridor) => corridor.source_keys.map((key) =>
        lineRibbon(rawWayLine(rawOsm, key.slice(1)), corridor.half_width_m * 2, `terrain override ${site.id} corridor ${key}`))),
      ...site.scope.exclude_xz.map((entry) => {
        let points = entry.points_xz.map(([x, z]) => [x, -z]);
        if (signedRingArea(points) < 0) points = points.reverse();
        return [[points]];
      }),
    ];
    // The correction fades out at the scope's edges but not at the coastline:
    // there the grade runs on to the shore, where the rock slope starts from it.
    const fadeGeometry = differenceMultiPolygons(unionMultiPolygons(...parts), ...corridors);
    const geometry = intersectMultiPolygons(fadeGeometry, boundary);
    invariant(geometry.length > 0 && multiPolygonArea(geometry) > 1, `Terrain override site ${site.id} scope is empty`);
    const scope = { geometry, fadeGeometry, edges: edgeIndex(fadeGeometry), bounds: multiPolygonBounds(geometry) };
    const regions = site.regions.map((region) => ({ id: region.id, rule: region.rule, field: shapeField(region.shape), minLeaf: region.min_leaf_m ?? null }));
    const grade = harmonicGrade(site.grade, scope, boundary, regions, baseAnywhere);
    return { id: site.id, name: site.name, edgeBlend: site.scope.edge_blend_m, scope, regions, grade, area_m2: multiPolygonArea(geometry) };
  });

  // The site correction at a point, given the coarse surface there.
  const siteDelta = (site, point, base) => {
    const box = site.scope.bounds;
    if (point[0] < box.min_x || point[0] > box.max_x || point[1] < box.min_y || point[1] > box.max_y) return 0;
    if (!pointInMultiPolygon(point, site.scope.fadeGeometry, true)) return 0;
    const fade = smoothstep(0, site.edgeBlend, distanceToEdges(point, site.scope.edges));
    if (fade === 0) return 0;
    let surface = site.grade.at(point);
    for (const region of site.regions) {
      if (region.rule.kind !== "sink") continue;
      const bounds = region.field.bounds;
      if (point[0] < bounds.min_x || point[0] > bounds.max_x || point[1] < bounds.min_y || point[1] > bounds.max_y) continue;
      const signed = region.field.signed(point);
      if (signed < 0) surface -= region.rule.depth_m * smoothstep(0, region.rule.side_run_m, -signed);
    }
    return fade * (surface - base);
  };
  const siteBoxes = sites.map((site) => site.scope.bounds);

  // Refined cells: every cell touching a scope that has land.
  const refined = new Map();
  for (const site of sites) {
    const box = site.scope.bounds;
    for (let west = Math.floor(box.min_x / cellSizeM) * cellSizeM; west < box.max_x; west += cellSizeM) {
      for (let south = Math.floor(box.min_y / cellSizeM) * cellSizeM; south < box.max_y; south += cellSizeM) {
        const key = cellKey(west, south);
        if (refined.has(key)) continue;
        const rect = rectangleMultiPolygon(west, south, west + cellSizeM, south + cellSizeM);
        const touched = intersectMultiPolygons(rect, site.scope.geometry);
        if (touched.length === 0 || multiPolygonArea(touched) <= 1e-6) continue;
        const cell = coarseCell(west, south);
        if (cell) refined.set(key, cell);
      }
    }
  }
  invariant(refined.size > 0, "Terrain overrides refine no land cell");
  const cellAt = (point) => {
    const west = Math.floor(point[0] / cellSizeM) * cellSizeM;
    const south = Math.floor(point[1] / cellSizeM) * cellSizeM;
    return refined.get(cellKey(west, south)) ?? null;
  };
  const deltaAt = (point, base) => {
    let delta = 0;
    sites.forEach((site, index) => {
      const box = siteBoxes[index];
      if (point[0] >= box.min_x && point[0] <= box.max_x && point[1] >= box.min_y && point[1] <= box.max_y) delta += siteDelta(site, point, base);
    });
    return delta;
  };

  // Heights of mesh vertices, by millimetre position, computed once so every
  // cell and coarse neighbour that shares a vertex uses the same value.
  const heights = new Map();
  const vertexKey = (point) => `${Math.round(point[0] * MM)},${Math.round(point[1] * MM)}`;
  const heightAt = (point, cell = cellAt(point)) => {
    const key = vertexKey(point);
    if (heights.has(key)) return heights.get(key);
    invariant(cell, `Terrain override height at ${point} is outside the refined cells`);
    const base = coarseAt(cell, point);
    const value = roundCoordinate(base + deltaAt(point, base));
    heights.set(key, value);
    return value;
  };
  // Unrounded surface for refinement tests.
  const surfaceAt = (cell, point) => {
    const base = coarseAt(cell, point);
    return base + deltaAt(point, base);
  };

  // ---- quadtree leaves per refined cell
  const steps = Math.round(cellSizeM / sampleM);
  const audit = { leaves: 0, cells: refined.size, maximum_raise_m: 0, maximum_cut_m: 0, sampled_points: 0 };
  for (const cell of refined.values()) {
    // Surface samples on the cell's grid (rows south to north).
    const samples = new Float64Array((steps + 1) * (steps + 1));
    const inside = new Uint8Array((steps + 1) * (steps + 1));
    let largest = 0;
    for (let j = 0; j <= steps; j += 1) {
      for (let i = 0; i <= steps; i += 1) {
        const point = [cell.west + i * sampleM, cell.south + j * sampleM];
        const base = coarseAt(cell, point);
        const delta = deltaAt(point, base);
        samples[j * (steps + 1) + i] = base + delta;
        inside[j * (steps + 1) + i] = cell.full || pointInMultiPolygon(point, cell.polygon, true) ? 1 : 0;
        largest = Math.max(largest, Math.abs(delta));
        if (inside[j * (steps + 1) + i]) {
          audit.maximum_raise_m = Math.max(audit.maximum_raise_m, delta);
          audit.maximum_cut_m = Math.max(audit.maximum_cut_m, -delta);
        }
      }
    }
    audit.sampled_points += samples.length;
    // A cell the correction never reaches keeps its coarse triangles.
    cell.mode = largest > 0 ? "leaves" : "coarse";
    if (cell.mode === "coarse") {
      cell.leaves = [];
      continue;
    }
    const sampleIndex = (x, y) => Math.round((y - cell.south) / sampleM) * (steps + 1) + Math.round((x - cell.west) / sampleM);
    // Largest gap between the samples inside a node and its two SW-NE triangles.
    const nodeError = (x0, y0, size) => {
      const n = Math.round(size / sampleM);
      const sw = samples[sampleIndex(x0, y0)];
      const se = samples[sampleIndex(x0 + size, y0)];
      const ne = samples[sampleIndex(x0 + size, y0 + size)];
      const nw = samples[sampleIndex(x0, y0 + size)];
      let error = 0;
      for (let j = 0; j <= n; j += 1) {
        for (let i = 0; i <= n; i += 1) {
          const index = sampleIndex(x0 + i * sampleM, y0 + j * sampleM);
          if (!inside[index]) continue;
          const u = i / n;
          const v = j / n;
          const plane = u >= v ? sw + u * (se - sw) + v * (ne - se) : sw + v * (nw - sw) + u * (ne - nw);
          error = Math.max(error, Math.abs(samples[index] - plane));
        }
      }
      return error;
    };
    // Regions that ask for finer leaves than the mesh's (a small forebay) lower the limit where they reach.
    const fine = sites.flatMap((site) => site.regions.filter((region) => region.minLeaf !== null && region.minLeaf < minLeaf));
    const leafLimit = (x0, y0, size) => {
      let limit = minLeaf;
      for (const region of fine) {
        const b = region.field.bounds;
        if (x0 + size < b.min_x || x0 > b.max_x || y0 + size < b.min_y || y0 > b.max_y) continue;
        limit = Math.min(limit, region.minLeaf);
      }
      return limit;
    };
    const leaves = [];
    const stack = [[cell.west, cell.south, cellSizeM]];
    while (stack.length > 0) {
      const [x0, y0, size] = stack.pop();
      if (size > leafLimit(x0, y0, size) && nodeError(x0, y0, size) > tolerance) {
        const half = size / 2;
        stack.push([x0, y0, half], [x0 + half, y0, half], [x0, y0 + half, half], [x0 + half, y0 + half, half]);
      } else {
        leaves.push({ x0, y0, size });
      }
    }
    leaves.sort((left, right) => left.y0 - right.y0 || left.x0 - right.x0);
    cell.leaves = leaves;
    audit.leaves += leaves.length;
  }

  // ---- vertices on grid lines (leaf corners, and coast points where leaves
  // are clipped), for T-junction-free edges.
  const lineX = new Map();
  const lineY = new Map();
  const addLinePoint = (point) => {
    const xm = Math.round(point[0] * MM);
    const ym = Math.round(point[1] * MM);
    if (!lineX.has(xm)) lineX.set(xm, new Set());
    lineX.get(xm).add(ym);
    if (!lineY.has(ym)) lineY.set(ym, new Set());
    lineY.get(ym).add(xm);
  };
  // Leaf polygons (clipped to the land for partial cells).
  for (const cell of refined.values()) {
    cell.leafPolygons = [];
    if (cell.mode !== "leaves") continue;
    for (const leaf of cell.leaves) {
      const square = rectangleMultiPolygon(leaf.x0, leaf.y0, leaf.x0 + leaf.size, leaf.y0 + leaf.size);
      let polygons;
      if (cell.full) {
        polygons = square;
      } else {
        const clipped = intersectMultiPolygons(square, cell.polygon);
        if (clipped.length === 0 || multiPolygonArea(clipped) <= 1e-8) continue;
        polygons = clipped.map((polygon) => [polygon[0].map((point) => [roundCoordinate(point[0]), roundCoordinate(point[1])])]);
      }
      const whole = Math.abs(multiPolygonArea(polygons) - leaf.size * leaf.size) <= 1e-9;
      cell.leafPolygons.push({ leaf, polygons, whole });
      for (const polygon of polygons) for (const point of polygon[0]) addLinePoint(point);
    }
  }
  const sortedLine = (map) => new Map([...map.entries()].map(([key, set]) => [key, [...set].sort((left, right) => left - right)]));
  const linesX = sortedLine(lineX);
  const linesY = sortedLine(lineY);
  // Vertices strictly inside an axis-aligned segment, in order from a to b.
  const extrasBetween = (a, b) => {
    const ax = Math.round(a[0] * MM);
    const ay = Math.round(a[1] * MM);
    const bx = Math.round(b[0] * MM);
    const by = Math.round(b[1] * MM);
    let found = [];
    if (ax === bx && ay !== by) {
      const list = linesX.get(ax) ?? [];
      const low = Math.min(ay, by);
      const high = Math.max(ay, by);
      found = list.filter((value) => value > low && value < high).map((value) => [ax / MM, value / MM]);
      if (ay > by) found.reverse();
    } else if (ay === by && ax !== bx) {
      const list = linesY.get(ay) ?? [];
      const low = Math.min(ax, bx);
      const high = Math.max(ax, bx);
      found = list.filter((value) => value > low && value < high).map((value) => [value / MM, ay / MM]);
      if (ax > bx) found.reverse();
    }
    return found;
  };

  // ---- meshing helpers
  const rasterGradient = (point) => [
    (sampler(point[0] + RASTER_NORMAL_STEP_M, point[1]) - sampler(point[0] - RASTER_NORMAL_STEP_M, point[1])) / (2 * RASTER_NORMAL_STEP_M),
    (sampler(point[0], point[1] + RASTER_NORMAL_STEP_M) - sampler(point[0], point[1] - RASTER_NORMAL_STEP_M)) / (2 * RASTER_NORMAL_STEP_M),
  ];
  // Shading normal: the raster's gradient (as the coarse land's) blended into
  // the corrected surface's own where the correction applies.
  const normalAt = (point) => {
    const cell = cellAt(point);
    let [slopeEast, slopeNorth] = rasterGradient(point);
    if (cell) {
      const deltaOf = (p) => deltaAt(p, coarseAt(cell, p));
      const step = DELTA_NORMAL_STEP_M;
      slopeEast += (deltaOf([point[0] + step, point[1]]) - deltaOf([point[0] - step, point[1]])) / (2 * step);
      slopeNorth += (deltaOf([point[0], point[1] + step]) - deltaOf([point[0], point[1] - step])) / (2 * step);
    }
    const length = Math.hypot(slopeEast, 1, slopeNorth);
    return [-slopeEast / length, 1 / length, slopeNorth / length];
  };
  const newMesh = () => ({ vertices: [], normals: [], uvs: [], indices: [], index: new Map() });
  const vertexOf = (mesh, point, cell, normal = null) => {
    const key = vertexKey(point);
    if (mesh.index.has(key)) return mesh.index.get(key);
    const east = roundCoordinate(point[0]);
    const north = roundCoordinate(point[1]);
    const elevation = heightAt([east, north], cell);
    const n = normal ?? normalAt([east, north]);
    const index = mesh.vertices.length / 3;
    mesh.vertices.push(east, elevation, roundCoordinate(-north));
    mesh.normals.push(...n.map(roundCoordinate));
    mesh.uvs.push(roundCoordinate(east / 10), roundCoordinate(-north / 10));
    mesh.index.set(key, index);
    return index;
  };
  const pushTriangle = (mesh, a, b, c) => {
    const p = (index) => [mesh.vertices[index * 3], mesh.vertices[index * 3 + 1], mesh.vertices[index * 3 + 2]];
    const [pa, pb, pc] = [p(a), p(b), p(c)];
    const ab = [pb[0] - pa[0], pb[1] - pa[1], pb[2] - pa[2]];
    const ac = [pc[0] - pa[0], pc[1] - pa[1], pc[2] - pa[2]];
    const cross = [ab[1] * ac[2] - ab[2] * ac[1], ab[2] * ac[0] - ab[0] * ac[2], ab[0] * ac[1] - ab[1] * ac[0]];
    if (Math.hypot(...cross) / 2 <= 1e-8) return false;
    // Generated land faces up (+Y), as terrainSurfaceMesh emits it.
    if (cross[1] < 0) mesh.indices.push(a, c, b);
    else mesh.indices.push(a, b, c);
    return true;
  };
  // A triangle p0 p1 p2 whose edges p0->p1 and p1->p2 may carry extra vertices
  // (p2->p0 carries none): fanned so every extra vertex is used.
  const fanTriangle = (emit, p0, p1, p2, extras01, extras12) => {
    if (extras01.length === 0) {
      const chain = [p1, ...extras12, p2];
      for (let index = 1; index < chain.length; index += 1) emit(p0, chain[index - 1], chain[index]);
      return;
    }
    const chain = [p0, ...extras01, p1];
    for (let index = 1; index < chain.length - 1; index += 1) emit(p2, chain[index - 1], chain[index]);
    const last = extras01.at(-1);
    const tail = [p1, ...extras12, p2];
    for (let index = 1; index < tail.length; index += 1) emit(last, tail[index - 1], tail[index]);
  };
  // Ear clipping that keeps collinear vertices (earcut drops them), for small
  // convex-ish leaf polygons along the coast. Counter-clockwise ring in.
  const clipEars = (ring) => {
    const points = ring.slice();
    const triangles = [];
    const area2 = (a, b, c) => (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]);
    const contains = (a, b, c, p) => area2(a, b, p) >= -1e-12 && area2(b, c, p) >= -1e-12 && area2(c, a, p) >= -1e-12;
    let guard = points.length * points.length + 10;
    while (points.length > 3 && guard > 0) {
      guard -= 1;
      let clipped = false;
      for (let index = 0; index < points.length; index += 1) {
        const a = points[(index + points.length - 1) % points.length];
        const b = points[index];
        const c = points[(index + 1) % points.length];
        if (area2(a, b, c) <= 1e-9) continue;
        if (points.some((p) => p !== a && p !== b && p !== c && contains(a, b, c, p))) continue;
        triangles.push([a, b, c]);
        points.splice(index, 1);
        clipped = true;
        break;
      }
      if (!clipped) return null;
    }
    if (points.length === 3 && area2(points[0], points[1], points[2]) > 1e-9) triangles.push(points);
    return triangles;
  };

  // The refined mesh of one cell: its quadtree leaves, T-junction free.
  const refinedCellMesh = (cell, label) => {
    const mesh = newMesh();
    const emit = (a, b, c) => pushTriangle(mesh, vertexOf(mesh, a, cell), vertexOf(mesh, b, cell), vertexOf(mesh, c, cell));
    for (const { leaf, polygons, whole } of cell.leafPolygons) {
      const { x0, y0, size } = leaf;
      if (whole) {
        const sw = [x0, y0];
        const se = [x0 + size, y0];
        const ne = [x0 + size, y0 + size];
        const nw = [x0, y0 + size];
        fanTriangle(emit, sw, se, ne, extrasBetween(sw, se), extrasBetween(se, ne));
        fanTriangle(emit, ne, nw, sw, extrasBetween(ne, nw), extrasBetween(nw, sw));
        continue;
      }
      for (const polygon of polygons) {
        let ring = polygon[0];
        if (signedRingArea(ring) < 0) ring = ring.slice().reverse();
        const withExtras = [];
        for (let index = 0; index < ring.length; index += 1) {
          const a = ring[index];
          const b = ring[(index + 1) % ring.length];
          withExtras.push(a, ...extrasBetween(a, b));
        }
        // Millimetre rounding can merge neighbouring points; drop the repeats.
        const cleaned = withExtras.filter((point, index) => {
          const next = withExtras[(index + 1) % withExtras.length];
          return vertexKey(point) !== vertexKey(next);
        });
        const triangles = clipEars(cleaned);
        if (!triangles) {
          process.stderr.write(`DEBUG ring ${label} ${x0},${y0}: ${JSON.stringify(cleaned)}\n`);
        }
        invariant(triangles, `${label} could not triangulate a coastal leaf at ${x0},${y0}`);
        for (const [a, b, c] of triangles) emit(a, b, c);
      }
    }
    return finishMesh(mesh, cell.polygon, label);
  };
  const finishMesh = (mesh, polygon, label) => {
    const out = { vertices: mesh.vertices, normals: mesh.normals, uvs: mesh.uvs, indices: mesh.indices };
    validateMesh(out, label);
    let plan = 0;
    for (let offset = 0; offset < out.indices.length; offset += 3) {
      const [a, b, c] = [0, 1, 2].map((k) => out.indices[offset + k] * 3);
      plan += Math.abs((out.vertices[b] - out.vertices[a]) * (out.vertices[c + 2] - out.vertices[a + 2]) - (out.vertices[c] - out.vertices[a]) * (out.vertices[b + 2] - out.vertices[a + 2])) / 2;
    }
    const expected = multiPolygonArea(polygon);
    invariant(Math.abs(plan - expected) <= Math.max(0.05, expected * 1e-5), `${label} refined plan area ${plan} differs from the land's ${expected}`);
    return out;
  };

  // A coarse mesh (an unsplit refined cell, or a neighbour) with the extra
  // vertices that lie on its edges fanned in; its surface is unchanged.
  const splitCoarseMesh = (mesh, label) => {
    const point = (index) => [mesh.vertices[index * 3], -mesh.vertices[index * 3 + 2]];
    const out = newMesh();
    let inserted = 0;
    // Original vertices keep their exact values; inserted ones come from the shared heights.
    const original = (index) => {
      const p = point(index);
      const key = vertexKey(p);
      if (out.index.has(key)) return out.index.get(key);
      const at = out.vertices.length / 3;
      out.vertices.push(mesh.vertices[index * 3], mesh.vertices[index * 3 + 1], mesh.vertices[index * 3 + 2]);
      out.normals.push(mesh.normals[index * 3], mesh.normals[index * 3 + 1], mesh.normals[index * 3 + 2]);
      out.uvs.push(mesh.uvs[index * 2], mesh.uvs[index * 2 + 1]);
      out.index.set(key, at);
      return at;
    };
    const extraVertex = (p, a, b) => {
      const key = vertexKey(p);
      if (out.index.has(key)) return out.index.get(key);
      // On the coarse edge: its value comes from the shared heights when a refined
      // leaf owns it, else from the edge itself (the neighbour's flat side).
      let elevation = heights.get(key);
      if (elevation === undefined) {
        const t = Math.hypot(p[0] - a[0], p[1] - a[1]) / Math.hypot(b[0] - a[0], b[1] - a[1]);
        elevation = roundCoordinate(a[2] + (b[2] - a[2]) * t);
        heights.set(key, elevation);
      }
      const at = out.vertices.length / 3;
      out.vertices.push(roundCoordinate(p[0]), elevation, roundCoordinate(-p[1]));
      const [slopeEast, slopeNorth] = rasterGradient(p);
      const length = Math.hypot(slopeEast, 1, slopeNorth);
      out.normals.push(...[-slopeEast / length, 1 / length, slopeNorth / length].map(roundCoordinate));
      out.uvs.push(roundCoordinate(p[0] / 10), roundCoordinate(-p[1] / 10));
      out.index.set(key, at);
      inserted += 1;
      return at;
    };
    for (let offset = 0; offset < mesh.indices.length; offset += 3) {
      const corner = [0, 1, 2].map((k) => mesh.indices[offset + k]);
      const points = corner.map((index) => [...point(index), mesh.vertices[index * 3 + 1]]);
      const extras = [0, 1, 2].map((k) => extrasBetween(points[k], points[(k + 1) % 3]));
      if (extras.every((list) => list.length === 0)) {
        out.indices.push(...corner.map(original));
        continue;
      }
      // Rotate so the edge without extras is p2 -> p0.
      const free = [0, 1, 2].find((k) => extras[(k + 2) % 3].length === 0);
      invariant(free !== undefined, `${label} triangle has extra vertices on all three edges`);
      const order = [free, (free + 1) % 3, (free + 2) % 3];
      const [p0, p1, p2] = order.map((k) => points[k]);
      const e01 = extras[order[0]];
      const e12 = extras[order[1]];
      const handle = new Map(order.map((k) => [points[k], original(corner[k])]));
      const edgeOf = new Map([...e01.map((p) => [p, [p0, p1]]), ...e12.map((p) => [p, [p1, p2]])]);
      const indexOf = (p) => handle.get(p) ?? extraVertex(p, ...edgeOf.get(p));
      fanTriangle((a, b, c) => pushTriangle(out, indexOf(a), indexOf(b), indexOf(c)), p0, p1, p2, e01, e12);
    }
    return { mesh: { vertices: out.vertices, normals: out.normals, uvs: out.uvs, indices: out.indices }, inserted };
  };

  // Meshes for the generator's per-cell callback (griddedTerrainSurfaceMesh).
  let neighbourInserts = 0;
  let refinedTriangles = 0;
  const cellMesh = (west, south, clipped, coarse, label) => {
    const cell = refined.get(cellKey(west, south));
    if (cell) {
      invariant(JSON.stringify(clipped) === JSON.stringify(cell.polygon), `${label} land polygon differs from the terrain override plan`);
      const mesh = cell.mode === "leaves" ? refinedCellMesh(cell, label) : splitCoarseMesh(coarse, label).mesh;
      refinedTriangles += mesh.indices.length / 3;
      return mesh;
    }
    // A coarse neighbour: only edges shared with refined cells can carry extras.
    const near = [[-cellSizeM, 0], [cellSizeM, 0], [0, -cellSizeM], [0, cellSizeM]].some(([dx, dy]) => refined.get(cellKey(west + dx, south + dy))?.mode === "leaves");
    if (!near) return coarse;
    const result = splitCoarseMesh(coarse, label);
    neighbourInserts += result.inserted;
    return result.mesh;
  };

  // The corrected surface's shading normal, for surfaces draped over it.
  const smoothNormalAt = (east, north) => (cellAt([east, north]) ? normalAt([east, north]) : null);

  const document = () => ({
    schema_version: TERRAIN_OVERRIDES_SCHEMA,
    config: descriptor,
    basis: "production_inference",
    mesh: { cell_m: cellSizeM, min_leaf_m: minLeaf, sample_m: sampleM, tolerance_m: tolerance },
    sites: sites.map((site) => ({
      id: site.id,
      name: site.name,
      scope_area_m2: Math.round(site.area_m2 * 10) / 10,
      edge_blend_m: site.edgeBlend,
      grade: { kind: "harmonic", free_nodes: site.grade.free_nodes, final_sweep_change_m: Math.round(site.grade.final_sweep_change_m * 1e6) / 1e6 },
      regions: site.regions.map((region) => ({ id: region.id, rule: region.rule.kind })),
    })),
    refined_cells: refined.size,
    // World rectangles [min_x, min_z, max_x, max_z] of the re-meshed cells
    // (tools/validate_godot_world.mjs checks every other land vertex against the raster).
    refined_cell_bounds_m: [...refined.values()]
      .map((cell) => [cell.west, -(cell.south + cellSizeM), cell.west + cellSizeM, -cell.south])
      .sort((left, right) => left[1] - right[1] || left[0] - right[0]),
    corrected_cells: [...refined.values()].filter((cell) => cell.mode === "leaves").length,
    leaves: audit.leaves,
    refined_triangles: refinedTriangles,
    neighbour_edge_vertices: neighbourInserts,
    maximum_raise_m: roundCoordinate(audit.maximum_raise_m),
    maximum_cut_m: roundCoordinate(audit.maximum_cut_m),
  });

  return {
    cellMesh,
    document,
    smoothNormalAt,
    // The corrected land height at a point inside a refined cell (unrounded), or null.
    surfaceAt: (east, north) => {
      const cell = cellAt([east, north]);
      return cell ? surfaceAt(cell, [east, north]) : null;
    },
  };
}
