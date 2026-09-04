extends SceneTree

const ROOT := "res://evidence/first-playable/p1-existing-live-revalidation-2026-09-04"
const MANIFEST_PATH := ROOT + "/capture-manifest.json"
const GENERATOR_PATH := "res://game/tests/p1_existing_live_revalidation_capture.gd"
const EXPECTED_MANIFEST_SHA256 := "e1ab8f526aed22a6234fff1d2fcc5eae5d2245df4260a25a5705cd37a158a921"
const EXPECTED_GENERATOR_SHA256 := "4b3beb2f6b827359c069498af54c385786428bddaaa4b381bd945b0c1dbee5ec"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_GENERATED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_CAPTURES := [
	{
		"id": "01-building-3-whole-object",
		"target": "building-3",
		"role": "whole_object_ordinary_player_view",
		"file": "images/building-3/01-building-3-whole-object.png",
		"sha256": "e20ebd6a483234b1b55de5421113a79dbe6d3c18380ab33858ab0f4de7ded1ef",
		"receiver": "building:w34313540:wall",
		"source_keys": ["w34313540"],
		"confusion_set": ["w24274434", "r16681702"],
	},
	{
		"id": "02-building-3-oblique-approach",
		"target": "building-3",
		"role": "oblique_approach_ordinary_player_view",
		"file": "images/building-3/02-building-3-oblique-approach.png",
		"sha256": "2a3aa0dd7e4f08f37cad515d75c45240eb412043f4f69acbea208fef4848a103",
		"receiver": "building:w34313540:wall",
		"source_keys": ["w34313540"],
		"confusion_set": ["w24274434", "r16681702"],
	},
	{
		"id": "03-hawkins-whole-object",
		"target": "hawkins",
		"role": "whole_object_ordinary_player_view",
		"file": "images/hawkins/03-hawkins-whole-object.png",
		"sha256": "c903a5cea795b5bc2731f7e31701001add2ee6685d9f1708c7883c00f13ff850",
		"receiver": "building:w1249412093:wall",
		"source_keys": ["w1249412093"],
		"confusion_set": ["r19685981", "w1212173437", "w1272162518"],
	},
	{
		"id": "04-hawkins-oblique-approach",
		"target": "hawkins",
		"role": "oblique_approach_ordinary_player_view",
		"file": "images/hawkins/04-hawkins-oblique-approach.png",
		"sha256": "f6a4665a29519ea9181c02b8635e75efb32f583b295d311291e2bc23c3bd696b",
		"receiver": "building:w1249412093:wall",
		"source_keys": ["w1249412093"],
		"confusion_set": ["r19685981", "w1212173437", "w1272162518"],
	},
	{
		"id": "05-isle-house-whole-composite-diagnostic",
		"target": "isle-house",
		"role": "whole_object_ordinary_player_view",
		"file": "images/isle-house/05-isle-house-whole-composite-diagnostic.png",
		"sha256": "c6556aef5dcd1996be4373f6d9387f3b74da81613a444223a0b3bceb18b830cf",
		"receiver": "building-composite:w1249412094:w1282547786:wall",
		"source_keys": ["w1282547786"],
		"confusion_set": ["w1249412093", "w1272162518"],
	},
	{
		"id": "06-isle-house-low-oblique-diagnostic",
		"target": "isle-house",
		"role": "oblique_approach_ordinary_player_view",
		"file": "images/isle-house/06-isle-house-low-oblique-diagnostic.png",
		"sha256": "6ea99d1321f2279e86fa6098fe87e3b47f611800421a0d75b5f6d03aaa6513db",
		"receiver": "building-composite:w1249412094:w1282547787:wall",
		"source_keys": ["w1282547787"],
		"confusion_set": ["w1249412093", "w1272162518"],
	},
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "P1 evidence manifest bytes drifted.")
	_require(FileAccess.get_sha256(GENERATOR_PATH) == EXPECTED_GENERATOR_SHA256, "P1 capture harness bytes drifted after evidence generation.")
	var manifest := _json(MANIFEST_PATH)
	_require(_header_matches(manifest), "P1 evidence renderer, review-state, or camera provenance drifted.")
	_require(_world_matches(manifest.get("generated_world", {}) as Dictionary), "P1 evidence generated-world pins drifted.")
	_require(_targets_match(manifest.get("targets", {}) as Dictionary), "P1 target binding, packet, confusion-set, or candidate status drifted.")
	_require(_captures_match(manifest.get("captures", []) as Array), "P1 image, grounding, HUD, framing, or exact receiver-first LOS evidence drifted.")
	if not _failed:
		print("PASS: six sealed native Metal P1 views retain captured-topology provenance, two physics-grounded stock-player perspectives per target, frozen confusion sets, clean exact-first-hit LOS, and pending-only verdicts; Building 3 is explicitly historical before evidence superseded by its hero-massing packet")
	quit(1 if _failed else 0)


