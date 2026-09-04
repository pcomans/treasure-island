extends SceneTree

const OUTPUT := "res://evidence/first-playable/isle-house-low-live-integration-2026-09-04"
const LIVE_ADAPTER_PATH := "res://game/scripts/world/facades/isle_house_39_bruton_low_live_attachment.gd"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const HIGH_WALL_KEY := "building-composite:w1249412094:w1282547786:wall"
const LIVE_SIGNATURE := "5d61ab90e5b798ac4aa26c45fea37a5293f3083dada615f06999faad459112cc"
const HIGH_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const STILL_SIZE := Vector2i(1440, 900)
# Native MovieWriter records the project's configured window override. A smaller
# CLI request is clamped back to this exact size by the project display contract.
const MOTION_SIZE := Vector2i(1280, 800)
const WORLD_SOLID_MASK := 1
const SETTLE_START_HEIGHT_M := 3.0
const SETTLE_MAX_FRAMES := 360
const TIMEOUT_SECONDS := 300.0
const CHANGED_LIGHT_ROTATION := Vector3(-32.0, 132.0, 0.0)
const MOTION_WALL_CORNER := Vector3(-143.885, 0.0, 527.885)
const MOTION_TANGENT := Vector3(0.454794, 0.0, 0.890596)
const MOTION_OUTWARD := Vector3(-0.890596, 0.0, 0.454794)
const MOTION_START_ALONG_M := -8.0
# Keep the continuous walk on the same unobstructed generated-ground band used
# by the WSW grounded still.
const MOTION_OUTWARD_DISTANCE_M := 22.0
const MOTION_PHYSICS_FRAMES := 300
const MOTION_FIXED_FPS := 30
const MOTION_PHYSICS_HZ := 60
const MOTION_FILE := "isle-house-low-public-corner-stock-walk.avi"

