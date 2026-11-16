class_name DayClock
extends RefCounted
## The game's time of day: the instant (UTC, Unix seconds) the sun is drawn for
## (DaySun), and Treasure Island's own clock for the menu (Pacific time).
##
## The game opens on the island's date today at the recorded moment's time of day,
## 12:30 (start_instant; owner, 2026-11-16: "always start the game during a time
## with nice lighting", rather than at the real time, which may be the middle of
## the night), so the sun's height follows the season but it is always early
## afternoon. From there time runs at real speed, one minute of play a minute of
## real time, whatever the game is doing (a pause too: the sun keeps time; owner,
## 2026-11-14); the Options screen's date and time jump to any moment of the year,
## and time runs on from there; "Now" jumps to the real date and time. Nothing of
## it is kept between runs: every run starts so. The web build holds the recorded
## moment ("Mac first, web later").
##
## The one switch for everything that must stay the same from run to run: every
## test or capture driver (a --script run, its SceneTree scripted, as
## GameMain.player_settings_problem tells them) and the web build hold the clock at
## RECORDED_UNIX, the moment main.tscn's Sun was set for, so reviews, acceptance
## captures, the neutral light and the tests see today's look. A driver opts in to
## another moment with pin(), or to running time with start_at().
##
## Real speed is the system clock's (UTC, Time.get_unix_time_from_system): the game
## keeps an offset from it, so its time runs on while the computer sleeps (a
## MacBook's lid closed with the game open) and follows the system's corrections,
## while a pause (Engine.time_scale 0) and --fixed-fps don't touch it. The
## monotonic clock (Time.get_ticks_usec) would stop during sleep: Godot 4.7.2 reads
## mach_absolute_time on macOS and CLOCK_MONOTONIC_RAW on Linux.
##
## The island's clock is Pacific time by the US rule (PST, UTC-8; PDT, UTC-7 from
## 2:00 on the second Sunday of March to 2:00 on the first Sunday of November,
## since 2007), whatever the device's own time zone.
##
## The switch for the whole time of day (owner, 2026-11-15: all of it behind one
## flag that is easy to turn off), for the developers and the owner, not a
## player's option: the project setting ENABLED_SETTING (true unless project.godot
## sets it false), or OFF_ARGUMENT on the command line for one run
## (`tools/godot --path . -- --no-time-of-day`). The web build counts as off (it
## holds the recorded moment, "Mac first, web later"). Off, the game is the web's:
## the clock holds RECORDED_UNIX and nothing moves it, DaySun writes nothing (the
## Sun and the whole look stay main.tscn's), Mersea's probes are never captured
## again and the Options screen has no time of day. Everything that depends on the
## time of day asks enabled() first and, when it is false, makes and runs nothing
## (no node, no light, no process): DaySun, which alone writes the look (the night,
## the stars, the Sun lighting the sky alone, the parked cars' lamps put out, the
## buildings' daylight fills put out, the shadows' reach), the Options screen's
## date and time, and NightLights (the flashlight and the driven car's
## headlights), which a scripted run doesn't make either (scripted()). Each run
## prints one TIME_OF_DAY line: off, and why, or held (a --script run) as it reads
## the switch; on, as its clock starts, with the moment it starts at and the real
## time then.

## Treasure Island, as tools/solar_position.mjs takes it.
const LATITUDE := 37.82
const LONGITUDE := -122.37
## 2026-11-13 12:30 PST: main.tscn's Sun (its solar_moment metadata).
const RECORDED_UNIX := 1794601800.0
## The switch (see the top): the project setting, and the command line's argument
## that turns the time of day off for one run.
const ENABLED_SETTING := "treasure_island/time_of_day/enabled"
const OFF_ARGUMENT := "--no-time-of-day"

## Where real time comes from: the system clock. A test may put a stand-in here
## (a Callable returning Unix seconds) and use_system_clock() puts it back.
static var system_clock := Callable(Time, &"get_unix_time_from_system")

static var _started := false
static var _running := false
## The instant while held; while running, how far the game's time is ahead of the
## system clock's (s).
static var _held_unix := RECORDED_UNIX
static var _offset := 0.0
## Goes up by one at every jump (start_at, start_now, pin): DaySun redraws the sun
## at once, not at its next step.
static var _revision := 0
## Why the time of day is off in this run ("" when it is on), read once.
static var _off := ""
static var _switch_read := false


