extends SceneTree
## No outdoor ground indoors (owner, 2026-11-20, on Building 1's hall: "can we add a
## mechanical check that there is no dirt or grass ground indoors?"). Build 2362 showed
## the plaza's grass along the bar room's front wall: the land and the plaza draped over
## it stood above the hall's floor there.
##
## Every enterable interior is checked: each catalog unit that lists walk-through
## "passages" (game/tests/shared/building_fit.gd walks them) is entered into an interior
## that its producer builds beside the unit's records, a node carrying the meta
## interior_of_source_key (Building 1's concourse, building_1_interior.gd). The chunks
## that hold the unit's records, and every chunk under the interior's plan, are built
## with the world's own WorldChunkBuilder: their ground and roads (land, draped areas,
## roads and paths, park and street surfaces, kerbs and overlays, drawn or solid) are
## the outdoor ground, and the street detail's placed rows (planting, hedges, furniture,
## fences, clutter and parked cars) the outdoor instances.
##
## The interior is sampled on a GRID_M grid over its plan and along the foot of each of
## its walls, FOOT_INSET_M inside the face, so every floor is sampled right up to its
## walls, in the window reveals and the vestibule too. Where a surface of the interior
## faces down over one that faces up (a ceiling, soffit, head or reveal over a floor),
## the sample stands on that floor, the lowest such one: a ray down from eye height over
## it must meet the interior first, and no outdoor ground may lie above it (up to the
## interior's top there) or less than CLEARANCE_M under it (nor, so, over any level
## above it). Where the lowest surface of
## the interior faces down, it is either a solid's underside at the level of the floor
## beside it (a plinth's), with the outdoor ground under it as under a floor, or a
## ceiling over a hole in the floor (a floor lies lower within NEAR_M), which fails. No
## placed street-detail row stands inside, and each passage's inside end stands on the
## floor. The interior hangs under the world's buildings, which the ground dressing's
## captures copy as a mask (ground_dressing.gd CAPTURED_PARTS), so no tuft of grass
## grows under it. Not empty: each interior needs MIN_FLOOR_SAMPLES samples on its
## floor, and outdoor ground under at least one of them.

const Catalog := preload("res://game/tests/shared/catalog.gd")
const GROUND_DRESSING := preload("res://game/scripts/world/ground_dressing.gd")
const WORLD := "res://generated/world/"
const MANIFEST := WORLD + "manifest.json"
const LEDGER := WORLD + "coverage-ledger.csv"
const STREET_DETAIL := WORLD + "street_detail.json"
## The meta an interior's root carries: the OSM key of the building it is inside.
const INTERIOR_META := "interior_of_source_key"
## The world's category parents (WorldChunkBuilder, WorldLoader): the first two hold
## the outdoor ground, the last the buildings and the interiors beside them.
const GROUND_PARTS := ["ground", "roads"]
const BUILDINGS := "buildings"
const GRID_M := 0.25
const FOOT_STEP_M := 0.25
## Close enough to a wall to find a floor that stops a few millimetres short of it.
const FOOT_INSET_M := 0.002
const EYE_HEIGHT_M := 1.6
## Ground this close under a floor fights it for the same pixels at a distance.
const CLEARANCE_M := 0.01
## A surface facing down is over a floor when it stands this much above it.
const OVER_M := 0.05
## A surface facing down rests on a floor at its own height within this (a box's
## underside on the floor it stands on).
const REST_M := 0.001
## How far round an underside a lower floor makes it a ceiling over a hole.
const NEAR_M := 1.0
## A surface faces up or down when its normal's y is past FACING_Y; a wall's is under
## WALL_Y.
const FACING_Y := 0.5
const WALL_Y := 0.2
const MIN_FLOOR_SAMPLES := 100
## Line street-detail rows are tested every this many metres along their runs.
const ROW_STEP_M := 0.25
const EXAMPLES := 8

var failures: Array[String] = []
var _parents := {}
var _built := {}
var _builder := WorldChunkBuilder.new()