func _header_matches(manifest: Dictionary) -> bool:
	var verdicts := manifest.get("recognition_verdicts", {}) as Dictionary
	var camera := manifest.get("camera_contract", {}) as Dictionary
	var viewport := manifest.get("viewport", []) as Array
	return str(manifest.get("schema_version", "")) == "ti.p1-existing-live-revalidation-evidence/1" \
		and str(manifest.get("review_status", "")) == "pending_independent_whole_building_recognition_review_not_self_accepted" \
		and verdicts == {
			"building-3": "pending_independent_review",
			"hawkins": "pending_independent_review",
			"isle-house": "pending_independent_diagnostic_review",
		} \
		and str(manifest.get("display_driver", "")) == "macOS" \
		and str(manifest.get("rendering_method", "")) == "Forward+" \
		and str(manifest.get("rendering_driver", "")) == "Metal" \
		and viewport.size() == 2 and int(viewport[0]) == 1440 and int(viewport[1]) == 900 \
		and str(manifest.get("generator", "")) == "game/tests/p1_existing_live_revalidation_capture.gd" \
		and str(manifest.get("generator_sha256", "")) == EXPECTED_GENERATOR_SHA256 \
		and bool(manifest.get("frozen_confusion_sets_selected_before_review", false)) \
		and not bool(manifest.get("source_photography_shipped", true)) \
		and bool(manifest.get("recognition_review_prohibited_for_executor", false)) \
		and int(manifest.get("capture_count", -1)) == EXPECTED_CAPTURES.size() \
		and str(camera.get("rig", "")) == "actual Player/CameraPivot/SpringArm3D/Camera3D" \
		and is_equal_approx(float(camera.get("fov_degrees", -1.0)), 70.0) \
		and is_equal_approx(float(camera.get("configured_spring_length_m", -1.0)), 5.5) \
		and is_equal_approx(float(camera.get("minimum_actual_spring_length_m", -1.0)), 4.5) \
		and is_equal_approx(float(camera.get("minimum_camera_height_above_ground_m", -1.0)), 1.0) \
		and not bool(camera.get("detached_camera", true)) \
		and not bool(camera.get("camera_tricks", true)) \
		and not bool(camera.get("context_hidden", true)) \
		and not bool(camera.get("lighting_changed", true)) \
		and not bool(camera.get("crop_or_postprocess", true)) \
		and not bool(camera.get("debug_labels_visible", true))


func _world_matches(world: Dictionary) -> bool:
	return str(world.get("content_sha256", "")) == EXPECTED_CONTENT_SHA256 \
		and str(world.get("manifest_sha256", "")) == EXPECTED_GENERATED_MANIFEST_SHA256 \
		and int(world.get("playable_rows", -1)) == 735 \
		and int(world.get("context_rows", -1)) == 4 \
		and int(world.get("meshes", -1)) == 931 \
		and int(world.get("surfaces", -1)) == 941 \
		and int(world.get("triangles", -1)) == 59778 \
		and int(world.get("static_bodies", -1)) == 466 \
		and int(world.get("shapes", -1)) == 466 \
		and FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_GENERATED_MANIFEST_SHA256


