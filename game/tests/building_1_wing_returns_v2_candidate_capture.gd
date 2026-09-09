extends "res://game/tests/isle_house_low_live_evidence_capture.gd"

## Identical source-checkout A/B harness for the bounded Building 1 wing-window
## returns v2 candidate. Both stages use ordinary main, the actual stock player rig,
## physics-settled generated ground, native Metal at 1440x900, and one frozen set
## of poses/lights/trajectories. The sealed PCK identity is carried as provenance;
## package semantics are proved separately by the direct-mounted package contract.

class B1PostPlayerSampler:
	extends Node

	signal sampled(snapshot: Dictionary)

	var player: PlayerController
	var target := Vector3.ZERO
	var sequence := 0
	var latest: Dictionary = {}


	func configure(value: PlayerController, target_value: Vector3) -> void:
		player = value
		target = target_value
		process_physics_priority = player.process_physics_priority + 100


	func _physics_process(_delta: float) -> void:
		if not is_instance_valid(player):
			return
		sequence += 1
		var position := player.global_position
		latest = {
			"sequence": sequence,
			"engine_physics_frame": Engine.get_physics_frames(),
			"player_position_m": [position.x, position.y, position.z],
			"target_distance_m": Vector2(position.x, position.z).distance_to(Vector2(target.x, target.z)),
		}
		sampled.emit(latest.duplicate(true))


const PACKET_ID := "building-1-wing-returns-v2-candidate-2026-09-08-001"
const CAPTURE_DATE := "2026-09-08"
const CAPTURE_SIZE := Vector2i(1440, 900)
const DEFAULT_SUN := Vector3(-52.0, -28.0, 0.0)
const CHANGED_SUN := Vector3(-18.0, 118.0, 0.0)
const PHYSICS_HZ := 60
const FIXED_FPS := 60
const MOTION_POSE_TOLERANCE_M := 0.22
const WALL_KEY := "building:r16681702:wall"
const ROOF_KEY := "building:r16681702:roof"
const TOWER_WALL_KEY := "building:w1222720021:wall"
const TOWER_ROOF_KEY := "building:w1222720021:roof"
const SOURCE_KEY := "r16681702"
const TOWER_SOURCE_KEY := "w1222720021"
const D2_WALL_KEY := "building:w95934105:wall"
const D2_ROOF_KEY := "building:w95934105:roof"
const BASELINE_PCK_SHA256 := "0945ac7b08ebd2fc5389ffa05a919b7324ecb298dac46032c8fdc30d8c47404a"
const CANDIDATE_PCK_SHA256 := "59b37cf856dd1ece6aaadeee5c6278327997394339bb8450253193cbd89728da"
const BASELINE_CONFIG_SHA256 := "7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806"
const CANDIDATE_CONFIG_SHA256 := "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb"
const BASELINE_ADAPTER_SHA256 := "e5b11fc7f971ea33bb38c84d3106f8883de0486774f58a5a8310d49d56aa55a5"
const CANDIDATE_ADAPTER_SHA256 := "ce2f21dab02163b5f45d9d7e457f5d0ce96089bc55cca6e65aa9924c9f199c5a"
const CONFIG_PATH := "res://game/resources/facades/building_1_public_front_believability.json"
const ADAPTER_PATH := "res://game/scripts/world/facades/building_1_hero_model.gd"
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const CONTRACTS_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const EXPECTED_REGISTRY_SHA256 := "26dcf64a34cf92aa7766c60940933190cdb5f9bc595dc23dc2f16fa01752e16c"
const EXPECTED_CONTRACTS_SHA256 := "8c61ea5601ab94852ac593b8658963b52cb5253aae22a2ff109f2e46771caa93"
const SOURCE_AUDIT_SHA256 := "beced0b7bb42589a1214559e193855e46a90a1a0578f5e2a323995a9f2d77958"
const SOURCE_AUDIT_TOKEN := "PASS_FOR_B1_RETURNS_V2_EVIDENCE_CAPTURE"
const PACKAGE_PROOF_SHA256 := "20a54f0a274d1f750aa4d2c5d48cb6cde34c7b95357426b0766c4d1e7a0e0b04"
const PACKAGE_PROOF_TOKEN := "PASS_FOR_B1_RETURNS_V2_SOURCE_CAPTURE"
const WHOLE_XZ := Vector2(-72.9087524414062, 757.150634765625)
const WHOLE_TARGET := Vector3(0.941, 16.281, 749.703)
const NORTH_TARGET := Vector3(-33.943094, 13.625, 713.237691)
const SOUTH_TARGET := Vector3(-10.460366, 13.625, 775.572451)
const NORTH_START := Vector2(-73.766048, 758.116777)
const NORTH_NEAR := Vector2(-50.535992, 731.937310)
const SOUTH_START := Vector2(-68.008646, 758.596130)
const SOUTH_NEAR := Vector2(-34.438816, 768.498984)
const ROOF_GROUND_START := Vector2(42.34600478034784, 734.8991184777858)
const ROOF_LANDING_POINT := Vector3(29.137405752047098, 14.75, 735.945737658564)
const SPRAY_TARGET := Vector3(-46.903, 7.8, 716.5245)
const SPRAY_XZ := Vector2(-45.4565768570446, 719.3789456714961)
const B1_TIMEOUT_SECONDS := 1800.0

const MATCHED_VIEWS := [
	{"id": "01-whole-front", "role": "whole_front_tower_both_wings_and_player_scale", "xz": WHOLE_XZ, "aim": WHOLE_TARGET, "receiver": WALL_KEY, "source": SOURCE_KEY},
	{"id": "02-north-wing-far", "role": "north_wing_all_eight_upper_and_seven_lower_windows_far_60m", "xz": NORTH_START, "aim": NORTH_TARGET, "receiver": WALL_KEY, "source": SOURCE_KEY},
	{"id": "03-north-wing-near", "role": "north_wing_all_eight_upper_and_seven_lower_windows_close_depth_25m", "xz": NORTH_NEAR, "aim": NORTH_TARGET, "receiver": WALL_KEY, "source": SOURCE_KEY},
	{"id": "04-south-wing-far", "role": "south_wing_all_eight_upper_and_seven_lower_windows_far_60m", "xz": SOUTH_START, "aim": SOUTH_TARGET, "receiver": WALL_KEY, "source": SOURCE_KEY},
	{"id": "05-south-wing-near", "role": "south_wing_all_eight_upper_and_seven_lower_windows_close_depth_25m", "xz": SOUTH_NEAR, "aim": SOUTH_TARGET, "receiver": WALL_KEY, "source": SOURCE_KEY},
]

const CONTEXT_VIEWS := [
	{"id": "06-protected-rear-east", "role": "protected_rear_east_return_unchanged", "xz": Vector2(76.5, 738.0), "aim": Vector3(4.0, 16.0, 738.0), "receiver": WALL_KEY, "source": SOURCE_KEY},
	{"id": "07-tower-accepted-pose-one", "role": "separate_tower_exact_accepted_ground_pose_one", "xz": Vector2(50.451462, 686.886108), "aim": Vector3(18.0214996337891, 32.25, 720.648986816406), "receiver": TOWER_WALL_KEY, "source": TOWER_SOURCE_KEY, "horizontal_aim": true},
	{"id": "08-tower-accepted-pose-two", "role": "separate_tower_exact_accepted_ground_pose_two", "xz": Vector2(22.211432, 667.034424), "aim": Vector3(12.8684997558594, 32.25, 718.990478515625), "receiver": TOWER_WALL_KEY, "source": TOWER_SOURCE_KEY, "horizontal_aim": true},
	{"id": "11-whole-context", "role": "wide_grounded_whole_building_and_surrounding_world_context", "xz": Vector2(-120.0, 755.0), "aim": Vector3(-8.0, 16.0, 737.0), "receiver": WALL_KEY, "source": SOURCE_KEY},
]

