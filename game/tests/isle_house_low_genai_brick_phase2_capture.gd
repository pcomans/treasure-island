extends SceneTree

const OUTPUT := "res://evidence/first-playable/isle-house-low-genai-brick-phase2-2026-09-04"
const CONFIG_PATH := "res://game/resources/facades/isle_house_39_bruton_low_facade_prototype.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const SCENE_PATH := "res://game/scenes/world/facades/isle_house/isle_house_low_facade_prototype.tscn"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const LOW_ROOF_KEY := "building-composite:w1249412094:w1282547787:roof"
const FIELD_NODE := "ObservedPublicLiveWorkBrickFields_Runs_0_9"
const CONTROL_MATERIAL := "res://game/resources/materials/world/isle_house/isle_house_low_brick.tres"
const GENERATED_MATERIAL := "res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres"
const GENERATED_TEXTURE := "res://game/resources/textures/world/facade_shared_v1/muted_brown_red_brick_albedo_v1.png"
const UV_HELPER := "res://game/scripts/world/facades/facade_meter_uv_adapter.gd"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 240.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/isle_house_low_genai_brick_phase2_capture.gd"
const SIDE_ID := "LOW-WSW-AVENUE-OF-THE-PALMS"

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Phase 2 brick receiver evidence requires the native macOS renderer.")
		_finish(null)
		return
	var config_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	var chunk_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	if not _require(config_value is Dictionary and chunk_value is Dictionary, "Could not parse Phase 2 capture inputs."):
		_finish(null)
		return
	var config := config_value as Dictionary
	var chunk := chunk_value as Dictionary
	var low_wall := _record_for_key(chunk.get("records", []) as Array, LOW_WALL_KEY)
	var low_roof := _record_for_key(chunk.get("records", []) as Array, LOW_ROOF_KEY)
	if not _require(not low_wall.is_empty() and not low_roof.is_empty(), "Could not resolve the exact Isle House low wall/roof capture receiver."):
		_finish(null)
		return
	var packed := load(SCENE_PATH) as PackedScene
	if not _require(packed != null, "Could not load the standalone Isle House low prototype scene."):
		_finish(null)
		return
	var prototype := packed.instantiate() as IsleHouse39BrutonLowFacadePrototype
	var configured := prototype.configure(low_wall)
	if not _require(bool(configured.get("ok", false)), str(configured.get("message", "Standalone prototype refused exact low wall."))):
		prototype.free()
		_finish(null)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images/motion")) == OK, "Could not create Phase 2 capture directories."):
		prototype.free()
		_finish(null)
		return
	var stage := _make_stage(low_wall, low_roof, prototype)
	root.add_child(stage)
	var camera := stage.get_node("Camera3D") as Camera3D
	var fields := prototype.get_node_or_null(FIELD_NODE) as MeshInstance3D
	var label := stage.get_node("CaptureOverlay/Panel/Label") as Label
	if not _require(fields != null and camera != null and label != null, "Phase 2 capture stage is incomplete.") \
	or not _require(_prototype_contract_matches(prototype, fields), "Standalone prototype lost its UV/material/zero-ownership contract before capture."):
		_finish(stage)
		return

	var captures: Array[Dictionary] = []
	var control := load(CONTROL_MATERIAL) as Material
	var front_pose := _pose(config, 29.0, 31.0, 0.0, 6.5, 7.25)
	fields.material_override = control
	label.text = "ISLE HOUSE LOW · CONTROL · FLAT SCALAR BRICK FIELD · FIXED WSW FRONT"
	_apply_pose(camera, front_pose)
	var flat_front := await _save_capture("images/01-flat-front.png", "flat_control_fixed_front", front_pose, fields)
	if not _require(bool(flat_front.get("ok", false)), str(flat_front.get("message", "Flat front capture failed."))):
		_finish(stage)
		return
	captures.append(flat_front.metadata as Dictionary)

	fields.material_override = null
	label.text = "ISLE HOUSE LOW · PHASE 2 · PROMOTED BRICK ALBEDO · 2.5 m CELL · FIXED WSW FRONT"
	var generated_front := await _save_capture("images/02-generated-front.png", "generated_fixed_front", front_pose, fields)
	if not _require(bool(generated_front.get("ok", false)), str(generated_front.get("message", "Generated front capture failed."))):
		_finish(stage)
		return
	captures.append(generated_front.metadata as Dictionary)

	var oblique_pose := _pose(config, 29.0, 28.0, -17.0, 8.4, 7.4)
	fields.material_override = control
	label.text = "ISLE HOUSE LOW · CONTROL · FLAT SCALAR BRICK FIELD · FIXED WSW OBLIQUE"
	_apply_pose(camera, oblique_pose)
	var flat_oblique := await _save_capture("images/03-flat-oblique.png", "flat_control_fixed_oblique", oblique_pose, fields)
	if not _require(bool(flat_oblique.get("ok", false)), str(flat_oblique.get("message", "Flat oblique capture failed."))):
		_finish(stage)
		return
	captures.append(flat_oblique.metadata as Dictionary)

	fields.material_override = null
	label.text = "ISLE HOUSE LOW · PHASE 2 · PROMOTED BRICK ALBEDO · 2.5 m CELL · FIXED WSW OBLIQUE"
	var generated_oblique := await _save_capture("images/04-generated-oblique.png", "generated_fixed_oblique", oblique_pose, fields)
	if not _require(bool(generated_oblique.get("ok", false)), str(generated_oblique.get("message", "Generated oblique capture failed."))):
		_finish(stage)
		return
	captures.append(generated_oblique.metadata as Dictionary)

	var motion_captures: Array[Dictionary] = []
	for frame_index in 9:
		var chain_u_m := 20.0 + float(frame_index) * 1.25
		var motion_pose := _pose(config, chain_u_m, 16.0, 0.0, 6.25, 7.15)
		label.text = "ISLE HOUSE LOW · NATIVE MOTION SAMPLE %02d/09 · PARALLEL WALK · U %.2f m · 2.5 m CELL" % [frame_index + 1, chain_u_m]
		_apply_pose(camera, motion_pose)
		var relative := "images/motion/05-generated-walk-%02d.png" % frame_index
		var saved := await _save_capture(relative, "generated_parallel_walk_sample", motion_pose, fields)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Motion capture failed."))):
			_finish(stage)
			return
		motion_captures.append(saved.metadata as Dictionary)

	var package_before_bytes := _file_size("res://build/phase2-package-audit-before.pck")
	var package_after_bytes := _file_size("res://build/phase2-package-audit-after.pck")
	var manifest := {
		"schema_version": "ti.isle-house-low-genai-brick-phase2-evidence/1",
		"review_status": "technical_capture_complete_visual_verdict_pending_bar_raiser_review",
		"evidence_role": "native standalone exact-receiver A/B and sampled motion diagnostic; not live-world or player acceptance",
		"runtime_attachment": false,
		"target_receiver": LOW_WALL_KEY,
		"mapped_run_scope": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
		"fixed_pair_side": SIDE_ID,
		"control_material": CONTROL_MATERIAL,
		"generated_material": GENERATED_MATERIAL,
		"generated_texture": GENERATED_TEXTURE,
		"generated_texture_sha256": FileAccess.get_sha256(GENERATED_TEXTURE),
		"uv_helper": UV_HELPER,
		"uv_helper_sha256": FileAccess.get_sha256(UV_HELPER),
		"field_material": {
			"cell_m": 2.5,
			"tint": [0.70, 0.66, 0.62, 1.0],
			"scalar_roughness": 0.86,
			"maps": ["albedo"],
			"module_piers": "existing scalar brick retained because normalized BoxMesh UVs do not preserve metre scale; geometry and batching unchanged",
		},
		"uv_contract": prototype.get_meta("field_uv_contract", {}),
		"side_chain_totals_m": prototype.get_meta("field_side_chain_totals_m", {}),
		"motion_protocol": {
			"kind": "native Forward+/Metal sampled camera path parallel to WSW public facade",
			"frame_count": motion_captures.size(),
			"step_m": 1.25,
			"outward_distance_m": 16.0,
			"purpose": ["shimmer", "moire", "run seams", "texture cadence", "architectural contrast"],
			"not_claimed": "not a physics/player traversal and not connected to the live world builder",
		},
		"package_audit": {
			"export_filter": "all_resources with isolated genai_pilot_v1 texture/material directories excluded",
			"before_bytes": package_before_bytes,
			"after_bytes": package_after_bytes,
			"delta_bytes": package_after_bytes - package_before_bytes,
			"before_sha256": FileAccess.get_sha256("res://build/phase2-package-audit-before.pck"),
			"after_sha256": FileAccess.get_sha256("res://build/phase2-package-audit-after.pck"),
			"mounted_contract": "headless_genai_texture_phase2_package_contract.gd -- --mounted",
		},
		"prototype_topology_unchanged": {
			"field_segments": 10,
			"field_triangles": 20,
			"module_boxes": 152,
			"module_triangles": 1824,
			"total_visual_triangles": 1844,
			"collision_nodes": 0,
			"navigation_nodes": 0,
			"spray_nodes": 0,
		},
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"capture_command": COMMAND,
		"fixed_captures": captures,
		"motion_captures": motion_captures,
		"reviewer_instruction": "Inspect fixed A/B pairs and all motion samples at original detail. Judge distracting seams, shimmer/moire, oversized cadence, noise, module/field contrast, and whether the brick makes the low public facade more believable. Technical capture is not self-acceptance.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write Phase 2 capture manifest.")
		_finish(stage)
		return
	print("PASS: captured fixed front/oblique A/B plus %d native sampled motion frames for the standalone Isle House low promoted-brick receiver; bar-raiser visual verdict remains pending" % motion_captures.size())
	_finish(stage)


