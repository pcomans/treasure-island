extends SceneTree

const CALIBRATION_HELPER := preload("res://game/tests/support/w34313515_module_calibration.gd")
const FIELD_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const WORLD_CHUNK_BUILDER := preload("res://game/scripts/world/world_chunk_builder.gd")
const REGISTRY_PATH := "res://game/resources/facades/w34313515_module_calibration.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_1.json"
const RUN_MAPPING_PATH := "res://discovery/facades/BATCH_06_RUN_MAPPING.json"
const RECEIVER_KEY := "building:w34313515:wall"
const EXPECTED_PLACEMENTS := ["CAL-NNW-BAY-01", "CAL-NNW-BAY-02", "CAL-WSW-BAY-01", "CAL-WSW-BAY-02"]
const EXPECTED_PROTECTED_HASHES := {
	REGISTRY_PATH: "2d378a94da4b7badd334d5c00f926a26a4ff9109782abb18e4859301df4b5c1d",
	"res://game/tests/support/w34313515_module_calibration.gd": "1edfdf4b736a7b1cc2883569a4c09b48814cabf30e3056e9dac86152de22d5f1",
	CHUNK_PATH: "b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c",
	"res://discovery/facades/BATCH_06_STREETVIEW_OBSERVATIONS.md": "259e562e69b1186912fce2dfb466f4512fbc69cc8e64562574971c0a8c40028b",
	"res://discovery/facades/W34313515_REFERENCE_SPEC.md": "7b5da4a8a25d7f328f086ac0b7995323039f1e49e0335f1c121f854138606ace",
	RUN_MAPPING_PATH: "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d",
	"res://discovery/facades/BATCH_06_PROTOTYPE_SET_01_MODULE_CORRECTION_ART_REVIEW.md": "70f6a0e1e9ece07d162aa669aa89e4f4a9a8b19b1785eb7fb91efc0dc8f6aded",
	"res://discovery/facades/BATCH_06_EXACT_RECEIVER_FIELD_TRIALS_ART_REVIEW.md": "ce213c3fb37529eeaefe01da1b555b44b4ea58ab10b36b2150002b8edf6d2bb7",
	"res://game/resources/facades/batch_06_prototype_registry.json": "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132",
	"res://game/scripts/world/facades/batch_06_prototype_set.gd": "fecc656332599acefbf307ce6b5978e62c689ae146f713cf9d935ef66b81de60",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://game/resources/materials/world/w34313515/w34313515_pale_exact_trial.tres": "0b8704ccc352374adc1d6a553ff3d985ae2b70559d92b5171092450783b4395f",
	"res://game/resources/materials/world/w34313515/w34313515_frame.tres": "716afbdf12f55975747b08c615236462d335b62ca0c46730b4cb8439b9691aa5",
	"res://game/resources/materials/world/w34313515/w34313515_glass.tres": "963160407868064dcbb66b56cf477d0901f53a27351cbb23905474b5b613a4cc",
	"res://game/scripts/world/world_chunk_builder.gd": "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f",
	"res://game/scripts/world/facades/w34313564_live_modules.gd": "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee",
	"res://game/resources/facades/w34313564_module_calibration.json": "45a47d333c997887cef7d1c97a633d37ae050efda597186430c7af6d52116f0f",
	"res://evidence/first-playable/batch-06-exact-receiver-trials-2026-08-30/capture-manifest.json": "034b6ef3ad0e85b81a2565a9443172bec3da9364ed29ab5b4cc6b34258e72449",
	"res://discovery/facades/W34313515_BAY_CALIBRATION_ART_REVIEW.md": "894873141bc589e51bb8ec65e06455461e17a809a18608253db59c7e49e5fedd",
	"res://discovery/facades/W34313515_LIVE_MODULES_ART_REVIEW.md": "cebfe328ec5372f8c0d440fcf59bb0b9bae7a490998ed373d8f5c5e418b5b94e",
	"res://game/scripts/world/facades/w34313515_live_modules.gd": "4420ad2d0a029f03da7a14fe84084d53edfa2323867a5c660c63f875c2a71ccb",
}

