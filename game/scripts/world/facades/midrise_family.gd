extends RefCounted
## Shared modern mid-rise apartment family: courtyard blocks over one frozen footprint.
##
## build(wall, roof, cfg) follows the housing_site_family contract: it returns a
## root with build_valid/source_key metadata whose MeshInstance3D children carry
## family_role wall, roof, support or ground. housing_family_live_attachment
## hides the generated record meshes and adds the matching source-owned contacts.
##
## The frozen wall record supplies the footprint ring and the frozen land records
## the actual terrain under walls, landings and aprons; the instance config
## supplies everything else:
## blocks clipped from the footprint by edge-relative half-planes, per-face facade
## schemes (bays, windows, loggias, bands, entries) and roof items. Blocks tile
## the footprint as 2.5D extrusions; walls are emitted only where a block rises
## above its neighbours or the ground, so the outer ring stays the footprint.
## Opt-in outbuilding fields (pitched roofs, pipe railings, open post sides,
## raised entries with ramps, cylinders and caged ladders, a whole-ring floor
## anchor) cover sheds, tanks, trailers and pavilions; configs without them build
## as before.
## Dimensions, cadence and unseen sides are production inference.
## See game/resources/midrise_family/README.md for the config fields.

const SCHEMA := "ti.midrise-family/1"
const ROLES := ["wall", "roof", "support", "ground"]
const FACE_COS := 0.98
const FACE_BAND_M := 2.5
const BURY_M := 0.25
const COLLINEAR_M := 0.002
const MIN_PIER_M := 0.18
const GRADE_CLEARANCE_M := 0.25
## Walls of a pitched block rise this far into the roof slab, so the eave line
## has no shared edge to crack open.
const PITCH_TUCK_M := 0.02
const RAIL_H_M := 1.07
const RAIL_BAR_M := 0.045
## Materials shared by value across instances; never mutated after creation.
static var _material_cache: Dictionary = {}


class Bucket:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var misaligned := 0

	## Emits one triangle whose front (Godot clockwise winding) faces `facing`.
	func tri(a: Vector3, b: Vector3, c: Vector3, facing: Vector3) -> void:
		var cross := (b - a).cross(c - a)
		# Skip slivers under 0.5 cm2: invisible, and their facing is numerically unreliable.
		if cross.length_squared() < 1e-8:
			return
		if absf(cross.normalized().dot(facing.normalized())) < 0.2:
			misaligned += 1
			return
		var second := b
		var third := c
		if cross.dot(facing) > 0.0:
			second = c
			third = b
			cross = -cross
		var normal := -cross.normalized()
		var flat := absf(normal.y) > 0.7
		var tangent := Vector3.RIGHT if flat else Vector3(-normal.z, 0.0, normal.x).normalized()
		for p: Vector3 in [a, second, third]:
			vertices.append(p)
			normals.append(normal)
			uvs.append(Vector2(p.x, p.z) if flat else Vector2(p.dot(tangent), -p.y))

	func quad(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, facing: Vector3) -> void:
		tri(p0, p1, p2, facing)
		tri(p0, p2, p3, facing)


## One frozen footprint edge: merged collinear wall runs. Run ends are the
## generator's land-facet crossings, so terrain is linear between stations.
class Edge:
	var start := Vector2.ZERO
	var end := Vector2.ZERO
	var d := Vector2.ZERO
	var n := Vector2.ZERO
	var length := 0.0
	var stations := PackedFloat64Array()

	func station(p: Vector2) -> float:
		return (p - start).dot(d)

	func depth(p: Vector2) -> float:
		return -(p - start).dot(n)

	func at(s: float, inward: float) -> Vector2:
		return start + d * s - n * inward


class Block:
	var id := ""
	var cfg: Dictionary = {}
	var poly := PackedVector2Array()
	var floors := PackedFloat64Array()
	var storeys := 0
	var roof_y := 0.0
	var top_y := 0.0
	var wall_top := 0.0
	var railing := false
	var form := "flat"
	## Pitched roof facets [u: Vector2, c: float, k: float]: underside height is
	## roof_y + k * (u.dot(p) - c) for the lowest facet.
	var planes: Array = []
	## Courtyard holes inside this block (flat blocks only).
	var holes: Array[PackedVector2Array] = []


## One exposed block edge with its facade scheme and station mapping.
class Face:
	var block: Block
	var a := Vector2.ZERO
	var d := Vector2.ZERO
	var n := Vector2.ZERO
	var length := 0.0
	var key := ""
	var edge := -1
	var scheme: Dictionary = {}
	var spans: Array = []
	var index := 0
	var poly_index := 0
	var top_xs: Array = []

	func point(s: float, y: float, depth: float) -> Vector3:
		var p := a + d * s - n * depth
		return Vector3(p.x, y, p.y)

	func out3() -> Vector3:
		return Vector3(n.x, 0.0, n.y)

	func dir3() -> Vector3:
		return Vector3(d.x, 0.0, d.y)


class Ctx:
	var cfg: Dictionary = {}
	var source := ""
	var floor_y := 0.0
	var edges: Array = []
	var blocks: Array = []
	var buckets: Dictionary = {}
	var materials: Dictionary = {}
	var errors: Array[String] = []
	var skipped: Array[String] = []
	var faces := 0
	var land: Array = []
	var terrain_misses := 0
	var levels := PackedFloat64Array()
	## Inner rings of a multi-ring wall record (courtyard holes, opt-in via target.holes).
	var holes: Array[PackedVector2Array] = []

	func bucket(role: String, mat: String) -> Bucket:
		var key := role + "|" + mat
		if not buckets.has(key):
			buckets[key] = Bucket.new()
		return buckets[key]


## chunks: the validated world chunks; their land_ground triangles seat walls and landings.
static func build(wall: Dictionary, roof: Dictionary, cfg: Dictionary, chunks: Array = []) -> Node3D:
	var root := Node3D.new()
	var target: Dictionary = cfg.get("target", {})
	var source := str(target.get("source_key", ""))
	root.name = "SharedMidrise_" + source
	root.set_meta("source_key", source)
	root.set_meta("scope", "experimental_visual_only_collision_unchanged")
	root.set_meta("dimensions", "production_inference_from_dated_references")
	var ctx := Ctx.new()
	ctx.cfg = cfg
	ctx.source = source
	_build_all(ctx, wall, roof, chunks)
	if ctx.terrain_misses > 0:
		ctx.errors.append("%d terrain samples fell outside the frozen land" % ctx.terrain_misses)
	var misaligned := 0
	for key: String in ctx.buckets:
		misaligned += (ctx.buckets[key] as Bucket).misaligned
	if misaligned > 0:
		ctx.errors.append("%d triangles had no clear facing" % misaligned)
	var triangles := 0
	if ctx.errors.is_empty():
		triangles = _emit(ctx, root)
		if triangles <= 0:
			ctx.errors.append("no geometry emitted")
	for message: String in ctx.errors:
		push_error("Mid-rise family %s: %s" % [source, message])
	root.set_meta("build_valid", ctx.errors.is_empty())
	root.set_meta("midrise_triangles", triangles)
	root.set_meta("midrise_skipped_features", ctx.skipped.duplicate())
	return root


static func _build_all(ctx: Ctx, wall: Dictionary, roof: Dictionary, chunks: Array) -> void:
	if str(ctx.cfg.get("schema_version", "")) != SCHEMA:
		ctx.errors.append("unsupported config schema")
		return
	if ctx.source.is_empty() or wall.get("source_keys", []) != [ctx.source] or roof.get("source_keys", []) != [ctx.source]:
		ctx.errors.append("wall/roof records do not belong to the configured source")
		return
	ctx.edges = _footprint(ctx, wall)
	if not ctx.errors.is_empty():
		return
	_collect_land(ctx, chunks)
	if ctx.land.is_empty():
		ctx.errors.append("no frozen land triangles under the footprint")
		return
	# Floor at the median frozen terrain along the photographed street side plus a
	# small clearance. Higher terrain elsewhere meets the walls (ground-storey sills
	# rise above it); lower terrain exposes the plinth.
	# "ring" samples every edge, for buildings with no single street side (tanks).
	var floor_cfg: Dictionary = ctx.cfg.get("floor", {})
	var anchor_value: Variant = floor_cfg.get("anchor_edge", -1)
	var lines: Array = ctx.edges
	if not (anchor_value is String and anchor_value == "ring"):
		var anchor := int(anchor_value)
		if anchor < 0 or anchor >= ctx.edges.size():
			ctx.errors.append("floor needs the photographed street side (or \"ring\") as anchor_edge")
			return
		lines = [ctx.edges[anchor]]
	var grades: Array[float] = []
	for street: Edge in lines:
		var samples := maxi(8, ceili(street.length))
		for i in samples:
			grades.append(_ground_y(ctx, street.at(street.length * (float(i) + 0.5) / float(samples), 0.0)))
	grades.sort()
	var count := grades.size()
	var middle := count >> 1
	var median := grades[middle] if count % 2 == 1 else (grades[middle - 1] + grades[middle]) * 0.5
	ctx.floor_y = median + float(floor_cfg.get("above_terrain", 0.05))
	if not is_finite(ctx.floor_y) or ctx.terrain_misses > 0:
		ctx.errors.append("footprint floor level is not on frozen land")
		return
	_make_materials(ctx)
	_make_blocks(ctx)
	if not ctx.errors.is_empty():
		return
	var levels: Array = []
	for block: Block in ctx.blocks:
		levels.append_array(Array(_block_levels(block, block.cfg.get("faces", {}), ctx.cfg.get("schemes", {}))))
		levels.append(block.wall_top)
	levels.sort()
	ctx.levels = PackedFloat64Array(levels)
	for block: Block in ctx.blocks:
		_block_faces(ctx, block)
		_roof(ctx, block)
	for apron: Dictionary in ctx.cfg.get("aprons", []):
		_apron(ctx, apron)


# ------------------------------------------------------------------ footprint

static func _footprint(ctx: Ctx, wall: Dictionary) -> Array:
	var v: Array = wall.get("vertices", [])
	var nr: Array = wall.get("normals", [])
	if v.size() < 36 or v.size() % 12 != 0 or nr.size() != v.size():
		ctx.errors.append("wall record is not a quad-run ring")
		return []
	var groups: Array = []
	var previous_end := Vector3(INF, INF, INF)
	# Opt-in: target.holes names how many further closed rings (courtyard holes)
	# follow the outer ring. Without it a second ring stays an error, as before.
	var target: Dictionary = ctx.cfg.target
	var hole_count := int(target.get("holes", 0))
	var ring_start := Vector2(INF, INF)
	var in_outer := true
	var hole := PackedVector2Array()
	for i in range(0, v.size(), 12):
		var a := Vector3(float(v[i]), float(v[i + 1]), float(v[i + 2]))
		var b := Vector3(float(v[i + 3]), float(v[i + 4]), float(v[i + 5]))
		var normal := Vector2(float(nr[i]), float(nr[i + 2])).normalized()
		if not ring_start.is_finite():
			ring_start = Vector2(a.x, a.z)
		elif Vector2(previous_end.x, previous_end.z).distance_to(Vector2(a.x, a.z)) > 0.001:
			# A new ring may start only where the previous one closed.
			if hole_count == 0 or Vector2(previous_end.x, previous_end.z).distance_to(ring_start) > 0.001:
				ctx.errors.append("wall runs are not contiguous")
				return []
			if not in_outer:
				ctx.holes.append(hole)
			in_outer = false
			hole = PackedVector2Array()
			ring_start = Vector2(a.x, a.z)
		previous_end = b
		if not in_outer:
			hole.append(Vector2(a.x, a.z))
			continue
		if groups.is_empty() or (groups[-1].n as Vector2).dot(normal) < 0.9999:
			groups.append({"n": normal, "points": [a]})
		(groups[-1].points as Array).append(b)
	if Vector2(previous_end.x, previous_end.z).distance_to(ring_start) > 0.001:
		ctx.errors.append("wall ring is not closed")
		return []
	if not in_outer:
		ctx.holes.append(hole)
	if ctx.holes.size() != hole_count:
		ctx.errors.append("footprint has %d holes, config expects %d" % [ctx.holes.size(), hole_count])
		return []
	var expected: Array = target.get("edge_normals", [])
	if groups.size() != expected.size():
		ctx.errors.append("footprint has %d edges, config expects %d" % [groups.size(), expected.size()])
		return []
	var edges: Array = []
	for k in groups.size():
		var points: Array = groups[k].points
		var edge := Edge.new()
		var p0: Vector3 = points[0]
		var p1: Vector3 = points[-1]
		edge.start = Vector2(p0.x, p0.z)
		edge.end = Vector2(p1.x, p1.z)
		edge.length = edge.start.distance_to(edge.end)
		edge.d = (edge.end - edge.start) / edge.length
		# Exact perpendicular of the frozen edge; the rounded record normal only orients it.
		var recorded: Vector2 = groups[k].n
		edge.n = Vector2(edge.d.y, -edge.d.x)
		if edge.n.dot(recorded) < 0.0:
			edge.n = -edge.n
		var want := Vector2(float(expected[k][0]), float(expected[k][1])).normalized()
		if edge.n.dot(want) < 0.9995 or edge.n.dot(recorded) < 0.9995:
			ctx.errors.append("footprint edge %d normal differs from the configured identity" % k)
			return []
		for p: Vector3 in points:
			if absf(edge.depth(Vector2(p.x, p.z))) > 0.01:
				ctx.errors.append("footprint edge %d runs are not collinear" % k)
				return []
			edge.stations.append(edge.station(Vector2(p.x, p.z)))
		edges.append(edge)
	return edges


## Land triangles near the footprint from the frozen world chunks.
static func _collect_land(ctx: Ctx, chunks: Array) -> void:
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	for edge: Edge in ctx.edges:
		low = low.min(edge.start)
		high = high.max(edge.start)
	low -= Vector2(30.0, 30.0)
	high += Vector2(30.0, 30.0)
	for chunk: Variant in chunks:
		if not chunk is Dictionary:
			continue
		for record: Variant in (chunk as Dictionary).get("records", []):
			if not record is Dictionary or str((record as Dictionary).get("feature_kind", "")) != "land_ground":
				continue
			var v: Array = record.vertices
			var indices: Array = record.indices
			for i in range(0, indices.size(), 3):
				var tri := PackedVector3Array()
				for j in 3:
					var k := int(indices[i + j]) * 3
					tri.append(Vector3(float(v[k]), float(v[k + 1]), float(v[k + 2])))
				var tmin := Vector2(minf(tri[0].x, minf(tri[1].x, tri[2].x)), minf(tri[0].z, minf(tri[1].z, tri[2].z)))
				var tmax := Vector2(maxf(tri[0].x, maxf(tri[1].x, tri[2].x)), maxf(tri[0].z, maxf(tri[1].z, tri[2].z)))
				if tmax.x < low.x or tmin.x > high.x or tmax.y < low.y or tmin.y > high.y:
					continue
				ctx.land.append(tri)


## Frozen terrain elevation under a plan point (barycentric on its land triangle).
## A footprint clipped at the shore runs along the land boundary, so a miss gets
## a second pass with a small barycentric tolerance before it counts.
static func _ground_y(ctx: Ctx, p: Vector2) -> float:
	for tolerance: float in [1e-7, 1e-4]:
		for tri: PackedVector3Array in ctx.land:
			var a := tri[0]
			var b := tri[1]
			var c := tri[2]
			var den := (b.z - c.z) * (a.x - c.x) + (c.x - b.x) * (a.z - c.z)
			if absf(den) < 1e-9:
				continue
			var w1 := ((b.z - c.z) * (p.x - c.x) + (c.x - b.x) * (p.y - c.z)) / den
			var w2 := ((c.z - a.z) * (p.x - c.x) + (a.x - c.x) * (p.y - c.z)) / den
			var w3 := 1.0 - w1 - w2
			if w1 >= -tolerance and w2 >= -tolerance and w3 >= -tolerance:
				return w1 * a.y + w2 * b.y + w3 * c.y
	ctx.terrain_misses += 1
	return ctx.floor_y


