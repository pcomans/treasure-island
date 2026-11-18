extends RefCounted

## Procedural wall-mounted equipment shared by facade producers (pure static,
## producer-agnostic): a telecom antenna cluster on pipe mounts and a sheet-metal duct
## turning into a weathered gooseneck, laid out by rule from a few numbers in the config.
##
## Every helper returns {"ok": bool, "boxes": Array, "errors": Array}. A box is
## {"role": String, "u0", "u1", "y0", "y1", "d0", "d1": float} in a wall's own frame:
## u along the wall (metres), y height (the producer's metres) and d out from the wall
## plane (0 on the wall, positive outward, negative over the wall's top), each range
## increasing. Producers map each
## role (ROLES) to a material, emit the boxes and own their collision. The same spec
## always gives the same boxes: placement varies only with the spec's "seed".
##
## antenna_cluster(spec): mounts spread evenly over "s": [u0, u1], panel antennas (or
## cabinets) topping out near y1 of "y": [y0, y1], radios under them with cable tails
## and, with "signs", a small warning sign on the wall at the foot of the range under
## each mount's lowest radio. Everything stays within s, and above y0 (the signs alone
## in its lowest SIGN_BAND_M); the pipes rise a little over y1.
##   "mounts" 2-12 (default 4), "standoff" 0.2-1 m (default 0.45: pipes stand that far
##   out), "cabinets" (every k-th mount carries a cabinet instead of a panel; 0 none),
##   "signs" (default true), "seed" (an integer).
##   Roles: pipe, bracket, panel, cabinet, radio, cable, sign.
## duct(spec): a vent: a box shaft "s": [u0, u1] wide up the wall from y0 to the wall's
## top y1 of "y", "depth" out from the wall (0.1-1 m, default 0.35), that curves over
## the top onto the roof: an elbow "neck" tall (0.1-1 m, default 0.3) sitting on y1
## runs from the shaft's front back over the wall "over" metres (0.3-5 m, default 1);
## elbow and run are the weathered hood. "conduits" (0-4) thin conduits beside the shaft
## on "conduit_side" (1: past u1, the default; -1: before u0), and straps every
## "strap_every" metres (default 1.5; 0 none).
##   Roles: duct, hood, conduit, strap.

