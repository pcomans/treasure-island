extends SceneTree

const OUTPUT := "res://evidence/first-playable/building-1-public-front-believability-2026-09-04"
const MANIFEST_PATH := OUTPUT + "/capture-manifest.json"
const BEFORE_PATH := OUTPUT + "/before-capture.json"
const AFTER_PATH := OUTPUT + "/after-capture.json"
const EXPECTED_MANIFEST_SHA256 := "2b813cd8487e3591c456635a1e352a64d614ddf69f506dcd72623172d867754f"
const EXPECTED_BEFORE_SHA256 := "7e6d1a549a678f63b3dd2bff1693bfd53f6979b44fa8f2f84e3d72754292780f"
const EXPECTED_AFTER_SHA256 := "bef28d2c1e021742a3f099a9a5b0ef0a8e7e8c258c1cac21e36797275d548e8f"
const EXPECTED_IMAGES := {
	"before": {
		"01-public-front-whole-ordinary": "d1e6c5bedd6c5eae73cc4e8e0ee74358b64ebbd7ec9a938b22c739e1347f2624",
		"02-public-front-entrances-ordinary": "0ad84590e6dfc64be49f96e9a3735f306062c81e5215c5285da3ec97c6afef66",
		"03-public-front-whole-changed-light": "2dfa19e38f3acc697200e294ce9aed4d53583e9e0e2a0f2bf255198643bb30f6",
	},
	"after": {
		"01-public-front-whole-ordinary": "d2189c1b70d0368f53de624d45f4cf41436b4f8972ae4e34afcd1045efd93c91",
		"02-public-front-entrances-ordinary": "4ea83c8a367e9c2a0b63f2e395241cc6daa62381c3c3992b9769cbdb33a19e9d",
		"03-public-front-whole-changed-light": "6c62aa19851c76e4897af14df6f37b11a777856af5d9a340f8e7055eb871d623",
	},
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "Building 1 public-front combined evidence manifest bytes drifted.")
	_require(FileAccess.get_sha256(BEFORE_PATH) == EXPECTED_BEFORE_SHA256, "Building 1 public-front before manifest bytes drifted.")
	_require(FileAccess.get_sha256(AFTER_PATH) == EXPECTED_AFTER_SHA256, "Building 1 public-front after manifest bytes drifted.")
	var manifest := _json(MANIFEST_PATH)
	var before := _json(BEFORE_PATH)
	var after := _json(AFTER_PATH)
	_require(_combined_contract(manifest), "Combined Building 1 public-front evidence contract drifted.")
	_require(_stage_contract(before, "before"), "Building 1 public-front before technical evidence drifted.")
	_require(_stage_contract(after, "after"), "Building 1 public-front after technical evidence drifted.")
	_require(_exact_pairs(before, after), "Building 1 public-front before/after camera, aim, player, or light pairing drifted.")
	for stage in ["before", "after"]:
		var stage_manifest := before if stage == "before" else after
		for capture_value: Variant in stage_manifest.get("captures", []):
			var capture := capture_value as Dictionary
			var image_path := OUTPUT.path_join(str(capture.file))
			_require(FileAccess.file_exists(image_path), "%s %s PNG is absent." % [stage, str(capture.id)])
			_require(FileAccess.get_sha256(image_path) == str((EXPECTED_IMAGES[stage] as Dictionary).get(str(capture.id), "")), "%s %s PNG bytes drifted." % [stage, str(capture.id)])
	if not _failed:
		print("PASS: Building 1 public-front evidence preserves three exact fixed-camera native Metal before/after pairs, including changed light, pending independent bar-raiser re-review")
	quit(1 if _failed else 0)


func _combined_contract(manifest: Dictionary) -> bool:
	var pairs := manifest.get("pairs", []) as Array
	if str(manifest.get("schema_version", "")) != "ti.building-1-public-front-believability-evidence/1" \
	or str(manifest.get("review_status", "")) != "pending_independent_bar_raiser_re_review_not_self_accepted" \
	or str(manifest.get("recognition_status", "")) != "accepted_before_and_preserved" \
	or not bool(manifest.get("exact_fixed_camera_and_light_pairs", false)) \
	or bool(manifest.get("source_photography_shipped", true)) \
	or bool(manifest.get("generated_facade_image_used", true)) \
	or bool(manifest.get("genai_texture_candidate_consumed", true)) \
	or str(manifest.get("before_manifest_sha256", "")) != EXPECTED_BEFORE_SHA256 \
	or str(manifest.get("after_manifest_sha256", "")) != EXPECTED_AFTER_SHA256 \
	or pairs.size() != 3:
		return false
	for pair_value: Variant in pairs:
		var pair := pair_value as Dictionary
		if not bool(pair.get("camera_and_light_match", false)) \
		or str(pair.get("verdict", "")) != "pending_independent_bar_raiser_re_review" \
		or not str(pair.get("before", "")).begins_with("images/before/") \
		or not str(pair.get("after", "")).begins_with("images/after/"):
			return false
	return true