## Triangles for vertical-line queries, within a plan rectangle: per triangle its plan
## box, first corner, the two edges from it, the inverse of their plan determinant and
## how far past each edge (in its own measure) a point still counts as on the triangle,
## TOLERANCE_M in plan (STRIDE floats), its facing (normal y) and its owner's name; and a
## grid of BUCKET_M buckets over the rectangle.
class Surfaces:
	const STRIDE := 17
	const BUCKET_M := 0.5
	## A point this close to a triangle in plan is on it: two triangles that meet along an
	## edge both hold a point on it, whichever way rounding takes it.
	const TOLERANCE_M := 0.0005
	var low := Vector2.ZERO
	var high := Vector2.ZERO
	var data := PackedFloat64Array()
	var facing := PackedFloat64Array()
	var owners := PackedInt32Array()
	var names: Array[String] = []
	var buckets := {}
	var count := 0

	func _init(from: Vector2, to: Vector2) -> void:
		low = from
		high = to

	func add(a: Vector3, b: Vector3, c: Vector3, normal_y: float, owner: int) -> void:
		var e1 := b - a
		var e2 := c - a
		var det := e1.x * e2.z - e2.x * e1.z
		if absf(det) < 1e-9:
			return
		var min_x := minf(a.x, minf(b.x, c.x)) - TOLERANCE_M
		var max_x := maxf(a.x, maxf(b.x, c.x)) + TOLERANCE_M
		var min_z := minf(a.z, minf(b.z, c.z)) - TOLERANCE_M
		var max_z := maxf(a.z, maxf(b.z, c.z)) + TOLERANCE_M
		if max_x < low.x or min_x > high.x or max_z < low.y or min_z > high.y:
			return
		var index := count
		count += 1
		var span := TOLERANCE_M / absf(det)
		var e1_plan := Vector2(e1.x, e1.z).length()
		var e2_plan := Vector2(e2.x, e2.z).length()
		var e3_plan := Vector2(e2.x - e1.x, e2.z - e1.z).length()
		data.append_array([min_x, max_x, min_z, max_z, a.x, a.y, a.z, e1.x, e1.y, e1.z, e2.x, e2.y, e2.z, 1.0 / det, span * e2_plan, span * e1_plan, span * e3_plan])
		facing.append(normal_y)
		owners.append(owner)
		for i in range(floori(maxf(min_x, low.x) / BUCKET_M), floori(minf(max_x, high.x) / BUCKET_M) + 1):
			for j in range(floori(maxf(min_z, low.y) / BUCKET_M), floori(minf(max_z, high.y) / BUCKET_M) + 1):
				var key := Vector2i(i, j)
				if not buckets.has(key):
					buckets[key] = []
				(buckets[key] as Array).append(index)

	## Every crossing of the vertical line at x, z: [y, facing, owner], in no order.
	func crossings(x: float, z: float) -> Array:
		var found: Array = []
		var key := Vector2i(floori(x / BUCKET_M), floori(z / BUCKET_M))
		if not buckets.has(key):
			return found
		for index: int in buckets[key]:
			var base := index * STRIDE
			if x < data[base] or x > data[base + 1] or z < data[base + 2] or z > data[base + 3]:
				continue
			var dx := x - data[base + 4]
			var dz := z - data[base + 6]
			# s along the first edge, t along the second; each may run past its edge by the
			# tolerance (data[base + 14] for s, + 15 for t, + 16 for the third edge).
			var s := (dx * data[base + 12] - data[base + 10] * dz) * data[base + 13]
			var t := (data[base + 7] * dz - dx * data[base + 9]) * data[base + 13]
			if s < -data[base + 14] or t < -data[base + 15] or s + t > 1.0 + data[base + 16]:
				continue
			found.append([data[base + 5] + s * data[base + 8] + t * data[base + 11], facing[index], owners[index]])
		return found

	## The highest crossing at x, z under the height below: [y, owner], or [] where
	## nothing crosses there.
	func top(x: float, z: float, below := INF) -> Array:
		var best: Array = []
		for hit: Array in crossings(x, z):
			if float(hit[0]) < below and (best.is_empty() or float(hit[0]) > float(best[0])):
				best = [hit[0], hit[2]]
		return best


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for part: String in GROUND_PARTS + [BUILDINGS]:
		var parent := Node3D.new()
		parent.name = part
		root.add_child(parent)
		_parents[part] = parent
	var units: Array[Dictionary] = []
	for unit: Dictionary in Catalog.units():
		if not (unit.get("passages", []) as Array).is_empty():
			units.append(unit)
	if units.is_empty():
		_finish("no catalog unit lists passages, so no interior is checked")
		return
	if not GROUND_DRESSING.CAPTURED_PARTS.has(BUILDINGS) or bool(GROUND_DRESSING.CAPTURED_PARTS[BUILDINGS]):
		failures.append("the ground dressing's captures no longer copy the buildings as a mask, so grass could grow under an interior")
	var manifest := _json(MANIFEST)
	var chunk_size := float(manifest.get("chunk_size_m", 0.0))
	var chunk_paths := {}
	for entry: Dictionary in manifest.get("chunks", []):
		chunk_paths[str(entry.chunk_id)] = WORLD + str(entry.path)
	if chunk_size <= 0.0 or chunk_paths.is_empty():
		_finish("the generated world's manifest names no chunks")
		return
	var ledger := _ledger_chunks()
	var rows := _street_detail_rows()
	var checked: Array[String] = []
	for unit: Dictionary in units:
		var source := str(unit.get("anchor_source_key", ""))
		var holding: Array = ledger.get(source, [])
		if holding.is_empty():
			failures.append("%s lists passages, but no chunk holds its records" % source)
			continue
		for chunk_id: String in holding:
			_build(chunk_id, chunk_paths)
		var interiors := _interiors(source)
		if interiors.is_empty():
			failures.append("%s lists passages, but no interior (meta %s) is built beside its records" % [source, INTERIOR_META])
			continue
		for interior: Node3D in interiors:
			var report := _check_interior(source, interior, unit.get("passages", []) as Array, rows, chunk_paths, chunk_size)
			if report != "":
				checked.append(report)
	_finish("" if not checked.is_empty() or not failures.is_empty() else "no interior was checked", checked)


