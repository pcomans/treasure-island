extends SceneTree

const SCENE_PATH := "res://game/scenes/world/facades/isle_house/isle_house_composite_repair_standalone_v1.tscn"
const FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_standalone_v1.gd"
const CONFIG_PATH := "res://game/resources/facades/isle_house_composite_repair_standalone_v1.json"
const LANDSCAPE_PATH := "res://game/resources/materials/world/isle_house/isle_house_low_landscape_proxy.tres"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const LIVE_PATH := "res://game/scripts/world/facades/isle_house_39_bruton_low_live_attachment.gd"
const HIGH_PATH := "res://game/scripts/world/facades/isle_house_39_bruton_high_facade.gd"
const HIGH_SCENE_PATH := "res://game/scenes/world/facades/isle_house/isle_house_high_facade.tscn"
const HIGH_LAYOUT_PATH := "res://game/resources/facades/isle_house_39_bruton_high_se_layout.json"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const EXPECTED_CONFIG_SHA256 := "a3e1865d18cfbb4155cf01df3b5eb265ca67e4ee80acfc07986c84d0cd7db393"
const EXPECTED_LANDSCAPE_SHA256 := "534cb523b48639e87ec365b120b793a6ddca819e4b09ae590a592fc63d1a010f"
const EXPECTED_LIVE_SHA256 := "1b36a0ad92ded4607e0c1e0df5d5581d1c7afff5843cb75cd4c490790a86c413"
const EXPECTED_HIGH_SHA256 := "f8243cedd3f331cbc37e6343b1b48e76a73a81644c96cc1f80e623e0c71a3113"
const EXPECTED_HIGH_SCENE_SHA256 := "7ff4a91c402cecea19d2686d29139d2c0f139673b06d21c67d1c14835fd31d12"
const EXPECTED_HIGH_LAYOUT_SHA256 := "c5e6393e90152cef62f6478d7bd87750f3db5598d6ebc36cd307ce20acaa090d"
const EXPECTED_REPAIR_SIGNATURE := "a58d9b963b0dc19b5a9fa1cba4872294a2ea2803459a9ba455e276dc1ff5b5bf"
const EXPECTED_VARIANT_A_TOPOLOGY := {"mesh_instances": 15, "surfaces": 16, "triangles": 13903}
const EXPECTED_VARIANT_B_TOPOLOGY := {"mesh_instances": 16, "surfaces": 19, "triangles": 14375}
const EXPECTED_REPAIR_TOPOLOGY := {"mesh_instances": 6, "surfaces": 8, "triangles": 2316}

