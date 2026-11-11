extends SceneTree
## Drivable cars (owner, 2026-11-08) in the real generated world, physics only
## (run with --headless and --fixed-fps 60). The places come from
## game/tests/shared/vehicle_cases.json. Cases, in order; the first failure
## stops the run (later cases need the earlier ones):
##   1. enter and exit with F: with the game paused F beside a parked car does
##      nothing; unpaused, the stock player presses F
##      and drives it (avatar hidden, capsule off, the parked box gone), the view
##      blending from the on-foot camera to the chase camera, which sees as far
##      (the distant horizon); F again stands the
##      player on the ground beside it, walking as before, the view blending
##      back; the car comes to rest, freezes and stays there; F gets back in;
##   2. a run along Seven Seas Avenue: up to speed, mostly on its wheels and
##      level, no recovery; then a handbrake turn that slides and stays upright;
##   3. the shore (Avenue N, where the verge falls to the riprap): driven off
##      it fast, and crept off it, the car goes over the crest and down the
##      rocks without stopping, never inside a stone, and splashes only where
##      its body reaches the water, over the corner that reached it; it sinks
##      until it is wholly under the surface, with the player kept in it (F
##      does nothing), then car and player are back on a level spot well clear
##      of the shore, facing away from the water, where it stays put on its
##      brakes until driven off; R from the slope by the rocks does the same;
##      on foot the riprap is as before: the cars' ground over it is on a layer
##      the player never meets, and walking out over the edge lifts the player
##      off it (recovery_controller.gd); a car left empty just past the edge
##      (handbrake then F, or F while it rolls) comes back to the island and
##      parks there; dropped on open water past the rocks the car splashes,
##      sinks under and comes back the same way; driven at the causeway's
##      crossing it is stopped by the cars' barrier there, inside the outline,
##      with no splash, while on foot the edge there lifts the player as before;
##   4. a roll: a car rolled over comes to rest on its roof or side; F gets
##      the player out of it there, it rights itself within a few seconds with
##      nobody in it, F gets back in and it drives on;
##   5. a ramp: driven straight at a dirt kicker at a sensible speed, the car
##      leaves the ground, flies and lands on its wheels, upright;
##   6. a fence: the car drives through a construction-panel joint, whose two
##      bays break and fall and whose stand goes down with them while the
##      stands either side, untouched, stay; it keeps most of its speed; on
##      foot an intact bay of the same fence still stops the stock player and
##      the broken gap lets it through; then a chain-link fence's bay with the
##      same key as a broken one (keys repeat from fence to fence) breaks too
##      and its gap opens on foot; then the turf pitch's windscreen: the car
##      breaks its bay and stops at the ball-stop net behind it, whose rows are
##      breakable: false;
##   7. plants: the car drives through a shrub without slowing and stops at a
##      palm's trunk;
##   8. shoves: a car creeping into a parked car and then pressing on at full
##      throttle pushes it, and again once it has frozen; a parked car hit from
##      the side at speed and a K-rail hit end on are set moving; each comes to
##      rest and freezes where it ends up, and a second hit from the same start
##      wakes it (the K-rail or the row units it lies among move again; the car
##      lies against a wall);
##   9. the pitch's ball: a car driven into it along the pitch sends it rolling
##      off ahead of the car (a bumper's push, not a ride over it); driven at it
##      in front of a goal, braking once it is away, the car pushes it in: a
##      goal, with confetti at that goal, and the ball back on its spot;
##  10. on foot after getting out: the stock controller back on, then the stock
##      walk, run, jetpack and fast drop on open street;
##  11. the browser's touch controls (touch_controls.gd, made as main.gd makes
##      them on a touch browser), driven by their own touch events: in a car the
##      use button shows GET OUT, RISE reads BRAKE with the handbrake glyph, RUN
##      and the look hint are hidden, the touch stick drives and its corner
##      steers at full throttle, RISE holds the handbrake, and a tap gets out,
##      which brings RISE, RUN and the hint back; beside the car it shows DRIVE
##      and a tap gets back in, letting go of a run held as it does; on the
##      ground away from cars it hides; in the air it shows DROP, held it holds
##      the fast drop, lifted it lets go, and held through the landing it lets go
##      of C and hides on the ground with the finger still down;
##  12. the riprap round the whole island: wherever it is drawn 1.5 m and 3 m off
##      the outline, a car finds something to land on (_case_riprap_cover).
## Every case ends with the car stopped and the player standing, inputs released,
## and the chest avatar shown with both feet beside the player (as before the
## first F): getting out must never leave the player without a character.

const CASES_PATH := "res://game/tests/shared/vehicle_cases.json"
const DRIVABLE_CAR := preload("res://game/scripts/vehicles/drivable_car.gd")
const VEHICLE_MANAGER := preload("res://game/scripts/vehicles/vehicle_manager.gd")
const BREAKER := preload("res://game/scripts/vehicles/street_fence_breaker.gd")
const TOUCH_CONTROLS := preload("res://game/scripts/ui/touch_controls.gd")
const VEHICLE_ACTIONS := ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack", "fast_drop", "vehicle_enter_exit", "handbrake", "recover"]
## A sinking car over the riprap may go this far under the cars' ground (the
## stones' tops) at its worst corner before it counts as inside the stones.
const STONES_DEPTH_M := 0.3
## The riprap sweep: round the outline every COVER_STEP_M, at each of COVER_OUT_M
## out from it, and the plan cells (m) its drawn surfaces are found through.
const COVER_STEP_M := 0.5
const COVER_OUT_M := [1.5, 3.0]
const COVER_CELL_M := 2.0
## On foot the avatar's feet stand within this of the player (m).
const AVATAR_REACH_M := 2.0

var _failure := ""
var _main: GameMain
var _world: WorldLoader
var _player: PlayerController
var _vehicles: VEHICLE_MANAGER
var _cases: Dictionary
var _recoveries: Array[Dictionary] = []
## The expanded generated shoreline (_shoreline), read once.
var _shoreline_document: Dictionary


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
	for case: Callable in [_case_enter_exit, _case_route, _case_shore, _case_empty_off_shore, _case_bay, _case_causeway, _case_roll, _case_ramp, _case_fence, _case_fence_shared, _case_field_net, _case_plants, _case_shove, _case_ball, _case_on_foot, _case_touch, _case_riprap_cover]:
		if not await case.call():
			return _finish()
	print("PASS: drivable cars: F in and out beside a parked car that stays where it was left, the view blending each way and seeing as far as on foot, a run on Seven Seas Avenue on its wheels, a handbrake slide, off the shore fast and slow over the crest and down the rocks with no stop and no stone inside the car, a splash only where it met the water and a sink under the surface clear of the stones, and R from the slope by them, each back on a level spot clear of the shore facing inland and staying put, the riprap as before on foot, an empty car left past the edge back on the island and parked, a splash, a sink and back on land from open water, a car stopped at the causeway's barrier with no splash while the edge there still lifts the player, a roll onto its roof or side, F out of it there, the car righting itself and F back in, a clean jump off a ramp, a fence joint broken with its stand felled and its untouched neighbours standing while intact bays still stop the player, a second fence's bay of the same key broken and open on foot, a turf windscreen bay broken and the car stopped by the ball-stop net behind it, through a shrub and stopped by a palm, a parked car pushed from a standstill and one and a K-rail shoved at speed, each pushed or shoved again once it had frozen, the pitch's ball sent rolling and pushed into a goal, with confetti there and the ball back on its spot, and the stock walk, run, jetpack and fast drop after getting out, the avatar standing with the player on foot after every exit; on touch, GET OUT in a car where the stick drives and steers and RISE is the handbrake, taps out and back in by DRIVE, the button hidden away from cars, and DROP in the air holding the fast drop until the finger lifts or the player lands; in a car RISE shows the handbrake glyph and RUN and the look hint hide, with no run left held, until the player gets out; and round the whole outline, wherever riprap is drawn 1.5 m and 3 m out, a car has something to land on there")
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
	if not await _stand_player(Vector2(door.x, door.z)) or not await _avatar_with_player("before getting in"):
		return false
	var shape := _parked_shape(entry)
	if not _require(shape != null and not shape.disabled, "The parked car %s has no enabled collision box." % id):
		return false
	# Paused, F does nothing (the vehicles pause with the game).
	paused = true
	await _press("vehicle_enter_exit")
	var paused_in := _player.is_driving()
	paused = false
	for _tick in 2:
		await physics_frame
	if not _require(not paused_in and _vehicles.live_node(id) == null, "F in the pause menu got the player into %s." % id):
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
	# The chase camera and its blend see as far as the on-foot camera: the distant horizon stays.
	var on_foot := _player.get_camera()
	if not _require(rig.camera.far == on_foot.far and showing.far == on_foot.far and rig.camera.near == on_foot.near and showing.near == on_foot.near, "The chase camera and its blend must see as far as the on-foot camera (far %.0f and %.0f m against %.0f m)." % [rig.camera.far, showing.far, on_foot.far]):
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


# --- 3. The shore: off it fast and slow, R by the rocks, on foot, and open water.

