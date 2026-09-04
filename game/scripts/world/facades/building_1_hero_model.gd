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
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1
const VISUAL_REVIEW_STATUS := "pending_independent_original_detail_review"

const WALL_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres")
const TRIM_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_light_trim.tres")
const GLASS_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres")
const BRONZE_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_bronze.tres")
const ROOF_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_roof_metal.tres")
const BASE_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_projecting_base_stone.tres")
const REVEAL_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_reveal_shadow.tres")
const CANOPY_UNDERSIDE_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_canopy_underside.tres")


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in TARGET_KEYS


static func build_record(record: Dictionary) -> Dictionary:
	var config := _json(CONFIG_PATH)
	var bar_config := _json(BAR_CONFIG_PATH)
	if not _config_valid(config) or not _bar_config_valid(bar_config) or not _record_valid(record):
		return _failure("building_1_hero_source_contract", "Building 1 hero source identity, geometry, or configuration drifted.", record)
	match str(record.object_key):
		BUILDING_WALL_KEY:
			return _build_building_wall(record, config, bar_config)
		BUILDING_ROOF_KEY:
			var wall_record := _record_from_chunk(MAIN_CHUNK_PATH, BUILDING_WALL_KEY)
			if not _record_valid(wall_record):
				return _failure("building_1_hero_wall_source", "Building 1 wall source could not be resolved for stepped roofs.", record)
			return _build_building_roof(record, wall_record, config, bar_config)
		TOWER_WALL_KEY:
			return _build_tower_wall(record, config)
		TOWER_ROOF_KEY:
			return _build_tower_roof(record, config)
	return _failure("building_1_hero_target", "Unexpected Building 1 hero target.", record)


