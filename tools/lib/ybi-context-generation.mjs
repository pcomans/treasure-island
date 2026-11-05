import {
  canonicalizeMultiPolygon,
  differenceMultiPolygons,
  intersectMultiPolygons,
  lineRibbon,
  multiPolygonArea,
  multiPolygonBounds,
  multiPolygonCentroid,
  rawWayFootprint,
  rawWayLine,
  unionMultiPolygons,
} from "./osm-geometry.mjs";
import {
  mergeMeshes,
  meshRecord,
  terrainSurfaceMesh,
  topSurfaceMesh,
  validateMesh,
  wallSurfaceMesh,
} from "./mesh-output.mjs";
import {
  BRIDGE_SOURCE_KEYS,
  ROAD_SURFACE_BIASES_M,
  ROAD_WIDTHS_M,
  YBI_SOURCE_KEY,
  invariant,
  roundCoordinate,
} from "./world-contract.mjs";

const CAUSEWAY_NORTHBOUND_WAY = "1115934722";
const CAUSEWAY_SOUTHBOUND_WAYS = ["1249797943", "513879523"];
const YBI_MAIN_TWO_WAY_NAMES = new Set([
  "Treasure Island Road",
  "Macalla Road",
  "Yerba Buena Road",
  "Hillcrest Road",
  "Signal Road",
]);
const YBI_TUNNEL_WAY_IDS = new Set(["11415208", "50691047"]);
const BRISTOL_WAY_ID = "813225688";
const SAS_TOWER_WAY_ID = "237735191";

function sub2(a, b) {
  return [a[0] - b[0], a[1] - b[1]];
}

function add2(a, b) {
  return [a[0] + b[0], a[1] + b[1]];
}

function scale2(a, s) {
  return [a[0] * s, a[1] * s];
}

function len2(a) {
  return Math.hypot(a[0], a[1]);
}

function unit2(a) {
  const l = len2(a);
  return l > 1e-9 ? [a[0] / l, a[1] / l] : [1, 0];
}

function left2(v) {
  return [-v[1], v[0]];
}

function polylineLength(line) {
  let total = 0;
  for (let i = 0; i < line.length - 1; i += 1) {
    total += len2(sub2(line[i + 1], line[i]));
  }
  return total;
}

function pointAlong(line, distanceM) {
  let remaining = Math.max(0, distanceM);
  for (let i = 0; i < line.length - 1; i += 1) {
    const start = line[i];
    const end = line[i + 1];
    const segLen = len2(sub2(end, start));
    if (segLen <= 1e-9) continue;
    if (remaining <= segLen || i === line.length - 2) {
      const t = Math.min(1, remaining / segLen);
      return {
        point: [start[0] + (end[0] - start[0]) * t, start[1] + (end[1] - start[1]) * t],
        tangent: unit2(sub2(end, start)),
      };
    }
    remaining -= segLen;
  }
  const tangent = unit2(sub2(line.at(-1), line.at(-2)));
  return { point: line.at(-1), tangent };
}

function offsetLineStrip(line, fromOffsetM, toOffsetM, label = "offset strip") {
  const midOffset = (fromOffsetM + toOffsetM) / 2;
  const width = Math.abs(toOffsetM - fromOffsetM);
  if (width <= 1e-4 || line.length < 2) return [];
  const shifted = line.map((pt, idx) => {
    let tangent;
    if (idx === 0) {
      tangent = unit2(sub2(line[1], line[0]));
    } else if (idx === line.length - 1) {
      tangent = unit2(sub2(line[idx], line[idx - 1]));
    } else {
      const t0 = unit2(sub2(line[idx], line[idx - 1]));
      const t1 = unit2(sub2(line[idx + 1], line[idx]));
      tangent = unit2(add2(t0, t1));
    }
    const normal = left2(tangent);
    return add2(pt, scale2(normal, midOffset));
  });
  try {
    return lineRibbon(shifted, width, label);
  } catch {
    return [];
  }
}

function dashRectanglesAlong(line, dashM, gapM, widthM, offsetM = 0) {
  const total = polylineLength(line);
  const parts = [];
  for (let s = gapM / 2; s + dashM <= total; s += dashM + gapM) {
    const sample = pointAlong(line, s + dashM / 2);
    const along = sample.tangent;
    const across = left2(along);
    const center = add2(sample.point, scale2(across, offsetM));
    const halfL = dashM / 2;
    const halfW = widthM / 2;
    const ring = [
      add2(center, add2(scale2(along, -halfL), scale2(across, -halfW))),
      add2(center, add2(scale2(along, halfL), scale2(across, -halfW))),
      add2(center, add2(scale2(along, halfL), scale2(across, halfW))),
      add2(center, add2(scale2(along, -halfL), scale2(across, halfW))),
    ];
    try {
      const poly = canonicalizeMultiPolygon([[ring]], { label: "dash", allowEmpty: true });
      if (poly.length > 0) parts.push(...poly);
    } catch {
      // Ignore degenerate dash
    }
  }
  return parts;
}

function drapeListOnYbiFacets(parts, facets, biasM, label, uvSampler = null) {
  const meshes = [];
  for (let i = 0; i < parts.length; i += 1) {
    try {
      const m = drapeOnYbiFacets(parts[i], facets, biasM, `${label}/${i}`, uvSampler);
      if (m && m.indices.length > 0) meshes.push(m);
    } catch {
      // Skip degenerate sliver
    }
  }
  if (meshes.length === 0) return null;
  return mergeMeshes(meshes, label);
}

function raisedKerbListMesh(parts, facets, topBiasM, bottomBiasM, terrainSampler, label) {
  const meshes = [];
  for (let i = 0; i < parts.length; i += 1) {
    try {
      const m = raisedKerbMesh(parts[i], facets, topBiasM, bottomBiasM, terrainSampler, `${label}/${i}`);
      if (m && m.indices.length > 0) meshes.push(m);
    } catch {
      // Skip degenerate sliver
    }
  }
  if (meshes.length === 0) return null;
  return mergeMeshes(meshes, label);
}

function drapeOnYbiFacets(multiPolygon, facets, biasM, label, uvSampler = null) {
  if (!multiPolygon || multiPolygon.length === 0) return null;
  const pieces = [];
  const box = multiPolygonBounds(multiPolygon);
  for (const facet of facets) {
    if (
      facet.bounds.max_x < box.min_x ||
      facet.bounds.min_x > box.max_x ||
      facet.bounds.max_y < box.min_y ||
      facet.bounds.min_y > box.max_y
    ) {
      continue;
    }
    let clipped;
    try {
      clipped = intersectMultiPolygons(multiPolygon, facet.geometry);
    } catch {
      continue;
    }
    if (clipped.length === 0 || multiPolygonArea(clipped) <= 1e-6) continue;
    const [a, b, c] = facet.vertices;
    const denom = (b.north - c.north) * (a.east - c.east) + (c.east - b.east) * (a.north - c.north);
    if (Math.abs(denom) <= 1e-10) continue;
    const sampler = (east, north) => {
      const wA = ((b.north - c.north) * (east - c.east) + (c.east - b.east) * (north - c.north)) / denom;
      const wB = ((c.north - a.north) * (east - c.east) + (a.east - c.east) * (north - c.north)) / denom;
      const wC = 1 - wA - wB;
      return wA * a.elevation + wB * b.elevation + wC * c.elevation + biasM;
    };
    const piece = terrainSurfaceMesh(clipped, sampler, `${label}/${facet.id}`, {
      allowEmpty: true,
      uvSampler,
    });
    if (piece.indices.length > 0) pieces.push(piece);
  }
  if (pieces.length === 0) return null;
  return mergeMeshes(pieces, label);
}

