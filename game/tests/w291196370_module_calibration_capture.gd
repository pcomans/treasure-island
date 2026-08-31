extends SceneTree

const CALIBRATION_HELPER := preload("res://game/tests/support/w291196370_module_calibration.gd")
const FIELD_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const REGISTRY_PATH := "res://game/resources/facades/w291196370_module_calibration.json"
const HELPER_PATH := "res://game/tests/support/w291196370_module_calibration.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-3.json"
const OUTPUT := "res://evidence/first-playable/batch-06-w291196370-module-calibration-2026-08-30"
const RECEIVER_KEY := "building:w291196370:wall"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w291196370_module_calibration_capture.gd"
const EXPECTED_REGISTRY_SHA256 := "b30a8f19091288cde4b8e891ec40287ab28a73776588f96ee86fc5565cfc25b8"
const EXPECTED_HELPER_SHA256 := "ba621cffc5ee155e8b7c7338c3b5d444d1180dad6dbe11528219ada6de05dfdf"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_PROTECTED_HASHES := {
	REGISTRY_PATH: EXPECTED_REGISTRY_SHA256,
	HELPER_PATH: EXPECTED_HELPER_SHA256,
	CHUNK_PATH: "6dfa4b8f4b91f309b313428829e37cedd13e4067ff94f896a8e2e5ef05002a1d",
	"res://discovery/facades/BATCH_06_STREETVIEW_OBSERVATIONS.md": "259e562e69b1186912fce2dfb466f4512fbc69cc8e64562574971c0a8c40028b",
	"res://discovery/facades/W291196370_REFERENCE_SPEC.md": "fdd7328579950c0d8b852b4a122a252c9a3ee01f60cfe34d32d9d518b895edd7",
	"res://discovery/facades/BATCH_06_RUN_MAPPING.json": "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d",
	"res://discovery/facades/BATCH_06_PROTOTYPE_SET_01_MODULE_CORRECTION_ART_REVIEW.md": "70f6a0e1e9ece07d162aa669aa89e4f4a9a8b19b1785eb7fb91efc0dc8f6aded",
	"res://discovery/facades/BATCH_06_EXACT_RECEIVER_FIELD_TRIALS_ART_REVIEW.md": "ce213c3fb37529eeaefe01da1b555b44b4ea58ab10b36b2150002b8edf6d2bb7",
	"res://game/resources/facades/batch_06_prototype_registry.json": "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132",
	"res://game/scripts/world/facades/batch_06_prototype_set.gd": "fecc656332599acefbf307ce6b5978e62c689ae146f713cf9d935ef66b81de60",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "2f547040b38a4d46ca900c0bd8fb3a260bfb4a7df6cda9e8578d084f8b065029",
	"res://game/resources/materials/world/w291196370/w291196370_siding_exact_trial.tres": "715cf02b3c006c1a492ad61def9b2535fbaf04a3b1a41c69c5f092d705fab677",
	"res://game/resources/materials/world/w291196370/w291196370_trim.tres": "0223453497849cddb947701aaf6c83044d3bfd1e610dbc2eea49ed79cb5b56ad",
	"res://game/resources/materials/world/w291196370/w291196370_glass.tres": "bb2727b8bfe6e8228cfe938345fd38950055f13a2c3ee27a7fd0daafaa5ba6ff",
	"res://game/resources/materials/world/w291196370/w291196370_entry.tres": "da23ac9280107f5cd3ca3f73bfe6e236149634a27213d5a8ac453781a4b7248f",
	"res://game/resources/materials/world/w291196370/w291196370_service.tres": "ec7973f9b7849a7ae36c2027bed9fa3c019405cedc4c254f8a104391923981a2",
	"res://game/scripts/world/world_chunk_builder.gd": "bd1c9e52e0a36c13092382616dc0ff6e5ce52dfd16e279303491db8c73cfa23f",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "c9ed0671a82e58da47394654175269a4f7adc9ae13cdb840532c29b0c9d70d85",
	"res://discovery/FACADE_RECEIVER_INVENTORY.md": "71d8e2e77ad5de2192663aa3fe6d9b9d4b5873fd2981d9f0fda575a1ad12ffcc",
	"res://game/scripts/world/facades/w34313564_live_modules.gd": "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee",
	"res://game/scripts/world/facades/w34313515_live_modules.gd": "4420ad2d0a029f03da7a14fe84084d53edfa2323867a5c660c63f875c2a71ccb",
	"res://evidence/first-playable/batch-06-exact-receiver-trials-2026-08-30/capture-manifest.json": "034b6ef3ad0e85b81a2565a9443172bec3da9364ed29ab5b4cc6b34258e72449",
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("w291196370 module calibration evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for path: String in EXPECTED_PROTECTED_HASHES:
		if not _require(FileAccess.get_sha256(path) == str(EXPECTED_PROTECTED_HASHES[path]), "Protected calibration input drifted: %s" % path):
			_finish(null)
			return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var record := _record_data()
	if not _require(not record.is_empty(), "Exact w291196370 generated receiver record did not resolve."):
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for w291196370 calibration capture."):
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
	if not _require(runtime.chunks_loaded == 38 and runtime.mesh_instances == 847 and runtime.surfaces == 854 and runtime.triangles == 49805, "Whole-island loaded render topology drifted before detached calibration.") \
	or not _require(runtime.static_bodies == 466 and runtime.shapes == 466, "Whole-island collision topology drifted before detached calibration."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world)
	if not _require(receiver != null and receiver.get_meta("source_keys", []) == ["w291196370"], "Exact w291196370 runtime receiver identity failed."):
		_finish(main)
		return
	var field_metadata := receiver.get_meta("accepted_material_run_trial", {}) as Dictionary
	var receiver_children_before := receiver.get_child_count()
	if not _require(field_metadata == FIELD_TRIALS.metadata_for(RECEIVER_KEY) \
	and int(field_metadata.get("modules", -1)) == 0 \
	and int(field_metadata.get("standalone_modules_live", -1)) == 0 \
	and receiver_children_before == 2, "Accepted exact-run siding field was not immutable and module-free before the detached overlay."):
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
	camera.name = "W291196370ModuleCalibrationEvidenceCamera"
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
		detail.text = "W291196370 DETACHED MODULE CALIBRATION · COMPLETE MODULE-ATLAS MOTIFS\n3 EXEMPLARS · WINSTACK + ENTRY ON SSE · SERVICE ON ENE · COORDINATES/COUNT STYLIZED INFERENCE\n%s · CADENCE/SCALE UNSURVEYED · ZERO LIVE ATTACHMENT · NNW/WSW EXCLUDED" % str(pose.view_kind).replace("_", " ").to_upper()
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
		"schema_version": "ti.w291196370-module-calibration-evidence/1",
		"review_status": "ready_for_independent_detached_exact_receiver_module_calibration_review_not_self_accepted",
		"evidence_role": "detached exact-receiver complete WINSTACK, ENTRY and SERVICE module-atlas motif calibration over the immutable accepted SSE/ENE siding field; not live attachment, surveyed scale/coordinate/count/cadence acceptance, lifecycle change, completed-elevation acceptance, or whole-building proof",
		"source_key": "w291196370",
		"receiver_key": RECEIVER_KEY,
		"generator": "game/tests/w291196370_module_calibration_capture.gd",
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
		"loaded_world_before_overlay": {"chunks": runtime.chunks_loaded, "records": 729, "meshes": runtime.mesh_instances, "surfaces": runtime.surfaces, "triangles": runtime.triangles, "static_bodies": runtime.static_bodies, "shapes": runtime.shapes},
		"receiver_child_count_before_and_after_overlay": [receiver_children_before, receiver.get_child_count()],
		"accepted_field_metadata": field_metadata,
		"face_chains": registry.face_chains,
		"module_contracts": registry.module_contracts,
		"placement_policy": registry.placement_policy,
		"placements": registry.placements,
		"resolved_placements": calibration_result.resolved_placements,
		"detached_overlay": {"parent": "main_capture_scene_only", "module_instances": 3, "motif_types": 3, "mesh_instances": 24, "surfaces": 24, "triangles": 288, "field_meshes": 0, "backing_meshes": 0, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0, "runtime_attachment": false},
		"excluded_regions": registry.excluded_regions,
		"captures": captures,
		"capture_count": captures.size(),
		"preserved_blockers": registry.preserved_blockers,
		"validity_inspection_only": "Inspect target visibility, complete per-motif geometry, accepted host siding continuity, exact registered transforms, shallow depth, camera diversity, both supported sides and evidence labels only. Executor art acceptance is prohibited.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write calibration capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d native Forward+/Metal w291196370 detached module calibration views to %s" % [captures.size(), output_absolute])
	_finish(main)


func _poses(record: Dictionary, resolved: Dictionary) -> Array[Dictionary]:
	return [
		_placement_pose(resolved["CAL-SSE-WINSTACK-01"], "01-close-sse-winstack", "close_complete_winstack_motif", 11.0, -0.8, 2.5, Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(resolved["CAL-SSE-ENTRY-01"], "02-close-sse-entry", "close_complete_entry_motif", 10.0, 0.7, 1.9, Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(resolved["CAL-ENE-SERVICE-01"], "03-close-ene-service", "close_complete_service_motif", 12.5, -0.5, 2.1, Vector3(-52.0, -28.0, 0.0)),
		_face_pose(record, [8, 9, 10], 21.5, "04-ordinary-sse-public-context", "ordinary_gameplay_height_sse_public_side_context", 42.0, 2.3, ["CAL-SSE-WINSTACK-01", "CAL-SSE-ENTRY-01"], Vector3(-52.0, -28.0, 0.0)),
		_face_pose(record, [17, 18, 19, 20, 21, 22], 36.0, "05-ordinary-ene-outer-context", "ordinary_gameplay_height_ene_outer_side_context", 39.0, 2.4, ["CAL-ENE-SERVICE-01"], Vector3(-52.0, -28.0, 0.0)),
		_dual_side_pose(resolved, "06-sse-ene-multi-side-context", "ordinary_building_context_supported_sse_and_ene_regions", 67.0, 3.2, ["CAL-SSE-WINSTACK-01", "CAL-SSE-ENTRY-01", "CAL-ENE-SERVICE-01"], Vector3(-52.0, -28.0, 0.0)),
		_face_pose(record, [8, 9, 10], 21.5, "07-changed-light-oblique-sse", "changed_light_oblique_sse_complete_motifs", 30.0, 2.8, ["CAL-SSE-WINSTACK-01", "CAL-SSE-ENTRY-01"], Vector3(-22.0, 118.0, 0.0), 8.0),
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
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": [str(resolved.placement_id)], "representative_runs": resolved.run_ownership}


func _face_pose(record: Dictionary, runs: Array[int], chain_m: float, id: String, view_kind: String, distance: float, camera_height_above_base: float, placement_ids: Array[String], sun: Vector3, lateral: float = 0.0) -> Dictionary:
	var frame := CALIBRATION_HELPER.chain_frame(record, runs, chain_m)
	var wall_anchor := frame.wall_anchor as Vector3
	var normal := frame.normal as Vector3
	var tangent := frame.tangent as Vector3
	var target := wall_anchor
	target.y = float(frame.base_y) + 3.0
	var camera := target + normal * distance + tangent * lateral
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
	var outward := (first_normal + second_normal).normalized()
	var target := (first_origin + second_origin) * 0.5
	target.y = (float(first.base_y_m) + float(second.base_y_m)) * 0.5 + 3.0
	var camera := target + outward * distance
	camera.y = minf(float(first.base_y_m), float(second.base_y_m)) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": placement_ids, "representative_runs": [8, 10, 20]}


func _vector3(values: Array) -> Vector3:
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


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
		"representative_runs": pose.representative_runs,
		"sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range),
	}
	print("W291196370_MODULE_CALIBRATION_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
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
	push_error("W291196370_MODULE_CALIBRATION_CAPTURE_FAIL: %s" % message)


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
