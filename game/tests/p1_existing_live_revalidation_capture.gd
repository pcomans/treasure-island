extends SceneTree

const OUTPUT := "res://evidence/first-playable/p1-existing-live-revalidation-2026-09-04"
const CAPTURE_SIZE := Vector2i(1440, 900)
const WORLD_SOLID_MASK := 1
const SETTLE_START_HEIGHT_M := 3.0
const SETTLE_MAX_PHYSICS_FRAMES := 360
const SETTLE_CLEARANCE_TOLERANCE_M := 0.08
const MIN_ACTUAL_SPRING_LENGTH_M := 4.5
const MIN_CAMERA_HEIGHT_ABOVE_GROUND_M := 1.0
const TIMEOUT_SECONDS := 240.0
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_B3_SIGNATURE := "737a674d63824d574e28c76f75c86212dfe126c3204870cdb2d0452d5bcf6337"
const EXPECTED_HAWKINS_SIGNATURE := "d311c103c9273b94fc982588f46bae6ab67ba6be54b0d0a111dd305e39c22219"
const EXPECTED_HAWKINS_MASSING_SIGNATURE := "7c4fea5fec624ccfc3963b9fa5eb586b73ca61da0c09ae8539df3e0adb8cf291"
const EXPECTED_ISLE_HIGH_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/p1_existing_live_revalidation_capture.gd"

