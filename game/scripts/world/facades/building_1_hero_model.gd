class_name Building1HeroModel
extends RefCounted

const CONFIG_PATH := "res://game/resources/facades/building_1_hero_model.json"
const BAR_CONFIG_PATH := "res://game/resources/facades/building_1_public_front_believability.json"
const MAIN_CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const TOWER_CHUNK_PATH := "res://generated/world/chunks/x_0__z_2.json"
const BUILDING_SOURCE_KEY := "r16681702"
const BUILDING_WALL_KEY := "building:r16681702:wall"
const BUILDING_ROOF_KEY := "building:r16681702:roof"
const TOWER_SOURCE_KEY := "w1222720021"
const TOWER_WALL_KEY := "building:w1222720021:wall"
const TOWER_ROOF_KEY := "building:w1222720021:roof"
const TARGET_KEYS := [BUILDING_WALL_KEY, BUILDING_ROOF_KEY, TOWER_WALL_KEY, TOWER_ROOF_KEY]
const CRESCENT_FIELD_RUNS := [21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37]
const NORTH_WING_WINDOW_RUNS := [9, 10, 11, 12, 13, 14, 15, 16]
const SOUTH_WING_WINDOW_RUNS := [44, 45, 46, 47, 48, 49, 50, 51]
# Runs 93-95 belong to the two-tier north lower ring (Sep 2025 frontal north
# view, nodes 0-4); the three-storey north wing starts at run 96.
const NORTH_FACE_WINDOW_RUNS := [96]
const ENTRANCE_BAYS := [4, 5, 6]
const JUNCTION_WINDOW_RUNS := [43]
const NORTH_JUNCTION_WINDOW_RUNS := [17]
const PAVILION_ENTRY_KEYS := ["recess_half_width", "door_half_width", "height", "transom_height", "jamb_width", "jamb_front", "hood_overhang", "hood_height", "hood_front"]
# Frozen stepped west ends of both wings: a projecting centre face, two flanks
# and the recessed corner bay. Identity is rechecked against actual coordinates.
const NORTH_PAVILION_RUNS := {"center_runs": [6], "flank_runs": [[3, 4], [8]], "corner_runs": [0, 1]}
const SOUTH_PAVILION_RUNS := {"center_runs": [54, 55, 56], "flank_runs": [[52], [58]], "corner_runs": [60]}
# Catalog protected scope: the austere rear and inner returns keep their exact
# faces, original material and collision. Only the released lower-ribbon hosts
# below carry relief, and only the ribbon.
const PROTECTED_RUNS := [70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109]
# SE face of the south wing, released for its narrow-window and ribbon assembly.
const SE_FACE_RUNS := [63, 64, 65, 66, 67, 68, 69]
# Podium runs carrying the lower ribbon. The dated 2023 rear view shows it on
# runs 70-77 and 80-83; across 78-79, hidden there by an unmapped annex, it
# continues as released production inference. Later runs pass the silhouette
# and stay unreleased.
const REAR_RIBBON_HOST_CHAINS := [[70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83]]
# SE shoulder block carrying the observed small and tall drum-end openings.
const SE_SHOULDER_RUNS := [69, 70]
## Inward face of a two-sided setback wall sits this far behind the outward
## face, so the two never tie in depth (or in a ray probe).
const SETBACK_INWARD_FACE_INSET_M := 0.02
## A set-down band's riser and roof edge follow the chain without its source runs
## shorter than this (_simplified_path).
const FRONT_STEP_MIN_SEGMENT_M := 1.0
## How far outside a set-down band's walls its roof cut reaches (_setback_cuts).
const SETBACK_CUT_OUTER_REACH_M := 1.5
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1
const VISUAL_REVIEW_STATUS := "pending_independent_original_detail_review"

# Original resources stay on protected runs, inner tier faces and the tower;
# Building 2 and calibration code share them, so this pass does not edit them.
const WALL_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres")
const TRIM_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_light_trim.tres")
const GLASS_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres")
const BRONZE_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_bronze.tres")
const ROOF_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_roof_metal.tres")
const TOWER_ROOF_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_tower_roof_pale.tres")
const REVEAL_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_reveal_shadow.tres")
# Public-only variants for the crescent, wings and pavilions.
const PUBLIC_WALL_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_public_stucco_field.tres")
const PUBLIC_TRIM_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_public_stucco_trim.tres")
const PUBLIC_BASE_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_public_stucco_base.tres")
const PUBLIC_FRAME_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_public_window_metal.tres")
const PUBLIC_GLASS_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_public_glazing.tres")
const EMBLEM_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_emblem_blue.tres")
## The public stucco carrying fine linear detail as a mipmapped pattern over its paint
## (_append_pattern_band): incised lines, the canopy fascia's rolls and dentils.
const PUBLIC_TRIM_LINES_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_public_stucco_trim_lines.tres")
const PUBLIC_FIELD_LINES_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_public_stucco_field_lines.tres")
## The door groups' and grilles' golden bronze, and the pavilions' light steel windows
## (the owner's 2026-11-20 photos); Building 1's original bronze stays with the tower.
const PUBLIC_BRONZE_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_public_bronze.tres")
const PUBLIC_LIGHT_STEEL_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_public_light_steel.tres")
## The crescent piers' reeds stop this much lower each, out from the middle reed.
const PIER_REED_TOP_STEP_M := 0.04
## The pavilions' emblem relief, white as photographed.
const PUBLIC_RELIEF_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_public_relief_white.tres")
## The narrow grooves between a pier's reeds: the sky reaches little of them, so they
## stay dark in shade as the photographed flutes do, with or without screen-space
## occlusion.
const PUBLIC_GROOVE_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_public_stucco_groove.tres")
## The concourse behind the crescent (owner, 2026-11-19): its door group opens, the
## exterior faces that stood inside it are cut, and its node rides with the wall.
const INTERIOR := preload("res://game/scripts/world/facades/building_1_interior.gd")
## The inner rings of the footprint (runs 97-109: a sliver and the tower's hole),
## enclosed in the central tier; the interior's plan cuts them.
const INNER_RING_FIRST_RUN := 97


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in TARGET_KEYS


static func build_record(record: Dictionary) -> Dictionary:
	var config := _json(CONFIG_PATH)
	var bar_config := _json(BAR_CONFIG_PATH)
	if not _config_valid(config) or not _bar_config_valid(bar_config) or not _record_valid(record):
		return _failure("building_1_hero_source_contract", "Building 1 hero source identity, geometry, or configuration does not match.", record)
	match str(record.object_key):
		BUILDING_WALL_KEY:
			return _build_building_wall(record, config, bar_config)
		BUILDING_ROOF_KEY:
			var wall_record := _record_from_chunk(MAIN_CHUNK_PATH, BUILDING_WALL_KEY)
			if not _record_valid(wall_record):
				return _failure("building_1_hero_wall_source", "Building 1 wall source could not be resolved for stepped roofs.", record)
			return _build_building_roof(record, wall_record, config, bar_config)
		TOWER_WALL_KEY:
			return _build_tower_wall(record, config, bar_config.geometry_production_inference_m as Dictionary)
		TOWER_ROOF_KEY:
			return _build_tower_roof(record, config, bar_config.geometry_production_inference_m as Dictionary)
	return _failure("building_1_hero_target", "Unexpected Building 1 hero target.", record)


