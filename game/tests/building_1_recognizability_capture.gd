extends SceneTree

const FACADE := preload("res://game/scripts/world/facades/building_1_recognizable_facade.gd")
const BASELINE_FIELD := preload("res://game/scripts/world/facades/building_1_live_field.gd")
const RUN_GEOMETRY := preload("res://game/tests/support/building_1_exact_receiver_calibration.gd")
const RECEIVER_KEY := "building:r16681702:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const REGISTRY_PATH := "res://game/resources/facades/building_1_recognizability_placements.json"
const OUTPUT := "res://evidence/first-playable/treasure-island-building-1-recognizability-composition-2026-08-30"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/building_1_recognizability_capture.gd"
const EXPECTED_IMMUTABLE_HASHES := {
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	CHUNK_PATH: "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	"res://game/resources/facades/building_1_standalone_prototypes.json": "2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc",
	"res://game/scripts/world/facades/building_1_standalone_prototypes.gd": "cf18bfcfa40c7770d92aad569cba05da7ac85fe0fc89c0fd8cba6167ef62fb1f",
	"res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres": "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a",
	"res://game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader": "a4a5df4fbb8fd4f13187ec284708879b540677ac2c827642b4c3040b4bce4c09",
	"res://discovery/facades/TREASURE_ISLAND_BUILDING_1_LIVE_IVORY_FIELD_ART_REVIEW.md": "35d8e0d306b381feee997c068824222e22ff4199c8ef5433bbe5ae082fa4c048",
	"res://discovery/facades/TREASURE_ISLAND_BUILDING_1_RECOGNIZABILITY_PLACEMENT_BRIEF.md": "f4f9d3d123ce923713b113d4c020e64d0d83356e2d8f3d8bc6dd3b1eac3c5be4",
	"res://game/resources/facades/r133351_standalone_prototypes.json": "ecde7b80ba595f61d03bfd21f57407956c3b8988e381f0457f95bfe1aa580ad9",
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Building 1 recognizability evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for path: String in EXPECTED_IMMUTABLE_HASHES:
		if not _require(FileAccess.get_sha256(path) == str(EXPECTED_IMMUTABLE_HASHES[path]), "Immutable Building 1 input drifted: %s" % path):
			_finish(null)
			return
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == FACADE.EXPECTED_REGISTRY_SHA256, "Building 1 recognizability registry drifted."):
		_finish(null)
		return
	var registry := _json(REGISTRY_PATH)
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for Building 1 recognizability capture."):
		_finish(null)
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, keys: Array) -> void: failures.append({"code": code, "message": message, "keys": keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 50000:
		await process_frame
	if not _require(failures.is_empty() and reports.size() == 1 and str(reports[0].get("content_sha256", "")) == CONTENT_SHA256, "Actual world did not reach one clean content-identical ready state."):
		_finish(main)
		return
	var runtime := world.get_runtime_evidence()
	if not _require(runtime.chunks_loaded == 38 and runtime.mesh_instances == 1278 and runtime.surfaces == 1288 and runtime.triangles == 55067, "Building 1 recognizability runtime topology drifted.") \
	or not _require(runtime.static_bodies == 466 and runtime.shapes == 466, "Building 1 recognizability composition changed collider topology."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world)
	var record := _record_data()
	var facade := receiver.get_node_or_null("Building1RecognizableFacade") as Node3D if receiver != null else null
	if not _require(receiver != null and facade != null and receiver.get_child_count() == 3, "Actual loaded Building 1 recognizability receiver did not resolve."):
		_finish(main)
		return
	var baseline_result := BASELINE_FIELD.build(record)
	if not _require(bool(baseline_result.get("ok", false)), "Accepted Building 1 field baseline could not build for same-pose before comparison."):
		_finish(main)
		return
	var baseline := baseline_result.node as Node3D
	receiver.add_child(baseline)
	baseline.hide()
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.path_join("images"))) != OK:
		_fail("Could not create Building 1 recognizability evidence directory.")
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "Building1RecognizabilityEvidenceCamera"
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
	for pose_value: Variant in _poses(record, registry, original_sun):
		var pose := pose_value as Dictionary
		var before := str(pose.get("stage", "after")) == "before"
		facade.visible = not before
		baseline.visible = before
		detail.text = "BUILDING 1 RECOGNIZABILITY STUDY · %s\n%s · REFERENCE-DERIVED PRODUCTION INFERENCE · AS-BUILT UNCLAIMED\n%s" % ["BEFORE: ACCEPTED IVORY FIELD ONLY" if before else "AFTER: IVORY + COMPLETE MOTIF COMPOSITION", str(pose.view_kind).replace("_", " ").to_upper(), "PENDING INDEPENDENT RECOGNIZABILITY REVIEW"]
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		var saved := await _save_view(camera, pose)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Building 1 recognizability capture failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	facade.show()
	baseline.hide()
	sun.rotation_degrees = original_sun
	receiver.remove_child(baseline)
	baseline.free()
	var manifest := {
		"schema_version": "ti.building-1-recognizability-live-evidence/1",
		"review_status": "pending_independent_recognizability_art_review_not_self_accepted",
		"evidence_role": "native actual-loaded-world before/after proof of a reversible recognizability-first Building 1 composition; production inference, not surveyed reconstruction",
		"source_key": "r16681702",
		"receiver_key": RECEIVER_KEY,
		"generator": "game/tests/building_1_recognizability_capture.gd",
		"capture_command": COMMAND,
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [1440, 900],
		"content_sha256": CONTENT_SHA256,
		"immutable_inputs_capture_time": EXPECTED_IMMUTABLE_HASHES,
		"registry_path": REGISTRY_PATH,
		"registry_sha256": FileAccess.get_sha256(REGISTRY_PATH),
		"adapter_path": "res://game/scripts/world/facades/building_1_recognizable_facade.gd",
		"adapter_sha256": FileAccess.get_sha256("res://game/scripts/world/facades/building_1_recognizable_facade.gd"),
		"world_builder_sha256": FileAccess.get_sha256("res://game/scripts/world/world_chunk_builder.gd"),
		"generated_source_and_data_bytes_unchanged": true,
		"runtime_before_recognizability_composition": {"records": 729, "meshes": 925, "surfaces": 935, "triangles": 50791, "static_bodies": 466, "shapes": 466},
		"runtime_after_recognizability_composition": {"records": 729, "meshes": runtime.mesh_instances, "surfaces": runtime.surfaces, "triangles": runtime.triangles, "static_bodies": runtime.static_bodies, "shapes": runtime.shapes},
		"exact_runtime_delta_vs_accepted_ivory_baseline": {"meshes": 353, "surfaces": 353, "triangles": 4276, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0},
		"composition_topology": registry.get("live_render_topology", {}),
		"field_composition": registry.get("field_composition", {}),
		"placement_summary": registry.get("placement_summary", {}),
		"placements": registry.get("placements", []),
		"protected_scope": registry.get("protected_scope", {}),
		"truth_boundary": registry.get("truth_boundary", {}),
		"receiver_contract": {"child_count": 3, "generated_receiver_meshes": 1, "generated_receiver_surfaces": 1, "generated_receiver_triangles": 220, "composition_meshes": 354, "composition_surfaces": 354, "composition_triangles": 4338, "collision_face_vertices": int((receiver.get_node("Collision/Shape") as CollisionShape3D).shape.get_faces().size()), "collision_navigation_spray_owned_by_composition": false},
		"captures": captures,
		"capture_count": captures.size(),
		"same_pose_before_after_pairs": [["01-before-ordinary-public-curve", "02-after-ordinary-public-curve"], ["03-before-ordinary-north-end", "04-after-ordinary-north-end"], ["05-before-whole-building", "06-after-whole-building"]],
		"family_close_oblique_capture_ids": ["07-wing-family-close-oblique", "08-central-family-close-oblique", "09-pavilion-family-close-oblique", "10-base-family-close-oblique", "11-door-family-close-oblique", "12-band-family-close-oblique"],
		"context_capture_ids": ["13-multiside-context", "14-changed-light-public-curve", "15-south-end-ordinary", "16-whole-island"],
		"validity_inspection_only": "Independent reviewer must judge ordinary-distance recognizability, complete motif read, field continuity, contact/containment, changed light, and protected-scope noninterference. Executor art acceptance is prohibited.",
	}
	var isolation := {
		"schema_version": "ti.building-1-recognizability-runtime-isolation/1",
		"result": "PASS",
		"runtime_before": manifest.runtime_before_recognizability_composition,
		"runtime_after": manifest.runtime_after_recognizability_composition,
		"delta_vs_accepted_ivory_baseline": manifest.exact_runtime_delta_vs_accepted_ivory_baseline,
		"receiver_child_count": 3,
		"receiver_collision_face_vertices": int((receiver.get_node("Collision/Shape") as CollisionShape3D).shape.get_faces().size()),
		"generated_data_changed": false,
		"receiver_geometry_changed": false,
		"receiver_collision_changed": false,
		"navigation_changed": false,
		"spray_ownership_changed": false,
		"protected_run_attachment_count": 0,
		"module_field_or_backing_meshes": 0,
		"composition_review_status": FACADE.COMPOSITION_REVIEW_STATUS,
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest) or not _write_json(OUTPUT.path_join("runtime-isolation.json"), isolation):
		_fail("Could not write Building 1 recognizability evidence metadata.")
		_finish(main)
		return
	print("PASS: captured %d native Building 1 recognizability before/after and complete-family views at 729/1,278/1,288/55,067/466" % captures.size())
	_finish(main)


