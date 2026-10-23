extends RefCounted
## Covered fixed pier family: a walkable concrete pier deck over the water under a
## long, thin canopy on two rows of round columns (Treasure Island ferry pier).
##
## build(wall, roof, cfg, chunks) follows the housing_site_family contract: it
## returns a root with build_valid/source_key metadata whose MeshInstance3D
## children carry family_role "wall" (sprayable concrete and columns), "roof"
## (the canopy top), "solid" (opaque or glazed non-receivers on the spray layer)
## or "ground" (the walkway). housing_family_live_attachment hides the generated
## record meshes and adds the matching source-owned contacts.
##
## The frozen pier corners come from the config and are bound to the generated
## (shore-clipped) wall record by its two land-side corners. The frozen land under
## the plaza end sets the deck level and how far the abutment runs before the deck
## stands on piles. Dimensions, cadence and the gate booth are production inference
## from dated references; see game/resources/pier_family/README.md.

const SCHEMA := "ti.pier-canopy-family/1"
const ROLES := ["wall", "roof", "solid", "ground"]
## Binding tolerance between config corners and the generated record (mm rounding).
const CORNER_TOLERANCE_M := 0.002
static var _material_cache: Dictionary = {}


class Bucket:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var misaligned := 0

	## One triangle whose front (Godot clockwise winding) faces `facing`.
	func tri(a: Vector3, b: Vector3, c: Vector3, facing: Vector3) -> void:
		var cross := (b - a).cross(c - a)
		if cross.length_squared() < 1e-10:
			return
		if absf(cross.normalized().dot(facing.normalized())) < 0.05:
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


## Pier frame: station s (m) from the plaza (NE) end toward the water (SW) end,
## lateral d (m) from the NW edge toward the SE edge, height y (world).
class Frame:
	var north := Vector2.ZERO
	var east := Vector2.ZERO
	var south := Vector2.ZERO
	var west := Vector2.ZERO
	var length := 0.0

	func edge_nw(s: float) -> Vector2:
		return north.lerp(west, s / length)

	func edge_se(s: float) -> Vector2:
		return east.lerp(south, s / length)

	func width(s: float) -> float:
		return edge_nw(s).distance_to(edge_se(s))

	func plan(s: float, d: float) -> Vector2:
		var a := edge_nw(s)
		var b := edge_se(s)
		return a + (b - a).normalized() * d

	func at(s: float, d: float, y: float) -> Vector3:
		var p := plan(s, d)
		return Vector3(p.x, y, p.y)

	## Unit vectors (world, horizontal): along +s, and across toward +d (SE).
	func along() -> Vector3:
		var a := ((west + south) - (north + east)).normalized()
		return Vector3(a.x, 0.0, a.y)

	func across(s: float) -> Vector3:
		var c := (edge_se(s) - edge_nw(s)).normalized()
		return Vector3(c.x, 0.0, c.y)


class Ctx:
	var cfg: Dictionary = {}
	var source := ""
	var f := Frame.new()
	var deck_y := 0.0
	var land: Array = []
	var shore_nw := 0.0
	var shore_se := 0.0
	var buckets: Dictionary = {}
	var materials: Dictionary = {}
	var errors: Array[String] = []

	func bucket(role: String, mat: String) -> Bucket:
		var key := role + "|" + mat
		if not buckets.has(key):
			buckets[key] = Bucket.new()
		return buckets[key]

	func num(section: String, key: String, fallback: float) -> float:
		var part: Variant = cfg.get(section, {})
		if part is Dictionary and (part as Dictionary).has(key):
			return float((part as Dictionary)[key])
		return fallback


static func build(wall: Dictionary, roof: Dictionary, cfg: Dictionary, chunks: Array = []) -> Node3D:
	var root := Node3D.new()
	var source := str(cfg.get("target", {}).get("source_key", ""))
	root.name = "SharedPier_" + source
	root.set_meta("source_key", source)
	root.set_meta("dimensions", "production_inference_from_dated_references")
	var ctx := Ctx.new()
	ctx.cfg = cfg
	ctx.source = source
	_build_all(ctx, wall, roof, chunks)
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
		push_error("Pier family %s: %s" % [source, message])
	root.set_meta("build_valid", ctx.errors.is_empty())
	root.set_meta("pier_triangles", triangles)
	root.set_meta("pier_deck_y", ctx.deck_y)
	return root


