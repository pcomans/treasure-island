extends SceneTree
## InteriorPresence (game/scripts/world/interiors/interior_presence.gd) on its own,
## headless, at 60 frames a second of game time (--fixed-fps 60), for an interior root
## carrying a ring_sector plan (centre 0, 0; radii 10 to 20 m; angles -1 to 1; top 8 m)
## and a camera moved along the angle 0 (x = metres from the centre):
## - a plan of an unknown kind, with radii or angles the wrong way round, or with angles a
##   whole turn or more apart, is refused (plan_problem);
## - a plan across the -PI/PI seam, written either side of it, holds exactly the points
##   within its turn at every angle round the circle, at its bound and at both lines;
## - far away (beyond the plan's outer radius and its lines) it runs no whole test a
##   frame (full_tests stays put), stays out and sends nothing;
## - walked across the band between its two lines and back, BAND_TRIPS times, it goes in
##   exactly once each time the camera crosses the inner line (HYSTERESIS_M inside the
##   bound) and out once each time it crosses the outer one, in that frame, and never
##   between them; put across the bound and back every frame, it does not switch;
## - in, the blend rises every frame (smoothstep of a progress moving 1 / fade_s a
##   second) and is all in within the fade's frames: entering_started once, at once, and
##   fully_inside once at the end; out, the same falling, leaving_started and
##   fully_outside once each;
## - turned back mid-fade, the blend turns round at once and only falls back to 0:
##   leaving_started once, no fully_inside, fully_outside once at 0;
## - taken out of the tree mid-fade it is out at once (blend 0, fully_outside once), and
##   back in it starts again from outside;
## - one long frame (LONG_FRAME_S) moves the progress by MAX_STEP_S / fade_s only, and the
##   fade runs on from there to its end.

const FPS := 60.0
const FADE_S := 0.5
## The plan's bound the camera crosses: its inner radius, along the angle 0.
const BOUND_M := 10.0
const PLAN := {"kind": "ring_sector", "centre": Vector2(0.0, 0.0), "radii": Vector2(10.0, 20.0), "angles": Vector2(-1.0, 1.0), "top_y": 8.0}
const EYE_M := 1.6
## The band walk: from BAND_PAST_M beyond one line to as far beyond the other, BAND_STEP_M
## a frame (steps that never land on a line), BAND_TRIPS times in and out.
const BAND_PAST_M := 0.125
const BAND_STEP_M := 0.05
const BAND_TRIPS := 3
## Frames in before turning back mid-fade, and before leaving the tree mid-fade.
const TURN_FRAMES := 9
const LEAVE_FRAMES := 12
## The seam plans: one sector 1 radian wide about the angle PI, written across the seam
## from below it and from above it; the sweep's steps round the circle.
const SEAM_PLANS: Array[Vector2] = [Vector2(PI - 0.5, PI + 0.5), Vector2(-PI - 0.5, -PI + 0.5)]
const SEAM_HALF := 0.5
const SEAM_STEPS := 720
const LONG_FRAME_S := 2.0

var failures: Array[String] = []
var _interior: Node3D
var _presence: InteriorPresence
var _camera: Camera3D
## Each signal the presence sent, as [name, frame], and the frames run.
var _sent: Array = []
var _frame := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_plans()
	_check_seam()
	_interior = Node3D.new()
	_interior.name = "Interior"
	_interior.set_meta("interior_of_source_key", "test")
	_interior.set_meta(InteriorPresence.PLAN_META, PLAN)
	_presence = InteriorPresence.new()
	_presence.name = "Presence"
	_presence.fade_s = FADE_S
	_interior.add_child(_presence)
	for name: String in ["entering_started", "fully_inside", "leaving_started", "fully_outside"]:
		_presence.connect(name, func() -> void: _sent.append([name, _frame]))
	_camera = Camera3D.new()
	_interior.add_child(_camera)
	root.add_child(_interior)
	_camera.make_current()
	await _check_far("at first")
	await _check_band()
	await _check_jitter()
	await _check_fade("in", BOUND_M + 5.0)
	await _check_fade("out", BOUND_M - 5.0)
	await _check_turn_back()
	await _check_leave()
	await _check_long_frame()
	await _check_far("at the end")
	_finish()


