class_name IsleHouse39BrutonLowFacadePrototype
extends Node3D

const TARGET_PARENT_SOURCE_KEY := "w1249412094"
const TARGET_SOURCE_KEY := "w1282547787"
const TARGET_HIGH_SOURCE_KEY := "w1282547786"
const TARGET_LOGICAL_OBJECT_KEY := "building-composite:w1249412094"
const TARGET_RECEIVER_OBJECT_KEY := "building-composite:w1249412094:w1282547787:wall"
const TARGET_HIGH_RECEIVER_OBJECT_KEY := "building-composite:w1249412094:w1282547786:wall"
const CONFIG_PATH := "res://game/resources/facades/isle_house_39_bruton_low_facade_prototype.json"
const RENDER_BUILDING_WALL := 1 << 1
const OBSERVED_FIELD_RUN_INDICES := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
const MODULE_RUN_INDICES := [2, 3, 8, 9]
const PROTECTED_RUN_INDICES := [10, 11, 12]
const METER_UV := preload("res://game/scripts/world/facades/facade_meter_uv_adapter.gd")

const MATERIALS := {
	"brick": preload("res://game/resources/materials/world/isle_house/isle_house_low_brick.tres"),
	"brick_field": preload("res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres"),
	"frame": preload("res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres"),
	"glass": preload("res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres"),
	"patio": preload("res://game/resources/materials/world/isle_house/isle_house_low_patio.tres"),
}

var _config: Dictionary = {}
var _render_contract: Dictionary = {}
var _side_nodes: Dictionary = {}
var _box_transforms: Dictionary = {}
var _box_counts: Dictionary = {}
var _signature_parts: PackedStringArray = []
var _configured := false


static func matches_target(record: Dictionary) -> bool:
	var source_keys: Array = record.get("source_keys", [])
	return str(record.get("object_key", "")) == TARGET_RECEIVER_OBJECT_KEY \
		and str(record.get("feature_kind", "")) == "building_part_wall" \
		and str(record.get("material_key", "")) == "building_part_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and source_keys.size() == 1 \
		and str(source_keys[0]) == TARGET_SOURCE_KEY