static func _build_building_wall(record: Dictionary, config: Dictionary, bar_config: Dictionary) -> Dictionary:
	var vertical := config.vertical_production_inference_m as Dictionary
	var chains := config.massing_chains as Dictionary
	var schedule := config.facade_schedule as Dictionary
	var front := bar_config.geometry_production_inference_m as Dictionary
	var two_y := float(vertical.two_story_roof_y)
	var three_y := float(vertical.three_story_roof_y)
	var four_y := float(vertical.four_story_roof_y)
	var north_pavilion := schedule.north_pavilion as Dictionary
	var south_pavilion := schedule.south_pavilion as Dictionary
	if not _pavilion_identity_valid(record, north_pavilion) or not _pavilion_identity_valid(record, south_pavilion):
		return _failure("building_1_hero_pavilion_identity", "Building 1 pavilion runs no longer bind to the frozen stepped west ends.", record)
	if _crown_rise(front, three_y) > float(front.pavilion_crown_max_rise_above_roof) + 0.0001:
		return _failure("building_1_hero_crown_rise", "Building 1 pavilion crowns exceed the approved rise above the public roof.", record)
	var se_runs := _int_array(schedule.se_face_runs)
	var ribbon := front.podium_ribbon as Dictionary
	var se_ribbon := front.se_ribbon as Dictionary
	if not _rear_hosts_valid(record, se_runs, schedule.rear_ribbon_host_chains as Array) or float(ribbon.top) + float(ribbon.head_height) >= two_y or float(se_ribbon.top) + float(se_ribbon.head_height) >= two_y:
		return _failure("building_1_hero_rear_ribbon_identity", "Building 1 SE and rear ribbon hosts no longer bind to the frozen podium below the blank drum.", record)
	var drum_openings := front.drum_end_openings as Dictionary
	var shoulder := front.se_shoulder as Dictionary
	var shoulder_runs := _int_array(shoulder.runs as Array)
	var shoulder_frame := _span_frame(record, shoulder_runs, 0.0, _chain_length(record, shoulder_runs))
	if shoulder_runs != _int_array(SE_SHOULDER_RUNS) or not _drum_openings_fit(shoulder_frame, _chain_length(record, shoulder_runs), drum_openings, front.wing_window_style as Dictionary, two_y, float(shoulder.top_y)):
		return _failure("building_1_hero_drum_opening_identity", "Building 1 drum-end openings no longer fit the SE shoulder block on runs 69-70.", record)
	var north_runs := _int_array(chains.north_three_story_runs)
	var central_runs := _int_array(chains.central_four_story_runs)
	var south_runs := _int_array(chains.south_three_story_runs)
	var north_depth := float(vertical.north_wing_inward_depth)
	var central_depth := float(vertical.central_inward_depth)
	# The concourse: its plan cuts the exterior faces that stood inside it, and its
	# open door group cuts the front wall (_door_span).
	var interior := _interior_plan(record, config, front)
	if not bool(interior.get("ok", false)):
		return _failure("building_1_interior_plan", str(interior.get("message", "Building 1 interior plan failed.")), record)
	var interior_cuts: Array = [interior.cut_polygon]
	var hole := interior.door as Dictionary
	var original := _bucket()
	var buckets := {
		"wall": _bucket(),
		"trim": _bucket(),
		"base": _bucket(),
		"frame": _bucket(),
		"glass": _bucket(),
		"reveal": _bucket(),
		"bronze": _bucket(),
		"emblem": _bucket(),
		"reveal_depth": _bucket(),
		"window_settings": {"extra": float(front.window_reveal_extra_depth), "clearance": float(front.window_reveal_min_clearance_m)},
		"lines_trim": _bucket(),
		"lines_field": _bucket(),
		"public_bronze": _bucket(),
		"light_steel": _bucket(),
		"relief": _bucket(),
		"groove": _bucket(),
	}
	var collision := _bucket()

	# Exact source walls and stepped tiers keep their outer geometry, collision
	# and emission order. Public outer faces take the public coating; protected
	# runs and inner tier faces keep the original material. The 11 m wing tiers'
	# inner partitions are clipped to the frozen footprint; the central tier that
	# carries the separate tower is unchanged.
	var tier_clip := _tier_clip(record)
	var north_ring := front.north_ring as Dictionary
	var terrace_y := float(north_ring.terrace_y)
	var lowered := {}
	for chain_value in north_ring.chains as Array:
		for run_value in chain_value as Array:
			lowered[int(run_value)] = terrace_y
	var rear_ring := front.rear_ring as Dictionary
	for run_value in rear_ring.runs as Array:
		lowered[int(run_value)] = float(rear_ring.terrace_y)
	_append_exact_base_walls(buckets.wall, original, collision, record, two_y, lowered, hole, interior_cuts)
	# Set-down front bands (the owner's 2026-11-20 photos): the crescent's front block
	# under the taller central block, and the wings' two-storey forecourt faces before
	# their set-back third storey. Each strip skips those outer faces; the step draws
	# them to their own top and the riser behind (_append_front_step).
	var block := front.crescent_block as Dictionary
	var block_runs := _int_array(block.runs as Array)
	var block_depth := float(block.depth_m)
	var block_roof := float(block.roof_y)
	var wing_setback := front.wing_setback as Dictionary
	var north_setback_runs := _int_array(wing_setback.north_runs as Array)
	var south_setback_runs := _int_array(wing_setback.south_runs as Array)
	var wing_face_top := float(wing_setback.face_top_y)
	var wing_step := float(wing_setback.setback)
	var north_skip := {}
	for run_index in north_setback_runs:
		north_skip[run_index] = true
	var central_skip := {}
	for run_index in block_runs:
		central_skip[run_index] = true
	# Junction towers about a bay wide at each end of the crescent, their tops just
	# over its coping with only the wings' height behind them, and a plain bay at the
	# crescent's height between each tower and the end pier (the owner's 2026-11-20
	# south-end and north-end views).
	var towers := front.junction_towers as Dictionary
	var tower_top := float(towers.top_y)
	var tower_depth := float(towers.depth_m)
	var tower_segment := float(towers.min_segment_m)
	var north_tower_runs := _int_array(towers.north_tower_runs as Array)
	var north_bay_runs := _int_array(towers.north_plain_bay_runs as Array)
	var south_tower_runs := _int_array(towers.south_tower_runs as Array)
	for run_index in north_tower_runs + north_bay_runs:
		north_skip[run_index] = true
	# Tier partitions and the north wing's end at the junction stood inside the hall.
	_append_strip_walls(buckets.wall, original, collision, record, north_runs, two_y, three_y, north_depth, tier_clip, north_skip, interior_cuts, true)
	_append_front_step(buckets.wall, collision, record, north_setback_runs, two_y, wing_face_top, three_y, wing_step, true, true)
	_append_front_step(buckets.wall, collision, record, north_tower_runs, two_y, tower_top, three_y, tower_depth, true, true, tower_segment)
	_append_front_step(buckets.wall, collision, record, north_bay_runs, two_y, block_roof, three_y, float(towers.north_plain_bay_depth_m), true, false)
	# The central block stands behind the crescent and its plain south bay only; the
	# south junction is a tower before a three-storey strip like the wings'.
	# The taller central block ends north of the crescent's south bays, whose block
	# keeps the front block's height through its depth: from the forecourt the photos
	# show sky beside the south junction tower, not a taller mass.
	var high_runs := _int_array(block.four_storey_runs as Array)
	var central_main := central_runs.slice(0, central_runs.find(south_tower_runs[0]))
	var central_high := central_main.slice(0, central_main.find(high_runs[high_runs.size() - 1]) + 1)
	var central_low := central_main.slice(central_high.size())
	_append_strip_walls(buckets.wall, original, collision, record, central_high, two_y, four_y, central_depth, {}, central_skip, interior_cuts, false, Vector2(block_depth, block_roof), Vector2(block_depth, block_roof))
	_append_strip_walls(buckets.wall, original, collision, record, central_low, two_y, block_roof, central_depth, {}, central_skip, interior_cuts)
	var block_step := _append_front_step(buckets.wall, collision, record, central_high, two_y, block_roof, four_y, block_depth, false, false)
	_append_front_step(buckets.wall, collision, record, central_low, two_y, block_roof, block_roof, block_depth, false, false)
	var tower_skip := {}
	for run_index in south_tower_runs:
		tower_skip[run_index] = true
	_append_strip_walls(buckets.wall, original, collision, record, south_tower_runs, two_y, three_y, float(vertical.south_wing_inward_depth), {}, tower_skip, interior_cuts)
	_append_front_step(buckets.wall, collision, record, south_tower_runs, two_y, tower_top, three_y, tower_depth, true, true, tower_segment)
	var se_setback := front.se_setback as Dictionary
	var skip_outer := {}
	for run_value in se_setback.skip_outer_runs as Array:
		skip_outer[int(run_value)] = true
	for run_index in south_setback_runs:
		skip_outer[run_index] = true
	var se_cuts := _setback_cuts(record, [se_setback.runs], float(se_setback.setback))
	_append_strip_walls(buckets.wall, original, collision, record, south_runs, two_y, three_y, float(vertical.south_wing_inward_depth), tier_clip, skip_outer, se_cuts)
	_append_front_step(buckets.wall, collision, record, south_setback_runs, two_y, wing_face_top, three_y, wing_step, false, true)
	_append_projecting_base(buckets.base, collision, record, central_runs, front, hole)

	# Everything below appends after the accepted collision prefix.
	# Crescent: rusticated projecting base, eleven pier-framed two-story bays and
	# three glazed-bronze entrance groups under the bays the dated view shows, the
	# middle one open into the concourse.
	var field_runs := _int_array(schedule.crescent_field_runs)
	var crescent := _crescent_layout(record, field_runs, int(schedule.central_window_count), front)
	# The door's chain metre (hole.center_m) is measured along the crescent's field
	# runs; the courses run along the central chain, so it is moved onto that chain.
	var field_at := central_runs.find(field_runs[0])
	if field_at < 0 or central_runs.slice(field_at, field_at + field_runs.size()) != field_runs:
		return _failure("building_1_hero_door_chain", "Building 1's crescent field runs no longer lie in order on its central chain, so the door's place on the base courses is unknown.", record)
	var central_hole := hole.duplicate()
	central_hole["center_m"] = float(hole.center_m) + _chain_length(record, central_runs.slice(0, field_at))
	_append_base_rustication(buckets.base, record, central_runs, front, central_hole, _ground_window_gaps(crescent, schedule.entrance_bays as Array, front))
	_append_crescent_bays(buckets, record, field_runs, crescent, front)
	_append_entry_composition(buckets, collision, _entry_frames(record, field_runs, crescent, schedule.entrance_bays as Array, front), int(schedule.doors_per_entrance_group), front, int(hole.bay))
	_append_ground_floor_windows(buckets, record, field_runs, crescent, schedule.entrance_bays as Array, front)
	_append_round_piers(buckets, collision, record, field_runs, crescent, front)
	_append_junction_windows(buckets, record, schedule.junction_windows as Array, front)

	# The wings' forecourt faces and the pavilions' flanks have two window rows (the
	# owner's 2026-11-20 photos); the unphotographed north face and north junction keep
	# the older three-floor schedule.
	var floors := front.window_floors as Array
	var wing_floors := front.wing_window_floors as Array
	var wing_style := front.wing_window_style as Dictionary
	var wing_doors := front.wing_doors as Dictionary
	_append_wing_facade(buckets, record, _int_array(schedule.north_wing_window_runs), int(schedule.upper_windows_per_wing), int(schedule.lower_windows_per_wing), wing_floors, front, int(wing_doors.north_index))
	_append_wing_facade(buckets, record, _int_array(schedule.south_wing_window_runs), int(schedule.upper_windows_per_wing), int(schedule.lower_windows_per_wing), wing_floors, front, int(wing_doors.south_index))
	var north_face := _int_array(schedule.north_face_window_runs)
	var north_face_centers := _evenly_spaced(_chain_length(record, north_face), int(schedule.north_face_windows_per_floor), float(front.north_face_window_margin_m))
	_append_window_grid(buckets, record, north_face, north_face_centers, float(front.north_face_window_width), floors, wing_style)
	_append_north_junction_bays(buckets, record, schedule.north_junction_windows as Array, floors, wing_style)
	_append_pavilion(buckets, collision, record, north_pavilion, wing_floors, front, "north_pavilion")
	_append_pavilion(buckets, collision, record, south_pavilion, wing_floors, front, "south_pavilion")

	# SE face and the visible podium (dated 2023 rear view): one lower ribbon
	# wraps from the SE face across the bound rear hosts, butting the protected
	# seam pier. Above the SE ribbon, a podium-line string course and one narrow
	# window over each bay.
	var seam_width := float(front.junction_pier_width)
	var se_end := _chain_length(record, se_runs) - seam_width
	var se_start := float(se_ribbon.end_inset_m)
	var se_layout := _ribbon_layout(se_start, se_end, true, false, se_ribbon)
	var se_windows: Array[float] = []
	for bay in int(se_layout.bays):
		se_windows.append(float(se_layout.first) + float(se_layout.pitch) * (float(bay) + 0.5))
	var se_y := front.se_narrow_window_y as Array
	var se_floor := [{"bottom": float(se_y[0]), "top": float(se_y[1]), "rows": int(front.se_narrow_window_rows)}]
	# The SE upper tier sits back behind a railed terrace (Nov 2025 SE view);
	# its narrow windows follow the setback face and carry stepped hoods.
	var se_style := wing_style.duplicate()
	se_style["setback_m"] = float(se_setback.setback)
	se_style["stepped_hood"] = true
	_append_window_grid(buckets, record, se_runs, se_windows, float(front.se_narrow_window_width), se_floor, se_style)
	var string_course := front.se_podium_string_course as Array
	_append_path_band(buckets.trim, _chain_points(record, se_runs, se_start, se_end), float(string_course[0]), float(string_course[1]), float(string_course[2]), -0.03)
	_append_ribbon(buckets, record, se_runs, se_start, se_end, true, false, se_ribbon)
	var rear_chains := schedule.rear_ribbon_host_chains as Array
	var rear_hosts: Array[int] = []
	for chain_index in rear_chains.size():
		var host := _int_array(rear_chains[chain_index] as Array)
		rear_hosts.append_array(host)
		# The first host chain continues the SE ribbon past the seam pier.
		_append_ribbon(buckets, record, host, 0.0, _chain_length(record, host), chain_index > 0, true, ribbon)
	# Rear podium edge (ROOT release of runs 70-92, 2026-10-22; dated 2023 rear
	# view): a coping course and a pipe guardrail where the one-storey podium
	# roof meets its exact rear walls, both solid because the roof is reachable.
	# Rear podium carries the north ring's terrace (ROOT 2026-10-22): a railed
	# terrace with coping and the blank drum continued down to it on a setback
	# wall. The ribbon sits where the dated 2023 rear view places it in the
	# podium height (below 0.43, ribbon 0.33, above 0.24).
	var podium_edge := front.podium_edge as Dictionary
	var rear_runs := _int_array(rear_ring.runs as Array)
	var rear_outer := _chain_points(record, rear_runs, 0.0, _chain_length(record, rear_runs))
	var rear_terrace := float(rear_ring.terrace_y)
	_append_setback_storey(original, original, collision, rear_outer, _offset_path(rear_outer, float(rear_ring.setback)), rear_terrace, two_y, true)
	var rear_edge := podium_edge.duplicate()
	rear_edge["coping"] = north_ring.terrace_coping
	_append_podium_edge(buckets.trim, collision, rear_outer, rear_edge, rear_terrace, true)
	var band_runs := _int_array(rear_ring.band_runs as Array)
	if not band_runs.is_empty():
		var ring_band := north_ring.band as Array
		_append_path_band(buckets.trim, _chain_points(record, band_runs, 0.0, _chain_length(record, band_runs)), float(ring_band[0]), float(ring_band[1]), float(ring_band[2]), -0.03)
	# Semi-basement windows under each rear ribbon bay (Sep 2025 north view
	# family, continued round the podium).
	var semi := front.rear_semi_window as Dictionary
	for chain_index in rear_chains.size():
		var host := _int_array(rear_chains[chain_index] as Array)
		var layout := _ribbon_layout(0.0, _chain_length(record, host), chain_index > 0, true, ribbon)
		var semi_centers: Array[float] = []
		for bay in int(layout.bays):
			semi_centers.append(float(layout.first) + float(layout.pitch) * (float(bay) + 0.5))
		_append_window_grid(buckets, record, host, semi_centers, float(semi.width), [{"bottom": float(semi.bottom), "top": float(semi.top), "rows": int(semi.rows)}], wing_style, int(semi.columns))

	# North lower ring (Sep 2025 frontal north view; L1/L2): semi-basement and
	# grouped main-floor bays between piers below a band course, a railed
	# terrace, and an upper floor set back behind it with stepped-hood windows,
	# a frieze and a thin cornice. A taller junction pylon stands at node 0.
	_append_north_ring(buckets, original, collision, record, north_ring, front.north_pylon as Dictionary, podium_edge, wing_style, two_y)
	# SE upper tier setback and the shoulder block stepping down from the drum's
	# south end (Nov 2025 SE view, 2023 rear view). The observed small and tall
	# openings, previously on the drum join behind it, sit on the shoulder face.
	var se_outer := _chain_points(record, _int_array(se_setback.runs as Array), 0.0, _chain_length(record, _int_array(se_setback.runs as Array)))
	var se_inner := _offset_path(se_outer, float(se_setback.setback))
	_append_setback_storey(buckets.wall, buckets.wall, collision, se_outer, se_inner, two_y, three_y, false, true)
	_append_podium_edge(buckets.trim, collision, se_outer, podium_edge, two_y, false)
	_append_se_shoulder(buckets, collision, record, front.se_shoulder as Dictionary, drum_openings, wing_style, float(se_setback.setback), two_y, three_y)

	# Flat copings with three incised lines (the owner's 2026-11-20 photos) close the
	# wing tiers and the pavilions' flanks, stopping at each pavilion's centre face,
	# whose crown rises plain above the flank roofs. The set-down wing faces carry the
	# same coping at their own top and again on the set-back storey. The crescent's
	# front block carries its attic frieze and coping; the central block behind it and
	# the south junction a flat coping. Plinths ground the wing and pavilion walls;
	# piers stand at the two protected-run seams.
	var cornice_back := float(front.cornice_back)
	var inner_trim := float(front.cornice_inner_trim)
	var butt_trim := float(front.cornice_butt_trim)
	var flat_coping := front.flat_coping as Dictionary
	var wing_top := three_y + float(flat_coping.top_above_roof)
	var central_top := four_y + float(flat_coping.top_above_roof)
	var lines := buckets.lines_trim as Dictionary
	var north_gap := _pavilion_face_span(record, north_runs, north_pavilion)
	var north_notch := _run_span(record, north_runs, north_setback_runs)
	var north_path := _chain_points(record, north_runs, 0.0, north_gap.x)
	var north_cap := _strip_cap(record, north_runs[0], true, north_depth - inner_trim)
	_prepend_point(north_path, north_cap.point as Vector3, north_cap.normal as Vector3)
	_append_flat_coping(buckets.trim, lines, north_path, wing_top, flat_coping, cornice_back)
	_append_flat_coping(buckets.trim, lines, _chain_points(record, north_runs, north_gap.y, north_notch.x), wing_top, flat_coping, cornice_back)
	var tower_coping_top := tower_top + float(flat_coping.top_above_roof)
	for tower_runs: Array[int] in [north_tower_runs, south_tower_runs]:
		var tower_outer := _simplified_path(_chain_points(record, tower_runs, 0.0, _chain_length(record, tower_runs)), tower_segment)
		_append_flat_coping(buckets.trim, lines, _loop_path(tower_outer, _offset_path(tower_outer, tower_depth)), tower_coping_top, flat_coping, cornice_back)
	for notch_runs: Array[int] in [north_setback_runs, south_setback_runs]:
		var notch_face := _chain_points(record, notch_runs, 0.0, _chain_length(record, notch_runs))
		_append_flat_coping(buckets.trim, lines, notch_face, wing_face_top, flat_coping, cornice_back)
		_append_flat_coping(buckets.trim, lines, _offset_path(notch_face, wing_step), wing_top, flat_coping, cornice_back)
	# The attic runs over the plain north bay too, ending against the towers' sides.
	var attic_runs: Array[int] = []
	attic_runs.append_array(north_bay_runs)
	attic_runs.append_array(block_runs)
	var block_face := _chain_points(record, attic_runs, 0.0, _chain_length(record, attic_runs))
	_append_crescent_attic(buckets, block_face, block_face, front.crescent_attic as Dictionary, cornice_back)
	# The central block's parapet: its north cap behind the step, the riser, the
	# notch's south wall, the south junction's faces and its south cap.
	var riser := block_step.inner as Dictionary
	var central_path := {"points": [], "normals": []}
	var central_first := _strip_cap(record, central_runs[0], true, central_depth - inner_trim)
	_append_point(central_path, central_first.point as Vector3, central_first.normal as Vector3)
	(central_path.points as Array).append_array(riser.points as Array)
	(central_path.normals as Array).append_array(riser.normals as Array)
	var central_last := _strip_cap(record, central_high[central_high.size() - 1], false, central_depth - inner_trim)
	_append_point(central_path, central_last.point as Vector3, central_last.normal as Vector3)
	_append_flat_coping(buckets.trim, lines, central_path, central_top, flat_coping, cornice_back)
	var se_first := int((se_setback.runs as Array)[0])
	var south_front_runs: Array[int] = []
	for run_index in south_runs:
		if run_index < se_first:
			south_front_runs.append(run_index)
	var south_gap := _pavilion_face_span(record, south_front_runs, south_pavilion)
	var south_notch := _run_span(record, south_front_runs, south_setback_runs)
	_append_flat_coping(buckets.trim, lines, _chain_points(record, south_front_runs, south_notch.y, south_gap.x), wing_top, flat_coping, cornice_back)
	var south_path := _chain_points(record, south_front_runs, south_gap.y, _chain_length(record, south_front_runs))
	# Turn in along the notch to the setback face, then follow it to the shoulder.
	var notch_normal := _flat_direction(se_outer.points[0] as Vector3, se_inner.points[0] as Vector3).cross(Vector3.UP)
	if notch_normal.dot(_run_frame(record, south_front_runs[south_front_runs.size() - 1]).tangent as Vector3) < 0.0:
		notch_normal = -notch_normal
	_append_point(south_path, se_inner.points[0] as Vector3, notch_normal)
	for index in range(1, (se_inner.points as Array).size()):
		_append_point(south_path, se_inner.points[index] as Vector3, se_inner.normals[index - 1] as Vector3)
	_append_flat_coping(buckets.trim, lines, south_path, wing_top, flat_coping, cornice_back)
	# Rear drum banding (dated 2023 rear view): a raised coping course at the
	# parapet and three Art Deco speed lines below it, following the central
	# tier's exact rear (inner) face. Visual relief only, high above any
	# walkable surface; the face, its material and collision are unchanged.
	var drum_banding_on_rear_outline := _append_drum_banding(buckets.trim, record, central_runs, central_depth, front.drum_banding as Dictionary)
	if not drum_banding_on_rear_outline:
		push_warning("Building 1 hero: the drum's rear outline did not resolve; the rear drum banding was omitted.")
	var seams := schedule.protected_seam_piers as Dictionary
	_append_seam_pier(buckets.trim, collision, record, int(seams.north_run_start), true, front)
	_append_seam_pier(buckets.trim, collision, record, int(seams.south_run_end), false, front)
	var seam_trim := float(front.plinth_seam_trim)
	_append_plinth(buckets.base, record, north_runs, seam_trim, butt_trim, [_pavilion_door_gap(record, north_runs, north_pavilion, front)], front)
	_append_plinth(buckets.base, record, south_runs, 0.0, seam_trim, [_pavilion_door_gap(record, south_runs, south_pavilion, front)], front)

	var root := _hero_root("Building1HeroWall", record, "building_wall")
	var specs: Array[Dictionary] = [
		{"name": "HeroOriginalIvory", "bucket": original, "material": WALL_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroPublicStucco", "bucket": buckets.wall, "material": PUBLIC_WALL_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroPublicBase", "bucket": buckets.base, "material": PUBLIC_BASE_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroPublicTrim", "bucket": buckets.trim, "material": PUBLIC_TRIM_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroEntryReveals", "bucket": buckets.reveal, "material": REVEAL_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroGlazing", "bucket": buckets.glass, "material": PUBLIC_GLASS_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroWindowMetal", "bucket": buckets.frame, "material": PUBLIC_FRAME_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroBronze", "bucket": buckets.bronze, "material": BRONZE_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroEmblemEnamel", "bucket": buckets.emblem, "material": EMBLEM_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroWindowRevealDepth", "bucket": buckets.reveal_depth, "material": PUBLIC_TRIM_MATERIAL, "layers": RENDER_BUILDING_WALL},
	]
	specs.append({"name": "HeroIncisedLinesTrim", "bucket": buckets.lines_trim, "material": PUBLIC_TRIM_LINES_MATERIAL, "layers": RENDER_BUILDING_WALL})
	specs.append({"name": "HeroIncisedLinesField", "bucket": buckets.lines_field, "material": PUBLIC_FIELD_LINES_MATERIAL, "layers": RENDER_BUILDING_WALL})
	specs.append({"name": "HeroPublicBronze", "bucket": buckets.public_bronze, "material": PUBLIC_BRONZE_MATERIAL, "layers": RENDER_BUILDING_WALL})
	specs.append({"name": "HeroLightSteel", "bucket": buckets.light_steel, "material": PUBLIC_LIGHT_STEEL_MATERIAL, "layers": RENDER_BUILDING_WALL})
	specs.append({"name": "HeroEmblemRelief", "bucket": buckets.relief, "material": PUBLIC_RELIEF_MATERIAL, "layers": RENDER_BUILDING_WALL})
	specs.append({"name": "HeroReedGrooves", "bucket": buckets.groove, "material": PUBLIC_GROOVE_MATERIAL, "layers": RENDER_BUILDING_WALL})
	var crescent_style := front.crescent_window_style as Dictionary
	var metadata := _common_metadata(config, record, "building_wall")
	metadata.merge({
		"exact_outer_and_inner_run_count": 110,
		"protected_runs_original_faces_and_material": true,
		"public_family_pass_id": str(bar_config.pass_id),
		"public_front_believability_config_path": BAR_CONFIG_PATH,
		"central_window_count": int(schedule.central_window_count),
		"central_lights_per_window": int(schedule.central_lights_per_window),
		"crescent_pier_count": int(schedule.central_window_count) + 1,
		"crescent_reeds_per_pier": int(front.crescent_pier_reeds),
		"crescent_window_glass_width_m": float(crescent.glass),
		"crescent_bay_pitch_m": float(crescent.pitch),
		"upper_windows_per_wing": int(schedule.upper_windows_per_wing),
		"upper_lights_per_window": int(schedule.upper_lights_per_window),
		"lower_windows_per_wing": int(schedule.lower_windows_per_wing),
		"lower_lights_per_window": int(schedule.lower_lights_per_window),
		"north_face_windows_per_floor": int(schedule.north_face_windows_per_floor),
		"pavilion_runs_bound_to_stepped_west_ends": true,
		"tall_windows_per_pavilion": int(schedule.tall_windows_per_end),
		"lights_per_tall_pavilion_window": int(schedule.lights_per_tall_end_window),
		"pavilion_emblem_count": 2,
		"south_pavilion_small_windows_by_emblem": 2,
		"pavilion_crowns_solid_with_congruent_collision": true,
		"pavilion_crown_rise_above_roof_m": _crown_rise(front, three_y),
		"chest_height_relief_collision_congruent": true,
		"entrance_groups": int(schedule.entrance_groups),
		"doors_per_entrance_group": int(schedule.doors_per_entrance_group),
		"entrance_bays": _int_array(schedule.entrance_bays as Array),
		"entrance_groups_aligned_with_crescent_bays": true,
		"south_junction_window_count": (schedule.junction_windows as Array).size(),
		"north_junction_window_runs": _junction_window_runs(schedule.north_junction_windows as Array),
		"se_face_runs": se_runs,
		"se_narrow_window_count": se_windows.size(),
		"rear_ribbon_host_runs": rear_hosts,
		"rear_podium_lowered_to_north_ring_terrace_by_root_release": true,
		"drum_end_opening_host_runs": SE_SHOULDER_RUNS.duplicate(),
		"drum_end_opening_host_width_m": _chain_length(record, shoulder_runs),
		"drum_end_opening_count": 2,
		"upper_drum_blank": true,
		"drum_banding_on_exposed_rear_outline": drum_banding_on_rear_outline,
		"wing_tier_partitions_clipped_to_frozen_footprint": not tier_clip.is_empty(),
		"central_tier_walls_unchanged": true,
		"public_depth_bands_m": [
			0.035,
			float(crescent_style.jamb_front),
			float(front.crescent_pier_depth),
			float(front.crescent_pier_reed_front),
			float(((front.crescent_attic as Dictionary).coping as Array)[2]),
		],
		"crescent_attic_frieze_with_incised_lines": true,
		"pavilion_crowns_flat_topped_over_corner_fins": true,
		"fine_detail_as_mipmapped_pattern_without_distance_switching": true,
		"proportions_from_owner_photos_2026_11_20": true,
		"crescent_front_block_set_down_m": [float((front.crescent_block as Dictionary).depth_m), float((front.crescent_block as Dictionary).roof_y)],
		"wing_faces_two_storeys_third_set_back_m": float((front.wing_setback as Dictionary).setback),
		"existing_cc0_plaster_maps_used": true,
		"genai_texture_candidate_consumed": false,
		"horizontal_source_geometry_changed": false,
		"source_wall_bottoms_changed": false,
		"tier_massing_changed": true,
		"base_wall_outer_tier_and_projecting_base_collision_preserved": true,
		"spray_ownership_changed": false,
		"recognition_status": "accepted_before_quality_hardening_and_preserved",
		"visual_review_status": VISUAL_REVIEW_STATUS,
		"interior_modeled": true,
		"interior_config_path": INTERIOR.CONFIG_PATH,
		"open_entrance_bay": int(hole.bay),
		"inner_rings_cut_by_interior": true,
	}, true)
	var result := _finish_record(root, specs, collision, true, metadata)
	if not bool(result.ok):
		return result
	# The concourse rides beside the wall record, not under it: it carries none of
	# the building's source keys, so the building's own checks see its exterior.
	var built := INTERIOR.build(interior)
	result["extra_nodes"] = [{"name": "building_1_interior", "parent": "buildings", "result": built}]
	return result


static func _build_building_roof(record: Dictionary, wall_record: Dictionary, config: Dictionary, bar_config: Dictionary) -> Dictionary:
	var vertical := config.vertical_production_inference_m as Dictionary
	var chains := config.massing_chains as Dictionary
	var schedule := config.facade_schedule as Dictionary
	var front := bar_config.geometry_production_inference_m as Dictionary
	var two_y := float(vertical.two_story_roof_y)
	var three_y := float(vertical.three_story_roof_y)
	var four_y := float(vertical.four_story_roof_y)
	var roof := _bucket()
	var canopy_buckets := {"canopy": _bucket(), "soffit": _bucket(), "fascia": _bucket(), "base": _bucket(), "reveal": _bucket(), "bronze": _bucket()}
	# The soffit's raised reeds and vent frames share its cream stucco.
	canopy_buckets["trim"] = canopy_buckets.soffit
	var collision := _bucket()
	var tier_clip := _tier_clip(wall_record)
	var field_runs := _int_array(schedule.crescent_field_runs)
	var crescent := _crescent_layout(wall_record, field_runs, int(schedule.central_window_count), front)
	var north_ring := front.north_ring as Dictionary
	var rear_ring := front.rear_ring as Dictionary
	var base_cuts := _setback_cuts(wall_record, north_ring.chains as Array, float(north_ring.setback))
	base_cuts.append_array(_setback_cuts(wall_record, [rear_ring.runs], float(rear_ring.setback)))
	# The concourse rises through the two-storey slab and the north wing's roof
	# where the wing meets the crescent; its plan polygon reaches out through the
	# door, past the footprint, so no cut leaves a hole in a slab piece.
	var interior := _interior_plan(wall_record, config, front)
	if not bool(interior.get("ok", false)):
		return _failure("building_1_interior_plan", str(interior.get("message", "Building 1 interior plan failed.")), record)
	var interior_cuts: Array = [interior.cut_polygon]
	base_cuts.append_array(interior_cuts)
	var cut_whole := _append_record_roof(roof, collision, record, two_y, base_cuts)
	# The set-down front bands (_append_front_step) take their own lower roofs out of
	# the strips' roofs: the crescent's front block and the wings' two-storey faces.
	var block := front.crescent_block as Dictionary
	var block_runs := _int_array(block.runs as Array)
	var wing_setback := front.wing_setback as Dictionary
	var north_setback_runs := _int_array(wing_setback.north_runs as Array)
	var south_setback_runs := _int_array(wing_setback.south_runs as Array)
	var wing_step := float(wing_setback.setback)
	var towers := front.junction_towers as Dictionary
	var tower_top := float(towers.top_y)
	var tower_depth := float(towers.depth_m)
	var tower_segment := float(towers.min_segment_m)
	var north_tower_runs := _int_array(towers.north_tower_runs as Array)
	var north_bay_runs := _int_array(towers.north_plain_bay_runs as Array)
	var south_tower_runs := _int_array(towers.south_tower_runs as Array)
	var north_cuts := interior_cuts.duplicate()
	north_cuts.append_array(_setback_cuts(wall_record, [north_setback_runs], wing_step, FRONT_STEP_MIN_SEGMENT_M))
	north_cuts.append_array(_setback_cuts(wall_record, [north_tower_runs], tower_depth, tower_segment))
	north_cuts.append_array(_setback_cuts(wall_record, [north_bay_runs], float(towers.north_plain_bay_depth_m), FRONT_STEP_MIN_SEGMENT_M))
	cut_whole = _append_strip_roof(roof, collision, wall_record, _int_array(chains.north_three_story_runs), three_y, float(vertical.north_wing_inward_depth), tier_clip, north_cuts) and cut_whole
	var central := _int_array(chains.central_four_story_runs)
	var central_main := central.slice(0, central.find(south_tower_runs[0]))
	var high_runs := _int_array(block.four_storey_runs as Array)
	var central_high := central_main.slice(0, central_main.find(high_runs[high_runs.size() - 1]) + 1)
	var central_low := central_main.slice(central_high.size())
	cut_whole = _append_strip_roof(roof, collision, wall_record, central_high, four_y, float(vertical.central_inward_depth), {}, _setback_cuts(wall_record, [central_high], float(block.depth_m), FRONT_STEP_MIN_SEGMENT_M)) and cut_whole
	cut_whole = _append_strip_roof(roof, collision, wall_record, central_low, float(block.roof_y), float(vertical.central_inward_depth)) and cut_whole
	# Where the crescent's chain meets the south junction's, the corner between the two
	# strips' end caps keeps a roof, as the single chain's join did.
	var low_end := _run_frame(wall_record, central_low[central_low.size() - 1])
	var tower_start := _run_frame(wall_record, south_tower_runs[0])
	var corner := low_end.end as Vector3
	var join_y := float(block.roof_y) - 0.01
	var join := [_lifted(corner, join_y), _lifted(corner - (low_end.normal as Vector3) * tower_depth, join_y), _lifted(corner - (tower_start.normal as Vector3) * tower_depth, join_y)]
	for target: Dictionary in [roof, collision]:
		_append_triangle(target, join[0], join[1], join[2], Vector3.UP)
	var tower_cuts := interior_cuts.duplicate()
	tower_cuts.append_array(_setback_cuts(wall_record, [south_tower_runs], tower_depth, tower_segment))
	cut_whole = _append_strip_roof(roof, collision, wall_record, south_tower_runs, three_y, float(vertical.south_wing_inward_depth), {}, tower_cuts) and cut_whole
	cut_whole = _append_front_step_roof(roof, collision, wall_record, north_bay_runs, float(towers.north_plain_bay_depth_m), float(block.roof_y)) and cut_whole
	for tower_runs: Array[int] in [north_tower_runs, south_tower_runs]:
		cut_whole = _append_front_step_roof(roof, collision, wall_record, tower_runs, tower_depth, tower_top, tower_segment) and cut_whole
	var se_setback := front.se_setback as Dictionary
	var se_cuts := _setback_cuts(wall_record, [se_setback.runs], float(se_setback.setback))
	var south_runs := _int_array(chains.south_three_story_runs)
	var south_depth := float(vertical.south_wing_inward_depth)
	var south_cuts := se_cuts.duplicate()
	south_cuts.append_array(_setback_cuts(wall_record, [south_setback_runs], wing_step, FRONT_STEP_MIN_SEGMENT_M))
	cut_whole = _append_strip_roof(roof, collision, wall_record, south_runs, three_y, south_depth, tier_clip, south_cuts) and cut_whole
	cut_whole = _append_front_step_roof(roof, collision, wall_record, central_high, float(block.depth_m), float(block.roof_y)) and cut_whole
	for notch_runs: Array[int] in [north_setback_runs, south_setback_runs]:
		cut_whole = _append_front_step_roof(roof, collision, wall_record, notch_runs, wing_step, float(wing_setback.face_top_y)) and cut_whole
	if not cut_whole:
		return _failure("building_1_hero_roof_cut", "A cut through Building 1's roof slabs (a setback terrace or the hall's plan) would leave a hole in a slab, which would be drawn and solid across the opening, or a cut piece could not be triangulated.", record)
	var canopy_error := _append_crescent_canopy(canopy_buckets, collision, wall_record, crescent, front)
	if canopy_error != "":
		return _failure("building_1_hero_canopy", canopy_error, record)
	# Thin dark mast on the drum roof near its south end, placed and sized by
	# fitted-camera triangulation of the Sep 2025 SW and WSW Street Views and
	# the 18 Jul 2023 rear photograph (see the b1-roof study notes). Solid,
	# non-receiver.
	var mast := _bucket()
	# It stands behind the crescent's south bays, on their block's roof.
	var mast_placed := _append_drum_mast(mast, collision, wall_record, _int_array(chains.central_four_story_runs), float(vertical.central_inward_depth), float(block.roof_y), front.drum_mast as Dictionary)
	if not mast_placed:
		push_warning("Building 1 hero: the configured drum mast point is not on the drum roof; the mast was omitted.")
	# A plain flagpole on the front block's roof behind the middle bay (the owner's
	# 2026-11-20 photos; no flag). Solid, non-receiver.
	var pole := front.flagpole as Dictionary
	var flagpole := _bucket()
	var pole_s := float((crescent.windows as Array)[int(pole.bay)])
	var pole_wall := _smoothed_wall(wall_record, block_runs, pole_s, float((front.canopy as Dictionary).normal_smoothing_m))
	var pole_at := (pole_wall.point as Vector3) - (pole_wall.normal as Vector3) * float(pole.behind_face_m)
	var pole_base := float(block.roof_y)
	var pole_width := float(pole.width)
	var pole_tangent := Vector3((pole_wall.normal as Vector3).z, 0.0, -(pole_wall.normal as Vector3).x)
	for target: Dictionary in [flagpole, collision]:
		_append_box(target, Vector3(pole_at.x, pole_base + float(pole.height) * 0.5, pole_at.z), pole_tangent, pole_wall.normal as Vector3, pole_width, float(pole.height), pole_width)
		_append_box(target, Vector3(pole_at.x, pole_base + float(pole.height) + float(pole.finial) * 0.5, pole_at.z), pole_tangent, pole_wall.normal as Vector3, float(pole.finial), float(pole.finial), float(pole.finial))
	var root := _hero_root("Building1HeroRoof", record, "building_roof")
	var specs: Array[Dictionary] = [
		{"name": "HeroSteppedRoof", "bucket": roof, "material": ROOF_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroEntranceCanopy", "bucket": canopy_buckets.canopy, "material": PUBLIC_TRIM_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroEntranceCanopySoffit", "bucket": canopy_buckets.soffit, "material": PUBLIC_TRIM_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroCanopyFascia", "bucket": canopy_buckets.fascia, "material": PUBLIC_TRIM_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroCanopySoffitJoints", "bucket": canopy_buckets.base, "material": PUBLIC_BASE_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroCanopyVentPlates", "bucket": canopy_buckets.reveal, "material": REVEAL_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroCanopyFloodlights", "bucket": canopy_buckets.bronze, "material": BRONZE_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroDrumMast", "bucket": mast, "material": PUBLIC_FRAME_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroFlagpole", "bucket": flagpole, "material": TRIM_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
	]
	var canopy_config := front.canopy as Dictionary
	var metadata := _common_metadata(config, record, "building_roof")
	metadata["reachable_roof_tier_y"] = [two_y, three_y, four_y]
	metadata["canopy_collision_congruent"] = true
	metadata["canopy_runs"] = _int_array(canopy_config.runs as Array)
	metadata["canopy_depth_m"] = float(canopy_config.depth_m)
	metadata["canopy_top_and_soffit_y"] = [float(canopy_config.top_y), float(canopy_config.soffit_y)]
	metadata["canopy_horizontal_domain"] = "constant_depth_on_smoothed_crescent_normals_with_quarter_round_ends"
	metadata["wing_tier_roofs_clipped_to_frozen_footprint"] = not tier_clip.is_empty()
	metadata["crescent_front_block_roof_y"] = float(block.roof_y)
	metadata["wing_face_terrace_y"] = float(wing_setback.face_top_y)
	metadata["flagpole_on_front_block"] = true
	metadata["drum_mast_placed"] = mast_placed
	metadata["public_family_pass_id"] = str(bar_config.pass_id)
	metadata["public_front_believability_config_path"] = BAR_CONFIG_PATH
	metadata["recognition_status"] = "accepted_before_quality_hardening_and_preserved"
	metadata["roof_tiers_changed"] = false
	metadata["genai_texture_candidate_consumed"] = false
	return _finish_record(root, specs, collision, false, metadata)


static func _build_tower_wall(record: Dictionary, config: Dictionary, front: Dictionary) -> Dictionary:
	var vertical := config.vertical_production_inference_m as Dictionary
	var glass_base := float(vertical.tower_glass_base_y)
	var glass_top := float(vertical.tower_glass_top_y)
	var platform_scale := float(vertical.tower_platform_plan_scale)
	var center := _plan_centroid_from_wall(record)
	var ivory := _bucket()
	var glass := _bucket()
	var trim := _bucket()
	var collision := _bucket()
	for run_index in range(10):
		var frame := _run_frame(record, run_index)
		var source_start := frame.start as Vector3
		var source_end := frame.end as Vector3
		# The base storey under the cab is r16681702 rooftop massing (ROOT
		# 2026-10-22); the frozen tower keeps the cab on its exact plan.
		var exact_start := Vector3(source_start.x, glass_base, source_start.z)
		var exact_end := Vector3(source_end.x, glass_base, source_end.z)
		_append_vertical_face(glass, exact_start, exact_end, glass_base, glass_top, frame.normal as Vector3)
		_append_vertical_face(collision, exact_start, exact_end, glass_base, glass_top, frame.normal as Vector3)
		_append_wall_bar(trim, exact_start.lerp(exact_end, 0.5), frame.tangent as Vector3, frame.normal as Vector3, glass_base + 0.12, float(frame.length_m), 0.12, 0.12)
		_append_wall_bar(trim, exact_start.lerp(exact_end, 0.5), frame.tangent as Vector3, frame.normal as Vector3, glass_top - 0.12, float(frame.length_m), 0.12, 0.12)
		for mullion_fraction in [0.333333, 0.666667]:
			var mullion_anchor := exact_start.lerp(exact_end, float(mullion_fraction))
			_append_wall_bar(trim, mullion_anchor, frame.tangent as Vector3, frame.normal as Vector3, (glass_base + glass_top) * 0.5, 0.12, glass_top - glass_base, 0.13)
	# Fascia above the low glazing, under the overhanging roof eave, and a sill
	# course below it (dated 2023 rear and east views): closed rings mitred at
	# the octagon's corners. The fascia is solid, closing the wall between the
	# glass top and the roof soffit.
	var ring := _tower_plan_ring(record)
	var fascia := front.tower_cab_fascia as Dictionary
	var sill := front.tower_cab_sill as Dictionary
	for target: Dictionary in [trim, collision]:
		_append_ring_band(target, ring, glass_top, glass_top + float(fascia.height), float(fascia.front), float(fascia.back))
	var sill_bottom := glass_base - float(sill.below_glass_base)
	_append_ring_band(trim, ring, sill_bottom, sill_bottom + float(sill.height), float(sill.front), float(sill.back))
	# Base storey under the cab (2023 rear view). ROOT 2026-10-22: the tower
	# record owns the cab and this storey; the frozen OSM way traces only the
	# cab, and the storey stands on r16681702's central roof at the tower base.
	if not _tower_base_block_fits(front.tower_base_block as Dictionary, center):
		return _failure("building_1_tower_base_block_placement", "Tower base storey no longer stands on Building 1's frozen roof around the cab.", record)
	var base_block := {"wall": _bucket(), "glass": _bucket(), "trim": _bucket()}
	_append_tower_base_block(base_block, collision, front.tower_base_block as Dictionary, float(vertical.four_story_roof_y), float(vertical.tower_platform_top_y))
	var root := _hero_root("Building1ObservationTowerHeroWall", record, "tower_wall")
	var specs: Array[Dictionary] = [
		{"name": "HeroTowerBaseStorey", "bucket": base_block.wall, "material": PUBLIC_WALL_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroTowerBaseStoreyGlazing", "bucket": base_block.glass, "material": PUBLIC_GLASS_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroTowerBaseStoreyTrim", "bucket": base_block.trim, "material": PUBLIC_TRIM_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroTowerIvory", "bucket": ivory, "material": WALL_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroTowerExactPlanGlass", "bucket": glass, "material": GLASS_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroTowerTrim", "bucket": trim, "material": TRIM_MATERIAL, "layers": RENDER_BUILDING_WALL},
	]
	var metadata := _common_metadata(config, record, "tower_wall")
	metadata.merge({
		"tower_separate_recognition_entity": true,
		"exact_source_plan": true,
		"exact_plan_run_count": 10,
		"exact_plan_centroid_xz": [center.x, center.z],
		"platform_plan_scale_production_inference": platform_scale,
		"base_storey_owned_by_tower_record": true,
	}, true)
	return _finish_record(root, specs, collision, true, metadata)


static func _build_tower_roof(record: Dictionary, config: Dictionary, front: Dictionary) -> Dictionary:
	var vertical := config.vertical_production_inference_m as Dictionary
	var platform_top := float(vertical.tower_platform_top_y)
	var glass_top := float(vertical.tower_glass_top_y)
	var peak_y := float(vertical.tower_roof_peak_y)
	var scale := float(vertical.tower_platform_plan_scale)
	var source_points := _roof_unique_points(record)
	if source_points.size() != 8:
		return _failure("building_1_tower_plan", "Tower roof no longer resolves to the exact eight-corner source plan.", record)
	var center := _plan_centroid(source_points)
	var roof := _bucket()
	var cab_roof := _bucket()
	var spike_bucket := _bucket()
	var collision := _bucket()
	_append_scaled_record_roof(roof, collision, record, center, scale, platform_top + 0.02)
	# Low pale standing-seam pyramid (dated 2023 rear and east views): the eave
	# overhangs the fascia on a scaled copy of the exact plan, with a soffit
	# back to the fascia face, raised hips and seams, and a small octagonal vent
	# cap with a short spike. Roof faces, eave edge, soffit and cap are solid.
	var cab := front.tower_cab_roof as Dictionary
	var fascia := front.tower_cab_fascia as Dictionary
	var soffit_y := glass_top + float(fascia.height)
	var eave_y := soffit_y + float(cab.eave_thickness)
	var eave_scale := float(cab.eave_plan_scale)
	var apex := Vector3(center.x, peak_y, center.z)
	var ring := {"points": source_points, "center": center}
	var count := source_points.size()
	var eaves: Array[Vector3] = []
	var fascia_fronts: Array[Vector3] = []
	for index in count:
		eaves.append(_scaled_plan_point(source_points[index], center, eave_scale, eave_y))
		fascia_fronts.append(_lifted(source_points[index] + _ring_miter(ring, index) * float(fascia.front), soffit_y))
	var facet_normals: Array[Vector3] = []
	for index in count:
		var first := eaves[index]
		var second := eaves[(index + 1) % count]
		var normal := (second - first).cross(apex - first).normalized()
		if normal.y < 0.0:
			normal = -normal
		facet_normals.append(normal)
		for target: Dictionary in [cab_roof, collision]:
			_append_triangle(target, first, second, apex, normal)
			_append_quad(target, _lifted(first, soffit_y), _lifted(second, soffit_y), second, first, _ring_edge_normal(ring, index))
			_append_quad(target, fascia_fronts[index], fascia_fronts[(index + 1) % count], _lifted(second, soffit_y), _lifted(first, soffit_y), Vector3.DOWN)
		_append_roof_seams(cab_roof, first, second, apex, normal, int(cab.seams_per_facet), float(cab.seam_width), float(cab.seam_height))
	var cap := cab.cap as Dictionary
	var cap_radius := float(cap.radius)
	for index in count:
		var hip_run := Vector2(eaves[index].x - apex.x, eaves[index].z - apex.z).length()
		_append_roof_hip(cab_roof, eaves[index], apex, eaves[(index + count - 1) % count], facet_normals[(index + count - 1) % count], eaves[(index + 1) % count], facet_normals[index], float(cab.hip_width), float(cab.hip_height), 1.0 - cap_radius / maxf(hip_run, cap_radius + 0.01))
	var cap_wall_top := peak_y + float(cap.wall_above_peak)
	var cap_top := cap_wall_top + float(cap.roof_rise)
	for target: Dictionary in [cab_roof, collision]:
		_append_octagon_cap(target, apex, cap_radius, peak_y - cap_radius * 0.75, cap_wall_top, cap_top)
	var spike := cab.spike as Dictionary
	_append_box(spike_bucket, Vector3(apex.x, cap_top + float(spike.height) * 0.5 - 0.05, apex.z), Vector3.RIGHT, Vector3.BACK, float(spike.width), float(spike.height), float(spike.width))
	var root := _hero_root("Building1ObservationTowerHeroRoof", record, "tower_roof")
	var specs: Array[Dictionary] = [
		{"name": "HeroTowerPlatform", "bucket": roof, "material": ROOF_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroTowerPaleStandingSeamRoof", "bucket": cab_roof, "material": TOWER_ROOF_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroTowerVentSpike", "bucket": spike_bucket, "material": BRONZE_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
	]
	var metadata := _common_metadata(config, record, "tower_roof")
	metadata.merge({
		"tower_separate_recognition_entity": true,
		"exact_source_plan": true,
		"source_plan_corner_count": 8,
		"raised_seam_pyramidal_roof_proxy": true,
		"reachable_platform_y": platform_top,
	}, true)
	return _finish_record(root, specs, collision, false, metadata)


## The cab's exact plan as a ring: the wall record's run starts, merging
## collinear source splits (runs 0/1 and 5/6), with the plan centroid.
static func _tower_plan_ring(record: Dictionary) -> Dictionary:
	var points: Array[Vector3] = []
	var last_tangent := Vector3.ZERO
	for run_index in range(10):
		var frame := _run_frame(record, run_index)
		var tangent := frame.tangent as Vector3
		if not points.is_empty() and tangent.dot(last_tangent) > 0.9999:
			continue
		points.append(frame.start as Vector3)
		last_tangent = tangent
	var first_tangent := _run_frame(record, 0).tangent as Vector3
	if points.size() > 1 and last_tangent.dot(first_tangent) > 0.9999:
		points.remove_at(0)
	return {"points": points, "center": _plan_centroid(points)}


## Outward horizontal normal of ring edge `index` (points[index] to the next).
static func _ring_edge_normal(ring: Dictionary, index: int) -> Vector3:
	var points := ring.points as Array
	var a := points[index] as Vector3
	var b := points[(index + 1) % points.size()] as Vector3
	var normal := Vector3(b.z - a.z, 0.0, a.x - b.x).normalized()
	var middle := (a + b) * 0.5 - (ring.center as Vector3)
	if normal.dot(Vector3(middle.x, 0.0, middle.z)) < 0.0:
		normal = -normal
	return normal


static func _ring_miter(ring: Dictionary, index: int) -> Vector3:
	var count := (ring.points as Array).size()
	return _miter_between(_ring_edge_normal(ring, (index + count - 1) % count), _ring_edge_normal(ring, index))


## Closed band around a ring, mitred at every corner: outer face, top and
## bottom between `back` and `front` metres off the exact plan.
static func _append_ring_band(bucket: Dictionary, ring: Dictionary, bottom: float, top: float, front: float, back: float) -> void:
	var points := ring.points as Array
	var count := points.size()
	for index in count:
		var next := (index + 1) % count
		var a := points[index] as Vector3
		var b := points[next] as Vector3
		var fa := a + _ring_miter(ring, index) * front
		var fb := b + _ring_miter(ring, next) * front
		var ba := a + _ring_miter(ring, index) * back
		var bb := b + _ring_miter(ring, next) * back
		_append_quad(bucket, _lifted(fa, bottom), _lifted(fb, bottom), _lifted(fb, top), _lifted(fa, top), _ring_edge_normal(ring, index))
		_append_quad(bucket, _lifted(ba, top), _lifted(bb, top), _lifted(fb, top), _lifted(fa, top), Vector3.UP)
		_append_quad(bucket, _lifted(fa, bottom), _lifted(fb, bottom), _lifted(bb, bottom), _lifted(ba, bottom), Vector3.DOWN)


## Standing seams on one pyramid facet: raised strips at even stations along
## the eave, running straight up the fall line until they meet a hip.
static func _append_roof_seams(bucket: Dictionary, first: Vector3, second: Vector3, apex: Vector3, normal: Vector3, count: int, width: float, height: float) -> void:
	var along := second - first
	var length := along.length()
	if count <= 0 or length < 0.5:
		return
	var e1 := along / length
	var e2 := normal.cross(e1).normalized()
	if e2.dot(apex - first) < 0.0:
		e2 = -e2
	var apex_x := (apex - first).dot(e1)
	var apex_y := (apex - first).dot(e2)
	if apex_x <= 0.01 or apex_x >= length - 0.01:
		return
	for station in count:
		var x := length * float(station + 1) / float(count + 1)
		var reach := apex_y * (x / apex_x if x <= apex_x else (length - x) / (length - apex_x))
		reach -= width
		if reach < 0.3:
			continue
		var lift := normal * height
		var bl := first + e1 * (x - width * 0.5)
		var br := first + e1 * (x + width * 0.5)
		var tl := bl + e2 * reach
		var tr := br + e2 * reach
		_append_quad(bucket, bl + lift, br + lift, tr + lift, tl + lift, normal)
		_append_quad(bucket, bl, tl, tl + lift, bl + lift, -e1)
		_append_quad(bucket, br, tr, tr + lift, br + lift, e1)
		_append_quad(bucket, bl, br, br + lift, bl + lift, -e2)


## Raised hip roll along a hip line from the eave towards the apex, lying on
## both adjoining facets (each given by its normal and its other eave corner);
## stops `fraction` of the way up, under the vent cap.
static func _append_roof_hip(bucket: Dictionary, eave: Vector3, apex: Vector3, left_corner: Vector3, left_normal: Vector3, right_corner: Vector3, right_normal: Vector3, width: float, height: float, fraction: float) -> void:
	var direction := (apex - eave).normalized()
	var top := eave + (apex - eave) * clampf(fraction, 0.0, 1.0)
	var ridge := (left_normal + right_normal).normalized() * height
	for pair: Array in [[left_corner, left_normal], [right_corner, right_normal]]:
		var normal: Vector3 = pair[1]
		var side := normal.cross(direction).normalized()
		if side.dot((pair[0] as Vector3) - eave) < 0.0:
			side = -side
		var offset := side * width * 0.5
		_append_quad(bucket, eave + offset, top + offset, top + ridge, eave + ridge, (normal + ridge.normalized()).normalized())
		_append_triangle(bucket, eave + offset, eave + ridge, eave, -direction)


## Small octagonal vent cap seated into the pyramid apex: walls, then a low
## octagonal pyramid roof. Closed above the main roof.
static func _append_octagon_cap(bucket: Dictionary, apex: Vector3, radius: float, bottom: float, wall_top: float, top: float) -> void:
	var tip := Vector3(apex.x, top, apex.z)
	for index in 8:
		var a_angle := TAU * (float(index) + 0.5) / 8.0
		var b_angle := TAU * (float(index) + 1.5) / 8.0
		var a := Vector3(apex.x + cos(a_angle) * radius, 0.0, apex.z + sin(a_angle) * radius)
		var b := Vector3(apex.x + cos(b_angle) * radius, 0.0, apex.z + sin(b_angle) * radius)
		var outward := Vector3(cos((a_angle + b_angle) * 0.5), 0.0, sin((a_angle + b_angle) * 0.5))
		_append_quad(bucket, _lifted(a, bottom), _lifted(b, bottom), _lifted(b, wall_top), _lifted(a, wall_top), outward)
		var up := (_lifted(b, wall_top) - _lifted(a, wall_top)).cross(tip - _lifted(a, wall_top)).normalized()
		if up.y < 0.0:
			up = -up
		_append_triangle(bucket, _lifted(a, wall_top), _lifted(b, wall_top), tip, up)


## Thin tapered mast on a plinth, standing on the drum roof at the configured
## point when that point lies inside the central tier's roof pieces.
static func _append_drum_mast(visual: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], depth: float, roof_y: float, mast: Dictionary) -> bool:
	var xz := mast.xz as Array
	var at := Vector2(float(xz[0]), float(xz[1]))
	var plinth := float(mast.plinth_width)
	var inside := 0
	for corner in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		for piece in _strip_pieces(record, runs, depth):
			if Geometry2D.is_point_in_polygon(at + corner * (plinth * 0.5 + 0.5), piece):
				inside += 1
				break
	if inside < 4:
		return false
	var plinth_top := roof_y + float(mast.plinth_height)
	var top := float(mast.top_y)
	for target: Dictionary in [visual, collision]:
		_append_box(target, Vector3(at.x, (roof_y - 0.02 + plinth_top) * 0.5, at.y), Vector3.RIGHT, Vector3.BACK, plinth, plinth_top - roof_y + 0.02, plinth)
		var base_half := float(mast.base_width) * 0.5
		var top_half := float(mast.top_width) * 0.5
		var corners := [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
		for index in 4:
			var c0: Vector2 = corners[index]
			var c1: Vector2 = corners[(index + 1) % 4]
			var outward := Vector3(c0.x + c1.x, 0.0, c0.y + c1.y).normalized()
			_append_quad(target, Vector3(at.x + c0.x * base_half, plinth_top - 0.02, at.y + c0.y * base_half), Vector3(at.x + c1.x * base_half, plinth_top - 0.02, at.y + c1.y * base_half), Vector3(at.x + c1.x * top_half, top, at.y + c1.y * top_half), Vector3(at.x + c0.x * top_half, top, at.y + c0.y * top_half), outward)
		_append_quad(target, Vector3(at.x - top_half, top, at.y - top_half), Vector3(at.x + top_half, top, at.y - top_half), Vector3(at.x + top_half, top, at.y + top_half), Vector3(at.x - top_half, top, at.y + top_half), Vector3.UP)
	return true


## The exact source walls, base to top_y. The open door (hole) cuts the run it
## crosses; inner_cuts (the interior's plan) cut the enclosed inner rings.
static func _append_exact_base_walls(public_visual: Dictionary, original_visual: Dictionary, collision: Dictionary, record: Dictionary, top_y: float, lowered: Dictionary = {}, hole: Dictionary = {}, inner_cuts: Array = []) -> void:
	for run_index in range(110):
		var frame := _run_frame(record, run_index)
		var start := frame.start as Vector3
		var end := frame.end as Vector3
		var visual := original_visual if run_index in PROTECTED_RUNS else public_visual
		var run_top := float(lowered.get(run_index, top_y))
		var normal := frame.normal as Vector3
		if run_index >= INNER_RING_FIRST_RUN and not inner_cuts.is_empty():
			_append_cut_face(visual, collision, start, end, start.y, run_top, normal, inner_cuts, end.y)
			continue
		var span := _door_span(hole, start, end)
		if span.x >= 0.0:
			_append_holed_face([visual, collision], start, end, run_top, normal, span, float(hole.top_y))
			continue
		_append_vertical_face(visual, start, end, start.y, run_top, normal, end.y)
		_append_vertical_face(collision, start, end, start.y, run_top, normal, end.y)


## Where the open door crosses a wall segment in its own wall plane: Vector2(t0,
## t1) along the segment between the door's sides, or (-1, -1). Segments more than
## a metre in front of or behind the door's frame never count.
static func _door_span(hole: Dictionary, start: Vector3, end: Vector3) -> Vector2:
	var none := Vector2(-1.0, -1.0)
	if hole.is_empty():
		return none
	var anchor := hole.anchor as Vector3
	var tangent := hole.tangent as Vector3
	var normal := hole.normal as Vector3
	var a := Vector3(start.x - anchor.x, 0.0, start.z - anchor.z)
	var b := Vector3(end.x - anchor.x, 0.0, end.z - anchor.z)
	if absf(a.dot(normal)) > 1.0 or absf(b.dot(normal)) > 1.0:
		return none
	var la := a.dot(tangent) - float(hole.center)
	var lb := b.dot(tangent) - float(hole.center)
	var half := float(hole.half)
	if absf(lb - la) < 0.0001 or maxf(la, lb) <= -half or minf(la, lb) >= half:
		return none
	var t0 := clampf((-half - la) / (lb - la), 0.0, 1.0)
	var t1 := clampf((half - la) / (lb - la), 0.0, 1.0)
	return Vector2(minf(t0, t1), maxf(t0, t1))


## A wall face with the door cut out of it: full height either side, the wall
## above the door's head over it. Bottoms follow the source base.
static func _append_holed_face(targets: Array, start: Vector3, end: Vector3, top_y: float, normal: Vector3, span: Vector2, hole_top: float) -> void:
	var a := start.lerp(end, span.x)
	var b := start.lerp(end, span.y)
	for target: Dictionary in targets:
		if span.x > 0.0001:
			_append_vertical_face(target, start, a, start.y, top_y, normal, a.y)
		if span.y < 0.9999:
			_append_vertical_face(target, b, end, b.y, top_y, normal, end.y)
		_append_vertical_face(target, a, b, hole_top, top_y, normal)


## A vertical face a-b with every part inside any cut polygon (world XZ) removed;
## bottoms follow the base from bottom_a to bottom_b (default: level).
static func _append_cut_face(visual: Dictionary, collision: Dictionary, a: Vector3, b: Vector3, bottom_a: float, top_y: float, normal: Vector3, cuts: Array, bottom_b: float = NAN) -> void:
	var resolved_b := bottom_a if is_nan(bottom_b) else bottom_b
	if cuts.is_empty():
		_append_vertical_face(visual, a, b, bottom_a, top_y, normal, resolved_b)
		_append_vertical_face(collision, a, b, bottom_a, top_y, normal, resolved_b)
		return
	var pieces: Array[PackedVector2Array] = [PackedVector2Array([Vector2(a.x, a.z), Vector2(b.x, b.z)])]
	for cut: PackedVector2Array in cuts:
		var kept: Array[PackedVector2Array] = []
		for piece in pieces:
			for remainder: PackedVector2Array in Geometry2D.clip_polyline_with_polygon(piece, cut):
				kept.append(remainder)
		pieces = kept
	var flat := Vector2(b.x - a.x, b.z - a.z)
	for piece in pieces:
		for index in range(piece.size() - 1):
			var p := piece[index]
			var q := piece[index + 1]
			if p.distance_to(q) < 0.05:
				continue
			var tp := clampf((p - Vector2(a.x, a.z)).dot(flat) / flat.length_squared(), 0.0, 1.0)
			var tq := clampf((q - Vector2(a.x, a.z)).dot(flat) / flat.length_squared(), 0.0, 1.0)
			var start := Vector3(p.x, 0.0, p.y)
			var end := Vector3(q.x, 0.0, q.y)
			_append_vertical_face(visual, start, end, lerpf(bottom_a, resolved_b, tp), top_y, normal, lerpf(bottom_a, resolved_b, tq))
			_append_vertical_face(collision, start, end, lerpf(bottom_a, resolved_b, tp), top_y, normal, lerpf(bottom_a, resolved_b, tq))


## `start_cap_step` and `end_cap_step` (Vector2(depth, top_y)) set down that end cap's
## front `depth` metres to top_y, where a set-down front band (_append_front_step)
## begins or ends the chain.
static func _append_strip_walls(public_visual: Dictionary, original_visual: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], low_y: float, high_y: float, depth: float, clip: Dictionary = {}, skip_outer: Dictionary = {}, cuts: Array = [], cut_end_caps: bool = false, start_cap_step: Vector2 = Vector2.ZERO, end_cap_step: Vector2 = Vector2.ZERO) -> void:
	var frames: Array[Dictionary] = []
	for run_index in runs:
		frames.append(_run_frame(record, run_index))
	# The end caps keep their accepted faces unless the cuts are to reach them too.
	var cap_cuts: Array = cuts if cut_end_caps else []
	for index in frames.size():
		var frame := frames[index]
		var normal := frame.normal as Vector3
		var start_source := frame.start as Vector3
		var end_source := frame.end as Vector3
		var outer_start := Vector3(start_source.x, low_y, start_source.z)
		var outer_end := Vector3(end_source.x, low_y, end_source.z)
		var inner_start := outer_start - normal * depth
		var inner_end := outer_end - normal * depth
		if not skip_outer.has(runs[index]):
			_append_vertical_face(public_visual, outer_start, outer_end, low_y, high_y, normal)
			_append_vertical_face(collision, outer_start, outer_end, low_y, high_y, normal)
		_append_partition(original_visual, collision, inner_end, inner_start, low_y, high_y, -normal, clip, cuts)
		if index == 0 and start_cap_step.x > 0.0:
			var step_point := outer_start - normal * start_cap_step.x
			_append_cut_face(public_visual, collision, inner_start, step_point, low_y, high_y, -(frame.tangent as Vector3), cap_cuts)
			_append_cut_face(public_visual, collision, step_point, outer_start, low_y, start_cap_step.y, -(frame.tangent as Vector3), cap_cuts)
		elif index == 0:
			_append_cut_face(public_visual, collision, inner_start, outer_start, low_y, high_y, -(frame.tangent as Vector3), cap_cuts)
		if index == frames.size() - 1 and end_cap_step.x > 0.0:
			var end_step := outer_end - normal * end_cap_step.x
			_append_cut_face(public_visual, collision, outer_end, end_step, low_y, end_cap_step.y, frame.tangent as Vector3, cap_cuts)
			_append_cut_face(public_visual, collision, end_step, inner_end, low_y, high_y, frame.tangent as Vector3, cap_cuts)
		elif index == frames.size() - 1:
			_append_cut_face(public_visual, collision, outer_end, inner_end, low_y, high_y, frame.tangent as Vector3, cap_cuts)
		if index > 0:
			var previous := frames[index - 1]
			var previous_end_source := previous.end as Vector3
			var previous_inner := Vector3(previous_end_source.x, low_y, previous_end_source.z) - (previous.normal as Vector3) * depth
			var join := inner_start - previous_inner
			if join.length_squared() > 0.000001:
				var join_normal := Vector3(join.z, 0.0, -join.x).normalized()
				_append_partition(original_visual, collision, previous_inner, inner_start, low_y, high_y, join_normal, clip, cuts)


## False when a cut would leave a hole in a piece or a piece could not be
## triangulated (_append_cut_polygon): the roof's build then fails.
static func _append_strip_roof(visual: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], top_y: float, depth: float, clip: Dictionary = {}, cuts: Array = []) -> bool:
	var whole := true
	var frames: Array[Dictionary] = []
	for run_index in runs:
		frames.append(_run_frame(record, run_index))
	for index in frames.size():
		var frame := frames[index]
		var normal := frame.normal as Vector3
		var start_source := frame.start as Vector3
		var end_source := frame.end as Vector3
		var outer_start := Vector3(start_source.x, top_y, start_source.z)
		var outer_end := Vector3(end_source.x, top_y, end_source.z)
		var inner_end := outer_end - normal * depth
		var inner_start := outer_start - normal * depth
		whole = _append_roof_piece(visual, collision, [outer_start, outer_end, inner_end, inner_start], top_y, clip, cuts) and whole
		if index > 0:
			var previous := frames[index - 1]
			var join_source := previous.end as Vector3
			var join_outer := Vector3(join_source.x, top_y, join_source.z)
			var previous_inner := join_outer - (previous.normal as Vector3) * depth
			var current_inner := join_outer - normal * depth
			whole = _append_roof_piece(visual, collision, [join_outer, previous_inner, current_inner], top_y, clip, cuts) and whole
	return whole


## Outer footprint ring (runs 0-96) in local XZ, oriented as an outer boundary,
## with a 0.12 m inset copy. The 11 m wing tiers are deeper than the stepped
## west ends and corner returns, so some inner partitions and roof pieces stood
## outside the frozen footprint or doubled an exact outer wall. Their walls are
## clipped to the inset ring and their roofs to the exact ring. Empty (no
## clipping) unless an interior probe proves the native clipper keeps solids.
static func _tier_clip(record: Dictionary) -> Dictionary:
	var origin := _run_frame(record, 0).start as Vector3
	var ring := PackedVector2Array()
	for run_index in range(97):
		var start := _run_frame(record, run_index).start as Vector3
		ring.append(Vector2(start.x - origin.x, start.z - origin.z))
	var closing := _run_frame(record, 96).end as Vector3
	if Vector2(closing.x - origin.x, closing.z - origin.z).distance_to(ring[0]) > 0.001:
		return {}
	if Geometry2D.is_polygon_clockwise(ring):
		ring.reverse()
	var area := absf(_ring_area(ring))
	var inset := PackedVector2Array()
	var inset_area := INF
	for delta in [-0.12, 0.12]:
		for candidate: PackedVector2Array in Geometry2D.offset_polygon(ring, float(delta), Geometry2D.JOIN_MITER):
			var candidate_area := absf(_ring_area(candidate))
			if candidate_area < area and candidate_area > area * 0.9 and candidate_area < inset_area:
				inset = candidate
				inset_area = candidate_area
	if inset.is_empty():
		return {}
	if Geometry2D.is_polygon_clockwise(inset):
		inset.reverse()
	var probe_frame := _run_frame(record, 6)
	var probe_point := (probe_frame.start as Vector3).lerp(probe_frame.end as Vector3, 0.5) - (probe_frame.normal as Vector3) * 3.0
	var probe := Vector2(probe_point.x - origin.x, probe_point.z - origin.z)
	var square := PackedVector2Array([probe + Vector2(-0.5, -0.5), probe + Vector2(0.5, -0.5), probe + Vector2(0.5, 0.5), probe + Vector2(-0.5, 0.5)])
	for boundary: PackedVector2Array in [ring, inset]:
		var kept := Geometry2D.intersect_polygons(square, boundary)
		if kept.size() != 1 or absf(absf(_ring_area(kept[0])) - 1.0) > 0.01:
			return {}
	return {"origin": origin, "ring": ring, "inset": inset}


## Vertical tier partition kept only inside the inset frozen footprint.
static func _append_partition(visual: Dictionary, collision: Dictionary, a: Vector3, b: Vector3, low_y: float, high_y: float, normal: Vector3, clip: Dictionary, cuts: Array = []) -> void:
	var pieces: Array[PackedVector2Array] = []
	if clip.is_empty():
		pieces.append(PackedVector2Array([Vector2(a.x, a.z), Vector2(b.x, b.z)]))
	else:
		var origin := clip.origin as Vector3
		var segment := PackedVector2Array([Vector2(a.x - origin.x, a.z - origin.z), Vector2(b.x - origin.x, b.z - origin.z)])
		for piece: PackedVector2Array in Geometry2D.intersect_polyline_with_polygon(segment, clip.inset as PackedVector2Array):
			var shifted := PackedVector2Array()
			for point in piece:
				shifted.append(point + Vector2(origin.x, origin.z))
			pieces.append(shifted)
	# A setback terrace opens the band behind the exact walls; inner partitions
	# that the removed outer face used to hide stop at its setback wall.
	for cut: PackedVector2Array in cuts:
		var kept: Array[PackedVector2Array] = []
		for piece in pieces:
			for remainder: PackedVector2Array in Geometry2D.clip_polyline_with_polygon(piece, cut):
				kept.append(remainder)
		pieces = kept
	for piece in pieces:
		for index in range(piece.size() - 1):
			var start := Vector3(piece[index].x, low_y, piece[index].y)
			var end := Vector3(piece[index + 1].x, low_y, piece[index + 1].y)
			if start.distance_to(end) < 0.05:
				continue
			_append_vertical_face(visual, start, end, low_y, high_y, normal)
			_append_vertical_face(collision, start, end, low_y, high_y, normal)


## Horizontal tier roof piece kept only inside the exact frozen footprint. If a
## clipped piece cannot be triangulated, the accepted unclipped piece is kept
## rather than opening a roof hole. With cuts, false when a cut fails
## (_append_cut_polygon).
static func _append_roof_piece(visual: Dictionary, collision: Dictionary, corners: Array, top_y: float, clip: Dictionary, cuts: Array = []) -> bool:
	if not cuts.is_empty():
		var world := PackedVector2Array()
		for corner_value in corners:
			var corner := corner_value as Vector3
			world.append(Vector2(corner.x, corner.z))
		var pieces: Array[PackedVector2Array] = [world]
		if not clip.is_empty():
			var origin := clip.origin as Vector3
			var local := PackedVector2Array()
			for point in world:
				local.append(point - Vector2(origin.x, origin.z))
			pieces.clear()
			for piece: PackedVector2Array in Geometry2D.intersect_polygons(local, clip.ring as PackedVector2Array):
				var shifted := PackedVector2Array()
				for point in piece:
					shifted.append(point + Vector2(origin.x, origin.z))
				pieces.append(shifted)
		var whole := true
		for piece in pieces:
			whole = _append_cut_polygon(visual, collision, piece, top_y, cuts) and whole
		return whole
	if clip.is_empty():
		_append_roof_corners(visual, collision, corners)
		return true
	var origin := clip.origin as Vector3
	var polygon := PackedVector2Array()
	for corner_value in corners:
		var corner := corner_value as Vector3
		polygon.append(Vector2(corner.x - origin.x, corner.z - origin.z))
	if absf(_ring_area(polygon)) < 0.000001:
		return true
	var triangles: Array[Vector3] = []
	for piece: PackedVector2Array in Geometry2D.intersect_polygons(polygon, clip.ring as PackedVector2Array):
		var indices := Geometry2D.triangulate_polygon(piece)
		if indices.is_empty():
			_append_roof_corners(visual, collision, corners)
			return true
		for index_value in indices:
			var point := piece[index_value]
			triangles.append(Vector3(point.x + origin.x, top_y, point.y + origin.z))
	for offset in range(0, triangles.size(), 3):
		_append_triangle(visual, triangles[offset], triangles[offset + 1], triangles[offset + 2], Vector3.UP)
		_append_triangle(collision, triangles[offset], triangles[offset + 1], triangles[offset + 2], Vector3.UP)
	return true


static func _append_roof_corners(visual: Dictionary, collision: Dictionary, corners: Array) -> void:
	if corners.size() == 4:
		_append_quad(visual, corners[0] as Vector3, corners[1] as Vector3, corners[2] as Vector3, corners[3] as Vector3, Vector3.UP)
		_append_quad(collision, corners[0] as Vector3, corners[1] as Vector3, corners[2] as Vector3, corners[3] as Vector3, Vector3.UP)
	else:
		_append_triangle(visual, corners[0] as Vector3, corners[1] as Vector3, corners[2] as Vector3, Vector3.UP)
		_append_triangle(collision, corners[0] as Vector3, corners[1] as Vector3, corners[2] as Vector3, Vector3.UP)


## The source roof's triangles at top_y, those the cuts touch cut; false when a cut
## fails (_append_cut_polygon).
static func _append_record_roof(visual: Dictionary, collision: Dictionary, record: Dictionary, top_y: float, cuts: Array = []) -> bool:
	var whole := true
	var values := record.vertices as Array
	var indices := record.indices as Array
	for offset in range(0, indices.size(), 3):
		var points: Array[Vector3] = []
		for index_offset in 3:
			var vertex_index := int(indices[offset + index_offset]) * 3
			points.append(Vector3(float(values[vertex_index]), top_y, float(values[vertex_index + 2])))
		var triangle := PackedVector2Array([Vector2(points[0].x, points[0].z), Vector2(points[1].x, points[1].z), Vector2(points[2].x, points[2].z)])
		var touched := false
		for cut: PackedVector2Array in cuts:
			if not Geometry2D.intersect_polygons(triangle, cut).is_empty():
				touched = true
		if touched:
			whole = _append_cut_polygon(visual, collision, triangle, top_y, cuts) and whole
			continue
		_append_triangle(visual, points[0], points[1], points[2], Vector3.UP)
		_append_triangle(collision, points[0], points[1], points[2], Vector3.UP)
	return whole


## A horizontal world-XZ polygon minus every cut polygon, triangulated at y.
## Used where a setback storey opens a terrace under an existing roof slab, and
## where the hall rises through the slabs. Cuts must cross the polygon's outline (the
## setback bands; the interior's plan reaches out through its door): a cut wholly
## inside a piece would leave a hole, which triangulation would fill, so a slab would
## stand across the opening. That, or a piece that cannot be triangulated (a hole in
## the roof), returns false and the roof's build fails; nothing is drawn in its place.
static func _append_cut_polygon(visual: Dictionary, collision: Dictionary, polygon: PackedVector2Array, y: float, cuts: Array) -> bool:
	var pieces: Array[PackedVector2Array] = [polygon]
	for cut: PackedVector2Array in cuts:
		var kept: Array[PackedVector2Array] = []
		for piece in pieces:
			var remainders := Geometry2D.clip_polygons(piece, cut)
			# Geometry2D returns outlines and holes in opposite windings.
			for remainder: PackedVector2Array in remainders:
				if Geometry2D.is_polygon_clockwise(remainder) != Geometry2D.is_polygon_clockwise(remainders[0]):
					return false
			for remainder: PackedVector2Array in remainders:
				if absf(_ring_area(remainder)) > 0.0001:
					kept.append(remainder)
		pieces = kept
	for piece in pieces:
		var triangles := _polygon_triangles(piece)
		if triangles.is_empty():
			return false
		for triangle in triangles:
			var a := Vector3(triangle[0].x, y, triangle[0].y)
			var b := Vector3(triangle[1].x, y, triangle[1].y)
			var c := Vector3(triangle[2].x, y, triangle[2].y)
			_append_triangle(visual, a, b, c, Vector3.UP)
			_append_triangle(collision, a, b, c, Vector3.UP)
	return true


## Triangles covering a simple polygon. Ear clipping returns nothing for some
## clipped rings (duplicate or collinear vertices left by the setback cut), which
## silently dropped whole roof pieces; those retry on the simplified ring, then
## as a fan over each convex part.
static func _polygon_triangles(polygon: PackedVector2Array) -> Array[PackedVector2Array]:
	var triangles: Array[PackedVector2Array] = []
	for ring: PackedVector2Array in [polygon, _simplified_ring(polygon)]:
		var indices := Geometry2D.triangulate_polygon(ring)
		if indices.is_empty():
			continue
		for offset in range(0, indices.size(), 3):
			triangles.append(PackedVector2Array([ring[indices[offset]], ring[indices[offset + 1]], ring[indices[offset + 2]]]))
		return triangles
	for part: PackedVector2Array in Geometry2D.decompose_polygon_in_convex(_simplified_ring(polygon)):
		for index in range(1, part.size() - 1):
			triangles.append(PackedVector2Array([part[0], part[index], part[index + 1]]))
	return triangles


## World-XZ cut polygons for setback storeys: each chain's band between the
## exact walls (pushed 0.05 m outward so no sliver survives) and its setback.
static func _setback_cuts(record: Dictionary, chains: Array, setback: float, min_segment: float = 0.0) -> Array:
	var cuts: Array = []
	for chain_value in chains:
		var chain := _int_array(chain_value as Array)
		var outer := _chain_points(record, chain, 0.0, _chain_length(record, chain))
		var pushed := _offset_path(outer, -0.05)
		var inner := _offset_path(outer, setback)
		if min_segment > 0.0:
			# Past a chain's very short source runs (a set-down band's, _append_front_step)
			# both edges follow the simplified path, the outer one well outside the walls.
			var simple := _simplified_path(outer, min_segment)
			pushed = _offset_path(simple, -SETBACK_CUT_OUTER_REACH_M)
			inner = _offset_path(simple, setback)
		var polygon := PackedVector2Array()
		for point_value in pushed.points as Array:
			var point := point_value as Vector3
			polygon.append(Vector2(point.x, point.z))
		var inner_points := inner.points as Array
		for index in range(inner_points.size() - 1, -1, -1):
			var point := inner_points[index] as Vector3
			polygon.append(Vector2(point.x, point.z))
		cuts.append(polygon)
	return cuts


static func _append_scaled_record_roof(visual: Dictionary, collision: Dictionary, record: Dictionary, center: Vector3, scale: float, top_y: float) -> void:
	var values := record.vertices as Array
	var indices := record.indices as Array
	for offset in range(0, indices.size(), 3):
		var points: Array[Vector3] = []
		for index_offset in 3:
			var vertex_index := int(indices[offset + index_offset]) * 3
			var source := Vector3(float(values[vertex_index]), top_y, float(values[vertex_index + 2]))
			points.append(_scaled_plan_point(source, center, scale, top_y))
		_append_triangle(visual, points[0], points[1], points[2], Vector3.UP)
		_append_triangle(collision, points[0], points[1], points[2], Vector3.UP)


static func _append_projecting_base(base: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], front: Dictionary, hole: Dictionary = {}) -> void:
	var projection := float(front.projecting_base_depth)
	var top_y := float(front.projecting_base_top_y)
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var normal := frame.normal as Vector3
		var start := (frame.start as Vector3) + normal * projection
		var end := (frame.end as Vector3) + normal * projection
		var span := _door_span(hole, start, end)
		if span.x >= 0.0:
			_append_holed_face([base, collision], start, end, top_y, normal, span, float(hole.top_y))
			continue
		_append_vertical_face(base, start, end, start.y, top_y, normal, end.y)
		# Preserve the accepted sprayable collision plane byte-for-geometry: the
		# believability accents below remain visual-only.
		_append_vertical_face(collision, start, end, start.y, top_y, normal, end.y)
	# Visual completion only: close the open base ends and the notches the
	# per-run offset planes leave at convex junction corners, then cap the whole
	# base with one mitered band instead of overlapping per-run boxes.
	var cap_y := front.projecting_base_cap_y as Array
	var cap_bottom := float(cap_y[0])
	var first := _run_frame(record, runs[0])
	var last := _run_frame(record, runs[runs.size() - 1])
	var first_start := first.start as Vector3
	var last_end := last.end as Vector3
	_append_vertical_face(base, first_start, first_start + (first.normal as Vector3) * projection, first_start.y, cap_bottom, -(first.tangent as Vector3))
	_append_vertical_face(base, last_end + (last.normal as Vector3) * projection, last_end, last_end.y, cap_bottom, last.tangent as Vector3)
	for index in range(1, runs.size()):
		var previous := _run_frame(record, runs[index - 1])
		var current := _run_frame(record, runs[index])
		var previous_normal := previous.normal as Vector3
		var current_normal := current.normal as Vector3
		if (current.tangent as Vector3).dot(previous_normal) > -0.05:
			continue
		var corner := previous.end as Vector3
		var miter := corner + _miter_between(previous_normal, current_normal) * projection
		_append_vertical_face(base, corner + previous_normal * projection, miter, corner.y, cap_bottom, previous_normal)
		_append_vertical_face(base, miter, corner + current_normal * projection, corner.y, cap_bottom, current_normal)
	var path := _chain_points(record, runs, 0.0, _chain_length(record, runs))
	_append_path_band(base, path, cap_bottom, float(cap_y[1]), float(front.projecting_base_cap_front), 0.0)


## Rusticated courses on the accepted projecting base: mitered bands proud of
## the base plane, so the joints read as recessed without touching collision.
## The open door (hole, its center_m measured along runs) splits the courses; their
## ends hide behind its dark border.
static func _append_base_rustication(base: Dictionary, record: Dictionary, runs: Array[int], front: Dictionary, hole: Dictionary = {}, gaps: Array = []) -> void:
	var trim := float(front.rustication_end_trim)
	var cuts: Array[Vector2] = []
	if not hole.is_empty():
		var gap := float(hole.half) + 0.05
		cuts.append(Vector2(float(hole.center_m) - gap, float(hole.center_m) + gap))
	for gap_value in gaps:
		cuts.append(gap_value as Vector2)
	cuts.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	var spans: Array[Vector2] = []
	var from_m := trim
	for cut in cuts:
		if cut.x > from_m:
			spans.append(Vector2(from_m, cut.x))
		from_m = maxf(from_m, cut.y)
	spans.append(Vector2(from_m, _chain_length(record, runs) - trim))
	var tops := front.rustication_course_tops_y as Array
	var joint := float(front.rustication_joint_height)
	var face := float(front.rustication_front)
	var back := float(front.rustication_back)
	for span in spans:
		var path := _chain_points(record, runs, span.x, span.y)
		for index in tops.size():
			if index == 0:
				_append_path_band(base, path, -0.06, float(tops[0]), face, back, true)
			else:
				_append_path_band(base, path, float(tops[index - 1]) + joint, float(tops[index]), face, back)


static func _crescent_layout(record: Dictionary, runs: Array[int], count: int, front: Dictionary) -> Dictionary:
	var start := float(front.crescent_field_start_m)
	var end := _chain_length(record, runs) - float(front.crescent_field_end_trim_m)
	var pier := float(front.crescent_pier_width)
	var surround := float((front.crescent_window_style as Dictionary).surround)
	var glass := ((end - start) - float(count + 1) * pier - float(count) * 2.0 * surround) / float(count)
	var pitch := pier + glass + 2.0 * surround
	var piers: Array[float] = []
	var windows: Array[float] = []
	for index in count + 1:
		piers.append(start + pier * 0.5 + float(index) * pitch)
	for index in count:
		windows.append(start + pier + surround + glass * 0.5 + float(index) * pitch)
	return {"piers": piers, "windows": windows, "glass": glass, "pitch": pitch, "pier": pier, "surround": surround}


## Eleven complete two-story bays: dark eighteen-light glazing behind pale
## surrounds and a head band of three rolls under a dentil course between broad
## fluted piers. The piers stop under the attic frieze (_append_crescent_attic) and
## rise from just over the canopy, whose fascia stops below the sills (the owner's
## 2026-11-20 photos). Piers project past the windows so the glazing reads recessed;
## nothing cuts the exact wall or its collision.
static func _append_crescent_bays(buckets: Dictionary, record: Dictionary, runs: Array[int], layout: Dictionary, front: Dictionary) -> void:
	var glass := float(layout.glass)
	var surround := float(layout.surround)
	var pier := float(layout.pier)
	var window_y := front.crescent_window_y as Array
	var style := front.crescent_window_style as Dictionary
	for center_value in layout.windows as Array:
		var center_m := float(center_value)
		var reach := glass * 0.5 + surround + 0.12
		var frame := _span_frame(record, runs, center_m - reach, center_m + reach)
		var center := center_m - float(frame.mid_m)
		var grid := front.crescent_window_grid as Array
		_append_window_module(buckets, frame, center, glass, float(window_y[0]), float(window_y[1]), int(grid[0]), int(grid[1]), style)
		# The bronze grille over the steel window: paired bars with short rungs.
		_append_bronze_grille(buckets.bronze, frame, center, glass, float(window_y[0]), float(window_y[1]), float(frame.hi), front.crescent_grille as Dictionary)
		# Three bold rolls from pier to pier under pale block dentils (the owner's
		# 2026-11-20 close-ups), in relief.
		var head_reach := glass * 0.5 + surround + 0.04
		var back := float(frame.lo) - float(frame.hi) - 0.03
		var rolls := front.crescent_head_rolls as Dictionary
		var rolls_y := rolls.y as Array
		_append_profile_sweep(buckets.trim, _frame_path(frame, center - head_reach, center + head_reach, float(frame.hi)), _rolls_profile(float(rolls_y[0]), float(rolls_y[1]), float(rolls.face), back, 3, float(rolls.radius), float(rolls.pitch)), true)
		var dentils := front.crescent_head_dentils as Dictionary
		var dentil_y := dentils.y as Array
		var span := head_reach * 2.0 - 0.16
		_append_dentil_blocks(buckets.trim, frame, center - span * 0.5, center + span * 0.5, float(dentil_y[0]), float(dentil_y[1]), float(frame.lo) - 0.03, float(frame.hi) + float(dentils.front), float(dentils.width), roundi(span / float(dentils.pitch)))
	var pier_y := front.crescent_pier_y as Array
	for center_value in layout.piers as Array:
		var center_m := float(center_value)
		var frame := _span_frame(record, runs, center_m - pier * 0.5 - 0.1, center_m + pier * 0.5 + 0.1)
		var center := center_m - float(frame.mid_m)
		_append_fluted_pier(buckets.trim, frame, center, pier, float(pier_y[0]), float(pier_y[1]), float(front.crescent_pier_depth), int(front.crescent_pier_reeds), float(front.crescent_pier_reed_width), float(front.crescent_pier_reed_gap), float(front.crescent_pier_reed_front), buckets.groove)


## The crescent's attic (the owner's 2026-11-20 photos; the 2003 nomination's
## "horizontal ribbing near the roof"): a plain frieze over the pier tops carrying a
## group of incised lines, closed by a thin flat coping with one line in it and little
## overhang. A thin skin over the front block's face, from over the head bands up to
## the coping, closes the field between the pier tops, so the attic reads as one plane.
## The lines are the stucco's line pattern (_append_lined_band), steady at any range;
## the skin and coping shade smoothly across the source runs' kinks. The skin follows
## the face (`face_path`); the coping also turns back along the set-down north cap
## (`capped_path`) and closes its back above the block's roof. Visual only; the exact
## faces and their collision are unchanged.
static func _append_crescent_attic(buckets: Dictionary, face_path: Dictionary, capped_path: Dictionary, attic: Dictionary, coping_back: float) -> void:
	var skin := attic.skin_y as Array
	var lines := attic.lines as Dictionary
	var skin_front := float(attic.skin_front)
	var skin_back := float(attic.skin_back)
	var lines_bottom := float(lines.bottom)
	var lines_top := lines_bottom + float(lines.pitch) * float(lines.count)
	_append_pattern_band(buckets.trim, face_path, float(skin[0]), lines_bottom, skin_front, skin_back, 1.0, 0.0, 1.0, Vector2(0.5, 0.5), 1 | 4)
	_append_profile_sweep(buckets.trim, face_path, _rolls_profile(lines_bottom, lines_top, skin_front, skin_back, int(lines.count), float(lines.radius), float(lines.pitch)), true)
	_append_pattern_band(buckets.trim, face_path, lines_top, float(skin[1]), skin_front, skin_back, 1.0, 0.0, 1.0, Vector2(0.5, 0.5), 2 | 4)
	var coping := attic.coping as Array
	var coping_line := attic.coping_line as Dictionary
	_append_profile_sweep(buckets.trim, capped_path, _coping_profile(float(coping[0]), float(coping[1]), float(coping[2]), coping_back, 1, float(coping_line.radius), float(coping_line.pitch), float(coping_line.cap_height), float(coping_line.cap_overhang)), true)


## Three glazed-bronze triple-door groups under the crescent bays the dated WSW
## view shows as dark entrance openings (bays 2, 5 and 8): doors and a
## bronze-barred transom set in a dark reveal, framed by a solid pale portal
## whose jambs reach the ground and whose head sits just under the canopy.
## Bronze relief stays shallow for oblique gameplay rays; nothing is cut from
## the accepted projecting-base plane or its collision.
## Each entrance group's frame on the exact crescent with the door's place in it:
## the frame (_span_frame), its bay and chain metre, the group's centre (lateral)
## and half width, the projecting base's face and the reveal's back (signed depth),
## the base, the doors' head and the transom's bottom and top.
static func _entry_frames(record: Dictionary, runs: Array[int], layout: Dictionary, bays: Array, front: Dictionary) -> Array[Dictionary]:
	var windows := layout.windows as Array
	var base_face := float(front.projecting_base_depth)
	var half := float(front.entrance_group_width) * 0.5
	var reach := half + float(front.entrance_reveal_border) + float(front.entrance_portal_jamb_width) + 0.1
	var frames: Array[Dictionary] = []
	var entry_base := -INF
	for bay_value in bays:
		var center_m := float(windows[int(bay_value)])
		var frame := _span_frame(record, runs, center_m - reach, center_m + reach)
		frame["bay"] = int(bay_value)
		frame["center_m"] = center_m
		frame["center"] = center_m - float(frame.mid_m)
		frame["half"] = half
		frame["face"] = base_face + float(frame.hi)
		frame["back"] = base_face + float(frame.lo) - 0.02
		frame["base_y"] = minf(float(frame.base_a), float(frame.base_b))
		frame["top_y"] = float(frame.base_y) + float(front.entrance_door_height)
		frames.append(frame)
		entry_base = maxf(entry_base, maxf(float(frame.base_a), float(frame.base_b)))
	# One level transom line for all three groups despite the sloping base.
	var transom_top := entry_base + float(front.entrance_transom_top_above_base)
	for frame in frames:
		frame["transom"] = [float(frame.top_y) + float(front.entrance_frame_width), transom_top]
	return frames


## The open bay's doors stand open into the vestibule, out of view: its door glass,
## mid rails and the lower mullions go, and its dark reveal stays only as the
## border round the opening and the band behind the transom.
static func _append_entry_composition(buckets: Dictionary, collision: Dictionary, frames: Array[Dictionary], doors_per_group: int, front: Dictionary, open_bay: int = -1) -> void:
	var group_width := float(front.entrance_group_width)
	var half := group_width * 0.5
	var border := float(front.entrance_reveal_border)
	var bar := float(front.entrance_frame_width)
	var bronze_front := float(front.entrance_frame_front)
	var jamb_width := float(front.entrance_portal_jamb_width)
	var jamb_front := float(front.entrance_portal_front)
	var head_y := front.entrance_portal_head_y as Array
	var head_bottom := float(head_y[0])
	for frame in frames:
		var center := float(frame.center)
		var face := float(frame.face)
		var back := float(frame.back)
		var base_y := float(frame.base_y)
		var door_top := float(frame.top_y)
		var transom := frame.transom as Array
		var transom_bottom := float(transom[0])
		var transom_top := float(transom[1])
		var open := int(frame.bay) == open_bay
		# The reveal front clears the rustication courses so they cannot streak
		# through the dark opening.
		if open:
			for side in [-1.0, 1.0]:
				var edge := center + float(side) * half
				var rim := center + float(side) * (half + border)
				_append_frame_box(buckets.reveal, frame, minf(edge, rim), maxf(edge, rim), base_y - border, head_bottom + 0.03, back, face + 0.06)
			_append_frame_box(buckets.reveal, frame, center - half, center + half, door_top, head_bottom + 0.03, back, face + 0.06)
		else:
			_append_frame_box(buckets.reveal, frame, center - half - border, center + half + border, base_y - border, head_bottom + 0.03, back, face + 0.06)
			_append_frame_box(buckets.glass, frame, center - half, center + half, base_y, door_top, face + 0.05, face + 0.1)
		_append_frame_box(buckets.glass, frame, center - half, center + half, transom_bottom, transom_top, face + 0.05, face + 0.1)
		for leaf in range(doors_per_group + 1):
			var x := center - half + group_width * float(leaf) / float(doors_per_group)
			var inner_leaf := leaf > 0 and leaf < doors_per_group
			var bottom := door_top if open and inner_leaf else base_y - bar * 0.5
			_append_frame_box(buckets.public_bronze, frame, x - bar * 0.5, x + bar * 0.5, bottom, transom_top + bar * 0.5, face + 0.09, face + bronze_front)
		for rail in [base_y, door_top + bar * 0.5, transom_top]:
			var y := float(rail)
			if open and y < door_top:
				continue
			_append_frame_box(buckets.public_bronze, frame, center - half - bar * 0.5, center + half + bar * 0.5, y - bar * 0.5, y + bar * 0.5, face + 0.092, face + bronze_front - 0.004)
		# Kick plates on the closed leaves (the owner's 2026-11-20 frontal view).
		if not open:
			var kick := float(front.entrance_kick_plate_height)
			for leaf in doors_per_group:
				var left := center - half + group_width * float(leaf) / float(doors_per_group) + bar * 0.5
				var right := center - half + group_width * float(leaf + 1) / float(doors_per_group) - bar * 0.5
				_append_frame_box(buckets.public_bronze, frame, left, right, base_y, base_y + kick, face + 0.09, face + bronze_front - 0.02)
		# Pale portal jambs where the photos show them; round piers stand between the
		# central door groups instead (_append_round_piers).
		if jamb_width > 0.0:
			for side in [-1.0, 1.0]:
				var inner := center + float(side) * (half + border)
				var outer := center + float(side) * (half + border + jamb_width)
				for target: Dictionary in [buckets.trim, collision]:
					_append_frame_box(target, frame, minf(inner, outer), maxf(inner, outer), base_y - 0.06, head_bottom + 0.02, back, face + jamb_front)
		var head_reach := half + border + jamb_width + 0.08
		_append_frame_box(buckets.trim, frame, center - head_reach, center + head_reach, head_bottom, float(head_y[1]), back, face + float(front.entrance_portal_head_front))


## Ground-floor windows in the crescent bays either side of the door groups (the
## National Register nomination's three-light casements with fixed lights above; the
## owner's 2026-11-20 frontal view): set in the projecting base's face under the
## canopy, from a sill over the sloping base up to the door groups' transom line.
static func _append_ground_floor_windows(buckets: Dictionary, record: Dictionary, runs: Array[int], layout: Dictionary, door_bays: Array, front: Dictionary) -> void:
	var spec := front.ground_floor_window as Dictionary
	var width := float(spec.width)
	var base_face := float(front.projecting_base_depth)
	var style := (front.wing_window_style as Dictionary).duplicate()
	var doors := _int_array(door_bays)
	var windows := layout.windows as Array
	for bay in windows.size():
		if doors.has(bay):
			continue
		var center_m := float(windows[bay])
		var reach := width * 0.5 + float(style.surround) + 0.2
		var frame := _span_frame(record, runs, center_m - reach, center_m + reach)
		frame["hi"] = float(frame.hi) + base_face
		frame["lo"] = float(frame.lo) + base_face
		var base := maxf(float(frame.base_a), float(frame.base_b))
		_append_bronze_window(buckets, frame, center_m - float(frame.mid_m), width, base + float(spec.bottom_above_base), base + float(spec.top_above_base), int(spec.columns), int(spec.rows), spec)


## A flush bronze-framed window in the projecting base (the owner's 2026-11-20
## frontal view): dark glazing set just behind a bronze frame and its mullions and
## transom, no stucco surround or sill.
static func _append_bronze_window(buckets: Dictionary, frame: Dictionary, center: float, width: float, bottom: float, top: float, columns: int, rows: int, spec: Dictionary) -> void:
	var wall := float(frame.hi)
	var back := float(frame.lo) - 0.03
	var half := width * 0.5
	var bar := float(spec.bar)
	var bronze := buckets.public_bronze as Dictionary
	_append_frame_box(buckets.reveal, frame, center - half - 0.02, center + half + 0.02, bottom - 0.02, top + 0.02, back, wall + 0.01)
	_append_frame_box(buckets.glass, frame, center - half, center + half, bottom, top, back, wall + 0.02)
	for column in range(columns + 1):
		var x := center - half + width * float(column) / float(columns)
		var w := bar * (1.6 if column == 0 or column == columns else 1.0)
		_append_frame_box(bronze, frame, x - w * 0.5, x + w * 0.5, bottom - 0.03, top + 0.03, wall + 0.015, wall + 0.06)
	var transom := lerpf(bottom, top, float(spec.transom_fraction))
	for y in [bottom, transom, top]:
		var h := bar * (1.6 if y != transom else 1.2)
		_append_frame_box(bronze, frame, center - half - 0.03, center + half + 0.03, float(y) - h * 0.5, float(y) + h * 0.5, wall + 0.015, wall + 0.058)


## Round banded piers between the ground floor's openings (the owner's 2026-11-20
## frontal view): half-round shafts on the projecting base under each crescent pier,
## from the base to the canopy's soffit, ringed by raised bands. Solid, as drawn.
static func _append_round_piers(buckets: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], layout: Dictionary, front: Dictionary) -> void:
	var spec := front.ground_floor_round_piers as Dictionary
	var half := float(spec.half_width)
	var relief := float(spec.relief)
	var top := float((front.canopy as Dictionary).soffit_y)
	var base_face := float(front.projecting_base_depth)
	var piers := layout.piers as Array
	for index in range(int(spec.first), piers.size() - int(spec.skip_last)):
		var center_m := float(piers[index])
		var frame := _span_frame(record, runs, center_m - half - 0.1, center_m + half + 0.1)
		var center := center_m - float(frame.mid_m)
		var face := float(frame.hi) + base_face - 0.01
		var bottom := minf(float(frame.base_a), float(frame.base_b)) - 0.06
		for target: Dictionary in [buckets.base, collision]:
			_append_reed(target, frame, center, half, relief, face, bottom, top, 0.0, 8)
		for band_value in spec.bands_above_base as Array:
			var y := maxf(float(frame.base_a), float(frame.base_b)) + float(band_value)
			_append_reed(buckets.base, frame, center, half + float(spec.band_out), relief + float(spec.band_out), face, y, y + float(spec.band_height), 0.0, 8)


