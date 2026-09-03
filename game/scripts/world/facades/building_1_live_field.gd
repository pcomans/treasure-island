class_name Building1LiveField
extends RefCounted

const SOURCE_KEY := "r16681702"
const RECEIVER_KEY := "building:r16681702:wall"
const REGISTRY_PATH := "res://game/resources/facades/building_1_exact_receiver_calibration.json"
const REVIEWED_HELPER_PATH := "res://game/tests/support/building_1_exact_receiver_calibration.gd"
const INDEPENDENT_REVIEW_PATH := "res://discovery/facades/TREASURE_ISLAND_BUILDING_1_EXACT_RECEIVER_MITER_CORRECTION_ART_REVIEW.md"
const EXPECTED_REGISTRY_SHA256 := "10ab1f25d0f9d37ccbb20be9dfe77a37c66f63918b1fdf070c1de9c61633414a"
const EXPECTED_REVIEWED_HELPER_SHA256 := "3a494ba38436b9f68ad02ddaf4e454a0a53c84a777a2999111a67dcc55dae75c"
const EXPECTED_INDEPENDENT_REVIEW_SHA256 := "499f24ae196a42c9c27737fb484c690bd2f228a0ebcc5ba3622606958cd1179e"
const EXPECTED_FIELD_MATERIAL_SHA256 := "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a"
const EXPECTED_FIELD_SHADER_SHA256 := "a4a5df4fbb8fd4f13187ec284708879b540677ac2c827642b4c3040b4bce4c09"
const FIELD_MATERIAL_PATH := "res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres"
const FIELD_SHADER_PATH := "res://game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader"
const ACTUAL_WORLD_REVIEW_STATUS := "pending_independent_actual_world_art_review"
const RENDER_BUILDING_WALL := 1 << 1

const REVIEWED_CALIBRATION := preload("res://game/tests/support/building_1_exact_receiver_calibration.gd")


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == RECEIVER_KEY \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))