const MOTIONS := {
	"north": {"start": NORTH_START, "near": NORTH_NEAR, "target": NORTH_TARGET},
	"south": {"start": SOUTH_START, "near": SOUTH_NEAR, "target": SOUTH_TARGET},
}

var _b1_finished := false


func _initialize() -> void:
	create_timer(B1_TIMEOUT_SECONDS, true, false, true).timeout.connect(_b1_timeout)
	call_deferred("_b1_run")


func _b1_run() -> void:
	var stage := _argument_value("--stage=")
	var mode := _argument_value("--capture-mode=")
	var output_root := _argument_value("--output-root=")
	if not _require(stage in ["baseline", "candidate"], "Pass exactly --stage=baseline or candidate.") \
	or not _require(mode in ["stills", "motion-north", "motion-south"], "Pass stills, motion-north, or motion-south.") \
	or not _require(output_root.is_absolute_path(), "Capture output root must be absolute.") \
	or not _require(_source_and_provenance_match(stage), "Source/PCK/generator/audit provenance drifted for %s." % stage) \
	or not _require(DisplayServer.get_name() == "macOS", "Capture requires native macOS display, not %s." % DisplayServer.get_name()) \
	or not _require(Engine.physics_ticks_per_second == PHYSICS_HZ, "Physics tick rate is not exactly 60 Hz."):
		_b1_finish(null)
		return
	var loaded := await _load_main_exact(stage)
	if not _require(bool(loaded.get("ok", false)), str(loaded.get("message", "Ordinary main failed."))):
		_b1_finish(loaded.get("main", null) as Node)
		return
	var main := loaded.main as GameMain
	var world := loaded.world as WorldLoader
	var player := loaded.player as PlayerController
	var hud := loaded.hud as GameHUD
	var sun := loaded.sun as DirectionalLight3D
	if not _require(Vector2i(root.get_texture().get_size()) == CAPTURE_SIZE, "Native viewport is not exactly 1440x900.") \
	or not _require(sun.rotation_degrees.is_equal_approx(DEFAULT_SUN), "World-default sun drifted before capture: %s." % sun.rotation_degrees) \
	or not _require(_camera_contract(player), "Stock FOV/spring/player visibility contract drifted."):
		_b1_finish(main)
		return
	var stage_root := output_root.path_join("stages/%s" % stage)
	if not _require(DirAccess.make_dir_recursive_absolute(stage_root) == OK, "Could not create stage root."):
		_b1_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	if mode == "stills":
		await _b1_capture_stills(main, world, player, hud, sun, stage, stage_root, loaded.bindings as Dictionary)
	else:
		await _b1_capture_motion(main, world, player, hud, sun, stage, stage_root, mode.trim_prefix("motion-"), loaded.bindings as Dictionary)
	_b1_finish(main)


static func _capture_pins_are_sealed(pins: Array) -> bool:
	for value: Variant in pins:
		var pin := str(value)
		if pin.length() != 64 or not pin.is_valid_hex_number(false):
			return false
	return not pins.is_empty()


func _source_and_provenance_match(stage: String) -> bool:
	if not _capture_pins_are_sealed([BASELINE_PCK_SHA256, CANDIDATE_PCK_SHA256, BASELINE_CONFIG_SHA256, CANDIDATE_CONFIG_SHA256, BASELINE_ADAPTER_SHA256, CANDIDATE_ADAPTER_SHA256, EXPECTED_REGISTRY_SHA256, EXPECTED_CONTRACTS_SHA256, SOURCE_AUDIT_SHA256, PACKAGE_PROOF_SHA256]):
		return false
	var proof := _argument_value("--package-proof-receipt=")
	if not proof.is_absolute_path() or not FileAccess.file_exists(proof) or FileAccess.get_sha256(proof) != PACKAGE_PROOF_SHA256 or _argument_value("--package-proof-sha256=") != PACKAGE_PROOF_SHA256:
		return false
	var proof_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(proof))
	if not proof_value is Dictionary or str(proof_value.get("status", "")) != PACKAGE_PROOF_TOKEN:
		return false
	var pck := _argument_value("--pck=")
	var pck_sha256 := _argument_value("--pck-sha256=")
	var generator := _argument_value("--generator=")
	var generator_sha256 := _argument_value("--generator-sha256=")
	var expected_pck := BASELINE_PCK_SHA256 if stage == "baseline" else CANDIDATE_PCK_SHA256
	var expected_config := BASELINE_CONFIG_SHA256 if stage == "baseline" else CANDIDATE_CONFIG_SHA256
	var expected_adapter := BASELINE_ADAPTER_SHA256 if stage == "baseline" else CANDIDATE_ADAPTER_SHA256
	return pck.is_absolute_path() and FileAccess.file_exists(pck) \
		and FileAccess.get_sha256(pck) == expected_pck and pck_sha256 == expected_pck \
		and generator.is_absolute_path() and FileAccess.file_exists(generator) \
		and FileAccess.get_sha256(generator) == generator_sha256 and generator_sha256.length() == 64 \
		and FileAccess.get_sha256(CONFIG_PATH) == expected_config \
		and FileAccess.get_sha256(ADAPTER_PATH) == expected_adapter \
		and FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256 \
		and FileAccess.get_sha256(CONTRACTS_PATH) == EXPECTED_CONTRACTS_SHA256 \
		and _argument_value("--source-audit-sha256=") == SOURCE_AUDIT_SHA256 \
		and _argument_value("--source-audit-token=") == SOURCE_AUDIT_TOKEN


func _load_main_exact(stage: String) -> Dictionary:
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if packed == null:
		return {"ok": false, "message": "Ordinary main scene did not load."}
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var hud := main.get_node("Interface/HUD") as GameHUD
	var sun := main.get_node("Sun") as DirectionalLight3D
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 90000:
		await process_frame
	while failures.is_empty() and not player.was_first_reveal_grounded() and Time.get_ticks_msec() - started < 90000:
		await physics_frame
	if not failures.is_empty() or reports.size() != 1 or not player.was_first_reveal_grounded():
		return {"ok": false, "message": "Ordinary main did not reach one clean, player-grounded ready state: %s" % failures, "main": main}
	var expected_triangles := 69252 if stage == "baseline" else 70692
	var runtime := world.get_runtime_evidence()
	if int(runtime.playable_rows) != 735 or int(runtime.mesh_instances) != 959 or int(runtime.surfaces) != 974 \
	or int(runtime.triangles) != expected_triangles or int(runtime.static_bodies) != 466 or int(runtime.shapes) != 466:
		return {"ok": false, "message": "%s runtime topology drifted: %s" % [stage, _runtime_topology(runtime)], "main": main}
	var bindings := _validate_bindings(world, stage)
	if not bool(bindings.get("ok", false)):
		return {"ok": false, "message": str(bindings.get("message", "B1/D2 bindings failed.")), "main": main}
	return {"ok": true, "main": main, "world": world, "player": player, "hud": hud, "sun": sun, "bindings": bindings.metadata}