## Chain metres the ground-floor windows take out of the base's rustication courses.
static func _ground_window_gaps(layout: Dictionary, door_bays: Array, front: Dictionary) -> Array:
	var spec := front.ground_floor_window as Dictionary
	var half := float(spec.width) * 0.5 + float((front.wing_window_style as Dictionary).surround) + 0.06
	var doors := _int_array(door_bays)
	var gaps: Array = []
	var windows := layout.windows as Array
	for bay in windows.size():
		if not doors.has(bay):
			gaps.append(Vector2(float(windows[bay]) - half, float(windows[bay]) + half))
	return gaps


## The interior's plan (building_1_interior.gd) from this record's exact crescent:
## its vertices, the twelve pier and eleven window anchors, and the door groups.
static func _interior_plan(record: Dictionary, config: Dictionary, front: Dictionary) -> Dictionary:
	var schedule := config.facade_schedule as Dictionary
	var field_runs := _int_array(schedule.crescent_field_runs)
	var crescent := _crescent_layout(record, field_runs, int(schedule.central_window_count), front)
	var points := PackedVector2Array()
	for run_index in field_runs:
		var start := _run_frame(record, run_index).start as Vector3
		points.append(Vector2(start.x, start.z))
	var last := _run_frame(record, field_runs[field_runs.size() - 1]).end as Vector3
	points.append(Vector2(last.x, last.z))
	var piers: Array = []
	for chain_m: Variant in crescent.piers:
		piers.append(_chain_frame(record, field_runs, float(chain_m)).wall_anchor)
	var windows: Array = []
	for chain_m: Variant in crescent.windows:
		windows.append(_chain_frame(record, field_runs, float(chain_m)).wall_anchor)
	var doors := {}
	for frame in _entry_frames(record, field_runs, crescent, schedule.entrance_bays as Array, front):
		doors[int(frame.bay)] = frame
	return INTERIOR.plan({"front": points, "piers": piers, "windows": windows, "window_glass": float(crescent.glass), "window_y": front.crescent_window_y, "doors": doors})


