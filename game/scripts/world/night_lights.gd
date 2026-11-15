class_name NightLights
extends Node
## The lights that come on by themselves when it is dark (owner, 2026-11-15: "a
## flashlight that turns on by itself and headlights on the car you drive"; "can we
## just give the player a flashlight for now?"): the player's flashlight and the
## driven car's two headlights, with that car's own day-running and tail lamps lit
## while it is driven (DrivableCar.set_lamps_lit). No key and no touch button.
##
## They follow the look's darkness, DaySun.night (DayLight's night, 0 by day to 1 at
## night): on once it reaches ON_AT (with the sun about 5.5 degrees under the
## horizon), off again only once it is back under OFF_AT (about 4 degrees), so a
## clock dragged back and forth over the line does not flicker them, fading over
## FADE_S either way. By day nothing is made and nothing is done each frame.
##
## One switch, wanted(), says whether a run has them at all (owner, 2026-11-15:
## "all features that are relating to dynamic time of day ... behind some form of a
## feature flag"): main.gd makes this node only where it is on. With time of day
## off the look holds the recorded moment's daylight, so the rest of the night
## (stars, the parked cars' lamps, the Sun lighting the sky alone) stays off with it.
##
## The flashlight is one spot carried at the chest and pointed where the camera
## looks: the camera's heading, and its pitch at FLASH_PITCH_SHARE of the camera's
## below FLASH_PITCH_DEG, held between FLASH_PITCH_MIN_DEG and FLASH_PITCH_MAX_DEG.
## The third-person camera sits behind and above the chest looking the same way, so
## the lit patch lies ahead of the chest, in the lower middle of the view, whichever
## way the chest itself faces; the way the camera looks is where the player is
## going. It shines from FLASH_AHEAD_M in front of the chest (less if a wall is
## nearer, so it never starts inside one), at FLASH_HEIGHT_M, and casts shadows
## (FLASH_SHADOWS: 0.1 to 0.2 ms of GPU time on the dev machine's Radeon 780M in a
## park, at a building's door and at the ferry spawn, 2026-11-15), so it lights
## nothing through a wall. Hidden while the player is in a car. The headlights cast
## none: what they reach through a wall within HEAD_RANGE_M is behind that wall from
## the chase camera too.

## Darkness (DaySun.night) at which the lights come on, and back under which they go off.
const ON_AT := 0.5
const OFF_AT := 0.35
## Seconds to fade fully in or out.
const FADE_S := 1.2

const FLASH_HEIGHT_M := 1.25
const FLASH_AHEAD_M := 0.4
const FLASH_ENERGY := 5.0
const FLASH_RANGE_M := 30.0
## The cone's half angle (degrees) and how its light falls off toward the edge and
## with distance (SpotLight3D spot_attenuation, OmniLight-style light attenuation).
const FLASH_ANGLE_DEG := 30.0
const FLASH_ANGLE_ATTENUATION := 0.6
const FLASH_ATTENUATION := 1.0
const FLASH_PITCH_DEG := -6.0
const FLASH_PITCH_SHARE := 0.6
const FLASH_PITCH_MIN_DEG := -45.0
const FLASH_PITCH_MAX_DEG := -2.0
const FLASH_COLOR := Color(1.0, 0.95, 0.86)
const FLASH_SHADOWS := true

const HEAD_ENERGY := 7.0
const HEAD_RANGE_M := 60.0
const HEAD_ANGLE_DEG := 28.0
const HEAD_ANGLE_ATTENUATION := 0.7
const HEAD_ATTENUATION := 1.0
const HEAD_PITCH_DEG := -2.0
const HEAD_COLOR := Color(1.0, 0.96, 0.9)

## The world's solid ground and walls, which the flashlight never starts inside.
const WALLS_MASK := 1

var day_sun: DaySun
var player: PlayerController
var vehicles: VehicleManager
## Whether the lights are on (the darkness rule, with its hysteresis), and how far
## they have faded in: 0 off to 1 fully on.
var on := false
var level := 0.0
## The flashlight, made the first time it is needed (none by day).
var flashlight: SpotLight3D
## The car whose headlights are on, and its two headlights.
var car: DrivableCar
var headlights: Array[SpotLight3D] = []
var _ray := PhysicsRayQueryParameters3D.new()


func _init(sun: DaySun, the_player: PlayerController, the_vehicles: VehicleManager) -> void:
	day_sun = sun
	player = the_player
	vehicles = the_vehicles
	name = "NightLights"
	# The Options screen's time moves the light while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ray.collision_mask = WALLS_MASK
	_ray.hit_back_faces = false


