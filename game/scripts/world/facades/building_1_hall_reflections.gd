class_name Building1HallReflections
extends Node
## Building 1's hall: real reflections in its polished terrazzo, a trial on Forward+
## (the interior's config "reflections", built by building_1_interior.gd). Off by
## default (mode "off"); "inside" turns them on while the camera is in the hall,
## "always" anywhere. The web's Compatibility renderer never has them: there the
## floor keeps the polish baked into its vertex shading, as with the trial off.
##
## While on it
## - turns the world environment's screen-space reflections on with this hall's
##   settings (ssr_max_steps, ssr_fade_in, ssr_fade_out, ssr_depth_tolerance) and puts
##   the environment's own back when off;
## - polishes the terrazzo (floor_roughness, floor_specular; floor_albedo tints its
##   colour, channel by channel, since the reflections now add light of their own);
## - unless baked_sheen, swaps the floor's vertex colours for plain_floor, its baked
##   shading without the painted window streaks and dark pier reflections, which the
##   real reflections replace (data only: the same shader draws both);
## - with probes, reflects the hall itself wherever the screen has nothing to reflect.
##   Without them the polished floor reflects the sky's radiance there, unoccluded by
##   the roof: the milky, sky-tinted floor of the first trial (work sheets ssr-trial).
##   probe_sections box-projected reflection probes along the crescent, each seeing
##   and reflecting on the interior render layer only, so nothing outside the hall
##   is drawn into them or lit by them. They are made once the mural has loaded near
##   the door (Building1MuralLoader, so they capture it) and freed when it is
##   released, but reflect nothing (intensity 0) until the camera is in, so the hall
##   seen through its door is as before; they capture again as the sun moves
##   (RECAPTURE_DEG), the hall's light following the sky's. Neighbouring boxes overlap
##   and blend over probe_blend metres. Headless runs and the web make none.

## Render layer 6 ("interior"): the hall draws on it alone (building_1_interior.gd).
const RENDER_INTERIOR := 1 << 5
## The sun's move (degrees) after which the probes capture again, as DaySun's for
## Mersea's.
const RECAPTURE_DEG := 2.0
## A probe's weight fades to nothing over its blend distance inside each face of its
## box, so the boxes reach that and this much more (m) below the floor and past the
## hall's walls and each other's: the floor has full probe weight everywhere.
const PROBE_MARGIN_M := 0.5

@export var mode := "off"
## The inside test: the hall's plan about the crescent's centre (centre x, centre z,
## inner radius, outer radius), its angles (from, to) and the height below which the
## camera is in it.
@export var hall := Vector4.ZERO
@export var hall_angles := Vector2.ZERO
@export var top_y := 0.0
@export var ssr := true
@export var ssr_max_steps := 64
@export var ssr_fade_in := 0.15
@export var ssr_fade_out := 2.0
@export var ssr_depth_tolerance := 0.2
@export var floor_roughness := 0.15
@export var floor_specular := 0.5
@export var floor_albedo := Color.WHITE
@export var baked_sheen := true
## The terrazzo's vertex colours without its baked sheen, RGBA8 (4 bytes a vertex,
## in the surface's vertex order, as the engine keeps vertex colours).
@export var plain_floor := PackedByteArray()
@export var probes := false
@export var probe_sections := 4
@export var probe_intensity := 1.0
## The probes' blend distance (m): neighbours fade into each other over it.
@export var probe_blend := 1.0
## What the probes' boxes hold: from the inner to the outer radius about the
## crescent's centre and from the floor to the ceiling (x, y, z, w), over hall_angles;
## the boxes reach probe_blend and PROBE_MARGIN_M past it but for the ceiling, their top.
@export var probe_box := Vector4.ZERO
## Where the probes capture, this high over the floor.
@export var probe_capture_height := 4.0

## The settings last applied, compared each frame (a trial: they may change in play).
var _applied: Array = []
var _on := false
var _shell: MeshInstance3D
var _floor: BaseMaterial3D
var _floor_surface := -1
var _floor_matte := {}
## The environment's own reflection settings, from before this turned them on.
var _environment: Environment
var _environment_own := {}
## The floor surface's attribute data as built, and with plain_floor's colours.
var _sheen_bytes := PackedByteArray()
var _plain_bytes := PackedByteArray()
var _plain_shown := false
var _probes: Array[ReflectionProbe] = []
## The layout the probes were made for: remade when it changes.
var _probe_layout: Array = []
var _captured_elevation := NAN