func _validate_bindings(world: WorldLoader, stage: String) -> Dictionary:
	var expected := {
		WALL_KEY: {"meshes": 6, "surfaces": 6, "triangles": 8806 if stage == "baseline" else 10246, "faces": 2046},
		ROOF_KEY: {"meshes": 3, "surfaces": 3, "triangles": 1131, "faces": 1737},
		TOWER_WALL_KEY: {"meshes": 3, "surfaces": 3, "triangles": 760, "faces": 120},
		TOWER_ROOF_KEY: {"meshes": 1, "surfaces": 1, "triangles": 14, "faces": 42},
	}
	var result := {}
	for key: String in expected:
		var nodes := _record_nodes(world, key)
		if nodes.size() != 1:
			return {"ok": false, "message": "%s did not resolve once." % key}
		var node := nodes[0]
		var measured := _measure(node)
		if int(measured.meshes) != int(expected[key].meshes) or int(measured.surfaces) != int(expected[key].surfaces) \
		or int(measured.triangles) != int(expected[key].triangles) or int(node.get_meta("collision_face_vertices", -1)) != int(expected[key].faces):
			return {"ok": false, "message": "%s topology drifted: %s" % [key, measured]}
		result[key] = measured
	var wall := _record_nodes(world, WALL_KEY)[0]
	var reveal := wall.get_node_or_null("HeroPublicFrontReveals") as MeshInstance3D
	var reveal_triangles := -1 if reveal == null else int(reveal.mesh.get_faces().size() / 3)
	if reveal_triangles != (168 if stage == "baseline" else 168):
		return {"ok": false, "message": "%s reveal triangle count drifted: %d." % [stage, reveal_triangles]}
	var trim := wall.get_node_or_null("HeroTrim") as MeshInstance3D
	var glass := wall.get_node_or_null("HeroGlass") as MeshInstance3D
	var trim_triangles := -1 if trim == null else int(trim.mesh.get_faces().size() / 3)
	var expected_trim_hash := "8a1f4ba50ab041457f420a95ee371a304b2cd0d4509b9d644b89ed722262a6e3" if stage == "baseline" else "72f4b3305ec451504c9cafda98ba1439fcee02b50c529c036e54defe0cd179b0"
	if trim == null or glass == null or trim_triangles != (6804 if stage == "baseline" else 8244) \
	or _b1_mesh_sha256(trim.mesh as ArrayMesh) != expected_trim_hash \
	or _b1_mesh_sha256(glass.mesh as ArrayMesh) != "7d7606c94e9aea27af5da01dbd047fc6378d2fb9f5d6cb59cd7b03e282340218":
		return {"ok": false, "message": "%s exact trim/glazing geometry drifted." % stage}
	var return_openings := 0 if stage == "baseline" else int(wall.get_meta("wing_jamb_return_openings", -1))
	var return_strips := 0 if stage == "baseline" else return_openings * int(wall.get_meta("wing_jamb_return_strips_per_opening", -1))
	if return_openings != (0 if stage == "baseline" else 30) or return_strips != (0 if stage == "baseline" else 120) \
	or int(wall.get_meta("wing_dark_backing_boxes", 0)) != 0:
		return {"ok": false, "message": "%s wing-return scope drifted." % stage}
	var d2_walls := _record_nodes(world, D2_WALL_KEY)
	var d2_roofs := _record_nodes(world, D2_ROOF_KEY)
	if d2_walls.size() != 1 or d2_roofs.size() != 1 \
	or _measure(d2_walls[0]) != {"meshes": 8, "surfaces": 8, "triangles": 1568, "bodies": 1, "shapes": 1} \
	or _measure(d2_roofs[0]) != {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1}:
		return {"ok": false, "message": "Accepted D2 component topology drifted under %s." % stage}
	return {"ok": true, "metadata": {
		"building_components": result,
		"reveal_triangles": reveal_triangles,
		"trim_triangles": trim_triangles,
		"wing_return_openings": return_openings,
		"wing_return_strips": return_strips,
		"wing_dark_backing_boxes": 0,
		"d2_wall_topology": _measure(d2_walls[0]),
		"d2_roof_topology": _measure(d2_roofs[0]),
		"tower_separate_and_unchanged": true,
		"collision_ownership_unchanged": true,
	}}


func _b1_capture_stills(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, stage: String, stage_root: String, bindings: Dictionary) -> void:
	var images_root := stage_root.path_join("images")
	if not _require(DirAccess.make_dir_recursive_absolute(images_root) == OK, "Could not create still image directory."):
		return
	var manifest_path := stage_root.path_join("stills.json")
	if not _require(not FileAccess.file_exists(manifest_path), "%s still manifest already exists." % stage):
		return
	var captures: Array[Dictionary] = []
	for value: Variant in MATCHED_VIEWS:
		var view := value as Dictionary
		sun.rotation_degrees = DEFAULT_SUN
		var pose := await _settle_and_input_aim(world, player, hud, view.xz as Vector2, view.aim as Vector3, str(view.id), bool(view.get("horizontal_aim", false)))
		if not _append_pose_capture(captures, await _capture_view(main, player, hud, stage_root, str(view.id) + "-default", str(view.role), "world_default", pose, _target_los(player, view.aim as Vector3, str(view.receiver), str(view.source), str(view.id)))):
			return
		var frozen_player := player.global_transform
		var frozen_camera := player.get_camera().global_transform
		sun.rotation_degrees = CHANGED_SUN
		if not await _wait_for_render(main, player, hud):
			_fail("%s changed-light render failed." % view.id)
			return
		var changed_extra := (pose.get("metadata", {}) as Dictionary).duplicate(true)
		changed_extra.merge((_target_los(player, view.aim as Vector3, str(view.receiver), str(view.source), str(view.id) + "-changed").get("metadata", {}) as Dictionary), true)
		changed_extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
		changed_extra["same_pose_source_capture"] = "images/%s-default.png" % view.id
		changed_extra["player_transform_exactly_reused"] = player.global_transform.is_equal_approx(frozen_player)
		changed_extra["camera_transform_exactly_reused"] = player.get_camera().global_transform.is_equal_approx(frozen_camera)
		if not _append_pose_capture(captures, await _save_image(main, player, hud, stage_root, str(view.id) + "-changed", str(view.role) + "_same_pose_changed_light", "frozen_changed_light", changed_extra)):
			return
		var gray := _save_grayscale(stage_root, "images/%s-default.png" % view.id, "images/%s-grayscale.png" % view.id, str(view.id) + "-grayscale", str(view.role) + "_grayscale")
		if not _append_pose_capture(captures, gray):
			return
	for value: Variant in CONTEXT_VIEWS:
		var view := value as Dictionary
		sun.rotation_degrees = DEFAULT_SUN
		var pose := await _settle_and_input_aim(world, player, hud, view.xz as Vector2, view.aim as Vector3, str(view.id), bool(view.get("horizontal_aim", false)))
		if not _append_pose_capture(captures, await _capture_view(main, player, hud, stage_root, str(view.id), str(view.role), "world_default", pose, _target_los(player, view.aim as Vector3, str(view.receiver), str(view.source), str(view.id)))):
			return
	var spray := await _capture_real_spray(main, world, player, hud, sun, stage_root)
	if not _append_pose_capture(captures, spray):
		return
	var roof := await _capture_roof_landing(main, world, player, hud, sun, stage_root)
	if not _append_pose_capture(captures, roof):
		return
	var overview := await _capture_elevated_diagnostic(main, world, player, hud, sun, stage_root)
	if not _append_pose_capture(captures, overview):
		return
	captures.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return str(left.id) < str(right.id))
	var runtime := world.get_runtime_evidence()
	var manifest := _common_manifest(stage, bindings, runtime)
	manifest.merge({
		"schema_version": "ti.building-1-wing-returns-v2-candidate-stills/1",
		"proof_role": "matched_native_grounded_stock_player_A_B_stills_plus_contextual_traversal_and_interaction_closure",
		"fixed_view_definitions": _serializable_views(),
		"lighting": {"default_sun_rotation_degrees": _vector3(DEFAULT_SUN), "changed_sun_rotation_degrees": _vector3(CHANGED_SUN), "same_pose_changed_light": true},
		"captures": captures,
		"capture_count": captures.size(),
		"expected_capture_count": 22,
		"elevated_overview_is_diagnostic_only": true,
		"original_color_pngs_preserved": true,
		"grayscale_derived_from_saved_default_pixels": true,
	}, true)
	if not _require(captures.size() == 22, "%s wrote %d/22 still PNGs." % [stage, captures.size()]) \
	or not _require(_write_new_json(manifest_path, manifest), "Could not write %s still manifest." % stage):
		return
	print("PASS: captured %s B1 returns v2 stage with 22 native Metal PNGs: matched default/changed/grayscale wing views, protected return, tower, real spray, supported roof landing, whole context, and diagnostic overview" % stage)


