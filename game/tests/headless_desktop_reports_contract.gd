extends SceneTree
## The desktop builds' anonymous statistics (DesktopReports, owner 2026-11-17), headless,
## with a stand-in for Sentry's SDK (SentryBackend's methods) and the test's own settings
## file and data folder, so nothing here reads or writes the player's:
##   - nothing starts in a run that may not send: the web, a test or capture driver, a run
##     from source or the editor, a headless run, a launch check, a build without its
##     build stamp, a build whose add-on did not load or that has no DSN; this run (a test,
##     headless) gets no page, and the real SDK, which the editor has loaded, is not
##     started by anything here;
##   - with the switch on, nothing starts before the notice is seen, nor in the run that
##     first shows it before play starts; then it starts once, with the options that keep
##     to the owner's list (no PII, log file, screenshots, scene tree, breadcrumbs, logs or
##     app hangs; engine, script and shader errors as events; every trace), the anonymous
##     id (GameStats.anonymous_id, kept in the settings file) as its user and the scope's
##     contexts replaced by the game's own; a later run with the notice seen starts at once;
##     play_started sends the funnel's first step, the first stats its second;
##   - switched off it closes at once, deletes the id and the SDK's files and stays off in
##     a later run (CrashReports keeps it); on again in the same run it waits for the next
##     launch, with a new id that the add-on will read as it loads;
##   - an error leaves with no home folder, user or computer name in its text, with only
##     the allowed contexts and the anonymous id as its user; each message goes once, at
##     most MAX_ERROR_EVENTS a run, a crash always; nothing goes once switched off; a
##     transaction keeps its trace and loses the rest the same way;
##   - the snapshot's bands go on the scope as tags, all of it as the "game" context; a
##     stats message is one "game stats" transaction (op ti.stats) with its numbers and a
##     child span per area and per movement, at most MAX_STATS a run;
##   - the build content audit admits exactly the pinned add-on's files in a pack and
##     beside a Linux or Windows executable, and nothing else under addons/;
##   - Options' switch shows and asks for the statistics, and the loading screen's line
##     about them shows on desktop.
## The first failure stops the run.

const AUDIT := preload("res://game/tests/shared/build_content_audit.gd")
const HUD_SCENE := "res://game/scenes/ui/hud.tscn"
const STAMP := {"build": 2178, "commit": "1a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d"}
const DSN := "http://0123456789abcdef0123456789abcdef@127.0.0.1:9/1"

var _failure := ""
var _settings_file := ""
var _data_dir := ""


## SentryBackend's methods, recorded.
class FakeBackend extends RefCounted:
	var started := 0
	var closed := 0
	var enabled := false
	var options: FakeOptions
	var user_id := "unset"
	var contexts := {}
	var tags := {}
	var spans: Array[FakeSpan] = []

	func available() -> bool:
		return true

	func is_enabled() -> bool:
		return enabled

	func init(configure: Callable) -> bool:
		options = FakeOptions.new()
		configure.call(options)
		started += 1
		enabled = true
		return true

	func close() -> void:
		closed += 1
		enabled = false

	func set_user_id(id: String) -> void:
		user_id = id

	func new_user(id: String) -> Dictionary:
		return {"id": id}

	func set_context(key: String, value: Dictionary) -> void:
		contexts[key] = value

	func set_tags(new_tags: Dictionary) -> void:
		tags.merge(new_tags, true)

	func start_new_trace() -> void:
		pass

	func start_transaction(name: String, attributes: Dictionary) -> FakeSpan:
		var span := FakeSpan.new(name, attributes, null)
		spans.append(span)
		return span

	func start_child(parent: Object, name: String, attributes: Dictionary) -> FakeSpan:
		var span := FakeSpan.new(name, attributes, parent)
		spans.append(span)
		return span

	func end_span(span: Object) -> void:
		(span as FakeSpan).ended = true

	## The transactions sent (root spans), by name.
	func roots(name: String) -> Array[FakeSpan]:
		var found: Array[FakeSpan] = []
		for span: FakeSpan in spans:
			if span.parent == null and span.name == name and span.ended:
				found.append(span)
		return found