## Tall crescent-height glazing on the south junction block's west faces,
## where the dated WSW view shows windows on the block that ends the crescent.
static func _append_junction_windows(buckets: Dictionary, record: Dictionary, specs: Array, front: Dictionary) -> void:
	var window_y := front.crescent_window_y as Array
	# Same family as the crescent bays; the sill returns past free-standing jambs.
	var style := (front.crescent_window_style as Dictionary).duplicate()
	style["sill_overhang"] = 0.06
	for spec_value in specs:
		var spec := spec_value as Dictionary
		var runs: Array[int] = [int(spec.run)]
		var frame := _span_frame(record, runs, 0.0, _chain_length(record, runs))
		_append_window_module(buckets, frame, 0.0, float(spec.glass_width), float(window_y[0]), float(window_y[1]), int(spec.columns), 6, style)


## Wing face: eight aligned upper bays on the second and third floors and seven
## lower ground-floor bays centred between them.
static func _append_wing_facade(buckets: Dictionary, record: Dictionary, runs: Array[int], upper_count: int, lower_count: int, floors: Array, front: Dictionary, door_index: int) -> void:
	var length := _chain_length(record, runs)
	var upper := _evenly_spaced(length, upper_count, float(front.wing_window_margin_m))
	# Seven lower windows and one door, each under an upper window (the National
	# Register nomination; the owner's 2026-11-20 photos).
	var lower: Array[float] = []
	for index in upper.size():
		if index != door_index and lower.size() < lower_count:
			lower.append(upper[index])
	var glass := float(front.wing_window_width)
	# Both wing faces front the forecourt the player crosses on foot.
	var style := (front.wing_window_style as Dictionary).duplicate()
	style["reveal_depth"] = true
	var upper_floor := floors[1] as Dictionary
	_append_window_grid(buckets, record, runs, upper, glass, [upper_floor], style)
	_append_window_grid(buckets, record, runs, lower, glass, [floors[0]], style)
	# Each upper window sits in a recessed panel reaching below its sill, under a row
	# of dentils (the nomination's "recessed panel with fluted detail centered below
	# and above dentils"; the owner's photos): the panel's pale border, the dentil row
	# inside its head.
	var panel := front.wing_upper_panel as Dictionary
	var surround := float(style.surround)
	var margin := float(panel.panel_margin)
	var bar := 0.08
	var panel_front := float(panel.panel_front)
	var dentil_y := panel.dentils as Array
	var top := float(upper_floor.top)
	var panel_bottom := float(upper_floor.bottom) - float(panel.below)
	var panel_top := top + float(dentil_y[1]) + 0.06
	for center_m in upper:
		var half := glass * 0.5 + surround + margin
		var frame := _span_frame(record, runs, center_m - half - 0.1, center_m + half + 0.1)
		var center := center_m - float(frame.mid_m)
		var back := float(frame.lo) - 0.03
		var wall := float(frame.hi)
		for side in [-1.0, 1.0]:
			var outer := center + float(side) * half
			var inner := center + float(side) * (half - bar)
			_append_frame_box(buckets.trim, frame, minf(outer, inner), maxf(outer, inner), panel_bottom, panel_top, back, wall + panel_front)
		_append_frame_box(buckets.trim, frame, center - half, center + half, panel_top - bar, panel_top, back, wall + panel_front)
		_append_frame_box(buckets.trim, frame, center - half, center + half, panel_bottom, panel_bottom + bar, back, wall + panel_front)
		var dentil_span := (half - bar) * 2.0 - 0.06
		_append_dentil_blocks(buckets.trim, frame, center - dentil_span * 0.5, center + dentil_span * 0.5, top + float(dentil_y[0]), top + float(dentil_y[1]), back, wall + float(panel.dentil_front), float(panel.dentil_width), roundi(dentil_span / float(panel.dentil_pitch)))
	var course := front.wing_string_course as Array
	_append_path_band(buckets.trim, _chain_points(record, runs, 0.0, length), float(course[0]), float(course[1]), float(course[2]), -0.03)
	# The wing's door: a glazed double door with a transom up to the lower windows' head.
	if door_index >= 0 and door_index < upper.size():
		var doors := front.wing_doors as Dictionary
		var center_m := upper[door_index]
		var door_half := float(doors.width) * 0.5
		var frame := _span_frame(record, runs, center_m - door_half - 0.4, center_m + door_half + 0.4)
		var center := center_m - float(frame.mid_m)
		var base := minf(float(frame.base_a), float(frame.base_b))
		var head := float((floors[0] as Dictionary).top)
		var transom := head - float(doors.transom)
		var wall := float(frame.hi)
		var back := float(frame.lo) - 0.03
		_append_frame_box(buckets.reveal, frame, center - door_half - 0.08, center + door_half + 0.08, base - 0.1, head + 0.05, back, wall + 0.03)
		_append_frame_box(buckets.glass, frame, center - door_half, center + door_half, base - 0.05, head, wall + 0.04, wall + 0.07)
		_append_frame_box(buckets.frame, frame, center - door_half, center + door_half, transom - 0.04, transom + 0.04, wall + 0.06, wall + 0.11)
		_append_frame_box(buckets.frame, frame, center - 0.035, center + 0.035, base - 0.05, transom, wall + 0.06, wall + 0.11)
		for side in [-1.0, 1.0]:
			var inner := center + float(side) * (door_half + 0.08)
			var outer := center + float(side) * (door_half + 0.08 + surround)
			_append_frame_box(buckets.trim, frame, minf(inner, outer), maxf(inner, outer), base - 0.06, head + surround, back, wall + float(style.jamb_front))
		_append_frame_box(buckets.trim, frame, center - door_half - 0.08 - surround, center + door_half + 0.08 + surround, head, head + surround, back, wall + float(style.head_front))


## Aligned bays on one exact run chain, one complete window per listed floor.
static func _append_window_grid(buckets: Dictionary, record: Dictionary, runs: Array[int], centers: Array, glass: float, floors: Array, style: Dictionary, columns: int = 2) -> void:
	for center_value in centers:
		for floor_value in floors:
			var floor_spec := floor_value as Dictionary
			_append_chain_window(buckets, record, runs, float(center_value), glass, float(floor_spec.bottom), float(floor_spec.top), columns, int(floor_spec.rows), style)


## North crescent-wing junction: one stacked wing-family bay on each face long
## enough for a complete window (runs 17 and 20). The dated SW view shows
## wing-scale openings continuing there to the first crescent bay, with plain
## wall at the short jog faces between them (runs 18-19); its lowest floor is
## hidden by parked cars, so that floor follows the wing schedule.
static func _append_north_junction_bays(buckets: Dictionary, record: Dictionary, specs: Array, floors: Array, style: Dictionary) -> void:
	for spec_value in specs:
		var spec := spec_value as Dictionary
		var runs: Array[int] = [int(spec.run)]
		_append_window_grid(buckets, record, runs, [_chain_length(record, runs) * 0.5], float(spec.glass_width), floors, style, int(spec.columns))


## Even bay layout for a podium ribbon between chain metres. Pier centres run
## from `first` to `last` at `pitch`; a butted end has no pier of its own.
static func _ribbon_layout(from_m: float, to_m: float, start_pier: bool, end_pier: bool, ribbon: Dictionary) -> Dictionary:
	var pier := float(ribbon.pier_width)
	var first := from_m + (pier * 0.5 if start_pier else 0.0)
	var last := to_m - (pier * 0.5 if end_pier else 0.0)
	var bays := maxi(1, roundi((last - first) / float(ribbon.bay_pitch)))
	return {"first": first, "last": last, "bays": bays, "pitch": (last - first) / float(bays)}


## Continuous lower ribbon on a podium chain: dark glazing between a sill and a
## head band, with transom bars, narrow piers at an even bay pitch and light
## mullions in each bay. Bands follow the exact runs with mitered corners;
## piers and mullions use short chord frames. A free end closes with a pier
## that buries the glazing end; a butted end stops against an existing pier.
static func _append_ribbon(buckets: Dictionary, record: Dictionary, runs: Array[int], from_m: float, to_m: float, start_pier: bool, end_pier: bool, ribbon: Dictionary) -> void:
	var layout := _ribbon_layout(from_m, to_m, start_pier, end_pier, ribbon)
	var first := float(layout.first)
	var pitch := float(layout.pitch)
	var bays := int(layout.bays)
	var bottom := float(ribbon.bottom)
	var top := float(ribbon.top)
	var bar := float(ribbon.bar)
	var pier := float(ribbon.pier_width)
	var band := _chain_points(record, runs, from_m, to_m)
	var glazing := _chain_points(record, runs, first, float(layout.last))
	_append_path_band(buckets.glass, glazing, bottom, top, 0.035, -0.03)
	_append_path_band(buckets.trim, band, bottom - float(ribbon.sill_height), bottom, float(ribbon.sill_front), -0.03)
	_append_path_band(buckets.trim, band, top, top + float(ribbon.head_height), float(ribbon.head_front), -0.03)
	var rows := int(ribbon.rows)
	for row in range(1, rows):
		var y := lerpf(bottom, top, float(row) / float(rows))
		_append_path_band(buckets.frame, glazing, y - bar * 0.5, y + bar * 0.5, 0.074, 0.033)
	for index in range(bays + 1):
		if (index == 0 and not start_pier) or (index == bays and not end_pier):
			continue
		var center_m := first + pitch * float(index)
		var frame := _span_frame(record, runs, center_m - pier * 0.5, center_m + pier * 0.5)
		_append_frame_box(buckets.trim, frame, -pier * 0.5, pier * 0.5, bottom, top, float(frame.lo) - 0.03, float(frame.hi) + float(ribbon.pier_front))
	var columns := int(ribbon.columns)
	for index in range(bays):
		var left := first + pitch * float(index) + (pier * 0.5 if index > 0 or start_pier else 0.0)
		var right := first + pitch * float(index + 1) - (pier * 0.5 if index < bays - 1 or end_pier else 0.0)
		for column in range(1, columns):
			var mullion_m := lerpf(left, right, float(column) / float(columns))
			var frame := _span_frame(record, runs, mullion_m - bar, mullion_m + bar)
			_append_frame_box(buckets.frame, frame, -bar * 0.5, bar * 0.5, bottom, top, float(frame.hi) + 0.03, float(frame.hi) + 0.078)