static func _build_building_wall(record: Dictionary, config: Dictionary, bar_config: Dictionary) -> Dictionary:
	var vertical := config.vertical_production_inference_m as Dictionary
	var chains := config.massing_chains as Dictionary
	var schedule := config.facade_schedule as Dictionary
	var front := bar_config.geometry_production_inference_m as Dictionary
	var two_y := float(vertical.two_story_roof_y)
	var three_y := float(vertical.three_story_roof_y)
	var four_y := float(vertical.four_story_roof_y)
	var wall := _bucket()
	var base := _bucket()
	var trim := _bucket()
	var glass := _bucket()
	var reveal := _bucket()
	var bronze := _bucket()
	var collision := _bucket()

	_append_exact_base_walls(wall, collision, record, two_y)
	_append_strip_walls(wall, collision, record, _int_array(chains.north_three_story_runs), two_y, three_y, float(vertical.north_wing_inward_depth))
	_append_strip_walls(wall, collision, record, _int_array(chains.central_four_story_runs), two_y, four_y, float(vertical.central_inward_depth))
	_append_strip_walls(wall, collision, record, _int_array(chains.south_three_story_runs), two_y, three_y, float(vertical.south_wing_inward_depth))

	var central_runs := _int_array(schedule.central_runs)
	_append_projecting_base(base, trim, collision, record, central_runs, front)
	_append_public_front_window_schedule(glass, reveal, trim, record, central_runs, int(schedule.central_window_count), front)
	_append_public_front_pilasters(trim, record, central_runs, int(schedule.central_window_count), front)
	_append_entry_groups(glass, reveal, bronze, record, central_runs, int(schedule.entrance_groups), int(schedule.doors_per_entrance_group), front)

	var north_window_runs := _int_array(schedule.north_wing_window_runs)
	var south_window_runs := _int_array(schedule.south_wing_window_runs)
	for wing_runs: Array[int] in [north_window_runs, south_window_runs]:
		_append_window_schedule(glass, trim, record, wing_runs, int(schedule.upper_windows_per_wing), 2.2, 2.35, 2.8, 2, 5, 0.13, 16.9)
		_append_window_schedule(glass, trim, record, wing_runs, int(schedule.lower_windows_per_wing), 2.5, 2.05, 2.45, 2, 3, 0.23, 10.35)
		_append_chain_band(trim, record, wing_runs, 19.55, 0.22, 0.16)

	_append_end_composition(glass, trim, record, int(schedule.north_end_run), front)
	_append_end_composition(glass, trim, record, int(schedule.south_end_run), front)

	var root := _hero_root("Building1HeroWall", record, "building_wall")
	var specs: Array[Dictionary] = [
		{"name": "HeroIvory", "bucket": wall, "material": WALL_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroProjectingBase", "bucket": base, "material": BASE_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroPublicFrontReveals", "bucket": reveal, "material": REVEAL_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroGlass", "bucket": glass, "material": GLASS_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroTrim", "bucket": trim, "material": TRIM_MATERIAL, "layers": RENDER_BUILDING_WALL},
		{"name": "HeroBronze", "bucket": bronze, "material": BRONZE_MATERIAL, "layers": RENDER_BUILDING_WALL},
	]
	var metadata := _common_metadata(config, record, "building_wall")
	metadata.merge({
		"exact_outer_and_inner_run_count": 110,
		"central_window_count": int(schedule.central_window_count),
		"central_lights_per_window": int(schedule.central_lights_per_window),
		"upper_windows_per_wing": int(schedule.upper_windows_per_wing),
		"upper_lights_per_window": int(schedule.upper_lights_per_window),
		"lower_windows_per_wing": int(schedule.lower_windows_per_wing),
		"entrance_groups": int(schedule.entrance_groups),
		"doors_per_entrance_group": int(schedule.doors_per_entrance_group),
		"end_composition_count": 2,
		"relief_proxy_count": 0,
		"neutral_end_relief_location_field_count": 2,
		"misleading_cruciform_proxy_count": 0,
		"public_front_believability_pass": true,
		"public_front_believability_config_path": BAR_CONFIG_PATH,
		"public_front_believability_review_status": "pending_independent_bar_raiser_re_review_not_self_accepted",
		"recognition_status": "accepted_before_quality_hardening_and_preserved",
		"public_front_depth_created_by_geometry": true,
		"scalar_material_value_separation": true,
		"image_texture_used_for_pass": false,
		"genai_texture_candidate_consumed": false,
		"central_recessed_glazing_field_count": int(schedule.central_window_count),
		"central_pilaster_count": int(front.pilaster_count),
		"fluting_ribs_per_pilaster": int(front.pilaster_flutes_per_pilaster),
		"public_front_depth_bands_m": [
			float(front.window_reveal_center_projection) + float(front.window_reveal_depth) * 0.5,
			float(front.window_frame_center_projection) + float(front.window_frame_depth) * 0.5,
			float(front.pilaster_flute_center_projection) + float(front.pilaster_flute_depth) * 0.5,
		],
		"horizontal_source_geometry_changed": false,
		"vertical_massing_changed": false,
		"collision_geometry_changed": false,
		"spray_ownership_changed": false,
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
	var canopy_underside := _bucket()
	var collision := _bucket()
	_append_record_roof(roof, collision, record, two_y)
	_append_strip_roof(roof, collision, wall_record, _int_array(chains.north_three_story_runs), three_y, float(vertical.north_wing_inward_depth))
	_append_strip_roof(roof, collision, wall_record, _int_array(chains.central_four_story_runs), four_y, float(vertical.central_inward_depth))
	_append_strip_roof(roof, collision, wall_record, _int_array(chains.south_three_story_runs), three_y, float(vertical.south_wing_inward_depth))
	_append_canopy(canopy, canopy_underside, collision, wall_record, _int_array(schedule.central_runs), front)
	var root := _hero_root("Building1HeroRoof", record, "building_roof")
	var specs: Array[Dictionary] = [
		{"name": "HeroSteppedRoof", "bucket": roof, "material": ROOF_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroEntranceCanopy", "bucket": canopy, "material": WALL_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "HeroEntranceCanopyUnderside", "bucket": canopy_underside, "material": CANOPY_UNDERSIDE_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
	]
	var metadata := _common_metadata(config, record, "building_roof")
	metadata["reachable_roof_tier_y"] = [two_y, three_y, four_y]
	metadata["canopy_collision_congruent"] = true
	metadata["canopy_primary_slab_collision_congruent"] = true
	metadata["canopy_visual_depth_accents_noncolliding"] = true
	metadata["public_front_believability_pass"] = true
	metadata["public_front_believability_config_path"] = BAR_CONFIG_PATH
	metadata["public_front_believability_review_status"] = "pending_independent_bar_raiser_re_review_not_self_accepted"
	metadata["recognition_status"] = "accepted_before_quality_hardening_and_preserved"
	metadata["collision_geometry_changed"] = false
	metadata["roof_traversal_changed"] = false
	metadata["genai_texture_candidate_consumed"] = false
	return _finish_record(root, specs, collision, false, metadata)


static func _build_tower_wall(record: Dictionary, config: Dictionary) -> Dictionary:
	var vertical := config.vertical_production_inference_m as Dictionary
	var platform_bottom := float(vertical.four_story_roof_y)
	var platform_top := float(vertical.tower_platform_top_y)
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
		var scaled_start := _scaled_plan_point(source_start, center, platform_scale, platform_bottom)
		var scaled_end := _scaled_plan_point(source_end, center, platform_scale, platform_bottom)
		var platform_normal := _outward_normal(scaled_start, scaled_end, frame.normal as Vector3)
		_append_vertical_face(ivory, scaled_start, scaled_end, platform_bottom, platform_top, platform_normal)
		_append_vertical_face(collision, scaled_start, scaled_end, platform_bottom, platform_top, platform_normal)
		var exact_start := Vector3(source_start.x, glass_base, source_start.z)
		var exact_end := Vector3(source_end.x, glass_base, source_end.z)
		_append_vertical_face(glass, exact_start, exact_end, glass_base, glass_top, frame.normal as Vector3)
		_append_vertical_face(collision, exact_start, exact_end, glass_base, glass_top, frame.normal as Vector3)
		_append_wall_bar(trim, exact_start.lerp(exact_end, 0.5), frame.tangent as Vector3, frame.normal as Vector3, glass_base + 0.12, float(frame.length_m), 0.12, 0.12)
		_append_wall_bar(trim, exact_start.lerp(exact_end, 0.5), frame.tangent as Vector3, frame.normal as Vector3, glass_top - 0.12, float(frame.length_m), 0.12, 0.12)
		for mullion_fraction in [0.333333, 0.666667]:
			var mullion_anchor := exact_start.lerp(exact_end, float(mullion_fraction))
			_append_wall_bar(trim, mullion_anchor, frame.tangent as Vector3, frame.normal as Vector3, (glass_base + glass_top) * 0.5, 0.12, glass_top - glass_base, 0.13)
		var post_anchor := scaled_start
		_append_box(ivory, Vector3(post_anchor.x, platform_top + 0.55, post_anchor.z), frame.tangent as Vector3, frame.normal as Vector3, 0.14, 1.1, 0.14)
		var rail_center := scaled_start.lerp(scaled_end, 0.5)
		rail_center.y = platform_top + 0.9
		_append_box(ivory, rail_center, frame.tangent as Vector3, frame.normal as Vector3, float(frame.length_m) * platform_scale, 0.10, 0.12)
	var root := _hero_root("Building1ObservationTowerHeroWall", record, "tower_wall")
	var specs: Array[Dictionary] = [
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
	}, true)
	return _finish_record(root, specs, collision, true, metadata)


static func _build_tower_roof(record: Dictionary, config: Dictionary) -> Dictionary:
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
	var collision := _bucket()
	_append_scaled_record_roof(roof, collision, record, center, scale, platform_top)
	var apex := Vector3(center.x, peak_y, center.z)
	for index in source_points.size():
		var first_source := source_points[index]
		var second_source := source_points[(index + 1) % source_points.size()]
		var first := Vector3(first_source.x, glass_top, first_source.z)
		var second := Vector3(second_source.x, glass_top, second_source.z)
		var normal := (second - first).cross(apex - first).normalized()
		if normal.y < 0.0:
			normal = -normal
		_append_triangle(roof, first, second, apex, normal)
		_append_triangle(collision, first, second, apex, normal)
	var root := _hero_root("Building1ObservationTowerHeroRoof", record, "tower_roof")
	var specs: Array[Dictionary] = [
		{"name": "HeroTowerPlatformAndPyramidalRoof", "bucket": roof, "material": ROOF_MATERIAL, "layers": RENDER_WORLD_VISIBLE},
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


static func _append_exact_base_walls(visual: Dictionary, collision: Dictionary, record: Dictionary, top_y: float) -> void:
	for run_index in range(110):
		var frame := _run_frame(record, run_index)
		var start := frame.start as Vector3
		var end := frame.end as Vector3
		_append_vertical_face(visual, start, end, start.y, top_y, frame.normal as Vector3, end.y)
		_append_vertical_face(collision, start, end, start.y, top_y, frame.normal as Vector3, end.y)


static func _append_strip_walls(visual: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], low_y: float, high_y: float, depth: float) -> void:
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
		_append_vertical_face(visual, outer_start, outer_end, low_y, high_y, normal)
		_append_vertical_face(collision, outer_start, outer_end, low_y, high_y, normal)
		_append_vertical_face(visual, inner_end, inner_start, low_y, high_y, -normal)
		_append_vertical_face(collision, inner_end, inner_start, low_y, high_y, -normal)
		if index == 0:
			var first_normal := -(frame.tangent as Vector3)
			_append_vertical_face(visual, inner_start, outer_start, low_y, high_y, first_normal)
			_append_vertical_face(collision, inner_start, outer_start, low_y, high_y, first_normal)
		if index == frames.size() - 1:
			var last_normal := frame.tangent as Vector3
			_append_vertical_face(visual, outer_end, inner_end, low_y, high_y, last_normal)
			_append_vertical_face(collision, outer_end, inner_end, low_y, high_y, last_normal)
		if index > 0:
			var previous := frames[index - 1]
			var previous_end_source := previous.end as Vector3
			var previous_inner := Vector3(previous_end_source.x, low_y, previous_end_source.z) - (previous.normal as Vector3) * depth
			var join := inner_start - previous_inner
			if join.length_squared() > 0.000001:
				var join_normal := Vector3(join.z, 0.0, -join.x).normalized()
				_append_vertical_face(visual, previous_inner, inner_start, low_y, high_y, join_normal)
				_append_vertical_face(collision, previous_inner, inner_start, low_y, high_y, join_normal)


static func _append_strip_roof(visual: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], top_y: float, depth: float) -> void:
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
		_append_quad(visual, outer_start, outer_end, inner_end, inner_start, Vector3.UP)
		_append_quad(collision, outer_start, outer_end, inner_end, inner_start, Vector3.UP)
		if index > 0:
			var previous := frames[index - 1]
			var join_source := previous.end as Vector3
			var join_outer := Vector3(join_source.x, top_y, join_source.z)
			var previous_inner := join_outer - (previous.normal as Vector3) * depth
			var current_inner := join_outer - normal * depth
			_append_triangle(visual, join_outer, previous_inner, current_inner, Vector3.UP)
			_append_triangle(collision, join_outer, previous_inner, current_inner, Vector3.UP)


static func _append_record_roof(visual: Dictionary, collision: Dictionary, record: Dictionary, top_y: float) -> void:
	var values := record.vertices as Array
	var indices := record.indices as Array
	for offset in range(0, indices.size(), 3):
		var points: Array[Vector3] = []
		for index_offset in 3:
			var vertex_index := int(indices[offset + index_offset]) * 3
			points.append(Vector3(float(values[vertex_index]), top_y, float(values[vertex_index + 2])))
		_append_triangle(visual, points[0], points[1], points[2], Vector3.UP)
		_append_triangle(collision, points[0], points[1], points[2], Vector3.UP)


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


static func _append_projecting_base(base: Dictionary, trim: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], front: Dictionary) -> void:
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
		for groove_y in [7.7, 9.65, 11.6]:
			var center := start.lerp(end, 0.5)
			center.y = groove_y
			_append_wall_bar(trim, center, frame.tangent as Vector3, normal, groove_y, float(frame.length_m) + 0.08, 0.10, 0.14)
		var cap_center := (frame.start as Vector3).lerp(frame.end as Vector3, 0.5) + normal * float(front.projecting_base_cap_center_projection)
		cap_center.y = float(front.projecting_base_cap_center_y)
		_append_box(
			base,
			cap_center,
			frame.tangent as Vector3,
			normal,
			float(frame.length_m) + 0.08,
			float(front.projecting_base_cap_height),
			float(front.projecting_base_cap_depth)
		)