func configure(record: Dictionary) -> Dictionary:
	if _configured:
		return {"ok": false, "message": "Isle House low prototype refused duplicate configuration."}
	if not matches_target(record):
		return {"ok": false, "message": "Isle House low prototype refused a non-target receiver."}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not (parsed is Dictionary):
		return {"ok": false, "message": "Isle House low prototype config could not be parsed."}
	_config = parsed as Dictionary
	if not _config_contract_matches(_config) or not _record_matches_config(record):
		return {"ok": false, "message": "Isle House low prototype identity, topology, run geometry, or bounded-layout contract drifted."}

	_render_contract = _config.get("render_contract", {}) as Dictionary
	name = "IsleHouse39BrutonLowFacadePrototype"
	set_meta("target_parent_source_key", TARGET_PARENT_SOURCE_KEY)
	set_meta("target_source_key", TARGET_SOURCE_KEY)
	set_meta("target_high_source_key", TARGET_HIGH_SOURCE_KEY)
	set_meta("target_logical_object_key", TARGET_LOGICAL_OBJECT_KEY)
	set_meta("target_receiver_object_key", TARGET_RECEIVER_OBJECT_KEY)
	set_meta("target_high_receiver_object_key", TARGET_HIGH_RECEIVER_OBJECT_KEY)
	set_meta("config_path", CONFIG_PATH)
	set_meta("config_sha256", FileAccess.get_sha256(CONFIG_PATH))
	set_meta("prototype_only", true)
	set_meta("runtime_attachment", false)
	set_meta("technical_evidence_status", "pending_independent_review")
	set_meta("receiver_geometry_fit", "contract_testable_not_art_accepted")
	set_meta("part_recognition_accepted", false)
	set_meta("whole_composite_recognition_accepted", false)
	set_meta("as_built_claim", false)
	set_meta("observed_field_run_indices", OBSERVED_FIELD_RUN_INDICES.duplicate())
	set_meta("module_run_indices", MODULE_RUN_INDICES.duplicate())
	set_meta("protected_run_indices", PROTECTED_RUN_INDICES.duplicate())
	set_meta("collision", "none")
	set_meta("navigation", "none")
	set_meta("spray_ray_owner", "unchanged_underlying_receiver")
	set_meta("future_integration_api", "matches_target(record) then configure(record)")
	add_to_group("isle_house_low_prototype_render_only")

	_build_side_nodes()
	var field_result := _build_observed_fields(record)
	if not bool(field_result.get("ok", false)):
		return field_result
	var placements := _config.get("placements", []) as Array
	for placement_value: Variant in placements:
		_build_live_work_module(record, placement_value as Dictionary)
	_flush_box_batches()
	var signature_values: Array[String] = []
	for value: String in _signature_parts:
		signature_values.append(value)
	signature_values.sort()
	var signature := JSON.stringify(signature_values).sha256_text()
	set_meta("deterministic_signature", signature)
	set_meta("field_segment_count", int(field_result.get("segment_count", 0)))
	set_meta("field_triangle_count", int(field_result.get("triangle_count", 0)))
	set_meta("field_uv_contract", field_result.get("uv_contract", {}).duplicate(true))
	set_meta("field_side_chain_totals_m", field_result.get("side_chain_totals_m", {}).duplicate(true))
	set_meta("field_side_chain_signatures", field_result.get("side_chain_signatures", {}).duplicate(true))
	set_meta("module_count", placements.size())
	set_meta("module_box_counts", _box_counts.duplicate(true))
	_configured = true
	return {
		"ok": true,
		"deterministic_signature": signature,
		"field_segment_count": int(field_result.get("segment_count", 0)),
		"field_triangle_count": int(field_result.get("triangle_count", 0)),
		"field_uv_contract": field_result.get("uv_contract", {}).duplicate(true),
		"field_side_chain_totals_m": field_result.get("side_chain_totals_m", {}).duplicate(true),
		"module_count": placements.size(),
		"module_box_counts": _box_counts.duplicate(true),
	}


