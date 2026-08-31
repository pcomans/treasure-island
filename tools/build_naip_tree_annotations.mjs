import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";

import { eastNorthToWorldRounded, inverseProjectEastNorth, projectLonLat } from "./lib/coordinates.mjs";

const ROOT = resolve(import.meta.dirname, "..");
const OUTPUT_ROOT = resolve(ROOT, "source_assets/vegetation/naip_2022");
const GENERATED_MANIFEST_PATH = resolve(ROOT, "generated/world/manifest.json");
const ANNOTATION_PATH = resolve(OUTPUT_ROOT, "tree_annotations_candidate.geojson");
const FOOTPRINT_PATH = resolve(OUTPUT_ROOT, "treasure_island_footprint.geojson");
const REVIEW_SVG_PATH = resolve(OUTPUT_ROOT, "tree_annotations_review.svg");
const SUMMARY_PATH = resolve(OUTPUT_ROOT, "REVIEW_SUMMARY.md");
const REJECTION_AUDIT_PATH = resolve(OUTPUT_ROOT, "tree_annotations_rejection_audit.geojson");

const IMAGE = Object.freeze({
  width: 2370,
  height: 3181,
  bbox: [-122.3790725, 37.8151916, -122.3629075, 37.8323315],
  imageryDate: "2022-05-18",
  sourceImage: "third_party_staging/naip_2022_treasure_island/treasure_island_naip_2022-05-18.tif",
});

const TILE_COLUMNS = Object.freeze([
  Object.freeze({ x: 0, width: 593 }),
  Object.freeze({ x: 593, width: 592 }),
  Object.freeze({ x: 1185, width: 593 }),
  Object.freeze({ x: 1778, width: 592 }),
]);
const TILE_ROWS = Object.freeze([
  Object.freeze({ y: 0, height: 636 }),
  Object.freeze({ y: 636, height: 636 }),
  Object.freeze({ y: 1272, height: 637 }),
  Object.freeze({ y: 1909, height: 636 }),
  Object.freeze({ y: 2545, height: 636 }),
]);

const NOTE = Object.freeze({
  rounded: "Distinct rounded mature crown; center is visually clear.",
  row: "Deliberate evenly spaced row; crown center clear, coarse type uncertain.",
  shadow: "Visible crown is partly shadowed or overlapping; center is approximate.",
  isolated: "Isolated visible crown; form is clear but coarse type is uncertain.",
});

