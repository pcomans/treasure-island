class_name CarSound
extends RefCounted
## The driven car's sound (owner, 2026-11-14: one sound set for every drivable
## vehicle), for the vehicle manager (vehicle_manager.gd), which calls start when
## the player gets in, drive each physics tick while driving and stop when the
## player gets out. Only the driven car has these: a parked or shoved car has no
## sound of its own but its hits (vehicle_manager.gd _sound_impact).
##
## Getting in: the door opens and shuts, the engine starts, and its loops come in
## under the start's tail. Getting out: the engine stops, the door opens and
## shuts. The engine: three steady loops of the same car (idle, low, high),
## crossfaded (equal power) by a virtual rev made from the throttle and the speed
## over the body's top speed, each pitched within about a third of an octave of
## its take, never one loop across the whole range (tools/sfx/README.md). With
## the throttle down the rev runs a little above the speed's, and with the wheels
## in the air it follows the throttle alone; it rises in REV_UP_S and falls in
## REV_DOWN_S. A loop with no takes leaves its band to its neighbour, so a missing
## take never drops the engine out. The tyres: one skid loop whose gain follows the
## tyres' sliding speed (DrivableCar.slip, smoothed in SKID_UP_S and SKID_DOWN_S),
## so a flickering drift never restarts a sound. In the bay the engine dies.

const DOOR_CLOSE_S := 0.45
const ENGINE_START_S := 0.7
## The loops come in from ENGINE_LOOPS_S after getting in, over ENGINE_FADE_S.
const ENGINE_LOOPS_S := 0.9
const ENGINE_FADE_S := 0.5
const EXIT_DOOR_OPEN_S := 0.25
const EXIT_DOOR_CLOSE_S := 0.9
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
const IDLE := &"car_engine_idle_loop"
const LOW := &"car_engine_low_loop"
const HIGH := &"car_engine_high_loop"
const SKID := &"tyre_skid_loop"
## The engine and tyres follow the car this often (s): 30 times a second, which
## the loops' own smoothing makes continuous, at half the physics tick's cost.
const UPDATE_S := 1.0 / 30.0

var _car: DrivableCar
var _clock := 0.0
## The time gone by since the last update.
var _due := 0.0
var _rev := 0.0
var _skid := 0.0
var _engine := 0.0
## Whether the idle and high loops have takes (looked up once a drive).
var _has_idle := true
var _has_high := true


## The player got into car.
func start(car: DrivableCar) -> void:
	_car = car
	_clock = 0.0
	_due = UPDATE_S
	_rev = 0.0
	_skid = 0.0
	_engine = 0.0
	_has_idle = Sound.has_takes(IDLE)
	_has_high = Sound.has_takes(HIGH)
	# Where it is drawn: a car just put down (DrivableCar.place) moves its body at
	# the next physics step, its visual at once.
	Sound.play(&"car_door_open", car.visual_transform().origin)
	Sound.play_after(DOOR_CLOSE_S, &"car_door_close", car)
	Sound.play_after(ENGINE_START_S, &"car_engine_start", car)


## The player got out of car.
func stop(car: DrivableCar) -> void:
	if _engine > 0.0:
		Sound.play(&"car_engine_stop", car.visual_transform().origin)
	Sound.play_after(EXIT_DOOR_OPEN_S, &"car_door_open", car)
	Sound.play_after(EXIT_DOOR_CLOSE_S, &"car_door_close", car)
	for loop: StringName in [IDLE, LOW, HIGH, SKID]:
		Sound.release(loop, car)
	_car = null


## Each physics tick while driving car (it updates UPDATE_S apart).
func drive(car: DrivableCar, delta: float) -> void:
	if car != _car:
		start(car)
	_clock += delta
	_due += delta
	if _due < UPDATE_S:
		return
	var step := _due
	_due = 0.0
	var running := 0.0 if car.is_sinking() else clampf((_clock - ENGINE_LOOPS_S) / ENGINE_FADE_S, 0.0, 1.0)
	_engine = running
	var throttle := absf(car.drive_input) if absf(car.drive_input) > 0.1 and not car.is_holding() else 0.0
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
	var sliding := car.slip() if wheels >= 2 and speed > 1.5 else 0.0
	_skid = lerpf(_skid, sliding, 1.0 - exp(-step / (SKID_UP_S if sliding > _skid else SKID_DOWN_S)))
	Sound.hold(SKID, car, clampf((_skid - SKID_FROM_MPS) / SKID_RANGE_MPS, 0.0, 1.0), at, 0.95 + 0.1 * clampf(speed / 30.0, 0.0, 1.0))


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