func _case_shore() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var shore: Dictionary = _cases.shore
	var start := Vector2(shore.start_xz[0], shore.start_xz[1])
	var heading := Vector2(shore.heading_xz[0], shore.heading_xz[1]).normalized()
	var outward := Vector3(heading.x, 0.0, heading.y)
	var stones := _stones_near(start + heading * 14.0, 30.0)
	if not _require(stones.size() >= 20, "Found only %d of the shore's stones by the Avenue N fixture." % stones.size()):
		return false
	# Driven off the shore, then crept off it (the strip falls to the rocks): each
	# time over the crest and down the rocks into the water, then back on land.
	for run: Array in [["fast", 40.0], ["slow", float(shore.creep_mps)]]:
		if not await _drive_from(car, start, heading) or not await _off_the_shore(car, start + heading * 200.0, float(run[1]), stones, str(run[0])) \
		or not await _back_on_land(car, outward, "the water " + str(run[0])):
			return false
	# R on the slope by the rocks: crept down it and stopped short of them.
	if not await _drive_from(car, start, heading):
		return false
	var boundary := _world.get_boundary()
	Input.action_press("move_forward")
	for _tick in 900:
		_steer_toward(car, start + heading * 200.0)
		if car.linear_velocity.length() > float(shore.creep_mps):
			Input.action_release("move_forward")
		else:
			Input.action_press("move_forward")
		await physics_frame
		if boundary.edge_distance(car.global_position) < float(shore.r_edge_m):
			break
	_release_driving()
	Input.action_press("move_back")
	for _tick in 120:
		await physics_frame
		if car.linear_velocity.length() < 0.3:
			break
	Input.action_release("move_back")
	var on_slope := car.global_position
	var before := _recoveries.size()
	print("SHORE R from %s, %.2f m from the edge, up %.4f" % [on_slope, boundary.edge_distance(on_slope), car.global_transform.basis.y.y])
	if not _require(boundary.contains_position(on_slope) and not car.is_sinking(), "The car crept onto the rocks before R (%s)." % on_slope):
		return false
	await _press("recover")
	for _tick in 5:
		await physics_frame
	if not _require(_recoveries.size() > before and _recoveries[_recoveries.size() - 1].cause == "manual", "R on the slope by the rocks did not put the car back."):
		return false
	if not await _back_on_land(car, outward, "R by the rocks"):
		return false
	return await _stop_and_exit(car, "shore") and await _shore_on_foot(start, heading)


## Drives (or creeps, at max_mps) toward target off the shore: over the crest
## and down the rocks without stopping (never under 0.5 m/s once its middle is
## off the outline), no stone of them inside its hulls on the way, its wheels on
## the cars' ground over them; then one splash, on the water, where the test saw
## the car's body first reach the water (its own reading of the car's box, a tick
## at most after the car's); then it rolls on off the stones' tops and sinks
## until it is wholly under the surface, never further than STONES_DEPTH_M under
## the cars' ground while over it, no stone above the water inside it, with the
## player kept in it (F doing nothing), and goes back to land ("water", not
## stranded) within DRIVABLE_CAR.SINK_MAX_S.
func _off_the_shore(car: DRIVABLE_CAR, target: Vector2, max_mps: float, stones: Array[AABB], label: String) -> bool:
	var before := _recoveries.size()
	var boundary := _world.get_boundary()
	var ground := _world.find_child("CarGround", true, false) as StaticBody3D
	var seen := {"count": 0}
	var on_splash := func(at: Vector3, speed: float) -> void:
		if not seen.has("at"):
			seen["at"] = at
			seen["speed"] = speed
		seen["count"] = int(seen.count) + 1
		seen["splashes"] = _vehicles.find_children("Splash*", "", false, false).size()
	car.splashed.connect(on_splash)
	var through := 0
	var off_tick := -1
	var slowest := INF
	var on_ground := 0
	var wet := Vector3.INF
	var sink_ticks := 0
	var deepest_top := INF
	var into_rocks := 0.0
	var tried_exit := false
	var stayed_in := true
	var top := 0.0
	for tick in 1500:
		if not car.is_sinking():
			_steer_toward(car, target)
			if car.linear_velocity.length() > max_mps:
				Input.action_release("move_forward")
			else:
				Input.action_press("move_forward")
		await physics_frame
		top = maxf(top, car.linear_velocity.length())
		if tick % 30 == 0 and not car.is_sinking():
			print("SHORE %s t=%.1f s at %s, %.2f m from the edge (%s), %s" % [label, tick / 60.0, car.global_position, boundary.edge_distance(car.global_position), "in" if boundary.contains_position(car.global_position) else "out", JSON.stringify(car.describe())])
		var bottom := _bottom_point(car)
		if not wet.is_finite() and bottom.y < car.water_y and not boundary.contains_position(bottom):
			wet = bottom
		if _top_y(car) >= car.water_y:
			var inside := _stones_in_car(car, stones, car.water_y)
			if inside > through:
				print("SHORE %s stone cores inside the car: %d at %s, %.2f m from the edge (%s), sinking %s, %s" % [label, inside, car.global_position, boundary.edge_distance(car.global_position), "in" if boundary.contains_position(car.global_position) else "out", car.is_sinking(), JSON.stringify(car.describe())])
			through = maxi(through, inside)
		if car.is_sinking():
			sink_ticks += 1
			deepest_top = minf(deepest_top, _top_y(car))
			into_rocks = maxf(into_rocks, _under_car_ground(car))
			if sink_ticks == 20 and not tried_exit:
				tried_exit = true
				_release_driving()
				await _press("vehicle_enter_exit")
				stayed_in = _player.is_driving() and _vehicles.active_car() == car
		elif not boundary.contains_position(car.global_position):
			if off_tick < 0:
				off_tick = tick
			slowest = minf(slowest, car.linear_velocity.length())
			# The cars' ground under it.
			var hit := _ray(car.global_position + Vector3.UP * 1.0, car.global_position + Vector3.DOWN * 2.0, DRIVABLE_CAR.PHYSICS_CAR_GROUND)
			if ground != null and hit.get("collider") == ground:
				on_ground += 1
		if _recoveries.size() > before:
			break
	_release_driving()
	car.splashed.disconnect(on_splash)
	var event: Dictionary = _recoveries[_recoveries.size() - 1] if _recoveries.size() > before else {}
	var splash_at: Vector3 = seen.get("at", Vector3.INF)
	var off_splash := Vector2(splash_at.x - wet.x, splash_at.z - wet.z).length() if splash_at.is_finite() and wet.is_finite() else INF
	print("SHORE %s: up to %.2f m/s, off the outline at tick %d, slowest %.2f m/s there, %d ticks over the cars' ground, stone cores inside the car at worst %d; %d splash(es), the first %s at %.2f m/s (%d splash nodes), %.2f m from where the test saw the body first reach the water (%s); sank %.2f s, its top %.2f m under the surface at the deepest, at worst %.2f m under the cars' ground while over it; F there kept the player in: %s; back on land by %s from %s" % [label, top, off_tick, slowest, on_ground, through, int(seen.count), splash_at, seen.get("speed", 0.0), seen.get("splashes", 0), off_splash, wet, sink_ticks / 60.0, car.water_y - deepest_top, into_rocks, stayed_in, event.get("cause"), event.get("from")])
	return _require(ground != null, "No cars' ground over the riprap.") \
		and _require(not event.is_empty() and event.cause == "water", "Driven %s off the shore the car did not go back to land from the water (%s)." % [label, event]) \
		and _require(off_tick >= 0 and slowest > 0.5, "Off the shore (%s) the car must roll on down the rocks, not stop at the crest (slowest %.2f m/s)." % [label, slowest]) \
		and _require(through == 0, "Off the shore (%s) %d stone cores stood inside the car." % [label, through]) \
		and _require(int(seen.count) == 1 and int(seen.get("splashes", 0)) >= 1 and absf(splash_at.y - car.water_y) < 0.01 and not boundary.contains_position(splash_at), "Off the shore (%s) the car must splash once, on the water off the island (%s)." % [label, seen]) \
		and _require(wet.is_finite() and off_splash < 1.0, "Off the shore (%s) the splash must be where the car's body first reached the water (the test saw it at %s, %.2f m from the splash)." % [label, wet, off_splash]) \
		and _require(sink_ticks >= int((DRIVABLE_CAR.SINK_MIN_S - 0.1) * 60.0) and sink_ticks <= int((DRIVABLE_CAR.SINK_MAX_S + 0.1) * 60.0) and deepest_top < car.water_y, "Off the shore (%s) the car must sink under the surface before it goes back (%.2f s, its top %.2f m under)." % [label, sink_ticks / 60.0, car.water_y - deepest_top]) \
		and _require(into_rocks <= STONES_DEPTH_M, "Off the shore (%s) the sinking car went %.2f m under the cars' ground, into the stones." % [label, into_rocks]) \
		and _require(tried_exit and stayed_in, "F while the car sinks must keep the player in it.")


## The lowest corner of the car's box (wheels to roof) now, read here from its
## transform and size, not from the car's own reading.
func _bottom_point(car: DRIVABLE_CAR) -> Vector3:
	var xf := car.global_transform
	var lowest := Vector3.INF
	for corner in 8:
		var local := Vector3((corner & 1) * 2 - 1, 0.0, ((corner >> 1) & 1) * 2 - 1) * Vector3(car.width_m * 0.45, 0.0, car.length_m * 0.45)
		local.y = car.height_m if corner >= 4 else 0.05
		var at := xf * local
		if at.y < lowest.y:
			lowest = at
	return lowest


