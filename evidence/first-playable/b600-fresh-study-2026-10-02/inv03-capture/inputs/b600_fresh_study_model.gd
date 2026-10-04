extends Node3D
## Building 600 (SFFD Treasure Island Training Facility, OSM w34313548) fresh
## isolated whole-building study. Owner-directed new base; no shared-family reuse.
##
## Footprint-local frame (derived from the exact generated roof record):
##   +X = "a": long axis from the OSM south corner (v0) toward the north end,
##   +Z = "b": across from the west (Avenue M) face to the east (yard) face,
##   Y  = world elevation (metres).
## Everything stays inside 0 <= a <= L, 0 <= b <= W. Unmeasured dimensions,
## cadence and hidden sides are production_inference, never as-built claims.

const SOURCE_KEY := "w34313548"
const WALL_KEY := "building:w34313548:wall"
const ROOF_KEY := "building:w34313548:roof"
const TEX_ROOT := "res://game/resources/textures/world/polyhaven/"
const WALL_BOTTOM_Y := 3.40
const ROLES := ["wall", "roof", "detail", "visual"]

# Heights above the flat source base B (inference from r07/r08/r10/r15 ratios).
const H_PARAPET := 5.50
const H_ROOF := 4.95
const H_FRAME_TOP := 5.80
const H_DECK := 4.55
const H_SPRING := 2.35
const H_CROWN := 4.15
const H_PLINTH := 0.55
const H_BAND_LO := 2.55
const H_BAND_HI := 3.65
const H_WALK_TOP := 3.65
const H_WALK_SOFFIT := 2.85
const H_SILL := 1.00
const H_HEAD := 2.75
const H_HIGH_LO := 3.85
const H_HIGH_HI := 4.55

# Plan positions (metres in the local frame).
const WEST_FACE_B := 0.35
const FRAME_FRONT_B := 0.04
const FRAME_BACK_B := 0.64
const A_FRAME0 := 2.0
const A_OPEN0 := 4.45
const A_OPEN1 := 12.85
const A_FRAME1 := 15.30
const EAST_WALL_B := 12.95
const PORCH_A := 100.0
const PORCH_B := 1.90
const PARAPET_T := 0.25
const SOUTH_A := 0.10
const BAY_COUNT := 14

var L := 0.0
var W := 0.0
var B := 0.0
var origin_world := Vector3.ZERO
var axis_a := Vector3.ZERO
var axis_b := Vector3.ZERO
var _land: Array = []
var _surfs: Dictionary = {}
var _materials: Dictionary = {}
var _textures: Dictionary = {}
var _font: FontVariation
var ground_contacts: Array = []
var letters: Array = []


class Surf:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var uv := PackedVector2Array()
	var t := PackedFloat32Array()
	var idx := PackedInt32Array()

	static func frame_for(nn: Vector3) -> Array:
		var hint := Vector3.UP if absf(nn.y) < 0.7 else Vector3(0, 0, 1)
		var tu := hint.cross(nn).normalized()
		var tv := nn.cross(tu).normalized()
		return [tu, tv]

	func _push(p: Vector3, nn: Vector3, tu: Vector3, tv: Vector3) -> void:
		v.append(p)
		n.append(nn)
		uv.append(Vector2(p.dot(tu), -p.dot(tv)))
		t.append(tu.x)
		t.append(tu.y)
		t.append(tu.z)
		t.append(-1.0 if nn.cross(tu).dot(-tv) < 0.0 else 1.0)

	func tri(a: Vector3, b: Vector3, c: Vector3, nn: Vector3) -> void:
		if (b - a).cross(c - a).length_squared() < 1e-12:
			return
		var fr := frame_for(nn)
		var base := v.size()
		_push(a, nn, fr[0], fr[1])
		_push(b, nn, fr[0], fr[1])
		_push(c, nn, fr[0], fr[1])
		# Godot front faces are clockwise: (b-a)x(c-a) must point away from nn.
		if (b - a).cross(c - a).dot(nn) > 0.0:
			idx.append_array(PackedInt32Array([base, base + 2, base + 1]))
		else:
			idx.append_array(PackedInt32Array([base, base + 1, base + 2]))

	func quad(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, nn: Vector3) -> void:
		if (p1 - p0).cross(p2 - p0).length_squared() < 1e-12 and (p2 - p0).cross(p3 - p0).length_squared() < 1e-12:
			return
		var fr := frame_for(nn)
		var base := v.size()
		for p: Vector3 in [p0, p1, p2, p3]:
			_push(p, nn, fr[0], fr[1])
		if (p1 - p0).cross(p2 - p0).dot(nn) > 0.0 or (p2 - p0).cross(p3 - p0).dot(nn) > 0.0:
			idx.append_array(PackedInt32Array([base, base + 2, base + 1, base, base + 3, base + 2]))
		else:
			idx.append_array(PackedInt32Array([base, base + 1, base + 2, base, base + 2, base + 3]))


## Builds the study from the exact generated roof record plus the chunk land
## record used only to seat ground-contacting details on actual local terrain.
func build(roof_record: Dictionary, land_record: Dictionary) -> Dictionary:
	name = "B600FreshStudy"
	if str(roof_record.get("object_key", "")) != ROOF_KEY or roof_record.get("source_keys", []) != [SOURCE_KEY]:
		return {"ok": false, "message": "Exact w34313548 roof record required"}
	var pts: Array[Vector3] = []
	var rv: Array = roof_record.vertices
	for i in range(0, rv.size(), 3):
		pts.append(Vector3(float(rv[i]), float(rv[i + 1]), float(rv[i + 2])))
	if pts.size() != 4:
		return {"ok": false, "message": "Rectangular four-vertex roof expected"}
	var south := pts[0]
	var west := pts[0]
	var east := pts[0]
	var north := pts[0]
	for p in pts:
		if p.z > south.z: south = p
		if p.x < west.x: west = p
		if p.x > east.x: east = p
		if p.z < north.z: north = p
	var along := Vector3(west.x - south.x, 0, west.z - south.z)
	var across := Vector3(east.x - south.x, 0, east.z - south.z)
	L = along.length()
	W = across.length()
	axis_a = along.normalized()
	axis_b = axis_a.cross(Vector3.UP).normalized()
	var predicted_north := south + axis_a * L + axis_b * W
	if absf(axis_b.dot(across.normalized()) - 1.0) > 0.0005 or Vector2(predicted_north.x - north.x, predicted_north.z - north.z).length() > 0.02:
		return {"ok": false, "message": "Footprint is not the expected rectangle/orientation"}
	B = float(roof_record.flat_base_elevation_m)
	origin_world = Vector3(south.x, 0.0, south.z)
	transform = Transform3D(Basis(axis_a, Vector3.UP, axis_b), origin_world)
	_prepare_land(land_record)
	_font = FontVariation.new()
	_font.base_font = ThemeDB.fallback_font
	# No embolden: emboldened outlines self-intersect and fail TextMesh triangulation.
	_font.variation_embolden = 0.0
	for role in ROLES:
		_surfs[role] = {}
	_build_south_block()
	_build_portal_frame(true)
	_build_portal_frame(false)
	_build_passage()
	_build_main_bar()
	_build_walkway()
	_build_roofs()
	_build_lettering()
	_commit()
	set_meta("source_keys", [SOURCE_KEY])
	set_meta("derived_object_key", WALL_KEY)
	set_meta("footprint_l_m", L)
	set_meta("footprint_w_m", W)
	set_meta("base_y_m", B)
	return {"ok": true, "L": L, "W": W, "B": B, "origin": [origin_world.x, origin_world.z], "axis_a": [axis_a.x, axis_a.z], "axis_b": [axis_b.x, axis_b.z]}


