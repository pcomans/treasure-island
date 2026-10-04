extends "res://game/tests/rendered_visual_evidence_capture.gd"
## B600 fresh isolated study driver, adapted from the Hawkins quality capture and
## mechanics drivers: actual source world, exact target pair swap, matched A/B
## stills, aerial study-camera stills, and (mode=full) stock-controller mechanics.
## No production attachment; the original generated pair is restored at the end.

const Geometry = preload("res://game/tests/support/building_study_geometry.gd")
const MODEL_PATH := "res://game/scripts/world/facades/b600_fresh_study_model.gd"
const CHUNK := "res://generated/world/chunks/x_1__z_-2.json"
const WALL_KEY := "building:w34313548:wall"
const ROOF_KEY := "building:w34313548:roof"
const LAND_KEY := "land:w26767313:x_1__z_-2"
const SOURCE := "w34313548"

var output := ""
var mode := "capture"
var rows: Array = []
var cases: Array = []
var motion_trace: Array = []
var sampled_frames := 0
var unsafe := false
var safe_final := false
var initial_recovery := 0
var preservation: Dictionary = {}
var geometry: Dictionary = {}
var model = null
var wall_node: Node3D
var roof_node: Node3D
var original: Array = []
var candidate_active := false


func _initialize() -> void:
	create_timer(570.0, true, false, true).timeout.connect(func(): _fail("Study timeout"); _receipt(); quit(1))
	call_deferred("_run")


func _run() -> void:
	var manifest_path := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--manifest="): manifest_path = arg.trim_prefix("--manifest=")
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
		if arg.begins_with("--mode="): mode = arg.trim_prefix("--mode=")
	if not _require(not output.is_empty() and not DirAccess.dir_exists_absolute(output), "Fresh output required"):
		await _finish(null)
		return
	DirAccess.make_dir_recursive_absolute(output)
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var ready: Array = []
	var errors: Array = []
	world.world_ready.connect(func(r: Dictionary): ready.append(r))
	world.world_failed.connect(func(c: String, m: String, k: Array): errors.append([c, m, k]))
	root.add_child(main)
	initial_recovery = int(world.get_runtime_evidence().recovery_count)
	var begin := Time.get_ticks_msec()
	while ready.is_empty() and errors.is_empty() and Time.get_ticks_msec() - begin < 90000:
		await process_frame
	if not _require(errors.is_empty() and ready.size() == 1 and world.is_world_validated(), "Source world load: %s" % [errors]):
		_receipt()
		await _finish(main)
		return
	while not player.was_first_reveal_grounded() and Time.get_ticks_msec() - begin < 90000:
		await physics_frame
	(main.get_node("Interface/HUD") as GameHUD).hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not await _install(world):
		_receipt()
		await _finish(main)
		return
	for view: Dictionary in manifest.views:
		if not _failure.is_empty() or unsafe:
			break
		if str(view.kind) == "aerial":
			await _aerial_view(view, main, player)
		else:
			await _stock_view(view, world, player)
		_receipt()
	if mode == "full" and _failure.is_empty() and not unsafe:
		await _mechanics(manifest.mechanics, world, player)
	_release_all()
	if mode == "full":
		safe_final = await _rest(world, player, "final-enabled-rest") if not unsafe and int(world.get_runtime_evidence().recovery_count) == initial_recovery and player.is_on_floor() else false
		_sample(world, player, "before-final-disable", {"safe_final": safe_final})
	player.set_gameplay_enabled(false)
	if mode == "full":
		_sample(world, player, "disabled-final")
		_require(not bool(player.get("_gameplay_enabled")) and player.velocity == Vector3.ZERO and _released(), "Disabled final safe inputs")
	preservation["after_cases"] = _protected(world)
	_require(preservation.before == preservation.after_cases, "Non-target channels unchanged through study")
	_restore()
	await physics_frame
	preservation["target_restored"] = _target_state() == original
	_require(preservation.target_restored, "Original generated w34313548 pair restored exactly")
	_receipt()
	await _finish(main)


