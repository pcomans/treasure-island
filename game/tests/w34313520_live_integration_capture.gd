extends SceneTree

const CALIBRATION := preload("res://game/tests/support/w34313520_exact_receiver_calibration.gd")
const LIVE_MODULES := preload("res://game/scripts/world/facades/w34313520_live_modules.gd")
const ACCEPTED_FIELDS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const RECEIVER_KEY := "building:w34313520:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_0.json"
const OUTPUT := "res://evidence/first-playable/w34313520-live-field-and-bay-2026-08-30"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313520_live_integration_capture.gd"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_PROTECTED_HASHES := {
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	CHUNK_PATH: "b935890b89202fa181248552176364668e506a7630f0024ec86f12a084743d86",
	"res://game/resources/facades/w34313520_exact_receiver_calibration.json": "28ea8b6e506d747299a920e4d456d8676031e18ec3b6d9e959cab31fa33de4f1",
	"res://game/tests/support/w34313520_exact_receiver_calibration.gd": "d747d9f9ca5798b09909efeeb930cdee119f1b3c310e95f9a2c426a3ee6ceea4",
	"res://discovery/facades/W34313520_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md": "555eb2fb3a397341cc6ed6412a627b9d84fe8c806de756c2ed4cbd8a3a652870",
	"res://game/resources/facades/w34313520_standalone_prototypes.json": "ab80f0cd0424c22f7f24e5fc82211353e9aee7c95bea4903022681a48c5620a4",
	"res://game/resources/materials/world/w34313520/w34313520_pale_field.tres": "7944151fd5ab8e977e7052d0cdb8df20132c82f967d8ebfefff83ede8fcf07a4",
	"res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres": "89fbb97ed797275a86c394af7eab13f946cbf23f29cba58b89a2b2d467030ab2",
	"res://game/resources/materials/world/w34313520/w34313520_bay_frame.tres": "445d3bec9d2ef3130aab27c816b27e384c689af68298b2db5ada37e0178f249b",
	"res://game/resources/materials/world/w34313520/w34313520_bay_glass.tres": "40caf8b054b51ebf247a41286dec9efdbf925f09acf698a75285a4321a41bba6",
	"res://game/scripts/world/facades/w34313520_standalone_prototypes.gd": "1244f590ed0854219f50a25a4c7931f4f094ce19fb65cefcf2d61b8ce4cd8566",
	"res://game/scenes/world/facades/batch_06/w34313520_standalone_prototype_set.tscn": "4d0ee0e79ea6fd5a7e85b21cdf4a103d125818626b6c97875737cad44cc65785",
	"res://game/scripts/world/facades/w34313520_live_modules.gd": "7675d651d834ac20328c12c9eb543bda1af453730cb3d8d8c8a41e899e63a8d2",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "aaea7d6518fda141a0c488a54a7441a70bc52d5b98cd666876aa665d3b5be80e",
	"res://game/scripts/world/world_chunk_builder.gd": "e54b31cef98b45f00aadcba0b7a6dec0125f147c1c332c06158198dbe19e508d",
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Live w34313520 evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for path: String in EXPECTED_PROTECTED_HASHES:
		if not _require(FileAccess.get_sha256(path) == str(EXPECTED_PROTECTED_HASHES[path]), "Protected w34313520 live input drifted: %s" % path):
			_finish(null)
			return
	var record := _record_data()
	if not _require(not record.is_empty(), "Exact w34313520 generated receiver record did not resolve."):
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for live w34313520 capture."):
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
	if not _require(failures.is_empty() and reports.size() == 1, "Whole island did not reach one clean world_ready for live w34313520 capture.") \
	or not _require(str(reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content identity drifted before live w34313520 capture."):
		_finish(main)
		return
	var evidence := world.get_runtime_evidence()
	if not _require(evidence.chunks_loaded == 38 and evidence.mesh_instances == 886 and evidence.surfaces == 894 and evidence.triangles == 50273, "Live w34313520 loaded render topology drifted.") \
	or not _require(evidence.static_bodies == 466 and evidence.shapes == 466, "Live w34313520 collision topology drifted."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world)
	var receiver_contract := _live_receiver_contract(receiver, record)
	if not _require(bool(receiver_contract.get("ok", false)), str(receiver_contract.get("message", "Live w34313520 receiver contract failed."))):
		_finish(main)
		return
	var live_root := receiver.get_node("W34313520LiveModules") as Node3D
	var resolved := live_root.get_meta("resolved_placement", {}) as Dictionary
	if not _require(str(resolved.get("placement_id", "")) == "CAL-SSE-BAY-01", "Live receiver did not retain the one reviewed BAY transform."):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create live w34313520 evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "W34313520LiveEvidenceCamera"
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
		_chain_pose(record, 25.045, 15.0, "01-field-join-r6-r7", "exact_field_join_6_to_7", [6, 7], original_sun),
		_chain_pose(record, 56.834, 15.0, "02-field-join-r7-r8", "exact_field_join_7_to_8", [7, 8], original_sun),
		_chain_pose(record, 61.328, 14.0, "03-field-join-r8-r9", "exact_field_join_8_to_9", [8, 9], original_sun),
		_chain_pose(record, 65.243, 13.0, "04-field-join-r9-r10", "exact_field_join_9_to_10", [9, 10], original_sun),
		_chain_pose(record, 28.5, 72.0, "05-macro-field-runs6-10", "macro_56m_plus_field_span", [6, 7, 8, 9, 10], original_sun, 10.0),
		_placement_pose(resolved, 10.5, -0.5, 3.0, "06-bay-close", "exact_live_bay_close", original_sun),
		_placement_pose(resolved, 20.0, 7.0, 3.8, "07-bay-oblique", "exact_live_bay_oblique", original_sun),
		_chain_pose(record, 31.0, 48.0, "08-all-runs-ordinary", "ordinary_gameplay_all_exact_sse_runs", [6, 7, 8, 9, 10], original_sun, 4.0),
		_chain_pose(record, 34.0, 100.0, "09-building-sse-context", "building_and_sse_context", [6, 7, 8, 9, 10], original_sun, -18.0, 8.0),
		_placement_pose(resolved, 29.0, -8.0, 4.5, "10-changed-light-field-and-bay", "changed_light_exact_field_and_bay", Vector3(-20.0, 142.0, 0.0)),
		{"id": "11-whole-island", "view_kind": "whole_island_actual_loaded_world", "camera": Vector3(180.0, 1550.0, 300.0), "target": Vector3(-20.0, 0.0, 30.0), "sun": original_sun, "placement_ids": [], "representative_runs": []},
	]
	var captures: Array[Dictionary] = []
	for pose_value: Variant in poses:
		var pose := pose_value as Dictionary
		detail.text = "W34313520 ACTUAL LIVE EXACT-RECEIVER PROOF\nMAT-PALE ONLY SSE RUNS 6..10 · ONE COMPLETE BAY AT RUN 7 MIDPOINT\n%s · STYLIZED/NON-SURVEYED · PENDING INDEPENDENT ACTUAL-WORLD ART REVIEW" % str(pose.view_kind).replace("_", " ").to_upper()
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		var saved := await _save_view(camera, pose)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Live w34313520 capture failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var manifest := {
		"schema_version": "ti.w34313520-live-field-and-bay-evidence/1",
		"review_status": "ready_for_independent_actual_world_art_review_not_self_accepted",
		"evidence_role": "actual loaded-world exact field continuity, macro behavior, exact single-BAY attachment, ordinary/building/changed-light/whole-island visibility and noninterference proof; not surveyed scale/dimensions/coordinates/count/cadence, completed SSE elevation, other-side transfer, whole-building acceptance, or executor art acceptance",
		"source_key": "w34313520", "receiver_key": RECEIVER_KEY,
		"generator": "game/tests/w34313520_live_integration_capture.gd", "capture_command": COMMAND,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"content_sha256": EXPECTED_CONTENT_SHA256, "protected_inputs_capture_time": EXPECTED_PROTECTED_HASHES,
		"generated_source_and_data_bytes_unchanged": true,
		"loaded_world_before_this_integration": {"records": 729, "record_meshes": 729, "record_surfaces": 736, "meshes": 871, "surfaces": 878, "triangles": 50093, "static_bodies": 466, "shapes": 466},
		"live_reported_world": {"chunks": evidence.chunks_loaded, "records": 729, "record_meshes": 729, "record_surfaces": 737, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"exact_runtime_delta": {"record_material_surfaces": 1, "module_nodes": 1, "motif_instances": {"W34313520-BAY": 1}, "mesh_instances": 15, "loaded_surfaces": 16, "triangles": 180, "field_meshes": 0, "backing_meshes": 0, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0},
		"field_scope": {"field_id": "W34313520-MAT-PALE", "asset_kind": "homogeneous_material_tile", "face": "SSE", "region": "observed_long_SSE_outer_elevation", "exact_ordered_runs": [6, 7, 8, 9, 10], "length_m": 68.156, "wall_area_m2": 751.441, "primary_scale_m": 0.95, "secondary_scale_m": 0.29, "maximum_join_phase_delta_m": 0.0, "scale_surveyed": false, "completed_elevation": false},
		"receiver": receiver_contract,
		"field_metadata": receiver.get_meta("accepted_material_run_trial", {}),
		"live_module_metadata": receiver.get_meta("w34313520_live_modules", {}),
		"resolved_placement": resolved,
		"truth_boundary": {"runtime_center_fixed": true, "along_run_center_m": 15.894477, "mechanical_safe_center_domain_m": [4.75, 27.038953], "center_uncertainty_half_span_m": 11.144477, "placement_role": LIVE_MODULES.PLACEMENT_ROLE, "dimensions_surveyed": false, "coordinates_surveyed": false, "scale_surveyed": false, "count_surveyed": false, "cadence_surveyed": false, "cadence_inferred": false, "completed_sse_elevation": false, "whole_building_accepted": false},
		"protected_scope": {"other_runs_and_sides_live": false, "runs_20_21_live": false, "wing_recess_lower_family_endpoints_live": false, "second_bay_live": false, "generated_files_modified": false, "terrain_foundation_massing_modified": false, "collision_navigation_spray_modified": false},
		"captures": captures, "capture_count": captures.size(),
		"field_join_capture_ids": ["01-field-join-r6-r7", "02-field-join-r7-r8", "03-field-join-r8-r9", "04-field-join-r9-r10"],
		"macro_capture_id": "05-macro-field-runs6-10", "changed_light_capture_id": "10-changed-light-field-and-bay", "whole_island_capture_id": "11-whole-island",
		"validity_inspection_only": "Inspect exact join continuity, 56.834 m macro span, BAY completeness/grounding/shallow separation, ordinary gameplay readability, building context and changed-light response only. Executor art acceptance is prohibited.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write live w34313520 capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d actual loaded-world native Forward+/Metal w34313520 proof views to %s" % [captures.size(), output_absolute])
	_finish(main)


func _live_receiver_contract(receiver: Node3D, record: Dictionary) -> Dictionary:
	if receiver == null:
		return {"ok": false, "message": "Exact live w34313520 receiver node did not resolve."}
	var mesh_instance := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := receiver.get_node_or_null("Collision") as StaticBody3D
	var shape_node := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var live_root := receiver.get_node_or_null("W34313520LiveModules") as Node3D
	var field_metadata := receiver.get_meta("accepted_material_run_trial", {}) as Dictionary
	var live_metadata := receiver.get_meta("w34313520_live_modules", {}) as Dictionary
	if mesh == null or body == null or shape == null or live_root == null \
	or receiver.get_child_count() != 3 or mesh.get_surface_count() != 2 \
	or mesh.surface_get_name(0) != ACCEPTED_FIELDS.PLACEHOLDER_SURFACE_NAME \
	or mesh.surface_get_name(1) != "trial_w34313520_pale_runs" \
	or mesh.surface_get_material(1).resource_path != "res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres" \
	or _runs_for_surface(mesh, 1) != [6, 7, 8, 9, 10] \
	or live_root.get_child_count() != 1 or _count_type(live_root, MeshInstance3D) != 15 \
	or _count_surfaces(live_root) != 15 or _count_triangles(live_root) != 180 \
	or _count_type(live_root, CollisionObject3D) != 0 or _count_type(live_root, NavigationRegion3D) != 0 \
	or shape.get_faces().size() != (record.get("indices", []) as Array).size() \
	or str(field_metadata.get("status", "")) != "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending" \
	or str(live_metadata.get("actual_world_review_status", "")) != LIVE_MODULES.ACTUAL_WORLD_REVIEW_STATUS:
		return {"ok": false, "message": "Exact w34313520 field, collision, lifecycle, or live BAY topology drifted."}
	return {
		"ok": true, "child_count": receiver.get_child_count(), "record_surface_count": mesh.get_surface_count(),
		"record_surface_names": [mesh.surface_get_name(0), mesh.surface_get_name(1)], "field_runs": _runs_for_surface(mesh, 1),
		"generated_wall_triangles": int(mesh.get_faces().size() / 3), "collision_triangles": int(shape.get_faces().size() / 3),
		"module_nodes": live_root.get_child_count(), "module_mesh_instances": _count_type(live_root, MeshInstance3D), "module_surfaces": _count_surfaces(live_root), "module_triangles": _count_triangles(live_root),
		"collision_objects": _count_type(receiver, CollisionObject3D), "collision_shapes": _count_type(receiver, CollisionShape3D),
		"wall_collision_remains_authoritative": body.is_in_group("spray_receiver_wall") and body.collision_layer == ((1 << 0) | (1 << 2)),
	}


func _chain_pose(record: Dictionary, chain_m: float, distance: float, id: String, view_kind: String, runs: Array[int], sun: Vector3, lateral: float = 0.0, height: float = 6.0) -> Dictionary:
	var frame := CALIBRATION.chain_frame(record, [6, 7, 8, 9, 10], chain_m)
	var target := frame.wall_anchor as Vector3
	target.y = float(frame.base_y) + 5.5
	var camera := target + (frame.normal as Vector3) * distance + (frame.tangent as Vector3) * lateral
	camera.y = float(frame.base_y) + height
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": ["CAL-SSE-BAY-01"] if runs.has(7) else [], "representative_runs": runs}


func _placement_pose(resolved: Dictionary, distance: float, lateral: float, height: float, id: String, view_kind: String, sun: Vector3) -> Dictionary:
	var origin := _vector3(resolved.module_origin_world_m as Array)
	var tangent_values := resolved.tangent_world_xz as Array
	var normal_values := resolved.outward_normal_world_xz as Array
	var tangent := Vector3(float(tangent_values[0]), 0.0, float(tangent_values[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	var target := origin
	var camera := target + normal * distance + tangent * lateral
	camera.y = float(resolved.base_y_m) + height
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": ["CAL-SSE-BAY-01"], "representative_runs": [7]}


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


func _runs_for_surface(mesh: ArrayMesh, surface_index: int) -> Array[int]:
	var indices := mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array
	var counts := {}
	for vertex_index: int in indices:
		var run_index := vertex_index / 4
		counts[run_index] = int(counts.get(run_index, 0)) + 1
	var result: Array[int] = []
	for run_value: Variant in counts:
		if int(counts[run_value]) != 6:
			return []
		result.append(int(run_value))
	result.sort()
	return result


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
		"id": str(pose.id), "view_kind": str(pose.view_kind), "file": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "aim_target_m": [target.x, target.y, target.z], "camera_fov_degrees": camera.fov,
		"sun_rotation_degrees": [(pose.sun as Vector3).x, (pose.sun as Vector3).y, (pose.sun as Vector3).z], "placement_ids": pose.placement_ids, "representative_runs": pose.representative_runs,
		"sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range),
	}
	print("W34313520_LIVE_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
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
			var arrays := mesh.surface_get_arrays(surface_index)
			count += int((arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
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
	push_error(message)


func _on_timeout() -> void:
	_fail("Live w34313520 native capture timed out after %.0f seconds." % TIMEOUT_SECONDS)
	_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	if main != null and is_instance_valid(main):
		main.queue_free()
	quit(0 if _failure.is_empty() else 1)
