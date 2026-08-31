extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/w34313520_standalone_prototypes.json"
const EXPECTED_REGISTRY_SHA256 := "ab80f0cd0424c22f7f24e5fc82211353e9aee7c95bea4903022681a48c5620a4"
const SCENE_PATH := "res://game/scenes/world/facades/batch_06/w34313520_standalone_prototype_set.tscn"
const EXPECTED_SCENE_SHA256 := "4d0ee0e79ea6fd5a7e85b21cdf4a103d125818626b6c97875737cad44cc65785"
const OUTPUT_ROOT := "res://evidence/first-playable/batch-06-w34313520-standalone-prototypes-2026-08-30"
const CAPTURE_SIZE := Vector2i(1440, 900)
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313520_standalone_prototype_capture.gd"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("w34313520 evidence requires the native macOS Metal renderer.")
		_finish(null)
		return
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Registry bytes drifted before capture.") \
	or not _require(FileAccess.get_sha256(SCENE_PATH) == EXPECTED_SCENE_SHA256, "Standalone scene bytes drifted before capture."):
		_finish(null)
		return
	var packed := load(SCENE_PATH) as PackedScene
	if not _require(packed != null, "Standalone scene could not load for capture."):
		_finish(null)
		return
	var stage := _make_stage()
	root.add_child(stage)
	var prototype := packed.instantiate() as Node3D
	prototype.name = "W34313520StandaloneProof"
	stage.add_child(prototype)
	await process_frame
	var geometry := prototype.get_node_or_null("PrototypeGeometry") as Node3D
	if not _require(geometry != null and _count_meshes(geometry) == 16 and _count_meshes(geometry.get_node("W34313520_BAY")) == 15, "Capture preflight topology failed."):
		_finish(stage)
		return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT)) != OK:
		_fail("Could not create w34313520 evidence directory.")
		_finish(stage)
		return
	var camera := stage.get_node("Camera3D") as Camera3D
	var sun := stage.get_node("Sun") as DirectionalLight3D
	var detail := stage.get_node("ProofOverlay/Detail") as Label
	var captures: Array[Dictionary] = []
	for pose: Dictionary in _poses():
		detail.text = "%s  ·  %s\n%s\nSTANDALONE ONLY  ·  NO CALIBRATION / LIVE ATTACHMENT  ·  SCALE + CADENCE NOT SURVEYED" % [str(pose.label), str(pose.view_kind), str(pose.scope_note)]
		var capture := await _capture_pose(camera, sun, pose)
		if not bool(capture.get("ok", false)):
			_fail(str(capture.get("message", "Unknown capture failure.")))
			_finish(stage)
			return
		captures.append(capture.result as Dictionary)
	var manifest := {
		"schema_version": "ti.w34313520-standalone-prototype-evidence/1",
		"source_key": "w34313520",
		"receiver_key": "building:w34313520:wall",
		"review_status": "ready_for_independent_standalone_art_review_not_self_accepted",
		"evidence_role": "controlled native standalone field and complete module proof; not receiver placement, calibration, gameplay-world, elevation or whole-building evidence",
		"registry_path": REGISTRY_PATH,
		"registry_sha256": EXPECTED_REGISTRY_SHA256,
		"scene_path": SCENE_PATH,
		"scene_sha256": EXPECTED_SCENE_SHA256,
		"asset_kinds": {"homogeneous_material_tile": ["W34313520-MAT-PALE"], "module_atlas": ["W34313520-BAY"], "architectural_pattern_tile": [], "unique_elevation": []},
		"observed_scope": "long SSE outer elevation family only; runs 6..10 are eligibility bounds, not placements",
		"proof_dimensions_m": [30.0, 11.0],
		"field_repeat_proof": {"span_m": 30.0, "finite_facade_motif_period": "none_by_design", "mapping": "continuous meter-space aperiodic host field"},
		"bay_proof": {"nominal_bounds_m": [6.8, 9.4], "tier_count": 3, "internal_mullion_cadence": "unknown_not_encoded", "module_meshes": 15, "field_or_backing_meshes": 0},
		"topology": {"total_meshes": 16, "total_surfaces": 16, "total_triangles": 192, "module_meshes": 15, "module_surfaces": 15, "module_triangles": 180, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0},
		"runtime_attachment": false,
		"exact_receiver_calibration": false,
		"one_local_unit_m": 1.0,
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"capture_command": COMMAND,
		"captures": captures,
		"blocked_claims": ["exact placement, count or cadence", "surveyed dimensions or scale", "runs 20..21 and inset wing", "non-SSE sides", "complete SSE elevation", "whole-building resemblance or acceptance"],
	}
	if not _write_json(OUTPUT_ROOT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write the w34313520 capture manifest.")
		_finish(stage)
		return
	print("PASS: captured 6 fresh native Forward+/Metal w34313520 standalone field/module views with valid luminance, including 30 m macro behavior and changed light; no receiver placement or acceptance occurred")
	_finish(stage)


func _make_stage() -> Node3D:
	var stage := Node3D.new()
	stage.name = "W34313520StandaloneEvidenceStage"
	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("20272d")
	environment.background_energy_multiplier = 0.72
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("aebac2")
	environment.ambient_light_energy = 0.5
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	world_environment.environment = environment
	stage.add_child(world_environment)
	var floor := MeshInstance3D.new()
	floor.name = "NeutralFloor"
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(70.0, 70.0)
	floor.mesh = floor_mesh
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("4b5155")
	floor_material.roughness = 0.94
	floor.material_override = floor_material
	stage.add_child(floor)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = Color("fff5e8")
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	stage.add_child(sun)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.fov = 50.0
	camera.current = true
	stage.add_child(camera)
	var overlay := CanvasLayer.new()
	overlay.name = "ProofOverlay"
	var backdrop := ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.color = Color(0.015, 0.02, 0.025, 0.87)
	backdrop.position = Vector2(28, 24)
	backdrop.size = Vector2(1380, 142)
	overlay.add_child(backdrop)
	var title := Label.new()
	title.name = "Title"
	title.position = Vector2(48, 38)
	title.text = "W34313520 · CONTROLLED STANDALONE PROTOTYPE PROOF"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("f3d56e"))
	overlay.add_child(title)
	var detail := Label.new()
	detail.name = "Detail"
	detail.position = Vector2(48, 73)
	detail.add_theme_font_size_override("font_size", 16)
	detail.add_theme_color_override("font_color", Color("f0f2f4"))
	overlay.add_child(detail)
	stage.add_child(overlay)
	return stage


