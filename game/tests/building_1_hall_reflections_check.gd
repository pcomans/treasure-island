extends SceneTree
## Building 1's hall floor reflections (building_1_hall_reflections.gd) in the loaded
## island, drawn; tools/test.sh runs it on both renderers the game ships with, naming
## the one it asks for (-- --expect METHOD): a run the engine draws with another
## renderer (Forward+ falling back to Compatibility without Vulkan) fails.
##   tools/godot --rendering-method forward_plus --fixed-fps 60 --path . --script game/tests/building_1_hall_reflections_check.gd -- --expect forward_plus
##   tools/godot --rendering-method gl_compatibility --rendering-driver opengl3 --fixed-fps 60 --path . --script game/tests/building_1_hall_reflections_check.gd -- --expect gl_compatibility
## It runs at 60 frames a second of game time (--fixed-fps 60), so the reflections' fade
## (the hall's InteriorPresence, its fade_s) takes a known number of frames
## (_fade_frames). The presence's own rules (its lines, blend and signals) are checked
## headless on their own (game/tests/headless_interior_presence_contract.gd); here they
## drive the reflections in the real hall.
## Forward+ (desktop), with mode "inside" (set here, as the config ships it):
## - far from the door the mural is not up and there is no probe, nor while it loads;
## - outside near the door, once the mural is up, the probes are there reflecting
##   nothing (intensity 0), and the environment and the floor are as they were;
## - walked in, the reflections fade in frame by frame: the blend only rises and is
##   all in within the fade's frames; each frame the floor's roughness, specular and
##   colour are the blend's mix of its own and the polished ones, its plain attributes
##   are up exactly from the blend's middle, the probes reflect at the blend's share,
##   and the environment has the hall's screen-space reflections from the first frame
##   (each frame printed as a FADE line). At the end, all in: the environment's
##   reflections the hall's, the floor polished and tinted, the renderer drawing its
##   plain attributes (read back, byte for byte the node's plain set), the probes at
##   full intensity;
## - walked out, the same fading out: the blend only falls, the environment keeps the
##   hall's reflections to the fade's last frame, and at the end its five reflection
##   settings and the floor's roughness, specular and albedo are exactly as before, and
##   the renderer draws the baked sheen's attributes again, byte for byte;
## - turned back mid-fade, below and past the blend's middle, the fade turns round
##   without flapping: from the frame the camera leaves, the blend only falls, the plain
##   attributes come down once if they went up, and the environment's reflections go
##   once, when the blend is back at 0;
## - on the doorway, where the look switches on HYSTERESIS_M inside the hall's bound
##   and off as far outside it: a camera walked across that whole band and back,
##   BAND_TRIPS times, switches it exactly once each time it crosses the far line, in
##   that frame, and never between the lines. Regression checks against the flicker one
##   line made: a camera put across the bound and back every frame switches it at most
##   once, and one going round the doorway, or the stock player's own spring-arm camera
##   turned round where it stands in the door, never twice within FLICKER_FRAMES
##   frames (each frame printed as DOORWAY lines, beside what one line would have done);
## - an environment swapped in while they are on gets the reflections and the one
##   swapped out its own settings back;
## - taken out of the tree while on, and again mid-fade with the plain attributes up,
##   the node puts the environment, the floor and its attributes back at once and frees
##   its probes; back in the tree it fades in again;
## - the mural released far away frees the probes.
## Compatibility (the web's renderer): with the camera inside, nothing of it: no probe,
## the environment and the floor untouched.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
## The environment's reflection settings the node sets and puts back.
const SSR_PROPERTIES := ["ssr_enabled", "ssr_max_steps", "ssr_fade_in", "ssr_fade_out", "ssr_depth_tolerance"]
## Where the camera stands: far beyond the mural's unload radius, outside near the door,
## and inside, on the door's axis (m from the door), at the door's eye height.
const FAR_M := 150.0
const OUTSIDE_M := 20.0
const INSIDE_M := 10.0
## The doorway: a camera put this far either side of the hall's bound every frame, and
## one going round the bound's middle at this radius, a turn in DOORWAY_FRAMES frames.
const JITTER_M := 0.2
const ORBIT_M := 1.5
const DOORWAY_FRAMES := 120
## Two switches of the look this close together (frames) are a flicker.
const FLICKER_FRAMES := 10
## The band between the two switch lines: walked from BAND_PAST_M beyond one line to as
## far beyond the other, BAND_STEP_M a frame (steps that never land on a line), in and
## out BAND_TRIPS times.
const BAND_PAST_M := 0.125
const BAND_STEP_M := 0.05
const BAND_TRIPS := 3
## The frames of game time a second (the run's --fixed-fps).
const FPS := 60.0
## Frames the camera stays in before turning back mid-fade: below the blend's middle,
## and past it (the plain attributes up).
const TURN_BELOW := 9
const TURN_PAST := 21

