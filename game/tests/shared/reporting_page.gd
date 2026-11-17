extends RefCounted
## The web page's crash and performance reports as CrashReports sees them
## (game/web/shell.html's window.__tiReporting), for a test to give main as its
## crash_page, as a browser does: its own copy of the switch (kept: true, false or
## null when never set), whether it has recorded the start prompt's line about the
## reports as shown, and what it was told, in order ("on", "off", "notice shown",
## "play started").

var kept: Variant = null
var notice_recorded := false
var told := []


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
