extends SceneTree

const CONFIG_PATH := "res://game/resources/facades/isle_house_39_bruton_low_facade_prototype.json"
const SCENE_PATH := "res://game/scenes/world/facades/isle_house/isle_house_low_facade_prototype.tscn"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const HIGH_WALL_KEY := "building-composite:w1249412094:w1282547786:wall"
const LOW_ROOF_KEY := "building-composite:w1249412094:w1282547787:roof"
const METER_UV := preload("res://game/scripts/world/facades/facade_meter_uv_adapter.gd")
const FIELD_MATERIAL_PATH := "res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres"
const FIELD_TEXTURE_PATH := "res://game/resources/textures/world/facade_shared_v1/muted_brown_red_brick_albedo_v1.png"
const REJECTED_LIVE_ATTACHMENT_PATH := "res://game/scripts/world/facades/isle_house_39_bruton_low_live_attachment.gd"
const ACCEPTED_LIVE_ATTACHMENT_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd"
const EXPECTED_CONFIG_SHA256 := "a0bfb094bfc4a7878a6dba0b5383dbd29cb8256f5a030a04ece222e912540ae0"
const EXPECTED_CHUNK_SHA256 := "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce"
const EXPECTED_ASSET_HASHES := {
	"res://game/scripts/world/facades/isle_house_39_bruton_low_facade_prototype.gd": "68373632dd41989bee82244bdfcef02b89e74202e5a0e22a86d7919285c3e321",
	"res://game/scripts/world/facades/facade_meter_uv_adapter.gd": "47e710b9ea7c5de5122430199e4105cbba5f672d22f59832f13b8004f16c5a1d",
	"res://game/scenes/world/facades/isle_house/isle_house_low_facade_prototype.tscn": "6dc28dbe5c0a6019ef770be90f830a0e72f7b454c21a785fdec992b96b6ebec3",
	FIELD_MATERIAL_PATH: "488ad52ae9aa0155fd0356eaff128b3ab88ba0c23528c6ae332e7e54c772ffb6",
	FIELD_TEXTURE_PATH: "0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d",
	"res://game/resources/materials/world/isle_house/isle_house_low_brick.tres": "fabab09ee257278336c1b7e9a2e6efab5f8e100df65340038ed03c7b0ea89635",
	"res://game/resources/materials/world/isle_house/isle_house_low_patio.tres": "a4790cb821a8bf37e57de4b02e9257a23b0abf6970af5f3da8daf2a22c8eaea5",
	"res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres": "6910208cb7130a86fbe8a063a6e8fa8e96cfa657d493e02449379b981ce961fe",
	"res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres": "19adff893d82c8c76542140b0ed6f1b3e08fa5e5b75101c0bb55c08b69f2c7ce",
	ACCEPTED_LIVE_ATTACHMENT_PATH: "e2767b01fab68d7f16ffe2e7f8e0313c711347e2006a72e028c19aaa2195b891",
}
const EXPECTED_BATCH_COUNTS := {"brick": 24, "frame": 88, "glass": 32, "patio": 8}
const OBSERVED_FIELD_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
const MODULE_RUNS := [2, 3, 8, 9]
const PROTECTED_RUNS := [10, 11, 12]
const RENDER_BUILDING_WALL := 1 << 1

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256, "Isle House low prototype config bytes drifted.") \
	or not _require(FileAccess.get_sha256(CHUNK_PATH) == EXPECTED_CHUNK_SHA256, "Isle House serialized chunk drifted.") \
	or not _require(_hashes_match(EXPECTED_ASSET_HASHES), "An Isle House low prototype package asset drifted.") \
	or not _require(_package_boundary_is_clean(), "The Isle House low runtime package contains an external/source-only path or URL.") \
	or not _require(_runtime_promotion_boundary_matches(), "The sealed Isle House low prototype or its bounded live promotion seam drifted."):
		_finish()
		return
	var config := JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH)) as Dictionary
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	var low_wall := _record_for_key(chunk.get("records", []) as Array, LOW_WALL_KEY)
	var high_wall := _record_for_key(chunk.get("records", []) as Array, HIGH_WALL_KEY)
	var low_roof := _record_for_key(chunk.get("records", []) as Array, LOW_ROOF_KEY)
	if not _require(not low_wall.is_empty() and not high_wall.is_empty() and not low_roof.is_empty(), "Could not resolve Isle House low/high/roof controls.") \
	or not _require(_config_truth_matches(config), "The prototype config overclaims evidence, acceptance, as-built status, or protected-region ownership.") \
		or not _require(_materials_match(), "Isle House low scalar materials or promoted albedo-only brick field material drifted.") \
	or not _require(_fail_closed_target_match(low_wall, high_wall, low_roof), "The prototype target matcher did not fail closed."):
		_finish()
		return
	var packed := load(SCENE_PATH) as PackedScene
	if not _require(packed != null, "The Isle House low prototype scene did not load."):
		_finish()
		return
	var first := packed.instantiate() as IsleHouse39BrutonLowFacadePrototype
	var first_result := first.configure(low_wall)
	if not _require(bool(first_result.get("ok", false)), str(first_result.get("message", "First exact-receiver configuration failed."))):
		first.free()
		_finish()
		return
	root.add_child(first)
	await process_frame
	if not _require(_scene_matches(first, low_wall, config), "The exact-receiver scene, field coverage, bounded modules, topology, or zero-ownership contract failed."):
		first.queue_free()
		_finish()
		return
	var first_signature := str(first.get_meta("deterministic_signature", ""))
	if not _require(not bool(first.configure(low_wall).get("ok", true)), "A configured prototype accepted duplicate configuration."):
		first.queue_free()
		_finish()
		return
	first.queue_free()
	await process_frame
	var second := packed.instantiate() as IsleHouse39BrutonLowFacadePrototype
	var second_result := second.configure(low_wall)
	root.add_child(second)
	await process_frame
	if not _require(bool(second_result.get("ok", false)), "Second exact-receiver configuration failed.") \
	or not _require(str(second.get_meta("deterministic_signature", "")) == first_signature, "Fresh Isle House low prototype instances are nondeterministic.") \
	or not _require(_scene_matches(second, low_wall, config), "The repeated exact-receiver scene failed its contract."):
		second.queue_free()
		_finish()
		return
	second.queue_free()
	print("ISLE_LOW_PROTOTYPE_SIGNATURE: %s" % first_signature)
	print("PASS: exact w1282547787 sealed source prototype and rejected live adapter remain byte-pinned and reproducible but inert; accepted Variant C is the sole current builder seam with no predecessor stack/fallback, while public-run mapping, package safety, zero ownership, and historical nonclaims remain explicit")
	_finish()