# ------------------------------------------------------------- install / swap

func _install(world: WorldLoader) -> bool:
	wall_node = _record_node_for_key(world, WALL_KEY)
	roof_node = _record_node_for_key(world, ROOF_KEY)
	if not _require(wall_node != null and roof_node != null, "Exact w34313548 generated pair"):
		return false
	var chunk: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CHUNK))
	var roof: Dictionary = {}
	var land: Dictionary = {}
	for record: Dictionary in chunk.records:
		if record.object_key == ROOF_KEY: roof = record
		if record.object_key == LAND_KEY: land = record
	if not _require(not roof.is_empty() and not land.is_empty() and wall_node.get_meta("source_keys", []) == [SOURCE] and roof_node.get_meta("source_keys", []) == [SOURCE], "Source identity"):
		return false
	if not _require(world.global_transform == Transform3D.IDENTITY, "World root identity"):
		return false
	original = _target_state()
	preservation["before"] = _protected(world)
	preservation["target_original"] = original
	model = load(MODEL_PATH).new()
	var built: Dictionary = model.build(roof, land)
	if not _require(bool(built.get("ok", false)), "Candidate build: " + str(built)):
		model.free()
		model = null
		return false
	world.add_child(model)
	_set_candidate(false)
	await physics_frame
	preservation["after_install"] = _protected(world)
	return _require(preservation.before == preservation.after_install, "Install left non-target channels unchanged")


func _target_bodies() -> Array:
	var out: Array = []
	for node: Node3D in [wall_node, roof_node]:
		for body: CollisionObject3D in node.find_children("*", "CollisionObject3D", true, false):
			out.append(body)
	return out


func _target_state() -> Array:
	var state: Array = []
	for node: Node3D in [wall_node, roof_node]:
		state.append([str(node.get_path()), node.visible, (node.get_node("Mesh") as Node3D).visible])
	for body: CollisionObject3D in _target_bodies():
		state.append([str(body.get_path()), body.collision_layer, body.collision_mask, body.is_in_group("spray_receiver_wall")])
	return state


func _set_candidate(active: bool) -> void:
	candidate_active = active
	(wall_node.get_node("Mesh") as Node3D).visible = not active
	(roof_node.get_node("Mesh") as Node3D).visible = not active
	var index := 2
	for body: CollisionObject3D in _target_bodies():
		var saved: Array = original[index]
		index += 1
		body.collision_layer = 0 if active else int(saved[1])
		body.collision_mask = 0 if active else int(saved[2])
		if active:
			body.remove_from_group("spray_receiver_wall")
		elif bool(saved[3]):
			body.add_to_group("spray_receiver_wall")
	model.visible = active
	for body: StaticBody3D in _candidate_bodies():
		body.collision_layer = 5 if active else 0
		if body.name == "WallContact":
			if active:
				body.add_to_group("spray_receiver_wall")
			else:
				body.remove_from_group("spray_receiver_wall")


func _candidate_bodies() -> Array:
	var out: Array = []
	if model == null:
		return out
	for name: String in ["WallContact", "RoofContact", "DetailContact"]:
		out.append(model.get_node(name))
	return out


func _restore() -> void:
	if model == null:
		return
	_set_candidate(false)
	for body: StaticBody3D in _candidate_bodies():
		body.collision_layer = 0
		body.remove_from_group("spray_receiver_wall")
	model.queue_free()
	model = null


func _protected(world: WorldLoader) -> Dictionary:
	var result: Dictionary = {}
	var skip := _target_bodies()
	for body: CollisionObject3D in world.find_children("*", "CollisionObject3D", true, false):
		if body is PlayerController or skip.has(body) or (model != null and model.is_ancestor_of(body)):
			continue
		var shapes: Array = []
		for child: CollisionShape3D in body.find_children("*", "CollisionShape3D", true, false):
			shapes.append([child.transform, child.disabled, str(child.shape.get_faces()) if child.shape is ConcavePolygonShape3D else str(child.shape)])
		result[str(body.get_path())] = [body.global_transform, body.collision_layer, body.collision_mask, shapes]
	return result