static func _append_chain_window(buckets: Dictionary, record: Dictionary, runs: Array[int], center_m: float, glass: float, bottom: float, top: float, columns: int, rows: int, style: Dictionary) -> void:
	var reach := glass * 0.5 + float(style.surround) + float(style.sill_overhang) + 0.05
	var frame := _span_frame(record, runs, center_m - reach, center_m + reach)
	var setback := float(style.get("setback_m", 0.0))
	if setback != 0.0:
		frame["anchor"] = (frame.anchor as Vector3) - (frame.normal as Vector3) * setback
	_append_window_module(buckets, frame, center_m - float(frame.mid_m), glass, bottom, top, columns, rows, style)


## One complete window: dark glazing set back behind pale jambs, a head and a
## projecting sill, carrying a dark metal glazing grid. Depths are measured from
## the module span's exact wall points; no source wall or collision is cut.
static func _append_window_module(buckets: Dictionary, frame: Dictionary, center: float, glass_width: float, bottom: float, top: float, columns: int, rows: int, style: Dictionary) -> void:
	var back := float(frame.lo) - 0.03
	var wall := float(frame.hi)
	var half := glass_width * 0.5
	var surround := float(style.surround)
	var edge_bar := float(style.edge_bar)
	var bar := float(style.bar)
	var transom_row := int(style.get("transom_row", -1))
	var transom_bar := float(style.get("transom_bar", bar))
	var bar_front := float(style.get("bar_front", 0.078))
	_append_frame_box(buckets.glass, frame, center - half, center + half, bottom, top, back, wall + 0.035)
	var metal := buckets[str(style.get("frame_bucket", "frame"))] as Dictionary
	# Narrow side lights (the pavilions' tall windows): the outer columns take
	# `side_light` of the width each, the rest share the middle evenly.
	var side_light := float(style.get("side_light", 0.0))
	for column in range(columns + 1):
		var fraction := float(column) / float(columns)
		if side_light > 0.0 and columns > 2 and column > 0 and column < columns:
			fraction = side_light + (1.0 - side_light * 2.0) * float(column - 1) / float(columns - 2)
		var x := center - half + glass_width * fraction
		var width := edge_bar if column == 0 or column == columns else bar
		_append_frame_box(metal, frame, x - width * 0.5, x + width * 0.5, bottom, top, wall + 0.03, wall + bar_front)
	for row in range(rows + 1):
		var y := lerpf(bottom, top, float(row) / float(rows))
		var height := edge_bar if row == 0 or row == rows else (transom_bar if row == transom_row else bar)
		_append_frame_box(metal, frame, center - half, center + half, y - height * 0.5, y + height * 0.5, wall + 0.033, wall + bar_front - 0.004)
	var jamb_front := wall + float(style.jamb_front)
	for side in [-1.0, 1.0]:
		var inner := center + float(side) * half
		var outer := center + float(side) * (half + surround + 0.03)
		_append_frame_box(buckets.trim, frame, minf(inner, outer), maxf(inner, outer), bottom - 0.04, top + 0.04, back, jamb_front)
	_append_frame_box(buckets.trim, frame, center - half - surround - 0.01, center + half + surround + 0.01, top, top + float(style.head_height), back, wall + float(style.head_front))
	if bool(style.get("stepped_hood", false)):
		# Two-step Art Deco hood over the head (Sep/Nov 2025 north and SE views).
		var head_top := top + float(style.head_height)
		_append_frame_box(buckets.trim, frame, center - half - surround - 0.12, center + half + surround + 0.12, head_top, head_top + 0.12, back, wall + float(style.head_front) + 0.06)
		_append_frame_box(buckets.trim, frame, center - half - 0.05, center + half + 0.05, head_top + 0.12, head_top + 0.26, back, wall + float(style.head_front))
	var sill_reach := half + surround + float(style.sill_overhang)
	_append_frame_box(buckets.trim, frame, center - sill_reach, center + sill_reach, bottom - float(style.sill_height), bottom, back, wall + float(style.sill_front))
	# Stepped double reveal (2008 crescent window detail): a narrow inner frame
	# between the glazing and the main surround, one step shallower than it.
	var inner_step := style.get("inner_step", []) as Array
	if inner_step.size() == 2:
		var step_width := float(inner_step[0])
		var step_front := wall + float(inner_step[1])
		for side in [-1.0, 1.0]:
			var edge := center + float(side) * half
			var inside := center + float(side) * (half - step_width)
			_append_frame_box(buckets.trim, frame, minf(edge, inside), maxf(edge, inside), bottom, top, back, step_front)
		_append_frame_box(buckets.trim, frame, center - half, center + half, top - step_width, top, back, step_front)
		_append_frame_box(buckets.trim, frame, center - half, center + half, bottom, bottom + step_width, back, step_front)
	_append_reveal_depth(buckets, frame, center, half, surround, sill_reach, bottom, top, style)


## Deeper reveal on the facades the player approaches on foot (styles marked
## reveal_depth): the jambs, head and sill continue forward so the glazing
## sits visibly behind its surround and takes contact shadow. Visual only, so
## it stops at modules whose sill is within reach of the ground, and a style's
## reveal_front_max keeps it behind neighbouring piers and fins.
static func _append_reveal_depth(buckets: Dictionary, frame: Dictionary, center: float, half: float, surround: float, sill_reach: float, bottom: float, top: float, style: Dictionary) -> void:
	if not bool(style.get("reveal_depth", false)) or not buckets.has("reveal_depth") or not frame.has("base_a") or not frame.has("base_b"):
		return
	var settings := buckets.window_settings as Dictionary
	var ground := maxf(float(frame.base_a), float(frame.base_b))
	if bottom - float(style.sill_height) - ground < float(settings.clearance):
		return
	var extra := float(settings.extra)
	var wall := float(frame.hi)
	var limit := wall + float(style.get("reveal_front_max", INF))
	var target := buckets.reveal_depth as Dictionary
	var jamb_front := wall + float(style.jamb_front)
	if minf(jamb_front + extra, limit) > jamb_front:
		for side in [-1.0, 1.0]:
			var inner := center + float(side) * half
			var outer := center + float(side) * (half + surround + 0.03)
			_append_frame_box(target, frame, minf(inner, outer), maxf(inner, outer), bottom - 0.04, top + 0.04, jamb_front, minf(jamb_front + extra, limit))
	var head_front := wall + float(style.head_front)
	if minf(head_front + extra, limit) > head_front:
		_append_frame_box(target, frame, center - half - surround - 0.01, center + half + surround + 0.01, top, top + float(style.head_height), head_front, minf(head_front + extra, limit))
	var sill_front := wall + float(style.sill_front)
	if minf(sill_front + extra * 0.6, limit) > sill_front:
		_append_frame_box(target, frame, center - sill_reach, center + sill_reach, bottom - float(style.sill_height), bottom, sill_front, minf(sill_front + extra * 0.6, limit))


## Optional coping and a pipe guardrail along a roof edge path. The coping
## straddles the wall top; posts stand inside it at an even pitch along each
## mitred segment and two rails run between them. Every part is also emitted
## into collision, because the roof behind is reachable by jetpack.
static func _append_podium_edge(trim: Dictionary, collision: Dictionary, path: Dictionary, edge: Dictionary, roof_y: float, with_coping: bool) -> void:
	var coping := edge.coping as Array
	if with_coping:
		for target: Dictionary in [trim, collision]:
			_append_path_band(target, path, roof_y + float(coping[0]), roof_y + float(coping[1]), float(coping[2]), float(coping[3]), false, false, true)
	var inset := float(edge.rail_inset)
	var thickness := float(edge.rail_thickness)
	var base := roof_y + (float(coping[1]) if with_coping else 0.0)
	for bar_value in edge.rail_bars as Array:
		var bar := bar_value as Array
		for target: Dictionary in [trim, collision]:
			_append_path_band(target, path, roof_y + float(bar[0]), roof_y + float(bar[1]), -inset + thickness * 0.5, -inset - thickness * 0.5, false, false, true)
	var points := path.points as Array
	var normals := path.normals as Array
	var spacing := float(edge.rail_post_spacing)
	var post := float(edge.rail_post_width)
	var top := roof_y + float(edge.rail_height)
	for segment in normals.size():
		var a := points[segment] as Vector3
		var b := points[segment + 1] as Vector3
		var normal := normals[segment] as Vector3
		var flat := Vector3(b.x - a.x, 0.0, b.z - a.z)
		var length := flat.length()
		if length < 0.05:
			continue
		var tangent := flat / length
		var count := maxi(1, roundi(length / spacing))
		for index in range(count + 1):
			if index == count and segment < normals.size() - 1:
				continue
			var at := Vector3(a.x, 0.0, a.z) + tangent * (length * float(index) / float(count)) - normal * inset
			at.y = (base + top) * 0.5
			for target: Dictionary in [trim, collision]:
				_append_box(target, at, tangent, normal, post, top - base, post)


## Copy of a chain path `distance` behind the exact walls along the mitred
## normals, with the same segment normals.
static func _offset_path(path: Dictionary, distance: float) -> Dictionary:
	var source := path.points as Array
	var normals := path.normals as Array
	var points: Array = []
	for index in source.size():
		points.append((source[index] as Vector3) - _miter_offset(normals, index) * distance)
	return {"points": points, "normals": normals.duplicate()}


## Setback upper storey on a chain: walls on the offset path from low_y to
## high_y, end caps closing the notch, and optionally the terrace floor
## between the exact walls and the setback at low_y. Visual and collision.
## `both_sides` also faces the wall inward, for a setback whose back is seen
## from a lower roof behind it (the south wing's slot behind the SE tier).
static func _append_setback_storey(wall_visual: Dictionary, floor_visual: Dictionary, collision: Dictionary, outer: Dictionary, inner: Dictionary, low_y: float, high_y: float, with_floor: bool, both_sides: bool = false) -> void:
	var outer_points := outer.points as Array
	var inner_points := inner.points as Array
	var normals := outer.normals as Array
	for segment in normals.size():
		var a := inner_points[segment] as Vector3
		var b := inner_points[segment + 1] as Vector3
		var normal := normals[segment] as Vector3
		for target: Dictionary in [wall_visual, collision]:
			_append_vertical_face(target, a, b, low_y, high_y, normal)
			if both_sides:
				_append_vertical_face(target, b - normal * SETBACK_INWARD_FACE_INSET_M, a - normal * SETBACK_INWARD_FACE_INSET_M, low_y, high_y, -normal)
		if with_floor:
			var oa := _lifted(outer_points[segment] as Vector3, low_y)
			var ob := _lifted(outer_points[segment + 1] as Vector3, low_y)
			for target: Dictionary in [floor_visual, collision]:
				_append_quad(target, oa, ob, _lifted(b, low_y), _lifted(a, low_y), Vector3.UP)
	var last := outer_points.size() - 1
	var first_direction := _flat_direction(outer_points[0] as Vector3, outer_points[1] as Vector3)
	var last_direction := _flat_direction(outer_points[last - 1] as Vector3, outer_points[last] as Vector3)
	# The end walls close the notch against the full-height mass beyond each
	# end, so they face back along the chain into the terrace.
	for target: Dictionary in [wall_visual, collision]:
		_append_vertical_face(target, outer_points[0] as Vector3, inner_points[0] as Vector3, low_y, high_y, first_direction)
		_append_vertical_face(target, inner_points[last] as Vector3, outer_points[last] as Vector3, low_y, high_y, -last_direction)


## North lower ring over the released north runs (Sep 2025 frontal north view):
## a semi-basement row and grouped main-floor windows in bays between flat piers
## below a band course; on the setback chains a railed terrace and an upper
## floor set back behind it, with stepped-hood windows, a frieze and a thin
## cornice; and the taller junction pylon at node 0 with its windows.
static func _append_north_ring(buckets: Dictionary, original: Dictionary, collision: Dictionary, record: Dictionary, ring: Dictionary, pylon: Dictionary, edge: Dictionary, style: Dictionary, roof_y: float) -> void:
	var all_runs := _int_array(ring.all_runs as Array)
	var length := _chain_length(record, all_runs)
	var bays := maxi(1, roundi(length / float(ring.bay_pitch)))
	var bay := length / float(bays)
	var centers: Array[float] = []
	for index in bays:
		centers.append(bay * (float(index) + 0.5))
	var heavy := style.duplicate()
	heavy["bar"] = 0.11
	heavy["edge_bar"] = 0.13
	var main := ring.main_window as Dictionary
	var pier := float(ring.pier_width)
	_append_window_grid(buckets, record, all_runs, centers, bay - pier - 0.5, [{"bottom": float(main.bottom), "top": float(main.top), "rows": int(main.rows)}], heavy, int(main.columns))
	var semi := ring.semi_window as Dictionary
	_append_window_grid(buckets, record, all_runs, centers, float(semi.width), [{"bottom": float(semi.bottom), "top": float(semi.top), "rows": int(semi.rows)}], heavy, int(semi.columns))
	var band := ring.band as Array
	for index in range(bays + 1):
		var at := clampf(bay * float(index), pier * 0.5, length - pier * 0.5)
		var frame := _span_frame(record, all_runs, at - pier * 0.5 - 0.1, at + pier * 0.5 + 0.1)
		var center := at - float(frame.mid_m)
		var ground := minf(float(frame.base_a), float(frame.base_b)) - 0.05
		_append_frame_box(buckets.trim, frame, center - pier * 0.5, center + pier * 0.5, ground, float(band[0]), float(frame.lo) - 0.03, float(frame.hi) + float(ring.pier_front))
	_append_path_band(buckets.trim, _chain_points(record, all_runs, 0.0, length), float(band[0]), float(band[1]), float(band[2]), -0.03)
	var terrace := float(ring.terrace_y)
	var setback := float(ring.setback)
	var terrace_edge := edge.duplicate()
	terrace_edge["coping"] = ring.terrace_coping
	var upper := ring.upper_window as Dictionary
	var upper_style := heavy.duplicate()
	upper_style["setback_m"] = setback
	upper_style["stepped_hood"] = true
	for chain_value in ring.chains as Array:
		var chain := _int_array(chain_value as Array)
		var chain_length := _chain_length(record, chain)
		var outer := _chain_points(record, chain, 0.0, chain_length)
		var inner := _offset_path(outer, setback)
		_append_setback_storey(original, original, collision, outer, inner, terrace, roof_y, true)
		_append_podium_edge(buckets.trim, collision, outer, terrace_edge, terrace, true)
		var count := maxi(1, roundi(chain_length * float(upper.count_per_m)))
		var upper_centers := _evenly_spaced(chain_length, count, minf(1.6, chain_length * 0.5))
		_append_window_grid(buckets, record, chain, upper_centers, float(upper.width), [{"bottom": float(upper.bottom), "top": float(upper.top), "rows": int(upper.rows)}], upper_style, int(upper.columns))
		for profile: Array in [ring.frieze as Array, ring.cornice as Array]:
			_append_path_band(buckets.trim, inner, float(profile[0]), float(profile[1]), float(profile[2]), -0.03)
		var top_coping := ring.top_coping as Array
		for target: Dictionary in [buckets.trim, collision]:
			_append_path_band(target, inner, float(top_coping[0]), float(top_coping[1]), float(top_coping[2]), -0.35, false, false, true)
	# Junction pylon over node 0: solid, rising one storey above the ring.
	var pylon_runs := _int_array(pylon.runs as Array)
	var pylon_length := _chain_length(record, pylon_runs)
	var pylon_frame := _span_frame(record, pylon_runs, 0.0, pylon_length)
	var wall := float(pylon_frame.hi)
	var half := pylon_length * 0.5
	var depth := float(pylon.depth)
	var top := float(pylon.top_y)
	for target: Dictionary in [original, collision]:
		_append_frame_box(target, pylon_frame, -half, half, roof_y - 0.05, top, wall - depth, wall)
	var pylon_coping := pylon.coping as Array
	for target: Dictionary in [buckets.trim, collision]:
		_append_frame_box(target, pylon_frame, -half - 0.12, half + 0.12, float(pylon_coping[0]), float(pylon_coping[1]), wall - depth - 0.12, wall + float(pylon_coping[2]))
	var tall := pylon.tall_window as Dictionary
	var pylon_style := heavy.duplicate()
	pylon_style["stepped_hood"] = true
	_append_window_module(buckets, pylon_frame, 0.0, float(tall.width), float(tall.bottom), float(tall.top), int(tall.columns), int(tall.rows), pylon_style)
	var small := pylon.small_window as Dictionary
	for side in [-1.0, 1.0]:
		_append_window_module(buckets, pylon_frame, float(side) * half * 0.45, float(small.width), float(small.bottom), float(small.top), int(small.columns), int(small.rows), pylon_style)


## Flat-roofed shoulder stepping forward and down from the drum's south end
## over the SE runs (Nov 2025 SE view, 2023 rear view): a solid block below the
## drum crown carrying the observed small high window and tall stepped-head
## window, and a lower parapet step back onto the SE upper tier.
static func _append_se_shoulder(buckets: Dictionary, collision: Dictionary, record: Dictionary, shoulder: Dictionary, openings: Dictionary, style: Dictionary, setback: float, low_y: float, tier_top_y: float) -> void:
	var runs := _int_array(shoulder.runs as Array)
	var length := _chain_length(record, runs)
	var frame := _span_frame(record, runs, 0.0, length)
	var wall := float(frame.hi)
	var half := length * 0.5
	var depth := float(shoulder.depth)
	var top := float(shoulder.top_y)
	# The block starts on the podium roof: its face lies in the exact wall plane,
	# so a seat below the roof would overlap the protected run-70 wall.
	for target: Dictionary in [buckets.wall, collision]:
		_append_frame_box(target, frame, -half, half, low_y, top, wall - depth, wall)
	var coping := shoulder.coping as Array
	for target: Dictionary in [buckets.trim, collision]:
		_append_frame_box(target, frame, -half - 0.1, half + 0.1, float(coping[0]), float(coping[1]), wall - depth - 0.1, wall + float(coping[2]))
	var hooded := style.duplicate()
	hooded["stepped_hood"] = true
	for key: String in ["tall", "small"]:
		var opening := openings[key] as Dictionary
		var y_range := opening.y as Array
		_append_window_module(buckets, frame, 0.0, float(opening.glass_width), float(y_range[0]), float(y_range[1]), int(opening.columns), int(opening.rows), hooded if key == "tall" else style)
	# Intermediate parapet step on the setback line just before the shoulder.
	var step := shoulder.step as Dictionary
	var step_runs: Array[int] = [runs[0] - 1]
	var step_length := _chain_length(record, step_runs)
	var step_frame := _span_frame(record, step_runs, step_length - float(step.from_end_m), step_length)
	step_frame["anchor"] = (step_frame.anchor as Vector3) - (step_frame.normal as Vector3) * setback
	var step_half := float(step.from_end_m) * 0.5
	var step_wall := float(step_frame.hi)
	for target: Dictionary in [buckets.wall, collision]:
		_append_frame_box(target, step_frame, -step_half, step_half + 0.3, tier_top_y - 0.05, float(step.top_y), step_wall - float(step.depth), step_wall)


## The base storey's configured placement must still hold the cab: the cab's
## plan centroid lies inside it, and all four corners (parapet included) lie on
## r16681702's frozen roof. Fails closed when that roof cannot be read.
static func _tower_base_block_fits(block: Dictionary, cab_center: Vector3) -> bool:
	var roof := _record_from_chunk(MAIN_CHUNK_PATH, BUILDING_ROOF_KEY)
	if roof.is_empty():
		return false
	var values := roof.vertices as Array
	var indices := roof.indices as Array
	var triangles: Array[PackedVector2Array] = []
	for offset in range(0, indices.size(), 3):
		var triangle := PackedVector2Array()
		for index_offset in 3:
			var vertex := int(indices[offset + index_offset]) * 3
			triangle.append(Vector2(float(values[vertex]), float(values[vertex + 2])))
		triangles.append(triangle)
	var center_xz := block.center_xz as Array
	var tangent_xz := block.tangent_xz as Array
	var center := Vector2(float(center_xz[0]), float(center_xz[1]))
	var tangent := Vector2(float(tangent_xz[0]), float(tangent_xz[1])).normalized()
	var normal := Vector2(tangent.y, -tangent.x)
	var half_length := float(block.length) * 0.5 + float(block.parapet_thickness) * 0.5
	var half_depth := float(block.depth) * 0.5 + float(block.parapet_thickness) * 0.5
	var cab := Vector2(cab_center.x, cab_center.z) - center
	if absf(cab.dot(tangent)) > float(block.length) * 0.5 or absf(cab.dot(normal)) > float(block.depth) * 0.5:
		return false
	for corner in [tangent * half_length + normal * half_depth, tangent * half_length - normal * half_depth, -tangent * half_length + normal * half_depth, -tangent * half_length - normal * half_depth]:
		var point: Vector2 = center + corner
		var inside := false
		for triangle in triangles:
			if Geometry2D.point_is_inside_triangle(point, triangle[0], triangle[1], triangle[2]):
				inside = true
				break
		if not inside:
			return false
	return true


## Rectangular base storey under the observation cab, emitted by the tower
## record on r16681702's central roof (ROOT 2026-10-22): about twice the cab's width along the drum's
## tangent, kept inside the drum's rear face; a ribbon of dark windows between
## pale piers, a solid parapet and a solid railed roof terrace.
static func _append_tower_base_block(buckets: Dictionary, collision: Dictionary, block: Dictionary, roof_y: float, top_y: float) -> void:
	var center_xz := block.center_xz as Array
	var tangent_xz := block.tangent_xz as Array
	var tangent := Vector3(float(tangent_xz[0]), 0.0, float(tangent_xz[1])).normalized()
	var normal := Vector3(tangent.z, 0.0, -tangent.x)
	var length := float(block.length)
	var depth := float(block.depth)
	var center := Vector3(float(center_xz[0]), (roof_y - 0.05 + top_y) * 0.5, float(center_xz[1]))
	_append_box(buckets.wall, center, tangent, normal, length, top_y - roof_y + 0.05, depth)
	# Collision starts exactly on the parent roof, where the shared fit harness
	# expects the tower's architecture base; the visual seats 0.05 m into it.
	_append_box(collision, Vector3(center.x, (roof_y + top_y) * 0.5, center.z), tangent, normal, length, top_y - roof_y, depth)
	var window_bottom := roof_y + float(block.window_bottom_above_roof)
	var window_top := top_y - float(block.window_top_below_roof)
	var parapet := float(block.parapet_thickness)
	var parapet_height := float(block.parapet_height)
	var faces := [[normal, tangent, length, depth], [-normal, tangent, length, depth], [tangent, normal, depth, length], [-tangent, normal, depth, length]]
	for face: Array in faces:
		var face_normal := face[0] as Vector3
		var along := face[1] as Vector3
		var face_length := float(face[2])
		var face_middle := Vector3(center.x, 0.0, center.z) + face_normal * float(face[3]) * 0.5
		var usable := face_length * 0.84
		var count := maxi(1, roundi(usable / (float(block.window_target_width) + float(block.window_gap))))
		var pitch := usable / float(count)
		for window in count:
			var window_center := face_middle + along * (-usable * 0.5 + pitch * (float(window) + 0.5))
			window_center.y = (window_bottom + window_top) * 0.5
			_append_box(buckets.glass, window_center, along, face_normal, pitch - float(block.window_gap), window_top - window_bottom, float(block.window_front) * 2.0)
		var parapet_center := face_middle - face_normal * (parapet * 0.5 - 0.02)
		parapet_center.y = top_y + parapet_height * 0.5
		for target: Dictionary in [buckets.trim, collision]:
			_append_box(target, parapet_center, along, face_normal, face_length + parapet, parapet_height, parapet)
		var rail_center := face_middle - face_normal * 0.3
		rail_center.y = top_y + float(block.rail_height)
		var posts := maxi(1, roundi(face_length / 2.4))
		for target: Dictionary in [buckets.trim, collision]:
			_append_box(target, rail_center, along, face_normal, face_length - 0.6, 0.07, 0.07)
			_append_box(target, Vector3(rail_center.x, top_y + float(block.rail_height) * 0.58, rail_center.z), along, face_normal, face_length - 0.6, 0.07, 0.07)
			for index in range(posts + 1):
				var post := rail_center + along * (-(face_length - 0.6) * 0.5 + (face_length - 0.6) * float(index) / float(posts))
				post.y = top_y + (parapet_height + float(block.rail_height)) * 0.5
				_append_box(target, post, along, face_normal, 0.07, float(block.rail_height) - parapet_height, 0.07)


## Rear drum banding along the central tier's exposed rear outline (dated
## 2023 rear view): the boundary of the tier's exact roof pieces between its
## two end caps. Short junction runs whose 25 m inward offsets fall inside the
## drum (39, 40, 42) contribute no band, so nothing crosses the roof. Bands sit
## `back` into the face so no seam opens at a join; the coping, which stands
## above the roof, also closes its inner face. Visual relief only.
static func _append_drum_banding(trim: Dictionary, record: Dictionary, runs: Array[int], depth: float, banding: Dictionary) -> bool:
	var path := _strip_rear_outline(record, runs, depth)
	if path.is_empty():
		return false
	var back := float(banding.back)
	var coping := banding.coping as Array
	_append_path_band(trim, path, float(coping[0]), float(coping[1]), float(coping[2]), back, false, false, true)
	for line_value in banding.speed_lines as Array:
		var line := line_value as Array
		_append_path_band(trim, path, float(line[0]), float(line[1]), float(banding.speed_line_front), back)
	return true


## Horizontal XZ pieces of a stepped tier strip exactly as _append_strip_roof
## emits them (before clipping): one quad per run and the join triangles.
static func _strip_pieces(record: Dictionary, runs: Array[int], depth: float) -> Array[PackedVector2Array]:
	var pieces: Array[PackedVector2Array] = []
	var previous := {}
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var normal := frame.normal as Vector3
		var start := frame.start as Vector3
		var end := frame.end as Vector3
		var inner_start := start - normal * depth
		var inner_end := end - normal * depth
		pieces.append(PackedVector2Array([Vector2(start.x, start.z), Vector2(end.x, end.z), Vector2(inner_end.x, inner_end.z), Vector2(inner_start.x, inner_start.z)]))
		if not previous.is_empty():
			var join := previous.end as Vector3
			var previous_inner := join - (previous.normal as Vector3) * depth
			var current_inner := join - normal * depth
			var triangle := PackedVector2Array([Vector2(join.x, join.z), Vector2(previous_inner.x, previous_inner.z), Vector2(current_inner.x, current_inner.z)])
			if absf(_ring_area(triangle)) > 0.0001:
				pieces.append(triangle)
		previous = frame
	return pieces