## Highest frozen terrain along a face between two stations (ends and 0.5 m steps).
static func _ground_max(ctx: Ctx, face: Face, s0: float, s1: float) -> float:
	var high := maxf(_ground_y(ctx, face.a + face.d * s0), _ground_y(ctx, face.a + face.d * s1))
	var s := s0 + 0.5
	while s < s1:
		high = maxf(high, _ground_y(ctx, face.a + face.d * s))
		s += 0.5
	return high


## Landing top above the highest terrain under its pad, skirts and any porch floor.
static func _landing(ctx: Ctx, face: Face, center: float, width: float, depth: float, inside: float) -> Dictionary:
	var high := -INF
	var low := INF
	for i in 7:
		var s := center - width * 0.5 - 0.3 + (width + 0.6) * float(i) / 6.0
		for j in 7:
			var d := inside - (inside + depth + 0.3) * float(j) / 6.0
			var y := _ground_y(ctx, face.a + face.d * s - face.n * d)
			high = maxf(high, y)
			low = minf(low, y)
	var top := high + 0.1
	return {"y": top, "drop": maxf(0.25, top - low + 0.12)}


# --------------------------------------------------------------------- blocks

static func _make_blocks(ctx: Ctx) -> void:
	var ring := PackedVector2Array()
	for edge: Edge in ctx.edges:
		ring.append(edge.start)
	var footprint_area := absf(_area(ring))
	var levels: Dictionary = ctx.cfg.get("levels", {})
	var total := 0.0
	var ids: Dictionary = {}
	for item: Dictionary in ctx.cfg.get("blocks", []):
		var block := Block.new()
		block.id = str(item.get("id", ""))
		block.cfg = item
		if block.id.is_empty() or ids.has(block.id):
			ctx.errors.append("block ids must be unique and nonempty")
			return
		ids[block.id] = true
		var poly := ring.duplicate()
		for clip: Dictionary in item.get("clip", []):
			for plane: Array in _planes(ctx, clip):
				poly = _clip(poly, plane[0], plane[1])
		if poly.size() < 3 or absf(_area(poly)) < 1.0:
			ctx.errors.append("block %s clips to nothing" % block.id)
			return
		block.poly = poly
		total += absf(_area(poly))
		var raise := float(item.get("floor_raise", 0.0))
		if not _in_range(raise, 0.0, 10.0):
			ctx.errors.append("block %s floor_raise must be 0-10 m" % block.id)
			return
		var floor_y := float(item.get("floor_y", ctx.floor_y + raise))
		var ground_h := float(item.get("ground_h", levels.get("ground_h", 4.0)))
		var storey_h := float(item.get("storey_h", levels.get("storey_h", 3.0)))
		block.storeys = int(item.get("storeys", 0))
		if block.storeys < 1 or ground_h <= 0.0 or storey_h <= 0.0:
			ctx.errors.append("block %s needs positive storeys and heights" % block.id)
			return
		block.floors.append(floor_y)
		for k in range(1, block.storeys + 1):
			block.floors.append(floor_y + ground_h + storey_h * float(k - 1))
		block.roof_y = block.floors[block.storeys]
		var parapet: Dictionary = item.get("parapet", {})
		block.railing = str(parapet.get("kind", "wall")) == "railing"
		var parapet_h := float(parapet.get("h", levels.get("parapet_h", 1.0)))
		block.top_y = block.roof_y + parapet_h
		block.wall_top = block.roof_y + float(parapet.get("curb", 0.3)) if block.railing else block.top_y
		var roof_cfg: Dictionary = item.get("roof", {})
		block.form = str(roof_cfg.get("form", "flat"))
		if block.form != "flat":
			var pitch := float(roof_cfg.get("pitch_deg", 15.0))
			var slab := float(roof_cfg.get("t", 0.15))
			var overhang := float(roof_cfg.get("overhang", 0.0))
			if not (_in_range(pitch, 0.0, 60.0) and pitch > 0.0) or not (_in_range(slab, 0.0, 1.0) and slab > 0.0) or not _in_range(overhang, 0.0, 3.0):
				ctx.errors.append("block %s roof needs pitch_deg in (0, 60], t in (0, 1] and overhang in [0, 3] m" % block.id)
				return
			if block.form not in ["gable", "mono", "pyramid"] or not _convex(poly):
				ctx.errors.append("block %s needs a convex outline for a gable, mono or pyramid roof" % block.id)
				return
			block.railing = false
			block.top_y = block.roof_y + PITCH_TUCK_M
			block.wall_top = block.top_y
			block.planes = _roof_planes(ctx, block, roof_cfg)
			if block.planes.is_empty():
				ctx.errors.append("block %s roof needs a valid ridge_edge or low_edge" % block.id)
				return
		if item.has("pergola"):
			if not _pergola_valid(ctx, block):
				return
			block.railing = false
			block.top_y = block.roof_y
			block.wall_top = block.roof_y
		ctx.blocks.append(block)
	if total > footprint_area + 0.05:
		ctx.errors.append("blocks overlap or exceed the footprint (%.3f > %.3f m2)" % [total, footprint_area])
		return
	# A hole (courtyard) lies wholly inside one flat block, which builds its walls,
	# parapets and roof around it.
	for hole: PackedVector2Array in ctx.holes:
		var owner: Block = null
		for block: Block in ctx.blocks:
			var inside := 0
			for p: Vector2 in hole:
				if Geometry2D.is_point_in_polygon(p, block.poly):
					inside += 1
			# Every vertex inside is not enough for a concave block: no edge may cross.
			for i in hole.size():
				for j in block.poly.size():
					if Geometry2D.segment_intersects_segment(hole[i], hole[(i + 1) % hole.size()], block.poly[j], block.poly[(j + 1) % block.poly.size()]) != null:
						inside = -1
			if inside == hole.size():
				owner = block
			elif inside > 0:
				ctx.errors.append("footprint hole crosses block %s" % block.id)
				return
		if owner == null or owner.form != "flat":
			ctx.errors.append("footprint hole needs one flat block around it")
			return
		owner.holes.append(hole)
	for i in ctx.blocks.size():
		for j in range(i + 1, ctx.blocks.size()):
			for piece: PackedVector2Array in Geometry2D.intersect_polygons((ctx.blocks[i] as Block).poly, (ctx.blocks[j] as Block).poly):
				if absf(_area(piece)) > 0.01:
					ctx.errors.append("blocks %s and %s overlap" % [(ctx.blocks[i] as Block).id, (ctx.blocks[j] as Block).id])
					return


## Edge-relative half-planes [point, normal]; points p with (p-point).normal >= 0 stay.
static func _planes(ctx: Ctx, clip: Dictionary) -> Array:
	var k := int(clip.get("edge", -1))
	if k < 0 or k >= ctx.edges.size():
		ctx.errors.append("clip needs a valid footprint edge")
		return []
	var edge: Edge = ctx.edges[k]
	var inward := -edge.n
	var planes: Array = []
	if clip.has("min"):
		planes.append([edge.at(0.0, float(clip["min"])), inward])
	if clip.has("max"):
		planes.append([edge.at(0.0, float(clip["max"])), -inward])
	if clip.has("s_min"):
		planes.append([edge.at(float(clip["s_min"]), 0.0), edge.d])
	if clip.has("s_max"):
		planes.append([edge.at(float(clip["s_max"]), 0.0), -edge.d])
	if clip.has("taper"):
		# Line through (station, depth) pairs; keeps the inner side unless taper_keep is outer.
		var t: Array = clip["taper"]
		var p0 := edge.at(float(t[0]), float(t[1]))
		var p1 := edge.at(float(t[2]), float(t[3]))
		var normal := Vector2(-(p1 - p0).y, (p1 - p0).x).normalized()
		if normal.dot(inward) < 0.0:
			normal = -normal
		if str(clip.get("taper_keep", "inner")) == "outer":
			normal = -normal
		planes.append([p0, normal])
	return planes


