extends RefCounted

## Window-assembly vocabulary shared by facade producers (pure static, producer-agnostic).
##
## Every helper returns {"ok": bool, "rects": Array, "errors": Array}. Invalid input
## (an empty or inverted extent, a non-positive pitch, depth or projection, overlapping
## or out-of-range group lights) gives ok false, no rects and the reasons.
##
## A rect is a material-tagged box in a face plane's coordinates:
##   {"role": String, "material": String, "u0", "u1", "y0", "y1", "d0", "d1": float}
## u along the face, y world height, d along the outward normal from the wall plane
## (negative is recessed).
##
## Depth rule: every rect is a box with d1 - d0 >= MIN_DEPTH_M. Members carry real
## depths (frames, mullions and transoms stand member_d in front of the pane; curtain
## members and spandrels stand d in front of their glazing plane base_d; panes are
## PANE_DEPTH_M thick behind their face). A member whose specified depth is thinner than
## MIN_DEPTH_M is thickened backwards from its face d1. Box emitters use d0..d1;
## flat-quad emitters draw the outward face at d1.
##
## Producers keep their own hole cutting, reveals, collision and emitters; these helpers
## only describe what sits in and around an opening.
##
## Roles: pane, frame, mullion, transom, lower_field, spandrel, surround, divider,
## pilaster, sill_band, head_band. spec.materials maps a role to the producer's
## material key (default: the role name).
##
## Generalised from Isle House (_opening, _curtain, _mullions: frame ring at the pane,
## split mullion, per-sill transoms, spandrels across joined floors, proud surround;
## curtain mullions on an absolute pitch with head/sill members and floor spandrels)
## and the Hawkins window-unit grammar (frame ring, opaque lower field, lower light,
## thick transom, main light; surrounded two-storey groups with a divider).
##
## unit spec (defaults in UNIT): pane_d (pane face depth), member_d (members stand this
## far in front of the pane), frame_w, mullion_w, transom_w, split (mullion position as a
## width fraction, used when the unit is wider than split_min_w), divisions (n equal
## lights; overrides split when > 1), transoms (bar heights above the unit bottom),
## lower_field (opaque field height above the bottom, 0 none, closed by a transom bar).

const MIN_DEPTH_M := 0.005
const PANE_DEPTH_M := 0.01
# Surround width a stack uses when its opening's style asks for "surround": true and
# the spec gives none (Isle House's proud black surround).
const STACK_SURROUND_W_M := 0.12
const UNIT := {
	"pane_d": -0.15, "member_d": 0.02, "frame_w": 0.07, "mullion_w": 0.084, "transom_w": 0.07,
	"split": 0.0, "split_min_w": 1.4, "divisions": 1, "transoms": [], "lower_field": 0.0,
}
const STACK := {"spandrel_d": 0.015, "surround_w": 0.0, "surround_d": 0.03}
const GROUP := {"surround_w": 0.22, "surround_d": 0.06, "spandrel_d": 0.08}
const CURTAIN := {
	"pitch": 1.25, "absolute": true, "base_d": 0.0, "d": 0.03, "mullion_w": 0.1, "rail_w": 0.12,
	"floors": [], "spandrel_below": 0.35, "spandrel_above": 0.15, "floor_rail_w": 0.07,
	"floor_margin": 0.2, "transoms": [],
}


