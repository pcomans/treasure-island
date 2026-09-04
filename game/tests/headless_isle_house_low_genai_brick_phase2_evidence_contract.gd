extends SceneTree

const EVIDENCE_ROOT := "res://evidence/first-playable/isle-house-low-genai-brick-phase2-2026-09-04"
const MANIFEST_PATH := EVIDENCE_ROOT + "/capture-manifest.json"
const GENERATED_MATERIAL := "res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres"
const GENERATED_TEXTURE := "res://game/resources/textures/world/facade_shared_v1/muted_brown_red_brick_albedo_v1.png"
const UV_HELPER := "res://game/scripts/world/facades/facade_meter_uv_adapter.gd"
const ACCEPTED_LIVE_ATTACHMENT := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd"
const ACCEPTED_VARIANT_C_FACTORY := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"
const REJECTED_LIVE_ATTACHMENT := "res://game/scripts/world/facades/isle_house_39_bruton_low_live_attachment.gd"
const EXPECTED_PROMOTED_MATERIAL_SHA256 := "488ad52ae9aa0155fd0356eaff128b3ab88ba0c23528c6ae332e7e54c772ffb6"
const EXPECTED_PROMOTED_TEXTURE_SHA256 := "0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d"
const BASELINE_PCK := "res://build/phase2-package-audit-before.pck"
const FINAL_PCK := "res://build/phase2-package-audit-after.pck"
const CAPTURE_SIZE := [1440, 900]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manifest_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if not _require(manifest_value is Dictionary, "Could not parse Phase 2 brick evidence manifest."):
		_finish()
		return
	var manifest := manifest_value as Dictionary
	if not _require(_manifest_contract_matches(manifest), "Phase 2 evidence truth, UV, material, motion, or topology contract drifted.") \
	or not _require(_captures_match(manifest), "Phase 2 fixed A/B or motion capture files/hashes/poses drifted.") \
	or not _require(_package_audit_matches(manifest), "Phase 2 package-cost evidence drifted from the actual before/after PCKs.") \
	or not _require(_accepted_promotion_boundary_matches(), "Phase 2 evidence or its later accepted package-safe shared-brick promotion boundary drifted."):
		_finish()
		return
	print("PASS: Phase 2 evidence remains an isolated hash-pinned historical trial; its exact promoted shared-brick bytes may appear live only through accepted Variant C, while pilot/source-only paths and rejected attachments remain absent from current construction")
	_finish()


