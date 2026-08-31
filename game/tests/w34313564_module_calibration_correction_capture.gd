extends SceneTree

const CALIBRATION_HELPER := preload("res://game/tests/support/w34313564_module_calibration.gd")
const ACCEPTED_FIELDS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const REGISTRY_PATH := "res://game/resources/facades/w34313564_module_calibration.json"
const HELPER_PATH := "res://game/tests/support/w34313564_module_calibration.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-3.json"
const PREDECESSOR_MANIFEST_PATH := "res://evidence/first-playable/batch-06-w34313564-module-calibration-2026-08-30/capture-manifest.json"
const REVIEW_PATH := "res://discovery/facades/W34313564_EXACT_MODULE_CALIBRATION_ART_REVIEW.md"
const OUTPUT := "res://evidence/first-playable/batch-06-w34313564-module-calibration-correction-2026-08-30"
const RECEIVER_KEY := "building:w34313564:wall"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313564_module_calibration_correction_capture.gd"
const EXPECTED_REGISTRY_SHA256 := "45a47d333c997887cef7d1c97a633d37ae050efda597186430c7af6d52116f0f"
const EXPECTED_HELPER_SHA256 := "b49b8c20fbbe40f2728c0acadf8d53f0593856091e6df897a613d4f2f8680b71"
const EXPECTED_ACCEPTED_HELPER_SHA256 := "18d3cdd6cf29349ba8b00283b4e679cd079c176adb24a32cae7f521c7d88a083"
const EXPECTED_PREDECESSOR_MANIFEST_SHA256 := "c664d7e0cae794f9d5be979af89c40a4f65096b29b7f2b14e8032271c2209221"
const EXPECTED_REVIEW_SHA256 := "3c5a8e9c22966c443203e900e0a0762c848eb33d4373c9d8f76b74b1a7dc0735"
const EXPECTED_INVENTORY_SHA256 := "41fd4b1cdc98b31b33801decb02a1303e9d1b6ee48e86214a90e52656f9a8542"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_BUILDER_SHA256 := "c770a977e879c0d077acb8fb4d33b52d1bd6aa3b454a50ba8e2125cb71e8ba8d"
const IMMUTABLE_CAPTURE_TIME_ACCEPTED_HELPER_SHA256 := "8fd1d899cf658f84a5044597e1194d6d0450b74b00281b73ad9b1c91914b21d0"

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Corrected w34313564 calibration evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	var protected := {
		REGISTRY_PATH: EXPECTED_REGISTRY_SHA256,
		HELPER_PATH: EXPECTED_HELPER_SHA256,
		"res://game/scripts/world/facades/accepted_material_run_trials.gd": EXPECTED_ACCEPTED_HELPER_SHA256,
		PREDECESSOR_MANIFEST_PATH: EXPECTED_PREDECESSOR_MANIFEST_SHA256,
		REVIEW_PATH: EXPECTED_REVIEW_SHA256,
		"res://discovery/FACADE_RECEIVER_INVENTORY.json": EXPECTED_INVENTORY_SHA256,
		"res://generated/world/manifest.json": EXPECTED_MANIFEST_SHA256,
		"res://game/scripts/world/world_chunk_builder.gd": EXPECTED_BUILDER_SHA256,
		"res://game/resources/materials/world/w34313564/w34313564_tan_exact_trial.tres": "3b895743b247a20641cb7564004d2f890bacfc286feaec9044b334b5e8e170bb",
		"res://game/resources/materials/world/w34313564/w34313564_pale_exact_trial.tres": "c7ec2df12b0dcf41e2b5019fd98155dbe3668d16379070210fe9f97ef032a343",
	}
	for path: String in protected:
		if not _require(FileAccess.get_sha256(path) == str(protected[path]), "Protected correction input drifted: %s" % path):
			_finish(null)
			return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var predecessor := JSON.parse_string(FileAccess.get_file_as_string(PREDECESSOR_MANIFEST_PATH)) as Dictionary
	var record := _record_data()
	if not _require(not record.is_empty(), "Exact w34313564 generated receiver record did not resolve.") \
	or not _require(_correction_scope_matches(registry, predecessor, record), "The one-door correction or four-placement preservation contract failed."):
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for corrected calibration capture."):
		_finish(null)
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var ready_reports: Array[Dictionary] = []
	var load_failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready_reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: load_failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - started < 50000:
		await process_frame
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Full world did not reach one clean world_ready for corrected calibration capture.") \
	or not _require(str(ready_reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content identity drifted before corrected calibration capture."):
		_finish(main)
		return
	var runtime := world.get_runtime_evidence()
	if not _require(runtime.chunks_loaded == 38 and runtime.mesh_instances == 729 and runtime.surfaces == 736 and runtime.triangles == 48389, "Whole-island render topology drifted before corrected calibration.") \
	or not _require(runtime.static_bodies == 466 and runtime.shapes == 466, "Whole-island collision topology drifted before corrected calibration."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world)
	if not _require(receiver != null and receiver.get_meta("source_keys", []) == ["w34313564"], "Exact w34313564 runtime receiver identity failed."):
		_finish(main)
		return
	var field_metadata := receiver.get_meta("accepted_material_run_trial", {}) as Dictionary
	var receiver_children_before := receiver.get_child_count()
	if not _require(field_metadata == ACCEPTED_FIELDS.metadata_for(RECEIVER_KEY) \
	and str(field_metadata.get("status", "")) == ACCEPTED_FIELDS.BATCH_06_ACCEPTED_STATUS \
	and int(field_metadata.get("modules", -1)) == 0 \
	and int(field_metadata.get("standalone_modules_live", -1)) == 0 \
	and receiver_children_before == 2, "Accepted exact-run fields were not immutable and module-free before corrected overlay."):
		_finish(main)
		return
	var calibration_result := CALIBRATION_HELPER.build(record, registry)
	if not _require(bool(calibration_result.get("ok", false)), str(calibration_result.get("message", "Corrected detached calibration build failed."))):
		_finish(main)
		return
	var calibration := calibration_result.node as Node3D
	main.add_child(calibration)
	if not _require(calibration.get_parent() == main and not calibration.is_ancestor_of(receiver) and receiver.get_child_count() == receiver_children_before, "Corrected overlay attached to or changed the live receiver.") \
	or not _require(_count_type(calibration, MeshInstance3D) == 34 and _count_type(calibration, CollisionObject3D) == 0 and _count_type(calibration, NavigationRegion3D) == 0, "Corrected overlay geometry or noninterference contract failed."):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create corrected calibration evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "W34313564CorrectedModuleCalibrationEvidenceCamera"
	camera.fov = 50.0
	camera.far = 5000.0
	camera.current = true
	main.add_child(camera)
	var sun := main.get_node("Sun") as DirectionalLight3D
	var original_sun := sun.rotation_degrees
	var overlay := _make_overlay()
	main.add_child(overlay)
	var detail := overlay.get_node("Detail") as Label
	var resolved_by_id := {}
	for value: Variant in calibration_result.resolved_placements:
		var resolved := value as Dictionary
		resolved_by_id[str(resolved.placement_id)] = resolved
	var poses := [
		_placement_pose(resolved_by_id["CAL-SSE-PDOOR-01"], "01-close-corrected-sse-pdoor", "close_corrected_tan_door", 6.0, -0.6, 1.4, 1.25),
		_face_pose(record, [5, 6, 7, 8, 9], 55.0, "02-ordinary-corrected-sse-layout", "ordinary_corrected_sse_layout", 42.0, 0.0, 2.7),
	]
	var captures: Array[Dictionary] = []
	for pose_value: Variant in poses:
		var pose := pose_value as Dictionary
		detail.text = "W34313564 ONE-DOOR CALIBRATION CORRECTION\nRUN 6 @ 30.0 M → SSE-CENTRAL RUN 7 @ 47.5 M ±4 M\n%s · STYLIZED/REFERENCE-DERIVED PRODUCTION INFERENCE · ZERO LIVE ATTACHMENT" % str(pose.view_kind).replace("_", " ").to_upper()
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
		var saved := await _save_view(camera, pose)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Corrected calibration capture failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var corrected := _placement_for(registry, "CAL-SSE-PDOOR-01")
	var manifest := {
		"schema_version": "ti.w34313564-module-calibration-correction-evidence/1",
		"review_status": "ready_for_independent_corrected_calibration_review_not_self_accepted",
		"evidence_role": "one bounded detached exact-receiver door-placement correction; stylized/reference-derived production inference, not observed coordinate, cadence, count, live attachment, lifecycle change, or whole-building proof",
		"source_key": "w34313564", "receiver_key": RECEIVER_KEY,
		"generator": "game/tests/w34313564_module_calibration_correction_capture.gd", "capture_command": COMMAND,
		"correction_review": {"path": REVIEW_PATH, "sha256": EXPECTED_REVIEW_SHA256, "brief_id": "W34313564-CAL-01"},
		"predecessor_evidence": {"path": PREDECESSOR_MANIFEST_PATH, "sha256": EXPECTED_PREDECESSOR_MANIFEST_SHA256, "capture_time_accepted_helper_sha256": IMMUTABLE_CAPTURE_TIME_ACCEPTED_HELPER_SHA256, "images_and_manifest_preserved": true},
		"before_after": {"before": {"mapping_id": "B06-34313564-SSE-EAST-RETURN", "anchor_run": 6, "center_chain_m": 30.0}, "after": {"mapping_id": corrected.mapping_id, "anchor_run": corrected.anchor_run, "center_chain_m": corrected.center_chain_m, "center_chain_uncertainty_m": corrected.center_chain_uncertainty_m, "placement_role": corrected.placement_role}},
		"other_four_placements_semantically_identical_to_predecessor": true,
		"registry_path": REGISTRY_PATH, "registry_sha256": EXPECTED_REGISTRY_SHA256,
		"helper_path": HELPER_PATH, "helper_sha256": EXPECTED_HELPER_SHA256,
		"accepted_material_run_helper_sha256": EXPECTED_ACCEPTED_HELPER_SHA256,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"protected_inputs": protected,
		"generated_world_before_overlay": {"chunks": runtime.chunks_loaded, "meshes": runtime.mesh_instances, "surfaces": runtime.surfaces, "triangles": runtime.triangles, "static_bodies": runtime.static_bodies, "shapes": runtime.shapes},
		"receiver_child_count_before_and_after_overlay": [receiver_children_before, receiver.get_child_count()],
		"accepted_field_metadata": field_metadata,
		"placement_policy": registry.placement_policy,
		"placements": registry.placements,
		"resolved_placements": calibration_result.resolved_placements,
		"detached_overlay": {"parent": "main_capture_scene_only", "module_instances": 5, "mesh_instances": 34, "field_meshes": 0, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0, "runtime_attachment": false},
		"captures": captures, "capture_count": captures.size(),
		"preserved_blockers": registry.preserved_blockers,
		"validity_inspection_only": "Inspect corrected door visibility, grounding, complete motif, tan host continuity, tangent/outward transform, separation from HWIN, camera distance, and noninterference only. Executor art acceptance is prohibited.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write corrected calibration capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d native Forward+/Metal w34313564 one-door correction views to %s" % [captures.size(), output_absolute])
	_finish(main)


