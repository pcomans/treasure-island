extends SceneTree

const ROOT := "res://evidence/first-playable/p3-existing-live-material-revalidation-2026-09-04"
const MANIFEST_PATH := ROOT + "/capture-manifest.json"
const GENERATOR_PATH := "res://game/tests/p3_existing_live_material_revalidation_capture.gd"
const EXPECTED_MANIFEST_SHA256 := "f48dc2db29228caaad418d01e15288ce7ff1e673bff8819fc70837d24aaa66e7"
const EXPECTED_GENERATOR_SHA256 := "ae2dc67a4437f12d3020e3ac334d3ce10738ce3a87b213bcf90b93160bb4170c"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_GENERATED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const CAPTURE_SIZE := Vector2i(1440, 900)
const DORMITORY_CONFLICT := "The reference shows five occupied tiers, while the exact current generated receiver remains fallback 6 m. This capture must expose the whole generated entity and may not imply that contradiction is resolved."

const EXPECTED_TARGETS := {
	"navy-chapel-187": {
		"source_key": "w291189336",
		"receiver_key": "building:w291189336:wall",
		"receiver_source_keys": ["w291189336"],
		"chunk_path": "res://generated/world/chunks/x_-1__z_2.json",
		"chunk_sha256": "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
		"reference_packet": "res://discovery/facades/p3_reference_packets/w291189336_navy_chapel_building_187.md",
		"reference_packet_sha256": "7eb592503ce8e276c38ef3ecaf7f2d3dd17e1eeb32adbe45d1059c5cb4693330",
		"run_map": "res://discovery/facades/BATCH_02_RUN_MAPPING.json",
		"run_map_sha256": "d076ee125168cd3dfe499bc56e94c324019d7ba70bb731b9c23c045ca6759b5f",
		"material_path": "res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
		"material_sha256": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5",
		"accepted_runs": [9, 10],
		"protected_runs": [0, 1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33],
		"accepted_length_m": 16.362,
		"render_triangles": 68,
		"confusion_set": ["w291189918", "w291189926", "w34313521"],
		"cue_count": 3,
		"massing_conflict": false,
	},
	"dormitory-369": {
		"source_key": "w291189926",
		"receiver_key": "building:w291189926:wall",
		"receiver_source_keys": ["w291189926"],
		"chunk_path": "res://generated/world/chunks/x_0__z_1.json",
		"chunk_sha256": "a35f63a877588d198e0e905167968bf9948f4616c16e708a6799d0e6c1bde00a",
		"reference_packet": "res://discovery/facades/p3_reference_packets/w291189926_job_corps_dormitory_369.md",
		"reference_packet_sha256": "a43d391239c2fd3ce66b13c39dc56c534253211e7a44a12d512dbe5367b3a9f9",
		"run_map": "res://discovery/facades/BATCH_04_RUN_MAPPING.json",
		"run_map_sha256": "3ec81316f9bdfb6131df55faeabe822b3fdfb2b739b95bd452a50a1d97a29e42",
		"material_path": "res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres",
		"material_sha256": "fb50d3989b7aa41421753ad4db5d195366d9a2c25c15087e5e3a2b7863c69602",
		"accepted_runs": [0, 1, 2, 3, 4, 5],
		"protected_runs": [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71],
		"accepted_length_m": 49.124,
		"render_triangles": 144,
		"confusion_set": ["w34313514", "w34313521", "w291189918"],
		"cue_count": 3,
		"massing_conflict": true,
	},
}

