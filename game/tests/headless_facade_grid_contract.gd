extends SceneTree

## The shared facade window grid (facade_grid.gd) and assembly vocabulary
## (facade_assembly.gd) on hand-built grids: expansion in the stacks() format,
## per-storey rows, groups and blank cells, ground-sill raising with fixed heads,
## inheritance by an unphotographed face, and fail-closed validation.

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


static func _check_expand(failures: Array) -> void:
	_expect(failures, GRID.floor_lines(10.0, 3, 3.0) == FLOORS, "floor_lines")
	_expect(failures, GRID.unique_sorted([3.0, 1.0, 1.0005, 2.0]) == [1.0, 2.0, 3.0], "unique_sorted")
	_expect(failures, GRID.in_opening([[1.0, 2.0, 1.0, 2.0]], 1.5, 1.5) and not GRID.in_opening([[1.0, 2.0, 1.0, 2.0]], 2.0, 1.5), "in_opening")
	# A uniform grid expands exactly as stacks() does.
	var grouped := _grid({"groups": [[0, 0], [1, 2]]})
	var expanded := GRID.expand(grouped, FLOORS, {"style": {"split": 0.5}})
	_expect(failures, expanded == GRID.stacks([[1.0, 2.5], [4.0, 5.5]], FLOORS, [[0, 0], [1, 2]], 0.35, 2.6, {"split": 0.5}), "uniform grid differs from stacks()")
	_expect(failures, expanded.size() == 4 and (expanded[1][4].spandrels as Array).size() == 1, "grouped storeys did not join")
	for o: Array in expanded:
		_expect(failures, not (o[4] as Dictionary).has("sill_raised"), "sill raised without ground")
	# Pitch columns.
	var pitched := _grid({"columns": {"pitch": 3.0, "first": 1.0, "count": 3, "width": 1.5}})
	_expect(failures, GRID.columns(pitched) == [[1.0, 2.5], [4.0, 5.5], [7.0, 8.5]], "pitch columns")
	_expect(failures, bool(GRID.validate(pitched, FLOORS, TOP).ok), "valid pitch grid refused")
	# Per-storey rows over a default row.
	var rows := _grid({"rows": {"0": {"sill": 0.9, "head": 2.6}, "*": {"sill": 0.35, "head": 2.75}}})
	var by_row := GRID.expand(rows, FLOORS)
	_expect(failures, by_row.size() == 6 and _near(by_row[0][2], 10.9) and _near(by_row[0][3], 12.6) and _near(by_row[1][2], 13.35) and _near(by_row[1][3], 15.75), "per-storey rows")
	# A blank cell splits its group; other columns keep the joined stack.
	var blank := GRID.expand(_grid({"groups": [[0, 1], [2, 2]], "blank_cells": [[0, 1]]}), FLOORS)
	_expect(failures, blank.size() == 4, "blank cell count")
	if blank.size() == 4:
		_expect(failures, _near(blank[0][2], 10.35) and _near(blank[0][3], 12.6) and (blank[0][4].spandrels as Array).is_empty(), "blank cell left a joined storey")
		_expect(failures, _near(blank[2][2], 10.35) and _near(blank[2][3], 15.6) and blank[2][4].spandrels.size() == 1 and _near_list(blank[2][4].spandrels[0], [12.6, 13.35]) and _near_list(blank[2][4].sills, [10.35, 13.35]), "unblanked column lost its stack")


static func _check_ground(failures: Array) -> void:
	# Ground just above the first sill: that sill rises, the head stays.
	var low := GRID.expand(_grid(), FLOORS, {"ground": 10.5})
	_expect(failures, low.size() == 6 and _near(low[0][2], 10.65) and _near(low[0][3], 12.6) and bool(low[0][4].get("sill_raised", false)), "buried sill not raised under a fixed head")
	_expect(failures, low.size() == 6 and _near(low[1][2], 13.35) and not (low[1][4] as Dictionary).has("sill_raised"), "unburied sill moved")
	# Ground that would leave too little light drops that storey.
	var high := GRID.expand(_grid(), FLOORS, {"ground": 12.4})
	_expect(failures, high.size() == 4 and _near(high[0][2], 13.35), "buried storey not dropped")
	# Ground per column: only the column over high ground rises.
	var sloped := GRID.expand(_grid(), FLOORS, {"ground": func(u0: float, _u1: float) -> float: return 11.0 if u0 > 3.0 else 9.0})
	_expect(failures, sloped.size() == 6 and _near(sloped[0][2], 10.35) and _near(sloped[3][2], 11.15) and _near(sloped[3][3], 12.6), "per-column ground")
	# A joined stack whose lowest storey is buried starts at the next storey.
	var joined := GRID.expand(_grid({"groups": [[0, 1], [2, 2]]}), FLOORS, {"ground": 12.4})
	_expect(failures, joined.size() == 4 and _near(joined[0][2], 13.35) and _near(joined[0][3], 15.6) and (joined[0][4].spandrels as Array).is_empty() and _near_list(joined[0][4].sills, [13.35]), "buried storey left in a joined stack")
	# The clearance is an option.
	var clear := GRID.expand(_grid(), FLOORS, {"ground": 10.5, "ground_clearance": 0.3})
	_expect(failures, _near(clear[0][2], 10.8), "ground clearance option")


