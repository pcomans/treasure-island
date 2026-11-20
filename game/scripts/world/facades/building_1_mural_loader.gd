class_name Building1MuralLoader
extends Node
## Building 1's hall mural (building_1_interior.gd, stage 2): its four tiles are loaded
## only once play has started and the camera comes within load_radius of the hall's
## front door, one tile a frame, and released once it has stayed beyond unload_radius
## for unload_delay seconds. The web's memory limit is why (the owner's design study,
## 2026-11-19): the island holds nothing of the mural until a player goes near. The
## hall is never more than about 40 m from its door, so nobody inside sees it unload.
##
## The four mural surfaces' materials carry a small placeholder texture of the band's
## plain colour from the start (the shader warm-up compiles them with it), so loading
## only swaps one texture for another: no new shader program, and never a hole. The
## builder hands this node that placeholder; it is never read back from a material,
## which may already hold a tile.
##
## Nothing here measures or prints: the drive trace (game/scripts/debug/drive_trace.gd)
## reads state and tiles_loaded to mark the frames the tiles go up in.
##
## It also holds the hall's trial switch for screen-space reflections (ssr_mode, from
## the interior's config "reflections"): "off", "inside" (on only while the camera is
## in the hall) or "always"; while they are on, the terrazzo turns glossy
## (floor_gloss: roughness, specular), since the reflections then show the room, not
## the sky. Forward+ only; the web's renderer has none.

enum State { UNLOADED, LOADING, LOADED }

## The door the distances are measured from (world, metres).
@export var door := Vector3.ZERO
## The tiles' resource paths, north to south, one for each mural surface.
@export var tiles := PackedStringArray()
@export var load_radius := 40.0
@export var unload_radius := 70.0
@export var unload_delay := 10.0
## The plain texture the mural surfaces show while the tiles are not loaded.
@export var placeholder: Texture2D
@export var ssr_mode := "off"
## The terrazzo's roughness and specular while the reflections are on.
@export var floor_gloss := Vector2(0.15, 0.5)
## The hall's plan for the inside test: (centre x, centre z, inner radius, outer radius)
## and its angles (from, to) about the crescent's centre.
@export var hall := Vector4.ZERO
@export var hall_angles := Vector2.ZERO

var state := State.UNLOADED
## How many tiles are on the walls now, from 0 to tiles.size().
var tiles_loaded := 0
## The mural surfaces' materials, north to south (the sibling Shell's "mural_N"
## surfaces, found by name: a baked world keeps the surfaces, not this node's links).
var materials: Array[BaseMaterial3D] = []
var _far_for := 0.0
var _ssr_on := false
var _floor: BaseMaterial3D
var _floor_matte := Vector2.ZERO


func _ready() -> void:
	var shell := get_parent().get_node_or_null("Shell") as MeshInstance3D
	if shell == null or shell.mesh == null or placeholder == null:
		push_error("Building 1 mural: the hall has no Shell mesh or no placeholder; its mural stays plain.")
		return
	materials.clear()
	for index in tiles.size():
		var material: BaseMaterial3D = null
		for surface in shell.mesh.get_surface_count():
			if shell.mesh.surface_get_name(surface) == "mural_%d" % (index + 1):
				material = shell.mesh.surface_get_material(surface) as BaseMaterial3D
		if material == null:
			materials.clear()
			push_error("Building 1 mural: the hall has no surface mural_%d; its mural stays plain." % (index + 1))
			return
		materials.append(material)
	for surface in shell.mesh.get_surface_count():
		if shell.mesh.surface_get_name(surface) == "terrazzo":
			_floor = shell.mesh.surface_get_material(surface) as BaseMaterial3D
	if _floor != null:
		_floor_matte = Vector2(_floor.roughness, _floor.metallic_specular)


func _process(delta: float) -> void:
	if materials.is_empty() or not _play_started():
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	step(camera.global_position.distance_to(door), delta)
	_update_reflections(camera.global_position)


## Advances the loading for a camera this far from the door, delta seconds on.
func step(distance: float, delta: float) -> void:
	match state:
		State.UNLOADED:
			if distance <= load_radius:
				state = State.LOADING
		State.LOADING:
			# One tile a frame: a load is spread over as many frames as there are tiles.
			var texture := load(tiles[tiles_loaded]) as Texture2D
			if texture != null:
				materials[tiles_loaded].albedo_texture = texture
				materials[tiles_loaded].emission_texture = texture
			tiles_loaded += 1
			if tiles_loaded >= tiles.size():
				state = State.LOADED
				_far_for = 0.0
		State.LOADED:
			_far_for = _far_for + delta if distance > unload_radius else 0.0
			if _far_for >= unload_delay:
				release()


## Puts the placeholder back on every mural surface, so the tiles are freed.
func release() -> void:
	for material in materials:
		material.albedo_texture = placeholder
		material.emission_texture = placeholder
	state = State.UNLOADED
	tiles_loaded = 0
	_far_for = 0.0


## Screen-space reflections on while the camera is in the hall (ssr_mode "inside"),
## always ("always") or never ("off", the default): the world's environment, Forward+.
func _update_reflections(at: Vector3) -> void:
	if ssr_mode == "off" or RenderingServer.get_current_rendering_method() == "gl_compatibility":
		return
	var inside := ssr_mode == "always"
	if not inside:
		var offset := Vector2(at.x - hall.x, at.z - hall.y)
		var angle := atan2(offset.y, offset.x)
		inside = offset.length() > hall.z and offset.length() < hall.w and angle > hall_angles.x and angle < hall_angles.y and at.y < door.y + 16.0
	if inside == _ssr_on:
		return
	var environment := get_viewport().world_3d.environment if get_viewport().world_3d != null else null
	if environment == null:
		var world := get_viewport().find_child("WorldEnvironment", true, false) as WorldEnvironment
		environment = world.environment if world != null else null
	if environment == null:
		return
	environment.ssr_enabled = inside
	if _floor != null:
		var gloss := floor_gloss if inside else _floor_matte
		_floor.roughness = gloss.x
		_floor.metallic_specular = gloss.y
	_ssr_on = inside


func _play_started() -> bool:
	var main := get_tree().root.get_node_or_null("Main")
	return main != null and main.has_method("is_play_ready") and bool(main.call("is_play_ready"))
