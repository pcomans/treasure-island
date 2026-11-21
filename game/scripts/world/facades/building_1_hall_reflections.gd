class_name Building1HallReflections
extends Node
## Building 1's hall: real reflections in its polished terrazzo on desktop, from the
## interior's config "reflections" (building_1_interior.gd builds this node). Mode
## "inside" turns them on while the camera is in the hall, "always" anywhere (for
## captures), "off" never. Only Forward+ draws them, and never in a headless run:
## anywhere else (the web's Compatibility renderer) this node does nothing at all, and
## the floor keeps the polish baked into its vertex shading.
##
## They fade in and out with the hall's InteriorPresence (game/scripts/world/interiors/
## interior_presence.gd, the "Presence" beside this node): its blend, 0 for the floor
## as built to 1 polished, eased over its fade_s (0.5 s), turning round wherever it is
## when the camera does. "always" and "off" go straight to 1 or 0. Along the blend this
## - turns the world environment's screen-space reflections on with this hall's
##   settings (ssr_max_steps, ssr_fade_in, ssr_fade_out, ssr_depth_tolerance) from the
##   fade-in's first frame to the fade-out's last, their two fade exponents raised along
##   the way (SSR_FADE_RISE) so that what they reflect comes and goes with the blend and
##   is nothing where they switch. The environment's own settings come back then, when
##   the environment is swapped for another, and when this node leaves the tree (the
##   environment is the main scene's); each setting is written only when it changes;
## - polishes the terrazzo: its roughness, specular and colour go from the material's
##   own to floor_roughness, floor_specular and its colour tinted by floor_albedo,
##   channel by channel (the reflections add light of their own);
## - unless baked_sheen, puts up plain_attributes from the blend's middle on, the floor's
##   vertex attributes without its painted window streaks and dark pier reflections,
##   which the real reflections replace, and puts sheen_attributes, the floor as built,
##   back below it. Both were built on the CPU with the floor (nothing is read back from
##   the GPU); the same shader draws both. If they do not fit the surface this hall
##   draws, it says so as an error and leaves the baked sheen up;
## - with probes, reflects the hall itself wherever the screen has nothing to reflect,
##   at probe_intensity times the blend: probe_sections box-projected reflection probes
##   along the crescent, seeing and lighting the hall's render layer only. They are
##   made once the mural is up near the door (Building1MuralLoader, so they capture it),
##   reflect next to nothing (PROBE_HOLD) until the camera is in, capture again as the
##   sun moves (RECAPTURE_DEG) and are freed when the mural goes. Neighbouring boxes
##   overlap and blend over probe_blend metres. A probe's intensity scales its colour,
##   not its weight, and the engine skips a probe at 0, where the sky's reflection takes
##   its place: so they never go to 0 (a surface in their boxes would take the sky's
##   reflection at once at the fade's ends; held, the hall seen through its door keeps
##   next to no reflection), and the door's open leaves, glossy and in the boxes, draw
##   on another layer (building_1_interior.gd _door_leaves), out of their reach.
## Going in and coming out have lines of their own (InteriorPresence.HYSTERESIS_M inside
## and outside the hall's bounds), so a camera on the doorway does not turn the fade round
## frame by frame.

const MODES: Array[String] = ["off", "inside", "always"]
## The sun's move (degrees) after which the probes capture again, as DaySun's for
## Mersea's.
const RECAPTURE_DEG := 2.0
## A probe's weight fades to nothing over its blend distance inside each face of its
## box, so the boxes reach that and this much more (m) below the floor and past the
## hall's walls and each other's: the floor has full probe weight everywhere.
const PROBE_MARGIN_M := 0.5
## The engine weighs each screen-space reflection by ray^fade_in * (1 - ray)^fade_out (ray:
## its length on screen, 0 to 1, and an exponent of 0 off). While the blend b fades, both
## exponents rise by this times (1 - b) / b: nothing at b = 1, and every ray's weight goes
## to nothing as b nears 0, where the reflections switch on and off unseen.
const SSR_FADE_RISE := 0.25
## The probes' least intensity, the blend at 0 included: above 0, so the engine never
## skips them.
const PROBE_HOLD := 0.0001

@export var mode := "off"
## The render layer the hall draws on (building_1_interior.gd RENDER_INTERIOR): the
## probes see it alone and light it alone.
@export var render_layer := 0
## The hall's plan about the crescent's centre (centre x, centre z, inner radius, outer
## radius) and its angles (from, to), which the probes divide among themselves.
@export var hall := Vector4.ZERO
@export var hall_angles := Vector2.ZERO
@export var ssr := true
@export var ssr_max_steps := 64
@export var ssr_fade_in := 0.15
@export var ssr_fade_out := 2.0
@export var ssr_depth_tolerance := 0.2
@export var floor_roughness := 0.15
@export var floor_specular := 0.5
@export var floor_albedo := Color.WHITE
@export var baked_sheen := true
## The terrazzo surface's vertex attributes as RenderingServer keeps them, encoded on
## the CPU at build time (building_1_interior.gd _floor_attributes): as built, with the
## baked sheen, and the same without it; and the surface's format, vertex and index
## counts they were built for.
@export var sheen_attributes := PackedByteArray()
@export var plain_attributes := PackedByteArray()
@export var floor_format := 0
@export var floor_vertex_count := 0
@export var floor_index_count := 0
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

