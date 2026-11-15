class_name CarSound
extends RefCounted
## The driven car's sound (owner, 2026-11-14: one sound set for every drivable
## vehicle), for the vehicle manager (vehicle_manager.gd), which calls start when
## the player gets in, drive each physics tick while driving and stop when the
## player gets out. Only the driven car has these: a parked or shoved car has no
## sound of its own but its hits (vehicle_manager.gd _sound_impact).
##
## Getting in: the door opens, the engine starts at once (its takes crank from
## their first moment and catch about 0.7 s in), the door shuts and the loops
## come in under the start as it catches; the throttle brings them in at once,
## so the engine is heard as the car first moves (owner, 2026-11-14: the car was
## already moving when the start played). Getting out: the engine's loops fade
## out (the owner wants no stop sound, 2026-11-14) and the door opens and shuts.
## The engine: three steady loops of the same car (idle, low, high), crossfaded
## (equal power) by a virtual rev made from the throttle and the speed over the
## body's top speed, each pitched within about a third of an octave of its take,
## never one loop across the whole range (tools/sfx/README.md). With the
## throttle down the rev runs a little above the speed's, and with the wheels in
## the air it follows the throttle alone; it rises in REV_UP_S and falls in
## REV_DOWN_S. A loop with no takes leaves its band to its neighbour, so a
## missing take never drops the engine out. The tyres: one skid loop whose gain
## follows the tyres' sliding speed (DrivableCar.slip, smoothed in SKID_UP_S and
## SKID_DOWN_S), so a flickering drift never restarts a sound; plain steering
## squeals only from STEER_SQUEAL_SHARE of the car's top speed. In the bay the
## engine dies; back on land it starts again, its loops coming in under the
## start as on getting in. A jump's landing on the wheels (LAND_AIR_S) and the
## shore's rocks under the wheels (RIPRAP) have sounds of their own (owner's
## picks, 2026-11-14).

## After getting in (s): the start, just after the door's first sound; the door
## shutting, its slam (about 30 ms into the takes since the sheet's
## oneshot_door_close trim) between the start's crank and its catch.
const ENGINE_START_S := 0.1
const DOOR_CLOSE_S := 0.5
## The loops come in from ENGINE_LOOPS_S after getting in, about when the start
## catches, over ENGINE_FADE_S; from the first throttle before that, over
## ENGINE_THROTTLE_FADE_S.
const ENGINE_LOOPS_S := 0.7
const ENGINE_FADE_S := 0.3
const ENGINE_THROTTLE_FADE_S := 0.1
## After getting out (s): the door opening, and shutting where its slam fell
## before the takes' trim (about 1.25 s).
const EXIT_DOOR_OPEN_S := 0.25
const EXIT_DOOR_CLOSE_S := 1.25
const REV_UP_S := 0.25
const REV_DOWN_S := 0.45
## The rev where the low loop is alone (the idle below it, the high above).
const LOW_REV := 0.45
const SKID_UP_S := 0.05
const SKID_DOWN_S := 0.15
## The tyres' sliding speed (m/s) where the skid starts, and how much more takes
## it to full.
const SKID_FROM_MPS := 1.2
const SKID_RANGE_MPS := 4.0
## Plain steering squeals only from this share of the driven car's own top speed
## (owner, 2026-11-15: no squeal from steering below 90 %); the handbrake and a
## hard brake (the pedal against the way the car rolls) squeal at any speed
## (squeals). How far the car slides off its heading tells nothing apart: steering
## alone swings a sedan's tail 15 to 28 degrees off it in a full-lock slalom
## from half to 85 % of its top speed.
const STEER_SQUEAL_SHARE := 0.9
const IDLE := &"car_engine_idle_loop"
const LOW := &"car_engine_low_loop"
const HIGH := &"car_engine_high_loop"
const SKID := &"tyre_skid_loop"
## The engine and tyres follow the car this often (s): 30 times a second, which
## the loops' own smoothing makes continuous, at half the physics tick's cost.
const UPDATE_S := 1.0 / 30.0
## A landing (car_jump_landing): two or more wheels back on the ground after at
## least LAND_AIR_S with none, the car having come down at LAND_MIN_MPS or more;
## its strength follows that speed up to LAND_FULL_MPS. The air time counts only
## while the car is free: getting in, a teleport (DrivableCar.place, R, the way
## back from the water: a move of TELEPORT_M or more in one physics tick), being
## held after R, sinking or being righted start it again, so none of them lands.
## A landing is one sound: for LAND_HUSH_S after it the vehicle manager plays no
## hit for this car whose velocity change lies mostly along the car's up (a share
## over LAND_HUSH_UP: the ground stopping the fall), so a crash sideways into a
## wall or a car at touchdown still sounds (landing_hushes). Production inference,
## to be tuned by ear.
const LANDING := &"car_jump_landing"
const LAND_AIR_S := 0.35
const LAND_MIN_MPS := 2.5
const LAND_FULL_MPS := 10.0
const LAND_HUSH_S := 0.2
const LAND_HUSH_UP := 0.7
const TELEPORT_M := 3.0
## The shore's rocks (riprap_rumble_loop): while a wheel stands on the cars'
## ground over the riprap (shoreline_builder.gd's CarGround, whose feature_kind is
## RIPRAP_KIND; the wheels' own rays find it, DrivableCar.wheel_ground), by speed
## from RUMBLE_FROM_MPS (silent below: stopped) to RUMBLE_FULL_MPS, looked at
## RUMBLE_UPDATE_S apart. A bounce off the rocks shorter than RUMBLE_AIR_S keeps
## it, and it rises in RUMBLE_UP_S and falls in RUMBLE_DOWN_S, so it never chops.
const RIPRAP := &"riprap_rumble_loop"
const RIPRAP_KIND := "shoreline_car_ground"
const RUMBLE_FROM_MPS := 0.5
const RUMBLE_FULL_MPS := 6.0
const RUMBLE_UPDATE_S := 0.1
const RUMBLE_AIR_S := 0.3
const RUMBLE_UP_S := 0.05
const RUMBLE_DOWN_S := 0.15

