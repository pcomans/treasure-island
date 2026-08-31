class_name W291196370LiveModules
extends RefCounted

const RECEIVER_KEY := "building:w291196370:wall"
const SOURCE_KEY := "w291196370"
const REGISTRY_PATH := "res://game/resources/facades/w291196370_module_calibration.json"
const REVIEWED_HELPER_PATH := "res://game/tests/support/w291196370_module_calibration.gd"
const ART_REVIEW_PATH := "res://discovery/facades/W291196370_MODULE_CALIBRATION_ART_REVIEW.md"
const EXPECTED_REGISTRY_SHA256 := "b30a8f19091288cde4b8e891ec40287ab28a73776588f96ee86fc5565cfc25b8"
const EXPECTED_REVIEWED_HELPER_SHA256 := "ba621cffc5ee155e8b7c7338c3b5d444d1180dad6dbe11528219ada6de05dfdf"
const EXPECTED_ART_REVIEW_SHA256 := "967ab07d109096a743be01fb0bce959280967f5eab65c82ac0652eb5dcd3023b"
const PLACEMENT_ROLE := "stylized/reference-derived production inference"
const RENDER_BUILDING_WALL := 1 << 1
const EXPECTED_MODULE_INSTANCES := 3
const EXPECTED_MESH_INSTANCES := 24
const EXPECTED_SURFACES := 24
const EXPECTED_TRIANGLES := 288
const EXPECTED_PLACEMENTS := {
	"CAL-SSE-WINSTACK-01": {"motif_id": "W291196370-WINSTACK", "face": "SSE", "region": "observed_SSE_public_elevation", "mapping_id": "B06-291196370-SSE-PUBLIC", "anchor_run": 8, "ordered_runs": [8, 9, 10], "center_chain_m": 5.5, "center_chain_uncertainty_m": 2.0, "host_material_id": "W291196370-SIDING", "mesh_count": 7},
	"CAL-SSE-ENTRY-01": {"motif_id": "W291196370-ENTRY", "face": "SSE", "region": "observed_SSE_public_elevation", "mapping_id": "B06-291196370-SSE-PUBLIC", "anchor_run": 10, "ordered_runs": [8, 9, 10], "center_chain_m": 32.0, "center_chain_uncertainty_m": 3.0, "host_material_id": "W291196370-SIDING", "mesh_count": 5},
	"CAL-ENE-SERVICE-01": {"motif_id": "W291196370-SERVICE", "face": "ENE", "region": "observed_ENE_outer_end", "mapping_id": "B06-291196370-ENE-OUTER", "anchor_run": 20, "ordered_runs": [17, 18, 19, 20, 21, 22], "center_chain_m": 39.5, "center_chain_uncertainty_m": 4.0, "host_material_id": "W291196370-SIDING", "mesh_count": 12},
}

const REVIEWED_CALIBRATION := preload("res://game/tests/support/w291196370_module_calibration.gd")


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == RECEIVER_KEY \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))


