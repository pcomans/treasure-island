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
const ENTRANCE_BAYS := [2, 5, 8]
const JUNCTION_WINDOW_RUNS := [38, 43]
const NORTH_JUNCTION_WINDOW_RUNS := [17, 20]
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
	_append_exact_base_walls(buckets.wall, original, collision, record, two_y, lowered)
	_append_strip_walls(buckets.wall, original, collision, record, north_runs, two_y, three_y, north_depth, tier_clip)
	_append_strip_walls(buckets.wall, original, collision, record, central_runs, two_y, four_y, central_depth)
	var se_setback := front.se_setback as Dictionary
	var skip_outer := {}
	for run_value in se_setback.skip_outer_runs as Array:
		skip_outer[int(run_value)] = true
	var se_cuts := _setback_cuts(record, [se_setback.runs], float(se_setback.setback))
	_append_strip_walls(buckets.wall, original, collision, record, south_runs, two_y, three_y, float(vertical.south_wing_inward_depth), tier_clip, skip_outer, se_cuts)
	_append_projecting_base(buckets.base, collision, record, central_runs, front)

	# Everything below appends after the accepted collision prefix.
	# Crescent: rusticated projecting base, eleven pier-framed two-story bays and
	# three glazed-bronze entrance groups under the bays the dated view shows.
	var field_runs := _int_array(schedule.crescent_field_runs)
	var crescent := _crescent_layout(record, field_runs, int(schedule.central_window_count), front)
	_append_base_rustication(buckets.base, record, central_runs, front)
	_append_crescent_bays(buckets, record, field_runs, crescent, front)
	_append_entry_composition(buckets, collision, record, field_runs, crescent, schedule.entrance_bays as Array, int(schedule.doors_per_entrance_group), front)
	_append_junction_windows(buckets, record, schedule.junction_windows as Array, front)

	# Wings, the north face and both west-end pavilions share one floor schedule.
	var floors := front.window_floors as Array
	var wing_style := front.wing_window_style as Dictionary
	for wing_runs: Array[int] in [_int_array(schedule.north_wing_window_runs), _int_array(schedule.south_wing_window_runs)]:
		_append_wing_facade(buckets, record, wing_runs, int(schedule.upper_windows_per_wing), int(schedule.lower_windows_per_wing), floors, front)
	var north_face := _int_array(schedule.north_face_window_runs)
	var north_face_centers := _evenly_spaced(_chain_length(record, north_face), int(schedule.north_face_windows_per_floor), float(front.north_face_window_margin_m))
	_append_window_grid(buckets, record, north_face, north_face_centers, float(front.north_face_window_width), floors, wing_style)
	_append_north_junction_bays(buckets, record, schedule.north_junction_windows as Array, floors, wing_style)
	_append_pavilion(buckets, collision, record, north_pavilion, floors, front)
	_append_pavilion(buckets, collision, record, south_pavilion, floors, front)

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

	# Cornices wrap each tier's exposed end caps; plinths ground the wing and
	# pavilion walls; piers stand at the two protected-run seams.
	var cornice_back := float(front.cornice_back)
	var inner_trim := float(front.cornice_inner_trim)
	var butt_trim := float(front.cornice_butt_trim)
	var wing_cornice := front.wing_cornice as Array
	var north_path := _chain_points(record, north_runs, 0.0, _chain_length(record, north_runs) - butt_trim)
	var north_cap := _strip_cap(record, north_runs[0], true, north_depth - inner_trim)
	_prepend_point(north_path, north_cap.point as Vector3, north_cap.normal as Vector3)
	_append_cornice(buckets.trim, north_path, wing_cornice, cornice_back)
	var central_path := _chain_points(record, central_runs, 0.0, _chain_length(record, central_runs))
	var central_first := _strip_cap(record, central_runs[0], true, central_depth - inner_trim)
	var central_last := _strip_cap(record, central_runs[central_runs.size() - 1], false, central_depth - inner_trim)
	_prepend_point(central_path, central_first.point as Vector3, central_first.normal as Vector3)
	_append_point(central_path, central_last.point as Vector3, central_last.normal as Vector3)
	_append_cornice(buckets.trim, central_path, front.crescent_cornice as Array, cornice_back)
	var se_first := int((se_setback.runs as Array)[0])
	var south_front_runs: Array[int] = []
	for run_index in south_runs:
		if run_index < se_first:
			south_front_runs.append(run_index)
	var south_path := _chain_points(record, south_front_runs, 0.0, _chain_length(record, south_front_runs))
	# Turn in along the notch to the setback face, then follow it to the shoulder.
	var notch_normal := _flat_direction(se_outer.points[0] as Vector3, se_inner.points[0] as Vector3).cross(Vector3.UP)
	if notch_normal.dot(_run_frame(record, south_front_runs[south_front_runs.size() - 1]).tangent as Vector3) < 0.0:
		notch_normal = -notch_normal
	_append_point(south_path, se_inner.points[0] as Vector3, notch_normal)
	for index in range(1, (se_inner.points as Array).size()):
		_append_point(south_path, se_inner.points[index] as Vector3, se_inner.normals[index - 1] as Vector3)
	_append_cornice(buckets.trim, south_path, wing_cornice, cornice_back)
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
	_append_plinth(buckets.base, record, north_runs, seam_trim, butt_trim, [_pavilion_door_gap(record, north_runs, north_pavilion)], front)
	_append_plinth(buckets.base, record, south_runs, 0.0, seam_trim, [_pavilion_door_gap(record, south_runs, south_pavilion)], front)

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
	var crescent_style := front.crescent_window_style as Dictionary
	var crescent_cornice := front.crescent_cornice as Array
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
		"abstract_winged_relief_count": 2,
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
			float((crescent_cornice[crescent_cornice.size() - 1] as Array)[2]),
		],
		"existing_cc0_plaster_maps_used": true,
		"genai_texture_candidate_consumed": false,
		"horizontal_source_geometry_changed": false,
		"source_wall_bottoms_changed": false,
		"tier_massing_changed": false,
		"base_wall_outer_tier_and_projecting_base_collision_preserved": true,
		"spray_ownership_changed": false,
		"recognition_status": "accepted_before_quality_hardening_and_preserved",
		"visual_review_status": VISUAL_REVIEW_STATUS,
	}, true)
	return _finish_record(root, specs, collision, true, metadata)