var _h: WorldHarness
var failures: Array[String] = []
var _node: Building1HallReflections
var _presence: InteriorPresence
var _loader: Building1MuralLoader
var _shell: MeshInstance3D
var _world_environment: WorldEnvironment
var _camera: Camera3D
## The door at eye height, and out of it (toward the crescent's centre), flat.
var _door := Vector3.ZERO
var _out := Vector3.ZERO


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var method := RenderingServer.get_current_rendering_method()
	print("RENDERER: %s / %s / %s" % [method, RenderingServer.get_video_adapter_name(), DisplayServer.get_name()])
	var expected := _expected_method()
	if expected == "":
		_finish("name the renderer the run asks for: -- --expect forward_plus or -- --expect gl_compatibility")
		return
	if method != expected:
		_finish("asked for %s, the engine draws with %s" % [expected, method])
		return
	_h = WorldHarness.new(self)
	var error := await _h.load_world([])
	if error != "":
		_finish(error)
		return
	_node = _h.world.buildings.find_child("HallReflections", true, false) as Building1HallReflections
	_loader = _h.world.buildings.find_child("MuralLoader", true, false) as Building1MuralLoader
	if _node == null or _loader == null:
		_finish("the island's Building 1 hall has no HallReflections or MuralLoader node")
		return
	_shell = _node.get_parent().get_node_or_null("Shell") as MeshInstance3D
	_presence = _node.get_parent().get_node_or_null("Presence") as InteriorPresence
	if _presence == null:
		_finish("the island's Building 1 hall has no Presence (InteriorPresence) beside its reflections")
		return
	_world_environment = _h.main.get_node("WorldEnvironment") as WorldEnvironment
	_node.mode = "inside"
	_door = _loader.door
	_out = Vector3(_loader.hall.x - _door.x, 0.0, _loader.hall.y - _door.z).normalized()
	_camera = Camera3D.new()
	_camera.name = "ReflectionsCheckCamera"
	_h.main.add_child(_camera)
	_camera.make_current()
	if method == "forward_plus":
		await _check_forward_plus()
	else:
		await _check_elsewhere()
	_finish("")


## The renderer the run asks for (-- --expect METHOD), or "" when it names none.
static func _expected_method() -> String:
	var args := OS.get_cmdline_user_args()
	var at := args.find("--expect")
	return args[at + 1] if at >= 0 and at + 1 < args.size() else ""


