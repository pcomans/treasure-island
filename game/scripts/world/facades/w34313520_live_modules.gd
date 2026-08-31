class_name W34313520LiveModules
extends RefCounted

const RECEIVER_KEY := "building:w34313520:wall"
const SOURCE_KEY := "w34313520"
const REGISTRY_PATH := "res://game/resources/facades/w34313520_exact_receiver_calibration.json"
const REVIEWED_HELPER_PATH := "res://game/tests/support/w34313520_exact_receiver_calibration.gd"
const ART_REVIEW_PATH := "res://discovery/facades/W34313520_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md"
const EXPECTED_REGISTRY_SHA256 := "28ea8b6e506d747299a920e4d456d8676031e18ec3b6d9e959cab31fa33de4f1"
const EXPECTED_REVIEWED_HELPER_SHA256 := "d747d9f9ca5798b09909efeeb930cdee119f1b3c310e95f9a2c426a3ee6ceea4"
const EXPECTED_ART_REVIEW_SHA256 := "555eb2fb3a397341cc6ed6412a627b9d84fe8c806de756c2ed4cbd8a3a652870"
const PLACEMENT_ROLE := "stylized/reference-derived production inference"
const ACTUAL_WORLD_REVIEW_STATUS := "pending_independent_actual_world_art_review"
const RENDER_BUILDING_WALL := 1 << 1
const EXPECTED_PLACEMENT_ID := "CAL-SSE-BAY-01"
const EXPECTED_MESH_INSTANCES := 15
const EXPECTED_SURFACES := 15
const EXPECTED_TRIANGLES := 180

const REVIEWED_CALIBRATION := preload("res://game/tests/support/w34313520_exact_receiver_calibration.gd")


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == RECEIVER_KEY \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))


