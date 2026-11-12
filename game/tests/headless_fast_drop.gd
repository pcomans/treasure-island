extends SceneTree
## Holding the fast drop (C) makes the stock player fall fast in the air and does
## nothing on the ground:
##   1. from 60 m the drop reaches its speed and lands on the open land, a road and a
##      roof at the height of what is there, with no recovery, and stays put;
##   2. on the ground C holds the player still, keeps the capsule's height and leaves
##      a walk exactly as it is: there is no crouch;
##   3. Space beats C, in the air and leaving the ground;
##   4. letting go of C in the air eases back to the jetpack's slow descent;
##   5. each of those fast-drop landings kicks up the dust poof once, at the feet,
##      as the player touches down. None comes from a slow landing, from C pressed
##      just before a slow touchdown (too slow for a fast drop), from a fast landing
##      with C let go or Space pressed just before it, or from anything else here
##      (C on the ground, a walk with it, Space with it).
## Physics only (run with --headless), in the real generated world.

# Each spot's first solid below the sky; min_y keeps the roof a roof.
const SPOTS := [
	{"name": "land", "xz": Vector2(-20.0, 60.0), "ground": true, "min_y": 0.0},
	{"name": "road", "xz": Vector2(278.0, 199.0), "ground": true, "min_y": 0.0},
	{"name": "roof of w34313513", "xz": Vector2(157.0, 220.5), "ground": false, "min_y": 12.0},
]
const GROUND_FEATURE_KINDS := ["land_ground", "street_kerb", "street_kerb_support"]
const DROP_HEIGHT_M := 60.0
# 60 m at 18 m/s is about 3.6 s; the slow descent would take 40 s.
const MAX_DROP_TICKS := 300
# The first 18 m/s takes 0.6 s at 30 m/s^2.
const REACH_SPEED_TICKS := 40
# The capsule's safe margin and a sloped spot's floor contact.
const LANDING_TOLERANCE_M := 0.05
# A landing moves nothing sideways; these spots are near level.
const LANDING_DRIFT_M := 0.25
# The poof stands on the drawn ground: the surface itself, or a road, path or
# area drawn up to 0.08 m above the land collision the capsule stands on.
const POOF_ABOVE_M := Vector2(-0.02, 0.12)
const POOF_AWAY_M := 0.3
# The slow landings start this high (about 2 s at the slow descent), the fast ones
# this high (full fast-drop speed well before the ground).
const SLOW_DROP_HEIGHT_M := 3.0
const FAST_DROP_HEIGHT_M := 20.0
# How far above the surface the late switches come: a few ticks before touchdown.
const LATE_C_M := 0.5
const LATE_SWITCH_M := 0.6

var _poofs: Array[Vector3] = []

var _failure := ""
var _finished := false
var _recoveries := 0


