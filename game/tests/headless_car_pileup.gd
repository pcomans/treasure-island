extends SceneTree
## A crash into a row of parked street cars stays cheap (owner, 2026-11-13: on
## the web the frame rate tanked as soon as a shoved car hit the next one). In
## the real generated world, physics only (run with --headless --fixed-fps 60):
## a sedan put 30 m behind the last car of the Avenue of the Palms' west kerb row
## drives into it on the stock W, so it shoves that car into the next and so on;
## W stays down for 6 s after the second car went live, then lets go.
##   1. it is a pile-up: the shoved car sets at least one more moving;
##   2. every car it set moving comes to rest and freezes within 10 s;
##   3. the pile-up's physics stays cheap: the mean physics tick (scene physics
##      and the server's step: one a frame under --fixed-fps 60) over the 6 s of
##      pressing into the row is at most PILEUP_TICK_RATIO times the mean over the
##      same car's free run-up in the same process, so the bound is no figure of
##      the machine's speed. On 2026-11-13 this test measured 174.5 times on
##      acdf5c88's code, where each moving car queried its drawn hull pieces
##      against its neighbours' every tick, milliseconds a pair
##      (car-crash-perf-20261113 runs/T3-pileup-test-on-acdf5c88), and 1.5 times
##      on the fix (code-review-car-crash-perf-20261113 runs/P3).
##   4. a crowd cannot hide a car (owner, 2026-11-13: one look round a moving car
##      for everything in its reach, vehicle_reach.gd): with CROWD small boxes on
##      the reach layer, which nothing collides with, between the sedan and a
##      parked car it is driven into from across the road, that car is set
##      moving, and the sedan's reach found the whole crowd at once.
## The cars are the generated rows' (if the world moves them, re-aim DRIVER, ROW,
## HEADING, RUN_UP_M and the CROWD_ fixture here).

const DRIVER := "scatter:avenue_of_the_palms:palms_parked_cars:w1001544697_left_029"
const ROW := "scatter:avenue_of_the_palms:palms_parked_cars:w1001544697_left_024"
## Along the row, toward its next cars (left_023, left_022, ...).
const HEADING := Vector2(-0.4625, -0.8866)
const RUN_UP_M := 30.0
## Ticks after W goes down before the free run-up's ticks count (the car pulls
## away), and of pressing on after the second car went live.
const FREE_FROM_TICKS := 30
const PRESS_TICKS := 360
const CONTACT_LIMIT_TICKS := 600
const REST_LIMIT_TICKS := 600
const PILEUP_TICK_RATIO := 40.0
## The crowd check's parked car, approached across the road from CROWD_START along
## CROWD_HEADING (the vehicle contract's side shove), and the crowd: CROWD boxes
## of CROWD_BOX_M in a cloud CROWD_AHEAD_M short of the car's middle on the way in.
const CROWD_ROW := "scatter:avenue_of_the_palms:palms_parked_cars:w1001544697_left_005"
const CROWD_START := Vector2(-284.6, 308.0)
const CROWD_HEADING := Vector2(0.613, -0.79)
const CROWD := 300
const CROWD_BOX_M := 0.1
const CROWD_AHEAD_M := 2.6

var _main: GameMain
var _vehicles: VehicleManager
var _failures: Array[String] = []
var _signal_us := -1
var _steps := 0


func _initialize() -> void:
	create_timer(420.0, true, false, true).timeout.connect(func() -> void:
		push_error("car pile-up: timed out")
		quit(1))
	call_deferred("_run")


