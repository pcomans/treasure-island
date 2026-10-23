extends RefCounted

## Isle House photo-based massing and low-block facade (2026-10-22 ferry L1/L2
## pass; 2026-10-23 rework from a component reading of the Sep 2025 Street View
## and DBA photos).
## Massing (built beside the high facade from the frozen low and high records):
## the WSW wing and the west part of the NNW face rise to the level-7 roof deck
## (double-height base plus five storeys, about 21m), the ENE/NNW-east part stays
## at the generated 15m; tower roof, penthouse and guardrail.
## Low facade (attached to the low wall receiver, replacing the older overlay):
## WSW and ENE white panel cladding in 6.4m modules of a projecting window-box
## stack and a flat strip with a narrow window per storey, over a double-height
## storefront base with charcoal brick piers and concrete columns; NNW light
## speckled brick with slim staggered windows over a charcoal brick base.
## Heights, depths, counts and cadence are production inference scaled from those
## photos, not surveyed. Added volumes and projecting boxes own solid collision
## on the spray layer with receiver_kind none.

const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const HIGH_ROOF_KEY := "building-composite:w1249412094:w1282547786:roof"
const LOW_TOP_Y := 19.103
const HIGH_TOP_Y := 71.103
# ROOT height override (2026-10-22, reference-supported, medium confidence,
# production inference): the ih17 matched pose reads the tower about 12% short
# and dba-50 shows 17-18 floors above level 7, so the tower rises from the
# generated 67m to 75m on its frozen footprint.
const TOWER_TOP_Y := 79.1
# Level-7 deck: double-height base (to 10.25) plus five 2.97m storeys.
const DECK_Y := 25.1
const STOREY_BASE_Y := 10.25
const STOREY_M := 2.97
const WINDOW_SILL_ABOVE_STOREY := 0.75
const WINDOW_H := 1.9
# The tall L: a WSW strip WING_DEPTH deep plus the NNW wing NNW_TALL_M along the
# NNW face (ih17: tall west volume about 24m of the 43m face), NNW_WING_S deep.
const WING_DEPTH := 14.0
const NNW_TALL_M := 24.0
const NNW_WING_S := 12.0
const FACE_OFFSET := 0.036
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1

const LOW_RECEIVER_KEY := LOW_WALL_KEY
const LOW_SOURCE_KEY := "w1282547787"
# Low facade layout (u along each side from its first run's start).
const FIELD_OFFSET := 0.012
const MODULE_M := 6.4
const STACK_W := 3.4
const STACK_DEPTH := 0.6
# Front face of a faceted stack: 0.3m narrower each side than its wall base.
const STACK_FRONT_INSET := 0.3
const SOFFIT_Y := 10.25
const CORNER_BRICK_M := 4.2
# Tower podium (ih08, ih14, ih18, dba-50): the east end (ENE runs and the SE east
# of the central glazed strip) steps down to three brick storeys; the tower
# oversails the podium on a white ledge above the dark level-7 band.
const EAST_PODIUM_TOP_Y := 19.16
const SE_STEP_U_M := 22.8
const LEVEL7_BAND_M := 3.3
const LEDGE_DEPTH := 0.9
const LEDGE_H := 0.4
const STOREFRONT_TOP := 9.5
# WSW folds (ih01, ih02): each 6.4m module is an asymmetric sawtooth in plan, a
# long shallow facet folding FOLD_DEPTH inside the frozen footprint line and a
# short steep facet (FOLD_SHORT_M wide) back out. The wide facets turn toward the
# ESE sun (N.S about +0.11) and the narrow ones away from it (about -0.27), and
# the narrow ones face a viewer up the avenue from the NW (ih02), so they read as
# dark vertical strips between lit faces. The double-height base sits BASE_RECESS inside the line
# under a white soffit, between corner piers. The low receiver follows this geometry.
const FOLD_DEPTH := 0.8
const FOLD_SHORT_M := 1.6
const BASE_RECESS := 1.0
const PIER_START := 0.6
const PIER_END := 0.3
const MATERIALS := {
	"wall": preload("res://game/resources/materials/world/isle_house/isle_house_panel_white.tres"),
	"brick": preload("res://game/resources/materials/world/isle_house/isle_house_brick_light.tres"),
	"concrete": preload("res://game/resources/materials/world/isle_house/isle_house_concrete.tres"),
	"roof": preload("res://game/resources/materials/world/isle_house/isle_house_support_grey.tres"),
	"trim": preload("res://game/resources/materials/world/isle_house/isle_house_panel_white.tres"),
	"frame": preload("res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres"),
	"glass": preload("res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres"),
	"glass_dark": preload("res://game/resources/materials/world/isle_house/isle_house_glass_dark.tres"),
	"tower": preload("res://game/resources/materials/world/isle_house/isle_house_tower_light.tres"),
}

var _surfaces := {}
var _roof_surfaces := {}
var _collision := PackedVector3Array()
var _roof_boxes := 0


static func build(high_wall: Dictionary) -> Dictionary:
	var chunk: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	if not chunk is Dictionary:
		return {"ok": false, "message": "Isle House massing could not read its chunk."}
	var low := _record(chunk.records, LOW_WALL_KEY)
	var high_roof := _record(chunk.records, HIGH_ROOF_KEY)
	if low.is_empty() or high_roof.is_empty() or (low.vertices as Array).size() != 156 \
		or not is_equal_approx(float(low.get("top_elevation_m", 0.0)), LOW_TOP_Y) \
		or not is_equal_approx(float(high_roof.get("top_elevation_m", 0.0)), HIGH_TOP_Y):
		return {"ok": false, "message": "Isle House massing source records did not match."}
	var builder: RefCounted = (load("res://game/scripts/world/facades/isle_house_massing_l1.gd") as GDScript).new()
	return builder._build(low, high_wall)