func _initialize() -> void:
	create_timer(150.0, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	main.capture_mouse_on_ready = false
	# The default shadows, never a level saved in the shared user folder (main.gd).
	main.use_saved_settings = false
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var load_failures: Array[String] = []
	world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void: load_failures.append("%s: %s" % [code, message]))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while not main.is_play_ready() and load_failures.is_empty() and Time.get_ticks_msec() - started < 90000:
		await process_frame
	if not _require(load_failures.is_empty() and main.is_play_ready(), "World did not reach play: %s" % [load_failures]):
		_finish(main)
		return
	paused = false
	_release()
	player.recovered.connect(func(_cause: String, _from_position: Vector3) -> void: _recoveries += 1)
	var poof := player.get_node_or_null("AvatarPivot/ChestAvatar/LandingPoof") as LandingPoof
	if not _require(poof != null, "The player character has no landing poof."):
		_finish(main)
		return
	poof.poofed.connect(func(at: Vector3) -> void: _poofs.append(at))

	# 1. Drops onto the land, a road and a roof, each kicking up one poof (5).
	for spot: Dictionary in SPOTS:
		if not await _drop(player, spot, poof):
			_finish(main)
			return
	# 5. No poof without a fast drop at touchdown: a slow landing, as after the jetpack
	# or walking off a ledge; C pressed just before a slow touchdown, too late to
	# reach the fast drop's pace; and a fast landing with C let go, or Space pressed,
	# just before it.
	var half_drop := 0.5 * player.fast_drop_speed_mps
	var slow := await _landing(player, SPOTS[1], "slow", SLOW_DROP_HEIGHT_M, [], -1.0, [])
	if not _require(is_equal_approx(slow, player.jetpack_descent_speed_mps), "The slow landing came down at %.3f m/s." % slow):
		_finish(main)
		return
	var late_c := await _landing(player, SPOTS[1], "late C", SLOW_DROP_HEIGHT_M, [], LATE_C_M, ["fast_drop"])
	if not _require(late_c > player.jetpack_descent_speed_mps + 1.0 and late_c < half_drop, "C pressed just before a slow touchdown came down at %.3f m/s, not between the slow descent and half the fast drop." % late_c):
		_finish(main)
		return
	var let_go := await _landing(player, SPOTS[1], "C let go", FAST_DROP_HEIGHT_M, ["fast_drop"], LATE_SWITCH_M, [])
	var with_space := await _landing(player, SPOTS[1], "Space with C", FAST_DROP_HEIGHT_M, ["fast_drop"], LATE_SWITCH_M, ["fast_drop", "jetpack"])
	if not _require(let_go >= half_drop and with_space >= half_drop, "The late switches were not fast landings: %.3f and %.3f m/s." % [let_go, with_space]):
		_finish(main)
		return
	_poofs.clear()

	# 2. On the ground C does nothing.
	var road: Dictionary = SPOTS[1]
	var ground := _first_solid(player, road.xz)
	var standing := (ground.position as Vector3) + Vector3.UP * 0.1
	if not await _settle(player, standing):
		_finish(main)
		return
	var settled := player.global_position
	var capsule := (player.get_node("CollisionShape3D") as CollisionShape3D).shape as CapsuleShape3D
	var height := capsule.height
	var shape_y := (player.get_node("CollisionShape3D") as Node3D).position.y
	Input.action_press("fast_drop")
	for _tick in 30:
		await physics_frame
		if not _require(player.is_on_floor() and player.velocity.is_zero_approx() and player.global_position.distance_to(settled) < 0.001, "Holding C on the ground moved the player: %s, velocity %s, on floor %s." % [player.global_position, player.velocity, player.is_on_floor()]):
			_finish(main)
			return
	if not _require(is_equal_approx(capsule.height, height) and is_equal_approx((player.get_node("CollisionShape3D") as Node3D).position.y, shape_y), "Holding C changed the capsule: there is no crouch."):
		_finish(main)
		return
	_release()
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var along := Vector3(1.0, 0.0, 0.0)
	var walked := await _walk(player, rig, settled, along, false)
	var walked_with_c := await _walk(player, rig, settled, along, true)
	print("WALK plain=%s with_c=%s" % [walked, walked_with_c])
	if not _require(walked.length() > 2.0 and walked.distance_to(walked_with_c) < 0.001, "Holding C changed a walk: %s against %s." % [walked_with_c, walked]):
		_finish(main)
		return

	# 3. Space beats C: the same climb with or without it, in the air and from the ground.
	var air := settled + Vector3.UP * 40.0
	var climbed := await _climb(player, air, false, false)
	var climbed_with_c := await _climb(player, air, false, true)
	var lifted := await _climb(player, settled, true, false)
	var lifted_with_c := await _climb(player, settled, true, true)
	print("CLIMB air=%.3f with_c=%.3f ground=%.3f with_c=%.3f" % [climbed, climbed_with_c, lifted, lifted_with_c])
	if not _require(climbed > 1.0 and absf(climbed - climbed_with_c) < 0.001, "Holding C changed the jetpack's climb in the air: %.3f against %.3f." % [climbed_with_c, climbed]) \
	or not _require(lifted > 1.0 and absf(lifted - lifted_with_c) < 0.001, "Holding C changed the jetpack's lift off the ground: %.3f against %.3f." % [lifted_with_c, lifted]):
		_finish(main)
		return

	# 4. Letting go in the air eases back to the slow descent.
	if not await _settle(player, air, false):
		_finish(main)
		return
	Input.action_press("fast_drop")
	for _tick in 60:
		await physics_frame
	var at_speed := -player.velocity.y
	_release()
	for _tick in 90:
		await physics_frame
	print("RELEASE fast=%.3f then=%.3f" % [at_speed, -player.velocity.y])
	if not _require(is_equal_approx(at_speed, player.fast_drop_speed_mps), "The drop was not at its speed before the release: %.3f." % at_speed) \
	or not _require(is_equal_approx(-player.velocity.y, player.jetpack_descent_speed_mps), "Releasing C did not ease to the slow descent: %.3f." % -player.velocity.y) \
	or not _require(_recoveries == 0, "The fast drop needed %d recoveries." % _recoveries):
		_finish(main)
		return
	if not _require(_poofs.is_empty(), "A poof came from something other than a fast-drop landing: at %s." % [_poofs]):
		_finish(main)
		return
	print("PASS: C drops the stock player fast onto land, road and roof without passing through, kicking up the dust poof as it lands, does nothing on the ground, and Space beats it; no poof comes without a fast drop at touchdown (a slow landing, a late C, C let go or Space pressed just before it)")
	_finish(main)


