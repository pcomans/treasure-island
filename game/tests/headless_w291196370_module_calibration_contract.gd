extends SceneTree

const CALIBRATION_HELPER := preload("res://game/tests/support/w291196370_module_calibration.gd")
const FIELD_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const WORLD_CHUNK_BUILDER := preload("res://game/scripts/world/world_chunk_builder.gd")
const REGISTRY_PATH := "res://game/resources/facades/w291196370_module_calibration.json"
const HELPER_PATH := "res://game/tests/support/w291196370_module_calibration.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-3.json"
const RUN_MAPPING_PATH := "res://discovery/facades/BATCH_06_RUN_MAPPING.json"
const RECEIVER_KEY := "building:w291196370:wall"
const EXPECTED_PLACEMENTS := ["CAL-ENE-SERVICE-01", "CAL-SSE-ENTRY-01", "CAL-SSE-WINSTACK-01"]
const EXPECTED_PROTECTED_HASHES := {
	REGISTRY_PATH: "b30a8f19091288cde4b8e891ec40287ab28a73776588f96ee86fc5565cfc25b8",
	HELPER_PATH: "ba621cffc5ee155e8b7c7338c3b5d444d1180dad6dbe11528219ada6de05dfdf",
	CHUNK_PATH: "6dfa4b8f4b91f309b313428829e37cedd13e4067ff94f896a8e2e5ef05002a1d",
	"res://discovery/facades/BATCH_06_STREETVIEW_OBSERVATIONS.md": "259e562e69b1186912fce2dfb466f4512fbc69cc8e64562574971c0a8c40028b",
	"res://discovery/facades/W291196370_REFERENCE_SPEC.md": "fdd7328579950c0d8b852b4a122a252c9a3ee01f60cfe34d32d9d518b895edd7",
	RUN_MAPPING_PATH: "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d",
	"res://discovery/facades/BATCH_06_PROTOTYPE_SET_01_ART_REVIEW.md": "bfaccbf182fb04222b5a65356f3287bd7823f5b692d0da6d2d44b2e2af5599eb",
	"res://discovery/facades/BATCH_06_PROTOTYPE_SET_01_MODULE_CORRECTION_ART_REVIEW.md": "70f6a0e1e9ece07d162aa669aa89e4f4a9a8b19b1785eb7fb91efc0dc8f6aded",
	"res://discovery/facades/BATCH_06_EXACT_RECEIVER_FIELD_TRIALS_ART_REVIEW.md": "ce213c3fb37529eeaefe01da1b555b44b4ea58ab10b36b2150002b8edf6d2bb7",
	"res://discovery/facades/W291196370_LIVE_MODULES_ART_REVIEW.md": "410ffa891bdebe92d689155b4c7986f7e9a07bef1028900cd0dac00bcb8222ca",
	"res://game/resources/facades/batch_06_prototype_registry.json": "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132",
	"res://game/scripts/world/facades/batch_06_prototype_set.gd": "fecc656332599acefbf307ce6b5978e62c689ae146f713cf9d935ef66b81de60",
	"res://game/resources/materials/world/w291196370/w291196370_siding_exact_trial.tres": "715cf02b3c006c1a492ad61def9b2535fbaf04a3b1a41c69c5f092d705fab677",
	"res://game/resources/materials/world/w291196370/w291196370_trim.tres": "0223453497849cddb947701aaf6c83044d3bfd1e610dbc2eea49ed79cb5b56ad",
	"res://game/resources/materials/world/w291196370/w291196370_glass.tres": "bb2727b8bfe6e8228cfe938345fd38950055f13a2c3ee27a7fd0daafaa5ba6ff",
	"res://game/resources/materials/world/w291196370/w291196370_entry.tres": "da23ac9280107f5cd3ca3f73bfe6e236149634a27213d5a8ac453781a4b7248f",
	"res://game/resources/materials/world/w291196370/w291196370_service.tres": "ec7973f9b7849a7ae36c2027bed9fa3c019405cedc4c254f8a104391923981a2",
	"res://game/scripts/world/facades/w291196370_live_modules.gd": "e297d40ac9841485ee00a76b955f8ec454639b394c23759e8017e170aa84cbf8",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://game/resources/facades/w34313515_module_calibration.json": "2d378a94da4b7badd334d5c00f926a26a4ff9109782abb18e4859301df4b5c1d",
	"res://game/tests/support/w34313515_module_calibration.gd": "1edfdf4b736a7b1cc2883569a4c09b48814cabf30e3056e9dac86152de22d5f1",
	"res://game/scripts/world/facades/w34313515_live_modules.gd": "4420ad2d0a029f03da7a14fe84084d53edfa2323867a5c660c63f875c2a71ccb",
	"res://game/resources/facades/w34313564_module_calibration.json": "45a47d333c997887cef7d1c97a633d37ae050efda597186430c7af6d52116f0f",
	"res://game/scripts/world/facades/w34313564_live_modules.gd": "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee",
}