func _stage_contract(manifest: Dictionary, stage: String) -> bool:
	var captures := manifest.get("captures", []) as Array
	var bindings := manifest.get("bindings", {}) as Dictionary
	var topology := manifest.get("runtime_topology", {}) as Dictionary
	var expected_topology := {
		"records": 735,
		"meshes": 931 if stage == "before" else 933,
		"surfaces": 941 if stage == "before" else 943,
		"triangles": 60544 if stage == "before" else 61876,
		"static_bodies": 466,
		"shapes": 466,
	}
	if str(manifest.get("schema_version", "")) != "ti.building-1-public-front-believability-stage-evidence/1" \
	or str(manifest.get("stage", "")) != stage \
	or str(manifest.get("review_status", "")) != "pending_independent_bar_raiser_re_review_not_self_accepted" \
	or str(manifest.get("display_driver", "")) != "macOS" \
	or not str(manifest.get("video_adapter", "")).contains("Apple") \
	or str(manifest.get("rendering_method", "")) != "Forward+" \
	or str(manifest.get("rendering_driver", "")) != "Metal" \
	or not _values_close(manifest.get("viewport", []), [1440, 900], 0.001) \
	or int(manifest.get("capture_count", -1)) != 3 \
	or captures.size() != 3 \
	or not _values_close(topology, expected_topology, 0.001) \
	or int(bindings.get("wall_collision_face_vertices", -1)) != 2046 \
	or int(bindings.get("roof_collision_face_vertices", -1)) != 1737 \
	or bool(bindings.get("public_front_believability_pass", stage == "before")) != (stage == "after") \
	or bool(manifest.get("source_photography_shipped", true)) \
	or bool(manifest.get("generated_facade_image_used", true)) \
	or bool(manifest.get("genai_texture_candidate_consumed", true)) \
	or str(manifest.get("visual_verdict", "")) != "pending_independent_bar_raiser_re_review":
		return false
	if stage == "after" and not bool(manifest.get("before_after_camera_and_light_match", false)):
		return false
	for capture_value: Variant in captures:
		var capture := capture_value as Dictionary
		var hud := capture.get("hud", {}) as Dictionary
		if str(capture.get("stage", "")) != stage \
		or str(capture.get("sha256", "")) != str((EXPECTED_IMAGES[stage] as Dictionary).get(str(capture.get("id", "")), "")) \
		or not _values_close(capture.get("dimensions", []), [1440, 900], 0.001) \
		or not bool(capture.get("physics_grounded", false)) \
		or not bool(capture.get("ordinary_player_rig", false)) \
		or not bool(capture.get("input_reachable_camera_orientation", false)) \
		or not bool(capture.get("in_boundary", false)) \
		or not bool(capture.get("receiver_first_los", false)) \
		or str(capture.get("first_los_hit_receiver", "")) != "building:r16681702:wall" \
		or capture.get("first_los_hit_source_keys", []) != ["r16681702"] \
		or absf(float(capture.get("camera_fov_degrees", 0.0)) - 70.0) > 0.001 \
		or absf(float(capture.get("configured_spring_length_m", 0.0)) - 5.5) > 0.001 \
		or float(capture.get("actual_spring_length_m", 0.0)) < 4.5 \
		or float(capture.get("camera_height_above_ground_m", 0.0)) < 1.0 \
		or bool(capture.get("debug_labels_visible", true)) \
		or bool(capture.get("source_photography_in_frame", true)) \
		or bool(hud.get("debug_panel_visible", true)) \
		or bool(hud.get("feedback_panel_visible", true)) \
		or bool(hud.get("load_panel_visible", true)) \
		or bool(hud.get("pause_panel_visible", true)) \
		or not bool(hud.get("reticle_visible", false)) \
		or int(capture.get("sample_unique_colors", 0)) < 8 \
		or float(capture.get("sample_luminance_range", 0.0)) < 0.1 \
		or str(capture.get("visual_verdict", "")) != "pending_independent_bar_raiser_re_review":
			return false
	return true


func _exact_pairs(before: Dictionary, after: Dictionary) -> bool:
	if not _values_close(before.get("fixed_view_definitions", []), after.get("fixed_view_definitions", []), 0.000001):
		return false
	var first := before.get("captures", []) as Array
	var second := after.get("captures", []) as Array
	if first.size() != second.size():
		return false
	for index in first.size():
		var before_capture := first[index] as Dictionary
		var after_capture := second[index] as Dictionary
		for key in ["id", "requested_xz", "player_position_m", "aim_target_m", "camera_position_m", "camera_forward", "camera_fov_degrees", "configured_spring_length_m", "sun_rotation_degrees"]:
			if not _values_close(before_capture.get(key), after_capture.get(key), 0.001):
				return false
	return true


func _values_close(first: Variant, second: Variant, tolerance: float) -> bool:
	if first is Array and second is Array:
		if first.size() != second.size():
			return false
		for index in first.size():
			if not _values_close(first[index], second[index], tolerance):
				return false
		return true
	if first is Dictionary and second is Dictionary:
		if first.size() != second.size():
			return false
		for key: Variant in first:
			if not second.has(key) or not _values_close(first[key], second[key], tolerance):
				return false
		return true
	if first is float or first is int:
		return absf(float(first) - float(second)) <= tolerance
	return first == second


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false