func _config_truth_matches(config: Dictionary) -> bool:
	if str(config.get("schema_version", "")) != "ti.isle-house-low-facade-prototype/1":
		return false
	var target := config.get("target", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	var render := config.get("render_contract", {}) as Dictionary
	var field_material := render.get("brick_field_material", {}) as Dictionary
	var uv_contract := render.get("field_uv_contract", {}) as Dictionary
	if str(target.get("source_key", "")) != "w1282547787" \
	or str(target.get("receiver_object_key", "")) != LOW_WALL_KEY \
	or str(target.get("high_source_key", "")) != "w1282547786" \
	or str(target.get("parent_source_key", "")) != "w1249412094" \
	or str(target.get("logical_object_key", "")) != "building-composite:w1249412094" \
	or str(target.get("chunk_id", "")) != "x_-1__z_2" \
	or int(target.get("wall_segments", 0)) != 13 \
	or int(target.get("wall_vertices", 0)) != 52 \
	or int(target.get("wall_triangles", 0)) != 26 \
	or not is_equal_approx(float(target.get("visible_wall_length_m", 0.0)), 144.909) \
	or not is_equal_approx(float(target.get("hidden_high_low_interface_length_m", 0.0)), 49.094):
		return false
	if not bool(truth.get("prototype_only", false)) \
	or bool(truth.get("runtime_attachment", true)) \
	or str(truth.get("technical_evidence_status", "")) != "pending_independent_review" \
	or str(truth.get("receiver_geometry_fit", "")) != "contract_testable_not_art_accepted" \
	or bool(truth.get("part_recognition_accepted", true)) \
	or bool(truth.get("whole_composite_recognition_accepted", true)) \
	or bool(truth.get("as_built_claim", true)) \
	or bool(truth.get("surveyed_dimensions", true)) \
	or bool(truth.get("surveyed_bay_count", true)) \
	or bool(truth.get("surveyed_cadence", true)) \
	or bool(truth.get("reference_pixels_stored_or_copied", true)):
		return false
	if int(render.get("render_layer", 0)) != RENDER_BUILDING_WALL \
	or float(render.get("maximum_relief_m", 1.0)) > 0.1 \
	or float(render.get("minimum_module_corner_clearance_m", 0.0)) < 1.8 \
	or str(render.get("collision", "")) != "none" \
	or str(render.get("navigation", "")) != "none" \
	or str(render.get("spray_ray_owner", "")) != "unchanged_underlying_receiver" \
	or str(render.get("roof_ownership", "")) != "none" \
	or str(render.get("silhouette_ownership", "")) != "none" \
	or str(field_material.get("path", "")) != FIELD_MATERIAL_PATH \
	or not is_equal_approx(float(field_material.get("starting_cell_m", 0.0)), 2.5) \
	or field_material.get("tint", []) != [0.70, 0.66, 0.62, 1.0] \
	or not is_equal_approx(float(field_material.get("roughness", 0.0)), 0.86) \
	or bool(field_material.get("normal_map", true)) \
	or bool(field_material.get("roughness_map", true)) \
	or str(field_material.get("visual_verdict", "")) != "pending_bar_raiser_review" \
	or str(uv_contract.get("contract_version", "")) != METER_UV.CONTRACT_VERSION \
	or str(uv_contract.get("u_phase_rule", "")) != METER_UV.U_PHASE_RULE \
	or str(uv_contract.get("corner_rule", "")) != METER_UV.CORNER_RULE \
	or str(uv_contract.get("v_phase_rule", "")) != METER_UV.V_PHASE_RULE \
	or bool(uv_contract.get("protected_runs_receive_uvs", true)):
		return false
	var sides := config.get("side_groups", []) as Array
	if sides.size() != 3 \
	or _int_array((sides[0] as Dictionary).get("ordered_run_indices", []) as Array) != [0, 1, 2, 3, 4] \
	or _int_array((sides[1] as Dictionary).get("ordered_run_indices", []) as Array) != [5, 6, 7, 8, 9] \
	or _int_array((sides[2] as Dictionary).get("ordered_run_indices", []) as Array) != PROTECTED_RUNS \
	or str((sides[2] as Dictionary).get("mapping_status", "")) != "unobserved_protected":
		return false
	var family := config.get("module_family", {}) as Dictionary
	if str(family.get("id", "")) != "IH-LOW-LIVEWORK-ENTRY-GALLERY" \
	or not bool(family.get("complete_motif", false)) \
	or bool(family.get("cross_run", true)) \
	or bool(family.get("wraps_corner", true)) \
	or bool(family.get("owns_collision", true)) \
	or bool(family.get("owns_navigation", true)) \
	or bool(family.get("owns_spray", true)):
		return false
	var topology := config.get("prototype_topology", {}) as Dictionary
	if int(topology.get("field_segments", 0)) != 10 \
	or int(topology.get("field_vertices", 0)) != 40 \
	or int(topology.get("field_triangles", 0)) != 20 \
	or int(topology.get("complete_module_nodes", 0)) != 8 \
	or int(topology.get("boxes_per_module", 0)) != 19 \
	or int(topology.get("module_boxes", 0)) != 152 \
	or int(topology.get("module_box_triangles", 0)) != 1824 \
	or int(topology.get("render_batches", 0)) != 4 \
	or int(topology.get("total_visual_triangles", 0)) != 1844 \
	or int(topology.get("collision_nodes", -1)) != 0 \
	or int(topology.get("navigation_nodes", -1)) != 0 \
	or int(topology.get("spray_nodes", -1)) != 0:
		return false
	var protected_text := JSON.stringify(config.get("protected_regions", [])).to_lower()
	var blocked_text := JSON.stringify(config.get("blocked_claims", [])).to_lower()
	for phrase in ["10.25..19.103", "49.094", "no roof"]:
		if phrase not in protected_text:
			return false
	for phrase in ["private", "rear", "brick bond", "address 39", "seven-story podium", "whole-composite", "as-built"]:
		if phrase not in blocked_text:
			return false
	return true


func _fail_closed_target_match(low_wall: Dictionary, high_wall: Dictionary, low_roof: Dictionary) -> bool:
	if not IsleHouse39BrutonLowFacadePrototype.matches_target(low_wall) \
	or IsleHouse39BrutonLowFacadePrototype.matches_target(high_wall) \
	or IsleHouse39BrutonLowFacadePrototype.matches_target(low_roof):
		return false
	var wrong_object := low_wall.duplicate(true)
	wrong_object["object_key"] = HIGH_WALL_KEY
	var wrong_source := low_wall.duplicate(true)
	wrong_source["source_keys"] = ["w1282547786"]
	var wrong_kind := low_wall.duplicate(true)
	wrong_kind["feature_kind"] = "building_wall"
	if IsleHouse39BrutonLowFacadePrototype.matches_target(wrong_object) \
	or IsleHouse39BrutonLowFacadePrototype.matches_target(wrong_source) \
	or IsleHouse39BrutonLowFacadePrototype.matches_target(wrong_kind):
		return false
	var packed := load(SCENE_PATH) as PackedScene
	var refused := packed.instantiate() as IsleHouse39BrutonLowFacadePrototype
	var result := refused.configure(high_wall)
	var clean := not bool(result.get("ok", true)) and refused.get_child_count() == 0
	refused.free()
	return clean


func _scene_matches(instance: IsleHouse39BrutonLowFacadePrototype, record: Dictionary, config: Dictionary) -> bool:
	if not bool(instance.get_meta("prototype_only", false)) \
	or bool(instance.get_meta("runtime_attachment", true)) \
	or str(instance.get_meta("technical_evidence_status", "")) != "pending_independent_review" \
	or str(instance.get_meta("receiver_geometry_fit", "")) != "contract_testable_not_art_accepted" \
	or bool(instance.get_meta("part_recognition_accepted", true)) \
	or bool(instance.get_meta("whole_composite_recognition_accepted", true)) \
	or bool(instance.get_meta("as_built_claim", true)) \
	or instance.get_meta("observed_field_run_indices", []) != OBSERVED_FIELD_RUNS \
	or instance.get_meta("module_run_indices", []) != MODULE_RUNS \
	or instance.get_meta("protected_run_indices", []) != PROTECTED_RUNS \
	or int(instance.get_meta("field_segment_count", 0)) != 10 \
	or int(instance.get_meta("field_triangle_count", 0)) != 20 \
	or str((instance.get_meta("field_uv_contract", {}) as Dictionary).get("contract_version", "")) != METER_UV.CONTRACT_VERSION \
	or (instance.get_meta("field_side_chain_totals_m", {}) as Dictionary).size() != 2 \
	or (instance.get_meta("field_side_chain_signatures", {}) as Dictionary).size() != 2 \
	or int(instance.get_meta("module_count", 0)) != 8 \
	or instance.get_meta("module_box_counts", {}) != EXPECTED_BATCH_COUNTS \
	or str(instance.get_meta("deterministic_signature", "")).length() != 64:
		return false
	var fields := instance.get_node_or_null("ObservedPublicLiveWorkBrickFields_Runs_0_9") as MeshInstance3D
	if fields == null or fields.layers != RENDER_BUILDING_WALL \
	or fields.get_meta("field_run_indices", []) != OBSERVED_FIELD_RUNS \
	or fields.get_meta("protected_run_indices", []) != PROTECTED_RUNS \
	or str(fields.get_meta("field_material_path", "")) != FIELD_MATERIAL_PATH \
	or not is_equal_approx(float(fields.get_meta("field_material_cell_m", 0.0)), 2.5) \
	or str(fields.get_meta("field_material_truth_class", "")) != "genai_albedo_receiver_trial_pending_bar_raiser_review" \
	or str((fields.get_meta("uv_contract", {}) as Dictionary).get("contract_version", "")) != METER_UV.CONTRACT_VERSION \
	or (fields.get_meta("side_chain_totals_m", {}) as Dictionary).size() != 2 \
	or (fields.get_meta("side_chain_signatures", {}) as Dictionary).size() != 2 \
	or not bool(fields.get_meta("upper_band_untouched", false)) \
	or not bool(fields.get_meta("roof_untouched", false)) \
	or not _field_geometry_matches(fields, record, config):
		return false
	if not _modules_match(instance, config) or not _batches_match(instance):
		return false
	var protected_side := instance.get_node_or_null("Side_LOW_NNW_PROTECTED") as Node3D
	if protected_side == null \
	or protected_side.get_meta("run_indices", []) != PROTECTED_RUNS \
	or str(protected_side.get_meta("mapping_status", "")) != "unobserved_protected" \
	or protected_side.get_child_count() != 0:
		return false
	return _count_type(instance, CollisionObject3D) == 0 \
		and _count_type(instance, CollisionShape3D) == 0 \
		and _count_type(instance, NavigationRegion3D) == 0 \
		and not _any_node_in_group(instance, "spray_receiver_wall") \
		and not _any_node_in_group(instance, "spray_receiver")


func _field_geometry_matches(fields: MeshInstance3D, record: Dictionary, config: Dictionary) -> bool:
	var mesh := fields.mesh as ArrayMesh
	if mesh == null or mesh.get_surface_count() != 1 \
	or mesh.surface_get_material(0).resource_path != FIELD_MATERIAL_PATH:
		return false
	var arrays := mesh.surface_get_arrays(0) as Array
	var actual_vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var actual_uvs := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	var actual_indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	if actual_vertices.size() != 40 or actual_uvs.size() != 40 or actual_indices.size() != 60 or mesh.get_faces().size() / 3 != 20:
		return false
	var raw_vertices := record.get("vertices", []) as Array
	var raw_normals := record.get("normals", []) as Array
	var render := config.get("render_contract", {}) as Dictionary
	var field_offset := float(render.get("field_offset_m", 0.0))
	var top_y := float(render.get("live_work_band_top_y_m", 0.0))
	var entries_by_run: Dictionary = {}
	for side_index in 2:
		var side := (config.get("side_groups", []) as Array)[side_index] as Dictionary
		var plan := METER_UV.plan_side_chain(
			config.get("runs", []) as Array,
			side.get("ordered_run_indices", []) as Array,
			str(side.get("id", ""))
		) as Dictionary
		if not bool(plan.get("ok", false)):
			return false
		for entry_value: Variant in plan.get("entries", []) as Array:
			var entry := entry_value as Dictionary
			entries_by_run[int(entry.get("run_index", -1))] = entry
	for quad_index in OBSERVED_FIELD_RUNS.size():
		var run_index := int(OBSERVED_FIELD_RUNS[quad_index])
		var offset := run_index * 12
		var normal := Vector3(float(raw_normals[offset]), 0.0, float(raw_normals[offset + 2])).normalized()
		var outward := normal * field_offset
		var expected := [
			Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2])) + outward,
			Vector3(float(raw_vertices[offset + 3]), float(raw_vertices[offset + 4]), float(raw_vertices[offset + 5])) + outward,
			Vector3(float(raw_vertices[offset + 3]), top_y, float(raw_vertices[offset + 5])) + outward,
			Vector3(float(raw_vertices[offset]), top_y, float(raw_vertices[offset + 2])) + outward,
		]
		for corner_index in 4:
			if actual_vertices[quad_index * 4 + corner_index].distance_to(expected[corner_index] as Vector3) > 0.0001:
				return false
		var entry := entries_by_run.get(run_index, {}) as Dictionary
		var expected_uvs := METER_UV.vertical_quad_uvs(expected, float(entry.get("u_start_m", -1.0))) as PackedVector2Array
		for corner_index in 4:
			if actual_uvs[quad_index * 4 + corner_index].distance_to(expected_uvs[corner_index]) > 0.0001:
				return false
	return true