# These sets and gates are frozen before looking at this capture batch. They
# come directly from the 2026-09-04 P1 reference packets and must not be tuned
# in response to the rendered results.
const TARGETS := {
	"building-3": {
		"source_identity": "w34313540",
		"candidate_status": "candidate_for_no_change_whole_building_revalidation_pending_independent_review",
		"confusion_set_source_ids": ["w24274434", "r16681702"],
		"recognition_gate": "Single central dark-teal hangar opening plus the long upper band; the documented curved-crown/shoulder massing gap remains.",
		"reference_packet": "res://discovery/facades/p1_reference_packets/w34313540_building_3.md",
		"reference_packet_sha256": "3701d28e19cc7811067c171eb5a85e5efe4098d554c387679f50fed6248fb961",
		"geometry_sha256": "9ac55412ceca46cb79b5bf5bc57485f9c94f797ee3fbd43d7408cf35f4c43294",
		"receiver": "building:w34313540:wall",
		"receiver_source_keys": ["w34313540"],
		"bounds_receivers": ["building:w34313540:wall", "building:w34313540:roof"],
		"facade_child": "Building3600CaliforniaFacade",
		"facade_signature": EXPECTED_B3_SIGNATURE,
		"layout_path": "res://game/resources/facades/building_3_600_california_ene_layout.json",
		"layout_sha256": "312ed89a5bca6e3eadf3034b8e97689b9a99646837aca8f5f1f7f940a11f8299",
		"runtime_script_path": "res://game/scripts/world/facades/building_3_600_california_facade.gd",
		"runtime_script_sha256": "5808131a175fd6b43957ddb54921d247b2c6d00a71185574616a1ed5c765231d",
	},
	"hawkins": {
		"source_identity": "w1249412093",
		"candidate_status": "candidate_for_no_change_whole_building_revalidation_pending_independent_review",
		"confusion_set_source_ids": ["r19685981", "w1212173437", "w1272162518"],
		"recognition_gate": "At least two of orientation-active fine pearlescent fluting, dark HAWKINS lobby/sign ground composition, western stoops, or the six/four-story step.",
		"reference_packet": "res://discovery/facades/p1_reference_packets/w1249412093_hawkins.md",
		"reference_packet_sha256": "ed2d7c0f16c605ba775edeb443085b75c6353e44d6850a4d5746cc15dad8efc4",
		"geometry_sha256": "611ed64a5fd1f359553f14649504b553eda17707057eefe536dac61cd4168311",
		"receiver": "building:w1249412093:wall",
		"receiver_source_keys": ["w1249412093"],
		"bounds_receivers": ["building:w1249412093:wall", "building:w1249412093:roof"],
		"facade_child": "Hawkins77BrutonFacade",
		"facade_signature": EXPECTED_HAWKINS_SIGNATURE,
		"massing_signature": EXPECTED_HAWKINS_MASSING_SIGNATURE,
		"layout_path": "res://game/resources/facades/hawkins_77_bruton_layout.json",
		"layout_sha256": "4de2239af2e18fe4121930d51dee15e081d2f81a40393da2f1f29c69464761d9",
		"runtime_script_path": "res://game/scripts/world/facades/hawkins_77_bruton_facade.gd",
		"runtime_script_sha256": "de733e43896fdf8c0437dcb266564b07fbb0e0ad42a40ef40d480623a748dd1e",
		"massing_script_path": "res://game/scripts/world/massing/hawkins_77_bruton_massing.gd",
		"massing_script_sha256": "b572d5b75faf47e91e9283af757cdc33a0c0b4a37de87230d7e7a505442f6a4d",
	},
	"isle-house": {
		"source_identity": "w1249412094",
		"candidate_status": "diagnostic_only_expected_low_part_limitation_pending_independent_review",
		"confusion_set_source_ids": ["w1249412093", "w1272162518"],
		"recognition_gate": "At least two of folded white punched-opening tower, dark vertical recess, 39 active-ground address assembly, or warm handcrafted live-work low realm; the high part alone cannot excuse the generic low part.",
		"reference_packet": "res://discovery/facades/p1_reference_packets/w1249412094_isle_house.md",
		"reference_packet_sha256": "04f1009fd240cde4765095c49ba8174f90b80dbad54281d8036ef1df04c2874d",
		"geometry_sha256": "467e2e31539fa2d865ffc92ee8bd57f8d9c7a3df26ef38f1bcc384156971a7d1",
		"receiver": "building-composite:w1249412094:w1282547786:wall",
		"receiver_source_keys": ["w1282547786"],
		"low_receiver": "building-composite:w1249412094:w1282547787:wall",
		"low_receiver_source_keys": ["w1282547787"],
		"bounds_receivers": [
			"building-composite:w1249412094:w1282547786:wall",
			"building-composite:w1249412094:w1282547786:roof",
			"building-composite:w1249412094:w1282547787:wall",
			"building-composite:w1249412094:w1282547787:roof",
		],
		"facade_child": "IsleHouse39BrutonHighFacade",
		"facade_signature": EXPECTED_ISLE_HIGH_SIGNATURE,
		"layout_path": "res://game/resources/facades/isle_house_39_bruton_high_se_layout.json",
		"layout_sha256": "c5e6393e90152cef62f6478d7bd87750f3db5598d6ebc36cd307ce20acaa090d",
		"runtime_script_path": "res://game/scripts/world/facades/isle_house_39_bruton_high_facade.gd",
		"runtime_script_sha256": "f8243cedd3f331cbc37e6343b1b48e76a73a81644c96cc1f80e623e0c71a3113",
	},
}