## Builds one generated chunk with the world's builder, once, under the category parents.
func _build(chunk_id: String, chunk_paths: Dictionary) -> void:
	if _built.has(chunk_id):
		return
	_built[chunk_id] = true
	if not chunk_paths.has(chunk_id):
		failures.append("chunk %s is not in the generated world" % chunk_id)
		return
	var report := _builder.build_chunk(_json(str(chunk_paths[chunk_id])), _parents)
	if not bool(report.get("ok", false)):
		failures.append("chunk %s does not build: %s" % [chunk_id, str(report.get("message", report))])
		return
	_builder.attach_built_chunk(report, _parents)


func _interiors(source: String) -> Array[Node3D]:
	var found: Array[Node3D] = []
	for node: Node in (_parents[BUILDINGS] as Node).find_children("*", "Node3D", true, false):
		if str(node.get_meta(INTERIOR_META, "")) == source:
			found.append(node as Node3D)
	return found


## The checks for one interior: its PASS summary, or "" when it fails.
func _check_interior(source: String, interior: Node3D, passages: Array, rows: Array, chunk_paths: Dictionary, chunk_size: float) -> String:
	var before := failures.size()
	var label := "%s's interior %s" % [source, interior.name]
	if not (_parents[BUILDINGS] as Node).is_ancestor_of(interior):
		failures.append("%s does not hang under the world's buildings, so the ground dressing could grow grass under it" % label)
	var triangles := _interior_triangles(interior)
	var box := _bounds(triangles.corners as PackedVector3Array)
	if box.size == Vector3.ZERO:
		failures.append("%s draws nothing" % label)
		return ""
	var low := Vector2(box.position.x, box.position.z) - Vector2.ONE
	var high := Vector2(box.end.x, box.end.z) + Vector2.ONE
	var inside := Surfaces.new(low, high)
	var walls: Array = []
	_interior_surfaces(triangles, str(interior.name), inside, walls)
	# Every chunk under the interior's plan, then their ground and roads there.
	for i in range(floori(low.x / chunk_size), floori(high.x / chunk_size) + 1):
		for j in range(floori(low.y / chunk_size), floori(high.y / chunk_size) + 1):
			var chunk_id := "x_%d__z_%d" % [i, j]
			if chunk_paths.has(chunk_id):
				_build(chunk_id, chunk_paths)
	var ground := Surfaces.new(low, high)
	for part: String in GROUND_PARTS:
		_ground_surfaces(_parents[part] as Node, ground)
	# The samples: a grid over the plan, and the foot of every wall just inside its face.
	var samples := {}
	var x := snappedf(box.position.x, GRID_M)
	while x <= box.end.x:
		var z := snappedf(box.position.z, GRID_M)
		while z <= box.end.z:
			samples[Vector2i(roundi(x * 1000.0), roundi(z * 1000.0))] = Vector2(x, z)
			z += GRID_M
		x += GRID_M
	for foot: Array in walls:
		var a: Vector3 = foot[0]
		var b: Vector3 = foot[1]
		var into: Vector3 = foot[2]
		var steps := maxi(1, ceili(a.distance_to(b) / FOOT_STEP_M))
		for step in steps + 1:
			var at := a.lerp(b, float(step) / float(steps)) + into * FOOT_INSET_M
			samples[Vector2i(roundi(at.x * 1000.0), roundi(at.z * 1000.0))] = Vector2(at.x, at.z)
	# Where each sample stands on the interior: its floor, or the underside lowest in it.
	var columns := {}
	var floors_near := {}
	for key: Vector2i in samples:
		var point: Vector2 = samples[key]
		var column := _column(inside, point)
		if str(column.kind) == "outside":
			continue
		columns[key] = column
		if str(column.kind) == "floor":
			var cell := Vector2i(floori(point.x / NEAR_M), floori(point.y / NEAR_M))
			floors_near[cell] = minf(float(floors_near.get(cell, INF)), float(column.y))
	var on_floor := 0
	var over_ground := 0
	var least := INF
	var holes: Array[String] = []
	var exposed: Array[String] = []
	var hole_count := 0
	var exposed_count := 0
	for key: Vector2i in columns:
		var point: Vector2 = samples[key]
		var column: Dictionary = columns[key]
		var level := float(column.y)
		if str(column.kind) == "under":
			# A ceiling over a hole when a floor beside it lies lower.
			var cell := Vector2i(floori(point.x / NEAR_M), floori(point.y / NEAR_M))
			var lowest := INF
			for i in range(-1, 2):
				for j in range(-1, 2):
					lowest = minf(lowest, float(floors_near.get(cell + Vector2i(i, j), INF)))
			if lowest < level - OVER_M:
				hole_count += 1
				if holes.size() < EXAMPLES:
					holes.append("(%.3f, %.3f): a surface facing down at %.3f, the floor beside it at %.3f" % [point.x, point.y, level, lowest])
				continue
		else:
			on_floor += 1
		# The outdoor ground inside the shell: under the interior's top (ground over its
		# roof, as over a cellar, is outside it).
		var top := ground.top(point.x, point.y, float(column.top))
		if top.is_empty():
			continue
		over_ground += 1
		var ground_y := float(top[0])
		least = minf(least, level - ground_y)
		if ground_y > level - CLEARANCE_M:
			exposed_count += 1
			if exposed.size() < EXAMPLES:
				# What a ray down from eye height over the floor meets first.
				var first := ground.names[int(top[1])] if ground_y < level + EYE_HEIGHT_M and ground_y >= float(column.below_eye) else "the interior"
				exposed.append("%s at %.3f, %+.3f m from the floor at %.3f, at (%.3f, %.3f), where a ray down from eye height meets %s first" % [ground.names[int(top[1])], ground_y, ground_y - level, level, point.x, point.y, first])
	if exposed_count > 0:
		failures.append("%s: outdoor ground stands inside it, above its floor or less than %.2f m under it, at %d of %d samples, as %s" % [label, CLEARANCE_M, exposed_count, columns.size(), "; ".join(exposed)])
	if hole_count > 0:
		failures.append("%s: its floor has holes under its ceilings at %d samples, as %s" % [label, hole_count, "; ".join(holes)])
	if on_floor < MIN_FLOOR_SAMPLES:
		failures.append("%s: only %d samples stand on its floor (fewer than %d), so the check proves nothing" % [label, on_floor, MIN_FLOOR_SAMPLES])
	if over_ground == 0:
		failures.append("%s: no outdoor ground was found under any of its %d samples, so the ground is not being read" % [label, columns.size()])
	# No placed street-detail row stands inside.
	var rows_inside: Array[String] = []
	for row: Dictionary in rows:
		for at: Vector2 in row.points:
			if at.x < low.x or at.x > high.x or at.y < low.y or at.y > high.y:
				continue
			if str(_column(inside, at).kind) != "outside":
				rows_inside.append("%s (%s) at (%.2f, %.2f)" % [row.id, row.kind, at.x, at.y])
				break
	if not rows_inside.is_empty():
		failures.append("%s: %d street-detail rows stand inside it, as %s" % [label, rows_inside.size(), ", ".join(rows_inside.slice(0, EXAMPLES))])
	# Each passage leads onto its floor.
	for passage: Variant in passages:
		var end: Variant = (passage as Dictionary).get("inside", null) if passage is Dictionary else null
		if not end is Array or (end as Array).size() != 2:
			failures.append("%s: a passage has no inside end" % label)
			continue
		if str(_column(inside, Vector2(float(end[0]), float(end[1]))).kind) != "floor":
			failures.append("%s: passage %s's inside end %s is not on its floor" % [label, str((passage as Dictionary).get("name", "")), str(end)])
	if failures.size() > before:
		return ""
	return "%s: %d samples on its floor, outdoor ground under %d samples, at least %.3f m under the floor" % [label, on_floor, over_ground, least]