const VIEWS := [
	{
		"id": "01-wsw-whole-composite",
		"side": "WSW_Avenue_of_the_Palms",
		"role": "grounded_ordinary_player_whole_high_plus_low_composite",
		"requested_xz": Vector2(-204.98, 620.18),
		"aim_target": Vector3(-125.2329, 20.0, 559.8556),
		"expected_receiver": HIGH_WALL_KEY,
		"expected_sources": ["w1282547786"],
		"lighting": "world_default",
	},
	{
		"id": "02-wsw-low-oblique",
		"side": "WSW_Avenue_of_the_Palms",
		"role": "grounded_ordinary_player_low_live_work_oblique",
		"requested_xz": Vector2(-167.55, 529.97),
		"aim_target": Vector3(-139.77, 9.0, 536.0),
		"expected_receiver": LOW_WALL_KEY,
		"expected_sources": ["w1282547787"],
		"lighting": "world_default",
	},
	{
		"id": "03-ene-whole-composite",
		"side": "ENE_public_entry_approach",
		"role": "grounded_ordinary_player_whole_high_plus_low_composite",
		"requested_xz": Vector2(-40.1774, 610.8812),
		"aim_target": Vector3(-103.1957, 34.0, 555.3411),
		"expected_receiver": HIGH_WALL_KEY,
		"expected_sources": ["w1282547786"],
		"lighting": "world_default",
	},
	{
		"id": "04-ene-low-oblique",
		"side": "ENE_Garden_Walk",
		"role": "grounded_ordinary_player_low_live_work_oblique",
		"requested_xz": Vector2(-95.79, 504.61),
		"aim_target": Vector3(-107.42, 9.0, 503.81),
		"expected_receiver": LOW_WALL_KEY,
		"expected_sources": ["w1282547787"],
		"lighting": "world_default",
		"minimum_actual_spring_m": 2.0,
	},
	{
		"id": "05-wsw-low-changed-light",
		"side": "WSW_Avenue_of_the_Palms",
		"role": "grounded_ordinary_player_low_material_changed_light",
		"requested_xz": Vector2(-167.55, 529.97),
		"aim_target": Vector3(-139.77, 9.0, 536.0),
		"expected_receiver": LOW_WALL_KEY,
		"expected_sources": ["w1282547787"],
		"lighting": "frozen_changed_light",
	},
	{
		"id": "06-ene-low-changed-light",
		"side": "ENE_Garden_Walk",
		"role": "grounded_ordinary_player_low_material_changed_light",
		"requested_xz": Vector2(-95.79, 504.61),
		"aim_target": Vector3(-107.42, 9.0, 503.81),
		"expected_receiver": LOW_WALL_KEY,
		"expected_sources": ["w1282547787"],
		"lighting": "frozen_changed_light",
		"minimum_actual_spring_m": 2.0,
	},
]

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	var mode := _argument_value("--capture-mode=")
	if mode == "finalize-motion":
		_finalize_motion_manifest()
		_finish(null)
		return
	if mode not in ["stills", "motion"]:
		_fail("Pass exactly --capture-mode=stills, motion, or finalize-motion.")
		_finish(null)
		return
	if DisplayServer.get_name() == "headless":
		_fail("Live Isle House evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	var main_result := await _load_main(mode)
	if not _require(bool(main_result.get("ok", false)), str(main_result.get("message", "Main scene failed."))):
		_finish(main_result.get("main", null) as Node)
		return
	var main := main_result.main as GameMain
	var world := main_result.world as WorldLoader
	var player := main_result.player as PlayerController
	var hud := main_result.hud as GameHUD
	var sun := main_result.sun as DirectionalLight3D
	var observed_size := Vector2i(root.get_texture().get_size())
	var size_ok := observed_size == STILL_SIZE if mode == "stills" else (
		observed_size.x >= 960 and observed_size.y >= 600
		and absf(float(observed_size.x) / float(observed_size.y) - 1.6) <= 0.005
	)
	if not _require(size_ok, "%s render viewport %s violates its native capture-size contract." % [mode, observed_size]):
		_finish(main)
		return
	var bindings := _validate_live_bindings(world)
	if not _require(bool(bindings.get("ok", false)), str(bindings.get("message", "Live Isle House bindings failed."))):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create live Isle House evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	if mode == "stills":
		await _capture_stills(main, world, player, hud, sun, bindings.metadata as Dictionary)
	else:
		await _capture_motion(main, world, player, hud, sun, bindings.metadata as Dictionary)
	_finish(main)


func _load_main(mode: String) -> Dictionary:
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if packed == null:
		return {"ok": false, "message": "Main scene did not load."}
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var hud := main.get_node("Interface/HUD") as GameHUD
	var sun := main.get_node("Sun") as DirectionalLight3D
	var ready_reports: Array[Dictionary] = []
	var load_failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready_reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: load_failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await process_frame
	if not load_failures.is_empty() or ready_reports.size() != 1:
		return {"ok": false, "message": "%s world did not reach one clean ready state: %s" % [mode, load_failures], "main": main}
	# WorldLoader emits first; GameMain then completes the real ferry-spawn
	# physics settle asynchronously. Never reposition the stock player while that
	# startup coroutine can still overwrite the evidence pose.
	while not player.was_first_reveal_grounded() and load_failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await physics_frame
	if not load_failures.is_empty() or not player.was_first_reveal_grounded() or not player.visible:
		return {"ok": false, "message": "%s player did not complete its native startup settle." % mode, "main": main}
	if str(ready_reports[0].get("content_sha256", "")) != EXPECTED_CONTENT_SHA256 \
	or FileAccess.get_sha256("res://generated/world/manifest.json") != EXPECTED_MANIFEST_SHA256:
		return {"ok": false, "message": "Generated world identity drifted before evidence capture.", "main": main}
	var runtime := world.get_runtime_evidence()
	if runtime.playable_rows != 735 or runtime.mesh_instances != 938 or runtime.surfaces != 948 \
	or runtime.triangles != 63720 or runtime.static_bodies != 466 or runtime.shapes != 466:
		return {"ok": false, "message": "Live Isle House runtime topology drifted before evidence: %d/%d/%d/%d/%d." % [runtime.playable_rows, runtime.mesh_instances, runtime.surfaces, runtime.triangles, runtime.static_bodies], "main": main}
	return {"ok": true, "main": main, "world": world, "player": player, "hud": hud, "sun": sun}


func _validate_live_bindings(world: WorldLoader) -> Dictionary:
	var low_nodes := _record_nodes(world, LOW_WALL_KEY)
	var high_nodes := _record_nodes(world, HIGH_WALL_KEY)
	if low_nodes.size() != 1 or high_nodes.size() != 1:
		return {"ok": false, "message": "Isle House high/low receiver did not resolve exactly once."}
	var low := low_nodes[0]
	var high := high_nodes[0]
	var live := low.get_node_or_null("IsleHouse39BrutonLowLiveAttachment") as Node3D
	var high_facade := high.get_node_or_null("IsleHouse39BrutonHighFacade") as Node3D
	if live == null or str(live.get_meta("live_deterministic_signature", "")) != LIVE_SIGNATURE \
	or high_facade == null or str(high_facade.get_meta("deterministic_signature", "")) != HIGH_SIGNATURE:
		return {"ok": false, "message": "Isle House high/low facade signature did not resolve."}
	if low.get_meta("source_keys", []) != ["w1282547787"] or high.get_meta("source_keys", []) != ["w1282547786"]:
		return {"ok": false, "message": "Isle House receiver source identity drifted."}
	var body := low.get_node_or_null("Collision") as StaticBody3D
	if body == null or not body.is_in_group("spray_receiver_wall") \
	or _count_type(low, CollisionObject3D) != 1 or _count_type(live, CollisionObject3D) != 0 \
	or bool(live.get_meta("part_recognition_accepted", true)) \
	or bool(live.get_meta("whole_composite_recognition_accepted", true)) \
	or bool(live.get_meta("believability_accepted", true)):
		return {"ok": false, "message": "Live low ownership or pending-review truth boundary drifted."}
	return {
		"ok": true,
		"metadata": {
			"low_receiver_path": str(low.get_path()),
			"low_receiver_source_keys": low.get_meta("source_keys", []),
			"low_live_path": str(live.get_path()),
			"low_live_signature": LIVE_SIGNATURE,
			"high_receiver_path": str(high.get_path()),
			"high_receiver_source_keys": high.get_meta("source_keys", []),
			"high_facade_signature": HIGH_SIGNATURE,
			"underlying_wall_is_sole_collision_and_spray_receiver": true,
			"recognition_accepted": false,
			"believability_accepted": false,
		},
	}


func _capture_stills(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary) -> void:
	var original_sun := sun.rotation_degrees
	var captures: Array[Dictionary] = []
	for value: Variant in VIEWS:
		var view := value as Dictionary
		sun.rotation_degrees = CHANGED_LIGHT_ROTATION if str(view.lighting) == "frozen_changed_light" else original_sun
		var pose := await _settle_and_aim(world, player, hud, view.requested_xz as Vector2, view.aim_target as Vector3, str(view.id), float(view.get("minimum_actual_spring_m", 4.5)))
		if not _require(bool(pose.get("ok", false)), str(pose.get("message", "%s pose failed." % str(view.id)))):
			return
		var los := _center_los(player, view.aim_target as Vector3, str(view.expected_receiver), view.expected_sources as Array, str(view.id))
		if not _require(bool(los.get("ok", false)), str(los.get("message", "%s LOS failed." % str(view.id)))):
			return
		var extra := pose.metadata as Dictionary
		extra.merge(los.metadata as Dictionary, true)
		extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
		var saved := await _save_still(main, player, hud, view, extra)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "%s save failed." % str(view.id)))):
			return
		captures.append(saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var runtime := world.get_runtime_evidence()
	var manifest := {
		"schema_version": "ti.isle-house-low-live-evidence/1",
		"review_status": "pending_independent_review_not_self_accepted",
		"recognition_status": "pending_independent_review",
		"believability_status": "pending_independent_review",
		"evidence_role": "Native grounded ordinary-player whole-composite, public-side oblique, and changed-light evidence for one reversible live integration; no executor visual grade.",
		"generator": "game/tests/isle_house_low_live_evidence_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/isle_house_low_live_evidence_capture.gd"),
		"capture_command": ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/isle_house_low_live_evidence_capture.gd -- --capture-mode=stills",
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [STILL_SIZE.x, STILL_SIZE.y],
		"camera_contract": {
			"rig": "actual Player/CameraPivot/SpringArm3D/Camera3D",
			"physics_grounded": true,
			"input_reachable_orientation": true,
			"fov_degrees": 70.0,
			"configured_spring_length_m": 5.5,
			"detached_camera": false,
			"crop_or_postprocess": false,
			"debug_labels_visible": false,
		},
		"bindings": bindings,
		"live_adapter_path": LIVE_ADAPTER_PATH,
		"live_adapter_sha256": FileAccess.get_sha256(LIVE_ADAPTER_PATH),
		"builder_path": BUILDER_PATH,
		"builder_sha256": FileAccess.get_sha256(BUILDER_PATH),
		"runtime_topology": {"rows": runtime.playable_rows, "meshes": runtime.mesh_instances, "surfaces": runtime.surfaces, "triangles": runtime.triangles, "bodies": runtime.static_bodies, "shapes": runtime.shapes},
		"captures": captures,
		"capture_count": captures.size(),
		"source_photography_shipped": false,
		"generated_reference_image_used": false,
		"visual_verdict": "pending_independent_review",
		"remaining_composite_discrepancies": [
			"Frozen low massing still has five generated levels rather than the referenced seven-story podium condition.",
			"Only mapped public low bands and complete reversible live-work modules are treated; low upper band, NNW return, shared interface, and roof remain intentionally untouched.",
			"Module dimensions, cadence, glazing opacity, and exact placement remain reversible production inference rather than surveyed as-built fact.",
		],
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write live Isle House still manifest.")
		return
	print("PASS: captured %d native grounded Isle House live stills; recognition and believability remain pending independent review" % captures.size())


func _capture_motion(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary) -> void:
	if Engine.get_frames_per_second() < 0.0:
		_fail("Movie writer did not expose a valid frame clock.")
		return
	if Engine.physics_ticks_per_second != MOTION_PHYSICS_HZ:
		_fail("Physics tick rate drifted from %d Hz." % MOTION_PHYSICS_HZ)
		return
	sun.rotation_degrees = Vector3(-51.999992, -27.999996, 0.0)
	var wall_start := MOTION_WALL_CORNER + MOTION_TANGENT * MOTION_START_ALONG_M
	var requested := Vector2(
		wall_start.x + MOTION_OUTWARD.x * MOTION_OUTWARD_DISTANCE_M,
		wall_start.z + MOTION_OUTWARD.z * MOTION_OUTWARD_DISTANCE_M
	)
	var target := Vector3(wall_start.x, 8.0, wall_start.z)
	var pose := await _settle_and_aim(world, player, hud, requested, target, "public-corner-motion-start")
	if not _require(bool(pose.get("ok", false)), str(pose.get("message", "Motion start pose failed."))):
		return
	var los := _center_los(player, target, LOW_WALL_KEY, ["w1282547787"], "public-corner-motion-start")
	if not _require(bool(los.get("ok", false)), str(los.get("message", "Motion start LOS failed."))):
		return
	var runtime := world.get_runtime_evidence()
	var recoveries_before := runtime.recovery_count
	var start_position := player.global_position
	var start_camera := player.get_camera().global_transform
	var start_process_frame := Engine.get_process_frames()
	var start_physics_frame := Engine.get_physics_frames()
	var samples: Array[Dictionary] = []
	var transform_writes_after_input := 0
	player.set_gameplay_enabled(true)
	Input.action_press("move_right")
	for frame_index in MOTION_PHYSICS_FRAMES:
		paused = false
		_clean_hud(hud)
		await physics_frame
		var position := player.global_position
		var along := (position - MOTION_WALL_CORNER).dot(MOTION_TANGENT)
		var outward := (position - MOTION_WALL_CORNER).dot(MOTION_OUTWARD)
		samples.append({
			"frame": frame_index + 1,
			"player_position_m": _vector3(position),
			"velocity_mps": _vector3(player.velocity),
			"is_on_floor": player.is_on_floor(),
			"along_from_corner_m": along,
			"outward_from_wall_chain_m": outward,
			"camera_position_m": _vector3(player.get_camera().global_position),
		})
		if not player.is_on_floor():
			Input.action_release("move_right")
			player.set_gameplay_enabled(false)
			_fail("Stock walk left the generated ground at motion frame %d." % (frame_index + 1))
			return
	var input_end_process_frame := Engine.get_process_frames()
	var input_end_physics_frame := Engine.get_physics_frames()
	Input.action_release("move_right")
	for _frame in 12:
		await physics_frame
	player.set_gameplay_enabled(false)
	var end_position := player.global_position
	var end_process_frame := Engine.get_process_frames()
	var end_physics_frame := Engine.get_physics_frames()
	var displacement := Vector2(end_position.x - start_position.x, end_position.z - start_position.z).length()
	var start_along := (start_position - MOTION_WALL_CORNER).dot(MOTION_TANGENT)
	var end_along := (end_position - MOTION_WALL_CORNER).dot(MOTION_TANGENT)
	var direction := Vector3(end_position.x - start_position.x, 0.0, end_position.z - start_position.z).normalized()
	if not _require(displacement >= 18.0 and displacement <= 22.0, "Stock walk displacement %.3f m is outside the 5 s walk envelope." % displacement) \
	or not _require(start_along < -7.0 and end_along > 10.0, "Stock walk did not continuously cross the runs 2/3 public source corner: %.3f -> %.3f." % [start_along, end_along]) \
	or not _require(direction.dot(MOTION_TANGENT) > 0.995, "Stock walk direction diverged from the public side chain.") \
	or not _require(runtime.recovery_count == recoveries_before, "Stock walk triggered recovery.") \
	or not _require(transform_writes_after_input == 0, "Capture harness wrote a player transform after motion input began.") \
	or not _require(start_camera.basis.is_equal_approx(player.get_camera().global_transform.basis), "Camera orientation changed during the fixed-orientation stock walk."):
		return
	var manifest := {
		"schema_version": "ti.isle-house-low-live-motion-evidence/1",
		"review_status": "pending_independent_review_not_self_accepted",
		"recognition_status": "pending_independent_review",
		"believability_status": "pending_independent_review",
		"evidence_role": "True time-continuous stock PlayerController walk across the WSW runs 2/3 source corner for shimmer, seam, metre-UV continuity, and module stability review.",
		"generator": "game/tests/isle_house_low_live_evidence_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/isle_house_low_live_evidence_capture.gd"),
		"capture_command": ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1280x800 --write-movie evidence/first-playable/isle-house-low-live-integration-2026-09-04/%s --fixed-fps 30 --script game/tests/isle_house_low_live_evidence_capture.gd -- --capture-mode=motion" % MOTION_FILE,
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"render_viewport": [root.get_texture().get_width(), root.get_texture().get_height()],
		"movie_dimensions": [MOTION_SIZE.x, MOTION_SIZE.y],
		"movie_file": MOTION_FILE,
		"movie_sha256": "pending_after_movie_writer_close",
		"movie_bytes": -1,
		"movie_total_frames_expected_after_close": end_process_frame + 1,
		"movie_contains_startup_before_motion": true,
		"review_motion_process_frame_range": [start_process_frame, input_end_process_frame],
		"review_motion_physics_frame_range": [start_physics_frame, input_end_physics_frame],
		"capture_end_process_frame_after_braking": end_process_frame,
		"capture_end_physics_frame_after_braking": end_physics_frame,
		"fixed_fps": MOTION_FIXED_FPS,
		"physics_ticks_per_second": MOTION_PHYSICS_HZ,
		"input_action": "move_right",
		"run_action_pressed": false,
		"configured_walk_speed_mps": player.walk_speed_mps,
		"motion_physics_frames": MOTION_PHYSICS_FRAMES,
		"continuous_duration_seconds": float(MOTION_PHYSICS_FRAMES) / float(MOTION_PHYSICS_HZ),
		"start_position_m": _vector3(start_position),
		"end_position_m": _vector3(end_position),
		"horizontal_displacement_m": displacement,
		"start_along_from_corner_m": start_along,
		"end_along_from_corner_m": end_along,
		"direction_dot_public_tangent": direction.dot(MOTION_TANGENT),
		"public_chain": "LOW-WSW-AVENUE-OF-THE-PALMS",
		"crossed_source_run_corner": "run_2_to_run_3",
		"uv_rule_under_review": "continuous U across ordered intra-side corner; V is absolute world Y; 2.5 m material cell",
		"player_transform_writes_after_input_began": transform_writes_after_input,
		"camera_orientation_changed_during_motion": false,
		"all_samples_grounded": true,
		"recovery_delta": runtime.recovery_count - recoveries_before,
		"samples": samples,
		"bindings": bindings,
		"visual_verdict": "pending_independent_review",
	}
	if not _write_json(OUTPUT.path_join("motion-capture.json"), manifest):
		_fail("Could not write preliminary motion manifest.")
		return
	print("PASS: drove a %.3f m, %.1f s continuous stock-player walk across the WSW runs 2/3 source corner with 0 transform writes and 0 recoveries; movie finalization remains post-close" % [displacement, float(MOTION_PHYSICS_FRAMES) / MOTION_PHYSICS_HZ])