// Manually transcribed after inspecting all 20 lossless review tiles at original
// detail. Coordinates are integer pixel centers local to the named review cell.
// This list intentionally does not read generated/world/vegetation.json.
const MANUAL_CANDIDATES = [
  // tile-00: northwest shoreline corner
  [0, 489, 578, "broadleaf", "high", NOTE.rounded],
  [0, 414, 619, "broadleaf", "medium", NOTE.shadow],

  // tile-01: north spit and northern housing loop
  [1, 269, 367, "unknown", "medium", NOTE.isolated],
  [1, 230, 419, "broadleaf", "high", NOTE.rounded],
  [1, 218, 452, "broadleaf", "medium", NOTE.rounded],
  [1, 188, 482, "broadleaf", "high", NOTE.rounded],
  [1, 155, 500, "broadleaf", "high", NOTE.rounded],
  [1, 251, 493, "broadleaf", "high", NOTE.rounded],
  [1, 275, 537, "broadleaf", "high", NOTE.rounded],
  [1, 280, 560, "broadleaf", "high", NOTE.rounded],
  [1, 286, 589, "broadleaf", "high", NOTE.rounded],
  [1, 331, 549, "broadleaf", "high", NOTE.rounded],
  [1, 329, 577, "broadleaf", "medium", NOTE.shadow],
  [1, 334, 609, "broadleaf", "high", NOTE.rounded],
  [1, 522, 409, "broadleaf", "high", NOTE.rounded],
  [1, 563, 418, "broadleaf", "high", NOTE.rounded],
  [1, 452, 505, "unknown", "medium", NOTE.isolated],

  // tile-02: northeast utility shoreline
  [2, 160, 466, "broadleaf", "medium", NOTE.isolated],

  // tile-04: northwest residential blocks
  [4, 265, 76, "broadleaf", "high", NOTE.rounded],
  [4, 341, 87, "broadleaf", "medium", NOTE.rounded],
  [4, 245, 118, "broadleaf", "medium", NOTE.rounded],
  [4, 253, 153, "broadleaf", "medium", NOTE.rounded],
  [4, 360, 154, "broadleaf", "high", NOTE.rounded],
  [4, 443, 159, "broadleaf", "medium", NOTE.rounded],
  [4, 530, 230, "broadleaf", "high", NOTE.isolated],
  [4, 360, 219, "broadleaf", "medium", NOTE.rounded],
  [4, 315, 247, "broadleaf", "medium", NOTE.rounded],
  [4, 410, 298, "broadleaf", "high", NOTE.rounded],
  [4, 218, 302, "broadleaf", "high", NOTE.rounded],
  [4, 179, 309, "broadleaf", "high", NOTE.rounded],
  [4, 158, 326, "unknown", "medium", NOTE.shadow],
  [4, 270, 314, "broadleaf", "high", NOTE.rounded],
  [4, 328, 319, "broadleaf", "high", NOTE.rounded],
  [4, 382, 327, "broadleaf", "high", NOTE.rounded],
  [4, 437, 338, "broadleaf", "high", NOTE.rounded],
  [4, 346, 359, "broadleaf", "high", NOTE.rounded],
  [4, 270, 384, "broadleaf", "high", NOTE.rounded],
  [4, 477, 393, "broadleaf", "medium", NOTE.rounded],
  [4, 230, 416, "broadleaf", "medium", NOTE.rounded],
  [4, 387, 420, "broadleaf", "high", NOTE.rounded],
  [4, 471, 427, "broadleaf", "high", NOTE.rounded],
  [4, 528, 432, "broadleaf", "medium", NOTE.rounded],
  [4, 187, 513, "unknown", "medium", NOTE.isolated],
  [4, 382, 553, "broadleaf", "high", NOTE.rounded],
  [4, 471, 573, "broadleaf", "high", NOTE.rounded],
  [4, 551, 579, "broadleaf", "medium", NOTE.rounded],

  // tile-05: central-north neighborhoods and school edge
  [5, 282, 91, "broadleaf", "high", NOTE.rounded],
  [5, 362, 82, "broadleaf", "high", NOTE.rounded],
  [5, 523, 82, "broadleaf", "high", NOTE.rounded],
  [5, 314, 140, "broadleaf", "high", NOTE.rounded],
  [5, 522, 144, "broadleaf", "high", NOTE.rounded],
  [5, 268, 154, "broadleaf", "high", NOTE.rounded],
  [5, 406, 180, "broadleaf", "high", NOTE.rounded],
  [5, 559, 186, "unknown", "medium", NOTE.shadow],
  [5, 382, 239, "broadleaf", "high", NOTE.rounded],
  [5, 408, 280, "broadleaf", "high", NOTE.rounded],
  [5, 260, 285, "unknown", "medium", NOTE.row],
  [5, 28, 339, "unknown", "medium", NOTE.isolated],
  [5, 167, 362, "broadleaf", "high", NOTE.rounded],
  [5, 77, 386, "broadleaf", "high", NOTE.rounded],
  [5, 147, 404, "broadleaf", "high", NOTE.rounded],
  [5, 31, 432, "broadleaf", "medium", NOTE.rounded],
  [5, 77, 431, "broadleaf", "high", NOTE.rounded],
  [5, 180, 420, "broadleaf", "high", NOTE.rounded],
  [5, 58, 454, "broadleaf", "medium", NOTE.shadow],
  [5, 186, 460, "broadleaf", "high", NOTE.rounded],
  [5, 52, 490, "broadleaf", "high", NOTE.rounded],
  [5, 194, 493, "broadleaf", "high", NOTE.rounded],
  [5, 235, 510, "broadleaf", "medium", NOTE.rounded],
  [5, 69, 553, "broadleaf", "high", NOTE.rounded],
  [5, 88, 598, "broadleaf", "medium", NOTE.shadow],
  [5, 181, 574, "broadleaf", "high", NOTE.rounded],
  [5, 210, 584, "broadleaf", "medium", NOTE.shadow],

  // tile-06: construction edge, sparse lawn, and interior tree rows
  [6, 253, 281, "broadleaf", "high", NOTE.isolated],
  [6, 277, 335, "broadleaf", "high", NOTE.rounded],
  [6, 329, 388, "unknown", "low", NOTE.shadow],
  [6, 436, 461, "broadleaf", "high", NOTE.rounded],
  [6, 456, 475, "unknown", "medium", NOTE.row],
  [6, 468, 496, "unknown", "medium", NOTE.row],
  [6, 471, 520, "unknown", "medium", NOTE.row],
  [6, 496, 543, "unknown", "medium", NOTE.row],
  [6, 507, 574, "unknown", "medium", NOTE.row],
  [6, 281, 556, "broadleaf", "medium", NOTE.rounded],
  [6, 329, 560, "broadleaf", "high", NOTE.rounded],
  [6, 372, 597, "broadleaf", "high", NOTE.rounded],
  [6, 62, 319, "unknown", "medium", NOTE.row],
  [6, 83, 372, "unknown", "medium", NOTE.row],

  // tile-07: deliberate eastern shoreline row
  [7, 62, 375, "unknown", "medium", NOTE.row],
  [7, 71, 393, "unknown", "medium", NOTE.row],
  [7, 82, 410, "unknown", "medium", NOTE.row],
  [7, 90, 429, "unknown", "medium", NOTE.row],
  [7, 101, 448, "unknown", "medium", NOTE.row],
  [7, 112, 467, "unknown", "medium", NOTE.row],
  [7, 122, 485, "unknown", "medium", NOTE.row],
  [7, 132, 505, "unknown", "medium", NOTE.row],
  [7, 146, 525, "unknown", "medium", NOTE.row],
  [7, 159, 544, "unknown", "medium", NOTE.row],
  [7, 175, 564, "unknown", "medium", NOTE.row],
  [7, 190, 584, "unknown", "medium", NOTE.row],
  [7, 205, 603, "unknown", "medium", NOTE.row],
  [7, 220, 624, "unknown", "medium", NOTE.row],

  // tile-08: southwest residential blocks and park edge
  [8, 333, 59, "broadleaf", "medium", NOTE.rounded],
  [8, 350, 99, "broadleaf", "medium", NOTE.rounded],
  [8, 313, 140, "broadleaf", "high", NOTE.rounded],
  [8, 402, 97, "broadleaf", "high", NOTE.rounded],
  [8, 492, 120, "broadleaf", "high", NOTE.rounded],
  [8, 491, 173, "broadleaf", "high", NOTE.rounded],
  [8, 540, 199, "unknown", "medium", NOTE.shadow],
  [8, 561, 247, "broadleaf", "medium", NOTE.rounded],
  [8, 334, 215, "broadleaf", "medium", NOTE.rounded],
  [8, 365, 247, "broadleaf", "high", NOTE.rounded],
  [8, 421, 258, "broadleaf", "medium", NOTE.rounded],
  [8, 492, 277, "broadleaf", "high", NOTE.rounded],
  [8, 356, 289, "unknown", "medium", NOTE.shadow],
  [8, 388, 340, "broadleaf", "high", NOTE.rounded],
  [8, 425, 342, "broadleaf", "high", NOTE.rounded],
  [8, 478, 352, "broadleaf", "medium", NOTE.rounded],
  [8, 405, 394, "broadleaf", "high", NOTE.rounded],
  [8, 434, 389, "broadleaf", "medium", NOTE.shadow],

  // tile-09: central-west mature neighborhood trees
  [9, 26, 40, "broadleaf", "medium", NOTE.rounded],
  [9, 64, 44, "broadleaf", "high", NOTE.rounded],
  [9, 145, 29, "broadleaf", "high", NOTE.rounded],
  [9, 169, 45, "broadleaf", "medium", NOTE.shadow],
  [9, 240, 148, "broadleaf", "high", NOTE.rounded],
  [9, 267, 146, "broadleaf", "high", NOTE.rounded],
  [9, 89, 174, "broadleaf", "high", NOTE.rounded],
  [9, 46, 256, "broadleaf", "high", NOTE.rounded],
  [9, 80, 257, "broadleaf", "medium", NOTE.rounded],
  [9, 145, 235, "broadleaf", "medium", NOTE.rounded],
  [9, 183, 245, "broadleaf", "high", NOTE.rounded],
  [9, 241, 240, "broadleaf", "high", NOTE.rounded],
  [9, 296, 213, "broadleaf", "medium", NOTE.rounded],
  [9, 13, 337, "broadleaf", "medium", NOTE.shadow],
  [9, 146, 324, "broadleaf", "high", NOTE.rounded],
  [9, 241, 294, "broadleaf", "high", NOTE.rounded],
  [9, 231, 371, "broadleaf", "high", NOTE.rounded],
  [9, 307, 300, "unknown", "medium", NOTE.isolated],
  [9, 240, 533, "broadleaf", "medium", NOTE.shadow],
  [9, 188, 556, "broadleaf", "high", NOTE.rounded],

  // tile-10: sparse central and southeastern interior trees
  [10, 47, 12, "broadleaf", "medium", NOTE.shadow],
  [10, 77, 40, "broadleaf", "high", NOTE.rounded],
  [10, 198, 65, "broadleaf", "high", NOTE.rounded],
  [10, 210, 102, "broadleaf", "medium", NOTE.shadow],
  [10, 134, 163, "unknown", "medium", NOTE.isolated],
  [10, 157, 206, "unknown", "medium", NOTE.isolated],
  [10, 266, 238, "unknown", "medium", NOTE.row],
  [10, 272, 283, "unknown", "medium", NOTE.row],
  [10, 286, 317, "unknown", "medium", NOTE.row],
  [10, 374, 297, "broadleaf", "medium", NOTE.isolated],
  [10, 409, 500, "broadleaf", "medium", NOTE.rounded],
  [10, 443, 553, "broadleaf", "medium", NOTE.rounded],
  [10, 470, 571, "unknown", "medium", NOTE.shadow],
  [10, 320, 574, "broadleaf", "high", NOTE.rounded],

  // tile-11: eastern waterfront rows; visually distinct, coarse form uncertain
  [11, 281, 25, "unknown", "medium", NOTE.row],
  [11, 293, 47, "unknown", "medium", NOTE.row],
  [11, 305, 70, "unknown", "medium", NOTE.row],
  [11, 317, 91, "unknown", "medium", NOTE.row],
  [11, 329, 115, "unknown", "medium", NOTE.row],
  [11, 341, 137, "unknown", "medium", NOTE.row],
  [11, 352, 161, "unknown", "medium", NOTE.row],
  [11, 365, 183, "unknown", "medium", NOTE.row],
  [11, 376, 207, "unknown", "medium", NOTE.row],
  [11, 390, 229, "unknown", "medium", NOTE.row],
  [11, 402, 253, "unknown", "medium", NOTE.row],
  [11, 415, 276, "unknown", "medium", NOTE.row],
  [11, 428, 299, "unknown", "medium", NOTE.row],
  [11, 440, 322, "unknown", "medium", NOTE.row],
  [11, 454, 344, "unknown", "medium", NOTE.row],
  [11, 468, 365, "unknown", "medium", NOTE.row],
  [11, 483, 389, "unknown", "medium", NOTE.row],
  [11, 497, 411, "unknown", "medium", NOTE.row],
  [11, 512, 434, "unknown", "medium", NOTE.row],
  [11, 528, 455, "unknown", "medium", NOTE.row],
  [11, 77, 178, "unknown", "medium", NOTE.row],
  [11, 81, 203, "unknown", "medium", NOTE.row],
  [11, 84, 229, "unknown", "medium", NOTE.row],
  [11, 88, 253, "unknown", "medium", NOTE.row],
  [11, 92, 277, "unknown", "medium", NOTE.row],
  [11, 97, 302, "unknown", "medium", NOTE.row],
  [11, 103, 325, "unknown", "medium", NOTE.row],
  [11, 107, 349, "unknown", "medium", NOTE.row],

  // tile-14: mature south-central grove fragments retained around construction
  [14, 121, 21, "broadleaf", "high", NOTE.rounded],
  [14, 164, 30, "broadleaf", "medium", NOTE.shadow],
  [14, 225, 7, "broadleaf", "medium", NOTE.shadow],
  [14, 356, 18, "unknown", "medium", NOTE.isolated],
  [14, 253, 40, "broadleaf", "high", NOTE.rounded],
  [14, 302, 47, "broadleaf", "medium", NOTE.rounded],
  [14, 477, 49, "broadleaf", "high", NOTE.rounded],
  [14, 545, 38, "broadleaf", "medium", NOTE.shadow],
  [14, 234, 111, "broadleaf", "high", NOTE.rounded],
  [14, 285, 126, "broadleaf", "medium", NOTE.rounded],
  [14, 335, 117, "unknown", "medium", NOTE.isolated],
  [14, 92, 181, "broadleaf", "high", NOTE.rounded],
  [14, 139, 184, "broadleaf", "medium", NOTE.shadow],
  [14, 184, 201, "broadleaf", "high", NOTE.rounded],
  [14, 217, 203, "broadleaf", "medium", NOTE.shadow],
  [14, 248, 190, "broadleaf", "high", NOTE.rounded],
  [14, 275, 184, "broadleaf", "high", NOTE.rounded],
  [14, 296, 186, "broadleaf", "medium", NOTE.shadow],
  [14, 12, 211, "unknown", "medium", NOTE.shadow],
  [14, 47, 214, "broadleaf", "medium", NOTE.rounded],
  [14, 95, 236, "broadleaf", "high", NOTE.rounded],
  [14, 129, 250, "broadleaf", "medium", NOTE.shadow],
  [14, 152, 283, "broadleaf", "high", NOTE.rounded],
  [14, 176, 309, "broadleaf", "medium", NOTE.shadow],
  [14, 205, 318, "broadleaf", "high", NOTE.rounded],
  [14, 89, 345, "broadleaf", "medium", NOTE.rounded],
  [14, 62, 389, "broadleaf", "high", NOTE.rounded],
  [14, 95, 414, "broadleaf", "medium", NOTE.shadow],
  [14, 124, 426, "broadleaf", "high", NOTE.rounded],
  [14, 150, 406, "broadleaf", "high", NOTE.rounded],
  [14, 181, 390, "broadleaf", "medium", NOTE.shadow],
  [14, 205, 401, "broadleaf", "high", NOTE.rounded],
];