class FakeSpan extends RefCounted:
	var name := ""
	var attributes := {}
	var parent: Object
	var ended := false

	func _init(span_name: String, span_attributes: Dictionary, span_parent: Object) -> void:
		name = span_name
		attributes = span_attributes
		parent = span_parent


## SentryOptions' properties DesktopReports sets.
class FakeOptions extends RefCounted:
	var dsn := ""
	var release := ""
	var environment := ""
	var send_default_pii := true
	var attach_log := true
	var attach_scene_tree := true
	var attach_screenshot := true
	var enable_app_hang_tracking := true
	var max_breadcrumbs := 100
	var traces_sample_rate := 0.0
	var trace_propagation_targets := [".*"]
	var godot_logger := FakeLogger.new()
	var before_send := Callable()
	var before_send_transaction := Callable()
	var before_send_log := Callable()
	var before_send_metric := Callable()
	var before_send_feedback := Callable()


class FakeLogger extends RefCounted:
	var event_mask := 13
	var breadcrumb_mask := 143
	var log_mask := 0
	var include_variables := true


## A SentryEvent's methods, on a dictionary shaped like the native event.
class FakeEvent extends RefCounted:
	var crash := false
	var message := ""
	var values: Array[String] = []
	var contexts := {}
	var user: Variant = {"id": "the SDK's installation id", "ip_address": "{{auto}}"}

	func is_crash() -> bool:
		return crash

	func get_exception_count() -> int:
		return values.size()

	func get_exception_value(index: int) -> String:
		return values[index] if index < values.size() else ""

	func set_exception_value(index: int, value: String) -> void:
		values[index] = value

	func set_context(key: String, value: Dictionary) -> void:
		contexts[key] = value

	func set_user(value: Variant) -> void:
		user = value

	func to_json() -> String:
		return JSON.stringify({"message": {"formatted": message}, "contexts": contexts})


func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func() -> void: _finish("The desktop reports contract timed out."))
	_settings_file = "user://test-desktop-reports-%d.cfg" % OS.get_process_id()
	_data_dir = "user://test-desktop-reports-%d" % OS.get_process_id()
	ShadowQuality.settings_path = _settings_file
	DirAccess.remove_absolute(_settings_file)
	DesktopReports.remove_tree(_data_dir)
	DirAccess.make_dir_recursive_absolute(_data_dir.path_join(DesktopReports.SDK_DATABASE))
	call_deferred("_run")


func _run() -> void:
	var ok := _check_gate() and _check_start() and _check_switch_off() and _check_before_send() \
		and _check_stats() and _check_audit() and _check_hud()
	if ok:
		print("PASS: desktop reports: nothing starts on the web, in a test or capture driver, from source or the editor, headless, in a launch check, without a build stamp, an add-on or a DSN (this run gets no page, and the real SDK stays off); with the switch on it starts after the notice (after play in the run that first shows it) with no PII, log file, screenshots, breadcrumbs, logs or app hangs, the anonymous id as its user and the scope's contexts replaced; off closes it at once, deletes the id and the SDK's files and stays off; an error leaves scrubbed of home folders and names, with the allowed contexts only, each message once and at most %d a run, a crash always; snapshot tags, stats transactions with a child span per area and movement, at most %d a run, and the funnel; the audit admits exactly the add-on's files; Options' switch and the loading screen's line" % [DesktopReports.MAX_ERROR_EVENTS, DesktopReports.MAX_STATS])
	_finish()


func _page() -> DesktopReports:
	return DesktopReports.new(FakeBackend.new(), _data_dir, DSN, STAMP)


func _facts() -> Dictionary:
	return {"web": false, "scripted": false, "exported": true, "display": "macOS", "launch_check": false, "stamped": true, "sdk": true, "dsn": DSN}