static func _build_all(ctx: Ctx, wall: Dictionary, roof: Dictionary, chunks: Array) -> void:
	if str(ctx.cfg.get("schema_version", "")) != SCHEMA:
		ctx.errors.append("unsupported config schema")
		return
	if ctx.source.is_empty() or wall.get("source_keys", []) != [ctx.source] or roof.get("source_keys", []) != [ctx.source]:
		ctx.errors.append("wall/roof records do not belong to the configured source")
		return
	var corners: Variant = ctx.cfg.get("target", {}).get("corners", {})
	for key: String in ["north", "east", "south", "west"]:
		if not corners is Dictionary or not (corners as Dictionary).get(key) is Array or (corners[key] as Array).size() != 2:
			ctx.errors.append("target.corners needs north, east, south and west [x, z]")
			return
	ctx.f.north = Vector2(float(corners.north[0]), float(corners.north[1]))
	ctx.f.east = Vector2(float(corners.east[0]), float(corners.east[1]))
	ctx.f.south = Vector2(float(corners.south[0]), float(corners.south[1]))
	ctx.f.west = Vector2(float(corners.west[0]), float(corners.west[1]))
	ctx.f.length = ((ctx.f.north + ctx.f.east) * 0.5).distance_to((ctx.f.south + ctx.f.west) * 0.5)
	# The generated record is the frozen footprint clipped at the shore: its land
	# side keeps the frozen north and east corners exactly.
	for corner: Vector2 in [ctx.f.north, ctx.f.east]:
		if not _record_has_corner(wall, corner):
			ctx.errors.append("frozen pier corner %s is not in the generated wall record" % corner)
			return
	if not is_finite(ctx.f.length) or ctx.f.length < 10.0:
		ctx.errors.append("pier corners do not describe a pier")
		return
	_collect_land(ctx, chunks)
	# Deck level: the frozen land along the plaza end plus the configured lift
	# (flush with the paving and path drapes laid on that land).
	var grades: Array[float] = []
	var w0 := ctx.f.width(0.0)
	for i in 9:
		var y := _ground_y(ctx, ctx.f.plan(0.05, w0 * (0.1 + 0.8 * float(i) / 8.0)))
		if is_finite(y):
			grades.append(y)
	if grades.size() < 5:
		ctx.errors.append("the plaza end of the pier is not on frozen land")
		return
	grades.sort()
	ctx.deck_y = grades[grades.size() - 1] + ctx.num("deck", "above_land", 0.1)
	var inset := ctx.num("deck", "inset", 0.4)
	ctx.shore_nw = _shore_station(ctx, inset)
	ctx.shore_se = _shore_station(ctx, -inset)
	if ctx.shore_nw < 2.0 or ctx.shore_se < 2.0 or ctx.shore_nw > ctx.f.length - 10.0 or ctx.shore_se > ctx.f.length - 10.0:
		ctx.errors.append("the shore crossing is not between the plaza and water ends")
		return
	_make_materials(ctx)
	if not ctx.errors.is_empty():
		return
	_deck(ctx)
	_side_walls(ctx)
	_columns(ctx)
	_windscreen(ctx)
	_rails(ctx)
	_gate(ctx)
	_roof(ctx)


static func _record_has_corner(record: Dictionary, corner: Vector2) -> bool:
	var v: Array = record.get("vertices", [])
	for i in range(0, v.size() - 2, 3):
		if Vector2(float(v[i]), float(v[i + 2])).distance_to(corner) <= CORNER_TOLERANCE_M:
			return true
	return false


static func _collect_land(ctx: Ctx, chunks: Array) -> void:
	var low := ctx.f.north.min(ctx.f.east).min(ctx.f.south).min(ctx.f.west) - Vector2(5.0, 5.0)
	var high := ctx.f.north.max(ctx.f.east).max(ctx.f.south).max(ctx.f.west) + Vector2(5.0, 5.0)
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


## Frozen land elevation under a plan point, or NAN over the water.
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
	return NAN


## Last station (0.25 m steps) along a side's outer deck line that is still over
## frozen land. A positive offset measures from the NW edge, negative from the SE.
static func _shore_station(ctx: Ctx, offset: float) -> float:
	var s := 0.0
	while s + 0.25 < ctx.f.length:
		var d := offset if offset > 0.0 else ctx.f.width(s + 0.25) + offset
		if not is_finite(_ground_y(ctx, ctx.f.plan(s + 0.25, d))):
			break
		s += 0.25
	return s


# ------------------------------------------------------------------ geometry helpers

## Box in the pier frame between stations s0..s1, laterals d0..d1 and heights
## y0..y1, with outward faces; `skip` lists faces to omit ("bottom", "top",
## "s0", "s1", "d0", "d1").
static func _box(ctx: Ctx, b: Bucket, s0: float, s1: float, d0: float, d1: float, y0: float, y1: float, skip: Array = []) -> void:
	var f := ctx.f
	var u := f.along()
	var p := func(s: float, d: float, y: float) -> Vector3: return f.at(s, d, y)
	if "bottom" not in skip:
		b.quad(p.call(s0, d0, y0), p.call(s1, d0, y0), p.call(s1, d1, y0), p.call(s0, d1, y0), Vector3.DOWN)
	if "top" not in skip:
		b.quad(p.call(s0, d0, y1), p.call(s1, d0, y1), p.call(s1, d1, y1), p.call(s0, d1, y1), Vector3.UP)
	if "s0" not in skip:
		b.quad(p.call(s0, d0, y0), p.call(s0, d1, y0), p.call(s0, d1, y1), p.call(s0, d0, y1), -u)
	if "s1" not in skip:
		b.quad(p.call(s1, d0, y0), p.call(s1, d1, y0), p.call(s1, d1, y1), p.call(s1, d0, y1), u)
	if "d0" not in skip:
		b.quad(p.call(s0, d0, y0), p.call(s1, d0, y0), p.call(s1, d0, y1), p.call(s0, d0, y1), -f.across(s0))
	if "d1" not in skip:
		b.quad(p.call(s0, d1, y0), p.call(s1, d1, y0), p.call(s1, d1, y1), p.call(s0, d1, y1), f.across(s0))