// Deliberately curated down from the full manual transcription to a hobby-scale
// representative set of clear mature crowns and repeated-row members. This is
// an explicit review selection, not an automatic detector or generated-world
// vegetation sample.
const SELECTED_PIXEL_KEYS = new Set([
  "0:489,578",
  "1:230,419", "1:218,452", "1:188,482", "1:155,500", "1:251,493",
  "1:275,537", "1:280,560", "1:286,589", "1:522,409", "1:563,418",
  "4:265,76", "4:341,87", "4:245,118", "4:360,154", "4:443,159", "4:530,230",
  "4:410,298", "4:218,302", "4:179,309", "4:270,314", "4:328,319", "4:382,327",
  "4:437,338", "4:346,359", "4:270,384", "4:387,420", "4:471,427", "4:382,553",
  "5:282,91", "5:362,82", "5:523,82", "5:314,140", "5:522,144", "5:268,154",
  "5:406,180", "5:382,239", "5:408,280", "5:167,362", "5:77,386", "5:147,404",
  "5:77,431", "5:180,420", "5:194,493", "5:181,574",
  "6:253,281", "6:277,335", "6:436,461", "6:281,556", "6:329,560", "6:372,597",
  "7:62,375", "7:82,410", "7:101,448", "7:122,485", "7:146,525",
  "7:159,544", "7:175,564", "7:190,584", "7:205,603", "7:220,624",
  "8:333,59", "8:350,99", "8:313,140", "8:402,97", "8:492,120",
  "8:491,173", "8:365,247", "8:492,277", "8:388,340", "8:405,394",
  "9:26,40", "9:64,44", "9:145,29", "9:240,148", "9:267,146",
  "9:89,174", "9:46,256", "9:183,245", "9:146,324", "9:188,556",
  "10:77,40", "10:198,65", "10:266,238", "10:374,297", "10:320,574",
  "11:281,25", "11:305,70", "11:329,115", "11:352,161", "11:376,207",
  "11:402,253", "11:428,299", "11:454,344", "11:483,389", "11:512,434",
  "11:77,178", "11:97,302",
  "14:121,21", "14:253,40", "14:477,49", "14:234,111", "14:92,181", "14:184,201",
  "14:248,190", "14:95,236", "14:152,283", "14:205,318", "14:62,389", "14:124,426",
]);