func local_to_world(p: Vector3) -> Vector3:
	return origin_world + axis_a * p.x + Vector3.UP * p.y + axis_b * p.z


func land_y(a: float, b: float) -> float:
	var w := local_to_world(Vector3(a, 0, b))
	for tri: Array in _land:
		var p1: Vector3 = tri[0]
		var p2: Vector3 = tri[1]
		var p3: Vector3 = tri[2]
		var d := (p2.z - p3.z) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.z - p3.z)
		if absf(d) < 1e-12:
			continue
		var l1 := ((p2.z - p3.z) * (w.x - p3.x) + (p3.x - p2.x) * (w.z - p3.z)) / d
		var l2 := ((p3.z - p1.z) * (w.x - p3.x) + (p1.x - p3.x) * (w.z - p3.z)) / d
		var l3 := 1.0 - l1 - l2
		if l1 >= -1e-9 and l2 >= -1e-9 and l3 >= -1e-9:
			return l1 * p1.y + l2 * p2.y + l3 * p3.y
	return NAN


func _prepare_land(record: Dictionary) -> void:
	var v: Array = record.vertices
	var ids: Array = record.indices
	for i in range(0, ids.size(), 3):
		var tri: Array = []
		for k in 3:
			var j := int(ids[i + k]) * 3
			tri.append(Vector3(float(v[j]), float(v[j + 1]), float(v[j + 2])))
		_land.append(tri)


# ---------------------------------------------------------------- primitives

func _s(role: String, mat: String) -> Surf:
	var group: Dictionary = _surfs[role]
	if not group.has(mat):
		group[mat] = Surf.new()
	return group[mat]


func _quad(role: String, mat: String, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, nn: Vector3) -> void:
	_s(role, mat).quad(p0, p1, p2, p3, nn)


## Oriented box. Skip bits: 1:-ax 2:+ax 4:-ay 8:+ay 16:-az 32:+az.
func _box(role: String, mat: String, c: Vector3, ax: Vector3, ay: Vector3, az: Vector3, h: Vector3, skip: int = 0) -> void:
	var axes := [ax, ay, az]
	var halves := [h.x, h.y, h.z]
	for k in 3:
		for sgn in [-1.0, 1.0]:
			var bit := 1 << (k * 2 + (1 if sgn > 0.0 else 0))
			if skip & bit:
				continue
			var nn: Vector3 = axes[k] * sgn
			var u: Vector3 = axes[(k + 1) % 3] * halves[(k + 1) % 3]
			var w: Vector3 = axes[(k + 2) % 3] * halves[(k + 2) % 3]
			var fc: Vector3 = c + nn * halves[k]
			_quad(role, mat, fc - u - w, fc + u - w, fc + u + w, fc - u + w, nn)


func _abox(role: String, mat: String, mn: Vector3, mx: Vector3, skip: int = 0) -> void:
	_box(role, mat, (mn + mx) * 0.5, Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1), (mx - mn) * 0.5, skip)


func _cyl(role: String, mat: String, base: Vector3, axis: Vector3, radius: float, height: float, sides: int, cap_top := true) -> void:
	var ax := axis.normalized()
	var ref := Vector3(1, 0, 0) if absf(ax.x) < 0.9 else Vector3(0, 0, 1)
	var e1 := ax.cross(ref).normalized()
	var e2 := ax.cross(e1).normalized()
	var top := base + ax * height
	for i in sides:
		var t0 := TAU * float(i) / sides
		var t1 := TAU * float(i + 1) / sides
		var d0 := e1 * cos(t0) + e2 * sin(t0)
		var d1 := e1 * cos(t1) + e2 * sin(t1)
		var mid := (d0 + d1).normalized()
		_quad(role, mat, base + d0 * radius, base + d1 * radius, top + d1 * radius, top + d0 * radius, mid)
		if cap_top:
			_s(role, mat).tri(top, top + d0 * radius, top + d1 * radius, ax)


## Planar wall face with rectangular holes. Points = origin + sdir*s + UP*y.
func _wall(role: String, mat: String, origin: Vector3, sdir: Vector3, nn: Vector3, s0: float, s1: float, y0: float, y1: float, holes: Array) -> void:
	var ys: Array = [y0, y1]
	for h: Rect2 in holes:
		for yy: float in [h.position.y, h.end.y]:
			if yy > y0 and yy < y1 and not ys.has(yy):
				ys.append(yy)
	ys.sort()
	for k in ys.size() - 1:
		var ya: float = ys[k]
		var yb: float = ys[k + 1]
		if yb - ya < 0.0005:
			continue
		var cuts: Array = []
		for h: Rect2 in holes:
			if h.position.y <= ya + 0.0001 and h.end.y >= yb - 0.0001 and h.end.x > s0 and h.position.x < s1:
				cuts.append(Vector2(maxf(h.position.x, s0), minf(h.end.x, s1)))
		cuts.sort_custom(func(p: Vector2, q: Vector2) -> bool: return p.x < q.x)
		var cur := s0
		for c: Vector2 in cuts:
			if c.x > cur + 0.0005:
				_wall_quad(role, mat, origin, sdir, nn, cur, c.x, ya, yb)
			cur = maxf(cur, c.y)
		if s1 > cur + 0.0005:
			_wall_quad(role, mat, origin, sdir, nn, cur, s1, ya, yb)


func _wall_quad(role: String, mat: String, origin: Vector3, sdir: Vector3, nn: Vector3, sa: float, sb: float, ya: float, yb: float) -> void:
	_quad(role, mat, origin + sdir * sa + Vector3.UP * ya, origin + sdir * sb + Vector3.UP * ya, origin + sdir * sb + Vector3.UP * yb, origin + sdir * sa + Vector3.UP * yb, nn)


func _wp(origin: Vector3, sdir: Vector3, nn: Vector3, s: float, y: float, d: float) -> Vector3:
	return origin + sdir * s + Vector3.UP * y - nn * d


## Box in wall coordinates: s along the face, y up, d = depth into the wall.
func _wbox(role: String, mat: String, origin: Vector3, sdir: Vector3, nn: Vector3, sa: float, sb: float, ya: float, yb: float, da: float, db: float, skip: int = 32) -> void:
	var c := _wp(origin, sdir, nn, (sa + sb) * 0.5, (ya + yb) * 0.5, (da + db) * 0.5)
	_box(role, mat, c, sdir, Vector3.UP, -nn, Vector3((sb - sa) * 0.5, (yb - ya) * 0.5, (db - da) * 0.5), skip)


func _reveals(mat: String, origin: Vector3, sdir: Vector3, nn: Vector3, r: Rect2, depth: float, with_sill: bool) -> void:
	var s0 := r.position.x
	var s1 := r.end.x
	var y0 := r.position.y
	var y1 := r.end.y
	_quad("wall", mat, _wp(origin, sdir, nn, s0, y0, 0), _wp(origin, sdir, nn, s0, y1, 0), _wp(origin, sdir, nn, s0, y1, depth), _wp(origin, sdir, nn, s0, y0, depth), sdir)
	_quad("wall", mat, _wp(origin, sdir, nn, s1, y0, 0), _wp(origin, sdir, nn, s1, y1, 0), _wp(origin, sdir, nn, s1, y1, depth), _wp(origin, sdir, nn, s1, y0, depth), -sdir)
	_quad("wall", mat, _wp(origin, sdir, nn, s0, y1, 0), _wp(origin, sdir, nn, s1, y1, 0), _wp(origin, sdir, nn, s1, y1, depth), _wp(origin, sdir, nn, s0, y1, depth), Vector3.DOWN)
	if with_sill:
		_quad("wall", mat, _wp(origin, sdir, nn, s0, y0, 0), _wp(origin, sdir, nn, s1, y0, 0), _wp(origin, sdir, nn, s1, y0, depth), _wp(origin, sdir, nn, s0, y0, depth), Vector3.UP)