static func _append_public_front_window_schedule(glass: Dictionary, reveal: Dictionary, trim: Dictionary, record: Dictionary, runs: Array[int], count: int, front: Dictionary) -> void:
	var length := _chain_length(record, runs)
	var margin := float(front.central_window_margin_along_chain)
	for index in count:
		var chain_m := margin if count == 1 else lerpf(margin, length - margin, float(index) / float(count - 1))
		var frame := _chain_frame(record, runs, chain_m)
		_append_public_front_window(glass, reveal, trim, frame, front)


static func _append_public_front_window(glass: Dictionary, reveal: Dictionary, trim: Dictionary, frame: Dictionary, front: Dictionary) -> void:
	var anchor := frame.wall_anchor as Vector3
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	var width := float(front.central_window_width)
	var height := float(front.central_window_height)
	var border := float(front.window_reveal_border)
	anchor.y = 19.55
	_append_box(
		reveal,
		anchor + normal * float(front.window_reveal_center_projection),
		tangent,
		normal,
		width + border * 2.0,
		height + border * 2.0,
		float(front.window_reveal_depth)
	)
	_append_box(
		glass,
		anchor + normal * float(front.window_glass_center_projection),
		tangent,
		normal,
		width,
		height,
		float(front.window_glass_depth)
	)
	var columns := 3
	var rows := 6
	for column in range(columns + 1):
		var lateral := -width * 0.5 + width * float(column) / float(columns)
		var bar_width := float(front.window_outer_frame_width) if column in [0, columns] else float(front.window_internal_frame_width)
		_append_box(
			trim,
			anchor + tangent * lateral + normal * float(front.window_frame_center_projection),
			tangent,
			normal,
			bar_width,
			height + float(front.window_outer_frame_width),
			float(front.window_frame_depth)
		)
	for row in range(rows + 1):
		var vertical := -height * 0.5 + height * float(row) / float(rows)
		var bar_height := float(front.window_outer_frame_width) if row in [0, rows] else float(front.window_internal_frame_width)
		_append_box(
			trim,
			anchor + Vector3.UP * vertical + normal * float(front.window_frame_center_projection),
			tangent,
			normal,
			width + float(front.window_outer_frame_width),
			bar_height,
			float(front.window_frame_depth)
		)


