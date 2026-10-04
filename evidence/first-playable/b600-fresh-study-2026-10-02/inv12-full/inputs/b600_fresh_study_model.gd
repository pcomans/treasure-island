extends Node3D
## Building 600 (SFFD Treasure Island Training Facility, OSM w34313548) fresh
## isolated whole-building study. Owner-directed new base; no shared-family reuse.
##
## Footprint-local frame (derived from the exact generated roof record):
##   +X = "a": long axis from the OSM south corner (v0) toward the north end,
##   +Z = "b": across from the west (Avenue M) face to the east (yard) face,
##   Y  = world elevation (metres).
## Building geometry stays inside the actual OSM polygon. The separate
## "setting" mesh (visual-only ground treatment on the school site area along
## Avenue M) is the only part outside the footprint.
## Unmeasured dimensions, cadence and hidden sides are production_inference.

const SOURCE_KEY := "w34313548"
const WALL_KEY := "building:w34313548:wall"
const ROOF_KEY := "building:w34313548:roof"
const TEX_ROOT := "res://game/resources/textures/world/polyhaven/"
const WALL_BOTTOM_Y := 3.40
const ROLES := ["wall", "roof", "detail", "visual", "setting"]

# Heights above the flat source base B (production_inference).
# Main bar parapet near 5.05 m (r07/r08/r15 ratios, r10 bands), below the 6 m tag.
const H_PARAPET := 5.05
const H_ROOF := 4.50
# Round 2 portal: tall frame, crown at 0.8 of frame height, low flanking
# blocks at about 0.6 of frame height (r07/r08/r15 reviewer ratios).
const H_FRAME_TOP := 5.30
const H_CROWN := 4.24
const H_SPRING := 2.55
const H_DECK := 4.38
const H_HI_ROOF := 4.62
const H_HI_PARAPET := 4.80
const H_LOW := 3.15
const H_LOW_ROOF := 2.75
const H_PLINTH := 0.90
const H_BAND_LO := 2.35
const H_BAND_HI := 3.40
const H_WALK_TOP := 3.40
const H_WALK_SOFFIT := 2.65
const H_SILL := 1.00
const H_HEAD := 2.60
const H_HIGH_LO := 3.55
const H_HIGH_HI := 4.20
const COPING_H := 0.10

# Plan positions (metres in the local frame).
const WEST_FACE_B := 0.35
const FRAME_FRONT_B := 0.04
const FRAME_BACK_B := 0.64
const SOUTH_A := 0.10
const A_LOW_S0 := 1.90
const A_FRAME0 := 3.90
const A_OPEN0 := 4.50
const A_OPEN1 := 11.70
const A_FRAME1 := 12.30
const A_MAIN := 15.30
const EAST_WALL_B := 12.95
const PORCH_A := 100.0
const PORCH_B := 1.90
const BAY_COUNT := 14
const EDGE_INSET := 0.006

var L := 0.0
var W := 0.0
var B := 0.0
var origin_world := Vector3.ZERO
var axis_a := Vector3.ZERO
var axis_b := Vector3.ZERO
var footprint_world: Array = []
var _land: Array = []
var _surfs: Dictionary = {}
var _materials: Dictionary = {}
var _textures: Dictionary = {}
var _grain: ImageTexture
var _font: Font
var ground_contacts: Array = []
var letters: Array = []
var west_door_centres: Array = []


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
	footprint_world = pts.duplicate()
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
	# Heavy sans for painted signage; falls back to the engine font if absent.
	var system := SystemFont.new()
	system.font_names = PackedStringArray(["Arial Black", "Helvetica Neue", "Arial"])
	system.font_weight = 900
	_font = system
	for role in ROLES:
		_surfs[role] = {}
	_build_south_block()
	_build_portal_frame(true)
	_build_portal_frame(false)
	_build_passage()
	_build_main_bar()
	_build_walkway()
	_build_roofs()
	_build_setting()
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


## fixture_out: wall-pack projection; limited where the wall sits near the footprint edge.
func _door(wall_mat: String, door_mat: String, origin: Vector3, sdir: Vector3, nn: Vector3, r: Rect2, depth := 0.14, fixture_out := 0.16) -> void:
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
	if s1 - s0 > 1.5:
		var mid := (s0 + s1) * 0.5
		_wbox("detail", "frame", origin, sdir, nn, mid - 0.03, mid + 0.03, y0, y1 - 0.06, fd, depth)
	# Small vision light and lever keep the leaf legible as a door.
	var vs := (s0 + s1) * 0.5
	_wbox("detail", "glass", origin, sdir, nn, vs - 0.12, vs + 0.12, y0 + 1.30, y0 + 1.85, depth - 0.012, depth)
	_wbox("detail", "frame", origin, sdir, nn, s1 - 0.20, s1 - 0.10, y0 + 0.98, y0 + 1.02, depth - 0.05, depth)
	# Small wall-pack light over each personnel door.
	if fixture_out > 0.0:
		_wbox("detail", "fixture", origin, sdir, nn, vs - 0.14, vs + 0.14, y1 + 0.22, y1 + 0.44, -fixture_out, 0.0)
		_wbox("detail", "fixture_lens", origin, sdir, nn, vs - 0.10, vs + 0.10, y1 + 0.24, y1 + 0.30, -fixture_out - 0.01, -fixture_out)


## Louvred service vent panel (east inference).
func _louver(wall_mat: String, origin: Vector3, sdir: Vector3, nn: Vector3, r: Rect2) -> void:
	_reveals(wall_mat, origin, sdir, nn, r, 0.12, true)
	_quad("detail", "louver_back", _wp(origin, sdir, nn, r.position.x, r.position.y, 0.12), _wp(origin, sdir, nn, r.end.x, r.position.y, 0.12), _wp(origin, sdir, nn, r.end.x, r.end.y, 0.12), _wp(origin, sdir, nn, r.position.x, r.end.y, 0.12), nn)
	var y := r.position.y + 0.08
	while y < r.end.y - 0.06:
		_wbox("detail", "frame", origin, sdir, nn, r.position.x, r.end.x, y, y + 0.05, 0.03, 0.12)
		y += 0.13


