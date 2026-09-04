extends "res://game/tests/isle_house_low_live_evidence_capture.gd"

## Actual-live capture only. This subclasses the accepted stock-player capture
## mechanics but never attaches a preview or standalone branch.

const LIVE_OUTPUT := "res://evidence/first-playable/isle-house-composite-repair-variant-c-live-replacement-2026-09-04"
const LIVE_GENERATOR := "res://game/tests/isle_house_variant_c_live_replacement_capture.gd"
const VARIANT_C_LIVE_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd"
const VARIANT_C_FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_repair_only_factory.gd"
const LIVE_CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const VARIANT_C_LIVE_SIGNATURE := "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981"
const VARIANT_C_REPAIR_SIGNATURE := "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69"
const VARIANT_C_REVIEW_SHA := "b9877edb51eb9cc09bfd08f33d2664d7d3de08736daa2b96dc6e36c60d0fb5e5"
const LIVE_WORLD_TOPOLOGY := {"rows": 735, "meshes": 940, "surfaces": 954, "triangles": 64118, "bodies": 466, "shapes": 466}
const LIVE_MOTION_FILE := "isle-house-variant-c-actual-live-public-corner-stock-walk.avi"
const LIVE_MOTION_FRAMES := 300
const LIVE_MOTION_HZ := 60

