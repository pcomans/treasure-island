extends SceneTree

const FRAME_HELPER := preload("res://game/tests/support/w34313515_module_calibration.gd")
const LIVE_MODULES := preload("res://game/scripts/world/facades/w34313515_live_modules.gd")
const ACCEPTED_FIELDS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const RECEIVER_KEY := "building:w34313515:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_1.json"
const OUTPUT := "res://evidence/first-playable/w34313515-live-modules-2026-08-30"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313515_live_module_integration_capture.gd"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_PROTECTED_HASHES := {
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	CHUNK_PATH: "b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c",
	"res://game/resources/facades/w34313515_module_calibration.json": "2d378a94da4b7badd334d5c00f926a26a4ff9109782abb18e4859301df4b5c1d",
	"res://game/tests/support/w34313515_module_calibration.gd": "1edfdf4b736a7b1cc2883569a4c09b48814cabf30e3056e9dac86152de22d5f1",
	"res://game/scripts/world/facades/w34313515_live_modules.gd": "4420ad2d0a029f03da7a14fe84084d53edfa2323867a5c660c63f875c2a71ccb",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "2f547040b38a4d46ca900c0bd8fb3a260bfb4a7df6cda9e8578d084f8b065029",
	"res://game/scripts/world/world_chunk_builder.gd": "bd1c9e52e0a36c13092382616dc0ff6e5ce52dfd16e279303491db8c73cfa23f",
	"res://discovery/facades/W34313515_BAY_CALIBRATION_ART_REVIEW.md": "894873141bc589e51bb8ec65e06455461e17a809a18608253db59c7e49e5fedd",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "768ab70a84f3e5e5b0e400a1ce7347ee50e073aa59be5f98cb34f73194e6ae5d",
	"res://evidence/first-playable/batch-06-w34313515-bay-calibration-2026-08-30/capture-manifest.json": "9b9e7e9d21539009cfc401f22017220bf3f2224061b57c0d48819325cab7f09b",
	"res://game/resources/materials/world/w34313515/w34313515_pale_exact_trial.tres": "0b8704ccc352374adc1d6a553ff3d985ae2b70559d92b5171092450783b4395f",
	"res://game/resources/materials/world/w34313515/w34313515_frame.tres": "716afbdf12f55975747b08c615236462d335b62ca0c46730b4cb8439b9691aa5",
	"res://game/resources/materials/world/w34313515/w34313515_glass.tres": "963160407868064dcbb66b56cf477d0901f53a27351cbb23905474b5b613a4cc",
	"res://game/scripts/world/facades/w34313564_live_modules.gd": "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee",
	"res://game/resources/facades/w34313564_module_calibration.json": "45a47d333c997887cef7d1c97a633d37ae050efda597186430c7af6d52116f0f",
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Live w34313515 BAY evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for path: String in EXPECTED_PROTECTED_HASHES:
		if not _require(FileAccess.get_sha256(path) == str(EXPECTED_PROTECTED_HASHES[path]), "Protected live BAY input drifted: %s" % path):
			_finish(null)
			return
	var record := _record_data()
	if not _require(not record.is_empty(), "Exact w34313515 generated receiver record did not resolve."):
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for live BAY capture."):
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
	if not _require(failures.is_empty() and reports.size() == 1, "Whole island did not reach one clean world_ready for live BAY capture.") \
	or not _require(str(reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content identity drifted before live BAY capture."):
		_finish(main)
		return
	var evidence := world.get_runtime_evidence()
	if not _require(evidence.chunks_loaded == 38 and evidence.mesh_instances == 847 and evidence.surfaces == 854 and evidence.triangles == 49805, "Live BAY world render topology drifted.") \
	or not _require(evidence.static_bodies == 466 and evidence.shapes == 466, "Live BAY world collision topology drifted."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world)
	var receiver_contract := _live_receiver_contract(receiver, record)
	if not _require(bool(receiver_contract.get("ok", false)), str(receiver_contract.get("message", "Live BAY receiver contract failed."))):
		_finish(main)
		return
	var live_root := receiver.get_node("W34313515LiveModules") as Node3D
	var resolved_by_id := {}
	for value: Variant in live_root.get_meta("resolved_placements", []):
		var resolved := value as Dictionary
		resolved_by_id[str(resolved.placement_id)] = resolved
	if not _require(resolved_by_id.size() == 4, "Live receiver did not retain all four reviewed BAY transforms."):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create live BAY evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "W34313515LiveBayEvidenceCamera"
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
		_placement_pose(resolved_by_id["CAL-WSW-BAY-01"], "01-close-wsw-bay", "close_actual_live_wsw_bay", 15.0, -1.0, 2.25, original_sun),
		_placement_pose(resolved_by_id["CAL-NNW-BAY-01"], "02-close-nnw-bay", "close_actual_live_nnw_bay", 15.0, 1.2, 2.25, original_sun),
		_placement_pose(resolved_by_id["CAL-WSW-BAY-02"], "03-ordinary-wsw-context", "ordinary_gameplay_actual_live_wsw_context", 55.0, 0.0, 2.25, original_sun),
		_face_pose(record, [43, 44, 45, 46, 47], 34.0, "04-ordinary-nnw-context", "ordinary_gameplay_actual_live_nnw_context", 57.0, 2.25, ["CAL-NNW-BAY-01", "CAL-NNW-BAY-02"], original_sun),
		_corner_pose(record, 47, 0, "05-wrap-corner-two-side-context", "actual_live_wsw_nnw_corner_multi_side_context", 46.0, 2.35, ["CAL-NNW-BAY-02", "CAL-WSW-BAY-01"], original_sun),
		_placement_pose(resolved_by_id["CAL-WSW-BAY-02"], "06-changed-light-oblique-wsw-bay", "changed_light_actual_live_wsw_bay", 25.0, 10.0, 2.4, Vector3(-24.0, 118.0, 0.0)),
		{"id": "07-whole-island-load", "view_kind": "whole_island_actual_live_bay_load_proof", "camera": Vector3(180.0, 1550.0, 300.0), "target": Vector3(-20.0, 0.0, 30.0), "sun": original_sun, "placement_ids": [], "before_run": -1, "after_run": -1},
	]
	var captures: Array[Dictionary] = []
	for pose_value: Variant in poses:
		var pose := pose_value as Dictionary
		detail.text = "W34313515 ACTUAL LIVE EXACT-RECEIVER BAY PROOF\n4 FIXED MODULE-ATLAS EXEMPLARS · WSW RUNS 0/6 + NNW RUNS 44/47\n%s · STYLIZED/NON-SURVEYED · ZERO BACKING/COLLISION/NAV/SPRAY · NOT ART ACCEPTANCE" % str(pose.view_kind).replace("_", " ").to_upper()
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		var saved := await _save_view(camera, pose)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Live BAY capture failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var manifest := {
		"schema_version": "ti.w34313515-live-module-integration-evidence/1",
		"review_status": "ready_for_independent_actual_world_art_review_not_self_accepted",
		"evidence_role": "actual loaded-world visibility, attachment, close/gameplay/multi-side/light diversity and noninterference proof for exactly four independently placement-approved stylized/reference-derived production-inference BAY exemplars; not surveyed coordinates, count, cadence, completed elevation, whole-building acceptance, or executor art acceptance",
		"source_key": "w34313515", "receiver_key": RECEIVER_KEY,
		"generator": "game/tests/w34313515_live_module_integration_capture.gd", "capture_command": COMMAND,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"content_sha256": EXPECTED_CONTENT_SHA256, "protected_inputs": EXPECTED_PROTECTED_HASHES,
		"generated_world_unchanged": {"records": 729, "meshes": 729, "surfaces": 736, "triangles": 48389, "static_bodies": 466, "shapes": 466},
		"loaded_world_before_this_integration": {"records": 729, "meshes": 763, "surfaces": 770, "triangles": 48797, "static_bodies": 466, "shapes": 466},
		"live_reported_world": {"chunks": evidence.chunks_loaded, "records": 729, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"exact_bay_delta": {"module_nodes": 4, "motif_instances": {"W34313515-BAY": 4}, "mesh_instances": 84, "surfaces": 84, "triangles": 1008, "field_meshes": 0, "backing_meshes": 0, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0},
		"receiver": receiver_contract,
		"accepted_field_metadata": receiver.get_meta("accepted_material_run_trial", {}),
		"live_module_metadata": receiver.get_meta("w34313515_live_modules", {}),
		"placements": _live_placement_metadata(live_root),
		"resolved_placements": live_root.get_meta("resolved_placements", []),
		"position_truth_boundary": {"fixed_runtime_centers": true, "uncertainty_by_placement_m": {"CAL-WSW-BAY-01": 1.2, "CAL-WSW-BAY-02": 3.0, "CAL-NNW-BAY-01": 3.0, "CAL-NNW-BAY-02": 3.0}, "uncertainty_role": "declared same-run stylized calibration envelope only; no runtime jitter or surveyed-coordinate claim", "coordinates_surveyed": false, "count_surveyed": false, "cadence_inferred": false, "total_opening_count_inferred": false, "placement_role": LIVE_MODULES.PLACEMENT_ROLE},
		"protected_scope": {"pale_runs_0_8_and_43_47_unchanged": true, "placeholder_runs_9_42_unchanged": true, "bay_elsewhere_live": false, "vrecess_live": false, "generated_files_modified": false, "terrain_foundation_massing_modified": false, "collision_navigation_spray_modified": false, "whole_building_accepted": false},
		"captures": captures, "capture_count": captures.size(),
		"validity_inspection_only": "Inspect actual live target visibility, complete module-atlas motifs, grounding, shallow separation, tangent/up/outward orientation, both facade sides, ordinary gameplay context, changed light, and absence of backing/collision changes only. Executor art acceptance is prohibited.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write live BAY capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d actual loaded-world native Forward+/Metal w34313515 BAY proof views to %s" % [captures.size(), output_absolute])
	_finish(main)


func _live_receiver_contract(receiver: Node3D, record: Dictionary) -> Dictionary:
	if receiver == null:
		return {"ok": false, "message": "Exact live w34313515 receiver node did not resolve."}
	var mesh_instance := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := receiver.get_node_or_null("Collision") as StaticBody3D
	var shape_node := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var live_root := receiver.get_node_or_null("W34313515LiveModules") as Node3D
	if mesh == null or body == null or shape == null or live_root == null \
	or receiver.get_child_count() != 3 or mesh.get_surface_count() != 2 \
	or mesh.surface_get_name(0) != ACCEPTED_FIELDS.PLACEHOLDER_SURFACE_NAME \
	or mesh.surface_get_name(1) != "trial_w34313515_pale_runs" \
	or live_root.get_child_count() != 4 or _count_type(live_root, MeshInstance3D) != 84 \
	or _count_type(live_root, CollisionObject3D) != 0 or _count_type(live_root, NavigationRegion3D) != 0 \
	or shape.get_faces().size() != (record.get("indices", []) as Array).size():
		return {"ok": false, "message": "Exact w34313515 field, collision, or live BAY topology drifted."}
	return {
		"ok": true, "child_count": receiver.get_child_count(), "generated_surface_count": mesh.get_surface_count(),
		"generated_surface_names": [mesh.surface_get_name(0), mesh.surface_get_name(1)],
		"generated_wall_triangles": int(mesh.get_faces().size() / 3), "collision_triangles": int(shape.get_faces().size() / 3),
		"module_nodes": live_root.get_child_count(), "module_mesh_instances": _count_type(live_root, MeshInstance3D),
		"module_surfaces": _count_surfaces(live_root), "module_triangles": _count_triangles(live_root),
		"collision_objects": _count_type(receiver, CollisionObject3D), "collision_shapes": _count_type(receiver, CollisionShape3D),
		"wall_collision_remains_authoritative": body.is_in_group("spray_receiver_wall") and body.collision_layer == ((1 << 0) | (1 << 2)),
	}


func _placement_pose(resolved: Dictionary, id: String, view_kind: String, distance: float, lateral: float, camera_height_above_base: float, sun: Vector3) -> Dictionary:
	var origin_values := resolved.module_origin_world_m as Array
	var tangent_values := resolved.tangent_world_xz as Array
	var normal_values := resolved.outward_normal_world_xz as Array
	var origin := Vector3(float(origin_values[0]), float(origin_values[1]), float(origin_values[2]))
	var tangent := Vector3(float(tangent_values[0]), 0.0, float(tangent_values[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	var camera := origin + normal * distance + tangent * lateral
	camera.y = float(resolved.base_y_m) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": origin, "sun": sun, "placement_ids": [str(resolved.placement_id)], "before_run": -1, "after_run": -1}


func _face_pose(record: Dictionary, runs: Array[int], chain_m: float, id: String, view_kind: String, distance: float, camera_height_above_base: float, placement_ids: Array[String], sun: Vector3) -> Dictionary:
	var frame := FRAME_HELPER.chain_frame(record, runs, chain_m)
	var target := frame.wall_anchor as Vector3
	target.y = float(frame.base_y) + 5.35
	var camera := target + (frame.normal as Vector3) * distance
	camera.y = float(frame.base_y) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": placement_ids, "before_run": -1, "after_run": -1}


func _corner_pose(record: Dictionary, before: int, after: int, id: String, view_kind: String, distance: float, camera_height_above_base: float, placement_ids: Array[String], sun: Vector3) -> Dictionary:
	var frame := FRAME_HELPER.boundary_frame(record, before, after)
	var junction := frame.junction as Vector3
	var target := junction
	target.y = 8.1
	var camera := junction + (frame.outward as Vector3) * distance
	camera.y = float(((frame.before as Dictionary).end as Vector3).y) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": placement_ids, "before_run": before, "after_run": after}


func _live_placement_metadata(live_root: Node3D) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for child: Node in live_root.get_children():
		result.append({
			"placement_id": child.get_meta("placement_id", ""), "motif_id": child.get_meta("motif_id", ""),
			"face": child.get_meta("face", ""), "region": child.get_meta("region", ""), "mapping_id": child.get_meta("mapping_id", ""),
			"exact_ordered_runs": child.get_meta("exact_ordered_runs", []), "anchor_run": child.get_meta("anchor_run", -1), "run_ownership": child.get_meta("run_ownership", []),
			"center_chain_m": child.get_meta("center_chain_m", -1.0), "center_chain_uncertainty_m": child.get_meta("center_chain_uncertainty_m", -1.0),
			"host_material_id": child.get_meta("host_material_id", ""), "placement_role": child.get_meta("placement_role", ""), "evidence_status": child.get_meta("evidence_status", ""),
			"coordinate_status": child.get_meta("coordinate_status", ""), "count_status": child.get_meta("count_status", ""), "cadence_status": child.get_meta("cadence_status", ""),
			"coordinates_surveyed": child.get_meta("coordinates_surveyed", true), "count_surveyed": child.get_meta("count_surveyed", true), "cadence_inferred": child.get_meta("cadence_inferred", true),
			"runtime_attachment": child.get_meta("runtime_attachment", false), "complete_motif": child.get_meta("complete_motif", false), "module_not_seamless_tile": child.get_meta("module_not_seamless_tile", false),
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
		"id": str(pose.id), "view_kind": str(pose.view_kind), "file": relative, "sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "aim_target_m": [target.x, target.y, target.z],
		"camera_fov_degrees": camera.fov, "sun_rotation_degrees": [(pose.sun as Vector3).x, (pose.sun as Vector3).y, (pose.sun as Vector3).z],
		"placement_ids": pose.placement_ids, "before_run": int(pose.before_run), "after_run": int(pose.after_run),
		"sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range),
	}
	print("W34313515_LIVE_BAY_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
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


func _count_surfaces(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		count = (node as MeshInstance3D).mesh.get_surface_count()
	for child: Node in node.get_children():
		count += _count_surfaces(child)
	return count


func _count_triangles(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mesh := (node as MeshInstance3D).mesh
		for surface_index in mesh.get_surface_count():
			count += int((mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
	for child: Node in node.get_children():
		count += _count_triangles(child)
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
	push_error("W34313515_LIVE_BAY_CAPTURE_FAIL: %s" % message)


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