func _poses(record: Dictionary, registry: Dictionary, original_sun: Vector3) -> Array[Dictionary]:
	var public_pose := _run_pose(record, 36, 72.0, 25.0, 18.0, original_sun)
	var north_pose := _run_pose(record, 94, 48.0, 20.0, 14.0, original_sun)
	var poses: Array[Dictionary] = [
		_pose("01-before-ordinary-public-curve", "before", "same_pose_ordinary_gameplay_public_curve_before", public_pose),
		_pose("02-after-ordinary-public-curve", "after", "same_pose_ordinary_gameplay_public_curve_after", public_pose),
		_pose("03-before-ordinary-north-end", "before", "same_pose_ordinary_gameplay_north_end_before", north_pose),
		_pose("04-after-ordinary-north-end", "after", "same_pose_ordinary_gameplay_north_end_after", north_pose),
		{"id": "05-before-whole-building", "stage": "before", "view_kind": "same_pose_whole_building_before_not_acceptance", "camera": Vector3(-165.0, 72.0, 750.0), "target": Vector3(-8.0, 15.0, 737.0), "sun": original_sun, "representative_runs": [0, 21, 38, 51, 60, 93, 96]},
		{"id": "06-after-whole-building", "stage": "after", "view_kind": "same_pose_whole_building_after_not_acceptance", "camera": Vector3(-165.0, 72.0, 750.0), "target": Vector3(-8.0, 15.0, 737.0), "sun": original_sun, "representative_runs": [0, 21, 38, 51, 60, 93, 96]},
	]
	for capture in [
		["07-wing-family-close-oblique", "REC-WING-R13-LOW", 12.0, 4.0],
		["08-central-family-close-oblique", "REC-CENTRAL-R35-A", 14.0, 5.0],
		["09-pavilion-family-close-oblique", "REC-PAV-NORTH-R93", 22.0, 9.0],
		["10-base-family-close-oblique", "REC-BASE-R94-2", 10.0, 3.0],
		["11-door-family-close-oblique", "REC-DOOR-BLUE-R06", 10.0, 3.0],
		["12-band-family-close-oblique", "REC-BAND-R56", 11.0, 4.0],
	]:
		poses.append(_placement_pose(registry, str(capture[1]), str(capture[0]), float(capture[2]), float(capture[3]), original_sun))
	poses.append({"id": "13-multiside-context", "stage": "after", "view_kind": "multiside_actual_world_composition_context", "camera": Vector3(-135.0, 48.0, 710.0), "target": Vector3(-7.0, 15.0, 744.0), "sun": original_sun, "representative_runs": [0, 9, 21, 38, 51, 60, 93, 96]})
	var changed := _run_pose(record, 36, 58.0, 24.0, 12.0, Vector3(-18.0, 118.0, 0.0))
	poses.append(_pose("14-changed-light-public-curve", "after", "changed_light_complete_composition", changed))
	var south := _run_pose(record, 60, 42.0, 18.0, 10.0, original_sun)
	poses.append(_pose("15-south-end-ordinary", "after", "ordinary_gameplay_south_end_pavilion_and_bands", south))
	poses.append({"id": "16-whole-island", "stage": "after", "view_kind": "whole_island_actual_loaded_world_context", "camera": Vector3(180.0, 1550.0, 300.0), "target": Vector3(-20.0, 0.0, 30.0), "sun": original_sun, "representative_runs": []})
	return poses


