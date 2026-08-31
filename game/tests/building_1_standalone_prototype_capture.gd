extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/building_1_standalone_prototypes.json"
const EXPECTED_REGISTRY_SHA256 := "2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc"
const SCENE_PATH := "res://game/scenes/world/facades/building_1/building_1_standalone_prototype_set.tscn"
const EXPECTED_SCENE_SHA256 := "1d205d4d6e176d4ed1e82746d1f1f8c4c2547910b1a71f87a213d9ada14967ef"
const OUTPUT_ROOT := "res://evidence/first-playable/treasure-island-building-1-standalone-prototypes-2026-08-30"
const CAPTURE_SIZE := Vector2i(1440, 900)
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/building_1_standalone_prototype_capture.gd"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Building 1 evidence requires the native macOS Forward+/Metal renderer; headless capture is forbidden.")
		_finish(null)
		return
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Registry bytes drifted before Building 1 capture.") \
	or not _require(FileAccess.get_sha256(SCENE_PATH) == EXPECTED_SCENE_SHA256, "Standalone scene bytes drifted before Building 1 capture."):
		_finish(null)
		return
	var packed := load(SCENE_PATH) as PackedScene
	if not _require(packed != null, "Building 1 standalone scene could not load for capture."):
		_finish(null)
		return
	var stage := _make_stage()
	root.add_child(stage)
	var prototype := packed.instantiate() as Node3D
	prototype.name = "Building1StandaloneProof"
	stage.add_child(prototype)
	await process_frame
	var geometry := prototype.get_node_or_null("PrototypeGeometry") as Node3D
	if not _require(geometry != null and _count_meshes(geometry) == 44 and _count_module_meshes(geometry) == 43, "Building 1 capture preflight topology failed."):
		_finish(stage)
		return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT)) != OK:
		_fail("Could not create Building 1 evidence directory.")
		_finish(stage)
		return
	var camera := stage.get_node("Camera3D") as Camera3D
	var sun := stage.get_node("Sun") as DirectionalLight3D
	var detail := stage.get_node("ProofOverlay/Detail") as Label
	var captures: Array[Dictionary] = []
	for pose: Dictionary in _poses():
		detail.text = "%s  ·  %s\n%s\nSTANDALONE ONLY  ·  NO RUN MAPPING / RECEIVER PLACEMENT  ·  DIMENSIONS + COUNT + CADENCE NOT SURVEYED" % [str(pose.label), str(pose.view_kind), str(pose.scope_note)]
		var capture := await _capture_pose(camera, sun, pose)
		if not bool(capture.get("ok", false)):
			_fail(str(capture.get("message", "Unknown capture failure.")))
			_finish(stage)
			return
		captures.append(capture.result as Dictionary)
	var manifest := {
		"schema_version": "ti.building-1-standalone-prototype-evidence/1",
		"source_key": "r16681702",
		"canonical_identity": "Treasure Island Administration Building 1 / Treasure Island Museum",
		"receiver_key": "building:r16681702:wall",
		"review_status": "ready_for_independent_standalone_art_review_not_self_accepted",
		"evidence_role": "controlled native standalone field and complete-module proof; not exact receiver placement, calibration, gameplay-world, elevation, or whole-building evidence",
		"registry_path": REGISTRY_PATH,
		"registry_sha256": EXPECTED_REGISTRY_SHA256,
		"scene_path": SCENE_PATH,
		"scene_sha256": EXPECTED_SCENE_SHA256,
		"asset_kinds": {"homogeneous_material_tile": ["B1-MAT-IVORY"], "module_atlas": ["B1-WING-W", "B1-CENTRAL-W", "B1-PAV-W", "B1-BASE-O", "B1-DOOR-BLUE", "B1-BAND"], "architectural_pattern_tile": [], "unique_elevation": []},
		"observed_scope": "public west-facing outer region families only; exact outer run endpoints unresolved, inner ring and tower excluded",
		"proof_dimensions_m": [40.0, 10.0],
		"field_repeat_proof": {"span_m": 40.0, "finite_facade_motif_period": "none_by_design", "mapping": "continuous local metre-space aperiodic host field", "facade_scale_motifs": 0, "baked_lighting": false},
		"module_proof": {"module_meshes": 43, "field_or_backing_meshes": 0, "complete_motifs": 6, "opaque_proxy_semantics": ["glazing", "base window or vent"], "maximum_relief_m": 0.12},
		"topology": {"total_meshes": 44, "total_surfaces": 44, "total_triangles": 528, "module_meshes": 43, "module_surfaces": 43, "module_triangles": 516, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0},
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
		"blocked_claims": ["exact ordered run or along-run placement", "surveyed dimensions, scale, color, count, cadence or sequence", "main entrance or canopy", "pavilion emblems", "east/rear, inner ring or separate tower", "receiver massing or silhouette correction", "completed elevation or whole-building resemblance"],
	}
	if not _write_json(OUTPUT_ROOT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write Building 1 capture manifest.")
		_finish(stage)
		return
	print("PASS: captured 11 fresh native Forward+/Metal Building 1 standalone views covering one 40 m warm-ivory field, six complete modules, neutral close/oblique, ordinary-distance context and changed light; no receiver placement or acceptance occurred")
	_finish(stage)


func _make_stage() -> Node3D:
	var stage := Node3D.new()
	stage.name = "Building1StandaloneEvidenceStage"
	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("222930")
	environment.background_energy_multiplier = 0.72
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b8c0c4")
	environment.ambient_light_energy = 0.48
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	world_environment.environment = environment
	stage.add_child(world_environment)
	var floor := MeshInstance3D.new()
	floor.name = "NeutralFloor"
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(90.0, 90.0)
	floor.mesh = floor_mesh
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("50565b")
	floor_material.roughness = 0.94
	floor.material_override = floor_material
	stage.add_child(floor)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = Color("fff4e6")
	sun.light_energy = 1.38
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
	title.text = "BUILDING 1 · CONTROLLED STANDALONE PROTOTYPE PROOF"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("f2d16b"))
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
	var neutral := Vector3(-34.0, -28.0, 0.0)
	return [
		{"id": "01-warm-ivory-neutral-close", "label": "B1-MAT-IVORY", "view_kind": "neutral_close_material", "scope_note": "1.10 m primary / 0.32 m secondary production scales · motif-free field, no baked light or unique stain", "camera": Vector3(16.0, 6.2, 6.2), "target": Vector3(16.0, 6.2, 0.0), "sun": neutral},
		{"id": "02-warm-ivory-macro-40m", "label": "B1-MAT-IVORY", "view_kind": "macro_repeat_and_alias_control", "scope_note": "40 m continuous aperiodic field · no finite facade motif period and no generated-run phase claim", "camera": Vector3(0.0, 11.0, 47.0), "target": Vector3(0.0, 5.0, 0.0), "sun": neutral},
		{"id": "03-wing-window-close", "label": "B1-WING-W", "view_kind": "complete_module_neutral_close", "scope_note": "complete wing opening study: opaque face, full frame and mullions · host field owns all surrounding pixels", "camera": Vector3(-15.0, 6.8, 5.7), "target": Vector3(-15.0, 6.8, 0.0), "sun": neutral},
		{"id": "04-central-window-close", "label": "B1-CENTRAL-W", "view_kind": "complete_module_neutral_close", "scope_note": "complete tall narrow multipane study · distinct family, not stretched from wing window", "camera": Vector3(-10.4, 6.3, 8.0), "target": Vector3(-10.4, 6.3, 0.0), "sun": neutral},
		{"id": "05-pavilion-window-close", "label": "B1-PAV-W", "view_kind": "complete_module_neutral_close", "scope_note": "complete full-height multipane group and shallow pilaster strips · no silhouette ownership", "camera": Vector3(-3.2, 5.1, 17.5), "target": Vector3(-3.2, 5.0, 0.0), "sun": neutral},
		{"id": "06-base-opening-close", "label": "B1-BASE-O", "view_kind": "complete_module_neutral_close", "scope_note": "complete base opening · opaque proxy does not disambiguate window versus vent", "camera": Vector3(4.7, 1.35, 4.2), "target": Vector3(4.7, 1.25, 0.0), "sun": neutral},
		{"id": "07-blue-door-close", "label": "B1-DOOR-BLUE", "view_kind": "complete_module_neutral_close", "scope_note": "complete opaque blue utility/personnel leaf and full frame · no main-entrance claim", "camera": Vector3(8.5, 1.55, 5.0), "target": Vector3(8.5, 1.45, 0.0), "sun": neutral},
		{"id": "08-band-oblique-close", "label": "B1-BAND", "view_kind": "complete_module_neutral_oblique", "scope_note": "complete shallow muted-rose base-band exemplar with finished terminals · not a seamless wall tile", "camera": Vector3(16.8, 6.4, 5.0), "target": Vector3(14.2, 5.1, 0.0), "sun": neutral},
		{"id": "09-all-modules-oblique", "label": "SIX COMPLETE MODULE FAMILIES", "view_kind": "aggregate_oblique_depth_and_zero_backing", "scope_note": "illustrative standalone lineup only · six complete motifs, 43 module meshes, zero field/backing ownership", "camera": Vector3(-23.0, 12.5, 36.0), "target": Vector3(-2.0, 4.8, 0.0), "sun": neutral},
		{"id": "10-ordinary-distance-aggregate", "label": "FIELD + SIX COMPLETE MODULES", "view_kind": "ordinary_gameplay_readable_scale", "scope_note": "40 m proof field and separated family exemplars · not an elevation, sequence, count or cadence", "camera": Vector3(0.0, 11.0, 54.0), "target": Vector3(0.0, 5.0, 0.0), "sun": neutral},
		{"id": "11-changed-light-aggregate", "label": "FIELD + SIX COMPLETE MODULES", "view_kind": "changed_light_oblique_finish_and_shallow_depth", "scope_note": "changed sun exposes matte field, opaque component families, shallow relief and zero module backing", "camera": Vector3(22.0, 13.0, 42.0), "target": Vector3(-1.0, 4.8, 0.0), "sun": Vector3(-18.0, 122.0, 0.0)},
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


func _count_module_meshes(geometry: Node3D) -> int:
	var count := 0
	for child in geometry.get_children():
		if child is Node3D and str(child.name).begins_with("B1_"):
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
