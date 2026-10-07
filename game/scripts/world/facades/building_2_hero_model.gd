class_name Building2HeroModel
extends RefCounted
## Building 2 / Hall of Transportation (OSM w24274434, NRHP 08000082) whole-building study.
##
## Replaces the generated 20 m slab for the exact wall and roof records. Every source
## wall run keeps its frozen horizontal points and exact bottom elevations; height,
## arch, pylons, facade depth and the SSE wing are reversible production inference
## from dated exterior references (WSW Street View May 2019, SSE visitor panorama
## April 2017). NNW/ENE schedules are unobserved and deliberately understated. No
## interior, relief artwork or hidden detail is modeled.
##
## Visible faces and collision faces come from the same emitted triangles. Wall-side
## geometry (walls, recesses, glazing grids, pylons) is one sprayable body; the barrel
## and wing roofs are one non-sprayable body. The generated wall record is the
## authority for the frame, pylon loops and roof outline.

const SOURCE_KEY := "w24274434"
const WALL_KEY := "building:w24274434:wall"
const ROOF_KEY := "building:w24274434:roof"
const TARGET_KEYS := [WALL_KEY, ROOF_KEY]
const CHUNK_PATH := "res://generated/world/chunks/x_1__z_2.json"
const MODEL_ID := "building-2-hall-of-transportation-first-coherent-study-2026-10-06"
const MAX_REQUIRED_RUN := 45
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1
const EPS := 0.0005

# Vertical production inference, absolute metres. Generated base/top are 3.56/23.56.
const BASE_Y := 3.56
const EAVE_Y := 21.36
const CROWN_Y := 28.16
const WING_TOP_Y := EAVE_Y
const PYLON_SHAFT_TOP_Y := 24.3
const PYLON_CROWN_TOP_Y := 25.7
const PYLON_CAP_Y := 26.3
const PYLON_SETBACK_M := 0.3
const PYLON_ENE_SSE_DEPTH_M := 5.8
const ARCH_STEP_M := 2.0
const BARREL_STRIPS := 36

# Source run roles (exact indices of the 46-run wall receiver).
const WSW_MAIN_RUNS := [3, 4, 5, 6, 7, 8]
const ENE_MAIN_RUNS := [27, 28, 29, 30, 31, 32]
const NNW_RUNS := [38, 39, 40, 41, 42, 43]
const WING_WSW_RUNS := [12, 13, 14, 15]
const WING_SSE_RUNS := [16, 17, 18, 19, 20, 21]
const WING_ENE_RUNS := [22]
const WING_RETURN_RUNS := [23]

const WALL_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres")
const TRIM_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_light_trim.tres")
const DARK_GLASS_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres")
const DOOR_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_blue_door.tres")
const SHADOW_MATERIAL := preload("res://game/resources/materials/world/building_3/building_3_shadow_recess.tres")


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in TARGET_KEYS


static func build_record(record: Dictionary) -> Dictionary:
	if not _record_valid(record):
		return _failure("building_2_hero_source_contract", "Building 2 source identity or geometry does not match.", record)
	var wall := record if str(record.object_key) == WALL_KEY else _record_from_chunk(CHUNK_PATH, WALL_KEY)
	if not _record_valid(wall) or str(wall.object_key) != WALL_KEY:
		return _failure("building_2_hero_wall_source", "Building 2 wall source could not be resolved.", record)
	var frame := _frame(wall)
	if frame.is_empty():
		return _failure("building_2_hero_frame", "Building 2 wall runs no longer form the expected WSW frame.", record)
	if str(record.object_key) == WALL_KEY:
		return _build_wall(record, frame)
	return _build_roof(record, wall, frame)


# --- Wall record: every vertical surface, pylons and facade depth -------------------

static func _build_wall(wall: Dictionary, frame: Dictionary) -> Dictionary:
	var collision := _bucket()
	var t := {
		"cream": _target(collision), "glass": _target(collision), "glass_band": _target(collision),
		"grid": _target(collision), "panel": _target(collision), "relief": _target(collision),
		"door": _target(collision), "inset": _target(collision), "shadow": _target(collision),
		"wing_glass": _target(collision), "wing_frame": _target(collision),
	}
	var wsw_top := _arch_top(frame, frame.wsw_u0, frame.wsw_u1)
	var ene_top := _arch_top(frame, frame.ene_u0, frame.ene_u1)

	var counts := {}
	counts["wsw_fields"] = _emit_wsw_composition(t, wall, frame, wsw_top)
	_emit_face(t.cream, _arch_chain(wall, ENE_MAIN_RUNS, frame, frame.ene_u0, frame.ene_u1), ene_top, [], ARCH_STEP_M)
	counts["nnw_panels"] = _emit_nnw_long_side(t, wall)
	counts["sse_bays"] = _emit_wing_bays(t, wall, WING_SSE_RUNS, 20, [4, 13])
	counts["wing_wsw_bays"] = _emit_wing_bays(t, wall, WING_WSW_RUNS, 2, [])
	counts["wing_ene_bays"] = _emit_wing_bays(t, wall, WING_ENE_RUNS, 2, [])
	_emit_face(t.cream, _chain_from_runs(wall, WING_RETURN_RUNS), _const_top(WING_TOP_Y), [], 0.0)
	_emit_face(t.cream, [_segment(frame.interface_wsw, frame.interface_ene, WING_TOP_Y, WING_TOP_Y, frame.t)], _const_top(EAVE_Y), [], 0.0)
	var pylons := _pylon_specs(wall, frame)
	if pylons.is_empty():
		return _failure("building_2_hero_pylon_loops", "Building 2 pylon footprint loops did not close on exact source points.", wall)
	for spec: Dictionary in pylons:
		_emit_pylon(t, wall, frame, spec)

	var materials := _materials()
	var root := _hero_root("Building2HeroWall", wall, "building_wall")
	var specs: Array[Dictionary] = [
		{"name": "Building2Cream", "target": t.cream, "material": WALL_MATERIAL},
		{"name": "Building2FieldGlass", "target": t.glass, "material": materials.field_glass},
		{"name": "Building2FieldGlassBand", "target": t.glass_band, "material": materials.field_band},
		{"name": "Building2FieldGrid", "target": t.grid, "material": materials.field_grid},
		{"name": "Building2EntryPanel", "target": t.panel, "material": materials.entry_panel},
		{"name": "Building2ReliefProxy", "target": t.relief, "material": TRIM_MATERIAL},
		{"name": "Building2Doors", "target": t.door, "material": DOOR_MATERIAL},
		{"name": "Building2PylonInsets", "target": t.inset, "material": materials.pylon_inset},
		{"name": "Building2Vents", "target": t.shadow, "material": SHADOW_MATERIAL},
		{"name": "Building2WingGlass", "target": t.wing_glass, "material": DARK_GLASS_MATERIAL},
		{"name": "Building2WingMullions", "target": t.wing_frame, "material": TRIM_MATERIAL},
	]
	var metadata := _common_metadata(wall, "building_wall")
	metadata.merge({
		"wsw_glazed_fields": int(counts.wsw_fields),
		"wsw_central_entry_doors": 3,
		"relief_proxy_nonliteral": true,
		"relief_artwork_reproduced": false,
		"pylon_count": pylons.size(),
		"sse_wing_bays": int(counts.sse_bays),
		"sse_wing_service_doors": 2,
		"nnw_shallow_panels_without_openings": int(counts.nnw_panels),
		"ene_end_schedule": "unobserved_plain",
		"nnw_side_schedule": "unobserved_understated",
		"exact_source_wall_runs": int((wall.vertices as Array).size() / 12.0),
	}, true)
	return _finish(root, specs, collision, RENDER_BUILDING_WALL, true, metadata)