const EXPECTED_CAPTURES := [
	{
		"id": "01-navy-chapel-whole-object",
		"target": "navy-chapel-187",
		"role": "whole_object_ordinary_player_view",
		"file": "images/navy-chapel-187/01-navy-chapel-whole-object.png",
		"sha256": "2edeaff94139639da514d049f42f94819881c7a421a4dd24f24b1b305ecd4833",
		"receiver": "building:w291189336:wall",
		"source_keys": ["w291189336"],
		"run": 9,
		"confusion_set": ["w291189918", "w291189926", "w34313521"],
	},
	{
		"id": "02-navy-chapel-oblique",
		"target": "navy-chapel-187",
		"role": "oblique_ordinary_player_view",
		"file": "images/navy-chapel-187/02-navy-chapel-oblique.png",
		"sha256": "8cff88807fa537c8360b6a314e322b84413e2af1561bf48134efd45211eb0733",
		"receiver": "building:w291189336:wall",
		"source_keys": ["w291189336"],
		"run": 9,
		"confusion_set": ["w291189918", "w291189926", "w34313521"],
	},
	{
		"id": "03-dormitory-369-whole-object",
		"target": "dormitory-369",
		"role": "whole_object_ordinary_player_view",
		"file": "images/dormitory-369/03-dormitory-369-whole-object.png",
		"sha256": "4a8ccc548cb46827a0f9f827b8eeed8fa2e120446ebfb8b80f5e4a5b67249992",
		"receiver": "building:w291189926:wall",
		"source_keys": ["w291189926"],
		"run": 12,
		"confusion_set": ["w34313514", "w34313521", "w291189918"],
	},
	{
		"id": "04-dormitory-369-oblique",
		"target": "dormitory-369",
		"role": "oblique_ordinary_player_view",
		"file": "images/dormitory-369/04-dormitory-369-oblique.png",
		"sha256": "c2f5ffcf91e1e2012aa2d22cd04d4a534c5f557049a4d45ff1bca577f8d423eb",
		"receiver": "building:w291189926:wall",
		"source_keys": ["w291189926"],
		"run": 2,
		"confusion_set": ["w34313514", "w34313521", "w291189918"],
	},
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "P3 evidence manifest bytes drifted.")
	_require(FileAccess.get_sha256(GENERATOR_PATH) == EXPECTED_GENERATOR_SHA256, "P3 native capture harness bytes drifted after sealing.")
	var manifest := _json(MANIFEST_PATH)
	_require(_header_matches(manifest), "P3 evidence renderer, camera, pending-only claim state, or protected scope drifted.")
	_require(_world_matches(manifest.get("generated_world", {}) as Dictionary), "P3 generated-world provenance drifted.")
	_require(_targets_match(manifest.get("targets", {}) as Dictionary), "P3 exact target binding, run partition, source packet, material, or confusion set drifted.")
	_require(_captures_match(manifest.get("captures", []) as Array), "P3 image, stock-player grounding, framing, HUD, or exact first-hit LOS evidence drifted.")
	if not _failed:
		print("PASS: four sealed native Metal P3 views remain exact-current and technically valid; Chapel and Dormitory whole-object recognition/believability remain pending, and Dormitory five-tier versus 6 m massing remains explicitly unresolved")
	quit(1 if _failed else 0)


func _header_matches(manifest: Dictionary) -> bool:
	var verdicts := manifest.get("recognition_verdicts", {}) as Dictionary
	var camera := manifest.get("camera_contract", {}) as Dictionary
	var protected := manifest.get("protected_scope", {}) as Dictionary
	var viewport := manifest.get("viewport", []) as Array
	var result: bool = str(manifest.get("schema_version", "")) == "ti.p3-existing-live-material-revalidation-evidence/1" \
		and str(manifest.get("review_status", "")) == "technical_capture_valid_recognition_and_believability_pending_independent_review" \
		and verdicts == {
			"navy-chapel-187": "pending_independent_whole_object_review",
			"dormitory-369": "pending_independent_whole_object_review_with_unresolved_five_tier_vs_6m_conflict",
		} \
		and str(manifest.get("display_driver", "")) == "macOS" \
		and str(manifest.get("rendering_method", "")) == "Forward+" \
		and str(manifest.get("rendering_driver", "")) == "Metal" \
		and viewport.size() == 2 and int(viewport[0]) == 1440 and int(viewport[1]) == 900 \
		and str(manifest.get("generator", "")) == "game/tests/p3_existing_live_material_revalidation_capture.gd" \
		and str(manifest.get("generator_sha256", "")) == EXPECTED_GENERATOR_SHA256 \
		and int(manifest.get("capture_count", -1)) == EXPECTED_CAPTURES.size() \
		and bool(manifest.get("frozen_confusion_sets_selected_before_capture_inspection", false)) \
		and not bool(manifest.get("source_photography_shipped", true)) \
		and bool(manifest.get("recognition_review_prohibited_for_executor", false)) \
		and str(manifest.get("dormitory_massing_conflict_unresolved", "")) == DORMITORY_CONFLICT \
		and str(camera.get("rig", "")) == "actual Player/CameraPivot/SpringArm3D/Camera3D" \
		and bool(camera.get("player_visible", false)) \
		and is_equal_approx(float(camera.get("fov_degrees", -1.0)), 70.0) \
		and is_equal_approx(float(camera.get("configured_spring_length_m", -1.0)), 5.5) \
		and is_equal_approx(float(camera.get("minimum_actual_spring_length_m", -1.0)), 4.5) \
		and is_equal_approx(float(camera.get("minimum_camera_height_above_ground_m", -1.0)), 1.0) \
		and not bool(camera.get("detached_camera", true)) \
		and not bool(camera.get("camera_tricks", true)) \
		and not bool(camera.get("context_hidden", true)) \
		and not bool(camera.get("lighting_changed", true)) \
		and not bool(camera.get("crop_or_postprocess", true)) \
		and not bool(camera.get("debug_labels_visible", true)) \
		and _float_array_matches(camera.get("sun_rotation_degrees", []) as Array, [-52.0, -28.0, 0.0]) \
		and not bool(protected.get("visuals_or_materials_changed", true)) \
		and not bool(protected.get("runtime_or_world_changed", true)) \
		and not bool(protected.get("generated_files_changed", true)) \
		and not bool(protected.get("geometry_or_massing_changed", true)) \
		and not bool(protected.get("collision_navigation_or_spray_changed", true)) \
		and int(protected.get("modules_added", -1)) == 0 \
		and bool(protected.get("protected_placeholder_runs_remain_visible_in_full_entity_context", false))
	if not result:
		print("P3_HEADER_ACTUAL: %s" % JSON.stringify({"verdicts": verdicts, "camera": camera, "protected": protected, "viewport": viewport}))
	return result