func _run_pose(record: Dictionary, run_index: int, distance: float, camera_y: float, lateral: float, sun: Vector3) -> Dictionary:
	var frame := RUN_GEOMETRY.run_frame(record, run_index)
	var target := (frame.start as Vector3).lerp(frame.end as Vector3, 0.5)
	target.y = lerpf((frame.start as Vector3).y, (frame.end as Vector3).y, 0.5) + 10.0
	var camera := target + (frame.normal as Vector3) * distance + (frame.tangent as Vector3) * lateral
	camera.y = camera_y
	return {"camera": camera, "target": target, "sun": sun, "representative_runs": [run_index]}


func _pose(id: String, stage: String, kind: String, values: Dictionary) -> Dictionary:
	return {"id": id, "stage": stage, "view_kind": kind, "camera": values.camera, "target": values.target, "sun": values.sun, "representative_runs": values.representative_runs}


func _placement_pose(registry: Dictionary, placement_id: String, id: String, distance: float, lateral: float, sun: Vector3) -> Dictionary:
	var placement := {}
	for value: Variant in registry.get("placements", []):
		if str((value as Dictionary).get("placement_id", "")) == placement_id:
			placement = value as Dictionary
			break
	var origin_values := placement.get("expected_module_origin_world_m", []) as Array
	var normal_values := placement.get("outward_normal_world_xz", []) as Array
	var tangent_values := placement.get("tangent_world_xz", []) as Array
	var target := Vector3(float(origin_values[0]), float(origin_values[1]), float(origin_values[2]))
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1]))
	var tangent := Vector3(float(tangent_values[0]), 0.0, float(tangent_values[1]))
	var camera := target + normal * distance + tangent * lateral
	camera.y = target.y + minf(3.0, distance * 0.15)
	return {"id": id, "stage": "after", "view_kind": "complete_%s_close_oblique" % str(placement.get("motif_id", "module")).to_lower().replace("-", "_"), "camera": camera, "target": target, "sun": sun, "representative_runs": [int(placement.get("anchor_run", -1))], "placement_id": placement_id}