// Exact crown-center pixels rejected by the independent world-surface check.
// Several real crowns overhang frozen OSM roads/roofs; those are unsuitable as
// unambiguous placement candidates even though the imagery mark itself is real.
const SURFACE_REJECTIONS = Object.freeze([
  [1115, 409, "road_path", "roads:x_-1__z_-3"],
  [844, 493, "road_path", "roads:x_-1__z_-3"],
  [879, 589, "road_path", "roads:x_-1__z_-3"],
  [265, 712, "building_roof", "building:w96665892:roof"],
  [875, 727, "building_roof", "building:w96698627:roof"],
  [245, 754, "building_roof", "building:w96665907:roof"],
  [360, 790, "building_roof", "building:w96665885:roof"],
  [218, 938, "road_path", "roads:x_-3__z_-2"],
  [328, 955, "building_roof", "building:w96665921:roof"],
  [382, 963, "building_roof", "building:w96665921:roof"],
  [760, 998, "building_roof", "building:w34313556:roof"],
  [740, 1040, "road_path", "roads:x_-2__z_-2"],
  [670, 1067, "building_roof", "building:w95934101:roof"],
  [1514, 1196, "road_path", "roads:x_0__z_-1"],
  [774, 1210, "road_path", "roads:x_-1__z_-1"],
  [657, 1316, "building_roof", "building:w95934122:roof"],
  [333, 1331, "building_roof", "building:w96215655:roof"],
  [402, 1369, "building_roof", "building:w95934116:roof"],
  [313, 1412, "road_path", "roads:x_-3__z_-1"],
  [860, 1418, "road_path", "roads:x_-1__z_-1"],
  [833, 1420, "building_roof", "building:w96665886:roof"],
  [682, 1446, "road_path", "roads:x_-2__z_-1"],
  [776, 1517, "road_path", "roads:x_-1__z_-1"],
  [365, 1519, "road_path", "roads:x_-2__z_-1"],
  [492, 1549, "road_path", "roads:x_-2__z_-1"],
  [2290, 1706, "road_path", "roads:x_2__z_0"],
  [1438, 1949, "building_roof", "building:w34313513:roof"],
  [1280, 2145, "road_path", "roads:x_0__z_1"],
  [1337, 2192, "building_roof", "building:w34313544:roof"],
  [1309, 2335, "building_roof", "building:w291189926:roof"],
]);
const SURFACE_REJECT_GLOBAL_PIXEL_KEYS = new Set(SURFACE_REJECTIONS.map(([x, y]) => `${x},${y}`));

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function round(value, places) {
  const scale = 10 ** places;
  return Math.round((value + Number.EPSILON) * scale) / scale;
}