# One window unit within one storey [u0, u1] x [y0, y1]: pane, frame ring, optional
# opaque lower field, transoms and mullions.
static func unit(u0: float, u1: float, y0: float, y1: float, spec: Dictionary = {}) -> Dictionary:
	var errors := _extent_errors("unit", u0, u1, y0, y1)
	var s := _spec(UNIT, spec)
	if int(s.divisions) < 1:
		errors.append("unit: divisions must be at least 1")
	if not errors.is_empty():
		return _result([], errors)
	var out := []
	var pane := float(s.pane_d)
	var front := pane + float(s.member_d)
	var w := float(s.frame_w)
	_rect(out, s, "pane", u0, u1, y0, y1, pane - PANE_DEPTH_M, pane)
	for bar: Array in [[u0, u0 + w, y0, y1], [u1 - w, u1, y0, y1], [u0, u1, y0, y0 + w], [u0, u1, y1 - w, y1]]:
		_rect(out, s, "frame", bar[0], bar[1], bar[2], bar[3], pane, front)
	var tw := float(s.transom_w)
	var field := float(s.lower_field)
	if field > 0.0:
		_rect(out, s, "lower_field", u0 + w, u1 - w, y0 + w, y0 + field, pane, lerpf(pane, front, 0.8))
		_rect(out, s, "transom", u0, u1, y0 + field - tw * 0.5, y0 + field + tw * 0.5, pane, front)
	for value: Variant in s.transoms:
		var t := float(value)
		_rect(out, s, "transom", u0, u1, y0 + t - tw * 0.5, y0 + t + tw * 0.5, pane, front)
	var mw := float(s.mullion_w)
	var divisions := int(s.divisions)
	if divisions > 1:
		for k in range(1, divisions):
			var mu := lerpf(u0, u1, float(k) / float(divisions))
			_rect(out, s, "mullion", mu - mw * 0.5, mu + mw * 0.5, y0, y1, pane, front)
	elif float(s.split) > 0.0 and u1 - u0 > float(s.split_min_w):
		var mu := lerpf(u0, u1, float(s.split))
		_rect(out, s, "mullion", mu - mw * 0.5, mu + mw * 0.5, y0, y1, pane, front)
	return _result(out, [])


# A unit spanning floors: one opening [u0, u1, y0, y1, extras] in the facade_grid
# format, a unit per storey between its spandrels, a spandrel panel across each band,
# and an optional proud surround (spec.surround_w > 0) on the wall plane. Style keys in
# the opening's extras override spec: "split", "transom" (a bar this far above each
# sill), "surround" (STACK_SURROUND_W_M when spec gives no width) and "pane" (the pane
# material).
static func stack(opening: Array, spec: Dictionary = {}) -> Dictionary:
	if opening.size() < 4:
		return _result([], ["stack: opening is not [u0, u1, y0, y1, extras]"])
	var extras: Dictionary = opening[4] if opening.size() > 4 and opening[4] is Dictionary else {}
	var s := _spec(STACK, spec)
	if extras.has("split"):
		s["split"] = float(extras.split)
	if float(extras.get("transom", 0.0)) > 0.0:
		s["transoms"] = [float(extras.transom)]
	if bool(extras.get("surround", false)) and float(s.surround_w) <= 0.0:
		s["surround_w"] = STACK_SURROUND_W_M
	if extras.has("pane"):
		var materials: Dictionary = (s.get("materials", {}) as Dictionary).duplicate()
		materials["pane"] = str(extras.pane)
		s["materials"] = materials
	var u0 := float(opening[0])
	var u1 := float(opening[1])
	var y0 := float(opening[2])
	var y1 := float(opening[3])
	var errors := _extent_errors("stack", u0, u1, y0, y1)
	if not errors.is_empty():
		return _result([], errors)
	var out := []
	var bottom := y0
	var pane := float(_spec(UNIT, s).pane_d)
	var storeys := []
	for band: Array in extras.get("spandrels", []):
		storeys.append([bottom, float(band[0])])
		_rect(out, s, "spandrel", u0, u1, float(band[0]), float(band[1]), pane, pane + float(s.spandrel_d))
		bottom = float(band[1])
	storeys.append([bottom, y1])
	for storey: Array in storeys:
		var part := unit(u0, u1, float(storey[0]), float(storey[1]), s)
		if not bool(part.ok):
			return _result([], part.errors)
		out.append_array(part.rects)
	out.append_array(_surround(s, u0, u1, y0, y1, float(s.surround_w), 0.0, float(s.surround_d)))
	return _result(out, [])


