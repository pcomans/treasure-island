extends SceneTree

const EVIDENCE_ROOT := "res://evidence/first-playable/isle-house-low-live-integration-2026-09-04"
const STILL_MANIFEST := EVIDENCE_ROOT + "/capture-manifest.json"
const MOTION_MANIFEST := EVIDENCE_ROOT + "/motion-capture.json"
const MOVIE_PATH := EVIDENCE_ROOT + "/isle-house-low-public-corner-stock-walk.avi"
const GENERATOR_PATH := "res://game/tests/isle_house_low_live_evidence_capture.gd"
const CAPTURE_LIVE_ADAPTER_PATH := "res://game/scripts/world/facades/isle_house_39_bruton_low_live_attachment.gd"
const CURRENT_LIVE_ADAPTER_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const HIGH_WALL_KEY := "building-composite:w1249412094:w1282547786:wall"

const EXPECTED_STILL_MANIFEST_SHA256 := "9b72ca941c1d96699d67060f3e75312074364ab5b027591827514bee335aebe7"
const EXPECTED_MOTION_MANIFEST_SHA256 := "ee99617b2a9e17cb73825900b0af8295656ba4e2c63e6c6c54598b5af6fd584f"
const EXPECTED_GENERATOR_SHA256 := "47768e4b2d6288b9c3dbb4b0ad19cd870b61a8804d72673c53bf3326f8f5636a"
const EXPECTED_CAPTURE_LIVE_ADAPTER_SHA256 := "1b36a0ad92ded4607e0c1e0df5d5581d1c7afff5843cb75cd4c490790a86c413"
const EXPECTED_CAPTURE_BUILDER_SHA256 := "9525ead815e95d7bc0b5fa8beae389954e232a9bbf51b54ed049a84a3613b9c0"
const EXPECTED_CURRENT_LIVE_ADAPTER_SHA256 := "e2767b01fab68d7f16ffe2e7f8e0313c711347e2006a72e028c19aaa2195b891"
const EXPECTED_CURRENT_BUILDER_SHA256 := "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c"
const EXPECTED_MOVIE_SHA256 := "d45ce3e3e28497c46f3828508175b301f13be9368e8879d4920a2641fb3d934d"
const EXPECTED_MOVIE_BYTES := 22049152
const EXPECTED_LIVE_SIGNATURE := "5d61ab90e5b798ac4aa26c45fea37a5293f3083dada615f06999faad459112cc"
const EXPECTED_HIGH_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const CAPTURE_SIZE := [1440, 900]