func _finalize_motion_manifest() -> void:
	var expected_hash := _argument_value("--movie-sha256=")
	var expected_bytes := int(_argument_value("--movie-bytes="))
	var movie_path := OUTPUT.path_join(MOTION_FILE)
	var manifest_path := OUTPUT.path_join("motion-capture.json")
	var manifest := _json(manifest_path)
	if not _require(expected_hash.length() == 64 and expected_hash == FileAccess.get_sha256(movie_path), "Movie finalizer received a missing or incorrect SHA-256.") \
	or not _require(expected_bytes > 0 and expected_bytes == FileAccess.get_file_as_bytes(movie_path).size(), "Movie finalizer received a missing or incorrect byte count.") \
	or not _require(str(manifest.get("movie_sha256", "")) == "pending_after_movie_writer_close", "Motion manifest was not in its one-time post-close state."):
		return
	manifest["movie_sha256"] = expected_hash
	manifest["movie_bytes"] = expected_bytes
	manifest["movie_finalized_after_writer_close"] = true
	manifest["finalizer_command"] = "Godot headless capture script finalize-motion with exact observed movie SHA-256 and byte count"
	if not _write_json(manifest_path, manifest):
		_fail("Could not finalize motion manifest.")
		return
	print("PASS: finalized continuous stock-player movie sha256=%s bytes=%d" % [expected_hash, expected_bytes])