# ---------------------------------------------------------------- massing

func _build_south_block() -> void:
	var low := B + H_LOW
	var sx := Vector3(1, 0, 0)
	var sz := Vector3(0, 0, 1)
	var east_b := W - 0.356
	# West: recessed maroon south wall, then two proud low maroon blocks flank the frame.
	_wall("wall", "maroon", Vector3(0, 0, WEST_FACE_B), sx, Vector3(0, 0, -1), SOUTH_A, A_LOW_S0, WALL_BOTTOM_Y, low, [])
	_abox("wall", "maroon", Vector3(A_LOW_S0, WALL_BOTTOM_Y, FRAME_FRONT_B), Vector3(A_FRAME0, low, WEST_FACE_B), 2 | 4 | 8 | 32)
	_abox("wall", "maroon", Vector3(A_FRAME1, WALL_BOTTOM_Y, FRAME_FRONT_B), Vector3(A_MAIN, low, WEST_FACE_B), 1 | 4 | 8 | 32)
	# South end (r14 occluded): low cream wall, one door and two windows.
	var so := Vector3(SOUTH_A, 0, 0)
	var sn := Vector3(-1, 0, 0)
	var door_g := land_y(SOUTH_A, 3.5)
	var door := Rect2(3.0, door_g + 0.02, 1.0, 2.15)
	var w1 := Rect2(7.4, B + H_SILL, 1.4, 1.2)
	var w2 := Rect2(11.4, B + H_SILL, 1.4, 1.2)
	var holes := [door, w1, w2]
	_wall("wall", "cream_base", so, sz, sn, WEST_FACE_B, east_b, WALL_BOTTOM_Y, B + H_PLINTH, holes)
	_wall("wall", "cream", so, sz, sn, WEST_FACE_B, east_b, B + H_PLINTH, low, holes)
	_door("cream", "door", so, sz, sn, door, 0.14, SOUTH_A - 0.03)
	_window("cream", so, sz, sn, w1, 2, 0.0)
	_window("cream", so, sz, sn, w2, 2, 0.0)
	ground_contacts.append({"id": "south-door", "a": SOUTH_A, "b": 3.5, "bottom_y": door.position.y, "land_y": door_g})
	# East (yard) low blocks flanking the cream east arch; doors break the plane.
	var eo := Vector3(0, 0, east_b)
	var en := Vector3(0, 0, 1)
	var eg1 := land_y(1.4, east_b)
	var ed1 := Rect2(0.9, eg1 + 0.02, 1.0, 2.15)
	var eg2 := land_y(13.8, east_b)
	var ed2 := Rect2(13.3, eg2 + 0.02, 1.0, 2.15)
	for seg: Array in [[SOUTH_A, A_FRAME0, ed1], [A_FRAME1, A_MAIN, ed2]]:
		var d: Rect2 = seg[2]
		_wall("wall", "cream_base", eo, sx, en, float(seg[0]), float(seg[1]), WALL_BOTTOM_Y, B + H_PLINTH, [d])
		_wall("wall", "cream", eo, sx, en, float(seg[0]), float(seg[1]), B + H_PLINTH, low, [d])
		_door("cream", "door", eo, sx, en, d, 0.14, 0.12)
	ground_contacts.append({"id": "east-low-door-s", "a": 1.4, "b": east_b, "bottom_y": ed1.position.y, "land_y": eg1})
	ground_contacts.append({"id": "east-low-door-n", "a": 13.8, "b": east_b, "bottom_y": ed2.position.y, "land_y": eg2})
	# Step walls rising from the low roofs to the high passage roof.
	_wall("wall", "cream", Vector3(A_FRAME0, 0, 0), sz, Vector3(-1, 0, 0), FRAME_BACK_B, W - 0.656, B + H_LOW_ROOF, B + H_HI_PARAPET, [])
	_wall("wall", "cream", Vector3(A_FRAME1, 0, 0), sz, Vector3(1, 0, 0), FRAME_BACK_B, W - 0.656, B + H_LOW_ROOF, B + H_HI_PARAPET, [])
	# Main bar south end above the north low block, and the low block's north wall under the walkway.
	_wall("wall", "cream", Vector3(A_MAIN, 0, 0), sz, Vector3(-1, 0, 0), WEST_FACE_B, EAST_WALL_B, B + H_LOW_ROOF, B + H_PARAPET, [])
	_wall("wall", "cream", Vector3(A_MAIN, 0, 0), sz, Vector3(1, 0, 0), EAST_WALL_B, east_b, WALL_BOTTOM_Y, low, [])


func _arch_centre() -> Vector2:
	return Vector2((A_OPEN0 + A_OPEN1) * 0.5, B + H_CROWN - _arch_radius())


func _arch_radius() -> float:
	var half := (A_OPEN1 - A_OPEN0) * 0.5
	var rise := H_CROWN - H_SPRING
	return (half * half + rise * rise) / (2.0 * rise)


func _arch_points(segments: int, extra := 0.0) -> Array:
	var r := _arch_radius()
	var half := (A_OPEN1 - A_OPEN0) * 0.5
	var c := _arch_centre()
	var t0 := asin(half / r)
	var out: Array = []
	for i in segments + 1:
		var th := -t0 + 2.0 * t0 * float(i) / segments
		out.append(Vector2(c.x + (r + extra) * sin(th), c.y + (r + extra) * cos(th)))
	if extra == 0.0:
		out[0] = Vector2(A_OPEN0, B + H_SPRING)
		out[segments] = Vector2(A_OPEN1, B + H_SPRING)
	return out


