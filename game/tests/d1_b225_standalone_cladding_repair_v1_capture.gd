extends SceneTree

const CONFIG_PATH := "res://game/resources/facades/d1_current/repairs/d1_b225_nnw_long_cladding_repair_v1.json"
const CANDIDATE_SCENE_PATH := "res://game/scenes/world/facades/d1_current/repairs/d1_b225_standalone_cladding_repair_v1.tscn"
const CANDIDATE_FACTORY_PATH := "res://game/scripts/world/facades/d1_b225_standalone_cladding_repair_v1.gd"
const UV_HELPER_PATH := "res://game/scripts/world/facades/d1_b225_cumulative_meter_uv_v1.gd"
const MATERIAL_PATH := "res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres"
const TEXTURE_PATH := "res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png"
const CONTROL_SCENE_PATH := "res://game/scenes/world/facades/d1_current/d1_current_standalone_prototype_pair.tscn"
const CONTROL_FACTORY_PATH := "res://game/scripts/world/facades/d1_current_standalone_prototypes.gd"
const B201_CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b201_public_wsw.json"
const OUTPUT_ROOT := "res://evidence/first-playable/d1-b225-standalone-cladding-repair-v1-2026-09-04"
const CAPTURE_SIZE := Vector2i(1440, 900)
const WIDTH_M := 46.261968372
const RUN_BOUNDARIES_U_M: Array[float] = [10.372629078, 16.883522872, 23.933383083]
const EXPECTED_CONTROL_FACTORY_SHA256 := "797bbb81e7f772f3fab3989d358772be4f1b16cb7e31a05571463e0d6ec31a5e"
const EXPECTED_CONTROL_SCENE_SHA256 := "0fdd5d356deb57664549db95fd04e123290c1fb9490b8024569e997616893d7f"
const EXPECTED_B201_CONFIG_SHA256 := "3d53efbb0577c9b5e52a2ada4d79a710b95e41faead0bdcdd41cd4f2d862a0fe"
const EXPECTED_TEXTURE_SHA256 := "63e755e9fe5a5dcfb662b4265f1e769fc1b371987b55579b1ca4ffb63015015b"
const EXPECTED_CONFIG_SHA256 := "89d34d33b48c93c0a6c90d46ff8120cd36c5f897ebe1fc9ea2ee2cd97a3db22c"
const EXPECTED_CANDIDATE_SCENE_SHA256 := "008669d9e0c2e04801ee8d720976e72e2041c82188c7fd14fe075ad48cb69914"
const EXPECTED_CANDIDATE_FACTORY_SHA256 := "8c06afec4835441ec386251e700cc7ba91b8fea9fe070549561e401aa530d58e"
const EXPECTED_UV_HELPER_SHA256 := "20d0f597ef0a49f85a0b8062d01186c7ad13262592f99a7f630be06938cd7dc2"
const EXPECTED_MATERIAL_SHA256 := "7fa7f3165dee560c48f5a092f317900b87b0876f27bb6a0e937b9c406a8d4ea1"
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/d1_b225_standalone_cladding_repair_v1_capture.gd"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("B225 superseding evidence requires native macOS Forward+/Metal; headless screenshots are forbidden.")
		_finish(null)
		return
	if not _bytes_are_bound():
		_finish(null)
		return
	var control_packed := load(CONTROL_SCENE_PATH) as PackedScene
	var candidate_packed := load(CANDIDATE_SCENE_PATH) as PackedScene
	if not _require(control_packed != null and candidate_packed != null, "Control or candidate scene failed to load."):
		_finish(null)
		return
	var stage := _make_stage()
	root.add_child(stage)
	var control := control_packed.instantiate() as Node3D
	control.name = "SealedRejectedControl"
	stage.add_child(control)
	var candidate := candidate_packed.instantiate() as Node3D
	candidate.name = "B225CladdingRepairCandidate"
	stage.add_child(candidate)
	await process_frame
	var b201 := control.get_node_or_null("B201_w34313545") as Node3D
	var old_b225 := control.get_node_or_null("B225_w95934119") as Node3D
	var new_b225 := candidate.get_node_or_null("B225_w95934119_CladdingRepairV1") as Node3D
	if not _require(b201 != null and old_b225 != null and new_b225 != null, "Expected B201/control/candidate roots were absent."):
		_finish(stage)
		return
	b201.visible = false
	old_b225.position = Vector3.ZERO
	if not _require(_candidate_preflight(candidate, new_b225), "Candidate topology, metre UV, or isolation preflight failed."):
		_finish(stage)
		return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT.path_join("motion"))) != OK:
		_fail("Could not create the new B225 repair evidence directory.")
		_finish(stage)
		return

	var camera := stage.get_node("Camera3D") as Camera3D
	var sun := stage.get_node("Sun") as DirectionalLight3D
	var captures: Array[Dictionary] = []
	for pose: Dictionary in _static_poses():
		control.visible = true
		candidate.visible = false
		var control_result := await _capture(camera, sun, pose, "control")
		if not bool(control_result.get("ok", false)):
			_fail(str(control_result.get("message", "Control capture failed.")))
			_finish(stage)
			return
		captures.append(control_result.get("capture", {}) as Dictionary)
		control.visible = false
		candidate.visible = true
		var candidate_result := await _capture(camera, sun, pose, "candidate")
		if not bool(candidate_result.get("ok", false)):
			_fail(str(candidate_result.get("message", "Candidate capture failed.")))
			_finish(stage)
			return
		captures.append(candidate_result.get("capture", {}) as Dictionary)

	control.visible = false
	candidate.visible = true
	var motion_frames: Array[Dictionary] = []
	sun.rotation_degrees = Vector3(-35.0, -32.0, 0.0)
	for frame_index in 25:
		var chain_u_m := 8.0 + float(frame_index) * 0.75
		var local_x := -WIDTH_M * 0.5 + chain_u_m
		camera.position = Vector3(local_x, 2.25, 12.0)
		camera.look_at(Vector3(local_x + 3.0, 2.65, 0.18), Vector3.UP)
		camera.force_update_transform()
		await process_frame
		await RenderingServer.frame_post_draw
		var motion_path := OUTPUT_ROOT.path_join("motion/frame-%02d.png" % frame_index)
		var result := _save_current_image(motion_path)
		if not bool(result.get("ok", false)):
			_fail("Motion frame %02d failed: %s" % [frame_index, str(result.get("message", "unknown"))])
			_finish(stage)
			return
		motion_frames.append({
			"frame": frame_index,
			"file": "motion/frame-%02d.png" % frame_index,
			"sha256": FileAccess.get_sha256(motion_path),
			"bytes": FileAccess.get_file_as_bytes(motion_path).size(),
			"camera_chain_u_m": chain_u_m,
			"camera_position_m": [camera.position.x, camera.position.y, camera.position.z],
			"look_target_m": [local_x + 3.0, 2.65, 0.18],
			"crossed_internal_boundaries_u_m": _crossed_boundaries(chain_u_m),
			"sampled_luminance": result.get("sampled_luminance", {}),
		})

	var config := _load_json(CONFIG_PATH)
	var manifest := {
		"schema_version": "ti.d1-b225-standalone-cladding-repair-native-evidence/1",
		"prototype_id": "D1-B225-NNW-LONG-CLADDING-REPAIR-V1",
		"review_status": "pending_independent_bar_raiser_re_review_not_self_accepted",
		"evidence_role": "matched sealed-control/candidate views plus consecutive native render frames for a standalone B225 repair; not live receiver placement or acceptance",
		"clean_images": true,
		"image_overlays_or_claim_cards": 0,
		"control": {
			"role": "sealed rejected B225 rendered in-memory at local origin; B201 hidden only in the capture instance",
			"scene": {"path": CONTROL_SCENE_PATH, "sha256": EXPECTED_CONTROL_SCENE_SHA256},
			"factory": {"path": CONTROL_FACTORY_PATH, "sha256": EXPECTED_CONTROL_FACTORY_SHA256},
			"sealed_evidence_modified": false
		},
		"candidate": {
			"config": {"path": CONFIG_PATH, "sha256": FileAccess.get_sha256(CONFIG_PATH)},
			"scene": {"path": CANDIDATE_SCENE_PATH, "sha256": FileAccess.get_sha256(CANDIDATE_SCENE_PATH)},
			"factory": {"path": CANDIDATE_FACTORY_PATH, "sha256": FileAccess.get_sha256(CANDIDATE_FACTORY_PATH)},
			"uv_helper": {"path": UV_HELPER_PATH, "sha256": FileAccess.get_sha256(UV_HELPER_PATH)},
			"material": {"path": MATERIAL_PATH, "sha256": FileAccess.get_sha256(MATERIAL_PATH)},
			"texture": {"path": TEXTURE_PATH, "sha256": EXPECTED_TEXTURE_SHA256},
			"geometry_signature": str(new_b225.get_meta("geometry_signature", "")),
			"uv_plan_signature": str(new_b225.get_meta("uv_plan_signature", ""))
		},
		"observed_scope": {"source_key": "w95934119", "mapping_id": "14812-NNW-LONG", "source_edge": 3, "ordered_runs": [10, 11, 12, 13], "run_lengths_m": [10.372629078, 6.510893794, 7.049860211, 22.328585289], "chain_length_m": WIDTH_M, "side": "NNW long side"},
		"metre_uv_contract": {
			"u_start_m": 0.0,
			"u_end_m": WIDTH_M,
			"internal_boundaries_u_m": RUN_BOUNDARIES_U_M,
			"texture_cell_m": [8.0, 3.48],
			"horizontal_repeats_across_chain": WIDTH_M / 8.0,
			"vertical_repeats_across_height": 5.0 / 3.48,
			"phase_resets_inside_chain": 0
		},
		"topology": {"render_geometry_batches": 3, "mesh_instances": 3, "field_quads": 4, "box_instances": 90, "triangles": 1088, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0, "delta_from_control_triangles": -208, "removed_dark_course_boxes": 14},
		"material_contract": config.get("material_contract", {}),
		"generated_albedo_provenance": config.get("generated_albedo", {}),
		"static_capture_count": captures.size(),
		"static_captures": captures,
		"motion": {
			"kind": "25 consecutive native rendered frames along one continuously increasing camera path; no camera teleport or run-boundary reset between frames",
			"ordinary_standoff_m": 12.0,
			"step_m": 0.75,
			"chain_u_start_m": 8.0,
			"chain_u_end_m": 26.0,
			"crosses_all_internal_run_boundaries": true,
			"frame_count": motion_frames.size(),
			"frames": motion_frames
		},
		"visual_questions_for_independent_reviewer": ["does the candidate remove barcode/ruler-line dominance?", "does the generated grain remain quiet at ordinary distance?", "are 8 m repeat seams or 3.48 m vertical phase seams distracting?", "does motion expose shimmer, moire or run-boundary phase reset?", "does the preserved clerestory remain the primary recognition cue under changed light?"],
		"blocked_claims": ["independent visual acceptance", "perfectly seamless source bitmap", "surveyed cladding substrate/course cadence", "exact as-built layout", "lower openings", "unobserved sides/corners/roof equipment", "live attachment", "transparent interior"],
		"runtime_attachment": false,
		"exact_receiver_layout": false,
		"b201_bytes_unchanged": FileAccess.get_sha256(B201_CONFIG_PATH) == EXPECTED_B201_CONFIG_SHA256,
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"capture_harness": {"path": "res://game/tests/d1_b225_standalone_cladding_repair_v1_capture.gd", "sha256": FileAccess.get_sha256("res://game/tests/d1_b225_standalone_cladding_repair_v1_capture.gd")},
		"capture_command": COMMAND
	}
	if not _write_json(OUTPUT_ROOT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write the B225 repair capture manifest.")
		_finish(stage)
		return
	print("PASS: captured 8 matched clean B225 control/candidate views and 25 consecutive native motion frames across all run boundaries; review remains pending")
	_finish(stage)


func _bytes_are_bound() -> bool:
	if not _require(FileAccess.get_sha256(CONTROL_FACTORY_PATH) == EXPECTED_CONTROL_FACTORY_SHA256, "Sealed control factory drifted.") \
	or not _require(FileAccess.get_sha256(CONTROL_SCENE_PATH) == EXPECTED_CONTROL_SCENE_SHA256, "Sealed control scene drifted.") \
	or not _require(FileAccess.get_sha256(B201_CONFIG_PATH) == EXPECTED_B201_CONFIG_SHA256, "B201 config drifted.") \
	or not _require(FileAccess.get_sha256(TEXTURE_PATH) == EXPECTED_TEXTURE_SHA256, "Selected generated albedo drifted."):
		return false
	for pair: Array in [
		[CONFIG_PATH, EXPECTED_CONFIG_SHA256],
		[CANDIDATE_SCENE_PATH, EXPECTED_CANDIDATE_SCENE_SHA256],
		[CANDIDATE_FACTORY_PATH, EXPECTED_CANDIDATE_FACTORY_SHA256],
		[UV_HELPER_PATH, EXPECTED_UV_HELPER_SHA256],
		[MATERIAL_PATH, EXPECTED_MATERIAL_SHA256],
	]:
		if not str(pair[1]).is_empty() and not _require(FileAccess.get_sha256(str(pair[0])) == str(pair[1]), "Candidate byte guard failed: %s" % str(pair[0])):
			return false
	return true


func _candidate_preflight(candidate: Node3D, prototype: Node3D) -> bool:
	if bool(candidate.get_meta("runtime_attachment", true)) \
	or bool(candidate.get_meta("exact_receiver_layout", true)) \
	or str(candidate.get_meta("review_status", "")) != "pending_independent_bar_raiser_re_review_not_self_accepted" \
	or str(prototype.get_meta("source_key", "")) != "w95934119" \
	or prototype.get_meta("eligible_run_indices_not_placements", []) != [10, 11, 12, 13] \
	or int(prototype.get_meta("mesh_instance_count", 0)) != 3 \
	or int(prototype.get_meta("run_quad_count", 0)) != 4 \
	or int(prototype.get_meta("box_instance_count", 0)) != 90 \
	or int(prototype.get_meta("triangle_count", 0)) != 1088:
		return false
	var field := prototype.get_node_or_null("RenderOnlyMeshes/Field_CumulativeMetreCladding_Runs10_13") as MeshInstance3D
	if field == null or not field.mesh is ArrayMesh or field.mesh.get_surface_count() != 1:
		return false
	var arrays := field.mesh.surface_get_arrays(0) as Array
	var uvs := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	if uvs.size() != 16 or uvs[0] != Vector2(0.0, 0.0) or not uvs[14].is_equal_approx(Vector2(WIDTH_M, 5.0)):
		return false
	return _count_type(candidate, MeshInstance3D) == 1 \
		and _count_type(candidate, MultiMeshInstance3D) == 2 \
		and _count_type(candidate, CollisionObject3D) == 0 \
		and _count_type(candidate, CollisionShape3D) == 0 \
		and _count_type(candidate, NavigationRegion3D) == 0 \
		and _count_type(candidate, Decal) == 0


func _make_stage() -> Node3D:
	var stage := Node3D.new()
	stage.name = "B225CladdingRepairEvidenceStage"
	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("20282d")
	environment.background_energy_multiplier = 0.75
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b6c0c3")
	environment.ambient_light_energy = 0.58
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	world_environment.environment = environment
	stage.add_child(world_environment)

	var floor := MeshInstance3D.new()
	floor.name = "NeutralMetreFloor"
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(100.0, 80.0)
	floor.mesh = floor_mesh
	floor.position.y = -0.015
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("485055")
	floor_material.roughness = 0.94
	floor.material_override = floor_material
	stage.add_child(floor)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = Color("fff4e5")
	sun.light_energy = 1.42
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 120.0
	stage.add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.name = "CoolFill"
	fill.light_color = Color("c3d8e4")
	fill.light_energy = 0.34
	fill.rotation_degrees = Vector3(-18.0, 145.0, 0.0)
	fill.shadow_enabled = false
	stage.add_child(fill)

	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.fov = 50.0
	camera.near = 0.1
	camera.far = 160.0
	camera.current = true
	stage.add_child(camera)
	return stage


func _static_poses() -> Array[Dictionary]:
	return [
		{"id": "01-front", "view_kind": "ordinary_grounded_complete_side", "camera": Vector3(0.0, 2.8, 39.0), "target": Vector3(0.0, 2.45, 0.15), "sun": Vector3(-35.0, -32.0, 0.0)},
		{"id": "02-oblique", "view_kind": "ordinary_grounded_clerestory_depth", "camera": Vector3(-20.0, 2.0, 25.0), "target": Vector3(0.0, 3.1, 0.20), "sun": Vector3(-35.0, -32.0, 0.0)},
		{"id": "03-close", "view_kind": "ordinary_clerestory_cladding_hierarchy_close", "camera": Vector3(0.0, 2.25, 15.0), "target": Vector3(0.0, 3.05, 0.20), "sun": Vector3(-35.0, -32.0, 0.0)},
		{"id": "04-changed-light", "view_kind": "changed_light_oblique_depth_check", "camera": Vector3(17.0, 3.2, 28.0), "target": Vector3(0.0, 2.7, 0.15), "sun": Vector3(-18.0, 118.0, 0.0)},
	]


func _capture(camera: Camera3D, sun: DirectionalLight3D, pose: Dictionary, variant: String) -> Dictionary:
	camera.position = pose.get("camera", Vector3.ZERO) as Vector3
	camera.look_at(pose.get("target", Vector3.ZERO) as Vector3, Vector3.UP)
	sun.rotation_degrees = pose.get("sun", Vector3.ZERO) as Vector3
	camera.force_update_transform()
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var filename := "%s-%s.png" % [str(pose.get("id", "capture")), variant]
	var output_path := OUTPUT_ROOT.path_join(filename)
	var result := _save_current_image(output_path)
	if not bool(result.get("ok", false)):
		return result
	return {
		"ok": true,
		"capture": {
			"id": str(pose.get("id", "")),
			"variant": variant,
			"view_kind": str(pose.get("view_kind", "")),
			"file": filename,
			"sha256": FileAccess.get_sha256(output_path),
			"bytes": FileAccess.get_file_as_bytes(output_path).size(),
			"dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
			"sampled_luminance": result.get("sampled_luminance", {}),
			"camera_position_m": [camera.position.x, camera.position.y, camera.position.z],
			"sun_rotation_degrees": [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z],
		}
	}


func _save_current_image(path: String) -> Dictionary:
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "empty or wrong-sized native image"}
	var stats := _luminance_stats(image)
	if float(stats.get("range", 0.0)) < 0.12:
		return {"ok": false, "message": "capture lacked useful luminance range"}
	if image.save_png(path) != OK:
		return {"ok": false, "message": "could not save PNG"}
	return {"ok": true, "sampled_luminance": stats}


func _crossed_boundaries(chain_u_m: float) -> Array[float]:
	var crossed: Array[float] = []
	for boundary in RUN_BOUNDARIES_U_M:
		if boundary <= chain_u_m:
			crossed.append(boundary)
	return crossed


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


func _count_type(node: Node, type: Variant) -> int:
	var count := 1 if is_instance_of(node, type) else 0
	for child in node.get_children():
		count += _count_type(child, type)
	return count


func _load_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


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
