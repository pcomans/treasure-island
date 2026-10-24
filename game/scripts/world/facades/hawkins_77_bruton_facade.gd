class_name Hawkins77BrutonFacade
extends Node3D

## Render-only Hawkins facade over the runtime massing walls (2026-10-22 ferry
## L1/L2/L3 pass; 2026-10-23 rework from a component reading of the Sep 2025
## Street View and the architect's photos): a smooth light-grey base (dark
## ribbed on the Bruton front), silver fluted cladding between flat white
## pilaster strips, stacked narrow and wide windows in grey frames with white
## sills and heads, fluted fronts on the projecting bay boxes of storeys 2-3
## (SE and WSW) with white-framed two-storey window groups, the glazed slot at
## the 4/6-storey junction (SE), a mid-face glazing bay and corner glazing
## (ENE), a glazed set-back top storey behind a glass rail on the 4-storey
## wing, doors at the stoops and the SE lobby, HAWKINS sign and garage.
## Cadence, sizes and positions are production inference.

const TARGET_SOURCE_KEY := "w1249412093"
const TARGET_LOGICAL_OBJECT_KEY := "building:w1249412093"
const TARGET_RECEIVER_OBJECT_KEY := "building:w1249412093:wall"
const RENDER_BUILDING_WALL := 1 << 1
const MASSING := preload("res://game/scripts/world/massing/hawkins_77_bruton_massing.gd")
const FIELD_OFFSET_M := 0.012
const MAXIMUM_RELIEF_M := 0.12
# Bay (hk07, measured on one plane): a narrow unit, a fluted strip, a wide
# two-pane unit, then a flat white pilaster; units cover about half the bay.
const BAY_PITCH_M := 4.2
const NARROW_W := 0.95
const WIDE_W := 1.75
const UNIT_GAP_M := 0.35
const SPANDREL_H := 0.3
const UNIT_BOTTOM_ABOVE_STOREY_M := 0.15
const GLASS_H := 2.75
const PILASTER_W := 0.6
const MATERIALS := {
	"pearl_fluted": preload("res://game/resources/materials/world/hawkins/hawkins_pearl_fluted.tres"),
	"pearl_plain": preload("res://game/resources/materials/world/hawkins/hawkins_pearl_plain.tres"),
	"base_smooth": preload("res://game/resources/materials/world/hawkins/hawkins_base_smooth.tres"),
	"frame_grey": preload("res://game/resources/materials/world/hawkins/hawkins_frame_grey.tres"),
	"base_ribbed": preload("res://game/resources/materials/world/hawkins/hawkins_base_ribbed.tres"),
	"frame_charcoal": preload("res://game/resources/materials/world/hawkins/hawkins_frame_charcoal.tres"),
	"glass_proxy": preload("res://game/resources/materials/world/hawkins/hawkins_glass_proxy.tres"),
	"spandrel_pale": preload("res://game/resources/materials/world/hawkins/hawkins_spandrel_pale.tres"),
	"garage_dark": preload("res://game/resources/materials/world/hawkins/hawkins_garage_dark.tres"),
	"sign_letters": preload("res://game/resources/materials/world/hawkins/hawkins_sign_letters.tres"),
}
# SE ground modules (u from the S corner): full-height lobby glazing from the
# recessed corner to the "77" doors, HAWKINS on a fascia under the box soffit
# (cav-2, cav-7, hk02), service door and garage.
const SE_GROUND := [
	["lobby", 7.9, 11.6, 3.0, 5.85], ["door", 15.0, 2.4, 2.48, 5.77], ["sign", 9.0, 5.6, 0.45, 7.5],
	["service", 28.0, 1.5, 2.35, 5.73], ["garage", 38.0, 5.4, 2.45, 5.72],
]
# Full-height dark glazing strips: [side, u, width] (SE junction slot, ENE mid
# bay and N corner glazing).
# The SE slot sits on the 6-storey side of the split station (33 m).
# E and N corners carry full-height glazing on both faces (hk13, hk09).
const GLAZING_STRIPS := [["se", 34.45, 2.8], ["ene", 30.0, 2.4], ["ene", 0.8, 1.6], ["se", 58.64, 1.6], ["ene", 59.34, 1.6], ["nnw", 0.8, 1.6]]

