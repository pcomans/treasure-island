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
	var floor_cfg: Dictionary = ctx.cfg.get("floor", {})
	var anchor := int(floor_cfg.get("anchor_edge", -1))
	if anchor < 0 or anchor >= ctx.edges.size():
		ctx.errors.append("floor needs the photographed street side as anchor_edge")
		return
	var street: Edge = ctx.edges[anchor]
	var count := maxi(8, ceili(street.length))
	var grades: Array[float] = []
	for i in count:
		grades.append(_ground_y(ctx, street.at(street.length * (float(i) + 0.5) / float(count), 0.0)))
	grades.sort()
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
	for i in range(0, v.size(), 12):
		var a := Vector3(float(v[i]), float(v[i + 1]), float(v[i + 2]))
		var b := Vector3(float(v[i + 3]), float(v[i + 4]), float(v[i + 5]))
		var normal := Vector2(float(nr[i]), float(nr[i + 2])).normalized()
		if previous_end.is_finite() and Vector2(previous_end.x, previous_end.z).distance_to(Vector2(a.x, a.z)) > 0.001:
			ctx.errors.append("wall runs are not contiguous")
			return []
		previous_end = b
		if groups.is_empty() or (groups[-1].n as Vector2).dot(normal) < 0.9999:
			groups.append({"n": normal, "points": [a]})
		(groups[-1].points as Array).append(b)
	var first: Vector3 = (groups[0].points as Array)[0]
	if Vector2(previous_end.x, previous_end.z).distance_to(Vector2(first.x, first.z)) > 0.001:
		ctx.errors.append("wall ring is not closed")
		return []
	var target: Dictionary = ctx.cfg.target
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
static func _ground_y(ctx: Ctx, p: Vector2) -> float:
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
		if w1 >= -1e-7 and w2 >= -1e-7 and w3 >= -1e-7:
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
		var floor_y := float(item.get("floor_y", ctx.floor_y))
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
		ctx.blocks.append(block)
	if total > footprint_area + 0.05:
		ctx.errors.append("blocks overlap or exceed the footprint (%.3f > %.3f m2)" % [total, footprint_area])
		return
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
		if absf((b - a).cross(c - b)) > 1e-6:
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


static func _outward(poly: PackedVector2Array, i: int) -> Vector2:
	var a := poly[i]
	var b := poly[(i + 1) % poly.size()]
	var d := (b - a).normalized()
	var n := Vector2(d.y, -d.x)
	if (_centroid(poly) - (a + b) * 0.5).dot(n) > 0.0:
		n = -n
	return n


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
		if other == block:
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
		_facade(ctx, face)


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
		if kind not in ["loggia", "frame", "entry", "garage", "vents", "band", "corner"]:
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
		"vents":
			var count := int(feature.get("count", 2))
			var w := float(feature.get("w", 1.4))
			var h := float(feature.get("h", 0.9))
			var y := block.floors[0] + float(feature.get("y", 2.4))
			for v in count:
				var c := s0 + (s1 - s0) * (float(v) + 0.5) / float(count)
				out.append({"s0": c - w * 0.5, "s1": c + w * 0.5, "y0": y, "y1": y + h, "kind": "vent", "spec": feature, "k": 0})
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
static func _glazing(ctx: Ctx, face: Face, spec: Dictionary, s0: float, s1: float, y0: float, y1: float, depth: float) -> void:
	var out := face.out3()
	_rect(ctx.bucket("wall", str(spec.get("glass", "glass"))), face, s0, s1, y0, y1, depth, out)
	var frame := ctx.bucket("wall", str(spec.get("frame", "frame")))
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
	var roof_mat := str(block.cfg.get("roof_material", "roof"))
	var bucket := ctx.bucket("roof", roof_mat)
	var p0 := block.poly[0]
	for i in range(1, block.poly.size() - 1):
		var p1 := block.poly[i]
		var p2 := block.poly[i + 1]
		bucket.tri(Vector3(p0.x, block.roof_y, p0.y), Vector3(p1.x, block.roof_y, p1.y), Vector3(p2.x, block.roof_y, p2.y), Vector3.UP)
	_parapets(ctx, block)
	for item: Dictionary in block.cfg.get("roof_items", []):
		_roof_item(ctx, block, item)


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
			if not Geometry2D.is_point_in_polygon(corner, block.poly):
				ctx.errors.append("roof item %s leaves block %s" % [kind, block.id])
				return
		var h := float(item.get("h", 0.45 if kind == "pv" else 2.0))
		var top_mat := str(item.get("top", "pv" if kind == "pv" else item.get("material", "mech")))
		var side_mat := str(item.get("material", "metal" if kind == "pv" else "mech"))
		_prism(ctx, corners, block.roof_y, block.roof_y + h, side_mat, top_mat)


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


# ------------------------------------------------------------------ emission

static func _make_materials(ctx: Ctx) -> void:
	var palette: Dictionary = ctx.cfg.get("palette", {})
	for key: String in palette:
		var entry: Dictionary = palette[key]
		var rgb: Array = entry.get("rgb", [])
		if rgb.size() != 3:
			ctx.errors.append("palette %s needs rgb" % key)
			return
		var material := StandardMaterial3D.new()
		material.resource_name = "Midrise_" + key
		material.albedo_color = Color(float(rgb[0]), float(rgb[1]), float(rgb[2]), float(entry.get("alpha", 1.0)))
		material.roughness = float(entry.get("roughness", 0.9))
		material.metallic = float(entry.get("metallic", 0.0))
		if float(entry.get("alpha", 1.0)) < 1.0:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.cull_mode = BaseMaterial3D.CULL_BACK
		ctx.materials[key] = material


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