static func build(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return _failure("w34313520_live_module_receiver", "Live BAY target receiver identity drifted.", record)
	if FileAccess.get_sha256(REGISTRY_PATH) != EXPECTED_REGISTRY_SHA256 \
	or FileAccess.get_sha256(REVIEWED_HELPER_PATH) != EXPECTED_REVIEWED_HELPER_SHA256 \
	or FileAccess.get_sha256(ART_REVIEW_PATH) != EXPECTED_ART_REVIEW_SHA256:
		return _failure("w34313520_live_module_reviewed_input", "Reviewed field/BAY registry, exact helper, or independent calibration review bytes drifted.", record)
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not (registry_value is Dictionary):
		return _failure("w34313520_live_module_registry", "Reviewed exact-receiver registry did not parse.", record)
	var registry := registry_value as Dictionary
	if not _registry_matches_exact_live_scope(registry):
		return _failure("w34313520_live_module_scope", "Reviewed registry no longer matches the exact authorized field and one-BAY scope.", record)
	var reviewed := REVIEWED_CALIBRATION.build(record, registry)
	if not bool(reviewed.get("ok", false)):
		return reviewed
	var detached_root := reviewed.get("node") as Node3D
	if detached_root == null:
		return _failure("w34313520_live_module_geometry", "Reviewed calibration did not produce a detached root.", record)
	var detached_field := detached_root.get_node_or_null("DetachedExactSSEFieldRuns06To10") as MeshInstance3D
	var bay := detached_root.get_node_or_null("CAL_SSE_BAY_01") as Node3D
	if detached_field == null or bay == null \
	or not _detached_field_matches_reviewed_scope(detached_field) \
	or not _promote_bay_to_live(bay, registry):
		detached_root.free()
		return _failure("w34313520_live_module_geometry", "Reviewed field/BAY output failed the exact render-only live attachment contract.", record)
	var reviewed_transform := bay.transform
	detached_root.remove_child(bay)
	detached_root.free()
	var live_root := Node3D.new()
	live_root.name = "W34313520LiveModules"
	live_root.add_child(bay)
	if not bay.transform.is_equal_approx(reviewed_transform):
		live_root.free()
		return _failure("w34313520_live_module_transform", "Live BAY transform drifted while detaching the reviewed motif from its capture-only field.", record)
	var topology := _render_topology(live_root)
	if int(topology.mesh_instances) != EXPECTED_MESH_INSTANCES \
	or int(topology.surfaces) != EXPECTED_SURFACES \
	or int(topology.triangles) != EXPECTED_TRIANGLES:
		live_root.free()
		return _failure("w34313520_live_module_topology", "Reviewed BAY live render topology drifted.", record)
	var resolved := (reviewed.get("resolved_placement", {}) as Dictionary).duplicate(true)
	var metadata := {
		"source_key": SOURCE_KEY,
		"receiver_key": RECEIVER_KEY,
		"runtime_attachment": true,
		"placement_review_verdict": "ACCEPT_WITH_DOCUMENTED_LIMITATION",
		"actual_world_review_status": ACTUAL_WORLD_REVIEW_STATUS,
		"placement_role": PLACEMENT_ROLE,
		"module_instances": 1,
		"motif_instance_counts": {"W34313520-BAY": 1},
		"asset_classification": "module_atlas",
		"complete_motif": true,
		"module_not_seamless_tile": true,
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
		"total_opening_count_inferred": false,
		"completed_sse_elevation": false,
		"cross_side_transfer_accepted": false,
		"whole_building_accepted": false,
		"reviewed_registry_path": REGISTRY_PATH,
		"reviewed_registry_sha256": EXPECTED_REGISTRY_SHA256,
		"reviewed_geometry_helper_path": REVIEWED_HELPER_PATH,
		"reviewed_geometry_helper_sha256": EXPECTED_REVIEWED_HELPER_SHA256,
		"independent_calibration_review_path": ART_REVIEW_PATH,
		"independent_calibration_review_sha256": EXPECTED_ART_REVIEW_SHA256,
		"resolved_placement": resolved,
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
		"resolved_placement": resolved,
	}


static func _registry_matches_exact_live_scope(registry: Dictionary) -> bool:
	var field := registry.get("exact_field_scope", {}) as Dictionary
	var module := registry.get("module_contract", {}) as Dictionary
	var policy := registry.get("placement_policy", {}) as Dictionary
	var placement := registry.get("placement", {}) as Dictionary
	var parameters := field.get("material_parameters", {}) as Dictionary
	return str((registry.get("target", {}) as Dictionary).get("receiver_key", "")) == RECEIVER_KEY \
		and _int_array(field.get("exact_ordered_runs", []) as Array) == [6, 7, 8, 9, 10] \
		and str(field.get("material_id", "")) == "W34313520-MAT-PALE" \
		and str(field.get("asset_kind", "")) == "homogeneous_material_tile" \
		and is_equal_approx(float(field.get("physical_wall_length_m", -1.0)), 68.156) \
		and str(field.get("exact_trial_material_sha256", "")) == "89fbb97ed797275a86c394af7eab13f946cbf23f29cba58b89a2b2d467030ab2" \
		and is_equal_approx(float(parameters.get("primary_scale_m", -1.0)), 0.95) \
		and is_equal_approx(float(parameters.get("secondary_scale_m", -1.0)), 0.29) \
		and not bool(field.get("surveyed_scale", true)) \
		and not bool(field.get("completed_elevation", true)) \
		and not bool(field.get("whole_building_accepted", true)) \
		and str(module.get("motif_id", "")) == "W34313520-BAY" \
		and str(module.get("asset_kind", "")) == "module_atlas" \
		and bool(module.get("complete_motif", false)) \
		and bool(module.get("module_not_seamless_wall_tile", false)) \
		and not bool(module.get("module_owns_field_geometry", true)) \
		and int(module.get("mesh_instances", -1)) == EXPECTED_MESH_INSTANCES \
		and int(module.get("field_or_backing_meshes", -1)) == 0 \
		and int(policy.get("placement_count", -1)) == 1 \
		and str(policy.get("position_status", "")) == "stylized_reference_derived_production_inference_not_surveyed" \
		and str(policy.get("cadence_status", "")) == "unknown_not_surveyed_not_inferred" \
		and int(policy.get("collision_nodes", -1)) == 0 \
		and int(policy.get("navigation_nodes", -1)) == 0 \
		and int(policy.get("spray_nodes", -1)) == 0 \
		and str(placement.get("placement_id", "")) == EXPECTED_PLACEMENT_ID \
		and str(placement.get("motif_id", "")) == "W34313520-BAY" \
		and str(placement.get("face", "")) == "SSE" \
		and str(placement.get("region", "")) == "observed_long_SSE_outer_elevation" \
		and int(placement.get("anchor_run", -1)) == 7 \
		and _int_array(placement.get("exact_ordered_runs", []) as Array) == [7] \
		and is_equal_approx(float(placement.get("along_run_center_m", -1.0)), 15.894477) \
		and not bool(placement.get("surveyed_dimensions", true)) \
		and not bool(placement.get("surveyed_coordinates", true)) \
		and not bool(placement.get("surveyed_count", true)) \
		and not bool(placement.get("surveyed_cadence", true)) \
		and not bool(placement.get("completed_elevation", true)) \
		and not bool(placement.get("whole_building_accepted", true))


static func _detached_field_matches_reviewed_scope(field: MeshInstance3D) -> bool:
	var mesh := field.mesh as ArrayMesh
	return mesh != null \
		and field.material_override != null \
		and field.material_override.resource_path == "res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres" \
		and mesh.get_surface_count() == 1 \
		and _count_triangles(field) == 10 \
		and field.get_meta("exact_ordered_runs", []) == [6, 7, 8, 9, 10] \
		and not bool(field.get_meta("runtime_attachment", true))


static func _promote_bay_to_live(bay: Node3D, registry: Dictionary) -> bool:
	var placement := registry.get("placement", {}) as Dictionary
	if bay.get_child_count() != EXPECTED_MESH_INSTANCES \
	or _count_type(bay, CollisionObject3D) != 0 \
	or _count_type(bay, CollisionShape3D) != 0 \
	or _count_type(bay, NavigationRegion3D) != 0 \
	or _count_type(bay, Decal) != 0 \
	or str(bay.get_meta("placement_id", "")) != EXPECTED_PLACEMENT_ID:
		return false
	bay.set_meta("runtime_attachment", true)
	bay.set_meta("placement_role", PLACEMENT_ROLE)
	bay.set_meta("actual_world_review_status", ACTUAL_WORLD_REVIEW_STATUS)
	bay.set_meta("host_material_id", "W34313520-MAT-PALE")
	bay.set_meta("run_ownership", [7])
	bay.set_meta("exact_ordered_runs", [7])
	bay.set_meta("anchor_run", 7)
	bay.set_meta("along_run_center_m", 15.894477)
	bay.set_meta("along_run_center_uncertainty_m", float(placement.get("center_uncertainty_half_span_m", -1.0)))
	bay.set_meta("coordinates_surveyed", false)
	bay.set_meta("dimensions_surveyed", false)
	bay.set_meta("scale_surveyed", false)
	bay.set_meta("count_surveyed", false)
	bay.set_meta("cadence_inferred", false)
	bay.set_meta("total_opening_count_inferred", false)
	bay.set_meta("completed_sse_elevation", false)
	bay.set_meta("cross_side_transfer_accepted", false)
	bay.set_meta("whole_building_accepted", false)
	bay.set_meta("complete_motif", true)
	bay.set_meta("module_not_seamless_tile", true)
	bay.set_meta("module_owns_field_geometry", false)
	for child: Node in bay.get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null or not (mesh_instance.mesh is BoxMesh) \
		or mesh_instance.material_override == null \
		or "field" in str(mesh_instance.name).to_lower() \
		or "backing" in str(mesh_instance.name).to_lower() \
		or "surround" in str(mesh_instance.name).to_lower():
			return false
		mesh_instance.layers = RENDER_BUILDING_WALL
		var box := mesh_instance.mesh as BoxMesh
		var back_clearance := REVIEWED_CALIBRATION.BAY_WALL_OFFSET_M + mesh_instance.position.z - box.size.z * 0.5
		var front_depth := REVIEWED_CALIBRATION.BAY_WALL_OFFSET_M + mesh_instance.position.z + box.size.z * 0.5
		# The reviewed source resolves to 0.315 m at the outer frame face; the
		# registry's 0.31 m value is rounded evidence prose, not a rescale order.
		if back_clearance < 0.001 or front_depth > 0.316:
			return false
	return true


static func _render_topology(node: Node) -> Dictionary:
	var result := {"mesh_instances": 0, "surfaces": 0, "triangles": 0}
	if node is MeshInstance3D:
		var mesh := (node as MeshInstance3D).mesh
		if mesh != null:
			result.mesh_instances = 1
			result.surfaces = mesh.get_surface_count()
			result.triangles = _count_triangles(node)
	for child: Node in node.get_children():
		var child_result := _render_topology(child)
		result.mesh_instances += int(child_result.mesh_instances)
		result.surfaces += int(child_result.surfaces)
		result.triangles += int(child_result.triangles)
	return result


static func _count_triangles(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mesh := (node as MeshInstance3D).mesh
		for surface_index in mesh.get_surface_count():
			var arrays := mesh.surface_get_arrays(surface_index)
			count += int((arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
	for child: Node in node.get_children():
		count += _count_triangles(child)
	return count


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
