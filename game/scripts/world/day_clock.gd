class_name DayClock
extends RefCounted
## The game's time of day: the instant (UTC, Unix seconds) the sun is drawn for
## (DaySun), and Treasure Island's own clock for the menu (Pacific time).
##
## Owner, 2026-11-14: the game opens at the real date and time on the island and
## runs at real speed, one minute of play a minute of real time, whatever the game
## is doing (a pause too: the sun keeps the real time); the Options screen's date
## and time jump to any moment of the year, and time runs on from there; "Now"
## comes back to the real time. Nothing of it is kept between runs. The web build
## holds the recorded moment ("Mac first, web later").
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

## Treasure Island, as tools/solar_position.mjs takes it.
const LATITUDE := 37.82
const LONGITUDE := -122.37
## 2026-11-13 12:30 PST: main.tscn's Sun (its solar_moment metadata).
const RECORDED_UNIX := 1794601800.0

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


## The real current time, running (the game's start; the Options screen's Now).
static func start_now() -> void:
	_jump(float(system_clock.call()), true)


## Holds the clock still at `unix`: the recorded moment unless a test or capture
## names another.
static func pin(unix: float = RECORDED_UNIX) -> void:
	_jump(unix, false)


## Whether this run holds the recorded moment from its start: the web build and
## every test or capture driver (a --script run, its SceneTree scripted); play
## starts at the real time.
static func starts_pinned() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	return OS.has_feature("web") or tree == null or tree.get_script() != null


## The clock as a run starts: the real time in play, the recorded moment, held,
## for the web and for every test or capture driver.
static func _start() -> void:
	if _started:
		return
	_started = true
	if starts_pinned():
		pin()
	else:
		start_now()


## Real time from the system clock again, after a test's stand-in. Set the source
## before a jump: the offset is kept from the source in use then.
static func use_system_clock() -> void:
	system_clock = Callable(Time, &"get_unix_time_from_system")


static func _jump(unix: float, running: bool) -> void:
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
