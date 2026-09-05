extends "res://game/tests/isle_house_low_live_evidence_capture.gd"

## Fresh actual-live B201 evidence only. This harness resolves the production
## receiver from main.tscn; it never instantiates or attaches the standalone
## prototype. Every capture remains pending independent visual/package review.

const B201_OUTPUT := "res://evidence/first-playable/d1-b201-live-attachment-2026-09-04"
const B201_GENERATOR := "res://game/tests/d1_b201_live_attachment_capture.gd"
const B201_PARENT_HARNESS := "res://game/tests/isle_house_low_live_evidence_capture.gd"
const B201_CAPTURE_OVERRIDE := "res://override.cfg"
const B201_CAPTURE_OVERRIDE_SHA256 := "edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3"
const B201_ADAPTER_PATH := "res://game/scripts/world/facades/d1_b201_live_attachment.gd"
const B201_CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b201_live_attachment.json"
const B201_BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const B201_CHUNK_PATH := "res://generated/world/chunks/x_0__z_-2.json"
const B201_RECEIVER_KEY := "building:w34313545:wall"
const B201_ROOF_KEY := "building:w34313545:roof"
const B201_SOURCE_KEY := "w34313545"
const B201_SIGNATURE := "705c5345509f77cd91359f66173fff0e1e132d41ebb9acef3f51ff2c467abb3a"
const B201_CONFIG_SHA256 := "0f3bf052688ec813b5fa58b077d74c963949574623fe4cf67c12c347e7257229"
const B201_ADAPTER_SHA256 := "499f6d2657b593ee5b0801cf1205a2925a993f3b1836922d3656a6d00c51cc19"
const B201_BUILDER_SHA256 := "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c"
const B201_REGISTRY_SHA256 := "65edf085437bc3fa2b22869406cc8a2c33297b6cc9d48b205e301e367efc734b"
const B201_CATALOG_SHA256 := "ab8797e86d5985c4b64670a22577394656c6388bb463f83c157a411663fa7b57"
const B201_WORLD_TOPOLOGY := {"rows": 735, "meshes": 950, "surfaces": 964, "triangles": 66636, "bodies": 466, "shapes": 466}
const B201_DEFAULT_SUN := Vector3(-52.0, -28.0, 0.0)
const B201_CHANGED_SUN := Vector3(-32.0, 132.0, 0.0)
const B201_CHAIN_START := Vector3(37.010, 0.0, -304.375)
const B201_CHAIN_END := Vector3(91.554, 0.0, -202.551)
const B201_CHAIN_MID := Vector3(64.282, 0.0, -253.463)
const B201_TANGENT := Vector3(0.472190662, 0.0, 0.881496443)
const B201_OUTWARD := Vector3(-0.881496443, 0.0, 0.472190662)
const B201_MOTION_FRAMES := 360
const B201_MOTION_HZ := 60
const B201_FIXED_FPS := 30
const B201_MOTION_FILE := "b201-actual-live-normal-forward-approach.avi"
const B201_MOTION_PENDING_FILE := "b201-actual-live-normal-forward-approach.pending.avi"
const B201_MOTION_PRELIMINARY_FILE := "motion-capture.json"
const B201_MOTION_SEAL_FILE := "motion-seal.json"
const B201_SPRAY_MASK := 1 << 2
const B201_STILL_FILES := [
	"01-whole-wsw-default.png",
	"02-whole-wsw-changed-light.png",
	"03-whole-wsw-default-grayscale.png",
	"04-wsw-hierarchy-oblique.png",
	"05-close-sprayed-host.png",
]

const B201_DEPENDENCY_HASHES := {
	"res://game/scenes/main.tscn": "959a0f8a14057ea8402790ba374c7839d5f9835ce20ad194846f0a4d45b43d66",
	"res://project.godot": "305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af",
	B201_PARENT_HARNESS: "47768e4b2d6288b9c3dbb4b0ad19cd870b61a8804d72673c53bf3326f8f5636a",
	"res://game/scripts/main.gd": "d948c8e4900ac88cfe4d40a701eedbbe2070df42c2414e39f2e9b8112d92620f",
	"res://game/scripts/world/world_loader.gd": "0bfb5c64ede051dadd87da10e85518a2c22c63d36ff9387e8221bdd0c24287af",
	"res://game/scripts/world/facades/facade_runtime_registry_loader.gd": "4c9af1ffcf5724e8c35e4b591a85697f1667f8d120af41a74fac511bfcb4f356",
	"res://game/scripts/world/facades/facade_meter_uv_adapter.gd": "47e710b9ea7c5de5122430199e4105cbba5f672d22f59832f13b8004f16c5a1d",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	B201_BUILDER_PATH: B201_BUILDER_SHA256,
	B201_ADAPTER_PATH: B201_ADAPTER_SHA256,
	B201_CONFIG_PATH: B201_CONFIG_SHA256,
	B201_CHUNK_PATH: "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://game/scripts/player/player_controller.gd": "8b114132d66c78dd0bfd09783c7b9a3a3a441a8b1ae14f33f7308bd9b04ed0ea",
	"res://game/scripts/player/player_camera.gd": "90ea739b25eb6cbcf8bacff072599b117fe894fcef08683483e41527d8019636",
	"res://game/scenes/player/player.tscn": "a37b00ecc620b4f3106a14d1dc9ec22a519f81481e5e6c68252389e13488a793",
	"res://game/scripts/interaction/spray_controller.gd": "9897042fbffc6740ebe3eb4c19da544a0d437391ded9987318edc7238c403da4",
	"res://game/scripts/interaction/tag_instance_pool.gd": "2460b12b9f70945dc88d2e321b72c1779dab4d867fd80f5920f4734213ce0950",
	"res://game/resources/textures/tag/predefined_tag.svg": "9eb345572cd3298ea14bad008fc6405e46123c0243444e4582393d0aa84af885",
	"res://game/resources/materials/world/d1_current/b201_warm_wall.tres": "6f5f6835790ab338454e72be58c2956deb6e470086797e209be0fab4d37ec788",
	"res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres": "5bdd67e659a0cce14abe3605f5a7fbfd85b0374d0a38be23cda326017235fe13",
	"res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres": "be97cdfd7367cd73172c4429ca212db0d1fc68bed34f4db6ce307d02a5225b94",
	"res://game/resources/materials/world/d1_current/b201_service_leaf.tres": "de9895a808e4d64afc2c727e77ef92b590c9c718266ba118e64c489e84690cfd",
	"res://game/resources/materials/world/d1_current/shared_dark_glass.tres": "ad8931db8954fd5ebc8fdd809f70afb279dd74a36e53e1d9ca907c44409f10d3",
	"res://game/resources/materials/world/d1_current/shared_pale_frame.tres": "9a2de298ff545cf80c5da0ed0aa37d9d4ebbf10fec8eb78810af7e4d012d1436",
	"res://game/resources/facades/facade-runtime-registry.json": B201_REGISTRY_SHA256,
	"res://discovery/facades/facade-recognition-catalog.json": B201_CATALOG_SHA256,
	"res://discovery/facades/d1_reference_packets/w34313545_building_201.md": "c6fba23d80e95b23c4f3eb172a252baa47767b7a29757096bff329c693db9e5e",
	"res://discovery/facades/PRECOMMIT_PACKAGE_SANITIZATION_SOURCE_PROVENANCE.json": "269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333",
	"res://evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md": "8567cd5eb9080f8f7cb563152ae83885330d366cc56ecc8513d5ebdadf491feb",
}

