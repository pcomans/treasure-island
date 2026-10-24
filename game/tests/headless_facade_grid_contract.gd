extends SceneTree

## The shared facade window grid (facade_grid.gd) and assembly vocabulary
## (facade_assembly.gd) on hand-built grids: expansion in the stacks() format,
## per-storey rows, groups and blank cells, ground-sill raising with fixed heads,
## inheritance by an unphotographed face, and fail-closed validation (tiling groups,
## no coerced numbers); assembly members are boxes, curtains refuse a bad pitch and
## groups fill their end gaps.

const GRID := preload("res://game/scripts/world/facades/facade_grid.gd")
const ASSEMBLY := preload("res://game/scripts/world/facades/facade_assembly.gd")
const SOURCE := {"kind": "rectified_photo", "ref": "test-photo", "date": "2025-09", "side": "wsw"}
const FLOORS := [10.0, 13.0, 16.0]
const TOP := 19.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures := run_checks()
	for failure: String in failures:
		print("FAIL: facade grid: ", failure)
	if failures.is_empty():
		print("PASS: facade grid expands, raises buried ground sills under fixed heads, inherits photographed grids and fails closed on bad grids; assembly helpers close their members")
	quit(0 if failures.is_empty() else 1)


static func run_checks() -> Array:
	var failures := []
	_check_expand(failures)
	_check_ground(failures)
	_check_validate(failures)
	_check_inherit(failures)
	_check_assembly(failures)
	_check_assembly_refusals(failures)
	return failures


static func _grid(extra: Dictionary = {}) -> Dictionary:
	var grid := {"columns": [[1.0, 2.5], [4.0, 5.5]], "rows": {"*": {"sill": 0.35, "head": 2.6}}, "source": SOURCE.duplicate()}
	grid.merge(extra, true)
	return grid


