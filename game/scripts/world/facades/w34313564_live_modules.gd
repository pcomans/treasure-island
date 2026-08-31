class_name W34313564LiveModules
extends RefCounted

const RECEIVER_KEY := "building:w34313564:wall"
const SOURCE_KEY := "w34313564"
const REGISTRY_PATH := "res://game/resources/facades/w34313564_module_calibration.json"
const REVIEWED_HELPER_PATH := "res://game/tests/support/w34313564_module_calibration.gd"
const EXPECTED_REGISTRY_SHA256 := "45a47d333c997887cef7d1c97a633d37ae050efda597186430c7af6d52116f0f"
const EXPECTED_REVIEWED_HELPER_SHA256 := "b49b8c20fbbe40f2728c0acadf8d53f0593856091e6df897a613d4f2f8680b71"
const PLACEMENT_ROLE := "stylized/reference-derived production inference"
const POSITION_UNCERTAINTY_M := 4.0
const RENDER_BUILDING_WALL := 1 << 1
const EXPECTED_MODULE_INSTANCES := 5
const EXPECTED_MESH_INSTANCES := 34
const EXPECTED_SURFACES := 34
const EXPECTED_TRIANGLES := 408
const EXPECTED_PLACEMENTS := {
	"CAL-SSE-PDOOR-01": {"motif_id": "W34313564-PDOOR", "face": "SSE", "mapping_id": "B06-34313564-SSE-CENTRAL", "anchor_run": 7, "center_chain_m": 47.5, "host_material_id": "W34313564-MAT-TAN"},
	"CAL-SSE-HWIN-01": {"motif_id": "W34313564-HWIN", "face": "SSE", "mapping_id": "B06-34313564-SSE-CENTRAL", "anchor_run": 8, "center_chain_m": 68.0, "host_material_id": "W34313564-MAT-TAN"},
	"CAL-ENE-HWIN-01": {"motif_id": "W34313564-HWIN", "face": "ENE", "mapping_id": "B06-34313564-ENE-END", "anchor_run": 12, "center_chain_m": 18.0, "host_material_id": "W34313564-MAT-PALE"},
	"CAL-NNW-PDOOR-01": {"motif_id": "W34313564-PDOOR", "face": "NNW", "mapping_id": "B06-34313564-NNW-OUTER", "anchor_run": 16, "center_chain_m": 32.0, "host_material_id": "W34313564-MAT-PALE"},
	"CAL-NNW-HWIN-01": {"motif_id": "W34313564-HWIN", "face": "NNW", "mapping_id": "B06-34313564-NNW-OUTER", "anchor_run": 17, "center_chain_m": 54.0, "host_material_id": "W34313564-MAT-PALE"},
}

const REVIEWED_CALIBRATION := preload("res://game/tests/support/w34313564_module_calibration.gd")


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == RECEIVER_KEY \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))


