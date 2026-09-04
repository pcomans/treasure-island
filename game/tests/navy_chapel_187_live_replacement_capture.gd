extends "res://game/tests/navy_chapel_187_standalone_hero_capture.gd"

## Native, actual-live evidence only. This harness resolves the replacement
## produced by main.tscn and never attaches the standalone prototype itself.

const LIVE_OUTPUT := "res://evidence/first-playable/navy-chapel-187-live-replacement-2026-09-04"
const LIVE_GENERATOR := "res://game/tests/navy_chapel_187_live_replacement_capture.gd"
const LIVE_ADAPTER := "res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd"
const LIVE_BUILDER := "res://game/scripts/world/world_chunk_builder.gd"
const LIVE_GEOMETRY_SIGNATURE := "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46"
const LIVE_OWNERSHIP_SIGNATURE := "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7"
const LIVE_APPROVAL_RECEIPT_SHA256 := "4232ad42b3600b1d7f945c5d51325bb9698c366e07eb1ddea3fd90f3f49235c6"
const LIVE_CANONICAL_WALL_SHA256 := "69769fef402b480f1626fdce47e6d4ad49ecb710dab2b2e7373e5efa5acf0080"
const LIVE_CANONICAL_ROOF_SHA256 := "54bcd378997d0778bdaee432dc24ecdbb142c5dc5371166cf2d690ebb245b832"
const LIVE_EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const LIVE_EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const LIVE_WORLD_TOPOLOGY := {
	"rows": 735, "meshes": 944, "surfaces": 957, "triangles": 64572,
	"bodies": 466, "shapes": 466,
}
const LIVE_STILL_SIZE := Vector2i(1440, 900)
const LIVE_MOTION_SIZE := Vector2i(1280, 800)
const LIVE_CHANGED_LIGHT := Vector3(-32.0, 132.0, 0.0)
const LIVE_MOTION_FILE := "navy-chapel-187-actual-live-public-stock-walk.avi"
const LIVE_MOTION_FRAMES := 300
const LIVE_MOTION_HZ := 60
const LIVE_FIXED_FPS := 30

const LIVE_VIEWS := [
	{
		"id": "01-whole-public-default",
		"role": "grounded_ordinary_player_actual_live_whole_public_object",
		"requested_xz": Vector2(-52.0, 675.0),
		"aim_target": Vector3(-100.468506, 9.019500, 648.694946),
		"expected_run_index": 9,
		"lighting": "world_default",
	},
	{
		"id": "03-public-oblique-default",
		"role": "grounded_ordinary_player_actual_live_public_oblique",
		"requested_xz": Vector2(-36.0, 668.0),
		"aim_target": Vector3(-100.468506, 9.019500, 648.694946),
		"expected_run_index": 9,
		"lighting": "world_default",
	},
]