func _config_contract_matches(config: Dictionary) -> bool:
	if str(config.get("schema_version", "")) != "ti.isle-house-low-facade-prototype/1":
		return false
	var target := config.get("target", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	var render := config.get("render_contract", {}) as Dictionary
	var field_material := render.get("brick_field_material", {}) as Dictionary
	var uv_contract := render.get("field_uv_contract", {}) as Dictionary
	if str(target.get("parent_source_key", "")) != TARGET_PARENT_SOURCE_KEY \
	or str(target.get("source_key", "")) != TARGET_SOURCE_KEY \
	or str(target.get("high_source_key", "")) != TARGET_HIGH_SOURCE_KEY \
	or str(target.get("logical_object_key", "")) != TARGET_LOGICAL_OBJECT_KEY \
	or str(target.get("receiver_object_key", "")) != TARGET_RECEIVER_OBJECT_KEY \
	or str(target.get("high_receiver_object_key", "")) != TARGET_HIGH_RECEIVER_OBJECT_KEY \
	or str(target.get("chunk_id", "")) != "x_-1__z_2" \
	or str(target.get("geometry_sha256", "")) != "99d96b6c7efb1a25a17439f56368706f92270d8008d7d9eaeb8b9f3ea8656ff5" \
	or int(target.get("wall_segments", 0)) != 13 \
	or int(target.get("wall_vertices", 0)) != 52 \
	or int(target.get("wall_triangles", 0)) != 26 \
	or not is_equal_approx(float(target.get("height_m", 0.0)), 15.0) \
	or not is_equal_approx(float(target.get("flat_base_y_m", 0.0)), 4.103) \
	or not is_equal_approx(float(target.get("lowest_foundation_y_m", 0.0)), 3.983) \
	or not is_equal_approx(float(target.get("top_y_m", 0.0)), 19.103):
		return false
	if not bool(truth.get("prototype_only", false)) \
	or bool(truth.get("runtime_attachment", true)) \
	or str(truth.get("technical_evidence_status", "")) != "pending_independent_review" \
	or bool(truth.get("part_recognition_accepted", true)) \
	or bool(truth.get("whole_composite_recognition_accepted", true)) \
	or bool(truth.get("as_built_claim", true)) \
	or bool(truth.get("surveyed_dimensions", true)) \
	or bool(truth.get("surveyed_bay_count", true)) \
	or bool(truth.get("surveyed_cadence", true)) \
	or bool(truth.get("reference_pixels_stored_or_copied", true)):
		return false
	if int(render.get("render_layer", 0)) != RENDER_BUILDING_WALL \
	or float(render.get("field_offset_m", 1.0)) <= 0.0 \
	or float(render.get("module_inner_offset_m", 1.0)) <= float(render.get("field_offset_m", 0.0)) \
	or float(render.get("maximum_relief_m", 1.0)) > 0.1 \
	or float(render.get("live_work_band_top_y_m", 99.0)) >= float(target.get("top_y_m", 0.0)) \
	or float(render.get("minimum_module_corner_clearance_m", 0.0)) < 1.8 \
	or str(render.get("collision", "")) != "none" \
	or str(render.get("navigation", "")) != "none" \
	or str(render.get("spray_ray_owner", "")) != "unchanged_underlying_receiver" \
	or str(render.get("roof_ownership", "")) != "none" \
	or str(render.get("silhouette_ownership", "")) != "none" \
	or str(field_material.get("path", "")) != "res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres" \
	or not is_equal_approx(float(field_material.get("starting_cell_m", 0.0)), 2.5) \
	or not is_equal_approx(float(field_material.get("roughness", 0.0)), 0.86) \
	or field_material.get("tint", []) != [0.70, 0.66, 0.62, 1.0] \
	or bool(field_material.get("normal_map", true)) \
	or bool(field_material.get("roughness_map", true)) \
	or str(uv_contract.get("contract_version", "")) != METER_UV.CONTRACT_VERSION \
	or str(uv_contract.get("u_phase_rule", "")) != METER_UV.U_PHASE_RULE \
	or str(uv_contract.get("corner_rule", "")) != METER_UV.CORNER_RULE \
	or str(uv_contract.get("v_phase_rule", "")) != METER_UV.V_PHASE_RULE:
		return false
	var sides := config.get("side_groups", []) as Array
	if sides.size() != 3:
		return false
	if _int_array((sides[0] as Dictionary).get("ordered_run_indices", []) as Array) != [0, 1, 2, 3, 4] \
	or _int_array((sides[1] as Dictionary).get("ordered_run_indices", []) as Array) != [5, 6, 7, 8, 9] \
	or _int_array((sides[2] as Dictionary).get("ordered_run_indices", []) as Array) != PROTECTED_RUN_INDICES \
	or str((sides[2] as Dictionary).get("mapping_status", "")) != "unobserved_protected" \
	or str((sides[2] as Dictionary).get("field_policy", "")) != "no_prototype_attachment" \
	or str((sides[2] as Dictionary).get("module_policy", "")) != "no_prototype_attachment":
		return false
	var runs := config.get("runs", []) as Array
	if runs.size() != 13:
		return false
	for index in 13:
		var run := runs[index] as Dictionary
		if int(run.get("index", -1)) != index:
			return false
		if bool(run.get("field", false)) != (index in OBSERVED_FIELD_RUN_INDICES) \
		or bool(run.get("modules", false)) != (index in MODULE_RUN_INDICES):
			return false
	var family := config.get("module_family", {}) as Dictionary
	if str(family.get("id", "")) != "IH-LOW-LIVEWORK-ENTRY-GALLERY" \
	or str(family.get("asset_kind", "")) != "complete_render_only_module" \
	or not bool(family.get("complete_motif", false)) \
	or bool(family.get("cross_run", true)) \
	or bool(family.get("wraps_corner", true)) \
	or bool(family.get("owns_collision", true)) \
	or bool(family.get("owns_navigation", true)) \
	or bool(family.get("owns_spray", true)) \
	or (family.get("observed_cues", []) as Array).size() != 4 \
	or (family.get("production_inferences", []) as Array).size() < 5:
		return false
	var placements := config.get("placements", []) as Array
	if placements.size() != 8 or not _placements_are_bounded(placements, runs, family, render):
		return false
	var protected := JSON.stringify(config.get("protected_regions", [])).to_lower()
	var blocked := JSON.stringify(config.get("blocked_claims", [])).to_lower()
	return "10.25..19.103" in protected \
		and "49.094" in protected \
		and "whole-composite" in blocked \
		and "as-built" in blocked \
		and "brick bond" in blocked \
		and "private" in blocked


func _placements_are_bounded(placements: Array, runs: Array, family: Dictionary, render: Dictionary) -> bool:
	var minimum_clearance := float(render.get("minimum_module_corner_clearance_m", 0.0))
	var intervals_by_run: Dictionary = {}
	for value: Variant in placements:
		var placement := value as Dictionary
		var run_index := int(placement.get("run_index", -1))
		if run_index not in MODULE_RUN_INDICES or run_index < 0 or run_index >= runs.size():
			return false
		var run := runs[run_index] as Dictionary
		var width := float(placement.get("width_m", 0.0))
		var center := float(placement.get("run_u_m", -1.0))
		var half := width * 0.5
		if str(placement.get("side_id", "")) != str(run.get("side_id", "")) \
		or str(placement.get("truth_class", "")) != "reversible_production_inference" \
		or not is_equal_approx(width, float(family.get("width_m", 0.0))) \
		or center - half < minimum_clearance - 0.0001 \
		or center + half > float(run.get("length_m", 0.0)) - minimum_clearance + 0.0001:
			return false
		var interval := Vector2(center - half, center + half)
		if not intervals_by_run.has(run_index):
			intervals_by_run[run_index] = []
		for other_value: Variant in intervals_by_run[run_index] as Array:
			var other := other_value as Vector2
			if interval.x < other.y + 0.25 and interval.y > other.x - 0.25:
				return false
		(intervals_by_run[run_index] as Array).append(interval)
	return true


func _record_matches_config(record: Dictionary) -> bool:
	var vertices := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var indices := record.get("indices", []) as Array
	if vertices.size() != 156 or normals.size() != 156 or indices.size() != 78:
		return false
	var target := _config.get("target", {}) as Dictionary
	var lowest := INF
	var highest := -INF
	for offset in range(1, vertices.size(), 3):
		lowest = minf(lowest, float(vertices[offset]))
		highest = maxf(highest, float(vertices[offset]))
	if absf(lowest - float(target.get("lowest_foundation_y_m", 0.0))) > 0.0006 \
	or absf(highest - float(target.get("top_y_m", 0.0))) > 0.0006:
		return false
	var runs := _config.get("runs", []) as Array
	for run_index in 13:
		var run := runs[run_index] as Dictionary
		var start_values := run.get("start_xyz_m", []) as Array
		var end_values := run.get("end_xyz_m", []) as Array
		var normal_values := run.get("normal_xz", []) as Array
		var offset := run_index * 12
		var actual_start := Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2]))
		var actual_end := Vector3(float(vertices[offset + 3]), float(vertices[offset + 4]), float(vertices[offset + 5]))
		var expected_start := Vector3(float(start_values[0]), float(start_values[1]), float(start_values[2]))
		var expected_end := Vector3(float(end_values[0]), float(end_values[1]), float(end_values[2]))
		var actual_normal := Vector2(float(normals[offset]), float(normals[offset + 2])).normalized()
		var expected_normal := Vector2(float(normal_values[0]), float(normal_values[1])).normalized()
		if actual_start.distance_to(expected_start) > 0.0006 \
		or actual_end.distance_to(expected_end) > 0.0006 \
		or actual_normal.distance_to(expected_normal) > 0.001 \
		or absf(float(vertices[offset + 7]) - float(target.get("top_y_m", 0.0))) > 0.0006 \
		or absf(float(vertices[offset + 10]) - float(target.get("top_y_m", 0.0))) > 0.0006:
			return false
	return true


