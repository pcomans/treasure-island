class_name IsleHouse39BrutonLowLiveAttachment
extends "res://game/scripts/world/facades/isle_house_39_bruton_low_facade_prototype.gd"

## Fail-closed, render-only promotion seam for the reviewed Isle House low
## prototype. The generic wall remains the only collision and spray receiver.

const LIVE_TARGET_RECEIVER_OBJECT_KEY := "building-composite:w1249412094:w1282547787:wall"
const LIVE_TARGET_SOURCE_KEY := "w1282547787"
const SEALED_PROTOTYPE_SIGNATURE := "7f299bf99599c2f3f9feb982fb857663355645ffbf1eaa36e6714000b8c8d4cc"
const EXPECTED_LIVE_SIGNATURE := "5d61ab90e5b798ac4aa26c45fea37a5293f3083dada615f06999faad459112cc"
const LIVE_WORK_BAND_TOP_Y_M := 10.25
const EXPECTED_UPPER_BOUNDARY_CLIPS := 56
const EXPECTED_MESH_INSTANCES := 5
const EXPECTED_SURFACES := 5
const EXPECTED_TRIANGLES := 1844
const EXPECTED_MODULES := 8
const EXPECTED_FIELD_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
const EXPECTED_MODULE_RUNS := [2, 3, 8, 9]
const EXPECTED_PROTECTED_RUNS := [10, 11, 12]
const EXPECTED_BATCH_COUNTS := {"brick": 24, "frame": 88, "glass": 32, "patio": 8}
const SEALED_CONFIG_PATH := "res://game/resources/facades/isle_house_39_bruton_low_facade_prototype.json"
const SCENE_PATH := "res://game/scenes/world/facades/isle_house/isle_house_low_facade_prototype.tscn"
const FIELD_MATERIAL_PATH := "res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres"
const FIELD_TEXTURE_PATH := "res://game/resources/textures/world/facade_shared_v1/muted_brown_red_brick_albedo_v1.png"
const SCALAR_BRICK_MATERIAL_PATH := "res://game/resources/materials/world/isle_house/isle_house_low_brick.tres"
const PATIO_MATERIAL_PATH := "res://game/resources/materials/world/isle_house/isle_house_low_patio.tres"
const FRAME_MATERIAL_PATH := "res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres"
const GLASS_MATERIAL_PATH := "res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres"

const SEALED_PACKAGE_HASHES := {
	SEALED_CONFIG_PATH: "a0bfb094bfc4a7878a6dba0b5383dbd29cb8256f5a030a04ece222e912540ae0",
	"res://game/scripts/world/facades/isle_house_39_bruton_low_facade_prototype.gd": "68373632dd41989bee82244bdfcef02b89e74202e5a0e22a86d7919285c3e321",
	"res://game/scripts/world/facades/facade_meter_uv_adapter.gd": "47e710b9ea7c5de5122430199e4105cbba5f672d22f59832f13b8004f16c5a1d",
	SCENE_PATH: "6dc28dbe5c0a6019ef770be90f830a0e72f7b454c21a785fdec992b96b6ebec3",
	FIELD_MATERIAL_PATH: "488ad52ae9aa0155fd0356eaff128b3ab88ba0c23528c6ae332e7e54c772ffb6",
	FIELD_TEXTURE_PATH: "0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d",
	SCALAR_BRICK_MATERIAL_PATH: "fabab09ee257278336c1b7e9a2e6efab5f8e100df65340038ed03c7b0ea89635",
	PATIO_MATERIAL_PATH: "a4790cb821a8bf37e57de4b02e9257a23b0abf6970af5f3da8daf2a22c8eaea5",
	FRAME_MATERIAL_PATH: "6910208cb7130a86fbe8a063a6e8fa8e96cfa657d493e02449379b981ce961fe",
	GLASS_MATERIAL_PATH: "19adff893d82c8c76542140b0ed6f1b3e08fa5e5b75101c0bb55c08b69f2c7ce",
}

