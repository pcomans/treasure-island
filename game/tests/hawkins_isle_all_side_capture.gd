extends SceneTree

const OUTPUT := "res://evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_HAWKINS_SIGNATURE := "d311c103c9273b94fc982588f46bae6ab67ba6be54b0d0a111dd305e39c22219"
const EXPECTED_ISLE_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const CAPTURE_SIZE := Vector2i(1440, 900)
const WORLD_SOLID_MASK := 1
const TIMEOUT_SECONDS := 240.0

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("All-side evidence capture requires the real macOS rendering display.")
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for all-side capture."):
		_finish(null)
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var hud := main.get_node("Interface/HUD") as GameHUD
	var ready_reports: Array[Dictionary] = []
	var load_failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready_reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: load_failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var wait_started := Time.get_ticks_msec()
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - wait_started < 40000:
		await process_frame
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Full world did not reach one clean world_ready for all-side capture."):
		_finish(main)
		return
	var report := ready_reports[0]
	if not _require(str(report.get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted before capture.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated manifest hash drifted before capture."):
		_finish(main)
		return
	var hawkins_receiver := _record_node_for_key(world, "building:w1249412093:wall")
	var isle_receiver := _record_node_for_key(world, "building-composite:w1249412094:w1282547786:wall")
	var low_receiver := _record_node_for_key(world, "building-composite:w1249412094:w1282547787:wall")
	var hawkins_facade := hawkins_receiver.get_node_or_null("Hawkins77BrutonFacade") as Hawkins77BrutonFacade if hawkins_receiver != null else null
	var isle_facade := isle_receiver.get_node_or_null("IsleHouse39BrutonHighFacade") as IsleHouse39BrutonHighFacade if isle_receiver != null else null
	if not _require(hawkins_facade != null and str(hawkins_facade.get_meta("deterministic_signature", "")) == EXPECTED_HAWKINS_SIGNATURE, "Accepted Hawkins facade/signature did not resolve.") \
	or not _require(isle_facade != null and str(isle_facade.get_meta("deterministic_signature", "")) == EXPECTED_ISLE_SIGNATURE, "All-side Isle high facade/signature did not resolve.") \
	or not _require(low_receiver != null and low_receiver.get_node_or_null("IsleHouse39BrutonHighFacade") == null, "Isle low receiver was missing or gained a facade."):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images/hawkins")) == OK, "Could not create Hawkins evidence image directory.") \
	or not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images/isle-house")) == OK, "Could not create Isle House evidence image directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.set_gameplay_enabled(false)
	hud.set_paused(false)

	var views: Array[Dictionary] = [
		_view("hawkins", "01-front-close", "accepted_front", "close", [7, 8, 9], Vector3(-79.648, 0.0, 526.358), Vector3(-41.556, 0.0, 480.728), Vector3(0.768, 0.0, 0.641), 15.5, 5.0, 6.15),
		_view("hawkins", "02-front-ordinary", "accepted_front", "ordinary", [0, 1, 2, 3, 4, 5, 6], Vector3(-118.795, 0.0, 451.595), Vector3(-79.648, 0.0, 526.358), Vector3(-0.886, 0.0, 0.464), 40.0, 40.0, 14.774),
		_view("hawkins", "03-ene-covered-close", "conservative_all_side_field", "close", [10, 11, 12, 13, 14, 15], Vector3(-41.556, 0.0, 480.728), Vector3(-69.387, 0.0, 427.417), Vector3(0.886, 0.0, -0.463), 28.0, 12.0, 13.0),
		_view("hawkins", "04-ene-covered-ordinary", "conservative_all_side_field", "ordinary", [10, 11, 12, 13, 14, 15], Vector3(-41.556, 0.0, 480.728), Vector3(-69.387, 0.0, 427.417), Vector3(0.886, 0.0, -0.463), 28.0, 52.0, 15.0),
		_view("hawkins", "05-nnw-module-free-close", "unobserved_module_free", "close", [16, 17, 18, 19], Vector3(-69.387, 0.0, 427.417), Vector3(-118.795, 0.0, 451.595), Vector3(-0.440, 0.0, -0.898), 28.0, 12.0, 13.0),
		_view("hawkins", "06-nnw-module-free-ordinary", "unobserved_module_free", "ordinary", [16, 17, 18, 19], Vector3(-69.387, 0.0, 427.417), Vector3(-118.795, 0.0, 451.595), Vector3(-0.440, 0.0, -0.898), 28.0, 48.0, 15.0),
		_view("isle-house", "07-front-close", "accepted_front", "close", [5, 6, 7], Vector3(-117.142, 0.0, 571.175), Vector3(-89.198, 0.0, 539.449), Vector3(0.750, 0.0, 0.661), 14.3, 5.0, 6.4),
		_view("isle-house", "08-front-ordinary", "accepted_front", "ordinary", [5, 6, 7], Vector3(-117.142, 0.0, 571.175), Vector3(-89.198, 0.0, 539.449), Vector3(0.750, 0.0, 0.661), 21.1, 84.0, 34.0),
		_view("isle-house", "09-new-wsw-close", "new_homogeneous_field", "close", [0, 1, 2], Vector3(-133.374, 0.0, 548.466), Vector3(-125.636, 0.0, 563.627), Vector3(-0.891, 0.0, 0.455), 8.0, 18.0, 28.0),
		_view("isle-house", "10-new-wsw-ordinary", "new_homogeneous_field", "ordinary", [0, 1, 2, 3, 4], Vector3(-133.374, 0.0, 548.466), Vector3(-117.142, 0.0, 571.175), Vector3(-0.780, 0.0, 0.590), 14.0, 62.0, 34.0),
		_view("isle-house", "11-shared-module-free-close", "shared_tower_module_free", "close", [10, 11, 12], Vector3(-107.522, 0.0, 522.651), Vector3(-130.305, 0.0, 546.840), Vector3(-0.728, 0.0, -0.686), 16.0, 24.0, 42.0, "airborne", 30.0),
		_view("isle-house", "12-shared-module-free-ordinary", "shared_tower_module_free", "ordinary", [10, 11, 12], Vector3(-107.522, 0.0, 522.651), Vector3(-130.305, 0.0, 546.840), Vector3(-0.728, 0.0, -0.686), 16.0, 70.0, 40.0, "airborne", 18.0),
	]
	var captures: Array[Dictionary] = []
	for view_value: Variant in views:
		var view := view_value as Dictionary
		var pose: Dictionary
		if str(view.pose_mode) == "airborne":
			pose = await _pose_airborne(world, player, view)
		else:
			pose = await _pose_on_side(world, player, view)
		if not _require(bool(pose.get("ok", false)), str(pose.get("message", "Evidence pose failed."))):
			_finish(main)
			return
		var saved := await _save_view(view, main, player, pose.metadata)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Evidence save failed."))):
			_finish(main)
			return
		captures.append(saved.metadata)

	var evidence := world.get_runtime_evidence()
	var manifest := {
		"schema_version": "ti.hawkins-isle-all-side-evidence/1",
		"generator": "game/tests/hawkins_isle_all_side_capture.gd",
		"evidence_role": "mechanical_render_proof_not_independent_art_review",
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"content_sha256": EXPECTED_CONTENT_SHA256,
		"manifest_sha256": EXPECTED_MANIFEST_SHA256,
		"hawkins": {"receiver": "building:w1249412093:wall", "source_keys": ["w1249412093"], "facade_signature": EXPECTED_HAWKINS_SIGNATURE, "field_policy": "accepted WSW/SE retained; smooth base plus plain upper on ENE/NNW; plain step; no new modules"},
		"isle_house_high": {"receiver": "building-composite:w1249412094:w1282547786:wall", "source_keys": ["w1282547786"], "facade_signature": EXPECTED_ISLE_SIGNATURE, "field_segment_count": 13, "field_quad_count": 23, "module_runs": [5, 6, 7], "new_field_runs": [0, 1, 2, 3, 4], "module_free_runs": [0, 1, 2, 3, 4, 8, 9, 10, 11, 12], "shared_tower_only_runs": [10, 11, 12], "low_receiver": "building-composite:w1249412094:w1282547787:wall", "low_receiver_untouched": true},
		"generated_world_counts": {"chunks": evidence.chunks_loaded, "meshes": evidence.mesh_instances, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"capture_count": captures.size(),
		"captures": captures,
		"limitations": ["Hawkins ENE/NNW and step remain homogeneous and module-free because admissible direct evidence does not authorize architectural schedules.", "Isle House runs 0..4 remain homogeneous and module-free pending exact side-local U mapping and independent review.", "Isle House runs 8..12 remain module-free; the low part w1282547787 remains entirely unchanged.", "The images prove live runtime coverage and framing, not independent semantic/art acceptance."],
	}
	var manifest_path := OUTPUT.path_join("capture-manifest.json")
	var file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if not _require(file != null, "Could not write all-side capture manifest."):
		_finish(main)
		return
	file.store_string(JSON.stringify(manifest, "  ", false) + "\n")
	file.close()
	print("PASS: captured %d Hawkins/Isle all-side Forward+/Metal views to %s" % [captures.size(), output_absolute])
	_finish(main)


func _view(target: String, id: String, role: String, distance_class: String, run_scope: Array, start: Vector3, end: Vector3, normal: Vector3, u: float, distance: float, target_y: float, pose_mode: String = "grounded", player_y: float = 0.0) -> Dictionary:
	return {"target": target, "id": id, "role": role, "distance_class": distance_class, "run_scope": run_scope, "start": start, "end": end, "normal": normal.normalized(), "u": u, "distance": distance, "target_y": target_y, "pose_mode": pose_mode, "player_y": player_y}


func _record_node_for_key(world: WorldLoader, key: String) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == key:
			return value as Node3D
	return null


func _pose_on_side(world: WorldLoader, player: PlayerController, view: Dictionary) -> Dictionary:
	var start := view.start as Vector3
	var end := view.end as Vector3
	var tangent := (end - start).normalized()
	var length := (end - start).length()
	var requested_distance := float(view.distance)
	var distances: Array = [requested_distance, requested_distance * 0.75, 48.0, 36.0, 24.0, 16.0, 12.0, 8.0, 5.0] if str(view.distance_class) == "ordinary" else [requested_distance, 16.0, 12.0, 8.0, 5.0]
	for u_offset in [0.0, -2.0, 2.0, -5.0, 5.0, -10.0, 10.0]:
		var candidate_u := clampf(float(view.u) + float(u_offset), 1.0, length - 1.0)
		var target := start + tangent * candidate_u
		target.y = float(view.target_y)
		for distance_value: Variant in distances:
			var distance := float(distance_value)
			var approach := Vector3(target.x, 0.0, target.z) + (view.normal as Vector3) * distance
			var result := await _pose_at(world, player, approach, target, "%s_%s" % [str(view.target), str(view.id)])
			if bool(result.get("ok", false)):
				(result.metadata as Dictionary).merge({"requested_distance_m": requested_distance, "actual_outward_distance_m": distance, "side_u_m": candidate_u}, true)
				return result
	return {"ok": false, "message": "%s has no deterministic walkable-ground camera approach." % str(view.id)}


func _pose_airborne(world: WorldLoader, player: PlayerController, view: Dictionary) -> Dictionary:
	var start := view.start as Vector3
	var end := view.end as Vector3
	var tangent := (end - start).normalized()
	var target := start + tangent * float(view.u)
	target.y = float(view.target_y)
	var approach := Vector3(target.x, float(view.player_y), target.z) + (view.normal as Vector3) * float(view.distance)
	player.set_gameplay_enabled(false)
	player.global_transform = Transform3D(Basis.IDENTITY, approach)
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
		return {"ok": false, "message": "%s airborne pose could not stabilize." % str(view.id)}
	var camera := player.get_camera()
	return {"ok": true, "metadata": {"pose_id": "%s_%s" % [str(view.target), str(view.id)], "physics_grounded_pose": false, "access_mode": "deterministic_jetpack_reachable_pose_after_passing_jetpack_contract", "in_boundary": world.get_boundary().contains_position(player.global_position), "aim_target": [target.x, target.y, target.z], "player_position": [player.global_position.x, player.global_position.y, player.global_position.z], "camera_position": [camera.global_position.x, camera.global_position.y, camera.global_position.z], "camera_forward": [-camera.global_basis.z.x, -camera.global_basis.z.y, -camera.global_basis.z.z], "camera_fov_degrees": camera.fov, "spring_length_m": arm.spring_length, "requested_distance_m": float(view.distance), "actual_outward_distance_m": float(view.distance), "side_u_m": float(view.u)}}


func _pose_at(world: WorldLoader, player: PlayerController, approach: Vector3, target: Vector3, pose_id: String) -> Dictionary:
	var hit := _ground_hit(player, Vector2(approach.x, approach.z))
	if hit.is_empty():
		return {"ok": false}
	var collider := hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	var feature := "" if record == null else str(record.get_meta("feature_kind", ""))
	var normal: Vector3 = hit.get("normal", Vector3.ZERO)
	if record == null or feature not in ["land_ground", "road_path"] or normal.dot(Vector3.UP) < 0.7:
		return {"ok": false}
	player.set_gameplay_enabled(false)
	player.global_transform = Transform3D(Basis.IDENTITY, Vector3(approach.x, float(hit.position.y), approach.z))
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
	return {"ok": true, "metadata": {"pose_id": pose_id, "physics_grounded_pose": true, "ground_y_m": float(hit.position.y), "ground_object": str(record.get_meta("derived_object_key", "")), "ground_sources": record.get_meta("source_keys", []), "in_boundary": world.get_boundary().contains_position(player.global_position), "aim_target": [target.x, target.y, target.z], "player_position": [player.global_position.x, player.global_position.y, player.global_position.z], "camera_position": [camera.global_position.x, camera.global_position.y, camera.global_position.z], "camera_forward": [-camera.global_basis.z.x, -camera.global_basis.z.y, -camera.global_basis.z.z], "camera_fov_degrees": camera.fov, "spring_length_m": arm.spring_length}}


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


func _save_view(view: Dictionary, main: GameMain, player: PlayerController, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player):
		return {"ok": false, "message": "%s could not stabilize." % str(view.id)}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s produced an empty or wrong-sized image." % str(view.id)}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s appears blank." % str(view.id)}
	var relative := "images/%s/%s.png" % [str(view.target), str(view.id)]
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(view.id)}
	var metadata := {"id": str(view.id), "target": str(view.target), "role": str(view.role), "distance_class": str(view.distance_class), "run_scope": view.run_scope, "file": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y], "sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range), "pause_overlay_visible": false}
	metadata.merge(extra, true)
	print("ALL_SIDE_CAPTURE_VIEW: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
	return {"ok": true, "metadata": metadata}


func _ground_hit(player: PlayerController, xz: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(Vector3(xz.x, 200.0, xz.y), Vector3(xz.x, -20.0, xz.y), WORLD_SOLID_MASK, [player.get_rid()])
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
	push_error("ALL_SIDE_CAPTURE_FAIL: %s" % message)


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
