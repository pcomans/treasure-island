extends SceneTree

const OUTPUT_ROOT := "res://evidence/first-playable/genai-texture-pilot-v1-2026-09-04"
const CAPTURE_SIZE := Vector2i(1440, 900)
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/genai_texture_pilot_v1_capture.gd"
const GENERATED := {
	"stucco": {
		"texture": "res://game/resources/textures/world/genai_pilot_v1/warm_ivory_mineral_albedo_v2.png",
		"material": "res://game/resources/materials/world/genai_pilot_v1/warm_ivory_mineral_albedo_pilot.tres",
		"sha256": "af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c",
	},
	"brick": {
		"texture": "res://game/resources/textures/world/genai_pilot_v1/muted_brown_red_brick_albedo.png",
		"material": "res://game/resources/materials/world/genai_pilot_v1/muted_brown_red_brick_albedo_pilot.tres",
		"sha256": "0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d",
	},
}
const CONTROLS := {
	"stucco": "res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres",
	"brick": "res://game/resources/materials/world/isle_house/isle_house_low_brick.tres",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Native texture-pilot capture requires the macOS renderer; headless output is not visual evidence.")
		_finish(null)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT_ROOT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute) == OK, "Could not create the texture-pilot evidence directory."):
		_finish(null)
		return
	var captures: Array[Dictionary] = []
	var repeat_stage := _repeat_stage()
	root.add_child(repeat_stage)
	var repeat_capture := await _save_capture("01-generated-3x3-repeat.png", "unblended_borderless_3x3_repeat_preview")
	if not _require(bool(repeat_capture.get("ok", false)), str(repeat_capture.get("message", "Repeat capture failed."))):
		_finish(repeat_stage)
		return
	captures.append(repeat_capture.metadata as Dictionary)
	repeat_stage.queue_free()
	await process_frame

	var lab_stage := _lab_stage()
	root.add_child(lab_stage)
	var camera := lab_stage.get_node("Camera3D") as Camera3D
	var sun := lab_stage.get_node("Sun") as DirectionalLight3D
	camera.position = Vector3(0.0, 0.65, 15.5)
	camera.look_at(Vector3(0.0, 0.65, 0.0), Vector3.UP)
	sun.rotation_degrees = Vector3(-32.0, 150.0, 0.0)
	var front_capture := await _save_capture("02-real-scale-ab-front.png", "six_by_three_point_two_metre_front_ab_at_three_metre_repeat")
	if not _require(bool(front_capture.get("ok", false)), str(front_capture.get("message", "Front A/B capture failed."))):
		_finish(lab_stage)
		return
	captures.append(front_capture.metadata as Dictionary)
	camera.position = Vector3(7.6, 2.3, 16.5)
	camera.look_at(Vector3(0.0, 0.65, 0.0), Vector3.UP)
	sun.rotation_degrees = Vector3(-20.0, 112.0, 0.0)
	var oblique_capture := await _save_capture("03-real-scale-ab-oblique.png", "changed_light_oblique_ab")
	if not _require(bool(oblique_capture.get("ok", false)), str(oblique_capture.get("message", "Oblique A/B capture failed."))):
		_finish(lab_stage)
		return
	captures.append(oblique_capture.metadata as Dictionary)

	var manifest := {
		"schema_version": "ti.genai-texture-pilot-evidence/1",
		"review_status": "technical_capture_complete_bar_raiser_visual_review_pending",
		"runtime_attachment": false,
		"asset_kind": "homogeneous_material_tile_pilot",
		"one_local_unit_m": 1.0,
		"generated_repeat_dimension_m": 3.0,
		"panel_dimensions_m": [6.0, 3.2, 0.06],
		"repeat_preview": "unblended borderless 3x3; no offset repair or edge blending",
		"controls": CONTROLS,
		"generated": GENERATED,
		"pbr_scope": "albedo plus scalar roughness only; no generated, derived, or borrowed normal/roughness/AO/height maps",
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"capture_command": COMMAND,
		"captures": captures,
	}
	if not _write_json(OUTPUT_ROOT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write the texture-pilot capture manifest.")
		_finish(lab_stage)
		return
	print("PASS: captured one unblended 3x3 repeat proof plus front and changed-light A/B material-lab views; the two generated albedos remain isolated from live runtime and await bar-raiser review")
	_finish(lab_stage)


func _repeat_stage() -> Node:
	var stage := Node.new()
	stage.name = "GenAITexturePilotRepeatProof"
	var canvas := CanvasLayer.new()
	stage.add_child(canvas)
	var backdrop := ColorRect.new()
	backdrop.color = Color("171b20")
	backdrop.size = Vector2(CAPTURE_SIZE)
	canvas.add_child(backdrop)
	var title := Label.new()
	title.position = Vector2(56, 28)
	title.text = "GENAI MATERIAL PILOT · UNBLENDED 3×3 REPEAT"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("f3d277"))
	canvas.add_child(title)
	var subtitle := Label.new()
	subtitle.position = Vector2(56, 68)
	subtitle.text = "Each source tile is shown nine times with no offset repair, edge blending, or boundary mask."
	subtitle.add_theme_font_size_override("font_size", 17)
	subtitle.add_theme_color_override("font_color", Color("d7dce2"))
	canvas.add_child(subtitle)
	_add_repeat_grid(canvas, load(str(GENERATED.stucco.texture)) as Texture2D, Vector2(56, 142), "WARM IVORY MINERAL · 3 m assumed tile")
	_add_repeat_grid(canvas, load(str(GENERATED.brick.texture)) as Texture2D, Vector2(756, 142), "MUTED BROWN-RED BRICK · 3 m assumed tile")
	return stage