func _build_side_nodes() -> void:
	for side_value: Variant in _config.get("side_groups", []) as Array:
		var side := side_value as Dictionary
		var side_id := str(side.get("id", ""))
		var side_node := Node3D.new()
		side_node.name = "Side_%s" % side_id.replace("-", "_")
		side_node.set_meta("side_id", side_id)
		side_node.set_meta("run_indices", _int_array(side.get("ordered_run_indices", []) as Array))
		side_node.set_meta("mapping_status", str(side.get("mapping_status", "")))
		side_node.set_meta("field_policy", str(side.get("field_policy", "")))
		side_node.set_meta("module_policy", str(side.get("module_policy", "")))
		side_node.set_meta("foundation_geometry_untouched", true)
		add_child(side_node)
		_side_nodes[side_id] = side_node


func _build_observed_fields(record: Dictionary) -> Dictionary:
	var group := _empty_surface_group()
	var vertices := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var runs := _config.get("runs", []) as Array
	var top_y := float(_render_contract.get("live_work_band_top_y_m", 0.0))
	var outward_distance := float(_render_contract.get("field_offset_m", 0.0))
	var entries_by_run: Dictionary = {}
	var side_chain_totals_m: Dictionary = {}
	var side_chain_signatures: Dictionary = {}
	for side_value: Variant in _config.get("side_groups", []) as Array:
		var side := side_value as Dictionary
		if str(side.get("mapping_status", "")) != "public_side_mapped":
			continue
		var side_id := str(side.get("id", ""))
		var plan := METER_UV.plan_side_chain(
			runs,
			side.get("ordered_run_indices", []) as Array,
			side_id
		) as Dictionary
		if not bool(plan.get("ok", false)):
			return {
				"ok": false,
				"message": "Facade metre UV plan failed for %s: %s" % [side_id, str(plan.get("code", "unknown"))],
			}
		side_chain_totals_m[side_id] = float(plan.get("total_u_m", 0.0))
		side_chain_signatures[side_id] = str(plan.get("signature", ""))
		for entry_value: Variant in plan.get("entries", []) as Array:
			var entry := entry_value as Dictionary
			var entry_run_index := int(entry.get("run_index", -1))
			if entry_run_index not in OBSERVED_FIELD_RUN_INDICES or entries_by_run.has(entry_run_index):
				return {"ok": false, "message": "Facade metre UV plan covered an invalid or duplicate public run."}
			entries_by_run[entry_run_index] = entry
	if entries_by_run.size() != OBSERVED_FIELD_RUN_INDICES.size():
		return {"ok": false, "message": "Facade metre UV plans did not cover all public field runs."}
	for run_index_value: Variant in OBSERVED_FIELD_RUN_INDICES:
		var run_index := int(run_index_value)
		var offset := run_index * 12
		var normal := Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()
		var outward := normal * outward_distance
		var corners := [
			Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2])) + outward,
			Vector3(float(vertices[offset + 3]), float(vertices[offset + 4]), float(vertices[offset + 5])) + outward,
			Vector3(float(vertices[offset + 3]), top_y, float(vertices[offset + 5])) + outward,
			Vector3(float(vertices[offset]), top_y, float(vertices[offset + 2])) + outward,
		]
		var entry := entries_by_run[run_index] as Dictionary
		var quad_uvs := METER_UV.vertical_quad_uvs(corners, float(entry.get("u_start_m", 0.0))) as PackedVector2Array
		if quad_uvs.size() != 4:
			return {"ok": false, "message": "Facade metre UV adapter refused a public field quad."}
		_append_quad(group, corners, normal, quad_uvs)
		_signature_parts.append("field:%02d:%s" % [run_index, _corners_token(corners)])
		_signature_parts.append("field_uv:%02d:%s" % [run_index, _uvs_token(quad_uvs)])
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = group.vertices
	arrays[Mesh.ARRAY_NORMAL] = group.normals
	arrays[Mesh.ARRAY_TANGENT] = group.tangents
	arrays[Mesh.ARRAY_TEX_UV] = group.uvs
	arrays[Mesh.ARRAY_INDEX] = group.indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, MATERIALS["brick_field"] as Material)
	var fields := MeshInstance3D.new()
	fields.name = "ObservedPublicLiveWorkBrickFields_Runs_0_9"
	fields.mesh = mesh
	fields.layers = RENDER_BUILDING_WALL
	fields.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	fields.set_meta("facade_visual", true)
	fields.set_meta("truth_class", "reference_supported_family_with_reversible_vertical_extent")
	fields.set_meta("field_run_indices", OBSERVED_FIELD_RUN_INDICES.duplicate())
	fields.set_meta("protected_run_indices", PROTECTED_RUN_INDICES.duplicate())
	fields.set_meta("field_material_path", (MATERIALS["brick_field"] as Material).resource_path)
	fields.set_meta("field_material_cell_m", 2.5)
	fields.set_meta("field_material_truth_class", "genai_albedo_receiver_trial_pending_bar_raiser_review")
	fields.set_meta("uv_contract", METER_UV.contract_metadata())
	fields.set_meta("side_chain_totals_m", side_chain_totals_m.duplicate(true))
	fields.set_meta("side_chain_signatures", side_chain_signatures.duplicate(true))
	fields.set_meta("upper_band_untouched", true)
	fields.set_meta("roof_untouched", true)
	add_child(fields)
	return {
		"ok": true,
		"segment_count": OBSERVED_FIELD_RUN_INDICES.size(),
		"triangle_count": OBSERVED_FIELD_RUN_INDICES.size() * 2,
		"uv_contract": METER_UV.contract_metadata(),
		"side_chain_totals_m": side_chain_totals_m,
		"side_chain_signatures": side_chain_signatures,
	}


