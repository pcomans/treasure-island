// Shoreline riprap: the rock armour around the island edge, for the segments
// and closures in tools/config/shoreline.json. Always-on scenery, not a
// switchable street-detail layer.
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
//      that continues the verge's ground cover, an underlay behind it that
//      rises into the crest's core and falls to under the water, and angular
//      quarry stones over them (a top row just beyond the outline and a back
//      row behind it on the crest, small stones in the shoulder, then the heap
//      down past the waterline, largest stones first), a few low cobbles set
//      in the band at the outline that the player walks over, weathered
//      driftwood lying in the stones, and rubble mounds standing out in the
//      water where a segment's breakwater runs out as a jetty.
// Segments that meet end to end join without a seam (one stone pile, one
// slope). Closures cover the rest of the outline: a concrete face from the
// land edge to below the water (a pier or platform edge), a boat ramp, or
// nothing where other scenery already closes the edge (the causeway's Yerba
// Buena context terrain, a narrow inlet the next segment fills). Together the
// segments and closures cover the whole outline, so the island edge never shows
// the void under the land.
//
// Where the outline doubles back across a narrow inlet (the OSM outline has a
// 0-9 m slit on the north-west shore), a cross-section meets the outline again
// before its toe: it is clamped there and falls to the land on the far side
// instead of to the water. A segment without crest rows (crest_rows false) is
// only the lower slope of a crest another segment builds: the far side's own
// seaward edge. The land between them is stone in the aerial: a rock ground
// (the flat breakwater overlay, drawn as rock) lies over the draped verge there.
// Bare parts of the underlay (a clamped section's fill, a capped end's face)
// are rock faces at the heap's apparent tone, not the dark gaps of a heap.
//
// The player is recovered as soon as it leaves the outline, so nothing beyond
// the outline needs collision. Every stone and log outside stays clear of the
// outline (the top row sets back by about the player's radius) and every cobble
// inside the band stays low enough to walk over; tools/validate_godot_world.mjs
// checks both.
//
// The document is compact: meshes and placements are quantized little-endian
// arrays in base64 strings (unpackShorelineRecord and unpackShorelineBatch
// below; their twins are in game/scripts/world/generated_world_contract.gd and
// game/scripts/world/shoreline_builder.gd). Stones carry no colour: the shader
// tints each one from its position.
//
// Plan geometry is east/north; placements use world x, y, z with z = -north.
// Every number in the config is production inference for game art (dated
// photos, the 2026-05-26 aerial and the USGS DEM), not survey data.

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

export const SHORELINE_SCHEMA = "ti.shoreline/4";
export const SHORELINE_CONFIG_SCHEMA = "ti.shoreline-config/2";
export const SHORELINE_CONFIG_PATH = "tools/config/shoreline.json";
// The riprap overlay inside the outline and the materials of the slope, the
// walls, the stones and the wood.
export const SHORELINE_OVERLAY_MATERIAL = "terrain_riprap";
export const SHORELINE_SLOPE_MATERIAL = "shoreline_riprap";
// The flat shoulder between the outline and the stones: the verge's ground
// cover, continued past the outline (its UVs are the land's, rebuilt from the
// positions when the record is unpacked).
export const SHORELINE_VERGE_MATERIAL = "shoreline_verge";
// Concrete closures: pier and platform faces, boat ramps.
export const SHORELINE_WALL_MATERIAL = "shoreline_wall";
// Rock faces that stand bare, with no heap on them: a capped end's face and the
// fill of a narrow inlet. The underlay's rock at the heap's apparent tone.
export const SHORELINE_FACE_MATERIAL = "shoreline_face";
export const SHORELINE_BOULDER_MATERIAL = "shoreline_boulder";
export const SHORELINE_DRIFTWOOD_MATERIAL = "shoreline_driftwood";
// The overlay's object key prefix: "<prefix>:<source key>:<chunk>".
export const SHORELINE_OVERLAY_PREFIX = "shoreline";
// Placement batches: cobbles inside the outline; the top row, the heap and the
// driftwood outside it.
export const SHORELINE_BANDS = Object.freeze(["cobble", "driftwood", "heap", "top"]);
// A stone tone: [brightness, warm share, dark share, pale share] (the shader's
// stone families; the rest are grey and olive), see riprap.gdshader.
export const SHORELINE_TONE_LENGTH = 4;
export const SHORELINE_PROTOTYPE_KINDS = Object.freeze(["boulder", "log", "plank"]);
// Record kinds (the object key's first part) and their materials.
export const SHORELINE_RECORD_MATERIALS = Object.freeze({
  "shoreline-face": SHORELINE_FACE_MATERIAL,
  "shoreline-slope": SHORELINE_SLOPE_MATERIAL,
  "shoreline-verge": SHORELINE_VERGE_MATERIAL,
  "shoreline-wall": SHORELINE_WALL_MATERIAL,
});
// What a closure builds: nothing (other scenery closes the edge), a concrete
// face, or a boat ramp.
export const SHORELINE_CLOSURE_KINDS = Object.freeze(["none", "ramp", "wall"]);
// Cobbles stand on walkable land with no collision: at most this far above it.
export const SHORELINE_COBBLE_MAX_TOP_M = 0.15;
// Stones and logs outside keep at least this far beyond the outline.
export const SHORELINE_OUTSIDE_CLEARANCE_M = 0.1;
// A rock ground lies this far over the draped band it covers (three draped
// layer steps, clear of any band lifted over another).
const SHORELINE_ROCK_LIFT_M = 0.006;
// The game's water plane (world_root.tscn ContextWorld/Water).
export const WATER_Y_M = -0.12;
// Quantization of the packed document. Positions (mesh vertices and placement
// origins) lie on a 2 mm world grid and are stored as uint16 steps from a
// per-record or per-batch origin; rotations are int16 quaternion components
// over 32767; stone sizes and log dimensions uint16 steps of 0.5 mm; record
// normals int8 over 127.
export const SHORELINE_POSITION_STEP_M = 0.002;
export const SHORELINE_SCALE_STEP_M = 0.0005;
export const SHORELINE_ROTATION_SCALE = 32767;
export const SHORELINE_NORMAL_SCALE = 127;
// How far the window around a segment reaches inland and out over the water.
const WINDOW_REACH_M = 40;
// Land vertices closer than this to the outline are land-edge breakpoints.
const EDGE_VERTEX_TOLERANCE_M = 0.003;
// Segments and closures must meet within this along the outline.
const JOINT_TOLERANCE_M = 0.05;
// A clamped cross-section narrower than this builds nothing.
const MINIMUM_CLAMP_WIDTH_M = 0.25;
// A mound's records and stone batches are its segment's sections from here on.
const MOUND_SECTION_BASE = 100;
// A capped end's last cross-section stands this far inside the segment, so
// it never lies along a closure face that juts out at the end (its grid
// points would sit on the outline and drop out).
const CAP_INSET_M = 0.05;
const MINIMUM_TRIANGLE_AREA_M2 = 1e-6;
const SAFE_ID = /^[a-z0-9_]+$/u;

const CONFIG_FIELDS = ["closure", "closures", "mounds", "notes", "overlay_bias_m", "rock_grounds", "schema_version", "seed", "segments", "slope", "stones", "structures", "tones"];
const ROCK_GROUND_FIELDS = ["id", "reason", "reference", "s_m", "source_key"];
const TONE_SETTINGS_FIELDS = ["blend_m", "palettes"];
const MOUND_FIELDS = ["centerline_xz", "crest_min_m", "crest_y_m", "gradient", "half_width_m", "id", "reason", "reference", "segment", "taper_m"];
const SLOPE_FIELDS = ["berm", "clamp_reach_m", "columns", "dem_fit_m", "end_cap_bottom_y_m", "gradient_m_per_m", "gradient_smoothing_m", "relief_m", "relief_wavelength_m", "section_m", "shoulder_m", "station_m", "toe_y_m", "top_blend_m", "waterline"];
const WATERLINE_FIELDS = ["core_m", "gradient_m_per_m", "smoothing_m"];
const BERM_FIELDS = ["below_crest_m", "cap_taper_m", "drop_per_m", "inner_m", "joint_blend_m", "wavelength_m", "width_m"];
const STONE_FIELDS = ["big", "chink", "cobble", "crest", "crest_fill", "driftwood", "heap", "pebbles", "planks", "posture", "prototypes", "section_m", "setback_m", "shoulder", "thinning", "top"];
const THINNING_FIELDS = ["max_m", "min_m", "reach_per_m", "start", "wood_m"];
const CHINK_FIELDS = ["fill", "overlap", "rise_m", "size_m"];
const BIG_FIELDS = ["above_m", "families"];
const SHOULDER_FIELDS = ["fill", "rise_m", "size_m"];
const TOP_FIELDS = ["bury", "out_jitter_m", "size_m", "size_skew", "spacing", "tilt_deg"];
const CREST_FIELDS = ["depth_m", "drop_per_m", "fill", "rise_m", "size_m", "size_skew"];
const CREST_FILL_FIELDS = ["fill", "rise_m", "size_m"];
const POSTURE_FIELDS = ["broad_face", "even", "max_aspect"];
const HEAP_FIELDS = ["bury", "classes", "overlap", "past_water_m", "small_reach_m", "tilt_deg", "toe_extra_m"];
const COBBLE_FIELDS = ["edge_m", "fill", "outline_bias", "overlap", "path_clearance_m", "reach_m", "size_m", "top_m"];
const DRIFTWOOD_FIELDS = ["acceptance", "from_waterline_m", "length_m", "radius_m", "sink", "spacing_m", "yaw_jitter_deg"];
const PLANK_FIELDS = ["above_water_m", "length_m", "near_xz", "segment", "width_m", "yaw_deg"];
const STRUCTURE_FIELDS = ["clearance_m", "slope", "tags", "under_drop_m"];
const SEGMENT_FIELDS = ["crest_fill_scale", "crest_rise_m", "id", "outline_source_key", "reason", "reference", "s_m", "source_key", "stone_tone"];
// Optional per segment: crest_rows false (the lower slope of a crest that
// another segment builds: no crest rows, no core, no shoulder) and cobble (its
// own fill, overlap, reach_m, size_m and top_m for the cobbles inside the band).
const SEGMENT_OPTIONAL_FIELDS = ["cobble", "crest_rows"];
const SEGMENT_COBBLE_FIELDS = ["fill", "overlap", "reach_m", "size_m", "top_m"];
const CLOSURE_SETTINGS_FIELDS = ["coping_m", "ramp_bottom_y_m", "ramp_grade", "ramp_wall_m", "wall_bottom_y_m"];
const CLOSURE_FIELDS = ["id", "kind", "reason", "reference", "s_m", "source_keys"];

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
  for (const key of ["station_m", "relief_wavelength_m", "top_blend_m", "section_m", "gradient_smoothing_m", "shoulder_m", "clamp_reach_m"]) {
    invariant(isFiniteNumber(slope[key]) && slope[key] > 0, `Shoreline slope.${key} must be positive`);
  }
  invariant(Number.isInteger(slope.columns) && slope.columns >= 4 && slope.columns <= 64, "Shoreline slope.columns must be an integer in [4, 64]");
  invariant(isRange(slope.gradient_m_per_m, 0.1) && slope.gradient_m_per_m[1] <= 1.0, "Shoreline slope.gradient_m_per_m must be [low, high] in (0.1, 1]");
  invariant(isRange(slope.dem_fit_m, 0) && slope.dem_fit_m[1] > slope.dem_fit_m[0], "Shoreline slope.dem_fit_m must be [near, far]");
  invariant(isFiniteNumber(slope.toe_y_m) && slope.toe_y_m < WATER_Y_M, "Shoreline slope.toe_y_m must lie under the water plane");
  invariant(isFiniteNumber(slope.end_cap_bottom_y_m) && slope.end_cap_bottom_y_m < slope.toe_y_m, "Shoreline end caps must reach below the toe");
  invariant(isFiniteNumber(slope.relief_m) && slope.relief_m >= 0 && slope.relief_m < 0.5, "Shoreline slope.relief_m must be in [0, 0.5)");
  // The crest's core: how far below each segment's lowest crest it rises, the
  // run of its inner face, its width (varying along the shore over
  // wavelength_m), its fall across the crest, and how far either side of a
  // joint two segments' crests blend.
  exactKeys(slope.berm, BERM_FIELDS, "Shoreline slope.berm");
  for (const key of ["cap_taper_m", "inner_m", "joint_blend_m", "wavelength_m"]) invariant(isFiniteNumber(slope.berm[key]) && slope.berm[key] > 0, `Shoreline slope.berm.${key} must be positive`);
  for (const key of ["below_crest_m", "drop_per_m"]) invariant(isFiniteNumber(slope.berm[key]) && slope.berm[key] >= 0, `Shoreline slope.berm.${key} must be non-negative`);
  requireRange(slope.berm.width_m, 0.2, "Shoreline slope.berm.width_m");
  // The underlay's waterline runs smoothly round the island: smoothing_m either
  // way of each point, for a core of core_m; each cross-section's fall is then
  // solved to reach it, within gradient_m_per_m.
  exactKeys(slope.waterline, WATERLINE_FIELDS, "Shoreline slope.waterline");
  invariant(isFiniteNumber(slope.waterline.smoothing_m) && slope.waterline.smoothing_m > 0, "Shoreline slope.waterline.smoothing_m must be positive");
  invariant(isFiniteNumber(slope.waterline.core_m) && slope.waterline.core_m >= 0, "Shoreline slope.waterline.core_m must be non-negative");
  invariant(isRange(slope.waterline.gradient_m_per_m, 0.1) && slope.waterline.gradient_m_per_m[1] <= 1.5, "Shoreline slope.waterline.gradient_m_per_m must be [low, high] in (0.1, 1.5]");
  // Each slope record holds one section; its vertices are packed as uint16.
  invariant(slope.section_m <= 120, "Shoreline slope.section_m must stay within 120 m (packed record extents)");
  const stones = config.stones;
  exactKeys(stones, STONE_FIELDS, "Shoreline stones");
  invariant(Number.isInteger(stones.prototypes) && stones.prototypes >= 3 && stones.prototypes <= 12, "Shoreline stones.prototypes must be 3-12 boulder shapes");
  invariant(isFiniteNumber(stones.section_m) && stones.section_m >= 10 && stones.section_m <= 100, "Shoreline stones.section_m must be 10-100 m (packed batch extents)");
  invariant(isFiniteNumber(stones.setback_m) && stones.setback_m >= SHORELINE_OUTSIDE_CLEARANCE_M, `Shoreline stones.setback_m must be at least ${SHORELINE_OUTSIDE_CLEARANCE_M} m`);
  // Stones thin out one by one with distance (riprap.gdshader): a stone of
  // size s drops out at its own random share (start to 1) of its reach,
  // s * reach_per_m within [min_m, max_m]. The logs keep a fixed range, wood_m
  // [end, fade margin].
  exactKeys(stones.thinning, THINNING_FIELDS, "Shoreline stones.thinning");
  invariant(isFiniteNumber(stones.thinning.reach_per_m) && stones.thinning.reach_per_m > 0, "Shoreline stones.thinning.reach_per_m must be positive");
  invariant(isFiniteNumber(stones.thinning.min_m) && isFiniteNumber(stones.thinning.max_m) && stones.thinning.min_m > 10 && stones.thinning.max_m >= stones.thinning.min_m,
    "Shoreline stones.thinning needs min_m over 10 m and max_m at least min_m");
  invariant(isFiniteNumber(stones.thinning.start) && stones.thinning.start > 0 && stones.thinning.start <= 1, "Shoreline stones.thinning.start must be in (0, 1]");
  invariant(Array.isArray(stones.thinning.wood_m) && stones.thinning.wood_m.length === 2 && stones.thinning.wood_m.every(isFiniteNumber)
    && stones.thinning.wood_m[1] > 0 && stones.thinning.wood_m[0] > stones.thinning.wood_m[1], "Shoreline stones.thinning.wood_m must be [end, fade margin]");
  // Chinking: small stones packed between the crest's blocks, over the core.
  exactKeys(stones.chink, CHINK_FIELDS, "Shoreline stones.chink");
  requireRange(stones.chink.size_m, 0.1, "Shoreline stones.chink.size_m");
  requireRange(stones.chink.rise_m, 0, "Shoreline stones.chink.rise_m");
  invariant(isFiniteNumber(stones.chink.fill) && stones.chink.fill >= 0 && stones.chink.fill <= 1.5 && isFiniteNumber(stones.chink.overlap) && stones.chink.overlap > 0.3 && stones.chink.overlap <= 1,
    "Shoreline stones.chink needs fill in [0, 1.5] and overlap in (0.3, 1]");
  // The biggest stones take only the irregular quarry families (a big clean
  // block or slab reads as a box).
  exactKeys(stones.big, BIG_FIELDS, "Shoreline stones.big");
  invariant(isFiniteNumber(stones.big.above_m) && stones.big.above_m > 0, "Shoreline stones.big.above_m must be positive");
  invariant(Array.isArray(stones.big.families) && stones.big.families.length > 0 && stones.big.families.every((name) => QUARRY_FAMILIES.some((family) => family.name === name)),
    "Shoreline stones.big.families must name quarry families");
  exactKeys(stones.top, TOP_FIELDS, "Shoreline stones.top");
  for (const key of ["size_m", "out_jitter_m", "bury"]) requireRange(stones.top[key], 0, `Shoreline stones.top.${key}`);
  invariant(stones.top.bury[1] < 1, "Shoreline stones.top.bury must leave part of each stone above ground");
  invariant(isFiniteNumber(stones.top.tilt_deg) && stones.top.tilt_deg >= 0 && stones.top.tilt_deg < 45, "Shoreline stones.top.tilt_deg must be in [0, 45)");
  for (const rule of ["top", "crest"]) {
    invariant(isFiniteNumber(stones[rule].size_skew) && stones[rule].size_skew >= 1 && stones[rule].size_skew <= 4, `Shoreline stones.${rule}.size_skew must be in [1, 4] (1: sizes even over size_m, more: mostly small)`);
  }
  exactKeys(stones.pebbles, ["below_m", "prototypes"], "Shoreline stones.pebbles");
  invariant(Number.isInteger(stones.pebbles.prototypes) && stones.pebbles.prototypes >= 1 && stones.pebbles.prototypes <= 6 && isFiniteNumber(stones.pebbles.below_m) && stones.pebbles.below_m > 0,
    "Shoreline stones.pebbles needs 1-6 prototypes and a positive below_m");
  exactKeys(stones.crest_fill, CREST_FILL_FIELDS, "Shoreline stones.crest_fill");
  requireRange(stones.crest_fill.size_m, 0.1, "Shoreline stones.crest_fill.size_m");
  requireRange(stones.crest_fill.rise_m, -1, "Shoreline stones.crest_fill.rise_m");
  invariant(isFiniteNumber(stones.crest_fill.fill) && stones.crest_fill.fill > 0 && stones.crest_fill.fill <= 1.5, "Shoreline stones.crest_fill.fill must be in (0, 1.5]");
  exactKeys(stones.posture, ["crest", "heap"], "Shoreline stones.posture");
  for (const band of ["crest", "heap"]) {
    exactKeys(stones.posture[band], POSTURE_FIELDS, `Shoreline stones.posture.${band}`);
    const rule = stones.posture[band];
    invariant(isFiniteNumber(rule.broad_face) && rule.broad_face >= 0 && rule.broad_face <= 1 && isFiniteNumber(rule.max_aspect) && rule.max_aspect > 0.3 && typeof rule.even === "boolean",
      `Shoreline stones.posture.${band} needs broad_face in [0, 1], a max_aspect over 0.3 and a boolean even`);
  }
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
  invariant(isFiniteNumber(stones.shoulder.fill) && stones.shoulder.fill >= 0 && stones.shoulder.fill <= 1.5, "Shoreline stones.shoulder.fill must be in [0, 1.5]");
  exactKeys(stones.heap, HEAP_FIELDS, "Shoreline stones.heap");
  requireRange(stones.heap.bury, 0, "Shoreline stones.heap.bury");
  invariant(stones.heap.bury[1] < 1, "Shoreline stones.heap.bury must leave part of each stone above the slope");
  invariant(isFiniteNumber(stones.heap.overlap) && stones.heap.overlap > 0.4 && stones.heap.overlap <= 1, "Shoreline stones.heap.overlap must be in (0.4, 1]");
  invariant(isFiniteNumber(stones.heap.tilt_deg) && stones.heap.tilt_deg >= 0 && stones.heap.tilt_deg < 45, "Shoreline stones.heap.tilt_deg must be in [0, 45)");
  invariant(isFiniteNumber(stones.heap.small_reach_m) && stones.heap.small_reach_m > 0, "Shoreline stones.heap.small_reach_m must be positive");
  invariant(isFiniteNumber(stones.heap.past_water_m) && stones.heap.past_water_m >= 0, "Shoreline stones.heap.past_water_m must be non-negative");
  invariant(stones.prototypes >= QUARRY_FAMILIES.length, `Shoreline stones.prototypes must cover the ${QUARRY_FAMILIES.length} quarry-stone families`);
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
  for (const key of ["fill", "edge_m", "path_clearance_m", "outline_bias", "reach_m"]) invariant(isFiniteNumber(stones.cobble[key]) && stones.cobble[key] >= 0, `Shoreline stones.cobble.${key} must be non-negative`);
  // How close two cobbles may lie (as a share of their radii's sum): buried, they may overlap.
  invariant(isFiniteNumber(stones.cobble.overlap) && stones.cobble.overlap > 0.3 && stones.cobble.overlap <= 1, "Shoreline stones.cobble.overlap must be in (0.3, 1]");
  exactKeys(stones.driftwood, DRIFTWOOD_FIELDS, "Shoreline stones.driftwood");
  for (const key of ["from_waterline_m", "length_m", "radius_m"]) requireRange(stones.driftwood[key], 0, `Shoreline stones.driftwood.${key}`);
  invariant(isFiniteNumber(stones.driftwood.spacing_m) && stones.driftwood.spacing_m > 2, "Shoreline stones.driftwood.spacing_m must exceed 2 m");
  invariant(isFiniteNumber(stones.driftwood.acceptance) && stones.driftwood.acceptance >= 0 && stones.driftwood.acceptance <= 1, "Shoreline stones.driftwood.acceptance must be in [0, 1]");
  invariant(isFiniteNumber(stones.driftwood.sink) && stones.driftwood.sink >= 0 && stones.driftwood.sink < 1, "Shoreline stones.driftwood.sink must be in [0, 1)");
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
  const closure = config.closure;
  exactKeys(closure, CLOSURE_SETTINGS_FIELDS, "Shoreline closure");
  invariant(isFiniteNumber(closure.wall_bottom_y_m) && closure.wall_bottom_y_m < slope.toe_y_m, "Shoreline closure.wall_bottom_y_m must reach below the toe");
  invariant(isFiniteNumber(closure.ramp_bottom_y_m) && closure.ramp_bottom_y_m < WATER_Y_M && closure.ramp_bottom_y_m > closure.wall_bottom_y_m,
    "Shoreline closure.ramp_bottom_y_m must lie under the water and over the wall bottom");
  invariant(isFiniteNumber(closure.ramp_grade) && closure.ramp_grade > 0.05 && closure.ramp_grade < 0.5, "Shoreline closure.ramp_grade must be in (0.05, 0.5)");
  invariant(isFiniteNumber(closure.ramp_wall_m) && closure.ramp_wall_m >= 0 && closure.ramp_wall_m < 1, "Shoreline closure.ramp_wall_m must be in [0, 1)");
  invariant(isFiniteNumber(closure.coping_m) && closure.coping_m >= 0 && closure.coping_m < 0.3, "Shoreline closure.coping_m must be in [0, 0.3)");
  // Stone tones per segment (palettes, from the dated photos), blended over
  // blend_m either side of each segment end into the next segment's.
  exactKeys(config.tones, TONE_SETTINGS_FIELDS, "Shoreline tones");
  invariant(isFiniteNumber(config.tones.blend_m) && config.tones.blend_m > 0, "Shoreline tones.blend_m must be positive");
  invariant(config.tones.palettes != null && typeof config.tones.palettes === "object" && Object.keys(config.tones.palettes).length > 0, "Shoreline tones.palettes must name palettes");
  for (const [name, tone] of Object.entries(config.tones.palettes)) {
    invariant(SAFE_ID.test(name) && Array.isArray(tone) && tone.length === SHORELINE_TONE_LENGTH && tone.every(isFiniteNumber) && tone[0] > 0
      && tone.slice(1).every((share) => share >= 0) && tone[1] + tone[2] + tone[3] <= 0.9,
    `Shoreline tones.palettes.${name} must be [brightness, warm share, dark share, pale share] with the shares under 0.9 together`);
  }
  invariant(Array.isArray(config.segments) && config.segments.length > 0, "Shoreline needs at least one segment");
  const ids = new Set();
  const segmentIds = new Set();
  for (const segment of config.segments) {
    exactKeys(segment, [...SEGMENT_FIELDS, ...SEGMENT_OPTIONAL_FIELDS.filter((key) => segment != null && Object.hasOwn(segment, key))], `Shoreline segment ${segment?.id}`);
    invariant(segment.crest_rows === undefined || segment.crest_rows === false, `Shoreline segment ${segment.id} crest_rows may only be false (crest rows are the default)`);
    if (segment.cobble !== undefined) {
      exactKeys(segment.cobble, SEGMENT_COBBLE_FIELDS, `Shoreline segment ${segment.id} cobble`);
      requireRange(segment.cobble.size_m, 0, `Shoreline segment ${segment.id} cobble.size_m`);
      requireRange(segment.cobble.top_m, 0, `Shoreline segment ${segment.id} cobble.top_m`);
      invariant(segment.cobble.top_m[1] <= SHORELINE_COBBLE_MAX_TOP_M, `Shoreline segment ${segment.id} cobbles may rise at most ${SHORELINE_COBBLE_MAX_TOP_M} m above the walkable land`);
      for (const key of ["fill", "reach_m"]) invariant(isFiniteNumber(segment.cobble[key]) && segment.cobble[key] >= 0, `Shoreline segment ${segment.id} cobble.${key} must be non-negative`);
      invariant(isFiniteNumber(segment.cobble.overlap) && segment.cobble.overlap > 0.3 && segment.cobble.overlap <= 1, `Shoreline segment ${segment.id} cobble.overlap must be in (0.3, 1]`);
    }
    invariant(typeof segment.id === "string" && SAFE_ID.test(segment.id) && !ids.has(segment.id), `Shoreline segment ${segment.id} needs a unique lower_snake id`);
    ids.add(segment.id);
    segmentIds.add(segment.id);
    invariant(segment.outline_source_key === PLAYABLE_BOUNDARY_SOURCE_KEY, `Shoreline segment ${segment.id} must run along the island outline ${PLAYABLE_BOUNDARY_SOURCE_KEY}`);
    invariant(/^[wr]\d+$/u.test(segment.source_key), `Shoreline segment ${segment.id} needs an OSM breakwater way or relation source_key`);
    // [start, end] along the outline; start > end runs across the outline's start (s = 0).
    invariant(Array.isArray(segment.s_m) && segment.s_m.length === 2 && segment.s_m.every((value) => isFiniteNumber(value) && value >= 0),
      `Shoreline segment ${segment.id} s_m must be [start, end] distances along the outline`);
    for (const field of ["reason", "reference"]) {
      invariant(typeof segment[field] === "string" && segment[field].trim() !== "", `Shoreline segment ${segment.id} needs ${field}`);
    }
    invariant(typeof segment.stone_tone === "string" && Object.hasOwn(config.tones?.palettes ?? {}, segment.stone_tone), `Shoreline segment ${segment.id} stone_tone must name a tones.palettes entry`);
    // The crest as photographed along this segment: how high its back row
    // rises above the land edge, and how densely the crest rows are dumped.
    requireRange(segment.crest_rise_m, 0.1, `Shoreline segment ${segment.id} crest_rise_m`);
    invariant(isFiniteNumber(segment.crest_fill_scale) && segment.crest_fill_scale > 0.2 && segment.crest_fill_scale <= 1.5, `Shoreline segment ${segment.id} crest_fill_scale must be in (0.2, 1.5]`);
  }
  invariant(Array.isArray(config.closures), "Shoreline closures must be a list");
  for (const piece of config.closures) {
    exactKeys(piece, CLOSURE_FIELDS, `Shoreline closure ${piece?.id}`);
    invariant(typeof piece.id === "string" && SAFE_ID.test(piece.id) && !ids.has(piece.id), `Shoreline closure ${piece.id} needs a unique lower_snake id`);
    ids.add(piece.id);
    invariant(SHORELINE_CLOSURE_KINDS.includes(piece.kind), `Shoreline closure ${piece.id} kind must be one of ${SHORELINE_CLOSURE_KINDS.join(", ")}`);
    invariant(Array.isArray(piece.s_m) && piece.s_m.length === 2 && piece.s_m.every((value) => isFiniteNumber(value) && value >= 0),
      `Shoreline closure ${piece.id} s_m must be [start, end] distances along the outline`);
    invariant(Array.isArray(piece.source_keys) && piece.source_keys.length > 0 && piece.source_keys.every((key) => /^[wr]\d+$/u.test(key)),
      `Shoreline closure ${piece.id} needs the OSM source keys it closes`);
    for (const field of ["reason", "reference"]) {
      invariant(typeof piece[field] === "string" && piece[field].trim() !== "", `Shoreline closure ${piece.id} needs ${field}`);
    }
  }
  for (const plank of stones.planks) invariant(segmentIds.has(plank.segment), `Shoreline plank names unknown segment ${plank.segment}`);
  // Land that is stone in the aerial: the flat breakwater overlay (the rock
  // ground) lies over the riprap verge there.
  invariant(Array.isArray(config.rock_grounds), "Shoreline rock_grounds must be a list");
  for (const ground of config.rock_grounds) {
    exactKeys(ground, ROCK_GROUND_FIELDS, `Shoreline rock ground ${ground?.id}`);
    invariant(typeof ground.id === "string" && SAFE_ID.test(ground.id) && !ids.has(ground.id), `Shoreline rock ground ${ground.id} needs a unique lower_snake id`);
    ids.add(ground.id);
    invariant(config.segments.some((segment) => segment.source_key === ground.source_key), `Shoreline rock ground ${ground.id} names ${ground.source_key}, which no segment takes`);
    invariant(Array.isArray(ground.s_m) && ground.s_m.length === 2 && ground.s_m.every(isFiniteNumber) && ground.s_m[1] > ground.s_m[0], `Shoreline rock ground ${ground.id} s_m must be [start, end] along the outline`);
    for (const field of ["reason", "reference"]) invariant(typeof ground[field] === "string" && ground[field].trim() !== "", `Shoreline rock ground ${ground.id} needs ${field}`);
  }
  invariant(Array.isArray(config.mounds), "Shoreline mounds must be a list");
  for (const mound of config.mounds) {
    exactKeys(mound, MOUND_FIELDS, `Shoreline mound ${mound?.id}`);
    invariant(typeof mound.id === "string" && SAFE_ID.test(mound.id) && !ids.has(mound.id), `Shoreline mound ${mound.id} needs a unique lower_snake id`);
    ids.add(mound.id);
    invariant(segmentIds.has(mound.segment), `Shoreline mound ${mound.id} names unknown segment ${mound.segment}`);
    invariant(Array.isArray(mound.centerline_xz) && mound.centerline_xz.length >= 2 && mound.centerline_xz.every((point) => Array.isArray(point) && point.length === 2 && point.every(isFiniteNumber)),
      `Shoreline mound ${mound.id} centerline_xz must list world [x, z] points`);
    invariant(isFiniteNumber(mound.crest_y_m) && mound.crest_y_m > WATER_Y_M + 0.3, `Shoreline mound ${mound.id} crest_y_m must stand clear of the water`);
    for (const key of ["crest_min_m", "taper_m"]) invariant(isFiniteNumber(mound[key]) && mound[key] > 0, `Shoreline mound ${mound.id} ${key} must be positive`);
    invariant(isFiniteNumber(mound.gradient) && mound.gradient > 0.2 && mound.gradient <= 1, `Shoreline mound ${mound.id} gradient must be in (0.2, 1]`);
    requireRange(mound.half_width_m, 0.5, `Shoreline mound ${mound.id} half_width_m`);
    for (const field of ["reason", "reference"]) invariant(typeof mound[field] === "string" && mound[field].trim() !== "", `Shoreline mound ${mound.id} needs ${field}`);
  }
  return config;
}

