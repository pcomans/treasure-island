class_name Hawkins77BrutonFacade
extends Node3D

## Render-only Hawkins facade assemblies (2026-10-24 Stage B) over the massing's
## punched wall receiver: the window openings, reveals and panes belong to the
## massing (Hawkins77BrutonMassing.openings(), one structural grid per face); this
## node adds what sits in and around them: grey frames, mullions and transoms in the
## panes, white sills and stack surrounds on the tall blocks, dark spandrels across
## the joined NNW floors, the white-framed two-storey groups on the projecting boxes,
## curtain-wall grids on the glazed slots, strip, loggia and set-back storey, and the
## base: storefront grids, doors, the louvre screen, the HAWKINS fascia, the ribbed
## pier and the garage. Sizes and positions are production inference from rectified
## Sep 2025 Street View and the architect's photos (grid tables in the task note).

const TARGET_SOURCE_KEY := "w1249412093"
const TARGET_LOGICAL_OBJECT_KEY := "building:w1249412093"
const TARGET_RECEIVER_OBJECT_KEY := "building:w1249412093:wall"
const RENDER_BUILDING_WALL := 1 << 1
const MASSING := preload("res://game/scripts/world/massing/hawkins_77_bruton_massing.gd")
const MAXIMUM_RELIEF_M := 0.12
const FRAME_W := 0.06
const MATERIALS := {
	"pearl_plain": preload("res://game/resources/materials/world/hawkins/hawkins_pearl_plain.tres"),
	"base_smooth": preload("res://game/resources/materials/world/hawkins/hawkins_base_smooth.tres"),
	"frame_grey": preload("res://game/resources/materials/world/hawkins/hawkins_frame_grey.tres"),
	"base_ribbed": preload("res://game/resources/materials/world/hawkins/hawkins_base_ribbed.tres"),
	"frame_charcoal": preload("res://game/resources/materials/world/hawkins/hawkins_frame_charcoal.tres"),
	"panel_grey": preload("res://game/resources/materials/world/hawkins/hawkins_base_smooth.tres"),
	"spandrel_pale": preload("res://game/resources/materials/world/hawkins/hawkins_spandrel_pale.tres"),
	"garage_dark": preload("res://game/resources/materials/world/hawkins/hawkins_garage_dark.tres"),
	"sign_letters": preload("res://game/resources/materials/world/hawkins/hawkins_sign_letters.tres"),
}
# SE ground under the 4-storey wing (recessed 1.3 m; cav-2, cav-7, hk01, hk02): corner
# storefront, slatted louvre screen, lobby storefront with the "77" doors and the
# HAWKINS fascia.
const SE_CORNER_STORE := [0.0, 13.0]
const SE_LOUVRE := [13.0, 21.5]
const SE_LOBBY := [21.5, 31.4]
const SE_LOBBY_DOORS := [27.0, 28.6]
const SE_FASCIA_Y := [7.55, 8.474]
const SE_SIGN_U := 27.3
const SE_SLOT_DOOR := [32.6, 34.0]
const SE_PIER := [34.5, 38.0]
const SE_PIER_DOOR := [35.5, 36.8]
const STORE_PITCH_M := 1.6
# Stage B rework: window families that use the per-floor light grammar (opaque lower
# field, lower light, thick transom, upper light; hk02, hk05, cav-2, cav-4, hk07, hk15).
# Validated on the SE box groups first, then propagated.
const GRAMMAR_GROUP_SIDES := ["se", "wsw", "nnw"]
const GRAMMAR_WINDOW_SIDES := ["se", "ene", "nnw", "wsw"]
const LIGHT_FRAME_W := 0.1
const LOWER_FIELD_M := 0.45
const TRANSOM_AT_M := 1.15
# SE stair slot (cav-7 rectified): landing bands, a deep band and the glazed top.
const SE_SLOT_BANDS := [[8.5, 8.8], [11.3, 11.6], [14.1, 14.4], [16.95, 17.25], [19.85, 20.15], [22.6, 23.5]]

