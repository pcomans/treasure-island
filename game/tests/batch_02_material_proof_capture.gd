extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/batch_02_material_registry.json"
const OUTPUT_ROOT := "res://evidence/first-playable/batch-02-material-prototypes-2026-08-29"
const EXPECTED_REGISTRY_SHA256 := "ff879daa15726fff144eba798ba87dace0a79debb7199375d84764107572c0b2"
const EXPECTED_SHADER_SHA256 := "1918177080126199ddbfc0715a77b85a9355800479a098ec9b81c9726b7cc4d5"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const CAPTURE_SIZE := Vector2i(1440, 900)
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/batch_02_material_proof_capture.gd"
const TIMEOUT_SECONDS := 180.0
const TARGET_METADATA := {
	"w24274434": {"slug": "building-2", "material_hash": "e936dc561b653e43eafdef633dc2260c7489a713b5d8da5521b5b118a9b8f8a9"},
	"w1272162518": {"slug": "490-avenue-of-the-palms", "material_hash": "76ae45e057f1d6502c09c6a937d45256c388ee01a67c450a249dffce82cbce39"},
	"w1212173437": {"slug": "star-view-court", "material_hash": "c7cd8fc95b76539a9bf20d6aa05cba5b494efdbb27ff93ba74a9a0077f60dc9c"},
	"r19685981": {"slug": "maceo-may", "material_hash": "da68584fa85647d611f825743e3e58164133b51312199fd7955267bc047721bf"},
	"w291189336": {"slug": "navy-chapel-187", "material_hash": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5"},
	"w34313547": {"slug": "treasure-island-community-ymca", "material_hash": "3d79421c1aa5f922395235a5c9105c29dd184340a619d7875414f6dc3b988309"},
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Batch 02 material proof capture requires the real macOS display renderer.")
		_finish(null)
		return
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Registry bytes drifted before proof capture.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated manifest bytes drifted before proof capture."):
		_finish(null)
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var stage := _make_stage()
	root.add_child(stage)
	var panel := stage.get_node("ProofPanel") as MeshInstance3D
	var camera := stage.get_node("Camera3D") as Camera3D
	var sun := stage.get_node("Sun") as DirectionalLight3D
	var title := stage.get_node("ProofOverlay/Title") as Label
	var detail := stage.get_node("ProofOverlay/Detail") as Label
	for target_value: Variant in registry.targets:
		var target := target_value as Dictionary
		var source_key := str(target.source_key)
		if not TARGET_METADATA.has(source_key):
			_fail("Registry contains an unexpected target during proof capture: %s." % source_key)
			_finish(stage)
			return
		var target_meta := TARGET_METADATA[source_key] as Dictionary
		var material := load(str(target.material_path)) as ShaderMaterial
		if not _require(material != null, "Material failed to load for %s." % source_key) \
		or not _require(FileAccess.get_sha256(str(target.material_path)) == str(target_meta.material_hash), "Material bytes drifted for %s." % source_key):
			_finish(stage)
			return
		panel.material_override = material
		title.text = "CONTROLLED MATERIAL PROOF — NOT ATTACHED IN GAME"
		detail.text = "%s  ·  %s\n4.8 m × 3.2 m proof panel  ·  proof scale %.3f m  ·  %s" % [str(target.canonical_name), source_key, float(target.proof_primary_scale_m), str(target.scale_status)]
		var output := OUTPUT_ROOT.path_join(str(target_meta.slug))
		if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
			_fail("Could not create material proof evidence directory for %s." % source_key)
			_finish(stage)
			return
		var captures: Array[Dictionary] = []
		var pose_result := await _capture_pose(stage, camera, sun, output, "01-close", "close_material_proof", Vector3(0.0, 1.9, 4.9), Vector3(0.0, 1.9, 0.0), Vector3(-34.0, -28.0, 0.0))
		if not _append_capture(captures, pose_result):
			_finish(stage)
			return
		pose_result = await _capture_pose(stage, camera, sun, output, "02-ordinary-distance", "ordinary_gameplay_scale_proof", Vector3(0.0, 2.2, 11.5), Vector3(0.0, 1.9, 0.0), Vector3(-34.0, -28.0, 0.0))
		if not _append_capture(captures, pose_result):
			_finish(stage)
			return
		pose_result = await _capture_pose(stage, camera, sun, output, "03-changed-light-oblique", "changed_light_oblique_proof", Vector3(3.2, 2.4, 7.2), Vector3(0.0, 1.9, 0.0), Vector3(-12.0, 118.0, 0.0))
		if not _append_capture(captures, pose_result):
			_finish(stage)
			return
		var target_manifest := {
			"schema_version": "ti.batch-02-material-proof-evidence/1",
			"review_status": "ready_for_independent_review_not_self_accepted",
			"evidence_role": "controlled_material_prototype_not_in_game_acceptance",
			"runtime_attachment": false,
			"runtime_attachment_reason": "Exact observed material-region endpoints and/or physical scale remain unreconciled in the target reference spec.",
			"source_key": source_key,
			"receiver_key": str(target.receiver_key),
			"canonical_name": str(target.canonical_name),
			"observed_region_scope": str(target.region_scope),
			"material_path": str(target.material_path),
			"material_sha256": str(target_meta.material_hash),
			"shared_shader_path": "res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader",
			"shared_shader_sha256": EXPECTED_SHADER_SHA256,
			"registry_path": REGISTRY_PATH,
			"registry_sha256": EXPECTED_REGISTRY_SHA256,
			"generated_manifest_sha256": EXPECTED_MANIFEST_SHA256,
			"proof_receiver": "controlled_flat_proof_panel",
			"proof_panel_size_m": [4.8, 3.2, 0.12],
			"one_local_unit_m": 1.0,
			"proof_primary_scale_m": float(target.proof_primary_scale_m),
			"scale_status": str(target.scale_status),
			"scale_truth_status": "reversible_proof_assumption_not_observed_measurement",
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
			_fail("Could not write material proof manifest for %s." % source_key)
			_finish(stage)
			return
		print("BATCH02_PROOF_TARGET: source=%s views=%d output=%s" % [source_key, captures.size(), ProjectSettings.globalize_path(output)])
	print("PASS: captured eighteen Forward+/Metal controlled material proof views for six prototype-only Batch 02 targets; none is presented as a live receiver or in-game acceptance")
	_finish(stage)


func _make_stage() -> Node3D:
	var stage := Node3D.new()
	stage.name = "Batch02ControlledMaterialProof"
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
	var panel_overlay := ColorRect.new()
	panel_overlay.name = "Backdrop"
	panel_overlay.color = Color(0.02, 0.025, 0.03, 0.86)
	panel_overlay.position = Vector2(28, 24)
	panel_overlay.size = Vector2(920, 104)
	overlay.add_child(panel_overlay)
	var title := Label.new()
	title.name = "Title"
	title.position = Vector2(48, 38)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("f4d56c"))
	overlay.add_child(title)
	var detail := Label.new()
	detail.name = "Detail"
	detail.position = Vector2(48, 70)
	detail.add_theme_font_size_override("font_size", 17)
	detail.add_theme_color_override("font_color", Color("f0f2f4"))
	overlay.add_child(detail)
	stage.add_child(overlay)
	return stage


func _capture_pose(stage: Node3D, camera: Camera3D, sun: DirectionalLight3D, output: String, id: String, view_kind: String, camera_position: Vector3, target: Vector3, sun_rotation: Vector3) -> Dictionary:
	camera.position = camera_position
	camera.look_at(target, Vector3.UP)
	sun.rotation_degrees = sun_rotation
	stage.force_update_transform()
	camera.force_update_transform()
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s produced an empty or wrong-sized image." % id}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 24 or float(sample.luminance_range) < 0.08:
		return {"ok": false, "message": "%s appears blank or materially uninformative." % id}
	var filename := "%s.png" % id
	var path := output.path_join(filename)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % id}
	var metadata := {
		"id": id,
		"view_kind": view_kind,
		"file": filename,
		"sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_position_m": [camera.position.x, camera.position.y, camera.position.z],
		"aim_target_m": [target.x, target.y, target.z],
		"camera_fov_degrees": camera.fov,
		"sun_rotation_degrees": [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z],
		"sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range),
		"proof_receiver_only": true,
	}
	print("BATCH02_PROOF_VIEW: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
	return {"ok": true, "metadata": metadata}


func _append_capture(captures: Array[Dictionary], result: Dictionary) -> bool:
	if not bool(result.get("ok", false)):
		_fail(str(result.get("message", "Material proof capture failed.")))
		return false
	captures.append((result.metadata as Dictionary).duplicate(true))
	return true


func _sample_image(image: Image) -> Dictionary:
	var colors := {}
	var minimum := 1.0
	var maximum := 0.0
	for sample_y in 24:
		var y := mini(image.get_height() - 1, int((float(sample_y) + 0.5) * image.get_height() / 24.0))
		for sample_x in 36:
			var x := mini(image.get_width() - 1, int((float(sample_x) + 0.5) * image.get_width() / 36.0))
			var color := image.get_pixel(x, y)
			colors[color.to_rgba32()] = true
			minimum = minf(minimum, color.get_luminance())
			maximum = maxf(maximum, color.get_luminance())
	return {"unique_colors": colors.size(), "luminance_range": maximum - minimum}


func _write_json(path: String, payload: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload, "  ", false) + "\n")
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
	push_error("BATCH02_PROOF_FAIL: %s" % message)


func _on_timeout() -> void:
	if not _finished:
		_fail("Capture timed out after %.0f seconds." % TIMEOUT_SECONDS)
		_finished = true
		quit(1)


func _finish(stage: Node) -> void:
	if _finished:
		return
	_finished = true
	if stage != null and is_instance_valid(stage):
		stage.queue_free()
		await process_frame
	quit(0 if _failure.is_empty() else 1)