export function loadShorelineConfig(projectRoot) {
  const path = resolve(projectRoot, SHORELINE_CONFIG_PATH);
  const config = shorelineSettings(JSON.parse(readFileSync(path, "utf8")));
  return { config, descriptor: { path: SHORELINE_CONFIG_PATH, sha256: sha256File(path) } };
}

// ---------------------------------------------------------------- packing

// A value on the 2 mm position grid.
function onGrid(value) {
  const snapped = Math.round(value / SHORELINE_POSITION_STEP_M) * SHORELINE_POSITION_STEP_M;
  return Object.is(snapped, -0) ? 0 : Number(snapped.toFixed(3));
}

function gridOrigin(points) {
  return [0, 1, 2].map((axis) => onGrid(Math.min(...points.map((point) => point[axis]))));
}

function gridSteps(value, origin, label) {
  const steps = Math.round((value - origin) / SHORELINE_POSITION_STEP_M);
  invariant(steps >= 0 && steps <= 0xffff, `${label} reaches past the packed extent (${steps} steps)`);
  return steps;
}

// The int16 components of a unit quaternion (w >= 0) and the quaternion they decode to.
function quantizeRotation(q) {
  const length = Math.hypot(...q);
  const sign = q[3] < 0 ? -1 : 1;
  const ints = q.map((value) => Math.round((sign * value * SHORELINE_ROTATION_SCALE) / length));
  return { ints, q: decodeRotation(ints) };
}

function decodeRotation(ints) {
  const raw = ints.map((value) => value / SHORELINE_ROTATION_SCALE);
  const length = Math.hypot(...raw);
  invariant(length > 0.5, "Packed rotation is not a unit quaternion");
  return raw.map((value) => value / length);
}

function quantizeScale(value) {
  const steps = Math.round(value / SHORELINE_SCALE_STEP_M);
  invariant(steps > 0 && steps <= 0xffff, `Shoreline scale ${value} cannot be packed`);
  return { steps, value: steps * SHORELINE_SCALE_STEP_M };
}

// Bytes per placement: position 3 x uint16, rotation 4 x int16, then one
// uint16 size for a stone (uniform scale) or three for a log or plank.
export function shorelinePlacementStride(kind) {
  return kind === "boulder" ? 16 : 20;
}

function packBatch(placements, kind) {
  const origin = gridOrigin(placements.map((placement) => placement.origin));
  const stride = shorelinePlacementStride(kind);
  const bytes = Buffer.alloc(stride * placements.length);
  placements.forEach((placement, index) => {
    let offset = index * stride;
    placement.origin.forEach((value, axis) => {
      bytes.writeUInt16LE(gridSteps(value, origin[axis], "Shoreline batch"), offset);
      offset += 2;
    });
    for (const value of placement.rotation) {
      bytes.writeInt16LE(value, offset);
      offset += 2;
    }
    for (const value of kind === "boulder" ? placement.scale.slice(0, 1) : placement.scale) {
      bytes.writeUInt16LE(value, offset);
      offset += 2;
    }
  });
  return { origin, count: placements.length, placements: bytes.toString("base64") };
}

// The placements of a packed batch: [x, y, z, qx, qy, qz, qw, sx, sy, sz]
// each, with the rotation normalized (the twin of the GDScript decoders).
export function unpackShorelineBatch(batch, kind) {
  const stride = shorelinePlacementStride(kind);
  const bytes = Buffer.from(String(batch.placements), "base64");
  invariant(Number.isInteger(batch.count) && batch.count > 0 && bytes.length === stride * batch.count, `Shoreline batch ${batch.id} placement bytes do not match its count`);
  invariant(Array.isArray(batch.origin) && batch.origin.length === 3 && batch.origin.every(isFiniteNumber), `Shoreline batch ${batch.id} needs a world origin`);
  const placements = [];
  for (let index = 0; index < batch.count; index += 1) {
    let offset = index * stride;
    const position = [0, 1, 2].map((axis) => {
      const value = batch.origin[axis] + bytes.readUInt16LE(offset) * SHORELINE_POSITION_STEP_M;
      offset += 2;
      return value;
    });
    const ints = [0, 1, 2, 3].map(() => {
      const value = bytes.readInt16LE(offset);
      offset += 2;
      return value;
    });
    const scales = (kind === "boulder" ? [0] : [0, 1, 2]).map(() => {
      const value = bytes.readUInt16LE(offset) * SHORELINE_SCALE_STEP_M;
      offset += 2;
      return value;
    });
    const scale = kind === "boulder" ? [scales[0], scales[0], scales[0]] : scales;
    placements.push([...position, ...decodeRotation(ints), ...scale]);
  }
  return placements;
}

// A generated mesh (vertices on the position grid) as a packed record.
function packMesh(mesh, label) {
  const vertexCount = mesh.vertices.length / 3;
  invariant(vertexCount > 0 && vertexCount <= 0xffff, `${label} has ${vertexCount} vertices; a packed record holds 1-65535`);
  const points = [];
  for (let index = 0; index < mesh.vertices.length; index += 3) points.push(mesh.vertices.slice(index, index + 3));
  const origin = gridOrigin(points);
  const positions = Buffer.alloc(vertexCount * 6);
  const normals = Buffer.alloc(vertexCount * 3);
  points.forEach((point, index) => {
    point.forEach((value, axis) => positions.writeUInt16LE(gridSteps(value, origin[axis], label), index * 6 + axis * 2));
    for (let axis = 0; axis < 3; axis += 1) {
      normals.writeInt8(Math.max(-127, Math.min(127, Math.round(mesh.normals[index * 3 + axis] * SHORELINE_NORMAL_SCALE))), index * 3 + axis);
    }
  });
  const indices = Buffer.alloc(mesh.indices.length * 2);
  mesh.indices.forEach((value, index) => indices.writeUInt16LE(value, index * 2));
  return { origin, vertex_count: vertexCount, positions: positions.toString("base64"), normals: normals.toString("base64"), indices: indices.toString("base64") };
}