var _boxes_by_material: Dictionary = {}
# Per side: Vector3(u_from, u_to, wall top) of every outer wall quad.
var _outer_ranges: Dictionary = {}
var _fields: Dictionary = {}


static func matches_target(record: Dictionary) -> bool:
	var source_keys: Array = record.get("source_keys", [])
	return str(record.get("object_key", "")) == TARGET_RECEIVER_OBJECT_KEY \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and source_keys.size() == 1 \
		and str(source_keys[0]) == TARGET_SOURCE_KEY


func configure(record: Dictionary, wall_geometry: Dictionary) -> Dictionary:
	if not matches_target(record) or not bool(wall_geometry.get("ok", false)):
		return {"ok": false, "message": "Hawkins facade refused a non-target receiver or missing massing."}
	name = "Hawkins77BrutonFacade"
	set_meta("target_source_key", TARGET_SOURCE_KEY)
	set_meta("target_logical_object_key", TARGET_LOGICAL_OBJECT_KEY)
	set_meta("target_receiver_object_key", TARGET_RECEIVER_OBJECT_KEY)
	set_meta("render_only", true)
	set_meta("collision", "none")
	set_meta("navigation", "none")
	set_meta("spray_ray_owner", "unchanged_underlying_receiver")
	set_meta("maximum_relief_m", MAXIMUM_RELIEF_M)
	add_to_group("hawkins_render_only_facade")
	var outer_count := 0
	_outer_ranges = {}
	for quad: Dictionary in wall_geometry.quads:
		var role := str(quad.role)
		var side := _side_of(quad)
		if role == "outer":
			if side == "":
				# Back and return walls of the massing notches (2026-10-24 form
				# study): plain cladding until the Stage B facade grid.
				_field(quad, -INF, INF, "pearl_fluted")
				continue
			outer_count += 1
			_field(quad, MASSING.BASE_Y - 1.0, MASSING.DECK_Y, "base_ribbed" if side == "se" else "base_smooth")
			_field(quad, MASSING.DECK_Y, INF, "pearl_fluted")
			if not _outer_ranges.has(side):
				_outer_ranges[side] = []
			var range_u := _u_range(quad, side)
			(_outer_ranges[side] as Array).append(Vector3(range_u.x, range_u.y, (quad.start_top as Vector3).y))
			if str(quad.volume) == "terrace":
				_terrace_rail(quad, side)
		else:
			# The recessed ground storey reads as a deep shadow line (cav-3, hk02).
			_field(quad, -INF, INF, "base_ribbed" if role == "recess" else "pearl_fluted")
			if role == "setback" and side != "":
				_setback_glazing(quad, side)
	for side: String in _outer_ranges:
		_upper_bays(side)
	for side: String in MASSING.BAY_BOX_U_RANGES:
		_bay_box(side)
	for strip: Array in GLAZING_STRIPS:
		_glazing_strip(str(strip[0]), float(strip[1]), float(strip[2]))
	_ground_floor()
	_flush()
	set_meta("outer_wall_quads", outer_count)
	return {"ok": true, "outer_wall_quads": outer_count}


# Which footprint side a quad faces (by normal) and lies on: the footprint line
# for outer walls, the setback line for every other wall ("" if neither).
func _side_of(quad: Dictionary) -> String:
	var normal := quad.normal as Vector3
	for side: String in MASSING.SIDES:
		var f := MASSING.side_frame(side)
		var n := f.normal as Vector2
		if Vector2(normal.x, normal.z).dot(n) < 0.999:
			continue
		var p := quad.start_bottom as Vector3
		var offset := (Vector2(p.x, p.z) - (f.start as Vector2)).dot(n)
		if absf(offset) < 0.05 if str(quad.role) == "outer" else absf(offset + MASSING.SETBACK_M) < 0.05:
			return side
	return ""