func _check_forward_plus() -> void:
	var environment := _world_environment.environment
	var own := _ssr_of(environment)
	var floor := _floor_values()
	# Far away: no mural, no probe.
	await _stand(-FAR_M, 30)
	if _loader.state != Building1MuralLoader.State.UNLOADED or not _node.probe_nodes().is_empty():
		failures.append("far from the door the mural is %s and there are %d probes" % [Building1MuralLoader.State.keys()[_loader.state], _node.probe_nodes().size()])
	# Outside near the door: no probe until the mural is up, then probes reflecting nothing.
	_put(_at(-OUTSIDE_M), _door)
	var frames := 0
	while _loader.state != Building1MuralLoader.State.LOADED and frames < 120:
		if not _node.probe_nodes().is_empty():
			failures.append("probes made before the mural is up (%s)" % Building1MuralLoader.State.keys()[_loader.state])
			break
		await process_frame
		frames += 1
	await _frames(10)
	_check_off("outside near the door, the mural up", environment, own, floor)
	if _node.probe_nodes().is_empty():
		failures.append("no probes outside near the door once the mural is up")
	# Inside: fading in, then all in.
	await _check_fade("fading in", INSIDE_M, environment, own, floor)
	_check_on("inside", environment)
	# Back outside: fading out, then everything as before.
	await _check_fade("fading out", -OUTSIDE_M, environment, own, floor)
	_check_off("back outside", environment, own, floor)
	# Turned back mid-fade, below the blend's middle and past it.
	await _check_turn_back("turned back below the middle", TURN_BELOW, environment, own, floor)
	await _check_turn_back("turned back past the middle", TURN_PAST, environment, own, floor)
	await _check_doorway()
	await _stand(-OUTSIDE_M, _fade_frames() + 2)
	_check_off("outside after the doorway", environment, own, floor)
	# Another environment (a copy made while the reflections are off) swapped in while on.
	var other := environment.duplicate() as Environment
	await _stand(INSIDE_M, _fade_frames() + 2)
	_world_environment.environment = other
	await _frames(3)
	if _ssr_of(environment) != own:
		failures.append("the environment swapped out keeps the hall's reflections: %s, its own %s" % [_ssr_of(environment), own])
	if not other.ssr_enabled:
		failures.append("the environment swapped in while inside has no reflections")
	_world_environment.environment = environment
	await _frames(3)
	if _ssr_of(other) != own:
		failures.append("the environment swapped back out keeps the hall's reflections: %s" % [_ssr_of(other)])
	_check_on("inside, the environment swapped back", environment)
	# Out of the tree while on, and again mid-fade with the plain attributes up:
	# everything back at once, the probes freed; back in, it fades in again.
	var parent := _node.get_parent()
	await _check_leave(parent, "while on", environment, own, floor)
	await _stand(-OUTSIDE_M, _fade_frames() + 2)
	_put(_at(INSIDE_M), _at(INSIDE_M + 5.0))
	await _frames(TURN_PAST)
	if _node.fade() <= 0.5 or _node.fade() >= 1.0 or not _node.plain_floor_shown():
		failures.append("%d frames into the fade-in the blend is %.3f and the plain attributes %s, not past the middle and up" % [TURN_PAST, _node.fade(), "up" if _node.plain_floor_shown() else "down"])
	await _check_leave(parent, "mid-fade", environment, own, floor)
	# Far away again: the mural released after its delay, the probes freed.
	_put(_at(-FAR_M), _door)
	frames = 0
	while _loader.state != Building1MuralLoader.State.UNLOADED and frames < int((_loader.unload_delay + 5.0) * Engine.physics_ticks_per_second):
		await process_frame
		frames += 1
	await _frames(3)
	_check_off("far away, the mural released", environment, own, floor)
	if _loader.state != Building1MuralLoader.State.UNLOADED or not _node.probe_nodes().is_empty() or not _hall_probes(parent).is_empty():
		failures.append("far away the mural is %s and %d probes are left" % [Building1MuralLoader.State.keys()[_loader.state], _hall_probes(parent).size()])
	if failures.is_empty():
		print("PASS: Forward+: no probe before the mural is up; probes reflecting nothing outside; the hall's reflections and polish fading in and out within %d frames, the blend moving one way, the floor, plain attributes, probes and environment following it; outside again, the environment's reflections and the floor exactly as before; turned back mid-fade without flapping; no flicker on the doorway; a swapped environment and the node leaving the tree, on or mid-fade, put back; probes freed with the mural" % _fade_frames())