const B201_VIEWS := [
	{
		"id": "01-whole-wsw-default",
		"role": "grounded_stock_player_actual_live_whole_wsw_default",
		"requested_xz": Vector2(-8.000708, -214.743366),
		"aim_target": Vector3(64.282, 5.8, -253.463),
		"minimum_actual_spring_m": 4.5,
	},
	{
		"id": "04-wsw-hierarchy-oblique",
		"role": "grounded_stock_player_actual_live_wsw_hierarchy_oblique",
		"requested_xz": Vector2(11.581976, -250.190770),
		"aim_target": Vector3(53.893805, 5.8, -272.855922),
		"minimum_actual_spring_m": 3.5,
	},
]


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	var mode := _argument_value("--capture-mode=")
	if mode not in ["preflight", "stills", "motion", "finalize-motion"]:
		_fail("Pass exactly --capture-mode=preflight, stills, motion, or finalize-motion.")
		_finish(null)
		return
	if not _require(_generator_authority_matches(), "Pass the independently frozen current harness SHA with --generator-sha256=.") \
	or not _require(_capture_override_matches(), "The temporary 1440x900 capture override is absent or drifted.") \
	or not _require(_dependencies_match(), "B201 capture dependency closure drifted.") \
	or not _require(_output_state_allows(mode), "B201 evidence output state would overwrite or mix a capture stage."):
		_finish(null)
		return
	if DisplayServer.get_name() != "macOS" or not _native_invocation_matches(mode):
		_fail("B201 evidence requires the exact native macOS Forward+/Metal 1440x900 invocation for this stage.")
		_finish(null)
		return
	if mode == "finalize-motion":
		_finalize_b201_motion()
		_finish(null)
		return
	var loaded := await _load_b201_main(mode)
	if not _require(bool(loaded.get("ok", false)), str(loaded.get("message", "B201 main load failed."))):
		_finish(loaded.get("main", null) as Node)
		return
	var main := loaded.main as GameMain
	var world := loaded.world as WorldLoader
	var player := loaded.player as PlayerController
	var hud := loaded.hud as GameHUD
	var sun := loaded.sun as DirectionalLight3D
	var bindings := loaded.bindings as Dictionary
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	if mode == "preflight":
		await _preflight_poses(main, world, player, hud, sun)
	elif mode == "stills":
		await _capture_b201_stills(main, world, player, hud, sun, bindings)
	else:
		await _capture_b201_motion(main, world, player, hud, sun, bindings)
	_finish(main)


func _load_b201_main(mode: String) -> Dictionary:
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
		return {"ok": false, "message": "%s did not reach one clean world_ready: %s" % [mode, failures], "main": main}
	while not player.was_first_reveal_grounded() and Time.get_ticks_msec() - started < 60000:
		await physics_frame
	if not player.was_first_reveal_grounded() or not player.visible:
		return {"ok": false, "message": "%s stock player did not complete startup settlement." % mode, "main": main}
	var evidence := world.get_runtime_evidence()
	var topology := {"rows": evidence.playable_rows, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "bodies": evidence.static_bodies, "shapes": evidence.shapes}
	if topology != B201_WORLD_TOPOLOGY:
		return {"ok": false, "message": "B201 actual-live topology drifted: %s" % topology, "main": main}
	if str(ready[0].get("content_sha256", "")) != EXPECTED_CONTENT_SHA256 or not _registry_is_frozen_pending():
		return {"ok": false, "message": "Generated content identity or frozen 6/213 registry state drifted.", "main": main}
	var bindings := _validate_b201_bindings(world)
	if not bool(bindings.get("ok", false)):
		return {"ok": false, "message": str(bindings.get("message", "B201 live binding failed.")), "main": main}
	return {"ok": true, "main": main, "world": world, "player": player, "hud": hud, "sun": sun, "bindings": bindings.metadata}


