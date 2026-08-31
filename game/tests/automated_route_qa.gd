extends SceneTree

const REGIONAL_QA_ANCHORS := preload("res://game/tests/regional_qa_anchors.gd")
const OUTPUT_ARG_PREFIX := "--visual-evidence-output="
const WHOLE_ISLAND_ARG := "--whole-island-route"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_FERRY_SPAWN := Vector3(-104.364, 3.457, 786.024)
const EXPECTED_FERRY_YAW := -0.119
const WORLD_SOLID_MASK := 1
const MAX_ROUTE_PHYSICS_FRAMES := 6000
const MAX_AIRBORNE_FRAMES := 6
const STALL_WINDOW_FRAMES := 120
const STALL_MINIMUM_PROGRESS_M := 0.25
const CAPTURE_PITCH_RADIANS := -0.13962634015954636
const WHOLE_ISLAND_TIME_SCALE := 8.0
const WHOLE_ISLAND_PHYSICS_TICKS := 480
const WHOLE_ISLAND_MAX_PHYSICS_FRAMES := 60000
const WHOLE_ISLAND_CRUISE_MIN_Y := 65.0
const WHOLE_ISLAND_CRUISE_MAX_Y := 75.0
const WHOLE_ISLAND_ANCHOR_RADIUS_M := 1.5
# At 60 Hz, 20 m/s horizontal plus 5 m/s ascent moves about 0.344 m per tick.
const WHOLE_ISLAND_MAX_STEP_M := 0.36

const WHOLE_ISLAND_REGIONS := [
	{"id": "southwest", "capture_region": "southwest"},
	{"id": "center", "capture_region": "center"},
	{"id": "north", "capture_region": "north"},
	{"id": "east-perimeter", "capture_region": "perimeter"},
]

# Frozen OSM road-centerline route from the approved ferry arrival through
# Waterfront Plaza, Treasure Island Road, and Trade Winds Avenue. Coordinates
# are the project's millimeter-rounded +X east/+Z south projection. The player
# starts at the manifest spawn and is never repositioned between checkpoints.
const ROUTE := [
	{"id": "00-ferry-spawn", "xz": Vector2(-104.364, 786.024), "terrain_y_m": 3.457, "source_key": "w1222514694", "node_id": "spawn", "mode": "walk", "radius_m": 0.35, "capture": true},
	{"id": "01-waterfront-approach", "xz": Vector2(-93.682, 780.044), "terrain_y_m": 3.897, "source_key": "w1222514694", "node_id": "n11609333225", "mode": "walk", "radius_m": 0.55},
	{"id": "02-waterfront-join", "xz": Vector2(-91.651, 778.897), "terrain_y_m": 3.919, "source_key": "w1212173450", "node_id": "n11230504400", "mode": "walk", "radius_m": 0.55},
	{"id": "03-waterfront-crossing", "xz": Vector2(-84.414, 774.734), "terrain_y_m": 3.998, "source_key": "w1249797944", "node_id": "n9551738100", "mode": "walk", "radius_m": 0.75, "capture": true},
	{"id": "04-ti-road-north-1", "xz": Vector2(-96.250, 754.195), "terrain_y_m": 4.062, "source_key": "w1249797944", "node_id": "n10206762981", "mode": "run", "radius_m": 1.25},
	{"id": "05-ti-road-north-2", "xz": Vector2(-108.833, 730.206), "terrain_y_m": 3.863, "source_key": "w1249797944", "node_id": "n11617861468", "mode": "run", "radius_m": 1.25},
	{"id": "06-trade-winds-turn", "xz": Vector2(-112.174, 722.948), "terrain_y_m": 3.733, "source_key": "w255330044", "node_id": "n10206762967", "mode": "run", "radius_m": 1.25, "capture": true},
	{"id": "07-trade-winds-1", "xz": Vector2(-112.666, 718.005), "terrain_y_m": 3.751, "source_key": "w255330044", "node_id": "n11230505956", "mode": "run", "radius_m": 1.25},
	{"id": "08-trade-winds-2", "xz": Vector2(-111.532, 712.884), "terrain_y_m": 3.836, "source_key": "w255330044", "node_id": "n10206762980", "mode": "run", "radius_m": 1.25},
	{"id": "09-trade-winds-3", "xz": Vector2(-110.152, 711.081), "terrain_y_m": 3.858, "source_key": "w255330044", "node_id": "n10206762979", "mode": "run", "radius_m": 1.25},
	{"id": "10-trade-winds-4", "xz": Vector2(-103.530, 705.972), "terrain_y_m": 3.900, "source_key": "w255330044", "node_id": "n5022051218", "mode": "run", "radius_m": 1.25},
	{"id": "11-trade-winds-west", "xz": Vector2(-68.085, 685.812), "terrain_y_m": 4.038, "source_key": "w1249797946", "node_id": "n11617873669", "mode": "run", "radius_m": 1.5},
	{"id": "12-trade-winds-center", "xz": Vector2(-4.951, 652.705), "terrain_y_m": 4.110, "source_key": "w1249797946", "node_id": "n13515946901", "mode": "run", "radius_m": 1.5},
	{"id": "13-trade-winds-east", "xz": Vector2(38.743, 629.439), "terrain_y_m": 3.884, "source_key": "w1249797946", "node_id": "n11612881904", "mode": "run", "radius_m": 1.5, "capture": true},
]