func _make_stage(low_wall: Dictionary, low_roof: Dictionary, prototype: Node3D) -> Node3D:
	var stage := Node3D.new()
	stage.name = "IsleHouseLowGenAIBrickPhase2Capture"
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("82909a")
	environment.background_energy_multiplier = 0.75
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b8c2c7")
	environment.ambient_light_energy = 0.62
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	world_environment.environment = environment
	stage.add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-31.0, 144.0, 0.0)
	sun.light_color = Color("fff2dc")
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	stage.add_child(sun)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.current = true
	camera.fov = 49.0
	camera.near = 0.1
	camera.far = 1000.0
	stage.add_child(camera)
	var receiver_material := StandardMaterial3D.new()
	receiver_material.albedo_color = Color(0.46, 0.44, 0.40, 1.0)
	receiver_material.roughness = 0.9
	_add_record_mesh(stage, "ExactLowWallReceiver", low_wall, receiver_material)
	var roof_material := StandardMaterial3D.new()
	roof_material.albedo_color = Color(0.24, 0.25, 0.25, 1.0)
	roof_material.roughness = 0.88
	_add_record_mesh(stage, "ExactLowRoofReceiver", low_roof, roof_material)
	stage.add_child(prototype)
	var ground := MeshInstance3D.new()
	ground.name = "DiagnosticGround"
	var plane := PlaneMesh.new()
	plane.size = Vector2(190.0, 180.0)
	var ground_material := StandardMaterial3D.new()
	ground_material.albedo_color = Color(0.30, 0.34, 0.29, 1.0)
	ground_material.roughness = 0.96
	plane.material = ground_material
	ground.mesh = plane
	ground.position = Vector3(-126.0, 3.89, 516.0)
	stage.add_child(ground)
	var overlay := CanvasLayer.new()
	overlay.name = "CaptureOverlay"
	var panel := ColorRect.new()
	panel.name = "Panel"
	panel.position = Vector2(18, 18)
	panel.size = Vector2(1404, 62)
	panel.color = Color(0.018, 0.022, 0.026, 0.88)
	overlay.add_child(panel)
	var label := Label.new()
	label.name = "Label"
	label.position = Vector2(22, 17)
	label.add_theme_font_size_override("font_size", 21)
	label.add_theme_color_override("font_color", Color("f3d277"))
	panel.add_child(label)
	stage.add_child(overlay)
	return stage


