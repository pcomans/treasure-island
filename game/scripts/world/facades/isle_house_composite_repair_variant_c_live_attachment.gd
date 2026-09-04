class_name IsleHouseCompositeRepairVariantCLiveAttachment
extends RefCounted

## Fail-closed live promotion of the independently approved Variant C repair.
## This adapter has one path: construct the reviewed C overlay for the exact low
## wall receiver. The rejected predecessor is neither called nor a fallback.

const LIVE_TARGET_RECEIVER_OBJECT_KEY := "building-composite:w1249412094:w1282547787:wall"
const LIVE_TARGET_SOURCE_KEY := "w1282547787"
const REPAIR_FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_repair_only_factory.gd"
const REPAIR_FACTORY_SHA256 := "4336e821e240b973f8d97e5cb46e17332b19dea03869abb1fa81b96a7e380582"
const REVIEWED_VARIANT_C_FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"
const REVIEWED_VARIANT_C_FACTORY_SHA256 := "b24fd72cd12aa0c6c45a123f005fc834ea657c343e8332a872eae07fa017ace7"
const APPROVED_REVIEW_SHA256 := "b9877edb51eb9cc09bfd08f33d2664d7d3de08736daa2b96dc6e36c60d0fb5e5"
const EXPECTED_APPROVAL_TOKEN_SHA256 := "a70b1857eed4bdf30be26bc0fab628cf65f7fbdf02d98f84612f854aaf9b7fd1"
const EXPECTED_REPAIR_SIGNATURE := "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69"
const REJECTED_LIVE_SIGNATURE := "5d61ab90e5b798ac4aa26c45fea37a5293f3083dada615f06999faad459112cc"
const EXPECTED_LIVE_SIGNATURE := "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981"
const EXPECTED_MESH_INSTANCES := 7
const EXPECTED_SURFACES := 11
const EXPECTED_TRIANGLES := 2242
const EXPECTED_TOPOLOGY := {
	"mesh_instances": EXPECTED_MESH_INSTANCES,
	"surfaces": EXPECTED_SURFACES,
	"triangles": EXPECTED_TRIANGLES,
}

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
	if not _approval_contract_matches():
		return _failure("isle_house_variant_c_live_approval", "Variant C live replacement refused a missing or drifted independent approval token.", record)
	if not _sealed_package_matches():
		return _failure("isle_house_variant_c_live_package", "Variant C live replacement refused missing or drifted repair-only factory bytes.", record)
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
	if str(repair_result.get("repair_signature", "")) != EXPECTED_REPAIR_SIGNATURE \
		or repair_result.get("topology", {}) != EXPECTED_TOPOLOGY \
		or not _approved_output_matches(node):
		factory.free()
		node.free()
		return _failure("isle_house_variant_c_live_output", "Variant C approved overlay signature, topology, truth boundary, or ownership drifted.", record)
	factory.free()

	var live_signature := JSON.stringify([
		APPROVED_REVIEW_SHA256,
		EXPECTED_REPAIR_SIGNATURE,
		LIVE_TARGET_RECEIVER_OBJECT_KEY,
		EXPECTED_MESH_INSTANCES,
		EXPECTED_SURFACES,
		EXPECTED_TRIANGLES,
		"approved_variant_c_replaces_rejected_overlay_without_fallback",
	]).sha256_text()
	if live_signature != EXPECTED_LIVE_SIGNATURE:
		node.free()
		return _failure("isle_house_variant_c_live_signature", "Variant C live replacement signature drifted.", record)

	node.name = "IsleHouseCompositeRepairVariantCLiveAttachment"
	node.remove_from_group("isle_house_composite_variant_c_standalone_only")
	node.add_to_group("isle_house_variant_c_live_render_only")
	node.set_meta("standalone_only", false)
	node.set_meta("runtime_attachment", true)
	node.set_meta("live_replacement", true)
	node.set_meta("integration_mode", "approved_variant_c_live_replacement")
	node.set_meta("integration_authorization", "independent_variant_c_bar_raiser_pass")
	node.set_meta("approval_review_sha256", APPROVED_REVIEW_SHA256)
	node.set_meta("standalone_independent_grade", "PASS")
	node.set_meta("technical_evidence_status", "actual_live_evidence_pending_independent_review")
	node.set_meta("recognition_accepted", false)
	node.set_meta("part_recognition_accepted", false)
	node.set_meta("whole_composite_recognition_accepted", false)
	node.set_meta("believability_accepted", false)
	node.set_meta("as_built_fidelity", false)
	node.set_meta("recognition_review_status", "pending_independent_exact_current_live_review")
	node.set_meta("believability_review_status", "pending_independent_exact_current_live_review")
	node.set_meta("replaces_rejected_live_signature", REJECTED_LIVE_SIGNATURE)
	node.set_meta("rejected_overlay_fallback_used", false)
	node.set_meta("overlay_stacked", false)
	node.set_meta("collision", "none")
	node.set_meta("navigation", "none")
	node.set_meta("spray", "none")
	node.set_meta("spray_ray_owner", "unchanged_underlying_receiver")
	node.set_meta("live_deterministic_signature", live_signature)
	var metadata := {
		"receiver_object_key": LIVE_TARGET_RECEIVER_OBJECT_KEY,
		"source_key": LIVE_TARGET_SOURCE_KEY,
		"approval_review_sha256": APPROVED_REVIEW_SHA256,
		"repair_signature": EXPECTED_REPAIR_SIGNATURE,
		"live_signature": live_signature,
		"replaces_rejected_live_signature": REJECTED_LIVE_SIGNATURE,
		"rejected_overlay_fallback_used": false,
		"overlay_stacked": false,
		"mesh_instances": EXPECTED_MESH_INSTANCES,
		"surfaces": EXPECTED_SURFACES,
		"triangles": EXPECTED_TRIANGLES,
		"collision_nodes": 0,
		"navigation_nodes": 0,
		"spray_nodes": 0,
		"part_recognition_accepted": false,
		"whole_composite_recognition_accepted": false,
		"believability_accepted": false,
	}
	return {
		"ok": true,
		"node": node,
		"mesh_instances": EXPECTED_MESH_INSTANCES,
		"surfaces": EXPECTED_SURFACES,
		"triangles": EXPECTED_TRIANGLES,
		"metadata": metadata,
	}