func _correction_scope_matches(registry: Dictionary, predecessor: Dictionary, record: Dictionary) -> bool:
	var corrected := _placement_for(registry, "CAL-SSE-PDOOR-01")
	if str(corrected.get("mapping_id", "")) != "B06-34313564-SSE-CENTRAL" \
	or int(corrected.get("anchor_run", -1)) != 7 \
	or _int_array(corrected.get("run_ownership", []) as Array) != [7] \
	or not is_equal_approx(float(corrected.get("center_chain_m", -1.0)), 47.5) \
	or not is_equal_approx(float(corrected.get("center_chain_uncertainty_m", -1.0)), 4.0) \
	or str(corrected.get("placement_role", "")) != "stylized/reference-derived production inference":
		return false
	var lower := CALIBRATION_HELPER.chain_frame(record, [5, 6, 7, 8, 9], 42.55)
	var upper := CALIBRATION_HELPER.chain_frame(record, [5, 6, 7, 8, 9], 52.45)
	if lower.is_empty() or upper.is_empty() or int(lower.run_index) != 7 or int(upper.run_index) != 7:
		return false
	var predecessor_placements := {}
	for value: Variant in predecessor.get("placements", []):
		var placement := value as Dictionary
		predecessor_placements[str(placement.placement_id)] = placement
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		var placement_id := str(placement.placement_id)
		if placement_id == "CAL-SSE-PDOOR-01":
			continue
		if not predecessor_placements.has(placement_id) \
		or JSON.stringify(placement) != JSON.stringify(predecessor_placements[placement_id]):
			return false
	return true