func _settle_and_aim(world: WorldLoader, player: PlayerController, hud: GameHUD, requested_xz: Vector2, target: Vector3, pose_id: String, minimum_actual_spring_m: float = 4.5) -> Dictionary:
	if not world.get_boundary().contains_position(Vector3(requested_xz.x, 0.0, requested_xz.y)):
		return {"ok": false, "message": "%s anchor is outside playable boundary." % pose_id}
	var hit := _ground_hit(player, requested_xz)
	var ground := _ground_metadata(hit)
	if not bool(ground.get("ok", false)):
		return {"ok": false, "message": "%s has no walkable support: %s" % [pose_id, str(ground.get("message", "unknown"))]}
	_clear_input()
	player.set_gameplay_enabled(false)
	var ground_y := float(hit.position.y)
	player.global_transform = Transform3D(Basis.IDENTITY, Vector3(requested_xz.x, ground_y + SETTLE_START_HEIGHT_M, requested_xz.y))
	player.velocity = Vector3.DOWN * 0.1
	player.force_update_transform()
	var recoveries_before := world.get_runtime_evidence().recovery_count
	player.set_gameplay_enabled(true)
	var settled := false
	var frames := 0
	for frame in SETTLE_MAX_FRAMES:
		paused = false
		_clean_hud(hud)
		await physics_frame
		frames = frame + 1
		if player.is_on_floor() and absf(player.global_position.y - ground_y) <= 0.08 and absf(player.velocity.y) <= 0.05:
			settled = true
			break
	_clear_input()
	player.set_gameplay_enabled(false)
	if not settled:
		return {"ok": false, "message": "%s did not physics-settle: pos=%s ground_y=%.4f velocity=%s on_floor=%s." % [pose_id, player.global_position, ground_y, player.velocity, player.is_on_floor()]}
	var final_hit := _ground_hit(player, Vector2(player.global_position.x, player.global_position.z))
	var final_ground := _ground_metadata(final_hit)
	var clearance := player.global_position.y - float(final_hit.get("position", Vector3.ZERO).y)
	if not bool(final_ground.get("ok", false)) or absf(clearance) > 0.08 \
	or world.get_runtime_evidence().recovery_count != recoveries_before:
		return {"ok": false, "message": "%s settle support, clearance, or recovery contract failed." % pose_id}
	var aimed := _aim_stock_camera(player, target)
	if not bool(aimed.get("ok", false)):
		return {"ok": false, "message": "%s %s" % [pose_id, str(aimed.get("message", "camera aim failed"))]}
	if not await _wait_for_render(main_from_player(player), player, hud):
		return {"ok": false, "message": "%s render did not stabilize." % pose_id}
	var camera := player.get_camera()
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var actual_spring := camera.global_position.distance_to(rig.global_position)
	if not is_equal_approx(camera.fov, 70.0) or not is_equal_approx(arm.spring_length, 5.5) or actual_spring < minimum_actual_spring_m:
		return {"ok": false, "message": "%s stock camera was obstructed or reconfigured: fov %.2f spring %.3f/%.3f." % [pose_id, camera.fov, arm.spring_length, actual_spring]}
	return {
		"ok": true,
		"metadata": {
			"pose_id": pose_id,
			"physics_grounded": true,
			"ordinary_player_rig": true,
			"input_reachable_camera_orientation": true,
			"requested_xz": [requested_xz.x, requested_xz.y],
			"player_position_m": _vector3(player.global_position),
			"camera_position_m": _vector3(camera.global_position),
			"camera_forward": _vector3(-camera.global_basis.z),
			"aim_target_m": _vector3(target),
			"ground_y_m": float(final_hit.position.y),
			"ground_clearance_m": clearance,
			"ground_feature": str(final_ground.feature),
			"ground_object": str(final_ground.object_key),
			"ground_sources": final_ground.source_keys,
			"settle_physics_frames": frames,
			"settle_recovery_delta": 0,
			"camera_fov_degrees": camera.fov,
			"configured_spring_length_m": arm.spring_length,
			"actual_spring_length_m": actual_spring,
			"minimum_allowed_actual_spring_length_m": minimum_actual_spring_m,
			"spring_arm_compressed_by_world": actual_spring < arm.spring_length - 0.1,
			"camera_yaw_degrees": float(aimed.yaw_degrees),
			"camera_pitch_degrees": float(aimed.pitch_degrees),
		},
	}