## Whether the time of day is on in this run (see the top): what everything that
## depends on it asks first.
static func enabled() -> bool:
	_read_switch()
	return _off.is_empty()


## Why the time of day is off in this run, or "" when it is on.
static func off_reason() -> String:
	_read_switch()
	return _off


## Why the time of day is off with these command-line arguments, this value of
## ENABLED_SETTING and on the web or not, or "" when it is on.
static func off_reason_for(arguments: PackedStringArray, setting: Variant, web: bool) -> String:
	if arguments.has(OFF_ARGUMENT):
		return "%s on the command line" % OFF_ARGUMENT
	if not bool(setting):
		return "the project setting %s is false" % ENABLED_SETTING
	if web:
		return "the web build holds the recorded moment"
	return ""


## Reads the switch and starts the clock again as a run does: for a test that
## turns the switch over (ProjectSettings) between its checks.
static func restart() -> void:
	_switch_read = false
	_started = false


static func _read_switch() -> void:
	if _switch_read:
		return
	_switch_read = true
	_off = off_reason_for(OS.get_cmdline_user_args(), ProjectSettings.get_setting(ENABLED_SETTING, true), OS.has_feature("web"))
	if not _off.is_empty():
		print("TIME_OF_DAY off (%s): the clock holds %s" % [_off, moment_text(RECORDED_UNIX)])
	elif scripted():
		print("TIME_OF_DAY held: a --script run holds the clock at %s unless its driver moves it" % moment_text(RECORDED_UNIX))


## Whether this run is a test or capture driver's (its SceneTree scripted): the
## clock holds the recorded moment unless that driver moves it, and the night's
## lights are not made (NightLights.wanted).
static func scripted() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	return tree == null or tree.get_script() != null


## The instant now (UTC, Unix seconds).
static func now() -> float:
	_start()
	if not _running:
		return _held_unix
	return float(system_clock.call()) + _offset


## Whether time runs (at real speed), or is held still.
static func is_running() -> bool:
	_start()
	return _running


## How many times the clock has jumped.
static func revision() -> int:
	_start()
	return _revision


## Jumps to `unix` and runs on from there at real speed (the Options screen).
static func start_at(unix: float) -> void:
	_jump(unix, true)


## The real current time, running (the Options screen's Now).
static func start_now() -> void:
	_jump(float(system_clock.call()), true)


## Holds the clock still at `unix`: the recorded moment unless a test or capture
## names another.
static func pin(unix: float = RECORDED_UNIX) -> void:
	_jump(unix, false)


## The clock as a run starts (start_for), with its TIME_OF_DAY line when it runs.
static func _start() -> void:
	if _started:
		return
	var real := float(system_clock.call())
	var start := start_for(enabled(), scripted(), real)
	_set_clock(float(start[0]), bool(start[1]))
	if _running:
		print("TIME_OF_DAY on: the clock starts at %s, the recorded moment's time of day on the island's date, and runs at real speed (the real time %s)" % [moment_text(float(start[0])), moment_text(real)])


## [instant, running] a run's clock starts at, with the time of day on or off, in a
## test or capture driver's run or not, the real time (the system clock) being
## `real_unix`: in play, start_instant(real_unix), running; held at the recorded
## moment with the time of day off (the web's too) and for every test or capture
## driver.
static func start_for(on: bool, is_scripted: bool, real_unix: float) -> Array:
	if not on or is_scripted:
		return [RECORDED_UNIX, false]
	return [start_instant(real_unix), true]


## The instant play starts at, the real time being `real_unix`: the island's date
## then at the recorded moment's time of day (12:30, PST or PDT as that date has
## it).
static func start_instant(real_unix: float) -> float:
	var today := local(real_unix)
	return unix_from_local(int(today.year), int(today.day_of_year), float(local(RECORDED_UNIX).minutes))


## The island's clock at `unix` as "YYYY-MM-DD HH:MM ZONE".
static func moment_text(unix: float) -> String:
	var at := local(unix)
	return "%d-%02d-%02d %02d:%02d %s" % [at.year, at.month, at.day, at.hour, at.minute, at.zone]


