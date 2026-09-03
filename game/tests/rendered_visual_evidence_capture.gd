extends SceneTree

const REGIONAL_QA_ANCHORS := preload("res://game/tests/regional_qa_anchors.gd")
const OUTPUT_ARG_PREFIX := "--visual-evidence-output="
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_FERRY_SPAWN := Vector3(-104.364, 3.457, 786.024)
const EXPECTED_FERRY_YAW := -0.119
const EXPECTED_CHUNKS := 38
const EXPECTED_PLAYABLE_ROWS := 735
const EXPECTED_CONTEXT_ROWS := 4
const EXPECTED_RECORDS := 729
const EXPECTED_GENERATED_MESHES := 729
const EXPECTED_GENERATED_SURFACES := 739
const EXPECTED_GENERATED_TRIANGLES := 48389
const EXPECTED_RUNTIME_MESHES := 1278
const EXPECTED_RUNTIME_SURFACES := 1288
const EXPECTED_RUNTIME_TRIANGLES := 55067
const EXPECTED_BODIES := 466
const EXPECTED_VEGETATION_SEED := 1414092337
const EXPECTED_VEGETATION_INSTANCES := 124
const EXPECTED_VEGETATION_ASSETS := 15
const EXPECTED_VEGETATION_BATCHES := 19
const EXPECTED_PALM_BATCHES := 7
const EXPECTED_PALM_SURFACES := 8
const EXPECTED_PALM_FOLIAGE_SURFACES := 5
const EXPECTED_PALM_WOOD_SURFACES := 3
const EXPECTED_PALM_FOLIAGE_ALBEDO := Color(0.16, 0.38, 0.16, 1.0)
const EXPECTED_PALM_WOOD_ALBEDO := Color(0.36, 0.23, 0.12, 1.0)
const EXPECTED_CAPTURE_COUNT := 12
const EXPECTED_CAPTURE_IDS := [
	"01-ferry-spawn",
	"02-north",
	"03-center",
	"04-southwest",
	"05-east-perimeter",
	"06-building-1-public-curve",
	"07-horizon-context",
	"08-ybi-bridge-context",
	"09-eligible-wall-tag",
	"10-vegetation-south-ground",
	"11-jetpack-ascent",
	"12-jetpack-released-descent",
]
const WORLD_SOLID_MASK := 1
const SPRAY_SURFACE_MASK := 1 << 2
const CAPTURE_WIDTH := 1440
const CAPTURE_HEIGHT := 900
const MIN_BILLBOARD_PROJECTED_WIDTH_RATIO := 0.30
const CAPTURE_PITCH_RADIANS := -0.13962634015954636
const SETTLE_START_HEIGHT_M := 3.0
const SETTLE_MAX_PHYSICS_FRAMES := 360
const SETTLE_CLEARANCE_TOLERANCE_M := 0.08
const CAPTURE_TIMEOUT_SECONDS := 180.0
const BUILDING_1_RECEIVER_KEY := "building:r16681702:wall"
const BUILDING_1_PUBLIC_CURVE_CAPTURE := {
	"id": "06-building-1-public-curve",
	"region": "building_1_public_curve",
	"requested_xz": Vector2(-72.908752, 757.150635),
	"aim_target": Vector3(0.941, 16.281, 749.703),
	"reference_capture": "evidence/first-playable/treasure-island-building-1-recognizability-composition-2026-08-30/images/02-after-ordinary-public-curve.png",
	"intent": "Physics-grounded ordinary third-person view of the independently accepted Building 1 public-curve composition",
}
const JETPACK_ASCENT_PHYSICS_FRAMES := 45
const JETPACK_DESCENT_TRANSITION_MAX_FRAMES := 90
const JETPACK_CLEARLY_LOWER_THAN_ASCENT_M := 1.0
const JETPACK_LOWER_DESCENT_MAX_PHYSICS_FRAMES := 120
const JETPACK_MAX_OBSERVED_STEP_M := 0.20

