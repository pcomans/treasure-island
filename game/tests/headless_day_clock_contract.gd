extends SceneTree
## The time of day (owner, 2026-11-14: the sun of the real date and time on the
## island, running at real speed, with a date and a time slider), headless and
## without the world. The Sun following it in the loaded game, and the sliders
## worked there, are headless_gameplay_contract.gd's.
##   - a test driver's clock is held at the recorded moment (main.tscn's Sun), and
##     the sun drawn there is main.tscn's Sun exactly;
##   - the game's sun (SolarPosition) is tools/solar_position.mjs's: within
##     TOLERANCE_DEG of the table the Node tool prints (`--table`; tools/test.sh
##     prints it outside the repository and names it: -- --solar-table FILE), every
##     13 h 7 min through 2026, day and night, and at moments in other years;
##   - the island's clock is Pacific time by the US rule, from the instant alone
##     (the device's time zone plays no part): the changes in March and November of
##     2026 and 2027 to the second, every day of 2026 there and back, the skipped
##     and the repeated hour;
##   - the clock runs with the system clock, a paused game's time scale of 0
##     included; with a stand-in system clock, a sleep (the system clock jumping
##     on) and a correction carry the game's time with them, to the microsecond;
##     it holds still when pinned, and jumps;
##   - DaySun points a light at the clock's sun, by day and by night: in steps while
##     time runs (10 s with the sun high or deep, shorter near the horizon), at once
##     on a jump, with no jump of its own through sunset, sunrise and midnight;
##   - the light of the sun's height (DayLight's curves): main.tscn's daylight exactly
##     at and above the full-day height, the recorded moment included, where DaySun
##     writes nothing to the Sun, the environment or the sky; dimming through sunset
##     without a step larger than its bound, to the night floor, which holds all
##     night; dawn the same as dusk at the same height; and DaySun putting it on;
##   - the options screen's date and time read the island's clock (PST and PDT, the
##     night note), its sliders jump the clock and time runs on, Now goes back to
##     the real time, and the web's options screen has none of it;
##   - the switch (DayClock.enabled; owner, 2026-11-15: the whole time of day
##     behind one flag): --no-time-of-day on the command line, the project setting
##     off and the web build each turn it off, and nothing else; with the setting
##     turned off as a run starts the clock holds the recorded moment whatever
##     jumps it, and DaySun writes nothing to main.tscn's Sun and look, nor any
##     global uniform.
## The first failure stops the run.

const MAIN_SCENE := "res://game/scenes/main.tscn"
## How far the GDScript sun may stray from the Node tool's (degrees): the same
## arithmetic in 64-bit floats, so only rounding differs.
const TOLERANCE_DEG := 0.000001
## How long a real-speed check lets real time run (s), and how far the game's clock
## may differ from the system clock over that time (s).
const REAL_SPAN_S := 0.3
const REAL_SLACK_S := 0.005
## The most the light may turn in a minute of clock time (degrees).
const JUMP_BOUND_DEG := 0.6
## The most one step of the sun (DaySun.step_seconds, at most 10 s) may change each of
## the look's lights by on the way down (_measures): far less than the eye sees
## change at once.
const STEP_BOUNDS := {
	"sun_energy": 0.01, "ambient": 0.001, "fog": 0.002, "sky_horizon": 0.002,
	"sky_top": 0.001, "exposure": 0.002, "horizon_light": 0.004,
}

var _failure := ""
var _nodes: Array[Node] = []


func _initialize() -> void:
	# Frames, not seconds: under --fixed-fps every frame is 1/60 s of this timer.
	create_timer(300.0, true, false, true).timeout.connect(func() -> void: _finish("The day clock contract timed out."))
	call_deferred("_run")


func _run() -> void:
	# The very first reading: a test driver's clock is held at the recorded moment.
	var first := DayClock.now()
	if not _require(first == DayClock.RECORDED_UNIX and not DayClock.is_running(), "A test driver's clock must start held at the recorded moment %s, not %s (running %s)." % [DayClock.RECORDED_UNIX, first, DayClock.is_running()]):
		return _finish()
	var solar := _check_reference()
	if solar.is_empty():
		return _finish()
	var recorded := _check_recorded_moment()
	if recorded.is_empty():
		return _finish()
	var island := _check_island_clock()
	if island.is_empty():
		return _finish()
	var running := _check_running()
	if running.is_empty():
		return _finish()
	var sun := await _check_day_sun()
	if sun.is_empty():
		return _finish()
	var light := await _check_day_light()
	if light.is_empty():
		return _finish()
	var menu := await _check_options_rows()
	if menu.is_empty():
		return _finish()
	var switch := await _check_switch_off()
	if switch.is_empty():
		return _finish()
	print("PASS: day clock: %s; %s; %s; %s; %s; %s; %s; %s" % [solar, recorded, island, running, sun, light, menu, switch])
	_finish()


