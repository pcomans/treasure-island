class_name CrashReports
extends RefCounted
## The anonymous statistics' switch (owner, 2026-11-17: on by default, "Easier is
## better. Always opt-out" and "we need an opt-out in settings"): Options' "Send
## anonymous statistics", on the web for now (the desktop builds get theirs with their
## own reports). It turns everything off together: crash reports, performance traces and
## the timed statistics (GameStats). The web page sends them (game/web/shell.html's
## tiReporting); the game keeps the switch in its settings file
## (ShadowQuality.settings_path, section privacy) and mirrors it to the page, which can't
## read the engine's settings before the engine starts and keeps its own copy in the
## browser's storage. The two are written apart, so either may lose a change (a page
## closed before the engine's file reached the browser's storage): off on either side
## wins, and a player's off is never undone by a copy that missed it.
##
## The page also says whether the start prompt should carry the one line about the
## statistics (notice), and hears when it showed it (notice_shown) and when play started
## (play_started): it sends nothing before a player has seen that line, and in the visit
## that first shows it, nothing before play starts. A player who turns the switch on in
## Options has read about it there, which counts the same. While the switch is on, the
## page gets the game's state (snapshot) and the timed stats (stats) from GameStats.
##
## The page: an object with read() (JSON {"on": true, false or null, "notice": bool}),
## set_enabled(on), notice_shown(), play_started(), snapshot(json) and stats(json);
## WebPage on the web, a stand-in in a test (as main.gd's crash_page).

const SECTION := "privacy"
const KEY := "crash_reports"

## The page's reporting, or null where there is none (desktop, a page without it): then
## Options shows no switch and nothing is told.
var page: Object
## Whether the statistics are on, as the switch shows it.
var on := true
## Whether the start prompt should show the notice (until it has).
var notice := false
## Whether the page has heard the notice shown in this run (it hears it once).
var _shown_told := false


## The switch as kept in the game's settings (kept_on) and on the page, off on either
## side winning; the page told the result.
func _init(reporting_page: Object, kept_on: bool) -> void:
	page = reporting_page
	on = kept_on
	if page == null:
		return
	var told: Variant = JSON.parse_string(str(page.read()))
	var state: Dictionary = told if told is Dictionary else {}
	if state.get("on") is bool and not bool(state.on):
		on = false
	notice = on and bool(state.get("notice", false))
	page.set_enabled(on)


## The switch kept in the settings file: on unless it says off.
static func saved() -> bool:
	var file := ConfigFile.new()
	if file.load(ShadowQuality.settings_path) != OK:
		return true
	var kept: Variant = file.get_value(SECTION, KEY, true)
	return kept if kept is bool else true


## Keeps the switch for the next run, with whatever else the file holds. Where storage
## is unavailable this quietly keeps nothing, as the other settings do.
static func save(value: bool) -> void:
	var file := ConfigFile.new()
	file.load(ShadowQuality.settings_path)
	file.set_value(SECTION, KEY, value)
	file.save(ShadowQuality.settings_path)


## The player's choice on the switch: on or off at once on the page.
func choose(value: bool) -> void:
	on = value
	notice = notice and on
	if page != null:
		page.set_enabled(on)
		if on:
			page.notice_shown()


## The start prompt shows the notice: the page hears it once.
func notice_shown() -> void:
	notice = false
	if page != null and not _shown_told:
		_shown_told = true
		page.notice_shown()


## The start prompt's tap or click: play starts.
func play_started() -> void:
	if page != null:
		page.play_started()


## The game's state now (GameStats.snapshot), for the page to attach to what it sends.
func snapshot(state: Dictionary) -> void:
	if page != null and on:
		page.snapshot(JSON.stringify(state))


## The timed stats (GameStats.take_stats), for the page to send.
func stats(window: Dictionary) -> void:
	if page != null and on:
		page.stats(JSON.stringify(window))


## The web page's reporting, or null off the web or where the page has none.
static func web_page() -> Object:
	if not OS.has_feature("web") or not bool(JavaScriptBridge.eval("Boolean(window.__tiReporting)")):
		return null
	return WebPage.new()


## The graphics adapter as the browser names it to the page (WebGL's unmasked renderer
## where the browser gives it, else its renderer), or "" off the web.
static func web_adapter() -> String:
	if not OS.has_feature("web"):
		return ""
	return str(JavaScriptBridge.eval("(() => { try { const gl = document.getElementById('canvas').getContext('webgl2'); const info = gl && gl.getExtension('WEBGL_debug_renderer_info'); return gl ? String(gl.getParameter(info ? info.UNMASKED_RENDERER_WEBGL : gl.RENDERER)) : ''; } catch (e) { return ''; } })()"))


## window.__tiReporting (game/web/shell.html), through JavaScriptBridge: its object,
## got once, its methods called directly (no script to parse on each call).
class WebPage extends RefCounted:
	var _reporting: JavaScriptObject = JavaScriptBridge.get_interface("__tiReporting")

	func read() -> String:
		return str(_reporting.read())

	func set_enabled(value: bool) -> void:
		_reporting.setEnabled(value)

	func notice_shown() -> void:
		_reporting.noticeShown()

	func play_started() -> void:
		_reporting.playStarted()

	func snapshot(json: String) -> void:
		_reporting.snapshot(json)

	func stats(json: String) -> void:
		_reporting.stats(json)