## Drops the player from above a spot with C held, then holds it on the landing:
## the landing kicks up one poof at the feet, as the player touches down.
func _drop(player: PlayerController, spot: Dictionary, poof: LandingPoof) -> bool:
	var hit := _first_solid(player, spot.xz)
	if not _require(not hit.is_empty() and (hit.position as Vector3).y >= float(spot.min_y), "%s: nothing solid at the height expected: %s." % [spot.name, hit]) \
	or not _require(not bool(spot.ground) or _is_ground(hit), "%s: the first solid is not the ground: %s." % [spot.name, hit]):
		return false
	var surface := hit.position as Vector3
	if not await _settle(player, surface + Vector3.UP * DROP_HEIGHT_M, false):
		return false
	var start := player.global_position
	_poofs.clear()
	Input.action_press("fast_drop")
	var ticks := 0
	var peak := 0.0
	var peak_tick := -1
	var lowest := INF
	while ticks < MAX_DROP_TICKS:
		await physics_frame
		ticks += 1
		lowest = minf(lowest, player.global_position.y)
		if -player.velocity.y > peak:
			peak = -player.velocity.y
			peak_tick = ticks
		# The floor flag is still the last spot's until the first move at this one.
		if ticks > 2 and player.is_on_floor():
			break
	print("DROP %s from %.2f onto %.3f: %d ticks, peak %.3f m/s at tick %d, lowest %.3f" % [spot.name, start.y, surface.y, ticks, peak, peak_tick, lowest])
	if not _require(player.is_on_floor(), "%s: no landing within %d ticks; at %s." % [spot.name, MAX_DROP_TICKS, player.global_position]) \
	or not _require(is_equal_approx(peak, player.fast_drop_speed_mps) and peak_tick <= REACH_SPEED_TICKS, "%s: the drop peaked at %.3f m/s at tick %d." % [spot.name, peak, peak_tick]) \
	or not _require(lowest >= surface.y - LANDING_TOLERANCE_M, "%s: the player went through the surface at %.3f: reached %.3f." % [spot.name, surface.y, lowest]):
		return false
	var landed := player.global_position
	# The avatar reacts in the landing tick itself, after the controller has moved.
	if not _require(_poofs.size() == 1 and poof.emitting, "%s: the landing kicked up %d poofs (emitting %s), not one as it touched down." % [spot.name, _poofs.size(), poof.emitting]):
		return false
	var at := _poofs[0]
	print("POOF %s at %s, %.3f m above the capsule's foot, %.3f m from it" % [spot.name, at, at.y - landed.y, Vector2(at.x - landed.x, at.z - landed.z).length()])
	if not _require(at.y - landed.y >= POOF_ABOVE_M.x and at.y - landed.y <= POOF_ABOVE_M.y and Vector2(at.x - landed.x, at.z - landed.z).length() <= POOF_AWAY_M, "%s: the poof is not at the feet: %s against %s." % [spot.name, at, landed]):
		return false
	for _tick in 30:
		await physics_frame
		if not _require(player.is_on_floor() and absf(player.global_position.y - landed.y) < 0.01, "%s: the landing did not hold: %s against %s." % [spot.name, player.global_position, landed]):
			return false
	_release()
	if not _require(_poofs.size() == 1, "%s: standing on with C held kicked up another poof." % spot.name):
		return false
	var drift := Vector2(landed.x - start.x, landed.z - start.z).length()
	return _require(absf(landed.y - surface.y) <= LANDING_TOLERANCE_M, "%s: landed at %.3f, not on the surface at %.3f." % [spot.name, landed.y, surface.y]) \
		and _require(drift <= LANDING_DRIFT_M, "%s: the landing moved the player %.3f m sideways." % [spot.name, drift]) \
		and _require(_recoveries == 0, "%s: the drop needed a recovery." % spot.name)


