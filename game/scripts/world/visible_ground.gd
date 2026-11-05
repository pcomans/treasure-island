class_name VisibleGround
extends RefCounted
## How far the drawn ground stands above the land collision at a point.
##
## The world generator drapes its visible-only surfaces over the land: roads and
## paths 0.078-0.08 m up, areas 0.02-0.05 m, terrain overlays 0.03-0.06 m, an area
## a few millimetres higher where it overlaps a larger one of its class (their
## records' `surface_bias_m`). The stock player stands on the land collision under
## them, so anything that should touch the drawn ground, such as the player
## character's feet, adds this lift where the land is what it stands on.
##
## WorldChunkBuilder stores each draped record's footprint (its triangles in world
## XZ) and lift as metadata on the record's root, and the static world bakes them
## with it, so this index is built from plain data: no mesh is read back from the
## renderer. Build it once per loaded world (it takes a few tens of milliseconds);
## lift_at() then tests the handful of triangles in one grid cell.

const FOOTPRINT_META := "visible_footprint_xz"
const LIFT_META := "visible_lift_m"
const CELL_M := 12.0

var _points := PackedVector2Array()
var _lifts := PackedFloat32Array()
## Grid cell (Vector2i) -> triangle numbers (PackedInt32Array).
var _cells := {}


## Indexes every draped record under `parents` (the world's GroundAndAreas and
## RoadsAndPaths); returns how many records it found.
func build(parents: Array) -> int:
	_points = PackedVector2Array()
	_lifts = PackedFloat32Array()
	var lists := {}
	var records := 0
	for parent: Node in parents:
		if parent == null:
			continue
		for node: Node in parent.find_children("*", "Node3D", true, false):
			if not node.has_meta(FOOTPRINT_META):
				continue
			records += 1
			var footprint: PackedVector2Array = node.get_meta(FOOTPRINT_META)
			var lift := float(node.get_meta(LIFT_META, 0.0))
			for corner in range(0, footprint.size() - 2, 3):
				var triangle := _lifts.size()
				var a := footprint[corner]
				var b := footprint[corner + 1]
				var c := footprint[corner + 2]
				_points.append_array(PackedVector2Array([a, b, c]))
				_lifts.append(lift)
				var low := Vector2i(floori(minf(a.x, minf(b.x, c.x)) / CELL_M), floori(minf(a.y, minf(b.y, c.y)) / CELL_M))
				var high := Vector2i(floori(maxf(a.x, maxf(b.x, c.x)) / CELL_M), floori(maxf(a.y, maxf(b.y, c.y)) / CELL_M))
				for cell_x in range(low.x, high.x + 1):
					for cell_z in range(low.y, high.y + 1):
						var key := Vector2i(cell_x, cell_z)
						if not lists.has(key):
							lists[key] = []
						(lists[key] as Array).append(triangle)
	_cells = {}
	for key: Vector2i in lists:
		_cells[key] = PackedInt32Array(lists[key])
	return records


func is_empty() -> bool:
	return _lifts.is_empty()


## The lift of the top draped surface covering world (x, z), or 0.
func lift_at(x: float, z: float) -> float:
	var list: PackedInt32Array = _cells.get(Vector2i(floori(x / CELL_M), floori(z / CELL_M)), PackedInt32Array())
	var point := Vector2(x, z)
	var best := 0.0
	for triangle in list:
		var lift := _lifts[triangle]
		if lift > best and _contains(point, _points[triangle * 3], _points[triangle * 3 + 1], _points[triangle * 3 + 2]):
			best = lift
	return best


## Whether p lies in triangle abc (either winding; edges count as inside).
static func _contains(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> bool:
	var ab := (b - a).cross(p - a)
	var bc := (c - b).cross(p - b)
	var ca := (a - c).cross(p - c)
	return not ((ab < 0.0 or bc < 0.0 or ca < 0.0) and (ab > 0.0 or bc > 0.0 or ca > 0.0))