func _modules_match(instance: Node3D, config: Dictionary) -> bool:
	var modules: Array[Node] = []
	_collect_motif_nodes(instance, modules)
	var placements := config.get("placements", []) as Array
	var runs := config.get("runs", []) as Array
	var render := config.get("render_contract", {}) as Dictionary
	if modules.size() != placements.size():
		return false
	var seen: Array[String] = []
	var run_counts := {2: 0, 3: 0, 8: 0, 9: 0}
	for placement_value: Variant in placements:
		var placement := placement_value as Dictionary
		var node_name := str(placement.get("id", "")).replace("-", "_")
		var module := instance.find_child(node_name, true, false) as Node3D
		if module == null:
			return false
		seen.append(str(placement.get("id", "")))
		var run_index := int(placement.get("run_index", -1))
		var run := runs[run_index] as Dictionary
		var start_values := run.get("start_xyz_m", []) as Array
		var end_values := run.get("end_xyz_m", []) as Array
		var start := Vector3(float(start_values[0]), 0.0, float(start_values[2]))
		var end := Vector3(float(end_values[0]), 0.0, float(end_values[2]))
		var tangent := (end - start).normalized()
		var normal_values := run.get("normal_xz", []) as Array
		var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
		var u := float(placement.get("run_u_m", 0.0))
		var width := float(placement.get("width_m", 0.0))
		var clearance := minf(u - width * 0.5, float(run.get("length_m", 0.0)) - u - width * 0.5)
		if str(module.get_meta("motif_id", "")) != "IH-LOW-LIVEWORK-ENTRY-GALLERY" \
		or str(module.get_meta("placement_id", "")) != str(placement.get("id", "")) \
		or str(module.get_meta("side_id", "")) != str(placement.get("side_id", "")) \
		or int(module.get_meta("run_index", -1)) != run_index \
		or not is_equal_approx(float(module.get_meta("run_u_m", 0.0)), u) \
		or not bool(module.get_meta("complete_motif", false)) \
		or str(module.get_meta("truth_class", "")) != "reversible_production_inference" \
		or (module.get_meta("observed_cues", []) as Array).size() != 4 \
		or bool(module.get_meta("cross_run", true)) \
		or bool(module.get_meta("wraps_corner", true)) \
		or str(module.get_meta("collision", "")) != "none" \
		or str(module.get_meta("navigation", "")) != "none" \
		or str(module.get_meta("spray_owner", "")) != "none" \
		or module.transform.origin.distance_to(start + tangent * u) > 0.0001 \
		or module.transform.basis.x.normalized().distance_to(tangent) > 0.0001 \
		or module.transform.basis.z.normalized().distance_to(normal) > 0.0001 \
		or clearance < float(render.get("minimum_module_corner_clearance_m", 0.0)) - 0.0001 \
		or module.get_child_count() != 0:
			return false
		run_counts[run_index] = int(run_counts[run_index]) + 1
	seen.sort()
	return seen.size() == 8 and run_counts == {2: 2, 3: 2, 8: 2, 9: 2}