func _u_range(quad: Dictionary, side: String) -> Vector2:
	var f := MASSING.side_frame(side)
	var a := quad.start_bottom as Vector3
	var b := quad.end_bottom as Vector3
	var ua := (Vector2(a.x, a.z) - (f.start as Vector2)).dot(f.tangent)
	var ub := (Vector2(b.x, b.z) - (f.start as Vector2)).dot(f.tangent)
	return Vector2(minf(ua, ub), maxf(ua, ub))


func _field(quad: Dictionary, bottom: float, top: float, material: String) -> void:
	var sb := quad.start_bottom as Vector3
	var eb := quad.end_bottom as Vector3
	var y_top := minf(top, (quad.start_top as Vector3).y)
	var normal := quad.normal as Vector3
	var offset := normal * FIELD_OFFSET_M
	var b0 := maxf(bottom, sb.y)
	var b1 := maxf(bottom, eb.y)
	if y_top <= maxf(b0, b1):
		return
	if not _fields.has(material):
		_fields[material] = {"vertices": PackedVector3Array(), "normals": PackedVector3Array(), "indices": PackedInt32Array()}
	var group: Dictionary = _fields[material]
	var vertices: PackedVector3Array = group.vertices
	var normals: PackedVector3Array = group.normals
	var indices: PackedInt32Array = group.indices
	var base := vertices.size()
	for v: Vector3 in [Vector3(sb.x, b0, sb.z), Vector3(eb.x, b1, eb.z), Vector3(eb.x, y_top, eb.z), Vector3(sb.x, y_top, sb.z)]:
		vertices.append(v + offset)
		normals.append(normal)
	indices.append_array([base, base + 2, base + 1, base, base + 3, base + 2])
	group.vertices = vertices
	group.normals = normals
	group.indices = indices


# Outer wall top at u on a side (NAN where no outer wall stands).
func _top_at(side: String, u: float) -> float:
	for r: Vector3 in _outer_ranges.get(side, []):
		if u >= r.x - 0.001 and u <= r.y + 0.001:
			return r.z
	return NAN


# Window bays over a side's whole outer range (not per wall quad, so bays may
# straddle source-run splits): flat white pilasters at the bay lines, and per
# storey a narrow and a wide window unit with a grey spandrel panel below and
# white sills and heads. On the WSW low wing the units run two storeys (cav3).
func _upper_bays(side: String) -> void:
	var length: float = MASSING.side_frame(side).length
	var count := int(floor(length / BAY_PITCH_M))
	var first := (length - BAY_PITCH_M * float(count)) * 0.5
	for index in count + 1:
		var line_u := first + BAY_PITCH_M * float(index)
		var top := minf(_top_at(side, line_u - PILASTER_W * 0.5), _top_at(side, line_u + PILASTER_W * 0.5))
		if not is_nan(top) and not _near_strip(side, line_u, PILASTER_W):
			var from_y := MASSING.TERRACE_Y if _in_box(side, line_u, PILASTER_W) else MASSING.DECK_Y
			if top > from_y + 0.1:
				_add_box("pearl_plain", side, 0.0, line_u, (from_y + top) * 0.5, PILASTER_W, top - from_y, FIELD_OFFSET_M, 0.06)
	var group_w := NARROW_W + UNIT_GAP_M + WIDE_W
	for index in count:
		var center := first + BAY_PITCH_M * (float(index) + 0.5)
		var left := center - group_w * 0.5
		var right := center + group_w * 0.5
		var top := _top_at(side, center)
		if is_nan(top) or _top_at(side, left - 0.1) != top or _top_at(side, right + 0.1) != top or _near_strip(side, center, group_w):
			continue
		var narrow_u := left + NARROW_W * 0.5
		var wide_u := right - WIDE_W * 0.5
		var double_height := side == "wsw" and is_equal_approx(top, MASSING.TERRACE_Y)
		var storey := 2
		while MASSING.BASE_Y + MASSING.STOREY_M * float(storey) <= top + 0.01:
			var floor_y := MASSING.BASE_Y + MASSING.STOREY_M * float(storey - 1)
			if floor_y < MASSING.TERRACE_Y - 0.01 and _in_box(side, center, group_w):
				storey += 1
				continue
			var span := 2 if double_height and MASSING.BASE_Y + MASSING.STOREY_M * float(storey + 1) <= top + 0.01 else 1
			var bottom := floor_y + UNIT_BOTTOM_ABOVE_STOREY_M
			var height := MASSING.STOREY_M * float(span) - UNIT_BOTTOM_ABOVE_STOREY_M - 0.25
			for unit: Array in [[narrow_u, NARROW_W, 0], [wide_u, WIDE_W, 1]]:
				var u: float = unit[0]
				var w: float = unit[1]
				_add_box("spandrel_pale", side, 0.0, u, bottom + SPANDREL_H * 0.5, w, SPANDREL_H, FIELD_OFFSET_M, 0.03)
				_window(side, 0.0, u, bottom + SPANDREL_H, w, height - SPANDREL_H, int(unit[2]))
				if span == 2:
					# Floor band across the two-storey unit.
					_add_box("spandrel_pale", side, 0.0, u, floor_y + MASSING.STOREY_M + 0.05, w, 0.4, FIELD_OFFSET_M, 0.04)
			_add_box("pearl_plain", side, 0.0, center, bottom - 0.05, group_w + 0.3, 0.1, FIELD_OFFSET_M, 0.11)
			_add_box("pearl_plain", side, 0.0, center, bottom + height + 0.05, group_w + 0.2, 0.1, FIELD_OFFSET_M, 0.07)
			storey += span