# ------------------------------------------------------------- stills

func _view_pose(view: Dictionary, world: WorldLoader, player: PlayerController) -> Dictionary:
	if view.has("camera_ab"):
		var cam: Vector3 = model.local_to_world(Vector3(view.camera_ab[0], 0, view.camera_ab[1]))
		var h := deg_to_rad(float(view.heading_deg))
		var p := deg_to_rad(float(view.pitch_deg))
		var fwd := Vector3(sin(h), 0, -cos(h))
		var pxz := Vector2(cam.x, cam.z) + Vector2(fwd.x, fwd.z) * 5.5 * cos(p)
		return {"xz": pxz, "dir": (fwd * cos(p) + Vector3.UP * sin(p)).normalized(), "heading": true}
	var pl: Vector3 = model.local_to_world(Vector3(view.player_ab[0], 0, view.player_ab[1]))
	var aim: Vector3 = model.local_to_world(Vector3(view.aim_abh[0], model.B + float(view.aim_abh[2]), view.aim_abh[1]))
	return {"xz": Vector2(pl.x, pl.z), "aim": aim, "heading": false}


func _stock_view(view: Dictionary, world: WorldLoader, player: PlayerController) -> void:
	var pose := _view_pose(view, world, player)
	var settled := await _settle_player(pose.xz, str(view.id), world, player)
	if not _require(settled.get("ok", false), str(settled)):
		return
	var target: Vector3
	if pose.heading:
		target = player.global_position + Vector3(0, 2, 0) + (pose.dir as Vector3) * 40.0
	else:
		target = pose.aim
	_aim_camera_at(player, target)
	for frame in 6:
		_force_unpaused(player)
		await physics_frame
	var phases := str(view.get("phases", "AB"))
	var fixed := Transform3D()
	if phases.contains("A"):
		_set_candidate(false)
		if not await _wait_for_render(player): return
		fixed = player.get_camera().global_transform
		var saved := _save_current_view({"id": str(view.id) + "-A", "region": SOURCE, "intent": str(view.intent)}, output, player, {"phase": "A-generated-placeholder", "view": view, "settle": settled.metadata, "source_key": SOURCE})
		if not _require(saved.get("ok", false), str(saved)): return
		rows.append(saved.metadata)
	_set_candidate(true)
	if not await _wait_for_render(player): return
	var drift := 0.0 if not phases.contains("A") else fixed.origin.distance_to(player.get_camera().global_transform.origin)
	var saved_b := _save_current_view({"id": str(view.id) + "-B", "region": SOURCE, "intent": str(view.intent)}, output, player, {"phase": "B-candidate", "view": view, "settle": settled.metadata, "source_key": SOURCE, "ab_camera_drift_m": drift})
	if not _require(saved_b.get("ok", false), str(saved_b)): return
	rows.append(saved_b.metadata)
	# Recorded, not fatal: a spring-arm difference only limits A/B pixel comparison.
	if drift >= 0.001:
		print("B600_AB_CAMERA_DRIFT: %s %.4f" % [view.id, drift])