var _car: DrivableCar
var _clock := 0.0
## The time gone by since the last update.
var _due := 0.0
var _rev := 0.0
var _skid := 0.0
## When the loops come in after getting in (s), and over how long.
var _loops_from := ENGINE_LOOPS_S
var _loops_fade := ENGINE_FADE_S
## Whether the idle and high loops have takes (looked up once a drive).
var _has_idle := true
var _has_high := true
## The jump: how long no wheel has touched (s), the fastest it has come down since
## (m/s), when it last landed (the clock) and where it was the last tick.
var _air_s := 0.0
var _fall_mps := 0.0
var _landed_at := -INF
var _last_at := Vector3.INF
## The rocks' rumble now (0..1) and the time since it was last looked at.
var _rumble := 0.0
var _rumble_due := 0.0
## Whether the engine died in the bay and has not started again since.
var _drowned := false


## The player got into car.
func start(car: DrivableCar) -> void:
	_car = car
	_clock = 0.0
	_due = UPDATE_S
	_rev = 0.0
	_skid = 0.0
	_loops_from = ENGINE_LOOPS_S
	_loops_fade = ENGINE_FADE_S
	_has_idle = Sound.has_takes(IDLE)
	_has_high = Sound.has_takes(HIGH)
	_air_s = 0.0
	_fall_mps = 0.0
	_landed_at = -INF
	_last_at = Vector3.INF
	_rumble = 0.0
	_rumble_due = RUMBLE_UPDATE_S
	_drowned = false
	# Back in before the last getting out's door had opened or shut: neither plays
	# after (review note, 2026-11-14), only this getting in's.
	Sound.cancel_after(&"car_door_open", car)
	Sound.cancel_after(&"car_door_close", car)
	# Where it is drawn: a car just put down (DrivableCar.place) moves its body at
	# the next physics step, its visual at once.
	Sound.play(&"car_door_open", car.visual_transform().origin)
	Sound.play_after(DOOR_CLOSE_S, &"car_door_close", car)
	Sound.play_after(ENGINE_START_S, &"car_engine_start", car)