# Framed window unit: glass, a slim grey frame, a low transom and optional
# vertical mullions.
func _window(side: String, plane: float, u: float, bottom: float, width: float, height: float, mullions: int = 0) -> void:
	var y := bottom + height * 0.5
	_add_box("glass_proxy", side, plane, u, y, width - 0.1, height - 0.1, FIELD_OFFSET_M, 0.03)
	for s: float in [-1.0, 1.0]:
		_add_box("frame_grey", side, plane, u + s * (width - 0.06) * 0.5, y, 0.06, height, 0.03, 0.05)
		_add_box("frame_grey", side, plane, u, y + s * (height - 0.06) * 0.5, width, 0.06, 0.03, 0.05)
	_add_box("frame_grey", side, plane, u, bottom + minf(0.7, height * 0.3), width - 0.1, 0.05, 0.03, 0.045)
	for k in mullions:
		_add_box("frame_grey", side, plane, u - width * 0.5 + width * float(k + 1) / float(mullions + 1), y, 0.05, height - 0.1, 0.03, 0.045)


# Set-back top storey on the 4-storey wing: storey-high glazing with mullions.
func _setback_glazing(quad: Dictionary, side: String) -> void:
	var range_u := _u_range(quad, side)
	var bottom := MASSING.TERRACE_Y + 0.1
	var height := MASSING.LOW_TOP_Y - MASSING.TERRACE_Y - 0.35
	var plane := -MASSING.SETBACK_M
	var width := range_u.y - range_u.x - 0.3
	if width <= 0.5:
		return
	var center := (range_u.x + range_u.y) * 0.5
	_add_box("glass_proxy", side, plane, center, bottom + height * 0.5, width, height, FIELD_OFFSET_M, 0.03)
	var count := int(floor(width / 1.5))
	for k in count + 1:
		_add_box("frame_charcoal", side, plane, center - width * 0.5 + width * float(k) / float(maxi(count, 1)), bottom + height * 0.5, 0.08, height, 0.03, 0.06)
	_add_box("frame_charcoal", side, plane, center, bottom + 1.05, width, 0.06, 0.03, 0.06)