static func _refused(grid: Dictionary, token: String, top: float = TOP, options: Dictionary = {}) -> bool:
	var result := GRID.validate(grid, FLOORS, top, options)
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
		[_grid({"columns": {"pitch": 3.0, "first": 0.0, "width": 1.5}}), "needs count"],
		[_grid({"columns": [[1.0, 1.0]]}), "no width"],
		[_grid({"columns": []}), "columns: none"],
		[_grid({"rows": {"*": {"sill": 0.35, "head": 3.2}}}), "does not fit"],
		[_grid({"rows": {"*": {"sill": -0.1, "head": 2.6}}}), "below its floor line"],
		[_grid({"rows": {"*": {"sill": 1.0, "head": 1.2}}}), "is under"],
		[_grid({"rows": {"0": {"sill": 0.35, "head": 2.6}}}), "no sill/head row"],
		[_grid({"rows": {"*": {"sill": 0.35, "head": 2.6}, "7": {"sill": 0.35, "head": 2.6}}}), "not a storey index"],
		[_grid({"groups": [[0, 1], [1, 2]]}), "overlaps the previous group"],
		[_grid({"groups": [[0, 3]]}), "storey range"],
		[_grid({"blank_cells": [[2, 0]]}), "blank_cells"],
		[_grid({"source": {"kind": "guess", "ref": "x", "date": "2025", "side": "wsw"}}), "kind"],
		[_grid({"source": {"kind": "rectified_photo", "ref": "x", "side": "wsw"}}), "date is missing"],
		[{"columns": [[1.0, 2.5]], "rows": {"*": {"sill": 0.35, "head": 2.6}}}, "source: missing"],
		[_grid({"source": {"kind": "inferred_from_side", "ref": "x", "date": "2025", "side": "wsw"}}), "inferred"],
	]
	for case: Array in cases:
		_expect(failures, _refused(case[0], case[1]), "accepted a grid that should fail with \"%s\"" % case[1])
	_expect(failures, _refused(_grid(), "span", TOP, {"span": [0.0, 5.0]}), "columns outside the face span accepted")
	_expect(failures, _refused(_grid(), "top", 16.0), "last storey without height accepted")
	_expect(failures, _refused(_grid(), "pier", TOP, {"min_pier": 2.0}), "min_pier option ignored")


static func _check_inherit(failures: Array) -> void:
	var grid := _grid()
	var inferred := GRID.inherit(grid, "ene")
	var source: Dictionary = inferred.source
	_expect(failures, source.kind == "inferred_from_side" and source.face == "ene" and source.side == "wsw" and source.ref == "test-photo" and source.truth_class == "production_inference", "inherited source")
	_expect(failures, grid.source.kind == "rectified_photo" and not (grid.source as Dictionary).has("face"), "inherit changed the photographed grid")
	_expect(failures, bool(GRID.validate(inferred, FLOORS, TOP).ok), "inherited grid refused")
	_expect(failures, GRID.expand(inferred, FLOORS) == GRID.expand(grid, FLOORS), "inherited grid expands differently")


static func _roles(rects: Array, role: String) -> Array:
	return rects.filter(func(r: Dictionary) -> bool: return r.role == role)