## Real time from the system clock again, after a test's stand-in. Set the source
## before a jump: the offset is kept from the source in use then.
static func use_system_clock() -> void:
	system_clock = Callable(Time, &"get_unix_time_from_system")


## A jump; with the time of day off nothing moves the clock from the recorded
## moment.
static func _jump(unix: float, running: bool) -> void:
	if not enabled():
		_start()
		return
	_set_clock(unix, running)


static func _set_clock(unix: float, running: bool) -> void:
	_started = true
	_held_unix = unix
	_offset = unix - float(system_clock.call())
	_running = running
	_revision += 1


## Whether daylight saving time is on at `unix` on the island.
static func is_daylight_saving(unix: float) -> bool:
	var year := int(Time.get_datetime_dict_from_unix_time(floori(unix)).year)
	# 2:00 PST (10:00 UTC) on March's second Sunday; 2:00 PDT (9:00 UTC) on
	# November's first.
	var begins := _sunday(year, 3, 2) + 10 * 3600
	var ends := _sunday(year, 11, 1) + 9 * 3600
	return unix >= begins and unix < ends


## The island's offset from UTC at `unix`, in hours: -7 (PDT) or -8 (PST).
static func pacific_offset_hours(unix: float) -> int:
	return -7 if is_daylight_saving(unix) else -8


## The island's clock at `unix`: {year, month, day, weekday (0 Sunday), hour,
## minute, second, day_of_year (1 on 1 January), minutes (into the day), zone
## ("PST" or "PDT")}.
static func local(unix: float) -> Dictionary:
	var offset := pacific_offset_hours(unix)
	var wall := floori(unix) + offset * 3600
	var date := Time.get_datetime_dict_from_unix_time(wall)
	var new_year := Time.get_unix_time_from_datetime_dict({"year": date.year, "month": 1, "day": 1})
	date["day_of_year"] = floori(float(wall - new_year) / 86400.0) + 1
	date["minutes"] = int(date.hour) * 60 + int(date.minute)
	date["zone"] = "PDT" if offset == -7 else "PST"
	return date


## The instant the island's clock reads `minutes` into day `day_of_year` (1 on
## 1 January) of `year`. In the hour that November's change repeats, the earlier
## (PDT); in the hour March's skips, an hour on (2:30 is 3:30 PDT).
static func unix_from_local(year: int, day_of_year: int, minutes: float) -> float:
	var wall := float(Time.get_unix_time_from_datetime_dict({"year": year, "month": 1, "day": 1})) \
		+ (day_of_year - 1) * 86400.0 + minutes * 60.0
	var daylight := wall + 7.0 * 3600.0
	if is_daylight_saving(daylight):
		return daylight
	return wall + 8.0 * 3600.0


## The instant the island's clock reads `text`, "YYYY-MM-DD HH:MM" (as
## unix_from_local takes it), or NAN for anything else.
static func parse_local(text: String) -> float:
	var found := RegEx.create_from_string("^(\\d{4})-(\\d{2})-(\\d{2}) (\\d{1,2}):(\\d{2})$").search(text.strip_edges())
	if found == null:
		return NAN
	var year := int(found.get_string(1))
	var month := int(found.get_string(2))
	var day := int(found.get_string(3))
	var hour := int(found.get_string(4))
	var minute := int(found.get_string(5))
	var month_days := [31, 29 if days_in_year(year) == 366 else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if month < 1 or month > 12 or day < 1 or day > int(month_days[month - 1]) or hour > 23 or minute > 59:
		return NAN
	var date := Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": day})
	var new_year := Time.get_unix_time_from_datetime_dict({"year": year, "month": 1, "day": 1})
	return unix_from_local(year, floori(float(date - new_year) / 86400.0) + 1, hour * 60.0 + minute)


## The number of days in `year`.
static func days_in_year(year: int) -> int:
	return 366 if (year % 4 == 0 and year % 100 != 0) or year % 400 == 0 else 365


## Midnight UTC on the nth Sunday of a month.
static func _sunday(year: int, month: int, nth: int) -> int:
	var first := Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": 1})
	var weekday := int(Time.get_datetime_dict_from_unix_time(first).weekday)
	return first + (((7 - weekday) % 7) + 7 * (nth - 1)) * 86400