var _failure := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	var chunk_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	_require(config_value is Dictionary and chunk_value is Dictionary, "Standalone config or exact chunk could not be parsed.")
	if not _failure.is_empty():
		_finish()
		return
	var config := config_value as Dictionary
	var chunk := chunk_value as Dictionary
	_require(IsleHouseCompositeRepairStandaloneV1.validate_config_dictionary(config), "Canonical standalone config failed complete semantic validation.")
	_test_config_mutations(config)
	_require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256, "Standalone config bytes drifted.")
	_require(FileAccess.get_sha256(LANDSCAPE_PATH) == EXPECTED_LANDSCAPE_SHA256, "Standalone landscape proxy material drifted.")
	_require(FileAccess.get_sha256(LIVE_PATH) == EXPECTED_LIVE_SHA256, "Sealed failed live parent drifted.")
	_require(FileAccess.get_sha256(HIGH_PATH) == EXPECTED_HIGH_SHA256, "Accepted high factory drifted.")
	_require(FileAccess.get_sha256(HIGH_SCENE_PATH) == EXPECTED_HIGH_SCENE_SHA256, "Accepted high scene drifted.")
	_require(FileAccess.get_sha256(HIGH_LAYOUT_PATH) == EXPECTED_HIGH_LAYOUT_SHA256, "Accepted high layout drifted.")
	_require("isle_house_composite_repair_standalone_v1.tscn" not in FileAccess.get_file_as_string(BUILDER_PATH), "Historical standalone A/B scene was wired directly into world construction.")
	_require(_runtime_files_are_package_clean(), "Standalone runtime files contain a source/evidence path, URL, or absolute workstation path.")

	var first := _fresh_instance()
	var second := _fresh_instance()
	_require(bool(first.get("ok", false)) and bool(second.get("ok", false)), "Two fresh standalone composites did not configure cleanly: %s / %s" % [first, second])
	if not bool(first.get("ok", false)) or not bool(second.get("ok", false)):
		_free_instance(first)
		_free_instance(second)
		_finish()
		return
	var first_node := first.node as IsleHouseCompositeRepairStandaloneV1
	var second_node := second.node as IsleHouseCompositeRepairStandaloneV1
	var first_result := first.result as Dictionary
	var second_result := second.result as Dictionary
	_require(str(first_result.get("repair_signature", "")) == str(second_result.get("repair_signature", "")), "Repair signatures differ across fresh builds.")
	_require(first_result.get("variant_a_topology", {}) == second_result.get("variant_a_topology", {}), "Variant A topology differs across fresh builds.")
	_require(first_result.get("variant_b_topology", {}) == second_result.get("variant_b_topology", {}), "Variant B topology differs across fresh builds.")
	print("ISLE_COMPOSITE_REPAIR_MEASURE: repair_signature=%s variant_a=%s variant_b=%s repair=%s boxes=%s" % [
		str(first_result.get("repair_signature", "")),
		str(first_result.get("variant_a_topology", {})),
		str(first_result.get("variant_b_topology", {})),
		str((first_node.get_node("VariantB_StandaloneRepair/RepairLowOverlay") as Node3D).get_meta("topology", {})),
		str((first_node.get_node("VariantB_StandaloneRepair/RepairLowOverlay") as Node3D).get_meta("module_box_counts", {})),
	])
	_require(str(first_result.get("repair_signature", "")) == EXPECTED_REPAIR_SIGNATURE, "Repair output signature drifted.")
	_require(first_result.get("variant_a_topology", {}) == EXPECTED_VARIANT_A_TOPOLOGY, "Variant A exact topology drifted.")
	_require(first_result.get("variant_b_topology", {}) == EXPECTED_VARIANT_B_TOPOLOGY, "Variant B exact topology drifted.")
	var repair := first_node.get_node("VariantB_StandaloneRepair/RepairLowOverlay") as Node3D
	_require(repair.get_meta("topology", {}) == EXPECTED_REPAIR_TOPOLOGY, "Repair-only exact topology drifted.")
	_validate_branches(first_node, repair, chunk)
	_validate_material_uv_and_bands(repair)
	_validate_modules(repair)
	_validate_zero_ownership(repair)
	_validate_bounds(repair)
	_require(first_node.set_variant("failed_parent") and first_node.get_node("VariantA_FailedLiveParent").visible and not first_node.get_node("VariantB_StandaloneRepair").visible, "A/B visibility switch did not select failed parent.")
	_require(first_node.set_variant("repair") and not first_node.get_node("VariantA_FailedLiveParent").visible and first_node.get_node("VariantB_StandaloneRepair").visible, "A/B visibility switch did not select repair.")
	_require(not first_node.set_variant("unknown"), "A/B visibility switch accepted an unknown variant.")

	var drifted_chunk := (chunk_value as Dictionary).duplicate(true)
	var drifted_records := drifted_chunk.get("records", []) as Array
	for record_value: Variant in drifted_records:
		var record := record_value as Dictionary
		if str(record.get("object_key", "")) == LOW_WALL_KEY:
			var drifted_vertices := (record.get("vertices", []) as Array).duplicate()
			drifted_vertices[0] = float(drifted_vertices[0]) + 0.01
			record["vertices"] = drifted_vertices
			break
	var drifted := _instance_from_records(drifted_records)
	_require(not bool(drifted.get("ok", true)) and str(drifted.get("code", "")) == "standalone_records", "Standalone factory did not fail closed on 0.01 m low geometry drift.")
	_free_instance(drifted)

	var detached := second_node.detach_repair_overlay_for_preview()
	_require(detached != null and detached.get_parent() == null and second_node.get_node_or_null("VariantB_StandaloneRepair/RepairLowOverlay") == null, "Preview seam did not detach exactly the candidate low overlay.")
	if detached != null:
		detached.free()
	first_node.free()
	second_node.free()
	if _failure.is_empty():
		print("PASS: isolated Isle House full-composite A/B reproduces the sealed failed live parent, preserves the accepted high and exact part geometry, adds only a public homogeneous podium transition plus four honestly inferred low module arrangements, and remains package-clean, topology-deterministic, render-only, unpromoted, and pending independent review")
	_finish()