## Where a point stands on the interior: {"kind": "floor", "y": the lowest surface facing
## up with one facing down over it (every level over it stands higher), "below_eye": the
## highest surface of the interior under eye height over that floor, "top": its highest
## surface there}; {"kind": "under", "y", "below_eye", "top"} where the lowest surface of
## the interior faces down (an underside, or a ceiling over a hole); or {"kind":
## "outside"} where nothing of it faces down over the point.
func _column(inside: Surfaces, point: Vector2) -> Dictionary:
	var ups: Array[float] = []
	var downs: Array[float] = []
	var all: Array[float] = []
	for hit: Array in inside.crossings(point.x, point.y):
		var y := float(hit[0])
		all.append(y)
		if float(hit[1]) > FACING_Y:
			ups.append(y)
		elif float(hit[1]) < -FACING_Y:
			downs.append(y)
	if downs.is_empty():
		return {"kind": "outside"}
	ups.sort()
	downs.sort()
	var level := INF
	var kind := "outside"
	if ups.is_empty() or downs[0] < ups[0] - REST_M:
		level = downs[0]
		kind = "under"
	else:
		var top := downs[downs.size() - 1]
		for y in ups:
			if top > y + OVER_M:
				level = y
				kind = "floor"
				break
	if kind == "outside":
		return {"kind": kind}
	var below_eye := -INF
	for y in all:
		if y < level + EYE_HEIGHT_M:
			below_eye = maxf(below_eye, y)
	return {"kind": kind, "y": level, "below_eye": below_eye, "top": all.max()}


