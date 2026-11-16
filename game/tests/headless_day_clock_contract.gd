extends SceneTree
## The time of day (owner, 2026-11-14: the sun of the island's date and time,
## running at real speed, with a date and a time slider; 2026-11-16: play always
## starts in good light), headless and without the world. The Sun following it in the loaded game, and the sliders
## worked there, are headless_gameplay_contract.gd's.
##   - a test driver's clock is held at the recorded moment (main.tscn's Sun), and
##     the sun drawn there is main.tscn's Sun exactly;
##   - play starts at the recorded moment's time of day, 12:30, on the island's
##     date at the real time, whatever that time is (in the night, either side of
##     midnight, an evening when the UTC date has already turned, either side of
##     both daylight-saving changes), running; held at the recorded moment with
##     the time of day off and in a test or capture run; from that start time runs
##     on at real speed, and Now jumps to the real time;
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
##     on a jump, with no jump of its own through sunset, sunrise and midnight; with
##     no strength it lights the sky alone (no shadow splits), and it keeps the
##     look's darkness for the night lights; while the sun shines, low too, a glint
##     on glass and its bloom are daylight's (owner, 2026-11-15: the Sun's specular
##     and the glow's luminance cap main.tscn's);
##   - the light of the sun's height (DayLight's curves): main.tscn's daylight exactly
##     at and above the full-day height, the recorded moment included, where DaySun
##     writes nothing to the Sun, the environment or the sky; dimming through sunset
##     and dusk without a step larger than its bound (the stars and the darkness
##     only rising, the parked cars' lamps and the buildings' daylight fills only
##     going out), to the night floor, which holds all night; dawn the same as dusk
##     at the same height; and DaySun putting it on;
##   - the night lights' rule (NightLights): on at ON_AT, off again only under
##     OFF_AT, fading over FADE_S, off by day and on at night; the flashlight's
##     pitch from the camera's (the lights in the loaded game are
##     headless_vehicle_contract.gd's);
##   - the options screen's date and time read the island's clock (PST and PDT),
##     its sliders jump the clock and time runs on, Now jumps to the real time, and
##     the web's options screen has none of it; the time slider marks the shown
##     date's sunrise and sunset (owner, 2026-11-16: night is experimental) where a
##     click puts those times, and the marks move with the date; "Night is
##     experimental" shows beside the heading by day and at night, and on a phone's
##     touch layout inside the panel, clear of the heading;
##   - the switch (DayClock.enabled; owner, 2026-11-15: the whole time of day
##     behind one flag): --no-time-of-day on the command line, the project setting
##     off and the web build each turn it off, and nothing else; with the setting
##     turned off as a run starts the clock holds the recorded moment whatever
##     jumps it, DaySun writes nothing to main.tscn's Sun and look, nor any global
##     uniform, and keeps the day's darkness (0), the shadows' whole reach and the
##     buildings' daylight fills lit even with the clock pinned at night, and
##     NightLights is neither wanted nor makes a light.
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
## A daylight fill's and a lamp's own emission in the glow checks (_glow_fixture).
const FILL_ENERGY := 0.45
const LAMP_ENERGY := 0.5
## The most one step of the sun (DaySun.step_seconds, at most 10 s) may change each of
## the look's lights by on the way down (_measures): far less than the eye sees
## change at once.
const STEP_BOUNDS := {
	"sun_energy": 0.01, "ambient": 0.001, "fog": 0.002, "sky_horizon": 0.002,
	"sky_top": 0.001, "exposure": 0.002, "horizon_light": 0.004,
	"stars": 0.01, "night": 0.01, "parked_lamps": 0.01, "shadow_reach": 0.02, "daylight_fill": 0.02,
}
## The measures that only rise as the sun sinks; every other one must not rise.
const RISING := ["exposure", "stars", "night"]

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
	var start := _check_start()
	if start.is_empty():
		return _finish()
	var sun := await _check_day_sun()
	if sun.is_empty():
		return _finish()
	var light := await _check_day_light()
	if light.is_empty():
		return _finish()
	var lights := _check_night_lights()
	if lights.is_empty():
		return _finish()
	var menu := await _check_options_rows()
	if menu.is_empty():
		return _finish()
	var switch := await _check_switch_off()
	if switch.is_empty():
		return _finish()
	print("PASS: day clock: %s; %s; %s; %s; %s; %s; %s; %s; %s; %s" % [solar, recorded, island, running, start, sun, light, lights, menu, switch])
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


