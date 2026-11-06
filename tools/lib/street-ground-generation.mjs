// Street ground: the always-on kerbs, raised sidewalks, curb ramps, road markings
// and asphalt wear of the street-detail pilot zones, emitted as chunk mesh records.
//
// The inputs are the frozen OSM geometry the world generator already built (road
// ribbons, sidewalks, crossings, parking lots, buildings) and the "ground" blocks
// of tools/config/street-detail-zones.json. Every dimension is production
// inference for game art read from the dated pilot photos, not survey data.
//
// Plan geometry is east/north (the generator frame); records use world x, y, z
// with z = -north. Heights are given above the generated land: each emitted
// vertex sits at land(x, z) + h, where h is affine over the piece it belongs to,
// so a piece clipped to one land triangle stays planar.
//
// Records, one of each per chunk the pilot touches:
//   street-kerb   street_kerb          concrete sidewalk tops (road-aligned
//                                      panels), curb faces, curb ramps and paved
//                                      back slopes; solid
//   street-lot-curb street_kerb        the Johnson St lot's darker curb, tops and
//                                      faces; solid
//   street-planting street_kerb        raised mulch planting strips; solid
//   street-plaza  street_kerb          banded plaza paving; solid
//   street-verge  street_kerb          grassed back slopes behind sidewalks; solid
//   street-ramp   street_kerb_support  invisible ramps in front of every curb
//                                      face, so the stock player (no step-up)
//                                      walks on and off a kerb; solid
//   street-parking street_paint        asphalt parking lanes beyond the frozen
//                                      road ribbon, up to the moved curb; visual only
//   street-gutter street_paint         concrete gutter pans; visual only
//   street-wear   street_paint         cracks, patches, stains, manholes, drains
//   street-marking street_paint        road paint, crosswalks, stop bars, stalls,
//                                      tactile pads; visual only
//   park-*        street_paint         a park zone's ground (ground.surfaces): mulch
//                                      and gravel beds, lawn, concrete, asphalt and
//                                      decomposed-granite paths, painted plazas,
//                                      draped flat over the land; visual only
//
// The visual layers over the road lie, bottom to top, each at least a layer step
// (DRAPED_LAYER_STEP_M) over the one below where they overlap: road base (and the
// parking lanes beside it at the same height, drawn clear of every road and path
// ribbon), pedestrian skin, gutter (lifts.gutter_m), wear (midway between the
// gutter and the paint) and paint (lifts.paint_m). A zone's ground lies at least
// a step over the paint.

import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import earcut from "earcut";
import polygonClipping from "polygon-clipping";

import { projectLonLat } from "./coordinates.mjs";
import { meshRecord } from "./mesh-output.mjs";
import { lineRibbon, pointInRing, rawWayLine } from "./osm-geometry.mjs";
import {
  CHUNK_SIZE_M,
  DRAPED_LAYER_STEP_M,
  ROAD_SURFACE_BIASES_M,
  ROAD_WIDTHS_M,
  chunkId,
  compareChunkIds,
  compareSourceKeys,
  invariant,
  roundCoordinate,
} from "./world-contract.mjs";

export const STREET_GROUND_FEATURE_KINDS = Object.freeze(["street_kerb", "street_kerb_support", "street_paint"]);
// Record kinds in emission order: [object key prefix, feature kind, material, collision, opaque].
// Zone ground surfaces (a zone's ground.surfaces): material key -> record key
// prefix. The park_* ones are Cityside Park's; the rest are the yards' shared
// ground (tools/lib/street-yard-generation.mjs): worn yard asphalt, compacted
// yard gravel (beige-grey, or the pale grey of a fresh aggregate pad), grey
// concrete rubble, black plastic sheeting over earth, plain poured concrete,
// pale graded sand, dark excavated soil and shallow murky ponds.
export const PARK_SURFACE_MATERIALS = Object.freeze({
  park_asphalt: "park-asphalt",
  park_concrete: "park-concrete",
  park_dg: "park-dg",
  park_gravel: "park-gravel",
  park_lawn: "park-lawn",
  park_mulch: "park-mulch",
  park_paint_pink: "park-paint-pink",
  park_plaza_lens: "park-plaza-lens",
  park_plaza_zigzag: "park-plaza-zigzag",
  black_plastic: "black-plastic",
  rubble_grey: "rubble-grey",
  yard_asphalt: "yard-asphalt",
  yard_asphalt_pale: "yard-asphalt-pale",
  yard_asphalt_fresh: "yard-asphalt-fresh",
  yard_gravel: "yard-gravel",
  yard_gravel_pale: "yard-gravel-pale",
  yard_concrete: "yard-concrete",
  yard_pond: "yard-pond",
  yard_sand_pale: "yard-sand-pale",
  yard_shoulder_band: "yard-shoulder-band",
  yard_shoulder_gravel: "yard-shoulder-gravel",
  yard_soil_dark: "yard-soil-dark",
});
const RECORD_KINDS = Object.freeze({
  ...Object.fromEntries(Object.entries(PARK_SURFACE_MATERIALS).map(([material, prefix]) => [material, [prefix, "street_paint", material, "none", false]])),
  kerb: ["street-kerb", "street_kerb", "street_kerb_concrete", "world_solid", true],
  lot_curb: ["street-lot-curb", "street_kerb", "street_kerb_lot", "world_solid", true],
  planting: ["street-planting", "street_kerb", "street_kerb_planting", "world_solid", true],
  plaza: ["street-plaza", "street_kerb", "street_plaza_pavers", "world_solid", true],
  verge: ["street-verge", "street_kerb", "street_kerb_verge", "world_solid", true],
  ramp: ["street-ramp", "street_kerb_support", "street_kerb_support", "world_solid", false],
  parking: ["street-parking", "street_paint", "street_parking", "none", false],
  gutter: ["street-gutter", "street_paint", "street_gutter", "none", false],
  wear: ["street-wear", "street_paint", "street_wear", "none", false],
  marking: ["street-marking", "street_paint", "street_marking", "none", false],
});
// Paint kinds (street-marking UV.x integer part, modulo PAINT_VARIANT_STRIDE)
// and wear atlas cells (street-wear UV.x integer part); the shaders read the
// same numbers. The integer part of a marking's UV.x is kind + stride * variant:
// for painted lines and legends the variant is a wear step (0 fresh, 3 mostly worn,
// 4 nearly worn away; PAINT_WEAR_STEPS), for kind legend it is the cell of the legend
// atlas (STREET_LEGEND_CELLS) plus STREET_LEGEND_ATLAS_CELLS times its wear step.
// red_curb is curb paint, blue an accessible stall and blue_dark a filled one on the
// Johnson St lot; sealant and patch are a lot's tar-sealed joints and patched strips.
export const STREET_PAINT_KINDS = Object.freeze({ white: 0, yellow: 1, red: 2, green: 3, tactile: 4, stop_legend: 5, yellow_faded: 6, red_curb: 7, blue: 8, legend: 9, sealant: 10, patch: 11, blue_dark: 12 });
export const PAINT_VARIANT_STRIDE = 16;
export const PAINT_WEAR_STEPS = 5;
export const STREET_LEGEND_CELLS = Object.freeze({ tour_bus_parking: 0, arrow_straight: 1, arrow_left: 2, arrow_right: 3, accessible: 4, arrow_short: 5 });
// The legend atlas's cell count (street_legends.png, street_paint.gdshader legend_cells).
export const STREET_LEGEND_ATLAS_CELLS = 8;
export const STREET_WEAR_CELLS = Object.freeze({ crack_a: 0, crack_b: 1, oil_a: 2, oil_b: 3, patch: 4, manhole: 5, drain: 6 });
// The deepest any street-ground vertex may sit above the land under it (m);
// validators reuse it.
export const STREET_GROUND_MAXIMUM_HEIGHT_M = 0.3;
export const STREET_GROUND_MINIMUM_HEIGHT_M = -0.02;

const ROAD_TOP_M = ROAD_SURFACE_BIASES_M.base;
const SKIRT_FOOT_M = -0.01;
const MINIMUM_TRIANGLE_AREA_M2 = 1e-6;
// openRing merges ring vertices closer than this, so two layers that each build a
// shared edge can differ along it by that much; the validator reuses it.
export const STREET_GROUND_EDGE_MERGE_M = 0.01;
// Parking strips start this far inside the frozen carriageway (and are then cut
// back to it), so where a ribbon bends their inner edge leaves no gap.
const CARRIAGEWAY_OVERLAP_M = 0.5;
// Plaza paving (tapered strip ends) and parking-lot tips narrower than twice
// these are dropped.
const PLAZA_OPENING_M = 1.5;
const LOT_OPENING_M = 1.5;
// boundaryBand merges ring vertices closer than this.
const BAND_VERTEX_MERGE_M = 0.05;
// Concrete kept beyond the top of a curb ramp before any mulch bed.
const RAMP_LANDING_M = 1.5;
// A rule street's zone: this far either side of its ways' centre lines.
const STREET_CORRIDOR_HALF_M = 18;
// A verge side: this much concrete curb top at the curb, then grass.
const CURB_TOP_M = 0.25;
// Red curb paint: the strip of the curb top it covers.
const RED_CURB_TOP_M = 0.15;
// A curb face longer than this with road on both sides fails the build (a
// hairline of band left in the lane); shorter spikes at corners are noise.
const INTERIOR_CURB_MIN_M = 0.25;
// A street-side bay's pavement and stalls keep this far off any building.
const BAY_BUILDING_CLEARANCE_M = 0.5;
// The paint overlap check's grid, and the overlap below which two paints do not count.
const PAINT_CELL_M = 8;
const PAINT_OVERLAP_MIN_M2 = 1e-4;
// A lot rule's own pavement lies at the yards' ground lift, a step over the road
// paint; its other layers lie LOT_LAYER_STEPS over that.
const LOT_SURFACE_LIFT_M = 0.09;
// How far a lot's planted strip lies over its curb band's top (m).
const LOT_STRIP_LIFT_M = 0.02;
// A lot surface's wear (decals per 100 m2 of its pavement).
const LOT_WEAR_FIELDS = Object.freeze(["crack_per_100m2", "oil_per_100m2", "patch_per_100m2"]);
// A lot with its own pavement stacks its layers a draped step apart over it:
// patched strips, wear decals, sealed joints, stall paint, then legends and hatching.
const LOT_LAYER_STEPS = Object.freeze({ patch: 1, wear: 2, seam: 3, paint: 4, top: 5 });
// A lot island's curb faces run down to the land (under the lot's surface).
const ISLAND_FOOT_M = 0;
// Two-line crosswalks (lines, ladder): each line this wide; a lines crosswalk
// is this wide overall (the villages' narrower walks).
const TRANSVERSE_LINE_M = 0.3;
const LINES_WALK_WIDTH_M = 3.2;
// Half-metre samples of clear road that end a stop line's search for crossing roads (8 m).
const STOP_LINE_CLEAR_RUN_STEPS = 16;
// Road classes in order of which owns the sidewalk panel frame where reaches overlap.
const FRAME_ROAD_RANK = Object.freeze(["trunk", "primary", "secondary", "tertiary", "unclassified", "residential", "service"]);
const SAFE_ID = /^[a-z0-9_]+$/u;

const GROUND_SCHEMA = Object.freeze({
  kerb: ["back_slope_run_m", "building_clearance_m", "closing_m", "flare_run_m", "gutter_width_m", "minimum_width_m", "panel_m", "planting_gap_m", "reveal_m", "sidewalk_reach_m", "sidewalk_width_m", "support_run_m"],
  crossings: ["bar_gap_m", "bar_width_m", "ramp_depth_m", "ramp_foot_m", "ramp_width_m", "tactile_depth_m", "walk_width_m"],
  lines: ["bike_lane_width_m", "bus_lane_width_m", "conflict_length_m", "dash_gap_m", "dash_m", "double_gap_m", "edge_inset_m", "stall_length_m", "stall_spacing_m", "stop_bar_width_m", "stop_legend_gap_m", "stop_legend_length_m", "width_m"],
  lifts: ["gutter_m", "paint_m"],
});
const ZONE_GROUND_FIELDS = ["centerlines", "kerbs", "lane_markings", "parking_lanes", "parking_stalls", "planting", "planting_behind_walk", "plazas", "wear"];
const PARKING_LANE_FIELDS = ["reason", "source_keys", "width_m"];
const BEHIND_WALK_FIELDS = ["reason", "source_keys"];
const CENTERLINE_STYLES = Object.freeze(["double_yellow", "dashed_faded"]);
const PLANTING_MODES = Object.freeze(["none", "curb_strip"]);
const PLAZA_FIELDS = ["depth_m", "paver_tile_m", "reason", "side_point_xz", "source_keys", "walk_m"];
const WEAR_FIELDS = ["crack_per_100m2", "drain_spacing_m", "manhole_spacing_m", "oil_per_100m2", "patch_per_100m2"];
const SURFACE_LAYER_FIELDS = ["evidence", "id", "material", "reason", "shape"];
// Cut a path's surface into cells this size so its panel frame follows its bends.
const PATH_FRAME_CELL_M = 8;
// Park path markings (a layer's markings): line width, the edge lines' inset
// from the path edge, the centre line's dash and gap, and their lift over the path.
const PARK_LINE_WIDTH_M = 0.1;
const PARK_EDGE_LINE_INSET_M = 0.25;
const PARK_DASH_M = 3;
const PARK_PAINT_LIFT_M = 0.006;

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

function exactKeys(value, keys, label) {
  invariant(value != null && typeof value === "object" && !Array.isArray(value), `${label} must be an object`);
  invariant(JSON.stringify(Object.keys(value).sort()) === JSON.stringify([...keys].sort()), `${label} must define exactly ${[...keys].sort().join(", ")}`);
}

// A park zone's ground: its OSM source, the lift above the land and the layers,
// each a material over a shape; later layers replace earlier ones where they
// overlap, so the zone ends up one partition of flat-lying ground.
//   shape {zone: true}                    the zone itself
//   shape {points_xz: [...]}              a traced polygon
//   shape {line_xz: [...], width_m}       a ribbon along a traced line
//   shape {way: "w...", width_m, offset_m} a ribbon along an OSM way, moved
//                                         offset_m to its left
//   shape {osm_paths: true}               the zone's OSM footway and cycleway ribbons
// Any shape may add minus_sources: OSM areas cut out of it (a breakwater). A
// layer may add frame {origin_xz, axis_xz}: plaza paint is laid out in metres
// along axis_xz from origin_xz. A way or line layer may add markings {edges,
// centre}: painted edge lines and a dashed centre line along it (STREET_PAINT_KINDS
// names, or null for none), as on a two-way cycle track.
function validateParkSurfaces(surfaces, label, minimumLift) {
  exactKeys(surfaces, ["layers", "lift_m", "source_keys"], label);
  invariant(isFiniteNumber(surfaces.lift_m) && surfaces.lift_m >= minimumLift - 1e-9 && surfaces.lift_m < STREET_GROUND_MAXIMUM_HEIGHT_M, `${label} lift_m must lie a layer step over the road paint (${minimumLift} m) and inside the street-ground band`);
  invariant(Array.isArray(surfaces.source_keys) && surfaces.source_keys.length > 0 && surfaces.source_keys.every((key) => /^[wr]\d+$/u.test(key)), `${label} needs OSM source_keys`);
  invariant(Array.isArray(surfaces.layers) && surfaces.layers.length > 0, `${label} needs layers`);
  const ids = new Set();
  for (const layer of surfaces.layers) {
    const layerLabel = `${label} layer ${layer?.id}`;
    exactKeys(layer, [...SURFACE_LAYER_FIELDS, ...["frame", "markings"].filter((field) => field in (layer ?? {}))], layerLabel);
    invariant(typeof layer.id === "string" && SAFE_ID.test(layer.id) && !ids.has(layer.id), `${layerLabel} needs a unique lower_snake id`);
    ids.add(layer.id);
    invariant(PARK_SURFACE_MATERIALS[layer.material] !== undefined, `${layerLabel} material must be one of ${Object.keys(PARK_SURFACE_MATERIALS).join(", ")}`);
    for (const field of ["reason", "evidence"]) invariant(typeof layer[field] === "string" && layer[field].trim() !== "", `${layerLabel} needs ${field}`);
    const shape = layer.shape;
    invariant(shape != null && typeof shape === "object", `${layerLabel} needs a shape`);
    const minus = "minus_sources" in shape ? ["minus_sources"] : [];
    if (minus.length > 0) invariant(Array.isArray(shape.minus_sources) && shape.minus_sources.every((key) => /^[wr]\d+$/u.test(key)), `${layerLabel} minus_sources must be OSM area keys`);
    const isXZ = (point) => Array.isArray(point) && point.length === 2 && point.every(isFiniteNumber);
    if (shape.zone === true) exactKeys(shape, ["zone", ...minus], `${layerLabel} zone shape`);
    else if (shape.osm_paths === true) exactKeys(shape, ["osm_paths", ...minus], `${layerLabel} osm_paths shape`);
    else if (shape.points_xz) {
      exactKeys(shape, ["points_xz", ...minus], `${layerLabel} polygon shape`);
      invariant(shape.points_xz.length >= 3 && shape.points_xz.every(isXZ), `${layerLabel} polygon needs 3+ [x, z] points`);
    } else if (shape.line_xz) {
      exactKeys(shape, ["line_xz", "width_m", ...minus], `${layerLabel} line shape`);
      invariant(shape.line_xz.length >= 2 && shape.line_xz.every(isXZ) && isFiniteNumber(shape.width_m) && shape.width_m > 0, `${layerLabel} line needs 2+ [x, z] points and a positive width_m`);
    } else if (shape.way) {
      exactKeys(shape, ["offset_m", "way", "width_m", ...minus], `${layerLabel} way shape`);
      invariant(/^w\d+$/u.test(shape.way) && isFiniteNumber(shape.width_m) && shape.width_m > 0 && isFiniteNumber(shape.offset_m), `${layerLabel} way shape needs an OSM way, a positive width_m and offset_m`);
    } else {
      throw new Error(`${layerLabel} shape must be zone, osm_paths, points_xz, line_xz or way`);
    }
    if (layer.frame !== undefined) {
      exactKeys(layer.frame, ["axis_xz", "origin_xz"], `${layerLabel} frame`);
      invariant(isXZ(layer.frame.origin_xz) && isXZ(layer.frame.axis_xz) && Math.hypot(...layer.frame.axis_xz) > 1e-6, `${layerLabel} frame needs origin_xz and a non-zero axis_xz`);
    }
    invariant(!layer.material.startsWith("park_plaza_") || layer.frame !== undefined, `${layerLabel}: painted plazas need a frame`);
    if (layer.markings !== undefined) {
      exactKeys(layer.markings, ["centre", "edges"], `${layerLabel} markings`);
      invariant((shape.way || shape.line_xz) && ["centre", "edges"].every((field) => layer.markings[field] === null || STREET_PAINT_KINDS[layer.markings[field]] !== undefined), `${layerLabel} markings go on a way or line layer and name paint kinds (or null)`);
    }
  }
}

// The validated "ground" settings: config.ground plus each pilot zone's ground block.
export function streetGroundSettings(config) {
  const ground = config.ground;
  invariant(ground != null, "Street detail config needs a ground block");
  exactKeys(ground, ["crossings", "kerb", "lifts", "lines", "notes"], "Street ground config");
  invariant(Array.isArray(ground.notes) && ground.notes.every((note) => typeof note === "string"), "Street ground notes must be strings");
  for (const [section, keys] of Object.entries(GROUND_SCHEMA)) {
    exactKeys(ground[section], keys, `Street ground ${section}`);
    for (const key of keys) {
      invariant(isFiniteNumber(ground[section][key]) && ground[section][key] >= 0, `Street ground ${section}.${key} must be a non-negative number`);
    }
  }
  const { kerb, crossings, lines, lifts } = ground;
  invariant(kerb.reveal_m > 0 && kerb.reveal_m < STREET_GROUND_MAXIMUM_HEIGHT_M - ROAD_TOP_M, "Kerb reveal must keep the sidewalk below the height bound");
  // A collision ramp steeper than 40 degrees would turn into a wall for the stock
  // controller (floor_max_angle 48 degrees); keep a margin.
  const top = ROAD_TOP_M + kerb.reveal_m;
  for (const key of ["support_run_m", "back_slope_run_m", "flare_run_m"]) {
    invariant(kerb[key] > 0 && Math.atan2(top - SKIRT_FOOT_M, kerb[key]) <= (40 * Math.PI) / 180, `Kerb ${key} makes a slope steeper than 40 degrees`);
  }
  invariant(crossings.ramp_depth_m > 0 && Math.atan2(kerb.reveal_m, crossings.ramp_depth_m) <= (15 * Math.PI) / 180, "Curb ramps must stay gentler than 15 degrees");
  invariant(crossings.ramp_width_m > 2 * kerb.flare_run_m, "Curb ramps must be wider than their two flares");
  // Each layer over the road a step over the one below (see the header): the
  // gutter a step over the pedestrian skin, the paint two over the gutter with
  // the wear midway, and a curb ramp's foot (solid) under the paint.
  invariant(
    lifts.gutter_m >= ROAD_SURFACE_BIASES_M.pedestrian - ROAD_TOP_M + DRAPED_LAYER_STEP_M - 1e-9 &&
      lifts.paint_m >= lifts.gutter_m + 2 * DRAPED_LAYER_STEP_M - 1e-9,
    "The gutter must sit a layer step over the pedestrian skin, and the paint two steps over the gutter",
  );
  invariant(crossings.ramp_foot_m > 0 && crossings.ramp_foot_m <= lifts.paint_m, "A curb ramp's foot must lie over the road and under the paint");
  invariant(lines.width_m > 0 && lines.stall_spacing_m > lines.width_m && crossings.bar_width_m > 0, "Line widths must be positive");
  invariant(lines.dash_m > 0 && lines.dash_gap_m > 0 && kerb.panel_m > 0 && kerb.closing_m >= 0, "Dashes, panels and gap closing need positive sizes");
  const zones = [];
  for (const zone of config.zones) {
    if (!zone.pilot || zone.ground == null) continue;
    exactKeys(zone.ground, "surfaces" in zone.ground ? [...ZONE_GROUND_FIELDS, "surfaces"] : ZONE_GROUND_FIELDS, `Street ground zone ${zone.id}`);
    const settings = zone.ground;
    if (settings.surfaces !== undefined) validateParkSurfaces(settings.surfaces, `Street ground zone ${zone.id} surfaces`, ROAD_TOP_M + lifts.paint_m + DRAPED_LAYER_STEP_M);
    for (const key of ["kerbs", "lane_markings", "parking_stalls"]) {
      invariant(typeof settings[key] === "boolean", `Street ground zone ${zone.id} ${key} must be boolean`);
    }
    invariant(
      settings.centerlines != null && typeof settings.centerlines === "object" && !Array.isArray(settings.centerlines) &&
        Object.entries(settings.centerlines).every(([highway, style]) => ROAD_WIDTHS_M[highway] != null && CENTERLINE_STYLES.includes(style)),
      `Street ground zone ${zone.id} centerlines must map highway classes to ${CENTERLINE_STYLES.join(" or ")}`,
    );
    invariant(PLANTING_MODES.includes(settings.planting), `Street ground zone ${zone.id} planting must be ${PLANTING_MODES.join(" or ")}`);
    invariant(Array.isArray(settings.plazas), `Street ground zone ${zone.id} plazas must be a list`);
    invariant(Array.isArray(settings.parking_lanes), `Street ground zone ${zone.id} parking_lanes must be a list`);
    invariant(Array.isArray(settings.planting_behind_walk), `Street ground zone ${zone.id} planting_behind_walk must be a list`);
    for (const entry of settings.planting_behind_walk) {
      exactKeys(entry, BEHIND_WALK_FIELDS, `Street ground zone ${zone.id} planting_behind_walk entry`);
      invariant(settings.planting === "curb_strip", `Street ground zone ${zone.id} planting_behind_walk needs planting curb_strip`);
      invariant(Array.isArray(entry.source_keys) && entry.source_keys.length > 0 && entry.source_keys.every((key) => /^w\d+$/u.test(key)), `Street ground zone ${zone.id} planting_behind_walk needs OSM sidewalk source_keys`);
      invariant(typeof entry.reason === "string" && entry.reason.trim() !== "", `Street ground zone ${zone.id} planting_behind_walk needs a reason`);
    }
    for (const lane of settings.parking_lanes) {
      exactKeys(lane, PARKING_LANE_FIELDS, `Street ground zone ${zone.id} parking lane`);
      invariant(Array.isArray(lane.source_keys) && lane.source_keys.length > 0 && lane.source_keys.every((key) => /^w\d+$/u.test(key)), `Street ground zone ${zone.id} parking lane needs OSM way source_keys`);
      invariant(isFiniteNumber(lane.width_m) && lane.width_m > 0 && lane.width_m <= 3.5, `Street ground zone ${zone.id} parking lane width must be in (0, 3.5] m`);
      invariant(typeof lane.reason === "string" && lane.reason.trim() !== "", `Street ground zone ${zone.id} parking lane needs a reason`);
    }
    for (const plaza of settings.plazas) {
      exactKeys(plaza, PLAZA_FIELDS, `Street ground zone ${zone.id} plaza`);
      invariant(Array.isArray(plaza.source_keys) && plaza.source_keys.length > 0 && plaza.source_keys.every((key) => /^w\d+$/u.test(key)), `Street ground zone ${zone.id} plaza needs OSM way source_keys`);
      invariant(Array.isArray(plaza.side_point_xz) && plaza.side_point_xz.length === 2 && plaza.side_point_xz.every(isFiniteNumber), `Street ground zone ${zone.id} plaza needs side_point_xz`);
      invariant(isFiniteNumber(plaza.walk_m) && isFiniteNumber(plaza.depth_m) && plaza.walk_m > 0 && plaza.depth_m > plaza.walk_m && isFiniteNumber(plaza.paver_tile_m) && plaza.paver_tile_m > 0, `Street ground zone ${zone.id} plaza needs walk_m < depth_m and a paver_tile_m`);
      invariant(typeof plaza.reason === "string" && plaza.reason.trim() !== "", `Street ground zone ${zone.id} plaza needs a reason`);
    }
    exactKeys(settings.wear, WEAR_FIELDS, `Street ground zone ${zone.id} wear`);
    for (const key of WEAR_FIELDS) {
      invariant(isFiniteNumber(settings.wear[key]) && settings.wear[key] >= 0, `Street ground zone ${zone.id} wear.${key} must be non-negative`);
    }
    invariant(SAFE_ID.test(zone.id), `Street ground zone id ${zone.id} is unsafe`);
    zones.push({ id: zone.id, zone, settings });
  }
  invariant(zones.length > 0, "No pilot zone has a ground block");
  return { ...ground, top_m: top, zones };
}

// ---------------------------------------------------------------- island-wide rules
// tools/config/street-ground.json: the street ground of every street outside the
// pilot zones, as rules read from the dated photos and aerial (production
// inference for game art, not survey data). A treatment is what a class of
// street looks like; a street names its OSM ways, a treatment and the evidence,
// and may change any treatment field (set), the curb of each way's side
// (sides: left and right of the way's own direction), widen the asphalt beyond
// the frozen ribbon (widen, metres per side: the curb-to-curb width read from
// the aerial) and list where cars park at the curb (parking, along-way metres
// per side, for the parked cars). crossings gives a crossing node's paint
// (or none), overriding its OSM tags; stops adds photographed stop lines OSM
// lacks (own_line false: only the legend, a crosswalk's near line serving as the
// stop line); bays are perpendicular parking bays paved off a street's edge; lots
// paint a parking lot's stall rows, legends and raised islands.
export const STREET_GROUND_RULES_PATH = "tools/config/street-ground.json";
const STREET_GROUND_RULES_SCHEMA = "ti.street-ground-rules/1";
const SIDE_KINDS = Object.freeze(["walk", "verge", "none"]);
const CROSSWALK_STYLES = Object.freeze(["continental", "ladder", "lines", "none"]);
const FILL_KINDS = Object.freeze(["concrete", "lawn", "mulch"]);
const RULE_CENTERLINES = Object.freeze(["double_yellow", "dashed_faded", "dashed_white"]);
const TREATMENT_FIELDS = Object.freeze(["bike_lanes", "centerline", "crosswalk", "edge_lines", "evidence", "fill", "paint_wear", "reason", "sides", "sidewalk_width_m", "tactile_pads", "verge_width_m", "wear"]);
const BIKE_LANE_KINDS = Object.freeze(["none", "line", "green"]);
const STREET_RULE_FIELDS = Object.freeze(["evidence", "id", "treatment", "ways"]);
const STREET_RULE_OPTIONAL = Object.freeze(["parking", "red_curb", "set", "sides", "widen"]);
const STALL_STYLES = Object.freeze(["plain", "faded", "accessible", "accessible_filled", "bus"]);