## The GDScript sun against the table the Node tool printed for this run.
func _check_reference() -> String:
	var args := OS.get_cmdline_user_args()
	var at := args.find("--solar-table")
	var path := args[at + 1] if at >= 0 and at + 1 < args.size() else ""
	if not _require(path != "" and FileAccess.file_exists(path), "Run this with -- --solar-table FILE, the table `node tools/solar_position.mjs --table` prints (tools/test.sh does), not %s." % [args]):
		return ""
	var table: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not _require(table is Dictionary and table.get("samples") is Array and (table.samples as Array).size() > 600, "The solar table %s is not the Node tool's table, or is short." % path):
		return ""
	var worst := [0.0, 0.0]
	var nights := 0
	for sample: Array in table.samples:
		var sun := SolarPosition.at(float(sample[0]), float(table.latitude), float(table.longitude))
		var elevation := absf(float(sun.elevation_deg) - float(sample[1]))
		var azimuth := absf(angle_difference(deg_to_rad(float(sun.azimuth_deg)), deg_to_rad(float(sample[2])))) / SolarPosition.RAD
		worst = [maxf(worst[0], elevation), maxf(worst[1], azimuth)]
		if not _require(elevation <= TOLERANCE_DEG and azimuth <= TOLERANCE_DEG, "At %d the game's sun is elevation %.9f, azimuth %.9f; the Node tool's %.9f, %.9f." % [int(sample[0]), sun.elevation_deg, sun.azimuth_deg, sample[1], sample[2]]):
			return ""
		if float(sample[1]) < 0.0:
			nights += 1
	return "the sun as tools/solar_position.mjs gives it at %d moments (%d with the sun below the horizon), within %s and %s degrees" % [(table.samples as Array).size(), nights, String.num_scientific(worst[0]), String.num_scientific(worst[1])]


## The recorded moment: main.tscn's Sun, its metadata and its light exactly, and
## the look there main.tscn's daylight exactly (DayLight's first key, from
## FULL_DAY_ELEVATION_DEG up).
func _check_recorded_moment() -> String:
	var main := (load(MAIN_SCENE) as PackedScene).instantiate()
	var scene_sun := main.get_node("Sun") as DirectionalLight3D
	var kept := DaySun.shown_angles(DayClock.RECORDED_UNIX)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = DaySun.rotation_for(kept)
	var same := light.transform == scene_sun.transform
	var metadata: Array[float] = [float(scene_sun.get_meta("solar_elevation_deg")), float(scene_sun.get_meta("solar_azimuth_deg"))]
	light.free()
	var differences := _look_differences(scene_sun, (main.get_node("WorldEnvironment") as WorldEnvironment).environment, _project_globals(), DayLight.at(kept[0]))
	main.free()
	if not _require(kept == metadata and same, "At the recorded moment the sun must be main.tscn's Sun: its metadata %s and its rotation exactly, not %s (rotation the same: %s)." % [metadata, kept, same]) \
	or not _require(kept[0] >= DayLight.FULL_DAY_ELEVATION_DEG and differences.is_empty(), "At the recorded moment (%.2f degrees up, full day from %.0f) the look must be main.tscn's daylight exactly; it differs in %s." % [kept[0], DayLight.FULL_DAY_ELEVATION_DEG, differences]):
		return ""
	return "the recorded moment is main.tscn's Sun exactly (%.2f, %.2f), and its look main.tscn's daylight exactly (%d values)" % [kept[0], kept[1], DayLight.VALUES.size()]


## Where `look` differs from what a Sun, an environment with its sky material and
## the global uniforms hold, each value as the engine holds it (a light's energy,
## for one, is a 32-bit float): [] when it is the same in every one.
func _look_differences(sun: DirectionalLight3D, environment: Environment, globals: Dictionary, look: Dictionary) -> Array[String]:
	var differences: Array[String] = []
	var sky := environment.sky.sky_material as ShaderMaterial
	var held_light := DirectionalLight3D.new()
	var held_environment := Environment.new()
	for value: String in DayLight.SUN_PROPERTIES:
		var property: StringName = DayLight.SUN_PROPERTIES[value]
		held_light.set(property, look[value])
		if held_light.get(property) != sun.get(property):
			differences.append("%s (%s, the Sun's %s)" % [value, held_light.get(property), sun.get(property)])
	for value: String in DayLight.ENVIRONMENT_PROPERTIES:
		var property: StringName = DayLight.ENVIRONMENT_PROPERTIES[value]
		held_environment.set(property, look[value])
		if held_environment.get(property) != environment.get(property):
			differences.append("%s (%s, the environment's %s)" % [value, held_environment.get(property), environment.get(property)])
	for value: String in DayLight.SKY_PARAMETERS:
		var stored: Variant = sky.get_shader_parameter(DayLight.SKY_PARAMETERS[value])
		var wanted: Variant = look[value]
		var equal := stored is Color and wanted is Color and [stored.r, stored.g, stored.b] == [wanted.r, wanted.g, wanted.b]
		if stored is float and (wanted is float or wanted is int):
			equal = stored == float(wanted)
		if not equal:
			differences.append("%s (%s, the sky material's %s)" % [value, wanted, stored])
	for value: String in globals:
		var held: Variant = globals[value]
		var equal: bool = held is float and held == float(look[value])
		if held is Vector3 and look[value] is Vector3:
			equal = (held as Vector3).is_equal_approx(look[value])
		if not equal:
			differences.append("%s (%s, the global's %s)" % [value, look[value], held])
	held_light.free()
	return differences


## project.godot's global uniforms by DayLight's names: what a scene shows before
## DaySun's first look, and what every tool without DaySun shows (horizon_haze, the
## daylight sky's horizon colour in linear RGB, acts only once horizon_light falls
## below 1).
func _project_globals() -> Dictionary:
	var globals := {}
	for value: String in DayLight.GLOBALS:
		var setting: Variant = ProjectSettings.get_setting("shader_globals/%s" % DayLight.GLOBALS[value], {})
		globals[value] = (setting as Dictionary).get("value") if setting is Dictionary else null
	return globals