func _placement_pose(resolved: Dictionary, id: String, view_kind: String, distance: float, lateral: float, camera_y_delta: float, aim_y_delta: float) -> Dictionary:
	var origin_values := resolved.module_origin_world_m as Array
	var tangent_values := resolved.tangent_world_xz as Array
	var normal_values := resolved.outward_normal_world_xz as Array
	var origin := Vector3(float(origin_values[0]), float(origin_values[1]), float(origin_values[2]))
	var tangent := Vector3(float(tangent_values[0]), 0.0, float(tangent_values[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	var target := origin + Vector3.UP * aim_y_delta
	var camera := target + normal * distance + tangent * lateral
	camera.y += camera_y_delta
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "placement_ids": [str(resolved.placement_id)]}


func _face_pose(record: Dictionary, runs: Array[int], chain_m: float, id: String, view_kind: String, distance: float, lateral: float, height: float) -> Dictionary:
	var frame := CALIBRATION_HELPER.chain_frame(record, runs, chain_m)
	var target := frame.wall_anchor as Vector3
	target.y = float(frame.base_y) + height
	var camera := target + (frame.normal as Vector3) * distance + (frame.tangent as Vector3) * lateral
	camera.y = float(frame.base_y) + minf(height, 2.4)
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "placement_ids": ["CAL-SSE-PDOOR-01", "CAL-SSE-HWIN-01"]}


func _record_data() -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	for record_value: Variant in chunk.get("records", []):
		var record := record_value as Dictionary
		if str(record.get("object_key", "")) == RECEIVER_KEY:
			return record
	return {}


func _record_node_for_key(world: WorldLoader) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == RECEIVER_KEY:
			return value as Node3D
	return null


func _placement_for(registry: Dictionary, placement_id: String) -> Dictionary:
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		if str(placement.get("placement_id", "")) == placement_id:
			return placement
	return {}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _make_overlay() -> CanvasLayer:
	var overlay := CanvasLayer.new()
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.015, 0.02, 0.025, 0.86)
	backdrop.position = Vector2(24, 22)
	backdrop.size = Vector2(1392, 128)
	overlay.add_child(backdrop)
	var detail := Label.new()
	detail.name = "Detail"
	detail.position = Vector2(44, 38)
	detail.add_theme_font_size_override("font_size", 16)
	detail.add_theme_color_override("font_color", Color("f4f0e8"))
	overlay.add_child(detail)
	return overlay