## Vertical cylinder (prism) about a plan point.
static func _cylinder(b: Bucket, center: Vector2, radius: float, y0: float, y1: float, sides: int, top: bool, bottom: bool) -> void:
	var ring: Array[Vector2] = []
	for i in sides:
		var angle := TAU * float(i) / float(sides)
		ring.append(center + Vector2(cos(angle), sin(angle)) * radius)
	for i in sides:
		var a := ring[i]
		var c := ring[(i + 1) % sides]
		var mid := (a + c) * 0.5 - center
		b.quad(Vector3(a.x, y0, a.y), Vector3(c.x, y0, c.y), Vector3(c.x, y1, c.y), Vector3(a.x, y1, a.y), Vector3(mid.x, 0.0, mid.y))
		if top:
			b.tri(Vector3(center.x, y1, center.y), Vector3(a.x, y1, a.y), Vector3(c.x, y1, c.y), Vector3.UP)
		if bottom:
			b.tri(Vector3(center.x, y0, center.y), Vector3(a.x, y0, a.y), Vector3(c.x, y0, c.y), Vector3.DOWN)


# ------------------------------------------------------------------ parts

## Walkway (ground) and the concrete deck structure: abutment over the land,
## edge beams with chamfered soffits, pile caps and piles over the water.
static func _deck(ctx: Ctx) -> void:
	var f := ctx.f
	var y := ctx.deck_y
	var inset := ctx.num("deck", "inset", 0.4)
	var nw_t := ctx.num("walls", "nw_t", 0.55)
	var se_t := ctx.num("walls", "se_t", 0.5)
	var beam := ctx.num("deck", "edge_beam_depth", 0.85)
	var chamfer := ctx.num("deck", "chamfer", 0.25)
	var abut := ctx.num("deck", "abutment_depth", 2.2)
	var end_s := f.length - inset
	# Walkway panels between the inner wall faces, two tones for the saw-cut panels.
	var panel := ctx.num("deck", "panel", 3.0)
	var s := 0.0
	var k := 0
	while s < end_s - 0.01:
		var s1 := minf(s + panel, end_s)
		var b := ctx.bucket("ground", "deck" if k % 2 == 0 else "deck_b")
		var w0 := f.width(s)
		var w1 := f.width(s1)
		b.quad(f.at(s, inset + nw_t, y), f.at(s1, inset + nw_t, y), f.at(s1, w1 - inset - se_t, y), f.at(s, w0 - inset - se_t, y), Vector3.UP)
		s = s1
		k += 1
	var concrete := ctx.bucket("solid", "edge_beam")
	var bottom_y := y - beam - chamfer
	# Plaza end: the abutment face under the walkway (mostly below the paving).
	var w_end := f.width(0.0)
	concrete.quad(f.at(0.0, inset, y - abut), f.at(0.0, w_end - inset, y - abut), f.at(0.0, w_end - inset, y), f.at(0.0, inset, y), -f.along())
	# Edge beams over the water (the land part is the abutment face of each wall).
	for side: int in [0, 1]:
		var shore := ctx.shore_nw if side == 0 else ctx.shore_se
		var s0 := shore
		var s1 := end_s
		var w_a := f.width(s0)
		var w_b := f.width(s1)
		var out_a := inset if side == 0 else w_a - inset
		var out_b := inset if side == 0 else w_b - inset
		var in_a := inset + chamfer if side == 0 else w_a - inset - chamfer
		var in_b := inset + chamfer if side == 0 else w_b - inset - chamfer
		var facing := -f.across(s0) if side == 0 else f.across(s0)
		concrete.quad(f.at(s0, out_a, y - beam), f.at(s1, out_b, y - beam), f.at(s1, out_b, y), f.at(s0, out_a, y), facing)
		concrete.quad(f.at(s0, out_a, y - beam), f.at(s1, out_b, y - beam), f.at(s1, in_b, bottom_y), f.at(s0, in_a, bottom_y), facing + Vector3.DOWN)
	# Soffit between the chamfers, from the shoreline out, and the water-end face.
	var s_from := minf(ctx.shore_nw, ctx.shore_se)
	var wa := f.width(s_from)
	var wb := f.width(end_s)
	concrete.quad(f.at(s_from, inset + chamfer, bottom_y), f.at(end_s, inset + chamfer, bottom_y), f.at(end_s, wb - inset - chamfer, bottom_y), f.at(s_from, wa - inset - chamfer, bottom_y), Vector3.DOWN)
	var wl := f.width(end_s)
	var u := f.along()
	concrete.quad(f.at(end_s, inset, y - beam), f.at(end_s, wl - inset, y - beam), f.at(end_s, wl - inset, y), f.at(end_s, inset, y), u)
	concrete.quad(f.at(end_s, inset, y - beam), f.at(end_s, wl - inset, y - beam), f.at(end_s, wl - inset - chamfer, bottom_y), f.at(end_s, inset + chamfer, bottom_y), u + Vector3.DOWN)
	# Pile bents under each column pair that stands over the water.
	var cap := ctx.bucket("solid", "pile_cap")
	var piles := ctx.bucket("solid", "pile")
	var cap_depth := ctx.num("deck", "pile_cap_depth", 0.6)
	for station: float in _column_stations(ctx):
		if station < maxf(ctx.shore_nw, ctx.shore_se) + 0.6:
			continue
		var w := f.width(station)
		_box(ctx, cap, station - 0.45, station + 0.45, inset - 0.15, w - inset + 0.15, bottom_y - cap_depth, bottom_y + 0.02, [])
		for d: float in [inset + 0.95, w - inset - 0.95]:
			_cylinder(piles, f.plan(station, d), 0.3, ctx.num("deck", "pile_bottom_y", -3.0), bottom_y - cap_depth + 0.01, 12, false, false)