## The frames a fade takes at FPS, and one for the last step's rounding.
func _fade_frames() -> int:
	return ceili(_presence.fade_s * FPS) + 1


## The polished floor's values: [roughness, specular, albedo] as the node sets them.
func _polished(floor: Array) -> Array:
	var albedo: Color = floor[2]
	var tint := _node.floor_albedo
	return [_node.floor_roughness, _node.floor_specular, Color(albedo.r * tint.r, albedo.g * tint.g, albedo.b * tint.b, albedo.a)]


## The camera put on the door's axis (metres in, out if negative), then a fade watched
## frame by frame until it has ended and a few frames more: the blend moves only toward
## its end and gets there within _fade_frames(); each frame the floor's values are the
## blend's mix of its own (floor) and the polished ones, the plain attributes are up
## exactly from the blend's middle, the probes reflect at its share of their intensity,
## and the environment has the hall's reflections while the camera calls for them or
## the blend is above 0, else its own (own) exactly.
func _check_fade(where: String, metres: float, environment: Environment, own: Array, floor: Array) -> void:
	var hall_ssr := [true, _node.ssr_max_steps, _node.ssr_fade_in, _node.ssr_fade_out, _node.ssr_depth_tolerance]
	var polished := _polished(floor)
	var start := _node.fade()
	_put(_at(metres), _at(metres + 5.0))
	var target := 1.0 if metres > 0.0 else 0.0
	var last := start
	var ended := -1
	var problems: Array[String] = []
	for frame in _fade_frames() + 3:
		await process_frame
		var blend := _node.fade()
		if (target - blend) * (target - last) < 0.0 or absf(target - blend) > absf(target - last):
			problems.append("frame %d: the blend went from %.3f to %.3f, away from %.0f" % [frame, last, blend, target])
		if blend == target and ended < 0:
			ended = frame
		var values := _floor_values()
		var mixed := [lerpf(floor[0], polished[0], blend), lerpf(floor[1], polished[1], blend), (floor[2] as Color).lerp(polished[2], blend)]
		if not is_equal_approx(values[0], mixed[0]) or not is_equal_approx(values[1], mixed[1]) or not (values[2] as Color).is_equal_approx(mixed[2]):
			problems.append("frame %d at blend %.3f: the floor %s, not %s" % [frame, blend, values, mixed])
		if _node.plain_floor_shown() != (not _node.baked_sheen and blend >= 0.5):
			problems.append("frame %d at blend %.3f: the plain attributes %s" % [frame, blend, "up" if _node.plain_floor_shown() else "down"])
		if _node.probe_nodes().any(func(probe: ReflectionProbe) -> bool: return not is_equal_approx(probe.intensity, _node.probe_intensity * blend)):
			problems.append("frame %d at blend %.3f: a probe not at %.3f" % [frame, blend, _node.probe_intensity * blend])
		var hall := _node.is_on() or blend > 0.0
		if (hall and not _same(_ssr_of(environment), hall_ssr)) or (not hall and _ssr_of(environment) != own):
			problems.append("frame %d at blend %.3f: the environment's reflections %s" % [frame, blend, _ssr_of(environment)])
		print("FADE %s frame=%d blend=%.3f roughness=%.4f specular=%.4f plain=%s ssr=%s" % [where, frame, blend, values[0], values[1], _node.plain_floor_shown(), _ssr_of(environment)[0]])
		last = blend
	if ended < 0 or ended >= _fade_frames():
		problems.append("the blend reached %.0f %s, not within %d frames" % [target, "at frame %d" % ended if ended >= 0 else "never", _fade_frames()])
	print("FADE %s: from %.3f to %.0f in %d frames" % [where, start, target, ended + 1])
	if not problems.is_empty():
		failures.append("%s: %s" % [where, "; ".join(problems.slice(0, 6))])