## WSW monumental end: twin gridded glazing fields, central blue-grey recessed entry
## with three dark doors and a nonliteral relief proxy, subordinate square vents.
static func _emit_wsw_composition(t: Dictionary, wall: Dictionary, frame: Dictionary, top: Callable) -> int:
	var chain := _arch_chain(wall, WSW_MAIN_RUNS, frame, frame.wsw_u0, frame.wsw_u1)
	var length := _chain_length(chain)
	var margin := 1.3
	var pier := 2.3
	var panel_width := 5.8
	var field_width := (length - 2.0 * margin - 2.0 * pier - panel_width) / 2.0
	var field_y0 := BASE_Y + 0.6
	var field_y1 := BASE_Y + 12.0
	var field_depth := 0.9
	var left_s0 := margin
	var panel_s0 := margin + field_width + pier
	var right_s0 := panel_s0 + panel_width + pier
	var panel_mid := panel_s0 + panel_width * 0.5
	var panel_depth := 1.25

	var door_width := 1.1
	var door_gap := 0.22
	var doors: Array = []
	var door_group := 3.0 * door_width + 2.0 * door_gap
	for k in 3:
		var s0 := panel_mid - door_group * 0.5 + float(k) * (door_width + door_gap)
		doors.append(_opening(s0, s0 + door_width, 0.0, BASE_Y + 2.75, 0.18, t.panel, {"kind": "flat", "target": t.door}, true))
	var openings: Array = [
		_opening(left_s0, left_s0 + field_width, field_y0, field_y1, field_depth, t.cream, {"kind": "flat", "target": t.glass}),
		_opening(right_s0, right_s0 + field_width, field_y0, field_y1, field_depth, t.cream, {"kind": "flat", "target": t.glass}),
		_opening(panel_s0, panel_s0 + panel_width, 0.0, field_y1, panel_depth, t.cream, {"kind": "face", "target": t.panel, "openings": doors}, true),
	]
	# Small square vents observed above the centre and the SSE field.
	for vent_u: float in [36.5, 56.0]:
		var vent_s := vent_u - _run_u(wall, 3)
		openings.append(_opening(vent_s - 0.4, vent_s + 0.4, BASE_Y + 16.2, BASE_Y + 17.0, 0.25, t.cream, {"kind": "flat", "target": t.shadow}))
	_emit_face(t.cream, chain, top, openings, ARCH_STEP_M)

	for s0: float in [left_s0, right_s0]:
		_emit_glazing_grid(t, chain, s0, s0 + field_width, field_y0, field_y1, field_depth)
	# Nonliteral relief proxy: stacked pale masses proud of the recessed blue panel.
	var relief_front := panel_depth - 0.28
	_chain_box(t.relief, chain, panel_mid - 0.55, panel_mid + 0.55, BASE_Y + 5.4, BASE_Y + 6.1, relief_front + 0.06, 0.22)
	_chain_box(t.relief, chain, panel_mid - 0.72, panel_mid + 0.72, BASE_Y + 6.1, BASE_Y + 9.2, relief_front, 0.28)
	_chain_box(t.relief, chain, panel_mid - 0.38, panel_mid + 0.38, BASE_Y + 9.2, BASE_Y + 10.1, relief_front + 0.03, 0.25)
	# Dark lintel band tying the three doors together.
	_chain_box(t.door, chain, panel_mid - door_group * 0.5 - 0.15, panel_mid + door_group * 0.5 + 0.15, BASE_Y + 2.75, BASE_Y + 3.05, panel_depth - 0.05, 0.05)
	return 2


static func _emit_glazing_grid(t: Dictionary, chain: Array, s0: float, s1: float, y0: float, y1: float, depth: float) -> void:
	var columns := 24
	var rows := 10
	var bar := 0.1
	var edge := 0.24
	var bar_depth := 0.08
	var row_height := (y1 - y0) / float(rows)
	# Dark pane band four rows below the head and a thin dark kick row, as observed.
	_chain_box(t.glass_band, chain, s0, s1, y1 - 5.0 * row_height, y1 - 4.0 * row_height, depth - 0.015, 0.012)
	_chain_box(t.glass_band, chain, s0, s1, y0, y0 + 0.45, depth - 0.015, 0.012)
	var column_width := (s1 - s0) / float(columns)
	for k in columns + 1:
		var width := edge if k == 0 or k == columns else bar
		var s := s0 + float(k) * column_width
		_chain_box(t.grid, chain, clampf(s - width * 0.5, s0, s1 - width), clampf(s + width * 0.5, s0 + width, s1), y0, y1, depth - bar_depth, bar_depth)
	for k in rows + 1:
		var height := edge if k == 0 or k == rows else bar
		var y := y0 + float(k) * row_height
		_chain_box(t.grid, chain, s0, s1, clampf(y - height * 0.5, y0, y1 - height), clampf(y + height * 0.5, y0 + height, y1), depth - bar_depth - 0.01, bar_depth)