func _capture_view(main: GameMain, player: PlayerController, hud: GameHUD, stage_root: String, id: String, role: String, lighting: String, pose: Dictionary, los: Dictionary) -> Dictionary:
	if not bool(pose.get("ok", false)):
		return pose
	if not bool(los.get("ok", false)):
		return los
	var extra := (pose.metadata as Dictionary).duplicate(true)
	extra.merge(los.metadata as Dictionary, true)
	extra["sun_rotation_degrees"] = _vector3((main.get_node("Sun") as DirectionalLight3D).rotation_degrees)
	return await _save_image(main, player, hud, stage_root, id, role, lighting, extra)


func _capture_real_spray(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, stage_root: String) -> Dictionary:
	sun.rotation_degrees = DEFAULT_SUN
	var pose := await _settle_and_input_aim(world, player, hud, SPRAY_XZ, SPRAY_TARGET, "09-real-spray-blank-wing-pier")
	if not bool(pose.get("ok", false)):
		return pose
	var camera := player.get_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var query := PhysicsRayQueryParameters3D.create(camera.project_ray_origin(center), camera.project_ray_origin(center) + camera.project_ray_normal(center) * 1000.0, 1 << 2, [player.get_rid()])
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	var collider := hit.get("collider", null) as CollisionObject3D
	if hit.is_empty() or collider == null or str(collider.get_meta("derived_object_key", "")) != WALL_KEY \
	or collider.get_meta("source_keys", []) != [SOURCE_KEY] or not collider.is_in_group("spray_receiver_wall") \
	or player.global_position.distance_to(hit.position as Vector3) > player.get_spray_controller().maximum_range_m:
		return {"ok": false, "message": "Real spray did not first-hit the eligible blank B1 wing pier within controller range: %s" % hit}
	var controller := player.get_spray_controller()
	var before := controller.tag_instances.active_count()
	var placed_before := int((world.get_runtime_evidence().spray_counts as Dictionary).placed)
	player.set_gameplay_enabled(true)
	controller.attempt_spray()
	await process_frame
	player.set_gameplay_enabled(false)
	if controller.tag_instances.active_count() != before + 1 or int((world.get_runtime_evidence().spray_counts as Dictionary).placed) != placed_before + 1:
		return {"ok": false, "message": "Real SprayController did not place exactly one B1 tag."}
	var tag := controller.tag_instances.get_child(controller.tag_instances.get_child_count() - 1) as Decal
	if tag == null or str(tag.get_meta("derived_object_key", "")) != WALL_KEY or tag.get_meta("source_keys", []) != [SOURCE_KEY]:
		return {"ok": false, "message": "Placed B1 tag lost exact receiver identity."}
	var extra := (pose.metadata as Dictionary).duplicate(true)
	extra.merge({
		"sun_rotation_degrees": _vector3(sun.rotation_degrees),
		"spray_result": "placed",
		"spray_controller_route": "real_SprayController_attempt_spray",
		"spray_first_hit_object": WALL_KEY,
		"spray_first_hit_sources": [SOURCE_KEY],
		"spray_first_hit_position_m": _vector3(hit.position as Vector3),
		"spray_first_hit_normal": _vector3(hit.normal as Vector3),
		"spray_player_to_hit_distance_m": player.global_position.distance_to(hit.position as Vector3),
		"targeted_blank_pier_band": "below_lower_north_wing_window_schedule",
		"tag_position_m": _vector3(tag.global_position),
		"tag_visible_in_tree": tag.is_visible_in_tree(),
	}, true)
	return await _save_image(main, player, hud, stage_root, "09-real-spray-blank-wing-pier", "real_predefined_spray_on_eligible_blank_B1_wall_pier", "world_default", extra)