# Glass guardrail on the terrace edge, just inside the parapet line.
func _terrace_rail(quad: Dictionary, side: String) -> void:
	var range_u := _u_range(quad, side)
	var width := range_u.y - range_u.x - 0.1
	if width <= 0.2:
		return
	var center := (range_u.x + range_u.y) * 0.5
	_add_box("glass_proxy", side, -0.15, center, MASSING.TERRACE_Y + 0.47, width, 0.94, -0.02, 0.0)
	_add_box("frame_charcoal", side, -0.15, center, MASSING.TERRACE_Y + 0.92, width, 0.05, -0.04, 0.02)


# Whether [u - width/2, u + width/2] overlaps a side's projecting bay box.
func _in_box(side: String, u: float, width: float) -> bool:
	if not MASSING.BAY_BOX_U_RANGES.has(side):
		return false
	var u_range: Vector2 = MASSING.bay_box_range(side)
	return u + width * 0.5 > u_range.x and u - width * 0.5 < u_range.y


# Bay box front (cav-7, hk02, cav-3, hk23): a silver fluted field inside a white
# border on the box face, with white-framed two-storey window groups of two
# tall lights split by a white floor band, about 6m apart.
func _bay_box(side: String) -> void:
	var u_range: Vector2 = MASSING.bay_box_range(side)
	var plane := MASSING.BAY_BOX_DEPTH_M
	var border := 0.25
	_plane_field(side, plane, u_range.x + border, u_range.y - border, MASSING.DECK_Y + border, MASSING.TERRACE_Y - border, "pearl_fluted")
	var pitch := 6.0
	var length := u_range.y - u_range.x - 2.0 * border
	var count := maxi(int(floor(length / pitch)), 1)
	var first := u_range.x + border + (length - pitch * float(count - 1)) * 0.5
	var bottom := MASSING.DECK_Y + 0.55
	var top := MASSING.TERRACE_Y - 0.45
	var band := MASSING.DECK_Y + MASSING.STOREY_M
	for index in count:
		var u := first + pitch * float(index)
		# White surround: jambs, sill, head and the centre mullion.
		var mid_y := (bottom + top) * 0.5
		for k: float in [-1.0, 1.0]:
			_add_box("pearl_plain", side, plane, u + k * 1.525, mid_y, 0.25, top - bottom + 0.5, FIELD_OFFSET_M, 0.1)
			_add_box("pearl_plain", side, plane, u, mid_y + k * (top - bottom + 0.25) * 0.5, 3.3, 0.25, FIELD_OFFSET_M, 0.1)
		_add_box("pearl_plain", side, plane, u, mid_y, 0.2, top - bottom, FIELD_OFFSET_M, 0.1)
		for k: float in [-1.0, 1.0]:
			var lu := u + k * 0.75
			_window(side, plane, lu, bottom, 1.3, band - 0.25 - bottom, 0)
			_window(side, plane, lu, band + 0.25, 1.3, top - band - 0.25, 0)
		_add_box("pearl_plain", side, plane, u, band, 3.3, 0.5, FIELD_OFFSET_M, 0.11)


# Field quad on a plane `plane` metres outside a side's footprint line.
func _plane_field(side: String, plane: float, u0: float, u1: float, y0: float, y1: float, material: String) -> void:
	var f := MASSING.side_frame(side)
	var t := Vector3((f.tangent as Vector2).x, 0.0, (f.tangent as Vector2).y)
	var n := Vector3((f.normal as Vector2).x, 0.0, (f.normal as Vector2).y)
	var start := f.start as Vector2
	var origin := Vector3(start.x, 0.0, start.y) + n * (plane + FIELD_OFFSET_M)
	if not _fields.has(material):
		_fields[material] = {"vertices": PackedVector3Array(), "normals": PackedVector3Array(), "indices": PackedInt32Array()}
	var group: Dictionary = _fields[material]
	var vertices: PackedVector3Array = group.vertices
	var normals: PackedVector3Array = group.normals
	var indices: PackedInt32Array = group.indices
	var base := vertices.size()
	for v: Vector3 in [origin + t * u0 + Vector3.UP * y0, origin + t * u1 + Vector3.UP * y0, origin + t * u1 + Vector3.UP * y1, origin + t * u0 + Vector3.UP * y1]:
		vertices.append(v)
		normals.append(n)
	indices.append_array([base, base + 2, base + 1, base, base + 3, base + 2])
	group.vertices = vertices
	group.normals = normals
	group.indices = indices