var _failure := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(_protected_inputs_match(), "A protected observation, accepted field/module, generated, runtime, or detached calibration input changed."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var record := _load_record()
	if not _require(_registry_matches(registry, record), "Calibration classification, evidence, uncertainty, side, placement, or blocker contract failed.") \
	or not _require(_mapping_and_prototype_bounds_match(registry), "A BAY placement escaped its observed mapping or accepted motif-specific prototype bounds.") \
	or not _require(_active_field_is_immutable(registry), "The accepted WSW/NNW pale field or its exact four-module lifecycle metadata changed."):
		_finish()
		return
	var first_result := CALIBRATION_HELPER.build(record, registry)
	var second_result := CALIBRATION_HELPER.build(record, registry)
	if not _require(bool(first_result.get("ok", false)) and bool(second_result.get("ok", false)), "Detached BAY calibration failed to build deterministically."):
		_free_result(first_result)
		_free_result(second_result)
		_finish()
		return
	var first := first_result.node as Node3D
	var second := second_result.node as Node3D
	if not _require(JSON.stringify(first_result.resolved_placements) == JSON.stringify(second_result.resolved_placements), "Resolved placement transforms are nondeterministic.") \
	or not _require(_overlay_matches(first, registry, first_result.resolved_placements), "Detached BAY geometry, transform, completeness, bounds, or no-backing contract failed.") \
	or not _require(_runtime_receiver_matches_accepted_attachment(record), "The live w34313515 receiver does not preserve the exact reviewed BAY attachment and field state."):
		first.free()
		second.free()
		_finish()
		return
	first.free()
	second.free()
	print("PASS: the reviewed w34313515 detached module-atlas calibration still deterministically resolves exactly four complete BAY exemplars byte-for-byte on WSW runs 0/6 and NNW runs 44/47; those exact live rows are independently KEEP_WITH_DOCUMENTED_LIMITATION while the adapter preserves their explicit unsurveyed inference labels and runs 9..42, VRECESS, field ownership, generated bytes, collision, navigation, spray, completed-elevation, and whole-building blockers stay unchanged")
	_finish()


func _protected_inputs_match() -> bool:
	for path: String in EXPECTED_PROTECTED_HASHES:
		if FileAccess.get_sha256(path) != str(EXPECTED_PROTECTED_HASHES[path]):
			push_error("Protected input drifted: %s" % path)
			return false
	return true


func _registry_matches(registry: Dictionary, record: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.w34313515-controlled-module-calibration/1" \
	or str(registry.get("status", "")) != "controlled_zero_attachment_calibration_ready_for_independent_review" \
	or not "module-atlas" in str(registry.get("evidence_role", "")) \
	or not "not live attachment" in str(registry.get("evidence_role", "")):
		return false
	var target := registry.get("target", {}) as Dictionary
	if str(target.get("source_key", "")) != "w34313515" \
	or str(target.get("receiver_key", "")) != RECEIVER_KEY \
	or int(target.get("run_count", -1)) != 48 \
	or _int_array(target.get("accepted_field_runs", []) as Array) != [0, 1, 2, 3, 4, 5, 6, 7, 8, 43, 44, 45, 46, 47] \
	or _int_array(target.get("excluded_runs", []) as Array) != range(9, 43) \
	or record.get("source_keys", []) != ["w34313515"]:
		return false
	var contract := registry.get("module_contract", {}) as Dictionary
	if str(contract.get("motif_id", "")) != "W34313515-BAY" \
	or str(contract.get("asset_classification", "")) != "module_atlas" \
	or not bool(contract.get("complete_motif", false)) \
	or not bool(contract.get("module_not_seamless_tile", false)) \
	or bool(contract.get("module_owns_field_geometry", true)) \
	or str(contract.get("host_field_contract", "")) != "continuous_receiver_field_owns_all_nonopening_pixels" \
	or int(contract.get("tier_count", -1)) != 3 \
	or int(contract.get("pane_count_per_tier", -1)) != 3 \
	or contract.get("nominal_bounds_m", []) != [6.2, 10.2] \
	or contract.get("opening_per_tier_m", []) != [5.1, 1.72]:
		return false
	var policy := registry.get("placement_policy", {}) as Dictionary
	if str(policy.get("position_status", "")) != "stylized_reference_derived_production_inference_not_surveyed" \
	or str(policy.get("coordinate_status", "")) != "stylized_reference_derived_inference_not_surveyed" \
	or str(policy.get("cadence_status", "")) != "unknown_not_surveyed_not_inferred" \
	or not "not_surveyed_total" in str(policy.get("count_status", "")) \
	or int(policy.get("placement_count", -1)) != 4 \
	or bool(policy.get("runtime_attachment", true)) \
	or int(policy.get("collision_nodes", -1)) != 0 \
	or int(policy.get("navigation_nodes", -1)) != 0 \
	or int(policy.get("spray_nodes", -1)) != 0 \
	or float(policy.get("maximum_outward_depth_m", 1.0)) > 0.18:
		return false
	var expected_faces := {"WSW": [0, 1, 2, 3, 4, 5, 6, 7, 8], "NNW": [43, 44, 45, 46, 47]}
	for chain_value: Variant in registry.get("face_chains", []):
		var chain := chain_value as Dictionary
		var face := str(chain.get("face", ""))
		if not expected_faces.has(face) \
		or _int_array(chain.get("ordered_runs", []) as Array) != expected_faces[face] \
		or str(chain.get("evidence_status", "")) != "reference_observation" \
		or chain.get("eligible_motif_ids", []) != ["W34313515-BAY"]:
			return false
		expected_faces.erase(face)
	if not expected_faces.is_empty():
		return false
	var ids: Array[String] = []
	var face_counts := {"WSW": 0, "NNW": 0}
	for placement_value: Variant in registry.get("placements", []):
		var placement := placement_value as Dictionary
		var placement_id := str(placement.get("placement_id", ""))
		ids.append(placement_id)
		var face := str(placement.get("face", ""))
		face_counts[face] = int(face_counts.get(face, 0)) + 1
		if str(placement.get("motif_id", "")) != "W34313515-BAY" \
		or str(placement.get("evidence_status", "")) != "production_inference" \
		or str(placement.get("coordinate_status", "")) != "stylized_reference_derived_inference_not_surveyed" \
		or str(placement.get("cadence_status", "")) != "unknown_not_surveyed_not_inferred" \
		or str(placement.get("count_status", "")) != "bounded_exemplar_not_surveyed_total" \
		or _int_array(placement.get("run_ownership", []) as Array) != [int(placement.get("anchor_run", -1))]:
			return false
		var uncertainty := float(placement.get("center_chain_uncertainty_m", -1.0))
		var bounds := placement.get("center_chain_bounds_m", []) as Array
		var center := float(placement.get("center_chain_m", -1.0))
		var runs := _int_array(placement.get("exact_ordered_runs", []) as Array)
		var half_width := float((contract.nominal_bounds_m as Array)[0]) * 0.5
		if bounds.size() != 2 \
		or not is_equal_approx(float(bounds[0]), center - uncertainty) \
		or not is_equal_approx(float(bounds[1]), center + uncertainty):
			return false
		var lower_frame := CALIBRATION_HELPER.chain_frame(record, runs, center - uncertainty - half_width)
		var upper_frame := CALIBRATION_HELPER.chain_frame(record, runs, center + uncertainty + half_width)
		if lower_frame.is_empty() or upper_frame.is_empty() \
		or int(lower_frame.run_index) != int(placement.anchor_run) \
		or int(upper_frame.run_index) != int(placement.anchor_run):
			return false
	ids.sort()
	return ids == EXPECTED_PLACEMENTS and face_counts == {"WSW": 2, "NNW": 2} \
		and "W34313515-VRECESS remains reference-blocked" in JSON.stringify(registry.get("preserved_blockers", [])) \
		and (registry.get("excluded_regions", []) as Array).size() == 4


func _mapping_and_prototype_bounds_match(registry: Dictionary) -> bool:
	var mapping := JSON.parse_string(FileAccess.get_file_as_string(RUN_MAPPING_PATH)) as Dictionary
	var mapping_target := _target_for(mapping.get("targets", []) as Array, "w34313515")
	if mapping_target.is_empty() \
	or _int_array((mapping_target.get("partition", {}) as Dictionary).get("mapped_run_indices", []) as Array) != [0, 1, 2, 3, 4, 5, 6, 7, 8, 43, 44, 45, 46, 47]:
		return false
	var mappings := {}
	for value: Variant in mapping_target.get("mappings", []):
		var item := value as Dictionary
		mappings[str(item.mapping_id)] = item
	var prototype := JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/facades/batch_06_prototype_registry.json")) as Dictionary
	var prototype_target := _target_for(prototype.get("targets", []) as Array, "w34313515")
	if prototype_target.is_empty() or (prototype_target.get("modules", []) as Array).size() != 1:
		return false
	var module := (prototype_target.modules as Array)[0] as Dictionary
	if str(module.get("motif_id", "")) != "W34313515-BAY" \
	or str(module.get("kind", "")) != "complete_three_tier_horizontal_window_bay" \
	or bool(module.get("module_owns_field_geometry", true)) \
	or not bool(module.get("complete_motif", false)):
		return false
	var prototype_bounds := module.get("placement_bounds", []) as Array
	for placement_value: Variant in registry.get("placements", []):
		var placement := placement_value as Dictionary
		var mapping_id := str(placement.mapping_id)
		if not mappings.has(mapping_id):
			return false
		var mapped := mappings[mapping_id] as Dictionary
		if not bool(mapped.get("contiguous", false)) \
		or not int(placement.anchor_run) in _int_array(mapped.run_indices as Array) \
		or (mapped.get("observation_ids", []) as Array).is_empty():
			return false
		var legal_bound := "%s:runs_%d_%d" % [mapping_id, int((placement.exact_ordered_runs as Array)[0]), int((placement.exact_ordered_runs as Array)[-1])]
		if not legal_bound in prototype_bounds:
			return false
	return true


func _active_field_is_immutable(registry: Dictionary) -> bool:
	if not FIELD_TRIALS.BATCH_06_ACCEPTED_TARGETS.has(RECEIVER_KEY):
		return false
	var target := FIELD_TRIALS.BATCH_06_ACCEPTED_TARGETS[RECEIVER_KEY] as Dictionary
	var metadata := FIELD_TRIALS.metadata_for(RECEIVER_KEY)
	var role := registry.get("active_accepted_field", {}) as Dictionary
	if int(target.get("run_count", -1)) != 48 \
	or int(metadata.get("modules", -1)) != 4 \
	or int(metadata.get("standalone_modules_live", -1)) != 4 \
	or int(metadata.get("module_motif_types_live", -1)) != 1 \
	or str(metadata.get("module_placement_role", "")) != "stylized/reference-derived production inference" \
	or bool(metadata.get("module_cadence_inferred", true)) \
	or bool(metadata.get("module_total_opening_count_inferred", true)) \
	or str(metadata.get("status", "")) != FIELD_TRIALS.BATCH_06_ACCEPTED_STATUS \
	or (target.get("material_groups", []) as Array).size() != 1:
		return false
	var group := (target.material_groups as Array)[0] as Dictionary
	var flattened: Array[int] = []
	for run_group_value: Variant in group.run_groups:
		flattened.append_array(_int_array(run_group_value as Array))
	if flattened != _int_array(role.get("runs", []) as Array) \
	or str(group.id) != str(role.material_id) \
	or str(group.material_path) != str(role.material_path) \
	or FileAccess.get_sha256(str(group.material_path)) != str(role.material_sha256):
		return false
	var uncertainties := metadata.get("module_position_uncertainty_by_placement_m", {}) as Dictionary
	return uncertainties == {"CAL-WSW-BAY-01": 1.2, "CAL-WSW-BAY-02": 3.0, "CAL-NNW-BAY-01": 3.0, "CAL-NNW-BAY-02": 3.0}


func _overlay_matches(root_node: Node3D, registry: Dictionary, resolved_values: Array) -> bool:
	if not bool(root_node.get_meta("controlled_calibration", false)) \
	or bool(root_node.get_meta("runtime_attachment", true)) \
	or str(root_node.get_meta("asset_classification", "")) != "module_atlas" \
	or bool(root_node.get_meta("module_owns_field_geometry", true)) \
	or root_node.get_child_count() != 4 \
	or _count_type(root_node, CollisionObject3D) != 0 \
	or _count_type(root_node, CollisionShape3D) != 0 \
	or _count_type(root_node, NavigationRegion3D) != 0:
		return false
	var resolved := {}
	for value: Variant in resolved_values:
		var item := value as Dictionary
		resolved[str(item.placement_id)] = item
	for child: Node in root_node.get_children():
		var module := child as Node3D
		var placement_id := str(module.get_meta("placement_id", ""))
		var placement := _placement_for(registry, placement_id)
		if placement.is_empty() or not resolved.has(placement_id) \
		or module.get_child_count() != 21 \
		or str(module.get_meta("motif_id", "")) != "W34313515-BAY" \
		or not bool(module.get_meta("complete_motif", false)) \
		or not bool(module.get_meta("module_not_seamless_tile", false)) \
		or bool(module.get_meta("module_owns_field_geometry", true)) \
		or bool(module.get_meta("runtime_attachment", true)):
			return false
		var item := resolved[placement_id] as Dictionary
		var expected_xz := placement.expected_wall_anchor_world_xz_m as Array
		var wall_anchor := item.wall_anchor_world_m as Array
		if Vector2(float(wall_anchor[0]), float(wall_anchor[2])).distance_to(Vector2(float(expected_xz[0]), float(expected_xz[1]))) > 0.0015 \
		or _int_array(item.run_ownership as Array) != _int_array(placement.run_ownership as Array) \
		or absf(float(item.anchor_run_fraction) - float(placement.anchor_run_fraction)) > 0.00001:
			return false
		var tangent_values := item.tangent_world_xz as Array
		var normal_values := item.outward_normal_world_xz as Array
		var tangent := Vector3(float(tangent_values[0]), 0.0, float(tangent_values[1])).normalized()
		var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
		if module.transform.basis.x.dot(tangent) < 0.9999 \
		or module.transform.basis.y.dot(Vector3.UP) < 0.9999 \
		or module.transform.basis.z.dot(normal) < 0.9999:
			return false
		var minimum_world_y := INF
		var maximum_world_y := -INF
		var maximum_depth := 0.0
		for mesh_value: Node in module.get_children():
			if not (mesh_value is MeshInstance3D):
				return false
			var mesh_instance := mesh_value as MeshInstance3D
			var name_lower := str(mesh_instance.name).to_lower()
			if "field" in name_lower or "surround" in name_lower or "backing" in name_lower \
			or not (mesh_instance.mesh is BoxMesh):
				return false
			var size := (mesh_instance.mesh as BoxMesh).size
			minimum_world_y = minf(minimum_world_y, module.position.y + mesh_instance.position.y - size.y * 0.5)
			maximum_world_y = maxf(maximum_world_y, module.position.y + mesh_instance.position.y + size.y * 0.5)
			maximum_depth = maxf(maximum_depth, CALIBRATION_HELPER.WALL_OFFSET_M + mesh_instance.position.z + size.z * 0.5)
		if maximum_depth > float((registry.placement_policy as Dictionary).maximum_outward_depth_m) + 0.0001 \
		or maximum_world_y > float(item.top_y_m) + 0.0001 \
		or minimum_world_y < float(item.base_y_m) - 0.0001:
			return false
	return true


func _runtime_receiver_matches_accepted_attachment(record: Dictionary) -> bool:
	var builder := WORLD_CHUNK_BUILDER.new()
	var result := builder._build_record(record, false)
	if not bool(result.get("ok", false)):
		return false
	var node := result.node as Node3D
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var metadata := node.get_meta("accepted_material_run_trial", {}) as Dictionary
	var live_root := node.get_node_or_null("W34313515LiveModules") as Node3D
	var live_metadata := node.get_meta("w34313515_live_modules", {}) as Dictionary
	var ok := node.get_child_count() == 3 \
		and node.get_node_or_null("DetachedW34313515BayCalibration") == null \
		and live_root != null and live_root.get_child_count() == 4 \
		and mesh != null and mesh.get_surface_count() == 2 \
		and mesh.surface_get_name(0) == FIELD_TRIALS.PLACEHOLDER_SURFACE_NAME \
		and mesh.surface_get_name(1) == "trial_w34313515_pale_runs" \
		and body != null and shape_node != null \
		and int(result.get("mesh_instances", -1)) == 85 \
		and int(result.get("surfaces", -1)) == 86 \
		and int(result.get("triangles", -1)) == 1104 \
		and int(metadata.get("modules", -1)) == 4 \
		and int(metadata.get("standalone_modules_live", -1)) == 4 \
		and int(live_metadata.get("field_meshes", -1)) == 0 \
		and int(live_metadata.get("backing_meshes", -1)) == 0 \
		and int(live_metadata.get("collision_nodes", -1)) == 0 \
		and int(live_metadata.get("navigation_nodes", -1)) == 0 \
		and int(live_metadata.get("spray_nodes", -1)) == 0
	node.free()
	var builder_source := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	return ok and "w34313515_live_modules.gd" in builder_source \
		and not "CAL-WSW-BAY" in builder_source and not "CAL-NNW-BAY" in builder_source


func _load_record() -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	for record_value: Variant in chunk.get("records", []):
		var record := record_value as Dictionary
		if str(record.get("object_key", "")) == RECEIVER_KEY:
			return record
	return {}


func _target_for(values: Array, source_key: String) -> Dictionary:
	for value: Variant in values:
		var target := value as Dictionary
		if str(target.get("source_key", "")) == source_key:
			return target
	return {}


func _placement_for(registry: Dictionary, placement_id: String) -> Dictionary:
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		if str(placement.get("placement_id", "")) == placement_id:
			return placement
	return {}


func _free_result(result: Dictionary) -> void:
	if bool(result.get("ok", false)) and result.get("node") is Node:
		(result.node as Node).free()


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	if _failure.is_empty():
		_failure = message
	push_error("W34313515_MODULE_CALIBRATION_CONTRACT_FAIL: %s" % message)
	return false


func _finish() -> void:
	quit(0 if _failure.is_empty() else 1)
