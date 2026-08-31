extends SceneTree

const BUILDING_3_OUTPUT := "res://evidence/first-playable/building-3-facade-pilot-2026-08-29"
const ISLE_HOUSE_OUTPUT := "res://evidence/first-playable/isle-house-high-facade-pilot-2026-08-29"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const CAPTURE_SIZE := Vector2i(1440, 900)
const WORLD_SOLID_MASK := 1
const SPRAY_SURFACE_MASK := 1 << 2
const TIMEOUT_SECONDS := 240.0

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Next-cohort evidence capture requires the real macOS rendering display.")
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for next-cohort capture."):
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
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - wait_started < 40000:
		await process_frame
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Full world did not reach one clean world_ready for capture."):
		_finish(main)
		return
	var report := ready_reports[0]
	if not _require(str(report.get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted before capture.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated manifest hash drifted before capture."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.set_gameplay_enabled(false)
	hud.set_paused(false)

	var building_3 := {
		"schema_version": "ti.building-3-facade-evidence/1",
		"target_id": "building_3_600_california",
		"output": BUILDING_3_OUTPUT,
		"receiver_key": "building:w34313540:wall",
		"source_key": "w34313540",
		"facade_child": "Building3600CaliforniaFacade",
		"run_scope": [27, 28, 29, 30, 31, 32, 33, 34, 35],
		"side": {
			"side_id": "observed_ene_main",
			"start": Vector3(528.784, 0.0, 488.910),
			"end": Vector3(486.955, 0.0, 408.860),
			"normal": Vector3(0.886, 0.0, -0.463).normalized(),
		},
		"close_u": 45.160,
		"close_distance": 24.0,
		"close_target_y": 9.728,
		"spray_distance": 5.0,
		"spray_target_y": 4.8,
		"ordinary_u": 45.160,
		"ordinary_distance": 72.0,
		"ordinary_target_y": 12.0,
		"oblique_u": 66.0,
		"oblique_distance": 42.0,
		"oblique_along": 22.0,
		"oblique_target_y": 12.0,
		"changed_u": 45.160,
		"changed_distance": 36.0,
		"changed_target_y": 11.0,
		"changed_sun": Vector3(-34.0, 78.0, 0.0),
		"known_limitation": "Current flat 20 m extrusion cannot reproduce the observed curved crown or taller shoulder/pylon silhouette; those prohibited massing elements remain unchanged.",
	}
	var isle_house := {
		"schema_version": "ti.isle-house-high-facade-evidence/1",
		"target_id": "isle_house_39_bruton_high",
		"output": ISLE_HOUSE_OUTPUT,
		"receiver_key": "building-composite:w1249412094:w1282547786:wall",
		"source_key": "w1282547786",
		"facade_child": "IsleHouse39BrutonHighFacade",
		"run_scope": [5, 6, 7],
		"material_only_run_scope": [8, 9],
		"side": {
			"side_id": "observed_high_se",
			"start": Vector3(-117.142, 0.0, 571.175),
			"end": Vector3(-89.198, 0.0, 539.449),
			"normal": Vector3(0.750, 0.0, 0.661).normalized(),
		},
		"close_u": 14.3,
		"close_distance": 5.0,
		"close_target_y": 6.4,
		"spray_distance": 5.0,
		"spray_target_y": 6.4,
		"ordinary_u": 21.1,
		"ordinary_distance": 84.0,
		"ordinary_target_y": 34.0,
		"oblique_u": 38.0,
		"oblique_distance": 58.0,
		"oblique_along": 18.0,
		"oblique_target_y": 32.0,
		"changed_u": 21.1,
		"changed_distance": 46.0,
		"changed_target_y": 30.0,
		"changed_sun": Vector3(-40.0, 145.0, 0.0),
		"known_limitation": "The exact generated five-level low part differs from the locally recorded seven-level podium; all low/shared-above-low geometry and unobserved schedules remain intentionally unchanged.",
	}
	for target_value: Variant in [building_3, isle_house]:
		var result := await _capture_target(target_value as Dictionary, main, world, player, sun, report)
		if not _require(bool(result.get("ok", false)), str(result.get("message", "Target capture failed."))):
			_finish(main)
			return
	print("PASS: captured ten comparable Forward+/Metal facade views across Building 3 and Isle House high")
	_finish(main)


func _capture_target(target: Dictionary, main: GameMain, world: WorldLoader, player: PlayerController, sun: DirectionalLight3D, report: Dictionary) -> Dictionary:
	var output := str(target.output)
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		return {"ok": false, "message": "Could not create evidence directory for %s." % str(target.target_id)}
	var receiver := _record_node_for_key(world, str(target.receiver_key))
	var facade := receiver.get_node_or_null(str(target.facade_child)) as Node3D if receiver != null else null
	if receiver == null or facade == null \
	or str(receiver.get_meta("derived_object_key", "")) != str(target.receiver_key) \
	or receiver.get_meta("source_keys", []) != [str(target.source_key)]:
		return {"ok": false, "message": "Live exact receiver/facade identity did not resolve for %s." % str(target.target_id)}
	var captures: Array[Dictionary] = []
	var side := target.side as Dictionary
	var close_pose := await _pose_on_side(world, player, side, float(target.close_u), float(target.close_distance), float(target.close_target_y))
	if not bool(close_pose.get("ok", false)):
		return close_pose
	var saved := await _save_view(output, "01-close", "close_exact_receiver", "Close exact-receiver view of complete target-specific facade modules under the default sun", main, player, close_pose.metadata)
	if not bool(saved.get("ok", false)):
		return saved
	captures.append(saved.metadata)

	var spray_pose := await _pose_on_side(world, player, side, float(target.close_u), float(target.spray_distance), float(target.spray_target_y))
	if not bool(spray_pose.get("ok", false)):
		return spray_pose
	var spray_hit := _camera_spray_hit(player)
	var spray_collider := spray_hit.get("collider") as CollisionObject3D if not spray_hit.is_empty() else null
	var evidence_before := world.get_runtime_evidence()
	var placed_before := int((evidence_before.spray_counts as Dictionary).placed)
	player.get_spray_controller().attempt_spray()
	await process_frame
	var evidence_after := world.get_runtime_evidence()
	if spray_collider == null \
	or str(spray_collider.get_meta("derived_object_key", "")) != str(target.receiver_key) \
	or spray_collider.get_meta("source_keys", []) != [str(target.source_key)] \
	or int((evidence_after.spray_counts as Dictionary).placed) != placed_before + 1:
		return {"ok": false, "message": "Real spray failed for %s: collider=%s sources=%s placed=%d->%d." % [str(target.target_id), "null" if spray_collider == null else str(spray_collider.get_meta("derived_object_key", "")), [] if spray_collider == null else spray_collider.get_meta("source_keys", []), placed_before, int((evidence_after.spray_counts as Dictionary).placed)]}
	var sprayed_metadata: Dictionary = spray_pose.metadata.duplicate(true)
	sprayed_metadata.merge({"spray_result": "placed", "spray_hit_object": str(target.receiver_key), "spray_hit_sources": [str(target.source_key)], "spray_visual_layer": 2}, true)
	saved = await _save_view(output, "02-close-sprayed", "close_exact_receiver_spray", "Close exact-receiver view after one real-controller spray projected across render-only visuals", main, player, sprayed_metadata)
	if not bool(saved.get("ok", false)):
		return saved
	captures.append(saved.metadata)

	var ordinary_pose := await _pose_on_side(world, player, side, float(target.ordinary_u), float(target.ordinary_distance), float(target.ordinary_target_y))
	if not bool(ordinary_pose.get("ok", false)):
		return ordinary_pose
	saved = await _save_view(output, "03-ordinary-gameplay-camera", "ordinary_third_person", "Ordinary third-person route-distance view of the target facade language", main, player, ordinary_pose.metadata)
	if not bool(saved.get("ok", false)):
		return saved
	captures.append(saved.metadata)

	var oblique_pose := await _pose_oblique(world, player, side, float(target.oblique_u), float(target.oblique_distance), float(target.oblique_along), float(target.oblique_target_y))
	if not bool(oblique_pose.get("ok", false)):
		return oblique_pose
	saved = await _save_view(output, "04-oblique-gameplay-camera", "oblique_third_person", "Ordinary third-person oblique view exposing side-local endpoints and material response", main, player, oblique_pose.metadata)
	if not bool(saved.get("ok", false)):
		return saved
	captures.append(saved.metadata)

	var original_sun := sun.rotation_degrees
	sun.rotation_degrees = target.changed_sun as Vector3
	var changed_pose := await _pose_on_side(world, player, side, float(target.changed_u), float(target.changed_distance), float(target.changed_target_y))
	if not bool(changed_pose.get("ok", false)):
		sun.rotation_degrees = original_sun
		return changed_pose
	var changed_metadata: Dictionary = changed_pose.metadata.duplicate(true)
	changed_metadata["sun_rotation_degrees"] = [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z]
	saved = await _save_view(output, "05-changed-light", "changed_light_exact_receiver", "Exact receiver under a changed sun direction to expose scalar PBR and shallow relief response", main, player, changed_metadata)
	sun.rotation_degrees = original_sun
	if not bool(saved.get("ok", false)):
		return saved
	captures.append(saved.metadata)

	var evidence := world.get_runtime_evidence()
	var manifest := {
		"schema_version": str(target.schema_version),
		"generator": "game/tests/next_cohort_facade_capture.gd",
		"evidence_role": "bounded_facade_pilot_ready_for_independent_review",
		"review_status": "ready_for_independent_review_not_self_accepted",
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"content_sha256": EXPECTED_CONTENT_SHA256,
		"manifest_sha256": EXPECTED_MANIFEST_SHA256,
		"target_receiver": str(target.receiver_key),
		"target_source_keys": [str(target.source_key)],
		"facade_layout": str(facade.get_meta("layout_path", "")),
		"facade_layout_sha256": str(facade.get_meta("layout_sha256", "")),
		"facade_signature": str(facade.get_meta("deterministic_signature", "")),
		"maximum_relief_m": float(facade.get_meta("maximum_relief_m", 0.0)),
		"module_counts": facade.get_meta("module_counts", {}),
		"module_run_scope": target.run_scope,
		"material_only_run_scope": target.get("material_only_run_scope", []),
		"known_limitation": str(target.known_limitation),
		"generated_world_counts": {"chunks": evidence.chunks_loaded, "meshes": evidence.mesh_instances, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"default_sun_rotation_degrees": [original_sun.x, original_sun.y, original_sun.z],
		"camera_fov_degrees": player.get_camera().fov,
		"captures": captures,
	}
	var manifest_path := output.path_join("capture-manifest.json")
	var file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Could not write capture manifest for %s." % str(target.target_id)}
	file.store_string(JSON.stringify(manifest, "  ", false) + "\n")
	file.close()
	print("COHORT_CAPTURE: target=%s views=%d manifest=%s" % [str(target.target_id), captures.size(), ProjectSettings.globalize_path(manifest_path)])
	return {"ok": true}


func _record_node_for_key(world: WorldLoader, key: String) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == key:
			return value as Node3D
	return null


func _pose_on_side(world: WorldLoader, player: PlayerController, side: Dictionary, u: float, outward_distance: float, target_y: float) -> Dictionary:
	var start := side.start as Vector3
	var end := side.end as Vector3
	var tangent := (end - start).normalized()
	var side_length := (end - start).length()
	var distances: Array[float] = [outward_distance, outward_distance * 0.75, 24.0, 16.0, 10.0]
	var u_offsets: Array[float] = [0.0, -10.0, 10.0, -20.0, 20.0]
	for u_offset in u_offsets:
		var candidate_u := clampf(u + u_offset, 2.0, side_length - 2.0)
		var target := start + tangent * candidate_u
		target.y = target_y
		for distance in distances:
			var approach := Vector3(target.x, 0.0, target.z) + (side.normal as Vector3) * distance
			var result := await _pose_at(world, player, approach, target, "%s_u%.1f_d%.1f" % [str(side.side_id), candidate_u, distance])
			if bool(result.get("ok", false)):
				(result.metadata as Dictionary)["side_u_m"] = candidate_u
				(result.metadata as Dictionary)["outward_distance_m"] = distance
				return result
	return {"ok": false, "message": "%s has no deterministic nearby walkable-ground camera approach." % str(side.side_id)}


func _pose_oblique(world: WorldLoader, player: PlayerController, side: Dictionary, u: float, outward_distance: float, along_distance: float, target_y: float) -> Dictionary:
	var start := side.start as Vector3
	var end := side.end as Vector3
	var tangent := (end - start).normalized()
	var target := start + tangent * u
	target.y = target_y
	for along in [along_distance, -along_distance, along_distance * 0.5, -along_distance * 0.5, 0.0]:
		for distance in [outward_distance, outward_distance * 0.75, 32.0, 20.0]:
			var approach := Vector3(target.x, 0.0, target.z) + (side.normal as Vector3) * float(distance) + tangent * float(along)
			var result := await _pose_at(world, player, approach, target, "%s_oblique" % str(side.side_id))
			if bool(result.get("ok", false)):
				(result.metadata as Dictionary)["side_u_m"] = u
				(result.metadata as Dictionary)["outward_distance_m"] = distance
				(result.metadata as Dictionary)["along_side_offset_m"] = along
				return result
	return {"ok": false, "message": "%s has no deterministic oblique walkable-ground camera approach." % str(side.side_id)}


func _pose_at(world: WorldLoader, player: PlayerController, approach: Vector3, target: Vector3, pose_id: String) -> Dictionary:
	var ground_hit := _ground_hit(player, Vector2(approach.x, approach.z))
	if ground_hit.is_empty():
		return {"ok": false}
	var collider := ground_hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	var feature := "" if record == null else str(record.get_meta("feature_kind", ""))
	var normal: Vector3 = ground_hit.get("normal", Vector3.ZERO)
	if record == null or feature not in ["land_ground", "road_path"] or normal.dot(Vector3.UP) < 0.7:
		return {"ok": false}
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
		return {"ok": false}
	var camera := player.get_camera()
	return {"ok": true, "metadata": {"pose_id": pose_id, "physics_grounded_pose": true, "ground_y_m": ground_y, "ground_object": str(record.get_meta("derived_object_key", "")), "ground_sources": record.get_meta("source_keys", []), "in_boundary": world.get_boundary().contains_position(player.global_position), "aim_target": [target.x, target.y, target.z], "player_position": [player.global_position.x, player.global_position.y, player.global_position.z], "camera_position": [camera.global_position.x, camera.global_position.y, camera.global_position.z], "camera_forward": [-camera.global_basis.z.x, -camera.global_basis.z.y, -camera.global_basis.z.z], "camera_fov_degrees": camera.fov, "spring_length_m": arm.spring_length}}


func _wait_for_render(main: GameMain, player: PlayerController) -> bool:
	_force_unpaused(main, player)
	await physics_frame
	_force_unpaused(main, player)
	await process_frame
	await RenderingServer.frame_post_draw
	_force_unpaused(main, player)
	await process_frame
	await RenderingServer.frame_post_draw
	return _force_unpaused(main, player)


func _force_unpaused(main: GameMain, player: PlayerController) -> bool:
	paused = false
	(main.get_node("Interface/HUD") as GameHUD).set_paused(false)
	player.set_gameplay_enabled(false)
	return not paused and not ((main.get_node("Interface/HUD/PausePanel") as Control).visible)


func _save_view(output: String, id: String, region: String, intent: String, main: GameMain, player: PlayerController, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player):
		return {"ok": false, "message": "%s could not stabilize." % id}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s produced an empty or wrong-sized image." % id}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s appears blank." % id}
	var filename := "%s.png" % id
	var path := output.path_join(filename)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % id}
	var camera := player.get_camera()
	var metadata := {"id": id, "region": region, "intent": intent, "file": filename, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y], "player_position": [player.global_position.x, player.global_position.y, player.global_position.z], "camera_position": [camera.global_position.x, camera.global_position.y, camera.global_position.z], "camera_forward": [-camera.global_basis.z.x, -camera.global_basis.z.y, -camera.global_basis.z.z], "sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range), "pause_overlay_visible": false}
	metadata.merge(extra, true)
	print("COHORT_CAPTURE_VIEW: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), metadata.sha256])
	return {"ok": true, "metadata": metadata}


func _ground_hit(player: PlayerController, xz: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(Vector3(xz.x, 200.0, xz.y), Vector3(xz.x, -20.0, xz.y), WORLD_SOLID_MASK, [player.get_rid()])
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _camera_spray_hit(player: PlayerController) -> Dictionary:
	var camera := player.get_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(center)
	var direction := camera.project_ray_normal(center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0, SPRAY_SURFACE_MASK, [player.get_rid()])
	return player.get_world_3d().direct_space_state.intersect_ray(query)


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


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error("COHORT_CAPTURE_FAIL: %s" % message)


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
