extends SceneTree

const OUTPUT := "res://evidence/first-playable/building-1-public-front-believability-2026-09-04"
const HERO_CONFIG_PATH := "res://game/resources/facades/building_1_hero_model.json"
const BAR_CONFIG_PATH := "res://game/resources/facades/building_1_public_front_believability.json"
const ADAPTER_PATH := "res://game/scripts/world/facades/building_1_hero_model.gd"
const WALL_KEY := "building:r16681702:wall"
const ROOF_KEY := "building:r16681702:roof"
const CAPTURE_SIZE := Vector2i(1440, 900)
const WORLD_SOLID_MASK := 1
const SETTLE_START_HEIGHT_M := 3.0
const SETTLE_MAX_PHYSICS_FRAMES := 360
const SETTLE_CLEARANCE_TOLERANCE_M := 0.08
const MIN_ACTUAL_SPRING_LENGTH_M := 4.5
const MIN_CAMERA_HEIGHT_ABOVE_GROUND_M := 1.0
const TIMEOUT_SECONDS := 240.0
const CHANGED_LIGHT_ROTATION := Vector3(-18.0, 118.0, 0.0)
const COMMAND_PREFIX := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/building_1_public_front_believability_capture.gd -- --bar-stage="

# Frozen before the implementation pass. The same physics-grounded stock-player
# poses, targets, FOV, spring arm, viewport, and sun rotations are required for
# the after batch. These views intentionally inspect the public front only.
const VIEWS := [
	{
		"id": "01-public-front-whole-ordinary",
		"role": "ordinary_player_height_public_front_whole_composition",
		"requested_xz": Vector2(-72.908752, 757.150635),
		"aim_target": Vector3(0.941, 16.281, 749.703),
		"lighting": "world_default",
	},
	{
		"id": "02-public-front-entrances-ordinary",
		"role": "ordinary_player_height_canopy_base_and_three_entrance_groups",
		"requested_xz": Vector2(-72.908752, 757.150635),
		"aim_target": Vector3(0.941, 9.55, 749.703),
		"lighting": "world_default",
	},
	{
		"id": "03-public-front-whole-changed-light",
		"role": "ordinary_player_height_public_front_changed_light_depth_check",
		"requested_xz": Vector2(-72.908752, 757.150635),
		"aim_target": Vector3(0.941, 16.281, 749.703),
		"lighting": "frozen_changed_light",
	},
]

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	var stage := _stage_argument()
	if not _require(stage in ["before", "after"], "Pass exactly --bar-stage=before or --bar-stage=after after the script separator."):
		_finish(null)
		return
	if DisplayServer.get_name() == "headless":
		_fail("Building 1 public-front evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for Building 1 public-front evidence."):
		_finish(null)
		return
	var main := packed.instantiate() as GameMain
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
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Actual world did not reach one clean ready state for Building 1 public-front evidence.") \
	or not _require(Vector2i(root.get_texture().get_size()) == CAPTURE_SIZE, "Capture viewport is not exactly 1440x900."):
		_finish(main)
		return
	var bindings := _validate_bindings(world, stage)
	if not _require(bool(bindings.get("ok", false)), str(bindings.get("message", "Building 1 bindings failed."))):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images/%s" % stage)) == OK, "Could not create stage image directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	var original_sun := sun.rotation_degrees
	var captures: Array[Dictionary] = []
	for view_value: Variant in VIEWS:
		var view := view_value as Dictionary
		sun.rotation_degrees = CHANGED_LIGHT_ROTATION if str(view.lighting) == "frozen_changed_light" else original_sun
		var posed := await _settle_and_aim(world, player, hud, view)
		if not _require(bool(posed.get("ok", false)), str(posed.get("message", "%s pose failed." % str(view.id)))):
			_finish(main)
			return
		var los := _center_los(player, view)
		if not _require(bool(los.get("ok", false)), str(los.get("message", "%s exact LOS failed." % str(view.id)))):
			_finish(main)
			return
		var metadata := posed.metadata as Dictionary
		metadata.merge(los.metadata as Dictionary, true)
		metadata["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
		var saved := await _save_view(main, player, hud, view, stage, metadata)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "%s image save failed." % str(view.id)))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var runtime := world.get_runtime_evidence()
	var stage_manifest := {
		"schema_version": "ti.building-1-public-front-believability-stage-evidence/1",
		"stage": stage,
		"review_status": "pending_independent_bar_raiser_re_review_not_self_accepted",
		"recognition_status": "previously_accepted_unchanged_by_this_quality_hardening_pass",
		"evidence_role": "Fixed-camera technical before/after evidence for the bounded Building 1 public-front believability pass; executor made no visual acceptance judgment.",
		"capture_command": COMMAND_PREFIX + stage,
		"generator": "game/tests/building_1_public_front_believability_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/building_1_public_front_believability_capture.gd"),
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_contract": {
			"rig": "actual Player/CameraPivot/SpringArm3D/Camera3D",
			"fov_degrees": 70.0,
			"configured_spring_length_m": 5.5,
			"physics_grounded": true,
			"orientation": "input_reachable_stock_PlayerCamera_yaw_plus_clamped_spring_arm_pitch",
			"detached_camera": false,
			"crop_or_postprocess": false,
			"debug_labels_visible": false,
		},
		"bindings": bindings.metadata,
		"hero_config_path": HERO_CONFIG_PATH,
		"hero_config_sha256": FileAccess.get_sha256(HERO_CONFIG_PATH),
		"bar_config_path": BAR_CONFIG_PATH if FileAccess.file_exists(BAR_CONFIG_PATH) else "",
		"bar_config_sha256": FileAccess.get_sha256(BAR_CONFIG_PATH) if FileAccess.file_exists(BAR_CONFIG_PATH) else "",
		"adapter_path": ADAPTER_PATH,
		"adapter_sha256": FileAccess.get_sha256(ADAPTER_PATH),
		"runtime_topology": {
			"records": runtime.playable_rows,
			"meshes": runtime.mesh_instances,
			"surfaces": runtime.surfaces,
			"triangles": runtime.triangles,
			"static_bodies": runtime.static_bodies,
			"shapes": runtime.shapes,
		},
		"fixed_view_definitions": _serializable_view_definitions(),
		"captures": captures,
		"capture_count": captures.size(),
		"source_photography_shipped": false,
		"generated_facade_image_used": false,
		"genai_texture_candidate_consumed": false,
		"visual_verdict": "pending_independent_bar_raiser_re_review",
	}
	if stage == "after":
		var before := _json(OUTPUT.path_join("before-capture.json"))
		if not _require(_before_after_fixed(before, stage_manifest), "After batch no longer matches the frozen before camera/light definitions and observed poses."):
			_finish(main)
			return
		stage_manifest["before_manifest_sha256"] = FileAccess.get_sha256(OUTPUT.path_join("before-capture.json"))
		stage_manifest["before_after_camera_and_light_match"] = true
	if not _write_json(OUTPUT.path_join("%s-capture.json" % stage), stage_manifest):
		_fail("Could not write %s stage manifest." % stage)
		_finish(main)
		return
	if stage == "after":
		var combined := {
			"schema_version": "ti.building-1-public-front-believability-evidence/1",
			"review_status": "pending_independent_bar_raiser_re_review_not_self_accepted",
			"recognition_status": "accepted_before_and_preserved",
			"before_manifest": "before-capture.json",
			"before_manifest_sha256": FileAccess.get_sha256(OUTPUT.path_join("before-capture.json")),
			"after_manifest": "after-capture.json",
			"after_manifest_sha256": FileAccess.get_sha256(OUTPUT.path_join("after-capture.json")),
			"pairs": _pairs(captures),
			"exact_fixed_camera_and_light_pairs": true,
			"source_photography_shipped": false,
			"generated_facade_image_used": false,
			"genai_texture_candidate_consumed": false,
			"reviewer_instruction": "Open each before/after pair at original 1440x900 detail. Re-review only public-front depth/value hierarchy and the removal of the misleading cruciform end treatment. Confirm 11 bays, fluted pilaster/reveal cadence, projecting base, canopy leading edge/underside, and three entrance groups read at ordinary distance. Recognition remains accepted, but believability verdict is pending independent bar-raiser review.",
		}
		if not _write_json(OUTPUT.path_join("capture-manifest.json"), combined):
			_fail("Could not write combined Building 1 public-front manifest.")
			_finish(main)
			return
	print("PASS: captured %s Building 1 public-front stage with %d fixed grounded views on native %s/%s" % [stage, captures.size(), DisplayServer.get_name(), RenderingServer.get_video_adapter_name()])
	_finish(main)