static func _approval_contract_matches() -> bool:
	var token := "PASS|%s|%s|%d|%d|%d" % [
		APPROVED_REVIEW_SHA256,
		EXPECTED_REPAIR_SIGNATURE,
		EXPECTED_MESH_INSTANCES,
		EXPECTED_SURFACES,
		EXPECTED_TRIANGLES,
	]
	return token.sha256_text() == EXPECTED_APPROVAL_TOKEN_SHA256


static func _sealed_package_matches() -> bool:
	for path: String in [REPAIR_FACTORY_PATH, REVIEWED_VARIANT_C_FACTORY_PATH]:
		if not _runtime_path_is_allowed(path):
			return false
		if FileAccess.file_exists(path):
			var expected := REPAIR_FACTORY_SHA256 if path == REPAIR_FACTORY_PATH else REVIEWED_VARIANT_C_FACTORY_SHA256
			if FileAccess.get_sha256(path) != expected:
				return false
		elif not ResourceLoader.exists(path):
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
	if str(node.get_meta("repair_signature", "")) != EXPECTED_REPAIR_SIGNATURE \
		or node.get_meta("topology", {}) != EXPECTED_TOPOLOGY \
		or not bool(node.get_meta("standalone_only", false)) \
		or bool(node.get_meta("runtime_attachment", true)) \
		or bool(node.get_meta("live_replacement", true)) \
		or bool(node.get_meta("upper_schedule_claimed", true)) \
		or bool(node.get_meta("literal_seven_story_geometry_claimed", true)) \
		or bool(node.get_meta("protected_return_opening_schedule_claimed", true)) \
		or node.get_meta("quiet_nnw_run_indices", []) != [10, 11, 12] \
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
	return _topology_for(node) == EXPECTED_TOPOLOGY


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
