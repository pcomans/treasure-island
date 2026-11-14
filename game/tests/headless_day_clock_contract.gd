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
##   - DaySun points a light at the clock's sun: in steps while time runs (10 s with
##     the sun high, shorter as it sinks), at once on a jump; below the daylight it
##     draws, the light waits where the sun crossed its edge, on the evening's or the
##     morning's side, with no jump as it gets there;
##   - the options screen's date and time read the island's clock (PST and PDT, the
##     night note), its sliders jump the clock and time runs on, Now goes back to
##     the real time, and the web's options screen has none of it.
## The first failure stops the run.

const MAIN_SCENE := "res://game/scenes/main.tscn"
## How far the GDScript sun may stray from the Node tool's (degrees): the same
## arithmetic in 64-bit floats, so only rounding differs.
const TOLERANCE_DEG := 0.000001
## How long a real-speed check lets real time run (s), and how far the game's clock
## may differ from the system clock over that time (s).
const REAL_SPAN_S := 0.3
const REAL_SLACK_S := 0.005

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
	var menu := await _check_options_rows()
	if menu.is_empty():
		return _finish()
	print("PASS: day clock: %s; %s; %s; %s; %s; %s" % [solar, recorded, island, running, sun, menu])
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


## The recorded moment: main.tscn's Sun, its metadata and its light exactly.
func _check_recorded_moment() -> String:
	var main := (load(MAIN_SCENE) as PackedScene).instantiate()
	var scene_sun := main.get_node("Sun") as DirectionalLight3D
	var kept := DaySun.shown_angles(DayClock.RECORDED_UNIX)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = DaySun.rotation_for(kept)
	var same := light.transform == scene_sun.transform
	var metadata: Array[float] = [float(scene_sun.get_meta("solar_elevation_deg")), float(scene_sun.get_meta("solar_azimuth_deg"))]
	light.free()
	main.free()
	if not _require(kept == metadata and same, "At the recorded moment the sun must be main.tscn's Sun: its metadata %s and its rotation exactly, not %s (rotation the same: %s)." % [metadata, kept, same]):
		return ""
	return "the recorded moment is main.tscn's Sun exactly (%.2f, %.2f)" % [kept[0], kept[1]]


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