static func build(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return _failure("building_1_live_field_receiver", "Building 1 live field receiver identity drifted.", record)
	# Export templates remap imported sources and omit authoring reviews; the
	# semantic registry/geometry contract below remains the packaged gate.
	if OS.has_feature("editor") and (
		FileAccess.get_sha256(REGISTRY_PATH) != EXPECTED_REGISTRY_SHA256 \
		or FileAccess.get_sha256(REVIEWED_HELPER_PATH) != EXPECTED_REVIEWED_HELPER_SHA256 \
		or FileAccess.get_sha256(INDEPENDENT_REVIEW_PATH) != EXPECTED_INDEPENDENT_REVIEW_SHA256 \
		or FileAccess.get_sha256(FIELD_MATERIAL_PATH) != EXPECTED_FIELD_MATERIAL_SHA256 \
		or FileAccess.get_sha256(FIELD_SHADER_PATH) != EXPECTED_FIELD_SHADER_SHA256
	):
		return _failure("building_1_live_field_reviewed_input", "A reviewed Building 1 field, helper, registry, or independent review byte drifted.", record)
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not registry_value is Dictionary:
		return _failure("building_1_live_field_registry", "Building 1 exact registry did not parse.", record)
	var registry := registry_value as Dictionary
	if not _registry_matches(registry):
		return _failure("building_1_live_field_scope", "Building 1 registry no longer describes exact field-only runs 21..51.", record)
	var reviewed := REVIEWED_CALIBRATION.build(record, registry)
	if not bool(reviewed.get("ok", false)):
		return reviewed
	var detached_root := reviewed.get("node") as Node3D
	if detached_root == null or detached_root.get_child_count() != 3:
		if detached_root != null:
			detached_root.free()
		return _failure("building_1_live_field_geometry", "Reviewed Building 1 calibration root drifted.", record)
	var field := detached_root.get_node_or_null("DetachedExactPublicCurveFieldRuns21To51") as MeshInstance3D
	if field == null or not _field_matches(field):
		detached_root.free()
		return _failure("building_1_live_field_geometry", "Reviewed Building 1 shared-miter field failed its live render-only contract.", record)
	var field_transform := field.transform
	detached_root.remove_child(field)
	detached_root.free()
	if not field.transform.is_equal_approx(field_transform):
		field.free()
		return _failure("building_1_live_field_transform", "Building 1 field transform drifted while detaching blocked fit studies.", record)
	field.name = "B1_MAT_IVORY_Runs21To51"
	field.layers = RENDER_BUILDING_WALL
	field.set_meta("runtime_attachment", true)
	field.set_meta("actual_world_review_status", ACTUAL_WORLD_REVIEW_STATUS)
	field.set_meta("independent_detached_review_sha256", EXPECTED_INDEPENDENT_REVIEW_SHA256)
	var root := Node3D.new()
	root.name = "Building1LiveIvoryField"
	root.add_child(field)
	var resolved_scope := (reviewed.get("resolved_field_scope", {}) as Dictionary).duplicate(true)
	var metadata := {
		"source_key": SOURCE_KEY,
		"receiver_key": RECEIVER_KEY,
		"runtime_attachment": true,
		"actual_world_review_status": ACTUAL_WORLD_REVIEW_STATUS,
		"field_id": "B1-MAT-IVORY",
		"asset_kind": "homogeneous_material_tile",
		"exact_ordered_runs": _expected_runs(),
		"run_count": 31,
		"physical_length_m": 85.939934,
		"surface_area_m2": 1740.731069,
		"field_meshes": 1,
		"field_surfaces": 1,
		"field_triangles": 62,
		"module_placements": 0,
		"module_meshes": 0,
		"collision_nodes": 0,
		"navigation_nodes": 0,
		"spray_nodes": 0,
		"overlay_offset_m": 0.018,
		"join_geometry": "shared_xz_mitered_offset_junctions",
		"internal_join_count": 30,
		"maximum_shared_miter_gap_m": 0.0,
		"maximum_join_phase_delta_m": 0.0,
		"uv_contract": "UV.x cumulative ordered horizontal chain metres from run 21 start; UV.y source world Y metres",
		"surveyed_material_scale": false,
		"surveyed_color": false,
		"completed_public_elevation": false,
		"whole_building_accepted": false,
		"registry_path": REGISTRY_PATH,
		"registry_sha256": EXPECTED_REGISTRY_SHA256,
		"reviewed_helper_path": REVIEWED_HELPER_PATH,
		"reviewed_helper_sha256": EXPECTED_REVIEWED_HELPER_SHA256,
		"independent_detached_review_path": INDEPENDENT_REVIEW_PATH,
		"independent_detached_review_sha256": EXPECTED_INDEPENDENT_REVIEW_SHA256,
		"resolved_field_scope": resolved_scope,
	}
	for key: String in metadata:
		root.set_meta(key, metadata[key])
	return {"ok": true, "node": root, "mesh_instances": 1, "surfaces": 1, "triangles": 62, "metadata": metadata, "resolved_field_scope": resolved_scope}


static func _registry_matches(registry: Dictionary) -> bool:
	var target := registry.get("target", {}) as Dictionary
	var field := registry.get("exact_field_scope", {}) as Dictionary
	var studies := registry.get("fit_studies", []) as Array
	return str(target.get("source_key", "")) == SOURCE_KEY \
		and str(target.get("receiver_key", "")) == RECEIVER_KEY \
		and int(target.get("run_count", -1)) == 110 \
		and _int_array(field.get("exact_ordered_runs", []) as Array) == _expected_runs() \
		and int(field.get("run_count", -1)) == 31 \
		and absf(float(field.get("physical_wall_length_m", 0.0)) - 85.939934) < 0.000001 \
		and absf(float(field.get("generated_mesh_surface_area_m2", 0.0)) - 1740.731069) < 0.000001 \
		and not bool(field.get("runtime_attachment", true)) \
		and studies.size() == 2 \
		and not bool((studies[0] as Dictionary).get("real_placement_authorized", true)) \
		and not bool((studies[1] as Dictionary).get("real_placement_authorized", true))


static func _field_matches(field: MeshInstance3D) -> bool:
	var mesh := field.mesh as ArrayMesh
	if mesh == null or mesh.get_surface_count() != 1 \
	or mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size() != 124 \
	or mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX].size() != 186 \
	or field.material_override == null \
	or field.material_override.resource_path != FIELD_MATERIAL_PATH \
	or field.get_meta("exact_ordered_runs", []) != _expected_runs() \
	or str(field.get_meta("join_geometry", "")) != "shared_xz_mitered_offset_junctions" \
	or float(field.get_meta("maximum_rendered_join_gap_after_m", -1.0)) != 0.0:
		return false
	return _count_type(field, CollisionObject3D) == 0 \
		and _count_type(field, CollisionShape3D) == 0 \
		and _count_type(field, NavigationRegion3D) == 0 \
		and _count_type(field, Decal) == 0


static func _expected_runs() -> Array[int]:
	var runs: Array[int] = []
	for run_index in range(21, 52):
		runs.append(run_index)
	return runs


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	return {"ok": false, "code": code, "message": message, "source_keys": record.get("source_keys", [])}