func _batches_match(instance: Node3D) -> bool:
	var batches := instance.get_node_or_null("RenderOnlyModuleBatches") as Node3D
	if batches == null or batches.get_child_count() != 4 \
	or str(batches.get_meta("collision", "")) != "none" \
	or str(batches.get_meta("navigation", "")) != "none" \
	or str(batches.get_meta("spray_owner", "")) != "none":
		return false
	var instance_total := 0
	var triangle_total := 20
	for material_key: String in ["brick", "frame", "glass", "patio"]:
		var batch := batches.get_node_or_null("Batch_%s" % material_key) as MultiMeshInstance3D
		if batch == null or batch.layers != RENDER_BUILDING_WALL \
		or not bool(batch.get_meta("render_only", false)) \
		or str(batch.get_meta("material_key", "")) != material_key \
		or int(batch.get_meta("instance_count", 0)) != int(EXPECTED_BATCH_COUNTS[material_key]) \
		or batch.multimesh == null \
		or batch.multimesh.instance_count != int(EXPECTED_BATCH_COUNTS[material_key]) \
		or not (batch.multimesh.mesh is BoxMesh) \
		or batch.multimesh.mesh.get_faces().size() / 3 != 12:
			return false
		instance_total += batch.multimesh.instance_count
		triangle_total += batch.multimesh.instance_count * 12
	return instance_total == 152 and triangle_total == 1844