func _build_live_work_module(record: Dictionary, placement: Dictionary) -> void:
	var run_index := int(placement.get("run_index", -1))
	var run_u := float(placement.get("run_u_m", 0.0))
	var width := float(placement.get("width_m", 0.0))
	var offset := run_index * 12
	var vertices := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var start := Vector3(float(vertices[offset]), 0.0, float(vertices[offset + 2]))
	var end := Vector3(float(vertices[offset + 3]), 0.0, float(vertices[offset + 5]))
	var tangent := (end - start).normalized()
	var normal := Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()
	var module_transform := Transform3D(Basis(tangent, Vector3.UP, normal), start + tangent * run_u)

	var module := Node3D.new()
	module.name = str(placement.get("id", "UNNAMED")).replace("-", "_")
	module.transform = module_transform
	module.set_meta("motif_id", "IH-LOW-LIVEWORK-ENTRY-GALLERY")
	module.set_meta("placement_id", str(placement.get("id", "")))
	module.set_meta("side_id", str(placement.get("side_id", "")))
	module.set_meta("run_index", run_index)
	module.set_meta("run_u_m", run_u)
	module.set_meta("width_m", width)
	module.set_meta("height_m", 6.1)
	module.set_meta("complete_motif", true)
	module.set_meta("truth_class", "reversible_production_inference")
	module.set_meta("observed_cues", ["warm_brick", "two_level_glazing", "dutch_half_door_entry", "patio_threshold_edge"])
	module.set_meta("cross_run", false)
	module.set_meta("wraps_corner", false)
	module.set_meta("render_only", true)
	module.set_meta("collision", "none")
	module.set_meta("navigation", "none")
	module.set_meta("spray_owner", "none")
	(_side_nodes[str(placement.get("side_id", ""))] as Node3D).add_child(module)

	# Reference-supported family: warm brick piers, two-level glazing, an
	# individual Dutch/half-door entry, and a shallow patio/threshold edge.
	# Every exact proportion and placement below is reversible production inference.
	_add_module_box("brick", placement, module_transform, "BrickPierLeft", Vector3(-2.05, 7.30, 0.050), Vector3(0.30, 6.10, 0.076))
	_add_module_box("brick", placement, module_transform, "BrickPierDivider", Vector3(-0.87, 7.30, 0.050), Vector3(0.26, 6.10, 0.076))
	_add_module_box("brick", placement, module_transform, "BrickPierRight", Vector3(2.05, 7.30, 0.050), Vector3(0.30, 6.10, 0.076))

	_add_module_box("glass", placement, module_transform, "GalleryGlazingLower", Vector3(0.59, 5.74, 0.051), Vector3(2.62, 2.52, 0.050))
	_add_module_box("glass", placement, module_transform, "GalleryGlazingUpper", Vector3(0.59, 8.66, 0.051), Vector3(2.62, 2.72, 0.050))
	_add_module_box("frame", placement, module_transform, "GalleryFrameLeft", Vector3(-0.78, 7.28, 0.074), Vector3(0.12, 6.08, 0.052))
	_add_module_box("frame", placement, module_transform, "GalleryFrameRight", Vector3(1.96, 7.28, 0.074), Vector3(0.12, 6.08, 0.052))
	_add_module_box("frame", placement, module_transform, "GalleryFrameBottom", Vector3(0.59, 4.30, 0.074), Vector3(2.86, 0.12, 0.052))
	_add_module_box("frame", placement, module_transform, "GalleryFrameLevel", Vector3(0.59, 7.12, 0.074), Vector3(2.86, 0.14, 0.052))
	_add_module_box("frame", placement, module_transform, "GalleryFrameTop", Vector3(0.59, 10.25, 0.074), Vector3(2.86, 0.12, 0.052))
	_add_module_box("frame", placement, module_transform, "GalleryMullion", Vector3(0.59, 7.28, 0.073), Vector3(0.10, 5.96, 0.054))

	_add_module_box("glass", placement, module_transform, "DutchDoorUpperGlazing", Vector3(-1.46, 6.36, 0.056), Vector3(0.92, 1.25, 0.058))
	_add_module_box("glass", placement, module_transform, "DutchDoorLowerPanel", Vector3(-1.46, 4.94, 0.056), Vector3(0.92, 1.41, 0.058))
	_add_module_box("frame", placement, module_transform, "DutchDoorFrameLeft", Vector3(-1.98, 5.64, 0.071), Vector3(0.12, 2.78, 0.056))
	_add_module_box("frame", placement, module_transform, "DutchDoorFrameRight", Vector3(-0.94, 5.64, 0.071), Vector3(0.12, 2.78, 0.056))
	_add_module_box("frame", placement, module_transform, "DutchDoorFrameBottom", Vector3(-1.46, 4.27, 0.071), Vector3(1.16, 0.12, 0.056))
	_add_module_box("frame", placement, module_transform, "DutchDoorFrameSplit", Vector3(-1.46, 5.64, 0.071), Vector3(1.16, 0.12, 0.056))
	_add_module_box("frame", placement, module_transform, "DutchDoorFrameTop", Vector3(-1.46, 7.01, 0.071), Vector3(1.16, 0.12, 0.056))
	_add_module_box("patio", placement, module_transform, "PatioThresholdEdge", Vector3(0.0, 4.20, 0.062), Vector3(4.36, 0.16, 0.076))
	_signature_parts.append("module:%s:run=%02d:u=%.3f:w=%.3f" % [str(placement.get("id", "")), run_index, run_u, width])