# Several lights under one surround [u0, u1] x [y0, y1] (a Hawkins box group):
# `lights` are [a, b] u ranges inside it, `bands` spandrel [y_lo, y_hi] ranges across
# it; divider panels fill every part of [u0, u1] outside the lights (between them and
# at both ends), and a unit fills each light per storey.
static func group(u0: float, u1: float, y0: float, y1: float, lights: Array, bands: Array = [], spec: Dictionary = {}) -> Dictionary:
	var errors := _extent_errors("group", u0, u1, y0, y1)
	var sorted := lights.duplicate()
	sorted.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	var edge := u0
	for light: Array in sorted:
		if float(light[1]) <= float(light[0]):
			errors.append("group: light %s has no width" % str(light))
		if float(light[0]) < edge - 0.0001 or float(light[1]) > u1 + 0.0001:
			errors.append("group: light %s overlaps another light or leaves [%.3f, %.3f]" % [str(light), u0, u1])
		edge = maxf(edge, float(light[1]))
	if sorted.is_empty():
		errors.append("group: no lights")
	if not errors.is_empty():
		return _result([], errors)
	var s := _spec(GROUP, spec)
	var out := _surround(s, u0, u1, y0, y1, float(s.surround_w), 0.0, float(s.surround_d))
	var pane := float(_spec(UNIT, s).pane_d)
	var front := pane + float(s.spandrel_d)
	for band: Array in bands:
		_rect(out, s, "spandrel", u0, u1, float(band[0]), float(band[1]), pane, front)
	var gaps := [u0]
	for light: Array in sorted:
		gaps.append_array([float(light[0]), float(light[1])])
	gaps.append(u1)
	for i in range(0, gaps.size(), 2):
		_rect(out, s, "divider", float(gaps[i]), float(gaps[i + 1]), y0, y1, pane, front)
	var storeys := []
	var bottom := y0
	for band: Array in bands:
		storeys.append([bottom, float(band[0])])
		bottom = float(band[1])
	storeys.append([bottom, y1])
	for light: Array in sorted:
		for storey: Array in storeys:
			var part := unit(float(light[0]), float(light[1]), float(storey[0]), float(storey[1]), s)
			if not bool(part.ok):
				return _result([], part.errors)
			out.append_array(part.rects)
	return _result(out, [])


# Curtain wall over [u0, u1] x [y0, y1]: mullions on a pitch (multiples of the pitch
# when spec.absolute, else evenly divided) including both jambs, head and sill rails so
# no member ends free, and per floor line inside the field a spandrel band with rails.
# Members stand from base_d (the glazing plane) to base_d + d.
static func curtain(u0: float, u1: float, y0: float, y1: float, spec: Dictionary = {}) -> Dictionary:
	var errors := _extent_errors("curtain", u0, u1, y0, y1)
	var s := _spec(CURTAIN, spec)
	var pitch := float(s.pitch)
	if not pitch > 0.0:
		errors.append("curtain: pitch %s must be positive" % str(s.pitch))
	if not float(s.d) > 0.0:
		errors.append("curtain: member depth d must be positive")
	if not errors.is_empty():
		return _result([], errors)
	var out := []
	var d0 := float(s.base_d)
	var d1 := d0 + float(s.d)
	var us := [u0, u1]
	if bool(s.absolute):
		var k := ceili(u0 / pitch)
		while float(k) * pitch < u1 - 0.05:
			if float(k) * pitch > u0 + 0.05:
				us.append(float(k) * pitch)
			k += 1
	else:
		var count := maxi(1, roundi((u1 - u0) / pitch))
		for k in range(1, count):
			us.append(lerpf(u0, u1, float(k) / float(count)))
	var mw := float(s.mullion_w) * 0.5
	for u: float in us:
		_rect(out, s, "mullion", u - mw, u + mw, y0, y1, d0, d1)
	var rw := float(s.rail_w) * 0.5
	for y: float in [y0, y1]:
		_rect(out, s, "transom", u0, u1, y - rw, y + rw, d0, d1)
	for value: Variant in s.transoms:
		var y := float(value)
		if y > y0 + rw and y < y1 - rw:
			_rect(out, s, "transom", u0, u1, y - rw, y + rw, d0, d1)
	var margin := float(s.floor_margin)
	var below := float(s.spandrel_below)
	var above := float(s.spandrel_above)
	var fr := float(s.floor_rail_w)
	for value: Variant in s.floors:
		var floor := float(value)
		if floor > y0 + margin and floor < y1 - margin:
			_rect(out, s, "spandrel", u0, u1, floor - below, floor + above, d0, d1 - 0.005)
			_rect(out, s, "transom", u0, u1, floor - below - fr * 0.5, floor - below + fr * 0.5, d0, d1)
			_rect(out, s, "transom", u0, u1, floor + above - fr * 0.5, floor + above + fr * 0.5, d0, d1)
	return _result(out, [])