func _materials_match() -> bool:
	var paths := [
		"res://game/resources/materials/world/isle_house/isle_house_low_brick.tres",
		"res://game/resources/materials/world/isle_house/isle_house_low_patio.tres",
		"res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres",
		"res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres",
	]
	var resources: Array[Resource] = []
	for path: String in paths:
		var material := load(path) as StandardMaterial3D
		if material == null \
		or material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED \
		or not is_zero_approx(material.metallic) \
		or material.albedo_color.a != 1.0 \
		or material.shading_mode != BaseMaterial3D.SHADING_MODE_PER_PIXEL \
		or material.albedo_texture != null \
		or material.normal_texture != null \
		or material.heightmap_enabled:
			return false
		resources.append(material)
	for first_index in resources.size():
		for second_index in range(first_index + 1, resources.size()):
			if resources[first_index] == resources[second_index]:
				return false
	var field_material := load(FIELD_MATERIAL_PATH) as StandardMaterial3D
	if field_material == null \
	or field_material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED \
	or not is_zero_approx(field_material.metallic) \
	or not is_equal_approx(field_material.roughness, 0.86) \
	or field_material.albedo_color != Color(0.70, 0.66, 0.62, 1.0) \
	or field_material.albedo_texture == null \
	or field_material.albedo_texture.resource_path != FIELD_TEXTURE_PATH \
	or field_material.normal_texture != null \
	or field_material.roughness_texture != null \
	or field_material.heightmap_enabled \
	or field_material.texture_filter != BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC \
	or field_material.uv1_scale != Vector3(0.4, 0.4, 1.0):
		return false
	return "mipmaps/generate=true" in FileAccess.get_file_as_string(FIELD_TEXTURE_PATH + ".import")


