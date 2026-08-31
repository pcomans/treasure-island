class_name W34313525LiveModules
extends RefCounted

const RECEIVER_KEY := "building:w34313525:wall"
const SOURCE_KEY := "w34313525"
const REGISTRY_PATH := "res://game/resources/facades/w34313525_exact_receiver_calibration.json"
const REVIEWED_HELPER_PATH := "res://game/tests/support/w34313525_exact_receiver_calibration.gd"
const ART_REVIEW_PATH := "res://discovery/facades/W34313525_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md"
const EXPECTED_REGISTRY_SHA256 := "ba22916618510f610719606c1c18f84b8965bbd76fe74eddc5430745470bbddd"
const EXPECTED_REVIEWED_HELPER_SHA256 := "a9ff1f94274509cdb39c6208117c59b84ba67598ff8a59a1eb57bf30a4b03532"
const EXPECTED_ART_REVIEW_SHA256 := "d19fdae403d11117b13ce1fe04476f0d62edfdd3adbc8238936845e481831de2"
const PLACEMENT_ROLE := "stylized/reference-derived production inference"
const ACTUAL_WORLD_REVIEW_STATUS := "pending_independent_actual_world_art_review"
const RENDER_BUILDING_WALL := 1 << 1
const EXPECTED_MODULE_INSTANCES := 4
const EXPECTED_MESH_INSTANCES := 38
const EXPECTED_SURFACES := 38
const EXPECTED_TRIANGLES := 456
const EXPECTED_PLACEMENTS := {
	"CAL-SSE-ROLLUP-PALE-01": {"motif_id": "W34313525-ROLLUP-PALE", "face": "SSE", "region": "SSE central outer service elevation", "mapping_id": "B06-34313525-SSE-CENTRAL", "anchor_run": 9, "along_run_center_m": 13.862233, "uncertainty_m": 11.262233, "mesh_count": 13},
	"CAL-SSE-ROLLUP-GRAY-01": {"motif_id": "W34313525-ROLLUP-GRAY", "face": "SSE", "region": "SSE central outer service elevation", "mapping_id": "B06-34313525-SSE-CENTRAL", "anchor_run": 10, "along_run_center_m": 16.003442, "uncertainty_m": 13.403442, "mesh_count": 13},
	"CAL-NNW-PERSONNEL-01": {"motif_id": "W34313525-PERSONNEL", "face": "NNW", "region": "NNW central outer service elevation", "mapping_id": "B06-34313525-NNW-CENTRAL", "anchor_run": 26, "along_run_center_m": 4.269684, "uncertainty_m": 3.444684, "mesh_count": 5},
	"CAL-NNW-HIGH-GROUP-01": {"motif_id": "W34313525-HIGH-GROUP", "face": "NNW", "region": "NNW central outer service elevation", "mapping_id": "B06-34313525-NNW-CENTRAL", "anchor_run": 27, "along_run_center_m": 3.698596, "uncertainty_m": 1.298596, "mesh_count": 7},
}

const REVIEWED_CALIBRATION := preload("res://game/tests/support/w34313525_exact_receiver_calibration.gd")


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == RECEIVER_KEY \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))