## Concrete upstand (NW) and parapet (SE) with end blocks at the plaza; sprayable.
static func _side_walls(ctx: Ctx) -> void:
	var f := ctx.f
	var y := ctx.deck_y
	var inset := ctx.num("deck", "inset", 0.4)
	var h := ctx.num("walls", "h", 0.55)
	var abut := ctx.num("deck", "abutment_depth", 2.2)
	var end_len := ctx.num("walls", "end_block_len", 0.65)
	var end_h := ctx.num("walls", "end_block_h", 0.95)
	var end_s := f.length - inset
	var wall := ctx.bucket("wall", "concrete")
	for side: int in [0, 1]:
		var t := ctx.num("walls", "nw_t" if side == 0 else "se_t", 0.55 if side == 0 else 0.5)
		var shore := ctx.shore_nw if side == 0 else ctx.shore_se
		var outer := func(s: float) -> float: return inset if side == 0 else f.width(s) - inset
		var inner := func(s: float) -> float: return inset + t if side == 0 else f.width(s) - inset - t
		var out_dir := -f.across(0.0) if side == 0 else f.across(0.0)
		# Body: top, inner face and the water end.
		for seg: Array in [[0.0, end_len, end_h], [end_len, end_s, h]]:
			var s0: float = seg[0]
			var s1: float = seg[1]
			var top_y: float = y + float(seg[2])
			wall.quad(f.at(s0, outer.call(s0), top_y), f.at(s1, outer.call(s1), top_y), f.at(s1, inner.call(s1), top_y), f.at(s0, inner.call(s0), top_y), Vector3.UP)
			wall.quad(f.at(s0, inner.call(s0), y), f.at(s1, inner.call(s1), y), f.at(s1, inner.call(s1), top_y), f.at(s0, inner.call(s0), top_y), -out_dir)
		# End block step down to the wall, plaza end face and water end face.
		wall.quad(f.at(end_len, outer.call(end_len), y + h), f.at(end_len, inner.call(end_len), y + h), f.at(end_len, inner.call(end_len), y + end_h), f.at(end_len, outer.call(end_len), y + end_h), f.along())
		wall.quad(f.at(0.0, outer.call(0.0), y), f.at(0.0, inner.call(0.0), y), f.at(0.0, inner.call(0.0), y + end_h), f.at(0.0, outer.call(0.0), y + end_h), -f.along())
		wall.quad(f.at(end_s, outer.call(end_s), y), f.at(end_s, inner.call(end_s), y), f.at(end_s, inner.call(end_s), y + h), f.at(end_s, outer.call(end_s), y + h), f.along())
		# Outer face; over the land the abutment face continues it down into the
		# ground (over the water the edge beam does).
		wall.quad(f.at(0.0, outer.call(0.0), y), f.at(end_s, outer.call(end_s), y), f.at(end_s, outer.call(end_s), y + h), f.at(0.0, outer.call(0.0), y + h), out_dir)
		ctx.bucket("solid", "edge_beam").quad(f.at(0.0, outer.call(0.0), y - abut), f.at(shore, outer.call(shore), y - abut), f.at(shore, outer.call(shore), y), f.at(0.0, outer.call(0.0), y), out_dir)
		# End block upper outer face above the wall height.
		wall.quad(f.at(0.0, outer.call(0.0), y + h), f.at(end_len, outer.call(end_len), y + h), f.at(end_len, outer.call(end_len), y + end_h), f.at(0.0, outer.call(0.0), y + end_h), out_dir)
		# Brass standpipe on the end block and its black sign plate.
		var mid: float = (outer.call(0.0) + inner.call(0.0)) * 0.5
		var brass := ctx.bucket("solid", "brass")
		_cylinder(brass, f.plan(end_len * 0.5, mid), 0.07, y + end_h, y + end_h + 0.32, 10, true, false)
		_box(ctx, brass, end_len * 0.5 - 0.17, end_len * 0.5 + 0.17, mid - 0.05, mid + 0.05, y + end_h + 0.16, y + end_h + 0.24, [])
		_box(ctx, ctx.bucket("solid", "plate"), -0.012, 0.0, mid - 0.09, mid + 0.09, y + end_h - 0.36, y + end_h - 0.14, ["s1"])


static func _column_stations(ctx: Ctx) -> Array[float]:
	var count := int(ctx.num("columns", "count", 10))
	var first := ctx.num("columns", "first", 3.2)
	var last := ctx.f.length - ctx.num("columns", "last_from_sw", 3.0)
	var stations: Array[float] = []
	for i in count:
		stations.append(first + (last - first) * float(i) / float(maxi(1, count - 1)))
	return stations


