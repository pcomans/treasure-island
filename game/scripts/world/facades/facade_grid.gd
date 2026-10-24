extends RefCounted

## Photo-derived structural window grids for facade producers (shared, pure static).
##
## A grid describes one face's openings in that face's plane coordinates: u along the
## face (metres), y world height. Producers supply the floor lines; the grid's rows are
## relative to them, so floor heads stay where the storeys put them.
##
##   {
##     "columns": [[u0, u1], ...]                  # sorted window columns, or
##                {"pitch": p, "first": u, "count": n, "width": w},
##     "rows": {"0": {"sill": s, "head": h}, ...}  # per storey index, relative to its
##                                                 # floor line; "*" is the default row
##     "groups": [[k0, k1], ...]                   # optional: storeys joined into one
##                                                 # opening with spandrels; when given
##                                                 # they must tile storeys 0..n-1 in
##                                                 # order (default: every storey alone)
##     "blank_cells": [[column, storey], ...]      # optional: cells left solid; the only
##                                                 # way to leave a cell without a window
##     "source": {"kind": "rectified_photo" | "inferred_from_side",
##                "ref": photo id, "date": photo date, "side": photographed side,
##                "face": face it is applied to (inferred_from_side only)}
##   }
##
## validate() fails closed: unsorted or overlapping columns, piers thinner than the
## minimum, non-numeric or non-finite numbers, non-integral indices or counts (JSON
## integral floats such as 2.0 are accepted), rows that do not fit their storey, groups
## that do not tile the storeys, and malformed blank cells or source. Nothing is coerced.
##
## expand() validates first and returns {"ok", "openings", "errors"}. Openings are in the
## stacks() format: [u0, u1, y0, y1, extras], extras = style + {"spandrels": [[y_lo,
## y_hi], ...], "sills": [y, ...]} (+ "sill_raised": true when the ground sill rose).
##
## Ground sills (building-texture skill, sloped ground): given options.ground (a height,
## or a Callable(u0, u1) -> the highest ground under that column), the ground-floor
## (storey 0) sill rises to ground + ground_clearance where it is lower; its head stays
## fixed, and a storey 0 left with less than min_light of light is dropped. Higher
## storeys are never raised or dropped by the ground.
## Unphotographed faces take a photographed face's grid through inherit(), which marks
## the copy inferred_from_side (production_inference).

const SOURCE_KINDS := ["rectified_photo", "inferred_from_side"]
const DEFAULT_ROW := "*"
const MIN_PIER_M := 0.1
# Least light left in an opening; validate() and expand() read it from the same options.
const MIN_LIGHT_M := 0.3
const GROUND_CLEARANCE_M := 0.15
# A sill counts as raised only when it moved more than this.
const RAISE_EPSILON_M := 0.000001


# Floor lines from `first`, `count` storeys `pitch` apart.
static func floor_lines(first: float, count: int, pitch: float) -> Array:
	var floors := []
	for k in count:
		floors.append(first + pitch * float(k))
	return floors


# Window assemblies: per column, each floor group [k0, k1] becomes one opening from
# floors[k0]+sill to floors[k1]+head, with spandrels across the floor lines inside it,
# so connected floors read as one framed stack. `style` is copied into each opening's
# extras (for Isle House: "split" mullion position as a width fraction, "transom" a bar
# this far above each floor's sill, "surround" a proud frame, "pane" a material key).
static func stacks(columns: Array, floors: Array, groups: Array = [], sill: float = 0.35, head: float = 2.6, style: Dictionary = {}) -> Array:
	var openings := []
	var floor_groups := groups.duplicate()
	if floor_groups.is_empty():
		for k in floors.size():
			floor_groups.append([k, k])
	for column: Array in columns:
		for group: Array in floor_groups:
			var k0 := int(group[0])
			var k1 := mini(int(group[-1]), floors.size() - 1)
			if k0 >= floors.size() or k1 < k0:
				continue
			var spandrels := []
			var sills := [float(floors[k0]) + sill]
			for k in range(k0 + 1, k1 + 1):
				spandrels.append([float(floors[k - 1]) + head, float(floors[k]) + sill])
				sills.append(float(floors[k]) + sill)
			var extras := style.duplicate()
			extras["spandrels"] = spandrels
			extras["sills"] = sills
			openings.append([float(column[0]), float(column[1]), float(floors[k0]) + sill, float(floors[k1]) + head, extras])
	return openings


