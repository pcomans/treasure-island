extends RefCounted
## The web page's anonymous statistics as CrashReports sees them
## (game/web/shell.html's window.__tiReporting), for a test to give main as its
## crash_page, as a browser does: its own copy of the switch (kept: true, false or
## null when never set), whether it has recorded the start prompt's line about the
## statistics as shown, what it was told, in order ("on", "off", "notice shown",
## "play started"), the snapshots and stats it got (parsed), and where a tap or click
## would open the privacy page (link_areas, parsed: {"url", "areas"}).

var kept: Variant = null
var notice_recorded := false
var told := []
var snapshots := []
var stats_got := []
var links := {}


func read() -> String:
	return JSON.stringify({"on": kept, "notice": kept != false and not notice_recorded})


func set_enabled(value: bool) -> void:
	told.append("on" if value else "off")
	kept = value


func notice_shown() -> void:
	told.append("notice shown")
	notice_recorded = true


func play_started() -> void:
	told.append("play started")


func snapshot(json: String) -> void:
	snapshots.append(JSON.parse_string(json))


func stats(json: String) -> void:
	stats_got.append(JSON.parse_string(json))


func link_areas(json: String) -> void:
	links = JSON.parse_string(json)
