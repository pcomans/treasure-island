extends SceneTree
## Drivable cars (owner, 2026-11-08) in the real generated world, physics only
## (run with --headless and --fixed-fps 60). The places come from
## game/tests/shared/vehicle_cases.json. Cases, in order; the first failure
## stops the run (later cases need the earlier ones):
##   1. enter and exit with F: the stock player beside a parked car presses F
##      and drives it (avatar hidden, capsule off, the parked box gone), the view
##      blending from the on-foot camera to the chase camera; F again stands the
##      player on the ground beside it, walking as before, the view blending
##      back; the car comes to rest, freezes and stays there; F gets back in;
##   2. a run along Seven Seas Avenue: up to speed, mostly on its wheels and
##      level, no recovery; then a handbrake turn that slides and stays upright;
##   3. off the west shore into the bay: the car meets the water (a splash),
##      sinks for a moment with the player kept in it (F does nothing), then car
##      and player are back on land, upright, facing away from the water;
##   4. a roll: a car rolled over comes to rest on its roof or side; F gets
##      the player out of it there, it rights itself within a few seconds with
##      nobody in it, F gets back in and it drives on;
##   5. a ramp: driven straight at a dirt kicker at a sensible speed, the car
##      leaves the ground, flies and lands on its wheels, upright;
##   6. a fence: the car drives through a construction-panel bay, which breaks
##      and falls, keeps most of its speed; on foot an intact bay of the same
##      fence still stops the stock player and the broken gap lets it through;
##   7. plants: the car drives through a shrub without slowing and stops at a
##      palm's trunk;
##   8. shoves: a car creeping into a parked car and then pressing on at full
##      throttle pushes it; a parked car hit from the side at speed and a K-rail
##      hit end on are set moving; each comes to rest where it ends up;
##   9. on foot after getting out: the stock walk, run, jetpack and fast drop.
## Every case ends with the car stopped and the player standing, inputs released.

const CASES_PATH := "res://game/tests/shared/vehicle_cases.json"
const DRIVABLE_CAR := preload("res://game/scripts/vehicles/drivable_car.gd")
const VEHICLE_MANAGER := preload("res://game/scripts/vehicles/vehicle_manager.gd")
const VEHICLE_ACTIONS := ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack", "fast_drop", "vehicle_enter_exit", "handbrake", "recover"]

var _failure := ""
var _main: GameMain
var _world: WorldLoader
var _player: PlayerController
var _vehicles: VEHICLE_MANAGER
var _cases: Dictionary
var _recoveries: Array[Dictionary] = []


func _initialize() -> void:
	create_timer(900.0, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	_main = (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	_main.capture_mouse_on_ready = false
	_world = _main.get_node("WorldRoot") as WorldLoader
	_player = _main.get_node("Player") as PlayerController
	var load_failures: Array[String] = []
	_world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void: load_failures.append("%s: %s" % [code, message]))
	root.add_child(_main)
	var started := Time.get_ticks_msec()
	while not _main.is_play_ready() and load_failures.is_empty() and Time.get_ticks_msec() - started < 180000:
		await process_frame
	if not _require(load_failures.is_empty() and _main.is_play_ready(), "World did not reach play: %s" % [load_failures]):
		return _finish()
	paused = false
	_release()
	_vehicles = _main.vehicles
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CASES_PATH))
	if not _require(parsed is Dictionary and _vehicles != null, "No vehicle manager or no %s." % CASES_PATH):
		return _finish()
	_cases = parsed
	_vehicles.car_recovered.connect(func(cause: String, from: Vector3) -> void: _recoveries.append({"cause": cause, "from": from, "tick": Engine.get_physics_frames()}))
	print("VEHICLE swappable rows %d" % _vehicles.swappable_ids().size())
	for case: Callable in [_case_enter_exit, _case_route, _case_plunge, _case_roll, _case_ramp, _case_fence, _case_plants, _case_shove, _case_on_foot]:
		if not await case.call():
			return _finish()
	print("PASS: drivable cars: F in and out beside a parked car that stays where it was left, the view blending each way, a run on Seven Seas Avenue on its wheels, a handbrake slide, a splash and back on land from the bay facing inland, a roll onto its roof or side, F out of it there, the car righting itself and F back in, a clean jump off a ramp, a fence bay broken while intact bays still stop the player, through a shrub and stopped by a palm, a parked car pushed from a standstill and one and a K-rail shoved at speed, and the stock walk, run, jetpack and fast drop after getting out")
	_finish()


# --- 1. Enter and exit with F.