func _stage_argument() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--bar-stage="):
			return argument.trim_prefix("--bar-stage=")
	return ""


func _validate_bindings(world: WorldLoader, stage: String) -> Dictionary:
	var wall_nodes := _record_nodes(world, WALL_KEY)
	var roof_nodes := _record_nodes(world, ROOF_KEY)
	if wall_nodes.size() != 1 or roof_nodes.size() != 1:
		return {"ok": false, "message": "Building 1 wall/roof did not resolve exactly once."}
	var wall := wall_nodes[0]
	var roof := roof_nodes[0]
	for node: Node3D in [wall, roof]:
		if not bool(node.get_meta("runtime_supersedes_generated_placeholder", false)) or node.get_meta("source_keys", []) != ["r16681702"]:
			return {"ok": false, "message": "%s lost exact hero/source binding." % str(node.get_meta("derived_object_key", ""))}
	if stage == "after" and (not bool(wall.get_meta("public_front_believability_pass", false)) or not bool(roof.get_meta("public_front_believability_pass", false))):
		return {"ok": false, "message": "After capture did not load the public-front believability pass on wall and roof."}
	return {
		"ok": true,
		"metadata": {
			"wall_path": str(wall.get_path()),
			"roof_path": str(roof.get_path()),
			"wall_source_keys": wall.get_meta("source_keys", []),
			"roof_source_keys": roof.get_meta("source_keys", []),
			"wall_triangles": int(wall.get_meta("triangles", -1)),
			"roof_triangles": int(roof.get_meta("triangles", -1)),
			"wall_collision_face_vertices": int(wall.get_meta("collision_face_vertices", -1)),
			"roof_collision_face_vertices": int(roof.get_meta("collision_face_vertices", -1)),
			"public_front_believability_pass": bool(wall.get_meta("public_front_believability_pass", false)),
			"visual_review_status": str(wall.get_meta("visual_review_status", "")),
		},
	}


