import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

import { inverseProjectEastNorth } from "./lib/coordinates.mjs";

const ROOT = resolve(import.meta.dirname, "..");
const SOURCE_ROOT = resolve(ROOT, "source_assets/vegetation/naip_2022");
const CANDIDATE_PATH = resolve(SOURCE_ROOT, "tree_annotations_candidate.geojson");
const FOOTPRINT_PATH = resolve(SOURCE_ROOT, "treasure_island_footprint.geojson");
const GENERATED_PATH = resolve(ROOT, "generated/world/vegetation.json");
const OUTPUT_PATH = resolve(SOURCE_ROOT, "naip_vs_generated_vegetation_review.svg");
const BBOX = [-122.3790725, 37.8151916, -122.3629075, 37.8323315];

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function round(value) {
  return Math.round((value + Number.EPSILON) * 100) / 100;
}

const candidates = JSON.parse(readFileSync(CANDIDATE_PATH, "utf8"));
const footprint = JSON.parse(readFileSync(FOOTPRINT_PATH, "utf8"));
const generated = JSON.parse(readFileSync(GENERATED_PATH, "utf8"));
assert(candidates.features.length === 80, "Expected 80 accepted NAIP candidates");
assert(generated.placements.length === 102, "Expected 102 current generated vegetation placements");
assert(footprint.features.length === 1 && footprint.features[0].geometry.type === "MultiPolygon", "Missing TI footprint");

const generatedCoordinates = generated.placements.map((placement) => {
  const [east, , worldZ] = placement.position_m;
  assert(Number.isFinite(east) && Number.isFinite(worldZ), `${placement.id} has invalid world coordinates`);
  return inverseProjectEastNorth([east, -worldZ]);
});
const generatedInsideSourceBbox = generatedCoordinates.filter(([longitude, latitude]) =>
  longitude >= BBOX[0] && longitude <= BBOX[2] && latitude >= BBOX[1] && latitude <= BBOX[3]);
assert(generatedInsideSourceBbox.length === 102, `Expected all 102 generated placements inside source bbox, found ${generatedInsideSourceBbox.length}`);

const width = 1060;
const height = 790;
const panel = { y: 135, width: 390, height: 560 };
const panelXs = [85, 585];
const [west, south, east, north] = BBOX;
const map = (coordinate, panelX) => [
  panelX + ((coordinate[0] - west) / (east - west)) * panel.width,
  panel.y + ((north - coordinate[1]) / (north - south)) * panel.height,
];
const ringPath = (ring, panelX) => ring.map((coordinate, index) => {
  const [x, y] = map(coordinate, panelX);
  return `${index === 0 ? "M" : "L"}${round(x)},${round(y)}`;
}).join(" ") + " Z";
const boundaryPath = (panelX) => footprint.features[0].geometry.coordinates
  .flatMap((polygon) => polygon.map((ring) => ringPath(ring, panelX))).join(" ");
const candidateMarks = candidates.features.map((feature) => {
  const [x, y] = map(feature.geometry.coordinates, panelXs[0]);
  return `<circle cx="${round(x)}" cy="${round(y)}" r="3.8" fill="#318c61" fill-opacity=".9" stroke="#fff" stroke-width=".6"/>`;
}).join("\n    ");
const generatedMarks = generatedCoordinates.map((coordinate) => {
  const [x, y] = map(coordinate, panelXs[1]);
  assert(x >= panelXs[1] && x <= panelXs[1] + panel.width && y >= panel.y && y <= panel.y + panel.height, "Generated mark outside right plot frame");
  return `<rect x="${round(x - 3)}" y="${round(y - 3)}" width="6" height="6" rx=".8" fill="#db6f2b" fill-opacity=".9" stroke="#fff" stroke-width=".6"/>`;
}).join("\n    ");

const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="title desc">
  <title id="title">Current generated vegetation versus accepted NAIP candidate tree centers</title>
  <desc id="desc">Two north-up maps on the same frozen Treasure Island footprint. Left: 80 accepted NAIP 2022 candidate crown centers. Right: 102 current generated vegetation placements. Marks distinguish source, not species.</desc>
  <style>text{font-family:Arial,sans-serif;fill:#263238}.title{font-size:24px;font-weight:700}.subtitle{font-size:14px;fill:#546e7a}.panel-title{font-size:17px;font-weight:700}.small{font-size:11px;fill:#607d8b}</style>
  <rect width="${width}" height="${height}" fill="#f7f5ef"/>
  <text x="55" y="45" class="title">Vegetation source comparison — review only</text>
  <text x="55" y="73" class="subtitle">Identical north-up Treasure Island footprint · source distinguished, not species · no integration implied</text>
  <text x="${panelXs[0]}" y="112" class="panel-title">NAIP 2022 candidates — 80</text>
  <text x="${panelXs[1]}" y="112" class="panel-title">Current generated placements — 102</text>
  <path d="${boundaryPath(panelXs[0])}" fill="#e7e1cf" fill-rule="evenodd" stroke="#263238" stroke-width="1.8"/>
  <path d="${boundaryPath(panelXs[1])}" fill="#e7e1cf" fill-rule="evenodd" stroke="#263238" stroke-width="1.8"/>
  <g>${candidateMarks}</g>
  <g>${generatedMarks}</g>
  <g transform="translate(447 119)"><path d="M0,0 l7,16 h-14 z" fill="#263238"/><text x="0" y="-6" text-anchor="middle" class="small">N</text></g>
  <g transform="translate(947 119)"><path d="M0,0 l7,16 h-14 z" fill="#263238"/><text x="0" y="-6" text-anchor="middle" class="small">N</text></g>
  <circle cx="85" cy="733" r="5" fill="#318c61"/><text x="99" y="738" class="small">accepted manual crown-center candidate</text>
  <rect x="586" y="728" width="9" height="9" rx="1" fill="#db6f2b"/><text x="604" y="738" class="small">current deterministic generated placement</text>
  <text x="55" y="770" class="small">This comparison was produced after annotation acceptance and is not an input to the candidate set. Runtime/generated data is unchanged.</text>
</svg>\n`;

writeFileSync(OUTPUT_PATH, svg);
process.stdout.write(`${JSON.stringify({
  status: "rendered",
  output: OUTPUT_PATH,
  naip_candidates: candidates.features.length,
  generated_placements: generated.placements.length,
  generated_marks_inside_right_plot_frame: generatedInsideSourceBbox.length,
  footprint: "Treasure Island",
  orientation: "north-up",
}, null, 2)}\n`);