## Every role a helper emits: a producer's material map may name only these.
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
## The foot of a cluster's range, kept for its warning signs.
const SIGN_BAND_M := 0.3
const SIGN_W_M := 0.14
const SIGN_H_M := 0.2


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
	# Gear, radios and cables stay above the signs' band.
	var low := y0 + SIGN_BAND_M
	var rng := _Rng.new(int(spec.get("seed", 0)))
	var out := []
	var pitch := (u1 - u0) / float(mounts)
	for i in mounts:
		var c := clampf(u0 + pitch * (float(i) + 0.5) + pitch * 0.15 * rng.signed(), u0 + PIPE_W_M * 0.5, u1 - PIPE_W_M * 0.5)
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
			width = lerpf(0.4, 0.6, rng.unit())
			height = lerpf(0.7, 1.0, rng.unit())
		else:
			width = lerpf(0.3, 0.6, rng.unit())
			height = lerpf(1.3, 1.9, rng.unit())
		width = minf(width, u1 - u0)
		height = minf(height, (top - y0) * 0.6)
		var depth := lerpf(0.14, 0.26, rng.unit())
		var gc := clampf(c + rng.signed() * pitch * 0.12, u0 + width * 0.5, u1 - width * 0.5)
		var g0 := gc - width * 0.5
		var g1 := gc + width * 0.5
		var gear_bottom := top - height
		_box(out, role, g0, g1, gear_bottom, top, front, front + depth)
		# One or two radios below, each a little off the gear's centre line.
		var cursor := gear_bottom - lerpf(0.08, 0.3, rng.unit())
		var radios := 1 + int(rng.unit() > 0.4)
		var lowest := gear_bottom
		var lowest_c := gc
		for r in radios:
			var rh := lerpf(0.32, 0.55, rng.unit())
			if cursor - rh < low + 0.05:
				break
			var rw := lerpf(0.26, 0.42, rng.unit())
			var rc := clampf(c + rng.signed() * pitch * 0.15, u0 + rw * 0.5, u1 - rw * 0.5)
			_box(out, "radio", rc - rw * 0.5, rc + rw * 0.5, cursor - rh, cursor, front, front + lerpf(0.14, 0.22, rng.unit()))
			# Cable tails hang below each radio, no lower than the signs' band.
			for t in 3 + int(rng.unit() * 2.0):
				var tc := rc - rw * 0.4 + rw * 0.8 * rng.unit()
				_box(out, "cable", tc - CABLE_W_M * 0.5, tc + CABLE_W_M * 0.5, maxf(low, cursor - rh - lerpf(0.15, 0.5, rng.unit())), cursor - rh, front + 0.02, front + 0.02 + CABLE_W_M)
			lowest = cursor - rh
			lowest_c = rc
			cursor -= rh + lerpf(0.1, 0.3, rng.unit())
		# Jumper cables from the gear down past the radios, close to the wall.
		for t in 3:
			var jc := clampf(g0 + (g1 - g0) * (0.2 + 0.3 * float(t)) + 0.05 * rng.signed(), u0 + CABLE_W_M * 0.5, u1 - CABLE_W_M * 0.5)
			_box(out, "cable", jc - CABLE_W_M * 0.5, jc + CABLE_W_M * 0.5, maxf(low, lowest - 0.25), gear_bottom, standoff - 0.14, standoff - 0.14 + CABLE_W_M)
		# A warning sign on the wall at the foot of the range, under the lowest radio.
		if bool(spec.get("signs", true)):
			var sc := clampf(lowest_c, u0 + SIGN_W_M * 0.5, u1 - SIGN_W_M * 0.5)
			_box(out, "sign", sc - SIGN_W_M * 0.5, sc + SIGN_W_M * 0.5, y0 + 0.05, y0 + 0.05 + SIGN_H_M, 0.0, MIN_DEPTH_M)
	return _result(out, [])


static func duct(spec: Dictionary) -> Dictionary:
	var errors := []
	var s: Array = spec.get("s", [])
	var y: Array = spec.get("y", [])
	var depth := float(spec.get("depth", 0.35))
	var conduits := int(spec.get("conduits", 0))
	var strap_every := float(spec.get("strap_every", 1.5))
	var neck := float(spec.get("neck", 0.3))
	var over := float(spec.get("over", 1.0))
	var conduit_side: Variant = spec.get("conduit_side", 1)
	if s.size() != 2 or y.size() != 2 or not _finite(s + y) or float(s[1]) - float(s[0]) < 0.15 or float(y[1]) - float(y[0]) < 1.0:
		errors.append("duct needs s [u0, u1] at least 0.15 m wide and y [y0, y1] at least 1 m tall")
	if not (depth >= 0.1 and depth <= 1.0):
		errors.append("duct depth must be 0.1-1 m")
	if not (neck >= 0.1 and neck <= 1.0):
		errors.append("duct neck must be 0.1-1 m")
	if not (over >= 0.3 and over <= 5.0):
		errors.append("duct over must be 0.3-5 m")
	if not (_finite([conduit_side]) and absf(float(conduit_side)) == 1.0):
		errors.append("duct conduit_side must be 1 or -1")
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
	_box(out, "duct", u0, u1, y0, y1, 0.02, depth)
	# The curve over the wall's top: an elbow on y1 running from the shaft's front back
	# over the wall onto the roof, weathered sheet metal.
	_box(out, "hood", u0, u1, y1, y1 + neck, -over, depth)
	for k in conduits:
		var cu := (u1 + 0.05 + 0.06 * float(k)) if float(conduit_side) > 0.0 else (u0 - 0.05 - 0.06 * float(k))
		_box(out, "conduit", cu - 0.025, cu + 0.025, y0 + 0.1, y1 - 0.05, 0.02, 0.07)
	if strap_every > 0.0:
		var at := y0 + strap_every * 0.5
		while at < y1 - 0.2:
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