func _test_config_mutations(config: Dictionary) -> void:
	var accepted := config.duplicate(true)
	(accepted.get("truth_boundary", {}) as Dictionary)["recognition_accepted"] = true
	_require(not IsleHouseCompositeRepairStandaloneV1.validate_config_dictionary(accepted), "Config validator accepted recognition self-promotion.")
	var upper_schedule := config.duplicate(true)
	((upper_schedule.get("render_contract", {}) as Dictionary).get("upper_transition", {}) as Dictionary)["blocked_expression"] = "candidate windows allowed"
	_require(not IsleHouseCompositeRepairStandaloneV1.validate_config_dictionary(upper_schedule), "Config validator accepted an unsupported upper schedule.")
	var protected_module := config.duplicate(true)
	var protected_placement := ((protected_module.get("placements", []) as Array)[0] as Dictionary)
	protected_placement["run_index"] = 10
	protected_placement["side_id"] = "LOW-NNW-PROTECTED"
	_require(not IsleHouseCompositeRepairStandaloneV1.validate_config_dictionary(protected_module), "Config validator accepted an NNW module.")
	var false_observation := config.duplicate(true)
	(false_observation.get("module_family", {}) as Dictionary)["sequence_truth_class"] = "reference_observation"
	_require(not IsleHouseCompositeRepairStandaloneV1.validate_config_dictionary(false_observation), "Config validator accepted inferred sequence as observed.")
	var source_url := config.duplicate(true)
	(source_url.get("provenance", []) as Array).append({"id": "bad", "url": "https://invalid.example"})
	_require(not IsleHouseCompositeRepairStandaloneV1.validate_config_dictionary(source_url), "Config validator accepted a runtime URL.")


func _fresh_instance() -> Dictionary:
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		return {"ok": false, "message": "Standalone scene could not load."}
	var node := packed.instantiate() as IsleHouseCompositeRepairStandaloneV1
	var result := node.configure_from_chunk()
	if not bool(result.get("ok", false)):
		node.free()
		return result
	return {"ok": true, "node": node, "result": result}


func _instance_from_records(records: Array) -> Dictionary:
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		return {"ok": false, "message": "Standalone scene could not load."}
	var node := packed.instantiate() as IsleHouseCompositeRepairStandaloneV1
	var result := node.configure(
		_record_for_key(records, "building-composite:w1249412094:w1282547786:wall"),
		_record_for_key(records, "building-composite:w1249412094:w1282547786:roof"),
		_record_for_key(records, LOW_WALL_KEY),
		_record_for_key(records, "building-composite:w1249412094:w1282547787:roof")
	)
	if bool(result.get("ok", false)):
		return {"ok": true, "node": node, "result": result}
	node.free()
	return result