## Multi-light window: recessed glass with blue-grey frame, mullions and transom.
func _window(wall_mat: String, origin: Vector3, sdir: Vector3, nn: Vector3, r: Rect2, columns: int, transom_from_top: float, depth := 0.22, sill := true) -> void:
	_reveals(wall_mat, origin, sdir, nn, r, depth, true)
	var s0 := r.position.x
	var s1 := r.end.x
	var y0 := r.position.y
	var y1 := r.end.y
	_quad("detail", "glass", _wp(origin, sdir, nn, s0, y0, depth), _wp(origin, sdir, nn, s1, y0, depth), _wp(origin, sdir, nn, s1, y1, depth), _wp(origin, sdir, nn, s0, y1, depth), nn)
	var fw := 0.07
	var fd := depth - 0.07
	_wbox("detail", "frame", origin, sdir, nn, s0, s0 + fw, y0, y1, fd, depth)
	_wbox("detail", "frame", origin, sdir, nn, s1 - fw, s1, y0, y1, fd, depth)
	_wbox("detail", "frame", origin, sdir, nn, s0 + fw, s1 - fw, y0, y0 + fw, fd, depth)
	_wbox("detail", "frame", origin, sdir, nn, s0 + fw, s1 - fw, y1 - fw, y1, fd, depth)
	for c in range(1, columns):
		var sc := s0 + (s1 - s0) * float(c) / columns
		_wbox("detail", "frame", origin, sdir, nn, sc - 0.03, sc + 0.03, y0 + fw, y1 - fw, fd + 0.01, depth)
	if transom_from_top > 0.0:
		var yt := y1 - transom_from_top
		_wbox("detail", "frame", origin, sdir, nn, s0 + fw, s1 - fw, yt - 0.03, yt + 0.03, fd + 0.01, depth)
	if sill:
		_wbox("detail", "sill", origin, sdir, nn, s0 - 0.08, s1 + 0.08, y0 - 0.07, y0, -0.06, 0.0)


func _door(wall_mat: String, door_mat: String, origin: Vector3, sdir: Vector3, nn: Vector3, r: Rect2, depth := 0.14) -> void:
	_reveals(wall_mat, origin, sdir, nn, r, depth, false)
	var s0 := r.position.x
	var s1 := r.end.x
	var y0 := r.position.y
	var y1 := r.end.y
	_quad("detail", door_mat, _wp(origin, sdir, nn, s0, y0, depth), _wp(origin, sdir, nn, s1, y0, depth), _wp(origin, sdir, nn, s1, y1, depth), _wp(origin, sdir, nn, s0, y1, depth), nn)
	var fd := depth - 0.05
	_wbox("detail", "frame", origin, sdir, nn, s0, s0 + 0.06, y0, y1, fd, depth)
	_wbox("detail", "frame", origin, sdir, nn, s1 - 0.06, s1, y0, y1, fd, depth)
	_wbox("detail", "frame", origin, sdir, nn, s0 + 0.06, s1 - 0.06, y1 - 0.06, y1, fd, depth)
	# Small vision light and lever keep the leaf legible as a door.
	var vs := (s0 + s1) * 0.5
	_wbox("detail", "glass", origin, sdir, nn, vs - 0.12, vs + 0.12, y0 + 1.30, y0 + 1.85, depth - 0.012, depth)
	_wbox("detail", "frame", origin, sdir, nn, s1 - 0.20, s1 - 0.10, y0 + 0.98, y0 + 1.02, depth - 0.05, depth)


# ---------------------------------------------------------------- massing

func _build_south_block() -> void:
	var west_o := Vector3(0, 0, WEST_FACE_B)
	_wall("wall", "maroon", west_o, Vector3(1, 0, 0), Vector3(0, 0, -1), SOUTH_A, A_FRAME0, WALL_BOTTOM_Y, B + H_PARAPET, [])
	var east_o := Vector3(0, 0, W - 0.356)
	_wall("wall", "cream_base", east_o, Vector3(1, 0, 0), Vector3(0, 0, 1), SOUTH_A, A_FRAME0, WALL_BOTTOM_Y, B + H_PLINTH, [])
	_wall("wall", "cream", east_o, Vector3(1, 0, 0), Vector3(0, 0, 1), SOUTH_A, A_FRAME0, B + H_PLINTH, B + H_PARAPET, [])
	# South end: one personnel door and two windows (inference; r14 is tree-occluded).
	var so := Vector3(SOUTH_A, 0, 0)
	var sdir := Vector3(0, 0, 1)
	var sn := Vector3(-1, 0, 0)
	var door_g := land_y(SOUTH_A, 3.5)
	var door := Rect2(3.0, door_g + 0.02, 1.0, 2.15)
	var w1 := Rect2(7.4, B + H_SILL, 1.4, 1.35)
	var w2 := Rect2(11.4, B + H_SILL, 1.4, 1.35)
	var holes := [door, w1, w2]
	_wall("wall", "cream_base", so, sdir, sn, WEST_FACE_B, W - 0.356, WALL_BOTTOM_Y, B + H_PLINTH, holes)
	_wall("wall", "cream", so, sdir, sn, WEST_FACE_B, W - 0.356, B + H_PLINTH, B + H_PARAPET, holes)
	_door("cream", "door", so, sdir, sn, door)
	_window("cream", so, sdir, sn, w1, 2, 0.45)
	_window("cream", so, sdir, sn, w2, 2, 0.45)
	ground_contacts.append({"id": "south-door", "a": SOUTH_A, "b": 3.5, "bottom_y": door.position.y, "land_y": door_g})
	# North wall of the south block, exposed under/above the walkway.
	var no := Vector3(A_FRAME1, 0, 0)
	_wall("wall", "cream", no, Vector3(0, 0, 1), Vector3(1, 0, 0), EAST_WALL_B, W - 0.656, WALL_BOTTOM_Y, B + H_PARAPET, [])


