extends "res://game/tests/building_1_public_front_believability_capture.gd"

## Exact-current, actual-live A/B evidence for the one-scalar Building 1
## entrance-group spacing experiment.  This deliberately uses a new evidence
## root; the earlier public-front packet is immutable historical evidence.

const GAP_OUTPUT := "res://evidence/first-playable/building-1-entrance-group-gap-calibration-2026-09-04"
const GAP_GENERATOR := "res://game/tests/building_1_entrance_gap_calibration_capture.gd"
const GAP_PARENT_HARNESS := "res://game/tests/building_1_public_front_believability_capture.gd"
const GAP_REGISTRY := "res://game/resources/facades/facade-runtime-registry.json"
const GAP_MAIN_CHUNK := "res://generated/world/chunks/x_-1__z_2.json"
const GAP_TOWER_WALL_KEY := "building:w1222720021:wall"
const GAP_TOWER_ROOF_KEY := "building:w1222720021:roof"
const GAP_BASE_COMMIT := "798a4dc90b2405f8ff9f336c7bdf95403a0352a1"
const GAP_BASELINE_CONFIG_SHA256 := "fd434eb472f61d93408732841e5993881b23238af8c0518b59181ac0ea535e32"
const GAP_CANDIDATE_CONFIG_SHA256 := "7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806"
const GAP_ADAPTER_SHA256 := "e5b11fc7f971ea33bb38c84d3106f8883de0486774f58a5a8310d49d56aa55a5"
const GAP_WORLD_BUILDER_SHA256 := "d3d3dc1ba3aace541dc07ce437d242787ce2e4efe66877368ac2907e3facf17c"
const GAP_CAPTURE_OVERRIDE_SHA256 := "edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3"
const GAP_WALL_COLLISION_SHA256 := "21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5"
const GAP_ROOF_COLLISION_SHA256 := "bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337"
const GAP_WORLD_TOPOLOGY := {
	"rows": 735, "meshes": 944, "surfaces": 957, "triangles": 64572,
	"bodies": 466, "shapes": 466,
}
const GAP_BUILDING_1_TOPOLOGY := {"meshes": 13, "surfaces": 13, "triangles": 10711, "bodies": 4, "shapes": 4}
const GAP_CHANGED_LIGHT := Vector3(-18.0, 118.0, 0.0)
const GAP_MOTION_FRAMES := 529
const GAP_MOTION_HZ := 60
const GAP_MOVIE_FPS := 30
const GAP_TIMEOUT_SECONDS := 420.0
const GAP_ACCEPTED_IDS := [
	"physical-building:r16681702",
	"physical-building:w1222720021",
	"physical-building:w1249412093",
	"physical-building:w1249412094",
	"physical-building:w291189336",
	"physical-building:w34313540",
]
const GAP_STABLE_RUNTIME_DEPENDENCIES := {
	"res://game/tests/building_1_public_front_believability_capture.gd": "763bc0aa3ba95e7fa2f82ae0e897bbdadd42391f2c0afe13387c828701c96e0e",
	"res://game/scripts/player/player_controller.gd": "8b114132d66c78dd0bfd09783c7b9a3a3a441a8b1ae14f33f7308bd9b04ed0ea",
	"res://game/scripts/player/player_camera.gd": "90ea739b25eb6cbcf8bacff072599b117fe894fcef08683483e41527d8019636",
	"res://game/scenes/main.tscn": "959a0f8a14057ea8402790ba374c7839d5f9835ce20ad194846f0a4d45b43d66",
	"res://game/scripts/main.gd": "d948c8e4900ac88cfe4d40a701eedbbe2070df42c2414e39f2e9b8112d92620f",
	"res://game/scripts/world/facades/facade_runtime_registry_loader.gd": "5975480c124cb3dd4b4f61a2099e284286d7c5c6b808f4c7ecef1cd7b5332395",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://generated/world/chunks/x_-1__z_2.json": "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	"res://generated/world/chunks/x_0__z_2.json": "886f4e6ecfbf570dac9cb36f682a089a0cfe51b735692e3220df4d5b4ac3d7b6",
	"res://project.godot": "305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af",
	"res://game/resources/facades/building_1_hero_model.json": "f10bc92a6e74cbae41347e742e6c68c50faccddbd52ab3ecce210ac8243bc6e9",
	"res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres": "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a",
	"res://game/resources/materials/world/building_1/building_1_light_trim.tres": "6e543d57ff078c267e952f633f4cee232e0743e30218d2f341dc3f31e4a4c8d9",
	"res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres": "41c1c31d4a78da25d4abfac59e82fe919fbb539afa479ab7601d0fb51939d59f",
	"res://game/resources/materials/world/building_1/building_1_bronze.tres": "7948c9fca74345f4ff5e57a44191beb59300847b66cc54ddc176c5ca1b315ca3",
	"res://game/resources/materials/world/building_1/building_1_roof_metal.tres": "8bee442442f8b7bc3004cd3f703ce4e21eb9bc3b1f4d3d8800b02a77268329c8",
	"res://game/resources/materials/world/building_1/building_1_projecting_base_stone.tres": "8bdd85aa10ac78c9225c59aad5ed9d26266ae517ea3f5910b8be3daf41f131ab",
	"res://game/resources/materials/world/building_1/building_1_reveal_shadow.tres": "2e1f36f163c037fe060a1ecfcdcc5dd062849290a96c508970384585b176e14a",
	"res://game/resources/materials/world/building_1/building_1_canopy_underside.tres": "661a7b8cfaef2394e47a42f9bbd04df5fdfbb2cd4be9e6733d5bf3101817cea9",
}

# Both stages use these exact stock-player anchors. Each anchor is settled by
# character physics before camera yaw/pitch is set through the ordinary
# PlayerCamera rig. The changed-light whole view reuses the already-settled
# whole-view transforms. The entrance view alone gets a derived grayscale pair.
const GAP_VIEWS := [
	{
		"id": "01-public-front-whole",
		"role": "grounded_stock_player_whole_public_front",
		"requested_xz": Vector2(-72.908752, 757.150635),
		"aim_target": Vector3(0.941, 16.281, 749.703),
	},
	{
		"id": "02-public-front-entrances",
		"role": "grounded_stock_player_canopy_and_three_entrance_groups",
		"requested_xz": Vector2(-72.908752, 757.150635),
		"aim_target": Vector3(0.941, 9.55, 749.703),
	},
]


func _initialize() -> void:
	create_timer(GAP_TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_gap_timeout)
	call_deferred("_run_gap_capture")