static func _build_building_roof(record: Dictionary, wall_record: Dictionary, config: Dictionary, bar_config: Dictionary) -> Dictionary:
	var vertical := config.vertical_production_inference_m as Dictionary
	var chains := config.massing_chains as Dictionary
	var schedule := config.facade_schedule as Dictionary
	var front := bar_config.geometry_production_inference_m as Dictionary
	var two_y := float(vertical.two_story_roof_y)
	var three_y := float(vertical.three_story_roof_y)
	var four_y := float(vertical.four_story_roof_y)
	var roof := _bucket()
	var canopy := _bucket()
	var soffit := _bucket()
	var collision := _bucket()
	var tier_clip := _tier_clip(wall_record)
	var field_runs := _int_array(schedule.crescent_field_runs)
	var crescent := _crescent_layout(wall_record, field_runs, int(schedule.central_window_count), front)
	var north_ring := front.north_ring as Dictionary
	var rear_ring := front.rear_ring as Dictionary
	var base_cuts := _setback_cuts(wall_record, north_ring.chains as Array, float(north_ring.setback))
	base_cuts.append_array(_setback_cuts(wall_record, [rear_ring.runs], float(rear_ring.setback)))
	_append_record_roof(roof, collision, record, two_y, base_cuts)
	_append_strip_roof(roof, collision, wall_record, _int_array(chains.north_three_story_runs), three_y, float(vertical.north_wing_inward_depth), tier_clip)
	_append_strip_roof(roof, collision, wall_record, _int_array(chains.central_four_story_runs), four_y, float(vertical.central_inward_depth))
	var se_setback := front.se_setback as Dictionary
	var se_cuts := _setback_cuts(wall_record, [se_setback.runs], float(se_setback.setback))
	var south_runs := _int_array(chains.south_three_story_runs)
	var south_depth := float(vertical.south_wing_inward_depth)
	_append_strip_roof(roof, collision, wall_record, south_runs, three_y, south_depth, tier_clip, se_cuts)
	var continuous := _append_canopy(canopy, soffit, collision, wall_record, _int_array(schedule.central_runs), field_runs, crescent, front)
	# Thin dark mast on the drum roof near its south end, placed and sized by
	# fitted-camera triangulation of the Sep 2025 SW and WSW Street Views and
	# the 18 Jul 2023 rear photograph (see the b1-roof study notes). Solid,
	# non-receiver.
	var mast := _bucket()
	var mast_placed := _append_drum_mast(mast, collision, wall_record, _int_array(chains.central_four_story_runs), float(vertical.central_inward_depth), four_y, front.drum_mast as Dictionary)
	if not mast_placed:
		push_warning("Building 1 hero: the configured drum mast point is not on the drum roof; the mast was omitted.")
	var root := _hero_root("Building1HeroRoof", record, "building_roof")
	var specs: Array[Dictionary] = [
		{"name": "HeroSteppedRoof", "bucket": roof, "material": ROOF_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroEntranceCanopy", "bucket": canopy, "material": PUBLIC_TRIM_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroEntranceCanopySoffit", "bucket": soffit, "material": PUBLIC_WALL_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroDrumMast", "bucket": mast, "material": PUBLIC_FRAME_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
	]
	var metadata := _common_metadata(config, record, "building_roof")
	metadata["reachable_roof_tier_y"] = [two_y, three_y, four_y]
	metadata["canopy_collision_congruent"] = true
	metadata["canopy_continuous_exact_union"] = continuous
	metadata["canopy_horizontal_domain"] = "exact_union_of_accepted_per_run_slabs" if continuous else "accepted_per_run_slabs_fallback"
	metadata["wing_tier_roofs_clipped_to_frozen_footprint"] = not tier_clip.is_empty()
	metadata["central_tier_roof_unchanged"] = true
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


static func _append_exact_base_walls(public_visual: Dictionary, original_visual: Dictionary, collision: Dictionary, record: Dictionary, top_y: float, lowered: Dictionary = {}) -> void:
	for run_index in range(110):
		var frame := _run_frame(record, run_index)
		var start := frame.start as Vector3
		var end := frame.end as Vector3
		var visual := original_visual if run_index in PROTECTED_RUNS else public_visual
		var run_top := float(lowered.get(run_index, top_y))
		_append_vertical_face(visual, start, end, start.y, run_top, frame.normal as Vector3, end.y)
		_append_vertical_face(collision, start, end, start.y, run_top, frame.normal as Vector3, end.y)


static func _append_strip_walls(public_visual: Dictionary, original_visual: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], low_y: float, high_y: float, depth: float, clip: Dictionary = {}, skip_outer: Dictionary = {}, cuts: Array = []) -> void:
	var frames: Array[Dictionary] = []
	for run_index in runs:
		frames.append(_run_frame(record, run_index))
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
		if index == 0:
			var first_normal := -(frame.tangent as Vector3)
			_append_vertical_face(public_visual, inner_start, outer_start, low_y, high_y, first_normal)
			_append_vertical_face(collision, inner_start, outer_start, low_y, high_y, first_normal)
		if index == frames.size() - 1:
			var last_normal := frame.tangent as Vector3
			_append_vertical_face(public_visual, outer_end, inner_end, low_y, high_y, last_normal)
			_append_vertical_face(collision, outer_end, inner_end, low_y, high_y, last_normal)
		if index > 0:
			var previous := frames[index - 1]
			var previous_end_source := previous.end as Vector3
			var previous_inner := Vector3(previous_end_source.x, low_y, previous_end_source.z) - (previous.normal as Vector3) * depth
			var join := inner_start - previous_inner
			if join.length_squared() > 0.000001:
				var join_normal := Vector3(join.z, 0.0, -join.x).normalized()
				_append_partition(original_visual, collision, previous_inner, inner_start, low_y, high_y, join_normal, clip, cuts)


