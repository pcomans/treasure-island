extends RefCounted

## Procedural wall-mounted equipment shared by facade producers (pure static,
## producer-agnostic): a telecom antenna cluster on pipe mounts and a sheet-metal duct
## with a gooseneck hood, laid out by rule from a few numbers in the config.
##
## Every helper returns {"ok": bool, "boxes": Array, "errors": Array}. A box is
## {"role": String, "u0", "u1", "y0", "y1", "d0", "d1": float} in a wall's own frame:
## u along the wall (metres), y height (the producer's metres) and d out from the wall
## plane (0 on the wall, positive outward, d0 < d1). Producers map each role to a
## material, emit the boxes and own their collision. The same spec always gives the
## same boxes: placement varies only with the spec's "seed".
##
## antenna_cluster(spec): mounts spread evenly over "s": [u0, u1], panel antennas
## (or cabinets) topping out near y1 of "y": [y0, y1], radios under them, cable
## drops and, with "signs", small warning signs on the wall near y0.
##   "mounts" 2-12 (default 4), "standoff" 0.2-1 m (default 0.45: pipes stand that far
##   out), "cabinets" (every k-th mount carries a cabinet instead of a panel; 0 none),
##   "signs" (default true), "seed" (an integer).
##   Roles: pipe, bracket, panel, cabinet, radio, cable, sign.
## duct(spec): a shaft "s": [u0, u1] wide from y0 up to y1 of "y", "depth" out from the
## wall (0.1-1 m, default 0.35), turning at the top into a gooseneck that runs along
## the wall to station "hood_to" and ends in a hood; "conduits" (0-4) thin conduits
## beside the shaft on the gooseneck's side, and straps every "strap_every" metres
## (default 1.5; 0 none).
##   Roles: duct, hood, conduit, strap.

const ROLES := ["pipe", "bracket", "panel", "cabinet", "radio", "cable", "sign", "duct", "hood", "conduit", "strap"]
## Palette keys a producer may use when a spec gives no "materials" of its own.
const DEFAULT_MATERIALS := {
	"pipe": "rail", "bracket": "rail", "panel": "mech", "cabinet": "mech", "radio": "metal",
	"cable": "metal", "sign": "frame_light", "duct": "rail", "hood": "roof_brown",
	"conduit": "metal", "strap": "rail",
}
const PIPE_W_M := 0.08
const CABLE_W_M := 0.03
const MIN_DEPTH_M := 0.01


static func antenna_cluster(spec: Dictionary) -> Dictionary:
	var errors := []
	var s: Array = spec.get("s", [])
	var y: Array = spec.get("y", [])
	var mounts := int(spec.get("mounts", 4))
	var standoff := float(spec.get("standoff", 0.45))
	var cabinets := int(spec.get("cabinets", 0))
	if s.size() != 2 or y.size() != 2 or not _finite(s + y) or float(s[1]) - float(s[0]) < 0.5 or float(y[1]) - float(y[0]) < 1.5:
		errors.append("antenna_cluster needs s [u0, u1] at least 0.5 m wide and y [y0, y1] at least 1.5 m tall")
	if mounts < 2 or mounts > 12:
		errors.append("antenna_cluster mounts must be 2-12")
	if not (standoff >= 0.2 and standoff <= 1.0):
		errors.append("antenna_cluster standoff must be 0.2-1 m")
	if cabinets < 0:
		errors.append("antenna_cluster cabinets must be 0 or more")
	if not errors.is_empty():
		return _result([], errors)
	var u0 := float(s[0])
	var u1 := float(s[1])
	var y0 := float(y[0])
	var y1 := float(y[1])
	var rng := _Rng.new(int(spec.get("seed", 0)))
	var out := []
	var pitch := (u1 - u0) / float(mounts)
	for i in mounts:
		var c := u0 + pitch * (float(i) + 0.5) + pitch * 0.15 * rng.signed()
		var cabinet := cabinets > 0 and (i + 1) % cabinets == 0
		# The pipe rises a little over the gear it carries; two brackets tie it to the wall.
		var pipe_top := y1 + 0.2 + 0.25 * rng.unit()
		var pipe_bottom := y0 + 0.5 + 0.4 * rng.unit()
		_box(out, "pipe", c - PIPE_W_M * 0.5, c + PIPE_W_M * 0.5, pipe_bottom, pipe_top, standoff - PIPE_W_M * 0.5, standoff + PIPE_W_M * 0.5)
		for at: float in [pipe_top - 0.25, pipe_bottom + 0.3]:
			_box(out, "bracket", c - 0.03, c + 0.03, at - 0.03, at + 0.03, 0.0, standoff)
		var front := standoff + PIPE_W_M * 0.5
		var width: float
		var height: float
		var top := y1 - 0.25 * rng.unit()
		var role := "cabinet" if cabinet else "panel"
		if cabinet:
			width = lerpf(0.35, 0.55, rng.unit())
			height = lerpf(0.6, 0.95, rng.unit())
		else:
			width = lerpf(0.26, 0.6, rng.unit())
			height = lerpf(1.2, 1.9, rng.unit())
		height = minf(height, (top - y0) * 0.6)
		var depth := lerpf(0.12, 0.24, rng.unit())
		var side := rng.signed() * pitch * 0.12
		var g0 := c + side - width * 0.5
		var g1 := c + side + width * 0.5
		var gear_bottom := top - height
		_box(out, role, g0, g1, gear_bottom, top, front, front + depth)
		# One or two radios below, each a little off the gear's centre line.
		var cursor := gear_bottom - lerpf(0.08, 0.3, rng.unit())
		var radios := 1 + int(rng.unit() > 0.5)
		var lowest := cursor
		for r in radios:
			var rh := lerpf(0.32, 0.55, rng.unit())
			if cursor - rh < y0 + 0.25:
				break
			var rw := lerpf(0.24, 0.4, rng.unit())
			var rc := c + rng.signed() * pitch * 0.15
			_box(out, "radio", rc - rw * 0.5, rc + rw * 0.5, cursor - rh, cursor, front, front + lerpf(0.12, 0.2, rng.unit()))
			# Cable tails hang below each radio.
			for t in 2 + int(rng.unit() * 2.0):
				var tc := rc - rw * 0.35 + rw * 0.7 * rng.unit()
				_box(out, "cable", tc - CABLE_W_M * 0.5, tc + CABLE_W_M * 0.5, cursor - rh - lerpf(0.15, 0.45, rng.unit()), cursor - rh, front + 0.02, front + 0.02 + CABLE_W_M)
			lowest = cursor - rh
			cursor -= rh + lerpf(0.1, 0.3, rng.unit())
		# Jumper cables from the gear down past the radios, close to the wall.
		for t in 2:
			var jc := g0 + (g1 - g0) * (0.25 + 0.5 * float(t)) + 0.05 * rng.signed()
			_box(out, "cable", jc - CABLE_W_M * 0.5, jc + CABLE_W_M * 0.5, maxf(y0 + 0.3, lowest - 0.2), gear_bottom, standoff - 0.12, standoff - 0.12 + CABLE_W_M)
		if bool(spec.get("signs", true)) and i % 2 == 0:
			var sc := c + 0.1 * rng.signed()
			_box(out, "sign", sc - 0.08, sc + 0.08, y0, y0 + 0.2, 0.0, MIN_DEPTH_M)
	return _result(out, [])