## How far the car's bottom stands under the cars' ground at its worst corner
## now (0 where it is over none of it or above it).
func _under_car_ground(car: DRIVABLE_CAR) -> float:
	var xf := car.global_transform
	var worst := 0.0
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		var at := xf * Vector3(corner.x * car.width_m * 0.45, 0.05, corner.y * car.length_m * 0.45)
		var hit := _ray(Vector3(at.x, at.y + 6.0, at.z), Vector3(at.x, at.y - 6.0, at.z), DRIVABLE_CAR.PHYSICS_CAR_GROUND)
		if not hit.is_empty():
			worst = maxf(worst, (hit.position as Vector3).y - at.y)
	return worst


## The top of the car's box (wheels to roof) at its highest corner now.
func _top_y(car: DRIVABLE_CAR) -> float:
	var xf := car.global_transform
	var top := -INF
	for corner in 8:
		var local := Vector3((corner & 1) * 2 - 1, 0.0, ((corner >> 1) & 1) * 2 - 1) * Vector3(car.width_m * 0.45, 0.0, car.length_m * 0.45)
		local.y = car.height_m if corner >= 4 else 0.05
		top = maxf(top, (xf * local).y)
	return top


## On foot the riprap is as it was: the cars' ground over it is on its own layer,
## which a car's mask has and the player's (and the on-foot camera's) hasn't, so
## a ray over the rocks finds it for a car and not for the player; and the stock
## player walking out from the verge over the edge is lifted off it there
## (recovery_controller.gd "outside_boundary") without ever touching it.
func _shore_on_foot(start: Vector2, heading: Vector2) -> bool:
	var ground := _world.find_child("CarGround", true, false) as StaticBody3D
	var boundary := _world.get_boundary()
	var edge := boundary.edge_distance(Vector3(start.x, 0.0, start.y))
	var over := start + heading * (edge + 3.0)
	var for_car := _ray(Vector3(over.x, 20.0, over.y), Vector3(over.x, -5.0, over.y), DRIVABLE_CAR.GROUND_MASK)
	var for_player := _ray(Vector3(over.x, 20.0, over.y), Vector3(over.x, -5.0, over.y), _player.collision_mask)
	var arm := (_player.get_node("CameraPivot") as Node3D).get_node("SpringArm3D") as SpringArm3D
	if not _require(ground != null and ground.collision_layer == DRIVABLE_CAR.PHYSICS_CAR_GROUND and ground.collision_mask == 0, "The cars' ground must stand on its own layer alone.") \
	or not _require(_player.collision_mask & DRIVABLE_CAR.PHYSICS_CAR_GROUND == 0 and arm.collision_mask & DRIVABLE_CAR.PHYSICS_CAR_GROUND == 0, "The player and the on-foot camera must not meet the cars' ground.") \
	or not _require(for_car.get("collider") == ground and for_player.is_empty(), "Over the rocks a car must find the cars' ground and the player nothing (%s, %s)." % [for_car.get("collider"), for_player.get("collider")]):
		return false
	return await _walk_off_edge(start, heading, ground, "the shore")


## The stock player walking out along heading from 4 m before where that line
## crosses the edge: lifted off it there (recovery_controller.gd
## "outside_boundary") without ever touching body (a car-only one); then stood
## back at start.
func _walk_off_edge(start: Vector2, heading: Vector2, body: StaticBody3D, label: String) -> bool:
	var boundary := _world.get_boundary()
	var edge := 0.0
	while edge < 80.0 and boundary.contains_position(Vector3(start.x + heading.x * edge, 0.0, start.y + heading.y * edge)):
		edge += 0.1
	if not await _stand_player(start + heading * (edge - 4.0)):
		return false
	var lifts: Array[Dictionary] = []
	var on_lift := func(cause: String, from: Vector3) -> void:
		lifts.append({"cause": cause, "from": from})
	_player.recovered.connect(on_lift)
	var rig := _player.get_node("CameraPivot") as Node3D
	rig.rotation.y = atan2(-heading.x, -heading.y)
	var touched := 0
	Input.action_press("move_forward")
	for _tick in 120:
		await physics_frame
		for index in _player.get_slide_collision_count():
			if _player.get_slide_collision(index).get_collider() == body:
				touched += 1
		if not lifts.is_empty():
			break
	_release()
	_player.recovered.disconnect(on_lift)
	var lift: Dictionary = lifts[0] if not lifts.is_empty() else {}
	var from: Vector3 = lift.get("from", Vector3.INF)
	print("ON FOOT at %s: %d lift(s), the first %s from %s, %.2f m off the edge; %s touched %d times; the player ended at %s" % [label, lifts.size(), lift.get("cause"), from, boundary.edge_distance(from) if from.is_finite() else INF, body.name, touched, _player.global_position])
	if not _require(not lift.is_empty() and lift.cause == "outside_boundary" and from.is_finite() and boundary.edge_distance(from) < 1.0, "Walking out over the edge at %s must lift the player off it as before (%s)." % [label, lifts]) \
	or not _require(touched == 0, "On foot at %s the player touched %s %d times." % [label, body.name, touched]):
		return false
	return await _stand_player(start) and await _rest("on foot at " + label)


## A car left empty just past the edge (handbrake then F; F while it still
## rolls) never parks out there: it parks on the island, rolled back onto it by
## itself or put back by the stranded rule (or the water, had it rolled on in),
## then on a spot well clear of the shore.
func _case_empty_off_shore() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var shore: Dictionary = _cases.shore
	var start := Vector2(shore.start_xz[0], shore.start_xz[1])
	var heading := Vector2(shore.heading_xz[0], shore.heading_xz[1]).normalized()
	var boundary := _world.get_boundary()
	for rolling: bool in [false, true]:
		var label := "F while it rolls" if rolling else "handbrake, then F"
		if not await _drive_from(car, start, heading):
			return false
		Input.action_press("move_forward")
		for _tick in 900:
			_steer_toward(car, start + heading * 200.0)
			if car.linear_velocity.length() > float(shore.creep_mps):
				Input.action_release("move_forward")
			else:
				Input.action_press("move_forward")
			await physics_frame
			if not boundary.contains_position(car.global_position) and boundary.edge_distance(car.global_position) > 0.3:
				break
		_release_driving()
		if not rolling:
			Input.action_press("handbrake")
			for _tick in 90:
				await physics_frame
				if car.linear_velocity.length() < 0.1:
					break
			Input.action_release("handbrake")
		var left_at := car.global_position
		var left_speed := car.linear_velocity.length()
		var before := _recoveries.size()
		await _press("vehicle_enter_exit")
		var out := not _player.is_driving()
		var frozen_outside := false
		for _tick in 420:
			await physics_frame
			if car.freeze and not boundary.contains_position(car.global_position):
				frozen_outside = true
			if _recoveries.size() > before:
				break
		var event: Dictionary = _recoveries[_recoveries.size() - 1] if _recoveries.size() > before else {}
		for _tick in 240:
			await physics_frame
			if car.freeze:
				break
		var put_back := not event.is_empty()
		print("EMPTY %s: left %.2f m past the edge at %s at %.2f m/s, out %s; frozen off the island %s; put back by %s; parked %s at %s, %.2f m from the edge (%s)" % [label, boundary.edge_distance(left_at), left_at, left_speed, out, frozen_outside, event.get("cause"), car.freeze, car.global_position, boundary.edge_distance(car.global_position), "in" if boundary.contains_position(car.global_position) else "out"])
		if not _require(out and not boundary.contains_position(left_at), "The empty-car case (%s) must leave the car past the edge (out %s at %s)." % [label, out, left_at]) \
		or not _require(not frozen_outside and (not put_back or str(event.cause) in ["outside_boundary", "water"]), "A car left empty past the edge (%s) must not park there (frozen outside %s, put back %s)." % [label, frozen_outside, event]) \
		or not _require(car.freeze and boundary.contains_position(car.global_position) and (not put_back or boundary.edge_distance(car.global_position) >= DRIVABLE_CAR.SAFE_SHORE_M - 0.5), "Left empty past the edge (%s) the car must end parked on the island (frozen %s at %s, put back %s)." % [label, car.freeze, car.global_position, put_back]):
			return false
	return await _stand_player(start) and await _rest("empty_off_shore")


