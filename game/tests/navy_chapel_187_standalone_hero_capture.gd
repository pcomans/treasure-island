extends SceneTree

const PROTOTYPE := preload("res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd")
const OUTPUT := "res://evidence/first-playable/navy-chapel-187-standalone-hero-2026-09-04"
const PROTOTYPE_SCENE_PATH := "res://game/scenes/world/facades/navy_chapel_187/navy_chapel_187_standalone_hero_prototype.tscn"
const CONFIG_PATH := "res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const PACKET_PATH := "res://discovery/facades/p3_reference_packets/w291189336_navy_chapel_building_187.md"
const WALL_KEY := "building:w291189336:wall"
const ROOF_KEY := "building:w291189336:roof"
const SOURCE_KEY := "w291189336"
const CAPTURE_SIZE := Vector2i(1440, 900)
const WORLD_SOLID_MASK := 1
const SETTLE_START_HEIGHT_M := 3.0
const SETTLE_MAX_PHYSICS_FRAMES := 360
const SETTLE_CLEARANCE_TOLERANCE_M := 0.08
const MIN_ACTUAL_SPRING_LENGTH_M := 4.5
const MIN_CAMERA_HEIGHT_ABOVE_GROUND_M := 1.0
const MIN_TARGET_WIDTH_RATIO := 0.12
const MIN_TARGET_HEIGHT_RATIO := 0.025
const TIMEOUT_SECONDS := 240.0
const EXPECTED_SUN_ROTATION_DEGREES := Vector3(-52.0, -28.0, 0.0)
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/navy_chapel_187_standalone_hero_capture.gd"
const CONFUSION_SET_SOURCE_IDS := ["w291189918", "w291189926", "w34313521"]
const FROZEN_SUPPORTED_CUES := [
	"strong SSE gable with tall vertically divided multipane window above a shallow projecting entry",
	"square belfry above the roof with pyramidal cap and restrained visible cross",
	"warm cream SSE field and bounded partial public-side rhythm of tall narrow opening groups",
]
const PINNED_INPUTS := {
	CONFIG_PATH: "c8f2ab09f3943a5ec8abea7cb9a108f49990bff1d83003c3b3622187a269dea2",
	CHUNK_PATH: "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	PACKET_PATH: "7eb592503ce8e276c38ef3ecaf7f2d3dd17e1eeb32adbe45d1059c5cb4693330",
	"res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd": "067c12e29c9fd352915ef2a501fcd7687b450081c79a4281d63bbfef1c19e7db",
	PROTOTYPE_SCENE_PATH: "2ab7db7ef064bf8d9d59fb3dd631dd1b7cddd9fc18eebbb67832e75df8eb8083",
	"res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres": "91cd7ce14550bdfb6773a4013ef0db8bbb24bd5cc9d0734f6c591f23d6552206",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres": "2ee243415387c9f3d9dfd5664c0a5e13107745a83d9dcb489dd39e5aeb2ff17a",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres": "b565aa44566a0bb93d07d041b1e8331d9f35cb83ec34f6a2ec403b362311c380",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres": "253e9c2a5013f81aed446f6e55b702dea3792189658ce285726788d15376bc41",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres": "89be7fbe0feb68525c5423540d3a6f17f269567875174f23522b4e964ba737b1",
}
const VIEWS := [
	{
		"id": "01-whole-object",
		"role": "whole_object_ordinary_player_view",
		"requested_xz": Vector2(-52.0, 675.0),
		"aim_target": Vector3(-100.468506, 9.019500, 648.694946),
		"expected_run_index": 9,
	},
	{
		"id": "02-oblique-approach",
		"role": "oblique_ordinary_player_view",
		"requested_xz": Vector2(-36.0, 668.0),
		"aim_target": Vector3(-100.468506, 9.019500, 648.694946),
		"expected_run_index": 9,
	},
]

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Chapel standalone evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for path: String in PINNED_INPUTS:
		if not _require(FileAccess.get_sha256(path) == str(PINNED_INPUTS[path]), "Pinned Chapel capture input drifted: %s." % path):
			_finish(null)
			return
	if not _require(Vector2i(root.get_texture().get_size()) == CAPTURE_SIZE, "Chapel capture viewport is not exactly 1440x900."):
		_finish(null)
		return
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	var wall_record := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof_record := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	if not _require(PROTOTYPE.matches_record_pair(wall_record, roof_record), "Pinned Chapel wall+roof source pair failed the standalone factory seam."):
		_finish(null)
		return
	var packed_main := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed_main != null, "Main scene did not load for grounded Chapel evidence."):
		_finish(null)
		return
	var main := packed_main.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var hud := main.get_node("Interface/HUD") as GameHUD
	var sun := main.get_node("Sun") as DirectionalLight3D
	var ready_reports: Array[Dictionary] = []
	var load_failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready_reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void:
		load_failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()})
	)
	root.add_child(main)
	var wait_started := Time.get_ticks_msec()
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - wait_started < 60000:
		await process_frame
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Actual world did not reach one clean ready state for Chapel evidence: %s." % str(load_failures)):
		_finish(main)
		return
	if not _require(sun.rotation_degrees.is_equal_approx(EXPECTED_SUN_ROTATION_DEGREES), "Default sun rotation drifted before Chapel capture."):
		_finish(main)
		return
	var baseline_wall_nodes := _record_nodes(world, WALL_KEY)
	var baseline_roof_nodes := _record_nodes(world, ROOF_KEY)
	if not _require(baseline_wall_nodes.size() == 1 and baseline_roof_nodes.size() == 1, "Grounded world did not expose one exact Chapel wall and roof representation."):
		_finish(main)
		return
	var prototype_result := PROTOTYPE.build_for_records(wall_record, roof_record)
	if not _require(bool(prototype_result.get("ok", false)), str(prototype_result.get("message", "Standalone Chapel prototype build failed."))):
		_finish(main)
		return
	var prototype := prototype_result.node as NavyChapel187StandaloneHeroPrototype
	prototype.name = "CaptureOnly_NavyChapel187StandaloneHero"
	prototype.set_meta("capture_only_replacement", true)
	world.get_node("PlayableWorld/Buildings").add_child(prototype)
	_set_prototype_enabled(prototype, false)
	_set_baseline_enabled(baseline_wall_nodes + baseline_roof_nodes, true)
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create Chapel evidence image directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	var captures: Array[Dictionary] = []
	var pairs: Array[Dictionary] = []
	for view_value: Variant in VIEWS:
		var view := view_value as Dictionary
		_set_prototype_enabled(prototype, false)
		_set_baseline_enabled(baseline_wall_nodes + baseline_roof_nodes, true)
		await physics_frame
		var posed := await _settle_and_aim(world, player, hud, view)
		if not _require(bool(posed.get("ok", false)), str(posed.get("message", "%s pose failed." % str(view.id)))):
			_finish(main)
			return
		var camera := player.get_camera()
		var frozen_camera := camera.global_transform
		var frozen_player := player.global_transform
		var before_framing := _framing_metadata(camera, baseline_wall_nodes + baseline_roof_nodes)
		var before_los := _center_los(player, view, wall_record, WALL_KEY)
		if not _require(_framing_is_technical_valid(before_framing), "%s before framing failed: %s." % [str(view.id), JSON.stringify(before_framing)]) \
			or not _require(bool(before_los.get("ok", false)), str(before_los.get("message", "%s before LOS failed." % str(view.id)))):
			_finish(main)
			return
		var common := posed.metadata as Dictionary
		var before_extra := common.duplicate(true)
		before_extra.merge(before_framing.metadata as Dictionary, true)
		before_extra.merge(before_los.metadata as Dictionary, true)
		before_extra["pair_camera_transform"] = _transform(frozen_camera)
		var before := await _save_view(main, player, hud, sun, view, "before", before_extra)
		if not _require(bool(before.get("ok", false)), str(before.get("message", "%s before image failed." % str(view.id)))):
			_finish(main)
			return

		_set_baseline_enabled(baseline_wall_nodes + baseline_roof_nodes, false)
		_set_prototype_enabled(prototype, true)
		await physics_frame
		for _frame in 2:
			_clean_hud(hud)
			await process_frame
			await RenderingServer.frame_post_draw
		var camera_translation_error := camera.global_position.distance_to(frozen_camera.origin)
		var player_translation_error := player.global_position.distance_to(frozen_player.origin)
		var basis_error := _basis_error(camera.global_basis, frozen_camera.basis)
		if not _require(camera_translation_error <= 0.0001 and player_translation_error <= 0.0001 and basis_error <= 0.0001, "%s camera/player moved during exact before/after swap." % str(view.id)):
			_finish(main)
			return
		var after_framing := _framing_metadata(camera, [prototype])
		var after_los := _center_los(player, view, wall_record, "prototype:%s" % WALL_KEY)
		if not _require(_framing_is_technical_valid(after_framing), "%s after framing failed: %s." % [str(view.id), JSON.stringify(after_framing)]) \
			or not _require(bool(after_los.get("ok", false)), str(after_los.get("message", "%s after LOS failed." % str(view.id)))):
			_finish(main)
			return
		var after_extra := common.duplicate(true)
		after_extra.merge(after_framing.metadata as Dictionary, true)
		after_extra.merge(after_los.metadata as Dictionary, true)
		after_extra["pair_camera_transform"] = _transform(camera.global_transform)
		after_extra["pair_camera_translation_error_m"] = camera_translation_error
		after_extra["pair_camera_basis_error"] = basis_error
		after_extra["pair_player_translation_error_m"] = player_translation_error
		var after := await _save_view(main, player, hud, sun, view, "after", after_extra)
		if not _require(bool(after.get("ok", false)), str(after.get("message", "%s after image failed." % str(view.id)))):
			_finish(main)
			return
		captures.append(before.metadata as Dictionary)
		captures.append(after.metadata as Dictionary)
		pairs.append({
			"view_id": str(view.id),
			"before_capture_id": str((before.metadata as Dictionary).id),
			"after_capture_id": str((after.metadata as Dictionary).id),
			"camera_transform_exactly_reused": true,
			"camera_translation_error_m": camera_translation_error,
			"camera_basis_error": basis_error,
			"player_translation_error_m": player_translation_error,
		})
	_set_prototype_enabled(prototype, false)
	_set_baseline_enabled(baseline_wall_nodes + baseline_roof_nodes, true)
	var runtime := world.get_runtime_evidence()
	var manifest := {
		"schema_version": "ti.navy-chapel-187-standalone-hero-evidence/1",
		"review_status": "technical_capture_valid_recognition_and_believability_pending_independent_bar_raiser_review",
		"evidence_role": "Native technical before/after evidence only. The executor verifies package bytes, exact-current source identity, real world loading, physics-grounded stock-player pose, exact camera reuse within each pair, full-object framing, first-hit source binding, and nonblank PNG integrity. The executor does not grade recognition or believability.",
		"target": {
			"canonical_name": "Navy Chapel Building 187",
			"source_key": SOURCE_KEY,
			"wall_object_key": WALL_KEY,
			"roof_object_key": ROOF_KEY,
			"geometry_sha256": "c62a89b238b4831fa2c16e3244c0bffdf17a80ec09498396bc8e582c5c9e696a",
			"mapped_sse_runs": [9, 10],
			"mapped_partial_public_side_runs": [11, 12, 13],
			"protected_runs": [0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33],
		},
		"truth_boundary": {
			"standalone_capture_only": true,
			"runtime_attachment": false,
			"recognition_accepted": false,
			"believability_accepted": false,
			"as_built_claim": false,
			"interior_modeled": false,
			"vertical_dimensions_pane_count_and_side_cadence": "reversible_production_inference",
			"source_photography_stored_or_shown": false,
		},
		"confusion_set_source_ids_frozen_before_capture": CONFUSION_SET_SOURCE_IDS,
		"reference_supported_cues_frozen_before_capture": FROZEN_SUPPORTED_CUES,
		"capture_command": COMMAND,
		"generator": "game/tests/navy_chapel_187_standalone_hero_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/navy_chapel_187_standalone_hero_capture.gd"),
		"pinned_inputs": PINNED_INPUTS,
		"exact_current_context_hashes_not_prototype_dependencies": {
			"game/scenes/main.tscn": FileAccess.get_sha256("res://game/scenes/main.tscn"),
			"game/scripts/main.gd": FileAccess.get_sha256("res://game/scripts/main.gd"),
			"game/scripts/world/world_chunk_builder.gd": FileAccess.get_sha256("res://game/scripts/world/world_chunk_builder.gd"),
			"generated/world/manifest.json": FileAccess.get_sha256("res://generated/world/manifest.json"),
		},
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"lighting": {"changed": false, "sun_rotation_degrees": _vector3(sun.rotation_degrees)},
		"world_runtime_context": {
			"playable_rows": int(runtime.playable_rows),
			"context_rows": int(runtime.context_rows),
			"mesh_instances": int(runtime.mesh_instances),
			"surfaces": int(runtime.surfaces),
			"triangles": int(runtime.triangles),
			"static_bodies": int(runtime.static_bodies),
			"shapes": int(runtime.shapes),
		},
		"prototype_topology": {
			"mesh_instances": int(prototype.get_meta("mesh_instances", 0)),
			"surfaces": int(prototype.get_meta("surfaces", 0)),
			"visual_triangles": int(prototype.get_meta("visual_triangles", 0)),
			"visual_batch_triangles": prototype.get_meta("visual_batch_triangles", {}),
			"static_bodies": int(prototype.get_meta("static_bodies", 0)),
			"shapes": int(prototype.get_meta("shapes", 0)),
			"collision_triangles": int(prototype.get_meta("collision_triangles", 0)),
			"deterministic_signature": str(prototype.get_meta("deterministic_signature", "")),
		},
		"camera_contract": {
			"rig": "actual Player/CameraPivot/SpringArm3D/Camera3D",
			"player_visible": true,
			"fov_degrees": 70.0,
			"configured_spring_length_m": 5.5,
			"before_after_pair_transform_rule": "exact same live Camera3D transform and physics-settled Player transform within 0.0001",
		},
		"capture_pairs": pairs,
		"captures": captures,
		"technical_checks": [
			"native macOS Forward+/Metal at 1440x900",
			"actual generated world and stock visible player rig",
			"real character physics settlement on walkable generated collision",
			"same camera/player transforms for each before/after pair",
			"before first-hit exact current building:w291189336:wall; after first-hit capture-only prototype derived from the same exact source",
			"full target bounds in frame at ordinary player distance",
			"debug, feedback, loading, and pause panels hidden; normal reticle retained",
			"default lighting unchanged",
			"all PNGs nonblank with exact dimensions and recorded SHA-256",
		],
		"recognition_review_prohibited_for_executor": true,
		"reviewer_instruction": "Open both before/after pairs at original detail. Judge only whether the after prototype is top-1 Navy Chapel against the frozen Oasis, Dormitory 369, and Food Service/nearby institutional confusion set using at least two source-supported cues, and whether the hierarchy/depth is believable at the shown ordinary player distance. Do not infer acceptance from technical validity. Treat every vertical dimension, pane division, and three-window side cadence as reversible production inference, and do not infer an interior, rear/private-side design, or as-built fidelity.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write Chapel capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d fixed-camera before/after Chapel views on native %s/%s to %s; recognition and believability remain pending independent review" % [captures.size(), DisplayServer.get_name(), RenderingServer.get_video_adapter_name(), output_absolute])
	_finish(main)