func _add_record_mesh(parent: Node3D, node_name: String, record: Dictionary, material: Material) -> void:
	var raw_vertices := record.get("vertices", []) as Array
	var raw_normals := record.get("normals", []) as Array
	var raw_indices := record.get("indices", []) as Array
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	for offset in range(0, raw_vertices.size(), 3):
		vertices.append(Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2])))
	for offset in range(0, raw_normals.size(), 3):
		normals.append(Vector3(float(raw_normals[offset]), float(raw_normals[offset + 1]), float(raw_normals[offset + 2])))
	for value: Variant in raw_indices:
		indices.append(int(value))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)


func _pose(config: Dictionary, side_u_m: float, outward_distance_m: float, tangent_offset_m: float, camera_y_m: float, target_y_m: float) -> Dictionary:
	var side := _side(config, SIDE_ID)
	var ordered := side.get("ordered_run_indices", []) as Array
	var runs := config.get("runs", []) as Array
	var target := _point_on_chain(runs, ordered, side_u_m)
	target.y = target_y_m
	var first_run := runs[int(ordered[0])] as Dictionary
	var last_run := runs[int(ordered[ordered.size() - 1])] as Dictionary
	var first_values := first_run.get("start_xyz_m", []) as Array
	var last_values := last_run.get("end_xyz_m", []) as Array
	var chain_start := Vector3(float(first_values[0]), 0.0, float(first_values[2]))
	var chain_end := Vector3(float(last_values[0]), 0.0, float(last_values[2]))
	var tangent := (chain_end - chain_start).normalized()
	var normal_values := side.get("normal_xz", []) as Array
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	var camera_position := Vector3(target.x, camera_y_m, target.z) + normal * outward_distance_m + tangent * tangent_offset_m
	return {
		"side_id": SIDE_ID,
		"side_u_m": side_u_m,
		"outward_distance_m": outward_distance_m,
		"tangent_offset_m": tangent_offset_m,
		"camera": camera_position,
		"target": target,
	}