## The causeway: driven at the outline where it crosses the road to Yerba Buena,
## the car is stopped by the cars' barrier there, its middle never past the
## outline, with no splash and no return; on foot the player is lifted off the
## edge there as before, never touching the barrier.
func _case_causeway() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var fixture: Dictionary = _cases.causeway
	var start := Vector2(fixture.start_xz[0], fixture.start_xz[1])
	var heading := Vector2(fixture.heading_xz[0], fixture.heading_xz[1]).normalized()
	var boundary := _world.get_boundary()
	var barrier := _world.find_child("CarBarrier", true, false) as StaticBody3D
	if not _require(barrier != null and barrier.collision_layer == DRIVABLE_CAR.PHYSICS_CAR_GROUND and barrier.collision_mask == 0, "No car-only barrier at the causeway.") \
	or not await _drive_from(car, start, heading):
		return false
	var before := _recoveries.size()
	var splashes := [0]
	var on_splash := func(_at: Vector3, _speed: float) -> void:
		splashes[0] += 1
	car.splashed.connect(on_splash)
	var top := 0.0
	var farthest_out := 0.0
	var nearest_in := INF
	var stopped := false
	Input.action_press("move_forward")
	for _tick in 600:
		_steer_toward(car, start + heading * 200.0)
		if car.linear_velocity.length() > float(fixture.max_mps):
			Input.action_release("move_forward")
		else:
			Input.action_press("move_forward")
		await physics_frame
		var speed := car.linear_velocity.length()
		top = maxf(top, speed)
		if not boundary.contains_position(car.global_position):
			farthest_out = maxf(farthest_out, boundary.edge_distance(car.global_position))
		else:
			nearest_in = minf(nearest_in, boundary.edge_distance(car.global_position))
		if top > 5.0 and speed < 0.3:
			stopped = true
			break
	_release_driving()
	for _tick in 60:
		await physics_frame
	car.splashed.disconnect(on_splash)
	var rest := car.global_position
	print("CAUSEWAY driven at the crossing at up to %.2f m/s: its middle came to %.2f m of the edge and at most %.2f m past it; stopped %s, at rest at %s, %.2f m %s the edge; %d splash(es), %d return(s), up %.3f" % [top, nearest_in, farthest_out, stopped, rest, boundary.edge_distance(rest), "inside" if boundary.contains_position(rest) else "past", splashes[0], _recoveries.size() - before, car.up_dot()])
	if not _require(top > 5.0 and stopped, "Driven at the causeway the car must reach speed and be stopped there (top %.2f m/s)." % top) \
	or not _require(boundary.contains_position(rest) and farthest_out == 0.0, "The barrier must stop the car before its middle passes the outline (%.2f m past at most)." % farthest_out) \
	or not _require(nearest_in <= car.length_m * 0.5 + 0.6, "The car must reach the barrier on the outline, not stop short of it (its middle came to %.2f m of the edge)." % nearest_in) \
	or not _require(splashes[0] == 0 and _recoveries.size() == before and not car.is_sinking(), "At the causeway the car must not splash or go back (%d splashes, %d returns)." % [splashes[0], _recoveries.size() - before]) \
	or not await _stop_and_exit(car, "causeway"):
		return false
	# On foot 2 m to the side of the car's lane, clear of the car left at the
	# barrier (and on the side away from the closure's barricades).
	return await _walk_off_edge(start + Vector2(heading.y, -heading.x) * 2.0, heading, barrier, "the causeway")


## Back on land after a return: on a level spot inside the outline, well clear
## of its edge, on four wheels, facing away from the water (outward), the
## player in it; still there (across the ground, once its springs have
## settled), on its brakes, after the fixture's still_s with nothing pressed;
## then W drives it off, inland.
func _back_on_land(car: DRIVABLE_CAR, outward: Vector3, label: String) -> bool:
	for _tick in 90:
		await physics_frame
	var boundary := _world.get_boundary()
	var rest := car.global_position
	var edge := boundary.edge_distance(rest)
	var forward := -car.global_transform.basis.z
	forward = Vector3(forward.x, 0.0, forward.z).normalized()
	var up := car.global_transform.basis.y.y
	var wheels := car.grounded_wheels()
	var holding := car.is_holding()
	for _tick in int(float(_cases.shore.still_s) * 60.0):
		await physics_frame
	var drift := Vector2(car.global_position.x - rest.x, car.global_position.z - rest.z).length()
	Input.action_press("move_forward")
	for _tick in 60:
		await physics_frame
	Input.action_release("move_forward")
	var gone := car.global_position - rest
	gone.y = 0.0
	print("BACK %s at %s, %.2f m from the edge, up %.4f, wheels %d, held %s, facing %.2f along the way out, drifted %.3f m in %.1f s, then W took it %.2f m (%.2f along the way out)" % [label, rest, edge, up, wheels, holding, forward.dot(outward), drift, float(_cases.shore.still_s), gone.length(), gone.normalized().dot(outward)])
	return _require(boundary.contains_position(rest) and edge >= DRIVABLE_CAR.SAFE_SHORE_M - 0.5, "Back from %s the car is %.2f m from the island's edge." % [label, edge]) \
		and _require(up >= cos(deg_to_rad(DRIVABLE_CAR.SAFE_TILT_DEG + 1.0)) and wheels == 4 and holding, "Back from %s the car must stand level on its four wheels, on its brakes (up %.4f, wheels %d, held %s)." % [label, up, wheels, holding]) \
		and _require(forward.dot(outward) < 0.3, "Back from %s the car must face away from the water." % label) \
		and _require(_player.is_driving() and _vehicles.active_car() == car, "Back from %s the player must be in the car." % label) \
		and _require(drift < 0.01, "Back from %s the car moved %.3f m with nothing pressed." % [label, drift]) \
		and _require(gone.length() > 1.0 and gone.dot(outward) < 0.0, "Back from %s, W must drive it off inland (%.2f m)." % [label, gone.length()])


## Dropped on open water past the rocks (off the west shore, after a short
## drive there for a spot to come back to): a splash on the water, a sink with
## the player kept in it (F does nothing), then back on land.
func _case_bay() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var bay: Dictionary = _cases.bay
	var start := Vector2(bay.start_xz[0], bay.start_xz[1])
	var heading := Vector2(bay.heading_xz[0], bay.heading_xz[1]).normalized()
	if not await _drive_from(car, start, heading):
		return false
	for _tick in int(float(bay.drive_s) * 60.0):
		_steer_toward(car, start + heading * 200.0)
		if car.linear_velocity.length() > 8.0:
			Input.action_release("move_forward")
		else:
			Input.action_press("move_forward")
		await physics_frame
	_release_driving()
	var boundary := _world.get_boundary()
	var drop := Vector3(bay.drop_xyz[0], bay.drop_xyz[1], bay.drop_xyz[2])
	if not _require(not boundary.contains_position(drop) and boundary.edge_distance(drop) > 25.0, "The bay fixture's drop %s is not on open water." % drop):
		return false
	var before := _recoveries.size()
	var seen := {}
	var on_splash := func(at: Vector3, speed: float) -> void:
		seen["at"] = at
		seen["speed"] = speed
		seen["lowest"] = car.lowest_y(car.global_transform)
		seen["splashes"] = _vehicles.find_children("Splash*", "", false, false).size()
	car.splashed.connect(on_splash)
	car.place(Transform3D(car.global_transform.basis, drop))
	var sinking_ticks := 0
	var deepest_top := INF
	var tried_exit := false
	var stayed_in := true
	for _tick in 600:
		await physics_frame
		if car.is_sinking():
			sinking_ticks += 1
			deepest_top = minf(deepest_top, _top_y(car))
			if sinking_ticks == 30 and not tried_exit:
				tried_exit = true
				await _press("vehicle_enter_exit")
				stayed_in = _player.is_driving() and _vehicles.active_car() == car
		if _recoveries.size() > before:
			break
	car.splashed.disconnect(on_splash)
	var event: Dictionary = _recoveries[_recoveries.size() - 1] if _recoveries.size() > before else {}
	print("BAY splash %s at %.2f m/s, lowest corner %.2f m (water %.2f), %d splash nodes; sank %.2f s, its top %.2f m under the surface at the deepest; F while sinking kept the player in: %s; back by %s" % [seen.get("at"), seen.get("speed", 0.0), seen.get("lowest", INF), car.water_y, seen.get("splashes", 0), sinking_ticks / 60.0, car.water_y - deepest_top, stayed_in, event.get("cause")])
	if not _require(seen.has("at") and absf((seen.at as Vector3).y - car.water_y) < 0.05 and float(seen.lowest) <= car.water_y + 0.02 and int(seen.splashes) >= 1, "Dropped on open water the car must splash on it (%s)." % [seen]) \
	or not _require(not event.is_empty() and event.cause == "water" and sinking_ticks >= int((DRIVABLE_CAR.SINK_MIN_S - 0.1) * 60.0) and sinking_ticks <= int((DRIVABLE_CAR.SINK_MAX_S + 0.1) * 60.0) and deepest_top < car.water_y, "The car must sink under the surface before it goes back (%s after %.2f s, its top %.2f m under)." % [event, sinking_ticks / 60.0, car.water_y - deepest_top]) \
	or not _require(tried_exit and stayed_in, "F while the car sinks must keep the player in it.") \
	or not await _back_on_land(car, Vector3(heading.x, 0.0, heading.y), "the bay"):
		return false
	return await _stop_and_exit(car, "bay")


## The shore's stones (the riprap's top row and heap, drawn only) within radius
## of a point, as boxes in the world: the generated shoreline's placements of
## its prototypes, as shoreline_builder.gd draws them.
func _stones_near(center: Vector2, radius: float) -> Array[AABB]:
	var stones: Array[AABB] = []
	var document := _shoreline()
	if document.is_empty():
		return stones
	var boxes := {}
	for prototype: Dictionary in document.prototypes:
		var flat: Array = prototype.vertices
		var box := AABB(Vector3(float(flat[0]), float(flat[1]), float(flat[2])), Vector3.ZERO)
		for index in range(3, flat.size(), 3):
			box = box.expand(Vector3(float(flat[index]), float(flat[index + 1]), float(flat[index + 2])))
		boxes[str(prototype.id)] = box
	for batch: Dictionary in document.batches:
		if not str(batch.band) in ["top", "heap"] or Vector2(float(batch.origin[0]), float(batch.origin[2])).distance_to(center) > radius + 160.0:
			continue
		var transforms: PackedFloat32Array = batch.transforms
		for at in range(0, transforms.size(), GeneratedWorldContract.SHORELINE_PLACEMENT_LENGTH):
			var position := Vector3(transforms[at], transforms[at + 1], transforms[at + 2])
			if Vector2(position.x, position.z).distance_to(center) > radius:
				continue
			var rotation := Quaternion(transforms[at + 3], transforms[at + 4], transforms[at + 5], transforms[at + 6]).normalized()
			var basis := Basis(rotation) * Basis.from_scale(Vector3(transforms[at + 7], transforms[at + 8], transforms[at + 9]))
			stones.append(Transform3D(basis, position) * (boxes[str(batch.prototype)] as AABB))
	return stones


