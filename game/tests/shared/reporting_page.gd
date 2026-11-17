extends RefCounted
## The web page's anonymous statistics as CrashReports sees them
## (game/web/shell.html's window.__tiReporting), for a test to give main as its
## crash_page, as a browser does: its own copy of the answer (kept: "yes", "no" or null
## for not asked), whether its browser keeps anything (storage), what it was told, in
## order ("yes", "no", "play started"), the snapshots and stats it got (parsed), and where
## a tap or click would open the privacy page (link_areas, parsed: {"url", "areas"}).

var kept: Variant = null
var storage := true
var told := []
var snapshots := []
var stats_got := []
var links := {}


func read() -> String:
	return JSON.stringify({"consent": kept, "storage": storage})


func set_consent(answer: String) -> void:
	told.append(answer)
	kept = answer


func play_started() -> void:
	told.append("play started")


func snapshot(json: String) -> void:
	snapshots.append(JSON.parse_string(json))


func stats(json: String) -> void:
	stats_got.append(JSON.parse_string(json))


func link_areas(json: String) -> void:
	links = JSON.parse_string(json)