## NNW is unobserved: keep a continuous finished wall on the exact source
## chain instead of unsupported shallow panels and their thin shadowed returns.
static func _emit_nnw_long_side(t: Dictionary, wall: Dictionary) -> int:
	_emit_face(t.cream, _chain_from_runs(wall, NNW_RUNS), _const_top(EAVE_Y), [], 0.0)
	return 0


## Two-tier ribbed wing: full-height piers on the frozen face line, bays recessed
## behind them with grouped lower and upper glazing; stepped pier crowns.
static func _emit_wing_bays(t: Dictionary, wall: Dictionary, runs: Array, bay_count: int, service_bays: Array) -> int:
	var chain := _chain_from_runs(wall, runs)
	var length := _chain_length(chain)
	var pier := 0.9
	var module := (length - pier) / float(bay_count)
	var bay := module - pier
	var bay_depth := 0.95
	var window_width := bay - 0.55
	var openings: Array = []
	for k in bay_count:
		var s0 := pier + float(k) * module
		var mid := s0 + bay * 0.5
		var inner: Array = []
		if k in service_bays:
			inner.append(_opening(mid - 1.55, mid + 1.55, 0.0, BASE_Y + 3.5, 0.12, t.cream, {"kind": "flat", "target": t.door}, true))
		else:
			inner.append(_opening(mid - window_width * 0.5, mid + window_width * 0.5, BASE_Y + 0.9, BASE_Y + 4.8, 0.18, t.cream, {"kind": "flat", "target": t.wing_glass}))
		inner.append(_opening(mid - window_width * 0.5, mid + window_width * 0.5, BASE_Y + 9.0, BASE_Y + 13.1, 0.18, t.cream, {"kind": "flat", "target": t.wing_glass}))
		openings.append(_opening(s0, s0 + bay, 0.0, 0.0, bay_depth, t.cream, {"kind": "face", "target": t.cream, "openings": inner}, true, true))
	_emit_face(t.cream, chain, _const_top(WING_TOP_Y), openings, 0.0)
	for k in bay_count:
		var mid := pier + float(k) * module + bay * 0.5
		var lower_y0 := BASE_Y + 0.9
		if k not in service_bays:
			_window_mullions(t, chain, mid, window_width, lower_y0, BASE_Y + 4.8, bay_depth + 0.18, 4, 2)
		_window_mullions(t, chain, mid, window_width, BASE_Y + 9.0, BASE_Y + 13.1, bay_depth + 0.18, 3, 3)
	for k in bay_count + 1:
		var s0 := float(k) * module
		_chain_box(t.cream, chain, s0, s0 + pier, WING_TOP_Y, WING_TOP_Y + 0.55, 0.0, 0.6)
	return bay_count


static func _window_mullions(t: Dictionary, chain: Array, mid: float, width: float, y0: float, y1: float, depth: float, columns: int, rows: int) -> void:
	var s0 := mid - width * 0.5
	var bar := 0.07
	for k in range(1, columns):
		var s := s0 + width * float(k) / float(columns)
		_chain_box(t.wing_frame, chain, s - bar * 0.5, s + bar * 0.5, y0, y1, depth - 0.05, 0.05)
	for k in range(1, rows):
		var y := y0 + (y1 - y0) * float(k) / float(rows)
		_chain_box(t.wing_frame, chain, s0, s0 + width, y - bar * 0.5, y + bar * 0.5, depth - 0.05, 0.05)


# --- Pylons --------------------------------------------------------------------------

## Footprint loops: run items start an exact source edge, end items add an exact run
## end point, ud items are inferred interior corners in the (u, d) frame.
static func _pylon_specs(wall: Dictionary, frame: Dictionary) -> Array:
	var c := _run_ud(wall, frame, 2, true)
	var f := _run_ud(wall, frame, 44, false)
	var g := _run_ud(wall, frame, 9, false)
	var j := _run_ud(wall, frame, 11, true)
	var q := _run_ud(wall, frame, 33, false)
	var r37 := _run_ud(wall, frame, 37, true)
	var s := _run_ud(wall, frame, 24, false)
	var r26 := _run_ud(wall, frame, 26, true)
	var back_d := s.y + PYLON_ENE_SSE_DEPTH_M
	var specs := [
		{"name": "wsw_nnw", "loop": [{"run": 45}, {"run": 0}, {"run": 1}, {"run": 2}, {"end": 2}, {"ud": Vector2(c.x, f.y)}, {"run": 44}], "front": [0, 1]},
		{"name": "wsw_sse", "loop": [{"run": 9}, {"run": 10}, {"run": 11}, {"end": 11}, {"ud": Vector2(g.x, j.y)}], "front": [10]},
		{"name": "ene_nnw", "loop": [{"run": 33}, {"run": 34}, {"run": 35}, {"run": 36}, {"run": 37}, {"end": 37}, {"ud": Vector2(q.x, r37.y)}], "front": [34, 35]},
		{"name": "ene_sse", "loop": [{"run": 24}, {"run": 25}, {"run": 26}, {"end": 26}, {"ud": Vector2(r26.x, back_d)}, {"ud": Vector2(s.x, back_d)}], "front": [24, 25]},
	]
	var resolved: Array = []
	for spec: Dictionary in specs:
		var vertices: Array = []
		for item: Dictionary in spec.loop:
			if item.has("run"):
				var run := _run(wall, int(item.run))
				vertices.append({"xz": run.a, "y": run.ya, "run": int(item.run)})
			elif item.has("end"):
				var run_end := _run(wall, int(item.end))
				vertices.append({"xz": run_end.b, "y": run_end.yb, "run": -1})
			else:
				vertices.append({"xz": _xz(frame, item.ud as Vector2), "y": BASE_Y, "run": -1})
		for k in vertices.size():
			var vertex := vertices[k] as Dictionary
			if int(vertex.run) >= 0:
				var next := vertices[(k + 1) % vertices.size()] as Dictionary
				if (_run(wall, int(vertex.run)).b as Vector2).distance_to(next.xz as Vector2) > 0.002:
					return []
		resolved.append({"name": spec.name, "vertices": vertices, "front": spec.front})
	return resolved