function tileDescriptor(tileIndex) {
  assert(Number.isInteger(tileIndex) && tileIndex >= 0 && tileIndex < 20, `Invalid tile ${tileIndex}`);
  const row = Math.floor(tileIndex / 4);
  const column = tileIndex % 4;
  return {
    id: `tile-${String(tileIndex).padStart(2, "0")}`,
    ...TILE_COLUMNS[column],
    y: TILE_ROWS[row].y,
    height: TILE_ROWS[row].height,
  };
}

function pixelToLonLat(x, y) {
  const [west, south, east, north] = IMAGE.bbox;
  return [
    round(west + ((x + 0.5) / IMAGE.width) * (east - west), 8),
    round(north - ((y + 0.5) / IMAGE.height) * (north - south), 8),
  ];
}

function stableId(x, y) {
  return `ti-naip-20220518-px${String(x).padStart(4, "0")}-py${String(y).padStart(4, "0")}`;
}

function featureFor(candidate) {
  const [tileIndex, localX, localY, treeType, confidence, notes] = candidate;
  const tile = tileDescriptor(tileIndex);
  assert(Number.isInteger(localX) && localX >= 0 && localX < tile.width, `${tile.id} local x outside tile`);
  assert(Number.isInteger(localY) && localY >= 0 && localY < tile.height, `${tile.id} local y outside tile`);
  const x = tile.x + localX;
  const y = tile.y + localY;
  const coordinate = pixelToLonLat(x, y);
  const worldPosition = eastNorthToWorldRounded(projectLonLat(coordinate));
  return {
    type: "Feature",
    id: stableId(x, y),
    geometry: { type: "Point", coordinates: coordinate },
    properties: {
      id: stableId(x, y),
      tree_type: treeType,
      confidence,
      imagery_date: IMAGE.imageryDate,
      source_cell: tile.id,
      source_pixel_xy: [x, y],
      cell_pixel_xy: [localX, localY],
      world_position_m: worldPosition,
      evidence: notes,
      review_status: "candidate",
    },
  };
}