## The global uniforms DaySun hands the engine (DaySun.set_global), recorded here:
## the engine gives a global's value back only in the editor. Keyed by DayLight's
## names; DaySun.use_engine_globals() puts the engine back.
func _record_globals() -> Dictionary:
	var written := {}
	DaySun.set_global = func(global: StringName, value: Variant) -> void:
		for name: String in DayLight.GLOBALS:
			if DayLight.GLOBALS[name] == global:
				written[name] = value
	return written


## Pacific time, from the instant alone.
func _check_island_clock() -> String:
	var recorded := DayClock.local(DayClock.RECORDED_UNIX)
	if not _require([recorded.year, recorded.month, recorded.day, recorded.hour, recorded.minute, recorded.zone, recorded.weekday, recorded.day_of_year, recorded.minutes] == [2026, 11, 13, 12, 30, "PST", 5, 317, 750], "The recorded moment must read Friday 2026-11-13 12:30 PST, day 317, on the island's clock, not %s." % recorded) \
	or not _require(DayClock.parse_local("2026-11-13 12:30") == DayClock.RECORDED_UNIX and is_nan(DayClock.parse_local("2026-02-30 12:00")) and is_nan(DayClock.parse_local("noon")), "\"2026-11-13 12:30\" must read as the recorded moment, and no Feb 30 or \"noon\"."):
		return ""
	# The changes, to the second: [UTC instant, island hour, minute, zone].
	var changes := [
		[_utc(2026, 3, 8, 9, 59, 59), 1, 59, "PST"], [_utc(2026, 3, 8, 10, 0, 0), 3, 0, "PDT"],
		[_utc(2026, 11, 1, 8, 59, 59), 1, 59, "PDT"], [_utc(2026, 11, 1, 9, 0, 0), 1, 0, "PST"],
		[_utc(2027, 3, 14, 9, 59, 59), 1, 59, "PST"], [_utc(2027, 3, 14, 10, 0, 0), 3, 0, "PDT"],
		[_utc(2027, 11, 7, 8, 59, 59), 1, 59, "PDT"], [_utc(2027, 11, 7, 9, 0, 0), 1, 0, "PST"],
		[_utc(2026, 12, 31, 23, 30, 0), 15, 30, "PST"], [_utc(2026, 7, 4, 19, 0, 0), 12, 0, "PDT"],
	]
	for change: Array in changes:
		var at := DayClock.local(float(change[0]))
		if not _require([at.hour, at.minute, at.zone] == change.slice(1), "At %d the island's clock must read %02d:%02d %s, not %02d:%02d %s." % [change[0], change[1], change[2], change[3], at.hour, at.minute, at.zone]):
			return ""
	# Every day of 2026 there and back, at five times of day; March's skipped hour
	# comes out an hour on, and November's repeated hour as its first (PDT).
	var trips := 0
	for day in range(1, DayClock.days_in_year(2026) + 1):
		for minutes: int in [0, 125, 150, 750, 1435]:
			var at := DayClock.local(DayClock.unix_from_local(2026, day, minutes))
			var expected := [day, minutes + (60 if day == 67 and minutes >= 120 and minutes < 180 else 0)]
			if not _require([at.day_of_year, at.minutes] == expected, "Day %d of 2026 at minute %d must come back as %s on the island's clock, not %s." % [day, minutes, expected, [at.day_of_year, at.minutes]]):
				return ""
			trips += 1
	var repeated := DayClock.local(DayClock.unix_from_local(2026, 305, 90))
	if not _require([repeated.hour, repeated.minute, repeated.zone] == [1, 30, "PDT"], "November's repeated 1:30 must be its first, PDT, not %s." % repeated):
		return ""
	return "the island's clock (PST and PDT changing on 2026-03-08, 2026-11-01, 2027-03-14 and 2027-11-07 to the second; %d dates and times there and back)" % trips


## Real speed is the system clock's: the game's time runs with it, a pause's time
## scale of 0 included. With a stand-in system clock, to the microsecond: a sleep
## (the system clock jumping an hour on while the lid is closed) and a correction
## carry the game's time with them, a pause doesn't stop it, a pinned clock holds
## still, and Now is the system's time. Jumps are counted.
func _check_running() -> String:
	var revision := DayClock.revision()
	var start := 1782050000.0
	DayClock.start_at(start)
	var jumped := DayClock.now()
	var span := _real_span()
	var kept := Engine.time_scale
	Engine.time_scale = 0.0
	var paused_span := _real_span()
	Engine.time_scale = kept
	var real_ok := absf(span.x - span.y) <= REAL_SLACK_S and absf(paused_span.x - paused_span.y) <= REAL_SLACK_S and span.y > 0.0
	# A stand-in system clock, moved by hand.
	var system := [1800000000.0]
	DayClock.system_clock = func() -> float: return system[0]
	DayClock.start_at(start)
	var moves := []
	for move: Array in [["running", 12.5], ["paused", 7.25], ["asleep an hour", 3600.0], ["corrected back", -2.0]]:
		Engine.time_scale = 0.0 if move[0] == "paused" else kept
		system[0] += float(move[1])
		moves.append([move[0], DayClock.now() - start])
	Engine.time_scale = kept
	DayClock.pin(start)
	system[0] += 600.0
	var held := DayClock.now() - start
	DayClock.start_now()
	var stand_in_now := DayClock.now() - float(system[0])
	DayClock.use_system_clock()
	DayClock.start_now()
	var system_gap := absf(DayClock.now() - Time.get_unix_time_from_system())
	var running_now := DayClock.is_running()
	DayClock.pin()
	var expected := [["running", 12.5], ["paused", 19.75], ["asleep an hour", 3619.75], ["corrected back", 3617.75]]
	if not _require(absf(jumped - start) < REAL_SLACK_S, "start_at must jump the clock to %s, not %s." % [start, jumped]) \
	or not _require(real_ok, "The game's time must run with the system clock, paused or not: the system ran %.4f s and the game %.4f s (time scale 0: %.4f s and %.4f s)." % [span.y, span.x, paused_span.y, paused_span.x]) \
	or not _require(moves == expected, "With a stand-in system clock the game's time must follow it to the microsecond, a sleep and a correction included: %s, not %s." % [expected, moves]) \
	or not _require(held == 0.0 and stand_in_now == 0.0, "A pinned clock must hold still while the system clock runs 600 s (it moved %s), and Now be the system's time (%s off)." % [held, stand_in_now]) \
	or not _require(system_gap < 1.0 and running_now, "Now must be the real time, running (%.3f s off, running %s)." % [system_gap, running_now]) \
	or not _require(DayClock.revision() == revision + 6 and DayClock.now() == DayClock.RECORDED_UNIX, "Every jump must count (%d counted, 6 made) and pin() go back to the recorded moment." % (DayClock.revision() - revision)):
		return ""
	return "the system clock's speed (%.4f s against the system's %.4f s, and %.4f s with the time scale at 0); with a stand-in system clock, 12.5 s running, 7.25 s more paused, an hour asleep and a 2 s correction back carried the game's time exactly; held still when pinned; Now the real time" % [span.x, span.y, paused_span.x]