func _apply_pose(camera: Camera3D, pose: Dictionary) -> void:
	camera.global_position = pose.get("camera", Vector3.ZERO) as Vector3
	camera.look_at(pose.get("target", Vector3.ZERO) as Vector3, Vector3.UP)


func _point_on_chain(runs: Array, ordered: Array, requested_u_m: float) -> Vector3:
	var remaining := requested_u_m
	for order_index in ordered.size():
		var run := runs[int(ordered[order_index])] as Dictionary
		var start_values := run.get("start_xyz_m", []) as Array
		var end_values := run.get("end_xyz_m", []) as Array
		var start := Vector3(float(start_values[0]), float(start_values[1]), float(start_values[2]))
		var end := Vector3(float(end_values[0]), float(end_values[1]), float(end_values[2]))
		var length := Vector2(start.x, start.z).distance_to(Vector2(end.x, end.z))
		if remaining <= length or order_index == ordered.size() - 1:
			return start.lerp(end, clampf(remaining / length, 0.0, 1.0))
		remaining -= length
	return Vector3.ZERO


func _side(config: Dictionary, side_id: String) -> Dictionary:
	for side_value: Variant in config.get("side_groups", []) as Array:
		var side := side_value as Dictionary
		if str(side.get("id", "")) == side_id:
			return side
	return {}