var _boxes_by_material: Dictionary = {}


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
	var stacks := {}
	for o: Dictionary in MASSING.openings():
		match str(o.kind):
			"win", "corner":
				_window(o)
				var key := "%s|%.2f|%.2f|%.2f" % [o.side, o.out, o.u0, o.u1]
				if float(o.y0) > MASSING.DECK_Y and float(o.y1) < MASSING.TALL_TOP_Y and str(o.side) != "wsw":
					if not stacks.has(key):
						stacks[key] = []
					(stacks[key] as Array).append(o)
			"group":
				_group(o)
			"store":
				_storefront(str(o.side), float(o.out) - MASSING.REVEAL_M, float(o.u0), float(o.u1), float(o.y0), float(o.y1), [])
			"door":
				_door(str(o.side), float(o.out) - MASSING.REVEAL_M, float(o.u0), float(o.u1), float(o.y0), float(o.y1))
			"door_side":
				# Entry door with a full-height sidelight (hk23, cav-3).
				var plane := float(o.out) - MASSING.REVEAL_M
				var split := float(o.u0) + 1.1
				_door(str(o.side), plane, float(o.u0), split, float(o.y0), float(o.y1))
				_frame_ring_w(str(o.side), plane, split, float(o.u1), float(o.y0), float(o.y1), "frame_charcoal", 0.1)
			"garage":
				_garage(o)
	for key: String in stacks:
		_stack(stacks[key])
	var outer_count := 0
	for quad: Dictionary in wall_geometry.quads:
		if str(quad.role) == "outer":
			outer_count += 1
		_glazed_plane(quad, _quad_info(quad))
	for side: String in MASSING.BAY_BOX_U_RANGES:
		var r: Vector2 = MASSING.bay_box_range(side)
		var d: float = MASSING.BAY_BOX_DEPTH_M
		# Ribbed white fascia bands along the top and bottom of the box (cav-2).
		_add_box("pearl_plain", side, d, (r.x + r.y) * 0.5, MASSING.DECK_Y + 0.17, r.y - r.x, 0.34, 0.0, 0.05)
		_add_box("pearl_plain", side, d, (r.x + r.y) * 0.5, MASSING.TERRACE_Y - 0.17, r.y - r.x, 0.34, 0.0, 0.05)
	_se_ground()
	_flush()
	set_meta("outer_wall_quads", outer_count)
	return {"ok": true, "outer_wall_quads": outer_count}


# Side, plane offset and u range of a wall quad ("" side when it faces no footprint side).
func _quad_info(quad: Dictionary) -> Dictionary:
	var normal := quad.normal as Vector3
	var a := quad.start_bottom as Vector3
	var b := quad.end_bottom as Vector3
	for side: String in MASSING.SIDES:
		var f := MASSING.side_frame(side)
		if Vector2(normal.x, normal.z).dot(f.normal) < 0.999:
			continue
		var start := f.start as Vector2
		var ua := (Vector2(a.x, a.z) - start).dot(f.tangent)
		var ub := (Vector2(b.x, b.z) - start).dot(f.tangent)
		return {"side": side, "out": (Vector2(a.x, a.z) - start).dot(f.normal), "u0": minf(ua, ub), "u1": maxf(ua, ub),
			"bottom": maxf(a.y, b.y), "top": (quad.start_top as Vector3).y}
	return {"side": ""}


# A punched window: grey frame ring at the pane, a low transom and mullions (two
# panes over 1.6 m; corner glazing every ~1.15 m), dark spandrels across joined floors,
# and a projecting white sill.
func _window(o: Dictionary) -> void:
	var side := str(o.side)
	var plane := float(o.out) - MASSING.REVEAL_M
	var u0 := float(o.u0)
	var u1 := float(o.u1)
	var y0 := float(o.y0)
	var y1 := float(o.y1)
	if side in GRAMMAR_WINDOW_SIDES and y0 > MASSING.DECK_Y:
		_grammar_window(o)
		return
	_frame_ring(side, plane, u0, u1, y0, y1, "frame_grey")
	var width := u1 - u0
	var panes := maxi(1, int(round(width / 1.15))) if str(o.kind) == "corner" else (2 if width > 1.6 else 1)
	for k in range(1, panes):
		_add_box("frame_grey", side, plane, u0 + width * float(k) / float(panes), (y0 + y1) * 0.5, 0.06, y1 - y0, 0.0, 0.04)
	var sills := [y0]
	for band: Array in o.spandrels:
		_add_box("frame_charcoal", side, plane, (u0 + u1) * 0.5, (float(band[0]) + float(band[1])) * 0.5, width, float(band[1]) - float(band[0]), 0.0, 0.03)
		sills.append(float(band[1]))
	for s: float in sills:
		_add_box("frame_grey", side, plane, (u0 + u1) * 0.5, s + 0.7, width, 0.05, 0.0, 0.04)
	if y0 > MASSING.DECK_Y:
		_add_box("pearl_plain", side, float(o.out), (u0 + u1) * 0.5, y0 - 0.06, width + 0.2, 0.12, 0.0, 0.1)


