extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/batch_03_material_registry.json"
const OUTPUT_ROOT := "res://evidence/first-playable/batch-03-material-prototypes-2026-08-29"
const EXPECTED_REGISTRY_SHA256 := "3967f455469e7c480c611b53a7502833f1582c5b73a5f2aa00783d71719c4139"
const EXPECTED_SHADER_SHA256 := "1918177080126199ddbfc0715a77b85a9355800479a098ec9b81c9726b7cc4d5"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const CAPTURE_SIZE := Vector2i(1440, 900)
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/batch_03_material_proof_capture.gd"
const TARGET_METADATA := {
	"r133347": {"slug": "personnel-support-detachment", "material_hash": "ec103e8a030903e17c3d863e80f6c904fafd0806b24db0385c8aac999c821692"},
	"w34313548": {"slug": "fire-training-b600", "material_hash": "5d7b9aa88a5bf287d5dbc7d5738e484786f44ae7c07449bf0a75a4384b11699d"},
	"w764313741": {"slug": "fire-station-48", "material_hash": "515135c3d0da6bb8eb8681e69d7e3f7818d896d948fe5dcc7c2bd8c6d076b188"},
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Batch 03 material proof capture requires explicit approval and the real macOS Metal renderer; headless execution is not evidence.")
		_finish(null)
		return
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Registry bytes drifted before proof capture.") \
	or not _require(FileAccess.get_sha256("res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader") == EXPECTED_SHADER_SHA256, "Shared shader bytes drifted before proof capture.") \
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
	for target_value: Variant in registry.targets:
		var target := target_value as Dictionary
		var source_key := str(target.source_key)
		if not _require(TARGET_METADATA.has(source_key), "Registry contains an unexpected Batch 03 target: %s." % source_key):
			_finish(stage)
			return
		var metadata := TARGET_METADATA[source_key] as Dictionary
		var material := load(str(target.material_path)) as ShaderMaterial
		if not _require(material != null, "Material failed to load for %s." % source_key) \
		or not _require(FileAccess.get_sha256(str(target.material_path)) == str(metadata.material_hash), "Material bytes drifted for %s." % source_key):
			_finish(stage)
			return
		panel.material_override = material
		detail.text = "%s  ·  %s\n4.8 m × 3.2 m controlled panel  ·  proof scale %.3f m\nPROTOTYPE ONLY — NOT ATTACHED IN GAME" % [str(target.canonical_name), source_key, float(target.proof_primary_scale_m)]
		var output := OUTPUT_ROOT.path_join(str(metadata.slug))
		if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
			_fail("Could not create proof directory for %s." % source_key)
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
		var target_manifest := {
			"schema_version": "ti.batch-03-material-proof-evidence/1",
			"review_status": "ready_for_independent_visual_review_not_self_accepted",
			"evidence_role": "controlled_material_prototype_not_in_game_acceptance",
			"runtime_attachment": false,
			"runtime_attachment_reason": "Exact observed material-region endpoints and physical module scale remain unreconciled.",
			"source_key": source_key,
			"receiver_key": str(target.receiver_key),
			"canonical_name": str(target.canonical_name),
			"observed_region_scope": str(target.region_scope),
			"material_path": str(target.material_path),
			"material_sha256": str(metadata.material_hash),
			"shared_shader_sha256": EXPECTED_SHADER_SHA256,
			"registry_sha256": EXPECTED_REGISTRY_SHA256,
			"generated_manifest_sha256": EXPECTED_MANIFEST_SHA256,
			"proof_receiver": "controlled_flat_proof_panel",
			"proof_panel_size_m": [4.8, 3.2, 0.12],
			"one_local_unit_m": 1.0,
			"proof_primary_scale_m": float(target.proof_primary_scale_m),
			"scale_status": str(target.scale_status),
			"contains_facade_scale_motifs": false,
			"godot_version": Engine.get_version_info().get("string", "unknown"),
			"display_driver": DisplayServer.get_name(),
			"video_adapter": RenderingServer.get_video_adapter_name(),
			"rendering_method": "Forward+",
			"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
			"capture_command": COMMAND,
			"captures": captures,
		}
		if not _write_json(output.path_join("capture-manifest.json"), target_manifest):
			_fail("Could not write capture manifest for %s." % source_key)
			_finish(stage)
			return
		print("BATCH03_PROOF_TARGET: source=%s views=%d output=%s" % [source_key, captures.size(), ProjectSettings.globalize_path(output)])
	print("PASS: captured nine Forward+/Metal controlled proof views for three prototype-only Batch 03 targets; none is live receiver or in-game acceptance evidence")
	_finish(stage)


func _make_stage() -> Node3D:
	var stage := Node3D.new()
	stage.name = "Batch03ControlledMaterialProof"
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
	backdrop.size = Vector2(1060, 132)
	overlay.add_child(backdrop)
	var title := Label.new()
	title.name = "Title"
	title.position = Vector2(48, 38)
	title.text = "CONTROLLED BATCH 03 MATERIAL PROOF"
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
	return {"ok": true, "result": {
		"id": str(pose.id),
		"view_kind": str(pose.view_kind),
		"file": filename,
		"sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_position_m": [camera.position.x, camera.position.y, camera.position.z],
		"sun_rotation_degrees": [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z],
	}}


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