func _check_gate() -> bool:
	if not _require(DesktopReports.blocked_reason(_facts()) == "", "An exported, stamped desktop build with the add-on and a DSN, on any desktop OS, may send (it says \"%s\")." % DesktopReports.blocked_reason(_facts())):
		return false
	for blocking: Array in [["web", true], ["scripted", true], ["exported", false], ["display", "headless"], ["launch_check", true], ["stamped", false], ["sdk", false], ["dsn", ""], ["dsn", "https://sentry.example/1"]]:
		var facts := _facts()
		facts[blocking[0]] = blocking[1]
		if not _require(not DesktopReports.blocked_reason(facts).is_empty(), "A run with %s = %s must send nothing." % blocking):
			return false
	return _require(DesktopReports.make_page() == null, "This run (a test, headless, from source) must get no page.") \
		and _require(DesktopReports.release_name(STAMP) == "grand-treasure-island@2178+1a2b3c4", "The release must be grand-treasure-island@<build>+<short commit>, as on the web (it is %s)." % DesktopReports.release_name(STAMP))


func _check_start() -> bool:
	# A first launch: the switch on (CrashReports's default), the notice not yet seen.
	var page := _page()
	var backend := page.backend as FakeBackend
	var reports := CrashReports.new(page, CrashReports.saved())
	if not _require(reports.on and reports.notice and backend.started == 0, "On a first launch the switch is on, the notice due and nothing started (on %s, notice %s, started %d)." % [reports.on, reports.notice, backend.started]):
		return false
	page.world_ready()
	reports.notice_shown()
	if not _require(backend.started == 0, "In the run that first shows the notice nothing may start before play does."):
		return false
	reports.play_started()
	var options := backend.options
	if not _require(backend.started == 1 and options != null, "Play's start after the notice must start the SDK once (started %d)." % backend.started):
		return false
	var logger := options.godot_logger
	if not _require(options.dsn == DSN and options.release == "grand-treasure-island@2178+1a2b3c4" and options.environment == "production", "The SDK must get the DSN, the release and production (it got %s, %s, %s)." % [options.dsn, options.release, options.environment]) \
	or not _require(not options.send_default_pii and not options.attach_log and not options.attach_scene_tree and not options.attach_screenshot and not options.enable_app_hang_tracking and options.max_breadcrumbs == 0 and options.trace_propagation_targets.is_empty(), "The SDK must send no PII, log file, scene tree or screenshot, track no app hangs and keep no breadcrumbs.") \
	or not _require(logger.event_mask == DesktopReports.EVENT_MASK and logger.breadcrumb_mask == 0 and logger.log_mask == 0 and not logger.include_variables, "Godot's engine, script and shader errors must go as events only, without variables (masks %d, %d, %d)." % [logger.event_mask, logger.breadcrumb_mask, logger.log_mask]) \
	or not _require(is_equal_approx(options.traces_sample_rate, DesktopReports.TRACES_SAMPLE_RATE) and options.before_send.is_valid() and options.before_send_transaction.is_valid() and options.before_send_log.is_valid() and options.before_send_metric.is_valid(), "The SDK must trace every load and stats message and pass every report through the page's callbacks."):
		return false
	var kept: Variant = _kept(DesktopReports.ID_KEY)
	if not _require(kept is String and GameStats.anonymous_id(kept) == kept and backend.user_id == kept, "The anonymous id must be made (GameStats.anonymous_id), kept in the settings file and be the reports' user (kept %s, user %s)." % [kept, backend.user_id]) \
	or not _require(_sdk_installation_id() == kept, "The add-on must read the anonymous id as its installation id on the next launch (sentry.dat has %s)." % _sdk_installation_id()):
		return false
	var device: Dictionary = backend.contexts.get("device", {})
	if not _require(backend.contexts.get("culture") == {} and backend.contexts.get("display") == {} and backend.contexts.get("environment") == {} and device.keys() == ["arch", "device_type", "memory_class"], "The scope's contexts must be the game's own: the device's architecture, type and memory class alone, no locale, time zone or display (they are %s)." % backend.contexts):
		return false
	var started := backend.roots("play_started")
	if not _require(started.size() == 1 and int(started[0].attributes.world_ready_ms) >= 0 and started[0].attributes.get("sentry.op") == "ti.funnel", "Play's start must send the funnel's play_started step once, with the world-ready time."):
		return false
	# A later run: the notice seen, so it starts as the switch is read, before play.
	var later := _page()
	CrashReports.new(later, CrashReports.saved())
	return _require((later.backend as FakeBackend).started == 1 and (later.backend as FakeBackend).user_id == kept, "A later run with the notice seen must start at once, with the same id.")