## DaySun on a Sun, an environment and a sky material of its own, copies of
## main.tscn's.
func _check_day_sun() -> String:
	var scene := (load(MAIN_SCENE) as PackedScene).instantiate()
	var scene_sun := scene.get_node("Sun") as DirectionalLight3D
	var scene_environment := (scene.get_node("WorldEnvironment") as WorldEnvironment).environment
	var scene_transform := scene_sun.transform
	# A light of its own with the Sun's colour and strength (a duplicate would take
	# the Sun's transform apart into a rotation and a scale a rounding off 1).
	var light := DirectionalLight3D.new()
	light.light_color = scene_sun.light_color
	light.light_energy = scene_sun.light_energy
	var environment := scene_environment.duplicate(true) as Environment
	scene.free()
	root.add_child(light)
	_nodes.append(light)
	var written := _record_globals()
	var day_sun := DaySun.new(light, environment)
	root.add_child(day_sun)
	_nodes.append(day_sun)
	await process_frame
	# Its first look hands the engine every global, at the recorded moment the values
	# project.godot gives them.
	var first_globals := written.duplicate()
	var recorded := _look_differences(light, environment, written, DayLight.at(DaySun.shown_angles(DayClock.RECORDED_UNIX)[0]))
	var project_globals := _project_globals()
	# The factors exactly; horizon_haze, worked out in 32-bit floats, to within
	# is_equal_approx of project.godot's (given there to 7 digits).
	var project := project_globals.keys().filter(func(value: String) -> bool: return not ((first_globals.get(value) is float and first_globals[value] == float(project_globals[value])) or (first_globals.get(value) is Vector3 and project_globals[value] is Vector3 and (first_globals[value] as Vector3).is_equal_approx(project_globals[value]))))
	if not _require(light.transform == scene_transform and recorded.is_empty() and project.is_empty() and first_globals.size() == DayLight.GLOBALS.size() and day_sun.sky == environment.sky.sky_material, "At the recorded moment DaySun must leave the light exactly as main.tscn's Sun and its look main.tscn's daylight, and its first look hand the engine every global (%s) at project.godot's values (it differs in %s; from project.godot in %s)." % [first_globals.keys(), recorded, project]):
		DaySun.use_engine_globals()
		return ""
	# Morning, noon, afternoon, dusk and night on the longest and shortest days and
	# on 2026-11-14: the light from the clock's sun (under the horizon too), through
	# east (+X) from north (-Z), and the look of its height on.
	var checked := 0
	var nights := 0
	for day: String in ["2026-06-21", "2026-12-21", "2026-11-14"]:
		for time: String in ["05:00", "09:30", "12:30", "15:30", "16:30", "17:00", "17:30", "20:30", "22:00"]:
			var unix := DayClock.parse_local("%s %s" % [day, time])
			DayClock.pin(unix)
			await process_frame
			var sun := SolarPosition.at(unix, DayClock.LATITUDE, DayClock.LONGITUDE)
			var shown := DaySun.shown_angles(unix)
			var kept_to := DaySun.angle_step(float(sun.elevation_deg))
			var true_sun: Array[float] = [snappedf(float(sun.elevation_deg), kept_to), snappedf(float(sun.azimuth_deg), kept_to)]
			var differences := _look_differences(light, environment, written, DayLight.at(shown[0]))
			if not _require(shown == true_sun and light.rotation_degrees.is_equal_approx(DaySun.rotation_for(shown)) and light.basis.z.is_equal_approx(SolarPosition.direction_to(shown[0], shown[1])), "At %s %s the light must shine from the sun at %s (%s), not from rotation %s." % [day, time, true_sun, shown, light.rotation_degrees]) \
			or not _require(day_sun.lit_elevation == shown[0] and differences.is_empty(), "At %s %s (the sun %.2f degrees up) DaySun must put on that height's look; it differs in %s." % [day, time, shown[0], differences]):
				DaySun.use_engine_globals()
				return ""
			checked += 1
			nights += 1 if shown[0] < 0.0 else 0
	# No jump: minute by minute through 2026-11-14's sunset and dusk, its solar
	# midnight, and 2026-11-15's dawn and sunrise.
	var largest := 0.0
	for span: Array in [["2026-11-14 15:30", 150], ["2026-11-14 23:15", 80], ["2026-11-15 05:45", 120]]:
		var unix := DayClock.parse_local(span[0])
		var last := DaySun.shown_angles(unix)
		for minute in int(span[1]):
			unix += 60.0
			var shown := DaySun.shown_angles(unix)
			largest = maxf(largest, rad_to_deg(SolarPosition.direction_to(last[0], last[1]).angle_to(SolarPosition.direction_to(shown[0], shown[1]))))
			last = shown
	# The sun moves at most about 0.25 degrees a minute along its path; just under the
	# horizon the refraction NOAA adds (SolarPosition) falls off quickly and the drawn
	# sun sinks up to twice as fast for a few minutes (0.34 degrees in a minute on
	# 2026-11-14). A jump, as midnight's side swap was, is tens of degrees.
	if not _require(largest < JUMP_BOUND_DEG, "The light must not jump through sunset, midnight or sunrise: it moved %.3f degrees in a minute (bound %.1f)." % [largest, JUMP_BOUND_DEG]):
		DaySun.use_engine_globals()
		return ""
	# Steps while time runs, on a stand-in system clock: 10 s with the sun high or
	# deep, shorter near the horizon (step_seconds), 10 s through the night floor
	# (step_for); a jump at once.
	var system := [1800000000.0]
	DayClock.system_clock = func() -> float: return system[0]
	var steps := []
	for trial: Array in [["2026-06-21 12:30", "high"], ["2026-11-14 16:50", "setting"], ["2026-11-14 17:55", "floor"], ["2026-11-14 22:00", "night"]]:
		var start := DayClock.parse_local(trial[0])
		var step := DaySun.step_for(DaySun.shown_angles(start)[0])
		DayClock.start_at(start)
		await process_frame
		var first := day_sun.shown_unix
		system[0] += step * 0.8
		await process_frame
		var within := day_sun.shown_unix
		system[0] += step * 0.4
		await process_frame
		var stepped := day_sun.shown_unix
		steps.append("%s %.2f s" % [trial[1], step])
		if not _require(first == start and within == start and is_equal_approx(stepped - start, step * 1.2), "%s (%s): the sun must step after %.2f s and not before (shown at %s, %s, %s from %s)." % [trial[0], trial[1], step, first, within, stepped, start]):
			DayClock.use_system_clock()
			DaySun.use_engine_globals()
			return ""
	var jump_from := DayClock.parse_local("2026-06-21 12:30")
	DayClock.start_at(jump_from + 3600.0)
	await process_frame
	var jumped := day_sun.shown_unix
	DayClock.use_system_clock()
	DayClock.pin()
	await process_frame
	var back := _look_differences(light, environment, written, DayLight.at(DaySun.shown_angles(DayClock.RECORDED_UNIX)[0]))
	DaySun.use_engine_globals()
	var shape := [DaySun.step_seconds(75.0), DaySun.step_seconds(30.0), DaySun.step_seconds(20.0), DaySun.step_seconds(10.0), DaySun.step_seconds(5.0), DaySun.step_seconds(-6.0), DaySun.step_seconds(-40.0), DaySun.step_for(-6.0), DaySun.step_for(-10.0)]
	if not _require(jumped == jump_from + 3600.0 and light.transform == scene_transform and back.is_empty(), "A jump must move the sun at once (shown %s for %s), and pinned again the light must be main.tscn's Sun with main.tscn's daylight (it differs in %s)." % [jumped, jump_from + 3600.0, back]) \
	or not _require(shape[0] == DaySun.STEP_S and shape[1] == DaySun.STEP_S and shape[2] < shape[1] and shape[3] < shape[2] and shape[3] < 1.5 and shape[4] == DaySun.MIN_STEP_S and shape[5] < shape[3] and shape[6] == DaySun.STEP_S and shape[7] == shape[5] and shape[8] == DaySun.STEP_S, "The step must be STEP_S from FULL_STEP_ELEVATION_DEG up or down and shorter near the horizon, to MIN_STEP_S, and STEP_S through the night floor: %s at 75, 30, 20, 10, 5, -6 and -40 degrees, then step_for at -6 and -10." % [shape]):
		return ""
	return "the light from the clock's sun with its height's look at %d moments (%d with the sun under the horizon; the first look hands the engine all %d globals at project.godot's values), no jump through sunset, midnight and sunrise (%.2f degrees a minute at most), in steps while time runs (%s; %.1f s at 10 degrees, 10 s through the floor) and at once on a jump, and main.tscn's again when pinned" % [checked, nights, DayLight.GLOBALS.size(), largest, ", ".join(PackedStringArray(steps)), shape[3]]