# Per-floor light grammar inside one opening: a framed ring, and per floor an opaque
# grey lower field, a short lower light, a thick transom and the main upper light, with
# a centre mullion on wide lights (corner glazing every ~1.15 m); joined floors are
# separated by a broad grey opaque field framed top and bottom (hk15).
func _grammar_window(o: Dictionary) -> void:
	var side := str(o.side)
	var plane := float(o.out) - MASSING.REVEAL_M
	var u0 := float(o.u0)
	var u1 := float(o.u1)
	var floors := [[float(o.y0), float(o.y1)]]
	if not (o.spandrels as Array).is_empty():
		floors = []
		var bottom := float(o.y0)
		for band: Array in o.spandrels:
			floors.append([bottom, float(band[0])])
			_add_box("panel_grey", side, plane, (u0 + u1) * 0.5, (float(band[0]) + float(band[1])) * 0.5, u1 - u0, float(band[1]) - float(band[0]), 0.0, 0.04)
			bottom = float(band[1])
		floors.append([bottom, float(o.y1)])
	var width := u1 - u0
	var divisions := maxi(1, int(round(width / 1.15))) if str(o.kind) == "corner" else (2 if width > 1.6 else 1)
	for f: Array in floors:
		_lights(side, plane, u0, u1, float(f[0]), float(f[1]), divisions)
	if float(o.y0) > MASSING.DECK_Y:
		_add_box("pearl_plain", side, float(o.out), (u0 + u1) * 0.5, float(o.y0) - 0.06, width + 0.2, 0.12, 0.0, 0.1)


func _lights(side: String, plane: float, u0: float, u1: float, s: float, h: float, divisions: int) -> void:
	var w := LIGHT_FRAME_W
	_frame_ring_w(side, plane, u0, u1, s, h, "frame_grey", w)
	_add_box("panel_grey", side, plane, (u0 + u1) * 0.5, s + LOWER_FIELD_M * 0.5, u1 - u0 - w, LOWER_FIELD_M, 0.0, 0.035)
	_add_box("frame_grey", side, plane, (u0 + u1) * 0.5, s + LOWER_FIELD_M, u1 - u0, 0.07, 0.0, 0.045)
	_add_box("frame_grey", side, plane, (u0 + u1) * 0.5, s + TRANSOM_AT_M, u1 - u0, 0.12, 0.0, 0.045)
	for k in range(1, divisions):
		_add_box("frame_grey", side, plane, u0 + (u1 - u0) * float(k) / float(divisions), (s + h) * 0.5, 0.08, h - s, 0.0, 0.045)


func _frame_ring_w(side: String, plane: float, u0: float, u1: float, y0: float, y1: float, material: String, w: float) -> void:
	_add_box(material, side, plane, u0 + w * 0.5, (y0 + y1) * 0.5, w, y1 - y0, 0.0, 0.045)
	_add_box(material, side, plane, u1 - w * 0.5, (y0 + y1) * 0.5, w, y1 - y0, 0.0, 0.045)
	_add_box(material, side, plane, (u0 + u1) * 0.5, y0 + w * 0.5, u1 - u0, w, 0.0, 0.045)
	_add_box(material, side, plane, (u0 + u1) * 0.5, y1 - w * 0.5, u1 - u0, w, 0.0, 0.045)