func _initialize() -> void:
	create_timer(300.0, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	var mode := _argument_value("--capture-mode=")
	if mode == "finalize-motion":
		_finalize_motion()
		_finish(null)
		return
	if mode not in ["stills", "motion"]:
		_fail("Pass exactly --capture-mode=stills, motion, or finalize-motion.")
		_finish(null)
		return
	if DisplayServer.get_name() == "headless":
		_fail("Actual-live Chapel evidence requires native macOS Forward+/Metal.")
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
	var size_ok := observed_size == LIVE_STILL_SIZE if mode == "stills" else (
		observed_size.x >= 960 and observed_size.y >= 600
		and absf(float(observed_size.x) / float(observed_size.y) - 1.6) <= 0.005
	)
	if not _require(size_ok, "%s viewport %s violates the native capture contract." % [mode, observed_size]):
		_finish(main)
		return
	var bindings := _actual_live_bindings(world)
	if not _require(bool(bindings.get("ok", false)), str(bindings.get("message", "Live Chapel binding failed."))):
		_finish(main)
		return
	if not _require(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(LIVE_OUTPUT.path_join("images"))) == OK, "Could not create live Chapel evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	if mode == "stills":
		await _capture_stills_and_landing(main, world, player, hud, sun, bindings.metadata as Dictionary)
	else:
		await _capture_motion(main, world, player, hud, sun, bindings.metadata as Dictionary)
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
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void:
		failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()})
	)
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await process_frame
	if not failures.is_empty() or ready.size() != 1:
		return {"ok": false, "message": "%s world did not reach one ready state: %s" % [mode, failures], "main": main}
	while not player.was_first_reveal_grounded() and Time.get_ticks_msec() - started < 60000:
		await physics_frame
	if not player.was_first_reveal_grounded() or not player.visible:
		return {"ok": false, "message": "%s stock player did not complete startup settlement." % mode, "main": main}
	if str(ready[0].get("content_sha256", "")) != LIVE_EXPECTED_CONTENT_SHA256 \
	or FileAccess.get_sha256("res://generated/world/manifest.json") != LIVE_EXPECTED_MANIFEST_SHA256:
		return {"ok": false, "message": "Generated world identity drifted before live Chapel capture.", "main": main}
	var evidence := world.get_runtime_evidence()
	var topology := {
		"rows": evidence.playable_rows, "meshes": evidence.mesh_instances,
		"surfaces": evidence.surfaces, "triangles": evidence.triangles,
		"bodies": evidence.static_bodies, "shapes": evidence.shapes,
	}
	if topology != LIVE_WORLD_TOPOLOGY:
		return {"ok": false, "message": "Actual-live Chapel topology drifted: %s." % topology, "main": main}
	return {"ok": true, "main": main, "world": world, "player": player, "hud": hud, "sun": sun}


func _actual_live_bindings(world: WorldLoader) -> Dictionary:
	var walls := _record_nodes(world, WALL_KEY)
	var roofs := _record_nodes(world, ROOF_KEY)
	if walls.size() != 1 or roofs.size() != 1:
		return {"ok": false, "message": "Expected one live Chapel wall and roof root, got %d/%d." % [walls.size(), roofs.size()]}
	var wall := walls[0]
	var roof := roofs[0]
	var wall_body := wall.get_node_or_null("Collision") as StaticBody3D
	var roof_body := roof.get_node_or_null("Collision") as StaticBody3D
	var wall_meta := wall.get_meta("navy_chapel_187_live_replacement", {}) as Dictionary
	var roof_meta := roof.get_meta("navy_chapel_187_live_replacement", {}) as Dictionary
	if wall.name != "NavyChapel187LiveWallVisualAndCollisionReplacement" \
	or roof.name != "NavyChapel187LiveRoofCollisionReplacement" \
	or wall_body == null or roof_body == null \
	or wall_body.get_child_count() != 1 or roof_body.get_child_count() != 1 \
	or not wall_body.is_in_group("spray_receiver_wall") or roof_body.is_in_group("spray_receiver_wall") \
	or str(wall_body.get_meta("receiver_kind", "")) != "building_wall" \
	or str(roof_body.get_meta("receiver_kind", "invalid")) != "none" \
	or str(wall_meta.get("geometry_signature", "")) != LIVE_GEOMETRY_SIGNATURE \
	or str(wall_meta.get("live_ownership_signature", "")) != LIVE_OWNERSHIP_SIGNATURE \
	or wall_meta != roof_meta \
	or bool(wall_meta.get("fallback_allowed", true)) or bool(wall_meta.get("stack_allowed", true)) \
	or bool(wall_meta.get("recognition_accepted", true)) or bool(wall_meta.get("believability_accepted", true)):
		return {"ok": false, "message": "Live Chapel node, ownership, signature, or pending-review state drifted."}
	var preview_count := 0
	for node: Node in world.find_children("*", "Node", true, false):
		if bool(node.get_meta("capture_only_replacement", false)) or str(node.name).contains("CaptureOnly"):
			preview_count += 1
	if preview_count != 0:
		return {"ok": false, "message": "Actual-live world contains a capture-only preview node."}
	return {"ok": true, "metadata": {
		"wall_root_path": str(wall.get_path()), "roof_root_path": str(roof.get_path()),
		"wall_body_path": str(wall_body.get_path()), "roof_body_path": str(roof_body.get_path()),
		"wall_source_keys": wall.get_meta("source_keys", []), "roof_source_keys": roof.get_meta("source_keys", []),
		"geometry_signature": LIVE_GEOMETRY_SIGNATURE, "live_ownership_signature": LIVE_OWNERSHIP_SIGNATURE,
		"canonical_wall_record_sha256": LIVE_CANONICAL_WALL_SHA256,
		"canonical_roof_record_sha256": LIVE_CANONICAL_ROOF_SHA256,
		"approval_receipt_sha256": LIVE_APPROVAL_RECEIPT_SHA256,
		"wall_collision_triangles": 94, "roof_collision_triangles": 50,
		"structural_body_count": 2, "structural_shape_count": 2,
		"spray_owner_count": 1, "navigation_owner_count": 0,
		"generic_wall_or_roof_stack_count": 0, "preview_attachment_count": 0,
		"recognition_accepted": false, "believability_accepted": false,
	}}


