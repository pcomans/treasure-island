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
## fences, clutter and parked cars) the outdoor instances. Not checked: a node marked
## interior_of_source_key whose catalog unit lists no passages, and ground that the
## world loader adds beyond those chunk records (the shoreline builder's, and the
## installers' such as the housing family's, Mersea's or the Bulgarian wall's): this
## check does not build it, so it is not read.
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
##
## The shell hides the interior (2026-11-21, after a see-through notch at Building 1's
## rear drum that two reviews of pictures missed): no ray from outside reaches the
## interior or passes through the building's shell, other than through the interior's
## openings. From points just behind the shell (SHELL_OFFSET_M behind each face of its
## walls, partitions and roofs, SHELL_SPAN_M wide or more) and in front of every face of
## the interior, every SHELL_SAMPLE_M across them, rays leave in SHELL_DIRECTIONS
## directions; the chunks under the box round them are built too. A ray that
## leaves the box round the unit and its interior crossing no surface that shows its
## drawn side along it (the renderer draws one-sided surfaces from the front only;
## see-through and shadow-only ones hide nothing, the ground always hides) shows its
## point to a viewer out along it: from the ground, or a jetpack anywhere round and
## above. Behind the shell, that viewer sees the face's back culled, so what lies past it
## shows: a face of the exterior there, facing the viewer, hides it (one face standing in
## front of another); the background or the interior is a hole. Each escape fails
## unless it passes through one of the interior's openings: the quads
## (four corners, in the interior's own space) its meta interior_openings declares,
## each on one of the unit's passages. An escape counts when rays SHELL_JITTER_M to
## either side along the surface escape too, so a numerical crack where two triangles
## share an edge does not fail. Not empty: points on both sides, and the interior seen
## through each opening.

const Catalog := preload("res://game/tests/shared/catalog.gd")
const StudyGeometry := preload("res://game/tests/support/building_study_geometry.gd")
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
## The openings an interior's root declares (see the shell check above).
const OPENINGS_META := "interior_openings"
const SHELL_SAMPLE_M := 1.0
## The shell is the walls, partitions and roofs: points stand behind exterior triangles
## at least this wide (_span). Narrower ones are trim and detail profiles, which close
## no room.
const SHELL_SPAN_M := 0.5
## Each sample is drawn this share of the way in towards its triangle's middle.
const SHELL_SAMPLE_INSET := 0.1
const SHELL_OFFSET_M := 0.002
const SHELL_DIRECTIONS := 32
const SHELL_MARGIN_M := 1.0
## Past a surface it crosses unseen, a ray goes on from this far beyond it.
const SHELL_STEP_M := 0.001
const SHELL_JITTER_M := 0.001
const SHELL_MAX_CROSSINGS := 64
## Escapes are reported by the place they start from, on a grid this coarse; past the
## failure's EXAMPLES, up to SHELL_LISTED_PLACES more places are listed to find them by.
const SHELL_CLUSTER_M := 2.0
const SHELL_LISTED_PLACES := 200
## A surface's drawing (_shell_flags): it hides nothing, its back is drawn too, or its
## back alone.
const SEE_THROUGH := 1
const BOTH_SIDES := 2
const BACK_ONLY := 4
## What a triangle belongs to.
enum Kind { EXTERIOR, INTERIOR, OTHER, GROUND }

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
			report = _check_shell(source, interior, unit.get("passages", []) as Array, chunk_paths, chunk_size)
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


## Every node marked as the source's interior, searched from the root, so one built
## outside the buildings' parent is found and fails the check below.
func _interiors(source: String) -> Array[Node3D]:
	var found: Array[Node3D] = []
	for node: Node in root.find_children("*", "Node3D", true, false):
		if str(node.get_meta(INTERIOR_META, "")) == source:
			found.append(node as Node3D)
	return found


## The checks for one interior: its PASS summary, or "" when it fails.
func _check_interior(source: String, interior: Node3D, passages: Array, rows: Array, chunk_paths: Dictionary, chunk_size: float) -> String:
	var before := failures.size()
	var label := "%s's interior %s" % [source, interior.name]
	if not (_parents[BUILDINGS] as Node).is_ancestor_of(interior):
		failures.append("%s does not hang under the world's buildings, so the ground dressing could grow grass under it" % label)
	var triangles := _drawn_triangles(interior.find_children("*", "MeshInstance3D", true, false), label)
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
		_ground_surfaces(_parents[part] as Node, ground, label)
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