## The interior's drawn triangles (its MeshInstance3D surfaces) in world space:
## {"corners": three per triangle, "normals": one per triangle, from its vertex
## normals, else from Godot's clockwise front faces}.
func _interior_triangles(node: Node) -> Dictionary:
	var corners := PackedVector3Array()
	var facings := PackedVector3Array()
	for found: Node in node.find_children("*", "MeshInstance3D", true, false):
		var instance := found as MeshInstance3D
		if instance.mesh == null or not instance.visible:
			continue
		var to_world := instance.global_transform
		var turn := to_world.basis.inverse().transposed()
		for surface in instance.mesh.get_surface_count():
			var arrays := instance.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals := PackedVector3Array()
			if arrays[Mesh.ARRAY_NORMAL] != null:
				normals = arrays[Mesh.ARRAY_NORMAL]
			var indices := PackedInt32Array()
			if arrays[Mesh.ARRAY_INDEX] != null:
				indices = arrays[Mesh.ARRAY_INDEX]
			if indices.is_empty():
				indices = PackedInt32Array(range(vertices.size()))
			for t in range(0, indices.size() - 2, 3):
				var a := to_world * vertices[indices[t]]
				var b := to_world * vertices[indices[t + 1]]
				var c := to_world * vertices[indices[t + 2]]
				corners.append_array([a, b, c])
				if normals.size() == vertices.size():
					facings.append((turn * (normals[indices[t]] + normals[indices[t + 1]] + normals[indices[t + 2]])).normalized())
				else:
					facings.append((c - a).cross(b - a).normalized())
	return {"corners": corners, "normals": facings}