static func _append_strip_roof(visual: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], top_y: float, depth: float, clip: Dictionary = {}, cuts: Array = []) -> void:
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
		_append_roof_piece(visual, collision, [outer_start, outer_end, inner_end, inner_start], top_y, clip, cuts)
		if index > 0:
			var previous := frames[index - 1]
			var join_source := previous.end as Vector3
			var join_outer := Vector3(join_source.x, top_y, join_source.z)
			var previous_inner := join_outer - (previous.normal as Vector3) * depth
			var current_inner := join_outer - normal * depth
			_append_roof_piece(visual, collision, [join_outer, previous_inner, current_inner], top_y, clip, cuts)


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
## rather than opening a roof hole.
static func _append_roof_piece(visual: Dictionary, collision: Dictionary, corners: Array, top_y: float, clip: Dictionary, cuts: Array = []) -> void:
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
		for piece in pieces:
			_append_cut_polygon(visual, collision, piece, top_y, cuts)
		return
	if clip.is_empty():
		_append_roof_corners(visual, collision, corners)
		return
	var origin := clip.origin as Vector3
	var polygon := PackedVector2Array()
	for corner_value in corners:
		var corner := corner_value as Vector3
		polygon.append(Vector2(corner.x - origin.x, corner.z - origin.z))
	if absf(_ring_area(polygon)) < 0.000001:
		return
	var triangles: Array[Vector3] = []
	for piece: PackedVector2Array in Geometry2D.intersect_polygons(polygon, clip.ring as PackedVector2Array):
		var indices := Geometry2D.triangulate_polygon(piece)
		if indices.is_empty():
			_append_roof_corners(visual, collision, corners)
			return
		for index_value in indices:
			var point := piece[index_value]
			triangles.append(Vector3(point.x + origin.x, top_y, point.y + origin.z))
	for offset in range(0, triangles.size(), 3):
		_append_triangle(visual, triangles[offset], triangles[offset + 1], triangles[offset + 2], Vector3.UP)
		_append_triangle(collision, triangles[offset], triangles[offset + 1], triangles[offset + 2], Vector3.UP)


static func _append_roof_corners(visual: Dictionary, collision: Dictionary, corners: Array) -> void:
	if corners.size() == 4:
		_append_quad(visual, corners[0] as Vector3, corners[1] as Vector3, corners[2] as Vector3, corners[3] as Vector3, Vector3.UP)
		_append_quad(collision, corners[0] as Vector3, corners[1] as Vector3, corners[2] as Vector3, corners[3] as Vector3, Vector3.UP)
	else:
		_append_triangle(visual, corners[0] as Vector3, corners[1] as Vector3, corners[2] as Vector3, Vector3.UP)
		_append_triangle(collision, corners[0] as Vector3, corners[1] as Vector3, corners[2] as Vector3, Vector3.UP)


static func _append_record_roof(visual: Dictionary, collision: Dictionary, record: Dictionary, top_y: float, cuts: Array = []) -> void:
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
			_append_cut_polygon(visual, collision, triangle, top_y, cuts)
			continue
		_append_triangle(visual, points[0], points[1], points[2], Vector3.UP)
		_append_triangle(collision, points[0], points[1], points[2], Vector3.UP)


## A horizontal world-XZ polygon minus every cut polygon, triangulated at y.
## Used where a setback storey opens a terrace under an existing roof slab.
static func _append_cut_polygon(visual: Dictionary, collision: Dictionary, polygon: PackedVector2Array, y: float, cuts: Array) -> void:
	var pieces: Array[PackedVector2Array] = [polygon]
	for cut: PackedVector2Array in cuts:
		var kept: Array[PackedVector2Array] = []
		for piece in pieces:
			for remainder: PackedVector2Array in Geometry2D.clip_polygons(piece, cut):
				# Cut bands always cross the footprint outline, so no remainder is a hole.
				if absf(_ring_area(remainder)) > 0.0001:
					kept.append(remainder)
		pieces = kept
	for piece in pieces:
		var triangles := _polygon_triangles(piece)
		if triangles.is_empty():
			push_warning("Building 1 hero: a %.3f m2 roof piece at y %.2f could not be triangulated and was dropped." % [absf(_ring_area(piece)), y])
		for triangle in triangles:
			var a := Vector3(triangle[0].x, y, triangle[0].y)
			var b := Vector3(triangle[1].x, y, triangle[1].y)
			var c := Vector3(triangle[2].x, y, triangle[2].y)
			_append_triangle(visual, a, b, c, Vector3.UP)
			_append_triangle(collision, a, b, c, Vector3.UP)


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
static func _setback_cuts(record: Dictionary, chains: Array, setback: float) -> Array:
	var cuts: Array = []
	for chain_value in chains:
		var chain := _int_array(chain_value as Array)
		var outer := _chain_points(record, chain, 0.0, _chain_length(record, chain))
		var pushed := _offset_path(outer, -0.05)
		var inner := _offset_path(outer, setback)
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