## Tall square portal frame with narrow jambs and a segmental arch that nearly
## fills it: maroon on Avenue M (Sep 2025), cream on the yard side (2019 state).
func _build_portal_frame(west: bool) -> void:
	var mat := "maroon" if west else "cream"
	var front := FRAME_FRONT_B if west else W - 0.056
	var back := FRAME_BACK_B if west else W - 0.656
	var out := Vector3(0, 0, -1) if west else Vector3(0, 0, 1)
	var top := B + H_FRAME_TOP
	var arch := _arch_points(28)
	var spring := B + H_SPRING
	var deck_y := B + H_DECK
	var centre := _arch_centre()
	for pair: Array in [[A_FRAME0, A_OPEN0], [A_OPEN1, A_FRAME1]]:
		var s0: float = pair[0]
		var s1: float = pair[1]
		_quad("wall", mat, Vector3(s0, WALL_BOTTOM_Y, front), Vector3(s1, WALL_BOTTOM_Y, front), Vector3(s1, top, front), Vector3(s0, top, front), out)
	for i in arch.size() - 1:
		var p: Vector2 = arch[i]
		var q: Vector2 = arch[i + 1]
		_quad("wall", mat, Vector3(p.x, p.y, front), Vector3(q.x, q.y, front), Vector3(q.x, top, front), Vector3(p.x, top, front), out)
		_quad("wall", mat, Vector3(p.x, p.y, back), Vector3(q.x, q.y, back), Vector3(q.x, deck_y, back), Vector3(p.x, deck_y, back), -out)
		var inward := (centre - (p + q) * 0.5).normalized()
		_quad("wall", mat, Vector3(p.x, p.y, front), Vector3(q.x, q.y, front), Vector3(q.x, q.y, back), Vector3(p.x, p.y, back), Vector3(inward.x, inward.y, 0))
	# Back face above the high passage roof and over the jamb rooms.
	_quad("wall", mat, Vector3(A_FRAME0, B + H_HI_ROOF, back), Vector3(A_FRAME1, B + H_HI_ROOF, back), Vector3(A_FRAME1, top, back), Vector3(A_FRAME0, top, back), -out)
	_quad("wall", mat, Vector3(A_OPEN0, WALL_BOTTOM_Y, front), Vector3(A_OPEN0, WALL_BOTTOM_Y, back), Vector3(A_OPEN0, spring, back), Vector3(A_OPEN0, spring, front), Vector3(1, 0, 0))
	_quad("wall", mat, Vector3(A_OPEN1, WALL_BOTTOM_Y, front), Vector3(A_OPEN1, WALL_BOTTOM_Y, back), Vector3(A_OPEN1, spring, back), Vector3(A_OPEN1, spring, front), Vector3(-1, 0, 0))
	_quad("wall", mat, Vector3(A_FRAME0, top, front), Vector3(A_FRAME1, top, front), Vector3(A_FRAME1, top, back), Vector3(A_FRAME0, top, back), Vector3.UP)
	for e: Array in [[A_FRAME0, Vector3(-1, 0, 0)], [A_FRAME1, Vector3(1, 0, 0)]]:
		var a: float = e[0]
		_quad("wall", mat, Vector3(a, WALL_BOTTOM_Y, front), Vector3(a, WALL_BOTTOM_Y, back), Vector3(a, top, back), Vector3(a, top, front), e[1])
	var zmin := minf(front, back)
	var zmax := maxf(front, back)
	_abox("detail", "coping", Vector3(A_FRAME0, top, zmin), Vector3(A_FRAME1, top + COPING_H, zmax), 4)
	if not west:
		_arch_ring(front, out, 0.04, 0.32, "east_ring")


## Proud architrave following the arch and down both jambs (east arch reveal, r15).
func _arch_ring(front: float, out: Vector3, proud: float, width: float, mat: String) -> void:
	var inner := _arch_points(28)
	var outer := _arch_points(28, width)
	var f := front + out.z * proud
	var spring := B + H_SPRING
	var t0 := asin((A_OPEN1 - A_OPEN0) * 0.5 / _arch_radius())
	var wj := width * sin(t0)
	var centre := _arch_centre()
	for i in inner.size() - 1:
		var p: Vector2 = inner[i]
		var q: Vector2 = inner[i + 1]
		var po: Vector2 = outer[i]
		var qo: Vector2 = outer[i + 1]
		_quad("wall", mat, Vector3(p.x, p.y, f), Vector3(q.x, q.y, f), Vector3(qo.x, qo.y, f), Vector3(po.x, po.y, f), out)
		var ri := (centre - (p + q) * 0.5).normalized()
		_quad("wall", mat, Vector3(p.x, p.y, front), Vector3(q.x, q.y, front), Vector3(q.x, q.y, f), Vector3(p.x, p.y, f), Vector3(ri.x, ri.y, 0))
		_quad("wall", mat, Vector3(po.x, po.y, front), Vector3(qo.x, qo.y, front), Vector3(qo.x, qo.y, f), Vector3(po.x, po.y, f), Vector3(-ri.x, -ri.y, 0))
	for side: Array in [[A_OPEN0, -1.0, outer[0]], [A_OPEN1, 1.0, outer[outer.size() - 1]]]:
		var jx: float = side[0]
		var sgn: float = side[1]
		var oq: Vector2 = side[2]
		var xo := jx + sgn * wj
		_quad("wall", mat, Vector3(xo, WALL_BOTTOM_Y, f), Vector3(jx, WALL_BOTTOM_Y, f), Vector3(jx, spring, f), Vector3(xo, spring, f), out)
		_s("wall", mat).tri(Vector3(xo, spring, f), Vector3(jx, spring, f), Vector3(oq.x, oq.y, f), out)
		_quad("wall", mat, Vector3(xo, WALL_BOTTOM_Y, front), Vector3(xo, oq.y, front), Vector3(xo, oq.y, f), Vector3(xo, WALL_BOTTOM_Y, f), Vector3(sgn, 0, 0))
		_quad("wall", mat, Vector3(jx, WALL_BOTTOM_Y, front), Vector3(jx, spring, front), Vector3(jx, spring, f), Vector3(jx, WALL_BOTTOM_Y, f), Vector3(-sgn, 0, 0))