static func _append_public_front_pilasters(trim: Dictionary, record: Dictionary, runs: Array[int], window_count: int, front: Dictionary) -> void:
	var chain_length := _chain_length(record, runs)
	var margin := float(front.central_window_margin_along_chain)
	var spacing := (chain_length - margin * 2.0) / float(window_count - 1)
	var count := int(front.pilaster_count)
	for index in count:
		var chain_m := margin + (float(index) - 0.5) * spacing
		var frame := _chain_frame(record, runs, chain_m)
		var anchor := frame.wall_anchor as Vector3
		var tangent := frame.tangent as Vector3
		var normal := frame.normal as Vector3
		anchor.y = float(front.pilaster_center_y)
		_append_box(
			trim,
			anchor + normal * float(front.pilaster_center_projection),
			tangent,
			normal,
			float(front.pilaster_width),
			float(front.pilaster_height),
			float(front.pilaster_depth)
		)
		var rib_offset := float(front.pilaster_width) * 0.27
		for sign_value in [-1.0, 1.0]:
			_append_box(
				trim,
				anchor + tangent * rib_offset * float(sign_value) + normal * float(front.pilaster_flute_center_projection),
				tangent,
				normal,
				float(front.pilaster_flute_width),
				float(front.pilaster_height),
				float(front.pilaster_flute_depth)
			)