static func _append_projecting_base(base: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], front: Dictionary) -> void:
	var projection := float(front.projecting_base_depth)
	var top_y := float(front.projecting_base_top_y)
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var normal := frame.normal as Vector3
		var start := (frame.start as Vector3) + normal * projection
		var end := (frame.end as Vector3) + normal * projection
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
static func _append_base_rustication(base: Dictionary, record: Dictionary, runs: Array[int], front: Dictionary) -> void:
	var trim := float(front.rustication_end_trim)
	var path := _chain_points(record, runs, trim, _chain_length(record, runs) - trim)
	var tops := front.rustication_course_tops_y as Array
	var joint := float(front.rustication_joint_height)
	var face := float(front.rustication_front)
	var back := float(front.rustication_back)
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
## surrounds, a reeded head band between broad fluted piers with capitals, and
## one reeded sill band riding the canopy. Piers project past the windows so
## the glazing reads recessed; nothing cuts the exact wall or its collision.
static func _append_crescent_bays(buckets: Dictionary, record: Dictionary, runs: Array[int], layout: Dictionary, front: Dictionary) -> void:
	var glass := float(layout.glass)
	var surround := float(layout.surround)
	var pier := float(layout.pier)
	var window_y := front.crescent_window_y as Array
	var style := front.crescent_window_style as Dictionary
	var reed_height := float(front.crescent_head_reed_height)
	var reed_front := float(front.crescent_head_reed_front)
	for center_value in layout.windows as Array:
		var center_m := float(center_value)
		var reach := glass * 0.5 + surround + 0.12
		var frame := _span_frame(record, runs, center_m - reach, center_m + reach)
		var center := center_m - float(frame.mid_m)
		var grid := front.crescent_window_grid as Array
		_append_window_module(buckets, frame, center, glass, float(window_y[0]), float(window_y[1]), int(grid[0]), int(grid[1]), style)
		var head_reach := glass * 0.5 + surround + 0.04
		for bottom_value in front.crescent_head_reed_bottoms_y as Array:
			var bottom := float(bottom_value)
			_append_frame_box(buckets.trim, frame, center - head_reach, center + head_reach, bottom, bottom + reed_height, float(frame.lo) - 0.03, float(frame.hi) + reed_front)
	var pier_y := front.crescent_pier_y as Array
	var capital_y := front.crescent_capital_y as Array
	var overhang := float(front.crescent_capital_overhang)
	for center_value in layout.piers as Array:
		var center_m := float(center_value)
		var frame := _span_frame(record, runs, center_m - pier * 0.5 - 0.1, center_m + pier * 0.5 + 0.1)
		var center := center_m - float(frame.mid_m)
		_append_fluted_pier(buckets.trim, frame, center, pier, float(pier_y[0]), float(pier_y[1]), float(front.crescent_pier_depth), int(front.crescent_pier_reeds), float(front.crescent_pier_reed_width), float(front.crescent_pier_reed_gap), float(front.crescent_pier_reed_front))
		_append_frame_box(buckets.trim, frame, center - pier * 0.5 - overhang, center + pier * 0.5 + overhang, float(capital_y[0]), float(capital_y[1]), float(frame.lo) - 0.03, float(frame.hi) + float(front.crescent_capital_front))
	var path := _chain_points(record, runs, float(front.crescent_band_start_trim_m), _chain_length(record, runs))
	for level_value in front.crescent_sill_band as Array:
		var level := level_value as Array
		_append_path_band(buckets.trim, path, float(level[0]), float(level[1]), float(level[2]), -0.05)