func _build_passage() -> void:
	var b0 := FRAME_BACK_B
	var b1 := W - 0.656
	var deck_y := B + H_DECK
	var sdir := Vector3(0, 0, 1)
	# North side: doors and multi-light windows (r15 left side).
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
	# South side near the west entrance: deep breeze-block screen, high-contrast
	# near-square cells readable from Avenue M (r08/r15), then a door and window.
	var so := Vector3(A_OPEN0, 0, 0)
	var sn := Vector3(1, 0, 0)
	var cells: Array = []
	var pitch := 0.42
	var cell := 0.32
	for row in 5:
		for col in 14:
			cells.append(Rect2(1.0 + pitch * col + (pitch - cell) * 0.5, B + 0.62 + pitch * row + (pitch - cell) * 0.5, cell, cell))
	var sd := Rect2(11.6, land_y(A_OPEN0, 12.1) + 0.02, 1.0, 2.15)
	var sw := Rect2(13.8, B + 1.2, 1.3, 1.1)
	var south_holes := cells.duplicate()
	south_holes.append(sd)
	south_holes.append(sw)
	_wall("wall", "cream_base", so, sdir, sn, b0, b1, WALL_BOTTOM_Y, B + 0.45, south_holes)
	_wall("wall", "cream", so, sdir, sn, b0, b1, B + 0.45, deck_y, south_holes)
	for c: Rect2 in cells:
		_reveals("cell_side", so, sdir, sn, c, 0.20, true)
		_quad("wall", "cell_dark", _wp(so, sdir, sn, c.position.x, c.position.y, 0.20), _wp(so, sdir, sn, c.end.x, c.position.y, 0.20), _wp(so, sdir, sn, c.end.x, c.end.y, 0.20), _wp(so, sdir, sn, c.position.x, c.end.y, 0.20), sn)
	_door("cream", "door", so, sdir, sn, sd)
	_window("cream", so, sdir, sn, sw, 1, 0.0)
	ground_contacts.append({"id": "passage-south-door", "a": A_OPEN0, "b": 12.1, "bottom_y": sd.position.y, "land_y": sd.position.y - 0.02})
	# Prominent round SFFD badge high on the screen wall (visual only).
	_cyl("visual", "badge_white", Vector3(A_OPEN0, B + 3.40, 3.17), Vector3(1, 0, 0), 0.44, 0.03, 24)
	_cyl("visual", "badge_red", Vector3(A_OPEN0 + 0.03, B + 3.40, 3.17), Vector3(1, 0, 0), 0.36, 0.015, 24)
	_cyl("visual", "badge_white", Vector3(A_OPEN0 + 0.045, B + 3.40, 3.17), Vector3(1, 0, 0), 0.13, 0.008, 16)
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
			_drape("visual", "concrete", a0, a1, c0, c1, 0.065)
	# Six grey bollards (reduced from r08's eight for the narrower opening) with a 0.88 m centre gap.
	for off: float in [-2.75, -1.65, -0.55, 0.55, 1.65, 2.75]:
		var ba := (A_OPEN0 + A_OPEN1) * 0.5 + off
		var bb := 1.0
		var g := land_y(ba, bb)
		_cyl("detail", "bollard", Vector3(ba, g - 0.10, bb), Vector3.UP, 0.11, 1.03, 12, false)
		_cyl("detail", "bollard_cap", Vector3(ba, g + 0.93, bb), Vector3.UP, 0.115, 0.07, 12, true)
		ground_contacts.append({"id": "bollard-%.2f" % ba, "a": ba, "b": bb, "bottom_y": g - 0.10, "land_y": g, "top_y": g + 1.0})


func _drape(role: String, mat: String, a0: float, a1: float, c0: float, c1: float, lift: float) -> void:
	var p00 := Vector3(a0, land_y(a0, c0) + lift, c0)
	var p10 := Vector3(a1, land_y(a1, c0) + lift, c0)
	var p11 := Vector3(a1, land_y(a1, c1) + lift, c1)
	var p01 := Vector3(a0, land_y(a0, c1) + lift, c1)
	var up1 := (p10 - p00).cross(p11 - p00).normalized()
	if up1.y < 0.0: up1 = -up1
	_s(role, mat).tri(p00, p10, p11, up1)
	var up2 := (p11 - p00).cross(p01 - p00).normalized()
	if up2.y < 0.0: up2 = -up2
	_s(role, mat).tri(p00, p11, p01, up2)


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
	return A_MAIN + (PORCH_A - A_MAIN) * (float(i) + 0.5) / BAY_COUNT


func _bay_width() -> float:
	return (PORCH_A - A_MAIN) / BAY_COUNT