func _case_enter_exit() -> bool:
	var id := str(_cases.enter.car)
	var entry: Dictionary = _vehicles.row(id)
	if not _require(not entry.is_empty() and str(entry.prop) == "parked_car", "Fixture car %s is not a swappable parked car." % id):
		return false
	var parked: Transform3D = entry.transform
	# The stock player 1.6 m off the driver's (left) door, walking.
	var door := parked.origin - parked.basis.x * 1.6
	if not await _stand_player(Vector2(door.x, door.z)):
		return false
	var shape := _parked_shape(entry)
	if not _require(shape != null and not shape.disabled, "The parked car %s has no enabled collision box." % id):
		return false
	var view_before := _player.get_camera().global_transform
	await _press("vehicle_enter_exit")
	var car := _vehicles.active_car() as DRIVABLE_CAR
	if not _require(car != null and _vehicles.live_node(id) == car, "F beside %s did not get the player in." % id) \
	or not _require(_player.is_driving() and not (_player.get_node("AvatarPivot") as Node3D).visible and (_player.get_node("CollisionShape3D") as CollisionShape3D).disabled, "Driving, the avatar must hide and the capsule stop colliding.") \
	or not _require(shape.disabled, "The parked box must be gone once the live car stands in for it.") \
	or not _require(not _player.is_processing_unhandled_input(), "The stock controller must stop while driving."):
		return false
	# The view starts where the on-foot camera was and ends behind the car.
	var rig := _vehicles.driving_camera()
	var showing := _main.get_viewport().get_camera_3d()
	var start_gap := showing.global_position.distance_to(view_before.origin)
	if not _require(rig.is_blending() and showing != rig.camera and start_gap < 1.5, "Getting in must blend from the on-foot view (blending %s, %.2f m from it)." % [rig.is_blending(), start_gap]):
		return false
	# Settle, drive a few metres, stop.
	for _tick in 45:
		await physics_frame
	if not _require(not rig.is_blending() and _main.get_viewport().get_camera_3d() == rig.camera, "After the blend the chase camera must show."):
		return false
	Input.action_press("move_forward")
	for _tick in 90:
		await physics_frame
	Input.action_release("move_forward")
	Input.action_press("move_back")
	for _tick in 60:
		await physics_frame
		if car.linear_velocity.length() < 0.3:
			break
	Input.action_release("move_back")
	for _tick in 30:
		await physics_frame
	var moved := car.global_position.distance_to(parked.origin)
	print("ENTER drove %.2f m, speed %.2f, up %.3f, wheels %d" % [moved, car.linear_velocity.length(), car.global_transform.basis.y.y, car.grounded_wheels()])
	if not _require(moved > 3.0 and car.grounded_wheels() == 4, "The car did not drive off on its wheels (moved %.2f m)." % moved):
		return false
	await _press("vehicle_enter_exit")
	var out := _player.global_position
	if not _require(not _player.is_driving() and _vehicles.active_car() == null, "F did not get the player out.") \
	or not _require((_player.get_node("AvatarPivot") as Node3D).visible and not (_player.get_node("CollisionShape3D") as CollisionShape3D).disabled and _player.is_processing_unhandled_input(), "Out of the car the player must walk as before.") \
	or not _require(rig.is_blending() and _main.get_viewport().get_camera_3d() != _player.get_camera(), "Getting out must blend back to the on-foot view."):
		return false
	for _tick in 60:
		await physics_frame
	if not _require(not rig.is_blending() and _main.get_viewport().get_camera_3d() == _player.get_camera(), "After the blend the on-foot camera must show."):
		return false
	var beside := Vector2(out.x - car.global_position.x, out.z - car.global_position.z).length()
	print("EXIT at %s, %.2f m from the car, on floor %s" % [_player.global_position, beside, _player.is_on_floor()])
	if not _require(_player.is_on_floor() and beside < 4.0 and absf(_player.global_position.y - car.global_position.y) < 1.5, "The player must stand on the ground beside the car (%.2f m away, on floor %s)." % [beside, _player.is_on_floor()]):
		return false
	# Left alone, the car comes to rest, freezes and stays there.
	for _tick in 120:
		await physics_frame
	var rested := car.global_position
	if not _require(car.freeze, "The car left alone did not freeze where it stopped."):
		return false
	for _tick in 60:
		await physics_frame
	if not _require(car.global_position.distance_to(rested) < 0.01, "The parked car moved after it froze."):
		return false
	# Back in from beside it, and out again.
	await _press("vehicle_enter_exit")
	if not _require(_vehicles.active_car() == car and not car.freeze, "F beside the moved car did not get back in."):
		return false
	await _press("vehicle_enter_exit")
	if not _require(not _player.is_driving(), "F did not get out the second time."):
		return false
	return await _rest("enter_exit")


# --- 2. A run on Seven Seas Avenue, and a handbrake slide.

