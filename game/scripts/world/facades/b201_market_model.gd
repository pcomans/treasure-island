extends Node3D
## City Building 201 at 800 Avenue I (OSM w34313545): a long 1940s Navy storehouse,
## now self storage, a winery and Island Cove Market. Replaces the generated wall
## and roof; live through b201_market_live_replacement.gd.
##
## Footprint-local frame (derived from the exact generated roof record):
##   X = w: across the building, from the Avenue H (WSW) wall toward Avenue I (ENE),
##   Z = u: along it, from the NNW end toward 9th Street (SSE),
##   Y = world elevation (metres).
## Walls stay on the frozen OSM outline. Canopies, the market sign roof and its
## porch overhang that line, as the May 2026 aerial shows them doing, and the
## "setting" meshes (lot, sidewalk, bollards) lie outside it.
##
## Massing, Sep 2025 and Mar 2025 Street View and the May 2026 aerial: a low front
## bay, a main block, a raised central monitor with a dark roof, a second main block
## and a lower east block. Tier heights, bays and openings are production_inference
## fitted from those photos through matched cameras, not surveyed. The ENE middle and
## south walls and the NNW lower wall have no dated photo: they keep their old openings
## (d1_inferred_openings.gd) and only take the side's plain paint.

const ASSEMBLY := preload("res://game/scripts/world/facades/facade_assembly.gd")
const SUPPORT := preload("res://game/scripts/world/facades/housing_quality_support.gd")
const INFERRED := preload("res://game/scripts/world/facades/d1_inferred_openings.gd")

const SOURCE_KEY := "w34313545"
const WALL_KEY := "building:w34313545:wall"
const ROOF_KEY := "building:w34313545:roof"
const LAND_CHUNKS := ["res://generated/world/chunks/x_0__z_-2.json", "res://generated/world/chunks/x_0__z_-1.json"]
const OPENINGS_PATH := "res://game/resources/facades/b201_unphotographed_openings.json"
const D1_MATERIALS := "res://game/resources/materials/world/d1_current/"
const TEX := "res://game/resources/textures/world/b201/"
const POLYHAVEN := "res://game/resources/textures/world/polyhaven/"
const ROLES := ["wall", "roof", "detail", "trim", "glow", "setting", "walk"]

## The OSM outline as (w, u), in roof-record order; checked against the record.
const PLAN: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.0, 115.52), Vector2(68.23, 115.52), Vector2(68.23, 94.41), Vector2(65.12, 94.41), Vector2(65.12, 80.165), Vector2(67.9, 80.165), Vector2(67.9, 70.66), Vector2(71.98, 70.66), Vector2(71.98, 59.99), Vector2(86.75, 59.99), Vector2(86.75, 36.495), Vector2(84.075, 36.495), Vector2(84.075, 0.0)]
const PLAN_TOLERANCE_M := 0.05
const U_S := 115.52
const W_F := 86.75
const W_E := 84.075
const U_E := 36.495
const U_F := 59.99

# Tiers across the building (aerial strips, refs 10/12/13/18).
const W_T2 := 8.8
const W_MON0 := 23.5
const W_MON1 := 31.5
const W_C := 45.3
const W_D := 70.0
const U_D := 112.3
# Heights, world elevation; grade is about 3.3 (refs 10/12 through fitted cameras).
const Y_FOOT := 2.8
const Y_T1 := 7.8
const Y_T2 := 9.9
const Y_MON := 12.0
const Y_D := 8.402
const Y_E := 9.2
const Y_F := 7.8
const Y_S := 7.95
const CAP_DROP := 0.16
# WSW front: the canopy and the upper band of window pairs (refs 26, 09).
const Y_SPLIT := 6.0
const Y_CANOPY_LOW := 5.62
const Y_CANOPY_TOP := 6.12
const CANOPY_W := -2.25
const CANOPY_U0 := 24.9
const CANOPY_GREEN_U := 70.4
const POST_FIRST_U := 27.7
const POST_PITCH_M := 4.03
const Y_BAND_SILL := 6.32
const Y_BAND_HEAD := 7.16
const WSW_PAIRS := [[48.5, 50.7], [52.1, 54.3], [55.5, 57.7], [58.9, 61.2], [71.7, 74.0], [78.3, 80.5], [81.7, 83.9], [85.2, 87.4], [96.8, 99.0], [100.7, 103.0], [104.1, 106.3], [107.6, 109.7]]
const WSW_SINGLES := [[75.8, 76.9]]
const WSW_LOUVRES := [[63.1, 64.2], [88.9, 90.0]]
const WSW_BLANKS := [[67.1, 69.3], [92.2, 94.4]]
# Market (refs 02, 06, 07, 25): sign roof, porch and storefront. The sign eave and its
# hips sit where the photos and aerial put them; the storefront stays on the OSM wall.
const SIGN_U0 := 6.0
const SIGN_U1 := 24.9
const SIGN_TOP_U0 := 7.6
const SIGN_TOP_U1 := 23.4
const SIGN_W_EAVE := -5.0
const SIGN_W_TOP := -3.7
const SIGN_W_BACK := 0.8
const Y_FASCIA_LOW := 5.84
const Y_EAVE := 6.2
const Y_SIGN_TOP := 8.95
const Y_SIGN_CAP := 9.28
const Y_SOFFIT := 5.9
const RIB_PITCH_M := 0.6
const ORANGE_U0 := 8.2
const STORE_U0 := 13.6
const STORE_U1 := 25.8
const PLUM_U1 := 40.6
const TAGS_U1 := 43.5
const Y_STORE_HEAD := 5.82
# SSE (refs 10, 12, 13): tall sash pairs, the storage lettering, the winery canopy.
const SSE_PAIRS := [[8.42, 10.5], [12.9, 15.0], [16.05, 18.2], [20.6, 22.75], [23.9, 26.05], [28.2, 30.4], [31.5, 33.7]]
const Y_SASH_SILL := 4.5
const Y_SASH_HEAD := 7.55
const SSE_CANOPY_W0 := 37.0
const SSE_CANOPY_U := 118.9
const Y_SSE_FASCIA_LOW := 7.42
const Y_SSE_FASCIA_TOP := 7.74
const SSE_POSTS := [37.4, 48.3, 58.3, 65.2]
# ENE north (refs 15, 20, 21): low eaved block, tall block under a black band.
const Y_BAND_LOW := 7.15
# Bollards along the market sidewalk (refs 06, 25).
const SIDEWALK_W := -7.4
const SIDEWALK_U0 := -8.0
const SIDEWALK_U1 := 30.0
const BOLLARD_W := -5.9
const BOLLARD_FIRST_U := 7.0
const BOLLARD_PITCH_M := 2.05
const BOLLARD_COUNT := 9
const SIDEWALK_LIFT := 0.1
const LOT_LIFT := 0.03

## Painted and plain surfaces: [[r, g, b] sRGB bytes, roughness, tile texture or "", tile metres].
const PAINTS := {
	"cream": [[216, 201, 164], 0.9, "stucco", 3.0],
	"sand": [[205, 186, 142], 0.9, "stucco", 3.0],
	"tan": [[199, 170, 122], 0.9, "stucco", 3.0],
	"white": [[240, 237, 228], 0.88, "stucco", 3.0],
	"grey": [[143, 152, 153], 0.9, "stucco", 3.0],
	"sky_blue": [[170, 193, 212], 0.9, "stucco", 3.0],
	"upper_grey": [[150, 155, 163], 0.8, "stucco", 3.0],
	"orange": [[222, 142, 28], 0.85, "stucco", 3.0],
	"plum": [[92, 62, 68], 0.92, "stucco", 2.0],
	"tags": [[150, 146, 140], 0.9, "stucco", 2.0],
	"rust": [[141, 86, 66], 0.8, "", 1.0],
	"lime": [[92, 186, 44], 0.7, "", 1.0],
	"maroon": [[142, 36, 50], 0.7, "", 1.0],
	"trim_red": [[124, 62, 50], 0.75, "", 1.0],
	"sign_tan": [[192, 170, 140], 0.72, "metal", 2.5],
	"sign_rib": [[170, 148, 118], 0.65, "", 1.0],
	"coping": [[226, 222, 208], 0.8, "", 1.0],
	"coping_grey": [[160, 165, 165], 0.8, "", 1.0],
	"soffit": [[112, 100, 86], 0.9, "", 1.0],
	"frame_white": [[232, 230, 222], 0.6, "", 1.0],
	"frame_black": [[30, 30, 32], 0.5, "", 1.0],
	"frame_grey": [[124, 128, 130], 0.6, "", 1.0],
	"grey_frame": [[120, 128, 130], 0.7, "", 1.0],
	"door_white": [[226, 224, 216], 0.55, "", 1.0],
	"door_dark": [[44, 52, 50], 0.6, "", 1.0],
	"door_glass": [[28, 36, 40], 0.2, "", 1.0],
	"container_red": [[132, 56, 46], 0.7, "", 1.0],
	"door_black": [[24, 26, 28], 0.55, "", 1.0],
	"pane_pale": [[206, 208, 200], 0.32, "", 1.0],
	"pane_grey": [[120, 130, 132], 0.4, "", 1.0],
	"glass_clerestory": [[88, 98, 104], 0.25, "", 1.0],
	"glass_dark": [[26, 32, 36], 0.18, "", 1.0],
	"louvre_back": [[70, 70, 66], 0.9, "", 1.0],
	"band_black": [[34, 37, 42], 0.72, "", 1.0],
	"hood_grey": [[70, 74, 78], 0.6, "", 1.0],
	"yellow": [[226, 186, 72], 0.65, "", 1.0],
	"cage_white": [[226, 226, 222], 0.7, "", 1.0],
	"cage_tan": [[200, 190, 164], 0.8, "", 1.0],
	"mailbox": [[36, 76, 142], 0.5, "", 1.0],
	"plaque": [[150, 72, 44], 0.6, "", 1.0],
	"oval": [[214, 216, 214], 0.5, "", 1.0],
	"unit_grey": [[150, 152, 150], 0.7, "", 1.0],
	"vent_metal": [[165, 168, 170], 0.45, "", 1.0],
	"roof_white": [[236, 233, 224], 0.85, "membrane", 8.0],
	"roof_dark": [[112, 110, 100], 0.92, "membrane", 8.0],
	"roof_tan": [[190, 172, 142], 0.92, "membrane", 8.0],
	"bollard": [[140, 142, 138], 0.8, "", 1.0],
	"lot": [[150, 150, 146], 0.95, "asphalt", 4.0],
	"sidewalk": [[186, 183, 172], 0.92, "concrete", 3.0],
	"curb": [[170, 168, 158], 0.9, "", 1.0],
	"paint_white": [[222, 220, 210], 0.85, "", 1.0],
	"paint_yellow": [[226, 170, 40], 0.85, "", 1.0],
	"interior_floor": [[120, 118, 110], 0.4, "", 1.0],
}