func _capture_roof_landing(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, stage_root: String) -> Dictionary:
	sun.rotation_degrees = DEFAULT_SUN
	var start_pose := await _settle_and_input_aim(world, player, hud, ROOF_GROUND_START, Vector3(ROOF_LANDING_POINT.x, 18.0, ROOF_LANDING_POINT.z), "10-real-player-main-roof-landing-start", true)
	if not bool(start_pose.get("ok", false)):
		return start_pose
	var recoveries_before := int(world.get_runtime_evidence().recovery_count)
	var route_start := player.global_position
	var ticks := 0
	var jetpack_ticks := 0
	player.set_gameplay_enabled(true)
	Input.action_press("jetpack")
	while player.global_position.y < 18.0 and ticks < 420:
		await physics_frame
		ticks += 1
		jetpack_ticks += 1
		_clean_hud(hud)
	Input.action_press("move_forward")
	while Vector2(player.global_position.x, player.global_position.z).distance_to(Vector2(ROOF_LANDING_POINT.x, ROOF_LANDING_POINT.z)) > 0.55 and ticks < 900:
		if player.global_position.y < 18.0:
			Input.action_press("jetpack")
		elif player.global_position.y > 20.0:
			Input.action_release("jetpack")
		if Input.is_action_pressed("jetpack"):
			jetpack_ticks += 1
		await physics_frame
		ticks += 1
		_clean_hud(hud)
		if int(world.get_runtime_evidence().recovery_count) != recoveries_before:
			_clear_input()
			return {"ok": false, "message": "Roof route triggered recovery."}
	Input.action_release("move_forward")
	Input.action_release("jetpack")
	var landed := false
	var descent_ticks := 0
	for _index in 900:
		await physics_frame
		descent_ticks += 1
		ticks += 1
		_clean_hud(hud)
		if player.is_on_floor() and absf(player.velocity.y) <= 0.05:
			landed = true
			break
	_clear_input()
	var support := _support_below(player)
	var final_error := Vector2(player.global_position.x, player.global_position.z).distance_to(Vector2(ROOF_LANDING_POINT.x, ROOF_LANDING_POINT.z))
	if not landed or str(support.get("object_key", "")) != ROOF_KEY or support.get("source_keys", []) != [SOURCE_KEY] \
	or absf(float((support.get("hit_position_m", [0, -INF, 0]) as Array)[1]) - 14.75) > 0.03 or final_error > 1.25 \
	or int(world.get_runtime_evidence().recovery_count) != recoveries_before:
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": "Real roof landing failed: landed=%s support=%s error=%.3f pos=%s" % [landed, support, final_error, player.global_position]}
	# Look back across the supported tier toward the full main block. The tower
	# itself already has two exact accepted ground views; forcing it to screen
	# center from this roof would exceed the stock camera's +25 degree pitch.
	var final_aim := await _input_aim(player, WHOLE_TARGET, false)
	player.set_gameplay_enabled(false)
	if not bool(final_aim.get("ok", false)):
		return {"ok": false, "message": "Roof landing final camera aim failed: %s" % final_aim}
	var extra := (start_pose.metadata as Dictionary).duplicate(true)
	extra.merge({
		"sun_rotation_degrees": _vector3(sun.rotation_degrees),
		"real_player_jetpack_route": true,
		"input_actions": ["jetpack", "move_forward"],
		"route_start_player_position_m": _vector3(route_start),
		"player_position_m": _vector3(player.global_position),
		"route_physics_ticks": ticks,
		"descent_physics_ticks": descent_ticks,
		"jetpack_pressed_ticks": jetpack_ticks,
		"player_transform_writes_after_route_start": 0,
		"camera_transform_writes_after_route_start": 0,
		"roof_landing_world_solid": true,
		"support": support,
		"landing_horizontal_error_m": final_error,
		"recovery_delta": 0,
		"final_input_aim": final_aim,
	}, true)
	return await _save_image(main, player, hud, stage_root, "10-real-player-main-roof-landing", "real_controller_and_jetpack_supported_main_roof_landing", "world_default", extra)


func _capture_elevated_diagnostic(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, stage_root: String) -> Dictionary:
	var recoveries_before := int(world.get_runtime_evidence().recovery_count)
	var start := player.global_position
	var ticks := 0
	player.set_gameplay_enabled(true)
	Input.action_press("jetpack")
	while player.global_position.y < 39.0 and ticks < 600:
		await physics_frame
		ticks += 1
		_clean_hud(hud)
	Input.action_release("jetpack")
	var aimed := await _input_aim(player, Vector3(-8.0, 16.0, 737.0), false)
	player.set_gameplay_enabled(false)
	if not bool(aimed.get("ok", false)) or ticks >= 600 or int(world.get_runtime_evidence().recovery_count) != recoveries_before:
		return {"ok": false, "message": "Elevated diagnostic input ascent/aim failed."}
	return await _save_image(main, player, hud, stage_root, "12-elevated-overview-diagnostic-only", "elevated_overview_diagnostic_only_not_acceptance", "world_default", {
		"diagnostic_only": true,
		"acceptance_view": false,
		"real_jetpack_input": true,
		"player_transform_writes": 0,
		"camera_transform_writes": 0,
		"start_player_position_m": _vector3(start),
		"player_position_m": _vector3(player.global_position),
		"jetpack_physics_ticks": ticks,
		"airborne": not player.is_on_floor(),
		"recovery_delta": 0,
		"input_aim": aimed,
		"sun_rotation_degrees": _vector3(sun.rotation_degrees),
	})