static func _expect(failures: Array, condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


static func _near(a: float, b: float) -> bool:
	return absf(a - b) < 0.00001


static func _near_list(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in a.size():
		if not _near(float(a[i]), float(b[i])):
			return false
	return true


# Openings of a grid expected to be valid ([] when expand refuses it).
static func _open(grid: Dictionary, options: Dictionary = {}) -> Array:
	var result := GRID.expand(grid, FLOORS, TOP, options)
	return result.openings if bool(result.ok) else []


static func _check_expand(failures: Array) -> void:
	_expect(failures, GRID.floor_lines(10.0, 3, 3.0) == FLOORS, "floor_lines")
	_expect(failures, GRID.unique_sorted([3.0, 1.0, 1.0005, 2.0]) == [1.0, 2.0, 3.0], "unique_sorted")
	_expect(failures, GRID.in_opening([[1.0, 2.0, 1.0, 2.0]], 1.5, 1.5) and not GRID.in_opening([[1.0, 2.0, 1.0, 2.0]], 2.0, 1.5), "in_opening")
	# A uniform grid expands exactly as stacks() does.
	var expanded := _open(_grid({"groups": [[0, 0], [1, 2]]}), {"style": {"split": 0.5}})
	_expect(failures, expanded == GRID.stacks([[1.0, 2.5], [4.0, 5.5]], FLOORS, [[0, 0], [1, 2]], 0.35, 2.6, {"split": 0.5}), "uniform grid differs from stacks()")
	_expect(failures, expanded.size() == 4 and (expanded[1][4].spandrels as Array).size() == 1, "grouped storeys did not join")
	for o: Array in expanded:
		_expect(failures, not (o[4] as Dictionary).has("sill_raised"), "sill raised without ground")
	# Pitch columns; JSON-style integral floats are indices.
	var pitched := _grid({"columns": {"pitch": 3.0, "first": 1.0, "count": 3.0, "width": 1.5}})
	_expect(failures, GRID.columns(pitched) == [[1.0, 2.5], [4.0, 5.5], [7.0, 8.5]], "pitch columns")
	_expect(failures, bool(GRID.validate(pitched, FLOORS, TOP).ok), "valid pitch grid refused")
	_expect(failures, bool(GRID.validate(_grid({"columns": [[1, 2.5], [4, 5.5]], "groups": [[0.0, 1.0], [2, 2]]}), FLOORS, TOP).ok), "integer or integral-float values refused")
	# Per-storey rows over a default row.
	var by_row := _open(_grid({"rows": {"0": {"sill": 0.9, "head": 2.6}, "*": {"sill": 0.35, "head": 2.75}}}))
	_expect(failures, by_row.size() == 6 and _near(by_row[0][2], 10.9) and _near(by_row[0][3], 12.6) and _near(by_row[1][2], 13.35) and _near(by_row[1][3], 15.75), "per-storey rows")
	# A blank cell splits its group; other columns keep the joined stack.
	var blank := _open(_grid({"groups": [[0, 1], [2, 2]], "blank_cells": [[0, 1]]}))
	_expect(failures, blank.size() == 4, "blank cell count")
	if blank.size() == 4:
		_expect(failures, _near(blank[0][2], 10.35) and _near(blank[0][3], 12.6) and (blank[0][4].spandrels as Array).is_empty(), "blank cell left a joined storey")
		_expect(failures, _near(blank[2][2], 10.35) and _near(blank[2][3], 15.6) and blank[2][4].spandrels.size() == 1 and _near_list(blank[2][4].spandrels[0], [12.6, 13.35]) and _near_list(blank[2][4].sills, [10.35, 13.35]), "unblanked column lost its stack")
	# expand() validates itself: an invalid grid or ground gives errors, not openings.
	var refused := GRID.expand(_grid({"groups": [[0, 1]]}), FLOORS, TOP)
	_expect(failures, not bool(refused.ok) and (refused.openings as Array).is_empty() and not (refused.errors as Array).is_empty(), "expand accepted an invalid grid")
	var bad_ground := GRID.expand(_grid(), FLOORS, TOP, {"ground": "10.5"})
	_expect(failures, not bool(bad_ground.ok), "expand accepted a non-numeric ground")


static func _check_ground(failures: Array) -> void:
	# Ground just above the ground-floor sill: that sill rises, the head stays.
	var low := _open(_grid(), {"ground": 10.5})
	_expect(failures, low.size() == 6 and _near(low[0][2], 10.65) and _near(low[0][3], 12.6) and bool(low[0][4].get("sill_raised", false)), "buried sill not raised under a fixed head")
	_expect(failures, low.size() == 6 and _near(low[1][2], 13.35) and not (low[1][4] as Dictionary).has("sill_raised"), "unburied sill moved")
	# Ground level with the sill (within float noise) is not a raise.
	var level := _open(_grid(), {"ground": 10.2})
	_expect(failures, level.size() == 6 and not (level[0][4] as Dictionary).has("sill_raised"), "float noise counted as a raised sill")
	# Ground that would leave too little light drops the ground-floor storey.
	var high := _open(_grid(), {"ground": 12.4})
	_expect(failures, high.size() == 4 and _near(high[0][2], 13.35), "buried storey not dropped")
	# Higher storeys are never raised or dropped by the ground.
	for ground: float in [13.5, 30.0]:
		var deep := _open(_grid(), {"ground": ground})
		_expect(failures, deep.size() == 4 and _near(deep[0][2], 13.35) and _near(deep[1][2], 16.35) and not (deep[0][4] as Dictionary).has("sill_raised"), "ground %.1f moved an upper storey" % ground)
	# Ground per column: only the column over high ground rises.
	var sloped := _open(_grid(), {"ground": func(u0: float, _u1: float) -> float: return 11.0 if u0 > 3.0 else 9.0})
	_expect(failures, sloped.size() == 6 and _near(sloped[0][2], 10.35) and _near(sloped[3][2], 11.15) and _near(sloped[3][3], 12.6), "per-column ground")
	# A joined stack whose ground storey is buried starts at the next storey, unraised.
	var joined := _open(_grid({"groups": [[0, 1], [2, 2]]}), {"ground": 13.5})
	_expect(failures, joined.size() == 4 and _near(joined[0][2], 13.35) and _near(joined[0][3], 15.6) and (joined[0][4].spandrels as Array).is_empty() and _near_list(joined[0][4].sills, [13.35]) and not (joined[0][4] as Dictionary).has("sill_raised"), "buried storey left in a joined stack")
	# The clearance is an option.
	var clear := _open(_grid(), {"ground": 10.5, "ground_clearance": 0.3})
	_expect(failures, clear.size() == 6 and _near(clear[0][2], 10.8), "ground clearance option")


static func _refused(grid: Dictionary, token: String, top: float = TOP, options: Dictionary = {}, floors: Array = FLOORS) -> bool:
	var result := GRID.validate(grid, floors, top, options)
	if bool(result.ok):
		return false
	for error: String in result.errors:
		if error.contains(token):
			return true
	return false


static func _check_validate(failures: Array) -> void:
	_expect(failures, bool(GRID.validate(_grid({"groups": [[0, 1], [2, 2]], "blank_cells": [[1, 2]]}), FLOORS, TOP).ok), "valid grid refused")
	var cases := [
		[_grid({"columns": [[4.0, 5.5], [1.0, 2.5]]}), "unsorted"],
		[_grid({"columns": [[1.0, 2.5], [2.0, 3.0]]}), "overlaps"],
		[_grid({"columns": [[1.0, 2.5], [2.55, 3.5]]}), "pier"],
		[_grid({"columns": {"pitch": 1.55, "first": 0.0, "count": 3, "width": 1.5}}), "pier"],
		[_grid({"columns": {"pitch": 3.0, "first": 0.0, "width": 1.5}}), "integral count"],
		[_grid({"columns": [[1.0, 1.0]]}), "no width"],
		[_grid({"columns": []}), "columns: none"],
		[_grid({"rows": {"*": {"sill": 0.35, "head": 3.2}}}), "does not fit"],
		[_grid({"rows": {"*": {"sill": -0.1, "head": 2.6}}}), "below its floor line"],
		[_grid({"rows": {"*": {"sill": 1.0, "head": 1.2}}}), "is under"],
		[_grid({"rows": {"0": {"sill": 0.35, "head": 2.6}}}), "no numeric sill/head row"],
		[_grid({"rows": {"*": {"sill": 0.35, "head": 2.6}, "7": {"sill": 0.35, "head": 2.6}}}), "not a storey index"],
		[_grid({"groups": [[0, 3]]}), "storey range"],
		[_grid({"blank_cells": [[2, 0]]}), "blank_cells"],
		[_grid({"source": {"kind": "guess", "ref": "x", "date": "2025", "side": "wsw"}}), "kind"],
		[_grid({"source": {"kind": "rectified_photo", "ref": "x", "side": "wsw"}}), "date is missing"],
		[{"columns": [[1.0, 2.5]], "rows": {"*": {"sill": 0.35, "head": 2.6}}}, "source: missing"],
		[_grid({"source": {"kind": "inferred_from_side", "ref": "x", "date": "2025", "side": "wsw"}}), "inferred"],
		# Groups must tile storeys 0..n-1; exceptions go through blank_cells.
		[_grid({"groups": [[0, 1]]}), "tile"],
		[_grid({"groups": [[1, 2]]}), "tile"],
		[_grid({"groups": [[0, 0], [2, 2]]}), "tile"],
		[_grid({"groups": [[0, 1], [1, 2]]}), "tile"],
		# Nothing is coerced: non-numeric fields and non-integral indices are refused.
		[_grid({"columns": [["1.0", 2.5]]}), "numbers"],
		[_grid({"columns": [[1.0, true]]}), "numbers"],
		[_grid({"columns": {"pitch": "3", "first": 0.0, "count": 3, "width": 1.5}}), "numeric pitch"],
		[_grid({"columns": {"pitch": 3.0, "first": 0.0, "count": 2.5, "width": 1.5}}), "integral count"],
		[_grid({"columns": {"pitch": 3.0, "first": 0.0, "count": "3", "width": 1.5}}), "integral count"],
		[_grid({"rows": {"*": {"sill": "0.35", "head": 2.6}}}), "no numeric sill/head row"],
		[_grid({"rows": {"*": {"sill": 0.35, "head": NAN}}}), "no numeric sill/head row"],
		[_grid({"groups": [[0.5, 2]]}), "storey indices"],
		[_grid({"groups": [["0", 2]]}), "storey indices"],
		[_grid({"blank_cells": [[0, 1.5]]}), "blank_cells"],
		[_grid({"blank_cells": [["0", 1]]}), "blank_cells"],
	]
	for case: Array in cases:
		_expect(failures, _refused(case[0], case[1]), "accepted a grid that should fail with \"%s\"" % case[1])
	_expect(failures, _refused(_grid(), "span", TOP, {"span": [0.0, 5.0]}), "columns outside the face span accepted")
	_expect(failures, _refused(_grid(), "top", 16.0), "last storey without height accepted")
	_expect(failures, _refused(_grid(), "pier", TOP, {"min_pier": 2.0}), "min_pier option ignored")
	_expect(failures, _refused(_grid(), "floor line 1", TOP, {}, [10.0, "13", 16.0]), "non-numeric floor line accepted")
	# min_light comes from the same option in validate and expand.
	_expect(failures, _refused(_grid(), "is under", TOP, {"min_light": 2.5}), "min_light option ignored by validate")
	_expect(failures, not bool(GRID.expand(_grid(), FLOORS, TOP, {"min_light": 2.5}).ok), "min_light option ignored by expand")


static func _check_inherit(failures: Array) -> void:
	var grid := _grid()
	var inferred := GRID.inherit(grid, "ene")
	var source: Dictionary = inferred.source
	_expect(failures, source.kind == "inferred_from_side" and source.face == "ene" and source.side == "wsw" and source.ref == "test-photo" and source.truth_class == "production_inference", "inherited source")
	_expect(failures, grid.source.kind == "rectified_photo" and not (grid.source as Dictionary).has("face"), "inherit changed the photographed grid")
	_expect(failures, bool(GRID.validate(inferred, FLOORS, TOP).ok), "inherited grid refused")
	_expect(failures, _open(inferred) == _open(grid) and not _open(grid).is_empty(), "inherited grid expands differently")


static func _roles(rects: Array, role: String) -> Array:
	return rects.filter(func(r: Dictionary) -> bool: return r.role == role)


# Rects of a helper result expected to succeed ([] when it refused).
static func _rects(result: Dictionary) -> Array:
	return result.rects if bool(result.ok) else []


static func _all_boxes(rects: Array) -> bool:
	for r: Dictionary in rects:
		if float(r.d1) - float(r.d0) < ASSEMBLY.MIN_DEPTH_M - 0.000001:
			return false
	return not rects.is_empty()


static func _check_assembly(failures: Array) -> void:
	var u := _rects(ASSEMBLY.unit(0.0, 2.0, 0.0, 2.5, {"split": 0.5, "transoms": [1.15], "lower_field": 0.45, "materials": {"frame": "frame_grey"}}))
	_expect(failures, _roles(u, "pane").size() == 1 and _roles(u, "frame").size() == 4 and _roles(u, "lower_field").size() == 1
		and _roles(u, "transom").size() == 2 and _roles(u, "mullion").size() == 1, "unit members")
	for r: Dictionary in u:
		_expect(failures, r.u0 >= 0.0 and r.u1 <= 2.0 and r.y0 >= 0.0 and r.y1 <= 2.5, "unit member outside its opening")
	_expect(failures, not u.is_empty() and _roles(u, "frame")[0].material == "frame_grey" and _roles(u, "pane")[0].material == "pane", "role materials")
	var narrow := _rects(ASSEMBLY.unit(0.0, 1.0, 0.0, 2.5, {"split": 0.5}))
	_expect(failures, not narrow.is_empty() and _roles(narrow, "mullion").is_empty(), "split on a narrow unit")
	# A two-storey stack from the grid: two units and one spandrel; a surround outside
	# it; the opening's pane style becomes the pane material.
	var openings := _open(_grid({"groups": [[0, 1], [2, 2]]}), {"style": {"surround": true, "pane": "glass_blue"}})
	var s := _rects(ASSEMBLY.stack(openings[0])) if not openings.is_empty() else []
	_expect(failures, _roles(s, "pane").size() == 2 and _roles(s, "spandrel").size() == 1 and _roles(s, "surround").size() == 4, "stack members")
	_expect(failures, not _roles(s, "pane").is_empty() and _roles(s, "pane").all(func(r: Dictionary) -> bool: return r.material == "glass_blue"), "stack pane style")
	var surround: Array = _roles(s, "surround")
	_expect(failures, not surround.is_empty() and _near(float(surround[0].u1) - float(surround[0].u0), ASSEMBLY.STACK_SURROUND_W_M), "stack surround width")
	var spandrel: Dictionary = _roles(s, "spandrel")[0] if not _roles(s, "spandrel").is_empty() else {}
	_expect(failures, _near(float(spandrel.get("y0", 0.0)), 12.6) and _near(float(spandrel.get("y1", 0.0)), 13.35), "stack spandrel off the grid")
	# Curtain wall: every mullion runs the full field, head and sill rails close it.
	var c := _rects(ASSEMBLY.curtain(0.3, 5.0, 0.0, 6.0, {"pitch": 1.0, "floors": [3.0]}))
	var mullions := _roles(c, "mullion")
	var centres := mullions.map(func(r: Dictionary) -> float: return (r.u0 + r.u1) * 0.5)
	centres.sort()
	_expect(failures, _near_list(centres, [0.3, 1.0, 2.0, 3.0, 4.0, 5.0]), "curtain mullions off the absolute pitch")
	for r: Dictionary in mullions:
		_expect(failures, _near(r.y0, 0.0) and _near(r.y1, 6.0), "curtain mullion ends free")
	var rails := _roles(c, "transom").map(func(r: Dictionary) -> float: return (r.y0 + r.y1) * 0.5)
	rails.sort()
	_expect(failures, _near_list(rails, [0.0, 2.65, 3.15, 6.0]) and _roles(c, "spandrel").size() == 1, "curtain rails or floor spandrel")
	var even := _rects(ASSEMBLY.curtain(0.0, 4.4, 0.0, 3.0, {"pitch": 1.1, "absolute": false}))
	_expect(failures, _roles(even, "mullion").size() == 5, "evenly divided curtain")
	# Group: surround, dividers filling every gap (both ends too), a unit per light per storey.
	var g := _rects(ASSEMBLY.group(0.0, 3.0, 0.0, 6.0, [[0.99, 2.8], [0.2, 0.85]], [[2.8, 3.2]]))
	var dividers: Array = _roles(g, "divider")
	_expect(failures, _roles(g, "surround").size() == 4 and _roles(g, "pane").size() == 4 and _roles(g, "spandrel").size() == 1, "group members")
	var pieces := dividers.map(func(r: Dictionary) -> Array: return [r.u0, r.u1])
	pieces.append_array([[0.2, 0.85], [0.99, 2.8]])
	pieces.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	var edge := 0.0
	var tiled := dividers.size() == 3
	for piece: Array in pieces:
		tiled = tiled and _near(float(piece[0]), edge)
		edge = float(piece[1])
	_expect(failures, tiled and _near(edge, 3.0), "group lights and dividers do not cover the group")
	var flush := _rects(ASSEMBLY.group(0.0, 3.0, 0.0, 6.0, [[0.0, 0.85], [0.99, 3.0]]))
	_expect(failures, _roles(flush, "divider").size() == 1, "group made dividers at flush ends")
	var sill: Array = _rects(ASSEMBLY.sill_band(1.0, 2.0, 10.0))
	_expect(failures, sill.size() == 1 and _near(sill[0].u0, 0.9) and _near(sill[0].u1, 2.1) and _near(sill[0].y0, 9.88) and _near(sill[0].y1, 10.0) and _near(sill[0].d1, 0.1), "sill band")
	var head: Array = _rects(ASSEMBLY.head_band(1.0, 2.0, 12.6))
	_expect(failures, head.size() == 1 and _near(head[0].y0, 12.6) and _near(head[0].y1, 12.72), "head band")
	var pier: Array = _rects(ASSEMBLY.pilaster(5.0, 0.7, 4.0, 10.0, 0.35))
	_expect(failures, pier.size() == 1 and _near(pier[0].u0, 4.65) and _near(pier[0].u1, 5.35) and pier[0].role == "pilaster" and _near(pier[0].d1, 0.35), "pilaster")
	# Depth rule: every member of every helper is a box with real depth, including a
	# member specified flat.
	var flat := _rects(ASSEMBLY.curtain(0.0, 2.0, 0.0, 3.0, {"d": 0.001, "floors": [1.5]}))
	for named: Array in [["unit", u], ["stack", s], ["curtain", c], ["even curtain", even], ["group", g], ["sill", sill], ["head", head], ["pilaster", pier], ["thin curtain", flat]]:
		_expect(failures, _all_boxes(named[1]), "%s has a member without box depth" % named[0])


static func _check_assembly_refusals(failures: Array) -> void:
	for pitch: float in [0.0, -1.25]:
		var refused := ASSEMBLY.curtain(0.0, 4.0, 0.0, 3.0, {"pitch": pitch})
		_expect(failures, not bool(refused.ok) and (refused.rects as Array).is_empty() and not (refused.errors as Array).is_empty(), "curtain accepted pitch %.2f" % pitch)
	_expect(failures, not bool(ASSEMBLY.group(0.0, 3.0, 0.0, 6.0, [[0.0, 1.0], [0.9, 2.0]]).ok), "group accepted overlapping lights")
	_expect(failures, not bool(ASSEMBLY.group(0.0, 3.0, 0.0, 6.0, [[2.5, 3.5]]).ok), "group accepted a light outside it")
	_expect(failures, not bool(ASSEMBLY.unit(2.0, 1.0, 0.0, 2.5).ok), "unit accepted an inverted extent")
	_expect(failures, not bool(ASSEMBLY.pilaster(5.0, 0.7, 4.0, 10.0, 0.0).ok), "pilaster accepted no depth")
	_expect(failures, not bool(ASSEMBLY.sill_band(1.0, 2.0, 10.0, 0.12, 0.0).ok), "sill band accepted no projection")
