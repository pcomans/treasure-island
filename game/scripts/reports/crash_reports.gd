class_name CrashReports
extends RefCounted
## The anonymous statistics' consent (owner, 2026-11-17: "Ask once on first launch";
## nothing is stored for them or sent until the player says yes). On the web for now (the
## desktop builds get theirs with their own reports). The answer is "yes", "no" or ""
## (not asked yet): the start prompt asks (GameStats.CONSENT_QUESTION) while the answer is
## "" and fewer than GameStats.CONSENT_MAX_ASKS visits have started play without one; the
## last of those makes it "no". Options' switch ("Send anonymous statistics") shows it on
## for "yes" alone and changes it either way at any time. "no" stops everything at once:
## the page deletes the anonymous id and what it kept for the statistics.
##
## The game keeps the answer and the count in its settings file
## (ShadowQuality.settings_path, section privacy: crash_reports "yes" or "no", missing for
## not asked; crash_reports_asked) and mirrors the answer to the page (game/web/shell.html's
## tiReporting), which can't read the engine's settings before the engine starts and keeps
## its own copy in the browser's storage. The two are written apart, so either may lose a
## change: "no" on either side wins, then "yes" on either side, else not asked; nothing
## kept never counts as yes.
##
## The page: an object with read() (JSON {"consent": "yes", "no" or null, "storage": bool}),
## set_consent(answer), play_started(), snapshot(json), stats(json) and link_areas(json);
## WebPage on the web, a stand-in in a test (as main.gd's crash_page).

const SECTION := "privacy"
const KEY := "crash_reports"
const ASKED_KEY := "crash_reports_asked"

## The page's reporting, or null where there is none (desktop, a page without it, or one
## whose browser keeps nothing): then nothing is asked, Options shows no switch and nothing
## is told.
var page: Object
## The answer: "yes", "no" or "" (not asked yet).
var answer := ""
## The visits that showed the question and started play without an answer.
var asked := 0
## Whether the statistics are on: the answer is yes.
var on: bool:
	get:
		return answer == "yes"


## The answer as kept in the game's settings (KEPT: {"answer", "asked"}) and on the page,
## "no" on either side winning, then "yes"; the page told the result.
func _init(reporting_page: Object, kept: Dictionary) -> void:
	page = reporting_page
	answer = _valid(kept.get("answer", ""))
	asked = maxi(0, int(kept.get("asked", 0)))
	if page == null:
		return
	var told: Variant = JSON.parse_string(str(page.read()))
	if not (told is Dictionary and bool((told as Dictionary).get("storage", false))):
		# A page whose browser keeps nothing (blocked site data) can't keep the answer or
		# send: nothing is asked and Options has no switch.
		page = null
		return
	var theirs := _valid((told as Dictionary).get("consent", ""))
	if answer == "no" or theirs == "no":
		answer = "no"
	elif answer == "yes" or theirs == "yes":
		answer = "yes"
	if not answer.is_empty():
		page.set_consent(answer)


## The answer and the count kept in the settings file: not asked and none when there is none.
static func saved() -> Dictionary:
	var file := ConfigFile.new()
	if file.load(ShadowQuality.settings_path) != OK:
		return {"answer": "", "asked": 0}
	var count: Variant = file.get_value(SECTION, ASKED_KEY, 0)
	return {"answer": _valid(file.get_value(SECTION, KEY, "")), "asked": maxi(0, int(count)) if count is int else 0}


## Keeps the answer and the count for the next run, with whatever else the file holds
## (not asked: no answer kept). Where storage is unavailable this quietly keeps nothing,
## as the other settings do.
static func save(kept_answer: String, kept_asked: int) -> void:
	var file := ConfigFile.new()
	file.load(ShadowQuality.settings_path)
	if _valid(kept_answer).is_empty():
		if file.has_section_key(SECTION, KEY):
			file.erase_section_key(SECTION, KEY)
	else:
		file.set_value(SECTION, KEY, kept_answer)
	file.set_value(SECTION, ASKED_KEY, maxi(0, kept_asked))
	file.save(ShadowQuality.settings_path)


## Whether the start prompt asks now.
func should_ask() -> bool:
	return page != null and answer.is_empty() and asked < GameStats.CONSENT_MAX_ASKS


## The player's answer: on the start prompt (yes or no) or Options' switch (on or off).
func choose(yes: bool) -> void:
	answer = "yes" if yes else "no"
	if page != null:
		page.set_consent(answer)


## Play started with the question unanswered: one more ask; the last makes it "no".
func unanswered_play() -> void:
	asked += 1
	if asked >= GameStats.CONSENT_MAX_ASKS and answer.is_empty():
		answer = "no"
		if page != null:
			page.set_consent(answer)


## The start prompt's tap or click: play starts.
func play_started() -> void:
	if page != null:
		page.play_started()


## The game's state now (GameStats.snapshot), for the page to attach to what it sends;
## only with a yes.
func snapshot(state: Dictionary) -> void:
	if page != null and on:
		page.snapshot(JSON.stringify(state))


## The timed stats (GameStats.take_stats), for the page to send; only with a yes.
func stats(window: Dictionary) -> void:
	if page != null and on:
		page.stats(JSON.stringify(window))


## Where a tap or click opens the privacy page now (the HUD's link areas, in pixels of a
## page of PAGE_SIZE), for the web page to open it inside the player's own gesture: as
## shares of the page, with the address (GameStats.PRIVACY_URL). Whatever the answer, as
## the question and Options both show the link.
func link_areas(areas: Array, page_size: Vector2) -> void:
	if page == null or page_size.x <= 0.0 or page_size.y <= 0.0:
		return
	var shares: Array = []
	for area: Rect2 in areas:
		shares.append([area.position.x / page_size.x, area.position.y / page_size.y, area.size.x / page_size.x, area.size.y / page_size.y])
	page.link_areas(JSON.stringify({"url": GameStats.PRIVACY_URL, "areas": shares}))


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


## "yes" or "no", else "".
static func _valid(value: Variant) -> String:
	return str(value) if value is String and str(value) in ["yes", "no"] else ""


## window.__tiReporting (game/web/shell.html), through JavaScriptBridge: its object,
## got once, its methods called directly (no script to parse on each call).
class WebPage extends RefCounted:
	var _reporting: JavaScriptObject = JavaScriptBridge.get_interface("__tiReporting")

	func read() -> String:
		return str(_reporting.read())

	func set_consent(value: String) -> void:
		_reporting.setConsent(value)

	func play_started() -> void:
		_reporting.playStarted()

	func snapshot(json: String) -> void:
		_reporting.snapshot(json)

	func stats(json: String) -> void:
		_reporting.stats(json)

	func link_areas(json: String) -> void:
		_reporting.linkAreas(json)