static func duct(spec: Dictionary) -> Dictionary:
	var errors := []
	var s: Array = spec.get("s", [])
	var y: Array = spec.get("y", [])
	var depth := float(spec.get("depth", 0.35))
	var conduits := int(spec.get("conduits", 0))
	var strap_every := float(spec.get("strap_every", 1.5))
	if s.size() != 2 or y.size() != 2 or not _finite(s + y) or float(s[1]) - float(s[0]) < 0.15 or float(y[1]) - float(y[0]) < 1.0:
		errors.append("duct needs s [u0, u1] at least 0.15 m wide and y [y0, y1] at least 1 m tall")
	if not (depth >= 0.1 and depth <= 1.0):
		errors.append("duct depth must be 0.1-1 m")
	if conduits < 0 or conduits > 4:
		errors.append("duct conduits must be 0-4")
	if not (strap_every == 0.0 or (strap_every >= 0.5 and strap_every <= 10.0)):
		errors.append("duct strap_every must be 0 or 0.5-10 m")
	if not errors.is_empty():
		return _result([], errors)
	var u0 := float(s[0])
	var u1 := float(s[1])
	var y0 := float(y[0])
	var y1 := float(y[1])
	var out := []
	var w := u1 - u0
	# The gooseneck turns toward hood_to; without it the shaft just ends in a hood.
	var hood_to := float(spec.get("hood_to", u1 + w))
	var dir := 1.0 if hood_to >= (u0 + u1) * 0.5 else -1.0
	var neck := minf(w, 0.45)
	_box(out, "duct", u0, u1, y0, y1 - neck, 0.02, depth)
	var n0 := minf(u0, hood_to)
	var n1 := maxf(u1, hood_to)
	_box(out, "duct", n0, n1, y1 - neck, y1, 0.02, depth)
	# The hood is the neck's weathered end, a little proud of it all round.
	var cap := hood_to - dir * 0.3
	_box(out, "hood", minf(cap, hood_to + dir * 0.05), maxf(cap, hood_to + dir * 0.05), y1 - neck - 0.04, y1 + 0.04, 0.0, depth + 0.04)
	for k in conduits:
		var cu := (u1 + 0.05 + 0.06 * float(k)) if dir > 0.0 else (u0 - 0.05 - 0.06 * float(k))
		_box(out, "conduit", cu - 0.025, cu + 0.025, y0 + 0.1, y1 - 0.05, 0.02, 0.07)
	if strap_every > 0.0:
		var at := y0 + strap_every * 0.5
		while at < y1 - neck - 0.2:
			_box(out, "strap", u0 - 0.02, u1 + 0.02, at, at + 0.05, 0.0, depth + 0.02)
			at += strap_every
	return _result(out, [])


static func _box(out: Array, role: String, u0: float, u1: float, y0: float, y1: float, d0: float, d1: float) -> void:
	if u1 - u0 < 0.005 or y1 - y0 < 0.005:
		return
	out.append({"role": role, "u0": u0, "u1": u1, "y0": y0, "y1": y1, "d0": minf(d0, d1), "d1": maxf(maxf(d0, d1), minf(d0, d1) + MIN_DEPTH_M)})


static func _finite(values: Array) -> bool:
	for value: Variant in values:
		if not (value is float or value is int) or not is_finite(float(value)):
			return false
	return true


static func _result(boxes: Array, errors: Array) -> Dictionary:
	return {"ok": errors.is_empty(), "boxes": boxes if errors.is_empty() else [], "errors": errors}


## Small deterministic generator (an LCG), so the same seed gives the same layout on
## every platform and run.
class _Rng:
	var state := 0

	func _init(seed: int) -> void:
		state = (seed * 2654435761 + 1013904223) & 0x7fffffff

	func unit() -> float:
		state = (state * 1103515245 + 12345) & 0x7fffffff
		return float(state) / float(0x7fffffff)

	func signed() -> float:
		return unit() * 2.0 - 1.0