function extrudeWallMesh(geometry, baseElevationM, topElevationM, label) {
  return wallSurfaceMesh(
    {
      geometry,
      base_elevation_m: baseElevationM,
      top_elevation_m: topElevationM,
    },
    undefined,
    label,
  );
}

function pushOrientedTriangle(mesh, i0, i1, i2, desiredNormal) {
  const v0 = mesh.vertices.slice(i0 * 3, i0 * 3 + 3);
  const v1 = mesh.vertices.slice(i1 * 3, i1 * 3 + 3);
  const v2 = mesh.vertices.slice(i2 * 3, i2 * 3 + 3);
  const ab = [v1[0] - v0[0], v1[1] - v0[1], v1[2] - v0[2]];
  const ac = [v2[0] - v0[0], v2[1] - v0[1], v2[2] - v0[2]];
  const cx = ab[1] * ac[2] - ab[2] * ac[1];
  const cy = ab[2] * ac[0] - ab[0] * ac[2];
  const cz = ab[0] * ac[1] - ab[1] * ac[0];
  const area = Math.hypot(cx, cy, cz) / 2;
  if (area <= 1e-6) return;
  if (cx * desiredNormal[0] + cy * desiredNormal[1] + cz * desiredNormal[2] < 0) {
    mesh.indices.push(i0, i2, i1);
  } else {
    mesh.indices.push(i0, i1, i2);
  }
}

function raisedKerbMesh(multiPolygon, facets, topBiasM, bottomBiasM, terrainSampler, label) {
  const topMesh = drapeOnYbiFacets(multiPolygon, facets, topBiasM, `${label}/top`);
  if (!topMesh) return null;
  const sideMesh = { vertices: [], normals: [], uvs: [], indices: [] };
  for (const polygon of multiPolygon) {
    for (const ring of polygon) {
      for (let i = 0; i < ring.length; i += 1) {
        const start = ring[i];
        const end = ring[(i + 1) % ring.length];
        const segLen = len2(sub2(end, start));
        if (segLen <= 0.05) continue;
        const steps = Math.max(1, Math.ceil(segLen / 6));
        for (let step = 0; step < steps; step += 1) {
          const t0 = step / steps;
          const t1 = (step + 1) / steps;
          const p0 = [start[0] + (end[0] - start[0]) * t0, start[1] + (end[1] - start[1]) * t0];
          const p1 = [start[0] + (end[0] - start[0]) * t1, start[1] + (end[1] - start[1]) * t1];
          const h0 = terrainSampler(p0[0], p0[1]);
          const h1 = terrainSampler(p1[0], p1[1]);
          const dx = p1[0] - p0[0];
          const dy = p1[1] - p0[1];
          const l = Math.hypot(dx, dy);
          if (l <= 1e-4) continue;
          const normal = [roundCoordinate(dy / l), 0, roundCoordinate(dx / l)];
          const baseIdx = sideMesh.vertices.length / 3;
          const pts = [
            [roundCoordinate(p0[0]), roundCoordinate(h0 + bottomBiasM), roundCoordinate(-p0[1])],
            [roundCoordinate(p1[0]), roundCoordinate(h1 + bottomBiasM), roundCoordinate(-p1[1])],
            [roundCoordinate(p1[0]), roundCoordinate(h1 + topBiasM), roundCoordinate(-p1[1])],
            [roundCoordinate(p0[0]), roundCoordinate(h0 + topBiasM), roundCoordinate(-p0[1])],
          ];
          const uvs = [
            [0, 0],
            [roundCoordinate(l / 2), 0],
            [roundCoordinate(l / 2), roundCoordinate((topBiasM - bottomBiasM) / 2)],
            [0, roundCoordinate((topBiasM - bottomBiasM) / 2)],
          ];
          for (let k = 0; k < 4; k += 1) {
            sideMesh.vertices.push(...pts[k]);
            sideMesh.normals.push(...normal);
            sideMesh.uvs.push(...uvs[k]);
          }
          pushOrientedTriangle(sideMesh, baseIdx, baseIdx + 1, baseIdx + 2, normal);
          pushOrientedTriangle(sideMesh, baseIdx, baseIdx + 2, baseIdx + 3, normal);
        }
      }
    }
  }
  if (sideMesh.indices.length === 0) return topMesh;
  return mergeMeshes([topMesh, sideMesh], label);
}