## The settings last applied, compared each frame (they may change in play).
var _applied: Array = []
## The hall's presence: where the blend comes from.
var _presence: InteriorPresence
## The blend now: 0 the floor as built, 1 polished; and the one last shown (-1: none yet).
var _blend := 0.0
var _shown := -1.0
var _shell: MeshInstance3D
var _floor: BaseMaterial3D
var _floor_surface := -1
var _floor_matte := {}
## Whether sheen_attributes and plain_attributes fit the floor surface drawn.
var _attributes_fit := false
var _plain_shown := false
## The environment this turned the reflections on in, and its own settings from before.
var _environment: Environment
var _environment_own := {}
var _probes: Array[ReflectionProbe] = []
## The layout the probes were made for: remade when it changes.
var _probe_layout: Array = []
var _captured_elevation := NAN


func _ready() -> void:
	if RenderingServer.get_current_rendering_method() != "forward_plus" or DisplayServer.get_name() == "headless":
		set_process(false)
		return
	_shell = get_parent().get_node_or_null("Shell") as MeshInstance3D
	_floor_surface = floor_surface(_shell)
	_presence = get_parent().get_node_or_null("Presence") as InteriorPresence
	if _floor_surface < 0 or _presence == null:
		push_error("Building 1 hall reflections: the hall has no %s; no reflections." % ("Shell with a terrazzo surface" if _floor_surface < 0 else "Presence (InteriorPresence)"))
		set_process(false)
		return
	_floor = _shell.mesh.surface_get_material(_floor_surface) as BaseMaterial3D
	if _floor != null:
		_floor_matte = {"roughness": _floor.roughness, "specular": _floor.metallic_specular, "albedo": _floor.albedo_color}
	_attributes_fit = attributes_fit(_shell)
	if not _attributes_fit:
		push_error("Building 1 hall reflections: the floor's built attributes do not fit its surface (format %d of %d, %d of %d vertices, %d of %d indices, %d and %d bytes); its baked sheen stays." % [floor_format, _shell.mesh.surface_get_format(_floor_surface), floor_vertex_count, _shell.mesh.surface_get_array_len(_floor_surface), floor_index_count, _shell.mesh.surface_get_array_index_len(_floor_surface), sheen_attributes.size(), plain_attributes.size()])


func _process(_delta: float) -> void:
	if (mode == "off" and _blend == 0.0 and _probes.is_empty()) or not Building1MuralLoader.play_started(get_tree()):
		return
	var settings := [mode, ssr, ssr_max_steps, ssr_fade_in, ssr_fade_out, ssr_depth_tolerance, floor_roughness, floor_specular, floor_albedo, baked_sheen]
	_blend = 1.0 if mode == "always" else (_presence.blend() if mode == "inside" else 0.0)
	if _blend != _shown or settings != _applied:
		_apply(is_on())
		_applied = settings
	elif _environment != null and _world_environment() != _environment:
		# The world's environment was swapped while the reflections are in it.
		_set_environment(true)
	_update_probes()


func _exit_tree() -> void:
	# Mid-fade or on: everything as built at once, the probes freed.
	_blend = 0.0
	if _shown > 0.0 or _environment != null or _plain_shown:
		_apply(false)
	_free_probes()


## Whether the reflections are called for now (they fade in or out after it): "always",
## or "inside" with the camera in the hall.
func is_on() -> bool:
	return mode == "always" or (mode == "inside" and _presence != null and _presence.is_inside())


## The fade: 0 the floor as built, 1 the reflections and polish all in.
func fade() -> float:
	return _blend


## Whether the floor shows its plain colours (no baked sheen) now.
func plain_floor_shown() -> bool:
	return _plain_shown


## The probes there are now.
func probe_nodes() -> Array[ReflectionProbe]:
	return _probes.duplicate()


## The terrazzo surface's index in the hall's Shell, or -1.
static func floor_surface(shell: MeshInstance3D) -> int:
	if shell == null or shell.mesh == null:
		return -1
	for surface in shell.mesh.get_surface_count():
		if shell.mesh.surface_get_name(surface) == "terrazzo":
			return surface
	return -1


## Whether sheen_attributes and plain_attributes fit the terrazzo surface the Shell
## draws: its format, vertex and index counts, and the attribute bytes those take.
func attributes_fit(shell: MeshInstance3D) -> bool:
	var surface := floor_surface(shell)
	if surface < 0:
		return false
	var mesh := shell.mesh
	var stride := RenderingServer.mesh_surface_get_format_attribute_stride(floor_format, floor_vertex_count)
	return mesh.surface_get_format(surface) == floor_format and mesh.surface_get_array_len(surface) == floor_vertex_count \
		and mesh.surface_get_array_index_len(surface) == floor_index_count and stride > 0 \
		and sheen_attributes.size() == stride * floor_vertex_count and plain_attributes.size() == sheen_attributes.size()