## Two rows of round white columns rising from the walls, with twin uplights on
## their inner faces. Sprayable.
static func _columns(ctx: Ctx) -> void:
	var f := ctx.f
	var y := ctx.deck_y
	var inset := ctx.num("deck", "inset", 0.4)
	var h := ctx.num("walls", "h", 0.55)
	var r := ctx.num("columns", "r", 0.2)
	var abut := ctx.num("deck", "abutment_depth", 2.2)
	var beam := ctx.num("deck", "edge_beam_depth", 0.85)
	var col := ctx.bucket("wall", "column")
	var lamp := ctx.bucket("solid", "lamp")
	var lamp_y := y + ctx.num("columns", "lamp_h", 2.55)
	var u := f.along()
	for station: float in _column_stations(ctx):
		var w := f.width(station)
		for side: int in [0, 1]:
			var t := ctx.num("walls", "nw_t" if side == 0 else "se_t", 0.55 if side == 0 else 0.5)
			var d := inset + t * 0.5 if side == 0 else w - inset - t * 0.5
			var top := _soffit_y(ctx, station, d) + 0.03
			# Columns run down inside the wall to their foundation: the abutment
			# over the land, the edge beam over the water. (The fit's walk-up ranks
			# the lowest wall faces first, so plaza approaches aim at the land pair.)
			var shore := ctx.shore_nw if side == 0 else ctx.shore_se
			var foot := y - (abut if station + r < shore else beam)
			_cylinder(col, f.plan(station, d), r, foot, top, 16, false, false)
			# Twin uplight heads on the walkway side of the column.
			var face := d + (r + 0.06 if side == 0 else -r - 0.06)
			for offset: float in [-0.09, 0.09]:
				_box(ctx, lamp, station + offset - 0.05, station + offset + 0.05, face - 0.07, face + 0.07, lamp_y, lamp_y + 0.16, [])
			var bracket := d + (r * 0.5 if side == 0 else -r * 0.5)
			_box(ctx, lamp, station - 0.14, station + 0.14, minf(bracket, face), maxf(bracket, face), lamp_y - 0.04, lamp_y, [])


## Frameless clear glass windscreen on the NW upstand, broken at the columns,
## with slim steel posts.
static func _windscreen(ctx: Ctx) -> void:
	var f := ctx.f
	var y := ctx.deck_y
	var inset := ctx.num("deck", "inset", 0.4)
	var h := ctx.num("walls", "h", 0.55)
	var nw_t := ctx.num("walls", "nw_t", 0.55)
	var r := ctx.num("columns", "r", 0.2)
	var top := y + ctx.num("glass", "top", 2.35)
	var d := inset + nw_t * 0.5
	var start := ctx.num("glass", "from", 1.6)
	var end_s := f.length - inset - 0.05
	var glass := ctx.bucket("solid", "glass")
	var post := ctx.bucket("solid", "steel")
	var breaks: Array[float] = [start]
	for station: float in _column_stations(ctx):
		breaks.append(station - r)
		breaks.append(station + r)
	breaks.append(end_s)
	for i in range(0, breaks.size() - 1, 2):
		var s0 := breaks[i]
		var s1 := breaks[i + 1]
		if s1 - s0 < 0.2:
			continue
		var panels := maxi(1, int(round((s1 - s0) / ctx.num("glass", "panel", 1.45))))
		for p in panels:
			var a := s0 + (s1 - s0) * float(p) / float(panels)
			var b := s0 + (s1 - s0) * float(p + 1) / float(panels)
			_box(ctx, glass, a + 0.006, b - 0.006, d - 0.012, d + 0.012, y + h, top, [])
			if p > 0:
				_box(ctx, post, a - 0.035, a + 0.035, d - 0.04, d + 0.04, y + h, top + 0.05, [])
		_box(ctx, post, s0, s0 + 0.06, d - 0.04, d + 0.04, y + h, top + 0.05, [])
		# Top cap rail and base shoe frame each run.
		_box(ctx, post, s0, s1, d - 0.035, d + 0.035, top, top + 0.05, [])
		_box(ctx, post, s0, s1, d - 0.04, d + 0.04, y + h, y + h + 0.07, ["bottom"])


## White picket rails: on the SE parapet (broken at the columns) and across the
## water end beyond the gate.
static func _rails(ctx: Ctx) -> void:
	var f := ctx.f
	var y := ctx.deck_y
	var inset := ctx.num("deck", "inset", 0.4)
	var h := ctx.num("walls", "h", 0.55)
	var se_t := ctx.num("walls", "se_t", 0.5)
	var nw_t := ctx.num("walls", "nw_t", 0.55)
	var r := ctx.num("columns", "r", 0.2)
	var rail_top := y + ctx.num("rail", "top", 1.07)
	var end_len := ctx.num("walls", "end_block_len", 0.65)
	var end_s := f.length - inset
	var b := ctx.bucket("solid", "rail")
	var breaks: Array[float] = [end_len]
	for station: float in _column_stations(ctx):
		breaks.append(station - r + 0.02)
		breaks.append(station + r - 0.02)
	breaks.append(end_s - 0.02)
	for i in range(0, breaks.size() - 1, 2):
		var s0 := breaks[i]
		var s1 := breaks[i + 1]
		var d := func(s: float) -> float: return f.width(s) - inset - se_t * 0.5
		_rail_run_along(ctx, b, s0, s1, d.call(s0), y + h, rail_top)
	# Across the water end: from the NW upstand to the SE parapet.
	var w := f.width(end_s)
	_rail_run_across(ctx, b, end_s - 0.06, inset + nw_t, w - inset - se_t, y, rail_top)