func _bounds(corners: PackedVector3Array) -> AABB:
	if corners.is_empty():
		return AABB()
	var box := AABB(corners[0], Vector3.ZERO)
	for corner in corners:
		box = box.expand(corner)
	return box


## The interior's triangles into surfaces, with each one's facing; each wall's foot
## edge (its lowest edge, when level) with the way the wall faces, into walls.
func _interior_surfaces(triangles: Dictionary, owner_name: String, surfaces: Surfaces, walls: Array) -> void:
	surfaces.names.append(owner_name)
	var corners: PackedVector3Array = triangles.corners
	var normals: PackedVector3Array = triangles.normals
	for index in normals.size():
		var a := corners[index * 3]
		var b := corners[index * 3 + 1]
		var c := corners[index * 3 + 2]
		var normal := normals[index]
		surfaces.add(a, b, c, normal.y, 0)
		var into := Vector3(normal.x, 0.0, normal.z)
		if absf(normal.y) >= WALL_Y or into.length() < 0.5:
			continue
		var foot := minf(a.y, minf(b.y, c.y))
		var points := [a, b, c]
		for edge in 3:
			var p: Vector3 = points[edge]
			var q: Vector3 = points[(edge + 1) % 3]
			if absf(p.y - foot) < 0.005 and absf(q.y - foot) < 0.005 and p.distance_to(q) > 0.01:
				walls.append([p, q, into.normalized()])


## The outdoor ground's triangles under parent: every drawn surface and every solid
## shape (a kerb's support ramp is solid only), each named for its generated record.
func _ground_surfaces(parent: Node, surfaces: Surfaces) -> void:
	for found: Node in parent.find_children("*", "", true, false):
		var triangles := PackedVector3Array()
		var to_world := Transform3D.IDENTITY
		if found is MeshInstance3D and (found as MeshInstance3D).mesh != null:
			triangles = (found as MeshInstance3D).mesh.get_faces()
			to_world = (found as MeshInstance3D).global_transform
		elif found is CollisionShape3D and (found as CollisionShape3D).shape is ConcavePolygonShape3D:
			triangles = ((found as CollisionShape3D).shape as ConcavePolygonShape3D).get_faces()
			to_world = (found as CollisionShape3D).global_transform
		else:
			continue
		var owner := surfaces.names.size()
		surfaces.names.append(_record_name(found))
		for t in range(0, triangles.size() - 2, 3):
			surfaces.add(to_world * triangles[t], to_world * triangles[t + 1], to_world * triangles[t + 2], 0.0, owner)