func _check_plans() -> void:
	if InteriorPresence.plan_problem(PLAN) != "":
		failures.append("the test's plan is refused: %s" % InteriorPresence.plan_problem(PLAN))
	var wrong := [null, {"kind": "box"}, {"kind": "ring_sector", "centre": Vector2.ZERO, "radii": Vector2(20.0, 10.0), "angles": Vector2(-1.0, 1.0), "top_y": 8.0}, {"kind": "ring_sector", "centre": Vector2.ZERO, "radii": Vector2(10.0, 20.0), "angles": Vector2(1.0, -1.0), "top_y": 8.0}, {"kind": "ring_sector", "centre": Vector2.ZERO, "radii": Vector2(10.0, 20.0), "angles": Vector2(-PI, PI), "top_y": 8.0}, {"kind": "ring_sector", "centre": Vector2.ZERO, "radii": Vector2(10.0, 20.0), "angles": Vector2(0.0, 7.0), "top_y": 8.0}]
	for plan: Variant in wrong:
		if InteriorPresence.plan_problem(plan) == "":
			failures.append("a plan it cannot use is taken: %s" % [plan])


## Each seam plan (a sector about the angle PI, written across the seam both ways) on a
## root of its own: at SEAM_STEPS angles round the whole circle, at the middle radius,
## contains() for the bound and both lines agrees with the angle's own distance from PI.
func _check_seam() -> void:
	var r := 15.0
	for angles: Vector2 in SEAM_PLANS:
		var plan := PLAN.duplicate()
		plan.angles = angles
		if InteriorPresence.plan_problem(plan) != "":
			failures.append("the seam plan %s is refused: %s" % [angles, InteriorPresence.plan_problem(plan)])
			continue
		var holder := Node3D.new()
		holder.set_meta(InteriorPresence.PLAN_META, plan)
		var presence := InteriorPresence.new()
		holder.add_child(presence)
		root.add_child(holder)
		var wrong: Array[String] = []
		var held := 0
		for step in SEAM_STEPS:
			var angle := -PI + TAU * (float(step) + 0.5) / float(SEAM_STEPS)
			# From PI round to the angle, the short way.
			var from_pi := PI - absf(angle)
			var at := Vector3(r * cos(angle), EYE_M, r * sin(angle))
			for margin: float in [0.0, InteriorPresence.HYSTERESIS_M, -InteriorPresence.HYSTERESIS_M]:
				var wanted := from_pi < SEAM_HALF - margin / r
				if presence.contains(at, margin) != wanted:
					wrong.append("%.4f rad, margin %+.1f m" % [angle, margin])
				elif wanted and margin == 0.0:
					held += 1
		holder.queue_free()
		print("PRESENCE seam plan %s: holds %d of %d angles round the circle, %d wrong" % [angles, held, SEAM_STEPS, wrong.size()])
		if not wrong.is_empty() or held == 0:
			failures.append("the seam plan %s holds %d angles and is wrong at %s" % [angles, held, ", ".join(wrong.slice(0, 6)) if not wrong.is_empty() else "none"])


## The camera on the angle 0 at metres from the centre, at eye height; frames pass.
func _put(metres: float) -> void:
	_camera.global_position = Vector3(metres, EYE_M, 0.0)


func _frames(count: int) -> void:
	for _i in count:
		await process_frame
		_frame += 1


func _fade_frames() -> int:
	return ceili(FADE_S * FPS) + 1


## The signals sent since `from` (an index into _sent), by name.
func _since(from: int) -> Array:
	return _sent.slice(from).map(func(entry: Array) -> String: return str(entry[0]))


## Far away, once any fade out has ended: no whole test a frame, out, the blend 0,
## nothing sent.
func _check_far(when: String) -> void:
	_put(500.0)
	await _frames(_fade_frames() + 2)
	var tests := _presence.full_tests
	var sent := _sent.size()
	await _frames(60)
	print("PRESENCE far away %s: %d whole tests in 60 frames, in %s, blend %.3f" % [when, _presence.full_tests - tests, _presence.is_inside(), _presence.blend()])
	if _presence.full_tests != tests or _presence.is_inside() or _presence.blend() != 0.0 or _sent.size() != sent:
		failures.append("far away %s it ran %d whole tests in 60 frames, is in %s at blend %.3f and sent %s" % [when, _presence.full_tests - tests, _presence.is_inside(), _presence.blend(), _since(sent)])


