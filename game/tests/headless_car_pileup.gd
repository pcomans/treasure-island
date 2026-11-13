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
##   4. a dense spot stays cheap (owner, 2026-11-13: one look round a moving car
##      for everything in its reach, not one check per kind of thing, so a new
##      kind's own check that grows expensive fails here): the same sedan on the
##      stock W along Bruton Street's lamp line, DENSE_OFFSET_M toward the Cultural
##      Park's screened fence, which runs about 2 m from the lamps, knocking the
##      lamps over as it goes with the fence within its reach; it must fell at
##      least DENSE_MIN_LAMPS and have a fence bay within its reach for at least
##      DENSE_MIN_FENCE_TICKS ticks, and its mean physics tick there is at most
##      DENSE_TICK_RATIO times the pile-up's free run-up's;
##   5. a crowd cannot hide a car (owner, 2026-11-13: one look round a moving car
##      for everything in its reach, vehicle_reach.gd): with CROWD small boxes on
##      the reach layer, which nothing collides with, between the sedan and a
##      parked car it is driven into from across the road, that car is set
##      moving, and the sedan's reach found the whole crowd at once.
## The cars and lamps are the generated rows' (if the world moves them, re-aim
## DRIVER, ROW, HEADING, RUN_UP_M and the DENSE_ and CROWD_ fixtures here).

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
## The dense spot: the first and last of Bruton Street's lamps in a line (the
## Cultural Park's screened fence about 2 m from it, toward which the sedan runs
## DENSE_OFFSET_M off the line, the kerb cars 3 m the other way), the run-up to
## the first, and how far the sedan goes past the last.
const DENSE_FIRST := "scatter:island:bruton_lamps:w1212176122_right_005"
const DENSE_LAST := "scatter:island:bruton_lamps:w1212176122_right_011"
const DENSE_RUN_UP_M := 14.0
const DENSE_OFFSET_M := 0.75
const DENSE_PAST_M := 2.0
const DENSE_MIN_LAMPS := 5
const DENSE_MIN_FENCE_TICKS := 30
const DENSE_TICK_RATIO := 4.0
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
	print("PILEUP %d cars set moving %s, %d street lamps knocked over; %d free ticks, %d pile-up ticks" % [shoved.size(), short_ids, _vehicles.furniture_breaker().felled_ids().size(), free.size(), pileup.size()])
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
	var dense := await _dense(free_mean)
	if dense != "":
		_failures.append(dense)
	_finish(await _crowd())