func _build(low: Dictionary, high: Dictionary) -> Dictionary:
	var a := _run_point(low, 0, false)
	var b := _run_point(low, 4, true)
	var s_axis := (b - a).normalized()
	var wsw_normal := _run_normal(low, 0)
	var r_axis := -wsw_normal
	var nnw_dir := (_run_point(low, 10, false) - a).normalized()
	var tower_corner := _run_point(high, 12, false)
	var tower_far := _run_point(high, 11, false)
	# Tower NW face (high run 11) where the wing's inner edge meets it.
	var ra := (tower_corner - a).dot(r_axis)
	var rb := (tower_far - a).dot(r_axis)
	var meet := tower_corner.lerp(tower_far, (WING_DEPTH - ra) / (rb - ra))
	var polygon: Array[Vector3] = [
		a,
		b,
		tower_corner,
		meet,
		a + s_axis * NNW_WING_S + r_axis * WING_DEPTH,
		a + nnw_dir * NNW_TALL_M + s_axis * NNW_WING_S,
		a + nnw_dir * NNW_TALL_M,
	]
	# Faces 0 (WSW) and 6 (NNW) continue the low block's own outer walls: the low
	# facade draws them on the receiver plane, so the massing only collides there.
	# Face 5 is the brick end of the tall NNW volume; the rest face the courtyard.
	var outer_faces := {0: true, 6: true}
	var root := Node3D.new()
	root.name = "IsleHouseMassingL1"
	root.set_meta("render_and_collision", true)
	root.set_meta("deck_y_m", DECK_Y)
	root.set_meta("truth_class", "production_inference_scaled_from_2025_photos")
	var signed := 0.0
	for i in polygon.size():
		var p := polygon[i]
		var q := polygon[(i + 1) % polygon.size()]
		signed += p.x * q.z - q.x * p.z
	for i in polygon.size():
		var p := polygon[i]
		var q := polygon[(i + 1) % polygon.size()]
		var tangent := Vector3(q.x - p.x, 0.0, q.z - p.z).normalized()
		var out := Vector3(tangent.z, 0.0, -tangent.x) if signed > 0.0 else Vector3(-tangent.z, 0.0, tangent.x)
		if not outer_faces.has(i):
			_quad("brick" if i == 5 else "wall", _at(p, LOW_TOP_Y), _at(q, LOW_TOP_Y), _at(q, DECK_Y), _at(p, DECK_Y), out)
		if i == 0:
			_fold_solid(low, LOW_TOP_Y, DECK_Y, false)
		else:
			_collide_quad(_at(p, LOW_TOP_Y), _at(q, LOW_TOP_Y), _at(q, DECK_Y), _at(p, DECK_Y), out)
		# Deck parapet with a white coping and a dark glass guardrail (dba-43/55).
		var offset := out * (FACE_OFFSET if outer_faces.has(i) else 0.0)
		var length := Vector3(q.x - p.x, 0.0, q.z - p.z).length()
		var mid := (p + q) * 0.5
		_box("trim", _at(mid, DECK_Y + 0.25) + offset - out * 0.12, tangent, out, length + 0.24, 0.5, 0.36, true)
		_box("glass", _at(mid, DECK_Y + 0.85) - out * 0.25, tangent, out, length - 0.1, 0.7, 0.05, true)
	var flat: PackedVector2Array = []
	for p in polygon:
		flat.append(Vector2(p.x, p.z))
	var triangles := Geometry2D.triangulate_polygon(flat)
	if triangles.is_empty():
		root.free()
		return {"ok": false, "message": "Isle House deck polygon did not triangulate."}
	for i in range(0, triangles.size(), 3):
		var t0 := _at(polygon[triangles[i]], DECK_Y)
		var t1 := _at(polygon[triangles[i + 1]], DECK_Y)
		var t2 := _at(polygon[triangles[i + 2]], DECK_Y)
		_triangle(_roof_surfaces, "roof", t0, t1, t2, Vector3.UP)
		_collide_triangle(t0, t1, t2, Vector3.UP)
	# Dark rooftop stair/mechanical box on the tall west volume (ih05, ih17).
	var stair_box := a + nnw_dir * 7.0 + s_axis * 6.0
	var deck_flat: PackedVector2Array = []
	for p in polygon:
		deck_flat.append(Vector2(p.x, p.z))
	_deck_box(deck_flat, stair_box, s_axis, nnw_dir, 4.2, 3.4, 4.6)
	# Courtyard-facing walls of the added storeys: storeys 4 and 5.
	for i in [3, 4]:
		var p := polygon[i]
		var q := polygon[i + 1]
		var tangent := Vector3(q.x - p.x, 0.0, q.z - p.z).normalized()
		var out := Vector3(tangent.z, 0.0, -tangent.x) if signed > 0.0 else Vector3(-tangent.z, 0.0, tangent.x)
		_slim_windows(p, tangent, out, 0.0, Vector3(q.x - p.x, 0.0, q.z - p.z).length(), [4, 5])
	_podium_base(high)
	var tower_error := _tower_extension(high)
	if tower_error == "":
		tower_error = _penthouse(high)
	if tower_error != "":
		root.free()
		return {"ok": false, "message": tower_error}
	root.set_meta("roof_box_count", _roof_boxes)
	_emit(root)
	return {"ok": true, "node": root, "deck_polygon": polygon}