static func _rail_run_along(ctx: Ctx, b: Bucket, s0: float, s1: float, d: float, base_y: float, top_y: float) -> void:
	var spacing := ctx.num("rail", "picket_spacing", 0.115)
	_box(ctx, b, s0, s1, d - 0.035, d + 0.035, top_y - 0.05, top_y, [])
	_box(ctx, b, s0, s1, d - 0.02, d + 0.02, base_y + 0.06, base_y + 0.1, [])
	var count := maxi(1, int(floor((s1 - s0) / spacing)))
	for i in count + 1:
		var s := s0 + (s1 - s0) * float(i) / float(count)
		_box(ctx, b, s - 0.0125, s + 0.0125, d - 0.0125, d + 0.0125, base_y, top_y - 0.05, ["top", "bottom"])


static func _rail_run_across(ctx: Ctx, b: Bucket, s: float, d0: float, d1: float, base_y: float, top_y: float) -> void:
	var spacing := ctx.num("rail", "picket_spacing", 0.115)
	_box(ctx, b, s - 0.035, s + 0.035, d0, d1, top_y - 0.05, top_y, [])
	_box(ctx, b, s - 0.02, s + 0.02, d0, d1, base_y + 0.06, base_y + 0.1, [])
	var count := maxi(1, int(floor((d1 - d0) / spacing)))
	for i in count + 1:
		var d := d0 + (d1 - d0) * float(i) / float(count)
		_box(ctx, b, s - 0.0125, s + 0.0125, d - 0.0125, d + 0.0125, base_y, top_y - 0.05, ["top", "bottom"])


## Glazed gate across the walkway near the water end: light portal frame
## (sprayable), dark-framed glass doors, the red-orange LED destination sign in
## the head, a red circular sign and an information stand.
static func _gate(ctx: Ctx) -> void:
	var f := ctx.f
	var y := ctx.deck_y
	var inset := ctx.num("deck", "inset", 0.4)
	var nw_t := ctx.num("walls", "nw_t", 0.55)
	var se_t := ctx.num("walls", "se_t", 0.5)
	var s := f.length - ctx.num("gate", "from_sw", 2.6)
	var w := f.width(s)
	var d0 := inset + nw_t
	var d1 := w - inset - se_t
	var head_y := y + ctx.num("gate", "head", 2.4)
	var head_top := y + ctx.num("gate", "head_top", 2.9)
	var frame := ctx.bucket("wall", "gate_frame")
	var depth := 0.18
	# Portal: two posts and the head box.
	_box(ctx, frame, s - depth, s + depth, d0, d0 + 0.16, y, head_top, ["bottom"])
	_box(ctx, frame, s - depth, s + depth, d1 - 0.16, d1, y, head_top, ["bottom"])
	_box(ctx, frame, s - depth, s + depth, d0 + 0.16, d1 - 0.16, head_y, head_top, [])
	# LED sign on the plaza face of the head: dark panel and lit segments.
	var mid := (d0 + d1) * 0.5
	var sign_w := ctx.num("gate", "sign_w", 1.7)
	var sign_h := ctx.num("gate", "sign_h", 0.34)
	_box(ctx, ctx.bucket("solid", "sign_panel"), s - depth - 0.03, s - depth, mid - sign_w * 0.5, mid + sign_w * 0.5, head_y + 0.06, head_y + 0.12 + sign_h, ["s1"])
	var led := ctx.bucket("solid", "led")
	var pattern := [0.1, 0.06, 0.12, 0.05, 0.08, 0.1, 0.04, 0.12, 0.07, 0.09, 0.05, 0.11, 0.08, 0.06]
	var cursor := mid - sign_w * 0.5 + 0.1
	var k := 0
	while cursor + float(pattern[k % pattern.size()]) <= mid + sign_w * 0.5 - 0.1:
		var seg: float = pattern[k % pattern.size()]
		_box(ctx, led, s - depth - 0.04, s - depth - 0.03, cursor, cursor + seg, head_y + 0.12, head_y + 0.06 + sign_h, ["s1"])
		cursor += seg + 0.035
		k += 1
	# Doors and side lights: dark frames with glass between (the barrier).
	var door := ctx.bucket("solid", "door_frame")
	var glass := ctx.bucket("solid", "gate_glass")
	var mullions: Array[float] = [d0 + 0.16, mid - 1.0, mid, mid + 1.0, d1 - 0.16]
	for m: float in mullions:
		_box(ctx, door, s - 0.04, s + 0.04, m - 0.035, m + 0.035, y, head_y, ["bottom"])
	for i in mullions.size() - 1:
		_box(ctx, glass, s - 0.01, s + 0.01, mullions[i] + 0.035, mullions[i + 1] - 0.035, y + 0.02, head_y, [])
	_box(ctx, door, s - 0.04, s + 0.04, d0 + 0.16, d1 - 0.16, y, y + 0.1, ["bottom"])
	_box(ctx, door, s - 0.04, s + 0.04, d0 + 0.16, d1 - 0.16, head_y - 0.06, head_y, [])
	# Red circular sign on the door glass, plaza side.
	var red := ctx.bucket("solid", "sign_red")
	var u := f.along()
	var sign_center := f.plan(s - 0.05, mid - 0.5)
	for i in 12:
		var a0 := TAU * float(i) / 12.0
		var a1 := TAU * float(i + 1) / 12.0
		var c := f.across(s)
		var pa := Vector3(sign_center.x, y + 1.55, sign_center.y)
		var p0 := pa + c * cos(a0) * 0.16 + Vector3.UP * sin(a0) * 0.16
		var p1 := pa + c * cos(a1) * 0.16 + Vector3.UP * sin(a1) * 0.16
		red.tri(pa, p0, p1, -u)
	# Information stand on two legs before the gate, SE side.
	var stand := ctx.bucket("solid", "stand")
	var ss := s - ctx.num("gate", "stand_before", 1.1)
	var sd := d1 - 0.55
	_box(ctx, stand, ss - 0.05, ss + 0.05, sd - 0.35, sd + 0.35, y + 0.45, y + 1.75, [])
	_box(ctx, ctx.bucket("solid", "stand_screen"), ss - 0.06, ss - 0.05, sd - 0.29, sd + 0.29, y + 0.55, y + 1.65, ["s1"])
	for leg: float in [sd - 0.28, sd + 0.28]:
		_box(ctx, stand, ss - 0.03, ss + 0.03, leg - 0.03, leg + 0.03, y, y + 0.45, ["bottom"])