var origin_world := Vector3.ZERO
var axis_w := Vector3.ZERO
var axis_u := Vector3.ZERO
var _land: Array = []
var _land_misses := 0
var _surfs: Dictionary = {}
var _materials: Dictionary = {}
var _textures: Dictionary = {}
var _walk_faces := PackedVector3Array()
var _problems: Array[String] = []


class Surf:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var uv := PackedVector2Array()
	var t := PackedFloat32Array()
	var idx := PackedInt32Array()

	## Adds a planar triangle or quad facing nn. uvs defaults to metres along the
	## surface, so tiled materials hold their scale on every face.
	func add(points: Array, nn: Vector3, uvs: Array = []) -> void:
		var hint := Vector3.UP if absf(nn.y) < 0.7 else Vector3(0, 0, 1)
		var tu := hint.cross(nn).normalized()
		var tv := nn.cross(tu).normalized()
		var base := v.size()
		for i in points.size():
			var p: Vector3 = points[i]
			v.append(p)
			n.append(nn)
			if uvs.is_empty():
				uv.append(Vector2(p.dot(tu), -p.dot(tv)))
			else:
				uv.append(uvs[i] as Vector2)
			t.append(tu.x)
			t.append(tu.y)
			t.append(tu.z)
			t.append(1.0)
		# Godot front faces are clockwise: (b-a)x(c-a) must point away from nn.
		var a: Vector3 = points[0]
		var b: Vector3 = points[1]
		var c: Vector3 = points[2]
		var flip := (b - a).cross(c - a).dot(nn) > 0.0
		for i in range(1, points.size() - 1):
			if flip:
				idx.append_array(PackedInt32Array([base, base + i + 1, base + i]))
			else:
				idx.append_array(PackedInt32Array([base, base + i, base + i + 1]))


## One wall plane: s runs along it, y is world height, d comes out of the wall.
class Face:
	var origin: Vector3
	var sdir: Vector3
	var nn: Vector3

	func _init(start: Vector3, along: Vector3, outward: Vector3) -> void:
		origin = start
		sdir = along
		nn = outward

	func at(s: float, y: float, d: float = 0.0) -> Vector3:
		return origin + sdir * s + Vector3.UP * y + nn * d


## Builds the model from the exact generated records. Fails closed on any change
## to the source footprint the design below was fitted to.
func build(roof_record: Dictionary, wall_record: Dictionary) -> Dictionary:
	name = "B201Market"
	if str(roof_record.get("object_key", "")) != ROOF_KEY or roof_record.get("source_keys", []) != [SOURCE_KEY]:
		return {"ok": false, "message": "Exact w34313545 roof record required."}
	if str(wall_record.get("object_key", "")) != WALL_KEY or wall_record.get("source_keys", []) != [SOURCE_KEY]:
		return {"ok": false, "message": "Exact w34313545 wall record required."}
	var rv: Array = roof_record.vertices
	if rv.size() != PLAN.size() * 3:
		return {"ok": false, "message": "B201 roof outline changed."}
	var first := Vector3(float(rv[0]), 0.0, float(rv[2]))
	var second := Vector3(float(rv[3]), 0.0, float(rv[5]))
	axis_u = (second - first).normalized()
	axis_w = Vector3(axis_u.z, 0.0, -axis_u.x)
	origin_world = first
	for i in PLAN.size():
		var p := Vector3(float(rv[i * 3]), 0.0, float(rv[i * 3 + 2])) - first
		if Vector2(p.dot(axis_w), p.dot(axis_u)).distance_to(PLAN[i]) > PLAN_TOLERANCE_M:
			return {"ok": false, "message": "B201 footprint no longer matches the fitted plan at vertex %d." % i}
	transform = Transform3D(Basis(axis_w, Vector3.UP, axis_u), origin_world)
	var land := SUPPORT.land_triangles(LAND_CHUNKS)
	if not bool(land.get("ok", false)):
		return {"ok": false, "message": str(land.get("message", "B201 land records missing."))}
	_keep_local_land(land.triangles as Array)
	for role: String in ROLES:
		_surfs[role] = {}
	_build_shell()
	_build_wsw()
	_build_market()
	_build_sse()
	_build_ene_north()
	_build_nnw()
	_build_monitor()
	_build_roof_gear()
	_build_setting()
	_commit()
	var openings := _unphotographed_openings(wall_record)
	if not bool(openings.get("ok", false)):
		return openings
	add_child(openings.node as Node3D)
	set_meta("source_keys", [SOURCE_KEY])
	set_meta("derived_object_key", WALL_KEY)
	if _land_misses > 0:
		return {"ok": false, "message": "%d B201 points fall outside the ground records." % _land_misses}
	if not _problems.is_empty():
		return {"ok": false, "message": "B201 assemblies failed: %s" % str(_problems)}
	return {"ok": true}


func _keep_local_land(triangles: Array) -> void:
	for triangle: Array in triangles:
		var near := false
		for corner: Vector3 in triangle:
			var p := corner - origin_world
			var w := p.dot(axis_w)
			var u := p.dot(axis_u)
			if w > -45.0 and w < 125.0 and u > -45.0 and u < 160.0:
				near = true
		if near:
			_land.append(triangle)


func _world(w: float, u: float) -> Vector2:
	var p := origin_world + axis_w * w + axis_u * u
	return Vector2(p.x, p.z)


func land_y(w: float, u: float) -> float:
	var y := SUPPORT.height_at(_world(w, u), _land)
	if y == -INF:
		_land_misses += 1
		return 3.3
	return y


func _p(w: float, y: float, u: float) -> Vector3:
	return Vector3(w, y, u)


# ---------------------------------------------------------------- primitives

func _s(role: String, mat: String) -> Surf:
	var group: Dictionary = _surfs[role]
	if not group.has(mat):
		group[mat] = Surf.new()
	return group[mat]


func _quad(role: String, mat: String, a: Vector3, b: Vector3, c: Vector3, d: Vector3, nn: Vector3, uvs: Array = []) -> void:
	_s(role, mat).add([a, b, c, d], nn, uvs)


## A polygon face whose normal comes from its points, flipped to agree with `toward`.
func _plane(role: String, mat: String, points: Array, toward: Vector3, uvs: Array = []) -> void:
	var a: Vector3 = points[0]
	var b: Vector3 = points[1]
	var c: Vector3 = points[2]
	var nn := (b - a).cross(c - a).normalized()
	if nn.dot(toward) < 0.0:
		nn = -nn
	_s(role, mat).add(points, nn, uvs)


## Axis-aligned box in the local frame. Skip bits: 1:-x 2:+x 4:-y 8:+y 16:-z 32:+z.
func _box(role: String, mat: String, lo: Vector3, hi: Vector3, skip: int = 0) -> void:
	var s := _s(role, mat)
	if not skip & 1:
		s.add([Vector3(lo.x, lo.y, lo.z), Vector3(lo.x, lo.y, hi.z), Vector3(lo.x, hi.y, hi.z), Vector3(lo.x, hi.y, lo.z)], Vector3.LEFT)
	if not skip & 2:
		s.add([Vector3(hi.x, lo.y, lo.z), Vector3(hi.x, lo.y, hi.z), Vector3(hi.x, hi.y, hi.z), Vector3(hi.x, hi.y, lo.z)], Vector3.RIGHT)
	if not skip & 4:
		s.add([Vector3(lo.x, lo.y, lo.z), Vector3(hi.x, lo.y, lo.z), Vector3(hi.x, lo.y, hi.z), Vector3(lo.x, lo.y, hi.z)], Vector3.DOWN)
	if not skip & 8:
		s.add([Vector3(lo.x, hi.y, lo.z), Vector3(hi.x, hi.y, lo.z), Vector3(hi.x, hi.y, hi.z), Vector3(lo.x, hi.y, hi.z)], Vector3.UP)
	if not skip & 16:
		s.add([Vector3(lo.x, lo.y, lo.z), Vector3(hi.x, lo.y, lo.z), Vector3(hi.x, hi.y, lo.z), Vector3(lo.x, hi.y, lo.z)], Vector3.FORWARD)
	if not skip & 32:
		s.add([Vector3(lo.x, lo.y, hi.z), Vector3(hi.x, lo.y, hi.z), Vector3(hi.x, hi.y, hi.z), Vector3(lo.x, hi.y, hi.z)], Vector3.BACK)


## Box on a face, s0..s1, y0..y1, d0..d1 out of the wall; no back.
func _fb(role: String, mat: String, f: Face, s0: float, s1: float, y0: float, y1: float, d0: float, d1: float) -> void:
	var s := _s(role, mat)
	s.add([f.at(s0, y0, d1), f.at(s1, y0, d1), f.at(s1, y1, d1), f.at(s0, y1, d1)], f.nn)
	s.add([f.at(s0, y0, d0), f.at(s0, y1, d0), f.at(s0, y1, d1), f.at(s0, y0, d1)], -f.sdir)
	s.add([f.at(s1, y0, d0), f.at(s1, y1, d0), f.at(s1, y1, d1), f.at(s1, y0, d1)], f.sdir)
	s.add([f.at(s0, y1, d0), f.at(s1, y1, d0), f.at(s1, y1, d1), f.at(s0, y1, d1)], Vector3.UP)
	s.add([f.at(s0, y0, d0), f.at(s1, y0, d0), f.at(s1, y0, d1), f.at(s0, y0, d1)], Vector3.DOWN)


func _cyl(role: String, mat: String, base: Vector3, radius: float, height: float, sides: int, top_radius: float = -1.0) -> void:
	var r1 := radius if top_radius < 0.0 else top_radius
	var top := base + Vector3.UP * height
	var s := _s(role, mat)
	for i in sides:
		var t0 := TAU * float(i) / sides
		var t1 := TAU * float(i + 1) / sides
		var d0 := Vector3(cos(t0), 0.0, sin(t0))
		var d1 := Vector3(cos(t1), 0.0, sin(t1))
		s.add([base + d0 * radius, base + d1 * radius, top + d1 * r1, top + d0 * r1], (d0 + d1).normalized())
		if r1 > 0.0:
			s.add([top, top + d0 * r1, top + d1 * r1], Vector3.UP)


## Planar wall face with rectangular holes (Rect2 in s, y).
func _wall(f: Face, mat: String, s0: float, s1: float, y0: float, y1: float, holes: Array = [], role: String = "wall") -> void:
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
				_s(role, mat).add([f.at(cur, ya), f.at(c.x, ya), f.at(c.x, yb), f.at(cur, yb)], f.nn)
			cur = maxf(cur, c.y)
		if s1 > cur + 0.0005:
			_s(role, mat).add([f.at(cur, ya), f.at(s1, ya), f.at(s1, yb), f.at(cur, yb)], f.nn)