# Fixed XZ anchors are ordinary island-side approaches. Orientation uses only
# the stock PlayerCamera yaw and pitch degrees of freedom, at stock FOV and arm
# length. No fallback pose, detached camera, hidden context, crop, or light edit
# is permitted.
const VIEWS := [
	{
		"id": "01-building-3-whole-object",
		"target": "building-3",
		"role": "whole_object_ordinary_player_view",
		"requested_xz": Vector2(571.6817, 415.5383),
		"aim_target": Vector3(507.8694, 12.0, 448.8849),
		"expected_receiver": "building:w34313540:wall",
		"expected_source_keys": ["w34313540"],
	},
	{
		"id": "02-building-3-oblique-approach",
		"target": "building-3",
		"role": "oblique_approach_ordinary_player_view",
		"requested_xz": Vector2(525.2532, 391.4638),
		"aim_target": Vector3(498.2180, 12.0, 430.4145),
		"expected_receiver": "building:w34313540:wall",
		"expected_source_keys": ["w34313540"],
	},
	{
		"id": "03-hawkins-whole-object",
		"target": "hawkins",
		"role": "whole_object_ordinary_player_view",
		"requested_xz": Vector2(2.37, 556.10),
		"aim_target": Vector3(-60.610, 14.774, 503.550),
		"expected_receiver": "building:w1249412093:wall",
		"expected_source_keys": ["w1249412093"],
	},
	{
		"id": "04-hawkins-oblique-approach",
		"target": "hawkins",
		"role": "oblique_approach_ordinary_player_view",
		"requested_xz": Vector2(7.80, 512.10),
		"aim_target": Vector3(-52.700, 14.774, 494.100),
		"expected_receiver": "building:w1249412093:wall",
		"expected_source_keys": ["w1249412093"],
	},
	{
		"id": "05-isle-house-whole-composite-diagnostic",
		"target": "isle-house",
		"role": "whole_object_ordinary_player_view",
		"requested_xz": Vector2(-204.98, 620.18),
		"aim_target": Vector3(-125.2329, 20.0, 559.8556),
		"expected_receiver": "building-composite:w1249412094:w1282547786:wall",
		"expected_source_keys": ["w1282547786"],
	},
	{
		"id": "06-isle-house-low-oblique-diagnostic",
		"target": "isle-house",
		"role": "oblique_approach_ordinary_player_view",
		"requested_xz": Vector2(-194.70, 533.80),
		"aim_target": Vector3(-145.130, 10.0, 525.450),
		"expected_receiver": "building-composite:w1249412094:w1282547787:wall",
		"expected_source_keys": ["w1282547787"],
	},
]

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("P1 exact-current evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for P1 exact-current evidence."):
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
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Actual world did not reach one clean ready state for P1 evidence."):
		_finish(main)
		return
	var ready := ready_reports[0]
	if not _require(str(ready.get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted before P1 capture.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated manifest bytes drifted before P1 capture.") \
	or not _require(Vector2i(root.get_texture().get_size()) == CAPTURE_SIZE, "P1 capture viewport is not exactly 1440x900."):
		_finish(main)
		return
	var binding_result := _validate_bindings(world)
	if not _require(bool(binding_result.get("ok", false)), str(binding_result.get("message", "P1 exact binding validation failed."))):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	for target_id: String in TARGETS.keys():
		if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images/%s" % target_id)) == OK, "Could not create %s evidence directory." % target_id):
			_finish(main)
			return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	var captures: Array[Dictionary] = []
	for view_value: Variant in VIEWS:
		var view := view_value as Dictionary
		var posed := await _settle_and_aim(world, player, hud, view)
		if not _require(bool(posed.get("ok", false)), str(posed.get("message", "%s pose failed." % str(view.id)))):
			_finish(main)
			return
		var framing := _framing_metadata(player.get_camera(), _nodes_for_keys(world, (TARGETS[str(view.target)] as Dictionary).bounds_receivers as Array))
		if not _require(bool(framing.get("ok", false)), "%s target bounds could not be projected." % str(view.id)) \
		or not _require(_framing_is_technical_valid(view, framing), "%s failed whole-object/oblique technical framing: %s" % [str(view.id), JSON.stringify(framing)]):
			_finish(main)
			return
		var los := _center_los(player, view)
		if not _require(bool(los.get("ok", false)), str(los.get("message", "%s exact first-hit LOS failed." % str(view.id)))):
			_finish(main)
			return
		var metadata := posed.metadata as Dictionary
		metadata.merge(framing.metadata as Dictionary, true)
		metadata.merge(los.metadata as Dictionary, true)
		var saved := await _save_view(main, player, hud, view, metadata)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "%s image save failed." % str(view.id)))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	var runtime := world.get_runtime_evidence()
	var manifest := {
		"schema_version": "ti.p1-existing-live-revalidation-evidence/1",
		"review_status": "pending_independent_whole_building_recognition_review_not_self_accepted",
		"recognition_verdicts": {
			"building-3": "pending_independent_review",
			"hawkins": "pending_independent_review",
			"isle-house": "pending_independent_diagnostic_review",
		},
		"evidence_role": "Exact-current technical capture evidence only; executor checked bindings, grounded player-rig provenance, first-hit LOS, framing, and image validity but made no recognition judgment.",
		"capture_command": COMMAND,
		"generator": "game/tests/p1_existing_live_revalidation_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/p1_existing_live_revalidation_capture.gd"),
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
			"minimum_actual_spring_length_m": MIN_ACTUAL_SPRING_LENGTH_M,
			"minimum_camera_height_above_ground_m": MIN_CAMERA_HEIGHT_ABOVE_GROUND_M,
			"orientation": "input_reachable_stock_PlayerCamera_yaw_plus_clamped_spring_arm_pitch",
			"detached_camera": false,
			"camera_tricks": false,
			"context_hidden": false,
			"lighting_changed": false,
			"crop_or_postprocess": false,
			"debug_labels_visible": false,
		},
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
		"targets": binding_result.metadata,
		"frozen_confusion_sets_selected_before_review": true,
		"source_photography_shipped": false,
		"capture_count": captures.size(),
		"captures": captures,
		"technical_inspection_scope": [
			"native image decodes at original 1440x900 resolution",
			"frame is nonblank and has usable luminance range",
			"actual stock player rig is physics-grounded inside the boundary",
			"debug, load, feedback, and pause panels are absent while the normal reticle remains",
			"viewport-center physics LOS first-hits the exact intended receiver and source keys",
			"whole-object or oblique target bounds are technically present without hidden context",
		],
		"recognition_review_prohibited_for_executor": true,
		"reviewer_instruction": "Open all six PNGs at original detail. Compare each target only with its cited P1 packet and frozen confusion set. Review Building 3 and Hawkins for possible no-change whole-building revalidation; treat Isle House as diagnostic and explicitly include its untreated low receiver. Do not infer acceptance from this technical manifest.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write P1 exact-current capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d technically valid pending-review P1 views on native %s/%s to %s" % [captures.size(), DisplayServer.get_name(), RenderingServer.get_video_adapter_name(), output_absolute])
	_finish(main)