## The generated record a ground node belongs to (its derived_object_key), else its name.
func _record_name(node: Node) -> String:
	var at := node
	while at != null:
		if at.has_meta("derived_object_key"):
			return str(at.get_meta("derived_object_key"))
		at = at.get_parent()
	return str(node.name)


## Every placed street-detail row (the planting blocks expanded as the world expands
## them) as {id, kind, points}: its position, its footprint's corners, and points every
## ROW_STEP_M along a line row's runs.
func _street_detail_rows() -> Array:
	# The world loader's expansion (GeneratedWorldContract.load_and_validate).
	var expanded := GeneratedWorldContract._expand_planting_rows(_json(STREET_DETAIL))
	if not bool(expanded.get("ok", false)):
		failures.append("the street detail does not expand: %s" % str(expanded.get("message", "")))
		return []
	var rows: Array = []
	for row: Dictionary in (expanded.data as Dictionary).get("rows", []):
		if str(row.get("status", "")) != "placed":
			continue
		var points: Array[Vector2] = []
		var at: Variant = row.get("position_m", null)
		if at is Array and (at as Array).size() == 3:
			var middle := Vector2(float(at[0]), float(at[2]))
			points.append(middle)
			var size: Variant = row.get("footprint_m", null)
			if size is Dictionary:
				var yaw := float(row.get("yaw_radians", 0.0))
				var along := Vector2(cos(yaw), -sin(yaw)) * float((size as Dictionary).get("x_m", 0.0)) * 0.5
				var across := Vector2(sin(yaw), cos(yaw)) * float((size as Dictionary).get("z_m", 0.0)) * 0.5
				points.append_array([middle + along + across, middle + along - across, middle - along + across, middle - along - across])
		var line: Variant = row.get("points_m", null)
		if line is Array:
			for index in (line as Array).size() - 1:
				var a := Vector2(float(line[index][0]), float(line[index][2]))
				var b := Vector2(float(line[index + 1][0]), float(line[index + 1][2]))
				var steps := maxi(1, ceili(a.distance_to(b) / ROW_STEP_M))
				for step in steps + 1:
					points.append(a.lerp(b, float(step) / float(steps)))
		if not points.is_empty():
			rows.append({"id": str(row.get("id", "")), "kind": str(row.get("kind", "")), "points": points})
	if rows.is_empty():
		failures.append("the street detail has no placed rows, so its check proves nothing")
	return rows


## Each source key's chunks, from the coverage ledger's chunk_ids column.
func _ledger_chunks() -> Dictionary:
	var result := {}
	var file := FileAccess.open(LEDGER, FileAccess.READ)
	if file == null:
		failures.append("the coverage ledger %s can't be read" % LEDGER)
		return result
	var header := file.get_csv_line()
	var key_at := header.find("source_key")
	var chunks_at := header.find("chunk_ids")
	if key_at < 0 or chunks_at < 0:
		failures.append("the coverage ledger has no source_key or chunk_ids column")
		return result
	while not file.eof_reached():
		var line := file.get_csv_line()
		if line.size() <= maxi(key_at, chunks_at):
			continue
		var ids: Array[String] = []
		for id in line[chunks_at].split(";", false):
			ids.append(id.strip_edges())
		result[line[key_at]] = ids
	return result


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _finish(error: String, checked: Array[String] = []) -> void:
	if error != "":
		failures.append(error)
	for part: String in _parents:
		if is_instance_valid(_parents[part]):
			(_parents[part] as Node).free()
	if failures.is_empty():
		print("PASS: no outdoor ground inside an enterable interior: %s" % "; ".join(checked))
		quit(0)
		return
	for message in failures:
		print("FAIL: " + message)
	quit(1)