## Outer boundaries of the union of polygons, merging pieces that overlap or
## share an edge (holes are dropped). Each result is counterclockwise in
## Geometry2D's sense (not is_polygon_clockwise).
static func _union_outers(polygons: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	for polygon in polygons:
		if absf(_ring_area(polygon)) < 0.0001:
			continue
		var current := polygon.duplicate()
		if Geometry2D.is_polygon_clockwise(current):
			current.reverse()
		var merged := true
		while merged:
			merged = false
			for index in result.size():
				var outer := _single_outer(Geometry2D.merge_polygons(current, result[index]))
				if outer.is_empty():
					continue
				current = outer
				result.remove_at(index)
				merged = true
				break
		result.append(current)
	return result


## The one outer boundary of a merge result, or empty when the inputs stayed
## separate (two or more outers). Holes have the opposite orientation.
static func _single_outer(pieces: Array[PackedVector2Array]) -> PackedVector2Array:
	var largest := -1
	for index in pieces.size():
		if largest < 0 or absf(_ring_area(pieces[index])) > absf(_ring_area(pieces[largest])):
			largest = index
	if largest < 0:
		return PackedVector2Array()
	var orientation := Geometry2D.is_polygon_clockwise(pieces[largest])
	for index in pieces.size():
		if index != largest and Geometry2D.is_polygon_clockwise(pieces[index]) == orientation:
			return PackedVector2Array()
	var outer := pieces[largest].duplicate()
	if orientation:
		outer.reverse()
	return outer


## The tier strip's exposed rear outline as a band path: the union boundary of
## its pieces from the first run's inner start to the last run's inner end,
## the way that does not pass the exact front, with outward normals. Empty
## when the union is not one polygon or the corners are not on it.
static func _strip_rear_outline(record: Dictionary, runs: Array[int], depth: float) -> Dictionary:
	var origin_point := _run_frame(record, runs[0]).start as Vector3
	var origin := Vector2(origin_point.x, origin_point.z)
	var local: Array[PackedVector2Array] = []
	for piece in _strip_pieces(record, runs, depth):
		var shifted := PackedVector2Array()
		for point in piece:
			shifted.append(point - origin)
		if Geometry2D.is_polygon_clockwise(shifted):
			shifted.reverse()
		local.append(shifted)
	var outers := _union_outers(local)
	if outers.size() != 1:
		return {}
	var outline := _simplified_ring(outers[0])
	var first := _run_frame(record, runs[0])
	var last := _run_frame(record, runs[runs.size() - 1])
	var corner_a3 := (first.start as Vector3) - (first.normal as Vector3) * depth
	var corner_b3 := (last.end as Vector3) - (last.normal as Vector3) * depth
	var corner_a := Vector2(corner_a3.x, corner_a3.z) - origin
	var corner_b := Vector2(corner_b3.x, corner_b3.z) - origin
	var last_end := last.end as Vector3
	var fronts: Array[Vector2] = [Vector2.ZERO, Vector2(last_end.x, last_end.z) - origin]
	var ia := -1
	var ib := -1
	for index in outline.size():
		if outline[index].distance_to(corner_a) < 0.02:
			ia = index
		if outline[index].distance_to(corner_b) < 0.02:
			ib = index
	if ia < 0 or ib < 0 or ia == ib:
		return {}
	var count := outline.size()
	var arcs: Array = []
	for step in [1, count - 1]:
		var arc: Array[Vector2] = []
		var index := ia
		var touches_front := false
		while true:
			arc.append(outline[index])
			for front in fronts:
				if outline[index].distance_to(front) < 0.05:
					touches_front = true
			if index == ib:
				break
			index = (index + step) % count
		arcs.append([arc, touches_front])
	var chosen: Array[Vector2] = []
	for entry: Array in arcs:
		if not bool(entry[1]):
			chosen = entry[0]
	if chosen.size() < 2:
		return {}
	var points: Array = []
	var normals: Array = []
	for index in chosen.size():
		var point := chosen[index] + origin
		points.append(Vector3(point.x, 0.0, point.y))
		if index == 0:
			continue
		var a := chosen[index - 1]
		var b := chosen[index]
		var normal := Vector2(b.y - a.y, a.x - b.x).normalized()
		if Geometry2D.is_point_in_polygon((a + b) * 0.5 + normal * 0.05, outline):
			normal = -normal
		normals.append(Vector3(normal.x, 0.0, normal.y))
	return {"points": points, "normals": normals}


## A pier with its reeds in the round (the owner's 2026-11-20 photos): each reed
## rounded across and at both ends, their tops stepping down from the middle reed.
static func _append_fluted_pier(trim: Dictionary, frame: Dictionary, center: float, width: float, bottom: float, top: float, depth: float, reeds: int, reed_width: float, reed_gap: float, reed_front: float, groove: Dictionary = {}) -> void:
	var back := float(frame.lo) - 0.03
	var wall := float(frame.hi)
	_append_frame_box(trim, frame, center - width * 0.5, center + width * 0.5, bottom, top, back, wall + depth)
	var total := float(reeds) * reed_width + float(maxi(reeds - 1, 0)) * reed_gap
	var middle := float(reeds - 1) * 0.5
	var end := minf(reed_width, 0.12)
	for reed in reeds:
		var x := center - total * 0.5 + reed_width * 0.5 + float(reed) * (reed_width + reed_gap)
		var step := absf(float(reed) - middle) * PIER_REED_TOP_STEP_M
		_append_reed(trim, frame, x, reed_width * 0.5, reed_front - depth, wall + depth - 0.005, bottom + 0.06, top - 0.04 - step, end)
		# The groove's floor beside each reed, dark where the sky barely reaches.
		if not groove.is_empty() and reed < reeds - 1:
			var gap_x := x + (reed_width + reed_gap) * 0.5
			var gap_top := top - 0.04 - maxf(step, absf(float(reed + 1) - middle) * PIER_REED_TOP_STEP_M) - end
			_append_frame_box(groove, frame, gap_x - reed_gap * 0.5 - reed_width * 0.2, gap_x + reed_gap * 0.5 + reed_width * 0.2, bottom + 0.06 + end, gap_top, wall + depth - 0.01, wall + depth + 0.004)


## The crescent windows' bronze grille (the owner's 2026-11-20 frontal and close
## views): pairs of vertical bars across the window with short rungs between each
## pair, standing in front of the steel window. Visual only.
static func _append_bronze_grille(bucket: Dictionary, frame: Dictionary, center: float, glass: float, bottom: float, top: float, wall: float, grille: Dictionary) -> void:
	var pairs := int(grille.pairs)
	var bar := float(grille.bar)
	var gap := float(grille.gap)
	var back := wall + float(grille.back)
	var front := wall + float(grille.front)
	var rung := float(grille.rung)
	var rung_pitch := float(grille.rung_pitch)
	var rungs := maxi(1, floori((top - bottom) / rung_pitch))
	for pair in pairs:
		var x := center - glass * 0.5 + glass * (float(pair) + 0.5) / float(pairs)
		for side in [-1.0, 1.0]:
			var bar_x := x + float(side) * (gap + bar) * 0.5
			_append_frame_box(bucket, frame, bar_x - bar * 0.5, bar_x + bar * 0.5, bottom, top, back, front)
		for index in range(1, rungs):
			var y := bottom + (top - bottom) * float(index) / float(rungs)
			_append_frame_box(bucket, frame, x - gap * 0.5, x + gap * 0.5, y - rung * 0.5, y + rung * 0.5, back, front - 0.005)


## Projecting west-end pavilion on its frozen centre face: paired two-story
## twenty-light windows on a fluted mullion pier, plain corner fins, an abstract
## winged relief, a pale-portal entry and a flat-topped crown over the whole face.
## Flanks and the recessed corner bay carry the wing floor schedule.
static func _append_pavilion(buckets: Dictionary, collision: Dictionary, record: Dictionary, spec: Dictionary, floors: Array, front: Dictionary, region: String) -> void:
	var center_runs := _int_array(spec.center_runs)
	var length := _chain_length(record, center_runs)
	var frame := _span_frame(record, center_runs, 0.0, length)
	var wall := float(frame.hi)
	var base_low := minf(float(frame.base_a), float(frame.base_b))
	var tall_y := front.pavilion_tall_window_y as Array
	var tall_bottom := float(tall_y[0])
	var tall_top := float(tall_y[1])
	var offset := float(front.pavilion_tall_window_offset)
	var tall_style := front.pavilion_tall_window_style as Dictionary
	for side in [-1.0, 1.0]:
		var tall_grid := front.pavilion_tall_window_grid as Array
		_append_window_module(buckets, frame, float(side) * offset, float(front.pavilion_tall_window_width), tall_bottom, tall_top, int(tall_grid[0]), int(tall_grid[1]), tall_style)
	_append_fluted_pier(buckets.trim, frame, 0.0, float(front.pavilion_mullion_pier_width), tall_bottom - 0.2, tall_top + 0.3, 0.27, 2, 0.11, 0.1, 0.32)
	_append_pavilion_emblem(buckets, frame, front.pavilion_emblem as Dictionary, region, front.wing_window_style as Dictionary)
	_append_pavilion_garage(buckets, collision, frame, base_low, front)
	# Corner fins (2008 south pavilion view, 2003 Photograph 11; the nomination's
	# "corner pilasters"): plain strips slightly proud of the face, in its stucco,
	# filling it outside the window field, from the plinth to a shoulder just over
	# the flank roofs with three incised lines under it. They reach chest height,
	# so they are solid.
	var crown := front.pavilion_crown as Dictionary
	var half := length * 0.5
	var fin_inner := float(crown.fin_inner_half_width_m)
	var fin_front := wall + float(crown.fin_front_m)
	var fin_top := float(crown.fin_top_y)
	var line_front := float(crown.line_front)
	var fin_lines := crown.fin_lines_y as Array
	var fin_pitch := float(fin_lines[1]) - float(fin_lines[0])
	for side in [-1.0, 1.0]:
		var inner := float(side) * fin_inner
		var outer := float(side) * half
		for target: Dictionary in [buckets.wall, collision]:
			_append_frame_box(target, frame, minf(inner, outer), maxf(inner, outer), base_low - 0.06, fin_top, float(frame.lo) - 0.03, fin_front)
		# The fin's cap (the owner's 2026-11-20 photos of both pavilions): a band proud
		# of its face with three incised lines, the crown standing back above it.
		var fin_cap := crown.fin_cap as Dictionary
		var fin_path := _frame_path(frame, minf(inner, outer) - float(fin_cap.side), maxf(inner, outer) + float(fin_cap.side), fin_front)
		_append_profile_sweep(buckets.wall, fin_path, _coping_profile(fin_top - float(fin_cap.height), fin_top, float(fin_cap.front), -float(crown.fin_front_m) - 0.03, fin_lines.size(), 0.03, fin_pitch, float(fin_cap.cap_height), float(fin_cap.cap_overhang)), true)
	# A dentil course over the tall windows, between the fins (the owner's 2026-11-20
	# photos of both pavilions).
	var dentils := front.pavilion_dentils as Dictionary
	var dentil_y := dentils.above_window_head as Array
	var head := tall_top + float(tall_style.head_height)
	_append_dentil_blocks(buckets.trim, frame, -fin_inner + 0.25, fin_inner - 0.25, head + float(dentil_y[0]), head + float(dentil_y[1]), float(frame.lo) - 0.03, wall + float(dentils.front), float(dentils.width), int(dentils.count))
	# Flat-topped crown (same views; the north pavilion's from its low-resolution
	# 2025 and 2003 views): solid masonry over the whole centre face in the face's
	# stucco, seated into the flank roof, with three incised lines under a thin pale
	# cap. Its sides, top, back and cap are all in the wall body's collision: the
	# roof is reachable.
	var block_half := half - float(crown.side_inset_m)
	var block_front := wall + float(crown.front_m)
	var block_back := wall + float(crown.back_m)
	var cap := crown.cap as Dictionary
	var cap_y := cap.y as Array
	var overhang := float(cap.overhang)
	for target: Dictionary in [buckets.wall, collision]:
		_append_frame_box(target, frame, -block_half, block_half, float(crown.bottom_y), float(cap_y[0]) + 0.02, block_back, block_front)
	for target: Dictionary in [buckets.trim, collision]:
		_append_frame_box(target, frame, -block_half - overhang, block_half + overhang, float(cap_y[0]), float(cap_y[1]), block_back - overhang, block_front + float(cap.front))
	var crown_lines := crown.lines_y as Array
	var crown_pitch := float(crown_lines[1]) - float(crown_lines[0])
	_append_pattern_band(buckets.lines_field, _frame_path(frame, -block_half + 0.02, block_half - 0.02, block_front), float(crown_lines[0]), float(crown_lines[crown_lines.size() - 1]) + crown_pitch, line_front, -0.01, 1.0, float(crown_lines[0]), crown_pitch, Vector2(0.5, 0.6), 0)
	var style := front.wing_window_style as Dictionary
	# One window column per flank block, dentils over each upper window (the owner's
	# 2026-11-20 photos of both pavilions).
	var flank_blocks: Array = (spec.flank_runs as Array).duplicate()
	flank_blocks.append(spec.corner_runs)
	var upper := floors[floors.size() - 1] as Dictionary
	var flank_dentils := front.flank_window_dentils as Dictionary
	for block_value in flank_blocks:
		var block := _int_array(block_value as Array)
		var middle_m := _chain_length(record, block) * 0.5
		_append_window_grid(buckets, record, block, [middle_m], float(front.flank_window_width), floors, style)
		var flank_half := float(front.flank_window_width) * 0.5 + float(style.surround)
		var block_frame := _span_frame(record, block, middle_m - flank_half - 0.1, middle_m + flank_half + 0.1)
		var block_center := middle_m - float(block_frame.mid_m)
		var flank_head := float(upper.top) + float(style.head_height)
		_append_dentil_blocks(buckets.trim, block_frame, block_center - flank_half, block_center + flank_half, flank_head + 0.04, flank_head + 0.04 + float(flank_dentils.height), float(block_frame.lo) - 0.03, float(block_frame.hi) + float(flank_dentils.front), float(flank_dentils.width), int(flank_dentils.count))


## The pavilion's garage entry (the National Register nomination's ramps to the
## basement parking; the owner's 2026-11-20 photos of both pavilions): a wide
## panelled door under a deep lintel, its jambs and lintel built out from the face
## so the door stands back in shadow. Jambs and lintel are solid.
static func _append_pavilion_garage(buckets: Dictionary, collision: Dictionary, frame: Dictionary, ground_y: float, front: Dictionary) -> void:
	var garage := front.pavilion_garage as Dictionary
	var half := _pavilion_garage_half(front)
	var wall := float(frame.hi)
	var back := float(frame.lo) - 0.03
	var depth := float(garage.depth)
	var top := ground_y + float(garage.height)
	var jamb := float(garage.jamb)
	var lintel := float(garage.lintel)
	_append_frame_box(buckets.reveal, frame, -half, half, ground_y - 0.1, top, back, wall + 0.02)
	var panels := int(garage.panels)
	for panel in panels:
		var y0 := lerpf(ground_y, top, float(panel) / float(panels)) + 0.02
		var y1 := lerpf(ground_y, top, float(panel + 1) / float(panels)) - 0.02
		_append_frame_box(buckets.emblem, frame, -half + 0.05, half - 0.05, y0, y1, wall + 0.02, wall + 0.06)
	for side in [-1.0, 1.0]:
		var inner := float(side) * half
		var outer := float(side) * (half + jamb)
		for target: Dictionary in [buckets.wall, collision]:
			_append_frame_box(target, frame, minf(inner, outer), maxf(inner, outer), ground_y - 0.08, top + lintel, back, wall + depth)
	for target: Dictionary in [buckets.wall, collision]:
		_append_frame_box(target, frame, -half, half, top, top + lintel, back, wall + depth)


## Half the garage door's width: a share of the tall window pair's width above it.
static func _pavilion_garage_half(front: Dictionary) -> float:
	var pair := float(front.pavilion_tall_window_offset) * 2.0 + float(front.pavilion_tall_window_width)
	return pair * float((front.pavilion_garage as Dictionary).width_of_window_pair) * 0.5


## The pavilion's emblem (the owner's 2026-11-20 photos of both pavilions and the
## emblem close-up; 2003 Photograph 11): an elongated blue octagon carrying a white
## relief of a kneeling figure holding an airplane up, three blue bars either side,
## centred about level with the fin caps. The relief is modelled only as far as the
## photos resolve it: two flat raised outlines (the figure, and its raised arm with
## the airplane), nothing inside them. On the south pavilion two small windows flank
## the bars; the north pavilion's wall there is plain. Visual only, above the fins'
## chest-height collision.
static func _append_pavilion_emblem(buckets: Dictionary, frame: Dictionary, emblem: Dictionary, region: String, style: Dictionary) -> void:
	var wall := float(frame.hi)
	var back := float(frame.lo) - 0.03
	var center_y := float(emblem.center_y)
	var half_w := float(emblem.octagon_width) * 0.5
	var half_h := float(emblem.octagon_height) * 0.5
	var corner := minf(half_w, half_h) * 0.42
	var octagon: Array = [[-half_w + corner, -half_h], [half_w - corner, -half_h], [half_w, -half_h + corner], [half_w, half_h - corner], [half_w - corner, half_h], [-half_w + corner, half_h], [-half_w, half_h - corner], [-half_w, -half_h + corner]]
	var field_front := wall + float(emblem.field_front)
	_append_frame_outline(buckets.emblem, frame, center_y, octagon, back, field_front)
	for part_value in emblem.relief as Array:
		var part := part_value as Dictionary
		_append_frame_outline(buckets.relief, frame, center_y, part.points as Array, field_front - 0.02, wall + float(emblem.relief_front))
	var bars := emblem.bars as Dictionary
	var bar_height := float(bars.bar_height)
	var gap := float(bars.gap)
	var reach := float(bars.reach)
	for row in 3:
		var y := center_y + (float(row) - 1.0) * (bar_height + gap)
		for side in [-1.0, 1.0]:
			var inner := float(side) * (half_w - 0.05)
			var outer := float(side) * reach
			_append_frame_box(buckets.emblem, frame, minf(inner, outer), maxf(inner, outer), y - bar_height * 0.5, y + bar_height * 0.5, back, wall + float(bars.front))
	var small := emblem.small_windows as Dictionary
	if region in (small.pavilions as Array):
		var small_y := small.y as Array
		for side in [-1.0, 1.0]:
			_append_window_module(buckets, frame, float(side) * float(small.offset), float(small.width), float(small_y[0]), float(small_y[1]), int(small.columns), int(small.rows), style)


static func _crown_rise(front: Dictionary, roof_y: float) -> float:
	return float((front.pavilion_crown as Dictionary).top_y) - roof_y


## Chain metres (Vector2(from, to)) of a pavilion's centre face on a wing chain: the
## span its crown covers, where the wing cornice stops.
static func _pavilion_face_span(record: Dictionary, chain: Array[int], spec: Dictionary) -> Vector2:
	var center_runs := _int_array(spec.center_runs)
	var from_m := _chain_start_of(record, chain, center_runs[0])
	return Vector2(from_m, from_m + _chain_length(record, center_runs))


## Pier at a protected-run seam: it stops at the exact junction without touching
## the protected wall, so the public coating ends at an inner corner.
static func _append_seam_pier(trim: Dictionary, collision: Dictionary, record: Dictionary, run_index: int, at_start: bool, front: Dictionary) -> void:
	var runs: Array[int] = [run_index]
	var width := float(front.junction_pier_width)
	var length := float(_run_frame(record, run_index).length_m)
	var from_m := 0.0 if at_start else length - width
	var frame := _span_frame(record, runs, from_m, from_m + width)
	var base := minf(float(frame.base_a), float(frame.base_b))
	var wall := float(frame.hi)
	for target: Dictionary in [trim, collision]:
		_append_frame_box(target, frame, -width * 0.5, width * 0.5, base - 0.06, float(front.junction_pier_top_y), wall + 0.005, wall + float(front.junction_pier_front))


## Plinth gap at a pavilion's garage, ending inside its solid jambs.
static func _pavilion_door_gap(record: Dictionary, chain: Array[int], spec: Dictionary, front: Dictionary) -> Vector2:
	var center_runs := _int_array(spec.center_runs)
	var center := _chain_start_of(record, chain, center_runs[0]) + _chain_length(record, center_runs) * 0.5
	var half := _pavilion_garage_half(front) + float((front.pavilion_garage as Dictionary).jamb) * 0.5
	return Vector2(center - half, center + half)


## Low water-table plinth following the exact source wall bottoms, interrupted
## at pavilion doors and stopping inside the seam piers.
static func _append_plinth(base: Dictionary, record: Dictionary, runs: Array[int], start_trim: float, end_trim: float, gaps: Array, front: Dictionary) -> void:
	var cuts: Array[float] = [start_trim]
	for gap_value in gaps:
		var gap := gap_value as Vector2
		cuts.append(gap.x)
		cuts.append(gap.y)
	cuts.append(_chain_length(record, runs) - end_trim)
	var height := float(front.plinth_height_above_base)
	for index in range(0, cuts.size(), 2):
		var path := _chain_points(record, runs, cuts[index], cuts[index + 1])
		_append_path_band(base, path, -0.06, height, float(front.plinth_front), -0.04, true, true)


## End point of a stepped tier's end cap `depth` inward from the exact outer
## corner, with the cap's outward normal.
static func _strip_cap(record: Dictionary, run_index: int, at_start: bool, depth: float) -> Dictionary:
	var frame := _run_frame(record, run_index)
	var corner := (frame.start if at_start else frame.end) as Vector3
	var tangent := frame.tangent as Vector3
	return {"point": corner - (frame.normal as Vector3) * depth, "normal": -tangent if at_start else tangent}


static func _prepend_point(path: Dictionary, point: Vector3, normal: Vector3) -> void:
	(path.points as Array).push_front(point)
	(path.normals as Array).push_front(normal)


static func _append_point(path: Dictionary, point: Vector3, normal: Vector3) -> void:
	(path.points as Array).append(point)
	(path.normals as Array).append(normal)


## The crescent's cantilevered canopy (the owner's 2026-11-20 photos; dated 2008
## photographs of both canopy ends; the 2003 nomination's "full cantilevered stucco
## canopy decorated with scallop and beaded details"): a slab of constant depth in
## front of the crescent's face whose ends sweep round in a quarter circle back to the
## wall at the face's end corners (_canopy_plan), its soffit 3.6 m over the door sills.
## Its fascia is a stack of thin rolls (the stucco's fascia pattern, smooth-shaded
## round the curve); floodlight boxes stand on its top at the piers. The soffit carries
## three reed lines along each edge, three rows of panels and one row of two-slot
## vents. The slab's top, soffit, fascia and lamp boxes are solid; the soffit's relief
## is visual, under 5 cm deep. Returns an empty string, or why the canopy could not be
## laid out.
static func _append_crescent_canopy(buckets: Dictionary, collision: Dictionary, record: Dictionary, layout: Dictionary, front: Dictionary) -> String:
	var canopy := front.canopy as Dictionary
	var plan := _canopy_plan(record, canopy)
	if plan.is_empty():
		return "Building 1's canopy runs no longer form one face long enough for its two rounded ends."
	var polygon := plan.polygon as PackedVector2Array
	var indices := Geometry2D.triangulate_polygon(polygon)
	if indices.is_empty():
		return "Building 1's canopy plan could not be triangulated."
	var origin := plan.origin as Vector2
	var top_y := float(canopy.top_y)
	var soffit_y := float(canopy.soffit_y)
	for offset in range(0, indices.size(), 3):
		var corners: Array[Vector3] = []
		for corner in 3:
			var point := polygon[indices[offset + corner]] + origin
			corners.append(Vector3(point.x, 0.0, point.y))
		for target: Dictionary in [buckets.canopy, collision]:
			_append_triangle(target, _lifted(corners[0], top_y), _lifted(corners[1], top_y), _lifted(corners[2], top_y), Vector3.UP)
		for target: Dictionary in [buckets.soffit, collision]:
			_append_triangle(target, _lifted(corners[0], soffit_y), _lifted(corners[1], soffit_y), _lifted(corners[2], soffit_y), Vector3.DOWN)
	var edge := plan.edge as Dictionary
	var edge_points := edge.points as Array
	var edge_normals := edge.normals as Array
	for segment in edge_normals.size():
		var a := edge_points[segment] as Vector3
		var b := edge_points[segment + 1] as Vector3
		_append_quad(collision, _lifted(a, soffit_y), _lifted(b, soffit_y), _lifted(b, top_y), _lifted(a, top_y), edge_normals[segment] as Vector3)
	# The fascia: a stack of rolls in the round on the edge (the owner's photos).
	var fascia := canopy.fascia_rolls as Dictionary
	_append_profile_sweep(buckets.fascia, edge, _rolls_profile(soffit_y, top_y, 0.0, 0.0, int(fascia.count), float(fascia.radius), float(fascia.pitch), 4, false), true)
	var close_trim := buckets.trim as Dictionary
	# Soffit: reed lines along the front edge and the wall, panel joints, vents.
	var runs := plan.runs as Array[int]
	var length := float(plan.length)
	var depth := float(canopy.depth_m)
	var smoothing := float(canopy.normal_smoothing_m)
	var segments := int(canopy.end_segments)
	var step := float(canopy.edge_step_m)
	var reed := canopy.soffit_reed as Dictionary
	var reed_half := float(reed.width) * 0.5
	for inset_value in canopy.soffit_reeds_from_edge_m as Array:
		var path := _canopy_path(record, runs, _canopy_arc_samples(length, depth, depth - float(inset_value), segments, step), smoothing, length, depth)
		_append_path_band(close_trim, path, soffit_y - float(reed.drop), soffit_y + 0.004, reed_half, -reed_half, false, false, true)
	for from_wall_value in canopy.soffit_reeds_from_wall_m as Array:
		var path := _canopy_path(record, runs, _canopy_line_samples(length, depth, float(from_wall_value), step), smoothing, length, depth)
		_append_path_band(close_trim, path, soffit_y - float(reed.drop), soffit_y + 0.004, reed_half, -reed_half, false, false, true)
	var joint := canopy.soffit_joint as Dictionary
	var joint_half := float(joint.width) * 0.5
	var joint_low := soffit_y - float(joint.drop)
	var close_base := buckets.base as Dictionary
	var joints := canopy.soffit_joints_from_wall_m as Array
	for from_wall_value in joints:
		var path := _canopy_path(record, runs, _canopy_line_samples(length, depth, float(from_wall_value), step), smoothing, length, depth)
		_append_path_band(close_base, path, joint_low, soffit_y + 0.004, joint_half, -joint_half, false, false, true)
	var first := float(joints[0])
	var last := float(joints[joints.size() - 1])
	var piers := layout.piers as Array
	var pitch := float(layout.pitch)
	var bays := range(-1, piers.size())
	for bay in bays:
		for fraction_value in canopy.soffit_joint_bay_fractions as Array:
			var s := float(piers[0]) + pitch * (float(bay) + float(fraction_value))
			var reach := minf(last, _canopy_depth_at(s, length, depth) - 0.35)
			if s <= 0.2 or s >= length - 0.2 or reach - first < 0.3:
				continue
			var a := _canopy_point(record, runs, s, first, smoothing)
			var b := _canopy_point(record, runs, s, reach, smoothing)
			var out := _smoothed_normal(record, runs, s, smoothing)
			var center := (a + b) * 0.5
			center.y = (joint_low + soffit_y + 0.004) * 0.5
			_append_box(close_base, center, out, Vector3(out.z, 0.0, -out.x), a.distance_to(b), soffit_y + 0.004 - joint_low, float(joint.width))
	var vents := canopy.soffit_vents as Dictionary
	var vent_d := float(vents.from_wall_m)
	var vent_size := vents.size_along_across as Array
	for bay in bays:
		for fraction_value in vents.bay_fractions as Array:
			var s := float(piers[0]) + pitch * (float(bay) + float(fraction_value))
			if s <= float(vent_size[0]) or s >= length - float(vent_size[0]) or _canopy_depth_at(s, length, depth) < vent_d + float(vent_size[1]) + 0.3:
				continue
			var out := _smoothed_normal(record, runs, s, smoothing)
			_append_soffit_vent(buckets, _canopy_point(record, runs, s, vent_d, smoothing), Vector3(out.z, 0.0, -out.x), out, soffit_y, vents)
	# Floodlight boxes on the canopy's top at each pier, near its front edge (the
	# owner's 2026-11-20 frontal and south-end views; the 2008 frontal).
	var lamp := canopy.floodlight as Dictionary
	var lamp_size := lamp.size_along_up_across as Array
	for pier_value in piers:
		var s := float(pier_value)
		var out := _smoothed_normal(record, runs, s, smoothing)
		var at := _canopy_point(record, runs, s, _canopy_depth_at(s, length, depth) - float(lamp.from_edge_m), smoothing)
		at.y = top_y + float(lamp_size[1]) * 0.5
		for target: Dictionary in [buckets.bronze, collision]:
			_append_box(target, at, Vector3(out.z, 0.0, -out.x), out, float(lamp_size[0]), float(lamp_size[1]), float(lamp_size[2]))
	return ""


## One two-slot vent on the soffit (2008 canopy-end photographs): a pale frame over a
## dark plate, its two slots side by side along the canopy, split by a bar running
## across it, hanging a few centimetres under the soffit.
static func _append_soffit_vent(buckets: Dictionary, at: Vector3, tangent: Vector3, normal: Vector3, soffit_y: float, vent: Dictionary) -> void:
	var vent_size := vent.size_along_across as Array
	var along := float(vent_size[0])
	var across := float(vent_size[1])
	var frame := float(vent.frame)
	var frame_drop := float(vent.frame_drop)
	var plate_drop := float(vent.plate_drop)
	var trim := buckets.trim as Dictionary
	var plate := at
	plate.y = soffit_y - plate_drop * 0.5 + 0.002
	_append_box(buckets.reveal, plate, tangent, normal, along - frame, plate_drop + 0.004, across - frame)
	var y := soffit_y - frame_drop * 0.5 + 0.002
	for side in [-1.0, 1.0]:
		var long_bar := at + normal * (float(side) * (across - frame) * 0.5)
		long_bar.y = y
		_append_box(trim, long_bar, tangent, normal, along, frame_drop + 0.004, frame)
		var short_bar := at + tangent * (float(side) * (along - frame) * 0.5)
		short_bar.y = y
		_append_box(trim, short_bar, tangent, normal, frame, frame_drop + 0.004, across - frame * 2.0)
	var middle := at
	middle.y = y
	_append_box(trim, middle, tangent, normal, float(vent.bar), frame_drop + 0.004, across - frame * 2.0)


## The canopy's plan in the crescent face's own coordinates, chain metre s along its
## runs and depth d out from the wall, mapped onto the exact wall (_canopy_point).
## The front edge ("edge": world points from the north corner to the south one, with
## each segment's outward normal) rises in a quarter circle from each end corner to
## the full depth and keeps it along the face; the polygon closes it with the wall
## line, embedded behind the exact face along its run miters.
static func _canopy_plan(record: Dictionary, canopy: Dictionary) -> Dictionary:
	var runs := _int_array(canopy.runs as Array)
	var length := _chain_length(record, runs)
	var depth := float(canopy.depth_m)
	if runs.is_empty() or not _chain_contiguous(record, runs) or length < depth * 2.0 + 1.0:
		return {}
	var samples := _canopy_arc_samples(length, depth, depth, int(canopy.end_segments), float(canopy.edge_step_m))
	var edge := _canopy_path(record, runs, samples, float(canopy.normal_smoothing_m), length, depth)
	var first := edge.points[0] as Vector3
	var origin := Vector2(first.x, first.z)
	var polygon := PackedVector2Array()
	for point_value in edge.points as Array:
		var point := point_value as Vector3
		polygon.append(Vector2(point.x, point.z) - origin)
	var wall := _chain_points(record, runs, 0.0, length)
	var wall_points := wall.points as Array
	var wall_normals := wall.normals as Array
	var embed := float(canopy.wall_embed_m)
	for index in range(wall_points.size() - 1, -1, -1):
		var point := (wall_points[index] as Vector3) - _miter_offset(wall_normals, index) * embed
		polygon.append(Vector2(point.x, point.z) - origin)
	return {"edge": edge, "polygon": polygon, "origin": origin, "length": length, "runs": runs}


## (s, d) samples of a curve concentric with the canopy's front edge, `radius` out
## from the wall: a quarter circle about (depth, 0) from the wall up to d = radius,
## that depth along the face, and the mirrored quarter circle at the south end.
static func _canopy_arc_samples(length: float, depth: float, radius: float, segments: int, step: float) -> Array[Vector2]:
	var samples: Array[Vector2] = []
	for index in segments + 1:
		var angle := PI * 0.5 * float(index) / float(segments)
		samples.append(Vector2(depth - radius * cos(angle), radius * sin(angle)))
	var middle := length - depth * 2.0
	var count := maxi(1, ceili(middle / step))
	for index in range(1, count):
		samples.append(Vector2(depth + middle * float(index) / float(count), radius))
	for index in segments + 1:
		var angle := PI * 0.5 * float(index) / float(segments)
		samples.append(Vector2(length - depth + radius * sin(angle), radius * cos(angle)))
	return samples


## (s, d) samples of a line `from_wall` metres out from the wall, between the two
## places the canopy's rounded ends cross it.
static func _canopy_line_samples(length: float, depth: float, from_wall: float, step: float) -> Array[Vector2]:
	var reach := depth - sqrt(maxf(depth * depth - from_wall * from_wall, 0.0))
	var span := length - reach * 2.0
	var count := maxi(1, ceili(span / step))
	var samples: Array[Vector2] = []
	for index in count + 1:
		samples.append(Vector2(reach + span * float(index) / float(count), from_wall))
	return samples


## The canopy's depth at chain metre s: its front edge's d there.
static func _canopy_depth_at(s: float, length: float, depth: float) -> float:
	var from_end := minf(s, length - s)
	if from_end <= 0.0:
		return 0.0
	if from_end >= depth:
		return depth
	return sqrt(maxf(depth * depth - (depth - from_end) * (depth - from_end), 0.0))


## A path (_append_path_band) through (s, d) samples, each segment's normal turned
## away from the wall: out along the face, radially out of the rounded ends.
static func _canopy_path(record: Dictionary, runs: Array[int], samples: Array[Vector2], smoothing: float, length: float, depth: float) -> Dictionary:
	var points: Array = []
	for sample in samples:
		points.append(_canopy_point(record, runs, sample.x, sample.y, smoothing))
	var normals: Array = []
	for index in range(samples.size() - 1):
		var a := points[index] as Vector3
		var b := points[index + 1] as Vector3
		var normal := Vector3(b.z - a.z, 0.0, a.x - b.x).normalized()
		var middle := (samples[index] + samples[index + 1]) * 0.5
		var away := Vector2(0.0, 1.0)
		if middle.x < depth:
			away = Vector2(middle.x - depth, middle.y)
		elif middle.x > length - depth:
			away = Vector2(middle.x - (length - depth), middle.y)
		var out := _canopy_point(record, runs, middle.x + away.normalized().x * 0.1, middle.y + away.normalized().y * 0.1, smoothing) - _canopy_point(record, runs, middle.x, middle.y, smoothing)
		if normal.dot(out) < 0.0:
			normal = -normal
		normals.append(normal)
	return {"points": points, "normals": normals}


## World point (y = 0) at chain metre s and depth d out from the wall: the wall point
## and its outward normal both averaged over `smoothing` metres of the exact runs
## (_smoothed_wall), so curves offset from the kinked source runs stay smooth (under
## 2 degrees of turn per half metre on the crescent, against 11 with exact points).
static func _canopy_point(record: Dictionary, runs: Array[int], s: float, d: float, smoothing: float) -> Vector3:
	var wall := _smoothed_wall(record, runs, s, smoothing)
	return (wall.point as Vector3) + (wall.normal as Vector3) * d


## The chain's wall point and outward normal at chain metre s, each the mean over the
## window `window` metres wide centred on s (point by arc length, normal weighted by
## run length). The window narrows towards the chain's ends so that its ends stay
## the exact corners. A concave chain's mean point lies a few centimetres in front of
## its vertices (under 0.09 m on the crescent at a 4 m window).
static func _smoothed_wall(record: Dictionary, runs: Array[int], s: float, window: float) -> Dictionary:
	var total := _chain_length(record, runs)
	var at := clampf(s, 0.0, total)
	var half := minf(window * 0.5, minf(at, total - at))
	if half < 0.001:
		var exact := _chain_frame(record, runs, at)
		var anchor := exact.wall_anchor as Vector3
		return {"point": Vector3(anchor.x, 0.0, anchor.z), "normal": exact.normal}
	var low := at - half
	var high := at + half
	var point_sum := Vector3.ZERO
	var normal_sum := Vector3.ZERO
	var accumulated := 0.0
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var length := float(frame.length_m)
		var from_m := maxf(low, accumulated) - accumulated
		var to_m := minf(high, accumulated + length) - accumulated
		if to_m > from_m:
			var start := frame.start as Vector3
			var middle := start.lerp(frame.end as Vector3, (from_m + to_m) * 0.5 / length)
			point_sum += Vector3(middle.x, 0.0, middle.z) * (to_m - from_m)
			normal_sum += (frame.normal as Vector3) * (to_m - from_m)
		accumulated += length
	return {"point": point_sum / (high - low), "normal": normal_sum.normalized()}


## The chain's outward normal at chain metre s, averaged as _smoothed_wall does.
static func _smoothed_normal(record: Dictionary, runs: Array[int], s: float, window: float) -> Vector3:
	return _smoothed_wall(record, runs, s, window).normal as Vector3


static func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(b.x - a.x, b.z - a.z).length()


## Drop duplicate and truly collinear vertices (sine below 5e-4), such as a native
## clip leaves along a cut's edge.
static func _simplified_ring(points: PackedVector2Array) -> PackedVector2Array:
	var result := PackedVector2Array()
	var count := points.size()
	for index in count:
		var previous := points[(index + count - 1) % count]
		var current := points[index]
		var next := points[(index + 1) % count]
		var incoming := current - previous
		var outgoing := next - current
		if incoming.length() < 0.0005:
			continue
		if absf(incoming.cross(outgoing)) <= 0.0005 * incoming.length() * outgoing.length() and incoming.dot(outgoing) > 0.0:
			continue
		result.append(current)
	return result


static func _ring_area(points: PackedVector2Array) -> float:
	var area := 0.0
	for index in points.size():
		var a := points[index]
		var b := points[(index + 1) % points.size()]
		area += a.x * b.y - b.x * a.y
	return area * 0.5


## Continuous mitered relief band over an exact wall path. `front`/`back` are
## signed metres from each run's exact plane along its outward normal; interior
## vertices use the miter of adjacent normals, so the band neither overlaps nor
## opens at kinks. Bottom and top may follow the exact source wall bottoms.
## Back faces stay buried behind the wall and are omitted unless requested.
static func _append_path_band(bucket: Dictionary, path: Dictionary, bottom: float, top: float, front: float, back: float, bottom_on_base: bool = false, top_on_base: bool = false, emit_back: bool = false) -> void:
	var points := path.points as Array
	var normals := path.normals as Array
	if points.size() < 2 or normals.size() != points.size() - 1:
		return
	var fronts: Array[Vector3] = []
	var backs: Array[Vector3] = []
	var lows: Array[float] = []
	var highs: Array[float] = []
	for index in points.size():
		var point := points[index] as Vector3
		var miter := _miter_offset(normals, index)
		var flat := Vector3(point.x, 0.0, point.z)
		fronts.append(flat + miter * front)
		backs.append(flat + miter * back)
		lows.append(point.y + bottom if bottom_on_base else bottom)
		highs.append(point.y + top if top_on_base else top)
	for segment in normals.size():
		var a := segment
		var b := segment + 1
		var normal := normals[segment] as Vector3
		_append_quad(bucket, _lifted(fronts[a], lows[a]), _lifted(fronts[b], lows[b]), _lifted(fronts[b], highs[b]), _lifted(fronts[a], highs[a]), normal)
		_append_quad(bucket, _lifted(backs[a], highs[a]), _lifted(backs[b], highs[b]), _lifted(fronts[b], highs[b]), _lifted(fronts[a], highs[a]), Vector3.UP)
		_append_quad(bucket, _lifted(fronts[a], lows[a]), _lifted(fronts[b], lows[b]), _lifted(backs[b], lows[b]), _lifted(backs[a], lows[a]), Vector3.DOWN)
		if emit_back:
			_append_quad(bucket, _lifted(backs[b], lows[b]), _lifted(backs[a], lows[a]), _lifted(backs[a], highs[a]), _lifted(backs[b], highs[b]), -normal)
	var last := points.size() - 1
	var first_direction := _flat_direction(points[0] as Vector3, points[1] as Vector3)
	var last_direction := _flat_direction(points[last - 1] as Vector3, points[last] as Vector3)
	_append_quad(bucket, _lifted(backs[0], lows[0]), _lifted(fronts[0], lows[0]), _lifted(fronts[0], highs[0]), _lifted(backs[0], highs[0]), -first_direction)
	_append_quad(bucket, _lifted(fronts[last], lows[last]), _lifted(backs[last], lows[last]), _lifted(backs[last], highs[last]), _lifted(fronts[last], highs[last]), last_direction)


## A profile swept along a horizontal path (the owner's 2026-11-20 photos: the canopy
## fascia's rolls, the head bands' rolls, the attic lines, copings and caps), real
## relief that takes light and shade. `profile` is the outer contour as [depth, y]
## pairs from its lower back round its front to its upper back, depth in metres out
## from the path line along each vertex's miter. The sweep shades smoothly along the
## path (each vertex's miter direction) and, where `rounded` is true, across the
## profile too (each profile vertex's normal the mean of its two edges'), so a few
## segments read as a rounded roll; a point given a third value (any) stays a sharp
## crease. Its ends close with the profile's polygon.
static func _append_profile_sweep(bucket: Dictionary, path: Dictionary, profile: Array, rounded: bool, close_ends: bool = true) -> void:
	var points := path.points as Array
	var normals := path.normals as Array
	var count := profile.size()
	if points.size() < 2 or normals.size() != points.size() - 1 or count < 2:
		return
	var contour: Array[Vector2] = []
	for value in profile:
		contour.append(Vector2(float(value[0]), float(value[1])))
	var edge_normals: Array[Vector2] = []
	for index in count - 1:
		var edge := contour[index + 1] - contour[index]
		edge_normals.append(Vector2(edge.y, -edge.x).normalized())
	var vertex_normals: Array[Vector2] = []
	for index in count:
		if index == 0:
			vertex_normals.append(edge_normals[0])
		elif index == count - 1:
			vertex_normals.append(edge_normals[count - 2])
		else:
			vertex_normals.append((edge_normals[index - 1] + edge_normals[index]).normalized())
	var flats: Array[Vector3] = []
	var miters: Array[Vector3] = []
	var along: Array[float] = []
	for index in points.size():
		var point := points[index] as Vector3
		flats.append(Vector3(point.x, 0.0, point.z))
		miters.append(_miter_offset(normals, index))
		along.append(0.0 if index == 0 else along[index - 1] + _flat_distance(flats[index - 1], flats[index]))
	for segment in normals.size():
		var a := segment
		var b := segment + 1
		var dir_a := miters[a].normalized()
		var dir_b := miters[b].normalized()
		for edge in count - 1:
			var p := contour[edge]
			var q := contour[edge + 1]
			var np := vertex_normals[edge] if rounded and (profile[edge] as Array).size() < 3 else edge_normals[edge]
			var nq := vertex_normals[edge + 1] if rounded and (profile[edge + 1] as Array).size() < 3 else edge_normals[edge]
			_append_quad_uv(bucket, [
				_lifted(flats[a] + miters[a] * p.x, p.y), _lifted(flats[b] + miters[b] * p.x, p.y),
				_lifted(flats[b] + miters[b] * q.x, q.y), _lifted(flats[a] + miters[a] * q.x, q.y),
			], [
				dir_a * np.x + Vector3.UP * np.y, dir_b * np.x + Vector3.UP * np.y,
				dir_b * nq.x + Vector3.UP * nq.y, dir_a * nq.x + Vector3.UP * nq.y,
			], [Vector2(along[a], p.y), Vector2(along[b], p.y), Vector2(along[b], q.y), Vector2(along[a], q.y)])
	if not close_ends:
		return
	var polygon := PackedVector2Array(contour)
	if Geometry2D.is_polygon_clockwise(polygon):
		polygon.reverse()
	var triangles := Geometry2D.triangulate_polygon(polygon)
	var last := points.size() - 1
	var ends := [[0, -_flat_direction(points[0] as Vector3, points[1] as Vector3)], [last, _flat_direction(points[last - 1] as Vector3, points[last] as Vector3)]]
	for end_value in ends:
		var at := int(end_value[0])
		var facing := end_value[1] as Vector3
		for offset in range(0, triangles.size(), 3):
			var corners: Array[Vector3] = []
			for corner in 3:
				var c := polygon[triangles[offset + corner]]
				corners.append(_lifted(flats[at] + miters[at] * c.x, c.y))
			_append_triangle(bucket, corners[0], corners[1], corners[2], facing)


## A profile of `count` half-round rolls of `radius`, stacked upward from `bottom`
## at `pitch` on a flat face at depth `face` (its back at `back`), each roll in
## `segments` facets: the head bands' and fascia's rolls, the attic's lines.
static func _rolls_profile(bottom: float, top: float, face: float, back: float, count: int, radius: float, pitch: float, segments: int = 4, with_back: bool = true) -> Array:
	var profile: Array = [[back, bottom, 1], [face, bottom, 1]] if with_back else [[face, bottom, 1]]
	var first := bottom + (top - bottom - pitch * float(count - 1)) * 0.5
	for roll in count:
		var center := first + pitch * float(roll)
		for step in segments + 1:
			var angle := -PI * 0.5 + PI * float(step) / float(segments)
			var point: Array = [face + cos(angle) * radius, center + sin(angle) * radius]
			if step == 0 or step == segments:
				point.append(1)
			profile.append(point)
	profile.append([face, top, 1])
	if with_back:
		profile.append([back, top, 1])
	return profile


## A coping in section: its face from `bottom` carrying `count` shallow rolls, then a
## cap `cap_height` deep standing `overhang` proud, its top running back to `back`.
static func _coping_profile(bottom: float, top: float, front: float, back: float, count: int, radius: float, pitch: float, cap_height: float, overhang: float) -> Array:
	var lines_top := top - cap_height
	var profile := _rolls_profile(bottom, lines_top, front, back, count, radius, pitch)
	profile.pop_back()
	profile.append([front + overhang, lines_top, 1])
	profile.append([front + overhang, top, 1])
	profile.append([back, top, 1])
	return profile


## A vertical reed on a module frame (the crescent's fluted piers; the owner's
## 2026-11-20 photos): a half-round of half-width `half` and relief `relief` standing
## out from `face` (depth from the frame's anchor line), from `bottom` to `top`, its
## ends rounded over `end` metres (no rounding where `end` is 0). Smooth-shaded
## across, so a pier's reeds keep their stripes in shade, where the sky lights each
## reed's front more than its sides.
static func _append_reed(bucket: Dictionary, frame: Dictionary, center: float, half: float, relief: float, face: float, bottom: float, top: float, end: float, segments: int = 5) -> void:
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	var anchor := frame.anchor as Vector3
	var base := Vector3(anchor.x, 0.0, anchor.z)
	# Rings from the bottom end's tip up to the top end's tip: [y, scale, rise].
	var rings: Array = []
	var steps := 2 if end > 0.0 else 0
	for step in range(steps, 0, -1):
		var angle := PI * 0.5 * float(step) / float(steps + 1)
		rings.append([bottom + end - sin(angle) * end, cos(angle), -sin(angle)])
	rings.append([bottom + end, 1.0, 0.0])
	rings.append([top - end, 1.0, 0.0])
	for step in range(1, steps + 1):
		var angle := PI * 0.5 * float(step) / float(steps + 1)
		rings.append([top - end + sin(angle) * end, cos(angle), sin(angle)])
	var section: Array[Vector2] = []
	var section_normals: Array[Vector2] = []
	for step in segments + 1:
		var angle := PI - PI * float(step) / float(segments)
		section.append(Vector2(cos(angle) * half, sin(angle) * relief))
		section_normals.append(Vector2(cos(angle) / maxf(half, 0.001), sin(angle) / maxf(relief, 0.001)).normalized())
	for ring in rings.size() - 1:
		var low := rings[ring] as Array
		var high := rings[ring + 1] as Array
		for step in segments:
			var corners: Array = []
			var corner_normals: Array = []
			for pick in [[low, step], [low, step + 1], [high, step + 1], [high, step]]:
				var r := pick[0] as Array
				var s := section[int(pick[1])] * float(r[1])
				var n := section_normals[int(pick[1])]
				corners.append(base + tangent * (center + s.x) + normal * (face + s.y) + Vector3.UP * float(r[0]))
				var rise := float(r[2])
				corner_normals.append((tangent * n.x + normal * n.y) * sqrt(maxf(1.0 - rise * rise, 0.0)) + Vector3.UP * rise)
			_append_quad_uv(bucket, corners, corner_normals, [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])


## Pale dentil blocks along a module frame's chord (the owner's 2026-11-20 photos:
## crescent head bands, wing window heads, the pavilions' course): `count` blocks
## `width` wide spread evenly between lateral_from and lateral_to, from y0 to y1,
## from `back` out to `front` (depths from the frame's anchor line).
static func _append_dentil_blocks(bucket: Dictionary, frame: Dictionary, lateral_from: float, lateral_to: float, y0: float, y1: float, back: float, front: float, width: float, count: int) -> void:
	if count < 1:
		return
	var pitch := (lateral_to - lateral_from - width) / float(maxi(count - 1, 1))
	for index in count:
		var x := lateral_from + width * 0.5 + pitch * float(index) if count > 1 else (lateral_from + lateral_to) * 0.5
		_append_frame_box(bucket, frame, x - width * 0.5, x + width * 0.5, y0, y1, back, front)


## A band like _append_path_band whose front face carries the stucco's detail
## pattern through its UV: u is arc length along the front over `u_period`, v is
## (y - v_origin) / v_period. The front face takes smooth normals (each vertex's
## miter), so a curved band shades without steps at the source runs' kinks. Its top,
## bottom and ends read the pattern at `plain_uv`, a plain spot of it. `faces` picks
## them: 1 bottom, 2 top, 4 ends, 8 back.
static func _append_pattern_band(bucket: Dictionary, path: Dictionary, bottom: float, top: float, front: float, back: float, u_period: float, v_origin: float, v_period: float, plain_uv: Vector2 = Vector2(0.5, 0.5), faces: int = 7) -> void:
	var points := path.points as Array
	var normals := path.normals as Array
	if points.size() < 2 or normals.size() != points.size() - 1 or top <= bottom:
		return
	var fronts: Array[Vector3] = []
	var backs: Array[Vector3] = []
	var smooth: Array[Vector3] = []
	var along: Array[float] = []
	for index in points.size():
		var point := points[index] as Vector3
		var miter := _miter_offset(normals, index)
		var flat := Vector3(point.x, 0.0, point.z)
		fronts.append(flat + miter * front)
		backs.append(flat + miter * back)
		smooth.append(miter.normalized())
		along.append(0.0 if index == 0 else along[index - 1] + _flat_distance(fronts[index - 1], fronts[index]))
	var v_low := (bottom - v_origin) / v_period
	var v_high := (top - v_origin) / v_period
	var plain: Array = [plain_uv, plain_uv, plain_uv, plain_uv]
	for segment in normals.size():
		var a := segment
		var b := segment + 1
		var normal := normals[segment] as Vector3
		var u_a := along[a] / u_period
		var u_b := along[b] / u_period
		_append_quad_uv(bucket, [_lifted(fronts[a], bottom), _lifted(fronts[b], bottom), _lifted(fronts[b], top), _lifted(fronts[a], top)], [smooth[a], smooth[b], smooth[b], smooth[a]], [Vector2(u_a, v_low), Vector2(u_b, v_low), Vector2(u_b, v_high), Vector2(u_a, v_high)])
		if faces & 2:
			_append_quad_uv(bucket, [_lifted(backs[a], top), _lifted(backs[b], top), _lifted(fronts[b], top), _lifted(fronts[a], top)], [Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP], plain)
		if faces & 1:
			_append_quad_uv(bucket, [_lifted(fronts[a], bottom), _lifted(fronts[b], bottom), _lifted(backs[b], bottom), _lifted(backs[a], bottom)], [Vector3.DOWN, Vector3.DOWN, Vector3.DOWN, Vector3.DOWN], plain)
		if faces & 8:
			_append_quad_uv(bucket, [_lifted(backs[b], bottom), _lifted(backs[a], bottom), _lifted(backs[a], top), _lifted(backs[b], top)], [-normal, -normal, -normal, -normal], plain)
	if faces & 4:
		var last := points.size() - 1
		var first_direction := -_flat_direction(points[0] as Vector3, points[1] as Vector3)
		var last_direction := _flat_direction(points[last - 1] as Vector3, points[last] as Vector3)
		_append_quad_uv(bucket, [_lifted(backs[0], bottom), _lifted(fronts[0], bottom), _lifted(fronts[0], top), _lifted(backs[0], top)], [first_direction, first_direction, first_direction, first_direction], plain)
		_append_quad_uv(bucket, [_lifted(fronts[last], bottom), _lifted(backs[last], bottom), _lifted(backs[last], top), _lifted(fronts[last], top)], [last_direction, last_direction, last_direction, last_direction], plain)


## A band on `path` in two materials: plain from bottom to lines_bottom and from the
## lines' top to top, and `count` incised lines (the stucco's line pattern, one per
## `pitch`) between, all one depth and smooth-shaded (_append_pattern_band). The
## lines' material has the plain one's paint, so the parts read as one band.
static func _append_lined_band(plain: Dictionary, lines: Dictionary, path: Dictionary, bottom: float, top: float, front: float, back: float, lines_bottom: float, pitch: float, count: int, emit_back: bool = false) -> void:
	var lines_top := minf(lines_bottom + pitch * float(count), top)
	var back_face := 8 if emit_back else 0
	if lines_bottom > bottom + 0.001:
		_append_pattern_band(plain, path, bottom, lines_bottom, front, back, 1.0, 0.0, 1.0, Vector2(0.5, 0.5), 1 | 4 | back_face)
	_append_pattern_band(lines, path, maxf(bottom, lines_bottom), lines_top, front, back, 1.0, lines_bottom, pitch, Vector2(0.5, 0.6), (1 if lines_bottom <= bottom + 0.001 else 0) | (2 if lines_top >= top - 0.001 else 0) | 4 | back_face)
	if lines_top < top - 0.001:
		_append_pattern_band(plain, path, lines_top, top, front, back, 1.0, 0.0, 1.0, Vector2(0.5, 0.5), 2 | 4 | back_face)


## A two-point path along a module frame's chord, `depth` out from its anchor line,
## for a pattern band over a frame-based element (_append_frame_box's coordinates).
static func _frame_path(frame: Dictionary, lateral_from: float, lateral_to: float, depth: float) -> Dictionary:
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	var anchor := frame.anchor as Vector3
	var base := Vector3(anchor.x, 0.0, anchor.z) + normal * depth
	return {"points": [base + tangent * lateral_from, base + tangent * lateral_to], "normals": [normal]}


## Flat coping (dated photos: the wings, the pavilions' flanks and fins): a thin band
## `coping.front` proud with three incised lines along its lower part, its back closed
## where it stands above a roof.
static func _append_flat_coping(trim: Dictionary, lines: Dictionary, path: Dictionary, top: float, coping: Dictionary, back: float) -> void:
	var bottom := top - float(coping.height)
	_append_profile_sweep(trim, path, _coping_profile(bottom, top, float(coping.front), back, int(coping.line_count), float(coping.line_radius), float(coping.line_pitch), float(coping.cap_height), float(coping.cap_overhang)), true)


## A chain's front band set down (dated photos: the crescent's front block under the
## taller central block behind it; the wings' two-storey faces before their set-back
## third storey). The chain's outer faces rise from low_y to face_top (its strip
## skips them); a riser stands `depth` back on the mitered offset path from face_top to
## high_y, facing out; walls close the notch's ends against full-height neighbours
## (close_start, close_end), facing back into it. Visual and collision. Returns the
## chain's outer path and the riser's path.
## A band raised above its strip instead (face_top over high_y: the junction towers)
## stands the same way: its back wall faces in and its end walls face out.
static func _append_front_step(visual: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], low_y: float, face_top: float, high_y: float, depth: float, close_start: bool, close_end: bool, min_segment: float = FRONT_STEP_MIN_SEGMENT_M) -> Dictionary:
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var start := frame.start as Vector3
		var end := frame.end as Vector3
		for target: Dictionary in [visual, collision]:
			_append_vertical_face(target, start, end, low_y, face_top, frame.normal as Vector3)
	var outer := _simplified_path(_chain_points(record, runs, 0.0, _chain_length(record, runs)), min_segment)
	var inner := _offset_path(outer, depth)
	var outer_points := outer.points as Array
	var inner_points := inner.points as Array
	var normals := outer.normals as Array
	if absf(face_top - high_y) < 0.001:
		return {"outer": _chain_points(record, runs, 0.0, _chain_length(record, runs)), "inner": inner}
	var raised := face_top > high_y
	var low := minf(face_top, high_y)
	var high := maxf(face_top, high_y)
	var facing := -1.0 if raised else 1.0
	for segment in normals.size():
		for target: Dictionary in [visual, collision]:
			_append_vertical_face(target, inner_points[segment] as Vector3, inner_points[segment + 1] as Vector3, low, high, (normals[segment] as Vector3) * facing)
	var last := outer_points.size() - 1
	for target: Dictionary in [visual, collision]:
		if close_start:
			_append_vertical_face(target, outer_points[0] as Vector3, inner_points[0] as Vector3, low, high, _flat_direction(outer_points[0] as Vector3, outer_points[1] as Vector3) * facing)
		if close_end:
			_append_vertical_face(target, inner_points[last] as Vector3, outer_points[last] as Vector3, low, high, -_flat_direction(outer_points[last - 1] as Vector3, outer_points[last] as Vector3) * facing)
	return {"outer": _chain_points(record, runs, 0.0, _chain_length(record, runs)), "inner": inner}