func _aerial_view(view: Dictionary, main: Node, player: PlayerController) -> void:
	var cam := Camera3D.new()
	cam.fov = float(view.get("fov", 45.0))
	cam.far = 4000.0
	main.add_child(cam)
	var eye: Vector3 = model.local_to_world(Vector3(view.eye_abh[0], model.B + float(view.eye_abh[2]), view.eye_abh[1]))
	var look: Vector3 = model.local_to_world(Vector3(view.look_abh[0], model.B + float(view.look_abh[2]), view.look_abh[1]))
	var up := Vector3(0, 0, -1) if bool(view.get("top_down", false)) else Vector3.UP
	cam.look_at_from_position(eye, look, up)
	cam.make_current()
	for phase in ["A", "B"]:
		_set_candidate(phase == "B")
		if not await _wait_for_render(player): break
		var saved := _save_study_camera(str(view.id) + "-" + phase, cam, {"phase": "A-generated-placeholder" if phase == "A" else "B-candidate", "view": view, "camera": "non-gameplay aerial study camera"})
		if not _require(saved.get("ok", false), str(saved)): break
		rows.append(saved.metadata)
	player.get_camera().make_current()
	cam.queue_free()
	_set_candidate(true)
	await process_frame


func _save_study_camera(id: String, camera: Camera3D, extra: Dictionary) -> Dictionary:
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		return {"ok": false, "message": id + " empty image"}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8:
		return {"ok": false, "message": id + " blank image"}
	var path := output.path_join(id + ".png")
	if image.save_png(path) != OK:
		return {"ok": false, "message": id + " save failed"}
	var metadata := {"id": id, "file": id + ".png", "sha256": FileAccess.get_sha256(path), "dimensions": [image.get_width(), image.get_height()], "camera_position": _v(camera.global_position), "camera_forward": _v(-camera.global_basis.z), "fov": camera.fov}
	metadata.merge(extra, true)
	print("VISUAL_CAPTURE: id=%s sha256=%s" % [id, metadata.sha256])
	return {"ok": true, "metadata": metadata}


# ------------------------------------------------------------- mechanics

func _mechanics(spec: Dictionary, world: WorldLoader, player: PlayerController) -> void:
	_set_candidate(true)
	# Stills use look_at on the pivot; stock mouse input keeps pitch on the arm.
	var rig := player.get_node("CameraPivot") as PlayerCamera
	rig.rotation = Vector3(0.0, rig.rotation.y, 0.0)
	(rig.get_node("SpringArm3D") as SpringArm3D).rotation = Vector3(deg_to_rad(-8.0), 0.0, 0.0)
	await physics_frame
	if not _native_geometry():
		return
	if not await _rest(world, player, "initial-candidate-rest"):
		return
	for route: Dictionary in spec.routes:
		if unsafe or not _failure.is_empty():
			return
		await _route_case(route, world, player)
	if unsafe or not _failure.is_empty():
		return
	for stop: Dictionary in spec.wall_stops:
		await _wall_stop_case(stop, world, player)
		if unsafe or not _failure.is_empty():
			return
	for spray: Dictionary in spec.sprays:
		await _spray_case(spray, world, player)
		if unsafe or not _failure.is_empty():
			return