static func _clip(poly: PackedVector2Array, point: Vector2, normal: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in poly.size():
		var a := poly[i]
		var b := poly[(i + 1) % poly.size()]
		var sa := (a - point).dot(normal)
		var sb := (b - point).dot(normal)
		if sa >= 0.0:
			out.append(a)
		if (sa >= 0.0) != (sb >= 0.0):
			out.append(a + (b - a) * (sa / (sa - sb)))
	var clean := PackedVector2Array()
	for p: Vector2 in out:
		if clean.is_empty() or clean[clean.size() - 1].distance_to(p) > 0.001:
			clean.append(p)
	if clean.size() > 1 and clean[0].distance_to(clean[clean.size() - 1]) <= 0.001:
		clean.remove_at(clean.size() - 1)
	var result := PackedVector2Array()
	for i in clean.size():
		var a := clean[(i + clean.size() - 1) % clean.size()]
		var b := clean[i]
		var c := clean[(i + 1) % clean.size()]
		var turn := (b - a).cross(c - b)
		# Clipping a concave ring along one of its own edges can leave a zero-width
		# spike (the outline runs out along the cut and back). In single precision
		# its tip survives the absolute collinear test, so also drop a vertex where
		# the outline reverses within 1e-4 rad; a valid outline never has one.
		if absf(turn) <= 1e-6 or ((b - a).dot(c - b) < 0.0 and absf(turn) <= 1e-4 * (b - a).length() * (c - b).length()):
			continue
		result.append(b)
	return result


static func _area(poly: PackedVector2Array) -> float:
	var total := 0.0
	for i in poly.size():
		var a := poly[i] - poly[0]
		var b := poly[(i + 1) % poly.size()] - poly[0]
		total += a.cross(b)
	return total * 0.5


static func _centroid(poly: PackedVector2Array) -> Vector2:
	var sum := Vector2.ZERO
	for p: Vector2 in poly:
		sum += p
	return sum / float(poly.size())


## Outward normal of edge i from the polygon's winding (also for non-convex blocks).
static func _outward(poly: PackedVector2Array, i: int) -> Vector2:
	var d := (poly[(i + 1) % poly.size()] - poly[i]).normalized()
	var n := Vector2(d.y, -d.x)
	return n if _area(poly) > 0.0 else -n


static func _convex(poly: PackedVector2Array) -> bool:
	var sign := 0.0
	for i in poly.size():
		var a := poly[(i + poly.size() - 1) % poly.size()]
		var b := poly[i]
		var c := poly[(i + 1) % poly.size()]
		var z := (b - a).cross(c - b)
		# Plan points are single precision: a turn under 1e-4 rad counts as straight.
		if absf(z) <= 1e-4 * (b - a).length() * (c - b).length():
			continue
		if sign == 0.0:
			sign = signf(z)
		elif signf(z) != sign:
			return false
	return true


# ------------------------------------------------------------------- courtyards

## Courtyard hole edges oriented like the outer faces (outward = into the courtyard),
## as [a, b, outward] triples.
static func _hole_edges(block: Block, hole: PackedVector2Array) -> Array:
	var a0 := block.poly[0]
	var d0 := (block.poly[1] - a0).normalized()
	var turn := signf(d0.cross(_outward(block.poly, 0)))
	var out: Array = []
	for i in hole.size():
		var a := hole[i]
		var b := hole[(i + 1) % hole.size()]
		if a.distance_to(b) < 0.001:
			continue
		var n := -_outward(hole, i)
		if signf((b - a).normalized().cross(n)) != turn:
			var swap := a
			a = b
			b = swap
		out.append([a, b, n])
	return out


## Full-height courtyard walls along a hole (face key "hole", else the default scheme).
static func _hole_faces(ctx: Ctx, block: Block, hole: PackedVector2Array, faces_cfg: Dictionary, schemes: Dictionary) -> void:
	for edge: Array in _hole_edges(block, hole):
		var face := Face.new()
		face.block = block
		face.a = edge[0]
		var b: Vector2 = edge[1]
		face.length = face.a.distance_to(b)
		face.d = (b - face.a) / face.length
		face.n = edge[2]
		face.spans = [{"s0": 0.0, "s1": face.length, "ground": true, "y": 0.0}]
		face.index = ctx.faces
		ctx.faces += 1
		face.key = "hole"
		var scheme_name := str(faces_cfg.get("hole", faces_cfg.get("default", "")))
		if not schemes.has(scheme_name) or (schemes[scheme_name] as Dictionary).has("open"):
			ctx.errors.append("block %s courtyard needs a closed wall scheme" % block.id)
			return
		face.scheme = schemes[scheme_name]
		_facade(ctx, face)


## Parapets along a courtyard's edges, mitred at its corners.
static func _hole_parapets(ctx: Ctx, block: Block, hole: PackedVector2Array) -> void:
	if block.wall_top <= block.roof_y + 0.01:
		return
	var t := float((block.cfg.get("parapet", {}) as Dictionary).get("t", 0.3))
	var edges := _hole_edges(block, hole)
	var count := edges.size()
	for i in count:
		var a: Vector2 = edges[i][0]
		var b: Vector2 = edges[i][1]
		var n: Vector2 = edges[i][2]
		var d := (b - a).normalized()
		var inner0 := a - n * t
		var inner1 := b - n * t
		# Mitre with the edge meeting each end (edges keep the ring order or its reverse).
		for other: Array in edges:
			if (other[1] as Vector2).distance_to(a) < 0.001:
				var no: Vector2 = other[2]
				inner0 = a - (no + n) * t / (1.0 + no.dot(n))
			if (other[0] as Vector2).distance_to(b) < 0.001:
				var nf: Vector2 = other[2]
				inner1 = b - (nf + n) * t / (1.0 + nf.dot(n))
		_parapet_run(ctx, block, a, b, inner0, inner1, n, d, false, false)


## The block outline minus its courtyards as hole-free pieces: each hole is cut by
## a line through it, so every Clipper piece has the courtyard as a notch.
static func _pieces_around_holes(block: Block) -> Array[PackedVector2Array]:
	var pieces: Array[PackedVector2Array] = [block.poly]
	for hole: PackedVector2Array in block.holes:
		var centre := Vector2.ZERO
		for p: Vector2 in hole:
			centre += p
		centre /= float(hole.size())
		var along := (hole[1] - hole[0]).normalized()
		var across := Vector2(-along.y, along.x)
		var reach := 1.0e4
		var halves: Array[PackedVector2Array] = [
			PackedVector2Array([centre - along * reach, centre + along * reach, centre + along * reach + across * reach, centre - along * reach + across * reach]),
			PackedVector2Array([centre - along * reach, centre - along * reach - across * reach, centre + along * reach - across * reach, centre + along * reach]),
		]
		var next: Array[PackedVector2Array] = []
		for piece: PackedVector2Array in pieces:
			if not Geometry2D.is_point_in_polygon(centre, piece):
				next.append(piece)
				continue
			for half: PackedVector2Array in halves:
				for part: PackedVector2Array in Geometry2D.intersect_polygons(piece, half):
					for rest: PackedVector2Array in Geometry2D.clip_polygons(part, hole):
						if not Geometry2D.is_polygon_clockwise(rest) == Geometry2D.is_polygon_clockwise(part):
							continue
						next.append(rest)
		pieces = next
	return pieces


# ------------------------------------------------------------------- exposure

## Station intervals of block edge i that rise above neighbours or the ground.
static func _spans(ctx: Ctx, block: Block, i: int) -> Array:
	var a := block.poly[i]
	var b := block.poly[(i + 1) % block.poly.size()]
	var length := a.distance_to(b)
	var d := (b - a) / length
	var side := Vector2(-d.y, d.x)
	var covers: Array = []
	for other: Block in ctx.blocks:
		# An open pergola has no roof slab, so it never hides a neighbour's wall.
		if other == block or other.cfg.has("pergola"):
			continue
		for j in other.poly.size():
			var qa := other.poly[j]
			var qb := other.poly[(j + 1) % other.poly.size()]
			if absf((qa - a).dot(side)) > COLLINEAR_M or absf((qb - a).dot(side)) > COLLINEAR_M or (qb - qa).dot(d) >= 0.0:
				continue
			var lo := maxf(0.0, minf((qa - a).dot(d), (qb - a).dot(d)))
			var hi := minf(length, maxf((qa - a).dot(d), (qb - a).dot(d)))
			if hi - lo > 0.001:
				covers.append([lo, hi, other.roof_y])
	var cuts: Array = [0.0, length]
	for cover: Array in covers:
		cuts.append(cover[0])
		cuts.append(cover[1])
	cuts.sort()
	var spans: Array = []
	for c in range(cuts.size() - 1):
		var s0: float = cuts[c]
		var s1: float = cuts[c + 1]
		if s1 - s0 < 0.001:
			continue
		var mid := (s0 + s1) * 0.5
		var bottom := -INF
		for cover: Array in covers:
			if float(cover[0]) <= mid and mid <= float(cover[1]):
				bottom = maxf(bottom, float(cover[2]))
		if bottom >= block.roof_y - 0.000001:
			continue
		var ground := bottom == -INF
		if not spans.is_empty() and bool(spans[-1].ground) == ground and (ground or is_equal_approx(float(spans[-1].y), bottom)) and absf(float(spans[-1].s1) - s0) < 0.000001:
			spans[-1].s1 = s1
		else:
			spans.append({"s0": s0, "s1": s1, "ground": ground, "y": 0.0 if ground else bottom})
	return spans


static func _block_faces(ctx: Ctx, block: Block) -> void:
	var faces_cfg: Dictionary = block.cfg.get("faces", {})
	var schemes: Dictionary = ctx.cfg.get("schemes", {})
	for i in block.poly.size():
		var spans := _spans(ctx, block, i)
		if spans.is_empty():
			continue
		var face := Face.new()
		face.block = block
		face.a = block.poly[i]
		var b := block.poly[(i + 1) % block.poly.size()]
		face.length = face.a.distance_to(b)
		face.d = (b - face.a) / face.length
		face.n = _outward(block.poly, i)
		face.spans = spans
		face.poly_index = i
		face.index = ctx.faces
		ctx.faces += 1
		face.key = "return"
		var all_raised := true
		for span: Dictionary in spans:
			if bool(span.ground):
				all_raised = false
		if all_raised:
			face.key = "court"
		for k in ctx.edges.size():
			var edge: Edge = ctx.edges[k]
			if face.n.dot(edge.n) < FACE_COS:
				continue
			var da := edge.depth(face.a)
			var db := edge.depth(b)
			if da < -0.01 or db < -0.01 or da > FACE_BAND_M or db > FACE_BAND_M:
				continue
			face.key = "e%d" % k
			face.edge = k
			break
		var scheme_name := str(faces_cfg.get(face.key, faces_cfg.get("default", "")))
		if not schemes.has(scheme_name):
			ctx.errors.append("block %s face %s has no scheme" % [block.id, face.key])
			return
		face.scheme = schemes[scheme_name]
		if face.scheme.has("open"):
			_open_face(ctx, face)
		else:
			_facade(ctx, face)
			if block.form != "flat":
				_infill(ctx, face)
	for hole: PackedVector2Array in block.holes:
		_hole_faces(ctx, block, hole, faces_cfg, schemes)


## Every level at which a wall material can change on this block (floors, plinth
## tops, bands and pilaster tops of all its face schemes). Strip ends at bay
## boundaries, corners and block junctions carry these levels of every block plus
## the wall tops, so neighbouring strips meet without T-junctions.
static func _block_levels(block: Block, faces_cfg: Dictionary, schemes: Dictionary) -> PackedFloat64Array:
	var levels: Array = []
	for k in range(block.storeys + 1):
		levels.append(block.floors[k])
	for name: Variant in faces_cfg.values():
		var scheme: Dictionary = schemes.get(str(name), {})
		var plinth: Dictionary = scheme.get("plinth", {})
		levels.append(block.floors[0] + float(plinth.get("top", 0.0)))
		for band: Dictionary in scheme.get("bands", []):
			var k := int(band.get("storey", 1))
			if k < block.floors.size():
				var y0 := block.floors[k] + float(band.get("offset", 0.0))
				levels.append(y0)
				levels.append(y0 + float(band.get("h", 0.25)))
		var pilaster: Dictionary = scheme.get("end_pilasters", {})
		if not pilaster.is_empty():
			levels.append(block.floors[mini(int(pilaster.get("to_storey", block.storeys)), block.storeys)])
	levels.sort()
	return PackedFloat64Array(levels)


# ------------------------------------------------------------------- facades

## Maps a configured station to face-local s: footprint stations on e_k faces.
static func _local_station(ctx: Ctx, face: Face, value: float) -> float:
	if face.edge < 0:
		return face.length + value if value < 0.0 else value
	var edge: Edge = ctx.edges[face.edge]
	var t := edge.length + value if value < 0.0 else value
	return (edge.at(t, 0.0) - face.a).dot(face.d)


static func _merge(base: Dictionary, over: Variant) -> Dictionary:
	var out := base.duplicate(true)
	if over is Dictionary:
		for key: Variant in (over as Dictionary):
			out[key] = (over as Dictionary)[key]
	return out


## Lays bays over [0, length]: single-bay features at their stations, filler bays between.
static func _bays(ctx: Ctx, face: Face) -> Array:
	var scheme := face.scheme
	var singles: Array = []
	var ranges: Array = []
	for feature: Dictionary in scheme.get("features", []):
		var kind := str(feature.get("type", ""))
		var s0 := _local_station(ctx, face, float(feature.get("from", 0.0)))
		var s1 := _local_station(ctx, face, float(feature.get("to", 0.0)))
		if s1 < s0:
			var swap := s0
			s0 = s1
			s1 = swap
		if kind in ["bays", "blank"]:
			var lo := maxf(0.0, s0)
			var hi := minf(face.length, s1)
			if hi - lo > 0.05:
				ranges.append({"s0": lo, "s1": hi, "f": feature})
			continue
		if kind not in ["loggia", "frame", "entry", "garage", "vents", "band", "corner", "ladder", "stair_bay", "top_box"]:
			ctx.errors.append("unknown facade feature type " + kind)
			return []
		if s1 <= 0.01 or s0 >= face.length - 0.01:
			continue
		if s0 < -0.01 or s1 > face.length + 0.01:
			ctx.skipped.append("%s/%s %s at %.2f-%.2f crosses face %d end" % [face.block.id, face.key, kind, s0, s1, face.index])
			continue
		singles.append({"s0": maxf(0.0, s0), "s1": minf(face.length, s1), "f": feature, "kind": kind})
	singles.sort_custom(func(x: Dictionary, y: Dictionary) -> bool: return float(x.s0) < float(y.s0))
	for i in range(1, singles.size()):
		if float(singles[i].s0) < float(singles[i - 1].s1) - 0.001:
			ctx.errors.append("%s/%s features overlap at %.2f" % [face.block.id, face.key, float(singles[i].s0)])
			return []
	var bays: Array = []
	var cursor := 0.0
	for single: Dictionary in singles:
		_fill(face, bays, cursor, float(single.s0), ranges)
		single["range"] = _range_at(ranges, (float(single.s0) + float(single.s1)) * 0.5)
		bays.append(single)
		cursor = float(single.s1)
	_fill(face, bays, cursor, face.length, ranges)
	for i in bays.size():
		bays[i]["i"] = i
	return bays


static func _range_at(ranges: Array, s: float) -> Dictionary:
	var found: Dictionary = {}
	for item: Dictionary in ranges:
		if float(item.s0) <= s and s <= float(item.s1):
			found = item.f
	return found


static func _fill(face: Face, bays: Array, g0: float, g1: float, ranges: Array) -> void:
	if g1 - g0 < 0.01:
		return
	var cuts: Array = [g0, g1]
	for item: Dictionary in ranges:
		for s: float in [float(item.s0), float(item.s1)]:
			if s > g0 + 0.01 and s < g1 - 0.01:
				cuts.append(s)
	cuts.sort()
	for c in range(cuts.size() - 1):
		var a: float = cuts[c]
		var b: float = cuts[c + 1]
		if b - a < 0.01:
			continue
		var feature := _range_at(ranges, (a + b) * 0.5)
		var module := float(feature.get("module", face.scheme.get("module", 3.3)))
		var count := int(round((b - a) / module))
		var kind := "blank" if str(feature.get("type", "")) == "blank" or count < 1 else "window"
		if kind == "blank":
			bays.append({"s0": a, "s1": b, "f": {}, "kind": "blank", "range": feature})
			continue
		var width := (b - a) / float(count)
		for k in count:
			bays.append({"s0": a + width * float(k), "s1": a + width * float(k + 1), "f": {}, "kind": "window", "range": feature})


## Wall material at storey k for a bay, before plinth/band/pilaster zones.
static func _bay_material(face: Face, bay: Dictionary, k: int) -> String:
	var scheme := face.scheme
	var base: Dictionary = scheme.get("base", {})
	if k < int(base.get("storeys", 0)):
		return str(base.get("material", scheme.get("material", "render")))
	for source: Dictionary in [bay.f, bay.range]:
		if source.has("material") and k >= int(source.get("material_from", 0)) and k < int(source.get("material_to", 1000)):
			return str(source.material)
	if k == 0 and scheme.has("ground_material"):
		return str(scheme.ground_material)
	return str(scheme.get("material", "render"))


static func _storey_at(block: Block, y: float) -> int:
	var k := 0
	while k < block.storeys - 1 and y >= block.floors[k + 1]:
		k += 1
	return k


static func _zone_material(face: Face, bay: Dictionary, s: float, y: float) -> String:
	var scheme := face.scheme
	var block := face.block
	for band: Dictionary in scheme.get("bands", []):
		var k := int(band.get("storey", 1))
		if k < block.floors.size():
			var y0 := block.floors[k] + float(band.get("offset", 0.0))
			if y >= y0 and y <= y0 + float(band.get("h", 0.25)):
				return str(band.get("material", "concrete"))
	var pilaster: Dictionary = scheme.get("end_pilasters", {})
	if not pilaster.is_empty():
		var w := float(pilaster.get("w", 0.4))
		var top := block.floors[mini(int(pilaster.get("to_storey", block.storeys)), block.storeys)]
		if (s <= w or s >= face.length - w) and y <= top:
			return str(pilaster.get("material", "concrete"))
	var plinth: Dictionary = scheme.get("plinth", {})
	if y < block.floors[0] + float(plinth.get("top", 0.0)) and plinth.has("material"):
		return str(plinth.material)
	if y >= block.roof_y:
		return str(scheme.get("parapet_material", _bay_material(face, bay, block.storeys - 1)))
	return _bay_material(face, bay, _storey_at(block, y))


static func _stagger(face: Face, bay: Dictionary, k: int, spec: Dictionary) -> Dictionary:
	var stagger: Dictionary = face.scheme.get("stagger", {})
	if stagger.is_empty() or k < int(stagger.get("from_storey", 1)) or not bay.range.is_empty() or not bay.f.is_empty():
		return {"spec": spec, "offset": 0.0}
	var key := face.index * 131 + int(bay.i) * 31 + k * 17 + int(stagger.get("seed", 0))
	var out := spec
	var mix: Array = stagger.get("mix", [])
	if not mix.is_empty():
		out = _merge(spec, mix[posmod(key * 7 + key % 5, mix.size())])
	var offsets: Array = stagger.get("offsets", [0.0])
	return {"spec": out, "offset": float(offsets[posmod(key, offsets.size())])}


## Openings for one bay as rectangles in face (s, y) with their assembly kind.
static func _openings(ctx: Ctx, face: Face, bay: Dictionary) -> Array:
	var block := face.block
	var scheme := face.scheme
	var feature: Dictionary = bay.f
	var rng: Dictionary = bay.range
	var kind := str(bay.kind)
	var s0 := float(bay.s0)
	var s1 := float(bay.s1)
	var center := (s0 + s1) * 0.5
	var out: Array = []
	if kind == "blank" or str(rng.get("type", "")) == "blank":
		return out
	var window := _merge(_merge(scheme.get("window", {}), rng.get("window", {})), feature.get("window", {}))
	var ground := _merge(_merge(scheme.get("ground", {}), rng.get("ground", {})), feature.get("ground", {}))
	var upper := str(feature.get("upper", rng.get("upper", scheme.get("upper", "window"))))
	var skip_storeys: Array = scheme.get("skip_storeys", [])
	var claimed: Dictionary = {}
	match kind:
		"loggia":
			var pier := float(feature.get("pier", 0.5))
			var head := float(feature.get("head", 0.35))
			for value: Variant in feature.get("storeys", []):
				var k := int(value)
				if k >= 0 and k < block.storeys:
					out.append({"s0": s0 + pier, "s1": s1 - pier, "y0": block.floors[k], "y1": block.floors[k + 1] - head, "kind": "loggia", "spec": feature, "k": k})
					claimed[k] = true
		"frame":
			var storeys: Array = feature.get("storeys", [1, 2])
			var k0 := int(storeys[0])
			var k1 := int(storeys[1])
			if k0 >= 0 and k1 >= k0 and k1 < block.storeys:
				var pier := float(feature.get("pier", 0.8))
				out.append({"s0": s0 + pier, "s1": s1 - pier, "y0": block.floors[k0], "y1": block.floors[k1 + 1] - float(feature.get("head", 0.4)), "kind": "frame", "spec": feature, "k": k0})
				for k in range(k0, k1 + 1):
					claimed[k] = true
		"band":
			var storeys: Array = feature.get("storeys", [1, block.storeys - 1])
			var k0 := clampi(int(storeys[0]), 0, block.storeys - 1)
			var k1 := clampi(int(storeys[1]), k0, block.storeys - 1)
			var w := float(feature.get("w", 1.6))
			out.append({"s0": center - w * 0.5, "s1": center + w * 0.5, "y0": block.floors[k0] + float(feature.get("bottom", 0.35)), "y1": block.floors[k1 + 1] - float(feature.get("top", 0.3)), "kind": "band", "spec": feature, "k": k0})
			for k in range(k0, k1 + 1):
				claimed[k] = true
		"entry":
			var door: Dictionary = feature.get("door", {})
			var landing: Dictionary = feature.get("landing", {})
			var w := float(door.get("w", 1.1))
			var inside := float(door.get("recess", 2.2)) if str(door.get("kind", "unit")) == "porch" else 0.0
			var land := _landing(ctx, face, center, float(landing.get("w", w + 1.0)), float(landing.get("depth", 1.6)), inside)
			if str(landing.get("at", "grade")) == "floor":
				var lowest := minf(float(land.y) - 0.1, float(land.y) - float(land.drop) + 0.12)
				land = {"y": block.floors[0], "drop": maxf(0.25, block.floors[0] - lowest + 0.12)}
			var y0 := float(land.y)
			# A door on higher local grade stops under the second-storey floor.
			var y1 := y0 + float(door.get("h", 2.9))
			if block.storeys > 1:
				y1 = minf(y1, block.floors[1] - 0.12)
			out.append({"s0": center - w * 0.5, "s1": center + w * 0.5, "y0": y0, "y1": y1, "kind": "door", "spec": feature, "k": 0, "drop": float(land.drop)})
			claimed[0] = true
		"garage":
			var w := float(feature.get("w", 5.4))
			var y0 := 0.04 + maxf(_ground_y(ctx, face.a + face.d * center), maxf(_ground_y(ctx, face.a + face.d * (center - w * 0.5)), _ground_y(ctx, face.a + face.d * (center + w * 0.5))))
			out.append({"s0": center - w * 0.5, "s1": center + w * 0.5, "y0": y0, "y1": y0 + float(feature.get("h", 3.0)), "kind": "garage", "spec": feature, "k": 0})
			claimed[0] = true
		"stair_bay":
			var bay_opening := _stair_bay_opening(ctx, face, feature, s0, s1)
			if bay_opening.is_empty():
				return []
			out.append(bay_opening)
			for k in block.storeys:
				claimed[k] = true
		"top_box":
			# The wall behind a projecting top-floor box stays blank; the box itself is
			# added after the wall strips (see _top_box).
			for k in block.storeys:
				claimed[k] = true
		"vents":
			var count := int(feature.get("count", 2))
			var w := float(feature.get("w", 1.4))
			var h := float(feature.get("h", 0.9))
			var y := block.floors[0] + float(feature.get("y", 2.4))
			for v in count:
				var c := s0 + (s1 - s0) * (float(v) + 0.5) / float(count)
				out.append({"s0": c - w * 0.5, "s1": c + w * 0.5, "y0": y, "y1": y + h, "kind": "vent", "spec": feature, "k": 0})
			# Opt-in: ground-storey windows still fill the bay (louvres under windows).
			if not bool(feature.get("windows", false)):
				claimed[0] = true
	for k in block.storeys:
		if claimed.has(k) or k in skip_storeys:
			continue
		if k == 0:
			var ground_kind := str(ground.get("kind", "window"))
			if ground_kind == "blank":
				continue
			if ground_kind == "storefront":
				var pier := float(ground.get("pier", 0.35))
				out.append({"s0": s0 + pier, "s1": s1 - pier, "y0": block.floors[0] + float(ground.get("sill", 0.15)), "y1": block.floors[1] - float(ground.get("head", 0.6)), "kind": "storefront", "spec": ground, "k": 0})
				continue
			out.append(_placed(face, bay, ground, center, block.floors[0], block.floors[1], 0, "patio" if ground_kind == "patio" else "window"))
			continue
		if upper == "blank":
			continue
		var storey_window := window
		for source: Dictionary in [scheme, rng, feature]:
			var overrides: Dictionary = source.get("window_storeys", {})
			if overrides.has(str(k)):
				storey_window = _merge(storey_window, overrides[str(k)])
		var choice := _stagger(face, bay, k, storey_window)
		var spec: Dictionary = choice.spec
		var c := center + float(choice.offset)
		if kind == "corner":
			var pier := float(feature.get("pier", 0.3))
			var w := float(spec.get("w", 1.6))
			c = s1 - pier - w * 0.5 if str(feature.get("align", "end")) == "end" else s0 + pier + w * 0.5
		out.append(_placed(face, bay, spec, c, block.floors[k], block.floors[k + 1], k, "window"))
	var kept: Array = []
	for item: Dictionary in out:
		if item.is_empty():
			continue
		if float(item.s0) < s0 + MIN_PIER_M * 0.5 - 0.001 or float(item.s1) > s1 - MIN_PIER_M * 0.5 + 0.001 or float(item.s1) - float(item.s0) < 0.2 or float(item.y1) - float(item.y0) < 0.2:
			ctx.skipped.append("%s/%s %s does not fit bay %.2f-%.2f" % [face.block.id, face.key, str(item.kind), s0, s1])
			continue
		kept.append(item)
	return kept


static func _placed(face: Face, bay: Dictionary, spec: Dictionary, center: float, floor_y: float, next_y: float, k: int, kind: String) -> Dictionary:
	var w := float(spec.get("w", 1.6))
	var sill := float(spec.get("sill", 0.8))
	var h := minf(float(spec.get("h", 1.8)), next_y - floor_y - sill - 0.15)
	var s0 := float(bay.s0)
	var s1 := float(bay.s1)
	var c := clampf(center, s0 + MIN_PIER_M + w * 0.5, s1 - MIN_PIER_M - w * 0.5)
	if s1 - s0 < w + 2.0 * MIN_PIER_M or h < 0.3:
		return {}
	return {"s0": c - w * 0.5, "s1": c + w * 0.5, "y0": floor_y + sill, "y1": floor_y + sill + h, "kind": kind, "spec": spec, "k": k}


static func _facade(ctx: Ctx, face: Face) -> void:
	var bays := _bays(ctx, face)
	if not ctx.errors.is_empty():
		return
	var block := face.block
	for span: Dictionary in face.spans:
		var a := float(span.s0)
		var b := float(span.s1)
		var raised := not bool(span.ground)
		for bay: Dictionary in bays:
			var x0 := maxf(a, float(bay.s0))
			var x1 := minf(b, float(bay.s1))
			if x1 - x0 < 0.001:
				continue
			var holes: Array = []
			for opening: Dictionary in _openings(ctx, face, bay):
				if float(opening.s0) < x0 - 0.0001 or float(opening.s1) > x1 + 0.0001 or float(opening.y1) > block.roof_y:
					continue
				if raised:
					if float(opening.y0) < float(span.y) + 0.05:
						continue
				else:
					# Where local grade rises above the floor, sills rise with it and heads
					# stay aligned; doors and garages already sit on their own grade.
					var grade := _ground_max(ctx, face, float(opening.s0), float(opening.s1))
					if str(opening.kind) in ["window", "storefront", "patio", "vent", "band"]:
						if float(opening.y0) < grade + GRADE_CLEARANCE_M:
							opening.y0 = grade + GRADE_CLEARANCE_M
							if float(opening.y1) - float(opening.y0) < 0.9:
								continue
					elif float(opening.y0) < grade:
						continue
				holes.append(opening)
			_wall_strip(ctx, face, bay, x0, x1, span, holes)
			for opening: Dictionary in holes:
				_assembly(ctx, face, bay, opening)
	for bay: Dictionary in bays:
		if str(bay.kind) == "ladder":
			_ladder(ctx, face, bay)
		elif str(bay.kind) == "top_box":
			_top_box(ctx, face, bay)


## Wall surface of one bay strip with rectangular holes and material zones.
static func _wall_strip(ctx: Ctx, face: Face, bay: Dictionary, x0: float, x1: float, span: Dictionary, holes: Array) -> void:
	var block := face.block
	var raised := not bool(span.ground)
	var top := block.wall_top
	var xs: Array = [x0, x1]
	var ys: Array = [top]
	for hole: Dictionary in holes:
		xs.append(float(hole.s0))
		xs.append(float(hole.s1))
		ys.append(float(hole.y0))
		ys.append(float(hole.y1))
	if not raised:
		# Exact frozen terrain breakpoints keep the buried bottom piecewise linear. A
		# station within 2 mm of an opening edge snaps to it: two near-equal breakpoints
		# would leave a sub-millimetre gap column that shows as a line of pinholes.
		for edge: Edge in ctx.edges:
			for s: float in edge.stations:
				var p := edge.start + edge.d * s
				if absf((p - face.a).dot(Vector2(-face.d.y, face.d.x))) < 0.05:
					var local := (p - face.a).dot(face.d)
					var near := false
					for x: float in xs:
						if absf(x - local) < 0.002:
							near = true
					if not near and local > x0 + 0.001 and local < x1 - 0.001:
						xs.append(local)
	var pilaster: Dictionary = face.scheme.get("end_pilasters", {})
	if not pilaster.is_empty():
		for s: float in [float(pilaster.get("w", 0.4)), face.length - float(pilaster.get("w", 0.4))]:
			if s > x0 + 0.001 and s < x1 - 0.001:
				xs.append(s)
	xs.sort()
	# Collapse near-equal breakpoints so every column has a real width and
	# neighbouring columns share their edge exactly.
	var cut_xs: Array = []
	for x: float in xs:
		if cut_xs.is_empty() or x - float(cut_xs[cut_xs.size() - 1]) >= 0.001:
			cut_xs.append(x)
		elif x == x1:
			cut_xs[cut_xs.size() - 1] = x1
	xs = cut_xs
	face.top_xs.append_array(xs)
	for k in range(block.storeys + 1):
		ys.append(block.floors[k])
	var plinth: Dictionary = face.scheme.get("plinth", {})
	ys.append(block.floors[0] + float(plinth.get("top", 0.0)))
	for band: Dictionary in face.scheme.get("bands", []):
		var k := int(band.get("storey", 1))
		if k < block.floors.size():
			var y0 := block.floors[k] + float(band.get("offset", 0.0))
			ys.append(y0)
			ys.append(y0 + float(band.get("h", 0.25)))
	if not pilaster.is_empty():
		ys.append(block.floors[mini(int(pilaster.get("to_storey", block.storeys)), block.storeys)])
	xs.sort()
	ys.sort()
	var out := face.out3()
	# Pass 1: per column, merged runs of one material between holes and zone changes.
	var columns: Array = []
	for i in range(xs.size() - 1):
		var xa: float = xs[i]
		var xb: float = xs[i + 1]
		if xb - xa < 0.001:
			continue
		var xm := (xa + xb) * 0.5
		var ba := float(span.y) if raised else _ground_y(ctx, face.a + face.d * xa) - BURY_M
		var bb := float(span.y) if raised else _ground_y(ctx, face.a + face.d * xb) - BURY_M
		var low := minf(ba, bb)
		var runs: Array = []
		var cuts := PackedFloat64Array()
		var run_mat := ""
		var run_y0 := 0.0
		var run_y1 := 0.0
		var prev := low
		for y: float in ys + [INF]:
			var level := minf(y, top)
			if level <= prev + 0.0005 and y != INF:
				continue
			var ym := (prev + level) * 0.5
			var inside := false
			for hole: Dictionary in holes:
				if xm > float(hole.s0) and xm < float(hole.s1) and ym > float(hole.y0) and ym < float(hole.y1):
					inside = true
					break
			var mat := "" if inside or y == INF else _zone_material(face, bay, xm, ym)
			if mat != run_mat:
				if run_mat != "":
					runs.append([run_mat, run_y0, run_y1])
					cuts.append(run_y0)
					cuts.append(run_y1)
				run_mat = mat
				run_y0 = prev
			run_y1 = level
			prev = level
			if level >= top:
				if run_mat != "":
					runs.append([run_mat, run_y0, run_y1])
					cuts.append(run_y0)
					cuts.append(run_y1)
				break
		columns.append({"xa": xa, "xb": xb, "ba": ba, "bb": bb, "runs": runs, "cuts": cuts})
	# Pass 2: each run also carries the vertex levels of the column across each side
	# (the building's zone levels and wall tops at the strip ends), so shared edges
	# have matching vertices and no T-junction opens rasterisation pinholes.
	var ends := ctx.levels
	for i in columns.size():
		var column: Dictionary = columns[i]
		var left: PackedFloat64Array = (columns[i - 1] as Dictionary).cuts if i > 0 else ends
		var right: PackedFloat64Array = (columns[i + 1] as Dictionary).cuts if i + 1 < columns.size() else ends
		for run: Array in column.runs:
			var y0 := float(run[1])
			_wall_cell(ctx, face, str(run[0]), float(column.xa), float(column.xb), maxf(y0, float(column.ba)), maxf(y0, float(column.bb)), float(run[2]), out, left, right)


## Wall quad between xa and xb from its bottom corners up to top, zipped between
## its two vertical edges with the extra vertex levels each neighbour needs.
static func _wall_cell(ctx: Ctx, face: Face, mat: String, xa: float, xb: float, ya: float, yb: float, top: float, out: Vector3, left: PackedFloat64Array, right: PackedFloat64Array) -> void:
	if top <= ya + 0.0005 and top <= yb + 0.0005:
		return
	var la := _edge_chain(minf(ya, top), top, left)
	var lb := _edge_chain(minf(yb, top), top, right)
	var bucket := ctx.bucket("wall", mat)
	var i := 0
	var j := 0
	while i < la.size() - 1 or j < lb.size() - 1:
		if j >= lb.size() - 1 or (i < la.size() - 1 and la[i + 1] <= lb[j + 1]):
			bucket.tri(face.point(xa, la[i], 0.0), face.point(xa, la[i + 1], 0.0), face.point(xb, lb[j], 0.0), out)
			i += 1
		else:
			bucket.tri(face.point(xa, la[i], 0.0), face.point(xb, lb[j + 1], 0.0), face.point(xb, lb[j], 0.0), out)
			j += 1


## Ascending vertex levels on one cell edge: its own ends plus the (ascending)
## neighbour levels between them.
static func _edge_chain(y0: float, y1: float, levels: PackedFloat64Array) -> PackedFloat64Array:
	var chain := PackedFloat64Array([y0])
	for y: float in levels:
		if y > chain[chain.size() - 1] + 0.0001 and y < y1 - 0.0001:
			chain.append(y)
	chain.append(y1)
	return chain


# ----------------------------------------------------------------- assemblies

static func _rect(bucket: Bucket, face: Face, s0: float, s1: float, y0: float, y1: float, depth: float, facing: Vector3) -> void:
	bucket.quad(face.point(s0, y0, depth), face.point(s1, y0, depth), face.point(s1, y1, depth), face.point(s0, y1, depth), facing)


## Axis box in face coordinates (s along, y up, depth inward; negative depth is outside).
static func _box(bucket: Bucket, face: Face, s0: float, s1: float, y0: float, y1: float, d0: float, d1: float, skip_bottom: bool = true) -> void:
	var out := face.out3()
	var along := face.dir3()
	_rect(bucket, face, s0, s1, y0, y1, d0, out)
	_rect(bucket, face, s0, s1, y0, y1, d1, -out)
	bucket.quad(face.point(s0, y1, d0), face.point(s1, y1, d0), face.point(s1, y1, d1), face.point(s0, y1, d1), Vector3.UP)
	if not skip_bottom:
		bucket.quad(face.point(s0, y0, d0), face.point(s1, y0, d0), face.point(s1, y0, d1), face.point(s0, y0, d1), Vector3.DOWN)
	bucket.quad(face.point(s0, y0, d0), face.point(s0, y1, d0), face.point(s0, y1, d1), face.point(s0, y0, d1), -along)
	bucket.quad(face.point(s1, y0, d0), face.point(s1, y1, d0), face.point(s1, y1, d1), face.point(s1, y0, d1), along)


static func _reveals(ctx: Ctx, face: Face, mat: String, s0: float, s1: float, y0: float, y1: float, depth: float, sill: bool, soffit: String = "") -> void:
	var bucket := ctx.bucket("wall", mat)
	var along := face.dir3()
	bucket.quad(face.point(s0, y0, 0.0), face.point(s0, y1, 0.0), face.point(s0, y1, depth), face.point(s0, y0, depth), along)
	bucket.quad(face.point(s1, y0, 0.0), face.point(s1, y1, 0.0), face.point(s1, y1, depth), face.point(s1, y0, depth), -along)
	ctx.bucket("wall", mat if soffit.is_empty() else soffit).quad(face.point(s0, y1, 0.0), face.point(s1, y1, 0.0), face.point(s1, y1, depth), face.point(s0, y1, depth), Vector3.DOWN)
	if sill:
		bucket.quad(face.point(s0, y0, 0.0), face.point(s1, y0, 0.0), face.point(s1, y0, depth), face.point(s0, y0, depth), Vector3.UP)


## Glazing with a perimeter frame, mullions (fractions of width) and transoms (of height).
static func _glazing(ctx: Ctx, face: Face, spec: Dictionary, s0: float, s1: float, y0: float, y1: float, depth: float, role: String = "wall") -> void:
	var out := face.out3()
	_rect(ctx.bucket(role, str(spec.get("glass", "glass"))), face, s0, s1, y0, y1, depth, out)
	var frame := ctx.bucket(role, str(spec.get("frame", "frame")))
	var fw := float(spec.get("frame_w", 0.06))
	var fd := depth - 0.015
	_rect(frame, face, s0, s0 + fw, y0, y1, fd, out)
	_rect(frame, face, s1 - fw, s1, y0, y1, fd, out)
	_rect(frame, face, s0 + fw, s1 - fw, y0, y0 + fw, fd, out)
	_rect(frame, face, s0 + fw, s1 - fw, y1 - fw, y1, fd, out)
	var bar := float(spec.get("bar_w", 0.05)) * 0.5
	for value: Variant in spec.get("mullions", []):
		var s := lerpf(s0, s1, float(value))
		_rect(frame, face, s - bar, s + bar, y0 + fw, y1 - fw, fd, out)
	for value: Variant in spec.get("transoms", []):
		var y := lerpf(y0, y1, float(value))
		_rect(frame, face, s0 + fw, s1 - fw, y - bar, y + bar, fd, out)


static func _assembly(ctx: Ctx, face: Face, bay: Dictionary, o: Dictionary) -> void:
	var s0 := float(o.s0)
	var s1 := float(o.s1)
	var y0 := float(o.y0)
	var y1 := float(o.y1)
	var spec: Dictionary = o.spec
	var wall_mat := _zone_material(face, bay, (s0 + s1) * 0.5, (y0 + y1) * 0.5)
	match str(o.kind):
		"window", "storefront":
			var depth := float(spec.get("depth", 0.18))
			_reveals(ctx, face, str(spec.get("reveal", wall_mat)), s0, s1, y0, y1, depth, true)
			var glazing := spec
			if str(o.kind) == "storefront" and not spec.has("mullions"):
				var count := maxi(1, int(round((s1 - s0) / float(spec.get("mullion_step", 1.6)))))
				var mullions: Array = []
				for m in range(1, count):
					mullions.append(float(m) / float(count))
				glazing = _merge(spec, {"mullions": mullions})
			_glazing(ctx, face, glazing, s0, s1, y0, y1, depth)
			_hood(ctx, face, spec, s0, s1, y1)
		"patio":
			var depth := float(spec.get("depth", 0.18))
			_reveals(ctx, face, wall_mat, s0, s1, y0, y1, depth, true)
			_glazing(ctx, face, spec, s0, s1, y0, y1, depth)
			var c := (s0 + s1) * 0.5
			if face.block.floors[0] - _ground_y(ctx, face.a + face.d * c) > float(spec.get("rail_above", 0.45)):
				_railing(ctx, face, s0, s1, y0, y0 + 1.05, 0.06)
		"loggia":
			_loggia(ctx, face, spec, wall_mat, s0, s1, y0, y1, [int(o.k)])
		"frame":
			var storeys: Array = spec.get("storeys", [1, 2])
			var ks: Array = []
			for k in range(int(storeys[0]), int(storeys[1]) + 1):
				ks.append(k)
			_loggia(ctx, face, spec, wall_mat, s0, s1, y0, y1, ks)
		"band":
			_band(ctx, face, spec, s0, s1, y0, y1)
		"stair_bay":
			_stair_bay(ctx, face, spec, wall_mat, s0, s1, y0, y1)
		"door":
			_door(ctx, face, spec, wall_mat, s0, s1, y0, y1, float(o.get("drop", 0.25)))
		"garage":
			var depth := float(spec.get("depth", 0.3))
			_reveals(ctx, face, wall_mat, s0, s1, y0, y1, depth, false)
			var out := face.out3()
			_rect(ctx.bucket("wall", str(spec.get("material", "garage"))), face, s0, s1, y0, y1, depth, out)
			var groove := ctx.bucket("wall", "frame")
			var y := y0 + 0.5
			while y < y1 - 0.2:
				_rect(groove, face, s0 + 0.05, s1 - 0.05, y - 0.02, y + 0.02, depth - 0.01, out)
				y += 0.55
		"vent":
			var depth := 0.14
			_reveals(ctx, face, wall_mat, s0, s1, y0, y1, depth, true)
			var out := face.out3()
			_rect(ctx.bucket("wall", "vent_back"), face, s0, s1, y0, y1, depth, out)
			var slats := ctx.bucket("wall", "frame")
			var y := y0 + 0.07
			while y < y1 - 0.05:
				_rect(slats, face, s0, s1, y, y + 0.045, 0.06, out)
				y += 0.12


## Opt-in box hood over a window head (window `hood`): a box `depth` out from the
## wall and `h` tall, `gap` above the head and `over` wider than the opening on each
## side, with optional side cheeks `cheek` down the jambs (`t` thick). Support role.
static func _hood(ctx: Ctx, face: Face, spec: Dictionary, s0: float, s1: float, y1: float) -> void:
	var hood: Dictionary = spec.get("hood", {})
	if hood.is_empty():
		return
	var depth := float(hood.get("depth", 0.5))
	var h := float(hood.get("h", 0.3))
	var over := float(hood.get("over", 0.1))
	var gap := float(hood.get("gap", 0.05))
	var cheek := float(hood.get("cheek", 0.0))
	var t := float(hood.get("t", 0.06))
	if not (_in_range(depth, 0.05, 2.0) and _in_range(h, 0.05, 1.0) and _in_range(over, 0.0, 1.0) and _in_range(gap, 0.0, 1.0) and _in_range(cheek, 0.0, 3.0) and _in_range(t, 0.02, 0.5)):
		ctx.errors.append("window hood needs depth 0.05-2, h 0.05-1, over 0-1, gap 0-1, cheek 0-3 and t 0.02-0.5 m")
		return
	var bucket := ctx.bucket("support", str(hood.get("material", "metal")))
	var a := s0 - over
	var b := s1 + over
	var y := y1 + gap
	_box(bucket, face, a, b, y, y + h, -depth, 0.02, false)
	if cheek > 0.0:
		_box(bucket, face, a, a + t, y - cheek, y, -depth, 0.02, false)
		_box(bucket, face, b - t, b, y - cheek, y, -depth, 0.02, false)


## Recessed loggia (one storey) or framed multi-storey recess: back wall, soffit,
## slab, glass railing and one glazed opening per storey on the back wall.
static func _loggia(ctx: Ctx, face: Face, spec: Dictionary, wall_mat: String, s0: float, s1: float, y0: float, y1: float, storeys: Array) -> void:
	var depth := float(spec.get("depth", 1.7))
	var side_mat := str(spec.get("side", wall_mat))
	_reveals(ctx, face, side_mat, s0, s1, y0, y1, depth, false, str(spec.get("soffit", "soffit")))
	ctx.bucket("support", str(spec.get("slab", "slab"))).quad(face.point(s0, y0, 0.0), face.point(s1, y0, 0.0), face.point(s1, y0, depth), face.point(s0, y0, depth), Vector3.UP)
	_rect(ctx.bucket("wall", str(spec.get("back", "render"))), face, s0, s1, y0, y1, depth, face.out3())
	var block := face.block
	var glass_w := (s1 - s0) * float(spec.get("glass_fraction", 0.62))
	var c := (s0 + s1) * 0.5
	for value: Variant in storeys:
		var k := int(value)
		var gy0 := block.floors[k] + 0.03
		var gy1 := minf(gy0 + 2.35, minf(y1, block.floors[k + 1]) - 0.15)
		if gy1 - gy0 < 0.5:
			continue
		_glazing(ctx, face, {"mullions": [0.5], "frame": str(spec.get("frame", "frame"))}, c - glass_w * 0.5, c + glass_w * 0.5, gy0, gy1, depth - 0.01)
	_railing(ctx, face, s0, s1, y0, y0 + float(spec.get("rail_h", 1.05)), 0.12)


static func _railing(ctx: Ctx, face: Face, s0: float, s1: float, y0: float, y1: float, depth: float) -> void:
	var out := face.out3()
	var panel := ctx.bucket("support", "rail_glass")
	_rect(panel, face, s0, s1, y0, y1, depth, out)
	_rect(panel, face, s0, s1, y0, y1, depth + 0.01, -out)
	_box(ctx.bucket("support", "metal"), face, s0, s1, y1, y1 + 0.05, depth - 0.025, depth + 0.035)


## Dark recessed vertical band: per storey a window and grey spandrel panels.
static func _band(ctx: Ctx, face: Face, spec: Dictionary, s0: float, s1: float, y0: float, y1: float) -> void:
	var depth := float(spec.get("depth", 0.14))
	var frame_mat := str(spec.get("frame", "band_frame"))
	var out := face.out3()
	var along := face.dir3()
	var block := face.block
	var border := float(spec.get("border", 0.1))
	var frame := ctx.bucket("wall", frame_mat)
	var spandrel := ctx.bucket("wall", str(spec.get("spandrel", "spandrel")))
	var window: Dictionary = spec.get("window", {})
	# Glazed storeys first; every spandrel/glazing level also cuts the side borders
	# and jambs, so the band recess has no T-junctions.
	var panes: Array = []
	var cursor := y0
	var k := _storey_at(block, y0 + 0.01)
	while k < block.storeys and block.floors[k] < y1:
		var gy0 := maxf(y0, block.floors[k] + float(window.get("sill", 0.85)))
		var gy1 := minf(y1, gy0 + float(window.get("h", 1.6)))
		if gy1 - gy0 > 0.3:
			panes.append([maxf(gy0, cursor), gy1])
			cursor = gy1
		k += 1
	var levels: Array = [y0]
	for pane: Array in panes:
		for y: float in pane:
			if y > float(levels[levels.size() - 1]) + 0.001 and y < y1 - 0.001:
				levels.append(y)
	levels.append(y1)
	cursor = y0
	for pane: Array in panes:
		if float(pane[0]) > cursor + 0.001:
			_rect(spandrel, face, s0 + border, s1 - border, cursor, float(pane[0]), depth, out)
		_glazing(ctx, face, _merge(window, {"frame": frame_mat}), s0 + border, s1 - border, maxf(float(pane[0]), cursor), float(pane[1]), depth)
		cursor = float(pane[1])
	if y1 > cursor + 0.001:
		_rect(spandrel, face, s0 + border, s1 - border, cursor, y1, depth, out)
	for i in range(levels.size() - 1):
		var ya := float(levels[i])
		var yb := float(levels[i + 1])
		_rect(frame, face, s0, s0 + border, ya, yb, depth, out)
		_rect(frame, face, s1 - border, s1, ya, yb, depth, out)
		# Jambs: the wall-plane edge keeps only its ends (as the neighbouring wall
		# column does); the inner edge carries every level.
		frame.tri(face.point(s0, y0, 0.0), face.point(s0, ya, depth), face.point(s0, yb, depth), along)
		frame.tri(face.point(s1, y0, 0.0), face.point(s1, ya, depth), face.point(s1, yb, depth), -along)
	frame.tri(face.point(s0, y0, 0.0), face.point(s0, y1, depth), face.point(s0, y1, 0.0), along)
	frame.tri(face.point(s1, y0, 0.0), face.point(s1, y1, depth), face.point(s1, y1, 0.0), -along)
	frame.quad(face.point(s0, y1, 0.0), face.point(s1, y1, 0.0), face.point(s1, y1, depth), face.point(s0, y1, depth), Vector3.DOWN)
	frame.quad(face.point(s0, y0, 0.0), face.point(s1, y0, 0.0), face.point(s1, y0, depth), face.point(s0, y0, depth), Vector3.UP)


## Opt-in open stair bay ("stair_bay" feature): the opening of a full-height
## recess from the highest grade under it to just below the roof. Invalid
## parameters, or a recess whose back corners leave the block, fail the build.
static func _stair_bay_opening(ctx: Ctx, face: Face, feature: Dictionary, s0: float, s1: float) -> Dictionary:
	var block := face.block
	var pier := float(feature.get("pier", 0.2))
	var depth := float(feature.get("depth", 2.0))
	var a := s0 + pier
	var b := s1 - pier
	var label := "%s/%s stair_bay at %.2f" % [block.id, face.key, s0]
	if block.storeys < 2 or b - a < 2.0 or depth < 1.2 or depth > 4.0:
		ctx.errors.append(label + " needs two storeys, a clear width of at least 2 m and a depth of 1.2-4 m")
		return {}
	for p: Vector2 in [face.a + face.d * a - face.n * depth, face.a + face.d * b - face.n * depth]:
		if not Geometry2D.is_point_in_polygon(p, block.poly):
			ctx.errors.append(label + " recess leaves its block")
			return {}
	# Recess floor: above the frozen grade along both its front and back lines.
	var y0 := block.floors[0]
	var s := a
	while s <= b + 0.001:
		for d: float in [0.0, depth]:
			y0 = maxf(y0, _ground_y(ctx, face.a + face.d * minf(s, b) - face.n * d))
		s += 0.5
	y0 += 0.02
	var y1 := block.roof_y - float(feature.get("head", 0.35))
	if y0 >= block.floors[1] - 0.5 or y1 <= block.floors[block.storeys - 1] + 1.0:
		ctx.errors.append(label + " has no room between grade and roof")
		return {}
	return {"s0": a, "s1": b, "y0": y0, "y1": y1, "kind": "stair_bay", "spec": feature, "k": 0}


## Open stair bay: side reveals and soffit, a dark back wall, the recess floor
## behind a solid ground-floor guard (the bay is not a walkable route), and per
## storey two stepped flights around a half landing under a full floor landing.
static func _stair_bay(ctx: Ctx, face: Face, spec: Dictionary, wall_mat: String, s0: float, s1: float, y0: float, y1: float) -> void:
	var block := face.block
	var depth := float(spec.get("depth", 2.0))
	var out := face.out3()
	var side_mat := str(spec.get("side", wall_mat))
	var slab := ctx.bucket("support", str(spec.get("slab", "slab")))
	_reveals(ctx, face, side_mat, s0, s1, y0, y1, depth, false, str(spec.get("soffit", "soffit")))
	_rect(ctx.bucket("wall", str(spec.get("back", "render"))), face, s0, s1, y0, y1, depth, out)
	var guard_t := 0.2
	_box(ctx.bucket("wall", side_mat), face, s0, s1, y0, y0 + float(spec.get("guard_h", 1.1)), 0.0, guard_t)
	slab.quad(face.point(s0, y0, guard_t), face.point(s1, y0, guard_t), face.point(s1, y0, depth), face.point(s0, y0, depth), Vector3.UP)
	var t := 0.2
	var land := minf(1.3, (s1 - s0) * 0.3)
	var mid_d := depth * 0.5
	for k in range(block.storeys - 1):
		var ya := y0 if k == 0 else block.floors[k]
		var yb := block.floors[k + 1]
		if yb - ya < 1.0:
			continue
		var ym := (ya + yb) * 0.5
		_flight(slab, face, s0 + 0.1, s1 - land, ya, ym, guard_t + 0.05, mid_d - 0.05, t)
		_box(slab, face, s1 - land, s1, ym - t, ym, guard_t + 0.05, depth, false)
		_flight(slab, face, s1 - land, s0 + land, ym, yb, mid_d + 0.05, depth, t)
		_box(slab, face, s0, s1, yb - t, yb, 0.05, depth, false)


## A straight stepped flight in face coordinates from (sa, ya) up to (sb, yb),
## between depths d0 < d1, with a sloped soffit `t` below the step nosings.
static func _flight(bucket: Bucket, face: Face, sa: float, sb: float, ya: float, yb: float, d0: float, d1: float, t: float) -> void:
	var out := face.out3()
	var along := face.dir3()
	var steps := maxi(2, int(round((yb - ya) / 0.18)))
	var rise := (yb - ya) / float(steps)
	var run := (sb - sa) / float(steps)
	var down := -along * signf(sb - sa)
	for i in steps:
		var sx := sa + run * float(i)
		var sy := ya + rise * float(i)
		bucket.quad(face.point(sx, sy, d0), face.point(sx, sy + rise, d0), face.point(sx, sy + rise, d1), face.point(sx, sy, d1), down)
		bucket.quad(face.point(sx, sy + rise, d0), face.point(sx + run, sy + rise, d0), face.point(sx + run, sy + rise, d1), face.point(sx, sy + rise, d1), Vector3.UP)
		for d: float in [d0, d1]:
			var facing := out if d == d0 else -out
			bucket.quad(face.point(sx, sy - t, d), face.point(sx + run, sy + rise - t, d), face.point(sx + run, sy + rise, d), face.point(sx, sy + rise, d), facing)
	bucket.quad(face.point(sa, ya - t, d0), face.point(sb, yb - t, d0), face.point(sb, yb - t, d1), face.point(sa, ya - t, d1), Vector3.DOWN)


## Opt-in projecting top-floor box ("top_box" feature) on an otherwise blank
## wall: a support-role box out from the wall up to the wall top, with one
## window band on its front. Invalid parameters fail the build.
static func _top_box(ctx: Ctx, face: Face, bay: Dictionary) -> void:
	var block := face.block
	var spec: Dictionary = bay.f
	var k := int(spec.get("storey", block.storeys - 1))
	var project := float(spec.get("project", 0.6))
	var pier := float(spec.get("pier", 0.0))
	var s0 := float(bay.s0) + pier
	var s1 := float(bay.s1) - pier
	if k < 0 or k >= block.storeys or project <= 0.05 or project > 2.0 or s1 - s0 < 1.0:
		ctx.errors.append("%s/%s top_box at %.2f needs a valid storey, a projection of 0.05-2 m and a width of at least 1 m" % [block.id, face.key, float(bay.s0)])
		return
	var y0 := block.floors[k] - float(spec.get("below", 0.15))
	var y1 := block.wall_top
	_box(ctx.bucket("support", str(spec.get("material", face.scheme.get("material", "render")))), face, s0, s1, y0, y1, -project, 0.0, false)
	var window: Dictionary = spec.get("window", {})
	var inset := float(window.get("inset", 0.3))
	var wy0 := block.floors[k] + float(window.get("sill", 0.9))
	var wy1 := minf(wy0 + float(window.get("h", 1.2)), y1 - 0.2)
	if s1 - s0 - 2.0 * inset > 0.5 and wy1 - wy0 > 0.3:
		_glazing(ctx, face, window, s0 + inset, s1 - inset, wy0, wy1, -project - 0.01, "support")


static func _door(ctx: Ctx, face: Face, spec: Dictionary, wall_mat: String, s0: float, s1: float, y0: float, y1: float, drop: float) -> void:
	var door: Dictionary = spec.get("door", {})
	var kind := str(door.get("kind", "unit"))
	var depth := float(door.get("recess", 2.2 if kind == "porch" else 0.3))
	var out := face.out3()
	var c := (s0 + s1) * 0.5
	_reveals(ctx, face, str(door.get("reveal", wall_mat)), s0, s1, y0, y1, depth, false, str(door.get("soffit", "soffit")) if kind == "porch" else "")
	var landing: Dictionary = spec.get("landing", {})
	var land_w := float(landing.get("w", s1 - s0 + 1.0))
	var land_d := float(landing.get("depth", 1.6))
	if kind == "porch":
		_rect(ctx.bucket("wall", str(door.get("back", "render"))), face, s0, s1, y0, y1, depth, out)
		var dw := float(door.get("door_w", 1.8))
		_glazing(ctx, face, {"mullions": [0.5], "transoms": [0.82]}, c - dw * 0.5, c + dw * 0.5, y0, minf(y1 - 0.2, y0 + 2.7), depth - 0.01)
		_pad(ctx, face, s0, s1, 0.0, depth, y0, 0.0)
	elif kind == "lobby":
		_glazing(ctx, face, {"mullions": door.get("mullions", [0.25, 0.5, 0.75]), "transoms": door.get("transoms", [0.78])}, s0, s1, y0, y1, depth)
	else:
		var leaf_top := minf(y1, y0 + float(door.get("leaf_h", 2.4)))
		_rect(ctx.bucket("wall", str(door.get("material", "door"))), face, s0, s1, y0, leaf_top, depth, out)
		var frame := ctx.bucket("wall", "frame")
		_rect(frame, face, s0, s0 + 0.06, y0, y1, depth - 0.015, out)
		_rect(frame, face, s1 - 0.06, s1, y0, y1, depth - 0.015, out)
		if y1 - leaf_top > 0.2:
			_glazing(ctx, face, {}, s0, s1, leaf_top, y1, depth)
		_box(ctx.bucket("wall", "frame"), face, s1 - 0.22, s1 - 0.12, y0 + 1.0, y0 + 1.04, depth - 0.06, depth)
	_pad(ctx, face, c - land_w * 0.5, c + land_w * 0.5, -land_d, 0.0, y0, drop)
	var ramp: Dictionary = spec.get("ramp", {})
	if not ramp.is_empty():
		_ramp(ctx, face, ramp, c, land_w, land_d, y0)
	if bool(spec.get("rails", not ramp.is_empty())):
		_deck_rails(ctx, face, ramp, c, land_w, land_d, y0)
	var canopy: Dictionary = spec.get("canopy", {})
	if not canopy.is_empty():
		var cw := float(canopy.get("w", s1 - s0 + 0.8))
		var cy := y1 + float(canopy.get("gap", 0.25))
		_box(ctx.bucket("support", str(canopy.get("material", "metal"))), face, c - cw * 0.5, c + cw * 0.5, cy, cy + float(canopy.get("t", 0.14)), -float(canopy.get("depth", 1.2)), 0.02, false)
	if bool(spec.get("screens", false)):
		var screen := ctx.bucket("support", "screen")
		for side: float in [-1.0, 1.0]:
			var s := c + side * (land_w * 0.5 - 0.04)
			_box(screen, face, s - 0.025, s + 0.025, y0, y0 + float(spec.get("screen_h", 1.1)), -land_d + 0.15, 0.0, false)


## Walkable landing: flat top at y with bevelled outer and side skirts (at most
## 40 degrees, the stock 48-degree floor limit) reaching drop metres into the ground.
static func _pad(ctx: Ctx, face: Face, s0: float, s1: float, d0: float, d1: float, y: float, drop: float) -> void:
	var ground := ctx.bucket("ground", "paving")
	ground.quad(face.point(s0, y, d0), face.point(s1, y, d0), face.point(s1, y, d1), face.point(s0, y, d1), Vector3.UP)
	if drop <= 0.0:
		return
	var run := drop * 1.2
	var out := face.out3()
	var along := face.dir3()
	ground.quad(face.point(s0, y, d0), face.point(s1, y, d0), face.point(s1 + run, y - drop, d0 - run), face.point(s0 - run, y - drop, d0 - run), out + Vector3.UP)
	ground.quad(face.point(s0, y, d0), face.point(s0, y, d1), face.point(s0 - run, y - drop, d1), face.point(s0 - run, y - drop, d0 - run), -along + Vector3.UP)
	ground.quad(face.point(s1, y, d0), face.point(s1, y, d1), face.point(s1 + run, y - drop, d1), face.point(s1 + run, y - drop, d0 - run), along + Vector3.UP)


# ---------------------------------------------------------------------- roofs

static func _roof(ctx: Ctx, block: Block) -> void:
	if block.cfg.has("pergola"):
		_pergola(ctx, block)
		return
	if block.form != "flat":
		_pitched_roof(ctx, block)
	else:
		var roof_mat := str(block.cfg.get("roof_material", "roof"))
		var bucket := ctx.bucket("roof", roof_mat)
		var p0 := block.poly[0]
		var tris: Array = []
		if not block.holes.is_empty():
			var pieces := _pieces_around_holes(block)
			# Fail closed: the pieces must cover exactly the block minus its courtyards
			# (a cut line that missed a non-convex courtyard would roof it over).
			var expected := absf(_area(block.poly))
			for hole: PackedVector2Array in block.holes:
				expected -= absf(_area(hole))
			var covered := 0.0
			for piece: PackedVector2Array in pieces:
				covered += absf(_area(piece))
			if absf(covered - expected) > 0.05:
				ctx.errors.append("block %s roof does not leave its courtyard open (%.2f of %.2f m2)" % [block.id, covered, expected])
				return
			for piece: PackedVector2Array in pieces:
				var piece_indices := Geometry2D.triangulate_polygon(piece)
				if piece_indices.is_empty():
					ctx.errors.append("block %s roof around its courtyard does not triangulate" % block.id)
					return
				for i in range(0, piece_indices.size(), 3):
					tris.append([piece[piece_indices[i]], piece[piece_indices[i + 1]], piece[piece_indices[i + 2]]])
		elif _convex(block.poly):
			for i in range(1, block.poly.size() - 1):
				tris.append([p0, block.poly[i], block.poly[i + 1]])
		else:
			var indices := Geometry2D.triangulate_polygon(block.poly)
			if indices.is_empty():
				ctx.errors.append("block %s outline does not triangulate" % block.id)
				return
			for i in range(0, indices.size(), 3):
				tris.append([block.poly[indices[i]], block.poly[indices[i + 1]], block.poly[indices[i + 2]]])
		for t: Array in tris:
			var q0: Vector2 = t[0]
			var q1: Vector2 = t[1]
			var q2: Vector2 = t[2]
			bucket.tri(Vector3(q0.x, block.roof_y, q0.y), Vector3(q1.x, block.roof_y, q1.y), Vector3(q2.x, block.roof_y, q2.y), Vector3.UP)
		# Opt-in deck slab over open sides: underside (fascia comes with the open faces).
		var deck: Dictionary = block.cfg.get("deck", {})
		if not deck.is_empty():
			var under_y := block.roof_y - float(deck.get("t", 0.3))
			var under := ctx.bucket("support", str(deck.get("material", "slab")))
			for t: Array in tris:
				var q0: Vector2 = t[0]
				var q1: Vector2 = t[1]
				var q2: Vector2 = t[2]
				under.tri(Vector3(q0.x, under_y, q0.y), Vector3(q1.x, under_y, q1.y), Vector3(q2.x, under_y, q2.y), Vector3.DOWN)
		_parapets(ctx, block)
		for hole: PackedVector2Array in block.holes:
			_hole_parapets(ctx, block, hole)
	for item: Dictionary in block.cfg.get("roof_items", []):
		_roof_item(ctx, block, item)


## Facet planes [u, c, k] of a pitched roof; the underside is the lowest facet.
static func _roof_planes(ctx: Ctx, block: Block, roof_cfg: Dictionary) -> Array:
	var k := tan(deg_to_rad(float(roof_cfg.get("pitch_deg", 15.0))))
	var planes: Array = []
	match block.form:
		"gable":
			var e := int(roof_cfg.get("ridge_edge", -1))
			if e < 0 or e >= ctx.edges.size():
				return []
			var ridge: Vector2 = (ctx.edges[e] as Edge).d
			var w := Vector2(-ridge.y, ridge.x)
			var lo := INF
			var hi := -INF
			for p: Vector2 in block.poly:
				lo = minf(lo, w.dot(p))
				hi = maxf(hi, w.dot(p))
			planes = [[w, lo, k], [-w, -hi, k]]
		"mono":
			var e := int(roof_cfg.get("low_edge", -1))
			if e < 0 or e >= ctx.edges.size():
				return []
			var u: Vector2 = -(ctx.edges[e] as Edge).n
			var lo := INF
			for p: Vector2 in block.poly:
				lo = minf(lo, u.dot(p))
			planes = [[u, lo, k]]
		"pyramid":
			for i in block.poly.size():
				var u := -_outward(block.poly, i)
				planes.append([u, u.dot(block.poly[i]), k])
	return planes


## Underside height of the block's roof at p: the eave on the walls, rising inward.
static func _roof_under(block: Block, p: Vector2) -> float:
	if block.form == "flat":
		return block.roof_y
	var h := INF
	for plane: Array in block.planes:
		h = minf(h, float(plane[2]) * ((plane[0] as Vector2).dot(p) - float(plane[1])))
	return block.roof_y + h


## Convex outline grown outward by `by` (mitred corners).
static func _grow_convex(poly: PackedVector2Array, by: float) -> PackedVector2Array:
	if by <= 0.0:
		return poly
	var out := PackedVector2Array()
	var count := poly.size()
	for i in count:
		var n0 := _outward(poly, (i + count - 1) % count)
		var n1 := _outward(poly, i)
		out.append(poly[i] + (n0 + n1) * (by / (1.0 + n0.dot(n1))))
	return out


## Pitched roof slab: top (roof role), underside and fascia (support) over the
## outline grown by the overhang. Each facet is the outline clipped to where its
## plane is lowest; facets share snapped vertices, so ridges and hips do not crack.
static func _pitched_roof(ctx: Ctx, block: Block) -> void:
	var roof_cfg: Dictionary = block.cfg.get("roof", {})
	var t := float(roof_cfg.get("t", 0.15))
	var top := ctx.bucket("roof", str(block.cfg.get("roof_material", "roof")))
	var under := ctx.bucket("support", str(roof_cfg.get("under", "soffit")))
	var fascia := ctx.bucket("support", str(roof_cfg.get("fascia", "coping")))
	var outline := _grow_convex(block.poly, float(roof_cfg.get("overhang", 0.3)))
	var canon: Array = []
	for j in block.planes.size():
		var pj: Array = block.planes[j]
		var facet := outline
		for i in block.planes.size():
			if i == j:
				continue
			var pi: Array = block.planes[i]
			var normal: Vector2 = (pi[0] as Vector2) * float(pi[2]) - (pj[0] as Vector2) * float(pj[2])
			if normal.length_squared() < 1e-12:
				continue
			var offset := float(pi[2]) * float(pi[1]) - float(pj[2]) * float(pj[1])
			facet = _clip(facet, normal * (offset / normal.length_squared()), normal)
			if facet.size() < 3:
				break
		if facet.size() < 3:
			continue
		var snapped := PackedVector2Array()
		for p: Vector2 in facet:
			var found := p
			for q: Vector2 in canon:
				if q.distance_to(p) < 0.0005:
					found = q
					break
			if found == p:
				canon.append(p)
			snapped.append(found)
		for i in range(1, snapped.size() - 1):
			var a := snapped[0]
			var b := snapped[i]
			var c := snapped[i + 1]
			top.tri(Vector3(a.x, _roof_under(block, a) + t, a.y), Vector3(b.x, _roof_under(block, b) + t, b.y), Vector3(c.x, _roof_under(block, c) + t, c.y), Vector3.UP)
			under.tri(Vector3(a.x, _roof_under(block, a), a.y), Vector3(b.x, _roof_under(block, b), b.y), Vector3(c.x, _roof_under(block, c), c.y), Vector3.DOWN)
		# Fascia along the facet edges that lie on the outline.
		for i in snapped.size():
			var a := snapped[i]
			var b := snapped[(i + 1) % snapped.size()]
			var m := (a + b) * 0.5
			for e in outline.size():
				var oa := outline[e]
				var ob := outline[(e + 1) % outline.size()]
				if Geometry2D.get_closest_point_to_segment(m, oa, ob).distance_to(m) > 0.001:
					continue
				var n := _outward(outline, e)
				var ya := _roof_under(block, a)
				var yb := _roof_under(block, b)
				fascia.quad(Vector3(a.x, ya, a.y), Vector3(b.x, yb, b.y), Vector3(b.x, yb + t, b.y), Vector3(a.x, ya + t, a.y), Vector3(n.x, 0.0, n.y))
				break


## Wall above the eave under a pitched roof (gable ends, lean-to sides): columns
## on the wall strips' own top vertices, rising into the roof slab; a ridge or
## hip crossing a column only adds a vertex to its hidden top.
static func _infill(ctx: Ctx, face: Face) -> void:
	var block := face.block
	var t := float((block.cfg.get("roof", {}) as Dictionary).get("t", 0.15))
	var xs: Array = face.top_xs.duplicate()
	xs.sort()
	var kinks: Array = []
	for i in block.planes.size():
		for j in range(i + 1, block.planes.size()):
			var pi: Array = block.planes[i]
			var pj: Array = block.planes[j]
			var gi := float(pi[2]) * (pi[0] as Vector2).dot(face.d)
			var gj := float(pj[2]) * (pj[0] as Vector2).dot(face.d)
			if absf(gi - gj) < 1e-9:
				continue
			var hi0 := float(pi[2]) * ((pi[0] as Vector2).dot(face.a) - float(pi[1]))
			var hj0 := float(pj[2]) * ((pj[0] as Vector2).dot(face.a) - float(pj[1]))
			kinks.append((hj0 - hi0) / (gi - gj))
	kinks.sort()
	var material := str(face.scheme.get("gable_material", face.scheme.get("parapet_material", face.scheme.get("material", "render"))))
	var bucket := ctx.bucket("wall", material)
	var bottom := block.wall_top
	var out := face.out3()
	for i in range(xs.size() - 1):
		var xa: float = xs[i]
		var xb: float = xs[i + 1]
		if xb - xa < 0.001:
			continue
		var exposed := false
		for span: Dictionary in face.spans:
			if float(span.s0) <= (xa + xb) * 0.5 and (xa + xb) * 0.5 <= float(span.s1):
				exposed = true
		if not exposed:
			continue
		# Hidden top polyline from xb back to xa, with any kinks between.
		var top: Array = [xb]
		for k in range(kinks.size() - 1, -1, -1):
			if float(kinks[k]) > xa + 0.001 and float(kinks[k]) < xb - 0.001:
				top.append(kinks[k])
		top.append(xa)
		var highest := -INF
		for x: float in top:
			highest = maxf(highest, _roof_under(block, face.a + face.d * x))
		if highest + t * 0.5 <= bottom + 0.005:
			continue
		var anchor := face.point(xa, bottom, 0.0)
		var previous := face.point(xb, bottom, 0.0)
		for x: float in top:
			var y := maxf(bottom, _roof_under(block, face.a + face.d * x) + t * 0.5)
			var point := face.point(x, y, 0.0)
			bucket.tri(anchor, previous, point, out)
			previous = point


## Inner parapet faces and coping along every edge run exposed at roof level.
static func _parapets(ctx: Ctx, block: Block) -> void:
	if block.wall_top <= block.roof_y + 0.01:
		return
	var count := block.poly.size()
	var runs: Array = []
	for i in count:
		var spans := _spans(ctx, block, i)
		var merged: Array = []
		for span: Dictionary in spans:
			if not merged.is_empty() and absf(float(merged[-1][1]) - float(span.s0)) < 0.001:
				merged[-1][1] = float(span.s1)
			else:
				merged.append([float(span.s0), float(span.s1)])
		runs.append(merged)
	var t := float((block.cfg.get("parapet", {}) as Dictionary).get("t", 0.3))
	for i in count:
		var a := block.poly[i]
		var b := block.poly[(i + 1) % count]
		var length := a.distance_to(b)
		var d := (b - a) / length
		var n := _outward(block.poly, i)
		var previous := (i + count - 1) % count
		var following := (i + 1) % count
		for run: Array in runs[i]:
			var s0 := float(run[0])
			var s1 := float(run[1])
			var start_miter := s0 < 0.001 and not (runs[previous] as Array).is_empty() and absf(float((runs[previous] as Array)[-1][1]) - block.poly[previous].distance_to(a)) < 0.001
			var end_miter := s1 > length - 0.001 and not (runs[following] as Array).is_empty() and float((runs[following] as Array)[0][0]) < 0.001
			var outer0 := a + d * s0
			var outer1 := a + d * s1
			var inner0 := outer0 - n * t
			var inner1 := outer1 - n * t
			if start_miter:
				var np := _outward(block.poly, previous)
				inner0 = a - (np + n) * t / (1.0 + np.dot(n))
			if end_miter:
				var nf := _outward(block.poly, following)
				inner1 = b - (nf + n) * t / (1.0 + nf.dot(n))
			_parapet_run(ctx, block, outer0, outer1, inner0, inner1, n, d, not start_miter, not end_miter)


static func _parapet_run(ctx: Ctx, block: Block, o0: Vector2, o1: Vector2, i0: Vector2, i1: Vector2, n: Vector2, d: Vector2, cap0: bool, cap1: bool) -> void:
	var top := block.wall_top
	var low := block.roof_y
	var coping := ctx.bucket("support", "coping")
	coping.quad(Vector3(o0.x, top, o0.y), Vector3(o1.x, top, o1.y), Vector3(i1.x, top, i1.y), Vector3(i0.x, top, i0.y), Vector3.UP)
	var inner_normal := Vector3(-n.x, 0.0, -n.y)
	ctx.bucket("support", str(block.cfg.get("parapet_inner", "parapet"))).quad(Vector3(i0.x, low, i0.y), Vector3(i1.x, low, i1.y), Vector3(i1.x, top, i1.y), Vector3(i0.x, top, i0.y), inner_normal)
	if cap0:
		coping.quad(Vector3(o0.x, low, o0.y), Vector3(i0.x, low, i0.y), Vector3(i0.x, top, i0.y), Vector3(o0.x, top, o0.y), Vector3(-d.x, 0.0, -d.y))
	if cap1:
		coping.quad(Vector3(o1.x, low, o1.y), Vector3(i1.x, low, i1.y), Vector3(i1.x, top, i1.y), Vector3(o1.x, top, o1.y), Vector3(d.x, 0.0, d.y))
	if block.railing:
		var rail_top := block.roof_y + float((block.cfg.get("parapet", {}) as Dictionary).get("h", 1.1))
		var mid0 := (o0 + i0) * 0.5
		var mid1 := (o1 + i1) * 0.5
		if str((block.cfg.get("parapet", {}) as Dictionary).get("style", "glass")) == "pipe":
			_pipe_run(ctx.bucket("support", "rail"), mid0, mid1, n, top, rail_top)
			return
		var glass := ctx.bucket("support", "rail_glass")
		var facing := Vector3(n.x, 0.0, n.y)
		glass.quad(Vector3(mid0.x, top, mid0.y), Vector3(mid1.x, top, mid1.y), Vector3(mid1.x, rail_top, mid1.y), Vector3(mid0.x, rail_top, mid0.y), facing)
		glass.quad(Vector3(mid0.x, top, mid0.y), Vector3(mid1.x, top, mid1.y), Vector3(mid1.x, rail_top, mid1.y), Vector3(mid0.x, rail_top, mid0.y), -facing)
		var rail := ctx.bucket("support", "metal")
		var w := n * 0.03
		rail.quad(Vector3(mid0.x + w.x, rail_top + 0.05, mid0.y + w.y), Vector3(mid1.x + w.x, rail_top + 0.05, mid1.y + w.y), Vector3(mid1.x - w.x, rail_top + 0.05, mid1.y - w.y), Vector3(mid0.x - w.x, rail_top + 0.05, mid0.y - w.y), Vector3.UP)
		rail.quad(Vector3(mid0.x + w.x, rail_top, mid0.y + w.y), Vector3(mid1.x + w.x, rail_top, mid1.y + w.y), Vector3(mid1.x + w.x, rail_top + 0.05, mid1.y + w.y), Vector3(mid0.x + w.x, rail_top + 0.05, mid0.y + w.y), facing)
		rail.quad(Vector3(mid0.x - w.x, rail_top, mid0.y - w.y), Vector3(mid1.x - w.x, rail_top, mid1.y - w.y), Vector3(mid1.x - w.x, rail_top + 0.05, mid1.y - w.y), Vector3(mid0.x - w.x, rail_top + 0.05, mid0.y - w.y), -facing)


## Roof or deck item in footprint-edge coordinates, inside its block outline.
static func _roof_item(ctx: Ctx, block: Block, item: Dictionary) -> void:
	var k := int(item.get("edge", -1))
	if k < 0 or k >= ctx.edges.size():
		ctx.errors.append("roof item needs a footprint edge")
		return
	var edge: Edge = ctx.edges[k]
	var s: Array = item.get("s", [])
	var dd: Array = item.get("d", [])
	if s.size() != 2 or dd.size() != 2:
		ctx.errors.append("roof item needs s and d ranges")
		return
	var kind := str(item.get("kind", "box"))
	var rows := maxi(1, int(item.get("rows", 1)))
	var gap := float(item.get("gap", 0.8))
	var row_d := (float(dd[1]) - float(dd[0]) - gap * float(rows - 1)) / float(rows)
	for r in rows:
		var d0 := float(dd[0]) + (row_d + gap) * float(r)
		var corners := [edge.at(float(s[0]), d0), edge.at(float(s[1]), d0), edge.at(float(s[1]), d0 + row_d), edge.at(float(s[0]), d0 + row_d)]
		for corner: Vector2 in corners:
			if not Geometry2D.is_point_in_polygon(corner, block.poly) or block.holes.any(func(h: PackedVector2Array) -> bool: return Geometry2D.is_point_in_polygon(corner, h)):
				ctx.errors.append("roof item %s leaves block %s" % [kind, block.id])
				return
		var h := float(item.get("h", 0.45 if kind == "pv" else 2.0))
		var top_mat := str(item.get("top", "pv" if kind == "pv" else item.get("material", "mech")))
		var side_mat := str(item.get("material", "metal" if kind == "pv" else "mech"))
		var center: Vector2 = (corners[0] + corners[2]) * 0.5
		var base := block.roof_y
		if block.form != "flat":
			base = _roof_under(block, center) + float((block.cfg.get("roof", {}) as Dictionary).get("t", 0.15)) - 0.05
		if kind == "cylinder":
			var radius := minf(absf(float(s[1]) - float(s[0])), absf(row_d)) * 0.5
			var sides := maxi(6, int(item.get("sides", 12)))
			var ring: Array = []
			for i in sides:
				ring.append(center + Vector2(cos(TAU * float(i) / float(sides)), sin(TAU * float(i) / float(sides))) * radius)
			_prism(ctx, ring, base, base + h, side_mat, top_mat)
		else:
			_prism(ctx, corners, base, base + h, side_mat, top_mat)


## Vertical prism over a convex quad: sides and top, support role.
static func _prism(ctx: Ctx, corners: Array, y0: float, y1: float, side_mat: String, top_mat: String) -> void:
	var center := Vector2.ZERO
	for corner: Vector2 in corners:
		center += corner
	center /= float(corners.size())
	var sides := ctx.bucket("support", side_mat)
	for i in corners.size():
		var a: Vector2 = corners[i]
		var b: Vector2 = corners[(i + 1) % corners.size()]
		var mid := (a + b) * 0.5
		var facing := Vector3(mid.x - center.x, 0.0, mid.y - center.y)
		sides.quad(Vector3(a.x, y0, a.y), Vector3(b.x, y0, b.y), Vector3(b.x, y1, b.y), Vector3(a.x, y1, a.y), facing)
	var top := ctx.bucket("support", top_mat)
	var c0: Vector2 = corners[0]
	for i in range(1, corners.size() - 1):
		var c1: Vector2 = corners[i]
		var c2: Vector2 = corners[i + 1]
		top.tri(Vector3(c0.x, y1, c0.y), Vector3(c1.x, y1, c1.y), Vector3(c2.x, y1, c2.y), Vector3.UP)


## Walkable paving strip inside the footprint line where a block face is set back.
static func _apron(ctx: Ctx, apron: Dictionary) -> void:
	var k := int(apron.get("edge", -1))
	if k < 0 or k >= ctx.edges.size():
		ctx.errors.append("apron needs a footprint edge")
		return
	var edge: Edge = ctx.edges[k]
	var s0 := float(apron.get("s0", 0.0))
	var s1 := float(apron.get("s1", 0.0))
	var depth0 := float(apron.get("d0", 0.0))
	var depth1 := float(apron.get("d1", 0.0))
	var lift := float(apron.get("lift", 0.09))
	var ground := ctx.bucket("ground", str(apron.get("material", "paving")))
	var cuts: Array = [s0, s1]
	for s: float in edge.stations:
		if s > s0 + 0.001 and s < s1 - 0.001:
			cuts.append(s)
	cuts.sort()
	for i in range(cuts.size() - 1):
		var a: float = cuts[i]
		var b: float = cuts[i + 1]
		var da := lerpf(depth0, depth1, (a - s0) / (s1 - s0))
		var db := lerpf(depth0, depth1, (b - s0) / (s1 - s0))
		var oa := edge.at(a, 0.0)
		var ob := edge.at(b, 0.0)
		var ia := edge.at(a, da)
		var ib := edge.at(b, db)
		var ya := _ground_y(ctx, oa) + lift
		var yb := _ground_y(ctx, ob) + lift
		if da > 0.001 or db > 0.001:
			ground.quad(Vector3(oa.x, ya, oa.y), Vector3(ob.x, yb, ob.y), Vector3(ib.x, _ground_y(ctx, ib) + lift, ib.y), Vector3(ia.x, _ground_y(ctx, ia) + lift, ia.y), Vector3.UP)
		var xa := edge.at(a, -0.3)
		var xb := edge.at(b, -0.3)
		ground.quad(Vector3(oa.x, ya, oa.y), Vector3(ob.x, yb, ob.y), Vector3(xb.x, yb - 0.25, xb.y), Vector3(xa.x, ya - 0.25, xa.y), Vector3(edge.n.x, 1.0, edge.n.y))


# ------------------------------------------------------------------ outbuilding parts

## Open side: posts (support) at the face start and every `module` along it,
## optionally over a knee wall (wall role, both faces and a cap) with an
## entrance `gap` in footprint stations. `post_every` keeps one face start in n
## (pavilions with many short faces).
static func _open_face(ctx: Ctx, face: Face) -> void:
	var block := face.block
	var spec: Dictionary = face.scheme.open
	var w := float(spec.get("post_w", 0.15))
	var module := maxf(0.5, float(spec.get("module", 3.0)))
	var posts := ctx.bucket("support", str(spec.get("post_material", "metal")))
	var t := float((block.cfg.get("roof", {}) as Dictionary).get("t", 0.15))
	var knee: Dictionary = spec.get("knee", {})
	if not knee.is_empty() and not (_in_range(float(knee.get("h", 1.2)), 0.0, 4.0) and float(knee.get("h", 1.2)) > 0.0 and _in_range(float(knee.get("t", 0.15)), 0.0, 1.0) and float(knee.get("t", 0.15)) > 0.0):
		ctx.errors.append("block %s open knee wall needs h in (0, 4] and t in (0, 1] m" % block.id)
		return
	var deck: Dictionary = block.cfg.get("deck", {})
	if not deck.is_empty() and not (_in_range(float(deck.get("t", 0.3)), 0.0, 2.0) and float(deck.get("t", 0.3)) > 0.0):
		ctx.errors.append("block %s deck needs t in (0, 2] m" % block.id)
		return
	var gap: Array = knee.get("gap", [])
	var g0 := INF
	var g1 := -INF
	if gap.size() == 2:
		g0 = minf(_local_station(ctx, face, float(gap[0])), _local_station(ctx, face, float(gap[1])))
		g1 = maxf(_local_station(ctx, face, float(gap[0])), _local_station(ctx, face, float(gap[1])))
	var every := maxi(1, int(spec.get("post_every", 1)))
	for span: Dictionary in face.spans:
		var a := float(span.s0)
		var b := float(span.s1)
		var stations: Array = []
		var x := a
		while x < b - 0.05:
			stations.append(x)
			x += module
		for i in stations.size():
			if i == 0 and a < 0.001 and face.index % every != 0:
				continue
			var s0 := clampf(float(stations[i]), a, b - w)
			var mid := face.a + face.d * (s0 + w * 0.5) - face.n * (w * 0.5)
			var y0 := float(span.y) if not bool(span.ground) else _ground_y(ctx, mid) - BURY_M
			_box(posts, face, s0, s0 + w, y0, _roof_under(block, mid) + t * 0.5, 0.0, w)
		if block.form == "flat" and not deck.is_empty():
			var dy := block.roof_y - float(deck.get("t", 0.3))
			ctx.bucket("support", str(deck.get("material", "slab"))).quad(face.point(a, dy, 0.0), face.point(b, dy, 0.0), face.point(b, block.wall_top, 0.0), face.point(a, block.wall_top, 0.0), face.out3())
		if knee.is_empty():
			continue
		var kh := block.floors[0] + float(knee.get("h", 1.2))
		var kt := float(knee.get("t", 0.15))
		var wall := ctx.bucket("wall", str(knee.get("material", face.scheme.get("material", "render"))))
		# At a block corner the inner face is mitred onto the neighbouring edge, so
		# the knee wall never pokes past it.
		var count := block.poly.size()
		var corner0 := block.poly[face.poly_index]
		var corner1 := block.poly[(face.poly_index + 1) % count]
		var before := (corner0 - block.poly[(face.poly_index + count - 1) % count]).normalized()
		var after := (block.poly[(face.poly_index + 2) % count] - corner1).normalized()
		var pieces: Array = [[a, b]]
		if g1 > g0:
			pieces = [[a, minf(b, g0)], [maxf(a, g1), b]]
		for piece: Array in pieces:
			var p0 := float(piece[0])
			var p1 := float(piece[1])
			if p1 - p0 < 0.05:
				continue
			var q0 := p0
			var q1 := p1
			if p0 < 0.001:
				var hit: Variant = Geometry2D.line_intersects_line(face.a - face.n * kt, face.d, corner0, before)
				if hit != null:
					q0 = ((hit as Vector2) - face.a).dot(face.d)
			if p1 > face.length - 0.001:
				var hit: Variant = Geometry2D.line_intersects_line(face.a - face.n * kt, face.d, corner1, after)
				if hit != null:
					q1 = ((hit as Vector2) - face.a).dot(face.d)
			var y_a := float(span.y) if not bool(span.ground) else _ground_y(ctx, face.a + face.d * p0) - BURY_M
			var y_b := float(span.y) if not bool(span.ground) else _ground_y(ctx, face.a + face.d * p1) - BURY_M
			var out := face.out3()
			wall.quad(face.point(p0, y_a, 0.0), face.point(p1, y_b, 0.0), face.point(p1, kh, 0.0), face.point(p0, kh, 0.0), out)
			wall.quad(face.point(q0, y_a, kt), face.point(q1, y_b, kt), face.point(q1, kh, kt), face.point(q0, kh, kt), -out)
			wall.quad(face.point(p0, kh, 0.0), face.point(p1, kh, 0.0), face.point(q1, kh, kt), face.point(q0, kh, kt), Vector3.UP)
			wall.quad(face.point(p0, y_a, 0.0), face.point(p0, kh, 0.0), face.point(q0, kh, kt), face.point(q0, y_a, kt), -face.dir3())
			wall.quad(face.point(p1, y_b, 0.0), face.point(p1, kh, 0.0), face.point(q1, kh, kt), face.point(q1, y_b, kt), face.dir3())


## Opt-in pergola ("pergola" on a flat block, normally with open sides): checks
## its fields. A pergola has no roof slab, deck, parapet or roof items, and its
## outline must be convex.
static func _pergola_valid(ctx: Ctx, block: Block) -> bool:
	var spec: Variant = block.cfg.get("pergola")
	var ok := spec is Dictionary and block.form == "flat" and not block.cfg.has("deck") and not block.cfg.has("roof_items") and _convex(block.poly)
	if ok:
		var edge := int(spec.get("rafter_edge", -1))
		ok = edge >= 0 and edge < ctx.edges.size() \
			and _in_range(float(spec.get("beam_w", 0.2)), 0.02, 1.0) and _in_range(float(spec.get("beam_h", 0.3)), 0.02, 1.0) \
			and _in_range(float(spec.get("rafter_w", 0.08)), 0.02, 0.5) and _in_range(float(spec.get("rafter_h", 0.2)), 0.02, 1.0) \
			and _in_range(float(spec.get("spacing", 0.6)), 0.2, 5.0)
	if not ok:
		ctx.errors.append("block %s pergola needs a flat convex block without deck or roof items, a valid rafter_edge, beam_w/beam_h 0.02-1, rafter_w 0.02-0.5, rafter_h 0.02-1 and spacing 0.2-5 m" % block.id)
	return ok


## Open pergola over its block (support role): beams round the outline just
## under the roof line and rafters on them across the block, at right angles to
## footprint edge `rafter_edge`, every `spacing` along it.
static func _pergola(ctx: Ctx, block: Block) -> void:
	var spec: Dictionary = block.cfg.pergola
	var bucket := ctx.bucket("support", str(spec.get("material", "timber")))
	var half := float(spec.get("beam_w", 0.2)) * 0.5
	var y0 := block.roof_y - float(spec.get("beam_h", 0.3))
	var count := block.poly.size()
	for i in count:
		var n := _outward(block.poly, i)
		_plan_box(bucket, block.poly[i] - n * half, block.poly[(i + 1) % count] - n * half, n, y0, block.roof_y, half)
	var edge: Edge = ctx.edges[int(spec.rafter_edge)]
	var rafter_half := float(spec.get("rafter_w", 0.08)) * 0.5
	var rafter_top := block.roof_y + float(spec.get("rafter_h", 0.2))
	var spacing := float(spec.get("spacing", 0.6))
	var lo := INF
	var hi := -INF
	for p: Vector2 in block.poly:
		lo = minf(lo, edge.station(p))
		hi = maxf(hi, edge.station(p))
	var s := lo + spacing * 0.5
	while s < hi - rafter_half:
		# The rafter line edge.at(s, t) for all t, clipped to the convex outline.
		var q := edge.at(s, 0.0)
		var t0 := -INF
		var t1 := INF
		for i in count:
			var m := _outward(block.poly, i)
			var rate := -m.dot(edge.n)
			var room := m.dot(block.poly[i] - q)
			if absf(rate) < 1e-9:
				if room < 0.0:
					t1 = -INF
			elif rate > 0.0:
				t1 = minf(t1, room / rate)
			else:
				t0 = maxf(t0, room / rate)
		if t1 - t0 > 0.1:
			_plan_box(bucket, edge.at(s, t0), edge.at(s, t1), edge.d, block.roof_y, rafter_top, rafter_half)
		s += spacing


## Caged steel ladder (support role) centred on its bay, from 0.3 m above grade
## to 1 m over the wall top. Not walkable; it is a climbing fixture.
static func _ladder(ctx: Ctx, face: Face, bay: Dictionary) -> void:
	var metal := ctx.bucket("support", "rail" if ctx.materials.has("rail") else "metal")
	var c := (float(bay.s0) + float(bay.s1)) * 0.5
	var y0 := _ground_y(ctx, face.a + face.d * c) + 0.3
	var y1 := face.block.wall_top + 1.0
	var half := 0.25
	var rail := -0.18
	for side: float in [-1.0, 1.0]:
		_box(metal, face, c + side * half - 0.025, c + side * half + 0.025, y0, y1, rail - 0.025, rail + 0.025, false)
	var y := y0 + 0.2
	while y < y1 - 0.1:
		_box(metal, face, c - half, c + half, y, y + 0.03, rail - 0.015, rail + 0.015, false)
		y += 0.3
	var cage0 := y0 + 2.1
	var reach := rail - 0.72
	var hoop := cage0
	while hoop < y1 - 0.05:
		for side: float in [-1.0, 1.0]:
			_box(metal, face, c + side * 0.38 - 0.02, c + side * 0.38 + 0.02, hoop, hoop + 0.04, reach, rail, false)
		_box(metal, face, c - 0.38, c + 0.38, hoop, hoop + 0.04, reach - 0.04, reach, false)
		hoop += 0.9
	for bar: float in [-0.38, -0.13, 0.13, 0.38]:
		var depth := reach if absf(bar) < 0.3 else (rail + reach) * 0.5
		_box(metal, face, c + bar - 0.015, c + bar + 0.015, cage0, y1, depth - 0.03, depth, false)


## Walkable ramp from a raised deck along the facade to the local grade (slope
## at most 1:12 by default), with a side skirt; `dir` picks the facade direction.
static func _ramp(ctx: Ctx, face: Face, ramp: Dictionary, c: float, land_w: float, land_d: float, y0: float) -> void:
	var sgn := -1.0 if float(ramp.get("dir", 1)) < 0.0 else 1.0
	var rw := minf(float(ramp.get("w", 1.2)), land_d)
	var slope := maxf(0.02, float(ramp.get("slope", 0.083)))
	var s0 := c + sgn * land_w * 0.5
	var length := 1.0
	for _i in 30:
		var probe := face.a + face.d * (s0 + sgn * length) + face.n * (rw * 0.5)
		length = maxf(0.5, (y0 - _ground_y(ctx, probe)) / slope)
	var s1 := s0 + sgn * length
	var g1 := _ground_y(ctx, face.a + face.d * s1 + face.n * (rw * 0.5)) + 0.02
	var ground := ctx.bucket("ground", "paving")
	ground.quad(face.point(s0, y0, 0.0), face.point(s1, g1, 0.0), face.point(s1, g1, -rw), face.point(s0, y0, -rw), Vector3.UP)
	var skirt := ctx.bucket("support", "slab")
	var base0 := _ground_y(ctx, face.a + face.d * s0 + face.n * rw) - BURY_M
	var base1 := _ground_y(ctx, face.a + face.d * s1 + face.n * rw) - BURY_M
	skirt.quad(face.point(s0, base0, -rw), face.point(s1, base1, -rw), face.point(s1, g1, -rw), face.point(s0, y0, -rw), face.out3())
	var rails := ctx.bucket("support", "rail" if ctx.materials.has("rail") else "metal")
	var p0 := face.point(s0, y0, -rw + 0.05)
	var p1 := face.point(s1, g1, -rw + 0.05)
	_pipe_slope(rails, p0, p1, face.out3())


## Pipe rails round a raised deck: its outer edge and the open side(s) the ramp
## does not use.
static func _deck_rails(ctx: Ctx, face: Face, ramp: Dictionary, c: float, land_w: float, land_d: float, y0: float) -> void:
	var rails := ctx.bucket("support", "rail" if ctx.materials.has("rail") else "metal")
	var a := face.a + face.d * (c - land_w * 0.5)
	var b := face.a + face.d * (c + land_w * 0.5)
	var front := face.n * (land_d - 0.05)
	_pipe_run(rails, a + front, b + front, face.n, y0, y0 + RAIL_H_M)
	var rw := minf(float(ramp.get("w", 1.2)), land_d) if not ramp.is_empty() else 0.0
	var ramp_side := 0.0 if ramp.is_empty() else (-1.0 if float(ramp.get("dir", 1)) < 0.0 else 1.0)
	for side: float in [-1.0, 1.0]:
		var edge := a if side < 0.0 else b
		var inset := face.d * (0.05 * -side)
		var start := 0.0 if side != ramp_side else rw
		var p0 := edge + inset + face.n * start
		var p1 := edge + inset + face.n * (land_d - 0.05)
		if p0.distance_to(p1) > 0.2:
			_pipe_run(rails, p0, p1, face.d * side, y0, y0 + RAIL_H_M)


## Level pipe rail along p0 -> p1 (plan points): posts at most 1.8 m apart, a top
## rail and a mid rail. `n` is the side the rail faces.
static func _pipe_run(bucket: Bucket, p0: Vector2, p1: Vector2, n: Vector2, y0: float, y1: float) -> void:
	var length := p0.distance_to(p1)
	if length < 0.05:
		return
	var d := (p1 - p0) / length
	var count := maxi(1, ceili(length / 1.8))
	var half := RAIL_BAR_M * 0.5
	for i in count + 1:
		var p := p0.lerp(p1, float(i) / float(count))
		_plan_box(bucket, p - d * half, p + d * half, n, y0, y1, half)
	_plan_box(bucket, p0, p1, n, y1 - RAIL_BAR_M, y1, half)
	_plan_box(bucket, p0, p1, n, (y0 + y1) * 0.5 - half, (y0 + y1) * 0.5 + half, half)


## Sloping pipe rail between two walking-surface points (world), facing `out`.
static func _pipe_slope(bucket: Bucket, p0: Vector3, p1: Vector3, out: Vector3) -> void:
	var plan := Vector2(p1.x - p0.x, p1.z - p0.z)
	var length := plan.length()
	if length < 0.05:
		return
	var count := maxi(1, ceili(length / 1.8))
	var half := RAIL_BAR_M * 0.5
	var d := plan / length
	var n := Vector2(out.x, out.z).normalized()
	for i in count + 1:
		var p := p0.lerp(p1, float(i) / float(count))
		var q := Vector2(p.x, p.z)
		_plan_box(bucket, q - d * half, q + d * half, n, p.y, p.y + RAIL_H_M, half)
	for h: float in [RAIL_H_M, RAIL_H_M * 0.5]:
		var a := p0 + Vector3.UP * h
		var b := p1 + Vector3.UP * h
		var side := Vector3(n.x, 0.0, n.y) * half
		bucket.quad(a + side - Vector3.UP * half, b + side - Vector3.UP * half, b + side + Vector3.UP * half, a + side + Vector3.UP * half, out)
		bucket.quad(a - side - Vector3.UP * half, b - side - Vector3.UP * half, b - side + Vector3.UP * half, a - side + Vector3.UP * half, -out)
		bucket.quad(a + side + Vector3.UP * half, b + side + Vector3.UP * half, b - side + Vector3.UP * half, a - side + Vector3.UP * half, Vector3.UP)
		bucket.quad(a + side - Vector3.UP * half, b + side - Vector3.UP * half, b - side - Vector3.UP * half, a - side - Vector3.UP * half, Vector3.DOWN)


## Closed box over the plan segment p0 -> p1, `half` wide either side, y0..y1.
static func _plan_box(bucket: Bucket, p0: Vector2, p1: Vector2, n: Vector2, y0: float, y1: float, half: float) -> void:
	var length := p0.distance_to(p1)
	if length < 1e-4:
		return
	var d := (p1 - p0) / length
	var side := Vector2(-d.y, d.x) * half
	if side.dot(n) < 0.0:
		side = -side
	var a0 := p0 + side
	var a1 := p1 + side
	var b0 := p0 - side
	var b1 := p1 - side
	var out := Vector3(side.x, 0.0, side.y)
	var along := Vector3(d.x, 0.0, d.y)
	bucket.quad(Vector3(a0.x, y0, a0.y), Vector3(a1.x, y0, a1.y), Vector3(a1.x, y1, a1.y), Vector3(a0.x, y1, a0.y), out)
	bucket.quad(Vector3(b0.x, y0, b0.y), Vector3(b1.x, y0, b1.y), Vector3(b1.x, y1, b1.y), Vector3(b0.x, y1, b0.y), -out)
	bucket.quad(Vector3(a0.x, y1, a0.y), Vector3(a1.x, y1, a1.y), Vector3(b1.x, y1, b1.y), Vector3(b0.x, y1, b0.y), Vector3.UP)
	bucket.quad(Vector3(a0.x, y0, a0.y), Vector3(a1.x, y0, a1.y), Vector3(b1.x, y0, b1.y), Vector3(b0.x, y0, b0.y), Vector3.DOWN)
	bucket.quad(Vector3(a0.x, y0, a0.y), Vector3(b0.x, y0, b0.y), Vector3(b0.x, y1, b0.y), Vector3(a0.x, y1, a0.y), -along)
	bucket.quad(Vector3(a1.x, y0, a1.y), Vector3(b1.x, y0, b1.y), Vector3(b1.x, y1, b1.y), Vector3(a1.x, y1, a1.y), along)


# ------------------------------------------------------------------ emission

static func _make_materials(ctx: Ctx) -> void:
	var palette: Dictionary = ctx.cfg.get("palette", {})
	for key: String in palette:
		var entry: Dictionary = palette[key]
		var rgb: Array = entry.get("rgb", [])
		if rgb.size() != 3:
			ctx.errors.append("palette %s needs rgb" % key)
			return
		var cache_key := "%s|%s|%s|%s|%s|%s|%s" % [key, rgb[0], rgb[1], rgb[2], entry.get("alpha", 1.0), entry.get("roughness", 0.9), entry.get("metallic", 0.0)]
		if not _material_cache.has(cache_key):
			var material := StandardMaterial3D.new()
			material.resource_name = "Midrise_" + key
			material.albedo_color = Color(float(rgb[0]), float(rgb[1]), float(rgb[2]), float(entry.get("alpha", 1.0)))
			material.roughness = float(entry.get("roughness", 0.9))
			material.metallic = float(entry.get("metallic", 0.0))
			if float(entry.get("alpha", 1.0)) < 1.0:
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				material.cull_mode = BaseMaterial3D.CULL_BACK
			_material_cache[cache_key] = material
		ctx.materials[key] = _material_cache[cache_key]


## True when value is finite and lo <= value <= hi.
static func _in_range(value: float, lo: float, hi: float) -> bool:
	return is_finite(value) and value >= lo and value <= hi


static func _emit(ctx: Ctx, root: Node3D) -> int:
	var keys: Array = ctx.buckets.keys()
	keys.sort()
	var triangles := 0
	for key: String in keys:
		var bucket: Bucket = ctx.buckets[key]
		if bucket.vertices.is_empty():
			continue
		var parts := key.split("|")
		var role := parts[0]
		var mat := parts[1]
		if role not in ROLES or not ctx.materials.has(mat):
			ctx.errors.append("unknown role or palette key: " + key)
			continue
		var finite := true
		for v: Vector3 in bucket.vertices:
			if not v.is_finite():
				finite = false
				break
		if not finite:
			ctx.errors.append("non-finite vertex in " + key)
			continue
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = bucket.vertices
		arrays[Mesh.ARRAY_NORMAL] = bucket.normals
		arrays[Mesh.ARRAY_TEX_UV] = bucket.uvs
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(0, ctx.materials[mat])
		var node := MeshInstance3D.new()
		node.name = "Midrise_%s_%s" % [role, mat]
		node.mesh = mesh
		node.set_meta("family_role", role)
		root.add_child(node)
		triangles += int(bucket.vertices.size() / 3.0)
	return triangles