function isXZ(point) {
  return Array.isArray(point) && point.length === 2 && point.every(isFiniteNumber);
}

function validateTreatment(treatment, label) {
  exactKeys(treatment, TREATMENT_FIELDS, label);
  for (const field of ["reason", "evidence"]) invariant(typeof treatment[field] === "string" && treatment[field].trim() !== "", `${label} needs ${field}`);
  invariant(SIDE_KINDS.includes(treatment.sides), `${label} sides must be ${SIDE_KINDS.join(", ")}`);
  invariant(treatment.centerline === null || RULE_CENTERLINES.includes(treatment.centerline), `${label} centerline must be null or ${RULE_CENTERLINES.join(", ")}`);
  invariant(CROSSWALK_STYLES.includes(treatment.crosswalk), `${label} crosswalk must be ${CROSSWALK_STYLES.join(", ")}`);
  invariant(FILL_KINDS.includes(treatment.fill), `${label} fill must be ${FILL_KINDS.join(", ")}`);
  invariant(typeof treatment.tactile_pads === "boolean", `${label} tactile_pads must be boolean`);
  invariant(typeof treatment.edge_lines === "boolean", `${label} edge_lines must be boolean`);
  invariant(BIKE_LANE_KINDS.includes(treatment.bike_lanes), `${label} bike_lanes must be ${BIKE_LANE_KINDS.join(", ")}`);
  invariant(Number.isInteger(treatment.paint_wear) && treatment.paint_wear >= 0 && treatment.paint_wear < PAINT_WEAR_STEPS, `${label} paint_wear must be a wear step 0-${PAINT_WEAR_STEPS - 1}`);
  invariant(isFiniteNumber(treatment.sidewalk_width_m) && treatment.sidewalk_width_m >= 0.9 && treatment.sidewalk_width_m <= 4, `${label} sidewalk_width_m must be 0.9-4 m`);
  invariant(isFiniteNumber(treatment.verge_width_m) && treatment.verge_width_m >= 0.6 && treatment.verge_width_m <= 3, `${label} verge_width_m must be 0.6-3 m`);
  exactKeys(treatment.wear, WEAR_FIELDS, `${label} wear`);
  for (const key of WEAR_FIELDS) invariant(isFiniteNumber(treatment.wear[key]) && treatment.wear[key] >= 0, `${label} wear.${key} must be non-negative`);
}

// The rules file, validated.
export function loadStreetGroundRules(projectRoot) {
  return validateStreetGroundRules(JSON.parse(readFileSync(resolve(projectRoot, STREET_GROUND_RULES_PATH), "utf8")));
}

// The validated rules, with each street's treatment fields resolved.
export function validateStreetGroundRules(rules) {
  exactKeys(rules, ["aprons", "bays", "crossings", "crosswalks", "lots", "notes", "pilot", "schema_version", "stalls", "stops", "streets", "treatments"], "Street ground rules");
  invariant(rules.schema_version === STREET_GROUND_RULES_SCHEMA, "Street ground rules schema drift");
  // The pilot zones' crosswalk paint wear (their other paint stays as built).
  exactKeys(rules.pilot, ["crosswalk_paint_wear", "evidence"], "Street ground rules pilot");
  invariant(Number.isInteger(rules.pilot.crosswalk_paint_wear) && rules.pilot.crosswalk_paint_wear >= 0 && rules.pilot.crosswalk_paint_wear < PAINT_WEAR_STEPS &&
    typeof rules.pilot.evidence === "string" && rules.pilot.evidence.trim() !== "", "Street ground rules pilot needs a crosswalk paint wear step and its evidence");
  invariant(Array.isArray(rules.notes) && rules.notes.every((note) => typeof note === "string"), "Street ground rules notes must be strings");
  for (const [id, treatment] of Object.entries(rules.treatments)) {
    invariant(SAFE_ID.test(id), `Street ground treatment id ${id} is unsafe`);
    validateTreatment(treatment, `Street ground treatment ${id}`);
  }
  const streetIds = new Set();
  const wayOwner = new Map();
  const streets = rules.streets.map((street) => {
    const label = `Street ground street ${street?.id}`;
    exactKeys(street, [...STREET_RULE_FIELDS, ...STREET_RULE_OPTIONAL.filter((field) => field in (street ?? {}))], label);
    invariant(typeof street.id === "string" && SAFE_ID.test(street.id) && !streetIds.has(street.id), `${label} needs a unique lower_snake id`);
    streetIds.add(street.id);
    invariant(typeof street.evidence === "string" && street.evidence.trim() !== "", `${label} needs evidence`);
    invariant(rules.treatments[street.treatment] !== undefined, `${label} names an unknown treatment ${street.treatment}`);
    invariant(Array.isArray(street.ways) && street.ways.length > 0 && street.ways.every((key) => /^w\d+$/u.test(key)), `${label} needs OSM way keys`);
    for (const key of street.ways) {
      invariant(!wayOwner.has(key), `${label}: way ${key} is already in street ${wayOwner.get(key)}`);
      wayOwner.set(key, street.id);
    }
    const treatment = { ...rules.treatments[street.treatment], ...(street.set ?? {}) };
    validateTreatment(treatment, `${label} (treatment ${street.treatment} with its set)`);
    const perWay = (field, check) => {
      const value = street[field] ?? {};
      invariant(value !== null && typeof value === "object" && !Array.isArray(value), `${label} ${field} must map way keys`);
      for (const [key, entry] of Object.entries(value)) {
        invariant(street.ways.includes(key), `${label} ${field} names ${key}, which is not one of its ways`);
        invariant(entry !== null && typeof entry === "object" && Object.keys(entry).every((side) => ["left", "right"].includes(side)), `${label} ${field}.${key} takes left and right`);
        for (const side of Object.keys(entry)) check(entry[side], `${label} ${field}.${key}.${side}`);
      }
      return value;
    };
    // A side is one kind, or stretches [from_m, to_m, kind] along the way.
    const sides = perWay("sides", (value, at) => invariant(SIDE_KINDS.includes(value) ||
      (Array.isArray(value) && value.length > 0 && value.every((stretch) => Array.isArray(stretch) && stretch.length === 3 &&
        isFiniteNumber(stretch[0]) && isFiniteNumber(stretch[1]) && stretch[0] < stretch[1] && SIDE_KINDS.includes(stretch[2]))),
    `${at} must be ${SIDE_KINDS.join(", ")} or [from_m, to_m, kind] stretches`));
    const widen = perWay("widen", (value, at) => invariant(isFiniteNumber(value) && value >= 0 && value <= 6, `${at} must be 0-6 m`));
    const stretches = (value, at) => invariant(Array.isArray(value) && value.every((stretch) => Array.isArray(stretch) && stretch.length === 2 && stretch.every(isFiniteNumber) && stretch[0] < stretch[1]), `${at} must list [from_m, to_m] stretches`);
    const parking = perWay("parking", stretches);
    // Red curb paint is only ever what a dated photograph shows of a side.
    const redCurb = perWay("red_curb", stretches);
    return { id: street.id, ways: street.ways, treatment_id: street.treatment, treatment, sides, widen, parking, redCurb, evidence: street.evidence };
  });
  invariant(rules.crossings !== null && typeof rules.crossings === "object" && !Array.isArray(rules.crossings), "Street ground crossings must map node keys to styles");
  for (const [key, style] of Object.entries(rules.crossings)) {
    invariant(/^n\d+$/u.test(key) && CROSSWALK_STYLES.includes(style), `Street ground crossing ${key} must be a node key with a style of ${CROSSWALK_STYLES.join(", ")}`);
  }
  for (const stop of rules.stops) {
    exactKeys(stop, ["evidence", "node", "way", ...("own_line" in (stop ?? {}) ? ["own_line"] : [])], "Street ground stop");
    invariant(/^n\d+$/u.test(stop.node) && /^w\d+$/u.test(stop.way) && typeof stop.evidence === "string" && stop.evidence.trim() !== "" &&
      (stop.own_line === undefined || typeof stop.own_line === "boolean"), "Street ground stop needs a node, its approach way and evidence");
  }
  // Crosswalks photographed where OSM maps no crossing: across a way at a distance along it.
  for (const walk of rules.crosswalks) {
    exactKeys(walk, ["at_m", "evidence", "style", "way", ...("width_m" in (walk ?? {}) ? ["width_m"] : [])], "Street ground crosswalk");
    invariant(/^w\d+$/u.test(walk.way) && isFiniteNumber(walk.at_m) && walk.at_m >= 0 && CROSSWALK_STYLES.includes(walk.style) && walk.style !== "none" &&
      (walk.width_m === undefined || (isFiniteNumber(walk.width_m) && walk.width_m >= 2 && walk.width_m <= 12)) &&
      typeof walk.evidence === "string" && walk.evidence.trim() !== "", `Street ground crosswalk on ${walk.way} is malformed`);
  }
  // Pavement flush with a street's edge, out to a building's parking (no stalls).
  for (const apron of rules.aprons) {
    exactKeys(apron, ["depth_m", "evidence", "from_m", "side", "to_m", "way"], "Street ground apron");
    invariant(/^w\d+$/u.test(apron.way) && ["left", "right"].includes(apron.side) && isFiniteNumber(apron.from_m) && isFiniteNumber(apron.to_m) && apron.to_m > apron.from_m &&
      isFiniteNumber(apron.depth_m) && apron.depth_m >= 0.3 && apron.depth_m <= 7 && typeof apron.evidence === "string" && apron.evidence.trim() !== "",
    `Street ground apron on ${apron.way} is malformed`);
  }
  // Stall lines painted across a widened shoulder (no new pavement).
  for (const stall of rules.stalls) {
    exactKeys(stall, ["evidence", "from_m", "side", "stall_width_m", "to_m", "way"], "Street ground shoulder stalls");
    invariant(/^w\d+$/u.test(stall.way) && ["left", "right"].includes(stall.side) && isFiniteNumber(stall.from_m) && isFiniteNumber(stall.to_m) && stall.to_m - stall.from_m >= 2.4 &&
      isFiniteNumber(stall.stall_width_m) && stall.stall_width_m >= 2.2 && stall.stall_width_m <= 3.5 && typeof stall.evidence === "string" && stall.evidence.trim() !== "",
    `Street ground shoulder stalls on ${stall.way} are malformed`);
  }
  for (const bay of rules.bays) {
    exactKeys(bay, ["depth_m", "evidence", "from_m", "lines", "side", "stall_width_m", "to_m", "way"], "Street ground bay");
    invariant(/^w\d+$/u.test(bay.way) && ["left", "right"].includes(bay.side) && isFiniteNumber(bay.from_m) && isFiniteNumber(bay.to_m) && bay.to_m - bay.from_m >= 2.4 &&
      isFiniteNumber(bay.depth_m) && bay.depth_m >= 4 && bay.depth_m <= 7 && isFiniteNumber(bay.stall_width_m) && bay.stall_width_m >= 2.2 && bay.stall_width_m <= 3.5 &&
      typeof bay.lines === "boolean" && typeof bay.evidence === "string" && bay.evidence.trim() !== "", `Street ground bay on ${bay.way} is malformed`);
  }
  const lotIds = new Set();
  const lots = rules.lots.map(expandLotPattern);
  for (const lot of lots) {
    const label = `Street ground lot ${lot?.id}`;
    exactKeys(lot, ["evidence", "hatches", "id", "islands", "legends", "paint_wear", "rows", "source_key", ...["osm_exception", "pattern", "planted", "surface"].filter((field) => field in (lot ?? {}))], label);
    invariant(Number.isInteger(lot.paint_wear) && lot.paint_wear >= 0 && lot.paint_wear < PAINT_WEAR_STEPS, `${label} paint_wear must be a wear step`);
    for (const hatch of lot.hatches) {
      exactKeys(hatch, ["id", "points_xz", "stripes"], `${label} hatch`);
      invariant(SAFE_ID.test(hatch.id) && Array.isArray(hatch.points_xz) && hatch.points_xz.length >= 3 && hatch.points_xz.every(isXZ) && typeof hatch.stripes === "boolean",
        `${label} hatch ${hatch.id} needs 3+ points and stripes`);
    }
    // A lot's own pavement where the photographs show it unlike the lots' asphalt:
    // a yard or park ground material draped over the whole lot at LOT_SURFACE_LIFT_M.
    if (lot.surface !== undefined) {
      exactKeys(lot.surface, ["evidence", "material", "patch_strips", "seams", "wear"], `${label} surface`);
      exactKeys(lot.surface.wear, LOT_WEAR_FIELDS, `${label} surface wear`);
      for (const key of LOT_WEAR_FIELDS) invariant(isFiniteNumber(lot.surface.wear[key]) && lot.surface.wear[key] >= 0, `${label} surface wear.${key} must be non-negative`);
      // Long tar-sealed joints and patched strips, each along a line.
      for (const seam of lot.surface.seams) {
        exactKeys(seam, ["line_xz", "width_m"], `${label} surface seam`);
        invariant(Array.isArray(seam.line_xz) && seam.line_xz.length === 2 && seam.line_xz.every(isXZ) && isFiniteNumber(seam.width_m) && seam.width_m > 0 && seam.width_m <= 0.3,
          `${label} surface seam is malformed`);
      }
      for (const strip of lot.surface.patch_strips) {
        exactKeys(strip, ["line_xz", "width_m"], `${label} surface patch strip`);
        invariant(Array.isArray(strip.line_xz) && strip.line_xz.length === 2 && strip.line_xz.every(isXZ) && isFiniteNumber(strip.width_m) && strip.width_m > 0 && strip.width_m <= 4,
          `${label} surface patch strip is malformed`);
      }
      invariant(PARK_SURFACE_MATERIALS[lot.surface.material] !== undefined && typeof lot.surface.evidence === "string" && lot.surface.evidence.trim() !== "",
        `${label} surface needs a ground material (${Object.keys(PARK_SURFACE_MATERIALS).join(", ")}) and evidence`);
    }
    invariant(typeof lot.id === "string" && SAFE_ID.test(lot.id) && !lotIds.has(lot.id), `${label} needs a unique lower_snake id`);
    lotIds.add(lot.id);
    invariant(/^w\d+$/u.test(lot.source_key) && typeof lot.evidence === "string" && lot.evidence.trim() !== "", `${label} needs its OSM parking area and evidence`);
    for (const row of lot.rows) {
      exactKeys(row, ["angle_deg", "count", "depth_m", "id", "line_xz", "side", "stall_width_m", "style"], `${label} row ${row?.id}`);
      invariant(typeof row.id === "string" && SAFE_ID.test(row.id) && Array.isArray(row.line_xz) && row.line_xz.length === 2 && row.line_xz.every(isXZ) &&
        ["left", "right"].includes(row.side) && STALL_STYLES.includes(row.style) && Number.isInteger(row.count) && row.count >= 1 &&
        isFiniteNumber(row.depth_m) && row.depth_m >= 4 && row.depth_m <= 16 && isFiniteNumber(row.stall_width_m) && row.stall_width_m >= 2.2 && row.stall_width_m <= 5 &&
        isFiniteNumber(row.angle_deg) && row.angle_deg >= 45 && row.angle_deg <= 90, `${label} row ${row.id} is malformed`);
    }
    for (const strip of lot.planted ?? []) {
      exactKeys(strip, ["evidence", "id", "points_xz"], `${label} planted strip`);
      invariant(SAFE_ID.test(strip.id) && Array.isArray(strip.points_xz) && strip.points_xz.length >= 3 && strip.points_xz.every(isXZ) && typeof strip.evidence === "string" && strip.evidence !== "", `${label} planted strip ${strip.id} is malformed`);
    }
    for (const island of lot.islands) {
      exactKeys(island, ["id", "points_xz", ...("fill" in (island ?? {}) ? ["fill"] : [])], `${label} island`);
      invariant(island.fill === undefined || island.fill === "mulch", `${label} island ${island.id} fill must be mulch`);
      invariant(SAFE_ID.test(island.id) && Array.isArray(island.points_xz) && island.points_xz.length >= 3 && island.points_xz.every(isXZ), `${label} island ${island.id} needs 3+ points`);
    }
    for (const legend of lot.legends) {
      exactKeys(legend, ["at_xz", "cell", "facing_xz", "length_m", "paint_wear", "width_m"], `${label} legend`);
      invariant(STREET_LEGEND_CELLS[legend.cell] !== undefined && isXZ(legend.at_xz) && isXZ(legend.facing_xz) && Math.hypot(...legend.facing_xz) > 1e-6 &&
        isFiniteNumber(legend.length_m) && legend.length_m > 0 && isFiniteNumber(legend.width_m) && legend.width_m > 0 &&
        Number.isInteger(legend.paint_wear) && legend.paint_wear >= 0 && legend.paint_wear < PAINT_WEAR_STEPS, `${label} legend is malformed`);
    }
  }
  return { ...rules, lots, streets, wayOwner };
}

// The Johnson St lot, which OSM lacks: the one recorded exception to the snapshot
// as the horizontal layout. osm_exception holds the reason, the approval, the aerial
// with its date and zoom, and the traced outline, the only traced data. Everything
// inside comes from the pattern, in the lot's own axes: s along the bearing from the
// origin, t square to it, left of the bearing. A row's line runs along its aisle and
// fills with as many stalls as fit at about the pattern's width. Accessible bays
// reserve spans of their row, a hatched aisle between each pair; the rest of that
// row fills round them. zones are the hatched and outlined areas; lines and ticks are
// painted lines, ticks spaced along a line and square to it; arrows the aisles'
// arrows. curb_edges are the outline's edges (by their first point) with a raised
// curb just inside them; shoulder is the ground behind some of them, a dark band
// then pale gravel, offset outward from those edges.
const EXCEPTION_LOT_ID = "johnson_lot";
const LOT_PATTERN_FIELDS = Object.freeze(["accessible", "arrows", "bearing_xz", "curb_edges", "depth_m", "lines", "origin_xz", "rows", "shoulder", "stall_width_m", "ticks", "zones"]);
// About the least the raised band's clean-up keeps (bandRaised, 0.2 m wide).
const LOT_CURB_WIDTH_M = 0.22;
const LOT_LINE_WIDTH_M = 0.12;
const LOT_MINIMUM_STALL_M = 2.2;
const LOT_ARROW_LENGTH_M = 2;
const LOT_ARROW_WIDTH_M = 1;
const LOT_SYMBOL_M = 1.5;
// The shoulder's outer edge wanders as spread gravel does, a slow drift over
// SHOULDER_DRIFT_STEPS steps with a little grit on top; its strips run on past a
// joint with the next edge, so no wedge opens between them.
const SHOULDER_STEP_M = 1;
const SHOULDER_DRIFT_STEPS = 5;
const SHOULDER_WANDER_M = 0.3;
const SHOULDER_JOIN_M = 1;
function expandLotPattern(lot) {
  if (lot?.osm_exception === undefined) return lot;
  const label = `Street ground lot ${lot.id}`;
  invariant(lot.id === EXCEPTION_LOT_ID, `${label}: only ${EXCEPTION_LOT_ID} is an exception to the OSM layout`);
  const exception = lot.osm_exception;
  exactKeys(exception, ["aerial", "approved", "outline_xz", "reason"], `${label} osm_exception`);
  invariant(["aerial", "approved", "reason"].every((key) => typeof exception[key] === "string" && exception[key].trim() !== "") &&
    Array.isArray(exception.outline_xz) && exception.outline_xz.length >= 3 && exception.outline_xz.every(isXZ), `${label} osm_exception needs its aerial, approval, reason and outline`);
  const pattern = lot.pattern;
  exactKeys(pattern, LOT_PATTERN_FIELDS, `${label} pattern`);
  const outline = exception.outline_xz;
  invariant(isXZ(pattern.origin_xz) && isXZ(pattern.bearing_xz) && Math.hypot(...pattern.bearing_xz) > 1e-6 && isFiniteNumber(pattern.stall_width_m) && isFiniteNumber(pattern.depth_m) &&
    Array.isArray(pattern.curb_edges) && pattern.curb_edges.every((edge) => Number.isInteger(edge) && edge >= 0 && edge < outline.length), `${label} pattern is malformed`);
  const size = Math.hypot(...pattern.bearing_xz);
  const u = [pattern.bearing_xz[0] / size, pattern.bearing_xz[1] / size];
  // Left of the bearing seen from above (x east, z south).
  const v = [u[1], -u[0]];
  const direction = ([s, t]) => [u[0] * s + v[0] * t, u[1] * s + v[1] * t];
  const at = (st) => direction(st).map((offset, axis) => roundCoordinate(pattern.origin_xz[axis] + offset));
  const rows = [];
  const hatches = [];
  const addStalls = (id, from, to, row, width, style) => {
    const angle = row.angle_deg ?? 90;
    const run = Math.hypot(to[0] - from[0], to[1] - from[1]) * Math.sin((angle * Math.PI) / 180);
    const count = Math.round(run / width);
    if (count === 0 || run / count < LOT_MINIMUM_STALL_M) return;
    rows.push({ id, line_xz: [at(from), at(to)], side: row.side, count, depth_m: row.depth_m ?? pattern.depth_m, stall_width_m: roundCoordinate(run / count), angle_deg: angle, style });
  };
  const addZone = (id, points, stripes) => hatches.push({ id, points_xz: points.map(at), stripes });
  const addLine = (id, from, to) => {
    const run = Math.hypot(to[0] - from[0], to[1] - from[1]);
    const half = [((from[1] - to[1]) / run) * (LOT_LINE_WIDTH_M / 2), ((to[0] - from[0]) / run) * (LOT_LINE_WIDTH_M / 2)];
    addZone(id, [[from[0] + half[0], from[1] + half[1]], [to[0] + half[0], to[1] + half[1]], [to[0] - half[0], to[1] - half[1]], [from[0] - half[0], from[1] - half[1]]], false);
  };
  // The bays, and what they reserve of their row.
  const bays = pattern.accessible;
  exactKeys(bays, ["aisle_m", "hatched_s_m", "pairs_at_s_m", "row", "singles_at_s_m", "stall_width_m"], `${label} pattern accessible`);
  const bayRow = pattern.rows.find((row) => row.id === bays.row);
  invariant(bayRow && bayRow.from_st[1] === bayRow.to_st[1] && bayRow.to_st[0] > bayRow.from_st[0], `${label} accessible bays need a row along the bearing`);
  const line = bayRow.from_st[1];
  const head = line + (bayRow.side === "left" ? 1 : -1) * (bayRow.depth_m ?? pattern.depth_m);
  const box = (from, to) => [[from, line], [to, line], [to, head], [from, head]];
  const bay = (id, from) => addStalls(id, [from, line], [from + bays.stall_width_m, line], bayRow, bays.stall_width_m, "accessible_filled");
  const spans = [];
  bays.pairs_at_s_m.forEach((aisle, index) => {
    bay(`accessible_${index}_a`, aisle - bays.stall_width_m);
    bay(`accessible_${index}_b`, aisle + bays.aisle_m);
    addZone(`accessible_${index}_aisle`, box(aisle, aisle + bays.aisle_m), true);
    spans.push([aisle - bays.stall_width_m, aisle + bays.aisle_m + bays.stall_width_m]);
  });
  bays.singles_at_s_m.forEach((from, index) => {
    bay(`accessible_single_${index}`, from);
    spans.push([from, from + bays.stall_width_m]);
  });
  bays.hatched_s_m.forEach(([from, to], index) => {
    addZone(`reserved_${index}`, box(from, to), true);
    spans.push([from, to]);
  });
  spans.sort((left, right) => left[0] - right[0]);
  for (const row of pattern.rows) {
    exactKeys(row, ["from_st", "id", "side", "to_st", ...["angle_deg", "depth_m"].filter((key) => key in row)], `${label} pattern row ${row.id}`);
    invariant(isXZ(row.from_st) && isXZ(row.to_st), `${label} pattern row ${row.id} needs its line`);
    if (row !== bayRow) {
      addStalls(row.id, row.from_st, row.to_st, row, pattern.stall_width_m, "plain");
      continue;
    }
    let from = row.from_st[0];
    [...spans, [row.to_st[0], row.to_st[0]]].forEach(([start, end], index) => {
      if (start > from) addStalls(`${row.id}_${index}`, [from, line], [start, line], row, pattern.stall_width_m, "plain");
      from = Math.max(from, end);
    });
  }
  pattern.zones.forEach((zone, index) => {
    exactKeys(zone, ["st", "stripes"], `${label} pattern zone ${index}`);
    invariant(Array.isArray(zone.st) && zone.st.length >= 3 && zone.st.every(isXZ) && typeof zone.stripes === "boolean", `${label} pattern zone ${index} is malformed`);
    addZone(`zone_${index}`, zone.st, zone.stripes);
  });
  pattern.lines.forEach((entry, index) => {
    invariant(Array.isArray(entry) && entry.length === 2 && entry.every(isXZ), `${label} pattern line ${index} is malformed`);
    addLine(`line_${index}`, entry[0], entry[1]);
  });
  // Ticks stand evenly along their line (at its middle for a single one), square to it.
  pattern.ticks.forEach((tick, index) => {
    exactKeys(tick, ["count", "from_st", "length_m", "to_st"], `${label} pattern tick ${index}`);
    const offset = [tick.to_st[0] - tick.from_st[0], tick.to_st[1] - tick.from_st[1]];
    const run = Math.hypot(...offset);
    const half = [(offset[1] / run) * (tick.length_m / 2), (-offset[0] / run) * (tick.length_m / 2)];
    for (let step = 0; step < tick.count; step += 1) {
      const fraction = tick.count === 1 ? 0.5 : step / (tick.count - 1);
      const point = [tick.from_st[0] + offset[0] * fraction, tick.from_st[1] + offset[1] * fraction];
      addLine(`tick_${index}_${step}`, [point[0] - half[0], point[1] - half[1]], [point[0] + half[0], point[1] + half[1]]);
    }
  });
  const legends = pattern.arrows.map((arrow, index) => {
    exactKeys(arrow, ["at_st", "facing_st"], `${label} pattern arrow ${index}`);
    invariant(isXZ(arrow.at_st) && isXZ(arrow.facing_st), `${label} pattern arrow ${index} is malformed`);
    return { cell: "arrow_short", at_xz: at(arrow.at_st), facing_xz: direction(arrow.facing_st).map(roundCoordinate), length_m: LOT_ARROW_LENGTH_M, width_m: LOT_ARROW_WIDTH_M, paint_wear: lot.paint_wear };
  });
  const shoulder = pattern.shoulder;
  exactKeys(shoulder, ["band_m", "band_material", "edges", "gravel_m", "gravel_material"], `${label} pattern shoulder`);
  invariant(isFiniteNumber(shoulder.band_m) && shoulder.band_m > 0 && isFiniteNumber(shoulder.gravel_m) && shoulder.gravel_m > 0 &&
    PARK_SURFACE_MATERIALS[shoulder.band_material] !== undefined && PARK_SURFACE_MATERIALS[shoulder.gravel_material] !== undefined &&
    Array.isArray(shoulder.edges) && shoulder.edges.every((edge) => Number.isInteger(edge) && edge >= 0 && edge < outline.length), `${label} pattern shoulder is malformed`);
  // The curb: a strip inside each curbed edge, run on past its ends to meet its
  // neighbours (the generator clips the strips to the lot).
  const doubledArea = outline.reduce((sum, a, index) => {
    const b = outline[(index + 1) % outline.length];
    return sum + a[0] * b[1] - b[0] * a[1];
  }, 0);
  const inward = doubledArea > 0 ? 1 : -1;
  const islands = pattern.curb_edges.map((edge) => {
    const a = outline[edge];
    const b = outline[(edge + 1) % outline.length];
    const run = Math.hypot(b[0] - a[0], b[1] - a[1]);
    const heading = [((b[0] - a[0]) / run) * LOT_CURB_WIDTH_M, ((b[1] - a[1]) / run) * LOT_CURB_WIDTH_M];
    const inside = [-heading[1] * inward, heading[0] * inward];
    const start = [a[0] - heading[0], a[1] - heading[1]];
    const end = [b[0] + heading[0], b[1] + heading[1]];
    return { id: `curb_${edge}`, points_xz: [start, end, [end[0] + inside[0], end[1] + inside[1]], [start[0] + inside[0], start[1] + inside[1]]].map((point) => point.map(roundCoordinate)) };
  });
  return { ...lot, rows, hatches, islands, legends };
}

