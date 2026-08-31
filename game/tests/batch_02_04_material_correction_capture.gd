extends SceneTree

const OUTPUT_ROOT := "res://evidence/first-playable/batch-02-04-material-corrections-2026-08-29"
const CAPTURE_SIZE := Vector2i(1440, 900)
const GENERIC_SHADER_SHA256 := "1918177080126199ddbfc0715a77b85a9355800479a098ec9b81c9726b7cc4d5"
const CORRECTION_SHADER_SHA256 := "324ba33a7c78f4b05038168a479ebb8e875c56704236492a050cee8da8e5f798"
const GENERATED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/batch_02_04_material_correction_capture.gd"

const TARGETS := [
	{
		"correction_id": "C1", "slug": "treasure-island-community-ymca", "source_key": "w34313547", "receiver_key": "building:w34313547:wall",
		"canonical_name": "Treasure Island Community YMCA", "role": "dark exposed-aggregate wall field",
		"material_path": "res://game/resources/materials/world/ti_ymca/ti_ymca_primary.tres", "material_hash": "c44f1f2e1d12acdda1cd79ca47e4a0188a8543377c1d0ff7742c69d7d01c5681",
		"shader_hash": CORRECTION_SHADER_SHA256, "registry_path": "res://game/resources/facades/batch_02_material_registry.json", "registry_hash": "e7d1167869640867e2857de1f08df81e878e68230b59feff3fb947b16ff56cb7",
		"primary_scale_m": 0.42, "secondary_scale_m": 0.095, "roughness": 0.91,
		"before": "Axis-aligned checker lattice dominated the material field.",
		"after": "Rotated, hash-driven multi-scale aggregate field preserves the declared 0.095-0.42 m grain range, dark base, and roughness without an aligned lattice.",
		"prior_manifest": "res://evidence/first-playable/batch-02-material-prototypes-2026-08-29/treasure-island-community-ymca/capture-manifest.json", "prior_manifest_hash": "bb46853fd86ea58080121f801a78a5c28db7f5cba959ce88ba02461cd73dbe92",
	},
	{
		"correction_id": "C2", "slug": "fire-training-b600", "source_key": "w34313548", "receiver_key": "building:w34313548:wall",
		"canonical_name": "Fire Training Building 600", "role": "pale cream-gray coarse mineral field",
		"material_path": "res://game/resources/materials/world/fire_training_b600/fire_training_primary.tres", "material_hash": "fd1437ed9c0e00508d10d9a3c5d859d9a07c73fb28edc3fad62c473e9d865483",
		"shader_hash": CORRECTION_SHADER_SHA256, "registry_path": "res://game/resources/facades/batch_03_material_registry.json", "registry_hash": "31983ae1529e6248e93ec8d231d2b870de3979778b35eef6019cd19e1a964516",
		"primary_scale_m": 0.38, "secondary_scale_m": 0.22, "roughness": 0.84,
		"before": "Diagonal quilting dominated the pale mineral field.",
		"after": "Low-amplitude rotated stochastic octaves preserve the pale cream-gray 0.20-0.50 m mineral reading and roughness without diagonal quilting.",
		"prior_manifest": "res://evidence/first-playable/batch-03-material-prototypes-2026-08-29/fire-training-b600/capture-manifest.json", "prior_manifest_hash": "ccdad3ba144c7011bbfa887a27ccc497f3455f27372f69b065f012d25a9f2138",
	},
	{
		"correction_id": "C3", "slug": "850-avenue-h/tan_wall", "source_key": "w34313546", "receiver_key": "building:w34313546:wall",
		"canonical_name": "850 Avenue H", "role": "warm tan homogeneous wall field",
		"material_path": "res://game/resources/materials/world/850_avenue_h/850_h_tan_field.tres", "material_hash": "d92f7137edf2be91b0268659843423764528db58c194cbe5d0b1596a4f8303a8",
		"shader_hash": CORRECTION_SHADER_SHA256, "registry_path": "res://game/resources/facades/batch_04_material_registry.json", "registry_hash": "b4c5983a628d076cda0aaa24d0023fc7a43983fd6c00f82c9806871af0409cf7",
		"primary_scale_m": 0.75, "secondary_scale_m": 0.28, "roughness": 0.80,
		"before": "Diagonal periodic banding overpowered the warm tan field.",
		"after": "Smooth low-amplitude aperiodic variation preserves the warm tan homogeneous identity and roughness with zero relief and no diagonal banding.",
		"prior_manifest": "res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/850-avenue-h/tan_wall/capture-manifest.json", "prior_manifest_hash": "03ea10d1872a90f10f0d94cda267f2cdffbe19875023eeb2f0d0fb90a569aac2",
	},
	{
		"correction_id": "C4", "slug": "bldg-461/medium_gray", "source_key": "w34313569", "receiver_key": "building:w34313569:wall",
		"canonical_name": "Building 461", "role": "medium-gray wall field",
		"material_path": "res://game/resources/materials/world/bldg_461/bldg_461_gray_field.tres", "material_hash": "e44738c8f1d06a34bfc876b610e2c70a0890c85cbb63342b613094d7b8b80a66",
		"shader_hash": CORRECTION_SHADER_SHA256, "registry_path": "res://game/resources/facades/batch_04_material_registry.json", "registry_hash": "b4c5983a628d076cda0aaa24d0023fc7a43983fd6c00f82c9806871af0409cf7",
		"primary_scale_m": 0.95, "secondary_scale_m": 0.38, "roughness": 0.82,
		"before": "Diagonal/cellular modulation created an unsupported two-value material pattern.",
		"after": "Sub-perceptual nondirectional variation preserves the substrate-neutral medium-gray identity and roughness with zero relief and no two-value band.",
		"prior_manifest": "res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/bldg-461/medium_gray/capture-manifest.json", "prior_manifest_hash": "3c5eda55b675f752a8767b6d8fa5336d05926d02d8405dfc64632ed269dd7e50",
	},
	{
		"correction_id": "C5", "slug": "1318-gateview/white_trim", "source_key": "w96698660", "receiver_key": "building:w96698660:wall",
		"canonical_name": "1318 Gateview", "role": "white painted trim",
		"material_path": "res://game/resources/materials/world/1318_gateview/1318_gateview_white_trim.tres", "material_hash": "30c896ddb23419a590744572fe4396c00fee942c3654985be97e2f33694a7452",
		"shader_hash": GENERIC_SHADER_SHA256, "registry_path": "res://game/resources/facades/batch_04_material_registry.json", "registry_hash": "b4c5983a628d076cda0aaa24d0023fc7a43983fd6c00f82c9806871af0409cf7",
		"primary_scale_m": 0.75, "secondary_scale_m": 0.25, "roughness": 0.66,
		"before": "A darker secondary color produced unsupported macro blotches in the white trim.",
		"after": "Secondary color now exactly equals the 0.84/0.85/0.82 base, preserving roughness 0.66 and zero relief for subtle white painted trim variation.",
		"prior_manifest": "res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/1318-gateview/white_trim/capture-manifest.json", "prior_manifest_hash": "ff12b15bfa4c60c60a4a6bbd420b59c2fd6e7ce3ae5bbff19eb73a22a5db4d3f",
	},
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Correction proof capture requires the real macOS Metal renderer; headless output is not evidence.")
		_finish(null)
		return
	if not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == GENERATED_MANIFEST_SHA256, "Generated manifest drifted before correction capture.") \
	or not _require(TARGETS.size() == 5, "Correction capture must contain exactly five targets."):
		_finish(null)
		return
	var stage := _make_stage()
	root.add_child(stage)
	var panel := stage.get_node("ProofPanel") as MeshInstance3D
	var camera := stage.get_node("Camera3D") as Camera3D
	var sun := stage.get_node("Sun") as DirectionalLight3D
	var detail := stage.get_node("ProofOverlay/Detail") as Label
	for target_value: Variant in TARGETS:
		var target := target_value as Dictionary
		if not _target_inputs_match(target):
			_finish(stage)
			return
		panel.material_override = load(str(target.material_path)) as ShaderMaterial
		detail.text = "%s  ·  %s  ·  %s\n4.8 m × 3.2 m controlled panel  ·  primary %.3f m  ·  secondary %.3f m\nCORRECTION PROOF ONLY — NOT ATTACHED IN GAME — INDEPENDENT REVIEW PENDING" % [str(target.correction_id), str(target.canonical_name), str(target.role), float(target.primary_scale_m), float(target.secondary_scale_m)]
		var output := OUTPUT_ROOT.path_join(str(target.slug))
		if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
			_fail("Could not create correction proof directory for %s." % str(target.correction_id))
			_finish(stage)
			return
		var captures: Array[Dictionary] = []
		for pose: Dictionary in _poses():
			var capture := await _capture_pose(stage, camera, sun, output, pose)
			if not bool(capture.get("ok", false)):
				_fail(str(capture.get("message", "Unknown correction capture failure.")))
				_finish(stage)
				return
			captures.append(capture.result as Dictionary)
		var prior_manifest := JSON.parse_string(FileAccess.get_file_as_string(str(target.prior_manifest))) as Dictionary
		var target_manifest := {
			"schema_version": "ti.batch-02-04-material-correction-proof/1",
			"review_status": "ready_for_independent_re_review_not_self_accepted",
			"evidence_role": "controlled_material_correction_proof_not_gameplay_or_live_receiver_acceptance",
			"correction_id": str(target.correction_id),
			"runtime_attachment": false,
			"source_key": str(target.source_key),
			"receiver_key": str(target.receiver_key),
			"canonical_name": str(target.canonical_name),
			"material_role": str(target.role),
			"before": str(target.before),
			"after": str(target.after),
			"material_path": str(target.material_path),
			"material_sha256": str(target.material_hash),
			"shader_sha256": str(target.shader_hash),
			"registry_path": str(target.registry_path),
			"registry_sha256": str(target.registry_hash),
			"generated_manifest_sha256": GENERATED_MANIFEST_SHA256,
			"prior_rejected_evidence_manifest": str(target.prior_manifest),
			"prior_rejected_evidence_manifest_sha256": str(target.prior_manifest_hash),
			"prior_rejected_captures": prior_manifest.get("captures", []),
			"proof_receiver": "controlled_flat_proof_panel",
			"proof_panel_size_m": [4.8, 3.2, 0.12],
			"one_local_unit_m": 1.0,
			"proof_primary_scale_m": float(target.primary_scale_m),
			"proof_secondary_scale_m": float(target.secondary_scale_m),
			"roughness_value": float(target.roughness),
			"contains_facade_scale_motifs": false,
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
			_fail("Could not write correction capture manifest for %s." % str(target.correction_id))
			_finish(stage)
			return
		print("CORRECTION_PROOF_TARGET: id=%s views=%d output=%s" % [str(target.correction_id), captures.size(), ProjectSettings.globalize_path(output)])
	print("PASS: captured 15 Forward+/Metal controlled proof views for exactly five corrected prototypes; independent art re-review remains pending and none is live receiver evidence")
	_finish(stage)


func _target_inputs_match(target: Dictionary) -> bool:
	if not _require(FileAccess.get_sha256(str(target.material_path)) == str(target.material_hash), "Material bytes drifted for %s." % str(target.correction_id)) \
	or not _require(FileAccess.get_sha256(str(target.registry_path)) == str(target.registry_hash), "Registry bytes drifted for %s." % str(target.correction_id)) \
	or not _require(FileAccess.get_sha256(str(target.prior_manifest)) == str(target.prior_manifest_hash), "Prior rejected evidence lineage drifted for %s." % str(target.correction_id)):
		return false
	var material := load(str(target.material_path)) as ShaderMaterial
	return _require(material != null and material.shader != null, "Material failed to load for %s." % str(target.correction_id)) \
		and _require(is_equal_approx(float(material.get_shader_parameter("primary_scale_m")), float(target.primary_scale_m)), "Primary scale drifted for %s." % str(target.correction_id)) \
		and _require(is_equal_approx(float(material.get_shader_parameter("secondary_scale_m")), float(target.secondary_scale_m)), "Secondary scale drifted for %s." % str(target.correction_id)) \
		and _require(is_equal_approx(float(material.get_shader_parameter("roughness_value")), float(target.roughness)), "Roughness drifted for %s." % str(target.correction_id)) \
		and _require(FileAccess.get_sha256(material.shader.resource_path) == str(target.shader_hash), "Shader bytes drifted for %s." % str(target.correction_id))


func _make_stage() -> Node3D:
	var stage := Node3D.new()
	stage.name = "Batch0204ControlledCorrectionProof"
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
	backdrop.size = Vector2(1330, 148)
	overlay.add_child(backdrop)
	var title := Label.new()
	title.name = "Title"
	title.position = Vector2(48, 38)
	title.text = "CONTROLLED BATCH 02-04 MATERIAL CORRECTION PROOF"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("f4d56c"))
	overlay.add_child(title)
	var detail := Label.new()
	detail.name = "Detail"
	detail.position = Vector2(48, 72)
	detail.add_theme_font_size_override("font_size", 16)
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
		"id": str(pose.id), "view_kind": str(pose.view_kind), "file": filename,
		"sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_position_m": [camera.position.x, camera.position.y, camera.position.z],
		"aim_target_m": [(pose.target as Vector3).x, (pose.target as Vector3).y, (pose.target as Vector3).z],
		"camera_fov_degrees": camera.fov,
		"sun_rotation_degrees": [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z],
		"proof_receiver_only": true,
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