func _world_matches(world: Dictionary) -> bool:
	return str(world.get("content_sha256", "")) == EXPECTED_CONTENT_SHA256 \
		and str(world.get("manifest_sha256", "")) == EXPECTED_GENERATED_MANIFEST_SHA256 \
		and int(world.get("playable_rows", -1)) == 735 \
		and int(world.get("context_rows", -1)) == 4 \
		and int(world.get("meshes", -1)) == 938 \
		and int(world.get("surfaces", -1)) == 948 \
		and int(world.get("triangles", -1)) == 63720 \
		and int(world.get("static_bodies", -1)) == 466 \
		and int(world.get("shapes", -1)) == 466 \
		and FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_GENERATED_MANIFEST_SHA256


func _targets_match(targets: Dictionary) -> bool:
	if targets.size() != EXPECTED_TARGETS.size():
		return false
	for target_id: String in EXPECTED_TARGETS:
		var target := targets.get(target_id, {}) as Dictionary
		var expected := EXPECTED_TARGETS[target_id] as Dictionary
		if str(target.get("source_key", "")) != str(expected.source_key) \
		or str(target.get("receiver_key", "")) != str(expected.receiver_key) \
		or target.get("receiver_source_keys", []) != expected.receiver_source_keys \
		or not _int_array_matches(target.get("accepted_runs", []) as Array, expected.accepted_runs as Array) \
		or not _int_array_matches(target.get("actual_accepted_runs", []) as Array, expected.accepted_runs as Array) \
		or not _int_array_matches(target.get("protected_runs", []) as Array, expected.protected_runs as Array) \
		or not _int_array_matches(target.get("actual_protected_runs", []) as Array, expected.protected_runs as Array) \
		or absf(float(target.get("accepted_length_m", -1.0)) - float(expected.accepted_length_m)) > 0.0001 \
		or int(target.get("render_triangles", -1)) != int(expected.render_triangles) \
		or int(target.get("collision_triangles", -1)) != int(expected.render_triangles) \
		or int(target.get("modules", -1)) != 0 \
		or target.get("confusion_set_source_ids", []) != expected.confusion_set \
		or (target.get("reference_supported_cues", []) as Array).size() != int(expected.cue_count) \
		or bool(target.get("massing_conflict", false)) != bool(expected.massing_conflict) \
		or str(target.get("whole_object_recognition_status", "")) != "pending_independent_review":
			print("P3_TARGET_ACTUAL_%s: %s" % [target_id, JSON.stringify(target)])
			print("P3_TARGET_EXPECTED_%s: %s" % [target_id, JSON.stringify(expected)])
			return false
		for path_key: String in ["chunk_path", "reference_packet", "run_map", "material_path"]:
			var path := str(target.get(path_key, ""))
			var hash_key := path_key.trim_suffix("_path") + "_sha256"
			if path != str(expected.get(path_key, "")) \
			or str(target.get(hash_key, "")) != str(expected.get(hash_key, "")) \
			or FileAccess.get_sha256(path) != str(expected.get(hash_key, "")):
				print("P3_TARGET_FILE_MISMATCH_%s: key=%s path=%s hash_key=%s actual=%s expected=%s current=%s" % [target_id, path_key, path, hash_key, str(target.get(hash_key, "")), str(expected.get(hash_key, "")), FileAccess.get_sha256(path)])
				return false
		if str(target.get("recognition_gate", "")).is_empty() or str(target.get("current_limitation", "")).is_empty():
			return false
		if target_id == "dormitory-369" and str(target.get("massing_conflict_text", "")) != DORMITORY_CONFLICT:
			return false
	return true