const EXPECTED_CAPTURES := [
	{
		"id": "01-wsw-whole-composite", "side": "WSW_Avenue_of_the_Palms",
		"role": "grounded_ordinary_player_whole_high_plus_low_composite", "lighting": "world_default",
		"receiver": HIGH_WALL_KEY, "sources": ["w1282547786"],
		"sha256": "1fb93ad0adaeeb27304ff2933c529b33efee4c3774feb8a551fb9c6d7cbdbf21", "bytes": 303456,
	},
	{
		"id": "02-wsw-low-oblique", "side": "WSW_Avenue_of_the_Palms",
		"role": "grounded_ordinary_player_low_live_work_oblique", "lighting": "world_default",
		"receiver": LOW_WALL_KEY, "sources": ["w1282547787"],
		"sha256": "7c4228b97b132c33d1db994dc3fed0ea8ef70eef6316ac3e0ca8f901c699cf63", "bytes": 1141794,
	},
	{
		"id": "03-ene-whole-composite", "side": "ENE_public_entry_approach",
		"role": "grounded_ordinary_player_whole_high_plus_low_composite", "lighting": "world_default",
		"receiver": HIGH_WALL_KEY, "sources": ["w1282547786"],
		"sha256": "0c519b65e40f3a0cbdfe7154adf54dec06fe4aec7d6a565ef83443db25b6752a", "bytes": 461134,
	},
	{
		"id": "04-ene-low-oblique", "side": "ENE_Garden_Walk",
		"role": "grounded_ordinary_player_low_live_work_oblique", "lighting": "world_default",
		"receiver": LOW_WALL_KEY, "sources": ["w1282547787"],
		"sha256": "aa554e5bc42e3adbc1bc1f81b90695f8182b3d50f89a7169dd66283529b03aca", "bytes": 1109991,
	},
	{
		"id": "05-wsw-low-changed-light", "side": "WSW_Avenue_of_the_Palms",
		"role": "grounded_ordinary_player_low_material_changed_light", "lighting": "frozen_changed_light",
		"receiver": LOW_WALL_KEY, "sources": ["w1282547787"],
		"sha256": "0441b4c79b7838ef17e7c8fdd1000fabaa33a715db4a938137656ecdb78d02d0", "bytes": 1093987,
	},
	{
		"id": "06-ene-low-changed-light", "side": "ENE_Garden_Walk",
		"role": "grounded_ordinary_player_low_material_changed_light", "lighting": "frozen_changed_light",
		"receiver": LOW_WALL_KEY, "sources": ["w1282547787"],
		"sha256": "136b7037aa0212f807414316bf19523d6252e3ba2968f790fd300e56659bee7e", "bytes": 1134139,
	},
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(STILL_MANIFEST) == EXPECTED_STILL_MANIFEST_SHA256, "Live still manifest drifted.") \
	or not _require(FileAccess.get_sha256(MOTION_MANIFEST) == EXPECTED_MOTION_MANIFEST_SHA256, "Live motion manifest drifted.") \
	or not _require(FileAccess.get_sha256(GENERATOR_PATH) == EXPECTED_GENERATOR_SHA256, "Live native evidence generator drifted.") \
	or not _require(FileAccess.get_sha256(CAPTURE_LIVE_ADAPTER_PATH) == EXPECTED_CAPTURE_LIVE_ADAPTER_SHA256, "Capture-time rejected low adapter drifted.") \
	or not _require(_current_live_boundary_matches(), "Current world builder is not the exact accepted Variant C-only replacement seam."):
		_finish()
		return
	var stills := _json(STILL_MANIFEST)
	var motion := _json(MOTION_MANIFEST)
	if not _require(_still_manifest_matches(stills), "Native still evidence contract failed.") \
	or not _require(_motion_manifest_matches(motion), "Native continuous-motion evidence contract failed."):
		_finish()
		return
	print("PASS: six native stills and one 222-frame MovieWriter clip preserve the exact rejected predecessor at its capture-time builder hash; the current builder separately resolves only the independently accepted Variant C replacement with no old-adapter stack or fallback")
	_finish()


func _still_manifest_matches(manifest: Dictionary) -> bool:
	var topology := manifest.get("runtime_topology", {}) as Dictionary
	var camera := manifest.get("camera_contract", {}) as Dictionary
	var bindings := manifest.get("bindings", {}) as Dictionary
	var captures := manifest.get("captures", []) as Array
	if str(manifest.get("schema_version", "")) != "ti.isle-house-low-live-evidence/1" \
	or str(manifest.get("review_status", "")) != "pending_independent_review_not_self_accepted" \
	or str(manifest.get("recognition_status", "")) != "pending_independent_review" \
	or str(manifest.get("believability_status", "")) != "pending_independent_review" \
	or str(manifest.get("visual_verdict", "")) != "pending_independent_review" \
	or str(manifest.get("generator_sha256", "")) != EXPECTED_GENERATOR_SHA256 \
	or str(manifest.get("live_adapter_path", "")) != CAPTURE_LIVE_ADAPTER_PATH \
	or str(manifest.get("live_adapter_sha256", "")) != EXPECTED_CAPTURE_LIVE_ADAPTER_SHA256 \
	or str(manifest.get("builder_path", "")) != BUILDER_PATH \
	or str(manifest.get("builder_sha256", "")) != EXPECTED_CAPTURE_BUILDER_SHA256 \
	or _int_array(manifest.get("viewport", []) as Array) != CAPTURE_SIZE \
	or int(manifest.get("capture_count", 0)) != EXPECTED_CAPTURES.size() \
	or captures.size() != EXPECTED_CAPTURES.size() \
	or bool(manifest.get("source_photography_shipped", true)) \
	or bool(manifest.get("generated_reference_image_used", true)) \
	or bool(camera.get("detached_camera", true)) or bool(camera.get("crop_or_postprocess", true)) \
	or not bool(camera.get("physics_grounded", false)) \
	or int(topology.get("rows", 0)) != 735 or int(topology.get("meshes", 0)) != 938 \
	or int(topology.get("surfaces", 0)) != 948 or int(topology.get("triangles", 0)) != 63720 \
	or int(topology.get("bodies", 0)) != 466 or int(topology.get("shapes", 0)) != 466 \
	or not _bindings_match(bindings) \
	or (manifest.get("remaining_composite_discrepancies", []) as Array).size() != 3:
		return false
	for index in EXPECTED_CAPTURES.size():
		if not _capture_matches(captures[index] as Dictionary, EXPECTED_CAPTURES[index] as Dictionary):
			return false
	return true