## The light's curves (DayLight): their table, full day from FULL_DAY_ELEVATION_DEG
## up, the way down through sunset in DaySun's own steps, the night floor through
## the night, and dawn the same as dusk.
func _check_day_light() -> String:
	# The table: every value in every key, falling heights, the floor last.
	var keys := DayLight.KEYS
	if not _require(float(keys[0].elevation) == DayLight.FULL_DAY_ELEVATION_DEG and keys[keys.size() - 1] == DayLight.NIGHT_FLOOR and float(DayLight.NIGHT_FLOOR.elevation) == DayLight.FLOOR_ELEVATION_DEG, "DayLight's keys must start at full day (%.1f) and end with the night floor (%.1f)." % [DayLight.FULL_DAY_ELEVATION_DEG, DayLight.FLOOR_ELEVATION_DEG]):
		return ""
	for index in keys.size():
		var key: Dictionary = keys[index]
		var named := key.keys()
		named.erase("elevation")
		named.sort()
		var wanted: Array = DayLight.VALUES.duplicate()
		wanted.sort()
		var typed := named == wanted and DayLight.VALUES.all(func(value: String) -> bool: return typeof(key[value]) == typeof(DayLight.NIGHT_FLOOR[value]) and typeof(key[value]) in [TYPE_COLOR, TYPE_FLOAT])
		if not _require(typed and (index == 0 or float(key.elevation) < float(keys[index - 1].elevation)), "DayLight's key %d (at %s degrees) must hold every value, each a colour or a float as the floor's, below the key before it." % [index, key.get("elevation")]):
			return ""
	# Full day: the first key exactly at any height from there up.
	for height: float in [DayLight.FULL_DAY_ELEVATION_DEG, 33.43, 52.3, 75.6, 90.0]:
		if not _require(DayLight.at(height) == DayLight.at(DayLight.FULL_DAY_ELEVATION_DEG), "At %.2f degrees, above full day, the look must be daylight's exactly." % height):
			return ""
	# Down through sunset in DaySun's steps on three dates, from full day to the
	# floor: nothing brightens as the sun sinks, the exposure only rises, and no
	# step changes a value by more than its bound (BOUNDS: sun energy, ambient
	# light, fog, sky, exposure and the horizon's factor).
	var worst := {}
	for name: String in STEP_BOUNDS:
		worst[name] = 0.0
	var steps := 0
	for day: String in ["2026-06-21", "2026-12-21", "2026-11-14"]:
		var unix := _crossing(DayClock.parse_local("%s 12:00" % day), DayLight.FULL_DAY_ELEVATION_DEG, true)
		var last := _measures(DayLight.at(DaySun.shown_angles(unix)[0]))
		while DaySun.shown_angles(unix)[0] > DayLight.FLOOR_ELEVATION_DEG - 0.5:
			unix += DaySun.step_seconds(DaySun.shown_angles(unix)[0])
			var now := _measures(DayLight.at(DaySun.shown_angles(unix)[0]))
			steps += 1
			for name: String in STEP_BOUNDS:
				var change: float = now[name] - last[name]
				worst[name] = maxf(worst[name], absf(change))
				var wrong_way := change < -1e-9 if name == "exposure" else change > 1e-9
				if not _require(not wrong_way and absf(change) <= float(STEP_BOUNDS[name]), "On %s at %.2f degrees, one step of the sun changed %s by %.5f (bound %.4f; it must %s as the sun sinks)." % [day, DaySun.shown_angles(unix)[0], name, change, STEP_BOUNDS[name], "only rise" if name == "exposure" else "not rise"]):
					return ""
			last = now
	# The night floor: reached at FLOOR_ELEVATION_DEG and held all night, solar
	# midnight included, every five minutes until dawn comes back past it.
	var floor_look := DayLight.at(DayLight.FLOOR_ELEVATION_DEG)
	var floor_values := DayLight.VALUES.all(func(value: String) -> bool: return floor_look[value] == DayLight.NIGHT_FLOOR[value])
	if not _require(floor_values and DayLight.at(-75.0) == floor_look, "At and under %.1f degrees the look must be the night floor's." % DayLight.FLOOR_ELEVATION_DEG):
		return ""
	var night_samples := 0
	for day: String in ["2026-06-21", "2026-12-21", "2026-11-14"]:
		var dusk := _crossing(DayClock.parse_local("%s 12:00" % day), DayLight.FLOOR_ELEVATION_DEG, true)
		var dawn := _crossing(DayClock.parse_local("%s 12:00" % day) + 86400.0, DayLight.FLOOR_ELEVATION_DEG, false)
		var unix := dusk + 1.0
		while unix < dawn - 1.0:
			var height := DaySun.shown_angles(unix)[0]
			if not _require(DayLight.is_floor(height) and DayLight.at(height) == floor_look, "The night of %s must hold the night floor (at %.2f degrees, %s)." % [day, height, DayClock.local(unix)]):
				return ""
			night_samples += 1
			unix += 300.0
	# Dawn mirrors dusk: the same height morning and evening gives the same look,
	# put on by DaySun.
	var light := DirectionalLight3D.new()
	root.add_child(light)
	_nodes.append(light)
	var scene := (load(MAIN_SCENE) as PackedScene).instantiate()
	var environment := (scene.get_node("WorldEnvironment") as WorldEnvironment).environment.duplicate(true) as Environment
	scene.free()
	var written := _record_globals()
	var day_sun := DaySun.new(light, environment)
	root.add_child(day_sun)
	_nodes.append(day_sun)
	var mirrored := 0
	for height: float in [25.0, 20.0, 10.0, 5.0, 2.0, 0.5, 0.0, -1.0, -3.0, -6.0]:
		var noon := DayClock.parse_local("2026-11-14 12:00")
		var evening := _crossing(noon, height, true)
		var morning := _crossing(noon, height, false)
		var looks := []
		for unix: float in [evening, morning]:
			DayClock.pin(unix)
			await process_frame
			looks.append([DaySun.shown_angles(unix)[0], environment.ambient_light_color, environment.ambient_light_energy, environment.fog_light_color, environment.tonemap_exposure, light.light_color, light.light_energy, environment.sky.sky_material.get_shader_parameter(&"sky_horizon_color"), written.duplicate()])
		if not _require(looks[0] == looks[1], "At %.1f degrees dawn must look as dusk does: %s in the evening, %s in the morning." % [height, looks[0], looks[1]]):
			DaySun.use_engine_globals()
			return ""
		mirrored += 1
	DaySun.use_engine_globals()
	DayClock.pin()
	await process_frame
	var bounds := PackedStringArray()
	for name: String in STEP_BOUNDS:
		bounds.append("%s %.4f (bound %.3f)" % [name, worst[name], STEP_BOUNDS[name]])
	return "the light's curves: daylight from %.0f degrees up, %d steps of the sun from there to the floor on three dates with nothing brightening and the largest changes a step %s, the night floor from %.0f degrees all night (%d samples, solar midnight among them), dawn the same as dusk at %d heights" % [DayLight.FULL_DAY_ELEVATION_DEG, steps, ", ".join(bounds), DayLight.FLOOR_ELEVATION_DEG, night_samples, mirrored]