func _targets_match(targets: Dictionary) -> bool:
	if targets.size() != 3:
		return false
	var building_3 := targets.get("building-3", {}) as Dictionary
	var hawkins := targets.get("hawkins", {}) as Dictionary
	var isle := targets.get("isle-house", {}) as Dictionary
	return _target_files_match(building_3) and _target_files_match(hawkins) and _target_files_match(isle) \
		and str(building_3.get("source_identity", "")) == "w34313540" \
		and str(building_3.get("receiver", "")) == "building:w34313540:wall" \
		and building_3.get("confusion_set_source_ids", []) == ["w24274434", "r16681702"] \
		and str(building_3.get("candidate_status", "")) == "candidate_for_no_change_whole_building_revalidation_pending_independent_review" \
		and str(hawkins.get("source_identity", "")) == "w1249412093" \
		and str(hawkins.get("receiver", "")) == "building:w1249412093:wall" \
		and hawkins.get("confusion_set_source_ids", []) == ["r19685981", "w1212173437", "w1272162518"] \
		and str(hawkins.get("candidate_status", "")) == "candidate_for_no_change_whole_building_revalidation_pending_independent_review" \
		and str(isle.get("source_identity", "")) == "w1249412094" \
		and str(isle.get("receiver", "")) == "building-composite:w1249412094:w1282547786:wall" \
		and str(isle.get("low_receiver", "")) == "building-composite:w1249412094:w1282547787:wall" \
		and isle.get("confusion_set_source_ids", []) == ["w1249412093", "w1272162518"] \
		and str(isle.get("candidate_status", "")) == "diagnostic_only_expected_low_part_limitation_pending_independent_review" \
		and bool(isle.get("parent_meshless", false)) and bool(isle.get("low_receiver_untreated", false)) \
		and int(building_3.get("runtime_receiver_count", -1)) == 1 \
		and int(hawkins.get("runtime_receiver_count", -1)) == 1 \
		and int(isle.get("runtime_receiver_count", -1)) == 1


func _target_files_match(target: Dictionary) -> bool:
	var packet := str(target.get("reference_packet", ""))
	var layout := str(target.get("layout_path", ""))
	var script := str(target.get("runtime_script_path", ""))
	# Building 3 was intentionally superseded by the separately sealed hero-
	# massing packet. Preserve this manifest's declared old layout/script hashes
	# as historical before-image provenance; do not pretend they are current.
	if str(target.get("source_identity", "")) == "w34313540":
		return not packet.is_empty() \
			and FileAccess.get_sha256(packet) == str(target.get("reference_packet_sha256", "")) \
			and str(target.get("layout_sha256", "")) == "312ed89a5bca6e3eadf3034b8e97689b9a99646837aca8f5f1f7f940a11f8299" \
			and str(target.get("runtime_script_sha256", "")) == "5808131a175fd6b43957ddb54921d247b2c6d00a71185574616a1ed5c765231d" \
			and FileAccess.get_sha256(layout) != str(target.get("layout_sha256", "")) \
			and FileAccess.get_sha256(script) != str(target.get("runtime_script_sha256", "")) \
			and FileAccess.file_exists("res://evidence/first-playable/building-3-hero-massing-2026-09-04/capture-manifest.json")
	if packet.is_empty() or layout.is_empty() or script.is_empty() \
		or FileAccess.get_sha256(packet) != str(target.get("reference_packet_sha256", "")) \
		or FileAccess.get_sha256(layout) != str(target.get("layout_sha256", "")) \
		or FileAccess.get_sha256(script) != str(target.get("runtime_script_sha256", "")):
		return false
	if target.has("massing_script_path"):
		return FileAccess.get_sha256(str(target.massing_script_path)) == str(target.get("massing_script_sha256", ""))
	return true