## Soffit height under the canopy at (s, d): lower on the NW (wind) side, with the
## SE edge rising toward the plaza tip.
static func _soffit_y(ctx: Ctx, s: float, d: float) -> float:
	var y := ctx.deck_y
	var inset := ctx.num("roof", "fascia_inset", 0.35)
	var w := ctx.f.width(s)
	var nw := y + ctx.num("roof", "soffit_nw", 3.45)
	var se := y + ctx.num("roof", "soffit_se", 3.75) + _prow(ctx, s)
	var t := clampf((d - inset) / maxf(0.01, w - 2.0 * inset), 0.0, 1.0)
	return lerpf(nw, se, t)


static func _prow(ctx: Ctx, s: float) -> float:
	var reach := ctx.num("roof", "prow_length", 12.0)
	return ctx.num("roof", "prow_rise", 0.6) * clampf(1.0 - s / reach, 0.0, 1.0)


## Thin canopy: top (roof role), tapered folded fascias sloping in to the soffit,
## and a lengthwise ribbed white soffit.
static func _roof(ctx: Ctx) -> void:
	var f := ctx.f
	var L := f.length
	var fi := ctx.num("roof", "fascia_inset", 0.35)
	var depth := ctx.num("roof", "fascia_depth", 0.42)
	var band := ctx.num("roof", "fascia_band", 0.25)
	var reach := ctx.num("roof", "prow_length", 12.0)
	var stations: Array[float] = [0.0, fi]
	var step := reach / 4.0
	var s := step
	while s < reach - 0.01:
		stations.append(s)
		s += step
	stations.append(reach)
	stations.append(L * 0.5)
	stations.append(L - fi)
	stations.append(L)
	var top := ctx.bucket("roof", "roof_top")
	var fascia := ctx.bucket("solid", "fascia")
	var soffit := ctx.bucket("solid", "soffit")
	var ribs := ctx.bucket("solid", "rib")
	var top_at := func(st: float, d: float) -> Vector3:
		var w := f.width(st)
		var clamped := clampf(st, fi, L - fi)
		var edge := _soffit_y(ctx, clamped, fi) + depth
		var edge_se := _soffit_y(ctx, clamped, w - fi) + depth
		return f.at(st, d, lerpf(edge, edge_se, d / w))
	var under_at := func(st: float, d: float) -> Vector3:
		var cs := clampf(st, fi, L - fi)
		var cd := clampf(d, fi, f.width(cs) - fi)
		return f.at(cs, cd, _soffit_y(ctx, cs, cd))
	for i in stations.size() - 1:
		var s0 := stations[i]
		var s1 := stations[i + 1]
		var w0 := f.width(s0)
		var w1 := f.width(s1)
		top.quad(top_at.call(s0, 0.0), top_at.call(s1, 0.0), top_at.call(s1, w1), top_at.call(s0, w0), Vector3.UP)
		# Side fascias: a vertical white band at the plate edge, then folded in
		# down to the soffit edge.
		var drop := Vector3.DOWN * band
		fascia.quad(top_at.call(s0, 0.0), top_at.call(s1, 0.0), top_at.call(s1, 0.0) + drop, top_at.call(s0, 0.0) + drop, -f.across(s0))
		fascia.quad(top_at.call(s0, w0), top_at.call(s1, w1), top_at.call(s1, w1) + drop, top_at.call(s0, w0) + drop, f.across(s0))
		fascia.quad(top_at.call(s0, 0.0) + drop, top_at.call(s1, 0.0) + drop, under_at.call(s1, 0.0), under_at.call(s0, 0.0), -f.across(s0) + Vector3.DOWN * 0.8)
		fascia.quad(top_at.call(s0, w0) + drop, top_at.call(s1, w1) + drop, under_at.call(s1, w1), under_at.call(s0, w0), f.across(s0) + Vector3.DOWN * 0.8)
		if s1 <= fi + 0.001 or s0 >= L - fi - 0.001:
			continue
		# Soffit in lengthwise strips between ribs.
		var ss0 := maxf(s0, fi)
		var ss1 := minf(s1, L - fi)
		var spacing := ctx.num("roof", "rib_spacing", 0.3)
		var wa := f.width(ss0)
		var wb := f.width(ss1)
		var strips := maxi(1, int(round((minf(wa, wb) - 2.0 * fi) / spacing)))
		for k in strips:
			var ta := float(k) / float(strips)
			var tb := float(k + 1) / float(strips)
			var da0 := lerpf(fi, wa - fi, ta)
			var da1 := lerpf(fi, wa - fi, tb)
			var db0 := lerpf(fi, wb - fi, ta)
			var db1 := lerpf(fi, wb - fi, tb)
			soffit.quad(under_at.call(ss0, da0), under_at.call(ss1, db0), under_at.call(ss1, db1), under_at.call(ss0, da1), Vector3.DOWN)
			if k == 0:
				continue
			# Rib: a slim downward fin on the strip line.
			var rib_h := 0.018
			var pa := under_at.call(ss0, da0) as Vector3
			var pb := under_at.call(ss1, db0) as Vector3
			var half := f.across(ss0) * 0.01
			ribs.quad(pa - half, pb - half, pb - half + Vector3.DOWN * rib_h, pa - half + Vector3.DOWN * rib_h, -f.across(ss0))
			ribs.quad(pa + half, pb + half, pb + half + Vector3.DOWN * rib_h, pa + half + Vector3.DOWN * rib_h, f.across(ss0))
			ribs.quad(pa - half + Vector3.DOWN * rib_h, pb - half + Vector3.DOWN * rib_h, pb + half + Vector3.DOWN * rib_h, pa + half + Vector3.DOWN * rib_h, Vector3.DOWN)
	# End fascias at the plaza and water ends.
	for end: Array in [[0.0, fi, -1.0], [L, L - fi, 1.0]]:
		var se: float = end[0]
		var si: float = end[1]
		var dir: float = end[2]
		var we := f.width(se)
		var steps := 6
		for k in steps:
			var ta := float(k) / float(steps)
			var tb := float(k + 1) / float(steps)
			var down := Vector3.DOWN * band
			fascia.quad(top_at.call(se, we * ta), top_at.call(se, we * tb), top_at.call(se, we * tb) + down, top_at.call(se, we * ta) + down, f.along() * dir)
			fascia.quad(top_at.call(se, we * ta) + down, top_at.call(se, we * tb) + down, under_at.call(si, we * tb), under_at.call(si, we * ta), f.along() * dir + Vector3.DOWN * 0.8)