## Three glazed-bronze triple-door groups under the crescent bays the dated WSW
## view shows as dark entrance openings (bays 2, 5 and 8): doors and a
## bronze-barred transom set in a dark reveal, framed by a solid pale portal
## whose jambs reach the ground and whose head sits just under the canopy.
## Bronze relief stays shallow for oblique gameplay rays; nothing is cut from
## the accepted projecting-base plane or its collision.
static func _append_entry_composition(buckets: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], layout: Dictionary, bays: Array, doors_per_group: int, front: Dictionary) -> void:
	var windows := layout.windows as Array
	var base_face := float(front.projecting_base_depth)
	var group_width := float(front.entrance_group_width)
	var half := group_width * 0.5
	var door_height := float(front.entrance_door_height)
	var border := float(front.entrance_reveal_border)
	var bar := float(front.entrance_frame_width)
	var bronze_front := float(front.entrance_frame_front)
	var jamb_width := float(front.entrance_portal_jamb_width)
	var jamb_front := float(front.entrance_portal_front)
	var head_y := front.entrance_portal_head_y as Array
	var head_bottom := float(head_y[0])
	var frames: Array[Dictionary] = []
	var entry_base := -INF
	for bay_value in bays:
		var center_m := float(windows[int(bay_value)])
		var reach := half + border + jamb_width + 0.1
		var frame := _span_frame(record, runs, center_m - reach, center_m + reach)
		frame["center"] = center_m - float(frame.mid_m)
		frames.append(frame)
		entry_base = maxf(entry_base, maxf(float(frame.base_a), float(frame.base_b)))
	# One level transom line for all three groups despite the sloping base.
	var transom_top := entry_base + float(front.entrance_transom_top_above_base)
	for frame in frames:
		var center := float(frame.center)
		var face := base_face + float(frame.hi)
		var back := base_face + float(frame.lo) - 0.02
		var base_y := minf(float(frame.base_a), float(frame.base_b))
		var door_top := base_y + door_height
		var transom_bottom := door_top + bar
		# The reveal front clears the rustication courses so they cannot streak
		# through the dark opening.
		_append_frame_box(buckets.reveal, frame, center - half - border, center + half + border, base_y - border, head_bottom + 0.03, back, face + 0.06)
		_append_frame_box(buckets.glass, frame, center - half, center + half, base_y, door_top, face + 0.05, face + 0.1)
		_append_frame_box(buckets.glass, frame, center - half, center + half, transom_bottom, transom_top, face + 0.05, face + 0.1)
		for leaf in range(doors_per_group + 1):
			var x := center - half + group_width * float(leaf) / float(doors_per_group)
			_append_frame_box(buckets.bronze, frame, x - bar * 0.5, x + bar * 0.5, base_y - bar * 0.5, transom_top + bar * 0.5, face + 0.09, face + bronze_front)
		for rail in [base_y, base_y + 0.95, door_top + bar * 0.5, (transom_bottom + transom_top) * 0.5, transom_top]:
			var y := float(rail)
			_append_frame_box(buckets.bronze, frame, center - half - bar * 0.5, center + half + bar * 0.5, y - bar * 0.5, y + bar * 0.5, face + 0.092, face + bronze_front - 0.004)
		for side in [-1.0, 1.0]:
			var inner := center + float(side) * (half + border)
			var outer := center + float(side) * (half + border + jamb_width)
			for target: Dictionary in [buckets.trim, collision]:
				_append_frame_box(target, frame, minf(inner, outer), maxf(inner, outer), base_y - 0.06, head_bottom + 0.02, back, face + jamb_front)
		var head_reach := half + border + jamb_width + 0.08
		_append_frame_box(buckets.trim, frame, center - head_reach, center + head_reach, head_bottom, float(head_y[1]), back, face + float(front.entrance_portal_head_front))


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
static func _append_wing_facade(buckets: Dictionary, record: Dictionary, runs: Array[int], upper_count: int, lower_count: int, floors: Array, front: Dictionary) -> void:
	var length := _chain_length(record, runs)
	var upper := _evenly_spaced(length, upper_count, float(front.wing_window_margin_m))
	var lower: Array[float] = []
	for index in mini(lower_count, upper.size() - 1):
		lower.append((upper[index] + upper[index + 1]) * 0.5)
	var glass := float(front.wing_window_width)
	# Both wing faces front the forecourt the player crosses on foot.
	var style := (front.wing_window_style as Dictionary).duplicate()
	style["reveal_depth"] = true
	_append_window_grid(buckets, record, runs, upper, glass, [floors[1], floors[2]], style)
	_append_window_grid(buckets, record, runs, lower, glass, [floors[0]], style)


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
	for column in range(columns + 1):
		var x := center - half + glass_width * float(column) / float(columns)
		var width := edge_bar if column == 0 or column == columns else bar
		_append_frame_box(buckets.frame, frame, x - width * 0.5, x + width * 0.5, bottom, top, wall + 0.03, wall + bar_front)
	for row in range(rows + 1):
		var y := lerpf(bottom, top, float(row) / float(rows))
		var height := edge_bar if row == 0 or row == rows else (transom_bar if row == transom_row else bar)
		_append_frame_box(buckets.frame, frame, center - half, center + half, y - height * 0.5, y + height * 0.5, wall + 0.033, wall + bar_front - 0.004)
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


static func _append_fluted_pier(trim: Dictionary, frame: Dictionary, center: float, width: float, bottom: float, top: float, depth: float, reeds: int, reed_width: float, reed_gap: float, reed_front: float) -> void:
	var back := float(frame.lo) - 0.03
	var wall := float(frame.hi)
	_append_frame_box(trim, frame, center - width * 0.5, center + width * 0.5, bottom, top, back, wall + depth)
	var total := float(reeds) * reed_width + float(maxi(reeds - 1, 0)) * reed_gap
	for reed in reeds:
		var x := center - total * 0.5 + reed_width * 0.5 + float(reed) * (reed_width + reed_gap)
		_append_frame_box(trim, frame, x - reed_width * 0.5, x + reed_width * 0.5, bottom + 0.12, top - 0.1, wall + depth - 0.02, wall + reed_front)


## Projecting west-end pavilion on its frozen centre face: paired two-story
## twenty-light windows on a fluted mullion pier, solid fins up to the cornice,
## an abstract winged relief, a pale-portal entry and the stepped crown at the
## dated-reference raised head. Flanks and the recessed corner bay carry the
## wing floor schedule.
static func _append_pavilion(buckets: Dictionary, collision: Dictionary, record: Dictionary, spec: Dictionary, floors: Array, front: Dictionary) -> void:
	var center_runs := _int_array(spec.center_runs)
	var length := _chain_length(record, center_runs)
	var frame := _span_frame(record, center_runs, 0.0, length)
	var wall := float(frame.hi)
	var base_mid := lerpf(float(frame.base_a), float(frame.base_b), 0.5)
	var base_low := minf(float(frame.base_a), float(frame.base_b))
	var tall_y := front.pavilion_tall_window_y as Array
	var tall_bottom := float(tall_y[0])
	var tall_top := float(tall_y[1])
	var offset := float(front.pavilion_tall_window_offset)
	var tall_style := front.pavilion_tall_window_style as Dictionary
	for side in [-1.0, 1.0]:
		_append_window_module(buckets, frame, float(side) * offset, float(front.pavilion_tall_window_width), tall_bottom, tall_top, 2, 10, tall_style)
	_append_fluted_pier(buckets.trim, frame, 0.0, float(front.pavilion_mullion_pier_width), tall_bottom - 0.2, tall_top + 0.3, 0.27, 2, 0.11, 0.1, 0.32)
	# Fins reach chest height on an oblique face, so they are solid pilasters.
	var fin_center := float(front.pavilion_fin_center)
	var fin_width := float(front.pavilion_fin_width)
	var fin_top := float(front.pavilion_fin_top_y)
	for side in [-1.0, 1.0]:
		var x := float(side) * fin_center
		_append_fluted_pier(buckets.trim, frame, x, fin_width, base_low - 0.06, fin_top, 0.24, 2, 0.12, 0.1, 0.29)
		_append_frame_box(collision, frame, x - fin_width * 0.5, x + fin_width * 0.5, base_low - 0.06, fin_top, float(frame.lo) - 0.03, wall + 0.24)
	_append_winged_emblem(buckets.trim, buckets.emblem, frame, front.pavilion_emblem as Dictionary)
	_append_pavilion_entry(buckets, collision, frame, base_mid, base_low, spec.entry as Dictionary)
	# Stepped crown: solid parapet masonry seated into the existing public roof,
	# its sidewalls, tops and lips all in the wall body's collision.
	var crown_bottom := float(front.pavilion_crown_bottom_y)
	var lip := front.pavilion_crown_lip as Dictionary
	for crown_step in _crown_steps(front, length):
		var half := float(crown_step.half_width)
		var top := float(crown_step.top)
		var step_back := wall + float(crown_step.back)
		var step_front := wall + float(crown_step.front)
		for target: Dictionary in [buckets.trim, collision]:
			_append_frame_box(target, frame, -half, half, crown_bottom, top, step_back, step_front)
			_append_frame_box(target, frame, -half - float(lip.overhang), half + float(lip.overhang), top, top + float(lip.height), step_back + float(lip.back_inset), step_front + float(lip.front))
	var style := front.wing_window_style as Dictionary
	for flank_value in spec.flank_runs as Array:
		var flank := _int_array(flank_value as Array)
		_append_window_grid(buckets, record, flank, [_chain_length(record, flank) * 0.5], float(front.flank_window_width), floors, style)
	var corner := _int_array(spec.corner_runs)
	var corner_length := _chain_length(record, corner)
	_append_window_grid(buckets, record, corner, [corner_length * 0.25, corner_length * 0.75], float(front.corner_bay_window_width), floors, style)