func _check_switch_off() -> bool:
	var page := _page()
	var backend := page.backend as FakeBackend
	var reports := CrashReports.new(page, true)
	var old_id := str(_kept(DesktopReports.ID_KEY))
	DirAccess.make_dir_recursive_absolute(_data_dir.path_join(DesktopReports.SDK_DATABASE).path_join("pending"))
	FileAccess.open(_data_dir.path_join(DesktopReports.SDK_DATABASE).path_join("pending/report.dmp"), FileAccess.WRITE).store_string("x")
	reports.choose(false)
	CrashReports.save(reports.on)
	if not _require(backend.closed == 1 and not page.active and _kept(DesktopReports.ID_KEY) == null, "Off must close the SDK at once and delete the anonymous id (closed %d, id %s)." % [backend.closed, _kept(DesktopReports.ID_KEY)]) \
	or not _require(not DirAccess.dir_exists_absolute(_data_dir.path_join(DesktopReports.SDK_DATABASE)) and not FileAccess.file_exists(_data_dir.path_join(DesktopReports.SDK_RUNTIME_CONFIG)), "Off must delete what the SDK keeps on disk."):
		return false
	var sent := backend.roots("game stats").size()
	page.stats(JSON.stringify(_window(true)))
	if not _require(backend.roots("game stats").size() == sent and page._before_send(FakeEvent.new()) == null, "Nothing may go out once switched off."):
		return false
	reports.choose(true)
	var new_id := str(_kept(DesktopReports.ID_KEY))
	if not _require(backend.started == 1 and new_id != old_id and GameStats.anonymous_id(new_id) == new_id and _sdk_installation_id() == new_id, "On again in the same run must wait for the next launch, with a new id the add-on reads as it loads (started %d, id %s, was %s)." % [backend.started, new_id, old_id]):
		return false
	reports.choose(false)
	CrashReports.save(false)
	var later := _page()
	CrashReports.new(later, CrashReports.saved())
	var stays := _require((later.backend as FakeBackend).started == 0, "Switched off, a later run must start nothing.")
	CrashReports.save(true)
	return stays


func _check_before_send() -> bool:
	var page := _page()
	CrashReports.new(page, true)
	if not _require(page.active, "With the notice seen and the switch on the page must be started for the error checks."):
		return false
	page.scrub_paths = PackedStringArray(["/home/alice/.local/share/godot/app_userdata/Treasure Island First Playable", "/home/alice/Games/gti", "C:\\Users\\Bob\\AppData\\Roaming"])
	page.scrub_names = PackedStringArray(["alice", "deskbox"])
	var event := _leaky_event()
	event.contexts = {"device": {"arch": "x86_64", "name": "deskbox", "device_unique_identifier": "1234", "model": "XPS 15"}, "culture": {"locale": "de_DE", "timezone": "Europe/Berlin"}, "godot_engine": {"version": "4.7.2", "command_line_arguments": ["/home/alice/x"]}, "godot_performance": {"fps": 60, "static_memory_usage": "1 GiB"}, "trace": {"trace_id": "abc"}, "game": {"area": "1,2"}}
	if not _require(page._before_send(event) == event, "An error must go out."):
		return false
	var text := event.message + " " + event.values[0]
	for leak: String in ["alice", "deskbox", "Bob", "carol", "dave", "/home/alice", "Users\\Bob"]:
		if not _require(not text.contains(leak) or (leak == "alice" and text.contains("malice") and not text.replace("malice", "").contains("alice")), "An error's text must not carry %s: %s" % [leak, text]):
			return false
	if not _require(text.contains("<folder>/settings.cfg") and text.contains("/Users/<user>/") and text.contains("/home/<user>/") and text.contains("<name>") and text.contains("malice"), "Folders and names must become placeholders, other words untouched: %s" % text):
		return false
	if not _require(not event.contexts.device.has("device_unique_identifier") and not event.contexts.device.has("name") and not event.contexts.device.has("model") and event.contexts.culture == {} and not event.contexts.godot_engine.has("command_line_arguments") and event.contexts.godot_performance == {"fps": 60.0}, "An error's contexts must be pared down to the allowed ones: %s" % event.contexts) \
	or not _require(event.contexts.trace == {"trace_id": "abc"} and event.contexts.game == {"area": "1,2"} and event.user == {"id": page.anonymous_id}, "An error keeps its trace and the game's snapshot, and its user is the anonymous id alone (%s)." % [event.user]):
		return false
	if not _require(page._before_send(_leaky_event()) == null, "The same message must go once a run."):
		return false
	var sent := 1
	for index in DesktopReports.MAX_ERROR_EVENTS + 3:
		var other := FakeEvent.new()
		other.values = ["error %d" % index] as Array[String]
		if page._before_send(other) != null:
			sent += 1
	var crash := FakeEvent.new()
	crash.crash = true
	if not _require(sent == DesktopReports.MAX_ERROR_EVENTS and page._before_send(crash) == crash, "At most %d error events a run (%d went), a crash always." % [DesktopReports.MAX_ERROR_EVENTS, sent]):
		return false
	var transaction := FakeEvent.new()
	transaction.contexts = {"trace": {"op": "ti.stats", "data": {"fps_median": 58.0}}, "device": {"device_unique_identifier": "1234"}, "display": {"screens": []}}
	return _require(page._before_send_transaction(transaction) == transaction and transaction.contexts.trace.data.fps_median == 58.0 and not transaction.contexts.device.has("device_unique_identifier") and transaction.contexts.display == {} and transaction.user == {"id": page.anonymous_id}, "A transaction keeps its trace and data, loses the rest as an error does and has the anonymous id as its user (%s)." % transaction.contexts)


