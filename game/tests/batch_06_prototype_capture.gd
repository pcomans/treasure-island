extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/batch_06_prototype_registry.json"
const OUTPUT_ROOT := "res://evidence/first-playable/batch-06-prototype-set-01-correction-2026-08-30"
const EXPECTED_REGISTRY_SHA256 := "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132"
const CAPTURE_SIZE := Vector2i(1440, 900)
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/batch_06_prototype_capture.gd"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Batch 06 prototype evidence requires the native macOS Metal renderer.")
		_finish(null)
		return
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Registry bytes drifted before capture."):
		_finish(null)
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var stage := _make_stage()
	root.add_child(stage)
	var camera := stage.get_node("Camera3D") as Camera3D
	var sun := stage.get_node("Sun") as DirectionalLight3D
	var detail := stage.get_node("ProofOverlay/Detail") as Label
	var overall: Array[Dictionary] = []
	for target_value: Variant in registry.targets:
		var target := target_value as Dictionary
		var packed := load(str(target.scene.path)) as PackedScene
		if not _require(packed != null and FileAccess.get_sha256(str(target.scene.path)) == str(target.scene.sha256), "Prototype scene failed its capture preflight: %s" % str(target.scene.path)):
			_finish(stage)
			return
		var prototype := packed.instantiate() as Node3D
		prototype.name = "ActivePrototype"
		stage.add_child(prototype)
		await process_frame
		var geometry := prototype.get_node("PrototypeGeometry") as Node3D
		var dimensions := geometry.get_meta("proof_dimensions_m") as Vector2
		var module_ids: Array[String] = []
		for module_value: Variant in target.modules:
			module_ids.append(str((module_value as Dictionary).motif_id))
		detail.text = "%s  ·  %s\nCorrected render-only proof  ·  complete modules: %s\nCONTINUOUS HOST FIELD  ·  NO MODULE BACKING SLABS  ·  NO LIVE ATTACHMENT" % [str(target.receiver_key), str(target.source_key), ", ".join(module_ids)]
		var output := OUTPUT_ROOT.path_join(str(target.source_key))
		if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
			_fail("Could not create capture directory: %s" % output)
			_finish(stage)
			return
		var captures: Array[Dictionary] = []
		for pose: Dictionary in _poses(dimensions):
			var capture := await _capture_pose(camera, sun, output, pose)
			if not bool(capture.get("ok", false)):
				_fail(str(capture.get("message", "Unknown capture failure.")))
				_finish(stage)
				return
			captures.append(capture.result as Dictionary)
		var target_manifest := {
			"schema_version": "ti.batch-06-prototype-correction-evidence/1",
			"review_status": "ready_for_independent_visual_review_not_self_accepted",
			"evidence_role": "controlled standalone corrected complete-module proof over byte-identical accepted fields; not live receiver evidence",
			"correction_brief": "discovery/facades/BATCH_06_PROTOTYPE_SET_01_ART_REVIEW.md",
			"before": "module-owned forward field-colored backing slabs created raised halos and siding phase resets",
			"after": "the one continuous host field owns all nonopening pixels; modules own frame, mullion, glass, leaf and trim geometry only",
			"source_key": str(target.source_key),
			"receiver_key": str(target.receiver_key),
			"registry_sha256": EXPECTED_REGISTRY_SHA256,
			"scene_path": str(target.scene.path),
			"scene_sha256": str(target.scene.sha256),
			"module_ids": module_ids,
			"module_owned_field_meshes": 0,
			"host_field_phase_resets": 0,
			"host_material_compatibility": target.modules,
			"field_materials": target.materials,
			"mapped_placement_bounds": target.mapped_groups,
			"runtime_attachment": false,
			"collision_nodes": 0,
			"navigation_nodes": 0,
			"one_local_unit_m": 1.0,
			"proof_dimensions_m": [dimensions.x, dimensions.y],
			"godot_version": Engine.get_version_info().get("string", "unknown"),
			"display_driver": DisplayServer.get_name(),
			"video_adapter": RenderingServer.get_video_adapter_name(),
			"rendering_method": "Forward+",
			"rendering_driver": "Metal",
			"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
			"capture_command": COMMAND,
			"captures": captures,
		}
		if not _write_json(output.path_join("capture-manifest.json"), target_manifest):
			_fail("Could not write target capture manifest: %s" % output)
			_finish(stage)
			return
		overall.append({"source_key": str(target.source_key), "directory": str(target.source_key), "scene_sha256": str(target.scene.sha256), "captures": captures})
		stage.remove_child(prototype)
		prototype.free()
	var overall_manifest := {
		"schema_version": "ti.batch-06-prototype-correction-evidence-set/1",
		"review_status": "ready_for_independent_visual_review_not_self_accepted",
		"evidence_role": "one corrected controlled module round over byte-identical accepted fields; not live receiver or whole-building acceptance",
		"correction_brief": "discovery/facades/BATCH_06_PROTOTYPE_SET_01_ART_REVIEW.md",
		"module_owned_field_meshes": 0,
		"host_field_phase_resets": 0,
		"registry_path": REGISTRY_PATH,
		"registry_sha256": EXPECTED_REGISTRY_SHA256,
		"capture_command": COMMAND,
		"renderer": "Forward+/Metal",
		"targets": overall,
	}
	if not _write_json(OUTPUT_ROOT.path_join("capture-manifest.json"), overall_manifest):
		_fail("Could not write overall capture manifest.")
		_finish(stage)
		return
	print("PASS: captured 9 fresh native Forward+/Metal corrected Batch 06 module views over continuous accepted host fields; no live receiver attachment or art acceptance was performed")
	_finish(stage)