# A proud vertical pier centred on u, `depth` out from the wall plane.
static func pilaster(u: float, width: float, y0: float, y1: float, depth: float, spec: Dictionary = {}) -> Dictionary:
	var errors := _extent_errors("pilaster", u - width * 0.5, u + width * 0.5, y0, y1)
	if not depth > 0.0:
		errors.append("pilaster: depth must be positive")
	if not errors.is_empty():
		return _result([], errors)
	var out := []
	_rect(out, spec, "pilaster", u - width * 0.5, u + width * 0.5, y0, y1, 0.0, depth)
	return _result(out, [])


# A projecting sill under an opening's sill line y: `height` tall, `overhang` past each
# jamb, `projection` out from the wall plane.
static func sill_band(u0: float, u1: float, y: float, height: float = 0.12, projection: float = 0.1, overhang: float = 0.1, spec: Dictionary = {}) -> Dictionary:
	return _band("sill_band", u0 - overhang, u1 + overhang, y - height, y, projection, spec)


# A projecting head band over an opening's head line y.
static func head_band(u0: float, u1: float, y: float, height: float = 0.12, projection: float = 0.1, overhang: float = 0.1, spec: Dictionary = {}) -> Dictionary:
	return _band("head_band", u0 - overhang, u1 + overhang, y, y + height, projection, spec)


static func _band(role: String, u0: float, u1: float, y0: float, y1: float, projection: float, spec: Dictionary) -> Dictionary:
	var errors := _extent_errors(role, u0, u1, y0, y1)
	if not projection > 0.0:
		errors.append("%s: projection must be positive" % role)
	if not errors.is_empty():
		return _result([], errors)
	var out := []
	_rect(out, spec, role, u0, u1, y0, y1, 0.0, projection)
	return _result(out, [])


# A ring `width` wide around [u0, u1] x [y0, y1] on the wall plane; the jambs run over
# the corners, the head and sill pieces stay between them.
static func _surround(spec: Dictionary, u0: float, u1: float, y0: float, y1: float, width: float, d0: float, d1: float) -> Array:
	var out := []
	if width <= 0.0:
		return out
	for r: Array in [[u0 - width, u0, y0 - width, y1 + width], [u1, u1 + width, y0 - width, y1 + width], [u0, u1, y0 - width, y0], [u0, u1, y1, y1 + width]]:
		_rect(out, spec, "surround", r[0], r[1], r[2], r[3], d0, d1)
	return out


static func _extent_errors(label: String, u0: float, u1: float, y0: float, y1: float) -> Array:
	var errors := []
	for v: float in [u0, u1, y0, y1]:
		if not is_finite(v):
			errors.append("%s: extent is not finite" % label)
			return errors
	if u1 <= u0 or y1 <= y0:
		errors.append("%s: extent [%.3f, %.3f] x [%.3f, %.3f] is empty or inverted" % [label, u0, u1, y0, y1])
	return errors


static func _result(rects: Array, errors: Array) -> Dictionary:
	return {"ok": errors.is_empty(), "rects": rects, "errors": errors}


static func _spec(defaults: Dictionary, spec: Dictionary) -> Dictionary:
	var s := defaults.duplicate(true)
	s.merge(spec, true)
	return s


# Appends a box, skipping slivers; a box thinner than MIN_DEPTH_M is thickened
# backwards from its face d1 (the depth rule above).
static func _rect(out: Array, spec: Dictionary, role: String, u0: float, u1: float, y0: float, y1: float, d0: float, d1: float) -> void:
	if u1 - u0 <= 0.005 or y1 - y0 <= 0.005:
		return
	var materials: Dictionary = spec.get("materials", {})
	var face := maxf(d0, d1)
	var back := minf(minf(d0, d1), face - MIN_DEPTH_M)
	out.append({"role": role, "material": str(materials.get(role, role)), "u0": u0, "u1": u1, "y0": y0, "y1": y1, "d0": back, "d1": face})
