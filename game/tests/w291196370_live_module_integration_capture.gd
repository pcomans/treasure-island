extends SceneTree

const FRAME_HELPER := preload("res://game/tests/support/w291196370_module_calibration.gd")
const LIVE_MODULES := preload("res://game/scripts/world/facades/w291196370_live_modules.gd")
const ACCEPTED_FIELDS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const RECEIVER_KEY := "building:w291196370:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-3.json"
const OUTPUT := "res://evidence/first-playable/w291196370-live-modules-2026-08-30"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w291196370_live_module_integration_capture.gd"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_PROTECTED_HASHES := {
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	CHUNK_PATH: "6dfa4b8f4b91f309b313428829e37cedd13e4067ff94f896a8e2e5ef05002a1d",
	"res://game/resources/facades/w291196370_module_calibration.json": "b30a8f19091288cde4b8e891ec40287ab28a73776588f96ee86fc5565cfc25b8",
	"res://game/tests/support/w291196370_module_calibration.gd": "ba621cffc5ee155e8b7c7338c3b5d444d1180dad6dbe11528219ada6de05dfdf",
	"res://game/scripts/world/facades/w291196370_live_modules.gd": "e297d40ac9841485ee00a76b955f8ec454639b394c23759e8017e170aa84cbf8",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "4741097b177f02074c6b254e03f955dce46703dfef89b0a4cbc0a8b424f7ae6f",
	"res://game/scripts/world/world_chunk_builder.gd": "84aaf060b6282e956bbae81e4880ac8e203e107760d627c48f7d9e5abb72183e",
	"res://discovery/facades/W291196370_MODULE_CALIBRATION_ART_REVIEW.md": "967ab07d109096a743be01fb0bce959280967f5eab65c82ac0652eb5dcd3023b",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "c9ed0671a82e58da47394654175269a4f7adc9ae13cdb840532c29b0c9d70d85",
	"res://discovery/FACADE_RECEIVER_INVENTORY.md": "71d8e2e77ad5de2192663aa3fe6d9b9d4b5873fd2981d9f0fda575a1ad12ffcc",
	"res://evidence/first-playable/batch-06-w291196370-module-calibration-2026-08-30/capture-manifest.json": "5a92402a7a6742c5c67fa18e904c1af5055c9aaacf6e3001ebb20fb26e738df0",
	"res://game/resources/materials/world/w291196370/w291196370_siding_exact_trial.tres": "715cf02b3c006c1a492ad61def9b2535fbaf04a3b1a41c69c5f092d705fab677",
	"res://game/resources/materials/world/w291196370/w291196370_trim.tres": "0223453497849cddb947701aaf6c83044d3bfd1e610dbc2eea49ed79cb5b56ad",
	"res://game/resources/materials/world/w291196370/w291196370_glass.tres": "bb2727b8bfe6e8228cfe938345fd38950055f13a2c3ee27a7fd0daafaa5ba6ff",
	"res://game/resources/materials/world/w291196370/w291196370_entry.tres": "da23ac9280107f5cd3ca3f73bfe6e236149634a27213d5a8ac453781a4b7248f",
	"res://game/resources/materials/world/w291196370/w291196370_service.tres": "ec7973f9b7849a7ae36c2027bed9fa3c019405cedc4c254f8a104391923981a2",
	"res://game/scripts/world/facades/w34313564_live_modules.gd": "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee",
	"res://game/scripts/world/facades/w34313515_live_modules.gd": "4420ad2d0a029f03da7a14fe84084d53edfa2323867a5c660c63f875c2a71ccb",
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Live w291196370 module evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for path: String in EXPECTED_PROTECTED_HASHES:
		if not _require(FileAccess.get_sha256(path) == str(EXPECTED_PROTECTED_HASHES[path]), "Protected live module input drifted: %s" % path):
			_finish(null)
			return
	var record := _record_data()
	if not _require(not record.is_empty(), "Exact w291196370 generated receiver record did not resolve."):
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for live w291196370 capture."):
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
	if not _require(failures.is_empty() and reports.size() == 1, "Whole island did not reach one clean world_ready for live w291196370 capture.") \
	or not _require(str(reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content identity drifted before live w291196370 capture."):
		_finish(main)
		return
	var evidence := world.get_runtime_evidence()
	if not _require(evidence.chunks_loaded == 38 and evidence.mesh_instances == 871 and evidence.surfaces == 878 and evidence.triangles == 50093, "Live w291196370 world render topology drifted.") \
	or not _require(evidence.static_bodies == 466 and evidence.shapes == 466, "Live w291196370 world collision topology drifted."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world)
	var receiver_contract := _live_receiver_contract(receiver, record)
	if not _require(bool(receiver_contract.get("ok", false)), str(receiver_contract.get("message", "Live w291196370 receiver contract failed."))):
		_finish(main)
		return
	var live_root := receiver.get_node("W291196370LiveModules") as Node3D
	var resolved_by_id := {}
	for value: Variant in live_root.get_meta("resolved_placements", []):
		var resolved := value as Dictionary
		resolved_by_id[str(resolved.placement_id)] = resolved
	if not _require(resolved_by_id.size() == 3, "Live receiver did not retain all three reviewed transforms."):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create live w291196370 evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "W291196370LiveModuleEvidenceCamera"
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
		_placement_pose(resolved_by_id["CAL-SSE-WINSTACK-01"], "01-close-sse-winstack", "close_actual_live_winstack_run8", 11.0, -0.8, 2.5, original_sun),
		_placement_pose(resolved_by_id["CAL-SSE-ENTRY-01"], "02-close-sse-entry", "close_actual_live_entry_run10", 10.0, 0.7, 1.9, original_sun),
		_placement_pose(resolved_by_id["CAL-ENE-SERVICE-01"], "03-close-ene-service", "close_actual_live_service_run20", 12.5, -0.5, 2.1, original_sun),
		_face_pose(record, [8, 9, 10], 21.5, "04-ordinary-sse-public-context", "ordinary_gameplay_actual_live_sse", 42.0, 2.3, ["CAL-SSE-WINSTACK-01", "CAL-SSE-ENTRY-01"], original_sun),
		_face_pose(record, [17, 18, 19, 20, 21, 22], 36.0, "05-ordinary-ene-outer-context", "ordinary_gameplay_actual_live_ene", 39.0, 2.4, ["CAL-ENE-SERVICE-01"], original_sun),
		_dual_side_pose(resolved_by_id, "06-sse-ene-multi-side-context", "actual_live_supported_sse_ene_multi_side_context", 67.0, 3.2, ["CAL-SSE-WINSTACK-01", "CAL-SSE-ENTRY-01", "CAL-ENE-SERVICE-01"], original_sun),
		_face_pose(record, [8, 9, 10], 21.5, "07-changed-light-oblique-sse", "changed_light_actual_live_sse_pair", 30.0, 2.8, ["CAL-SSE-WINSTACK-01", "CAL-SSE-ENTRY-01"], Vector3(-22.0, 118.0, 0.0), 8.0),
		_placement_pose(resolved_by_id["CAL-ENE-SERVICE-01"], "08-changed-light-exact-ene-service-run20", "changed_light_exact_actual_live_ene_service_run20", 18.0, 5.0, 2.7, Vector3(-20.0, 142.0, 0.0)),
		{"id": "09-whole-island-load", "view_kind": "whole_island_actual_live_three_motif_load_proof", "camera": Vector3(180.0, 1550.0, 300.0), "target": Vector3(-20.0, 0.0, 30.0), "sun": original_sun, "placement_ids": [], "representative_runs": []},
	]
	var captures: Array[Dictionary] = []
	for pose_value: Variant in poses:
		var pose := pose_value as Dictionary
		detail.text = "W291196370 ACTUAL LIVE EXACT-RECEIVER MODULE PROOF\n3 FIXED COMPLETE MODULE-ATLAS EXEMPLARS · SSE RUNS 8/10 + ENE RUN 20\n%s · STYLIZED/NON-SURVEYED · ZERO BACKING/COLLISION/NAV/SPRAY · PENDING ART REVIEW" % str(pose.view_kind).replace("_", " ").to_upper()
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		var saved := await _save_view(camera, pose)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Live w291196370 capture failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var manifest := {
		"schema_version": "ti.w291196370-live-module-integration-evidence/1",
		"review_status": "ready_for_independent_actual_world_art_review_not_self_accepted",
		"evidence_role": "actual loaded-world visibility, exact attachment, close/gameplay/multi-side/light diversity and noninterference proof for exactly three independently detached-placement-reviewed stylized/reference-derived production-inference complete module-atlas exemplars; not surveyed scale/coordinates/count/cadence, completed elevation, cross-side transfer, whole-building acceptance, or executor art acceptance",
		"source_key": "w291196370", "receiver_key": RECEIVER_KEY,
		"generator": "game/tests/w291196370_live_module_integration_capture.gd", "capture_command": COMMAND,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"content_sha256": EXPECTED_CONTENT_SHA256, "protected_inputs_capture_time": EXPECTED_PROTECTED_HASHES,
		"generated_world_unchanged": {"records": 729, "meshes": 729, "surfaces": 736, "triangles": 48389, "static_bodies": 466, "shapes": 466},
		"loaded_world_before_this_integration": {"records": 729, "meshes": 847, "surfaces": 854, "triangles": 49805, "static_bodies": 466, "shapes": 466},
		"live_reported_world": {"chunks": evidence.chunks_loaded, "records": 729, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"exact_module_delta": {"module_nodes": 3, "motif_instances": {"W291196370-WINSTACK": 1, "W291196370-ENTRY": 1, "W291196370-SERVICE": 1}, "mesh_instances": 24, "surfaces": 24, "triangles": 288, "field_meshes": 0, "backing_meshes": 0, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0},
		"receiver": receiver_contract,
		"accepted_field_metadata": receiver.get_meta("accepted_material_run_trial", {}),
		"live_module_metadata": receiver.get_meta("w291196370_live_modules", {}),
		"placements": _live_placement_metadata(live_root),
		"resolved_placements": live_root.get_meta("resolved_placements", []),
		"position_truth_boundary": {"fixed_runtime_centers": true, "uncertainty_by_placement_m": {"CAL-SSE-WINSTACK-01": 2.0, "CAL-SSE-ENTRY-01": 3.0, "CAL-ENE-SERVICE-01": 4.0}, "uncertainty_role": "declared same-run stylized calibration envelope only; no runtime jitter or surveyed-coordinate claim", "coordinates_surveyed": false, "scale_surveyed": false, "count_surveyed": false, "cadence_inferred": false, "total_opening_count_inferred": false, "placement_role": LIVE_MODULES.PLACEMENT_ROLE},
		"protected_scope": {"siding_runs_8_10_and_17_22_unchanged": true, "continuous_global_course_phase_unchanged": true, "placeholder_runs_0_7_11_16_23_35_unchanged": true, "modules_elsewhere_live": false, "cross_side_transfer": false, "generated_files_modified": false, "terrain_foundation_massing_modified": false, "collision_navigation_spray_modified": false, "completed_sse_elevation": false, "completed_ene_elevation": false, "whole_building_accepted": false},
		"captures": captures, "capture_count": captures.size(),
		"changed_light_exact_ene_service_run20_capture_id": "08-changed-light-exact-ene-service-run20",
		"validity_inspection_only": "Inspect actual live target visibility, complete motifs, grounding, shallow separation, tangent/up/outward orientation, both supported sides, ordinary context, exact ENE SERVICE changed light, whole-island context, and absence of backing/collision changes only. Executor art acceptance is prohibited.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write live w291196370 capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d actual loaded-world native Forward+/Metal w291196370 proof views to %s" % [captures.size(), output_absolute])
	_finish(main)


func _live_receiver_contract(receiver: Node3D, record: Dictionary) -> Dictionary:
	if receiver == null:
		return {"ok": false, "message": "Exact live w291196370 receiver node did not resolve."}
	var mesh_instance := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := receiver.get_node_or_null("Collision") as StaticBody3D
	var shape_node := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var live_root := receiver.get_node_or_null("W291196370LiveModules") as Node3D
	if mesh == null or body == null or shape == null or live_root == null \
	or receiver.get_child_count() != 3 or mesh.get_surface_count() != 2 \
	or mesh.surface_get_name(0) != ACCEPTED_FIELDS.PLACEHOLDER_SURFACE_NAME \
	or mesh.surface_get_name(1) != "trial_w291196370_siding_runs" \
	or live_root.get_child_count() != 3 or _count_type(live_root, MeshInstance3D) != 24 \
	or _count_type(live_root, CollisionObject3D) != 0 or _count_type(live_root, NavigationRegion3D) != 0 \
	or shape.get_faces().size() != (record.get("indices", []) as Array).size():
		return {"ok": false, "message": "Exact w291196370 field, collision, or live module topology drifted."}
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
	var origin := _vector3(resolved.module_origin_world_m as Array)
	var tangent_values := resolved.tangent_world_xz as Array
	var normal_values := resolved.outward_normal_world_xz as Array
	var tangent := Vector3(float(tangent_values[0]), 0.0, float(tangent_values[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	var target := origin
	var camera := target + normal * distance + tangent * lateral
	camera.y = float(resolved.base_y_m) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": [str(resolved.placement_id)], "representative_runs": resolved.run_ownership}


func _face_pose(record: Dictionary, runs: Array[int], chain_m: float, id: String, view_kind: String, distance: float, camera_height_above_base: float, placement_ids: Array[String], sun: Vector3, lateral: float = 0.0) -> Dictionary:
	var frame := FRAME_HELPER.chain_frame(record, runs, chain_m)
	var target := frame.wall_anchor as Vector3
	target.y = float(frame.base_y) + 3.0
	var camera := target + (frame.normal as Vector3) * distance + (frame.tangent as Vector3) * lateral
	camera.y = float(frame.base_y) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": placement_ids, "representative_runs": runs}


func _dual_side_pose(resolved: Dictionary, id: String, view_kind: String, distance: float, camera_height_above_base: float, placement_ids: Array[String], sun: Vector3) -> Dictionary:
	var first := resolved["CAL-SSE-ENTRY-01"] as Dictionary
	var second := resolved["CAL-ENE-SERVICE-01"] as Dictionary
	var first_origin := _vector3(first.module_origin_world_m as Array)
	var second_origin := _vector3(second.module_origin_world_m as Array)
	var first_normal_values := first.outward_normal_world_xz as Array
	var second_normal_values := second.outward_normal_world_xz as Array
	var first_normal := Vector3(float(first_normal_values[0]), 0.0, float(first_normal_values[1])).normalized()
	var second_normal := Vector3(float(second_normal_values[0]), 0.0, float(second_normal_values[1])).normalized()
	var target := (first_origin + second_origin) * 0.5
	target.y = (float(first.base_y_m) + float(second.base_y_m)) * 0.5 + 3.0
	var camera := target + (first_normal + second_normal).normalized() * distance
	camera.y = minf(float(first.base_y_m), float(second.base_y_m)) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": placement_ids, "representative_runs": [8, 10, 20]}


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
			"coordinates_surveyed": child.get_meta("coordinates_surveyed", true), "scale_surveyed": child.get_meta("scale_surveyed", true), "count_surveyed": child.get_meta("count_surveyed", true), "cadence_inferred": child.get_meta("cadence_inferred", true),
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
		"id": str(pose.id), "view_kind": str(pose.view_kind), "file": relative,
		"sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "aim_target_m": [target.x, target.y, target.z], "camera_fov_degrees": camera.fov,
		"sun_rotation_degrees": [(pose.sun as Vector3).x, (pose.sun as Vector3).y, (pose.sun as Vector3).z],
		"placement_ids": pose.placement_ids, "representative_runs": pose.representative_runs,
		"sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range),
	}
	print("W291196370_LIVE_MODULE_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
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
	_fail("Live w291196370 native capture timed out after %.0f seconds." % TIMEOUT_SECONDS)
	_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	if main != null and is_instance_valid(main):
		main.queue_free()
	quit(0 if _failure.is_empty() else 1)