## Whether this run has night lights at all: the one switch they hang off. For now
## the clock's own (DayClock.starts_pinned): none on the web and none in a test or
## capture run, which hold the recorded moment; such a driver opts in by making
## this node itself, as it opts in to another moment with DayClock.pin(). Point this
## at the time-of-day switch when it lands.
static func wanted() -> bool:
	return not DayClock.starts_pinned()


func _process(delta: float) -> void:
	update(delta)


## The rule and the fade for `delta` seconds, then every light put where it goes
## (tests call this with their own steps). By day, with every light off and none
## on a car, it does nothing more.
func update(delta: float) -> void:
	var night := day_sun.night if day_sun != null else 0.0
	if night <= 0.0 and level <= 0.0 and car == null:
		on = false
		return
	on = lights_on(night, on)
	level = move_toward(level, 1.0 if on else 0.0, delta / FADE_S)
	_update_flashlight()
	_update_headlights()


## Whether the lights are on at darkness `night`, given whether they were.
static func lights_on(night: float, was_on: bool) -> bool:
	return night >= ON_AT or (was_on and night > OFF_AT)


## The flashlight's pitch (degrees) for the camera's (its spring arm's, degrees).
static func flash_pitch(camera_pitch_deg: float) -> float:
	return clampf(FLASH_PITCH_DEG + FLASH_PITCH_SHARE * camera_pitch_deg, FLASH_PITCH_MIN_DEG, FLASH_PITCH_MAX_DEG)


func _update_flashlight() -> void:
	var shown := level > 0.0 and player != null and player.is_inside_tree() and player.visible and not player.is_driving()
	if not shown:
		if flashlight != null:
			flashlight.visible = false
		return
	if flashlight == null:
		flashlight = _spot("Flashlight", FLASH_COLOR, FLASH_RANGE_M, FLASH_ANGLE_DEG, FLASH_ANGLE_ATTENUATION, FLASH_ATTENUATION, FLASH_SHADOWS)
		add_child(flashlight)
	var rig := player.camera_rig
	var forward := -rig.global_basis.z
	forward.y = 0.0
	forward = forward.normalized() if forward.length_squared() > 1e-6 else Vector3.FORWARD
	var heading := Basis.looking_at(forward, Vector3.UP)
	var chest := player.global_position + Vector3.UP * FLASH_HEIGHT_M
	var ahead := FLASH_AHEAD_M
	_ray.from = chest
	_ray.to = chest + forward * FLASH_AHEAD_M
	_ray.exclude = [player.get_rid()]
	var hit := player.get_world_3d().direct_space_state.intersect_ray(_ray)
	if not hit.is_empty():
		ahead = maxf(0.0, chest.distance_to(hit.position) - 0.1)
	var pitch := flash_pitch(rad_to_deg(rig.spring_arm.rotation.x))
	flashlight.global_transform = Transform3D(heading * Basis(Vector3.RIGHT, deg_to_rad(pitch)), chest + forward * ahead)
	flashlight.light_energy = FLASH_ENERGY * level
	flashlight.visible = true


func _update_headlights() -> void:
	var driven: DrivableCar = vehicles.active_car() if vehicles != null else null
	if driven != car:
		_drop_headlights()
		car = driven
		if car != null and car.visual_root() != null:
			for mount: Vector3 in car.headlight_mounts():
				var lamp := _spot("Headlight", HEAD_COLOR, HEAD_RANGE_M, HEAD_ANGLE_DEG, HEAD_ANGLE_ATTENUATION, HEAD_ATTENUATION, false)
				lamp.transform = Transform3D(Basis(Vector3.RIGHT, deg_to_rad(HEAD_PITCH_DEG)), mount)
				car.visual_root().add_child(lamp)
				headlights.append(lamp)
			car.set_lamps_lit(true)
	for lamp: SpotLight3D in headlights:
		lamp.light_energy = HEAD_ENERGY * level
		lamp.visible = level > 0.0


## The headlights off the car that had them, and its own lamps back to the parked
## cars' (the player is out of it).
func _drop_headlights() -> void:
	for lamp: SpotLight3D in headlights:
		if is_instance_valid(lamp):
			lamp.queue_free()
	headlights.clear()
	if is_instance_valid(car):
		car.set_lamps_lit(false)
	car = null


static func _spot(node_name: String, color: Color, range_m: float, angle_deg: float, angle_attenuation: float, attenuation: float, shadows: bool) -> SpotLight3D:
	var spot := SpotLight3D.new()
	spot.name = node_name
	spot.light_color = color
	spot.spot_range = range_m
	spot.spot_angle = angle_deg
	spot.spot_angle_attenuation = angle_attenuation
	spot.spot_attenuation = attenuation
	spot.shadow_enabled = shadows
	spot.light_energy = 0.0
	spot.visible = false
	return spot