func _native_geometry() -> bool:
	var all_ok := true
	var pairs := {"WallContact": "WallMesh", "RoofContact": "RoofMesh", "DetailContact": "DetailMesh"}
	for body_name: String in pairs:
		var body: StaticBody3D = model.get_node(body_name)
		var holder: CollisionShape3D = body.get_node("Shape")
		var shape := holder.shape as ConcavePolygonShape3D
		var inst: MeshInstance3D = model.get_node(pairs[body_name])
		var expected := 0
		for si in inst.mesh.get_surface_count():
			expected += (inst.mesh.surface_get_arrays(si)[Mesh.ARRAY_INDEX] as PackedInt32Array).size()
		var transforms: Array[Transform3D] = [inst.transform]
		var collected := Geometry.collect(inst.mesh, transforms, Geometry.INDEXED_ARRAYS)
		var compared := Geometry.compare(collected, shape.get_faces(), expected)
		var wall_role := body_name == "WallContact"
		var owner_ok := false
		for id in body.get_shape_owners():
			for i in body.shape_owner_get_shape_count(id):
				owner_ok = owner_ok or (body.shape_owner_get_owner(id) == holder and not body.is_shape_owner_disabled(id) and body.shape_owner_get_shape(id, i) == shape)
		var predicates := {
			"compare": bool(compared.ok),
			"shape_owner": owner_ok,
			"body_local_identity": body.transform == Transform3D.IDENTITY and holder.transform == Transform3D.IDENTITY and inst.transform == Transform3D.IDENTITY,
			"server_transform": body.global_transform.is_equal_approx(PhysicsServer3D.body_get_state(body.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM)),
			"same_global_as_render": body.global_transform == inst.global_transform,
			"layer": body.collision_layer == 5,
			"mask": body.collision_mask == 0,
			"spray_group": body.is_in_group("spray_receiver_wall") == wall_role,
			"render_layer": inst.layers == (2 if wall_role else 1),
			"metadata": body.get_meta("source_keys", []) == [SOURCE] and str(body.get_meta("receiver_kind", "")) == ("building_wall" if wall_role else "none") and shape.get_meta("source_keys", []) == [SOURCE],
		}
		var ok := true
		for key: String in predicates:
			ok = ok and bool(predicates[key])
		geometry[body_name] = {"ok": ok, "predicates": predicates, "expected_vertex_count": expected, "compare_predicates": compared.predicates}
		var file := FileAccess.open(output.path_join("native-geometry-%s.json" % body_name), FileAccess.WRITE)
		file.store_string(JSON.stringify({"predicates": predicates, "compare": compared}))
		file.close()
		all_ok = all_ok and ok
	cases.append({"case": "shared-indexed-native-geometry-and-roles", "ok": all_ok, "bodies": geometry})
	return _require(all_ok, "Shared indexed geometry/roles for candidate bodies")


func _local(ab: Array) -> Vector3:
	return model.local_to_world(Vector3(float(ab[0]), 0, float(ab[1])))


func _route_case(route: Dictionary, world: WorldLoader, player: PlayerController) -> void:
	var record := {"case": str(route.id), "ok": false, "legs": []}
	cases.append(record)
	var start := _local(route.start_ab)
	var setup := await _settle_player(Vector2(start.x, start.z), str(route.id), world, player)
	record["setup"] = setup
	if not _require(setup.get("ok", false), str(setup)):
		unsafe = true
		return
	if not await _rest(world, player, str(route.id) + "-start"):
		return
	var all_ok := true
	var points: Array = route.waypoints_ab
	var mid_capture: Dictionary = route.get("capture_at", {})
	for i in points.size():
		var dest := _local(points[i])
		var leg := await _walk_leg(dest, "%s-leg%d" % [route.id, i], world, player, mid_capture)
		(record.legs as Array).append(leg)
		all_ok = all_ok and bool(leg.ok)
		if not leg.ok or unsafe or not _failure.is_empty():
			break
	record["ok"] = all_ok and not unsafe and _failure.is_empty()
	_require(record.ok, "Stock walking route " + str(route.id))