func _add_repeat_grid(parent: Node, texture: Texture2D, origin: Vector2, label_text: String) -> void:
	var label := Label.new()
	label.position = origin - Vector2(0, 34)
	label.text = label_text
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color("f1f3f5"))
	parent.add_child(label)
	const TILE_PX := 200.0
	for row in 3:
		for column in 3:
			var tile := TextureRect.new()
			tile.position = origin + Vector2(column * TILE_PX, row * TILE_PX)
			tile.size = Vector2(TILE_PX, TILE_PX)
			tile.texture = texture
			tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tile.stretch_mode = TextureRect.STRETCH_SCALE
			parent.add_child(tile)


func _lab_stage() -> Node3D:
	var stage := Node3D.new()
	stage.name = "GenAITexturePilotMaterialLab"
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("29313a")
	environment.background_energy_multiplier = 0.72
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("aab4be")
	environment.ambient_light_energy = 0.62
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	world_environment.environment = environment
	stage.add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = Color("fff2df")
	sun.light_energy = 1.18
	sun.shadow_enabled = true
	stage.add_child(sun)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.current = true
	camera.fov = 49.0
	stage.add_child(camera)
	_add_panel(stage, "StuccoCurrentControl", Vector3(-3.15, 2.35, 0.0), load(str(CONTROLS.stucco)) as Material)
	_add_panel(stage, "StuccoGeneratedPilot", Vector3(3.15, 2.35, 0.0), load(str(GENERATED.stucco.material)) as Material)
	_add_panel(stage, "BrickCurrentControl", Vector3(-3.15, -1.25, 0.0), load(str(CONTROLS.brick)) as Material)
	_add_panel(stage, "BrickGeneratedPilot", Vector3(3.15, -1.25, 0.0), load(str(GENERATED.brick.material)) as Material)
	var overlay := CanvasLayer.new()
	var overlay_backdrop := ColorRect.new()
	overlay_backdrop.position = Vector2(20, 18)
	overlay_backdrop.size = Vector2(1400, 90)
	overlay_backdrop.color = Color(0.015, 0.02, 0.025, 0.88)
	overlay.add_child(overlay_backdrop)
	var title := Label.new()
	title.position = Vector2(42, 30)
	title.text = "GENAI MATERIAL PILOT · CURRENT CONTROL → GENERATED ALBEDO"
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color("f3d277"))
	overlay.add_child(title)
	var detail := Label.new()
	detail.position = Vector2(42, 66)
	detail.text = "TOP: Building 1 warm-ivory procedural control   |   BOTTOM: Isle House flat-brick control   ·   6.0 × 3.2 m panels   ·   3.0 m generated repeat   ·   PILOT ONLY / NOT LIVE"
	detail.add_theme_font_size_override("font_size", 15)
	detail.add_theme_color_override("font_color", Color("edf0f3"))
	overlay.add_child(detail)
	stage.add_child(overlay)
	return stage


func _add_panel(parent: Node3D, node_name: String, position_value: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.mesh = _meter_panel_mesh(Vector2(6.0, 3.2))
	mesh_instance.material_override = material
	mesh_instance.position = position_value
	parent.add_child(mesh_instance)


func _meter_panel_mesh(size: Vector2) -> ArrayMesh:
	var half := size * 0.5
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		Vector3(-half.x, -half.y, 0.0), Vector3(half.x, -half.y, 0.0),
		Vector3(half.x, half.y, 0.0), Vector3(-half.x, half.y, 0.0),
	])
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array([Vector3.FORWARD, Vector3.FORWARD, Vector3.FORWARD, Vector3.FORWARD])
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array([Vector2(0.0, size.y), Vector2(size.x, size.y), Vector2(size.x, 0.0), Vector2.ZERO])
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 2, 1, 0, 3, 2])
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _save_capture(filename: String, view_kind: String) -> Dictionary:
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s produced an empty or wrong-sized image." % filename}
	var path := OUTPUT_ROOT.path_join(filename)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "Could not save %s." % path}
	return {"ok": true, "metadata": {
		"file": filename,
		"view_kind": view_kind,
		"sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
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
	push_error("FAIL [genai_texture_pilot_v1_capture]: %s" % message)


func _finish(stage: Node) -> void:
	if stage != null:
		stage.queue_free()
	quit(1 if _failed else 0)