## Across the band and back: in once per crossing of the inner line, out once per
## crossing of the outer one, in that frame, never between.
func _check_band() -> void:
	var width := InteriorPresence.HYSTERESIS_M
	var reach := width + BAND_PAST_M
	_put(BOUND_M - 2.0)
	await _frames(_fade_frames() + 2)
	var steps := roundi(2.0 * reach / BAND_STEP_M)
	var inside := false
	var before := _presence.switches
	var crossings := 0
	var wrong: Array[String] = []
	var frame := 0
	for trip in BAND_TRIPS:
		for inward: bool in [true, false]:
			for step in range(1, steps + 1):
				# Metres into the plan from its bound (negative: out of it).
				var depth := -reach + 2.0 * reach * float(step) / float(steps)
				if not inward:
					depth = -depth
				_put(BOUND_M + depth)
				await _frames(1)
				if (not inside and depth > width) or (inside and depth <= -width):
					inside = not inside
					crossings += 1
				if _presence.is_inside() != inside:
					wrong.append("frame %d at %+.3f m" % [frame, depth])
				frame += 1
	var switches := _presence.switches - before
	print("PRESENCE band: %d switches for %d crossings in %d frames, the lines %.1f m either side of the bound" % [switches, crossings, frame, width])
	if switches != crossings or crossings != 2 * BAND_TRIPS or not wrong.is_empty():
		failures.append("across the band %d times it switched %d times for %d crossings, against two lines at %s" % [2 * BAND_TRIPS, switches, crossings, ", ".join(wrong.slice(0, 6)) if not wrong.is_empty() else "no frame"])


## Across the bound and back every frame, inside the band: no switch.
func _check_jitter() -> void:
	_put(BOUND_M - 2.0)
	await _frames(_fade_frames() + 2)
	var before := _presence.switches
	for frame in 60:
		_put(BOUND_M + (0.2 if frame % 2 == 0 else -0.2))
		await _frames(1)
	print("PRESENCE jitter: %d switches in 60 frames across the bound by 0.2 m" % (_presence.switches - before))
	if _presence.switches != before:
		failures.append("put across the bound by 0.2 m every frame it switched %d times" % (_presence.switches - before))


## From the far end (fully out for "in", fully in for "out"), the camera put at metres:
## the blend moves one way every frame and is eased (smoothstep of the progress), gets
## to its end within the fade's frames, and the signals are the start's once at once
## and the end's once at the end.
func _check_fade(way: String, metres: float) -> void:
	var into := way == "in"
	_put(BOUND_M - 5.0 if into else BOUND_M + 5.0)
	await _frames(_fade_frames() + 2)
	var sent := _sent.size()
	var start_frame := _frame
	_put(metres)
	var last := _presence.blend()
	var ended := -1
	var problems: Array[String] = []
	for frame in _fade_frames() + 3:
		await _frames(1)
		var blend := _presence.blend()
		var progress := _presence.progress()
		if (into and blend < last) or (not into and blend > last):
			problems.append("frame %d: the blend went from %.4f to %.4f" % [frame, last, blend])
		if not is_equal_approx(blend, progress * progress * (3.0 - 2.0 * progress)):
			problems.append("frame %d: the blend %.4f is not the eased progress %.4f" % [frame, blend, progress])
		if blend == (1.0 if into else 0.0) and ended < 0:
			ended = frame
		last = blend
	var names := _since(sent)
	var wanted := ["entering_started", "fully_inside"] if into else ["leaving_started", "fully_outside"]
	var first: int = (_sent[sent][1] as int) - start_frame if _sent.size() > sent else -1
	print("PRESENCE fade %s: at its end in %d frames, sent %s (the first in frame %d)" % [way, ended + 1, names, first])
	if ended < 0 or ended >= _fade_frames() or names != wanted or first != 0:
		problems.append("the blend at its end %s, sent %s (wanted %s, the first in the frame the camera moved)" % ["in %d frames" % (ended + 1) if ended >= 0 else "never", names, wanted])
	if not problems.is_empty():
		failures.append("fading %s: %s" % [way, "; ".join(problems.slice(0, 6))])