static func build(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return _failure("w34313564_live_module_receiver", "Live module target receiver identity drifted.", record)
	if FileAccess.get_sha256(REGISTRY_PATH) != EXPECTED_REGISTRY_SHA256 \
	or FileAccess.get_sha256(REVIEWED_HELPER_PATH) != EXPECTED_REVIEWED_HELPER_SHA256:
		return _failure("w34313564_live_module_reviewed_input", "Reviewed module registry or geometry helper bytes drifted.", record)
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not (registry_value is Dictionary):
		return _failure("w34313564_live_module_registry", "Reviewed module registry did not parse.", record)
	var registry := registry_value as Dictionary
	if not _registry_matches_exact_live_scope(registry):
		return _failure("w34313564_live_module_scope", "Reviewed module registry no longer matches the exact five authorized placements.", record)
	var result := REVIEWED_CALIBRATION.build(record, registry)
	if not bool(result.get("ok", false)):
		return result
	var live_root := result.get("node") as Node3D
	if live_root == null or not _promote_to_live_attachment(live_root, registry):
		if live_root != null:
			live_root.free()
		return _failure("w34313564_live_module_geometry", "Reviewed module output failed the render-only live attachment contract.", record)
	live_root.name = "W34313564LiveModules"
	var topology := _render_topology(live_root)
	if int(topology.mesh_instances) != EXPECTED_MESH_INSTANCES \
	or int(topology.surfaces) != EXPECTED_SURFACES \
	or int(topology.triangles) != EXPECTED_TRIANGLES:
		live_root.free()
		return _failure("w34313564_live_module_topology", "Reviewed live module render topology drifted.", record)
	var metadata := {
		"source_key": SOURCE_KEY,
		"receiver_key": RECEIVER_KEY,
		"runtime_attachment": true,
		"placement_role": PLACEMENT_ROLE,
		"position_uncertainty_m": POSITION_UNCERTAINTY_M,
		"module_instances": EXPECTED_MODULE_INSTANCES,
		"motif_instance_counts": {"W34313564-HWIN": 3, "W34313564-PDOOR": 2},
		"mesh_instances": int(topology.mesh_instances),
		"surfaces": int(topology.surfaces),
		"triangles": int(topology.triangles),
		"field_meshes": 0,
		"collision_nodes": 0,
		"navigation_nodes": 0,
		"spray_nodes": 0,
		"cadence_inferred": false,
		"total_opening_count_inferred": false,
		"reviewed_registry_path": REGISTRY_PATH,
		"reviewed_registry_sha256": EXPECTED_REGISTRY_SHA256,
		"reviewed_geometry_helper_path": REVIEWED_HELPER_PATH,
		"reviewed_geometry_helper_sha256": EXPECTED_REVIEWED_HELPER_SHA256,
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
		"resolved_placements": result.get("resolved_placements", []).duplicate(true),
	}


static func _registry_matches_exact_live_scope(registry: Dictionary) -> bool:
	var policy := registry.get("placement_policy", {}) as Dictionary
	if int(policy.get("placement_count", -1)) != EXPECTED_MODULE_INSTANCES \
	or str(policy.get("cadence_status", "")) != "no_period_or_global_sequence_inferred" \
	or float(policy.get("maximum_outward_depth_m", 1.0)) > 0.18 \
	or int(policy.get("collision_nodes", -1)) != 0 \
	or int(policy.get("navigation_nodes", -1)) != 0 \
	or int(policy.get("spray_nodes", -1)) != 0:
		return false
	var seen := {}
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		var placement_id := str(placement.get("placement_id", ""))
		if not EXPECTED_PLACEMENTS.has(placement_id) or seen.has(placement_id):
			return false
		seen[placement_id] = true
		var expected := EXPECTED_PLACEMENTS[placement_id] as Dictionary
		if str(placement.get("motif_id", "")) != str(expected.motif_id) \
		or str(placement.get("face", "")) != str(expected.face) \
		or str(placement.get("mapping_id", "")) != str(expected.mapping_id) \
		or int(placement.get("anchor_run", -1)) != int(expected.anchor_run) \
		or _int_array(placement.get("run_ownership", []) as Array) != [int(expected.anchor_run)] \
		or not is_equal_approx(float(placement.get("center_chain_m", -1.0)), float(expected.center_chain_m)) \
		or not is_equal_approx(float(placement.get("center_chain_uncertainty_m", -1.0)), POSITION_UNCERTAINTY_M) \
		or str(placement.get("host_material_id", "")) != str(expected.host_material_id):
			return false
	return seen.size() == EXPECTED_PLACEMENTS.size()


static func _promote_to_live_attachment(live_root: Node3D, registry: Dictionary) -> bool:
	if live_root.get_child_count() != EXPECTED_MODULE_INSTANCES \
	or _count_type(live_root, CollisionObject3D) != 0 \
	or _count_type(live_root, CollisionShape3D) != 0 \
	or _count_type(live_root, NavigationRegion3D) != 0:
		return false
	live_root.set_meta("controlled_calibration", false)
	live_root.set_meta("runtime_attachment", true)
	for child: Node in live_root.get_children():
		if not (child is Node3D):
			return false
		var module := child as Node3D
		var placement_id := str(module.get_meta("placement_id", ""))
		var expected := EXPECTED_PLACEMENTS.get(placement_id, {}) as Dictionary
		var placement := _placement_for(registry, placement_id)
		if expected.is_empty() or placement.is_empty():
			return false
		module.set_meta("runtime_attachment", true)
		module.set_meta("placement_role", PLACEMENT_ROLE)
		module.set_meta("center_chain_m", float(expected.center_chain_m))
		module.set_meta("center_chain_uncertainty_m", POSITION_UNCERTAINTY_M)
		module.set_meta("anchor_run", int(expected.anchor_run))
		module.set_meta("run_ownership", [int(expected.anchor_run)])
		module.set_meta("face", str(expected.face))
		module.set_meta("mapping_id", str(expected.mapping_id))
		module.set_meta("host_material_id", str(expected.host_material_id))
		module.set_meta("cadence_inferred", false)
		module.set_meta("total_opening_count_inferred", false)
		for mesh_value: Node in module.get_children():
			if not (mesh_value is MeshInstance3D):
				return false
			var mesh_instance := mesh_value as MeshInstance3D
			if not (mesh_instance.mesh is BoxMesh) \
			or mesh_instance.material_override == null \
			or bool(mesh_instance.get_meta("collision", false)):
				return false
			mesh_instance.layers = RENDER_BUILDING_WALL
			var size := (mesh_instance.mesh as BoxMesh).size
			var clearance := REVIEWED_CALIBRATION.WALL_OFFSET_M + mesh_instance.position.z - size.z * 0.5
			if clearance < 0.001:
				return false
	return true


static func _render_topology(root_node: Node) -> Dictionary:
	var result := {"mesh_instances": 0, "surfaces": 0, "triangles": 0}
	if root_node is MeshInstance3D:
		var mesh := (root_node as MeshInstance3D).mesh
		if mesh == null:
			return result
		result.mesh_instances = 1
		result.surfaces = mesh.get_surface_count()
		for surface_index in mesh.get_surface_count():
			var arrays := mesh.surface_get_arrays(surface_index)
			var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
			result.triangles += int(indices.size() / 3)
	for child: Node in root_node.get_children():
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