func _b1_capture_motion(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, stage: String, stage_root: String, side: String, bindings: Dictionary) -> void:
	if not _require(_argument_value("--fixed-fps-receipt=") == "60", "Motion requires explicit fixed-fps 60 invocation receipt."):
		return
	var motion := MOTIONS.get(side, {}) as Dictionary
	var output_dir := stage_root.path_join("motion/%s" % side)
	var manifest_path := stage_root.path_join("motion-%s.json" % side)
	if not _require(not motion.is_empty() and DirAccess.make_dir_recursive_absolute(output_dir) == OK, "Could not prepare %s motion output." % side) \
	or not _require(not FileAccess.file_exists(manifest_path), "%s %s motion manifest already exists." % [stage, side]):
		return
	sun.rotation_degrees = DEFAULT_SUN
	var pose := await _settle_and_input_aim(world, player, hud, motion.start as Vector2, motion.target as Vector3, "%s-motion-start" % side)
	if not _require(bool(pose.get("ok", false)), str(pose.get("message", "%s motion start failed." % side))):
		return
	var start_position := player.global_position
	var start_distance := Vector2(start_position.x, start_position.z).distance_to(Vector2((motion.target as Vector3).x, (motion.target as Vector3).z))
	var target_near_distance := (motion.near as Vector2).distance_to(Vector2((motion.target as Vector3).x, (motion.target as Vector3).z))
	if not _require(absf(start_distance - 60.0) <= 0.05 and absf(target_near_distance - 25.0) <= 0.001, "%s frozen 60m->25m trajectory drifted." % side):
		return
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var desired := Vector3((motion.target as Vector3).x - start_position.x, 0.0, (motion.target as Vector3).z - start_position.z).normalized()
	if not _require(rig.planar_forward().dot(desired) >= 0.9999, "%s move_forward is not aligned to frozen trajectory." % side):
		return
	var sampler := B1PostPlayerSampler.new()
	sampler.name = "B1%sPostPlayerSampler" % side.capitalize()
	sampler.configure(player, motion.target as Vector3)
	player.get_parent().add_child(sampler)
	player.set_gameplay_enabled(true)
	var baseline_value: Variant = await sampler.sampled
	player.set_gameplay_enabled(false)
	var baseline := baseline_value as Dictionary
	var pending: Array[Dictionary] = []
	var telemetry: Array[Dictionary] = []
	var thresholds: Array[float] = [60.0, 45.0, 30.0, 25.0]
	var next_threshold := 0
	var group_remaining := 0
	var group_threshold := 0.0
	var group_offset := 0
	var recoveries_before := int(world.get_runtime_evidence().recovery_count)
	var camera_basis := player.get_camera().global_basis
	# Exact 60 m pre-input image, followed by two true motion frames.
	await RenderingServer.frame_post_draw
	pending.append(_stage_motion_image(side, 60.0, 0, player, sampler.latest))
	next_threshold = 1
	group_remaining = 2
	group_threshold = 60.0
	group_offset = 1
	player.set_gameplay_enabled(true)
	Input.action_press("move_forward")
	var last_distance := start_distance
	var route_frames := 0
	while route_frames < 900 and (next_threshold < thresholds.size() or group_remaining > 0):
		var value: Variant = await sampler.sampled
		var sample := value as Dictionary
		route_frames += 1
		var distance := float(sample.target_distance_m)
		var state_ok := player.is_on_floor() and world.get_boundary().contains_position(player.global_position) \
			and Input.is_action_pressed("move_forward") and not Input.is_action_pressed("run") and not Input.is_action_pressed("jetpack") \
			and player.get_camera().global_basis.is_equal_approx(camera_basis) and distance <= last_distance + 0.0001 \
			and int(world.get_runtime_evidence().recovery_count) == recoveries_before
		if not state_ok:
			_stop_motion(player, sampler)
			_fail("%s motion state drifted at frame %d distance %.4f." % [side, route_frames, distance])
			return
		telemetry.append({
			"route_frame": route_frames,
			"engine_physics_frame": int(sample.engine_physics_frame),
			"player_position_m": sample.player_position_m,
			"target_distance_m": distance,
			"velocity_mps": _vector3(player.velocity),
			"grounded": true,
		})
		if group_remaining == 0 and next_threshold < thresholds.size() and distance <= thresholds[next_threshold]:
			group_threshold = thresholds[next_threshold]
			group_remaining = 3
			group_offset = 0
			next_threshold += 1
		if group_remaining > 0:
			await RenderingServer.frame_post_draw
			var staged := _stage_motion_image(side, group_threshold, group_offset, player, sampler.latest)
			if not bool(staged.get("ok", false)):
				_stop_motion(player, sampler)
				_fail(str(staged.get("message", "%s motion image failed." % side)))
				return
			pending.append(staged)
			group_remaining -= 1
			group_offset += 1
		last_distance = distance
	_stop_motion(player, sampler)
	for _index in 12:
		await physics_frame
	var written := _write_motion_images(stage_root, pending)
	if not _require(bool(written.get("ok", false)), str(written.get("message", "Motion PNG write failed."))):
		return
	var captures := written.captures as Array
	var runtime := world.get_runtime_evidence()
	var manifest := _common_manifest(stage, bindings, runtime)
	manifest.merge({
		"schema_version": "ti.building-1-wing-returns-v2-candidate-motion/1",
		"side": side,
		"proof_role": "fixed_60fps_true_stock_controller_60m_to_25m_parallax_shimmer_zfight_motion",
		"trajectory": {"start_xz": [motion.start.x, motion.start.y], "near_xz": [motion.near.x, motion.near.y], "target_m": _vector3(motion.target as Vector3), "start_distance_m": start_distance, "near_distance_m": target_near_distance},
		"motion_start_pose": pose.metadata,
		"sampler_phase": "dedicated_node_physics_callback_after_PlayerController",
		"sampler_priority_strictly_after_player": true,
		"fixed_fps_operator_request": FIXED_FPS,
		"physics_ticks_per_second": PHYSICS_HZ,
		"input_action": "move_forward",
		"run_action_pressed": false,
		"jetpack_action_pressed": false,
		"player_transform_writes_after_motion_start": 0,
		"camera_transform_writes_after_motion_start": 0,
		"camera_basis_unchanged": true,
		"recovery_delta": 0,
		"thresholds_m": thresholds,
		"images_per_threshold": 3,
		"capture_tolerance_m": MOTION_POSE_TOLERANCE_M,
		"baseline_sampler_snapshot": baseline,
		"route_physics_frames": route_frames,
		"telemetry": telemetry,
		"captures": captures,
		"capture_count": captures.size(),
		"png_encoding_deferred_until_after_input_release": true,
	}, true)
	if not _require(captures.size() == 12, "%s %s motion wrote %d/12 images." % [stage, side, captures.size()]) \
	or not _require(_motion_thresholds_exact(captures), "%s %s motion samples escaped thresholds/tolerance." % [stage, side]) \
	or not _require(_write_new_json(manifest_path, manifest), "Could not write %s %s motion manifest." % [stage, side]):
		return
	print("PASS: captured %s %s fixed-60fps stock-controller motion with 12 post-draw frames at 60/45/30/25m, zero transform writes/recoveries, and deferred PNG encoding" % [stage, side])


func _stage_motion_image(side: String, threshold: float, offset: int, player: PlayerController, snapshot: Dictionary) -> Dictionary:
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s %.0fm motion image is empty/wrong-sized." % [side, threshold]}
	var distance := Vector2(player.global_position.x, player.global_position.z).distance_to(Vector2((MOTIONS[side].target as Vector3).x, (MOTIONS[side].target as Vector3).z))
	if absf(distance - threshold) > MOTION_POSE_TOLERANCE_M:
		return {"ok": false, "message": "%s %.0fm offset%d frame is %.4fm from threshold." % [side, threshold, offset, distance]}
	return {"ok": true, "image": image, "metadata": {
		"id": "%s-%02dm-%d" % [side, int(threshold), offset],
		"file": "motion/%s/%02dm-%d.png" % [side, int(threshold), offset],
		"side": side,
		"threshold_m": threshold,
		"sequence_offset": offset,
		"actual_distance_m": distance,
		"actual_minus_threshold_m": distance - threshold,
		"player_position_m": _vector3(player.global_position),
		"camera_position_m": _vector3(player.get_camera().global_position),
		"engine_physics_frame": int(snapshot.get("engine_physics_frame", Engine.get_physics_frames())),
		"sampler_sequence": int(snapshot.get("sequence", -1)),
		"post_draw_original_pixels": true,
		"dimensions": [image.get_width(), image.get_height()],
	}}


func _write_motion_images(stage_root: String, pending: Array[Dictionary]) -> Dictionary:
	var captures: Array[Dictionary] = []
	for item: Dictionary in pending:
		if not bool(item.get("ok", false)):
			return item
		var image := item.image as Image
		var metadata := (item.metadata as Dictionary).duplicate(true)
		var path := stage_root.path_join(str(metadata.file))
		if FileAccess.file_exists(path) or image.save_png(path) != OK:
			return {"ok": false, "message": "Motion PNG would overwrite or failed: %s." % metadata.file}
		metadata["sha256"] = FileAccess.get_sha256(path)
		metadata["bytes"] = FileAccess.get_file_as_bytes(path).size()
		captures.append(metadata)
	return {"ok": true, "captures": captures}


func _motion_thresholds_exact(captures: Array) -> bool:
	if captures.size() != 12:
		return false
	var counts := {}
	for value: Variant in captures:
		var item := value as Dictionary
		var threshold := int(round(float(item.get("threshold_m", -1.0))))
		counts[threshold] = int(counts.get(threshold, 0)) + 1
		if absf(float(item.get("actual_distance_m", INF)) - float(item.get("threshold_m", -INF))) > MOTION_POSE_TOLERANCE_M:
			return false
	return counts == {60: 3, 45: 3, 30: 3, 25: 3}


