extends SceneTree

const PAIR_CONFIG_PATH := "res://game/resources/facades/d1_current/d1_current_standalone_pair.json"
const B201_CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b201_public_wsw.json"
const B225_CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b225_nnw_long.json"
const SCENE_PATH := "res://game/scenes/world/facades/d1_current/d1_current_standalone_prototype_pair.tscn"
const FACTORY_PATH := "res://game/scripts/world/facades/d1_current_standalone_prototypes.gd"
const CONTRACT_PATH := "res://game/tests/headless_d1_current_standalone_prototype_contract.gd"
const OUTPUT_ROOT := "res://evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04"
const CAPTURE_SIZE := Vector2i(1440, 900)
const EXPECTED_PAIR_CONFIG_SHA256 := "c73f8c8da4d30a4e4ebe3e94cde10d63f98377bf5b636a1e12cee92c9bcaafe4"
const EXPECTED_B201_CONFIG_SHA256 := "3d53efbb0577c9b5e52a2ada4d79a710b95e41faead0bdcdd41cd4f2d862a0fe"
const EXPECTED_B225_CONFIG_SHA256 := "63e4f80cc7716146dc1fef46c7678e4da856755377c84ff33f972c0cc0c1f639"
const EXPECTED_SCENE_SHA256 := "0fdd5d356deb57664549db95fd04e123290c1fb9490b8024569e997616893d7f"
const EXPECTED_FACTORY_SHA256 := "797bbb81e7f772f3fab3989d358772be4f1b16cb7e31a05571463e0d6ec31a5e"
const EXPECTED_CONTRACT_SHA256 := "eafe1f8b20cf4a276ad8cda97112acc6870fca183c6d73916dd5bf306a7d099e"
const B201_SIGNATURE := "57573bc19d6c6a45b946827e76a346c592d5238a310e923a30a41b149f963511"
const B225_SIGNATURE := "179d898c4635917743e967819998256c7fe4938981da69e7d4664e1e7e13b58a"
const PAIR_SIGNATURE := "17c560633517963489b76430729bb6476065bb0d9a6385b3a913103a778c32ad"
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/d1_current_standalone_prototype_capture.gd"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("D1 standalone evidence requires native macOS Forward+/Metal; headless screenshots are forbidden.")
		_finish(null)
		return
	if not _require(FileAccess.get_sha256(PAIR_CONFIG_PATH) == EXPECTED_PAIR_CONFIG_SHA256, "Pair config drifted before capture.") \
	or not _require(FileAccess.get_sha256(B201_CONFIG_PATH) == EXPECTED_B201_CONFIG_SHA256, "B201 config drifted before capture.") \
	or not _require(FileAccess.get_sha256(B225_CONFIG_PATH) == EXPECTED_B225_CONFIG_SHA256, "B225 config drifted before capture.") \
	or not _require(FileAccess.get_sha256(SCENE_PATH) == EXPECTED_SCENE_SHA256, "Pair scene drifted before capture.") \
	or not _require(FileAccess.get_sha256(FACTORY_PATH) == EXPECTED_FACTORY_SHA256, "Factory drifted before capture.") \
	or not _require(FileAccess.get_sha256(CONTRACT_PATH) == EXPECTED_CONTRACT_SHA256, "Headless contract drifted before capture."):
		_finish(null)
		return
	var packed := load(SCENE_PATH) as PackedScene
	if not _require(packed != null, "D1 standalone prototype pair scene did not load."):
		_finish(null)
		return
	var stage := _make_stage()
	root.add_child(stage)
	var prototype := packed.instantiate() as Node3D
	prototype.name = "D1CurrentStandaloneProof"
	stage.add_child(prototype)
	await process_frame
	if not _require(_prototype_preflight(prototype), "Capture preflight topology/signature/isolation failed."):
		_finish(stage)
		return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT)) != OK:
		_fail("Could not create the D1 standalone evidence directory.")
		_finish(stage)
		return

	var camera := stage.get_node("Camera3D") as Camera3D
	var sun := stage.get_node("Sun") as DirectionalLight3D
	var detail := stage.get_node("ProofOverlay/Detail") as Label
	var captures: Array[Dictionary] = []
	for pose: Dictionary in _poses():
		detail.text = "%s  ·  %s\n%s\nSTANDALONE SIDE STUDY  ·  RUN ELIGIBILITY IS NOT PLACEMENT  ·  INFERRED CADENCE  ·  PENDING INDEPENDENT RECOGNITION + BAR REVIEW" % [str(pose.get("label", "")), str(pose.get("view_kind", "")), str(pose.get("scope_note", ""))]
		var result := await _capture_pose(camera, sun, pose)
		if not bool(result.get("ok", false)):
			_fail(str(result.get("message", "Unknown D1 capture failure.")))
			_finish(stage)
			return
		captures.append(result.get("capture", {}) as Dictionary)

	var manifest := {
		"schema_version": "ti.d1-current-standalone-native-evidence/1",
		"pair_id": "D1-CURRENT-B201-B225-STANDALONE-PAIR",
		"review_status": "pending_independent_recognition_and_bar_review_not_self_accepted",
		"evidence_role": "fresh native technical views of two standalone observed-side studies; not live receiver placement, calibration, gameplay-world evidence, or acceptance",
		"observed_scope": [
			{"source_key": "w34313545", "city_building": "B201", "mapping_id": "800I-PUBLIC-WSW", "source_edge": 0, "ordered_runs": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], "chain_length_m": 115.512661489, "side": "WSW public long side"},
			{"source_key": "w95934119", "city_building": "B225", "mapping_id": "14812-NNW-LONG", "source_edge": 3, "ordered_runs": [10, 11, 12, 13], "chain_length_m": 46.261968372, "side": "NNW long side"},
		],
		"recognition_cues": {
			"w34313545": ["green-bounded broad upper-window register", "mostly solid light lower field with sparse nonsemantic openings", "separate canopy depth and muted posts"],
			"w95934119": ["varied complete high clerestory groups", "physically coursed aged light horizontal cladding", "low near-flat-roof proportion"],
		},
		"production_inference": ["all module counts", "bay/group cadence", "opening anchors", "canopy dimensions and endpoints", "window and pane dimensions"],
		"identity_nonclaims": ["B201 frozen 800 Avenue I conflicts with City B201 addresses and is not Station 48", "B225 has no authoritative common name and is not Building 227/the Pavilion"],
		"blocked_claims": ["address, sign or tenant recognition", "exact as-built layout", "unobserved lower B225 openings", "B201 service ENE/SSE/NNW/returns", "B225 WSW openings/SSE/ENE/returns", "roof equipment", "transparent interiors", "live attachment or independent acceptance"],
		"pair_config": {"path": PAIR_CONFIG_PATH, "sha256": EXPECTED_PAIR_CONFIG_SHA256},
		"unit_configs": [
			{"path": B201_CONFIG_PATH, "sha256": EXPECTED_B201_CONFIG_SHA256},
			{"path": B225_CONFIG_PATH, "sha256": EXPECTED_B225_CONFIG_SHA256},
		],
		"scene": {"path": SCENE_PATH, "sha256": EXPECTED_SCENE_SHA256},
		"factory": {"path": FACTORY_PATH, "sha256": EXPECTED_FACTORY_SHA256},
		"headless_contract": {"path": CONTRACT_PATH, "sha256": EXPECTED_CONTRACT_SHA256},
		"geometry_signatures": {"w34313545": B201_SIGNATURE, "w95934119": B225_SIGNATURE, "pair": PAIR_SIGNATURE},
		"topology": {"batch_count": 10, "box_instance_count": 290, "triangle_count": 3480, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0},
		"materials": {"local_standard_materials": 8, "bitmap_textures": 0, "generated_images": 0, "random_or_noise_generators": 0},
		"runtime_attachment": false,
		"exact_receiver_layout": false,
		"one_local_unit_m": 1.0,
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"capture_command": COMMAND,
		"capture_count": captures.size(),
		"captures": captures,
	}
	if not _write_json(OUTPUT_ROOT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write the D1 capture manifest.")
		_finish(stage)
		return
	print("PASS: captured %d fresh native Forward+/Metal D1 standalone views for B201 runs 0..9 and B225 runs 10..13; pair remains pending independent recognition/bar review with no live attachment" % captures.size())
	_finish(stage)


func _make_stage() -> Node3D:
	var stage := Node3D.new()
	stage.name = "D1StandaloneEvidenceStage"
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
	floor_mesh.size = Vector2(240.0, 190.0)
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
	sun.directional_shadow_max_distance = 240.0
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
	camera.far = 400.0
	camera.current = true
	stage.add_child(camera)

	var overlay := CanvasLayer.new()
	overlay.name = "ProofOverlay"
	var backdrop := ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.color = Color(0.012, 0.016, 0.019, 0.90)
	backdrop.position = Vector2(24, 22)
	backdrop.size = Vector2(1392, 148)
	overlay.add_child(backdrop)
	var title := Label.new()
	title.name = "Title"
	title.position = Vector2(44, 35)
	title.text = "D1 CURRENT PAIR · B201 + B225 · NATIVE TECHNICAL PROOF"
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", Color("f1d470"))
	overlay.add_child(title)
	var detail := Label.new()
	detail.name = "Detail"
	detail.position = Vector2(44, 70)
	detail.add_theme_font_size_override("font_size", 15)
	detail.add_theme_color_override("font_color", Color("eef1f2"))
	overlay.add_child(detail)
	stage.add_child(overlay)
	return stage


func _poses() -> Array[Dictionary]:
	return [
		{"id": "01-b201-grounded-complete-wsw", "label": "B201 · W34313545 · OBSERVED WSW CHAIN RUNS 0–9", "view_kind": "ordinary_grounded_complete_side", "scope_note": "115.513 m exact chain length · broad dark upper bays + green hierarchy + sparse solid lower field", "camera": Vector3(-32.0, 3.1, 88.0), "target": Vector3(-32.0, 2.45, 0.25), "sun": Vector3(-35.0, -32.0, 0.0)},
		{"id": "02-b201-grounded-canopy-depth", "label": "B201 · W34313545 · WSW DEPTH READ", "view_kind": "ordinary_grounded_oblique", "scope_note": "canopy slab/fascia/posts are separate removable render geometry · dimensions and anchors inferred", "camera": Vector3(-78.0, 2.2, 43.0), "target": Vector3(-28.0, 2.4, 0.55), "sun": Vector3(-35.0, -32.0, 0.0)},
		{"id": "03-b201-register-service-close", "label": "B201 · W34313545 · REGISTER / LOWER-FIELD HIERARCHY", "view_kind": "grounded_recognition_close", "scope_note": "complete broad windows and real frame/pier relief · three lower leaves are nonsemantic production inference", "camera": Vector3(-38.0, 2.15, 24.0), "target": Vector3(-32.0, 2.65, 0.35), "sun": Vector3(-35.0, -32.0, 0.0)},
		{"id": "04-b201-changed-light-oblique", "label": "B201 · W34313545 · CHANGED LIGHT", "view_kind": "changed_light_oblique_depth_check", "scope_note": "restrained material hierarchy and relief remain readable without signage, address markers or facade imagery", "camera": Vector3(3.0, 3.6, 48.0), "target": Vector3(-32.0, 2.5, 0.45), "sun": Vector3(-20.0, 118.0, 0.0)},
		{"id": "05-b225-grounded-complete-nnw", "label": "B225 · W95934119 · OBSERVED NNW CHAIN RUNS 10–13", "view_kind": "ordinary_grounded_complete_side", "scope_note": "46.262 m exact chain length · varied high clerestory groups + physically coursed aged field", "camera": Vector3(68.0, 2.8, 39.0), "target": Vector3(68.0, 2.45, 0.15), "sun": Vector3(-35.0, -32.0, 0.0)},
		{"id": "06-b225-grounded-clerestory-oblique", "label": "B225 · W95934119 · CLERESTORY DEPTH READ", "view_kind": "ordinary_grounded_oblique", "scope_note": "ten complete varied groups, pale frames and recessed opaque panes · group widths/counts inferred", "camera": Vector3(48.0, 2.0, 25.0), "target": Vector3(68.0, 3.1, 0.20), "sun": Vector3(-35.0, -32.0, 0.0)},
		{"id": "07-b225-clerestory-course-close", "label": "B225 · W95934119 · CLERESTORY / COURSE HIERARCHY", "view_kind": "grounded_recognition_close", "scope_note": "directional course relief is deterministic and metre-authored · no repeated damage or dark-pane signature", "camera": Vector3(68.0, 2.25, 15.0), "target": Vector3(68.0, 3.05, 0.20), "sun": Vector3(-35.0, -32.0, 0.0)},
		{"id": "08-b225-changed-light-oblique", "label": "B225 · W95934119 · CHANGED LIGHT", "view_kind": "changed_light_oblique_depth_check", "scope_note": "low mass, course direction, frame projection and pane recess remain legible without openings/signs", "camera": Vector3(85.0, 3.2, 28.0), "target": Vector3(68.0, 2.7, 0.15), "sun": Vector3(-18.0, 118.0, 0.0)},
		{"id": "09-pair-grounded-overview", "label": "D1 CURRENT PAIR · DISTINCT RECOGNITION LANGUAGES", "view_kind": "grounded_pair_overview", "scope_note": "B201 green-bounded broad register versus B225 pale varied clerestory/coursed field · illustrative spacing only", "camera": Vector3(18.0, 8.2, 126.0), "target": Vector3(12.0, 2.5, 0.15), "sun": Vector3(-35.0, -32.0, 0.0)},
	]


func _capture_pose(camera: Camera3D, sun: DirectionalLight3D, pose: Dictionary) -> Dictionary:
	camera.position = pose.get("camera", Vector3.ZERO) as Vector3
	camera.look_at(pose.get("target", Vector3.ZERO) as Vector3, Vector3.UP)
	sun.rotation_degrees = pose.get("sun", Vector3.ZERO) as Vector3
	camera.force_update_transform()
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s produced an empty or wrong-sized image." % str(pose.get("id", "unknown"))}
	var stats := _luminance_stats(image)
	if float(stats.get("range", 0.0)) < 0.12:
		return {"ok": false, "message": "%s lacked enough luminance range for useful evidence." % str(pose.get("id", "unknown"))}
	var filename := "%s.png" % str(pose.get("id", "capture"))
	var output_path := OUTPUT_ROOT.path_join(filename)
	if image.save_png(output_path) != OK:
		return {"ok": false, "message": "%s could not save its PNG." % str(pose.get("id", "unknown"))}
	return {
		"ok": true,
		"capture": {
			"id": str(pose.get("id", "")),
			"label": str(pose.get("label", "")),
			"view_kind": str(pose.get("view_kind", "")),
			"scope_note": str(pose.get("scope_note", "")),
			"file": filename,
			"sha256": FileAccess.get_sha256(output_path),
			"bytes": FileAccess.get_file_as_bytes(output_path).size(),
			"dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
			"sampled_luminance": stats,
			"camera_position_m": [camera.position.x, camera.position.y, camera.position.z],
			"sun_rotation_degrees": [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z],
		},
	}


func _prototype_preflight(prototype: Node3D) -> bool:
	var b201 := prototype.get_node_or_null("B201_w34313545") as Node3D
	var b225 := prototype.get_node_or_null("B225_w95934119") as Node3D
	return not bool(prototype.get_meta("runtime_attachment", true)) \
		and str(prototype.get_meta("review_status", "")) == "pending_independent_recognition_and_bar_review_not_self_accepted" \
		and int(prototype.get_meta("box_instance_count", 0)) == 290 \
		and int(prototype.get_meta("triangle_count", 0)) == 3480 \
		and str(prototype.get_meta("geometry_signature", "")) == PAIR_SIGNATURE \
		and b201 != null and b225 != null \
		and str(b201.get_meta("geometry_signature", "")) == B201_SIGNATURE \
		and str(b225.get_meta("geometry_signature", "")) == B225_SIGNATURE \
		and _count_type(prototype, MultiMeshInstance3D) == 10 \
		and _count_type(prototype, CollisionObject3D) == 0 \
		and _count_type(prototype, CollisionShape3D) == 0 \
		and _count_type(prototype, NavigationRegion3D) == 0 \
		and _count_type(prototype, Decal) == 0


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