# ---------------------------------------------------------------- cut-line helpers
# For producers that cut wall rectangles around openings on a grid of cut lines.

# Sorts `values` in place and returns them without near-duplicates (within 1 mm).
static func unique_sorted(values: Array) -> Array:
	values.sort()
	var out := []
	for v: float in values:
		if out.is_empty() or v - float(out[-1]) > 0.001:
			out.append(v)
	return out


# True when (u, y) lies strictly inside one of the [u0, u1, y0, y1, ...] openings.
static func in_opening(openings: Array, u: float, y: float) -> bool:
	for o: Array in openings:
		if u > float(o[0]) and u < float(o[1]) and y > float(o[2]) and y < float(o[3]):
			return true
	return false


# ---------------------------------------------------------------- grids

# The grid's columns as [[u0, u1], ...] (a pitch description expanded). Validate first:
# malformed entries are skipped here, not repaired.
static func columns(grid: Dictionary) -> Array:
	var value: Variant = grid.get("columns", [])
	var out := []
	if value is Dictionary:
		if not (_is_number(value.get("pitch")) and _is_number(value.get("first")) and _is_number(value.get("width")) and _is_index(value.get("count"))):
			return out
		var pitch := float(value["pitch"])
		var first := float(value["first"])
		var width := float(value["width"])
		for k in int(value["count"]):
			var u := first + pitch * float(k)
			out.append([u, u + width])
	elif value is Array:
		for column: Variant in value:
			if column is Array and (column as Array).size() == 2 and _is_number(column[0]) and _is_number(column[1]):
				out.append([float(column[0]), float(column[1])])
	return out


# The row (sill, head relative to the floor line) for storey k, or {} if none.
static func row(grid: Dictionary, k: int) -> Dictionary:
	var rows: Variant = grid.get("rows", {})
	if not rows is Dictionary:
		return {}
	var value: Variant = rows.get(str(k), rows.get(DEFAULT_ROW, {}))
	return value if value is Dictionary else {}


# A photographed face's grid applied to another (unphotographed) face.
static func inherit(grid: Dictionary, face: String) -> Dictionary:
	var copy := grid.duplicate(true)
	var source: Dictionary = (grid.get("source", {}) as Dictionary).duplicate(true)
	source["kind"] = "inferred_from_side"
	source["face"] = face
	source["truth_class"] = "production_inference"
	copy["source"] = source
	return copy


# Checks a grid against the producer's floor lines and the top of the wall it sits on
# (the last storey ends there). options: min_pier, min_light, span [u0, u1] the face
# extent the columns must stay inside. Returns {"ok": bool, "errors": [...]}.
static func validate(grid: Dictionary, floors: Array, top: float, options: Dictionary = {}) -> Dictionary:
	var errors := []
	var min_pier := float(options.get("min_pier", MIN_PIER_M))
	var min_light := float(options.get("min_light", MIN_LIGHT_M))
	_validate_columns(grid, min_pier, options.get("span", []), errors)
	var storeys := floors.size()
	var floors_ok := storeys > 0
	if storeys == 0:
		errors.append("floors: no floor lines")
	for k in storeys:
		if not _is_number(floors[k]):
			errors.append("floors: floor line %d is not a finite number" % k)
			floors_ok = false
		elif k > 0 and _is_number(floors[k - 1]) and float(floors[k]) <= float(floors[k - 1]):
			errors.append("floors: floor line %d is not above floor line %d" % [k, k - 1])
	if not is_finite(top):
		errors.append("floors: top is not a finite number")
		floors_ok = false
	elif floors_ok and top <= float(floors[-1]):
		errors.append("floors: top %.3f is not above the last floor line" % top)
	var rows: Variant = grid.get("rows", null)
	if not rows is Dictionary:
		errors.append("rows: missing")
		rows = {}
	for key: Variant in rows:
		var text := str(key)
		if text != DEFAULT_ROW and (not text.is_valid_int() or int(text) < 0 or int(text) >= storeys):
			errors.append("rows: key %s is not a storey index or \"%s\"" % [text, DEFAULT_ROW])
	for k in storeys:
		var r := row(grid, k)
		if r.is_empty() or not _is_number(r.get("sill")) or not _is_number(r.get("head")):
			errors.append("rows: storey %d has no numeric sill/head row" % k)
			continue
		if not floors_ok:
			continue
		var height := (float(floors[k + 1]) if k + 1 < storeys else top) - float(floors[k])
		var sill := float(r.sill)
		var head := float(r.head)
		if sill < 0.0:
			errors.append("rows: storey %d sill %.3f is below its floor line" % [k, sill])
		if head > height + 0.0001:
			errors.append("rows: storey %d head %.3f does not fit the %.3f m storey" % [k, head, height])
		if head - sill < min_light:
			errors.append("rows: storey %d sill %.3f to head %.3f is under %.2f m" % [k, sill, head, min_light])
	_validate_groups(grid.get("groups", []), storeys, errors)
	var count := columns(grid).size()
	var blanks: Variant = grid.get("blank_cells", [])
	if not blanks is Array:
		errors.append("blank_cells: not a list")
		blanks = []
	for cell: Variant in blanks:
		if not cell is Array or (cell as Array).size() != 2 or not _is_index(cell[0]) or not _is_index(cell[1]) \
				or int(cell[0]) >= count or int(cell[1]) >= storeys:
			errors.append("blank_cells: %s is not a [column, storey] cell of this grid" % str(cell))
	_validate_source(grid.get("source", null), errors)
	return {"ok": errors.is_empty(), "errors": errors}