func _settle_and_input_aim(world: WorldLoader, player: PlayerController, hud: GameHUD, requested_xz: Vector2, target: Vector3, pose_id: String, horizontal_only: bool = false) -> Dictionary:
	if not world.get_boundary().contains_position(Vector3(requested_xz.x, 0.0, requested_xz.y)):
		return {"ok": false, "message": "%s anchor is outside playable boundary." % pose_id}
	var hit := _ground_hit(player, requested_xz)
	var ground := _ground_metadata(hit)
	if not bool(ground.get("ok", false)):
		return {"ok": false, "message": "%s has no generated ground support: %s" % [pose_id, ground]}
	_clear_input()
	player.set_gameplay_enabled(false)
	var ground_y := float(hit.position.y)
	player.global_transform = Transform3D(Basis.IDENTITY, Vector3(requested_xz.x, ground_y + 3.0, requested_xz.y))
	player.velocity = Vector3.DOWN * 0.1
	player.force_update_transform()
	var recovery_before := int(world.get_runtime_evidence().recovery_count)
	player.set_gameplay_enabled(true)
	var settled := false
	var frames := 0
	for frame in 360:
		await physics_frame
		frames = frame + 1
		_clean_hud(hud)
		if player.is_on_floor() and absf(player.global_position.y - ground_y) <= 0.08 and absf(player.velocity.y) <= 0.05:
			settled = true
			break
	_clear_input()
	if not settled or int(world.get_runtime_evidence().recovery_count) != recovery_before:
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": "%s did not physics-settle without recovery." % pose_id}
	var drift := Vector2(player.global_position.x - requested_xz.x, player.global_position.z - requested_xz.y).length()
	var aimed := await _input_aim(player, target, horizontal_only)
	player.set_gameplay_enabled(false)
	if drift > 0.02 or not bool(aimed.get("ok", false)) or not await _wait_for_render(main_from_player(player), player, hud):
		return {"ok": false, "message": "%s pose/aim/render failed: drift=%.4f aim=%s" % [pose_id, drift, aimed]}
	var camera := player.get_camera()
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	return {"ok": true, "metadata": {
		"pose_id": pose_id,
		"requested_xz": [requested_xz.x, requested_xz.y],
		"player_position_m": _vector3(player.global_position),
		"camera_position_m": _vector3(camera.global_position),
		"camera_forward": _vector3(-camera.global_basis.z),
		"aim_target_m": _vector3(target),
		"physics_grounded": true,
		"ground_y_m": ground_y,
		"ground_feature": str(ground.feature),
		"ground_object": str(ground.object_key),
		"ground_sources": ground.source_keys,
		"settle_physics_frames": frames,
		"settle_horizontal_drift_m": drift,
		"recovery_delta": 0,
		"camera_fov_degrees": camera.fov,
		"configured_spring_length_m": arm.spring_length,
		"actual_spring_length_m": camera.global_position.distance_to(rig.global_position),
		"input_aim": aimed,
		"player_transform_writes_for_static_pose": 1,
		"camera_transform_writes": 0,
	}}


func _input_aim(player: PlayerController, target: Vector3, horizontal_only: bool) -> Dictionary:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var delta := target - rig.global_position
	if horizontal_only:
		delta.y = 0.0
	var horizontal := Vector2(delta.x, delta.z).length()
	if horizontal < 0.001:
		return {"ok": false, "message": "Input aim target is singular."}
	var local_delta := ((rig.get_parent() as Node3D).global_basis.inverse() * delta)
	var desired_yaw := atan2(-local_delta.x, -local_delta.z)
	var desired_pitch := 0.0 if horizontal_only else atan2(delta.y, horizontal)
	if desired_pitch < deg_to_rad(rig.minimum_pitch_degrees) or desired_pitch > deg_to_rad(rig.maximum_pitch_degrees):
		return {"ok": false, "message": "Input aim pitch escaped stock limits."}
	player.set_gameplay_enabled(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for _attempt in 4:
		var yaw_delta := angle_difference(rig.rotation.y, desired_yaw)
		var pitch_delta := desired_pitch - arm.rotation.x
		if absf(yaw_delta) <= 0.0001 and absf(pitch_delta) <= 0.0001:
			break
		var event := InputEventMouseMotion.new()
		event.relative = Vector2(-yaw_delta / rig.look_sensitivity, -pitch_delta / rig.look_sensitivity)
		Input.parse_input_event(event)
		await process_frame
	var yaw_error := absf(angle_difference(rig.rotation.y, desired_yaw))
	var pitch_error := absf(arm.rotation.x - desired_pitch)
	return {"ok": yaw_error <= 0.001 and pitch_error <= 0.001, "input_route": "Input.parse_input_event_to_stock_PlayerCamera", "yaw_degrees": rad_to_deg(rig.rotation.y), "pitch_degrees": rad_to_deg(arm.rotation.x), "yaw_error_degrees": rad_to_deg(yaw_error), "pitch_error_degrees": rad_to_deg(pitch_error)}


func _target_los(player: PlayerController, target: Vector3, receiver: String, source: String, pose_id: String) -> Dictionary:
	var camera := player.get_camera()
	if camera.is_position_behind(target):
		return {"ok": false, "message": "%s target is behind stock camera." % pose_id}
	var origin := camera.global_position
	# The frozen aim points are on the visible facade plane. Extend through that
	# plane so endpoint precision never turns a truthful contact into a miss.
	var direction := (target - origin).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 2000.0, 1 << 0, [player.get_rid()])
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	var collider := hit.get("collider", null) as CollisionObject3D
	if hit.is_empty() or collider == null or str(collider.get_meta("derived_object_key", "")) != receiver or collider.get_meta("source_keys", []) != [source]:
		return {"ok": false, "message": "%s LOS hit %s instead of %s [%s]." % [pose_id, "" if collider == null else str(collider.get_meta("derived_object_key", "")), receiver, source]}
	var projected := camera.unproject_position(target)
	return {"ok": true, "metadata": {"receiver_first_los": true, "first_los_hit_receiver": receiver, "first_los_hit_source_keys": [source], "first_los_hit_position_m": _vector3(hit.position as Vector3), "first_los_hit_distance_m": origin.distance_to(hit.position as Vector3), "aim_target_screen_px": [projected.x, projected.y]}}


func _support_below(player: PlayerController) -> Dictionary:
	var start := player.global_position + Vector3.UP
	var query := PhysicsRayQueryParameters3D.create(start, start + Vector3.DOWN * 6.0, 1 << 0, [player.get_rid()])
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return {"ok": false}
	var collider := hit.get("collider") as CollisionObject3D
	var parent := collider.get_parent() if collider != null else null
	return {"ok": collider != null, "object_key": "" if collider == null else str(collider.get_meta("derived_object_key", "")), "source_keys": [] if collider == null else collider.get_meta("source_keys", []), "feature_kind": "" if parent == null else str(parent.get_meta("feature_kind", "")), "hit_position_m": _vector3(hit.position as Vector3), "hit_normal": _vector3(hit.normal as Vector3)}