## Square maroon portal frame with a segmental arch (west), cream twin (east).
func _build_portal_frame(west: bool) -> void:
	var mat := "maroon" if west else "cream"
	var front := FRAME_FRONT_B if west else W - 0.056
	var back := FRAME_BACK_B if west else W - 0.656
	var out := Vector3(0, 0, -1) if west else Vector3(0, 0, 1)
	var top := B + H_FRAME_TOP
	var arch := _arch_points(24)
	var spring := B + H_SPRING
	var roof_y := B + H_ROOF
	var deck_y := B + H_DECK
	# Front face: piers plus strips above the arch.
	for pair: Array in [[A_FRAME0, A_OPEN0], [A_OPEN1, A_FRAME1]]:
		var s0: float = pair[0]
		var s1: float = pair[1]
		_quad("wall", mat, Vector3(s0, WALL_BOTTOM_Y, front), Vector3(s1, WALL_BOTTOM_Y, front), Vector3(s1, top, front), Vector3(s0, top, front), out)
	for i in arch.size() - 1:
		var p: Vector2 = arch[i]
		var q: Vector2 = arch[i + 1]
		_quad("wall", mat, Vector3(p.x, p.y, front), Vector3(q.x, q.y, front), Vector3(q.x, top, front), Vector3(p.x, top, front), out)
		# Back face toward the passage, up to the deck.
		_quad("wall", mat, Vector3(p.x, p.y, back), Vector3(q.x, q.y, back), Vector3(q.x, deck_y, back), Vector3(p.x, deck_y, back), -out)
		# Soffit through the frame depth, facing the arch centre.
		var mid := (p + q) * 0.5
		var centre := Vector2((A_OPEN0 + A_OPEN1) * 0.5, B + H_CROWN - _arch_radius())
		var inward := (centre - mid).normalized()
		_quad("wall", mat, Vector3(p.x, p.y, front), Vector3(q.x, q.y, front), Vector3(q.x, q.y, back), Vector3(p.x, p.y, back), Vector3(inward.x, inward.y, 0))
	# Back face above the roof (visible from the roof) across the full frame.
	_quad("wall", mat, Vector3(A_FRAME0, roof_y, back), Vector3(A_FRAME1, roof_y, back), Vector3(A_FRAME1, top, back), Vector3(A_FRAME0, top, back), -out)
	# Jambs below the springing.
	_quad("wall", mat, Vector3(A_OPEN0, WALL_BOTTOM_Y, front), Vector3(A_OPEN0, WALL_BOTTOM_Y, back), Vector3(A_OPEN0, spring, back), Vector3(A_OPEN0, spring, front), Vector3(1, 0, 0))
	_quad("wall", mat, Vector3(A_OPEN1, WALL_BOTTOM_Y, front), Vector3(A_OPEN1, WALL_BOTTOM_Y, back), Vector3(A_OPEN1, spring, back), Vector3(A_OPEN1, spring, front), Vector3(-1, 0, 0))
	# Cap and end returns.
	_quad("wall", mat, Vector3(A_FRAME0, top, front), Vector3(A_FRAME1, top, front), Vector3(A_FRAME1, top, back), Vector3(A_FRAME0, top, back), Vector3.UP)
	for e: Array in [[A_FRAME0, Vector3(-1, 0, 0)], [A_FRAME1, Vector3(1, 0, 0)]]:
		var a: float = e[0]
		_quad("wall", mat, Vector3(a, WALL_BOTTOM_Y, front), Vector3(a, WALL_BOTTOM_Y, back), Vector3(a, top, back), Vector3(a, top, front), e[1])
	# Thin coping strip on the frame top (metal, matches parapet copings).
	var zmin := minf(front, back)
	var zmax := maxf(front, back)
	_abox("detail", "coping", Vector3(A_FRAME0 - 0.0, top, zmin), Vector3(A_FRAME1, top + 0.05, zmax), 4)


func _arch_radius() -> float:
	var half := (A_OPEN1 - A_OPEN0) * 0.5
	var rise := H_CROWN - H_SPRING
	return (half * half + rise * rise) / (2.0 * rise)


func _arch_points(segments: int) -> Array:
	var r := _arch_radius()
	var half := (A_OPEN1 - A_OPEN0) * 0.5
	var ac := (A_OPEN0 + A_OPEN1) * 0.5
	var yc := B + H_CROWN - r
	var t0 := asin(half / r)
	var out: Array = []
	for i in segments + 1:
		var th := -t0 + 2.0 * t0 * float(i) / segments
		out.append(Vector2(ac + r * sin(th), yc + r * cos(th)))
	out[0] = Vector2(A_OPEN0, B + H_SPRING)
	out[segments] = Vector2(A_OPEN1, B + H_SPRING)
	return out


func _build_passage() -> void:
	var b0 := FRAME_BACK_B
	var b1 := W - 0.656
	var deck_y := B + H_DECK
	var sdir := Vector3(0, 0, 1)
	# North side (main-bar rooms): doors and multi-light windows (r15 left side).
	var no := Vector3(A_OPEN1, 0, 0)
	var nn := Vector3(-1, 0, 0)
	var d1 := Rect2(2.7, land_y(A_OPEN1, 3.2) + 0.02, 1.0, 2.15)
	var d2 := Rect2(10.2, land_y(A_OPEN1, 10.7) + 0.02, 1.0, 2.15)
	var w1 := Rect2(5.0, B + H_SILL, 2.2, 1.6)
	var w2 := Rect2(12.6, B + H_SILL, 2.2, 1.6)
	var holes := [d1, d2, w1, w2]
	_wall("wall", "cream_base", no, sdir, nn, b0, b1, WALL_BOTTOM_Y, B + 0.9, holes)
	_wall("wall", "cream", no, sdir, nn, b0, b1, B + 0.9, deck_y, holes)
	_door("cream", "door", no, sdir, nn, d1)
	_door("cream", "door", no, sdir, nn, d2)
	_window("cream", no, sdir, nn, w1, 2, 0.5)
	_window("cream", no, sdir, nn, w2, 2, 0.5)
	ground_contacts.append({"id": "passage-north-door-1", "a": A_OPEN1, "b": 3.2, "bottom_y": d1.position.y, "land_y": d1.position.y - 0.02})
	ground_contacts.append({"id": "passage-north-door-2", "a": A_OPEN1, "b": 10.7, "bottom_y": d2.position.y, "land_y": d2.position.y - 0.02})
	# South side: breeze-block screen field, a door and a small window.
	var so := Vector3(A_OPEN0, 0, 0)
	var sn := Vector3(1, 0, 0)
	var cells: Array = []
	var pitch := 0.40
	var cell := 0.27
	for row in 6:
		for col in 20:
			var cs := 1.2 + pitch * col + (pitch - cell) * 0.5
			var cy := B + 0.55 + pitch * row + (pitch - cell) * 0.5
			cells.append(Rect2(cs, cy, cell, cell))
	var sd := Rect2(11.6, land_y(A_OPEN0, 12.1) + 0.02, 1.0, 2.15)
	var sw := Rect2(13.8, B + 1.2, 1.3, 1.1)
	var south_holes := cells.duplicate()
	south_holes.append(sd)
	south_holes.append(sw)
	_wall("wall", "cream_base", so, sdir, sn, b0, b1, WALL_BOTTOM_Y, B + 0.45, south_holes)
	_wall("wall", "cream", so, sdir, sn, b0, b1, B + 0.45, deck_y, south_holes)
	for c: Rect2 in cells:
		_reveals("cream", so, sdir, sn, c, 0.19, true)
		_quad("wall", "cell_dark", _wp(so, sdir, sn, c.position.x, c.position.y, 0.19), _wp(so, sdir, sn, c.end.x, c.position.y, 0.19), _wp(so, sdir, sn, c.end.x, c.end.y, 0.19), _wp(so, sdir, sn, c.position.x, c.end.y, 0.19), sn)
	_door("cream", "door", so, sdir, sn, sd)
	_window("cream", so, sdir, sn, sw, 1, 0.0)
	ground_contacts.append({"id": "passage-south-door", "a": A_OPEN0, "b": 12.1, "bottom_y": sd.position.y, "land_y": sd.position.y - 0.02})
	# Round SFFD badge above the screen (visual only).
	_cyl("visual", "badge_white", Vector3(A_OPEN0, B + 3.45, 5.2), Vector3(1, 0, 0), 0.40, 0.03, 20)
	_cyl("visual", "badge_red", Vector3(A_OPEN0 + 0.03, B + 3.45, 5.2), Vector3(1, 0, 0), 0.31, 0.015, 20)
	_cyl("visual", "badge_white", Vector3(A_OPEN0 + 0.045, B + 3.45, 5.2), Vector3(1, 0, 0), 0.11, 0.008, 12)
	# Metal deck soffit and open-web steel joists spanning the passage.
	_quad("roof", "deck", Vector3(A_OPEN0, deck_y, b0), Vector3(A_OPEN1, deck_y, b0), Vector3(A_OPEN1, deck_y, b1), Vector3(A_OPEN0, deck_y, b1), Vector3.DOWN)
	var jb := 1.3
	while jb < b1 - 0.4:
		_joist(jb, deck_y)
		jb += 1.25
	# Concrete drive slab draped on actual land (visual, no collision).
	var na := 10
	var nb := 24
	for i in na:
		for j in nb:
			var a0 := A_OPEN0 + (A_OPEN1 - A_OPEN0) * float(i) / na
			var a1 := A_OPEN0 + (A_OPEN1 - A_OPEN0) * float(i + 1) / na
			var c0 := FRAME_FRONT_B + (W - 0.056 - FRAME_FRONT_B) * float(j) / nb
			var c1 := FRAME_FRONT_B + (W - 0.056 - FRAME_FRONT_B) * float(j + 1) / nb
			var p00 := Vector3(a0, land_y(a0, c0) + 0.065, c0)
			var p10 := Vector3(a1, land_y(a1, c0) + 0.065, c0)
			var p11 := Vector3(a1, land_y(a1, c1) + 0.065, c1)
			var p01 := Vector3(a0, land_y(a0, c1) + 0.065, c1)
			var up1 := (p10 - p00).cross(p11 - p00).normalized()
			if up1.y < 0.0: up1 = -up1
			_s("visual", "concrete").tri(p00, p10, p11, up1)
			var up2 := (p11 - p00).cross(p01 - p00).normalized()
			if up2.y < 0.0: up2 = -up2
			_s("visual", "concrete").tri(p00, p11, p01, up2)
	# Eight grey bollards (r08) with a clear 0.88 m centre walkway gap.
	for off: float in [-3.85, -2.75, -1.65, -0.55, 0.55, 1.65, 2.75, 3.85]:
		var ba := (A_OPEN0 + A_OPEN1) * 0.5 + off
		var bb := 1.0
		var g := land_y(ba, bb)
		_cyl("detail", "bollard", Vector3(ba, g - 0.10, bb), Vector3.UP, 0.11, 1.03, 12, false)
		_cyl("detail", "bollard_cap", Vector3(ba, g + 0.93, bb), Vector3.UP, 0.115, 0.07, 12, true)
		ground_contacts.append({"id": "bollard-%.2f" % ba, "a": ba, "b": bb, "bottom_y": g - 0.10, "land_y": g, "top_y": g + 1.0})