func _near_strip(side: String, u: float, width: float) -> bool:
	for strip: Array in GLAZING_STRIPS:
		if str(strip[0]) == side and absf(float(strip[1]) - u) < (float(strip[2]) + width) * 0.5 + 0.2:
			return true
	return false


func _glazing_strip(side: String, u: float, width: float) -> void:
	var length: float = MASSING.side_frame(side).length
	u = clampf(u, width * 0.5, length - width * 0.5)
	var bottom := MASSING.DECK_Y
	var top := MASSING.TALL_TOP_Y - 0.05
	_add_box("glass_proxy", side, 0.0, u, (bottom + top) * 0.5, width, top - bottom, FIELD_OFFSET_M, 0.03)
	var storey := 2
	while MASSING.BASE_Y + MASSING.STOREY_M * float(storey - 1) < top - 0.1:
		var y := MASSING.BASE_Y + MASSING.STOREY_M * float(storey - 1)
		_add_box("frame_charcoal", side, 0.0, u, y, width, 0.12, 0.03, 0.06)
		storey += 1
	for s: float in [-1.0, 1.0]:
		_add_box("frame_charcoal", side, 0.0, u + s * (width - 0.08) * 0.5, (bottom + top) * 0.5, 0.08, top - bottom, 0.03, 0.06)


# Ground storey: stoop doors with a side window (WSW/ENE), ground windows on
# the remaining bays (ENE/NNW/WSW), and the accepted SE lobby, sign and garage.
func _ground_floor() -> void:
	var door_us := {"wsw": [], "ene": []}
	for stoop: Array in MASSING.STOOPS:
		var side := str(stoop[0])
		var u: float = stoop[1]
		var platform: float = float(stoop[2]) + MASSING.STOOP_RISE_M
		_door(side, u, platform, 1.1, 2.45)
		_window(side, _ground_plane(side, u + 1.55), u + 1.55, platform + 0.4, 1.0, 2.0)
		(door_us[side] as Array).append(u)
	for side: String in ["wsw", "ene", "nnw"]:
		var length: float = MASSING.side_frame(side).length
		var count := int(floor(length / BAY_PITCH_M))
		var first := (length - BAY_PITCH_M * float(count)) * 0.5
		for index in count:
			var center := first + BAY_PITCH_M * (float(index) + 0.5)
			var blocked := _near_strip(side, center, 2.0) or center < 1.5 or center > length - 1.5
			# The S corner glazing takes the WSW end (cav-2).
			if side == "wsw" and center > MASSING.recess_range("wsw").y - 9.0:
				blocked = true
			for door_u: Variant in door_us.get(side, []):
				if absf(float(door_u) - center) < 3.2:
					blocked = true
			if not blocked:
				_window(side, _ground_plane(side, center), center - 0.6, 5.0, NARROW_W, 2.3)
				_window(side, _ground_plane(side, center), center + 0.75, 5.0, 1.45, 2.3, 1)
	# Full-height corner glazing on the WSW end under the box (cav-2).
	var corner_u: float = MASSING.recess_range("wsw").y
	_storefront_glass("wsw", corner_u - 4.1, 7.6, 3.0, 5.85)
	for module: Array in SE_GROUND:
		var kind := str(module[0])
		var u: float = module[1]
		var width: float = module[2]
		var height: float = module[3]
		var y: float = module[4]
		match kind:
			"lobby":
				_storefront_glass("se", u, width, height, y)
			"door":
				_door("se", u, y - height * 0.5, width, height)
			"sign":
				_add_box("base_ribbed", "se", _ground_plane("se", u), u, y, width, height, FIELD_OFFSET_M, 0.04)
				_add_sign_letters(u, y, width, height, _ground_plane("se", u))
			"service":
				_add_box("garage_dark", "se", _ground_plane("se", u), u, y, width - 0.16, height - 0.16, FIELD_OFFSET_M, 0.03)
			"garage":
				_add_box("garage_dark", "se", 0.0, u, y, width - 0.18, height - 0.18, FIELD_OFFSET_M, 0.03)
				for k in 8:
					_add_box("frame_charcoal", "se", 0.0, u, y - height * 0.4 + float(k) * height * 0.115, width - 0.22, 0.04, 0.03, 0.045)