func _case_route() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var points: Array = _cases.route.points_xz
	var start := Vector2(points[0][0], points[0][1])
	var next := Vector2(points[1][0], points[1][1])
	if not await _drive_from(car, start, next - start):
		return false
	var waypoint := 1
	var ticks := 0
	var limit := int(float(_cases.route.time_s) * 60.0)
	var top := 0.0
	var grounded_ticks := 0
	var lowest_up := 1.0
	var recoveries_before := _recoveries.size()
	Input.action_press("move_forward")
	while waypoint < points.size() and ticks < limit:
		var target := Vector2(points[waypoint][0], points[waypoint][1])
		var at := Vector2(car.global_position.x, car.global_position.z)
		if at.distance_to(target) < 8.0:
			waypoint += 1
			continue
		_steer_toward(car, target)
		await physics_frame
		ticks += 1
		top = maxf(top, car.linear_velocity.length())
		grounded_ticks += 1 if car.grounded_wheels() >= 3 else 0
		lowest_up = minf(lowest_up, car.global_transform.basis.y.y)
		if ticks % 60 == 0:
			print("ROUTE t=%.1f s at %s %s" % [ticks / 60.0, car.global_position, JSON.stringify(car.describe())])
	_release_driving()
	var share := float(grounded_ticks) / float(maxi(ticks, 1))
	print("ROUTE reached %d/%d waypoints in %.1f s, top %.2f m/s, on 3+ wheels %.3f, lowest up %.3f" % [waypoint, points.size(), ticks / 60.0, top, share, lowest_up])
	if not _require(waypoint == points.size(), "The run did not reach the end of the route (waypoint %d/%d)." % [waypoint, points.size()]) \
	or not _require(top >= float(_cases.route.min_speed_mps), "The car only reached %.2f m/s." % top) \
	# The land under the road dips by up to about 0.9 m over 20 m here (the terrain
	# mesh), so a fast car floats over a few crests: mostly on its wheels, level.
	or not _require(share >= 0.85 and lowest_up >= 0.95, "The car left its wheels on an ordinary road run (%.3f on 3+ wheels, lowest up %.3f)." % [share, lowest_up]) \
	or not _require(_recoveries.size() == recoveries_before, "A recovery fired on the road run."):
		return false
	# A handbrake turn at speed: it slides, and stays on its wheels.
	Input.action_press("move_forward")
	for _tick in 240:
		await physics_frame
		if car.linear_velocity.length() >= 18.0:
			break
	Input.action_press("move_left")
	Input.action_press("handbrake")
	var slip := 0.0
	var turned := 0.0
	var heading := car.global_transform.basis.z
	var lowest := 1.0
	for _tick in 70:
		await physics_frame
		var velocity := car.linear_velocity
		if velocity.length() > 3.0:
			slip = maxf(slip, rad_to_deg(velocity.normalized().angle_to(-car.global_transform.basis.z)))
		lowest = minf(lowest, car.global_transform.basis.y.y)
	turned = rad_to_deg(heading.angle_to(car.global_transform.basis.z))
	_release_driving()
	print("SLIDE slip %.1f deg, turned %.1f deg, lowest up %.3f" % [slip, turned, lowest])
	if not _require(slip > 15.0 and turned > 45.0, "The handbrake turn did not slide (slip %.1f deg, turned %.1f deg)." % [slip, turned]):
		return false
	return await _stop_and_exit(car, "route")


# --- 3. Off the west shore into the bay.

func _case_plunge() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var start := Vector2(_cases.plunge.start_xz[0], _cases.plunge.start_xz[1])
	var direction := Vector2(_cases.plunge.direction_xz[0], _cases.plunge.direction_xz[1]).normalized()
	if not await _drive_from(car, start, direction):
		return false
	var boundary := _world.get_boundary()
	var before := _recoveries.size()
	var left_island := false
	var seen := {}
	var on_splash := func(at: Vector3, speed: float) -> void:
		seen["at"] = at
		seen["speed"] = speed
		seen["lowest"] = car.lowest_y(car.global_transform)
		seen["splashes"] = _vehicles.find_children("Splash*", "", false, false).size()
	car.splashed.connect(on_splash)
	var sinking_ticks := 0
	var tried_exit := false
	var stayed_in := true
	Input.action_press("move_forward")
	for _tick in 900:
		_steer_toward(car, start + direction * 400.0)
		await physics_frame
		left_island = left_island or not boundary.contains_position(car.global_position)
		if car.is_sinking():
			sinking_ticks += 1
			if sinking_ticks == 30 and not tried_exit:
				tried_exit = true
				_release_driving()
				await _press("vehicle_enter_exit")
				stayed_in = _player.is_driving() and _vehicles.active_car() == car
		if _recoveries.size() > before:
			break
	_release_driving()
	car.splashed.disconnect(on_splash)
	if not _require(left_island and _recoveries.size() > before, "Driving off the shore did not bring the car back (left the island %s)." % left_island):
		return false
	var event: Dictionary = _recoveries[_recoveries.size() - 1]
	var water_y := car.water_y
	print("PLUNGE splash %s at %.2f m/s, lowest corner %.2f m (water %.2f), %d splash nodes; sank %.2f s; F while sinking kept the player in: %s" % [seen.get("at"), seen.get("speed", 0.0), seen.get("lowest", INF), water_y, seen.get("splashes", 0), sinking_ticks / 60.0, stayed_in])
	if not _require(seen.has("at") and absf((seen.at as Vector3).y - water_y) < 0.05 and float(seen.lowest) <= water_y + 0.02 and int(seen.splashes) >= 1, "The car must meet the water and splash before it goes back (%s)." % [seen]) \
	or not _require(event.cause == "water" and sinking_ticks >= int((DRIVABLE_CAR.SINK_S - 0.1) * 60.0), "The car must sink for a moment before it goes back (%s after %.2f s)." % [event.cause, sinking_ticks / 60.0]) \
	or not _require(tried_exit and stayed_in, "F while the car sinks must keep the player in it."):
		return false
	for _tick in 90:
		await physics_frame
	var forward := -car.global_transform.basis.z
	var outward := Vector3(direction.x, 0.0, direction.y)
	var ahead := car.global_position + Vector3(forward.x, 0.0, forward.z).normalized() * DRIVABLE_CAR.RESET_CLEAR_M
	print("PLUNGE recovered (%s) from %s to %s, up %.3f, wheels %d, facing %s (%.2f along the way it went in), island ahead %s, driving %s" % [event.cause, event.from, car.global_position, car.global_transform.basis.y.y, car.grounded_wheels(), forward, forward.dot(outward), boundary.contains_position(ahead), _player.is_driving()])
	if not _require(boundary.contains_position(car.global_position) and car.global_transform.basis.y.y > 0.9 and car.grounded_wheels() >= 3, "The car is not back on land, upright, on its wheels.") \
	or not _require(boundary.contains_position(ahead) and forward.dot(outward) < 0.3, "Back on land the car must face away from the water.") \
	or not _require(_player.is_driving() and _vehicles.active_car() == car, "The player must come back in the car."):
		return false
	return await _stop_and_exit(car, "plunge")