func _validate_bindings(world: WorldLoader) -> Dictionary:
	var result := {}
	for target_id: String in TARGETS.keys():
		var target := TARGETS[target_id] as Dictionary
		if FileAccess.get_sha256(str(target.reference_packet)) != str(target.reference_packet_sha256):
			return {"ok": false, "message": "%s reference packet drifted." % target_id}
		if FileAccess.get_sha256(str(target.layout_path)) != str(target.layout_sha256):
			return {"ok": false, "message": "%s accepted layout drifted." % target_id}
		if FileAccess.get_sha256(str(target.runtime_script_path)) != str(target.runtime_script_sha256):
			return {"ok": false, "message": "%s live facade script drifted." % target_id}
		if target.has("massing_script_path") and FileAccess.get_sha256(str(target.massing_script_path)) != str(target.massing_script_sha256):
			return {"ok": false, "message": "%s massing script drifted." % target_id}
		var receivers := _record_nodes(world, str(target.receiver))
		if receivers.size() != 1:
			return {"ok": false, "message": "%s wall receiver count is %d rather than one." % [target_id, receivers.size()]}
		var receiver := receivers[0] as Node3D
		if receiver.get_meta("source_keys", []) != target.receiver_source_keys:
			return {"ok": false, "message": "%s wall receiver source keys drifted." % target_id}
		var facade := receiver.get_node_or_null(str(target.facade_child)) as Node3D
		if facade == null or str(facade.get_meta("deterministic_signature", "")) != str(target.facade_signature):
			return {"ok": false, "message": "%s live facade/signature did not resolve." % target_id}
		for bounds_key_value: Variant in target.bounds_receivers:
			var bounds_key := str(bounds_key_value)
			if _record_nodes(world, bounds_key).size() != 1:
				return {"ok": false, "message": "%s bounds receiver %s did not resolve exactly once." % [target_id, bounds_key]}
		if target.has("massing_signature") and str(receiver.get_meta("massing_signature", "")) != str(target.massing_signature):
			return {"ok": false, "message": "%s accepted massing signature drifted." % target_id}
		if target_id == "isle-house":
			var low_nodes := _record_nodes(world, str(target.low_receiver))
			if low_nodes.size() != 1 or (low_nodes[0] as Node3D).get_meta("source_keys", []) != target.low_receiver_source_keys:
				return {"ok": false, "message": "Isle House low receiver identity did not resolve exactly once."}
			if (low_nodes[0] as Node3D).get_node_or_null(str(target.facade_child)) != null:
				return {"ok": false, "message": "Isle House low receiver unexpectedly gained the high facade."}
			if not _record_nodes(world, "building-composite:w1249412094").is_empty():
				return {"ok": false, "message": "Meshless Isle House parent unexpectedly gained a runtime record."}
		var metadata := target.duplicate(true)
		metadata["runtime_receiver_count"] = receivers.size()
		metadata["runtime_receiver_path"] = str(receiver.get_path())
		metadata["runtime_facade_path"] = str(facade.get_path())
		metadata["runtime_facade_signature"] = str(facade.get_meta("deterministic_signature", ""))
		metadata["layout_sha256_observed"] = FileAccess.get_sha256(str(target.layout_path))
		metadata["runtime_script_sha256_observed"] = FileAccess.get_sha256(str(target.runtime_script_path))
		if target_id == "isle-house":
			metadata["parent_meshless"] = true
			metadata["low_receiver_untreated"] = true
		result[target_id] = metadata
	return {"ok": true, "metadata": result}


