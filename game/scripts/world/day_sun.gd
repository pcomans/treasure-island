class_name DaySun
extends Node
## Points main.tscn's Sun at the sun of the clock's instant (DayClock, SolarPosition),
## and puts on the light of that sun's height (DayLight): the Sun's colour and
## strength, the sky material's colours, the environment's ambient light, fog and
## exposure, and the global factors for the distant horizon and vegetation. The Sun's
## shadows stay ShadowQuality's. The sky draws its disc, halo and low-sun horizon
## from the light (bay_sky.gdshader).
##
## The light follows the sun all the way down and back up. As the disc sets the
## sunlight fades to nothing, the sky and the light through it pass through dusk,
## and from DayLight.FLOOR_ELEVATION_DEG down the night floor holds until dawn
## comes back up past it. Under the horizon the light still points at the sun,
## with no strength: the sky's twilight glow and the clouds' afterglow are drawn
## toward it. With no strength the Sun lights the sky alone (sky_mode SKY_ONLY), so
## its shadow splits stop rendering at night; ShadowQuality still owns whether it
## casts them. night, the look's darkness, is kept for the lights that follow it
## (NightLights).
##
## While time runs the sun moves in steps (step_seconds), not every frame: any
## change of the light or of the sky's material makes Godot redraw the sky's
## radiance map (ambient light and every reflection) over several frames, so a sun
## moved every frame would keep that redraw going all the time. A jump of the clock
## (the Options screen's date and time, Now, a test) moves it at once.
##
## With the time of day off (DayClock.enabled: its switch, and the web) it does
## nothing at all: no look is put on, so the Sun, the environment, the sky and the
## global uniforms stay main.tscn's and project.godot's, and no probe is captured
## again.

## Seconds of clock time between steps while time runs, with the sun at least
## FULL_STEP_ELEVATION_DEG up or down: the sun moves about 0.04 degrees in that
## time, a shadow's end a centimetre or two, and the radiance map redraws no more
## often than the clouds already make it (sky_weather.gd, every 10 s).
const STEP_S := 10.0
## Nearer the horizon, a step is shorter, with the square of the sine of the sun's
## height, down to MIN_STEP_S: a shadow's far end moves by the change in the sun's
## height over that square, and the light of dusk changes fastest there. With the
## sun 10.3 degrees up a 10 s step moved the end of a 9.2 m street lamp's shadow 10
## to 15 cm at once, 5 to 6 px seen from 7 m, a hop the eye catches (measured
## 2026-11-14). Lower still the same lamp's shadow is 105 m long at 5 degrees and
## 263 m at 2, and rounding the angles to ANGLE_STEP_DEG hopped its end 0.2 m and
## 1.3 m every 3 s or so; in half-second steps, with the angles kept to
## FINE_ANGLE_STEP_DEG under FULL_STEP_ELEVATION_DEG, it creeps 4 cm and 22 cm.
const FULL_STEP_ELEVATION_DEG := 30.0
const MIN_STEP_S := 0.5
## The angles are kept to this (degrees) from FULL_STEP_ELEVATION_DEG up: the
## precision main.tscn's Sun was set to, so at the recorded moment the light is
## exactly the scene's. The sun takes 2 s to move that far. Lower, to
## FINE_ANGLE_STEP_DEG.
const ANGLE_STEP_DEG := 0.01
const FINE_ANGLE_STEP_DEG := 0.001
## Reflection probes that capture once (Mersea's two, handed over by main.gd once
## startup has settled them) are captured again, while time runs, when the sun's
## height has moved this far (degrees) since their last capture, though not through
## the night floor, where the light stays the same; at most once every
## PROBE_RECAPTURE_S of real time, the last move caught up when that has passed. A
## capture of both added up to about 10 ms to one or two frames of a 50 ms view on
## the dev machine (2026-11-14), and the engine spreads its filtering over the next
## few frames. A
## held clock (a test's, a capture's, the web's) never captures them again, so a
## capture at other moments keeps the reflections the world loaded with.
const PROBE_RECAPTURE_DEG := 2.0
const PROBE_RECAPTURE_S := 5.0

## Where the look's global uniforms go: the RenderingServer, or a test's stand-in
## that records them (the engine gives a global's value back only in the editor).
static var set_global := Callable(RenderingServer, &"global_shader_parameter_set")