## The shell check for one interior (see the header): its PASS summary, or "" when it
## fails.
func _check_shell(source: String, interior: Node3D, passages: Array, chunk_paths: Dictionary, chunk_size: float) -> String:
	var before := failures.size()
	var label := "%s's shell round its interior %s" % [source, interior.name]
	var started := Time.get_ticks_msec()
	var faces := {"corners": PackedVector3Array(), "normals": PackedVector3Array(), "flags": PackedByteArray(), "kinds": PackedByteArray(), "owners": PackedInt32Array(), "names": []}
	# The unit's exterior and its interior set the box; other buildings and the ground
	# in it hide what stands behind them.
	var unit: Array[Node] = []
	_unit_meshes(_parents[BUILDINGS] as Node, source, unit)
	for instance: Node in unit:
		_shell_faces(instance as GeometryInstance3D, Kind.EXTERIOR, faces, label)
	var drawn_inside := interior.find_children("*", "GeometryInstance3D", true, false)
	for instance: Node in drawn_inside:
		_shell_faces(instance as GeometryInstance3D, Kind.INTERIOR, faces, label)
	var kinds: PackedByteArray = faces.kinds
	if not kinds.has(Kind.EXTERIOR) or not kinds.has(Kind.INTERIOR):
		failures.append("%s: the unit draws %s exterior and its interior %s, so nothing can be checked" % [label, "an" if kinds.has(Kind.EXTERIOR) else "no", "something" if kinds.has(Kind.INTERIOR) else "nothing"])
		return ""
	var box := _bounds(faces.corners as PackedVector3Array).grow(SHELL_MARGIN_M)
	# Every chunk under the box, so the ground is known all round it.
	for i in range(floori(box.position.x / chunk_size), floori(box.end.x / chunk_size) + 1):
		for j in range(floori(box.position.z / chunk_size), floori(box.end.z / chunk_size) + 1):
			var chunk_id := "x_%d__z_%d" % [i, j]
			if chunk_paths.has(chunk_id):
				_build(chunk_id, chunk_paths)
	for part: String in GROUND_PARTS:
		for instance: Node in (_parents[part] as Node).find_children("*", "GeometryInstance3D", true, false):
			_shell_faces(instance as GeometryInstance3D, Kind.GROUND, faces, label, box)
	for instance: Node in (_parents[BUILDINGS] as Node).find_children("*", "GeometryInstance3D", true, false):
		if not unit.has(instance) and not drawn_inside.has(instance):
			_shell_faces(instance as GeometryInstance3D, Kind.OTHER, faces, label, box)
	kinds = faces.kinds
	var corners: PackedVector3Array = faces.corners
	var normals: PackedVector3Array = faces.normals
	var flags: PackedByteArray = faces.flags
	var mesh := TriangleMesh.new()
	if not mesh.create_from_faces(corners):
		failures.append("%s: its %d triangles do not build a TriangleMesh" % [label, kinds.size()])
		return ""
	# The ray caster must name the face it meets: a ray straight at the first exterior face.
	var probe := kinds.find(Kind.EXTERIOR)
	var middle := (corners[probe * 3] + corners[probe * 3 + 1] + corners[probe * 3 + 2]) / 3.0
	var probe_hit := mesh.intersect_ray(middle + normals[probe] * 0.5, -normals[probe])
	if probe_hit.is_empty() or int(probe_hit.get("face_index", -1)) < 0:
		failures.append("%s: the TriangleMesh does not name the face a ray meets (%s), so faces can't be told apart" % [label, probe_hit])
		return ""
	# The ground's tops, so a ray that leaves the box under the ground (where no one
	# stands to see along it) does not count.
	var ground := Surfaces.new(Vector2(box.position.x, box.position.z), Vector2(box.end.x, box.end.z))
	var drawn_by := {Kind.EXTERIOR: 0, Kind.INTERIOR: 0, Kind.OTHER: 0, Kind.GROUND: 0}
	for face in kinds.size():
		drawn_by[kinds[face]] += 1
		if kinds[face] == Kind.GROUND:
			ground.add(corners[face * 3], corners[face * 3 + 1], corners[face * 3 + 2], normals[face].y, 0)
	var triangles_note := "%d exterior, %d interior, %d other buildings' and %d ground triangles" % [drawn_by[Kind.EXTERIOR], drawn_by[Kind.INTERIOR], drawn_by[Kind.OTHER], drawn_by[Kind.GROUND]]
	if ground.count == 0:
		failures.append("%s: no ground is read round it (%s), so rays that leave under the ground can't be told" % [label, triangles_note])
		return ""
	var openings := _openings(interior, passages, label)
	var directions := _sphere(SHELL_DIRECTIONS)
	var seen := PackedInt32Array()
	seen.resize(openings.size())
	var points := {Kind.EXTERIOR: 0, Kind.INTERIOR: 0}
	var rays := 0
	var escapes := 0
	var places := {}
	for face in kinds.size():
		var kind := kinds[face]
		if kind != Kind.EXTERIOR and kind != Kind.INTERIOR or flags[face] & (SEE_THROUGH | BOTH_SIDES) != 0:
			continue
		if kind == Kind.EXTERIOR and _span(corners[face * 3], corners[face * 3 + 1], corners[face * 3 + 2]) < SHELL_SPAN_M:
			continue
		# The side the face draws, and the hidden side the points stand on: behind an
		# exterior face, in front of an interior one.
		var drawn := normals[face] * (-1.0 if flags[face] & BACK_ONLY != 0 else 1.0)
		var offset := drawn * SHELL_OFFSET_M * (-1.0 if kind == Kind.EXTERIOR else 1.0)
		for sample in _triangle_samples(corners[face * 3], corners[face * 3 + 1], corners[face * 3 + 2]):
			var origin := sample + offset
			points[kind] += 1
			var spin := _spin(points[Kind.EXTERIOR] + points[Kind.INTERIOR])
			for direction_value: Vector3 in directions:
				var direction := spin * direction_value
				rays += 1
				var cover := _cover(mesh, origin, direction, direction, faces)
				if int(cover[0]) != -1 or not _leaves_above_ground(origin, direction, box, ground):
					continue
				var opening := _through_opening(origin, direction, openings)
				if opening >= 0:
					seen[opening] += 1
					continue
				# Behind the shell, the viewer sees the face's back culled: a face of the
				# building beyond it, facing the viewer, hides that (one face standing in
				# front of another); the background or the interior there is a hole.
				if kind == Kind.EXTERIOR and _building_beyond(mesh, origin, direction, faces):
					continue
				if not _escape_holds(mesh, origin, direction, drawn, kind, faces):
					continue
				escapes += 1
				var place := Vector3i((origin / SHELL_CLUSTER_M).floor())
				if not places.has(place):
					places[place] = [0, _escape_note(mesh, origin, direction, face, cover, faces)]
				places[place][0] += 1
	if escapes > 0:
		var listed := places.keys()
		listed.sort_custom(func(p: Vector3i, q: Vector3i) -> bool: return int(places[p][0]) > int(places[q][0]))
		var examples: Array[String] = []
		for place: Vector3i in listed.slice(0, EXAMPLES):
			examples.append("%d rays from %s" % [int(places[place][0]), str(places[place][1])])
		failures.append("%s: %d of %d rays from points behind its surfaces reach a viewer outside, from %d places (%s), as %s" % [label, escapes, rays, places.size(), triangles_note, "; ".join(examples)])
		# The next places, for finding them (not part of the verdict).
		for place: Vector3i in listed.slice(EXAMPLES, EXAMPLES + SHELL_LISTED_PLACES):
			print("  also %d rays from %s" % [int(places[place][0]), str(places[place][1])])
	for index in openings.size():
		if seen[index] == 0:
			failures.append("%s: nothing behind its surfaces is seen through opening %d, so the opening or this check is wrong" % [label, index])
	if points[Kind.EXTERIOR] == 0 or points[Kind.INTERIOR] == 0:
		failures.append("%s: %d points behind its exterior and %d in its interior, so the check proves nothing" % [label, points[Kind.EXTERIOR], points[Kind.INTERIOR]])
	if failures.size() > before:
		return ""
	var through := 0
	for count in seen:
		through += count
	return "%s: %d rays from %d points behind its exterior and %d in its interior, none seen from outside but %d through its %d openings (%s; %.1f s)" % [label, rays, points[Kind.EXTERIOR], points[Kind.INTERIOR], through, openings.size(), triangles_note, (Time.get_ticks_msec() - started) / 1000.0]


