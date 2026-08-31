extends SceneTree

const CALIBRATION_HELPER := preload("res://game/tests/support/w34313515_module_calibration.gd")
const FIELD_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const REGISTRY_PATH := "res://game/resources/facades/w34313515_module_calibration.json"
const HELPER_PATH := "res://game/tests/support/w34313515_module_calibration.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_1.json"
const OUTPUT := "res://evidence/first-playable/batch-06-w34313515-bay-calibration-2026-08-30"
const RECEIVER_KEY := "building:w34313515:wall"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313515_module_calibration_capture.gd"
const EXPECTED_REGISTRY_SHA256 := "2d378a94da4b7badd334d5c00f926a26a4ff9109782abb18e4859301df4b5c1d"
const EXPECTED_HELPER_SHA256 := "1edfdf4b736a7b1cc2883569a4c09b48814cabf30e3056e9dac86152de22d5f1"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_PROTECTED_HASHES := {
	REGISTRY_PATH: EXPECTED_REGISTRY_SHA256,
	HELPER_PATH: EXPECTED_HELPER_SHA256,
	CHUNK_PATH: "b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c",
	"res://discovery/facades/BATCH_06_STREETVIEW_OBSERVATIONS.md": "259e562e69b1186912fce2dfb466f4512fbc69cc8e64562574971c0a8c40028b",
	"res://discovery/facades/W34313515_REFERENCE_SPEC.md": "7b5da4a8a25d7f328f086ac0b7995323039f1e49e0335f1c121f854138606ace",
	"res://discovery/facades/BATCH_06_RUN_MAPPING.json": "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d",
	"res://discovery/facades/BATCH_06_PROTOTYPE_SET_01_MODULE_CORRECTION_ART_REVIEW.md": "70f6a0e1e9ece07d162aa669aa89e4f4a9a8b19b1785eb7fb91efc0dc8f6aded",
	"res://game/resources/facades/batch_06_prototype_registry.json": "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132",
	"res://game/scripts/world/facades/batch_06_prototype_set.gd": "fecc656332599acefbf307ce6b5978e62c689ae146f713cf9d935ef66b81de60",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "545d3d4b42fef07c64a035a65006c533b8549d983e4b28bc510eaada60712c9f",
	"res://game/resources/materials/world/w34313515/w34313515_pale_exact_trial.tres": "0b8704ccc352374adc1d6a553ff3d985ae2b70559d92b5171092450783b4395f",
	"res://game/resources/materials/world/w34313515/w34313515_frame.tres": "716afbdf12f55975747b08c615236462d335b62ca0c46730b4cb8439b9691aa5",
	"res://game/resources/materials/world/w34313515/w34313515_glass.tres": "963160407868064dcbb66b56cf477d0901f53a27351cbb23905474b5b613a4cc",
	"res://game/scripts/world/world_chunk_builder.gd": "3c9e995aefe4e02fd466e51aa3a762fa53137f69a57091b395a59abda0f27cb9",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "768ab70a84f3e5e5b0e400a1ce7347ee50e073aa59be5f98cb34f73194e6ae5d",
	"res://game/scripts/world/facades/w34313564_live_modules.gd": "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee",
	"res://game/resources/facades/w34313564_module_calibration.json": "45a47d333c997887cef7d1c97a633d37ae050efda597186430c7af6d52116f0f",
	"res://evidence/first-playable/batch-06-exact-receiver-trials-2026-08-30/capture-manifest.json": "034b6ef3ad0e85b81a2565a9443172bec3da9364ed29ab5b4cc6b34258e72449",
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("w34313515 BAY calibration evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for path: String in EXPECTED_PROTECTED_HASHES:
		if not _require(FileAccess.get_sha256(path) == str(EXPECTED_PROTECTED_HASHES[path]), "Protected calibration input drifted: %s" % path):
			_finish(null)
			return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var record := _record_data()
	if not _require(not record.is_empty(), "Exact w34313515 generated receiver record did not resolve."):
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for w34313515 calibration capture."):
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
	var runtime := world.get_runtime_evidence()
	if not _require(runtime.chunks_loaded == 38 and runtime.mesh_instances == 763 and runtime.surfaces == 770 and runtime.triangles == 48797, "Whole-island loaded render topology drifted before detached calibration.") \
	or not _require(runtime.static_bodies == 466 and runtime.shapes == 466, "Whole-island collision topology drifted before detached calibration."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world)
	if not _require(receiver != null and receiver.get_meta("source_keys", []) == ["w34313515"], "Exact w34313515 runtime receiver identity failed."):
		_finish(main)
		return
	var field_metadata := receiver.get_meta("accepted_material_run_trial", {}) as Dictionary
	var receiver_children_before := receiver.get_child_count()
	if not _require(field_metadata == FIELD_TRIALS.metadata_for(RECEIVER_KEY) \
	and int(field_metadata.get("modules", -1)) == 0 \
	and int(field_metadata.get("standalone_modules_live", -1)) == 0 \
	and receiver_children_before == 2, "Accepted exact-run pale field was not immutable and module-free before the detached overlay."):
		_finish(main)
		return
	var calibration_result := CALIBRATION_HELPER.build(record, registry)
	if not _require(bool(calibration_result.get("ok", false)), str(calibration_result.get("message", "Detached calibration build failed."))):
		_finish(main)
		return
	var calibration := calibration_result.node as Node3D
	main.add_child(calibration)
	if not _require(calibration.get_parent() == main and not calibration.is_ancestor_of(receiver) and receiver.get_child_count() == receiver_children_before, "Calibration overlay attached to or changed the live receiver."):
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
	camera.name = "W34313515BayCalibrationEvidenceCamera"
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
	var captures: Array[Dictionary] = []
	for pose_value: Variant in _poses(record, resolved_by_id):
		var pose := pose_value as Dictionary
		detail.text = "W34313515 DETACHED BAY CALIBRATION · COMPLETE MODULE-ATLAS MOTIF\n4 EXEMPLARS · 2 WSW + 2 NNW · COORDINATES/COUNT STYLIZED REFERENCE-DERIVED INFERENCE\n%s · CADENCE UNKNOWN · ZERO LIVE ATTACHMENT · ENE/SSE + VRECESS EXCLUDED" % str(pose.view_kind).replace("_", " ").to_upper()
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
		"schema_version": "ti.w34313515-bay-calibration-evidence/1",
		"review_status": "ready_for_independent_exact_receiver_module_calibration_review_not_self_accepted",
		"evidence_role": "detached exact-receiver complete BAY module-atlas calibration over the immutable accepted WSW/NNW pale field; not live attachment, surveyed coordinate/count/cadence acceptance, lifecycle change, or whole-building proof",
		"source_key": "w34313515",
		"receiver_key": RECEIVER_KEY,
		"generator": "game/tests/w34313515_module_calibration_capture.gd",
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
		"loaded_world_before_overlay": {"chunks": runtime.chunks_loaded, "meshes": runtime.mesh_instances, "surfaces": runtime.surfaces, "triangles": runtime.triangles, "static_bodies": runtime.static_bodies, "shapes": runtime.shapes},
		"receiver_child_count_before_and_after_overlay": [receiver_children_before, receiver.get_child_count()],
		"accepted_field_metadata": field_metadata,
		"face_chains": registry.face_chains,
		"module_contract": registry.module_contract,
		"placement_policy": registry.placement_policy,
		"placements": registry.placements,
		"resolved_placements": calibration_result.resolved_placements,
		"detached_overlay": {"parent": "main_capture_scene_only", "module_instances": 4, "mesh_instances": 84, "field_meshes": 0, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0, "runtime_attachment": false},
		"excluded_regions": registry.excluded_regions,
		"captures": captures,
		"capture_count": captures.size(),
		"preserved_blockers": registry.preserved_blockers,
		"validity_inspection_only": "Inspect target visibility, complete three-tier motifs, accepted host field continuity, exact transforms, shallow depth, camera diversity, multi-side coverage and evidence labels only. Executor art acceptance is prohibited.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write calibration capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d native Forward+/Metal w34313515 detached BAY calibration views to %s" % [captures.size(), output_absolute])
	_finish(main)


func _poses(record: Dictionary, resolved: Dictionary) -> Array[Dictionary]:
	return [
		_placement_pose(resolved["CAL-WSW-BAY-01"], "01-close-wsw-bay", "close_complete_wsw_bay", 15.0, -1.0, 2.25, Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(resolved["CAL-NNW-BAY-01"], "02-close-nnw-bay", "close_complete_nnw_bay", 15.0, 1.2, 2.25, Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(resolved["CAL-WSW-BAY-02"], "03-ordinary-wsw-context", "ordinary_gameplay_height_wsw_building_context", 55.0, 0.0, 2.25, Vector3(-52.0, -28.0, 0.0)),
		_face_pose(record, [43, 44, 45, 46, 47], 34.0, "04-ordinary-nnw-context", "ordinary_gameplay_height_nnw_building_context", 57.0, 2.25, ["CAL-NNW-BAY-01", "CAL-NNW-BAY-02"], Vector3(-52.0, -28.0, 0.0)),
		_corner_pose(record, 47, 0, "05-wrap-corner-two-side-context", "ordinary_wrap_corner_wsw_nnw_multi_side_context", 46.0, 2.35, ["CAL-NNW-BAY-02", "CAL-WSW-BAY-01"], Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(resolved["CAL-WSW-BAY-02"], "06-changed-light-oblique-wsw-bay", "changed_light_oblique_complete_wsw_bay", 25.0, 10.0, 2.4, Vector3(-24.0, 118.0, 0.0)),
	]


func _placement_pose(resolved: Dictionary, id: String, view_kind: String, distance: float, lateral: float, camera_height_above_base: float, sun: Vector3) -> Dictionary:
	var origin_values := resolved.module_origin_world_m as Array
	var tangent_values := resolved.tangent_world_xz as Array
	var normal_values := resolved.outward_normal_world_xz as Array
	var origin := Vector3(float(origin_values[0]), float(origin_values[1]), float(origin_values[2]))
	var tangent := Vector3(float(tangent_values[0]), 0.0, float(tangent_values[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	var target := origin
	var camera := target + normal * distance + tangent * lateral
	camera.y = float(resolved.base_y_m) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": [str(resolved.placement_id)], "before_run": -1, "after_run": -1}


func _face_pose(record: Dictionary, runs: Array[int], chain_m: float, id: String, view_kind: String, distance: float, camera_height_above_base: float, placement_ids: Array[String], sun: Vector3) -> Dictionary:
	var frame := CALIBRATION_HELPER.chain_frame(record, runs, chain_m)
	var wall_anchor := frame.wall_anchor as Vector3
	var normal := frame.normal as Vector3
	var target := wall_anchor
	target.y = float(frame.base_y) + 5.35
	var camera := target + normal * distance
	camera.y = float(frame.base_y) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": placement_ids, "before_run": -1, "after_run": -1}


func _corner_pose(record: Dictionary, before: int, after: int, id: String, view_kind: String, distance: float, camera_height_above_base: float, placement_ids: Array[String], sun: Vector3) -> Dictionary:
	var frame := CALIBRATION_HELPER.boundary_frame(record, before, after)
	var junction := frame.junction as Vector3
	var outward := frame.outward as Vector3
	var target := junction
	target.y = 8.1
	var camera := junction + outward * distance
	camera.y = float(((frame.before as Dictionary).end as Vector3).y) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": placement_ids, "before_run": before, "after_run": after}


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
	overlay.name = "CalibrationEvidenceOverlay"
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
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(pose.id)}
	var target := pose.target as Vector3
	var metadata := {
		"id": str(pose.id),
		"view_kind": str(pose.view_kind),
		"file": relative,
		"sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_position_m": [camera.position.x, camera.position.y, camera.position.z],
		"aim_target_m": [target.x, target.y, target.z],
		"camera_fov_degrees": camera.fov,
		"sun_rotation_degrees": [(pose.sun as Vector3).x, (pose.sun as Vector3).y, (pose.sun as Vector3).z],
		"placement_ids": pose.placement_ids,
		"before_run": int(pose.before_run),
		"after_run": int(pose.after_run),
		"sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range),
	}
	print("W34313515_BAY_CALIBRATION_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
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
	push_error("W34313515_BAY_CALIBRATION_CAPTURE_FAIL: %s" % message)


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