func _settle_and_aim(world: WorldLoader, player: PlayerController, hud: GameHUD, view: Dictionary) -> Dictionary:
	var requested_xz := view.requested_xz as Vector2
	if not world.get_boundary().contains_position(Vector3(requested_xz.x, 0.0, requested_xz.y)):
		return {"ok": false, "message": "%s fixed anchor is outside the playable boundary." % str(view.id)}
	var initial_hit := _ground_hit(player, requested_xz)
	var initial_ground := _ground_metadata(initial_hit)
	if not bool(initial_ground.get("ok", false)):
		return {"ok": false, "message": "%s fixed anchor has no walkable generated support: %s" % [str(view.id), str(initial_ground.get("message", "unknown"))]}
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
			"scenario_reset": "fixed_xz_then_real_character_physics_settle",
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
			"ground_normal_up_dot": float((final_hit.normal as Vector3).dot(Vector3.UP)),
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
		return {"ok": false, "message": "%s aim target is %.3f px from the viewport center." % [str(view.id), projected_target.distance_to(viewport_center)]}
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
	if hit_key != str(view.expected_receiver) or hit_sources != view.expected_source_keys:
		return {"ok": false, "message": "%s first LOS hit %s %s instead of %s %s." % [str(view.id), hit_key, str(hit_sources), str(view.expected_receiver), str(view.expected_source_keys)]}
	return {
		"ok": true,
		"metadata": {
			"viewport_center_px": [viewport_center.x, viewport_center.y],
			"aim_target_screen_px": [projected_target.x, projected_target.y],
			"aim_target_center_error_px": projected_target.distance_to(viewport_center),
			"first_los_hit_receiver": hit_key,
			"first_los_hit_source_keys": hit_sources,
			"first_los_hit_position_m": _vector3(hit.position as Vector3),
			"first_los_hit_normal": _vector3(hit.normal as Vector3),
			"first_los_hit_distance_m": origin.distance_to(hit.position as Vector3),
			"first_los_collision_mask": WORLD_SOLID_MASK,
			"receiver_first_los": true,
		},
	}