## The camera in from outside (blend 0) for `frames` frames, then out again: from the
## frame it leaves the blend only falls, back to 0 within _fade_frames(); the plain
## attributes come down once if they went up, never otherwise, and the environment's
## reflections go once, when the blend is back at 0; then everything as before.
func _check_turn_back(where: String, frames: int, environment: Environment, own: Array, floor: Array) -> void:
	await _stand(-OUTSIDE_M, _fade_frames() + 2)
	_put(_at(INSIDE_M), _at(INSIDE_M + 5.0))
	await _frames(frames)
	var peak := _node.fade()
	var plain := _node.plain_floor_shown()
	var hall := _ssr_of(environment) != own
	_put(_at(-OUTSIDE_M), _at(-OUTSIDE_M + 5.0))
	var last := peak
	var plain_changes := 0
	var environment_changes := 0
	var ended := -1
	var problems: Array[String] = []
	for frame in _fade_frames() + 3:
		await process_frame
		var blend := _node.fade()
		if blend > last:
			problems.append("frame %d: the blend rose from %.3f to %.3f" % [frame, last, blend])
		if blend == 0.0 and ended < 0:
			ended = frame
		if _node.plain_floor_shown() != plain:
			plain = _node.plain_floor_shown()
			plain_changes += 1
		if (_ssr_of(environment) != own) != hall:
			hall = not hall
			environment_changes += 1
			if blend != 0.0:
				problems.append("frame %d: the environment's reflections went at blend %.3f" % [frame, blend])
		last = blend
	var expected_plain := 1 if peak >= 0.5 and not _node.baked_sheen else 0
	if plain_changes != expected_plain or environment_changes != 1 or ended < 0 or ended >= _fade_frames():
		problems.append("turned back at blend %.3f: the plain attributes changed %d times (%d expected), the environment's reflections %d times (1 expected), the blend at 0 %s" % [peak, plain_changes, expected_plain, environment_changes, "at frame %d" % ended if ended >= 0 else "never"])
	print("FADE %s at blend %.3f: back to 0 in %d frames, the plain attributes changed %d times, the environment's reflections %d" % [where, peak, ended + 1, plain_changes, environment_changes])
	if not problems.is_empty():
		failures.append("%s: %s" % [where, "; ".join(problems.slice(0, 6))])
	_check_off(where + ", at the end", environment, own, floor)


## The node out of the tree (as it is now: on, or mid-fade), then back in: out, the
## environment, the floor and its attributes are back at once and the probes freed; back
## in with the camera inside, it fades in again.
func _check_leave(parent: Node, when: String, environment: Environment, own: Array, floor: Array) -> void:
	var blend := _node.fade()
	parent.remove_child(_node)
	await _frames(2)
	if _ssr_of(environment) != own or _floor_values() != floor or _node.plain_floor_shown() or _drawn_attributes() != _node.sheen_attributes or not _hall_probes(parent).is_empty() or _node.fade() != 0.0:
		failures.append("taken out of the tree %s (blend %.3f), it left the environment %s (own %s), the floor %s (was %s), its plain attributes %s (the drawn bytes %s its baked sheen), %d probes and the blend at %.3f" % [when, blend, _ssr_of(environment), own, _floor_values(), floor, "up" if _node.plain_floor_shown() else "down", "are" if _drawn_attributes() == _node.sheen_attributes else "are not", _hall_probes(parent).size(), _node.fade()])
	print("FADE out of the tree %s at blend %.3f: put back" % [when, blend])
	parent.add_child(_node)
	await _frames(_fade_frames() + 2)
	_check_on("inside, the node back in the tree after leaving it %s" % when, environment)