func _build_main_bar() -> void:
	var bw := _bay_width()
	# West (Avenue M) face: pilastered bays, high windows and multi-light lower windows.
	var wo := Vector3(0, 0, WEST_FACE_B)
	var sdir := Vector3(1, 0, 0)
	var wn := Vector3(0, 0, -1)
	# Lower rhythm is production_inference (west cadence hidden by trees); two doors only.
	var pattern := ["WW", "WW", "W", "W", "WW", "DW", "WW", "W", "WW", "WW", "DW", "WW", "W", "WW"]
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
	_wall("wall", "plinth", wo, sdir, wn, A_MAIN, PORCH_A, WALL_BOTTOM_Y, B + H_PLINTH, holes)
	_wall("wall", "cream", wo, sdir, wn, A_MAIN, PORCH_A, B + H_PLINTH, B + H_PARAPET, holes)
	for r: Rect2 in windows:
		_window("cream", wo, sdir, wn, r, 2, 0.55)
	for d: Rect2 in doors:
		_door("cream", "door", wo, sdir, wn, d)
		west_door_centres.append(d.get_center().x)
	for i in BAY_COUNT:
		var ac := _bay_centre(i)
		for off: float in [-1.35, 1.35]:
			_window("cream", wo, sdir, wn, Rect2(ac + off - 0.40, B + H_HIGH_LO, 0.80, H_HIGH_HI - H_HIGH_LO), 1, 0.0, 0.18, false)
	# Plinth cap ledge (r08 textured base under the windows), broken at doors.
	var cur := A_MAIN
	for d: Rect2 in doors:
		_wbox("wall", "sill", wo, sdir, wn, cur, d.position.x, B + H_PLINTH - 0.04, B + H_PLINTH, -0.03, 0.0)
		cur = d.end.x
	_wbox("wall", "sill", wo, sdir, wn, cur, PORCH_A, B + H_PLINTH - 0.04, B + H_PLINTH, -0.03, 0.0)
	# Pilasters at bay lines with a deeper shadow edge (r12 joints).
	for k in range(1, BAY_COUNT):
		var ap := A_MAIN + bw * k
		_wbox("wall", "cream", wo, sdir, wn, ap - 0.20, ap + 0.20, WALL_BOTTOM_Y, B + H_PARAPET, -0.09, 0.0, 32 | 8)
	# Shadow reglet under the coping (visual only, 4 mm proud).
	_quad("visual", "reglet", Vector3(A_MAIN, B + H_PARAPET - 0.07, WEST_FACE_B - 0.004), Vector3(PORCH_A, B + H_PARAPET - 0.07, WEST_FACE_B - 0.004), Vector3(PORCH_A, B + H_PARAPET, WEST_FACE_B - 0.004), Vector3(A_MAIN, B + H_PARAPET, WEST_FACE_B - 0.004), Vector3(0, 0, -1))
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
	_door("bluegrey", "door_teal", no, ndir, nn, nd, 0.14, 0.0)
	_quad("visual", "reglet", Vector3(L - 0.046, B + H_PARAPET - 0.07, PORCH_B), Vector3(L - 0.046, B + H_PARAPET - 0.07, EAST_WALL_B), Vector3(L - 0.046, B + H_PARAPET, EAST_WALL_B), Vector3(L - 0.046, B + H_PARAPET, PORCH_B), Vector3(1, 0, 0))
	ground_contacts.append({"id": "north-door", "a": L - 0.05, "b": 12.05, "bottom_y": nd.position.y, "land_y": nd.position.y - 0.02})
	# East (yard) face under the walkway: varied doors, windows, double doors and vents (inference).
	var eo := Vector3(0, 0, EAST_WALL_B)
	var en := Vector3(0, 0, 1)
	var epattern := ["DW", "WW", "L", "DW", "W", "WW", "DD", "W", "WW", "DW", "L", "WW", "D", "WW", "D"]
	var eholes: Array = []
	var ewin: Array = []
	var edoor: Array = []
	var elouver: Array = []
	for i in epattern.size():
		var ac := _bay_centre(i) if i < BAY_COUNT else (PORCH_A + L) * 0.5
		if i < BAY_COUNT:
			for off: float in [-1.35, 1.35]:
				eholes.append(Rect2(ac + off - 0.40, B + H_HIGH_LO, 0.80, H_HIGH_HI - H_HIGH_LO))
		var kind: String = epattern[i]
		var items: Array = []
		match kind:
			"DW": items = [["D", ac - 1.4, 1.0], ["W", ac + 1.2]]
			"WW": items = [["W", ac - 1.4], ["W", ac + 1.4]]
			"W": items = [["W", ac]]
			"L": items = [["L", ac - 1.2], ["W", ac + 1.3]]
			"DD": items = [["D", ac, 1.8]]
			"D": items = [["D", ac - 0.4, 1.0]]
		for it: Array in items:
			if it[0] == "W":
				var r := Rect2(float(it[1]) - 0.65, B + H_SILL, 1.3, 1.35)
				eholes.append(r)
				ewin.append(r)
			elif it[0] == "L":
				var r2 := Rect2(float(it[1]) - 0.6, B + 1.2, 1.2, 1.0)
				eholes.append(r2)
				elouver.append(r2)
			else:
				var wdt: float = it[2]
				var g := land_y(float(it[1]), EAST_WALL_B + 0.05)
				var d := Rect2(float(it[1]) - wdt * 0.5, g + 0.02, wdt, 2.15)
				eholes.append(d)
				edoor.append(d)
				ground_contacts.append({"id": "east-door-bay-%d" % i, "a": float(it[1]), "b": EAST_WALL_B, "bottom_y": d.position.y, "land_y": g})
	_wall("wall", "cream_base", eo, sdir, en, A_MAIN, L - 0.05, WALL_BOTTOM_Y, B + 0.55, eholes)
	_wall("wall", "cream", eo, sdir, en, A_MAIN, L - 0.05, B + 0.55, B + H_PARAPET, eholes)
	for r: Rect2 in ewin:
		_window("cream", eo, sdir, en, r, 2, 0.45)
	for d: Rect2 in edoor:
		_door("cream", "door", eo, sdir, en, d)
	for r: Rect2 in elouver:
		_louver("cream", eo, sdir, en, r)
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
	var a_start := A_MAIN + 0.15
	# South end fascia closes the walkway above the low north block.
	_abox("wall", "north_cream", Vector3(A_MAIN, y_f0, EAST_WALL_B), Vector3(a_start, y_f1, front), 16)
	_abox("wall", "north_cream", Vector3(a_start, y_f0, fascia_back), Vector3(L - 0.20, y_f1, front), 1 | 2)
	_abox("wall", "north_cream", Vector3(L - 0.20, y_f0, EAST_WALL_B), Vector3(L - 0.05, y_f1, front), 16)
	_quad("roof", "walk_soffit", Vector3(a_start, y_soffit, EAST_WALL_B), Vector3(L - 0.20, y_soffit, EAST_WALL_B), Vector3(L - 0.20, y_soffit, fascia_back), Vector3(a_start, y_soffit, fascia_back), Vector3.DOWN)
	_quad("roof", "walk_roof", Vector3(a_start, y_top, EAST_WALL_B), Vector3(L - 0.20, y_top, EAST_WALL_B), Vector3(L - 0.20, y_top, fascia_back), Vector3(a_start, y_top, fascia_back), Vector3.UP)
	# Light-painted steel posts on actual land, aligned with the bays.
	var post_b := W - 0.30
	var posts: Array = []
	for k in range(1, BAY_COUNT + 1):
		posts.append(A_MAIN + _bay_width() * k)
	posts.append(L - 0.40)
	for ap: float in posts:
		var g := land_y(ap, post_b)
		_abox("detail", "post_light", Vector3(ap - 0.075, g - 0.10, post_b - 0.075), Vector3(ap + 0.075, y_soffit, post_b + 0.075), 4 | 8)
		_abox("detail", "post_light", Vector3(ap - 0.15, g - 0.10, post_b - 0.15), Vector3(ap + 0.15, g + 0.02, post_b + 0.15), 4)
		ground_contacts.append({"id": "walkway-post-%.2f" % ap, "a": ap, "b": post_b, "bottom_y": g - 0.10, "land_y": g, "top_y": y_soffit})