static func build(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return _failure("w291196370_live_module_receiver", "Live three-motif target receiver identity drifted.", record)
	if FileAccess.get_sha256(REGISTRY_PATH) != EXPECTED_REGISTRY_SHA256 \
	or FileAccess.get_sha256(REVIEWED_HELPER_PATH) != EXPECTED_REVIEWED_HELPER_SHA256 \
	or FileAccess.get_sha256(ART_REVIEW_PATH) != EXPECTED_ART_REVIEW_SHA256:
		return _failure("w291196370_live_module_reviewed_input", "Reviewed registry, geometry helper, or independent detached art review bytes drifted.", record)
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not (registry_value is Dictionary):
		return _failure("w291196370_live_module_registry", "Reviewed three-motif registry did not parse.", record)
	var registry := registry_value as Dictionary
	if not _registry_matches_exact_live_scope(registry):
		return _failure("w291196370_live_module_scope", "Reviewed registry no longer matches the exact three authorized placements.", record)
	var result := REVIEWED_CALIBRATION.build(record, registry)
	if not bool(result.get("ok", false)):
		return result
	var live_root := result.get("node") as Node3D
	if live_root == null or not _promote_to_live_attachment(live_root, registry):
		if live_root != null:
			live_root.free()
		return _failure("w291196370_live_module_geometry", "Reviewed three-motif output failed the render-only live attachment contract.", record)
	live_root.name = "W291196370LiveModules"
	var topology := _render_topology(live_root)
	if int(topology.mesh_instances) != EXPECTED_MESH_INSTANCES \
	or int(topology.surfaces) != EXPECTED_SURFACES \
	or int(topology.triangles) != EXPECTED_TRIANGLES:
		live_root.free()
		return _failure("w291196370_live_module_topology", "Reviewed live three-motif render topology drifted.", record)
	var metadata := {
		"source_key": SOURCE_KEY,
		"receiver_key": RECEIVER_KEY,
		"runtime_attachment": true,
		"actual_world_art_review_status": "pending_independent_actual_world_review",
		"placement_role": PLACEMENT_ROLE,
		"position_uncertainty_by_placement_m": {
			"CAL-SSE-WINSTACK-01": 2.0,
			"CAL-SSE-ENTRY-01": 3.0,
			"CAL-ENE-SERVICE-01": 4.0,
		},
		"module_instances": EXPECTED_MODULE_INSTANCES,
		"motif_instance_counts": {
			"W291196370-WINSTACK": 1,
			"W291196370-ENTRY": 1,
			"W291196370-SERVICE": 1,
		},
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
		"coordinates_surveyed": false,
		"scale_surveyed": false,
		"count_surveyed": false,
		"cadence_inferred": false,
		"total_opening_count_inferred": false,
		"completed_sse_elevation": false,
		"completed_ene_elevation": false,
		"cross_side_transfer_accepted": false,
		"whole_building_accepted": false,
		"reviewed_registry_path": REGISTRY_PATH,
		"reviewed_registry_sha256": EXPECTED_REGISTRY_SHA256,
		"reviewed_geometry_helper_path": REVIEWED_HELPER_PATH,
		"reviewed_geometry_helper_sha256": EXPECTED_REVIEWED_HELPER_SHA256,
		"independent_detached_art_review_path": ART_REVIEW_PATH,
		"independent_detached_art_review_sha256": EXPECTED_ART_REVIEW_SHA256,
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
	var contracts := registry.get("module_contracts", []) as Array
	var policy := registry.get("placement_policy", {}) as Dictionary
	if contracts.size() != 3 \
	or int(policy.get("placement_count", -1)) != EXPECTED_MODULE_INSTANCES \
	or str(policy.get("position_status", "")) != "stylized_reference_derived_production_inference_not_surveyed" \
	or str(policy.get("count_status", "")) != "three_bounded_exemplars_one_per_accepted_motif_not_surveyed_total" \
	or str(policy.get("cadence_status", "")) != "unknown_not_surveyed_not_inferred" \
	or str(policy.get("coordinate_status", "")) != "stylized_reference_derived_inference_not_surveyed" \
	or float(policy.get("maximum_outward_depth_m", 1.0)) > 0.18 \
	or int(policy.get("collision_nodes", -1)) != 0 \
	or int(policy.get("navigation_nodes", -1)) != 0 \
	or int(policy.get("spray_nodes", -1)) != 0:
		return false
	var motif_ids: Array[String] = []
	for contract_value: Variant in contracts:
		var contract := contract_value as Dictionary
		motif_ids.append(str(contract.get("motif_id", "")))
		if str(contract.get("asset_classification", "")) != "module_atlas" \
		or not bool(contract.get("complete_motif", false)) \
		or not bool(contract.get("module_not_seamless_tile", false)) \
		or bool(contract.get("module_owns_field_geometry", true)):
			return false
	motif_ids.sort()
	if motif_ids != ["W291196370-ENTRY", "W291196370-SERVICE", "W291196370-WINSTACK"]:
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
		or str(placement.get("region", "")) != str(expected.region) \
		or str(placement.get("mapping_id", "")) != str(expected.mapping_id) \
		or int(placement.get("anchor_run", -1)) != int(expected.anchor_run) \
		or _int_array(placement.get("run_ownership", []) as Array) != [int(expected.anchor_run)] \
		or _int_array(placement.get("exact_ordered_runs", []) as Array) != _int_array(expected.ordered_runs as Array) \
		or not is_equal_approx(float(placement.get("center_chain_m", -1.0)), float(expected.center_chain_m)) \
		or not is_equal_approx(float(placement.get("center_chain_uncertainty_m", -1.0)), float(expected.center_chain_uncertainty_m)) \
		or str(placement.get("host_material_id", "")) != str(expected.host_material_id) \
		or str(placement.get("evidence_status", "")) != "production_inference" \
		or str(placement.get("coordinate_status", "")) != "stylized_reference_derived_inference_not_surveyed" \
		or str(placement.get("count_status", "")) != "bounded_exemplar_not_surveyed_total" \
		or str(placement.get("cadence_status", "")) != "unknown_not_surveyed_not_inferred" \
		or bool(placement.get("coordinate_surveyed", true)) \
		or bool(placement.get("count_surveyed", true)) \
		or bool(placement.get("cadence_surveyed", true)) \
		or bool(placement.get("module_scale_surveyed", true)):
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
		if expected.is_empty() or placement.is_empty() or module.get_child_count() != int(expected.mesh_count):
			return false
		module.set_meta("runtime_attachment", true)
		module.set_meta("placement_role", PLACEMENT_ROLE)
		module.set_meta("center_chain_m", float(expected.center_chain_m))
		module.set_meta("center_chain_uncertainty_m", float(expected.center_chain_uncertainty_m))
		module.set_meta("anchor_run", int(expected.anchor_run))
		module.set_meta("run_ownership", [int(expected.anchor_run)])
		module.set_meta("exact_ordered_runs", _int_array(expected.ordered_runs as Array))
		module.set_meta("face", str(expected.face))
		module.set_meta("region", str(expected.region))
		module.set_meta("mapping_id", str(expected.mapping_id))
		module.set_meta("host_material_id", str(expected.host_material_id))
		module.set_meta("evidence_status", "production_inference")
		module.set_meta("coordinate_status", "stylized_reference_derived_inference_not_surveyed")
		module.set_meta("count_status", "bounded_exemplar_not_surveyed_total")
		module.set_meta("cadence_status", "unknown_not_surveyed_not_inferred")
		module.set_meta("coordinates_surveyed", false)
		module.set_meta("scale_surveyed", false)
		module.set_meta("count_surveyed", false)
		module.set_meta("cadence_inferred", false)
		module.set_meta("total_opening_count_inferred", false)
		module.set_meta("complete_motif", true)
		module.set_meta("module_not_seamless_tile", true)
		module.set_meta("module_owns_field_geometry", false)
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