## The doorway, where the door's axis crosses the hall's bound (line): the band between
## the two switch lines walked across and back; then, as regression checks against a
## single line's flicker, the bound crossed by a camera put either side of it every
## frame, by one going round it, and by the stock player's spring-arm camera turned
## round where the player stands in the door.
func _check_doorway() -> void:
	var line := Vector3(_loader.hall.x, _door.y, _loader.hall.y) - _out * _loader.hall.z
	var outward := _out
	await _check_band(line, outward)
	# Across the bound and back every frame.
	_put(line + outward * 2.0, line - outward)
	await _frames(5)
	var before := _presence.switches
	var single := 0
	var was := _presence.contains(_camera.global_position)
	for frame in 60:
		var at := line + outward * (JITTER_M if frame % 2 == 0 else -JITTER_M)
		_put(at, line - outward)
		await process_frame
		single += 1 if _presence.contains(at) != was else 0
		was = _presence.contains(at)
	var jitter := _presence.switches - before
	print("DOORWAY jitter %d frames across the line by %.1f m: %d switches (a single line: %d)" % [60, JITTER_M, jitter, single])
	if jitter > 1:
		failures.append("a camera put across the doorway line every frame switched the look %d times" % jitter)
	# Round the line's middle.
	await _record_doorway("orbit", func(frame: int) -> void:
		var turn := TAU * float(frame) / float(DOORWAY_FRAMES)
		_put(line + Vector3(cos(turn), 0.0, sin(turn)) * ORBIT_M, line))
	# The stock player in the door, its own spring-arm camera turned round.
	var player := _h.player
	var hit := _h.ray(Vector3(_door.x, _door.y + 2.0, _door.z), Vector3(_door.x, _door.y - 4.0, _door.z), player.collision_mask)
	if hit.is_empty():
		failures.append("no floor in the door to stand the player on")
		return
	player.set_gameplay_enabled(false)
	player.global_position = hit.position as Vector3
	player.get_camera().make_current()
	await _frames(5)
	await _record_doorway("spring-arm", func(frame: int) -> void:
		player.camera_rig.rotation.y = TAU * float(frame) / float(DOORWAY_FRAMES))
	_camera.make_current()


## The band between the switch lines, on the door's axis (line, outward: out of the
## hall): a camera from BAND_PAST_M beyond the outer line to as far beyond the inner one
## and back, BAND_STEP_M a frame, BAND_TRIPS times. What two lines do, worked out here
## from the camera's metres off the bound: on in the frame it first stands more than
## HYSTERESIS_M inside, off in the frame it first stands HYSTERESIS_M or more outside.
## The node must agree every frame, so it switches exactly once per crossing, at that
## line, and never in the band between.
func _check_band(line: Vector3, outward: Vector3) -> void:
	var width := InteriorPresence.HYSTERESIS_M
	var reach := width + BAND_PAST_M
	_put(line + outward * 2.0, line - outward)
	await _frames(5)
	if _node.is_on():
		failures.append("2 m out of the door, the look is on before the doorway band")
		return
	var steps := roundi(2.0 * reach / BAND_STEP_M)
	var on := false
	var before := _presence.switches
	var crossings := 0
	var wrong: Array[String] = []
	var frame := 0
	for trip in BAND_TRIPS:
		for inward: bool in [true, false]:
			for step in range(1, steps + 1):
				# Metres out of the hall from its bound (negative: in it).
				var offset := reach - 2.0 * reach * float(step) / float(steps)
				if not inward:
					offset = -offset
				_put(line + outward * offset, line - outward)
				await process_frame
				if (not on and offset < -width) or (on and offset >= width):
					on = not on
					crossings += 1
				if _node.is_on() != on:
					wrong.append("frame %d at %+.3f m" % [frame, offset])
				print("DOORWAY band frame=%d offset=%+.3f on=%s two_lines=%s switches=%d crossings=%d" % [frame, offset, _node.is_on(), on, _presence.switches - before, crossings])
				frame += 1
	var switches := _presence.switches - before
	print("DOORWAY band: %d switches for %d crossings in %d frames, the lines %.1f m either side of the bound" % [switches, crossings, frame, width])
	if switches != crossings or crossings != 2 * BAND_TRIPS or not wrong.is_empty():
		failures.append("walked across the doorway's band %d times, the look switched %d times for %d crossings, against two lines at %s" % [2 * BAND_TRIPS, switches, crossings, ", ".join(wrong.slice(0, 6)) if not wrong.is_empty() else "no frame"])


