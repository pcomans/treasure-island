class_name Building1LiveField
extends RefCounted

const SOURCE_KEY := "r16681702"
const RECEIVER_KEY := "building:r16681702:wall"
const REGISTRY_PATH := "res://game/resources/facades/building_1_exact_receiver_calibration.json"
const REVIEWED_HELPER_PATH := "res://game/tests/support/building_1_exact_receiver_calibration.gd"
const INDEPENDENT_REVIEW_PATH := "res://discovery/facades/TREASURE_ISLAND_BUILDING_1_EXACT_RECEIVER_MITER_CORRECTION_ART_REVIEW.md"
const FIELD_MATERIAL_PATH := "res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres"
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
		return _failure("building_1_live_field_receiver", "Building 1 live field receiver identity does not match.", record)
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
	var root := Node3D.new()
	root.name = "Building1LiveIvoryField"
	root.add_child(field)
	var resolved_scope := (reviewed.get("resolved_field_scope", {}) as Dictionary).duplicate(true)
	var metadata := {
		"source_key": SOURCE_KEY,
		"receiver_key": RECEIVER_KEY,
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
		"registry_path": REGISTRY_PATH,
		"reviewed_helper_path": REVIEWED_HELPER_PATH,
		"independent_detached_review_path": INDEPENDENT_REVIEW_PATH,
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
		and studies.size() == 2


static func _field_matches(field: MeshInstance3D) -> bool:
	var mesh := field.mesh as ArrayMesh
	if mesh == null or mesh.get_surface_count() != 1 \
	or mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX].size() == 0 \
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
