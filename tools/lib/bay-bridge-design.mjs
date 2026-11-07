// Shared design data for the San Francisco-Oakland Bay Bridge scenery: the
// eastern span (self-anchored suspension span and Skyway), the Yerba Buena
// Island crossing and the western suspension span. The generator builds every
// part from these profiles, proportions and roles so the parts read as one
// bridge. Work in progress: the generator itself is not wired in yet.
//
// Plan geometry comes from the frozen OSM snapshot (data/osm, 2026-08-27),
// projected with tools/lib/coordinates.mjs. "Measured" below means read from
// that snapshot or from a published drawing or fact sheet; every height,
// depth, sag and spacing marked "inferred" is production inference from the
// sources and dated photographs, never a survey value.

// Material roles, carried in each vertex's UV x. The runtime builder owns the
// colours and surface families for these roles.
export const BRIDGE_ROLES = Object.freeze({
  sas_white: 0, // SAS tower, cables, steel box girders: white paint
  concrete: 1, // Skyway, YBI transition structure, ramps, piers, portals
  concrete_dark: 2, // tidal band at pier feet, tunnel reveals
  roadway: 3, // asphalt deck tops
  barrier: 4, // concrete traffic barriers
  steel_silver: 5, // western span towers and truss: aluminium paint
  light_pole: 6, // white lighting masts
  suspender: 7, // suspender ropes
  cable_silver: 8, // western span main cables
  tunnel_void: 9, // dark tunnel interior behind the portals
});

// Occlusion levels, carried with the role in each vertex's UV x as
// role + ROLE_STRIDE * level: how much sky a face sees for its place on the
// structure (an open face 0, under an overhang 1, under the deck 2, a deck's
// underside 3, a slot between tower legs 4). Geometry only, never the sun, so
// the time of day stays free; the runtime builder darkens each level's albedo.
export const ROLE_STRIDE = 16;
export const OCCLUSION = Object.freeze({ open: 0, overhang: 1, under: 2, soffit: 3, slot: 4 });
export const shade = (role, level) => role + ROLE_STRIDE * level;

// Detail classes, carried in each vertex's UV y. Structure is drawn at every
// distance; detail stops at DETAIL_END_M; wires are camera-facing ribbons
// whose coverage falls with distance; far wires stand in for solid detail
// beyond DETAIL_END_M.
export const BRIDGE_CLASSES = Object.freeze({ structure: 0, detail: 1, wire: 2, wire_far: 3 });
export const DETAIL_END_M = 2400;

// Main-line OSM ways (measured), each list ordered from the tunnel's east
// portal through the YBI transition, the suspension span and the Skyway to
// the end of the snapshot. The eastbound ways already run that way; the
// westbound ways run east to west and are reversed when assembled.
export const MAIN_LINE_WAYS = Object.freeze({
  eastbound_east: Object.freeze(["52527662", "1212176124", "237731428"]),
  westbound_east: Object.freeze(["497579295", "929579737", "236348360", "236348361"]),
  tunnel_upper: "11415208",
  tunnel_lower: "50691047",
  west_approach_upper: "23874736",
  west_approach_lower: Object.freeze(["179235221", "52721870"]),
  west_span_upper: "8921938",
  west_span_lower: "661905446",
});

// Self-anchored suspension span (measured from OSM): axis bearing from the
// tower footprint w237735191 (19.42 m along x 13.67 m across), and stations
// along that axis from the tower centre of the pier and crossbeam polygons
// between the twin decks. W2-T1 179.8 m and T1-E2 385.2 m match the published
// 180 m and 385 m spans. There is no crossbeam polygon at +45 m.
export const SAS = Object.freeze({
  tower_way: "237735191",
  tower_center_en: Object.freeze([1097.75, -945.81]),
  axis_bearing_deg: 54.1,
  tower_base_m: Object.freeze({ along: 19.42, across: 13.67 }),
  tower_height_m: 160,
  w2_station_m: -179.8,
  e2_station_m: 385.2,
  east_end_station_m: 419.6,
  crossbeam_stations_m: Object.freeze([
    -134.8, -104.8, -74.8, -44.8, -14.8, 15.1, 75.4, 105.3, 135.2, 165.2, 195.1, 225.1, 255.2, 285.1, 315.1, 345.1,
  ]),
  crossbeam_size_m: Object.freeze({ across: 13.7, along: 10.3 }),
  // Gap between the twin decks, and each deck's extent from its own way
  // (left is north): westbound -14.3..15.9 m, eastbound -21.0..14.0 m with
  // the bike path on the south.
  deck_gap_m: 13.7,
  westbound_extent_m: Object.freeze([-14.3, 15.9]),
  eastbound_extent_m: Object.freeze([-21.0, 14.0]),
  // Inferred: the main-span cable reaches the deck 350 m from the tower (fit
  // carried over from the earlier east span), the back-span cable meets W2
  // still falling (same horizontal tension both sides), the cable planes run
  // from about 1.5 m off the axis at the saddle to the decks' outer edges,
  // and suspender pairs hang every 10 m in those inclined planes.
  main_cable_landing_m: 350,
  saddle_offset_m: 1.5,
  suspender_spacing_m: 10,
});

