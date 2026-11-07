#!/usr/bin/env node
// Yerba Buena Island land cover read from a dated aerial: the share of each heuristic
// cover class in every LAND_COVER_CELL_M cell of the island's land, written to
// data/ybi/ybi-land-cover-2026-05-26.json for tools/lib/ybi-context-generation.mjs
// (its tree crowns, scrub and ground-cover map).
//
//   node tools/build_ybi_land_cover.mjs --mosaic DIR
//
// DIR holds the aerial outside Git: mosaic.json ({z, X0, Y0, nx, ny}, the Web Mercator
// tile range) and mosaic.rgb (the tiles assembled north-up, raw 8-bit RGB). The run of
// 2026-11-07 used Esri World Imagery Wayback release 43291 (2026-10-29), zoom 19, tiles
// x 83923-83947 and y 202572-202591, whose YBI imagery is the 2026-05-26 Vantor capture
// (0.34 m, World_Imagery_Metadata_2026_r10 layer 4 at five points on the island): the
// same capture and classifier as the Treasure Island vegetation and ground-cover work.
// The aerial itself never enters the repository; only these class shares do.
//
// Each 1 m sample takes the class of the aerial pixels it covers (the vegetation
// inventory's heuristic: canopy = dark saturated green, green = bright green, dry =
// straw, bare = pale soil, rock or concrete, other = the rest: asphalt, roofs, shadow,
// water); a cell stores each class's share as a byte (0-255), and the share of its
// pixels in deep shadow (mean of R, G and B under SHADOW_LUMINANCE): tall trees throw
// long shadows in the late-morning capture, low scrub hardly any. Cells off the
// island's land (w26767311 less the Treasure Island polygon) are zero.

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { deflateSync } from "node:zlib";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { tmpdir } from "node:os";
import { mkdtempSync, rmSync } from "node:fs";
import { join } from "node:path";

import { inverseProjectEastNorth } from "./lib/coordinates.mjs";
import {
  differenceMultiPolygons,
  exportOsmiumGeoJsonSeq,
  geometryToMultiPolygon,
  parseGeoJsonSeq,
  pointInMultiPolygon,
  selectGeometry,
} from "./lib/osm-geometry.mjs";
import { SOURCE_CONTRACT, YBI_SOURCE_KEY, invariant } from "./lib/world-contract.mjs";
import { YBI_LAND_COVER_CLASSES, YBI_LAND_COVER_GRID, YBI_LAND_COVER_LAYERS, YBI_LAND_COVER_PATH } from "./lib/ybi-context-generation.mjs";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const SHADOW_LUMINANCE = 38;

// The vegetation inventory's per-pixel cover class (its zonestats.py): 0 canopy,
// 1 green, 2 dry, 3 bare, 4 other.
export function classifyAerialPixel(r, g, b) {
  const l = (r + g + b) / 3;
  const mx = Math.max(r, g, b);
  const mn = Math.min(r, g, b);
  const s = (mx - mn) / (mx + 1);
  if (g >= r + 8 && g >= b + 10 && l < 80 && s > 0.2) return 0;
  if (g >= r + 8 && g >= b + 20 && s > 0.25) return 1;
  if (r >= g - 2 && r >= b + 20 && s > 0.18 && l < 170) return 2;
  if (l >= 145 && r >= b + 12 && s < 0.3) return 3;
  return 4;
}

function parseArguments(argv) {
  let mosaic = null;
  for (let index = 0; index < argv.length; index += 1) {
    if (argv[index] === "--mosaic") {
      mosaic = resolve(argv[index + 1]);
      index += 1;
    } else {
      throw new Error(`Unknown argument ${argv[index]}`);
    }
  }
  invariant(mosaic, "--mosaic DIR is required");
  return { mosaic };
}

function loadMosaic(directory) {
  const meta = JSON.parse(readFileSync(join(directory, "mosaic.json"), "utf8"));
  const data = readFileSync(join(directory, "mosaic.rgb"));
  const width = meta.nx * 256;
  const height = meta.ny * 256;
  invariant(data.length === width * height * 3, `mosaic.rgb is not ${width}x${height} RGB`);
  const toPixel = (east, north) => {
    const [longitude, latitude] = inverseProjectEastNorth([east, north]);
    const n = 2 ** meta.z;
    const tileX = ((longitude + 180) / 360) * n;
    const tileY = ((1 - Math.asinh(Math.tan((latitude * Math.PI) / 180)) / Math.PI) / 2) * n;
    return [(tileX - meta.X0) * 256, (tileY - meta.Y0) * 256];
  };
  return { meta, data, width, height, toPixel };
}