func _joist(jb: float, deck_y: float) -> void:
	var top_lo := deck_y - 0.08
	var bot_hi := deck_y - 0.40
	var bot_lo := deck_y - 0.46
	var a0 := A_OPEN0
	var a1 := A_OPEN1
	_abox("detail", "steel", Vector3(a0, top_lo, jb - 0.05), Vector3(a1, deck_y, jb + 0.05), 1 | 2 | 8)
	var ba0 := a0 + 0.35
	var ba1 := a1 - 0.35
	_abox("detail", "steel", Vector3(ba0, bot_lo, jb - 0.04), Vector3(ba1, bot_hi, jb + 0.04))
	var panels := 12
	var step := (ba1 - ba0) / panels
	for i in panels:
		var pa := ba0 + step * i
		var pb := pa + step
		var low := Vector3(pa if i % 2 == 0 else pb, (bot_lo + bot_hi) * 0.5, jb)
		var high := Vector3(pb if i % 2 == 0 else pa, (top_lo + deck_y) * 0.5 - 0.04, jb)
		_strut(low, high, 0.022)
	_strut(Vector3(ba0, (bot_lo + bot_hi) * 0.5, jb), Vector3(a0 + 0.08, top_lo, jb), 0.025)
	_strut(Vector3(ba1, (bot_lo + bot_hi) * 0.5, jb), Vector3(a1 - 0.08, top_lo, jb), 0.025)


func _strut(p: Vector3, q: Vector3, half: float) -> void:
	var ax := (q - p).normalized()
	var az := Vector3(0, 0, 1)
	var ay := az.cross(ax).normalized()
	_box("detail", "steel", (p + q) * 0.5, ax, ay, az, Vector3((q - p).length() * 0.5, half, half), 3)


func _bay_centre(i: int) -> float:
	return A_FRAME1 + (PORCH_A - A_FRAME1) * (float(i) + 0.5) / BAY_COUNT


func _bay_width() -> float:
	return (PORCH_A - A_FRAME1) / BAY_COUNT