## The generated shoreline, expanded (empty if it can't be read).
func _shoreline() -> Dictionary:
	if _shoreline_document.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/shoreline.json"))
		var expanded: Dictionary = GeneratedWorldContract._expand_shoreline(parsed) if parsed is Dictionary else {}
		if bool(expanded.get("ok", false)):
			_shoreline_document = expanded.data
	return _shoreline_document


## No hole in the cars' ground for a car driven off the island to drop through
## the drawn stones: round the whole playable outline every COVER_STEP_M, at each
## of COVER_OUT_M out (where that is off the island), wherever the shoreline
## draws riprap a car can reach (the slope, a shoulder, or a shouldered section's
## rock face lying no steeper than a slope, such as a narrow inlet's fill), a ray
## with a car's own mask finds something to land on above the water.
func _case_riprap_cover() -> bool:
	var document := _shoreline()
	if not _require(not document.is_empty(), "Could not read the generated shoreline."):
		return false
	var shouldered := {}
	for record: Dictionary in document.records:
		if str(record.material_key) == ShorelineBuilder.VERGE_MATERIAL:
			shouldered[ShorelineBuilder._section_key(record)] = true
	# The drawn surfaces' triangles in plan, by COVER_CELL_M cell.
	var cells := {}
	for record: Dictionary in document.records:
		var key := str(record.material_key)
		var face := key == ShorelineBuilder.FACE_MATERIAL and shouldered.has(ShorelineBuilder._section_key(record))
		if key != ShorelineBuilder.SLOPE_MATERIAL and key != ShorelineBuilder.VERGE_MATERIAL and not face:
			continue
		var vertices: PackedVector3Array = record.vertices
		var indices: PackedInt32Array = record.indices
		for at in range(0, indices.size(), 3):
			var a := vertices[indices[at]]
			var b := vertices[indices[at + 1]]
			var c := vertices[indices[at + 2]]
			var up := (b - a).cross(c - a)
			if up.length() < 1e-6 or (face and absf(up.normalized().y) < ShorelineBuilder.CAR_FACE_UP):
				continue
			var plan := [Vector2(a.x, a.z), Vector2(b.x, b.z), Vector2(c.x, c.z)]
			for cell_x in range(floori(minf(a.x, minf(b.x, c.x)) / COVER_CELL_M), floori(maxf(a.x, maxf(b.x, c.x)) / COVER_CELL_M) + 1):
				for cell_z in range(floori(minf(a.z, minf(b.z, c.z)) / COVER_CELL_M), floori(maxf(a.z, maxf(b.z, c.z)) / COVER_CELL_M) + 1):
					var cell := Vector2i(cell_x, cell_z)
					if not cells.has(cell):
						cells[cell] = []
					(cells[cell] as Array).append(plan)
	var boundary := _world.get_boundary()
	var space := _main.get_world_3d().direct_space_state
	var water_y := GeneratedWorldContract.STREET_DETAIL_WATER_Y_M
	var checked := 0
	var holes: Array[Vector2] = []
	for component: Dictionary in boundary.get_boundary_data().components:
		var rings: Array = [component.outer]
		rings.append_array(component.get("holes", []))
		for ring: Array in rings:
			for index in ring.size():
				var a := Vector2(float(ring[index - 1][0]), float(ring[index - 1][1]))
				var b := Vector2(float(ring[index][0]), float(ring[index][1]))
				var length := a.distance_to(b)
				if length < 0.01:
					continue
				var out := Vector2(-(b - a).y, (b - a).x) / length
				var middle := a.lerp(b, 0.5)
				if boundary.contains_position(Vector3(middle.x + out.x * 0.1, 0.0, middle.y + out.y * 0.1)):
					out = -out
				var steps := maxi(1, roundi(length / COVER_STEP_M))
				for k in steps:
					for reach: float in COVER_OUT_M:
						var p := a.lerp(b, (k + 0.5) / steps) + out * reach
						if boundary.contains_position(Vector3(p.x, 0.0, p.y)) or not _drawn_at(cells, p):
							continue
						checked += 1
						var query := PhysicsRayQueryParameters3D.create(Vector3(p.x, 60.0, p.y), Vector3(p.x, water_y, p.y), DRIVABLE_CAR.GROUND_MASK)
						if space.intersect_ray(query).is_empty():
							holes.append(p)
	var shown: Array[String] = []
	for hole: Vector2 in holes.slice(0, 12):
		shown.append("(%.1f, %.1f)" % [hole.x, hole.y])
	print("RIPRAP COVER %d points over drawn riprap 1.5 m and 3 m off the outline, %d with nothing for a car to land on%s" % [checked, holes.size(), (": " + ", ".join(shown)) if not holes.is_empty() else ""])
	# The sweep must have found the riprap at all (a car's reach of it runs round
	# the island), and a car must find ground over every point of it.
	return _require(checked >= 1000, "The riprap sweep found only %d points of drawn riprap off the outline." % checked) \
		and _require(holes.is_empty(), "A car would drop through the drawn riprap at %d points off the outline: %s." % [holes.size(), ", ".join(shown)])


## Whether a drawn shoreline triangle (cells, _case_riprap_cover's) lies under p.
func _drawn_at(cells: Dictionary, p: Vector2) -> bool:
	for plan: Array in cells.get(Vector2i(floori(p.x / COVER_CELL_M), floori(p.y / COVER_CELL_M)), []):
		if Geometry2D.point_is_inside_triangle(p, plan[0], plan[1], plan[2]):
			return true
	return false


## How many points of nearby stones' cores (the middle half of each stone's
## box: its middle and corners) stand inside the car's hulls now: any is a
## stone showing through the car. With above, only stones whose middle is over
## that height (the water's surface: the ones in sight) count.
func _stones_in_car(car: DRIVABLE_CAR, stones: Array[AABB], above: float = -INF) -> int:
	var space := car.get_world_3d().direct_space_state
	var query := PhysicsPointQueryParameters3D.new()
	query.collision_mask = car.collision_layer
	query.collide_with_areas = false
	var inside := 0
	for stone: AABB in stones:
		var middle := stone.get_center()
		if middle.distance_to(car.global_position) > car.length_m or middle.y < above:
			continue
		var core := AABB(middle - stone.size * 0.25, stone.size * 0.5)
		for corner in 9:
			query.position = middle if corner == 8 else core.get_endpoint(corner)
			for hit: Dictionary in space.intersect_point(query, 8):
				if hit.get("rid", RID()) == car.get_rid():
					inside += 1
					break
	return inside


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
	var heading := Vector2(_cases.fence.heading_xz[0], _cases.fence.heading_xz[1]).normalized()
	var group := _fence_group(str(_cases.fence.row))
	if not _require(group != null and group.has_meta("fence_bays") and group.has_meta("fence_posts"), "Fixture fence %s has no bays or posts." % _cases.fence.row):
		return false
	# Straight at a joint: the run-up ends at the fixture's post (a panel stand).
	var posts: Dictionary = group.get_meta("fence_posts")
	var post_key := str(_cases.fence.post)
	var neighbours := _neighbour_posts(post_key)
	if not _require(posts.has(post_key) and posts.has(neighbours[0]) and posts.has(neighbours[1]), "Fixture fence %s has no post %s with neighbours %s." % [_cases.fence.row, post_key, neighbours]):
		return false
	var foot: Vector3 = posts[post_key].frame.foot
	var start := Vector2(foot.x, foot.z) - heading * float(_cases.fence.run_up_m)
	if not await _drive_from(car, start, heading):
		return false
	var breaker := _vehicles.fence_breaker()
	var broken_before := breaker.broken_count()
	var debris_before := breaker.get_child_count()
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
	var ids: Array = breaker.broken_keys().slice(broken_before)
	var keys: Array = ids.map(func(id: Variant) -> String: return str(id).get_slice("|", 1))
	var bays: Dictionary = group.get_meta("fence_bays")
	var felled := breaker.is_post_felled(group, post_key)
	var standing := not breaker.is_post_felled(group, neighbours[0]) and not breaker.is_post_felled(group, neighbours[1])
	var post_debris := breaker.find_children("FencePost*", "", false, false).size()
	print("FENCE broke %s at %.2f m/s, %.2f m/s half a second later, debris %d; post %s felled %s (%d post debris), its neighbours %s standing %s" % [ids, speed_in, speed_out, breaker.get_child_count() - debris_before, post_key, felled, post_debris, neighbours, standing])
	if not _require(broke_tick >= 0 and keys.size() >= 2 and keys.size() <= 4 and ids.all(func(id: Variant) -> bool: return str(id) == BREAKER.fence_id(group, str(id).get_slice("|", 1))), "Driving into the fence's joint broke %s." % [ids]) \
	or not _require(speed_out >= 0.7 * speed_in and speed_in > 5.0, "The car did not keep going through the fence (%.2f -> %.2f m/s)." % [speed_in, speed_out]) \
	or not _require(breaker.get_child_count() - debris_before >= keys.size() + 1, "No debris fell from the broken bays and their felled stand.") \
	or not _require(felled and post_debris >= 1, "The stand the car hit (%s) did not go down with its bays." % post_key) \
	or not _require(standing, "A stand the car did not touch (%s) went down." % [neighbours]):
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
		if breaker.is_broken(group, key) or key.begins_with("g"):
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