# White surround on a tall-block window column: jambs over the whole stack and white
# panels between the floors, so each column reads as one glazed stack (cav-7, cav-4).
func _stack(column: Array) -> void:
	column.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.y0) < float(b.y0))
	var first: Dictionary = column[0]
	var last: Dictionary = column[-1]
	var side := str(first.side)
	var out := float(first.out)
	var u0 := float(first.u0)
	var u1 := float(first.u1)
	var bottom := float(first.y0) - 0.12
	var top := float(last.y1) + 0.08
	for u: float in [u0 - 0.15, u1 + 0.15]:
		_add_box("pearl_plain", side, out, u, (bottom + top) * 0.5, 0.3, top - bottom, 0.0, 0.05)
	for k in column.size() - 1:
		var lo := float((column[k] as Dictionary).y1)
		var hi := float((column[k + 1] as Dictionary).y0) - 0.12
		if hi > lo + 0.05:
			_add_box("pearl_plain", side, out, (u0 + u1) * 0.5, (lo + hi) * 0.5, u1 - u0, hi - lo, 0.0, 0.04)
	_add_box("pearl_plain", side, out, (u0 + u1) * 0.5, top - 0.04, u1 - u0 + 0.6, 0.08, 0.0, 0.05)


# Two-storey group on a projecting box (cav-2, cav-7): white surround, a white floor
# band at L3, a white divider between the narrow and the wide light, and per floor a
# grey centre mullion and low transom in the wide light.
func _group(o: Dictionary) -> void:
	var side := str(o.side)
	var front := float(o.out)
	var plane := front - MASSING.REVEAL_M
	var u0 := float(o.u0)
	var u1 := float(o.u1)
	var y0 := float(o.y0)
	var y1 := float(o.y1)
	var sw := 0.22
	_add_box("pearl_plain", side, front, u0 - sw * 0.5, (y0 + y1) * 0.5, sw, y1 - y0 + sw * 2.0, 0.0, 0.06)
	_add_box("pearl_plain", side, front, u1 + sw * 0.5, (y0 + y1) * 0.5, sw, y1 - y0 + sw * 2.0, 0.0, 0.06)
	_add_box("pearl_plain", side, front, (u0 + u1) * 0.5, y0 - sw * 0.5, u1 - u0, sw, 0.0, 0.06)
	_add_box("pearl_plain", side, front, (u0 + u1) * 0.5, y1 + sw * 0.5, u1 - u0, sw, 0.0, 0.06)
	var band: Array = o.spandrels[0]
	_add_box("pearl_plain", side, plane, (u0 + u1) * 0.5, (float(band[0]) + float(band[1])) * 0.5, u1 - u0, float(band[1]) - float(band[0]), 0.0, 0.08)
	var narrow := minf(0.85, (u1 - u0) * 0.35)
	var divider := u0 + narrow
	_add_box("pearl_plain", side, plane, divider, (y0 + y1) * 0.5, 0.14, y1 - y0, 0.0, 0.08)
	if side in GRAMMAR_GROUP_SIDES:
		# Per floor: the narrow light and the wide light (centre mullion) each with
		# the opaque lower field, lower light, transom and upper light (cav-2, hk02).
		for floor: Array in [[y0, float(band[0])], [float(band[1]), y1]]:
			_lights(side, plane, u0, divider - 0.07, float(floor[0]), float(floor[1]), 1)
			_lights(side, plane, divider + 0.07, u1, float(floor[0]), float(floor[1]), 2)
		return
	_frame_ring(side, plane, u0, u1, y0, y1, "frame_grey")
	var wide_mid := (divider + u1) * 0.5
	for floor: Array in [[y0, float(band[0])], [float(band[1]), y1]]:
		_add_box("frame_grey", side, plane, wide_mid, (float(floor[0]) + float(floor[1])) * 0.5, 0.06, float(floor[1]) - float(floor[0]), 0.0, 0.04)
		_add_box("frame_grey", side, plane, (divider + u1) * 0.5, float(floor[0]) + 0.55, u1 - divider, 0.06, 0.0, 0.04)
		_frame_ring(side, plane, u0, divider, float(floor[0]), float(floor[1]), "frame_grey")