## The set-down band's roof between the chain's exact outer path and the riser's path
## (_append_front_step), at y. False if its polygon could not be triangulated.
static func _append_front_step_roof(visual: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], depth: float, y: float, min_segment: float = FRONT_STEP_MIN_SEGMENT_M) -> bool:
	var outer := _chain_points(record, runs, 0.0, _chain_length(record, runs))
	var inner := _offset_path(_simplified_path(outer, min_segment), depth)
	var polygon := PackedVector2Array()
	for point_value in outer.points as Array:
		var point := point_value as Vector3
		polygon.append(Vector2(point.x, point.z))
	var inner_points := inner.points as Array
	for index in range(inner_points.size() - 1, -1, -1):
		var point := inner_points[index] as Vector3
		polygon.append(Vector2(point.x, point.z))
	var indices := Geometry2D.triangulate_polygon(polygon)
	if indices.is_empty():
		return false
	for offset in range(0, indices.size(), 3):
		var corners: Array[Vector3] = []
		for corner in 3:
			var point := polygon[indices[offset + corner]]
			corners.append(Vector3(point.x, y, point.y))
		for target: Dictionary in [visual, collision]:
			_append_triangle(target, corners[0], corners[1], corners[2], Vector3.UP)
	return true


## A closed outline (outer path, its far end, the inner path back, its near end)
## with each side's outward normal: the coping round a tower's top.
static func _loop_path(outer: Dictionary, inner: Dictionary) -> Dictionary:
	var outer_points := outer.points as Array
	var inner_points := inner.points as Array
	var outer_normals := outer.normals as Array
	var last := outer_points.size() - 1
	var points: Array = outer_points.duplicate()
	var normals: Array = outer_normals.duplicate()
	normals.append(_flat_direction(outer_points[last - 1] as Vector3, outer_points[last] as Vector3))
	for index in range(last, -1, -1):
		points.append(inner_points[index])
		if index > 0:
			normals.append(-(outer_normals[index - 1] as Vector3))
	normals.append(-_flat_direction(outer_points[0] as Vector3, outer_points[1] as Vector3))
	points.append(outer_points[0])
	return {"points": points, "normals": normals}


## The path with interior points closer than `min_length` to the last kept one
## dropped (its ends kept) and each remaining segment's outward normal recomputed,
## turned like the source's. Offsetting a chain far (a set-down band's riser) folds
## at its very short source runs (runs 30-32 are 0.07-0.44 m); this does not.
static func _simplified_path(path: Dictionary, min_length: float) -> Dictionary:
	var points := path.points as Array
	var reference := (path.normals as Array)[0] as Vector3
	var kept: Array = [points[0]]
	for index in range(1, points.size() - 1):
		if _flat_distance(kept[kept.size() - 1] as Vector3, points[index] as Vector3) >= min_length and _flat_distance(points[index] as Vector3, points[points.size() - 1] as Vector3) >= min_length:
			kept.append(points[index])
	kept.append(points[points.size() - 1])
	var normals: Array = []
	for index in range(kept.size() - 1):
		var direction := _flat_direction(kept[index] as Vector3, kept[index + 1] as Vector3)
		var normal := Vector3(direction.z, 0.0, -direction.x)
		if normal.dot(reference) < 0.0:
			normal = -normal
		normals.append(normal)
		reference = normal
	return {"points": kept, "normals": normals}


## A flat raised outline on a module frame (lateral, y offsets from its centre): its
## face `front` out from the frame's anchor line and its edges back to `back`.
static func _append_frame_outline(bucket: Dictionary, frame: Dictionary, center_y: float, outline: Array, back: float, front: float) -> void:
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	var anchor := frame.anchor as Vector3
	var origin := Vector3(anchor.x, center_y, anchor.z)
	var polygon := PackedVector2Array()
	for value in outline:
		var pair := value as Array
		polygon.append(Vector2(float(pair[0]), float(pair[1])))
	if Geometry2D.is_polygon_clockwise(polygon):
		polygon.reverse()
	var indices := Geometry2D.triangulate_polygon(polygon)
	for offset in range(0, indices.size(), 3):
		var corners: Array[Vector3] = []
		for corner in 3:
			var point := polygon[indices[offset + corner]]
			corners.append(origin + tangent * point.x + Vector3.UP * point.y + normal * front)
		_append_triangle(bucket, corners[0], corners[1], corners[2], normal)
	for index in polygon.size():
		var a := polygon[index]
		var b := polygon[(index + 1) % polygon.size()]
		var edge := b - a
		var side := (tangent * edge.y - Vector3.UP * edge.x).normalized()
		var pa := origin + tangent * a.x + Vector3.UP * a.y
		var pb := origin + tangent * b.x + Vector3.UP * b.y
		_append_quad(bucket, pa + normal * back, pb + normal * back, pb + normal * front, pa + normal * front, side)


static func _append_quad_uv(bucket: Dictionary, corners: Array, corner_normals: Array, corner_uvs: Array) -> void:
	var vertices := bucket.vertices as Array
	var normals := bucket.normals as Array
	var uvs := bucket.uvs as Array
	var indices := bucket.indices as Array
	var base := vertices.size()
	var average := Vector3.ZERO
	for index in 4:
		vertices.append(corners[index])
		normals.append((corner_normals[index] as Vector3).normalized())
		uvs.append(corner_uvs[index])
		average += corner_normals[index] as Vector3
	var a := corners[0] as Vector3
	if ((corners[1] as Vector3) - a).cross((corners[2] as Vector3) - a).dot(average) > 0.0:
		indices.append_array([base, base + 2, base + 1, base, base + 3, base + 2])
	else:
		indices.append_array([base, base + 1, base + 2, base, base + 2, base + 3])