# --- 4. A roll that rights itself.

func _case_roll() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var at := Vector2(_cases.roll.at_xz[0], _cases.roll.at_xz[1])
	var heading := Vector2(_cases.roll.heading_xz[0], _cases.roll.heading_xz[1])
	if not await _drive_from(car, at, heading):
		return false
	# A hard knock from the side, as a crash would give it: it rolls over. A
	# knock that lands it back on its wheels (a full barrel roll, or none) is
	# tried again with another spin.
	var flipped_at := -1
	var righted_at := -1
	var lowest := 1.0
	for spin: float in [4.4, 3.6, 5.2]:
		var right := car.global_transform.basis.x
		car.linear_velocity = right * 4.0 + Vector3.UP * 3.5
		car.angular_velocity = -car.global_transform.basis.z * spin
		lowest = 1.0
		for tick in 600:
			await physics_frame
			var up := car.global_transform.basis.y.y
			lowest = minf(lowest, up)
			if tick % 30 == 0:
				print("ROLL spin %.1f t=%.1f s at %s turning %.2f rad/s %s" % [spin, tick / 60.0, car.global_position, car.angular_velocity.length(), JSON.stringify(car.describe())])
			if up < 0.5 and car.linear_velocity.length() < 1.0 and car.angular_velocity.length() < 1.0:
				flipped_at = tick
				break
			if tick > 150 and up > 0.95 and car.linear_velocity.length() < 0.3:
				break
		if flipped_at >= 0:
			break
	if not _require(flipped_at >= 0, "The knocked car did not come to rest on its roof or side (lowest up %.3f)." % lowest):
		return false
	var flipped_frame := Engine.get_physics_frames()
	# F gets the player out of the car on its roof or side, onto the ground.
	await _press("vehicle_enter_exit")
	for _tick in 30:
		await physics_frame
	var out_on_floor := _player.is_on_floor()
	if not _require(not _player.is_driving() and out_on_floor, "F did not get the player out of the flipped car onto the ground (on floor %s)." % out_on_floor):
		return false
	# With nobody in it (the player stepped well clear of its roll), it rights itself.
	if not await _stand_player(Vector2(car.global_position.x, car.global_position.z) + Vector2(7.0, 0.0)):
		return false
	for _tick in 360:
		if car.global_transform.basis.y.y > 0.95 and car.grounded_wheels() >= 3 and not car.is_righting():
			righted_at = Engine.get_physics_frames() - flipped_frame
			break
		await physics_frame
	print("ROLL lowest up %.3f, came to rest flipped, F got the player out onto the ground, and it was back on its wheels %.2f s later" % [lowest, righted_at / 60.0])
	if not _require(righted_at >= 0 and righted_at / 60.0 <= 5.0, "The flipped car did not right itself within 5 s."):
		return false
	# F beside it gets back in, and it drives on.
	var side := car.global_transform.basis.x
	side.y = 0.0
	var door := car.global_position - side.normalized() * (car.width_m * 0.5 + 0.8)
	if not await _stand_player(Vector2(door.x, door.z)):
		return false
	await _press("vehicle_enter_exit")
	if not _require(_player.is_driving() and _vehicles.active_car() == car, "F beside the righted car did not get back in."):
		return false
	for _tick in 20:
		await physics_frame
	var from := car.global_position
	Input.action_press("move_forward")
	for _tick in 120:
		await physics_frame
	_release_driving()
	var gone := car.global_position.distance_to(from)
	print("ROLL drove on %.2f m, up %.3f" % [gone, car.global_transform.basis.y.y])
	if not _require(gone > 5.0 and car.global_transform.basis.y.y > 0.9, "The righted car did not drive on (%.2f m)." % gone):
		return false
	return await _stop_and_exit(car, "roll")



# --- 5. A clean jump off a ramp.