## Comes down on a spot from height_m above it holding first_hold, switches to
## then_hold once the feet are switch_m above the surface (never, below 0), lands
## and stands. Returns how fast it came down on its last tick in the air, or -1.0
## when it didn't land, needed a recovery or kicked up a poof.
func _landing(player: PlayerController, spot: Dictionary, label: String, height_m: float, first_hold: Array, switch_m: float, then_hold: Array) -> float:
	var hit := _first_solid(player, spot.xz)
	if not _require(not hit.is_empty(), "%s: nothing solid for the %s landing." % [spot.name, label]):
		return -1.0
	var surface := hit.position as Vector3
	if not await _settle(player, surface + Vector3.UP * height_m, false):
		return -1.0
	_poofs.clear()
	var recoveries := _recoveries
	for action: StringName in first_hold:
		Input.action_press(action)
	var switched := switch_m < 0.0
	var ticks := 0
	var speed := 0.0
	while ticks < MAX_DROP_TICKS:
		await physics_frame
		ticks += 1
		if ticks > 2 and player.is_on_floor():
			break
		speed = -player.velocity.y
		if not switched and player.global_position.y - surface.y <= switch_m:
			switched = true
			_release()
			for action: StringName in then_hold:
				Input.action_press(action)
	# Let go at once, so Space doesn't lift it off again.
	_release()
	for _tick in 30:
		await physics_frame
	print("LANDING %s on %s: %d ticks, came down at %.3f m/s, poofs %d" % [label, spot.name, ticks, speed, _poofs.size()])
	var landed := _require(player.is_on_floor() and switched, "%s on %s: no landing within %d ticks, or no switch (%s); at %s." % [label, spot.name, MAX_DROP_TICKS, switched, player.global_position]) \
		and _require(_recoveries == recoveries, "%s on %s: the landing needed a recovery." % [label, spot.name]) \
		and _require(_poofs.is_empty(), "%s on %s: the landing kicked up a poof at %s." % [label, spot.name, _poofs])
	return speed if landed else -1.0


## The displacement of a 60-tick walk from at, along direction.
func _walk(player: PlayerController, rig: PlayerCamera, at: Vector3, direction: Vector3, hold_c: bool) -> Vector3:
	await _settle(player, at + Vector3.UP * 0.02)
	rig.rotation = Vector3(0.0, atan2(-direction.x, -direction.z), 0.0)
	var from := player.global_position
	if hold_c:
		Input.action_press("fast_drop")
	Input.action_press("move_forward")
	for _tick in 60:
		await physics_frame
	var moved := player.global_position - from
	_release()
	return moved


## How far 60 ticks of Space lift the player from at.
func _climb(player: PlayerController, at: Vector3, grounded: bool, hold_c: bool) -> float:
	await _settle(player, at, grounded)
	var from := player.global_position.y
	if hold_c:
		Input.action_press("fast_drop")
	Input.action_press("jetpack")
	for _tick in 60:
		await physics_frame
	var climbed := player.global_position.y - from
	_release()
	return climbed


## Puts the player at a spot, at rest; on the ground unless grounded is false.
func _settle(player: PlayerController, at: Vector3, grounded := true) -> bool:
	_release()
	player.set_gameplay_enabled(false)
	player.global_transform = Transform3D(Basis.IDENTITY, at)
	player.velocity = Vector3.ZERO
	player.set_gameplay_enabled(true)
	if not grounded:
		return true
	for _tick in 30:
		await physics_frame
	return _require(player.is_on_floor(), "The player did not settle at %s: at %s." % [at, player.global_position])


## The first thing the player can stand on, straight down from the sky.
func _first_solid(player: PlayerController, xz: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(Vector3(xz.x, 300.0, xz.y), Vector3(xz.x, -20.0, xz.y), player.collision_mask, [player.get_rid()])
	query.hit_back_faces = false
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _is_ground(hit: Dictionary) -> bool:
	var collider := hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	return record != null and str(record.get_meta("feature_kind", "")) in GROUND_FEATURE_KINDS


func _release() -> void:
	for action: StringName in ["move_forward", "jetpack", "fast_drop"]:
		Input.action_release(action)


func _require(condition: bool, message: String) -> bool:
	if not condition and _failure.is_empty():
		_failure = message
		push_error(message)
	return condition


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	_release()
	if main != null and is_instance_valid(main):
		main.queue_free()
		await process_frame
	quit(0 if _failure.is_empty() else 1)


func _on_timeout() -> void:
	if not _finished:
		_finished = true
		_require(false, "The fast drop test did not finish within 150 s.")
		_release()
		quit(1)
