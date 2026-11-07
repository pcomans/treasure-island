extends Node3D
## City Building 201 at 800 Avenue I (OSM w34313545): a long 1940s Navy storehouse,
## now self storage, a winery and Island Cove Market. Replaces the generated wall
## and roof; live through b201_market_live_replacement.gd.
##
## Footprint-local frame (derived from the exact generated roof record):
##   X = w: across the building, from the Avenue H (WSW) wall toward Avenue I (ENE),
##   Z = u: along it, from the NNW end toward 9th Street (SSE),
##   Y = world elevation (metres).
## The main mass stays on the frozen OSM outline. The market's attached shop front,
## its sign roof and porch, and the canopies stand forward of that line, as the photos
## and the May 2026 aerial show; the annex, lot, sidewalk and props are setting.
##
## Massing, Sep 2025 and Mar 2025 Street View and the May 2026 aerial: a low front
## bay, a main block, a raised central monitor with a dark roof, a second main block
## and a lower east block. Tier heights, bays and openings are production_inference
## fitted from those photos through matched cameras, not surveyed. The ENE middle and
## south walls have no dated photo: they keep their old openings
## (d1_inferred_openings.gd) and only take the side's plain paint.

const ASSEMBLY := preload("res://game/scripts/world/facades/facade_assembly.gd")
const SUPPORT := preload("res://game/scripts/world/facades/housing_quality_support.gd")
const INFERRED := preload("res://game/scripts/world/facades/d1_inferred_openings.gd")

const SOURCE_KEY := "w34313545"
const WALL_KEY := "building:w34313545:wall"
const ROOF_KEY := "building:w34313545:roof"
const LAND_CHUNKS := ["res://generated/world/chunks/x_0__z_-2.json", "res://generated/world/chunks/x_0__z_-1.json", "res://generated/world/chunks/x_-1__z_-2.json"]
const NFPA_CELL := Rect2(0.0, 0.6875, 0.125, 0.25)
const OPENINGS_PATH := "res://game/resources/facades/b201_unphotographed_openings.json"
const D1_MATERIALS := "res://game/resources/materials/world/d1_current/"
const TEX := "res://game/resources/textures/world/b201/"
const LOT_NODE := "B201MarketLot"
const ROLES := ["wall", "roof", "detail", "trim", "overlay", "setting", "walk", "lot"]
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2

## The OSM outline as (w, u), in roof-record order; checked against the record.
const PLAN: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.0, 115.52), Vector2(68.23, 115.52), Vector2(68.23, 94.41), Vector2(65.12, 94.41), Vector2(65.12, 80.165), Vector2(67.9, 80.165), Vector2(67.9, 70.66), Vector2(71.98, 70.66), Vector2(71.98, 59.99), Vector2(86.75, 59.99), Vector2(86.75, 36.495), Vector2(84.075, 36.495), Vector2(84.075, 0.0)]
const PLAN_TOLERANCE_M := 0.05
const GRIME_TILE_M := 44.0
const SLAT_PITCH_M := 0.11
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
# Market (refs 02, 06, 07, 25): sign roof, porch and shop front. The sign, the attached
# front and the plum fence line sit where the photos and aerial put them.
const FRONT_W := -2.6
const SIGN_U0 := 6.0
const SIGN_U1 := 24.9
const SIGN_TOP_U0 := 7.6
const SIGN_TOP_U1 := 23.4
const SIGN_W_EAVE := -5.0
const SIGN_W_TOP := -3.7
const SIGN_W_BACK := 0.8
const Y_FASCIA_LOW := 5.96
const Y_EAVE := 6.2
const Y_SIGN_TOP := 8.95
const Y_SIGN_CAP := 9.22
const Y_SOFFIT := 5.98
const RIB_PITCH_M := 0.6
const HIP_RIB_PITCH_M := 1.9
const ORANGE_U0 := 8.2
const STORE_U0 := 13.6
const ENTRY_U1 := 15.3
const STORE_U1 := 25.4
const TAGS_U0 := 40.6
const PLUM_U1 := 43.8
const Y_STORE_HEAD := 5.9
# SSE (refs 10, 12, 13): tall sash pairs, the storage lettering, the winery canopy.
const SSE_PAIRS := [[8.42, 10.5], [12.9, 15.0], [16.05, 18.2], [20.6, 22.75], [23.9, 26.05], [28.2, 30.4], [31.5, 33.7]]
const Y_SASH_SILL := 4.5
const Y_SASH_HEAD := 7.55
const SSE_CANOPY_W0 := 37.0
const SSE_CANOPY_U := 117.2
const Y_SSE_FASCIA_LOW := 7.42
const Y_SSE_FASCIA_TOP := 7.74
const SSE_POSTS := [37.4, 47.2, 59.9, 66.2]
# ENE north (refs 15, 20, 21): low eaved block, tall block under a black band.
const Y_BAND_LOW := 7.15
# Bollards along the market sidewalk (refs 06, 25).
const SIDEWALK_W := -7.4
const SIDEWALK_U0 := -8.0
const SIDEWALK_U1 := 30.0
const LOT_N := -32.0
const LOT_U1 := 135.3
const LOT_E := 86.9
# The lot's west edge runs under Avenue H's parking strip, which slants across this frame.
const LOT_EDGE_N := -13.14
const LOT_EDGE_S := -14.13
## Building 202's wall line, where the lot stops, as (w, u).
const B202_EDGE: Array[Vector2] = [Vector2(-2.55, LOT_N), Vector2(-2.86, -25.14), Vector2(15.64, -25.35), Vector2(26.31, -15.66), Vector2(64.42, -15.03), Vector2(64.61, -26.17), Vector2(83.81, -25.85)]
const BOLLARD_W := -5.9
const BOLLARD_FIRST_U := 7.0
const BOLLARD_PITCH_M := 2.05
const BOLLARD_COUNT := 9
# The lot lies between the land and the roads and street paint drawn 7.8 cm over it,
# so those meet it rather than being covered. Paint of its own sits on top of them.
const LOT_LIFT := 0.06
const STAIN_LIFT := 0.069
const STAIN_TILE_M := 41.25
const EDGE_WEAR_TILE_M := 14.0
const PAINT_LIFT := 0.088
const SIDEWALK_LIFT := 0.2
# The container yard along Avenue I (refs 14, 22; Aug 2025 aerial).
const YARD_FACE_W := 85.0
const YARD_UPPER_W := 84.2
const CONTAINER_WIDE := 2.44
const CONTAINER_TALL := 2.59
## Ground tier: [north edge u, length, paint, door number]. Upper: the same, then door face w.
const YARD_LOW := [[60.25, 12.2, "container_grey", 1], [65.3, 12.2, "container_grey", 3], [71.75, 12.2, "container_grey", 7], [74.2, 6.06, "container_rust", 9], [79.7, 12.2, "container_rust", 15], [85.0, 12.2, "container_rust", 17], [87.6, 12.2, "container_grey", 0], [90.1, 12.2, "container_grey", 0], [94.9, 6.06, "container_grey", 0]]
const YARD_HIGH := [[60.25, 11.2, "container_grey", 2, YARD_UPPER_W], [71.75, 12.2, "container_grey", 8, YARD_FACE_W], [79.7, 12.2, "container_rust", 16, YARD_FACE_W], [85.0, 6.06, "container_brown", 0, 78.6], [87.6, 12.2, "container_grey", 0, YARD_FACE_W], [90.1, 12.2, "container_grey", 0, YARD_FACE_W]]
## Door numbers in the sign atlas: number -> cell.
const DOOR_NUMBERS := {1: 0, 2: 1, 3: 2, 4: 3, 7: 4, 8: 5, 9: 6, 15: 7, 16: 8, 17: 9}