func _case_ramp() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var start := Vector2(_cases.ramp.start_xz[0], _cases.ramp.start_xz[1])
	var heading := Vector2(_cases.ramp.heading_xz[0], _cases.ramp.heading_xz[1]).normalized()
	var cap := float(_cases.ramp.speed_mps)
	if not await _drive_from(car, start, heading):
		return false
	var recoveries_before := _recoveries.size()
	var airborne := 0
	var longest := 0
	var lowest_up := 1.0
	var takeoff := 0.0
	var landed_at := -1
	var tick := 0
	while tick < 600:
		_steer_toward(car, start + heading * 300.0)
		# Up to the cap, then off the throttle from take-off and braking once down.
		Input.action_release("move_forward")
		if landed_at >= 0:
			Input.action_press("move_back")
		elif longest < 15 and car.linear_velocity.length() <= cap:
			Input.action_press("move_forward")
		await physics_frame
		tick += 1
		if car.grounded_wheels() == 0:
			if airborne == 0:
				takeoff = car.linear_velocity.length()
			airborne += 1
			longest = maxi(longest, airborne)
			lowest_up = minf(lowest_up, car.global_transform.basis.y.y)
		else:
			if airborne >= 15 and landed_at < 0:
				landed_at = tick
			airborne = 0
		if landed_at >= 0 and tick >= landed_at + 45:
			break
	_release_driving()
	print("RAMP %s: took off at %.2f m/s, %.2f s in the air, lowest up %.3f in the air; 0.75 s after landing up %.3f, wheels %d" % [_cases.ramp.row, takeoff, longest / 60.0, lowest_up, car.global_transform.basis.y.y, car.grounded_wheels()])
	if not _require(longest >= 30 and landed_at >= 0, "Driving straight at the ramp did not fly the car (%.2f s in the air)." % (longest / 60.0)) \
	or not _require(lowest_up > 0.5 and car.global_transform.basis.y.y > 0.9 and car.grounded_wheels() >= 3, "A straight jump at a sensible speed must land on the wheels, upright.") \
	or not _require(_recoveries.size() == recoveries_before, "A recovery fired on the jump."):
		return false
	return await _stop_and_exit(car, "ramp")


# --- 6. A fence: through it in a car, solid on foot.

func _case_fence() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var start := Vector2(_cases.fence.start_xz[0], _cases.fence.start_xz[1])
	var heading := Vector2(_cases.fence.heading_xz[0], _cases.fence.heading_xz[1]).normalized()
	var group := _world.street_detail_layer("fences").find_child("Fence__" + str(_cases.fence.row).validate_node_name(), true, false) as Node3D
	if not _require(group != null and group.has_meta("fence_bays"), "Fixture fence %s has no bays." % _cases.fence.row):
		return false
	if not await _drive_from(car, start, heading):
		return false
	var breaker := _vehicles.fence_breaker()
	var broken_before := breaker.broken_count()
	var last_speed := 0.0
	var speed_in := 0.0
	var speed_out := 0.0
	var broke_tick := -1
	Input.action_press("move_forward")
	for tick in 360:
		_steer_toward(car, start + heading * 200.0)
		await physics_frame
		if broke_tick < 0 and breaker.broken_count() > broken_before:
			broke_tick = tick
			speed_in = last_speed
		last_speed = car.linear_velocity.length()
		if broke_tick >= 0 and tick >= broke_tick + 30:
			speed_out = last_speed
			break
	_release_driving()
	var keys: Array = breaker.broken_keys().slice(broken_before)
	var bays: Dictionary = group.get_meta("fence_bays")
	print("FENCE broke %s at %.2f m/s, %.2f m/s half a second later, debris %d" % [keys, speed_in, speed_out, breaker.get_child_count()])
	if not _require(broke_tick >= 0 and keys.size() >= 1 and keys.size() <= 4, "Driving into the fence broke %d bays." % keys.size()) \
	or not _require(speed_out >= 0.7 * speed_in and speed_in > 5.0, "The car did not keep going through the fence (%.2f -> %.2f m/s)." % [speed_in, speed_out]) \
	or not _require(breaker.get_child_count() >= keys.size(), "No debris fell from the broken bays."):
		return false
	var broken: Dictionary = bays[keys[0]]
	var car_xz := Vector2(car.global_position.x, car.global_position.z)
	if not _require(_side(broken, car_xz) != _side(broken, start), "The car did not get through the fence line."):
		return false
	if not await _stop_and_exit(car, "fence_drive"):
		return false
	# On foot: an intact bay away from the break still stops the player...
	var intact := ""
	for key: String in bays:
		if breaker.is_broken(key) or key.begins_with("g"):
			continue
		var mid := ((bays[key].a as Vector3) + (bays[key].b as Vector3)) * 0.5
		var broken_mid := ((broken.a as Vector3) + (broken.b as Vector3)) * 0.5
		if mid.distance_to(broken_mid) > 12.0 and mid.distance_to(broken_mid) < 30.0:
			intact = key
			break
	if not _require(intact != "", "No intact bay near the break to walk into."):
		return false
	if not await _walk_into_bay(bays[intact], false, "intact bay %s" % intact):
		return false
	# ...and the broken gap lets it through.
	return await _walk_into_bay(broken, true, "broken bay %s" % keys[0])