## Play's start (DayClock.start_for, start_instant; owner, 2026-11-16: "always start
## the game during a time with nice lighting"): 12:30 on the island's date at the
## real time, whatever the real time, running; held at the recorded moment with the
## time of day off or in a test or capture run. From a start in the night, on a
## stand-in system clock, time runs on at real speed, and Now jumps to the real
## (night) time.
func _check_start() -> String:
	# [the real time on the island's clock, the start it must give].
	var cases := [
		["2026-11-16 23:30", "2026-11-16 12:30 PST"],
		["2026-11-16 03:10", "2026-11-16 12:30 PST"],
		["2026-11-16 17:00", "2026-11-16 12:30 PST"],
		["2026-11-16 23:59", "2026-11-16 12:30 PST"],
		["2026-11-17 00:00", "2026-11-17 12:30 PST"],
		["2026-12-31 23:59", "2026-12-31 12:30 PST"],
		["2027-01-01 00:01", "2027-01-01 12:30 PST"],
		["2026-10-31 23:00", "2026-10-31 12:30 PDT"],
		["2026-11-01 01:30", "2026-11-01 12:30 PST"],
		["2026-11-01 03:00", "2026-11-01 12:30 PST"],
		["2026-03-07 23:00", "2026-03-07 12:30 PST"],
		["2026-03-08 01:30", "2026-03-08 12:30 PDT"],
		["2026-03-08 03:30", "2026-03-08 12:30 PDT"],
		["2026-06-21 12:30", "2026-06-21 12:30 PDT"],
	]
	var wrong := []
	for case: Array in cases:
		var real := DayClock.parse_local(case[0])
		var start := DayClock.start_for(true, false, real)
		var shown := DayClock.moment_text(float(start[0]))
		if shown != case[1] or start[1] != true:
			wrong.append("%s gave %s (running %s), not %s" % [case[0], shown, start[1], case[1]])
	# 01:30 on 2026-11-01 comes twice; the second (PST, an hour later) starts the same day.
	var second := DayClock.parse_local("2026-11-01 01:30") + 3600.0
	if DayClock.moment_text(second) != "2026-11-01 01:30 PST" or DayClock.moment_text(DayClock.start_instant(second)) != "2026-11-01 12:30 PST":
		wrong.append("the second 01:30 on 2026-11-01 (%s) gave %s" % [DayClock.moment_text(second), DayClock.moment_text(DayClock.start_instant(second))])
	var night := DayClock.parse_local("2026-11-16 23:30")
	var held := [DayClock.start_for(true, true, night), DayClock.start_for(false, false, night), DayClock.start_for(false, true, night)]
	if not _require(wrong.is_empty(), "Play must start at 12:30 on the island's date at the real time: %s." % ", ".join(PackedStringArray(wrong))) \
	or not _require(held.all(func(start: Array) -> bool: return start == [DayClock.RECORDED_UNIX, false]), "A test or capture run, and a run with the time of day off, must start held at the recorded moment: %s." % [held]):
		return ""
	# A start in the night, on a stand-in system clock: time runs on at real speed
	# from 12:30, and Now jumps to the real night.
	var system := [night]
	DayClock.system_clock = func() -> float: return system[0]
	var start_unix := float(DayClock.start_for(true, false, float(system[0]))[0])
	DayClock.start_at(start_unix)
	var at_start := [DayClock.now() - start_unix, DayClock.is_running()]
	system[0] += 600.0
	var later := DayClock.now() - start_unix
	DayClock.start_now()
	var at_now := [DayClock.now() - float(system[0]), DayClock.is_running(), DayClock.moment_text(DayClock.now())]
	DayClock.use_system_clock()
	DayClock.pin()
	if not _require(at_start == [0.0, true] and later == 600.0 and at_now == [0.0, true, "2026-11-16 23:40 PST"], "Started at 12:30 from a real 23:30, time must run on with the system clock and Now jump to the real time (at the start %s, after 600 s %s, Now %s)." % [at_start, later, at_now]):
		return ""
	return "play starting at 12:30 on the island's date for %d real times (in the night, at 03:10, an evening past UTC's midnight, either side of midnight and of the new year, either side of November's and March's changes, the repeated 01:30 both times), held at the recorded moment in a test run and with the time of day off; from a start at a real 23:30 the time ran 600 s with the system clock and Now jumped to 23:40" % (cases.size() + 1)