func _validate_branches(node: Node3D, repair: Node3D, chunk: Dictionary) -> void:
	var a := node.get_node("VariantA_FailedLiveParent") as Node3D
	var b := node.get_node("VariantB_StandaloneRepair") as Node3D
	var failed := a.get_node_or_null("FailedLiveParentLowOverlay") as Node3D
	var high_a := a.get_node_or_null("AcceptedHighFacade") as Node3D
	var high_b := b.get_node_or_null("AcceptedHighFacade") as Node3D
	_require(failed != null and str(failed.get_meta("live_deterministic_signature", "")) == "5d61ab90e5b798ac4aa26c45fea37a5293f3083dada615f06999faad459112cc", "Variant A did not reproduce the sealed failed live output.")
	_require(high_a != null and high_b != null and str(high_a.get_meta("deterministic_signature", "")) == "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1" and str(high_b.get_meta("deterministic_signature", "")) == str(high_a.get_meta("deterministic_signature", "")), "Accepted high output differs between A and B.")
	_require(not bool(repair.get_meta("runtime_attachment", true)) and not bool(repair.get_meta("live_replacement", true)) and not bool(repair.get_meta("recognition_accepted", true)) and not bool(repair.get_meta("believability_accepted", true)) and not bool(repair.get_meta("as_built_fidelity", true)), "Repair truth boundary self-promoted.")
	var records := chunk.get("records", []) as Array
	for branch: Node3D in [a, b]:
		for pair: Array in [
			["ExactHighWall", "building-composite:w1249412094:w1282547786:wall"],
			["ExactHighRoof", "building-composite:w1249412094:w1282547786:roof"],
			["ExactLowWall", LOW_WALL_KEY],
			["ExactLowRoof", "building-composite:w1249412094:w1282547787:roof"],
		]:
			var instance := branch.get_node(str(pair[0])) as MeshInstance3D
			var record := _record_for_key(records, str(pair[1]))
			var arrays := instance.mesh.surface_get_arrays(0) as Array
			_require((arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() * 3 == (record.get("vertices", []) as Array).size(), "%s standalone footprint vertex count drifted." % str(pair[0]))
			_require((arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() == (record.get("indices", []) as Array).size(), "%s standalone topology drifted." % str(pair[0]))


func _validate_material_uv_and_bands(repair: Node3D) -> void:
	var fields := repair.get_node_or_null("PublicLowFieldAndPodiumTransition_Runs_0_9") as MeshInstance3D
	_require(fields != null and fields.mesh.get_surface_count() == 3 and fields.get_meta("public_run_indices", []) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] and fields.get_meta("protected_run_indices", []) == [10, 11, 12], "Candidate field scope or three-part transition surface drifted.")
	if fields == null:
		return
	var brick := fields.mesh.surface_get_material(0) as StandardMaterial3D
	_require(brick != null and brick.albedo_texture != null and brick.albedo_texture.resource_path == "res://game/resources/textures/world/facade_shared_v1/muted_brown_red_brick_albedo_v1.png" and brick.uv1_scale == Vector3(0.4, 0.4, 1.0) and brick.albedo_color == Color(0.70, 0.66, 0.62, 1.0) and is_equal_approx(brick.roughness, 0.86), "Promoted 2.5 m brick material contract drifted.")
	_require((fields.get_meta("uv_contract", {}) as Dictionary).get("contract_version", "") == "ti.facade-meter-uv/1", "Candidate lost the continuous metre-UV contract.")
	var expected_ranges := [Vector2(3.98, 10.25), Vector2(10.25, 18.58), Vector2(18.58, 19.103)]
	for surface_index in 3:
		var arrays := fields.mesh.surface_get_arrays(surface_index) as Array
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var min_y := INF
		var max_y := -INF
		for vertex: Vector3 in vertices:
			min_y = minf(min_y, vertex.y)
			max_y = maxf(max_y, vertex.y)
		_require(absf(min_y - expected_ranges[surface_index].x) <= (0.15 if surface_index == 0 else 0.0002) and absf(max_y - expected_ranges[surface_index].y) <= 0.0002, "Candidate surface %d left its bounded Y band: %.4f..%.4f." % [surface_index, min_y, max_y])
	_require(not bool(fields.get_meta("upper_schedule_claimed", true)) and not bool(fields.get_meta("literal_seven_story_geometry_claimed", true)), "Upper field incorrectly claims a schedule or literal seven-story correction.")


func _validate_modules(repair: Node3D) -> void:
	var counts: Dictionary = {}
	var modules := 0
	for child: Node in repair.get_children():
		if child.has_meta("variant_id"):
			modules += 1
			var variant_id := str(child.get_meta("variant_id", ""))
			counts[variant_id] = int(counts.get(variant_id, 0)) + 1
			_require(int(child.get_meta("run_index", -1)) in [2, 3, 8, 9], "Candidate module escaped mapped long public runs.")
			_require("mirroring" in (child.get_meta("production_inferences", []) as Array) and str(child.get_meta("truth_class", "")) == "reference_supported_family_with_inferred_arrangement_dimensions_sequence", "Candidate module obscured its inference boundary.")
	_require(modules == 8 and counts == {"ENTRY-GALLERY": 2, "HALF-DOOR-LEFT": 2, "HALF-DOOR-RIGHT": 2, "PATIO-GLAZING": 2}, "Candidate did not produce the four-by-two deterministic variant family: %s." % counts)
	_require(int(repair.get_meta("module_variant_count", 0)) == 4 and int(repair.get_meta("module_count", 0)) == 8 and int(repair.get_meta("module_box_count", 0)) > 152, "Candidate did not replace the eight stamped modules with a richer bounded family.")


func _validate_zero_ownership(repair: Node3D) -> void:
	_require(_count_type(repair, CollisionObject3D) == 0 and _count_type(repair, CollisionShape3D) == 0 and _count_type(repair, NavigationRegion3D) == 0 and not _any_node_in_group(repair, "spray_receiver") and not _any_node_in_group(repair, "spray_receiver_wall"), "Candidate decorative geometry acquired collision/navigation/spray ownership.")


func _validate_bounds(repair: Node3D) -> void:
	# Headless MultiMesh transform readback is not reliable on every renderer;
	# the factory validates each authored box before batching and seals aggregate
	# bounds in metadata instead.
	var min_y := float(repair.get_meta("module_min_y_m", -INF))
	var max_y := float(repair.get_meta("module_max_y_m", INF))
	_require(min_y >= 3.9799 and max_y <= 10.2501 and is_equal_approx(max_y, 10.20), "Candidate authored module bounds escaped the live-work band: %.4f..%.4f." % [min_y, max_y])


func _runtime_files_are_package_clean() -> bool:
	for path: String in [FACTORY_PATH, CONFIG_PATH, SCENE_PATH, LANDSCAPE_PATH]:
		var text := FileAccess.get_file_as_string(path).to_lower()
		for forbidden: String in ["res://discovery/", "res://evidence/", "http://", "https://", "file://", "/volumes/", "/users/"]:
			if forbidden in text:
				return false
	return true


func _record_for_key(records: Array, object_key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == object_key:
			return record
	return {}


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


func _free_instance(result: Dictionary) -> void:
	var node := result.get("node", null) as Node
	if node != null and is_instance_valid(node):
		node.free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	if _failure.is_empty():
		_failure = message
	push_error("FAIL [headless_isle_house_composite_repair_standalone_v1_contract]: %s" % message)
	return false


func _finish() -> void:
	quit(1 if not _failure.is_empty() else 0)