// Skyway (measured widths from the OSM deck outlines w1006027483 and
// w1000066963; inferred spans and depths): 160 m spans from E2, 14 pier
// pairs, haunched concrete box 5.5 m deep at midspan and 11 m at the piers.
export const SKYWAY = Object.freeze({
  westbound_extent_m: Object.freeze([-13.5, 13.4]),
  eastbound_extent_m: Object.freeze([-18.6, 13.5]),
  span_m: 160,
  pier_pairs: 14,
  depth_midspan_m: 5.5,
  depth_pier_m: 11.0,
});

// Deck-top elevation (m NAVD 88) of the eastern span by east coordinate,
// inferred: about 55 m beside the tower (the dated photographs give 47-56 m,
// the earlier Pier 1 fit 54 m, the published 191 ft clearance more), falling
// along the Skyway to the Oakland touchdown. The snapshot ends at x 3805; the last point carries the
// deck on to a touchdown abutment so the bridge ends in the distance.
export const EAST_DECK_PROFILE = Object.freeze([
  Object.freeze([952, 55.5]),
  Object.freeze([1098, 55.0]),
  Object.freeze([1410, 52.5]),
  Object.freeze([3460, 21.0]),
  Object.freeze([3805, 13.0]),
  Object.freeze([4150, 5.5]),
]);

// YBI transition structure (measured): begin-bridge elevations W line
// (westbound, upper) 59.152 m and E line (eastbound, lower) 51.339 m at the
// tunnel's east portal (Dameron, WBES 2015); W line spans from the portal.
export const YBITS = Object.freeze({
  upper_portal_m: 59.152,
  lower_portal_m: 51.339,
  w_line_spans_m: Object.freeze([21.573, 26.7, 31.7, 36.7, 59.2, 64.4, 69.6, 84.8, 61.62]),
  westbound_width_m: 26.67,
  eastbound_width_m: 25.67,
  bikeway_width_m: 5.6,
});

// Yerba Buena Tunnel portals (measured from the tunnel ways) and the stacked
// deck spacing inside (7.8 m from the YBITS begin elevations).
export const TUNNEL = Object.freeze({
  east_portal_en: Object.freeze([521.6, -1515.6]),
  west_portal_en: Object.freeze([409.9, -1648.2]),
  deck_spacing_m: 7.8,
  // HAER: 540 ft bore, 76-79 ft wide, 58 ft high, 79 ft arches with 21 ft rise.
  bore_width_m: 24,
  bore_height_m: 17.7,
  arch_rise_m: 6.4,
});

// Western suspension span. Stations along the axis (bearing 220.2 deg) from
// the YBI cable bent at the end of the OSM upper deck (325.2, -1745.9): W6
// measured from its OSM footprint (w432712479, 29.2 m across x 5.9 m along);
// the rest stepped by the published spans (704.1 m main, 353.6 m side).
export const WEST_SPAN = Object.freeze({
  axis_start_en: Object.freeze([325.2, -1745.9]),
  axis_bearing_deg: 220.2,
  piers_m: Object.freeze({ w7: 0, w6: 356.8, w5: 1060.9, w4: 1414.5, w3: 1768.1, w2: 2472.2, w1: 2825.8 }),
  snapshot_end_m: 3190,
  // Measured: stiffening truss 66 x 35 ft (HAER). Inferred: panels at the
  // 30 ft suspender band spacing.
  truss_width_m: 20.1,
  truss_depth_m: 10.7,
  panel_m: 9.14,
  lower_deck_drop_m: 7.6,
  // Inferred within the conflicting sources: HAER's 458 and 502 ft read from the
  // base plates 40 ft above low water (outer towers about 152 m, inner about 165 m
  // above the water). The May 2025 profile from TI, through its solved camera
  // (140 mm, 9.8 deg vertical; the YBI owner's fit), puts W6's top at about
  // 153 +/- 8 m.
  tower_top_m: Object.freeze({ w6: 152, w5: 165, w3: 165, w2: 152 }),
  center_anchorage_top_m: 88,
});

// Western span upper-deck elevation by station, inferred: about 61 m at the
// YBI cable bent (the tunnel's upper deck is 59.2 m), rising to a crest at the
// centre anchorage that clears the 220 ft navigation requirement at the main
// spans' centres, and falling to the San Francisco approach. The last point
// carries the deck on behind the skyline billboard.
export const WEST_DECK_PROFILE = Object.freeze([
  Object.freeze([0, 61.0]),
  Object.freeze([356.8, 70.5]),
  Object.freeze([709, 79.0]),
  Object.freeze([1060.9, 82.0]),
  Object.freeze([1414.5, 83.5]),
  Object.freeze([1768.1, 82.0]),
  Object.freeze([2120, 79.0]),
  Object.freeze([2472.2, 72.0]),
  Object.freeze([2825.8, 63.0]),
  Object.freeze([3190, 48.0]),
  Object.freeze([3440, 40.0]),
]);

// Bridge-tagged ramps and local road bridges on YBI (measured ways); their
// elevations come from the deck or the ground at each end.
export const YBI_RAMP_WAYS = Object.freeze([
  "322962944", "1178201287", "35536683", "839972873", "329394287", "1034687990", "1034687993",
  "36332873", "255330060", "255330063", "11414755", "662177841", "119057701",
]);