var _failure := ""
var _finished := false
var _route_capture_output := ""
var _capture_records: Array[Dictionary] = []
var _whole_island_mode := false
var _saved_time_scale := 1.0
var _saved_physics_ticks := 60
var _simulation_clock_changed := false


func _initialize() -> void:
	_whole_island_mode = WHOLE_ISLAND_ARG in OS.get_cmdline_user_args()
	create_timer(180.0 if _whole_island_mode else 120.0, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	var baseline_nodes := get_node_count()
	var main_scene := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(main_scene != null, "Main scene could not be loaded."):
		_finish(null, baseline_nodes)
		return
	var main := main_scene.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
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
		_finish(main, baseline_nodes)
		return

	var spawn := world.get_spawn_transform()
	if not _require(world.is_world_validated(), "World was not retained as validated.") \
	or not _require(str(ready_reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Manifest file hash drifted.") \
	or not _require(spawn.origin.is_equal_approx(EXPECTED_FERRY_SPAWN), "Ferry spawn origin drifted.") \
	or not _require(spawn.basis.is_equal_approx(Basis(Vector3.UP, EXPECTED_FERRY_YAW)), "Ferry spawn yaw drifted."):
		_finish(main, baseline_nodes)
		return

	_route_capture_output = _capture_output_directory()
	if _whole_island_mode and not _route_capture_output.is_empty():
		_fail("Whole-island route mode is headless-only; omit %s." % OUTPUT_ARG_PREFIX)
		_finish(main, baseline_nodes)
		return
	if not _route_capture_output.is_empty():
		if DisplayServer.get_name() == "headless":
			_fail("Route screenshots require the normal rendering driver; omit %s for headless route QA." % OUTPUT_ARG_PREFIX)
			_finish(main, baseline_nodes)
			return
		var absolute_output := ProjectSettings.globalize_path(_route_capture_output)
		var directory_error := DirAccess.make_dir_recursive_absolute(absolute_output)
		if not _require(directory_error == OK, "Could not create route capture directory: %s" % absolute_output):
			_finish(main, baseline_nodes)
			return

	paused = false
	_clear_gameplay_input()
	if not await _wait_for_floor(player, 300):
		_fail("Player did not ground at the approved ferry spawn.")
		_finish(main, baseline_nodes)
		return
	if not _require(_horizontal_distance(player.global_position, EXPECTED_FERRY_SPAWN) <= 0.05, "Player did not begin at the approved ferry spawn."):
		_finish(main, baseline_nodes)
		return

	var road_records := _road_records(world)
	if not _require(not road_records.is_empty(), "Live generated road records are missing."):
		_finish(main, baseline_nodes)
		return
	var route_length_m := 0.0
	for index in ROUTE.size():
		var checkpoint: Dictionary = ROUTE[index]
		var validation := _validate_route_checkpoint(checkpoint, world, player, road_records)
		if not _require(bool(validation.get("ok", false)), str(validation.get("message", "Route checkpoint is invalid."))):
			_finish(main, baseline_nodes)
			return
		if index > 0:
			route_length_m += (ROUTE[index - 1].xz as Vector2).distance_to(checkpoint.xz)
	print("ROUTE_CONTRACT: checkpoints=%d centerline_length=%.3fm start=%s end=%s road_validation=pass" % [
		ROUTE.size(), route_length_m, ROUTE[0].id, ROUTE[-1].id,
	])
	if not _require(route_length_m > 240.0 and route_length_m < 280.0, "Frozen route length drifted: %.3f m." % route_length_m):
		_finish(main, baseline_nodes)
		return
	var whole_island_direct_length_m := 0.0
	var previous_whole_xz: Vector2 = ROUTE[-1].xz
	if _whole_island_mode:
		for region_definition: Dictionary in WHOLE_ISLAND_REGIONS:
			var capture := REGIONAL_QA_ANCHORS.capture_for_region(str(region_definition.capture_region))
			if not _require(not capture.is_empty(), "Missing shared regional anchor %s." % region_definition.id) \
			or not _require(_validate_regional_anchor(capture, world, player), "Regional anchor %s is not clear generated land." % region_definition.id):
				_finish(main, baseline_nodes)
				return
			var anchor_xz: Vector2 = capture.requested_xz
			whole_island_direct_length_m += previous_whole_xz.distance_to(anchor_xz)
			previous_whole_xz = anchor_xz
		print("WHOLE_ISLAND_CONTRACT: regions=ferry_spawn,southwest,center,north,east-perimeter ground_centerline=%.3fm flight_direct=%.3fm no_startup_teleports=true" % [route_length_m, whole_island_direct_length_m])
		_saved_time_scale = Engine.time_scale
		_saved_physics_ticks = Engine.physics_ticks_per_second
		Engine.physics_ticks_per_second = WHOLE_ISLAND_PHYSICS_TICKS
		Engine.time_scale = WHOLE_ISLAND_TIME_SCALE
		_simulation_clock_changed = true

	var evidence := world.get_runtime_evidence()
	var recoveries_before := evidence.recovery_count
	var route_start_msec := Time.get_ticks_msec()
	var physics_frames := 0
	var walk_frames := 0
	var run_frames := 0
	var airborne_peak_frames := 0
	var traveled_distance_m := 0.0
	var maximum_step_m := 0.0
	var last_position := player.global_position
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	if not _route_capture_output.is_empty():
		_steer_camera(rig, player.global_position, ROUTE[1].xz)
		arm.rotation.x = CAPTURE_PITCH_RADIANS
		if not await _capture_checkpoint(ROUTE[0], player):
			_finish(main, baseline_nodes)
			return

	for route_index in range(1, ROUTE.size()):
		var checkpoint: Dictionary = ROUTE[route_index]
		var target_xz: Vector2 = checkpoint.xz
		var reach_radius_m := float(checkpoint.radius_m)
		var segment_frames := 0
		var airborne_frames := 0
		var stall_frames := 0
		var stall_anchor := player.global_position
		while _horizontal_distance_xz(player.global_position, target_xz) > reach_radius_m:
			var checkpoint_distance_m := _horizontal_distance_xz(player.global_position, target_xz)
			var final_run_slowdown_m := (
				(player.run_speed_mps * player.run_speed_mps - player.walk_speed_mps * player.walk_speed_mps)
				/ (2.0 * player.acceleration_mps2)
			) + reach_radius_m
			var slow_for_final_stop := route_index == ROUTE.size() - 1 \
				and checkpoint_distance_m <= final_run_slowdown_m
			_steer_camera(rig, player.global_position, target_xz)
			Input.action_press("move_forward")
			if str(checkpoint.mode) == "run" and not slow_for_final_stop:
				Input.action_press("run")
			else:
				Input.action_release("run")
			await physics_frame
			physics_frames += 1
			segment_frames += 1
			if Input.is_action_pressed("run"):
				run_frames += 1
			else:
				walk_frames += 1
			var frame_distance_m := _horizontal_distance(last_position, player.global_position)
			traveled_distance_m += frame_distance_m
			maximum_step_m = maxf(maximum_step_m, frame_distance_m)
			last_position = player.global_position
			if frame_distance_m > WHOLE_ISLAND_MAX_STEP_M:
				_fail("Route made an implausible %.3f m one-frame step near %s." % [frame_distance_m, checkpoint.id])
				_finish(main, baseline_nodes)
				return
			if player.is_on_floor():
				airborne_frames = 0
			else:
				airborne_frames += 1
				airborne_peak_frames = maxi(airborne_peak_frames, airborne_frames)
			if airborne_frames > MAX_AIRBORNE_FRAMES:
				_fail("Route left generated ground near %s for %d consecutive frames." % [checkpoint.id, airborne_frames])
				_finish(main, baseline_nodes)
				return
			if not world.get_boundary().contains_position(player.global_position):
				_fail("Route left the playable boundary near %s at %s." % [checkpoint.id, player.global_position])
				_finish(main, baseline_nodes)
				return
			if evidence.recovery_count != recoveries_before:
				_fail("Route triggered recovery near %s: delta=%d." % [checkpoint.id, evidence.recovery_count - recoveries_before])
				_finish(main, baseline_nodes)
				return
			stall_frames += 1
			if stall_frames >= STALL_WINDOW_FRAMES:
				var stall_progress := _horizontal_distance(stall_anchor, player.global_position)
				if stall_progress < STALL_MINIMUM_PROGRESS_M and _horizontal_distance_xz(player.global_position, target_xz) > reach_radius_m + 0.5:
					_fail("Route stalled near %s: %.3f m in %d frames." % [checkpoint.id, stall_progress, stall_frames])
					_finish(main, baseline_nodes)
					return
				stall_anchor = player.global_position
				stall_frames = 0
			if physics_frames > MAX_ROUTE_PHYSICS_FRAMES:
				_fail("Route exceeded %d physics frames near %s." % [MAX_ROUTE_PHYSICS_FRAMES, checkpoint.id])
				_finish(main, baseline_nodes)
				return

		var checkpoint_error := _horizontal_distance_xz(player.global_position, target_xz)
		var actual_road_sources := _road_sources_at(Vector2(player.global_position.x, player.global_position.z), road_records)
		if not _require(checkpoint_error <= reach_radius_m + 0.01, "Checkpoint %s reach error drifted." % checkpoint.id) \
		or not _require(not actual_road_sources.is_empty(), "Player reached %s outside generated road geometry." % checkpoint.id) \
		or not _require(player.is_on_floor(), "Player reached %s without a grounded contact." % checkpoint.id):
			_finish(main, baseline_nodes)
			return
		print("ROUTE_CHECKPOINT: index=%d id=%s source=%s node=%s mode=%s frames=%d error=%.3fm position=(%.3f,%.3f,%.3f) traveled=%.3fm" % [
			route_index, checkpoint.id, checkpoint.source_key, checkpoint.node_id, checkpoint.mode,
			segment_frames, checkpoint_error, player.global_position.x, player.global_position.y,
			player.global_position.z, traveled_distance_m,
		])
		if not _route_capture_output.is_empty() and bool(checkpoint.get("capture", false)):
			_clear_gameplay_input()
			await _brake_to_stop(player, 120)
			var look_xz: Vector2 = target_xz
			if route_index + 1 < ROUTE.size():
				look_xz = ROUTE[route_index + 1].xz
			else:
				look_xz = target_xz + (target_xz - (ROUTE[route_index - 1].xz as Vector2))
			_steer_camera(rig, player.global_position, look_xz)
			arm.rotation.x = CAPTURE_PITCH_RADIANS
			if not await _capture_checkpoint(checkpoint, player):
				_finish(main, baseline_nodes)
				return

	if _whole_island_mode:
		var extension_state := {
			"physics_frames": 0,
			"walk_frames": 0,
			"run_frames": 0,
			"jetpack_frames": 0,
			"horizontal_distance_m": 0.0,
			"maximum_step_m": maximum_step_m,
			"last_position": player.global_position,
			"region_landings": 1,
			"airborne_frames": 0,
		}
		for region_definition: Dictionary in WHOLE_ISLAND_REGIONS:
			var capture := REGIONAL_QA_ANCHORS.capture_for_region(str(region_definition.capture_region))
			if not await _fly_to_regional_anchor(str(region_definition.id), capture.requested_xz, player, rig, world, evidence, recoveries_before, extension_state):
				_finish(main, baseline_nodes)
				return
		var elapsed_seconds := float(Time.get_ticks_msec() - route_start_msec) / 1000.0
		var total_physics_frames: int = physics_frames + int(extension_state.physics_frames)
		var total_run_frames: int = run_frames + int(extension_state.run_frames)
		var total_walk_frames: int = walk_frames + int(extension_state.walk_frames)
		var total_distance_m := traveled_distance_m + float(extension_state.horizontal_distance_m)
		var planned_distance_m := route_length_m + whole_island_direct_length_m
		var recovery_delta := evidence.recovery_count - recoveries_before
		var final_capture := REGIONAL_QA_ANCHORS.capture_for_region("perimeter")
		var final_error_m := _horizontal_distance_xz(player.global_position, final_capture.requested_xz)
		if not _require(recovery_delta == 0, "Whole-island route recovery count changed by %d." % recovery_delta) \
		or not _require(int(extension_state.region_landings) == 5, "Whole-island route did not land in all five regions.") \
		or not _require(player.is_on_floor(), "Whole-island route did not finish grounded.") \
		or not _require(total_walk_frames > 0 and total_run_frames > 0 and int(extension_state.jetpack_frames) > 0, "Whole-island route did not exercise walk, run, and jetpack input.") \
		or not _require(total_distance_m >= planned_distance_m * 0.88 and total_distance_m <= planned_distance_m * 1.25, "Whole-island travel %.3f m is implausible for planned %.3f m." % [total_distance_m, planned_distance_m]) \
		or not _require(float(extension_state.maximum_step_m) <= WHOLE_ISLAND_MAX_STEP_M, "Whole-island route made an implausible one-frame step.") \
		or not _require(final_error_m <= WHOLE_ISLAND_ANCHOR_RADIUS_M, "Whole-island final anchor error is %.3f m." % final_error_m):
			_finish(main, baseline_nodes)
			return
		print("WHOLE_ISLAND_ROUTE: regions=5 order=ferry_spawn,southwest,center,north,east-perimeter planned=%.3fm traveled=%.3fm wall_elapsed=%.3fs simulated=%.3fs physics_frames=%d walk_frames=%d run_frames=%d jetpack_frames=%d airborne_frames=%d max_step=%.3fm recoveries=%d final_error=%.3fm continuous=true no_teleport=true boundary=pass landings=5 stalls=0" % [
			planned_distance_m, total_distance_m, elapsed_seconds, float(total_physics_frames) / 60.0,
			total_physics_frames, total_walk_frames, total_run_frames, extension_state.jetpack_frames,
			extension_state.airborne_frames, extension_state.maximum_step_m, recovery_delta, final_error_m,
		])
		print("PASS: actual PlayerController continuously visited ferry, southwest, center, north, and east-perimeter anchors using walk/run/jetpack input without teleport or recovery")
		_finish(main, baseline_nodes)
		return

	_clear_gameplay_input()
	await _brake_to_stop(player, 180)
	var elapsed_seconds := float(Time.get_ticks_msec() - route_start_msec) / 1000.0
	var final_checkpoint: Dictionary = ROUTE[-1]
	var final_error_m := _horizontal_distance_xz(player.global_position, final_checkpoint.xz)
	var recovery_delta := evidence.recovery_count - recoveries_before
	var minimum_expected_travel := route_length_m * 0.88
	var maximum_expected_travel := route_length_m * 1.35
	if not _require(recovery_delta == 0, "Route recovery count changed by %d." % recovery_delta) \
	or not _require(world.get_boundary().contains_position(player.global_position), "Final route position is outside boundary.") \
	or not _require(player.is_on_floor(), "Player did not finish grounded.") \
	or not _require(final_error_m <= float(final_checkpoint.radius_m) + 1.0, "Final route error is %.3f m." % final_error_m) \
	or not _require(walk_frames > 0 and run_frames > 0, "Route did not exercise both walk and run input.") \
	or not _require(traveled_distance_m >= minimum_expected_travel and traveled_distance_m <= maximum_expected_travel, "Continuous travel %.3f m is outside expected %.3f–%.3f m." % [traveled_distance_m, minimum_expected_travel, maximum_expected_travel]):
		_finish(main, baseline_nodes)
		return

	var metrics := {
		"checkpoints": ROUTE.size(),
		"centerline_length_m": route_length_m,
		"traveled_distance_m": traveled_distance_m,
		"elapsed_seconds": elapsed_seconds,
		"physics_frames": physics_frames,
		"walk_frames": walk_frames,
		"run_frames": run_frames,
		"airborne_peak_frames": airborne_peak_frames,
		"recovery_delta": recovery_delta,
		"final_error_m": final_error_m,
		"final_position": [player.global_position.x, player.global_position.y, player.global_position.z],
		"continuous_without_teleport": true,
		"boundary": "pass",
		"grounded": "pass",
		"stall": "none",
	}
	if not _route_capture_output.is_empty() and not _write_capture_manifest(metrics):
		_finish(main, baseline_nodes)
		return
	print("AUTOMATED_ROUTE: checkpoints=%d centerline=%.3fm traveled=%.3fm elapsed=%.3fs physics_frames=%d walk_frames=%d run_frames=%d airborne_peak=%d recoveries=%d final_error=%.3fm continuous=true boundary=pass grounded=pass stalls=0 captures=%d" % [
		ROUTE.size(), route_length_m, traveled_distance_m, elapsed_seconds, physics_frames,
		walk_frames, run_frames, airborne_peak_frames, recovery_delta, final_error_m, _capture_records.size(),
	])
	print("PASS: actual PlayerController continuously traversed the validated ferry-to-Trade-Winds road route without teleport, stall, boundary loss, or recovery")
	_finish(main, baseline_nodes)


func _validate_route_checkpoint(checkpoint: Dictionary, world: WorldLoader, player: PlayerController, road_records: Array[Node3D]) -> Dictionary:
	var point: Vector2 = checkpoint.xz
	var position := Vector3(point.x, 0.0, point.y)
	if not world.get_boundary().contains_position(position):
		return {"ok": false, "message": "%s is outside the playable boundary." % checkpoint.id}
	var ground_hit := _ground_hit(point, player)
	if ground_hit.is_empty():
		return {"ok": false, "message": "%s has no generated ground hit." % checkpoint.id}
	var collider := ground_hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	if record == null or str(record.get_meta("feature_kind", "")) != "land_ground":
		return {"ok": false, "message": "%s hits non-land collision first." % checkpoint.id}
	if absf(float(ground_hit.position.y) - float(checkpoint.terrain_y_m)) > 0.35:
		return {"ok": false, "message": "%s terrain elevation %.3f differs from its USGS anchor %.3f." % [checkpoint.id, ground_hit.position.y, checkpoint.terrain_y_m]}
	var road_sources := _road_sources_at(point, road_records)
	if road_sources.is_empty() or str(checkpoint.source_key) not in road_sources:
		return {"ok": false, "message": "%s is not on live generated road geometry carrying %s (found %s)." % [checkpoint.id, checkpoint.source_key, road_sources.keys()]}
	return {"ok": true}


func _validate_regional_anchor(capture: Dictionary, world: WorldLoader, player: PlayerController) -> bool:
	var point: Vector2 = capture.requested_xz
	if not world.get_boundary().contains_position(Vector3(point.x, 0.0, point.y)):
		return false
	var ground_hit := _ground_hit(point, player)
	if ground_hit.is_empty():
		return false
	var collider := ground_hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	return record != null and str(record.get_meta("feature_kind", "")) == "land_ground" \
		and absf(float(ground_hit.position.y) - float(capture.terrain_y_m)) <= 0.35


func _fly_to_regional_anchor(
	region_id: String,
	target_xz: Vector2,
	player: PlayerController,
	rig: PlayerCamera,
	world: WorldLoader,
	evidence: RuntimeEvidence,
	recoveries_before: int,
	state: Dictionary,
) -> bool:
	var segment_start_xz := Vector2(player.global_position.x, player.global_position.z)
	var segment_distance_before := float(state.horizontal_distance_m)
	var segment_frames_before := int(state.physics_frames)
	var peak_y := player.global_position.y
	_clear_gameplay_input()
	while player.global_position.y < WHOLE_ISLAND_CRUISE_MIN_Y:
		Input.action_press("jetpack")
		if not await _advance_whole_island_frame(region_id, player, world, evidence, recoveries_before, state):
			return false
		peak_y = maxf(peak_y, player.global_position.y)

	var jetpack_latched := true
	var stall_frames := 0
	var stall_anchor := player.global_position
	while _horizontal_distance_xz(player.global_position, target_xz) > 0.6:
		_steer_camera(rig, player.global_position, target_xz)
		Input.action_press("move_forward")
		Input.action_press("run")
		if player.global_position.y >= WHOLE_ISLAND_CRUISE_MAX_Y:
			jetpack_latched = false
		elif player.global_position.y <= WHOLE_ISLAND_CRUISE_MIN_Y:
			jetpack_latched = true
		if jetpack_latched:
			Input.action_press("jetpack")
		else:
			Input.action_release("jetpack")
		if not await _advance_whole_island_frame(region_id, player, world, evidence, recoveries_before, state):
			return false
		peak_y = maxf(peak_y, player.global_position.y)
		stall_frames += 1
		if stall_frames >= STALL_WINDOW_FRAMES:
			var progress := _horizontal_distance(stall_anchor, player.global_position)
			if progress < STALL_MINIMUM_PROGRESS_M:
				_fail("Whole-island route stalled in flight toward %s: %.3f m in %d frames." % [region_id, progress, stall_frames])
				return false
			stall_anchor = player.global_position
			stall_frames = 0

	Input.action_release("move_forward")
	Input.action_release("run")
	var brake_frames := 0
	while Vector2(player.velocity.x, player.velocity.z).length() > 0.1:
		if player.global_position.y >= WHOLE_ISLAND_CRUISE_MAX_Y:
			Input.action_release("jetpack")
		elif player.global_position.y <= WHOLE_ISLAND_CRUISE_MIN_Y:
			Input.action_press("jetpack")
		if not await _advance_whole_island_frame(region_id, player, world, evidence, recoveries_before, state):
			return false
		peak_y = maxf(peak_y, player.global_position.y)
		brake_frames += 1
		if brake_frames > 180:
			_fail("Whole-island route could not brake before descending at %s." % region_id)
			return false

	Input.action_release("jetpack")
	var landing_frames := 0
	while not player.is_on_floor():
		var landing_error := _horizontal_distance_xz(player.global_position, target_xz)
		if landing_error > 0.3:
			_steer_camera(rig, player.global_position, target_xz)
			Input.action_press("move_forward")
			Input.action_release("run")
		else:
			Input.action_release("move_forward")
		if not await _advance_whole_island_frame(region_id, player, world, evidence, recoveries_before, state):
			return false
		landing_frames += 1
		if landing_frames > 6000:
			_fail("Whole-island route did not land at %s." % region_id)
			return false

	var settle_frames := 0
	while _horizontal_distance_xz(player.global_position, target_xz) > 0.45 \
	or Vector2(player.velocity.x, player.velocity.z).length() > 0.1:
		if _horizontal_distance_xz(player.global_position, target_xz) > 0.3:
			_steer_camera(rig, player.global_position, target_xz)
			Input.action_press("move_forward")
			Input.action_release("run")
		else:
			Input.action_release("move_forward")
		if not await _advance_whole_island_frame(region_id, player, world, evidence, recoveries_before, state):
			return false
		settle_frames += 1
		if settle_frames > 900:
			_fail("Whole-island route could not settle on %s." % region_id)
			return false
	_clear_gameplay_input()

	var final_error_m := _horizontal_distance_xz(player.global_position, target_xz)
	var actual_ground_hit := _ground_hit(Vector2(player.global_position.x, player.global_position.z), player)
	var actual_collider := actual_ground_hit.get("collider") as Node
	var actual_record := actual_collider.get_parent() if actual_collider != null else null
	if not _require(player.is_on_floor(), "Whole-island anchor %s is not grounded." % region_id) \
	or not _require(final_error_m <= WHOLE_ISLAND_ANCHOR_RADIUS_M, "Whole-island anchor %s error is %.3f m." % [region_id, final_error_m]) \
	or not _require(actual_record != null and str(actual_record.get_meta("feature_kind", "")) == "land_ground", "Whole-island anchor %s did not land on generated land." % region_id):
		return false
	state.region_landings = int(state.region_landings) + 1
	print("WHOLE_ISLAND_ANCHOR: id=%s input=run+jetpack planned=%.3fm traveled=%.3fm frames=%d peak_y=%.3fm error=%.3fm grounded=true position=(%.3f,%.3f,%.3f)" % [
		region_id, segment_start_xz.distance_to(target_xz), float(state.horizontal_distance_m) - segment_distance_before,
		int(state.physics_frames) - segment_frames_before, peak_y, final_error_m,
		player.global_position.x, player.global_position.y, player.global_position.z,
	])
	return true


func _advance_whole_island_frame(
	region_id: String,
	player: PlayerController,
	world: WorldLoader,
	evidence: RuntimeEvidence,
	recoveries_before: int,
	state: Dictionary,
) -> bool:
	await physics_frame
	state.physics_frames = int(state.physics_frames) + 1
	if Input.is_action_pressed("move_forward"):
		if Input.is_action_pressed("run"):
			state.run_frames = int(state.run_frames) + 1
		else:
			state.walk_frames = int(state.walk_frames) + 1
	if Input.is_action_pressed("jetpack"):
		state.jetpack_frames = int(state.jetpack_frames) + 1
	if not player.is_on_floor():
		state.airborne_frames = int(state.airborne_frames) + 1
	var previous_position: Vector3 = state.last_position
	var horizontal_step_m := _horizontal_distance(previous_position, player.global_position)
	var full_step_m := previous_position.distance_to(player.global_position)
	state.horizontal_distance_m = float(state.horizontal_distance_m) + horizontal_step_m
	state.maximum_step_m = maxf(float(state.maximum_step_m), full_step_m)
	state.last_position = player.global_position
	if full_step_m > WHOLE_ISLAND_MAX_STEP_M:
		_fail("Whole-island route made an implausible %.3f m one-frame step near %s." % [full_step_m, region_id])
		return false
	if int(state.physics_frames) > WHOLE_ISLAND_MAX_PHYSICS_FRAMES:
		_fail("Whole-island route exceeded %d extension physics frames near %s." % [WHOLE_ISLAND_MAX_PHYSICS_FRAMES, region_id])
		return false
	if not world.get_boundary().contains_position(player.global_position):
		_fail("Whole-island route left the playable boundary near %s at %s." % [region_id, player.global_position])
		return false
	if evidence.recovery_count != recoveries_before:
		_fail("Whole-island route triggered recovery near %s: delta=%d." % [region_id, evidence.recovery_count - recoveries_before])
		return false
	return true


func _road_records(world: WorldLoader) -> Array[Node3D]:
	var records: Array[Node3D] = []
	var roads := world.get_node("PlayableWorld/RoadsAndPaths") as Node3D
	for node: Node in roads.find_children("*", "Node3D", true, false):
		if str(node.get_meta("feature_kind", "")) == "road_path" and node.has_node("Mesh"):
			records.append(node as Node3D)
	return records


func _road_sources_at(point: Vector2, road_records: Array[Node3D]) -> Dictionary:
	var sources := {}
	for record: Node3D in road_records:
		var mesh_instance := record.get_node("Mesh") as MeshInstance3D
		var mesh := mesh_instance.mesh as ArrayMesh
		var arrays := mesh.surface_get_arrays(0)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		var contains_point := false
		for offset in range(0, indices.size(), 3):
			var a3: Vector3 = mesh_instance.global_transform * vertices[indices[offset]]
			var b3: Vector3 = mesh_instance.global_transform * vertices[indices[offset + 1]]
			var c3: Vector3 = mesh_instance.global_transform * vertices[indices[offset + 2]]
			if _point_in_triangle(point, Vector2(a3.x, a3.z), Vector2(b3.x, b3.z), Vector2(c3.x, c3.z)):
				contains_point = true
				break
		if contains_point:
			for source_value: Variant in record.get_meta("source_keys", []):
				sources[str(source_value)] = true
	return sources


func _point_in_triangle(point: Vector2, a: Vector2, b: Vector2, c: Vector2) -> bool:
	var cross_ab := (b - a).cross(point - a)
	var cross_bc := (c - b).cross(point - b)
	var cross_ca := (a - c).cross(point - c)
	var has_negative := cross_ab < -0.001 or cross_bc < -0.001 or cross_ca < -0.001
	var has_positive := cross_ab > 0.001 or cross_bc > 0.001 or cross_ca > 0.001
	return not (has_negative and has_positive)


func _ground_hit(point: Vector2, player: PlayerController) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(Vector3(point.x, 100.0, point.y), Vector3(point.x, -20.0, point.y), WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _steer_camera(rig: PlayerCamera, player_position: Vector3, target_xz: Vector2) -> void:
	var direction := Vector3(target_xz.x - player_position.x, 0.0, target_xz.y - player_position.z)
	if direction.length_squared() <= 0.0001:
		return
	rig.look_at(rig.global_position + direction.normalized(), Vector3.UP)


func _wait_for_floor(player: PlayerController, maximum_frames: int) -> bool:
	for _frame in maximum_frames:
		await physics_frame
		if player.is_on_floor():
			return true
	return false


func _brake_to_stop(player: PlayerController, maximum_frames: int) -> void:
	_clear_gameplay_input()
	for _frame in maximum_frames:
		await physics_frame
		if Vector2(player.velocity.x, player.velocity.z).length() <= 0.1:
			return


func _capture_output_directory() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(OUTPUT_ARG_PREFIX):
			return argument.trim_prefix(OUTPUT_ARG_PREFIX).trim_suffix("/")
	return ""


func _capture_checkpoint(checkpoint: Dictionary, player: PlayerController) -> bool:
	if not await _wait_for_render(player):
		return false
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("Checkpoint %s produced an empty viewport image." % checkpoint.id)
		return false
	var filename := "route-%s.png" % checkpoint.id
	var image_path := _route_capture_output.path_join(filename)
	var save_error := image.save_png(image_path)
	if save_error != OK:
		_fail("Checkpoint %s could not save PNG (error %d)." % [checkpoint.id, save_error])
		return false
	var camera := player.get_camera()
	var metadata := {
		"id": str(checkpoint.id),
		"file": filename,
		"sha256": FileAccess.get_sha256(image_path),
		"bytes": FileAccess.get_file_as_bytes(image_path).size(),
		"dimensions": [image.get_width(), image.get_height()],
		"source_key": str(checkpoint.source_key),
		"node_id": str(checkpoint.node_id),
		"player_position": [player.global_position.x, player.global_position.y, player.global_position.z],
		"camera_position": [camera.global_position.x, camera.global_position.y, camera.global_position.z],
		"grounded": player.is_on_floor(),
	}
	_capture_records.append(metadata)
	print("ROUTE_CAPTURE: id=%s image=%s sha256=%s position=(%.3f,%.3f,%.3f)" % [
		checkpoint.id, ProjectSettings.globalize_path(image_path), metadata.sha256,
		player.global_position.x, player.global_position.y, player.global_position.z,
	])
	return true


func _wait_for_render(player: PlayerController) -> bool:
	for _step in 2:
		paused = false
		await process_frame
		await RenderingServer.frame_post_draw
	if paused:
		_fail("Route capture was paused before rendering.")
		return false
	return player.visible and player.is_physics_processing()


func _write_capture_manifest(metrics: Dictionary) -> bool:
	var manifest := {
		"schema_version": 1,
		"generator": "game/tests/automated_route_qa.gd",
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"content_sha256": EXPECTED_CONTENT_SHA256,
		"manifest_sha256": EXPECTED_MANIFEST_SHA256,
		"route": _serializable_route(),
		"metrics": metrics,
		"captures": _capture_records,
	}
	var manifest_path := _route_capture_output.path_join("route-capture-manifest.json")
	var file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if file == null:
		_fail("Could not write route capture manifest: %s" % manifest_path)
		return false
	file.store_string(JSON.stringify(manifest, "  ", false) + "\n")
	file.close()
	print("ROUTE_CAPTURE_MANIFEST: path=%s captures=%d" % [ProjectSettings.globalize_path(manifest_path), _capture_records.size()])
	return true


func _serializable_route() -> Array[Dictionary]:
	var serialized: Array[Dictionary] = []
	for checkpoint: Dictionary in ROUTE:
		var point: Vector2 = checkpoint.xz
		serialized.append({
			"id": str(checkpoint.id),
			"xz": [point.x, point.y],
			"source_key": str(checkpoint.source_key),
			"node_id": str(checkpoint.node_id),
			"mode": str(checkpoint.mode),
			"radius_m": float(checkpoint.radius_m),
			"capture": bool(checkpoint.get("capture", false)),
		})
	return serialized


func _horizontal_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _horizontal_distance_xz(position: Vector3, target: Vector2) -> float:
	return Vector2(position.x - target.x, position.z - target.y).length()


func _clear_gameplay_input() -> void:
	for action: StringName in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_fail(message)
		return false
	return true


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error(message)


func _finish(main: Node, baseline_nodes: int) -> void:
	if _finished:
		return
	_finished = true
	_clear_gameplay_input()
	_restore_simulation_clock()
	if main != null and is_instance_valid(main):
		main.queue_free()
		await process_frame
		await process_frame
	if _failure.is_empty() and get_node_count() != baseline_nodes:
		_fail("Automated route leaked scene-tree nodes: baseline %d, final %d." % [baseline_nodes, get_node_count()])
	quit(0 if _failure.is_empty() else 1)


func _on_timeout() -> void:
	if not _finished:
		_fail("Automated route QA did not finish within %d seconds." % [180 if _whole_island_mode else 120])
		_clear_gameplay_input()
		_restore_simulation_clock()
		quit(1)


func _restore_simulation_clock() -> void:
	if not _simulation_clock_changed:
		return
	Engine.time_scale = _saved_time_scale
	Engine.physics_ticks_per_second = _saved_physics_ticks
	_simulation_clock_changed = false
