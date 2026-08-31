extends SceneTree

const CALIBRATION_HELPER := preload("res://game/tests/support/w34313564_module_calibration.gd")
const FIELD_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const LIVE_MODULES := preload("res://game/scripts/world/facades/w34313564_live_modules.gd")
const REGISTRY_PATH := "res://game/resources/facades/w34313564_module_calibration.json"
const HELPER_PATH := "res://game/tests/support/w34313564_module_calibration.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-3.json"
const RUN_MAPPING_PATH := "res://discovery/facades/BATCH_06_RUN_MAPPING.json"
const RECEIVER_KEY := "building:w34313564:wall"
const EXPECTED_REGISTRY_SHA256 := "45a47d333c997887cef7d1c97a633d37ae050efda597186430c7af6d52116f0f"
const EXPECTED_HELPER_SHA256 := "b49b8c20fbbe40f2728c0acadf8d53f0593856091e6df897a613d4f2f8680b71"
const EXPECTED_PLACEMENTS := ["CAL-SSE-PDOOR-01", "CAL-SSE-HWIN-01", "CAL-ENE-HWIN-01", "CAL-NNW-PDOOR-01", "CAL-NNW-HWIN-01"]
const EXPECTED_PROTECTED_HASHES := {
	"res://discovery/facades/BATCH_06_STREETVIEW_OBSERVATIONS.md": "259e562e69b1186912fce2dfb466f4512fbc69cc8e64562574971c0a8c40028b",
	"res://discovery/facades/W34313564_REFERENCE_SPEC.md": "3b3cf3e330ab4848335d0f12729291a4d77d26806160920c2733a120b6c12e70",
	RUN_MAPPING_PATH: "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d",
	"res://discovery/facades/BATCH_06_PROTOTYPE_SET_01_ART_REVIEW.md": "bfaccbf182fb04222b5a65356f3287bd7823f5b692d0da6d2d44b2e2af5599eb",
	"res://discovery/facades/BATCH_06_PROTOTYPE_SET_01_MODULE_CORRECTION_ART_REVIEW.md": "70f6a0e1e9ece07d162aa669aa89e4f4a9a8b19b1785eb7fb91efc0dc8f6aded",
	"res://discovery/facades/W34313564_EXACT_MODULE_CALIBRATION_ART_REVIEW.md": "3c5a8e9c22966c443203e900e0a0762c848eb33d4373c9d8f76b74b1a7dc0735",
	"res://evidence/first-playable/batch-06-w34313564-module-calibration-2026-08-30/capture-manifest.json": "c664d7e0cae794f9d5be979af89c40a4f65096b29b7f2b14e8032271c2209221",
	"res://game/resources/facades/batch_06_prototype_registry.json": "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132",
	"res://game/scripts/world/facades/batch_06_prototype_set.gd": "fecc656332599acefbf307ce6b5978e62c689ae146f713cf9d935ef66b81de60",
	# Current promoted runtime helper. The exact-receiver capture manifest below
	# remains the immutable pre-promotion evidence identity.
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://game/scripts/world/facades/w34313564_live_modules.gd": "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee",
	"res://discovery/facades/W34313564_MODULE_CALIBRATION_CORRECTION_ART_REVIEW.md": "a8f1396e2d126c0c38b37edf770df975c4fa95e25e34fb2c7c1e766630fd1591",
	"res://evidence/first-playable/batch-06-exact-receiver-trials-2026-08-30/capture-manifest.json": "034b6ef3ad0e85b81a2565a9443172bec3da9364ed29ab5b4cc6b34258e72449",
	CHUNK_PATH: "6dfa4b8f4b91f309b313428829e37cedd13e4067ff94f896a8e2e5ef05002a1d",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://game/scripts/world/world_chunk_builder.gd": "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42",
	"res://game/resources/materials/world/w34313564/w34313564_tan_field.tres": "2503ee946804bd16db9ca60ae05a0a1b9b6ca7c46422e0997ac2891c79a7ea76",
	"res://game/resources/materials/world/w34313564/w34313564_pale_field.tres": "4523c071e50875db052e98ac39b9d9eff9cfb487aa37344064834ae82c0aae83",
	"res://game/resources/materials/world/w34313564/w34313564_plinth_field.tres": "89a36e7fb036bf8bd3f5db0996076c477641e2c7e97d29537c2c464155b12d88",
	"res://game/resources/materials/world/w34313564/w34313564_tan_exact_trial.tres": "3b895743b247a20641cb7564004d2f890bacfc286feaec9044b334b5e8e170bb",
	"res://game/resources/materials/world/w34313564/w34313564_pale_exact_trial.tres": "c7ec2df12b0dcf41e2b5019fd98155dbe3668d16379070210fe9f97ef032a343",
	"res://game/resources/materials/world/w34313564/w34313564_frame.tres": "5487fa17415e4022d85b82e3f013ac9a41be1dd07d88354f1caf4b05a9ab5994",
	"res://game/resources/materials/world/w34313564/w34313564_glass.tres": "0f5b2ac833346143e777b81e85079f4502ca5a2692944228a9fbfeff28ddd669",
	"res://game/resources/materials/world/w34313564/w34313564_door.tres": "88babf9bdceb46e8475f6d1acf1853ac451433c91f1264ca70c41d8c19d2aa3d",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Calibration registry bytes drifted.") \
	or not _require(FileAccess.get_sha256(HELPER_PATH) == EXPECTED_HELPER_SHA256, "Detached calibration helper bytes drifted.") \
	or not _require(_protected_inputs_match(), "A protected observation, accepted field/module, exact-trial, generated, or runtime input changed."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var record := _load_record()
	if not _require(_registry_matches(registry, record), "Calibration provenance, observed-face, uncertainty, run, host-role, or blocker contract failed.") \
	or not _require(_active_accepted_fields_are_immutable(registry), "The active accepted exact-run fields or approved live-module metadata changed.") \
	or not _require(_mapping_matches(registry), "A calibration face or placement escaped its observed mapped run chain.") \
	or not _require(_motif_specific_bounds_match(registry), "A calibration placement escaped its predeclared motif-specific run bounds.") \
	or not _require(_predecessor_delta_matches(registry), "The correction changed more than the one authorized SSE door placement."):
		_finish()
		return
	var first_result := CALIBRATION_HELPER.build(record, registry)
	var second_result := CALIBRATION_HELPER.build(record, registry)
	if not _require(bool(first_result.get("ok", false)) and bool(second_result.get("ok", false)), "Detached calibration failed to build deterministically."):
		_free_result(first_result)
		_free_result(second_result)
		_finish()
		return
	var first := first_result.node as Node3D
	var second := second_result.node as Node3D
	if not _require(JSON.stringify(first_result.resolved_placements) == JSON.stringify(second_result.resolved_placements), "Resolved placement transforms are nondeterministic.") \
	or not _require(_overlay_matches(first, registry, first_result.resolved_placements), "Detached module geometry, transform, height, depth, completeness, or no-backing contract failed.") \
	or not _require(_runtime_receiver_matches_approved_live_modules(record), "The runtime receiver does not contain exactly the five approved render-only module instances over the unchanged generated wall/collision."):
		first.free()
		second.free()
		_finish()
		return
	first.free()
	second.free()
	print("PASS: corrected w34313564 detached calibration remains byte-identical and deterministic while its exact 3 HWIN + 2 PDOOR placements are now attached live on runs 7/8/12/16/17 as stylized/reference-derived production inference; both accepted host fields remain immutable, and field backing/collision/navigation/spray/cadence/count claims remain zero")
	_finish()


func _protected_inputs_match() -> bool:
	for path: String in EXPECTED_PROTECTED_HASHES:
		if FileAccess.get_sha256(path) != str(EXPECTED_PROTECTED_HASHES[path]):
			push_error("Protected input drifted: %s" % path)
			return false
	return true


func _registry_matches(registry: Dictionary, record: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.w34313564-controlled-module-calibration/1" \
	or str(registry.get("status", "")) != "controlled_zero_attachment_calibration_corrected_ready_for_independent_review" \
	or not "not live attachment" in str(registry.get("evidence_role", "")):
		push_error("registry-stage: header")
		return false
	var target := registry.get("target", {}) as Dictionary
	if str(target.get("source_key", "")) != "w34313564" \
	or str(target.get("receiver_key", "")) != RECEIVER_KEY \
	or int(target.get("run_count", -1)) != 20 \
	or _int_array(target.get("placeholder_or_protected_runs", []) as Array) != [0, 1, 2, 3, 4] \
	or _int_array(target.get("nonexistent_forbidden_indices", []) as Array) != [20] \
	or record.get("source_keys", []) != ["w34313564"]:
		push_error("registry-stage: target source=%s receiver=%s count=%s placeholder=%s nonexistent=%s record_sources=%s" % [target.get("source_key"), target.get("receiver_key"), target.get("run_count"), target.get("placeholder_or_protected_runs"), target.get("nonexistent_forbidden_indices"), record.get("source_keys")])
		return false
	var policy := registry.get("placement_policy", {}) as Dictionary
	if str(policy.get("position_status", "")) != "production_inference_for_calibration_only_not_observed_coordinate" \
	or str(policy.get("cadence_status", "")) != "no_period_or_global_sequence_inferred" \
	or int(policy.get("placement_count", -1)) != 5 \
	or bool(policy.get("runtime_attachment", true)) \
	or int(policy.get("collision_nodes", -1)) != 0 \
	or int(policy.get("navigation_nodes", -1)) != 0 \
	or int(policy.get("spray_nodes", -1)) != 0 \
	or float(policy.get("maximum_outward_depth_m", 1.0)) > 0.18:
		push_error("registry-stage: policy")
		return false
	var contracts := registry.get("module_contracts", []) as Array
	if contracts.size() != 2:
		push_error("registry-stage: contract-count")
		return false
	for contract_value: Variant in contracts:
		var contract := contract_value as Dictionary
		if not bool(contract.get("complete_motif", false)) \
		or bool(contract.get("module_owns_field_geometry", true)) \
		or str(contract.get("host_field_contract", "")) != "continuous_receiver_field_owns_all_nonopening_pixels" \
		or (contract.get("nominal_bounds_m", []) as Array).size() != 2 \
		or (contract.get("opening_m", []) as Array).size() != 2:
			push_error("registry-stage: contract %s" % str(contract.get("motif_id", "")))
			return false
	var ids: Array[String] = []
	var motif_counts := {"W34313564-HWIN": 0, "W34313564-PDOOR": 0}
	var host_motifs := {}
	for placement_value: Variant in registry.get("placements", []):
		var placement := placement_value as Dictionary
		var placement_id := str(placement.get("placement_id", ""))
		var motif_id := str(placement.get("motif_id", ""))
		ids.append(placement_id)
		motif_counts[motif_id] = int(motif_counts.get(motif_id, 0)) + 1
		host_motifs["%s:%s" % [str(placement.get("host_material_id", "")), motif_id]] = true
		var run_ownership := _int_array(placement.get("run_ownership", []) as Array)
		if run_ownership.size() != 1 or run_ownership[0] < 5 or run_ownership[0] >= 20 \
		or int(placement.get("anchor_run", -1)) != run_ownership[0] \
		or float(placement.get("center_chain_uncertainty_m", 0.0)) != 4.0:
			push_error("registry-stage: placement-base %s" % placement_id)
			return false
		var contract := _contract_for(registry, motif_id)
		var nominal_width := float((contract.nominal_bounds_m as Array)[0])
		var lower := float(placement.center_chain_m) - 4.0 - nominal_width * 0.5
		var upper := float(placement.center_chain_m) + 4.0 + nominal_width * 0.5
		var runs := _int_array(placement.face_chain_runs as Array)
		var lower_frame := CALIBRATION_HELPER.chain_frame(record, runs, lower)
		var upper_frame := CALIBRATION_HELPER.chain_frame(record, runs, upper)
		if lower_frame.is_empty() or upper_frame.is_empty() \
		or int(lower_frame.run_index) != run_ownership[0] \
		or int(upper_frame.run_index) != run_ownership[0]:
			push_error("registry-stage: uncertainty-span %s lower=%s upper=%s owner=%s" % [placement_id, lower_frame, upper_frame, run_ownership])
			return false
	ids.sort()
	var corrected_door := _placement_for(registry, "CAL-SSE-PDOOR-01")
	if str(corrected_door.get("mapping_id", "")) != "B06-34313564-SSE-CENTRAL" \
	or int(corrected_door.get("anchor_run", -1)) != 7 \
	or _int_array(corrected_door.get("run_ownership", []) as Array) != [7] \
	or not is_equal_approx(float(corrected_door.get("center_chain_m", -1.0)), 47.5) \
	or not is_equal_approx(float(corrected_door.get("center_chain_uncertainty_m", -1.0)), 4.0) \
	or str(corrected_door.get("placement_role", "")) != "stylized/reference-derived production inference":
		push_error("registry-stage: corrected SSE door semantics")
		return false
	var corrected_xz := corrected_door.get("expected_wall_anchor_world_xz_m", []) as Array
	if corrected_xz.size() != 2 \
	or Vector2(float(corrected_xz[0]), float(corrected_xz[1])).distance_to(Vector2(55.858936, -612.345596)) > 0.00001:
		push_error("registry-stage: corrected SSE door anchor")
		return false
	var expected := EXPECTED_PLACEMENTS.duplicate()
	expected.sort()
	var result := ids == expected \
		and motif_counts == {"W34313564-HWIN": 3, "W34313564-PDOOR": 2} \
		and host_motifs.has("W34313564-MAT-TAN:W34313564-HWIN") \
		and host_motifs.has("W34313564-MAT-TAN:W34313564-PDOOR") \
		and host_motifs.has("W34313564-MAT-PALE:W34313564-HWIN") \
		and host_motifs.has("W34313564-MAT-PALE:W34313564-PDOOR") \
		and "exact real-world opening coordinates" in JSON.stringify(registry.get("preserved_blockers", []))
	if not result:
		push_error("registry-stage: final ids=%s expected=%s counts=%s hosts=%s blockers=%s" % [ids, expected, motif_counts, host_motifs, registry.get("preserved_blockers", [])])
	return result


func _active_accepted_fields_are_immutable(registry: Dictionary) -> bool:
	if not FIELD_TRIALS.BATCH_06_ACCEPTED_TARGETS.has(RECEIVER_KEY):
		return false
	var target := FIELD_TRIALS.BATCH_06_ACCEPTED_TARGETS[RECEIVER_KEY] as Dictionary
	if int(target.get("run_count", -1)) != 20 \
	or int(FIELD_TRIALS.metadata_for(RECEIVER_KEY).get("modules", -1)) != 5 \
	or int(FIELD_TRIALS.metadata_for(RECEIVER_KEY).get("standalone_modules_live", -1)) != 5 \
	or str(FIELD_TRIALS.metadata_for(RECEIVER_KEY).get("module_placement_role", "")) != LIVE_MODULES.PLACEMENT_ROLE \
	or str(FIELD_TRIALS.metadata_for(RECEIVER_KEY).get("status", "")) != FIELD_TRIALS.BATCH_06_ACCEPTED_STATUS:
		return false
	var registry_roles := registry.get("active_field_trial_roles", []) as Array
	var target_groups := target.get("material_groups", []) as Array
	if registry_roles.size() != 2 or target_groups.size() != 2:
		return false
	for role_value: Variant in registry_roles:
		var role := role_value as Dictionary
		var matched := false
		for group_value: Variant in target_groups:
			var group := group_value as Dictionary
			var flattened: Array[int] = []
			for run_group_value: Variant in group.run_groups:
				flattened.append_array(_int_array(run_group_value as Array))
			if str(role.material_id) == str(group.id) \
			and _int_array(role.runs as Array) == flattened \
			and str(role.material_path) == str(group.material_path) \
			and FileAccess.get_sha256(str(role.material_path)) == str(role.material_sha256):
				matched = true
				break
		if not matched:
			return false
	var helper_source := FileAccess.get_file_as_string("res://game/scripts/world/facades/accepted_material_run_trials.gd")
	return not "w34313564_module_calibration" in helper_source \
		and not "CAL-SSE-PDOOR-01" in helper_source \
		and not "CAL-SSE-HWIN-01" in helper_source \
		and not "CAL-ENE-HWIN-01" in helper_source \
		and not "CAL-NNW-HWIN" in helper_source \
		and not "CAL-NNW-PDOOR" in helper_source


func _mapping_matches(registry: Dictionary) -> bool:
	var mapping := JSON.parse_string(FileAccess.get_file_as_string(RUN_MAPPING_PATH)) as Dictionary
	var target := {}
	for target_value: Variant in mapping.get("targets", []):
		var candidate := target_value as Dictionary
		if str(candidate.get("source_key", "")) == "w34313564":
			target = candidate
			break
	if target.is_empty() or _int_array((target.get("partition", {}) as Dictionary).get("mapped_run_indices", []) as Array) != [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]:
		return false
	var mappings := {}
	for mapping_value: Variant in target.get("mappings", []):
		var mapped := mapping_value as Dictionary
		mappings[str(mapped.mapping_id)] = mapped
	for placement_value: Variant in registry.get("placements", []):
		var placement := placement_value as Dictionary
		var mapping_id := str(placement.mapping_id)
		if not mappings.has(mapping_id):
			return false
		var mapped := mappings[mapping_id] as Dictionary
		if not int(placement.anchor_run) in _int_array(mapped.run_indices as Array) \
		or not bool(mapped.get("contiguous", false)) \
		or (mapped.get("observation_ids", []) as Array).is_empty():
			return false
	return true


func _motif_specific_bounds_match(registry: Dictionary) -> bool:
	var prototype := JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/facades/batch_06_prototype_registry.json")) as Dictionary
	var target := {}
	for target_value: Variant in prototype.get("targets", []):
		var candidate := target_value as Dictionary
		if str(candidate.get("source_key", "")) == "w34313564":
			target = candidate
			break
	if target.is_empty():
		return false
	var bounds_by_motif := {}
	for module_value: Variant in target.get("modules", []):
		var module := module_value as Dictionary
		bounds_by_motif[str(module.get("motif_id", ""))] = module.get("placement_bounds", [])
	for placement_value: Variant in registry.get("placements", []):
		var placement := placement_value as Dictionary
		var motif_id := str(placement.get("motif_id", ""))
		if not bounds_by_motif.has(motif_id):
			return false
		var matched := false
		for bound_value: Variant in bounds_by_motif[motif_id] as Array:
			var parts := str(bound_value).split(":")
			if parts.size() != 2 or parts[0] != str(placement.get("mapping_id", "")):
				continue
			var run_parts := str(parts[1]).trim_prefix("runs_").split("_")
			if run_parts.size() == 2:
				var anchor_run := int(placement.get("anchor_run", -1))
				matched = anchor_run >= int(run_parts[0]) and anchor_run <= int(run_parts[1])
			if matched:
				break
		if not matched:
			return false
	return true


func _predecessor_delta_matches(registry: Dictionary) -> bool:
	var predecessor := JSON.parse_string(FileAccess.get_file_as_string("res://evidence/first-playable/batch-06-w34313564-module-calibration-2026-08-30/capture-manifest.json")) as Dictionary
	var old_by_id := {}
	for value: Variant in predecessor.get("placements", []):
		var placement := value as Dictionary
		old_by_id[str(placement.get("placement_id", ""))] = placement
	var changed_count := 0
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		var placement_id := str(placement.get("placement_id", ""))
		if not old_by_id.has(placement_id):
			return false
		if JSON.stringify(placement) != JSON.stringify(old_by_id[placement_id]):
			changed_count += 1
			if placement_id != "CAL-SSE-PDOOR-01":
				return false
	var old_door := old_by_id.get("CAL-SSE-PDOOR-01", {}) as Dictionary
	return changed_count == 1 \
		and str(old_door.get("mapping_id", "")) == "B06-34313564-SSE-EAST-RETURN" \
		and int(old_door.get("anchor_run", -1)) == 6 \
		and is_equal_approx(float(old_door.get("center_chain_m", -1.0)), 30.0)


func _overlay_matches(root_node: Node3D, registry: Dictionary, resolved_values: Array) -> bool:
	if not bool(root_node.get_meta("controlled_calibration", false)) \
	or bool(root_node.get_meta("runtime_attachment", true)) \
	or bool(root_node.get_meta("module_owns_field_geometry", true)) \
	or root_node.get_child_count() != 5 \
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
		var motif_id := str(module.get_meta("motif_id", ""))
		if placement.is_empty() or not resolved.has(placement_id) \
		or bool(module.get_meta("module_owns_field_geometry", true)) \
		or str(module.get_meta("host_field_contract", "")) != "continuous_receiver_field_owns_all_nonopening_pixels" \
		or bool(module.get_meta("runtime_attachment", true)):
			return false
		var item := resolved[placement_id] as Dictionary
		var expected_xz := placement.expected_wall_anchor_world_xz_m as Array
		var wall_anchor := item.wall_anchor_world_m as Array
		if Vector2(float(wall_anchor[0]), float(wall_anchor[2])).distance_to(Vector2(float(expected_xz[0]), float(expected_xz[1]))) > 0.0015 \
		or _int_array(item.run_ownership as Array) != _int_array(placement.run_ownership as Array):
			return false
		var tangent_values := item.tangent_world_xz as Array
		var normal_values := item.outward_normal_world_xz as Array
		var tangent := Vector3(float(tangent_values[0]), 0.0, float(tangent_values[1])).normalized()
		var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
		if module.transform.basis.x.dot(tangent) < 0.9999 \
		or module.transform.basis.y.dot(Vector3.UP) < 0.9999 \
		or module.transform.basis.z.dot(normal) < 0.9999:
			return false
		var expected_meshes := 8 if motif_id == "W34313564-HWIN" else 5
		if module.get_child_count() != expected_meshes:
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
			or mesh_instance.material_override is ShaderMaterial \
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


func _runtime_receiver_matches_approved_live_modules(record: Dictionary) -> bool:
	var builder := WorldChunkBuilder.new()
	var result := builder._build_record(record, false)
	if not bool(result.get("ok", false)):
		return false
	var node := result.node as Node3D
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var live_root := node.get_node_or_null("W34313564LiveModules") as Node3D
	var live_metadata := node.get_meta("w34313564_live_modules", {}) as Dictionary
	var ok := node.get_child_count() == 3 \
		and mesh != null and mesh.get_surface_count() == 3 \
		and mesh.surface_get_name(0) == FIELD_TRIALS.PLACEHOLDER_SURFACE_NAME \
		and body != null and shape_node != null \
		and int(result.get("mesh_instances", -1)) == 35 \
		and int(result.get("surfaces", -1)) == 37 \
		and int(result.get("triangles", -1)) == 448 \
		and live_root != null and live_root.get_child_count() == 5 \
		and live_root.find_children("*", "MeshInstance3D", true, false).size() == 34 \
		and live_root.find_children("*", "CollisionObject3D", true, false).is_empty() \
		and live_root.find_children("*", "NavigationRegion3D", true, false).is_empty() \
		and int(live_metadata.get("module_instances", -1)) == 5 \
		and int(live_metadata.get("mesh_instances", -1)) == 34 \
		and int(live_metadata.get("surfaces", -1)) == 34 \
		and int(live_metadata.get("triangles", -1)) == 408 \
		and str(live_metadata.get("placement_role", "")) == LIVE_MODULES.PLACEMENT_ROLE
	node.free()
	var builder_source := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	return ok and "w34313564_live_modules.gd" in builder_source and not "CAL-SSE" in builder_source


func _load_record() -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	for record_value: Variant in chunk.get("records", []):
		var record := record_value as Dictionary
		if str(record.get("object_key", "")) == RECEIVER_KEY:
			return record
	return {}


func _contract_for(registry: Dictionary, motif_id: String) -> Dictionary:
	for value: Variant in registry.get("module_contracts", []):
		var contract := value as Dictionary
		if str(contract.get("motif_id", "")) == motif_id:
			return contract
	return {}


func _placement_for(registry: Dictionary, placement_id: String) -> Dictionary:
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		if str(placement.get("placement_id", "")) == placement_id:
			return placement
	return {}


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _free_result(result: Dictionary) -> void:
	if result.has("node") and is_instance_valid(result.node):
		(result.node as Node).free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