## Recessed pavilion entry: bronze leaves and a three-light transom in a dark
## reveal behind solid pale portal jambs and a projecting hood. Instance widths
## follow the dated views: a narrower north door, a wider south porch. Heights
## follow the face's mid base; bottoms seat below its lowest source bottom so
## the downhill jamb still meets the sloping ground.
static func _append_pavilion_entry(buckets: Dictionary, collision: Dictionary, frame: Dictionary, base_y: float, ground_y: float, entry: Dictionary) -> void:
	var wall := float(frame.hi)
	var back := float(frame.lo) - 0.03
	var recess := float(entry.recess_half_width)
	var door := float(entry.door_half_width)
	var top := base_y + float(entry.height)
	var transom := top - float(entry.transom_height)
	var jamb := float(entry.jamb_width)
	_append_frame_box(buckets.reveal, frame, -recess, recess, ground_y - 0.1, top, back, wall + 0.03)
	_append_frame_box(buckets.bronze, frame, -door, door, ground_y - 0.12, transom - 0.04, wall + 0.02, wall + 0.06)
	_append_frame_box(buckets.glass, frame, -door, door, transom + 0.04, top - 0.06, wall + 0.02, wall + 0.05)
	_append_frame_box(buckets.frame, frame, -door - 0.06, door + 0.06, transom - 0.04, transom + 0.04, wall + 0.03, wall + 0.09)
	_append_frame_box(buckets.frame, frame, -0.04, 0.04, ground_y - 0.12, transom, wall + 0.05, wall + 0.1)
	for mullion in [-door / 3.0, door / 3.0]:
		_append_frame_box(buckets.frame, frame, float(mullion) - 0.035, float(mullion) + 0.035, transom, top - 0.06, wall + 0.03, wall + 0.08)
	for side in [-1.0, 1.0]:
		var inner := float(side) * recess
		var outer := float(side) * (recess + jamb)
		for target: Dictionary in [buckets.trim, collision]:
			_append_frame_box(target, frame, minf(inner, outer), maxf(inner, outer), ground_y - 0.08, top + 0.06, back, wall + float(entry.jamb_front))
	var hood_reach := recess + jamb + float(entry.hood_overhang)
	_append_frame_box(buckets.trim, frame, -hood_reach, hood_reach, top, top + float(entry.hood_height), back, wall + float(entry.hood_front))


## Winged aviation roundel after the dated Sep 2025 NW view: a cream disc and
## raised boss inside a blue enamel ring, between two solid blue tapered wing
## fields. A rights-safe simplified proxy for the documented airplane reliefs,
## not a copied emblem; no lettering. Visual only, above the fins' chest-height
## collision.
static func _append_winged_emblem(trim: Dictionary, enamel: Dictionary, frame: Dictionary, emblem: Dictionary) -> void:
	var wall := float(frame.hi)
	var back := float(frame.lo) - 0.03
	var center_y := float(emblem.y)
	var radius := float(emblem.radius)
	_append_frame_disc(enamel, frame, center_y, float(emblem.ring_radius), back, wall + float(emblem.ring_front), 32)
	_append_frame_disc(trim, frame, center_y, radius, back, wall + float(emblem.disc_front), 32)
	_append_frame_disc(trim, frame, center_y, radius * 0.55, wall + float(emblem.disc_front) - 0.03, wall + float(emblem.boss_front), 24)
	var inner := float(emblem.wing_inner)
	var step := float(emblem.wing_step)
	var outer := float(emblem.wing_outer)
	var inner_half := float(emblem.wing_inner_height) * 0.5
	var outer_half := float(emblem.wing_outer_height) * 0.5
	var wing_front := wall + float(emblem.wing_front)
	for side in [-1.0, 1.0]:
		var a := float(side) * inner
		var b := float(side) * step
		var c := float(side) * outer
		_append_frame_box(enamel, frame, minf(a, b), maxf(a, b), center_y - inner_half, center_y + inner_half, back, wing_front)
		_append_frame_box(enamel, frame, minf(b, c), maxf(b, c), center_y - outer_half, center_y + outer_half, back, wing_front)