func _frame_ring(side: String, plane: float, u0: float, u1: float, y0: float, y1: float, material: String) -> void:
	_add_box(material, side, plane, u0 + FRAME_W * 0.5, (y0 + y1) * 0.5, FRAME_W, y1 - y0, 0.0, 0.04)
	_add_box(material, side, plane, u1 - FRAME_W * 0.5, (y0 + y1) * 0.5, FRAME_W, y1 - y0, 0.0, 0.04)
	_add_box(material, side, plane, (u0 + u1) * 0.5, y0 + FRAME_W * 0.5, u1 - u0, FRAME_W, 0.0, 0.04)
	_add_box(material, side, plane, (u0 + u1) * 0.5, y1 - FRAME_W * 0.5, u1 - u0, FRAME_W, 0.0, 0.04)


# Storefront grid: mullions on a shared absolute u grid, head and sill members and a
# transom, with door openings left clear of the grid.
func _storefront(side: String, plane: float, u0: float, u1: float, y0: float, y1: float, doors: Array, transom_y := -1.0) -> void:
	if u1 - u0 < 0.3 or y1 - y0 < 0.3:
		return
	_frame_ring_w(side, plane, u0, u1, y0, y1, "frame_grey", 0.12)
	var k := ceili(u0 / STORE_PITCH_M)
	while float(k) * STORE_PITCH_M < u1 - 0.15:
		var u := float(k) * STORE_PITCH_M
		var clear := u > u0 + 0.15
		for d: Array in doors:
			if u > float(d[0]) - 0.1 and u < float(d[1]) + 0.1:
				clear = false
		if clear:
			_add_box("frame_grey", side, plane, u, (y0 + y1) * 0.5, 0.1, y1 - y0, 0.0, 0.045)
		k += 1
	var t := transom_y if transom_y > 0.0 else y1 - 0.55
	if t < y1 - 0.2 and t > y0 + 0.2:
		_add_box("frame_grey", side, plane, (u0 + u1) * 0.5, t, u1 - u0, 0.1, 0.0, 0.045)
	for d: Array in doors:
		_door(side, plane, float(d[0]), float(d[1]), y0, minf(y0 + 2.6, t - 0.05))


# Door: heavy charcoal frame proud of the glazing, leaves with broad stiles and a
# kick rail, pull bars, and a transom bar over the leaves (hk22).
func _door(side: String, plane: float, u0: float, u1: float, y0: float, y1: float) -> void:
	_frame_ring_w(side, plane, u0, u1, y0, y1, "frame_charcoal", 0.14)
	var width := u1 - u0
	var leaves := 2 if width > 1.3 else 1
	for k in leaves:
		var a := u0 + width * float(k) / float(leaves)
		var b := u0 + width * float(k + 1) / float(leaves)
		_frame_ring_w(side, plane + 0.02, a + 0.07, b - 0.07, y0 + 0.07, y1 - 0.07, "frame_charcoal", 0.1)
		_add_box("frame_charcoal", side, plane + 0.02, (a + b) * 0.5, y0 + 0.2, b - a - 0.14, 0.3, 0.0, 0.05)
		var pull := b - 0.25 if k == 0 and leaves == 2 else a + 0.25
		_add_box("spandrel_pale", side, plane + 0.05, pull, y0 + 1.05, 0.04, 0.9, 0.0, 0.06)


func _garage(o: Dictionary) -> void:
	var side := str(o.side)
	var plane := float(o.out) - MASSING.REVEAL_M
	var u0 := float(o.u0)
	var u1 := float(o.u1)
	var y0 := float(o.y0)
	var y1 := float(o.y1)
	_frame_ring(side, plane, u0, u1, y0, y1, "frame_charcoal")
	var y := y0 + 0.2
	while y < y1 - 0.1:
		_add_box("frame_grey", side, plane, (u0 + u1) * 0.5, y, u1 - u0 - 0.12, 0.05, 0.0, 0.03)
		y += 0.16