static func build(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return _failure("w34313525_live_module_receiver", "Live four-motif target receiver identity drifted.", record)
	if FileAccess.get_sha256(REGISTRY_PATH) != EXPECTED_REGISTRY_SHA256 \
	or FileAccess.get_sha256(REVIEWED_HELPER_PATH) != EXPECTED_REVIEWED_HELPER_SHA256 \
	or FileAccess.get_sha256(ART_REVIEW_PATH) != EXPECTED_ART_REVIEW_SHA256:
		return _failure("w34313525_live_module_reviewed_input", "Reviewed registry, exact helper, or independent calibration review bytes drifted.", record)
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not (registry_value is Dictionary):
		return _failure("w34313525_live_module_registry", "Reviewed exact-receiver registry did not parse.", record)
	var registry := registry_value as Dictionary
	if not _registry_matches_exact_live_scope(registry):
		return _failure("w34313525_live_module_scope", "Reviewed registry no longer matches the exact two-field/four-placement authorization.", record)
	var reviewed := REVIEWED_CALIBRATION.build(record, registry)
	if not bool(reviewed.get("ok", false)):
		return reviewed
	var detached_root := reviewed.get("node") as Node3D
	if detached_root == null:
		return _failure("w34313525_live_module_geometry", "Reviewed calibration did not produce a detached root.", record)
	var reviewed_transforms := {}
	var live_modules: Array[Node3D] = []
	for placement_id: String in EXPECTED_PLACEMENTS:
		var module := detached_root.get_node_or_null(placement_id.replace("-", "_")) as Node3D
		if module == null or not _promote_module_to_live(module, registry):
			detached_root.free()
			return _failure("w34313525_live_module_geometry", "Reviewed module %s failed the render-only live attachment contract." % placement_id, record)
		reviewed_transforms[placement_id] = module.transform
		detached_root.remove_child(module)
		live_modules.append(module)
	detached_root.free()
	var live_root := Node3D.new()
	live_root.name = "W34313525LiveModules"
	for module: Node3D in live_modules:
		live_root.add_child(module)
		var placement_id := str(module.get_meta("placement_id", ""))
		if not module.transform.is_equal_approx(reviewed_transforms[placement_id] as Transform3D):
			live_root.free()
			return _failure("w34313525_live_module_transform", "Live module %s transform drifted while detaching it from calibration-only field overlays." % placement_id, record)
	var topology := _render_topology(live_root)
	if int(topology.mesh_instances) != EXPECTED_MESH_INSTANCES \
	or int(topology.surfaces) != EXPECTED_SURFACES \
	or int(topology.triangles) != EXPECTED_TRIANGLES:
		live_root.free()
		return _failure("w34313525_live_module_topology", "Reviewed four-motif live render topology drifted.", record)
	var resolved_placements := (reviewed.get("resolved_placements", []) as Array).duplicate(true)
	var metadata := {
		"source_key": SOURCE_KEY,
		"receiver_key": RECEIVER_KEY,
		"runtime_attachment": true,
		"placement_review_verdict": "ACCEPT_WITH_DOCUMENTED_LIMITATION",
		"actual_world_review_status": ACTUAL_WORLD_REVIEW_STATUS,
		"placement_role": PLACEMENT_ROLE,
		"module_instances": EXPECTED_MODULE_INSTANCES,
		"motif_instance_counts": {
			"W34313525-ROLLUP-PALE": 1,
			"W34313525-ROLLUP-GRAY": 1,
			"W34313525-PERSONNEL": 1,
			"W34313525-HIGH-GROUP": 1,
		},
		"asset_classification": "module_atlas",
		"complete_motif": true,
		"module_not_seamless_tile": true,
		"high_group_semantic_face_status": "window_or_grille_not_disambiguated_opaque_proxy_only",
		"mesh_instances": int(topology.mesh_instances),
		"surfaces": int(topology.surfaces),
		"triangles": int(topology.triangles),
		"field_meshes": 0,
		"backing_meshes": 0,
		"collision_nodes": 0,
		"navigation_nodes": 0,
		"spray_nodes": 0,
		"surveyed_dimensions": false,
		"surveyed_coordinates": false,
		"surveyed_scale": false,
		"surveyed_count": false,
		"surveyed_cadence": false,
		"cadence_inferred": false,
		"sequence_inferred": false,
		"maximum_uncertainty_envelope_contained_for_all_modules": false,
		"completed_sse_elevation": false,
		"completed_nnw_elevation": false,
		"cross_side_transfer_accepted": false,
		"whole_building_accepted": false,
		"reviewed_registry_path": REGISTRY_PATH,
		"reviewed_registry_sha256": EXPECTED_REGISTRY_SHA256,
		"reviewed_geometry_helper_path": REVIEWED_HELPER_PATH,
		"reviewed_geometry_helper_sha256": EXPECTED_REVIEWED_HELPER_SHA256,
		"independent_calibration_review_path": ART_REVIEW_PATH,
		"independent_calibration_review_sha256": EXPECTED_ART_REVIEW_SHA256,
		"resolved_placements": resolved_placements,
	}
	for key: String in metadata:
		live_root.set_meta(key, metadata[key])
	return {
		"ok": true,
		"node": live_root,
		"mesh_instances": int(topology.mesh_instances),
		"surfaces": int(topology.surfaces),
		"triangles": int(topology.triangles),
		"metadata": metadata,
		"resolved_placements": resolved_placements,
	}


static func _registry_matches_exact_live_scope(registry: Dictionary) -> bool:
	var target := registry.get("target", {}) as Dictionary
	var scopes := registry.get("exact_field_scopes", []) as Array
	var contracts := registry.get("module_contracts", []) as Array
	var policy := registry.get("placement_policy", {}) as Dictionary
	var field_contract := registry.get("field_material_contract", {}) as Dictionary
	var field_parameters := field_contract.get("material_parameters", {}) as Dictionary
	if str(target.get("receiver_key", "")) != RECEIVER_KEY \
	or int(target.get("run_count", -1)) != 30 \
	or scopes.size() != 2 \
	or contracts.size() != 4 \
	or int(policy.get("placement_count", -1)) != EXPECTED_MODULE_INSTANCES \
	or str(policy.get("position_status", "")) != "stylized_reference_derived_production_inference_not_surveyed" \
	or str(policy.get("cadence_status", "")) != "unknown_not_surveyed_not_inferred" \
	or not is_equal_approx(float(field_parameters.get("primary_scale_m", -1.0)), 0.88) \
	or not is_equal_approx(float(field_parameters.get("secondary_scale_m", -1.0)), 0.31) \
	or int(policy.get("collision_nodes", -1)) != 0 \
	or int(policy.get("navigation_nodes", -1)) != 0 \
	or int(policy.get("spray_nodes", -1)) != 0:
		return false
	var scope_runs := {}
	for value: Variant in scopes:
		var scope := value as Dictionary
		scope_runs[str(scope.get("scope_id", ""))] = _int_array(scope.get("exact_ordered_runs", []) as Array)
		if str(scope.get("material_id", "")) != "W34313525-MAT-PALE" \
		or str(scope.get("asset_kind", "")) != "homogeneous_material_tile" \
		or bool(scope.get("surveyed_scale", true)) \
		or bool(scope.get("completed_elevation", true)) \
		or bool(scope.get("whole_building_accepted", true)):
			return false
	if scope_runs != {"CAL-FIELD-SSE-PALE-01": [8, 9, 10, 11, 12], "CAL-FIELD-NNW-PALE-01": [26, 27]}:
		return false
	var contract_ids: Array[String] = []
	for value: Variant in contracts:
		var contract := value as Dictionary
		contract_ids.append(str(contract.get("motif_id", "")))
		if str(contract.get("asset_kind", "")) != "module_atlas" \
		or not bool(contract.get("complete_motif", false)) \
		or not bool(contract.get("module_not_seamless_wall_tile", false)) \
		or bool(contract.get("module_owns_field_geometry", true)):
			return false
	contract_ids.sort()
	if contract_ids != ["W34313525-HIGH-GROUP", "W34313525-PERSONNEL", "W34313525-ROLLUP-GRAY", "W34313525-ROLLUP-PALE"]:
		return false
	var seen := {}
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		var placement_id := str(placement.get("placement_id", ""))
		var expected := EXPECTED_PLACEMENTS.get(placement_id, {}) as Dictionary
		if expected.is_empty() or seen.has(placement_id):
			return false
		seen[placement_id] = true
		if str(placement.get("motif_id", "")) != str(expected.motif_id) \
		or str(placement.get("face", "")) != str(expected.face) \
		or str(placement.get("region", "")) != str(expected.region) \
		or str(placement.get("mapping_id", "")) != str(expected.mapping_id) \
		or int(placement.get("anchor_run", -1)) != int(expected.anchor_run) \
		or _int_array(placement.get("exact_ordered_runs", []) as Array) != [int(expected.anchor_run)] \
		or not is_equal_approx(float(placement.get("along_run_center_m", -1.0)), float(expected.along_run_center_m)) \
		or bool(placement.get("surveyed_dimensions", true)) \
		or bool(placement.get("surveyed_coordinates", true)) \
		or bool(placement.get("surveyed_count", true)) \
		or bool(placement.get("surveyed_cadence", true)) \
		or bool(placement.get("completed_elevation", true)) \
		or bool(placement.get("whole_building_accepted", true)):
			return false
	return seen.size() == EXPECTED_PLACEMENTS.size()


static func _promote_module_to_live(module: Node3D, registry: Dictionary) -> bool:
	var placement_id := str(module.get_meta("placement_id", ""))
	var expected := EXPECTED_PLACEMENTS.get(placement_id, {}) as Dictionary
	var placement := _placement_for(registry, placement_id)
	if expected.is_empty() or placement.is_empty() \
	or module.get_child_count() != int(expected.mesh_count) \
	or _count_type(module, CollisionObject3D) != 0 \
	or _count_type(module, CollisionShape3D) != 0 \
	or _count_type(module, NavigationRegion3D) != 0 \
	or _count_type(module, Decal) != 0:
		return false
	module.set_meta("runtime_attachment", true)
	module.set_meta("placement_role", PLACEMENT_ROLE)
	module.set_meta("actual_world_review_status", ACTUAL_WORLD_REVIEW_STATUS)
	module.set_meta("host_material_id", "W34313525-MAT-PALE")
	module.set_meta("run_ownership", [int(expected.anchor_run)])
	module.set_meta("exact_ordered_runs", [int(expected.anchor_run)])
	module.set_meta("anchor_run", int(expected.anchor_run))
	module.set_meta("along_run_center_m", float(expected.along_run_center_m))
	module.set_meta("along_run_center_uncertainty_m", float(expected.uncertainty_m))
	module.set_meta("coordinates_surveyed", false)
	module.set_meta("dimensions_surveyed", false)
	module.set_meta("scale_surveyed", false)
	module.set_meta("count_surveyed", false)
	module.set_meta("cadence_surveyed", false)
	module.set_meta("cadence_inferred", false)
	module.set_meta("sequence_inferred", false)
	module.set_meta("completed_sse_elevation", false)
	module.set_meta("completed_nnw_elevation", false)
	module.set_meta("cross_side_transfer_accepted", false)
	module.set_meta("whole_building_accepted", false)
	module.set_meta("complete_motif", true)
	module.set_meta("module_not_seamless_tile", true)
	module.set_meta("module_owns_field_geometry", false)
	if str(expected.motif_id) == "W34313525-HIGH-GROUP":
		module.set_meta("semantic_face_status", "window_or_grille_not_disambiguated_opaque_proxy_only")
	for child: Node in module.get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null or not (mesh_instance.mesh is BoxMesh) \
		or mesh_instance.material_override == null \
		or "field" in str(mesh_instance.name).to_lower() \
		or "backing" in str(mesh_instance.name).to_lower() \
		or "surround" in str(mesh_instance.name).to_lower():
			return false
		mesh_instance.layers = RENDER_BUILDING_WALL
		var box := mesh_instance.mesh as BoxMesh
		var back_clearance := REVIEWED_CALIBRATION.MODULE_WALL_OFFSET_M + mesh_instance.position.z - box.size.z * 0.5
		if back_clearance < 0.001:
			return false
	return true


static func _render_topology(node: Node) -> Dictionary:
	var result := {"mesh_instances": 0, "surfaces": 0, "triangles": 0}
	if node is MeshInstance3D:
		var mesh := (node as MeshInstance3D).mesh
		if mesh != null:
			result.mesh_instances = 1
			result.surfaces = mesh.get_surface_count()
			for surface_index in mesh.get_surface_count():
				var arrays := mesh.surface_get_arrays(surface_index)
				result.triangles += int((arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
	for child: Node in node.get_children():
		var child_result := _render_topology(child)
		result.mesh_instances += int(child_result.mesh_instances)
		result.surfaces += int(child_result.surfaces)
		result.triangles += int(child_result.triangles)
	return result


static func _placement_for(registry: Dictionary, placement_id: String) -> Dictionary:
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		if str(placement.get("placement_id", "")) == placement_id:
			return placement
	return {}


static func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	return {"ok": false, "code": code, "message": message, "source_keys": record.get("source_keys", [])}