func _reveals(f: Face, mat: String, r: Rect2, depth: float) -> void:
	var s0 := r.position.x
	var s1 := r.end.x
	var y0 := r.position.y
	var y1 := r.end.y
	var s := _s("wall", mat)
	s.add([f.at(s0, y0), f.at(s0, y1), f.at(s0, y1, -depth), f.at(s0, y0, -depth)], f.sdir)
	s.add([f.at(s1, y0), f.at(s1, y1), f.at(s1, y1, -depth), f.at(s1, y0, -depth)], -f.sdir)
	s.add([f.at(s0, y1), f.at(s1, y1), f.at(s1, y1, -depth), f.at(s0, y1, -depth)], Vector3.DOWN)
	s.add([f.at(s0, y0), f.at(s1, y0), f.at(s1, y0, -depth), f.at(s0, y0, -depth)], Vector3.UP)


## Shared window assemblies: panes stop the player, members are trim.
func _emit(f: Face, built: Dictionary) -> void:
	if not bool(built.ok):
		_problems.append(str(built.get("errors", [])))
		return
	for rect: Dictionary in built.rects:
		var role := "detail" if str(rect.role) == "pane" else "trim"
		_fb(role, str(rect.material), f, float(rect.u0), float(rect.u1), float(rect.y0), float(rect.y1), float(rect.d0), float(rect.d1))


## Two-light sash unit: recessed, painted frame, optional meeting rails, sill.
func _sash(f: Face, wall_mat: String, s0: float, s1: float, y0: float, y1: float, divisions: int, rails: Array, pane: String, frame: String, depth: float = 0.14, sill: bool = true) -> void:
	_reveals(f, wall_mat, Rect2(s0, y0, s1 - s0, y1 - y0), depth)
	_emit(f, ASSEMBLY.unit(s0, s1, y0, y1, {"pane_d": -depth, "member_d": 0.05, "frame_w": 0.07, "mullion_w": 0.09, "transom_w": 0.05, "divisions": divisions, "transoms": rails, "materials": {"pane": pane, "frame": frame, "mullion": frame, "transom": frame}}))
	if sill:
		_emit(f, ASSEMBLY.sill_band(s0, s1, y0, 0.07, 0.07, 0.06, {"materials": {"sill_band": frame}}))


func _louvre(f: Face, wall_mat: String, s0: float, s1: float, y0: float, y1: float) -> void:
	_reveals(f, wall_mat, Rect2(s0, y0, s1 - s0, y1 - y0), 0.1)
	_quad("detail", "louvre_back", f.at(s0, y0, -0.1), f.at(s1, y0, -0.1), f.at(s1, y1, -0.1), f.at(s0, y1, -0.1), f.nn)
	var y := y0 + 0.06
	while y < y1 - 0.05:
		_fb("trim", "frame_white", f, s0, s1, y, y + 0.05, -0.09, -0.02)
		y += 0.12


## A swing door: leaf recessed in the wall, thin frame, small lever.
func _door(f: Face, wall_mat: String, leaf: String, s0: float, s1: float, y0: float, y1: float, frame: String = "frame_white") -> void:
	var depth := 0.08
	_reveals(f, wall_mat, Rect2(s0, y0, s1 - s0, y1 - y0), depth)
	_quad("detail", leaf, f.at(s0, y0, -depth), f.at(s1, y0, -depth), f.at(s1, y1, -depth), f.at(s0, y1, -depth), f.nn)
	_fb("trim", frame, f, s0 - 0.06, s0, y0, y1 + 0.06, 0.0, 0.03)
	_fb("trim", frame, f, s1, s1 + 0.06, y0, y1 + 0.06, 0.0, 0.03)
	_fb("trim", frame, f, s0, s1, y1, y1 + 0.06, 0.0, 0.03)
	_fb("trim", "frame_black", f, s1 - 0.16, s1 - 0.06, y0 + 0.98, y0 + 1.02, -depth, -depth + 0.05)


## Roll-up door: the curtain sits a little behind the wall in a framed opening.
func _rollup(f: Face, wall_mat: String, s0: float, s1: float, y0: float, y1: float, curtain: String, frame: String) -> void:
	var depth := 0.16
	_reveals(f, wall_mat, Rect2(s0, y0, s1 - s0, y1 - y0), depth)
	_quad("detail", curtain, f.at(s0, y0, -depth), f.at(s1, y0, -depth), f.at(s1, y1, -depth), f.at(s0, y1, -depth), f.nn)
	_fb("trim", frame, f, s0 - 0.16, s0, y0, y1 + 0.16, 0.0, 0.06)
	_fb("trim", frame, f, s1, s1 + 0.16, y0, y1 + 0.16, 0.0, 0.06)
	_fb("trim", frame, f, s0, s1, y1, y1 + 0.16, 0.0, 0.06)


## Parapet coping on top of a wall: proud of the face, running back over the roof edge.
func _coping(f: Face, s0: float, s1: float, y: float, mat: String = "coping", proud: float = 0.12, inner: float = 0.35) -> void:
	_fb("trim", mat, f, s0 - proud, s1 + proud, y - CAP_DROP, y + 0.06, -inner, proud)
	_quad("trim", mat, f.at(s0 - proud, y - CAP_DROP, -inner), f.at(s1 + proud, y - CAP_DROP, -inner), f.at(s1 + proud, y + 0.06, -inner), f.at(s0 - proud, y + 0.06, -inner), -f.nn)


## Flat textured art on a face (lettering, banners), its UV rect mapped across it.
func _art(f: Face, mat: String, s0: float, s1: float, y0: float, y1: float, d: float, uv: Rect2 = Rect2(0, 0, 1, 1), role: String = "trim") -> void:
	var a := uv.position
	var b := uv.end
	# Image left stays on the viewer's left, whichever way s runs on this face.
	if f.sdir.dot((-f.nn).cross(Vector3.UP)) < 0.0:
		var left := a.x
		a.x = b.x
		b.x = left
	_quad(role, mat, f.at(s0, y0, d), f.at(s1, y0, d), f.at(s1, y1, d), f.at(s0, y1, d), f.nn, [Vector2(a.x, b.y), Vector2(b.x, b.y), Vector2(b.x, a.y), Vector2(a.x, a.y)])


func _drape(role: String, mat: String, w0: float, w1: float, u0: float, u1: float, lift: float, step: float = 3.0) -> void:
	var w := w0
	while w < w1 - 0.001:
		var wn := minf(w + step, w1)
		var u := u0
		while u < u1 - 0.001:
			var un := minf(u + step, u1)
			var a := _p(w, land_y(w, u) + lift, u)
			var b := _p(wn, land_y(wn, u) + lift, u)
			var c := _p(wn, land_y(wn, un) + lift, un)
			var d := _p(w, land_y(w, un) + lift, un)
			_plane(role, mat, [a, b, c], Vector3.UP)
			_plane(role, mat, [a, c, d], Vector3.UP)
			u = un
		w = wn


# ---------------------------------------------------------------- massing

## Roofs and the walls that no photo-specific builder owns, tier by tier.
func _build_shell() -> void:
	var drop := CAP_DROP
	# Long white strips and the dark monitor (May 2026 aerial).
	_roof("roof_white", 0.0, W_T2, 0.0, U_S, Y_T1 - drop)
	_roof("roof_white", W_T2, W_MON0, 0.0, U_S, Y_T2 - drop)
	_roof("roof_dark", W_MON0, W_MON1, 0.0, U_S, Y_MON - drop)
	_roof("roof_white", W_MON1, W_C, 0.0, U_S, Y_T2 - drop)
	for strip: Array in [[W_D, 0.0, U_F], [71.98, U_F, 70.66], [67.9, 70.66, 80.165], [65.12, 80.165, 94.41], [68.23, 94.41, U_D]]:
		_roof("roof_white", W_C, strip[0], strip[1], strip[2], Y_D - drop)
	_roof("roof_white", W_C, 68.23, U_D, U_S, Y_S - drop)
	_roof("roof_dark", W_D, W_E, 0.0, U_E, Y_E - drop)
	_roof("roof_tan", W_D, W_F, U_E, U_F, Y_F - drop)
	# Steps between the tiers.
	var t2 := Face.new(_p(W_T2, 0, 0), Vector3.BACK, Vector3.LEFT)
	_wall(t2, "cream", 48.7, U_S, Y_T1, Y_T2)
	_wall(t2, "cream", 0.0, 48.7, Y_T2 - 0.7, Y_T2)
	_wall(t2, "upper_grey", 0.0, 48.7, Y_T1, Y_T2 - 0.7)
	_fb("trim", "rust", t2, 0.0, 48.7, Y_T2 - 0.78, Y_T2 - 0.7, 0.0, 0.05)
	_coping(t2, 0.0, U_S, Y_T2)
	for k in 12:
		_fb("trim", "frame_grey", t2, 2.0 + k * 3.9, 2.08 + k * 3.9, Y_T1, Y_T2 - 0.78, 0.0, 0.03)
	var c_east := Face.new(_p(W_C, 0, 0), Vector3.BACK, Vector3.RIGHT)
	_wall(c_east, "white", 0.0, U_D, Y_D - drop, Y_T2)
	_wall(c_east, "white", U_D, U_S, Y_S - drop, Y_T2)
	_coping(c_east, 0.0, U_S, Y_T2)
	var s_step := Face.new(_p(0, 0, U_D), Vector3.RIGHT, Vector3.BACK)
	_wall(s_step, "white", W_C, 68.23, Y_S - drop, Y_D)
	_coping(s_step, W_C, 68.23, Y_D)
	var e_west := Face.new(_p(W_D, 0, 0), Vector3.BACK, Vector3.LEFT)
	_wall(e_west, "grey", 0.0, U_E, Y_D - drop, Y_E)
	_coping(e_west, 0.0, U_E, Y_E, "band_black")
	var e_south := Face.new(_p(0, 0, U_E), Vector3.RIGHT, Vector3.BACK)
	_wall(e_south, "grey", W_D, W_E, Y_F - drop, Y_E)
	var d_east := Face.new(_p(W_D, 0, 0), Vector3.BACK, Vector3.RIGHT)
	_wall(d_east, "white", U_E, U_F, Y_F - drop, Y_D)
	_coping(d_east, U_E, U_F, Y_D)
	var d_step := Face.new(_p(0, 0, U_F), Vector3.RIGHT, Vector3.FORWARD)
	_wall(d_step, "white", W_D, 71.98, Y_F - drop, Y_D)
	# The unphotographed ENE steps: plain paint, the height the source gave them.
	var ene := [[68.23, U_D, U_S, Y_S], [68.23, 94.41, U_D, Y_D], [65.12, 80.165, 94.41, Y_D], [67.9, 70.66, 80.165, Y_D], [71.98, U_F, 70.66, Y_D]]
	for run: Array in ene:
		var f := Face.new(_p(run[0], 0, 0), Vector3.BACK, Vector3.RIGHT)
		_wall(f, "grey", run[1], run[2], Y_FOOT, run[3])
		_coping(f, run[1], run[2], run[3], "coping_grey", 0.08, 0.3)
	var north_step := Face.new(_p(0, 0, 94.41), Vector3.RIGHT, Vector3.FORWARD)
	_wall(north_step, "grey", 65.12, 68.23, Y_FOOT, Y_D)
	_coping(north_step, 65.12, 68.23, Y_D, "coping_grey", 0.08, 0.3)
	var step_a := Face.new(_p(0, 0, 80.165), Vector3.RIGHT, Vector3.BACK)
	_wall(step_a, "grey", 65.12, 67.9, Y_FOOT, Y_D)
	_coping(step_a, 65.12, 67.9, Y_D, "coping_grey", 0.08, 0.3)
	var step_b := Face.new(_p(0, 0, 70.66), Vector3.RIGHT, Vector3.BACK)
	_wall(step_b, "grey", 67.9, 71.98, Y_FOOT, Y_D)
	_coping(step_b, 67.9, 71.98, Y_D, "coping_grey", 0.08, 0.3)
	var f_south := Face.new(_p(0, 0, U_F), Vector3.RIGHT, Vector3.BACK)
	_wall(f_south, "grey", 71.98, W_F, Y_FOOT, Y_F)
	_coping(f_south, 71.98, W_F, Y_F, "coping_grey", 0.08, 0.3)