var _live_upper_boundary_clips := 0
var _live_visual_max_y_m := -INF
var _live_bounds_valid := true


static func matches_record(record: Dictionary) -> bool:
	return IsleHouse39BrutonLowFacadePrototype.matches_target(record)


static func build(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return _failure("isle_house_low_live_target", "Live Isle House low attachment refused a non-target receiver.", record)
	if not _sealed_package_matches():
		return _failure("isle_house_low_live_package_hash", "Live Isle House low attachment refused drifted or missing package bytes.", record)
	if not _runtime_package_is_clean():
		return _failure("isle_house_low_live_package_boundary", "Live Isle House low attachment found a source-only path or URL in its runtime closure.", record)
	if not _field_material_matches() or not _support_materials_match():
		return _failure("isle_house_low_live_material", "Live Isle House low attachment refused drifted brick texture settings.", record)

	var node := IsleHouse39BrutonLowLiveAttachment.new()
	var configured := node.configure(record)
	if not bool(configured.get("ok", false)):
		node.free()
		return _failure("isle_house_low_live_configure", str(configured.get("message", "Live Isle House low configuration failed.")), record)
	if node._live_upper_boundary_clips != EXPECTED_UPPER_BOUNDARY_CLIPS \
	or not node._live_bounds_valid \
	or node._live_visual_max_y_m > LIVE_WORK_BAND_TOP_Y_M + 0.0001:
		var boundary_message := "Live Isle House low output crossed the 10.25 m stop or lost an exact boundary clip: clips=%d max_y=%.6f bounds_valid=%s." % [node._live_upper_boundary_clips, node._live_visual_max_y_m, node._live_bounds_valid]
		node.free()
		return _failure("isle_house_low_live_upper_band", boundary_message, record)

	var topology := _topology_for(node)
	if topology != {
		"mesh_instances": EXPECTED_MESH_INSTANCES,
		"surfaces": EXPECTED_SURFACES,
		"triangles": EXPECTED_TRIANGLES,
	}:
		node.free()
		return _failure("isle_house_low_live_topology", "Live Isle House low render topology drifted: %s." % topology, record)
	if not _output_contract_matches(node):
		node.free()
		return _failure("isle_house_low_live_output", "Live Isle House low output violated a run, stop-zone, or zero-ownership contract.", record)

	var live_signature := JSON.stringify([
		str(node.get_meta("deterministic_signature", "")),
		"upper_band_max_y=%.3f" % LIVE_WORK_BAND_TOP_Y_M,
		"upper_boundary_clips=%d" % EXPECTED_UPPER_BOUNDARY_CLIPS,
	]).sha256_text()
	if live_signature != EXPECTED_LIVE_SIGNATURE:
		node.free()
		return _failure("isle_house_low_live_signature", "Live Isle House low attachment refused deterministic output drift.", record)
	node.name = "IsleHouse39BrutonLowLiveAttachment"
	node.remove_from_group("isle_house_low_prototype_render_only")
	node.add_to_group("isle_house_low_live_render_only")
	node.set_meta("source_prototype_only", true)
	node.set_meta("prototype_only", false)
	node.set_meta("runtime_attachment", true)
	node.set_meta("integration_mode", "reversible_live_attachment")
	node.set_meta("integration_authorization", "independent_material_uv_pass_with_limitation")
	node.set_meta("technical_evidence_status", "live_evidence_pending_independent_review")
	node.set_meta("receiver_geometry_fit", "exact_receiver_and_run_contract_enforced")
	node.set_meta("part_recognition_accepted", false)
	node.set_meta("whole_composite_recognition_accepted", false)
	node.set_meta("believability_accepted", false)
	node.set_meta("recognition_review_status", "pending_independent_live_review_not_self_accepted")
	node.set_meta("believability_review_status", "pending_independent_live_review_not_self_accepted")
	node.set_meta("collision", "none")
	node.set_meta("navigation", "none")
	node.set_meta("spray_ray_owner", "unchanged_underlying_receiver")
	node.set_meta("protected_upper_band_min_y_m", LIVE_WORK_BAND_TOP_Y_M)
	node.set_meta("upper_boundary_clip_count", EXPECTED_UPPER_BOUNDARY_CLIPS)
	node.set_meta("live_visual_max_y_m", node._live_visual_max_y_m)
	node.set_meta("live_deterministic_signature", live_signature)
	var metadata := {
		"receiver_object_key": LIVE_TARGET_RECEIVER_OBJECT_KEY,
		"source_key": LIVE_TARGET_SOURCE_KEY,
		"sealed_prototype_signature": SEALED_PROTOTYPE_SIGNATURE,
		"live_geometry_signature": str(node.get_meta("deterministic_signature", "")),
		"live_signature": live_signature,
		"mesh_instances": EXPECTED_MESH_INSTANCES,
		"surfaces": EXPECTED_SURFACES,
		"triangles": EXPECTED_TRIANGLES,
		"collision_nodes": 0,
		"navigation_nodes": 0,
		"spray_nodes": 0,
		"upper_boundary_clip_count": EXPECTED_UPPER_BOUNDARY_CLIPS,
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


static func _sealed_package_matches() -> bool:
	for path_value: Variant in SEALED_PACKAGE_HASHES:
		var path := str(path_value)
		if not _runtime_path_is_allowed(path):
			return false
		# Editor/source tests have the authoring bytes and must pin every one.
		# Compiled exports intentionally remap scripts, scenes, materials, and
		# textures, so FileAccess cannot truthfully hash their absent source files.
		# In that mode require the complete allowlisted ResourceLoader closure and
		# retain an exact raw config hash; semantic/material/output checks below
		# then fail closed on executable behavior drift.
		if OS.has_feature("editor"):
			if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(SEALED_PACKAGE_HASHES[path]):
				return false
		elif path == SEALED_CONFIG_PATH:
			if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(SEALED_PACKAGE_HASHES[path]):
				return false
		elif not ResourceLoader.exists(path):
			return false
	return true


static func _runtime_package_is_clean() -> bool:
	for path_value: Variant in SEALED_PACKAGE_HASHES:
		if not _runtime_path_is_allowed(str(path_value)):
			return false
	# Text/source bytes are deliberately absent from compiled exports. Their
	# closure is the explicit allowlist above; editor runs additionally scan all
	# readable authoring resources for accidental source/evidence references.
	if not OS.has_feature("editor"):
		return true
	var text_paths: Array[String] = [SEALED_CONFIG_PATH, SCENE_PATH]
	for path_value: Variant in SEALED_PACKAGE_HASHES:
		var path := str(path_value)
		if path.get_extension().to_lower() in ["gd", "tscn", "tres", "json"] and path not in text_paths:
			text_paths.append(path)
	for path: String in text_paths:
		var source := FileAccess.get_file_as_string(path).to_lower()
		for forbidden: String in ["res://discovery/", "res://evidence/", "http://", "https://", "file://", "/volumes/", "/users/"]:
			if forbidden in source:
				return false
	return true


static func _runtime_path_is_allowed(path: String) -> bool:
	if not path.begins_with("res://game/"):
		return false
	var normalized := path.to_lower()
	for forbidden: String in ["res://discovery/", "res://evidence/", "http://", "https://", "file://", "/volumes/", "/users/"]:
		if forbidden in normalized:
			return false
	return true


static func _field_material_matches() -> bool:
	var material := load(FIELD_MATERIAL_PATH) as StandardMaterial3D
	return material != null \
		and material.albedo_texture != null \
		and material.albedo_texture.resource_path == FIELD_TEXTURE_PATH \
		and material.albedo_texture.get_width() == 1254 \
		and material.albedo_texture.get_height() == 1254 \
		and material.albedo_color == Color(0.70, 0.66, 0.62, 1.0) \
		and is_zero_approx(material.metallic) \
		and is_equal_approx(material.roughness, 0.86) \
		and material.normal_texture == null \
		and material.roughness_texture == null \
		and material.uv1_scale == Vector3(0.4, 0.4, 1.0) \
		and material.texture_filter == BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC


static func _support_materials_match() -> bool:
	return _scalar_material_matches(SCALAR_BRICK_MATERIAL_PATH, Color(0.285, 0.205, 0.155, 1.0), 0.86) \
		and _scalar_material_matches(PATIO_MATERIAL_PATH, Color(0.42, 0.405, 0.37, 1.0), 0.90) \
		and _scalar_material_matches(FRAME_MATERIAL_PATH, Color(0.08, 0.10, 0.115, 1.0), 0.56) \
		and _scalar_material_matches(GLASS_MATERIAL_PATH, Color(0.08, 0.14, 0.18, 1.0), 0.24)


static func _scalar_material_matches(path: String, color: Color, roughness: float) -> bool:
	var material := load(path) as StandardMaterial3D
	return material != null \
		and material.albedo_color == color \
		and is_zero_approx(material.metallic) \
		and is_equal_approx(material.roughness, roughness) \
		and material.albedo_texture == null \
		and material.normal_texture == null \
		and material.roughness_texture == null


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


static func _output_contract_matches(node: Node3D) -> bool:
	if node.get_meta("observed_field_run_indices", []) != EXPECTED_FIELD_RUNS \
		or node.get_meta("module_run_indices", []) != EXPECTED_MODULE_RUNS \
		or node.get_meta("protected_run_indices", []) != EXPECTED_PROTECTED_RUNS \
		or int(node.get_meta("module_count", 0)) != EXPECTED_MODULES \
		or node.get_meta("module_box_counts", {}) != EXPECTED_BATCH_COUNTS:
		return false
	var protected := node.get_node_or_null("Side_LOW_NNW_PROTECTED")
	if protected == null or protected.get_child_count() != 0:
		return false
	if _count_type(node, CollisionObject3D) != 0 \
		or _count_type(node, CollisionShape3D) != 0 \
		or _count_type(node, NavigationRegion3D) != 0 \
		or _any_node_in_group(node, "spray_receiver_wall") \
		or _any_node_in_group(node, "spray_receiver"):
		return false
	return true


func _add_module_box(material_key: String, placement: Dictionary, module_transform: Transform3D, component_name: String, local_origin: Vector3, size: Vector3) -> void:
	var live_origin := local_origin
	var live_size := size
	var original_top_y := local_origin.y + size.y * 0.5
	if original_top_y > LIVE_WORK_BAND_TOP_Y_M + 0.0001:
		var allowed_components := [
			"BrickPierLeft", "BrickPierDivider", "BrickPierRight",
			"GalleryFrameLeft", "GalleryFrameRight", "GalleryFrameTop", "GalleryMullion",
		]
		var overflow := original_top_y - LIVE_WORK_BAND_TOP_Y_M
		if component_name not in allowed_components or overflow > 0.1001 or size.y - overflow <= 0.0:
			_live_bounds_valid = false
		else:
			# Clip only the top: keep the component's lower edge fixed.
			live_origin.y -= overflow * 0.5
			live_size.y -= overflow
			_live_upper_boundary_clips += 1
	var local_basis := Basis(Vector3.RIGHT * live_size.x, Vector3.UP * live_size.y, Vector3.BACK * live_size.z)
	var world_transform := module_transform * Transform3D(local_basis, live_origin)
	_live_visual_max_y_m = maxf(_live_visual_max_y_m, world_transform.origin.y + world_transform.basis.y.length() * 0.5)
	if world_transform.origin.y + world_transform.basis.y.length() * 0.5 > LIVE_WORK_BAND_TOP_Y_M + 0.0001:
		_live_bounds_valid = false
	super._add_module_box(material_key, placement, module_transform, component_name, live_origin, live_size)


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