func _build_main_bar() -> void:
	var bw := _bay_width()
	# West (Avenue M) face: pilastered bays, high windows and multi-light lower windows.
	var wo := Vector3(0, 0, WEST_FACE_B)
	var sdir := Vector3(1, 0, 0)
	var wn := Vector3(0, 0, -1)
	# Lower opening rhythm is production_inference (west cadence hidden by trees).
	var pattern := ["WW", "DW", "WW", "W", "WW", "DW", "WW", "WW", "W", "DW", "WW", "WW", "W", "DW"]
	var holes: Array = []
	var windows: Array = []
	var doors: Array = []
	for i in BAY_COUNT:
		var ac := _bay_centre(i)
		for off: float in [-1.35, 1.35]:
			holes.append(Rect2(ac + off - 0.40, B + H_HIGH_LO, 0.80, H_HIGH_HI - H_HIGH_LO))
		var kind: String = pattern[i]
		var lower: Array = []
		if kind == "WW":
			lower = [["W", ac - 1.45], ["W", ac + 1.45]]
		elif kind == "W":
			lower = [["W", ac]]
		else:
			lower = [["D", ac - 1.75], ["W", ac + 0.95]]
		for item: Array in lower:
			if item[0] == "W":
				var r := Rect2(float(item[1]) - 1.0, B + H_SILL, 2.0, H_HEAD - H_SILL)
				holes.append(r)
				windows.append(r)
			else:
				var g := land_y(float(item[1]), WEST_FACE_B - 0.05)
				var d := Rect2(float(item[1]) - 0.5, g + 0.02, 1.0, 2.15)
				holes.append(d)
				doors.append(d)
				ground_contacts.append({"id": "west-door-bay-%d" % i, "a": float(item[1]), "b": WEST_FACE_B, "bottom_y": d.position.y, "land_y": g})
	_wall("wall", "cream_base", wo, sdir, wn, A_FRAME1, PORCH_A, WALL_BOTTOM_Y, B + H_PLINTH, holes)
	_wall("wall", "cream", wo, sdir, wn, A_FRAME1, PORCH_A, B + H_PLINTH, B + H_PARAPET, holes)
	for r: Rect2 in windows:
		_window("cream", wo, sdir, wn, r, 2, 0.55)
	for d: Rect2 in doors:
		_door("cream", "door", wo, sdir, wn, d)
	for i in BAY_COUNT:
		var ac := _bay_centre(i)
		for off: float in [-1.35, 1.35]:
			_window("cream", wo, sdir, wn, Rect2(ac + off - 0.40, B + H_HIGH_LO, 0.80, H_HIGH_HI - H_HIGH_LO), 1, 0.0, 0.18, false)
	# Shallow pilasters at bay lines (r12 joint/pilaster marks).
	for k in range(1, BAY_COUNT):
		var ap := A_FRAME1 + bw * k
		_wbox("wall", "cream", wo, sdir, wn, ap - 0.22, ap + 0.22, WALL_BOTTOM_Y, B + H_PARAPET, -0.05, 0.0, 32 | 8)
	# NW corner porch step (r10 low cream-banded corner element).
	var step_o := Vector3(PORCH_A, 0, 0)
	_wall("wall", "bluegrey", step_o, Vector3(0, 0, 1), Vector3(1, 0, 0), WEST_FACE_B, PORCH_B, WALL_BOTTOM_Y, B + H_BAND_LO, [])
	_wall("wall", "north_grey", step_o, Vector3(0, 0, 1), Vector3(1, 0, 0), WEST_FACE_B, PORCH_B, B + H_BAND_LO, B + H_PARAPET, [])
	var w2o := Vector3(0, 0, PORCH_B)
	var pd := Rect2(101.6, land_y(102.1, PORCH_B) + 0.02, 1.0, 2.15)
	_wall("wall", "bluegrey", w2o, sdir, wn, PORCH_A, L - 0.05, WALL_BOTTOM_Y, B + H_BAND_LO, [pd])
	_wall("wall", "cream", w2o, sdir, wn, PORCH_A, L - 0.05, B + H_BAND_LO, B + H_PARAPET, [])
	_door("bluegrey", "door", w2o, sdir, wn, pd)
	ground_contacts.append({"id": "porch-door", "a": 102.1, "b": PORCH_B, "bottom_y": pd.position.y, "land_y": pd.position.y - 0.02})
	_abox("wall", "north_cream", Vector3(PORCH_A, B + H_BAND_LO, WEST_FACE_B), Vector3(L - 0.05, B + H_BAND_HI, PORCH_B), 1 | 32)
	var pier_g := land_y(L - 0.35, 0.65)
	_abox("wall", "bluegrey", Vector3(L - 0.65, WALL_BOTTOM_Y, WEST_FACE_B), Vector3(L - 0.05, B + H_BAND_LO, 0.95), 8)
	ground_contacts.append({"id": "porch-pier", "a": L - 0.35, "b": 0.65, "bottom_y": WALL_BOTTOM_Y, "land_y": pier_g})
	# North end (10th St): windowless banded wall, teal service door near the walkway.
	var no := Vector3(L - 0.05, 0, 0)
	var ndir := Vector3(0, 0, 1)
	var nn := Vector3(1, 0, 0)
	var nd := Rect2(11.55, land_y(L - 0.05, 12.05) + 0.02, 1.0, 2.15)
	_wall("wall", "bluegrey", no, ndir, nn, PORCH_B, EAST_WALL_B, WALL_BOTTOM_Y, B + H_BAND_LO, [nd])
	_wall("wall", "north_cream", no, ndir, nn, PORCH_B, EAST_WALL_B, B + H_BAND_LO, B + H_BAND_HI, [])
	_wall("wall", "north_grey", no, ndir, nn, PORCH_B, EAST_WALL_B, B + H_BAND_HI, B + H_PARAPET, [])
	_door("bluegrey", "door_teal", no, ndir, nn, nd)
	ground_contacts.append({"id": "north-door", "a": L - 0.05, "b": 12.05, "bottom_y": nd.position.y, "land_y": nd.position.y - 0.02})
	# East (yard) face under the walkway: honest plain inference, doors and windows.
	var eo := Vector3(0, 0, EAST_WALL_B)
	var en := Vector3(0, 0, 1)
	var eholes: Array = []
	var ewin: Array = []
	var edoor: Array = []
	var bays_east := BAY_COUNT + 1
	for i in bays_east:
		var ac := _bay_centre(i) if i < BAY_COUNT else (PORCH_A + L) * 0.5
		if i < BAY_COUNT:
			for off: float in [-1.35, 1.35]:
				eholes.append(Rect2(ac + off - 0.40, B + H_HIGH_LO, 0.80, H_HIGH_HI - H_HIGH_LO))
		if i % 2 == 0:
			var g := land_y(ac - 0.6, EAST_WALL_B + 0.05)
			var d := Rect2(ac - 1.1, g + 0.02, 1.0, 2.15)
			eholes.append(d)
			edoor.append(d)
			ground_contacts.append({"id": "east-door-bay-%d" % i, "a": ac - 0.6, "b": EAST_WALL_B, "bottom_y": d.position.y, "land_y": g})
			if i < BAY_COUNT:
				var r := Rect2(ac + 0.8, B + H_SILL, 1.3, 1.35)
				eholes.append(r)
				ewin.append(r)
		else:
			for off: float in [-1.4, 1.4]:
				var r := Rect2(ac + off - 0.65, B + H_SILL, 1.3, 1.35)
				eholes.append(r)
				ewin.append(r)
	_wall("wall", "cream_base", eo, sdir, en, A_FRAME1, L - 0.05, WALL_BOTTOM_Y, B + H_PLINTH, eholes)
	_wall("wall", "cream", eo, sdir, en, A_FRAME1, L - 0.05, B + H_PLINTH, B + H_PARAPET, eholes)
	for r: Rect2 in ewin:
		_window("cream", eo, sdir, en, r, 2, 0.45)
	for d: Rect2 in edoor:
		_door("cream", "door", eo, sdir, en, d)
	for i in BAY_COUNT:
		var ac := _bay_centre(i)
		for off: float in [-1.35, 1.35]:
			_window("cream", eo, sdir, en, Rect2(ac + off - 0.40, B + H_HIGH_LO, 0.80, H_HIGH_HI - H_HIGH_LO), 1, 0.0, 0.18, false)


func _build_walkway() -> void:
	var front := W - 0.056
	var fascia_back := W - 0.206
	var y_soffit := B + H_WALK_SOFFIT
	var y_top := B + H_WALK_TOP
	var y_f0 := B + H_BAND_LO
	var y_f1 := B + H_WALK_TOP + 0.10
	# Long cream fascia (r10 deep band), north return fascia with lettering.
	_abox("wall", "north_cream", Vector3(A_FRAME1, y_f0, fascia_back), Vector3(L - 0.20, y_f1, front), 1 | 2)
	_abox("wall", "north_cream", Vector3(L - 0.20, y_f0, EAST_WALL_B), Vector3(L - 0.05, y_f1, front), 16)
	_quad("roof", "walk_soffit", Vector3(A_FRAME1, y_soffit, EAST_WALL_B), Vector3(L - 0.20, y_soffit, EAST_WALL_B), Vector3(L - 0.20, y_soffit, fascia_back), Vector3(A_FRAME1, y_soffit, fascia_back), Vector3.DOWN)
	_quad("roof", "walk_roof", Vector3(A_FRAME1, y_top, EAST_WALL_B), Vector3(L - 0.20, y_top, EAST_WALL_B), Vector3(L - 0.20, y_top, fascia_back), Vector3(A_FRAME1, y_top, fascia_back), Vector3.UP)
	# Steel posts on actual land, aligned with the bays.
	var post_b := W - 0.30
	var posts: Array = []
	for k in range(1, BAY_COUNT + 1):
		posts.append(A_FRAME1 + _bay_width() * k)
	posts.append(L - 0.40)
	for ap: float in posts:
		var g := land_y(ap, post_b)
		_abox("detail", "steel", Vector3(ap - 0.075, g - 0.10, post_b - 0.075), Vector3(ap + 0.075, y_soffit, post_b + 0.075), 4 | 8)
		_abox("detail", "steel", Vector3(ap - 0.15, g - 0.10, post_b - 0.15), Vector3(ap + 0.15, g + 0.02, post_b + 0.15), 4)
		ground_contacts.append({"id": "walkway-post-%.2f" % ap, "a": ap, "b": post_b, "bottom_y": g - 0.10, "land_y": g, "top_y": y_soffit})