# Storefront glazing in slim grey frames on a side's ground plane at u.
func _storefront_glass(side: String, u: float, width: float, height: float, y: float) -> void:
	var plane := _ground_plane(side, u)
	_add_box("glass_proxy", side, plane, u, y, width - 0.2, height - 0.2, FIELD_OFFSET_M, 0.03)
	var panes := int(round(width / 1.7))
	for k in panes + 1:
		_add_box("frame_grey", side, plane, u - (width - 0.1) * 0.5 + (width - 0.1) * float(k) / float(panes), y, 0.1, height, 0.03, 0.05)
	_add_box("frame_grey", side, plane, u, y + height * 0.5, width, 0.1, 0.03, 0.05)


func _door(side: String, u: float, bottom: float, width: float, height: float) -> void:
	var plane := _ground_plane(side, u)
	var y := bottom + height * 0.5
	_add_box("glass_proxy", side, plane, u, y, width - 0.12, height - 0.06, FIELD_OFFSET_M, 0.03)
	for s: float in [-1.0, 1.0]:
		_add_box("frame_charcoal", side, plane, u + s * (width - 0.08) * 0.5, y, 0.08, height, 0.03, 0.05)
	_add_box("frame_charcoal", side, plane, u, bottom + height - 0.04, width, 0.08, 0.03, 0.05)
	# Small entry canopy over the door (not under the box soffit).
	if plane == 0.0:
		_add_box("pearl_plain", side, plane, u, bottom + height + 0.12, width + 0.6, 0.1, FIELD_OFFSET_M, MAXIMUM_RELIEF_M)


# Ground-storey plane at u: recessed under the bay boxes, else the footprint line.
func _ground_plane(side: String, u: float) -> float:
	var r: Vector2 = MASSING.recess_range(side)
	return -MASSING.RECESS_M if u > r.x and u < r.y else 0.0


func _add_sign_letters(center_u: float, center_y: float, fascia_width: float, fascia_height: float, plane: float) -> void:
	var glyphs := {
		"H": [[0.0, 0.0, 0.0, 1.0], [1.0, 0.0, 1.0, 1.0], [0.0, 0.5, 1.0, 0.5]],
		"A": [[0.0, 0.0, 0.18, 1.0], [1.0, 0.0, 0.82, 1.0], [0.18, 1.0, 0.82, 1.0], [0.1, 0.52, 0.9, 0.52]],
		"W": [[0.0, 1.0, 0.2, 0.0], [0.2, 0.0, 0.5, 0.55], [0.5, 0.55, 0.8, 0.0], [0.8, 0.0, 1.0, 1.0]],
		"K": [[0.0, 0.0, 0.0, 1.0], [0.0, 0.5, 1.0, 1.0], [0.0, 0.5, 1.0, 0.0]],
		"I": [[0.0, 1.0, 1.0, 1.0], [0.5, 0.0, 0.5, 1.0], [0.0, 0.0, 1.0, 0.0]],
		"N": [[0.0, 0.0, 0.0, 1.0], [0.0, 1.0, 1.0, 0.0], [1.0, 0.0, 1.0, 1.0]],
		"S": [[0.0, 1.0, 1.0, 1.0], [0.0, 0.5, 1.0, 0.5], [0.0, 0.0, 1.0, 0.0], [0.0, 0.5, 0.0, 1.0], [1.0, 0.0, 1.0, 0.5]],
	}
	var text := "HAWKINS"
	var letter_width := minf(0.38, fascia_width / 9.5)
	var letter_height := minf(0.34, fascia_height * 0.62)
	var gap := letter_width * 0.26
	var total := float(text.length()) * letter_width + float(text.length() - 1) * gap
	var stroke := minf(0.055, letter_width * 0.16)
	for i in text.length():
		var left := center_u - total * 0.5 + float(i) * (letter_width + gap)
		for segment: Array in glyphs[text.substr(i, 1)]:
			var from := Vector2(left + float(segment[0]) * letter_width, center_y - letter_height * 0.5 + float(segment[1]) * letter_height)
			var to := Vector2(left + float(segment[2]) * letter_width, center_y - letter_height * 0.5 + float(segment[3]) * letter_height)
			var delta := to - from
			if delta.length() < 0.0001:
				continue
			var f := MASSING.side_frame("se")
			var t := Vector3((f.tangent as Vector2).x, 0.0, (f.tangent as Vector2).y)
			var n := Vector3((f.normal as Vector2).x, 0.0, (f.normal as Vector2).y)
			var direction := (t * delta.x + Vector3.UP * delta.y).normalized()
			var across := (t * -delta.y + Vector3.UP * delta.x).normalized()
			var mid := (from + to) * 0.5
			var start := f.start as Vector2
			var origin := Vector3(start.x, mid.y, start.y) + t * mid.x + n * (plane + 0.07)
			_push("sign_letters", Transform3D(Basis(direction * delta.length(), across * stroke, n * 0.03), origin))