function buildCausewayShorelineRiprapOnYbi(rawOsm, terrain) {
  // East causeway shore: w1222684021 (south of TI seam, north <= -932.6)
  // West causeway shore: w1222685424 (south of TI seam, north <= -954.0)
  const eastWay = rawWayLine(rawOsm, "1222684021");
  const westWay = rawWayLine(rawOsm, "1222685424");

  // Filter segments on YBI side of the boundary line:
  // Boundary line runs from [-34.566, -954.002] to [12.425, -932.607]
  const seamNorthAtEast = (east) => {
    const t = (east - -34.566) / (12.425 - -34.566);
    return -954.002 + t * (-932.607 - -954.002);
  };

  const slopeMesh = { vertices: [], normals: [], uvs: [], indices: [] };
  const boulderMesh = { vertices: [], normals: [], uvs: [], indices: [] };

  const pushQuad = (target, p00, p10, p11, p01, uv00, uv10, uv11, uv01) => {
    const ux = p10[0] - p00[0];
    const uy = p10[1] - p00[1];
    const uz = p10[2] - p00[2];
    const vx = p01[0] - p00[0];
    const vy = p01[1] - p00[1];
    const vz = p01[2] - p00[2];
    let nx = uy * vz - uz * vy;
    let ny = uz * vx - ux * vz;
    let nz = ux * vy - uy * vx;
    const nl = Math.hypot(nx, ny, nz);
    if (nl <= 1e-7) return;
    nx = roundCoordinate(nx / nl);
    ny = roundCoordinate(ny / nl);
    nz = roundCoordinate(nz / nl);
    const base = target.vertices.length / 3;
    for (const [pt, uv] of [
      [p00, uv00],
      [p10, uv10],
      [p11, uv11],
      [p01, uv01],
    ]) {
      target.vertices.push(roundCoordinate(pt[0]), roundCoordinate(pt[1]), roundCoordinate(pt[2]));
      target.normals.push(nx, ny, nz);
      target.uvs.push(roundCoordinate(uv[0]), roundCoordinate(uv[1]));
    }
    pushOrientedTriangle(target, base, base + 1, base + 2, [nx, ny, nz]);
    pushOrientedTriangle(target, base, base + 2, base + 3, [nx, ny, nz]);
  };

  const addBoulder = (center, rx, ry, rz, yaw, seed) => {
    const rings = 3;
    const sectors = 6;
    const cosY = Math.cos(yaw);
    const sinY = Math.sin(yaw);
    const rot = (x, y, z) => [
      center[0] + x * cosY - z * sinY,
      center[1] + y,
      center[2] + x * sinY + z * cosY,
    ];
    const grid = [];
    for (let r = 0; r <= rings; r += 1) {
      const v = r / rings;
      const phi = v * Math.PI;
      const row = [];
      for (let s = 0; s <= sectors; s += 1) {
        const u = s / sectors;
        const theta = u * Math.PI * 2;
        const hash = Math.sin((seed + r * 7 + (s % sectors) * 13) * 12.9898) * 43758.5453;
        const jitter = 0.84 + (hash - Math.floor(hash)) * 0.32;
        const lx = Math.sin(phi) * Math.cos(theta) * rx * jitter;
        const ly = Math.cos(phi) * ry * (r === rings ? 0.6 : jitter);
        const lz = Math.sin(phi) * Math.sin(theta) * rz * jitter;
        row.push({ pos: rot(lx, ly, lz), uv: [u * 1.5, v * 1.2] });
      }
      grid.push(row);
    }
    for (let r = 0; r < rings; r += 1) {
      for (let s = 0; s < sectors; s += 1) {
        const a = grid[r][s];
        const b = grid[r + 1][s];
        const c = grid[r + 1][s + 1];
        const d = grid[r][s + 1];
        if (r === 0) {
          pushQuad(boulderMesh, a.pos, b.pos, c.pos, a.pos, a.uv, b.uv, c.uv, a.uv);
        } else if (r === rings - 1) {
          pushQuad(boulderMesh, a.pos, b.pos, d.pos, a.pos, a.uv, b.uv, d.uv, a.uv);
        } else {
          pushQuad(boulderMesh, a.pos, b.pos, c.pos, d.pos, a.uv, b.uv, c.uv, d.uv);
        }
      }
    }
  };

  const buildShoreBank = (wayLinePts, outwardSign, minNorth, maxNorth) => {
    let sAlong = 0;
    for (let i = 0; i < wayLinePts.length - 1; i += 1) {
      const a = wayLinePts[i];
      const b = wayLinePts[i + 1];
      const segLen = len2(sub2(b, a));
      if (segLen <= 0.2) continue;
      const steps = Math.max(1, Math.ceil(segLen / 2.5));
      const tangent = unit2(sub2(b, a));
      const outward = scale2(left2(tangent), outwardSign);
      for (let st = 0; st < steps; st += 1) {
        const t0 = st / steps;
        const t1 = (st + 1) / steps;
        const p0 = [a[0] + (b[0] - a[0]) * t0, a[1] + (b[1] - a[1]) * t0];
        const p1 = [a[0] + (b[0] - a[0]) * t1, a[1] + (b[1] - a[1]) * t1];
        const mid = [(p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2];
        const seamN = seamNorthAtEast(mid[0]);
        if (mid[1] > seamN + 1.0 || mid[1] < minNorth || mid[1] > maxNorth) {
          sAlong += segLen / steps;
          continue;
        }
        const s0 = sAlong;
        const s1 = sAlong + segLen / steps;
        sAlong = s1;

        const h0 = Math.max(1.2, terrain.sampleTerrainEastNorth(p0[0] - outward[0] * 2.5, p0[1] - outward[1] * 2.5));
        const h1 = Math.max(1.2, terrain.sampleTerrainEastNorth(p1[0] - outward[0] * 2.5, p1[1] - outward[1] * 2.5));

        const profile = [
          { across: -2.2, y0: h0 + 0.06, y1: h1 + 0.06 },
          { across: -0.4, y0: h0 + 0.32, y1: h1 + 0.32 },
          { across: 1.8, y0: h0 * 0.58 + 0.25, y1: h1 * 0.58 + 0.25 },
          { across: 4.2, y0: 0.35, y1: 0.35 },
          { across: 6.4, y0: -0.65, y1: -0.65 },
        ];
        for (let k = 0; k < profile.length - 1; k += 1) {
          const r0 = profile[k];
          const r1 = profile[k + 1];
          const q00 = [p0[0] + outward[0] * r0.across, r0.y0, -(p0[1] + outward[1] * r0.across)];
          const q10 = [p1[0] + outward[0] * r0.across, r0.y1, -(p1[1] + outward[1] * r0.across)];
          const q11 = [p1[0] + outward[0] * r1.across, r1.y1, -(p1[1] + outward[1] * r1.across)];
          const q01 = [p0[0] + outward[0] * r1.across, r1.y0, -(p0[1] + outward[1] * r1.across)];
          if (outwardSign > 0) {
            pushQuad(slopeMesh, q00, q01, q11, q10, [s0, r0.across], [s0, r1.across], [s1, r1.across], [s1, r0.across]);
          } else {
            pushQuad(slopeMesh, q00, q10, q11, q01, [s0, r0.across], [s1, r0.across], [s1, r1.across], [s0, r1.across]);
          }
        }

        // Deterministic 3D quarry boulders along the crest, middle slope, and waterline toe
        const seedBase = Math.round(Math.abs(mid[0] * 19 + mid[1] * 37));
        const tiers = [
          { across: -0.2, y: (h0 + h1) * 0.5 + 0.28, size: 0.72 },
          { across: 1.3, y: (h0 + h1) * 0.38 + 0.22, size: 0.95 },
          { across: 2.9, y: (h0 + h1) * 0.18 + 0.15, size: 1.08 },
          { across: 4.5, y: 0.08, size: 0.88 },
        ];
        tiers.forEach((tier, tIdx) => {
          const seed = seedBase + tIdx * 31;
          const jitterAlong = ((seed % 17) / 17 - 0.5) * 1.4;
          const jitterAcross = (((seed * 7) % 19) / 19 - 0.5) * 0.65;
          const bx = mid[0] + tangent[0] * jitterAlong + outward[0] * (tier.across + jitterAcross);
          const by = mid[1] + tangent[1] * jitterAlong + outward[1] * (tier.across + jitterAcross);
          const rx = tier.size * (0.85 + ((seed % 11) / 11) * 0.35);
          const ry = tier.size * (0.62 + (((seed + 3) % 11) / 11) * 0.28);
          const rz = tier.size * (0.78 + (((seed + 5) % 11) / 11) * 0.35);
          const yaw = ((seed % 29) / 29) * Math.PI * 2;
          addBoulder([bx, tier.y, -by], rx, ry, rz, yaw, seed);
        });
      }
    }
  };

  // w1222684021 runs south-east along the east causeway shore; its left (+1) is east (bayward)
  buildShoreBank(eastWay, 1, -1068, -930);
  // w1222685424 runs south along the west causeway shore; its right (-1) is west (Clipper Cove)
  buildShoreBank(westWay, -1, -1142, -950);

  return { slopeMesh, boulderMesh };
}

function relationMultiPolygonPartsOnYbi(rawOsm, relationId, ybiGeometry) {
  const rel = rawOsm.relations.get(String(relationId));
  if (!rel) return [];
  const outers = [];
  const inners = [];
  for (const member of rel.members) {
    if (member.type !== "way") continue;
    const way = rawOsm.ways.get(String(member.ref));
    if (!way || way.node_refs.length < 4 || way.node_refs[0] !== way.node_refs.at(-1)) continue;
    try {
      const poly = canonicalizeMultiPolygon([[rawWayLine(rawOsm, member.ref)]], {
        label: `r${relationId}/w${member.ref}`,
        allowEmpty: true,
      });
      if (poly.length === 0) continue;
      if (member.role === "inner") inners.push(poly);
      else outers.push(poly);
    } catch {
      // Skip unclosed member rings
    }
  }
  const results = [];
  for (const outer of outers) {
    let cur = outer;
    for (const inner of inners) {
      try {
        cur = differenceMultiPolygons(cur, inner);
      } catch {
        // Keep outer if difference fails
      }
    }
    try {
      const clipped = intersectMultiPolygons(cur, ybiGeometry);
      if (clipped.length > 0) results.push(clipped);
    } catch {
      // Skip unclippable part
    }
  }
  return results;
}

function buildBristolMeshes(rawOsm, ybiGeometry, terrain) {
  const poly = intersectMultiPolygons(rawWayFootprint(rawOsm, BRISTOL_WAY_ID), ybiGeometry);
  invariant(poly.length > 0, "The Bristol (w813225688) footprint is missing on YBI");
  const samplePoints = [];
  for (const p of poly) {
    for (const ring of p) {
      for (const pt of ring) samplePoints.push(pt);
    }
  }
  const centroid = multiPolygonCentroid(poly);
  samplePoints.push(centroid);
  const heights = samplePoints.map(([e, n]) => terrain.sampleTerrainEastNorth(e, n));
  const minH = Math.min(...heights);
  const baseH = roundCoordinate(terrain.sampleTerrainEastNorth(centroid[0], centroid[1]));
  const foundationBottom = roundCoordinate(minH - 0.6);
  const podiumTop = roundCoordinate(baseH + 4.8);
  const mainTop = roundCoordinate(baseH + 18.6);

  // Podium base + recessed window/balcony core (warm stone/taupe building_wall)
  const podiumWall = extrudeWallMesh(poly, foundationBottom, podiumTop, "Bristol podium wall");
  const coreWall = extrudeWallMesh(poly, podiumTop, mainTop, "Bristol core wall");

  // Upper architectural facade & projecting floor slab/balcony bands (bright cream building_part_wall)
  const bandPieces = [];
  const floorHeights = [
    [podiumTop, roundCoordinate(podiumTop + 0.55)],
    [roundCoordinate(baseH + 8.0), roundCoordinate(baseH + 8.55)],
    [roundCoordinate(baseH + 11.4), roundCoordinate(baseH + 11.95)],
    [roundCoordinate(baseH + 14.8), roundCoordinate(baseH + 15.35)],
    [roundCoordinate(baseH + 17.8), mainTop],
  ];
  for (const [b0, b1] of floorHeights) {
    bandPieces.push(extrudeWallMesh(poly, b0, b1, `Bristol band ${b0}`));
  }

  // Rooftop parapet and stepped penthouse volume
  const bounds = multiPolygonBounds(poly);
  const insetX = (bounds.max_x - bounds.min_x) * 0.22;
  const insetY = (bounds.max_y - bounds.min_y) * 0.22;
  const penthouseBox = canonicalizeMultiPolygon(
    [
      [
        [
          [bounds.min_x + insetX, bounds.min_y + insetY],
          [bounds.max_x - insetX, bounds.min_y + insetY],
          [bounds.max_x - insetX, bounds.max_y - insetY],
          [bounds.min_x + insetX, bounds.max_y - insetY],
        ],
      ],
    ],
    { label: "Bristol penthouse box", allowEmpty: true },
  );
  const penthousePoly = intersectMultiPolygons(poly, penthouseBox);
  const penthouseTop = roundCoordinate(mainTop + 2.8);
  const roofPieces = [topSurfaceMesh(poly, mainTop, "Bristol main roof")];
  if (penthousePoly.length > 0 && multiPolygonArea(penthousePoly) > 12) {
    bandPieces.push(extrudeWallMesh(penthousePoly, mainTop, penthouseTop, "Bristol penthouse wall"));
    roofPieces.push(topSurfaceMesh(penthousePoly, penthouseTop, "Bristol penthouse roof"));
  }

  return {
    baseWallMesh: mergeMeshes([podiumWall, coreWall], "Bristol base and core"),
    upperWallMesh: mergeMeshes(bandPieces, "Bristol architectural facade"),
    roofMesh: mergeMeshes(roofPieces, "Bristol roof"),
  };
}

function buildYbiBuildingsMeshes(rawOsm, ybiGeometry, terrain) {
  const wallPieces = [];
  const roofPieces = [];
  for (const [id, way] of rawOsm.ways) {
    if (!way.tags.building) continue;
    if (id === BRISTOL_WAY_ID || id === SAS_TOWER_WAY_ID) continue;
    if (way.node_refs.length < 4 || way.node_refs[0] !== way.node_refs.at(-1)) continue;
    let footprint;
    try {
      footprint = intersectMultiPolygons(rawWayFootprint(rawOsm, id), ybiGeometry);
    } catch {
      continue;
    }
    if (footprint.length === 0 || multiPolygonArea(footprint) < 2) continue;

    const pts = [];
    for (const poly of footprint) {
      for (const ring of poly) {
        for (const pt of ring) pts.push(pt);
      }
    }
    const centroid = multiPolygonCentroid(footprint);
    pts.push(centroid);
    const elevations = pts.map(([e, n]) => terrain.sampleTerrainEastNorth(e, n));
    const minElev = Math.min(...elevations);
    const baseElev = roundCoordinate(terrain.sampleTerrainEastNorth(centroid[0], centroid[1]));
    const bottomElev = roundCoordinate(minElev - 0.5);

    let heightM = 7.5;
    if (way.tags.height) {
      const parsed = Number.parseFloat(way.tags.height);
      if (Number.isFinite(parsed) && parsed > 2) heightM = parsed;
    } else if (way.tags["building:levels"]) {
      const levels = Number.parseFloat(way.tags["building:levels"]);
      if (Number.isFinite(levels) && levels > 0) heightM = Math.max(4, levels * 3.2);
    } else if (way.tags.building === "apartments" || way.tags.building === "residential") {
      heightM = 10.5;
    } else if (way.tags.building === "industrial" || way.tags.building === "warehouse" || way.tags.building === "civic") {
      heightM = 9.5;
    }
    const topElev = roundCoordinate(baseElev + heightM);

    try {
      wallPieces.push(extrudeWallMesh(footprint, bottomElev, topElev, `YBI building w${id} wall`));
      roofPieces.push(topSurfaceMesh(footprint, topElev, `YBI building w${id} roof`));
    } catch {
      // Skip malformed footprint
    }
  }
  return {
    wallMesh: mergeMeshes(wallPieces, "YBI buildings wall"),
    roofMesh: mergeMeshes(roofPieces, "YBI buildings roof"),
  };
}

function buildEasternBayBridge3DMesh(rawOsm, westGeometry, eastMemberWayIds, boundary, terrain) {
  // Keep the flat western span surface (X < 250 m) so source area/contract stays satisfied
  // while runtime culls X < 250 m in favor of WesternBayBridgeModel.
  const westClipped = differenceMultiPolygons(westGeometry, boundary);
  const pieces = [topSurfaceMesh(westClipped, 12, "Western Span context placeholder")];

  // Elevation profile of the modern Eastern Span from YBI East Tunnel Portal (X ≈ 490 m, Y ≈ 48 m)
  // past the SAS Tower (X ≈ 1098.4 m, Y ≈ 43.5 m) down along the Skyway to Oakland (X ≈ 3888 m, Y ≈ 14 m).
  const deckElevationAt = (east) => {
    if (east <= 500) return 48.0;
    if (east <= 1100) {
      const t = (east - 500) / 600;
      return 48.0 + t * (43.5 - 48.0);
    }
    const t = Math.min(1, (east - 1100) / 2788);
    return 43.5 * (1 - t) + 14.0 * t;
  };

  const pushBoxSegment = (mesh, p0, p1, widthM, yBottom0, yTop0, yBottom1, yTop1) => {
    const dir = unit2(sub2(p1, p0));
    const n2 = left2(dir);
    const hw = widthM / 2;
    const p0L = add2(p0, scale2(n2, hw));
    const p0R = add2(p0, scale2(n2, -hw));
    const p1L = add2(p1, scale2(n2, hw));
    const p1R = add2(p1, scale2(n2, -hw));

    const v = (pt2, y) => [roundCoordinate(pt2[0]), roundCoordinate(y), roundCoordinate(-pt2[1])];
    const quad = (a, b, c, d, normal) => {
      const base = mesh.vertices.length / 3;
      const uLen = Math.hypot(b[0] - a[0], b[1] - a[1], b[2] - a[2]);
      const vLen = Math.hypot(d[0] - a[0], d[1] - a[1], d[2] - a[2]);
      if (uLen <= 1e-4 || vLen <= 1e-4) return;
      for (const [pt, uv] of [
        [a, [0, 0]],
        [b, [roundCoordinate(uLen / 10), 0]],
        [c, [roundCoordinate(uLen / 10), roundCoordinate(vLen / 10)]],
        [d, [0, roundCoordinate(vLen / 10)]],
      ]) {
        mesh.vertices.push(...pt);
        mesh.normals.push(...normal.map(roundCoordinate));
        mesh.uvs.push(...uv);
      }
      pushOrientedTriangle(mesh, base, base + 1, base + 2, normal);
      pushOrientedTriangle(mesh, base, base + 2, base + 3, normal);
    };

    // Top face (+Y)
    quad(v(p0L, yTop0), v(p0R, yTop0), v(p1R, yTop1), v(p1L, yTop1), [0, 1, 0]);
    // Bottom face (-Y)
    quad(v(p0R, yBottom0), v(p0L, yBottom0), v(p1L, yBottom1), v(p1R, yBottom1), [0, -1, 0]);
    // Left side (+n2)
    quad(v(p0L, yBottom0), v(p1L, yBottom1), v(p1L, yTop1), v(p0L, yTop0), [n2[0], 0, -n2[1]]);
    // Right side (-n2)
    quad(v(p1R, yBottom1), v(p0R, yBottom0), v(p0R, yTop0), v(p1R, yTop1), [-n2[0], 0, n2[1]]);
    // Start cap (-dir)
    quad(v(p0R, yBottom0), v(p0R, yTop0), v(p0L, yTop0), v(p0L, yBottom0), [-dir[0], 0, dir[1]]);
    // End cap (+dir)
    quad(v(p1L, yBottom1), v(p1L, yTop1), v(p1R, yTop1), v(p1R, yBottom1), [dir[0], 0, -dir[1]]);
  };

  const bridge3D = { vertices: [], normals: [], uvs: [], indices: [] };

  // 1. Twin box-girder decks + bike path from the actual OSM bridge ways on the Eastern Span
  const deckSpecByWay = [
    // Westbound deck ways (5 lanes)
    { id: "235850739", width: 23.0, thickness: 3.4 },
    { id: "430133642", width: 23.0, thickness: 3.4 },
    { id: "599155240", width: 23.0, thickness: 3.4 },
    { id: "235850741", width: 23.0, thickness: 3.4 },
    { id: "1112580172", width: 23.0, thickness: 3.4 },
    // Eastbound deck ways (5 lanes)
    { id: "50691046", width: 23.0, thickness: 3.4 },
    { id: "235850738", width: 23.0, thickness: 3.4 },
    { id: "430133640", width: 23.0, thickness: 3.4 },
    { id: "396200315", width: 23.0, thickness: 3.4 },
    { id: "1112580173", width: 23.0, thickness: 3.4 },
    // Shared-use bicycle/pedestrian path on south side of eastbound deck
    { id: "396200316", width: 5.2, thickness: 2.0 },
    { id: "430152840", width: 5.2, thickness: 2.0 },
    { id: "1112580170", width: 5.2, thickness: 2.0 },
  ];

  const wbSamples = [];
  const ebSamples = [];

  for (const spec of deckSpecByWay) {
    if (!rawOsm.ways.has(spec.id)) continue;
    const line = rawWayLine(rawOsm, spec.id);
    for (let i = 0; i < line.length - 1; i += 1) {
      const p0 = line[i];
      const p1 = line[i + 1];
      if (len2(sub2(p1, p0)) <= 0.5) continue;
      const yTop0 = deckElevationAt(p0[0]);
      const yTop1 = deckElevationAt(p1[0]);
      pushBoxSegment(
        bridge3D,
        p0,
        p1,
        spec.width,
        yTop0 - spec.thickness,
        yTop0,
        yTop1 - spec.thickness,
        yTop1,
      );
      // Side safety barriers (1.15 m tall, 0.6 m wide along outer edges)
      const dir = unit2(sub2(p1, p0));
      const n2 = left2(dir);
      for (const side of [-1, 1]) {
        const offset = side * (spec.width / 2 - 0.35);
        const b0 = add2(p0, scale2(n2, offset));
        const b1 = add2(p1, scale2(n2, offset));
        pushBoxSegment(bridge3D, b0, b1, 0.7, yTop0, yTop0 + 1.15, yTop1, yTop1 + 1.15);
      }
      if (spec.width > 15) {
        const target = ["235850739", "430133642", "599155240", "235850741", "1112580172"].includes(spec.id)
          ? wbSamples
          : ebSamples;
        target.push({ p0, p1, y0: yTop0, y1: yTop1 });
      }
    }
  }

  // 2. Concrete piers from r13543937 pier ways + regular twin-column skyway piers down to water/terrain
  for (const wayId of eastMemberWayIds) {
    const way = rawOsm.ways.get(String(wayId));
    if (!way || way.tags["man_made"] !== "pier") continue;
    const footprint = differenceMultiPolygons(rawWayFootprint(rawOsm, wayId, 8), boundary);
    if (footprint.length === 0) continue;
    const centroid = multiPolygonCentroid(footprint);
    const deckY = deckElevationAt(centroid[0]);
    const capTop = roundCoordinate(deckY - 2.6);
    try {
      pieces.push(extrudeWallMesh(footprint, 0, capTop, `East Span pier w${wayId} wall`));
      pieces.push(topSurfaceMesh(footprint, capTop, `East Span pier w${wayId} cap`));
    } catch {
      // Ignore degenerate pier ring
    }
  }

  // Regular twin piers along westbound and eastbound alignments from YBI viaduct to Oakland skyway
  const addSupportBents = (samples, spacingM) => {
    let accum = 0;
    let nextPier = 45;
    for (const seg of samples) {
      const segLen = len2(sub2(seg.p1, seg.p0));
      while (accum + segLen >= nextPier) {
        const localT = (nextPier - accum) / segLen;
        const pt = [
          seg.p0[0] + (seg.p1[0] - seg.p0[0]) * localT,
          seg.p0[1] + (seg.p1[1] - seg.p0[1]) * localT,
        ];
        // Skip right at the SAS tower center (1098.4, -946.4) where the SAS tower piers stand
        if (Math.hypot(pt[0] - 1098.4, pt[1] - -946.4) > 55) {
          const deckY = seg.y0 + (seg.y1 - seg.y0) * localT;
          const groundY = Math.max(0, terrain.sampleTerrainEastNorth(pt[0], pt[1]) - 0.5);
          if (deckY - groundY > 4.0) {
            const dir = unit2(sub2(seg.p1, seg.p0));
            const pStart = add2(pt, scale2(dir, -2.6));
            const pEnd = add2(pt, scale2(dir, 2.6));
            pushBoxSegment(bridge3D, pStart, pEnd, 8.5, groundY, deckY - 3.2, groundY, deckY - 3.2);
            // Crosshead cap beam under the box girder
            pushBoxSegment(bridge3D, pStart, pEnd, 18.0, deckY - 5.2, deckY - 3.0, deckY - 5.2, deckY - 3.0);
          }
        }
        nextPier += spacingM;
      }
      accum += segLen;
    }
  };
  addSupportBents(wbSamples, 115);
  addSupportBents(ebSamples, 115);

  // 3. The signature 160 m tall Single-Tower Self-Anchored Suspension (SAS) Tower (w237735191)
  const sasFootprint = rawWayFootprint(rawOsm, SAS_TOWER_WAY_ID);
  const sasCenter = multiPolygonCentroid(sasFootprint); // ~ [1098.43, -946.39]
  // Bridge axis at the SAS tower (~51 deg azimuth, unit vector along bridge [0.775, 0.632])
  const bridgeAlong = unit2([0.775, 0.632]);
  const bridgeAcross = left2(bridgeAlong);

  // Concrete pile cap / base pedestal at waterline (Y = 0..7.5 m)
  pieces.push(extrudeWallMesh(sasFootprint, 0, 7.5, "SAS tower pedestal wall"));
  pieces.push(topSurfaceMesh(sasFootprint, 7.5, "SAS tower pedestal top"));

  // Four tapering white steel tower shafts rising from Y = 7.5 m to Y = 160.0 m
  const towerLevels = [
    { y: 7.5, spreadAlong: 6.2, spreadAcross: 6.8, legAlong: 4.6, legAcross: 4.8 },
    { y: 44.0, spreadAlong: 5.2, spreadAcross: 5.6, legAlong: 4.2, legAcross: 4.4 },
    { y: 88.0, spreadAlong: 4.0, spreadAcross: 4.2, legAlong: 3.6, legAcross: 3.8 },
    { y: 128.0, spreadAlong: 3.0, spreadAcross: 3.1, legAlong: 3.1, legAcross: 3.2 },
    { y: 156.0, spreadAlong: 2.4, spreadAcross: 2.4, legAlong: 2.7, legAcross: 2.8 },
  ];
  for (let lv = 0; lv < towerLevels.length - 1; lv += 1) {
    const a = towerLevels[lv];
    const b = towerLevels[lv + 1];
    for (const sAlong of [-1, 1]) {
      for (const sAcross of [-1, 1]) {
        const cMid = add2(
          sasCenter,
          add2(
            scale2(bridgeAlong, sAlong * ((a.spreadAlong + b.spreadAlong) / 2)),
            scale2(bridgeAcross, sAcross * ((a.spreadAcross + b.spreadAcross) / 2)),
          ),
        );
        const legLen = (a.legAlong + b.legAlong) / 2;
        const legWid = (a.legAcross + b.legAcross) / 2;
        const p0 = add2(cMid, scale2(bridgeAlong, -legLen / 2));
        const p1 = add2(cMid, scale2(bridgeAlong, legLen / 2));
        pushBoxSegment(bridge3D, p0, p1, legWid, a.y, b.y, a.y, b.y);
      }
    }
    // Shear-link crossbeams connecting the 4 shafts at each tier
    const tierY = b.y;
    const beam0 = add2(sasCenter, scale2(bridgeAcross, -(b.spreadAcross + b.legAcross / 2)));
    const beam1 = add2(sasCenter, scale2(bridgeAcross, b.spreadAcross + b.legAcross / 2));
    pushBoxSegment(bridge3D, beam0, beam1, b.spreadAlong * 2 + b.legAlong, tierY - 3.2, tierY, tierY - 3.2, tierY);
  }
  // Tower saddle crown (Y = 156..162.5 m)
  const saddle0 = add2(sasCenter, scale2(bridgeAlong, -5.5));
  const saddle1 = add2(sasCenter, scale2(bridgeAlong, 5.5));
  pushBoxSegment(bridge3D, saddle0, saddle1, 8.8, 156.0, 162.5, 156.0, 162.5);

  // Crossbeam under the twin decks at the SAS tower (Y = 36.5..40.5 m, spanning 68 m across both decks)
  const deckBeam0 = add2(sasCenter, scale2(bridgeAcross, -34.0));
  const deckBeam1 = add2(sasCenter, scale2(bridgeAcross, 34.0));
  pushBoxSegment(bridge3D, deckBeam0, deckBeam1, 9.0, 36.5, 40.5, 36.5, 40.5);

  // 4. Main suspension cables & suspender cables of the Self-Anchored Suspension span
  // West anchorage at X ≈ 915 m (s = -230 m from tower along bridge), East anchorage at X ≈ 1475 m (s = +485 m from tower)
  const cablePoint = (sAlongM, isEastSpan) => {
    const endS = isEastSpan ? 485.0 : -230.0;
    const u = Math.min(1, Math.abs(sAlongM / endS));
    const endPos = add2(sasCenter, scale2(bridgeAlong, endS));
    const endY = deckElevationAt(endPos[0]) + 1.2;
    const topY = 160.5;
    // Parabolic suspension profile from tower saddle (u=0, y=160.5) down to outer deck edge (u=1, y=endY)
    const y = endY + (topY - endY) * (1 - u) * (1 - u);
    const lateral = 3.2 + u * 25.5; // Widens from 3.2 m at tower saddle to 28.7 m at outer deck edges
    return { s: sAlongM, y, lateral };
  };

  for (const sideSign of [-1, 1]) {
    // West main span (-230..0 m) and East main span (0..485 m)
    const spans = [
      { from: -230, to: 0, steps: 12, east: false },
      { from: 0, to: 485, steps: 22, east: true },
    ];
    for (const sp of spans) {
      for (let k = 0; k < sp.steps; k += 1) {
        const s0 = sp.from + ((sp.to - sp.from) * k) / sp.steps;
        const s1 = sp.from + ((sp.to - sp.from) * (k + 1)) / sp.steps;
        const c0 = cablePoint(s0, sp.east);
        const c1 = cablePoint(s1, sp.east);
        const p0 = add2(
          sasCenter,
          add2(scale2(bridgeAlong, s0), scale2(bridgeAcross, sideSign * c0.lateral)),
        );
        const p1 = add2(
          sasCenter,
          add2(scale2(bridgeAlong, s1), scale2(bridgeAcross, sideSign * c1.lateral)),
        );
        pushBoxSegment(bridge3D, p0, p1, 1.35, c0.y - 0.65, c0.y + 0.65, c1.y - 0.65, c1.y + 0.65);

        // Suspender cables from main cable down to outer deck edge
        if (k > 0) {
          const deckAnchor = add2(
            sasCenter,
            add2(scale2(bridgeAlong, s0), scale2(bridgeAcross, sideSign * 26.5)),
          );
          const deckY = deckElevationAt(deckAnchor[0]);
          if (c0.y - deckY > 3.0) {
            pushBoxSegment(bridge3D, p0, deckAnchor, 0.45, deckY, deckY + 1.5, c0.y - 0.5, c0.y);
          }
        }
      }
    }
  }

  pieces.push(bridge3D);
  return mergeMeshes(pieces, "Bay Bridge Level 1 context");
}

export function buildEnhancedContext({
  ledger,
  boundary,
  rawOsm,
  playableObjects,
  terrain,
  ybiGeometry,
  ybiMesh,
  ybiFacets,
  westGeometry,
  eastMemberWayIds,
  bridgeGeometry,
  contextRecord,
}) {
  const ybiRecords = [
    contextRecord(
      meshRecord({
        objectKey: "context:ybi",
        featureKind: "context",
        sourceKeys: [YBI_SOURCE_KEY],
        materialKey: "context_ybi",
        mesh: ybiMesh,
      }),
      "ybi",
    ),
  ];

  const addYbiRecord = (objectKey, materialKey, mesh) => {
    if (!mesh || !mesh.indices || mesh.indices.length === 0) return;
    validateMesh(mesh, objectKey);
    ybiRecords.push(
      contextRecord(
        meshRecord({
          objectKey,
          featureKind: "context",
          sourceKeys: [YBI_SOURCE_KEY],
          materialKey,
          mesh,
        }),
        "ybi",
      ),
    );
  };

  // 1. YBI Woodland (r15819529 + natural=wood|scrub + landuse=forest|meadow|grass)
  const woodlandParts = [...relationMultiPolygonPartsOnYbi(rawOsm, "15819529", ybiGeometry)];
  const parkParts = [];
  const beachParts = [];
  const parkingParts = [];

  for (const [id, way] of rawOsm.ways) {
    if (way.node_refs.length < 4 || way.node_refs[0] !== way.node_refs.at(-1)) continue;
    const t = way.tags;
    const isPark = t.leisure === "park" || t.leisure === "garden" || t.leisure === "nature_reserve";
    const isWood = t.natural === "wood" || t.natural === "scrub" || t.landuse === "forest" || t.landuse === "meadow" || t.landuse === "grass";
    const isBeach = t.natural === "beach" || t.natural === "sand";
    const isParking = t.amenity === "parking";
    if (!isPark && !isWood && !isBeach && !isParking) continue;
    let clipped;
    try {
      clipped = intersectMultiPolygons(rawWayFootprint(rawOsm, id), ybiGeometry);
    } catch {
      continue;
    }
    if (clipped.length === 0 || multiPolygonArea(clipped) <= 1.0) continue;
    if (isPark) parkParts.push(clipped);
    else if (isWood) woodlandParts.push(clipped);
    else if (isBeach) beachParts.push(clipped);
    else if (isParking) parkingParts.push(clipped);
  }

  addYbiRecord("context:ybi:woodland", "major_area_landuse", drapeListOnYbiFacets(woodlandParts, ybiFacets, 0.016, "YBI woodland"));
  addYbiRecord("context:ybi:beaches", "terrain_sand", drapeListOnYbiFacets(beachParts, ybiFacets, 0.02, "YBI beaches"));
  addYbiRecord("context:ybi:parks", "major_area_leisure", drapeListOnYbiFacets(parkParts, ybiFacets, 0.024, "YBI parks"));
  addYbiRecord("context:ybi:parking", "major_area_paved", drapeListOnYbiFacets(parkingParts, ybiFacets, 0.03, "YBI parking"));

  // 2. YBI Roads & Seamless Causeway Road Continuation
  const vehicleParts = [];
  const pedestrianParts = [];
  const kerbParts = [];
  const yellowMarkingParts = [];
  const whiteMarkingParts = [];
  const redMarkingParts = [];

  for (const [id, way] of rawOsm.ways) {
    const hw = way.tags.highway;
    if (!hw || YBI_TUNNEL_WAY_IDS.has(id) || way.tags.tunnel === "yes") continue;
    if (eastMemberWayIds.includes(id) || id === "1011568818") continue;
    if (way.tags.bridge === "yes" && (hw === "motorway" || hw === "motorway_link")) continue;

    let line;
    try {
      line = rawWayLine(rawOsm, id);
    } catch {
      continue;
    }
    const maxNorth = Math.max(...line.map((pt) => pt[1]));
    const minNorth = Math.min(...line.map((pt) => pt[1]));
    if (minNorth > -910) continue; // Purely north of causeway on TI

    const isPedestrian = ["footway", "cycleway", "path", "steps", "pedestrian"].includes(hw);
    if (isPedestrian) {
      const width = hw === "cycleway" ? 2.6 : ROAD_WIDTHS_M[hw] ?? 2.2;
      try {
        const ribbon = intersectMultiPolygons(lineRibbon(line, width, `YBI path w${id}`), ybiGeometry);
        if (ribbon.length > 0) {
          pedestrianParts.push(ribbon);
          // Causeway sidewalks & cycleway join the raised kerb/red lane treatment
          if (id === "1212173456" || id === "1248964740" || id === "1248964743") {
            kerbParts.push(ribbon);
          }
          if (id === "1248964738" || id === "1248964726") {
            redMarkingParts.push(ribbon);
          }
        }
      } catch {
        // Ignore degenerate path
      }
      continue;
    }

    const baseWidth = ROAD_WIDTHS_M[hw] ?? 7.0;
    const half = baseWidth / 2;
    let roadPoly;
    try {
      if (id === CAUSEWAY_NORTHBOUND_WAY || CAUSEWAY_SOUTHBOUND_WAYS.includes(id)) {
        // Widen left (median) side by 1.2 m to match TI causeway exactly across the seam
        roadPoly = offsetLineStrip(line, -half, half + 1.2, `causeway road w${id}`);
      } else {
        roadPoly = lineRibbon(line, baseWidth, `YBI road w${id}`);
      }
      const clipped = intersectMultiPolygons(roadPoly, ybiGeometry);
      if (clipped.length === 0) continue;
      vehicleParts.push(clipped);

      // Causeway & main road markings + kerbs
      if (id === CAUSEWAY_NORTHBOUND_WAY) {
        // Double yellow centerline at +half (4.5 m)
        const lineHalf = 0.075;
        const widthM = 0.15;
        const leftYellow = offsetLineStrip(line, half + lineHalf, half + lineHalf + widthM, "nb yellow left");
        const rightYellow = offsetLineStrip(line, half - lineHalf - widthM, half - lineHalf, "nb yellow right");
        yellowMarkingParts.push(intersectMultiPolygons(leftYellow, ybiGeometry));
        yellowMarkingParts.push(intersectMultiPolygons(rightYellow, ybiGeometry));
        // Dashed white lane divider at center (0 m)
        whiteMarkingParts.push(intersectMultiPolygons(dashRectanglesAlong(line, 3.0, 6.0, 0.15, 0), ybiGeometry));
        // White right (east) edge line
        whiteMarkingParts.push(intersectMultiPolygons(offsetLineStrip(line, -half + 0.15, -half + 0.3, "nb edge"), ybiGeometry));
        // Raised concrete sidewalk/kerb along right (east) side
        kerbParts.push(intersectMultiPolygons(offsetLineStrip(line, -half - 2.4, -half + 0.05, "nb east kerb"), ybiGeometry));
      } else if (CAUSEWAY_SOUTHBOUND_WAYS.includes(id)) {
        // Red bike/transit lane along right (west) side + white lane/edge lines
        const redWidth = 1.6;
        const inner = half - redWidth;
        whiteMarkingParts.push(intersectMultiPolygons(offsetLineStrip(line, -inner, -inner + 0.15, "sb red line"), ybiGeometry));
        whiteMarkingParts.push(intersectMultiPolygons(offsetLineStrip(line, -half + 0.15, -half + 0.3, "sb edge line"), ybiGeometry));
        redMarkingParts.push(intersectMultiPolygons(offsetLineStrip(line, -half + 0.35, -inner - 0.05, "sb red fill"), ybiGeometry));
        // Raised concrete sidewalk/kerb along right (west) side
        kerbParts.push(intersectMultiPolygons(offsetLineStrip(line, -half - 2.6, -half + 0.05, "sb west kerb"), ybiGeometry));
      } else if (
        way.tags.oneway !== "yes" &&
        (YBI_MAIN_TWO_WAY_NAMES.has(way.tags.name) || hw === "secondary" || hw === "tertiary") &&
        maxNorth <= -1050
      ) {
        const lineHalf = 0.075;
        const widthM = 0.15;
        const leftY = offsetLineStrip(line, lineHalf, lineHalf + widthM, `ybi yellow l w${id}`);
        const rightY = offsetLineStrip(line, -lineHalf - widthM, -lineHalf, `ybi yellow r w${id}`);
        yellowMarkingParts.push(intersectMultiPolygons(leftY, ybiGeometry));
        yellowMarkingParts.push(intersectMultiPolygons(rightY, ybiGeometry));
        whiteMarkingParts.push(intersectMultiPolygons(offsetLineStrip(line, half - 0.3, half - 0.15, `ybi edge l w${id}`), ybiGeometry));
        whiteMarkingParts.push(intersectMultiPolygons(offsetLineStrip(line, -half + 0.15, -half + 0.3, `ybi edge r w${id}`), ybiGeometry));
        if (id === "255330059" || way.tags.name === "Macalla Road" || way.tags.name === "Bristol Court") {
          kerbParts.push(intersectMultiPolygons(offsetLineStrip(line, half + 0.05, half + 2.0, `ybi kerb l w${id}`), ybiGeometry));
          kerbParts.push(intersectMultiPolygons(offsetLineStrip(line, -half - 2.0, -half - 0.05, `ybi kerb r w${id}`), ybiGeometry));
        }
      }
    } catch {
      // Skip malformed road segment
    }
  }

  addYbiRecord(
    "context:ybi:roads",
    "road_path",
    drapeListOnYbiFacets(vehicleParts, ybiFacets, ROAD_SURFACE_BIASES_M.base, "YBI vehicle roads"),
  );
  addYbiRecord(
    "context:ybi:paths",
    "road_path_pedestrian",
    drapeListOnYbiFacets(pedestrianParts, ybiFacets, 0.036, "YBI pedestrian paths"),
  );
  addYbiRecord(
    "context:ybi:kerbs",
    "street_kerb_concrete",
    raisedKerbListMesh(kerbParts, ybiFacets, 0.17, 0.03, terrain.sampleTerrainEastNorth, "YBI raised kerbs"),
  );

  // Markings: white (UV [0.5, 0.5]), yellow (UV [1.5, 0.5]), red (UV [2.5, 0.5])
  const markingMeshes = [];
  const yellowMesh = drapeListOnYbiFacets(yellowMarkingParts, ybiFacets, 0.084, "YBI yellow markings", () => [1.5, 0.5]);
  const whiteMesh = drapeListOnYbiFacets(whiteMarkingParts, ybiFacets, 0.08, "YBI white markings", () => [0.5, 0.5]);
  const redMesh = drapeListOnYbiFacets(redMarkingParts, ybiFacets, 0.082, "YBI red bike lane", () => [2.5, 0.5]);
  for (const m of [yellowMesh, whiteMesh, redMesh]) {
    if (m && m.indices.length > 0) markingMeshes.push(m);
  }
  if (markingMeshes.length > 0) {
    addYbiRecord("context:ybi:markings", "street_marking", mergeMeshes(markingMeshes, "YBI street markings"));
  }

  // 3. Seamless Causeway 3D Shoreline Rock Riprap on YBI
  const riprap = buildCausewayShorelineRiprapOnYbi(rawOsm, terrain);
  addYbiRecord("context:ybi:riprap-slope", "shoreline_riprap", riprap.slopeMesh);
  addYbiRecord("context:ybi:riprap-boulders", "shoreline_boulder", riprap.boulderMesh);

  // 4. The Bristol (w813225688) at Level 1 + all other YBI Buildings
  const bristol = buildBristolMeshes(rawOsm, ybiGeometry, terrain);
  addYbiRecord("context:ybi:bristol-base", "building_wall", bristol.baseWallMesh);
  addYbiRecord("context:ybi:bristol-wall", "building_part_wall", bristol.upperWallMesh);
  addYbiRecord("context:ybi:bristol-roof", "building_roof", bristol.roofMesh);

  const ybiBuildings = buildYbiBuildingsMeshes(rawOsm, ybiGeometry, terrain);
  addYbiRecord("context:ybi:buildings-wall", "building_wall", ybiBuildings.wallMesh);
  addYbiRecord("context:ybi:buildings-roof", "building_roof", ybiBuildings.roofMesh);

  // 5. Eastern Span of the Bay Bridge at Level 1
  const bridgeMesh = buildEasternBayBridge3DMesh(
    rawOsm,
    westGeometry,
    eastMemberWayIds,
    boundary,
    terrain,
  );
  const bridgeRecord = contextRecord(
    meshRecord({
      objectKey: "context:bay-bridge",
      featureKind: "context",
      sourceKeys: BRIDGE_SOURCE_KEYS,
      materialKey: "context_bay_bridge",
      mesh: bridgeMesh,
    }),
    "bay_bridge",
  );

  const records = [...ybiRecords, bridgeRecord].sort((left, right) =>
    left.object_key.localeCompare(right.object_key),
  );

  const ybiKeys = ybiRecords.map((r) => r.object_key).sort();
  const bridgeKeys = [bridgeRecord.object_key];

  return {
    records,
    ybiPhysicalKeys: ybiKeys,
    bridgePhysicalKeys: bridgeKeys,
  };
}