## Which side of a bay's line a point lies on.
func _side(bay: Dictionary, xz: Vector2) -> bool:
	var a: Vector3 = bay.a
	var b: Vector3 = bay.b
	return (b.x - a.x) * (xz.y - a.z) - (b.z - a.z) * (xz.x - a.x) > 0.0


## The stock player walks at a bay from 2.5 m off its middle: through it when
## open (crossed), stopped by it when solid (not crossed, held near the line).
func _walk_into_bay(bay: Dictionary, open: bool, label: String) -> bool:
	var a: Vector3 = bay.a
	var b: Vector3 = bay.b
	var mid := (a + b) * 0.5
	var along := Vector2(b.x - a.x, b.z - a.z).normalized()
	var normal := Vector2(-along.y, along.x)
	var from := Vector2(mid.x, mid.z) + normal * 2.5
	if not await _stand_player(from):
		return false
	var rig := _player.get_node("CameraPivot") as Node3D
	rig.rotation.y = atan2(normal.x, normal.y)
	var start_side := _side(bay, from)
	Input.action_press("move_forward")
	for _tick in 120:
		await physics_frame
	_release()
	var at := Vector2(_player.global_position.x, _player.global_position.z)
	var crossed := _side(bay, at) != start_side
	var gap := absf((at - Vector2(a.x, a.z)).dot(normal))
	print("FENCE on foot at %s: crossed %s, %.2f m from the line" % [label, crossed, gap])
	if open:
		return _require(crossed, "The stock player could not walk through the broken gap at %s." % label) and await _rest("fence_gap")
	return _require(not crossed and gap < 1.0, "The stock player got through the %s or never reached it (%.2f m off)." % [label, gap]) and await _rest("fence_solid")


# --- 7. Through a shrub, stopped by a tree.

func _case_plants() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var recoveries_before := _recoveries.size()
	# The shrub: no collision, so no slowing as the car passes through it.
	var start := Vector2(_cases.shrub.start_xz[0], _cases.shrub.start_xz[1])
	var heading := Vector2(_cases.shrub.heading_xz[0], _cases.shrub.heading_xz[1]).normalized()
	var shrub := Vector2(_cases.shrub.at_xz[0], _cases.shrub.at_xz[1])
	if not await _drive_from(car, start, heading):
		return false
	var reach := (shrub - start).dot(heading)
	var speed_before := 0.0
	var speed_after := -1.0
	Input.action_press("move_forward")
	for _tick in 400:
		_steer_toward(car, start + heading * 200.0)
		await physics_frame
		var along := (Vector2(car.global_position.x, car.global_position.z) - start).dot(heading)
		if along < reach - 4.0:
			speed_before = car.linear_velocity.length()
		elif along > reach + 4.0:
			speed_after = car.linear_velocity.length()
			break
	_release_driving()
	print("SHRUB %.2f m/s before, %.2f m/s after" % [speed_before, speed_after])
	if not _require(speed_after >= 0.9 * speed_before and speed_before > 5.0, "The car did not drive straight through the shrub (%.2f -> %.2f m/s)." % [speed_before, speed_after]):
		return false
	# The palm: its trunk stops the car.
	start = Vector2(_cases.tree.start_xz[0], _cases.tree.start_xz[1])
	heading = Vector2(_cases.tree.heading_xz[0], _cases.tree.heading_xz[1]).normalized()
	var tree := Vector2(_cases.tree.at_xz[0], _cases.tree.at_xz[1])
	if not await _drive_from(car, start, heading):
		return false
	reach = (tree - start).dot(heading)
	var approach := 0.0
	var furthest := -INF
	var hit_tick := -1
	Input.action_press("move_forward")
	for tick in 420:
		_steer_toward(car, tree)
		await physics_frame
		var along := (Vector2(car.global_position.x, car.global_position.z) - start).dot(heading)
		furthest = maxf(furthest, along)
		if hit_tick < 0:
			approach = maxf(approach, car.linear_velocity.length())
			if along > reach - car.length_m and car.linear_velocity.length() < 0.5 * approach:
				hit_tick = tick
		elif tick >= hit_tick + 30:
			break
	_release_driving()
	var after := car.linear_velocity.length()
	print("TREE approached at %.2f m/s, %.2f m/s after the hit, front reached %.2f of %.2f m, up %.3f" % [approach, after, furthest + car.length_m * 0.5, reach, car.global_transform.basis.y.y])
	if not _require(hit_tick >= 0 and approach > 8.0, "The car never hit the palm (approach %.2f m/s)." % approach) \
	or not _require(furthest < reach and after < 0.3 * approach, "The palm's trunk did not stop the car.") \
	or not _require(_recoveries.size() == recoveries_before, "A recovery fired at the plants."):
		return false
	return await _stop_and_exit(car, "plants")


# --- 8. Shoving parked cars and a K-rail.