func _current_live_boundary_matches() -> bool:
	var builder := FileAccess.get_file_as_string(BUILDER_PATH)
	var current_adapter := FileAccess.get_file_as_string(CURRENT_LIVE_ADAPTER_PATH)
	var registry := FileAccess.get_file_as_string("res://game/resources/facades/facade-runtime-registry.json")
	return FileAccess.get_sha256(BUILDER_PATH) == EXPECTED_CURRENT_BUILDER_SHA256 \
		and FileAccess.get_sha256(CURRENT_LIVE_ADAPTER_PATH) == EXPECTED_CURRENT_LIVE_ADAPTER_SHA256 \
		and builder.count(CURRENT_LIVE_ADAPTER_PATH) == 1 \
		and builder.count("ISLE_HOUSE_LOW_LIVE_ATTACHMENT.matches_record(record)") == 1 \
		and builder.count("ISLE_HOUSE_LOW_LIVE_ATTACHMENT.build(record)") == 1 \
		and CAPTURE_LIVE_ADAPTER_PATH not in builder \
		and "IsleHouse39BrutonLowLiveAttachment" not in builder \
		and "The rejected predecessor is neither called nor a fallback." in current_adapter \
		and CAPTURE_LIVE_ADAPTER_PATH not in current_adapter \
		and CAPTURE_LIVE_ADAPTER_PATH not in registry \
		and "active-adapter:isle-house-variant-c:building-composite:w1249412094:w1282547787:wall" in registry \
		and "\"runtime_content_mode\": \"active_isle_house_variant_c\"" in registry


func _capture_matches(capture: Dictionary, expected: Dictionary) -> bool:
	var path := EVIDENCE_ROOT.path_join("images/%s.png" % str(expected.id))
	return str(capture.get("id", "")) == str(expected.id) \
		and str(capture.get("side", "")) == str(expected.side) \
		and str(capture.get("role", "")) == str(expected.role) \
		and str(capture.get("lighting", "")) == str(expected.lighting) \
		and str(capture.get("file", "")) == "images/%s.png" % str(expected.id) \
		and str(capture.get("sha256", "")) == str(expected.sha256) \
		and FileAccess.get_sha256(path) == str(expected.sha256) \
		and int(capture.get("bytes", -1)) == int(expected.bytes) \
		and _file_size(path) == int(expected.bytes) \
		and _int_array(capture.get("dimensions", []) as Array) == CAPTURE_SIZE \
		and bool(capture.get("physics_grounded", false)) \
		and bool(capture.get("ordinary_player_rig", false)) \
		and bool(capture.get("input_reachable_camera_orientation", false)) \
		and bool(capture.get("receiver_first_los", false)) \
		and str(capture.get("first_los_hit_receiver", "")) == str(expected.receiver) \
		and capture.get("first_los_hit_source_keys", []) == expected.sources \
		and not bool(capture.get("debug_labels_visible", true)) \
		and not bool(capture.get("source_photography_in_frame", true)) \
		and not bool(capture.get("crop_or_postprocess", true)) \
		and str(capture.get("visual_verdict", "")) == "pending_independent_review" \
		and int(capture.get("sample_unique_colors", 0)) >= 8 \
		and float(capture.get("sample_luminance_range", 0.0)) >= 0.1