func _set_baseline_enabled(nodes: Array[Node3D], enabled: bool) -> void:
	for node in nodes:
		node.visible = enabled
		for body_value: Variant in node.find_children("*", "CollisionObject3D", true, false):
			var body := body_value as CollisionObject3D
			if not body.has_meta("chapel_capture_original_collision_layer"):
				body.set_meta("chapel_capture_original_collision_layer", body.collision_layer)
			body.collision_layer = int(body.get_meta("chapel_capture_original_collision_layer", 0)) if enabled else 0


func _set_prototype_enabled(prototype: Node3D, enabled: bool) -> void:
	prototype.visible = enabled
	var body := prototype.get_node("StructuralCollision_NoSprayOwnership") as StaticBody3D
	body.collision_layer = 1 if enabled else 0


func _settle_and_aim(world: WorldLoader, player: PlayerController, hud: GameHUD, view: Dictionary) -> Dictionary:
	var requested_xz := view.requested_xz as Vector2
	if not world.get_boundary().contains_position(Vector3(requested_xz.x, 0.0, requested_xz.y)):
		return {"ok": false, "message": "%s fixed anchor is outside the playable boundary." % str(view.id)}
	var initial_hit := _ground_hit(player, requested_xz)
	var initial_ground := _ground_metadata(initial_hit)
	if not bool(initial_ground.get("ok", false)):
		return {"ok": false, "message": "%s fixed anchor has no generated support: %s" % [str(view.id), str(initial_ground.get("message", "unknown"))]}
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	var ground_y := float(initial_hit.position.y)
	var spawn := Vector3(requested_xz.x, ground_y + SETTLE_START_HEIGHT_M, requested_xz.y)
	player.global_transform = Transform3D(Basis.IDENTITY, spawn)
	player.velocity = Vector3.DOWN * 0.1
	player.force_update_transform()
	var recovery_before := int(world.get_runtime_evidence().recovery_count)
	player.set_gameplay_enabled(true)
	var settled := false
	var settle_frames := 0
	for frame in SETTLE_MAX_PHYSICS_FRAMES:
		paused = false
		_clean_hud(hud)
		await physics_frame
		settle_frames = frame + 1
		if player.is_on_floor() and absf(player.global_position.y - ground_y) <= SETTLE_CLEARANCE_TOLERANCE_M and absf(player.velocity.y) <= 0.05:
			settled = true
			break
	var settled_position := player.global_position
	var recovery_delta := int(world.get_runtime_evidence().recovery_count) - recovery_before
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	if not settled:
		return {"ok": false, "message": "%s did not physics-settle within %d frames." % [str(view.id), SETTLE_MAX_PHYSICS_FRAMES]}
	var final_hit := _ground_hit(player, Vector2(settled_position.x, settled_position.z))
	var final_ground := _ground_metadata(final_hit)
	if not bool(final_ground.get("ok", false)):
		return {"ok": false, "message": "%s lost walkable support after settling." % str(view.id)}
	var clearance := settled_position.y - float(final_hit.position.y)
	var drift := Vector2(settled_position.x - requested_xz.x, settled_position.z - requested_xz.y).length()
	if absf(clearance) > SETTLE_CLEARANCE_TOLERANCE_M or drift > 0.05 or recovery_delta != 0:
		return {"ok": false, "message": "%s invalid settle: clearance=%.3f drift=%.3f recovery=%d." % [str(view.id), clearance, drift, recovery_delta]}
	var aimed := _aim_stock_player_camera(player, view.aim_target as Vector3)
	if not bool(aimed.get("ok", false)):
		return {"ok": false, "message": "%s %s" % [str(view.id), str(aimed.get("message", "camera aim failed."))]}
	if not await _wait_for_render(player.get_parent() as GameMain, player, hud):
		return {"ok": false, "message": "%s did not stabilize without overlays." % str(view.id)}
	var camera := player.get_camera()
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var actual_spring := camera.global_position.distance_to(rig.global_position)
	var camera_height := camera.global_position.y - float(final_hit.position.y)
	if not is_equal_approx(camera.fov, 70.0) or not is_equal_approx(arm.spring_length, 5.5) or actual_spring < MIN_ACTUAL_SPRING_LENGTH_M or camera_height < MIN_CAMERA_HEIGHT_ABOVE_GROUND_M:
		return {"ok": false, "message": "%s stock camera contract failed." % str(view.id)}
	return {
		"ok": true,
		"metadata": {
			"scenario_reset": "fixed_xz_then_real_character_physics_settle",
			"physics_grounded": true,
			"ordinary_player_rig": true,
			"input_reachable_camera_orientation": true,
			"requested_xz": [requested_xz.x, requested_xz.y],
			"settle_spawn_y_m": spawn.y,
			"player_position_m": _vector3(settled_position),
			"ground_y_m": float(final_hit.position.y),
			"ground_clearance_m": clearance,
			"settle_horizontal_drift_m": drift,
			"settle_physics_frames": settle_frames,
			"settle_recovery_delta": recovery_delta,
			"ground_feature": str(final_ground.feature),
			"ground_object": str(final_ground.object_key),
			"ground_sources": final_ground.source_keys,
			"ground_normal_up_dot": float((final_hit.normal as Vector3).dot(Vector3.UP)),
			"in_boundary": world.get_boundary().contains_position(settled_position),
			"aim_target_m": _vector3(view.aim_target as Vector3),
			"camera_position_m": _vector3(camera.global_position),
			"camera_height_above_ground_m": camera_height,
			"camera_forward": _vector3(-camera.global_basis.z),
			"camera_fov_degrees": camera.fov,
			"configured_spring_length_m": arm.spring_length,
			"actual_spring_length_m": actual_spring,
			"camera_yaw_degrees": float(aimed.yaw_degrees),
			"camera_pitch_degrees": float(aimed.pitch_degrees),
		},
	}


