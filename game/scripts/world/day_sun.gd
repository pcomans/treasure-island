class_name DaySun
extends Node
## Points main.tscn's Sun at the sun of the clock's instant (DayClock, SolarPosition).
## Only its direction moves: its colour, energy and shadows stay main.tscn's (the
## shadows' quality is ShadowQuality's), and so do the sky's, fog's and ambient
## light's settings; the sky draws its disc, halo and low-sun horizon from the light
## (bay_sky.gdshader).
##
## While time runs the sun moves in steps of STEP_S, not every frame: any change of
## the light makes Godot redraw the sky's radiance map (ambient light and every
## reflection) over several frames, so a sun moved every frame would keep that
## redraw going all the time. A jump of the clock (the Options screen's date and
## time, Now, a test) moves it at once.

## Daylight only, until dusk and night are drawn (later updates, owner 2026-11-14):
## with the true sun lower than this (degrees), the light stays where the sun
## crossed this height that evening, or will cross it next morning, so a night
## shows a low sun on the right side of the sky rather than a light from below the
## ground. Ten degrees keeps the light within what the sky shader draws for a low sun
## (its horizon tint is near full from about 10 degrees) and its shadows about six
## times longer than they are tall.
const DAYLIGHT_MIN_ELEVATION_DEG := 10.0
## Seconds of clock time between steps while time runs: at real speed the sun moves
## about 0.04 degrees in that time, so even the long shadows of a sun 10 degrees up
## move only centimetres a step, and the radiance map redraws no more often than
## the clouds already make it (sky_weather.gd, every 10 s).
const STEP_S := 10.0
## The angles are kept to this (degrees): the precision main.tscn's Sun was set to,
## so at the recorded moment the light is exactly the scene's. The sun takes 2 s to
## move that far.
const ANGLE_STEP_DEG := 0.01

var sun: DirectionalLight3D
## Seconds between steps (STEP_S; a test may shorten it).
var step_s := STEP_S
## The instant the sun is drawn for, and the clock's jump count then.
var shown_unix := NAN
var _revision := -1


func _init(scene_sun: DirectionalLight3D) -> void:
	sun = scene_sun
	name = "DaySun"
	# The Options screen's date and time move the sun while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	follow(true)


func _process(_delta: float) -> void:
	follow()


## Points the sun at the clock's instant: at once after a jump of the clock, or
## when `now` is true; else once a step has gone by.
func follow(now := false) -> void:
	var unix := DayClock.now()
	var revision := DayClock.revision()
	if not now and revision == _revision and absf(unix - shown_unix) < step_s:
		return
	_revision = revision
	shown_unix = unix
	sun.rotation_degrees = rotation_for(shown_angles(unix))


## A light's rotation_degrees shining from [elevation, azimuth] (degrees): worked
## out in 64 bits, so the recorded moment's (33.43, 190.32) gives main.tscn's Sun's
## (-33.43, -10.32, 0) to the bit (Vector2 and Vector3 hold 32-bit floats).
static func rotation_for(angles: Array[float]) -> Vector3:
	return Vector3(-angles[0], 180.0 - angles[1], 0.0)


## Whether the true sun is below the daylight drawn at `unix`, so the light is held
## at the edge of it.
static func is_held(unix: float) -> bool:
	return float(SolarPosition.at(unix, DayClock.LATITUDE, DayClock.LONGITUDE).elevation_deg) < DAYLIGHT_MIN_ELEVATION_DEG


## The sun's [elevation, azimuth] as drawn at `unix` (degrees, kept to
## ANGLE_STEP_DEG): the true sun in daylight; below DAYLIGHT_MIN_ELEVATION_DEG, the
## sun where it crossed that height after the last solar noon (the evening), or
## will cross it before the next (the morning).
static func shown_angles(unix: float) -> Array[float]:
	var sun_now := SolarPosition.at(unix, DayClock.LATITUDE, DayClock.LONGITUDE)
	if float(sun_now.elevation_deg) >= DAYLIGHT_MIN_ELEVATION_DEG:
		return _kept(sun_now)
	# Solar noon is where the hour angle is 0; it turns 15 degrees an hour.
	var low := unix
	var high := unix - float(sun_now.hour_angle_deg) / 15.0 * 3600.0
	var noon := SolarPosition.at(high, DayClock.LATITUDE, DayClock.LONGITUDE)
	if float(noon.elevation_deg) < DAYLIGHT_MIN_ELEVATION_DEG:
		# A day whose sun never climbs that high (never at the island's latitude).
		var edge: Array[float] = [DAYLIGHT_MIN_ELEVATION_DEG, snappedf(float(noon.azimuth_deg), ANGLE_STEP_DEG)]
		return edge
	# The crossing lies between now (below) and that noon (above): halved 24 times,
	# to within a few thousandths of a second.
	for _halving in 24:
		var middle := 0.5 * (low + high)
		if float(SolarPosition.at(middle, DayClock.LATITUDE, DayClock.LONGITUDE).elevation_deg) >= DAYLIGHT_MIN_ELEVATION_DEG:
			high = middle
		else:
			low = middle
	return _kept(SolarPosition.at(high, DayClock.LATITUDE, DayClock.LONGITUDE))


static func _kept(position: Dictionary) -> Array[float]:
	var kept: Array[float] = [snappedf(float(position.elevation_deg), ANGLE_STEP_DEG), snappedf(float(position.azimuth_deg), ANGLE_STEP_DEG)]
	return kept