## An error whose text carries a home folder, the data folder, user and computer names.
func _leaky_event() -> FakeEvent:
	var event := FakeEvent.new()
	event.message = "Can't open /home/alice/.local/share/godot/app_userdata/Treasure Island First Playable/settings.cfg on deskbox"
	event.values = ["Missing C:\\Users\\Bob\\AppData\\Roaming\\Godot\\x.pck and /Users/carol/Library/y and /home/dave/z, said alice not malice"] as Array[String]
	return event


func _window(first: bool) -> Dictionary:
	return {"first": first, "play_min": 1, "window_s": 60, "fps_median": 58.5, "fps_p05": 41.0, "fps_worst": 33.2, "areas_s": {"3,-7": 40, "4,-7": 15, "other": 5}, "movement_s": {"on_foot": 30, "jetpack": 20, "in_car": 10}, "graphics_changes": [{"setting": "shadows", "from": "medium", "to": "high"}], "snapshot": {"area": "3,-7", "movement": "on_foot", "fps": "55+", "video_mb": 812, "texture_mb": 400, "buffer_mb": 120}}


func _check_stats() -> bool:
	var page := _page()
	var backend := page.backend as FakeBackend
	CrashReports.new(page, true)
	page.snapshot(JSON.stringify(_window(true).snapshot))
	if not _require(backend.tags == {"area": "3,-7", "movement": "on_foot", "fps": "55+"} and backend.contexts.game.video_mb == 812, "The snapshot's bands must go on the scope as tags and all of it as the game context (tags %s)." % backend.tags):
		return false
	page.stats(JSON.stringify(_window(true)))
	var stats := backend.roots("game stats")
	if not _require(stats.size() == 1, "A stats message must be one \"game stats\" transaction."):
		return false
	var data := stats[0].attributes
	var children := backend.spans.filter(func(span: FakeSpan) -> bool: return span.parent == stats[0])
	if not _require(data.get("sentry.op") == "ti.stats" and data.fps_median == 58.5 and data.fps_p05 == 41.0 and data.fps_worst == 33.2 and data.play_min == 1 and data.video_mb == 812 and str(data.graphics_changes).contains("shadows"), "The transaction must carry the stats' numbers (%s)." % data) \
	or not _require(children.size() == 6 and children.all(func(span: FakeSpan) -> bool: return span.ended and span.attributes.has("seconds")), "It must have a child span per area and per movement, with its seconds (%d)." % children.size()) \
	or not _require(backend.roots("playing_1min").size() == 1, "The first stats message must send the funnel's playing_1min step."):
		return false
	for index in DesktopReports.MAX_STATS + 2:
		page.stats(JSON.stringify(_window(false)))
	return _require(backend.roots("game stats").size() == DesktopReports.MAX_STATS and backend.roots("playing_1min").size() == 1, "At most %d stats messages a run, and playing_1min once (%d sent)." % [DesktopReports.MAX_STATS, backend.roots("game stats").size()])