func _manifest_contract_matches(manifest: Dictionary) -> bool:
	var field := manifest.get("field_material", {}) as Dictionary
	var uv := manifest.get("uv_contract", {}) as Dictionary
	var motion := manifest.get("motion_protocol", {}) as Dictionary
	var topology := manifest.get("prototype_topology_unchanged", {}) as Dictionary
	var checks := {
		"schema": str(manifest.get("schema_version", "")) == "ti.isle-house-low-genai-brick-phase2-evidence/1",
		"review": str(manifest.get("review_status", "")) == "technical_capture_complete_visual_verdict_pending_bar_raiser_review",
		"isolation": not bool(manifest.get("runtime_attachment", true)),
		"runs": _int_array(manifest.get("mapped_run_scope", []) as Array) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
		"material_path": str(manifest.get("generated_material", "")) == GENERATED_MATERIAL,
		"texture_path": str(manifest.get("generated_texture", "")) == GENERATED_TEXTURE,
		"texture_hash": str(manifest.get("generated_texture_sha256", "")) == FileAccess.get_sha256(GENERATED_TEXTURE),
		"helper_path": str(manifest.get("uv_helper", "")) == UV_HELPER,
		"helper_hash": str(manifest.get("uv_helper_sha256", "")) == FileAccess.get_sha256(UV_HELPER),
		"cell": is_equal_approx(float(field.get("cell_m", 0.0)), 2.5),
		"tint": _numeric_array_approx(field.get("tint", []) as Array, [0.70, 0.66, 0.62, 1.0]),
		"roughness": is_equal_approx(float(field.get("scalar_roughness", 0.0)), 0.86),
		"maps": (field.get("maps", []) as Array).size() == 1 and str((field.get("maps", []) as Array)[0]) == "albedo",
		"module_boundary": "scalar brick retained" in str(field.get("module_piers", "")),
		"uv_version": str(uv.get("contract_version", "")) == "ti.facade-meter-uv/1",
		"uv_u": str(uv.get("u_phase_rule", "")) == "continuous_xz_metres_within_ordered_side_chain",
		"uv_corner": str(uv.get("corner_rule", "")) == "continue_at_ordered_intra_side_corner_reset_at_side_start",
		"uv_v": str(uv.get("v_phase_rule", "")) == "absolute_world_y_metres",
		"motion_count": int(motion.get("frame_count", 0)) == 9,
		"motion_step": is_equal_approx(float(motion.get("step_m", 0.0)), 1.25),
		"motion_distance": is_equal_approx(float(motion.get("outward_distance_m", 0.0)), 16.0),
		"motion_purpose": (motion.get("purpose", []) as Array).size() == 5,
		"motion_nonclaim": "not a physics/player traversal" in str(motion.get("not_claimed", "")),
		"topology": int(topology.get("field_segments", 0)) == 10 \
			and int(topology.get("field_triangles", 0)) == 20 \
			and int(topology.get("module_boxes", 0)) == 152 \
			and int(topology.get("module_triangles", 0)) == 1824 \
			and int(topology.get("total_visual_triangles", 0)) == 1844,
		"zero_ownership": int(topology.get("collision_nodes", -1)) == 0 \
			and int(topology.get("navigation_nodes", -1)) == 0 \
			and int(topology.get("spray_nodes", -1)) == 0,
		"viewport": _int_array(manifest.get("viewport", []) as Array) == CAPTURE_SIZE,
		"native_renderer": str(manifest.get("display_driver", "")) != "headless" and str(manifest.get("video_adapter", "")).length() > 0,
		"review_instruction": "self-acceptance" in str(manifest.get("reviewer_instruction", "")),
	}
	for key_value: Variant in checks:
		if not bool(checks[key_value]):
			push_error("Phase 2 manifest sub-contract failed: %s" % str(key_value))
			return false
	return true


func _captures_match(manifest: Dictionary) -> bool:
	var fixed := manifest.get("fixed_captures", []) as Array
	var motion := manifest.get("motion_captures", []) as Array
	if fixed.size() != 4 or motion.size() != 9:
		return false
	var expected_kinds := [
		"flat_control_fixed_front",
		"generated_fixed_front",
		"flat_control_fixed_oblique",
		"generated_fixed_oblique",
	]
	for index in fixed.size():
		var capture := fixed[index] as Dictionary
		if str(capture.get("view_kind", "")) != expected_kinds[index] or not _capture_file_matches(capture):
			return false
	var flat_front := fixed[0] as Dictionary
	var generated_front := fixed[1] as Dictionary
	var flat_oblique := fixed[2] as Dictionary
	var generated_oblique := fixed[3] as Dictionary
	if flat_front.get("camera_position_m", []) != generated_front.get("camera_position_m", []) \
	or flat_front.get("target_position_m", []) != generated_front.get("target_position_m", []) \
	or flat_oblique.get("camera_position_m", []) != generated_oblique.get("camera_position_m", []) \
	or flat_oblique.get("target_position_m", []) != generated_oblique.get("target_position_m", []) \
	or str(flat_front.get("field_material", "")) == GENERATED_MATERIAL \
	or str(flat_oblique.get("field_material", "")) == GENERATED_MATERIAL \
	or str(generated_front.get("field_material", "")) != GENERATED_MATERIAL \
	or str(generated_oblique.get("field_material", "")) != GENERATED_MATERIAL:
		return false
	for index in motion.size():
		var capture := motion[index] as Dictionary
		if str(capture.get("view_kind", "")) != "generated_parallel_walk_sample" \
		or str(capture.get("field_material", "")) != GENERATED_MATERIAL \
		or absf(float(capture.get("side_u_m", 0.0)) - (20.0 + float(index) * 1.25)) > 0.0001 \
		or not is_equal_approx(float(capture.get("outward_distance_m", 0.0)), 16.0) \
		or not _capture_file_matches(capture):
			return false
	return true