# Grids on the glazed planes behind the footprint line: the SE stair slot (landing
# bands), the NNW strip and ENE slot (floor-aligned spandrels), the ENE middle ground
# and loggia, and the set-back storey of the 4-storey wing.
func _glazed_plane(quad: Dictionary, info: Dictionary) -> void:
	var side := str(info.get("side", ""))
	if side == "":
		return
	var out := float(info.out)
	var u0 := float(info.u0)
	var u1 := float(info.u1)
	var bottom := float(info.bottom)
	var top := float(info.top)
	var role := str(quad.role)
	var glass := role == "setback"
	for o: float in MASSING.GLASS_NOTCH_OUTS.get(side, []):
		if absf(out - o) < 0.05:
			glass = true
	if not glass or u1 - u0 < 0.3:
		return
	if role == "setback":
		# Set-back storey: mullions about 1.5 m apart and a rail-height transom.
		_curtain(side, out, u0, u1, maxf(bottom, MASSING.TERRACE_Y), top, 1.5, [])
		_add_box("frame_charcoal", side, out, (u0 + u1) * 0.5, MASSING.TERRACE_Y + 1.05, u1 - u0, 0.06, 0.0, 0.05)
		_terrace_rail(side, u0, u1)
		return
	# Ground band: storefront grid (opaque recessed grounds carry punched openings).
	if bottom < MASSING.DECK_Y and not MASSING.is_base_ground(side, out):
		var doors := []
		for stoop: Array in MASSING.STOOPS:
			var su := float(stoop[1])
			if str(stoop[0]) == side and su > u0 + 0.6 and su < u1 - 0.6:
				doors.append([su - 0.6, su + 0.6])
		_storefront(side, out, u0, u1, bottom, MASSING.DECK_Y - 0.05, doors, 7.3)
		if side == "se":
			_door(side, out, SE_SLOT_DOOR[0], SE_SLOT_DOOR[1], bottom, bottom + 2.6)
	var g0 := maxf(bottom, MASSING.DECK_Y)
	if top <= g0 + 0.3:
		return
	var floors := []
	if side == "se":
		floors = SE_SLOT_BANDS
	else:
		for f: float in MASSING.FLOORS:
			floors.append([f - 0.35, f + 0.1])
	_curtain(side, out, u0, u1, g0, top, 1.1, floors)


func _curtain(side: String, out: float, u0: float, u1: float, y0: float, y1: float, pitch: float, bands: Array) -> void:
	var count := maxi(1, int(round((u1 - u0) / pitch)))
	for k in count + 1:
		var u := lerpf(u0 + 0.04, u1 - 0.04, float(k) / float(count))
		_add_box("frame_grey", side, out, u, (y0 + y1) * 0.5, 0.08, y1 - y0, 0.0, 0.05)
	for y: float in [y0 + 0.04, y1 - 0.04]:
		_add_box("frame_grey", side, out, (u0 + u1) * 0.5, y, u1 - u0, 0.08, 0.0, 0.05)
	for band: Array in bands:
		var b0 := maxf(float(band[0]), y0)
		var b1 := minf(float(band[1]), y1)
		if b1 > b0 + 0.05:
			var material := "pearl_plain" if side == "se" else "frame_charcoal"
			_add_box(material, side, out, (u0 + u1) * 0.5, (b0 + b1) * 0.5, u1 - u0, b1 - b0, 0.0, 0.06)


# Glass guardrail on the terrace edge, just inside the parapet line.
func _terrace_rail(side: String, u0: float, u1: float) -> void:
	var width := u1 - u0 - 0.1
	if width <= 0.2 or not MASSING.SETBACK_U_RANGES.has(side):
		return
	var center := (u0 + u1) * 0.5
	_add_box("frame_charcoal", side, -0.15, center, MASSING.TERRACE_Y + 0.92, width, 0.05, -0.04, 0.02)
	_add_box("frame_charcoal", side, -0.15, center, MASSING.TERRACE_Y + 0.05, width, 0.1, -0.04, 0.02)