## The player got out of car: out before the door had shut or the engine had
## started, neither plays after.
func stop(car: DrivableCar) -> void:
	Sound.cancel_after(&"car_door_close", car)
	Sound.cancel_after(&"car_engine_start", car)
	Sound.play_after(EXIT_DOOR_OPEN_S, &"car_door_open", car)
	Sound.play_after(EXIT_DOOR_CLOSE_S, &"car_door_close", car)
	for loop: StringName in [IDLE, LOW, HIGH, SKID, RIPRAP]:
		Sound.release(loop, car)
	_car = null


## Each physics tick while driving car (it updates UPDATE_S apart).
func drive(car: DrivableCar, delta: float) -> void:
	if car != _car:
		start(car)
	_clock += delta
	# The engine died in the bay; back on land it starts again as on getting in
	# (review note, 2026-11-14: its loops came back with no start), the start
	# ENGINE_START_S on, where the car and the camera are by then (the camera
	# snaps behind the car a moment after it is put back).
	if car.is_sinking():
		_drowned = true
	elif _drowned:
		_drowned = false
		Sound.play_after(ENGINE_START_S, &"car_engine_start", car)
		_loops_from = _clock + ENGINE_LOOPS_S
		_loops_fade = ENGINE_FADE_S
	_watch_landing(car, delta)
	_rumble_due += delta
	if _rumble_due >= RUMBLE_UPDATE_S:
		if car.is_sinking() or car.is_righting():
			_rumble = 0.0
		else:
			var target := rumble_level(riprap_wheels(car), car.speed()) if _air_s < RUMBLE_AIR_S else 0.0
			_rumble = lerpf(_rumble, target, 1.0 - exp(-_rumble_due / (RUMBLE_UP_S if target > _rumble else RUMBLE_DOWN_S)))
			if target <= 0.0 and _rumble < 0.01:
				_rumble = 0.0
		_rumble_due = 0.0
	_due += delta
	if _due < UPDATE_S:
		return
	var step := _due
	_due = 0.0
	var throttle := absf(car.drive_input) if absf(car.drive_input) > 0.1 and not car.is_holding() else 0.0
	# A throttle before the loops' time brings them in now.
	if throttle > 0.0 and _clock < _loops_from:
		_loops_from = _clock
		_loops_fade = ENGINE_THROTTLE_FADE_S
	var running := 0.0 if car.is_sinking() else clampf((_clock - _loops_from) / _loops_fade, 0.0, 1.0)
	var share := clampf(absf(car.forward_speed()) / maxf(car.top_speed(), 1.0), 0.0, 1.0)
	var target := clampf(share * (0.85 + 0.15 * throttle) + 0.15 * throttle, 0.35 * throttle, 1.0)
	var wheels := car.grounded_wheels()
	if wheels == 0:
		target = maxf(share, 0.9 * throttle)
	_rev = lerpf(_rev, target, 1.0 - exp(-step / (REV_UP_S if target > _rev else REV_DOWN_S)))
	var at := car.visual_transform().origin
	var weights := engine_weights(_rev, _has_idle, _has_high)
	var level := running * (0.85 + 0.15 * throttle)
	Sound.hold(IDLE, car, level * weights.x, at, clampf(1.0 + 0.4 * _rev, 0.9, 1.18))
	Sound.hold(LOW, car, level * weights.y, at, clampf(1.0 + 0.45 * (_rev - LOW_REV), 0.85, 1.2))
	Sound.hold(HIGH, car, level * weights.z, at, clampf(1.0 + 0.45 * (_rev - 0.9), 0.85, 1.12))
	var speed := car.speed()
	var sliding := car.slip() if wheels >= 2 and speed > 1.5 and squeals(car) else 0.0
	_skid = lerpf(_skid, sliding, 1.0 - exp(-step / (SKID_UP_S if sliding > _skid else SKID_DOWN_S)))
	Sound.hold(SKID, car, clampf((_skid - SKID_FROM_MPS) / SKID_RANGE_MPS, 0.0, 1.0), at, 0.95 + 0.1 * clampf(speed / 30.0, 0.0, 1.0))
	Sound.hold(RIPRAP, car, _rumble, at, 0.9 + 0.2 * clampf(speed / RUMBLE_FULL_MPS, 0.0, 1.0))


