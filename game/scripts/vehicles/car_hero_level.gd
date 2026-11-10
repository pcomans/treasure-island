extends Node3D
## The parked cars' hero level: the few cars nearest the camera are drawn from
## the hero kit (street_clutter_kit.gd hero_visual: body with cabin and
## underbody, see-through glass, four wheels and brakes) in place of their
## instance in the world's near and far batches. A car is taken up when the
## camera comes within KIT.HERO_NEAR_M of it and put back beyond KIT.HERO_FAR_M,
## at most KIT.HERO_MAX_CARS at once (the nearest), so the cost stays the same
## in a full car park. Its shadow caster in the world's batches stays as it is.
## The vehicle manager owns this node (desktop only: KIT.hero_level_enabled())
## and tells it when a row becomes a live car, which draws its own levels.

const KIT := preload("res://game/scripts/world/street_clutter_kit.gd")
## Look for the nearest cars this often (frames).
const EVERY_FRAMES := 3

var _kit: KIT
var _clutter: Node3D
var _rows: Dictionary = {}
var _cells: Dictionary = {}
var _grid_m := 16.0
## Row id -> the hero node drawn for it.
var _shown: Dictionary = {}
var _frame := 0


## rows and cells are the vehicle manager's: every swappable row by id, and the
## ids by grid cell of grid_m.
func configure(kit: KIT, clutter: Node3D, rows: Dictionary, cells: Dictionary, grid_m: float) -> void:
	_kit = kit
	_clutter = clutter
	_rows = rows
	_cells = cells
	_grid_m = grid_m


## The rows drawn at the hero level now.
func shown_ids() -> Array:
	return _shown.keys()


## A row that has become a live car: its hero node goes, its static instances
## stay hidden (the manager hides them all).
func release(id: String) -> void:
	if _shown.has(id):
		(_shown[id] as Node).queue_free()
		_shown.erase(id)


func _process(_delta: float) -> void:
	_frame += 1
	if _frame % EVERY_FRAMES != 0 or _kit == null:
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var at := camera.global_position
	var near: Array = []
	var reach := ceili(KIT.HERO_FAR_M / _grid_m)
	var cell := Vector2i(floori(at.x / _grid_m), floori(at.z / _grid_m))
	for dx in range(-reach, reach + 1):
		for dz in range(-reach, reach + 1):
			for id: String in _cells.get(cell + Vector2i(dx, dz), []):
				var entry: Dictionary = _rows[id]
				if str(entry.prop) != "parked_car" or bool(entry.get("live", false)):
					continue
				var distance := at.distance_to((entry.transform as Transform3D) * Vector3(0.0, 0.7, 0.0))
				if distance < (KIT.HERO_FAR_M if _shown.has(id) else KIT.HERO_NEAR_M):
					near.append([distance, id])
	near.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	var keep: Dictionary = {}
	for index in mini(near.size(), KIT.HERO_MAX_CARS):
		keep[near[index][1]] = true
	for id: String in _shown.keys():
		if not keep.has(id):
			_put_back(id)
	for id: String in keep:
		if not _shown.has(id):
			_take_up(id)


func _take_up(id: String) -> void:
	var entry: Dictionary = _rows[id]
	var custom: Color = entry.custom
	var visual := _kit.hero_visual(str((entry.params as Dictionary).get("body", "")), custom, custom.b)
	if visual == null:
		return
	visual.transform = entry.transform
	add_child(visual)
	_shown[id] = visual
	_set_static(entry, Transform3D(Basis().scaled(Vector3.ZERO), (entry.transform as Transform3D).origin))


func _put_back(id: String) -> void:
	(_shown[id] as Node).queue_free()
	_shown.erase(id)
	var entry: Dictionary = _rows[id]
	if not bool(entry.get("live", false)):
		_set_static(entry, entry.transform)


## Sets the row's instance in the world's near and far batches (not its shadow caster).
func _set_static(entry: Dictionary, placed: Transform3D) -> void:
	for ref: Array in entry.instances:
		if ref.size() > 2 and str(ref[2]) == "shadow":
			continue
		var instance := _clutter.get_node_or_null(str(ref[0])) as MultiMeshInstance3D
		if instance != null and instance.multimesh != null:
			instance.multimesh.set_instance_transform(int(ref[1]), placed)