static func _append_window_schedule(glass: Dictionary, trim: Dictionary, record: Dictionary, runs: Array[int], count: int, margin_m: float, width: float, height: float, columns: int, rows: int, projection: float, center_y: float = 19.55) -> void:
	var length := _chain_length(record, runs)
	for index in count:
		var chain_m := margin_m if count == 1 else lerpf(margin_m, length - margin_m, float(index) / float(count - 1))
		var frame := _chain_frame(record, runs, chain_m)
		_append_window(glass, trim, frame, center_y, width, height, columns, rows, projection)


static func _append_window(glass: Dictionary, trim: Dictionary, frame: Dictionary, center_y: float, width: float, height: float, columns: int, rows: int, projection: float) -> void:
	var anchor := frame.wall_anchor as Vector3
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	anchor.y = center_y
	_append_box(glass, anchor + normal * maxf(0.035, projection - 0.10), tangent, normal, width, height, 0.07)
	var trim_depth := 0.14
	for column in range(columns + 1):
		var lateral := -width * 0.5 + width * float(column) / float(columns)
		_append_box(trim, anchor + tangent * lateral + normal * projection, tangent, normal, 0.105, height + 0.16, trim_depth)
	for row in range(rows + 1):
		var vertical := -height * 0.5 + height * float(row) / float(rows)
		_append_box(trim, anchor + Vector3.UP * vertical + normal * projection, tangent, normal, width + 0.16, 0.105, trim_depth)


