extends SceneTree

const FRAME_HELPER := preload("res://game/tests/support/w34313564_module_calibration.gd")
const LIVE_MODULES := preload("res://game/scripts/world/facades/w34313564_live_modules.gd")
const ACCEPTED_FIELDS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const RECEIVER_KEY := "building:w34313564:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-3.json"
const OUTPUT := "res://evidence/first-playable/w34313564-live-modules-2026-08-30"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313564_live_module_integration_capture.gd"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_GENERATED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_CHUNK_SHA256 := "6dfa4b8f4b91f309b313428829e37cedd13e4067ff94f896a8e2e5ef05002a1d"
const EXPECTED_REGISTRY_SHA256 := "45a47d333c997887cef7d1c97a633d37ae050efda597186430c7af6d52116f0f"
const EXPECTED_REVIEWED_HELPER_SHA256 := "b49b8c20fbbe40f2728c0acadf8d53f0593856091e6df897a613d4f2f8680b71"
const EXPECTED_LIVE_HELPER_SHA256 := "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee"
const EXPECTED_FIELD_HELPER_SHA256 := "545d3d4b42fef07c64a035a65006c533b8549d983e4b28bc510eaada60712c9f"
const EXPECTED_WORLD_BUILDER_SHA256 := "3c9e995aefe4e02fd466e51aa3a762fa53137f69a57091b395a59abda0f27cb9"
const EXPECTED_REVIEW_SHA256 := "a8f1396e2d126c0c38b37edf770df975c4fa95e25e34fb2c7c1e766630fd1591"
const EXPECTED_INVENTORY_SHA256 := "41fd4b1cdc98b31b33801decb02a1303e9d1b6ee48e86214a90e52656f9a8542"
const EXPECTED_PREDECESSOR_MANIFEST_SHA256 := "c664d7e0cae794f9d5be979af89c40a4f65096b29b7f2b14e8032271c2209221"
const EXPECTED_CORRECTION_MANIFEST_SHA256 := "d1fcc1a18dacc10c02cef649424b34e0fca5cbd2e8ec933d486d1e2b9a75885e"

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Live w34313564 module evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	var protected := {
		"res://generated/world/manifest.json": EXPECTED_GENERATED_MANIFEST_SHA256,
		CHUNK_PATH: EXPECTED_CHUNK_SHA256,
		"res://game/resources/facades/w34313564_module_calibration.json": EXPECTED_REGISTRY_SHA256,
		"res://game/tests/support/w34313564_module_calibration.gd": EXPECTED_REVIEWED_HELPER_SHA256,
		"res://game/scripts/world/facades/w34313564_live_modules.gd": EXPECTED_LIVE_HELPER_SHA256,
		"res://game/scripts/world/facades/accepted_material_run_trials.gd": EXPECTED_FIELD_HELPER_SHA256,
		"res://game/scripts/world/world_chunk_builder.gd": EXPECTED_WORLD_BUILDER_SHA256,
		"res://discovery/facades/W34313564_MODULE_CALIBRATION_CORRECTION_ART_REVIEW.md": EXPECTED_REVIEW_SHA256,
		"res://discovery/FACADE_RECEIVER_INVENTORY.json": EXPECTED_INVENTORY_SHA256,
		"res://evidence/first-playable/batch-06-w34313564-module-calibration-2026-08-30/capture-manifest.json": EXPECTED_PREDECESSOR_MANIFEST_SHA256,
		"res://evidence/first-playable/batch-06-w34313564-module-calibration-correction-2026-08-30/capture-manifest.json": EXPECTED_CORRECTION_MANIFEST_SHA256,
		"res://game/resources/materials/world/w34313564/w34313564_frame.tres": "5487fa17415e4022d85b82e3f013ac9a41be1dd07d88354f1caf4b05a9ab5994",
		"res://game/resources/materials/world/w34313564/w34313564_glass.tres": "0f5b2ac833346143e777b81e85079f4502ca5a2692944228a9fbfeff28ddd669",
		"res://game/resources/materials/world/w34313564/w34313564_door.tres": "88babf9bdceb46e8475f6d1acf1853ac451433c91f1264ca70c41d8c19d2aa3d",
		"res://game/resources/materials/world/w34313564/w34313564_tan_exact_trial.tres": "3b895743b247a20641cb7564004d2f890bacfc286feaec9044b334b5e8e170bb",
		"res://game/resources/materials/world/w34313564/w34313564_pale_exact_trial.tres": "c7ec2df12b0dcf41e2b5019fd98155dbe3668d16379070210fe9f97ef032a343",
	}
	for path: String in protected:
		if not _require(FileAccess.get_sha256(path) == str(protected[path]), "Protected live-module input drifted: %s" % path):
			_finish(null)
			return
	var record := _record_data()
	if not _require(not record.is_empty(), "Exact w34313564 generated receiver record did not resolve."):
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for live-module capture."):
		_finish(null)
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 50000:
		await process_frame
	if not _require(failures.is_empty() and reports.size() == 1, "Whole island did not reach one clean world_ready for live-module capture.") \
	or not _require(str(reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content identity drifted before live-module capture."):
		_finish(main)
		return
	var evidence := world.get_runtime_evidence()
	if not _require(evidence.chunks_loaded == 38 and evidence.mesh_instances == 763 and evidence.surfaces == 770 and evidence.triangles == 48797, "Live-module world render topology drifted.") \
	or not _require(evidence.static_bodies == 466 and evidence.shapes == 466, "Live-module world collision topology drifted."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world)
	var receiver_contract := _live_receiver_contract(receiver, record)
	if not _require(bool(receiver_contract.get("ok", false)), str(receiver_contract.get("message", "Live receiver contract failed."))):
		_finish(main)
		return
	var live_root := receiver.get_node("W34313564LiveModules") as Node3D
	var resolved_by_id := {}
	for value: Variant in live_root.get_meta("resolved_placements", []):
		var resolved := value as Dictionary
		resolved_by_id[str(resolved.placement_id)] = resolved
	if not _require(resolved_by_id.size() == 5, "Live receiver did not retain all five reviewed resolved transforms."):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create live-module evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "W34313564LiveModuleEvidenceCamera"
	camera.fov = 50.0
	camera.far = 5000.0
	camera.current = true
	main.add_child(camera)
	var sun := main.get_node("Sun") as DirectionalLight3D
	var original_sun := sun.rotation_degrees
	var overlay := _make_overlay()
	main.add_child(overlay)
	var detail := overlay.get_node("Detail") as Label
	var poses := [
		_placement_pose(resolved_by_id["CAL-SSE-PDOOR-01"], "01-close-sse-pdoor", "close_live_tan_pdoor", 6.0, -0.6, 1.4, 1.25, Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(resolved_by_id["CAL-NNW-HWIN-01"], "02-close-nnw-hwin", "close_live_pale_hwin", 7.0, 0.8, 0.25, 0.0, Vector3(-52.0, -28.0, 0.0)),
		_face_pose(record, [5, 6, 7, 8, 9], 55.0, "03-ordinary-sse-layout", "ordinary_live_sse_pair", 42.0, 0.0, 2.7, Vector3(-52.0, -28.0, 0.0), ["CAL-SSE-PDOOR-01", "CAL-SSE-HWIN-01"]),
		_face_pose(record, [14, 15, 16, 17, 18, 19], 43.0, "04-ordinary-nnw-layout", "ordinary_live_nnw_pair", 36.0, 0.0, 2.8, Vector3(-52.0, -28.0, 0.0), ["CAL-NNW-PDOOR-01", "CAL-NNW-HWIN-01"]),
		_placement_pose(resolved_by_id["CAL-ENE-HWIN-01"], "05-changed-light-oblique-ene-hwin", "changed_light_oblique_live_pale_hwin", 18.0, 10.0, 1.0, 0.0, Vector3(-24.0, 118.0, 0.0)),
		_boundary_pose(record, 13, 14, "06-pale-orientation-corner", "live_pale_ene_to_nnw_corner", 26.0, 6.5, Vector3(-52.0, -28.0, 0.0)),
		_boundary_pose(record, 9, 10, "07-tan-pale-host-boundary", "live_tan_to_pale_host_boundary", 38.0, 6.8, Vector3(-52.0, -28.0, 0.0)),
		{"id": "08-whole-island-load", "view_kind": "whole_island_live_module_load_proof", "camera": Vector3(180.0, 1550.0, 300.0), "target": Vector3(-20.0, 0.0, 30.0), "sun": original_sun, "placement_ids": [], "before_run": -1, "after_run": -1},
	]
	var captures: Array[Dictionary] = []
	for pose_value: Variant in poses:
		var pose := pose_value as Dictionary
		detail.text = "W34313564 ACTUAL LIVE EXACT-RECEIVER MODULE PROOF\n5 FIXED EXEMPLARS · RUNS 7/8/12/16/17 · ±4 M PROVENANCE ONLY\n%s · RENDER-ONLY · NOT ART ACCEPTANCE" % str(pose.view_kind).replace("_", " ").to_upper()
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		var saved := await _save_view(camera, pose)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Live-module capture failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var manifest := {
		"schema_version": "ti.w34313564-live-module-integration-evidence/1",
		"review_status": "ready_for_independent_live_gameplay_art_review_not_self_accepted",
		"evidence_role": "actual loaded-world visibility, attachment, host-boundary, camera-diversity and noninterference proof for exactly five approved stylized/reference-derived production-inference module placements; not lifecycle promotion, surveyed coordinates, cadence, count, or whole-building acceptance",
		"source_key": "w34313564", "receiver_key": RECEIVER_KEY,
		"generator": "game/tests/w34313564_live_module_integration_capture.gd", "capture_command": COMMAND,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"content_sha256": EXPECTED_CONTENT_SHA256, "protected_inputs": protected,
		"generated_world_unchanged": {"records": 729, "meshes": 729, "surfaces": 736, "triangles": 48389, "static_bodies": 466, "shapes": 466},
		"live_reported_world": {"chunks": evidence.chunks_loaded, "records": 729, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"exact_module_delta": {"module_nodes": 5, "motif_instances": {"W34313564-HWIN": 3, "W34313564-PDOOR": 2}, "mesh_instances": 34, "surfaces": 34, "triangles": 408, "field_meshes": 0, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0},
		"receiver": receiver_contract,
		"accepted_field_metadata": receiver.get_meta("accepted_material_run_trial", {}),
		"live_module_metadata": receiver.get_meta("w34313564_live_modules", {}),
		"placements": _live_placement_metadata(live_root),
		"resolved_placements": live_root.get_meta("resolved_placements", []),
		"position_truth_boundary": {"fixed_runtime_centers": true, "uncertainty_m": 4.0, "uncertainty_role": "same-run calibration provenance only; no jitter or surveyed-coordinate claim", "cadence_inferred": false, "total_opening_count_inferred": false, "placement_role": LIVE_MODULES.PLACEMENT_ROLE},
		"protected_scope": {"placeholder_runs_0_4_unchanged": true, "tan_runs_5_9_unchanged": true, "pale_runs_10_19_unchanged": true, "plinth_live": false, "other_module_motifs_live": false, "generated_files_modified": false, "terrain_foundation_massing_modified": false, "collision_navigation_spray_modified": false},
		"captures": captures, "capture_count": captures.size(),
		"validity_inspection_only": "Inspect actual live target visibility, complete motifs, grounding, shallow separation, tangent/up/outward orientation, camera diversity, corners and host transitions only. Executor art acceptance is prohibited.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write live-module capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d actual loaded-world native Forward+/Metal w34313564 live-module proof views to %s" % [captures.size(), output_absolute])
	_finish(main)


func _live_receiver_contract(receiver: Node3D, record: Dictionary) -> Dictionary:
	if receiver == null:
		return {"ok": false, "message": "Exact live receiver node did not resolve."}
	var mesh_instance := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := receiver.get_node_or_null("Collision") as StaticBody3D
	var shape_node := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var live_root := receiver.get_node_or_null("W34313564LiveModules") as Node3D
	if mesh == null or body == null or shape == null or live_root == null \
	or receiver.get_child_count() != 3 or mesh.get_surface_count() != 3 \
	or mesh.surface_get_name(0) != ACCEPTED_FIELDS.PLACEHOLDER_SURFACE_NAME \
	or live_root.get_child_count() != 5 or _count_type(live_root, MeshInstance3D) != 34 \
	or _count_type(live_root, CollisionObject3D) != 0 or _count_type(live_root, NavigationRegion3D) != 0 \
	or shape.get_faces().size() != (record.get("indices", []) as Array).size():
		return {"ok": false, "message": "Exact receiver field, collision, or live module topology drifted."}
	return {
		"ok": true, "child_count": receiver.get_child_count(), "generated_surface_count": mesh.get_surface_count(),
		"generated_surface_names": [mesh.surface_get_name(0), mesh.surface_get_name(1), mesh.surface_get_name(2)],
		"generated_wall_triangles": int(mesh.get_faces().size() / 3), "collision_triangles": int(shape.get_faces().size() / 3),
		"module_nodes": live_root.get_child_count(), "module_mesh_instances": _count_type(live_root, MeshInstance3D),
		"collision_objects": _count_type(receiver, CollisionObject3D), "collision_shapes": _count_type(receiver, CollisionShape3D),
		"wall_collision_remains_authoritative": body.is_in_group("spray_receiver_wall") and body.collision_layer == ((1 << 0) | (1 << 2)),
	}


func _placement_pose(resolved: Dictionary, id: String, view_kind: String, distance: float, lateral: float, camera_y_delta: float, aim_y_delta: float, sun: Vector3) -> Dictionary:
	var origin_values := resolved.module_origin_world_m as Array
	var tangent_values := resolved.tangent_world_xz as Array
	var normal_values := resolved.outward_normal_world_xz as Array
	var origin := Vector3(float(origin_values[0]), float(origin_values[1]), float(origin_values[2]))
	var tangent := Vector3(float(tangent_values[0]), 0.0, float(tangent_values[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	var target := origin + Vector3.UP * aim_y_delta
	var camera := target + normal * distance + tangent * lateral
	camera.y += camera_y_delta
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": [str(resolved.placement_id)], "before_run": -1, "after_run": -1}


func _face_pose(record: Dictionary, runs: Array[int], chain_m: float, id: String, view_kind: String, distance: float, lateral: float, height: float, sun: Vector3, placement_ids: Array) -> Dictionary:
	var frame := FRAME_HELPER.chain_frame(record, runs, chain_m)
	var target := frame.wall_anchor as Vector3
	target.y = float(frame.base_y) + height
	var camera := target + (frame.normal as Vector3) * distance + (frame.tangent as Vector3) * lateral
	camera.y = float(frame.base_y) + minf(height, 2.4)
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": placement_ids, "before_run": -1, "after_run": -1}


func _boundary_pose(record: Dictionary, before: int, after: int, id: String, view_kind: String, distance: float, camera_y: float, sun: Vector3) -> Dictionary:
	var frame := FRAME_HELPER.boundary_frame(record, before, after)
	var junction := frame.junction as Vector3
	var target := junction
	target.y = 6.1
	var camera := junction + (frame.outward as Vector3) * distance
	camera.y = camera_y
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": [], "before_run": before, "after_run": after}


func _live_placement_metadata(live_root: Node3D) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for child: Node in live_root.get_children():
		result.append({
			"placement_id": child.get_meta("placement_id", ""), "motif_id": child.get_meta("motif_id", ""),
			"face": child.get_meta("face", ""), "mapping_id": child.get_meta("mapping_id", ""),
			"anchor_run": child.get_meta("anchor_run", -1), "run_ownership": child.get_meta("run_ownership", []),
			"center_chain_m": child.get_meta("center_chain_m", -1.0), "center_chain_uncertainty_m": child.get_meta("center_chain_uncertainty_m", -1.0),
			"host_material_id": child.get_meta("host_material_id", ""), "placement_role": child.get_meta("placement_role", ""),
			"runtime_attachment": child.get_meta("runtime_attachment", false), "complete_motif": child.get_meta("complete_motif", false),
			"module_owns_field_geometry": child.get_meta("module_owns_field_geometry", true), "mesh_instances": child.get_child_count(),
		})
	return result


func _record_data() -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	for value: Variant in chunk.get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == RECEIVER_KEY:
			return record
	return {}


func _record_node_for_key(world: WorldLoader) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == RECEIVER_KEY and value.get_node_or_null("Mesh") != null:
			return value as Node3D
	return null


func _make_overlay() -> CanvasLayer:
	var overlay := CanvasLayer.new()
	overlay.name = "W34313564LiveModuleEvidenceOverlay"
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
		"sun_rotation_degrees": [(pose.sun as Vector3).x, (pose.sun as Vector3).y, (pose.sun as Vector3).z],
		"placement_ids": pose.placement_ids, "before_run": int(pose.before_run), "after_run": int(pose.after_run),
		"sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range),
	}
	print("W34313564_LIVE_MODULE_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
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


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


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
	push_error("W34313564_LIVE_MODULE_CAPTURE_FAIL: %s" % message)


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