## A second fence's bay with the same key as one the first fence lost (keys
## repeat from row to row): it breaks, under the car, and opens on foot too.
func _case_fence_shared() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var breaker := _vehicles.fence_breaker()
	var first := _fence_group(str(_cases.fence.row))
	var second := _fence_group(str(_cases.fence_shared.row))
	var key := str(_cases.fence_shared.bay)
	if not _require(first != null and second != null and first != second and (second.get_meta("fence_bays", {}) as Dictionary).has(key), "Fixture fences %s and %s with bay %s are missing." % [_cases.fence.row, _cases.fence_shared.row, key]) \
	or not _require(breaker.is_broken(first, key) and not breaker.is_broken(second, key), "Bay %s must be broken on %s and whole on %s before the second fence is driven into." % [key, _cases.fence.row, _cases.fence_shared.row]):
		return false
	var bay: Dictionary = (second.get_meta("fence_bays") as Dictionary)[key]
	var shape := _bay_shape(second, key)
	if not _require(shape != null and not shape.disabled, "Bay %s of %s has no intact box." % [key, _cases.fence_shared.row]):
		return false
	var start := Vector2(_cases.fence_shared.start_xz[0], _cases.fence_shared.start_xz[1])
	var heading := Vector2(_cases.fence_shared.heading_xz[0], _cases.fence_shared.heading_xz[1]).normalized()
	if not await _drive_from(car, start, heading):
		return false
	var debris_before := breaker.get_child_count()
	Input.action_press("move_forward")
	var broke := -1
	for tick in 360:
		_steer_toward(car, start + heading * 200.0)
		await physics_frame
		if broke < 0 and breaker.is_broken(second, key):
			broke = tick
		if broke >= 0 and tick >= broke + 20:
			break
	_release_driving()
	print("FENCE SHARED %s bay %s broken %s at tick %d, its box disabled %s, debris %d" % [_cases.fence_shared.row, key, breaker.is_broken(second, key), broke, shape.disabled, breaker.get_child_count() - debris_before])
	if not _require(broke >= 0 and shape.disabled and breaker.get_child_count() > debris_before, "Driving into bay %s of %s (the key %s already broke on %s) did not break it." % [key, _cases.fence_shared.row, key, _cases.fence.row]) \
	or not _require(_side(bay, Vector2(car.global_position.x, car.global_position.z)) != _side(bay, start), "The car did not get through the second fence's line."):
		return false
	if not await _stop_and_exit(car, "fence_shared_drive"):
		return false
	return await _walk_into_bay(bay, true, "%s broken bay %s" % [_cases.fence_shared.row, key])


func _fence_group(row: String) -> Node3D:
	return _world.street_detail_layer("fences").find_child("Fence__" + row.validate_node_name(), true, false) as Node3D


## A bay's collision box in its fence's body.
func _bay_shape(group: Node3D, key: String) -> CollisionShape3D:
	var body := group.get_node_or_null("Collision")
	if body == null:
		return null
	for child: Node in body.get_children():
		if child is CollisionShape3D and str(child.get_meta("fence_bay", "")) == key:
			return child as CollisionShape3D
	return null


## The posts either side of a post "pRUN:INDEX" in its run.
static func _neighbour_posts(key: String) -> Array[String]:
	var run := key.trim_prefix("p").get_slice(":", 0)
	var index := int(key.get_slice(":", 1))
	return ["p%s:%d" % [run, index - 1], "p%s:%d" % [run, index + 1]]


## The turf pitch's windscreen breaks under a car, the ball-stop net behind it
## (breakable: false) stops it like a wall.
func _case_field_net() -> bool:
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var start := Vector2(_cases.field_net.start_xz[0], _cases.field_net.start_xz[1])
	var heading := Vector2(_cases.field_net.heading_xz[0], _cases.field_net.heading_xz[1]).normalized()
	var fences := _world.street_detail_layer("fences")
	var screen := fences.find_child("Fence__" + str(_cases.field_net.fence).validate_node_name(), true, false) as Node3D
	var net := fences.find_child("Fence__" + str(_cases.field_net.net).validate_node_name(), true, false) as Node3D
	if not _require(screen != null and net != null and screen.has_meta("fence_bays") and net.has_meta("fence_bays"), "Fixture fences %s and %s have no bays." % [_cases.field_net.fence, _cases.field_net.net]):
		return false
	var net_body := net.get_node_or_null("Collision") as StaticBody3D
	if not _require(net_body != null and not bool(net_body.get_meta("breakable", true)), "The ball-stop net %s is not breakable: false." % _cases.field_net.net):
		return false
	if not await _drive_from(car, start, heading):
		return false
	var breaker := _vehicles.fence_breaker()
	var broken_before := breaker.broken_count()
	var top := 0.0
	var stopped := false
	Input.action_press("move_forward")
	for tick in 300:
		_steer_toward(car, start + heading * 200.0)
		await physics_frame
		var speed := car.linear_velocity.length()
		top = maxf(top, speed)
		if top > 5.0 and speed < 0.5:
			stopped = true
			break
	_release_driving()
	var keys: Array = breaker.broken_keys().slice(broken_before)
	var net_bay: Dictionary = (net.get_meta("fence_bays") as Dictionary).values()[0]
	var car_xz := Vector2(car.global_position.x, car.global_position.z)
	print("FIELD_NET broke %s at up to %.2f m/s, stopped %s at %s" % [keys, top, stopped, car_xz])
	if not _require(keys.size() >= 1, "Driving at the turf's windscreen broke no bay.") \
	or not _require(stopped, "The car did not stop at the ball-stop net (top %.2f m/s)." % top) \
	or not _require(_side(net_bay, car_xz) == _side(net_bay, start), "The car got through the ball-stop net."):
		return false
	return await _stop_and_exit(car, "field_net")


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
	# Once it has come to rest and frozen, driving up to it again from the
	# case's start, creeping the last metres and pressing on pushes it again.
	var wedge_frozen := false
	for _tick in 600:
		await physics_frame
		if wedge_node.freeze:
			wedge_frozen = true
			break
	var wedge_rest := wedge_node.global_position
	if not _require(wedge_frozen, "The pushed car %s did not come to rest and freeze." % wedge_id) \
	or not await _drive_from(car, Vector2(_cases.wedge.start_xz[0], _cases.wedge.start_xz[1]), wedge_heading):
		return false
	print("WEDGE AGAIN start %.2f m from the frozen car" % car.global_position.distance_to(wedge_rest))
	var woke_tick := -1
	for tick in 1500:
		var gap := Vector2(car.global_position.x - wedge_rest.x, car.global_position.z - wedge_rest.z).length()
		var cap := 0.8 if gap < 9.0 else 6.0
		var speed := car.linear_velocity.length()
		Input.action_release("move_forward")
		Input.action_release("move_back")
		if speed > cap + 0.5:
			Input.action_press("move_back")
		elif speed < cap - 0.15:
			Input.action_press("move_forward")
		_steer_toward(car, Vector2(wedge_rest.x, wedge_rest.z))
		await physics_frame
		if not wedge_node.freeze:
			woke_tick = tick
			break
	_release_driving()
	Input.action_press("move_forward")
	for _tick in 180:
		_steer_toward(car, Vector2(wedge_node.global_position.x, wedge_node.global_position.z))
		await physics_frame
	_release_driving()
	var pushed_again := wedge_node.global_position.distance_to(wedge_rest)
	print("WEDGE AGAIN crept up to it frozen, woken at tick %d; 3 s more of full throttle moved it %.2f m from where it had frozen" % [woke_tick, pushed_again])
	if not _require(woke_tick >= 0 and pushed_again >= 0.5, "Creeping into %s once it had frozen and pressing on wedged (woken at tick %d, moved %.2f m)." % [wedge_id, woke_tick, pushed_again]):
		return false
	# At speed: a parked car from the side, a K-rail end on.
	for target: Dictionary in [{"id": str(_cases.shove.car), "start": _cases.shove.start_xz, "heading": _cases.shove.heading_xz, "again_moves": _cases.shove.again_moves, "min_m": 0.5},
			{"id": str(_cases.krail.row), "start": _cases.krail.start_xz, "heading": _cases.krail.heading_xz, "again_moves": _cases.krail.again_moves, "min_m": 0.2}]:
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
		# Frozen where it stopped, it must not turn into a wall: a second hit
		# from the same start wakes it, and (unless it lies against a wall)
		# moves it or the bodies it now lies among: a K-rail rests among the
		# rest of its row, which the hit may meet first.
		var rest_at := moved_node.global_position
		var others_before := _live_positions(car)
		if not await _drive_from(car, start, heading):
			return false
		Input.action_press("move_forward")
		var woke := false
		var woke_speed := 0.0
		for _tick in 360:
			_steer_toward(car, Vector2(rest_at.x, rest_at.z))
			await physics_frame
			if not moved_node.freeze:
				woke = true
				woke_speed = car.linear_velocity.length()
				break
		for _tick in 30:
			await physics_frame
		_release_driving()
		Input.action_press("move_back")
		for _tick in 90:
			await physics_frame
		Input.action_release("move_back")
		var refrozen := false
		for _tick in 600:
			await physics_frame
			if moved_node.freeze:
				refrozen = true
				break
		var moved_again := moved_node.global_position.distance_to(rest_at)
		# The most any other live body (frozen before the hit) or any row the hit
		# swapped in moved.
		var others_moved := 0.0
		for id: String in _live_positions(car):
			var from: Vector3 = others_before[id] if others_before.has(id) else (_vehicles.row(id).transform as Transform3D).origin
			if id != target.id:
				others_moved = maxf(others_moved, (_vehicles.live_node(id) as Node3D).global_position.distance_to(from))
		print("SHOVE AGAIN %s: set moving %s at %.2f m/s, moved %.2f m from where it had frozen (the most another body moved: %.2f m), at rest and frozen again %s" % [target.id, woke, woke_speed, moved_again, others_moved, refrozen])
		if not _require(woke and (maxf(moved_again, others_moved) >= float(target.min_m) or not bool(target.again_moves)) and refrozen, "Hitting %s again once it had frozen did not shove it or what it lies among (woken %s, moved %.2f m, others %.2f m, frozen again %s)." % [target.id, woke, moved_again, others_moved, refrozen]):
			return false
	return await _stop_and_exit(car, "shove")