static func _append_entry_groups(glass: Dictionary, reveal: Dictionary, bronze: Dictionary, record: Dictionary, runs: Array[int], group_count: int, doors_per_group: int, front: Dictionary) -> void:
	var frame := _chain_frame(record, runs, _chain_length(record, runs) * 0.5)
	var center := frame.wall_anchor as Vector3
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	var group_width := float(front.entrance_group_width)
	var gap := float(front.entrance_group_gap)
	var height := float(front.entrance_height)
	var total := float(group_count) * group_width + float(group_count - 1) * gap
	var base_y := float(frame.base_y)
	for group_index in group_count:
		var lateral := -total * 0.5 + group_width * 0.5 + float(group_index) * (group_width + gap)
		var anchor := center + tangent * lateral
		anchor.y = base_y + height * 0.5
		_append_box(
			reveal,
			anchor + normal * float(front.entrance_reveal_center_projection),
			tangent,
			normal,
			group_width + float(front.entrance_reveal_border) * 2.0,
			height + float(front.entrance_reveal_border) * 2.0,
			float(front.entrance_reveal_depth)
		)
		_append_box(
			glass,
			anchor + normal * float(front.entrance_glass_center_projection),
			tangent,
			normal,
			group_width,
			height,
			float(front.entrance_glass_depth)
		)
		for leaf in range(doors_per_group + 1):
			var leaf_lateral := -group_width * 0.5 + group_width * float(leaf) / float(doors_per_group)
			_append_box(
				bronze,
				anchor + tangent * leaf_lateral + normal * float(front.entrance_frame_center_projection),
				tangent,
				normal,
				float(front.entrance_frame_width),
				height + float(front.entrance_frame_width),
				float(front.entrance_frame_depth)
			)
		for rail_y in [-height * 0.5, 0.95, height * 0.5]:
			_append_box(
				bronze,
				anchor + Vector3.UP * float(rail_y) + normal * float(front.entrance_frame_center_projection),
				tangent,
				normal,
				group_width + float(front.entrance_frame_width),
				float(front.entrance_frame_width),
				float(front.entrance_frame_depth)
			)


static func _append_chain_band(bucket: Dictionary, record: Dictionary, runs: Array[int], center_y: float, height: float, projection: float) -> void:
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var center := (frame.start as Vector3).lerp(frame.end as Vector3, 0.5)
		center.y = center_y
		_append_wall_bar(bucket, center, frame.tangent as Vector3, frame.normal as Vector3, center_y, float(frame.length_m) + 0.06, height, projection)