## Unit miter at a path vertex: a point displaced d along it lies d from both
## adjacent exact wall planes. Clamped so a reflex fold cannot explode a band.
static func _miter_offset(normals: Array, index: int) -> Vector3:
	if index <= 0:
		return normals[0] as Vector3
	if index >= normals.size():
		return normals[normals.size() - 1] as Vector3
	return _miter_between(normals[index - 1] as Vector3, normals[index] as Vector3)


static func _miter_between(previous: Vector3, current: Vector3) -> Vector3:
	return (previous + current) / maxf(1.0 + previous.dot(current), 0.25)


static func _lifted(point: Vector3, y: float) -> Vector3:
	return Vector3(point.x, y, point.z)


static func _flat_direction(origin_point: Vector3, target_point: Vector3) -> Vector3:
	return Vector3(target_point.x - origin_point.x, 0.0, target_point.z - origin_point.z).normalized()


## Exact chain polyline between two chain metres: interior run vertices,
## per-segment outward normals and interpolated source bottoms at the cuts.
## Collinear source splits merge into one segment, so a short split ending at
## a corner (run 4 is 0.19 m) cannot fold a mitered band back on itself.
static func _chain_points(record: Dictionary, runs: Array[int], from_m: float, to_m: float) -> Dictionary:
	var points: Array = []
	var normals: Array = []
	var accumulated := 0.0
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var length := float(frame.length_m)
		var run_start := accumulated
		accumulated += length
		if accumulated <= from_m + 0.0001 or run_start >= to_m - 0.0001:
			continue
		var start := frame.start as Vector3
		var end := frame.end as Vector3
		var normal := frame.normal as Vector3
		if points.is_empty():
			points.append(start.lerp(end, clampf((from_m - run_start) / length, 0.0, 1.0)))
		elif (normals[normals.size() - 1] as Vector3).dot(normal) > 0.9999:
			points.pop_back()
			normals.pop_back()
		points.append(start.lerp(end, clampf((to_m - run_start) / length, 0.0, 1.0)))
		normals.append(normal)
	return {"points": points, "normals": normals}


## Chord frame for a finite applied module spanning exact chain metres. Its
## lateral axis follows the chord; `lo`/`hi` bound the exact wall polyline in
## the span along the outward normal, so a module embeds behind the deepest wall
## point and measures projections from the most forward one.
static func _span_frame(record: Dictionary, runs: Array[int], from_m: float, to_m: float) -> Dictionary:
	var length := _chain_length(record, runs)
	var low_m := clampf(from_m, 0.0, length)
	var high_m := clampf(to_m, low_m + 0.001, length)
	var first := _chain_frame(record, runs, low_m)
	var last := _chain_frame(record, runs, high_m)
	var a := first.wall_anchor as Vector3
	var b := last.wall_anchor as Vector3
	var tangent := Vector3(b.x - a.x, 0.0, b.z - a.z).normalized()
	var normal := Vector3(-tangent.z, 0.0, tangent.x)
	if normal.dot((first.normal as Vector3) + (last.normal as Vector3)) < 0.0:
		normal = -normal
	var lo := 0.0
	var hi := 0.0
	var accumulated := 0.0
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		accumulated += float(frame.length_m)
		if accumulated > low_m + 0.0001 and accumulated < high_m - 0.0001:
			var offset := ((frame.end as Vector3) - a).dot(normal)
			lo = minf(lo, offset)
			hi = maxf(hi, offset)
	return {
		"anchor": a.lerp(b, 0.5),
		"tangent": tangent,
		"normal": normal,
		"lo": lo,
		"hi": hi,
		"mid_m": (low_m + high_m) * 0.5,
		"base_a": float(first.base_y),
		"base_b": float(last.base_y),
	}


## Box in a module frame: lateral metres along the frame tangent from its
## anchor, absolute Y, and signed depth along its outward normal.
static func _append_frame_box(bucket: Dictionary, frame: Dictionary, lateral_min: float, lateral_max: float, y_min: float, y_max: float, depth_min: float, depth_max: float) -> void:
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	var center := (frame.anchor as Vector3) + tangent * ((lateral_min + lateral_max) * 0.5) + normal * ((depth_min + depth_max) * 0.5)
	center.y = (y_min + y_max) * 0.5
	_append_box(bucket, center, tangent, normal, lateral_max - lateral_min, y_max - y_min, depth_max - depth_min)


static func _evenly_spaced(length: float, count: int, margin: float) -> Array[float]:
	var result: Array[float] = []
	for index in count:
		result.append(length * 0.5 if count == 1 else lerpf(margin, length - margin, float(index) / float(count - 1)))
	return result


## Chain metres (Vector2(from, to)) of a run of consecutive `members` on a chain.
static func _run_span(record: Dictionary, chain: Array[int], members: Array[int]) -> Vector2:
	var from_m := _chain_start_of(record, chain, members[0])
	var last_m := _chain_start_of(record, chain, members[members.size() - 1])
	return Vector2(from_m, last_m + float(_run_frame(record, members[members.size() - 1]).length_m))


static func _chain_start_of(record: Dictionary, runs: Array[int], target_run: int) -> float:
	var accumulated := 0.0
	for run_index in runs:
		if run_index == target_run:
			return accumulated
		accumulated += float(_run_frame(record, run_index).length_m)
	return -1.0


## Relocated pavilion compositions must still bind to the frozen footprint's
## stepped west ends: a straight west-facing centre face projecting 1-2.5 m past
## both flanks, with its corner bay recessed further behind them.
static func _pavilion_identity_valid(record: Dictionary, spec: Dictionary) -> bool:
	var center_runs := _int_array(spec.get("center_runs", []) as Array)
	var corner_runs := _int_array(spec.get("corner_runs", []) as Array)
	var flanks := spec.get("flank_runs", []) as Array
	if center_runs.is_empty() or corner_runs.is_empty() or flanks.size() != 2:
		return false
	var center_length := _chain_length(record, center_runs)
	var frame := _span_frame(record, center_runs, 0.0, center_length)
	var normal := frame.normal as Vector3
	var anchor := frame.anchor as Vector3
	if normal.x > -0.8 or center_length < 8.0 or float(frame.lo) < -0.08 or float(frame.hi) > 0.08:
		return false
	for flank_value in flanks:
		var flank := _int_array(flank_value as Array)
		var flank_anchor := _span_frame(record, flank, 0.0, _chain_length(record, flank)).anchor as Vector3
		var projection := (anchor - flank_anchor).dot(normal)
		if projection < 1.0 or projection > 2.5:
			return false
	var corner_anchor := _span_frame(record, corner_runs, 0.0, _chain_length(record, corner_runs)).anchor as Vector3
	return (anchor - corner_anchor).dot(normal) > 2.5


## The SE face and rear ribbon hosts must still be the frozen chains the dated
## rear view binds. Each chain is contiguous and faces out of the SE face or
## the east/north-east podium. The first rear chain starts at the SE face's
## protected seam, and every rear host is a protected run.
static func _rear_hosts_valid(record: Dictionary, se_runs: Array[int], chains: Array) -> bool:
	if se_runs.is_empty() or not _chain_contiguous(record, se_runs):
		return false
	for run_index in se_runs:
		var normal := _run_frame(record, run_index).normal as Vector3
		if run_index in PROTECTED_RUNS or normal.x < 0.4 or normal.z < 0.3:
			return false
	var seam := _run_frame(record, se_runs[se_runs.size() - 1]).end as Vector3
	for chain_index in chains.size():
		var host := _int_array(chains[chain_index] as Array)
		if host.is_empty() or not _chain_contiguous(record, host):
			return false
		var host_start := _run_frame(record, host[0]).start as Vector3
		if chain_index == 0 and Vector2(seam.x - host_start.x, seam.z - host_start.z).length() > 0.001:
			return false
		for run_index in host:
			if run_index not in PROTECTED_RUNS or (_run_frame(record, run_index).normal as Vector3).x < 0.5:
				return false
	return true


static func _chain_contiguous(record: Dictionary, runs: Array[int]) -> bool:
	for index in range(1, runs.size()):
		var previous := _run_frame(record, runs[index - 1]).end as Vector3
		var current := _run_frame(record, runs[index]).start as Vector3
		if Vector2(previous.x - current.x, previous.z - current.z).length() > 0.001:
			return false
	return true


## The observed drum-end pair must face out of the rear and fit the SE shoulder
## face with its surrounds and head. It sits between the podium roof and the
## shoulder top, with the small window clear above the tall one's head.
static func _drum_openings_fit(frame: Dictionary, width: float, openings: Dictionary, style: Dictionary, low_y: float, high_y: float) -> bool:
	if frame.is_empty() or (frame.normal as Vector3).x < 0.5:
		return false
	var tall := openings.tall as Dictionary
	var small := openings.small as Dictionary
	var tall_y := tall.y as Array
	var small_y := small.y as Array
	var side := float(style.surround) + maxf(float(style.sill_overhang), float(openings.head_overhang)) + float(openings.edge_margin_m)
	return width >= maxf(float(tall.glass_width), float(small.glass_width)) + 2.0 * side \
		and float(tall_y[0]) - float(style.sill_height) > low_y \
		and float(small_y[0]) - float(style.sill_height) > float(tall_y[1]) + float(style.head_height) + float(openings.head_height) \
		and float(small_y[1]) + float(style.head_height) < high_y


static func _append_wall_bar(bucket: Dictionary, anchor: Vector3, tangent: Vector3, normal: Vector3, center_y: float, width: float, height: float, projection: float) -> void:
	var center := anchor + normal * projection
	center.y = center_y
	_append_box(bucket, center, tangent, normal, width, height, 0.12)


static func _append_vertical_face(bucket: Dictionary, start: Vector3, end: Vector3, start_bottom_y: float, top_y: float, normal: Vector3, end_bottom_y: float = NAN) -> void:
	var resolved_end_bottom := start_bottom_y if is_nan(end_bottom_y) else end_bottom_y
	var bottom_start := Vector3(start.x, start_bottom_y, start.z)
	var bottom_end := Vector3(end.x, resolved_end_bottom, end.z)
	var top_end := Vector3(end.x, top_y, end.z)
	var top_start := Vector3(start.x, top_y, start.z)
	_append_quad(bucket, bottom_start, bottom_end, top_end, top_start, normal)


static func _append_box(bucket: Dictionary, center: Vector3, tangent_value: Vector3, normal_value: Vector3, width: float, height: float, depth: float) -> void:
	var tangent := tangent_value.normalized()
	var normal := normal_value.normalized()
	var up := Vector3.UP
	var tx := tangent * width * 0.5
	var ny := normal * depth * 0.5
	var uy := up * height * 0.5
	var fbl := center - tx - uy + ny
	var fbr := center + tx - uy + ny
	var ftr := center + tx + uy + ny
	var ftl := center - tx + uy + ny
	var bbl := center - tx - uy - ny
	var bbr := center + tx - uy - ny
	var btr := center + tx + uy - ny
	var btl := center - tx + uy - ny
	_append_quad(bucket, fbl, fbr, ftr, ftl, normal)
	_append_quad(bucket, bbr, bbl, btl, btr, -normal)
	_append_quad(bucket, ftl, ftr, btr, btl, up)
	_append_quad(bucket, bbl, bbr, fbr, fbl, -up)
	_append_quad(bucket, bbl, fbl, ftl, btl, -tangent)
	_append_quad(bucket, fbr, bbr, btr, ftr, tangent)


static func _append_quad(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal_value: Vector3) -> void:
	var normal := normal_value.normalized()
	var vertices := bucket.vertices as Array
	var normals := bucket.normals as Array
	var uvs := bucket.uvs as Array
	var indices := bucket.indices as Array
	var base := vertices.size()
	for point in [a, b, c, d]:
		vertices.append(point)
		normals.append(normal)
		uvs.append(Vector2(point.x + point.z, point.y))
	if (b - a).cross(c - a).dot(normal) > 0.0:
		indices.append_array([base, base + 2, base + 1, base, base + 3, base + 2])
	else:
		indices.append_array([base, base + 1, base + 2, base, base + 2, base + 3])


static func _append_triangle(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, normal_value: Vector3) -> void:
	var normal := normal_value.normalized()
	var vertices := bucket.vertices as Array
	var normals := bucket.normals as Array
	var uvs := bucket.uvs as Array
	var indices := bucket.indices as Array
	var base := vertices.size()
	for point in [a, b, c]:
		vertices.append(point)
		normals.append(normal)
		uvs.append(Vector2(point.x + point.z, point.y))
	if (b - a).cross(c - a).dot(normal) > 0.0:
		indices.append_array([base, base + 2, base + 1])
	else:
		indices.append_array([base, base + 1, base + 2])


static func _finish_record(root: Node3D, specs: Array[Dictionary], collision_bucket: Dictionary, sprayable: bool, metadata: Dictionary) -> Dictionary:
	var mesh_count := 0
	var surface_count := 0
	var triangle_count := 0
	for spec in specs:
		var bucket := spec.bucket as Dictionary
		if (bucket.indices as Array).is_empty():
			continue
		var mesh_instance := _mesh_instance(str(spec.name), bucket, spec.material as Material, int(spec.layers))
		root.add_child(mesh_instance)
		mesh_count += 1
		surface_count += 1
		triangle_count += int((bucket.indices as Array).size() / 3)
	var body := _collision_body(collision_bucket, str(root.get_meta("derived_object_key")), root.get_meta("source_keys") as Array, sprayable)
	if body == null:
		root.free()
		return {"ok": false, "code": "building_1_hero_collision", "message": "Building 1 hero collision geometry was empty."}
	root.add_child(body)
	metadata["mesh_instances"] = mesh_count
	metadata["surfaces"] = surface_count
	metadata["triangles"] = triangle_count
	metadata["collision_face_vertices"] = (collision_bucket.indices as Array).size()
	metadata["static_bodies"] = 1
	metadata["shapes"] = 1
	for key: String in metadata:
		root.set_meta(key, metadata[key])
	return {
		"ok": true,
		"node": root,
		"mesh_instances": mesh_count,
		"surfaces": surface_count,
		"triangles": triangle_count,
		"static_bodies": 1,
		"shapes": 1,
		"metadata": metadata,
	}


static func _mesh_instance(node_name: String, bucket: Dictionary, material: Material, layers: int) -> MeshInstance3D:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(bucket.vertices as Array)
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(bucket.normals as Array)
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(bucket.uvs as Array)
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(bucket.indices as Array)
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_name(0, node_name.to_snake_case())
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.layers = layers
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return instance


static func _collision_body(bucket: Dictionary, object_key: String, source_keys: Array, sprayable: bool) -> StaticBody3D:
	if (bucket.indices as Array).is_empty():
		return null
	var source_vertices := bucket.vertices as Array
	var faces := PackedVector3Array()
	for index_value in bucket.indices as Array:
		faces.append(source_vertices[int(index_value)] as Vector3)
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	shape.set_meta("receiver_kind", "building_wall" if sprayable else "none")
	shape.set_meta("opaque", true)
	shape.set_meta("derived_object_key", object_key)
	shape.set_meta("source_keys", source_keys.duplicate())
	shape.set_meta("building_1_hero", true)
	var shape_node := CollisionShape3D.new()
	shape_node.name = "Shape"
	shape_node.shape = shape
	var body := StaticBody3D.new()
	body.name = "Collision"
	body.collision_layer = PHYSICS_WORLD_SOLID | (PHYSICS_SPRAY_SURFACE if sprayable else 0)
	body.collision_mask = 0
	body.set_meta("receiver_kind", "building_wall" if sprayable else "none")
	body.set_meta("opaque", true)
	body.set_meta("derived_object_key", object_key)
	body.set_meta("source_keys", source_keys.duplicate())
	body.set_meta("building_1_hero", true)
	if sprayable:
		body.add_to_group("spray_receiver_wall")
	body.add_child(shape_node)
	return body


static func _hero_root(node_name: String, record: Dictionary, component: String) -> Node3D:
	var root := Node3D.new()
	root.name = node_name
	root.set_meta("derived_object_key", str(record.object_key))
	root.set_meta("source_keys", (record.source_keys as Array).duplicate())
	root.set_meta("feature_kind", str(record.feature_kind))
	root.set_meta("building_1_hero_component", component)
	return root


static func _common_metadata(config: Dictionary, record: Dictionary, component: String) -> Dictionary:
	return {
		"model_id": str(config.model_id),
		"config_path": CONFIG_PATH,
		"source_key": str((record.source_keys as Array)[0]),
		"object_key": str(record.object_key),
		"component": component,
		"runtime_supersedes_generated_placeholder": true,
		"horizontal_source_geometry_preserved": true,
		"vertical_massing_role": "reversible_production_inference",
		"surveyed_vertical_dimensions": false,
		"surveyed_facade_coordinates": false,
		"surveyed_cadence": false,
		"interior_modeled": false,
		"source_photography_shipped": false,
	}


static func _run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var offset := run_index * 12
	if run_index < 0 or offset + 11 >= values.size():
		return {}
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var horizontal := end - start
	horizontal.y = 0.0
	return {
		"start": start,
		"end": end,
		"length_m": horizontal.length(),
		"tangent": horizontal.normalized(),
		"normal": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized(),
	}


static func _chain_length(record: Dictionary, runs: Array[int]) -> float:
	var result := 0.0
	for run_index in runs:
		result += float(_run_frame(record, run_index).length_m)
	return result


static func _chain_frame(record: Dictionary, runs: Array[int], chain_m: float) -> Dictionary:
	var accumulated := 0.0
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var length := float(frame.length_m)
		if chain_m <= accumulated + length + 0.0001:
			var fraction := clampf((chain_m - accumulated) / length, 0.0, 1.0)
			var start := frame.start as Vector3
			var end := frame.end as Vector3
			return {
				"wall_anchor": start.lerp(end, fraction),
				"base_y": lerpf(start.y, end.y, fraction),
				"tangent": frame.tangent,
				"normal": frame.normal,
				"run_index": run_index,
			}
		accumulated += length
	return {}


static func _plan_centroid_from_wall(record: Dictionary) -> Vector3:
	var points: Array[Vector3] = []
	for run_index in range(10):
		points.append(_run_frame(record, run_index).start as Vector3)
	return _plan_centroid(points)


static func _plan_centroid(points: Array[Vector3]) -> Vector3:
	var center := Vector3.ZERO
	for point in points:
		center += point
	return center / float(points.size())


static func _roof_unique_points(record: Dictionary) -> Array[Vector3]:
	var values := record.vertices as Array
	var result: Array[Vector3] = []
	for offset in range(0, values.size(), 3):
		result.append(Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2])))
	return result


static func _scaled_plan_point(source: Vector3, center: Vector3, scale: float, y: float) -> Vector3:
	return Vector3(center.x + (source.x - center.x) * scale, y, center.z + (source.z - center.z) * scale)


static func _outward_normal(start: Vector3, end: Vector3, fallback: Vector3) -> Vector3:
	var tangent := end - start
	tangent.y = 0.0
	if tangent.length_squared() <= 0.000001:
		return fallback
	var candidate := fallback.normalized()
	return candidate


static func _bucket() -> Dictionary:
	return {"vertices": [], "normals": [], "uvs": [], "indices": []}


static func _record_from_chunk(path: String, key: String) -> Dictionary:
	var chunk := _json(path)
	for value: Variant in chunk.get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


static func _record_valid(record: Dictionary) -> bool:
	if record.is_empty() or str(record.get("object_key", "")) not in TARGET_KEYS:
		return false
	var key := str(record.object_key)
	var expected_source := BUILDING_SOURCE_KEY if key.begins_with("building:r16681702") else TOWER_SOURCE_KEY
	var expected_feature := "building_wall" if key.ends_with(":wall") else "building_roof"
	return record.get("source_keys", []) == [expected_source] \
		and str(record.get("feature_kind", "")) == expected_feature \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and not (record.get("vertices", []) as Array).is_empty() \
		and not (record.get("indices", []) as Array).is_empty()


static func _config_valid(config: Dictionary) -> bool:
	if config.is_empty():
		return false
	var target := config.get("target", {}) as Dictionary
	var vertical := config.get("vertical_production_inference_m", {}) as Dictionary
	var schedule := config.get("facade_schedule", {}) as Dictionary
	var seams := schedule.get("protected_seam_piers", {}) as Dictionary
	var central_runs: Array[int] = []
	for run_index in range(21, 44):
		central_runs.append(run_index)
	return str(config.get("schema_version", "")) == "ti.building-1-hero-model/2" \
		and str(target.get("building_source_key", "")) == BUILDING_SOURCE_KEY \
		and str(target.get("tower_source_key", "")) == TOWER_SOURCE_KEY \
		and bool(target.get("tower_remains_separately_reviewable", false)) \
		and float(vertical.get("two_story_roof_y", 0.0)) < float(vertical.get("three_story_roof_y", 0.0)) \
		and float(vertical.get("three_story_roof_y", 0.0)) < float(vertical.get("four_story_roof_y", 0.0)) \
		and float(vertical.get("four_story_roof_y", 0.0)) < float(vertical.get("tower_glass_top_y", 0.0)) \
		and float(vertical.get("tower_glass_top_y", 0.0)) < float(vertical.get("tower_roof_peak_y", 0.0)) \
		and _int_array(schedule.get("central_runs", []) as Array) == central_runs \
		and _int_array(schedule.get("crescent_field_runs", []) as Array) == CRESCENT_FIELD_RUNS \
		and int(schedule.get("central_window_count", 0)) == 11 \
		and int(schedule.get("central_lights_per_window", 0)) == 18 \
		and int(schedule.get("upper_windows_per_wing", 0)) == 8 \
		and int(schedule.get("upper_lights_per_window", 0)) == 10 \
		and int(schedule.get("lower_windows_per_wing", 0)) == 7 \
		and int(schedule.get("north_face_windows_per_floor", 0)) > 0 \
		and _int_array(schedule.get("north_wing_window_runs", []) as Array) == NORTH_WING_WINDOW_RUNS \
		and _int_array(schedule.get("south_wing_window_runs", []) as Array) == SOUTH_WING_WINDOW_RUNS \
		and _int_array(schedule.get("north_face_window_runs", []) as Array) == NORTH_FACE_WINDOW_RUNS \
		and _pavilion_runs_match(schedule.get("north_pavilion", {}) as Dictionary, NORTH_PAVILION_RUNS) \
		and _pavilion_runs_match(schedule.get("south_pavilion", {}) as Dictionary, SOUTH_PAVILION_RUNS) \
		and _pavilion_entry_valid(schedule.get("north_pavilion", {}) as Dictionary) \
		and _pavilion_entry_valid(schedule.get("south_pavilion", {}) as Dictionary) \
		and _int_array(schedule.get("entrance_bays", []) as Array) == ENTRANCE_BAYS \
		and _junction_window_runs(schedule.get("junction_windows", []) as Array) == JUNCTION_WINDOW_RUNS \
		and _junction_window_runs(schedule.get("north_junction_windows", []) as Array) == NORTH_JUNCTION_WINDOW_RUNS \
		and _int_array(schedule.get("se_face_runs", []) as Array) == SE_FACE_RUNS \
		and _chains_equal(schedule.get("rear_ribbon_host_chains", []) as Array, REAR_RIBBON_HOST_CHAINS) \
		and int(seams.get("north_run_start", -1)) == 96 \
		and int(seams.get("south_run_end", -1)) == 69 \
		and int(schedule.get("tall_windows_per_end", 0)) == 2 \
		and int(schedule.get("lights_per_tall_end_window", 0)) == 20 \
		and int(schedule.get("entrance_groups", 0)) == 3 \
		and int(schedule.get("doors_per_entrance_group", 0)) == 3


static func _pavilion_entry_valid(config: Dictionary) -> bool:
	var entry := config.get("entry", {}) as Dictionary
	for key: String in PAVILION_ENTRY_KEYS:
		if not entry.has(key):
			return false
	return float(entry.door_half_width) < float(entry.recess_half_width) \
		and float(entry.transom_height) < float(entry.height)


static func _junction_window_runs(specs: Array) -> Array[int]:
	var runs: Array[int] = []
	for spec_value in specs:
		var spec := spec_value as Dictionary
		if not spec.has("run") or not spec.has("glass_width") or not spec.has("columns"):
			return []
		runs.append(int(spec.run))
	return runs


static func _chains_equal(chains: Array, expected: Array) -> bool:
	if chains.size() != expected.size():
		return false
	for index in chains.size():
		if not chains[index] is Array or _int_array(chains[index] as Array) != _int_array(expected[index] as Array):
			return false
	return true


static func _pavilion_runs_match(config: Dictionary, expected: Dictionary) -> bool:
	if _int_array(config.get("center_runs", []) as Array) != _int_array(expected.center_runs as Array) \
		or _int_array(config.get("corner_runs", []) as Array) != _int_array(expected.corner_runs as Array):
		return false
	var flanks := config.get("flank_runs", []) as Array
	var expected_flanks := expected.flank_runs as Array
	if flanks.size() != expected_flanks.size():
		return false
	for index in flanks.size():
		if _int_array(flanks[index] as Array) != _int_array(expected_flanks[index] as Array):
			return false
	return true


static func _bar_config_valid(config: Dictionary) -> bool:
	if config.is_empty():
		return false
	var target := config.get("target", {}) as Dictionary
	var geometry := config.get("geometry_production_inference_m", {}) as Dictionary
	var crescent_style := geometry.get("crescent_window_style", {}) as Dictionary
	var expected_runs: Array[int] = []
	for run_index in range(21, 44):
		expected_runs.append(run_index)
	var canopy_runs: Array[int] = []
	for run_index in range(21, 39):
		canopy_runs.append(run_index)
	var canopy := geometry.get("canopy", {}) as Dictionary
	var attic := geometry.get("crescent_attic", {}) as Dictionary
	var crown := geometry.get("pavilion_crown", {}) as Dictionary
	var block := geometry.get("crescent_block", {}) as Dictionary
	var wing_setback := geometry.get("wing_setback", {}) as Dictionary
	var window_y := geometry.get("crescent_window_y", []) as Array
	var head_y := geometry.get("entrance_portal_head_y", []) as Array
	var pier_y := geometry.get("crescent_pier_y", []) as Array
	var skin_y := attic.get("skin_y", []) as Array
	var coping := attic.get("coping", []) as Array
	var lines := attic.get("lines", {}) as Dictionary
	var block_runs: Array[int] = []
	for run_index in range(21, 39):
		block_runs.append(run_index)
	# The canopy clears the entrance portals' heads and the projecting base's cap, and
	# its top stays under the crescent windows' sills; the attic skin runs from over
	# the head bands, past the pier tops, to the coping, its lines inside it; the front
	# block's roof stands under the coping's top and under the central block's roof.
	return str(config.get("schema_version", "")) == "ti.building-1-public-front-believability/5" \
		and str(config.get("pass_id", "")) == "building-1-public-family-opus-2026-10-16" \
		and str(target.get("building_source_key", "")) == BUILDING_SOURCE_KEY \
		and str(target.get("wall_object_key", "")) == BUILDING_WALL_KEY \
		and str(target.get("roof_object_key", "")) == BUILDING_ROOF_KEY \
		and _int_array(target.get("public_front_chain_runs", []) as Array) == expected_runs \
		and is_equal_approx(float(geometry.get("projecting_base_depth", -1.0)), 0.28) \
		and float(geometry.get("projecting_base_top_y", 99.0)) <= float(canopy.get("soffit_y", 0.0)) + 0.05 \
		and _int_array(canopy.get("runs", []) as Array) == canopy_runs \
		and float(canopy.get("depth_m", 0.0)) >= 2.0 and float(canopy.get("depth_m", 99.0)) <= 8.0 \
		and window_y.size() == 2 and head_y.size() == 2 and pier_y.size() == 2 \
		and float(canopy.get("soffit_y", 0.0)) > maxf(float(head_y[1]), float((geometry.get("projecting_base_cap_y", [99.0, 99.0]) as Array)[1])) \
		and float(canopy.get("top_y", 99.0)) > float(canopy.get("soffit_y", 99.0)) \
		and float(canopy.get("top_y", 99.0)) < float(window_y[0]) \
		and skin_y.size() == 2 and coping.size() == 3 and lines.has("bottom") and lines.has("pitch") and int(lines.get("count", 0)) > 0 \
		and float(skin_y[0]) > float(window_y[1]) and float(skin_y[0]) < float(pier_y[1]) and float(pier_y[1]) < float(lines.bottom) \
		and float(lines.bottom) + float(lines.pitch) * float(lines.count) < float(skin_y[1]) \
		and is_equal_approx(float(skin_y[1]), float(coping[0])) and float(coping[1]) > float(coping[0]) \
		and _int_array(block.get("runs", []) as Array) == block_runs and float(block.get("depth_m", 0.0)) > 0.0 \
		and float(block.get("roof_y", 99.0)) < float(coping[1]) and float(block.get("roof_y", 0.0)) > float(coping[0]) \
		and _int_array(wing_setback.get("north_runs", []) as Array) == NORTH_WING_WINDOW_RUNS and _int_array(wing_setback.get("south_runs", []) as Array) == SOUTH_WING_WINDOW_RUNS \
		and float(wing_setback.get("setback", 0.0)) > 0.0 and (geometry.get("wing_window_floors", []) as Array).size() == 2 \
		and float(crown.get("top_y", 0.0)) > float(crown.get("bottom_y", 99.0)) \
		and float(crown.get("fin_top_y", 0.0)) > float(crown.get("bottom_y", 99.0)) \
		and float(geometry.get("crescent_pier_depth", 0.0)) > float(crescent_style.get("jamb_front", 1.0)) \
		and float(geometry.get("crescent_pier_reed_front", 0.0)) > float(geometry.get("crescent_pier_depth", 1.0)) \
		and int(geometry.get("crescent_pier_reeds", 0)) > 0 \
		and geometry.get("flat_coping", null) is Dictionary \
		and (geometry.get("window_floors", []) as Array).size() == 3 \
		and float(geometry.get("entrance_portal_front", 0.0)) > float(geometry.get("entrance_frame_front", 1.0)) \
		and geometry.get("pavilion_emblem", null) is Dictionary \
		and geometry.get("podium_ribbon", null) is Dictionary \
		and geometry.get("drum_end_openings", null) is Dictionary \
		and (geometry.get("se_narrow_window_y", []) as Array).size() == 2 \
		and (geometry.get("se_podium_string_course", []) as Array).size() == 3


static func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	return {
		"ok": false,
		"code": code,
		"message": message,
		"source_keys": (record.get("source_keys", []) as Array).duplicate(),
	}