## In for TURN_FRAMES frames, then out: the blend turns round at once and only falls to
## 0; entering_started, leaving_started, fully_outside, no fully_inside.
func _check_turn_back() -> void:
	_put(BOUND_M - 5.0)
	await _frames(_fade_frames() + 2)
	var sent := _sent.size()
	_put(BOUND_M + 5.0)
	await _frames(TURN_FRAMES)
	var peak := _presence.blend()
	_put(BOUND_M - 5.0)
	var last := peak
	var problems: Array[String] = []
	for frame in _fade_frames() + 3:
		await _frames(1)
		if _presence.blend() > last:
			problems.append("frame %d: the blend rose from %.4f to %.4f" % [frame, last, _presence.blend()])
		last = _presence.blend()
	var names := _since(sent)
	print("PRESENCE turned back at blend %.3f: at %.3f after the fade's frames, sent %s" % [peak, last, names])
	if last != 0.0 or peak <= 0.0 or peak >= 1.0 or names != ["entering_started", "leaving_started", "fully_outside"]:
		problems.append("turned back at blend %.3f, it ended at %.3f and sent %s" % [peak, last, names])
	if not problems.is_empty():
		failures.append("turned back mid-fade: %s" % "; ".join(problems.slice(0, 6)))


## Out of the tree mid-fade: out at once, fully_outside once; back in, from outside.
func _check_leave() -> void:
	_put(BOUND_M - 5.0)
	await _frames(_fade_frames() + 2)
	_put(BOUND_M + 5.0)
	await _frames(LEAVE_FRAMES)
	var blend := _presence.blend()
	var sent := _sent.size()
	_interior.remove_child(_presence)
	var names := _since(sent)
	if _presence.is_inside() or _presence.blend() != 0.0 or names != ["fully_outside"]:
		failures.append("taken out of the tree at blend %.3f, it is in %s at blend %.3f and sent %s" % [blend, _presence.is_inside(), _presence.blend(), names])
	_interior.add_child(_presence)
	sent = _sent.size()
	await _frames(1)
	names = _since(sent)
	print("PRESENCE out of the tree at blend %.3f: out at once; back in, sent %s, blend %.3f" % [blend, names, _presence.blend()])
	if names != ["entering_started"] or _presence.blend() <= 0.0 or _presence.blend() >= 0.1:
		failures.append("back in the tree with the camera in, it sent %s at blend %.3f, not starting again from outside" % [names, _presence.blend()])
	await _frames(_fade_frames() + 2)


## Out, then in with one long frame: the progress moves MAX_STEP_S / fade_s, not the
## whole way, and the following frames take it on to 1 (fully_inside once).
func _check_long_frame() -> void:
	_put(BOUND_M - 5.0)
	await _frames(_fade_frames() + 2)
	var sent := _sent.size()
	_put(BOUND_M + 5.0)
	_presence._process(LONG_FRAME_S)
	var after := _presence.progress()
	var wanted := InteriorPresence.MAX_STEP_S / FADE_S
	var frames := 0
	while _presence.progress() < 1.0 and frames < _fade_frames() + 3:
		await _frames(1)
		frames += 1
	var names := _since(sent)
	print("PRESENCE one frame of %.1f s: progress %.3f (%.3f wanted), then at its end in %d frames, sent %s" % [LONG_FRAME_S, after, wanted, frames, names])
	if not is_equal_approx(after, wanted) or _presence.progress() != 1.0 or names != ["entering_started", "fully_inside"]:
		failures.append("one frame of %.1f s moved the progress to %.3f (wanted %.3f), then it got to %.3f and sent %s" % [LONG_FRAME_S, after, wanted, _presence.progress(), names])


func _finish() -> void:
	if is_instance_valid(_interior):
		_interior.queue_free()
	if failures.is_empty():
		print("PASS: InteriorPresence: plans it cannot use refused; a plan across the -PI/PI seam holds its turn either way it is written; nothing run far away; in and out once per crossing of its two lines and never between; the eased blend rising and falling one way, done within %d frames, each start and end signalled once; turned back mid-fade without flapping; out at once leaving the tree; one long frame moves it MAX_STEP_S / fade_s only" % _fade_frames())
		quit(0)
		return
	for message in failures:
		print("FAIL: " + message)
	quit(1)