func _build_roofs() -> void:
	var ry := B + H_ROOF
	var py := B + H_PARAPET
	var cy := py + COPING_H
	var e := L - EDGE_INSET
	# Main bar membrane (L-shaped around the NW porch step).
	_quad("roof", "roof_light", Vector3(A_MAIN + 0.25, ry, 0.60), Vector3(PORCH_A - 0.25, ry, 0.60), Vector3(PORCH_A - 0.25, ry, EAST_WALL_B - 0.25), Vector3(A_MAIN + 0.25, ry, EAST_WALL_B - 0.25), Vector3.UP)
	_quad("roof", "roof_light", Vector3(PORCH_A - 0.25, ry, PORCH_B + 0.25), Vector3(L - 0.30, ry, PORCH_B + 0.25), Vector3(L - 0.30, ry, EAST_WALL_B - 0.25), Vector3(PORCH_A - 0.25, ry, EAST_WALL_B - 0.25), Vector3.UP)
	_iface(Vector3(A_MAIN + 0.25, 0, 0.60), Vector3(PORCH_A - 0.25, 0, 0.60), Vector3(0, 0, 1), ry, py)
	_iface(Vector3(PORCH_A - 0.25, 0, 0.60), Vector3(PORCH_A - 0.25, 0, PORCH_B + 0.25), Vector3(-1, 0, 0), ry, py)
	_iface(Vector3(PORCH_A - 0.25, 0, PORCH_B + 0.25), Vector3(L - 0.30, 0, PORCH_B + 0.25), Vector3(0, 0, 1), ry, py)
	_iface(Vector3(L - 0.30, 0, PORCH_B + 0.25), Vector3(L - 0.30, 0, EAST_WALL_B - 0.25), Vector3(-1, 0, 0), ry, py)
	_iface(Vector3(A_MAIN + 0.25, 0, EAST_WALL_B - 0.25), Vector3(L - 0.30, 0, EAST_WALL_B - 0.25), Vector3(0, 0, -1), ry, py)
	_iface(Vector3(A_MAIN + 0.25, 0, 0.60), Vector3(A_MAIN + 0.25, 0, EAST_WALL_B - 0.25), Vector3(1, 0, 0), ry, py)
	# Main bar copings (deeper cap, overhang throws a shadow line); north edge inset from the OSM polygon.
	_abox("roof", "coping", Vector3(A_MAIN - 0.05, py, 0.24), Vector3(PORCH_A + 0.05, cy, 0.65), 4)
	_abox("roof", "coping", Vector3(PORCH_A - 0.30, py, 0.65), Vector3(PORCH_A + 0.05, cy, PORCH_B - 0.06), 4)
	_abox("roof", "coping", Vector3(PORCH_A - 0.30, py, PORCH_B - 0.06), Vector3(e, cy, PORCH_B + 0.30), 4)
	_abox("roof", "coping", Vector3(L - 0.35, py, PORCH_B + 0.30), Vector3(e, cy, EAST_WALL_B + 0.06), 4)
	_abox("roof", "coping", Vector3(A_MAIN - 0.05, py, EAST_WALL_B - 0.30), Vector3(L - 0.35, cy, EAST_WALL_B + 0.06), 4)
	_abox("roof", "coping", Vector3(A_MAIN - 0.05, py, 0.65), Vector3(A_MAIN + 0.30, cy, EAST_WALL_B - 0.30), 4)
	# High passage roof between the step walls and the two frames.
	var hy := B + H_HI_ROOF
	_quad("roof", "roof_dark", Vector3(A_FRAME0 + 0.25, hy, FRAME_BACK_B), Vector3(A_FRAME1 - 0.25, hy, FRAME_BACK_B), Vector3(A_FRAME1 - 0.25, hy, W - 0.656), Vector3(A_FRAME0 + 0.25, hy, W - 0.656), Vector3.UP)
	var hp := B + H_HI_PARAPET
	_iface(Vector3(A_FRAME0 + 0.25, 0, FRAME_BACK_B), Vector3(A_FRAME0 + 0.25, 0, W - 0.656), Vector3(1, 0, 0), hy, hp)
	_iface(Vector3(A_FRAME1 - 0.25, 0, FRAME_BACK_B), Vector3(A_FRAME1 - 0.25, 0, W - 0.656), Vector3(-1, 0, 0), hy, hp)
	_abox("roof", "coping", Vector3(A_FRAME0 - 0.05, hp, FRAME_BACK_B), Vector3(A_FRAME0 + 0.30, hp + COPING_H, W - 0.656), 4)
	_abox("roof", "coping", Vector3(A_FRAME1 - 0.30, hp, FRAME_BACK_B), Vector3(A_FRAME1 + 0.05, hp + COPING_H, W - 0.656), 4)
	# Low south and north blocks flanking the portal (darker roofs, r04).
	var ly := B + H_LOW_ROOF
	var lp := B + H_LOW
	var lc := lp + COPING_H
	var eb := W - 0.356
	var si := SOUTH_A + 0.25
	_quad("roof", "roof_dark", Vector3(si, ly, 0.60), Vector3(A_FRAME0, ly, 0.60), Vector3(A_FRAME0, ly, eb - 0.25), Vector3(si, ly, eb - 0.25), Vector3.UP)
	_iface(Vector3(si, 0, 0.60), Vector3(A_FRAME0, 0, 0.60), Vector3(0, 0, 1), ly, lp)
	_iface(Vector3(si, 0, 0.60), Vector3(si, 0, eb - 0.25), Vector3(1, 0, 0), ly, lp)
	_iface(Vector3(si, 0, eb - 0.25), Vector3(A_FRAME0, 0, eb - 0.25), Vector3(0, 0, -1), ly, lp)
	_abox("roof", "coping", Vector3(SOUTH_A - 0.05, lp, 0.30), Vector3(A_LOW_S0, lc, 0.65), 4)
	_abox("roof", "coping", Vector3(A_LOW_S0, lp, 0.01), Vector3(A_FRAME0, lc, 0.65), 4)
	_abox("roof", "coping", Vector3(SOUTH_A - 0.05, lp, 0.65), Vector3(si + 0.05, lc, eb - 0.30), 4)
	_abox("roof", "coping", Vector3(SOUTH_A - 0.05, lp, eb - 0.30), Vector3(A_FRAME0, lc, eb + 0.05), 4)
	_quad("roof", "roof_dark", Vector3(A_FRAME1, ly, 0.60), Vector3(A_MAIN, ly, 0.60), Vector3(A_MAIN, ly, EAST_WALL_B), Vector3(A_FRAME1, ly, EAST_WALL_B), Vector3.UP)
	_quad("roof", "roof_dark", Vector3(A_FRAME1, ly, EAST_WALL_B), Vector3(A_MAIN - 0.25, ly, EAST_WALL_B), Vector3(A_MAIN - 0.25, ly, eb - 0.25), Vector3(A_FRAME1, ly, eb - 0.25), Vector3.UP)
	_iface(Vector3(A_FRAME1, 0, 0.60), Vector3(A_MAIN, 0, 0.60), Vector3(0, 0, 1), ly, lp)
	_iface(Vector3(A_FRAME1, 0, eb - 0.25), Vector3(A_MAIN - 0.25, 0, eb - 0.25), Vector3(0, 0, -1), ly, lp)
	_iface(Vector3(A_MAIN - 0.25, 0, EAST_WALL_B), Vector3(A_MAIN - 0.25, 0, eb - 0.25), Vector3(-1, 0, 0), ly, lp)
	_iface(Vector3(A_MAIN - 0.25, 0, EAST_WALL_B), Vector3(A_MAIN, 0, EAST_WALL_B), Vector3(0, 0, -1), ly, lp)
	_abox("roof", "coping", Vector3(A_FRAME1, lp, 0.01), Vector3(A_MAIN, lc, 0.65), 4)
	_abox("roof", "coping", Vector3(A_FRAME1, lp, eb - 0.30), Vector3(A_MAIN, lc, eb + 0.05), 4)
	_abox("roof", "coping", Vector3(A_MAIN - 0.30, lp, EAST_WALL_B), Vector3(A_MAIN, lc, eb - 0.30), 4)
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
	_cyl("roof", "coping", Vector3(8.0, hy, 13.5), Vector3.UP, 0.12, 0.45, 10)