func _package_boundary_is_clean() -> bool:
	var files: Array[String] = [CONFIG_PATH, SCENE_PATH]
	for path_value: Variant in EXPECTED_ASSET_HASHES:
		files.append(str(path_value))
	for path: String in files:
		if path.get_extension().to_lower() not in ["gd", "tscn", "tres", "json"]:
			continue
		var source := FileAccess.get_file_as_string(path).to_lower()
		for forbidden in ["res://discovery/", "res://evidence/", "http://", "https://", "file://", "/volumes/", "/users/"]:
			if forbidden in source:
				return false
	return "ih-entry39" not in FileAccess.get_file_as_string(CONFIG_PATH).to_lower() \
		and "ih-entry39" not in FileAccess.get_file_as_string("res://game/scripts/world/facades/isle_house_39_bruton_low_facade_prototype.gd").to_lower()


func _runtime_promotion_boundary_matches() -> bool:
	var builder := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	var rejected_adapter := FileAccess.get_file_as_string(REJECTED_LIVE_ATTACHMENT_PATH)
	var accepted_adapter := FileAccess.get_file_as_string(ACCEPTED_LIVE_ATTACHMENT_PATH)
	var registry := FileAccess.get_file_as_string("res://game/resources/facades/facade-runtime-registry.json")
	if FileAccess.get_sha256(REJECTED_LIVE_ATTACHMENT_PATH) != "1b36a0ad92ded4607e0c1e0df5d5581d1c7afff5843cb75cd4c490790a86c413":
		return false
	for token in [
		"isle_house_low_facade_prototype.tscn",
		"isle_house_39_bruton_low_facade_prototype.gd",
		"IsleHouse39BrutonLowFacadePrototype",
		REJECTED_LIVE_ATTACHMENT_PATH,
		"IsleHouse39BrutonLowLiveAttachment",
	]:
		if token in builder:
			return false
	return builder.count(ACCEPTED_LIVE_ATTACHMENT_PATH) == 1 \
		and builder.count("ISLE_HOUSE_LOW_LIVE_ATTACHMENT.matches_record(record)") == 1 \
		and builder.count("ISLE_HOUSE_LOW_LIVE_ATTACHMENT.build(record)") == 1 \
		and "extends \"res://game/scripts/world/facades/isle_house_39_bruton_low_facade_prototype.gd\"" in rejected_adapter \
		and "class_name IsleHouseCompositeRepairVariantCLiveAttachment" in accepted_adapter \
		and "The rejected predecessor is neither called nor a fallback." in accepted_adapter \
		and REJECTED_LIVE_ATTACHMENT_PATH not in accepted_adapter \
		and REJECTED_LIVE_ATTACHMENT_PATH not in registry \
		and "active-adapter:isle-house-variant-c:building-composite:w1249412094:w1282547787:wall" in registry \
		and "\"runtime_content_mode\": \"active_isle_house_variant_c\"" in registry \
		and "\"receiver_key\": \"building-composite:w1249412094:w1282547787:wall\"" in registry


func _record_for_key(records: Array, object_key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == object_key:
			return record
	return {}


func _collect_motif_nodes(node: Node, output: Array[Node]) -> void:
	if node.has_meta("motif_id"):
		output.append(node)
	for child: Node in node.get_children():
		_collect_motif_nodes(child, output)


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _any_node_in_group(node: Node, group_name: StringName) -> bool:
	if node.is_in_group(group_name):
		return true
	for child: Node in node.get_children():
		if _any_node_in_group(child, group_name):
			return true
	return false


func _hashes_match(expected: Dictionary) -> bool:
	for path_value: Variant in expected:
		var path := str(path_value)
		if FileAccess.get_sha256(path) != str(expected[path_value]):
			return false
	return true


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
