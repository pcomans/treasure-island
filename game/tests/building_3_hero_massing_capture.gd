extends "res://game/tests/p1_existing_live_revalidation_capture.gd"

const HERO_OUTPUT := "res://evidence/first-playable/building-3-hero-massing-2026-09-04"
const HERO_COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/building_3_hero_massing_capture.gd"
const HERO_CONFIG_PATH := "res://game/resources/facades/building_3_hero_massing.json"
const HERO_LAYOUT_PATH := "res://game/resources/facades/building_3_600_california_ene_layout.json"
const HERO_MASSING_SCRIPT_PATH := "res://game/scripts/world/massing/building_3_600_california_massing.gd"
const HERO_FACADE_SCRIPT_PATH := "res://game/scripts/world/facades/building_3_600_california_facade.gd"
const HERO_SPEC_PATH := "res://discovery/facades/BUILDING_3_HERO_MASSING_REPAIR.md"
const HERO_PACKET_PATH := "res://discovery/facades/p1_reference_packets/w34313540_building_3.md"
const HERO_CONFIG_SHA256 := "149d9211c75e86c769243298d649b79b682c1b4873af5d86d30a5d04aa1a26bd"
const HERO_LAYOUT_SHA256 := "a491a3c7916191b9ca5f6adacc6d1f2289c0103f5079516b102b94e3993dae0c"
const HERO_MASSING_SCRIPT_SHA256 := "0755ab9846357207143f4bb0a50c27e710d92aa3a529903c61d4d3495bb94419"
const HERO_FACADE_SCRIPT_SHA256 := "5fa9851a90e886bb0a75ff35bf137ed891ed5f1e0cd53d95ee840a0573c2c55a"
const HERO_SPEC_SHA256 := "90daf84b4d26e90ec8f7ef07d88aad0317dbd67475eefc39d88c8b08c79e4425"
const HERO_PACKET_SHA256 := "3701d28e19cc7811067c171eb5a85e5efe4098d554c387679f50fed6248fb961"
const HERO_PROFILE_SIGNATURE := "f82192fe9ebeb04a6da1222bcd84afd217f163ff6ce1cceed826a5d436dd1693"
const HERO_WALL_SIGNATURE := "e03f830e6a41da16107b5db14bcb8a8ff9f43b46f9df89b1f157958cc68909d4"
const HERO_ROOF_SIGNATURE := "2dee9acf24616423230895d70827acb56c8f402a56ac1fe8e4a93d2409b34b63"
const HERO_FACADE_SIGNATURE := "e0b30339bd2ca8642a7b49b5e6153f52017ec4a840e9b0dc1e3841f5373ca5f8"
const HERO_WALL_KEY := "building:w34313540:wall"
const HERO_ROOF_KEY := "building:w34313540:roof"

const BEFORE_IMAGES := [
	{
		"pair_id": "whole-ene",
		"file": "evidence/first-playable/p1-existing-live-revalidation-2026-09-04/images/building-3/01-building-3-whole-object.png",
		"sha256": "e20ebd6a483234b1b55de5421113a79dbe6d3c18380ab33858ab0f4de7ded1ef",
		"role": "historical_exact_current_before_whole_object",
	},
	{
		"pair_id": "ene-oblique",
		"file": "evidence/first-playable/p1-existing-live-revalidation-2026-09-04/images/building-3/02-building-3-oblique-approach.png",
		"sha256": "2a3aa0dd7e4f08f37cad515d75c45240eb412043f4f69acbea208fef4848a103",
		"role": "historical_exact_current_before_oblique",
	},
]