func _iface(p: Vector3, q: Vector3, inward: Vector3, y0: float, y1: float) -> void:
	_quad("roof", "parapet_inner", Vector3(p.x, y0, p.z), Vector3(q.x, y0, q.z), Vector3(q.x, y1, q.z), Vector3(p.x, y1, p.z), inward)


## Visual-only ground treatment on the school site area west of the building
## (r06/r07): concrete apron to the portal, mulch planting strip with edging.
func _build_setting() -> void:
	var apron_a0 := A_FRAME0 - 0.5
	var apron_a1 := A_FRAME1 + 0.5
	var apron_b0 := -12.5
	var step := 1.0
	var a := apron_a0
	while a < apron_a1 - 0.001:
		var a1 := minf(a + step, apron_a1)
		var b := apron_b0
		while b < FRAME_FRONT_B - 0.001:
			var b2 := minf(b + 1.25, FRAME_FRONT_B)
			_drape("setting", "concrete", a, a1, b, b2, 0.065)
			b = b2
		a = a1
	# The site-area surface begins about 1 m north of the OSM south corner.
	for span: Vector2 in [Vector2(1.5, apron_a0), Vector2(apron_a1, PORCH_A - 0.2)]:
		var x := span.x
		while x < span.y - 0.001:
			var x1 := minf(x + 2.0, span.y)
			var top_b := 0.0 if x1 <= A_MAIN else WEST_FACE_B - 0.05
			if x < A_MAIN and x1 > A_MAIN:
				x1 = A_MAIN
				top_b = 0.0
			_drape("setting", "mulch", x, x1, -3.0, top_b, 0.08)
			_drape("setting", "edging", x, x1, -3.15, -3.0, 0.09)
			x = x1
	# Concrete paths across the planting strip to the two west doors.
	for dc: float in west_door_centres:
		_drape("setting", "concrete", dc - 0.7, dc + 0.7, -3.15, WEST_FACE_B - 0.05, 0.095)


# ---------------------------------------------------------------- lettering

func _build_lettering() -> void:
	# "FIRE FIGHTING SCHOOL" follows the arch, cream on maroon (Sep 2025 state).
	var r_text := _arch_radius() + 0.30
	var centre := _arch_centre()
	var text := "FIRE FIGHTING SCHOOL"
	var font_size := 64
	var px := 0.0052
	var advances: Array[float] = []
	var total := 0.0
	for ch in text:
		var adv := _font.get_char_size(ch.unicode_at(0), font_size).x * px * 1.18
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
	# Small "600" at mid-height of the low north block (r08).
	_word("600", Vector3(13.8, B + 1.45, FRAME_FRONT_B - 0.016), Vector3(-1, 0, 0), Vector3(0, 0, -1), 64, 0.0045, "letter_cream")
	# Walkway north fascia lettering (r10 shows "...TRAINING...").
	_word("TRAINING", Vector3(L - 0.034, B + 2.72, (EAST_WALL_B + W - 0.056) * 0.5), Vector3(0, 0, -1), Vector3(1, 0, 0), 64, 0.0036, "letter_dark")


func _word(text: String, centre: Vector3, reading: Vector3, facing: Vector3, font_size: int, px: float, mat: String) -> void:
	var total := 0.0
	var advances: Array[float] = []
	for ch in text:
		var adv := _font.get_char_size(ch.unicode_at(0), font_size).x * px * 1.10
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