func _capture_file_matches(capture: Dictionary) -> bool:
	var path := EVIDENCE_ROOT.path_join(str(capture.get("file", "")))
	return FileAccess.file_exists(path) \
		and FileAccess.get_sha256(path) == str(capture.get("sha256", "")) \
		and FileAccess.get_file_as_bytes(path).size() == int(capture.get("bytes", -1)) \
		and _int_array(capture.get("dimensions", []) as Array) == CAPTURE_SIZE \
		and int(capture.get("sample_unique_colors", 0)) >= 16 \
		and float(capture.get("sample_luminance_range", 0.0)) >= 0.12


func _package_audit_matches(manifest: Dictionary) -> bool:
	var package := manifest.get("package_audit", {}) as Dictionary
	var before_bytes := _file_size(BASELINE_PCK)
	var after_bytes := _file_size(FINAL_PCK)
	return before_bytes > 0 \
		and after_bytes > 0 \
		and after_bytes < before_bytes \
		and int(package.get("before_bytes", -1)) == before_bytes \
		and int(package.get("after_bytes", -1)) == after_bytes \
		and int(package.get("delta_bytes", 0)) == after_bytes - before_bytes \
		and str(package.get("before_sha256", "")) == FileAccess.get_sha256(BASELINE_PCK) \
		and str(package.get("after_sha256", "")) == FileAccess.get_sha256(FINAL_PCK) \
		and "genai_pilot_v1" in str(package.get("export_filter", ""))


func _accepted_promotion_boundary_matches() -> bool:
	var builder := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	var registry := FileAccess.get_file_as_string("res://game/resources/facades/facade-runtime-registry.json")
	var accepted_adapter := FileAccess.get_file_as_string(ACCEPTED_LIVE_ATTACHMENT)
	var accepted_factory := FileAccess.get_file_as_string(ACCEPTED_VARIANT_C_FACTORY)
	var promoted_material := FileAccess.get_file_as_string(GENERATED_MATERIAL)
	var closure := [builder, registry, accepted_adapter, accepted_factory, promoted_material]
	for source: String in closure:
		for forbidden: String in [
			"res://game/resources/materials/world/genai_pilot_v1/",
			"res://game/resources/textures/world/genai_pilot_v1/",
			"res://discovery/",
			"res://evidence/",
			"http://",
			"https://",
			"file://",
			"/users/",
			"/volumes/",
		]:
			if forbidden in source.to_lower():
				return false
	if FileAccess.get_sha256(GENERATED_MATERIAL) != EXPECTED_PROMOTED_MATERIAL_SHA256 \
	or FileAccess.get_sha256(GENERATED_TEXTURE) != EXPECTED_PROMOTED_TEXTURE_SHA256 \
	or builder.count(ACCEPTED_LIVE_ATTACHMENT) != 1 \
	or REJECTED_LIVE_ATTACHMENT in builder \
	or GENERATED_MATERIAL in builder \
	or GENERATED_TEXTURE in builder \
	or GENERATED_MATERIAL not in accepted_factory \
	or GENERATED_TEXTURE not in accepted_factory \
	or registry.count(GENERATED_MATERIAL) != 1 \
	or registry.count(GENERATED_TEXTURE) != 1 \
	or "active-adapter:isle-house-variant-c:building-composite:w1249412094:w1282547787:wall" not in registry \
	or "\"runtime_content_mode\": \"active_isle_house_variant_c\"" not in registry:
		return false
	for forbidden_variant: String in [
		"isle_house_39_bruton_low_live_attachment.gd",
		"isle_house_low_facade_prototype.tscn",
		"IsleHouse39BrutonLowLiveAttachment",
	]:
		if forbidden_variant in builder or forbidden_variant in registry:
			return false
	return true


func _file_size(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return -1
	var size := file.get_length()
	file.close()
	return size


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _numeric_array_approx(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for index in actual.size():
		if not is_equal_approx(float(actual[index]), float(expected[index])):
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
