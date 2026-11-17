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
## They hang off the time of day's one switch (DayClock.enabled; owner, 2026-11-15:
## "all features that are relating to dynamic time of day ... behind some form of a
## feature flag"): main.gd makes this node only where wanted(), and one made with
## the switch off does nothing (_ready). With the switch off DaySun puts on no look,
## so the rest of the night (the stars, the parked cars' lamps put out, the Sun
## lighting the sky alone, the buildings' daylight fills put out) stays off with it.
##
## The flashlight is a spot carried at the chest and pointed where the camera
## looks: the camera's heading, and its pitch at FLASH_PITCH_SHARE of the camera's
## below FLASH_PITCH_DEG, held between FLASH_PITCH_MIN_DEG and FLASH_PITCH_MAX_DEG.
## The third-person camera sits behind and above the chest looking the same way, so
## the lit patch lies ahead of the chest, in the lower middle of the view, whichever
## way the chest itself faces; the way the camera looks is where the player is
## going. On flat ground its beam reaches about 20 m ahead, with a soft edge, and a
## faint wide spill (SPILL_*) lights a few metres round the player. It shines from
## FLASH_AHEAD_M in front of the chest (less if a wall is nearer, so it never starts
## inside one), at FLASH_HEIGHT_M, and casts shadows when the player's shadow option
## is not Off (ShadowQuality; about 0.1 to 0.2 ms of GPU time on the dev machine's
## Radeon 780M, 2026-11-15), so it lights nothing through a wall. The chest casts no
## shadow in it (owner, 2026-11-17: "exclude Chester from things that can cast shadows
## from a flashlight"). It shines from just in front of the closed lid's front edge:
## speeding up into a run the chest leans forward and its sprung lid swings open,
## which brought that edge to within a few centimetres of the light, in front of it,
## blacking out most of the beam and flickering with the gait's bob (the limbs stay
## outside the beam's cone). Once the flashlight is made the chest's meshes are on
## CHEST_LAYER alone, which the flashlight's shadow caster mask leaves out: it still
## lights the chest, everything else still shadows its beam, and the Sun lights the
## chest and casts its shadow as before. A small fill on the chest itself (FILL_*),
## lighting only the chest (CHEST_LAYER is its cull mask), shows its back and lid in
## front of the beam. Hidden while the player is in a car. The headlights cast no
## shadows: what they reach through a wall within HEAD_RANGE_M is behind that wall
## from the chase camera too.

## Darkness (DaySun.night) at which the lights come on, and back under which they go off.
const ON_AT := 0.5
const OFF_AT := 0.35
## Seconds to fade fully in or out.
const FADE_S := 1.2

const FLASH_HEIGHT_M := 1.25
const FLASH_AHEAD_M := 0.4
const FLASH_ENERGY := 2.2
const FLASH_RANGE_M := 48.0
## The cone's half angle (degrees) and how its light falls off toward the edge and
## with distance (SpotLight3D spot_angle_attenuation, spot_attenuation: under 1 a
## softer edge and a gentler fall with distance). The fall with distance is gentle
## so that ground 20 m ahead stays lit without a pale wall a few metres away
## burning to white.
const FLASH_ANGLE_DEG := 40.0
const FLASH_ANGLE_ATTENUATION := 0.5
const FLASH_ATTENUATION := 0.35
const FLASH_PITCH_DEG := -2.0
const FLASH_PITCH_SHARE := 0.5
const FLASH_PITCH_MIN_DEG := -45.0
const FLASH_PITCH_MAX_DEG := -1.0
const FLASH_COLOR := Color(1.0, 0.95, 0.86)
## The spill: a wide, faint cone round the beam, at SPILL_SHARE of its energy.
const SPILL_ANGLE_DEG := 60.0
const SPILL_SHARE := 0.2
const SPILL_RANGE_M := 12.0
## The chest's fill: a small omni light behind and above the chest on the camera's
## side, lighting only what is on CHEST_LAYER (the chest's meshes).
const FILL_ENERGY := 0.4
const FILL_RANGE_M := 2.6
const FILL_BACK_M := 0.9
const FILL_UP_M := 1.5
## The chest's own render layer (layer 20, "avatar_fill" in project.godot), which
## nothing else in the game is on. The engine leaves a mesh out of a light's shadows
## when none of the mesh's layers is in that light's shadow caster mask, so once the
## flashlight is made the chest's meshes are on this layer alone (off layer 1,
## world_visible), and the flashlight's mask is every layer but this one. The cameras
## draw every layer; the Sun's and the flashlight's light cull masks and the Sun's
## shadow caster mask keep all of them.
const CHEST_LAYER := 1 << 19
const FLASH_SHADOW_CASTERS := 0xFFFFFFFF & ~CHEST_LAYER

const HEAD_ENERGY := 8.0
const HEAD_RANGE_M := 75.0
const HEAD_ANGLE_DEG := 28.0
const HEAD_ANGLE_ATTENUATION := 0.7
const HEAD_ATTENUATION := 0.8
const HEAD_PITCH_DEG := -2.0
const HEAD_COLOR := Color(1.0, 0.96, 0.9)

## The world's solid ground and walls, which the flashlight never starts inside.
const WALLS_MASK := 1

var day_sun: DaySun
var player: PlayerController
var vehicles: VehicleManager
## The player's shadow option: the flashlight casts shadows unless it is Off.
var shadows: ShadowQuality
## Whether the lights are on (the darkness rule, with its hysteresis), and how far
## they have faded in: 0 off to 1 fully on.
var on := false
var level := 0.0
## The flashlight, its spill and the chest's fill, made the first time they are
## needed (none by day).
var flashlight: SpotLight3D
var spill: SpotLight3D
var fill: OmniLight3D
## The car whose headlights are on, and its two headlights.
var car: DrivableCar
var headlights: Array[SpotLight3D] = []
var _ray := PhysicsRayQueryParameters3D.new()
## The chest and heading the wall's pull-back was last found for, and its result.
var _ray_chest := Vector3.INF
var _ray_forward := Vector3.ZERO
var _ahead := FLASH_AHEAD_M