func _captures_match(captures: Array) -> bool:
	if captures.size() != EXPECTED_CAPTURES.size():
		return false
	var role_counts := {
		"navy-chapel-187": {"whole_object_ordinary_player_view": 0, "oblique_ordinary_player_view": 0},
		"dormitory-369": {"whole_object_ordinary_player_view": 0, "oblique_ordinary_player_view": 0},
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
		or int(capture.get("first_los_hit_run_index", -1)) != int(expected.run) \
		or int(capture.get("expected_los_run_index", -1)) != int(expected.run) \
		or capture.get("confusion_set_source_ids_frozen_before_capture", []) != expected.confusion_set \
		or (capture.get("reference_supported_cues_frozen_before_capture", []) as Array).size() < 2:
			return false
		var image_path := ROOT.path_join(str(capture.file))
		var image := Image.load_from_file(image_path)
		if FileAccess.get_sha256(image_path) != str(expected.sha256) \
		or image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE \
		or FileAccess.get_file_as_bytes(image_path).size() != int(capture.get("bytes", -1)):
			return false
		var sample := _sample_image(image)
		var hud := capture.get("hud", {}) as Dictionary
		if not bool(capture.get("physics_grounded", false)) \
		or not bool(capture.get("ordinary_player_rig", false)) \
		or not bool(capture.get("input_reachable_camera_orientation", false)) \
		or not bool(capture.get("in_boundary", false)) \
		or not bool(capture.get("receiver_source_run_first_los", false)) \
		or not bool(capture.get("player_visible", false)) \
		or bool(capture.get("debug_labels_visible", true)) \
		or bool(capture.get("source_photography_in_frame", true)) \
		or bool(capture.get("lighting_changed", true)) \
		or not bool(capture.get("full_entity_required_and_in_frame", false)) \
		or not bool(capture.get("protected_untreated_faces_intentionally_not_hidden", false)) \
		or str(capture.get("recognition_verdict", "")) != "pending_independent_review" \
		or str(capture.get("believability_verdict", "")) != "pending_independent_review" \
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
		or float(capture.get("first_los_hit_target_error_m", INF)) > 0.25 \
		or int(capture.get("first_los_collision_mask", -1)) != 1 \
		or int(capture.get("target_bounds_points_behind_camera", -1)) != 0 \
		or not bool(capture.get("target_bounds_fully_in_frame", false)) \
		or float(capture.get("target_projected_width_ratio", 0.0)) < 0.12 \
		or float(capture.get("target_projected_height_ratio", 0.0)) < 0.025 \
		or int(capture.get("live_scope_bounds_points_behind_camera", -1)) != 0 \
		or not bool(capture.get("live_scope_bounds_fully_in_frame", false)) \
		or float(capture.get("live_scope_projected_width_ratio", 0.0)) < 0.04 \
		or float(capture.get("live_scope_projected_height_ratio", 0.0)) < 0.03 \
		or int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1 \
		or int(capture.get("sample_unique_colors", 0)) < 8 \
		or float(capture.get("sample_luminance_range", 0.0)) < 0.1 \
		or bool(hud.get("debug_panel_visible", true)) \
		or bool(hud.get("feedback_panel_visible", true)) \
		or bool(hud.get("load_panel_visible", true)) \
		or bool(hud.get("pause_panel_visible", true)) \
		or not bool(hud.get("reticle_visible", false)):
			return false
		var counts := role_counts[str(capture.target)] as Dictionary
		counts[str(capture.role)] = int(counts[str(capture.role)]) + 1
	for counts_value: Variant in role_counts.values():
		var counts := counts_value as Dictionary
		if int(counts.whole_object_ordinary_player_view) != 1 or int(counts.oblique_ordinary_player_view) != 1:
			return false
	return true


func _sample_image(image: Image) -> Dictionary:
	var colors := {}
	var minimum := 1.0
	var maximum := 0.0
	for sample_y in 20:
		var y := mini(image.get_height() - 1, int((float(sample_y) + 0.5) * image.get_height() / 20.0))
		for sample_x in 32:
			var x := mini(image.get_width() - 1, int((float(sample_x) + 0.5) * image.get_width() / 32.0))
			var color := image.get_pixel(x, y)
			colors[color.to_rgba32()] = true
			minimum = minf(minimum, color.get_luminance())
			maximum = maxf(maximum, color.get_luminance())
	return {"unique_colors": colors.size(), "luminance_range": maximum - minimum}


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _int_array_matches(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for index in actual.size():
		if int(actual[index]) != int(expected[index]) or float(actual[index]) != float(int(actual[index])):
			return false
	return true


func _float_array_matches(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for index in actual.size():
		if not is_equal_approx(float(actual[index]), float(expected[index])):
			return false
	return true


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