func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility" or DisplayServer.get_name() == "headless":
		set_process(false)
		return
	_shell = get_parent().get_node_or_null("Shell") as MeshInstance3D
	if _shell == null or _shell.mesh == null:
		set_process(false)
		return
	for surface in _shell.mesh.get_surface_count():
		if _shell.mesh.surface_get_name(surface) == "terrazzo":
			_floor_surface = surface
			_floor = _shell.mesh.surface_get_material(surface) as BaseMaterial3D
	if _floor != null:
		_floor_matte = {"roughness": _floor.roughness, "specular": _floor.metallic_specular, "albedo": _floor.albedo_color}


func _process(_delta: float) -> void:
	if (mode == "off" and not _on and _probes.is_empty()) or not _play_started():
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var settings := [mode, ssr, ssr_max_steps, ssr_fade_in, ssr_fade_out, ssr_depth_tolerance, floor_roughness, floor_specular, floor_albedo, baked_sheen]
	var on := mode == "always" or (mode == "inside" and inside(camera.global_position))
	if on != _on or settings != _applied:
		_apply(on)
		_applied = settings
	_update_probes()


## Whether a point is in the hall (mode "inside").
func inside(at: Vector3) -> bool:
	var offset := Vector2(at.x - hall.x, at.z - hall.y)
	var angle := atan2(offset.y, offset.x)
	return offset.length() > hall.z and offset.length() < hall.w and angle > hall_angles.x and angle < hall_angles.y and at.y < top_y


func _apply(on: bool) -> void:
	var environment := _world_environment()
	if environment != null:
		if on and _environment != environment:
			_environment = environment
			_environment_own = {"ssr_enabled": environment.ssr_enabled, "ssr_max_steps": environment.ssr_max_steps, "ssr_fade_in": environment.ssr_fade_in, "ssr_fade_out": environment.ssr_fade_out, "ssr_depth_tolerance": environment.ssr_depth_tolerance}
		if _environment != null:
			var values := _environment_own
			if on and ssr:
				values = {"ssr_enabled": true, "ssr_max_steps": ssr_max_steps, "ssr_fade_in": ssr_fade_in, "ssr_fade_out": ssr_fade_out, "ssr_depth_tolerance": ssr_depth_tolerance}
			for property: String in values:
				_environment.set(property, values[property])
			if not on:
				_environment = null
	if _floor != null:
		_floor.roughness = floor_roughness if on else float(_floor_matte.roughness)
		_floor.metallic_specular = floor_specular if on else float(_floor_matte.specular)
		var albedo: Color = _floor_matte.albedo
		_floor.albedo_color = Color(albedo.r * floor_albedo.r, albedo.g * floor_albedo.g, albedo.b * floor_albedo.b, albedo.a) if on else albedo
	_show_plain_floor(on and not baked_sheen)
	_on = on


## The world's environment: the viewport's World3D's, else main.tscn's WorldEnvironment
## node's (a capture may swap that one's for its own).
func _world_environment() -> Environment:
	var world := get_viewport().world_3d
	if world != null and world.environment != null:
		return world.environment
	var node := get_tree().root.find_child("WorldEnvironment", true, false) as WorldEnvironment
	return node.environment if node != null else null