func _framing_metadata(camera: Camera3D, record_nodes: Array[Node3D]) -> Dictionary:
	var points: Array[Vector3] = []
	for record: Node3D in record_nodes:
		for child_value: Variant in record.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := child_value as MeshInstance3D
			if mesh_instance == null or mesh_instance.mesh == null or not mesh_instance.is_visible_in_tree():
				continue
			var bounds := mesh_instance.get_aabb()
			for x_index in 2:
				for y_index in 2:
					for z_index in 2:
						var local := bounds.position + Vector3(bounds.size.x * x_index, bounds.size.y * y_index, bounds.size.z * z_index)
						points.append(mesh_instance.global_transform * local)
	if points.is_empty():
		return {"ok": false}
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	var behind := 0
	for point: Vector3 in points:
		if camera.is_position_behind(point):
			behind += 1
			continue
		var screen := camera.unproject_position(point)
		minimum = minimum.min(screen)
		maximum = maximum.max(screen)
	if behind == points.size():
		return {"ok": false}
	var size := maximum - minimum
	return {
		"ok": true,
		"metadata": {
			"target_bounds_mesh_corner_count": points.size(),
			"target_bounds_corners_behind_camera": behind,
			"target_projected_min_px": [minimum.x, minimum.y],
			"target_projected_max_px": [maximum.x, maximum.y],
			"target_projected_width_ratio": size.x / CAPTURE_SIZE.x,
			"target_projected_height_ratio": size.y / CAPTURE_SIZE.y,
			"target_bounds_fully_in_frame": minimum.x >= 0.0 and minimum.y >= 0.0 and maximum.x <= CAPTURE_SIZE.x and maximum.y <= CAPTURE_SIZE.y,
		},
	}


func _framing_is_technical_valid(view: Dictionary, framing: Dictionary) -> bool:
	var metadata := framing.metadata as Dictionary
	var width_ratio := float(metadata.target_projected_width_ratio)
	var height_ratio := float(metadata.target_projected_height_ratio)
	if int(metadata.target_bounds_corners_behind_camera) != 0 or width_ratio < 0.08 or height_ratio < 0.08:
		return false
	if str(view.role).begins_with("whole_object"):
		return bool(metadata.target_bounds_fully_in_frame) and width_ratio <= 0.95 and height_ratio <= 0.95
	return width_ratio <= 1.35 and height_ratio <= 1.35


func _save_view(main: GameMain, player: PlayerController, hud: GameHUD, view: Dictionary, extra: Dictionary) -> Dictionary:
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
	var relative := "images/%s/%s.png" % [str(view.target), str(view.id)]
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save its PNG." % str(view.id)}
	var target := TARGETS[str(view.target)] as Dictionary
	var metadata := {
		"id": str(view.id),
		"target": str(view.target),
		"source_identity": str(target.source_identity),
		"role": str(view.role),
		"candidate_status": str(target.candidate_status),
		"recognition_verdict": "pending_independent_review",
		"confusion_set_source_ids_frozen_before_review": target.confusion_set_source_ids,
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
	print("P1_REVALIDATION_CAPTURE: id=%s receiver=%s grounded=%s arm=%.3f bounds=%.3fx%.3f image=%s sha256=%s" % [
		str(view.id), str(metadata.first_los_hit_receiver), str(metadata.physics_grounded), float(metadata.actual_spring_length_m),
		float(metadata.target_projected_width_ratio), float(metadata.target_projected_height_ratio),
		ProjectSettings.globalize_path(path), str(metadata.sha256),
	])
	return {"ok": true, "metadata": metadata}


func _record_nodes(world: WorldLoader, key: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		# Collision bodies intentionally repeat receiver/source metadata. Only the
		# generated record owner carries feature_kind and participates in binding.
		if str(value.get_meta("derived_object_key", "")) == key and value.has_meta("feature_kind"):
			result.append(value as Node3D)
	return result


func _nodes_for_keys(world: WorldLoader, keys: Array) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for key_value: Variant in keys:
		result.append_array(_record_nodes(world, str(key_value)))
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
		_fail("P1 exact-current native evidence timed out after %.0f seconds." % TIMEOUT_SECONDS)
		_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	if main != null and is_instance_valid(main):
		main.queue_free()
	quit(1 if not _failure.is_empty() else 0)