# SE base under the wing (recess plane), the ribbed pier and its service door.
func _se_ground() -> void:
	var plane := -MASSING.RECESS_M
	var y0 := 4.3
	var store_top: float = SE_FASCIA_Y[0]
	_storefront("se", plane, SE_CORNER_STORE[0] + 0.3, SE_CORNER_STORE[1], y0, store_top, [], 7.0)
	_storefront("se", plane, SE_LOBBY[0], SE_LOBBY[1], y0, store_top, [SE_LOBBY_DOORS], 6.95)
	# Fascia over the storefronts with the HAWKINS letters (cav-7, hk02, hk24).
	var fascia_mid := (float(SE_FASCIA_Y[0]) + float(SE_FASCIA_Y[1])) * 0.5
	var fascia_h := float(SE_FASCIA_Y[1]) - float(SE_FASCIA_Y[0])
	# The fascia hangs at the box front line under its soffit, letters on its face.
	_add_box("base_ribbed", "se", -0.12, (float(SE_CORNER_STORE[0]) + float(SE_LOBBY[1])) * 0.5 + 0.15, fascia_mid, float(SE_LOBBY[1]) - float(SE_CORNER_STORE[0]) - 0.3, fascia_h, 0.0, 0.1)
	_add_sign_letters(SE_SIGN_U, 8.0, 4.6, 0.6, 0.0)
	# Louvre screen: an opaque panel behind light vertical slats (cav-7, hk01).
	_add_box("frame_charcoal", "se", plane, (float(SE_LOUVRE[0]) + float(SE_LOUVRE[1])) * 0.5, (y0 + store_top) * 0.5, float(SE_LOUVRE[1]) - float(SE_LOUVRE[0]), store_top - y0, 0.0, 0.03)
	var u: float = float(SE_LOUVRE[0]) + 0.1
	while u < float(SE_LOUVRE[1]) - 0.05:
		_add_box("spandrel_pale", "se", plane, u, (y0 + store_top) * 0.5, 0.07, store_top - y0, 0.03, 0.11)
		u += 0.2
	# Ribbed silver pier base with a service door.
	_add_box("base_ribbed", "se", 0.0, (float(SE_PIER[0]) + float(SE_PIER[1])) * 0.5, (y0 + MASSING.DECK_Y) * 0.5, float(SE_PIER[1]) - float(SE_PIER[0]), MASSING.DECK_Y - y0, 0.0, 0.03)
	var r: float = float(SE_PIER[0]) + 0.1
	while r < float(SE_PIER[1]) - 0.05:
		_add_box("spandrel_pale", "se", 0.0, r, (y0 + MASSING.DECK_Y) * 0.5, 0.05, MASSING.DECK_Y - y0 - 0.1, 0.03, 0.07)
		r += 0.15
	_add_box("garage_dark", "se", 0.0, (float(SE_PIER_DOOR[0]) + float(SE_PIER_DOOR[1])) * 0.5, y0 + 1.25, float(SE_PIER_DOOR[1]) - float(SE_PIER_DOOR[0]), 2.5, 0.07, 0.09)
	_frame_ring("se", 0.07, SE_PIER_DOOR[0], SE_PIER_DOOR[1], y0, y0 + 2.5, "frame_charcoal")


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
	var letter_width := minf(0.5, fascia_width / 9.5)
	var letter_height := minf(0.6, fascia_height * 0.85)
	var gap := letter_width * 0.3
	var total := float(text.length()) * letter_width + float(text.length() - 1) * gap
	var stroke := minf(0.06, letter_width * 0.16)
	var f := MASSING.side_frame("se")
	var t := Vector3((f.tangent as Vector2).x, 0.0, (f.tangent as Vector2).y)
	var n := Vector3((f.normal as Vector2).x, 0.0, (f.normal as Vector2).y)
	var start := f.start as Vector2
	for i in text.length():
		var left := center_u - total * 0.5 + float(i) * (letter_width + gap)
		for segment: Array in glyphs[text.substr(i, 1)]:
			var from := Vector2(left + float(segment[0]) * letter_width, center_y - letter_height * 0.5 + float(segment[1]) * letter_height)
			var to := Vector2(left + float(segment[2]) * letter_width, center_y - letter_height * 0.5 + float(segment[3]) * letter_height)
			var delta := to - from
			if delta.length() < 0.0001:
				continue
			var direction := (t * delta.x + Vector3.UP * delta.y).normalized()
			var across := (t * -delta.y + Vector3.UP * delta.x).normalized()
			var mid := (from + to) * 0.5
			var origin := Vector3(start.x, mid.y, start.y) + t * mid.x + n * (plane + 0.03)
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