function canonicalFeatures() {
  const selected = MANUAL_CANDIDATES.filter(([tileIndex, x, y]) => SELECTED_PIXEL_KEYS.has(`${tileIndex}:${x},${y}`));
  assert(selected.length === SELECTED_PIXEL_KEYS.size, "A selected manual pixel key is missing from the transcription");
  assert(selected.length === 110, `Expected 110 hobby-scale candidates, found ${selected.length}`);
  const surfaceScreened = selected.map(featureFor).filter((feature) => {
    const [x, y] = feature.properties.source_pixel_xy;
    return !SURFACE_REJECT_GLOBAL_PIXEL_KEYS.has(`${x},${y}`);
  });
  assert(surfaceScreened.length === 80, `Expected 80 surface-screened candidates, found ${surfaceScreened.length}`);
  return surfaceScreened.sort((left, right) => {
    const [lx, ly] = left.properties.source_pixel_xy;
    const [rx, ry] = right.properties.source_pixel_xy;
    return ly - ry || lx - rx || left.id.localeCompare(right.id);
  });
}

function rejectionFeatures() {
  const manualById = new Map(MANUAL_CANDIDATES.map(featureFor).map((feature) => [feature.id, feature]));
  return SURFACE_REJECTIONS.map(([x, y, featureKind, objectKey]) => {
    const id = stableId(x, y);
    const source = manualById.get(id);
    assert(source, `Surface rejection ${id} is absent from manual transcription`);
    return {
      ...source,
      properties: {
        ...source.properties,
        review_status: "rejected",
        rejection_reason: "intersects_existing_serialized_road_or_building_surface",
        intersected_feature_kind: featureKind,
        intersected_object_key: objectKey,
        decision: "omit_without_snapping",
      },
    };
  }).sort((left, right) => {
    const [lx, ly] = left.properties.source_pixel_xy;
    const [rx, ry] = right.properties.source_pixel_xy;
    return ly - ry || lx - rx || left.id.localeCompare(right.id);
  });
}

function boundaryFeature() {
  const manifest = JSON.parse(readFileSync(GENERATED_MANIFEST_PATH, "utf8"));
  const components = manifest.playable_boundary?.components;
  assert(Array.isArray(components) && components.length === 1, "Generated Treasure Island playable boundary is missing");
  const toWgs84Ring = (ring) => ring.map(([worldX, worldZ]) => inverseProjectEastNorth([worldX, -worldZ]).map((value) => round(value, 8)));
  const geometry = {
    type: "MultiPolygon",
    coordinates: components.map((component) => [
      toWgs84Ring(component.outer),
      ...component.holes.map(toWgs84Ring),
    ]),
  };
  return {
    type: "Feature",
    id: "treasure-island-frozen-osm-boundary",
    geometry,
    properties: {
      name: "Treasure Island",
      role: "annotation_footprint",
      source: "generated/world/manifest.json#playable_boundary",
      source_key: manifest.boundary_source_key,
      derivation: "Existing generated +X-east/-Z-north boundary converted with tools/lib/coordinates.mjs inverseProjectEastNorth",
    },
  };
}

function countsFor(features, key, values) {
  const counts = Object.fromEntries(values.map((value) => [value, 0]));
  for (const feature of features) counts[feature.properties[key]] += 1;
  return counts;
}