## Deterministic low-contrast stucco grain (multiplies a flat paint albedo).
func _grain_texture() -> ImageTexture:
	if _grain != null:
		return _grain
	var noise := FastNoiseLite.new()
	noise.seed = 600
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.045
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5
	var img := noise.get_seamless_image(256, 256)
	img.convert(Image.FORMAT_RGB8)
	for y in 256:
		for x in 256:
			var g := 0.93 + 0.07 * img.get_pixel(x, y).r
			img.set_pixel(x, y, Color(g, g, g))
	img.generate_mipmaps()
	_grain = ImageTexture.create_from_image(img)
	return _grain


func _material(key: String) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key]
	var m := StandardMaterial3D.new()
	m.resource_name = "b600_" + key
	m.roughness = 0.9
	# Painted stucco/concrete: flat warm albedo times a subtle grain plus normal relief.
	var relief := ""
	var grain := false
	var repeat := 1.5
	var relief_scale := 0.25
	match key:
		"cream":
			m.albedo_color = Color8(240, 214, 184)
			relief = "plaster_grey_04"
			grain = true
		"cream_base":
			m.albedo_color = Color8(226, 206, 178)
			relief = "plaster_grey_04"
			grain = true
		"plinth":
			m.albedo_color = Color8(234, 222, 198)
			relief = "concrete_floor_03"
			repeat = 0.8
			relief_scale = 0.9
			grain = true
		"maroon":
			m.albedo_color = Color8(112, 26, 34)
			relief = "plaster_grey_04"
			grain = true
		"bluegrey":
			m.albedo_color = Color8(172, 177, 178)
			m.roughness = 1.0
			relief = "plaster_grey_04"
			grain = true
		"north_cream":
			m.albedo_color = Color8(224, 204, 164)
			relief = "plaster_grey_04"
			grain = true
		"north_grey":
			m.albedo_color = Color8(196, 196, 190)
			relief = "plaster_grey_04"
			grain = true
		"east_ring":
			m.albedo_color = Color8(236, 228, 210)
			relief = "plaster_grey_04"
		"parapet_inner":
			m.albedo_color = Color8(206, 202, 192)
			relief = "plaster_grey_04"
		"reglet":
			m.albedo_color = Color8(118, 102, 82)
			m.roughness = 1.0
		"roof_light":
			m.albedo_color = Color8(226, 227, 223)
			relief = "concrete_floor_03"
			repeat = 4.0
			relief_scale = 0.3
		"roof_dark":
			m.albedo_color = Color8(96, 97, 95)
			relief = "bitumen"
			repeat = 6.0
		"walk_roof":
			m.albedo_color = Color8(158, 159, 155)
			relief = "bitumen"
			repeat = 6.0
		"roof_seam":
			m.albedo_color = Color8(208, 209, 205)
		"walk_soffit":
			m.albedo_color = Color8(214, 204, 182)
		"concrete":
			m.albedo_color = Color8(178, 176, 170)
			relief = "concrete_floor_03"
			repeat = 2.5
			relief_scale = 0.5
		"mulch":
			m.albedo_color = Color8(92, 70, 52)
			m.roughness = 1.0
			relief = "bitumen"
			repeat = 1.2
			relief_scale = 1.0
			grain = true
		"edging":
			m.albedo_color = Color8(206, 203, 196)
		"glass":
			m.albedo_color = Color8(132, 150, 162)
			m.metallic = 0.35
			m.roughness = 0.08
		"frame":
			m.albedo_color = Color8(104, 124, 140)
			m.metallic = 0.2
			m.roughness = 0.5
		"louver_back":
			m.albedo_color = Color8(48, 52, 56)
		"door":
			m.albedo_color = Color8(104, 122, 136)
			m.roughness = 0.55
		"door_teal":
			m.albedo_color = Color8(42, 132, 144)
			m.roughness = 0.5
		"sill":
			m.albedo_color = Color8(222, 214, 198)
		"coping":
			m.albedo_color = Color8(184, 186, 184)
			m.metallic = 0.3
			m.roughness = 0.45
		"hatch":
			m.albedo_color = Color8(196, 196, 190)
			m.metallic = 0.2
			m.roughness = 0.5
		"steel":
			m.albedo_color = Color8(92, 100, 108)
			m.metallic = 0.4
			m.roughness = 0.5
		"post_light":
			m.albedo_color = Color8(214, 212, 204)
			m.roughness = 0.6
		"deck":
			m.albedo_color = Color8(176, 180, 180)
			m.metallic = 0.2
			m.roughness = 0.65
		"bollard":
			m.albedo_color = Color8(124, 126, 126)
			m.roughness = 0.6
		"bollard_cap":
			m.albedo_color = Color8(228, 228, 222)
			m.roughness = 0.5
		"cell_side":
			m.albedo_color = Color8(132, 120, 102)
			m.roughness = 1.0
		"cell_dark":
			# Deep cells read dark against cream webs (high-contrast grid, r08).
			m.albedo_color = Color8(46, 42, 38)
			m.roughness = 1.0
		"fixture":
			m.albedo_color = Color8(70, 66, 60)
			m.roughness = 0.6
		"fixture_lens":
			m.albedo_color = Color8(232, 228, 210)
			m.roughness = 0.3
		"badge_red":
			m.albedo_color = Color8(176, 30, 34)
		"badge_white":
			m.albedo_color = Color8(236, 234, 228)
		"letter_cream":
			m.albedo_color = Color8(242, 232, 206)
			m.roughness = 0.6
		"letter_dark":
			m.albedo_color = Color8(52, 58, 64)
			m.roughness = 0.6
		_:
			m.albedo_color = Color(1, 0, 1)
	if grain:
		m.albedo_texture = _grain_texture()
	if not relief.is_empty():
		m.normal_enabled = true
		m.normal_texture = _texture("%s/%s_nor_gl_1k.jpg" % [relief, relief])
		m.normal_scale = relief_scale
		m.roughness_texture = _texture("%s/%s_rough_1k.jpg" % [relief, relief])
	if grain or not relief.is_empty():
		m.uv1_scale = Vector3(1.0 / repeat, 1.0 / repeat, 1.0)
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_materials[key] = m
	return m


func _commit() -> void:
	var names := {"wall": "WallMesh", "roof": "RoofMesh", "detail": "DetailMesh", "visual": "VisualMesh", "setting": "SettingMesh"}
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
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if role in ["visual", "setting"] else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
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