func _settle_and_aim(world: WorldLoader, player: PlayerController, hud: GameHUD, view: Dictionary) -> Dictionary:
	var requested_xz := view.requested_xz as Vector2
	if not world.get_boundary().contains_position(Vector3(requested_xz.x, 0.0, requested_xz.y)):
		return {"ok": false, "message": "%s fixed anchor is outside the playable boundary." % str(view.id)}
	var initial_hit := _ground_hit(player, requested_xz)
	var initial_ground := _ground_metadata(initial_hit)
	if not bool(initial_ground.get("ok", false)):
		return {"ok": false, "message": "%s fixed anchor has no generated walkable support: %s" % [str(view.id), str(initial_ground.get("message", "unknown"))]}
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
		return {"ok": false, "message": "%s stock camera contract failed: fov=%.3f configured=%.3f actual=%.3f height=%.3f." % [str(view.id), camera.fov, arm.spring_length, actual_spring, camera_height]}
	return {
		"ok": true,
		"metadata": {
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
		return {"ok": false, "message": "target pitch %.2f is outside stock PlayerCamera limits." % rad_to_deg(pitch)}
	rig.rotation = Vector3(0.0, yaw, 0.0)
	arm.rotation = Vector3(pitch, 0.0, 0.0)
	rig.force_update_transform()
	arm.force_update_transform()
	return {"ok": true, "yaw_degrees": rad_to_deg(yaw), "pitch_degrees": rad_to_deg(pitch)}


func _center_los(player: PlayerController, view: Dictionary) -> Dictionary:
	var camera := player.get_camera()
	var viewport_center := camera.get_viewport().get_visible_rect().size * 0.5
	var projected_target := camera.unproject_position(view.aim_target as Vector3)
	if projected_target.distance_to(viewport_center) > 1.0:
		return {"ok": false, "message": "%s aim target is %.3f px from viewport center." % [str(view.id), projected_target.distance_to(viewport_center)]}
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
	if hit_key != WALL_KEY or hit_sources != ["r16681702"]:
		return {"ok": false, "message": "%s first LOS hit %s %s instead of %s [r16681702]." % [str(view.id), hit_key, str(hit_sources), WALL_KEY]}
	return {
		"ok": true,
		"metadata": {
			"viewport_center_px": [viewport_center.x, viewport_center.y],
			"aim_target_screen_px": [projected_target.x, projected_target.y],
			"aim_target_center_error_px": projected_target.distance_to(viewport_center),
			"first_los_hit_receiver": hit_key,
			"first_los_hit_source_keys": hit_sources,
			"first_los_hit_position_m": _vector3(hit.position as Vector3),
			"first_los_hit_distance_m": origin.distance_to(hit.position as Vector3),
			"receiver_first_los": true,
		},
	}


func _save_view(main: GameMain, player: PlayerController, hud: GameHUD, view: Dictionary, stage: String, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s did not stabilize for image capture." % str(view.id)}
	var hud_state := _hud_state(hud)
	if bool(hud_state.debug_panel_visible) or bool(hud_state.feedback_panel_visible) or bool(hud_state.load_panel_visible) or bool(hud_state.pause_panel_visible) or not bool(hud_state.reticle_visible):
		return {"ok": false, "message": "%s HUD state is not clean and ordinary: %s" % [str(view.id), JSON.stringify(hud_state)]}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s returned an empty or wrong-sized native image." % str(view.id)}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s native image appears blank." % str(view.id)}
	var relative := "images/%s/%s.png" % [stage, str(view.id)]
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save its PNG." % str(view.id)}
	var metadata := {
		"id": str(view.id),
		"role": str(view.role),
		"lighting": str(view.lighting),
		"stage": stage,
		"file": relative,
		"sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [image.get_width(), image.get_height()],
		"sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range),
		"hud": hud_state,
		"debug_labels_visible": false,
		"source_photography_in_frame": false,
		"visual_verdict": "pending_independent_bar_raiser_re_review",
	}
	metadata.merge(extra, true)
	print("BUILDING1_PUBLIC_FRONT_CAPTURE: stage=%s id=%s receiver=%s grounded=%s arm=%.3f image=%s sha256=%s" % [
		stage, str(view.id), str(metadata.first_los_hit_receiver), str(metadata.physics_grounded), float(metadata.actual_spring_length_m), ProjectSettings.globalize_path(path), str(metadata.sha256),
	])
	return {"ok": true, "metadata": metadata}


func _before_after_fixed(before: Dictionary, after: Dictionary) -> bool:
	if before.is_empty() or not _values_close(before.get("fixed_view_definitions", []), after.get("fixed_view_definitions", []), 0.000001):
		print("BUILDING1_PUBLIC_FRONT_PAIR_MISMATCH: fixed definitions before=%s after=%s" % [JSON.stringify(before.get("fixed_view_definitions", [])), JSON.stringify(after.get("fixed_view_definitions", []))])
		return false
	var before_captures := before.get("captures", []) as Array
	var after_captures := after.get("captures", []) as Array
	if before_captures.size() != after_captures.size():
		return false
	for index in before_captures.size():
		var first := before_captures[index] as Dictionary
		var second := after_captures[index] as Dictionary
		for key in ["id", "requested_xz", "player_position_m", "aim_target_m", "camera_position_m", "camera_forward", "camera_fov_degrees", "configured_spring_length_m", "sun_rotation_degrees"]:
			if not _values_close(first.get(key), second.get(key), 0.001):
				print("BUILDING1_PUBLIC_FRONT_PAIR_MISMATCH: view=%s key=%s before=%s after=%s" % [str(first.get("id", index)), key, JSON.stringify(first.get(key)), JSON.stringify(second.get(key))])
				return false
	return true


func _values_close(first: Variant, second: Variant, tolerance: float) -> bool:
	if first is Array and second is Array:
		if first.size() != second.size():
			return false
		for index in first.size():
			if not _values_close(first[index], second[index], tolerance):
				return false
		return true
	if first is Dictionary and second is Dictionary:
		if first.size() != second.size():
			return false
		for key: Variant in first:
			if not second.has(key) or not _values_close(first[key], second[key], tolerance):
				return false
		return true
	if first is float or first is int:
		return absf(float(first) - float(second)) <= tolerance
	return first == second


func _serializable_view_definitions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Variant in VIEWS:
		var view := value as Dictionary
		result.append({
			"id": str(view.id),
			"role": str(view.role),
			"requested_xz": [float((view.requested_xz as Vector2).x), float((view.requested_xz as Vector2).y)],
			"aim_target_m": _vector3(view.aim_target as Vector3),
			"lighting": str(view.lighting),
			"changed_light_rotation_degrees": _vector3(CHANGED_LIGHT_ROTATION) if str(view.lighting) == "frozen_changed_light" else [],
		})
	return result


func _pairs(after_captures: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for capture: Dictionary in after_captures:
		result.append({
			"id": str(capture.id),
			"before": "images/before/%s.png" % str(capture.id),
			"after": "images/after/%s.png" % str(capture.id),
			"camera_and_light_match": true,
			"verdict": "pending_independent_bar_raiser_re_review",
		})
	return result


func _record_nodes(world: WorldLoader, key: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == key and value.has_meta("feature_kind"):
			result.append(value as Node3D)
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
	return not paused and not bool(_hud_state(hud).debug_panel_visible) and not bool(_hud_state(hud).pause_panel_visible)


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


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


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
		_fail("Building 1 public-front native evidence timed out after %.0f seconds." % TIMEOUT_SECONDS)
		_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	if main != null and is_instance_valid(main):
		main.queue_free()
	quit(1 if not _failure.is_empty() else 0)