# --- 9. The pitch's ball.

func _case_ball() -> bool:
	var balls := get_nodes_in_group(SoccerBall.GROUP)
	if not _require(not balls.is_empty(), "No soccer ball on the pitch."):
		return false
	var ball := balls[0] as SoccerBall
	var spot := ball.global_position
	var car := _vehicles.live_node(str(_cases.enter.car)) as DRIVABLE_CAR
	var heading := Vector2(_cases.ball.heading_xz[0], _cases.ball.heading_xz[1]).normalized()
	if not await _drive_from(car, Vector2(spot.x, spot.z) - heading * float(_cases.ball.run_up_m), heading):
		return false
	Input.action_press("move_forward")
	var hit_speed := 0.0
	var top := 0.0
	for _tick in 300:
		_steer_toward(car, Vector2(spot.x, spot.z))
		await physics_frame
		top = maxf(top, ball.linear_velocity.length())
		if hit_speed == 0.0 and ball.linear_velocity.length() > 1.0:
			hit_speed = car.linear_velocity.length()
		if ball.global_position.distance_to(spot) > 3.0:
			break
	_release_driving()
	var moved := ball.global_position.distance_to(spot)
	# Sent off ahead of the bumper, not ridden over and left behind.
	var ahead := (ball.global_position - car.global_position).dot(Vector3(heading.x, 0.0, heading.y))
	print("BALL a car at %.1f m/s sent the pitch's ball %.1f m from its spot, at up to %.1f m/s, %.1f m ahead of the car" % [hit_speed, moved, top, ahead])
	if not _require(moved > 3.0 and top > 2.0 and ahead > 0.0, "The car did not send the pitch's ball rolling ahead of it (moved %.2f m, top %.1f m/s, %.1f m ahead)." % [moved, top, ahead]):
		return false
	# Into a goal (owner, 2026-11-11): the ball 8 m out in front of the middle of the
	# full-size goal nearest its spot, and the car driven at it along the goal's axis
	# from 12 m behind it, braking once the ball is away.
	var goal := {}
	for candidate: Dictionary in ball.goals:
		if str(candidate.prop) == "goal_soccer" and (goal.is_empty() or float(candidate.half_m) > float(goal.half_m) + 0.01 \
		or (is_equal_approx(float(candidate.half_m), float(goal.half_m)) and (candidate.transform as Transform3D).origin.distance_to(ball.spot.origin) < (goal.transform as Transform3D).origin.distance_to(ball.spot.origin))):
			goal = candidate
	if not _require(not goal.is_empty(), "The ball knows no soccer goal."):
		return false
	var frame: Transform3D = goal.transform
	var into := Vector2(frame.basis.z.x, frame.basis.z.z).normalized()
	var mark := frame * Vector3(0.0, 0.0, -8.0)
	var ground := _ray(mark + Vector3.UP * 5.0, mark + Vector3.DOWN * 5.0, ball.collision_mask)
	if not _require(not ground.is_empty(), "No ground for the ball in front of %s." % goal.id):
		return false
	ball.place((ground.position as Vector3) + Vector3.UP * SoccerBall.RADIUS_M)
	if not await _drive_from(car, Vector2(mark.x, mark.z) - into * 12.0, into):
		return false
	var scored: Array[String] = []
	var record := func(id: String) -> void: scored.append(id)
	ball.scored.connect(record)
	var before := ball.goals_scored
	var resets := ball.resets
	var braking := false
	Input.action_press("move_forward")
	for _tick in 300:
		if not braking:
			_steer_toward(car, Vector2(frame.origin.x, frame.origin.z))
		await physics_frame
		if not braking and ball.linear_velocity.length() > 1.0:
			braking = true
			_release_driving()
			Input.action_press("move_back")
		if ball.goals_scored > before:
			break
	_release_driving()
	ball.scored.disconnect(record)
	var crossbar := frame * Vector3(0.0, float(goal.crossbar_m), 0.0)
	var confetti := ball.get_parent().get_children().filter(func(node: Node) -> bool: return node is CPUParticles3D and str(node.name).begins_with("GoalConfetti") and (node as Node3D).global_position.distance_to(crossbar) < 1.0)
	print("GOAL a car pushed the ball into %s: goals %d, confetti %d, car %.1f m short of the line" % [goal.id, ball.goals_scored - before, confetti.size(), -(frame.affine_inverse() * car.global_position).z])
	if not _require(ball.goals_scored == before + 1 and scored == [str(goal.id)] and not confetti.is_empty(), "A car pushing the ball in through the mouth of %s must score one goal there with confetti (goals %d at %s, confetti %d)." % [goal.id, ball.goals_scored - before, scored, confetti.size()]):
		return false
	for _tick in roundi((SoccerBall.GOAL_RESET_S + 0.5) * Engine.physics_ticks_per_second):
		await physics_frame
		if ball.resets > resets:
			break
	if not _require(ball.resets == resets + 1, "After the car's goal the ball did not go back to its spot."):
		return false
	return await _stop_and_exit(car, "ball")


# --- 10. On foot after getting out.

func _case_on_foot() -> bool:
	if not _require(not _player.is_driving() and _player.is_processing_unhandled_input(), "The player must be on foot."):
		return false
	# Out of the car the controller is back (checked just above); the walk, run,
	# rise and drop are measured on open street, away from what the shoves left.
	if not await _stand_player(Vector2(_cases.on_foot.at_xz[0], _cases.on_foot.at_xz[1])):
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


# --- 11. The browser's touch controls.

func _case_touch() -> bool:
	var touch := TOUCH_CONTROLS.new() as TouchControls
	touch.name = "TouchControls"
	touch.camera_rig = _player.camera_rig
	touch.player = _player
	touch.vehicles = _vehicles
	_main.hud.add_child(touch)
	touch.set_gameplay_active(true)
	var passed := await _touch_steps(touch)
	touch.free()
	var held := ["jetpack", "handbrake", "run", "fast_drop", "vehicle_enter_exit"].filter(func(action: String) -> bool: return Input.is_action_pressed(action))
	if not _require(held.is_empty() and _player.touch_input_vector.is_zero_approx(), "Removing the touch controls left %s held." % [held]):
		return false
	return passed and await _rest("touch")