## How much each of the look's lights changes by: the sun's energy; the ambient
## light, the fog and the sky's horizon and zenith as linear luminance times
## energy; the exposure; the horizon art's factor.
func _measures(look: Dictionary) -> Dictionary:
	return {
		"sun_energy": float(look.sun_energy),
		"ambient": (look.ambient_color as Color).srgb_to_linear().get_luminance() * float(look.ambient_energy),
		"fog": (look.fog_color as Color).srgb_to_linear().get_luminance() * float(look.fog_energy),
		"sky_horizon": (look.sky_horizon as Color).srgb_to_linear().get_luminance(),
		"sky_top": (look.sky_top as Color).srgb_to_linear().get_luminance(),
		"exposure": float(look.exposure),
		"horizon_light": float(look.horizon_light),
	}


## The instant after (evening) or before (morning) solar noon nearest `around`
## when the sun's true height is `height_deg`, to a millisecond.
func _crossing(around: float, height_deg: float, evening: bool) -> float:
	var sun := SolarPosition.at(around, DayClock.LATITUDE, DayClock.LONGITUDE)
	var noon := around - float(sun.hour_angle_deg) / 15.0 * 3600.0
	var high := noon
	var low := noon + (12.0 if evening else -12.0) * 3600.0
	for _halving in 40:
		var middle := 0.5 * (low + high)
		if float(SolarPosition.at(middle, DayClock.LATITUDE, DayClock.LONGITUDE).elevation_deg) >= height_deg:
			high = middle
		else:
			low = middle
	return high