func _make_stage() -> Node3D:
	var stage := Node3D.new()
	stage.name = "Batch06ControlledPrototypeProof"
	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("20272d")
	environment.background_energy_multiplier = 0.72
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("aebac2")
	environment.ambient_light_energy = 0.48
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	world_environment.environment = environment
	stage.add_child(world_environment)
	var floor := MeshInstance3D.new()
	floor.name = "NeutralFloor"
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(40.0, 40.0)
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
	backdrop.size = Vector2(1320, 142)
	overlay.add_child(backdrop)
	var title := Label.new()
	title.name = "Title"
	title.position = Vector2(48, 38)
	title.text = "CONTROLLED BATCH 06 CORRECTED COMPLETE-MODULE PROOF"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("f3d56e"))
	overlay.add_child(title)
	var detail := Label.new()
	detail.name = "Detail"
	detail.position = Vector2(48, 74)
	detail.add_theme_font_size_override("font_size", 17)
	detail.add_theme_color_override("font_color", Color("f0f2f4"))
	overlay.add_child(detail)
	stage.add_child(overlay)
	return stage


func _poses(dimensions: Vector2) -> Array[Dictionary]:
	var center := Vector3(0.0, dimensions.y * 0.5, 0.0)
	var ordinary_z: float = maxf(dimensions.x, dimensions.y) * 1.55
	return [
		{"id": "01-close", "view_kind": "close_material_and_module_detail", "camera": Vector3(-dimensions.x * 0.12, dimensions.y * 0.55, max(6.8, dimensions.y * 0.72)), "target": center, "sun": Vector3(-34.0, -28.0, 0.0)},
		{"id": "02-ordinary-distance", "view_kind": "ordinary_gameplay_distance_control", "camera": Vector3(0.0, dimensions.y * 0.58, ordinary_z), "target": center, "sun": Vector3(-34.0, -28.0, 0.0)},
		{"id": "03-changed-light-oblique", "view_kind": "changed_light_oblique_alias_and_depth_control", "camera": Vector3(dimensions.x * 0.58, dimensions.y * 0.68, ordinary_z * 0.78), "target": center, "sun": Vector3(-14.0, 116.0, 0.0)},
	]


func _capture_pose(camera: Camera3D, sun: DirectionalLight3D, output: String, pose: Dictionary) -> Dictionary:
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
	var filename := "%s.png" % str(pose.id)
	var path := output.path_join(filename)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(pose.id)}
	return {"ok": true, "result": {"id": str(pose.id), "view_kind": str(pose.view_kind), "file": filename, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y], "camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "sun_rotation_degrees": [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z]}}


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
