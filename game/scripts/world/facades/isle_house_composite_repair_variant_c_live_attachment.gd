class_name IsleHouseCompositeRepairVariantCLiveAttachment
extends RefCounted

## Fail-closed live promotion of the independently approved Variant C repair.
## This adapter has one path: construct the reviewed C overlay for the exact low
## wall receiver. The rejected predecessor is neither called nor a fallback.

const LIVE_TARGET_RECEIVER_OBJECT_KEY := "building-composite:w1249412094:w1282547787:wall"
const LIVE_TARGET_SOURCE_KEY := "w1282547787"
const REPAIR_FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_repair_only_factory.gd"
const REVIEWED_VARIANT_C_FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"

const REPAIR_FACTORY := preload(REPAIR_FACTORY_PATH)


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == LIVE_TARGET_RECEIVER_OBJECT_KEY \
		and record.get("source_keys", []) == [LIVE_TARGET_SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_part_wall" \
		and str(record.get("material_key", "")) == "building_part_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and is_equal_approx(float(record.get("top_elevation_m", 0.0)), 19.103) \
		and (record.get("vertices", []) as Array).size() == 156 \
		and (record.get("normals", []) as Array).size() == 156 \
		and (record.get("indices", []) as Array).size() == 78


static func build(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return _failure("isle_house_variant_c_live_target", "Variant C live replacement refused a non-target low receiver.", record)
	if not _sealed_package_matches():
		return _failure("isle_house_variant_c_live_package", "Variant C live replacement refused a missing repair-only factory.", record)
	if not _runtime_package_is_clean():
		return _failure("isle_house_variant_c_live_package_boundary", "Variant C live replacement found a source/evidence path or URL in its executable seam.", record)

	var factory := REPAIR_FACTORY.new() as IsleHouseCompositeRepairVariantCRepairOnlyFactory
	if factory == null:
		return _failure("isle_house_variant_c_live_factory", "Variant C repair-only factory did not instantiate.", record)
	var repair_result: Dictionary = factory.build_repair_only(record)
	if not bool(repair_result.get("ok", false)):
		factory.free()
		return _failure(
			"isle_house_variant_c_live_build",
			"Variant C repair-only factory failed: %s (%s)" % [str(repair_result.get("message", "unknown")), str(repair_result.get("code", "unknown"))],
			record
		)
	var node := repair_result.get("node", null) as Node3D
	if node == null:
		factory.free()
		return _failure("isle_house_variant_c_live_node", "Variant C repair-only factory returned no overlay node.", record)
	if not _approved_output_matches(node):
		factory.free()
		node.free()
		return _failure("isle_house_variant_c_live_output", "Variant C approved overlay violated its truth boundary or ownership contract.", record)
	factory.free()
	var topology := _topology_for(node)

	node.name = "IsleHouseCompositeRepairVariantCLiveAttachment"
	node.remove_from_group("isle_house_composite_variant_c_standalone_only")
	node.add_to_group("isle_house_variant_c_live_render_only")
	node.set_meta("standalone_only", false)
	node.set_meta("live_replacement", true)
	node.set_meta("integration_mode", "approved_variant_c_live_replacement")
	node.set_meta("integration_authorization", "independent_variant_c_bar_raiser_pass")
	node.set_meta("standalone_independent_grade", "PASS")
	node.set_meta("as_built_fidelity", false)
	node.set_meta("rejected_overlay_fallback_used", false)
	node.set_meta("overlay_stacked", false)
	node.set_meta("collision", "none")
	node.set_meta("navigation", "none")
	node.set_meta("spray", "none")
	node.set_meta("spray_ray_owner", "unchanged_underlying_receiver")
	var metadata := {
		"receiver_object_key": LIVE_TARGET_RECEIVER_OBJECT_KEY,
		"source_key": LIVE_TARGET_SOURCE_KEY,
		"rejected_overlay_fallback_used": false,
		"overlay_stacked": false,
		"mesh_instances": int(topology.mesh_instances),
		"surfaces": int(topology.surfaces),
		"triangles": int(topology.triangles),
		"collision_nodes": 0,
		"navigation_nodes": 0,
		"spray_nodes": 0,
	}
	return {
		"ok": true,
		"node": node,
		"mesh_instances": int(topology.mesh_instances),
		"surfaces": int(topology.surfaces),
		"triangles": int(topology.triangles),
		"metadata": metadata,
	}


static func _sealed_package_matches() -> bool:
	for path: String in [REPAIR_FACTORY_PATH, REVIEWED_VARIANT_C_FACTORY_PATH]:
		if not _runtime_path_is_allowed(path):
			return false
		if not FileAccess.file_exists(path) and not ResourceLoader.exists(path):
			return false
	return true


static func _runtime_package_is_clean() -> bool:
	if not FileAccess.file_exists("res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd"):
		return true
	var paths: Array[String] = [
		"res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd",
		REPAIR_FACTORY_PATH,
		REVIEWED_VARIANT_C_FACTORY_PATH,
		"res://game/resources/facades/isle_house_composite_repair_variant_c_standalone_v1.json",
	]
	for path: String in paths:
		if not _runtime_path_is_allowed(path) or not FileAccess.file_exists(path):
			return false
		var source := FileAccess.get_file_as_string(path).to_lower()
		for forbidden: String in _forbidden_tokens():
			if forbidden in source:
				return false
	return true


static func _runtime_path_is_allowed(path: String) -> bool:
	if not path.begins_with("res://game/"):
		return false
	var normalized := path.to_lower()
	for forbidden: String in _forbidden_tokens():
		if forbidden in normalized:
			return false
	return true


static func _forbidden_tokens() -> Array[String]:
	# Assemble tokens so this executable guard cannot match its own source.
	return [
		"res://" + "discovery/", "res://" + "evidence/",
		"http" + "://", "https" + "://", "file" + "://",
		"/" + "volumes/", "/" + "users/",
	]


static func _approved_output_matches(node: Node3D) -> bool:
	if node.get_meta("quiet_nnw_run_indices", []) != [10, 11, 12] \
		or int(node.get_meta("quiet_nnw_opening_count", -1)) != 0 \
		or node.get_meta("upper_band_ids", []) != ["TRANSFER-PLINTH", "PODIUM-BODY", "PODIUM-CROWN", "TOP-SHADOW-CAP"]:
		return false
	if node.get_node_or_null("IsleHouse39BrutonLowLiveAttachment") != null \
		or node.get_node_or_null("FailedLiveParentLowOverlay") != null \
		or _count_type(node, CollisionObject3D) != 0 \
		or _count_type(node, CollisionShape3D) != 0 \
		or _count_type(node, NavigationRegion3D) != 0 \
		or _any_node_in_group(node, "spray_receiver") \
		or _any_node_in_group(node, "spray_receiver_wall"):
		return false
	return true


static func _topology_for(node: Node) -> Dictionary:
	var mesh_instances := 0
	var surfaces := 0
	var triangles := 0
	for descendant: Node in _descendants_including(node):
		if descendant is MeshInstance3D:
			var mesh := (descendant as MeshInstance3D).mesh
			if mesh == null:
				continue
			mesh_instances += 1
			surfaces += mesh.get_surface_count()
			triangles += mesh.get_faces().size() / 3
		elif descendant is MultiMeshInstance3D:
			var multimesh := (descendant as MultiMeshInstance3D).multimesh
			if multimesh == null or multimesh.mesh == null:
				continue
			mesh_instances += 1
			surfaces += multimesh.mesh.get_surface_count()
			triangles += int(multimesh.mesh.get_faces().size() / 3) * multimesh.instance_count
	return {"mesh_instances": mesh_instances, "surfaces": surfaces, "triangles": triangles}


static func _descendants_including(node: Node) -> Array[Node]:
	var result: Array[Node] = [node]
	for child: Node in node.get_children():
		result.append_array(_descendants_including(child))
	return result


static func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


static func _any_node_in_group(node: Node, group_name: StringName) -> bool:
	if node.is_in_group(group_name):
		return true
	for child: Node in node.get_children():
		if _any_node_in_group(child, group_name):
			return true
	return false


static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	return {
		"ok": false,
		"code": code,
		"message": message,
		"source_keys": (record.get("source_keys", []) as Array).duplicate(),
	}