func _check_audit() -> bool:
	for path: String in AUDIT.SENTRY_ADDON_PACK_FILES:
		if not _require(AUDIT.addon_problem(path) == "", "The audit must admit %s." % path):
			return false
	for path: String in ["addons/sentry/bin/linux/x86_64/crashpad_handler", "addons/sentry/README.md", "addons/generated_world_export/plugin.gd", "addons/other/thing.gd"]:
		if not _require(AUDIT.addon_problem(path) != "", "The audit must not admit %s in a pack." % path):
			return false
	var linux := PackedStringArray(AUDIT.SENTRY_ADDON_BESIDE.linux)
	var windows := PackedStringArray(AUDIT.SENTRY_ADDON_BESIDE.windows)
	var extra := linux.duplicate()
	extra.append("libextra.so")
	var missing := windows.slice(0, windows.size() - 1)
	return _require(AUDIT.beside_problem(linux) == "" and AUDIT.beside_problem(windows) == "", "The audit must admit a Linux or Windows folder holding exactly the game and the add-on's files.") \
		and _require(AUDIT.beside_problem(extra) != "" and AUDIT.beside_problem(missing) != "" and AUDIT.beside_problem(PackedStringArray(["readme.txt"])) != "", "The audit must fail a folder with another file, one missing, or no game.")


func _check_hud() -> bool:
	var hud := (load(HUD_SCENE) as PackedScene).instantiate() as GameHUD
	root.add_child(hud)
	var asked: Array = []
	hud.crash_reports_chosen.connect(func(on: bool) -> void: asked.append(on))
	hud.set_crash_reports(true, true)
	var shown := hud.privacy_row.visible and hud.privacy_heading.visible and hud.crash_reports.button_pressed and hud.crash_reports.text == "Send anonymous statistics"
	hud.crash_reports.button_pressed = false
	hud.show_reports_note(GameHUD.START_REPORTS_NOTE)
	var note := hud.reports_note_shown() and hud.load_reports_note.text == GameHUD.START_REPORTS_NOTE
	hud.set_crash_reports(false, true)
	var hidden := not hud.privacy_row.visible
	hud.queue_free()
	return _require(shown and asked == [false] and hidden, "Options must show the switch where there is a page, pressed when on, and ask for a change (shown %s, asked %s, hidden %s)." % [shown, asked, hidden]) \
		and _require(note, "The loading screen must show the line about the statistics.")


func _kept(key: String) -> Variant:
	var file := ConfigFile.new()
	if file.load(_settings_file) != OK or not file.has_section_key(CrashReports.SECTION, key):
		return null
	return file.get_value(CrashReports.SECTION, key)


func _sdk_installation_id() -> String:
	var file := ConfigFile.new()
	file.load(_data_dir.path_join(DesktopReports.SDK_RUNTIME_CONFIG))
	return str(file.get_value("main", "installation_id", ""))


func _require(condition: bool, message: String) -> bool:
	if not condition and _failure.is_empty():
		_failure = message
	return condition


func _finish(timeout_message := "") -> void:
	if not timeout_message.is_empty():
		_failure = timeout_message
	# The real SDK (the editor loaded the add-on) was never started by anything here.
	var real := SentryBackend.new()
	if real.available() and real.is_enabled():
		_failure = "Sentry's SDK was started in a test run." if _failure.is_empty() else _failure
	DirAccess.remove_absolute(_settings_file)
	DesktopReports.remove_tree(_data_dir)
	if not _failure.is_empty():
		print("FAIL: " + _failure)
		quit(1)
	else:
		quit(0)