## The drawn meshes of the unit's own nodes under the buildings: those carrying its
## source key (their source_keys meta, or a derived_object_key naming it), as the world
## harness finds a building's nodes; not its interiors, which carry interior_of_source_key.
func _unit_meshes(parent: Node, source: String, found: Array[Node]) -> void:
	for child: Node in parent.get_children():
		if child.has_meta(INTERIOR_META):
			continue
		var keys: Variant = child.get_meta("source_keys", [])
		var own := keys is Array and (keys as Array).any(func(key: Variant) -> bool: return str(key) == source)
		if own or (":%s:" % source) in str(child.get_meta("derived_object_key", "")):
			if child is GeometryInstance3D:
				found.append(child)
			found.append_array(child.find_children("*", "GeometryInstance3D", true, false))
		else:
			_unit_meshes(child, source, found)


## The triangles an instance draws, in world space, into faces: each one's drawn facing
## (the side Godot's clockwise winding shows, turned by a mirroring transform), its
## surface's flags (_shell_flags), its kind and its owner (the instance and surface).
## Shadow-only and hidden instances draw nothing. With a box, only triangles whose
## bounds meet it are kept.
func _shell_faces(instance: GeometryInstance3D, kind: int, faces: Dictionary, label: String, box := AABB()) -> void:
	if instance == null or not instance.is_visible_in_tree() or instance.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY:
		return
	var mesh: Mesh = null
	var poses: Array[Transform3D] = []
	if instance is MeshInstance3D:
		mesh = (instance as MeshInstance3D).mesh
		poses.append(instance.global_transform)
	elif instance is MultiMeshInstance3D and (instance as MultiMeshInstance3D).multimesh != null:
		var multimesh := (instance as MultiMeshInstance3D).multimesh
		mesh = multimesh.mesh
		var shown := multimesh.instance_count if multimesh.visible_instance_count < 0 else mini(multimesh.visible_instance_count, multimesh.instance_count)
		for index in shown:
			poses.append(instance.global_transform * multimesh.get_instance_transform(index))
	if mesh == null or poses.is_empty():
		return
	if box.size != Vector3.ZERO and not (instance.global_transform * instance.get_aabb()).intersects(box):
		return
	# Each surface's triangle count, in the order the shared collector reads them, and
	# how it is drawn. A surface without indices is drawn straight from its vertices.
	var producer := StudyGeometry.INDEXED_ARRAYS
	var counts: Array[int] = []
	var surface_flags: Array[int] = []
	var owners: Array[int] = []
	for surface in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(surface)
		var indices: Variant = arrays[Mesh.ARRAY_INDEX] if arrays.size() == Mesh.ARRAY_MAX else null
		if indices is PackedInt32Array and not (indices as PackedInt32Array).is_empty():
			counts.append((indices as PackedInt32Array).size() / 3)
		else:
			producer = StudyGeometry.MESH_GET_FACES
			counts.append((arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3 if arrays.size() == Mesh.ARRAY_MAX and arrays[Mesh.ARRAY_VERTEX] is PackedVector3Array else 0)
		surface_flags.append(_shell_flags(instance, mesh, surface))
		var surface_name := (mesh as ArrayMesh).surface_get_name(surface) if mesh is ArrayMesh else ""
		owners.append((faces.names as Array).size())
		(faces.names as Array).append("%s%s" % [instance.name, ":" + surface_name if surface_name != "" else ""])
	var collected := StudyGeometry.collect(mesh, poses, producer)
	var triangles: PackedVector3Array = collected.faces
	if not bool(collected.ok):
		failures.append("%s: the mesh %s can't be read: %s" % [label, instance.get_path(), str(collected.errors)])
		return
	var per_pose := 0
	for count in counts:
		per_pose += count
	if triangles.size() != per_pose * 3 * poses.size():
		# Mesh.get_faces() leaves out the degenerate triangles, so its surfaces can't be
		# told apart: the ground hides whatever its surface, and a mesh of one surface is
		# drawn one way; another is not read.
		if kind != Kind.GROUND and counts.size() != 1:
			failures.append("%s: the mesh %s can't be read surface by surface" % [label, instance.get_path()])
			return
		per_pose = triangles.size() / 3 / poses.size()
		counts.clear()
		counts.append(per_pose)
	var corners: PackedVector3Array = faces.corners
	var normals: PackedVector3Array = faces.normals
	var flags: PackedByteArray = faces.flags
	var kinds: PackedByteArray = faces.kinds
	var owner_of: PackedInt32Array = faces.owners
	for pose_index in poses.size():
		var turn := -1.0 if poses[pose_index].basis.determinant() < 0.0 else 1.0
		var surface := 0
		var surface_end := counts[0] if not counts.is_empty() else 0
		for local in per_pose:
			while local >= surface_end and surface < counts.size() - 1:
				surface += 1
				surface_end += counts[surface]
			var at := (pose_index * per_pose + local) * 3
			var a := triangles[at]
			var b := triangles[at + 1]
			var c := triangles[at + 2]
			var cross := (c - a).cross(b - a)
			if cross.length_squared() < 1e-12:
				continue
			if box.size != Vector3.ZERO:
				var bounds := AABB(a, Vector3.ZERO).expand(b).expand(c)
				if not bounds.intersects(box):
					continue
			corners.append_array([a, b, c])
			normals.append(cross.normalized() * turn)
			flags.append(surface_flags[surface])
			kinds.append(kind)
			owner_of.append(owners[surface])
	faces.corners = corners
	faces.normals = normals
	faces.flags = flags
	faces.kinds = kinds
	faces.owners = owner_of


## How a surface is drawn: SEE_THROUGH when it hides nothing behind it (alpha, a blend
## other than mix, an instance drawn transparent), BOTH_SIDES when its back is drawn too,
## BACK_ONLY when only its back is.
static func _shell_flags(instance: GeometryInstance3D, mesh: Mesh, surface: int) -> int:
	var flags := SEE_THROUGH if instance.transparency > 0.0 else 0
	var material: Material = instance.material_override
	if material == null and instance is MeshInstance3D:
		material = (instance as MeshInstance3D).get_active_material(surface)
	elif material == null:
		material = mesh.surface_get_material(surface)
	if material is BaseMaterial3D:
		var base := material as BaseMaterial3D
		if base.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED or base.blend_mode != BaseMaterial3D.BLEND_MODE_MIX:
			flags |= SEE_THROUGH
		if base.cull_mode == BaseMaterial3D.CULL_DISABLED:
			flags |= BOTH_SIDES
		elif base.cull_mode == BaseMaterial3D.CULL_FRONT:
			flags |= BACK_ONLY
	elif material is ShaderMaterial and (material as ShaderMaterial).shader != null:
		var code := (material as ShaderMaterial).shader.code
		var modes: Array[String] = []
		var found := RegEx.create_from_string("render_mode\\s+([^;]*);").search(code)
		if found != null:
			for mode in found.get_string(1).split(","):
				modes.append(mode.strip_edges())
		if modes.has("cull_disabled"):
			flags |= BOTH_SIDES
		elif modes.has("cull_front"):
			flags |= BACK_ONLY
		if modes.has("blend_add") or modes.has("blend_sub") or modes.has("blend_mul") or RegEx.create_from_string("\\bALPHA\\s*=(?!=)").search(code) != null:
			flags |= SEE_THROUGH
	return flags


## The interior's declared openings in world space, each checked to lie on one of the
## unit's passages (its bottom edge crosses the passage in plan), every passage through
## one of them, and each wound to face out along its passage (_through_opening).
func _openings(interior: Node3D, passages: Array, label: String) -> Array[PackedVector3Array]:
	var openings: Array[PackedVector3Array] = []
	var declared: Variant = interior.get_meta(OPENINGS_META, [])
	if not declared is Array:
		failures.append("%s: its meta %s is not a list of quads" % [label, OPENINGS_META])
		return openings
	for quad_value: Variant in declared:
		if not quad_value is PackedVector3Array or (quad_value as PackedVector3Array).size() != 4:
			failures.append("%s: an opening is not four corners: %s" % [label, str(quad_value)])
			continue
		var quad := PackedVector3Array()
		for corner: Vector3 in quad_value:
			quad.append(interior.global_transform * corner)
		openings.append(quad)
	var on_passage := {}
	for passage: Variant in passages:
		var ends := passage as Dictionary if passage is Dictionary else {}
		var outside: Variant = ends.get("outside", null)
		var inside: Variant = ends.get("inside", null)
		if not outside is Array or not inside is Array or (outside as Array).size() != 2 or (inside as Array).size() != 2:
			failures.append("%s: passage %s has no outside and inside ends" % [label, str(ends.get("name", ""))])
			continue
		var from := Vector2(float(outside[0]), float(outside[1]))
		var to := Vector2(float(inside[0]), float(inside[1]))
		var through := false
		for index in openings.size():
			var quad := openings[index]
			if Geometry2D.segment_intersects_segment(from, to, Vector2(quad[0].x, quad[0].z), Vector2(quad[1].x, quad[1].z)) != null:
				on_passage[index] = true
				through = true
				if (quad[1] - quad[0]).cross(quad[3] - quad[0]).dot(Vector3(from.x, quad[0].y, from.y) - quad[0]) < 0.0:
					openings[index] = PackedVector3Array([quad[0], quad[3], quad[2], quad[1]])
		if not through:
			failures.append("%s: passage %s goes through none of its openings" % [label, str(ends.get("name", ""))])
	for index in openings.size():
		if not on_passage.has(index):
			failures.append("%s: opening %d lies on none of its passages" % [label, index])
	return openings


## The first face a ray from origin along travel meets that a viewer out along toward
## sees (its drawn side faces toward, or it is drawn both sides), or the ground, stepping
## past those it crosses unseen: [face, or -1 when it meets none, crossings, the last
## face crossed, where]. Past SHELL_MAX_CROSSINGS it counts as hidden.
func _cover(mesh: TriangleMesh, origin: Vector3, travel: Vector3, toward: Vector3, faces: Dictionary) -> Array:
	var normals: PackedVector3Array = faces.normals
	var flags: PackedByteArray = faces.flags
	var kinds: PackedByteArray = faces.kinds
	var from := origin
	var last := -1
	var last_at := origin
	for crossing in SHELL_MAX_CROSSINGS:
		var hit := mesh.intersect_ray(from, travel)
		if hit.is_empty():
			return [-1, crossing, last, last_at]
		var face := int(hit.face_index)
		if kinds[face] == Kind.GROUND:
			return [face, crossing, last, last_at]
		var flag := flags[face]
		if flag & SEE_THROUGH == 0:
			var facing := normals[face].dot(toward)
			if flag & BOTH_SIDES != 0 or (facing < 0.0 if flag & BACK_ONLY != 0 else facing > 0.0):
				return [face, crossing, last, last_at]
		last = face
		last_at = hit.position
		from = last_at + travel * SHELL_STEP_M
	return [last, SHELL_MAX_CROSSINGS, last, last_at]


## Whether a viewer out along direction, looking back past origin, sees a face of the
## building's exterior there.
func _building_beyond(mesh: TriangleMesh, origin: Vector3, direction: Vector3, faces: Dictionary) -> bool:
	var beyond := int(_cover(mesh, origin, -direction, direction, faces)[0])
	return beyond >= 0 and (faces.kinds as PackedByteArray)[beyond] == Kind.EXTERIOR


## The escape holds for rays SHELL_JITTER_M to either side of the origin, along the
## surface it stands by (so they keep its side): they reach the viewer too, and behind
## the shell nothing of the building's exterior hides the hole either.
func _escape_holds(mesh: TriangleMesh, origin: Vector3, direction: Vector3, normal: Vector3, kind: int, faces: Dictionary) -> bool:
	var side := direction.cross(normal)
	if side.length_squared() < 1e-8:
		side = direction.cross(Vector3.UP if absf(direction.y) < 0.9 else Vector3.RIGHT)
	side = side.normalized()
	var along := normal.cross(side).normalized()
	for shift: Vector3 in [side, -side, along, -along]:
		var shifted := origin + shift * SHELL_JITTER_M
		if int(_cover(mesh, shifted, direction, direction, faces)[0]) != -1:
			return false
		if kind == Kind.EXTERIOR and _building_beyond(mesh, shifted, direction, faces):
			return false
	return true


## Whether a ray from inside the box leaves it where someone could stand to look back
## along it: through its top, or through a side above the ground there.
static func _leaves_above_ground(origin: Vector3, direction: Vector3, box: AABB, ground: Surfaces) -> bool:
	var reach := INF
	var axis := -1
	for index in 3:
		if absf(direction[index]) < 1e-9:
			continue
		var bound := box.end[index] if direction[index] > 0.0 else box.position[index]
		var along := (bound - origin[index]) / direction[index]
		if along < reach:
			reach = along
			axis = index
	if axis == 1:
		return direction.y > 0.0
	var leaving := origin + direction * reach
	var top := ground.top(leaving.x, leaving.z)
	return top.is_empty() or leaving.y > float(top[0])


## Which opening (index) a ray passes through, or -1. A point standing out in front of
## an opening, within its outline, is in the doorway itself (a threshold or reveal of
## the interior's), so its rays go out through it too.
static func _through_opening(origin: Vector3, direction: Vector3, openings: Array[PackedVector3Array]) -> int:
	for index in openings.size():
		var quad := openings[index]
		if Geometry3D.ray_intersects_triangle(origin, direction, quad[0], quad[1], quad[2]) != null or Geometry3D.ray_intersects_triangle(origin, direction, quad[0], quad[2], quad[3]) != null:
			return index
		var outward := (quad[1] - quad[0]).cross(quad[3] - quad[0]).normalized()
		if (origin - quad[0]).dot(outward) > 0.0 and (Geometry3D.ray_intersects_triangle(origin, -outward, quad[0], quad[1], quad[2]) != null or Geometry3D.ray_intersects_triangle(origin, -outward, quad[0], quad[2], quad[3]) != null):
			return index
	return -1


## Where an escape starts and goes, what it passes unseen and, behind the shell, what the
## viewer sees past it.
func _escape_note(mesh: TriangleMesh, origin: Vector3, direction: Vector3, face: int, cover: Array, faces: Dictionary) -> String:
	var names: Array = faces.names
	var owners: PackedInt32Array = faces.owners
	var exterior := (faces.kinds as PackedByteArray)[face] == Kind.EXTERIOR
	var note := "%s (%s) at (%.2f, %.2f, %.2f) towards (%.2f, %.2f, %.2f)" % [names[owners[face]], "behind it" if exterior else "in front", origin.x, origin.y, origin.z, direction.x, direction.y, direction.z]
	if int(cover[2]) >= 0:
		var at: Vector3 = cover[3]
		note += ", past %d surfaces seen from behind, the last %s at (%.2f, %.2f, %.2f)" % [int(cover[1]), names[owners[int(cover[2])]], at.x, at.y, at.z]
	if exterior:
		var beyond := int(_cover(mesh, origin, -direction, direction, faces)[0])
		note += ", showing %s past it" % (names[owners[beyond]] if beyond >= 0 else "the background")
	return note


## How wide a triangle is across its longest side (its height over that side).
static func _span(a: Vector3, b: Vector3, c: Vector3) -> float:
	return (b - a).cross(c - a).length() / maxf(a.distance_to(b), maxf(b.distance_to(c), c.distance_to(a)))


## Points over a triangle about one per SHELL_SAMPLE_M square (at least its middle),
## spread by the plastic-number sequence and drawn in towards its middle
## (SHELL_SAMPLE_INSET), so none stands on an edge or corner that two faces share.
static func _triangle_samples(a: Vector3, b: Vector3, c: Vector3) -> PackedVector3Array:
	var samples := PackedVector3Array()
	var e1 := b - a
	var e2 := c - a
	var middle := a + (e1 + e2) / 3.0
	var count := maxi(1, roundi(e1.cross(e2).length() * 0.5 / (SHELL_SAMPLE_M * SHELL_SAMPLE_M)))
	if count == 1:
		samples.append(middle)
		return samples
	for index in count:
		var u := fposmod(0.5 + float(index) * 0.7548776662466927, 1.0)
		var v := fposmod(0.5 + float(index) * 0.5698402909980532, 1.0)
		if u + v > 1.0:
			u = 1.0 - u
			v = 1.0 - v
		samples.append(middle.lerp(a + e1 * u + e2 * v, 1.0 - SHELL_SAMPLE_INSET))
	return samples


## count directions spread evenly over the sphere (a Fibonacci lattice).
static func _sphere(count: int) -> Array[Vector3]:
	var directions: Array[Vector3] = []
	for index in count:
		var y := 1.0 - 2.0 * (float(index) + 0.5) / float(count)
		var radius := sqrt(maxf(0.0, 1.0 - y * y))
		var angle := float(index) * 2.399963229728653
		directions.append(Vector3(radius * cos(angle), y, radius * sin(angle)))
	return directions


## A turn of the direction set for the point counted index, so neighbouring points look
## along different rays.
static func _spin(index: int) -> Basis:
	return Basis(Vector3.UP, fposmod(float(index) * 0.6180339887498949, 1.0) * TAU) * Basis(Vector3.RIGHT, fposmod(float(index) * 0.7548776662466927, 1.0) * TAU)


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


## The triangles these MeshInstance3D nodes draw, in world space: the shared collector's
## (building_study_geometry.gd) indexed arrays, which the renderer draws, with
## each triangle's facing, the side its clockwise winding shows (Godot's front faces; a
## mirroring transform turns it): {"corners": three per triangle, "normals": one per
## triangle}. A mesh it can't read is a failure.
func _drawn_triangles(meshes: Array[Node], label: String) -> Dictionary:
	var corners := PackedVector3Array()
	var facings := PackedVector3Array()
	for found: Node in meshes:
		var instance := found as MeshInstance3D
		if instance.mesh == null or not instance.is_visible_in_tree():
			continue
		# A surface without indices is drawn straight from its vertices, as Mesh.get_faces() reads it.
		var producer := StudyGeometry.INDEXED_ARRAYS
		if instance.mesh is ArrayMesh:
			for surface in instance.mesh.get_surface_count():
				if (instance.mesh as ArrayMesh).surface_get_array_index_len(surface) <= 0:
					producer = StudyGeometry.MESH_GET_FACES
		var pose: Array[Transform3D] = [instance.global_transform]
		var collected := StudyGeometry.collect(instance.mesh, pose, producer)
		if not bool(collected.ok):
			failures.append("%s: the mesh %s can't be read: %s" % [label, instance.get_path(), str(collected.errors)])
			continue
		var faces: PackedVector3Array = collected.faces
		var turn := -1.0 if instance.global_transform.basis.determinant() < 0.0 else 1.0
		for t in range(0, faces.size(), 3):
			facings.append((faces[t + 2] - faces[t]).cross(faces[t + 1] - faces[t]).normalized() * turn)
		corners.append_array(faces)
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


## The outdoor ground's triangles under parent: every drawn surface (_drawn_triangles)
## and every solid shape's faces (a kerb's support ramp is solid only), each named for
## its generated record.
func _ground_surfaces(parent: Node, surfaces: Surfaces, label: String) -> void:
	for found: Node in parent.find_children("*", "", true, false):
		var triangles := PackedVector3Array()
		if found is MeshInstance3D:
			var mesh: Array[Node] = [found]
			triangles = _drawn_triangles(mesh, label).corners
		elif found is CollisionShape3D and (found as CollisionShape3D).shape is ConcavePolygonShape3D:
			var to_world := (found as CollisionShape3D).global_transform
			for corner in ((found as CollisionShape3D).shape as ConcavePolygonShape3D).get_faces():
				triangles.append(to_world * corner)
		if triangles.is_empty():
			continue
		var owner := surfaces.names.size()
		surfaces.names.append(_record_name(found))
		for t in range(0, triangles.size() - 2, 3):
			surfaces.add(triangles[t], triangles[t + 1], triangles[t + 2], 0.0, owner)


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
		print("PASS: no outdoor ground inside an enterable interior, and its building's shell hides it but for its openings: %s" % "; ".join(checked))
		quit(0)
		return
	for message in failures:
		print("FAIL: " + message)
	quit(1)
