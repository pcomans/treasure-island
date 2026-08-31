extends SceneTree

const OUTPUT_DIRECTORY := "res://evidence/first-playable/77-bruton-massing-2026-08-29"
const PRIOR_EVIDENCE_DIRECTORY := "res://evidence/first-playable/77-bruton-facade-correction-2026-08-29"
const TARGET_RECEIVER_PATH := "PlayableWorld/Buildings/x_-1__z_1__building_w1249412093_wall/building_w1249412093_wall"
const TARGET_WALL_KEY := "building:w1249412093:wall"
const TARGET_ROOF_KEY := "building:w1249412093:roof"
const TARGET_SOURCE_KEY := "w1249412093"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const CAPTURE_SIZE := Vector2i(1440, 900)
const WORLD_SOLID_MASK := 1
const SPRAY_SURFACE_MASK := 1 << 2
const TIMEOUT_SECONDS := 150.0

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Hawkins evidence capture requires the real macOS rendering display.")
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for Hawkins capture."):
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
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - wait_started < 30000:
		await process_frame
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Full world did not reach one clean world_ready for Hawkins capture."):
		_finish(main)
		return
	var report := ready_reports[0]
	var evidence := world.get_runtime_evidence()
	var receiver := world.get_node_or_null(TARGET_RECEIVER_PATH) as Node3D
	var facade := receiver.get_node_or_null("Hawkins77BrutonFacade") as Hawkins77BrutonFacade if receiver != null else null
	if not _require(str(report.get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted before capture.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated manifest hash drifted before capture.") \
	or not _require(receiver != null and facade != null, "Exact Hawkins receiver or facade child did not resolve in the live world.") \
	or not _require(str(receiver.get_meta("derived_object_key", "")) == TARGET_WALL_KEY and receiver.get_meta("source_keys", []) == [TARGET_SOURCE_KEY], "Live capture receiver identity drifted."):
		_finish(main)
		return

	var output_absolute := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute) == OK, "Could not create Hawkins evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.set_gameplay_enabled(false)
	hud.set_paused(false)
	var captures: Array[Dictionary] = []

	var address_side := {
		"start": Vector3(-79.648, 0.0, 526.358),
		"end": Vector3(-41.556, 0.0, 480.728),
		"normal": Vector3(0.768, 0.0, 0.641).normalized(),
	}
	var broad_side := {
		"start": Vector3(-118.795, 0.0, 451.595),
		"end": Vector3(-79.648, 0.0, 526.358),
		"normal": Vector3(-0.886, 0.0, 0.464).normalized(),
	}
	var close_pose := await _pose_on_side(world, player, address_side, 15.5, 5.0, 6.15)
	if not _require(bool(close_pose.get("ok", false)), str(close_pose.get("message", "Address close pose failed."))):
		_finish(main)
		return
	var saved := await _save_view("01-address-close", "close_address_side", "Close exact-receiver view of the complete lobby/door/sign language under the default project sun", main, player, close_pose.metadata)
	if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Address close capture failed."))):
		_finish(main)
		return
	captures.append(saved.metadata)

	var spray_hit := _camera_spray_hit(player)
	if not _require(not spray_hit.is_empty(), "Close Hawkins camera did not ray-hit the spray receiver."):
		_finish(main)
		return
	var spray_collider := spray_hit.get("collider") as CollisionObject3D
	var placed_before := int(evidence.spray_counts.placed)
	player.get_spray_controller().attempt_spray()
	await process_frame
	if not _require(spray_collider != null \
	and str(spray_collider.get_meta("derived_object_key", "")) == TARGET_WALL_KEY \
	and spray_collider.get_meta("source_keys", []) == [TARGET_SOURCE_KEY] \
	and int(evidence.spray_counts.placed) == placed_before + 1, "Real Hawkins spray did not retain underlying receiver identity and place one tag."):
		_finish(main)
		return
	await _wait_for_render(main, player)
	var sprayed_metadata: Dictionary = close_pose.metadata.duplicate(true)
	sprayed_metadata.merge({
		"spray_result": "placed",
		"spray_hit_object": TARGET_WALL_KEY,
		"spray_hit_sources": [TARGET_SOURCE_KEY],
		"spray_visual_layer": 2,
	}, true)
	saved = await _save_view("02-address-close-sprayed", "close_address_side_spray", "Close exact-receiver view after one real-controller spray projected across the render-only facade", main, player, sprayed_metadata)
	if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Sprayed close capture failed."))):
		_finish(main)
		return
	captures.append(saved.metadata)

	var broad_pose := await _pose_on_side(world, player, broad_side, 35.0, 40.0, 14.774)
	if not _require(bool(broad_pose.get("ok", false)), str(broad_pose.get("message", "Broad gameplay pose failed."))):
		_finish(main)
		return
	saved = await _save_view("03-wsw-ordinary-stepped", "ordinary_gameplay_camera", "Ordinary third-person 40 m view of the six-story WSW main block and lower companion cadence", main, player, broad_pose.metadata)
	if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Broad gameplay capture failed."))):
		_finish(main)
		return
	captures.append(saved.metadata)

	var corner := Vector3(-79.648, 0.0, 526.358)
	var corner_outward := (Vector3(-0.886, 0.0, 0.464).normalized() + Vector3(0.768, 0.0, 0.641).normalized()).normalized()
	var corner_pose := await _pose_at(world, player, corner + corner_outward * 40.0, Vector3(corner.x, 14.774, corner.z), "corner_b_oblique")
	if not _require(bool(corner_pose.get("ok", false)), str(corner_pose.get("message", "Corner oblique pose failed."))):
		_finish(main)
		return
	saved = await _save_view("04-corner-b-oblique", "oblique_gameplay_camera", "40 m third-person oblique view across the stepped WSW/SE corner B", main, player, corner_pose.metadata)
	if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Corner oblique capture failed."))):
		_finish(main)
		return
	captures.append(saved.metadata)

	var step_pose := await _pose_on_companion_roof(world, player)
	if not _require(bool(step_pose.get("ok", false)), str(step_pose.get("message", "Companion-roof step pose failed."))):
		_finish(main)
		return
	var upper_hit := _camera_spray_hit(player)
	if not _require(not upper_hit.is_empty(), "Companion-roof camera did not ray-hit the exposed upper step wall."):
		_finish(main)
		return
	var upper_collider := upper_hit.get("collider") as CollisionObject3D
	placed_before = int(evidence.spray_counts.placed)
	player.get_spray_controller().attempt_spray()
	await process_frame
	if not _require(upper_collider != null \
	and str(upper_collider.get_meta("derived_object_key", "")) == TARGET_WALL_KEY \
	and upper_collider.get_meta("source_keys", []) == [TARGET_SOURCE_KEY] \
	and int(evidence.spray_counts.placed) == placed_before + 1, "Real upper-step spray did not retain Hawkins wall identity and place one tag."):
		_finish(main)
		return
	await _wait_for_render(main, player)
	var step_metadata: Dictionary = step_pose.metadata.duplicate(true)
	step_metadata.merge({
		"access_mode": "deterministic_companion_roof_pose_after_jetpack_contract",
		"spray_result": "placed",
		"spray_surface_role": "exposed_step_wall_above_companion_roof",
		"spray_hit_object": TARGET_WALL_KEY,
		"spray_hit_sources": [TARGET_SOURCE_KEY],
	}, true)
	saved = await _save_view("05-companion-roof-upper-step-sprayed", "jetpack_oblique_upper_spray", "Stable companion-roof view of the exposed step wall after a real within-range spray placement", main, player, step_metadata)
	if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Companion-roof sprayed capture failed."))):
		_finish(main)
		return
	captures.append(saved.metadata)

	var original_sun_rotation := sun.rotation_degrees
	sun.rotation_degrees = Vector3(-38.0, 125.0, 0.0)
	var changed_pose := await _pose_at(world, player, corner + corner_outward * 40.0, Vector3(corner.x, 14.774, corner.z), "corner_b_oblique_changed_light")
	if not _require(bool(changed_pose.get("ok", false)), str(changed_pose.get("message", "Changed-light pose failed."))):
		_finish(main)
		return
	var changed_metadata: Dictionary = changed_pose.metadata.duplicate(true)
	changed_metadata["sun_rotation_degrees"] = [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z]
	saved = await _save_view("06-corner-b-changed-light", "changed_light_exact_pose", "Exact corner-B oblique pose under sun rotation (-38,125,0) to expose the stepped mass and material response", main, player, changed_metadata)
	if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Changed-light capture failed."))):
		_finish(main)
		return
	captures.append(saved.metadata)
	sun.rotation_degrees = original_sun_rotation

	var manifest := {
		"schema_version": "ti.hawkins-massing-evidence/1",
		"generator": "game/tests/hawkins_facade_capture.gd",
		"evidence_role": "owner_approved_hawkins_runtime_massing_change",
		"prior_evidence_directory": PRIOR_EVIDENCE_DIRECTORY,
		"pose_policy": "six deterministic Forward+/Metal views: address close/default and lower spray, WSW ordinary, corner-B oblique, companion-roof upper-step spray, exact corner-B changed light",
		"approved_before_after": "one flat 6 m Hawkins extrusion -> Hawkins-only stepped six-story main plus lower four-story companion with matching collision and spray surfaces",
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"content_sha256": EXPECTED_CONTENT_SHA256,
		"manifest_sha256": EXPECTED_MANIFEST_SHA256,
		"target_receiver": TARGET_WALL_KEY,
		"target_source_keys": [TARGET_SOURCE_KEY],
		"facade_layout": str(facade.get_meta("layout_path", "")),
		"facade_layout_sha256": str(facade.get_meta("layout_sha256", "")),
		"facade_signature": str(facade.get_meta("deterministic_signature", "")),
		"source_height_m": float(facade.get_meta("source_height_m", 0.0)),
		"base_y_m": float(facade.get_meta("base_y_m", 0.0)),
		"main_top_y_m": float(facade.get_meta("main_top_y_m", 0.0)),
		"companion_top_y_m": float(facade.get_meta("companion_top_y_m", 0.0)),
		"massing_signature": str(receiver.get_meta("massing_signature", "")),
		"runtime_wall_triangles": 46,
		"runtime_roof_triangles": 4,
		"maximum_relief_m": float(facade.get_meta("maximum_relief_m", 0.0)),
		"module_counts": facade.get_meta("module_counts", {}),
		"generated_world_counts": {
			"chunks": evidence.chunks_loaded,
			"meshes": evidence.mesh_instances,
			"triangles": evidence.triangles,
			"static_bodies": evidence.static_bodies,
			"shapes": evidence.shapes,
		},
		"default_sun_rotation_degrees": [original_sun_rotation.x, original_sun_rotation.y, original_sun_rotation.z],
		"camera_fov_degrees": player.get_camera().fov,
		"captures": captures,
	}
	var manifest_path := OUTPUT_DIRECTORY.path_join("capture-manifest.json")
	var file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if not _require(file != null, "Could not write Hawkins capture manifest."):
		_finish(main)
		return
	file.store_string(JSON.stringify(manifest, "  ", false) + "\n")
	file.close()
	print("PASS: captured %d exact Hawkins stepped-massing views with real lower and upper-step spray to %s" % [captures.size(), ProjectSettings.globalize_path(OUTPUT_DIRECTORY)])
	_finish(main)


func _pose_on_companion_roof(world: WorldLoader, player: PlayerController) -> Dictionary:
	var p := Hawkins77BrutonMassing.split_p()
	var q := Hawkins77BrutonMassing.split_q()
	var normal := Vector3(0.1253620420, 0.0, 0.9921110615).normalized()
	var step_midpoint := Vector3((p.x + q.x) * 0.5, 21.0, (p.y + q.y) * 0.5)
	var approach := Vector3(step_midpoint.x, 18.274, step_midpoint.z) + normal * 2.6
	var support_query := PhysicsRayQueryParameters3D.create(approach + Vector3.UP * 3.0, approach - Vector3.UP * 2.0, WORLD_SOLID_MASK)
	support_query.collide_with_areas = false
	support_query.collide_with_bodies = true
	var support := player.get_world_3d().direct_space_state.intersect_ray(support_query)
	var support_collider := support.get("collider", null) as CollisionObject3D
	if support.is_empty() or support_collider == null \
	or str(support_collider.get_meta("derived_object_key", "")) != TARGET_ROOF_KEY \
	or str(support_collider.get_meta("receiver_kind", "")) != "none":
		return {"ok": false, "message": "Companion-roof capture approach did not resolve the exact non-spray Hawkins roof collider."}
	player.set_gameplay_enabled(false)
	player.global_transform = Transform3D(Basis.IDENTITY, Vector3(approach.x, float(support.position.y), approach.z))
	player.velocity = Vector3.ZERO
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3.ZERO
	player.force_update_transform()
	rig.look_at(step_midpoint, Vector3.UP)
	rig.force_update_transform()
	arm.force_update_transform()
	if not await _wait_for_render(player.get_parent() as GameMain, player):
		return {"ok": false, "message": "Companion-roof pose did not reach a stable rendered frame."}
	return {
		"ok": true,
		"metadata": {
			"pose_id": "companion_roof_step",
			"player_origin": [player.global_position.x, player.global_position.y, player.global_position.z],
			"target": [step_midpoint.x, step_midpoint.y, step_midpoint.z],
			"support_object": TARGET_ROOF_KEY,
			"support_receiver_kind": "none",
			"support_top_y_m": float(support.position.y),
		},
	}


func _pose_on_side(world: WorldLoader, player: PlayerController, side: Dictionary, u: float, outward_distance: float, target_y: float) -> Dictionary:
	var start := side.start as Vector3
	var end := side.end as Vector3
	var tangent := (end - start).normalized()
	var side_length := (end - start).length()
	var distances: Array[float] = [outward_distance, 12.0, 8.0, 5.0]
	var u_offsets: Array[float] = [0.0, -15.0, 15.0, -25.0, 25.0]
	for u_offset in u_offsets:
		var candidate_u := clampf(u + u_offset, 2.0, side_length - 2.0)
		var target := start + tangent * candidate_u
		target.y = target_y
		for distance in distances:
			var approach := Vector3(target.x, 0.0, target.z) + (side.normal as Vector3) * distance
			var preview := _ground_hit(player, Vector2(approach.x, approach.z))
			var collider := preview.get("collider") as Node if not preview.is_empty() else null
			var record := collider.get_parent() if collider != null else null
			var feature := "" if record == null else str(record.get_meta("feature_kind", ""))
			var preview_normal: Vector3 = preview.get("normal", Vector3.ZERO)
			if feature not in ["land_ground", "road_path"] or preview_normal.dot(Vector3.UP) < 0.7:
				continue
			var result := await _pose_at(world, player, approach, target, str(side.get("side_id", "side")))
			if bool(result.get("ok", false)):
				(result.metadata as Dictionary)["side_u_m"] = candidate_u
				(result.metadata as Dictionary)["outward_distance_m"] = distance
				return result
	return {"ok": false, "message": "%s has no deterministic nearby walkable-ground camera approach." % str(side.get("side_id", "side"))}


func _pose_at(world: WorldLoader, player: PlayerController, approach: Vector3, target: Vector3, pose_id: String) -> Dictionary:
	var ground_hit := _ground_hit(player, Vector2(approach.x, approach.z))
	if ground_hit.is_empty():
		return {"ok": false, "message": "%s approach has no generated ground support." % pose_id}
	var ground_collider := ground_hit.get("collider") as Node
	var ground_record := ground_collider.get_parent() if ground_collider != null else null
	var ground_feature := "" if ground_record == null else str(ground_record.get_meta("feature_kind", ""))
	var ground_normal: Vector3 = ground_hit.get("normal", Vector3.ZERO)
	if ground_record == null or ground_feature not in ["land_ground", "road_path"] or ground_normal.dot(Vector3.UP) < 0.7:
		return {"ok": false, "message": "%s approach hit %s instead of a generated walkable ground surface." % [pose_id, ground_feature]}
	var ground_y := float(ground_hit.position.y)
	player.set_gameplay_enabled(false)
	player.global_transform = Transform3D(Basis.IDENTITY, Vector3(approach.x, ground_y, approach.z))
	player.velocity = Vector3.ZERO
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3.ZERO
	player.force_update_transform()
	rig.look_at(target, Vector3.UP)
	rig.force_update_transform()
	arm.force_update_transform()
	if not await _wait_for_render(player.get_parent() as GameMain, player):
		return {"ok": false, "message": "%s could not reach a stable rendered frame." % pose_id}
	var camera := player.get_camera()
	return {
		"ok": true,
		"metadata": {
			"physics_grounded_pose": true,
			"ground_y_m": ground_y,
			"ground_object": str(ground_record.get_meta("derived_object_key", "")),
			"ground_sources": ground_record.get_meta("source_keys", []),
			"in_boundary": world.get_boundary().contains_position(player.global_position),
			"aim_target": [target.x, target.y, target.z],
			"player_position": [player.global_position.x, player.global_position.y, player.global_position.z],
			"camera_position": [camera.global_position.x, camera.global_position.y, camera.global_position.z],
			"camera_forward": [-camera.global_basis.z.x, -camera.global_basis.z.y, -camera.global_basis.z.z],
			"camera_fov_degrees": camera.fov,
			"spring_length_m": arm.spring_length,
		},
	}


func _wait_for_render(main: GameMain, player: PlayerController) -> bool:
	_force_unpaused(main, player)
	await physics_frame
	_force_unpaused(main, player)
	await process_frame
	_force_unpaused(main, player)
	await RenderingServer.frame_post_draw
	_force_unpaused(main, player)
	await process_frame
	_force_unpaused(main, player)
	await RenderingServer.frame_post_draw
	return _force_unpaused(main, player)


func _force_unpaused(main: GameMain, player: PlayerController) -> bool:
	paused = false
	(main.get_node("Interface/HUD") as GameHUD).set_paused(false)
	player.set_gameplay_enabled(false)
	return not paused and not ((main.get_node("Interface/HUD/PausePanel") as Control).visible)


func _save_view(id: String, region: String, intent: String, main: GameMain, player: PlayerController, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player):
		return {"ok": false, "message": "%s could not hide the pause overlay." % id}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s produced an empty or wrong-sized viewport image." % id}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s appears blank." % id}
	var filename := "%s.png" % id
	var path := OUTPUT_DIRECTORY.path_join(filename)
	var error := image.save_png(path)
	if error != OK:
		return {"ok": false, "message": "%s could not save PNG (%d)." % [id, error]}
	var camera := player.get_camera()
	var metadata := {
		"id": id,
		"region": region,
		"intent": intent,
		"file": filename,
		"sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"player_position": [player.global_position.x, player.global_position.y, player.global_position.z],
		"camera_position": [camera.global_position.x, camera.global_position.y, camera.global_position.z],
		"camera_forward": [-camera.global_basis.z.x, -camera.global_basis.z.y, -camera.global_basis.z.z],
		"sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range),
		"pause_overlay_visible": false,
	}
	metadata.merge(extra, true)
	print("HAWKINS_CAPTURE: id=%s image=%s sha256=%s" % [id, ProjectSettings.globalize_path(path), metadata.sha256])
	return {"ok": true, "metadata": metadata}