static func _emit_pylon(t: Dictionary, wall: Dictionary, frame: Dictionary, spec: Dictionary) -> void:
	var vertices := spec.vertices as Array
	var centroid := Vector2.ZERO
	for vertex: Dictionary in vertices:
		centroid += vertex.xz as Vector2
	centroid /= float(vertices.size())
	var shaft_top := _const_top(PYLON_SHAFT_TOP_Y)
	var front := spec.front as Array
	for k in vertices.size():
		var a := vertices[k] as Dictionary
		var b := vertices[(k + 1) % vertices.size()] as Dictionary
		if int(a.run) in front:
			continue
		var normal := _outward(a.xz as Vector2, b.xz as Vector2, centroid)
		if int(a.run) >= 0:
			normal = _run(wall, int(a.run)).normal as Vector2
		_emit_face(t.cream, [_segment(a.xz as Vector2, b.xz as Vector2, float(a.y), float(b.y), normal)], shaft_top, [], 0.0)
	var front_chain := _chain_from_runs(wall, front)
	var mid := _chain_length(front_chain) * 0.5
	var strip := _opening(mid - 0.62, mid + 0.62, BASE_Y + 2.2, PYLON_SHAFT_TOP_Y - 1.3, 0.22, t.cream, {"kind": "flat", "target": t.inset})
	_emit_face(t.cream, front_chain, shaft_top, [strip], 0.0)
	# Shaft ledge, set-back crown stage and low pyramidal cap.
	var first := _v3(vertices[0].xz as Vector2, PYLON_SHAFT_TOP_Y)
	for k in range(1, vertices.size() - 1):
		var second := _v3(vertices[k].xz as Vector2, PYLON_SHAFT_TOP_Y)
		var third := _v3(vertices[k + 1].xz as Vector2, PYLON_SHAFT_TOP_Y)
		# Collinear source points along one rectangle side give zero-area fan triangles.
		if (second - first).cross(third - first).length() > 0.0001:
			_triangle(t.cream, first, second, third, Vector3.UP)
	var u_min := INF
	var u_max := -INF
	var d_min := INF
	var d_max := -INF
	for vertex: Dictionary in vertices:
		var ud := _ud(frame, vertex.xz as Vector2)
		u_min = minf(u_min, ud.x)
		u_max = maxf(u_max, ud.x)
		d_min = minf(d_min, ud.y)
		d_max = maxf(d_max, ud.y)
	var inset := PYLON_SETBACK_M
	var corners := [
		_xz(frame, Vector2(u_min + inset, d_min + inset)), _xz(frame, Vector2(u_max - inset, d_min + inset)),
		_xz(frame, Vector2(u_max - inset, d_max - inset)), _xz(frame, Vector2(u_min + inset, d_max - inset)),
	]
	var center := _xz(frame, Vector2((u_min + u_max) * 0.5, (d_min + d_max) * 0.5))
	var apex := _v3(center, PYLON_CAP_Y)
	for k in 4:
		var a2 := corners[k] as Vector2
		var b2 := corners[(k + 1) % 4] as Vector2
		var normal := _outward(a2, b2, center)
		_emit_face(t.cream, [_segment(a2, b2, PYLON_SHAFT_TOP_Y, PYLON_SHAFT_TOP_Y, normal)], _const_top(PYLON_CROWN_TOP_Y), [], 0.0)
		var slope_normal := (_v3(b2, PYLON_CROWN_TOP_Y) - _v3(a2, PYLON_CROWN_TOP_Y)).cross(apex - _v3(a2, PYLON_CROWN_TOP_Y))
		if slope_normal.y < 0.0:
			slope_normal = -slope_normal
		_triangle(t.cream, _v3(a2, PYLON_CROWN_TOP_Y), _v3(b2, PYLON_CROWN_TOP_Y), apex, slope_normal)


# --- Roof record: segmental barrel and flat wing roof -------------------------------

static func _build_roof(roof: Dictionary, wall: Dictionary, frame: Dictionary) -> Dictionary:
	var collision := _bucket()
	var barrel := _target(collision)
	var wing := _target(collision)
	for k in BARREL_STRIPS:
		var a0 := float(k) / float(BARREL_STRIPS)
		var a1 := float(k + 1) / float(BARREL_STRIPS)
		var w0 := _v3((frame.barrel_w0 as Vector2).lerp(frame.barrel_w1 as Vector2, a0), _arch_y(a0, frame.barrel_span))
		var w1 := _v3((frame.barrel_w0 as Vector2).lerp(frame.barrel_w1 as Vector2, a1), _arch_y(a1, frame.barrel_span))
		var e0 := _v3((frame.barrel_e0 as Vector2).lerp(frame.barrel_e1 as Vector2, a0), _arch_y(a0, frame.barrel_span))
		var e1 := _v3((frame.barrel_e0 as Vector2).lerp(frame.barrel_e1 as Vector2, a1), _arch_y(a1, frame.barrel_span))
		var normal := (w1 - w0).cross(e0 - w0)
		if normal.y < 0.0:
			normal = -normal
		_quad(barrel, w0, w1, e1, e0, normal)
	var r16 := _run(wall, 16)
	var r21 := _run(wall, 21)
	var r22 := _run(wall, 22)
	var sse_back := _line_point_at_d(frame, r16.a as Vector2, r21.b as Vector2, frame.pylon_back_d)
	var wing_quads := [
		[frame.interface_wsw, r16.a, sse_back, frame.interface_ene],
		[frame.pylon_back_sse, sse_back, r21.b, r22.b],
	]
	for corners: Array in wing_quads:
		_quad(wing, _v3(corners[0], WING_TOP_Y), _v3(corners[1], WING_TOP_Y), _v3(corners[2], WING_TOP_Y), _v3(corners[3], WING_TOP_Y), Vector3.UP)
	var materials := _materials()
	var root := _hero_root("Building2HeroRoof", roof, "building_roof")
	var specs: Array[Dictionary] = [
		{"name": "Building2BarrelRoof", "target": barrel, "material": materials.roof},
		{"name": "Building2WingRoof", "target": wing, "material": materials.wing_roof},
	]
	var metadata := _common_metadata(roof, "building_roof")
	metadata.merge({
		"barrel_strips": BARREL_STRIPS,
		"barrel_profile": "segmental_arch_production_inference",
		"eave_y_m": EAVE_Y,
		"crown_y_m": CROWN_Y,
		"wing_roof_y_m": WING_TOP_Y,
		"source_roof_triangulation_replaced_within_footprint": true,
	}, true)
	return _finish(root, specs, collision, RENDER_WORLD_VISIBLE, false, metadata)