static func _check_assembly(failures: Array) -> void:
	var u := ASSEMBLY.unit(0.0, 2.0, 0.0, 2.5, {"split": 0.5, "transoms": [1.15], "lower_field": 0.45, "materials": {"frame": "frame_grey"}})
	_expect(failures, _roles(u, "pane").size() == 1 and _roles(u, "frame").size() == 4 and _roles(u, "lower_field").size() == 1
		and _roles(u, "transom").size() == 2 and _roles(u, "mullion").size() == 1, "unit members")
	for r: Dictionary in u:
		_expect(failures, r.u0 >= 0.0 and r.u1 <= 2.0 and r.y0 >= 0.0 and r.y1 <= 2.5 and r.d1 >= r.d0, "unit member outside its opening")
	_expect(failures, _roles(u, "frame")[0].material == "frame_grey" and _roles(u, "pane")[0].material == "pane", "role materials")
	var narrow := ASSEMBLY.unit(0.0, 1.0, 0.0, 2.5, {"split": 0.5})
	_expect(failures, _roles(narrow, "mullion").is_empty(), "split on a narrow unit")
	# A two-storey stack from the grid: two units and one spandrel; a surround outside it.
	var opening: Array = GRID.expand(_grid({"groups": [[0, 1], [2, 2]]}), FLOORS, {"style": {"surround": true}})[0]
	var s := ASSEMBLY.stack(opening)
	_expect(failures, _roles(s, "pane").size() == 2 and _roles(s, "spandrel").size() == 1 and _roles(s, "surround").size() == 4, "stack members")
	var spandrel: Dictionary = _roles(s, "spandrel")[0] if not _roles(s, "spandrel").is_empty() else {}
	_expect(failures, _near(float(spandrel.get("y0", 0.0)), 12.6) and _near(float(spandrel.get("y1", 0.0)), 13.35), "stack spandrel off the grid")
	# Curtain wall: every mullion runs the full field, head and sill rails close it.
	var c := ASSEMBLY.curtain(0.3, 5.0, 0.0, 6.0, {"pitch": 1.0, "floors": [3.0]})
	var mullions := _roles(c, "mullion")
	var centres := mullions.map(func(r: Dictionary) -> float: return (r.u0 + r.u1) * 0.5)
	centres.sort()
	_expect(failures, _near_list(centres, [0.3, 1.0, 2.0, 3.0, 4.0, 5.0]), "curtain mullions off the absolute pitch")
	for r: Dictionary in mullions:
		_expect(failures, _near(r.y0, 0.0) and _near(r.y1, 6.0), "curtain mullion ends free")
	var rails := _roles(c, "transom").map(func(r: Dictionary) -> float: return (r.y0 + r.y1) * 0.5)
	rails.sort()
	_expect(failures, _near_list(rails, [0.0, 2.65, 3.15, 6.0]) and _roles(c, "spandrel").size() == 1, "curtain rails or floor spandrel")
	var even := ASSEMBLY.curtain(0.0, 4.4, 0.0, 3.0, {"pitch": 1.1, "absolute": false})
	_expect(failures, _roles(even, "mullion").size() == 5, "evenly divided curtain")
	# Group: surround, divider between the lights, a unit per light per storey.
	var g := ASSEMBLY.group(0.0, 3.0, 0.0, 6.0, [[0.99, 3.0], [0.0, 0.85]], [[2.8, 3.2]])
	var divider: Array = _roles(g, "divider")
	_expect(failures, _roles(g, "surround").size() == 4 and divider.size() == 1 and _roles(g, "pane").size() == 4 and _roles(g, "spandrel").size() == 1, "group members")
	_expect(failures, divider.size() == 1 and _near(divider[0].u0, 0.85) and _near(divider[0].u1, 0.99), "group divider")
	var sill: Dictionary = ASSEMBLY.sill_band(1.0, 2.0, 10.0)[0]
	_expect(failures, _near(sill.u0, 0.9) and _near(sill.u1, 2.1) and _near(sill.y0, 9.88) and _near(sill.y1, 10.0) and _near(sill.d1, 0.1), "sill band")
	var head: Dictionary = ASSEMBLY.head_band(1.0, 2.0, 12.6)[0]
	_expect(failures, _near(head.y0, 12.6) and _near(head.y1, 12.72), "head band")
	var pier: Dictionary = ASSEMBLY.pilaster(5.0, 0.7, 4.0, 10.0, 0.35)[0]
	_expect(failures, _near(pier.u0, 4.65) and _near(pier.u1, 5.35) and pier.role == "pilaster" and _near(pier.d1, 0.35), "pilaster")