var _failure := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(_protected_inputs_match(), "A protected observation, accepted field/module, inventory, generated, or runtime input changed."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var record := _load_record()
	if not _require(_registry_matches(registry, record), "Calibration classification, evidence, uncertainty, side, placement, or blocker contract failed.") \
	or not _require(_mapping_and_prototype_bounds_match(registry), "A placement escaped its observed mapping or accepted motif-specific prototype bound.") \
	or not _require(_active_field_is_immutable(registry), "The accepted SSE/ENE siding field or exact-three live-module metadata changed."):
		_finish()
		return
	var first_result := CALIBRATION_HELPER.build(record, registry)
	var second_result := CALIBRATION_HELPER.build(record, registry)
	if not _require(bool(first_result.get("ok", false)) and bool(second_result.get("ok", false)), "Detached module calibration failed to build deterministically."):
		_free_result(first_result)
		_free_result(second_result)
		_finish()
		return
	var first := first_result.node as Node3D
	var second := second_result.node as Node3D
	if not _require(JSON.stringify(first_result.resolved_placements) == JSON.stringify(second_result.resolved_placements), "Resolved placement transforms are nondeterministic.") \
	or not _require(_overlay_matches(first, registry, first_result.resolved_placements), "Detached motif geometry, transform, completeness, bounds, or no-backing contract failed.") \
	or not _require(_runtime_receiver_matches_reviewed_scope(record), "The live w291196370 receiver no longer preserves the accepted field plus exact-three reviewed module scope."):
		first.free()
		second.free()
		_finish()
		return
	first.free()
	second.free()
	print("PASS: w291196370 detached calibration deterministically remains identical to exactly three independently KEEP_WITH_DOCUMENTED_LIMITATION live complete module-atlas exemplars—WINSTACK/ENTRY on SSE runs 8/10 and SERVICE on ENE run 20—with explicit unsurveyed inference envelopes; the separate byte-stable live adapter attaches only that reviewed scope while backing/collision/navigation/spray/count/cadence/completed-elevation/whole-building claims remain zero")
	_finish()


func _protected_inputs_match() -> bool:
	for path: String in EXPECTED_PROTECTED_HASHES:
		if FileAccess.get_sha256(path) != str(EXPECTED_PROTECTED_HASHES[path]):
			push_error("Protected input drifted: %s" % path)
			return false
	return true


func _registry_matches(registry: Dictionary, record: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.w291196370-controlled-module-calibration/1" \
	or str(registry.get("status", "")) != "controlled_zero_attachment_calibration_ready_for_independent_review" \
	or not "module-atlas" in str(registry.get("evidence_role", "")) \
	or not "not live attachment" in str(registry.get("evidence_role", "")):
		return false
	var target := registry.get("target", {}) as Dictionary
	if str(target.get("source_key", "")) != "w291196370" \
	or str(target.get("receiver_key", "")) != RECEIVER_KEY \
	or int(target.get("run_count", -1)) != 36 \
	or _int_array(target.get("accepted_field_runs", []) as Array) != [8, 9, 10, 17, 18, 19, 20, 21, 22] \
	or _int_array(target.get("excluded_runs", []) as Array) != [0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35] \
	or record.get("source_keys", []) != ["w291196370"]:
		return false
	var contracts := registry.get("module_contracts", []) as Array
	if contracts.size() != 3:
		return false
	var contract_ids: Array[String] = []
	for contract_value: Variant in contracts:
		var contract := contract_value as Dictionary
		contract_ids.append(str(contract.get("motif_id", "")))
		if str(contract.get("asset_classification", "")) != "module_atlas" \
		or not bool(contract.get("complete_motif", false)) \
		or not bool(contract.get("module_not_seamless_tile", false)) \
		or bool(contract.get("module_owns_field_geometry", true)) \
		or str(contract.get("host_field_contract", "")) != "continuous_receiver_field_owns_all_nonopening_pixels" \
		or str(contract.get("scale_status", "")) != "reversible_unmeasured_proof_assumption":
			return false
	contract_ids.sort()
	if contract_ids != ["W291196370-ENTRY", "W291196370-SERVICE", "W291196370-WINSTACK"]:
		return false
	var policy := registry.get("placement_policy", {}) as Dictionary
	if str(policy.get("position_status", "")) != "stylized_reference_derived_production_inference_not_surveyed" \
	or str(policy.get("coordinate_status", "")) != "stylized_reference_derived_inference_not_surveyed" \
	or str(policy.get("cadence_status", "")) != "unknown_not_surveyed_not_inferred" \
	or not "not_surveyed_total" in str(policy.get("count_status", "")) \
	or int(policy.get("placement_count", -1)) != 3 \
	or bool(policy.get("runtime_attachment", true)) \
	or int(policy.get("collision_nodes", -1)) != 0 \
	or int(policy.get("navigation_nodes", -1)) != 0 \
	or int(policy.get("spray_nodes", -1)) != 0 \
	or float(policy.get("maximum_outward_depth_m", 1.0)) > 0.18:
		return false
	var expected_faces := {
		"SSE": {"runs": [8, 9, 10], "motifs": ["W291196370-WINSTACK", "W291196370-ENTRY"]},
		"ENE": {"runs": [17, 18, 19, 20, 21, 22], "motifs": ["W291196370-SERVICE"]},
	}
	for chain_value: Variant in registry.get("face_chains", []):
		var chain := chain_value as Dictionary
		var face := str(chain.get("face", ""))
		if not expected_faces.has(face) \
		or _int_array(chain.get("ordered_runs", []) as Array) != expected_faces[face].runs \
		or chain.get("eligible_motif_ids", []) != expected_faces[face].motifs \
		or str(chain.get("evidence_status", "")) != "reference_observation":
			return false
		expected_faces.erase(face)
	if not expected_faces.is_empty():
		return false
	var ids: Array[String] = []
	var motif_counts := {"W291196370-WINSTACK": 0, "W291196370-ENTRY": 0, "W291196370-SERVICE": 0}
	for placement_value: Variant in registry.get("placements", []):
		var placement := placement_value as Dictionary
		var motif_id := str(placement.get("motif_id", ""))
		ids.append(str(placement.get("placement_id", "")))
		motif_counts[motif_id] = int(motif_counts.get(motif_id, 0)) + 1
		if str(placement.get("evidence_status", "")) != "production_inference" \
		or str(placement.get("reference_observation_basis", "")) != "reference_observation" \
		or str(placement.get("coordinate_status", "")) != "stylized_reference_derived_inference_not_surveyed" \
		or bool(placement.get("coordinate_surveyed", true)) \
		or bool(placement.get("count_surveyed", true)) \
		or bool(placement.get("cadence_surveyed", true)) \
		or bool(placement.get("module_scale_surveyed", true)) \
		or str(placement.get("count_status", "")) != "bounded_exemplar_not_surveyed_total" \
		or str(placement.get("cadence_status", "")) != "unknown_not_surveyed_not_inferred" \
		or _int_array(placement.get("run_ownership", []) as Array) != [int(placement.get("anchor_run", -1))]:
			return false
		var contract := _contract_for(registry, motif_id)
		var center := float(placement.get("center_chain_m", -1.0))
		var uncertainty := float(placement.get("center_chain_uncertainty_m", -1.0))
		var bounds := placement.get("center_chain_bounds_m", []) as Array
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
	return ids == EXPECTED_PLACEMENTS \
		and motif_counts == {"W291196370-WINSTACK": 1, "W291196370-ENTRY": 1, "W291196370-SERVICE": 1} \
		and (registry.get("excluded_regions", []) as Array).size() == 5 \
		and "completed elevations and whole-building resemblance remain blocked" in JSON.stringify(registry.get("preserved_blockers", []))


func _mapping_and_prototype_bounds_match(registry: Dictionary) -> bool:
	var mapping := JSON.parse_string(FileAccess.get_file_as_string(RUN_MAPPING_PATH)) as Dictionary
	var mapping_target := _target_for(mapping.get("targets", []) as Array, "w291196370")
	if mapping_target.is_empty() \
	or _int_array((mapping_target.get("partition", {}) as Dictionary).get("mapped_run_indices", []) as Array) != [8, 9, 10, 17, 18, 19, 20, 21, 22]:
		return false
	var mappings := {}
	for value: Variant in mapping_target.get("mappings", []):
		var item := value as Dictionary
		mappings[str(item.mapping_id)] = item
	var prototype := JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/facades/batch_06_prototype_registry.json")) as Dictionary
	var prototype_target := _target_for(prototype.get("targets", []) as Array, "w291196370")
	if prototype_target.is_empty() or (prototype_target.get("modules", []) as Array).size() != 3:
		return false
	var prototype_modules := {}
	for module_value: Variant in prototype_target.modules:
		var module := module_value as Dictionary
		prototype_modules[str(module.motif_id)] = module
		if bool(module.get("module_owns_field_geometry", true)) or not bool(module.get("complete_motif", false)):
			return false
	for placement_value: Variant in registry.get("placements", []):
		var placement := placement_value as Dictionary
		var mapping_id := str(placement.mapping_id)
		var motif_id := str(placement.motif_id)
		if not mappings.has(mapping_id) or not prototype_modules.has(motif_id):
			return false
		var mapped := mappings[mapping_id] as Dictionary
		var prototype_module := prototype_modules[motif_id] as Dictionary
		var runs := _int_array(placement.exact_ordered_runs as Array)
		var legal_bound := "%s:runs_%d_%d" % [mapping_id, runs[0], runs[-1]]
		if not bool(mapped.get("contiguous", false)) \
		or not int(placement.anchor_run) in _int_array(mapped.run_indices as Array) \
		or (mapped.get("observation_ids", []) as Array).is_empty() \
		or not legal_bound in (prototype_module.get("placement_bounds", []) as Array):
			return false
	return true


func _active_field_is_immutable(registry: Dictionary) -> bool:
	if not FIELD_TRIALS.BATCH_06_ACCEPTED_TARGETS.has(RECEIVER_KEY):
		return false
	var target := FIELD_TRIALS.BATCH_06_ACCEPTED_TARGETS[RECEIVER_KEY] as Dictionary
	var metadata := FIELD_TRIALS.metadata_for(RECEIVER_KEY)
	var role := registry.get("active_accepted_field", {}) as Dictionary
	if int(target.get("run_count", -1)) != 36 \
	or int(metadata.get("modules", -1)) != 3 \
	or int(metadata.get("standalone_modules_live", -1)) != 3 \
	or int(metadata.get("module_motif_types_live", -1)) != 3 \
	or str(metadata.get("module_placement_role", "")) != "stylized/reference-derived production inference" \
	or metadata.get("module_position_uncertainty_by_placement_m", {}) != {"CAL-SSE-WINSTACK-01": 2.0, "CAL-SSE-ENTRY-01": 3.0, "CAL-ENE-SERVICE-01": 4.0} \
	or str(metadata.get("status", "")) != FIELD_TRIALS.BATCH_06_ACCEPTED_STATUS \
	or (target.get("material_groups", []) as Array).size() != 1:
		return false
	var group := (target.material_groups as Array)[0] as Dictionary
	var flattened: Array[int] = []
	for run_group_value: Variant in group.run_groups:
		flattened.append_array(_int_array(run_group_value as Array))
	return flattened == _int_array(role.get("runs", []) as Array) \
		and str(group.id) == str(role.material_id) \
		and str(group.material_path) == str(role.material_path) \
		and FileAccess.get_sha256(str(group.material_path)) == str(role.material_sha256)


func _overlay_matches(root_node: Node3D, registry: Dictionary, resolved_values: Array) -> bool:
	if not bool(root_node.get_meta("controlled_calibration", false)) \
	or bool(root_node.get_meta("runtime_attachment", true)) \
	or str(root_node.get_meta("asset_classification", "")) != "module_atlas" \
	or bool(root_node.get_meta("module_owns_field_geometry", true)) \
	or root_node.get_child_count() != 3 \
	or _count_type(root_node, MeshInstance3D) != 24 \
	or _count_type(root_node, CollisionObject3D) != 0 \
	or _count_type(root_node, CollisionShape3D) != 0 \
	or _count_type(root_node, NavigationRegion3D) != 0:
		return false
	var expected_mesh_counts := {"W291196370-WINSTACK": 7, "W291196370-ENTRY": 5, "W291196370-SERVICE": 12}
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
		or module.get_child_count() != int(expected_mesh_counts.get(motif_id, -1)) \
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


func _runtime_receiver_matches_reviewed_scope(record: Dictionary) -> bool:
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
	var live := node.get_node_or_null("W291196370LiveModules") as Node3D
	var live_metadata := node.get_meta("w291196370_live_modules", {}) as Dictionary
	var ok := node.get_child_count() == 3 \
		and node.get_node_or_null("DetachedW291196370ModuleCalibration") == null \
		and live != null and live.get_child_count() == 3 \
		and mesh != null and mesh.get_surface_count() == 2 \
		and mesh.surface_get_name(0) == FIELD_TRIALS.PLACEHOLDER_SURFACE_NAME \
		and mesh.surface_get_name(1) == "trial_w291196370_siding_runs" \
		and body != null and shape_node != null \
		and int(result.get("mesh_instances", -1)) == 25 \
		and int(result.get("surfaces", -1)) == 26 \
		and int(result.get("triangles", -1)) == 360 \
		and int(metadata.get("modules", -1)) == 3 \
		and int(metadata.get("standalone_modules_live", -1)) == 3 \
		and int(metadata.get("module_motif_types_live", -1)) == 3 \
		and int(live_metadata.get("module_instances", -1)) == 3 \
		and int(live_metadata.get("field_meshes", -1)) == 0 \
		and int(live_metadata.get("backing_meshes", -1)) == 0 \
		and int(live_metadata.get("collision_nodes", -1)) == 0 \
		and int(live_metadata.get("navigation_nodes", -1)) == 0 \
		and int(live_metadata.get("spray_nodes", -1)) == 0
	node.free()
	var builder_source := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	var field_source := FileAccess.get_file_as_string("res://game/scripts/world/facades/accepted_material_run_trials.gd")
	return ok \
		and "w291196370_live_modules" in builder_source \
		and "CAL-SSE-WINSTACK-01" in field_source \
		and "CAL-SSE-ENTRY-01" in field_source \
		and "CAL-ENE-SERVICE-01" in field_source


func _load_record() -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	for record_value: Variant in chunk.get("records", []):
		var record := record_value as Dictionary
		if str(record.get("object_key", "")) == RECEIVER_KEY:
			return record
	return {}


func _target_for(values: Array, source_key: String) -> Dictionary:
	for value: Variant in values:
		var item := value as Dictionary
		if str(item.get("source_key", "")) == source_key:
			return item
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
	var node := result.get("node") as Node
	if node != null:
		node.free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	if _failure.is_empty():
		_failure = message
	push_error(message)
	return false


func _finish() -> void:
	quit(0 if _failure.is_empty() else 1)