// ---------------------------------------------------------------- geometry

function hashUnit(seed, identity, slot = 0) {
  return createHash("sha256").update(`${seed}|${identity}`, "utf8").digest().readUInt32BE(slot * 4) / 0xffffffff;
}

function sub(a, b) {
  return [a[0] - b[0], a[1] - b[1]];
}

function add(a, b) {
  return [a[0] + b[0], a[1] + b[1]];
}

function scale(a, s) {
  return [a[0] * s, a[1] * s];
}

function dot(a, b) {
  return a[0] * b[0] + a[1] * b[1];
}

function cross(a, b) {
  return a[0] * b[1] - a[1] * b[0];
}

function length(a) {
  return Math.hypot(a[0], a[1]);
}

function unit(a) {
  const l = length(a);
  invariant(l > 1e-12, "Cannot normalize a zero vector");
  return [a[0] / l, a[1] / l];
}

// Left normal of a direction in the east/north frame.
function leftOf(direction) {
  return [-direction[1], direction[0]];
}

function emptyBox() {
  return { min_x: Infinity, min_y: Infinity, max_x: -Infinity, max_y: -Infinity };
}

function growBox(box, point) {
  box.min_x = Math.min(box.min_x, point[0]);
  box.min_y = Math.min(box.min_y, point[1]);
  box.max_x = Math.max(box.max_x, point[0]);
  box.max_y = Math.max(box.max_y, point[1]);
  return box;
}

function boxOfPoints(points) {
  return points.reduce(growBox, emptyBox());
}

function boxOfMulti(multi) {
  const box = emptyBox();
  for (const polygon of multi) for (const point of polygon[0]) growBox(box, point);
  return box;
}

function boxesOverlap(left, right, margin = 0) {
  return left.min_x <= right.max_x + margin && right.min_x <= left.max_x + margin &&
    left.min_y <= right.max_y + margin && right.min_y <= left.max_y + margin;
}

function inBox(box, point, margin = 0) {
  return point[0] >= box.min_x - margin && point[0] <= box.max_x + margin && point[1] >= box.min_y - margin && point[1] <= box.max_y + margin;
}

function openRing(ring) {
  const points = ring.length > 1 && ring[0][0] === ring.at(-1)[0] && ring[0][1] === ring.at(-1)[1] ? ring.slice(0, -1) : ring.slice();
  const merged = [];
  for (const point of points) {
    if (merged.length === 0 || length(sub(point, merged.at(-1))) > STREET_GROUND_EDGE_MERGE_M) merged.push(point);
  }
  while (merged.length > 2 && length(sub(merged[0], merged.at(-1))) <= STREET_GROUND_EDGE_MERGE_M) merged.pop();
  return merged;
}