## The options screen's date and time, on desktop and on the web.
func _check_options_rows() -> String:
	var hud := (load("res://game/scenes/ui/hud.tscn") as PackedScene).instantiate() as GameHUD
	root.add_child(hud)
	_nodes.append(hud)
	hud.set_time_controls(true)
	hud.show_world_ready()
	hud.set_paused(true)
	hud.options_button.pressed.emit()
	await process_frame
	var rows := [hud.time_heading, hud.time_date_row, hud.time_row, hud.time_note]
	var shown := rows.all(func(row: Control) -> bool: return row.is_visible_in_tree())
	var recorded := [hud.time_date_label.text, hud.time_label.text, hud.time_note.text, hud.time_date_slider.value, hud.time_slider.value]
	if not _require(shown and recorded == ["Fri 13 Nov 2026", "12:30 PST", "", 317.0, 750.0], "The options screen must show the date and time at the recorded moment: Fri 13 Nov 2026, 12:30 PST, day 317 and minute 750 on the sliders, no night note (shown %s: %s)." % [shown, recorded]):
		return ""
	# The date slider (a player's change): the same time on 21 June, PDT, running.
	hud.time_date_slider.value = 172
	var june := [hud.time_date_label.text, hud.time_label.text, DayClock.is_running(), DayClock.now() - DayClock.parse_local("2026-06-21 12:30")]
	hud.time_slider.value = 1380
	var night := [hud.time_label.text, hud.time_note.text, DayClock.now() - DayClock.parse_local("2026-06-21 23:00")]
	hud.time_slider.value = 570
	var morning := [hud.time_label.text, hud.time_note.text]
	if not _require(june.slice(0, 3) == ["Sun 21 Jun 2026", "12:30 PDT", true] and absf(june[3]) < 1.0, "The date slider at day 172 must jump the clock to Sun 21 Jun 2026 12:30 PDT, running, not %s." % [june]) \
	or not _require(night.slice(0, 2) == ["23:00 PDT", GameHUD.NIGHT_NOTE] and absf(night[2]) < 1.0, "The time slider at 23:00 must jump there and say night comes later, not %s." % [night]) \
	or not _require(morning == ["09:30 PDT", ""], "The time slider at 09:30 must jump there, with no night note, not %s." % [morning]):
		return ""
	hud.time_now_button.pressed.emit()
	var real := absf(DayClock.now() - Time.get_unix_time_from_system())
	var now_running := DayClock.is_running()
	DayClock.pin()
	if not _require(real < 1.0 and now_running, "Now must go back to the real time, running (%.3f s off, running %s)." % [real, now_running]):
		return ""
	# The web's options screen: none of it.
	hud.set_time_controls(false)
	await process_frame
	var hidden := rows.all(func(row: Control) -> bool: return not row.is_visible_in_tree())
	if not _require(hidden and not hud.time_controls_shown(), "On the web the options screen must show no date or time."):
		return ""
	return "the options screen's date and time (Fri 13 Nov 2026 12:30 PST; Sun 21 Jun 12:30 PDT from the date slider, 23:00 with the night note and 09:30 from the time slider; Now; none on the web)"