// The plain mesh of a packed record: vertices, normals (normalized), indices,
// and for a shoulder (verge) record the land's UVs, world x / 10 and z / 10.
export function unpackShorelineRecord(record) {
  const count = record.vertex_count;
  invariant(Number.isInteger(count) && count > 0, `${record.object_key} needs a vertex count`);
  invariant(Array.isArray(record.origin) && record.origin.length === 3 && record.origin.every(isFiniteNumber), `${record.object_key} needs a world origin`);
  const positions = Buffer.from(String(record.positions), "base64");
  const packedNormals = Buffer.from(String(record.normals), "base64");
  const packedIndices = Buffer.from(String(record.indices), "base64");
  invariant(positions.length === count * 6 && packedNormals.length === count * 3 && packedIndices.length % 6 === 0 && packedIndices.length > 0, `${record.object_key} packed arrays do not match its vertex count`);
  const vertices = [];
  const normals = [];
  for (let index = 0; index < count; index += 1) {
    for (let axis = 0; axis < 3; axis += 1) vertices.push(record.origin[axis] + positions.readUInt16LE(index * 6 + axis * 2) * SHORELINE_POSITION_STEP_M);
    const n = [0, 1, 2].map((axis) => packedNormals.readInt8(index * 3 + axis) / SHORELINE_NORMAL_SCALE);
    const length = Math.hypot(...n);
    invariant(length > 0.5, `${record.object_key} has a zero normal`);
    normals.push(...n.map((value) => value / length));
  }
  const indices = [];
  for (let offset = 0; offset < packedIndices.length; offset += 2) indices.push(packedIndices.readUInt16LE(offset));
  const mesh = { vertices, normals, indices };
  if (record.material_key === SHORELINE_VERGE_MATERIAL) {
    mesh.uvs = [];
    for (let index = 0; index < vertices.length; index += 3) mesh.uvs.push(vertices[index] / 10, vertices[index + 2] / 10);
  }
  return mesh;
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

// The convex hull of plan points, counterclockwise (monotone chain).
function convexHull(points) {
  const sorted = [...points].sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  const half = (list) => {
    const out = [];
    for (const point of list) {
      while (out.length >= 2 && cross(sub(out.at(-1), out.at(-2)), sub(point, out.at(-2))) <= 0) out.pop();
      out.push(point);
    }
    out.pop();
    return out;
  };
  return [...half(sorted), ...half([...sorted].reverse())];
}

// A convex polygon of vertices ({ plan, y, normal }) cut by a line: the part
// where f(plan) >= 0, new vertices interpolated along the cut edges and
// tagged with the cut's id (`cut`).
function clipVertices(polygon, f, cut) {
  const kept = [];
  polygon.forEach((a, index) => {
    const b = polygon[(index + 1) % polygon.length];
    const fa = f(a.plan);
    const fb = f(b.plan);
    if (fa >= 0) kept.push(a);
    if ((fa >= 0) !== (fb >= 0)) {
      const t = fa / (fa - fb);
      kept.push({ plan: add(a.plan, scale(sub(b.plan, a.plan), t)), y: lerp(a.y, b.y, t), normal: unit3(add3(scale3(a.normal, 1 - t), scale3(b.normal, t))), cut });
    }
  });
  return kept;
}

// A convex polygon minus a convex counterclockwise hull: the convex pieces
// outside it, one per hull edge (outside that edge, inside the ones before);
// the vertices on hull edge k carry cut [tag, k].
function subtractHull(polygon, hull, tag) {
  const pieces = [];
  let rest = polygon;
  for (let index = 0; index < hull.length && rest.length >= 3; index += 1) {
    const a = hull[index];
    const edge = sub(hull[(index + 1) % hull.length], a);
    const inside = (plan) => cross(edge, sub(plan, a));
    pieces.push(clipVertices(rest, (plan) => -inside(plan), [tag, index]));
    rest = clipVertices(rest, inside, [tag, index]);
  }
  if (rest.length < 3) return [polygon];
  return pieces.filter((piece) => piece.length >= 3);
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

// Appends one triangle wound counterclockwise around desiredNormal (the
// generated-world convention; the runtime turns it clockwise for Godot).
// Vertices lie on the packed position grid, so a triangle too small to keep
// after packing is dropped here.
function pushTriangle(mesh, indices, desiredNormal, target = mesh.indices) {
  const vertex = (index) => mesh.vertices.slice(index * 3, index * 3 + 3);
  let [a, b, c] = indices;
  const normal = cross3(sub3(vertex(b), vertex(a)), sub3(vertex(c), vertex(a)));
  if (length3(normal) / 2 < MINIMUM_TRIANGLE_AREA_M2) return false;
  if (dot3(normal, desiredNormal) < 0) [b, c] = [c, b];
  target.push(a, b, c);
  return true;
}

// Record vertices snap to the packed grid; prototype vertices (unit stones)
// keep millimetres.
function pushVertex(mesh, position, normal, grid = true) {
  const index = mesh.vertices.length / 3;
  mesh.vertices.push(...position.map(grid ? onGrid : roundCoordinate));
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

// The shortest rotation (unit quaternion) taking unit vector a onto unit vector b.
function arcQuaternion(a, b) {
  const c = dot3(a, b);
  if (c < -0.999999) {
    const axis = unit3(Math.abs(a[0]) < 0.9 ? cross3(a, [1, 0, 0]) : cross3(a, [0, 1, 0]));
    return [axis[0], axis[1], axis[2], 0];
  }
  const axis = cross3(a, b);
  const q = [axis[0], axis[1], axis[2], 1 + c];
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

// World positions of points (local [x, y, z]) under a placement.
function placedPoints(points, q, scales, origin) {
  const basis = basisOf(q, scales);
  return points.map((v) => add3(origin, add3(add3(scale3(basis[0], v[0]), scale3(basis[1], v[1])), scale3(basis[2], v[2]))));
}

// The distinct vertices of a mesh (a stone's hull points), as local [x, y, z].
function distinctPoints(mesh) {
  const seen = new Map();
  for (let index = 0; index < mesh.vertices.length; index += 3) {
    const point = mesh.vertices.slice(index, index + 3);
    const key = point.map((value) => value.toFixed(4)).join(",");
    if (!seen.has(key)) seen.set(key, point);
  }
  return [...seen.values()];
}

// ---------------------------------------------------------------- prototypes

// Quarry-stone families: half extents of the starting block (x is 1), how
// far its six faces are tilted, how many corners are broken off, and whether a
// deep fracture takes off a whole top edge (a wedge).
const QUARRY_FAMILIES = Object.freeze([
  { name: "block", half: [[0.62, 0.85], [0.7, 0.95]], jitter: 0.32, corners: 3, wedge: false },
  { name: "slab", half: [[0.34, 0.48], [0.62, 0.9]], jitter: 0.26, corners: 2, wedge: false },
  { name: "long", half: [[0.5, 0.66], [0.4, 0.55]], jitter: 0.3, corners: 3, wedge: false },
  { name: "wedge", half: [[0.6, 0.8], [0.65, 0.9]], jitter: 0.3, corners: 1, wedge: true },
  { name: "chunky", half: [[0.75, 0.95], [0.8, 1.0]], jitter: 0.34, corners: 4, wedge: false },
]);

// The convex polytope bounded by planes ({n, o}: n.p <= o): its vertices,
// where three planes meet inside all the others, and its faces (each plane
// with three or more vertices: outward normal, vertex indices in order, area).
function polytope(planes) {
  const points = [];
  const onPlanes = [];
  for (let i = 0; i < planes.length; i += 1) {
    for (let j = i + 1; j < planes.length; j += 1) {
      for (let k = j + 1; k < planes.length; k += 1) {
        const [a, b, c] = [planes[i], planes[j], planes[k]];
        const bc = cross3(b.n, c.n);
        const determinant = dot3(a.n, bc);
        if (Math.abs(determinant) < 1e-9) continue;
        const p = scale3(add3(add3(scale3(bc, a.o), scale3(cross3(c.n, a.n), b.o)), scale3(cross3(a.n, b.n), c.o)), 1 / determinant);
        if (planes.some((plane) => dot3(plane.n, p) > plane.o + 1e-7)) continue;
        if (points.some((q) => length3(sub3(p, q)) < 1e-6)) continue;
        points.push(p);
        onPlanes.push(planes.map((plane, index) => (Math.abs(dot3(plane.n, p) - plane.o) < 1e-6 ? index : -1)).filter((index) => index >= 0));
      }
    }
  }
  const faces = [];
  planes.forEach((plane, planeIndex) => {
    const on = points.map((p, index) => index).filter((index) => onPlanes[index].includes(planeIndex));
    if (on.length < 3) return;
    const centroid = scale3(on.reduce((sum, index) => add3(sum, points[index]), [0, 0, 0]), 1 / on.length);
    const u = unit3(Math.abs(plane.n[1]) < 0.9 ? cross3(plane.n, [0, 1, 0]) : cross3(plane.n, [1, 0, 0]));
    const w = cross3(plane.n, u);
    on.sort((left, right) => {
      const a = sub3(points[left], centroid);
      const b = sub3(points[right], centroid);
      return Math.atan2(dot3(a, w), dot3(a, u)) - Math.atan2(dot3(b, w), dot3(b, u));
    });
    let area = 0;
    for (let k = 1; k + 1 < on.length; k += 1) area += length3(cross3(sub3(points[on[k]], points[on[0]]), sub3(points[on[k + 1]], points[on[0]]))) / 2;
    faces.push({ n: plane.n, on, area });
  });
  return { points, faces };
}

// Angles in degrees between the normals of every pair of neighbouring faces
// (faces sharing two vertices).
function edgeAngles(shape) {
  const angles = [];
  for (let i = 0; i < shape.faces.length; i += 1) {
    for (let j = i + 1; j < shape.faces.length; j += 1) {
      if (shape.faces[i].on.filter((index) => shape.faces[j].on.includes(index)).length < 2) continue;
      angles.push((Math.acos(Math.max(-1, Math.min(1, dot3(shape.faces[i].n, shape.faces[j].n)))) * 180) / Math.PI);
    }
  }
  return angles;
}

// One candidate fractured block from `rng`, or null when it fails a check.
// First the clean block: six tilted split faces, an optional wedge fracture
// and broken-off corners, every face at least 3 % of the surface and every
// edge a crease of at least 24 degrees. Then the broken surface: 2-3 shallow
// creases (10-16 degrees) across its largest faces, as split rock is never one
// flat plane, and 3-5 chipped corners. The detailed stone needs 12-20 faces,
// no face under 0.5 % of the surface, no edge under 7 degrees and at most five
// edges under 20 degrees (the creases); the clean block is its coarse LOD.
function quarryCandidate(rng, family, detailed) {
  const half = [1, pick(family.half[0], rng), pick(family.half[1], rng)];
  const support = (n) => Math.abs(n[0]) * half[0] + Math.abs(n[1]) * half[1] + Math.abs(n[2]) * half[2];
  const jitter = () => (rng() - 0.5) * 2 * family.jitter;
  const sign = () => (rng() < 0.5 ? -1 : 1);
  const planes = [];
  for (const axis of [[1, 0, 0], [-1, 0, 0], [0, 1, 0], [0, -1, 0], [0, 0, 1], [0, 0, -1]]) {
    const n = unit3(add3(axis, [jitter(), jitter(), jitter()]));
    planes.push({ n, o: support(n) * (0.84 + 0.14 * rng()) });
  }
  if (family.wedge) {
    const n = unit3([(rng() - 0.5) * 0.4, 1, sign() * (0.8 + 0.6 * rng())]);
    planes.push({ n, o: support(n) * (0.4 + 0.15 * rng()) });
  }
  for (let k = 0; k < family.corners; k += 1) {
    const n = unit3([sign() * (0.6 + 0.6 * rng()), sign() * (0.5 + 0.6 * rng()), sign() * (0.6 + 0.6 * rng())]);
    planes.push({ n, o: support(n) * (0.55 + 0.25 * rng()) });
  }
  const block = polytope(planes);
  if (block.points.length < 8 || block.faces.length < 6 || block.faces.length > 10) return null;
  const blockSurface = block.faces.reduce((sum, face) => sum + face.area, 0);
  if (block.faces.some((face) => face.area < blockSurface * 0.03) || edgeAngles(block).some((angle) => angle < 24)) return null;
  const extentOf = (points) => Math.max(...[0, 1, 2].map((axis) => Math.max(...points.map((p) => p[axis])) - Math.min(...points.map((p) => p[axis]))));
  if (!detailed) return finishStone(block, null);
  const longest = extentOf(block.points);
  const reach = (n, points) => Math.max(...points.map((p) => dot3(p, n)));
  // Shallow creases across the largest faces.
  const broken = [...planes];
  const largest = [...block.faces].sort((left, right) => right.area - left.area).slice(0, 3);
  const creases = 2 + Math.floor(rng() * 2);
  for (let k = 0; k < creases; k += 1) {
    const face = largest[k % largest.length];
    const axis = unit3(cross3(face.n, unit3([rng() - 0.5, rng() - 0.5, rng() - 0.5])));
    const angle = ((10 + 6 * rng()) * Math.PI) / 180;
    const n = unit3(add3(scale3(face.n, Math.cos(angle)), scale3(cross3(axis, face.n), Math.sin(angle))));
    broken.push({ n, o: reach(n, polytope(broken).points) - longest * (0.05 + 0.05 * rng()) });
  }
  // Chipped corners.
  const chips = 3 + Math.floor(rng() * 3);
  for (let k = 0; k < chips; k += 1) {
    const current = polytope(broken).points;
    const centroid = scale3(current.reduce((sum, p) => add3(sum, p), [0, 0, 0]), 1 / current.length);
    const corner = current[Math.floor(rng() * current.length)];
    const n = unit3(add3(unit3(sub3(corner, centroid)), [(rng() - 0.5) * 0.5, (rng() - 0.5) * 0.5, (rng() - 0.5) * 0.5]));
    broken.push({ n, o: dot3(corner, n) - longest * (0.05 + 0.05 * rng()) });
  }
  const stone = polytope(broken);
  if (stone.faces.length < 12 || stone.faces.length > 20) return null;
  const surface = stone.faces.reduce((sum, face) => sum + face.area, 0);
  const angles = edgeAngles(stone);
  if (stone.faces.some((face) => face.area < surface * 0.005) || angles.some((angle) => angle < 7) || angles.filter((angle) => angle < 20).length > 5) return null;
  return finishStone(stone, block);
}

// The mesh of a stone polytope, centred on its vertex centroid and scaled so
// its longest side is 1, flat-shaded (each face its own vertices and normal),
// with `coarse` (a slightly larger polytope in the same frame) as its LOD.
function finishStone(stone, coarse) {
  const extents = [0, 1, 2].map((axis) => Math.max(...stone.points.map((p) => p[axis])) - Math.min(...stone.points.map((p) => p[axis])));
  const centroid = scale3(stone.points.reduce((sum, p) => add3(sum, p), [0, 0, 0]), 1 / stone.points.length);
  const unitScale = 1 / Math.max(...extents);
  const normalize = (p) => scale3(sub3(p, centroid), unitScale);
  const mesh = { vertices: [], normals: [], indices: [] };
  const emit = (shape, target) => {
    for (const face of shape.faces) {
      const ids = face.on.map((index) => pushVertex(mesh, normalize(shape.points[index]), face.n, false));
      for (let k = 1; k + 1 < ids.length; k += 1) pushTriangle(mesh, [ids[0], ids[k], ids[k + 1]], face.n, target);
    }
  };
  emit(stone, mesh.indices);
  const lods = [];
  if (coarse) {
    const indices = [];
    emit(coarse, indices);
    // The coarse LOD differs from the detailed stone by about its deepest crease or chip.
    lods.push({ error_m: 0.08, indices });
  }
  return {
    size_m: extents.map((extent) => round3(extent * unitScale)),
    mesh,
    lods,
    faces: stone.faces.map((face) => ({ n: face.n, area: face.area * unitScale * unitScale })),
  };
}

// One fractured quarry block, as dumped riprap is: a block split by a few
// fracture planes into a convex polyhedron with flat broken faces, sharp
// corners and edges, shallow creases across its big faces and chipped corners
// (quarryCandidate). Prototypes cycle through QUARRY_FAMILIES (block, slab,
// long, wedge, chunky); a candidate that fails a check is drawn again.
// Flat-shaded, so edges stay hard. Centred on its centroid and scaled so its
// longest side is 1; size_m gives its three box sides. Also returns its faces
// (outward normal and area), on which a dumped stone may rest. A pebble (for
// the small stones, whose chips would be a centimetre or two) is just the
// clean block, with no LOD.
function quarryPrototype(seed, index, { pebble = false } = {}) {
  const family = QUARRY_FAMILIES[index % QUARRY_FAMILIES.length];
  const prefix = pebble ? "pebble" : "boulder";
  for (let attempt = 0; attempt < 400; attempt += 1) {
    const stone = quarryCandidate(random(seed, `${prefix === "boulder" ? "quarry" : "pebble"}:${index}:${attempt}`), family, !pebble);
    if (!stone) continue;
    return {
      prototype: { id: `${prefix}_${index}`, kind: "boulder", material_key: SHORELINE_BOULDER_MATERIAL, size_m: stone.size_m, ...stone.mesh, lods: stone.lods },
      faces: stone.faces,
    };
  }
  throw new Error(`Quarry stone ${prefix} ${index} (${family.name}) found no clean shape in 400 attempts`);
}

// One weathered driftwood log, 1 long along x and 1 thick: a trunk length,
// bent both ways and knotty (its girth wanders around and along it), squashed
// where it has lain, flaring to a broken-off root end at -x and splintering to
// a snapped tip at +x, with one short broken branch stub; its axis at y = 0.
// Instances scale it to length (x) and thickness (y and z alike).
function logPrototype(seed) {
  const rng = random(seed, "log");
  const mesh = { vertices: [], normals: [], indices: [] };
  const sides = 9;
  const stations = [[-0.5, 1.0], [-0.44, 0.92], [-0.34, 0.8], [-0.2, 0.78], [-0.05, 0.74], [0.1, 0.72], [0.24, 0.68], [0.36, 0.6], [0.45, 0.52], [0.5, 0.44]];
  const bendZ = (x) => 0.05 * Math.cos(x * Math.PI) + 0.025 * Math.sin(x * 9);
  const bendY = (x) => 0.025 * Math.sin(x * 5 + 1);
  const rings = stations.map(([x, radius]) => {
    const ring = [];
    for (let k = 0; k < sides; k += 1) {
      const angle = (k / sides) * Math.PI * 2;
      const girth = radius * 0.5 * (0.78 + 0.32 * rng());
      // Squashed where it has lain: a little flatter underneath.
      const flatten = Math.sin(angle) < 0 ? 0.82 : 1;
      ring.push([x + (rng() - 0.5) * 0.01, bendY(x) + Math.sin(angle) * girth * 0.82 * flatten, bendZ(x) + Math.cos(angle) * girth]);
    }
    return ring;
  });
  const axisAt = (x) => [x, bendY(x), bendZ(x)];
  const tube = (ringList) => {
    for (let s = 0; s + 1 < ringList.length; s += 1) {
      for (let k = 0; k < sides; k += 1) {
        const quad = [ringList[s][k], ringList[s][(k + 1) % sides], ringList[s + 1][(k + 1) % sides], ringList[s + 1][k]];
        const middle = scale3(quad.reduce((sum, p) => add3(sum, p), [0, 0, 0]), 0.25);
        const outward = unit3(sub3(middle, axisAt(middle[0])));
        const corners = quad.map((p) => pushVertex(mesh, p, unit3(sub3(p, axisAt(p[0]))), false));
        pushTriangle(mesh, [corners[0], corners[1], corners[2]], outward);
        pushTriangle(mesh, [corners[0], corners[2], corners[3]], outward);
      }
    }
  };
  tube(rings);
  // Ends: a broken-off root end, ragged, and a snapped tip whose splinters stand out.
  for (const [ring, normal, splinter] of [[rings[0], [-1, 0, 0], 0.02], [rings.at(-1), [1, 0, 0], 0.06]]) {
    const middle = add3(scale3(ring.reduce((sum, p) => add3(sum, p), [0, 0, 0]), 1 / ring.length), scale3(normal, splinter));
    const centerIndex = pushVertex(mesh, middle, normal, false);
    const corners = ring.map((p) => pushVertex(mesh, p, normal, false));
    for (let k = 0; k < sides; k += 1) pushTriangle(mesh, [centerIndex, corners[k], corners[(k + 1) % sides]], normal);
  }
  // A short broken branch stub on the upper side, a third of the way along.
  const base = axisAt(-0.12);
  const direction = unit3([0.45, 0.75, 0.48]);
  const stubLength = 0.16;
  const stubRadius = 0.11;
  const helper = unit3(cross3(direction, [1, 0, 0]));
  const other = cross3(direction, helper);
  const stubRing = (offset, radius) => Array.from({ length: 6 }, (_, k) => {
    const angle = (k / 6) * Math.PI * 2;
    return add3(add3(base, scale3(direction, offset)), add3(scale3(helper, Math.cos(angle) * radius), scale3(other, Math.sin(angle) * radius)));
  });
  const stub = [stubRing(0.05, stubRadius), stubRing(stubLength, stubRadius * 0.7)];
  for (let k = 0; k < 6; k += 1) {
    const quad = [stub[0][k], stub[0][(k + 1) % 6], stub[1][(k + 1) % 6], stub[1][k]];
    const middle = scale3(quad.reduce((sum, p) => add3(sum, p), [0, 0, 0]), 0.25);
    const along = dot3(sub3(middle, base), direction);
    const outward = unit3(sub3(middle, add3(base, scale3(direction, along))));
    const corners = quad.map((p) => pushVertex(mesh, p, outward, false));
    pushTriangle(mesh, [corners[0], corners[1], corners[2]], outward);
    pushTriangle(mesh, [corners[0], corners[2], corners[3]], outward);
  }
  const tip = add3(scale3(stub[1].reduce((sum, p) => add3(sum, p), [0, 0, 0]), 1 / 6), scale3(direction, 0.03));
  const tipIndex = pushVertex(mesh, tip, direction, false);
  const tipRing = stub[1].map((p) => pushVertex(mesh, p, direction, false));
  for (let k = 0; k < 6; k += 1) pushTriangle(mesh, [tipIndex, tipRing[k], tipRing[(k + 1) % 6]], direction);
  return { id: "log", kind: "log", material_key: SHORELINE_DRIFTWOOD_MATERIAL, ...mesh, lods: [] };
}

// One weathered plank: a unit box along x (y up, z across) whose far end has
// broken off unevenly.
function plankPrototype() {
  const mesh = { vertices: [], normals: [], indices: [] };
  const end = (z) => (z < 0 ? 0.5 : 0.36);
  const quad = (points, normal) => {
    const ids = points.map((p) => pushVertex(mesh, p, normal, false));
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
  // Smoothed outward normal: segment normals weighted by their overlap with
  // [s - radius, s + radius] (clipped to [lo, hi] when given, so a normal near
  // a segment's capped end never reaches round a hairpin), so cross-sections
  // never fold at a bend.
  const normalAt = (s, radius, lo = -Infinity, hi = Infinity) => {
    const from = Math.max(s - radius, lo);
    const to = Math.min(s + radius, hi);
    let sum = [0, 0];
    for (const offset of [-perimeter, 0, perimeter]) {
      const a = from - offset;
      const b = to - offset;
      if (b < 0 || a >= perimeter) continue;
      for (let index = segmentAt(Math.max(0, a)); index < ring.length; index += 1) {
        if (cumulative[index] > b) break;
        const overlap = Math.min(cumulative[index + 1], b) - Math.max(cumulative[index], a);
        if (overlap > 0) sum = add(sum, scale(segmentNormal(index), overlap));
      }
    }
    if (length(sum) < 1e-9) return segmentNormal(segmentAt(s));
    return unit(sum);
  };
  // Ring edges in an 8 m grid, for spatial queries.
  const cell = 8;
  const grid = new Map();
  ring.forEach((a, index) => {
    const b = ring[(index + 1) % ring.length];
    for (let x = Math.floor(Math.min(a[0], b[0]) / cell); x <= Math.floor(Math.max(a[0], b[0]) / cell); x += 1) {
      for (let y = Math.floor(Math.min(a[1], b[1]) / cell); y <= Math.floor(Math.max(a[1], b[1]) / cell); y += 1) {
        const key = `${x},${y}`;
        if (!grid.has(key)) grid.set(key, []);
        grid.get(key).push(index);
      }
    }
  });
  // Signed distance of a point from the outline: positive over the water,
  // exact within one grid cell (cell size where no edge is that near). At a
  // ring vertex the sign comes from the bisector of its edges.
  const signedDistance = (point) => {
    let best = null;
    const cx = Math.floor(point[0] / cell);
    const cy = Math.floor(point[1] / cell);
    for (let dx = -1; dx <= 1; dx += 1) {
      for (let dy = -1; dy <= 1; dy += 1) {
        for (const index of grid.get(`${cx + dx},${cy + dy}`) ?? []) {
          const a = ring[index];
          const delta = sub(ring[(index + 1) % ring.length], a);
          const t = Math.max(0, Math.min(1, dot(sub(point, a), delta) / dot(delta, delta)));
          const closest = add(a, scale(delta, t));
          const distance = length(sub(point, closest));
          if (!best || distance < best.distance - 1e-12) best = { distance, index, t, closest };
        }
      }
    }
    if (!best) return pointInMultiPolygon(point, boundary, false) ? -cell : cell;
    let normal = segmentNormal(best.index);
    if (best.t <= 1e-9 || best.t >= 1 - 1e-9) {
      const vertex = best.t <= 1e-9 ? best.index : (best.index + 1) % ring.length;
      const bisector = add(segmentNormal((vertex - 1 + ring.length) % ring.length), segmentNormal(vertex));
      if (length(bisector) > 1e-9) normal = unit(bisector);
      else return pointInMultiPolygon(point, boundary, false) ? -best.distance : best.distance;
    }
    return (dot(sub(point, best.closest), normal) >= 0 ? 1 : -1) * best.distance;
  };
  // Distance along the ray from `point` in direction `direction` to where it
  // first enters the land again beyond `skip` (a crossing of the outline with
  // land just past it; a ray that only grazes a corner goes on), and the
  // crossing; null when it does not within `reach`.
  const rayHit = (point, direction, reach, skip = 0.05) => {
    const crossings = [];
    ring.forEach((a, index) => {
      const b = ring[(index + 1) % ring.length];
      const edge = sub(b, a);
      const denominator = cross(direction, edge);
      if (Math.abs(denominator) < 1e-12) return;
      const offset = sub(a, point);
      const t = cross(offset, edge) / denominator;
      const u = cross(offset, direction) / denominator;
      if (t <= skip || t > reach || u < 0 || u > 1) return;
      crossings.push(t);
    });
    crossings.sort((left, right) => left - right);
    // A ray that starts straight into land (from the head of a slit, where the
    // far shore meets this one) is clamped at once.
    if (pointInMultiPolygon(add(point, scale(direction, skip + 0.05)), boundary, false)) return { t: skip, point: add(point, scale(direction, skip)) };
    for (const t of crossings) {
      if (pointInMultiPolygon(add(point, scale(direction, t + 0.05)), boundary, false)) return { t, point: add(point, scale(direction, t)) };
    }
    return null;
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
  return { ring, perimeter, wrap, pointAt, normalAt, segmentNormal, segmentAt, signedDistance, rayHit, breakpoints, distanceOf, nearestS };
}

// The region swept by cross-sections from s0 to s1, reaching `reach` inland and
// out over the water.
function windowPolygon(outline, s0, s1, reach) {
  const stations = [s0, ...outline.breakpoints(s0, s1), s1];
  const inner = stations.map((s) => add(outline.pointAt(s), scale(outline.normalAt(s, 6, s0, s1), -reach)));
  const outer = stations.map((s) => add(outline.pointAt(s), scale(outline.normalAt(s, 6, s0, s1), reach)));
  const ring = [...inner, ...outer.reverse()];
  return [[signedRingArea(ring) > 0 ? ring : ring.reverse()]];
}

// [s0, s1] of a piece (segment or closure), s1 > s0, s1 past the perimeter
// when it wraps.
function pieceRange(piece, perimeter, minimum) {
  const [start, end] = piece.s_m;
  invariant(start < perimeter + JOINT_TOLERANCE_M && end <= perimeter + JOINT_TOLERANCE_M, `Shoreline ${piece.id} runs past the end of the outline (${perimeter.toFixed(1)} m)`);
  const s1 = end > start ? end : end + perimeter;
  invariant(s1 - start >= minimum && s1 - start < perimeter, `Shoreline ${piece.id} must span ${minimum} m to less than the whole outline`);
  return [start, s1];
}

// Segments and closures must cover the whole outline end to end, each meeting
// the next within JOINT_TOLERANCE_M. Returns, per piece id, whether its start
// and end meet another segment (a joint: no end cap, one stone pile) and that
// segment.
function coverage(pieces, perimeter) {
  const sorted = [...pieces].sort((left, right) => left.s0 - right.s0);
  const joins = new Map(sorted.map((piece) => [piece.id, { start: false, end: false, previous: null, next: null }]));
  let covered = 0;
  sorted.forEach((piece, index) => {
    const next = sorted[(index + 1) % sorted.length];
    const gap = ((next.s0 - piece.s1) % perimeter + perimeter * 1.5) % perimeter - perimeter * 0.5;
    invariant(Math.abs(gap) <= JOINT_TOLERANCE_M, `Shoreline ${piece.id} ends at s=${piece.s1.toFixed(2)} but ${next.id} starts at s=${next.s0.toFixed(2)}: the outline must be covered end to end`);
    if (piece.kind === "segment" && next.kind === "segment") {
      Object.assign(joins.get(piece.id), { end: true, next });
      Object.assign(joins.get(next.id), { start: true, previous: piece });
    }
    covered += piece.s1 - piece.s0;
  });
  invariant(Math.abs(covered - perimeter) <= JOINT_TOLERANCE_M * sorted.length, `Shoreline pieces cover ${covered.toFixed(2)} m of the ${perimeter.toFixed(2)} m outline`);
  return joins;
}

// ---------------------------------------------------------------- plan

// The inside bands, from the config, boundary and OSM sources alone (no land
// facets yet): source key -> the breakwater part inside the outline that the
// world builder drapes as the riprap overlay instead of the flat one.
export function planShoreline({ config, boundary, playableObjects }) {
  const settings = shorelineSettings(config);
  const outline = outlineOf(boundary);
  const innerBySource = new Map();
  const segments = settings.segments.map((segment) => {
    const object = playableObjects.get(segment.source_key);
    invariant(object && object.roles.includes("terrain_shoreline") && object.tags.man_made === "breakwater",
      `Shoreline segment ${segment.id} source ${segment.source_key} is not a playable OSM breakwater`);
    const [s0, s1] = pieceRange(segment, outline.perimeter, 10);
    return { ...segment, kind: "segment", s0, s1 };
  });
  const closures = settings.closures.map((piece) => {
    for (const key of piece.source_keys) invariant(playableObjects.has(key), `Shoreline closure ${piece.id} names ${key}, which is not a playable source`);
    const [s0, s1] = pieceRange(piece, outline.perimeter, 0.5);
    return { ...piece, closure_kind: piece.kind, kind: "closure", s0, s1 };
  });
  const joins = coverage([...segments, ...closures], outline.perimeter);
  // In outline order, each segment's neighbours on either side, past any
  // closure between them: its stone tone blends into theirs at its ends.
  const ordered = [...segments].sort((left, right) => left.s0 - right.s0);
  ordered.forEach((segment, index) => {
    segment.tone_previous = ordered[(index - 1 + ordered.length) % ordered.length];
    segment.tone_next = ordered[(index + 1) % ordered.length];
  });
  for (const segment of segments) {
    const join = joins.get(segment.id);
    segment.join_start = join.start;
    segment.join_end = join.end;
    // The crests of the segments it joins, which its own blends into.
    const crestOf = (piece) => ({ rise: piece.crest_rise_m, fill: piece.crest_fill_scale, rows: piece.crest_rows === false ? 0 : 1, span: piece.s1 - piece.s0 });
    segment.crest_previous = join.previous ? crestOf(join.previous) : null;
    segment.crest_next = join.next ? crestOf(join.next) : null;
    // Normals and the window reach round a joint (the next segment computes the
    // same cross-section there) but never round a capped end.
    segment.clip = [join.start ? -Infinity : segment.s0, join.end ? Infinity : segment.s1];
    segment.window = windowPolygon(outline, segment.s0, segment.s1, WINDOW_REACH_M);
    const object = playableObjects.get(segment.source_key);
    // The band along this segment (its cobbles stay inside it).
    segment.inner = guarded(`segment ${segment.id} inner band`, () => polygonClipping.intersection(object.geometry, segment.window));
    invariant(multiPolygonArea(segment.inner) > 1, `Shoreline segment ${segment.id} has no breakwater inside the outline`);
    // The segments cover the island's whole edge, so every breakwater a
    // segment takes is draped whole as the riprap verge (cutting it at the
    // windows would only leave slivers of the flat overlay).
    innerBySource.set(segment.source_key, object.geometry);
  }
  // A rock ground: the land within the outline from s_m[0] to s_m[1], closed by
  // the chord back, which the world builder lays over the draped band as the
  // flat breakwater overlay, drawn as rock.
  const rockBySource = new Map();
  for (const ground of settings.rock_grounds) {
    const [from, to] = ground.s_m;
    const ring = [from, ...outline.breakpoints(from, to), to].map((s) => outline.pointAt(s));
    const oriented = signedRingArea(ring) > 0 ? ring : [...ring].reverse();
    rockBySource.set(ground.source_key, [...(rockBySource.get(ground.source_key) ?? []), [[[...oriented, oriented[0]]]]]);
  }
  return { settings, outline, segments, closures, innerBySource, rockBySource, overlay_bias_m: settings.overlay_bias_m, rock_bias_m: settings.overlay_bias_m + SHORELINE_ROCK_LIFT_M };
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

  // The DEM's gradient down the slope at a whole metre along the outline,
  // clamped to the photographed 2:1-3:1, then smoothed over neighbouring
  // metres. A lattice shared by every segment, so two segments that meet
  // compute the same cross-section at their joint.
  const latticeGradient = new Map();
  const rawGradient = (sl) => {
    const key = outline.wrap(sl).toFixed(0);
    if (!latticeGradient.has(key)) {
      const point = outline.pointAt(sl);
      const normal = outline.segmentNormal(outline.segmentAt(sl));
      const near = terrain.sampleEastNorth(...add(point, scale(normal, slope.dem_fit_m[0])));
      const far = terrain.sampleEastNorth(...add(point, scale(normal, slope.dem_fit_m[1])));
      const raw = (near - far) / (slope.dem_fit_m[1] - slope.dem_fit_m[0]);
      latticeGradient.set(key, Math.max(slope.gradient_m_per_m[0], Math.min(slope.gradient_m_per_m[1], raw)));
    }
    return latticeGradient.get(key);
  };
  const smoothedGradient = (s) => {
    let sum = 0;
    let weight = 0;
    for (let sl = Math.ceil(s - slope.gradient_smoothing_m); sl <= Math.floor(s + slope.gradient_smoothing_m); sl += 1) {
      const w = 1 - Math.abs(sl - s) / (slope.gradient_smoothing_m + 1e-9);
      if (w <= 0) continue;
      sum += rawGradient(sl) * w;
      weight += w;
    }
    return sum / weight;
  };
  // The crest core's width at s: smooth noise on a lattice that divides the
  // outline evenly, so it runs on across s = 0 and every joint.
  const berm = slope.berm;
  const bermCells = Math.max(1, Math.round(outline.perimeter / berm.wavelength_m));
  const bermWidthAt = (s) => {
    const u = (outline.wrap(s) / outline.perimeter) * bermCells;
    const cellIndex = Math.floor(u);
    const f = u - cellIndex;
    const h = (k) => cellHash(seed, ((k % bermCells) + bermCells) % bermCells, 0, 7);
    return lerp(berm.width_m[0], berm.width_m[1], lerp(h(cellIndex), h(cellIndex + 1), f * f * (3 - 2 * f)));
  };
  // The underlay's waterline, its distance out from the outline: at each whole
  // metre what the land's height and the DEM's gradient give for a core of
  // waterline.core_m, then smoothed over waterline.smoothing_m either way. A
  // lattice shared by every segment, so two segments that meet compute the
  // same cross-section at their joint. Without the smoothing the land's and the
  // gradient's own wanderings put jogs of a metre or more in the far band's edge.
  const latticeWaterline = new Map();
  const rawWaterline = (sl) => {
    const key = outline.wrap(sl).toFixed(0);
    if (!latticeWaterline.has(key)) {
      const point = outline.pointAt(sl);
      const land = landAt(point) ?? terrain.sampleEastNorth(point[0], point[1]);
      const width = bermWidthAt(sl);
      const fall = land + bias + slope.waterline.core_m - berm.drop_per_m * width - WATER_Y_M;
      latticeWaterline.set(key, slope.shoulder_m + berm.inner_m + width + fall / smoothedGradient(sl));
    }
    return latticeWaterline.get(key);
  };
  const smoothedWaterline = (s) => {
    let sum = 0;
    let weight = 0;
    for (let sl = Math.ceil(s - slope.waterline.smoothing_m); sl <= Math.floor(s + slope.waterline.smoothing_m); sl += 1) {
      const w = 1 - Math.abs(sl - s) / (slope.waterline.smoothing_m + 1e-9);
      if (w <= 0) continue;
      sum += rawWaterline(sl) * w;
      weight += w;
    }
    return sum / weight;
  };

  const prototypes = [];
  // Per stone shape: the faces it may come to rest on and its hull points
  // (kept out of the document).
  const shapes = new Map();
  const remember = (prototype, faces) => {
    prototypes.push(prototype);
    shapes.set(prototype.id, { faces, points: distinctPoints(prototype) });
  };
  for (let index = 0; index < rules.prototypes; index += 1) {
    const { prototype, faces } = quarryPrototype(seed, index);
    remember(prototype, faces);
  }
  for (let index = 0; index < rules.pebbles.prototypes; index += 1) {
    // Blocky families first (block, slab, chunky): pebbles are small clean blocks.
    const { prototype, faces } = quarryPrototype(seed, [0, 1, 4, 2, 3][index % 5], { pebble: true });
    prototype.id = `pebble_${index}`;
    remember(prototype, faces);
  }
  const log = logPrototype(seed);
  const plank = plankPrototype();
  remember(log, []);
  remember(plank, []);
  const boulders = prototypes.filter((prototype) => prototype.id.startsWith("boulder_"));
  const pebbles = prototypes.filter((prototype) => prototype.id.startsWith("pebble_"));

  // Every stone and log of the island in one spatial hash, so stones of two
  // segments that meet never overlap and the wood rests on either.
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
  // The same against the stones of other segments only (the top row of a
  // segment overlaps itself on purpose; it must not overlap a neighbour's).
  const fitsOthers = (point, radius, overlap, segmentId) => neighbours(point)
    .every((other) => other.segment === segmentId || length(sub(point, other.plan)) >= overlap * (radius + other.radius));
  const stones = [];
  const keep = (stone) => {
    const key = `${Math.floor(stone.plan[0] / cellSize)},${Math.floor(stone.plan[1] / cellSize)}`;
    if (!hash.has(key)) hash.set(key, []);
    hash.get(key).push(stone);
    stones.push(stone);
  };
  // The closest any point of a placement comes to the outline from the water
  // side (negative when it reaches inside).
  const clearance = (points) => {
    let least = Infinity;
    for (const point of points) least = Math.min(least, outline.signedDistance([point[0], -point[2]]));
    return least;
  };

  const records = [];
  const segmentSummaries = [];
  // ------------------------------------------------------------ closures
  // A wall: a concrete face along the outline from just above the land edge
  // (its coping) to below the water. A ramp: a slab running out from the land
  // edge at ramp_grade to under the water, between two low side walls, with
  // the face under the land edge beside it.
  const closureRule = settings.closure;
  const closureSummaries = [];
  // Each ramp's plan footprint: the segments beside it cut their slope there
  // and keep their stones clear of it, like a mapped slipway.
  const rampStructures = [];
  for (const piece of plan.closures) {
    closureSummaries.push({ id: piece.id, kind: piece.closure_kind, s_m: [roundCoordinate(outline.wrap(piece.s0)), roundCoordinate(piece.s1 > outline.perimeter ? outline.wrap(piece.s1) : piece.s1)], source_keys: [...piece.source_keys], reason: piece.reason, reference: piece.reference });
    if (piece.closure_kind === "none") continue;
    const mesh = { vertices: [], normals: [], indices: [] };
    const stations = [piece.s0, ...outline.breakpoints(piece.s0, piece.s1), piece.s1];
    for (let s = piece.s0 + 2; s < piece.s1 - 0.5; s += 2) if (!stations.some((station) => Math.abs(station - s) < 0.5)) stations.push(s);
    stations.sort((left, right) => left - right);
    const edge = stations.map((s) => {
      const point = outline.pointAt(Math.min(Math.max(s, piece.s0 + 0.01), piece.s1 - 0.01));
      const exact = outline.pointAt(s);
      const land = landAt(point);
      invariant(land != null, `Shoreline closure ${piece.id} has no land under the outline at s=${s.toFixed(2)}`);
      return { s, point: exact, land, top: land + closureRule.coping_m, normal: outline.normalAt(s, 1.5, piece.s0, piece.s1) };
    });
    // The face under the land edge, per outline edge between stations.
    for (let i = 0; i + 1 < edge.length; i += 1) {
      const [a, b] = [edge[i], edge[i + 1]];
      const facing = unit3([(a.normal[0] + b.normal[0]) / 2, 0, -(a.normal[1] + b.normal[1]) / 2]);
      const ids = [
        pushVertex(mesh, [a.point[0], a.top, -a.point[1]], facing),
        pushVertex(mesh, [b.point[0], b.top, -b.point[1]], facing),
        pushVertex(mesh, [b.point[0], closureRule.wall_bottom_y_m, -b.point[1]], facing),
        pushVertex(mesh, [a.point[0], closureRule.wall_bottom_y_m, -a.point[1]], facing),
      ];
      pushTriangle(mesh, [ids[0], ids[1], ids[2]], facing);
      pushTriangle(mesh, [ids[0], ids[2], ids[3]], facing);
    }
    if (piece.closure_kind === "ramp") {
      // The slab, straight out from the mean land edge along the mean normal.
      const normal = unit(edge.reduce((sum, station) => add(sum, station.normal), [0, 0]));
      const run = (edge.reduce((sum, station) => sum + station.land, 0) / edge.length - closureRule.ramp_bottom_y_m) / closureRule.ramp_grade;
      const slabTop = (station, d) => station.land - closureRule.ramp_grade * d;
      // The slab's normal leans down the ramp (the shader lays its panels from it).
      const slabNormal = unit3([closureRule.ramp_grade * normal[0], 1, -closureRule.ramp_grade * normal[1]]);
      const ids = [];
      for (const station of edge) {
        const outer = add(station.point, scale(normal, run));
        ids.push([
          pushVertex(mesh, [station.point[0], station.land + 0.01, -station.point[1]], slabNormal),
          pushVertex(mesh, [outer[0], slabTop(station, run), -outer[1]], slabNormal),
        ]);
      }
      for (let i = 0; i + 1 < ids.length; i += 1) {
        pushTriangle(mesh, [ids[i][0], ids[i + 1][0], ids[i + 1][1]], slabNormal);
        pushTriangle(mesh, [ids[i][0], ids[i + 1][1], ids[i][1]], slabNormal);
      }
      const footprint = [...edge.map((station) => station.point), ...edge.map((station) => add(station.point, scale(normal, run))).reverse()];
      rampStructures.push({ source_key: piece.id, kind: "ramp", slope: "cut", clearance_m: 0.15, under_drop_m: null, area: indexedArea([[signedRingArea(footprint) > 0 ? footprint : footprint.reverse()]]) });
      // Side walls: from ramp_wall_m above the slab down to below the toe,
      // faced both ways (the curb seen from the ramp, its back from the water).
      for (const [station, sign] of [[edge[0], -1], [edge.at(-1), 1]]) {
        const tangent = [-normal[1], normal[0]];
        const outer = add(station.point, scale(normal, run));
        const corners = [
          [station.point[0], station.land + closureRule.ramp_wall_m, -station.point[1]],
          [outer[0], slabTop(station, run) + closureRule.ramp_wall_m, -outer[1]],
          [outer[0], closureRule.wall_bottom_y_m, -outer[1]],
          [station.point[0], closureRule.wall_bottom_y_m, -station.point[1]],
        ];
        for (const side of [sign, -sign]) {
          const facing = [tangent[0] * side, 0, -tangent[1] * side];
          const wall = corners.map((corner) => pushVertex(mesh, corner, facing));
          pushTriangle(mesh, [wall[0], wall[1], wall[2]], facing);
          pushTriangle(mesh, [wall[0], wall[2], wall[3]], facing);
        }
      }
    }
    invariant(mesh.indices.length > 0, `Shoreline closure ${piece.id} built no faces`);
    records.push({
      object_key: `shoreline-wall:${piece.id}:0`,
      segment: piece.id,
      section: 0,
      source_keys: [...new Set([PLAYABLE_BOUNDARY_SOURCE_KEY, ...piece.source_keys])].sort(),
      material_key: SHORELINE_WALL_MATERIAL,
      ...packMesh(mesh, `shoreline-wall:${piece.id}`),
    });
  }

  // Stones under pebbles.below_m use the clean pebble shapes; stones of
  // big.above_m or more only the irregular families in big.families.
  const familyOf = (prototype) => QUARRY_FAMILIES[Number(prototype.id.split("_")[1]) % QUARRY_FAMILIES.length].name;
  const bigShapes = boulders.filter((prototype) => rules.big.families.includes(familyOf(prototype)));
  invariant(bigShapes.length > 0, "Shoreline stones.big.families names no prototype's family");
  const shapeFor = (size, rng) => {
    const pool = size < rules.pebbles.below_m ? pebbles : size >= rules.big.above_m ? bigShapes : boulders;
    return pool[Math.floor(rng() * pool.length)];
  };
  // `base` tilted by up to maxDeg about a random horizontal axis.
  const leanUp = (base, maxDeg, rng) => {
    const tilt = ((rng() - 0.5) * 2 * maxDeg * Math.PI) / 180;
    const axis = rng() * Math.PI * 2;
    return unit3(add3(unit3(base), [Math.sin(tilt) * Math.cos(axis), 0, Math.sin(tilt) * Math.sin(axis)]));
  };
  // A dumped stone comes to rest on one of its broad faces (a face of at
  // least posture.broad_face of its largest face's area; each equally often
  // when posture.even, otherwise larger faces more often), that face against
  // its bed (`up` is the bed's normal, tilted up to tiltDeg), turned any way
  // about it, and stands no taller than posture.max_aspect times its
  // narrower width: no teeth or tombstones. After eight draws that fail, it
  // lies on its flattest face. Returns the rotation and, for a stone of size
  // 1, its lowest and highest point relative to its centroid and its mean
  // horizontal half-extent (radius).
  const orient = (prototype, up, tiltDeg, rng, posture) => {
    const { faces, points } = shapes.get(prototype.id);
    const largest = faces.reduce((best, face) => (face.area > best.area ? face : best), faces[0]);
    const broad = faces.filter((face) => face.area >= posture.broad_face * largest.area);
    const pose = (face, bed, yaw) => {
      const turned = quaternionMultiply(quaternionFor(bed, yaw), arcQuaternion(face.n, [0, -1, 0]));
      const length4 = Math.hypot(...turned);
      const q = turned.map((value) => value / length4);
      const placed = placedPoints(points, q, [1, 1, 1], [0, 0, 0]);
      const span = (axis) => Math.max(...placed.map((p) => p[axis])) - Math.min(...placed.map((p) => p[axis]));
      const low = Math.min(...placed.map((p) => p[1]));
      const high = Math.max(...placed.map((p) => p[1]));
      const aspect = (high - low) / Math.min(span(0), span(2));
      return { q, low, high, radius: (span(0) + span(2)) / 4, aspect, upright: aspect > posture.max_aspect };
    };
    for (let attempt = 0; attempt < 8; attempt += 1) {
      const weight = (face) => (posture.even ? 1 : face.area);
      let pickAt = rng() * broad.reduce((sum, face) => sum + weight(face), 0);
      let face = broad[broad.length - 1];
      for (const candidate of broad) {
        pickAt -= weight(candidate);
        if (pickAt <= 0) {
          face = candidate;
          break;
        }
      }
      const result = pose(face, leanUp(up, tiltDeg, rng), rng() * Math.PI * 2);
      if (!result.upright) return result;
    }
    // The flattest of every face, untilted.
    const yaw = rng() * Math.PI * 2;
    return faces.map((face) => pose(face, unit3(up), yaw)).reduce((best, candidate) => (candidate.aspect < best.aspect ? candidate : best));
  };
  const crestPosture = rules.posture.crest;
  const heapPosture = rules.posture.heap;
  // A size in range, mostly toward its low end for skew > 1.
  const pickSize = (range, skew, rng) => lerp(range[0], range[1], rng() ** skew);

  // A segment's stone tone and, at each end, the joint the shader blends it
  // across (riprap.gdshader): the outline point there (world x, z) and the
  // direction into the segment, with the neighbour's tone. The direction is
  // the chord to the point the blend ends at: the outline's own direction at
  // an end is often a corner's or a jog's, nothing like the shore's.
  const toneOf = (piece) => [...settings.tones.palettes[piece.stone_tone]];
  const jointOf = (s, inward, span, neighbour) => {
    const point = outline.pointAt(s);
    const chord = unit(sub(outline.pointAt(s + inward * Math.min(settings.tones.blend_m, span)), point));
    return {
      at: [roundCoordinate(point[0]), roundCoordinate(-point[1])],
      along: [round3(chord[0]), round3(-chord[1])],
      stone: toneOf(neighbour),
    };
  };
  // The OSM structures the ramp closures build (their own footprints cut the slope).
  const builtByRamps = new Set(plan.closures.filter((piece) => piece.closure_kind === "ramp").flatMap((piece) => piece.source_keys));
  // A ramp's cut: the convex hull of its footprint, with its bounds.
  const hullOf = (ramp) => {
    const hull = convexHull(ramp.area.multi.flatMap((part) => part[0]));
    const xs = hull.map((point) => point[0]);
    const ys = hull.map((point) => point[1]);
    return { hull, bounds: { min_x: Math.min(...xs), max_x: Math.max(...xs), min_y: Math.min(...ys), max_y: Math.max(...ys) } };
  };
  // Whether a plan point lies inside a counterclockwise hull grown by `grow`.
  const insideHull = (hull, point, grow = 0) => hull.every((a, index) => {
    const edge = sub(hull[(index + 1) % hull.length], a);
    return cross(edge, sub(point, a)) / length(edge) > -grow;
  });
  // Whether any vertex ({ plan }) of a polygon lies within a hull's bounds.
  const nearHulls = (hulls, vertices) => hulls.some(({ bounds }) => vertices.some(({ plan }) => nearBounds({ bounds }, plan, 0.01)));
  // A convex polygon of vertices ({ plan, y, normal }) as a fan of triangles,
  // the hulls cut out of it. With a skirt ({ mesh, bottom }), each cut edge
  // that runs along a hull edge also gets a rock face in skirt.mesh, from the
  // cut down to skirt.bottom, facing into the hull (the ramp), so the open edge
  // of the slope never shows the water through it.
  const pushCut = (mesh, polygon, hulls, skirt = null) => {
    let pieces = [polygon];
    hulls.forEach(({ hull }, h) => {
      pieces = pieces.flatMap((piece) => subtractHull(piece, hull, h));
    });
    for (const piece of pieces) {
      const ids = piece.map((vertex) => pushVertex(mesh, [vertex.plan[0], vertex.y, -vertex.plan[1]], vertex.normal));
      for (let k = 1; k + 1 < ids.length; k += 1) pushTriangle(mesh, [ids[0], ids[k], ids[k + 1]], [0, 1, 0]);
      if (skirt == null) continue;
      piece.forEach((a, index) => {
        const b = piece[(index + 1) % piece.length];
        if (a.cut == null || b.cut == null || a.cut[0] !== b.cut[0] || a.cut[1] !== b.cut[1]) return;
        // Only the part along the hull edge itself (not its line beyond).
        const hull = hulls[a.cut[0]].hull;
        const start = hull[a.cut[1]];
        const edge = sub(hull[(a.cut[1] + 1) % hull.length], start);
        const span = dot(edge, edge);
        const ta = dot(sub(a.plan, start), edge) / span;
        const tb = dot(sub(b.plan, start), edge) / span;
        const lo = Math.max(0, Math.min(ta, tb));
        const hi = Math.min(1, Math.max(ta, tb));
        if (hi - lo < 1e-6) return;
        const at = (t) => {
          const f = Math.abs(tb - ta) < 1e-12 ? 0 : (t - ta) / (tb - ta);
          return { plan: add(start, scale(edge, t)), y: lerp(a.y, b.y, f) };
        };
        // Into the hull: left of a counterclockwise edge (world x, z); set 2 cm
        // back behind the ramp's side, which shares the hull's edge.
        const facing = unit3([-edge[1], 0, -edge[0]]);
        const back = scale(unit([edge[1], -edge[0]]), 0.02);
        const [p, q] = [at(lo), at(hi)].map((vertex) => ({ plan: add(vertex.plan, back), y: vertex.y }));
        const top = [p, q].map((vertex) => pushVertex(skirt.mesh, [vertex.plan[0], vertex.y, -vertex.plan[1]], facing));
        const bottom = [p, q].map((vertex) => pushVertex(skirt.mesh, [vertex.plan[0], skirt.bottom, -vertex.plan[1]], facing));
        pushTriangle(skirt.mesh, [top[0], top[1], bottom[1]], facing);
        pushTriangle(skirt.mesh, [top[0], bottom[1], bottom[0]], facing);
      });
    }
  };
  for (const segment of plan.segments) {
    const { s0, s1 } = segment;
    const [clipLo, clipHi] = segment.clip;
    const windowBounds = multiPolygonBounds(segment.window);
    // An OSM structure a ramp closure builds (the north slipway) is cut by the
    // ramp's own footprint, not again by its mapped one.
    const structures = [
      ...structuresNear(settings, playableObjects, rawOsm, segment.window).filter((structure) => !builtByRamps.has(structure.source_key)),
      ...rampStructures.filter((ramp) => boundsOverlap(ramp.area.bounds, windowBounds)),
    ];
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
        const margin = rules.cobble.path_clearance_m + radius;
        for (const road of nearRoads) {
          if (!nearBounds(road, point, margin)) continue;
          if (pointInMultiPolygon(point, road.multi) || edgeDistance(road, point) < margin) return "path";
        }
      }
      return null;
    };

    // Stations: every station_m, plus each land-edge breakpoint and ring
    // vertex on the outline so the slope's top edge follows the land edge
    // exactly.
    const sFirst = segment.join_start ? s0 : s0 + CAP_INSET_M;
    const sLast = segment.join_end ? s1 : s1 - CAP_INSET_M;
    const forced = new Set([sFirst, sLast, ...outline.breakpoints(sFirst, sLast)]);
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
          if (along > sFirst && along < sLast) forced.add(along);
        }
      }
    }
    const stationList = [...forced];
    const count = Math.ceil((sLast - sFirst) / slope.station_m);
    for (let step = 1; step < count; step += 1) {
      const s = sFirst + ((sLast - sFirst) * step) / count;
      if (![...forced].some((f) => Math.abs(f - s) < slope.station_m * 0.35)) stationList.push(s);
    }
    stationList.sort((left, right) => left - right);

    // The crest at s: this segment's crest_rise_m and crest_fill_scale, blended
    // either side of a joint into the joined segment's (half and half at the
    // joint itself, so both compute the same crest there). A blend reaches at
    // most joint_blend_m and half of either segment.
    const span = s1 - s0;
    // A segment without crest rows is the lower slope of a crest another
    // segment builds (the far side of the north-west slit): no shoulder, no core.
    const crestRows = segment.crest_rows !== false;
    // `rows` (1 with crest rows, 0 without) blends the cross-section's shoulder
    // and core across a joint between the two kinds.
    const mixCrest = (a, b, t) => ({ rise: [lerp(a.rise[0], b.rise[0], t), lerp(a.rise[1], b.rise[1], t)], fill: lerp(a.fill, b.fill, t), rows: lerp(a.rows, b.rows, t) });
    const ownCrest = { rise: segment.crest_rise_m, fill: segment.crest_fill_scale, rows: crestRows ? 1 : 0 };
    const blendStart = segment.crest_previous ? Math.min(berm.joint_blend_m, span / 2, segment.crest_previous.span / 2) : 0;
    const blendEnd = segment.crest_next ? Math.min(berm.joint_blend_m, span / 2, segment.crest_next.span / 2) : 0;
    const crestAt = (s) => {
      let crest = ownCrest;
      if (blendStart > 0 && s - s0 < blendStart) crest = mixCrest(segment.crest_previous, crest, 0.5 + (0.5 * Math.max(0, s - s0)) / blendStart);
      if (blendEnd > 0 && s1 - s < blendEnd) crest = mixCrest(segment.crest_next, crest, 0.5 + (0.5 * Math.max(0, s1 - s)) / blendEnd);
      return crest;
    };

    // Cross-section per station: the shoulder flat at the land edge; the
    // crest's core, rising over berm.inner_m to `core` above it (below_crest_m
    // under the lowest crest the photos show, so the stones bedded on it top
    // out at the crest) and running `width` out, falling drop_per_m; then the
    // DEM gradient down to the toe under the water. The core is what shows
    // between the crest stones, so from the verge no water shows between them.
    // A section whose outward line meets the outline again before its toe (a
    // narrow inlet) is clamped there: its profile, squeezed into the inlet,
    // falls to the land on the far side instead.
    const capTaper = (s) => (segment.join_start ? 1 : smoothstep(0, berm.cap_taper_m, s - s0)) * (segment.join_end ? 1 : smoothstep(0, berm.cap_taper_m, s1 - s));
    let clampedCount = 0;
    const sections = [];
    const crestEndOf = (section) => section.shoulder + section.inner + section.width;
    const unclampedToeOf = (section) => crestEndOf(section)
      + (section.top + section.core - berm.drop_per_m * section.width - slope.toe_y_m) / section.gradient;
    // The underlay's height without relief at distance d out.
    const profileAt = (section, d) => {
      const { top, shoulder, core, inner, width, gradient } = section;
      if (d <= shoulder) return top;
      if (d <= shoulder + inner) return top + core * smoothstep(0, 1, (d - shoulder) / inner);
      if (d <= shoulder + inner + width) return top + core - berm.drop_per_m * (d - shoulder - inner);
      return top + core - berm.drop_per_m * width - gradient * (d - shoulder - inner - width);
    };
    const planeAt = (section, d) => {
      const base = profileAt(section, d);
      if (!section.clamp) return base;
      const { width, far } = section.clamp;
      const blend = Math.min(1.5, 0.5 * Math.max(1e-6, width - section.shoulder));
      return lerp(base, far, smoothstep(width - blend, width, d));
    };
    // Where the underlay first dips under the water plane (past the toe when it never does).
    const waterlineOf = (section) => {
      for (let d = 0; d <= section.toe_m + 1e-9; d += 0.05) if (planeAt(section, d) < WATER_Y_M) return d;
      return section.toe_m + 1;
    };
    for (const s of stationList) {
      const point = outline.pointAt(s);
      const normal = outline.normalAt(s, 3, clipLo, clipHi);
      const land = landAt(point);
      invariant(land != null, `Shoreline segment ${segment.id} has no land under the outline at s=${s}`);
      // The land's normal just inside the edge (world x, y, z), for the shoulder's shading.
      const inland = add(point, scale(normal, -0.5));
      const tangent = [-normal[1], normal[0]];
      const h0 = landAt(inland) ?? land;
      const ht = landAt(add(inland, scale(tangent, 0.5))) ?? h0;
      const hn = landAt(add(inland, scale(normal, -0.5))) ?? h0;
      const gradientVector = add(scale(tangent, (ht - h0) / 0.5), scale(normal, -(hn - h0) / 0.5));
      const landNormal = unit3([-gradientVector[0], 1, gradientVector[1]]);
      const crest = crestAt(s);
      const section = {
        s, point, normal, land, landNormal,
        top: land + bias,
        gradient: smoothedGradient(s),
        shoulder: lerp(0.1, slope.shoulder_m, crest.rows),
        // At a capped end (a pier, ramp or the causeway beside it) the core
        // sinks to the land over the last cap_taper_m, so the end face stays low.
        core: crest.rows * Math.max(0, crest.rise[0] - berm.below_crest_m) * capTaper(s),
        inner: lerp(0.05, berm.inner_m, crest.rows),
        width: crest.rows * bermWidthAt(s),
        clamp: null,
      };
      // The fall that reaches the smoothed waterline.
      const run = smoothedWaterline(s) - crestEndOf(section);
      const fall = section.top + section.core - berm.drop_per_m * section.width - WATER_Y_M;
      section.gradient = Math.max(slope.waterline.gradient_m_per_m[0], Math.min(slope.waterline.gradient_m_per_m[1], fall / Math.max(run, 0.5)));
      section.toe_m = unclampedToeOf(section);
      const hit = outline.rayHit(point, normal, section.toe_m + slope.clamp_reach_m);
      if (hit) {
        const width = hit.t - 0.02;
        if (width < MINIMUM_CLAMP_WIDTH_M) continue;
        const far = landAt(add(hit.point, scale(normal, 0.05)));
        invariant(far != null, `Shoreline segment ${segment.id} at s=${s.toFixed(2)} meets the outline again ${hit.t.toFixed(2)} m out but finds no land there`);
        section.clamp = { width, far: far + bias };
        section.shoulder = Math.min(slope.shoulder_m, Math.max(0.05, width * 0.3));
        section.toe_m = width;
        clampedCount += 1;
      }
      section.water_m = waterlineOf(section);
      sections.push(section);
    }
    invariant(sections.length >= 2, `Shoreline segment ${segment.id} has fewer than two cross-sections`);
    // The visible underlay: the plane with boulder-scale relief fading in
    // behind the shoulder (and out again at a clamped section's far edge, so it
    // meets the land there exactly).
    const surfaceAt = (section, d, east, north) => {
      const past = Math.max(0, d - section.shoulder);
      let fade = smoothstep(0, slope.top_blend_m, past);
      if (section.clamp) fade *= 1 - smoothstep(Math.max(0, section.clamp.width - section.shoulder - 0.6), section.clamp.width - section.shoulder, past);
      const base = planeAt(section, d);
      if (section.clamp && past >= section.clamp.width - section.shoulder - 1e-6) return base;
      return base + slope.relief_m * rockRelief(seed, east, north, slope.relief_wavelength_m) * fade;
    };

    // ------------------------------------------------------------ underlay slope
    // Columns: the shoulder's edge, the core's inner face (two), across the
    // crest (two), then `columns` down the fall to the toe; a clamped section
    // squeezes the same columns into its inlet.
    const lastColumn = slope.columns + 4;
    const columnsOf = (section) => {
      const crestEnd = crestEndOf(section);
      const toe = unclampedToeOf(section);
      const ds = [section.shoulder, section.shoulder + section.inner * 0.5, section.shoulder + section.inner, section.shoulder + section.inner + section.width * 0.5, crestEnd];
      for (let k = 1; k <= slope.columns; k += 1) ds.push(crestEnd + ((toe - crestEnd) * k) / slope.columns);
      if (!section.clamp) return ds;
      return ds.map((d) => section.shoulder + ((d - section.shoulder) * (section.clamp.width - section.shoulder)) / (toe - section.shoulder));
    };
    const grid = sections.map((section) => columnsOf(section).map((d, column) => {
      const plan2 = add(section.point, scale(section.normal, d));
      const y = column === 0 ? section.top : surfaceAt(section, d, plan2[0], plan2[1]);
      return { d, plan: plan2, world: [plan2[0], y, -plan2[1]] };
    }));
    // A grid point the outline's own wiggles put back over the land (beside a
    // pier corner or a notch at a capped end) is left out, with every face
    // that uses it: the underlay stays visual-only over the water.
    const open = grid.map((row) => row.map((cell) => outline.signedDistance(cell.plan) > 0.005));
    const vertexNormal = (i, j) => {
      const at = (a, b) => grid[Math.max(0, Math.min(grid.length - 1, a))][Math.max(0, Math.min(lastColumn, b))].world;
      const across = sub3(at(i + 1, j), at(i - 1, j));
      const down = sub3(at(i, j + 1), at(i, j - 1));
      let normal = length3(cross3(across, down)) > 1e-9 ? unit3(cross3(across, down)) : [0, 1, 0];
      if (normal[1] < 0) normal = scale3(normal, -1);
      return normal;
    };
    // Structures whose slope is "cut" open a hole in the slope: a ramp exactly
    // along its footprint's hull (its inner edge follows the outline), an OSM
    // slipway by whole quads.
    const cuts = structures.filter((structure) => structure.slope === "cut" && structure.kind !== "ramp");
    const rampHulls = structures.filter((structure) => structure.kind === "ramp").map(hullOf);
    const cutAway = (points) => {
      const centroid = scale(points.reduce((sum, p) => add(sum, p), [0, 0]), 1 / points.length);
      return cuts.some((structure) => nearBounds(structure.area, centroid, structure.clearance_m)
        && (pointInMultiPolygon(centroid, structure.area.multi) || edgeDistance(structure.area, centroid) < structure.clearance_m));
    };
    const slopeSections = Math.max(1, Math.round((s1 - s0) / slope.section_m));
    const recordOf = (s) => Math.min(slopeSections - 1, Math.max(0, Math.floor(((s - s0) / (s1 - s0)) * slopeSections)));
    const meshes = Array.from({ length: slopeSections }, () => ({ vertices: [], normals: [], indices: [], shared: new Map() }));
    // The parts of the underlay that stand bare (a clamped section's fill, a
    // capped end's face, a strip with no verge) are rock faces, not the dark
    // gaps of a heap.
    const faces = Array.from({ length: slopeSections }, () => ({ vertices: [], normals: [], indices: [], shared: new Map() }));
    // The shoulder strip, from the outline (d = 0) to the slope's first column,
    // flat at the land edge's height; its normals are the land's at the edge
    // (its UVs, world x / 10 and z / 10, are rebuilt on unpacking), so the
    // verge's ground cover continues across the outline in the same tone. Its
    // inner edge meets what is drawn inside: the riprap overlay (overlay_bias_m
    // up) where the segment's breakwater covers the land there, else the land
    // itself (a gap between two breakwaters), so no open step shows the void.
    const verges = Array.from({ length: slopeSections }, () => ({ vertices: [], normals: [], indices: [] }));
    const band = indexedArea(segment.inner);
    const inner = sections.map((section) => {
      const inside = add(section.point, scale(section.normal, -0.1));
      const covered = nearBounds(band, inside, 0) && pointInMultiPolygon(inside, band.multi);
      return [section.point[0], covered ? section.top : section.land, -section.point[1]];
    });
    for (let i = 0; i + 1 < grid.length; i += 1) {
      if (!open[i][0] || !open[i + 1][0] || cutAway([sections[i].point, sections[i + 1].point, grid[i + 1][0].plan, grid[i][0].plan])) continue;
      // A segment without crest rows is rock to its land edge: no verge strip.
      const mesh = (crestRows ? verges : faces)[recordOf((sections[i].s + sections[i + 1].s) / 2)];
      const corners = [inner[i], inner[i + 1], grid[i + 1][0].world, grid[i][0].world];
      const normals = [sections[i].landNormal, sections[i + 1].landNormal, sections[i + 1].landNormal, sections[i].landNormal];
      const vertices = corners.map((corner, k) => ({ plan: [corner[0], -corner[2]], y: corner[1], normal: normals[k] }));
      if (nearHulls(rampHulls, vertices)) {
        const skirt = { mesh: faces[recordOf((sections[i].s + sections[i + 1].s) / 2)], bottom: closureRule.wall_bottom_y_m };
        pushCut(mesh, [vertices[0], vertices[1], vertices[2]], rampHulls, skirt);
        pushCut(mesh, [vertices[0], vertices[2], vertices[3]], rampHulls, skirt);
        continue;
      }
      const ids = corners.map((corner, k) => pushVertex(mesh, corner, normals[k]));
      pushTriangle(mesh, [ids[0], ids[1], ids[2]], [0, 1, 0]);
      pushTriangle(mesh, [ids[0], ids[2], ids[3]], [0, 1, 0]);
    }
    for (let i = 0; i + 1 < grid.length; i += 1) {
      const mesh = (sections[i].clamp && sections[i + 1].clamp ? faces : meshes)[recordOf((sections[i].s + sections[i + 1].s) / 2)];
      const index = (row, column) => {
        const key = row * (lastColumn + 1) + column;
        if (!mesh.shared.has(key)) mesh.shared.set(key, pushVertex(mesh, grid[row][column].world, vertexNormal(row, column)));
        return mesh.shared.get(key);
      };
      for (let column = 0; column < lastColumn; column += 1) {
        if (!open[i][column] || !open[i + 1][column] || !open[i + 1][column + 1] || !open[i][column + 1]) continue;
        if (cutAway([grid[i][column].plan, grid[i + 1][column].plan, grid[i + 1][column + 1].plan, grid[i][column + 1].plan])) continue;
        const cell = (row, col) => ({ plan: grid[row][col].plan, y: grid[row][col].world[1], normal: vertexNormal(row, col) });
        const quad = [cell(i, column), cell(i + 1, column), cell(i + 1, column + 1), cell(i, column + 1)];
        if (nearHulls(rampHulls, quad)) {
          const [qa, qb, qc, qd] = quad;
          const skirt = { mesh: faces[recordOf((sections[i].s + sections[i + 1].s) / 2)], bottom: closureRule.wall_bottom_y_m };
          for (const triangle of (i + column) % 2 === 0 ? [[qa, qb, qc], [qa, qc, qd]] : [[qa, qb, qd], [qb, qc, qd]]) pushCut(mesh, triangle, rampHulls, skirt);
          continue;
        }
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
    // End caps at the capped ends (not at joints): rock faces closing the
    // slope, from the cross-section down to below the toe.
    for (const [rowIndex, sign, capped] of [[0, -1, !segment.join_start], [grid.length - 1, 1, !segment.join_end]]) {
      if (!capped) continue;
      const section = sections[rowIndex];
      const tangent = [-section.normal[1], section.normal[0]];
      const facing = [tangent[0] * sign, 0, -tangent[1] * sign];
      const mesh = faces[rowIndex === 0 ? 0 : slopeSections - 1];
      const row = [{ world: inner[rowIndex] }, ...grid[rowIndex]];
      const usable = [true, ...open[rowIndex]];
      const tops = row.map((cell, column) => (usable[column] ? pushVertex(mesh, cell.world, facing) : -1));
      const bottoms = row.map((cell, column) => (usable[column] ? pushVertex(mesh, [cell.world[0], slope.end_cap_bottom_y_m, cell.world[2]], facing) : -1));
      for (let column = 0; column < row.length - 1; column += 1) {
        if (!usable[column] || !usable[column + 1]) continue;
        // A cap face inside a ramp's footprint is the ramp's to close.
        const middle = [(row[column].world[0] + row[column + 1].world[0]) / 2, -(row[column].world[2] + row[column + 1].world[2]) / 2];
        if (rampHulls.some(({ hull }) => insideHull(hull, middle))) continue;
        pushTriangle(mesh, [tops[column], bottoms[column], bottoms[column + 1]], facing);
        pushTriangle(mesh, [tops[column], bottoms[column + 1], tops[column + 1]], facing);
      }
    }
    meshes.forEach((mesh, index) => {
      if (mesh.indices.length === 0) return;
      records.push({
        object_key: `shoreline-slope:${segment.id}:${index}`,
        segment: segment.id,
        section: index,
        source_keys: [segment.source_key],
        material_key: SHORELINE_SLOPE_MATERIAL,
        ...packMesh(mesh, `shoreline-slope:${segment.id}:${index}`),
      });
    });
    invariant(records.some((record) => record.segment === segment.id), `Shoreline segment ${segment.id} has no slope triangles`);
    faces.forEach((mesh, index) => {
      if (mesh.indices.length === 0) return;
      records.push({
        object_key: `shoreline-face:${segment.id}:${index}`,
        segment: segment.id,
        section: index,
        source_keys: [segment.source_key],
        material_key: SHORELINE_FACE_MATERIAL,
        ...packMesh(mesh, `shoreline-face:${segment.id}:${index}`),
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
        ...packMesh(mesh, `shoreline-verge:${segment.id}:${index}`),
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
      const a = sections[low];
      const b = sections[high];
      const span = b.s - a.s;
      const t = span > 0 ? Math.max(0, Math.min(1, (s - a.s) / span)) : 0;
      // A clamped neighbour clamps the interpolated section too.
      const clamp = a.clamp || b.clamp
        ? { width: lerp(a.clamp?.width ?? a.toe_m, b.clamp?.width ?? b.toe_m, t), far: lerp(a.clamp?.far ?? a.top, b.clamp?.far ?? b.top, t) }
        : null;
      return {
        s,
        point: outline.pointAt(s),
        normal: unit(add(scale(a.normal, 1 - t), scale(b.normal, t))),
        land: lerp(a.land, b.land, t),
        top: lerp(a.top, b.top, t),
        gradient: lerp(a.gradient, b.gradient, t),
        shoulder: lerp(a.shoulder, b.shoulder, t),
        core: lerp(a.core, b.core, t),
        inner: lerp(a.inner, b.inner, t),
        width: lerp(a.width, b.width, t),
        water_m: lerp(a.water_m, b.water_m, t),
        toe_m: lerp(a.toe_m, b.toe_m, t),
        clamp,
      };
    };
    const slopeNormal = (section) => unit3([section.gradient * section.normal[0], 1, -section.gradient * section.normal[1]]);
    // The underlay's own normal at distance d out (world x, y, z): flat on the
    // shoulder and the core's top, tilted on its inner face and the fall.
    const bedNormal = (section, d) => {
      const rise = (planeAt(section, d + 0.25) - planeAt(section, Math.max(0, d - 0.25))) / (d + 0.25 - Math.max(0, d - 0.25));
      return unit3([-rise * section.normal[0], 1, rise * section.normal[1]]);
    };
    const planAt = (section, d) => add(section.point, scale(section.normal, d));
    // Plan angle of the shore direction (counterclockwise along the outline).
    const tangentAngle = (section) => Math.atan2(section.normal[0], -section.normal[1]);
    const batchSection = (s) => Math.max(0, Math.floor((s - s0) / rules.section_m));
    // One stone of `prototype` in orientation o, scaled uniformly to `size`,
    // its lowest point at bedY, quantized as it will be packed (position on
    // the 2 mm grid, rotation and size as their packed integers), then
    // settled: where its underside would hang over the visible underlay (on a
    // slope its downhill edge, from the side a dark sliver of void), it is
    // lowered until it touches. Returns its record with its world top and reach.
    const makeStone = ({ band, s, d, plan2, size, prototype, o, bedY, settle = true }) => {
      const rotation = quantizeRotation(o.q);
      const sizeQ = quantizeScale(size);
      const scales = [sizeQ.value, sizeQ.value, sizeQ.value];
      const { points } = shapes.get(prototype.id);
      let origin = [onGrid(plan2[0]), onGrid(bedY - o.low * size), onGrid(-plan2[1])];
      let placed = placedPoints(points, rotation.q, scales, origin);
      if (settle) {
        const section = sectionAtS(s);
        const low = Math.min(...placed.map((p) => p[1]));
        const high = Math.max(...placed.map((p) => p[1]));
        let hang = -Infinity;
        for (const p of placed) {
          if (p[1] > low + (high - low) * 0.35) continue;
          const along = dot(sub([p[0], -p[2]], section.point), section.normal);
          if (along < 0) continue;
          hang = Math.max(hang, p[1] - surfaceAt(section, along, p[0], -p[2]));
        }
        if (hang > -0.01) {
          origin = [origin[0], onGrid(origin[1] - hang - 0.012), origin[2]];
          placed = placedPoints(points, rotation.q, scales, origin);
        }
      }
      return {
        band, s, d, plan: plan2, radius: o.radius * size, prototype, prototypeId: prototype.id, section: batchSection(s), segment: segment.id,
        rotation: rotation.ints, q: rotation.q, scale: [sizeQ.steps], scales, origin, placed,
        top: Math.max(...placed.map((point) => point[1])),
        reach: Math.max(...placed.map((point) => Math.hypot(point[0] - origin[0], point[2] - origin[2]))),
      };
    };
    // Outside the outline, and (beside a ramp) wholly clear of its cut, so no
    // stone overhangs the ramp or the open edge of the slope there.
    const outsideOk = (stone, minimum = SHORELINE_OUTSIDE_CLEARANCE_M) => clearance(stone.placed) >= minimum
      && stone.placed.every((point) => !rampHulls.some(({ hull }) => insideHull(hull, [point[0], -point[2]], 0.05)));
    // Stones never spill past a capped end; across a joint they may.
    const insideEnds = (s, size) => (segment.join_start || s - size * 0.25 >= s0) && (segment.join_end || s + size * 0.25 <= s1);
    // The heap's outward reach at a section: past the toe, but short of the
    // far side of a clamped inlet.
    const heapReach = (section, radius) => (section.clamp ? section.clamp.width - 0.1 - radius : section.toe_m + rules.heap.toe_extra_m);

    // Top row: quarry blocks dumped just beyond the outline, their inner faces
    // at least setback_m out (about the player's radius, so the player is
    // recovered before it can reach into one). Each is buried by a share of
    // its own height, so big stones stand tall and small ones low, up to 5 cm
    // over the crest's highest rise above the land edge; sizes, spacing and
    // the face each rests on vary stone by stone, so the crest skyline breaks
    // up as in the photos. The crest at each stone (crestAt): the back row
    // rises crest_rise_m above the land edge, the top row at most a little
    // more, the crest fill in proportion, and the crest rows are dumped
    // crest_fill_scale as densely as the pilot's.
    const topRule = rules.top;
    for (let s = s0, k = 0; crestRows && s < s1; k += 1) {
      const rng = random(seed, `${segment.id}:top:${k}`);
      const size = pickSize(topRule.size_m, topRule.size_skew, rng);
      const sAt = s + size * 0.5;
      s += size * pick(topRule.spacing, rng);
      if (!insideEnds(sAt, size)) continue;
      const section = sectionAtS(sAt);
      const prototype = shapeFor(size, rng);
      const o = orient(prototype, add3(scale3(bedNormal(section, rules.setback_m + size * 0.4), 0.5), [0, 0.5, 0]), topRule.tilt_deg, rng, crestPosture);
      const height = (o.high - o.low) * size;
      const bury = pick(topRule.bury, rng);
      const maxRise = crestAt(sAt).rise[1] + 0.05;
      const bedAt = (d) => Math.min(planeAt(section, d) - height * bury, section.land + maxRise - height);
      let d = rules.setback_m + o.radius * size + pick(topRule.out_jitter_m, rng);
      if (heapReach(section, o.radius * size) < d) continue;
      let plan2 = planAt(section, d);
      if (blocked(plan2, size * 0.5, false) || !fitsOthers(plan2, o.radius * size, 0.85, segment.id)) continue;
      let stone = makeStone({ band: "top", s: sAt, d, plan2, size, prototype, o, bedY: bedAt(d) });
      const clear = clearance(stone.placed);
      if (clear < rules.setback_m) {
        // Push it out just far enough, once.
        d += rules.setback_m - clear + 0.02;
        plan2 = planAt(section, d);
        stone = makeStone({ band: "top", s: sAt, d, plan2, size, prototype, o, bedY: bedAt(d) });
        if (!outsideOk(stone) || blocked(plan2, size * 0.5, false)) continue;
      }
      if (!outsideOk(stone, 0)) continue;
      keep(stone);
    }
    // Back row: big blocks dumped behind the top row, within depth_m of the
    // setback, aiming their tops rise_m above the land edge (less drop_per_m
    // further out) but always bedded at least 5 cm into the slope, so the big
    // ones rise above the top row and the small ones sit lower in the pile.
    const crest = { ...rules.crest, fill: rules.crest.fill * segment.crest_fill_scale };
    if (crestRows) {
      const meanSize = (crest.size_m[0] + crest.size_m[1]) / 2;
      const target = Math.ceil(((s1 - s0) * crest.depth_m * crest.fill) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${segment.id}:crest`);
      let placed = 0;
      for (let attempt = 0; attempt < target * 12 && placed < target; attempt += 1) {
        const size = pickSize(crest.size_m, crest.size_skew, rng);
        const sAt = lerp(s0, s1, rng());
        if (!insideEnds(sAt, size)) continue;
        const section = sectionAtS(sAt);
        const prototype = shapeFor(size, rng);
        const spread = rng() * crest.depth_m;
        const o = orient(prototype, bedNormal(section, rules.setback_m + size * 0.4 + spread), topRule.tilt_deg, rng, crestPosture);
        const radius = o.radius * size;
        const d = rules.setback_m + radius + spread;
        if (d > heapReach(section, radius)) continue;
        const plan2 = planAt(section, d);
        if (!fits(plan2, radius, rules.heap.overlap) || blocked(plan2, radius, false)) continue;
        const topY = section.land + pick(crestAt(sAt).rise, rng) - crest.drop_per_m * (d - rules.setback_m);
        const bedY = Math.min(planeAt(section, d) - 0.05, topY - (o.high - o.low) * size);
        const stone = makeStone({ band: "top", s: sAt, d, plan2, size, prototype, o, bedY });
        if (!outsideOk(stone)) continue;
        keep(stone);
        placed += 1;
      }
    }
    // Crest fill: mid-sized blocks packed between the top and back rows, so the
    // crest reads as one continuous low heap rather than a row of big stones.
    const crestFill = { ...rules.crest_fill, fill: rules.crest_fill.fill * segment.crest_fill_scale };
    if (crestRows) {
      const meanSize = (crestFill.size_m[0] + crestFill.size_m[1]) / 2;
      const target = Math.ceil(((s1 - s0) * crest.depth_m * crestFill.fill) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${segment.id}:crest-fill`);
      let placed = 0;
      for (let attempt = 0; attempt < target * 15 && placed < target; attempt += 1) {
        const size = pick(crestFill.size_m, rng);
        const sAt = lerp(s0, s1, rng());
        if (!insideEnds(sAt, size)) continue;
        const section = sectionAtS(sAt);
        const prototype = shapeFor(size, rng);
        const spread = rng() * crest.depth_m;
        const o = orient(prototype, bedNormal(section, rules.setback_m + size * 0.4 + spread), topRule.tilt_deg, rng, crestPosture);
        const radius = o.radius * size;
        const d = rules.setback_m + radius + spread;
        if (d > heapReach(section, radius)) continue;
        const plan2 = planAt(section, d);
        if (!fits(plan2, radius, 0.85) || blocked(plan2, radius, false)) continue;
        const riseScale = crestAt(sAt).rise[1] / rules.crest.rise_m[1];
        const bedY = Math.min(planeAt(section, d) - 0.06, section.land + pick(crestFill.rise_m, rng) * riseScale - (o.high - o.low) * size);
        const stone = makeStone({ band: "top", s: sAt, d, plan2, size, prototype, o, bedY });
        if (!outsideOk(stone)) continue;
        keep(stone);
        placed += 1;
      }
    }
    // Chinking: small stones packed between the crest's blocks over the core
    // (from half-way up its inner face to just past its top), each lying flat
    // with its top rise_m above the core and allowed to tuck under its bigger
    // neighbours (overlap), so close by the crest shows stone and dark gaps,
    // not the core's surface.
    const chink = rules.chink;
    if (crestRows && chink.fill > 0) {
      const meanSize = (chink.size_m[0] + chink.size_m[1]) / 2;
      const meanBand = sections.reduce((sum, section) => sum + section.inner * 0.5 + section.width + 0.8, 0) / sections.length;
      const target = Math.ceil(((s1 - s0) * meanBand * chink.fill * segment.crest_fill_scale) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${segment.id}:chink`);
      let placed = 0;
      for (let attempt = 0; attempt < target * 10 && placed < target; attempt += 1) {
        const size = pick(chink.size_m, rng);
        const sAt = lerp(s0, s1, rng());
        if (!insideEnds(sAt, size)) continue;
        const section = sectionAtS(sAt);
        const d = lerp(section.shoulder + section.inner * 0.5, crestEndOf(section) + 0.8, rng());
        if (d > heapReach(section, size * 0.4)) continue;
        const prototype = shapeFor(size, rng);
        const o = orient(prototype, bedNormal(section, d), topRule.tilt_deg, rng, crestPosture);
        const radius = o.radius * size;
        if (d < rules.setback_m + radius) continue;
        const plan2 = planAt(section, d);
        if (!fits(plan2, radius, chink.overlap) || blocked(plan2, radius, false)) continue;
        const height = (o.high - o.low) * size;
        const bedY = Math.min(planeAt(section, d) - 0.03, planeAt(section, d) + pick(chink.rise_m, rng) - height);
        const stone = makeStone({ band: "heap", s: sAt, d, plan2, size, prototype, o, bedY });
        if (!outsideOk(stone)) continue;
        keep(stone);
        placed += 1;
      }
    }
    // Shoulder stones: small blocks in the shoulder between the outline and
    // the top row, rising rise_m above it, so the strip reads as the dirt and
    // stone at the top of the riprap in the photos, not as a trench. Like every
    // stone outside, they keep clear of the outline.
    const shoulderRule = rules.shoulder;
    if (crestRows && shoulderRule.fill > 0) {
      const meanSize = (shoulderRule.size_m[0] + shoulderRule.size_m[1]) / 2;
      const target = Math.ceil(((s1 - s0) * (slope.shoulder_m + 0.4) * shoulderRule.fill) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${segment.id}:shoulder`);
      let placed = 0;
      for (let attempt = 0; attempt < target * 15 && placed < target; attempt += 1) {
        const size = pick(shoulderRule.size_m, rng);
        const sAt = lerp(s0, s1, rng());
        if (!insideEnds(sAt, size)) continue;
        const section = sectionAtS(sAt);
        const prototype = shapeFor(size, rng);
        const o = orient(prototype, [0, 1, 0], topRule.tilt_deg, rng, crestPosture);
        const radius = o.radius * size;
        // Mostly toward the top row, at the foot of the crest, not out on the verge.
        const d = SHORELINE_OUTSIDE_CLEARANCE_M + radius + Math.sqrt(rng()) * (section.shoulder + 0.4);
        if (d > heapReach(section, radius)) continue;
        const plan2 = planAt(section, d);
        if (!fits(plan2, radius, 0.9) || blocked(plan2, radius, false)) continue;
        const bedY = Math.min(planeAt(section, d) - 0.04, section.top + pick(shoulderRule.rise_m, rng) - (o.high - o.low) * size);
        const stone = makeStone({ band: "heap", s: sAt, d, plan2, size, prototype, o, bedY });
        if (!outsideOk(stone)) continue;
        keep(stone);
        placed += 1;
      }
    }
    // Heap: random sequential packing of the slope from behind the crest to
    // just past the toe, largest stones first; neighbours may overlap by up to
    // 1 - overlap of their radii, so the blocks close up into one dumped pile,
    // each buried by a bury share of its height (at least 5 cm). Small stones
    // (pebble shapes) fill only the upper slope, within small_reach_m of the
    // outline, where the player sees them close; lower down the voids between
    // the big blocks stay dark, as on the photographed riprap. From just above
    // the waterline out, a stone stands well clear of the water and shows no
    // more than past_water_m beyond the waterline, or is not kept: one that
    // would just break the surface, or stand off the pile, reads as a wedge
    // floating offshore, and the band's edge must stay where it is when the
    // stones thin out with distance.
    const heap = rules.heap;
    const meanToe = sections.reduce((sum, section) => sum + section.toe_m, 0) / sections.length;
    for (const [classIndex, sizeClass] of heap.classes.entries()) {
      const meanSize = (sizeClass.size_m[0] + sizeClass.size_m[1]) / 2;
      const small = sizeClass.size_m[1] <= rules.pebbles.below_m;
      const reachLimit = small ? heap.small_reach_m : Infinity;
      const area = (s1 - s0) * Math.min(meanToe + heap.toe_extra_m, reachLimit);
      const target = Math.ceil((area * sizeClass.fill) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${segment.id}:heap:${classIndex}`);
      let placed = 0;
      for (let attempt = 0; attempt < target * 12 && placed < target; attempt += 1) {
        const size = pick(sizeClass.size_m, rng);
        const sAt = lerp(s0, s1, rng());
        if (!insideEnds(sAt, size)) continue;
        const section = sectionAtS(sAt);
        const prototype = shapeFor(size, rng);
        let o = orient(prototype, add3(scale3(slopeNormal(section), 0.7), [0, 0.3, 0]), heap.tilt_deg, rng, heapPosture);
        let radius = o.radius * size;
        const d = lerp(rules.setback_m + radius, Math.min(heapReach(section, radius), reachLimit), rng());
        if (d < rules.setback_m + radius) continue;
        // On the crest (the core's top and its inner face) a stone lies on a
        // broad face against the flat bed, as the crest rows do; on the fall
        // it leans with the slope.
        if (crestRows && d < crestEndOf(section) + 0.3) {
          o = orient(prototype, bedNormal(section, d), topRule.tilt_deg, rng, crestPosture);
          radius = o.radius * size;
        }
        const plan2 = planAt(section, d);
        const height = (o.high - o.low) * size;
        const bedY = planeAt(section, d) - Math.max(0.05, height * pick(heap.bury, rng));
        const top = bedY + height;
        const atWater = d > section.water_m - 0.3;
        if (atWater && (top < WATER_Y_M + 0.3 || d > section.water_m + heap.past_water_m)) continue;
        if (!fits(plan2, radius, heap.overlap) || blocked(plan2, radius, false, section.land - top - 0.1)) continue;
        const stone = makeStone({ band: "heap", s: sAt, d, plan2, size, prototype, o, bedY });
        if (stone.top < WATER_Y_M + (atWater ? 0.25 : 0.08) || !outsideOk(stone)) continue;
        // Its farthest point out that shows above the water.
        const shown = stone.placed.filter((point) => point[1] > WATER_Y_M);
        if (Math.max(...shown.map((point) => dot(sub([point[0], -point[2]], section.point), section.normal))) > section.water_m + heap.past_water_m) continue;
        keep(stone);
        placed += 1;
      }
    }
    // Cobbles: a few small blocks set in the band just inside the outline,
    // each wholly inside the band (so the overlay's edge never cuts across
    // one), within reach_m of the outline, more of them toward it, and no
    // higher than the player can walk over without seeming to sink into rock.
    const cobble = { ...rules.cobble, ...(segment.cobble ?? {}) };
    if (cobble.fill > 0) {
      const meanSize = (cobble.size_m[0] + cobble.size_m[1]) / 2;
      const target = Math.ceil(((s1 - s0) * cobble.reach_m * cobble.fill) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${segment.id}:cobble`);
      let placed = 0;
      for (let attempt = 0; attempt < target * 15 && placed < target; attempt += 1) {
        const sAt = lerp(s0, s1, rng());
        const section = sectionAtS(sAt);
        const plan2 = planAt(section, -cobble.reach_m * rng() ** (1 + cobble.outline_bias));
        if (!pointInMultiPolygon(plan2, band.multi, false)) continue;
        const size = pick(cobble.size_m, rng);
        // Mostly buried, a cobble shows only its top: the clean pebble shapes
        // for the small ones, quarry blocks for the bigger.
        const prototype = shapeFor(size, rng);
        // Lying on a broad face, a little tilted, as a stone settles in dirt.
        const o = orient(prototype, [0, 1, 0], 12, rng, { broad_face: 0.5, max_aspect: 0.9, even: true });
        const radius = o.radius * size;
        if (edgeDistance(band, plan2) < size * 0.5 + cobble.edge_m || !fits(plan2, radius, cobble.overlap) || blocked(plan2, size * 0.5, true)) continue;
        const ground = landAt(plan2);
        if (ground == null) continue;
        // Bury it so only its top shows, top_m above the land.
        const bedY = ground + pick(cobble.top_m, rng) - (o.high - o.low) * size;
        const stone = makeStone({ band: "cobble", s: sAt, d: -1, plan2, size, prototype, o, bedY, settle: false });
        if (stone.top > ground + cobble.top_m[1] - 0.004 || edgeDistance(band, plan2) < stone.reach + cobble.edge_m) continue;
        if (stone.placed.some((point) => outline.signedDistance([point[0], -point[2]]) > -0.01)) continue;
        keep(stone);
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
    // A log or plank lying in the stone tops along its length: settled onto the
    // highest support under each half, pitched between them (at most 10
    // degrees), then sunk by `sink` of its thickness into the gaps between the
    // stones, as wood washed up into riprap lies wedged, not balanced. It needs
    // stone under at least `support` of nine points along it, its underside
    // within 20 cm of the stone at all but two, and (unless overWater, a plank
    // at the waterline) every support above the water: no wood bridging a gap
    // or lying out on the water.
    const placeWood = (s, d, yaw, lengthM, thickness, width, prototype, sink, { support, overWater }) => {
      const section = sectionAtS(s);
      const plan2 = planAt(section, d);
      if (blocked(plan2, lengthM * 0.5, false)) return false;
      const along = [Math.cos(yaw), Math.sin(yaw)];
      const samples = [];
      for (let k = 0; k <= 8; k += 1) {
        const t = k / 8 - 0.5;
        const top = heapTop(add(plan2, scale(along, t * lengthM)));
        if (Number.isFinite(top)) samples.push({ t, top });
      }
      if (samples.length < support) return false;
      if (!overWater && Math.min(...samples.map((sample) => sample.top)) < WATER_Y_M + 0.15) return false;
      const halves = [samples.filter((sample) => sample.t < 0), samples.filter((sample) => sample.t >= 0)];
      if (halves.some((half) => half.length === 0)) return false;
      const [low, high] = halves.map((half) => Math.max(...half.map((sample) => sample.top)));
      const pitch = Math.max(-0.17, Math.min(0.17, Math.atan2(high - low, lengthM * 0.5)));
      const restY = Math.min(low, high) + thickness * (0.5 - sink) + Math.abs(Math.tan(pitch)) * lengthM * 0.25;
      const underside = (t) => restY - thickness * 0.5 + Math.tan(pitch) * t * lengthM;
      if (samples.filter((sample) => underside(sample.t) - sample.top > 0.2).length > 2) return false;
      const q = quaternionMultiply(quaternionFor([0, 1, 0], yaw), axisQuaternion([0, 0, 1], pitch));
      const rotation = quantizeRotation(q);
      const dims = [lengthM, thickness, width].map(quantizeScale);
      const scales = dims.map((dim) => dim.value);
      const origin = [onGrid(plan2[0]), onGrid(restY), onGrid(-plan2[1])];
      const placed = placedPoints(shapes.get(prototype.id).points, rotation.q, scales, origin);
      if (clearance(placed) < SHORELINE_OUTSIDE_CLEARANCE_M) return false;
      keep({
        band: "driftwood", s, d, plan: plan2, radius: lengthM * 0.5, prototype, prototypeId: prototype.id, section: batchSection(s), segment: segment.id,
        rotation: rotation.ints, q: rotation.q, scale: dims.map((dim) => dim.steps), scales, origin, placed,
        top: Math.max(...placed.map((point) => point[1])), reach: lengthM * 0.5,
      });
      return true;
    };
    // The first distance out where the underlay dips under height y.
    const distanceDownTo = (section, y) => {
      for (let d = 0; d <= section.toe_m + 1e-9; d += 0.05) if (planeAt(section, d) < y) return d;
      return section.toe_m;
    };
    // Driftwood: a few bleached logs washed up onto the face of the heap below
    // the crest, from_waterline_m out of the waterline, lying roughly along the
    // shore (the 2021 and 2025 photos show several).
    const wood = rules.driftwood;
    for (let s = s0 + wood.spacing_m * 0.5, k = 0; s < s1; s += wood.spacing_m, k += 1) {
      const rng = random(seed, `${segment.id}:driftwood:${k}`);
      if (rng() > wood.acceptance) continue;
      const sAt = Math.min(s1 - 3, Math.max(s0 + 3, s + (rng() - 0.5) * wood.spacing_m * 0.6));
      const section = sectionAtS(sAt);
      if (section.clamp) continue;
      const yaw = tangentAngle(section) + ((rng() - 0.5) * 2 * wood.yaw_jitter_deg * Math.PI) / 180;
      const thickness = 2 * pick(wood.radius_m, rng);
      const d = section.water_m - pick(wood.from_waterline_m, rng);
      if (d < crestEndOf(section) + 0.3) continue;
      placeWood(sAt, d, yaw, pick(wood.length_m, rng), thickness, thickness, log, wood.sink, { support: 7, overWater: false });
    }
    // Planks: boards washed up at the waterline (the 2021 photo shows one
    // beside the landing pier), each at the shore station nearest near_xz.
    for (const [k, board] of rules.planks.entries()) {
      if (board.segment !== segment.id) continue;
      const nearest = outline.nearestS([board.near_xz[0], -board.near_xz[1]]);
      const sAt = nearest < s0 ? nearest + outline.perimeter : nearest;
      invariant(sAt > s0 && sAt < s1, `Shoreline plank ${k} lies outside segment ${segment.id}`);
      // The first spot near there (within 2 m along the shore and half a metre
      // up or down the slope) with stones to rest on.
      let placedPlank = false;
      for (const ds of [0, 0.5, -0.5, 1, -1, 1.5, -1.5, 2, -2]) {
        const section = sectionAtS(sAt + ds);
        const d = distanceDownTo(section, WATER_Y_M + board.above_water_m);
        for (const dd of [0, -0.25, 0.25, -0.5, 0.5]) {
          placedPlank = placeWood(sAt + ds, d + dd, tangentAngle(section) + (board.yaw_deg * Math.PI) / 180, board.length_m, 0.05, board.width_m, plank, 0, { support: 5, overWater: true });
          if (placedPlank) break;
        }
        if (placedPlank) break;
      }
      invariant(placedPlank, `Shoreline plank ${k} has no stones to rest on`);
    }
    const openWater = sections.filter((section) => !section.clamp).map((section) => section.water_m);
    segmentSummaries.push({
      id: segment.id,
      source_key: segment.source_key,
      outline_source_key: segment.outline_source_key,
      s_m: [roundCoordinate(outline.wrap(s0)), roundCoordinate(s1 > outline.perimeter ? outline.wrap(s1) : s1)],
      ends: [segment.join_start ? "joint" : "cap", segment.join_end ? "joint" : "cap"],
      clamped_sections: clampedCount,
      structures: structures.map((structure) => ({ source_key: structure.source_key, kind: structure.kind, slope: structure.slope })),
      // A blend reaches no farther than the segment itself, so a short segment's
      // two ends leave each other alone.
      tone: { stone: toneOf(segment), start: jointOf(s0, 1, s1 - s0, segment.tone_previous), end: jointOf(s1, -1, s1 - s0, segment.tone_next), blend_m: Math.min(settings.tones.blend_m, s1 - s0) },
      top_y_m: [roundCoordinate(Math.min(...sections.map((x) => x.top))), roundCoordinate(Math.max(...sections.map((x) => x.top)))],
      crest_core_m: [roundCoordinate(Math.min(...sections.map((x) => x.core))), roundCoordinate(Math.max(...sections.map((x) => x.core)))],
      gradient_m_per_m: [round3(Math.min(...sections.map((x) => x.gradient))), round3(Math.max(...sections.map((x) => x.gradient)))],
      waterline_m: openWater.length > 0 ? [roundCoordinate(Math.min(...openWater)), roundCoordinate(Math.max(...openWater))] : [0, 0],
      reason: segment.reason,
      reference: segment.reference,
    });
  }

  // ------------------------------------------------------------ mounds
  // A rubble mound standing out in the water, part of a segment's OSM
  // breakwater (the north tip's jetty, w26767328): a flat-topped ridge along
  // centerline_xz, its crest crest_y_m high with a slight crown, its sides
  // falling at `gradient` to toe_y_m. The breakwater polygon traces the stone
  // above the water, so each side's waterline lies at the polygon's edge
  // (half_width_m bounds it), which sets the crest's width (at least
  // crest_min_m); over taper_m at the far end the crest sinks under the water.
  // Big blocks lie flat on the crest, the heap's classes on the sides; nothing
  // reaches the outline or a ramp. Its records and stone batches belong to the
  // segment, numbered from MOUND_SECTION_BASE on.
  for (const mound of settings.mounds) {
    const segment = plan.segments.find((piece) => piece.id === mound.segment);
    invariant(segment, `Shoreline mound ${mound.id} names unknown segment ${mound.segment}`);
    const polygon = playableObjects.get(segment.source_key).geometry;
    const line = mound.centerline_xz.map(([x, z]) => [x, -z]);
    const cumulative = [0];
    for (let index = 1; index < line.length; index += 1) cumulative.push(cumulative[index - 1] + length(sub(line[index], line[index - 1])));
    const total = cumulative.at(-1);
    const along = (t) => {
      let index = 0;
      while (index + 2 < line.length && cumulative[index + 1] < t) index += 1;
      const f = Math.max(0, Math.min(1, (t - cumulative[index]) / (cumulative[index + 1] - cumulative[index])));
      return add(line[index], scale(sub(line[index + 1], line[index]), f));
    };
    // The left normal of the centreline at t, smoothed over 6 m so the sections never fold.
    const leftAt = (t) => {
      const tangent = unit(sub(along(Math.min(total, t + 3)), along(Math.max(0, t - 3))));
      return [-tangent[1], tangent[0]];
    };
    // Distance from p along dir to the polygon's edge (the waterline).
    const toEdge = (p, dir) => {
      let best = Infinity;
      for (const part of polygon) {
        for (const ring of part) {
          for (let index = 0; index + 1 < ring.length; index += 1) {
            const edge = sub(ring[index + 1], ring[index]);
            const denominator = cross(dir, edge);
            if (Math.abs(denominator) < 1e-12) continue;
            const offset = sub(ring[index], p);
            const t = cross(offset, edge) / denominator;
            const u = cross(offset, dir) / denominator;
            if (t > 0 && u >= 0 && u <= 1) best = Math.min(best, t);
          }
        }
      }
      return Math.max(mound.half_width_m[0], Math.min(mound.half_width_m[1], best));
    };
    const rise = (crestY) => (crestY - WATER_Y_M) / mound.gradient;
    // Cross-section at t: crest height, crest and toe half-widths left and right.
    const sectionAt = (t) => {
      const p = along(t);
      const left = leftAt(t);
      const crestY = mound.crest_y_m - (mound.crest_y_m - (WATER_Y_M - 0.25)) * smoothstep(total - mound.taper_m, total, t);
      const sides = [1, -1].map((sign) => {
        const crest = Math.max(mound.crest_min_m / 2, toEdge(p, scale(left, sign)) - rise(mound.crest_y_m));
        return { crest, toe: crest + (crestY - slope.toe_y_m) / mound.gradient };
      });
      return { t, p, left, crestY, sides };
    };
    // Height at signed distance u across (left positive), without relief.
    const crown = 0.08;
    const profile = (section, u) => {
      const side = section.sides[u >= 0 ? 0 : 1];
      const a = Math.abs(u);
      if (a <= side.crest) return section.crestY - crown * (a / side.crest) ** 2;
      return Math.max(slope.toe_y_m, section.crestY - crown - mound.gradient * (a - side.crest));
    };
    const sections = [];
    for (let k = 0, count = Math.max(2, Math.ceil(total / slope.station_m)); k <= count; k += 1) sections.push(sectionAt((total * k) / count));
    // Underlay: columns at the toes, half-way up the sides, the crest edges, half-way to and on the centreline.
    const columnsOf = (section) => {
      const [left, right] = section.sides;
      return [-right.toe, -(right.crest + right.toe) / 2, -right.crest, -right.crest / 2, 0, left.crest / 2, left.crest, (left.crest + left.toe) / 2, left.toe];
    };
    const grid = sections.map((section) => columnsOf(section).map((u, column, all) => {
      const plan2 = add(section.p, scale(section.left, u));
      const edge = column === 0 || column === all.length - 1;
      const y = profile(section, u) + (edge ? 0 : slope.relief_m * rockRelief(seed, plan2[0], plan2[1], slope.relief_wavelength_m));
      return { u, plan: plan2, world: [plan2[0], y, -plan2[1]], open: outline.signedDistance(plan2) > 0.005 };
    }));
    const moundSections = Math.max(1, Math.round(total / slope.section_m));
    const moundRampHulls = rampStructures.map(hullOf);
    const moundSkirt = { mesh: { vertices: [], normals: [], indices: [] }, bottom: closureRule.wall_bottom_y_m };
    const normalAt = (row, column) => {
      const at = (r, c) => grid[Math.max(0, Math.min(grid.length - 1, r))][Math.max(0, Math.min(grid[0].length - 1, c))].world;
      const normal = unit3(cross3(sub3(at(row, column + 1), at(row, column - 1)), sub3(at(row + 1, column), at(row - 1, column))));
      return normal[1] < 0 ? scale3(normal, -1) : normal;
    };
    const meshes = Array.from({ length: moundSections }, () => ({ vertices: [], normals: [], indices: [], shared: new Map() }));
    const columns = grid[0].length;
    for (let i = 0; i + 1 < grid.length; i += 1) {
      const mesh = meshes[Math.min(moundSections - 1, Math.floor((((sections[i].t + sections[i + 1].t) / 2) / total) * moundSections))];
      const vertexAt = (row, column) => {
        const key = row * columns + column;
        if (!mesh.shared.has(key)) mesh.shared.set(key, pushVertex(mesh, grid[row][column].world, normalAt(row, column)));
        return mesh.shared.get(key);
      };
      for (let column = 0; column + 1 < columns; column += 1) {
        const cells = [grid[i][column], grid[i + 1][column], grid[i + 1][column + 1], grid[i][column + 1]];
        if (!cells.every((cell) => cell.open)) continue;
        // A ramp beside the mound cuts it exactly, as it cuts the shore's slope.
        const corners = [[i, column], [i + 1, column], [i + 1, column + 1], [i, column + 1]].map(([row, col]) => ({ plan: grid[row][col].plan, y: grid[row][col].world[1], normal: normalAt(row, col) }));
        if (nearHulls(moundRampHulls, corners)) {
          pushCut(mesh, [corners[0], corners[1], corners[2]], moundRampHulls, moundSkirt);
          pushCut(mesh, [corners[0], corners[2], corners[3]], moundRampHulls, moundSkirt);
          continue;
        }
        const [a, b, c, d] = [vertexAt(i, column), vertexAt(i + 1, column), vertexAt(i + 1, column + 1), vertexAt(i, column + 1)];
        pushTriangle(mesh, [a, b, c], [0, 1, 0]);
        pushTriangle(mesh, [a, c, d], [0, 1, 0]);
      }
    }
    meshes.forEach((mesh, index) => {
      if (mesh.indices.length === 0) return;
      records.push({
        object_key: `shoreline-slope:${segment.id}:${MOUND_SECTION_BASE + index}`,
        segment: segment.id,
        section: MOUND_SECTION_BASE + index,
        source_keys: [segment.source_key],
        material_key: SHORELINE_SLOPE_MATERIAL,
        ...packMesh(mesh, `shoreline-slope:${segment.id}:${MOUND_SECTION_BASE + index}`),
      });
    });
    invariant(meshes.some((mesh) => mesh.indices.length > 0), `Shoreline mound ${mound.id} built no faces`);
    if (moundSkirt.mesh.indices.length > 0) {
      records.push({
        object_key: `shoreline-face:${segment.id}:${MOUND_SECTION_BASE}`,
        segment: segment.id,
        section: MOUND_SECTION_BASE,
        source_keys: [segment.source_key],
        material_key: SHORELINE_FACE_MATERIAL,
        ...packMesh(moundSkirt.mesh, `shoreline-face:${segment.id}:${MOUND_SECTION_BASE}`),
      });
    }

    // Stones. The nearest cross-section to a point, for settling on the mound.
    const sectionNear = (t) => sections[Math.max(0, Math.min(sections.length - 1, Math.round((t / total) * (sections.length - 1))))];
    const surfaceUnder = (section, plan2) => profile(section, dot(sub(plan2, section.p), section.left));
    const clearOfRamps = (plan2, radius) => rampStructures.every((ramp) => !(pointInMultiPolygon(plan2, ramp.area.multi) || edgeDistance(ramp.area, plan2) < ramp.clearance_m + radius));
    const clearOfRampHulls = (placed) => placed.every((point) => !moundRampHulls.some(({ hull }) => insideHull(hull, [point[0], -point[2]], 0.05)));
    const placeOnMound = ({ band, t, u, size, prototype, o, bury }) => {
      const section = sectionAt(t);
      const plan2 = add(section.p, scale(section.left, u));
      const height = (o.high - o.low) * size;
      const radius = o.radius * size;
      if (!fits(plan2, radius, rules.heap.overlap) || !clearOfRamps(plan2, radius)) return null;
      const rotation = quantizeRotation(o.q);
      const sizeQ = quantizeScale(size);
      const scales = [sizeQ.value, sizeQ.value, sizeQ.value];
      const { points } = shapes.get(prototype.id);
      const bedY = profile(section, u) - Math.max(0.05, height * bury);
      let origin = [onGrid(plan2[0]), onGrid(bedY - o.low * size), onGrid(-plan2[1])];
      let placed = placedPoints(points, rotation.q, scales, origin);
      // Settled: lowered where its underside would hang over the mound.
      const low = Math.min(...placed.map((p) => p[1]));
      const high = Math.max(...placed.map((p) => p[1]));
      let hang = -Infinity;
      for (const p of placed) {
        if (p[1] > low + (high - low) * 0.35) continue;
        hang = Math.max(hang, p[1] - surfaceUnder(sectionNear(t), [p[0], -p[2]]));
      }
      if (hang > -0.01) {
        origin = [origin[0], onGrid(origin[1] - hang - 0.012), origin[2]];
        placed = placedPoints(points, rotation.q, scales, origin);
      }
      const top = Math.max(...placed.map((p) => p[1]));
      // As on the shore: from the waterline out a stone stands well clear of the
      // water, against the mound, or is not kept.
      const waterline = section.sides[u >= 0 ? 0 : 1].crest + (section.crestY - crown - WATER_Y_M) / mound.gradient;
      if (Math.abs(u) > waterline - 0.3 && (top < WATER_Y_M + 0.3 || Math.abs(u) > waterline + rules.heap.past_water_m)) return null;
      const shown = placed.filter((point) => point[1] > WATER_Y_M);
      if (Math.max(...shown.map((point) => Math.abs(dot(sub([point[0], -point[2]], section.p), section.left)))) > waterline + rules.heap.past_water_m) return null;
      if (top < WATER_Y_M + 0.08 || clearance(placed) < SHORELINE_OUTSIDE_CLEARANCE_M || !clearOfRampHulls(placed)) return null;
      const stone = {
        band, s: segment.s1 + MOUND_SECTION_BASE * rules.section_m + t, d: u, plan: plan2, radius, prototype, prototypeId: prototype.id,
        section: MOUND_SECTION_BASE + Math.floor(t / rules.section_m), segment: segment.id,
        rotation: rotation.ints, q: rotation.q, scale: [sizeQ.steps], scales, origin, placed, top,
        reach: Math.max(...placed.map((p) => Math.hypot(p[0] - origin[0], p[2] - origin[2]))),
      };
      keep(stone);
      return stone;
    };
    const meanCrest = sections.reduce((sum, section) => sum + section.sides[0].crest + section.sides[1].crest, 0) / sections.length;
    const meanSides = sections.reduce((sum, section) => sum + section.sides[0].toe - section.sides[0].crest + section.sides[1].toe - section.sides[1].crest, 0) / sections.length;
    // Crest blocks: big stones lying flat.
    {
      const rule = rules.crest;
      const meanSize = (rule.size_m[0] + rule.size_m[1]) / 2;
      const target = Math.ceil((total * meanCrest * rule.fill) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${mound.id}:crest`);
      let placedCount = 0;
      for (let attempt = 0; attempt < target * 12 && placedCount < target; attempt += 1) {
        const size = pickSize(rule.size_m, rule.size_skew, rng);
        const t = rng() * total;
        const section = sectionAt(t);
        const u = lerp(-section.sides[1].crest, section.sides[0].crest, rng());
        const prototype = shapeFor(size, rng);
        const o = orient(prototype, [0, 1, 0], rules.top.tilt_deg, rng, crestPosture);
        if (placeOnMound({ band: "top", t, u, size, prototype, o, bury: pick(rules.top.bury, rng) })) placedCount += 1;
      }
    }
    // Sides: the heap's size classes, largest first, down past the waterline.
    for (const [classIndex, sizeClass] of rules.heap.classes.entries()) {
      if (sizeClass.size_m[1] <= rules.pebbles.below_m) continue;
      const meanSize = (sizeClass.size_m[0] + sizeClass.size_m[1]) / 2;
      const target = Math.ceil((total * meanSides * sizeClass.fill) / (Math.PI * (meanSize * 0.42) ** 2));
      const rng = random(seed, `${mound.id}:heap:${classIndex}`);
      let placedCount = 0;
      for (let attempt = 0; attempt < target * 12 && placedCount < target; attempt += 1) {
        const size = pick(sizeClass.size_m, rng);
        const t = rng() * total;
        const section = sectionAt(t);
        const sign = rng() < 0.5 ? 1 : -1;
        const side = section.sides[sign > 0 ? 0 : 1];
        const u = sign * lerp(side.crest, side.toe + rules.heap.toe_extra_m, rng());
        const prototype = shapeFor(size, rng);
        const n = unit3([section.left[0] * sign * mound.gradient, 1, -section.left[1] * sign * mound.gradient]);
        const o = orient(prototype, add3(scale3(n, 0.7), [0, 0.3, 0]), rules.heap.tilt_deg, rng, heapPosture);
        if (placeOnMound({ band: "heap", t, u, size, prototype, o, bury: pick(rules.heap.bury, rng) })) placedCount += 1;
      }
    }
    const summary = segmentSummaries.find((entry) => entry.id === segment.id);
    summary.mounds = [...(summary.mounds ?? []), {
      id: mound.id, length_m: roundCoordinate(total), crest_y_m: mound.crest_y_m, gradient: mound.gradient, reason: mound.reason, reference: mound.reference,
    }];
  }

  // One batch (one MultiMesh) per segment, section, band and prototype, so
  // each culls on its own. The stones thin out one by one with distance in the
  // shader (each at its own share of its reach, thinning below); a batch is
  // culled only once every stone in it can have dropped out: its visibility
  // range, measured from the centre of its bounds, is its stones' farthest
  // reach plus their farthest distance from that centre. So no batch edge
  // ever shows as a step in the heap. The logs keep a fixed range.
  const thinning = rules.thinning;
  const reachOf = (stone) => Math.min(thinning.max_m, Math.max(thinning.min_m, stone.scales[0] * thinning.reach_per_m));
  const batches = new Map();
  for (const stone of stones) {
    const pebble = stone.prototypeId.startsWith("pebble_");
    // The small stones of the crest rows draw with the heap's: same shapes,
    // no shadows.
    const band = pebble && stone.band === "top" ? "heap" : stone.band;
    const id = `${stone.segment}:${String(stone.section).padStart(2, "0")}:${band}:${stone.prototypeId}`;
    if (!batches.has(id)) {
      batches.set(id, {
        id,
        segment: stone.segment,
        section: stone.section,
        band,
        prototype: stone.prototypeId,
        // The heap and cobbles are shaded by their texture and the shader's
        // contact darkening; the big stones of the top row and the wood also
        // cast shadows.
        cast_shadow: (band === "top" && !pebble) || band === "driftwood",
        placements: [],
      });
    }
    batches.get(id).placements.push(stone);
  }
  const ordered = [...batches.values()].sort((left, right) => (left.id < right.id ? -1 : left.id > right.id ? 1 : 0));
  const kindOf = new Map(prototypes.map((prototype) => [prototype.id, prototype.kind]));
  for (const batch of ordered) {
    batch.placements.sort((left, right) => left.s - right.s || left.plan[0] - right.plan[0] || left.plan[1] - right.plan[1]);
    if (batch.band === "driftwood") {
      [batch.visibility_end_m, batch.visibility_margin_m] = thinning.wood_m;
    } else {
      const low = [Infinity, Infinity, Infinity];
      const high = [-Infinity, -Infinity, -Infinity];
      for (const stone of batch.placements) {
        for (const point of stone.placed) {
          for (let axis = 0; axis < 3; axis += 1) {
            low[axis] = Math.min(low[axis], point[axis]);
            high[axis] = Math.max(high[axis], point[axis]);
          }
        }
      }
      const centre = low.map((value, axis) => (value + high[axis]) / 2);
      const farthest = Math.max(...batch.placements.map((stone) => reachOf(stone) + length3(sub3(stone.origin, centre))));
      batch.visibility_end_m = Math.ceil(farthest + 2);
      batch.visibility_margin_m = 1;
    }
    Object.assign(batch, packBatch(batch.placements, kindOf.get(batch.prototype)));
  }
  // The share of the heap's plan cover still drawn at a camera distance x
  // falls as the stones thin out; the underlay in the gaps stands in for the
  // stones by that share. Fitted here as smoothstep(fade[0], fade[1], x) to
  // the actual stones, so the shader's stand-in follows the thinning.
  const covering = stones.filter((stone) => stone.band !== "driftwood" && stone.band !== "cobble")
    .map((stone) => ({ area: stone.radius * stone.radius, reach: reachOf(stone) }));
  const coverArea = covering.reduce((sum, stone) => sum + stone.area, 0);
  const lost = (x) => 1 - covering.reduce((sum, stone) => {
    const start = thinning.start * stone.reach;
    const kept = x <= start ? 1 : x >= stone.reach ? 0 : (stone.reach - x) / (stone.reach - start);
    return sum + stone.area * kept;
  }, 0) / coverArea;
  const samples = [];
  for (let x = 0; x <= thinning.max_m + 20; x += 5) samples.push([x, lost(x)]);
  let fade = [0, thinning.max_m];
  let bestError = Infinity;
  for (let a = 0; a <= thinning.max_m; a += 2) {
    for (let b = a + 10; b <= thinning.max_m + 40; b += 2) {
      const error = samples.reduce((sum, [x, target]) => sum + (smoothstep(a, b, x) - target) ** 2, 0);
      if (error < bestError) {
        bestError = error;
        fade = [a, b];
      }
    }
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
      lod: {
        reach_per_m: thinning.reach_per_m,
        min_m: thinning.min_m,
        max_m: thinning.max_m,
        start: thinning.start,
        underlay_fade_m: fade,
        description: "stones thin out one by one: a stone of size s (its instance scale) is drawn while the main camera is within its reach, s * reach_per_m within [min_m, max_m], times its own share in [start, 1] (a hash of its position); the underlay stands in for the thinned stones by smoothstep(underlay_fade_m[0], underlay_fade_m[1], camera distance)",
      },
      packing: {
        position_step_m: SHORELINE_POSITION_STEP_M,
        scale_step_m: SHORELINE_SCALE_STEP_M,
        rotation_scale: SHORELINE_ROTATION_SCALE,
        normal_scale: SHORELINE_NORMAL_SCALE,
        records: "positions: uint16 x, y, z steps from origin; normals: int8 x, y, z over normal_scale; indices: uint16; little-endian, base64; a shoreline-verge record's UVs are world x / 10 and z / 10",
        placements: "per placement: position uint16 x, y, z steps from origin; rotation int16 x, y, z, w over rotation_scale (normalized on reading); size uint16 steps of scale_step_m (one for a boulder, its uniform scale; length, thickness, width for a log or plank); little-endian, base64",
      },
      segments: segmentSummaries,
      closures: closureSummaries,
      records,
      prototypes,
      batches: ordered,
    },
    stones,
  };
}