static func _append_frame_disc(bucket: Dictionary, frame: Dictionary, center_y: float, radius: float, back: float, front_depth: float, segments: int) -> void:
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	var anchor := frame.anchor as Vector3
	var origin := Vector3(anchor.x, center_y, anchor.z)
	var face_center := origin + normal * front_depth
	for index in segments:
		var first_angle := TAU * float(index) / float(segments)
		var second_angle := TAU * float(index + 1) / float(segments)
		var first := tangent * (cos(first_angle) * radius) + Vector3.UP * (sin(first_angle) * radius)
		var second := tangent * (cos(second_angle) * radius) + Vector3.UP * (sin(second_angle) * radius)
		_append_triangle(bucket, face_center, origin + first + normal * front_depth, origin + second + normal * front_depth, normal)
		_append_quad(bucket, origin + first + normal * back, origin + second + normal * back, origin + second + normal * front_depth, origin + first + normal * front_depth, (first + second).normalized())


static func _crown_steps(front: Dictionary, face_length: float) -> Array:
	var shoulder := front.pavilion_crown_shoulder as Dictionary
	var steps: Array = [{
		"half_width": face_length * 0.5 - float(shoulder.inset),
		"top": float(shoulder.top),
		"back": float(shoulder.back),
		"front": float(shoulder.front),
	}]
	steps.append_array(front.pavilion_crown_steps as Array)
	return steps


static func _crown_rise(front: Dictionary, roof_y: float) -> float:
	var highest := -INF
	for crown_step in _crown_steps(front, 0.0):
		highest = maxf(highest, float(crown_step.top))
	return highest + float((front.pavilion_crown_lip as Dictionary).height) - roof_y


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


## Plinth gap at a pavilion entry, ending inside its solid portal jambs.
static func _pavilion_door_gap(record: Dictionary, chain: Array[int], spec: Dictionary) -> Vector2:
	var center_runs := _int_array(spec.center_runs)
	var entry := spec.entry as Dictionary
	var center := _chain_start_of(record, chain, center_runs[0]) + _chain_length(record, center_runs) * 0.5
	var half := float(entry.recess_half_width) + float(entry.jamb_width) * 0.5
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


## Cornice courses on an exact wall path. The top course stands above the
## tier roof, so every course also closes its inner face: without it the lip
## reads as a see-through slot from the roof. Visual only.
static func _append_cornice(trim: Dictionary, path: Dictionary, profile: Array, back: float) -> void:
	for level_value in profile:
		var level := level_value as Array
		_append_path_band(trim, path, float(level[0]), float(level[1]), float(level[2]), back, false, false, true)


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


## The accepted canopy footprint is the union of one slab per central run. A
## single closed prism over that exact union replaces the overlapping boxes, so
## no duplicate coplanar faces remain at kinks while the horizontal domain,
## source ownership and roof role stay unchanged. If the native union is not one
## simple polygon, the accepted per-run slabs are emitted unchanged instead.
static func _append_canopy(visual: Dictionary, soffit: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], rim_runs: Array[int], layout: Dictionary, front: Dictionary) -> bool:
	var center_y := float(front.canopy_center_y)
	var height := float(front.canopy_primary_height)
	var bottom_y := center_y - height * 0.5
	var union := _canopy_union(record, runs, front)
	if union.is_empty():
		_append_canopy_slabs(visual, soffit, collision, record, runs, front)
		return false
	_append_canopy_prism(visual, soffit, collision, union, bottom_y, center_y + height * 0.5)
	# Deeper leading fascia inside the same footprint along the smooth crescent
	# field; visual only, like the accepted leading edge it replaces.
	var rim_y := front.canopy_rim_y as Array
	var rim_path := _chain_points(record, rim_runs, 0.0, _chain_length(record, rim_runs))
	_append_path_band(visual, rim_path, float(rim_y[0]), float(rim_y[1]), float(front.canopy_rim_front), float(front.canopy_rim_back), false, false, true)
	# Three horizontal reeds on the fascia (2008 crescent window detail).
	var reeds := front.canopy_rim_reeds as Dictionary
	for reed_value in reeds.y as Array:
		var reed := reed_value as Array
		_append_path_band(visual, rim_path, float(reed[0]), float(reed[1]), float(reeds.front), float(reeds.back))
	# Coffered soffit: transverse ribs under each crescent pier and one spine,
	# visual only beneath the closed slab and seated 0.01 m into it.
	var ribs := front.canopy_soffit_ribs as Dictionary
	var rib_half := float(ribs.width) * 0.5
	for center_value in layout.piers as Array:
		var center_m := float(center_value)
		var frame := _span_frame(record, rim_runs, center_m - rib_half - 0.1, center_m + rib_half + 0.1)
		var center := center_m - float(frame.mid_m)
		_append_frame_box(soffit, frame, center - rib_half, center + rib_half, float(ribs.bottom_y), bottom_y + 0.01, float(ribs.back), float(ribs.front))
	_append_path_band(soffit, rim_path, float(ribs.spine_bottom_y), bottom_y + 0.01, float(ribs.spine_front), float(ribs.spine_back), false, false, true)
	return true


static func _canopy_union(record: Dictionary, runs: Array[int], front: Dictionary) -> Dictionary:
	# Local coordinates keep the native polygon union and triangulation well
	# conditioned; the slab rectangles are exactly the accepted per-run boxes.
	var origin := _run_frame(record, runs[0]).start as Vector3
	var center := float(front.canopy_primary_center_projection)
	var half_depth := float(front.canopy_primary_depth) * 0.5
	var extension := float(front.canopy_run_extension)
	var merged := PackedVector2Array()
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var tangent := frame.tangent as Vector3
		var normal := frame.normal as Vector3
		var start := (frame.start as Vector3) - tangent * extension
		var end := (frame.end as Vector3) + tangent * extension
		var rectangle := PackedVector2Array()
		for corner: Vector3 in [start + normal * (center - half_depth), end + normal * (center - half_depth), end + normal * (center + half_depth), start + normal * (center + half_depth)]:
			rectangle.append(Vector2(corner.x - origin.x, corner.z - origin.z))
		if merged.is_empty():
			merged = rectangle
			continue
		var union := Geometry2D.merge_polygons(merged, rectangle)
		if union.size() != 1:
			return {}
		merged = union[0]
	merged = _simplified_ring(merged)
	if merged.size() < 3:
		return {}
	var triangles := Geometry2D.triangulate_polygon(merged)
	if triangles.is_empty():
		return {}
	return {"polygon": merged, "indices": triangles, "origin": origin}