func _roof(mat: String, w0: float, w1: float, u0: float, u1: float, y: float) -> void:
	_quad("roof", mat, _p(w0, y, u0), _p(w1, y, u0), _p(w1, y, u1), _p(w0, y, u1), Vector3.UP)


# ---------------------------------------------------------------- WSW front

func _build_wsw() -> void:
	var f := Face.new(Vector3.ZERO, Vector3.BACK, Vector3.LEFT)
	var doors := [[43.55, 44.95, "door_white"], [85.3, 86.3, "door_white"], [89.6, 90.6, "door_white"], [107.3, 108.5, "door_glass"]]
	var low: Array = []
	var band: Array = []
	for door: Array in doors:
		low.append(Rect2(door[0], Y_FOOT, float(door[1]) - float(door[0]), _ground(door[0]) + 2.1 - Y_FOOT))
	low.append(Rect2(46.0, Y_FOOT, 1.8, _ground(46.0) + 2.25 - Y_FOOT))
	low.append(Rect2(56.2, _ground(56.2) + 0.2, 2.4, 1.9))
	low.append(Rect2(59.3, _ground(59.3) + 0.9, 1.7, 1.25))
	low.append(Rect2(70.1, Y_FOOT, 3.8, _ground(70.1) + 2.2 - Y_FOOT))
	for pair: Array in WSW_PAIRS + WSW_SINGLES + WSW_BLANKS:
		band.append(Rect2(pair[0], Y_BAND_SILL, float(pair[1]) - float(pair[0]), Y_BAND_HEAD - Y_BAND_SILL))
	for slot: Array in WSW_LOUVRES:
		band.append(Rect2(slot[0], Y_BAND_SILL, float(slot[1]) - float(slot[0]), Y_BAND_HEAD - Y_BAND_SILL))
	# Lower field and upper band in their photographed paints.
	_wall(f, "tan", 0.0, SIGN_U0, Y_FOOT, Y_T1)
	_wall(f, "tan", SIGN_U0, TAGS_U1, Y_SPLIT, Y_T1)
	_wall(f, "plum", STORE_U1, PLUM_U1, Y_FOOT, Y_SPLIT)
	_wall(f, "tags", PLUM_U1, TAGS_U1, Y_FOOT, Y_SPLIT)
	_wall(f, "sand", TAGS_U1, U_S, Y_FOOT, Y_SPLIT, low)
	_wall(f, "cream", TAGS_U1, U_S, Y_SPLIT, Y_T1, band)
	# Doors, windows and service openings under the canopy (refs 26, 09).
	for door: Array in doors:
		var bottom: float = _ground(door[0])
		_door(f, "sand", str(door[2]), door[0], door[1], Y_FOOT, bottom + 2.1)
	var entry_bottom: float = _ground(46.0)
	_door(f, "sand", "door_glass", 46.0, 47.8, Y_FOOT, entry_bottom + 2.25, "frame_black")
	_fb("trim", "frame_black", f, 46.86, 46.94, Y_FOOT, entry_bottom + 2.25, -0.08, -0.03)
	var w0: float = _ground(56.2)
	_sash(f, "sand", 56.2, 58.6, w0 + 0.2, w0 + 2.1, 3, [], "glass_dark", "frame_black", 0.12, false)
	var w1: float = _ground(59.3)
	_sash(f, "sand", 59.3, 61.0, w1 + 0.9, w1 + 2.15, 2, [], "pane_pale", "frame_white", 0.12, true)
	var svc: float = _ground(70.1)
	_door(f, "sand", "door_dark", 70.1, 73.9, Y_FOOT, svc + 2.2, "frame_grey")
	_fb("trim", "frame_grey", f, 71.9, 73.9, Y_FOOT, svc + 2.2, -0.08, -0.04)
	# Lattice panel beside the south door.
	for k in 7:
		_fb("trim", "frame_black", f, 105.05 + k * 0.28, 105.09 + k * 0.28, _ground(105.0), _ground(105.0) + 2.1, 0.0, 0.05)
	for k in 8:
		var yy: float = _ground(105.0) + 0.1 + k * 0.28
		_fb("trim", "frame_black", f, 105.0, 106.85, yy, yy + 0.04, 0.0, 0.05)
	# Upper band: pairs, the two blanked pairs, single lights and louvres.
	for pair: Array in WSW_PAIRS:
		_sash(f, "cream", pair[0], pair[1], Y_BAND_SILL, Y_BAND_HEAD, 2, [], "pane_pale", "frame_white", 0.1)
	for pair: Array in WSW_SINGLES:
		_sash(f, "cream", pair[0], pair[1], Y_BAND_SILL, Y_BAND_HEAD, 1, [], "pane_pale", "frame_white", 0.1)
	for pair: Array in WSW_BLANKS:
		_sash(f, "cream", pair[0], pair[1], Y_BAND_SILL, Y_BAND_HEAD, 2, [], "cream", "cream", 0.04)
	for slot: Array in WSW_LOUVRES:
		_louvre(f, "cream", slot[0], slot[1], Y_BAND_SILL, Y_BAND_HEAD)
	# Eave band and canopy: rust to the north, lime green to the south.
	_fb("trim", "rust", f, 0.0, CANOPY_GREEN_U, Y_T1 - 0.24, Y_T1 - 0.02, 0.0, 0.2)
	_fb("trim", "lime", f, CANOPY_GREEN_U, U_S, Y_T1 - 0.24, Y_T1 - 0.02, 0.0, 0.2)
	_fb("trim", "coping", f, 0.0, U_S, Y_T1 - 0.02, Y_T1 + 0.06, -0.35, 0.24)
	_canopy(CANOPY_U0, CANOPY_GREEN_U, "rust")
	_canopy(CANOPY_GREEN_U, U_S, "lime")
	# Painted banner over the rust canopy, the small orange sign north of the market,
	# and the green storage board at the south corner (refs 26, 06, 09).
	_art(f, "banner", 29.8, 43.3, 6.24, 7.5, 0.012)
	_art(f, "sign_atlas", 1.6, 4.6, 6.2, 7.3, 0.02, Rect2(0.5, 0.625, 0.25, 0.125))
	var board := Face.new(_p(CANOPY_W - 0.2, 0, 0), Vector3.BACK, Vector3.LEFT)
	_fb("detail", "lime", board, 113.6, 116.9, 6.2, 7.5, -0.12, 0.0)
	_quad("detail", "lime", board.at(113.6, 6.2, -0.12), board.at(116.9, 6.2, -0.12), board.at(116.9, 7.5, -0.12), board.at(113.6, 7.5, -0.12), -board.nn)
	_art(board, "sign_atlas", 113.7, 116.8, 6.34, 7.34, 0.01, Rect2(0.75, 0.625, 0.25, 0.125))
	for post_u: float in [114.0, 116.5]:
		_box("detail", "rust", _p(CANOPY_W - 0.25, land_y(CANOPY_W - 0.2, post_u) - 0.05, post_u - 0.06), _p(CANOPY_W - 0.13, 7.45, post_u + 0.06))
	var u := POST_FIRST_U
	while u < U_S - 2.0:
		var base := land_y(CANOPY_W + 0.14, u) - 0.05
		_box("detail", "rust", _p(CANOPY_W + 0.06, base, u - 0.07), _p(CANOPY_W + 0.2, Y_CANOPY_LOW + 0.02, u + 0.07))
		u += POST_PITCH_M


func _ground(u: float) -> float:
	return land_y(-0.3, u)


func _canopy(u0: float, u1: float, fascia: String) -> void:
	_box("detail", "soffit", _p(CANOPY_W, Y_CANOPY_LOW + 0.08, u0), _p(0.0, Y_CANOPY_TOP - 0.02, u1), 2)
	_quad("roof", "coping", _p(CANOPY_W, Y_CANOPY_TOP, u0), _p(0.0, Y_CANOPY_TOP, u0), _p(0.0, Y_CANOPY_TOP, u1), _p(CANOPY_W, Y_CANOPY_TOP, u1), Vector3.UP)
	_box("trim", fascia, _p(CANOPY_W - 0.08, Y_CANOPY_LOW, u0), _p(CANOPY_W, Y_CANOPY_TOP - 0.04, u1), 2)
	_box("trim", "coping", _p(CANOPY_W - 0.09, Y_CANOPY_TOP - 0.04, u0), _p(CANOPY_W, Y_CANOPY_TOP + 0.02, u1), 2)


# ---------------------------------------------------------------- market

func _build_market() -> void:
	var f := Face.new(Vector3.ZERO, Vector3.BACK, Vector3.LEFT)
	var g0 := land_y(-0.4, 7.0) + SIDEWALK_LIFT
	# Storefront opening and the wall under the porch.
	var store_hole := Rect2(STORE_U0, Y_FOOT, STORE_U1 - STORE_U0, Y_STORE_HEAD - Y_FOOT)
	var doors := [Rect2(6.2, Y_FOOT, 0.92, g0 + 2.1 - Y_FOOT), Rect2(7.28, Y_FOOT, 0.82, g0 + 2.1 - Y_FOOT)]
	_wall(f, "cream", SIGN_U0, ORANGE_U0, Y_FOOT, Y_SPLIT, doors)
	_wall(f, "orange", ORANGE_U0, STORE_U0, Y_FOOT, Y_SPLIT)
	_wall(f, "orange", STORE_U0, STORE_U1, Y_STORE_HEAD, Y_SPLIT)
	_door(f, "cream", "door_white", 6.2, 7.12, Y_FOOT, g0 + 2.1)
	_door(f, "cream", "door_dark", 7.28, 8.1, Y_FOOT, g0 + 2.1, "rust")
	_store(f, store_hole, g0)
	_sign_roof()
	# Porch posts carrying the sign eave (refs 06, 25).
	for u: float in [6.4, 11.1, 24.6]:
		var base := land_y(SIGN_W_EAVE + 0.3, u) - 0.02
		_box("detail", "rust", _p(SIGN_W_EAVE + 0.2, base, u - 0.1), _p(SIGN_W_EAVE + 0.4, Y_FASCIA_LOW + 0.02, u + 0.1))
	_market_fixtures(g0)


