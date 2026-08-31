extends SceneTree

const CALIBRATION_HELPER := preload("res://game/tests/support/w34313520_exact_receiver_calibration.gd")
const REGISTRY_PATH := "res://game/resources/facades/w34313520_exact_receiver_calibration.json"
const HELPER_PATH := "res://game/tests/support/w34313520_exact_receiver_calibration.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_0.json"
const OUTPUT := "res://evidence/first-playable/batch-06-w34313520-exact-receiver-calibration-2026-08-30"
const RECEIVER_KEY := "building:w34313520:wall"
const EXPECTED_REGISTRY_SHA256 := "28ea8b6e506d747299a920e4d456d8676031e18ec3b6d9e959cab31fa33de4f1"
const EXPECTED_HELPER_SHA256 := "d747d9f9ca5798b09909efeeb930cdee119f1b3c310e95f9a2c426a3ee6ceea4"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313520_exact_receiver_calibration_capture.gd"
const EXPECTED_PROTECTED_HASHES := {
	REGISTRY_PATH: EXPECTED_REGISTRY_SHA256,
	HELPER_PATH: EXPECTED_HELPER_SHA256,
	CHUNK_PATH: "b935890b89202fa181248552176364668e506a7630f0024ec86f12a084743d86",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://discovery/facades/W34313520_STANDALONE_PROTOTYPE_ART_REVIEW.md": "3d778413b2ef8b93c2fb321dd76301677ea2ea1dc532862457a452a6d972f35e",
	"res://game/resources/facades/w34313520_standalone_prototypes.json": "ab80f0cd0424c22f7f24e5fc82211353e9aee7c95bea4903022681a48c5620a4",
	"res://game/resources/materials/world/w34313520/w34313520_pale_field.tres": "7944151fd5ab8e977e7052d0cdb8df20132c82f967d8ebfefff83ede8fcf07a4",
	"res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres": "89fbb97ed797275a86c394af7eab13f946cbf23f29cba58b89a2b2d467030ab2",
	"res://game/resources/materials/world/w34313520/w34313520_bay_frame.tres": "445d3bec9d2ef3130aab27c816b27e384c689af68298b2db5ada37e0178f249b",
	"res://game/resources/materials/world/w34313520/w34313520_bay_glass.tres": "40caf8b054b51ebf247a41286dec9efdbf925f09acf698a75285a4321a41bba6",
	"res://game/scripts/world/facades/w34313520_standalone_prototypes.gd": "1244f590ed0854219f50a25a4c7931f4f094ce19fb65cefcf2d61b8ce4cd8566",
	"res://game/scenes/world/facades/batch_06/w34313520_standalone_prototype_set.tscn": "4d0ee0e79ea6fd5a7e85b21cdf4a103d125818626b6c97875737cad44cc65785",
	"res://game/scripts/world/world_chunk_builder.gd": "84aaf060b6282e956bbae81e4880ac8e203e107760d627c48f7d9e5abb72183e",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "4741097b177f02074c6b254e03f955dce46703dfef89b0a4cbc0a8b424f7ae6f",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "efe1c0f531488f1ad3f0e2b2337beea1e93162df35ba7124bb8d5ef37475b544",
	"res://game/scripts/world/facades/w34313564_live_modules.gd": "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee",
	"res://game/scripts/world/facades/w34313515_live_modules.gd": "4420ad2d0a029f03da7a14fe84084d53edfa2323867a5c660c63f875c2a71ccb",
	"res://game/scripts/world/facades/w291196370_live_modules.gd": "e297d40ac9841485ee00a76b955f8ec454639b394c23759e8017e170aa84cbf8",
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("w34313520 exact-receiver calibration evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for file_name: String in EXPECTED_PROTECTED_HASHES:
		if not _require(FileAccess.get_sha256(file_name) == str(EXPECTED_PROTECTED_HASHES[file_name]), "Protected calibration input drifted: %s" % file_name):
			_finish(null)
			return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var record := _record_data()
	if not _require(not record.is_empty(), "Exact w34313520 generated receiver record did not resolve."):
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for w34313520 calibration capture."):
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
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Full world did not reach one clean world_ready for calibration capture.") \
	or not _require(str(ready_reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content identity drifted before calibration capture."):
		_finish(main)
		return
	var runtime_before := world.get_runtime_evidence()
	if not _require(runtime_before.chunks_loaded == 38 and runtime_before.mesh_instances == 871 and runtime_before.surfaces == 878 and runtime_before.triangles == 50093, "Whole-island loaded render topology drifted before detached calibration.") \
	or not _require(runtime_before.static_bodies == 466 and runtime_before.shapes == 466, "Whole-island collision topology drifted before detached calibration."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world)
	if not _require(receiver != null and receiver.get_meta("source_keys", []) == ["w34313520"], "Exact w34313520 runtime receiver identity failed."):
		_finish(main)
		return
	var receiver_children_before := receiver.get_child_count()
	var field_metadata_before := receiver.get_meta("accepted_material_run_trial", {}) as Dictionary
	if not _require(field_metadata_before.is_empty() and receiver_children_before == 2, "w34313520 was not placeholder-only and child-stable before the detached overlay."):
		_finish(main)
		return
	var calibration_result := CALIBRATION_HELPER.build(record, registry)
	if not _require(bool(calibration_result.get("ok", false)), str(calibration_result.get("message", "Detached calibration build failed."))):
		_finish(main)
		return
	var calibration := calibration_result.node as Node3D
	main.add_child(calibration)
	var runtime_after_overlay := world.get_runtime_evidence()
	if not _require(calibration.get_parent() == main and not calibration.is_ancestor_of(receiver) and receiver.get_child_count() == receiver_children_before, "Calibration overlay attached to or changed the live receiver.") \
	or not _require(JSON.stringify(runtime_before) == JSON.stringify(runtime_after_overlay), "Detached sibling overlay changed WorldLoader runtime topology evidence."):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create calibration evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "W34313520ExactReceiverCalibrationEvidenceCamera"
	camera.fov = 50.0
	camera.far = 5000.0
	camera.current = true
	main.add_child(camera)
	var sun := main.get_node("Sun") as DirectionalLight3D
	var original_sun := sun.rotation_degrees
	var overlay := _make_overlay()
	main.add_child(overlay)
	var detail := overlay.get_node("Detail") as Label
	var resolved := calibration_result.resolved_placement as Dictionary
	var captures: Array[Dictionary] = []
	for pose_value: Variant in _poses(record, resolved):
		var pose := pose_value as Dictionary
		detail.text = "W34313520 DETACHED EXACT-RECEIVER CALIBRATION · SSE RUNS 6..10 · 68.156 m FIELD\nEXACTLY 1 COMPLETE BAY · RUN 7 MIDPOINT · PRODUCTION INFERENCE · COUNT/CADENCE UNSURVEYED\n%s · ZERO LIVE ATTACHMENT · OTHER RUNS/SIDES/ELEVATION/WHOLE BUILDING BLOCKED" % str(pose.view_kind).replace("_", " ").to_upper()
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		var saved := await _save_view(camera, pose)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Calibration capture failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var manifest := {
		"schema_version": "ti.w34313520-exact-receiver-calibration-evidence/1",
		"review_status": "ready_for_independent_detached_exact_receiver_art_review_not_self_accepted",
		"evidence_role": "detached exact generated-receiver W34313520-MAT-PALE scale/phase proposal on SSE runs 6..10 plus exactly one complete W34313520-BAY exemplar at run 7 midpoint; not live attachment, lifecycle acceptance, surveyed dimensions/coordinates/count/cadence, completed elevation, or whole-building proof",
		"source_key": "w34313520",
		"receiver_key": RECEIVER_KEY,
		"generator": "game/tests/w34313520_exact_receiver_calibration_capture.gd",
		"capture_command": COMMAND,
		"registry_path": REGISTRY_PATH,
		"registry_sha256": EXPECTED_REGISTRY_SHA256,
		"helper_path": HELPER_PATH,
		"helper_sha256": EXPECTED_HELPER_SHA256,
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"protected_inputs": EXPECTED_PROTECTED_HASHES,
		"generated_world_unchanged": {"records": 729, "meshes": 729, "surfaces": 736, "triangles": 48389, "static_bodies": 466, "shapes": 466},
		"loaded_world_before_and_after_overlay": {
			"before": {"chunks": runtime_before.chunks_loaded, "meshes": runtime_before.mesh_instances, "surfaces": runtime_before.surfaces, "triangles": runtime_before.triangles, "static_bodies": runtime_before.static_bodies, "shapes": runtime_before.shapes},
			"after": {"chunks": runtime_after_overlay.chunks_loaded, "meshes": runtime_after_overlay.mesh_instances, "surfaces": runtime_after_overlay.surfaces, "triangles": runtime_after_overlay.triangles, "static_bodies": runtime_after_overlay.static_bodies, "shapes": runtime_after_overlay.shapes}
		},
		"receiver_child_count_before_and_after_overlay": [receiver_children_before, receiver.get_child_count()],
		"receiver_accepted_material_metadata_before_and_after": [field_metadata_before, receiver.get_meta("accepted_material_run_trial", {})],
		"exact_field_scope": registry.exact_field_scope,
		"module_contract": registry.module_contract,
		"placement_policy": registry.placement_policy,
		"placement": registry.placement,
		"resolved_field_scope": calibration_result.resolved_field_scope,
		"resolved_placement": calibration_result.resolved_placement,
		"detached_overlay": registry.detached_overlay_contract,
		"excluded_regions": registry.excluded_regions,
		"preserved_false_claims": registry.preserved_false_claims,
		"captures": captures,
		"capture_count": captures.size(),
		"validity_inspection_only": "Inspect exact run field continuity/scale/phase, one complete BAY contact and shallow depth, ordinary SSE/building context, changed light, sparse exemplar truth, and receiver isolation only. Executor art acceptance is prohibited."
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write calibration capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d native Forward+/Metal w34313520 detached exact-receiver field/BAY calibration views with receiver children %d→%d and runtime topology unchanged" % [captures.size(), receiver_children_before, receiver.get_child_count()])
	_finish(main)


func _poses(record: Dictionary, resolved: Dictionary) -> Array[Dictionary]:
	return [
		_boundary_pose(record, 6, 7, "01-close-field-run06-07-junction", "close_exact_field_continuity_run_6_to_7", 14.0, 5.0, Vector3(-52.0, -28.0, 0.0)),
		_face_pose(record, [6, 7], 40.0, "02-macro-field-runs06-07", "macro_56_834m_exact_field_span", 58.0, 3.2, [6, 7], Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(resolved, "03-close-complete-bay", "close_complete_bay_run_7_midpoint", 15.0, 0.0, 4.5, Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(resolved, "04-oblique-complete-bay", "oblique_complete_bay_depth_and_zero_backing", 23.0, 10.0, 5.0, Vector3(-52.0, -28.0, 0.0)),
		_face_pose(record, [6, 7, 8, 9, 10], 34.0, "05-ordinary-sse-exact-scope", "ordinary_gameplay_height_all_exact_SSE_runs", 55.0, 2.5, [6, 7, 8, 9, 10], Vector3(-52.0, -28.0, 0.0)),
		_face_pose(record, [6, 7, 8, 9, 10], 34.0, "06-building-context", "ordinary_building_context_sparse_single_exemplar", 90.0, 5.5, [6, 7, 8, 9, 10], Vector3(-52.0, -28.0, 0.0), -18.0),
		_placement_pose(resolved, "07-changed-light-field-and-bay", "changed_light_oblique_exact_field_and_complete_bay", 28.0, -8.0, 5.3, Vector3(-20.0, 118.0, 0.0)),
	]


func _placement_pose(resolved: Dictionary, id: String, view_kind: String, distance: float, lateral: float, camera_height_above_base: float, sun: Vector3) -> Dictionary:
	var origin := _vector3(resolved.module_origin_world_m as Array)
	var tangent_values := resolved.tangent_world_xz as Array
	var normal_values := resolved.outward_normal_world_xz as Array
	var tangent := Vector3(float(tangent_values[0]), 0.0, float(tangent_values[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	var camera := origin + normal * distance + tangent * lateral
	camera.y = float(resolved.base_y_m) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": origin, "sun": sun, "placement_ids": [str(resolved.placement_id)], "representative_runs": [7]}


func _face_pose(record: Dictionary, runs: Array[int], chain_m: float, id: String, view_kind: String, distance: float, camera_height_above_base: float, representative_runs: Array[int], sun: Vector3, lateral: float = 0.0) -> Dictionary:
	var frame := CALIBRATION_HELPER.chain_frame(record, runs, chain_m)
	var wall_anchor := frame.wall_anchor as Vector3
	var normal := frame.normal as Vector3
	var tangent := frame.tangent as Vector3
	var target := wall_anchor
	target.y = float(frame.base_y) + 5.5
	var camera := target + normal * distance + tangent * lateral
	camera.y = float(frame.base_y) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": ["CAL-SSE-BAY-01"], "representative_runs": representative_runs}


func _boundary_pose(record: Dictionary, before_run: int, after_run: int, id: String, view_kind: String, distance: float, camera_height_above_base: float, sun: Vector3) -> Dictionary:
	var before := CALIBRATION_HELPER.run_frame(record, before_run)
	var after := CALIBRATION_HELPER.run_frame(record, after_run)
	var junction := ((before.end as Vector3) + (after.start as Vector3)) * 0.5
	var normal := ((before.normal as Vector3) + (after.normal as Vector3)).normalized()
	var target := junction
	target.y = 8.5
	var camera := target + normal * distance
	camera.y = junction.y + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": [], "representative_runs": [before_run, after_run]}


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


func _make_overlay() -> CanvasLayer:
	var overlay := CanvasLayer.new()
	overlay.name = "W34313520ExactCalibrationEvidenceOverlay"
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.015, 0.02, 0.025, 0.86)
	backdrop.position = Vector2(24, 22)
	backdrop.size = Vector2(1392, 108)
	overlay.add_child(backdrop)
	var detail := Label.new()
	detail.name = "Detail"
	detail.position = Vector2(44, 36)
	detail.add_theme_font_size_override("font_size", 15)
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
	var output_path := OUTPUT.path_join(relative)
	if image.save_png(output_path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(pose.id)}
	var target := pose.target as Vector3
	var metadata := {
		"id": str(pose.id),
		"view_kind": str(pose.view_kind),
		"file": relative,
		"sha256": FileAccess.get_sha256(output_path),
		"bytes": FileAccess.get_file_as_bytes(output_path).size(),
		"dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_position_m": [camera.position.x, camera.position.y, camera.position.z],
		"aim_target_m": [target.x, target.y, target.z],
		"camera_fov_degrees": camera.fov,
		"sun_rotation_degrees": [(pose.sun as Vector3).x, (pose.sun as Vector3).y, (pose.sun as Vector3).z],
		"placement_ids": pose.placement_ids,
		"representative_runs": pose.representative_runs,
		"sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range),
	}
	print("W34313520_EXACT_CAL_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(output_path), str(metadata.sha256)])
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


func _vector3(values: Array) -> Vector3:
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _write_json(output_path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(output_path, FileAccess.WRITE)
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
	push_error("W34313520_EXACT_CAL_CAPTURE_FAIL: %s" % message)


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