func _walk_leg(destination: Vector3, label: String, world: WorldLoader, player: PlayerController, capture_at: Dictionary) -> Dictionary:
	var aim := destination
	aim.y = player.global_position.y + 2.0
	var aimed := await _input_aim(player, aim, true)
	if not _require(aimed.ok, "Stock route aim " + label):
		unsafe = true
		return {"ok": false, "label": label}
	var before := int(world.get_runtime_evidence().recovery_count)
	var start_index := motion_trace.size()
	var start := player.global_position
	var arrived := false
	var captured := false
	var owners := {}
	player.set_gameplay_enabled(true)
	Input.action_press("move_forward")
	for i in 900:
		_force_unpaused(player)
		await physics_frame
		var row := _sample(world, player, label)
		if not _safe(world):
			break
		for s: Dictionary in row.slides:
			owners[str(s.owner)] = true
		if not captured and not capture_at.is_empty():
			var lp: Vector3 = _to_local(player.global_position)
			if absf(lp.z - float(capture_at.b)) < 0.25 and label.ends_with("leg%d" % int(capture_at.leg)):
				captured = true
				await _motion_image(player, label + "-mid")
		if Vector2(player.global_position.x - destination.x, player.global_position.z - destination.z).length() < 0.25:
			arrived = true
			break
	_release_all()
	if unsafe or int(world.get_runtime_evidence().recovery_count) != before:
		_require(false, "Unsafe recovery during " + label)
		player.set_gameplay_enabled(false)
		return {"ok": false, "label": label, "fatal": true}
	var rest := await _rest(world, player, label + "-rest")
	var supports := {}
	for k in range(start_index, motion_trace.size()):
		supports[str(motion_trace[k].support)] = true
	var ok := arrived and rest
	return {"ok": ok, "label": label, "arrived": arrived, "safe_rest": rest, "start": _v(start), "end": _v(player.global_position), "end_local": _v(_to_local(player.global_position)), "destination": _v(destination), "trace_start": start_index, "trace_end": motion_trace.size(), "slide_owners": owners.keys(), "support_owners": supports.keys(), "recovery_delta": int(world.get_runtime_evidence().recovery_count) - before, "aim": aimed}


func _wall_stop_case(stop: Dictionary, world: WorldLoader, player: PlayerController) -> void:
	var record := {"case": str(stop.id), "ok": false}
	cases.append(record)
	var start := _local(stop.start_ab)
	var setup := await _settle_player(Vector2(start.x, start.z), str(stop.id), world, player)
	if not _require(setup.get("ok", false), str(setup)):
		unsafe = true
		return
	var toward := _local(stop.toward_ab)
	toward.y = player.global_position.y + 2.0
	var aimed := await _input_aim(player, toward, true)
	if not _require(aimed.ok, "Stock wall-stop aim"):
		unsafe = true
		return
	if not await _rest(world, player, str(stop.id) + "-start"):
		return
	var start_index := motion_trace.size()
	var owners := {}
	player.set_gameplay_enabled(true)
	Input.action_press("move_forward")
	for i in int(stop.frames):
		_force_unpaused(player)
		await physics_frame
		var row := _sample(world, player, str(stop.id) + "-push")
		if not _safe(world):
			break
		for s: Dictionary in row.slides:
			owners[str(s.owner)] = true
	_release_all()
	if unsafe:
		return
	var pushed := _to_local(player.global_position)
	await _motion_image(player, str(stop.id) + "-pushed")
	var rest := await _rest(world, player, str(stop.id) + "-pushed-rest")
	var retreat_aim := _local(stop.start_ab)
	var back := await _walk_leg(retreat_aim, str(stop.id) + "-retreat", world, player, {})
	var face_b := float(stop.face_b)
	var stopped := pushed.z < face_b - 0.30 and pushed.z > face_b - 0.60
	record.merge({"pushed_local": _v(pushed), "face_b": face_b, "stopped_at_face": stopped, "slide_owners": owners.keys(), "rest": rest, "retreat": back, "trace_start": start_index})
	record["ok"] = stopped and owners.has(WALL_KEY) and rest and bool(back.ok)
	_require(record.ok, "Closed wall blocks stock walking " + str(stop.id))