## Painted and plain surfaces: [[r, g, b] sRGB bytes, roughness, tile texture or "", tile metres].
const PAINTS := {
	"cream": [[218, 204, 170], 0.9, "stucco", 3.0],
	"arcade": [[178, 170, 152], 0.92, "stucco", 3.0],
	"tan": [[204, 182, 140], 0.9, "stucco", 3.0],
	# Past 255: the stucco tile darkens what it multiplies, and this wall stays bleached.
	"white": [[281, 281, 275], 0.88, "stucco", 3.0],
	"grey": [[188, 200, 204], 0.9, "stucco", 3.0],
	"sky_blue": [[182, 200, 216], 0.9, "stucco", 3.0],
	"upper_grey": [[176, 182, 190], 0.8, "stucco", 3.0],
	"orange": [[222, 142, 28], 0.85, "stucco", 3.0],
	"plum": [[146, 118, 122], 0.92, "speckle", 0.9],
	"tags": [[176, 172, 164], 0.9, "stucco", 2.0],
	"rust": [[176, 124, 104], 0.8, "", 1.0],
	"lime": [[118, 206, 58], 0.7, "", 1.0],
	"maroon": [[126, 40, 50], 0.7, "", 1.0],
	"trim_red": [[196, 152, 136], 0.75, "", 1.0],
	"sign_rib": [[150, 134, 112], 0.65, "", 1.0],
	"sign_hip_rib": [[174, 160, 140], 0.65, "", 1.0],
	"coping": [[226, 222, 208], 0.8, "", 1.0],
	"coping_grey": [[176, 182, 182], 0.8, "", 1.0],
	"soffit": [[134, 122, 108], 0.9, "", 1.0],
	"soffit_pale": [[176, 164, 146], 0.9, "", 1.0],
	"frame_white": [[236, 234, 226], 0.6, "", 1.0],
	"frame_black": [[30, 30, 32], 0.5, "", 1.0],
	"frame_grey": [[124, 128, 130], 0.6, "", 1.0],
	"grey_frame": [[168, 178, 182], 0.7, "", 1.0],
	"rollup_frame": [[122, 128, 130], 0.7, "", 1.0],
	"door_frame": [[48, 40, 36], 0.55, "", 1.0],
	"door_white": [[226, 224, 216], 0.55, "", 1.0],
	"door_dark": [[44, 52, 50], 0.6, "", 1.0],
	"door_glass": [[28, 36, 40], 0.2, "", 1.0],
	"door_black": [[12, 13, 14], 0.8, "", 1.0],
	"door_grey": [[122, 132, 136], 0.7, "", 1.0],
	"container_red": [[172, 76, 64], 0.7, "ribs", 0.3],
	"container_red_edge": [[146, 64, 54], 0.7, "", 1.0],
	"container_tan": [[214, 192, 142], 0.75, "ribs", 0.3],
	"container_grey": [[136, 142, 142], 0.7, "ribs", 0.3],
	"container_grey_edge": [[172, 178, 176], 0.7, "", 1.0],
	"container_grey_seam": [[146, 150, 148], 0.7, "", 1.0],
	"container_grey_rod": [[136, 138, 134], 0.6, "", 1.0],
	"container_rust": [[142, 84, 66], 0.75, "ribs", 0.3],
	"container_rust_edge": [[150, 96, 72], 0.75, "", 1.0],
	"container_rust_seam": [[116, 70, 56], 0.75, "", 1.0],
	"container_rust_rod": [[186, 178, 162], 0.6, "", 1.0],
	"container_brown": [[132, 90, 58], 0.75, "ribs", 0.3],
	"container_brown_edge": [[136, 94, 62], 0.75, "", 1.0],
	"container_brown_seam": [[108, 74, 50], 0.75, "", 1.0],
	"container_brown_rod": [[110, 78, 54], 0.6, "", 1.0],
	"container_casting": [[62, 56, 52], 0.7, "", 1.0],
	"patch_primer": [[214, 214, 210], 0.8, "", 1.0],
	"lock_red": [[196, 54, 48], 0.5, "", 1.0],
	"tarp": [[120, 132, 140], 0.85, "", 1.0],
	"cabin_white": [[226, 226, 220], 0.7, "", 1.0],
	"plywood": [[196, 152, 98], 0.85, "", 1.0],
	"wood_dark": [[92, 66, 52], 0.85, "", 1.0],
	"trailer_white": [[232, 232, 228], 0.45, "", 1.0],
	"trailer_skirt": [[150, 152, 150], 0.6, "", 1.0],
	"container_tan_edge": [[196, 174, 126], 0.75, "", 1.0],
	"fence_red": [[158, 66, 58], 0.8, "mesh", 0.16],
	"fence_green": [[62, 112, 86], 0.8, "slats", 0.09],
	"pane_band": [[138, 138, 134], 0.34, "", 1.0],
	"pane_sse": [[176, 168, 152], 0.4, "", 1.0],
	"pane_grey": [[132, 144, 148], 0.4, "", 1.0],
	"glass_clerestory": [[88, 98, 104], 0.25, "", 1.0],
	"glass_dark": [[26, 32, 36], 0.18, "", 1.0],
	"louvre_back": [[70, 70, 66], 0.9, "", 1.0],
	"band_black": [[40, 43, 48], 0.72, "ribs", 0.3],
	"band_plain": [[52, 54, 56], 0.6, "", 1.0],
	"hood_grey": [[70, 74, 78], 0.6, "", 1.0],
	"yellow": [[226, 186, 72], 0.65, "", 1.0],
	"cage_white": [[226, 226, 222], 0.7, "dots", 0.12],
	"cage_tan": [[200, 190, 164], 0.8, "mesh", 0.12],
	"mailbox": [[26, 36, 64], 0.5, "", 1.0],
	"plaque": [[150, 72, 44], 0.6, "", 1.0],
	"oval": [[196, 198, 196], 0.5, "", 1.0],
	"unit_grey": [[150, 152, 150], 0.7, "", 1.0],
	"vent_curb": [[176, 178, 176], 0.6, "", 1.0],
	"vent_metal": [[170, 172, 172], 0.45, "", 1.0],
	"vent_ball": [[176, 180, 184], 0.45, "ribs", 0.16],
	"corrugated": [[212, 208, 198], 0.6, "ribs", 0.14],
	"roof_white": [[236, 233, 224], 0.85, "membrane", 8.0],
	"roof_dark": [[112, 110, 100], 0.92, "membrane", 8.0],
	"roof_tan": [[190, 172, 142], 0.92, "membrane", 8.0],
	"roof_annex": [[150, 142, 126], 0.92, "membrane", 6.0],
	"bollard": [[150, 150, 146], 0.85, "", 1.0],
	"curb": [[186, 184, 174], 0.9, "", 1.0],
	"paint_yellow": [[226, 170, 40], 0.85, "", 1.0],
	"paint_blue": [[52, 92, 150], 0.85, "", 1.0],
	"interior_floor": [[60, 58, 54], 0.4, "", 1.0],
	"tote": [[230, 230, 226], 0.7, "", 1.0],
	"underbody": [[26, 26, 28], 0.9, "", 1.0],
	"barrel": [[104, 76, 54], 0.75, "", 1.0],
	"wood": [[126, 108, 84], 0.85, "", 1.0],
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
var _lot_footprint := PackedVector2Array()
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


	## A quad with its own vertex normals, for rounded things.
	func add_smooth(points: Array, normals: Array, facing: Vector3) -> void:
		var hint := Vector3.UP if absf(facing.y) < 0.7 else Vector3(0, 0, 1)
		var tu := hint.cross(facing).normalized()
		var tv := facing.cross(tu).normalized()
		var base := v.size()
		for i in points.size():
			var p: Vector3 = points[i]
			v.append(p)
			n.append(normals[i] as Vector3)
			uv.append(Vector2(p.dot(tu), -p.dot(tv)))
			t.append(tu.x)
			t.append(tu.y)
			t.append(tu.z)
			t.append(1.0)
		var a: Vector3 = points[0]
		var b: Vector3 = points[1]
		var c: Vector3 = points[2]
		var flip := (b - a).cross(c - a).dot(facing) > 0.0
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
			if w > -45.0 and w < 125.0 and u > -75.0 and u < 160.0:
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


## Body of revolution round a vertical axis: profile is (radius, height above base).
func _lathe(role: String, mat: String, base: Vector3, profile: Array, sides: int) -> void:
	var s := _s(role, mat)
	for k in profile.size() - 1:
		var a: Vector2 = profile[k]
		var b: Vector2 = profile[k + 1]
		var rise := Vector2(b.y - a.y, a.x - b.x).normalized()
		for i in sides:
			var t0 := TAU * float(i) / sides
			var t1 := TAU * float(i + 1) / sides
			var d0 := Vector3(cos(t0), 0.0, sin(t0))
			var d1 := Vector3(cos(t1), 0.0, sin(t1))
			var n0 := d0 * rise.x + Vector3.UP * rise.y
			var n1 := d1 * rise.x + Vector3.UP * rise.y
			var pts := [base + d0 * a.x + Vector3.UP * a.y, base + d1 * a.x + Vector3.UP * a.y, base + d1 * b.x + Vector3.UP * b.y, base + d0 * b.x + Vector3.UP * b.y]
			s.add_smooth(pts, [n0, n1, n1, n0], (n0 + n1).normalized())


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
	var doors := [[44.0, 45.1, "door_white"], [85.3, 86.3, "door_white"], [89.6, 90.6, "door_white"], [107.3, 108.5, "door_glass"]]
	var low: Array = []
	var band: Array = []
	for door: Array in doors:
		low.append(Rect2(door[0], Y_FOOT, float(door[1]) - float(door[0]), _ground(door[0]) + 2.1 - Y_FOOT))
	low.append(Rect2(46.0, Y_FOOT, 1.8, _ground(46.0) + 2.25 - Y_FOOT))
	low.append(Rect2(56.2, _ground(56.2) + 0.2, 2.4, 1.9))
	low.append(Rect2(59.3, _ground(59.3) + 0.9, 1.7, 1.25))
	low.append(Rect2(70.1, Y_FOOT, 3.8, _ground(70.1) + 2.2 - Y_FOOT))
	for pair: Array in WSW_PAIRS + WSW_SINGLES + WSW_BLANKS + WSW_LOUVRES:
		band.append(Rect2(pair[0], Y_BAND_SILL, float(pair[1]) - float(pair[0]), Y_BAND_HEAD - Y_BAND_SILL))
	# Paints: the darker arcade below the canopy, pale cream above it.
	_wall(f, "tan", 0.0, SIGN_U0, Y_FOOT, Y_T1)
	_wall(f, "cream", SIGN_U0, PLUM_U1, Y_SPLIT, Y_T1)
	_wall(f, "arcade", SIGN_U0, TAGS_U0, Y_FOOT, Y_SPLIT)
	_wall(f, "tags", TAGS_U0, PLUM_U1, Y_FOOT, Y_SPLIT)
	_wall(f, "arcade", PLUM_U1, U_S, Y_FOOT, Y_SPLIT, low)
	_wall(f, "cream", PLUM_U1, U_S, Y_SPLIT, Y_T1, band)
	# The plum fence between the rust posts, in line with the shop front (refs 06, 25, 26).
	var fence := Face.new(_p(FRONT_W, 0, 0), Vector3.BACK, Vector3.LEFT)
	_wall(fence, "plum", STORE_U1, PLUM_U1, Y_FOOT, Y_CANOPY_LOW + 0.1)
	# Doors, windows and service openings under the canopy (refs 26, 09).
	for door: Array in doors:
		_door(f, "arcade", str(door[2]), door[0], door[1], Y_FOOT, _ground(door[0]) + 2.1)
	var entry_bottom := _ground(46.0)
	_door(f, "arcade", "door_glass", 46.0, 47.8, Y_FOOT, entry_bottom + 2.25, "frame_black")
	_fb("trim", "frame_black", f, 46.86, 46.94, Y_FOOT, entry_bottom + 2.25, -0.08, -0.03)
	var w0 := _ground(56.2)
	_sash(f, "arcade", 56.2, 58.6, w0 + 0.2, w0 + 2.1, 3, [], "glass_dark", "frame_black", 0.12, false)
	var w1 := _ground(59.3)
	_sash(f, "arcade", 59.3, 61.0, w1 + 0.9, w1 + 2.15, 2, [], "pane_band", "frame_white", 0.12, true)
	var svc := _ground(70.1)
	_door(f, "arcade", "door_dark", 70.1, 73.9, Y_FOOT, svc + 2.2, "frame_grey")
	_fb("trim", "frame_grey", f, 71.9, 73.9, Y_FOOT, svc + 2.2, -0.08, -0.04)
	# Lattice panel beside the south door.
	var lattice := _ground(105.0)
	for k in 7:
		_fb("trim", "frame_black", f, 105.05 + k * 0.28, 105.09 + k * 0.28, lattice, lattice + 2.1, 0.0, 0.05)
	for k in 8:
		_fb("trim", "frame_black", f, 105.0, 106.85, lattice + 0.1 + k * 0.28, lattice + 0.14 + k * 0.28, 0.0, 0.05)
	# Upper band: pairs with their glazing bars, single lights, blanked pairs, louvres.
	var bars := [0.3, 0.58]
	for pair: Array in WSW_PAIRS:
		_sash(f, "cream", pair[0], pair[1], Y_BAND_SILL, Y_BAND_HEAD, 2, bars, "pane_band", "frame_white", 0.1)
	for pair: Array in WSW_SINGLES:
		_sash(f, "cream", pair[0], pair[1], Y_BAND_SILL, Y_BAND_HEAD, 1, bars, "pane_band", "frame_white", 0.1)
	for pair: Array in WSW_BLANKS:
		_sash(f, "cream", pair[0], pair[1], Y_BAND_SILL, Y_BAND_HEAD, 2, [], "cream", "cream", 0.04)
	for slot: Array in WSW_LOUVRES:
		_louvre(f, "cream", slot[0], slot[1], Y_BAND_SILL, Y_BAND_HEAD)
	# Eave band and canopy: rust to the north, lime green to the south.
	_fb("trim", "rust", f, 0.0, CANOPY_GREEN_U, Y_T1 - 0.24, Y_T1 - 0.02, 0.0, 0.2)
	_fb("trim", "lime", f, CANOPY_GREEN_U, U_S, Y_T1 - 0.24, Y_T1 - 0.02, 0.0, 0.2)
	_fb("trim", "coping", f, 0.0, U_S, Y_T1 - 0.02, Y_T1 + 0.06, -0.35, 0.24)
	_canopy(CANOPY_U0, PLUM_U1, "rust", FRONT_W - 0.28)
	_canopy(PLUM_U1, CANOPY_GREEN_U, "rust", CANOPY_W)
	_canopy(CANOPY_GREEN_U, U_S, "lime", CANOPY_W)
	var u := POST_FIRST_U
	while u < U_S - 2.0:
		var line := FRONT_W - 0.16 if u < PLUM_U1 + 0.2 else CANOPY_W + 0.13
		var base := land_y(line, u) - 0.05
		_box("detail", "rust", _p(line - 0.08, base, u - 0.08), _p(line + 0.08, Y_CANOPY_LOW + 0.02, u + 0.08))
		u += POST_PITCH_M
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
	# Weather: run-off under the eave, splash along the foot of the arcade.
	_grime_top(f, PLUM_U1, U_S, Y_BAND_HEAD + 0.03, Y_T1 - 0.24)
	_grime_foot(f, PLUM_U1, U_S, 3.15, 4.3)


func _ground(u: float) -> float:
	return land_y(-0.3, u)


func _canopy(u0: float, u1: float, fascia: String, outer: float) -> void:
	_box("detail", "soffit", _p(outer, Y_CANOPY_LOW + 0.08, u0), _p(0.0, Y_CANOPY_TOP - 0.02, u1), 2)
	_quad("roof", "coping", _p(outer, Y_CANOPY_TOP, u0), _p(0.0, Y_CANOPY_TOP, u0), _p(0.0, Y_CANOPY_TOP, u1), _p(outer, Y_CANOPY_TOP, u1), Vector3.UP)
	_box("trim", fascia, _p(outer - 0.08, Y_CANOPY_LOW, u0), _p(outer, Y_CANOPY_TOP - 0.04, u1), 2)
	_box("trim", "coping", _p(outer - 0.09, Y_CANOPY_TOP - 0.04, u0), _p(outer, Y_CANOPY_TOP + 0.02, u1), 2)


## Rain run-off hanging from y1 down to y0, and the darker foot of a wall.
func _grime_top(f: Face, s0: float, s1: float, y0: float, y1: float, d: float = 0.008, mat: String = "grime") -> void:
	_art(f, mat, s0, s1, y0, y1, d, Rect2(s0 / GRIME_TILE_M, 0.0, (s1 - s0) / GRIME_TILE_M, 1.0), "overlay")


func _grime_foot(f: Face, s0: float, s1: float, y0: float, y1: float, d: float = 0.008, mat: String = "grime") -> void:
	_art(f, mat, s0, s1, y0, y1, d, Rect2(0.3 + s0 / GRIME_TILE_M, 1.0, (s1 - s0) / GRIME_TILE_M, -1.0), "overlay")


# ---------------------------------------------------------------- market

func _build_market() -> void:
	# The attached shop front stands under the sign roof, forward of the OSM wall.
	var f := Face.new(_p(FRONT_W, 0, 0), Vector3.BACK, Vector3.LEFT)
	var g0 := land_y(FRONT_W - 0.4, 7.0) + SIDEWALK_LIFT
	var store_hole := Rect2(STORE_U0, Y_FOOT, STORE_U1 - STORE_U0, Y_STORE_HEAD - Y_FOOT)
	var doors := [Rect2(6.2, Y_FOOT, 0.92, g0 + 2.1 - Y_FOOT), Rect2(7.28, Y_FOOT, 0.82, g0 + 2.1 - Y_FOOT)]
	_wall(f, "cream", SIGN_U0, ORANGE_U0, Y_FOOT, Y_SOFFIT, doors)
	_wall(f, "orange", ORANGE_U0, STORE_U0, Y_FOOT, Y_SOFFIT)
	_wall(f, "orange", STORE_U0, STORE_U1, Y_STORE_HEAD, Y_SOFFIT)
	_door(f, "cream", "door_white", 6.2, 7.12, Y_FOOT, g0 + 2.1)
	_door(f, "cream", "door_dark", 7.28, 8.1, Y_FOOT, g0 + 2.1, "rust")
	_wall(Face.new(_p(0, 0, SIGN_U0), Vector3.RIGHT, Vector3.FORWARD), "cream", FRONT_W, 0.0, Y_FOOT, Y_SOFFIT)
	_wall(Face.new(_p(0, 0, STORE_U1), Vector3.RIGHT, Vector3.BACK), "arcade", FRONT_W, 0.0, Y_FOOT, Y_SOFFIT)
	_store(f, store_hole, g0)
	_sign_roof()
	# Porch posts carrying the sign eave (refs 06, 25).
	for u: float in [6.4, 11.1, 24.6]:
		var base := land_y(SIGN_W_EAVE + 0.3, u) + SIDEWALK_LIFT - 0.1
		_box("detail", "rust", _p(SIGN_W_EAVE + 0.2, base, u - 0.09), _p(SIGN_W_EAVE + 0.38, Y_FASCIA_LOW + 0.02, u + 0.09))
	_market_fixtures(g0)


## Shop front: the dark door bay, then dark glazing over yellow kick panels, with the
## shop only faintly seen behind it by day (refs 06, 25).
func _store(f: Face, hole: Rect2, g0: float) -> void:
	var depth := 0.12
	var back := 2.3
	var s0 := hole.position.x
	var s1 := hole.end.x
	var head := hole.end.y
	_reveals(f, "orange", hole, depth)
	_quad("trim", "interior", f.at(s0, g0 - 0.1, -back), f.at(s1, g0 - 0.1, -back), f.at(s1, head, -back), f.at(s0, head, -back), f.nn, [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
	_quad("trim", "interior_floor", f.at(s0, g0 - 0.02, -depth), f.at(s1, g0 - 0.02, -depth), f.at(s1, g0 - 0.02, -back), f.at(s0, g0 - 0.02, -back), Vector3.UP)
	_quad("trim", "soffit", f.at(s0, head, -depth), f.at(s1, head, -depth), f.at(s1, head, -back), f.at(s0, head, -back), Vector3.DOWN)
	_quad("trim", "frame_black", f.at(s0, g0, -depth), f.at(s0, head, -depth), f.at(s0, head, -back), f.at(s0, g0, -back), f.sdir)
	_quad("trim", "frame_black", f.at(s1, g0, -depth), f.at(s1, head, -depth), f.at(s1, head, -back), f.at(s1, g0, -back), -f.sdir)
	var kick_top := g0 + 0.62
	var entry_u := ENTRY_U1
	var bay := (s1 - entry_u) / 6.0
	var spec := {"mullion_w": 0.1, "rail_w": 0.1, "d": 0.08, "base_d": -depth, "absolute": false, "pitch": bay, "materials": {"mullion": "frame_black", "transom": "frame_black"}}
	_quad("detail", "glass", f.at(entry_u, kick_top, -depth), f.at(s1, kick_top, -depth), f.at(s1, head, -depth), f.at(entry_u, head, -depth), f.nn)
	_emit(f, ASSEMBLY.curtain(entry_u, s1, kick_top, head, spec))
	_fb("detail", "yellow", f, entry_u, s1, g0 - 0.05, kick_top, -depth - 0.02, -depth + 0.02)
	for k in 7:
		_fb("trim", "frame_black", f, entry_u + bay * k - 0.05, entry_u + bay * k + 0.05, g0 - 0.05, kick_top, -depth, -depth + 0.06)
	_fb("trim", "frame_black", f, entry_u, s1, g0 - 0.05, g0 + 0.05, -depth, -depth + 0.06)
	# The door bay: a recessed pair under a transom, with kick rails and push bars.
	var door_top := g0 + 2.2
	var bay_d := -depth - 0.34
	_quad("detail", "glass", f.at(s0, g0 - 0.05, bay_d), f.at(entry_u, g0 - 0.05, bay_d), f.at(entry_u, head, bay_d), f.at(s0, head, bay_d), f.nn)
	_emit(f, ASSEMBLY.curtain(s0, entry_u, g0, head, {"mullion_w": 0.14, "rail_w": 0.12, "d": 0.08, "base_d": bay_d, "absolute": false, "pitch": (entry_u - s0) / 2.0, "transoms": [door_top], "materials": {"mullion": "door_frame", "transom": "door_frame"}}))
	var mid := (s0 + entry_u) * 0.5
	for leaf: Vector2 in [Vector2(s0 + 0.07, mid - 0.07), Vector2(mid + 0.07, entry_u - 0.07)]:
		_fb("trim", "door_frame", f, leaf.x, leaf.y, g0, g0 + 0.34, bay_d, bay_d + 0.05)
		_fb("trim", "vent_metal", f, leaf.x + 0.1, leaf.y - 0.1, g0 + 0.98, g0 + 1.03, bay_d + 0.05, bay_d + 0.1)
	_fb("trim", "frame_black", f, entry_u - 0.05, entry_u + 0.05, g0, head, bay_d, -depth + 0.06)
	# "OPEN" and the food posters high in the lights (refs 06, 25).
	var sticker := -depth + 0.012
	_art(f, "sign_bright", entry_u + bay * 3.15, entry_u + bay * 3.85, head - 0.92, head - 0.5, sticker, Rect2(0.0, 0.5, 0.25, 0.125))
	for slot: Vector2i in [Vector2i(1, 2), Vector2i(2, 0), Vector2i(4, 1)]:
		var centre := entry_u + bay * (float(slot.x) + 0.5)
		_art(f, "posters", centre - 0.62, centre + 0.62, head - 0.98, head - 0.14, sticker, Rect2(float(slot.y) * 0.25 + 0.012, 0.3, 0.226, 0.34))


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
	# Hips carry the same sheet without its lettering, so the two read as one metal.
	var hip_uv := [Vector2(0, 1), Vector2(0.31, 1), Vector2(0.31, 0), Vector2(0.07, 0)]
	_plane("roof", "sign_plain", [eave_n, back_n, back_top_n, top_n], Vector3(0, 0.4, -1), hip_uv)
	_plane("roof", "sign_plain", [eave_s, back_s, back_top_s, top_s], Vector3(0, 0.4, 1), hip_uv)
	_plane("roof", "trim_red", [back_n, back_s, back_top_s, back_top_n], Vector3.RIGHT)
	# Standing seams up the slope and across the hips.
	var u := SIGN_U0 + RIB_PITCH_M * 0.5
	while u < SIGN_U1:
		# Parallel seams, cut short where the hips meet the slope.
		var t := minf((u - SIGN_U0) / (SIGN_TOP_U0 - SIGN_U0), (SIGN_U1 - u) / (SIGN_U1 - SIGN_TOP_U1))
		t = clampf(t, 0.0, 1.0)
		_rib(_p(SIGN_W_EAVE, Y_EAVE, u), _p(lerpf(SIGN_W_EAVE, SIGN_W_TOP, t), lerpf(Y_EAVE, Y_SIGN_TOP, t), u), up_front.normalized(), Vector3.BACK)
		u += RIB_PITCH_M
	var w := SIGN_W_EAVE + HIP_RIB_PITCH_M * 0.5
	while w < SIGN_W_BACK:
		var tw := clampf((w - SIGN_W_EAVE) / (SIGN_W_TOP - SIGN_W_EAVE), 0.0, 1.0)
		var top_y := lerpf(Y_EAVE, Y_SIGN_TOP, tw)
		_rib(_p(w, Y_EAVE, SIGN_U0), _p(w, top_y, lerpf(SIGN_U0, SIGN_TOP_U0, tw)), Vector3(0, 0.4, -1).normalized(), Vector3.RIGHT, "sign_hip_rib")
		_rib(_p(w, Y_EAVE, SIGN_U1), _p(w, top_y, lerpf(SIGN_U1, SIGN_TOP_U1, tw)), Vector3(0, 0.4, 1).normalized(), Vector3.RIGHT, "sign_hip_rib")
		w += HIP_RIB_PITCH_M
	# Faded terracotta cap along the top of the slope; its flat top is the aerial's red roof.
	_box("roof", "trim_red", _p(SIGN_W_TOP - 0.08, Y_SIGN_TOP - 0.02, SIGN_TOP_U0 - 0.08), _p(SIGN_W_BACK + 0.04, Y_SIGN_CAP, SIGN_TOP_U1 + 0.08), 4)
	# Eave fascia, returning to the shop front at both ends, and the porch soffit.
	_box("detail", "trim_red", _p(SIGN_W_EAVE - 0.1, Y_FASCIA_LOW, SIGN_U0 - 0.1), _p(SIGN_W_EAVE, Y_EAVE + 0.02, SIGN_U1 + 0.1))
	_box("detail", "trim_red", _p(SIGN_W_EAVE, Y_FASCIA_LOW, SIGN_U0 - 0.1), _p(0.0, Y_EAVE + 0.02, SIGN_U0))
	_box("detail", "trim_red", _p(SIGN_W_EAVE, Y_FASCIA_LOW, SIGN_U1), _p(FRONT_W, Y_EAVE + 0.02, SIGN_U1 + 0.1))
	_quad("detail", "soffit_pale", _p(SIGN_W_EAVE, Y_SOFFIT, SIGN_U0), _p(FRONT_W, Y_SOFFIT, SIGN_U0), _p(FRONT_W, Y_SOFFIT, SIGN_U1), _p(SIGN_W_EAVE, Y_SOFFIT, SIGN_U1), Vector3.DOWN)
	# Address on the fascia; the unlit roof sign, oval and floodlights ride on the cap.
	var fascia := Face.new(_p(SIGN_W_EAVE - 0.1, 0, 0), Vector3.BACK, Vector3.LEFT)
	_art(fascia, "sign_bright", 14.55, 16.75, Y_FASCIA_LOW + 0.03, Y_EAVE - 0.02, 0.012, Rect2(0.0, 0.625, 0.5, 0.0625))
	var cap := Face.new(_p(SIGN_W_TOP - 0.08, 0, 0), Vector3.BACK, Vector3.LEFT)
	_art(cap, "sign_led", 14.3, 18.5, Y_SIGN_TOP - 0.02, Y_SIGN_CAP + 0.1, 0.05, Rect2(0.0, 0.0, 1.0, 0.25))
	_oval(cap, 13.55, Y_SIGN_CAP - 0.04, 0.36, 0.2)
	for u_lamp: float in [12.1, 19.6]:
		_box("overlay", "frame_grey", _p(SIGN_W_TOP - 0.3, Y_SIGN_TOP + 0.04, u_lamp - 0.19), _p(SIGN_W_TOP - 0.1, Y_SIGN_CAP + 0.06, u_lamp + 0.19))
		_box("overlay", "lamp", _p(SIGN_W_TOP - 0.31, Y_SIGN_TOP + 0.08, u_lamp - 0.15), _p(SIGN_W_TOP - 0.3, Y_SIGN_CAP + 0.03, u_lamp + 0.15))


func _rib(a: Vector3, b: Vector3, out: Vector3, across: Vector3, mat: String = "sign_rib") -> void:
	var half := across * 0.016
	var lift := out * 0.035
	_plane("trim", mat, [a - half, b - half, b - half + lift, a - half + lift], -across)
	_plane("trim", mat, [a + half, b + half, b + half + lift, a + half + lift], across)
	_plane("trim", mat, [a - half + lift, b - half + lift, b + half + lift, a + half + lift], out)


func _oval(f: Face, s: float, y: float, rs: float, ry: float) -> void:
	var sides := 12
	var points: Array = []
	for i in sides:
		var t := TAU * float(i) / sides
		points.append(f.at(s + rs * cos(t), y + ry * sin(t), 0.1))
	_s("trim", "oval").add(points, f.nn)


## Doors, cages, bike rail and mailbox along the orange wall (refs 06, 25).
func _market_fixtures(g0: float) -> void:
	var fw := FRONT_W
	_box("detail", "cage_white", _p(fw - 1.0, g0, 8.3), _p(fw - 0.05, g0 + 1.85, 9.45))
	_box("detail", "cage_tan", _p(fw - 1.0, g0, 9.5), _p(fw - 0.05, g0 + 1.85, 10.65))
	var front := Face.new(_p(fw - 1.0, 0, 0), Vector3.BACK, Vector3.LEFT)
	_art(front, "sign_atlas", 8.65, 9.1, g0 + 1.3, g0 + 1.75, 0.012, NFPA_CELL)
	_art(front, "sign_atlas", 9.95, 10.3, g0 + 0.72, g0 + 1.07, 0.012, NFPA_CELL)
	# The bike rail's black wave.
	var last := _p(fw - 0.6, g0, 10.85)
	for k in range(1, 13):
		var t := float(k) / 12.0
		var next := _p(fw - 0.6, g0 + 0.42 + 0.3 * sin(t * TAU * 1.5 - 1.1), 10.85 + 1.45 * t)
		if k == 12:
			next.y = g0
		_strut("frame_black", last, next, 0.022)
		last = next
	_mailbox(fw - 0.62, fw - 0.1, 12.7, 13.3, g0)
	_box("trim", "plaque", _p(fw - 0.03, g0 + 1.5, 12.95), _p(fw, g0 + 2.0, 13.5))
	# Street signs on the sidewalk (ref 06).
	_sign_post(-6.5, 15.0, g0, 2.6, Rect2(0.125, 0.6875, 0.0625, 0.125), 0.34, 0.5)
	_sign_post(-6.5, 8.7, g0, 2.75, Rect2(0.1875, 0.6875, 0.0625, 0.125), 0.42, 0.58)


## Dark navy collection box with a rounded top, seen end-on from the street.
func _mailbox(w0: float, w1: float, u0: float, u1: float, y0: float) -> void:
	var spring := y0 + 1.0
	var radius := (u1 - u0) * 0.5
	var mid := (u0 + u1) * 0.5
	_box("detail", "mailbox", _p(w0, y0, u0), _p(w1, spring, u1), 8)
	var arch: Array = []
	for k in 9:
		var t := PI * float(k) / 8.0
		arch.append(Vector2(mid + radius * cos(t), spring + radius * sin(t)))
	for k in 8:
		var a: Vector2 = arch[k]
		var b: Vector2 = arch[k + 1]
		_plane("detail", "mailbox", [_p(w0, a.y, a.x), _p(w1, a.y, a.x), _p(w1, b.y, b.x), _p(w0, b.y, b.x)], Vector3(0, (a.y + b.y) * 0.5 - spring, (a.x + b.x) * 0.5 - mid))
		_plane("detail", "mailbox", [_p(w0, spring, mid), _p(w0, a.y, a.x), _p(w0, b.y, b.x)], Vector3.LEFT)


func _sign_post(w: float, u: float, ground_y: float, height: float, cell: Rect2, width: float, tall: float) -> void:
	_cyl("detail", "frame_grey", _p(w, ground_y - 0.1, u), 0.03, height + 0.1, 6)
	var f := Face.new(_p(w - 0.04, 0, 0), Vector3.BACK, Vector3.LEFT)
	_art(f, "sign_atlas", u - width * 0.5, u + width * 0.5, ground_y + height - tall, ground_y + height, 0.01, cell)
	_fb("trim", "frame_grey", f, u - width * 0.5, u + width * 0.5, ground_y + height - tall, ground_y + height, -0.015, 0.005)


# ---------------------------------------------------------------- SSE

func _build_sse() -> void:
	var f := Face.new(_p(0, 0, U_S), Vector3.RIGHT, Vector3.BACK)
	var holes: Array = [Rect2(2.14, 6.22, 2.33, 0.95)]
	for pair: Array in SSE_PAIRS:
		holes.append(Rect2(pair[0], Y_SASH_SILL, float(pair[1]) - float(pair[0]), Y_SASH_HEAD - Y_SASH_SILL))
	var g1 := land_y(40.0, U_S + 0.3)
	var g2 := land_y(62.0, U_S + 0.3)
	var roll1 := Rect2(38.75, Y_FOOT, 3.45, g1 + 3.7 - Y_FOOT)
	var roll2 := Rect2(60.7, Y_FOOT, 3.3, g2 + 3.4 - Y_FOOT)
	var door := Rect2(58.6, Y_FOOT, 1.0, g2 + 2.15 - Y_FOOT)
	var low_holes: Array = [roll1, roll2, door]
	_wall(f, "white", 0.0, W_T2, Y_FOOT, Y_T1, holes)
	_wall(f, "white", W_T2, W_MON0, Y_FOOT, Y_T2, holes)
	_wall(f, "white", W_MON0, W_MON1, Y_FOOT, Y_MON, holes)
	_wall(f, "white", W_MON1, W_C, Y_FOOT, Y_T2, holes + low_holes)
	_wall(f, "white", W_C, 68.23, Y_FOOT, Y_S, low_holes)
	_sash(f, "white", 2.14, 4.47, 6.22, 7.17, 2, [], "pane_sse", "frame_white", 0.12)
	for pair: Array in SSE_PAIRS:
		_sash(f, "white", pair[0], pair[1], Y_SASH_SILL, Y_SASH_HEAD, 2, [0.75, 1.5, 2.25], "pane_sse", "frame_white", 0.2)
	_rollup(f, "white", roll1.position.x, roll1.end.x, roll1.position.y, roll1.end.y, "rollup_white", "maroon")
	_raised_rollup(f, roll2, g2 + 1.1)
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
	_art(f, "sign_atlas", 52.6, 57.5, 6.68, 7.34, 0.03, Rect2(0.5, 0.5, 0.5, 0.125))
	# The winery wall: white boards low down, a pipe run under the sign (ref 13).
	_fb("trim", "rollup_white", f, 45.6, 54.4, g1, g1 + 1.25, 0.0, 0.05)
	_fb("trim", "frame_white", f, 44.0, 59.0, 6.3, 6.36, 0.03, 0.09)
	# The bleached white wall carries only light run-off and a dusty foot.
	_grime_top(f, 0.2, W_T2 - 0.2, 7.22, Y_T1 - 0.14, 0.008, "grime_light")
	_grime_top(f, W_T2 + 0.2, W_MON0, 8.2, Y_T2 - 0.14, 0.012, "grime_light")
	_grime_top(f, W_MON0, W_MON1, 10.2, Y_MON - 0.14, 0.012, "grime_light")
	_grime_top(f, W_MON1, W_C - 0.2, 8.2, Y_T2 - 0.14, 0.012, "grime_light")
	_grime_foot(f, 0.0, 37.0, 3.25, 4.25, 0.008, "grime_light")
	# Conduit and meters by the centre of the wall (ref 12).
	_cyl("trim", "frame_white", _p(27.0, Y_FOOT, U_S + 0.06), 0.03, 8.2 - Y_FOOT, 6)
	_cyl("trim", "frame_white", _p(27.32, Y_FOOT, U_S + 0.06), 0.03, 7.0 - Y_FOOT, 6)
	_box("trim", "frame_grey", _p(26.86, 4.1, U_S), _p(27.46, 4.75, U_S + 0.14))
	_box("trim", "frame_grey", _p(26.95, 5.0, U_S), _p(27.3, 5.35, U_S + 0.12))
	_winery_patio()


## Roll-up door left partly raised: its white curtain over a black gap (ref 13).
func _raised_rollup(f: Face, r: Rect2, gap_top: float) -> void:
	var depth := 0.3
	_reveals(f, "white", r, depth)
	_quad("detail", "door_black", f.at(r.position.x, r.position.y, -depth), f.at(r.end.x, r.position.y, -depth), f.at(r.end.x, r.end.y, -depth), f.at(r.position.x, r.end.y, -depth), f.nn)
	_fb("trim", "rollup_white", f, r.position.x, r.end.x, gap_top, r.end.y, -depth, -0.1)
	_fb("trim", "maroon", f, r.position.x - 0.16, r.position.x, r.position.y, r.end.y + 0.16, 0.0, 0.06)
	_fb("trim", "maroon", f, r.end.x, r.end.x + 0.16, r.position.y, r.end.y + 0.16, 0.0, 0.06)
	_fb("trim", "maroon", f, r.position.x, r.end.x, r.end.y, r.end.y + 0.16, 0.0, 0.06)


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


## Tote stacks, barrels, tables and the shade sail in front of the winery (refs 10-13).
func _winery_patio() -> void:
	for col in 3:
		var w0 := 42.7 + col * 1.2
		var stack := 3 if col == 1 else 2
		for row in stack:
			var u0 := 115.9
			var y0 := land_y(w0, u0) + LOT_LIFT + row * 1.02
			_box("detail", "tote", _p(w0, y0, u0), _p(w0 + 1.14, y0 + 1.0, u0 + 1.14))
			_box("trim", "frame_black", _p(w0 + 0.2, y0 + 0.5, u0 + 1.14), _p(w0 + 0.48, y0 + 0.72, u0 + 1.15))
			_box("trim", "frame_black", _p(w0 + 0.66, y0 + 0.5, u0 + 1.14), _p(w0 + 0.94, y0 + 0.72, u0 + 1.15))
	for spot: Vector2 in [Vector2(47.8, 118.0), Vector2(48.7, 117.2), Vector2(50.2, 118.3), Vector2(51.9, 117.9), Vector2(56.9, 118.3), Vector2(58.1, 117.8), Vector2(66.6, 118.6)]:
		_barrel(spot.x, spot.y)
	for spot: Vector2 in [Vector2(52.9, 119.3), Vector2(55.3, 118.6)]:
		_picnic_table(spot.x, spot.y)
	_shade_sail()


## Coral shade sail: peak tied to the fascia, wings tied off to two flag poles (ref 13).
func _shade_sail() -> void:
	var peak := _p(49.2, 6.98, SSE_CANOPY_U + 0.05)
	var left := _p(46.7, 6.32, 119.5)
	var right := _p(54.0, 6.36, 120.1)
	var rows := 5
	var cols := 8
	var grid: Array = []
	for j in rows + 1:
		var t := float(j) / rows
		var row: Array = []
		for i in cols + 1:
			var s := float(i) / cols
			var p: Vector3 = peak.lerp(left, t).lerp(peak.lerp(right, t), s)
			row.append(p + Vector3.DOWN * (0.62 * sin(PI * s) * pow(t, 1.3) + 0.1 * sin(PI * t)))
		grid.append(row)
	var sail := _s("trim", "sail")
	for j in rows:
		for i in cols:
			var a: Vector3 = grid[j][i]
			var b: Vector3 = grid[j][i + 1]
			var c: Vector3 = grid[j + 1][i + 1]
			var d: Vector3 = grid[j + 1][i]
			var up := (c - a).cross(d - b).normalized()
			if up.y < 0.0:
				up = -up
			if j == 0:
				sail.add_smooth([a, c, d], [up, up, up], up)
			else:
				sail.add_smooth([a, b, c, d], [up, up, up, up], up)
	var ties := [[peak, _p(49.2, Y_SSE_FASCIA_LOW + 0.05, SSE_CANOPY_U)], [left, _p(45.7, 6.5, 120.4)], [right, _p(55.6, 6.55, 120.9)], [right, _p(59.9, 6.9, SSE_CANOPY_U - 0.2)]]
	for tie: Array in ties:
		_strut("frame_black", tie[0], tie[1], 0.008)
	for pole: Vector2 in [Vector2(45.7, 120.4), Vector2(55.6, 120.9)]:
		_cyl("detail", "frame_grey", _p(pole.x, land_y(pole.x, pole.y) - 0.1, pole.y), 0.03, 7.5 - land_y(pole.x, pole.y), 6)


func _barrel(w: float, u: float) -> void:
	var y := land_y(w, u) + LOT_LIFT
	_lathe("detail", "barrel", _p(w, y, u), [Vector2(0.27, 0.0), Vector2(0.33, 0.28), Vector2(0.34, 0.46), Vector2(0.33, 0.64), Vector2(0.27, 0.92), Vector2(0.0, 0.92)], 14)
	_lathe("trim", "frame_black", _p(w, y, u), [Vector2(0.335, 0.2), Vector2(0.342, 0.24)], 14)
	_lathe("trim", "frame_black", _p(w, y, u), [Vector2(0.342, 0.68), Vector2(0.335, 0.72)], 14)


func _picnic_table(w: float, u: float) -> void:
	var y := land_y(w, u) + LOT_LIFT
	_box("detail", "wood", _p(w - 0.95, y + 0.72, u - 0.38), _p(w + 0.95, y + 0.78, u + 0.38))
	for side: float in [-0.72, 0.72]:
		_box("detail", "wood", _p(w - 0.95, y + 0.42, u + side - 0.13), _p(w + 0.95, y + 0.47, u + side + 0.13))
	for leg: float in [-0.75, 0.75]:
		_box("detail", "wood", _p(w + leg - 0.04, y, u - 0.72), _p(w + leg + 0.04, y + 0.42, u + 0.72))
		_box("detail", "wood", _p(w + leg - 0.04, y, u - 0.05), _p(w + leg + 0.04, y + 0.72, u + 0.05))


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
	_cyl("trim", "grey_frame", _p(W_F + 0.07, Y_FOOT, 38.8), 0.04, Y_F - 0.2 - Y_FOOT, 8)
	_grime_top(low, U_E, U_F, 6.6, Y_F - 0.2, 0.008, "grime_light")
	_grime_foot(low, U_E, U_F, 3.2, 4.2, 0.008, "grime_light")
	var ret := Face.new(_p(0, 0, U_E), Vector3.RIGHT, Vector3.FORWARD)
	_wall(ret, "grey", W_E, W_F, Y_FOOT, Y_F)
	# Tall block under the black band, with its roll-up door and hooded entry.
	var tall := Face.new(_p(W_E, 0, 0), Vector3.BACK, Vector3.RIGHT)
	var g := land_y(W_E + 0.4, 30.0)
	var roll := Rect2(28.5, Y_FOOT, 4.3, g + 3.65 - Y_FOOT)
	var door := Rect2(26.8, Y_FOOT, 1.1, g + 2.1 - Y_FOOT)
	_wall(tall, "grey", 0.0, U_E, Y_FOOT, Y_BAND_LOW + 0.1, [roll, door])
	_rollup(tall, "grey", roll.position.x, roll.end.x, roll.position.y, roll.end.y, "rollup_grey", "rollup_frame")
	_door(tall, "grey", "door_black", door.position.x, door.end.x, door.position.y, door.end.y, "grey_frame")
	for u: float in [3.3, 6.9, 10.2, 13.7, 17.1]:
		_fb("trim", "grey", tall, u - 0.15, u + 0.15, Y_FOOT, Y_BAND_LOW, 0.0, 0.1)
	_band(tall, 0.0, U_E, true, false)
	_hood(tall, 20.2, 28.0)
	_grime_foot(tall, 0.0, 26.5, 3.2, 4.2, 0.008, "grime_light")


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
	# One continuous faded mural across the three tiers (refs 18, 05).
	var fit := 36.3
	var y_mural := 7.62
	var y_top := 11.85
	var low_v := 1.0 - (Y_T2 - 0.18 - y_mural) / (y_top - y_mural)
	_art(f, "mural", W_MON1, 45.2, y_mural, Y_T2 - 0.18, 0.012, Rect2(0.0, low_v, (45.2 - W_MON1) / fit, 1.0 - low_v))
	_art(f, "mural", W_MON0, W_MON1, y_mural, y_top, 0.012, Rect2((45.2 - W_MON1) / fit, 0.0, (W_MON1 - W_MON0) / fit, 1.0))
	_art(f, "mural", 8.9, W_MON0, y_mural, Y_T2 - 0.18, 0.012, Rect2((45.2 - W_MON0) / fit, low_v, (W_MON0 - 8.9) / fit, 1.0 - low_v))
	# East block: grey wall, pilasters, roll-up door, black band (refs 16, 19).
	var g := land_y(81.0, -0.4)
	var roll := Rect2(79.65, Y_FOOT, 3.55, g + 3.65 - Y_FOOT)
	_wall(f, "grey", W_D, W_E, Y_FOOT, Y_BAND_LOW + 0.1, [roll])
	_rollup(f, "grey", roll.position.x, roll.end.x, roll.position.y, roll.end.y, "rollup_grey", "rollup_frame")
	_fb("trim", "grey", f, 72.4, 72.7, Y_FOOT, Y_BAND_LOW, 0.0, 0.1)
	_fb("trim", "grey", f, 76.1, 76.4, Y_FOOT, Y_BAND_LOW, 0.0, 0.1)
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
	# The dark roof court behind the low ENE block (May 2026 aerial).
	_quad("trim", "roof_dark", _p(72.5, Y_F - CAP_DROP + 0.02, 44.0), _p(79.5, Y_F - CAP_DROP + 0.02, 44.0), _p(79.5, Y_F - CAP_DROP + 0.02, 57.0), _p(72.5, Y_F - CAP_DROP + 0.02, 57.0), Vector3.UP)


func _rooftop_unit(w: float, u: float, y: float) -> void:
	_box("detail", "unit_grey", _p(w - 1.05, y, u - 0.75), _p(w + 1.05, y + 1.15, u + 0.75))
	_cyl("trim", "frame_black", _p(w - 0.45, y + 1.15, u), 0.42, 0.1, 10)
	_cyl("trim", "frame_black", _p(w + 0.5, y + 1.15, u), 0.42, 0.1, 10)


## Large ventilator on a short curb, its ribbed ball tapering to a cap (refs 05, 18).
func _turbine(w: float, y: float, u: float, size: float) -> void:
	var curb: Array = []
	for p: Vector2 in [Vector2(0.46, 0.0), Vector2(0.37, 0.11), Vector2(0.35, 0.54)]:
		curb.append(p * size)
	var ball: Array = []
	for p: Vector2 in [Vector2(0.37, 0.0), Vector2(0.55, 0.2), Vector2(0.6, 0.4), Vector2(0.51, 0.62), Vector2(0.15, 0.8), Vector2(0.0, 0.82)]:
		ball.append(p * size)
	_lathe("detail", "vent_curb", _p(w, y, u), curb, 14)
	_lathe("detail", "vent_ball", _p(w, y + 0.54 * size, u), ball, 16)


# ---------------------------------------------------------------- setting

## Paved lot round the building, the market sidewalk, bollards, stall lines and the
## props the photos stand around it.
func _build_setting() -> void:
	_build_lot()
	_edge_wear(120.72, -2.0, 69.0, 0.0)
	_edge_wear(124.63, -2.0, 69.0, 0.37)
	# Sidewalk before the market, its low curb, and a walkable ramp over the curb.
	_drape("walk", "sidewalk", SIDEWALK_W, SIGN_W_EAVE, SIDEWALK_U0, SIDEWALK_U1, SIDEWALK_LIFT, 1.5)
	_drape("walk", "porch_floor", SIGN_W_EAVE, FRONT_W, SIDEWALK_U0, SIDEWALK_U1, SIDEWALK_LIFT, 1.5)
	var u := SIDEWALK_U0
	while u < SIDEWALK_U1 - 0.001:
		var un := minf(u + 1.5, SIDEWALK_U1)
		var a := land_y(SIDEWALK_W, u)
		var b := land_y(SIDEWALK_W, un)
		_quad("setting", "curb", _p(SIDEWALK_W, a + LOT_LIFT - 0.02, u), _p(SIDEWALK_W, b + LOT_LIFT - 0.02, un), _p(SIDEWALK_W, b + SIDEWALK_LIFT, un), _p(SIDEWALK_W, a + SIDEWALK_LIFT, u), Vector3.LEFT)
		_walk_tri(_p(SIDEWALK_W - 0.8, a - 0.02, u), _p(SIDEWALK_W - 0.8, b - 0.02, un), _p(SIDEWALK_W, b + SIDEWALK_LIFT, un))
		_walk_tri(_p(SIDEWALK_W - 0.8, a - 0.02, u), _p(SIDEWALK_W, b + SIDEWALK_LIFT, un), _p(SIDEWALK_W, a + SIDEWALK_LIFT, u))
		u = un
	for end_u: float in [SIDEWALK_U0, SIDEWALK_U1]:
		var dir := -1.0 if end_u < 10.0 else 1.0
		var w := SIDEWALK_W
		while w < FRONT_W - 0.001:
			var wn := minf(w + 1.5, FRONT_W)
			var a := land_y(w, end_u)
			var b := land_y(wn, end_u)
			_quad("setting", "curb", _p(w, a + LOT_LIFT - 0.02, end_u), _p(wn, b + LOT_LIFT - 0.02, end_u), _p(wn, b + SIDEWALK_LIFT, end_u), _p(w, a + SIDEWALK_LIFT, end_u), Vector3(0, 0, dir))
			_walk_tri(_p(w, a - 0.02, end_u + dir * 0.8), _p(wn, b - 0.02, end_u + dir * 0.8), _p(wn, b + SIDEWALK_LIFT, end_u))
			_walk_tri(_p(w, a - 0.02, end_u + dir * 0.8), _p(wn, b + SIDEWALK_LIFT, end_u), _p(w, a + SIDEWALK_LIFT, end_u))
			w = wn
	_drape("setting", "paint_blue", SIDEWALK_W, SIDEWALK_W + 0.12, 13.6, 18.2, SIDEWALK_LIFT + 0.008, 1.5)
	for k in BOLLARD_COUNT:
		_bollard(BOLLARD_W, BOLLARD_FIRST_U + BOLLARD_PITCH_M * k)
	_north_annex()
	_red_wall()
	# The big tan container and wire rack on the pavement well back from the Avenue H edge
	# line (refs 05, 18; Aug 2025 aerial), with its primer patches and worn stall lines.
	var tan := _container(-9.4, -6.96, -26.0, -13.8, "container_tan")
	var side := Face.new(_p(-9.4, 0, 0), Vector3.BACK, Vector3.LEFT)
	for patch: Rect2 in [Rect2(-22.5, 1.02, 1.4, 0.61), Rect2(-16.7, 1.02, 1.3, 0.51), Rect2(-15.8, 0.64, 0.4, 0.38), Rect2(-14.2, 1.1, 0.25, 0.4)]:
		_fb("trim", "patch_primer", side, patch.position.x, patch.end.x, tan + patch.position.y, tan + patch.end.y, 0.0, 0.012)
	_grime_top(side, -26.0, -13.8, tan + 1.2, tan + 2.42, 0.014, "grime_rust")
	_wire_rack(-8.6, -26.95, 1.45)
	_line("paint_worn", Vector2(-9.45, -24.7), Vector2(-12.2, -23.2), 0.05)
	_line("paint_worn", Vector2(-7.2, -29.15), Vector2(-12.6, -26.1), 0.05)
	_yard()
	# Green slatted bin enclosure on the 9th Street apron (refs 10, 12).
	var pen := land_y(5.6, 131.6) + LOT_LIFT - 0.05
	_box("detail", "fence_green", _p(3.0, pen, 129.6), _p(8.2, pen + 2.45, 133.6), 8)
	_box("detail", "frame_grey", _p(2.95, pen + 2.42, 129.55), _p(8.25, pen + 2.48, 133.65))
	_art(Face.new(_p(0, 0, 133.6), Vector3.RIGHT, Vector3.BACK), "sign_atlas", 4.2, 6.2, pen + 1.05, pen + 2.2, 0.02, Rect2(0.3125, 0.6875, 0.125, 0.15625))
	# Worn stall lines along the whole Avenue H front (refs 06, 09, 26), yellow ramp pads.
	var stall := 0
	var along := -3.0
	while along < U_S - 2.0:
		for piece in 3:
			# A deterministic share of each line has worn away.
			if (stall * 7 + piece * 5) % 6 != 0:
				_stripe("paint_worn", SIDEWALK_W - 5.0 + piece * 1.65, SIDEWALK_W - 3.45 + piece * 1.65, along, along + 0.1)
		along += 2.75
		stall += 1
	_stripe("paint_yellow", SIDEWALK_W - 1.0, SIDEWALK_W - 0.1, 17.3, 19.4)
	_stripe("paint_yellow", SIDEWALK_W - 1.0, SIDEWALK_W - 0.1, 20.2, 22.3)


## The low corrugated annex along the NNW end, outside the frozen footprint (aerial;
## refs 05, 06, 18), with its big turbine vents: setting, no spray receiver of its own.
func _north_annex() -> void:
	var w0 := 2.5
	var w1 := 46.0
	var u0 := -8.5
	var u1 := -0.03
	var y0 := land_y(w0, u0) - 0.1
	var low := 7.26
	var high := 7.66
	_box("detail", "corrugated", _p(w0, y0, u0), _p(w1, low, u1), 8)
	_plane("detail", "corrugated", [_p(w0, low, u0), _p(w0, low, u1), _p(w0, high, u1)], Vector3.LEFT)
	_plane("detail", "corrugated", [_p(w1, low, u0), _p(w1, low, u1), _p(w1, high, u1)], Vector3.RIGHT)
	_plane("roof", "roof_annex", [_p(w0, low, u0), _p(w1, low, u0), _p(w1, high, u1), _p(w0, high, u1)], Vector3.UP)
	# Sheet-metal eave round the roof (ref 18).
	_box("trim", "coping_grey", _p(w0 - 0.22, low - 0.02, u0 - 0.22), _p(w1 + 0.22, low + 0.07, u0))
	_plane("trim", "coping_grey", [_p(w0 - 0.22, low - 0.02, u0 - 0.22), _p(w0 - 0.22, high - 0.02, u1), _p(w0 - 0.22, high + 0.07, u1), _p(w0 - 0.22, low + 0.07, u0 - 0.22)], Vector3.LEFT)
	for spot: Vector3 in [Vector3(41.4, -3.6, 1.0), Vector3(31.3, -5.6, 1.0), Vector3(27.4, -3.0, 1.3), Vector3(16.3, -5.2, 1.0), Vector3(14.0, -2.8, 0.75), Vector3(5.2, -5.0, 1.0), Vector3(3.6, -2.6, 0.75)]:
		var t := (spot.y - u0) / (u1 - u0)
		_turbine(spot.x, lerpf(low, high, t) - 0.04, spot.y, spot.z)
	# Its wall lamp (ref 18).
	_box("overlay", "lamp", _p(w0 - 0.3, 6.1, -3.6), _p(w0 - 0.1, 6.32, -3.2))


## Rust-red containers, the slatted fence and the small red shed that run north from
## the market along the OSM wall line (refs 06, 07).
func _red_wall() -> void:
	var front := -2.46
	_container(front, -0.02, -24.9, -19.4, "container_red")
	_container(front, -0.02, -19.4, -13.3, "container_red")
	_container(front, -0.02, -13.3, -7.2, "container_red")
	# Slatted fence on steel posts.
	var y0 := land_y(-1.4, -2.0) + SIDEWALK_LIFT - 0.1
	var fence := Face.new(_p(-1.4, 0, 0), Vector3.BACK, Vector3.LEFT)
	_fb("detail", "fence_red", fence, -7.2, 2.9, y0, y0 + 2.62, -0.04, 0.0)
	_quad("detail", "fence_red", fence.at(-7.2, y0, -0.04), fence.at(2.9, y0, -0.04), fence.at(2.9, y0 + 2.62, -0.04), fence.at(-7.2, y0 + 2.62, -0.04), -fence.nn)
	_fb("trim", "frame_grey", fence, -7.2, 2.9, y0 + 2.62, y0 + 2.67, -0.05, 0.02)
	for post_u: float in [-7.1, -4.6, -2.1, 0.4, 2.8]:
		_cyl("detail", "frame_grey", _p(-1.37, y0, post_u), 0.04, 2.66, 8)
	# Small red shed with its grey door.
	var shed := _container(front, -0.02, 2.9, 5.9, "container_red")
	var door := Face.new(_p(front - 0.035, 0, 0), Vector3.BACK, Vector3.LEFT)
	_fb("trim", "door_grey", door, 3.55, 4.55, shed + 0.12, shed + 2.2, 0.0, 0.02)


## A container on its side, its long faces ribbed. Returns its base height.
func _container(w0: float, w1: float, u0: float, u1: float, mat: String) -> float:
	var y0 := land_y((w0 + w1) * 0.5, (u0 + u1) * 0.5) + LOT_LIFT - 0.02
	var y1 := y0 + 2.6
	var edge := mat + "_edge"
	_box("detail", mat, _p(w0, y0, u0), _p(w1, y1, u1), 0)
	# Corner posts and top and bottom rails stand proud of the ribbed sheet.
	_box("trim", edge, _p(w0 - 0.05, y0, u0), _p(w0, y1, u0 + 0.12), 2)
	_box("trim", edge, _p(w0 - 0.05, y0, u1 - 0.12), _p(w0, y1, u1), 2)
	_box("trim", edge, _p(w0 - 0.05, y1 - 0.14, u0), _p(w0, y1, u1), 2)
	_box("trim", edge, _p(w0 - 0.05, y0, u0), _p(w0, y0 + 0.16, u1), 2)
	# Fork pockets in the bottom rail, a metre or so apart at the middle of the long side.
	if u1 - u0 > 8.0:
		for pocket: float in [-1.2, 0.85]:
			var mid := (u0 + u1) * 0.5 + pocket
			_box("trim", "container_casting", _p(w0 - 0.052, y0 + 0.02, mid), _p(w0 - 0.05, y0 + 0.14, mid + 0.36), 2)
	return y0


## Lot and apron, cut from the land triangles themselves and lifted by LOT_LIFT: they
## follow the land exactly, stop at Building 202 and pass under the roads and street
## paint, which keep showing.
func _build_lot() -> void:
	var north := PackedVector2Array([Vector2(LOT_EDGE_N, LOT_N)])
	north.append_array(PackedVector2Array(B202_EDGE))
	north.append_array(PackedVector2Array([Vector2(LOT_E, B202_EDGE[-1].y), Vector2(LOT_E, 0.0), Vector2(0.0, 0.0), Vector2(0.0, U_S), Vector2(_lot_edge(U_S), U_S)]))
	var pieces := {"lot": [north, PackedVector2Array([Vector2(W_E, 0.0), Vector2(LOT_E, 0.0), Vector2(LOT_E, U_E), Vector2(W_E, U_E)]), PackedVector2Array([Vector2(W_F, U_E), Vector2(LOT_E, U_E), Vector2(LOT_E, U_F), Vector2(W_F, U_F)]), PackedVector2Array([Vector2(71.98, U_F), Vector2(LOT_E, U_F), Vector2(LOT_E, U_S), Vector2(68.23, U_S), Vector2(68.23, 94.41), Vector2(65.12, 94.41), Vector2(65.12, 80.165), Vector2(67.9, 80.165), Vector2(67.9, 70.66), Vector2(71.98, 70.66)])], "apron": [PackedVector2Array([Vector2(_lot_edge(U_S), U_S), Vector2(LOT_E, U_S), Vector2(LOT_E, LOT_U1), Vector2(LOT_EDGE_S, LOT_U1)])]}
	for mat: String in pieces:
		for outline: PackedVector2Array in pieces[mat]:
			_cover(mat, outline, LOT_LIFT)
			_cover("lot_stains", outline, STAIN_LIFT)


## Dust and wear along the service road's edge on the apron: a soft strip over the join
## that breaks up its hard line. The road itself stays as it is.
func _edge_wear(u: float, w0: float, w1: float, phase: float) -> void:
	var half := 0.6
	var w := w0
	while w < w1 - 0.001:
		var wn := minf(w + 4.0, w1)
		var points: Array = []
		for c: Vector2 in [Vector2(w, u - half), Vector2(wn, u - half), Vector2(wn, u + half), Vector2(w, u + half)]:
			points.append(_p(c.x, land_y(c.x, c.y) + PAINT_LIFT, c.y))
		var s0 := phase + w / EDGE_WEAR_TILE_M
		var s1 := phase + wn / EDGE_WEAR_TILE_M
		_plane("setting", "edge_wear", points, Vector3.UP, [Vector2(s0, 0.0), Vector2(s1, 0.0), Vector2(s1, 1.0), Vector2(s0, 1.0)])
		w = wn


func _lot_edge(u: float) -> float:
	return lerpf(LOT_EDGE_N, LOT_EDGE_S, (u - LOT_N) / (LOT_U1 - LOT_N))


## The land inside a (w, u) outline, as lot surface. Fails if the land does not cover it.
func _cover(mat: String, outline: PackedVector2Array, lift: float) -> void:
	var covered := 0.0
	for triangle: Array in _land:
		var corners: Array[Vector3] = []
		var flat := PackedVector2Array()
		for corner: Vector3 in triangle:
			var p := corner - origin_world
			corners.append(Vector3(p.dot(axis_w), corner.y, p.dot(axis_u)))
			flat.append(Vector2(corners[-1].x, corners[-1].z))
		for piece: PackedVector2Array in Geometry2D.intersect_polygons(flat, outline):
			var ids := Geometry2D.triangulate_polygon(piece)
			for i in range(0, ids.size(), 3):
				var points: Array = []
				for k in 3:
					var q := piece[ids[i + k]]
					points.append(_p(q.x, _land_plane(corners, q) + lift, q.y))
				var a: Vector3 = points[0]
				var b: Vector3 = points[1]
				var c: Vector3 = points[2]
				var area := absf((b - a).cross(c - a).y) * 0.5
				if area < 0.0005:
					continue
				covered += area
				# Metres in plan, so tiles run on unbroken across the land's creases.
				_plane("lot", mat, points, Vector3.UP, [Vector2(-a.x, -a.z), Vector2(-b.x, -b.z), Vector2(-c.x, -c.z)])
				if lift == LOT_LIFT:
					for point: Vector3 in points:
						_lot_footprint.append(_world(point.x, point.z))
	if absf(covered - _area(outline)) > 1.0:
		_problems.append("B201 lot covers %.1f of %.1f m2." % [covered, _area(outline)])


func _land_plane(c: Array[Vector3], q: Vector2) -> float:
	var n := (c[1] - c[0]).cross(c[2] - c[0])
	return c[0].y - (n.x * (q.x - c[0].x) + n.z * (q.y - c[0].z)) / n.y


func _area(outline: PackedVector2Array) -> float:
	var sum := 0.0
	for i in outline.size():
		var a := outline[i]
		var b := outline[(i + 1) % outline.size()]
		sum += a.x * b.y - b.x * a.y
	return absf(sum) * 0.5


## The containers, tarps and odds and ends that hide the ENE middle walls (Sep 2025
## refs 14, 22; Aug 2025 aerial). Door numbers are plain plates; nothing is copied.
func _yard() -> void:
	var tops := {}
	for row: Array in YARD_LOW:
		var u0: float = row[0]
		var length: float = row[1]
		var y := land_y(YARD_FACE_W - length * 0.5, u0 + 1.22) + LOT_LIFT - 0.02
		_shipping(YARD_FACE_W, u0, y, length, row[2], row[3])
		tops[u0] = y + CONTAINER_TALL + 0.01
	for row: Array in YARD_HIGH:
		_shipping(row[4], row[0], tops[row[0]], row[1], row[2], row[3])
	# A flat-ended grey box over the "3" stack (ref 14), and its door numbers.
	var blank_u := 65.3
	_box("detail", "container_grey", _p(YARD_UPPER_W - 11.2, tops[blank_u], blank_u), _p(YARD_UPPER_W, tops[blank_u] + CONTAINER_TALL, blank_u + CONTAINER_WIDE))
	var blank := Face.new(_p(YARD_UPPER_W, 0, 0), Vector3.BACK, Vector3.RIGHT)
	_fb("trim", "container_grey_edge", blank, blank_u, blank_u + CONTAINER_WIDE, tops[blank_u], tops[blank_u] + CONTAINER_TALL, 0.0, 0.02)
	_door_number(blank, blank_u + 0.5, tops[blank_u] + 1.15, 2, 0.022)
	var face := Face.new(_p(YARD_FACE_W, 0, 0), Vector3.BACK, Vector3.RIGHT)
	_door_number(face, blank_u + 0.825, tops[blank_u] - 1.05, 3, 0.03)
	var upper_door := Face.new(_p(YARD_UPPER_W, 0, 0), Vector3.BACK, Vector3.RIGHT)
	_door_number(upper_door, 60.25 + 2.1, tops[60.25] + 0.65, 4, 0.03)
	# Rust stack's long north side: a plain stencil on each tier (refs 14, 22).
	var north := Face.new(_p(0, 0, 79.7), Vector3.RIGHT, Vector3.FORWARD)
	for y: float in [tops[79.7] - CONTAINER_TALL, tops[79.7]]:
		_art(north, "sign_atlas", YARD_FACE_W - 1.15, YARD_FACE_W - 0.72, y + 0.42, y + 2.25, 0.015, Rect2(0.75, 0.75, 0.03125, 0.25))
	# Tarps on a wire between the stacks.
	var ground := land_y(YARD_FACE_W, 66.0) + LOT_LIFT
	_tarp(YARD_FACE_W - 0.1, 62.69, 65.3, ground, 2.3)
	_tarp(YARD_FACE_W - 0.1, 67.74, 71.75, ground, 2.3)
	# White site cabin behind the tarp, with its wall air conditioner (ref 14).
	var cabin_y := land_y(76.0, 69.7) + LOT_LIFT
	_box("detail", "cabin_white", _p(73.0, cabin_y, 67.9), _p(80.6, cabin_y + 3.5, 71.6))
	_box("trim", "band_plain", _p(72.9, cabin_y + 3.5, 67.8), _p(80.7, cabin_y + 3.58, 71.7))
	_box("trim", "frame_white", _p(80.6, cabin_y + 2.72, 70.3), _p(80.95, cabin_y + 3.12, 70.95), 1)
	# Deck and bent conduit on the single rust box (ref 14).
	var deck_y: float = tops[74.2]
	_box("detail", "wood", _p(YARD_FACE_W - 5.9, deck_y, 74.25), _p(YARD_FACE_W - 0.1, deck_y + 0.14, 76.6))
	for pipe: Array in [[80.6, 75.2, 2.2], [81.8, 75.6, 1.8], [83.0, 75.0, 2.5]]:
		_bent_pipe(pipe[0], deck_y + 0.14, pipe[1], pipe[2])
	_travel_trailer(82.6, 77.75)
	var pallet_y := land_y(83.0, 78.0) + LOT_LIFT
	for bar: Rect2 in [Rect2(81.6, 76.5, 3.0, 0.12), Rect2(81.6, 79.3, 3.0, 0.12), Rect2(81.6, 76.5, 0.12, 2.9), Rect2(84.48, 76.5, 0.12, 2.9), Rect2(83.0, 76.5, 0.12, 2.9)]:
		_box("trim", "plywood", _p(bar.position.x, pallet_y, bar.position.y), _p(bar.end.x, pallet_y + 0.11, bar.end.y), 4)
	_quad("trim", "plywood", _p(81.6, pallet_y + 0.06, 76.5), _p(84.6, pallet_y + 0.06, 76.5), _p(84.6, pallet_y + 0.06, 79.42), _p(81.6, pallet_y + 0.06, 79.42), Vector3.UP)
	# Yellow tray on the "17" box and boards leaning on its long side (ref 22).
	var tray: float = tops[85.0]
	_box("detail", "yellow", _p(YARD_FACE_W - 5.0, tray, 85.2), _p(YARD_FACE_W - 0.6, tray + 0.42, 87.2))
	var lean_y := land_y(80.0, 84.6) + LOT_LIFT
	for board: Vector2 in [Vector2(79.0, 81.2), Vector2(80.3, 83.1)]:
		_plane("trim", "wood_dark", [_p(board.x, lean_y, 84.3), _p(board.y, lean_y, 84.3), _p(board.y, lean_y + 1.1, 84.98), _p(board.x, lean_y + 1.1, 84.98)], Vector3(0, 0.5, -1))
	# Notice on the plain grey wall past the last stack (ref 14).
	var notice_y := land_y(85.2, U_F + 0.4) + 2.4
	_art(Face.new(_p(0, 0, U_F), Vector3.RIGHT, Vector3.BACK), "sign_atlas", 85.0, 85.5, notice_y, notice_y + 0.6, 0.012, Rect2(0.1875, 0.6875, 0.0625, 0.125))
	# Dish on its mast and a lamp on the top corner (ref 14).
	var mast_y: float = tops[60.25] + CONTAINER_TALL
	_cyl("trim", "frame_grey", _p(YARD_UPPER_W - 4.0, mast_y, 61.6), 0.03, 1.15, 6)
	_lathe("trim", "frame_white", _p(YARD_UPPER_W - 4.0, mast_y + 1.0, 61.6), [Vector2(0.0, 0.0), Vector2(0.2, 0.05), Vector2(0.34, 0.14)], 12)
	_box("trim", "frame_white", _p(YARD_UPPER_W, mast_y - 0.34, 60.1), _p(YARD_UPPER_W + 0.14, mast_y - 0.16, 60.42))


## One shipping container with its doors facing Avenue I. number 0 has no plate.
func _shipping(face_w: float, u0: float, y0: float, length: float, paint: String, number: int) -> void:
	var u1 := u0 + CONTAINER_WIDE
	var top := y0 + CONTAINER_TALL
	var mid := (u0 + u1) * 0.5
	var edge := paint + "_edge"
	var rod := paint + "_rod"
	var seam := paint + "_seam"
	_box("detail", paint, _p(face_w - length, y0, u0), _p(face_w, top, u1), 2)
	# Solid door end, with posts, rails and the raised bands of the leaves.
	var f := Face.new(_p(face_w, 0, 0), Vector3.BACK, Vector3.RIGHT)
	_fb("detail", edge, f, u0, u1, y0, top, 0.0, 0.015)
	_fb("trim", edge, f, u0, u0 + 0.11, y0, top, 0.015, 0.06)
	_fb("trim", edge, f, u1 - 0.11, u1, y0, top, 0.015, 0.06)
	_fb("trim", edge, f, u0 + 0.11, u1 - 0.11, top - 0.16, top, 0.015, 0.05)
	_fb("trim", edge, f, u0 + 0.11, u1 - 0.11, y0, y0 + 0.2, 0.015, 0.05)
	_fb("trim", "container_casting", f, mid - 0.01, mid + 0.01, y0 + 0.2, top - 0.16, 0.015, 0.02)
	for band in 4:
		var yb := y0 + 0.5 + band * 0.5
		_fb("trim", seam, f, u0 + 0.16, mid - 0.04, yb, yb + 0.05, 0.015, 0.018)
		_fb("trim", seam, f, mid + 0.04, u1 - 0.16, yb, yb + 0.05, 0.015, 0.018)
	# Four lock rods with their keepers and handles.
	for offset: float in [-0.62, -0.17, 0.17, 0.62]:
		var s := mid + offset
		_fb("trim", rod, f, s - 0.018, s + 0.018, y0 + 0.12, top - 0.1, 0.03, 0.06)
		_fb("trim", rod, f, s - 0.05, s + 0.05, y0 + 0.1, y0 + 0.2, 0.03, 0.065)
		_fb("trim", rod, f, s - 0.05, s + 0.05, top - 0.2, top - 0.1, 0.03, 0.065)
		var towards := 0.32 if offset < 0.0 else -0.32
		_fb("trim", rod, f, minf(s, s + towards), maxf(s, s + towards), y0 + 0.92, y0 + 0.96, 0.06, 0.075)
	for corner: Vector2 in [Vector2(u0, y0), Vector2(u1 - 0.14, y0), Vector2(u0, top - 0.1), Vector2(u1 - 0.14, top - 0.1)]:
		_fb("trim", seam, f, corner.x, corner.x + 0.14, corner.y, corner.y + 0.1, 0.03, 0.062)
	if number != 0:
		_door_number(f, mid - 0.395, y0 + 1.9, number, 0.03)
	if number >= 15:
		_art(f, "sign_atlas", u0 + 0.28, u0 + 0.56, y0 + 0.5, y0 + 0.92, 0.021, Rect2(0.84375, 0.75, 0.03125, 0.09375))
		_art(f, "sign_atlas", mid - 0.58, mid - 0.2, y0 + 1.05, y0 + 1.65, 0.021, Rect2(0.78125, 0.75, 0.0625, 0.125))
	elif paint == "container_grey" and number != 0:
		_fb("trim", "lock_red", f, mid - 0.2, mid + 0.2, y0 + 0.86, y0 + 0.94, 0.08, 0.095)
	_grime_top(f, u0 + 0.12, u1 - 0.12, y0 + 0.9, top - 0.17, 0.052, "grime_rust" if paint == "container_rust" else "grime_light")
	var sides := [Face.new(_p(0, 0, u0), Vector3.RIGHT, Vector3.FORWARD), Face.new(_p(0, 0, u1), Vector3.RIGHT, Vector3.BACK)]
	for side: Face in sides:
		_grime_top(side, face_w - length, face_w, y0 + 0.6, top - 0.1, 0.008, "grime_rust" if paint == "container_rust" else "grime")


func _door_number(f: Face, s: float, y: float, number: int, d: float) -> void:
	var cell := float(DOOR_NUMBERS[number])
	_art(f, "sign_atlas", s - 0.17, s + 0.17, y - 0.17, y + 0.17, d, Rect2(0.4375 + cell * 0.03125, 0.75, 0.03125, 0.0625))


## A plastic tarp strung between stacks: bellied, its corners pulled in (refs 14, 22).
func _tarp(w: float, u0: float, u1: float, y0: float, height: float) -> void:
	var across := 12
	var up := 4
	var grid: Array = []
	for j in up + 1:
		var t := float(j) / up
		var row: Array = []
		for i in across + 1:
			var s := float(i) / across
			var belly := sin(PI * s) * sin(PI * t)
			var inset := 0.02 * cos(PI * t) * cos(PI * t)
			var arch := 0.02 * sin(PI * s) * t
			row.append(_p(w + 0.05 * belly + 0.006 * sin(s * 26.0 + t * 2.5), y0 + height * t + arch, lerpf(u0 + inset, u1 - inset, s)))
		grid.append(row)
	var sheet := _s("detail", "tarp")
	for j in up:
		for i in across:
			var a: Vector3 = grid[j][i]
			var b: Vector3 = grid[j][i + 1]
			var c: Vector3 = grid[j + 1][i + 1]
			var d: Vector3 = grid[j + 1][i]
			sheet.add_smooth([a, b, c, d], [_tarp_normal(grid, i, j), _tarp_normal(grid, i + 1, j), _tarp_normal(grid, i + 1, j + 1), _tarp_normal(grid, i, j + 1)], Vector3.RIGHT)
	for i in across:
		_strut("frame_black", grid[up][i], grid[up][i + 1], 0.012)
		_strut("frame_black", grid[0][i], grid[0][i + 1], 0.012)
		if i % 2 == 1:
			_strut("frame_black", grid[up][i], (grid[up][i] as Vector3) + Vector3(0.0, 0.09, 0.0), 0.006)
	for j in up:
		_strut("frame_black", grid[j][0], grid[j + 1][0], 0.012)
		_strut("frame_black", grid[j][across], grid[j + 1][across], 0.012)


func _tarp_normal(grid: Array, i: int, j: int) -> Vector3:
	var row: Array = grid[j]
	var along: Vector3 = (row[mini(i + 1, row.size() - 1)] as Vector3) - (row[maxi(i - 1, 0)] as Vector3)
	var rise: Vector3 = (grid[mini(j + 1, grid.size() - 1)][i] as Vector3) - (grid[maxi(j - 1, 0)][i] as Vector3)
	var n := along.cross(rise).normalized()
	return n if n.x > 0.0 else -n


## A length of bent conduit standing on the deck (ref 14).
func _bent_pipe(w: float, y: float, u: float, height: float) -> void:
	var points: Array[Vector3] = []
	for k in 7:
		var t := float(k) / 6.0
		points.append(_p(w + 0.5 * t * t, y + height * sin(t * PI * 0.55), u + 0.12 * sin(t * 3.0)))
	for k in 6:
		_strut("frame_grey", points[k], points[k + 1], 0.018)


## A small white travel trailer, nose to the road, in the gap between stacks (ref 14).
func _travel_trailer(w: float, u: float) -> void:
	var y := land_y(w, u) + LOT_LIFT
	var half := 1.04
	var length := 5.2
	var floor_y := y + 0.52
	var top := y + 2.5
	var section := [Vector2(-half, floor_y), Vector2(-half, top - 0.4), Vector2(-half + 0.14, top - 0.14), Vector2(-half + 0.4, top), Vector2(half - 0.4, top), Vector2(half - 0.14, top - 0.14), Vector2(half, top - 0.4), Vector2(half, floor_y)]
	var cap: Array = []
	for i in section.size():
		var a: Vector2 = section[i]
		cap.append(_p(w, a.y, u + a.x))
		if i + 1 < section.size():
			var b: Vector2 = section[i + 1]
			var mid := (a + b) * 0.5
			_plane("detail", "trailer_white", [_p(w - length, a.y, u + a.x), _p(w, a.y, u + a.x), _p(w, b.y, u + b.x), _p(w - length, b.y, u + b.x)], Vector3(0, mid.y - (floor_y + top) * 0.5, mid.x))
	_plane("detail", "trailer_white", cap, Vector3.RIGHT)
	var nose := Face.new(_p(w, 0, 0), Vector3.BACK, Vector3.RIGHT)
	_fb("trim", "glass_dark", nose, u - 0.82, u + 0.82, floor_y + 0.86, floor_y + 1.42, 0.0, 0.015)
	_fb("trim", "trailer_skirt", nose, u - half, u + half, floor_y, floor_y + 0.42, 0.0, 0.015)
	_box("detail", "underbody", _p(w - length + 0.3, y, u - 0.8), _p(w - 0.2, floor_y, u + 0.8))
	_strut("trailer_skirt", _p(w, floor_y + 0.1, u), _p(w + 1.25, floor_y - 0.02, u), 0.05)
	_box("trim", "trailer_skirt", _p(w + 0.25, floor_y + 0.04, u - 0.32), _p(w + 0.8, floor_y + 0.38, u + 0.32))
	_cyl("trim", "frame_black", _p(w + 1.15, y, u), 0.03, floor_y - y, 6)


## The white wire rack by the tan container (ref 05).
func _wire_rack(w: float, u: float, turn: float) -> void:
	var y := land_y(w, u) + LOT_LIFT
	var along := Vector3(sin(turn), 0.0, cos(turn))
	var across := Vector3(cos(turn), 0.0, -sin(turn))
	var corners: Array[Vector3] = []
	for corner: Vector2 in [Vector2(-0.45, -0.9), Vector2(0.45, -0.9), Vector2(0.45, 0.9), Vector2(-0.45, 0.9)]:
		corners.append(_p(w, y, u) + across * corner.x + along * corner.y)
		_cyl("detail", "frame_white", corners[-1], 0.016, 1.85, 6)
	for shelf in 4:
		var lift := Vector3.UP * (0.28 + shelf * 0.5)
		for i in 4:
			_strut("frame_white", corners[i] + lift, corners[(i + 1) % 4] + lift, 0.012)
		for wire in 7:
			var t := (float(wire) + 1.0) / 8.0
			_strut("frame_white", corners[0].lerp(corners[3], t) + lift, corners[1].lerp(corners[2], t) + lift, 0.005)


func _stripe(mat: String, w0: float, w1: float, u0: float, u1: float) -> void:
	_drape("setting", mat, w0, w1, u0, u1, PAINT_LIFT, 2.0)


## A painted line from a to b, both (w, u), on the land.
func _line(mat: String, a: Vector2, b: Vector2, half: float) -> void:
	var across := Vector2(b.y - a.y, a.x - b.x).normalized() * half
	var pieces := ceili(a.distance_to(b) / 1.5)
	for i in pieces:
		var p := a.lerp(b, float(i) / pieces)
		var q := a.lerp(b, float(i + 1) / pieces)
		var corners: Array = []
		for c: Vector2 in [p - across, q - across, q + across, p + across]:
			corners.append(_p(c.x, land_y(c.x, c.y) + PAINT_LIFT, c.y))
		_plane("setting", mat, corners, Vector3.UP)


## A walkable face, wound clockwise from above so the stock player meets its top.
func _walk_tri(a: Vector3, b: Vector3, c: Vector3) -> void:
	if (b - a).cross(c - a).y > 0.0:
		_walk_faces.append_array(PackedVector3Array([a, c, b]))
	else:
		_walk_faces.append_array(PackedVector3Array([a, b, c]))


## Concrete-filled guard post with a domed head and a dark band (refs 06, 25).
func _bollard(w: float, u: float) -> void:
	var y := land_y(w, u) + SIDEWALK_LIFT - 0.1
	_lathe("detail", "bollard", _p(w, y, u), [Vector2(0.21, 0.0), Vector2(0.21, 1.02), Vector2(0.17, 1.12), Vector2(0.1, 1.18), Vector2(0.0, 1.2)], 20)
	_lathe("trim", "band_plain", _p(w, y, u), [Vector2(0.214, 0.86), Vector2(0.214, 0.98)], 20)


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
		m.albedo_color = Color(float(rgb[0]) / 255.0, float(rgb[1]) / 255.0, float(rgb[2]) / 255.0)
		m.roughness = float(paint[1])
		var tile := str(paint[2])
		if not tile.is_empty():
			if tile in ["ribs", "dots", "mesh", "slats", "speckle"]:
				m.albedo_texture = _pattern_texture(tile)
				if tile == "ribs":
					m.normal_enabled = true
					m.normal_texture = _relief_texture("ribs")
			else:
				m.albedo_texture = _texture(TEX + {"stucco": "stucco_paint.png", "membrane": "roof_membrane.png"}[tile])
			m.uv1_scale = Vector3(1.0 / float(paint[3]), 1.0 / float(paint[3]), 1.0)
			m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	else:
		match key:
			"glass":
				# A warm body under a plain dielectric sheen: the sky's blue brings it to neutral.
				m.albedo_color = Color(0.29, 0.255, 0.235, 0.9)
				m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				m.roughness = 0.16
				m.metallic_specular = 0.5
			"interior":
				m.albedo_texture = _texture(TEX + "market_interior.png")
				m.albedo_color = Color(0.42, 0.42, 0.42)
				m.roughness = 0.9
			# Local ground: pale worn lot, broad apron, plain sidewalk concrete.
			"lot":
				m.albedo_texture = _texture(TEX + "lot_worn.png")
				m.albedo_color = Color(0.7, 0.69, 0.67)
				m.uv1_scale = Vector3(1.0 / 9.0, 1.0 / 9.0, 1.0)
				m.roughness = 1.0
			"lot_stains":
				m.albedo_texture = _texture(TEX + "lot_stains.png")
				m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				m.uv1_scale = Vector3(1.0 / STAIN_TILE_M, 1.0 / STAIN_TILE_M, 1.0)
				m.roughness = 1.0
				m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
				m.render_priority = -1
			"edge_wear":
				m.albedo_texture = _texture(TEX + "edge_wear.png")
				m.albedo_color = Color(0.43, 0.42, 0.4)
				m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				m.roughness = 1.0
			"apron":
				m.albedo_texture = _texture(TEX + "apron_concrete.png")
				m.albedo_color = Color(0.53, 0.52, 0.5)
				m.uv1_scale = Vector3(1.0 / 11.0, 1.0 / 11.0, 1.0)
				m.roughness = 0.95
			"sidewalk", "porch_floor":
				m.albedo_texture = _texture(TEX + "apron_concrete.png")
				m.albedo_color = Color(0.62, 0.6, 0.545) if key == "sidewalk" else Color(0.82, 0.79, 0.73)
				m.uv1_scale = Vector3(1.0 / 6.0, 1.0 / 6.0, 1.0)
				m.roughness = 0.92
			"paint_worn":
				m.albedo_color = Color(0.86, 0.85, 0.8, 0.55)
				m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				m.roughness = 0.9
			"sign_sheet", "sign_plain":
				m.albedo_texture = _texture(TEX + key + ".png")
				m.roughness = 0.72
				m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
			"sign_atlas", "sign_led", "sign_bright":
				m.albedo_texture = _texture(TEX + "sign_atlas.png")
				m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				m.roughness = 0.7
				m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
				if key == "sign_bright":
					m.emission_enabled = true
					m.emission_texture = m.albedo_texture
					m.emission_energy_multiplier = 0.45
			"mural":
				m.albedo_texture = _texture(TEX + "mural_nnw.png")
				m.roughness = 0.9
			"banner":
				m.albedo_texture = _texture(TEX + "banner.png")
				m.roughness = 0.9
			"grime", "grime_light", "grime_rust":
				m.albedo_texture = _texture(TEX + "grime_strip.png")
				m.albedo_color = {"grime": Color(0.29, 0.26, 0.22, 1.0), "grime_light": Color(0.29, 0.26, 0.22, 0.45), "grime_rust": Color(0.4, 0.2, 0.11, 0.85)}[key]
				m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				m.roughness = 1.0
			"posters":
				m.albedo_texture = _texture(TEX + "shop_posters.png")
				m.albedo_color = Color(0.5, 0.48, 0.46)
				m.roughness = 0.5
			"sail":
				m.albedo_color = Color8(158, 72, 52)
				m.cull_mode = BaseMaterial3D.CULL_DISABLED
				m.roughness = 0.85
			"lamp":
				m.albedo_color = Color(0.95, 0.95, 0.9)
				m.emission_enabled = true
				m.emission = Color(1.0, 0.98, 0.9)
				m.emission_energy_multiplier = 0.5
			"rollup_grey", "rollup_white":
				m.albedo_color = Color8(150, 154, 154) if key == "rollup_grey" else Color8(232, 230, 222)
				m.albedo_texture = _pattern_texture("slat_rows")
				m.normal_enabled = true
				m.normal_texture = _relief_texture("slat_rows")
				m.uv1_scale = Vector3(1.0, 1.0 / SLAT_PITCH_M, 1.0)
				m.roughness = 0.6
			_:
				m.albedo_color = Color(1, 0, 1)
	_materials[key] = m
	return m


## A small repeating pattern: vertical ribs, perforation, slatted diamond mesh,
## fence slats, or the mottle of the plum fence.
func _pattern_texture(kind: String) -> ImageTexture:
	if _textures.has(kind):
		return _textures[kind]
	var size := 64 if kind == "speckle" else 32 if kind in ["ribs", "slat_rows"] else 16
	var img := Image.create(size, size, false, Image.FORMAT_RGB8)
	var noise := RandomNumberGenerator.new()
	noise.seed = 201
	for y in size:
		for x in size:
			var g := 1.0
			match kind:
				"ribs":
					g = lerpf(0.9, 1.0, _sheet_height(x))
				"slat_rows":
					g = lerpf(0.66, 1.0, _sheet_height(y))
				"dots":
					g = 0.28 if Vector2(x - 8, y - 8).length() < 4.6 else 1.0
				"mesh":
					g = 0.74 if (x + y) % 16 < 2 or (x - y + 16) % 16 < 2 else 1.0
				"slats":
					g = 0.7 if x % 8 < 2 else 1.0
				"speckle":
					g = 0.72 + 0.56 * noise.randf()
			img.set_pixel(x, y, Color(g, g, g))
	img.generate_mipmaps()
	var texture := ImageTexture.create_from_image(img)
	_textures[kind] = texture
	return texture


## Sheet profile over 32 pixels, the same either side of a valley: crest 1, valley 0.
func _sheet_height(x: int) -> float:
	var c := absf(float(posmod(x, 32)) - 15.5)
	return clampf((c - 4.0) / 5.0, 0.0, 1.0)


## The sheet's relief as a normal map, so the light picks it out at any hour.
func _relief_texture(kind: String) -> ImageTexture:
	var key := kind + "_relief"
	if _textures.has(key):
		return _textures[key]
	var img := Image.create(32, 32, false, Image.FORMAT_RGB8)
	for y in 32:
		for x in 32:
			var n := Vector3(0.0, 0.0, 1.0)
			if kind == "ribs":
				n.x = (_sheet_height(x - 1) - _sheet_height(x + 1)) * 1.0
			else:
				n.y = (_sheet_height(y + 1) - _sheet_height(y - 1)) * 1.6
			n = n.normalized()
			img.set_pixel(x, y, Color(n.x * 0.5 + 0.5, n.y * 0.5 + 0.5, n.z * 0.5 + 0.5))
	img.generate_mipmaps(true)
	var texture := ImageTexture.create_from_image(img)
	_textures[key] = texture
	return texture


func _commit() -> void:
	var names := {"wall": "WallMesh", "roof": "RoofMesh", "detail": "DetailMesh", "trim": "TrimMesh", "overlay": "OverlayMesh", "setting": "SettingMesh", "walk": "SidewalkMesh", "lot": "LotMesh"}
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
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if role in ["setting", "walk", "overlay", "lot"] else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		_tag(inst, "building_wall" if role == "wall" else "none", ROOF_KEY if role == "roof" else WALL_KEY)
		if role == "walk":
			sidewalk.add_child(inst)
		elif role == "lot":
			# Ground, not building: the replacement moves it to the world's ground parent.
			var lot := Node3D.new()
			lot.name = LOT_NODE
			lot.set_meta("feature_kind", "major_area")
			lot.set_meta("source_keys", [SOURCE_KEY])
			lot.set_meta("derived_object_key", "site:" + SOURCE_KEY + ":lot")
			lot.set_meta(VisibleGround.FOOTPRINT_META, _lot_footprint)
			lot.set_meta(VisibleGround.LIFT_META, LOT_LIFT)
			lot.add_child(inst)
			add_child(lot)
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
			for si in mesh.get_surface_count():
				var arr: Array = mesh.surface_get_arrays(si)
				var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				var ids: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
				for i in ids:
					walk.append(verts[i])
			sidewalk.add_child(_contact("SidewalkContact", walk, "none", WALL_KEY, false))


func _contact(body_name: String, faces: PackedVector3Array, receiver: String, key: String, spray: bool) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = body_name
	body.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
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