func _run() -> void:
	_main = (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	_main.capture_mouse_on_ready = false
	# The default shadows, never a level saved in the shared user folder (main.gd).
	_main.use_saved_settings = false
	var world := _main.get_node("WorldRoot") as WorldLoader
	var load_failures: Array[String] = []
	world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void: load_failures.append("%s: %s" % [code, message]))
	root.add_child(_main)
	var started := Time.get_ticks_msec()
	while not _main.is_play_ready() and load_failures.is_empty() and Time.get_ticks_msec() - started < 240000:
		await process_frame
	if not _main.is_play_ready():
		return _finish("The world did not reach play: %s" % [load_failures])
	paused = false
	_vehicles = _main.vehicles
	for id: String in [DRIVER, ROW]:
		if _vehicles.row(id).is_empty() or _vehicles.live_node(id) != null:
			return _finish("%s is not a parked car in this world: re-aim the fixture." % id)
	var target: Vector3 = (_vehicles.row(ROW).transform as Transform3D).origin
	var heading := HEADING.normalized()
	var problem := _vehicles.drive_from(DRIVER, Vector2(target.x, target.z) - heading * RUN_UP_M, heading)
	if problem != "":
		return _finish("Could not put the sedan at the run-up: %s" % problem)
	for _tick in 45:
		await physics_frame
	var before := {}
	for id: String in _vehicles.swappable_ids():
		if _vehicles.live_node(id) != null:
			before[id] = true
	physics_frame.connect(_on_physics_frame)
	var free: Array[float] = []
	var pileup: Array[float] = []
	var shoved: Array[String] = []
	var second_at := -1
	var tick := 0
	Input.action_press("move_forward")
	while true:
		_steps = 0
		await process_frame
		var spent := float(Time.get_ticks_usec() - _signal_us) / 1000.0
		tick += _steps
		for id: String in _vehicles.swappable_ids():
			if not before.has(id) and not shoved.has(id) and _vehicles.live_node(id) != null:
				shoved.append(id)
				if shoved.size() == 2:
					second_at = tick
		if _steps != 1:
			continue
		if shoved.is_empty() and tick > FREE_FROM_TICKS:
			free.append(spent)
		elif second_at >= 0:
			pileup.append(spent)
		if second_at >= 0 and tick - second_at >= PRESS_TICKS:
			break
		if shoved.size() < 2 and tick > CONTACT_LIMIT_TICKS:
			break
	Input.action_release("move_forward")
	physics_frame.disconnect(_on_physics_frame)
	var resting := false
	for _tick in REST_LIMIT_TICKS:
		await physics_frame
		resting = shoved.all(func(id: String) -> bool: return (_vehicles.live_node(id) as RigidBody3D).freeze)
		if resting:
			break
	var short_ids := shoved.map(func(id: String) -> String: return id.rsplit(":", true, 1)[-1])
	print("PILEUP %d cars set moving %s; %d free ticks, %d pile-up ticks" % [shoved.size(), short_ids, free.size(), pileup.size()])
	if shoved.size() < 2:
		return _finish("The shoved car set nothing more moving (%s): no pile-up to measure." % [short_ids])
	if not resting:
		var moving := shoved.filter(func(id: String) -> bool: return not (_vehicles.live_node(id) as RigidBody3D).freeze)
		_failures.append("%d cars were still moving %.0f s after W came up: %s" % [moving.size(), REST_LIMIT_TICKS / 60.0, moving])
	var free_mean := _mean(free)
	var pile_mean := _mean(pileup)
	pileup.sort()
	var ratio := pile_mean / maxf(free_mean, 0.001)
	print("PILEUP physics tick: free run-up mean %.3f ms over %d ticks; pile-up mean %.3f ms, 95th percentile %.3f ms, longest %.3f ms over %d ticks; %.1f times the run-up's (at most %.0f)" % [free_mean, free.size(), pile_mean, pileup[int(pileup.size() * 0.95)], pileup[-1], pileup.size(), ratio, PILEUP_TICK_RATIO])
	if ratio > PILEUP_TICK_RATIO:
		_failures.append("The pile-up's mean physics tick took %.1f times the free run-up's (at most %.0f): pressing a car into a row of parked cars is too costly" % [ratio, PILEUP_TICK_RATIO])
	_finish(await _crowd())


## A crowd of things in reach between the sedan and a parked car: the car is still
## set moving and the reach found the whole crowd at once. "" or what failed.
func _crowd() -> String:
	if _vehicles.row(CROWD_ROW).is_empty() or _vehicles.live_node(CROWD_ROW) != null:
		return "%s is not a static parked car in this world: re-aim the crowd fixture." % CROWD_ROW
	var heading := CROWD_HEADING.normalized()
	var problem := _vehicles.drive_from(DRIVER, CROWD_START, heading)
	if problem != "":
		return "Could not put the sedan at the crowd check's start: %s" % problem
	for _tick in 45:
		await physics_frame
	var target: Transform3D = _vehicles.row(CROWD_ROW).transform
	var along := Vector3(heading.x, 0.0, heading.y)
	var across := along.cross(Vector3.UP)
	var middle := target.origin - along * CROWD_AHEAD_M
	var crowd := StaticBody3D.new()
	crowd.name = "ReachCrowd"
	crowd.collision_layer = VehicleReach.PHYSICS_REACH
	crowd.collision_mask = 0
	var box := BoxShape3D.new()
	box.size = Vector3.ONE * CROWD_BOX_M
	var random := RandomNumberGenerator.new()
	random.seed = 20261113
	for index in CROWD:
		var piece := CollisionShape3D.new()
		piece.shape = box
		piece.position = middle + along * random.randf_range(-0.8, 0.8) + across * random.randf_range(-0.6, 0.6) + Vector3.UP * random.randf_range(0.4, 1.3)
		crowd.add_child(piece)
	root.add_child(crowd)
	Input.action_press("move_forward")
	var live_at := -1
	for tick in 300:
		await physics_frame
		if _vehicles.live_node(CROWD_ROW) != null:
			live_at = tick
			break
	Input.action_release("move_forward")
	crowd.queue_free()
	print("CROWD %s set moving at tick %d with %d boxes in reach; the most one reach found %d" % [CROWD_ROW.rsplit(":", true, 1)[-1], live_at, CROWD, _vehicles.reach_most_hits()])
	if live_at < 0:
		return "Driven into %s through a crowd of %d things in its reach, the sedan did not set it moving: the crowd pushed it out of what the reach found." % [CROWD_ROW, CROWD]
	if _vehicles.reach_most_hits() < CROWD:
		return "The sedan's reach found at most %d of the %d things in it at once: a full list must be asked again with room for more (vehicle_reach.gd find), unless the crowd fixture no longer stands in its way." % [_vehicles.reach_most_hits(), CROWD]
	return ""


func _on_physics_frame() -> void:
	if _steps == 0:
		_signal_us = Time.get_ticks_usec()
	_steps += 1


func _mean(values: Array[float]) -> float:
	var total := 0.0
	for value in values:
		total += value
	return total / maxf(1.0, float(values.size()))


func _finish(problem: String) -> void:
	if problem != "":
		_failures.append(problem)
	Input.action_release("move_forward")
	if _failures.is_empty():
		print("PASS car pile-up: a sedan driven into a row of parked cars shoves one into the next, every car it set moving comes to rest, and the pile-up's physics tick stays within %.0f times the free run-up's; driven into a parked car through a crowd of %d things in its reach, it sets it moving" % [PILEUP_TICK_RATIO, CROWD])
		quit(0)
	else:
		for failure in _failures:
			print("FAIL car pile-up: %s" % failure)
		quit(1)