function ybiLand() {
  const temporary = mkdtempSync(join(tmpdir(), "ti-ybi-land-cover-"));
  try {
    const path = join(temporary, "raw.geojsonseq");
    exportOsmiumGeoJsonSeq(resolve(projectRoot, SOURCE_CONTRACT.raw_osm.path), path);
    const sources = parseGeoJsonSeq(path);
    const island = geometryToMultiPolygon(selectGeometry(sources.get(YBI_SOURCE_KEY), "area"), YBI_SOURCE_KEY);
    const boundary = JSON.parse(readFileSync(resolve(projectRoot, SOURCE_CONTRACT.extraction_polygon.path), "utf8"));
    return differenceMultiPolygons(island, geometryToMultiPolygon(boundary.features[0].geometry, "Treasure Island boundary"));
  } finally {
    rmSync(temporary, { recursive: true, force: true });
  }
}

function main() {
  const { mosaic: directory } = parseArguments(process.argv.slice(2));
  const mosaic = loadMosaic(directory);
  const land = ybiLand();
  const { origin_xz: [x0, z0], cell_m: cell, width, height } = YBI_LAND_COVER_GRID;
  const sub = cell; // 1 m samples per cell side
  const layers = YBI_LAND_COVER_LAYERS.map(() => new Uint8Array(width * height));
  const shadowLayer = YBI_LAND_COVER_LAYERS.indexOf("shadow");
  let landCells = 0;
  for (let row = 0; row < height; row += 1) {
    for (let column = 0; column < width; column += 1) {
      const counts = [0, 0, 0, 0, 0];
      let samples = 0;
      let dark = 0;
      for (let v = 0; v < sub; v += 1) {
        for (let u = 0; u < sub; u += 1) {
          const x = x0 + column * cell + u + 0.5;
          const z = z0 + row * cell + v + 0.5;
          if (!pointInMultiPolygon([x, -z], land, true)) continue;
          const [left, top] = mosaic.toPixel(x - 0.5, -(z - 0.5));
          const [right, bottom] = mosaic.toPixel(x + 0.5, -(z + 0.5));
          for (let py = Math.floor(top); py <= Math.floor(bottom); py += 1) {
            for (let px = Math.floor(left); px <= Math.floor(right); px += 1) {
              invariant(px >= 0 && py >= 0 && px < mosaic.width && py < mosaic.height, "The mosaic does not cover the island");
              const index = (py * mosaic.width + px) * 3;
              const [r, g, b] = [mosaic.data[index], mosaic.data[index + 1], mosaic.data[index + 2]];
              counts[classifyAerialPixel(r, g, b)] += 1;
              if ((r + g + b) / 3 < SHADOW_LUMINANCE) dark += 1;
              samples += 1;
            }
          }
        }
      }
      if (samples === 0) continue;
      landCells += 1;
      for (let k = 0; k < YBI_LAND_COVER_CLASSES.length; k += 1) layers[k][row * width + column] = Math.round((counts[k] / samples) * 255);
      layers[shadowLayer][row * width + column] = Math.round((dark / samples) * 255);
    }
  }
  const document = {
    schema_version: "ti.ybi-land-cover/1",
    notes: [
      "Shares of the vegetation inventory's heuristic cover classes (canopy: dark saturated green; green: bright green; dry: straw; bare: pale soil, rock or concrete) in each cell of Yerba Buena Island's land (w26767311 less the Treasure Island polygon w26767313), 0-255; cells off the land are 0. The rest of a cell is the other class (asphalt, roofs, shadow). The shadow layer is the share of pixels darker than a mean RGB of 38, whatever their class.",
      "Read by tools/build_ybi_land_cover.mjs from the 2026-05-26 Vantor aerial (0.34 m) as served by Esri World Imagery Wayback release 43291 (2026-10-29), zoom 19, tiles x 83923-83947, y 202572-202591 (capture date from World_Imagery_Metadata_2026_r10 layer 4 at five points on the island, queried 2026-11-07). The aerial stays outside Git. Imagery and OSM are offset by a few metres in places; the shares are production inference, not survey data.",
      "Layers are row-major (rows north to south, +Z), each a zlib-deflated byte array in base64.",
    ],
    source: {
      imagery: "Esri World Imagery Wayback release 43291 (2026-10-29)",
      capture: "2026-05-26 Vantor, 0.34 m",
      tiles: { z: mosaic.meta.z, x: [mosaic.meta.X0, mosaic.meta.X0 + mosaic.meta.nx - 1], y: [mosaic.meta.Y0, mosaic.meta.Y0 + mosaic.meta.ny - 1] },
      checked: "2026-11-07",
    },
    grid: YBI_LAND_COVER_GRID,
    land_cells: landCells,
    layers: Object.fromEntries(YBI_LAND_COVER_LAYERS.map((name, k) => [name, deflateSync(layers[k], { level: 9 }).toString("base64")])),
  };
  const output = resolve(projectRoot, YBI_LAND_COVER_PATH);
  mkdirSync(dirname(output), { recursive: true });
  writeFileSync(output, `${JSON.stringify(document, null, 1)}\n`);
  process.stdout.write(`${JSON.stringify({ output: YBI_LAND_COVER_PATH, land_cells: landCells })}\n`);
}

main();