func _prototype_contract_matches(prototype: Node3D, fields: MeshInstance3D) -> bool:
	var material := fields.mesh.surface_get_material(0) as StandardMaterial3D
	return str(fields.get_meta("field_material_path", "")) == GENERATED_MATERIAL \
		and str((fields.get_meta("uv_contract", {}) as Dictionary).get("contract_version", "")) == "ti.facade-meter-uv/1" \
		and (fields.mesh.surface_get_arrays(0) as Array)[Mesh.ARRAY_TEX_UV].size() == 40 \
		and material != null \
		and material.albedo_texture != null \
		and material.albedo_texture.resource_path == GENERATED_TEXTURE \
		and material.uv1_scale == Vector3(0.4, 0.4, 1.0) \
		and is_equal_approx(material.roughness, 0.86) \
		and material.albedo_color == Color(0.70, 0.66, 0.62, 1.0) \
		and _count_type(prototype, CollisionObject3D) == 0 \
		and _count_type(prototype, CollisionShape3D) == 0 \
		and _count_type(prototype, NavigationRegion3D) == 0 \
		and int(prototype.get_meta("field_triangle_count", 0)) == 20 \
		and int(prototype.get_meta("module_count", 0)) == 8 \
		and prototype.get_meta("module_box_counts", {}) == {"brick": 24, "frame": 88, "glass": 32, "patio": 8}


func _save_capture(relative_path: String, view_kind: String, pose: Dictionary, fields: MeshInstance3D) -> Dictionary:
	for _frame in 2:
		await process_frame
		await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s produced an empty or wrong-sized image." % relative_path}
	var sample := _sample_image(image)
	if int(sample.get("unique_colors", 0)) < 16 or float(sample.get("luminance_range", 0.0)) < 0.12:
		return {"ok": false, "message": "%s appears blank or materially unlit." % relative_path}
	var path := OUTPUT.path_join(relative_path)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "Could not save %s." % path}
	var material := fields.material_override if fields.material_override != null else fields.mesh.surface_get_material(0)
	var metadata := {
		"file": relative_path,
		"view_kind": view_kind,
		"field_material": (material as Material).resource_path,
		"side_id": str(pose.get("side_id", "")),
		"side_u_m": float(pose.get("side_u_m", 0.0)),
		"outward_distance_m": float(pose.get("outward_distance_m", 0.0)),
		"tangent_offset_m": float(pose.get("tangent_offset_m", 0.0)),
		"camera_position_m": _vector(pose.get("camera", Vector3.ZERO) as Vector3),
		"target_position_m": _vector(pose.get("target", Vector3.ZERO) as Vector3),
		"dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"sha256": FileAccess.get_sha256(path),
		"sample_unique_colors": int(sample.get("unique_colors", 0)),
		"sample_luminance_range": float(sample.get("luminance_range", 0.0)),
	}
	print("PHASE2_BRICK_CAPTURE: %s %s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
	return {"ok": true, "metadata": metadata}


func _sample_image(image: Image) -> Dictionary:
	var colors: Dictionary = {}
	var minimum := 1.0
	var maximum := 0.0
	for sample_y in 20:
		var y := mini(image.get_height() - 1, int((float(sample_y) + 0.5) * image.get_height() / 20.0))
		for sample_x in 32:
			var x := mini(image.get_width() - 1, int((float(sample_x) + 0.5) * image.get_width() / 32.0))
			var color := image.get_pixel(x, y)
			colors[color.to_rgba32()] = true
			minimum = minf(minimum, color.get_luminance())
			maximum = maxf(maximum, color.get_luminance())
	return {"unique_colors": colors.size(), "luminance_range": maximum - minimum}


func _record_for_key(records: Array, object_key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == object_key:
			return record
	return {}


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _file_size(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return -1
	var size := file.get_length()
	file.close()
	return size


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true


func _vector(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error("FAIL [isle_house_low_genai_brick_phase2_capture]: %s" % message)


func _finish(stage: Node) -> void:
	if _finished:
		return
	_finished = true
	if stage != null and is_instance_valid(stage):
		stage.queue_free()
	quit(1 if not _failure.is_empty() else 0)


func _on_timeout() -> void:
	if _finished:
		return
	_fail("Phase 2 brick capture timed out.")
	_finish(null)