const LIVE_VIEWS := [
	{
		"id": "01-wsw-whole-composite-default",
		"side": "WSW_Avenue_of_the_Palms",
		"role": "grounded_ordinary_player_actual_live_whole_high_plus_low_composite",
		"requested_xz": Vector2(-202.0, 568.0),
		"aim_target": Vector3(-128.0, 26.0, 559.0),
		"expected_receiver": HIGH_WALL_KEY,
		"expected_sources": ["w1282547786"],
		"lighting": "world_default",
		"whole_composite": true,
		"minimum_actual_spring_m": 4.0,
	},
	{
		"id": "03-ene-public-supplemental",
		"side": "ENE_Garden_Walk",
		"role": "grounded_ordinary_player_actual_live_low_supplemental",
		"requested_xz": Vector2(-95.79, 504.61),
		"aim_target": Vector3(-107.42, 9.0, 503.81),
		"expected_receiver": LOW_WALL_KEY,
		"expected_sources": ["w1282547787"],
		"lighting": "world_default",
		"whole_composite": false,
		"minimum_actual_spring_m": 2.0,
	},
	{
		"id": "04-nnw-quiet-return-direct",
		"side": "NNW_quiet_protected_return",
		"role": "grounded_ordinary_player_actual_live_direct_quiet_return",
		"requested_xz": Vector2(-164.0, 456.0),
		"aim_target": Vector3(-137.0, 12.0, 493.0),
		"expected_receiver": LOW_WALL_KEY,
		"expected_sources": ["w1282547787"],
		"lighting": "world_default",
		"whole_composite": false,
		"minimum_actual_spring_m": 3.5,
	},
]


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	var mode := _argument_value("--capture-mode=")
	if mode == "finalize-motion":
		_finalize_live_motion()
		_finish(null)
		return
	if mode not in ["stills", "motion"]:
		_fail("Pass exactly --capture-mode=stills, motion, or finalize-motion.")
		_finish(null)
		return
	if DisplayServer.get_name() == "headless":
		_fail("Actual-live Variant C evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	var loaded := await _load_actual_live_main(mode)
	if not _require(bool(loaded.get("ok", false)), str(loaded.get("message", "Main scene failed."))):
		_finish(loaded.get("main", null) as Node)
		return
	var main := loaded.main as GameMain
	var world := loaded.world as WorldLoader
	var player := loaded.player as PlayerController
	var hud := loaded.hud as GameHUD
	var sun := loaded.sun as DirectionalLight3D
	var observed_size := Vector2i(root.get_texture().get_size())
	var size_ok := observed_size == STILL_SIZE if mode == "stills" else (
		observed_size.x >= 960 and observed_size.y >= 600
		and absf(float(observed_size.x) / float(observed_size.y) - 1.6) <= 0.005
	)
	if not _require(size_ok, "%s viewport %s violates its native capture-size contract." % [mode, observed_size]):
		_finish(main)
		return
	var bindings := _actual_live_bindings(world)
	if not _require(bool(bindings.get("ok", false)), str(bindings.get("message", "Actual-live binding failed."))):
		_finish(main)
		return
	if not _require(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(LIVE_OUTPUT.path_join("images"))) == OK, "Could not create fresh actual-live evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	if mode == "stills":
		await _capture_live_stills(main, world, player, hud, sun, bindings.metadata as Dictionary)
	else:
		await _capture_live_motion(main, world, player, hud, sun, bindings.metadata as Dictionary)
	_finish(main)


func _load_actual_live_main(mode: String) -> Dictionary:
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if packed == null:
		return {"ok": false, "message": "Main scene did not load."}
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var hud := main.get_node("Interface/HUD") as GameHUD
	var sun := main.get_node("Sun") as DirectionalLight3D
	var ready: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await process_frame
	if not failures.is_empty() or ready.size() != 1:
		return {"ok": false, "message": "%s world did not reach one ready state: %s" % [mode, failures], "main": main}
	while not player.was_first_reveal_grounded() and failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await physics_frame
	if not player.was_first_reveal_grounded() or not player.visible:
		return {"ok": false, "message": "%s player did not complete native startup settle." % mode, "main": main}
	if str(ready[0].get("content_sha256", "")) != EXPECTED_CONTENT_SHA256 or FileAccess.get_sha256("res://generated/world/manifest.json") != EXPECTED_MANIFEST_SHA256:
		return {"ok": false, "message": "Generated world identity drifted before actual-live capture.", "main": main}
	var e := world.get_runtime_evidence()
	var topology := {"rows": e.playable_rows, "meshes": e.mesh_instances, "surfaces": e.surfaces, "triangles": e.triangles, "bodies": e.static_bodies, "shapes": e.shapes}
	if topology != LIVE_WORLD_TOPOLOGY:
		return {"ok": false, "message": "Actual-live world topology drifted: %s." % topology, "main": main}
	return {"ok": true, "main": main, "world": world, "player": player, "hud": hud, "sun": sun}


func _actual_live_bindings(world: WorldLoader) -> Dictionary:
	var lows := _record_nodes(world, LOW_WALL_KEY)
	var highs := _record_nodes(world, HIGH_WALL_KEY)
	if lows.size() != 1 or highs.size() != 1:
		return {"ok": false, "message": "Exact high/low receiver did not resolve once."}
	var low := lows[0]
	var high := highs[0]
	var live := low.get_node_or_null("IsleHouseCompositeRepairVariantCLiveAttachment") as Node3D
	var high_facade := high.get_node_or_null("IsleHouse39BrutonHighFacade") as Node3D
	if live == null or str(live.get_meta("live_deterministic_signature", "")) != VARIANT_C_LIVE_SIGNATURE \
	or str(live.get_meta("repair_signature", "")) != VARIANT_C_REPAIR_SIGNATURE \
	or str(live.get_meta("approval_review_sha256", "")) != VARIANT_C_REVIEW_SHA \
	or high_facade == null or str(high_facade.get_meta("deterministic_signature", "")) != HIGH_SIGNATURE:
		return {"ok": false, "message": "Actual-live low or accepted-high signature did not resolve."}
	if low.get_node_or_null("IsleHouse39BrutonLowLiveAttachment") != null or low.get_node_or_null("FailedLiveParentLowOverlay") != null \
	or bool(live.get_meta("rejected_overlay_fallback_used", true)) or bool(live.get_meta("overlay_stacked", true)):
		return {"ok": false, "message": "Rejected overlay is present, stacked, or marked as fallback."}
	var body := low.get_node_or_null("Collision") as StaticBody3D
	if body == null or not body.is_in_group("spray_receiver_wall") or _count_type(low, CollisionObject3D) != 1 \
	or _count_type(live, CollisionObject3D) != 0 or _count_type(live, CollisionShape3D) != 0 or _count_type(live, NavigationRegion3D) != 0:
		return {"ok": false, "message": "Actual-live low ownership drifted."}
	return {"ok": true, "metadata": {
		"low_receiver_path": str(low.get_path()), "low_receiver_source_keys": low.get_meta("source_keys", []),
		"live_node_path": str(live.get_path()), "live_signature": VARIANT_C_LIVE_SIGNATURE,
		"repair_signature": VARIANT_C_REPAIR_SIGNATURE, "approval_review_sha256": VARIANT_C_REVIEW_SHA,
		"high_receiver_path": str(high.get_path()), "high_receiver_source_keys": high.get_meta("source_keys", []),
		"high_facade_signature": HIGH_SIGNATURE, "preview_nodes_attached": 0,
		"rejected_overlay_present": false, "overlay_stacked": false,
		"underlying_wall_is_sole_collision_and_spray_receiver": true,
		"recognition_accepted": false, "believability_accepted": false,
	}}


func _capture_live_stills(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary) -> void:
	var original_sun := sun.rotation_degrees
	var captures: Array[Dictionary] = []
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(LIVE_CHUNK_PATH)) as Dictionary
	var high_record := _record_for_key(chunk.records as Array, HIGH_WALL_KEY)
	var low_record := _record_for_key(chunk.records as Array, LOW_WALL_KEY)
	for value: Variant in LIVE_VIEWS:
		var view := value as Dictionary
		sun.rotation_degrees = original_sun
		var pose := await _settle_and_aim(world, player, hud, view.requested_xz as Vector2, view.aim_target as Vector3, str(view.id), float(view.minimum_actual_spring_m))
		if not _require(bool(pose.get("ok", false)), str(pose.get("message", "%s pose failed." % str(view.id)))):
			return
		var los := _center_los(player, view.aim_target as Vector3, str(view.expected_receiver), view.expected_sources as Array, str(view.id))
		if not _require(bool(los.get("ok", false)), str(los.get("message", "%s LOS failed." % str(view.id)))):
			return
		var extra := pose.metadata as Dictionary
		extra.merge(los.metadata as Dictionary, true)
		extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
		if bool(view.whole_composite):
			var projection := _composite_projection(player.get_camera(), high_record, low_record)
			if not _require(_whole_projection_useful(projection), "WSW actual-live whole-composite framing is not useful: %s" % projection):
				return
			extra["composite_projection"] = projection
		var saved := await _save_live_still(main, player, hud, view, extra)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "%s save failed." % str(view.id)))):
			return
		captures.append(saved.metadata as Dictionary)
		if str(view.id) == "01-wsw-whole-composite-default":
			sun.rotation_degrees = CHANGED_LIGHT_ROTATION
			var changed_view := view.duplicate(true)
			changed_view.id = "02-wsw-whole-composite-changed-light"
			changed_view.lighting = "frozen_changed_light"
			var changed_extra := extra.duplicate(true)
			changed_extra.sun_rotation_degrees = _vector3(sun.rotation_degrees)
			changed_extra.same_pose_as = "01-wsw-whole-composite-default"
			var changed := await _save_live_still(main, player, hud, changed_view, changed_extra)
			if not _require(bool(changed.get("ok", false)), str(changed.get("message", "Changed-light save failed."))):
				return
			captures.append(changed.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var manifest := {
		"schema_version": "ti.isle-house-variant-c-actual-live-evidence/1",
		"review_status": "pending_independent_exact_current_live_review_not_self_accepted",
		"recognition_status": "pending_independent_review",
		"believability_status": "pending_independent_review",
		"generator": LIVE_GENERATOR.trim_prefix("res://"), "generator_sha256": FileAccess.get_sha256(LIVE_GENERATOR),
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "viewport": [STILL_SIZE.x, STILL_SIZE.y],
		"capture_count": captures.size(), "captures": captures, "bindings": bindings,
		"runtime_topology": LIVE_WORLD_TOPOLOGY.duplicate(true),
		"live_adapter_sha256": FileAccess.get_sha256(VARIANT_C_LIVE_PATH),
		"repair_factory_sha256": FileAccess.get_sha256(VARIANT_C_FACTORY_PATH),
		"actual_live_node_resolved": true, "preview_or_standalone_attachment_count": 0,
		"source_photography_shipped": false, "source_urls_in_runtime": false,
		"nonclaims": ["exact upper opening, floor, or story schedule", "NNW opening schedule or as-built cladding", "private/rear facade", "roof alteration", "as-built fidelity", "exact-current live recognition or believability acceptance"],
		"visual_verdict": "pending_independent_review",
	}
	if not _write_json(LIVE_OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write actual-live still manifest.")
		return
	print("PASS: captured four actual-live grounded frames, including same-pose WSW default/changed light, ENE supplemental, and direct NNW, with no preview attachment")


func _capture_live_motion(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary) -> void:
	if Engine.physics_ticks_per_second != LIVE_MOTION_HZ:
		_fail("Physics tick rate drifted from %d Hz." % LIVE_MOTION_HZ)
		return
	sun.rotation_degrees = Vector3(-51.999992, -27.999996, 0.0)
	var wall_start := MOTION_WALL_CORNER + MOTION_TANGENT * MOTION_START_ALONG_M
	var requested := Vector2(wall_start.x + MOTION_OUTWARD.x * MOTION_OUTWARD_DISTANCE_M, wall_start.z + MOTION_OUTWARD.z * MOTION_OUTWARD_DISTANCE_M)
	var target := Vector3(wall_start.x, 8.0, wall_start.z)
	var pose := await _settle_and_aim(world, player, hud, requested, target, "actual-live-public-corner-motion-start")
	if not _require(bool(pose.get("ok", false)), str(pose.get("message", "Motion pose failed."))):
		return
	var los := _center_los(player, target, LOW_WALL_KEY, ["w1282547787"], "actual-live-public-corner-motion-start")
	if not _require(bool(los.get("ok", false)), str(los.get("message", "Motion LOS failed."))):
		return
	var recoveries_before := world.get_runtime_evidence().recovery_count
	var start_position := player.global_position
	var start_camera_basis := player.get_camera().global_basis
	var start_process_frame := Engine.get_process_frames()
	var start_physics_frame := Engine.get_physics_frames()
	var samples: Array[Dictionary] = []
	player.set_gameplay_enabled(true)
	Input.action_press("move_right")
	for index in LIVE_MOTION_FRAMES:
		paused = false
		_clean_hud(hud)
		await physics_frame
		var position := player.global_position
		samples.append({"frame": index + 1, "player_position_m": _vector3(position), "velocity_mps": _vector3(player.velocity), "is_on_floor": player.is_on_floor(), "along_from_corner_m": (position - MOTION_WALL_CORNER).dot(MOTION_TANGENT), "outward_from_wall_chain_m": (position - MOTION_WALL_CORNER).dot(MOTION_OUTWARD)})
		if not player.is_on_floor():
			Input.action_release("move_right")
			_fail("Stock player left generated ground at motion frame %d." % (index + 1))
			return
	var input_end_process_frame := Engine.get_process_frames()
	var input_end_physics_frame := Engine.get_physics_frames()
	Input.action_release("move_right")
	for _frame in 12:
		await physics_frame
	player.set_gameplay_enabled(false)
	var end_position := player.global_position
	var displacement := Vector2(end_position.x - start_position.x, end_position.z - start_position.z).length()
	var start_along := (start_position - MOTION_WALL_CORNER).dot(MOTION_TANGENT)
	var end_along := (end_position - MOTION_WALL_CORNER).dot(MOTION_TANGENT)
	var direction := Vector3(end_position.x - start_position.x, 0.0, end_position.z - start_position.z).normalized()
	if not _require(displacement >= 18.0 and displacement <= 22.0, "Stock walk displacement %.3f m escaped its 5 s envelope." % displacement) \
	or not _require(start_along < -7.0 and end_along > 10.0, "Stock walk did not cross the public runs 2/3 corner: %.3f -> %.3f." % [start_along, end_along]) \
	or not _require(direction.dot(MOTION_TANGENT) > 0.995, "Stock walk direction diverged from public chain.") \
	or not _require(world.get_runtime_evidence().recovery_count == recoveries_before, "Stock walk triggered recovery.") \
	or not _require(start_camera_basis.is_equal_approx(player.get_camera().global_basis), "Camera orientation changed during stock walk."):
		return
	var manifest := {
		"schema_version": "ti.isle-house-variant-c-actual-live-motion-evidence/1",
		"review_status": "pending_independent_exact_current_live_review_not_self_accepted",
		"generator": LIVE_GENERATOR.trim_prefix("res://"), "generator_sha256": FileAccess.get_sha256(LIVE_GENERATOR),
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(), "video_adapter": RenderingServer.get_video_adapter_name(),
		"movie_dimensions": [MOTION_SIZE.x, MOTION_SIZE.y], "movie_file": LIVE_MOTION_FILE,
		"movie_sha256": "pending_after_movie_writer_close", "movie_bytes": -1, "movie_finalized_after_writer_close": false,
		"review_motion_process_frame_range": [start_process_frame, input_end_process_frame], "review_motion_physics_frame_range": [start_physics_frame, input_end_physics_frame],
		"fixed_fps": 30, "physics_ticks_per_second": LIVE_MOTION_HZ, "input_action": "move_right", "run_action_pressed": false,
		"configured_walk_speed_mps": player.walk_speed_mps, "motion_physics_frames": LIVE_MOTION_FRAMES,
		"continuous_duration_seconds": float(LIVE_MOTION_FRAMES) / LIVE_MOTION_HZ,
		"start_position_m": _vector3(start_position), "end_position_m": _vector3(end_position), "horizontal_displacement_m": displacement,
		"start_along_from_corner_m": start_along, "end_along_from_corner_m": end_along, "direction_dot_public_tangent": direction.dot(MOTION_TANGENT),
		"public_chain": "LOW-WSW-AVENUE-OF-THE-PALMS", "crossed_source_run_corner": "run_2_to_run_3",
		"player_transform_writes_after_input_began": 0, "camera_orientation_changed_during_motion": false,
		"all_samples_grounded": true, "recovery_delta": world.get_runtime_evidence().recovery_count - recoveries_before,
		"samples": samples, "bindings": bindings, "runtime_topology": LIVE_WORLD_TOPOLOGY.duplicate(true),
		"visual_verdict": "pending_independent_review",
	}
	if not _write_json(LIVE_OUTPUT.path_join("motion-capture.json"), manifest):
		_fail("Could not write preliminary actual-live motion manifest.")
		return
	print("PASS: drove a %.3f m, %.1f s continuous grounded stock-player walk across actual-live Variant C with 0 transform writes and recoveries; post-close finalization pending" % [displacement, float(LIVE_MOTION_FRAMES) / LIVE_MOTION_HZ])


func _finalize_live_motion() -> void:
	var expected_hash := _argument_value("--movie-sha256=")
	var expected_bytes := int(_argument_value("--movie-bytes="))
	var movie_path := LIVE_OUTPUT.path_join(LIVE_MOTION_FILE)
	var manifest_path := LIVE_OUTPUT.path_join("motion-capture.json")
	var manifest := _json(manifest_path)
	if not _require(expected_hash.length() == 64 and expected_hash == FileAccess.get_sha256(movie_path), "Movie finalizer received incorrect SHA-256.") \
	or not _require(expected_bytes > 0 and expected_bytes == FileAccess.get_file_as_bytes(movie_path).size(), "Movie finalizer received incorrect byte count.") \
	or not _require(str(manifest.get("movie_sha256", "")) == "pending_after_movie_writer_close", "Motion manifest was not in its one-time post-close state."):
		return
	manifest.movie_sha256 = expected_hash
	manifest.movie_bytes = expected_bytes
	manifest.movie_finalized_after_writer_close = true
	manifest.finalizer = "post-MovieWriter-close exact SHA-256 and byte-count seal"
	if not _write_json(manifest_path, manifest):
		_fail("Could not finalize actual-live motion manifest.")
		return
	print("PASS: finalized actual-live Variant C movie sha256=%s bytes=%d" % [expected_hash, expected_bytes])


func _save_live_still(main: GameMain, player: PlayerController, hud: GameHUD, view: Dictionary, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s did not stabilize." % str(view.id)}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != STILL_SIZE:
		return {"ok": false, "message": "%s returned wrong-sized image." % str(view.id)}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s appears blank." % str(view.id)}
	var relative := "images/%s.png" % str(view.id)
	var path := LIVE_OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save." % str(view.id)}
	var metadata := {"id": str(view.id), "side": str(view.side), "role": str(view.role), "lighting": str(view.lighting), "file": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [image.get_width(), image.get_height()], "sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range), "debug_labels_visible": false, "source_photography_in_frame": false, "crop_or_postprocess": false, "visual_verdict": "pending_independent_review"}
	metadata.merge(extra, true)
	print("ISLE_VARIANT_C_ACTUAL_LIVE_CAPTURE: id=%s image=%s sha256=%s" % [view.id, ProjectSettings.globalize_path(path), metadata.sha256])
	return {"ok": true, "metadata": metadata}


func _composite_projection(camera: Camera3D, high_record: Dictionary, low_record: Dictionary) -> Dictionary:
	var high := _project_record(camera, high_record)
	var low := _project_record(camera, low_record)
	return {"ok": bool(high.get("ok", false)) and bool(low.get("ok", false)), "high": high, "low": low}


func _project_record(camera: Camera3D, record: Dictionary) -> Dictionary:
	var raw := record.get("vertices", []) as Array
	var viewport := camera.get_viewport().get_visible_rect().size
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	var count := 0
	for offset in range(0, raw.size(), 3):
		var point := Vector3(float(raw[offset]), float(raw[offset + 1]), float(raw[offset + 2]))
		if camera.is_position_behind(point):
			continue
		var pixel := camera.unproject_position(point)
		minimum = Vector2(minf(minimum.x, pixel.x), minf(minimum.y, pixel.y))
		maximum = Vector2(maxf(maximum.x, pixel.x), maxf(maximum.y, pixel.y))
		count += 1
	if count == 0:
		return {"ok": false}
	var clipped_min := Vector2(clampf(minimum.x, 0.0, viewport.x), clampf(minimum.y, 0.0, viewport.y))
	var clipped_max := Vector2(clampf(maximum.x, 0.0, viewport.x), clampf(maximum.y, 0.0, viewport.y))
	var size := clipped_max - clipped_min
	return {"ok": true, "clipped_min_px": [clipped_min.x, clipped_min.y], "clipped_max_px": [clipped_max.x, clipped_max.y], "clipped_width_px": size.x, "clipped_height_px": size.y, "clipped_area_fraction": size.x * size.y / (viewport.x * viewport.y)}


func _whole_projection_useful(projection: Dictionary) -> bool:
	var high := projection.get("high", {}) as Dictionary
	var low := projection.get("low", {}) as Dictionary
	return bool(projection.get("ok", false)) and float(high.get("clipped_height_px", 0.0)) >= 260.0 \
		and float(high.get("clipped_area_fraction", 0.0)) >= 0.05 and float(low.get("clipped_height_px", 0.0)) >= 70.0 \
		and float(low.get("clipped_area_fraction", 0.0)) >= 0.018


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		if str((value as Dictionary).get("object_key", "")) == key:
			return value as Dictionary
	return {}