# Box on a side plane `plane` metres outside the footprint line (negative is
# inside), between `inner` and `outer` metres in front of that plane.
func _add_box(material: String, side: String, plane: float, u: float, y: float, width: float, height: float, inner: float, outer: float) -> void:
	assert(MATERIALS.has(material) and width > 0.0 and height > 0.0 and outer > inner and outer <= MAXIMUM_RELIEF_M + 0.0001)
	var f := MASSING.side_frame(side)
	var t := Vector3((f.tangent as Vector2).x, 0.0, (f.tangent as Vector2).y)
	var n := Vector3((f.normal as Vector2).x, 0.0, (f.normal as Vector2).y)
	var start := f.start as Vector2
	var origin := Vector3(start.x, y, start.y) + t * u + n * (plane + (inner + outer) * 0.5)
	_push(material, Transform3D(Basis(t * width, Vector3.UP * height, n * (outer - inner)), origin))


func _push(material: String, transform: Transform3D) -> void:
	if not _boxes_by_material.has(material):
		_boxes_by_material[material] = []
	(_boxes_by_material[material] as Array).append(transform)


func _flush() -> void:
	var fields := ArrayMesh.new()
	var keys := _fields.keys()
	keys.sort()
	for key: Variant in keys:
		var group: Dictionary = _fields[key]
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = group.vertices
		arrays[Mesh.ARRAY_NORMAL] = group.normals
		arrays[Mesh.ARRAY_INDEX] = group.indices
		fields.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		fields.surface_set_material(fields.get_surface_count() - 1, MATERIALS[key] as Material)
	var field_node := MeshInstance3D.new()
	field_node.name = "FacadeFields"
	field_node.mesh = fields
	field_node.layers = RENDER_BUILDING_WALL
	field_node.set_meta("facade_visual", true)
	add_child(field_node)
	var batches := Node3D.new()
	batches.name = "RenderBatches"
	batches.set_meta("render_only", true)
	add_child(batches)
	var box_keys := _boxes_by_material.keys()
	box_keys.sort()
	for key: Variant in box_keys:
		var transforms: Array = _boxes_by_material[key]
		var box := BoxMesh.new()
		box.size = Vector3.ONE
		box.material = MATERIALS[key] as Material
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = box
		multimesh.instance_count = transforms.size()
		for i in transforms.size():
			multimesh.set_instance_transform(i, transforms[i])
		var instance := MultiMeshInstance3D.new()
		instance.name = "Batch_%s" % key
		instance.multimesh = multimesh
		instance.layers = RENDER_BUILDING_WALL
		instance.set_meta("facade_visual", true)
		instance.set_meta("material_key", key)
		instance.set_meta("instance_count", transforms.size())
		batches.add_child(instance)
