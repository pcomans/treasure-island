#!/usr/bin/env node
// Clip audit: an on-demand scan of the generated world for things that may clip,
// ranked for a person to look at. It is a lead list, not a gate, and tools/test.sh
// doesn't run it.
//
//   node tools/clip_audit.mjs [--world generated/world] [--out findings.json] [--top 13]
//
// It reads only the chunk records and street_detail.json (a few seconds), prints the
// counts and the top findings of each kind, and with --out writes them all as JSON.
// It rasters the ground at 0.25 m and reports three kinds of finding:
//   1. a prop against the ground: it crosses hard and soft ground with a step (crosses),
//      or the ground stands above or below its rest (buried, floating);
//   2. ground against ground: a surface pokes through one it should lie under (poke),
//      or two materials lie within 1.5 mm of each other (coplanar);
//   3. object against object: two footprints overlap (objects), or a prop stands on a
//      roof's plan (in_building).
// Scores weigh size and closeness to a road or path.
//
// Limits. In a hand-check of the first run on 2026-11-06 about 38 % of the findings
// were false alarms. Props are plan rectangles at their row's footprint, or a guessed
// radius without one. It can't see meshes built at runtime, prop heights (a shelter's
// roof over a bench counts as an overlap) or planting (grass clumps are skipped).

import { readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const CELL_M = 0.25;
const CHUNK_M = 256;
const CELLS = CHUNK_M / CELL_M;
// The most ground materials a cell remembers.
const LAYERS = 6;
const GROUND_KINDS = new Set(["land_ground", "major_area", "road_path", "street_kerb", "terrain_overlay"]);
const SOFT_MATERIAL = /land_ground|leisure|verge|planting|mulch|grass|lawn|landuse/;
const PATH_MATERIAL = /^road_path|street_plaza|kerb_concrete/;
// Footprint radii where a row has no footprint of its own.
const PROP_RADIUS_M = { bus_stop_sign: 0.15, waste_basket: 0.3 };
const TRUNK_RADIUS_M = { tree: 0.3, palm_slot: 0.3, planting_slot: 0.4 };

function argument(name, fallback) {
  const index = process.argv.indexOf(name);
  return index >= 0 && index + 1 < process.argv.length ? process.argv[index + 1] : fallback;
}

const isGround = (record) => GROUND_KINDS.has(record.feature_kind) ||
  (record.feature_kind === "street_paint" && !["street_marking", "street_wear"].includes(record.material_key));

// Where a material lies in the stack: land, areas, roads, then what is raised on them.
function stackRank(material) {
  if (/land_ground/.test(material)) return 0;
  if (/^major_area|terrain_/.test(material)) return 1;
  if (/^road_path/.test(material)) return 2;
  return /parking|gutter|park_|yard_|black_plastic/.test(material) ? 3 : 4;
}

function* triangles(record) {
  const { vertices: v, indices } = record;
  for (let t = 0; t < indices.length; t += 3) {
    const [a, b, c] = [indices[t] * 3, indices[t + 1] * 3, indices[t + 2] * 3];
    yield [v[a], v[a + 1], v[a + 2], v[b], v[b + 1], v[b + 2], v[c], v[c + 1], v[c + 2]];
  }
}

// How level a triangle is: its normal's y.
function levelness(t) {
  const [ux, uy, uz, vx, vy, vz] = [t[3] - t[0], t[4] - t[1], t[5] - t[2], t[6] - t[0], t[7] - t[1], t[8] - t[2]];
  const [nx, ny, nz] = [uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx];
  return Math.abs(ny) / Math.max(1e-9, Math.hypot(nx, ny, nz));
}

// Calls visit(i, j, y) for each cell whose centre lies in the triangle's plan.
function rasterize(t, x0, z0, visit) {
  const [ax, ay, az, bx, by, bz, cx, cy, cz] = t;
  const den = (bz - cz) * (ax - cx) + (cx - bx) * (az - cz);
  if (Math.abs(den) < 1e-9) return;
  const i0 = Math.max(0, Math.floor((Math.min(ax, bx, cx) - x0) / CELL_M));
  const i1 = Math.min(CELLS - 1, Math.ceil((Math.max(ax, bx, cx) - x0) / CELL_M));
  const j0 = Math.max(0, Math.floor((Math.min(az, bz, cz) - z0) / CELL_M));
  const j1 = Math.min(CELLS - 1, Math.ceil((Math.max(az, bz, cz) - z0) / CELL_M));
  for (let j = j0; j <= j1; j += 1) {
    const z = z0 + (j + 0.5) * CELL_M;
    for (let i = i0; i <= i1; i += 1) {
      const x = x0 + (i + 0.5) * CELL_M;
      const l1 = ((bz - cz) * (x - cx) + (cx - bx) * (z - cz)) / den;
      const l2 = ((cz - az) * (x - cx) + (ax - cx) * (z - cz)) / den;
      const l3 = 1 - l1 - l2;
      if (l1 < -1e-9 || l2 < -1e-9 || l3 < -1e-9) continue;
      visit(i, j, l1 * ay + l2 * by + l3 * cy);
    }
  }
}

// Reads a chunk into a tile of top heights, materials and roof cells, and adds its
// ground-against-ground clusters to clusters.
function scanChunk(chunk, materials, clusters) {
  const materialId = (name) => {
    if (!materials.ids.has(name)) {
      materials.ids.set(name, materials.names.length);
      materials.names.push(name);
    }
    return materials.ids.get(name);
  };
  const { min_x: x0, min_z: z0 } = chunk.bounds_m;
  const size = CELLS * CELLS;
  const tile = { x0, z0, top: new Float32Array(size).fill(NaN), material: new Int16Array(size).fill(-1), roof: new Uint8Array(size) };
  const layerCount = new Uint8Array(size);
  const layerY = new Float32Array(size * LAYERS);
  const layerMaterial = new Int16Array(size * LAYERS);
  for (const record of chunk.records) {
    if (/^building_(roof|part_roof)$/.test(record.feature_kind)) {
      for (const t of triangles(record)) rasterize(t, x0, z0, (i, j) => { tile.roof[j * CELLS + i] = 1; });
      continue;
    }
    if (!isGround(record)) continue;
    const material = materialId(record.material_key);
    for (const t of triangles(record)) {
      if (levelness(t) < 0.5) continue;
      rasterize(t, x0, z0, (i, j, y) => {
        const cell = j * CELLS + i;
        if (!(tile.top[cell] >= y)) {
          tile.top[cell] = y;
          tile.material[cell] = material;
        }
        const count = layerCount[cell];
        for (let layer = 0; layer < count; layer += 1) {
          if (layerMaterial[cell * LAYERS + layer] === material) {
            if (y > layerY[cell * LAYERS + layer]) layerY[cell * LAYERS + layer] = y;
            return;
          }
        }
        if (count < LAYERS) {
          layerMaterial[cell * LAYERS + count] = material;
          layerY[cell * LAYERS + count] = y;
          layerCount[cell] = count + 1;
        }
      });
    }
  }
  // Each cell: a surface above what should cover it, or the top two nearly coplanar.
  const flags = new Int32Array(size).fill(-1);
  const types = [];
  const typeId = (name) => {
    if (!types.includes(name)) types.push(name);
    return types.indexOf(name);
  };
  for (let cell = 0; cell < size; cell += 1) {
    const count = layerCount[cell];
    if (count < 2) continue;
    const y = (layer) => layerY[cell * LAYERS + layer];
    const name = (layer) => materials.names[layerMaterial[cell * LAYERS + layer]];
    let top = 0;
    for (let layer = 1; layer < count; layer += 1) if (y(layer) > y(top)) top = layer;
    let second = -1;
    for (let layer = 0; layer < count; layer += 1) if (layer !== top && (second < 0 || y(layer) > y(second))) second = layer;
    let cover = -1;
    for (let layer = 0; layer < count; layer += 1) {
      if (stackRank(name(layer)) > stackRank(name(top)) && (cover < 0 || y(layer) > y(cover))) cover = layer;
    }
    let type = null;
    if (cover >= 0 && y(top) - y(cover) > 0.01 && y(top) - y(cover) < 1.5) type = `poke:${name(top)}>${name(cover)}`;
    else if (y(top) - y(second) < 0.0015 && name(top) !== name(second)) type = `coplanar:${[name(top), name(second)].sort().join("|")}`;
    if (type) flags[cell] = typeId(type);
  }
  // Connected runs of one type, 0.5 m2 or more.
  const seen = new Uint8Array(size);
  for (let start = 0; start < size; start += 1) {
    if (flags[start] < 0 || seen[start]) continue;
    const type = flags[start];
    let [cells, sumI, sumJ, minI, maxI, minJ, maxJ] = [0, 0, 0, Infinity, -Infinity, Infinity, -Infinity];
    const stack = [start];
    seen[start] = 1;
    while (stack.length > 0) {
      const cell = stack.pop();
      const [i, j] = [cell % CELLS, Math.floor(cell / CELLS)];
      cells += 1;
      sumI += i;
      sumJ += j;
      [minI, maxI, minJ, maxJ] = [Math.min(minI, i), Math.max(maxI, i), Math.min(minJ, j), Math.max(maxJ, j)];
      for (const [di, dj] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
        const [a, b] = [i + di, j + dj];
        if (a < 0 || b < 0 || a >= CELLS || b >= CELLS) continue;
        const next = b * CELLS + a;
        if (!seen[next] && flags[next] === type) {
          seen[next] = 1;
          stack.push(next);
        }
      }
    }
    const area = cells * CELL_M * CELL_M;
    if (area < 0.5) continue;
    clusters.push({
      kind: 2,
      id: types[type],
      x: x0 + (sumI / cells + 0.5) * CELL_M,
      z: z0 + (sumJ / cells + 0.5) * CELL_M,
      area_m2: Number(area.toFixed(2)),
      span_m: Number((Math.max(maxI - minI, maxJ - minJ) * CELL_M + CELL_M).toFixed(1)),
    });
  }
  return tile;
}

// The placed rows as oriented rectangles, a line row as one per segment.
function propRectangles(street) {
  const props = [];
  for (const row of street.rows) {
    if (row.status !== "placed" || row.layer === "ground") continue;
    const kind = street.kinds[row.kind];
    if (!kind || kind.overhead) continue;
    if (row.geometry === "point") {
      if (row.kind === "grass_clump") continue;
      const radius = PROP_RADIUS_M[row.prop] ?? TRUNK_RADIUS_M[row.kind] ?? kind.footprint_radius_m;
      const plan = row.footprint_m ?? { x_m: 2 * radius, z_m: 2 * radius };
      const [x, y, z] = row.position_m;
      props.push({
        row, x, z,
        base: y + (row.surface?.bias_m ?? 0) + (row.prop_params?.lift ?? 0),
        hx: plan.x_m / 2,
        hz: plan.z_m / 2,
        yaw: row.yaw_radians ?? 0,
        settled: row.prop_params?.lift_m !== undefined || ["parked_car", "van"].includes(row.kind),
      });
    } else if (row.points_m) {
      const halfWidth = Math.max(0.1, kind.footprint_radius_m);
      for (let index = 0; index + 1 < row.points_m.length; index += 1) {
        const [ax, , az] = row.points_m[index];
        const [bx, , bz] = row.points_m[index + 1];
        const length = Math.hypot(bx - ax, bz - az);
        if (length < 0.05) continue;
        props.push({ row, segment: index, line: true, x: (ax + bx) / 2, z: (az + bz) / 2, hx: length / 2, hz: halfWidth, yaw: Math.atan2(-(bz - az), bx - ax) });
      }
    }
  }
  return props;
}

// Local X and Z in world x, z.
function axes(prop) {
  const [c, s] = [Math.cos(prop.yaw), Math.sin(prop.yaw)];
  return [[c, -s], [s, c]];
}

// How deep two rectangles overlap, or 0: separating axes.
function penetration(a, b) {
  const [axesA, axesB] = [axes(a), axes(b)];
  const [dx, dz] = [b.x - a.x, b.z - a.z];
  const reach = (prop, own, axis) => prop.hx * Math.abs(axis[0] * own[0][0] + axis[1] * own[0][1]) + prop.hz * Math.abs(axis[0] * own[1][0] + axis[1] * own[1][1]);
  let depth = Infinity;
  for (const axis of [...axesA, ...axesB]) {
    const overlap = reach(a, axesA, axis) + reach(b, axesB, axis) - Math.abs(dx * axis[0] + dz * axis[1]);
    if (overlap <= 0) return 0;
    depth = Math.min(depth, overlap);
  }
  return depth;
}

function main() {
  const world = resolve(projectRoot, argument("--world", "generated/world"));
  const street = JSON.parse(readFileSync(join(world, "street_detail.json"), "utf8"));
  const chunkFolder = join(world, "chunks");
  const materials = { ids: new Map(), names: [] };
  const clusters = [];
  const tiles = new Map();
  const tileKey = (i, j) => `${i},${j}`;
  for (const file of readdirSync(chunkFolder).filter((name) => name.endsWith(".json")).sort()) {
    const tile = scanChunk(JSON.parse(readFileSync(join(chunkFolder, file), "utf8")), materials, clusters);
    tiles.set(tileKey(tile.x0 / CHUNK_M, tile.z0 / CHUNK_M), tile);
  }
  const cellAt = (x, z) => {
    const tile = tiles.get(tileKey(Math.floor(x / CHUNK_M), Math.floor(z / CHUNK_M)));
    return tile ? { tile, cell: Math.floor((z - tile.z0) / CELL_M) * CELLS + Math.floor((x - tile.x0) / CELL_M) } : null;
  };

  // Distance to the nearest road or path, on a 4 m grid, for the scores.
  const GRID_M = 4;
  const pathCells = new Set();
  for (const tile of tiles.values()) {
    for (let cell = 0; cell < CELLS * CELLS; cell += 1) {
      const material = tile.material[cell];
      if (material < 0 || !PATH_MATERIAL.test(materials.names[material])) continue;
      pathCells.add(`${Math.floor((tile.x0 + (cell % CELLS) * CELL_M) / GRID_M)},${Math.floor((tile.z0 + Math.floor(cell / CELLS) * CELL_M) / GRID_M)}`);
    }
  }
  const pathDistance = (x, z) => {
    const [gi, gj] = [Math.floor(x / GRID_M), Math.floor(z / GRID_M)];
    for (let ring = 0; ring <= 15; ring += 1) {
      for (let a = -ring; a <= ring; a += 1) {
        const offsets = Math.abs(a) === ring ? Array.from({ length: 2 * ring + 1 }, (_, index) => index - ring) : [-ring, ring];
        if (offsets.some((b) => pathCells.has(`${gi + a},${gj + b}`))) return ring * GRID_M;
      }
    }
    return 64;
  };
  const nearPath = (distance) => (distance <= 8 ? 1 : Math.max(0.15, 1 - (distance - 8) / 40));

  const findings = [];
  const props = propRectangles(street);
  for (const prop of props) {
    let [count, roofCells, soft, hard, buried, floating, low, high] = [0, 0, 0, 0, 0, 0, Infinity, -Infinity];
    const seen = new Map();
    const points = [];
    const [axisX, axisZ] = axes(prop);
    for (let u = -prop.hx + CELL_M / 2; u < prop.hx; u += CELL_M) {
      for (let v = -prop.hz + CELL_M / 2; v < prop.hz; v += CELL_M) {
        const [x, z] = [prop.x + u * axisX[0] + v * axisZ[0], prop.z + u * axisX[1] + v * axisZ[1]];
        const at = cellAt(x, z);
        if (!at || at.tile.material[at.cell] < 0) continue;
        const material = materials.names[at.tile.material[at.cell]];
        const y = at.tile.top[at.cell];
        count += 1;
        if (at.tile.roof[at.cell]) roofCells += 1;
        seen.set(material, (seen.get(material) ?? 0) + 1);
        if (SOFT_MATERIAL.test(material)) soft += 1;
        else hard += 1;
        low = Math.min(low, y);
        high = Math.max(high, y);
        points.push([x, z, y]);
        if (!prop.line) {
          buried = Math.max(buried, y - prop.base);
          floating = Math.max(floating, prop.base - y);
        }
      }
    }
    if (count === 0) continue;
    // A prop tilted to the ground: measure against the plane through its ground.
    const params = prop.row.prop_params;
    if (params && (params.pitch !== undefined || params.roll !== undefined) && points.length >= 6) {
      const [mx, mz, my] = [0, 1, 2].map((axis) => points.reduce((sum, point) => sum + point[axis], 0) / points.length);
      let [a, b, d, e, f] = [0, 0, 0, 0, 0];
      for (const [x, z, y] of points) {
        const [u, v, w] = [x - mx, z - mz, y - my];
        a += u * u;
        b += u * v;
        d += v * v;
        e += u * w;
        f += v * w;
      }
      const det = a * d - b * b || 1e-9;
      const [gx, gz] = [(e * d - f * b) / det, (a * f - b * e) / det];
      [buried, floating] = [0, 0];
      for (const [x, z, y] of points) {
        const residual = y - (my + gx * (x - mx) + gz * (z - mz));
        buried = Math.max(buried, residual);
        floating = Math.max(floating, -residual);
      }
    }
    if (prop.line) continue;
    const length = 2 * Math.max(prop.hx, prop.hz);
    const size = Math.min(length, 6);
    const road = pathDistance(prop.x, prop.z);
    const weight = nearPath(road);
    const row = { id: prop.row.id, kind_obj: prop.row.kind, prop: prop.row.prop ?? null, x: Number(prop.x.toFixed(1)), z: Number(prop.z.toFixed(1)), len_m: Number(length.toFixed(1)), road_m: road };
    const mats = [...seen.keys()].join("+");
    if (prop.hx * prop.hz * 4 >= 0.5 && count >= 4) {
      const minor = Math.min(soft, hard) / count;
      const step = high - low;
      if (minor >= 0.15 && step >= 0.08) findings.push({ ...row, kind: 1, id2: "crosses", minor: Number(minor.toFixed(2)), step_m: Number(step.toFixed(2)), mats, score: Number((size * minor * 2 * weight * Math.min(1.5, 0.5 + step * 3)).toFixed(2)) });
      if (!prop.settled && buried > 0.1) findings.push({ ...row, kind: 1, id2: "buried", bury_m: Number(buried.toFixed(2)), mats, score: Number((size * Math.min(1, buried / 0.3) * weight * 0.8).toFixed(2)) });
      if (!prop.settled && floating > 0.12) findings.push({ ...row, kind: 1, id2: "floating", float_m: Number(floating.toFixed(2)), mats, score: Number((size * Math.min(1, floating / 0.3) * weight * 0.8).toFixed(2)) });
    }
    if (roofCells / count >= 0.1 && count >= 2) findings.push({ ...row, kind: 3, id2: "in_building", frac: Number((roofCells / count).toFixed(2)), score: Number((Math.max(1, length) * (roofCells / count) * weight).toFixed(2)) });
  }

  // Object against object, through a spatial hash.
  const BIN_M = 8;
  const bins = new Map();
  props.forEach((prop, index) => {
    const reach = Math.hypot(prop.hx, prop.hz);
    for (let a = Math.floor((prop.x - reach) / BIN_M); a <= Math.floor((prop.x + reach) / BIN_M); a += 1) {
      for (let b = Math.floor((prop.z - reach) / BIN_M); b <= Math.floor((prop.z + reach) / BIN_M); b += 1) {
        const key = `${a},${b}`;
        if (!bins.has(key)) bins.set(key, []);
        bins.get(key).push(index);
      }
    }
  });
  const compared = new Set();
  for (const bin of bins.values()) {
    for (let p = 0; p < bin.length; p += 1) {
      for (let q = p + 1; q < bin.length; q += 1) {
        const [i, j] = [Math.min(bin[p], bin[q]), Math.max(bin[p], bin[q])];
        if (compared.has(`${i}-${j}`)) continue;
        compared.add(`${i}-${j}`);
        const [a, b] = [props[i], props[j]];
        if (a.row === b.row || (a.line && b.line) || a.row.id.includes(b.row.id) || b.row.id.includes(a.row.id)) continue;
        const depth = penetration(a, b);
        if (depth < 0.08) continue;
        const road = pathDistance(a.x, a.z);
        findings.push({
          kind: 3, id2: "objects", id: a.row.id, other: b.row.id,
          kind_obj: `${a.row.kind}+${b.row.kind}`, prop: `${a.row.prop ?? ""}+${b.row.prop ?? ""}`,
          x: Number(((a.x + b.x) / 2).toFixed(1)), z: Number(((a.z + b.z) / 2).toFixed(1)),
          pen_m: Number(depth.toFixed(2)), road_m: road, score: Number((Math.min(3, depth) * 2 * nearPath(road)).toFixed(2)),
        });
      }
    }
  }
  for (const cluster of clusters) {
    const road = pathDistance(cluster.x, cluster.z);
    findings.push({ ...cluster, road_m: road, id2: cluster.id.split(":")[0], score: Number((Math.sqrt(cluster.area_m2) * nearPath(road)).toFixed(2)) });
  }

  findings.sort((left, right) => right.score - left.score);
  const out = argument("--out", null);
  if (out) writeFileSync(resolve(process.cwd(), out), JSON.stringify(findings));
  const counts = {};
  for (const finding of findings) counts[`${finding.kind}:${finding.id2}`] = (counts[`${finding.kind}:${finding.id2}`] ?? 0) + 1;
  console.log(`props ${props.length}, findings`, counts);
  const top = Number(argument("--top", 13));
  for (const kind of [1, 2, 3]) {
    console.log(`Top of kind ${kind}:`);
    const named = new Set();
    for (const finding of findings.filter((item) => item.kind === kind)) {
      if (named.has(finding.id)) continue;
      named.add(finding.id);
      if (named.size > top) break;
      const detail = finding.bury_m ?? finding.float_m ?? finding.step_m ?? finding.pen_m ?? finding.area_m2 ?? finding.frac;
      console.log(`  ${finding.score} ${finding.id2} ${finding.id}${finding.other ? ` / ${finding.other}` : ""} at (${Number(finding.x).toFixed(1)}, ${Number(finding.z).toFixed(1)}): ${detail}`);
    }
  }
}

main();