# Each view faces a fixed island-side target so the result does not depend on
# input timing, mouse state, or GUI automation.
const CAPTURES := REGIONAL_QA_ANCHORS.CAPTURES
const VISUAL_CAPTURE_OVERRIDES := {
	"02-north": {
		"requested_xz": Vector2(-50.0, -780.0),
		"terrain_y_m": 3.207,
		"aim_target": Vector3(37.864, 5.906, -627.358),
		"expected_target_receiver": "building:w34313564:wall",
		"intent": "Physics-grounded north-island road view along an unobstructed ordinary-play sightline to accepted w34313564 facade work",
	},
	"03-center": {
		"aim_target": Vector3(-167.540, 8.462, 88.677),
		"expected_target_receiver": "building:w34313520:wall",
		"intent": "Physics-grounded central-grid view along an ordinary-play sightline to accepted w34313520 facade work",
	},
	"04-southwest": {
		"aim_target": Vector3(-360.0, 8.0, 155.0),
		"intent": "Physics-grounded southwest view along the existing road-and-lawn approach to the deliberate south palm rows",
	},
	"05-east-perimeter": {
		"aim_target": Vector3(447.347, 13.142, 481.730),
		"expected_target_receiver": "building:w34313540:wall",
		"intent": "Physics-grounded east-perimeter view back across the shoreline-side ground toward the accepted Building 3 receiver",
	},
}
const VEGETATION_GROUND_CAPTURES := [
	{
		"id": "10-vegetation-south-ground",
		"region": "vegetation_south_ground",
		"requested_xz": Vector2(-300.0, 230.0),
		"aim_target": Vector3(-355.0, 8.0, 150.0),
		"intent": "Physics-grounded ordinary-play view from outside the planting bed along the deliberate south palm rows",
	},
]

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(CAPTURE_TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Rendered evidence requires a real rendering display; the headless driver is dummy-only in this Godot build.")
		_finish(null)
		return
	var main_scene := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(main_scene != null, "Main scene could not be loaded."):
		_finish(null)
		return
	var main := main_scene.instantiate() as GameMain
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
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - wait_started < 30000:
		await process_frame
	if not _require(load_failures.is_empty(), "Full-world load failed: %s" % [load_failures]) \
	or not _require(ready_reports.size() == 1, "Expected one world_ready signal, got %d." % ready_reports.size()):
		_finish(main)
		return

	var report: Dictionary = ready_reports[0]
	var evidence := world.get_runtime_evidence()
	var spawn := world.get_spawn_transform()
	var records := _record_nodes(main)
	var generated_topology := _inspect_generated_records(records)
	if not _require(world.is_world_validated(), "World was not retained as validated.") \
	or not _require(str(report.get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Manifest file hash drifted.") \
	or not _require(spawn.origin.is_equal_approx(EXPECTED_FERRY_SPAWN), "Ferry spawn origin drifted.") \
	or not _require(spawn.basis.is_equal_approx(Basis(Vector3.UP, EXPECTED_FERRY_YAW)), "Ferry spawn yaw drifted.") \
	or not _require(evidence.chunks_loaded == EXPECTED_CHUNKS and evidence.chunks_expected == EXPECTED_CHUNKS, "Full chunk set was not loaded.") \
	or not _require(evidence.playable_rows == EXPECTED_PLAYABLE_ROWS and evidence.context_rows == EXPECTED_CONTEXT_ROWS, "Coverage counts drifted.") \
	or not _require(records.size() == EXPECTED_RECORDS, "Generated record count drifted.") \
	or not _require(int(generated_topology.meshes) == EXPECTED_GENERATED_MESHES and int(generated_topology.surfaces) == EXPECTED_GENERATED_SURFACES and int(generated_topology.triangles) == EXPECTED_GENERATED_TRIANGLES, "Generated record-owned topology drifted.") \
	or not _require(evidence.mesh_instances == EXPECTED_RUNTIME_MESHES and evidence.surfaces == EXPECTED_RUNTIME_SURFACES and evidence.triangles == EXPECTED_RUNTIME_TRIANGLES, "Exact-current runtime topology drifted.") \
	or not _require(evidence.static_bodies == EXPECTED_BODIES and evidence.shapes == EXPECTED_BODIES, "Physics counts drifted."):
		_finish(main)
		return
	if not _require(evidence.vegetation_seed == EXPECTED_VEGETATION_SEED and evidence.vegetation_instances == EXPECTED_VEGETATION_INSTANCES, "Vegetation seed/count drifted.") \
	or not _require(evidence.vegetation_assets == EXPECTED_VEGETATION_ASSETS and evidence.vegetation_multimesh_batches == EXPECTED_VEGETATION_BATCHES, "Vegetation batching drifted."):
		_finish(main)
		return
	var palm_material_contract := _inspect_palm_visual_contract(world)
	if not _require(bool(palm_material_contract.get("ok", false)), str(palm_material_contract.get("message", "Palm material contract failed."))):
		_finish(main)
		return

	var output_directory := _output_directory()
	if not _require(not output_directory.is_empty(), "Exact-current capture requires an explicit fresh %s path." % OUTPUT_ARG_PREFIX):
		_finish(main)
		return
	var absolute_output := ProjectSettings.globalize_path(output_directory)
	if not _require(not DirAccess.dir_exists_absolute(absolute_output), "Capture output already exists; refusing to overwrite: %s" % absolute_output):
		_finish(main)
		return
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_output)
	if not _require(directory_error == OK, "Could not create capture output directory: %s" % absolute_output):
		_finish(main)
		return

	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.set_gameplay_enabled(false)
	hud.set_paused(false)
	await physics_frame
	var captures: Array[Dictionary] = []
	for definition: Dictionary in CAPTURES:
		var result := await _capture_view(definition, output_directory, world, player)
		if not _require(bool(result.get("ok", false)), str(result.get("message", "Capture failed."))):
			_finish(main)
			return
		captures.append(result.metadata)
	var building_result := await _capture_building_1_public_curve(output_directory, world, player)
	if not _require(bool(building_result.get("ok", false)), str(building_result.get("message", "Building 1 public-curve capture failed."))):
		_finish(main)
		return
	captures.append(building_result.metadata)
	var context_result := await _capture_context_views(output_directory, world, player)
	if not _require(bool(context_result.get("ok", false)), str(context_result.get("message", "Horizon-context captures failed."))):
		_finish(main)
		return
	for context_metadata: Dictionary in context_result.captures:
		captures.append(context_metadata)
	var tag_result := await _capture_near_wall_tag(output_directory, world, player, evidence)
	if not _require(bool(tag_result.get("ok", false)), str(tag_result.get("message", "Near-wall tag capture failed."))):
		_finish(main)
		return
	captures.append(tag_result.metadata)
	for definition: Dictionary in VEGETATION_GROUND_CAPTURES:
		var result := await _capture_view(definition, output_directory, world, player)
		if not _require(bool(result.get("ok", false)), str(result.get("message", "Vegetation ground capture failed."))):
			_finish(main)
			return
		captures.append(result.metadata)
	var jetpack_result := await _capture_jetpack_sequence(output_directory, world, player, evidence)
	if not _require(bool(jetpack_result.get("ok", false)), str(jetpack_result.get("message", "Jetpack capture sequence failed."))):
		_finish(main)
		return
	for jetpack_metadata: Dictionary in jetpack_result.captures:
		captures.append(jetpack_metadata)
	var capture_ids := _capture_ids(captures)
	if not _require(captures.size() == EXPECTED_CAPTURE_COUNT, "Expected exactly %d captures, got %d." % [EXPECTED_CAPTURE_COUNT, captures.size()]) \
	or not _require(capture_ids == EXPECTED_CAPTURE_IDS, "Capture order/identity drifted: %s." % [capture_ids]):
		_finish(main)
		return

	var manifest := {
		"schema_version": 4,
		"generator": "game/tests/rendered_visual_evidence_capture.gd",
		"evidence_scope": "exact-current source-project native renderer; static views do not prove traversal; only captures 11 and 12 provide time-connected public-input movement evidence",
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"project_rendering_contract": "Forward+",
		"viewport": [CAPTURE_WIDTH, CAPTURE_HEIGHT],
		"source_project_identity": {
			"project_file": "project.godot",
			"project_file_sha256": FileAccess.get_sha256("res://project.godot"),
			"capture_harness": "game/tests/rendered_visual_evidence_capture.gd",
			"capture_harness_sha256": FileAccess.get_sha256("res://game/tests/rendered_visual_evidence_capture.gd"),
			"main_script": "game/scripts/main.gd",
			"main_script_sha256": FileAccess.get_sha256("res://game/scripts/main.gd"),
			"vegetation_builder": "game/scripts/world/vegetation_builder.gd",
			"vegetation_builder_sha256": FileAccess.get_sha256("res://game/scripts/world/vegetation_builder.gd"),
			"binding_scope": "Exact source-project files executed by this harness; no exported-package execution is claimed.",
		},
		"content_sha256": EXPECTED_CONTENT_SHA256,
		"manifest_sha256": EXPECTED_MANIFEST_SHA256,
		"capture_count": captures.size(),
		"capture_ids": capture_ids,
		"scenario_reset_policy": "Every scenario starts from a disclosed fixed player-transform reset; grounded scenarios run real physics to land before capture.",
		"movement_proof_capture_ids": ["11-jetpack-ascent", "12-jetpack-released-descent"],
		"world_counts": {
			"chunks": evidence.chunks_loaded,
			"playable_rows": evidence.playable_rows,
			"context_rows": evidence.context_rows,
			"records": records.size(),
			"generated_meshes": generated_topology.meshes,
			"generated_surfaces": generated_topology.surfaces,
			"generated_triangles": generated_topology.triangles,
			"runtime_meshes": evidence.mesh_instances,
			"runtime_surfaces": evidence.surfaces,
			"runtime_triangles": evidence.triangles,
			"bodies": evidence.static_bodies,
			"shapes": evidence.shapes,
			"vegetation_seed": evidence.vegetation_seed,
			"vegetation_instances": evidence.vegetation_instances,
			"vegetation_assets": evidence.vegetation_assets,
			"vegetation_multimesh_batches": evidence.vegetation_multimesh_batches,
			"vegetation_rendered_triangles": evidence.vegetation_rendered_triangles,
		},
		"palm_material_contract": palm_material_contract,
		"captures": captures,
	}
	var manifest_path := output_directory.path_join("capture-manifest.json")
	var manifest_file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if not _require(manifest_file != null, "Could not write capture manifest: %s" % manifest_path):
		_finish(main)
		return
	manifest_file.store_string(JSON.stringify(manifest, "  ", false) + "\n")
	manifest_file.close()
	print("VISUAL_CAPTURE_MANIFEST: path=%s captures=%d content=%s manifest=%s" % [
		ProjectSettings.globalize_path(manifest_path), captures.size(), EXPECTED_CONTENT_SHA256, EXPECTED_MANIFEST_SHA256,
	])
	print("PASS: captured %d exact-current deterministic views with disclosed resets and time-connected public-input jetpack ascent/descent" % captures.size())
	_finish(main)


func _capture_view(definition: Dictionary, output_directory: String, world: WorldLoader, player: PlayerController) -> Dictionary:
	var capture_definition := definition.duplicate(true)
	var override_value: Variant = VISUAL_CAPTURE_OVERRIDES.get(str(definition.id), {})
	var has_capture_override := override_value is Dictionary and not (override_value as Dictionary).is_empty()
	if has_capture_override:
		capture_definition.merge(override_value as Dictionary, true)
	var requested_xz: Vector2 = capture_definition.requested_xz
	var settlement := await _settle_player(
		requested_xz,
		capture_definition.id,
		world,
		player,
		float(capture_definition.get("terrain_y_m", INF)),
	)
	if not bool(settlement.get("ok", false)):
		return settlement
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var yaw := float(capture_definition.get("yaw", 0.0))
	var pitch := float(capture_definition.get("pitch", CAPTURE_PITCH_RADIANS))
	if capture_definition.has("aim_target"):
		_aim_camera_at(player, capture_definition.aim_target as Vector3)
	else:
		player.global_transform = Transform3D(Basis(Vector3.UP, yaw), player.global_position)
		rig.rotation = Vector3.ZERO
		arm.rotation = Vector3(pitch, 0.0, 0.0)
	player.force_update_transform()
	rig.force_update_transform()
	arm.force_update_transform()
	if not await _wait_for_render(player):
		return {"ok": false, "message": "%s could not keep the pause overlay hidden for capture." % capture_definition.id}
	var extra_metadata: Dictionary = settlement.metadata.duplicate(true)
	extra_metadata["yaw"] = yaw
	extra_metadata["pitch"] = pitch
	if has_capture_override:
		extra_metadata["capture_override_from_shared_regional_anchor"] = true
		extra_metadata["shared_regional_requested_xz"] = [definition.requested_xz.x, definition.requested_xz.y]
		extra_metadata["shared_regional_yaw"] = float(definition.yaw)
	if capture_definition.has("aim_target"):
		var aim_target := capture_definition.aim_target as Vector3
		var camera := player.get_camera()
		if camera.is_position_behind(aim_target) or not camera.is_position_in_frustum(aim_target):
			return {"ok": false, "message": "%s composition target is outside the ordinary third-person camera frustum." % capture_definition.id}
		extra_metadata["camera_aim_target"] = [aim_target.x, aim_target.y, aim_target.z]
		extra_metadata["camera_aim_target_screen"] = _vector2_array(camera.unproject_position(aim_target))
		if capture_definition.has("expected_target_receiver"):
			var expected_receiver := str(capture_definition.expected_target_receiver)
			var target_hit := _world_blocker_between(camera.global_position, aim_target, player)
			var target_receiver := _derived_object_key_for_collider(target_hit.get("collider", null))
			if target_receiver != expected_receiver:
				return {"ok": false, "message": "%s intended receiver sightline hit %s rather than %s." % [capture_definition.id, target_receiver, expected_receiver]}
			extra_metadata["composition_target_receiver"] = target_receiver
		extra_metadata["composition_claim"] = "fixed grounded camera sightline only; no traversal claim"
	return _save_current_view(capture_definition, output_directory, player, extra_metadata)


func _capture_building_1_public_curve(output_directory: String, world: WorldLoader, player: PlayerController) -> Dictionary:
	var receiver := _record_node_for_key(world, BUILDING_1_RECEIVER_KEY)
	var facade := receiver.get_node_or_null("Building1RecognizableFacade") if receiver != null else null
	if receiver == null or facade == null or not facade.is_visible_in_tree():
		return {"ok": false, "message": "The accepted Building 1 public-curve facade is missing from the exact-current world."}
	var settlement := await _settle_player(
		BUILDING_1_PUBLIC_CURVE_CAPTURE.requested_xz,
		BUILDING_1_PUBLIC_CURVE_CAPTURE.id,
		world,
		player,
	)
	if not bool(settlement.get("ok", false)):
		return settlement
	var target: Vector3 = BUILDING_1_PUBLIC_CURVE_CAPTURE.aim_target
	_aim_camera_at(player, target)
	if not await _wait_for_render(player):
		return {"ok": false, "message": "Building 1 public-curve view could not keep the pause overlay hidden."}
	var metadata: Dictionary = settlement.metadata.duplicate(true)
	metadata.merge({
		"camera_aim_target": [target.x, target.y, target.z],
		"receiver_key": BUILDING_1_RECEIVER_KEY,
		"accepted_facade_present": true,
		"reference_capture": BUILDING_1_PUBLIC_CURVE_CAPTURE.reference_capture,
		"reference_pose_use": "The accepted target and horizontal camera anchor are reused; this frame uses the real third-person player camera at grounded eye height.",
	}, true)
	return _save_current_view(BUILDING_1_PUBLIC_CURVE_CAPTURE, output_directory, player, metadata)


func _capture_jetpack_sequence(output_directory: String, world: WorldLoader, player: PlayerController, evidence: RuntimeEvidence) -> Dictionary:
	var settlement := await _settle_player(
		Vector2(EXPECTED_FERRY_SPAWN.x, EXPECTED_FERRY_SPAWN.z),
		"11-12-jetpack-sequence",
		world,
		player,
		EXPECTED_FERRY_SPAWN.y,
	)
	if not bool(settlement.get("ok", false)):
		return settlement
	if not InputMap.has_action("jetpack") or not _action_has_physical_key("jetpack", KEY_SPACE):
		return {"ok": false, "message": "Public jetpack action is missing its physical Space binding."}

	player.global_transform = Transform3D(Basis(Vector3.UP, EXPECTED_FERRY_YAW), player.global_position)
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3(CAPTURE_PITCH_RADIANS, 0.0, 0.0)
	player.force_update_transform()
	rig.force_update_transform()
	arm.force_update_transform()
	if not await _wait_for_render(player):
		return {"ok": false, "message": "Jetpack start view could not keep the pause overlay hidden."}

	var start_position := player.global_position
	var recovery_count_before := evidence.recovery_count
	var motion_state := {
		"previous_position": start_position,
		"maximum_observed_step_m": 0.0,
		"motion_samples": 0,
	}
	var input_start_physics_frame := Engine.get_physics_frames()
	player.set_gameplay_enabled(true)
	Input.action_press("jetpack")
	if not Input.is_action_pressed("jetpack"):
		_clear_gameplay_input()
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": "Synthetic press did not engage the public jetpack action."}
	for _frame in JETPACK_ASCENT_PHYSICS_FRAMES:
		await physics_frame
		var step_failure := _record_jetpack_motion_step(player, world, evidence, recovery_count_before, motion_state)
		if not step_failure.is_empty():
			_clear_gameplay_input()
			player.set_gameplay_enabled(false)
			return {"ok": false, "message": step_failure}
	if not await _wait_for_active_render(player):
		_clear_gameplay_input()
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": "Jetpack ascent could not keep the pause overlay hidden."}
	var ascent_step_failure := _record_jetpack_motion_step(player, world, evidence, recovery_count_before, motion_state)
	if not ascent_step_failure.is_empty():
		_clear_gameplay_input()
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": ascent_step_failure}
	var ascent_position := player.global_position
	var ascent_capture_physics_frame := Engine.get_physics_frames()
	var ascent_velocity_y := player.velocity.y
	var ascent_rise_m := ascent_position.y - start_position.y
	var ascent_frames := Engine.get_physics_frames() - input_start_physics_frame
	var recovery_delta := evidence.recovery_count - recovery_count_before
	if ascent_rise_m <= 1.5 or ascent_velocity_y <= 0.0 \
	or ascent_velocity_y > player.jetpack_ascent_speed_mps + 0.01 \
	or recovery_delta != 0:
		_clear_gameplay_input()
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": "Input-driven jetpack ascent contract failed: rise=%.3f velocity=%.3f recovery_delta=%d." % [ascent_rise_m, ascent_velocity_y, recovery_delta]}
	var ascent_definition := {
		"id": "11-jetpack-ascent",
		"region": "ferry_jetpack_ascent",
		"intent": "Time-connected ordinary third-person frame during a held public jetpack action with measured positive ascent",
	}
	var ascent_metadata: Dictionary = settlement.metadata.duplicate(true)
	ascent_metadata.merge({
		"physics_grounded": false,
		"ground_clearance_m": ascent_position.y - float(settlement.metadata.ground_y),
		"scenario_reset": "fixed_player_transform_then_physics_settle_before_input",
		"movement_proof": true,
		"input_driven_after_reset": true,
		"public_input_action": "jetpack",
		"physical_key": "Space",
		"input_state_at_capture": "pressed",
		"harness_transform_policy_after_input_start": "no player transform writes",
		"start_position": _vector3_array(start_position),
		"capture_position": _vector3_array(ascent_position),
		"input_start_physics_frame": input_start_physics_frame,
		"capture_physics_frame": ascent_capture_physics_frame,
		"physics_frames_since_input_start": ascent_frames,
		"rise_m": ascent_rise_m,
		"vertical_velocity_mps": ascent_velocity_y,
		"recovery_delta": recovery_delta,
		"harness_transform_writes_after_input_start": 0,
		"motion_samples": motion_state.motion_samples,
		"maximum_observed_step_m": motion_state.maximum_observed_step_m,
	}, true)
	var ascent_saved := _save_current_view(ascent_definition, output_directory, player, ascent_metadata)
	if not bool(ascent_saved.get("ok", false)):
		_clear_gameplay_input()
		player.set_gameplay_enabled(false)
		return ascent_saved

	Input.action_release("jetpack")
	var release_position := player.global_position
	var release_physics_frame := Engine.get_physics_frames()
	var reached_capped_descent := false
	for _frame in JETPACK_DESCENT_TRANSITION_MAX_FRAMES:
		await physics_frame
		var step_failure := _record_jetpack_motion_step(player, world, evidence, recovery_count_before, motion_state)
		if not step_failure.is_empty():
			_clear_gameplay_input()
			player.set_gameplay_enabled(false)
			return {"ok": false, "message": step_failure}
		if player.velocity.y <= -player.jetpack_descent_speed_mps + 0.05:
			reached_capped_descent = true
			break
	if not reached_capped_descent:
		_clear_gameplay_input()
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": "Released public jetpack action did not reach capped slow descent."}
	var capped_descent_start_position := player.global_position
	var capped_descent_frames := 0
	while capped_descent_frames < JETPACK_LOWER_DESCENT_MAX_PHYSICS_FRAMES \
	and player.global_position.y > ascent_position.y - JETPACK_CLEARLY_LOWER_THAN_ASCENT_M:
		await physics_frame
		capped_descent_frames += 1
		var step_failure := _record_jetpack_motion_step(player, world, evidence, recovery_count_before, motion_state)
		if not step_failure.is_empty():
			_clear_gameplay_input()
			player.set_gameplay_enabled(false)
			return {"ok": false, "message": step_failure}
	if player.global_position.y > ascent_position.y - JETPACK_CLEARLY_LOWER_THAN_ASCENT_M:
		_clear_gameplay_input()
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": "Released slow descent did not reach a clearly lower state than frame 11 within %d physics frames." % JETPACK_LOWER_DESCENT_MAX_PHYSICS_FRAMES}
	if not await _wait_for_active_render(player):
		_clear_gameplay_input()
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": "Jetpack slow-descent view could not keep the pause overlay hidden."}
	var descent_step_failure := _record_jetpack_motion_step(player, world, evidence, recovery_count_before, motion_state)
	if not descent_step_failure.is_empty():
		_clear_gameplay_input()
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": descent_step_failure}
	var descent_position := player.global_position
	var descent_capture_physics_frame := Engine.get_physics_frames()
	var descent_velocity_y := player.velocity.y
	var capped_descent_drop_m := capped_descent_start_position.y - descent_position.y
	var descent_below_ascent_m := ascent_position.y - descent_position.y
	var release_frames := Engine.get_physics_frames() - release_physics_frame
	recovery_delta = evidence.recovery_count - recovery_count_before
	if Input.is_action_pressed("jetpack") \
	or player.is_on_floor() \
	or descent_velocity_y > -player.jetpack_descent_speed_mps + 0.05 \
	or descent_velocity_y < -player.jetpack_descent_speed_mps - 0.01 \
	or capped_descent_drop_m <= JETPACK_CLEARLY_LOWER_THAN_ASCENT_M \
	or descent_below_ascent_m < JETPACK_CLEARLY_LOWER_THAN_ASCENT_M \
	or recovery_delta != 0:
		_clear_gameplay_input()
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": "Released jetpack slow-descent contract failed: capped_drop=%.3f below_ascent=%.3f velocity=%.3f recovery_delta=%d." % [capped_descent_drop_m, descent_below_ascent_m, descent_velocity_y, recovery_delta]}
	var descent_definition := {
		"id": "12-jetpack-released-descent",
		"region": "ferry_jetpack_released_descent",
		"intent": "Time-connected ordinary third-person frame after releasing the public jetpack action at the measured slow-descent cap",
	}
	var descent_metadata: Dictionary = settlement.metadata.duplicate(true)
	descent_metadata.merge({
		"physics_grounded": false,
		"ground_clearance_m": descent_position.y - float(settlement.metadata.ground_y),
		"scenario_reset": "same_time_connected_sequence_as_11_jetpack_ascent",
		"movement_proof": true,
		"input_driven_after_reset": true,
		"public_input_action": "jetpack",
		"physical_key": "Space",
		"input_state_at_capture": "released",
		"harness_transform_policy_after_input_start": "no player transform writes",
		"start_position": _vector3_array(start_position),
		"ascent_capture_position": _vector3_array(ascent_position),
		"release_position": _vector3_array(release_position),
		"capped_descent_start_position": _vector3_array(capped_descent_start_position),
		"capture_position": _vector3_array(descent_position),
		"input_start_physics_frame": input_start_physics_frame,
		"release_physics_frame": release_physics_frame,
		"capture_physics_frame": descent_capture_physics_frame,
		"physics_frames_since_release": release_frames,
		"rise_before_release_m": ascent_rise_m,
		"drop_at_capped_descent_m": capped_descent_drop_m,
		"descent_below_ascent_capture_m": descent_below_ascent_m,
		"capped_descent_physics_frames": capped_descent_frames,
		"vertical_velocity_mps": descent_velocity_y,
		"recovery_delta": recovery_delta,
		"harness_transform_writes_after_input_start": 0,
		"motion_samples": motion_state.motion_samples,
		"maximum_observed_step_m": motion_state.maximum_observed_step_m,
	}, true)
	var descent_saved := _save_current_view(descent_definition, output_directory, player, descent_metadata)
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	if not bool(descent_saved.get("ok", false)):
		return descent_saved
	print("VISUAL_JETPACK: rise=%.3fm ascent_velocity=%.3fmps ascent_frames=%d capped_drop=%.3fm below_ascent=%.3fm capped_descent_frames=%d descent_velocity=%.3fmps release_frames=%d recoveries=%d max_observed_step=%.3fm" % [
		ascent_rise_m, ascent_velocity_y, ascent_frames, capped_descent_drop_m, descent_below_ascent_m,
		capped_descent_frames, descent_velocity_y, release_frames, recovery_delta, float(motion_state.maximum_observed_step_m),
	])
	return {"ok": true, "captures": [ascent_saved.metadata, descent_saved.metadata]}


func _capture_near_wall_tag(output_directory: String, world: WorldLoader, player: PlayerController, evidence: RuntimeEvidence) -> Dictionary:
	var wall_face := _find_near_wall_face(world, player)
	if wall_face.is_empty():
		return {"ok": false, "message": "Could not find a deterministic eligible wall with an in-bound ground approach."}
	var approach: Vector3 = wall_face.approach
	var settlement := await _settle_player(Vector2(approach.x, approach.z), "09-eligible-wall-tag", world, player)
	if not bool(settlement.get("ok", false)):
		return settlement
	var target: Vector3 = wall_face.center
	player.global_transform = Transform3D(Basis.IDENTITY, player.global_position)
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3.ZERO
	rig.look_at(target, Vector3.UP)
	player.force_update_transform()
	rig.force_update_transform()
	arm.force_update_transform()
	if not await _wait_for_render(player):
		return {"ok": false, "message": "Near-wall aim could not keep the pause overlay hidden."}
	var spray_hit := _camera_spray_hit(player)
	if spray_hit.is_empty():
		return {"ok": false, "message": "Near-wall camera ray did not hit a spray surface."}
	var hit_collider := spray_hit.get("collider") as CollisionObject3D
	var expected_object := str(wall_face.object_key)
	if hit_collider == null or not hit_collider.is_in_group("spray_receiver_wall") \
	or str(hit_collider.get_meta("derived_object_key", "")) != expected_object:
		return {"ok": false, "message": "Near-wall camera did not resolve the selected eligible wall first."}
	var controller := player.get_spray_controller()
	var pool := controller.tag_instances
	var active_before := pool.active_count()
	var placed_before := int(evidence.spray_counts.placed)
	controller.attempt_spray()
	await process_frame
	if not await _wait_for_render(player):
		return {"ok": false, "message": "Tagged-wall view could not keep the pause overlay hidden."}
	if pool.active_count() != active_before + 1 or int(evidence.spray_counts.placed) != placed_before + 1:
		return {"ok": false, "message": "Real spray controller did not place exactly one tag."}
	var tag := pool.get_child(pool.get_child_count() - 1) as Decal
	var tag_sources: Array = wall_face.source_keys
	if tag == null or str(tag.get_meta("derived_object_key", "")) != expected_object \
	or tag.get_meta("source_keys", []) != tag_sources \
	or tag.texture_albedo == null \
	or tag.global_position.distance_to(spray_hit.position) > 0.05:
		return {"ok": false, "message": "Placed tag identity, texture, or transform did not match the live wall hit."}
	var definition := {
		"id": "09-eligible-wall-tag",
		"region": "eligible_wall_tag",
		"intent": "Physics-grounded close wall view after one real-controller eligible spray placement",
	}
	var extra_metadata: Dictionary = settlement.metadata.duplicate(true)
	extra_metadata.merge({
		"camera_aim_target": [target.x, target.y, target.z],
		"spray_result": "placed",
		"tag_active_count": pool.active_count(),
		"tag_object": expected_object,
		"tag_sources": tag_sources,
		"tag_position": [tag.global_position.x, tag.global_position.y, tag.global_position.z],
		"tag_wall_normal": [spray_hit.normal.x, spray_hit.normal.y, spray_hit.normal.z],
		"tag_player_distance_m": player.global_position.distance_to(spray_hit.position),
		"tag_identity_matches_hit": true,
		"tag_texture_present": true,
	}, true)
	var saved := _save_current_view(definition, output_directory, player, extra_metadata)
	if bool(saved.get("ok", false)):
		print("VISUAL_TAG: object=%s sources=%s active=%d player_distance=%.3f tag=(%.3f,%.3f,%.3f)" % [
			expected_object, ",".join(tag_sources), pool.active_count(), player.global_position.distance_to(spray_hit.position),
			tag.global_position.x, tag.global_position.y, tag.global_position.z,
		])
	return saved


func _capture_context_views(output_directory: String, world: WorldLoader, player: PlayerController) -> Dictionary:
	var settlement := await _settle_player(Vector2(EXPECTED_FERRY_SPAWN.x, EXPECTED_FERRY_SPAWN.z), "07-08-horizon-context", world, player, 3.457)
	if not bool(settlement.get("ok", false)):
		return settlement
	var context_world := world.get_node("ContextWorld") as Node3D
	var billboard := context_world.get_node("SanFranciscoBillboard") as MeshInstance3D
	var ybi := context_world.get_node("YerbaBuenaIsland") as MeshInstance3D
	var bridge := context_world.get_node("BayBridge") as Node3D
	if billboard == null or ybi == null or bridge == null:
		return {"ok": false, "message": "Required billboard/YBI/bridge context nodes are missing."}
	var context_collisions := context_world.find_children("*", "CollisionObject3D", true, false)
	var billboard_collisions := billboard.find_children("*", "CollisionObject3D", true, false)
	var ybi_runtime_meshes := ybi.find_children("*", "MeshInstance3D", true, false)
	var bridge_runtime_meshes := bridge.find_children("*", "MeshInstance3D", true, false)
	var billboard_mesh := billboard.mesh as QuadMesh
	var billboard_material := billboard_mesh.material as StandardMaterial3D if billboard_mesh != null else null
	var billboard_texture := billboard_material.albedo_texture if billboard_material != null else null
	if billboard_mesh == null or billboard_material == null or billboard_texture == null \
	or not billboard.is_visible_in_tree() \
	or billboard.layers & 1 == 0 \
	or not billboard_collisions.is_empty() \
	or not context_collisions.is_empty() \
	or not ybi.is_visible_in_tree() \
	or ybi_runtime_meshes.is_empty() \
	or bridge_runtime_meshes.is_empty():
		return {"ok": false, "message": "Billboard/YBI/bridge visibility or collision-free context contract failed."}
	var camera := player.get_camera()
	var viewport_rect := root.get_visible_rect()
	var billboard_target := billboard.global_position
	_aim_camera_at(player, billboard_target)
	if not await _wait_for_render(player):
		return {"ok": false, "message": "SF-billboard view could not keep the pause overlay hidden."}
	var billboard_screen := camera.unproject_position(billboard_target)
	var billboard_projected_bounds := _project_billboard_bounds(camera, billboard_target, billboard_mesh.size)
	var billboard_projected_width_ratio := billboard_projected_bounds.size.x / viewport_rect.size.x
	var billboard_blocker := _world_blocker_between(camera.global_position, billboard_target, player)
	if camera.is_position_behind(billboard_target) \
	or not camera.is_position_in_frustum(billboard_target) \
	or not viewport_rect.has_point(billboard_screen) \
	or not viewport_rect.encloses(billboard_projected_bounds) \
	or billboard_projected_width_ratio < MIN_BILLBOARD_PROJECTED_WIDTH_RATIO \
	or not billboard_blocker.is_empty():
		return {"ok": false, "message": "SF billboard is not fully projected at a readable width inside the unobstructed camera view."}
	var sf_definition := {
		"id": "07-horizon-context",
		"region": "sf_horizon_context",
		"intent": "Physics-grounded ferry/southwest-facing view with unobstructed bridge-aligned SF billboard center",
	}
	var sf_metadata: Dictionary = settlement.metadata.duplicate(true)
	sf_metadata.merge({
		"camera_aim_target": [billboard_target.x, billboard_target.y, billboard_target.z],
		"billboard_visible": billboard.is_visible_in_tree(),
		"billboard_mesh_present": billboard.mesh != null,
		"billboard_render_layer_1": billboard.layers & 1 != 0,
		"billboard_collision_nodes": billboard_collisions.size(),
		"billboard_position": [billboard_target.x, billboard_target.y, billboard_target.z],
		"billboard_size": [billboard_mesh.size.x, billboard_mesh.size.y],
		"billboard_texture": billboard_texture.resource_path,
		"billboard_center_in_frustum": true,
		"billboard_center_screen": [billboard_screen.x, billboard_screen.y],
		"billboard_projected_bounds": [
			billboard_projected_bounds.position.x,
			billboard_projected_bounds.position.y,
			billboard_projected_bounds.size.x,
			billboard_projected_bounds.size.y,
		],
		"billboard_projected_width_px": billboard_projected_bounds.size.x,
		"billboard_projected_width_ratio": billboard_projected_width_ratio,
		"billboard_world_blocker": false,
		"context_collision_nodes": context_collisions.size(),
	}, true)
	var sf_saved := _save_current_view(sf_definition, output_directory, player, sf_metadata)
	if not bool(sf_saved.get("ok", false)):
		return sf_saved

	var ybi_mesh := ybi_runtime_meshes[0] as MeshInstance3D
	var bridge_mesh := bridge_runtime_meshes[0] as MeshInstance3D
	var ybi_target := ybi_mesh.global_transform * ybi_mesh.get_aabb().get_center()
	var bridge_target := bridge_mesh.global_transform * bridge_mesh.get_aabb().get_center()
	var context_target := (ybi_target + bridge_target) * 0.5
	_aim_camera_at(player, context_target)
	if not await _wait_for_render(player):
		return {"ok": false, "message": "YBI/bridge view could not keep the pause overlay hidden."}
	var ybi_screen := camera.unproject_position(ybi_target)
	var bridge_screen := camera.unproject_position(bridge_target)
	var ybi_blocker := _world_blocker_between(camera.global_position, ybi_target, player)
	var bridge_blocker := _world_blocker_between(camera.global_position, bridge_target, player)
	if camera.is_position_behind(ybi_target) or camera.is_position_behind(bridge_target) \
	or not camera.is_position_in_frustum(ybi_target) or not camera.is_position_in_frustum(bridge_target) \
	or not viewport_rect.has_point(ybi_screen) or not viewport_rect.has_point(bridge_screen) \
	or not ybi_blocker.is_empty() or not bridge_blocker.is_empty():
		return {"ok": false, "message": "YBI/bridge runtime mesh centers are not both unobstructed inside the rendered camera frustum."}
	var ybi_bridge_definition := {
		"id": "08-ybi-bridge-context",
		"region": "ybi_bridge_context",
		"intent": "Physics-grounded ferry/southeast-facing view with unobstructed projected YBI and Bay Bridge runtime-mesh centers",
	}
	var ybi_bridge_metadata: Dictionary = settlement.metadata.duplicate(true)
	ybi_bridge_metadata.merge({
		"camera_aim_target": [context_target.x, context_target.y, context_target.z],
		"ybi_visible": ybi.is_visible_in_tree(),
		"ybi_runtime_meshes": ybi_runtime_meshes.size(),
		"ybi_aabb_center": [ybi_target.x, ybi_target.y, ybi_target.z],
		"ybi_center_in_frustum": true,
		"ybi_center_screen": [ybi_screen.x, ybi_screen.y],
		"ybi_world_blocker": false,
		"bridge_runtime_meshes": bridge_runtime_meshes.size(),
		"bridge_aabb_center": [bridge_target.x, bridge_target.y, bridge_target.z],
		"bridge_center_in_frustum": true,
		"bridge_center_screen": [bridge_screen.x, bridge_screen.y],
		"bridge_world_blocker": false,
		"context_collision_nodes": context_collisions.size(),
	}, true)
	var ybi_bridge_saved := _save_current_view(ybi_bridge_definition, output_directory, player, ybi_bridge_metadata)
	if not bool(ybi_bridge_saved.get("ok", false)):
		return ybi_bridge_saved
	print("VISUAL_CONTEXT: billboard_screen=(%.1f,%.1f) billboard_width=%.1f billboard_collision=%d ybi_screen=(%.1f,%.1f) bridge_screen=(%.1f,%.1f) context_collision=%d" % [
		billboard_screen.x, billboard_screen.y, billboard_projected_bounds.size.x, billboard_collisions.size(), ybi_screen.x, ybi_screen.y,
		bridge_screen.x, bridge_screen.y, context_collisions.size(),
	])
	return {"ok": true, "captures": [sf_saved.metadata, ybi_bridge_saved.metadata]}


func _project_billboard_bounds(camera: Camera3D, center: Vector3, size: Vector2) -> Rect2:
	var half_right := camera.global_basis.x.normalized() * size.x * 0.5
	var half_up := camera.global_basis.y.normalized() * size.y * 0.5
	var screen_min := Vector2(INF, INF)
	var screen_max := Vector2(-INF, -INF)
	for world_corner: Vector3 in [
		center - half_right - half_up,
		center + half_right - half_up,
		center + half_right + half_up,
		center - half_right + half_up,
	]:
		var screen_corner := camera.unproject_position(world_corner)
		screen_min = screen_min.min(screen_corner)
		screen_max = screen_max.max(screen_corner)
	return Rect2(screen_min, screen_max - screen_min)


func _aim_camera_at(player: PlayerController, target: Vector3) -> void:
	player.global_transform = Transform3D(Basis.IDENTITY, player.global_position)
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3.ZERO
	rig.look_at(target, Vector3.UP)
	player.force_update_transform()
	rig.force_update_transform()
	arm.force_update_transform()


func _world_blocker_between(origin: Vector3, target: Vector3, player: PlayerController) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(origin, target, WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _derived_object_key_for_collider(collider_value: Variant) -> String:
	var node := collider_value as Node
	while node != null:
		if node.has_meta("derived_object_key"):
			return str(node.get_meta("derived_object_key"))
		node = node.get_parent()
	return ""


func _settle_player(requested_xz: Vector2, capture_id: String, world: WorldLoader, player: PlayerController, expected_terrain_y_m := INF) -> Dictionary:
	var boundary := world.get_boundary()
	var requested_position := Vector3(requested_xz.x, 0.0, requested_xz.y)
	if not boundary.contains_position(requested_position):
		return {"ok": false, "message": "%s anchor is outside the playable boundary." % capture_id}
	var hit := _ground_hit(requested_xz, player)
	if hit.is_empty():
		return {"ok": false, "message": "%s anchor did not ray-hit generated collision." % capture_id}
	var collider := hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	var feature_kind := "" if record == null else str(record.get_meta("feature_kind", ""))
	if feature_kind != "land_ground":
		return {"ok": false, "message": "%s anchor hit %s rather than land_ground." % [capture_id, feature_kind]}
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	var ground_y := float(hit.position.y)
	if not is_inf(expected_terrain_y_m) and absf(ground_y - expected_terrain_y_m) > 0.35:
		return {"ok": false, "message": "%s terrain elevation %.3f differs from its USGS anchor %.3f." % [capture_id, ground_y, expected_terrain_y_m]}
	var spawn_position := Vector3(requested_xz.x, ground_y + SETTLE_START_HEIGHT_M, requested_xz.y)
	player.global_transform = Transform3D(Basis.IDENTITY, spawn_position)
	player.velocity = Vector3.ZERO
	player.force_update_transform()
	var recovery_count_before := world.get_runtime_evidence().recovery_count
	paused = false
	player.set_gameplay_enabled(true)
	var settled := false
	var settle_frames := 0
	for frame in SETTLE_MAX_PHYSICS_FRAMES:
		paused = false
		await physics_frame
		settle_frames = frame + 1
		if player.is_on_floor() \
		and absf(player.global_position.y - ground_y) <= SETTLE_CLEARANCE_TOLERANCE_M \
		and absf(player.velocity.y) <= 0.05:
			settled = true
			break
	var settled_position := player.global_position
	var recovery_delta := world.get_runtime_evidence().recovery_count - recovery_count_before
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	if not settled:
		return {"ok": false, "message": "%s player did not settle within %d physics frames." % [capture_id, SETTLE_MAX_PHYSICS_FRAMES]}
	var horizontal_drift := Vector2(settled_position.x - requested_xz.x, settled_position.z - requested_xz.y).length()
	var clearance := settled_position.y - ground_y
	if horizontal_drift > 0.05 or absf(clearance) > SETTLE_CLEARANCE_TOLERANCE_M or recovery_delta != 0:
		return {"ok": false, "message": "%s invalid settlement: drift=%.3f clearance=%.3f recovery_delta=%d." % [capture_id, horizontal_drift, clearance, recovery_delta]}
	print("VISUAL_SETTLED: id=%s spawn_y=%.3f settled_y=%.3f ground_y=%.3f clearance=%.3f frames=%d recovery_delta=%d" % [
		capture_id, spawn_position.y, settled_position.y, ground_y, clearance, settle_frames, recovery_delta,
	])
	return {
		"ok": true,
		"metadata": {
			"scenario_reset": "fixed_player_transform_then_physics_settle",
			"movement_proof": false,
			"input_driven_after_reset": false,
			"physics_grounded": true,
			"settle_spawn_y": spawn_position.y,
			"settled_y": settled_position.y,
			"ground_y": ground_y,
			"ground_clearance_m": clearance,
			"settle_physics_frames": settle_frames,
			"settle_horizontal_drift_m": horizontal_drift,
			"settle_recovery_delta": recovery_delta,
			"ground_feature": feature_kind,
			"ground_object": "" if record == null else str(record.get_meta("derived_object_key", record.name)),
			"ground_sources": [] if record == null else record.get_meta("source_keys", []),
			"in_boundary": boundary.contains_position(settled_position),
		},
	}


func _ground_hit(requested_xz: Vector2, player: PlayerController) -> Dictionary:
	var ray_from := Vector3(requested_xz.x, 200.0, requested_xz.y)
	var ray_to := Vector3(requested_xz.x, -20.0, requested_xz.y)
	var query := PhysicsRayQueryParameters3D.create(ray_from, ray_to, WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _record_nodes(main: Node) -> Array:
	var records: Array = []
	for node: Node in main.find_children("*", "Node3D", true, false):
		if node.has_meta("feature_kind") and node.has_meta("derived_object_key"):
			records.append(node)
	return records


func _inspect_generated_records(records: Array) -> Dictionary:
	var meshes := 0
	var surfaces := 0
	var triangles := 0
	for record_value: Variant in records:
		var record := record_value as Node3D
		if record == null:
			continue
		# Only the record-owned `Mesh` contributes to the frozen generated-world
		# inventory. Reversible live facade children are included separately in
		# RuntimeEvidence and must not alter this source-generation metric.
		var mesh_instance := record.get_node_or_null("Mesh") as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		meshes += 1
		var mesh := mesh_instance.mesh
		surfaces += mesh.get_surface_count()
		triangles += mesh.get_faces().size() / 3
	return {
		"meshes": meshes,
		"surfaces": surfaces,
		"triangles": triangles,
	}


func _inspect_palm_visual_contract(world: WorldLoader) -> Dictionary:
	var vegetation_root := world.get_node_or_null("PlayableWorld/Vegetation")
	if vegetation_root == null:
		return {"ok": false, "message": "Generated vegetation root is missing."}
	var palm_batches := 0
	var palm_surfaces := 0
	var foliage_surfaces := 0
	var wood_surfaces := 0
	for node: Node in vegetation_root.find_children("*", "MultiMeshInstance3D", true, false):
		var instance := node as MultiMeshInstance3D
		if instance == null or not str(instance.get_meta("asset_path", "")).get_file().begins_with("tree_palm"):
			continue
		palm_batches += 1
		var mesh := instance.multimesh.mesh if instance.multimesh != null else null
		if mesh == null:
			return {"ok": false, "message": "Palm batch %s has no runtime mesh." % instance.name}
		for surface_index in mesh.get_surface_count():
			palm_surfaces += 1
			var material := mesh.surface_get_material(surface_index) as StandardMaterial3D
			if material == null \
			or not bool(material.get_meta("vegetation_material_normalized", false)) \
			or not is_zero_approx(material.metallic) \
			or material.roughness < 0.82:
				return {"ok": false, "message": "Palm batch %s surface %d did not retain the non-metallic high-roughness runtime material correction." % [instance.name, surface_index]}
			var source_material_name := str(material.get_meta("vegetation_source_material_name", material.resource_name)).to_lower()
			if source_material_name.contains("leaf"):
				foliage_surfaces += 1
				if material.cull_mode != BaseMaterial3D.CULL_DISABLED \
				or not bool(material.get_meta("vegetation_foliage_two_sided", false)) \
				or not material.albedo_color.is_equal_approx(EXPECTED_PALM_FOLIAGE_ALBEDO):
					return {"ok": false, "message": "Palm foliage batch %s surface %d did not retain its two-sided muted non-metallic runtime correction." % [instance.name, surface_index]}
			elif source_material_name.contains("wood") or source_material_name.contains("bark"):
				wood_surfaces += 1
				if not material.albedo_color.is_equal_approx(EXPECTED_PALM_WOOD_ALBEDO):
					return {"ok": false, "message": "Palm wood batch %s surface %d did not retain the muted runtime palette correction." % [instance.name, surface_index]}
			else:
				return {"ok": false, "message": "Palm batch %s surface %d has an unclassified source material %s." % [instance.name, surface_index, source_material_name]}
	if palm_batches != EXPECTED_PALM_BATCHES \
	or palm_surfaces != EXPECTED_PALM_SURFACES \
	or foliage_surfaces != EXPECTED_PALM_FOLIAGE_SURFACES \
	or wood_surfaces != EXPECTED_PALM_WOOD_SURFACES:
		return {"ok": false, "message": "Palm runtime material inventory drifted: batches=%d surfaces=%d foliage=%d wood=%d." % [palm_batches, palm_surfaces, foliage_surfaces, wood_surfaces]}
	print("VISUAL_PALM_MATERIALS: batches=%d surfaces=%d foliage=%d wood=%d metallic=0 roughness>=0.82 foliage_two_sided=true palette=muted_source_roles" % [
		palm_batches, palm_surfaces, foliage_surfaces, wood_surfaces,
	])
	return {
		"ok": true,
		"palm_batches": palm_batches,
		"palm_surfaces": palm_surfaces,
		"foliage_surfaces": foliage_surfaces,
		"wood_surfaces": wood_surfaces,
		"metallic": 0.0,
		"minimum_roughness": 0.82,
		"foliage_two_sided": true,
		"palette": "muted source foliage/wood roles",
		"geometry_and_placement": "unchanged",
	}


func _record_node_for_key(world: WorldLoader, object_key: String) -> Node3D:
	for node: Node in world.get_node("PlayableWorld").find_children("*", "Node3D", true, false):
		var record := node as Node3D
		if record != null and str(record.get_meta("derived_object_key", "")) == object_key:
			return record
	return null


func _capture_ids(captures: Array[Dictionary]) -> Array:
	var ids: Array = []
	for capture: Dictionary in captures:
		ids.append(str(capture.get("id", "")))
	return ids


func _find_near_wall_face(world: WorldLoader, player: PlayerController) -> Dictionary:
	var best: Dictionary = {}
	var best_score := INF
	for record_value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		var record := record_value as Node3D
		if record == null or str(record.get_meta("feature_kind", "")) != "building_wall":
			continue
		var collision_shape := record.get_node_or_null("Collision/Shape") as CollisionShape3D
		if collision_shape == null or not (collision_shape.shape is ConcavePolygonShape3D):
			continue
		var faces := (collision_shape.shape as ConcavePolygonShape3D).get_faces()
		for index in range(0, faces.size(), 3):
			var a: Vector3 = collision_shape.global_transform * faces[index]
			var b: Vector3 = collision_shape.global_transform * faces[index + 1]
			var c: Vector3 = collision_shape.global_transform * faces[index + 2]
			var cross := (b - a).cross(c - a)
			if cross.length_squared() < 0.04:
				continue
			var normal := -cross.normalized()
			var center := (a + b + c) / 3.0
			if absf(normal.y) > 0.1:
				continue
			for side_value: Variant in [1.0, -1.0]:
				var side := float(side_value)
				var approach: Vector3 = center + normal * side * 3.5
				if not world.get_boundary().contains_position(approach):
					continue
				var ground_hit := _ground_hit(Vector2(approach.x, approach.z), player)
				var ground_collider := ground_hit.get("collider") as Node if not ground_hit.is_empty() else null
				var ground_record := ground_collider.get_parent() if ground_collider != null else null
				if ground_record == null or str(ground_record.get_meta("feature_kind", "")) != "land_ground":
					continue
				var height_above_ground := center.y - float(ground_hit.position.y)
				if height_above_ground < 0.8 or height_above_ground > 4.5:
					continue
				var grounded_approach := Vector3(approach.x, float(ground_hit.position.y), approach.z)
				if grounded_approach.distance_to(center) > player.get_spray_controller().maximum_range_m - 0.1:
					continue
				var pivot_position := grounded_approach + Vector3(0.0, 2.0, 0.0)
				var aim_direction := (center - pivot_position).normalized()
				var expected_camera := pivot_position - aim_direction * 5.5
				var visibility_query := PhysicsRayQueryParameters3D.create(expected_camera, center + aim_direction, SPRAY_SURFACE_MASK, [player.get_rid()])
				visibility_query.collide_with_areas = false
				visibility_query.collide_with_bodies = true
				var visible_hit := player.get_world_3d().direct_space_state.intersect_ray(visibility_query)
				var visible_collider := visible_hit.get("collider") as CollisionObject3D if not visible_hit.is_empty() else null
				var object_key := str(record.get_meta("derived_object_key", record.name))
				if visible_collider == null or str(visible_collider.get_meta("derived_object_key", "")) != object_key:
					continue
				var score := Vector2(center.x - EXPECTED_FERRY_SPAWN.x, center.z - EXPECTED_FERRY_SPAWN.z).length_squared() + absf(height_above_ground - 1.5) * 100.0
				if score < best_score:
					best_score = score
					best = {
						"center": center,
						"normal": visible_hit.normal,
						"approach": grounded_approach,
						"object_key": object_key,
						"source_keys": record.get_meta("source_keys", []).duplicate(),
					}
	return best


func _camera_spray_hit(player: PlayerController) -> Dictionary:
	var camera := player.get_camera()
	var viewport_center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(viewport_center)
	var direction := camera.project_ray_normal(viewport_center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0, SPRAY_SURFACE_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _wait_for_render(player: PlayerController) -> bool:
	_force_unpaused(player)
	await physics_frame
	_force_unpaused(player)
	await process_frame
	_force_unpaused(player)
	await RenderingServer.frame_post_draw
	_force_unpaused(player)
	await process_frame
	_force_unpaused(player)
	await RenderingServer.frame_post_draw
	return _force_unpaused(player)


func _wait_for_active_render(player: PlayerController) -> bool:
	# Gameplay must remain enabled while the native renderer advances. Unlike the
	# static-view helper, this function performs no explicit physics-frame wait;
	# any physics ticks observed here belong to the same live input sequence.
	_force_unpaused(player)
	await process_frame
	_force_unpaused(player)
	await RenderingServer.frame_post_draw
	_force_unpaused(player)
	await process_frame
	_force_unpaused(player)
	await RenderingServer.frame_post_draw
	return _force_unpaused(player)


func _record_jetpack_motion_step(
	player: PlayerController,
	world: WorldLoader,
	evidence: RuntimeEvidence,
	recovery_count_before: int,
	motion_state: Dictionary,
) -> String:
	var previous_position: Vector3 = motion_state.previous_position
	var current_position := player.global_position
	var step_distance := previous_position.distance_to(current_position)
	motion_state.previous_position = current_position
	motion_state.motion_samples = int(motion_state.motion_samples) + 1
	motion_state.maximum_observed_step_m = maxf(float(motion_state.maximum_observed_step_m), step_distance)
	if step_distance > JETPACK_MAX_OBSERVED_STEP_M:
		return "Jetpack sequence exceeded the %.3f m per-sample continuity cap: %.3f m." % [JETPACK_MAX_OBSERVED_STEP_M, step_distance]
	if not world.get_boundary().contains_position(current_position):
		return "Jetpack sequence left the playable XZ boundary."
	if evidence.recovery_count != recovery_count_before:
		return "Jetpack sequence triggered recovery delta %d." % [evidence.recovery_count - recovery_count_before]
	return ""


func _action_has_physical_key(action: StringName, key: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		var key_event := event as InputEventKey
		if key_event != null and key_event.physical_keycode == key:
			return true
	return false


func _vector3_array(value: Vector3) -> Array:
	return [value.x, value.y, value.z]


func _vector2_array(value: Vector2) -> Array:
	return [value.x, value.y]


func _save_current_view(definition: Dictionary, output_directory: String, player: PlayerController, extra_metadata: Dictionary) -> Dictionary:
	var hud := player.get_parent().get_node("Interface/HUD") as GameHUD
	var pause_panel := hud.get_node("PausePanel") as Control
	if paused or pause_panel.visible:
		return {"ok": false, "message": "%s refused to save with the pause overlay visible." % definition.id}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		return {"ok": false, "message": "%s produced an empty viewport image." % definition.id}
	var image_size := image.get_size()
	if image_size != Vector2i(CAPTURE_WIDTH, CAPTURE_HEIGHT):
		return {"ok": false, "message": "%s image was %s, expected %dx%d." % [definition.id, image_size, CAPTURE_WIDTH, CAPTURE_HEIGHT]}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s image looks blank (sample colors=%d, luminance range=%.3f)." % [definition.id, sample.unique_colors, sample.luminance_range]}
	var filename := "%s.png" % definition.id
	var image_path := output_directory.path_join(filename)
	var save_error := image.save_png(image_path)
	if save_error != OK:
		return {"ok": false, "message": "%s could not save PNG (error %d)." % [definition.id, save_error]}
	var camera := player.get_camera()
	var metadata := {
		"id": definition.id,
		"region": definition.region,
		"intent": definition.intent,
		"file": filename,
		"sha256": FileAccess.get_sha256(image_path),
		"bytes": FileAccess.get_file_as_bytes(image_path).size(),
		"dimensions": [image_size.x, image_size.y],
		"player_position": [player.global_position.x, player.global_position.y, player.global_position.z],
		"camera_position": [camera.global_position.x, camera.global_position.y, camera.global_position.z],
		"camera_forward": [-camera.global_basis.z.x, -camera.global_basis.z.y, -camera.global_basis.z.z],
		"pause_overlay_visible": false,
		"sample_unique_colors": sample.unique_colors,
		"sample_luminance_range": sample.luminance_range,
	}
	metadata.merge(extra_metadata, true)
	print("VISUAL_CAPTURE: id=%s region=%s player=(%.3f,%.3f,%.3f) camera=(%.3f,%.3f,%.3f) grounded=%s clearance=%.3f image=%s sha256=%s colors=%d luminance_range=%.3f" % [
		definition.id, definition.region,
		player.global_position.x, player.global_position.y, player.global_position.z,
		camera.global_position.x, camera.global_position.y, camera.global_position.z,
		str(metadata.get("physics_grounded", false)), float(metadata.get("ground_clearance_m", INF)),
		ProjectSettings.globalize_path(image_path), metadata.sha256,
		int(sample.unique_colors), float(sample.luminance_range),
	])
	return {"ok": true, "metadata": metadata}


func _clear_gameplay_input() -> void:
	for action: StringName in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _force_unpaused(player: PlayerController) -> bool:
	paused = false
	var hud := player.get_parent().get_node("Interface/HUD") as GameHUD
	hud.set_paused(false)
	return not paused and not (hud.get_node("PausePanel") as Control).visible


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
			var luminance := color.get_luminance()
			minimum_luminance = minf(minimum_luminance, luminance)
			maximum_luminance = maxf(maximum_luminance, luminance)
	return {
		"unique_colors": colors.size(),
		"luminance_range": maximum_luminance - minimum_luminance,
	}


func _output_directory() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(OUTPUT_ARG_PREFIX):
			var value := argument.trim_prefix(OUTPUT_ARG_PREFIX).strip_edges()
			if not value.is_empty():
				return value.trim_suffix("/")
	return ""


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_fail(message)
		return false
	return true


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error("VISUAL_CAPTURE_FAIL: %s" % message)


func _on_timeout() -> void:
	if not _finished:
		_clear_gameplay_input()
		_fail("Capture did not finish within %.0f seconds." % CAPTURE_TIMEOUT_SECONDS)
		_finished = true
		quit(1)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	_clear_gameplay_input()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	paused = false
	if main != null and is_instance_valid(main):
		main.queue_free()
		await process_frame
	quit(0 if _failure.is_empty() else 1)
