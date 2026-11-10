class_name SkyWeather
extends WorldEnvironment
## Moves the sky's clouds (game/resources/materials/world/sky/bay_sky.gdshader).
##
## The shader reads no TIME, so Godot does not redraw the sky's radiance map (the
## source of ambient light and reflections) every frame. Instead this node sets
## the global shader uniform sky_cloud_drift each frame, which the visible sky
## follows at no extra cost, and every reflection_refresh_s seconds copies it to
## the material's reflection_cloud_drift, which makes Godot redraw the radiance
## map once, spread over a few frames (the Sky's incremental process mode).

## The drift wraps at the shader's largest noise tile (WEATHER_TILE_M) and the
## rise at the height of its shape tile (SHAPE_TILE_M / 2), so neither jumps.
const DRIFT_WRAP_M := 72000.0
const RISE_WRAP_M := 4500.0

## Clouds drift toward this bearing (clockwise from north), with the bay's
## prevailing westerly (the water's wind_bearing_deg).
@export var wind_bearing_deg := 80.0
@export var wind_speed_mps := 9.0
## How fast the clouds change shape: metres a second they rise through the noise.
@export var rise_mps := 0.6
@export var reflection_refresh_s := 10.0

var _seconds := 0.0
var _held := false
var _since_refresh := 0.0


func _ready() -> void:
	_apply(true)


func _process(delta: float) -> void:
	if _held:
		return
	_seconds += delta
	_since_refresh += delta
	_apply(_since_refresh >= reflection_refresh_s)


## Stops the clouds where they stand `seconds` into their drift, in the sky and
## in its reflections: review screenshots hold them still so pairs match.
func hold_at(seconds: float) -> void:
	_seconds = seconds
	_held = true
	_apply(true)


## Lets the clouds drift again from where they stand.
func release() -> void:
	_held = false


func drift_seconds() -> float:
	return _seconds


func _apply(refresh_reflection: bool) -> void:
	var bearing := deg_to_rad(wind_bearing_deg)
	var along := _seconds * wind_speed_mps
	var drift := Vector3(
		fposmod(sin(bearing) * along, DRIFT_WRAP_M),
		fposmod(_seconds * rise_mps, RISE_WRAP_M),
		fposmod(-cos(bearing) * along, DRIFT_WRAP_M))
	RenderingServer.global_shader_parameter_set(&"sky_cloud_drift", drift)
	if not refresh_reflection or environment == null or environment.sky == null:
		return
	var material := environment.sky.sky_material as ShaderMaterial
	if material != null:
		material.set_shader_parameter(&"reflection_cloud_drift", drift)
	_since_refresh = 0.0
