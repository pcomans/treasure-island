extends SceneTree

const PROTOTYPE := preload("res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd")
const OUTPUT := "res://evidence/first-playable/d2-1441-chinook-standalone-hero-2026-09-04"
const PROTOTYPE_SCENE_PATH := "res://game/scenes/world/facades/site_12_housing/d2_1441_chinook_standalone_hero_prototype.tscn"
const CONFIG_PATH := "res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_-1.json"
const PACKET_PATH := "res://discovery/facades/d2_reference_packets/w95934105_1441_chinook_court.md"
const WALL_KEY := "building:w95934105:wall"
const ROOF_KEY := "building:w95934105:roof"
const SOURCE_KEY := "w95934105"
const MAPPED_RUNS := [10, 12, 13, 15]
const PROTECTED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14]
const EXPECTED_CHUNK_SHA256 := "5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b"
const EXPECTED_PACKET_SHA256 := "8135272f4cc012e83fa19f80871651d25db29c4cbd5a50dc07e4faee7563b0bc"
const STILL_SIZE := Vector2i(1440, 900)
const MOTION_SIZE := Vector2i(1280, 800)
const WORLD_SOLID_MASK := 1
const SETTLE_START_HEIGHT_M := 3.0
const SETTLE_MAX_PHYSICS_FRAMES := 360
const SETTLE_CLEARANCE_TOLERANCE_M := 0.08
const MIN_ACTUAL_SPRING_LENGTH_M := 4.2
const TIMEOUT_SECONDS := 300.0
const DEFAULT_SUN := Vector3(-52.0, -28.0, 0.0)
const CHANGED_SUN := Vector3(-26.0, 126.0, 0.0)
const MOTION_PHYSICS_FRAMES := 240
const MOTION_PHYSICS_HZ := 60
const MOTION_FIXED_FPS := 30
const MOTION_FILE := "d2-1441-chinook-sse-stock-walk.avi"
const TARGET_POINT := Vector3(-258.455, 6.36, -15.544)
const PUBLIC_TANGENT := Vector3(-0.883, 0.0, 0.468)
const PUBLIC_OUTWARD := Vector3(-0.468, 0.0, -0.884)
const CONFUSION_SET := ["w95934144", "w95934143", "w95934131", "w95934129"]
const FROZEN_SUPPORTED_CUES := [
	"two long projecting windowed wing faces separated by the real footprint setback to runs 12 and 13",
	"two-level dark recessed balcony or breezeway voids with simple metal rail silhouettes",
	"shallow dark side-gable profile and broad projecting SSE eave over a quiet warm-white field",
]
const VIEWS := [
	{
		"id": "01-whole-sse",
		"role": "whole_object_grounded_public_sse_view",
		"requested_xz": Vector2(-230.0, -65.0),
		"aim_target": Vector3(-249.514, 6.36, -26.700),
		"expected_run_index": 10,
		"sun": DEFAULT_SUN,
	},
	{
		"id": "02-sse-oblique",
		"role": "grounded_public_sse_oblique_approach",
		"requested_xz": Vector2(-245.0, -47.0),
		"aim_target": TARGET_POINT,
		"expected_run_index": 13,
		"sun": DEFAULT_SUN,
	},
	{
		"id": "03-sse-oblique-changed-light",
		"role": "same_grounded_public_sse_oblique_under_materially_changed_light",
		"requested_xz": Vector2(-245.0, -47.0),
		"aim_target": TARGET_POINT,
		"expected_run_index": 13,
		"sun": CHANGED_SUN,
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
		_fail("1441 Chinook evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	if not _require(FileAccess.get_sha256(CHUNK_PATH) == EXPECTED_CHUNK_SHA256, "Frozen source chunk drifted before capture.") \
	or not _require(FileAccess.get_sha256(PACKET_PATH) == EXPECTED_PACKET_SHA256, "Authoritative 1441 packet drifted before capture."):
		_finish(null)
		return
	var chunk := _json(CHUNK_PATH)
	var wall_record := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof_record := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	if not _require(PROTOTYPE.matches_record_pair(wall_record, roof_record), "Exact 1441 wall+roof pair failed the standalone seam."):
		_finish(null)
		return
	var main_result := await _load_main()
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
	var binding := _attach_standalone(world, wall_record, roof_record)
	if not _require(bool(binding.get("ok", false)), str(binding.get("message", "Standalone attachment failed."))):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create 1441 evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	if mode == "stills":
		await _capture_stills(main, world, player, hud, sun, binding, wall_record)
	else:
		await _capture_motion(main, world, player, hud, sun, binding, wall_record)
	_finish(main)


func _load_main() -> Dictionary:
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
		return {"ok": false, "message": "World did not reach one clean ready state: %s" % load_failures, "main": main}
	while not player.was_first_reveal_grounded() and load_failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await physics_frame
	if not load_failures.is_empty() or not player.was_first_reveal_grounded() or not player.visible:
		return {"ok": false, "message": "Stock player did not complete native startup settlement.", "main": main}
	return {"ok": true, "main": main, "world": world, "player": player, "hud": hud, "sun": sun, "runtime_before_preview": world.get_runtime_evidence()}


func _attach_standalone(world: WorldLoader, wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	var wall_nodes := _record_nodes(world, WALL_KEY)
	var roof_nodes := _record_nodes(world, ROOF_KEY)
	if wall_nodes.size() != 1 or roof_nodes.size() != 1:
		return {"ok": false, "message": "Live world did not expose exactly one 1441 wall and roof."}
	var result := PROTOTYPE.build_for_records(wall_record, roof_record)
	if not bool(result.get("ok", false)):
		return result
	var prototype := result.node as D21441ChinookStandaloneHeroPrototype
	prototype.name = "CaptureOnly_D2_1441_Chinook_StandaloneHero"
	prototype.set_meta("capture_only_replacement", true)
	world.get_node("PlayableWorld/Buildings").add_child(prototype)
	_set_prototype_enabled(prototype, false)
	_set_baseline_enabled(wall_nodes + roof_nodes, true)
	return {"ok": true, "prototype": prototype, "baseline": wall_nodes + roof_nodes, "runtime_before_preview": world.get_runtime_evidence()}


func _capture_stills(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, binding: Dictionary, wall_record: Dictionary) -> void:
	var prototype := binding.prototype as D21441ChinookStandaloneHeroPrototype
	var baseline := binding.baseline as Array[Node3D]
	var captures: Array[Dictionary] = []
	var pairs: Array[Dictionary] = []
	var original_sun := sun.rotation_degrees
	for view_value: Variant in VIEWS:
		var view := view_value as Dictionary
		sun.rotation_degrees = view.sun as Vector3
		_set_prototype_enabled(prototype, false)
		_set_baseline_enabled(baseline, true)
		await physics_frame
		var posed := await _settle_and_aim(world, player, hud, view.requested_xz as Vector2, view.aim_target as Vector3, str(view.id))
		if not _require(bool(posed.get("ok", false)), str(posed.get("message", "%s pose failed." % str(view.id)))):
			return
		var camera := player.get_camera()
		var frozen_camera := camera.global_transform
		var frozen_player := player.global_transform
		var before_projection := _framing_metadata(camera, baseline)
		var before_los := _center_los(player, view.aim_target as Vector3, wall_record, WALL_KEY, int(view.expected_run_index), str(view.id))
		if not _require(_framing_is_valid(before_projection), "%s baseline framing failed: %s" % [view.id, before_projection]) \
		or not _require(bool(before_los.get("ok", false)), str(before_los.get("message", "%s baseline LOS failed." % str(view.id)))):
			return
		var before_extra := (posed.metadata as Dictionary).duplicate(true)
		before_extra.merge(before_projection.metadata as Dictionary, true)
		before_extra.merge(before_los.metadata as Dictionary, true)
		var before := await _save_still(main, player, hud, sun, view, "before", before_extra)
		if not _require(bool(before.get("ok", false)), str(before.get("message", "Baseline save failed."))):
			return

		_set_baseline_enabled(baseline, false)
		_set_prototype_enabled(prototype, true)
		await physics_frame
		for _frame in 2:
			await process_frame
			await RenderingServer.frame_post_draw
		var camera_error := camera.global_position.distance_to(frozen_camera.origin)
		var basis_error := _basis_error(camera.global_basis, frozen_camera.basis)
		var player_error := player.global_position.distance_to(frozen_player.origin)
		var after_projection := _framing_metadata(camera, [prototype])
		var after_los := _center_los(player, view.aim_target as Vector3, wall_record, "prototype:%s" % WALL_KEY, int(view.expected_run_index), str(view.id))
		if not _require(camera_error <= 0.0001 and basis_error <= 0.0001 and player_error <= 0.0001, "%s camera/player moved during swap." % view.id) \
		or not _require(_framing_is_valid(after_projection), "%s prototype framing failed: %s" % [view.id, after_projection]) \
		or not _require(bool(after_los.get("ok", false)), str(after_los.get("message", "%s prototype LOS failed." % str(view.id)))):
			return
		var after_extra := (posed.metadata as Dictionary).duplicate(true)
		after_extra.merge(after_projection.metadata as Dictionary, true)
		after_extra.merge(after_los.metadata as Dictionary, true)
		after_extra["pair_camera_translation_error_m"] = camera_error
		after_extra["pair_camera_basis_error"] = basis_error
		after_extra["pair_player_translation_error_m"] = player_error
		var after := await _save_still(main, player, hud, sun, view, "after", after_extra)
		if not _require(bool(after.get("ok", false)), str(after.get("message", "Prototype save failed."))):
			return
		captures.append(before.metadata as Dictionary)
		captures.append(after.metadata as Dictionary)
		pairs.append({
			"view_id": str(view.id),
			"before_capture_id": str((before.metadata as Dictionary).id),
			"after_capture_id": str((after.metadata as Dictionary).id),
			"camera_transform_exactly_reused": true,
			"camera_translation_error_m": camera_error,
			"camera_basis_error": basis_error,
			"player_translation_error_m": player_error,
			"sun_rotation_degrees": _vector3(view.sun as Vector3),
		})
	_set_prototype_enabled(prototype, false)
	_set_baseline_enabled(baseline, true)
	sun.rotation_degrees = original_sun
	var runtime: Variant = binding.runtime_before_preview
	var manifest := {
		"schema_version": "ti.d2-1441-chinook-standalone-hero-evidence/1",
		"review_status": "technical_capture_valid_recognition_and_believability_pending_independent_bar_raiser_review",
		"evidence_role": "Native technical same-pose baseline/prototype evidence only; executor verified source binding, grounded stock player, framing, transform reuse, changed light, and PNG integrity without grading visual quality.",
		"target": {
			"canonical_name": "1441 Chinook Court",
			"source_key": SOURCE_KEY,
			"wall_object_key": WALL_KEY,
			"roof_object_key": ROOF_KEY,
			"source_geometry_sha256": PROTOTYPE.SOURCE_GEOMETRY_SHA256,
			"wall_record_sha256": PROTOTYPE.EXPECTED_WALL_RECORD_SHA256,
			"roof_record_sha256": PROTOTYPE.EXPECTED_ROOF_RECORD_SHA256,
			"mapped_public_sse_runs": MAPPED_RUNS,
			"protected_runs": PROTECTED_RUNS,
			"source_base_wall_top_y_m": [3.332, 9.332],
		},
		"truth_boundary": {
			"standalone_capture_only": true,
			"runtime_attachment": false,
			"recognition_accepted": false,
			"believability_accepted": false,
			"as_built_claim": false,
			"interior_modeled": false,
			"all_module_dimensions_and_counts_and_roof_rise": "reversible_production_inference",
			"source_photography_stored_or_shown": false,
			"protected_runs_have_modules": false,
			"fallback_collider_retained": false,
		},
		"confusion_set_source_ids_frozen_before_capture": CONFUSION_SET,
		"reference_supported_cues_frozen_before_capture": FROZEN_SUPPORTED_CUES,
		"capture_command": ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/d2_1441_chinook_standalone_hero_capture.gd -- --capture-mode=stills",
		"generator": "game/tests/d2_1441_chinook_standalone_hero_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/d2_1441_chinook_standalone_hero_capture.gd"),
		"pinned_inputs": _package_hashes(),
		"context_hashes_not_prototype_dependencies": {
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
		"viewport": [STILL_SIZE.x, STILL_SIZE.y],
		"lighting": {"default_sun_rotation_degrees": _vector3(DEFAULT_SUN), "changed_sun_rotation_degrees": _vector3(CHANGED_SUN), "changed_light_pair_id": "03-sse-oblique-changed-light"},
		"world_runtime_context": {"playable_rows": int(runtime.playable_rows), "context_rows": int(runtime.context_rows), "mesh_instances": int(runtime.mesh_instances), "surfaces": int(runtime.surfaces), "triangles": int(runtime.triangles), "static_bodies": int(runtime.static_bodies), "shapes": int(runtime.shapes)},
		"prototype_topology": _prototype_topology(prototype),
		"camera_contract": {"rig": "actual Player/CameraPivot/SpringArm3D/Camera3D", "player_visible": true, "physics_grounded": true, "fov_degrees": 70.0, "configured_spring_length_m": 5.5, "before_after_pair_transform_rule": "exact same live Camera3D and Player transforms within 0.0001"},
		"capture_pairs": pairs,
		"captures": captures,
		"technical_self_check_only": true,
		"visual_verdict": "pending_independent_bar_raiser_review",
		"reviewer_instruction": "Open all six PNGs at original detail before reading labels. Against 1439, 1443, 1438 and 1440 Chinook, decide whether the after views are top-1 1441 using at least two supported cues, including the real projecting-wing / central setback / two-level void cadence. Check the shallow dark gable and broad eave in default and changed light without relying on white color, address, location, or source ID. Treat all opening, void, rail, eave and roof-rise counts/dimensions as reversible inference.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write 1441 capture manifest.")
		return
	print("PASS: captured %d native grounded 1441 same-pose baseline/prototype stills; recognition and believability remain pending independent review" % captures.size())


func _capture_motion(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, binding: Dictionary, wall_record: Dictionary) -> void:
	if Engine.physics_ticks_per_second != MOTION_PHYSICS_HZ:
		_fail("Physics tick rate drifted from %d Hz." % MOTION_PHYSICS_HZ)
		return
	var prototype := binding.prototype as D21441ChinookStandaloneHeroPrototype
	var baseline := binding.baseline as Array[Node3D]
	_set_baseline_enabled(baseline, false)
	_set_prototype_enabled(prototype, true)
	sun.rotation_degrees = DEFAULT_SUN
	var start_wall := TARGET_POINT - PUBLIC_TANGENT * 8.0
	var requested := Vector2(start_wall.x + PUBLIC_OUTWARD.x * 22.0, start_wall.z + PUBLIC_OUTWARD.z * 22.0)
	var posed := await _settle_and_aim(world, player, hud, requested, TARGET_POINT, "sse-stock-walk-start")
	if not _require(bool(posed.get("ok", false)), str(posed.get("message", "Motion pose failed."))):
		return
	var los := _center_los(player, TARGET_POINT, wall_record, "prototype:%s" % WALL_KEY, 13, "sse-stock-walk-start")
	if not _require(bool(los.get("ok", false)), str(los.get("message", "Motion LOS failed."))):
		return
	var recovery_before := int(world.get_runtime_evidence().recovery_count)
	var start_position := player.global_position
	var start_basis := player.get_camera().global_basis
	var start_process_frame := Engine.get_process_frames()
	var start_physics_frame := Engine.get_physics_frames()
	var samples: Array[Dictionary] = []
	player.set_gameplay_enabled(true)
	Input.action_press("move_right")
	for frame_index in MOTION_PHYSICS_FRAMES:
		paused = false
		_clean_hud(hud)
		await physics_frame
		if not player.is_on_floor():
			Input.action_release("move_right")
			player.set_gameplay_enabled(false)
			_fail("Stock player left generated ground at motion frame %d." % (frame_index + 1))
			return
		var position := player.global_position
		samples.append({"frame": frame_index + 1, "player_position_m": _vector3(position), "velocity_mps": _vector3(player.velocity), "is_on_floor": true, "along_public_tangent_m": (position - TARGET_POINT).dot(PUBLIC_TANGENT), "outward_from_target_m": (position - TARGET_POINT).dot(PUBLIC_OUTWARD), "camera_position_m": _vector3(player.get_camera().global_position)})
	var input_end_process_frame := Engine.get_process_frames()
	var input_end_physics_frame := Engine.get_physics_frames()
	Input.action_release("move_right")
	for _frame in 12:
		await physics_frame
	player.set_gameplay_enabled(false)
	var end_position := player.global_position
	var displacement := Vector2(end_position.x - start_position.x, end_position.z - start_position.z).length()
	var direction := Vector3(end_position.x - start_position.x, 0.0, end_position.z - start_position.z).normalized()
	if not _require(displacement >= 10.0, "Stock walk displaced only %.3f m." % displacement) \
	or not _require(int(world.get_runtime_evidence().recovery_count) == recovery_before, "Stock walk triggered recovery.") \
	or not _require(start_basis.is_equal_approx(player.get_camera().global_basis), "Camera orientation changed during stock walk."):
		return
	var manifest := {
		"schema_version": "ti.d2-1441-chinook-standalone-motion-evidence/1",
		"review_status": "technical_motion_valid_visual_review_pending",
		"evidence_role": "Continuous stock-player public-side walk for facade cadence, meter-repeat, seam, shimmer, and stability review; standalone prototype only.",
		"capture_command": ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1280x800 --write-movie evidence/first-playable/d2-1441-chinook-standalone-hero-2026-09-04/%s --fixed-fps 30 --script game/tests/d2_1441_chinook_standalone_hero_capture.gd -- --capture-mode=motion" % MOTION_FILE,
		"generator": "game/tests/d2_1441_chinook_standalone_hero_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/d2_1441_chinook_standalone_hero_capture.gd"),
		"package_hashes": _package_hashes(),
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"render_viewport": [root.get_texture().get_width(), root.get_texture().get_height()],
		"movie_dimensions": [MOTION_SIZE.x, MOTION_SIZE.y],
		"movie_file": MOTION_FILE,
		"movie_sha256": "pending_after_movie_writer_close",
		"movie_bytes": -1,
		"movie_total_frames_expected_after_close": Engine.get_process_frames() + 1,
		"movie_contains_startup_before_motion": true,
		"review_motion_process_frame_range": [start_process_frame, input_end_process_frame],
		"review_motion_physics_frame_range": [start_physics_frame, input_end_physics_frame],
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
		"direction_dot_public_tangent_abs": absf(direction.dot(PUBLIC_TANGENT)),
		"player_transform_writes_after_input_began": 0,
		"camera_orientation_changed_during_motion": false,
		"all_samples_grounded": true,
		"recovery_delta": int(world.get_runtime_evidence().recovery_count) - recovery_before,
		"mapped_public_runs_under_review": MAPPED_RUNS,
		"meter_uv_rule_under_review": "one geometry UV unit per modeled meter; 3 m stucco and 5 m roof material repeat assumptions",
		"architecture_under_review": "entity-specific projecting runs 10/15 and recessed two-level void runs 12/13",
		"samples": samples,
		"visual_verdict": "pending_independent_bar_raiser_review",
	}
	if not _write_json(OUTPUT.path_join("motion-capture.json"), manifest):
		_fail("Could not write 1441 motion manifest.")
		return
	print("PASS: drove a %.3f m, %.1f s grounded stock-player walk beside standalone 1441 with zero transform writes and recoveries; movie finalization remains post-close" % [displacement, float(MOTION_PHYSICS_FRAMES) / MOTION_PHYSICS_HZ])


func _finalize_motion_manifest() -> void:
	var expected_hash := _argument_value("--movie-sha256=")
	var expected_bytes := int(_argument_value("--movie-bytes="))
	var movie_path := OUTPUT.path_join(MOTION_FILE)
	var manifest_path := OUTPUT.path_join("motion-capture.json")
	var manifest := _json(manifest_path)
	if not _require(expected_hash.length() == 64 and expected_hash == FileAccess.get_sha256(movie_path), "Movie finalizer received a missing or incorrect SHA-256.") \
	or not _require(expected_bytes > 0 and expected_bytes == FileAccess.get_file_as_bytes(movie_path).size(), "Movie finalizer received a missing or incorrect byte count.") \
	or not _require(str(manifest.get("movie_sha256", "")) == "pending_after_movie_writer_close", "Motion manifest was not in post-close state."):
		return
	manifest["movie_sha256"] = expected_hash
	manifest["movie_bytes"] = expected_bytes
	manifest["movie_finalized_after_writer_close"] = true
	manifest["finalizer_command"] = "headless finalizer received exact observed movie SHA-256 and byte count"
	if not _write_json(manifest_path, manifest):
		_fail("Could not finalize 1441 motion manifest.")
		return
	print("PASS: finalized 1441 motion movie sha256=%s bytes=%d" % [expected_hash, expected_bytes])


func _set_baseline_enabled(nodes: Array[Node3D], enabled: bool) -> void:
	for node in nodes:
		node.visible = enabled
		for body_value: Variant in node.find_children("*", "CollisionObject3D", true, false):
			var body := body_value as CollisionObject3D
			if not body.has_meta("d2_1441_capture_original_collision_layer"):
				body.set_meta("d2_1441_capture_original_collision_layer", body.collision_layer)
			body.collision_layer = int(body.get_meta("d2_1441_capture_original_collision_layer", 0)) if enabled else 0


func _set_prototype_enabled(prototype: Node3D, enabled: bool) -> void:
	prototype.visible = enabled
	var body := prototype.get_node("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	body.collision_layer = 1 if enabled else 0


func _settle_and_aim(world: WorldLoader, player: PlayerController, hud: GameHUD, requested_xz: Vector2, target: Vector3, pose_id: String) -> Dictionary:
	if not world.get_boundary().contains_position(Vector3(requested_xz.x, 0.0, requested_xz.y)):
		return {"ok": false, "message": "%s anchor is outside the playable boundary." % pose_id}
	var initial_hit := _ground_hit(player, requested_xz)
	var initial_ground := _ground_metadata(initial_hit)
	if not bool(initial_ground.get("ok", false)):
		return {"ok": false, "message": "%s anchor has no walkable support: %s" % [pose_id, initial_ground]}
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
		return {"ok": false, "message": "%s did not physics-settle." % pose_id}
	var final_hit := _ground_hit(player, Vector2(settled_position.x, settled_position.z))
	var final_ground := _ground_metadata(final_hit)
	if not bool(final_ground.get("ok", false)):
		return {"ok": false, "message": "%s lost walkable support after settling." % pose_id}
	var clearance := settled_position.y - float(final_hit.position.y)
	var drift := Vector2(settled_position.x - requested_xz.x, settled_position.z - requested_xz.y).length()
	if absf(clearance) > SETTLE_CLEARANCE_TOLERANCE_M or drift > 0.05 or recovery_delta != 0:
		return {"ok": false, "message": "%s invalid settle clearance=%.3f drift=%.3f recovery=%d." % [pose_id, clearance, drift, recovery_delta]}
	var aimed := _aim_stock_player_camera(player, target)
	if not bool(aimed.get("ok", false)):
		return {"ok": false, "message": "%s %s" % [pose_id, aimed.get("message", "aim failed")]}
	if not await _wait_for_render(player.get_parent() as GameMain, player, hud):
		return {"ok": false, "message": "%s did not stabilize." % pose_id}
	var camera := player.get_camera()
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var actual_spring := camera.global_position.distance_to(rig.global_position)
	if not is_equal_approx(camera.fov, 70.0) or not is_equal_approx(arm.spring_length, 5.5) or actual_spring < MIN_ACTUAL_SPRING_LENGTH_M:
		return {"ok": false, "message": "%s stock camera contract failed." % pose_id}
	return {"ok": true, "metadata": {"scenario_reset": "fixed_xz_then_real_character_physics_settle", "physics_grounded": true, "ordinary_player_rig": true, "input_reachable_camera_orientation": true, "requested_xz": [requested_xz.x, requested_xz.y], "settle_spawn_y_m": spawn.y, "player_position_m": _vector3(settled_position), "ground_y_m": float(final_hit.position.y), "ground_clearance_m": clearance, "settle_horizontal_drift_m": drift, "settle_physics_frames": settle_frames, "settle_recovery_delta": recovery_delta, "ground_feature": str(final_ground.feature), "ground_object": str(final_ground.object_key), "ground_sources": final_ground.source_keys, "aim_target_m": _vector3(target), "camera_position_m": _vector3(camera.global_position), "camera_forward": _vector3(-camera.global_basis.z), "camera_fov_degrees": camera.fov, "configured_spring_length_m": arm.spring_length, "actual_spring_length_m": actual_spring, "camera_yaw_degrees": float(aimed.yaw_degrees), "camera_pitch_degrees": float(aimed.pitch_degrees)}}


func _aim_stock_player_camera(player: PlayerController, target: Vector3) -> Dictionary:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var delta := target - rig.global_position
	var horizontal := Vector2(delta.x, delta.z).length()
	if horizontal < 0.001:
		return {"ok": false, "message": "target is vertically singular."}
	var yaw := atan2(-delta.x, -delta.z)
	var pitch := atan2(delta.y, horizontal)
	if pitch < deg_to_rad(rig.minimum_pitch_degrees) or pitch > deg_to_rad(rig.maximum_pitch_degrees):
		return {"ok": false, "message": "target pitch is outside stock camera limits."}
	rig.rotation = Vector3(0.0, yaw, 0.0)
	arm.rotation = Vector3(pitch, 0.0, 0.0)
	rig.force_update_transform()
	arm.force_update_transform()
	return {"ok": true, "yaw_degrees": rad_to_deg(yaw), "pitch_degrees": rad_to_deg(pitch)}


func _center_los(player: PlayerController, target: Vector3, record: Dictionary, expected_key: String, expected_run: int, view_id: String) -> Dictionary:
	var camera := player.get_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var projected := camera.unproject_position(target)
	if projected.distance_to(center) > 1.0:
		return {"ok": false, "message": "%s target is %.3f px from center." % [view_id, projected.distance_to(center)]}
	var origin := camera.project_ray_origin(center)
	var direction := camera.project_ray_normal(center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 2000.0, WORLD_SOLID_MASK, [player.get_rid()])
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return {"ok": false, "message": "%s center LOS hit nothing." % view_id}
	var collider := hit.get("collider") as CollisionObject3D
	var hit_key := "" if collider == null else str(collider.get_meta("derived_object_key", ""))
	var hit_sources: Array = [] if collider == null else collider.get_meta("source_keys", [])
	var hit_run := _nearest_run_index(record, hit.position as Vector3)
	var target_error := (hit.position as Vector3).distance_to(target)
	if hit_key != expected_key or hit_sources != [SOURCE_KEY] or hit_run != expected_run or target_error > 0.4:
		return {"ok": false, "message": "%s LOS hit %s %s run %d error %.3f; expected %s run %d." % [view_id, hit_key, hit_sources, hit_run, target_error, expected_key, expected_run]}
	return {"ok": true, "metadata": {"viewport_center_px": [center.x, center.y], "aim_target_center_error_px": projected.distance_to(center), "first_los_hit_receiver": hit_key, "first_los_hit_source_keys": hit_sources, "first_los_hit_run_index": hit_run, "expected_los_run_index": expected_run, "first_los_hit_position_m": _vector3(hit.position as Vector3), "first_los_hit_distance_m": origin.distance_to(hit.position as Vector3), "first_los_hit_target_error_m": target_error, "receiver_source_run_first_los": true}}


func _framing_metadata(camera: Camera3D, nodes: Array[Node3D]) -> Dictionary:
	var points: Array[Vector3] = []
	for node in nodes:
		for child_value: Variant in node.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := child_value as MeshInstance3D
			if mesh_instance == null or mesh_instance.mesh == null or not mesh_instance.is_visible_in_tree():
				continue
			var bounds := mesh_instance.get_aabb()
			for x_index in 2:
				for y_index in 2:
					for z_index in 2:
						points.append(mesh_instance.global_transform * (bounds.position + Vector3(bounds.size.x * x_index, bounds.size.y * y_index, bounds.size.z * z_index)))
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
	var size := maximum - minimum
	return {"ok": behind < points.size(), "metadata": {"target_bounds_point_count": points.size(), "target_bounds_points_behind_camera": behind, "target_projected_min_px": [minimum.x, minimum.y], "target_projected_max_px": [maximum.x, maximum.y], "target_projected_width_ratio": size.x / STILL_SIZE.x, "target_projected_height_ratio": size.y / STILL_SIZE.y, "target_bounds_fully_in_frame": minimum.x >= 0.0 and minimum.y >= 0.0 and maximum.x <= STILL_SIZE.x and maximum.y <= STILL_SIZE.y}}


func _framing_is_valid(result: Dictionary) -> bool:
	if not bool(result.get("ok", false)):
		return false
	var data := result.metadata as Dictionary
	return int(data.target_bounds_points_behind_camera) == 0 and bool(data.target_bounds_fully_in_frame) and float(data.target_projected_width_ratio) >= 0.12 and float(data.target_projected_height_ratio) >= 0.035 and float(data.target_projected_width_ratio) <= 0.96 and float(data.target_projected_height_ratio) <= 0.96


func _save_still(main: GameMain, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, view: Dictionary, stage: String, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s %s did not stabilize." % [view.id, stage]}
	var hud_state := _hud_state(hud)
	if bool(hud_state.debug_panel_visible) or bool(hud_state.feedback_panel_visible) or bool(hud_state.load_panel_visible) or bool(hud_state.pause_panel_visible) or not bool(hud_state.reticle_visible):
		return {"ok": false, "message": "%s %s HUD is not clean." % [view.id, stage]}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != STILL_SIZE:
		return {"ok": false, "message": "%s %s image is empty or wrong-sized." % [view.id, stage]}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s %s image appears blank." % [view.id, stage]}
	var capture_id := "%s-%s" % [str(view.id), stage]
	var relative := "images/%s.png" % capture_id
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save." % capture_id}
	var metadata := {"id": capture_id, "stage": stage, "target": "1441-chinook-court", "source_identity": SOURCE_KEY, "role": str(view.role), "recognition_verdict": "pending_independent_bar_raiser_review", "believability_verdict": "pending_independent_bar_raiser_review", "confusion_set_source_ids_frozen_before_capture": CONFUSION_SET, "reference_supported_cues_frozen_before_capture": FROZEN_SUPPORTED_CUES, "file": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [image.get_width(), image.get_height()], "sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range), "hud": hud_state, "player_visible": player.visible, "debug_labels_visible": false, "source_photography_in_frame": false, "lighting_changed": not (view.sun as Vector3).is_equal_approx(DEFAULT_SUN), "sun_rotation_degrees": _vector3(sun.rotation_degrees), "full_entity_required_and_in_frame": true, "protected_untreated_faces_intentionally_not_hidden": true, "capture_only_prototype_swap": stage == "after"}
	metadata.merge(extra, true)
	print("D2_1441_CAPTURE: id=%s grounded=%s frame=%.3fx%.3f sha256=%s" % [capture_id, metadata.physics_grounded, metadata.target_projected_width_ratio, metadata.target_projected_height_ratio, metadata.sha256])
	return {"ok": true, "metadata": metadata}


func _package_hashes() -> Dictionary:
	var paths := [CONFIG_PATH, CHUNK_PATH, PACKET_PATH, "res://game/scripts/world/facades/site_12_housing_kit.gd", "res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd", PROTOTYPE_SCENE_PATH, "res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres", "res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres", "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres", "res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres", "res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres", "res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres", "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png", "res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg"]
	var hashes := {}
	for path: String in paths:
		hashes[path] = FileAccess.get_sha256(path)
	return hashes


func _prototype_topology(prototype: Node3D) -> Dictionary:
	return {"mesh_instances": int(prototype.get_meta("mesh_instances", 0)), "surfaces": int(prototype.get_meta("surfaces", 0)), "visual_triangles": int(prototype.get_meta("visual_triangles", 0)), "visual_batch_triangles": prototype.get_meta("visual_batch_triangles", {}), "static_bodies": int(prototype.get_meta("static_bodies", 0)), "shapes": int(prototype.get_meta("shapes", 0)), "collision_triangles": int(prototype.get_meta("collision_triangles", 0)), "deterministic_signature": str(prototype.get_meta("deterministic_signature", "")), "wing_opening_count": int(prototype.get_meta("wing_opening_count", 0)), "recess_void_count": int(prototype.get_meta("recess_void_count", 0)), "rail_picket_count": int(prototype.get_meta("rail_picket_count", 0)), "mapped_eave_count": int(prototype.get_meta("mapped_eave_count", 0))}


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
	for run_index in 16:
		var offset := run_index * 12
		var distance := _point_segment_distance(Vector2(hit.x, hit.z), Vector2(float(values[offset]), float(values[offset + 2])), Vector2(float(values[offset + 3]), float(values[offset + 5])))
		if distance < best_distance:
			best_distance = distance
			best_index = run_index
	return best_index


func _point_segment_distance(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	if segment.length_squared() <= 0.0000001:
		return point.distance_to(start)
	return point.distance_to(start + segment * clampf((point - start).dot(segment) / segment.length_squared(), 0.0, 1.0))


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
	return {"debug_panel_visible": hud.debug_panel.visible, "feedback_panel_visible": hud.feedback_panel.visible, "load_panel_visible": hud.load_panel.visible, "pause_panel_visible": hud.pause_panel.visible, "reticle_visible": hud.reticle.visible}


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


func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


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
		_fail("1441 Chinook native evidence timed out after %.0f seconds." % TIMEOUT_SECONDS)
		_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	_clear_gameplay_input()
	if main != null and is_instance_valid(main):
		main.queue_free()
	quit(1 if not _failure.is_empty() else 0)