func _init(sun: DaySun, the_player: PlayerController, the_vehicles: VehicleManager, the_shadows: ShadowQuality = null) -> void:
	day_sun = sun
	player = the_player
	vehicles = the_vehicles
	shadows = the_shadows
	name = "NightLights"
	# The Options screen's time moves the light while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ray.collision_mask = WALLS_MASK
	_ray.hit_back_faces = false
	if player != null:
		_ray.exclude = [player.get_rid()]


## Whether this run has night lights at all: with the time of day on
## (DayClock.enabled: not with its switch off, nor on the web) and not in a test or
## capture run (DayClock.scripted), which holds the recorded moment; such a driver
## opts in by making this node itself, as it opts in to another moment with
## DayClock.pin().
static func wanted() -> bool:
	return DayClock.enabled() and not DayClock.scripted()


## With the time of day off this node does nothing at all, even where a driver makes
## it: no process, no light.
func _ready() -> void:
	if not DayClock.enabled():
		set_process(false)


func _process(delta: float) -> void:
	update(delta)


## The rule and the fade for `delta` seconds, then every light put where it goes
## (tests call this with their own steps). By day, with every light off and none
## on a car, it does nothing more; with the time of day off, nothing at all.
func update(delta: float) -> void:
	if not DayClock.enabled():
		return
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


## Whether the flashlight casts shadows: unless the player's shadow option is Off.
func flash_shadows() -> bool:
	return shadows == null or shadows.current != "off"


func _update_flashlight() -> void:
	var shown := level > 0.0 and player != null and player.is_inside_tree() and player.visible and not player.is_driving()
	if not shown:
		if flashlight != null:
			flashlight.visible = false
			fill.visible = false
		return
	if flashlight == null:
		_make_flashlight()
	var rig := player.camera_rig
	var forward := -rig.global_basis.z
	forward.y = 0.0
	forward = forward.normalized() if forward.length_squared() > 1e-6 else Vector3.FORWARD
	var heading := Basis.looking_at(forward, Vector3.UP)
	var chest := player.global_position + Vector3.UP * FLASH_HEIGHT_M
	# Pulled back before a wall: looked for again only once the chest or the
	# heading has moved.
	if chest.distance_squared_to(_ray_chest) > 1e-4 or forward.dot(_ray_forward) < 0.99995:
		_ray_chest = chest
		_ray_forward = forward
		_ray.from = chest
		_ray.to = chest + forward * FLASH_AHEAD_M
		var hit := player.get_world_3d().direct_space_state.intersect_ray(_ray)
		_ahead = FLASH_AHEAD_M if hit.is_empty() else maxf(0.0, chest.distance_to(hit.position) - 0.1)
	var pitch := flash_pitch(rad_to_deg(rig.spring_arm.rotation.x))
	flashlight.global_transform = Transform3D(heading * Basis(Vector3.RIGHT, deg_to_rad(pitch)), chest + forward * _ahead)
	flashlight.light_energy = FLASH_ENERGY * level
	spill.light_energy = FLASH_ENERGY * SPILL_SHARE * level
	var cast := flash_shadows()
	if flashlight.shadow_enabled != cast:
		flashlight.shadow_enabled = cast
	flashlight.visible = true
	fill.global_position = player.global_position + Vector3.UP * FILL_UP_M - forward * FILL_BACK_M
	fill.light_energy = FILL_ENERGY * level
	fill.visible = true


## The flashlight with its spill (riding with it), and the chest's fill, which
## lights only the chest's meshes. They go on CHEST_LAYER alone, which the
## flashlight's shadows leave out; Mersea's reflection probes, which draw layers 1
## and 2, leave the chest out of their captures from then on.
func _make_flashlight() -> void:
	flashlight = _spot("Flashlight", FLASH_COLOR, FLASH_RANGE_M, FLASH_ANGLE_DEG, FLASH_ANGLE_ATTENUATION, FLASH_ATTENUATION, flash_shadows())
	flashlight.shadow_caster_mask = FLASH_SHADOW_CASTERS
	add_child(flashlight)
	spill = _spot("Spill", FLASH_COLOR, SPILL_RANGE_M, SPILL_ANGLE_DEG, 1.0, 1.0, false)
	spill.visible = true
	flashlight.add_child(spill)
	fill = OmniLight3D.new()
	fill.name = "ChestFill"
	fill.light_color = FLASH_COLOR
	fill.omni_range = FILL_RANGE_M
	fill.light_cull_mask = CHEST_LAYER
	fill.shadow_enabled = false
	fill.light_energy = 0.0
	fill.visible = false
	add_child(fill)
	for piece: Node in player.avatar_pivot.find_children("*", "GeometryInstance3D", true, false):
		(piece as GeometryInstance3D).layers = CHEST_LAYER


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


static func _spot(node_name: String, color: Color, range_m: float, angle_deg: float, angle_attenuation: float, attenuation: float, cast_shadows: bool) -> SpotLight3D:
	var spot := SpotLight3D.new()
	spot.name = node_name
	spot.light_color = color
	spot.spot_range = range_m
	spot.spot_angle = angle_deg
	spot.spot_angle_attenuation = angle_attenuation
	spot.spot_attenuation = attenuation
	spot.shadow_enabled = cast_shadows
	spot.light_energy = 0.0
	spot.visible = false
	return spot