func _add_module_box(material_key: String, placement: Dictionary, module_transform: Transform3D, component_name: String, local_origin: Vector3, size: Vector3) -> void:
	assert(size.x > 0.0 and size.y > 0.0 and size.z > 0.0)
	var outer := local_origin.z + size.z * 0.5
	var inner := local_origin.z - size.z * 0.5
	assert(inner >= float(_render_contract.get("field_offset_m", 0.0)) - 0.0001)
	assert(outer <= float(_render_contract.get("maximum_relief_m", 0.0)) + 0.0001)
	var local_basis := Basis(Vector3.RIGHT * size.x, Vector3.UP * size.y, Vector3.BACK * size.z)
	var world_transform := module_transform * Transform3D(local_basis, local_origin)
	if not _box_transforms.has(material_key):
		_box_transforms[material_key] = []
	(_box_transforms[material_key] as Array).append(world_transform)
	_box_counts[material_key] = int(_box_counts.get(material_key, 0)) + 1
	_signature_parts.append("box:%s:%s:%s:%s" % [material_key, str(placement.get("id", "")), component_name, _transform_token(world_transform)])


func _flush_box_batches() -> void:
	var batches := Node3D.new()
	batches.name = "RenderOnlyModuleBatches"
	batches.set_meta("render_only", true)
	batches.set_meta("collision", "none")
	batches.set_meta("navigation", "none")
	batches.set_meta("spray_owner", "none")
	add_child(batches)
	var material_keys := _box_transforms.keys()
	material_keys.sort()
	for key_value: Variant in material_keys:
		var material_key := str(key_value)
		var transforms := _box_transforms[material_key] as Array
		var box := BoxMesh.new()
		box.size = Vector3.ONE
		box.material = MATERIALS[material_key] as Material
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = box
		multimesh.instance_count = transforms.size()
		for index in transforms.size():
			multimesh.set_instance_transform(index, transforms[index] as Transform3D)
		var instance := MultiMeshInstance3D.new()
		instance.name = "Batch_%s" % material_key
		instance.multimesh = multimesh
		instance.layers = RENDER_BUILDING_WALL
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		instance.set_meta("facade_visual", true)
		instance.set_meta("material_key", material_key)
		instance.set_meta("instance_count", transforms.size())
		instance.set_meta("render_only", true)
		batches.add_child(instance)