func _build_roofs() -> void:
	var ry := B + H_ROOF
	var py := B + H_PARAPET
	var cy := py + 0.06
	# Main bar membrane (L-shaped around the NW porch step).
	_quad("roof", "roof_light", Vector3(15.45, ry, 0.60), Vector3(PORCH_A - 0.25, ry, 0.60), Vector3(PORCH_A - 0.25, ry, EAST_WALL_B - 0.25), Vector3(15.45, ry, EAST_WALL_B - 0.25), Vector3.UP)
	_quad("roof", "roof_light", Vector3(PORCH_A - 0.25, ry, PORCH_B + 0.25), Vector3(L - 0.30, ry, PORCH_B + 0.25), Vector3(L - 0.30, ry, EAST_WALL_B - 0.25), Vector3(PORCH_A - 0.25, ry, EAST_WALL_B - 0.25), Vector3.UP)
	# Parapet inner faces.
	_iface(Vector3(15.45, 0, 0.60), Vector3(PORCH_A - 0.25, 0, 0.60), Vector3(0, 0, 1), ry, py)
	_iface(Vector3(PORCH_A - 0.25, 0, 0.60), Vector3(PORCH_A - 0.25, 0, PORCH_B + 0.25), Vector3(-1, 0, 0), ry, py)
	_iface(Vector3(PORCH_A - 0.25, 0, PORCH_B + 0.25), Vector3(L - 0.30, 0, PORCH_B + 0.25), Vector3(0, 0, 1), ry, py)
	_iface(Vector3(L - 0.30, 0, PORCH_B + 0.25), Vector3(L - 0.30, 0, EAST_WALL_B - 0.25), Vector3(-1, 0, 0), ry, py)
	_iface(Vector3(15.45, 0, EAST_WALL_B - 0.25), Vector3(L - 0.30, 0, EAST_WALL_B - 0.25), Vector3(0, 0, -1), ry, py)
	# Divider parapet between the white main roof and the darker south roof.
	_iface(Vector3(15.45, 0, 0.60), Vector3(15.45, 0, EAST_WALL_B - 0.25), Vector3(1, 0, 0), ry, py)
	_iface(Vector3(15.15, 0, FRAME_BACK_B), Vector3(15.15, 0, W - 0.656), Vector3(-1, 0, 0), ry, py)
	# Copings (metal), arranged to avoid coplanar overlaps at corners.
	_abox("roof", "coping", Vector3(A_FRAME1, py, 0.30), Vector3(PORCH_A + 0.05, cy, 0.65), 4)
	_abox("roof", "coping", Vector3(PORCH_A - 0.30, py, 0.65), Vector3(PORCH_A + 0.05, cy, PORCH_B - 0.05), 4)
	_abox("roof", "coping", Vector3(PORCH_A - 0.30, py, PORCH_B - 0.05), Vector3(L, cy, PORCH_B + 0.30), 4)
	_abox("roof", "coping", Vector3(L - 0.35, py, PORCH_B + 0.30), Vector3(L, cy, EAST_WALL_B + 0.05), 4)
	_abox("roof", "coping", Vector3(15.35, py, EAST_WALL_B - 0.30), Vector3(L - 0.35, cy, EAST_WALL_B + 0.05), 4)
	_abox("roof", "coping", Vector3(15.10, py, 0.65), Vector3(15.50, cy, EAST_WALL_B - 0.30), 4)
	_abox("roof", "coping", Vector3(15.10, py, EAST_WALL_B - 0.30), Vector3(15.35, cy, W - 0.656), 4)
	# Darker south-block roof and its parapets (r04).
	var si := SOUTH_A + 0.25
	_quad("roof", "roof_dark", Vector3(si, ry, FRAME_BACK_B), Vector3(15.15, ry, FRAME_BACK_B), Vector3(15.15, ry, W - 0.656), Vector3(si, ry, W - 0.656), Vector3.UP)
	_iface(Vector3(si, 0, FRAME_BACK_B), Vector3(A_FRAME0, 0, FRAME_BACK_B), Vector3(0, 0, 1), ry, py)
	_iface(Vector3(si, 0, FRAME_BACK_B), Vector3(si, 0, W - 0.656), Vector3(1, 0, 0), ry, py)
	_iface(Vector3(si, 0, W - 0.656), Vector3(A_FRAME0, 0, W - 0.656), Vector3(0, 0, -1), ry, py)
	_abox("roof", "coping", Vector3(SOUTH_A - 0.05, py, 0.30), Vector3(A_FRAME0, cy, 0.69), 4)
	_abox("roof", "coping", Vector3(SOUTH_A - 0.05, py, 0.69), Vector3(si + 0.05, cy, W - 0.706), 4)
	_abox("roof", "coping", Vector3(SOUTH_A - 0.05, py, W - 0.706), Vector3(A_FRAME0, cy, W - 0.306), 4)
	# Faint membrane seams, roof hatch near the south end, a few vent stacks.
	var sa := 18.0
	while sa < L - 1.0:
		var b_hi := EAST_WALL_B - 0.25
		var b_lo := 0.60 if sa < PORCH_A - 0.25 else PORCH_B + 0.25
		_abox("roof", "roof_seam", Vector3(sa - 0.04, ry, b_lo), Vector3(sa + 0.04, ry + 0.02, b_hi), 4 | 1 | 2 | 16 | 32)
		sa += 3.0
	_abox("roof", "hatch", Vector3(21.5, ry, 5.8), Vector3(22.4, ry + 0.5, 6.7), 4)
	_abox("roof", "hatch", Vector3(21.42, ry + 0.5, 5.72), Vector3(22.48, ry + 0.56, 6.78), 4)
	for vent: Vector2 in [Vector2(34.0, 9.6), Vector2(58.5, 3.2), Vector2(83.0, 9.1)]:
		_cyl("roof", "coping", Vector3(vent.x, ry, vent.y), Vector3.UP, 0.09, 0.55, 10)
	_cyl("roof", "coping", Vector3(8.0, ry, 13.5), Vector3.UP, 0.12, 0.45, 10)


func _iface(p: Vector3, q: Vector3, inward: Vector3, y0: float, y1: float) -> void:
	_quad("roof", "parapet_inner", Vector3(p.x, y0, p.z), Vector3(q.x, y0, q.z), Vector3(q.x, y1, q.z), Vector3(p.x, y1, p.z), inward)


# ---------------------------------------------------------------- lettering

func _build_lettering() -> void:
	# "FIRE FIGHTING SCHOOL" follows the arch, cream on maroon (Sep 2025 state).
	var r_text := _arch_radius() + 0.40
	var centre := Vector2((A_OPEN0 + A_OPEN1) * 0.5, B + H_CROWN - _arch_radius())
	var text := "FIRE FIGHTING SCHOOL"
	var font_size := 64
	var px := 0.0066
	var advances: Array[float] = []
	var total := 0.0
	for ch in text:
		var adv := _font.get_char_size(ch.unicode_at(0), font_size).x * px * 1.06
		advances.append(adv)
		total += adv
	var cursor := -total * 0.5
	for i in text.length():
		var mid := cursor + advances[i] * 0.5
		cursor += advances[i]
		if text[i] == " ":
			continue
		var th := mid / r_text
		var radial := Vector3(-sin(th), cos(th), 0)
		var tangent := Vector3(-cos(th), -sin(th), 0)
		var pos := Vector3(centre.x - r_text * sin(th), centre.y + r_text * cos(th), FRAME_FRONT_B - 0.016)
		_letter(text[i], pos, tangent, radial, Vector3(0, 0, -1), font_size, px, "letter_cream")
	# "600" plaque numerals on the north pier (r08).
	_word("600", Vector3(13.95, B + 1.55, FRAME_FRONT_B - 0.016), Vector3(-1, 0, 0), Vector3(0, 0, -1), 64, 0.0062, "letter_cream")
	# Walkway north fascia lettering (r10 shows "...TRAINING...").
	_word("TRAINING", Vector3(L - 0.034, B + 2.92, (EAST_WALL_B + W - 0.056) * 0.5), Vector3(0, 0, -1), Vector3(1, 0, 0), 64, 0.0042, "letter_dark")


func _word(text: String, centre: Vector3, reading: Vector3, facing: Vector3, font_size: int, px: float, mat: String) -> void:
	var total := 0.0
	var advances: Array[float] = []
	for ch in text:
		var adv := _font.get_char_size(ch.unicode_at(0), font_size).x * px * 1.04
		advances.append(adv)
		total += adv
	var cursor := -total * 0.5
	for i in text.length():
		var mid := cursor + advances[i] * 0.5
		cursor += advances[i]
		_letter(text[i], centre + reading * mid, reading, Vector3.UP, facing, font_size, px, mat)


