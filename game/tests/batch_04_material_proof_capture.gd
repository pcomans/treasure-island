extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/batch_04_material_registry.json"
const OUTPUT_ROOT := "res://evidence/first-playable/batch-04-material-prototypes-2026-08-29"
const EXPECTED_REGISTRY_SHA256 := "97c9e4e07b0680a3c825923cbd0433536e98d9dcc5d511279249a86e2163aac9"
const EXPECTED_GENERIC_SHADER_SHA256 := "1918177080126199ddbfc0715a77b85a9355800479a098ec9b81c9726b7cc4d5"
const EXPECTED_SIDING_SHADER_SHA256 := "63f0be4ab7995f94653298cff1d5a271728209e05ee014c67b76165bc4f0dc8d"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const CAPTURE_SIZE := Vector2i(1440, 900)
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/batch_04_material_proof_capture.gd"
const TARGET_SLUGS := {
	"w291189926": "job-corps-dormitory-369",
	"w34313512": "449-avenue-h",
	"w34313546": "850-avenue-h",
	"w96698660": "810-avenue-d",
	"w34313569": "bldg-461",
	"w95934092": "1318-gateview",
	"w96215649": "1212-mariner",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Batch 04 proof capture requires explicit owner approval and the real macOS Metal renderer; headless execution is not visual evidence.")
		_finish(null)
		return
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Registry bytes drifted before proof capture.") \
	or not _require(FileAccess.get_sha256("res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader") == EXPECTED_GENERIC_SHADER_SHA256, "Generic shader bytes drifted before proof capture.") \
	or not _require(FileAccess.get_sha256("res://game/resources/materials/world/batch_04/batch_04_horizontal_siding_field.gdshader") == EXPECTED_SIDING_SHADER_SHA256, "Siding shader bytes drifted before proof capture.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated manifest bytes drifted before proof capture."):
		_finish(null)
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var stage := _make_stage()
	root.add_child(stage)
	var panel := stage.get_node("ProofPanel") as MeshInstance3D
	var camera := stage.get_node("Camera3D") as Camera3D
	var sun := stage.get_node("Sun") as DirectionalLight3D
	var detail := stage.get_node("ProofOverlay/Detail") as Label
	var capture_total := 0
	for target_value: Variant in registry.targets:
		var target := target_value as Dictionary
		var source_key := str(target.source_key)
		if not _require(TARGET_SLUGS.has(source_key), "Unexpected Batch 04 target: %s." % source_key):
			_finish(stage)
			return
		for material_value: Variant in target.materials:
			var material_record := material_value as Dictionary
			var material := load(str(material_record.path)) as ShaderMaterial
			if not _require(material != null, "Material failed to load: %s." % str(material_record.path)) \
			or not _require(FileAccess.get_sha256(str(material_record.path)) == str(material_record.sha256), "Material bytes drifted: %s." % str(material_record.path)):
				_finish(stage)
				return
			panel.material_override = material
			detail.text = "%s  ·  %s  ·  %s\n4.8 m × 3.2 m controlled panel  ·  proof scale %.3f m\n%s — NOT ATTACHED IN GAME" % [str(target.canonical_name), source_key, str(material_record.role), float(material_record.proof_primary_scale_m), str(target.prototype_status).to_upper()]
			var output := OUTPUT_ROOT.path_join(str(TARGET_SLUGS[source_key])).path_join(str(material_record.role))
			if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
				_fail("Could not create proof directory: %s." % output)
				_finish(stage)
				return
			var captures: Array[Dictionary] = []
			for pose: Dictionary in _poses():
				var capture := await _capture_pose(stage, camera, sun, output, pose)
				if not bool(capture.get("ok", false)):
					_fail(str(capture.get("message", "Unknown capture failure.")))
					_finish(stage)
					return
				captures.append(capture.result as Dictionary)
			capture_total += captures.size()
			var manifest := {
				"schema_version": "ti.batch-04-material-proof-evidence/1",
				"review_status": "ready_for_independent_visual_review_not_self_accepted",
				"evidence_role": "controlled_material_prototype_not_in_game_acceptance",
				"runtime_attachment": false,
				"prototype_status": str(target.prototype_status),
				"temporal_status": str(target.temporal_status),
				"source_key": source_key,
				"receiver_key": str(target.receiver_key),
				"canonical_name": str(target.canonical_name),
				"observed_region_scope": str(target.region_scope),
				"material_role": str(material_record.role),
				"material_path": str(material_record.path),
				"material_sha256": str(material_record.sha256),
				"registry_sha256": EXPECTED_REGISTRY_SHA256,
				"generated_manifest_sha256": EXPECTED_MANIFEST_SHA256,
				"proof_receiver": "controlled_flat_proof_panel",
				"proof_panel_size_m": [4.8, 3.2, 0.12],
				"one_local_unit_m": 1.0,
				"proof_primary_scale_m": float(material_record.proof_primary_scale_m),
				"scale_status": str(material_record.scale_status),
				"contains_facade_scale_motifs": false,
				"godot_version": Engine.get_version_info().get("string", "unknown"),
				"display_driver": DisplayServer.get_name(),
				"video_adapter": RenderingServer.get_video_adapter_name(),
				"rendering_method": "Forward+",
				"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
				"capture_command": COMMAND,
				"captures": captures,
			}
			if not _write_json(output.path_join("capture-manifest.json"), manifest):
				_fail("Could not write proof manifest: %s." % output)
				_finish(stage)
				return
			print("BATCH04_PROOF_FIELD: source=%s role=%s views=%d output=%s" % [source_key, str(material_record.role), captures.size(), ProjectSettings.globalize_path(output)])
	print("PASS: captured %d Forward+/Metal controlled proof views for 17 prototype-only Batch 04 fields; none is live receiver or gameplay evidence" % capture_total)
	_finish(stage)


func _make_stage() -> Node3D:
	var stage := Node3D.new()
	stage.name = "Batch04ControlledMaterialProof"
	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("283038")
	environment.background_energy_multiplier = 0.7
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b8c2ca")
	environment.ambient_light_energy = 0.42
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	world_environment.environment = environment
	stage.add_child(world_environment)
	var panel := MeshInstance3D.new()
	panel.name = "ProofPanel"
	var panel_mesh := BoxMesh.new()
	panel_mesh.size = Vector3(4.8, 3.2, 0.12)
	panel.mesh = panel_mesh
	panel.position = Vector3(0.0, 1.9, 0.0)
	stage.add_child(panel)
	var floor := MeshInstance3D.new()
	floor.name = "NeutralFloor"
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(18.0, 18.0)
	floor.mesh = floor_mesh
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("575d61")
	floor_material.roughness = 0.92
	floor.material_override = floor_material
	stage.add_child(floor)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = Color("fff5e7")
	sun.light_energy = 1.25
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
	backdrop.color = Color(0.02, 0.025, 0.03, 0.86)
	backdrop.position = Vector2(28, 24)
	backdrop.size = Vector2(1180, 132)
	overlay.add_child(backdrop)
	var title := Label.new()
	title.name = "Title"
	title.position = Vector2(48, 38)
	title.text = "CONTROLLED BATCH 04 MATERIAL PROOF"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("f4d56c"))
	overlay.add_child(title)
	var detail := Label.new()
	detail.name = "Detail"
	detail.position = Vector2(48, 72)
	detail.add_theme_font_size_override("font_size", 17)
	detail.add_theme_color_override("font_color", Color("f0f2f4"))
	overlay.add_child(detail)
	stage.add_child(overlay)
	return stage


func _poses() -> Array[Dictionary]:
	return [
		{"id": "01-close", "view_kind": "close_material_proof", "camera": Vector3(0.0, 1.9, 4.9), "target": Vector3(0.0, 1.9, 0.0), "sun": Vector3(-34.0, -28.0, 0.0)},
		{"id": "02-ordinary-distance", "view_kind": "ordinary_gameplay_scale_proof", "camera": Vector3(0.0, 2.2, 11.5), "target": Vector3(0.0, 1.9, 0.0), "sun": Vector3(-34.0, -28.0, 0.0)},
		{"id": "03-changed-light-oblique", "view_kind": "changed_light_oblique_proof", "camera": Vector3(3.2, 2.4, 7.2), "target": Vector3(0.0, 1.9, 0.0), "sun": Vector3(-12.0, 118.0, 0.0)},
	]


func _capture_pose(stage: Node3D, camera: Camera3D, sun: DirectionalLight3D, output: String, pose: Dictionary) -> Dictionary:
	camera.position = pose.camera as Vector3
	camera.look_at(pose.target as Vector3, Vector3.UP)
	sun.rotation_degrees = pose.sun as Vector3
	stage.force_update_transform()
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