func _empty_surface_group() -> Dictionary:
	return {
		"vertices": PackedVector3Array(),
		"normals": PackedVector3Array(),
		"tangents": PackedFloat32Array(),
		"uvs": PackedVector2Array(),
		"indices": PackedInt32Array(),
	}


func _append_quad(group: Dictionary, corners: Array, normal: Vector3, quad_uvs: PackedVector2Array) -> void:
	var vertices := group.vertices as PackedVector3Array
	var normals := group.normals as PackedVector3Array
	var tangents := group.tangents as PackedFloat32Array
	var uvs := group.uvs as PackedVector2Array
	var indices := group.indices as PackedInt32Array
	var base := vertices.size()
	var tangent := Vector3(normal.z, 0.0, -normal.x).normalized()
	for corner_index in corners.size():
		vertices.append(corners[corner_index] as Vector3)
		normals.append(normal)
		tangents.append_array(PackedFloat32Array([tangent.x, tangent.y, tangent.z, 1.0]))
		uvs.append(quad_uvs[corner_index])
	indices.append_array(PackedInt32Array([base, base + 2, base + 1, base, base + 3, base + 2]))
	group["vertices"] = vertices
	group["normals"] = normals
	group["tangents"] = tangents
	group["uvs"] = uvs
	group["indices"] = indices


func _corners_token(corners: Array) -> String:
	var values: Array[String] = []
	for value: Variant in corners:
		var corner := value as Vector3
		values.append("%.6f,%.6f,%.6f" % [corner.x, corner.y, corner.z])
	return ";".join(values)


func _uvs_token(uvs: PackedVector2Array) -> String:
	var values: Array[String] = []
	for uv: Vector2 in uvs:
		values.append("%.6f,%.6f" % [uv.x, uv.y])
	return ";".join(values)


func _transform_token(value: Transform3D) -> String:
	return "%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f" % [
		value.basis.x.x, value.basis.x.y, value.basis.x.z,
		value.basis.y.x, value.basis.y.y, value.basis.y.z,
		value.basis.z.x, value.basis.z.y, value.basis.z.z,
		value.origin.x, value.origin.y, value.origin.z,
	]


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result
