extends SceneTree

const CALIBRATION_HELPER := preload("res://game/tests/support/w34313525_exact_receiver_calibration.gd")
const REGISTRY_PATH := "res://game/resources/facades/w34313525_exact_receiver_calibration.json"
const HELPER_PATH := "res://game/tests/support/w34313525_exact_receiver_calibration.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_1__z_-1.json"
const OUTPUT := "res://evidence/first-playable/batch-06-w34313525-exact-receiver-calibration-2026-08-30"
const RECEIVER_KEY := "building:w34313525:wall"
const EXPECTED_REGISTRY_SHA256 := "ba22916618510f610719606c1c18f84b8965bbd76fe74eddc5430745470bbddd"
const EXPECTED_HELPER_SHA256 := "a9ff1f94274509cdb39c6208117c59b84ba67598ff8a59a1eb57bf30a4b03532"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313525_exact_receiver_calibration_capture.gd"
const EXPECTED_PROTECTED_HASHES := {
	REGISTRY_PATH: EXPECTED_REGISTRY_SHA256,
	HELPER_PATH: EXPECTED_HELPER_SHA256,
	CHUNK_PATH: "a952756b1c6d8d547669dffb89723c2be81d6c9a4b3afd2ae7f2dc3702a82b0d",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://discovery/facades/W34313525_STANDALONE_PROTOTYPE_ART_REVIEW.md": "3a75990173f6d272bf45b5f7c5ab6b411132a786751f1ed1f240a79d207231e6",
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
	"res://game/scripts/world/world_chunk_builder.gd": "e54b31cef98b45f00aadcba0b7a6dec0125f147c1c332c06158198dbe19e508d",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "aaea7d6518fda141a0c488a54a7441a70bc52d5b98cd666876aa665d3b5be80e",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "220f8af84f3f16c104858f630be9c4bb7e2d282569ab4d3a00bd49c07cb0b3cf",
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("w34313525 exact-receiver calibration evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for file_name: String in EXPECTED_PROTECTED_HASHES:
		if not _require(FileAccess.get_sha256(file_name) == str(EXPECTED_PROTECTED_HASHES[file_name]), "Protected calibration input drifted: %s" % file_name):
			_finish(null)
			return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var record := _record_data()
	if not _require(not record.is_empty(), "Exact w34313525 generated receiver record did not resolve."):
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for w34313525 calibration capture."):
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
	var receiver := _record_node_for_key(world)
	if not _require(receiver != null and receiver.get_meta("source_keys", []) == ["w34313525"], "Exact w34313525 runtime receiver identity failed."):
		_finish(main)
		return
	var receiver_children_before := receiver.get_child_count()
	var field_metadata_before := receiver.get_meta("accepted_material_run_trial", {}) as Dictionary
	if not _require(field_metadata_before.is_empty() and receiver_children_before == 2, "w34313525 was not placeholder-only and child-stable before the detached overlay."):
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
	camera.name = "W34313525ExactReceiverCalibrationEvidenceCamera"
	camera.fov = 50.0
	camera.far = 5000.0
	camera.current = true
	main.add_child(camera)
	var sun := main.get_node("Sun") as DirectionalLight3D
	var original_sun := sun.rotation_degrees
	var overlay := _make_overlay()
	main.add_child(overlay)
	var detail := overlay.get_node("Detail") as Label
	var resolved := calibration_result.resolved_placements as Array
	var captures: Array[Dictionary] = []
	for pose_value: Variant in _poses(record, resolved):
		var pose := pose_value as Dictionary
		detail.text = "W34313525 DETACHED EXACT-RECEIVER CALIBRATION · PALE FIELD SSE 8..12 + NNW 26..27\nEXACTLY 4 COMPLETE ONE-OFF MODULE EXEMPLARS · PRODUCTION INFERENCE · COUNT/CADENCE/SEQUENCE UNSURVEYED\n%s · ZERO LIVE ATTACHMENT · OTHER RUNS/SIDES/ELEVATIONS/WHOLE BUILDING BLOCKED" % str(pose.view_kind).replace("_", " ").to_upper()
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
		"schema_version": "ti.w34313525-exact-receiver-calibration-evidence/1",
		"review_status": "ready_for_independent_detached_exact_receiver_art_review_not_self_accepted",
		"evidence_role": "detached exact generated-receiver W34313525-MAT-PALE scale/phase proposal on SSE runs 8..12 and NNW runs 26..27 plus exactly one complete exemplar of each accepted module type; not live attachment, lifecycle acceptance, surveyed dimensions/coordinates/count/cadence/sequence, completed elevation, or whole-building proof",
		"source_key": "w34313525",
		"receiver_key": RECEIVER_KEY,
		"generator": "game/tests/w34313525_exact_receiver_calibration_capture.gd",
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
		"exact_field_scopes": registry.exact_field_scopes,
		"field_material_contract": registry.field_material_contract,
		"module_contracts": registry.module_contracts,
		"placement_policy": registry.placement_policy,
		"placements": registry.placements,
		"resolved_field_scopes": calibration_result.resolved_field_scopes,
		"resolved_placements": calibration_result.resolved_placements,
		"detached_overlay": registry.detached_overlay_contract,
		"excluded_regions": registry.excluded_regions,
		"preserved_false_claims": registry.preserved_false_claims,
		"captures": captures,
		"capture_count": captures.size(),
		"validity_inspection_only": "Inspect exact field scale and joins on both bounded sides, every complete motif, ground/high contact, ordinary side/building context, changed light, sparse exemplar truth, opaque HIGH-GROUP ambiguity, and receiver isolation only. Executor art acceptance is prohibited."
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write calibration capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d native Forward+/Metal w34313525 detached exact-receiver field/four-module calibration views with receiver children %d→%d and runtime topology unchanged" % [captures.size(), receiver_children_before, receiver.get_child_count()])
	_finish(main)


func _poses(record: Dictionary, resolved: Array) -> Array[Dictionary]:
	var by_id := {}
	for value: Variant in resolved:
		var item := value as Dictionary
		by_id[str(item.get("placement_id", ""))] = item
	return [
		_boundary_pose(record, 8, 9, "01-sse-field-join-08-09", "close_SSE_field_continuity_run_8_to_9", 15.0, 4.5, Vector3(-52.0, -28.0, 0.0)),
		_boundary_pose(record, 9, 10, "02-sse-field-join-09-10", "close_SSE_field_continuity_run_9_to_10", 15.0, 4.5, Vector3(-52.0, -28.0, 0.0)),
		_boundary_pose(record, 10, 11, "03-sse-field-join-10-11", "close_SSE_field_continuity_run_10_to_11", 14.0, 4.5, Vector3(-52.0, -28.0, 0.0)),
		_boundary_pose(record, 11, 12, "04-sse-field-join-11-12", "close_SSE_field_continuity_run_11_to_12", 11.0, 4.5, Vector3(-52.0, -28.0, 0.0)),
		_boundary_pose(record, 26, 27, "05-nnw-field-join-26-27", "close_NNW_field_continuity_run_26_to_27", 13.0, 4.5, Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(by_id["CAL-SSE-ROLLUP-PALE-01"] as Dictionary, "06-close-rollup-pale", "close_complete_ROLLUP_PALE_run_9", 12.0, 2.0, 3.6, Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(by_id["CAL-SSE-ROLLUP-GRAY-01"] as Dictionary, "07-close-rollup-gray", "close_complete_ROLLUP_GRAY_run_10", 12.0, -2.0, 3.6, Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(by_id["CAL-NNW-PERSONNEL-01"] as Dictionary, "08-close-personnel", "close_complete_PERSONNEL_run_26", 9.0, 1.4, 2.8, Vector3(-52.0, -28.0, 0.0)),
		_placement_pose(by_id["CAL-NNW-HIGH-GROUP-01"] as Dictionary, "09-close-high-group", "close_complete_opaque_HIGH_GROUP_run_27", 10.0, -1.2, 4.2, Vector3(-52.0, -28.0, 0.0)),
		_face_pose(record, [8, 9, 10, 11, 12], 37.5, "10-ordinary-sse-macro", "ordinary_SSE_two_rollups_and_30m_plus_field_macro", 26.0, 3.9, [8, 9, 10, 11, 12], ["CAL-SSE-ROLLUP-PALE-01", "CAL-SSE-ROLLUP-GRAY-01"], Vector3(-52.0, -28.0, 0.0)),
		_face_pose(record, [26, 27], 8.0, "11-ordinary-nnw-macro", "ordinary_NNW_personnel_HIGH_GROUP_and_15m_field", 27.0, 4.0, [26, 27], ["CAL-NNW-PERSONNEL-01", "CAL-NNW-HIGH-GROUP-01"], Vector3(-52.0, -28.0, 0.0)),
		{"id": "12-building-multiside-context", "view_kind": "aerial_building_context_two_bounded_opposite_sides", "camera": Vector3(365.0, 86.0, -38.0), "target": Vector3(318.0, 5.5, -99.0), "sun": Vector3(-52.0, -28.0, 0.0), "placement_ids": ["CAL-SSE-ROLLUP-PALE-01", "CAL-SSE-ROLLUP-GRAY-01", "CAL-NNW-PERSONNEL-01", "CAL-NNW-HIGH-GROUP-01"], "representative_runs": [8, 9, 10, 11, 12, 26, 27]},
		_face_pose(record, [8, 9, 10, 11, 12], 37.5, "13-changed-light-sse", "changed_light_SSE_field_rollup_pale_and_gray", 26.0, 4.8, [8, 9, 10, 11, 12], ["CAL-SSE-ROLLUP-PALE-01", "CAL-SSE-ROLLUP-GRAY-01"], Vector3(-18.0, 118.0, 0.0)),
		_face_pose(record, [26, 27], 8.0, "14-changed-light-nnw", "changed_light_NNW_field_PERSONNEL_and_opaque_HIGH_GROUP", 23.0, 5.2, [26, 27], ["CAL-NNW-PERSONNEL-01", "CAL-NNW-HIGH-GROUP-01"], Vector3(-18.0, 118.0, 0.0), 2.0),
	]


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
	var frame := CALIBRATION_HELPER.chain_frame(record, runs, chain_m)
	var wall_anchor := frame.wall_anchor as Vector3
	var normal := frame.normal as Vector3
	var tangent := frame.tangent as Vector3
	var target := wall_anchor
	target.y = float(frame.base_y) + 2.6
	var camera := target + normal * distance + tangent * lateral
	camera.y = float(frame.base_y) + camera_height_above_base
	return {"id": id, "view_kind": view_kind, "camera": camera, "target": target, "sun": sun, "placement_ids": placement_ids, "representative_runs": representative_runs}


func _boundary_pose(record: Dictionary, before_run: int, after_run: int, id: String, view_kind: String, distance: float, camera_height_above_base: float, sun: Vector3) -> Dictionary:
	var boundary := CALIBRATION_HELPER.boundary_frame(record, before_run, after_run)
	var junction := boundary.junction as Vector3
	var normal := boundary.normal as Vector3
	var target := junction
	target.y = 6.2
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
	overlay.name = "W34313525ExactCalibrationEvidenceOverlay"
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
	var stats := _luminance_stats(image)
	if float(stats.range) < 0.1:
		return {"ok": false, "message": "%s did not contain enough luminance variation for valid evidence." % str(pose.id)}
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
		_fail("Timed out while capturing w34313525 detached exact-receiver evidence.")
		_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	if main != null:
		main.queue_free()
	quit(1 if not _failure.is_empty() else 0)