## The switch (DayClock.enabled): on unless --no-time-of-day is on the command line,
## the project setting is false or the build is the web's. With the setting turned
## off at run time and the clock started again, as a run starts: the clock holds the
## recorded moment, not running, and start_at, start_now and pin move it nowhere; a
## DaySun on copies of main.tscn's Sun and look writes nothing through frames and a
## follow(true) (the Sun's transform and light and the look main.tscn's daylight, no
## global uniform handed over, nothing shown, not processing). Then the setting and
## the clock as they were: on, held for this driver at the recorded moment.
func _check_switch_off() -> String:
	var reasons := [
		DayClock.off_reason_for(PackedStringArray(["--solar-table", "table.json"]), true, false),
		DayClock.off_reason_for(PackedStringArray([DayClock.OFF_ARGUMENT]), true, false),
		DayClock.off_reason_for(PackedStringArray(), false, false),
		DayClock.off_reason_for(PackedStringArray(), true, true),
	]
	var kept: Variant = ProjectSettings.get_setting(DayClock.ENABLED_SETTING)
	if not _require(reasons[0] == "" and not reasons.slice(1).has("") and DayClock.enabled() and kept == true, "The time of day must be on unless %s is on the command line, %s is false or the build is the web's (reasons %s; on now %s, project.godot's setting %s)." % [DayClock.OFF_ARGUMENT, DayClock.ENABLED_SETTING, reasons, DayClock.enabled(), kept]):
		return ""
	ProjectSettings.set_setting(DayClock.ENABLED_SETTING, false)
	DayClock.restart()
	var off := [DayClock.enabled(), DayClock.off_reason(), DayClock.now(), DayClock.is_running()]
	var revision := DayClock.revision()
	DayClock.start_at(DayClock.parse_local("2026-06-21 20:30"))
	DayClock.start_now()
	DayClock.pin(DayClock.parse_local("2026-12-21 17:00"))
	var jumped := [DayClock.now(), DayClock.is_running(), DayClock.revision() - revision]
	# DaySun on copies of main.tscn's Sun (its transform set whole, not taken apart)
	# and its environment with the sky material.
	var scene := (load(MAIN_SCENE) as PackedScene).instantiate()
	var scene_sun := scene.get_node("Sun") as DirectionalLight3D
	var light := DirectionalLight3D.new()
	light.transform = scene_sun.transform
	for property: StringName in [&"light_color", &"light_energy", &"light_specular"]:
		light.set(property, scene_sun.get(property))
	var scene_transform := light.transform
	var environment := (scene.get_node("WorldEnvironment") as WorldEnvironment).environment.duplicate(true) as Environment
	scene.free()
	root.add_child(light)
	_nodes.append(light)
	var written := _record_globals()
	var day_sun := DaySun.new(light, environment)
	root.add_child(day_sun)
	_nodes.append(day_sun)
	for _frame in 3:
		await process_frame
	day_sun.follow(true)
	var differences := _look_differences(light, environment, written, DayLight.at(DaySun.shown_angles(DayClock.RECORDED_UNIX)[0]))
	var inert := [light.transform == scene_transform, differences.is_empty(), written.size(), is_nan(day_sun.shown_unix), is_nan(day_sun.lit_elevation), day_sun.is_processing()]
	DaySun.use_engine_globals()
	ProjectSettings.set_setting(DayClock.ENABLED_SETTING, kept)
	DayClock.restart()
	var back := [DayClock.enabled(), DayClock.now(), DayClock.is_running()]
	if not _require(off == [false, reasons[2], DayClock.RECORDED_UNIX, false] and jumped == [DayClock.RECORDED_UNIX, false, 0], "With %s false the time of day must be off for that reason and its clock hold the recorded moment whatever jumps it (off: %s; after start_at, start_now and pin: %s)." % [DayClock.ENABLED_SETTING, off, jumped]) \
	or not _require(inert == [true, true, 0, true, true, false], "With the time of day off DaySun must write nothing: main.tscn's Sun and look untouched, no global handed over, nothing shown and no processing (transform kept, look kept, globals, nothing shown, nothing lit, processing: %s; the look differs in %s)." % [inert, differences]) \
	or not _require(back == [true, DayClock.RECORDED_UNIX, false], "With the setting back the time of day must be on again, the clock held for this driver at the recorded moment (%s)." % [back]):
		return ""
	return "the switch: on unless %s, the setting %s false or the web; turned off, the clock held at the recorded moment through start_at, start_now and pin, and DaySun writing nothing to main.tscn's Sun, its look or the globals" % [DayClock.OFF_ARGUMENT, DayClock.ENABLED_SETTING]


## How far the game's clock and the system clock run while REAL_SPAN_S of real time
## passes, waited inside one frame: (clock seconds, system seconds).
func _real_span() -> Vector2:
	var begun := Time.get_ticks_usec()
	var clock := DayClock.now()
	var system := Time.get_unix_time_from_system()
	while Time.get_ticks_usec() - begun < int(REAL_SPAN_S * 1000000.0):
		pass
	return Vector2(DayClock.now() - clock, Time.get_unix_time_from_system() - system)


func _utc(year: int, month: int, day: int, hour: int, minute: int, second: int) -> int:
	return Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": day, "hour": hour, "minute": minute, "second": second})


func _require(condition: bool, message: String) -> bool:
	if not condition and _failure == "":
		_failure = message
	return condition


func _finish(timeout_message := "") -> void:
	if timeout_message != "" and _failure == "":
		_failure = timeout_message
	for node: Node in _nodes:
		if is_instance_valid(node):
			node.free()
	_nodes.clear()
	if _failure != "":
		push_error("FAIL: " + _failure)
		print("FAIL: " + _failure)
		quit(1)
	else:
		quit(0)