func _capture_stills_and_landing(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary) -> void:
	var original_sun := sun.rotation_degrees
	if not _require(original_sun.is_equal_approx(EXPECTED_SUN_ROTATION_DEGREES), "Default sunlight drifted before Chapel capture."):
		return
	var wall_nodes := _record_nodes(world, WALL_KEY)
	var roof_nodes := _record_nodes(world, ROOF_KEY)
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	var wall_record := _record_for_key(chunk.records as Array, WALL_KEY)
	var captures: Array[Dictionary] = []
	for value: Variant in LIVE_VIEWS:
		var view := value as Dictionary
		sun.rotation_degrees = original_sun
		var posed := await _settle_and_aim(world, player, hud, view)
		if not _require(bool(posed.get("ok", false)), str(posed.get("message", "%s pose failed." % str(view.id)))):
			return
		var framing := _framing_metadata(player.get_camera(), wall_nodes + roof_nodes)
		var los := _center_los(player, view, wall_record, WALL_KEY)
		if not _require(_framing_is_technical_valid(framing), "%s live framing failed: %s." % [str(view.id), framing]) \
		or not _require(bool(los.get("ok", false)), str(los.get("message", "%s LOS failed." % str(view.id)))):
			return
		var extra := posed.metadata as Dictionary
		extra.merge(framing.metadata as Dictionary, true)
		extra.merge(los.metadata as Dictionary, true)
		extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
		var saved := await _save_live_image(main, player, hud, view, extra)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "%s save failed." % str(view.id)))):
			return
		captures.append(saved.metadata as Dictionary)
		if str(view.id) == "01-whole-public-default":
			var frozen_player := player.global_transform
			var frozen_camera := player.get_camera().global_transform
			sun.rotation_degrees = LIVE_CHANGED_LIGHT
			var changed := view.duplicate(true)
			changed.id = "02-whole-public-changed-light"
			changed.lighting = "frozen_changed_light"
			var changed_extra := extra.duplicate(true)
			changed_extra["same_pose_as"] = str(view.id)
			changed_extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
			changed_extra["player_transform_exactly_reused"] = player.global_transform.is_equal_approx(frozen_player)
			changed_extra["camera_transform_exactly_reused"] = player.get_camera().global_transform.is_equal_approx(frozen_camera)
			var changed_saved := await _save_live_image(main, player, hud, changed, changed_extra)
			if not _require(bool(changed_saved.get("ok", false)), str(changed_saved.get("message", "Changed-light save failed."))):
				return
			captures.append(changed_saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var landing := await _capture_roof_landing(main, world, player, hud, wall_record)
	if not _require(bool(landing.get("ok", false)), str(landing.get("message", "Roof landing evidence failed."))):
		return
	captures.append(landing.capture as Dictionary)
	var manifest := {
		"schema_version": "ti.navy-chapel-187-actual-live-evidence/1",
		"review_status": "pending_independent_exact_current_live_review_not_self_accepted",
		"visual_verdict": "pending_independent_review",
		"recognition_status": "pending_independent_review",
		"believability_status": "pending_independent_review",
		"generator": LIVE_GENERATOR.trim_prefix("res://"),
		"generator_sha256": FileAccess.get_sha256(LIVE_GENERATOR),
		"live_adapter_sha256": FileAccess.get_sha256(LIVE_ADAPTER),
		"world_builder_sha256": FileAccess.get_sha256(LIVE_BUILDER),
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(), "video_adapter": RenderingServer.get_video_adapter_name(),
		"viewport": [LIVE_STILL_SIZE.x, LIVE_STILL_SIZE.y],
		"target": {"canonical_name": "Navy Chapel Building 187", "source_key": SOURCE_KEY, "wall_object_key": WALL_KEY, "roof_object_key": ROOF_KEY},
		"bindings": bindings, "runtime_topology": LIVE_WORLD_TOPOLOGY.duplicate(true),
		"captures": captures, "capture_count": captures.size(),
		"roof_landing": landing.metadata,
		"actual_live_node_resolved": true, "preview_attachment_count": 0,
		"replacement_mode": "wall_and_roof_replaced_once_without_generic_stack_or_fallback",
		"source_photography_shipped": false, "source_urls_in_runtime": false,
		"nonclaims": ["exact dimensions or pane count", "complete side schedule", "rear or private-side design", "interior", "as-built fidelity", "recognition or believability acceptance before independent review"],
	}
	if not _write_json(LIVE_OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write live Chapel still manifest.")
		return
	print("PASS: captured three actual-live grounded public frames plus a real stock-player roof landing; independent visual review remains pending")


func _capture_roof_landing(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, wall_record: Dictionary) -> Dictionary:
	var basis := _chain_basis(wall_record, [9, 10])
	if basis.is_empty():
		return {"ok": false, "message": "Could not derive the approved public chain."}
	var front := (basis.start as Vector3).lerp(basis.end as Vector3, 0.5)
	var tangent := basis.tangent as Vector3
	var outward := basis.normal as Vector3
	var roof_xz := front - outward * 5.0 - tangent * 4.5
	var query := PhysicsRayQueryParameters3D.create(Vector3(roof_xz.x, 40.0, roof_xz.z), Vector3(roof_xz.x, 0.0, roof_xz.z), WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return {"ok": false, "message": "Roof landing authority ray hit nothing."}
	var collider := hit.collider as StaticBody3D
	if collider == null or str(collider.get_meta("derived_object_key", "")) != ROOF_KEY \
	or str(collider.get_meta("receiver_kind", "invalid")) != "none" \
	or collider.is_in_group("spray_receiver_wall") or float((hit.position as Vector3).y) <= 14.04:
		return {"ok": false, "message": "Roof landing ray did not resolve the non-spray live roof body: %s." % hit}
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	player.global_transform = Transform3D(Basis.IDENTITY, Vector3(roof_xz.x, float(hit.position.y) + 6.0, roof_xz.z))
	player.velocity = Vector3.DOWN * 0.1
	player.force_update_transform()
	var recovery_before := int(world.get_runtime_evidence().recovery_count)
	var landed := false
	var saw_airborne := false
	var landing_frames := 0
	player.set_gameplay_enabled(true)
	for frame in 420:
		paused = false
		_clean_hud(hud)
		await physics_frame
		landing_frames = frame + 1
		if not player.is_on_floor():
			saw_airborne = true
		if saw_airborne and player.is_on_floor() and absf(player.velocity.y) <= 0.05:
			landed = true
			break
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	var landing_position := player.global_position
	var recovery_delta := int(world.get_runtime_evidence().recovery_count) - recovery_before
	var post_query := PhysicsRayQueryParameters3D.create(landing_position + Vector3.UP * 0.5, landing_position + Vector3.DOWN * 1.0, WORLD_SOLID_MASK, [player.get_rid()])
	post_query.collide_with_areas = false
	post_query.collide_with_bodies = true
	var post_hit := player.get_world_3d().direct_space_state.intersect_ray(post_query)
	if not landed or not saw_airborne or recovery_delta != 0 or absf(landing_position.y - float(hit.position.y)) > 0.08 \
	or post_hit.is_empty() or post_hit.collider != collider:
		return {"ok": false, "message": "Stock-player roof landing failed: landed=%s airborne=%s frames=%d recovery=%d clearance=%.3f post_hit=%s." % [landed, saw_airborne, landing_frames, recovery_delta, landing_position.y - float(hit.position.y), post_hit]}
	var cap_xz := front - outward * 8.5 + tangent * 0.7
	var cap_query := PhysicsRayQueryParameters3D.create(Vector3(cap_xz.x, 40.0, cap_xz.z), Vector3(cap_xz.x, 0.0, cap_xz.z), WORLD_SOLID_MASK, [player.get_rid()])
	cap_query.collide_with_areas = false
	cap_query.collide_with_bodies = true
	var cap_hit := player.get_world_3d().direct_space_state.intersect_ray(cap_query)
	if cap_hit.is_empty() or cap_hit.collider != collider or float((cap_hit.position as Vector3).y) <= 21.0 or float((cap_hit.normal as Vector3).y) <= 0.25:
		return {"ok": false, "message": "Belfry/cap landing authority ray failed: %s." % cap_hit}
	var aim_target := Vector3(front.x, maxf(10.0, float(hit.position.y) - 3.0), front.z)
	var aimed := _aim_stock_player_camera(player, aim_target)
	if not bool(aimed.get("ok", false)):
		return {"ok": false, "message": str(aimed.get("message", "Landing camera aim failed."))}
	var view := {"id": "04-stock-player-roof-landing", "role": "actual_live_stock_player_physics_landing_on_non_spray_roof", "lighting": "world_default"}
	var metadata := {
		"physics_grounded": true, "ordinary_player_rig": true,
		"landing_position_m": _vector3(landing_position), "roof_hit_position_m": _vector3(hit.position as Vector3),
		"roof_hit_normal": _vector3(hit.normal as Vector3), "roof_receiver": str(collider.get_meta("receiver_kind", "")),
		"roof_object_key": str(collider.get_meta("derived_object_key", "")), "roof_in_wall_spray_group": false,
		"landing_physics_frames": landing_frames, "saw_airborne_before_landing": saw_airborne,
		"landing_clearance_m": landing_position.y - float(hit.position.y), "post_landing_collider_is_same_roof_body": true,
		"cap_hit_position_m": _vector3(cap_hit.position as Vector3), "cap_hit_normal": _vector3(cap_hit.normal as Vector3),
		"recovery_delta": recovery_delta, "player_transform_writes_after_descent_began": 0,
		"camera_yaw_degrees": float(aimed.yaw_degrees), "camera_pitch_degrees": float(aimed.pitch_degrees),
	}
	var saved := await _save_live_image(main, player, hud, view, metadata)
	if not bool(saved.get("ok", false)):
		return saved
	var receipt := metadata.duplicate(true)
	receipt["capture"] = saved.metadata
	if not _write_json(LIVE_OUTPUT.path_join("roof-landing.json"), receipt):
		return {"ok": false, "message": "Could not write roof landing receipt."}
	return {"ok": true, "metadata": metadata, "capture": saved.metadata}


func _capture_motion(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary) -> void:
	if Engine.physics_ticks_per_second != LIVE_MOTION_HZ:
		_fail("Physics tick rate drifted from %d Hz." % LIVE_MOTION_HZ)
		return
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	var wall_record := _record_for_key(chunk.records as Array, WALL_KEY)
	var basis := _chain_basis(wall_record, [9, 10])
	if not _require(not basis.is_empty(), "Could not derive Chapel motion chain."):
		return
	var tangent := basis.tangent as Vector3
	var outward := basis.normal as Vector3
	var front := (basis.start as Vector3).lerp(basis.end as Vector3, 0.5)
	var start_wall := front - tangent * 8.0
	var requested := Vector2(start_wall.x + outward.x * 25.0, start_wall.z + outward.z * 25.0)
	var target := Vector3(start_wall.x, 9.0, start_wall.z)
	var view := {"id": "actual-live-public-motion-start", "requested_xz": requested, "aim_target": target, "expected_run_index": 9}
	var posed := await _settle_and_aim(world, player, hud, view)
	if not _require(bool(posed.get("ok", false)), str(posed.get("message", "Motion start pose failed."))):
		return
	var camera_rig := player.get_node("CameraPivot") as PlayerCamera
	var right_dot: float = camera_rig.planar_right().dot(tangent)
	if not _require(right_dot > 0.995, "Stock camera right axis does not follow the public chain: %.6f." % right_dot):
		return
	var recovery_before := int(world.get_runtime_evidence().recovery_count)
	var start_position := player.global_position
	var start_basis := player.get_camera().global_basis
	var samples: Array[Dictionary] = []
	var start_process_frame := Engine.get_process_frames()
	var start_physics_frame := Engine.get_physics_frames()
	player.set_gameplay_enabled(true)
	Input.action_press("move_right")
	for index in LIVE_MOTION_FRAMES:
		paused = false
		_clean_hud(hud)
		await physics_frame
		samples.append({"frame": index + 1, "player_position_m": _vector3(player.global_position), "velocity_mps": _vector3(player.velocity), "is_on_floor": player.is_on_floor()})
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
	var delta := end_position - start_position
	var horizontal := Vector3(delta.x, 0.0, delta.z)
	var displacement := horizontal.length()
	var direction_dot := horizontal.normalized().dot(tangent)
	var start_along := (start_position - front).dot(tangent)
	var end_along := (end_position - front).dot(tangent)
	var recovery_delta := int(world.get_runtime_evidence().recovery_count) - recovery_before
	if not _require(displacement >= 18.0 and displacement <= 22.0, "Stock walk displacement %.3f m escaped its 5 s envelope." % displacement) \
	or not _require(direction_dot > 0.995, "Stock walk direction diverged from the public chain: %.6f." % direction_dot) \
	or not _require(start_along < -7.0 and end_along > 10.0, "Stock walk did not traverse the public chain: %.3f -> %.3f." % [start_along, end_along]) \
	or not _require(recovery_delta == 0, "Stock walk triggered %d recoveries." % recovery_delta) \
	or not _require(start_basis.is_equal_approx(player.get_camera().global_basis), "Camera orientation changed during stock walk."):
		return
	var manifest := {
		"schema_version": "ti.navy-chapel-187-actual-live-motion-evidence/1",
		"review_status": "pending_independent_exact_current_live_review_not_self_accepted",
		"visual_verdict": "pending_independent_review",
		"generator": LIVE_GENERATOR.trim_prefix("res://"), "generator_sha256": FileAccess.get_sha256(LIVE_GENERATOR),
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(), "video_adapter": RenderingServer.get_video_adapter_name(),
		"movie_dimensions": [LIVE_MOTION_SIZE.x, LIVE_MOTION_SIZE.y], "movie_file": LIVE_MOTION_FILE,
		"movie_sha256": "pending_after_movie_writer_close", "movie_bytes": -1, "movie_finalized_after_writer_close": false,
		"fixed_fps": LIVE_FIXED_FPS, "physics_ticks_per_second": LIVE_MOTION_HZ,
		"motion_physics_frames": LIVE_MOTION_FRAMES, "continuous_duration_seconds": float(LIVE_MOTION_FRAMES) / LIVE_MOTION_HZ,
		"input_action": "move_right", "run_action_pressed": false,
		"configured_walk_speed_mps": player.walk_speed_mps,
		"review_motion_process_frame_range": [start_process_frame, input_end_process_frame],
		"review_motion_physics_frame_range": [start_physics_frame, input_end_physics_frame],
		"start_position_m": _vector3(start_position), "end_position_m": _vector3(end_position),
		"horizontal_displacement_m": displacement, "direction_dot_public_tangent": direction_dot,
		"start_along_public_chain_m": start_along, "end_along_public_chain_m": end_along,
		"player_transform_writes_after_input_began": 0, "camera_orientation_changed_during_motion": false,
		"all_samples_grounded": true, "recovery_delta": recovery_delta, "samples": samples,
		"bindings": bindings, "runtime_topology": LIVE_WORLD_TOPOLOGY.duplicate(true),
	}
	if not _write_json(LIVE_OUTPUT.path_join("motion-capture.json"), manifest):
		_fail("Could not write preliminary live Chapel motion manifest.")
		return
	print("PASS: drove a %.3f m, %.1f s continuous grounded stock-player walk across the actual-live Chapel public front; post-close movie seal pending" % [displacement, float(LIVE_MOTION_FRAMES) / LIVE_MOTION_HZ])


func _finalize_motion() -> void:
	var expected_hash := _argument_value("--movie-sha256=")
	var expected_bytes := int(_argument_value("--movie-bytes="))
	var movie_path := LIVE_OUTPUT.path_join(LIVE_MOTION_FILE)
	var manifest_path := LIVE_OUTPUT.path_join("motion-capture.json")
	var manifest_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if not _require(manifest_value is Dictionary, "Motion manifest did not parse for finalization."):
		return
	var manifest := manifest_value as Dictionary
	if not _require(expected_hash.length() == 64 and expected_hash == FileAccess.get_sha256(movie_path), "Movie finalizer received an incorrect SHA-256.") \
	or not _require(expected_bytes > 0 and expected_bytes == FileAccess.get_file_as_bytes(movie_path).size(), "Movie finalizer received an incorrect byte count.") \
	or not _require(str(manifest.get("movie_sha256", "")) == "pending_after_movie_writer_close", "Motion manifest was not in its one-time post-close state."):
		return
	manifest.movie_sha256 = expected_hash
	manifest.movie_bytes = expected_bytes
	manifest.movie_finalized_after_writer_close = true
	manifest.finalizer = "post-MovieWriter-close exact SHA-256 and byte-count seal"
	if not _write_json(manifest_path, manifest):
		_fail("Could not finalize live Chapel motion manifest.")
		return
	print("PASS: finalized actual-live Chapel movie sha256=%s bytes=%d" % [expected_hash, expected_bytes])


func _save_live_image(main: GameMain, player: PlayerController, hud: GameHUD, view: Dictionary, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s did not stabilize." % str(view.id)}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != LIVE_STILL_SIZE:
		return {"ok": false, "message": "%s returned an empty or wrong-sized image." % str(view.id)}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s appears blank." % str(view.id)}
	var relative := "images/%s.png" % str(view.id)
	var path := LIVE_OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save." % str(view.id)}
	var metadata := {
		"id": str(view.id), "role": str(view.role), "lighting": str(view.lighting),
		"file": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [image.get_width(), image.get_height()], "sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range), "debug_labels_visible": false,
		"source_photography_in_frame": false, "crop_or_postprocess": false,
		"actual_live_node": true, "preview_attachment_count": 0, "visual_verdict": "pending_independent_review",
	}
	metadata.merge(extra, true)
	print("NAVY_CHAPEL_187_ACTUAL_LIVE_CAPTURE: id=%s image=%s sha256=%s" % [view.id, ProjectSettings.globalize_path(path), metadata.sha256])
	return {"ok": true, "metadata": metadata}


func _chain_basis(record: Dictionary, runs: Array) -> Dictionary:
	var values := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	if runs.is_empty() or values.size() < 12 * 34 or normals.size() < 12 * 34:
		return {}
	var first_offset := int(runs[0]) * 12
	var last_offset := int(runs[runs.size() - 1]) * 12
	var start := Vector3(float(values[first_offset]), float(values[first_offset + 1]), float(values[first_offset + 2]))
	var end := Vector3(float(values[last_offset + 3]), float(values[last_offset + 4]), float(values[last_offset + 5]))
	var tangent := end - start
	tangent.y = 0.0
	var normal := Vector3(float(normals[first_offset]), 0.0, float(normals[first_offset + 2])).normalized()
	return {"start": start, "end": end, "tangent": tangent.normalized(), "normal": normal}


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