# --- Frame and arch -----------------------------------------------------------------

static func _frame(wall: Dictionary) -> Dictionary:
	var c := _run(wall, 3).a as Vector2
	var g := _run(wall, 8).b as Vector2
	var t := (g - c).normalized()
	var n := Vector2(-t.y, t.x)
	if n.dot(_run(wall, 4).normal as Vector2) < 0.999 or t.dot((_run(wall, 17).normal as Vector2)) < 0.999:
		return {}
	var frame := {"origin": _run(wall, 0).a, "t": t, "n": n}
	var ene_a := _run(wall, 27).a as Vector2
	var ene_b := _run(wall, 32).b as Vector2
	var nnw_a := _run(wall, 38).a as Vector2
	var nnw_b := _run(wall, 43).b as Vector2
	var j := _run(wall, 11).b as Vector2
	var s := _run(wall, 24).a as Vector2
	var back_d := _ud(frame, s).y + PYLON_ENE_SSE_DEPTH_M
	var interface_dir := -n
	var interface_ene := _line_point_at_d(frame, j, j + interface_dir, back_d)
	var w0 := _intersect(c, g, nnw_a, nnw_b)
	var w1 := _intersect(c, g, j, j + interface_dir)
	var e0 := _intersect(ene_a, ene_b, nnw_a, nnw_b)
	var e1 := _intersect(ene_a, ene_b, j, j + interface_dir)
	frame.merge({
		"interface_wsw": j,
		"interface_ene": interface_ene,
		"pylon_back_d": back_d,
		"pylon_back_sse": _xz(frame, Vector2(_ud(frame, s).x, back_d)),
		"barrel_w0": w0, "barrel_w1": w1, "barrel_e0": e0, "barrel_e1": e1,
		"barrel_span": w0.distance_to(w1),
		"wsw_u0": _ud(frame, w0).x, "wsw_u1": _ud(frame, w1).x,
		"ene_u0": _ud(frame, e0).x, "ene_u1": _ud(frame, e1).x,
	}, true)
	return frame


static func _arch_y(a: float, span: float) -> float:
	var strip := clampf(a, 0.0, 1.0) * float(BARREL_STRIPS)
	var index := mini(int(floor(strip)), BARREL_STRIPS - 1)
	return lerpf(_arch_sample_y(float(index) / BARREL_STRIPS, span), _arch_sample_y(float(index + 1) / BARREL_STRIPS, span), strip - float(index))


static func _arch_sample_y(a: float, span: float) -> float:
	var rise := CROWN_Y - EAVE_Y
	var half := span * 0.5
	var radius := (half * half + rise * rise) / (2.0 * rise)
	var x := (clampf(a, 0.0, 1.0) - 0.5) * span
	return EAVE_Y + sqrt(maxf(radius * radius - x * x, 0.0)) - (radius - rise)


static func _arch_top(frame: Dictionary, u0: float, u1: float) -> Callable:
	var span := float(frame.barrel_span)
	return func(xz: Vector2) -> float:
		return _arch_y((_ud(frame, xz).x - u0) / (u1 - u0), span)


static func _const_top(y: float) -> Callable:
	return func(_xz: Vector2) -> float:
		return y


static func _xz(frame: Dictionary, ud: Vector2) -> Vector2:
	return (frame.origin as Vector2) + (frame.t as Vector2) * ud.x + (frame.n as Vector2) * ud.y


static func _ud(frame: Dictionary, xz: Vector2) -> Vector2:
	var rel := xz - (frame.origin as Vector2)
	return Vector2(rel.dot(frame.t as Vector2), rel.dot(frame.n as Vector2))


static func _line_point_at_d(frame: Dictionary, a: Vector2, b: Vector2, d: float) -> Vector2:
	var da := _ud(frame, a).y
	var db := _ud(frame, b).y
	return a.lerp(b, (d - da) / (db - da))