function renderSvg(features, boundary) {
  const width = 1000;
  const height = 1180;
  const plot = { x: 55, y: 120, width: 680, height: 980 };
  const [west, south, east, north] = IMAGE.bbox;
  const map = ([longitude, latitude]) => [
    plot.x + ((longitude - west) / (east - west)) * plot.width,
    plot.y + ((north - latitude) / (north - south)) * plot.height,
  ];
  const ringPath = (ring) => ring.map((coordinate, index) => {
    const [x, y] = map(coordinate);
    return `${index === 0 ? "M" : "L"}${round(x, 2)},${round(y, 2)}`;
  }).join(" ") + " Z";
  const boundaryPath = boundary.geometry.coordinates.flatMap((polygon) => polygon.map(ringPath)).join(" ");
  const colors = { palm: "#e78f2f", conifer: "#176b45", broadleaf: "#59a14f", unknown: "#8b6fb3" };
  const radii = { high: 4.4, medium: 3.5, low: 2.8 };
  const circles = features.map((feature) => {
    const [x, y] = map(feature.geometry.coordinates);
    const { tree_type: treeType, confidence } = feature.properties;
    return `<circle cx="${round(x, 2)}" cy="${round(y, 2)}" r="${radii[confidence]}" fill="${colors[treeType]}" fill-opacity=".88" stroke="#fff" stroke-width=".7"/>`;
  }).join("\n    ");
  const typeCounts = countsFor(features, "tree_type", ["palm", "conifer", "broadleaf", "unknown"]);
  const confidenceCounts = countsFor(features, "confidence", ["high", "medium", "low"]);
  const legend = Object.entries(colors).map(([label, color], index) => `<circle cx="790" cy="${190 + index * 30}" r="6" fill="${color}"/><text x="806" y="${195 + index * 30}">${label}: ${typeCounts[label]}</text>`).join("\n    ");
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="title desc">
  <title id="title">Treasure Island 2022 NAIP tree annotation candidates</title>
  <desc id="desc">Frozen Treasure Island boundary with ${features.length} manually marked candidate tree centers colored by coarse crown type. No Yerba Buena Island annotations.</desc>
  <style>text{font-family:Arial,sans-serif;fill:#263238}.title{font-size:24px;font-weight:700}.subtitle{font-size:14px;fill:#546e7a}.label{font-size:13px}.small{font-size:11px;fill:#607d8b}</style>
  <rect width="1000" height="1180" fill="#f7f5ef"/>
  <text x="55" y="48" class="title">Treasure Island — NAIP 2022 candidate tree centers</text>
  <text x="55" y="76" class="subtitle">Manual natural-color review · imagery 2022-05-18 · candidate data only · north up</text>
  <path d="${boundaryPath}" fill="#e7e1cf" fill-rule="evenodd" stroke="#263238" stroke-width="2"/>
  <g>${circles}</g>
  <path d="M730,120 l0,980" stroke="#c7c2b7"/>
  <text x="770" y="145" font-size="17" font-weight="700">${features.length} candidates</text>
  <text x="770" y="170" class="small">Color = coarse crown type</text>
  ${legend}
  <text x="770" y="345" class="label">Confidence</text>
  <text x="790" y="372" class="label">high: ${confidenceCounts.high}</text>
  <text x="790" y="397" class="label">medium: ${confidenceCounts.medium}</text>
  <text x="790" y="422" class="label">low: ${confidenceCounts.low}</text>
  <text x="770" y="480" class="label">Scope</text>
  <text x="790" y="507" class="small">Treasure Island only</text>
  <text x="790" y="529" class="small">YBI candidates: 0</text>
  <text x="770" y="580" class="label">Limits</text>
  <text x="790" y="607" class="small">2022 canopy state</text>
  <text x="790" y="629" class="small">crown, not surveyed trunk</text>
  <text x="790" y="651" class="small">species not inferred</text>
  <text x="790" y="673" class="small">shrubs omitted</text>
  <g transform="translate(680 102)"><path d="M0,0 l8,18 h-16 z" fill="#263238"/><text x="0" y="-7" text-anchor="middle" class="small">N</text></g>
  <text x="55" y="1135" class="small">Imagery: USDA FSA NAIP, acquired 2022-05-18; served by USGS The National Map. Boundary: existing generated-world manifest.</text>
</svg>\n`;
}

function summaryMarkdown(features) {
  const types = countsFor(features, "tree_type", ["palm", "conifer", "broadleaf", "unknown"]);
  const confidence = countsFor(features, "confidence", ["high", "medium", "low"]);
  const cells = countsFor(features, "source_cell", Array.from({ length: 20 }, (_, index) => `tile-${String(index).padStart(2, "0")}`));
  const cellRows = Object.entries(cells).map(([cell, count]) => `| ${cell} | ${count} |`).join("\n");
  return `# NAIP 2022 tree annotation candidate review

This is a review-only, hobby-scale candidate inventory of ${features.length} visually distinct mature tree crowns and deliberate rows on Treasure Island. It is source data, not generated-world or runtime placement data.

## Counts

| Coarse type | Count |
| --- | ---: |
| palm | ${types.palm} |
| conifer | ${types.conifer} |
| broadleaf | ${types.broadleaf} |
| unknown | ${types.unknown} |

| Confidence | Count |
| --- | ---: |
| high | ${confidence.high} |
| medium | ${confidence.medium} |
| low | ${confidence.low} |

| Review cell | Candidates |
| --- | ---: |
${cellRows}

## Method

- Inspected every one of the 20 lossless review cells at original detail.
- Marked integer crown-center pixels manually; GeoJSON positions are deterministic pixel-to-WGS84 conversions over the exact export bbox.
- Used only 'palm', 'conifer', 'broadleaf', or 'unknown'. Rounded, visually clear mature crowns are 'broadleaf'; small or ambiguous forms are 'unknown'. No crown was strong enough in this natural-color crop to label palm or conifer without overclaiming.
- Omitted shrubs, ornamental grasses, tiny seedlings, hidden crowns, and most ambiguous canopy fragments.
- Did not consult or copy current generated vegetation placements.

## Limitations

- The imagery is a snapshot from 2022-05-18 and does not establish current 2026 presence.
- Points estimate visible crown centers, not surveyed trunk positions. Tall crowns may be displaced by view geometry, and overlapping canopy/shadow lowers confidence.
- Natural-color 0.6 m imagery is suitable for coarse crown form, not botanical species identification. Zero palm/conifer labels means “not safely distinguished here,” not “absent from the island.”
- Construction, demolition, leaf condition, building shadow, and the western source seam can hide trees.
- This candidate set prioritizes mature, visually distinct crowns and repeated rows; it is deliberately incomplete.
- The separate validator proves containment and rejects point intersections with the existing world’s serialized road and building surfaces. That is a consistency screen, not a claim that the frozen OSM inventory exactly matches the 2022 photo.
- Thirty otherwise visible-crown marks that intersected those surfaces were omitted without snapping; their original IDs and exact rejection evidence remain in 'tree_annotations_rejection_audit.geojson'.

## Files

- 'tree_annotations_candidate.geojson': canonical, deterministically sorted candidate points.
- 'treasure_island_footprint.geojson': existing generated-world Treasure Island boundary converted to WGS84; no YBI polygon.
- 'tree_annotations_review.svg' and 'tree_annotations_review.png': visual review aids.
- 'tree_annotations_rejection_audit.geojson': 30 omitted marks with exact surface-intersection reasons; not accepted candidates.
- 'validation_report.json': persisted result from the independent deterministic validator.
- 'naip_vs_generated_vegetation_review.svg' and '.png': post-acceptance source comparison; never annotation or runtime input.
- Staged source imagery and review cells: 'third_party_staging/naip_2022_treasure_island/' (export-excluded).
`;
}

const features = canonicalFeatures();
const rejectedFeatures = rejectionFeatures();
const boundary = boundaryFeature();
mkdirSync(OUTPUT_ROOT, { recursive: true });

const annotations = {
  type: "FeatureCollection",
  schema: "ti.naip-tree-annotations-candidate/1",
  name: "Treasure Island NAIP 2022 tree annotation candidates",
  crs: { type: "name", properties: { name: "urn:ogc:def:crs:OGC:1.3:CRS84" } },
  source: {
    imagery_date: IMAGE.imageryDate,
    source_image: IMAGE.sourceImage,
    source_bbox_wgs84: IMAGE.bbox,
    source_dimensions_px: [IMAGE.width, IMAGE.height],
    pixel_coordinate_rule: "integer crown-center pixel; WGS84 uses pixel-center interpolation over export bbox",
    attribution: "Imagery: USDA Farm Service Agency NAIP, acquired 2022-05-18; served by USGS The National Map.",
  },
  review_status: "candidate",
  features,
};
const footprint = {
  type: "FeatureCollection",
  schema: "ti.annotation-footprint/1",
  name: "Treasure Island annotation footprint",
  features: [boundary],
};
const rejectionAudit = {
  type: "FeatureCollection",
  schema: "ti.naip-tree-annotation-rejections/1",
  name: "Treasure Island NAIP 2022 tree annotation rejection audit",
  review_status: "rejected",
  policy: "Preserve original mark and ID; omit from accepted candidates; do not snap or loosen the road/building invariant.",
  features: rejectedFeatures,
};

writeFileSync(ANNOTATION_PATH, `${JSON.stringify(annotations, null, 2)}\n`);
writeFileSync(FOOTPRINT_PATH, `${JSON.stringify(footprint, null, 2)}\n`);
writeFileSync(REJECTION_AUDIT_PATH, `${JSON.stringify(rejectionAudit, null, 2)}\n`);
writeFileSync(REVIEW_SVG_PATH, renderSvg(features, boundary));
writeFileSync(SUMMARY_PATH, summaryMarkdown(features));

process.stdout.write(`${JSON.stringify({
  annotations: ANNOTATION_PATH,
  footprint: FOOTPRINT_PATH,
  rejection_audit: REJECTION_AUDIT_PATH,
  review_svg: REVIEW_SVG_PATH,
  summary: SUMMARY_PATH,
  candidates: features.length,
  rejected_surface_intersections: rejectedFeatures.length,
  types: countsFor(features, "tree_type", ["palm", "conifer", "broadleaf", "unknown"]),
  confidence: countsFor(features, "confidence", ["high", "medium", "low"]),
}, null, 2)}\n`);