const HERO_VIEWS := [
	{
		"id": "01-building-3-hero-whole-ene",
		"pair_id": "whole-ene",
		"target": "building-3",
		"role": "whole_object_ordinary_player_view",
		"requested_xz": Vector2(571.6817, 415.5383),
		"aim_target": Vector3(507.8694, 14.5, 448.8849),
		"expected_receiver": HERO_WALL_KEY,
		"expected_source_keys": ["w34313540"],
	},
	{
		"id": "02-building-3-hero-ene-oblique",
		"pair_id": "ene-oblique",
		"target": "building-3",
		"role": "whole_object_oblique_ordinary_player_view",
		"requested_xz": Vector2(560.0, 382.0),
		"aim_target": Vector3(507.8694, 14.5, 448.8849),
		"expected_receiver": HERO_WALL_KEY,
		"expected_source_keys": ["w34313540"],
	},
]


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Building 3 hero evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for Building 3 hero evidence."):
		_finish(null)
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var hud := main.get_node("Interface/HUD") as GameHUD
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
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Actual world did not reach one clean ready state for Building 3 hero evidence."):
		_finish(main)
		return
	var ready := ready_reports[0]
	if not _require(str(ready.get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted before Building 3 hero capture.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated manifest bytes drifted before Building 3 hero capture.") \
	or not _require(Vector2i(root.get_texture().get_size()) == CAPTURE_SIZE, "Building 3 hero capture viewport is not exactly 1440x900."):
		_finish(main)
		return
	var binding := _validate_hero_binding(world)
	if not _require(bool(binding.get("ok", false)), str(binding.get("message", "Building 3 hero binding failed."))):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(HERO_OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create Building 3 hero evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	var captures: Array[Dictionary] = []
	for view_value: Variant in HERO_VIEWS:
		var view := view_value as Dictionary
		var posed := await _settle_and_aim(world, player, hud, view)
		if not _require(bool(posed.get("ok", false)), str(posed.get("message", "%s pose failed." % str(view.id)))):
			_finish(main)
			return
		var framing := _framing_metadata(player.get_camera(), _nodes_for_keys(world, [HERO_WALL_KEY, HERO_ROOF_KEY]))
		if not _require(bool(framing.get("ok", false)), "%s bounds could not be projected." % str(view.id)) \
		or not _require(_hero_framing_is_valid(framing), "%s does not contain the whole observable Building 3 mass: %s" % [str(view.id), JSON.stringify(framing)]):
			_finish(main)
			return
		var los := _center_los(player, view)
		if not _require(bool(los.get("ok", false)), str(los.get("message", "%s exact first-hit LOS failed." % str(view.id)))):
			_finish(main)
			return
		var metadata := posed.metadata as Dictionary
		metadata.merge(framing.metadata as Dictionary, true)
		metadata.merge(los.metadata as Dictionary, true)
		var saved := await _save_hero_view(main, player, hud, view, metadata)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "%s save failed." % str(view.id)))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	var runtime := world.get_runtime_evidence()
	var manifest := {
		"schema_version": "ti.building-3-hero-massing-evidence/1",
		"review_status": "pending_independent_original_detail_review_not_self_accepted",
		"recognition_verdict": "pending_independent_review",
		"executor_role": "builder_and_technical_capture_only",
		"capture_command": HERO_COMMAND,
		"generator": "game/tests/building_3_hero_massing_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/building_3_hero_massing_capture.gd"),
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"source_identity": "w34313540",
		"logical_object_key": "building:w34313540",
		"wall_receiver": HERO_WALL_KEY,
		"roof_receiver": HERO_ROOF_KEY,
		"corrected_nrhp_id": "08000083",
		"frozen_osm_nrhp_ref": "08000081",
		"frozen_osm_nrhp_ref_role": "provenance_only_incorrect_for_building_3",
		"confusion_set_source_ids_frozen_before_review": ["w24274434", "r16681702"],
		"recognition_gate": "Top-1 Building 3 from two ordinary grounded views using the broad curved crown, four narrow high corner shoulders/pylons, dominant single hangar opening, and subordinate raised upper band without relying on color, address, source ID, location, or overlays.",
		"before_images_immutable_prior_runtime": BEFORE_IMAGES,
		"before_after_pairing_note": "Pair IDs preserve the prior whole/oblique evidence roles. The whole ENE player anchor is identical; the after aim is raised only to contain the new crown. The second after anchor is moved farther along the same ordinary ENE approach so the newly taller whole mass remains in frame.",
		"camera_contract": {
			"rig": "actual Player/CameraPivot/SpringArm3D/Camera3D",
			"fov_degrees": 70.0,
			"configured_spring_length_m": 5.5,
			"orientation": "input_reachable stock yaw plus clamped spring-arm pitch",
			"physics_grounded": true,
			"detached_camera": false,
			"camera_tricks": false,
			"context_hidden": false,
			"lighting_changed": false,
			"crop_or_postprocess": false,
			"debug_labels_visible": false,
		},
		"exact_binding": binding.metadata,
		"generated_world": {
			"content_sha256": EXPECTED_CONTENT_SHA256,
			"manifest_sha256": EXPECTED_MANIFEST_SHA256,
			"playable_rows": runtime.playable_rows,
			"context_rows": runtime.context_rows,
			"meshes": runtime.mesh_instances,
			"surfaces": runtime.surfaces,
			"triangles": runtime.triangles,
			"static_bodies": runtime.static_bodies,
			"shapes": runtime.shapes,
		},
		"truth_boundary": {
			"horizontal_source_footprint_preserved": true,
			"generated_bytes_unchanged": true,
			"vertical_dimensions": "reversible_production_inference_not_surveyed",
			"exterior_only": true,
			"interior_modeled": false,
			"as_built_fidelity_claimed": false,
			"source_photography_shipped": false,
		},
		"capture_count": captures.size(),
		"captures": captures,
		"recognition_review_prohibited_for_executor": true,
		"reviewer_instruction": "Open both new PNGs and both immutable before PNGs at original 1440x900 detail. Apply the frozen confusion set and whole-entity top-1 rubric. Do not infer acceptance from this manifest or from color.",
	}
	if not _write_json(HERO_OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write Building 3 hero capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d grounded whole-mass pending-review Building 3 hero views on native %s/%s to %s" % [captures.size(), DisplayServer.get_name(), RenderingServer.get_video_adapter_name(), output_absolute])
	_finish(main)


func _validate_hero_binding(world: WorldLoader) -> Dictionary:
	var expected_files := {
		HERO_CONFIG_PATH: HERO_CONFIG_SHA256,
		HERO_LAYOUT_PATH: HERO_LAYOUT_SHA256,
		HERO_MASSING_SCRIPT_PATH: HERO_MASSING_SCRIPT_SHA256,
		HERO_FACADE_SCRIPT_PATH: HERO_FACADE_SCRIPT_SHA256,
		HERO_SPEC_PATH: HERO_SPEC_SHA256,
		HERO_PACKET_PATH: HERO_PACKET_SHA256,
	}
	for path: String in expected_files:
		if FileAccess.get_sha256(path) != str(expected_files[path]):
			return {"ok": false, "message": "Exact-bound Building 3 file drifted: %s" % path}
	for before: Dictionary in BEFORE_IMAGES:
		var before_path := "res://%s" % str(before.file)
		if FileAccess.get_sha256(before_path) != str(before.sha256):
			return {"ok": false, "message": "Immutable Building 3 before image drifted: %s" % before_path}
	var walls := _record_nodes(world, HERO_WALL_KEY)
	var roofs := _record_nodes(world, HERO_ROOF_KEY)
	if walls.size() != 1 or roofs.size() != 1:
		return {"ok": false, "message": "Building 3 wall/roof did not each resolve exactly once."}
	var wall := walls[0] as Node3D
	var roof := roofs[0] as Node3D
	var facade := wall.get_node_or_null("Building3600CaliforniaFacade") as Node3D
	var contract := wall.get_meta("massing_contract", {}) as Dictionary
	if facade == null \
	or wall.get_meta("source_keys", []) != ["w34313540"] \
	or roof.get_meta("source_keys", []) != ["w34313540"] \
	or str(contract.get("profile_signature", "")) != HERO_PROFILE_SIGNATURE \
	or str(wall.get_meta("massing_signature", "")) != HERO_WALL_SIGNATURE \
	or str(roof.get_meta("massing_signature", "")) != HERO_ROOF_SIGNATURE \
	or str(facade.get_meta("deterministic_signature", "")) != HERO_FACADE_SIGNATURE \
	or not bool(wall.get_meta("runtime_supersedes_generated_placeholder", false)) \
	or not bool(roof.get_meta("runtime_supersedes_generated_placeholder", false)):
		return {"ok": false, "message": "Building 3 runtime signatures or placeholder-supersession contract drifted."}
	return {
		"ok": true,
		"metadata": {
			"wall_runtime_path": str(wall.get_path()),
			"roof_runtime_path": str(roof.get_path()),
			"facade_runtime_path": str(facade.get_path()),
			"profile_signature": HERO_PROFILE_SIGNATURE,
			"wall_geometry_signature": HERO_WALL_SIGNATURE,
			"roof_geometry_signature": HERO_ROOF_SIGNATURE,
			"facade_signature": HERO_FACADE_SIGNATURE,
			"config_sha256": HERO_CONFIG_SHA256,
			"layout_sha256": HERO_LAYOUT_SHA256,
			"massing_script_sha256": HERO_MASSING_SCRIPT_SHA256,
			"facade_script_sha256": HERO_FACADE_SCRIPT_SHA256,
			"reference_packet_sha256": HERO_PACKET_SHA256,
			"repair_spec_sha256": HERO_SPEC_SHA256,
			"wall_triangles": 236,
			"roof_triangles": 675,
			"topology_delta_triangles": 766,
			"hidden_generic_wall_or_roof_collision": false,
			"visual_review_status": "pending_independent_original_detail_review",
		},
	}


func _hero_framing_is_valid(framing: Dictionary) -> bool:
	var metadata := framing.metadata as Dictionary
	return bool(metadata.target_bounds_fully_in_frame) \
		and int(metadata.target_bounds_corners_behind_camera) == 0 \
		and float(metadata.target_projected_width_ratio) >= 0.18 \
		and float(metadata.target_projected_width_ratio) <= 0.95 \
		and float(metadata.target_projected_height_ratio) >= 0.12 \
		and float(metadata.target_projected_height_ratio) <= 0.95


func _save_hero_view(main: GameMain, player: PlayerController, hud: GameHUD, view: Dictionary, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s did not stabilize for capture." % str(view.id)}
	var hud_state := _hud_state(hud)
	if bool(hud_state.debug_panel_visible) or bool(hud_state.feedback_panel_visible) or bool(hud_state.load_panel_visible) or bool(hud_state.pause_panel_visible) or not bool(hud_state.reticle_visible):
		return {"ok": false, "message": "%s HUD state is not clean and ordinary." % str(view.id)}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s returned an empty or wrong-sized image." % str(view.id)}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s native image appears blank." % str(view.id)}
	var relative := "images/%s.png" % str(view.id)
	var path := HERO_OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(view.id)}
	var metadata := {
		"id": str(view.id),
		"pair_id": str(view.pair_id),
		"role": str(view.role),
		"recognition_verdict": "pending_independent_review",
		"file": relative,
		"sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [image.get_width(), image.get_height()],
		"sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range),
		"hud": hud_state,
		"debug_labels_visible": false,
		"source_photography_in_frame": false,
	}
	metadata.merge(extra, true)
	print("BUILDING_3_HERO_CAPTURE: id=%s grounded=%s receiver=%s bounds=%.3fx%.3f image=%s sha256=%s" % [str(view.id), str(metadata.physics_grounded), str(metadata.first_los_hit_receiver), float(metadata.target_projected_width_ratio), float(metadata.target_projected_height_ratio), ProjectSettings.globalize_path(path), str(metadata.sha256)])
	return {"ok": true, "metadata": metadata}