# A finite int or float (bool and strings are not numbers).
static func _is_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))


# A non-negative integral number (2 or 2.0, not 2.5 or "2").
static func _is_index(value: Variant) -> bool:
	return _is_number(value) and float(value) >= 0.0 and float(value) == floorf(float(value))


static func _validate_groups(groups: Variant, storeys: int, errors: Array) -> void:
	if not groups is Array:
		errors.append("groups: not a list")
		return
	if (groups as Array).is_empty():
		return
	var next := 0
	for group: Variant in groups:
		if not group is Array or (group as Array).size() != 2 or not _is_index(group[0]) or not _is_index(group[1]):
			errors.append("groups: %s is not [k0, k1] storey indices" % str(group))
			return
		var k0 := int(group[0])
		var k1 := int(group[1])
		if k1 < k0 or k1 >= storeys:
			errors.append("groups: [%d, %d] is not a storey range" % [k0, k1])
			return
		if k0 != next:
			errors.append("groups: [%d, %d] does not continue from storey %d; groups must tile storeys 0..%d (use blank_cells for exceptions)" % [k0, k1, next, storeys - 1])
			return
		next = k1 + 1
	if next != storeys:
		errors.append("groups: storeys %d..%d are in no group; groups must tile storeys 0..%d (use blank_cells for exceptions)" % [next, storeys - 1, storeys - 1])


static func _validate_columns(grid: Dictionary, min_pier: float, span: Variant, errors: Array) -> void:
	var value: Variant = grid.get("columns", null)
	var shape_ok := true
	if value is Dictionary:
		for key: String in ["pitch", "first", "width"]:
			if not _is_number(value.get(key)):
				errors.append("columns: pitch form needs a numeric %s" % key)
				shape_ok = false
		if not _is_index(value.get("count")) or int(value.get("count", 0)) < 1:
			errors.append("columns: pitch form needs an integral count of at least 1")
			shape_ok = false
		if shape_ok:
			if float(value["width"]) <= 0.0:
				errors.append("columns: width must be positive")
			if int(value["count"]) > 1 and float(value["pitch"]) - float(value["width"]) < min_pier:
				errors.append("columns: pier %.3f (pitch - width) is under %.3f m" % [float(value["pitch"]) - float(value["width"]), min_pier])
	elif value is Array:
		for column: Variant in value:
			if not column is Array or (column as Array).size() != 2 or not _is_number(column[0]) or not _is_number(column[1]):
				errors.append("columns: %s is not [u0, u1] numbers" % str(column))
				shape_ok = false
	else:
		errors.append("columns: missing")
		shape_ok = false
	if not shape_ok:
		return
	var cols := columns(grid)
	if cols.is_empty():
		errors.append("columns: none")
	for i in cols.size():
		var u0 := float(cols[i][0])
		var u1 := float(cols[i][1])
		if u1 <= u0:
			errors.append("columns: column %d [%.3f, %.3f] has no width" % [i, u0, u1])
		if i == 0:
			continue
		var p0 := float(cols[i - 1][0])
		var p1 := float(cols[i - 1][1])
		if u0 < p0:
			errors.append("columns: column %d starts before column %d (unsorted)" % [i, i - 1])
		elif u0 < p1:
			errors.append("columns: column %d overlaps column %d" % [i, i - 1])
		elif u0 - p1 < min_pier:
			errors.append("columns: pier %.3f between columns %d and %d is under %.3f m" % [u0 - p1, i - 1, i, min_pier])
	if span is Array and (span as Array).size() == 2 and not cols.is_empty():
		if float(cols[0][0]) < float(span[0]) or float(cols[-1][1]) > float(span[1]):
			errors.append("columns: columns leave the face span [%.3f, %.3f]" % [float(span[0]), float(span[1])])