## Drop duplicate and truly collinear vertices (sine below 5e-4) that the native
## union leaves where neighbouring accepted slabs share an edge line.
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


static func _append_canopy_prism(visual: Dictionary, soffit: Dictionary, collision: Dictionary, union: Dictionary, bottom_y: float, top_y: float) -> void:
	var polygon := union.polygon as PackedVector2Array
	var indices := union.indices as PackedInt32Array
	var origin := union.origin as Vector3
	var points: Array[Vector3] = []
	for point in polygon:
		points.append(Vector3(point.x + origin.x, 0.0, point.y + origin.z))
	for offset in range(0, indices.size(), 3):
		var a := points[indices[offset]]
		var b := points[indices[offset + 1]]
		var c := points[indices[offset + 2]]
		for target: Dictionary in [visual, collision]:
			_append_triangle(target, _lifted(a, top_y), _lifted(b, top_y), _lifted(c, top_y), Vector3.UP)
		for target: Dictionary in [soffit, collision]:
			_append_triangle(target, _lifted(a, bottom_y), _lifted(b, bottom_y), _lifted(c, bottom_y), Vector3.DOWN)
	var outward_sign := 1.0 if _ring_area(polygon) > 0.0 else -1.0
	for index in points.size():
		var a := points[index]
		var b := points[(index + 1) % points.size()]
		var outward := Vector3(b.z - a.z, 0.0, a.x - b.x).normalized() * outward_sign
		for target: Dictionary in [visual, collision]:
			_append_quad(target, _lifted(a, bottom_y), _lifted(b, bottom_y), _lifted(b, top_y), _lifted(a, top_y), outward)


## Accepted per-run canopy slabs, kept as the exact fallback representation.
static func _append_canopy_slabs(visual: Dictionary, underside: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], front: Dictionary) -> void:
	var center_y := float(front.canopy_center_y)
	var extension := float(front.canopy_run_extension)
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var wall_center := (frame.start as Vector3).lerp(frame.end as Vector3, 0.5)
		var normal := frame.normal as Vector3
		var tangent := frame.tangent as Vector3
		var center := wall_center + normal * float(front.canopy_primary_center_projection)
		center.y = center_y
		var width := float(frame.length_m) + extension * 2.0
		_append_box(visual, center, tangent, normal, width, float(front.canopy_primary_height), float(front.canopy_primary_depth))
		_append_box(collision, center, tangent, normal, width, float(front.canopy_primary_height), float(front.canopy_primary_depth))
		var leading_edge := wall_center + normal * float(front.canopy_leading_edge_center_projection)
		leading_edge.y = center_y
		_append_box(visual, leading_edge, tangent, normal, width + 0.04, float(front.canopy_leading_edge_height), float(front.canopy_leading_edge_depth))
		var underside_center := wall_center + normal * float(front.canopy_underside_center_projection)
		underside_center.y = center_y - 0.25
		_append_box(underside, underside_center, tangent, normal, width - 0.04, float(front.canopy_underside_height), float(front.canopy_underside_depth))


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
	return str(config.get("schema_version", "")) == "ti.building-1-public-front-believability/4" \
		and str(config.get("pass_id", "")) == "building-1-public-family-opus-2026-10-16" \
		and str(target.get("building_source_key", "")) == BUILDING_SOURCE_KEY \
		and str(target.get("wall_object_key", "")) == BUILDING_WALL_KEY \
		and str(target.get("roof_object_key", "")) == BUILDING_ROOF_KEY \
		and _int_array(target.get("public_front_chain_runs", []) as Array) == expected_runs \
		and is_equal_approx(float(geometry.get("projecting_base_depth", -1.0)), 0.28) \
		and is_equal_approx(float(geometry.get("projecting_base_top_y", -1.0)), 12.45) \
		and is_equal_approx(float(geometry.get("canopy_center_y", -1.0)), 12.6) \
		and is_equal_approx(float(geometry.get("canopy_primary_center_projection", -1.0)), 1.08) \
		and is_equal_approx(float(geometry.get("canopy_primary_depth", -1.0)), 2.25) \
		and is_equal_approx(float(geometry.get("canopy_primary_height", -1.0)), 0.42) \
		and is_equal_approx(float(geometry.get("canopy_run_extension", -1.0)), 0.06) \
		and float(geometry.get("canopy_rim_front", 9.0)) < 1.08 + 2.25 * 0.5 \
		and float(geometry.get("crescent_pier_depth", 0.0)) > float(crescent_style.get("jamb_front", 1.0)) \
		and float(geometry.get("crescent_pier_reed_front", 0.0)) > float(geometry.get("crescent_pier_depth", 1.0)) \
		and int(geometry.get("crescent_pier_reeds", 0)) > 0 \
		and (geometry.get("crescent_cornice", []) as Array).size() == 3 \
		and (geometry.get("wing_cornice", []) as Array).size() == 3 \
		and (geometry.get("window_floors", []) as Array).size() == 3 \
		and (geometry.get("entrance_portal_head_y", []) as Array).size() == 2 \
		and float(geometry.get("entrance_portal_front", 0.0)) > float(geometry.get("entrance_frame_front", 1.0)) \
		and geometry.get("canopy_soffit_ribs", null) is Dictionary \
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