function ringArea(ring) {
  let doubled = 0;
  for (let index = 0; index < ring.length; index += 1) doubled += cross(ring[index], ring[(index + 1) % ring.length]);
  return doubled / 2;
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

function multiPerimeter(multi) {
  let total = 0;
  for (const polygon of multi) {
    for (const raw of polygon) {
      const ring = openRing(raw);
      for (let index = 0; index < ring.length; index += 1) total += length(sub(ring[(index + 1) % ring.length], ring[index]));
    }
  }
  return total;
}

function pointInPolygon(point, polygon) {
  if (!pointInRing(point, openRing(polygon[0]), true)) return false;
  return !polygon.slice(1).some((hole) => pointInRing(point, openRing(hole), false));
}

// pointInPolygon on rings already opened.
function pointInOpenRings(point, rings) {
  if (!pointInRing(point, rings[0], true)) return false;
  return !rings.slice(1).some((hole) => pointInRing(point, hole, false));
}

function rectangle(origin, along, across, alongMin, alongMax, acrossMin, acrossMax) {
  const corner = (s, t) => add(origin, add(scale(along, s), scale(across, t)));
  const ring = [corner(alongMin, acrossMin), corner(alongMax, acrossMin), corner(alongMax, acrossMax), corner(alongMin, acrossMax)];
  return [[ringArea(ring) > 0 ? ring : ring.reverse()]];
}

function circle(center, radius, sides = 12) {
  const ring = [];
  for (let index = 0; index < sides; index += 1) {
    const angle = (index * 2 * Math.PI) / sides;
    ring.push([center[0] + Math.cos(angle) * radius, center[1] + Math.sin(angle) * radius]);
  }
  return [[ring]];
}

function convexHull(points) {
  const sorted = [...points].sort((left, right) => left[0] - right[0] || left[1] - right[1]);
  const half = (list) => {
    const hull = [];
    for (const point of list) {
      while (hull.length >= 2 && cross(sub(hull.at(-1), hull.at(-2)), sub(point, hull.at(-2))) <= 1e-12) hull.pop();
      hull.push(point);
    }
    return hull;
  };
  const lower = half(sorted);
  const upper = half([...sorted].reverse());
  return [...lower.slice(0, -1), ...upper.slice(0, -1)];
}

// Boolean operations on raw polygon-clipping multipolygons. A failure names the
// step: the output is deterministic, so a throw is a real geometry problem.
// polygon-clipping's sweep can fail on nearly coincident or nearly collinear
// edges ("Unable to complete output ring", "Unable to find segment"), which
// island-wide bands meet. A failed operation is retried with its operands on a
// lattice (1/1024 m, then 1/256 m, then 1/64 m), where such corners coincide
// exactly; the output is deterministic either way.
// An output with a non-finite coordinate (nearly parallel edges can give one
// without a throw) counts as a failure.
const RETRY_LATTICES = Object.freeze([1024, 256, 64]);
function finiteMulti(multi) {
  return multi.every((polygon) => polygon.every((ring) => ring.every(([x, y]) => Number.isFinite(x) && Number.isFinite(y))));
}
// A boolean that failed on every lattice; callers that can fall back catch only this.
class BooleanFailure extends Error {}

function guarded(label, operation, operands) {
  let failure = null;
  for (const steps of [null, ...RETRY_LATTICES]) {
    try {
      const result = operation(...(steps === null ? operands : operands.map((operand) => onLattice(operand, steps))));
      if (finiteMulti(result)) return result;
      failure ??= new Error("non-finite coordinate in the output");
    } catch (error) {
      failure ??= error;
    }
  }
  throw new BooleanFailure(`Street ground ${label} boolean failed: ${failure.message}`, { cause: failure });
}

function union(label, parts) {
  let queue = parts.filter((part) => part.length > 0);
  if (queue.length === 0) return [];
  while (queue.length > 1) {
    const next = [];
    for (let index = 0; index < queue.length; index += 2) {
      next.push(index + 1 < queue.length ? guarded(label, polygonClipping.union, [queue[index], queue[index + 1]]) : queue[index]);
    }
    queue = next;
  }
  return guarded(label, polygonClipping.union, [queue[0]]);
}

// A multipolygon on a lattice of 1/steps m (1/1024 by default): nearly
// coincident corners of neighbouring pieces coincide exactly, which
// polygon-clipping needs to close its rings when many pieces meet.
function onLattice(multi, steps = 1024) {
  const snap = (value) => Math.round(value * steps) / steps;
  return multi.map((polygon) => polygon.map((ring) => ring.map(([x, y]) => [snap(x), snap(y)])));
}

// union, retried on the lattice when polygon-clipping cannot close a ring.
function unionOnLattice(label, parts) {
  try {
    return union(label, parts);
  } catch {
    return union(`${label} on the lattice`, parts.map((part) => onLattice(part)));
  }
}

function intersect(label, left, right) {
  if (left.length === 0 || right.length === 0) return [];
  return guarded(label, polygonClipping.intersection, [left, right]);
}

function difference(label, subject, clips) {
  const nonEmpty = clips.filter((clip) => clip.length > 0);
  if (subject.length === 0 || nonEmpty.length === 0) return subject;
  return guarded(label, polygonClipping.difference, [subject, ...nonEmpty]);
}

// Individual polygons with bounds, so local operations only touch nearby parts;
// a grid of their bounds finds them (in their original order).
const POLYGON_CELL_M = 32;
function polygonIndex(multi) {
  const items = multi.map((polygon) => ({ polygon, box: boxOfPoints(polygon[0]), rings: null }));
  const cells = new Map();
  items.forEach((item, index) => {
    for (let i = Math.floor(item.box.min_x / POLYGON_CELL_M); i <= Math.floor(item.box.max_x / POLYGON_CELL_M); i += 1) {
      for (let j = Math.floor(item.box.min_y / POLYGON_CELL_M); j <= Math.floor(item.box.max_y / POLYGON_CELL_M); j += 1) {
        const key = `${i},${j}`;
        if (!cells.has(key)) cells.set(key, []);
        cells.get(key).push(index);
      }
    }
  });
  return {
    multi,
    near(box, margin = 0) {
      const found = new Set();
      for (let i = Math.floor((box.min_x - margin) / POLYGON_CELL_M); i <= Math.floor((box.max_x + margin) / POLYGON_CELL_M); i += 1) {
        for (let j = Math.floor((box.min_y - margin) / POLYGON_CELL_M); j <= Math.floor((box.max_y + margin) / POLYGON_CELL_M); j += 1) {
          for (const index of cells.get(`${i},${j}`) ?? []) if (boxesOverlap(items[index].box, box, margin)) found.add(index);
        }
      }
      return [...found].sort((left, right) => left - right).map((index) => items[index].polygon);
    },
    contains(point) {
      for (const index of cells.get(`${Math.floor(point[0] / POLYGON_CELL_M)},${Math.floor(point[1] / POLYGON_CELL_M)}`) ?? []) {
        const item = items[index];
        if (inBox(item.box, point) && pointInOpenRings(point, item.rings ??= item.polygon.map(openRing))) return true;
      }
      return false;
    },
  };
}

// A union of many overlapping source parts (road or path ribbons), kept as its
// parts. Island-wide the carriageway is one polygon holding every road edge, and
// polygon-clipping sweeps all of an operand's edges, so cutting each small piece
// against the whole union was slow. A point lies in the union when it lies in a
// part; outside it, its distance to the union is its distance to the nearest
// part; a small piece is cut against the union of only the parts near it
// (local, cached by the set of parts).
const PARTS_CELL_M = 32;
const EDGE_CELL_M = 4;
function partsIndex(label, multis) {
  const items = [];
  for (const multi of multis) {
    for (const polygon of multi) items.push({ polygon, box: boxOfPoints(polygon[0]), rings: null });
  }
  const cells = new Map();
  items.forEach((item, index) => {
    for (let i = Math.floor(item.box.min_x / PARTS_CELL_M); i <= Math.floor(item.box.max_x / PARTS_CELL_M); i += 1) {
      for (let j = Math.floor(item.box.min_y / PARTS_CELL_M); j <= Math.floor(item.box.max_y / PARTS_CELL_M); j += 1) {
        const key = `${i},${j}`;
        if (!cells.has(key)) cells.set(key, []);
        cells.get(key).push(index);
      }
    }
  });
  const indicesNear = (box, margin = 0) => {
    const found = new Set();
    for (let i = Math.floor((box.min_x - margin) / PARTS_CELL_M); i <= Math.floor((box.max_x + margin) / PARTS_CELL_M); i += 1) {
      for (let j = Math.floor((box.min_y - margin) / PARTS_CELL_M); j <= Math.floor((box.max_y + margin) / PARTS_CELL_M); j += 1) {
        for (const index of cells.get(`${i},${j}`) ?? []) if (boxesOverlap(items[index].box, box, margin)) found.add(index);
      }
    }
    return [...found].sort((left, right) => left - right);
  };
  const ringsOf = (item) => (item.rings ??= item.polygon.map(openRing));
  const contains = (point) => {
    for (const index of cells.get(`${Math.floor(point[0] / PARTS_CELL_M)},${Math.floor(point[1] / PARTS_CELL_M)}`) ?? []) {
      const item = items[index];
      if (inBox(item.box, point) && pointInOpenRings(point, ringsOf(item))) return true;
    }
    return false;
  };
  const unions = new Map();
  // Every ring edge, in pieces of at most half a cell, listed in the cells it crosses.
  let edgeCells = null;
  const buildEdges = () => {
    edgeCells = new Map();
    for (const item of items) {
      for (const ring of ringsOf(item)) {
        ring.forEach((a, at) => {
          const b = ring[(at + 1) % ring.length];
          const edge = sub(b, a);
          const pieces = Math.max(1, Math.ceil(length(edge) / (EDGE_CELL_M / 2)));
          const touched = new Set();
          for (let piece = 0; piece < pieces; piece += 1) {
            const p = add(a, scale(edge, piece / pieces));
            const q = piece + 1 === pieces ? b : add(a, scale(edge, (piece + 1) / pieces));
            for (let i = Math.floor(Math.min(p[0], q[0]) / EDGE_CELL_M); i <= Math.floor(Math.max(p[0], q[0]) / EDGE_CELL_M); i += 1) {
              for (let j = Math.floor(Math.min(p[1], q[1]) / EDGE_CELL_M); j <= Math.floor(Math.max(p[1], q[1]) / EDGE_CELL_M); j += 1) touched.add(`${i},${j}`);
            }
          }
          for (const key of touched) {
            if (!edgeCells.has(key)) edgeCells.set(key, []);
            edgeCells.get(key).push([a, b]);
          }
        });
      }
    }
  };
  return {
    multi: items.map((item) => item.polygon),
    contains,
    // The part polygons whose bounds come within margin of a box.
    near: (box, margin = 0) => indicesNear(box, margin).map((index) => items[index].polygon),
    // The union of the parts near a box: what a piece inside the box is cut against.
    local(box, margin = 0) {
      const indices = indicesNear(box, margin);
      if (indices.length === 0) return [];
      const key = indices.join(",");
      if (!unions.has(key)) unions.set(key, union(`${label} near`, indices.map((index) => [items[index].polygon])));
      return unions.get(key);
    },
    // Plan distance to the union (0 inside it). Exact when the union lies within
    // reach; past reach it may return a larger distance or Infinity.
    distance(point, reach) {
      if (contains(point)) return 0;
      if (edgeCells === null) buildEdges();
      const ci = Math.floor(point[0] / EDGE_CELL_M);
      const cj = Math.floor(point[1] / EDGE_CELL_M);
      let best = Infinity;
      for (let ring = 0; (ring - 1) * EDGE_CELL_M <= reach; ring += 1) {
        if ((ring - 1) * EDGE_CELL_M > best) break;
        for (let di = -ring; di <= ring; di += 1) {
          for (let dj = -ring; dj <= ring; dj += 1) {
            if (Math.max(Math.abs(di), Math.abs(dj)) !== ring) continue;
            for (const [a, b] of edgeCells.get(`${ci + di},${cj + dj}`) ?? []) {
              const edge = sub(b, a);
              const t = Math.max(0, Math.min(1, dot(sub(point, a), edge) / Math.max(1e-12, dot(edge, edge))));
              best = Math.min(best, length(sub(point, add(a, scale(edge, t)))));
            }
          }
        }
      }
      return best;
    },
  };
}

// Polylines (road centre lines) indexed by segment, for the nearest line to a
// point: the same answer as scanning every line in order, the first of equally
// near lines winning.
const LINE_CELL_M = 16;
function lineIndex(lines) {
  const cells = new Map();
  lines.forEach((line, index) => {
    for (let at = 1; at < line.length; at += 1) {
      const a = line[at - 1];
      const b = line[at];
      for (let i = Math.floor(Math.min(a[0], b[0]) / LINE_CELL_M); i <= Math.floor(Math.max(a[0], b[0]) / LINE_CELL_M); i += 1) {
        for (let j = Math.floor(Math.min(a[1], b[1]) / LINE_CELL_M); j <= Math.floor(Math.max(a[1], b[1]) / LINE_CELL_M); j += 1) {
          const key = `${i},${j}`;
          if (!cells.has(key)) cells.set(key, new Set());
          cells.get(key).add(index);
        }
      }
    }
  });
  const box = lines.reduce((total, line) => line.reduce(growBox, total), emptyBox());
  const maxRing = lines.length === 0 ? 0 : Math.ceil(Math.max(box.max_x - box.min_x, box.max_y - box.min_y) / LINE_CELL_M) + 2;
  // {index, near} of the nearest line (closestOnPolyline), or null when there are none.
  return (point) => {
    if (lines.length === 0) return null;
    const ci = Math.floor(point[0] / LINE_CELL_M);
    const cj = Math.floor(point[1] / LINE_CELL_M);
    // Lines within the first rings that hold any; then every line whose cells lie
    // within the best distance found, so no nearer line is missed.
    const seen = new Set();
    let best = null;
    const consider = (index) => {
      if (seen.has(index)) return;
      seen.add(index);
      const near = closestOnPolyline(lines[index], point);
      if (near && (!best || near.distance < best.near.distance || (near.distance === best.near.distance && index < best.index))) best = { index, near };
    };
    for (let ring = 0; ring <= maxRing; ring += 1) {
      if (best && (ring - 1) * LINE_CELL_M > best.near.distance) break;
      for (let di = -ring; di <= ring; di += 1) {
        for (let dj = -ring; dj <= ring; dj += 1) {
          if (Math.max(Math.abs(di), Math.abs(dj)) !== ring) continue;
          for (const index of cells.get(`${ci + di},${cj + dj}`) ?? []) consider(index);
        }
      }
    }
    // A point far outside every line's cells: scan them all.
    if (!best) lines.forEach((_, index) => consider(index));
    return best;
  };
}

// Drops slivers: parts smaller than minimumArea or thinner than minimumWidth
// (mean width 2 * area / perimeter). Fills holes smaller than holeArea or
// thinner than holeWidth, so no ragged land sliver is left inside a sidewalk.
function cleanPolygons(multi, minimumArea, minimumWidth, holeArea = minimumArea, holeWidth = 0) {
  const kept = [];
  for (const polygon of multi) {
    const outer = polygon[0];
    const holes = polygon.slice(1).filter((hole) => {
      const ring = openRing(hole);
      const area = Math.abs(ringArea(ring));
      return area >= holeArea && (2 * area) / multiPerimeter([[hole]]) >= holeWidth;
    });
    const candidate = [outer, ...holes];
    const area = multiArea([candidate]);
    if (area < minimumArea) continue;
    if ((2 * area) / multiPerimeter([candidate]) < minimumWidth) continue;
    kept.push(candidate);
  }
  return kept;
}

// Offsets a polyline sideways by distance (positive = left), with mitred joins.
function offsetPolyline(points, distance) {
  const result = [];
  for (let index = 0; index < points.length; index += 1) {
    const before = index > 0 ? unit(sub(points[index], points[index - 1])) : null;
    const after = index < points.length - 1 ? unit(sub(points[index + 1], points[index])) : null;
    const normals = [before, after].filter(Boolean).map(leftOf);
    let miter = normals.length === 1 ? normals[0] : add(normals[0], normals[1]);
    if (length(miter) < 1e-9) miter = normals[0];
    miter = unit(miter);
    const cosine = Math.max(0.35, dot(miter, normals[0]));
    result.push(add(points[index], scale(miter, distance / cosine)));
  }
  return result;
}

// Raw band of a given half-width around every ring edge: segment rectangles and
// vertex discs, unioned without the strict canonical-ring checks (touching
// output is fine here). Vertices closer than a few centimetres are merged first:
// the band is a coarse morphological tool, and millimetre edges only give the
// boolean sweep near-degenerate input.
function boundaryBand(label, shape, radius) {
  const parts = [];
  for (const polygon of shape) {
    for (const raw of polygon) {
      const ring = [];
      for (const point of openRing(raw)) {
        if (ring.length === 0 || length(sub(point, ring.at(-1))) >= BAND_VERTEX_MERGE_M) ring.push(point);
      }
      while (ring.length > 1 && length(sub(ring.at(-1), ring[0])) < BAND_VERTEX_MERGE_M) ring.pop();
      ring.forEach((point, index) => {
        const next = ring[(index + 1) % ring.length];
        const edge = sub(next, point);
        if (length(edge) > 1e-6) {
          const normal = scale(leftOf(unit(edge)), radius);
          parts.push([[[add(point, normal), sub(point, normal), sub(next, normal), add(next, normal)]]]);
        }
        parts.push(circle(point, radius, 8));
      });
    }
  }
  // On a 1/1024 m lattice, nearly coincident corners of neighbouring parts coincide exactly.
  const snap = (value) => Math.round(value * 1024) / 1024;
  return union(label, parts.map((part) => part.map((polygon) => polygon.map((ring) => ring.map(([x, y]) => [snap(x), snap(y)])))));
}

// Everything within radius of a polyline: segment rectangles and vertex discs,
// unioned on the 1/1024 m lattice (a wide corridor round a curving way).
function lineBuffer(label, line, radius) {
  const snap = (value) => Math.round(value * 1024) / 1024;
  const parts = [];
  line.forEach((point, index) => {
    parts.push(circle(point, radius, 16));
    const next = line[index + 1];
    if (!next || length(sub(next, point)) < 1e-6) return;
    const normal = scale(leftOf(unit(sub(next, point))), radius);
    parts.push([[[add(point, normal), sub(point, normal), sub(next, normal), add(next, normal)]]]);
  });
  return union(label, parts.map((part) => part.map((polygon) => polygon.map((ring) => {
    const snapped = ring.map(([x, y]) => [snap(x), snap(y)]);
    return ringArea(snapped) > 0 ? snapped : snapped.reverse();
  }))));
}

// Morphological closing: fills gaps and notches narrower than 2 * radius
// between raised pieces (dilate, then erode by the same radius).
function closeGaps(label, multi, radius) {
  if (radius <= 0 || multi.length === 0) return multi;
  const dilated = union(`${label} dilate`, [multi, boundaryBand(`${label} outline`, multi, radius)]);
  return difference(`${label} erode`, dilated, [boundaryBand(`${label} dilated outline`, dilated, radius)]);
}

// Morphological opening: drops spikes and slivers narrower than twice the radius.
function openShapes(label, multi, radius) {
  if (radius <= 0 || multi.length === 0) return multi;
  const eroded = difference(`${label} erode`, multi, [boundaryBand(`${label} outline`, multi, radius)]);
  if (eroded.length === 0) return eroded;
  return union(`${label} dilate`, [eroded, boundaryBand(`${label} eroded outline`, eroded, radius)]);
}

// Squares of a fixed plan grid covering a box, for splitting large surfaces.
function gridCells(box, size) {
  const cells = [];
  for (let x = Math.floor(box.min_x / size) * size; x < box.max_x; x += size) {
    for (let y = Math.floor(box.min_y / size) * size; y < box.max_y; y += size) {
      cells.push([[[[x, y], [x + size, y], [x + size, y + size], [x, y + size]]]]);
    }
  }
  return cells;
}

// Which of gridCells(box, size) a multipolygon overlaps: those its edges pass
// through (each edge in pieces of at most half a cell, every cell a piece's
// bounds touch) and those whose centre lies inside it. A predicate on cells, so
// a long diagonal strip is cut only where it lies, not across its whole bounds.
function occupiedCells(multi, size) {
  const touched = new Set();
  for (const polygon of multi) {
    for (const ring of polygon) {
      ring.forEach((a, at) => {
        const b = ring[(at + 1) % ring.length];
        const edge = sub(b, a);
        const pieces = Math.max(1, Math.ceil(length(edge) / (size / 2)));
        for (let piece = 0; piece < pieces; piece += 1) {
          const p = add(a, scale(edge, piece / pieces));
          const q = piece + 1 === pieces ? b : add(a, scale(edge, (piece + 1) / pieces));
          for (let i = Math.floor(Math.min(p[0], q[0]) / size); i <= Math.floor(Math.max(p[0], q[0]) / size); i += 1) {
            for (let j = Math.floor(Math.min(p[1], q[1]) / size); j <= Math.floor(Math.max(p[1], q[1]) / size); j += 1) touched.add(`${i},${j}`);
          }
        }
      });
    }
  }
  const index = polygonIndex(multi);
  return (cell) => {
    const [x, y] = cell[0][0][0];
    return touched.has(`${Math.round(x / size)},${Math.round(y / size)}`) || index.contains([x + size / 2, y + size / 2]);
  };
}

// The strip between two sideways offsets of a polyline, as unioned quads.
function strip(label, points, from, to) {
  const near = offsetPolyline(points, from);
  const far = offsetPolyline(points, to);
  const quads = [];
  for (let index = 1; index < points.length; index += 1) {
    const ring = [near[index - 1], near[index], far[index], far[index - 1]];
    if (Math.abs(ringArea(ring)) < 1e-6) continue;
    quads.push([[ringArea(ring) > 0 ? ring : ring.reverse()]]);
  }
  return union(label, quads);
}

// Dashes along a polyline at an offset to its left: dash metres painted, then as
// many left bare, each dash a straight quad between its ends.
function dashedStrip(label, points, offset, width, dash) {
  const quads = [];
  const total = polylineLength(points);
  for (let start = dash / 2; start + dash <= total; start += dash * 2) {
    const ends = [pointAlong(points, start), pointAlong(points, start + dash)];
    const corners = ends.flatMap(({ point, tangent }) => {
      const left = [-tangent[1], tangent[0]];
      return [add(point, scale(left, offset - width / 2)), add(point, scale(left, offset + width / 2))];
    });
    const ring = [corners[0], corners[2], corners[3], corners[1]];
    if (Math.abs(ringArea(ring)) < 1e-6) continue;
    quads.push([[ringArea(ring) > 0 ? ring : ring.reverse()]]);
  }
  return union(label, quads);
}

function polylineLength(points) {
  let total = 0;
  for (let index = 1; index < points.length; index += 1) total += length(sub(points[index], points[index - 1]));
  return total;
}

// The part of a polyline between two distances along it.
function polylineSlice(points, from, to) {
  const result = [pointAlong(points, from).point];
  let walked = 0;
  for (let index = 1; index < points.length; index += 1) {
    walked += length(sub(points[index], points[index - 1]));
    if (walked > from + 1e-9 && walked < to - 1e-9) result.push(points[index]);
  }
  result.push(pointAlong(points, to).point);
  return result.filter((point, index) => index === 0 || length(sub(point, result[index - 1])) > 1e-6);
}

// Point and unit tangent at distance s along a polyline.
function pointAlong(points, s) {
  let walked = 0;
  for (let index = 1; index < points.length; index += 1) {
    const segment = length(sub(points[index], points[index - 1]));
    if (walked + segment >= s || index === points.length - 1) {
      const fraction = segment > 0 ? Math.max(0, Math.min(1, (s - walked) / segment)) : 0;
      const tangent = unit(sub(points[index], points[index - 1]));
      return { point: add(points[index - 1], scale(sub(points[index], points[index - 1]), fraction)), tangent };
    }
    walked += segment;
  }
  throw new Error("pointAlong on an empty polyline");
}

// Closest point on a polyline: {point, distance, along, tangent}.
function closestOnPolyline(points, point) {
  let best = null;
  let walked = 0;
  for (let index = 1; index < points.length; index += 1) {
    const start = points[index - 1];
    const delta = sub(points[index], start);
    const segment = length(delta);
    if (segment <= 1e-9) continue;
    const fraction = Math.max(0, Math.min(1, dot(sub(point, start), delta) / (segment * segment)));
    const closest = add(start, scale(delta, fraction));
    const distance = length(sub(point, closest));
    if (!best || distance < best.distance) best = { point: closest, distance, along: walked + fraction * segment, tangent: scale(delta, 1 / segment) };
    walked += segment;
  }
  return best;
}

// Parameters (fractions of start->end) where a segment crosses polygon edges.
function segmentPolygonCrossings(start, end, polygons) {
  const fractions = [];
  const delta = sub(end, start);
  for (const polygon of polygons) {
    for (const raw of polygon) {
      const ring = openRing(raw);
      for (let index = 0; index < ring.length; index += 1) {
        const a = ring[index];
        const b = ring[(index + 1) % ring.length];
        const edge = sub(b, a);
        const denominator = cross(delta, edge);
        if (Math.abs(denominator) < 1e-12) continue;
        const t = cross(sub(a, start), edge) / denominator;
        const u = cross(sub(a, start), delta) / denominator;
        if (t > 0 && t < 1 && u >= 0 && u <= 1) fractions.push(t);
      }
    }
  }
  return fractions.sort((left, right) => left - right);
}

// ---------------------------------------------------------------- pieces
// A piece is a plan polygon with an affine height above land and a UV rule.

function affineHeight(points, heights) {
  // Plane h = h0 + he * e + hn * n through three points.
  const [a, b, c] = points;
  const ab = sub(b, a);
  const ac = sub(c, a);
  const determinant = cross(ab, ac);
  invariant(Math.abs(determinant) > 1e-12, "Affine height needs a non-degenerate triangle");
  const dhb = heights[1] - heights[0];
  const dhc = heights[2] - heights[0];
  const he = (dhb * ac[1] - dhc * ab[1]) / determinant;
  const hn = (dhc * ab[0] - dhb * ac[0]) / determinant;
  return { h0: heights[0] - he * a[0] - hn * a[1], he, hn };
}

function constantHeight(value) {
  return { h0: value, he: 0, hn: 0 };
}

function heightAt(height, point) {
  return height.h0 + height.he * point[0] + height.hn * point[1];
}

function worldUv(point) {
  return [point[0] / 10, -point[1] / 10];
}

// World-planar UV in tiles of the given size (for direction-free textures).
function tiledUv(size) {
  return (point) => [point[0] / size, -point[1] / size];
}

// UV in tiles of the given size, in a frame running along a road: u along its
// centre line, v across it. Joints and paver bands follow the street.
function roadFrameUv(line, reference, size) {
  const near = closestOnPolyline(line, reference);
  return (point) => {
    const offset = sub(point, near.point);
    return [(near.along + dot(offset, near.tangent)) / size, cross(near.tangent, offset) / size];
  };
}

// UV for a paint kind with no texture placement (the shader tiles in world space).
function kindUv(kind, variant = 0) {
  return () => [kind + PAINT_VARIANT_STRIDE * variant + 0.5, 0.5];
}

// UV for a placed glyph or decal: integer part of u picks the cell, the fraction
// and v are the local coordinates over the decal's frame.
function frameUv(cell, origin, alongAxis, acrossAxis, alongSize, acrossSize) {
  return (point) => {
    const local = sub(point, origin);
    const u = Math.max(0.001, Math.min(0.999, dot(local, acrossAxis) / acrossSize + 0.5));
    const v = Math.max(0, Math.min(1, 1 - (dot(local, alongAxis) / alongSize + 0.5)));
    return [cell + u, v];
  };
}

// ---------------------------------------------------------------- main

export function generateStreetGround({
  config,
  playableObjects,
  rawOsm,
  properSources,
  facetsForChunk,
  facetElevation,
  spawnXZ,
  hardShapes,
  // The land's smooth shading normal at a plan point, or null (terrain overrides):
  // park surfaces over re-meshed land shade with it rather than per land triangle.
  normalAt = null,
  // The island-wide rules (validateStreetGroundRules), or null for the pilot zones alone.
  rules = null,
}) {
  const settings = streetGroundSettings(config);
  const { kerb, crossings, lines, lifts } = settings;
  const top = settings.top_m;
  const seed = config.seed;
  const objects = [...playableObjects.values()].sort((left, right) => compareSourceKeys(left.row.source_key, right.row.source_key));

  // Zone regions in the east/north frame.
  const zoneRegions = settings.zones.map(({ id, zone, settings: zoneSettings }) => {
    let region;
    if (zone.shape.type === "polygon") {
      const ring = zone.shape.points_xz.map(([x, z]) => [x, -z]);
      region = union(`zone ${id}`, [[[ringArea(ring) > 0 ? ring : ring.reverse()]]]);
    } else {
      region = union(`zone ${id}`, zone.shape.source_keys.map((key) =>
        lineRibbon(rawWayLine(rawOsm, key.slice(1)), zone.shape.half_width_m * 2, `zone ${id} ${key}`)));
    }
    return { id, settings: zoneSettings, region, index: polygonIndex(region), box: boxOfMulti(region) };
  });
  // Each rule street is a zone too: a corridor along its ways less the pilot
  // zones, which keep their own ground. It raises no pilot kerbs (its curbs come
  // from its rule) and carries its treatment's wear.
  const pilotRegion = union("pilot zones", zoneRegions.map((zone) => zone.region));
  // The island's land (the playable boundary's own geometry), which rule streets stay on.
  const land = [...playableObjects.values()].find((object) => object.roles.includes("land_boundary"));
  invariant(land, "Street ground needs the playable land boundary");
  // The pilot zones without kerbs hold ground of their own (the yards, the park)
  // and the props on it: a rule street's band keeps its back slope's run (and a
  // little more) clear of them.
  const pilotGround = union("pilot ground zones", zoneRegions.filter((zone) => !zone.settings.kerbs).map((zone) => zone.region));
  const pilotGroundMargin = pilotGround.length === 0 ? [] :
    union("pilot ground zone margin", [pilotGround, boundaryBand("pilot ground zone outline", pilotGround, kerb.back_slope_run_m + 0.2)]);
  const ruleOf = new Map();
  for (const street of rules?.streets ?? []) {
    for (const key of street.ways) ruleOf.set(key, street);
    const corridor = union(`street ${street.id}`, street.ways.map((key) =>
      lineBuffer(`street ${street.id} ${key}`, rawWayLine(rawOsm, key.slice(1)), STREET_CORRIDOR_HALF_M)));
    const region = difference(`street ${street.id} outside pilot`, intersect(`street ${street.id} on land`, corridor, land.geometry), [pilotRegion, pilotGroundMargin]);
    if (region.length === 0) continue;
    zoneRegions.push({
      id: `street_${street.id}`,
      rule: street,
      settings: { kerbs: false, centerlines: {}, lane_markings: false, planting: "none", parking_lanes: [], planting_behind_walk: [], plazas: [], parking_stalls: false, wear: street.treatment.wear },
      region,
      index: polygonIndex(region),
      box: boxOfMulti(region),
    });
  }
  const streetZones = zoneRegions.filter((zone) => zone.rule);
  const ruleRegion = union("rule streets", streetZones.map((zone) => zone.region));
  const ruleIndex = polygonIndex(ruleRegion);
  const pilot = union("pilot region", zoneRegions.map((zone) => zone.region));
  const pilotBox = boxOfMulti(pilot);
  const kerbRegion = union("kerb region", zoneRegions.filter((zone) => zone.settings.kerbs).map((zone) => zone.region));
  const zonesAt = (point) => zoneRegions.filter((zone) => inBox(zone.box, point) && zone.index.contains(point));

  // Frozen source geometry near the pilot: near one of its zones, so zones far
  // apart (the yards across the island) don't pull in everything between them.
  const nearPilot = (object, margin) => {
    const box = boxOfMulti(object.geometry);
    return boxesOverlap(box, pilotBox, margin) && zoneRegions.some((zone) => boxesOverlap(box, zone.box, margin));
  };
  const lineOf = new Map();
  const wayLine = (object) => {
    if (!lineOf.has(object.row.source_key)) lineOf.set(object.row.source_key, rawWayLine(rawOsm, object.row.osm_id));
    return lineOf.get(object.row.source_key);
  };
  const roads = objects.filter((object) => object.roles.includes("roads_paths") && object.row.osm_type === "way" && nearPilot(object, 60));
  const vehicles = roads.filter((object) => object.road_visual_class === "vehicle");
  const roadLineAt = lineIndex(vehicles.map(wayLine));
  const nearestRoad = (point) => {
    const best = roadLineAt(point);
    return best && { road: vehicles[best.index], near: best.near };
  };
  const pilotIndex = polygonIndex(pilotRegion);
  const osmCarriageway = union("vehicle roads", vehicles.map((object) => object.geometry));
  // Parking lanes widen the carriageway beyond the frozen ribbon where the
  // photographs show cars parked along the curb and the OSM sidewalks sit that
  // far out; the curb then follows the widened edge.
  const parkingParts = [];
  // A rule street's own widened asphalt and bays (the pilot's lanes stay as built).
  const ruleParkingParts = [];
  const parkingWidth = new Map();
  for (const zone of zoneRegions) {
    for (const lane of zone.settings.parking_lanes) {
      for (const key of lane.source_keys) {
        parkingWidth.set(key, Math.max(parkingWidth.get(key) ?? 0, lane.width_m));
        const road = vehicles.find((object) => object.row.source_key === key);
        invariant(road, `Street ground parking lane road ${key} is not a vehicle road near the pilot`);
        const hw = ROAD_WIDTHS_M[road.tags.highway] / 2;
        parkingParts.push(intersect(`parking lane ${key}`, union(`parking lane ${key}`, [strip(`parking left ${key}`, wayLine(road), hw - CARRIAGEWAY_OVERLAP_M, hw + lane.width_m), strip(`parking right ${key}`, wayLine(road), -hw - lane.width_m, -hw + CARRIAGEWAY_OVERLAP_M)]), zone.region));
      }
    }
  }
  // Rule streets widen the asphalt on each side by what the aerial shows beyond
  // the frozen ribbon (widen), inside their own zone.
  const widenOf = new Map();
  for (const zone of streetZones) {
    for (const key of zone.rule.ways) {
      const widen = zone.rule.widen[key];
      if (!widen) continue;
      const road = vehicles.find((object) => object.row.source_key === key);
      invariant(road, `Street ground widened road ${key} is not a vehicle road`);
      const hw = ROAD_WIDTHS_M[road.tags.highway] / 2;
      const sides = { left: widen.left ?? 0, right: widen.right ?? 0 };
      widenOf.set(key, sides);
      const parts = [];
      if (sides.left > 0) parts.push(strip(`widen left ${key}`, wayLine(road), hw - CARRIAGEWAY_OVERLAP_M, hw + sides.left));
      if (sides.right > 0) parts.push(strip(`widen right ${key}`, wayLine(road), -hw - sides.right, -hw + CARRIAGEWAY_OVERLAP_M));
      if (parts.length > 0) {
        const widened = intersect(`widen ${key}`, union(`widen ${key}`, parts), zone.region);
        parkingParts.push(widened);
        ruleParkingParts.push(widened);
      }
    }
  }
  // The carriageway's half width on one side of a road (sign +1 left of its
  // direction, -1 right): the frozen ribbon, a pilot parking lane, a rule's widening.
  const halfWidthSide = (object, sign) => ROAD_WIDTHS_M[object.tags.highway] / 2 + (parkingWidth.get(object.row.source_key) ?? 0) +
    (widenOf.get(object.row.source_key)?.[sign > 0 ? "left" : "right"] ?? 0);
  // Bays: perpendicular parking bays paved off a rule street's edge, between two
  // along-way distances; the curb runs round them. A bay stops short of any
  // building (BAY_BUILDING_CLEARANCE_M), and a stall reaching that close gets no
  // lines or parked-car slot.
  const bayBuildings = partsIndex("bay buildings", objects
    .filter((object) => object.roles.includes("building") || object.roles.includes("building_part"))
    .map((object) => object.geometry));
  // A bay's or apron's pavement off a rule street's edge, clear of buildings.
  const paveOffEdge = (label, entry) => {
    const road = vehicles.find((object) => object.row.source_key === entry.way);
    invariant(road && ruleOf.has(entry.way), `Street ground ${label} way ${entry.way} is not a rule street's vehicle road`);
    const line = wayLine(road);
    const total = polylineLength(line);
    invariant(entry.from_m >= 0 && entry.to_m <= total + 0.5, `Street ground ${label} on ${entry.way} runs past the way (${roundCoordinate(total)} m)`);
    const sign = entry.side === "left" ? 1 : -1;
    const hw = halfWidthSide(road, sign);
    const along = polylineSlice(line, entry.from_m, Math.min(entry.to_m, total));
    const [from, to] = sign > 0 ? [hw - CARRIAGEWAY_OVERLAP_M, hw + entry.depth_m] : [-hw - entry.depth_m, -hw + CARRIAGEWAY_OVERLAP_M];
    const paved = strip(`${label} ${entry.way} ${entry.from_m}`, along, from, to);
    const near = bayBuildings.near(boxOfMulti(paved), BAY_BUILDING_CLEARANCE_M);
    const part = near.length === 0 ? paved : difference(`${label} ${entry.way} ${entry.from_m} off buildings`, paved,
      near.map((polygon) => union(`${label} building clearance ${entry.way}`, [[polygon], ...polygon.map((ring) => lineBuffer(`${label} building edge ${entry.way}`, [...openRing(ring), ring[0]], BAY_BUILDING_CLEARANCE_M))])));
    parkingParts.push(part);
    ruleParkingParts.push(part);
    return { road, line, sign, hw };
  };
  const bays = (rules?.bays ?? []).map((bay) => ({ bay, ...paveOffEdge("bay", bay) }));
  for (const apron of rules?.aprons ?? []) paveOffEdge("apron", apron);
  const parkingSurface = difference("parking lanes", union("parking lanes", parkingParts), [osmCarriageway]);
  const parkingIndex = polygonIndex(parkingSurface);
  // The blockers and point tests use the parts as built (overlapping the ribbon by
  // CARRIAGEWAY_OVERLAP_M), not the ribbon plus the difference: a hairline crack
  // along the ribbon's edge under a widened side left a curb in the lane (Bruton).
  const vehicleUnion = union("carriageway", [osmCarriageway, ...parkingParts]);
  // The carriageway as its parts (road ribbons and parking lanes) for point,
  // distance and local cuts; vehicleUnion stays for the few whole-island cuts.
  const vehicleIndex = partsIndex("carriageway", [...vehicles.map((object) => object.geometry), ...parkingParts]);
  const vehicleIndexRibbons = partsIndex("road ribbons", vehicles.map((object) => object.geometry));
  const inKerbRegion = (object) => intersect(`kerb test ${object.row.source_key}`, object.geometry, kerbRegion).length > 0;
  const kerbRoads = vehicles.filter((object) => object.tags.service !== "parking_aisle" && inKerbRegion(object));
  // A rule road's curb on one side, as stretches [from_m, to_m, kind] along it:
  // walk (a sidewalk at the curb), verge (a curb top, then grass) or none.
  const sideStretches = (object, sign) => {
    const rule = ruleOf.get(object.row.source_key);
    if (!rule) return [];
    const total = polylineLength(wayLine(object));
    const spec = rule.sides[object.row.source_key]?.[sign > 0 ? "left" : "right"] ?? rule.treatment.sides;
    if (typeof spec === "string") return [[0, total, spec]];
    return spec.map(([from, to, kind]) => [Math.max(0, from), Math.min(total, to), kind]).filter(([from, to]) => to - from > 0.5);
  };
  const sideKindAt = (object, sign, along) => sideStretches(object, sign).find(([from, to]) => along >= from - 1e-6 && along <= to + 1e-6)?.[2] ?? "none";
  const ruleRoads = vehicles.filter((object) => ruleOf.has(object.row.source_key));
  const ruleKerbRoads = ruleRoads.filter((object) => object.tags.service !== "parking_aisle" &&
    [1, -1].some((sign) => sideStretches(object, sign).some(([, , kind]) => kind !== "none")));
  // Every road with a curb: the pilot's kerbed roads, then the rule roads with one.
  const bandRoads = [...kerbRoads, ...ruleKerbRoads.filter((object) => !kerbRoads.includes(object))];
  const sidewalks = roads.filter((object) => object.road_visual_class === "pedestrian" && object.tags.footway === "sidewalk");
  const pedestrianIndex = partsIndex("pedestrian ways", roads.filter((object) => object.road_visual_class === "pedestrian").map((object) => object.geometry));
  const lots = objects.filter((object) => object.roles.includes("major_area") && object.tags.amenity === "parking" && nearPilot(object, 30));
  // The lot OSM lacks stands on its traced outline, over the rounded end of the
  // road it meets: the aerial's joint with the older pavement is straight, so the
  // lot's sheet lies across that end. Its source key is the OSM way it meets, for
  // the records' provenance.
  const exceptionLots = (rules?.lots ?? []).filter((lot) => lot.osm_exception !== undefined).map((lot) => {
    invariant(playableObjects.has(lot.source_key), `Street ground lot ${lot.id} names ${lot.source_key}, which is not an OSM object`);
    const ring = lot.osm_exception.outline_xz.map(([x, z]) => [x, -z]);
    return { lot, object: { geometry: [[ringArea(ring) > 0 ? ring : [...ring].reverse()]] } };
  });
  const exceptionLotIndex = polygonIndex(union("exception lots", exceptionLots.map(({ object }) => object.geometry)));
  const lotUnion = union("parking lots", [...lots, ...exceptionLots.map(({ object }) => object)].map((object) => object.geometry));
  const lotIndex = polygonIndex(lotUnion);
  // The rules' lots, and their raised islands (curbed all round, in the band).
  const lotRules = (rules?.lots ?? []).map((lot) => {
    const exception = exceptionLots.find((entry) => entry.lot === lot);
    if (exception) return exception;
    const object = playableObjects.get(lot.source_key);
    invariant(object && object.tags.amenity === "parking", `Street ground lot ${lot.id} names ${lot.source_key}, which is not an OSM parking area`);
    return { lot, object };
  });
  const islandParts = lotRules.flatMap(({ lot, object }) => lot.islands.map((island) => {
    const ring = island.points_xz.map(([x, z]) => [x, -z]);
    const shape = [[ringArea(ring) > 0 ? [...ring] : [...ring].reverse()]];
    return { lot, line: ring.slice(0, 2), shape: lot.osm_exception ? intersect(`lot ${lot.id} ${island.id}`, shape, object.geometry) : shape };
  }));
  const islandUnion = union("lot islands", islandParts.map(({ shape }) => shape));
  // The curb strips of the lot OSM lacks, each with the edge it follows.
  const lotCurbs = islandParts.filter(({ lot }) => lot.osm_exception !== undefined);
  const lotCurbUnion = union("lot curbs", lotCurbs.map(({ shape }) => shape));
  const lotCurbIndex = polygonIndex(lotCurbUnion);
  const islandIndex = polygonIndex(islandUnion);
  const buildings = objects.filter((object) => (object.roles.includes("building") || object.roles.includes("building_part")) && nearPilot(object, 30));
  const buildingUnion = union("buildings", buildings.map((object) => object.geometry));
  const buildingIndex = polygonIndex(buildingUnion);
  // The traced outline stays on the land and off the buildings.
  for (const { lot, object } of exceptionLots) {
    invariant(difference(`lot ${lot.id} off the land`, object.geometry, [land.geometry]).length === 0, `Street ground lot ${lot.id}'s outline leaves the land`);
    invariant(intersect(`lot ${lot.id} on buildings`, object.geometry, buildingUnion).length === 0, `Street ground lot ${lot.id}'s outline crosses a building`);
  }
  const buildingClearance = union("building clearance", buildings.flatMap((object) => [
    object.geometry,
    ...object.geometry.flatMap((polygon) => polygon.map((ring) => {
      const points = openRing(ring);
      // lineRibbon's strict union rejects a few island-wide rings (a hole of
      // the ribbon crossing itself); those take the lattice buffer instead.
      try {
        return lineRibbon([...points, points[0]], kerb.building_clearance_m * 2, `clearance ${object.row.source_key}`);
      } catch {
        return lineBuffer(`clearance ${object.row.source_key}`, [...points, points[0]], kerb.building_clearance_m);
      }
    })),
  ]));
  const keepoutShapes = hardShapes
    .filter((shape) => ["stair", "door", "approach"].includes(shape.component))
    .filter((shape) => shape.points.some(([x, z]) => zoneRegions.some((zone) => inBox(zone.box, [x, -z], 30))))
    .map((shape) => (shape.points.length === 1
      ? circle([shape.points[0][0], -shape.points[0][1]], shape.radius_m)
      : lineRibbon(shape.points.map(([x, z]) => [x, -z]), shape.radius_m * 2, `keepout ${shape.source_id}`)));
  const hardKeepout = unionOnLattice("stair keepout", keepoutShapes);
  const sameStreet = (left, right) => left === right ||
    (left.tags.name != null && left.tags.name === right.tags.name && left.tags.highway === right.tags.highway);

  // --- Raised band. Flat-ended strips of the default sidewalk width along both
  // sides of every kerbed road, rounded only where ways meet; OSM sidewalks that
  // run alongside within reach join it, with the gap between them filled.
  const kerbSources = new Set(bandRoads.map((object) => object.row.source_key));
  // Half the carriageway, its wider side: the frozen ribbon plus any parking lane or widening.
  const halfWidth = (object) => Math.max(halfWidthSide(object, 1), halfWidthSide(object, -1));
  const nodeUse = new Map();
  for (const object of vehicles) {
    for (const ref of new Set(rawOsm.ways.get(object.row.osm_id).node_refs)) nodeUse.set(ref, (nodeUse.get(ref) ?? 0) + 1);
  }
  const sideStrips = (label, line, inner, outer) => union(label, [strip(`${label} left`, line, inner, outer), strip(`${label} right`, line, -outer, -inner)]);
  const defaultBand = union("default band", kerbRoads.map((object) => {
    const line = wayLine(object);
    const refs = rawOsm.ways.get(object.row.osm_id).node_refs;
    const outer = halfWidth(object) + kerb.sidewalk_width_m;
    const parts = [sideStrips(`band ${object.row.source_key}`, line, halfWidth(object) - 0.05, outer)];
    if ((nodeUse.get(refs[0]) ?? 0) > 1) parts.push(circle(line[0], outer, 24));
    if ((nodeUse.get(refs.at(-1)) ?? 0) > 1) parts.push(circle(line.at(-1), outer, 24));
    return union(`band ${object.row.source_key}`, parts);
  }));
  // Rule roads: each kerbed side's strip, a sidewalk (walk) or a curb and grass
  // (verge) wide, rounded at the way's junctions by half a disc on that side;
  // vergeRegion holds the verge sides, whose tops are grass beyond the curb top.
  const ruleBandParts = [];
  const vergeParts = [];
  for (const object of ruleKerbRoads) {
    const key = object.row.source_key;
    const line = wayLine(object);
    const total = polylineLength(line);
    const refs = rawOsm.ways.get(object.row.osm_id).node_refs;
    const treatment = ruleOf.get(key).treatment;
    const parts = [];
    for (const sign of [1, -1]) {
      const hw = halfWidthSide(object, sign);
      const side = (inner, outer) => (sign > 0 ? [inner, outer] : [-outer, -inner]);
      for (const [from, to, kind] of sideStretches(object, sign)) {
        if (kind === "none") continue;
        const width = kind === "walk" ? treatment.sidewalk_width_m : treatment.verge_width_m;
        const sideParts = [strip(`rule band ${key}`, polylineSlice(line, from, to), ...side(hw - 0.05, hw + width))];
        // A stretch that reaches a junction at the way's end rounds its corner.
        const ends = [[from <= 0.5, refs[0], line[0], unit(sub(line[1], line[0]))], [to >= total - 0.5, refs.at(-1), line.at(-1), unit(sub(line.at(-1), line.at(-2)))]];
        for (const [reaches, ref, point, tangent] of ends) {
          if (!reaches || (nodeUse.get(ref) ?? 0) <= 1) continue;
          const radius = hw + width;
          sideParts.push(intersect(`rule corner ${key}`, circle(point, radius, 24),
            rectangle(point, tangent, leftOf(tangent), -radius - 1, radius + 1, ...side(0, radius + 1))));
        }
        const sideBand = union(`rule side ${key}`, sideParts);
        parts.push(sideBand);
        if (kind === "verge") vergeParts.push(sideBand);
      }
    }
    if (parts.length > 0) ruleBandParts.push(union(`rule band ${key}`, parts.map((part) => onLattice(part))));
  }
  const ruleBand = union("rule band", ruleBandParts.map((part) => onLattice(part)));
  const vergeRegion = union("verge sides", vergeParts.map((part) => onLattice(part)));
  const joinedSidewalks = [];
  const sidewalkParts = [];
  const ruleSidewalkParts = [];
  // Rule walks set back from the curb: the ground between, filled per treatment.
  const ruleFills = { mulch: [], lawn: [] };
  // A planted lot island: mulch inside its curb.
  // A lot's planted strip: mulch on the curb band inside its outline.
  for (const { lot } of lotRules) {
    for (const part of [...lot.islands.filter(({ fill }) => fill === "mulch"), ...(lot.planted ?? [])]) {
      const ring = part.points_xz.map(([x, z]) => [x, -z]);
      ruleFills.mulch.push([[ringArea(ring) > 0 ? ring : ring.reverse()]]);
    }
  }
  const wideGapParts = [];
  const wideGapWalks = [];
  // OSM sidewalks whose walk is photographed at the curb with the bed behind it.
  const behindWalk = new Set(zoneRegions.flatMap((zone) => zone.settings.planting_behind_walk.flatMap((entry) => entry.source_keys)));
  for (const sidewalk of sidewalks) {
    const line = wayLine(sidewalk);
    const total = polylineLength(line);
    const pieces = Math.max(1, Math.ceil(total / 6));
    let joined = false;
    for (let piece = 0; piece < pieces; piece += 1) {
      const a = pointAlong(line, (total * piece) / pieces).point;
      const b = pointAlong(line, (total * (piece + 1)) / pieces).point;
      if (length(sub(b, a)) < 0.2) continue;
      let best = null;
      for (const road of bandRoads) {
        const nearA = closestOnPolyline(wayLine(road), a);
        const nearB = closestOnPolyline(wayLine(road), b);
        const reach = halfWidth(road) + kerb.sidewalk_reach_m + 1;
        if (nearA.distance > reach || nearB.distance > reach) continue;
        // A rule road takes a sidewalk only on a side whose curb has a walk.
        if (!kerbRoads.includes(road) && sideKindAt(road, cross(nearA.tangent, sub(a, nearA.point)) >= 0 ? 1 : -1, nearA.along) !== "walk") continue;
        if (!best || nearA.distance + nearB.distance < best.score) best = { score: nearA.distance + nearB.distance, nearA, nearB, road };
      }
      if (!best || best.nearA.distance < 0.5 || best.nearB.distance < 0.5) continue;
      joined = true;
      const along = unit(sub(b, a));
      const walk = rectangle(a, along, leftOf(along), 0, length(sub(b, a)), -1, 1);
      const outA = add(a, scale(unit(sub(a, best.nearA.point)), 1));
      const outB = add(b, scale(unit(sub(b, best.nearB.point)), 1));
      const hull = convexHull([outA, outB, a, b, best.nearA.point, best.nearB.point]);
      // A pilot road's sidewalk joins the pilot band, a rule road's the rule band
      // (a road in both feeds both; each is cut to its own region).
      const isPilot = kerbRoads.includes(best.road);
      const isRule = ruleOf.has(best.road.row.source_key) && ruleKerbRoads.includes(best.road);
      if (isRule) {
        ruleSidewalkParts.push(walk);
        if (hull.length >= 3) ruleSidewalkParts.push([[hull]]);
        const fill = ruleOf.get(best.road.row.source_key).treatment.fill;
        const ruleGap = (best.nearA.distance + best.nearB.distance) / 2 - halfWidth(best.road) - 1;
        if (fill !== "concrete" && ruleGap >= kerb.planting_gap_m && hull.length >= 3) ruleFills[fill].push(difference(`fill ${sidewalk.row.source_key}`, [[hull]], [walk]));
      }
      if (!isPilot) continue;
      sidewalkParts.push(walk);
      if (hull.length >= 3) sidewalkParts.push([[hull]]);
      // Gap between the curb and the sidewalk's inner edge. Normally the bed
      // fills it and the OSM walk stays concrete; a behind-walk sidewalk keeps
      // the default walk at the curb and the bed takes the gap and its line.
      const gap = (best.nearA.distance + best.nearB.distance) / 2 - halfWidth(best.road) - 1;
      if (gap >= kerb.planting_gap_m && hull.length >= 3 && !behindWalk.has(sidewalk.row.source_key)) {
        wideGapParts.push([[hull]]);
        wideGapWalks.push(walk);
      }
    }
    if (joined) joinedSidewalks.push(sidewalk.row.source_key);
  }
  // Plazas: a concrete walk at the curb, then banded paving, along named roads.
  const plazaParts = [];
  const paverParts = [];
  for (const zone of zoneRegions) {
    for (const plaza of zone.settings.plazas) {
      const sidePoint = [plaza.side_point_xz[0], -plaza.side_point_xz[1]];
      const walks = [];
      const pavers = [];
      for (const key of plaza.source_keys) {
        const road = vehicles.find((object) => object.row.source_key === key);
        invariant(road, `Street ground plaza road ${key} is not a vehicle road near the pilot`);
        const line = wayLine(road);
        const near = closestOnPolyline(line, sidePoint);
        const sign = cross(near.tangent, sub(sidePoint, near.point)) >= 0 ? 1 : -1;
        const hw = halfWidth(road);
        const signed = (from, to) => (sign > 0 ? [from, to] : [-to, -from]);
        walks.push(strip(`plaza walk ${key}`, line, ...signed(hw - 0.05, hw + plaza.walk_m)));
        pavers.push(strip(`plaza paving ${key}`, line, ...signed(hw + plaza.walk_m, hw + plaza.depth_m)));
      }
      // Where the road bends, the end of the paving strip tapers to a spike: open it away.
      const paving = openShapes(`plaza paving ${zone.id}`, intersect(`plaza paving ${zone.id}`, union(`plaza pavers ${zone.id}`, pavers), zone.region), PLAZA_OPENING_M);
      plazaParts.push(union(`plaza ${zone.id}`, [intersect(`plaza walk ${zone.id}`, union(`plaza walks ${zone.id}`, walks), zone.region), paving]));
      paverParts.push({ zone, plaza, region: paving });
    }
  }
  const raisedRaw = union("raised band", [defaultBand, ...sidewalkParts, ...plazaParts]);
  // A parking lot's narrow tips (under 3 m) do not notch the sidewalk.
  const blockers = [vehicleUnion, openShapes("parking lot body", lotUnion, LOT_OPENING_M), buildingClearance, hardKeepout];
  // The pilot's raised ground stays inside its kerbed zones, the rule streets'
  // inside their own zones (outside the pilot's).
  const pilotRaised = intersect("band zone", raisedRaw, kerbRegion);
  const ruleRaised = ruleBand.length === 0 && ruleSidewalkParts.length === 0 ? [] :
    intersect("rule band zone", union("rule raised", [ruleBand, ...ruleSidewalkParts].map((part) => onLattice(part))), ruleRegion);
  const allRaised = ruleRaised.length === 0 ? pilotRaised : union("raised", [pilotRaised, ruleRaised]);
  const bandBase = cleanPolygons(
    difference("band subtraction", closeGaps("band closing", allRaised, kerb.closing_m), blockers),
    1.0,
    kerb.minimum_width_m,
    6.0,
    1.5,
  );
  const bandOriginal = islandUnion.length === 0 ? bandBase : union("band and islands", [bandBase, islandUnion]);
  const bandIndex = polygonIndex(bandOriginal);
  invariant(!bandIndex.contains([spawnXZ[0], -spawnXZ[1]]), "Street ground raises the ferry spawn");
  // Surface materials over the raised band: banded plaza paving, mulch planting
  // (curb_strip zones: between the curb and a sidewalk set back from it, and
  // beyond the default sidewalk where the OSM sidewalk crowds the curb) and
  // concrete everywhere else.
  const paverTop = intersect("plaza paving top", bandOriginal, union("plaza paving", paverParts.map((part) => part.region)));
  const paverIndex = polygonIndex(paverTop);

  // --- Crosswalks: from crossing ways, and crossing nodes that no crossing way carries.
  const marked = (tags) => tags["crossing:markings"] !== "no" && tags.crossing !== "unmarked" &&
    (tags["crossing:markings"] != null || ["marked", "zebra", "traffic_signals", "uncontrolled"].includes(tags.crossing));
  // The rules' paint for a crossing node (read from the dated aerial), or null.
  const ruleCrossing = (ref) => rules?.crossings[`n${ref}`] ?? null;
  const wayCrossing = (object) => rawOsm.ways.get(object.row.osm_id).node_refs.map(ruleCrossing).find((style) => style !== null) ?? null;
  const crossingWays = roads.filter((object) => (object.tags.footway === "crossing" || object.tags.cycleway === "crossing") &&
    (wayCrossing(object) !== null ? wayCrossing(object) !== "none" : marked(object.tags)));
  const carriedNodes = new Set(roads.filter((object) => object.tags.footway === "crossing" || object.tags.cycleway === "crossing")
    .flatMap((object) => rawOsm.ways.get(object.row.osm_id).node_refs));
  const crosswalks = [];
  // A crossing is signalized when its way or one of its nodes says so; street
  // furniture puts signal poles at these.
  const signalTags = (tags) => tags.crossing === "traffic_signals" || tags.highway === "traffic_signals" || tags["crossing:signals"] === "yes";
  const nodeTags = (ref) => properSources.get(`n${ref}`)?.metadata.tags ?? {};
  // A crosswalk's paint and wear: the rules' for its node, else its road's
  // street treatment, else (in the pilot zones) the pilot's continental bars.
  const crosswalkPaint = (center, host, nodeStyle) => {
    const rule = host && !pilotIndex.contains(center) ? ruleOf.get(host.row.source_key) : null;
    const style = nodeStyle ?? (rule ? rule.treatment.crosswalk : "continental");
    return { style, wear: rule ? rule.treatment.paint_wear : (rules?.pilot.crosswalk_paint_wear ?? 0), tactile: rule ? rule.treatment.tactile_pads : true, rule: rule !== null };
  };
  const addCrosswalk = (sourceKey, center, direction, signals = false, paintOf = { style: "continental", wear: 0, tactile: true, rule: false }, host = null, widthM = null) => {
    if (paintOf.style === "none" || zonesAt(center).length === 0) return;
    const start = add(center, scale(direction, -25));
    const end = add(center, scale(direction, 25));
    // The carriageway's own edges near the line (the union's, not its parts').
    const nearRoads = vehicleIndex.local(boxOfPoints([start, end]), 1);
    const fractions = [0, ...segmentPolygonCrossings(start, end, nearRoads), 1];
    let span = null;
    for (let index = 1; index < fractions.length; index += 1) {
      const middle = (fractions[index - 1] + fractions[index]) / 2;
      if (!vehicleIndex.contains(add(start, scale(sub(end, start), middle)))) continue;
      const s0 = fractions[index - 1] * 50 - 25;
      const s1 = fractions[index] * 50 - 25;
      if (s0 <= 0.5 && s1 >= -0.5 && (!span || Math.abs(s0 + s1) < Math.abs(span[0] + span[1]))) span = [s0, s1];
    }
    if (span && paintOf.rule && host) {
      const reach = halfWidth(host) + 1;
      span = [Math.max(span[0], -reach), Math.min(span[1], reach)];
    }
    if (!span || span[1] - span[0] < 2) return;
    if (crosswalks.some((walk) => length(sub(walk.center, center)) < 2.5 && Math.abs(dot(walk.direction, direction)) > 0.9)) return;
    const width = widthM ?? (paintOf.style === "lines" ? LINES_WALK_WIDTH_M : crossings.walk_width_m);
    crosswalks.push({ source_key: sourceKey, center, direction, across: leftOf(direction), span, signals, style: paintOf.style, width_m: width, paint_wear: paintOf.wear, tactile: paintOf.tactile });
  };
  for (const way of crossingWays) {
    const line = wayLine(way);
    const middle = pointAlong(line, polylineLength(line) / 2);
    const chord = sub(line.at(-1), line[0]);
    const refs = rawOsm.ways.get(way.row.osm_id).node_refs;
    const signals = signalTags(way.tags) || refs.some((ref) => signalTags(nodeTags(ref)));
    // One OSM crossing way can run across several roads (9th Street at Avenue H):
    // outside the pilot it gets a crosswalk at each of its crossing nodes on a
    // road, in that node's style, rather than one at its middle.
    const onRoads = pilotIndex.contains(middle.point) ? [] : refs
      .filter((ref) => nodeTags(ref).highway === "crossing" && rawOsm.nodes.get(ref))
      .map((ref) => ({ ref, host: vehicles.find((object) => rawOsm.ways.get(object.row.osm_id).node_refs.includes(ref)) }))
      .filter((entry) => entry.host);
    if (onRoads.length >= 2) {
      for (const { ref, host } of onRoads) {
        const style = ruleCrossing(ref) ?? wayCrossing(way);
        const position = closestOnPolyline(wayLine(host), projectLonLat(rawOsm.nodes.get(ref).coordinate));
        addCrosswalk(way.row.source_key, position.point, leftOf(position.tangent), signals, crosswalkPaint(position.point, host, style), host);
      }
      continue;
    }
    const host = nearestRoad(middle.point)?.road ?? null;
    addCrosswalk(way.row.source_key, middle.point, length(chord) > 1 ? unit(chord) : middle.tangent, signals, crosswalkPaint(middle.point, host, wayCrossing(way)), host);
  }
  for (const [sourceKey, source] of [...properSources.entries()].sort(([left], [right]) => compareSourceKeys(left, right))) {
    if (sourceKey[0] !== "n" || source.metadata.tags.highway !== "crossing" || carriedNodes.has(sourceKey.slice(1))) continue;
    const nodeStyle = ruleCrossing(sourceKey.slice(1));
    if (nodeStyle === null ? !marked(source.metadata.tags) : nodeStyle === "none") continue;
    const node = rawOsm.nodes.get(sourceKey.slice(1));
    const host = node ? vehicles.find((object) => rawOsm.ways.get(object.row.osm_id).node_refs.includes(sourceKey.slice(1))) : null;
    if (!host) continue;
    const position = closestOnPolyline(wayLine(host), projectLonLat(node.coordinate));
    addCrosswalk(host.row.source_key, position.point, leftOf(position.tangent), signalTags(source.metadata.tags), crosswalkPaint(position.point, host, nodeStyle), host);
  }
  for (const walk of rules?.crosswalks ?? []) {
    const host = vehicles.find((object) => object.row.source_key === walk.way);
    invariant(host && ruleOf.has(walk.way), `Street ground crosswalk way ${walk.way} is not a rule street's vehicle road`);
    invariant(walk.at_m <= polylineLength(wayLine(host)), `Street ground crosswalk on ${walk.way} lies past the way's end`);
    const at = pointAlong(wayLine(host), walk.at_m);
    const before = crosswalks.length;
    addCrosswalk(walk.way, at.point, leftOf(at.tangent), false, crosswalkPaint(at.point, host, walk.style), host, walk.width_m ?? null);
    invariant(crosswalks.length > before, `Street ground crosswalk on ${walk.way} at ${walk.at_m} m found no carriageway to cross`);
  }
  crosswalks.sort((left, right) => left.center[0] - right.center[0] || left.center[1] - right.center[1]);
  const crosswalkKeepout = union("crosswalk keepout", crosswalks.map((walk) =>
    rectangle(walk.center, walk.direction, walk.across, walk.span[0] - 1, walk.span[1] + 1, -walk.width_m / 2 - 0.5, walk.width_m / 2 + 0.5)));
  const keepoutIndex = polygonIndex(crosswalkKeepout);

  // Curb ramps where a crosswalk lands on the raised band.
  const notches = [];
  for (const walk of crosswalks) {
    for (const [sign, s] of [[-1, walk.span[0]], [1, walk.span[1]]]) {
      const outward = scale(walk.direction, sign);
      const landing = add(walk.center, scale(walk.direction, s));
      if (!bandIndex.contains(add(landing, scale(outward, 0.4)))) continue;
      const rect = rectangle(landing, outward, walk.across, -0.05, crossings.ramp_depth_m, -crossings.ramp_width_m / 2, crossings.ramp_width_m / 2);
      const piece = intersect("curb ramp", rect, bandIndex.near(boxOfMulti(rect), 1));
      if (multiArea(piece) < 0.5) continue;
      const rise = top - (ROAD_TOP_M + crossings.ramp_foot_m);
      const height = {
        h0: ROAD_TOP_M + crossings.ramp_foot_m - (rise / crossings.ramp_depth_m) * dot(landing, outward),
        he: (rise / crossings.ramp_depth_m) * outward[0],
        hn: (rise / crossings.ramp_depth_m) * outward[1],
      };
      notches.push({ source_key: walk.source_key, landing, outward, across: walk.across, rect, piece, box: boxOfMulti(piece), height, tactile: walk.tactile });
    }
  }
  const notchUnion = union("curb ramp notches", notches.map((notch) => notch.rect));
  const notchIndex = polygonIndex(union("curb ramps", notches.map((notch) => notch.piece)));
  // Mulch beds stay clear of a crosswalk's landing: a ramp tops out on concrete.
  const landings = notches.map((notch) => rectangle(notch.landing, notch.outward, notch.across,
    crossings.ramp_depth_m - 0.05, crossings.ramp_depth_m + RAMP_LANDING_M, -crossings.ramp_width_m / 2, crossings.ramp_width_m / 2));
  const curbStripRegion = union("curb-strip zones", zoneRegions.filter((zone) => zone.settings.planting === "curb_strip").map((zone) => zone.region));
  const concreteKeep = union("concrete keep", [difference("default band beside set-back walks", defaultBand, wideGapParts), ...wideGapWalks, ...plazaParts, ...landings]);
  const pilotPlanted = intersect("planting", difference("planting candidates", bandOriginal, [concreteKeep, paverTop]), curbStripRegion);
  // A rule street's mulch fill between the curb and a set-back walk.
  const ruleMulch = ruleFills.mulch.length === 0 ? [] :
    difference("rule mulch", intersect("rule mulch band", bandOriginal, union("rule mulch fills", ruleFills.mulch)), [paverTop, ...landings]);
  const plantedTop = cleanPolygons(ruleMulch.length === 0 ? pilotPlanted : union("planted", [pilotPlanted, ruleMulch]), 1.0, 0.6);
  const plantedIndex = polygonIndex(plantedTop);
  const bandRaised = cleanPolygons(difference("band minus ramps", bandOriginal, [notchUnion]), 0.3, 0.2);
  const raisedIndex = polygonIndex(bandRaised);
  // Grass tops: a verge side's band beyond a concrete curb top CURB_TOP_M deep
  // along the carriageway, and a rule street's lawn fill behind a set-back walk.
  let lawnTop = [];
  if (vergeRegion.length > 0 || ruleFills.lawn.length > 0) {
    const grassRegion = union("grass regions", [vergeRegion, ...ruleFills.lawn]);
    const grassIndex = polygonIndex(grassRegion);
    const curbTops = [];
    for (const polygon of bandRaised) {
      if (grassIndex.near(boxOfPoints(polygon[0]), 1).length === 0) continue;
      polygon.forEach((raw, ringIndex) => {
        let ring = openRing(raw);
        if (ring.length < 3) return;
        if ((ringIndex === 0) !== (ringArea(ring) > 0)) ring = ring.reverse();
        ring.forEach((a, at) => {
          const b = ring[(at + 1) % ring.length];
          if (length(sub(b, a)) < 1e-6) return;
          const direction = unit(sub(b, a));
          const outward = [direction[1], -direction[0]];
          const faced = add(add(a, scale(sub(b, a), 0.5)), scale(outward, 0.04));
          if (!vehicleIndex.contains(faced) && !exceptionLotIndex.contains(faced)) return;
          // Inward from the curb edge, a little past its ends so corners close.
          curbTops.push(rectangle(a, direction, scale(outward, -1), -CURB_TOP_M, length(sub(b, a)) + CURB_TOP_M, -0.01, CURB_TOP_M));
        });
      });
    }
    lawnTop = cleanPolygons(difference("grass tops", intersect("grass candidates", bandRaised, grassRegion),
      [union("curb tops", curbTops), plantedTop, paverTop, ...landings]), 0.3, 0.3);
  }

  const counts = { crosswalks: crosswalks.length, curb_ramps: notches.length, centerline_m: 0, stop_bars: 0, stall_lines: 0, bays: 0, shoulder_stalls: 0, lot_stalls: 0, red_curb_m: 0, skirt_split_fallbacks: 0, wear: {} };
  const pieces = [];
  const faces = [];
  const sources = {
    kerb: new Set(kerbSources),
    lot_curb: new Set(),
    planting: new Set(kerbSources),
    plaza: new Set(paverParts.flatMap((part) => part.plaza.source_keys)),
    parking: new Set(zoneRegions.flatMap((zone) => zone.settings.parking_lanes.flatMap((lane) => lane.source_keys))),
    verge: new Set(kerbSources),
    ramp: new Set(kerbSources),
    gutter: new Set(kerbSources),
    wear: new Set(),
    marking: new Set(),
    ...Object.fromEntries(Object.keys(PARK_SURFACE_MATERIALS).map((material) => [material, new Set()])),
  };
  for (const key of joinedSidewalks) {
    sources.kerb.add(key);
    sources.planting.add(key);
  }
  const addPiece = (record, polygon, height, uv, smooth = false) => {
    if (polygon.length > 0) pieces.push({ record, polygon, height, uv, smooth });
  };

  // Raised tops take their panel or paver frame from a kerbed road. Each road
  // owns the band within reach of it, the more important (then longer) road
  // first, so a side street's panels meet the main sidewalk along its back edge,
  // as poured, rather than on an arbitrary seam. Owned parts are cut on an 8 m
  // grid so the frame follows curves; parts no road reaches take the nearest
  // road's frame. Ramp floors use their crossing's frame.
  const kerbLineAt = lineIndex(bandRoads.map(wayLine));
  const nearestKerbLine = (point) => wayLine(bandRoads[kerbLineAt(point).index]);
  const rankOf = (road) => {
    const rank = FRAME_ROAD_RANK.indexOf(road.tags.highway);
    return rank < 0 ? FRAME_ROAD_RANK.length : rank;
  };
  const frameOwners = [...bandRoads].sort((left, right) => rankOf(left) - rankOf(right) ||
    polylineLength(wayLine(right)) - polylineLength(wayLine(left)) ||
    compareSourceKeys(left.row.source_key, right.row.source_key));
  // Each owner's reach (whole) and the part no earlier owner's reach covers (region).
  const frameRegions = [];
  for (const road of frameOwners) {
    const reach = halfWidth(road) + kerb.sidewalk_reach_m + 1;
    const whole = strip(`frame ${road.row.source_key}`, wayLine(road), -reach, reach);
    const box = boxOfMulti(whole);
    const earlier = frameRegions.filter((other) => boxesOverlap(other.box, box)).map((other) => other.whole);
    frameRegions.push({ line: wayLine(road), whole, box, region: difference(`frame owned ${road.row.source_key}`, whole, earlier) });
  }
  const addFramed = (record, polygon, size) => {
    if (polygon.length === 0) return;
    const addCells = (part, line) => {
      if (part.length === 0) return;
      const box = boxOfMulti(part);
      const occupied = occupiedCells(part, 8);
      for (const cell of gridCells(box, 8)) {
        if (!occupied(cell)) continue;
        const piece = intersect(`${record} cell`, part, cell);
        if (multiArea(piece) < 1e-6) continue;
        const pieceBox = boxOfMulti(piece);
        const centre = [(pieceBox.min_x + pieceBox.max_x) / 2, (pieceBox.min_y + pieceBox.max_y) / 2];
        addPiece(record, piece, constantHeight(top), roadFrameUv(line ?? nearestKerbLine(centre), centre, size));
      }
    };
    const parts = polygonIndex(polygon);
    for (const owner of frameRegions) {
      const near = parts.near(owner.box);
      if (near.length > 0) addCells(intersect(`${record} owned`, near, owner.region), owner.line);
    }
    // What no owner reaches: each part less the reaches near it.
    addCells(polygon.flatMap((part) => {
      const box = boxOfPoints(part[0]);
      return difference(`${record} unowned`, [part], frameRegions.filter((owner) => boxesOverlap(owner.box, box)).map((owner) => owner.whole));
    }), null);
  };
  addFramed("kerb", difference("concrete tops", bandRaised, [plantedTop, paverTop, lawnTop, lotCurbUnion]), kerb.panel_m);
  // The lot curbs' tops, each strip in panels along its own edge.
  let curbTopsSoFar = [];
  for (const { lot, line, shape } of lotCurbs) {
    const curbTop = difference("lot curb top", intersect("lot curb raised", bandRaised, shape), [curbTopsSoFar]);
    addPiece("lot_curb", curbTop, constantHeight(top), roadFrameUv(line, line[0], kerb.panel_m));
    sources.lot_curb.add(lot.source_key);
    curbTopsSoFar = union("lot curb tops", [curbTopsSoFar, curbTop]);
  }
  // A parking lane meets the road base at its height, so it is drawn clear of
  // the paths that cross it too (their pavement and pedestrian skin draw there);
  // each piece is cut against the paths near it only.
  addPiece("parking", parkingSurface.flatMap((part) => difference("parking lanes off paths", [part], pedestrianIndex.near(boxOfPoints(part[0])))),
    constantHeight(ROAD_TOP_M), worldUv);
  addPiece("planting", intersect("planted tops", bandRaised, plantedTop), constantHeight(top), tiledUv(2));
  // A lot's planted strip is the parks' dark bark mulch, just over the band's top.
  for (const { lot } of lotRules) {
    if (!lot.planted) continue;
    const outlines = lot.planted.map((strip) => {
      const ring = strip.points_xz.map(([x, z]) => [x, -z]);
      return [[ringArea(ring) > 0 ? ring : ring.reverse()]];
    });
    addPiece("park_mulch", intersect(`lot ${lot.id} strip`, intersect("planted tops", bandRaised, plantedTop), union(`lot ${lot.id} strips`, outlines)),
      constantHeight(top + LOT_STRIP_LIFT_M), worldUv, true);
    sources.park_mulch.add(lot.source_key);
  }
  addPiece("verge", lawnTop, constantHeight(top), worldUv);
  for (const part of paverParts) addFramed("plaza", intersect("plaza tops", bandRaised, part.region), part.plaza.paver_tile_m);
  for (const notch of notches) {
    addPiece("kerb", notch.piece, notch.height, (point) => [
      dot(sub(point, notch.landing), notch.across) / kerb.panel_m,
      dot(sub(point, notch.landing), notch.outward) / kerb.panel_m,
    ]);
    sources.kerb.add(notch.source_key);
  }

  // Skirts: walkable slopes around every raised edge. In front of a curb face
  // they are invisible collision ramps; behind a sidewalk they are visible slopes;
  // inside a curb ramp they are its flared sides.
  const skirtPieces = [];
  const edgeLoops = (multi, heightOf, classify) => {
    for (const polygon of multi) {
      polygon.forEach((raw, ringIndex) => {
        let ring = openRing(raw);
        if (ring.length < 3) return;
        const area = ringArea(ring);
        if ((ringIndex === 0) !== (area > 0)) ring = ring.reverse();
        const edges = [];
        for (let index = 0; index < ring.length; index += 1) {
          const a = ring[index];
          const b = ring[(index + 1) % ring.length];
          const direction = unit(sub(b, a));
          const outward = [direction[1], -direction[0]];
          const kind = classify(a, b, outward);
          edges.push({ a, b, outward, kind, ha: heightOf(a), hb: heightOf(b) });
        }
        emitSkirts(edges);
      });
    }
  };
  // lot_curb is an edge along the lot OSM lacks: a curb face, with no gutter or drain
  // and with its ramp on the lot, invisible like an island's.
  const runOf = { curb: kerb.support_run_m, island: kerb.support_run_m, lot_curb: kerb.support_run_m, flare: kerb.flare_run_m, back: kerb.back_slope_run_m, inner: 0 };
  const footOf = { curb: 0, island: 0, lot_curb: 0, flare: SKIRT_FOOT_M, back: SKIRT_FOOT_M, inner: 0 };
  const classifyRaised = (a, b, outward) => {
    // A lot island's edge is a curb face all round, over the lot.
    if (islandUnion.length > 0 && islandIndex.contains(add(add(a, scale(sub(b, a), 0.5)), scale(outward, -0.04)))) return "island";
    let curb = 0;
    let lotCurb = 0;
    let flare = 0;
    for (const fraction of [0.25, 0.5, 0.75]) {
      const probe = add(add(a, scale(sub(b, a), fraction)), scale(outward, 0.04));
      if (vehicleIndex.contains(probe)) curb += 1;
      else if (exceptionLotIndex.contains(probe)) lotCurb += 1;
      else if (notchIndex.contains(probe)) flare += 1;
    }
    return curb >= 2 ? "curb" : curb + lotCurb >= 2 ? "lot_curb" : flare >= 2 ? "flare" : "back";
  };
  const classifyRamp = (a, b, outward) => {
    let curb = 0;
    let lotCurb = 0;
    let inner = 0;
    for (const fraction of [0.25, 0.5, 0.75]) {
      const probe = add(add(a, scale(sub(b, a), fraction)), scale(outward, 0.04));
      if (vehicleIndex.contains(probe)) curb += 1;
      else if (exceptionLotIndex.contains(probe)) lotCurb += 1;
      else if (raisedIndex.contains(probe)) inner += 1;
    }
    return curb >= 2 ? "curb" : curb + lotCurb >= 2 ? "lot_curb" : inner >= 2 ? "inner" : "back";
  };
  function emitSkirts(edges) {
    for (let index = 0; index < edges.length; index += 1) {
      const edge = edges[index];
      const run = runOf[edge.kind];
      if (run <= 0) continue;
      const foot = footOf[edge.kind];
      const aOut = add(edge.a, scale(edge.outward, run));
      const bOut = add(edge.b, scale(edge.outward, run));
      skirtPieces.push({ kind: edge.kind, points: [edge.a, edge.b, bOut], heights: [edge.ha, edge.hb, foot], edge });
      skirtPieces.push({ kind: edge.kind, points: [edge.a, bOut, aOut], heights: [edge.ha, foot, foot], edge });
      if (edge.kind === "curb" || edge.kind === "island" || edge.kind === "lot_curb") faces.push(edge);
      // Round the corner to the next edge when the outline turns convex.
      const next = edges[(index + 1) % edges.length];
      const nextRun = runOf[next.kind];
      if (nextRun <= 0 || cross(sub(edge.b, edge.a), sub(next.b, next.a)) <= 1e-9) continue;
      const start = Math.atan2(edge.outward[1], edge.outward[0]);
      let sweep = Math.atan2(next.outward[1], next.outward[0]) - start;
      while (sweep <= 0) sweep += 2 * Math.PI;
      if (sweep >= Math.PI) continue;
      const steps = Math.max(1, Math.ceil(sweep / (Math.PI / 8)));
      const kind = edge.kind === next.kind ? edge.kind : edge.kind === "curb" || next.kind === "curb" ? "curb" : edge.kind;
      for (let step = 0; step < steps; step += 1) {
        const point = (k) => {
          const angle = start + (sweep * k) / steps;
          const r = run + (nextRun - run) * (k / steps);
          return add(edge.b, [Math.cos(angle) * r, Math.sin(angle) * r]);
        };
        skirtPieces.push({ kind, points: [edge.b, point(step), point(step + 1)], heights: [edge.hb, footOf[kind], footOf[kind]], edge });
      }
    }
  }
  edgeLoops(bandRaised, () => top, classifyRaised);
  const interiorCurbs = faces.filter((edge) => edge.kind === "curb" && length(sub(edge.b, edge.a)) > INTERIOR_CURB_MIN_M &&
    vehicleIndex.contains(add(add(edge.a, scale(sub(edge.b, edge.a), 0.5)), scale(edge.outward, -0.05))));
  invariant(interiorCurbs.length === 0, `Street ground curbs inside the carriageway (road on both sides): ${interiorCurbs.slice(0, 5)
    .map((edge) => `(${roundCoordinate(edge.a[0])}, ${roundCoordinate(-edge.a[1])})`).join(", ")}${interiorCurbs.length > 5 ? ` and ${interiorCurbs.length - 5} more` : ""}`);
  for (const notch of notches) edgeLoops(notch.piece, (point) => heightAt(notch.height, point), classifyRamp);

  // Split each skirt triangle into its road part (invisible collision ramp) and
  // its open-ground part (visible slope, paved or planted by what lies there).
  for (const skirt of skirtPieces) {
    const triangle = [[skirt.points]];
    if (Math.abs(ringArea(skirt.points)) < 1e-6) continue;
    const height = affineHeight(skirt.points, skirt.heights);
    // A lot island's ramps lie on the lot, like those of an edge along the lot OSM
    // lacks: invisible support all round.
    if (skirt.kind === "island" || skirt.kind === "lot_curb") {
      addPiece("ramp", triangle, height, worldUv);
      continue;
    }
    const box = boxOfPoints(skirt.points);
    const roadParts = vehicleIndex.local(box, 0.01);
    const inRoad = skirt.points.every((point) => vehicleIndex.contains(point));
    let support;
    let open;
    try {
      support = roadParts.length === 0 ? [] : inRoad ? triangle : intersect("skirt road part", triangle, roadParts);
      open = roadParts.length === 0 ? triangle : inRoad ? [] : difference("skirt open part", triangle, roadParts);
    } catch (error) {
      if (!(error instanceof BooleanFailure)) throw error;
      // polygon-clipping could not split this triangle on any lattice: it goes
      // whole to the side its centroid lies on (counted in the summary).
      const centroid = scale(add(add(skirt.points[0], skirt.points[1]), skirt.points[2]), 1 / 3);
      const onRoad = vehicleIndex.contains(centroid);
      support = onRoad ? triangle : [];
      open = onRoad ? [] : triangle;
      counts.skirt_split_fallbacks += 1;
    }
    addPiece("ramp", support, height, worldUv);
    const visible = difference("skirt beside buildings", open, buildingIndex.near(box, 0.01));
    if (visible.length === 0) continue;
    // The slope takes the raised top it falls from: a mulch bed's own edge, else
    // concrete where it runs down onto paving and grass where it meets ground.
    const middle = add(skirt.edge.a, scale(sub(skirt.edge.b, skirt.edge.a), 0.5));
    const probe = add(middle, scale(skirt.edge.outward, runOf[skirt.kind] * 0.7));
    const inner = add(middle, scale(skirt.edge.outward, -0.05));
    const planted = skirt.kind === "back" && plantedIndex.contains(inner);
    const paved = skirt.kind === "flare" || skirt.kind === "curb" || notchIndex.contains(probe) || pedestrianIndex.contains(probe) || lotIndex.contains(probe) || vehicleIndex.contains(probe);
    if (planted) addPiece("planting", visible, height, tiledUv(2));
    else if (paved) addPiece("kerb", visible, height, roadFrameUv(nearestKerbLine(middle), middle, kerb.panel_m));
    else addPiece("verge", visible, height, worldUv);
  }

  // Gutter pans along curb faces, on the road.
  const gutterSkirts = [];
  for (const edge of faces.filter((face) => face.kind === "curb")) {
    const aOut = add(edge.a, scale(edge.outward, kerb.gutter_width_m));
    const bOut = add(edge.b, scale(edge.outward, kerb.gutter_width_m));
    const ring = [edge.a, edge.b, bOut, aOut];
    gutterSkirts.push([[ringArea(ring) > 0 ? ring : ring.reverse()]]);
  }
  const gutters = intersect("gutters", union("gutter strips", gutterSkirts), vehicleUnion);
  addPiece("gutter", gutters, constantHeight(ROAD_TOP_M + lifts.gutter_m), worldUv);
  // Where a rule street's widening or bays pave over an OSM path (a footway that
  // ended at the old ribbon's edge, a crossing path), asphalt covers the path's
  // pale skin a step over it, beside the gutters at their height (Cravath).
  const gutterIndex = partsIndex("gutters", [gutters]);
  const pathCover = ruleParkingParts.flatMap((part) => part.flatMap((polygon) => {
    const box = boxOfPoints(polygon[0]);
    const paths = pedestrianIndex.local(box, 0.1);
    if (paths.length === 0) return [];
    const onWidening = intersect("path cover", [polygon], paths);
    const ribbons = vehicleIndexRibbons.local(box, 0.1);
    const covered = ribbons.length === 0 ? onWidening : difference("path cover off the ribbon", onWidening, [ribbons]);
    const nearGutters = gutterIndex.local(box, 0.1);
    return nearGutters.length === 0 ? covered : difference("path cover off gutters", covered, nearGutters);
  }));
  addPiece("parking", cleanPolygons(union("path covers", pathCover), 0.05, 0.05), constantHeight(ROAD_TOP_M + lifts.gutter_m), worldUv);

  // Red curb paint (fire lanes): the stretches of a rule street's curb its rule
  // gives from dated photographs: the curb face (painted below, with the faces)
  // and a strip of the curb top.
  const paintedStretches = new Set();
  for (const edge of faces) {
    if (edge.kind !== "curb") continue;
    const middle = scale(add(edge.a, edge.b), 0.5);
    if (pilotIndex.contains(middle) || bandRoads.length === 0) continue;
    const owner = bandRoads[kerbLineAt(middle).index];
    const rule = ruleOf.get(owner.row.source_key);
    if (!rule) continue;
    const line = wayLine(owner);
    const near = closestOnPolyline(line, middle);
    const stretches = rule.redCurb[owner.row.source_key]?.[cross(near.tangent, sub(middle, near.point)) >= 0 ? "left" : "right"] ?? [];
    // The parts of the edge inside a stretch, as fractions along it (one straight
    // curb edge can run on past a stretch's end).
    const [fromAlong, toAlong] = [closestOnPolyline(line, edge.a).along, closestOnPolyline(line, edge.b).along];
    const spans = stretches.flatMap((stretch) => {
      const [from, to] = stretch;
      const ends = Math.abs(toAlong - fromAlong) < 1e-6 ? (near.along >= from && near.along <= to ? [0, 1] : [0, 0]) :
        [(from - fromAlong) / (toAlong - fromAlong), (to - fromAlong) / (toAlong - fromAlong)];
      const [start, end] = [Math.max(0, Math.min(...ends)), Math.min(1, Math.max(...ends))];
      if (end <= start) return [];
      paintedStretches.add(stretch);
      return [[start, end]];
    });
    if (spans.length === 0) continue;
    edge.red = { wear: rule.treatment.paint_wear, spans };
    const along = sub(edge.b, edge.a);
    for (const [start, end] of spans) {
      const topStrip = rectangle(edge.a, unit(along), scale(edge.outward, -1), start * length(along), end * length(along), 0, RED_CURB_TOP_M);
      addPiece("marking", intersect("red curb top", topStrip, raisedIndex.near(boxOfMulti(topStrip), 0.1)), constantHeight(top + lifts.paint_m),
        kindUv(STREET_PAINT_KINDS.red_curb, edge.red.wear));
    }
    sources.marking.add(owner.row.source_key);
  }
  // Each stretch is photo evidence: one past its way's end, or that finds no curb
  // to paint, is a mistake in the rules, so it fails rather than vanishing.
  for (const street of rules?.streets ?? []) {
    for (const [way, sides] of Object.entries(street.redCurb)) {
      const road = ruleRoads.find((object) => object.row.source_key === way);
      invariant(road, `Street ground red curb way ${way} is not a rule street's vehicle road`);
      for (const [side, stretches] of Object.entries(sides)) {
        for (const stretch of stretches) {
          invariant(stretch[0] >= 0 && stretch[1] <= polylineLength(wayLine(road)) + 0.5, `Street ground red curb ${way} ${side} ${stretch.join("-")} m runs past the way`);
          invariant(paintedStretches.has(stretch), `Street ground red curb ${way} ${side} ${stretch.join("-")} m finds no curb to paint`);
        }
      }
    }
  }

  // ---------------------------------------------------------------- markings
  // Paint stays on the carriageway inside the given zones: cut against those
  // zones and the roads near it only.
  const paintClip = (label, polygon, zones) => {
    if (polygon.length === 0) return [];
    const box = boxOfMulti(polygon);
    const zonesNear = zones.filter((zone) => boxesOverlap(zone.box, box)).map((zone) => zone.region);
    if (zonesNear.length === 0) return [];
    return intersect(`${label} on road`, intersect(`${label} in zone`, polygon, union(`${label} zones`, zonesNear)), vehicleIndex.local(box));
  };
  const roadPaint = (label, polygon) => paintClip(label, polygon, zoneRegions);
  const pilotZones = zoneRegions.filter((zone) => !zone.rule);
  const paint = (kind, polygon, sourceKey, wear = 0) => {
    if (polygon.length === 0) return;
    addPiece("marking", polygon, constantHeight(ROAD_TOP_M + lifts.paint_m), kindUv(kind, wear));
    sources.marking.add(sourceKey);
  };

  // Painted stop bars, for the stop signs beside them.
  const stopBars = [];

  // Crosswalks: continental bars parallel to traffic, two transverse lines along
  // the walk's edges (lines), or both (ladder).
  for (const walk of crosswalks) {
    const parts = [];
    const half = walk.width_m / 2;
    if (walk.style === "lines" || walk.style === "ladder") {
      parts.push(rectangle(walk.center, walk.direction, walk.across, walk.span[0], walk.span[1], half - TRANSVERSE_LINE_M, half));
      parts.push(rectangle(walk.center, walk.direction, walk.across, walk.span[0], walk.span[1], -half, -half + TRANSVERSE_LINE_M));
    }
    if (walk.style === "continental" || walk.style === "ladder") {
      const reach = walk.style === "ladder" ? half - TRANSVERSE_LINE_M - crossings.bar_gap_m / 2 : half;
      const pitch = crossings.bar_width_m + crossings.bar_gap_m;
      const count = Math.floor((walk.span[1] - walk.span[0] + crossings.bar_gap_m) / pitch);
      const start = (walk.span[0] + walk.span[1]) / 2 - (count * pitch - crossings.bar_gap_m) / 2;
      for (let bar = 0; bar < count; bar += 1) {
        const s = start + bar * pitch;
        parts.push(rectangle(walk.center, walk.direction, walk.across, s, s + crossings.bar_width_m, -reach, reach));
      }
    }
    paint(STREET_PAINT_KINDS.white, roadPaint("crosswalk", union("crosswalk paint", parts)), walk.source_key, walk.paint_wear);
  }

  // Tactile pads at the foot of a curb ramp where the street's photographs show them.
  for (const notch of notches) {
    if (!notch.tactile) continue;
    const core = crossings.ramp_width_m / 2 - kerb.flare_run_m - 0.05;
    const pad = intersect("tactile pad", rectangle(notch.landing, notch.outward, notch.across, 0.15, 0.15 + crossings.tactile_depth_m, -core, core), notch.piece);
    if (pad.length === 0) continue;
    addPiece("marking", pad, { ...notch.height, h0: notch.height.h0 + lifts.paint_m }, kindUv(STREET_PAINT_KINDS.tactile));
    sources.marking.add(notch.source_key);
  }

  // Lines along roads: centre lines, bus and bike lanes, edge lines.
  for (const road of kerbRoads) {
    const roadBox = boxOfMulti(road.geometry);
    const roadZones = pilotZones.filter((zone) => boxesOverlap(zone.box, roadBox) && intersect(`road zone ${road.row.source_key}`, road.geometry, zone.region).length > 0);
    const line = wayLine(road);
    const half = ROAD_WIDTHS_M[road.tags.highway] / 2;
    // Other streets' carriageways where they cross this one (only those near it can).
    const others = vehicles.filter((other) => !sameStreet(other, road) && boxesOverlap(boxOfMulti(other.geometry), roadBox)).map((other) => other.geometry);
    const junctions = union(`junctions ${road.row.source_key}`, others);
    const clip = (label, polygon) => difference(label, intersect(`${label} own road`, paintClip(label, polygon, pilotZones), road.geometry), [junctions, crosswalkKeepout]);
    const zoneWants = (key) => roadZones.some((zone) => zone.settings[key]);
    const centerlineStyle = road.tags.oneway === "yes" ? null : (roadZones.map((zone) => zone.settings.centerlines[road.tags.highway]).find(Boolean) ?? null);
    const centerline = centerlineStyle === "double_yellow";
    const sideLanes = { left: null, right: null };
    if (zoneWants("lane_markings")) {
      const busSide = (value) => typeof value === "string" && value.split("|").includes("designated");
      if (busSide(road.tags["bus:lanes:backward"])) sideLanes.left = "bus";
      if (busSide(road.tags["bus:lanes:forward"])) sideLanes.right = "bus";
      const bike = (value) => value === "lane";
      if (bike(road.tags["cycleway:right"]) || bike(road.tags["cycleway:both"]) || bike(road.tags.cycleway)) sideLanes.right ??= "bike";
      if (bike(road.tags["cycleway:left"]) || bike(road.tags["cycleway:both"]) || (bike(road.tags.cycleway) && road.tags.oneway !== "yes")) sideLanes.left ??= "bike";
    }
    if (centerline) {
      const lineHalf = lines.double_gap_m / 2;
      const yellow = union("centre line", [strip("centre line left", line, lineHalf, lineHalf + lines.width_m), strip("centre line right", line, -lineHalf - lines.width_m, -lineHalf)]);
      const clipped = clip("centre line", yellow);
      paint(STREET_PAINT_KINDS.yellow, clipped, road.row.source_key);
      counts.centerline_m += multiArea(clipped) / (2 * lines.width_m);
    } else if (centerlineStyle === "dashed_faded") {
      // A worn single dashed line, as photographed on the Avenue of the Palms.
      const dashes = [];
      const total = polylineLength(line);
      for (let s = lines.dash_gap_m / 2; s + lines.dash_m <= total; s += lines.dash_m + lines.dash_gap_m) {
        const at = pointAlong(line, s + lines.dash_m / 2);
        dashes.push(rectangle(at.point, at.tangent, leftOf(at.tangent), -lines.dash_m / 2, lines.dash_m / 2, -lines.width_m / 2, lines.width_m / 2));
      }
      const clipped = clip("dashed centre line", union("dashed centre line", dashes));
      paint(STREET_PAINT_KINDS.yellow_faded, clipped, road.row.source_key);
      counts.centerline_m += multiArea(clipped) / lines.width_m;
    }
    for (const [side, sign] of [["left", 1], ["right", -1]]) {
      const lane = sideLanes[side];
      const signed = (from, to) => (sign > 0 ? [from, to] : [-to, -from]);
      if (lane === "bus" || lane === "bike") {
        const width = lane === "bus" ? lines.bus_lane_width_m : lines.bike_lane_width_m;
        const inner = half - width;
        const [lineFrom, lineTo] = signed(inner - lines.width_m, inner);
        paint(STREET_PAINT_KINDS.white, clip(`${lane} lane line`, strip(`${lane} lane line`, line, lineFrom, lineTo)), road.row.source_key);
        const [laneFrom, laneTo] = signed(inner + 0.05, half - 0.05);
        const laneStrip = strip(`${lane} lane`, line, laneFrom, laneTo);
        if (lane === "bus") {
          paint(STREET_PAINT_KINDS.red, clip("bus lane", laneStrip), road.row.source_key);
        } else {
          // Green only in the conflict zones next to crossings, as photographed.
          const conflict = union("bike conflict zones", crosswalks.map((walk) =>
            rectangle(walk.center, walk.direction, walk.across, walk.span[0] - 1, walk.span[1] + 1, -crossings.walk_width_m / 2 - lines.conflict_length_m, crossings.walk_width_m / 2 + lines.conflict_length_m)));
          paint(STREET_PAINT_KINDS.green, clip("bike conflict", intersect("bike conflict lane", laneStrip, conflict)), road.row.source_key);
        }
      } else if (centerline) {
        const [from, to] = signed(half - lines.edge_inset_m - lines.width_m, half - lines.edge_inset_m);
        paint(STREET_PAINT_KINDS.white, clip("edge line", strip("edge line", line, from, to)), road.row.source_key);
      }
    }
  }

  // Rule streets: the treatment's centre line and edge lines on each road's own
  // carriageway inside its street's zone, at the treatment's paint wear.
  const streetZoneOf = new Map(streetZones.map((zone) => [zone.rule.id, zone]));
  for (const road of ruleRoads) {
    const zone = streetZoneOf.get(ruleOf.get(road.row.source_key).id);
    if (!zone) continue;
    const treatment = zone.rule.treatment;
    const style = road.tags.oneway === "yes" ? null : treatment.centerline;
    if (style === null && !treatment.edge_lines && treatment.bike_lanes === "none") continue;
    const roadBox = boxOfMulti(road.geometry);
    const line = wayLine(road);
    const half = ROAD_WIDTHS_M[road.tags.highway] / 2;
    const others = vehicles.filter((other) => !sameStreet(other, road) && boxesOverlap(boxOfMulti(other.geometry), roadBox)).map((other) => other.geometry);
    const junctions = union(`junctions ${road.row.source_key}`, others);
    const clip = (label, polygon) => difference(label, intersect(`${label} own road`, paintClip(label, polygon, [zone]), road.geometry), [junctions, crosswalkKeepout]);
    const wear = treatment.paint_wear;
    if (style === "double_yellow") {
      const lineHalf = lines.double_gap_m / 2;
      const clipped = clip("rule centre line", union("rule centre line", [strip("rule centre left", line, lineHalf, lineHalf + lines.width_m), strip("rule centre right", line, -lineHalf - lines.width_m, -lineHalf)]));
      paint(STREET_PAINT_KINDS.yellow, clipped, road.row.source_key, wear);
      counts.centerline_m += multiArea(clipped) / (2 * lines.width_m);
    } else if (style === "dashed_faded" || style === "dashed_white") {
      const dashes = [];
      const total = polylineLength(line);
      for (let at = lines.dash_gap_m / 2; at + lines.dash_m <= total; at += lines.dash_m + lines.dash_gap_m) {
        const point = pointAlong(line, at + lines.dash_m / 2);
        dashes.push(rectangle(point.point, point.tangent, leftOf(point.tangent), -lines.dash_m / 2, lines.dash_m / 2, -lines.width_m / 2, lines.width_m / 2));
      }
      const clipped = clip("rule dashed centre line", union("rule dashed centre line", dashes));
      paint(style === "dashed_white" ? STREET_PAINT_KINDS.white : STREET_PAINT_KINDS.yellow_faded, clipped, road.row.source_key, wear);
      counts.centerline_m += multiArea(clipped) / lines.width_m;
    }
    if (treatment.edge_lines) {
      for (const sign of [1, -1]) {
        const [from, to] = sign > 0 ? [half - lines.edge_inset_m - lines.width_m, half - lines.edge_inset_m] : [-half + lines.edge_inset_m, -half + lines.edge_inset_m + lines.width_m];
        paint(STREET_PAINT_KINDS.white, clip("rule edge line", strip("rule edge line", line, from, to)), road.row.source_key, wear);
      }
    }
    // Bike lanes along both curbs, on the whole carriageway (widening included):
    // a white line bike_lane_width_m in from the curb, and green paint in the lane.
    if (treatment.bike_lanes !== "none") {
      const laneClip = (label, polygon) => difference(label, paintClip(label, polygon, [zone]), [junctions, crosswalkKeepout]);
      for (const sign of [1, -1]) {
        const curb = halfWidthSide(road, sign) - kerb.gutter_width_m;
        const inner = curb - lines.bike_lane_width_m;
        const side = (from, to) => (sign > 0 ? [from, to] : [-to, -from]);
        paint(STREET_PAINT_KINDS.white, laneClip("rule bike lane line", strip("rule bike lane line", line, ...side(inner - lines.width_m, inner))), road.row.source_key, wear);
        if (treatment.bike_lanes === "green") {
          paint(STREET_PAINT_KINDS.green, laneClip("rule bike lane", strip("rule bike lane", line, ...side(inner + 0.05, curb))), road.row.source_key, wear);
        }
      }
    }
  }

  // Stop bars and STOP legends where a stop controls an approach: at OSM
  // highway=stop nodes on vehicle roads, and the rules' photographed stops.
  const placeStop = (nodeKey, host, position, forward, ownLine = true) => {
    const near = closestOnPolyline(wayLine(host), position);
    const travel = scale(near.tangent, forward ? 1 : -1);
    const right = [travel[1], -travel[0]];
    const half = ROAD_WIDTHS_M[host.tags.highway] / 2;
    const rule = pilotIndex.contains(near.point) ? null : ruleOf.get(host.row.source_key);
    const wear = rule ? rule.treatment.paint_wear : 0;
    // A stop node often sits on the junction itself. Back the stop line up the
    // approach until it is clear of every crossing road and crosswalk.
    const stopBox = boxOfPoints([near.point]);
    const crossingRoads = partsIndex(`roads crossing ${host.row.source_key}`, vehicles
      .filter((other) => !sameStreet(other, host) && (host.tags.name == null || other.tags.name !== host.tags.name) &&
        boxesOverlap(boxOfMulti(other.geometry), stopBox, 25))
      .map((other) => other.geometry));
    const barCorners = (center) => [-1, 1].flatMap((side) => [-1, 1].map((end) =>
      add(add(center, scale(travel, end * lines.stop_bar_width_m)), scale(right, side > 0 ? half - 0.1 : 0.15))));
    // The driver meets STOP, the stop line, then any crosswalk, then the
    // junction: put the line just upstream of the last blocked sample within
    // 16 m. A crosswalk counts anywhere in that reach; a crossing road only
    // until a clear stretch ends the junction, as a driveway further up the
    // approach is not part of it.
    let lastBlocked = -1;
    for (let step = 0; step <= 32; step += 1) {
      const sample = add(near.point, scale(travel, -0.5 * step));
      const inJunction = step - lastBlocked <= STOP_LINE_CLEAR_RUN_STEPS;
      if (barCorners(sample).some((corner) => keepoutIndex.contains(corner) || (inJunction && crossingRoads.contains(corner)))) lastBlocked = step;
    }
    const barCenter = lastBlocked < 0 ? near.point : add(near.point, scale(travel, -(0.5 * lastBlocked + 1.1)));
    const bar = rectangle(barCenter, travel, right, -lines.stop_bar_width_m / 2, lines.stop_bar_width_m / 2, 0.15, half - 0.1);
    if (ownLine) paint(STREET_PAINT_KINDS.white, roadPaint("stop bar", bar), host.row.source_key, wear);
    const legendWidth = Math.min(half - 0.6, 2.4);
    const legendCenter = add(add(barCenter, scale(travel, -(lines.stop_bar_width_m / 2 + lines.stop_legend_gap_m + lines.stop_legend_length_m / 2))), scale(right, half / 2));
    const legend = roadPaint("stop legend", rectangle(legendCenter, travel, right, -lines.stop_legend_length_m / 2, lines.stop_legend_length_m / 2, -legendWidth / 2, legendWidth / 2));
    if (legend.length > 0) {
      addPiece("marking", legend, constantHeight(ROAD_TOP_M + lifts.paint_m + DRAPED_LAYER_STEP_M), frameUv(STREET_PAINT_KINDS.stop_legend + PAINT_VARIANT_STRIDE * wear, legendCenter, travel, right, lines.stop_legend_length_m, legendWidth));
    }
    stopBars.push({ node_key: nodeKey, host_key: host.row.source_key, bar_center: barCenter, travel, right, kerb_offset_m: halfWidthSide(host, forward ? -1 : 1) });
    counts.stop_bars += 1;
  };
  const placedStops = new Set();
  for (const [sourceKey, source] of [...properSources.entries()].sort(([left], [right]) => compareSourceKeys(left, right))) {
    if (sourceKey[0] !== "n" || source.metadata.tags.highway !== "stop") continue;
    const node = rawOsm.nodes.get(sourceKey.slice(1));
    if (!node) continue;
    const position = projectLonLat(node.coordinate);
    if (zonesAt(position).length === 0) continue;
    // Only stops that OSM puts on a vehicle road: a stop node on a footway does
    // not say which approach it controls.
    const host = vehicles.find((object) => rawOsm.ways.get(object.row.osm_id).node_refs.includes(sourceKey.slice(1)));
    if (!host) continue;
    const near = closestOnPolyline(wayLine(host), position);
    const tags = source.metadata.tags;
    const forward = tags.direction === "forward" ? true : tags.direction === "backward" ? false : near.along > polylineLength(wayLine(host)) / 2;
    placeStop(sourceKey, host, position, forward);
    placedStops.add(`${sourceKey}|${host.row.source_key}`);
  }
  // A photographed stop at a junction node, controlling the approach along its way.
  for (const stop of rules?.stops ?? []) {
    const node = rawOsm.nodes.get(stop.node.slice(1));
    const host = vehicles.find((object) => object.row.source_key === stop.way);
    const refs = host ? rawOsm.ways.get(host.row.osm_id).node_refs : [];
    invariant(node && host && refs.includes(stop.node.slice(1)), `Street ground stop ${stop.node} is not a node of vehicle road ${stop.way}`);
    if (placedStops.has(`${stop.node}|${stop.way}`)) continue;
    const position = projectLonLat(node.coordinate);
    const forward = refs.at(-1) === stop.node.slice(1) ? true : refs[0] === stop.node.slice(1) ? false :
      closestOnPolyline(wayLine(host), position).along > polylineLength(wayLine(host)) / 2;
    placeStop(stop.node, host, position, forward, stop.own_line ?? true);
    placedStops.add(`${stop.node}|${stop.way}`);
  }

  // Parking stall lines along aisles inside lots. The stalls between two
  // neighbouring lines are kept for the parked cars (street clutter).
  const stallSlots = [];
  for (const zone of zoneRegions.filter((candidate) => candidate.settings.parking_stalls)) {
    const aisles = vehicles.filter((object) => object.tags.service === "parking_aisle" && boxesOverlap(boxOfMulti(object.geometry), zone.box) &&
      intersect("aisle zone", object.geometry, zone.region).length > 0);
    for (const aisle of aisles) {
      const line = wayLine(aisle);
      const half = ROAD_WIDTHS_M[aisle.tags.highway] / 2;
      // The other roads a stall's probe can reach.
      const aisleBox = boxOfMulti(aisle.geometry);
      const otherRoads = partsIndex("other aisles", vehicles
        .filter((other) => other !== aisle && boxesOverlap(boxOfMulti(other.geometry), aisleBox, lines.stall_length_m * 2 + 2))
        .map((other) => other.geometry));
      const total = polylineLength(line);
      const stalls = [];
      for (const sign of [1, -1]) {
        let previous = null;
        for (let s = 1.5; s <= total - 1.5; s += lines.stall_spacing_m) {
          const at = pointAlong(line, s);
          const outward = scale(leftOf(at.tangent), sign);
          const base = add(at.point, scale(outward, half + 0.05));
          let reach = 0;
          for (let step = 1; step <= Math.ceil((lines.stall_length_m * 2 + 1) / 0.2); step += 1) {
            const probe = add(base, scale(outward, step * 0.2));
            if (!lotIndex.contains(probe) || otherRoads.contains(probe) || buildingIndex.contains(probe) || bandIndex.contains(probe)) break;
            reach = step * 0.2;
          }
          const stall = Math.min(lines.stall_length_m, reach > lines.stall_length_m * 1.6 ? lines.stall_length_m : reach / 2) - 0.1;
          if (stall < 2.5) {
            previous = null;
            continue;
          }
          stalls.push(rectangle(base, outward, at.tangent, 0, stall, -lines.width_m / 2, lines.width_m / 2));
          if (previous) {
            const middle = pointAlong(line, s - lines.stall_spacing_m / 2);
            const middleOut = scale(leftOf(middle.tangent), sign);
            stallSlots.push({
              aisle_key: aisle.row.source_key,
              side: sign > 0 ? "left" : "right",
              s: roundCoordinate(s - lines.stall_spacing_m / 2),
              entry: add(middle.point, scale(middleOut, half + 0.05)),
              outward: middleOut,
              along: middle.tangent,
              depth_m: roundCoordinate(Math.min(stall, previous)),
              width_m: lines.stall_spacing_m,
            });
          }
          previous = stall;
        }
      }
      const painted = intersect("stall lines", union("stall lines", stalls), lotUnion);
      paint(STREET_PAINT_KINDS.white, painted, aisle.row.source_key);
      counts.stall_lines += stalls.length;
    }
  }
  for (const slot of stallSlots) slot.kind = "aisle";

  // Bays: their stall lines, square to the road, and a stall per pitch for the
  // parked cars (kind bay: entry on the road edge, outward into the bay).
  for (const { bay, road, line, sign, hw } of bays) {
    const wear = ruleOf.get(bay.way).treatment.paint_wear;
    const count = Math.floor((bay.to_m - bay.from_m) / bay.stall_width_m + 1e-9);
    const start = (bay.from_m + bay.to_m) / 2 - (count * bay.stall_width_m) / 2;
    // A stall is kept when no corner of it comes within the clearance of a building.
    const kept = Array.from({ length: count }, (_, index) => {
      const middle = pointAlong(line, start + (index + 0.5) * bay.stall_width_m);
      const out = scale(leftOf(middle.tangent), sign);
      const corners = [hw, hw + bay.depth_m].flatMap((reach) => [-0.5, 0.5].map((half) =>
        add(add(middle.point, scale(out, reach)), scale(middle.tangent, half * bay.stall_width_m))));
      return corners.every((corner) => bayBuildings.distance(corner, 2) > BAY_BUILDING_CLEARANCE_M);
    });
    const marks = [];
    for (let index = 0; index <= count; index += 1) {
      if (kept[index - 1] || kept[index]) {
        const at = pointAlong(line, start + index * bay.stall_width_m);
        const outward = scale(leftOf(at.tangent), sign);
        marks.push(rectangle(add(at.point, scale(outward, hw)), outward, at.tangent, 0.3, bay.depth_m - 0.3, -lines.width_m / 2, lines.width_m / 2));
      }
      if (index === count || !kept[index]) continue;
      const middle = pointAlong(line, start + (index + 0.5) * bay.stall_width_m);
      const middleOut = scale(leftOf(middle.tangent), sign);
      stallSlots.push({
        aisle_key: bay.way, side: bay.side, s: roundCoordinate(start + (index + 0.5) * bay.stall_width_m),
        entry: add(middle.point, scale(middleOut, hw)), outward: middleOut, along: middle.tangent,
        depth_m: bay.depth_m, width_m: bay.stall_width_m, kind: "bay",
      });
      counts.bays += 1;
    }
    if (bay.lines && marks.length > 0) paint(STREET_PAINT_KINDS.white, difference("bay lines off crosswalks", roadPaint("bay lines", union("bay lines", marks)), [crosswalkKeepout]), bay.way, wear);
  }
  // Shoulder stalls: thin lines square to the road across a rule street's widened
  // shoulder, from just outside its edge line to short of the shoulder's edge, and
  // a stall per pitch for the parked cars (kind shoulder: entry at the edge line).
  for (const stall of rules?.stalls ?? []) {
    const road = vehicles.find((object) => object.row.source_key === stall.way);
    invariant(road && ruleOf.has(stall.way), `Street ground shoulder stalls way ${stall.way} is not a rule street's vehicle road`);
    const line = wayLine(road);
    const total = polylineLength(line);
    invariant(stall.from_m >= 0 && stall.to_m <= total + 0.5, `Street ground shoulder stalls on ${stall.way} run past the way (${roundCoordinate(total)} m)`);
    const sign = stall.side === "left" ? 1 : -1;
    const inner = ROAD_WIDTHS_M[road.tags.highway] / 2 - lines.edge_inset_m + 0.05;
    const outer = halfWidthSide(road, sign) - 0.2;
    invariant(outer - inner >= 2, `Street ground shoulder stalls on ${stall.way} need a widened ${stall.side} side`);
    const count = Math.floor((stall.to_m - stall.from_m) / stall.stall_width_m + 1e-9);
    const start = (stall.from_m + stall.to_m) / 2 - (count * stall.stall_width_m) / 2;
    const marks = [];
    for (let index = 0; index <= count; index += 1) {
      const at = pointAlong(line, start + index * stall.stall_width_m);
      const outward = scale(leftOf(at.tangent), sign);
      marks.push(rectangle(add(at.point, scale(outward, inner)), outward, at.tangent, 0, outer - inner, -lines.width_m / 2, lines.width_m / 2));
      if (index === count) break;
      const middle = pointAlong(line, start + (index + 0.5) * stall.stall_width_m);
      const middleOut = scale(leftOf(middle.tangent), sign);
      stallSlots.push({
        aisle_key: stall.way, side: stall.side, s: roundCoordinate(start + (index + 0.5) * stall.stall_width_m),
        entry: add(middle.point, scale(middleOut, inner)), outward: middleOut, along: middle.tangent,
        depth_m: roundCoordinate(outer - inner), width_m: stall.stall_width_m, kind: "shoulder",
      });
      counts.shoulder_stalls += 1;
    }
    paint(STREET_PAINT_KINDS.white, difference("shoulder stall lines off crosswalks", roadPaint("shoulder stall lines", union("shoulder stall lines", marks)), [crosswalkKeepout]),
      stall.way, ruleOf.get(stall.way).treatment.paint_wear);
  }

  // Lot rules: stall rows (separator lines; accessible stalls outlined in blue
  // round their symbol; bus stalls with their legend), hatched zones and legends.
  // A legend of the atlas painted at a centre, reading up along facing, at a paint height and wear step.
  const legendPiece = (cell, center, facing, lengthM, widthM, sourceKey, paintHeight, wear) => {
    const along = unit(facing);
    const across = [along[1], -along[0]];
    addPiece("marking", rectangle(center, along, across, -lengthM / 2, lengthM / 2, -widthM / 2, widthM / 2), constantHeight(paintHeight),
      frameUv(STREET_PAINT_KINDS.legend + PAINT_VARIANT_STRIDE * (cell + STREET_LEGEND_ATLAS_CELLS * wear), center, along, across, lengthM, widthM));
    sources.marking.add(sourceKey);
  };
  // A rectangle's outline, a band inset from its edge.
  const outlineRing = (center, along, across, length0, length1, width0, width1, band) => difference("outline",
    rectangle(center, along, across, length0, length1, width0, width1), [rectangle(center, along, across, length0 + band, length1 - band, width0 + band, width1 - band)]);
  for (const { lot, object } of lotRules) {
    // On the lot's own pavement its paint and legends take their steps over it;
    // otherwise they lie over the lot like the aisles' paint.
    const lotLevel = (layer) => LOT_SURFACE_LIFT_M + LOT_LAYER_STEPS[layer] * DRAPED_LAYER_STEP_M;
    const lotPaint = lot.surface ? lotLevel("paint") : ROAD_TOP_M + lifts.paint_m;
    const lotTop = lot.surface ? lotLevel("top") : lotPaint + DRAPED_LAYER_STEP_M;
    const paintLot = (kind, polygon, wear, height = lotPaint) => {
      if (polygon.length === 0) return;
      addPiece("marking", polygon, constantHeight(height), kindUv(kind, wear));
      sources.marking.add(lot.source_key);
    };
    // Rows stop at the lot's raised islands: no line or stall on an island.
    const offIslands = (label, polygon) => (islandUnion.length === 0 ? polygon : difference(label, polygon, [islandUnion]));
    for (const row of lot.rows) {
      const p0 = [row.line_xz[0][0], -row.line_xz[0][1]];
      const p1 = [row.line_xz[1][0], -row.line_xz[1][1]];
      const direction = unit(sub(p1, p0));
      const sign = row.side === "left" ? 1 : -1;
      const theta = (row.angle_deg * Math.PI) / 180;
      // The stall axis: the row direction turned by the angle toward the side.
      const axis = [direction[0] * Math.cos(theta) - sign * direction[1] * Math.sin(theta), sign * direction[0] * Math.sin(theta) + direction[1] * Math.cos(theta)];
      const pitch = row.stall_width_m / Math.sin(theta);
      const reach = row.depth_m / Math.sin(theta);
      // Faded rows are worn away entirely; the rest at the lot's paint wear.
      const wear = row.style === "faded" ? PAINT_WEAR_STEPS - 1 : lot.paint_wear;
      const separators = [];
      for (let index = 0; index <= row.count; index += 1) {
        const base = add(p0, scale(direction, index * pitch));
        separators.push(rectangle(base, axis, leftOf(axis), 0, reach, -lines.width_m / 2, lines.width_m / 2));
      }
      paintLot(STREET_PAINT_KINDS.white, offIslands(`lot ${lot.id} ${row.id} off islands`,
        intersect(`lot ${lot.id} ${row.id}`, union(`lot ${lot.id} ${row.id} lines`, separators), object.geometry)), wear);
      for (let index = 0; index < row.count; index += 1) {
        const entry = add(p0, scale(direction, (index + 0.5) * pitch));
        const middle = add(entry, scale(axis, row.depth_m / 2));
        const footprint = rectangle(entry, axis, leftOf(axis), 0, row.depth_m, -row.stall_width_m / 2, row.stall_width_m / 2);
        if (islandUnion.length > 0 && intersect(`lot ${lot.id} stall on island`, footprint, islandUnion).length > 0) continue;
        if (row.style === "accessible_filled") {
          // Dark blue inside the white separators; the symbol by the aisle, upright from it.
          const inset = lines.width_m / 2 + 0.01;
          paintLot(STREET_PAINT_KINDS.blue_dark, intersect(`lot ${lot.id} accessible fill`,
            rectangle(entry, axis, leftOf(axis), inset, row.depth_m - inset, -row.stall_width_m / 2 + inset, row.stall_width_m / 2 - inset), object.geometry), Math.min(wear, 2));
          legendPiece(STREET_LEGEND_CELLS.accessible, add(entry, scale(axis, 1)), axis, LOT_SYMBOL_M, LOT_SYMBOL_M, lot.source_key, lotTop, Math.min(wear, 2));
        }
        if (row.style === "accessible") {
          // A blue outline inside the white separators and the symbol, on grey.
          paintLot(STREET_PAINT_KINDS.blue, intersect(`lot ${lot.id} accessible`,
            outlineRing(entry, axis, leftOf(axis), 0.2, row.depth_m - 0.2, -row.stall_width_m / 2 + 0.2, row.stall_width_m / 2 - 0.2, 0.12), object.geometry), Math.min(wear, 2));
          legendPiece(STREET_LEGEND_CELLS.accessible, middle, scale(axis, -1), Math.min(1.6, row.depth_m * 0.4), Math.min(1.6, row.stall_width_m * 0.6), lot.source_key, lotTop, Math.min(wear, 2));
        }
        stallSlots.push({
          aisle_key: lot.source_key, side: row.side, s: roundCoordinate((index + 0.5) * pitch), entry, outward: axis, along: direction,
          depth_m: row.depth_m, width_m: row.stall_width_m, kind: "lot_row", lot_id: lot.id, row_id: row.id, style: row.style,
        });
        counts.lot_stalls += 1;
      }
    }
    // Hatched no-parking zones: an outline, and stripes at 45 degrees to its first edge.
    for (const hatch of lot.hatches) {
      const raw = hatch.points_xz.map(([x, z]) => [x, -z]);
      const ring = ringArea(raw) > 0 ? raw : [...raw].reverse();
      const zone = [[ring]];
      // The outline: a band inside each edge (the inside lies left of a CCW ring's edges).
      const parts = ring.map((a, index) => {
        const b = ring[(index + 1) % ring.length];
        const edge = unit(sub(b, a));
        return rectangle(a, edge, leftOf(edge), 0, length(sub(b, a)), 0, 0.12);
      });
      if (hatch.stripes) {
        const first = unit(sub(ring[1], ring[0]));
        const stripe = unit([first[0] - first[1], first[1] + first[0]]);
        const box = boxOfMulti(zone);
        const centre = [(box.min_x + box.max_x) / 2, (box.min_y + box.max_y) / 2];
        const radius = Math.hypot(box.max_x - box.min_x, box.max_y - box.min_y) / 2 + 1;
        for (let offset = -radius; offset <= radius; offset += 0.75) {
          parts.push(rectangle(add(centre, scale(leftOf(stripe), offset)), stripe, leftOf(stripe), -radius, radius, -0.06, 0.06));
        }
      }
      paintLot(STREET_PAINT_KINDS.white, intersect(`lot ${lot.id} ${hatch.id}`, union(`lot ${lot.id} ${hatch.id} paint`, parts), zone), lot.paint_wear, lotTop);
    }
    for (const legend of lot.legends) {
      legendPiece(STREET_LEGEND_CELLS[legend.cell], [legend.at_xz[0], -legend.at_xz[1]], [legend.facing_xz[0], -legend.facing_xz[1]], legend.length_m, legend.width_m, lot.source_key, lotTop, legend.paint_wear);
    }
  }

  // ---------------------------------------------------------------- wear
  const wearPiece = (cell, center, along, alongSize, acrossSize, sourceKey) => {
    const across = leftOf(along);
    const quad = rectangle(center, along, across, -alongSize / 2, alongSize / 2, -acrossSize / 2, acrossSize / 2);
    if (!openRing(quad[0][0]).every((point) => vehicleIndex.contains(point))) return false;
    addPiece("wear", quad, constantHeight(ROAD_TOP_M + (lifts.gutter_m + lifts.paint_m) / 2), frameUv(cell, center, along, across, alongSize, acrossSize));
    sources.wear.add(sourceKey);
    counts.wear[cell] = (counts.wear[cell] ?? 0) + 1;
    return true;
  };
  for (const zone of zoneRegions) {
    const wear = zone.settings.wear;
    const asphalt = intersect(`asphalt ${zone.id}`, vehicleIndex.local(zone.box), zone.region);
    const area = multiArea(asphalt);
    const box = boxOfMulti(asphalt.length > 0 ? asphalt : zone.region);
    const asphaltIndex = polygonIndex(asphalt);
    const scatter = (kindName, perHundred, cells, size) => {
      const wanted = Math.round((area * perHundred) / 100);
      let placed = 0;
      for (let attempt = 0; placed < wanted && attempt < wanted * 12; attempt += 1) {
        const identity = `${zone.id}:${kindName}:${attempt}`;
        const point = [box.min_x + hashUnit(seed, identity, 0) * (box.max_x - box.min_x), box.min_y + hashUnit(seed, identity, 1) * (box.max_y - box.min_y)];
        if (!asphaltIndex.contains(point) || keepoutIndex.contains(point)) continue;
        const road = nearestRoad(point);
        if (!road) continue;
        const jitter = (hashUnit(seed, identity, 2) - 0.5) * (kindName === "oil" ? 2 * Math.PI : 0.25);
        const angle = Math.atan2(road.near.tangent[1], road.near.tangent[0]) + jitter + (kindName !== "oil" && hashUnit(seed, identity, 3) < 0.3 ? Math.PI / 2 : 0);
        const along = [Math.cos(angle), Math.sin(angle)];
        const cell = cells[Math.floor(hashUnit(seed, identity, 4) * cells.length) % cells.length];
        const sizeScale = 0.75 + hashUnit(seed, identity, 5) * 0.5;
        if (wearPiece(cell, point, along, size[0] * sizeScale, size[1] * sizeScale, road.road.row.source_key)) placed += 1;
      }
    };
    scatter("crack", wear.crack_per_100m2, [STREET_WEAR_CELLS.crack_a, STREET_WEAR_CELLS.crack_b], [3.2, 1.6]);
    scatter("patch", wear.patch_per_100m2, [STREET_WEAR_CELLS.patch], [2.2, 1.4]);
    scatter("oil", wear.oil_per_100m2, [STREET_WEAR_CELLS.oil_a, STREET_WEAR_CELLS.oil_b], [1.4, 1.4]);
    // Manholes along the middle of each kerbed road in the zone (a rule street's own roads).
    if (wear.manhole_spacing_m > 0) {
      for (const road of zone.rule ? ruleRoads.filter((object) => ruleOf.get(object.row.source_key) === zone.rule) : kerbRoads) {
        const line = wayLine(road);
        const total = polylineLength(line);
        for (let s = wear.manhole_spacing_m / 2, index = 0; s < total; s += wear.manhole_spacing_m, index += 1) {
          const identity = `${zone.id}:manhole:${road.row.source_key}:${index}`;
          const at = pointAlong(line, Math.min(total, s + (hashUnit(seed, identity, 0) - 0.5) * wear.manhole_spacing_m * 0.4));
          const side = (hashUnit(seed, identity, 1) < 0.5 ? -1 : 1) * ROAD_WIDTHS_M[road.tags.highway] * 0.22;
          const point = add(at.point, scale(leftOf(at.tangent), side));
          if (!zone.index.contains(point) || keepoutIndex.contains(point)) continue;
          wearPiece(STREET_WEAR_CELLS.manhole, point, at.tangent, 0.95, 0.95, road.row.source_key);
        }
      }
    }
    // Storm drains in the gutter along curb faces.
    if (wear.drain_spacing_m > 0) {
      let walked = wear.drain_spacing_m / 2;
      for (const edge of faces.filter((face) => face.kind === "curb")) {
        const edgeLength = length(sub(edge.b, edge.a));
        let s = walked;
        while (s < edgeLength) {
          const along = unit(sub(edge.b, edge.a));
          const center = add(add(edge.a, scale(along, s)), scale(edge.outward, 0.27));
          if (zone.index.contains(center) && !notchIndex.contains(add(center, scale(edge.outward, -0.5))) && s > 0.6 && s < edgeLength - 0.6) {
            const road = nearestRoad(center);
            if (road) wearPiece(STREET_WEAR_CELLS.drain, center, along, 0.95, 0.5, road.road.row.source_key);
          }
          s += wear.drain_spacing_m;
        }
        walked = s - edgeLength;
      }
    }
  }

  // ---------------------------------------------------------------- park surfaces
  // Each park zone's layers, later ones replacing earlier ones: one partition of
  // the zone into flat-lying ground draped lift_m over the land. Zones share the
  // ground the same way: where two zones' ground overlaps, the zone listed later
  // in the config replaces the earlier one's, so no two zones draw there.
  const pedestrianWays = roads.filter((object) => object.road_visual_class === "pedestrian");
  const sourceGeometry = (key) => {
    const object = playableObjects.get(key);
    invariant(object && object.geometry?.length > 0, `Park surface source ${key} has no geometry`);
    return object.geometry;
  };
  const layerLine = (layer) => {
    const shape = layer.shape;
    if (shape.line_xz) return { line: shape.line_xz.map(([x, z]) => [x, -z]), offset: 0 };
    if (shape.way) return { line: rawWayLine(rawOsm, shape.way.slice(1)), offset: shape.offset_m };
    return null;
  };
  const layerShape = (zone, layer) => {
    const shape = layer.shape;
    let polygon;
    if (shape.zone) {
      polygon = zone.region;
    } else if (shape.osm_paths) {
      polygon = union(`park ${layer.id} paths`, pedestrianWays.filter((object) => intersect(`park ${layer.id} path test`, object.geometry, zone.region).length > 0).map((object) => object.geometry));
    } else if (shape.points_xz) {
      const ring = shape.points_xz.map(([x, z]) => [x, -z]);
      polygon = union(`park ${layer.id}`, [[[ringArea(ring) > 0 ? ring : ring.reverse()]]]);
    } else {
      const { line, offset } = layerLine(layer);
      polygon = strip(`park ${layer.id}`, line, offset - shape.width_m / 2, offset + shape.width_m / 2);
    }
    if (shape.minus_sources) polygon = difference(`park ${layer.id} minus`, polygon, shape.minus_sources.map(sourceGeometry));
    return intersect(`park ${layer.id} in zone`, polygon, zone.region);
  };
  const parkLayers = [];
  const parkLifts = new Map();
  const groundZones = zoneRegions.filter((zone) => zone.settings.surfaces);
  const zoneShapes = new Map(groundZones.map((zone) => [zone, zone.settings.surfaces.layers.map((layer) => layerShape(zone, layer))]));
  for (const [zoneIndex, zone] of groundZones.entries()) {
    const surfaces = zone.settings.surfaces;
    const shapes = zoneShapes.get(zone);
    const later = groundZones.slice(zoneIndex + 1).filter((other) => boxesOverlap(zone.box, other.box) &&
      multiArea(intersect(`zones ${zone.id} ${other.id}`, zone.region, other.region)) > 1e-8);
    let covered = union(`park ${zone.id} later zones`, later.flatMap((other) => zoneShapes.get(other)));
    for (let index = surfaces.layers.length - 1; index >= 0; index -= 1) {
      const layer = surfaces.layers[index];
      const own = cleanPolygons(difference(`park ${layer.id} uncovered`, shapes[index], [covered]), 0.05, 0.05);
      covered = union(`park ${zone.id} cover`, [covered, shapes[index]]);
      if (own.length === 0) continue;
      invariant((parkLifts.get(layer.material) ?? surfaces.lift_m) === surfaces.lift_m, `Park surface ${layer.material} has two lifts`);
      parkLifts.set(layer.material, surfaces.lift_m);
      parkLayers.push({ zone, layer, polygon: own, index: polygonIndex(own), box: boxOfMulti(own), lift: surfaces.lift_m, sources: surfaces.source_keys });
    }
  }
  for (const entry of parkLayers) {
    const { layer, polygon, lift } = entry;
    for (const key of entry.sources) sources[layer.material].add(key);
    const height = constantHeight(lift);
    const path = layer.material === "park_concrete" ? layerLine(layer) : null;
    if (layer.frame) {
      // Plaza paint laid out in metres along the plaza's axis.
      const origin = [layer.frame.origin_xz[0], -layer.frame.origin_xz[1]];
      const axis = unit([layer.frame.axis_xz[0], -layer.frame.axis_xz[1]]);
      addPiece(layer.material, polygon, height, (point) => [dot(sub(point, origin), axis), cross(axis, sub(point, origin))], true);
    } else if (path) {
      // Concrete paths in poured panels that follow the path's bends.
      for (const cell of gridCells(boxOfMulti(polygon), PATH_FRAME_CELL_M)) {
        const piece = intersect(`park ${layer.id} cell`, polygon, cell);
        if (multiArea(piece) < 1e-6) continue;
        const box = boxOfMulti(piece);
        addPiece(layer.material, piece, height, roadFrameUv(path.line, [(box.min_x + box.max_x) / 2, (box.min_y + box.max_y) / 2], kerb.panel_m * 2), true);
      }
    } else {
      // Concrete elsewhere in panels on the world grid; other ground in world UV.
      addPiece(layer.material, polygon, height, layer.material === "park_concrete" ? tiledUv(kerb.panel_m * 2) : worldUv, true);
    }
    if (layer.markings) {
      // Painted lines on the path itself, just above it: edge lines in from
      // both edges and a dashed centre line.
      const { line, offset } = layerLine(layer);
      const half = layer.shape.width_m / 2;
      const lines = [];
      if (layer.markings.edges) {
        for (const side of [-1, 1]) {
          const at = offset + side * (half - PARK_EDGE_LINE_INSET_M);
          lines.push([layer.markings.edges, strip(`park ${layer.id} edge line`, line, at - PARK_LINE_WIDTH_M / 2, at + PARK_LINE_WIDTH_M / 2)]);
        }
      }
      if (layer.markings.centre) lines.push([layer.markings.centre, dashedStrip(`park ${layer.id} centre line`, line, offset, PARK_LINE_WIDTH_M, PARK_DASH_M)]);
      for (const [kind, band] of lines) {
        const painted = intersect(`park ${layer.id} paint`, band, polygon);
        if (painted.length === 0) continue;
        addPiece("marking", painted, constantHeight(lift + PARK_PAINT_LIFT_M), kindUv(STREET_PAINT_KINDS[kind]));
        for (const key of entry.sources) sources.marking.add(key);
      }
    }
  }
  // Lot rules' own pavement over their whole lot, at the yards' lift (one lift per material).
  const addLotGround = (lot, id, material, polygon) => {
    invariant((parkLifts.get(material) ?? LOT_SURFACE_LIFT_M) === LOT_SURFACE_LIFT_M, `Street ground lot ${lot.id} surface ${material} already lies at another lift`);
    parkLifts.set(material, LOT_SURFACE_LIFT_M);
    sources[material].add(lot.source_key);
    parkLayers.push({ zone: null, layer: { material, id }, polygon, index: polygonIndex(polygon), box: boxOfMulti(polygon), lift: LOT_SURFACE_LIFT_M, sources: [lot.source_key] });
    addPiece(material, polygon, constantHeight(LOT_SURFACE_LIFT_M), worldUv, true);
  };
  // A strip outward from the lot's shoulder edges, as wide as width (its outer edge
  // wandering by up to wander).
  const shoulderStrip = (lot, width, wander) => {
    const outline = lot.osm_exception.outline_xz.map(([x, z]) => [x, -z]);
    const outward = ringArea(outline) > 0 ? -1 : 1;
    const edges = lot.pattern.shoulder.edges;
    return union(`lot ${lot.id} shoulder`, edges.map((edge) => {
      const a = outline[edge];
      const b = outline[(edge + 1) % outline.length];
      const along = unit(sub(b, a));
      const start = edges.includes((edge + outline.length - 1) % outline.length) ? add(a, scale(along, -SHOULDER_JOIN_M)) : a;
      const end = edges.includes((edge + 1) % outline.length) ? add(b, scale(along, SHOULDER_JOIN_M)) : b;
      const steps = Math.max(1, Math.round(length(sub(end, start)) / SHOULDER_STEP_M));
      const noise = (slot, index) => hashUnit(seed, `${lot.id}:shoulder:${edge}:${index}`, slot) - 0.5;
      const wandering = (step) => {
        const knot = Math.floor(step / SHOULDER_DRIFT_STEPS);
        const fraction = step / SHOULDER_DRIFT_STEPS - knot;
        return (noise(0, knot) * (1 - fraction) + noise(0, knot + 1) * fraction) * 1.6 + noise(1, step) * 0.4;
      };
      const outer = Array.from({ length: steps + 1 }, (_, step) => add(add(start, scale(sub(end, start), step / steps)),
        scale(leftOf(along), outward * (width + wandering(step) * wander))));
      const ring = [start, end, ...outer.reverse()];
      return [[ringArea(ring) > 0 ? ring : ring.reverse()]];
    }));
  };
  for (const { lot, object } of lotRules) {
    if (!lot.surface) continue;
    const polygon = object.geometry;
    addLotGround(lot, lot.id, lot.surface.material, polygon);
    // Behind the curb, off the lot and the raised and paved ground: visual only, the land stays the floor.
    if (lot.pattern) {
      const { band_m: band, band_material: bandMaterial, gravel_m: gravel, gravel_material: gravelMaterial } = lot.pattern.shoulder;
      const taken = [polygon, bandOriginal, vehicleUnion];
      const bandStrip = difference(`lot ${lot.id} shoulder band`, shoulderStrip(lot, band, 0), taken);
      addLotGround(lot, `${lot.id}_shoulder_band`, bandMaterial, bandStrip);
      addLotGround(lot, `${lot.id}_shoulder`, gravelMaterial, difference(`lot ${lot.id} shoulder gravel`, shoulderStrip(lot, band + gravel, SHOULDER_WANDER_M), [...taken, bandStrip]));
    }
    const lotStep = (layer) => constantHeight(LOT_SURFACE_LIFT_M + LOT_LAYER_STEPS[layer] * DRAPED_LAYER_STEP_M);
    const openPavement = (label, piece) => difference(label, intersect(`${label} in lot`, piece, polygon), [islandUnion, bandOriginal].filter((part) => part.length > 0));
    // Patched strips along the lot (dark asphalt), then its long tar-sealed joints.
    for (const [index, strip] of lot.surface.patch_strips.entries()) {
      const a = [strip.line_xz[0][0], -strip.line_xz[0][1]];
      const b = [strip.line_xz[1][0], -strip.line_xz[1][1]];
      const along = unit(sub(b, a));
      const piece = openPavement(`lot ${lot.id} patch strip ${index}`, rectangle(a, along, leftOf(along), 0, length(sub(b, a)), -strip.width_m / 2, strip.width_m / 2));
      if (piece.length === 0) continue;
      addPiece("marking", piece, lotStep("patch"), kindUv(STREET_PAINT_KINDS.patch));
      sources.marking.add(lot.source_key);
    }
    // Each joint wanders a little either side of its line (a 2.5 m step, up to 0.12 m).
    const seams = lot.surface.seams.map((seam, index) => {
      const a = [seam.line_xz[0][0], -seam.line_xz[0][1]];
      const b = [seam.line_xz[1][0], -seam.line_xz[1][1]];
      const along = unit(sub(b, a));
      const steps = Math.max(1, Math.round(length(sub(b, a)) / 2.5));
      const points = Array.from({ length: steps + 1 }, (_, step) => add(add(a, scale(sub(b, a), step / steps)),
        scale(leftOf(along), step === 0 || step === steps ? 0 : (hashUnit(seed, `${lot.id}:seam:${index}:${step}`, 0) - 0.5) * 0.24)));
      return strip(`lot ${lot.id} seam ${index}`, points, -seam.width_m / 2, seam.width_m / 2);
    });
    const sealed = seams.length === 0 ? [] : openPavement(`lot ${lot.id} seams`, union(`lot ${lot.id} seam lines`, seams));
    if (sealed.length > 0) {
      addPiece("marking", sealed, lotStep("seam"), kindUv(STREET_PAINT_KINDS.sealant));
      sources.marking.add(lot.source_key);
    }
    // Its cracks, patches and oil stains (under its joints and paint), anywhere
    // on the open pavement, in any direction.
    const lotIndex = polygonIndex(polygon);
    const lotBox = boxOfMulti(polygon);
    const lotArea = multiArea(polygon);
    for (const [kindName, perHundred, cells, size] of [
      ["crack", lot.surface.wear.crack_per_100m2, [STREET_WEAR_CELLS.crack_a, STREET_WEAR_CELLS.crack_b], [3.2, 1.6]],
      ["patch", lot.surface.wear.patch_per_100m2, [STREET_WEAR_CELLS.patch], [2.2, 1.4]],
      ["oil", lot.surface.wear.oil_per_100m2, [STREET_WEAR_CELLS.oil_a, STREET_WEAR_CELLS.oil_b], [1.4, 1.4]],
    ]) {
      const wanted = Math.round((lotArea * perHundred) / 100);
      let placed = 0;
      for (let attempt = 0; placed < wanted && attempt < wanted * 12; attempt += 1) {
        const identity = `${lot.id}:${kindName}:${attempt}`;
        const center = [lotBox.min_x + hashUnit(seed, identity, 0) * (lotBox.max_x - lotBox.min_x), lotBox.min_y + hashUnit(seed, identity, 1) * (lotBox.max_y - lotBox.min_y)];
        const angle = hashUnit(seed, identity, 2) * 2 * Math.PI;
        const along = [Math.cos(angle), Math.sin(angle)];
        const scaleBy = 0.75 + hashUnit(seed, identity, 5) * 0.5;
        const [alongSize, acrossSize] = [size[0] * scaleBy, size[1] * scaleBy];
        const quad = rectangle(center, along, leftOf(along), -alongSize / 2, alongSize / 2, -acrossSize / 2, acrossSize / 2);
        if (!openRing(quad[0][0]).every((corner) => lotIndex.contains(corner) && !islandIndex.contains(corner) && !bandIndex.contains(corner))) continue;
        const cell = cells[Math.floor(hashUnit(seed, identity, 4) * cells.length) % cells.length];
        addPiece("wear", quad, lotStep("wear"), frameUv(cell, center, along, leftOf(along), alongSize, acrossSize));
        sources.wear.add(lot.source_key);
        counts.wear[cell] = (counts.wear[cell] ?? 0) + 1;
        placed += 1;
      }
    }
  }
  const parkAt = (point) => parkLayers.find((entry) => inBox(entry.box, point) && entry.index.contains(point)) ?? null;
  // Beds of the park layers with the given materials: whether a point lies on
  // one and how far it is from the nearest bed edge (inside or out), searched
  // within BED_REACH_M; for planting drifts (tools/lib/street-planting-generation.mjs).
  // A bed is the park ground the player sees: where the raised street ground
  // (sidewalks, curb ramps) is drawn over a park layer, that part is no bed.
  const BED_REACH_M = 8;
  const BED_CELL_M = 2;
  // Each cell lists the bed edges that come within BED_EDGE_MARGIN_M of it: a
  // cell that lists none lies wholly on a bed or wholly off it.
  const BED_EDGE_MARGIN_M = 0.001;
  const bedIndexes = new Map();
  // A rule passes the same materials list on every call: look it up by the list.
  const bedIndexesByList = new WeakMap();
  const bedIndex = (materials) => {
    const known = bedIndexesByList.get(materials);
    if (known) return known;
    const key = [...materials].sort().join("|");
    if (!bedIndexes.has(key)) {
      const parts = parkLayers.filter((entry) => materials.includes(entry.layer.material)).map((entry) => entry.polygon);
      const region = difference(`park beds ${key} uncovered`, union(`park beds ${key}`, parts), [bandOriginal, notchUnion]);
      const cells = new Map();
      for (const polygon of region) {
        for (const raw of polygon) {
          const ring = openRing(raw);
          ring.forEach((a, index) => {
            const b = ring[(index + 1) % ring.length];
            // In pieces of at most half a cell, so a long diagonal edge lists
            // only in the cells along it, not across its whole bounding box.
            const edge = sub(b, a);
            const pieces = Math.max(1, Math.ceil(length(edge) / (BED_CELL_M / 2)));
            const touched = new Set();
            for (let piece = 0; piece < pieces; piece += 1) {
              const p = add(a, scale(edge, piece / pieces));
              const q = piece + 1 === pieces ? b : add(a, scale(edge, (piece + 1) / pieces));
              for (let i = Math.floor((Math.min(p[0], q[0]) - BED_EDGE_MARGIN_M) / BED_CELL_M); i <= Math.floor((Math.max(p[0], q[0]) + BED_EDGE_MARGIN_M) / BED_CELL_M); i += 1) {
                for (let j = Math.floor((Math.min(p[1], q[1]) - BED_EDGE_MARGIN_M) / BED_CELL_M); j <= Math.floor((Math.max(p[1], q[1]) + BED_EDGE_MARGIN_M) / BED_CELL_M); j += 1) touched.add(`${i},${j}`);
              }
            }
            for (const cell of touched) {
              if (!cells.has(cell)) cells.set(cell, []);
              cells.get(cell).push([a, b]);
            }
          });
        }
      }
      // Whether each cell that lists no edge lies on the bed, from its first query.
      bedIndexes.set(key, { index: polygonIndex(region), cells, wholeCells: new Map() });
    }
    bedIndexesByList.set(materials, bedIndexes.get(key));
    return bedIndexes.get(key);
  };
  // Whether a point lies on a bed of the given materials (parkBed's "on" alone).
  const parkBedOn = (point, materials) => {
    const { index, cells, wholeCells } = bedIndex(materials);
    const cell = `${Math.floor(point[0] / BED_CELL_M)},${Math.floor(point[1] / BED_CELL_M)}`;
    if (cells.has(cell)) return index.contains(point);
    if (!wholeCells.has(cell)) wholeCells.set(cell, index.contains(point));
    return wholeCells.get(cell);
  };
  const parkBed = (point, materials) => {
    const { cells } = bedIndex(materials);
    const ci = Math.floor(point[0] / BED_CELL_M);
    const cj = Math.floor(point[1] / BED_CELL_M);
    let best = BED_REACH_M;
    for (let ring = 0; ring * BED_CELL_M <= BED_REACH_M; ring += 1) {
      if ((ring - 1) * BED_CELL_M > best) break;
      for (let di = -ring; di <= ring; di += 1) {
        for (let dj = -ring; dj <= ring; dj += 1) {
          if (Math.max(Math.abs(di), Math.abs(dj)) !== ring) continue;
          for (const [a, b] of cells.get(`${ci + di},${cj + dj}`) ?? []) {
            const edge = sub(b, a);
            const t = Math.max(0, Math.min(1, dot(sub(point, a), edge) / Math.max(1e-12, dot(edge, edge))));
            best = Math.min(best, length(sub(point, add(a, scale(edge, t)))));
          }
        }
      }
    }
    return { on: parkBedOn(point, materials), distance: best };
  };

  // ---------------------------------------------------------------- drape
  const meshes = new Map();
  const meshFor = (record, id) => {
    const key = `${record}|${id}`;
    if (!meshes.has(key)) meshes.set(key, { record, chunk: id, vertices: [], normals: [], uvs: [], indices: [] });
    return meshes.get(key);
  };
  const chunkRange = (box) => {
    const ids = [];
    for (let x = Math.floor(box.min_x / CHUNK_SIZE_M); x <= Math.floor(box.max_x / CHUNK_SIZE_M); x += 1) {
      for (let z = Math.floor(-box.max_y / CHUNK_SIZE_M); z <= Math.floor(-box.min_y / CHUNK_SIZE_M); z += 1) ids.push({ x, z, id: chunkId(x, z) });
    }
    return ids;
  };
  const facetCache = new Map();
  const facetsOf = (id) => {
    if (!facetCache.has(id)) facetCache.set(id, facetsForChunk(id));
    return facetCache.get(id);
  };
  const facetGradient = (facet) => {
    const origin = facetElevation(facet, 0, 0).elevation;
    return [facetElevation(facet, 1, 0).elevation - origin, facetElevation(facet, 0, 1).elevation - origin];
  };
  const drape = (piece) => {
    for (const chunk of chunkRange(boxOfMulti(piece.polygon))) {
      const rect = [[[[chunk.x * CHUNK_SIZE_M, -(chunk.z + 1) * CHUNK_SIZE_M], [(chunk.x + 1) * CHUNK_SIZE_M, -(chunk.z + 1) * CHUNK_SIZE_M], [(chunk.x + 1) * CHUNK_SIZE_M, -chunk.z * CHUNK_SIZE_M], [chunk.x * CHUNK_SIZE_M, -chunk.z * CHUNK_SIZE_M]]]];
      const inChunk = intersect("piece chunk", piece.polygon, rect);
      if (multiArea(inChunk) < 1e-6) continue;
      const box = boxOfMulti(inChunk);
      for (const facet of facetsOf(chunk.id)) {
        if (!boxesOverlap(facet.bounds, box, 1e-6)) continue;
        const part = intersect("piece facet", inChunk, facet.geometry);
        if (multiArea(part) < 1e-6) continue;
        const gradient = facetGradient(facet);
        const surface = [gradient[0] + piece.height.he, gradient[1] + piece.height.hn];
        const normalLength = Math.hypot(surface[0], 1, surface[1]);
        const normal = [-surface[0] / normalLength, 1 / normalLength, surface[1] / normalLength];
        const mesh = meshFor(piece.record, chunk.id);
        for (const polygon of part) {
          const rings = polygon.map(openRing).filter((ring) => ring.length >= 3);
          if (rings.length === 0) continue;
          const flat = [];
          const holes = [];
          const points = [];
          rings.forEach((ring, ringIndex) => {
            if (ringIndex > 0) holes.push(points.length);
            for (const point of ring) {
              flat.push(point[0], point[1]);
              points.push(point);
            }
          });
          const triangles = earcut(flat, holes, 2);
          const offset = mesh.vertices.length / 3;
          for (const point of points) {
            const land = facetElevation(facet, point[0], point[1]).elevation;
            mesh.vertices.push(roundCoordinate(point[0]), roundCoordinate(land + heightAt(piece.height, point)), roundCoordinate(-point[1]));
            mesh.normals.push(...((piece.smooth && normalAt?.(point[0], point[1])) || normal).map(roundCoordinate));
            mesh.uvs.push(...piece.uv(point).map(roundCoordinate));
          }
          pushTriangles(mesh, triangles.map((index) => index + offset), normal);
        }
      }
    }
  };
  // Paint pieces of the marking record that overlap closer than a draped step (the
  // validator compares records with each other, not the pieces inside one): visit
  // sees each such pair once, the earlier piece first, and a point of the overlap.
  const eachPaintClash = (visit) => {
    const entries = pieces.filter((piece) => piece.record === "marking").flatMap((piece) =>
      piece.polygon.map((polygon) => ({ piece, polygon, box: boxOfPoints(polygon[0]) })));
    const cells = new Map();
    entries.forEach((entry, index) => {
      for (let i = Math.floor(entry.box.min_x / PAINT_CELL_M); i <= Math.floor(entry.box.max_x / PAINT_CELL_M); i += 1) {
        for (let j = Math.floor(entry.box.min_y / PAINT_CELL_M); j <= Math.floor(entry.box.max_y / PAINT_CELL_M); j += 1) {
          const key = `${i},${j}`;
          if (!cells.has(key)) cells.set(key, []);
          cells.get(key).push(index);
        }
      }
    });
    const compared = new Set();
    for (const indices of cells.values()) {
      for (let x = 0; x < indices.length; x += 1) {
        for (let y = x + 1; y < indices.length; y += 1) {
          const [earlier, later] = [entries[indices[x]], entries[indices[y]]];
          const pair = `${indices[x]}:${indices[y]}`;
          if (earlier.piece === later.piece || compared.has(pair) || !boxesOverlap(earlier.box, later.box)) continue;
          compared.add(pair);
          const overlap = intersect("paint overlap", [earlier.polygon], [later.polygon]);
          if (multiArea(overlap) < PAINT_OVERLAP_MIN_M2) continue;
          const probe = overlap[0][0][0];
          if (Math.abs(heightAt(earlier.piece.height, probe) - heightAt(later.piece.height, probe)) < DRAPED_LAYER_STEP_M - 1e-6) visit(earlier, later, probe);
        }
      }
    }
  };
  // Where two paints of one kind clash the later gives way (two crosswalks sharing
  // a junction corner, adjacent red curb tops): its overlap is cut out. A clash of
  // two kinds is a missing layer step, so it stays a build error.
  const paintKind = (entry) => Math.floor(entry.piece.uv(entry.polygon[0][0])[0]) % PAINT_VARIANT_STRIDE;
  const givingWay = new Map();
  eachPaintClash((earlier, later) => {
    if (paintKind(earlier) !== paintKind(later)) return;
    if (!givingWay.has(later)) givingWay.set(later, []);
    givingWay.get(later).push([earlier.polygon]);
  });
  for (const [entry, cuts] of givingWay) {
    const kept = cleanPolygons(difference("paint giving way", [entry.polygon], cuts), 0.001, 0.01);
    entry.piece.polygon = entry.piece.polygon.flatMap((polygon) => (polygon === entry.polygon ? kept : [polygon]));
  }
  const paintClashes = [];
  eachPaintClash((earlier, later, probe) => paintClashes.push(probe));
  invariant(paintClashes.length === 0, `Street ground paint pieces overlap less than a draped step apart at ${paintClashes.slice(0, 5)
    .map((point) => `(${roundCoordinate(point[0])}, ${roundCoordinate(-point[1])})`).join(", ")}${paintClashes.length > 5 ? ` and ${paintClashes.length - 5} more` : ""}`);
  for (const piece of pieces) drape(piece);

  // Curb faces: vertical quads from the road surface to the raised edge, split
  // where the land under them changes triangle.
  for (const edge of faces) {
    const edgeTop = (point) => edge.ha + (edge.hb - edge.ha) * (length(sub(point, edge.a)) / Math.max(1e-9, length(sub(edge.b, edge.a))));
    if (Math.max(edge.ha, edge.hb) - ROAD_TOP_M < 0.01) continue;
    for (const chunk of chunkRange(boxOfPoints([edge.a, edge.b]))) {
      const facets = facetsOf(chunk.id);
      const fractions = [0, 1, ...(edge.red?.spans.flat() ?? [])];
      for (const facet of facets) {
        if (!boxesOverlap(facet.bounds, boxOfPoints([edge.a, edge.b]), 1e-6)) continue;
        fractions.push(...segmentPolygonCrossings(edge.a, edge.b, facet.geometry));
      }
      const unique = [...new Set(fractions.map((value) => Math.round(value * 1e9) / 1e9))].sort((left, right) => left - right);
      for (let index = 1; index < unique.length; index += 1) {
        const p0 = add(edge.a, scale(sub(edge.b, edge.a), unique[index - 1]));
        const p1 = add(edge.a, scale(sub(edge.b, edge.a), unique[index]));
        if (length(sub(p1, p0)) < 0.005) continue;
        const middle = scale(add(p0, p1), 0.5);
        const chunkOfMiddle = chunkId(Math.floor(middle[0] / CHUNK_SIZE_M), Math.floor(-middle[1] / CHUNK_SIZE_M));
        if (chunkOfMiddle !== chunk.id) continue;
        const facet = facets.find((candidate) => inBox(candidate.bounds, middle, 1e-6) && facetElevation(candidate, middle[0], middle[1]).inside);
        if (!facet) continue;
        const mesh = meshFor(lotCurbIndex.contains(add(middle, scale(edge.outward, -0.04))) ? "lot_curb" : "kerb", chunk.id);
        const normal = [edge.outward[0], 0, -edge.outward[1]];
        const offset = mesh.vertices.length / 3;
        const along0 = length(sub(p0, edge.a));
        const along1 = length(sub(p1, edge.a));
        // A lot island's face runs down to the land, under the lot's surface.
        const foot = edge.kind === "island" || edge.kind === "lot_curb" ? ISLAND_FOOT_M : ROAD_TOP_M;
        const corners = [
          [p0, foot, along0],
          [p1, foot, along1],
          [p1, edgeTop(p1), along1],
          [p0, edgeTop(p0), along0],
        ];
        for (const [point, h, along] of corners) {
          const land = facetElevation(facet, point[0], point[1]).elevation;
          mesh.vertices.push(roundCoordinate(point[0]), roundCoordinate(land + h), roundCoordinate(-point[1]));
          mesh.normals.push(...normal.map(roundCoordinate));
          // v from the face's own foot, inside one panel: no sidewalk joint runs along a curb face.
          mesh.uvs.push(roundCoordinate(along / kerb.panel_m), roundCoordinate((h - ROAD_TOP_M) / kerb.panel_m + 0.1));
        }
        pushTriangles(mesh, [offset, offset + 1, offset + 2, offset, offset + 2, offset + 3], normal);
        // Red paint on the face itself, a draped step out from the concrete face.
        const piece = (unique[index - 1] + unique[index]) / 2;
        if (edge.red?.spans.some(([start, end]) => piece >= start && piece <= end)) {
          const paintMesh = meshFor("marking", chunk.id);
          const paintOffset = paintMesh.vertices.length / 3;
          // Stepped out where that stays on this chunk's land (at a chunk seam the end stays put).
          const out = scale(edge.outward, DRAPED_LAYER_STEP_M);
          const onLand = (point) => {
            const [x, y] = [roundCoordinate(point[0]), roundCoordinate(point[1])];
            return facets.some((candidate) => inBox(candidate.bounds, [x, y], 1e-6) && facetElevation(candidate, x, y).inside);
          };
          const q0 = onLand(add(p0, out)) ? add(p0, out) : p0;
          const q1 = onLand(add(p1, out)) ? add(p1, out) : p1;
          for (const [point, h] of [[q0, ROAD_TOP_M], [q1, ROAD_TOP_M], [q1, edgeTop(p1) + lifts.paint_m], [q0, edgeTop(p0) + lifts.paint_m]]) {
            const land = facetElevation(facet, point[0], point[1]).elevation;
            paintMesh.vertices.push(roundCoordinate(point[0]), roundCoordinate(land + h), roundCoordinate(-point[1]));
            paintMesh.normals.push(...normal.map(roundCoordinate));
            paintMesh.uvs.push(...kindUv(STREET_PAINT_KINDS.red_curb, edge.red.wear)().map(roundCoordinate));
          }
          pushTriangles(paintMesh, [paintOffset, paintOffset + 1, paintOffset + 2, paintOffset, paintOffset + 2, paintOffset + 3], normal);
          counts.red_curb_m += length(sub(p1, p0));
        }
      }
    }
  }

  // ---------------------------------------------------------------- records
  const records = new Map();
  for (const mesh of [...meshes.values()].sort((left, right) => compareChunkIds(left.chunk, right.chunk) || left.record.localeCompare(right.record))) {
    if (mesh.indices.length === 0) continue;
    const [prefix, featureKind, materialKey, collisionKind, opaque] = RECORD_KINDS[mesh.record];
    const sourceKeys = [...sources[mesh.record]].sort(compareSourceKeys);
    invariant(sourceKeys.length > 0, `Street ground ${mesh.record} in ${mesh.chunk} has no source`);
    const record = meshRecord({
      objectKey: `${prefix}:${mesh.chunk}`,
      featureKind,
      sourceKeys,
      materialKey,
      mesh,
      collisionKind,
      opaque,
    });
    // Park ground is drawn its lift over the land: what the player's feet and
    // props stand on (VisibleGround), though the land is what collides.
    if (parkLifts.has(materialKey)) record.surface_bias_m = parkLifts.get(materialKey);
    if (!records.has(mesh.chunk)) records.set(mesh.chunk, []);
    records.get(mesh.chunk).push(record);
  }

  // The raised surface under a world point, for placing street-detail items on
  // it: a curb ramp or the raised street ground drawn over everything else, then
  // park ground, then a parking lane.
  const surfaceAt = (xz) => {
    const point = [xz[0], -xz[1]];
    if (notchIndex.contains(point)) {
      for (const notch of notches) {
        if (inBox(notch.box, point) && pointInMultiCheap(notch.piece, point)) {
          return { kind: "street_kerb", material_key: "street_kerb_concrete", source_key: notch.source_key, bias_m: roundCoordinate(heightAt(notch.height, point)) };
        }
      }
    }
    if (!raisedIndex.contains(point)) {
      const park = parkAt(point);
      if (park) return { kind: "street_paint", material_key: park.layer.material, source_key: park.sources[0], bias_m: roundCoordinate(park.lift) };
      // Parking lanes widen the asphalt beyond the frozen road ribbons.
      if (!parkingIndex.contains(point)) return null;
      return { kind: "street_paint", material_key: "street_parking", source_key: nearestRoad(point).road.row.source_key, bias_m: ROAD_TOP_M };
    }
    const near = nearestRoad(point);
    return {
      kind: "street_kerb",
      material_key: lotCurbIndex.contains(point) ? "street_kerb_lot" : plantedIndex.contains(point) ? "street_kerb_planting" : paverIndex.contains(point) ? "street_plaza_pavers" : "street_kerb_concrete",
      source_key: near ? near.road.row.source_key : [...kerbSources][0],
      bias_m: roundCoordinate(top),
    };
  };

  const summary = {
    generator: "tools/lib/street-ground-generation.mjs",
    feature_kinds: STREET_GROUND_FEATURE_KINDS,
    paint_kinds: STREET_PAINT_KINDS,
    wear_cells: STREET_WEAR_CELLS,
    heights_m: {
      road_surface: ROAD_TOP_M,
      sidewalk_top: roundCoordinate(top),
      gutter: roundCoordinate(ROAD_TOP_M + lifts.gutter_m),
      paint: roundCoordinate(ROAD_TOP_M + lifts.paint_m),
    },
    zones: settings.zones.map(({ id }) => id),
    // The rule streets (tools/config/street-ground.json) with ground outside the pilot zones.
    streets: streetZones.map((zone) => zone.rule.id),
    kerbed_roads: [...kerbSources].sort(compareSourceKeys),
    joined_sidewalks: joinedSidewalks.sort(compareSourceKeys),
    counts: {
      crosswalks: counts.crosswalks,
      curb_ramps: counts.curb_ramps,
      stop_bars: counts.stop_bars,
      stall_lines: counts.stall_lines,
      bay_stalls: counts.bays,
      shoulder_stalls: counts.shoulder_stalls,
      lot_stalls: counts.lot_stalls,
      red_curb_m: roundCoordinate(counts.red_curb_m),
      skirt_split_fallbacks: counts.skirt_split_fallbacks,
      grass_top_area_m2: roundCoordinate(multiArea(lawnTop)),
      centerline_m: roundCoordinate(counts.centerline_m),
      raised_area_m2: roundCoordinate(multiArea(bandRaised)),
      planted_area_m2: roundCoordinate(multiArea(plantedTop)),
      plaza_paving_area_m2: roundCoordinate(multiArea(paverTop)),
      parking_lane_area_m2: roundCoordinate(multiArea(parkingSurface)),
      curb_face_m: roundCoordinate(faces.reduce((sum, edge) => sum + length(sub(edge.b, edge.a)), 0)),
      wear_by_cell: Object.fromEntries(Object.entries(STREET_WEAR_CELLS).map(([name, cell]) => [name, counts.wear[cell] ?? 0])),
      park_surface_area_m2: Object.fromEntries(Object.keys(PARK_SURFACE_MATERIALS).map((material) => [material,
        roundCoordinate(parkLayers.filter((entry) => entry.layer.material === material).reduce((sum, entry) => sum + multiArea(entry.polygon), 0))])),
    },
    records: [...records.entries()].sort(([left], [right]) => compareChunkIds(left, right))
      .flatMap(([, list]) => list.map((record) => ({ object_key: record.object_key, triangles: record.indices.length / 3 }))),
  };
  // Plan geometry for the street furniture that stands on and beside this
  // ground (tools/lib/street-furniture-generation.mjs), in the east/north frame.
  const rampIndex = partsIndex("curb ramps", [notchUnion]);
  const site = {
    top_m: roundCoordinate(top),
    walk_width_m: crossings.walk_width_m,
    // Roads with a curb: the curb's offset from the centre line (the wider side,
    // then each side, left of the way's direction first) and what each side has
    // (walk: a sidewalk at the curb, verge: a curb top then grass, none: no curb;
    // the pilot's kerbed roads have a walk on both sides).
    kerb_roads: bandRoads.map((road) => ({
      source_key: road.row.source_key,
      name: road.tags.name ?? null,
      highway: road.tags.highway,
      line: wayLine(road),
      kerb_offset_m: halfWidth(road),
      kerb_offset_left_m: halfWidthSide(road, 1),
      kerb_offset_right_m: halfWidthSide(road, -1),
      sides: kerbRoads.includes(road)
        ? { left: [[0, polylineLength(wayLine(road)), "walk"]], right: [[0, polylineLength(wayLine(road)), "walk"]] }
        : { left: sideStretches(road, 1), right: sideStretches(road, -1) },
    })),
    crosswalks: crosswalks.map((walk) => ({ ...walk })),
    stop_bars: stopBars,
    // OSM parking lots near the pilot: multipolygons in the east/north frame.
    lots: lots.map((object) => ({ source_key: object.row.source_key, geometry: object.geometry })),
    // Plan distance (m) to the carriageway (0 inside it), searched within reach.
    carriagewayDistance: (point, reach = 12) => vehicleIndex.distance(point, reach),
    // Plan distance (m) to a curb ramp (0 inside it), searched within reach.
    rampDistance: (point, reach = 6) => rampIndex.distance(point, reach),
    // On the raised street ground: sidewalk, planting strip or plaza top.
    raised: (point) => raisedIndex.contains(point),
    // A park bed of the given materials under an east/north point: {on, distance to its edge}.
    parkBed,
    parkBedOn,
    // Parking lanes: the roads that have them, with the curb's offset from the
    // centre line on both sides (the frozen ribbon's half width plus the lane).
    // Rule streets add per-side fields: each side's lane (widening) and curb
    // offset, and the stretches [from_m, to_m] along the way where the dated
    // aerial shows cars at that curb.
    parking_lanes: [...new Set([...parkingWidth.keys(), ...ruleRoads.map((road) => road.row.source_key)
      .filter((key) => widenOf.has(key) || ruleOf.get(key).parking[key])])].sort(compareSourceKeys).map((key) => {
      const road = vehicles.find((object) => object.row.source_key === key);
      const pilot = parkingWidth.get(key) ?? 0;
      const widen = widenOf.get(key) ?? { left: 0, right: 0 };
      const stretches = ruleOf.get(key)?.parking[key] ?? null;
      return {
        source_key: key,
        line: wayLine(road),
        ribbon_half_m: ROAD_WIDTHS_M[road.tags.highway] / 2,
        lane_width_m: pilot + Math.max(widen.left, widen.right),
        kerb_offset_m: halfWidth(road),
        lane_width_left_m: pilot + widen.left,
        lane_width_right_m: pilot + widen.right,
        kerb_offset_left_m: halfWidthSide(road, 1),
        kerb_offset_right_m: halfWidthSide(road, -1),
        parked: stretches ? { left: stretches.left ?? [], right: stretches.right ?? [] } : null,
      };
    }),
    // Parking stalls: the entry point on the aisle (or road, or row) edge, the
    // direction into the stall, along the aisle, the stall depth and width, and
    // kind: aisle (painted along a lot aisle), bay (a street-side bay), shoulder
    // (lines across a widened shoulder, entry at the edge line; depth_m is the
    // shoulder's, shallower than a car, so no car is meant to stand in one) or
    // lot_row (a lot rule's row, with its lot_id, row_id and style).
    stalls: stallSlots,
    // Inside an OSM parking lot near the pilot.
    inLot: (point) => lotIndex.contains(point),
    // The lot OSM lacks, for the street clutter's parked cars.
    exception_lots: exceptionLots.map(({ lot, object }) => ({ source_key: lot.source_key, geometry: object.geometry })),
  };
  return { records, summary, surfaceAt, site };
}

function pointInMultiCheap(multi, point) {
  return multi.some((polygon) => pointInPolygon(point, polygon));
}

function pushTriangles(mesh, indices, desiredNormal) {
  const vertex = (index) => mesh.vertices.slice(index * 3, index * 3 + 3);
  for (let offset = 0; offset < indices.length; offset += 3) {
    let [a, b, c] = indices.slice(offset, offset + 3);
    const pa = vertex(a);
    const pb = vertex(b);
    const pc = vertex(c);
    const ab = [pb[0] - pa[0], pb[1] - pa[1], pb[2] - pa[2]];
    const ac = [pc[0] - pa[0], pc[1] - pa[1], pc[2] - pa[2]];
    const normal = [ab[1] * ac[2] - ab[2] * ac[1], ab[2] * ac[0] - ab[0] * ac[2], ab[0] * ac[1] - ab[1] * ac[0]];
    if (Math.hypot(...normal) / 2 < MINIMUM_TRIANGLE_AREA_M2) continue;
    if (normal[0] * desiredNormal[0] + normal[1] * desiredNormal[1] + normal[2] * desiredNormal[2] < 0) [b, c] = [c, b];
    mesh.indices.push(a, b, c);
  }
}
