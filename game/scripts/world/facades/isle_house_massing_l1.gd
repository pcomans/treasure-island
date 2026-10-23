extends RefCounted

## Isle House photo-based massing and upper-floor openings (2026-10-22 ferry L1/L2
## pass), built beside the high facade from the frozen low and high wall records.
## Sep 2025 Street View (WSW, NNW, SE) and the DBA photos/plans show:
## - the WSW wing and the west part of the NNW face rise to the level-7 roof deck
##   (double-height base plus five storeys, about 21m), the ENE/NNW-east part stays
##   at the generated 15m;
## - five rows of paired framed windows on the WSW, slim staggered windows on the
##   NNW and three rows of paired windows over the ENE live-work frontage;
## - a roof penthouse and guardrail on the tower.
## Heights, depths, counts and cadence are production inference scaled from those
## photos, not surveyed. The added volumes own their own solid collision.

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
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1

const MATERIALS := {
	"wall": preload("res://game/resources/materials/world/isle_house/isle_house_podium_mid_warm_v1.tres"),
	"roof": preload("res://game/resources/materials/world/isle_house/isle_house_support_grey.tres"),
	"trim": preload("res://game/resources/materials/world/isle_house/isle_house_podium_light.tres"),
	"frame": preload("res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres"),
	"glass": preload("res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres"),
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
	# Faces that continue the low block's own outer walls take its relief plane.
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
		var offset := out * (FACE_OFFSET if outer_faces.has(i) else 0.0)
		_quad("wall", _at(p, LOW_TOP_Y) + offset, _at(q, LOW_TOP_Y) + offset, _at(q, DECK_Y) + offset, _at(p, DECK_Y) + offset, out)
		if outer_faces.has(i):
			# Cap both ends of the offset face back to the footprint plane so no
			# slot opens where it meets an unoffset neighbour.
			_quad("wall", _at(p, LOW_TOP_Y), _at(p, LOW_TOP_Y) + offset, _at(p, DECK_Y) + offset, _at(p, DECK_Y), -tangent)
			_quad("wall", _at(q, LOW_TOP_Y) + offset, _at(q, LOW_TOP_Y), _at(q, DECK_Y), _at(q, DECK_Y) + offset, tangent)
		_collide_quad(_at(p, LOW_TOP_Y), _at(q, LOW_TOP_Y), _at(q, DECK_Y), _at(p, DECK_Y), out)
		# Deck parapet with a coping and a dark glass guardrail (dba-43/55).
		var length := Vector3(q.x - p.x, 0.0, q.z - p.z).length()
		var mid := (p + q) * 0.5
		_box("trim", _at(mid, DECK_Y + 0.25) + offset - out * 0.12, tangent, out, length + 0.24, 0.5, 0.36, true)
		_box("glass", _at(mid, DECK_Y + 0.85) - out * 0.25, tangent, out, length - 0.1, 0.7, 0.05, true)
	var flat: PackedVector2Array = []
	for p in polygon:
		flat.append(Vector2(p.x, p.z))
	var triangles := Geometry2D.triangulate_polygon(flat)
	if triangles.is_empty():
		return {"ok": false, "message": "Isle House deck polygon did not triangulate."}
	for i in range(0, triangles.size(), 3):
		var t0 := _at(polygon[triangles[i]], DECK_Y)
		var t1 := _at(polygon[triangles[i + 1]], DECK_Y)
		var t2 := _at(polygon[triangles[i + 2]], DECK_Y)
		_triangle(_roof_surfaces, "roof", t0, t1, t2, Vector3.UP)
		_collide_triangle(t0, t1, t2, Vector3.UP)
	# Upper windows. WSW: five rows of paired framed windows over the whole face.
	_window_boxes(a + wsw_normal * FACE_OFFSET, s_axis, wsw_normal, a.distance_to(b), [1, 2, 3, 4, 5])
	_storefront(a, s_axis, wsw_normal, a.distance_to(b))
	# NNW face: slim staggered windows, five rows on the tall west part, three on
	# the lower east part (ih17).
	var nnw_end := _run_point(low, 10, false)
	var nnw_normal := _run_normal(low, 12)
	_slim_pairs(a + nnw_normal * FACE_OFFSET, nnw_dir, nnw_normal, 0.0, NNW_TALL_M, [1, 2, 3, 4, 5])
	_slim_pairs(a + nnw_normal * FACE_OFFSET, nnw_dir, nnw_normal, NNW_TALL_M, a.distance_to(nnw_end), [1, 2, 3])
	# ENE (Garden Walk) upper floors: paired framed windows, three rows.
	var ene_start := _run_point(low, 5, false)
	var ene_end := _run_point(low, 9, true)
	var ene_normal := _run_normal(low, 6)
	_window_boxes(ene_start + ene_normal * FACE_OFFSET, (ene_end - ene_start).normalized(), ene_normal, ene_start.distance_to(ene_end), [1, 2, 3])
	# Courtyard-facing walls of the added storeys: storeys 4 and 5.
	for i in [3, 4]:
		var p := polygon[i]
		var q := polygon[i + 1]
		var tangent := Vector3(q.x - p.x, 0.0, q.z - p.z).normalized()
		var out := Vector3(tangent.z, 0.0, -tangent.x) if signed > 0.0 else Vector3(-tangent.z, 0.0, tangent.x)
		_slim_pairs(p, tangent, out, 0.0, Vector3(q.x - p.x, 0.0, q.z - p.z).length(), [4, 5])
	_tower_extension(high)
	_penthouse(high)
	root.set_meta("roof_box_count", _roof_boxes)
	_emit(root)
	return {"ok": true, "node": root, "deck_polygon": polygon}


# Large framed window boxes (ih01/ih02 WSW, Garden Walk ENE): a white surround
# standing proud of the wall around a two-light dark-framed window, one per bay.
func _window_boxes(origin: Vector3, tangent: Vector3, normal: Vector3, length: float, storeys: Array) -> void:
	var pitch := 3.4
	var count := int(floor((length - 2.4) / pitch))
	if count <= 0:
		return
	var first := (length - pitch * float(count - 1)) * 0.5
	for index in count:
		var u := first + pitch * float(index)
		for storey: int in storeys:
			# Tops stay under the Variant C crown cap at 18.88m on storey 3.
			var bottom := STOREY_BASE_Y + STOREY_M * float(storey - 1) + 0.25
			var width := 2.6
			var height := 2.4
			var center := origin + tangent * u
			center.y = bottom + height * 0.5
			_glazing(center, tangent, normal, width - 0.36, height - 0.36, 1)
			# Surround: four white members 0.18 wide, 0.16 proud.
			_box("trim", center + normal * 0.08 - tangent * (width - 0.18) * 0.5, tangent, normal, 0.18, height, 0.16, false)
			_box("trim", center + normal * 0.08 + tangent * (width - 0.18) * 0.5, tangent, normal, 0.18, height, 0.16, false)
			_box("trim", center + normal * 0.08 + Vector3.UP * (height - 0.18) * 0.5, tangent, normal, width, 0.18, 0.16, false)
			_box("trim", center + normal * 0.08 - Vector3.UP * (height - 0.18) * 0.5, tangent, normal, width, 0.18, 0.16, false)


# Tall narrow dark-framed windows in staggered pairs (ih17 NNW, ih08/ih18).
func _slim_pairs(origin: Vector3, tangent: Vector3, normal: Vector3, from_m: float, to_m: float, storeys: Array) -> void:
	var pitch := 3.6
	var usable := to_m - from_m - 3.4
	if usable <= 0.0:
		return
	var count := int(floor(usable / pitch)) + 1
	var first := from_m + (to_m - from_m - pitch * float(count - 1)) * 0.5
	for index in count:
		for storey: int in storeys:
			var shift := 0.6 if storey % 2 == 0 else -0.6
			for side: float in [-0.6, 0.6]:
				var u := first + pitch * float(index) + shift + side
				if u - 0.45 < from_m + 0.5 or u + 0.45 > to_m - 0.5:
					continue
				var center := origin + tangent * u
				center.y = STOREY_BASE_Y + STOREY_M * float(storey - 1) + 0.25 + 1.175
				_glazing(center, tangent, normal, 0.85, 2.35, 0)


# Dark-framed glazing: glass panel with a frame and optional centre mullion.
func _glazing(center: Vector3, tangent: Vector3, normal: Vector3, width: float, height: float, mullions: int) -> void:
	var frame := 0.08
	_box("glass", center + normal * 0.05, tangent, normal, width - frame, height - frame, 0.02, false)
	for side: float in [-1.0, 1.0]:
		_box("frame", center + normal * 0.075 + tangent * side * (width - frame) * 0.5, tangent, normal, frame, height, 0.05, false)
		_box("frame", center + normal * 0.075 + Vector3.UP * side * (height - frame) * 0.5, tangent, normal, width, frame, 0.05, false)
	for index in mullions:
		var u := -width * 0.5 + width * float(index + 1) / float(mullions + 1)
		_box("frame", center + normal * 0.075 + tangent * u, tangent, normal, 0.06, height - frame, 0.04, false)


# WSW double-height storefront and live-work glazing (ih01/ih02, dba-6):
# continuous glazing with a mezzanine transom between concrete columns and
# charcoal piers, and the garage door near the tower. Render-only, over the
# unchanged receiver; replaces the Variant C base modules on this side. Glass
# and frames stay within 0.04m of the receiver (Variant C brick field at
# 0.014m behind them) so a spray decal, projected +-0.04m about the receiver,
# shows on the glazing instead of hiding behind it.
func _storefront(origin: Vector3, tangent: Vector3, normal: Vector3, length: float) -> void:
	# Up to the Variant C transfer plinth (10.25) so no brick band shows above,
	# and down past the lowest source wall bottom (3.98).
	var bottom := 3.95
	var top := 10.25
	var bay := 6.4
	var count := int(floor(length / bay))
	var first := (length - bay * float(count)) * 0.5
	var garage_u := length - 9.0
	for index in count + 1:
		var u := first + bay * float(index)
		var concrete := index % 2 == 0
		var width := 0.7 if concrete else 1.0
		var center := origin + tangent * clampf(u, width * 0.5, length - width * 0.5)
		center.y = (bottom + top) * 0.5
		_box("trim" if concrete else "frame", center + normal * 0.06, tangent, normal, width, top - bottom, 0.1, false)
	for index in count:
		var left := first + bay * float(index) + (0.35 if index % 2 == 0 else 0.5)
		var right := first + bay * float(index + 1) - (0.5 if index % 2 == 0 else 0.35)
		var mid := (left + right) * 0.5
		var center := origin + tangent * mid
		if absf(mid - garage_u) < bay * 0.5:
			# Garage roll-up door with slats, glazing above.
			center.y = (bottom + 7.4) * 0.5
			_box("frame", center + normal * 0.025, tangent, normal, right - left, 7.4 - bottom, 0.01, false)
			for k in range(1, 12):
				var slat := center + normal * 0.034
				slat.y = bottom + (7.4 - bottom) * float(k) / 12.0
				_box("trim", slat, tangent, normal, right - left - 0.2, 0.05, 0.008, false)
			center.y = (7.4 + top) * 0.5
			_flush_glazing(center, tangent, normal, right - left, top - 7.4, 2)
			continue
		var lower := origin + tangent * mid
		lower.y = (bottom + 7.25) * 0.5
		_flush_glazing(lower, tangent, normal, right - left, 7.25 - bottom, 3)
		var upper := origin + tangent * mid
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


# Roof penthouse (ih21, dba-50/52): an offset plant box and a perimeter guardrail.
func _penthouse(high: Dictionary) -> void:
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
	_roof_box(outline, "tower", middle, along, se_normal, half.x * 2.0, 4.0, half.y * 2.0, true)
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


# Tower height override: walls on the frozen tower runs from the generated
# roof up to TOWER_TOP_Y, and a new roof (the high facade fields cover the walls).
func _tower_extension(high: Dictionary) -> void:
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
	assert(not triangles.is_empty(), "Isle House tower outline did not triangulate")
	for i in range(0, triangles.size(), 3):
		var t0 := _at(points[triangles[i]], TOWER_TOP_Y)
		var t1 := _at(points[triangles[i + 1]], TOWER_TOP_Y)
		var t2 := _at(points[triangles[i + 2]], TOWER_TOP_Y)
		_triangle(_roof_surfaces, "roof", t0, t1, t2, Vector3.UP)
		_collide_triangle(t0, t1, t2, Vector3.UP)


# A solid roof-top box, emitted only when its whole footprint lies on the roof.
func _roof_box(outline: PackedVector2Array, key: String, middle: Vector3, along: Vector3, normal: Vector3, width: float, height: float, depth: float, required: bool) -> void:
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var p := middle + along * corner.x * width * 0.5 + normal * corner.y * depth * 0.5
		if not Geometry2D.is_point_in_polygon(Vector2(p.x, p.z), outline):
			assert(not required, "Isle House penthouse footprint left the tower roof")
			return
	_roof_boxes += 1
	_box(key, _at(middle, TOWER_TOP_Y + height * 0.5), along, normal, width, height, depth, true, true)


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
	body.collision_layer = PHYSICS_WORLD_SOLID
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