func _ground_hit(player: PlayerController, xz: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(Vector3(xz.x, 200.0, xz.y), Vector3(xz.x, -20.0, xz.y), WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _camera_spray_hit(player: PlayerController) -> Dictionary:
	var camera := player.get_camera()
	var viewport_center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(viewport_center)
	var direction := camera.project_ray_normal(viewport_center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0, SPRAY_SURFACE_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _sample_image(image: Image) -> Dictionary:
	var colors := {}
	var minimum_luminance := 1.0
	var maximum_luminance := 0.0
	for sample_y in 20:
		var y := mini(image.get_height() - 1, int((float(sample_y) + 0.5) * image.get_height() / 20.0))
		for sample_x in 32:
			var x := mini(image.get_width() - 1, int((float(sample_x) + 0.5) * image.get_width() / 32.0))
			var color := image.get_pixel(x, y)
			colors[color.to_rgba32()] = true
			minimum_luminance = minf(minimum_luminance, color.get_luminance())
			maximum_luminance = maxf(maximum_luminance, color.get_luminance())
	return {"unique_colors": colors.size(), "luminance_range": maximum_luminance - minimum_luminance}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error("HAWKINS_CAPTURE_FAIL: %s" % message)


func _on_timeout() -> void:
	if not _finished:
		_fail("Capture timed out after %.0f seconds." % TIMEOUT_SECONDS)
		_finished = true
		quit(1)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	paused = false
	if main != null and is_instance_valid(main):
		main.queue_free()
		await process_frame
	quit(0 if _failure.is_empty() else 1)