func _case_shove() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	# From a standstill: creep into a parked car under SHOVE_SPEED_MPS, then
	# full throttle; the parked car must give way (not wedge the driven car).
	var wedge_id := str(_cases.wedge.car)
	var wedge_entry: Dictionary = _vehicles.row(wedge_id)
	if not _require(not wedge_entry.is_empty() and _vehicles.live_node(wedge_id) == null, "Wedge target %s is not a static parked car." % wedge_id):
		return false
	var wedge_parked: Transform3D = wedge_entry.transform
	var wedge_heading := Vector2(_cases.wedge.heading_xz[0], _cases.wedge.heading_xz[1]).normalized()
	if not await _drive_from(car, Vector2(_cases.wedge.start_xz[0], _cases.wedge.start_xz[1]), wedge_heading):
		return false
	var creep_top := 0.0
	var contact_tick := -1
	var still := 0
	for tick in 600:
		var speed := car.linear_velocity.length()
		if speed < 0.7:
			Input.action_press("move_forward")
		elif speed > 0.9:
			Input.action_release("move_forward")
		await physics_frame
		creep_top = maxf(creep_top, car.linear_velocity.length())
		still = still + 1 if car.linear_velocity.length() < 0.2 and tick > 30 else 0
		if _vehicles.live_node(wedge_id) != null or still >= 20:
			contact_tick = tick
			break
	var pressed_from := car.global_position
	Input.action_press("move_forward")
	for _tick in 180:
		await physics_frame
	_release_driving()
	var wedge_node := _vehicles.live_node(wedge_id) as RigidBody3D
	var pushed := wedge_node.global_position.distance_to(wedge_parked.origin) if wedge_node != null else 0.0
	var pressed := car.global_position.distance_to(pressed_from)
	print("WEDGE crept in at up to %.2f m/s, %s live at tick %d; 3 s of full throttle moved the driven car %.2f m and the parked car %.2f m" % [creep_top, wedge_id, contact_tick, pressed, pushed])
	if not _require(creep_top < VEHICLE_MANAGER.SHOVE_SPEED_MPS and wedge_node != null, "Creeping into %s at %.2f m/s did not set it moving." % [wedge_id, creep_top]) \
	or not _require(pushed >= 0.5 and pressed >= 0.5, "Full throttle against %s wedged (driven car %.2f m, parked car %.2f m)." % [wedge_id, pressed, pushed]):
		return false
	# At speed: a parked car from the side, a K-rail end on.
	for target: Dictionary in [{"id": str(_cases.shove.car), "start": _cases.shove.start_xz, "heading": _cases.shove.heading_xz, "min_m": 0.5},
			{"id": str(_cases.krail.row), "start": _cases.krail.start_xz, "heading": _cases.krail.heading_xz, "min_m": 0.2}]:
		var entry: Dictionary = _vehicles.row(target.id)
		if not _require(not entry.is_empty() and _vehicles.live_node(target.id) == null, "Shove target %s is not a static swappable row." % target.id):
			return false
		var parked: Transform3D = entry.transform
		var start := Vector2(target.start[0], target.start[1])
		var heading := Vector2(target.heading[0], target.heading[1]).normalized()
		if not await _drive_from(car, start, heading):
			return false
		Input.action_press("move_forward")
		var hit := false
		var hit_speed := 0.0
		for _tick in 360:
			_steer_toward(car, Vector2(parked.origin.x, parked.origin.z))
			await physics_frame
			if _vehicles.live_node(target.id) != null:
				hit = true
				hit_speed = car.linear_velocity.length()
				break
		for _tick in 30:
			await physics_frame
		_release_driving()
		Input.action_press("move_back")
		for _tick in 90:
			await physics_frame
		Input.action_release("move_back")
		var moved_node := _vehicles.live_node(target.id) as RigidBody3D
		var frozen := false
		for _tick in 600:
			await physics_frame
			if moved_node != null and moved_node.freeze:
				frozen = true
				break
		var moved := moved_node.global_position.distance_to(parked.origin) if moved_node != null else 0.0
		print("SHOVE %s: set moving %s at %.2f m/s, moved %.2f m, at rest and frozen %s, car up %.3f" % [target.id, hit, hit_speed, moved, frozen, car.global_transform.basis.y.y])
		if not _require(hit and moved >= float(target.min_m) and frozen, "Hitting %s did not shove it and leave it at rest (moved %.2f m, frozen %s)." % [target.id, moved, frozen]):
			return false
	return await _stop_and_exit(car, "shove")


# --- 9. On foot after getting out.

func _case_on_foot() -> bool:
	if not _require(not _player.is_driving() and _player.is_processing_unhandled_input(), "The player must be on foot."):
		return false
	var rig := _player.get_node("CameraPivot") as Node3D
	rig.rotation.y = 0.0
	var top_walk := 0.0
	Input.action_press("move_forward")
	for _tick in 60:
		await physics_frame
		top_walk = maxf(top_walk, Vector2(_player.velocity.x, _player.velocity.z).length())
	Input.action_press("run")
	var top_run := 0.0
	for _tick in 60:
		await physics_frame
		top_run = maxf(top_run, Vector2(_player.velocity.x, _player.velocity.z).length())
	_release()
	Input.action_press("jetpack")
	var y0 := _player.global_position.y
	for _tick in 60:
		await physics_frame
	var risen := _player.global_position.y - y0
	Input.action_release("jetpack")
	Input.action_press("fast_drop")
	var drop := 0.0
	for _tick in 40:
		await physics_frame
		drop = maxf(drop, -_player.velocity.y)
		if _player.is_on_floor():
			break
	_release()
	print("ON_FOOT walk %.2f m/s, run %.2f m/s, jetpack rose %.2f m, fast drop %.2f m/s" % [top_walk, top_run, risen, drop])
	# Speeds as the stock controller gives them on this ground (move_and_slide
	# follows its slope); headless_gameplay_contract.gd pins the defaults.
	if not _require(top_walk > 3.5 and top_walk < 4.8 and top_run > 19.0 and risen > 3.0 and drop > 10.0, "On foot the stock walk, run, jetpack or fast drop changed."):
		return false
	return await _rest("on_foot")