## Glazed shop front: kick panels, black frames, entry doors, a shallow shop behind.
func _store(f: Face, hole: Rect2, g0: float) -> void:
	var depth := 0.12
	var back := 2.4
	var s0 := hole.position.x
	var s1 := hole.end.x
	var head := hole.end.y
	_reveals(f, "orange", hole, depth)
	# Shop interior seen through the glass.
	_quad("glow", "interior", f.at(s0, g0 - 0.1, -back), f.at(s1, g0 - 0.1, -back), f.at(s1, head, -back), f.at(s0, head, -back), f.nn, [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
	_quad("trim", "interior_floor", f.at(s0, g0 - 0.02, -depth), f.at(s1, g0 - 0.02, -depth), f.at(s1, g0 - 0.02, -back), f.at(s0, g0 - 0.02, -back), Vector3.UP)
	_quad("trim", "soffit", f.at(s0, head, -depth), f.at(s1, head, -depth), f.at(s1, head, -back), f.at(s0, head, -back), Vector3.DOWN)
	_quad("trim", "orange", f.at(s0, g0, -depth), f.at(s0, head, -depth), f.at(s0, head, -back), f.at(s0, g0, -back), f.sdir)
	_quad("trim", "orange", f.at(s1, g0, -depth), f.at(s1, head, -depth), f.at(s1, head, -back), f.at(s1, g0, -back), -f.sdir)
	var kick_top := g0 + 0.62
	var entry_u := s0 + 2.1
	# Entry pair, then six glazed bays over yellow kick panels.
	var spec := {"mullion_w": 0.1, "rail_w": 0.1, "d": 0.08, "base_d": -depth, "absolute": false, "pitch": (s1 - entry_u) / 6.0, "materials": {"mullion": "frame_black", "transom": "frame_black"}}
	_quad("detail", "glass", f.at(entry_u, kick_top, -depth), f.at(s1, kick_top, -depth), f.at(s1, head, -depth), f.at(entry_u, head, -depth), f.nn)
	_emit(f, ASSEMBLY.curtain(entry_u, s1, kick_top, head, spec))
	_fb("detail", "yellow", f, entry_u, s1, g0 - 0.05, kick_top, -depth - 0.02, -depth + 0.02)
	var bay := (s1 - entry_u) / 6.0
	for k in 7:
		_fb("trim", "frame_black", f, entry_u + bay * k - 0.05, entry_u + bay * k + 0.05, g0 - 0.05, kick_top, -depth, -depth + 0.06)
	_fb("trim", "frame_black", f, entry_u, s1, g0 - 0.05, g0 + 0.05, -depth, -depth + 0.06)
	# Paired glass doors under a transom.
	var door_top := g0 + 2.2
	_quad("detail", "glass", f.at(s0, g0 - 0.05, -depth - 0.16), f.at(entry_u, g0 - 0.05, -depth - 0.16), f.at(entry_u, head, -depth - 0.16), f.at(s0, head, -depth - 0.16), f.nn)
	_emit(f, ASSEMBLY.curtain(s0, entry_u, g0, head, {"mullion_w": 0.12, "rail_w": 0.12, "d": 0.08, "base_d": -depth - 0.14, "absolute": false, "pitch": (entry_u - s0) / 2.0, "transoms": [door_top], "materials": {"mullion": "frame_black", "transom": "frame_black"}}))
	# "OPEN" neon in one light, sale posters in others.
	_art(f, "sign_atlas_glow", entry_u + bay * 3.2, entry_u + bay * 3.8 + 0.1, g0 + 1.45, g0 + 1.95, -depth - 0.05, Rect2(0.0, 0.5, 0.25, 0.125), "glow")


## The big standing-seam sign roof with hipped ends (refs 02, 06, 07, 25).
func _sign_roof() -> void:
	var eave_n := _p(SIGN_W_EAVE, Y_EAVE, SIGN_U0)
	var eave_s := _p(SIGN_W_EAVE, Y_EAVE, SIGN_U1)
	var top_n := _p(SIGN_W_TOP, Y_SIGN_TOP, SIGN_TOP_U0)
	var top_s := _p(SIGN_W_TOP, Y_SIGN_TOP, SIGN_TOP_U1)
	var back_n := _p(SIGN_W_BACK, Y_EAVE, SIGN_U0)
	var back_s := _p(SIGN_W_BACK, Y_EAVE, SIGN_U1)
	var back_top_n := _p(SIGN_W_BACK, Y_SIGN_TOP, SIGN_TOP_U0)
	var back_top_s := _p(SIGN_W_BACK, Y_SIGN_TOP, SIGN_TOP_U1)
	var up_front := Vector3(-1, 0.4, 0)
	# The slope: tan seamed metal; UVs run the unique lettered sheet across it.
	var u_scale := SIGN_U1 - SIGN_U0
	var front_uv := [Vector2(0, 1), Vector2(1, 1), Vector2((SIGN_TOP_U1 - SIGN_U0) / u_scale, 0), Vector2((SIGN_TOP_U0 - SIGN_U0) / u_scale, 0)]
	_plane("roof", "sign_sheet", [eave_n, eave_s, top_s, top_n], up_front, front_uv)
	_plane("roof", "sign_tan", [eave_n, back_n, back_top_n, top_n], Vector3(0, 0.4, -1))
	_plane("roof", "sign_tan", [eave_s, back_s, back_top_s, top_s], Vector3(0, 0.4, 1))
	_plane("roof", "trim_red", [back_n, back_s, back_top_s, back_top_n], Vector3.RIGHT)
	# Standing seams: thin ribs up the slope and across the hips.
	var u := SIGN_U0 + RIB_PITCH_M * 0.5
	while u < SIGN_U1:
		# Parallel seams, cut short where the hips meet the slope.
		var t := minf((u - SIGN_U0) / (SIGN_TOP_U0 - SIGN_U0), (SIGN_U1 - u) / (SIGN_U1 - SIGN_TOP_U1))
		t = clampf(t, 0.0, 1.0)
		_rib(_p(SIGN_W_EAVE, Y_EAVE, u), _p(lerpf(SIGN_W_EAVE, SIGN_W_TOP, t), lerpf(Y_EAVE, Y_SIGN_TOP, t), u), up_front.normalized(), Vector3.BACK)
		u += RIB_PITCH_M
	var w := SIGN_W_EAVE + RIB_PITCH_M * 0.5
	while w < SIGN_W_BACK:
		var tw := clampf((w - SIGN_W_EAVE) / (SIGN_W_TOP - SIGN_W_EAVE), 0.0, 1.0)
		var top_y := lerpf(Y_EAVE, Y_SIGN_TOP, tw)
		_rib(_p(w, Y_EAVE, SIGN_U0), _p(w, top_y, lerpf(SIGN_U0, SIGN_TOP_U0, tw)), Vector3(0, 0.4, -1).normalized(), Vector3.RIGHT)
		_rib(_p(w, Y_EAVE, SIGN_U1), _p(w, top_y, lerpf(SIGN_U1, SIGN_TOP_U1, tw)), Vector3(0, 0.4, 1).normalized(), Vector3.RIGHT)
		w += RIB_PITCH_M
	# Dark red cap along the top of the slope; its flat top is the aerial's red roof.
	_box("roof", "trim_red", _p(SIGN_W_TOP - 0.08, Y_SIGN_TOP - 0.02, SIGN_TOP_U0 - 0.08), _p(SIGN_W_BACK + 0.04, Y_SIGN_CAP, SIGN_TOP_U1 + 0.08), 4)
	# Eave fascia, returning to the wall at both ends.
	_box("detail", "trim_red", _p(SIGN_W_EAVE - 0.1, Y_FASCIA_LOW, SIGN_U0 - 0.1), _p(SIGN_W_EAVE, Y_EAVE + 0.02, SIGN_U1 + 0.1))
	_box("detail", "trim_red", _p(SIGN_W_EAVE, Y_FASCIA_LOW, SIGN_U0 - 0.1), _p(0.0, Y_EAVE + 0.02, SIGN_U0))
	_box("detail", "trim_red", _p(SIGN_W_EAVE, Y_FASCIA_LOW, SIGN_U1), _p(0.0, Y_EAVE + 0.02, SIGN_U1 + 0.1))
	_quad("detail", "soffit", _p(SIGN_W_EAVE, Y_SOFFIT, SIGN_U0), _p(0.0, Y_SOFFIT, SIGN_U0), _p(0.0, Y_SOFFIT, SIGN_U1), _p(SIGN_W_EAVE, Y_SOFFIT, SIGN_U1), Vector3.DOWN)
	# Sign-face lettering on the fascia, the LED sign and floodlights on the cap.
	var fascia := Face.new(_p(SIGN_W_EAVE - 0.1, 0, 0), Vector3.BACK, Vector3.LEFT)
	_art(fascia, "sign_atlas", 14.55, 16.75, 5.94, 6.12, 0.012, Rect2(0.0, 0.625, 0.5, 0.0625))
	var cap := Face.new(_p(SIGN_W_TOP - 0.08, 0, 0), Vector3.BACK, Vector3.LEFT)
	_art(cap, "sign_atlas_glow", 12.3, 18.9, Y_SIGN_CAP - 0.16, Y_SIGN_CAP + 0.36, 0.14, Rect2(0.0, 0.0, 1.0, 0.25), "glow")
	_fb("trim", "frame_black", cap, 12.3, 18.9, Y_SIGN_CAP - 0.02, Y_SIGN_CAP + 0.34, 0.0, 0.12)
	_oval(cap, 11.45, Y_SIGN_CAP + 0.14, 0.44, 0.26)
	for u_lamp: float in [10.1, 20.9]:
		_box("trim", "frame_black", _p(SIGN_W_TOP - 0.46, Y_SIGN_CAP - 0.02, u_lamp - 0.03), _p(SIGN_W_TOP - 0.1, Y_SIGN_CAP + 0.02, u_lamp + 0.03))
		_box("trim", "frame_grey", _p(SIGN_W_TOP - 0.56, Y_SIGN_CAP + 0.0, u_lamp - 0.26), _p(SIGN_W_TOP - 0.4, Y_SIGN_CAP + 0.26, u_lamp + 0.26))
		_box("glow", "lamp", _p(SIGN_W_TOP - 0.57, Y_SIGN_CAP + 0.03, u_lamp - 0.22), _p(SIGN_W_TOP - 0.55, Y_SIGN_CAP + 0.23, u_lamp + 0.22))


func _rib(a: Vector3, b: Vector3, out: Vector3, across: Vector3) -> void:
	var half := across * 0.022
	var lift := out * 0.045
	_plane("trim", "sign_rib", [a - half, b - half, b - half + lift, a - half + lift], -across)
	_plane("trim", "sign_rib", [a + half, b + half, b + half + lift, a + half + lift], across)
	_plane("trim", "sign_rib", [a - half + lift, b - half + lift, b + half + lift, a + half + lift], out)


func _oval(f: Face, s: float, y: float, rs: float, ry: float) -> void:
	var sides := 12
	var points: Array = []
	for i in sides:
		var t := TAU * float(i) / sides
		points.append(f.at(s + rs * cos(t), y + ry * sin(t), 0.1))
	_s("trim", "oval").add(points, f.nn)


## Doors, cages and the mailbox along the orange wall (refs 06, 25).
func _market_fixtures(g0: float) -> void:
	# Perforated gas-bottle cage and its lattice neighbour.
	_box("detail", "cage_white", _p(-1.1, g0, 8.35), _p(-0.1, g0 + 1.85, 9.75))
	_box("detail", "cage_tan", _p(-1.1, g0, 9.85), _p(-0.1, g0 + 1.85, 11.2))
	# Blue mailbox.
	_box("detail", "mailbox", _p(-0.75, g0 + 0.05, 12.3), _p(-0.2, g0 + 1.25, 12.85))
	_box("trim", "plaque", _p(-0.02, g0 + 1.45, 12.75), _p(0.02, g0 + 2.0, 13.4))


# ---------------------------------------------------------------- SSE

func _build_sse() -> void:
	var f := Face.new(_p(0, 0, U_S), Vector3.RIGHT, Vector3.BACK)
	var holes: Array = [Rect2(2.14, 6.22, 2.33, 0.95)]
	for pair: Array in SSE_PAIRS:
		holes.append(Rect2(pair[0], Y_SASH_SILL, float(pair[1]) - float(pair[0]), Y_SASH_HEAD - Y_SASH_SILL))
	var g1 := land_y(40.0, U_S + 0.3)
	var g2 := land_y(62.0, U_S + 0.3)
	var roll1 := Rect2(38.75, Y_FOOT, 3.45, g1 + 3.7 - Y_FOOT)
	var roll2 := Rect2(60.7, Y_FOOT, 3.3, g2 + 3.3 - Y_FOOT)
	var door := Rect2(58.6, Y_FOOT, 1.0, g2 + 2.15 - Y_FOOT)
	var low_holes: Array = [roll1, roll2, door]
	_wall(f, "white", 0.0, W_T2, Y_FOOT, Y_T1, holes)
	_wall(f, "white", W_T2, W_MON0, Y_FOOT, Y_T2, holes)
	_wall(f, "white", W_MON0, W_MON1, Y_FOOT, Y_MON, holes)
	_wall(f, "white", W_MON1, W_C, Y_FOOT, Y_T2, holes + low_holes)
	_wall(f, "white", W_C, 68.23, Y_FOOT, Y_S, low_holes)
	_sash(f, "white", 2.14, 4.47, 6.22, 7.17, 2, [], "pane_pale", "frame_white", 0.12)
	for pair: Array in SSE_PAIRS:
		_sash(f, "white", pair[0], pair[1], Y_SASH_SILL, Y_SASH_HEAD, 2, [1.75], "pane_pale", "frame_white", 0.16)
	_rollup(f, "white", roll1.position.x, roll1.end.x, roll1.position.y, roll1.end.y, "rollup_white", "maroon")
	_rollup(f, "white", roll2.position.x, roll2.end.x, roll2.position.y, roll2.end.y, "rollup_white", "maroon")
	_door(f, "white", "door_dark", door.position.x, door.end.x, door.position.y, door.end.y, "maroon")
	# Copings per tier (ref 12: a thin projecting slab).
	_coping(f, 0.0, W_T2 - 0.12, Y_T1)
	_coping(f, W_T2 + 0.12, W_MON0 - 0.12, Y_T2)
	_coping(f, W_MON0, W_MON1, Y_MON)
	_coping(f, W_MON1 + 0.12, W_C - 0.12, Y_T2)
	_coping(f, W_C, 68.23, Y_S)
	# Painted self-storage lettering (refs 12, 13).
	_art(f, "sign_atlas", 8.42, 18.44, 8.62, 9.06, 0.01, Rect2(0.0, 0.25, 1.0, 0.125))
	_art(f, "sign_atlas", 10.72, 21.19, 7.84, 8.28, 0.01, Rect2(0.0, 0.375, 1.0, 0.125))
	_sse_canopy()
	_art(f, "sign_atlas", 52.6, 57.5, 6.55, 7.3, 0.03, Rect2(0.5, 0.5, 0.5, 0.125))


func _sse_canopy() -> void:
	var w0 := SSE_CANOPY_W0
	var w1 := 68.6
	var out := SSE_CANOPY_U
	var top_wall := Y_SSE_FASCIA_TOP + 0.12
	_plane("roof", "coping", [_p(w0, Y_SSE_FASCIA_TOP, out), _p(w1, Y_SSE_FASCIA_TOP, out), _p(w1, top_wall, U_S), _p(w0, top_wall, U_S)], Vector3.UP)
	_plane("detail", "soffit", [_p(w0, Y_SSE_FASCIA_LOW, out), _p(w1, Y_SSE_FASCIA_LOW, out), _p(w1, Y_SSE_FASCIA_LOW + 0.1, U_S), _p(w0, Y_SSE_FASCIA_LOW + 0.1, U_S)], Vector3.DOWN)
	_box("detail", "maroon", _p(w0 - 0.05, Y_SSE_FASCIA_LOW, out), _p(w1 + 0.05, Y_SSE_FASCIA_TOP, out + 0.07))
	_box("trim", "maroon", _p(w0 - 0.05, Y_SSE_FASCIA_LOW, U_S), _p(w0 + 0.03, Y_SSE_FASCIA_TOP + 0.1, out))
	_box("trim", "maroon", _p(w1 - 0.03, Y_SSE_FASCIA_LOW, U_S), _p(w1 + 0.05, Y_SSE_FASCIA_TOP + 0.1, out))
	_box("trim", "coping", _p(w0 - 0.07, Y_SSE_FASCIA_TOP, out - 0.02), _p(w1 + 0.07, Y_SSE_FASCIA_TOP + 0.05, out + 0.09))
	for w: float in SSE_POSTS:
		var base := land_y(w, out - 0.2) - 0.05
		_box("detail", "maroon", _p(w - 0.07, base, out - 0.27), _p(w + 0.07, Y_SSE_FASCIA_LOW + 0.02, out - 0.13))
		# Y-brace under the fascia.
		for sign_w: float in [-1.0, 1.0]:
			var a := _p(w + sign_w * 0.05, Y_SSE_FASCIA_LOW - 0.75, out - 0.2)
			var b := _p(w + sign_w * 0.7, Y_SSE_FASCIA_LOW - 0.02, out - 0.2)
			_strut("maroon", a, b, 0.035)


## Square bar from a to b.
func _strut(mat: String, a: Vector3, b: Vector3, half: float) -> void:
	var dir := (b - a).normalized()
	var side := dir.cross(Vector3.BACK).normalized()
	if side.length_squared() < 0.5:
		side = dir.cross(Vector3.RIGHT).normalized()
	var other := dir.cross(side).normalized()
	var corners := [side * half + other * half, -side * half + other * half, -side * half - other * half, side * half - other * half]
	for i in 4:
		var c0: Vector3 = corners[i]
		var c1: Vector3 = corners[(i + 1) % 4]
		_plane("trim", mat, [a + c0, b + c0, b + c1, a + c1], (c0 + c1).normalized())


# ---------------------------------------------------------------- ENE and NNW

func _build_ene_north() -> void:
	# Low eaved block on the outermost line (refs 15, 20, 21).
	var low := Face.new(_p(W_F, 0, 0), Vector3.BACK, Vector3.RIGHT)
	var lights := [[39.6, 40.62], [45.5, 46.52]]
	var holes: Array = []
	for light: Array in lights:
		holes.append(Rect2(light[0], 6.2, float(light[1]) - float(light[0]), 1.2))
	_wall(low, "grey", U_E, U_F, Y_FOOT, Y_F, holes)
	for light: Array in lights:
		_sash(low, "grey", light[0], light[1], 6.2, 7.4, 2, [0.4, 0.8], "pane_grey", "grey_frame", 0.05, false)
	_sash(low, "grey", 51.1, 52.12, 6.2, 7.4, 1, [], "grey", "grey", 0.01, false)
	_box("trim", "band_black", _p(W_F, Y_F - 0.2, U_E - 0.45), _p(W_F + 0.42, Y_F + 0.02, U_F))
	_box("trim", "coping_grey", _p(W_F - 0.3, Y_F, U_E - 0.45), _p(W_F + 0.44, Y_F + 0.06, U_F))
	_cyl("trim", "frame_white", _p(W_F + 0.1, Y_FOOT, 38.8), 0.05, Y_F - 0.2 - Y_FOOT, 6)
	var ret := Face.new(_p(0, 0, U_E), Vector3.RIGHT, Vector3.FORWARD)
	_wall(ret, "grey", W_E, W_F, Y_FOOT, Y_F)
	# Tall block under the black band, with its roll-up door and hooded entry.
	var tall := Face.new(_p(W_E, 0, 0), Vector3.BACK, Vector3.RIGHT)
	var g := land_y(W_E + 0.4, 30.0)
	var roll := Rect2(28.5, Y_FOOT, 4.3, g + 3.65 - Y_FOOT)
	var door := Rect2(26.8, Y_FOOT, 1.1, g + 2.1 - Y_FOOT)
	_wall(tall, "grey", 0.0, U_E, Y_FOOT, Y_BAND_LOW + 0.1, [roll, door])
	_rollup(tall, "grey", roll.position.x, roll.end.x, roll.position.y, roll.end.y, "rollup_grey", "grey_frame")
	_door(tall, "grey", "door_black", door.position.x, door.end.x, door.position.y, door.end.y, "grey_frame")
	for u: float in [3.3, 6.9, 10.2, 13.7, 17.1]:
		_fb("trim", "grey", tall, u - 0.15, u + 0.15, Y_FOOT, Y_BAND_LOW, 0.0, 0.1)
	_band(tall, 0.0, U_E, true, false)
	_hood(tall, 20.2, 28.0)


## The black ribbed band that leans out over the grey walls (refs 16, 19, 20).
func _band(f: Face, s0: float, s1: float, wrap_start: bool, wrap_end: bool) -> void:
	var low_d := 0.16
	var top_d := 0.36
	var a0 := s0 - (top_d if wrap_start else 0.0)
	var a1 := s1 + (top_d if wrap_end else 0.0)
	var b0 := s0 - (low_d if wrap_start else 0.0)
	var b1 := s1 + (low_d if wrap_end else 0.0)
	_plane("wall", "band_black", [f.at(b0, Y_BAND_LOW, low_d), f.at(b1, Y_BAND_LOW, low_d), f.at(a1, Y_E, top_d), f.at(a0, Y_E, top_d)], f.nn)
	_quad("trim", "band_black", f.at(b0, Y_BAND_LOW, 0.0), f.at(b1, Y_BAND_LOW, 0.0), f.at(b1, Y_BAND_LOW, low_d), f.at(b0, Y_BAND_LOW, low_d), Vector3.DOWN)
	_fb("trim", "band_black", f, a0, a1, Y_E - 0.02, Y_E + 0.06, -0.4, top_d + 0.02)
	if not wrap_start:
		_plane("trim", "band_black", [f.at(s0, Y_BAND_LOW, 0.0), f.at(s0, Y_BAND_LOW, low_d), f.at(s0, Y_E, top_d), f.at(s0, Y_E, 0.0)], -f.sdir)
	if not wrap_end:
		_plane("trim", "band_black", [f.at(s1, Y_BAND_LOW, 0.0), f.at(s1, Y_BAND_LOW, low_d), f.at(s1, Y_E, top_d), f.at(s1, Y_E, 0.0)], f.sdir)


## Steep standing-seam hood over the ENE door (refs 16, 20).
func _hood(f: Face, s0: float, s1: float) -> void:
	var top_d := 0.38
	var low_d := 1.75
	var y_top := Y_E - 0.08
	var y_low := 6.15
	var out := Vector3(0.75, 0.4, 0).normalized()
	_plane("wall", "hood_grey", [f.at(s0, y_low, low_d), f.at(s1, y_low, low_d), f.at(s1, y_top, top_d), f.at(s0, y_top, top_d)], out)
	_plane("trim", "band_black", [f.at(s0, y_low, 0.0), f.at(s0, y_low, low_d), f.at(s0, y_top, top_d), f.at(s0, y_top, 0.0)], -f.sdir)
	_plane("trim", "band_black", [f.at(s1, y_low, 0.0), f.at(s1, y_low, low_d), f.at(s1, y_top, top_d), f.at(s1, y_top, 0.0)], f.sdir)
	_quad("trim", "band_black", f.at(s0, y_low, 0.0), f.at(s1, y_low, 0.0), f.at(s1, y_low, low_d), f.at(s0, y_low, low_d), Vector3.DOWN)
	var s := s0 + 0.5
	while s < s1:
		var half := 0.03
		var a := f.at(s, y_low, low_d + 0.02)
		var b := f.at(s, y_top, top_d + 0.02)
		_plane("trim", "frame_grey", [a - f.sdir * half, b - f.sdir * half, b + f.sdir * half, a + f.sdir * half], out)
		s += 0.65


func _build_nnw() -> void:
	var f := Face.new(Vector3.ZERO, Vector3.RIGHT, Vector3.FORWARD)
	# West end and mural tiers. The lower wall has no dated photo: plain paint.
	_wall(f, "tan", 0.0, W_T2, Y_FOOT, Y_T1)
	_wall(f, "sky_blue", W_T2, W_MON0, Y_FOOT, Y_T2)
	_wall(f, "sky_blue", W_MON0, W_MON1, Y_FOOT, Y_MON)
	_wall(f, "sky_blue", W_MON1, W_C, Y_FOOT, Y_T2)
	_wall(f, "grey", W_C, W_D, Y_FOOT, Y_D)
	_coping(f, 0.0, W_T2 - 0.12, Y_T1)
	_coping(f, W_T2 + 0.12, W_MON0 - 0.12, Y_T2)
	_coping(f, W_MON0, W_MON1, Y_MON)
	_coping(f, W_MON1 + 0.12, W_C - 0.12, Y_T2)
	_coping(f, W_C + 0.12, W_D, Y_D, "coping_grey", 0.08, 0.3)
	# Mural over the wall's upper part (refs 18, 05).
	_art(f, "mural", 9.2, 18.8, 7.72, Y_T2 - 0.25, 0.012, Rect2(0.0, 0.0, 1.0, 0.5))
	_art(f, "mural", 20.2, 22.4, 7.72, Y_T2 - 0.25, 0.012, Rect2(0.25, 0.5, 0.25, 0.5))
	_art(f, "mural", 25.4, 29.6, 7.72, Y_MON - 0.3, 0.012, Rect2(0.0, 0.5, 0.25, 0.5))
	_art(f, "mural", 33.5, 38.0, 7.72, Y_T2 - 0.25, 0.012, Rect2(0.5, 0.5, 0.5, 0.5))
	# East block: grey wall, pilasters, roll-up door, black band (refs 16, 19).
	var g := land_y(77.0, -0.4)
	var roll := Rect2(74.6, Y_FOOT, 3.66, g + 3.65 - Y_FOOT)
	_wall(f, "grey", W_D, W_E, Y_FOOT, Y_BAND_LOW + 0.1, [roll])
	_rollup(f, "grey", roll.position.x, roll.end.x, roll.position.y, roll.end.y, "rollup_grey", "grey_frame")
	_fb("trim", "grey", f, 72.4, 72.7, Y_FOOT, Y_BAND_LOW, 0.0, 0.1)
	_fb("trim", "grey", f, 81.0, 81.3, Y_FOOT, Y_BAND_LOW, 0.0, 0.1)
	var band_face := Face.new(_p(0, 0, 0), Vector3.RIGHT, Vector3.FORWARD)
	_band(band_face, W_D, W_E, false, true)


func _build_monitor() -> void:
	# Long clerestory sides of the raised centre (ref 13), both faces alike.
	var west := Face.new(_p(W_MON0, 0, 0), Vector3.BACK, Vector3.LEFT)
	var east := Face.new(_p(W_MON1, 0, 0), Vector3.BACK, Vector3.RIGHT)
	var y0 := Y_T2 + 0.36
	var y1 := Y_MON - 0.42
	var bay := 3.66
	var lights: Array = []
	var u := 11.0
	while u < U_S - 11.0:
		lights.append(Rect2(u, y0, bay - 0.6, y1 - y0))
		u += bay
	for f: Face in [west, east]:
		_wall(f, "cream", 0.0, U_S, Y_T2 - CAP_DROP, Y_MON, lights)
		_coping(f, 0.0, U_S, Y_MON)
		for r: Rect2 in lights:
			_sash(f, "cream", r.position.x, r.end.x, r.position.y, r.end.y, 3, [], "glass_clerestory", "frame_white", 0.1, false)


func _build_roof_gear() -> void:
	# Rooftop units on the main block (ref 18, May 2026 aerial).
	for spot: Vector2 in [Vector2(10.5, 13.0), Vector2(11.0, 16.2), Vector2(10.6, 19.8), Vector2(16.8, 11.6), Vector2(15.2, 21.8), Vector2(21.0, 5.6)]:
		_rooftop_unit(spot.x, spot.y, Y_T2 - CAP_DROP)
	# Turbine vents along the low roofs at the NNW end (refs 05, 18).
	for spot: Vector3 in [Vector3(3.0, Y_T1 - CAP_DROP, 1.4), Vector3(6.4, Y_T1 - CAP_DROP, 2.2), Vector3(14.0, Y_T2 - CAP_DROP, 1.2), Vector3(19.0, Y_T2 - CAP_DROP, 1.6), Vector3(35.0, Y_T2 - CAP_DROP, 1.3), Vector3(41.0, Y_T2 - CAP_DROP, 1.5)]:
		_turbine(spot.x, spot.y, spot.z)
	# Small things that stop the white strips looking empty from above.
	for spot: Vector3 in [Vector3(13.0, Y_T2 - CAP_DROP, 58.0), Vector3(18.0, Y_T2 - CAP_DROP, 84.0), Vector3(38.0, Y_T2 - CAP_DROP, 32.0), Vector3(55.0, Y_D - CAP_DROP, 24.0), Vector3(50.0, Y_D - CAP_DROP, 72.0), Vector3(61.0, Y_D - CAP_DROP, 104.0)]:
		_box("detail", "frame_grey", _p(spot.x - 0.5, spot.y, spot.z - 0.5), _p(spot.x + 0.5, spot.y + 0.42, spot.z + 0.5))
	# The dark roof court behind the low ENE block (May 2026 aerial).
	_quad("trim", "roof_dark", _p(72.5, Y_F - CAP_DROP + 0.02, 44.0), _p(79.5, Y_F - CAP_DROP + 0.02, 44.0), _p(79.5, Y_F - CAP_DROP + 0.02, 57.0), _p(72.5, Y_F - CAP_DROP + 0.02, 57.0), Vector3.UP)


func _rooftop_unit(w: float, u: float, y: float) -> void:
	_box("detail", "unit_grey", _p(w - 1.05, y, u - 0.75), _p(w + 1.05, y + 1.15, u + 0.75))
	_cyl("trim", "frame_black", _p(w - 0.45, y + 1.15, u), 0.42, 0.1, 10)
	_cyl("trim", "frame_black", _p(w + 0.5, y + 1.15, u), 0.42, 0.1, 10)


func _turbine(w: float, y: float, u: float) -> void:
	_cyl("detail", "vent_metal", _p(w, y, u), 0.26, 0.38, 10)
	_cyl("trim", "vent_metal", _p(w, y + 0.38, u), 0.3, 0.2, 12, 0.44)
	_cyl("trim", "vent_metal", _p(w, y + 0.58, u), 0.44, 0.2, 12, 0.08)


# ---------------------------------------------------------------- setting

## Paved lot round the building, the market sidewalk, bollards, stall lines.
func _build_setting() -> void:
	# Lot: the aerial has no grass between Avenue H, Avenue I and the walls.
	_drape("setting", "lot", -12.5, 0.0, -11.0, 128.0, LOT_LIFT)
	_drape("setting", "lot", 0.0, 86.0, 115.52, 128.0, LOT_LIFT)
	_drape("setting", "lot", 0.0, 86.0, -11.0, 0.0, LOT_LIFT)
	_drape("setting", "lot", 68.0, 87.5, 60.0, 115.52, LOT_LIFT)
	_drape("setting", "lot", W_F, 87.5, 36.5, 60.0, LOT_LIFT)
	_drape("setting", "lot", W_E, 87.5, -11.0, 36.5, LOT_LIFT)
	# Sidewalk in front of the market, its low curb, and a walkable ramp over the curb.
	_drape("walk", "sidewalk", SIDEWALK_W, 0.0, SIDEWALK_U0, SIDEWALK_U1, SIDEWALK_LIFT, 1.5)
	var u := SIDEWALK_U0
	while u < SIDEWALK_U1 - 0.001:
		var un := minf(u + 1.5, SIDEWALK_U1)
		var a := land_y(SIDEWALK_W, u)
		var b := land_y(SIDEWALK_W, un)
		_quad("setting", "curb", _p(SIDEWALK_W, a - 0.05, u), _p(SIDEWALK_W, b - 0.05, un), _p(SIDEWALK_W, b + SIDEWALK_LIFT, un), _p(SIDEWALK_W, a + SIDEWALK_LIFT, u), Vector3.LEFT)
		_walk_tri(_p(SIDEWALK_W - 0.6, a - 0.02, u), _p(SIDEWALK_W - 0.6, b - 0.02, un), _p(SIDEWALK_W, b + SIDEWALK_LIFT, un))
		_walk_tri(_p(SIDEWALK_W - 0.6, a - 0.02, u), _p(SIDEWALK_W, b + SIDEWALK_LIFT, un), _p(SIDEWALK_W, a + SIDEWALK_LIFT, u))
		u = un
	for end_u: float in [SIDEWALK_U0, SIDEWALK_U1]:
		var dir := -1.0 if end_u < 10.0 else 1.0
		var w := SIDEWALK_W
		while w < -0.001:
			var wn := minf(w + 1.5, 0.0)
			var a := land_y(w, end_u)
			var b := land_y(wn, end_u)
			_quad("setting", "curb", _p(w, a - 0.05, end_u), _p(wn, b - 0.05, end_u), _p(wn, b + SIDEWALK_LIFT, end_u), _p(w, a + SIDEWALK_LIFT, end_u), Vector3(0, 0, dir))
			_walk_tri(_p(w, a - 0.02, end_u + dir * 0.6), _p(wn, b - 0.02, end_u + dir * 0.6), _p(wn, b + SIDEWALK_LIFT, end_u))
			_walk_tri(_p(w, a - 0.02, end_u + dir * 0.6), _p(wn, b + SIDEWALK_LIFT, end_u), _p(w, a + SIDEWALK_LIFT, end_u))
			w = wn
	for k in BOLLARD_COUNT:
		_bollard(BOLLARD_W, BOLLARD_FIRST_U + BOLLARD_PITCH_M * k)
	# Red container wall running north from the market (refs 06, 07).
	for span: Vector2 in [Vector2(-18.6, -6.4), Vector2(-6.4, 5.8)]:
		_container(-2.46, -0.02, span.x, span.y)
	# Stall lines off the sidewalk (ref 06), the yellow ramp pads.
	var stall := -2.0
	while stall < 31.0:
		_stripe("paint_white", SIDEWALK_W - 5.2, SIDEWALK_W - 0.1, stall, stall + 0.1)
		stall += 2.75
	_stripe("paint_yellow", SIDEWALK_W - 1.0, SIDEWALK_W - 0.1, 17.3, 19.4)
	_stripe("paint_yellow", SIDEWALK_W - 1.0, SIDEWALK_W - 0.1, 20.2, 22.3)


## A container on its side, ribbed down its long faces.
func _container(w0: float, w1: float, u0: float, u1: float) -> void:
	var y0 := land_y((w0 + w1) * 0.5, (u0 + u1) * 0.5) - 0.1
	var y1 := y0 + 2.7
	_box("detail", "container_red", _p(w0, y0, u0), _p(w1, y1, u1))
	var u := u0 + 0.14
	while u < u1 - 0.1:
		_box("trim", "container_red", _p(w0 - 0.035, y0 + 0.12, u), _p(w0, y1 - 0.12, u + 0.13), 2)
		u += 0.28


func _stripe(mat: String, w0: float, w1: float, u0: float, u1: float) -> void:
	_drape("setting", mat, w0, w1, u0, u1, LOT_LIFT + 0.012, 2.0)


func _walk_tri(a: Vector3, b: Vector3, c: Vector3) -> void:
	_walk_faces.append_array(PackedVector3Array([a, c, b]))


func _bollard(w: float, u: float) -> void:
	var y := land_y(w, u) + SIDEWALK_LIFT
	_cyl("detail", "bollard", _p(w, y - 0.1, u), 0.2, 1.05, 12)
	_cyl("trim", "bollard", _p(w, y + 0.95, u), 0.2, 0.1, 12, 0.11)
	_cyl("trim", "band_black", _p(w, y + 0.74, u), 0.205, 0.11, 12)


# ---------------------------------------------------------------- old openings

func _unphotographed_openings(wall_record: Dictionary) -> Dictionary:
	var spec: Variant = JSON.parse_string(FileAccess.get_file_as_string(OPENINGS_PATH))
	if not spec is Dictionary:
		return {"ok": false, "message": "B201 unphotographed openings config did not parse."}
	var materials := {}
	for key: String in ["shared_dark_glass", "shared_pale_frame", "b201_service_leaf"]:
		materials[key] = load(D1_MATERIALS + key + ".tres") as Material
	return INFERRED.build(wall_record, spec as Dictionary, materials, transform)


# ---------------------------------------------------------------- materials / commit

func _texture(path: String) -> Texture2D:
	if not _textures.has(path):
		_textures[path] = load(path) as Texture2D
	return _textures[path]




func _material(key: String) -> Material:
	if _materials.has(key):
		return _materials[key]
	var m := StandardMaterial3D.new()
	m.resource_name = "b201_" + key
	if PAINTS.has(key):
		var paint: Array = PAINTS[key]
		var rgb: Array = paint[0]
		m.albedo_color = Color8(int(rgb[0]), int(rgb[1]), int(rgb[2]))
		m.roughness = float(paint[1])
		var tile := str(paint[2])
		if not tile.is_empty():
			m.albedo_texture = _texture({"stucco": TEX + "stucco_paint.png", "metal": TEX + "metal_faded.png", "membrane": TEX + "roof_membrane.png", "asphalt": POLYHAVEN + "clean_asphalt/clean_asphalt_diff_1k.jpg", "concrete": POLYHAVEN + "concrete_pavement/concrete_pavement_diff_1k.jpg"}[tile])
			m.uv1_scale = Vector3(1.0 / float(paint[3]), 1.0 / float(paint[3]), 1.0)
			m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	else:
		match key:
			"glass":
				m.albedo_color = Color(0.05, 0.07, 0.08, 0.42)
				m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				m.roughness = 0.06
				m.metallic_specular = 0.75
			"interior":
				m.albedo_texture = _texture(TEX + "market_interior.png")
				m.emission_enabled = true
				m.emission_texture = m.albedo_texture
				m.emission_energy_multiplier = 0.55
			"sign_sheet":
				m.albedo_texture = _texture(TEX + "sign_sheet.png")
				m.roughness = 0.72
				m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
			"sign_atlas", "sign_atlas_glow":
				m.albedo_texture = _texture(TEX + "sign_atlas.png")
				m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				m.roughness = 0.7
				m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
				if key == "sign_atlas_glow":
					m.emission_enabled = true
					m.emission_texture = m.albedo_texture
					m.emission_energy_multiplier = 0.8
			"mural":
				m.albedo_texture = _texture(TEX + "mural_atlas.png")
				m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				m.roughness = 0.9
			"banner":
				m.albedo_texture = _texture(TEX + "banner.png")
				m.roughness = 0.9
			"lamp":
				m.albedo_color = Color(0.95, 0.95, 0.9)
				m.emission_enabled = true
				m.emission = Color(1.0, 0.98, 0.9)
				m.emission_energy_multiplier = 1.2
			"rollup_grey", "rollup_white":
				m.albedo_color = Color8(150, 154, 154) if key == "rollup_grey" else Color8(232, 230, 222)
				m.albedo_texture = _slat_texture()
				m.uv1_scale = Vector3(1.0, 1.0 / 0.32, 1.0)
				m.roughness = 0.6
			_:
				m.albedo_color = Color(1, 0, 1)
	_materials[key] = m
	return m


## Horizontal slats of a roll-up door, as a small repeating strip.
func _slat_texture() -> ImageTexture:
	var img := Image.create(4, 32, false, Image.FORMAT_RGB8)
	for y in 32:
		var g := 0.62 if y < 3 else (0.82 if y < 6 else 1.0)
		for x in 4:
			img.set_pixel(x, y, Color(g, g, g))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


func _commit() -> void:
	var names := {"wall": "WallMesh", "roof": "RoofMesh", "detail": "DetailMesh", "trim": "TrimMesh", "glow": "GlowMesh", "setting": "SettingMesh", "walk": "SidewalkMesh"}
	var bodies := {"wall": "WallContact", "roof": "RoofContact", "detail": "DetailContact"}
	var sidewalk := Node3D.new()
	sidewalk.name = "MarketSidewalk"
	sidewalk.set_meta("feature_kind", "street_kerb")
	sidewalk.set_meta("source_keys", [SOURCE_KEY])
	sidewalk.set_meta("derived_object_key", WALL_KEY)
	add_child(sidewalk)
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
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if role in ["setting", "walk", "glow"] else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		_tag(inst, "building_wall" if role == "wall" else "none", ROOF_KEY if role == "roof" else WALL_KEY)
		if role == "walk":
			sidewalk.add_child(inst)
		else:
			add_child(inst)
		if bodies.has(role):
			var faces := PackedVector3Array()
			for si in mesh.get_surface_count():
				var arr: Array = mesh.surface_get_arrays(si)
				var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				var ids: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
				for i in ids:
					faces.append(verts[i])
			add_child(_contact(bodies[role], faces, "building_wall" if role == "wall" else "none", ROOF_KEY if role == "roof" else WALL_KEY, role == "wall"))
		elif role == "walk":
			var walk := PackedVector3Array(_walk_faces)
			var arr: Array = mesh.surface_get_arrays(0)
			var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var ids: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
			for i in ids:
				walk.append(verts[i])
			sidewalk.add_child(_contact("SidewalkContact", walk, "none", WALL_KEY, false))


func _contact(body_name: String, faces: PackedVector3Array, receiver: String, key: String, spray: bool) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = body_name
	body.collision_layer = 1 | 4
	body.collision_mask = 0
	_tag(body, receiver, key)
	if spray:
		body.add_to_group("spray_receiver_wall")
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	_tag(shape, receiver, key)
	var holder := CollisionShape3D.new()
	holder.name = "Shape"
	holder.shape = shape
	_tag(holder, receiver, key)
	body.add_child(holder)
	return body


func _tag(object: Object, receiver: String, key: String) -> void:
	object.set_meta("source_keys", [SOURCE_KEY])
	object.set_meta("derived_object_key", key)
	object.set_meta("receiver_kind", receiver)
	object.set_meta("collision_kind", "world_solid")
	object.set_meta("feature_kind", "building_wall" if key == WALL_KEY else "building_roof")
	object.set_meta("opaque", true)