# Low facade (receiver w1282547787), attached by the world chunk builder.
static func matches_low_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == LOW_RECEIVER_KEY \
		and record.get("source_keys", []) == [LOW_SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_part_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and is_equal_approx(float(record.get("top_elevation_m", 0.0)), LOW_TOP_Y) \
		and (record.get("vertices", []) as Array).size() == 156 \
		and (record.get("normals", []) as Array).size() == 156


static func build_low(low: Dictionary) -> Dictionary:
	if not matches_low_record(low):
		return {"ok": false, "code": "isle_house_low_facade_target", "message": "Isle House low facade refused a non-target receiver.", "source_keys": (low.get("source_keys", []) as Array).duplicate()}
	var builder: RefCounted = (load("res://game/scripts/world/facades/isle_house_massing_l1.gd") as GDScript).new()
	var root: Node3D = builder._build_low(low)
	var triangles := 0
	var mesh_instances := 0
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			mesh_instances += 1
			triangles += (child as MeshInstance3D).mesh.get_faces().size() / 3
	return {"ok": true, "node": root, "mesh_instances": mesh_instances, "surfaces": mesh_instances, "triangles": triangles,
		"metadata": {"receiver_object_key": LOW_RECEIVER_KEY, "source_key": LOW_SOURCE_KEY, "spray": "unchanged_underlying_receiver"}}


# Side frame over consecutive low runs: origin, tangent, outward normal, length.
static func _low_side(low: Dictionary, first: int, last: int) -> Dictionary:
	var start := _run_point(low, first, false)
	var finish := _run_point(low, last, true)
	return {"origin": Vector3(start.x, 0.0, start.z), "t": Vector3(finish.x - start.x, 0.0, finish.z - start.z).normalized(),
		"n": _run_normal(low, first), "length": Vector3(finish.x - start.x, 0.0, finish.z - start.z).length()}


func _build_low(low: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.name = "IsleHouseLowFacade"
	root.set_meta("render_and_collision", true)
	root.set_meta("spray_ray_owner", "unchanged_underlying_receiver")
	root.set_meta("truth_class", "production_inference_scaled_from_2025_photos")
	var wsw := _low_side(low, 0, 4)
	var ene := _low_side(low, 5, 9)
	var nnw := _low_side(low, 10, 12)
	# WSW (ih01, ih02, dba-6): recessed storefront base under a white soffit, a
	# brick corner bay, then folded white facets with one boxed window each.
	_wsw_facade(low, wsw)
	# ENE, Garden Walk (dba-64, dba-4, cav-6): the same grammar, three storeys.
	_field(ene, 3.95, SOFFIT_Y, 0.0, ene.length, "frame")
	_field(ene, SOFFIT_Y, LOW_TOP_Y, 0.0, ene.length, "wall")
	_storefront(ene, false)
	_soffit(ene, 0.0, ene.length)
	_modules(ene, 0.0, ene.length, LOW_TOP_Y, 3)
	_coping(ene, 0.0, ene.length, LOW_TOP_Y)
	# NNW (ih05-07, ih15-17): light brick over a charcoal brick base; the west
	# NNW_TALL_M rise to the deck, the east part stays at the low roof.
	var step: float = float(nnw.length) - NNW_TALL_M
	_field(nnw, 3.95, SOFFIT_Y, 0.0, nnw.length, "frame")
	_field(nnw, SOFFIT_Y, LOW_TOP_Y, 0.0, step, "brick")
	# 3 cm past the step so no seam opens at the corner with the brick end wall.
	_field(nnw, SOFFIT_Y, DECK_Y, step - 0.03, nnw.length, "brick")
	_nnw_base(nnw)
	var origin := _side_at(nnw, 0.0, FIELD_OFFSET)
	_slim_windows(origin, nnw.t, nnw.n, 0.0, step, [1, 2, 3])
	_slim_windows(origin, nnw.t, nnw.n, step, nnw.length, [1, 2, 3, 4, 5])
	_coping(nnw, 0.0, step, LOW_TOP_Y)
	_emit(root)
	return root


func _side_at(side: Dictionary, u: float, out: float) -> Vector3:
	return (side.origin as Vector3) + (side.t as Vector3) * u + (side.n as Vector3) * out


# Flat cladding field on the receiver plane (inside the spray decal's reach).
func _field(side: Dictionary, bottom: float, top: float, from_u: float, to_u: float, key: String) -> void:
	var p := _side_at(side, from_u, FIELD_OFFSET)
	var q := _side_at(side, to_u, FIELD_OFFSET)
	_quad(key, _at(p, bottom), _at(q, bottom), _at(q, top), _at(p, top), side.n)


# White soffit band where the upper body oversails the base (ih02, dba-6).
func _soffit(side: Dictionary, from_u: float, to_u: float) -> void:
	var mid := _side_at(side, (from_u + to_u) * 0.5, STACK_DEPTH * 0.5)
	_box("trim", _at(mid, SOFFIT_Y + 0.2), side.t, side.n, to_u - from_u, 0.4, STACK_DEPTH, true)


func _coping(side: Dictionary, from_u: float, to_u: float, top: float) -> void:
	var mid := _side_at(side, (from_u + to_u) * 0.5, 0.0)
	_box("trim", _at(mid, top + 0.15), side.t, side.n, to_u - from_u, 0.3, 0.3, true)


# 6.4m modules (ih01, ih02, dba-6): a faceted projecting window-box stack (angled
# white cheeks, a dark-framed front of large three-pane glazing per storey over a
# white spandrel) and a flat white strip with a narrow storey-high window.
func _modules(side: Dictionary, from_u: float, to_u: float, top: float, storeys: int) -> void:
	var count := int(floor((to_u - from_u) / MODULE_M))
	var first := from_u + (to_u - from_u - MODULE_M * float(count)) * 0.5
	var t: Vector3 = side.t
	var n: Vector3 = side.n
	var stack_bottom := SOFFIT_Y + 0.4
	var front_w := STACK_W - 2.0 * STACK_FRONT_INSET
	for index in count:
		var u0 := first + MODULE_M * float(index)
		var su := u0 + STACK_W * 0.5
		var slot_u := u0 + STACK_W + 0.55
		_collide_box(_at(_side_at(side, su, STACK_DEPTH * 0.5), (stack_bottom + top) * 0.5), t, n, STACK_W, top - stack_bottom, STACK_DEPTH)
		# Angled white cheeks from the wall to the narrower front, and caps.
		var wall_l := _side_at(side, u0, FIELD_OFFSET)
		var wall_r := _side_at(side, u0 + STACK_W, FIELD_OFFSET)
		var front_l := _side_at(side, u0 + STACK_FRONT_INSET, STACK_DEPTH)
		var front_r := _side_at(side, u0 + STACK_W - STACK_FRONT_INSET, STACK_DEPTH)
		var cheek_l_n := (n * STACK_FRONT_INSET - t * STACK_DEPTH).normalized()
		var cheek_r_n := (n * STACK_FRONT_INSET + t * STACK_DEPTH).normalized()
		_quad("trim", _at(wall_l, stack_bottom), _at(front_l, stack_bottom), _at(front_l, top), _at(wall_l, top), cheek_l_n)
		_quad("trim", _at(front_r, stack_bottom), _at(wall_r, stack_bottom), _at(wall_r, top), _at(front_r, top), cheek_r_n)
		_quad("trim", _at(wall_l, stack_bottom), _at(wall_r, stack_bottom), _at(front_r, stack_bottom), _at(front_l, stack_bottom), Vector3.DOWN)
		_quad("trim", _at(wall_l, top), _at(front_l, top), _at(front_r, top), _at(wall_r, top), Vector3.UP)
		# Dark frame lines on the front edges of the box.
		for k: float in [-1.0, 1.0]:
			_box("frame", _at(_side_at(side, su + k * (front_w * 0.5 - 0.05), STACK_DEPTH - 0.02), (stack_bottom + top) * 0.5), t, n, 0.1, top - stack_bottom, 0.06, false)
		for storey in storeys:
			var y := SOFFIT_Y + STOREY_M * float(storey)
			var sill := maxf(y + 0.35, stack_bottom + 0.1)
			var ceiling := minf(y + STOREY_M, top)
			var head := ceiling - 0.15
			_box("trim", _at(_side_at(side, su, STACK_DEPTH - 0.03), (maxf(y, stack_bottom) + sill) * 0.5), t, n, front_w - 0.2, sill - maxf(y, stack_bottom), 0.06, false)
			_box("trim", _at(_side_at(side, su, STACK_DEPTH - 0.03), (head + ceiling) * 0.5), t, n, front_w - 0.2, ceiling - head, 0.06, false)
			_glazing(_at(_side_at(side, su, STACK_DEPTH - 0.09), (sill + head) * 0.5), t, n, front_w - 0.2, head - sill, 2)
			# Narrow storey-high window at the fold, so the slots read as one
			# continuous vertical stripe between thin white floor bars (ih01).
			_glazing(_at(_side_at(side, slot_u, FIELD_OFFSET), (y + ceiling) * 0.5), t, n, 0.8, ceiling - y - 0.16, 0)


# NNW base (ih06): charcoal brick panels between concrete piers, with tall
# recessed glazing and doors in alternate bays.
func _nnw_base(side: Dictionary) -> void:
	var bay := 6.0
	var count := int(floor(side.length / bay))
	var first := (float(side.length) - bay * float(count)) * 0.5
	for index in count + 1:
		var u := first + bay * float(index)
		_box("concrete", _at(_side_at(side, clampf(u, 0.35, side.length - 0.35), 0.06), (3.95 + SOFFIT_Y) * 0.5), side.t, side.n, 0.7, SOFFIT_Y - 3.95, 0.1, false)
	for index in count:
		var mid := first + bay * (float(index) + 0.5)
		if index % 2 == 0:
			_flush_glazing(_at(_side_at(side, mid, 0.0), 4.1 + 2.7), side.t, side.n, 3.4, 5.4, 2)
		else:
			_flush_glazing(_at(_side_at(side, mid, 0.0), 4.1 + 1.3), side.t, side.n, 1.2, 2.6, 0)


# A dark solid box on the level-7 deck, kept only when it lies on the deck.
func _deck_box(outline: PackedVector2Array, middle: Vector3, along: Vector3, across: Vector3, width: float, depth: float, height: float) -> void:
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var p := middle + along * corner.x * width * 0.5 + across * corner.y * depth * 0.5
		if not Geometry2D.is_point_in_polygon(Vector2(p.x, p.z), outline):
			return
	_roof_boxes += 1
	_box("frame", _at(middle, DECK_Y + height * 0.5), along, across, width, height, depth, true, true)


func _collide_box(center: Vector3, t: Vector3, n: Vector3, width: float, height: float, depth: float) -> void:
	var tx := t * width * 0.5
	var nz := n * depth * 0.5
	var uy := Vector3.UP * height * 0.5
	var c := center
	_collide_quad(c - tx - uy + nz, c + tx - uy + nz, c + tx + uy + nz, c - tx + uy + nz, n)
	_collide_quad(c - tx + uy - nz, c - tx + uy + nz, c + tx + uy + nz, c + tx + uy - nz, Vector3.UP)
	_collide_quad(c - tx - uy - nz, c + tx - uy - nz, c + tx - uy + nz, c - tx - uy + nz, Vector3.DOWN)
	_collide_quad(c - tx - uy - nz, c - tx - uy + nz, c - tx + uy + nz, c - tx + uy - nz, -t)
	_collide_quad(c + tx - uy + nz, c + tx - uy - nz, c + tx + uy - nz, c + tx + uy + nz, t)


# WSW fold polyline as (u along the side, depth inside the footprint line):
# flat over the brick corner bay, a sawtooth over each module, flat to the end.
static func wsw_fold(low: Dictionary) -> Array[Vector2]:
	var side := _low_side(low, 0, 4)
	var length: float = side.length
	var from_u := CORNER_BRICK_M + 0.15
	var count := int(floor((length - from_u) / MODULE_M))
	var first := from_u + (length - from_u - MODULE_M * float(count)) * 0.5
	var points: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(CORNER_BRICK_M, 0.0)]
	for index in count:
		var u0 := first + MODULE_M * float(index)
		points.append(Vector2(u0, 0.0))
		points.append(Vector2(u0 + MODULE_M - FOLD_SHORT_M, FOLD_DEPTH))
	points.append(Vector2(first + MODULE_M * float(count), 0.0))
	points.append(Vector2(length, 0.0))
	return points


static func _wsw_point(side: Dictionary, p: Vector2, y: float) -> Vector3:
	return _at((side.origin as Vector3) + (side.t as Vector3) * p.x - (side.n as Vector3) * p.y, y)


# Outward normal of a fold segment (the side normal turned with the facet).
static func _fold_normal(side: Dictionary, p: Vector2, q: Vector2) -> Vector3:
	var e := (side.t as Vector3) * (q.x - p.x) - (side.n as Vector3) * (q.y - p.y)
	var normal := Vector3(e.z, 0.0, -e.x).normalized()
	return normal if normal.dot(side.n) > 0.0 else -normal


# Folded wall between y0 and y1 (collision, and the white field when visual).
func _fold_solid(low: Dictionary, y0: float, y1: float, visual: bool) -> void:
	var side := _low_side(low, 0, 4)
	var fold := wsw_fold(low)
	for i in fold.size() - 1:
		var p := fold[i]
		var q := fold[i + 1]
		if q.x - p.x < 0.001:
			continue
		var normal := _fold_normal(side, p, q)
		_collide_quad(_wsw_point(side, p, y0), _wsw_point(side, q, y0), _wsw_point(side, q, y1), _wsw_point(side, p, y1), normal)
		if visual:
			var off := normal * FIELD_OFFSET
			_quad("brick" if q.x <= CORNER_BRICK_M + 0.001 else "wall", _wsw_point(side, p, y0) + off, _wsw_point(side, q, y0) + off, _wsw_point(side, q, y1) + off, _wsw_point(side, p, y1) + off, normal)
	# Valley caps under the deck coping and over the base soffit line.
	if y1 >= DECK_Y - 0.001:
		_fold_caps(side, fold, DECK_Y, Vector2(0.0, float(side.length)), 0.0)


# Horizontal down-facing caps between a straight line at depth `line_d` and the
# fold polyline over [range.x, range.y]: white, and solid unless the receiver
# already carries them.
func _fold_caps(side: Dictionary, fold: Array[Vector2], y: float, u_range: Vector2, line_d: float, solid: bool = true) -> void:
	for i in fold.size() - 1:
		var p := fold[i]
		var q := fold[i + 1]
		var u0 := maxf(p.x, u_range.x)
		var u1 := minf(q.x, u_range.y)
		if u1 - u0 < 0.001:
			continue
		var a := Vector2(u0, lerpf(p.y, q.y, (u0 - p.x) / (q.x - p.x)))
		var b := Vector2(u1, lerpf(p.y, q.y, (u1 - p.x) / (q.x - p.x)))
		if absf(a.y - line_d) < 0.001 and absf(b.y - line_d) < 0.001:
			continue
		var c := Vector2(u1, line_d)
		var d := Vector2(u0, line_d)
		_quad("trim", _wsw_point(side, a, y), _wsw_point(side, b, y), _wsw_point(side, c, y), _wsw_point(side, d, y), Vector3.DOWN)
		if solid:
			_collide_quad(_wsw_point(side, a, y), _wsw_point(side, b, y), _wsw_point(side, c, y), _wsw_point(side, d, y), Vector3.DOWN)


# Visual WSW facade over the folded receiver.
func _wsw_facade(low: Dictionary, side: Dictionary) -> void:
	var length: float = side.length
	var fold := wsw_fold(low)
	# Upper folds: fields (and the receiver-matching collision lives on the record).
	for i in fold.size() - 1:
		var p := fold[i]
		var q := fold[i + 1]
		if q.x - p.x < 0.001:
			continue
		var normal := _fold_normal(side, p, q)
		var off := normal * FIELD_OFFSET
		_quad("brick" if q.x <= CORNER_BRICK_M + 0.001 else "wall", _wsw_point(side, p, SOFFIT_Y) + off, _wsw_point(side, q, SOFFIT_Y) + off, _wsw_point(side, q, DECK_Y) + off, _wsw_point(side, p, DECK_Y) + off, normal)
		# White band along the soffit edge: the line where the upper block
		# oversails the recessed base (ih01, ih02).
		var edge_mid := (_wsw_point(side, p, 0.0) + _wsw_point(side, q, 0.0)) * 0.5
		var edge_len := _wsw_point(side, p, 0.0).distance_to(_wsw_point(side, q, 0.0))
		_box("trim", _at(edge_mid, SOFFIT_Y + 0.22) + normal * 0.05, (_wsw_point(side, q, 0.0) - _wsw_point(side, p, 0.0)).normalized(), normal, edge_len + 0.02, 0.44, 0.08, false)
		if absf(q.y - p.y) < 0.001:
			continue
		# One large boxed window per facet and storey, about half the facet,
		# in a deep dark frame (ih01, ih02).
		var tangent := ((_wsw_point(side, q, 0.0) - _wsw_point(side, p, 0.0))).normalized()
		var mid := (_wsw_point(side, p, 0.0) + _wsw_point(side, q, 0.0)) * 0.5
		var facet_w := _wsw_point(side, p, 0.0).distance_to(_wsw_point(side, q, 0.0))
		var w := facet_w * 0.55
		for storey in 5:
			var y := SOFFIT_Y + STOREY_M * float(storey)
			var sill := y + 0.4
			var head := y + STOREY_M - 0.25
			var center := _at(mid, (sill + head) * 0.5)
			_glazing(center + normal * (FIELD_OFFSET - 0.02), tangent, normal, w, head - sill, 1)
			for k: float in [-1.0, 1.0]:
				_box("frame", center + normal * 0.09 + tangent * k * (w * 0.5 + 0.06), tangent, normal, 0.14, head - sill + 0.26, 0.16, false)
				_box("frame", center + normal * 0.09 + Vector3.UP * k * ((head - sill) * 0.5 + 0.06), tangent, normal, w + 0.26, 0.14, 0.16, false)
	_slim_windows(_side_at(side, 0.0, FIELD_OFFSET), side.t, side.n, 0.0, CORNER_BRICK_M + 0.3, [1, 2, 3, 4, 5])
	# Soffit under the folds, over the recessed base (the receiver collides there).
	_fold_caps(side, fold, SOFFIT_Y, Vector2(PIER_START, length - PIER_END), BASE_RECESS, false)
	# Recessed storefront between corner piers, with returns.
	var base := {"origin": _side_at(side, PIER_START, -BASE_RECESS), "t": side.t, "n": side.n, "length": length - PIER_START - PIER_END}
	_field(base, 3.95, SOFFIT_Y, 0.0, base.length, "frame")
	_storefront(base, true)
	_field(side, 3.95, SOFFIT_Y, 0.0, PIER_START, "concrete")
	_field(side, 3.95, SOFFIT_Y, length - PIER_END, length, "concrete")
	for end: Array in [[PIER_START, 1.0], [length - PIER_END, -1.0]]:
		var u: float = end[0]
		var t: Vector3 = side.t
		var normal: Vector3 = t * float(end[1])
		var p0 := _side_at(side, u, 0.0) + normal * FIELD_OFFSET
		var p1 := _side_at(side, u, -BASE_RECESS) + normal * FIELD_OFFSET
		_quad("concrete", _at(p0, 3.95), _at(p1, 3.95), _at(p1, SOFFIT_Y), _at(p0, SOFFIT_Y), normal)


# The low wall record built with the WSW folds and recessed base (receiver
# geometry follows the visuals so walls, spray and walk-up agree). Runs 5-12 keep
# their generated triangles; runs 0-4 are replaced inside the frozen footprint.
static func build_low_record(record: Dictionary, material: Material) -> Dictionary:
	if not matches_low_record(record):
		return {"ok": false, "code": "isle_house_low_receiver_target", "message": "Isle House low receiver refused a non-target record.", "source_keys": (record.get("source_keys", []) as Array).duplicate()}
	var builder: RefCounted = (load("res://game/scripts/world/facades/isle_house_massing_l1.gd") as GDScript).new()
	return builder._build_low_record(record, material)


func _build_low_record(record: Dictionary, material: Material) -> Dictionary:
	var raw: Array = record.vertices
	var raw_normals: Array = record.normals
	var indices: Array = record.indices
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var faces := PackedVector3Array()
	for i in range(0, indices.size(), 3):
		if int(indices[i]) < 20 or int(indices[i + 1]) < 20 or int(indices[i + 2]) < 20:
			continue
		# The record stores counterclockwise triangles; Godot fronts are
		# clockwise, so take each triplet as (first, third, second) like the
		# generic wall builder.
		for k: int in [0, 2, 1]:
			var vi := int(indices[i + k])
			var v := Vector3(float(raw[vi * 3]), float(raw[vi * 3 + 1]), float(raw[vi * 3 + 2]))
			vertices.append(v)
			normals.append(Vector3(float(raw_normals[vi * 3]), float(raw_normals[vi * 3 + 1]), float(raw_normals[vi * 3 + 2])))
			faces.append(v)
	# WSW: corner piers, recessed base with returns, soffit, folded upper walls.
	var side := _low_side(record, 0, 4)
	var length: float = side.length
	var bottom := 3.95
	var t: Vector3 = side.t
	var n: Vector3 = side.n
	_collision = PackedVector3Array()
	_collide_quad(_at(_side_at(side, 0.0, 0.0), bottom), _at(_side_at(side, PIER_START, 0.0), bottom), _at(_side_at(side, PIER_START, 0.0), SOFFIT_Y), _at(_side_at(side, 0.0, 0.0), SOFFIT_Y), n)
	_collide_quad(_at(_side_at(side, length - PIER_END, 0.0), bottom), _at(_side_at(side, length, 0.0), bottom), _at(_side_at(side, length, 0.0), SOFFIT_Y), _at(_side_at(side, length - PIER_END, 0.0), SOFFIT_Y), n)
	_collide_quad(_at(_side_at(side, PIER_START, -BASE_RECESS), bottom), _at(_side_at(side, length - PIER_END, -BASE_RECESS), bottom), _at(_side_at(side, length - PIER_END, -BASE_RECESS), SOFFIT_Y), _at(_side_at(side, PIER_START, -BASE_RECESS), SOFFIT_Y), n)
	_collide_quad(_at(_side_at(side, PIER_START, 0.0), bottom), _at(_side_at(side, PIER_START, -BASE_RECESS), bottom), _at(_side_at(side, PIER_START, -BASE_RECESS), SOFFIT_Y), _at(_side_at(side, PIER_START, 0.0), SOFFIT_Y), t)
	_collide_quad(_at(_side_at(side, length - PIER_END, -BASE_RECESS), bottom), _at(_side_at(side, length - PIER_END, 0.0), bottom), _at(_side_at(side, length - PIER_END, 0.0), SOFFIT_Y), _at(_side_at(side, length - PIER_END, -BASE_RECESS), SOFFIT_Y), -t)
	var fold := wsw_fold(record)
	_fold_caps(side, fold, SOFFIT_Y, Vector2(PIER_START, length - PIER_END), BASE_RECESS)
	_fold_solid(record, SOFFIT_Y, LOW_TOP_Y, false)
	# The receiver mesh carries the same faces as its collision (render layer as
	# the generated wall; the facade fields cover it).
	for i in range(0, _collision.size(), 3):
		var normal := (_collision[i + 2] - _collision[i]).cross(_collision[i + 1] - _collision[i]).normalized()
		for k in 3:
			vertices.append(_collision[i + k])
			normals.append(normal)
	faces.append_array(_collision)
	_surfaces = {}
	_roof_surfaces = {}
	_collision = PackedVector3Array()
	var root := Node3D.new()
	root.name = str(record.object_key).validate_node_name()
	root.set_meta("derived_object_key", str(record.object_key))
	root.set_meta("source_keys", (record.source_keys as Array).duplicate())
	root.set_meta("feature_kind", str(record.feature_kind))
	root.set_meta("isle_house_low_receiver_override", true)
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	# Triangles in collision order: the same front faces the generic wall uses.
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	mesh_instance.mesh = mesh
	mesh_instance.layers = RENDER_BUILDING_WALL
	root.add_child(mesh_instance)
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	for target: Object in [shape]:
		target.set_meta("receiver_kind", str(record.receiver_kind))
		target.set_meta("opaque", bool(record.opaque))
		target.set_meta("derived_object_key", str(record.object_key))
		target.set_meta("source_keys", (record.source_keys as Array).duplicate())
	var shape_node := CollisionShape3D.new()
	shape_node.name = "Shape"
	shape_node.shape = shape
	var body := StaticBody3D.new()
	body.name = "Collision"
	body.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
	body.collision_mask = 0
	body.set_meta("receiver_kind", str(record.receiver_kind))
	body.set_meta("opaque", bool(record.opaque))
	body.set_meta("derived_object_key", str(record.object_key))
	body.set_meta("source_keys", (record.source_keys as Array).duplicate())
	body.add_to_group("spray_receiver_wall")
	body.add_child(shape_node)
	root.add_child(body)
	var facade := build_low(record)
	if not bool(facade.get("ok", false)):
		root.free()
		return facade
	root.add_child(facade.node as Node3D)
	root.set_meta("isle_house_low_facade", (facade.metadata as Dictionary).duplicate(true))
	return {"ok": true, "node": root, "mesh_instances": 1 + int(facade.mesh_instances), "surfaces": 1 + int(facade.surfaces), "triangles": vertices.size() / 3 + int(facade.triangles)}


# Sparse tall narrow dark-framed windows, staggered by storey (ih05, ih06, ih17):
# about 15% glass on the light brick.
func _slim_windows(origin: Vector3, tangent: Vector3, normal: Vector3, from_m: float, to_m: float, storeys: Array) -> void:
	var pitch := 4.2
	var count := maxi(int(floor((to_m - from_m) / pitch)), 1)
	var first := from_m + (to_m - from_m - pitch * float(count - 1)) * 0.5
	for index in count:
		for storey: int in storeys:
			var u := clampf(first + pitch * float(index) + (0.7 if storey % 2 == 0 else -0.7), from_m + 0.6, to_m - 0.6)
			var center := origin + tangent * u
			center.y = STOREY_BASE_Y + STOREY_M * float(storey - 1) + 0.25 + 1.175
			_glazing(center, tangent, normal, 0.85, 2.35, 0, "glass_dark")


# Dark-framed glazing: glass panel with a frame and optional centre mullion.
func _glazing(center: Vector3, tangent: Vector3, normal: Vector3, width: float, height: float, mullions: int, glass: String = "glass") -> void:
	var frame := 0.08
	_box(glass, center + normal * 0.05, tangent, normal, width - frame, height - frame, 0.02, false)
	for side: float in [-1.0, 1.0]:
		_box("frame", center + normal * 0.075 + tangent * side * (width - frame) * 0.5, tangent, normal, frame, height, 0.05, false)
		_box("frame", center + normal * 0.075 + Vector3.UP * side * (height - frame) * 0.5, tangent, normal, width, frame, 0.05, false)
	for index in mullions:
		var u := -width * 0.5 + width * float(index + 1) / float(mullions + 1)
		_box("frame", center + normal * 0.075 + tangent * u, tangent, normal, 0.06, height - frame, 0.04, false)


# Double-height storefront / live-work glazing (WSW ih01/ih02/dba-6, ENE
# dba-64/dba-4): glazing with a mezzanine transom between concrete columns and
# charcoal patterned-brick piers, plus the WSW roll-up garage door 9m from the
# tower. Render-only over the unchanged receiver: glass and frames stay within
# 0.04m of it (the base field 0.012m behind them) so a spray decal, projected
# +-0.04m about the receiver, shows on the glazing instead of hiding behind it.
func _storefront(side: Dictionary, garage: bool) -> void:
	var tangent: Vector3 = side.t
	var normal: Vector3 = side.n
	var length: float = side.length
	# Up to the soffit band, and down past the lowest source wall bottom (3.98).
	var bottom := 3.95
	var top := SOFFIT_Y
	var bay := MODULE_M
	var count := int(floor(length / bay))
	var first := (length - bay * float(count)) * 0.5
	var garage_u := length - 9.0 if garage else -INF
	for index in count + 1:
		var u := first + bay * float(index)
		var concrete := index % 2 == 0
		var width := 0.7 if concrete else 1.0
		var center := _side_at(side, clampf(u, width * 0.5, length - width * 0.5), 0.0)
		center.y = (bottom + top) * 0.5
		_box("concrete" if concrete else "frame", center + normal * 0.06, tangent, normal, width, top - bottom, 0.1, false)
	for index in count:
		var left := first + bay * float(index) + (0.35 if index % 2 == 0 else 0.5)
		var right := first + bay * float(index + 1) - (0.5 if index % 2 == 0 else 0.35)
		var mid := (left + right) * 0.5
		var center := _side_at(side, mid, 0.0)
		if absf(mid - garage_u) < bay * 0.5:
			# Silver roll-up garage door with slats, glazing above.
			center.y = (bottom + 7.4) * 0.5
			_box("concrete", center + normal * 0.025, tangent, normal, right - left, 7.4 - bottom, 0.01, false)
			for k in range(1, 12):
				var slat := center + normal * 0.034
				slat.y = bottom + (7.4 - bottom) * float(k) / 12.0
				_box("roof", slat, tangent, normal, right - left - 0.2, 0.05, 0.008, false)
			center.y = (7.4 + top) * 0.5
			_flush_glazing(center, tangent, normal, right - left, top - 7.4, 2)
			continue
		var lower := center
		lower.y = (bottom + 7.25) * 0.5
		_flush_glazing(lower, tangent, normal, right - left, 7.25 - bottom, 3)
		var upper := center
		upper.y = (7.25 + top) * 0.5
		_flush_glazing(upper, tangent, normal, right - left, top - 7.25, 3)


# Near-flush glazing for spray-receiving bases: glass 0.02-0.03m and frames
# 0.03-0.04m in front of the receiver plane (origin on the receiver).
func _flush_glazing(center: Vector3, tangent: Vector3, normal: Vector3, width: float, height: float, mullions: int) -> void:
	var frame := 0.08
	_box("glass", center + normal * 0.025, tangent, normal, width - frame, height - frame, 0.01, false)
	for side: float in [-1.0, 1.0]:
		_box("frame", center + normal * 0.035 + tangent * side * (width - frame) * 0.5, tangent, normal, frame, height, 0.01, false)
		_box("frame", center + normal * 0.035 + Vector3.UP * side * (height - frame) * 0.5, tangent, normal, width, frame, 0.01, false)
	for index in mullions:
		var u := -width * 0.5 + width * float(index + 1) / float(mullions + 1)
		_box("frame", center + normal * 0.035 + tangent * u, tangent, normal, 0.06, height - frame, 0.01, false)


# Tower podium base (ih08, ih10, ih14, ih18): double-height storefront glazing
# along most of each ground face between board-formed concrete columns, a dark
# louvre band over it, and charcoal patterned-brick panels at the doors. Glass
# and frames stay within the spray decal's reach of the high receiver.
func _podium_base(high: Dictionary) -> void:
	# [first run, last run, charcoal brick panels, u ranges left to other modules]
	var groups := [
		[0, 2, [], []],
		[3, 4, [[3.3, 4.9], [6.5, 8.1]], []],
		[5, 7, [[16.4, 18.9]], [[19.3, 22.9]]],
		[8, 9, [], []],
	]
	for group: Array in groups:
		var side := _low_side(high, int(group[0]), int(group[1]))
		var length: float = side.length
		var t: Vector3 = side.t
		var n: Vector3 = side.n
		_field(side, 3.95, SOFFIT_Y, 0.0, length, "frame")
		var bays := maxi(int(round(length / 6.0)), 1)
		var bay := length / float(bays)
		for index in bays + 1:
			var u := clampf(bay * float(index), 0.45, length - 0.45)
			if _within(u, group[3]):
				continue
			_box("concrete", _at(_side_at(side, u, 0.08), (3.95 + SOFFIT_Y) * 0.5), t, n, 0.9, SOFFIT_Y - 3.95, 0.14, false)
		for index in bays:
			var left := bay * float(index) + 0.45
			var right := bay * float(index + 1) - 0.45
			var mid := (left + right) * 0.5
			if _within(mid, group[3]):
				continue
			var lower := _at(_side_at(side, mid, 0.0), (4.05 + 7.0) * 0.5)
			_flush_glazing(lower, t, n, right - left, 7.0 - 4.05, int(round((right - left) / 1.5)) - 1)
			var upper := _at(_side_at(side, mid, 0.0), (7.0 + STOREFRONT_TOP) * 0.5)
			_flush_glazing(upper, t, n, right - left, STOREFRONT_TOP - 7.0, int(round((right - left) / 1.5)) - 1)
		# Louvre band over the glazing.
		for k in range(1, 5):
			var slat := _at(_side_at(side, length * 0.5, 0.03), STOREFRONT_TOP + (SOFFIT_Y - STOREFRONT_TOP) * float(k) / 5.0)
			_box("concrete", slat, t, n, length - 0.1, 0.035, 0.01, false)
		for panel: Array in group[2]:
			var pu := (float(panel[0]) + float(panel[1])) * 0.5
			_box("frame", _at(_side_at(side, pu, 0.035), (3.95 + SOFFIT_Y) * 0.5), t, n, float(panel[1]) - float(panel[0]), SOFFIT_Y - 3.95, 0.01, false)
	_tower_ledges(high)


static func _within(u: float, ranges: Array) -> bool:
	for r: Array in ranges:
		if u > float(r[0]) - 0.5 and u < float(r[1]) + 0.5:
			return true
	return false


# White ledge where the tower oversails the podium, over the dark level-7 band:
# at the deck band on the west and at the stepped-down band on the east end.
func _tower_ledges(high: Dictionary) -> void:
	var se := _low_side(high, 5, 7)
	var west_y := DECK_Y + LEVEL7_BAND_M
	var east_y := EAST_PODIUM_TOP_Y + LEVEL7_BAND_M
	var spans := [
		[_low_side(high, 0, 2), 0.0, -1.0, west_y],
		[_low_side(high, 3, 4), 0.0, -1.0, west_y],
		[se, 0.0, SE_STEP_U_M, west_y],
		[se, SE_STEP_U_M, -1.0, east_y],
		[_low_side(high, 8, 9), 0.0, -1.0, east_y],
	]
	for span: Array in spans:
		var side: Dictionary = span[0]
		var u0: float = span[1]
		var u1: float = float(side.length) if float(span[2]) < 0.0 else float(span[2])
		var mid := _side_at(side, (u0 + u1) * 0.5, LEDGE_DEPTH * 0.5)
		_box("wall", _at(mid, float(span[3]) + LEDGE_H * 0.5), side.t, side.n, u1 - u0, LEDGE_H, LEDGE_DEPTH, true)


# Roof penthouse (ih21, dba-50/52): an offset plant box and a perimeter guardrail.
func _penthouse(high: Dictionary) -> String:
	var se_start := _run_point(high, 5, false)
	var se_end := _run_point(high, 5, true)
	var along := (se_end - se_start).normalized()
	var se_normal := _run_normal(high, 5)
	var outline: PackedVector2Array = []
	for run in 13:
		var p := _run_point(high, run, false)
		outline.append(Vector2(p.x, p.z))
	# 27 May 2025 crown (ih21): the box spans about the middle half of the SE
	# face, left of centre, set back about 3m behind the guardrail.
	var half := Vector2(10.0, 4.5)
	var middle := se_start + along * 18.6 - se_normal * (3.0 + half.y)
	var penthouse_error := _roof_box(outline, "tower", middle, along, se_normal, half.x * 2.0, 4.0, half.y * 2.0, true)
	if penthouse_error != "":
		return penthouse_error
	_roof_box(outline, "roof", middle - along * (half.x + 2.5), along, se_normal, 4.0, 2.2, 4.0, false)
	_roof_box(outline, "roof", middle + along * (half.x + 3.0) + se_normal * 1.5, along, se_normal, 3.0, 1.8, 2.5, false)
	for run in 13:
		var p := _run_point(high, run, false)
		var q := _run_point(high, run, true)
		var tangent := Vector3(q.x - p.x, 0.0, q.z - p.z)
		var length := tangent.length()
		if length < 0.5:
			continue
		tangent = tangent.normalized()
		var inward := -_run_normal(high, run)
		var mid := (p + q) * 0.5 + inward * 0.35
		_box("frame", _at(mid, TOWER_TOP_Y + 1.05), tangent, inward, length - 0.7, 0.06, 0.06, true)
		for k in range(1, int(length / 2.5)):
			var post := p + tangent * (length * float(k) / float(int(length / 2.5))) + inward * 0.35
			_box("frame", _at(post, TOWER_TOP_Y + 0.53), tangent, inward, 0.06, 1.05, 0.06, true)
	return ""


# Tower height override: walls on the frozen tower runs from the generated
# roof up to TOWER_TOP_Y, and a new roof (the high facade fields cover the walls).
func _tower_extension(high: Dictionary) -> String:
	var outline: PackedVector2Array = []
	var points: Array[Vector3] = []
	for run in 13:
		var p := _run_point(high, run, false)
		var q := _run_point(high, run, true)
		points.append(p)
		outline.append(Vector2(p.x, p.z))
		var tangent := Vector3(q.x - p.x, 0.0, q.z - p.z)
		if tangent.length() < 0.01:
			continue
		var out := _run_normal(high, run)
		_quad("tower", _at(p, HIGH_TOP_Y - 0.05), _at(q, HIGH_TOP_Y - 0.05), _at(q, TOWER_TOP_Y), _at(p, TOWER_TOP_Y), out)
		_collide_quad(_at(p, HIGH_TOP_Y), _at(q, HIGH_TOP_Y), _at(q, TOWER_TOP_Y), _at(p, TOWER_TOP_Y), out)
	var triangles := Geometry2D.triangulate_polygon(outline)
	if triangles.is_empty():
		return "Isle House tower outline did not triangulate."
	for i in range(0, triangles.size(), 3):
		var t0 := _at(points[triangles[i]], TOWER_TOP_Y)
		var t1 := _at(points[triangles[i + 1]], TOWER_TOP_Y)
		var t2 := _at(points[triangles[i + 2]], TOWER_TOP_Y)
		_triangle(_roof_surfaces, "roof", t0, t1, t2, Vector3.UP)
		_collide_triangle(t0, t1, t2, Vector3.UP)
	return ""


# A solid roof-top box, emitted only when its whole footprint lies on the roof.
# Returns an error only for a required box (the penthouse) that does not fit.
func _roof_box(outline: PackedVector2Array, key: String, middle: Vector3, along: Vector3, normal: Vector3, width: float, height: float, depth: float, required: bool) -> String:
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var p := middle + along * corner.x * width * 0.5 + normal * corner.y * depth * 0.5
		if not Geometry2D.is_point_in_polygon(Vector2(p.x, p.z), outline):
			return "Isle House penthouse footprint left the tower roof." if required else ""
	_roof_boxes += 1
	_box(key, _at(middle, TOWER_TOP_Y + height * 0.5), along, normal, width, height, depth, true, true)
	return ""


func _emit(root: Node3D) -> void:
	for key: String in _surfaces:
		root.add_child(_mesh_instance("Massing_" + key, _surfaces[key], MATERIALS[key], RENDER_BUILDING_WALL, ""))
	for key: String in _roof_surfaces:
		root.add_child(_mesh_instance("MassingRoof_" + key, _roof_surfaces[key], MATERIALS[key], RENDER_WORLD_VISIBLE, "roof"))
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(_collision)
	var shape_node := CollisionShape3D.new()
	shape_node.name = "MassingShape"
	shape_node.shape = shape
	var body := StaticBody3D.new()
	body.name = "IsleHouseMassingCollision_NoSprayOwnership"
	# Spray rays stop on these volumes (receiver_kind none refuses the tag)
	# instead of passing through to the hidden tower walls inside the wing.
	body.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
	body.collision_mask = 0
	body.set_meta("receiver_kind", "none")
	body.set_meta("opaque", true)
	body.set_meta("spray_ownership", "none")
	body.add_child(shape_node)
	root.add_child(body)


func _mesh_instance(node_name: String, bucket: Dictionary, material: Material, layers: int, role: String) -> MeshInstance3D:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = bucket.vertices
	arrays[Mesh.ARRAY_NORMAL] = bucket.normals
	arrays[Mesh.ARRAY_INDEX] = bucket.indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.layers = layers
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	if role != "":
		instance.set_meta("physical_role", role)
	return instance


# Box with its top face on the roof role when it carries a walkable top.
func _box(key: String, center: Vector3, tangent_value: Vector3, normal_value: Vector3, width: float, height: float, depth: float, solid: bool, roof_top: bool = false) -> void:
	var tangent := tangent_value.normalized()
	var normal := (normal_value - tangent * normal_value.dot(tangent)).normalized()
	var up := Vector3.UP
	var tx := tangent * width * 0.5
	var nz := normal * depth * 0.5
	var uy := up * height * 0.5
	var c := center
	var corners := {
		"fbl": c - tx - uy + nz, "fbr": c + tx - uy + nz, "ftr": c + tx + uy + nz, "ftl": c - tx + uy + nz,
		"bbl": c - tx - uy - nz, "bbr": c + tx - uy - nz, "btr": c + tx + uy - nz, "btl": c - tx + uy - nz,
	}
	var faces := [
		[["fbl", "fbr", "ftr", "ftl"], normal], [["bbr", "bbl", "btl", "btr"], -normal],
		[["ftl", "ftr", "btr", "btl"], up], [["bbl", "bbr", "fbr", "fbl"], -up],
		[["bbl", "fbl", "ftl", "btl"], -tangent], [["fbr", "bbr", "btr", "ftr"], tangent],
	]
	for face: Array in faces:
		var k: Array = face[0]
		var n: Vector3 = face[1]
		var p: Array[Vector3] = [corners[k[0]], corners[k[1]], corners[k[2]], corners[k[3]]]
		if roof_top and n == up:
			_triangle(_roof_surfaces, "roof", p[0], p[1], p[2], n)
			_triangle(_roof_surfaces, "roof", p[0], p[2], p[3], n)
		else:
			_quad(key, p[0], p[1], p[2], p[3], n)
		if solid:
			_collide_quad(p[0], p[1], p[2], p[3], n)


func _quad(key: String, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal: Vector3) -> void:
	_triangle(_surfaces, key, a, b, c, normal)
	_triangle(_surfaces, key, a, c, d, normal)


# Godot front faces wind clockwise seen from the front: order each triangle so
# its geometric normal opposes the requested outward normal's cross product.
func _triangle(target: Dictionary, key: String, a: Vector3, b: Vector3, c: Vector3, normal: Vector3) -> void:
	if not target.has(key):
		target[key] = {"vertices": PackedVector3Array(), "normals": PackedVector3Array(), "indices": PackedInt32Array()}
	var bucket: Dictionary = target[key]
	var base := (bucket.vertices as PackedVector3Array).size()
	var vertices: PackedVector3Array = bucket.vertices
	var normals: PackedVector3Array = bucket.normals
	var indices: PackedInt32Array = bucket.indices
	for p: Vector3 in [a, b, c]:
		vertices.append(p)
		normals.append(normal.normalized())
	if (b - a).cross(c - a).dot(normal) > 0.0:
		indices.append_array([base, base + 2, base + 1])
	else:
		indices.append_array([base, base + 1, base + 2])
	bucket.vertices = vertices
	bucket.normals = normals
	bucket.indices = indices


# Native queries without back faces (the fit harness) see only front faces, so
# wind each collision triangle clockwise as seen from its outward side.
func _collide_quad(a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal: Vector3) -> void:
	_collide_triangle(a, b, c, normal)
	_collide_triangle(a, c, d, normal)


func _collide_triangle(a: Vector3, b: Vector3, c: Vector3, normal: Vector3) -> void:
	if (b - a).cross(c - a).dot(normal) > 0.0:
		_collision.append_array([a, c, b])
	else:
		_collision.append_array([a, b, c])


static func _at(p: Vector3, y: float) -> Vector3:
	return Vector3(p.x, y, p.z)


static func _run_point(record: Dictionary, run: int, end: bool) -> Vector3:
	var v: Array = record.vertices
	var o := run * 12 + (3 if end else 0)
	return Vector3(float(v[o]), float(v[o + 1]), float(v[o + 2]))


static func _run_normal(record: Dictionary, run: int) -> Vector3:
	var n: Array = record.normals
	return Vector3(float(n[run * 12]), 0.0, float(n[run * 12 + 2])).normalized()


static func _record(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		if str((value as Dictionary).get("object_key", "")) == key:
			return value
	return {}
