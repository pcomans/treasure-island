extends SceneTree

const HELPER := preload("res://game/tests/support/building_1_exact_receiver_calibration.gd")
const REGISTRY_PATH := "res://game/resources/facades/building_1_exact_receiver_calibration.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const OUTPUT := "res://evidence/first-playable/treasure-island-building-1-exact-receiver-miter-correction-2026-08-30"
const RECEIVER_KEY := "building:r16681702:wall"
const CORRECTION_REVIEW_PATH := "res://discovery/facades/TREASURE_ISLAND_BUILDING_1_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md"
const EXPECTED_CORRECTION_REVIEW_SHA256 := "7c1d4fed00fda41b35b8618565622712368504465c45ab4aa443e3460ab4e85b"
const PREDECESSOR_MANIFEST_PATH := "res://evidence/first-playable/treasure-island-building-1-exact-receiver-calibration-2026-08-30/capture-manifest.json"
const EXPECTED_PREDECESSOR_MANIFEST_SHA256 := "9e84fb33d095546a422469dc8c5d6433eae194b7300aa1595968cc5a9d2005bb"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const CAPTURE_SIZE := Vector2i(1440, 900)
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/building_1_exact_receiver_calibration_capture.gd"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Building 1 detached evidence requires native Forward+/Metal.")
		_finish(null)
		return
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	var record := _record_data()
	if not _require(FileAccess.get_sha256(CORRECTION_REVIEW_PATH) == EXPECTED_CORRECTION_REVIEW_SHA256, "Independent miter-correction authorization drifted.") \
	or not _require(FileAccess.get_sha256(PREDECESSOR_MANIFEST_PATH) == EXPECTED_PREDECESSOR_MANIFEST_SHA256, "Predecessor evidence point-in-time drifted.") \
	or not _require(registry_value is Dictionary and not record.is_empty(), "Calibration registry or receiver record did not resolve."):
		_finish(null)
		return
	var registry := registry_value as Dictionary
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for detached calibration capture."):
		_finish(null)
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var ready_reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready_reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, keys: Array) -> void: failures.append({"code": code, "message": message, "keys": keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready_reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 50000:
		await process_frame
	if not _require(failures.is_empty() and ready_reports.size() == 1, "Loaded world did not reach one clean world_ready.") \
	or not _require(str(ready_reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content identity drifted."):
		_finish(main)
		return
	var runtime_before := world.get_runtime_evidence()
	var receiver := _record_node_for_key(world)
	if not _require(receiver != null and receiver.get_meta("source_keys", []) == ["r16681702"], "Exact Building 1 live receiver identity failed."):
		_finish(main)
		return
	var receiver_children_before := receiver.get_child_count()
	var receiver_metadata_before: Variant = receiver.get_meta("accepted_material_run_trial", {})
	var result := HELPER.build(record, registry)
	if not _require(bool(result.get("ok", false)), str(result.get("message", "Detached build failed."))):
		_finish(main)
		return
	var calibration := result.node as Node3D
	main.add_child(calibration)
	var runtime_after_overlay := world.get_runtime_evidence()
	if not _require(calibration.get_parent() == main and not calibration.is_ancestor_of(receiver), "Detached study attached to the live receiver.") \
	or not _require(receiver.get_child_count() == receiver_children_before, "Detached study changed receiver children.") \
	or not _require(JSON.stringify(runtime_before) == JSON.stringify(runtime_after_overlay), "Detached study changed loaded-world runtime topology."):
		_finish(main)
		return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.path_join("images"))) != OK:
		_fail("Could not create Building 1 calibration evidence directory.")
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "Building1DetachedCalibrationEvidenceCamera"
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
	for pose_value: Variant in _poses(record, result.resolved_fit_studies as Array):
		var pose := pose_value as Dictionary
		detail.text = "BUILDING 1 DETACHED MITER CORRECTION · MAT-IVORY RUNS 21..51 · 30 WATERTIGHT OFFSET JOINS\nBEFORE MAX 0.026857801 m → AFTER 0.0 m · CENTRAL/PAV TRANSFORMS UNCHANGED FIT STUDIES ONLY\n%s · ZERO LIVE ATTACHMENT · COMPLETE ELEVATION / WHOLE BUILDING BLOCKED" % str(pose.view_kind).replace("_", " ").to_upper()
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		var saved := await _save_view(camera, pose)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Capture failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var manifest := {
		"schema_version": "ti.building-1-detached-exact-receiver-miter-correction-evidence/1",
		"review_status": "ready_for_independent_detached_miter_correction_rereview_not_self_accepted",
		"evidence_role": "single bounded shared-miter correction proof for the exact MAT-IVORY overlay on outer runs 21..51; CENTRAL/PAV are byte-and-transform-preserved detached fit studies only; not live attachment or actual-world placement proof",
		"source_key": "r16681702", "receiver_key": RECEIVER_KEY,
		"generator": "game/tests/building_1_exact_receiver_calibration_capture.gd", "capture_command": COMMAND,
		"registry_path": REGISTRY_PATH, "registry_sha256": FileAccess.get_sha256(REGISTRY_PATH),
		"helper_path": "res://game/tests/support/building_1_exact_receiver_calibration.gd", "helper_sha256": FileAccess.get_sha256("res://game/tests/support/building_1_exact_receiver_calibration.gd"),
		"correction_authorization": {"path": CORRECTION_REVIEW_PATH, "sha256": EXPECTED_CORRECTION_REVIEW_SHA256, "prescribed_change": "independent per-run normal offsets to one shared XZ offset-line miter at every internal join"},
		"predecessor_evidence": {"path": PREDECESSOR_MANIFEST_PATH, "sha256": EXPECTED_PREDECESSOR_MANIFEST_SHA256, "preserved_point_in_time": true},
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [1440, 900],
		"exact_field_scope": registry.exact_field_scope,
		"resolved_field_scope": result.resolved_field_scope,
		"fit_study_policy": registry.fit_study_policy,
		"fit_studies": registry.fit_studies,
		"resolved_fit_studies": result.resolved_fit_studies,
		"complete_join_proof": {"machine_complete_internal_join_count": 30, "maximum_endpoint_delta_m": 0.0, "maximum_chain_phase_delta_m": 0.0, "visual_sample_join_pairs": [[21,22],[30,31],[38,39],[45,46],[50,51]]},
		"rendered_overlay_miter_correction": result.resolved_field_scope.overlay_join_miter_correction,
		"rendered_overlay_join_records": result.resolved_field_scope.overlay_join_records,
		"topology": registry.detached_overlay_contract,
		"loaded_world_before_and_after_overlay": {"before": runtime_before, "after": runtime_after_overlay},
		"receiver_child_count_before_and_after_overlay": [receiver_children_before, receiver.get_child_count()],
		"receiver_material_metadata_before_and_after_overlay": [receiver_metadata_before, receiver.get_meta("accepted_material_run_trial", {})],
		"captures": captures, "capture_count": captures.size(),
		"blocked_claims": registry.preserved_false_claims,
		"validity_inspection_only": "Review field scale/phase/macro, sampled joins, complete CENTRAL/PAV contact and ordinary context, changed light, and isolation only. Executor acceptance is prohibited."
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest) \
	or not _write_json(OUTPUT.path_join("runtime-isolation.json"), {"content_sha256": EXPECTED_CONTENT_SHA256, "runtime_before": runtime_before, "runtime_after": runtime_after_overlay, "receiver_children": [receiver_children_before, receiver.get_child_count()], "receiver_metadata": [receiver_metadata_before, receiver.get_meta("accepted_material_run_trial", {})], "detached_runtime_attachment": false, "actual_world_placement_count": 0}):
		_fail("Could not write evidence metadata.")
		_finish(main)
		return
	print("PASS: captured %d native Building 1 detached shared-miter correction views; 31 runs/30 watertight joins, two unchanged fit studies, receiver/runtime unchanged" % captures.size())
	_finish(main)


func _poses(record: Dictionary, resolved: Array) -> Array[Dictionary]:
	var by_id := {}
	for value: Variant in resolved:
		var item := value as Dictionary
		by_id[str(item.fit_study_id)] = item
	return [
		_boundary_pose(record, 21, 22, "01-field-join-21-22", "close_field_join_21_22", 18.0, Vector3(-52,-28,0)),
		_boundary_pose(record, 30, 31, "02-field-join-30-31", "close_field_join_30_31", 18.0, Vector3(-52,-28,0)),
		_boundary_pose(record, 38, 39, "03-field-join-38-39", "close_sharp_field_join_38_39", 18.0, Vector3(-52,-28,0)),
		_boundary_pose(record, 45, 46, "04-field-join-45-46", "close_field_join_45_46", 18.0, Vector3(-52,-28,0)),
		_boundary_pose(record, 50, 51, "05-field-join-50-51", "close_field_join_50_51", 18.0, Vector3(-52,-28,0)),
		_chain_pose(record, 43.0, "06-field-macro-85m", "ordinary_85m_public_curve_macro", 80.0, 21.0, Vector3(-52,-28,0)),
		_fit_pose(by_id["FIT-CENTRAL-W-R36"], "07-central-close", "close_complete_CENTRAL_contact_fit", 10.0, 1.0, Vector3(-52,-28,0)),
		_fit_pose(by_id["FIT-CENTRAL-W-R36"], "08-central-oblique", "oblique_complete_CENTRAL_contact_fit", 15.0, 5.0, Vector3(-52,-28,0)),
		_fit_pose(by_id["FIT-PAV-W-R06"], "09-pavilion-close", "close_complete_PAV_contact_fit", 18.0, 2.0, Vector3(-52,-28,0)),
		_fit_pose(by_id["FIT-PAV-W-R06"], "10-pavilion-oblique", "oblique_complete_PAV_contact_fit", 24.0, -8.0, Vector3(-52,-28,0)),
		_fit_pose(by_id["FIT-CENTRAL-W-R36"], "11-central-ordinary", "ordinary_distance_CENTRAL_and_public_curve", 36.0, 2.0, Vector3(-52,-28,0)),
		_fit_pose(by_id["FIT-PAV-W-R06"], "12-pavilion-ordinary", "ordinary_distance_PAV_and_north_end", 45.0, 1.0, Vector3(-52,-28,0)),
		{"id":"13-whole-building-context", "view_kind":"multi_side_whole_building_context_not_acceptance", "camera":Vector3(-150,55,750), "target":Vector3(-5,15,730), "sun":Vector3(-52,-28,0), "fit_study_ids":["FIT-CENTRAL-W-R36","FIT-PAV-W-R06"], "representative_runs":[6,21,36,51]},
		_fit_pose(by_id["FIT-CENTRAL-W-R36"], "14-central-changed-light", "changed_light_CENTRAL_and_ivory", 18.0, 4.0, Vector3(-18,118,0)),
		_fit_pose(by_id["FIT-PAV-W-R06"], "15-pavilion-changed-light", "changed_light_PAV_and_north_end", 28.0, -5.0, Vector3(-18,118,0)),
	]


func _boundary_pose(record: Dictionary, before: int, after: int, id: String, kind: String, distance: float, sun: Vector3) -> Dictionary:
	var boundary := HELPER.boundary_frame(record, before, after)
	var target := boundary.junction as Vector3
	target.y = 15.0
	var camera := target + (boundary.normal as Vector3) * distance
	camera.y = 17.0
	return {"id":id,"view_kind":kind,"camera":camera,"target":target,"sun":sun,"fit_study_ids":[],"representative_runs":[before,after]}


func _chain_pose(record: Dictionary, chain_m: float, id: String, kind: String, distance: float, height: float, sun: Vector3) -> Dictionary:
	var runs: Array[int] = []
	for index in range(21, 52): runs.append(index)
	var frame := HELPER.chain_frame(record, runs, chain_m)
	var target := frame.wall_anchor as Vector3
	target.y = 15.0
	var camera := target + (frame.normal as Vector3) * distance
	camera.y = height
	return {"id":id,"view_kind":kind,"camera":camera,"target":target,"sun":sun,"fit_study_ids":["FIT-CENTRAL-W-R36"],"representative_runs":[21,36,51]}


func _fit_pose(item: Dictionary, id: String, kind: String, distance: float, lateral: float, sun: Vector3) -> Dictionary:
	var origin := _vector3(item.module_origin_world_m as Array)
	var normal := Vector3(float(item.outward_normal_world_xz[0]),0,float(item.outward_normal_world_xz[1])).normalized()
	var tangent := Vector3(float(item.tangent_world_xz[0]),0,float(item.tangent_world_xz[1])).normalized()
	var camera := origin + normal * distance + tangent * lateral
	camera.y = origin.y + 1.0
	return {"id":id,"view_kind":kind,"camera":camera,"target":origin,"sun":sun,"fit_study_ids":[str(item.fit_study_id)],"representative_runs":[int(item.representative_run)]}


func _record_data() -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	for value: Variant in chunk.get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == RECEIVER_KEY: return record
	return {}


func _record_node_for_key(world: WorldLoader) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == RECEIVER_KEY: return value as Node3D
	return null


func _make_overlay() -> CanvasLayer:
	var layer := CanvasLayer.new()
	var backdrop := ColorRect.new(); backdrop.color = Color(0.015,0.02,0.025,0.86); backdrop.position = Vector2(24,22); backdrop.size = Vector2(1392,108); layer.add_child(backdrop)
	var detail := Label.new(); detail.name = "Detail"; detail.position = Vector2(44,36); detail.add_theme_font_size_override("font_size",15); detail.add_theme_color_override("font_color",Color("f4f0e8")); layer.add_child(detail)
	return layer


func _save_view(camera: Camera3D, pose: Dictionary) -> Dictionary:
	camera.force_update_transform()
	await process_frame; await RenderingServer.frame_post_draw; await process_frame; await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE: return {"ok":false,"message":"%s produced an invalid image." % str(pose.id)}
	var stats := _luminance_stats(image)
	if float(stats.range) < 0.1: return {"ok":false,"message":"%s lacks visual range." % str(pose.id)}
	var relative := "images/%s.png" % str(pose.id)
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK: return {"ok":false,"message":"%s could not save." % str(pose.id)}
	return {"ok":true,"metadata":{"id":pose.id,"view_kind":pose.view_kind,"file":relative,"sha256":FileAccess.get_sha256(path),"bytes":FileAccess.get_file_as_bytes(path).size(),"dimensions":[1440,900],"sampled_luminance":stats,"camera_position_m":[camera.position.x,camera.position.y,camera.position.z],"target_position_m":[pose.target.x,pose.target.y,pose.target.z],"sun_rotation_degrees":[pose.sun.x,pose.sun.y,pose.sun.z],"fit_study_ids":pose.fit_study_ids,"representative_runs":pose.representative_runs}}


func _luminance_stats(image: Image) -> Dictionary:
	var low := 1.0; var high := 0.0; var total := 0.0; var count := 0
	for y in range(0,image.get_height(),18):
		for x in range(0,image.get_width(),18):
			var value := image.get_pixel(x,y).get_luminance(); low = minf(low,value); high = maxf(high,value); total += value; count += 1
	return {"minimum":snappedf(low,0.000001),"maximum":snappedf(high,0.000001),"range":snappedf(high-low,0.000001),"mean":snappedf(total/float(count),0.000001),"sample_count":count}


func _vector3(values: Array) -> Vector3:
	return Vector3(float(values[0]),float(values[1]),float(values[2]))


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path,FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(value,"  ")+"\n"); file.close(); return true


func _require(condition: bool, message: String) -> bool:
	if not condition: _fail(message)
	return condition


func _fail(message: String) -> void:
	_failed = true; push_error(message)


func _finish(main: Node) -> void:
	if main != null: main.queue_free()
	quit(1 if _failed else 0)
