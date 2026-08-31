extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/batch_06_prototype_registry.json"
const EXPECTED_REGISTRY_SHA256 := "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132"
const EXPECTED_MAPPING_SHA256 := "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d"
const EXPECTED_OBSERVATIONS_SHA256 := "259e562e69b1186912fce2dfb466f4512fbc69cc8e64562574971c0a8c40028b"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_BUILDER_SHA256 := "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42"
const EXPECTED_FACTORY_SHA256 := "fecc656332599acefbf307ce6b5978e62c689ae146f713cf9d935ef66b81de60"
const EXPECTED_LIVE_MODULE_HELPER_SHA256 := "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee"
const EXPECTED_W34313515_LIVE_MODULE_HELPER_SHA256 := "4420ad2d0a029f03da7a14fe84084d53edfa2323867a5c660c63f875c2a71ccb"
const EXPECTED_CALIBRATION_REGISTRY_SHA256 := "45a47d333c997887cef7d1c97a633d37ae050efda597186430c7af6d52116f0f"
const EXPECTED_MODULE_REVIEW_SHA256 := "a8f1396e2d126c0c38b37edf770df975c4fa95e25e34fb2c7c1e766630fd1591"
const EXPECTED_W34313515_LIVE_REVIEW_SHA256 := "cebfe328ec5372f8c0d440fcf59bb0b9bae7a490998ed373d8f5c5e418b5b94e"
const EXPECTED_W291196370_LIVE_MODULE_HELPER_SHA256 := "e297d40ac9841485ee00a76b955f8ec454639b394c23759e8017e170aa84cbf8"
const EXPECTED_W291196370_PLACEMENT_REVIEW_SHA256 := "967ab07d109096a743be01fb0bce959280967f5eab65c82ac0652eb5dcd3023b"
const EXPECTED_W291196370_LIVE_REVIEW_SHA256 := "410ffa891bdebe92d689155b4c7986f7e9a07bef1028900cd0dac00bcb8222ca"
const EXPECTED_W34313520_LIVE_MODULE_HELPER_SHA256 := "7675d651d834ac20328c12c9eb543bda1af453730cb3d8d8c8a41e899e63a8d2"
const EXPECTED_W34313520_CALIBRATION_REVIEW_SHA256 := "555eb2fb3a397341cc6ed6412a627b9d84fe8c806de756c2ed4cbd8a3a652870"
const EXPECTED_W34313520_CORRECTION_REVIEW_SHA256 := "958130a3cc09cf129186562a9e54f4157bbfad3f99846a695238c3ee4b6b1a46"
const EXPECTED_W34313525_LIVE_MODULE_HELPER_SHA256 := "f9b31302eaf98fd4185aed4f28d3651794e2e50958ad2641c04aec0dd45f05e1"
const EXPECTED_W34313525_LIVE_REVIEW_SHA256 := "d11041e1abf41fc11843d2f2631e4c33da25f8fc565f93e6ee822589ad229f45"
const EXPECTED_TARGETS := ["w34313564", "w34313515", "w291196370"]
const EXPECTED_MODULES := {
	"w34313564": ["W34313564-HWIN", "W34313564-PDOOR"],
	"w34313515": ["W34313515-BAY"],
	"w291196370": ["W291196370-WINSTACK", "W291196370-ENTRY", "W291196370-SERVICE"],
}
const EXPECTED_RECEIVERS := {
	"w34313564": "building:w34313564:wall",
	"w34313515": "building:w34313515:wall",
	"w291196370": "building:w291196370:wall",
}
const EXPECTED_FIELD_HASHES := {
	"W34313515-MAT-PALE": "0f97c958b35fe8c52e61db532c9caed95566330d9269e4b830e2c319ec47023e",
	"W34313564-MAT-TAN": "2503ee946804bd16db9ca60ae05a0a1b9b6ca7c46422e0997ac2891c79a7ea76",
	"W34313564-MAT-PALE": "4523c071e50875db052e98ac39b9d9eff9cfb487aa37344064834ae82c0aae83",
	"W34313564-MAT-PLINTH": "89a36e7fb036bf8bd3f5db0996076c477641e2c7e97d29537c2c464155b12d88",
	"W291196370-SIDING": "f5c359c34f6e4c61020a49391f0dad04f637730b955ae14195a87260588fce5f",
}
const EXPECTED_HOST_MATERIALS := {
	"W34313515-BAY": ["W34313515-MAT-PALE"],
	"W34313564-HWIN": ["W34313564-MAT-TAN", "W34313564-MAT-PALE"],
	"W34313564-PDOOR": ["W34313564-MAT-TAN", "W34313564-MAT-PALE"],
	"W291196370-WINSTACK": ["W291196370-SIDING"],
	"W291196370-ENTRY": ["W291196370-SIDING"],
	"W291196370-SERVICE": ["W291196370-SIDING"],
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Batch 06 registry bytes drifted.") \
	or not _require(FileAccess.get_sha256("res://discovery/facades/BATCH_06_RUN_MAPPING.json") == EXPECTED_MAPPING_SHA256, "Final Batch 06 run mapping drifted.") \
	or not _require(FileAccess.get_sha256("res://discovery/facades/BATCH_06_STREETVIEW_OBSERVATIONS.md") == EXPECTED_OBSERVATIONS_SHA256, "Batch 06 observation ledger drifted.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated world manifest changed.") \
	or not _require(FileAccess.get_sha256("res://game/scripts/world/world_chunk_builder.gd") == EXPECTED_BUILDER_SHA256, "Runtime world builder changed.") \
	or not _require(FileAccess.get_sha256("res://game/scripts/world/facades/w34313564_live_modules.gd") == EXPECTED_LIVE_MODULE_HELPER_SHA256, "Approved w34313564 live-module helper changed.") \
	or not _require(FileAccess.get_sha256("res://game/scripts/world/facades/w34313515_live_modules.gd") == EXPECTED_W34313515_LIVE_MODULE_HELPER_SHA256, "Placement-approved w34313515 live-module helper changed.") \
	or not _require(FileAccess.get_sha256("res://game/scripts/world/facades/w291196370_live_modules.gd") == EXPECTED_W291196370_LIVE_MODULE_HELPER_SHA256, "Placement-approved w291196370 live-module helper changed.") \
	or not _require(FileAccess.get_sha256("res://game/scripts/world/facades/w34313520_live_modules.gd") == EXPECTED_W34313520_LIVE_MODULE_HELPER_SHA256, "Placement-approved w34313520 live-module helper changed.") \
	or not _require(FileAccess.get_sha256("res://game/scripts/world/facades/w34313525_live_modules.gd") == EXPECTED_W34313525_LIVE_MODULE_HELPER_SHA256, "Placement-approved w34313525 live-module helper changed.") \
	or not _require(FileAccess.get_sha256("res://game/resources/facades/w34313564_module_calibration.json") == EXPECTED_CALIBRATION_REGISTRY_SHA256, "Corrected w34313564 calibration registry changed.") \
	or not _require(FileAccess.get_sha256("res://discovery/facades/W34313564_MODULE_CALIBRATION_CORRECTION_ART_REVIEW.md") == EXPECTED_MODULE_REVIEW_SHA256, "Final corrected w34313564 module review changed.") \
	or not _require(FileAccess.get_sha256("res://discovery/facades/W34313515_LIVE_MODULES_ART_REVIEW.md") == EXPECTED_W34313515_LIVE_REVIEW_SHA256, "Independent w34313515 actual-world review changed.") \
	or not _require(FileAccess.get_sha256("res://discovery/facades/W291196370_MODULE_CALIBRATION_ART_REVIEW.md") == EXPECTED_W291196370_PLACEMENT_REVIEW_SHA256, "Independent w291196370 detached placement review changed.") \
	or not _require(FileAccess.get_sha256("res://discovery/facades/W291196370_LIVE_MODULES_ART_REVIEW.md") == EXPECTED_W291196370_LIVE_REVIEW_SHA256, "Independent w291196370 actual-world review changed.") \
	or not _require(FileAccess.get_sha256("res://discovery/facades/W34313520_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md") == EXPECTED_W34313520_CALIBRATION_REVIEW_SHA256, "Independent w34313520 exact calibration review changed.") \
	or not _require(FileAccess.get_sha256("res://discovery/facades/W34313520_LIVE_EVIDENCE_CORRECTION_ART_REVIEW.md") == EXPECTED_W34313520_CORRECTION_REVIEW_SHA256, "Accepted w34313520 evidence-correction review changed.") \
	or not _require(FileAccess.get_sha256("res://discovery/facades/W34313525_LIVE_FIELDS_AND_MODULES_ART_REVIEW.md") == EXPECTED_W34313525_LIVE_REVIEW_SHA256, "Accepted w34313525 actual-world review changed."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	if not _require(_registry_matches(registry), "Selection, provenance, mapping, zero-attachment, or output classification contract failed.") \
	or not _require(_shader_contracts_match(registry), "A shared field shader lost its alias-resistant opaque material-only contract."):
		_finish()
		return
	for target_value: Variant in registry.targets:
		var target := target_value as Dictionary
		if not _require(_materials_match(target), "Material contract failed for %s." % str(target.source_key)):
			_finish()
			return
		if not await _scene_matches(target):
			_finish()
			return
	if not _require(_runtime_matches_approved_fields_and_modules(registry), "Batch 06 runtime scope escaped the exact accepted fields/modules.") \
	or not _require(_blocked_targets_have_no_assets(registry), "A reference-blocked target gained an asset or module."):
		_finish()
		return
	print("PASS: the corrected Batch 06 prototype registry and module geometry stay immutable while seven exact fields and seventeen placements remain independently accepted; pending actual-world review is zero, and field backing, phase, collision/navigation/generated data, and blocked targets remain unchanged")
	_finish()


func _registry_matches(registry: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.batch-06-bounded-prototypes/2" \
	or str(registry.get("runtime_attachment_policy", "")).begins_with("none;") == false:
		return false
	var correction := registry.get("correction_round", {}) as Dictionary
	if str(registry.get("review_status", "")) != "corrected_module_round_ready_for_independent_visual_review" \
	or str(correction.get("scope", "")) != "six modules only" \
	or int(correction.get("attempt_count", 0)) != 1 \
	or not "continuous host wall" in str(correction.get("after", "")):
		return false
	var selection := registry.get("selection_basis", {}) as Dictionary
	if selection.get("selected_in_order", []) != EXPECTED_TARGETS \
	or not "partial source-edge" in str(selection.get("deferred_candidate", "")):
		return false
	var geometry := registry.get("prototype_geometry_contract", {}) as Dictionary
	if not bool(geometry.get("render_only", false)) \
	or int(geometry.get("collision_nodes", -1)) != 0 \
	or int(geometry.get("navigation_nodes", -1)) != 0 \
	or int(geometry.get("architectural_pattern_tiles", -1)) != 0 \
	or int(geometry.get("whole_wall_tiles", -1)) != 0 \
	or int(geometry.get("module_owned_field_meshes", -1)) != 0 \
	or int(geometry.get("host_field_phase_resets", -1)) != 0 \
	or str(geometry.get("factory_sha256", "")) != EXPECTED_FACTORY_SHA256 \
	or FileAccess.get_sha256(str(geometry.get("factory_path", ""))) != EXPECTED_FACTORY_SHA256:
		return false
	var targets := registry.get("targets", []) as Array
	if targets.size() != 3:
		return false
	for index in targets.size():
		var target := targets[index] as Dictionary
		var source_key := str(target.get("source_key", ""))
		if source_key != EXPECTED_TARGETS[index] \
		or str(target.get("receiver_key", "")) != str(EXPECTED_RECEIVERS[source_key]) \
		or (target.get("provenance", []) as Array).size() < 2 \
		or (target.get("mapped_groups", []) as Array).size() < 2 \
		or (target.get("materials", []) as Array).is_empty() \
		or (target.get("modules", []) as Array).is_empty():
			return false
		for material_value: Variant in target.materials:
			var material := material_value as Dictionary
			if str(material.get("classification", "")) != "homogeneous_material_tile" \
			or str(material.get("sha256", "")) != str(EXPECTED_FIELD_HASHES.get(str(material.get("id", "")), "")) \
			or bool(material.get("contains_facade_scale_motifs", true)) \
			or float(material.get("proof_scale_m", 0.0)) <= 0.0 \
			or (material.get("uncertainty_m", []) as Array).size() != 2:
				return false
		for module_value: Variant in target.modules:
			var module := module_value as Dictionary
			if not bool(module.get("complete_motif", false)) \
			or bool(module.get("opposite_edge_continuity_required", true)) \
			or bool(module.get("module_owns_field_geometry", true)) \
			or str(module.get("host_field_contract", "")) != "continuous_receiver_field_owns_all_nonopening_pixels" \
			or module.get("allowed_host_material_ids", []) != EXPECTED_HOST_MATERIALS.get(str(module.get("motif_id", "")), []) \
			or (module.get("placement_bounds", []) as Array).is_empty() \
			or not "reversible_unmeasured" in str(module.get("scale_status", "")):
				return false
	var blocked := registry.get("nonselected_and_blocked", {}) as Dictionary
	return blocked.has("w1222514695") and blocked.has("w1222720021") and blocked.has("w34313525")


func _shader_contracts_match(registry: Dictionary) -> bool:
	for shader_value: Variant in registry.shared_shader_contracts:
		var shader := shader_value as Dictionary
		var path := str(shader.path)
		if FileAccess.get_sha256(path) != str(shader.sha256):
			return false
		var source := FileAccess.get_file_as_string(path)
		if source.count("fwidth(") < 1 or not "render_mode depth_draw_opaque, cull_back" in source:
			return false
		for forbidden in ["discard", "ALPHA =", "TIME", "SCREEN_TEXTURE", "sampler2D"]:
			if forbidden in source:
				return false
	return true


func _materials_match(target: Dictionary) -> bool:
	for material_value: Variant in target.materials:
		var record := material_value as Dictionary
		var path := str(record.path)
		if FileAccess.get_sha256(path) != str(record.sha256):
			return false
		var material := load(path) as ShaderMaterial
		if material == null or material.shader == null or not material.resource_name.ends_with("prototype"):
			return false
		if (material.get_shader_parameter("base_color") as Color).a != 1.0 \
		or float(material.get_shader_parameter("roughness_value")) < 0.65 \
		or float(material.get_shader_parameter("color_variation")) <= 0.0 \
		or float(material.get_shader_parameter("filter_start_cycles_per_pixel")) >= float(material.get_shader_parameter("filter_end_cycles_per_pixel")):
			return false
		if str(record.id) == "W291196370-SIDING":
			if not is_equal_approx(float(material.get_shader_parameter("course_height_m")), float(record.proof_scale_m)):
				return false
		elif not is_equal_approx(float(material.get_shader_parameter("primary_scale_m")), float(record.proof_scale_m)):
			return false
		var source := FileAccess.get_file_as_string(path).to_lower()
		for forbidden in ["texture =", "atlas", "whole_wall", "window", "door"]:
			if forbidden in source:
				return false
	return true


func _scene_matches(target: Dictionary) -> bool:
	var scene_record := target.scene as Dictionary
	var path := str(scene_record.path)
	if not _require(FileAccess.get_sha256(path) == str(scene_record.sha256), "Prototype scene bytes drifted: %s" % path):
		return false
	var packed := load(path) as PackedScene
	if not _require(packed != null, "Prototype scene did not load: %s" % path):
		return false
	var instance := packed.instantiate() as Node3D
	root.add_child(instance)
	await process_frame
	var geometry := instance.get_node_or_null("PrototypeGeometry") as Node3D
	if not _require(geometry != null and bool(geometry.get_meta("prototype_only", false)) and not bool(geometry.get_meta("runtime_attachment", true)), "Prototype geometry metadata failed for %s." % str(target.source_key)):
		instance.queue_free()
		return false
	var modules: Array[Node] = []
	_collect_modules(geometry, modules)
	var ids: Array[String] = []
	for module in modules:
		var motif_id := str(module.get_meta("motif_id", ""))
		ids.append(motif_id)
		if not _require(bool(module.get_meta("complete_motif", false)) \
		and bool(module.get_meta("module_not_seamless_tile", false)) \
		and not bool(module.get_meta("opposite_edge_continuity_required", true)) \
		and not bool(module.get_meta("module_owns_field_geometry", true)) \
		and str(module.get_meta("host_field_contract", "")) == "continuous_receiver_field_owns_all_nonopening_pixels" \
		and module.get_meta("allowed_host_material_ids", []) == EXPECTED_HOST_MATERIALS.get(motif_id, []) \
		and (module.get_meta("placement_bounds", []) as Array).size() > 0 \
		and _module_has_complete_render_geometry_but_no_field_backing(module), "Incomplete, host-incompatible, or field-owning module %s." % str(module.name)):
			instance.queue_free()
			return false
	ids.sort()
	var expected: Array = (EXPECTED_MODULES[str(target.source_key)] as Array).duplicate()
	expected.sort()
	if not _require(ids == expected, "Module inventory drifted for %s." % str(target.source_key)) \
	or not _require(_count_type(geometry, CollisionObject3D) == 0 and _count_type(geometry, CollisionShape3D) == 0 and _count_type(geometry, NavigationRegion3D) == 0, "Prototype gained collision or navigation for %s." % str(target.source_key)):
		instance.queue_free()
		return false
	instance.queue_free()
	await process_frame
	return true


func _module_has_complete_render_geometry_but_no_field_backing(module: Node) -> bool:
	var mesh_count := 0
	for child in module.get_children():
		if child is MeshInstance3D:
			mesh_count += 1
			var child_name := str(child.name).to_lower()
			if "surround" in child_name or "backing" in child_name or "field" in child_name:
				return false
			if (child as MeshInstance3D).material_override is ShaderMaterial:
				return false
	return mesh_count >= 5


func _collect_modules(node: Node, result: Array[Node]) -> void:
	if node.has_meta("motif_id"):
		result.append(node)
	for child in node.get_children():
		_collect_modules(child, result)


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child in node.get_children():
		count += _count_type(child, node_type)
	return count


func _runtime_matches_approved_fields_and_modules(registry: Dictionary) -> bool:
	var builder := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	if "batch_06_prototype" in builder or not "w34313564_live_modules.gd" in builder or not "w34313515_live_modules.gd" in builder or not "w291196370_live_modules.gd" in builder or not "w34313520_live_modules.gd" in builder or not "w34313525_live_modules.gd" in builder:
		return false
	var helper := FileAccess.get_file_as_string("res://game/scripts/world/facades/accepted_material_run_trials.gd")
	var w34313564_live_helper := FileAccess.get_file_as_string("res://game/scripts/world/facades/w34313564_live_modules.gd")
	var w34313515_live_helper := FileAccess.get_file_as_string("res://game/scripts/world/facades/w34313515_live_modules.gd")
	var w291196370_live_helper := FileAccess.get_file_as_string("res://game/scripts/world/facades/w291196370_live_modules.gd")
	var w34313520_live_helper := FileAccess.get_file_as_string("res://game/scripts/world/facades/w34313520_live_modules.gd")
	var w34313525_live_helper := FileAccess.get_file_as_string("res://game/scripts/world/facades/w34313525_live_modules.gd")
	var accepted_keys := AcceptedMaterialRunTrials.BATCH_06_ACCEPTED_TARGETS.keys()
	accepted_keys.sort()
	if accepted_keys != ["building:w291196370:wall", "building:w34313515:wall", "building:w34313520:wall", "building:w34313525:wall", "building:w34313564:wall"]:
		return false
	for target_value: Variant in registry.targets:
		var target := target_value as Dictionary
		if (str(target.source_key) in builder and not str(target.source_key) in ["w34313564", "w34313515", "w291196370"]) or str(target.scene.path) in builder:
			return false
		if not str(target.source_key) in helper:
			return false
		var metadata := AcceptedMaterialRunTrials.metadata_for(str(target.receiver_key)) as Dictionary
		var expected_live_instances := 5 if str(target.source_key) == "w34313564" else (4 if str(target.source_key) == "w34313515" else 3)
		if str(metadata.get("status", "")) != AcceptedMaterialRunTrials.BATCH_06_ACCEPTED_STATUS \
		or int(metadata.get("modules", -1)) != expected_live_instances \
		or int(metadata.get("standalone_modules_live", -1)) != expected_live_instances:
			return false
		for module_value: Variant in target.modules:
			var module := module_value as Dictionary
			var motif_id := str(module.motif_id)
			if motif_id in helper \
			or ((motif_id in w34313564_live_helper) != (str(target.source_key) == "w34313564")) \
			or ((motif_id in w34313515_live_helper) != (str(target.source_key) == "w34313515")) \
			or ((motif_id in w291196370_live_helper) != (str(target.source_key) == "w291196370")):
				return false
	var integration_metadata := AcceptedMaterialRunTrials.metadata_for("building:w34313520:wall") as Dictionary
	if str(integration_metadata.get("status", "")) != "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending" \
	or int(integration_metadata.get("modules", -1)) != 1 \
	or int(integration_metadata.get("standalone_modules_live", -1)) != 1 \
	or "W34313520-BAY" in helper:
		return false
	var w34313525_metadata := AcceptedMaterialRunTrials.metadata_for("building:w34313525:wall") as Dictionary
	if str(w34313525_metadata.get("status", "")) != "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending" \
	or int(w34313525_metadata.get("modules", -1)) != 4 \
	or int(w34313525_metadata.get("standalone_modules_live", -1)) != 4 \
	or "W34313525-ROLLUP" in helper:
		return false
	var inventory := JSON.parse_string(FileAccess.get_file_as_string("res://discovery/FACADE_RECEIVER_INVENTORY.json")) as Dictionary
	var runtime := inventory.get("runtime_material_contract", {}) as Dictionary
	if int(runtime.get("accepted_live_module_target_receiver_count", -1)) != 6 \
	or int(runtime.get("accepted_live_module_placement_count", -1)) != 62 \
	or int(runtime.get("accepted_live_module_mesh_count", -1)) != 546 \
	or int(runtime.get("accepted_live_module_triangle_count", -1)) != 6552 \
	or int(runtime.get("pending_independent_actual_world_art_review_live_module_target_receiver_count", -1)) != 0 \
	or int(runtime.get("pending_independent_actual_world_art_review_live_module_placement_count", -1)) != 0 \
	or (runtime.get("pending_independent_actual_world_art_review_runtime_attachments", []) as Array).size() != 0:
		return false
	return w34313564_live_helper.count("CAL-") >= 5 \
		and "EXPECTED_MODULE_INSTANCES := 5" in w34313564_live_helper \
		and "EXPECTED_MESH_INSTANCES := 34" in w34313564_live_helper \
		and w34313515_live_helper.count("CAL-") >= 4 \
		and "EXPECTED_MODULE_INSTANCES := 4" in w34313515_live_helper \
		and "EXPECTED_MESH_INSTANCES := 84" in w34313515_live_helper \
		and "backing_meshes\": 0" in w34313515_live_helper \
		and "collision_nodes\": 0" in w34313515_live_helper \
		and "navigation_nodes\": 0" in w34313515_live_helper \
		and "spray_nodes\": 0" in w34313515_live_helper \
		and w291196370_live_helper.count("CAL-") >= 3 \
		and "EXPECTED_MODULE_INSTANCES := 3" in w291196370_live_helper \
		and "EXPECTED_MESH_INSTANCES := 24" in w291196370_live_helper \
		and "backing_meshes\": 0" in w291196370_live_helper \
		and "collision_nodes\": 0" in w291196370_live_helper \
		and "navigation_nodes\": 0" in w291196370_live_helper \
		and "spray_nodes\": 0" in w291196370_live_helper \
		and "EXPECTED_PLACEMENT_ID := \"CAL-SSE-BAY-01\"" in w34313520_live_helper \
		and "EXPECTED_MESH_INSTANCES := 15" in w34313520_live_helper \
		and "backing_meshes\": 0" in w34313520_live_helper \
		and "collision_nodes\": 0" in w34313520_live_helper \
		and "navigation_nodes\": 0" in w34313520_live_helper \
		and "spray_nodes\": 0" in w34313520_live_helper \
		and w34313525_live_helper.count("CAL-") >= 4 \
		and "EXPECTED_MODULE_INSTANCES := 4" in w34313525_live_helper \
		and "EXPECTED_MESH_INSTANCES := 38" in w34313525_live_helper \
		and "backing_meshes\": 0" in w34313525_live_helper \
		and "collision_nodes\": 0" in w34313525_live_helper \
		and "navigation_nodes\": 0" in w34313525_live_helper \
		and "spray_nodes\": 0" in w34313525_live_helper


func _blocked_targets_have_no_assets(registry: Dictionary) -> bool:
	var text := JSON.stringify(registry)
	if not "reference-blocked" in text:
		return false
	for path in ["res://game/resources/materials/world/w1222514695", "res://game/resources/materials/world/w1222720021", "res://game/scenes/world/facades/batch_06/w1222514695_prototype_set.tscn", "res://game/scenes/world/facades/batch_06/w1222720021_prototype_set.tscn"]:
		if ResourceLoader.exists(path) or DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path)):
			return false
	return true


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