## Puts the floor's plain colours up, or its baked ones back. The first time, reads the
## surface's attribute data from the renderer (its vertex colours sit among the other
## attributes) and keeps both versions.
func _show_plain_floor(plain: bool) -> void:
	if plain == _plain_shown or _floor_surface < 0:
		return
	if _plain_bytes.is_empty():
		var surface := RenderingServer.mesh_get_surface(_shell.mesh.get_rid(), _floor_surface)
		var count := int(surface.get("vertex_count", 0))
		var format := int(surface.get("format", 0))
		var data: PackedByteArray = surface.get("attribute_data", PackedByteArray())
		var stride := RenderingServer.mesh_surface_get_format_attribute_stride(format, count)
		var offset := RenderingServer.mesh_surface_get_format_offset(format, count, RenderingServer.ARRAY_COLOR)
		if count == 0 or plain_floor.size() != count * 4 or data.size() < count * stride or (format & RenderingServer.ARRAY_FORMAT_COLOR) == 0:
			push_warning("Building 1 hall reflections: the floor's colours do not match its surface (%d vertices, %d plain colours); its baked sheen stays." % [count, plain_floor.size() / 4])
			_floor_surface = -1
			return
		_sheen_bytes = data
		_plain_bytes = data.duplicate()
		for index in count:
			for channel in 4:
				_plain_bytes[index * stride + offset + channel] = plain_floor[index * 4 + channel]
	RenderingServer.mesh_surface_update_attribute_region(_shell.mesh.get_rid(), _floor_surface, 0, _plain_bytes if plain else _sheen_bytes)
	_plain_shown = plain


## The probes: made once the mural is up near the door while the reflections may come
## on, freed when it goes or they are switched off; captured again as the sun moves.
func _update_probes() -> void:
	var loader := get_parent().get_node_or_null("MuralLoader") as Building1MuralLoader
	var wanted := mode != "off" and probes and loader != null and loader.state == Building1MuralLoader.State.LOADED
	var layout := [probe_sections, probe_blend, probe_capture_height, probe_box]
	if not wanted or layout != _probe_layout:
		for probe in _probes:
			probe.queue_free()
		_probes.clear()
		_probe_layout = []
		if not wanted:
			return
	if _probes.is_empty():
		_make_probes()
		_probe_layout = layout
		_captured_elevation = _sun_elevation()
	var intensity := probe_intensity if _on else 0.0
	for probe in _probes:
		if probe.intensity != intensity:
			probe.intensity = intensity
	var elevation := _sun_elevation()
	if absf(elevation - _captured_elevation) >= RECAPTURE_DEG:
		for probe in _probes:
			probe.update_mode = ReflectionProbe.UPDATE_ONCE
		_captured_elevation = elevation


func _make_probes() -> void:
	var parent := get_parent() as Node3D
	var center := Vector2(hall.x, hall.y)
	var sections := maxi(1, probe_sections)
	var span := (hall_angles.y - hall_angles.x) / float(sections)
	var half := span * 0.5
	var margin := probe_blend + PROBE_MARGIN_M
	var bottom := probe_box.z - margin
	var top := probe_box.w
	for index in sections:
		var theta := hall_angles.x + span * (float(index) + 0.5)
		# Each box covers its share of the crescent, from the inner arc's ends (its
		# chord) to the outer arc and as wide as the outer arc's chord, and the margin.
		var inner := probe_box.x * cos(half) - margin
		var outer := probe_box.y + margin
		var radial := Vector3(cos(theta), 0.0, sin(theta))
		var probe := ReflectionProbe.new()
		probe.name = "HallReflection%d" % index
		probe.size = Vector3(2.0 * probe_box.y * sin(half) + 2.0 * margin, top - bottom, outer - inner)
		probe.origin_offset = Vector3(0.0, probe_box.z + probe_capture_height - (bottom + top) * 0.5, 0.0)
		probe.blend_distance = probe_blend
		probe.box_projection = true
		probe.interior = false
		probe.intensity = 0.0
		probe.ambient_mode = ReflectionProbe.AMBIENT_DISABLED
		probe.cull_mask = RENDER_INTERIOR
		probe.reflection_mask = RENDER_INTERIOR
		probe.enable_shadows = false
		# It sees the whole hall from its share of it.
		probe.max_distance = 2.0 * outer
		probe.update_mode = ReflectionProbe.UPDATE_ONCE
		parent.add_child(probe)
		var mid := (inner + outer) * 0.5
		# Local +z points out from the crescent's centre, +x along the hall.
		probe.global_transform = Transform3D(Basis.looking_at(-radial, Vector3.UP), Vector3(center.x + mid * radial.x, (bottom + top) * 0.5, center.y + mid * radial.z))
		_probes.append(probe)


func _sun_elevation() -> float:
	return DaySun.shown_angles(DayClock.now())[0]


func _play_started() -> bool:
	var main := get_tree().root.get_node_or_null("Main")
	return main != null and main.has_method("is_play_ready") and bool(main.call("is_play_ready"))