func _poses() -> Array[Dictionary]:
	return [
		{"id": "01-neutral-field-close", "label": "W34313520-MAT-PALE", "view_kind": "neutral_close_material", "scope_note": "0.95 m proof scale, uncertainty 0.35–1.80 m · motif-free host field", "camera": Vector3(-9.2, 5.5, 7.2), "target": Vector3(-9.2, 5.5, 0.0), "sun": Vector3(-34.0, -28.0, 0.0)},
		{"id": "02-complete-bay-neutral", "label": "W34313520-BAY", "view_kind": "complete_module_neutral", "scope_note": "complete three-tier motif · full frames · host field supplies pale pier space", "camera": Vector3(0.0, 5.4, 14.5), "target": Vector3(0.0, 5.35, 0.0), "sun": Vector3(-34.0, -28.0, 0.0)},
		{"id": "03-complete-bay-oblique", "label": "W34313520-BAY", "view_kind": "complete_module_oblique_depth", "scope_note": "15 module meshes · zero field/backing meshes · mullion cadence left unknown", "camera": Vector3(8.0, 6.4, 14.5), "target": Vector3(0.0, 5.35, 0.0), "sun": Vector3(-34.0, -28.0, 0.0)},
		{"id": "04-ordinary-gameplay-scale", "label": "SSE FAMILY EXEMPLAR", "view_kind": "ordinary_gameplay_readable_scale", "scope_note": "one illustrative standalone motif on continuous field · not a proposed placement", "camera": Vector3(0.0, 4.4, 34.0), "target": Vector3(0.0, 5.0, 0.0), "sun": Vector3(-34.0, -28.0, 0.0)},
		{"id": "05-macro-repeat-span", "label": "W34313520-MAT-PALE", "view_kind": "macro_repeat_and_alias_control", "scope_note": "30 m continuous aperiodic field · no finite facade motif period or phase reset", "camera": Vector3(0.0, 8.8, 43.0), "target": Vector3(0.0, 5.0, 0.0), "sun": Vector3(-34.0, -28.0, 0.0)},
		{"id": "06-changed-light-oblique", "label": "FIELD + COMPLETE BAY", "view_kind": "changed_light_oblique_finish_and_depth", "scope_note": "changed sun exposes roughness, relief and bounded module depth", "camera": Vector3(-14.0, 8.0, 34.0), "target": Vector3(0.0, 5.0, 0.0), "sun": Vector3(-16.0, 118.0, 0.0)},
	]


func _capture_pose(camera: Camera3D, sun: DirectionalLight3D, pose: Dictionary) -> Dictionary:
	camera.position = pose.camera as Vector3
	camera.look_at(pose.target as Vector3, Vector3.UP)
	sun.rotation_degrees = pose.sun as Vector3
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
	var filename := "%s.png" % str(pose.id)
	var path := OUTPUT_ROOT.path_join(filename)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(pose.id)}
	return {"ok": true, "result": {"id": str(pose.id), "label": str(pose.label), "view_kind": str(pose.view_kind), "scope_note": str(pose.scope_note), "file": filename, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y], "sampled_luminance": stats, "camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "sun_rotation_degrees": [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z]}}


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


func _count_meshes(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _count_meshes(child)
	return count


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
	_failed = true
	push_error(message)


func _finish(stage: Node3D) -> void:
	if stage != null:
		stage.queue_free()
	quit(1 if _failed else 0)