static func _append_end_composition(glass: Dictionary, trim: Dictionary, record: Dictionary, run_index: int, front: Dictionary) -> void:
	var frame := _run_frame(record, run_index)
	var length := float(frame.length_m)
	var tall_width := clampf(length * 0.17, 0.95, 1.65)
	var flank_width := clampf(length * 0.085, 0.55, 0.82)
	for sign_value in [-1.0, 1.0]:
		var tall_frame := frame.duplicate(true)
		tall_frame["wall_anchor"] = (frame.start as Vector3).lerp(frame.end as Vector3, 0.5) + (frame.tangent as Vector3) * (length * 0.19 * float(sign_value))
		_append_window(glass, trim, tall_frame, 14.2, tall_width, 11.25, 4, 5, 0.16)
		var flank_frame := frame.duplicate(true)
		flank_frame["wall_anchor"] = (frame.start as Vector3).lerp(frame.end as Vector3, 0.5) + (frame.tangent as Vector3) * (length * 0.405 * float(sign_value))
		_append_window(glass, trim, flank_frame, 15.05, flank_width, 3.35, 2, 3, 0.15)
	var center := (frame.start as Vector3).lerp(frame.end as Vector3, 0.5)
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	center.y = 14.25
	# Preserve the documented relief location as a quiet, low-contrast field.
	# The previous high-contrast bar proxy suggested a cruciform symbol and is
	# intentionally absent; no sculpture or as-built ornament is claimed.
	_append_box(
		trim,
		center + normal * float(front.end_relief_field_center_projection),
		tangent,
		normal,
		clampf(length * 0.13, 0.72, 1.15),
		float(front.end_relief_field_height),
		float(front.end_relief_field_depth)
	)


static func _append_canopy(visual: Dictionary, underside: Dictionary, collision: Dictionary, record: Dictionary, runs: Array[int], front: Dictionary) -> void:
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var wall_center := (frame.start as Vector3).lerp(frame.end as Vector3, 0.5)
		var normal := frame.normal as Vector3
		var tangent := frame.tangent as Vector3
		var center := wall_center + normal * float(front.canopy_primary_center_projection)
		center.y = 12.6
		var width := float(frame.length_m) + 0.12
		_append_box(visual, center, tangent, normal, width, float(front.canopy_primary_height), float(front.canopy_primary_depth))
		# Keep the accepted reachable/spray-blocking primary canopy collision
		# exactly congruent; the leading edge and underside are visual accents.
		_append_box(collision, center, tangent, normal, width, float(front.canopy_primary_height), float(front.canopy_primary_depth))
		var leading_edge := wall_center + normal * float(front.canopy_leading_edge_center_projection)
		leading_edge.y = 12.6
		_append_box(visual, leading_edge, tangent, normal, width + 0.04, float(front.canopy_leading_edge_height), float(front.canopy_leading_edge_depth))
		var underside_center := wall_center + normal * float(front.canopy_underside_center_projection)
		underside_center.y = 12.35
		_append_box(underside, underside_center, tangent, normal, width - 0.04, float(front.canopy_underside_height), float(front.canopy_underside_depth))


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
		"as_built_fidelity_claimed": false,
		"visual_review_status": VISUAL_REVIEW_STATUS,
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
	var expected_vertices := {
		BUILDING_WALL_KEY: 1320,
		BUILDING_ROOF_KEY: 246,
		TOWER_WALL_KEY: 120,
		TOWER_ROOF_KEY: 24,
	}
	var expected_indices := {
		BUILDING_WALL_KEY: 660,
		BUILDING_ROOF_KEY: 252,
		TOWER_WALL_KEY: 60,
		TOWER_ROOF_KEY: 18,
	}
	var expected_feature := "building_wall" if key.ends_with(":wall") else "building_roof"
	return record.get("source_keys", []) == [expected_source] \
		and str(record.get("feature_kind", "")) == expected_feature \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and (record.get("vertices", []) as Array).size() == int(expected_vertices[key]) \
		and (record.get("indices", []) as Array).size() == int(expected_indices[key])