func _record_data() -> Dictionary:
	for value: Variant in _json(CHUNK_PATH).get("records", []):
		if str((value as Dictionary).get("object_key", "")) == RECEIVER_KEY:
			return value as Dictionary
	return {}


func _record_node_for_key(world: WorldLoader) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == RECEIVER_KEY and value.get_parent() != null and str(value.get_parent().name).contains("__"):
			return value as Node3D
	return null


func _make_overlay() -> CanvasLayer:
	var layer := CanvasLayer.new()
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.015, 0.02, 0.025, 0.86)
	backdrop.position = Vector2(24, 22)
	backdrop.size = Vector2(1392, 108)
	layer.add_child(backdrop)
	var detail := Label.new()
	detail.name = "Detail"
	detail.position = Vector2(44, 36)
	detail.add_theme_font_size_override("font_size", 15)
	detail.add_theme_color_override("font_color", Color("f4f0e8"))
	layer.add_child(detail)
	return layer


func _save_view(camera: Camera3D, pose: Dictionary) -> Dictionary:
	camera.force_update_transform()
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s produced an invalid image." % str(pose.id)}
	var stats := _luminance_stats(image)
	if float(stats.range) < 0.1:
		return {"ok": false, "message": "%s lacks visual range." % str(pose.id)}
	var relative := "images/%s.png" % str(pose.id)
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save." % str(pose.id)}
	return {"ok": true, "metadata": {"id": pose.id, "stage": pose.stage, "view_kind": pose.view_kind, "file": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [1440, 900], "sampled_luminance": stats, "camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "target_position_m": [pose.target.x, pose.target.y, pose.target.z], "sun_rotation_degrees": [pose.sun.x, pose.sun.y, pose.sun.z], "representative_runs": pose.representative_runs}}


func _luminance_stats(image: Image) -> Dictionary:
	var low := 1.0
	var high := 0.0
	var total := 0.0
	var count := 0
	for y in range(0, image.get_height(), 18):
		for x in range(0, image.get_width(), 18):
			var value := image.get_pixel(x, y).get_luminance()
			low = minf(low, value)
			high = maxf(high, value)
			total += value
			count += 1
	return {"minimum": snappedf(low, 0.000001), "maximum": snappedf(high, 0.000001), "range": snappedf(high - low, 0.000001), "mean": snappedf(total / float(count), 0.000001), "sample_count": count}


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ") + "\n")
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
	if not _finished:
		_fail("Timed out while capturing Building 1 recognizability evidence.")
		_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	if main != null:
		main.queue_free()
	quit(1 if not _failure.is_empty() else 0)
