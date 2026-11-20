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
## reads state and tiles_loaded to mark the frames the tiles go up in. The hall's
## floor reflections (Building1HallReflections) read state too: their probes capture
## the hall once the mural is up.

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
## The hall's plan about the crescent's centre: (centre x, centre z, inner radius,
## outer radius); the drive trace walks in along it.
@export var hall := Vector4.ZERO

var state := State.UNLOADED
## How many tiles are on the walls now, from 0 to tiles.size().
var tiles_loaded := 0
## The mural surfaces' materials, north to south (the sibling Shell's "mural_N"
## surfaces, found by name: a baked world keeps the surfaces, not this node's links).
var materials: Array[BaseMaterial3D] = []
var _far_for := 0.0


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


func _process(delta: float) -> void:
	if materials.is_empty() or not play_started(get_tree()):
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	step(camera.global_position.distance_to(door), delta)


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


## Whether the game has handed over play (main.gd is_play_ready): the hall's nodes wait
## for it (the reflections too, Building1HallReflections).
static func play_started(tree: SceneTree) -> bool:
	var main := tree.root.get_node_or_null("Main")
	return main != null and main.has_method("is_play_ready") and bool(main.call("is_play_ready"))