func _captures_match(captures: Array) -> bool:
	if captures.size() != EXPECTED_CAPTURES.size():
		return false
	var target_role_counts := {
		"building-3": {"whole_object_ordinary_player_view": 0, "oblique_approach_ordinary_player_view": 0},
		"hawkins": {"whole_object_ordinary_player_view": 0, "oblique_approach_ordinary_player_view": 0},
		"isle-house": {"whole_object_ordinary_player_view": 0, "oblique_approach_ordinary_player_view": 0},
	}
	for index in captures.size():
		var capture := captures[index] as Dictionary
		var expected := EXPECTED_CAPTURES[index] as Dictionary
		if str(capture.get("id", "")) != str(expected.id) \
		or str(capture.get("target", "")) != str(expected.target) \
		or str(capture.get("role", "")) != str(expected.role) \
		or str(capture.get("file", "")) != str(expected.file) \
		or str(capture.get("sha256", "")) != str(expected.sha256) \
		or str(capture.get("first_los_hit_receiver", "")) != str(expected.receiver) \
		or capture.get("first_los_hit_source_keys", []) != expected.source_keys \
		or capture.get("confusion_set_source_ids_frozen_before_review", []) != expected.confusion_set:
			return false
		var path := ROOT.path_join(str(capture.file))
		var image := Image.load_from_file(path)
		if FileAccess.get_sha256(path) != str(expected.sha256) or image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900):
			return false
		var hud := capture.get("hud", {}) as Dictionary
		var dimensions := capture.get("dimensions", []) as Array
		if not bool(capture.get("physics_grounded", false)) \
		or not bool(capture.get("ordinary_player_rig", false)) \
		or not bool(capture.get("input_reachable_camera_orientation", false)) \
		or not bool(capture.get("in_boundary", false)) \
		or not bool(capture.get("receiver_first_los", false)) \
		or bool(capture.get("debug_labels_visible", true)) \
		or bool(capture.get("source_photography_in_frame", true)) \
		or str(capture.get("recognition_verdict", "")) != "pending_independent_review" \
		or absf(float(capture.get("ground_clearance_m", INF))) > 0.08 \
		or float(capture.get("settle_horizontal_drift_m", INF)) > 0.05 \
		or int(capture.get("settle_recovery_delta", -1)) != 0 \
		or float(capture.get("ground_normal_up_dot", 0.0)) < 0.7 \
		or str(capture.get("ground_feature", "")) not in ["land_ground", "road_path"] \
		or not is_equal_approx(float(capture.get("camera_fov_degrees", -1.0)), 70.0) \
		or not is_equal_approx(float(capture.get("configured_spring_length_m", -1.0)), 5.5) \
		or float(capture.get("actual_spring_length_m", 0.0)) < 4.5 \
		or float(capture.get("camera_height_above_ground_m", 0.0)) < 1.0 \
		or float(capture.get("aim_target_center_error_px", INF)) > 1.0 \
		or int(capture.get("target_bounds_corners_behind_camera", -1)) != 0 \
		or float(capture.get("target_projected_width_ratio", 0.0)) < 0.08 \
		or float(capture.get("target_projected_height_ratio", 0.0)) < 0.08 \
		or int(capture.get("sample_unique_colors", 0)) < 8 \
		or float(capture.get("sample_luminance_range", 0.0)) < 0.1 \
		or dimensions.size() != 2 or int(dimensions[0]) != 1440 or int(dimensions[1]) != 900 \
		or bool(hud.get("debug_panel_visible", true)) \
		or bool(hud.get("feedback_panel_visible", true)) \
		or bool(hud.get("load_panel_visible", true)) \
		or bool(hud.get("pause_panel_visible", true)) \
		or not bool(hud.get("reticle_visible", false)):
			return false
		if str(capture.role).begins_with("whole_object") and not bool(capture.get("target_bounds_fully_in_frame", false)):
			return false
		var counts := target_role_counts[str(capture.target)] as Dictionary
		counts[str(capture.role)] = int(counts[str(capture.role)]) + 1
	for target_value: Variant in target_role_counts.values():
		var roles := target_value as Dictionary
		if int(roles.whole_object_ordinary_player_view) != 1 or int(roles.oblique_approach_ordinary_player_view) != 1:
			return false
	return true


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false