## DaySun on a light of its own.
func _check_day_sun() -> String:
	var light := DirectionalLight3D.new()
	root.add_child(light)
	_nodes.append(light)
	var day_sun := DaySun.new(light)
	root.add_child(day_sun)
	_nodes.append(day_sun)
	var scene := (load(MAIN_SCENE) as PackedScene).instantiate()
	var scene_transform := (scene.get_node("Sun") as Node3D).transform
	scene.free()
	await process_frame
	if not _require(light.transform == scene_transform, "At the recorded moment DaySun must leave the light exactly as main.tscn's Sun."):
		return ""
	# Morning, noon, afternoon and evening on the longest and shortest days and on
	# 2026-11-14: the light from the clock's sun, through east (+X) from north (-Z).
	var checked := 0
	for day: String in ["2026-06-21", "2026-12-21", "2026-11-14"]:
		for time: String in ["09:30", "12:30", "15:30", "16:30"]:
			var unix := DayClock.parse_local("%s %s" % [day, time])
			DayClock.pin(unix)
			await process_frame
			var sun := SolarPosition.at(unix, DayClock.LATITUDE, DayClock.LONGITUDE)
			var shown := DaySun.shown_angles(unix)
			var true_sun: Array[float] = [snappedf(float(sun.elevation_deg), DaySun.ANGLE_STEP_DEG), snappedf(float(sun.azimuth_deg), DaySun.ANGLE_STEP_DEG)]
			if DaySun.is_held(unix):
				continue
			if not _require(shown == true_sun and light.rotation_degrees.is_equal_approx(DaySun.rotation_for(shown)) and light.basis.z.is_equal_approx(SolarPosition.direction_to(shown[0], shown[1])), "At %s %s the light must shine from the sun at %s (%s), not from rotation %s." % [day, time, true_sun, shown, light.rotation_degrees]):
				return ""
			checked += 1
	# Night: the light waits where the sun crossed the edge of the daylight drawn,
	# west after sunset, east before sunrise.
	var sides := []
	for night: Array in [["2026-11-14 22:00", true], ["2026-11-15 05:00", false], ["2026-06-21 23:50", true], ["2026-06-22 03:00", false]]:
		var unix := DayClock.parse_local(night[0])
		DayClock.pin(unix)
		await process_frame
		var shown := DaySun.shown_angles(unix)
		var west := shown[1] > 180.0
		if not _require(DaySun.is_held(unix) and is_equal_approx(shown[0], DaySun.DAYLIGHT_MIN_ELEVATION_DEG) and west == night[1] and light.rotation_degrees.is_equal_approx(DaySun.rotation_for(shown)), "At %s the light must wait at %.0f degrees on the %s side, not at %s." % [night[0], DaySun.DAYLIGHT_MIN_ELEVATION_DEG, "west" if night[1] else "east", shown]):
			return ""
		sides.append("%s %.1f" % [night[0].right(5), shown[1]])
	# No jump as the sun reaches the edge or leaves it: minute by minute through
	# 2026-11-14's sunset and 2026-11-15's sunrise.
	var largest := 0.0
	for span: Array in [["2026-11-14 15:30", 120], ["2026-11-15 06:30", 150]]:
		var unix := DayClock.parse_local(span[0])
		var last := DaySun.shown_angles(unix)
		for minute in int(span[1]):
			unix += 60.0
			var shown := DaySun.shown_angles(unix)
			largest = maxf(largest, rad_to_deg(SolarPosition.direction_to(last[0], last[1]).angle_to(SolarPosition.direction_to(shown[0], shown[1]))))
			last = shown
	if not _require(largest < 0.3, "The light must not jump at the edge of the daylight: it moved %.3f degrees in a minute." % largest):
		return ""
	# Steps while time runs, on a stand-in system clock: 10 s with the sun high,
	# shorter as it sinks (step_seconds), a full step while it is held; a jump at once.
	var system := [1800000000.0]
	DayClock.system_clock = func() -> float: return system[0]
	var steps := []
	for trial: Array in [["2026-06-21 12:30", "high"], ["2026-11-14 15:50", "low"], ["2026-11-14 22:00", "held"]]:
		var start := DayClock.parse_local(trial[0])
		var step := DaySun.STEP_S if DaySun.is_held(start) else DaySun.step_seconds(DaySun.shown_angles(start)[0])
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
			return ""
	var jump_from := DayClock.parse_local("2026-06-21 12:30")
	DayClock.start_at(jump_from + 3600.0)
	await process_frame
	var jumped := day_sun.shown_unix
	DayClock.use_system_clock()
	DayClock.pin()
	await process_frame
	var back := light.transform == scene_transform
	var shape := [DaySun.step_seconds(75.0), DaySun.step_seconds(30.0), DaySun.step_seconds(20.0), DaySun.step_seconds(10.0), DaySun.step_seconds(5.0)]
	if not _require(jumped == jump_from + 3600.0 and back, "A jump must move the sun at once (shown %s for %s), and pinned again it must be main.tscn's (%s)." % [jumped, jump_from + 3600.0, back]) \
	or not _require(shape[0] == DaySun.STEP_S and shape[1] == DaySun.STEP_S and shape[2] < shape[1] and shape[3] < shape[2] and shape[3] < 1.5 and shape[4] == DaySun.MIN_STEP_S, "The step must be STEP_S from FULL_STEP_ELEVATION_DEG up and shorter as the sun sinks, to MIN_STEP_S: %s at 75, 30, 20, 10 and 5 degrees." % [shape]):
		return ""
	return "the light from the clock's sun at %d moments, waiting at %.0f degrees at night (%s), no jump at the edge (%.2f degrees a minute at most), in steps while time runs (%s; %.1f s at 10 degrees) and at once on a jump" % [checked, DaySun.DAYLIGHT_MIN_ELEVATION_DEG, ", ".join(PackedStringArray(sides)), largest, ", ".join(PackedStringArray(steps)), shape[3]]


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