func _save_image(main: GameMain, player: PlayerController, hud: GameHUD, stage_root: String, id: String, role: String, lighting: String, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s render did not stabilize." % id}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s image is empty/wrong-sized." % id}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s appears blank." % id}
	var relative := "images/%s.png" % id
	var path := stage_root.path_join(relative)
	if FileAccess.file_exists(path) or image.save_png(path) != OK:
		return {"ok": false, "message": "%s would overwrite or failed." % id}
	var metadata := {"id": id, "role": role, "lighting": lighting, "file": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [image.get_width(), image.get_height()], "sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range), "player_visible": player.visible and player.is_visible_in_tree(), "stock_player_rig": true, "debug_labels_visible": false, "crop_or_postprocess": false, "source_photography_in_frame": false, "visual_verdict": "pending_independent_bar_raiser_review"}
	metadata.merge(extra, true)
	if not bool(metadata.player_visible):
		return {"ok": false, "message": "%s player is not visible in the ordinary scene tree." % id}
	print("B1_REVEAL_CAPTURE: id=%s sha256=%s" % [id, metadata.sha256])
	return {"ok": true, "metadata": metadata}


func _save_grayscale(stage_root: String, source_relative: String, target_relative: String, id: String, role: String) -> Dictionary:
	var source_path := stage_root.path_join(source_relative)
	var target_path := stage_root.path_join(target_relative)
	var image := Image.load_from_file(source_path)
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE or FileAccess.file_exists(target_path):
		return {"ok": false, "message": "%s grayscale source/target is invalid." % id}
	image.convert(Image.FORMAT_L8)
	if image.save_png(target_path) != OK:
		return {"ok": false, "message": "%s grayscale save failed." % id}
	return {"ok": true, "metadata": {"id": id, "role": role, "lighting": "derived_from_world_default", "file": target_relative, "sha256": FileAccess.get_sha256(target_path), "bytes": FileAccess.get_file_as_bytes(target_path).size(), "dimensions": [image.get_width(), image.get_height()], "derivation_source": source_relative, "derivation_source_sha256": FileAccess.get_sha256(source_path), "grayscale_only": true, "derived_byte_for_byte_from_saved_default_pixels": true, "crop_or_postprocess": false, "visual_verdict": "pending_independent_bar_raiser_review"}}


func _append_pose_capture(captures: Array[Dictionary], result: Dictionary) -> bool:
	if not _require(bool(result.get("ok", false)), str(result.get("message", "Capture failed."))):
		return false
	captures.append(result.metadata as Dictionary)
	return true


func _common_manifest(stage: String, bindings: Dictionary, runtime: Variant) -> Dictionary:
	return {
		"packet_id": PACKET_ID,
		"capture_date": CAPTURE_DATE,
		"stage": stage,
		"candidate_status": "isolated_uncommitted_no_credit_quality_candidate",
		"review_status": "pending_independent_bar_raiser_review_not_self_accepted",
		"recognition_status": "current_v9_9_of_213_unchanged",
		"recognition_credit": false,
		"additional_recognition_credit": false,
		"promotion": false,
		"visual_verdict": "pending_independent_bar_raiser_review",
		"source_vs_package_provenance": {
			"render_source": "exact_source_checkout_not_exported_PCK",
			"sealed_corresponding_PCK_role": "separately_hash_bound_and_direct_mounted_component_contract",
			"pck_sha256": BASELINE_PCK_SHA256 if stage == "baseline" else CANDIDATE_PCK_SHA256,
			"config_sha256": BASELINE_CONFIG_SHA256 if stage == "baseline" else CANDIDATE_CONFIG_SHA256,
			"adapter_sha256": BASELINE_ADAPTER_SHA256 if stage == "baseline" else CANDIDATE_ADAPTER_SHA256,
		},
		"generator": "game/tests/building_1_wing_returns_v2_candidate_capture.gd",
		"generator_sha256": _argument_value("--generator-sha256="),
		"source_audit": {"sha256": SOURCE_AUDIT_SHA256, "token": SOURCE_AUDIT_TOKEN},
		"package_proof": {"sha256": PACKAGE_PROOF_SHA256, "token": PACKAGE_PROOF_TOKEN, "source_pixels_are_package_pixels": false},
		"runtime_environment": {"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(), "video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y]},
		"camera_contract": {"rig": "actual Player/CameraPivot/SpringArm3D/Camera3D", "fov_degrees": 70.0, "configured_spring_length_m": 5.5, "player_visible": true, "detached_camera": false, "labels_or_debug_overlays": false},
		"runtime_topology": _runtime_topology(runtime),
		"bindings": bindings,
		"authority": {"registry_sha256": EXPECTED_REGISTRY_SHA256, "contracts_sha256": EXPECTED_CONTRACTS_SHA256, "metric": "9/213", "authority_mutated": false, "frozen_D2_bridges_mutated": false},
		"capture_command": "Godot 4.7.2 native macOS Metal --path <exact-stage-source-checkout> --resolution 1440x900 --script <identical-generator> -- --stage=%s --capture-mode=<mode> --output-root=<packet> --pck=<sealed-corresponding-pck> --pck-sha256=<exact> --generator=<exact> --generator-sha256=<exact> --source-audit-sha256=<exact> --source-audit-token=%s" % [stage, SOURCE_AUDIT_TOKEN],
		"no_absolute_paths_recorded": true,
	}


func _serializable_views() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Variant in MATCHED_VIEWS:
		var view := value as Dictionary
		result.append({"id": str(view.id), "role": str(view.role), "requested_xz": [view.xz.x, view.xz.y], "aim_target_m": _vector3(view.aim as Vector3), "default_sun_rotation_degrees": _vector3(DEFAULT_SUN), "changed_sun_rotation_degrees": _vector3(CHANGED_SUN)})
	return result


func _runtime_topology(runtime: Variant) -> Dictionary:
	return {"rows": int(runtime.playable_rows), "meshes": int(runtime.mesh_instances), "surfaces": int(runtime.surfaces), "triangles": int(runtime.triangles), "bodies": int(runtime.static_bodies), "shapes": int(runtime.shapes)}


func _camera_contract(player: PlayerController) -> bool:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	return is_equal_approx(player.get_camera().fov, 70.0) and is_equal_approx(arm.spring_length, 5.5) and player.visible


func _measure(node: Node) -> Dictionary:
	var result := {"meshes": 0, "surfaces": 0, "triangles": 0, "bodies": 0, "shapes": 0}
	for candidate: Node in node.find_children("*", "", true, false):
		if candidate is MeshInstance3D:
			result.meshes += 1
			result.surfaces += (candidate as MeshInstance3D).mesh.get_surface_count()
			result.triangles += int((candidate as MeshInstance3D).mesh.get_faces().size() / 3)
		elif candidate is StaticBody3D:
			result.bodies += 1
		elif candidate is CollisionShape3D:
			result.shapes += 1
	return result


func _write_new_json(path: String, value: Dictionary) -> bool:
	if FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true


func _stop_motion(player: PlayerController, sampler: B1PostPlayerSampler) -> void:
	Input.action_release("move_forward")
	_clear_input()
	player.set_gameplay_enabled(false)
	if is_instance_valid(sampler):
		sampler.set_physics_process(false)
		sampler.queue_free()


func _b1_timeout() -> void:
	if not _b1_finished:
		_fail("Building 1 reveal capture timed out after %.0f seconds." % B1_TIMEOUT_SECONDS)
		_b1_finish(null)


func _b1_finish(main: Node) -> void:
	if _b1_finished:
		return
	_b1_finished = true
	_clear_input()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	paused = false
	if main != null and is_instance_valid(main):
		main.queue_free()
	quit(1 if not _failure.is_empty() else 0)


func _b1_mesh_sha256(mesh: ArrayMesh) -> String:
	if mesh == null or mesh.get_surface_count() != 1:
		return ""
	var arrays := mesh.surface_get_arrays(0)
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	for slot in [Mesh.ARRAY_VERTEX, Mesh.ARRAY_NORMAL, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_INDEX]:
		var value: Variant = arrays[slot]
		if value is PackedVector3Array:
			context.update((value as PackedVector3Array).to_byte_array())
		elif value is PackedVector2Array:
			context.update((value as PackedVector2Array).to_byte_array())
		elif value is PackedInt32Array:
			context.update((value as PackedInt32Array).to_byte_array())
	return context.finish().hex_encode()