func _run_gap_capture() -> void:
	var stage := _gap_argument("--gap-stage=")
	var mode := _gap_argument("--capture-mode=")
	if stage not in ["a", "b"] or mode not in ["stills", "motion", "finalize-motion"]:
		_fail("Pass --gap-stage=a|b and --capture-mode=stills|motion|finalize-motion.")
		_finish(null)
		return
	if mode == "finalize-motion":
		if not _require(_gap_capture_override_valid(), "The temporary 1440x900 MovieWriter override is missing or drifted."):
			_finish(null)
			return
		_finalize_gap_motion(stage)
		_finish(null)
		return
	if not _require(_gap_capture_override_valid(), "The temporary 1440x900 MovieWriter override is missing or drifted.") \
	or not _require(_gap_runtime_dependencies_valid(), "A stable capture/runtime dependency drifted before stage execution.") \
	or not _require(_gap_stage_is_fresh(stage, mode), "Stage %s/%s would overwrite or mix an existing capture artifact." % [stage, mode]):
		_finish(null)
		return
	if DisplayServer.get_name() == "headless":
		_fail("Building 1 entrance-gap evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	var loaded := await _load_gap_world(stage)
	if not _require(bool(loaded.get("ok", false)), str(loaded.get("message", "World failed."))):
		_finish(loaded.get("main", null) as Node)
		return
	var main := loaded.main as GameMain
	var world := loaded.world as WorldLoader
	var player := loaded.player as PlayerController
	var hud := loaded.hud as GameHUD
	var sun := loaded.sun as DirectionalLight3D
	if not _require(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(GAP_OUTPUT.path_join("images/%s" % stage))) == OK, "Could not create entrance-gap evidence root."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	if mode == "stills":
		await _capture_gap_stills(main, world, player, hud, sun, stage, loaded.bindings as Dictionary)
	else:
		await _capture_gap_motion(main, world, player, hud, sun, stage, loaded.bindings as Dictionary)
	_finish(main)


func _load_gap_world(stage: String) -> Dictionary:
	var config := _json(BAR_CONFIG_PATH)
	var expected_gap := 0.55 if stage == "a" else 0.90
	var expected_config_sha := GAP_BASELINE_CONFIG_SHA256 if stage == "a" else GAP_CANDIDATE_CONFIG_SHA256
	var geometry := config.get("geometry_production_inference_m", {}) as Dictionary
	if not is_equal_approx(float(geometry.get("entrance_group_gap", -1.0)), expected_gap) \
	or FileAccess.get_sha256(BAR_CONFIG_PATH) != expected_config_sha:
		return {"ok": false, "message": "Stage %s did not resolve its exact %.2f config bytes." % [stage, expected_gap]}
	if FileAccess.get_sha256(ADAPTER_PATH) != GAP_ADAPTER_SHA256 \
	or FileAccess.get_sha256("res://game/scripts/world/world_chunk_builder.gd") != GAP_WORLD_BUILDER_SHA256:
		return {"ok": false, "message": "Building 1 adapter or world builder drifted before capture."}
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
		return {"ok": false, "message": "Actual world did not reach one ready state: %s" % failures, "main": main}
	while not player.was_first_reveal_grounded() and Time.get_ticks_msec() - started < 60000:
		await physics_frame
	if not player.was_first_reveal_grounded() or not player.visible:
		return {"ok": false, "message": "Stock player did not complete grounded startup.", "main": main}
	if Vector2i(root.get_texture().get_size()) != CAPTURE_SIZE:
		return {"ok": false, "message": "Viewport must be exactly 1440x900.", "main": main}
	var evidence := world.get_runtime_evidence()
	var topology := {
		"rows": int(evidence.playable_rows), "meshes": int(evidence.mesh_instances),
		"surfaces": int(evidence.surfaces), "triangles": int(evidence.triangles),
		"bodies": int(evidence.static_bodies), "shapes": int(evidence.shapes),
	}
	if topology != GAP_WORLD_TOPOLOGY:
		return {"ok": false, "message": "Exact-current world topology drifted: %s." % topology, "main": main}
	var bindings := _gap_bindings(world, stage)
	if not bool(bindings.get("ok", false)):
		return {"ok": false, "message": str(bindings.get("message", "Binding failure.")), "main": main}
	return {"ok": true, "main": main, "world": world, "player": player, "hud": hud, "sun": sun, "bindings": bindings.metadata}


func _gap_bindings(world: WorldLoader, stage: String) -> Dictionary:
	var keys := [WALL_KEY, ROOF_KEY, GAP_TOWER_WALL_KEY, GAP_TOWER_ROOF_KEY]
	var nodes: Array[Node3D] = []
	var components := {}
	var total := {"meshes": 0, "surfaces": 0, "triangles": 0, "bodies": 0, "shapes": 0}
	for key in keys:
		var matches := _record_nodes(world, key)
		if matches.size() != 1:
			return {"ok": false, "message": "%s resolved %d times." % [key, matches.size()]}
		var node := matches[0]
		nodes.append(node)
		var meshes := node.find_children("*", "MeshInstance3D", true, false).size()
		var bodies := node.find_children("*", "StaticBody3D", true, false)
		var shapes := node.find_children("*", "CollisionShape3D", true, false)
		var component := {
			"meshes": meshes, "surfaces": int(node.get_meta("surfaces", -1)),
			"triangles": int(node.get_meta("triangles", -1)),
			"bodies": bodies.size(), "shapes": shapes.size(),
			"source_keys": node.get_meta("source_keys", []),
		}
		components[key] = component
		for field in total:
			total[field] = int(total[field]) + int(component[field])
		if not bool(node.get_meta("runtime_supersedes_generated_placeholder", false)):
			return {"ok": false, "message": "%s is not the exact live hero." % key}
		if bodies.size() != 1 or shapes.size() != 1:
			return {"ok": false, "message": "%s lost its single structural owner." % key}
		var body := bodies[0] as StaticBody3D
		var wall_role: bool = key.ends_with(":wall")
		if body.is_in_group("spray_receiver_wall") != wall_role \
		or str(body.get_meta("receiver_kind", "")) != ("building_wall" if wall_role else "none"):
			return {"ok": false, "message": "%s collision/spray role drifted." % key}
		if not node.find_children("*", "NavigationRegion3D", true, false).is_empty():
			return {"ok": false, "message": "%s unexpectedly owns navigation." % key}
	if total != GAP_BUILDING_1_TOPOLOGY:
		return {"ok": false, "message": "Building 1/tower 13/13/10711 topology drifted: %s." % total}
	var wall := nodes[0]
	var roof := nodes[1]
	if _gap_collision_sha256(wall) != GAP_WALL_COLLISION_SHA256 or _gap_collision_sha256(roof) != GAP_ROOF_COLLISION_SHA256:
		return {"ok": false, "message": "Building 1 main collision hashes drifted."}
	var registry := _json(GAP_REGISTRY)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	if str(metric.get("display", "")) != "6/213" \
	or metric.get("accepted_physical_unit_ids", []) != GAP_ACCEPTED_IDS:
		return {"ok": false, "message": "Recognition metric drifted from exact 6/213."}
	# A and B intentionally precede the registry-closure repair so that their
	# effective runtime differs only by the one public-front scalar. The final
	# headless/package contract separately requires the repaired 11-asset plans.
	var expected_asset_count := 10
	var plan_counts := {}
	for value: Variant in registry.get("active_runtime_adapters", []) as Array:
		var adapter := value as Dictionary
		var receiver := str(adapter.get("receiver_key", ""))
		if receiver in [WALL_KEY, GAP_TOWER_WALL_KEY]:
			var assets := adapter.get("runtime_assets", []) as Array
			plan_counts[receiver] = assets.size()
			if assets.size() != expected_asset_count:
				return {"ok": false, "message": "%s has %d runtime assets, expected stage-%s count %d." % [receiver, assets.size(), stage, expected_asset_count]}
			if assets.any(func(asset: Variant) -> bool: return str((asset as Dictionary).get("path", "")) == BAR_CONFIG_PATH):
				return {"ok": false, "message": "%s unexpectedly changed registry closure during the controlled A/B." % receiver}
	if plan_counts.size() != 2:
		return {"ok": false, "message": "Building 1 and tower active registry plans did not both resolve."}
	return {"ok": true, "metadata": {
		"component_topology": components, "building_1_and_tower_topology": total,
		"main_wall_collision_sha256": GAP_WALL_COLLISION_SHA256,
		"main_roof_collision_sha256": GAP_ROOF_COLLISION_SHA256,
		"structural_body_count": 4, "structural_shape_count": 4,
		"wall_spray_owner_count": 2, "roof_spray_owner_count": 0,
		"navigation_owner_count": 0, "recognition_metric": "6/213",
		"accepted_physical_unit_ids": GAP_ACCEPTED_IDS.duplicate(),
		"runtime_asset_counts": plan_counts,
		"registry_sha256": FileAccess.get_sha256(GAP_REGISTRY),
	}}


func _capture_gap_stills(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, stage: String, bindings: Dictionary) -> void:
	var original_sun := sun.rotation_degrees
	var captures: Array[Dictionary] = []
	for value: Variant in GAP_VIEWS:
		var base_view := value as Dictionary
		sun.rotation_degrees = original_sun
		var posed := await _settle_and_aim(world, player, hud, base_view)
		if not _require(bool(posed.get("ok", false)), str(posed.get("message", "Pose failed."))):
			return
		var los := _center_los(player, base_view)
		if not _require(bool(los.get("ok", false)), str(los.get("message", "LOS failed."))):
			return
		var default_extra := posed.metadata as Dictionary
		default_extra.merge(los.metadata as Dictionary, true)
		default_extra.merge(_gap_readability_metrics(player.get_camera()), true)
		default_extra["sun_rotation_degrees"] = _vector3(original_sun)
		var default_view := base_view.duplicate(true)
		default_view["id"] = "%s-default" % str(base_view.id)
		default_view["lighting"] = "world_default"
		var default_saved := await _save_gap_view(main, player, hud, default_view, stage, default_extra)
		if not _require(bool(default_saved.get("ok", false)), str(default_saved.get("message", "Default save failed."))):
			return
		captures.append(default_saved.metadata as Dictionary)
		if str(base_view.id) == "01-public-front-whole":
			var frozen_player := player.global_transform
			var frozen_camera := player.get_camera().global_transform
			sun.rotation_degrees = GAP_CHANGED_LIGHT
			var changed_view := base_view.duplicate(true)
			changed_view["id"] = "%s-changed-light" % str(base_view.id)
			changed_view["lighting"] = "frozen_changed_light"
			var changed_extra := default_extra.duplicate(true)
			changed_extra["same_pose_as"] = str(default_view.id)
			changed_extra["sun_rotation_degrees"] = _vector3(GAP_CHANGED_LIGHT)
			changed_extra["player_transform_exactly_reused"] = player.global_transform.is_equal_approx(frozen_player)
			changed_extra["camera_transform_exactly_reused"] = player.get_camera().global_transform.is_equal_approx(frozen_camera)
			if not _require(bool(changed_extra.player_transform_exactly_reused) and bool(changed_extra.camera_transform_exactly_reused), "Changed-light frame did not reuse the exact whole-view player/camera transforms."):
				return
			var changed_saved := await _save_gap_view(main, player, hud, changed_view, stage, changed_extra)
			if not _require(bool(changed_saved.get("ok", false)), str(changed_saved.get("message", "Changed-light save failed."))):
				return
			captures.append(changed_saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var manifest := {
		"schema_version": "ti.building-1-entrance-group-gap-stills/1",
		"stage": stage, "stage_role": "accepted_current_control" if stage == "a" else "bounded_candidate",
		"base_commit": GAP_BASE_COMMIT,
		"review_status": "pending_independent_visual_and_static_review_not_self_accepted",
		"recognition_status": "accepted_before_and_unchanged_by_scalar_quality_pass",
		"generator": GAP_GENERATOR.trim_prefix("res://"), "generator_sha256": FileAccess.get_sha256(GAP_GENERATOR),
		"parent_harness": GAP_PARENT_HARNESS.trim_prefix("res://"), "parent_harness_sha256": FileAccess.get_sha256(GAP_PARENT_HARNESS),
		"stable_runtime_dependency_hashes": _gap_runtime_dependency_receipt(),
		"capture_override_sha256": FileAccess.get_sha256("res://override.cfg"),
		"registry_sha256": FileAccess.get_sha256(GAP_REGISTRY),
		"public_front_config_sha256": FileAccess.get_sha256(BAR_CONFIG_PATH),
		"entrance_group_gap_m": 0.55 if stage == "a" else 0.90,
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(), "video_adapter": RenderingServer.get_video_adapter_name(),
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y], "camera_fov_degrees": 70.0, "spring_arm_length_m": 5.5,
		"changed_light_rotation_degrees": _vector3(GAP_CHANGED_LIGHT),
		"fixed_view_definitions": _gap_view_definitions(), "captures": captures, "capture_count": captures.size(),
		"bindings": bindings, "runtime_topology": GAP_WORLD_TOPOLOGY.duplicate(true),
		"deterministic_grayscale_derivation": "Entrance-focused frame only: Godot Image duplicate then FORMAT_L8 conversion from the exact captured color frame",
		"source_photography_shipped": false, "debug_labels_visible": false, "crop_or_camera_trick": false,
		"visual_verdict": "pending_independent_review",
	}
	if stage == "b":
		var before := _json(GAP_OUTPUT.path_join("a-stills.json"))
		if not _require(_gap_stills_pair(before, manifest), "B stills no longer exactly pair the A camera/light/ground contract."):
			return
		manifest["a_stills_sha256"] = FileAccess.get_sha256(GAP_OUTPUT.path_join("a-stills.json"))
		manifest["same_pose_and_light_contract_as_a"] = true
	if not _gap_write_new_json(GAP_OUTPUT.path_join("%s-stills.json" % stage), manifest):
		_fail("Could not write stage-%s still manifest." % stage)
		return
	print("PASS: captured stage %s with three fixed native Building 1 frames and one entrance grayscale derivative at exact 735/944/957/64572/466/466" % stage)


func _save_gap_view(main: GameMain, player: PlayerController, hud: GameHUD, view: Dictionary, stage: String, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s did not stabilize." % str(view.id)}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s returned an empty or wrong-sized frame." % str(view.id)}
	var hud_state := _hud_state(hud)
	if bool(hud_state.debug_panel_visible) or bool(hud_state.feedback_panel_visible) \
	or bool(hud_state.load_panel_visible) or bool(hud_state.pause_panel_visible) \
	or not bool(hud_state.reticle_visible):
		return {"ok": false, "message": "%s HUD state is not clean stock-player state: %s." % [str(view.id), hud_state]}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s appears blank." % str(view.id)}
	var color_relative := "images/%s/%s-color.png" % [stage, str(view.id)]
	var derive_grayscale := str(view.id) == "02-public-front-entrances-default"
	var gray_relative := "images/%s/%s-grayscale.png" % [stage, str(view.id)] if derive_grayscale else ""
	var color_path := GAP_OUTPUT.path_join(color_relative)
	if image.save_png(color_path) != OK:
		return {"ok": false, "message": "%s color frame failed to save." % str(view.id)}
	var metadata := {
		"id": str(view.id), "role": str(view.role), "lighting": str(view.lighting), "stage": stage,
		"color_file": color_relative, "color_sha256": FileAccess.get_sha256(color_path), "color_bytes": FileAccess.get_file_as_bytes(color_path).size(),
		"dimensions": [image.get_width(), image.get_height()],
		"grayscale_derived": derive_grayscale,
		"sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range),
		"hud": hud_state, "debug_labels_visible": false, "source_photography_in_frame": false,
		"color_crop_or_postprocess": false, "visual_verdict": "pending_independent_review",
	}
	if derive_grayscale:
		var gray_path := GAP_OUTPUT.path_join(gray_relative)
		var grayscale := image.duplicate()
		grayscale.convert(Image.FORMAT_L8)
		if grayscale.save_png(gray_path) != OK:
			return {"ok": false, "message": "%s grayscale frame failed to save." % str(view.id)}
		metadata["grayscale_file"] = gray_relative
		metadata["grayscale_sha256"] = FileAccess.get_sha256(gray_path)
		metadata["grayscale_bytes"] = FileAccess.get_file_as_bytes(gray_path).size()
		metadata["grayscale_dimensions"] = [grayscale.get_width(), grayscale.get_height()]
		metadata["grayscale_format"] = "FORMAT_L8"
		metadata["grayscale_derived_from_same_exact_color_pixels"] = true
	metadata.merge(extra, true)
	print("BUILDING1_GAP_STILL: stage=%s id=%s color=%s grayscale=%s" % [stage, view.id, metadata.color_sha256, str(metadata.get("grayscale_sha256", "not-derived"))])
	return {"ok": true, "metadata": metadata}


func _capture_gap_motion(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, stage: String, bindings: Dictionary) -> void:
	if Engine.physics_ticks_per_second != GAP_MOTION_HZ:
		_fail("Physics tick rate drifted from 60 Hz.")
		return
	var original_sun := sun.rotation_degrees
	if not _require(original_sun.is_equal_approx(Vector3(-52.0, -28.0, 0.0)), "World-default sun drifted before motion capture."):
		return
	var target := Vector3(-0.521373797, 9.55, 734.329981128)
	var wall_anchor_xz := Vector2(-0.521373797, 734.329981128)
	var outward := Vector2(-0.939735032, 0.341903597)
	var requested := Vector2(-56.905475721, 754.844196935)
	var view := {"id": "public-front-normal-approach-start", "requested_xz": requested, "aim_target": target}
	var posed := await _settle_and_aim(world, player, hud, view)
	if not _require(bool(posed.get("ok", false)), str(posed.get("message", "Motion pose failed."))):
		return
	var los_start := _center_los(player, view)
	if not _require(bool(los_start.get("ok", false)), str(los_start.get("message", "Motion start LOS failed."))):
		return
	var camera := player.get_camera()
	var camera_rig := player.get_node("CameraPivot") as PlayerCamera
	var start_position := player.global_position
	var start_player_transform := player.global_transform
	var start_camera_transform := camera.global_transform
	var start_forward := camera_rig.planar_forward()
	var desired_forward := Vector3(target.x - start_position.x, 0.0, target.z - start_position.z).normalized()
	if not _require(start_forward.dot(desired_forward) > 0.999, "Stock camera forward is not the normal approach direction."):
		return
	var recovery_before := int(world.get_runtime_evidence().recovery_count)
	var samples: Array[Dictionary] = []
	var los_samples: Array[Dictionary] = []
	var previous_range := INF
	var maximum_lateral_deviation := 0.0
	var start_process_frame := Engine.get_process_frames()
	var start_physics_frame := Engine.get_physics_frames()
	_clear_gameplay_input()
	player.set_gameplay_enabled(true)
	Input.action_press("move_forward")
	for index in GAP_MOTION_FRAMES:
		paused = false
		_clean_hud(hud)
		await physics_frame
		if not player.is_on_floor():
			Input.action_release("move_forward")
			_fail("Stock player left generated support at motion frame %d." % (index + 1))
			return
		var position := player.global_position
		var ground_hit := _ground_hit(player, Vector2(position.x, position.z))
		var ground := _ground_metadata(ground_hit)
		if not bool(ground.get("ok", false)):
			Input.action_release("move_forward")
			_fail("Motion ground authority failed at frame %d: %s" % [index + 1, ground])
			return
		var camera_position := camera.global_position
		var relative := Vector2(position.x, position.z) - wall_anchor_xz
		var range_to_anchor := relative.dot(outward)
		var lateral_deviation := absf(relative.x * -outward.y + relative.y * outward.x)
		maximum_lateral_deviation = maxf(maximum_lateral_deviation, lateral_deviation)
		var current_recovery_delta := int(world.get_runtime_evidence().recovery_count) - recovery_before
		if _gap_basis_error(start_camera_transform.basis, camera.global_transform.basis) > 0.00001 \
		or not world.get_boundary().contains_position(position) \
		or not Input.is_action_pressed("move_forward") \
		or Input.is_action_pressed("run") or Input.is_action_pressed("jetpack") \
		or current_recovery_delta != 0 \
		or lateral_deviation > 0.08 \
		or absf(position.y - float((ground_hit.position as Vector3).y)) > SETTLE_CLEARANCE_TOLERANCE_M:
			Input.action_release("move_forward")
			_fail("Forbidden camera/input/recovery/boundary/route/ground state at motion frame %d." % (index + 1))
			return
		if range_to_anchor > previous_range + 0.002:
			Input.action_release("move_forward")
			_fail("Wall range increased at motion frame %d: %.6f -> %.6f." % [index + 1, previous_range, range_to_anchor])
			return
		previous_range = range_to_anchor
		var los := _gap_motion_los(player)
		if not bool(los.get("ok", false)):
			Input.action_release("move_forward")
			_fail("Motion LOS failed at frame %d: %s" % [index + 1, los.get("message", "unknown")])
			return
		var los_receipt := los.metadata as Dictionary
		los_receipt["frame"] = index + 1
		los_samples.append(los_receipt)
		samples.append({
			"frame": index + 1, "player_position_m": _vector3(position), "velocity_mps": _vector3(player.velocity),
			"is_on_floor": true, "ground_feature": str(ground.feature), "ground_object": str(ground.object_key),
			"ground_source_keys": ground.get("source_keys", []), "ground_hit_position_m": _vector3(ground_hit.position as Vector3),
			"ground_normal": _vector3(ground_hit.normal as Vector3), "ground_normal_up_dot": float((ground_hit.normal as Vector3).dot(Vector3.UP)),
			"ground_clearance_m": position.y - float((ground_hit.position as Vector3).y),
			"in_world_boundary": world.get_boundary().contains_position(position),
			"camera_position_m": _vector3(camera_position), "camera_forward": _vector3(-camera.global_basis.z),
			"camera_basis_x": _vector3(camera.global_basis.x), "camera_basis_y": _vector3(camera.global_basis.y), "camera_basis_z": _vector3(camera.global_basis.z),
			"range_to_wall_anchor_m": range_to_anchor, "lateral_deviation_from_normal_route_m": lateral_deviation,
			"move_forward_pressed": Input.is_action_pressed("move_forward"), "run_pressed": Input.is_action_pressed("run"),
			"jetpack_pressed": Input.is_action_pressed("jetpack"),
		})
	var input_end_process_frame := Engine.get_process_frames()
	var input_end_physics_frame := Engine.get_physics_frames()
	Input.action_release("move_forward")
	for _frame in 12:
		await physics_frame
	player.set_gameplay_enabled(false)
	var end_position := player.global_position
	var horizontal := Vector3(end_position.x - start_position.x, 0.0, end_position.z - start_position.z)
	var displacement := horizontal.length()
	var direction_dot := horizontal.normalized().dot(desired_forward)
	var start_range := (Vector2(start_position.x, start_position.z) - wall_anchor_xz).dot(outward)
	var end_range := (Vector2(end_position.x, end_position.z) - wall_anchor_xz).dot(outward)
	var recovery_delta := int(world.get_runtime_evidence().recovery_count) - recovery_before
	if not _require(displacement >= 34.8 and displacement <= 35.3, "Normal walk displacement %.3f escaped its 529-tick envelope." % displacement) \
	or not _require(direction_dot > 0.999, "Normal walk direction drifted: %.6f." % direction_dot) \
	or not _require(start_range >= 59.8 and start_range <= 60.2 and end_range >= 24.5 and end_range <= 25.5, "Approach range did not traverse 60 m into the ~25 m band: %.3f -> %.3f." % [start_range, end_range]) \
	or not _require(maximum_lateral_deviation <= 0.08, "Normal route lateral deviation reached %.4f m." % maximum_lateral_deviation) \
	or not _require(recovery_delta == 0, "Normal walk triggered %d recoveries." % recovery_delta) \
	or not _require(start_camera_transform.basis.is_equal_approx(camera.global_transform.basis), "Camera orientation changed after input began.") \
	or not _require(not Input.is_action_pressed("run") and not Input.is_action_pressed("jetpack"), "Sprint or jetpack entered the normal-walk interval."):
		return
	var movie_file := _gap_movie_file(stage)
	var manifest := {
		"schema_version": "ti.building-1-entrance-group-gap-motion/1",
		"stage": stage, "stage_role": "accepted_current_control" if stage == "a" else "bounded_candidate",
		"base_commit": GAP_BASE_COMMIT,
		"review_status": "pending_independent_visual_and_static_review_not_self_accepted",
		"generator": GAP_GENERATOR.trim_prefix("res://"), "generator_sha256": FileAccess.get_sha256(GAP_GENERATOR),
		"parent_harness": GAP_PARENT_HARNESS.trim_prefix("res://"), "parent_harness_sha256": FileAccess.get_sha256(GAP_PARENT_HARNESS),
		"stable_runtime_dependency_hashes": _gap_runtime_dependency_receipt(),
		"capture_override_sha256": FileAccess.get_sha256("res://override.cfg"),
		"registry_sha256": FileAccess.get_sha256(GAP_REGISTRY),
		"public_front_config_sha256": FileAccess.get_sha256(BAR_CONFIG_PATH),
		"entrance_group_gap_m": 0.55 if stage == "a" else 0.90,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(), "video_adapter": RenderingServer.get_video_adapter_name(),
		"movie_file": movie_file, "pending_movie_file": _gap_pending_movie_file(stage),
		"movie_sha256": "pending_after_movie_writer_close", "movie_bytes": -1, "movie_finalized_after_writer_close": false,
		"movie_dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y], "fixed_fps": GAP_MOVIE_FPS,
		"physics_ticks_per_second": GAP_MOTION_HZ, "motion_physics_frames": GAP_MOTION_FRAMES,
		"continuous_duration_seconds": float(GAP_MOTION_FRAMES) / GAP_MOTION_HZ,
		"input_action": "move_forward", "normal_forward_walk": true, "run_action_pressed": false, "jetpack_action_pressed": false,
		"configured_walk_speed_mps": player.walk_speed_mps,
		"review_motion_process_frame_range": [start_process_frame, input_end_process_frame],
		"review_motion_physics_frame_range": [start_physics_frame, input_end_physics_frame],
		"requested_start_xz": [requested.x, requested.y], "aim_target_m": _vector3(target),
		"start_player_transform": _gap_transform(start_player_transform), "start_camera_transform": _gap_transform(start_camera_transform),
		"start_position_m": _vector3(start_position), "end_position_m": _vector3(end_position),
		"wall_anchor_m": [-0.521373797, 6.281, 734.329981128], "outward_normal_xz": [outward.x, outward.y],
		"start_horizontal_range_to_facade_m": start_range, "end_horizontal_range_to_facade_m": end_range,
		"horizontal_displacement_m": displacement, "direction_dot_normal_approach": direction_dot,
		"maximum_lateral_deviation_m": maximum_lateral_deviation, "wall_range_monotonically_decreased": true,
		"player_transform_writes_after_input_began": 0, "camera_transform_writes_after_input_began": 0,
		"camera_orientation_changed_during_motion": false, "all_samples_grounded": true,
		"recovery_delta": recovery_delta, "sprint_used": false, "jetpack_used": false, "manual_recovery_used": false,
		"path_samples": samples, "path_sample_count": samples.size(), "los_samples": los_samples, "los_sample_count": los_samples.size(),
		"start_los": los_start.metadata, "bindings": bindings, "runtime_topology": GAP_WORLD_TOPOLOGY.duplicate(true),
		"visual_motion_verdict": "pending_independent_review_for_shimmer_clipping_float_and_group_readability",
	}
	if stage == "b":
		var before := _json(GAP_OUTPUT.path_join("a-motion.json"))
		if not _require(_gap_motion_pair(before, manifest), "B motion does not match the frozen A start/input/camera/ground contract."):
			return
		manifest["a_motion_sha256"] = FileAccess.get_sha256(GAP_OUTPUT.path_join("a-motion.json"))
		manifest["paired_continuous_stock_controller_contract"] = true
	if not _gap_write_new_json(GAP_OUTPUT.path_join("%s-motion.json" % stage), manifest):
		_fail("Could not write stage-%s preliminary motion manifest." % stage)
		return
	print("PASS: stage %s drove a %.3f m continuous 529-tick normal-forward stock-player approach with 0 transform writes/recoveries; movie seal pending" % [stage, displacement])


func _gap_motion_los(player: PlayerController) -> Dictionary:
	var camera := player.get_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(center)
	var direction := camera.project_ray_normal(center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0, WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return {"ok": false, "message": "center ray hit nothing"}
	var collider := hit.collider as CollisionObject3D
	var key := "" if collider == null else str(collider.get_meta("derived_object_key", ""))
	if key != WALL_KEY or collider.get_meta("source_keys", []) != ["r16681702"]:
		return {"ok": false, "message": "center ray hit %s" % key}
	return {"ok": true, "metadata": {
		"receiver_key": key, "source_keys": collider.get_meta("source_keys", []),
		"hit_position_m": _vector3(hit.position as Vector3), "hit_normal": _vector3(hit.normal as Vector3),
		"hit_distance_m": origin.distance_to(hit.position as Vector3),
	}}


func _gap_readability_metrics(camera: Camera3D) -> Dictionary:
	var config := _json(BAR_CONFIG_PATH)
	var geometry := config.get("geometry_production_inference_m", {}) as Dictionary
	var target := config.get("target", {}) as Dictionary
	var runs: Array[int] = []
	for value: Variant in target.get("public_front_chain_runs", []) as Array:
		runs.append(int(value))
	var record := _gap_record(WALL_KEY)
	var chain_length := _gap_chain_length(record, runs)
	var frame := _gap_chain_frame(record, runs, chain_length * 0.5)
	var group_width := float(geometry.entrance_group_width)
	var group_gap := float(geometry.entrance_group_gap)
	var reveal_border := float(geometry.entrance_reveal_border)
	var separator := group_gap - 2.0 * reveal_border
	var ensemble := group_width * 3.0 + group_gap * 2.0
	var anchor := frame.wall_anchor as Vector3
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	anchor.y = float(frame.base_y) + float(geometry.entrance_height) * 0.5
	var first_center := anchor - tangent * (group_width + group_gap)
	var second_center := anchor
	var first_edge := first_center + tangent * (group_width * 0.5 + reveal_border) + normal * float(geometry.entrance_reveal_center_projection)
	var second_edge := second_center - tangent * (group_width * 0.5 + reveal_border) + normal * float(geometry.entrance_reveal_center_projection)
	var first_px := camera.unproject_position(first_edge)
	var second_px := camera.unproject_position(second_edge)
	var front_depths := [
		float(geometry.entrance_reveal_center_projection) + float(geometry.entrance_reveal_depth) * 0.5,
		float(geometry.entrance_glass_center_projection) + float(geometry.entrance_glass_depth) * 0.5,
		float(geometry.entrance_frame_center_projection) + float(geometry.entrance_frame_depth) * 0.5,
	]
	return {
		"entrance_group_count": 3, "doors_per_group": 3,
		"entrance_group_width_m": group_width, "entrance_group_gap_m": group_gap,
		"entrance_reveal_border_m": reveal_border, "visible_separator_width_m": separator,
		"projected_separator_width_px": first_px.distance_to(second_px),
		"entrance_ensemble_width_m": ensemble, "public_front_chain_length_m": chain_length,
		"centered_chain_margin_each_side_m": (chain_length - ensemble) * 0.5,
		"one_canopy_for_all_groups": true, "canopy_primary_depth_m": float(geometry.canopy_primary_depth),
		"frontmost_depth_planes_m": front_depths,
		"frontmost_depth_planes_strictly_separated": float(front_depths[0]) < float(front_depths[1]) and float(front_depths[1]) < float(front_depths[2]),
		"entrance_bottom_derived_from_exact_wall_base": true,
		"groups_centered_on_public_chain_midpoint": true,
		"group_frame_derived_from_curved_source_chain": true,
		"visual_shimmer_clipping_float_verdict": "pending_independent_motion_review",
	}


func _gap_record(key: String) -> Dictionary:
	for value: Variant in _json(GAP_MAIN_CHUNK).get("records", []) as Array:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _gap_chain_length(record: Dictionary, runs: Array[int]) -> float:
	var result := 0.0
	for run_index in runs:
		var values := record.get("vertices", []) as Array
		var offset := run_index * 12
		var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
		var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
		result += Vector2(end.x - start.x, end.z - start.z).length()
	return result


func _gap_chain_frame(record: Dictionary, runs: Array[int], target_m: float) -> Dictionary:
	var values := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var accumulated := 0.0
	for run_index in runs:
		var offset := run_index * 12
		var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
		var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
		var length := Vector2(end.x - start.x, end.z - start.z).length()
		if target_m <= accumulated + length + 0.0001:
			var fraction := clampf((target_m - accumulated) / length, 0.0, 1.0)
			var tangent := Vector3(end.x - start.x, 0.0, end.z - start.z).normalized()
			return {
				"wall_anchor": start.lerp(end, fraction), "base_y": lerpf(start.y, end.y, fraction),
				"tangent": tangent, "normal": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized(),
			}
		accumulated += length
	return {}


func _finalize_gap_motion(stage: String) -> void:
	var expected_hash := _gap_argument("--movie-sha256=")
	var expected_bytes := int(_gap_argument("--movie-bytes="))
	var expected_frames := int(_gap_argument("--movie-frames="))
	var pending_path := GAP_OUTPUT.path_join(_gap_pending_movie_file(stage))
	var movie_path := GAP_OUTPUT.path_join(_gap_movie_file(stage))
	var manifest_path := GAP_OUTPUT.path_join("%s-motion.json" % stage)
	var manifest := _json(manifest_path)
	var expected_config_sha := GAP_BASELINE_CONFIG_SHA256 if stage == "a" else GAP_CANDIDATE_CONFIG_SHA256
	var expected_gap := 0.55 if stage == "a" else 0.90
	var config := _json(BAR_CONFIG_PATH)
	var avi := _gap_avi_metadata(pending_path)
	if not _require(_gap_runtime_dependencies_valid(), "A stable runtime dependency drifted before movie finalization.") \
	or not _require(not FileAccess.file_exists(movie_path), "Canonical stage-%s movie already exists; refusing overwrite." % stage) \
	or not _require(expected_hash.length() == 64 and expected_hash == FileAccess.get_sha256(pending_path), "Movie finalizer received an incorrect pending-file SHA-256.") \
	or not _require(expected_bytes > 0 and expected_bytes == FileAccess.get_file_as_bytes(pending_path).size(), "Movie finalizer received an incorrect pending-file byte count.") \
	or not _require(expected_frames > 0 and expected_frames == int(avi.get("total_frames", -1)), "Movie finalizer received an incorrect AVI frame count.") \
	or not _require(int(avi.get("width", -1)) == 1440 and int(avi.get("height", -1)) == 900, "Actual MovieWriter output is not 1440x900: %s." % avi) \
	or not _require(absf(float(avi.get("frame_rate_fps", 0.0)) - 30.0) <= 0.01 and expected_frames >= ceili(float(GAP_MOTION_FRAMES) * GAP_MOVIE_FPS / GAP_MOTION_HZ), "AVI FPS/frame envelope cannot cover the 529-tick review interval: %s." % avi) \
	or not _require(str(manifest.get("movie_sha256", "")) == "pending_after_movie_writer_close" and not bool(manifest.get("movie_finalized_after_writer_close", true)), "Motion manifest was not in its one-time finalization state.") \
	or not _require(str(manifest.get("stage", "")) == stage and str(manifest.get("generator_sha256", "")) == FileAccess.get_sha256(GAP_GENERATOR), "Motion stage/generator drifted before finalization.") \
	or not _require(str(manifest.get("parent_harness_sha256", "")) == FileAccess.get_sha256(GAP_PARENT_HARNESS) and manifest.get("stable_runtime_dependency_hashes", {}) == _gap_runtime_dependency_receipt(), "Inherited harness/runtime closure drifted before finalization.") \
	or not _require(str(manifest.get("capture_override_sha256", "")) == GAP_CAPTURE_OVERRIDE_SHA256 and str(manifest.get("registry_sha256", "")) == FileAccess.get_sha256(GAP_REGISTRY), "Capture override or A/B registry bytes drifted before finalization.") \
	or not _require(str(manifest.get("public_front_config_sha256", "")) == expected_config_sha and FileAccess.get_sha256(BAR_CONFIG_PATH) == expected_config_sha and is_equal_approx(float((config.get("geometry_production_inference_m", {}) as Dictionary).get("entrance_group_gap", -1.0)), expected_gap), "Stage config drifted before movie finalization."):
		return
	if stage == "b" and not _require(_gap_motion_artifact_valid(_json(GAP_OUTPUT.path_join("a-motion.json"))), "Sealed A movie no longer validates before B finalization."):
		return
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(pending_path), ProjectSettings.globalize_path(movie_path)) != OK:
		_fail("Could not atomically promote the closed pending movie to its canonical stage path.")
		return
	if not _require(FileAccess.get_sha256(movie_path) == expected_hash and FileAccess.get_file_as_bytes(movie_path).size() == expected_bytes, "Canonical movie changed during one-time promotion."):
		return
	manifest["movie_sha256"] = expected_hash
	manifest["movie_bytes"] = expected_bytes
	manifest["movie_finalized_after_writer_close"] = true
	manifest["pending_movie_file"] = ""
	manifest["avi_container"] = avi
	manifest["finalizer"] = "post-MovieWriter-close SHA-256/bytes plus parsed 1440x900/30fps/frame-count seal and one-time pending-to-canonical rename"
	if not _write_json(manifest_path, manifest):
		_fail("Could not finalize stage-%s motion manifest." % stage)
		return
	if stage == "b":
		_write_gap_combined_manifest()
	print("PASS: finalized stage %s Building 1 gap movie sha256=%s bytes=%d" % [stage, expected_hash, expected_bytes])


func _write_gap_combined_manifest() -> void:
	var a_stills := _json(GAP_OUTPUT.path_join("a-stills.json"))
	var b_stills := _json(GAP_OUTPUT.path_join("b-stills.json"))
	var a_motion := _json(GAP_OUTPUT.path_join("a-motion.json"))
	var b_motion := _json(GAP_OUTPUT.path_join("b-motion.json"))
	if not _require(not FileAccess.file_exists(GAP_OUTPUT.path_join("capture-manifest.json")), "Combined A/B manifest already exists; refusing overwrite.") \
	or not _require(_gap_stage_manifests_valid(a_stills, b_stills, a_motion, b_motion), "A/B packet did not independently revalidate at combined-manifest seal."):
		return
	var combined := {
		"schema_version": "ti.building-1-entrance-group-gap-evidence/1",
		"review_status": "pending_independent_visual_and_static_review_not_self_accepted",
		"recognition_status": "accepted_before_and_unchanged; no_numerator_effect",
		"base_commit": GAP_BASE_COMMIT,
		"experiment": {"field": "geometry_production_inference_m.entrance_group_gap", "a_m": 0.55, "b_m": 0.90, "delta_m": 0.35},
		"a_stills": "a-stills.json", "a_stills_sha256": FileAccess.get_sha256(GAP_OUTPUT.path_join("a-stills.json")),
		"b_stills": "b-stills.json", "b_stills_sha256": FileAccess.get_sha256(GAP_OUTPUT.path_join("b-stills.json")),
		"a_motion": "a-motion.json", "a_motion_sha256": FileAccess.get_sha256(GAP_OUTPUT.path_join("a-motion.json")),
		"b_motion": "b-motion.json", "b_motion_sha256": FileAccess.get_sha256(GAP_OUTPUT.path_join("b-motion.json")),
		"same_pose_still_pairs": true, "paired_normal_forward_stock_controller_motion": true,
		"deterministic_entrance_grayscale_pair": true, "runtime_topology_unchanged": GAP_WORLD_TOPOLOGY.duplicate(true),
		"building_1_and_tower_topology_unchanged": GAP_BUILDING_1_TOPOLOGY.duplicate(true),
		"collision_hashes_unchanged": [GAP_WALL_COLLISION_SHA256, GAP_ROOF_COLLISION_SHA256],
		"recognition_metric_unchanged": "6/213",
		"reviewer_instruction": "Judge original-detail same-pose A/B color and grayscale frames first, then both continuous normal-forward stock-player movies. Confirm the three entrance groups become countable without splitting the single canopy composition or weakening the curved public-front fit; reject visible shimmer, clipping, or float. This packet makes no self-grade.",
		"visual_verdict": "pending_independent_review",
	}
	if not _gap_write_new_json(GAP_OUTPUT.path_join("capture-manifest.json"), combined):
		_fail("Could not write combined A/B capture manifest.")


func _gap_stills_pair(before: Dictionary, after: Dictionary) -> bool:
	if before.is_empty() \
	or str(before.get("generator_sha256", "")) != str(after.get("generator_sha256", "")) \
	or str(before.get("parent_harness_sha256", "")) != str(after.get("parent_harness_sha256", "")) \
	or str(before.get("capture_override_sha256", "")) != str(after.get("capture_override_sha256", "")) \
	or str(before.get("registry_sha256", "")) != str(after.get("registry_sha256", "")) \
	or before.get("stable_runtime_dependency_hashes", {}) != after.get("stable_runtime_dependency_hashes", {}) \
	or not _values_close(before.get("fixed_view_definitions", []), after.get("fixed_view_definitions", []), 0.000001):
		return false
	var first := before.get("captures", []) as Array
	var second := after.get("captures", []) as Array
	if first.size() != 3 or second.size() != 3:
		return false
	for index in first.size():
		var a := first[index] as Dictionary
		var b := second[index] as Dictionary
		for key in ["id", "lighting", "requested_xz", "player_position_m", "ground_y_m", "aim_target_m", "camera_position_m", "camera_forward", "camera_fov_degrees", "configured_spring_length_m", "sun_rotation_degrees"]:
			if not _values_close(a.get(key), b.get(key), 0.001):
				return false
	return true


func _gap_motion_pair(before: Dictionary, after: Dictionary) -> bool:
	if before.is_empty() \
	or str(before.get("generator_sha256", "")) != str(after.get("generator_sha256", "")) \
	or str(before.get("parent_harness_sha256", "")) != str(after.get("parent_harness_sha256", "")) \
	or str(before.get("capture_override_sha256", "")) != str(after.get("capture_override_sha256", "")) \
	or str(before.get("registry_sha256", "")) != str(after.get("registry_sha256", "")) \
	or before.get("stable_runtime_dependency_hashes", {}) != after.get("stable_runtime_dependency_hashes", {}):
		return false
	for key in ["requested_start_xz", "aim_target_m", "start_player_transform", "start_camera_transform", "input_action", "motion_physics_frames", "physics_ticks_per_second", "fixed_fps"]:
		if not _values_close(before.get(key), after.get(key), 0.001):
			return false
	if not _values_close(before.get("path_samples", []), after.get("path_samples", []), 0.002) \
	or not _values_close(before.get("los_samples", []), after.get("los_samples", []), 0.002):
		return false
	return true


func _gap_view_definitions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Variant in GAP_VIEWS:
		var view := value as Dictionary
		result.append({
			"id": str(view.id), "role": str(view.role),
			"requested_xz": [float((view.requested_xz as Vector2).x), float((view.requested_xz as Vector2).y)],
			"aim_target_m": _vector3(view.aim_target as Vector3),
			"lighting_variants": ["world_default", "frozen_changed_light"] if str(view.id) == "01-public-front-whole" else ["world_default"],
			"changed_light_rotation_degrees": _vector3(GAP_CHANGED_LIGHT),
		})
	return result


func _gap_collision_sha256(node: Node3D) -> String:
	var shape_node := node.find_child("Shape", true, false) as CollisionShape3D
	if shape_node == null or not (shape_node.shape is ConcavePolygonShape3D):
		return ""
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update((shape_node.shape as ConcavePolygonShape3D).get_faces().to_byte_array())
	return context.finish().hex_encode()


func _gap_capture_override_valid() -> bool:
	return FileAccess.file_exists("res://override.cfg") \
		and FileAccess.get_sha256("res://override.cfg") == GAP_CAPTURE_OVERRIDE_SHA256 \
		and int(ProjectSettings.get_setting("display/window/size/window_width_override", -1)) == 1440 \
		and int(ProjectSettings.get_setting("display/window/size/window_height_override", -1)) == 900


func _gap_runtime_dependencies_valid() -> bool:
	for path: String in GAP_STABLE_RUNTIME_DEPENDENCIES:
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(GAP_STABLE_RUNTIME_DEPENDENCIES[path]):
			return false
	return FileAccess.get_sha256(ADAPTER_PATH) == GAP_ADAPTER_SHA256 \
		and FileAccess.get_sha256("res://game/scripts/world/world_chunk_builder.gd") == GAP_WORLD_BUILDER_SHA256


func _gap_runtime_dependency_receipt() -> Dictionary:
	var result := GAP_STABLE_RUNTIME_DEPENDENCIES.duplicate(true)
	result[ADAPTER_PATH] = FileAccess.get_sha256(ADAPTER_PATH)
	result["res://game/scripts/world/world_chunk_builder.gd"] = FileAccess.get_sha256("res://game/scripts/world/world_chunk_builder.gd")
	return result


func _gap_stage_is_fresh(stage: String, mode: String) -> bool:
	var combined := GAP_OUTPUT.path_join("capture-manifest.json")
	if FileAccess.file_exists(combined):
		return false
	var stills_path := GAP_OUTPUT.path_join("%s-stills.json" % stage)
	var motion_path := GAP_OUTPUT.path_join("%s-motion.json" % stage)
	var image_directory := ProjectSettings.globalize_path(GAP_OUTPUT.path_join("images/%s" % stage))
	var canonical_movie := GAP_OUTPUT.path_join(_gap_movie_file(stage))
	if mode == "stills":
		if FileAccess.file_exists(stills_path) or FileAccess.file_exists(motion_path) \
		or FileAccess.file_exists(canonical_movie) or DirAccess.dir_exists_absolute(image_directory):
			return false
		if stage == "b" and not _gap_sealed_stage_exists("a"):
			return false
		return true
	if mode == "motion":
		if not FileAccess.file_exists(stills_path) or FileAccess.file_exists(motion_path) or FileAccess.file_exists(canonical_movie):
			return false
		if not FileAccess.file_exists(GAP_OUTPUT.path_join(_gap_pending_movie_file(stage))):
			return false
		if stage == "b" and not _gap_sealed_stage_exists("a"):
			return false
		return true
	return false


func _gap_sealed_stage_exists(stage: String) -> bool:
	var stills := _json(GAP_OUTPUT.path_join("%s-stills.json" % stage))
	var motion := _json(GAP_OUTPUT.path_join("%s-motion.json" % stage))
	var movie_path := GAP_OUTPUT.path_join(_gap_movie_file(stage))
	return not stills.is_empty() and not motion.is_empty() \
		and bool(motion.get("movie_finalized_after_writer_close", false)) \
		and FileAccess.file_exists(movie_path) \
		and str(motion.get("movie_sha256", "")) == FileAccess.get_sha256(movie_path) \
		and int(motion.get("movie_bytes", -1)) == FileAccess.get_file_as_bytes(movie_path).size()


func _gap_write_new_json(path: String, value: Dictionary) -> bool:
	if FileAccess.file_exists(path):
		return false
	return _write_json(path, value)


func _gap_basis_error(first: Basis, second: Basis) -> float:
	return maxf(maxf(first.x.distance_to(second.x), first.y.distance_to(second.y)), first.z.distance_to(second.z))


func _gap_stage_manifests_valid(a_stills: Dictionary, b_stills: Dictionary, a_motion: Dictionary, b_motion: Dictionary) -> bool:
	var current_generator := FileAccess.get_sha256(GAP_GENERATOR)
	if a_stills.is_empty() or b_stills.is_empty() or a_motion.is_empty() or b_motion.is_empty() \
	or str(a_stills.get("stage", "")) != "a" or str(b_stills.get("stage", "")) != "b" \
	or str(a_motion.get("stage", "")) != "a" or str(b_motion.get("stage", "")) != "b" \
	or str(a_stills.get("public_front_config_sha256", "")) != GAP_BASELINE_CONFIG_SHA256 \
	or str(a_motion.get("public_front_config_sha256", "")) != GAP_BASELINE_CONFIG_SHA256 \
	or str(b_stills.get("public_front_config_sha256", "")) != GAP_CANDIDATE_CONFIG_SHA256 \
	or str(b_motion.get("public_front_config_sha256", "")) != GAP_CANDIDATE_CONFIG_SHA256 \
	or not _gap_stills_pair(a_stills, b_stills) or not _gap_motion_pair(a_motion, b_motion):
		return false
	for manifest: Dictionary in [a_stills, b_stills, a_motion, b_motion]:
		if str(manifest.get("generator_sha256", "")) != current_generator \
		or str(manifest.get("parent_harness_sha256", "")) != FileAccess.get_sha256(GAP_PARENT_HARNESS) \
		or str(manifest.get("capture_override_sha256", "")) != GAP_CAPTURE_OVERRIDE_SHA256 \
		or manifest.get("stable_runtime_dependency_hashes", {}) != _gap_runtime_dependency_receipt():
			return false
	if not _gap_still_artifacts_valid(a_stills) or not _gap_still_artifacts_valid(b_stills):
		return false
	if not _gap_motion_artifact_valid(a_motion) or not _gap_motion_artifact_valid(b_motion):
		return false
	var a_process_range := a_motion.get("review_motion_process_frame_range", []) as Array
	var b_process_range := b_motion.get("review_motion_process_frame_range", []) as Array
	return a_process_range.size() == 2 and b_process_range.size() == 2 \
		and int(a_process_range[1]) - int(a_process_range[0]) == int(b_process_range[1]) - int(b_process_range[0])


func _gap_still_artifacts_valid(manifest: Dictionary) -> bool:
	var captures := manifest.get("captures", []) as Array
	if captures.size() != 3:
		return false
	var grayscale_count := 0
	for value: Variant in captures:
		var capture := value as Dictionary
		var color_path := GAP_OUTPUT.path_join(str(capture.get("color_file", "")))
		if not FileAccess.file_exists(color_path) \
		or FileAccess.get_sha256(color_path) != str(capture.get("color_sha256", "")) \
		or FileAccess.get_file_as_bytes(color_path).size() != int(capture.get("color_bytes", -1)) \
		or capture.get("dimensions", []) != [1440, 900]:
			return false
		if bool(capture.get("grayscale_derived", false)):
			grayscale_count += 1
			var gray_path := GAP_OUTPUT.path_join(str(capture.get("grayscale_file", "")))
			if not FileAccess.file_exists(gray_path) \
			or FileAccess.get_sha256(gray_path) != str(capture.get("grayscale_sha256", "")) \
			or FileAccess.get_file_as_bytes(gray_path).size() != int(capture.get("grayscale_bytes", -1)) \
			or not _gap_grayscale_matches(color_path, gray_path):
				return false
	return grayscale_count == 1


func _gap_grayscale_matches(color_path: String, grayscale_path: String) -> bool:
	var color := Image.load_from_file(color_path)
	var stored := Image.load_from_file(grayscale_path)
	if color == null or stored == null or color.is_empty() or stored.is_empty():
		return false
	var derived := color.duplicate()
	derived.convert(Image.FORMAT_L8)
	stored.convert(Image.FORMAT_L8)
	return derived.get_size() == Vector2i(1440, 900) and derived.get_data() == stored.get_data()


func _gap_motion_artifact_valid(manifest: Dictionary) -> bool:
	var movie_path := GAP_OUTPUT.path_join(str(manifest.get("movie_file", "")))
	if not bool(manifest.get("movie_finalized_after_writer_close", false)) \
	or not FileAccess.file_exists(movie_path) \
	or str(manifest.get("movie_sha256", "")) != FileAccess.get_sha256(movie_path) \
	or int(manifest.get("movie_bytes", -1)) != FileAccess.get_file_as_bytes(movie_path).size():
		return false
	var observed := _gap_avi_metadata(movie_path)
	var recorded := manifest.get("avi_container", {}) as Dictionary
	return observed == recorded \
		and int(observed.get("width", -1)) == 1440 \
		and int(observed.get("height", -1)) == 900 \
		and absf(float(observed.get("frame_rate_fps", 0.0)) - 30.0) <= 0.01 \
		and int(observed.get("total_frames", -1)) >= ceili(float(GAP_MOTION_FRAMES) * GAP_MOVIE_FPS / GAP_MOTION_HZ)


func _gap_avi_metadata(path: String) -> Dictionary:
	var bytes := FileAccess.get_file_as_bytes(path)
	var offset := _gap_fourcc_offset(bytes, "avih")
	if offset < 0 or offset + 48 > bytes.size():
		return {}
	var microseconds := int(bytes.decode_u32(offset + 8))
	var total_frames := int(bytes.decode_u32(offset + 24))
	var width := int(bytes.decode_u32(offset + 40))
	var height := int(bytes.decode_u32(offset + 44))
	if microseconds <= 0 or total_frames <= 0 or width <= 0 or height <= 0:
		return {}
	return {
		"container": "RIFF_AVI", "video_codec": "Motion_JPEG",
		"width": width, "height": height, "total_frames": total_frames,
		"microseconds_per_frame": microseconds,
		"frame_rate_fps": 1000000.0 / float(microseconds),
		"duration_seconds_from_avih": float(total_frames * microseconds) / 1000000.0,
	}


func _gap_fourcc_offset(bytes: PackedByteArray, fourcc: String) -> int:
	var needle := fourcc.to_ascii_buffer()
	for index in range(0, bytes.size() - needle.size() + 1):
		var matches := true
		for needle_index in needle.size():
			if bytes[index + needle_index] != needle[needle_index]:
				matches = false
				break
		if matches:
			return index
	return -1


func _gap_movie_file(stage: String) -> String:
	return "building-1-entrance-gap-%s-normal-forward-approach.avi" % stage


func _gap_pending_movie_file(stage: String) -> String:
	return "building-1-entrance-gap-%s-normal-forward-approach.pending.avi" % stage


func _gap_transform(value: Transform3D) -> Dictionary:
	return {
		"origin": _vector3(value.origin),
		"basis_x": _vector3(value.basis.x),
		"basis_y": _vector3(value.basis.y),
		"basis_z": _vector3(value.basis.z),
	}


func _gap_argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _on_gap_timeout() -> void:
	if not _finished:
		_fail("Building 1 entrance-gap evidence timed out after %.0f seconds." % GAP_TIMEOUT_SECONDS)
		_finish(null)