func _spray_case(spray: Dictionary, world: WorldLoader, player: PlayerController) -> void:
	var record := {"case": str(spray.id), "ok": false}
	cases.append(record)
	var start := _local(spray.player_ab)
	var setup := await _settle_player(Vector2(start.x, start.z), str(spray.id), world, player)
	if not _require(setup.get("ok", false), str(setup)):
		unsafe = true
		return
	var target: Vector3 = model.local_to_world(Vector3(spray.target_abh[0], model.B + float(spray.target_abh[2]), spray.target_abh[1]))
	var aimed := await _input_aim(player, target, false)
	record["aim"] = aimed
	if not _require(aimed.ok, "Stock spray aim " + str(spray.id)):
		unsafe = true
		return
	if not await _rest(world, player, str(spray.id) + "-start"):
		return
	if not await _wait_for_active_render(player):
		unsafe = true
		return
	var hit := _camera_spray_hit(player)
	var expected_body: Node = model.get_node(str(spray.body))
	record["hit"] = _hit_record(hit)
	record["target"] = _v(target)
	record["hit_target_distance"] = -1.0 if hit.is_empty() else (hit.position as Vector3).distance_to(target)
	record["player_range"] = -1.0 if hit.is_empty() else player.global_position.distance_to(hit.position)
	if not _require(not hit.is_empty() and hit.collider == expected_body and float(record.hit_target_distance) >= 0.0 and float(record.hit_target_distance) < 0.10, "Camera ray first hit expected candidate body " + str(spray.id)):
		return
	var controller := player.get_spray_controller()
	var before := controller.tag_instances.active_count()
	var results: Array[String] = []
	var callback := func(code: String): results.append(code)
	controller.spray_result.connect(callback)
	controller.attempt_spray()
	await process_frame
	controller.spray_result.disconnect(callback)
	var after := controller.tag_instances.active_count()
	record.merge({"results": results, "tag_count_before": before, "tag_count_after": after, "expected": str(spray.expect)})
	var ok := false
	if str(spray.expect) == "placed":
		var tag: Decal = null
		if after == before + 1:
			tag = controller.tag_instances.get_child(controller.tag_instances.get_child_count() - 1) as Decal
		ok = results == ["placed"] and tag != null and tag.get_meta("derived_object_key", "") == WALL_KEY and tag.get_meta("source_keys", []) == [SOURCE] and tag.cull_mask == 2 and tag.global_position.distance_to(hit.position) < 0.05
		if tag != null:
			record["tag"] = {"origin": _v(tag.global_position), "size": _v(tag.size), "metadata": [tag.get_meta("derived_object_key", ""), tag.get_meta("source_keys", [])]}
	else:
		ok = results == [str(spray.expect)] and after == before
	await _motion_image(player, str(spray.id))
	var rest := await _rest(world, player, str(spray.id) + "-rest")
	record["rest"] = rest
	record["ok"] = ok and rest
	_require(record.ok, "Stock spray outcome " + str(spray.id))


func _to_local(p: Vector3) -> Vector3:
	var d: Vector3 = p - model.origin_world
	return Vector3(d.dot(model.axis_a), p.y, d.dot(model.axis_b))


func _motion_image(player: PlayerController, stage: String) -> void:
	if not await _wait_for_active_render(player):
		unsafe = true
		return
	var shot: Dictionary = _save_current_view({"id": "motion-" + stage, "region": SOURCE, "intent": "Sampled actual stock motion/spray: " + stage}, output, player, {"source_key": SOURCE, "phase": stage, "physics_frame": Engine.get_physics_frames(), "movement_proof": true, "physics_grounded": player.is_on_floor(), "controller_enabled": bool(player.get("_gameplay_enabled")), "actions": _input_state(), "scope": "Single sampled frame"})
	if _require(shot.get("ok", false), "Motion sample " + stage):
		rows.append(shot.metadata)
	else:
		unsafe = true


# ------------------------------------------------------------- shared helpers (Hawkins mechanics donor)