## Each physics tick: a landing after a jump (see LAND_AIR_S).
func _watch_landing(car: DrivableCar, delta: float) -> void:
	var at := car.global_position
	var moved := at.distance_to(_last_at) if _last_at.is_finite() else 0.0
	_last_at = at
	if moved >= TELEPORT_M or car.is_holding() or car.is_sinking() or car.is_righting():
		_air_s = 0.0
		_fall_mps = 0.0
		return
	var wheels := car.grounded_wheels()
	if wheels == 0:
		_air_s += delta
	if wheels < 2:
		_fall_mps = maxf(_fall_mps, -car.linear_velocity.y)
		return
	if _air_s >= LAND_AIR_S and _fall_mps >= LAND_MIN_MPS:
		Sound.play(LANDING, at, landing_strength(_fall_mps))
		_landed_at = _clock
	_air_s = 0.0
	_fall_mps = 0.0


## Whether a hit to car (its velocity change) is its landing's own: car, driven
## now, landed within LAND_HUSH_S and the change lies mostly along its up.
func landing_hushes(car: Node3D, change: Vector3) -> bool:
	return car == _car and _clock - _landed_at <= LAND_HUSH_S and absf(change.normalized().dot(car.global_transform.basis.y)) > LAND_HUSH_UP


## A landing's strength at the speed it came down at (m/s).
static func landing_strength(fall_mps: float) -> float:
	return clampf(0.35 + 0.65 * (fall_mps - LAND_MIN_MPS) / (LAND_FULL_MPS - LAND_MIN_MPS), 0.35, 1.0)


## How many of car's wheels stand on the shore's rocks (RIPRAP_KIND).
static func riprap_wheels(car: DrivableCar) -> int:
	var count := 0
	for i in 4:
		var ground: Object = car.wheel_ground(i)
		if is_instance_valid(ground) and ground is Node and str((ground as Node).get_meta("feature_kind", "")) == RIPRAP_KIND:
			count += 1
	return count


## Whether car's sliding tyres may squeal now (see STEER_SQUEAL_SHARE): its
## handbrake held, its pedal pressed against the way it rolls (a hard brake, as
## DrivableCar's braking), or its speed at STEER_SQUEAL_SHARE of its top speed or
## over. The tyres' slide alone (DrivableCar.slip) cannot tell steering from
## these: a turn at the grip's limit slides them as they do.
static func squeals(car: DrivableCar) -> bool:
	if car.handbrake:
		return true
	var along := car.forward_speed()
	if (car.drive_input < -0.1 and along > 1.0) or (car.drive_input > 0.1 and along < -1.0):
		return true
	return car.speed() >= STEER_SQUEAL_SHARE * car.top_speed()


## The rocks' rumble with wheels on them at speed (m/s): half with one wheel,
## full with two or more, by speed from RUMBLE_FROM_MPS (silent below) to
## RUMBLE_FULL_MPS.
static func rumble_level(wheels: int, speed: float) -> float:
	return clampf(wheels / 2.0, 0.0, 1.0) * smoothstep(RUMBLE_FROM_MPS, RUMBLE_FULL_MPS, speed)


## The idle, low and high loops' gains (x, y, z) at a rev (equal power between
## neighbours); a missing idle or high loop leaves its band to the low one.
static func engine_weights(rev: float, idle: bool = true, high: bool = true) -> Vector3:
	if rev <= LOW_REV:
		var t := clampf(rev / LOW_REV, 0.0, 1.0)
		return Vector3(cos(t * PI * 0.5), sin(t * PI * 0.5), 0.0) if idle else Vector3(0.0, 1.0, 0.0)
	var u := clampf((rev - LOW_REV) / (1.0 - LOW_REV), 0.0, 1.0)
	return Vector3(0.0, cos(u * PI * 0.5), sin(u * PI * 0.5)) if high else Vector3(0.0, 1.0, 0.0)


## The engine's virtual rev now (0..1), for tests.
func rev() -> float:
	return _rev