func _save_view(camera: Camera3D, pose: Dictionary) -> Dictionary:
	camera.force_update_transform()
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s produced an empty or wrong-sized image." % str(pose.id)}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.08:
		return {"ok": false, "message": "%s appears blank." % str(pose.id)}
	var relative := "images/%s.png" % str(pose.id)
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(pose.id)}
	var target := pose.target as Vector3
	var metadata := {
		"id": str(pose.id), "view_kind": str(pose.view_kind), "file": relative,
		"sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "aim_target_m": [target.x, target.y, target.z], "camera_fov_degrees": camera.fov,
		"sun_rotation_degrees": [-52.0, -28.0, 0.0], "placement_ids": pose.placement_ids,
		"sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range),
	}
	print("W34313564_CALIBRATION_CORRECTION_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
	return {"ok": true, "metadata": metadata}


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


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error("W34313564_CALIBRATION_CORRECTION_CAPTURE_FAIL: %s" % message)


func _on_timeout() -> void:
	if not _finished:
		_fail("Capture timed out after %.0f seconds." % TIMEOUT_SECONDS)
		_finished = true
		quit(1)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	paused = false
	if main != null and is_instance_valid(main):
		main.queue_free()
		await process_frame
		await process_frame
	quit(0 if _failure.is_empty() else 1)