## Along Bruton Street's lamp line beside the screened fence: the lamps fall, the
## fence is in reach, and the mean physics tick stays within DENSE_TICK_RATIO of
## the free run-up's (free_mean, ms). "" or what failed.
func _dense(free_mean: float) -> String:
	var lamps := _vehicles.furniture_breaker()
	var first: Dictionary = lamps.pole(DENSE_FIRST)
	var last: Dictionary = lamps.pole(DENSE_LAST)
	if first.is_empty() or last.is_empty():
		return "%s or %s is not a street lamp a car knocks over in this world: re-aim the dense fixture." % [DENSE_FIRST, DENSE_LAST]
	var a := Vector2((first.foot as Vector3).x, (first.foot as Vector3).z)
	var b := Vector2((last.foot as Vector3).x, (last.foot as Vector3).z)
	var heading := (b - a).normalized()
	var aside := Vector2(-heading.y, heading.x) * DENSE_OFFSET_M
	var problem := _vehicles.drive_from(DRIVER, a - heading * DENSE_RUN_UP_M + aside, heading)
	if problem != "":
		return "Could not put the sedan at the dense spot's start: %s" % problem
	for _tick in 45:
		await physics_frame
	var car := _vehicles.active_car()
	var fences := {}
	for rid: RID in _vehicles.fence_breaker().fence_bodies():
		fences[rid] = true
	var probe := PhysicsShapeQueryParameters3D.new()
	var probe_box := BoxShape3D.new()
	probe.shape = probe_box
	probe.collision_mask = VehicleReach.PHYSICS_STREET_PROP
	var felled_before := lamps.felled_ids().size()
	var spent_ticks: Array[float] = []
	var fence_ticks := 0
	var length := (b - a).length()
	physics_frame.connect(_on_physics_frame)
	Input.action_press("move_forward")
	for _frame in 900:
		var at := Vector2(car.global_position.x, car.global_position.z)
		var target := b + heading * 30.0 + aside
		var forward := -car.global_transform.basis.z
		var angle := Vector2(forward.x, forward.z).angle_to(target - at)
		Input.action_release("move_left")
		Input.action_release("move_right")
		if angle > deg_to_rad(2.0):
			Input.action_press("move_right")
		elif angle < deg_to_rad(-2.0):
			Input.action_press("move_left")
		_steps = 0
		await process_frame
		var spent := float(Time.get_ticks_usec() - _signal_us) / 1000.0
		if _steps == 1:
			spent_ticks.append(spent)
		# A fence bay within the reach's largest margin (the look-ahead's) of the
		# car's box: asked here, after the tick's time is taken.
		var box := VehicleReach.reach_box(car)
		probe_box.size = box.size + Vector3.ONE * 0.8
		probe.transform = car.global_transform * Transform3D(Basis.IDENTITY, box.get_center())
		probe.exclude = [car.get_rid()]
		for hit: Dictionary in car.get_world_3d().direct_space_state.intersect_shape(probe, 64):
			if fences.has(hit.get("rid", RID())):
				fence_ticks += 1
				break
		if (Vector2(car.global_position.x, car.global_position.z) - a).dot(heading) > length + DENSE_PAST_M:
			break
	Input.action_release("move_forward")
	Input.action_release("move_left")
	Input.action_release("move_right")
	physics_frame.disconnect(_on_physics_frame)
	Input.action_press("move_back")
	for _tick in 180:
		await physics_frame
		if car.linear_velocity.length() < 0.5:
			break
	Input.action_release("move_back")
	var felled := lamps.felled_ids().size() - felled_before
	var mean := _mean(spent_ticks)
	spent_ticks.sort()
	var ratio := mean / maxf(free_mean, 0.001)
	print("DENSE along Bruton Street's lamps beside the fence: %d lamps felled, a fence bay in reach %d ticks; physics tick mean %.3f ms, 95th percentile %.3f ms, longest %.3f ms over %d ticks; %.1f times the free run-up's (at most %.0f)" % [felled, fence_ticks, mean, spent_ticks[int(spent_ticks.size() * 0.95)] if not spent_ticks.is_empty() else NAN, spent_ticks[-1] if not spent_ticks.is_empty() else NAN, spent_ticks.size(), ratio, DENSE_TICK_RATIO])
	if felled < DENSE_MIN_LAMPS or fence_ticks < DENSE_MIN_FENCE_TICKS:
		return "Along Bruton Street the sedan felled %d lamps (at least %d) and had a fence bay in reach %d ticks (at least %d): re-aim the dense fixture." % [felled, DENSE_MIN_LAMPS, fence_ticks, DENSE_MIN_FENCE_TICKS]
	if ratio > DENSE_TICK_RATIO:
		return "Along Bruton Street's lamps beside the fence the mean physics tick took %.1f times the free run-up's (at most %.0f): what a moving car finds round it is too costly to judge" % [ratio, DENSE_TICK_RATIO]
	return ""


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
		print("PASS car pile-up: a sedan driven into a row of parked cars shoves one into the next, every car it set moving comes to rest, and the pile-up's physics tick stays within %.0f times the free run-up's; along a lamp line beside a fence it knocks the lamps over within %.0f times; driven into a parked car through a crowd of %d things in its reach, it sets it moving" % [PILEUP_TICK_RATIO, DENSE_TICK_RATIO, CROWD])
		quit(0)
	else:
		for failure in _failures:
			print("FAIL car pile-up: %s" % failure)
		quit(1)