var sun: DirectionalLight3D
## Where the rest of the look goes: main.tscn's own environment and its sky
## material, kept from the start, so a neutral environment a capture swaps in is
## left alone. Null for a bare light (a test's).
var environment: Environment
var sky: ShaderMaterial
## The instant the sun is drawn for, and the clock's jump count then.
var shown_unix := NAN
## The sun's height (degrees) whose look is on now.
var lit_elevation := NAN
## How dark that look is (DayLight's night: 0 by day, 1 at night).
var night := 0.0
## The player's shadow option, which takes the look's shadow reach (main.gd sets
## it; null for a bare light, a test's).
var shadow_quality: ShadowQuality
var _revision := -1
## Seconds until the next step, for the sun as drawn now.
var _step := STEP_S
## The global uniforms as last set; the first look sets every one.
var _globals := {}
## The probes captured again as the light changes (watch_reflections), the sun's
## height at their last capture, when that was (Time.get_ticks_msec) and whether a
## capture waits on PROBE_RECAPTURE_S.
var reflection_probes: Array[ReflectionProbe] = []
var captured_elevation := NAN
var _captured_msec := 0
var _capture_due := false


func _init(scene_sun: DirectionalLight3D, scene_environment: Environment = null) -> void:
	sun = scene_sun
	environment = scene_environment
	if environment != null and environment.sky != null:
		sky = environment.sky.sky_material as ShaderMaterial
	name = "DaySun"
	# The Options screen's date and time move the sun while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	if not DayClock.enabled():
		set_process(false)
		return
	follow(true)


func _process(_delta: float) -> void:
	follow()
	if _capture_due and Time.get_ticks_msec() - _captured_msec >= int(PROBE_RECAPTURE_S * 1000.0):
		_capture_reflections()


## Points the sun at the clock's instant and puts on its light: at once after a
## jump of the clock, or when `now` is true; else once a step has gone by. Nothing
## with the time of day off.
func follow(now := false) -> void:
	if not DayClock.enabled():
		return
	var unix := DayClock.now()
	var revision := DayClock.revision()
	if not now and revision == _revision and absf(unix - shown_unix) < _step:
		return
	_revision = revision
	shown_unix = unix
	var angles := shown_angles(unix)
	sun.rotation_degrees = rotation_for(angles)
	light(angles[0])
	_step = step_for(angles[0])


## Puts on the look of a sun `elevation_deg` up (DayLight.at), writing only what
## differs from what is on (at the recorded moment, nothing but the global uniforms,
## which the first look always sets, to the values project.godot gives them).
func light(elevation_deg: float) -> void:
	if elevation_deg == lit_elevation:
		return
	lit_elevation = elevation_deg
	var look := DayLight.at(elevation_deg)
	night = float(look.night)
	for value: String in DayLight.SUN_PROPERTIES:
		_put(sun, DayLight.SUN_PROPERTIES[value], look[value])
	var mode := sky_mode_for(float(look.sun_energy))
	if sun.sky_mode != mode:
		sun.sky_mode = mode
	if shadow_quality != null:
		shadow_quality.set_reach(float(look.shadow_reach))
	if environment != null:
		for value: String in DayLight.ENVIRONMENT_PROPERTIES:
			_put(environment, DayLight.ENVIRONMENT_PROPERTIES[value], look[value])
	if sky != null:
		for value: String in DayLight.SKY_PARAMETERS:
			var parameter: StringName = DayLight.SKY_PARAMETERS[value]
			var current: Variant = sky.get_shader_parameter(parameter)
			if current == null:
				current = RenderingServer.shader_get_parameter_default(sky.shader.get_rid(), parameter)
			if not same(current, look[value]):
				sky.set_shader_parameter(parameter, look[value])
	for value: String in DayLight.GLOBALS:
		if not _globals.has(value) or not same(_globals[value], look[value]):
			_globals[value] = look[value]
			set_global.call(DayLight.GLOBALS[value], look[value])
	if DayClock.is_running() and not reflection_probes.is_empty() and absf(elevation_deg - captured_elevation) >= PROBE_RECAPTURE_DEG \
	and not (DayLight.is_floor(elevation_deg) and DayLight.is_floor(captured_elevation)):
		_capture_due = true