# --- Helpers.

## The stock player standing still on the ground at xz, walking enabled.
func _stand_player(xz: Vector2) -> bool:
	_release()
	_player.set_gameplay_enabled(false)
	var hit := _ray(Vector3(xz.x, 200.0, xz.y), Vector3(xz.x, -50.0, xz.y), _player.collision_mask)
	if not _require(not hit.is_empty(), "No ground under %s." % xz):
		return false
	_player.global_transform = Transform3D(Basis.IDENTITY, (hit.position as Vector3) + Vector3.UP * 0.3)
	_player.velocity = Vector3.ZERO
	_player.set_gameplay_enabled(true)
	for _tick in 90:
		await physics_frame
		if _player.is_on_floor() and _player.velocity.length() < 0.05:
			return true
	return _require(false, "The player did not settle at %s." % xz)


## Puts the live car at xz on the ground facing heading, gets in, settles.
func _drive_from(car: DRIVABLE_CAR, xz: Vector2, heading: Vector2) -> bool:
	var error: String = _vehicles.drive_from(car.row_id, xz, heading)
	if not _require(error == "", "Could not start a drive at %s: %s." % [xz, error]):
		return false
	for _tick in 60:
		await physics_frame
	return _require(car.grounded_wheels() == 4 and car.linear_velocity.length() < 0.5, "The car did not settle on its wheels at %s (wheels %d, speed %.2f)." % [xz, car.grounded_wheels(), car.linear_velocity.length()])


## Steering keys toward a point (a crude driver: full lock past 6 degrees).
func _steer_toward(car: DRIVABLE_CAR, target: Vector2) -> void:
	var forward := -car.global_transform.basis.z
	var to := Vector3(target.x - car.global_position.x, 0.0, target.y - car.global_position.z)
	var angle := Vector2(forward.x, forward.z).angle_to(Vector2(to.x, to.z))
	Input.action_release("move_left")
	Input.action_release("move_right")
	if angle > deg_to_rad(4.0):
		Input.action_press("move_right")
	elif angle < deg_to_rad(-4.0):
		Input.action_press("move_left")


func _stop_and_exit(car: DRIVABLE_CAR, label: String) -> bool:
	_release_driving()
	Input.action_press("move_back")
	for _tick in 240:
		await physics_frame
		if car.linear_velocity.length() < 0.5:
			break
	Input.action_release("move_back")
	for _tick in 30:
		await physics_frame
	await _press("vehicle_enter_exit")
	if not _require(not _player.is_driving(), "F did not get out after %s." % label):
		return false
	return await _rest(label)


## The case's end: inputs released, the car (if any) stopped, the player standing.
func _rest(label: String) -> bool:
	_release()
	for _tick in 90:
		await physics_frame
		if _player.is_on_floor() and Vector2(_player.velocity.x, _player.velocity.z).length() < 0.05:
			print("REST %s player at %s on floor, driving %s" % [label, _player.global_position, _player.is_driving()])
			return true
	return _require(false, "No supported rest after %s (player at %s, on floor %s)." % [label, _player.global_position, _player.is_on_floor()])


func _press(action: String) -> void:
	Input.action_press(action)
	await physics_frame
	await physics_frame
	Input.action_release(action)
	await physics_frame


func _release_driving() -> void:
	for action: String in ["move_forward", "move_back", "move_left", "move_right", "handbrake"]:
		Input.action_release(action)


func _release() -> void:
	for action: String in VEHICLE_ACTIONS:
		Input.action_release(action)


func _parked_shape(entry: Dictionary) -> CollisionShape3D:
	var clutter := _world.street_detail_layer("clutter").get_node_or_null("GeneratedStreetClutter")
	if clutter == null or (entry.shapes as Array).is_empty():
		return null
	var ref: Array = entry.shapes[0]
	var body := clutter.get_node_or_null(str(ref[0]))
	return body.get_node_or_null(str(ref[1])) as CollisionShape3D if body != null else null


func _ray(from: Vector3, to: Vector3, mask: int) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, mask, [_player.get_rid()])
	query.hit_back_faces = false
	return _main.get_world_3d().direct_space_state.intersect_ray(query)


func _require(condition: bool, message: String) -> bool:
	if not condition and _failure == "":
		_failure = message
	return condition


func _on_timeout() -> void:
	if _failure == "":
		_failure = "The vehicle contract timed out."
	_finish()


func _finish() -> void:
	_release()
	if _failure != "":
		push_error("FAIL: " + _failure)
		print("FAIL: " + _failure)
		quit(1)
	else:
		quit(0)