## Runs a doorway move a frame at a time (move(frame) puts the camera), printing each
## frame: the look on or off, its switches so far, and those a single line would have
## made. Fails on two switches FLICKER_FRAMES frames or closer.
func _record_doorway(label: String, move: Callable) -> void:
	await _frames(5)
	var before := _presence.switches
	var single := 0
	var was := _presence.contains(root.get_camera_3d().global_position)
	var last_switch := -FLICKER_FRAMES - 1
	var switches := 0
	for frame in DOORWAY_FRAMES:
		move.call(frame)
		await process_frame
		var at := root.get_camera_3d().global_position
		var now := _presence.contains(at)
		single += 1 if now != was else 0
		was = now
		var toggles := _presence.switches - before
		if toggles != switches:
			if frame - last_switch <= FLICKER_FRAMES:
				failures.append("the %s at the doorway switched the look twice within %d frames (frame %d)" % [label, FLICKER_FRAMES, frame])
			last_switch = frame
			switches = toggles
		print("DOORWAY %s frame=%d camera=(%.2f, %.2f, %.2f) on=%s switches=%d single_line=%d" % [label, frame, at.x, at.y, at.z, _node.is_on(), toggles, single])
	print("DOORWAY %s: %d switches in %d frames (a single line: %d)" % [label, switches, DOORWAY_FRAMES, single])


## Compatibility: nothing of the reflections with the camera inside.
func _check_elsewhere() -> void:
	var environment := _world_environment.environment
	var own := _ssr_of(environment)
	var floor := _floor_values()
	await _stand(-OUTSIDE_M, 30)
	await _stand(INSIDE_M, 30)
	var probes := _hall_probes(_node.get_parent())
	if _node.is_on() or not probes.is_empty() or _ssr_of(environment) != own or _floor_values() != floor or _node.plain_floor_shown():
		failures.append("on %s the reflections did something: on %s, %d probes, the environment %s (own %s), the floor %s (was %s)" % [RenderingServer.get_current_rendering_method(), _node.is_on(), probes.size(), _ssr_of(environment), own, _floor_values(), floor])
	if failures.is_empty():
		print("PASS: %s: inside the hall, no probe, and the environment and the floor untouched" % RenderingServer.get_current_rendering_method())


func _check_on(where: String, environment: Environment) -> void:
	var values := [true, _node.ssr_max_steps, _node.ssr_fade_in, _node.ssr_fade_out, _node.ssr_depth_tolerance]
	var material := _floor_material()
	var problems: Array[String] = []
	if not _node.is_on() or _node.fade() != 1.0:
		problems.append("not all in (on %s, blend %.3f)" % [_node.is_on(), _node.fade()])
	if not _same(_ssr_of(environment), values):
		problems.append("the environment's reflections %s, not the hall's %s" % [_ssr_of(environment), values])
	if not is_equal_approx(material.roughness, _node.floor_roughness) or not is_equal_approx(material.metallic_specular, _node.floor_specular):
		problems.append("the floor at roughness %.3f and specular %.3f, not %.3f and %.3f" % [material.roughness, material.metallic_specular, _node.floor_roughness, _node.floor_specular])
	if _node.plain_floor_shown() == _node.baked_sheen:
		problems.append("its plain attributes %s" % ("up" if _node.plain_floor_shown() else "down"))
	var wanted := _node.sheen_attributes if _node.baked_sheen else _node.plain_attributes
	var drawn := _drawn_attributes()
	if wanted.is_empty() or drawn != wanted:
		problems.append("the floor draws %d attribute bytes that are not its %s set of %d" % [drawn.size(), "baked sheen" if _node.baked_sheen else "plain", wanted.size()])
	var probes := _node.probe_nodes()
	if probes.is_empty() or probes.any(func(probe: ReflectionProbe) -> bool: return not is_equal_approx(probe.intensity, _node.probe_intensity)):
		problems.append("%d probes, not all at intensity %.2f" % [probes.size(), _node.probe_intensity])
	if not problems.is_empty():
		failures.append("%s: %s" % [where, "; ".join(problems)])