# ------------------------------------------------------------------ output

static func _make_materials(ctx: Ctx) -> void:
	var palette: Variant = ctx.cfg.get("palette", {})
	if not palette is Dictionary:
		ctx.errors.append("palette must be an object")
		return
	for key: String in palette:
		var entry: Dictionary = palette[key]
		var rgb: Array = entry.get("rgb", [])
		if rgb.size() != 3:
			ctx.errors.append("palette %s needs rgb" % key)
			return
		var emission: Array = entry.get("emission", [])
		var cache_key := "%s|%s|%s|%s|%s|%s|%s|%s|%s" % [key, rgb[0], rgb[1], rgb[2], entry.get("alpha", 1.0), entry.get("roughness", 0.9), entry.get("metallic", 0.0), emission, entry.get("emission_energy", 1.0)]
		if not _material_cache.has(cache_key):
			var material := StandardMaterial3D.new()
			material.resource_name = "Pier_" + key
			material.albedo_color = Color(float(rgb[0]), float(rgb[1]), float(rgb[2]), float(entry.get("alpha", 1.0)))
			material.roughness = float(entry.get("roughness", 0.9))
			material.metallic = float(entry.get("metallic", 0.0))
			if float(entry.get("alpha", 1.0)) < 1.0:
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				material.cull_mode = BaseMaterial3D.CULL_DISABLED
			if emission.size() == 3:
				material.emission_enabled = true
				material.emission = Color(float(emission[0]), float(emission[1]), float(emission[2]))
				material.emission_energy_multiplier = float(entry.get("emission_energy", 1.0))
			_material_cache[cache_key] = material
		ctx.materials[key] = _material_cache[cache_key]


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
		for v: Vector3 in bucket.vertices:
			if not v.is_finite():
				ctx.errors.append("non-finite vertex in " + key)
				return 0
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = bucket.vertices
		arrays[Mesh.ARRAY_NORMAL] = bucket.normals
		arrays[Mesh.ARRAY_TEX_UV] = bucket.uvs
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(0, ctx.materials[mat])
		var node := MeshInstance3D.new()
		node.name = "Pier_%s_%s" % [role, mat]
		node.mesh = mesh
		node.set_meta("family_role", role)
		if (ctx.materials[mat] as StandardMaterial3D).transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(node)
		triangles += int(bucket.vertices.size() / 3.0)
	return triangles