## Captures `probes` again as the light changes from now on (their capture now is
## the light on now).
func watch_reflections(probes: Array[ReflectionProbe]) -> void:
	reflection_probes = probes
	captured_elevation = lit_elevation
	_captured_msec = Time.get_ticks_msec()
	_capture_due = false


## Captures again every watched probe that captures once (one set to update always,
## as the neutral captures set Mersea's, is left alone).
func _capture_reflections() -> void:
	for probe: ReflectionProbe in reflection_probes:
		if is_instance_valid(probe) and probe.is_inside_tree() and probe.update_mode == ReflectionProbe.UPDATE_ONCE:
			probe.update_mode = ReflectionProbe.UPDATE_ONCE
	captured_elevation = lit_elevation
	_captured_msec = Time.get_ticks_msec()
	_capture_due = false


## The Sun's sky mode for its strength: the sky alone with none (no shadow splits
## drawn, the sky's light direction kept), light and sky otherwise (main.tscn's).
static func sky_mode_for(energy: float) -> DirectionalLight3D.SkyMode:
	return DirectionalLight3D.SKY_MODE_SKY_ONLY if energy <= 0.0 else DirectionalLight3D.SKY_MODE_LIGHT_AND_SKY


## The global uniforms to the RenderingServer again, after a test's stand-in.
static func use_engine_globals() -> void:
	set_global = Callable(RenderingServer, &"global_shader_parameter_set")


## Whether two of the look's values are the same, a colour's alpha aside (a sky
## colour may come back as a Vector3).
static func same(a: Variant, b: Variant) -> bool:
	if a is Vector3:
		a = Color(a.x, a.y, a.z)
	if b is Vector3:
		b = Color(b.x, b.y, b.z)
	if a is Color and b is Color:
		return is_equal_approx(a.r, b.r) and is_equal_approx(a.g, b.g) and is_equal_approx(a.b, b.b)
	if (a is float or a is int) and (b is float or b is int):
		return is_equal_approx(float(a), float(b))
	return false


func _put(object: Object, property: StringName, value: Variant) -> void:
	if not same(object.get(property), value):
		object.set(property, value)


## Seconds to the next step with the sun drawn `elevation_deg` up: step_seconds, but
## STEP_S through the night floor, whose light doesn't change (each step there would
## only turn a sun with no strength and redraw the radiance map for nothing).
static func step_for(elevation_deg: float) -> float:
	return STEP_S if DayLight.is_floor(elevation_deg) else step_seconds(elevation_deg)


## Seconds between steps with the sun drawn `elevation_deg` up (or down): STEP_S
## from FULL_STEP_ELEVATION_DEG either way, shorter nearer the horizon with the
## square of the sine of the height, at least MIN_STEP_S.
static func step_seconds(elevation_deg: float) -> float:
	var share := sin(deg_to_rad(elevation_deg)) / sin(deg_to_rad(FULL_STEP_ELEVATION_DEG))
	return clampf(STEP_S * share * share, MIN_STEP_S, STEP_S)


## A light's rotation_degrees shining from [elevation, azimuth] (degrees): worked
## out in 64 bits, so the recorded moment's (33.43, 190.32) gives main.tscn's Sun's
## (-33.43, -10.32, 0) to the bit (Vector2 and Vector3 hold 32-bit floats).
static func rotation_for(angles: Array[float]) -> Vector3:
	return Vector3(-angles[0], 180.0 - angles[1], 0.0)


## The sun's [elevation, azimuth] at `unix` (degrees, refracted, kept to
## angle_step), by day and by night.
static func shown_angles(unix: float) -> Array[float]:
	var position := SolarPosition.at(unix, DayClock.LATITUDE, DayClock.LONGITUDE)
	var step := angle_step(float(position.elevation_deg))
	var kept: Array[float] = [snappedf(float(position.elevation_deg), step), snappedf(float(position.azimuth_deg), step)]
	return kept


## What the angles are kept to with the sun `elevation_deg` up (degrees).
static func angle_step(elevation_deg: float) -> float:
	return ANGLE_STEP_DEG if elevation_deg >= FULL_STEP_ELEVATION_DEG else FINE_ANGLE_STEP_DEG