func _aim_stock_camera(player: PlayerController, target: Vector3) -> Dictionary:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var delta := target - rig.global_position
	var horizontal := Vector2(delta.x, delta.z).length()
	if horizontal < 0.001:
		return {"ok": false, "message": "target is vertically singular."}
	var yaw := atan2(-delta.x, -delta.z)
	var pitch := atan2(delta.y, horizontal)
	if pitch < deg_to_rad(rig.minimum_pitch_degrees) or pitch > deg_to_rad(rig.maximum_pitch_degrees):
		return {"ok": false, "message": "target pitch %.2f is outside stock limits." % rad_to_deg(pitch)}
	rig.rotation = Vector3(0.0, yaw, 0.0)
	arm.rotation = Vector3(pitch, 0.0, 0.0)
	rig.force_update_transform()
	arm.force_update_transform()
	return {"ok": true, "yaw_degrees": rad_to_deg(yaw), "pitch_degrees": rad_to_deg(pitch)}


func _center_los(player: PlayerController, target: Vector3, expected_receiver: String, expected_sources: Array, pose_id: String) -> Dictionary:
	var camera := player.get_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var projected := camera.unproject_position(target)
	if projected.distance_to(center) > 1.0:
		return {"ok": false, "message": "%s aim target is %.3f px off center." % [pose_id, projected.distance_to(center)]}
	var origin := camera.project_ray_origin(center)
	var direction := camera.project_ray_normal(center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 2000.0, WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	var collider := hit.get("collider") as CollisionObject3D if not hit.is_empty() else null
	var key := "" if collider == null else str(collider.get_meta("derived_object_key", ""))
	var sources: Array = [] if collider == null else collider.get_meta("source_keys", [])
	if key != expected_receiver or sources != expected_sources:
		return {"ok": false, "message": "%s LOS hit %s %s instead of %s %s." % [pose_id, key, sources, expected_receiver, expected_sources]}
	return {"ok": true, "metadata": {"first_los_hit_receiver": key, "first_los_hit_source_keys": sources, "first_los_hit_position_m": _vector3(hit.position as Vector3), "first_los_hit_distance_m": origin.distance_to(hit.position as Vector3), "receiver_first_los": true}}


func _save_still(main: GameMain, player: PlayerController, hud: GameHUD, view: Dictionary, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s did not stabilize." % str(view.id)}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != STILL_SIZE:
		return {"ok": false, "message": "%s returned an empty or wrong-sized image." % str(view.id)}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s native image appears blank." % str(view.id)}
	var relative := "images/%s.png" % str(view.id)
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(view.id)}
	var metadata := {
		"id": str(view.id), "side": str(view.side), "role": str(view.role), "lighting": str(view.lighting),
		"file": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [image.get_width(), image.get_height()], "sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range), "debug_labels_visible": false,
		"source_photography_in_frame": false, "crop_or_postprocess": false, "visual_verdict": "pending_independent_review",
	}
	metadata.merge(extra, true)
	print("ISLE_LOW_LIVE_CAPTURE: id=%s receiver=%s image=%s sha256=%s" % [str(view.id), str(metadata.first_los_hit_receiver), ProjectSettings.globalize_path(path), str(metadata.sha256)])
	return {"ok": true, "metadata": metadata}


func _record_nodes(world: WorldLoader, key: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for node: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(node.get_meta("derived_object_key", "")) == key and node.has_meta("feature_kind"):
			result.append(node as Node3D)
	return result


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


func _wait_for_render(main: GameMain, player: PlayerController, hud: GameHUD) -> bool:
	for _index in 2:
		paused = false
		player.set_gameplay_enabled(false)
		_clean_hud(hud)
		await process_frame
		await RenderingServer.frame_post_draw
	return not paused and not hud.debug_panel.visible and not hud.pause_panel.visible


func _clean_hud(hud: GameHUD) -> void:
	paused = false
	hud.set_paused(false)
	hud.debug_panel.hide()
	hud.feedback_panel.hide()
	hud.load_panel.hide()
	hud.pause_panel.hide()
	hud.reticle.show()


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


func _clear_input() -> void:
	for action: StringName in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func main_from_player(player: PlayerController) -> GameMain:
	return player.get_parent() as GameMain


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
	push_error("ISLE_LOW_LIVE_CAPTURE_FAIL: %s" % message)


func _on_timeout() -> void:
	if not _finished:
		_fail("Live Isle House evidence timed out after %.0f seconds." % TIMEOUT_SECONDS)
		_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	_clear_input()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	paused = false
	if main != null and is_instance_valid(main):
		main.queue_free()
	quit(1 if not _failure.is_empty() else 0)