func _validate_b201_bindings(world: WorldLoader) -> Dictionary:
	var walls := _record_nodes(world, B201_RECEIVER_KEY)
	var roofs := _record_nodes(world, B201_ROOF_KEY)
	if walls.size() != 1 or roofs.size() != 1:
		return {"ok": false, "message": "Expected one exact B201 wall/roof root, got %d/%d." % [walls.size(), roofs.size()]}
	var wall := walls[0]
	var roof := roofs[0]
	var attachment := wall.get_node_or_null("D1B201LiveAttachment") as Node3D
	var mesh_instance := wall.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := wall.get_node_or_null("Collision") as StaticBody3D
	var shape_node := wall.get_node_or_null("Collision/Shape") as CollisionShape3D
	if attachment == null or mesh == null or body == null or shape_node == null \
	or mesh.get_surface_count() != 2 \
	or int(((mesh.surface_get_arrays(0) as Array)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3) != 60 \
	or int(((mesh.surface_get_arrays(1) as Array)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3) != 20 \
	or mesh.surface_get_material(0).resource_name != "building_wall" \
	or mesh.surface_get_material(1).resource_path != "res://game/resources/materials/world/d1_current/b201_warm_wall.tres" \
	or str(attachment.get_meta("decorative_geometry_signature", "")) != B201_SIGNATURE \
	or bool(attachment.get_meta("reference_recognizable", true)) \
	or _count_type(wall, StaticBody3D) != 1 or _count_type(wall, CollisionShape3D) != 1 \
	or _count_type(attachment, CollisionObject3D) != 0 or _count_type(attachment, CollisionShape3D) != 0 \
	or _count_type(attachment, NavigationRegion3D) != 0 or _count_type(attachment, Decal) != 0 \
	or not body.is_in_group("spray_receiver_wall") \
	or body.collision_layer != ((1 << 0) | (1 << 2)) or body.collision_mask != 0 \
	or str(body.get_meta("derived_object_key", "")) != B201_RECEIVER_KEY \
	or body.get_meta("source_keys", []) != [B201_SOURCE_KEY]:
		return {"ok": false, "message": "B201 host partition, detail signature, or sole ownership drifted."}
	if roof.get_node_or_null("D1B201LiveAttachment") != null or _count_type(roof, MeshInstance3D) != 1 \
	or _count_type(roof, StaticBody3D) != 1 or _count_type(roof, CollisionShape3D) != 1:
		return {"ok": false, "message": "Protected B201 roof was altered by the live attachment."}
	var preview_count := 0
	for node: Node in world.find_children("*", "Node", true, false):
		if bool(node.get_meta("capture_only_replacement", false)) or str(node.name).contains("CaptureOnly"):
			preview_count += 1
	if preview_count != 0:
		return {"ok": false, "message": "Capture-only preview geometry is attached to the actual world."}
	return {"ok": true, "metadata": {
		"wall_root_path": str(wall.get_path()), "roof_root_path": str(roof.get_path()),
		"attachment_path": str(attachment.get_path()), "wall_body_path": str(body.get_path()),
		"source_keys": wall.get_meta("source_keys", []), "decorative_geometry_signature": B201_SIGNATURE,
		"host_triangles": 80, "eligible_warm_triangles": 20, "protected_generic_triangles": 60,
		"decorative_batches": 6, "decorative_boxes": 172, "decorative_triangles": 2064,
		"structural_body_count": 1, "structural_shape_count": 1, "spray_owner_count": 1,
		"navigation_owner_count": 0, "preview_attachment_count": 0,
		"recognition_accepted": false, "recognition_metric": "6/213",
	}}


func _preflight_poses(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D) -> void:
	if not _require(Vector2i(root.get_texture().get_size()) == STILL_SIZE, "Native preflight viewport is not 1440x900.") \
	or not _require(sun.rotation_degrees.is_equal_approx(B201_DEFAULT_SUN), "Default sun drifted before B201 preflight."):
		return
	var record := _b201_wall_record()
	for value: Variant in B201_VIEWS:
		var view := value as Dictionary
		var pose := await _settle_and_aim(world, player, hud, view.requested_xz as Vector2, view.aim_target as Vector3, str(view.id), float(view.minimum_actual_spring_m))
		if not _require(bool(pose.get("ok", false)), str(pose.get("message", "%s pose failed." % str(view.id)))):
			return
		var los := _center_los(player, view.aim_target as Vector3, B201_RECEIVER_KEY, [B201_SOURCE_KEY], str(view.id))
		if not _require(bool(los.get("ok", false)), str(los.get("message", "%s LOS failed." % str(view.id)))):
			return
		if str(view.id) == "01-whole-wsw-default" and not _require(_whole_wsw_projection(player.get_camera(), record).get("ok", false), "Whole WSW pose does not contain the complete public chain."):
			return
	var spray_target := _chain_point(15.0, 5.1)
	var spray_pose := await _settle_and_aim(world, player, hud, Vector2(67.398126, -238.115695), spray_target, "05-close-sprayed-host", 2.5)
	if not _require(bool(spray_pose.get("ok", false)), str(spray_pose.get("message", "Spray pose failed."))) \
	or not _require(_camera_hit_matches(player), "Spray preflight did not hit the exact retained B201 host first."):
		return
	var motion_pose := await _settle_and_aim(world, player, hud, Vector2(18.444185, -228.909086), Vector3(64.282, 5.8, -253.463), "normal-forward-motion-start", 4.0)
	if not _require(bool(motion_pose.get("ok", false)), str(motion_pose.get("message", "Motion pose failed."))):
		return
	print("PASS: B201 no-write capture preflight resolved grounded whole, oblique, spray, and normal-forward motion poses at 1440x900 on the actual live receiver")


func _capture_b201_stills(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary) -> void:
	if not _require(Vector2i(root.get_texture().get_size()) == STILL_SIZE, "B201 still viewport is not exactly 1440x900.") \
	or not _require(sun.rotation_degrees.is_equal_approx(B201_DEFAULT_SUN), "Default sun drifted before B201 still capture."):
		return
	var absolute := ProjectSettings.globalize_path(B201_OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(absolute.path_join("images")) == OK, "Could not create fresh B201 evidence root."):
		return
	var record := _b201_wall_record()
	var captures: Array[Dictionary] = []
	var whole := B201_VIEWS[0] as Dictionary
	var pose := await _settle_and_aim(world, player, hud, whole.requested_xz as Vector2, whole.aim_target as Vector3, str(whole.id), float(whole.minimum_actual_spring_m))
	if not _require(bool(pose.get("ok", false)), str(pose.get("message", "Whole pose failed."))):
		return
	var los := _center_los(player, whole.aim_target as Vector3, B201_RECEIVER_KEY, [B201_SOURCE_KEY], str(whole.id))
	var projection := _whole_wsw_projection(player.get_camera(), record)
	if not _require(bool(los.get("ok", false)) and bool(projection.get("ok", false)), "Whole WSW LOS or complete-chain projection failed."):
		return
	var extra := pose.metadata as Dictionary
	extra.merge(los.metadata as Dictionary, true)
	extra["whole_wsw_projection"] = projection
	extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
	var saved := await _save_b201_still(main, player, hud, "01-whole-wsw-default", str(whole.role), "world_default", extra)
	if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Whole default save failed."))):
		return
	captures.append(saved.metadata)
	var frozen_player := player.global_transform
	var frozen_camera := player.get_camera().global_transform
	sun.rotation_degrees = B201_CHANGED_SUN
	var changed_extra := extra.duplicate(true)
	changed_extra["same_pose_as"] = "01-whole-wsw-default"
	changed_extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
	changed_extra["player_transform_exactly_reused"] = player.global_transform.is_equal_approx(frozen_player)
	changed_extra["camera_transform_exactly_reused"] = player.get_camera().global_transform.is_equal_approx(frozen_camera)
	if not _require(bool(changed_extra.player_transform_exactly_reused) and bool(changed_extra.camera_transform_exactly_reused), "Changed light moved the stock-player pose."):
		return
	saved = await _save_b201_still(main, player, hud, "02-whole-wsw-changed-light", "same_grounded_stock_player_pose_changed_light", "frozen_changed_light", changed_extra)
	if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Changed-light save failed."))):
		return
	captures.append(saved.metadata)
	var grayscale := _save_grayscale("images/01-whole-wsw-default.png", "images/03-whole-wsw-default-grayscale.png")
	if not _require(bool(grayscale.get("ok", false)), str(grayscale.get("message", "Grayscale derivation failed."))):
		return
	captures.append(grayscale.metadata)
	sun.rotation_degrees = B201_DEFAULT_SUN
	var oblique := B201_VIEWS[1] as Dictionary
	pose = await _settle_and_aim(world, player, hud, oblique.requested_xz as Vector2, oblique.aim_target as Vector3, str(oblique.id), float(oblique.minimum_actual_spring_m))
	if not _require(bool(pose.get("ok", false)), str(pose.get("message", "Oblique pose failed."))):
		return
	los = _center_los(player, oblique.aim_target as Vector3, B201_RECEIVER_KEY, [B201_SOURCE_KEY], str(oblique.id))
	if not _require(bool(los.get("ok", false)), str(los.get("message", "Oblique LOS failed."))):
		return
	extra = pose.metadata as Dictionary
	extra.merge(los.metadata as Dictionary, true)
	extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
	saved = await _save_b201_still(main, player, hud, "04-wsw-hierarchy-oblique", str(oblique.role), "world_default", extra)
	if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Oblique save failed."))):
		return
	captures.append(saved.metadata)
	var spray := await _capture_visible_spray(main, world, player, hud)
	if not _require(bool(spray.get("ok", false)), str(spray.get("message", "Visible spray capture failed."))):
		return
	captures.append(spray.metadata)
	var manifest := {
		"schema_version": "ti.d1-b201-actual-live-evidence/1",
		"review_status": "pending_independent_live_visual_static_and_package_review_not_self_accepted",
		"recognition_status": "pending_independent_review",
		"recognition_metric_frozen": "6/213",
		"generator": B201_GENERATOR.trim_prefix("res://"), "generator_sha256": FileAccess.get_sha256(B201_GENERATOR),
		"frozen_generator_sha256_argument": _argument_value("--generator-sha256="),
		"parent_harness": B201_PARENT_HARNESS.trim_prefix("res://"), "parent_harness_sha256": FileAccess.get_sha256(B201_PARENT_HARNESS),
		"capture_override_sha256": FileAccess.get_sha256(B201_CAPTURE_OVERRIDE),
		"engine_invocation_arguments": OS.get_cmdline_args(), "user_invocation_arguments": OS.get_cmdline_user_args(),
		"runtime_environment": _runtime_environment_receipt(),
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"rendering_driver": "Metal", "rendering_method": "Forward+", "video_adapter": RenderingServer.get_video_adapter_name(),
		"viewport": [STILL_SIZE.x, STILL_SIZE.y], "camera_fov_degrees": 70.0, "configured_spring_length_m": 5.5,
		"runtime_topology": B201_WORLD_TOPOLOGY.duplicate(true), "bindings": bindings,
		"source_dependency_hashes": B201_DEPENDENCY_HASHES.duplicate(true),
		"captures": captures, "capture_count": captures.size(),
		"actual_live_node_resolved": true, "preview_or_standalone_attachment_count": 0,
		"pose_method_disclosure": "after real startup grounding, the harness performs one pre-capture player transform placement and input-reachable PlayerCamera yaw/pitch rotation per distinct pose, then physics-settles; it performs no pose transform writes while saving a still",
		"grayscale_derivation": "lossless default PNG reload, Image FORMAT_L8 conversion, PNG save; no crop, relight, or geometry change",
		"visible_spray": spray.spray,
		"source_photography_shipped": false, "source_urls_in_runtime": false,
		"visual_verdict": "pending_independent_review",
		"nonclaims": ["exact opening count, width, cadence or glazing transparency", "exact canopy dimensions or endpoints", "service ENE/SSE/NNW/short/corner/return geometry", "roof geometry", "interior", "as-built fidelity", "recognition credit before independent live review"],
	}
	if not _write_new_json(B201_OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write B201 still manifest.")
		return
	print("PASS: captured five fresh actual-live B201 still artifacts (whole default/changed-light/grayscale, oblique, visible real-controller spray) at 1440x900; recognition remains pending at 6/213")


func _capture_visible_spray(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD) -> Dictionary:
	var target := _chain_point(15.0, 5.1)
	var pose := await _settle_and_aim(world, player, hud, Vector2(67.398126, -238.115695), target, "05-close-sprayed-host", 2.5)
	if not bool(pose.get("ok", false)):
		return pose
	var hit := _camera_spray_hit(player)
	var collider := hit.get("collider", null) as CollisionObject3D
	var body := _record_nodes(world, B201_RECEIVER_KEY)[0].get_node("Collision") as StaticBody3D
	if hit.is_empty() or collider != body or not body.is_in_group("spray_receiver_wall") \
	or str(body.get_meta("derived_object_key", "")) != B201_RECEIVER_KEY \
	or body.get_meta("source_keys", []) != [B201_SOURCE_KEY] \
	or player.global_position.distance_to(hit.position as Vector3) > player.get_spray_controller().maximum_range_m:
		return {"ok": false, "message": "Spray ray did not first-hit the sole retained B201 host in range."}
	var controller := player.get_spray_controller()
	var pool := controller.tag_instances
	var active_before := pool.active_count()
	var placed_before := int((world.get_runtime_evidence().spray_counts as Dictionary).placed)
	var before_image := root.get_texture().get_image()
	if before_image == null or before_image.is_empty() or before_image.get_size() != STILL_SIZE:
		return {"ok": false, "message": "Could not retain the exact pre-spray render for pixel proof."}
	var before_png_sha256 := _sha256_bytes(before_image.save_png_to_buffer())
	controller.attempt_spray()
	await process_frame
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "Sprayed B201 view did not stabilize."}
	if pool.active_count() != active_before + 1 or int((world.get_runtime_evidence().spray_counts as Dictionary).placed) != placed_before + 1:
		return {"ok": false, "message": "Real SprayController did not place exactly one B201 tag."}
	var latest := pool.get_child(pool.get_child_count() - 1)
	if not (latest is Decal):
		return {"ok": false, "message": "The real SprayController did not append a Decal instance."}
	var tag := latest as Decal
	var wall := _record_nodes(world, B201_RECEIVER_KEY)[0]
	var attachment := wall.get_node("D1B201LiveAttachment") as Node3D
	var local_tag := attachment.to_local(tag.global_position)
	var camera := player.get_camera()
	var pixel := camera.unproject_position(tag.global_position)
	var viewport := camera.get_viewport().get_visible_rect()
	var after_image := root.get_texture().get_image()
	var pixel_delta := _pixel_patch_delta(before_image, after_image, pixel)
	if not tag.is_visible_in_tree() or tag.texture_albedo == null or tag.cull_mask != (1 << 1) \
	or str(tag.get_meta("derived_object_key", "")) != B201_RECEIVER_KEY or tag.get_meta("source_keys", []) != [B201_SOURCE_KEY] \
	or tag.global_position.distance_to(hit.position as Vector3) > 0.05 or camera.is_position_behind(tag.global_position) \
	or not viewport.has_point(pixel) or not _tag_is_clear_of_authored_detail(local_tag) \
	or not bool(pixel_delta.get("ok", false)):
		return {"ok": false, "message": "Placed B201 tag identity, visibility, projection, or unobstructed host position failed."}
	var extra := pose.metadata as Dictionary
	extra.merge({
		"spray_result": "placed", "spray_first_hit_object": B201_RECEIVER_KEY, "spray_first_hit_sources": [B201_SOURCE_KEY],
		"spray_first_hit_position_m": _vector3(hit.position as Vector3), "spray_first_hit_normal": _vector3(hit.normal as Vector3),
		"tag_position_m": _vector3(tag.global_position), "tag_local_to_attachment_m": _vector3(local_tag),
		"tag_projected_pixel": [pixel.x, pixel.y], "tag_visible_in_tree": true, "tag_clear_of_decorative_bounds": true,
		"tag_cull_mask": tag.cull_mask, "tag_player_distance_m": player.global_position.distance_to(hit.position as Vector3),
		"tag_texture_path": "res://game/resources/textures/tag/predefined_tag.svg",
		"tag_texture_source_sha256": B201_DEPENDENCY_HASHES["res://game/resources/textures/tag/predefined_tag.svg"],
		"pre_spray_render_png_buffer_sha256": before_png_sha256,
		"post_spray_render_png_buffer_sha256": _sha256_bytes(after_image.save_png_to_buffer()),
		"rendered_tag_pixel_delta": pixel_delta,
		"sole_host_collider": true, "sun_rotation_degrees": _vector3(B201_DEFAULT_SUN),
	}, true)
	var saved := await _save_b201_still(main, player, hud, "05-close-sprayed-host", "grounded_stock_player_real_spray_on_retained_eligible_host", "world_default", extra)
	if not bool(saved.get("ok", false)):
		return saved
	return {"ok": true, "metadata": saved.metadata, "spray": extra}


func _capture_b201_motion(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary) -> void:
	if Engine.physics_ticks_per_second != B201_MOTION_HZ \
	or Vector2i(root.get_texture().get_size()) != STILL_SIZE:
		_fail("Motion physics or exact 1440x900 render viewport drifted.")
		return
	sun.rotation_degrees = B201_DEFAULT_SUN
	var target := Vector3(64.282, 5.8, -253.463)
	var pose := await _settle_and_aim(world, player, hud, Vector2(18.444185, -228.909086), target, "normal-forward-motion-start", 4.0)
	if not _require(bool(pose.get("ok", false)), str(pose.get("message", "Motion start pose failed."))):
		return
	var los := _center_los(player, target, B201_RECEIVER_KEY, [B201_SOURCE_KEY], "normal-forward-motion-start")
	if not _require(bool(los.get("ok", false)), str(los.get("message", "Motion start LOS failed."))):
		return
	_clear_input()
	var recoveries_before := world.get_runtime_evidence().recovery_count
	var start_position := player.global_position
	var start_camera_basis := player.get_camera().global_basis
	var start_process_frame := Engine.get_process_frames()
	var start_physics_frame := Engine.get_physics_frames()
	var start_distance := (start_position - B201_CHAIN_MID).dot(B201_OUTWARD)
	var samples: Array[Dictionary] = []
	player.set_gameplay_enabled(true)
	Input.action_press("move_forward")
	for frame_index in B201_MOTION_FRAMES:
		paused = false
		_clean_hud(hud)
		await physics_frame
		var position := player.global_position
		var hit := _camera_spray_hit(player)
		var collider := hit.get("collider", null) as CollisionObject3D
		if not player.is_on_floor() or not world.get_boundary().contains_position(position) \
		or not Input.is_action_pressed("move_forward") or Input.is_action_pressed("run") \
		or Input.is_action_pressed("jetpack") or Input.is_action_pressed("recover") \
		or not start_camera_basis.is_equal_approx(player.get_camera().global_basis) \
		or world.get_runtime_evidence().recovery_count != recoveries_before \
		or collider == null or str(collider.get_meta("derived_object_key", "")) != B201_RECEIVER_KEY:
			Input.action_release("move_forward")
			player.set_gameplay_enabled(false)
			_fail("B201 continuous motion contract failed at physics frame %d." % (frame_index + 1))
			return
		samples.append({
			"frame": frame_index + 1, "player_position_m": _vector3(position), "velocity_mps": _vector3(player.velocity),
			"is_on_floor": true, "in_boundary": true, "camera_basis_unchanged": true,
			"center_first_hit_object": B201_RECEIVER_KEY, "center_first_hit_sources": collider.get_meta("source_keys", []),
			"outward_distance_from_chain_mid_m": (position - B201_CHAIN_MID).dot(B201_OUTWARD),
		})
	var input_end_process_frame := Engine.get_process_frames()
	var input_end_physics_frame := Engine.get_physics_frames()
	Input.action_release("move_forward")
	for _frame in 12:
		await physics_frame
	player.set_gameplay_enabled(false)
	var end_position := player.global_position
	var end_distance := (end_position - B201_CHAIN_MID).dot(B201_OUTWARD)
	var displacement := Vector2(end_position.x - start_position.x, end_position.z - start_position.z).length()
	var direction := Vector3(end_position.x - start_position.x, 0.0, end_position.z - start_position.z).normalized()
	if not _require(displacement >= 22.0 and displacement <= 26.5, "B201 stock approach displacement %.3f m escaped its 6 s envelope." % displacement) \
	or not _require(start_distance > 48.0 and end_distance < 30.0 and start_distance - end_distance > 21.0, "B201 stock approach did not materially close on the facade: %.3f -> %.3f." % [start_distance, end_distance]) \
	or not _require(direction.dot(-B201_OUTWARD) > 0.995, "B201 stock forward direction diverged from the facade normal.") \
	or not _require(samples.size() == B201_MOTION_FRAMES and world.get_runtime_evidence().recovery_count == recoveries_before, "B201 motion sample/recovery closure drifted."):
		return
	var manifest := {
		"schema_version": "ti.d1-b201-actual-live-motion-evidence/1",
		"review_status": "pending_independent_live_visual_static_and_package_review_not_self_accepted",
		"generator": B201_GENERATOR.trim_prefix("res://"), "generator_sha256": FileAccess.get_sha256(B201_GENERATOR),
		"frozen_generator_sha256_argument": _argument_value("--generator-sha256="),
		"parent_harness": B201_PARENT_HARNESS.trim_prefix("res://"), "parent_harness_sha256": FileAccess.get_sha256(B201_PARENT_HARNESS),
		"capture_override_sha256": FileAccess.get_sha256(B201_CAPTURE_OVERRIDE),
		"engine_invocation_arguments": OS.get_cmdline_args(), "user_invocation_arguments": OS.get_cmdline_user_args(),
		"runtime_environment": _runtime_environment_receipt(),
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(), "video_adapter": RenderingServer.get_video_adapter_name(),
		"movie_file": B201_MOTION_FILE, "pending_movie_file": B201_MOTION_PENDING_FILE,
		"movie_sha256": "sealed_separately_after_movie_writer_close", "movie_bytes": -1, "movie_finalized_after_writer_close": false,
		"render_viewport": [root.get_texture().get_width(), root.get_texture().get_height()], "fixed_fps": B201_FIXED_FPS, "physics_ticks_per_second": B201_MOTION_HZ,
		"review_motion_process_frame_range": [start_process_frame, input_end_process_frame], "review_motion_physics_frame_range": [start_physics_frame, input_end_physics_frame],
		"motion_physics_frames": B201_MOTION_FRAMES, "continuous_duration_seconds": float(B201_MOTION_FRAMES) / B201_MOTION_HZ,
		"input_action": "move_forward", "run_action_pressed": false, "jetpack_action_pressed": false, "recovery_action_pressed": false,
		"pre_input_harness_player_transform_placements": 1, "pre_input_harness_camera_rig_aims": 1,
		"zero_write_scope": "capture harness after move_forward input began",
		"player_transform_writes_after_input_began": 0, "camera_transform_writes_after_input_began": 0, "camera_basis_unchanged": true,
		"start_position_m": _vector3(start_position), "end_position_m": _vector3(end_position), "horizontal_displacement_m": displacement,
		"start_outward_distance_m": start_distance, "end_outward_distance_m": end_distance, "direction_dot_inward_normal": direction.dot(-B201_OUTWARD),
		"all_samples_grounded": true, "all_samples_in_boundary": true, "all_center_hits_exact_receiver": true, "recovery_delta": 0,
		"runtime_topology": B201_WORLD_TOPOLOGY.duplicate(true), "bindings": bindings, "source_dependency_hashes": B201_DEPENDENCY_HASHES.duplicate(true),
		"samples": samples, "visual_verdict": "pending_independent_review", "recognition_metric_frozen": "6/213",
	}
	if not _write_new_json(B201_OUTPUT.path_join(B201_MOTION_PRELIMINARY_FILE), manifest):
		_fail("Could not write preliminary B201 motion manifest.")
		return
	print("PASS: drove a %.3f m, 6.0 s continuous normal-forward stock-player approach toward actual-live B201 with 360 grounded exact-receiver samples, zero camera/transform writes, and zero recoveries; post-close movie seal pending" % displacement)


func _finalize_b201_motion() -> void:
	var expected_hash := _argument_value("--movie-sha256=")
	var expected_bytes := int(_argument_value("--movie-bytes="))
	var expected_frames := int(_argument_value("--movie-frames="))
	var pending_path := B201_OUTPUT.path_join(B201_MOTION_PENDING_FILE)
	var movie_path := B201_OUTPUT.path_join(B201_MOTION_FILE)
	var preliminary_path := B201_OUTPUT.path_join(B201_MOTION_PRELIMINARY_FILE)
	var preliminary := _json(preliminary_path)
	var source_path := pending_path if FileAccess.file_exists(pending_path) else movie_path
	var recovered_after_rename := source_path == movie_path
	var avi := _avi_metadata(source_path)
	if not _require(_sealed_stills_manifest_valid(), "Sealed B201 still evidence drifted before movie finalization.") \
	or not _require(_motion_preliminary_valid(preliminary), "B201 preliminary motion record drifted before finalization.") \
	or not _require(expected_hash.length() == 64 and expected_hash == FileAccess.get_sha256(source_path), "B201 movie finalizer received incorrect SHA-256.") \
	or not _require(expected_bytes > 0 and expected_bytes == FileAccess.get_file_as_bytes(source_path).size(), "B201 movie finalizer received incorrect byte count.") \
	or not _require(expected_frames > 0 and expected_frames == int(avi.get("total_frames", -1)), "B201 movie finalizer received incorrect AVI frame count.") \
	or not _require(int(avi.get("width", -1)) == STILL_SIZE.x and int(avi.get("height", -1)) == STILL_SIZE.y, "B201 MovieWriter output is not exactly 1440x900.") \
	or not _require(absf(float(avi.get("frame_rate_fps", 0.0)) - B201_FIXED_FPS) <= 0.01, "B201 MovieWriter output is not 30 fps.") \
	or not _require(str(avi.get("video_handler", "")) == "MJPG" and expected_frames >= ceili(float(B201_MOTION_FRAMES) * B201_FIXED_FPS / B201_MOTION_HZ), "B201 AVI cannot contain the full reviewed motion interval."):
		return
	if not recovered_after_rename:
		if DirAccess.rename_absolute(ProjectSettings.globalize_path(pending_path), ProjectSettings.globalize_path(movie_path)) != OK:
			_fail("Could not atomically promote the closed B201 pending movie.")
			return
	if not _require(FileAccess.get_sha256(movie_path) == expected_hash and FileAccess.get_file_as_bytes(movie_path).size() == expected_bytes, "Canonical B201 movie changed during promotion."):
		return
	var seal := {
		"schema_version": "ti.d1-b201-actual-live-motion-seal/1",
		"review_status": "pending_independent_live_visual_static_and_package_review_not_self_accepted",
		"generator": B201_GENERATOR.trim_prefix("res://"), "generator_sha256": FileAccess.get_sha256(B201_GENERATOR),
		"frozen_generator_sha256_argument": _argument_value("--generator-sha256="),
		"parent_harness_sha256": FileAccess.get_sha256(B201_PARENT_HARNESS),
		"capture_override_sha256": FileAccess.get_sha256(B201_CAPTURE_OVERRIDE),
		"engine_invocation_arguments": OS.get_cmdline_args(), "user_invocation_arguments": OS.get_cmdline_user_args(),
		"runtime_environment": _runtime_environment_receipt(),
		"source_dependency_hashes": B201_DEPENDENCY_HASHES.duplicate(true),
		"stills_manifest": "capture-manifest.json", "stills_manifest_sha256": FileAccess.get_sha256(B201_OUTPUT.path_join("capture-manifest.json")),
		"motion_preliminary": B201_MOTION_PRELIMINARY_FILE, "motion_preliminary_sha256": FileAccess.get_sha256(preliminary_path),
		"movie_file": B201_MOTION_FILE, "movie_sha256": expected_hash, "movie_bytes": expected_bytes,
		"movie_finalized_after_writer_close": true, "avi_container": avi,
		"recovered_from_atomic_rename_before_seal": recovered_after_rename,
		"finalizer": "dependency- and generator-pinned post-close RIFF/AVI/MJPG validation, pending-to-canonical atomic rename, and immutable separate seal",
		"runtime_topology": B201_WORLD_TOPOLOGY.duplicate(true), "recognition_metric_frozen": "6/213",
		"visual_verdict": "pending_independent_review",
	}
	if not _write_new_json(B201_OUTPUT.path_join(B201_MOTION_SEAL_FILE), seal):
		_fail("Could not create immutable B201 motion seal.")
		return
	print("PASS: finalized B201 continuous motion sha256=%s bytes=%d frames=%d" % [expected_hash, expected_bytes, expected_frames])


func _save_b201_still(main: GameMain, player: PlayerController, hud: GameHUD, id: String, role: String, lighting: String, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s did not stabilize." % id}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != STILL_SIZE:
		return {"ok": false, "message": "%s returned an empty or wrong-sized image." % id}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s appears blank." % id}
	var relative := "images/%s.png" % id
	var path := B201_OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % id}
	var metadata := {
		"id": id, "role": role, "lighting": lighting, "file": relative, "sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [image.get_width(), image.get_height()],
		"sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range),
		"debug_labels_visible": false, "source_photography_in_frame": false, "crop_or_postprocess": false,
		"ordinary_stock_player_rig": true, "visual_verdict": "pending_independent_review",
		"pose_setup_disclosure": "one harness placement plus stock-rig yaw/pitch before physics-settled capture; zero harness transform writes while saving this still",
	}
	metadata.merge(extra, true)
	print("D1_B201_LIVE_CAPTURE: id=%s image=%s sha256=%s" % [id, ProjectSettings.globalize_path(path), metadata.sha256])
	return {"ok": true, "metadata": metadata}


func _save_grayscale(source_relative: String, target_relative: String) -> Dictionary:
	var source_path := B201_OUTPUT.path_join(source_relative)
	var target_path := B201_OUTPUT.path_join(target_relative)
	var image := Image.load_from_file(ProjectSettings.globalize_path(source_path))
	if image == null or image.is_empty() or image.get_size() != STILL_SIZE:
		return {"ok": false, "message": "Default B201 PNG could not be reloaded for grayscale."}
	var source_sha := FileAccess.get_sha256(source_path)
	image.convert(Image.FORMAT_L8)
	if image.get_format() != Image.FORMAT_L8 or image.save_png(target_path) != OK:
		return {"ok": false, "message": "Deterministic B201 L8 grayscale save failed."}
	return {"ok": true, "metadata": {
		"id": "03-whole-wsw-default-grayscale", "role": "deterministic_grayscale_of_grounded_whole_wsw_default",
		"lighting": "world_default_derived_luminance", "file": target_relative, "sha256": FileAccess.get_sha256(target_path),
		"bytes": FileAccess.get_file_as_bytes(target_path).size(), "dimensions": [image.get_width(), image.get_height()],
		"image_format": "L8", "derived_from": source_relative, "derived_from_sha256": source_sha,
		"derivation": "Godot Image FORMAT_L8 conversion from exact lossless default PNG", "crop_or_relight": false,
		"visual_verdict": "pending_independent_review",
	}}


func _whole_wsw_projection(camera: Camera3D, record: Dictionary) -> Dictionary:
	var raw := record.get("vertices", []) as Array
	var viewport := camera.get_viewport().get_visible_rect().size
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	var visible := 0
	for vertex_index in 40:
		var offset := vertex_index * 3
		var point := Vector3(float(raw[offset]), float(raw[offset + 1]), float(raw[offset + 2]))
		if camera.is_position_behind(point):
			continue
		var pixel := camera.unproject_position(point)
		minimum = Vector2(minf(minimum.x, pixel.x), minf(minimum.y, pixel.y))
		maximum = Vector2(maxf(maximum.x, pixel.x), maxf(maximum.y, pixel.y))
		visible += 1
	var size := maximum - minimum
	var complete := visible == 40 and minimum.x >= 4.0 and maximum.x <= viewport.x - 4.0 and minimum.y >= 4.0 and maximum.y <= viewport.y - 4.0
	return {
		"ok": complete and size.x >= 600.0 and size.y >= 30.0,
		"eligible_vertex_count": 40, "visible_vertex_count": visible, "complete_chain_in_frame": complete,
		"minimum_pixel": [minimum.x, minimum.y], "maximum_pixel": [maximum.x, maximum.y],
		"width_pixels": size.x, "height_pixels": size.y, "viewport": [viewport.x, viewport.y],
	}


func _tag_is_clear_of_authored_detail(local_point: Vector3) -> bool:
	var adapter: Variant = load(B201_ADAPTER_PATH)
	var record := _b201_wall_record()
	var prepared: Dictionary = adapter.prepare(record)
	var authored: Dictionary = adapter.authored_transform_spec(record, prepared)
	if not bool(authored.get("ok", false)):
		return false
	for key: Variant in authored.boxes:
		for value: Variant in authored.boxes[key] as Array:
			var transform := value as Transform3D
			var half_x := transform.basis.x.length() * 0.5 + 0.65
			var half_y := transform.basis.y.length() * 0.5 + 0.38
			if absf(local_point.x - transform.origin.x) <= half_x and absf(local_point.y - transform.origin.y) <= half_y:
				return false
	return true


func _pixel_patch_delta(before: Image, after: Image, center: Vector2) -> Dictionary:
	if before == null or after == null or before.is_empty() or after.is_empty() \
	or before.get_size() != STILL_SIZE or after.get_size() != STILL_SIZE:
		return {"ok": false}
	var minimum_x := clampi(floori(center.x) - 96, 0, STILL_SIZE.x - 1)
	var maximum_x := clampi(ceili(center.x) + 96, 0, STILL_SIZE.x - 1)
	var minimum_y := clampi(floori(center.y) - 64, 0, STILL_SIZE.y - 1)
	var maximum_y := clampi(ceili(center.y) + 64, 0, STILL_SIZE.y - 1)
	var changed_pixels := 0
	var maximum_channel_delta := 0.0
	var accumulated_delta := 0.0
	var sample_count := 0
	for y in range(minimum_y, maximum_y + 1):
		for x in range(minimum_x, maximum_x + 1):
			var first := before.get_pixel(x, y)
			var second := after.get_pixel(x, y)
			var delta := maxf(absf(first.r - second.r), maxf(absf(first.g - second.g), absf(first.b - second.b)))
			maximum_channel_delta = maxf(maximum_channel_delta, delta)
			accumulated_delta += delta
			sample_count += 1
			if delta >= 0.03:
				changed_pixels += 1
	var mean_channel_delta := accumulated_delta / float(maxi(sample_count, 1))
	return {
		"ok": changed_pixels >= 40 and maximum_channel_delta >= 0.12 and mean_channel_delta >= 0.001,
		"patch_minimum_pixel": [minimum_x, minimum_y], "patch_maximum_pixel": [maximum_x, maximum_y],
		"sample_count": sample_count, "changed_pixels_at_or_above_0_03": changed_pixels,
		"maximum_rgb_channel_delta": maximum_channel_delta, "mean_max_rgb_channel_delta": mean_channel_delta,
	}


func _sha256_bytes(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()


func _camera_spray_hit(player: PlayerController) -> Dictionary:
	var camera := player.get_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(center)
	var direction := camera.project_ray_normal(center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0, B201_SPRAY_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _camera_hit_matches(player: PlayerController) -> bool:
	var hit := _camera_spray_hit(player)
	var collider := hit.get("collider", null) as CollisionObject3D
	return collider != null and str(collider.get_meta("derived_object_key", "")) == B201_RECEIVER_KEY \
		and collider.get_meta("source_keys", []) == [B201_SOURCE_KEY] and collider.is_in_group("spray_receiver_wall")


func _chain_point(local_x: float, world_y: float) -> Vector3:
	return Vector3(B201_CHAIN_MID.x + B201_TANGENT.x * local_x, world_y, B201_CHAIN_MID.z + B201_TANGENT.z * local_x)


func _b201_wall_record() -> Dictionary:
	var chunk := _json(B201_CHUNK_PATH)
	for value: Variant in chunk.get("records", []) as Array:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == B201_RECEIVER_KEY:
			return record
	return {}


func _registry_is_frozen_pending() -> bool:
	var registry := _json("res://game/resources/facades/facade-runtime-registry.json")
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted := metric.get("accepted_physical_unit_ids", []) as Array
	if int(metric.get("numerator", -1)) != 6 or int(metric.get("denominator", -1)) != 213 \
	or str(metric.get("display", "")) != "6/213" or "physical-building:w34313545" in accepted:
		return false
	for value: Variant in registry.get("units", []) as Array:
		var unit := value as Dictionary
		if str(unit.get("unit_id", "")) == "physical-building:w34313545":
			return (unit.get("acceptance_records", []) as Array).is_empty() \
				and str((unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "not_evaluated"
	return false


func _dependencies_match() -> bool:
	for path: String in B201_DEPENDENCY_HASHES:
		if FileAccess.get_sha256(path) != str(B201_DEPENDENCY_HASHES[path]):
			push_error("B201_CAPTURE_DEPENDENCY_DRIFT: %s expected=%s actual=%s" % [path, B201_DEPENDENCY_HASHES[path], FileAccess.get_sha256(path)])
			return false
	return true


func _output_state_allows(mode: String) -> bool:
	var absolute := ProjectSettings.globalize_path(B201_OUTPUT)
	if mode in ["preflight", "stills"]:
		return not DirAccess.dir_exists_absolute(absolute)
	if mode == "motion":
		return _sealed_stills_manifest_valid() \
			and FileAccess.file_exists(B201_OUTPUT.path_join(B201_MOTION_PENDING_FILE)) \
			and not FileAccess.file_exists(B201_OUTPUT.path_join(B201_MOTION_FILE)) \
			and not FileAccess.file_exists(B201_OUTPUT.path_join(B201_MOTION_PRELIMINARY_FILE)) \
			and not FileAccess.file_exists(B201_OUTPUT.path_join(B201_MOTION_SEAL_FILE)) \
			and _stage_tree_matches(["capture-manifest.json", B201_MOTION_PENDING_FILE])
	if mode == "finalize-motion":
		var has_pending := FileAccess.file_exists(B201_OUTPUT.path_join(B201_MOTION_PENDING_FILE))
		var has_canonical := FileAccess.file_exists(B201_OUTPUT.path_join(B201_MOTION_FILE))
		var movie_name := B201_MOTION_PENDING_FILE if has_pending else B201_MOTION_FILE
		return has_pending != has_canonical \
			and not FileAccess.file_exists(B201_OUTPUT.path_join(B201_MOTION_SEAL_FILE)) \
			and _sealed_stills_manifest_valid() \
			and _motion_preliminary_valid(_json(B201_OUTPUT.path_join(B201_MOTION_PRELIMINARY_FILE))) \
			and _stage_tree_matches(["capture-manifest.json", B201_MOTION_PRELIMINARY_FILE, movie_name])
	return false


func _generator_authority_matches() -> bool:
	var frozen := _argument_value("--generator-sha256=")
	return frozen.length() == 64 and frozen == FileAccess.get_sha256(B201_GENERATOR)


func _capture_override_matches() -> bool:
	return FileAccess.file_exists(B201_CAPTURE_OVERRIDE) \
		and FileAccess.get_sha256(B201_CAPTURE_OVERRIDE) == B201_CAPTURE_OVERRIDE_SHA256 \
		and int(ProjectSettings.get_setting("display/window/size/window_width_override", -1)) == STILL_SIZE.x \
		and int(ProjectSettings.get_setting("display/window/size/window_height_override", -1)) == STILL_SIZE.y


func _native_invocation_matches(mode: String) -> bool:
	return str(Engine.get_version_info().get("string", "")).begins_with("4.7.2-stable") \
		and DisplayServer.get_name() == "macOS" \
		and str(RenderingServer.get_current_rendering_method()) == "forward_plus" \
		and str(RenderingServer.get_current_rendering_driver_name()) == "metal" \
		and str(RenderingServer.get_video_adapter_api_version()) == "4.0" \
		and not RenderingServer.get_video_adapter_name().is_empty() \
		and AudioServer.get_driver_name() == "Dummy" \
		and DisplayServer.window_get_size() == STILL_SIZE \
		and _invocation_values_match(OS.get_cmdline_args(), mode) \
		and _user_invocation_values_match(OS.get_cmdline_user_args(), mode)


func _invocation_values_match(arguments_value: Variant, mode: String) -> bool:
	var arguments := Array(arguments_value)
	# Godot consumes recognized display/renderer/audio/movie arguments before
	# exposing this array. Their effective values are validated from the live
	# servers, exact viewport/override, pending target, and closed AVI instead.
	return mode in ["preflight", "stills", "motion", "finalize-motion"] \
		and arguments == ["--script", B201_GENERATOR.trim_prefix("res://")]


func _user_invocation_values_match(arguments_value: Variant, mode: String) -> bool:
	var arguments := Array(arguments_value)
	if _user_argument(arguments, "--capture-mode=") != mode \
	or _user_argument(arguments, "--generator-sha256=") != FileAccess.get_sha256(B201_GENERATOR):
		return false
	if mode == "finalize-motion":
		return arguments.size() == 5 \
			and _user_argument(arguments, "--movie-sha256=").length() == 64 \
			and int(_user_argument(arguments, "--movie-bytes=")) > 0 \
			and int(_user_argument(arguments, "--movie-frames=")) > 0
	return arguments.size() == 2


func _user_argument(arguments: Array, prefix: String) -> String:
	for value: Variant in arguments:
		var argument := str(value)
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _runtime_environment_receipt() -> Dictionary:
	return {
		"display_server": DisplayServer.get_name(),
		"rendering_method": str(RenderingServer.get_current_rendering_method()),
		"rendering_driver": str(RenderingServer.get_current_rendering_driver_name()),
		"video_adapter_api": str(RenderingServer.get_video_adapter_api_version()),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"audio_driver": AudioServer.get_driver_name(),
		"native_window": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y],
		"viewport": [root.get_texture().get_width(), root.get_texture().get_height()],
	}


func _runtime_environment_matches(value: Variant) -> bool:
	if not (value is Dictionary):
		return false
	var environment := value as Dictionary
	return str(environment.get("display_server", "")) == "macOS" \
		and str(environment.get("rendering_method", "")) == "forward_plus" \
		and str(environment.get("rendering_driver", "")) == "metal" \
		and str(environment.get("video_adapter_api", "")) == "4.0" \
		and not str(environment.get("video_adapter", "")).is_empty() \
		and str(environment.get("audio_driver", "")) == "Dummy" \
		and _dimensions_match(environment.get("native_window", []), STILL_SIZE) \
		and _dimensions_match(environment.get("viewport", []), STILL_SIZE)


func _stage_tree_matches(expected_root_files: Array[String]) -> bool:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(B201_OUTPUT)):
		return false
	var root_files := Array(DirAccess.get_files_at(B201_OUTPUT))
	var root_directories := Array(DirAccess.get_directories_at(B201_OUTPUT))
	var image_files := Array(DirAccess.get_files_at(B201_OUTPUT.path_join("images")))
	var image_directories := Array(DirAccess.get_directories_at(B201_OUTPUT.path_join("images")))
	root_files.sort()
	root_directories.sort()
	image_files.sort()
	var expected_files := expected_root_files.duplicate()
	var expected_images := B201_STILL_FILES.duplicate()
	expected_files.sort()
	expected_images.sort()
	return root_files == expected_files and root_directories == ["images"] \
		and image_files == expected_images and image_directories.is_empty()


func _sealed_stills_manifest_valid() -> bool:
	var path := B201_OUTPUT.path_join("capture-manifest.json")
	var manifest := _json(path)
	if manifest.is_empty() \
	or str(manifest.get("schema_version", "")) != "ti.d1-b201-actual-live-evidence/1" \
	or str(manifest.get("review_status", "")) != "pending_independent_live_visual_static_and_package_review_not_self_accepted" \
	or str(manifest.get("visual_verdict", "")) != "pending_independent_review" \
	or str(manifest.get("recognition_metric_frozen", "")) != "6/213" \
	or str(manifest.get("generator_sha256", "")) != FileAccess.get_sha256(B201_GENERATOR) \
	or str(manifest.get("frozen_generator_sha256_argument", "")) != FileAccess.get_sha256(B201_GENERATOR) \
	or str(manifest.get("parent_harness_sha256", "")) != FileAccess.get_sha256(B201_PARENT_HARNESS) \
	or str(manifest.get("capture_override_sha256", "")) != B201_CAPTURE_OVERRIDE_SHA256 \
	or manifest.get("source_dependency_hashes", {}) != B201_DEPENDENCY_HASHES \
	or not _topology_matches(manifest.get("runtime_topology", {})) \
	or int(manifest.get("capture_count", -1)) != B201_STILL_FILES.size() \
	or bool(manifest.get("source_photography_shipped", true)) \
	or not _invocation_values_match(manifest.get("engine_invocation_arguments", []), "stills") \
	or not _user_invocation_values_match(manifest.get("user_invocation_arguments", []), "stills") \
	or not _runtime_environment_matches(manifest.get("runtime_environment", {})):
		return false
	var captures := manifest.get("captures", []) as Array
	if captures.size() != B201_STILL_FILES.size():
		return false
	var observed := {}
	for value: Variant in captures:
		if not (value is Dictionary):
			return false
		var capture := value as Dictionary
		var relative := str(capture.get("file", ""))
		var name := relative.trim_prefix("images/")
		var image_path := B201_OUTPUT.path_join(relative)
		if relative != "images/%s" % name or name not in B201_STILL_FILES or observed.has(name) \
		or not FileAccess.file_exists(image_path) \
		or FileAccess.get_sha256(image_path) != str(capture.get("sha256", "")) \
		or FileAccess.get_file_as_bytes(image_path).size() != int(capture.get("bytes", -1)) \
		or not _dimensions_match(capture.get("dimensions", []), STILL_SIZE) \
		or str(capture.get("visual_verdict", "")) != "pending_independent_review":
			return false
		observed[name] = true
	var changed := _capture_by_id(captures, "02-whole-wsw-changed-light")
	var grayscale := _capture_by_id(captures, "03-whole-wsw-default-grayscale")
	var spray := manifest.get("visible_spray", {}) as Dictionary
	return observed.size() == B201_STILL_FILES.size() \
		and bool(changed.get("player_transform_exactly_reused", false)) \
		and bool(changed.get("camera_transform_exactly_reused", false)) \
		and str(grayscale.get("image_format", "")) == "L8" \
		and str(grayscale.get("derived_from_sha256", "")) == FileAccess.get_sha256(B201_OUTPUT.path_join("images/01-whole-wsw-default.png")) \
		and bool((spray.get("rendered_tag_pixel_delta", {}) as Dictionary).get("ok", false)) \
		and bool(spray.get("sole_host_collider", false)) \
		and str(spray.get("tag_texture_source_sha256", "")) == str(B201_DEPENDENCY_HASHES["res://game/resources/textures/tag/predefined_tag.svg"])


func _motion_preliminary_valid(manifest: Dictionary) -> bool:
	if manifest.is_empty() \
	or str(manifest.get("schema_version", "")) != "ti.d1-b201-actual-live-motion-evidence/1" \
	or str(manifest.get("review_status", "")) != "pending_independent_live_visual_static_and_package_review_not_self_accepted" \
	or str(manifest.get("visual_verdict", "")) != "pending_independent_review" \
	or str(manifest.get("recognition_metric_frozen", "")) != "6/213" \
	or str(manifest.get("generator_sha256", "")) != FileAccess.get_sha256(B201_GENERATOR) \
	or str(manifest.get("frozen_generator_sha256_argument", "")) != FileAccess.get_sha256(B201_GENERATOR) \
	or str(manifest.get("parent_harness_sha256", "")) != FileAccess.get_sha256(B201_PARENT_HARNESS) \
	or str(manifest.get("capture_override_sha256", "")) != B201_CAPTURE_OVERRIDE_SHA256 \
	or manifest.get("source_dependency_hashes", {}) != B201_DEPENDENCY_HASHES \
	or str(manifest.get("movie_file", "")) != B201_MOTION_FILE \
	or str(manifest.get("pending_movie_file", "")) != B201_MOTION_PENDING_FILE \
	or str(manifest.get("movie_sha256", "")) != "sealed_separately_after_movie_writer_close" \
	or bool(manifest.get("movie_finalized_after_writer_close", true)) \
	or not _dimensions_match(manifest.get("render_viewport", []), STILL_SIZE) \
	or int(manifest.get("fixed_fps", -1)) != B201_FIXED_FPS \
	or int(manifest.get("physics_ticks_per_second", -1)) != B201_MOTION_HZ \
	or int(manifest.get("motion_physics_frames", -1)) != B201_MOTION_FRAMES \
	or int(manifest.get("player_transform_writes_after_input_began", -1)) != 0 \
	or int(manifest.get("camera_transform_writes_after_input_began", -1)) != 0 \
	or not bool(manifest.get("camera_basis_unchanged", false)) \
	or not bool(manifest.get("all_samples_grounded", false)) \
	or not bool(manifest.get("all_samples_in_boundary", false)) \
	or not bool(manifest.get("all_center_hits_exact_receiver", false)) \
	or int(manifest.get("recovery_delta", -1)) != 0 \
	or not _topology_matches(manifest.get("runtime_topology", {})) \
	or not _invocation_values_match(manifest.get("engine_invocation_arguments", []), "motion") \
	or not _user_invocation_values_match(manifest.get("user_invocation_arguments", []), "motion") \
	or not _runtime_environment_matches(manifest.get("runtime_environment", {})):
		return false
	var samples := manifest.get("samples", []) as Array
	if samples.size() != B201_MOTION_FRAMES:
		return false
	for index in samples.size():
		var sample := samples[index] as Dictionary
		if int(sample.get("frame", -1)) != index + 1 \
		or not bool(sample.get("is_on_floor", false)) or not bool(sample.get("in_boundary", false)) \
		or not bool(sample.get("camera_basis_unchanged", false)) \
		or str(sample.get("center_first_hit_object", "")) != B201_RECEIVER_KEY \
		or sample.get("center_first_hit_sources", []) != [B201_SOURCE_KEY]:
			return false
	return float(manifest.get("horizontal_displacement_m", 0.0)) >= 22.0 \
		and float(manifest.get("horizontal_displacement_m", 1000.0)) <= 26.5 \
		and float(manifest.get("start_outward_distance_m", 0.0)) > 48.0 \
		and float(manifest.get("end_outward_distance_m", 1000.0)) < 30.0 \
		and float(manifest.get("direction_dot_inward_normal", 0.0)) > 0.995


func _capture_by_id(captures: Array, capture_id: String) -> Dictionary:
	for value: Variant in captures:
		if value is Dictionary and str((value as Dictionary).get("id", "")) == capture_id:
			return value as Dictionary
	return {}


func _dimensions_match(value: Variant, expected: Vector2i) -> bool:
	if not (value is Array) or (value as Array).size() != 2:
		return false
	var dimensions := value as Array
	return int(dimensions[0]) == expected.x and int(dimensions[1]) == expected.y


func _topology_matches(value: Variant) -> bool:
	if not (value is Dictionary):
		return false
	var topology := value as Dictionary
	for key: String in B201_WORLD_TOPOLOGY:
		if int(topology.get(key, -1)) != int(B201_WORLD_TOPOLOGY[key]):
			return false
	return topology.size() == B201_WORLD_TOPOLOGY.size()


func _avi_metadata(path: String) -> Dictionary:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 64 or not _fourcc_at(bytes, 0, "RIFF") or not _fourcc_at(bytes, 8, "AVI ") \
	or _fourcc_offset(bytes, "movi", 0) < 0:
		return {}
	var header := _fourcc_offset(bytes, "avih", 0)
	if header < 0 or header + 48 > bytes.size():
		return {}
	var stream_header := _video_stream_header_offset(bytes)
	if stream_header < 0:
		return {}
	var microseconds := int(bytes.decode_u32(header + 8))
	var total_frames := int(bytes.decode_u32(header + 24))
	var width := int(bytes.decode_u32(header + 40))
	var height := int(bytes.decode_u32(header + 44))
	var handler := bytes.slice(stream_header + 12, stream_header + 16).get_string_from_ascii()
	if microseconds <= 0 or total_frames <= 0 or width <= 0 or height <= 0 or handler != "MJPG":
		return {}
	return {
		"container": "RIFF_AVI", "stream_type": "vids", "video_handler": handler,
		"width": width, "height": height, "total_frames": total_frames,
		"microseconds_per_frame": microseconds, "frame_rate_fps": 1000000.0 / float(microseconds),
		"duration_seconds_from_avih": float(total_frames * microseconds) / 1000000.0,
		"file_bytes": bytes.size(),
	}


func _video_stream_header_offset(bytes: PackedByteArray) -> int:
	var search_from := 0
	while true:
		var offset := _fourcc_offset(bytes, "strh", search_from)
		if offset < 0:
			return -1
		if offset + 16 <= bytes.size() and _fourcc_at(bytes, offset + 8, "vids"):
			return offset
		search_from = offset + 4
	return -1


func _fourcc_offset(bytes: PackedByteArray, value: String, start: int) -> int:
	var needle := value.to_ascii_buffer()
	for index in range(maxi(start, 0), bytes.size() - needle.size() + 1):
		var matches := true
		for needle_index in needle.size():
			if bytes[index + needle_index] != needle[needle_index]:
				matches = false
				break
		if matches:
			return index
	return -1


func _fourcc_at(bytes: PackedByteArray, offset: int, value: String) -> bool:
	var expected := value.to_ascii_buffer()
	if offset < 0 or offset + expected.size() > bytes.size():
		return false
	for index in expected.size():
		if bytes[offset + index] != expected[index]:
			return false
	return true


func _write_new_json(path: String, value: Dictionary) -> bool:
	if FileAccess.file_exists(path):
		return false
	return _write_json(path, value)