func _sample(world: WorldLoader, player: PlayerController, label: String, extra: Dictionary = {}) -> Dictionary:
	var position := player.global_position
	var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position + Vector3.UP * 0.3, position - Vector3.UP * 0.6, 1, [player.get_rid()]))
	var support := "" if hit.is_empty() else _derived_object_key_for_collider(hit.collider)
	var collisions: Array = []
	for i in player.get_slide_collision_count():
		var col := player.get_slide_collision(i)
		collisions.append({"owner": _derived_object_key_for_collider(col.get_collider()), "body": str((col.get_collider() as Node).name) if col.get_collider() is Node else "", "normal": _v(col.get_normal()), "position": _v(col.get_position()), "depth": col.get_depth()})
	var row := {"stage": label, "physics_frame": Engine.get_physics_frames(), "position": _v(position), "velocity": _v(player.velocity), "on_floor": player.is_on_floor(), "support": support, "support_y": null if hit.is_empty() else hit.position.y, "recovery": world.get_runtime_evidence().recovery_count, "slides": collisions, "controller_enabled": bool(player.get("_gameplay_enabled")), "released_inputs": _released()}
	if model != null:
		row["local"] = _v(_to_local(position))
	row["actions"] = _input_state()
	row.merge(extra, true)
	sampled_frames += 1
	motion_trace.append(row)
	return row


func _v(p: Vector3) -> Array:
	return [p.x, p.y, p.z]


func _released() -> bool:
	for action in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack", "spray"]:
		if Input.is_action_pressed(action): return false
	return true


func _input_state() -> Dictionary:
	var state: Dictionary = {}
	for action in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack", "spray"]:
		state[action] = Input.is_action_pressed(action)
	return state


func _rest(world: WorldLoader, player: PlayerController, label: String) -> bool:
	_release_all()
	player.set_gameplay_enabled(true)
	var consecutive := 0
	for frame in 180:
		_force_unpaused(player)
		await physics_frame
		_sample(world, player, label)
		if not _safe(world): return false
		var current: Dictionary = motion_trace[-1]
		if player.is_on_floor() and player.velocity.length() < 0.05 and not str(current.support).is_empty() and current.controller_enabled and current.released_inputs:
			consecutive += 1
		else:
			consecutive = 0
		if consecutive >= 8: break
	var last: Dictionary = motion_trace[-1]
	var good: bool = consecutive >= 8 and player.is_on_floor() and player.velocity.length() < 0.05 and not str(last.support).is_empty() and last.controller_enabled and last.released_inputs
	if not good: unsafe = true
	return _require(good and not unsafe, "Supported input-released stock rest: " + label)


func _release_all() -> void:
	_clear_gameplay_input()
	Input.action_release("spray")


func _safe(world: WorldLoader) -> bool:
	if int(world.get_runtime_evidence().recovery_count) != initial_recovery:
		unsafe = true
		_require(false, "Recovery since initial reveal; stop later actions")
	return not unsafe


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


func _hit_record(hit: Dictionary) -> Dictionary:
	if hit.is_empty(): return {"hit": false}
	var body: CollisionObject3D = hit.collider
	return {"hit": true, "body": str(body.get_path()), "shape_index": int(hit.shape), "point": _v(hit.position), "normal": _v(hit.normal), "derived_object_key": str(body.get_meta("derived_object_key", "")), "receiver_kind": str(body.get_meta("receiver_kind", "")), "layer": body.collision_layer}


func _receipt() -> void:
	if output.is_empty() or not DirAccess.dir_exists_absolute(output):
		return
	var ok := _failure.is_empty() and not unsafe and (safe_final or mode != "full")
	var trace := FileAccess.open(output.path_join("motion-trace.json"), FileAccess.WRITE)
	trace.store_string(JSON.stringify({"sampled_frames": sampled_frames, "stored_records": motion_trace.size(), "records": motion_trace}))
	trace.close()
	var file := FileAccess.open(output.path_join("capture-receipt.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"ok": ok, "mode": mode, "failure": _failure, "unsafe": unsafe, "safe_final": safe_final, "initial_recovery": initial_recovery, "cases": cases, "captures": rows, "geometry": geometry, "preservation_equal": preservation.get("before", null) == preservation.get("after_cases", preservation.get("after_install", null)), "target_original": preservation.get("target_original", []), "target_restored": preservation.get("target_restored", null), "scope": "Isolated B600 study; no production attachment, acceptance or release claim"}, "\t") + "\n")
	file.close()