static func _config_valid(config: Dictionary) -> bool:
	if config.is_empty():
		return false
	var target := config.get("target", {}) as Dictionary
	var vertical := config.get("vertical_production_inference_m", {}) as Dictionary
	var schedule := config.get("facade_schedule", {}) as Dictionary
	return str(config.get("schema_version", "")) == "ti.building-1-hero-model/1" \
		and str(target.get("building_source_key", "")) == BUILDING_SOURCE_KEY \
		and str(target.get("tower_source_key", "")) == TOWER_SOURCE_KEY \
		and bool(target.get("tower_remains_separately_reviewable", false)) \
		and float(vertical.get("two_story_roof_y", 0.0)) < float(vertical.get("three_story_roof_y", 0.0)) \
		and float(vertical.get("three_story_roof_y", 0.0)) < float(vertical.get("four_story_roof_y", 0.0)) \
		and float(vertical.get("four_story_roof_y", 0.0)) < float(vertical.get("tower_glass_top_y", 0.0)) \
		and float(vertical.get("tower_glass_top_y", 0.0)) < float(vertical.get("tower_roof_peak_y", 0.0)) \
		and int(schedule.get("central_window_count", 0)) == 11 \
		and int(schedule.get("central_lights_per_window", 0)) == 18 \
		and int(schedule.get("upper_windows_per_wing", 0)) == 8 \
		and int(schedule.get("upper_lights_per_window", 0)) == 10 \
		and int(schedule.get("lower_windows_per_wing", 0)) == 7 \
		and int(schedule.get("tall_windows_per_end", 0)) == 2 \
		and int(schedule.get("lights_per_tall_end_window", 0)) == 20 \
		and int(schedule.get("entrance_groups", 0)) == 3 \
		and int(schedule.get("doors_per_entrance_group", 0)) == 3


static func _bar_config_valid(config: Dictionary) -> bool:
	if config.is_empty():
		return false
	var target := config.get("target", {}) as Dictionary
	var geometry := config.get("geometry_production_inference_m", {}) as Dictionary
	var truth := config.get("truth", {}) as Dictionary
	var expected_runs: Array[int] = []
	for run_index in range(21, 44):
		expected_runs.append(run_index)
	return str(config.get("schema_version", "")) == "ti.building-1-public-front-believability/1" \
		and str(target.get("building_source_key", "")) == BUILDING_SOURCE_KEY \
		and str(target.get("wall_object_key", "")) == BUILDING_WALL_KEY \
		and str(target.get("roof_object_key", "")) == BUILDING_ROOF_KEY \
		and _int_array(target.get("public_front_chain_runs", []) as Array) == expected_runs \
		and int(geometry.get("pilaster_count", 0)) == 12 \
		and int(geometry.get("pilaster_flutes_per_pilaster", 0)) == 2 \
		and float(geometry.get("window_reveal_center_projection", -1.0)) + float(geometry.get("window_reveal_depth", 0.0)) * 0.5 \
			< float(geometry.get("window_frame_center_projection", -1.0)) + float(geometry.get("window_frame_depth", 0.0)) * 0.5 \
		and float(geometry.get("window_frame_center_projection", -1.0)) + float(geometry.get("window_frame_depth", 0.0)) * 0.5 \
			< float(geometry.get("pilaster_flute_center_projection", -1.0)) + float(geometry.get("pilaster_flute_depth", 0.0)) * 0.5 \
		and is_equal_approx(float(geometry.get("projecting_base_depth", -1.0)), 0.28) \
		and is_equal_approx(float(geometry.get("projecting_base_top_y", -1.0)), 12.45) \
		and is_equal_approx(float(geometry.get("canopy_primary_center_projection", -1.0)), 1.08) \
		and is_equal_approx(float(geometry.get("canopy_primary_depth", -1.0)), 2.25) \
		and is_equal_approx(float(geometry.get("canopy_primary_height", -1.0)), 0.42) \
		and bool(truth.get("misleading_cruciform_proxy_removed", false)) \
		and bool(truth.get("quiet_neutral_relief_location_field_used", false)) \
		and not bool(truth.get("horizontal_source_geometry_changed", true)) \
		and not bool(truth.get("vertical_massing_changed", true)) \
		and not bool(truth.get("collision_geometry_changed", true)) \
		and not bool(truth.get("spray_ownership_changed", true)) \
		and not bool(truth.get("roof_traversal_changed", true)) \
		and not bool(truth.get("image_texture_used", true)) \
		and not bool(truth.get("genai_texture_candidate_consumed", true)) \
		and str(truth.get("review_status", "")) == "pending_independent_bar_raiser_re_review_not_self_accepted"


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