func _touch_steps(touch: TouchControls) -> bool:
	var use := touch.use_button
	# The fixture car at the start of the Seven Seas run, the player in it.
	var points: Array = _cases.route.points_xz
	var start := Vector2(points[0][0], points[0][1])
	var error: String = _vehicles.drive_from(str(_cases.enter.car), start, Vector2(points[1][0], points[1][1]) - start)
	var car := _vehicles.active_car() as DRIVABLE_CAR
	if not _require(error == "" and car != null, "Could not start the touch drive: %s." % error):
		return false
	for _tick in 60:
		await physics_frame
	var shown := touch.describe()
	if not _require(use.visible and use.mode_name() == "exit" and str(shown.rise_label) == "BRAKE" and str(shown.rise_icon) == "brake" and not bool(shown.run_visible) and not bool(shown.look_hint), "In a car the use button must show GET OUT, RISE the BRAKE glyph and label, and RUN and the look hint hide (%s)." % [shown]):
		return false
	# The stick drives (up), and its corner (up and right) is full throttle and lock.
	var stick := _touch_point(touch, "stick")
	var reach := float(touch.describe().stick_reach)
	_finger(touch, 1, stick, true)
	_slide(touch, 1, stick + Vector2(0.0, -reach))
	for _tick in 90:
		await physics_frame
	var drive := car.drive_input
	var speed := car.forward_speed()
	var heading := car.global_transform.basis.z
	_slide(touch, 1, stick + Vector2(reach, -reach) * 0.7071)
	for _tick in 45:
		await physics_frame
	var corner := Vector2(car.drive_input, car.steer_input)
	var turned := rad_to_deg(heading.angle_to(car.global_transform.basis.z))
	print("TOUCH stick up: drive %.2f, %.2f m/s; corner: drive %.2f, steer %.2f, turned %.1f deg" % [drive, speed, corner.x, corner.y, turned])
	if not _require(drive > 0.95 and speed > 3.0, "The touch stick did not drive the car (input %.2f, %.2f m/s)." % [drive, speed]) \
	or not _require(corner.x > 0.95 and corner.y > 0.95 and turned > 10.0, "The touch stick's corner did not steer at full throttle (drive %.2f, steer %.2f, turned %.1f deg)." % [corner.x, corner.y, turned]):
		return false
	# RISE is the handbrake while touched.
	var rise := _touch_point(touch, "rise")
	_finger(touch, 2, rise, true)
	for _tick in 5:
		await physics_frame
	var braking := car.handbrake
	_finger(touch, 2, rise, false)
	for _tick in 2:
		await physics_frame
	print("TOUCH RISE handbrake while touched %s, after %s" % [braking, car.handbrake])
	if not _require(braking and not car.handbrake, "RISE must hold the car's handbrake while touched (touched %s, after %s)." % [braking, car.handbrake]):
		return false
	# Stopped with the stick (down brakes), then a tap on GET OUT.
	_slide(touch, 1, stick + Vector2(0.0, reach))
	for _tick in 240:
		await physics_frame
		if car.linear_velocity.length() < 0.5:
			break
	_finger(touch, 1, stick, false)
	for _tick in 30:
		await physics_frame
	await _tap(touch, "use")
	if not _require(not _player.is_driving(), "A tap on GET OUT did not get the player out."):
		return false
	shown = touch.describe()
	if not _require(str(shown.rise_label) == "RISE" and str(shown.rise_icon) == "jump" and bool(shown.run_visible) and bool(shown.look_hint), "Out of the car RISE, RUN and the look hint must come back (%s)." % [shown]):
		return false
	# Beside the car DRIVE: a tap gets back in, another out again.
	for _tick in 30:
		await physics_frame
	print("TOUCH out at %s, %.2f m from the car, button %s" % [_player.global_position, _player.global_position.distance_to(car.global_position), use.mode_name()])
	if not _require(use.visible and use.mode_name() == "enter" and (use.get_node("Icon") as TextureRect).texture == TouchUseButton.CAR_ICON, "Beside the car the use button must show DRIVE (%s)." % use.mode_name()):
		return false
	# A finger holding RUN as DRIVE is tapped: RUN hides in the car and its run goes up.
	var run_at := _touch_point(touch, "run")
	_finger(touch, 5, run_at, true)
	var running := Input.is_action_pressed("run")
	await _tap(touch, "use")
	var run_left := Input.is_action_pressed("run")
	_finger(touch, 5, run_at, false)
	if not _require(_vehicles.active_car() == car and use.mode_name() == "exit", "A tap on DRIVE did not get back in (button %s)." % use.mode_name()) \
	or not _require(running and not run_left and not Input.is_action_pressed("run") and not bool(touch.describe().run_visible), "A run held as the player got in must go up with RUN hidden (held %s, after %s)." % [running, run_left]):
		return false
	for _tick in 10:
		await physics_frame
	await _tap(touch, "use")
	if not _require(not _player.is_driving(), "The second tap on GET OUT did not get the player out."):
		return false
	# On open street away from cars it hides; the stick walks.
	if not await _stand_player(Vector2(_cases.on_foot.at_xz[0], _cases.on_foot.at_xz[1])):
		return false
	var ground_y := _player.global_position.y
	var from := _player.global_position
	# North, where the on-foot case walked and ran clear.
	(_player.get_node("CameraPivot") as Node3D).rotation.y = 0.0
	_finger(touch, 1, stick, true)
	_slide(touch, 1, stick + Vector2(0.0, -reach))
	for _tick in 30:
		await physics_frame
	_finger(touch, 1, stick, false)
	for _tick in 30:
		await physics_frame
	var walked := Vector2(_player.global_position.x - from.x, _player.global_position.z - from.z).length()
	if not _require(walked > 1.0 and _player.is_on_floor() and not use.visible and use.mode_name() == "hidden", "On the ground away from cars the stick must walk and the use button hide (walked %.2f m, button %s)." % [walked, use.mode_name()]):
		return false
	# RISE lifts; once off the ground a moment the button shows DROP.
	_finger(touch, 2, rise, true)
	var shown_tick := -1
	for tick in 150:
		await physics_frame
		if shown_tick < 0 and use.mode_name() == "drop":
			shown_tick = tick
	_finger(touch, 2, rise, false)
	for _tick in 30:
		await physics_frame
	var height := _player.global_position.y - ground_y
	print("TOUCH DROP shown after %d ticks in the air, %.2f m up" % [shown_tick, height])
	if not _require(shown_tick > 0 and use.visible and (use.get_node("Icon") as TextureRect).texture == TouchUseButton.DROP_ICON and height > 6.0, "In the air the use button must show DROP (after %d ticks, %.2f m up, button %s)." % [shown_tick, height, use.mode_name()]):
		return false
	# Held, DROP is the fast drop; lifted in the air, it lets go.
	var drop := _touch_point(touch, "use")
	_finger(touch, 3, drop, true)
	for _tick in 20:
		await physics_frame
	var held_c := Input.is_action_pressed("fast_drop") and use.is_touched()
	var falling := -_player.velocity.y
	_finger(touch, 3, drop, false)
	var let_go := not Input.is_action_pressed("fast_drop")
	print("TOUCH DROP held %s, falling %.2f m/s, let go %s, %.2f m up" % [held_c, falling, let_go, _player.global_position.y - ground_y])
	if not _require(held_c and falling > 6.0 and let_go and not _player.is_on_floor() and use.mode_name() == "drop", "Holding DROP must hold the fast drop and lifting it let go in the air (held %s, falling %.2f m/s, let go %s)." % [held_c, falling, let_go]):
		return false
	# Held through the landing: on the ground C goes up and the button hides,
	# the finger still down; its lift then changes nothing.
	_finger(touch, 3, drop, true)
	var landed := false
	for _tick in 240:
		await physics_frame
		if _player.is_on_floor():
			landed = true
			break
	for _tick in 3:
		await physics_frame
	var after := [Input.is_action_pressed("fast_drop"), use.visible, use.is_touched()]
	_finger(touch, 3, drop, false)
	print("TOUCH DROP held through the landing: landed %s, C held %s, shown %s, touched %s" % [landed, after[0], after[1], after[2]])
	return _require(landed and after == [false, false, false] and not Input.is_action_pressed("fast_drop"), "Landing with DROP held must let go of C and hide the button (landed %s, C held %s, shown %s)." % [landed, after[0], after[1]])


# --- Helpers.

## A control's centre in the touch controls (their describe()).
func _touch_point(touch: TouchControls, control: String) -> Vector2:
	var at: Array = touch.describe()[control]
	return Vector2(float(at[0]), float(at[1]))


func _finger(touch: TouchControls, index: int, at: Vector2, down: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = at
	event.pressed = down
	touch._input(event)


func _slide(touch: TouchControls, index: int, at: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = at
	touch._input(event)


## A quick tap on a touch control, lifted before any physics tick, then three ticks.
func _tap(touch: TouchControls, control: String) -> void:
	var at := _touch_point(touch, control)
	_finger(touch, 9, at, true)
	_finger(touch, 9, at, false)
	for _tick in 3:
		await physics_frame

## Where every live car and K-rail is now (but the driven car), by row id.
func _live_positions(driven: Node3D) -> Dictionary:
	var found := {}
	for id: String in _vehicles.swappable_ids():
		var node := _vehicles.live_node(id)
		if node != null and node != driven:
			found[id] = node.global_position
	return found


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


## The case's end: inputs released, the car (if any) stopped, the player
## standing with the avatar.
func _rest(label: String) -> bool:
	_release()
	for _tick in 90:
		await physics_frame
		if _player.is_on_floor() and Vector2(_player.velocity.x, _player.velocity.z).length() < 0.05:
			print("REST %s player at %s on floor, driving %s" % [label, _player.global_position, _player.is_driving()])
			return await _avatar_with_player(label)
	return _require(false, "No supported rest after %s (player at %s, on floor %s)." % [label, _player.global_position, _player.is_on_floor()])


## On foot the chest avatar shows and stands with the player: a few ticks on,
## both its feet within AVATAR_REACH_M of the capsule.
func _avatar_with_player(label: String) -> bool:
	var pivot := _player.get_node("AvatarPivot") as Node3D
	var avatar: Node = pivot.get_child(0) if pivot.get_child_count() > 0 else null
	for _tick in 10:
		await physics_frame
	if not _require(pivot.is_visible_in_tree() and avatar != null and avatar.has_method("describe"), "On foot (%s) the avatar must show." % label):
		return false
	var feet: Array = avatar.describe().get("feet", [])
	var at := _player.global_position
	var farthest := 0.0
	for foot: Variant in feet:
		farthest = maxf(farthest, Vector2((foot as Vector3).x - at.x, (foot as Vector3).z - at.z).length())
	print("AVATAR %s shown, %d feet, the farthest %.2f m from the player" % [label, feet.size(), farthest])
	return _require(feet.size() == 2 and farthest < AVATAR_REACH_M, "On foot (%s) the avatar's feet must stand with the player (%d feet, the farthest %.2f m away)." % [label, feet.size(), farthest])


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