func _letter(ch: String, pos: Vector3, x_axis: Vector3, y_axis: Vector3, z_axis: Vector3, font_size: int, px: float, mat: String) -> void:
	var mesh := TextMesh.new()
	mesh.text = ch
	mesh.font = _font
	mesh.font_size = font_size
	mesh.pixel_size = px
	mesh.depth = 0.03
	mesh.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mesh.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	mesh.material = _material(mat)
	var inst := MeshInstance3D.new()
	inst.name = "Letter%d" % letters.size()
	inst.mesh = mesh
	inst.layers = 1
	inst.transform = Transform3D(Basis(x_axis, y_axis, z_axis), pos)
	inst.set_meta("source_keys", [SOURCE_KEY])
	inst.set_meta("derived_object_key", WALL_KEY)
	inst.set_meta("receiver_kind", "none")
	add_child(inst)
	letters.append(inst)


# ---------------------------------------------------------------- materials / commit

func _texture(path: String) -> Texture2D:
	if not _textures.has(path):
		_textures[path] = load(TEX_ROOT + path) as Texture2D
	return _textures[path]


func _material(key: String) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key]
	var m := StandardMaterial3D.new()
	m.resource_name = "b600_" + key
	m.roughness = 0.9
	var tex_set := ""
	var repeat := 1.5
	match key:
		"cream":
			m.albedo_color = Color8(250, 238, 210)
			tex_set = "plaster_grey_04"
		"cream_base":
			m.albedo_color = Color8(226, 212, 182)
			tex_set = "plaster_grey_04"
			repeat = 1.0
		"maroon":
			m.albedo_color = Color8(150, 38, 46)
			tex_set = "plaster_grey_04"
		"bluegrey":
			m.albedo_color = Color8(150, 168, 184)
			tex_set = "plaster_grey_04"
		"north_cream":
			m.albedo_color = Color8(242, 224, 182)
			tex_set = "plaster_grey_04"
		"north_grey":
			m.albedo_color = Color8(218, 218, 212)
			tex_set = "plaster_grey_04"
		"parapet_inner":
			m.albedo_color = Color8(214, 210, 200)
			tex_set = "plaster_grey_04"
		"roof_light":
			m.albedo_color = Color8(236, 236, 230)
			tex_set = "bitumen"
			repeat = 6.0
		"roof_dark":
			m.albedo_color = Color8(128, 128, 126)
			tex_set = "bitumen"
			repeat = 6.0
		"walk_roof":
			m.albedo_color = Color8(170, 170, 166)
			tex_set = "bitumen"
			repeat = 6.0
		"roof_seam":
			m.albedo_color = Color8(196, 196, 190)
		"walk_soffit":
			m.albedo_color = Color8(214, 206, 186)
		"concrete":
			m.albedo_color = Color8(214, 211, 204)
			tex_set = "concrete_floor_03"
			repeat = 2.5
		"glass":
			m.albedo_color = Color8(44, 58, 68)
			m.metallic = 0.55
			m.roughness = 0.12
		"frame":
			m.albedo_color = Color8(96, 116, 132)
			m.metallic = 0.25
			m.roughness = 0.5
		"door":
			m.albedo_color = Color8(98, 116, 130)
			m.roughness = 0.55
		"door_teal":
			m.albedo_color = Color8(42, 132, 144)
			m.roughness = 0.5
		"sill":
			m.albedo_color = Color8(206, 200, 186)
		"coping":
			m.albedo_color = Color8(178, 180, 178)
			m.metallic = 0.35
			m.roughness = 0.45
		"hatch":
			m.albedo_color = Color8(196, 196, 190)
			m.metallic = 0.2
			m.roughness = 0.5
		"steel":
			m.albedo_color = Color8(84, 92, 100)
			m.metallic = 0.45
			m.roughness = 0.5
		"deck":
			m.albedo_color = Color8(168, 172, 172)
			m.metallic = 0.2
			m.roughness = 0.65
		"bollard":
			m.albedo_color = Color8(118, 120, 120)
			m.roughness = 0.6
		"bollard_cap":
			m.albedo_color = Color8(228, 228, 222)
			m.roughness = 0.5
		"cell_dark":
			m.albedo_color = Color8(52, 48, 44)
			m.roughness = 1.0
		"badge_red":
			m.albedo_color = Color8(176, 30, 34)
		"badge_white":
			m.albedo_color = Color8(236, 234, 228)
		"letter_cream":
			m.albedo_color = Color8(240, 230, 204)
			m.roughness = 0.6
		"letter_dark":
			m.albedo_color = Color8(52, 58, 64)
			m.roughness = 0.6
		_:
			m.albedo_color = Color(1, 0, 1)
	if not tex_set.is_empty():
		m.albedo_texture = _texture("%s/%s_diff_1k.jpg" % [tex_set, tex_set])
		m.normal_enabled = true
		m.normal_texture = _texture("%s/%s_nor_gl_1k.jpg" % [tex_set, tex_set])
		m.normal_scale = 0.35
		m.roughness_texture = _texture("%s/%s_rough_1k.jpg" % [tex_set, tex_set])
		m.uv1_scale = Vector3(1.0 / repeat, 1.0 / repeat, 1.0)
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_materials[key] = m
	return m


func _commit() -> void:
	var names := {"wall": "WallMesh", "roof": "RoofMesh", "detail": "DetailMesh", "visual": "VisualMesh"}
	var bodies := {"wall": "WallContact", "roof": "RoofContact", "detail": "DetailContact"}
	for role: String in ROLES:
		var group: Dictionary = _surfs[role]
		var mesh := ArrayMesh.new()
		var keys: Array = group.keys()
		keys.sort()
		for key: String in keys:
			var s: Surf = group[key]
			if s.idx.is_empty():
				continue
			var arrays: Array = []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = s.v
			arrays[Mesh.ARRAY_NORMAL] = s.n
			arrays[Mesh.ARRAY_TANGENT] = s.t
			arrays[Mesh.ARRAY_TEX_UV] = s.uv
			arrays[Mesh.ARRAY_INDEX] = s.idx
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			var si := mesh.get_surface_count() - 1
			mesh.surface_set_name(si, key)
			mesh.surface_set_material(si, _material(key))
		var inst := MeshInstance3D.new()
		inst.name = names[role]
		inst.mesh = mesh
		inst.layers = 2 if role == "wall" else 1
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if role == "visual" else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		_tag(inst, "building_wall" if role == "wall" else "none", WALL_KEY if role != "roof" else ROOF_KEY)
		inst.set_meta("b600_role", role)
		add_child(inst)
		if not bodies.has(role):
			continue
		var faces := PackedVector3Array()
		for si in mesh.get_surface_count():
			var arr: Array = mesh.surface_get_arrays(si)
			var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var ids: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
			for i in ids:
				faces.append(verts[i])
		var body := StaticBody3D.new()
		body.name = bodies[role]
		body.collision_layer = 1 | 4
		body.collision_mask = 0
		var receiver := "building_wall" if role == "wall" else "none"
		var key := ROOF_KEY if role == "roof" else WALL_KEY
		_tag(body, receiver, key)
		body.set_meta("b600_role", role)
		if role == "wall":
			body.add_to_group("spray_receiver_wall")
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(faces)
		_tag(shape, receiver, key)
		var holder := CollisionShape3D.new()
		holder.name = "Shape"
		holder.shape = shape
		_tag(holder, receiver, key)
		body.add_child(holder)
		add_child(body)


func _tag(object: Object, receiver: String, key: String) -> void:
	object.set_meta("source_keys", [SOURCE_KEY])
	object.set_meta("derived_object_key", key)
	object.set_meta("receiver_kind", receiver)
	object.set_meta("collision_kind", "world_solid")
	object.set_meta("feature_kind", "building_wall" if key == WALL_KEY else "building_roof")
	object.set_meta("opaque", true)