static func _intersect(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> Vector2:
	var r := b - a
	var s := d - c
	var denominator := r.cross(s)
	return a + r * ((c - a).cross(s) / denominator)


static func _outward(a: Vector2, b: Vector2, inside: Vector2) -> Vector2:
	var direction := (b - a).normalized()
	var normal := Vector2(-direction.y, direction.x)
	return -normal if normal.dot((a + b) * 0.5 - inside) < 0.0 else normal


# --- Chains, faces and openings -----------------------------------------------------

static func _run(wall: Dictionary, index: int) -> Dictionary:
	var values := wall.vertices as Array
	var normals := wall.normals as Array
	var offset := index * 12
	return {
		"a": Vector2(float(values[offset]), float(values[offset + 2])),
		"b": Vector2(float(values[offset + 3]), float(values[offset + 5])),
		"ya": float(values[offset + 1]),
		"yb": float(values[offset + 4]),
		"normal": Vector2(float(normals[offset]), float(normals[offset + 2])).normalized(),
	}


static func _run_u(wall: Dictionary, index: int) -> float:
	var frame := {"origin": _run(wall, 0).a, "t": ((_run(wall, 8).b as Vector2) - (_run(wall, 3).a as Vector2)).normalized()}
	return ((_run(wall, index).a as Vector2) - (frame.origin as Vector2)).dot(frame.t as Vector2)


static func _run_ud(wall: Dictionary, frame: Dictionary, index: int, at_end: bool) -> Vector2:
	var run := _run(wall, index)
	return _ud(frame, (run.b if at_end else run.a) as Vector2)


static func _segment(a: Vector2, b: Vector2, ya: float, yb: float, normal: Vector2) -> Dictionary:
	return {"a": a, "b": b, "ya": ya, "yb": yb, "normal": normal.normalized(), "s0": 0.0, "s1": a.distance_to(b)}


static func _chain_from_runs(wall: Dictionary, runs: Array) -> Array:
	var chain: Array = []
	var s := 0.0
	for index: Variant in runs:
		var run := _run(wall, int(index))
		var length := (run.a as Vector2).distance_to(run.b as Vector2)
		run["s0"] = s
		run["s1"] = s + length
		chain.append(run)
		s += length
	return chain


## Split end walls at the exact barrel strip boundaries. Later opening cuts lie
## on the same linear profile, so independently split faces still share the roof edge.
static func _arch_chain(wall: Dictionary, runs: Array, frame: Dictionary, u0: float, u1: float) -> Array:
	var result: Array = []
	for seg: Dictionary in _chain_from_runs(wall, runs):
		var ua := _ud(frame, seg.a as Vector2).x
		var ub := _ud(frame, seg.b as Vector2).x
		var cuts: Array[float] = [0.0, 1.0]
		if absf(ub - ua) > EPS:
			for k in range(1, BARREL_STRIPS):
				var fraction := (lerpf(u0, u1, float(k) / BARREL_STRIPS) - ua) / (ub - ua)
				if fraction > EPS and fraction < 1.0 - EPS:
					cuts.append(fraction)
		cuts.sort()
		for k in cuts.size() - 1:
			var sa := lerpf(float(seg.s0), float(seg.s1), cuts[k])
			var sb := lerpf(float(seg.s0), float(seg.s1), cuts[k + 1])
			result.append({"a": _seg_point(seg, sa), "b": _seg_point(seg, sb), "ya": _seg_bottom(seg, sa), "yb": _seg_bottom(seg, sb), "normal": seg.normal, "s0": sa, "s1": sb})
	return result


static func _chain_length(chain: Array) -> float:
	return float((chain.back() as Dictionary).s1)


static func _seg_fraction(seg: Dictionary, s: float) -> float:
	var span := float(seg.s1) - float(seg.s0)
	return 0.0 if span <= 0.0 else clampf((s - float(seg.s0)) / span, 0.0, 1.0)


static func _seg_point(seg: Dictionary, s: float) -> Vector2:
	return (seg.a as Vector2).lerp(seg.b as Vector2, _seg_fraction(seg, s))


static func _seg_bottom(seg: Dictionary, s: float) -> float:
	return lerpf(float(seg.ya), float(seg.yb), _seg_fraction(seg, s))


static func _seg_at(chain: Array, s: float) -> Dictionary:
	for seg: Dictionary in chain:
		if s <= float(seg.s1) + EPS:
			return seg
	return chain.back() as Dictionary


static func _opening(s0: float, s1: float, y0: float, y1: float, depth: float, reveal: Dictionary, back: Dictionary, to_grade: bool = false, to_top: bool = false) -> Dictionary:
	return {"s0": s0, "s1": s1, "y0": y0, "y1": y1, "depth": depth, "reveal": reveal, "back": back, "to_grade": to_grade, "to_top": to_top}


## Emits the face plane of a chain between its exact source bottom line and top(),
## leaving rectangular openings that are closed by reveals and a recessed back.
static func _emit_face(target: Dictionary, chain: Array, top: Callable, openings: Array, max_step: float) -> void:
	for seg: Dictionary in chain:
		var s0 := float(seg.s0)
		var s1 := float(seg.s1)
		if s1 - s0 < EPS:
			continue
		var cuts: Array[float] = [s0, s1]
		for opening: Dictionary in openings:
			for edge: float in [float(opening.s0), float(opening.s1)]:
				if edge > s0 + EPS and edge < s1 - EPS:
					cuts.append(edge)
		if max_step > 0.0:
			var steps := ceili((s1 - s0) / max_step)
			for k in range(1, steps):
				cuts.append(s0 + (s1 - s0) * float(k) / float(steps))
		cuts.sort()
		var normal := _v3(seg.normal as Vector2, 0.0)
		for k in cuts.size() - 1:
			var sa := cuts[k]
			var sb := cuts[k + 1]
			if sb - sa < EPS:
				continue
			var pa := _seg_point(seg, sa)
			var pb := _seg_point(seg, sb)
			var top_a := float(top.call(pa))
			var top_b := float(top.call(pb))
			var cur_a := _seg_bottom(seg, sa)
			var cur_b := _seg_bottom(seg, sb)
			var covering: Array = []
			for opening: Dictionary in openings:
				if float(opening.s0) <= sa + EPS and float(opening.s1) >= sb - EPS:
					covering.append(opening)
			covering.sort_custom(func(x: Dictionary, y: Dictionary) -> bool: return float(x.y0) < float(y.y0))
			for opening: Dictionary in covering:
				if not bool(opening.to_grade) and float(opening.y0) > maxf(cur_a, cur_b) + EPS:
					_quad(target, _v3(pa, cur_a), _v3(pb, cur_b), _v3(pb, opening.y0), _v3(pa, opening.y0), normal)
				if bool(opening.to_top):
					cur_a = top_a
					cur_b = top_b
				else:
					cur_a = float(opening.y1)
					cur_b = float(opening.y1)
			if top_a > cur_a + EPS and top_b > cur_b + EPS:
				_quad(target, _v3(pa, cur_a), _v3(pb, cur_b), _v3(pb, top_b), _v3(pa, top_a), normal)
	for opening: Dictionary in openings:
		_emit_opening(chain, top, opening)


static func _emit_opening(chain: Array, top: Callable, opening: Dictionary) -> void:
	var reveal := opening.reveal as Dictionary
	var depth := float(opening.depth)
	var to_grade := bool(opening.to_grade)
	var to_top := bool(opening.to_top)
	var back_chain: Array = []
	for seg: Dictionary in chain:
		var sa := maxf(float(opening.s0), float(seg.s0))
		var sb := minf(float(opening.s1), float(seg.s1))
		if sb - sa < EPS:
			continue
		var inward := -(seg.normal as Vector2) * depth
		var pa := _seg_point(seg, sa)
		var pb := _seg_point(seg, sb)
		var head_a := float(top.call(pa)) if to_top else float(opening.y1)
		var head_b := float(top.call(pb)) if to_top else float(opening.y1)
		_quad(reveal, _v3(pa, head_a), _v3(pb, head_b), _v3(pb + inward, head_b), _v3(pa + inward, head_a), Vector3.DOWN)
		if not to_grade:
			_quad(reveal, _v3(pa, opening.y0), _v3(pb, opening.y0), _v3(pb + inward, opening.y0), _v3(pa + inward, opening.y0), Vector3.UP)
		var bottom_a := _seg_bottom(seg, sa) if to_grade else float(opening.y0)
		var bottom_b := _seg_bottom(seg, sb) if to_grade else float(opening.y0)
		back_chain.append({"a": pa + inward, "b": pb + inward, "ya": bottom_a, "yb": bottom_b, "normal": seg.normal, "s0": sa, "s1": sb})
	if back_chain.is_empty():
		return
	for side: int in [0, 1]:
		var s := float(opening.s0) if side == 0 else float(opening.s1)
		var seg := _seg_at(chain, s)
		var p := _seg_point(seg, s)
		var inward := -(seg.normal as Vector2) * depth
		var tangent := ((seg.b as Vector2) - (seg.a as Vector2)).normalized()
		var bottom := _seg_bottom(seg, s) if to_grade else float(opening.y0)
		var head := float(top.call(p)) if to_top else float(opening.y1)
		var facing := tangent if side == 0 else -tangent
		_quad(reveal, _v3(p, bottom), _v3(p + inward, bottom), _v3(p + inward, head), _v3(p, head), _v3(facing, 0.0))
	var back := opening.back as Dictionary
	var y1 := float(opening.y1)
	var back_top := top if to_top else _const_top(y1)
	var inner: Array = back.get("openings", []) as Array
	_emit_face(back.target as Dictionary, back_chain, back_top, inner, 0.0)


## Closed box spanning chain s0..s1 (split per segment), front face at an inward
## depth from the chain face line and extending thickness further inward.
static func _chain_box(target: Dictionary, chain: Array, s0: float, s1: float, y0: float, y1: float, front_depth: float, thickness: float) -> void:
	for seg: Dictionary in chain:
		var sa := maxf(s0, float(seg.s0))
		var sb := minf(s1, float(seg.s1))
		if sb - sa < EPS:
			continue
		var n2 := seg.normal as Vector2
		var tangent := ((seg.b as Vector2) - (seg.a as Vector2)).normalized()
		var fa := _seg_point(seg, sa) - n2 * front_depth
		var fb := _seg_point(seg, sb) - n2 * front_depth
		var ba := fa - n2 * thickness
		var bb := fb - n2 * thickness
		var normal := _v3(n2, 0.0)
		_quad(target, _v3(fa, y0), _v3(fb, y0), _v3(fb, y1), _v3(fa, y1), normal)
		_quad(target, _v3(bb, y0), _v3(ba, y0), _v3(ba, y1), _v3(bb, y1), -normal)
		_quad(target, _v3(fa, y1), _v3(fb, y1), _v3(bb, y1), _v3(ba, y1), Vector3.UP)
		_quad(target, _v3(ba, y0), _v3(bb, y0), _v3(fb, y0), _v3(fa, y0), Vector3.DOWN)
		if sa <= s0 + EPS:
			_quad(target, _v3(ba, y0), _v3(fa, y0), _v3(fa, y1), _v3(ba, y1), _v3(-tangent, 0.0))
		if sb >= s1 - EPS:
			_quad(target, _v3(fb, y0), _v3(bb, y0), _v3(bb, y1), _v3(fb, y1), _v3(tangent, 0.0))


# --- Buckets, nodes and metadata ----------------------------------------------------

static func _bucket() -> Dictionary:
	return {"vertices": [], "normals": [], "uvs": [], "tangents": [], "indices": []}


static func _target(collision: Dictionary) -> Dictionary:
	return {"vis": _bucket(), "col": collision}


static func _v3(xz: Vector2, y: Variant) -> Vector3:
	return Vector3(xz.x, float(y), xz.y)


static func _quad(target: Dictionary, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal_value: Vector3) -> void:
	var normal := normal_value.normalized()
	var clockwise_needed := (b - a).cross(c - a).dot(normal) > 0.0
	var tangent := Vector3(normal.z, 0.0, -normal.x).normalized() if absf(normal.y) < 0.7 else (Vector3.RIGHT - normal * normal.x).normalized()
	var bitangent := normal.cross(tangent).normalized()
	for bucket: Dictionary in [target.vis, target.col]:
		var vertices := bucket.vertices as Array
		var base := vertices.size()
		for point: Vector3 in [a, b, c, d]:
			vertices.append(point)
			(bucket.normals as Array).append(normal)
			(bucket.uvs as Array).append(Vector2(point.dot(tangent), point.dot(bitangent)))
			(bucket.tangents as Array).append_array([tangent.x, tangent.y, tangent.z, 1.0])
		if clockwise_needed:
			(bucket.indices as Array).append_array([base, base + 2, base + 1, base, base + 3, base + 2])
		else:
			(bucket.indices as Array).append_array([base, base + 1, base + 2, base, base + 2, base + 3])


static func _triangle(target: Dictionary, a: Vector3, b: Vector3, c: Vector3, normal_value: Vector3) -> void:
	var normal := normal_value.normalized()
	var clockwise_needed := (b - a).cross(c - a).dot(normal) > 0.0
	var tangent := Vector3(normal.z, 0.0, -normal.x).normalized() if absf(normal.y) < 0.7 else (Vector3.RIGHT - normal * normal.x).normalized()
	var bitangent := normal.cross(tangent).normalized()
	for bucket: Dictionary in [target.vis, target.col]:
		var vertices := bucket.vertices as Array
		var base := vertices.size()
		for point: Vector3 in [a, b, c]:
			vertices.append(point)
			(bucket.normals as Array).append(normal)
			(bucket.uvs as Array).append(Vector2(point.dot(tangent), point.dot(bitangent)))
			(bucket.tangents as Array).append_array([tangent.x, tangent.y, tangent.z, 1.0])
		if clockwise_needed:
			(bucket.indices as Array).append_array([base, base + 2, base + 1])
		else:
			(bucket.indices as Array).append_array([base, base + 1, base + 2])


static func _materials() -> Dictionary:
	return {
		"field_glass": _material("building_2_field_glazing_grey_green", Color(0.40, 0.47, 0.47), 0.12, 0.3),
		"field_band": _material("building_2_field_dark_pane_band", Color(0.11, 0.15, 0.18), 0.1, 0.35),
		"field_grid": _material("building_2_field_light_steel_grid", Color(0.70, 0.71, 0.68), 0.25, 0.55),
		"entry_panel": _material("building_2_entry_blue_grey_panel", Color(0.50, 0.60, 0.69), 0.0, 0.8),
		"pylon_inset": _material("building_2_pylon_blue_grey_inset", Color(0.62, 0.67, 0.70), 0.0, 0.82),
		"roof": _material("building_2_barrel_roof_weathered_grey", Color(0.47, 0.47, 0.45), 0.05, 0.88),
		"wing_roof": _material("building_2_wing_roof_grey", Color(0.42, 0.42, 0.40), 0.0, 0.92),
	}


static func _material(resource_name: String, color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = resource_name
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material


static func _finish(root: Node3D, specs: Array[Dictionary], collision: Dictionary, layers: int, sprayable: bool, metadata: Dictionary) -> Dictionary:
	var mesh_count := 0
	var triangle_count := 0
	for spec: Dictionary in specs:
		var bucket := (spec.target as Dictionary).vis as Dictionary
		if (bucket.indices as Array).is_empty():
			continue
		root.add_child(_mesh_instance(str(spec.name), bucket, spec.material as Material, layers))
		mesh_count += 1
		triangle_count += int((bucket.indices as Array).size() / 3)
	if (collision.indices as Array).is_empty():
		root.free()
		return {"ok": false, "code": "building_2_hero_collision", "message": "Building 2 collision geometry was empty."}
	root.add_child(_collision_body(collision, str(root.get_meta("derived_object_key")), root.get_meta("source_keys") as Array, sprayable))
	metadata["mesh_instances"] = mesh_count
	metadata["triangles"] = triangle_count
	metadata["collision_triangles"] = int((collision.indices as Array).size() / 3)
	metadata["visible_and_collision_triangles_shared"] = triangle_count == int((collision.indices as Array).size() / 3)
	for key: String in metadata:
		root.set_meta(key, metadata[key])
	return {
		"ok": true,
		"node": root,
		"mesh_instances": mesh_count,
		"surfaces": mesh_count,
		"triangles": triangle_count,
		"static_bodies": 1,
		"shapes": 1,
		"metadata": metadata,
	}


static func _mesh_instance(node_name: String, bucket: Dictionary, material: Material, layers: int) -> MeshInstance3D:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(bucket.vertices as Array)
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(bucket.normals as Array)
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(bucket.uvs as Array)
	arrays[Mesh.ARRAY_TANGENT] = PackedFloat32Array(bucket.tangents as Array)
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(bucket.indices as Array)
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_name(0, node_name.to_snake_case())
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.layers = layers
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return instance


static func _collision_body(bucket: Dictionary, object_key: String, source_keys: Array, sprayable: bool) -> StaticBody3D:
	var vertices := bucket.vertices as Array
	var faces := PackedVector3Array()
	for index: Variant in bucket.indices as Array:
		faces.append(vertices[int(index)] as Vector3)
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	var body := StaticBody3D.new()
	body.name = "Collision"
	body.collision_layer = PHYSICS_WORLD_SOLID | (PHYSICS_SPRAY_SURFACE if sprayable else 0)
	body.collision_mask = 0
	for holder: Object in [shape, body]:
		holder.set_meta("receiver_kind", "building_wall" if sprayable else "none")
		holder.set_meta("opaque", true)
		holder.set_meta("derived_object_key", object_key)
		holder.set_meta("source_keys", source_keys.duplicate())
		holder.set_meta("building_2_hero", true)
	if sprayable:
		body.add_to_group("spray_receiver_wall")
	var shape_node := CollisionShape3D.new()
	shape_node.name = "Shape"
	shape_node.shape = shape
	body.add_child(shape_node)
	return body


static func _hero_root(node_name: String, record: Dictionary, component: String) -> Node3D:
	var root := Node3D.new()
	root.name = node_name
	root.set_meta("derived_object_key", str(record.object_key))
	root.set_meta("source_keys", (record.source_keys as Array).duplicate())
	root.set_meta("feature_kind", str(record.feature_kind))
	root.set_meta("building_2_hero_component", component)
	return root


static func _common_metadata(record: Dictionary, component: String) -> Dictionary:
	return {
		"model_id": MODEL_ID,
		"source_key": SOURCE_KEY,
		"object_key": str(record.object_key),
		"component": component,
		"corrected_nrhp_id": "08000082",
		"frozen_osm_nrhp_ref": "08000081",
		"frozen_osm_nrhp_ref_role": "provenance_only_incorrect_for_building_2",
		"runtime_supersedes_generated_placeholder": true,
		"horizontal_source_geometry_preserved": true,
		"exact_source_wall_bottoms_preserved": true,
		"vertical_massing_role": "reversible_production_inference",
		"reference_observations": "wsw_streetview_2019_05_and_sse_visitor_panorama_2017_04",
		"surveyed_vertical_dimensions": false,
		"surveyed_facade_coordinates": false,
		"as_built_fidelity_claimed": false,
		"interior_modeled": false,
		"source_photography_shipped": false,
		"visual_review_status": "pending_independent_review",
	}


static func _record_from_chunk(path: String, key: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return {}
	for value: Variant in (parsed as Dictionary).get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


static func _record_valid(record: Dictionary) -> bool:
	if record.is_empty() or not matches_record(record):
		return false
	var is_wall := str(record.object_key) == WALL_KEY
	var vertices := record.get("vertices", []) as Array
	var indices := record.get("indices", []) as Array
	if record.get("source_keys", []) != [SOURCE_KEY] \
		or str(record.get("feature_kind", "")) != ("building_wall" if is_wall else "building_roof") \
		or str(record.get("collision_kind", "")) != "world_solid" \
		or not bool(record.get("opaque", false)) \
		or not is_equal_approx(float(record.get("flat_base_elevation_m", 0.0)), BASE_Y) \
		or vertices.is_empty() or vertices.size() % 3 != 0 or indices.is_empty():
		return false
	for value: Variant in vertices:
		if not (value is float or value is int) or not is_finite(float(value)):
			return false
	var vertex_count := vertices.size() / 3
	for index: Variant in indices:
		if int(index) < 0 or int(index) >= vertex_count:
			return false
	if not is_wall:
		return true
	# The facade grammar addresses runs by index: require safe access to every run it
	# uses (four vertices per run, matching normals), not a pinned snapshot size.
	return vertices.size() % 12 == 0 \
		and vertices.size() >= (MAX_REQUIRED_RUN + 1) * 12 \
		and (record.get("normals", []) as Array).size() == vertices.size()


static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	return {
		"ok": false,
		"code": code,
		"message": message,
		"source_keys": (record.get("source_keys", []) as Array).duplicate(),
	}