func _aim_stock_player_camera(player: PlayerController, target: Vector3) -> Dictionary:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var delta := target - rig.global_position
	var horizontal := Vector2(delta.x, delta.z).length()
	if horizontal < 0.001:
		return {"ok": false, "message": "target is vertically singular for the stock camera."}
	var yaw := atan2(-delta.x, -delta.z)
	var pitch := atan2(delta.y, horizontal)
	if pitch < deg_to_rad(rig.minimum_pitch_degrees) or pitch > deg_to_rad(rig.maximum_pitch_degrees):
		return {"ok": false, "message": "target pitch is outside stock PlayerCamera limits."}
	rig.rotation = Vector3(0.0, yaw, 0.0)
	arm.rotation = Vector3(pitch, 0.0, 0.0)
	rig.force_update_transform()
	arm.force_update_transform()
	return {"ok": true, "yaw_degrees": rad_to_deg(yaw), "pitch_degrees": rad_to_deg(pitch)}


func _center_los(player: PlayerController, view: Dictionary, record: Dictionary, expected_key: String) -> Dictionary:
	var camera := player.get_camera()
	var viewport_center := camera.get_viewport().get_visible_rect().size * 0.5
	var projected_target := camera.unproject_position(view.aim_target as Vector3)
	if projected_target.distance_to(viewport_center) > 1.0:
		return {"ok": false, "message": "%s aim target is %.3f px from center." % [str(view.id), projected_target.distance_to(viewport_center)]}
	var origin := camera.project_ray_origin(viewport_center)
	var direction := camera.project_ray_normal(viewport_center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 2000.0, WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return {"ok": false, "message": "%s viewport-center LOS hit nothing." % str(view.id)}
	var collider := hit.get("collider") as CollisionObject3D
	var hit_key := "" if collider == null else str(collider.get_meta("derived_object_key", ""))
	var hit_sources: Array = [] if collider == null else collider.get_meta("source_keys", [])
	var hit_run := _nearest_run_index(record, hit.position as Vector3)
	var hit_target_error := (hit.position as Vector3).distance_to(view.aim_target as Vector3)
	if hit_key != expected_key or hit_sources != [SOURCE_KEY] or hit_run != int(view.expected_run_index) or hit_target_error > 0.25:
		return {"ok": false, "message": "%s LOS hit %s %s run %d at %s error %.3f, expected %s." % [str(view.id), hit_key, str(hit_sources), hit_run, str(hit.position), hit_target_error, expected_key]}
	return {
		"ok": true,
		"metadata": {
			"viewport_center_px": [viewport_center.x, viewport_center.y],
			"aim_target_screen_px": [projected_target.x, projected_target.y],
			"aim_target_center_error_px": projected_target.distance_to(viewport_center),
			"first_los_hit_receiver": hit_key,
			"first_los_hit_source_keys": hit_sources,
			"first_los_hit_run_index": hit_run,
			"expected_los_run_index": int(view.expected_run_index),
			"first_los_hit_position_m": _vector3(hit.position as Vector3),
			"first_los_hit_normal": _vector3(hit.normal as Vector3),
			"first_los_hit_distance_m": origin.distance_to(hit.position as Vector3),
			"first_los_hit_target_error_m": hit_target_error,
			"first_los_collision_mask": WORLD_SOLID_MASK,
			"receiver_source_run_first_los": true,
		},
	}


func _framing_metadata(camera: Camera3D, record_nodes: Array[Node3D]) -> Dictionary:
	var points: Array[Vector3] = []
	for record: Node3D in record_nodes:
		for child_value: Variant in record.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := child_value as MeshInstance3D
			if mesh_instance == null or mesh_instance.mesh == null or not mesh_instance.is_visible_in_tree():
				continue
			var bounds := mesh_instance.get_aabb()
			for x_index in 2:
				for y_index in 2:
					for z_index in 2:
						var local := bounds.position + Vector3(bounds.size.x * x_index, bounds.size.y * y_index, bounds.size.z * z_index)
						points.append(mesh_instance.global_transform * local)
	if points.is_empty():
		return {"ok": false}
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	var behind := 0
	for point: Vector3 in points:
		if camera.is_position_behind(point):
			behind += 1
			continue
		var screen := camera.unproject_position(point)
		minimum = minimum.min(screen)
		maximum = maximum.max(screen)
	if behind == points.size():
		return {"ok": false}
	var size := maximum - minimum
	return {
		"ok": true,
		"metadata": {
			"target_bounds_point_count": points.size(),
			"target_bounds_points_behind_camera": behind,
			"target_projected_min_px": [minimum.x, minimum.y],
			"target_projected_max_px": [maximum.x, maximum.y],
			"target_projected_width_ratio": size.x / CAPTURE_SIZE.x,
			"target_projected_height_ratio": size.y / CAPTURE_SIZE.y,
			"target_bounds_fully_in_frame": minimum.x >= 0.0 and minimum.y >= 0.0 and maximum.x <= CAPTURE_SIZE.x and maximum.y <= CAPTURE_SIZE.y,
		},
	}


func _framing_is_technical_valid(result: Dictionary) -> bool:
	if not bool(result.get("ok", false)):
		return false
	var data := result.metadata as Dictionary
	return int(data.target_bounds_points_behind_camera) == 0 \
		and bool(data.target_bounds_fully_in_frame) \
		and float(data.target_projected_width_ratio) >= MIN_TARGET_WIDTH_RATIO \
		and float(data.target_projected_height_ratio) >= MIN_TARGET_HEIGHT_RATIO \
		and float(data.target_projected_width_ratio) <= 0.96 \
		and float(data.target_projected_height_ratio) <= 0.96


func _save_view(main: GameMain, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, view: Dictionary, stage: String, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s %s did not stabilize." % [str(view.id), stage]}
	var hud_state := _hud_state(hud)
	if bool(hud_state.debug_panel_visible) or bool(hud_state.feedback_panel_visible) or bool(hud_state.load_panel_visible) or bool(hud_state.pause_panel_visible) or not bool(hud_state.reticle_visible):
		return {"ok": false, "message": "%s %s HUD state is not clean." % [str(view.id), stage]}
	if not sun.rotation_degrees.is_equal_approx(EXPECTED_SUN_ROTATION_DEGREES):
		return {"ok": false, "message": "%s %s default lighting changed." % [str(view.id), stage]}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s %s returned an empty or wrong-sized image." % [str(view.id), stage]}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s %s native image appears blank." % [str(view.id), stage]}
	var capture_id := "%s-%s" % [str(view.id), stage]
	var relative := "images/%s.png" % capture_id
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save." % capture_id}
	var metadata := {
		"id": capture_id,
		"stage": stage,
		"target": "navy-chapel-187",
		"source_identity": SOURCE_KEY,
		"role": str(view.role),
		"recognition_verdict": "pending_independent_bar_raiser_review",
		"believability_verdict": "pending_independent_bar_raiser_review",
		"confusion_set_source_ids_frozen_before_capture": CONFUSION_SET_SOURCE_IDS,
		"reference_supported_cues_frozen_before_capture": FROZEN_SUPPORTED_CUES,
		"file": relative,
		"sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [image.get_width(), image.get_height()],
		"sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range),
		"hud": hud_state,
		"player_visible": player.visible,
		"debug_labels_visible": false,
		"source_photography_in_frame": false,
		"lighting_changed": false,
		"sun_rotation_degrees": _vector3(sun.rotation_degrees),
		"full_entity_required_and_in_frame": true,
		"protected_untreated_faces_intentionally_not_hidden": true,
		"capture_only_prototype_swap": stage == "after",
	}
	metadata.merge(extra, true)
	print("CHAPEL_HERO_CAPTURE: id=%s grounded=%s frame=%.3fx%.3f image=%s sha256=%s" % [
		capture_id, str(metadata.physics_grounded), float(metadata.target_projected_width_ratio), float(metadata.target_projected_height_ratio), ProjectSettings.globalize_path(path), str(metadata.sha256)
	])
	return {"ok": true, "metadata": metadata}


func _record_nodes(world: WorldLoader, key: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == key and value.has_meta("feature_kind"):
			result.append(value as Node3D)
	return result


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _nearest_run_index(record: Dictionary, hit: Vector3) -> int:
	var values := record.vertices as Array
	var best_index := -1
	var best_distance := INF
	for run_index in 34:
		var offset := run_index * 12
		var start := Vector2(float(values[offset]), float(values[offset + 2]))
		var end := Vector2(float(values[offset + 3]), float(values[offset + 5]))
		var distance := _point_segment_distance(Vector2(hit.x, hit.z), start, end)
		if distance < best_distance:
			best_distance = distance
			best_index = run_index
	return best_index


func _point_segment_distance(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var length_squared := segment.length_squared()
	if length_squared <= 0.0000001:
		return point.distance_to(start)
	var t := clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_to(start + segment * t)


func _ground_hit(player: PlayerController, xz: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(Vector3(xz.x, 200.0, xz.y), Vector3(xz.x, -20.0, xz.y), WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _ground_metadata(hit: Dictionary) -> Dictionary:
	if hit.is_empty():
		return {"ok": false, "message": "ray hit nothing"}
	var collider := hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	var feature := "" if record == null else str(record.get_meta("feature_kind", ""))
	var normal: Vector3 = hit.get("normal", Vector3.ZERO)
	if record == null or feature not in ["land_ground", "road_path"] or normal.dot(Vector3.UP) < 0.7:
		return {"ok": false, "message": "hit %s with up-dot %.3f" % [feature, normal.dot(Vector3.UP)]}
	return {"ok": true, "feature": feature, "object_key": str(record.get_meta("derived_object_key", "")), "source_keys": record.get_meta("source_keys", [])}


func _clean_hud(hud: GameHUD) -> void:
	paused = false
	hud.set_paused(false)
	hud.debug_panel.hide()
	hud.feedback_panel.hide()
	hud.load_panel.hide()
	hud.pause_panel.hide()
	hud.reticle.show()


func _hud_state(hud: GameHUD) -> Dictionary:
	return {
		"debug_panel_visible": hud.debug_panel.visible,
		"feedback_panel_visible": hud.feedback_panel.visible,
		"load_panel_visible": hud.load_panel.visible,
		"pause_panel_visible": hud.pause_panel.visible,
		"reticle_visible": hud.reticle.visible,
	}


func _wait_for_render(main: GameMain, player: PlayerController, hud: GameHUD) -> bool:
	for _index in 2:
		paused = false
		player.set_gameplay_enabled(false)
		_clean_hud(hud)
		await process_frame
		await RenderingServer.frame_post_draw
	return not paused and not bool(_hud_state(hud).debug_panel_visible) and not bool(_hud_state(hud).pause_panel_visible) and main.visible


func _sample_image(image: Image) -> Dictionary:
	var colors := {}
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


func _clear_gameplay_input() -> void:
	for action: StringName in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _basis_error(a: Basis, b: Basis) -> float:
	return maxf(maxf(a.x.distance_to(b.x), a.y.distance_to(b.y)), a.z.distance_to(b.z))


func _transform(value: Transform3D) -> Dictionary:
	return {"origin": _vector3(value.origin), "basis_x": _vector3(value.basis.x), "basis_y": _vector3(value.basis.y), "basis_z": _vector3(value.basis.z)}


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true


func _vector3(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error(message)


func _on_timeout() -> void:
	if not _finished:
		_fail("Chapel standalone native evidence timed out after %.0f seconds." % TIMEOUT_SECONDS)
		_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	if main != null and is_instance_valid(main):
		main.queue_free()
	quit(1 if not _failure.is_empty() else 0)