## DaySun on a Sun, an environment and a sky material of its own, copies of
## main.tscn's.
func _check_day_sun() -> String:
	var scene := (load(MAIN_SCENE) as PackedScene).instantiate()
	var scene_sun := scene.get_node("Sun") as DirectionalLight3D
	var scene_environment := (scene.get_node("WorldEnvironment") as WorldEnvironment).environment
	var scene_transform := scene_sun.transform
	# A light of its own with the Sun's colour, strength and specular (a duplicate
	# would take the Sun's transform apart into a rotation and a scale a rounding off 1).
	var light := DirectionalLight3D.new()
	light.light_color = scene_sun.light_color
	light.light_energy = scene_sun.light_energy
	light.light_specular = scene_sun.light_specular
	# A glint on glass and its bloom: the Sun's specular and the glow's luminance cap.
	var glint := [scene_sun.light_specular, scene_environment.glow_hdr_luminance_cap]
	var environment := scene_environment.duplicate(true) as Environment
	scene.free()
	root.add_child(light)
	_nodes.append(light)
	var written := _record_globals()
	var day_sun := DaySun.new(light, environment)
	# The player's shadow option, which takes the look's shadow reach.
	var quality := ShadowQuality.new(light)
	quality.apply("medium")
	var medium_distance := float(quality.settings_of("medium").max_distance)
	var near_split_m := float((quality.settings_of("medium").splits as Array)[0]) * medium_distance
	day_sun.shadow_quality = quality
	root.add_child(day_sun)
	_nodes.append(day_sun)
	await process_frame
	if not _require(quality.reach == 1.0 and light.directional_shadow_max_distance == medium_distance, "At the recorded moment the sun's shadows must reach the shadow option's whole distance (reach %s, %.1f m of %.1f)." % [quality.reach, light.directional_shadow_max_distance, medium_distance]):
		DaySun.use_engine_globals()
		return ""
	# A building's glows (DaySun.collect_fills): a daylight fill and a lamp, found at
	# the recorded moment and left as they are there.
	var glows := _glow_fixture()
	day_sun.collect_fills(glows.root)
	if not _require(day_sun.fills.size() == 1 and day_sun.fills.has(glows.fill) and day_sun.fill_share == 1.0 and glows.fill.emission_energy_multiplier == glows.fill_energy and glows.lamp.emission_energy_multiplier == glows.lamp_energy, "At the recorded moment DaySun must find the daylight fill alone and leave both glows as they are (fills %s, share %s, fill %s, lamp %s)." % [day_sun.fills.size(), day_sun.fill_share, glows.fill.emission_energy_multiplier, glows.lamp.emission_energy_multiplier]):
		DaySun.use_engine_globals()
		return ""
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
	var sky_only := 0
	var fills_out := 0
	var low_glints := 0
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
			or not _require(day_sun.lit_elevation == shown[0] and differences.is_empty(), "At %s %s (the sun %.2f degrees up) DaySun must put on that height's look; it differs in %s." % [day, time, shown[0], differences]) \
			or not _require(is_equal_approx(light.directional_shadow_max_distance, medium_distance * float(DayLight.at(shown[0]).shadow_reach)) and is_equal_approx(light.directional_shadow_split_1 * light.directional_shadow_max_distance, near_split_m), "At %s %s (the sun %.2f degrees up) the sun's shadows must reach the shadow option's distance times that height's shadow reach (%.1f m, not %.1f), the nearest split still ending %.1f m out (not %.1f)." % [day, time, shown[0], medium_distance * float(DayLight.at(shown[0]).shadow_reach), light.directional_shadow_max_distance, near_split_m, light.directional_shadow_split_1 * light.directional_shadow_max_distance]) \
			or not _require(light.sky_mode == DaySun.sky_mode_for(float(DayLight.at(shown[0]).sun_energy)) and day_sun.night == float(DayLight.at(shown[0]).night), "At %s %s (the sun %.2f degrees up, energy %.3f) the light must light the sky alone only with no strength (sky mode %d) and DaySun keep that height's darkness (%.3f, not %.3f)." % [day, time, shown[0], light.light_energy, light.sky_mode, float(DayLight.at(shown[0]).night), day_sun.night]) \
			or not _require(is_equal_approx(glows.fill.emission_energy_multiplier, glows.fill_energy * float(DayLight.at(shown[0]).daylight_fill)) and glows.lamp.emission_energy_multiplier == glows.lamp_energy, "At %s %s (the sun %.2f degrees up) the daylight fill must keep that height's share of its emission (%.3f of %.2f: %.4f) and the lamp all of its own (%.2f: %.4f)." % [day, time, shown[0], float(DayLight.at(shown[0]).daylight_fill), FILL_ENERGY, glows.fill.emission_energy_multiplier, LAMP_ENERGY, glows.lamp.emission_energy_multiplier]) \
			or not _require(light.light_energy <= 0.0 or [light.light_specular, environment.glow_hdr_luminance_cap] == glint, "At %s %s (the sun %.2f degrees up) the sun's glint on glass and its bloom must be daylight's while it shines (owner, 2026-11-15): the Sun's specular and the glow's luminance cap %s, not %s." % [day, time, shown[0], glint, [light.light_specular, environment.glow_hdr_luminance_cap]]):
				DaySun.use_engine_globals()
				return ""
			low_glints += 1 if light.light_energy > 0.0 and shown[0] < 15.0 else 0
			fills_out += 1 if glows.fill.emission_energy_multiplier == 0.0 else 0
			checked += 1
			nights += 1 if shown[0] < 0.0 else 0
			sky_only += 1 if light.sky_mode == DirectionalLight3D.SKY_MODE_SKY_ONLY else 0
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
	for trial: Array in [["2026-06-21 12:30", "high"], ["2026-11-14 16:50", "setting"], ["2026-11-14 17:55", "dusk"], ["2026-11-14 18:40", "floor"], ["2026-11-14 22:00", "night"]]:
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
	var shape := [DaySun.step_seconds(75.0), DaySun.step_seconds(30.0), DaySun.step_seconds(20.0), DaySun.step_seconds(10.0), DaySun.step_seconds(5.0), DaySun.step_seconds(-6.0), DaySun.step_seconds(-40.0), DaySun.step_for(-12.0), DaySun.step_for(-20.0)]
	if not _require(jumped == jump_from + 3600.0 and light.transform == scene_transform and back.is_empty() and glows.fill.emission_energy_multiplier == glows.fill_energy and day_sun.fill_share == 1.0 and fills_out > 0, "A jump must move the sun at once (shown %s for %s), and pinned again the light must be main.tscn's Sun with main.tscn's daylight (it differs in %s) and the daylight fill its own emission exactly (%s, share %s; out at %d moments)." % [jumped, jump_from + 3600.0, back, glows.fill.emission_energy_multiplier, day_sun.fill_share, fills_out]) \
	or not _require(low_glints > 0, "The glint check must see the sun shining under 15 degrees at one moment at least (it saw %d)." % low_glints) \
	or not _require(shape[0] == DaySun.STEP_S and shape[1] == DaySun.STEP_S and shape[2] < shape[1] and shape[3] < shape[2] and shape[3] < 1.5 and shape[4] == DaySun.MIN_STEP_S and shape[5] < shape[3] and shape[6] == DaySun.STEP_S and shape[7] == DaySun.step_seconds(-12.0) and shape[7] < DaySun.STEP_S and shape[8] == DaySun.STEP_S, "The step must be STEP_S from FULL_STEP_ELEVATION_DEG up or down and shorter near the horizon, to MIN_STEP_S, and STEP_S through the night floor: %s at 75, 30, 20, 10, 5, -6 and -40 degrees, then step_for at -12 (above the floor) and -20." % [shape]):
		return ""
	return "the light from the clock's sun with its height's look at %d moments (%d with the sun under the horizon, %d of them lighting the sky alone, the daylight fill out at %d and the lamp lit at all, the glint daylight's wherever the sun shone, %d of them under 15 degrees; the first look hands the engine all %d globals at project.godot's values), no jump through sunset, midnight and sunrise (%.2f degrees a minute at most), in steps while time runs (%s; %.1f s at 10 degrees, 10 s through the floor) and at once on a jump, and main.tscn's again when pinned, the fill's own emission back exactly" % [checked, nights, sky_only, fills_out, low_glints, DayLight.GLOBALS.size(), largest, ", ".join(PackedStringArray(steps)), shape[3]]


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
				var wrong_way := change < -1e-9 if name in RISING else change > 1e-9
				if not _require(not wrong_way and absf(change) <= float(STEP_BOUNDS[name]), "On %s at %.2f degrees, one step of the sun changed %s by %.5f (bound %.4f; it must %s as the sun sinks)." % [day, DaySun.shown_angles(unix)[0], name, change, STEP_BOUNDS[name], "only rise" if name in RISING else "not rise"]):
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
	for height: float in [25.0, 20.0, 10.0, 5.0, 2.0, 0.5, 0.0, -1.0, -3.0, -6.0, -9.0, -12.0, -15.0]:
		var noon := DayClock.parse_local("2026-11-14 12:00")
		var evening := _crossing(noon, height, true)
		var morning := _crossing(noon, height, false)
		var looks := []
		for unix: float in [evening, morning]:
			DayClock.pin(unix)
			await process_frame
			looks.append([DaySun.shown_angles(unix)[0], environment.ambient_light_color, environment.ambient_light_energy, environment.fog_light_color, environment.tonemap_exposure, light.light_color, light.light_energy, environment.sky.sky_material.get_shader_parameter(&"sky_horizon_color"), environment.sky.sky_material.get_shader_parameter(&"star_energy"), light.sky_mode, day_sun.night, written.duplicate()])
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
## energy; the exposure; the horizon art's factor; the stars, the darkness, the
## parked cars' lamps and the sun's shadow reach.
func _measures(look: Dictionary) -> Dictionary:
	return {
		"sun_energy": float(look.sun_energy),
		"ambient": (look.ambient_color as Color).srgb_to_linear().get_luminance() * float(look.ambient_energy),
		"fog": (look.fog_color as Color).srgb_to_linear().get_luminance() * float(look.fog_energy),
		"sky_horizon": (look.sky_horizon as Color).srgb_to_linear().get_luminance(),
		"sky_top": (look.sky_top as Color).srgb_to_linear().get_luminance(),
		"exposure": float(look.exposure),
		"horizon_light": float(look.horizon_light),
		"stars": float(look.stars),
		"night": float(look.night),
		"parked_lamps": float(look.parked_lamps),
		"shadow_reach": float(look.shadow_reach),
		"daylight_fill": float(look.daylight_fill),
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


## A building's glows for DaySun to find: a daylight fill and a lamp, each on a box
## under one root (in the tree, freed with the run's other nodes), with their own
## emission as the materials hold it.
func _glow_fixture() -> Dictionary:
	var parent := Node3D.new()
	var glows := {"root": parent}
	for role: String in [DaySun.DAYLIGHT_FILL, DaySun.LAMP]:
		var material := StandardMaterial3D.new()
		material.emission_enabled = true
		material.emission_energy_multiplier = FILL_ENERGY if role == DaySun.DAYLIGHT_FILL else LAMP_ENERGY
		material.set_meta(DaySun.NIGHT_ROLE, role)
		var box := MeshInstance3D.new()
		box.mesh = BoxMesh.new()
		box.material_override = material
		parent.add_child(box)
		var kind := "fill" if role == DaySun.DAYLIGHT_FILL else "lamp"
		glows[kind] = material
		glows[kind + "_energy"] = material.emission_energy_multiplier
	root.add_child(parent)
	_nodes.append(parent)
	return glows


## The night lights' rule (NightLights), on a DaySun out of the tree whose darkness
## is set by hand: on at ON_AT, still on above OFF_AT, off at it and staying off
## below ON_AT; a fade of FADE_S each way; off at the recorded moment's look and on
## at the night floor's; the flashlight's pitch from the camera's.
func _check_night_lights() -> String:
	var light := DirectionalLight3D.new()
	var sun := DaySun.new(light, null)
	var lights := NightLights.new(sun, null, null)
	var states: Array[bool] = []
	for night: float in [0.0, 0.49, 0.5, 0.4, 0.36, 0.35, 0.45, 0.6, 1.0, 0.0]:
		sun.night = night
		lights.update(0.0)
		states.append(lights.on)
	var wanted: Array[bool] = [false, false, true, true, true, false, false, true, true, false]
	sun.night = 1.0
	lights.update(0.0)
	var levels: Array[float] = [lights.level]
	lights.update(NightLights.FADE_S * 0.5)
	levels.append(lights.level)
	lights.update(NightLights.FADE_S)
	levels.append(lights.level)
	sun.night = 0.0
	lights.update(NightLights.FADE_S * 0.25)
	levels.append(lights.level)
	var made := lights.flashlight != null or not lights.headlights.is_empty()
	lights.free()
	sun.free()
	light.free()
	var pitches: Array[float] = [NightLights.flash_pitch(-8.0), NightLights.flash_pitch(-60.0), NightLights.flash_pitch(25.0)]
	var day := float(DayLight.at(33.43).night)
	var night_floor := float(DayLight.at(DayLight.FLOOR_ELEVATION_DEG).night)
	# This is a test run: the time of day on but held (scripted), so no night lights
	# (main.gd makes them only where NightLights.wanted()).
	var held := DayClock.enabled() and DayClock.scripted() and not NightLights.wanted()
	var on_at := _height_at_night(NightLights.ON_AT)
	var off_at := _height_at_night(NightLights.OFF_AT)
	if not _require(states == wanted, "The night lights must come on at %.2f, stay on above %.2f and go off at it: %s for darkness 0, 0.49, 0.5, 0.4, 0.36, 0.35, 0.45, 0.6, 1, 0 (wanted %s)." % [NightLights.ON_AT, NightLights.OFF_AT, states, wanted]) \
	or not _require(levels == [0.0, 0.5, 1.0, 0.75] and not made, "The night lights must fade over FADE_S (levels %s, wanted 0, 0.5, 1, 0.75) and, with no player or car, make no light (made %s)." % [levels, made]) \
	or not _require(is_equal_approx(pitches[0], NightLights.FLASH_PITCH_DEG - 8.0 * NightLights.FLASH_PITCH_SHARE) and pitches[0] < -5.0 and pitches[1] < pitches[0] and pitches[1] >= NightLights.FLASH_PITCH_MIN_DEG and pitches[2] == NightLights.FLASH_PITCH_MAX_DEG and NightLights.FLASH_PITCH_MAX_DEG < 0.0, "The flashlight's pitch must be FLASH_PITCH_DEG plus FLASH_PITCH_SHARE of the camera's, down at the camera's rest, lower looking down, never above FLASH_PITCH_MAX_DEG (under the horizon) looking up: %s for the camera at -8, -60 and 25 degrees." % [pitches]) \
	or not _require(day == 0.0 and night_floor == 1.0 and on_at < -3.0 and on_at > -8.0 and off_at > on_at, "Darkness must be 0 by day and 1 at the night floor (%.2f, %.2f), the lights coming on between 3 and 8 degrees under the horizon (%.2f) and going off higher up (%.2f)." % [day, night_floor, on_at, off_at]) \
	or not _require(held, "In a test run (the time of day on, held) the night lights must not be wanted (on %s, scripted %s, wanted %s)." % [DayClock.enabled(), DayClock.scripted(), NightLights.wanted()]):
		return ""
	return "the night lights on at darkness %.2f (the sun %.1f degrees under the horizon) and off under %.2f (%.1f degrees), fading over %.1f s, none made without a player, and none wanted in a test run (held); the flashlight's pitch %.1f, %.0f and %.0f degrees for the camera's -8, -60 and 25" % [NightLights.ON_AT, -on_at, NightLights.OFF_AT, -off_at, NightLights.FADE_S, pitches[0], pitches[1], pitches[2]]


## The highest sun height (degrees, to a hundredth) at which DayLight's darkness
## reaches `night`, from full day down.
func _height_at_night(night: float) -> float:
	var height := DayLight.FULL_DAY_ELEVATION_DEG
	while height > DayLight.FLOOR_ELEVATION_DEG and float(DayLight.at(height).night) < night:
		height -= 0.01
	return snappedf(height, 0.01)


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
	var rows := [hud.time_heading, hud.time_date_row, hud.time_row]
	var shown := rows.all(func(row: Control) -> bool: return row.is_visible_in_tree())
	var recorded := [hud.time_date_label.text, hud.time_label.text, hud.time_date_slider.value, hud.time_slider.value]
	if not _require(shown and recorded == ["Fri 13 Nov 2026", "12:30 PST", 317.0, 750.0], "The options screen must show the date and time at the recorded moment: Fri 13 Nov 2026, 12:30 PST, day 317 and minute 750 on the sliders (shown %s: %s)." % [shown, recorded]):
		return ""
	# The date slider (a player's change): the same time on 21 June, PDT, running.
	hud.time_date_slider.value = 172
	var june := [hud.time_date_label.text, hud.time_label.text, DayClock.is_running(), DayClock.now() - DayClock.parse_local("2026-06-21 12:30")]
	hud.time_slider.value = 1380
	var night := [hud.time_label.text, DayClock.now() - DayClock.parse_local("2026-06-21 23:00")]
	hud.time_slider.value = 570
	var morning := [hud.time_label.text]
	if not _require(june.slice(0, 3) == ["Sun 21 Jun 2026", "12:30 PDT", true] and absf(june[3]) < 1.0, "The date slider at day 172 must jump the clock to Sun 21 Jun 2026 12:30 PDT, running, not %s." % [june]) \
	or not _require(night[0] == "23:00 PDT" and absf(night[1]) < 1.0, "The time slider at 23:00 must jump there, not %s." % [night]) \
	or not _require(morning == ["09:30 PDT"], "The time slider at 09:30 must jump there, not %s." % [morning]):
		return ""
	hud.time_now_button.pressed.emit()
	var real := absf(DayClock.now() - Time.get_unix_time_from_system())
	var now_running := DayClock.is_running()
	DayClock.pin()
	if not _require(real < 1.0 and now_running, "Now must jump to the real time, running (%.3f s off, running %s)." % [real, now_running]):
		return ""
	var daylight := await _check_daylight(hud)
	if daylight.is_empty():
		return ""
	# The web's options screen: none of it, the night note neither.
	hud.set_time_controls(false)
	await process_frame
	var hidden := rows.all(func(row: Control) -> bool: return not row.is_visible_in_tree()) and not hud.night_note.is_visible_in_tree()
	if not _require(hidden and not hud.time_controls_shown(), "On the web the options screen must show no date or time."):
		return ""
	return "the options screen's date and time (Fri 13 Nov 2026 12:30 PST; Sun 21 Jun 12:30 PDT from the date slider, 23:00 and 09:30 from the time slider; Now; none on the web); %s" % daylight


## The time slider's day and night (owner, 2026-11-16: "a line ... before sunrise
## and after sunset to sort of make it clear there's like a supported time of day
## and then Nighttime is experimental"), at the recorded moment: its marks at that
## date's sunrise and sunset (DayClock.sun_times: the sun's centre
## SUNRISE_ELEVATION_DEG up before refraction, rising before noon and setting after
## it, on that date), each where a click on the slider puts its time, to the
## slider's own resolution (a pixel and its step); the night note beside the
## heading, inside the panel and clear of the heading's text, by day (12:30) and at
## night (23:00); another date's marks at that date's own sunrise and sunset. Then
## on a phone's screen (the touch drive test's iPhone, upright and sideways) with
## the touch layout and the web's rows plus the time of day, as the web would have
## them: the panel inside the page, the note inside it and clear of the heading,
## the marks on the slider, the slider thumb-sized. The window and the clock as
## they were after. Returns a summary, or "" after failing.
func _check_daylight(hud: GameHUD) -> String:
	DayClock.pin()
	hud.show_options()
	await process_frame
	var date := DayClock.local(DayClock.RECORDED_UNIX)
	var times := DayClock.sun_times(int(date.year), int(date.day_of_year))
	var wanted: Array[float] = [DayClock.local_minutes(times[0]), DayClock.local_minutes(times[1])]
	for index in 2:
		var rising := index == 0
		# The sun's centre a minute before, at and a minute after (degrees, before refraction).
		var sun := [-60.0, 0.0, 60.0].map(func(offset: float) -> float: return float(SolarPosition.at(times[index] + offset, DayClock.LATITUDE, DayClock.LONGITUDE).geometric_elevation_deg))
		var climbing: bool = sun[0] < sun[1] and sun[1] < sun[2]
		var sinking: bool = sun[0] > sun[1] and sun[1] > sun[2]
		if not _require(absf(float(sun[1]) - DayClock.SUNRISE_ELEVATION_DEG) < 0.000001 and (climbing if rising else sinking) \
				and int(DayClock.local(times[index]).day_of_year) == int(date.day_of_year) and (wanted[index] < 720.0) == rising, "The %s on %s must be where the sun's centre is %.3f degrees up before refraction, %s, on that date, %s noon: at %s its height a minute before, then and a minute after is %s." % ["sunrise" if rising else "sunset", DayClock.moment_text(DayClock.RECORDED_UNIX).left(10), DayClock.SUNRISE_ELEVATION_DEG, "rising" if rising else "setting", "before" if rising else "after", DayClock.moment_text(times[index]), sun]):
			return ""
	var marks := hud.daylight_minutes()
	var slider := hud.time_slider
	var marks_x: Array = marks.map(func(minutes: float) -> float: return hud.time_slider_x(minutes))
	if not _require(marks == wanted and float(marks_x[0]) > 0.0 and float(marks_x[0]) < float(marks_x[1]) and float(marks_x[1]) < slider.size.x, "The time slider must mark the recorded moment's date's sunrise and sunset, %s minutes into the day, on the slider (marked %s at x %s of %.0f)." % [wanted, marks, marks_x, slider.size.x]):
		return ""
	# A click on each mark: the slider's own value for that place, to a pixel's worth
	# of minutes (it reads a click to a whole pixel) and half its step.
	var per_px := (slider.max_value - slider.min_value) / (slider.size.x - float(slider.get_theme_icon("grabber").get_width()))
	var clicked := []
	for index in 2:
		_click(slider.get_global_rect().position + Vector2(float(marks_x[index]), slider.size.y / 2.0))
		await process_frame
		clicked.append(slider.value)
		if not _require(absf(slider.value - marks[index]) <= per_px + slider.step / 2.0 and DayClock.is_running(), "A click on the %s mark (x %.1f) must put the time slider at %s, %.1f minutes into the day, to %.1f minutes, and jump the clock there; it put it at %s (running %s)." % ["sunrise" if index == 0 else "sunset", marks_x[index], DayClock.moment_text(times[index]).right(9), marks[index], per_px + slider.step / 2.0, slider.value, DayClock.is_running()]):
			return ""
	DayClock.pin()
	hud.show_options()
	await process_frame
	# The night note, by day and at night (the time slider's own moves).
	var heading := hud.time_heading.get_node("Text") as Control
	var notes := []
	for minutes: float in [750.0, 1380.0]:
		slider.value = minutes
		await process_frame
		notes.append([hud.time_label.text, hud.night_note.is_visible_in_tree(), hud.night_note.text, hud.options_panel.get_global_rect().encloses(hud.night_note.get_global_rect()), not hud.night_note.get_global_rect().intersects(heading.get_global_rect())])
	if not _require(notes == [["12:30 PST", true, "Night is experimental", true, true], ["23:00 PST", true, "Night is experimental", true, true]], "Beside the time of day's heading, inside the panel and clear of the heading's text, \"Night is experimental\" must show by day and at night ([time, shown, text, inside the panel, clear of the heading] %s)." % [notes]):
		return ""
	# Another date (the date slider): its own sunrise and sunset, earlier and later.
	hud.time_date_slider.value = 172
	await process_frame
	var june := DayClock.sun_times(2026, 172)
	var june_wanted: Array[float] = [DayClock.local_minutes(june[0]), DayClock.local_minutes(june[1])]
	var june_marks := hud.daylight_minutes()
	if not _require(hud.time_date_label.text == "Sun 21 Jun 2026" and june_marks == june_wanted and june_marks[0] < marks[0] and june_marks[1] > marks[1] and hud.time_slider_x(june_marks[0]) < float(marks_x[0]) and hud.time_slider_x(june_marks[1]) > float(marks_x[1]), "On Sun 21 Jun 2026 (the date slider at 172, showing %s) the marks must move to that date's sunrise and sunset, %s, before and after the recorded date's %s (marked %s)." % [hud.time_date_label.text, june_wanted, marks, june_marks]):
		return ""
	DayClock.pin()
	hud.show_options()
	# A phone's screen, the touch layout, the web's rows with the time of day.
	var window := root.size
	var layout := root.content_scale_size
	root.content_scale_size = Vector2i(GameMain.TOUCH_LAYOUT_PX, GameMain.TOUCH_LAYOUT_PX)
	hud.set_touch_instructions()
	hud.set_shadow_levels(ShadowQuality.LEVELS.filter(func(level: Dictionary) -> bool: return level.web), "off")
	hud.set_graphics(GraphicsSettings.offered(GraphicsSettings.FRAME_RATE_KEY, true), GraphicsSettings.offered(GraphicsSettings.RESOLUTION_KEY, true), GraphicsSettings.defaults(true))
	var phones := []
	for shape: Vector2i in [Vector2i(1206, 2148), Vector2i(2622, 1110)]:
		root.size = shape
		for _frame in 2:
			await process_frame
		var page := Rect2(Vector2.ZERO, hud.get_viewport_rect().size)
		var panel := hud.options_panel.get_global_rect()
		var note := hud.night_note.get_global_rect()
		var phone_x: Array = hud.daylight_minutes().map(func(minutes: float) -> float: return hud.time_slider_x(minutes))
		phones.append([shape, page.encloses(panel), panel.encloses(note), not note.intersects(heading.get_global_rect()), hud.night_note.is_visible_in_tree(), float(phone_x[0]) > 0.0 and float(phone_x[1]) < slider.size.x, slider.size.y >= 64.0])
	root.size = window
	root.content_scale_size = layout
	await process_frame
	if not _require(phones.all(func(phone: Array) -> bool: return phone.slice(1) == [true, true, true, true, true, true]), "On a phone's screen with the touch layout the options panel must lie inside the page, the night note inside it, clear of the heading and shown, and the marks on a thumb-sized slider ([window, panel in page, note in panel, clear of the heading, shown, marks on the slider, thumb-sized] %s)." % [phones]):
		return ""
	return "the time slider marking %s's sunrise and sunset at %s and %s (the sun's centre %.3f degrees up before refraction, rising and setting), a click on each mark putting the slider at %s, \"Night is experimental\" beside the heading at 12:30 and 23:00, Sun 21 Jun's marks at %s and %s, and on a phone's screen, upright and sideways, the note and the marks inside the panel and clear of the heading" % [DayClock.moment_text(DayClock.RECORDED_UNIX).left(10), DayClock.moment_text(times[0]).right(9), DayClock.moment_text(times[1]).right(9), DayClock.SUNRISE_ELEVATION_DEG, clicked, DayClock.moment_text(june[0]).right(9), DayClock.moment_text(june[1]).right(9)]


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
	# The player's shadow option, which a look at night would give a shorter reach.
	var quality := ShadowQuality.new(light)
	quality.apply("medium")
	var medium_distance := light.directional_shadow_max_distance
	day_sun.shadow_quality = quality
	root.add_child(day_sun)
	_nodes.append(day_sun)
	for _frame in 3:
		await process_frame
	day_sun.follow(true)
	# A building's glows, which a look at night would put out (its daylight fill).
	var glows := _glow_fixture()
	day_sun.collect_fills(glows.root)
	# The night lights, made as a driver would: nothing at all, even told it is dark.
	var lights := NightLights.new(day_sun, null, null)
	root.add_child(lights)
	_nodes.append(lights)
	DayClock.pin(DayClock.parse_local("2026-11-14 22:00"))
	for _frame in 3:
		await process_frame
	day_sun.follow(true)
	day_sun.night = 1.0
	lights.update(1.0)
	var lights_off := [NightLights.wanted(), lights.is_processing(), lights.on, lights.level]
	day_sun.night = 0.0
	var differences := _look_differences(light, environment, written, DayLight.at(DaySun.shown_angles(DayClock.RECORDED_UNIX)[0]))
	var inert := [light.transform == scene_transform, differences.is_empty(), written.size(), is_nan(day_sun.shown_unix), is_nan(day_sun.lit_elevation), day_sun.is_processing(),
		light.sky_mode == DirectionalLight3D.SKY_MODE_LIGHT_AND_SKY, quality.reach == 1.0 and light.directional_shadow_max_distance == medium_distance,
		day_sun.fills.is_empty() and day_sun.fill_share == 1.0 and glows.fill.emission_energy_multiplier == glows.fill_energy]
	DaySun.use_engine_globals()
	ProjectSettings.set_setting(DayClock.ENABLED_SETTING, kept)
	DayClock.restart()
	var back := [DayClock.enabled(), DayClock.now(), DayClock.is_running()]
	if not _require(off == [false, reasons[2], DayClock.RECORDED_UNIX, false] and jumped == [DayClock.RECORDED_UNIX, false, 0], "With %s false the time of day must be off for that reason and its clock hold the recorded moment whatever jumps it (off: %s; after start_at, start_now and pin: %s)." % [DayClock.ENABLED_SETTING, off, jumped]) \
	or not _require(inert == [true, true, 0, true, true, false, true, true, true], "With the time of day off DaySun must write nothing, even with the clock pinned at night: main.tscn's Sun and look untouched (the stars and the parked cars' lamps among them), no global handed over, nothing shown and no processing, the Sun lighting land and sky, the shadows' whole reach and a building's daylight fill neither found nor dimmed (transform kept, look kept, globals, nothing shown, nothing lit, processing, light and sky, whole reach, fill untouched: %s; the look differs in %s)." % [inert, differences]) \
	or not _require(lights_off == [false, false, false, 0.0], "With the time of day off the night lights must not be wanted, and one a driver makes must do nothing, even told it is dark ([wanted, processing, on, level] %s)." % [lights_off]) \
	or not _require(back == [true, DayClock.RECORDED_UNIX, false], "With the setting back the time of day must be on again, the clock held for this driver at the recorded moment (%s)." % [back]):
		return ""
	return "the switch: on unless %s, the setting %s false or the web; turned off, the clock held at the recorded moment through start_at, start_now and pin (22:00 among them), DaySun writing nothing to main.tscn's Sun, its look (the stars among it) or the globals (the parked cars' lamps among them), the Sun lighting land and sky, the shadows' whole reach, a building's daylight fill neither found nor dimmed, and the night lights neither wanted nor doing anything where a driver makes them" % [DayClock.OFF_ARGUMENT, DayClock.ENABLED_SETTING]


## How far the game's clock and the system clock run while REAL_SPAN_S of real time
## passes, waited inside one frame: (clock seconds, system seconds).
func _real_span() -> Vector2:
	var begun := Time.get_ticks_usec()
	var clock := DayClock.now()
	var system := Time.get_unix_time_from_system()
	while Time.get_ticks_usec() - begun < int(REAL_SPAN_S * 1000000.0):
		pass
	return Vector2(DayClock.now() - clock, Time.get_unix_time_from_system() - system)


## A left click (down and up) at `at`, in the HUD's pixels.
func _click(at: Vector2) -> void:
	for pressed: bool in [true, false]:
		var button := InputEventMouseButton.new()
		button.button_index = MOUSE_BUTTON_LEFT
		button.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		button.position = at
		button.global_position = at
		button.pressed = pressed
		root.push_input(button, true)


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