func _check_off(where: String, environment: Environment, own: Array, floor: Array) -> void:
	var problems: Array[String] = []
	if _node.is_on() or _node.fade() != 0.0:
		problems.append("not all out (on %s, blend %.3f)" % [_node.is_on(), _node.fade()])
	if _ssr_of(environment) != own:
		problems.append("the environment's reflections %s, not its own %s" % [_ssr_of(environment), own])
	if _floor_values() != floor:
		problems.append("the floor %s, not %s" % [_floor_values(), floor])
	if _node.plain_floor_shown():
		problems.append("its plain attributes up")
	var drawn := _drawn_attributes()
	if _node.sheen_attributes.is_empty() or drawn != _node.sheen_attributes:
		problems.append("the floor draws %d attribute bytes that are not its baked sheen of %d" % [drawn.size(), _node.sheen_attributes.size()])
	if _node.probe_nodes().any(func(probe: ReflectionProbe) -> bool: return probe.intensity != 0.0):
		problems.append("a probe reflecting")
	if not problems.is_empty():
		failures.append("%s: %s" % [where, "; ".join(problems)])


## A point on the door's axis at eye height, metres into the hall (out of it, negative).
func _at(metres: float) -> Vector3:
	return _door - _out * metres


func _put(at: Vector3, look: Vector3) -> void:
	_camera.global_position = at
	_camera.look_at(look, Vector3.UP)


## Stands the camera on the door's axis (metres in), looking along it, for some frames.
func _stand(metres: float, frames: int) -> void:
	_put(_at(metres), _at(metres + 5.0))
	await _frames(frames)


func _frames(count: int) -> void:
	for _i in count:
		await process_frame


func _ssr_of(environment: Environment) -> Array:
	var values := []
	for property: String in SSR_PROPERTIES:
		values.append(environment.get(property))
	return values


## Whether two lists of settings agree, numbers as the engine keeps them (32-bit).
static func _same(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for index in a.size():
		if (a[index] is float or b[index] is float) and not is_equal_approx(float(a[index]), float(b[index])):
			return false
		if not (a[index] is float or b[index] is float) and a[index] != b[index]:
			return false
	return true


func _floor_material() -> BaseMaterial3D:
	return _shell.mesh.surface_get_material(Building1HallReflections.floor_surface(_shell)) as BaseMaterial3D


func _floor_values() -> Array:
	var material := _floor_material()
	return [material.roughness, material.metallic_specular, material.albedo_color]


## The floor's vertex attributes as the renderer holds them to draw (read back from the
## GPU: a check may, the game does not), byte for byte the set the node swapped in.
func _drawn_attributes() -> PackedByteArray:
	var surface := RenderingServer.mesh_get_surface(_shell.mesh.get_rid(), Building1HallReflections.floor_surface(_shell))
	return surface.get("attribute_data", PackedByteArray())


## The hall's reflection probes under the hall's node.
func _hall_probes(hall: Node) -> Array[Node]:
	return hall.find_children("HallReflection*", "ReflectionProbe", false, false)


func _finish(error: String) -> void:
	if error != "":
		failures.append(error)
	for message in failures:
		print("FAIL: " + message)
	if _h != null and is_instance_valid(_h.main):
		_h.main.queue_free()
	quit(0 if failures.is_empty() else 1)