## The look at the blend now: the environment's reflections in while called for (from
## the fade-in's start) and until the fade-out's end, the floor between its own values
## and the polished ones (each end exact), its plain colours from the middle on.
func _apply(called_for: bool) -> void:
	_set_environment(called_for or _blend > 0.0)
	if _floor != null:
		var albedo: Color = _floor_matte.albedo
		var polished := Color(albedo.r * floor_albedo.r, albedo.g * floor_albedo.g, albedo.b * floor_albedo.b, albedo.a)
		_floor.roughness = _mix(float(_floor_matte.roughness), floor_roughness)
		_floor.metallic_specular = _mix(float(_floor_matte.specular), floor_specular)
		_floor.albedo_color = albedo if _blend == 0.0 else (polished if _blend == 1.0 else albedo.lerp(polished, _blend))
	_show_plain_floor(not baked_sheen and _blend >= 0.5)
	_shown = _blend


## A value between the floor's own (blend 0) and the polished one (blend 1).
func _mix(own: float, polished: float) -> float:
	return own if _blend == 0.0 else (polished if _blend == 1.0 else lerpf(own, polished, _blend))


## The world environment's reflections: this hall's while on (only its own if ssr is
## off), the environment's own back when off or when another environment has taken its
## place.
func _set_environment(on: bool) -> void:
	var current := _world_environment() if on else null
	if _environment != null and _environment != current:
		_restore_environment()
	if current == null:
		return
	if _environment == null:
		_environment = current
		_environment_own = {"ssr_enabled": current.ssr_enabled, "ssr_max_steps": current.ssr_max_steps, "ssr_fade_in": current.ssr_fade_in, "ssr_fade_out": current.ssr_fade_out, "ssr_depth_tolerance": current.ssr_depth_tolerance}
	var values := _environment_own
	if ssr:
		var rise := SSR_FADE_RISE * (1.0 - _blend) / maxf(_blend, 0.0001)
		values = {"ssr_enabled": true, "ssr_max_steps": ssr_max_steps, "ssr_fade_in": ssr_fade_in + rise, "ssr_fade_out": ssr_fade_out + rise, "ssr_depth_tolerance": ssr_depth_tolerance}
	_write_environment(values)


func _restore_environment() -> void:
	_write_environment(_environment_own)
	_environment = null
	_environment_own = {}


## Writes the values into the environment, each only where it holds another.
func _write_environment(values: Dictionary) -> void:
	for property: String in values:
		var now: Variant = _environment.get(property)
		var value: Variant = values[property]
		if not (is_equal_approx(now, value) if value is float else now == value):
			_environment.set(property, value)


## The world's environment: the viewport's World3D's, else main.tscn's WorldEnvironment
## node's (a capture may swap that one's for its own).
func _world_environment() -> Environment:
	var world := get_viewport().world_3d
	if world != null and world.environment != null:
		return world.environment
	var node := get_tree().root.find_child("WorldEnvironment", true, false) as WorldEnvironment
	return node.environment if node != null else null


## Puts the floor's plain attributes up, or its baked ones back (when they fit).
func _show_plain_floor(plain: bool) -> void:
	if plain == _plain_shown or not _attributes_fit:
		return
	RenderingServer.mesh_surface_update_attribute_region(_shell.mesh.get_rid(), _floor_surface, 0, plain_attributes if plain else sheen_attributes)
	_plain_shown = plain


## The probes: made once the mural is up near the door while the reflections may come
## on, freed when it goes or they are switched off; captured again as the sun moves.
func _update_probes() -> void:
	var loader := get_parent().get_node_or_null("MuralLoader") as Building1MuralLoader
	var wanted := mode != "off" and probes and loader != null and loader.state == Building1MuralLoader.State.LOADED
	var layout := [probe_sections, probe_blend, probe_capture_height, probe_box, render_layer]
	if not wanted or layout != _probe_layout:
		_free_probes()
		if not wanted:
			return
	if _probes.is_empty():
		_make_probes()
		_probe_layout = layout
		_captured_elevation = _sun_elevation()
	var intensity := maxf(probe_intensity * _blend, PROBE_HOLD)
	for probe in _probes:
		if probe.intensity != intensity:
			probe.intensity = intensity
	var elevation := _sun_elevation()
	if absf(elevation - _captured_elevation) >= RECAPTURE_DEG:
		for probe in _probes:
			probe.update_mode = ReflectionProbe.UPDATE_ONCE
		_captured_elevation = elevation


func _free_probes() -> void:
	for probe in _probes:
		if is_instance_valid(probe):
			probe.queue_free()
	_probes.clear()
	_probe_layout = []


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
		probe.cull_mask = render_layer
		probe.reflection_mask = render_layer
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