func _motion_manifest_matches(manifest: Dictionary) -> bool:
	var process_range := _int_array(manifest.get("review_motion_process_frame_range", []) as Array)
	var physics_range := _int_array(manifest.get("review_motion_physics_frame_range", []) as Array)
	var render_viewport := _int_array(manifest.get("render_viewport", []) as Array)
	var samples := manifest.get("samples", []) as Array
	if str(manifest.get("schema_version", "")) != "ti.isle-house-low-live-motion-evidence/1" \
	or str(manifest.get("review_status", "")) != "pending_independent_review_not_self_accepted" \
	or str(manifest.get("recognition_status", "")) != "pending_independent_review" \
	or str(manifest.get("believability_status", "")) != "pending_independent_review" \
	or str(manifest.get("visual_verdict", "")) != "pending_independent_review" \
	or str(manifest.get("generator_sha256", "")) != EXPECTED_GENERATOR_SHA256 \
	or _int_array(manifest.get("movie_dimensions", []) as Array) != [1280, 800] \
	or render_viewport.size() != 2 or render_viewport[0] < 960 or render_viewport[1] < 600 \
	or process_range.size() != 2 or process_range[1] - process_range[0] != 150 \
	or physics_range.size() != 2 or physics_range[1] - physics_range[0] != 300 \
	or int(manifest.get("capture_end_process_frame_after_braking", 0)) - process_range[1] != 6 \
	or int(manifest.get("capture_end_physics_frame_after_braking", 0)) - physics_range[1] != 12 \
	or int(manifest.get("movie_total_frames_expected_after_close", 0)) != 222 \
	or int(manifest.get("fixed_fps", 0)) != 30 or int(manifest.get("physics_ticks_per_second", 0)) != 60 \
	or int(manifest.get("motion_physics_frames", 0)) != 300 or not is_equal_approx(float(manifest.get("continuous_duration_seconds", 0.0)), 5.0) \
	or str(manifest.get("input_action", "")) != "move_right" or bool(manifest.get("run_action_pressed", true)) \
	or not is_equal_approx(float(manifest.get("configured_walk_speed_mps", 0.0)), 4.0) \
	or float(manifest.get("horizontal_displacement_m", 0.0)) < 19.8 or float(manifest.get("horizontal_displacement_m", 0.0)) > 20.0 \
	or float(manifest.get("start_along_from_corner_m", 0.0)) >= -7.9 \
	or float(manifest.get("end_along_from_corner_m", 0.0)) <= 11.8 \
	or float(manifest.get("direction_dot_public_tangent", 0.0)) < 0.999 \
	or int(manifest.get("player_transform_writes_after_input_began", -1)) != 0 \
	or bool(manifest.get("camera_orientation_changed_during_motion", true)) \
	or not bool(manifest.get("all_samples_grounded", false)) \
	or int(manifest.get("recovery_delta", -1)) != 0 \
	or not _bindings_match(manifest.get("bindings", {}) as Dictionary) \
	or not _movie_matches(manifest) \
	or not _samples_match(samples):
		return false
	return true


func _samples_match(samples: Array) -> bool:
	if samples.size() != 300:
		return false
	var prior_along := -INF
	for index in samples.size():
		var sample := samples[index] as Dictionary
		var along := float(sample.get("along_from_corner_m", INF))
		var outward := float(sample.get("outward_from_wall_chain_m", INF))
		if int(sample.get("frame", 0)) != index + 1 \
		or not bool(sample.get("is_on_floor", false)) \
		or (sample.get("player_position_m", []) as Array).size() != 3 \
		or (sample.get("velocity_mps", []) as Array).size() != 3 \
		or (sample.get("camera_position_m", []) as Array).size() != 3 \
		or along + 0.0001 < prior_along \
		or outward < 21.9 or outward > 22.1:
			return false
		prior_along = along
	return float((samples[0] as Dictionary).get("along_from_corner_m", 0.0)) < -7.9 \
		and float((samples[-1] as Dictionary).get("along_from_corner_m", 0.0)) > 11.7


func _movie_matches(manifest: Dictionary) -> bool:
	if str(manifest.get("movie_file", "")) != MOVIE_PATH.get_file() \
	or str(manifest.get("movie_sha256", "")) != EXPECTED_MOVIE_SHA256 \
	or int(manifest.get("movie_bytes", -1)) != EXPECTED_MOVIE_BYTES \
	or not bool(manifest.get("movie_finalized_after_writer_close", false)) \
	or FileAccess.get_sha256(MOVIE_PATH) != EXPECTED_MOVIE_SHA256 \
	or _file_size(MOVIE_PATH) != EXPECTED_MOVIE_BYTES:
		return false
	var file := FileAccess.open(MOVIE_PATH, FileAccess.READ)
	if file == null:
		return false
	var header := file.get_buffer(12)
	file.close()
	return header.slice(0, 4).get_string_from_ascii() == "RIFF" \
		and header.slice(8, 12).get_string_from_ascii() == "AVI "


func _bindings_match(bindings: Dictionary) -> bool:
	return bindings.get("low_receiver_source_keys", []) == ["w1282547787"] \
		and bindings.get("high_receiver_source_keys", []) == ["w1282547786"] \
		and str(bindings.get("low_live_signature", "")) == EXPECTED_LIVE_SIGNATURE \
		and str(bindings.get("high_facade_signature", "")) == EXPECTED_HIGH_SIGNATURE \
		and bool(bindings.get("underlying_wall_is_sole_collision_and_spray_receiver", false)) \
		and not bool(bindings.get("recognition_accepted", true)) \
		and not bool(bindings.get("believability_accepted", true))


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


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


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