static func _validate_source(source: Variant, errors: Array) -> void:
	if not source is Dictionary:
		errors.append("source: missing")
		return
	var kind := str(source.get("kind", ""))
	if kind not in SOURCE_KINDS:
		errors.append("source: kind %s is not one of %s" % [kind, str(SOURCE_KINDS)])
	for key: String in ["ref", "date", "side"]:
		if not source.get(key) is String or str(source.get(key)) == "":
			errors.append("source: %s is missing" % key)
	if kind == "inferred_from_side" and (str(source.get("face", "")) == "" or str(source.get("face", "")) == str(source.get("side", ""))):
		errors.append("source: an inferred grid needs the face it is applied to, other than the photographed side")


# Validates the grid (with the same options) and returns {"ok", "openings", "errors"};
# an invalid grid gives ok false, no openings and validate()'s errors.
# options: style (copied into extras), ground (height or Callable(u0, u1) -> height),
# ground_clearance, min_light, and validate()'s min_pier and span.
static func expand(grid: Dictionary, floors: Array, top: float, options: Dictionary = {}) -> Dictionary:
	var check := validate(grid, floors, top, options)
	if not bool(check.ok):
		return {"ok": false, "openings": [], "errors": check.errors}
	var style: Dictionary = options.get("style", {})
	var ground: Variant = options.get("ground", null)
	var clearance := float(options.get("ground_clearance", GROUND_CLEARANCE_M))
	var min_light := float(options.get("min_light", MIN_LIGHT_M))
	if ground != null and not ground is Callable and not _is_number(ground):
		return {"ok": false, "openings": [], "errors": ["options: ground is neither a number nor a Callable"]}
	var groups: Array = (grid.get("groups", []) as Array).duplicate()
	if groups.is_empty():
		for k in floors.size():
			groups.append([k, k])
	var blanks := {}
	for cell: Array in grid.get("blank_cells", []):
		blanks["%d:%d" % [int(cell[0]), int(cell[1])]] = true
	var cols := columns(grid)
	var openings := []
	for c in cols.size():
		var u0 := float(cols[c][0])
		var u1 := float(cols[c][1])
		var lowest := -INF
		if ground is Callable:
			var g: Variant = (ground as Callable).call(u0, u1)
			if not _is_number(g):
				return {"ok": false, "openings": [], "errors": ["options: ground(%.3f, %.3f) did not return a finite number" % [u0, u1]]}
			lowest = float(g) + clearance
		elif ground != null:
			lowest = float(ground) + clearance
		for group: Array in groups:
			var run := []
			for k in range(int(group[0]), int(group[1]) + 1):
				var r := row(grid, k)
				var sill := float(floors[k]) + float(r.sill)
				var head := float(floors[k]) + float(r.head)
				# Only the ground-floor sill follows the ground.
				var raised := maxf(sill, lowest) if k == 0 else sill
				if blanks.has("%d:%d" % [c, k]) or head - raised < min_light:
					_flush(run, u0, u1, style, openings)
					run = []
					continue
				run.append([raised, head, raised > sill + RAISE_EPSILON_M])
			_flush(run, u0, u1, style, openings)
	return {"ok": true, "openings": openings, "errors": []}


static func _flush(run: Array, u0: float, u1: float, style: Dictionary, openings: Array) -> void:
	if run.is_empty():
		return
	var spandrels := []
	var sills := []
	var raised := false
	for i in run.size():
		sills.append(float(run[i][0]))
		raised = raised or bool(run[i][2])
		if i > 0:
			spandrels.append([float(run[i - 1][1]), float(run[i][0])])
	var extras := style.duplicate()
	extras["spandrels"] = spandrels
	extras["sills"] = sills
	if raised:
		extras["sill_raised"] = true
	openings.append([u0, u1, float(run[0][0]), float(run[-1][1]), extras])
