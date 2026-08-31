extends SceneTree

const CALIBRATION := preload("res://game/tests/support/w34313525_exact_receiver_calibration.gd")
const LIVE_MODULES := preload("res://game/scripts/world/facades/w34313525_live_modules.gd")
const ACCEPTED_FIELDS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const RECEIVER_KEY := "building:w34313525:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_1__z_-1.json"
const OUTPUT := "res://evidence/first-playable/w34313525-live-fields-and-modules-2026-08-30"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313525_live_integration_capture.gd"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_PROTECTED_HASHES := {
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	CHUNK_PATH: "a952756b1c6d8d547669dffb89723c2be81d6c9a4b3afd2ae7f2dc3702a82b0d",
	"res://game/resources/facades/w34313525_exact_receiver_calibration.json": "ba22916618510f610719606c1c18f84b8965bbd76fe74eddc5430745470bbddd",
	"res://game/tests/support/w34313525_exact_receiver_calibration.gd": "a9ff1f94274509cdb39c6208117c59b84ba67598ff8a59a1eb57bf30a4b03532",
	"res://discovery/facades/W34313525_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md": "d19fdae403d11117b13ce1fe04476f0d62edfdd3adbc8238936845e481831de2",
	"res://game/resources/facades/w34313525_standalone_prototypes.json": "86d3634e62f367f24bef98206fe1e6f34124023f0d9672bbd318c45c0a33b170",
	"res://game/scenes/world/facades/batch_06/w34313525_standalone_prototype_set.tscn": "9259ab6f231fee7d3d3ad8bfea0a290a455b1490b291a1d05b7cd64df4965cbe",
	"res://game/scripts/world/facades/w34313525_standalone_prototypes.gd": "a8e432b8cae545532aa976b095e2dc012454dd73648dccf09d55be550ccbcc76",
	"res://game/resources/materials/world/w34313525/w34313525_pale_field.tres": "00ad40bbc932d7b7d4a3ce77d13a3798f25a35e908bd45a1a5f7f38ba4c80eff",
	"res://game/resources/materials/world/w34313525/w34313525_pale_exact_trial.tres": "d8a4500d3f3ec036b5e0b4c4273caf0644abdc3bda626fb831e2989d63559752",
	"res://game/resources/materials/world/w34313525/w34313525_frame.tres": "2298f55a4129757eb69af498236e609384acb1565a2c0654e8200bc79e0ae21e",
	"res://game/resources/materials/world/w34313525/w34313525_rollup_pale.tres": "ded6d1de11ce4e77c71ee384be689257707c522718c9f8fad20fb3d1933fee47",
	"res://game/resources/materials/world/w34313525/w34313525_rollup_gray.tres": "b0beeb8e0cf894e3cafd8f7084e0d235074b67daf29c2a863f514d5386173b8a",
	"res://game/resources/materials/world/w34313525/w34313525_personnel.tres": "bcc6295ffe9229f6b7105c13896f0ff0cfcd5d3227e3b30046d9957c2272a88f",
	"res://game/resources/materials/world/w34313525/w34313525_high_group.tres": "68f56c35a7e2ef870dd395e5f2e38b8cc5d640b532de32339ae4b22ffbabadfb",
	"res://game/scripts/world/facades/w34313525_live_modules.gd": "f9b31302eaf98fd4185aed4f28d3651794e2e50958ad2641c04aec0dd45f05e1",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://game/scripts/world/world_chunk_builder.gd": "dec0811b3b6b4947c16f8f69a6a6e60d706b6d7b43a93051ea7be71ad2c203a3",
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Live w34313525 evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for path: String in EXPECTED_PROTECTED_HASHES:
		if not _require(FileAccess.get_sha256(path) == str(EXPECTED_PROTECTED_HASHES[path]), "Protected live input drifted: %s" % path):
			_finish(null)
			return
	var record := _record_data()
	if not _require(not record.is_empty(), "Exact w34313525 generated receiver record did not resolve."):
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for live w34313525 capture."):
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
	if not _require(failures.is_empty() and reports.size() == 1, "Whole island did not reach one clean world_ready for capture.") \
	or not _require(str(reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content identity drifted before capture."):
		_finish(main)
		return
	var evidence := world.get_runtime_evidence()
	if not _require(evidence.chunks_loaded == 38 and evidence.mesh_instances == 924 and evidence.surfaces == 934 and evidence.triangles == 50729, "Loaded render topology drifted.") \
	or not _require(evidence.static_bodies == 466 and evidence.shapes == 466, "Collision topology drifted."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world)
	var receiver_contract := _live_receiver_contract(receiver, record)
	if not _require(bool(receiver_contract.get("ok", false)), str(receiver_contract.get("message", "Live receiver contract failed."))):
		_finish(main)
		return
	var live_root := receiver.get_node("W34313525LiveModules") as Node3D
	var resolved := live_root.get_meta("resolved_placements", []) as Array
	if not _require(resolved.size() == 4, "Live receiver did not retain exactly four reviewed transforms."):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "W34313525LiveEvidenceCamera"
	camera.fov = 50.0
	camera.far = 5000.0
	camera.current = true
	main.add_child(camera)
	var sun := main.get_node("Sun") as DirectionalLight3D
	var original_sun := sun.rotation_degrees
	var overlay := _make_overlay()
	main.add_child(overlay)
	var detail := overlay.get_node("Detail") as Label
	var captures: Array[Dictionary] = []
	for pose_value: Variant in _poses(record, resolved, original_sun):
		var pose := pose_value as Dictionary
		detail.text = "W34313525 ACTUAL LIVE EXACT-RECEIVER PROOF\nMAT-PALE SSE 8..12 + NNW 26..27 · EXACTLY FOUR COMPLETE TYPE EXEMPLARS\n%s · STYLIZED/NON-SURVEYED · PENDING INDEPENDENT ACTUAL-WORLD ART REVIEW" % str(pose.view_kind).replace("_", " ").to_upper()
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		var saved := await _save_view(camera, pose)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Live capture failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var manifest := {
		"schema_version": "ti.w34313525-live-fields-and-modules-evidence/1",
		"review_status": "ready_for_independent_actual_world_art_review_not_self_accepted",
		"evidence_role": "actual loaded-world exact two-scope MAT-PALE continuity/macro behavior and four exact complete module-atlas placements; not surveyed scale/dimensions/coordinates/count/cadence/sequence, maximum uncertainty-envelope containment, completed SSE/NNW elevations, cross-side transfer, whole-building acceptance, or executor art acceptance",
		"source_key": "w34313525", "receiver_key": RECEIVER_KEY,
		"generator": "game/tests/w34313525_live_integration_capture.gd", "capture_command": COMMAND,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"content_sha256": EXPECTED_CONTENT_SHA256, "protected_inputs_capture_time": EXPECTED_PROTECTED_HASHES,
		"generated_source_and_data_bytes_unchanged": true,
		"loaded_world_before_this_integration": {"records": 729, "record_meshes": 729, "record_surfaces": 737, "meshes": 886, "surfaces": 894, "triangles": 50273, "static_bodies": 466, "shapes": 466},
		"live_reported_world": {"chunks": evidence.chunks_loaded, "records": 729, "record_meshes": 729, "record_surfaces": 739, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"exact_runtime_delta": {"field_scopes": 2, "field_runs": 7, "record_material_surfaces": 2, "module_nodes": 4, "mesh_instances": 38, "loaded_surfaces": 40, "triangles": 456, "field_meshes": 0, "backing_meshes": 0, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0},
		"field_scopes": [
			{"scope_id": "CAL-FIELD-SSE-PALE-01", "field_id": "W34313525-MAT-PALE", "face": "SSE", "exact_ordered_runs": [8, 9, 10, 11, 12], "length_m": 75.310910, "wall_area_m2": 377.392952, "primary_scale_m": 0.88, "secondary_scale_m": 0.31, "maximum_join_phase_delta_m": 0.0, "scale_surveyed": false, "completed_elevation": false},
			{"scope_id": "CAL-FIELD-NNW-PALE-01", "field_id": "W34313525-MAT-PALE", "face": "NNW", "exact_ordered_runs": [26, 27], "length_m": 15.936560, "wall_area_m2": 80.510358, "primary_scale_m": 0.88, "secondary_scale_m": 0.31, "maximum_join_phase_delta_m": 0.0, "scale_surveyed": false, "completed_elevation": false},
		],
		"receiver": receiver_contract,
		"field_metadata": receiver.get_meta("accepted_material_run_trial", {}),
		"live_module_metadata": receiver.get_meta("w34313525_live_modules", {}),
		"resolved_placements": resolved,
		"truth_boundary": {"placement_role": LIVE_MODULES.PLACEMENT_ROLE, "dimensions_surveyed": false, "coordinates_surveyed": false, "scale_surveyed": false, "count_surveyed": false, "cadence_surveyed": false, "cadence_inferred": false, "sequence_inferred": false, "maximum_uncertainty_envelope_contained_for_all_modules": false, "completed_sse_elevation": false, "completed_nnw_elevation": false, "cross_side_transfer_accepted": false, "whole_building_accepted": false, "high_group_semantic_face_status": "window_or_grille_not_disambiguated_opaque_proxy_only"},
		"captures": captures, "capture_count": captures.size(),
		"field_join_capture_ids": ["01-sse-field-join-08-09", "02-sse-field-join-09-10", "03-sse-field-join-10-11", "04-sse-field-join-11-12", "05-nnw-field-join-26-27"],
		"ordinary_macro_capture_ids": ["10-ordinary-sse-macro", "11-ordinary-nnw-full-scope"],
		"changed_light_capture_ids": ["13-changed-light-sse", "14-changed-light-nnw"],
		"whole_island_capture_id": "15-whole-island",
		"validity_inspection_only": "Inspect five exact joins, both bounded field spans, every complete motif, ordinary side/building context, changed-light response, opaque HIGH-GROUP ambiguity and whole-island noninterference only. Executor art acceptance is prohibited.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d actual loaded-world native Forward+/Metal w34313525 proof views to %s" % [captures.size(), output_absolute])
	_finish(main)


func _poses(record: Dictionary, resolved: Array, original_sun: Vector3) -> Array[Dictionary]:
	var by_id := {}
	for value: Variant in resolved:
		var item := value as Dictionary
		by_id[str(item.get("placement_id", ""))] = item
	return [
		_boundary_pose(record, 8, 9, "01-sse-field-join-08-09", "exact_live_SSE_field_join_8_to_9", 15.0, 4.5, original_sun),
		_boundary_pose(record, 9, 10, "02-sse-field-join-09-10", "exact_live_SSE_field_join_9_to_10", 15.0, 4.5, original_sun),
		_boundary_pose(record, 10, 11, "03-sse-field-join-10-11", "exact_live_SSE_field_join_10_to_11", 14.0, 4.5, original_sun),
		_boundary_pose(record, 11, 12, "04-sse-field-join-11-12", "exact_live_SSE_field_join_11_to_12", 11.0, 4.5, original_sun),
		_boundary_pose(record, 26, 27, "05-nnw-field-join-26-27", "exact_live_NNW_field_join_26_to_27", 13.0, 4.5, original_sun),
		_placement_pose(by_id["CAL-SSE-ROLLUP-PALE-01"] as Dictionary, "06-close-rollup-pale", "exact_live_complete_ROLLUP_PALE", 12.0, 2.0, 3.6, original_sun),
		_placement_pose(by_id["CAL-SSE-ROLLUP-GRAY-01"] as Dictionary, "07-close-rollup-gray", "exact_live_complete_ROLLUP_GRAY", 12.0, -2.0, 3.6, original_sun),
		_placement_pose(by_id["CAL-NNW-PERSONNEL-01"] as Dictionary, "08-close-personnel", "exact_live_complete_PERSONNEL", 9.0, 1.4, 2.8, original_sun),
		_placement_pose(by_id["CAL-NNW-HIGH-GROUP-01"] as Dictionary, "09-close-high-group", "exact_live_complete_opaque_HIGH_GROUP", 10.0, -1.2, 4.2, original_sun),
		_face_pose(record, [8, 9, 10, 11, 12], 37.5, "10-ordinary-sse-macro", "ordinary_gameplay_SSE_modules_and_30m_plus_field", 26.0, 3.9, [8, 9, 10, 11, 12], ["CAL-SSE-ROLLUP-PALE-01", "CAL-SSE-ROLLUP-GRAY-01"], original_sun),
		_face_pose(record, [26, 27], 8.0, "11-ordinary-nnw-full-scope", "ordinary_gameplay_NNW_modules_and_full_field_scope", 27.0, 4.0, [26, 27], ["CAL-NNW-PERSONNEL-01", "CAL-NNW-HIGH-GROUP-01"], original_sun),
		{"id": "12-building-multiside-context", "view_kind": "building_context_with_both_bounded_sides", "camera": Vector3(365.0, 86.0, -38.0), "target": Vector3(318.0, 5.5, -99.0), "sun": original_sun, "placement_ids": ["CAL-SSE-ROLLUP-PALE-01", "CAL-SSE-ROLLUP-GRAY-01", "CAL-NNW-PERSONNEL-01", "CAL-NNW-HIGH-GROUP-01"], "representative_runs": [8, 9, 10, 11, 12, 26, 27]},
		_face_pose(record, [8, 9, 10, 11, 12], 37.5, "13-changed-light-sse", "changed_light_SSE_field_and_both_rollups", 26.0, 4.8, [8, 9, 10, 11, 12], ["CAL-SSE-ROLLUP-PALE-01", "CAL-SSE-ROLLUP-GRAY-01"], Vector3(-18.0, 118.0, 0.0)),
		_face_pose(record, [26, 27], 8.0, "14-changed-light-nnw", "changed_light_NNW_field_PERSONNEL_and_opaque_HIGH_GROUP", 23.0, 5.2, [26, 27], ["CAL-NNW-PERSONNEL-01", "CAL-NNW-HIGH-GROUP-01"], Vector3(-18.0, 118.0, 0.0), 2.0),
		{"id": "15-whole-island", "view_kind": "whole_island_actual_loaded_world", "camera": Vector3(180.0, 1550.0, 300.0), "target": Vector3(-20.0, 0.0, 30.0), "sun": original_sun, "placement_ids": [], "representative_runs": []},
	]


func _live_receiver_contract(receiver: Node3D, record: Dictionary) -> Dictionary:
	if receiver == null:
		return {"ok": false, "message": "Exact live receiver node did not resolve."}
	var mesh_instance := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := receiver.get_node_or_null("Collision") as StaticBody3D
	var shape_node := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var live_root := receiver.get_node_or_null("W34313525LiveModules") as Node3D
	var field_metadata := receiver.get_meta("accepted_material_run_trial", {}) as Dictionary
	var live_metadata := receiver.get_meta("w34313525_live_modules", {}) as Dictionary
	if mesh == null or body == null or shape == null or live_root == null \
	or receiver.get_child_count() != 3 or mesh.get_surface_count() != 3 \
	or mesh.surface_get_name(0) != ACCEPTED_FIELDS.PLACEHOLDER_SURFACE_NAME \
	or mesh.surface_get_name(1) != "trial_w34313525_pale_sse_runs" \
	or mesh.surface_get_name(2) != "trial_w34313525_pale_nnw_runs" \
	or _runs_for_surface(mesh, 1) != [8, 9, 10, 11, 12] \
	or _runs_for_surface(mesh, 2) != [26, 27] \
	or live_root.get_child_count() != 4 or _count_type(live_root, MeshInstance3D) != 38 \
	or _count_surfaces(live_root) != 38 or _count_triangles(live_root) != 456 \
	or _count_type(live_root, CollisionObject3D) != 0 or _count_type(live_root, NavigationRegion3D) != 0 \
	or shape.get_faces().size() != (record.get("indices", []) as Array).size() \
	or str(field_metadata.get("status", "")) != "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending" \
	or str(live_metadata.get("actual_world_review_status", "")) != LIVE_MODULES.ACTUAL_WORLD_REVIEW_STATUS:
		return {"ok": false, "message": "Exact field, collision, lifecycle, or four-module topology drifted."}
	return {
		"ok": true, "child_count": receiver.get_child_count(), "record_surface_count": mesh.get_surface_count(),
		"record_surface_names": [mesh.surface_get_name(0), mesh.surface_get_name(1), mesh.surface_get_name(2)],
		"sse_field_runs": _runs_for_surface(mesh, 1), "nnw_field_runs": _runs_for_surface(mesh, 2),
		"generated_wall_triangles": int(mesh.get_faces().size() / 3), "collision_triangles": int(shape.get_faces().size() / 3),
		"module_nodes": live_root.get_child_count(), "module_mesh_instances": _count_type(live_root, MeshInstance3D), "module_surfaces": _count_surfaces(live_root), "module_triangles": _count_triangles(live_root),
		"wall_collision_remains_authoritative": body.is_in_group("spray_receiver_wall") and body.collision_layer == ((1 << 0) | (1 << 2)),
	}


func _placement_pose(resolved: Dictionary, id: String, view_kind: String, distance: float, lateral: float, camera_height_above_base: float, sun: Vector3) -> Dictionary:
	var origin := _vector3(resolved.module_origin_world_m as Array)
	var tangent_values := resolved.tangent_world_xz as Array
	var normal_values := resolved.outward_normal_world_xz as Array
	var tangent := Vector3(float(tangent_values[0]), 0.0, float(tangent_values[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	var camera := origin + normal * distance + tangent * lateral
	camera.y = float(resolved.base_y_m) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": origin, "sun": sun, "placement_ids": [str(resolved.placement_id)], "representative_runs": [int(resolved.anchor_run)]}


func _face_pose(record: Dictionary, runs: Array[int], chain_m: float, id: String, view_kind: String, distance: float, camera_height_above_base: float, representative_runs: Array[int], placement_ids: Array[String], sun: Vector3, lateral: float = 0.0) -> Dictionary:
	var frame := CALIBRATION.chain_frame(record, runs, chain_m)
	var wall_anchor := frame.wall_anchor as Vector3
	var target := wall_anchor
	target.y = float(frame.base_y) + 2.6
	var camera := target + (frame.normal as Vector3) * distance + (frame.tangent as Vector3) * lateral
	camera.y = float(frame.base_y) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": placement_ids, "representative_runs": representative_runs}


func _boundary_pose(record: Dictionary, before_run: int, after_run: int, id: String, view_kind: String, distance: float, camera_height_above_base: float, sun: Vector3) -> Dictionary:
	var boundary := CALIBRATION.boundary_frame(record, before_run, after_run)
	var junction := boundary.junction as Vector3
	var target := junction
	target.y = 6.2
	var camera := target + (boundary.normal as Vector3) * distance
	camera.y = junction.y + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": [], "representative_runs": [before_run, after_run]}


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
	var stats := _luminance_stats(image)
	if float(stats.range) < 0.1:
		return {"ok": false, "message": "%s did not contain enough luminance variation." % str(pose.id)}
	var file_name := "images/%s.png" % str(pose.id)
	var path := OUTPUT.path_join(file_name)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(pose.id)}
	return {"ok": true, "metadata": {"id": str(pose.id), "view_kind": str(pose.view_kind), "file": file_name, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y], "sampled_luminance": stats, "camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "target_position_m": [(pose.target as Vector3).x, (pose.target as Vector3).y, (pose.target as Vector3).z], "sun_rotation_degrees": [(pose.sun as Vector3).x, (pose.sun as Vector3).y, (pose.sun as Vector3).z], "placement_ids": pose.placement_ids, "representative_runs": pose.representative_runs}}


func _luminance_stats(image: Image) -> Dictionary:
	var minimum := 1.0
	var maximum := 0.0
	var total := 0.0
	var sample_count := 0
	for y in range(0, image.get_height(), 18):
		for x in range(0, image.get_width(), 18):
			var luminance := image.get_pixel(x, y).get_luminance()
			minimum = minf(minimum, luminance)
			maximum = maxf(maximum, luminance)
			total += luminance
			sample_count += 1
	return {"minimum": snappedf(minimum, 0.000001), "maximum": snappedf(maximum, 0.000001), "range": snappedf(maximum - minimum, 0.000001), "mean": snappedf(total / float(sample_count), 0.000001), "sample_count": sample_count}


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _count_surfaces(node: Node) -> int:
	var count := (node as MeshInstance3D).mesh.get_surface_count() if node is MeshInstance3D and (node as MeshInstance3D).mesh != null else 0
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


func _vector3(values: Array) -> Vector3:
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ") + "\n")
	file.close()
	return true


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_fail(message)
	return condition


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error(message)


func _on_timeout() -> void:
	if not _finished:
		_fail("Timed out while capturing live w34313525 evidence.")
		_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	if main != null:
		main.queue_free()
	quit(1 if not _failure.is_empty() else 0)
