class_name DesktopReports
extends RefCounted
## The anonymous statistics on desktop (owner, 2026-11-17: crash and error reports,
## sessions per build, load times and the timed stats; "Always opt-out", with Options'
## switch stopping all sending), sent to Sentry's project for the desktop builds through
## its official Godot add-on (addons/sentry, pinned to release 2.5.1; SentryBackend is
## the one script that calls it). This is CrashReports' page on desktop, as the web page
## is on the web (main.gd's crash_page): it hears the switch (set_enabled), the notice
## shown (notice_shown), play's start (play_started), the game's state (snapshot) and the
## timed stats (stats) from GameStats, and starts or closes the SDK.
##
## Nothing starts and nothing is sent unless the switch is on and the player has seen the
## notice (main.gd puts it on the loading screen until it has been shown; turning the
## switch on in Options counts the same), and in the run that first shows it, not before
## play starts. Turning the switch off closes the SDK at once, deletes the anonymous id
## and what the SDK keeps on disk, and stays off across runs (CrashReports keeps it);
## turned on again, it starts with the next launch, under a new id. make_page gives no
## page, so nothing is ever started, on the web (its page sends its own), in a test or
## capture driver (DayClock.scripted), a run from source or the editor, a headless run, a
## launch check (--quit-on-ready), a build without its build stamp (one exported by hand)
## or where the add-on did not load.
##
## What is sent: errors and crashes (Godot's engine, script and shader errors as events;
## no warnings, no logs, no breadcrumbs, no screenshots, no log file, no scene tree),
## Sentry's sessions (release health), two loading-funnel steps (GameStats.FUNNEL_STEPS'
## play_started, with the times to world-ready and play-ready, and playing_1min) and one
## "game stats" transaction per timed stats message, each a small transaction (op ti.funnel
## or ti.stats). Every report carries the build as its release, the game's latest snapshot
## (GameStats.snapshot: its bands as tags, all of it as the "game" context), the system
## (the OS and its version, the CPU architecture, the GPU model as GameStats.coarse_gpu
## gives it and the renderer, the memory class) and, as its user id, the anonymous id
## (owner, 2026-11-17: "Let's just switch to permanent IDs ... People can just turn off
## analytics if they don't like it"): GameStats.anonymous_id, random bytes from the
## engine's cryptographic source, made when reporting first starts, kept in the settings
## file (ID_KEY) until the switch is turned off or the game's data removed. What the SDK adds of its own is
## pared down before anything leaves the game: the scope's contexts are replaced as the SDK
## starts (_clean_scope), and every error and transaction passes _before_send /
## _before_send_transaction, which drop every context but the allowed ones, take home
## folders, user and computer names out of the error's text, and set the user to the
## anonymous id alone. The add-on's own installation id (its first user id, read from
## SDK_RUNTIME_CONFIG as it loads) is set to ours for the next launch, and sentry-native's
## and Crashpad's own ids (SDK_DATABASE_IDS) are deleted before each start, so the
## anonymous id is the one id the reports share; on a Mac, Sentry's Cocoa component also
## sends its own installation id with session updates (README, KNOWN_ISSUES).

const BuildStamp := preload("res://game/scripts/ui/build_stamp.gd")

## The desktop project's DSN (public by design: it lets a build send reports and nothing
## else), in project.godot, where an override.cfg beside a test build points it at a
## stand-in endpoint.
const DSN_SETTING := "treasure_island/crash_reports/desktop_dsn"
## Sentry's DSN form: https://KEY@HOST/PROJECT, or http on the loopback (a stand-in).
const DSN_PATTERN := "^(https://[0-9a-f]{32}@[a-z0-9.-]+|http://[0-9a-f]{32}@127\\.0\\.0\\.1:[0-9]+)/[0-9]+$"
## The desktop's own keys in the settings file's privacy section (CrashReports keeps the
## switch there): whether the notice has been shown, and the anonymous id.
const NOTICE_KEY := "notice_shown"
const ID_KEY := "anonymous_id"
## The builds' launch checks (main.gd, tools/build-mac.sh, the release workflow).
const LAUNCH_CHECK_ARGUMENT := "--quit-on-ready"
## Every funnel step and stats message is a trace of a few spans: about 160 spans an hour
## of play at most, 1.6 million a month at 10,000 hours, inside the free plan's 5 million.
const TRACES_SAMPLE_RATE := 1.0
## A run sends at most this many error events (crashes always go), each message once, so
## an error repeating in a loop can't use up the plan's 5,000 errors a month; and at most
## MAX_STATS timed stats messages (four hours of play).
const MAX_ERROR_EVENTS := 10
const MAX_STATS := 48
## Godot's errors as events: engine, script and shader errors; none as breadcrumbs or logs.
const EVENT_MASK := 1 | 4 | 8
## The add-on's files in the game's data folder: its runtime config, whose installation id
## it reads as it loads and uses as the first user id; and sentry-native's database, with
## sentry-native's installation id and Crashpad's settings (Crashpad's client id, which goes
## with a crash's upload), and pending reports.
const SDK_RUNTIME_CONFIG := "sentry.dat"
const SDK_DATABASE := "sentry"
const SDK_DATABASE_IDS: Array[String] = ["installation_id", "settings.dat"]
## The snapshot's fields that go as tags (the rest, numbers, only in its context).
const TAG_FIELDS: Array[String] = ["area", "movement", "height_m", "speed_m_s", "fps", "session_min", "resolution", "shadows", "frame_rate_limit", "gpu", "screen", "input"]
## The stats' numbers on a "game stats" transaction (span data), as GameStats names them.
const STATS_FIELDS: Array[String] = ["first", "play_min", "window_s", "fps_median", "fps_p05", "fps_worst"]
const SNAPSHOT_NUMBERS: Array[String] = ["video_mb", "texture_mb", "buffer_mb"]
## The memory classes (GiB) and the contexts a report keeps: these are replaced by the
## game's own (system_contexts), "game" and "trace" (a transaction's data) go as they are,
## "godot_performance" keeps its numbers, and every other context is emptied.
const MEMORY_EDGES_GB := [4.0, 8.0, 16.0, 32.0]
const OWN_CONTEXTS: Array[String] = ["os", "device", "gpu", "app", "godot_engine"]
const KEPT_CONTEXTS: Array[String] = ["game", "trace"]
## A user's folder in a path, whatever the system: its name becomes <user>.
const HOME_PATTERN := "(?i)(/home/|/Users/|[A-Z]:[\\\\/]Users[\\\\/]|[A-Z]:[\\\\/]Documents and Settings[\\\\/])[^/\\\\\\s'\":]+"

## The SDK, through SentryBackend or a test's stand-in.
var backend: Object
## The game's data folder (user://, a test's own folder) and the DSN.
var data_dir := ""
var dsn := ""
## The release: the build number and the commit's first seven digits, as on the web.
var release := ""
## The switch, the notice seen (ever, and first in this run), play started, whether the
## SDK is started by this page, and whether the switch was turned off in this run (on
## again, it waits for the next launch: the SDK's first user id this run is the old id).
var on := false
var notice_seen := false
var notice_seen_now := false
var playing := false
var active := false
var switched_off := false
## The anonymous id in use ("" until reporting first starts), and the system's contexts.
var anonymous_id := ""
var own_contexts := {}
## The times (Time.get_ticks_msec) the world and play were ready.
var world_ready_msec := -1
var play_ready_msec := -1
## Text taken out of an error's: the home and data folders, then the user and computer names.
var scrub_paths := PackedStringArray()
var scrub_names := PackedStringArray()

var _lock := Mutex.new()
var _errors_sent := 0
var _error_keys := {}
var _stats_sent := 0
var _funnel_sent := {}
var _tags := {}


## The desktop page, or null where nothing may be sent (above); prints why on a line of
## its own (CRASH_REPORTS), as the time of day does.
static func make_page() -> DesktopReports:
	var reason := blocked_reason(facts())
	print("CRASH_REPORTS %s" % ("desktop, %s" % OS.get_name() if reason.is_empty() else "off: " + reason))
	if not reason.is_empty():
		return null
	return DesktopReports.new(SentryBackend.new(), OS.get_user_data_dir(), str(ProjectSettings.get_setting(DSN_SETTING, "")), BuildStamp.read())


## What decides whether this run may send: the platform, how it runs and what it is.
static func facts() -> Dictionary:
	return {
		"web": OS.has_feature("web"),
		"scripted": DayClock.scripted(),
		"exported": OS.has_feature("template") and not OS.has_feature("editor") and not Engine.is_editor_hint(),
		"display": DisplayServer.get_name(),
		"launch_check": OS.get_cmdline_user_args().has(LAUNCH_CHECK_ARGUMENT),
		"stamped": not BuildStamp.read().is_empty(),
		"sdk": Engine.has_singleton(SentryBackend.SDK_SINGLETON),
		"dsn": str(ProjectSettings.get_setting(DSN_SETTING, "")),
	}


## Why a run with these facts sends nothing, or "" when it may.
static func blocked_reason(run: Dictionary) -> String:
	if bool(run.get("web", false)):
		return "the web page sends its own"
	if bool(run.get("scripted", true)):
		return "a test or capture driver"
	if not bool(run.get("exported", false)):
		return "a run from source or the editor"
	if str(run.get("display", "")) == "headless":
		return "a headless run"
	if bool(run.get("launch_check", true)):
		return "a launch check (%s)" % LAUNCH_CHECK_ARGUMENT
	if not bool(run.get("stamped", false)):
		return "a build without its build stamp"
	if not bool(run.get("sdk", false)):
		return "Sentry's add-on did not load"
	if not valid_dsn(str(run.get("dsn", ""))):
		return "no DSN in %s" % DSN_SETTING
	return ""


static func valid_dsn(value: String) -> bool:
	var found := RegEx.create_from_string(DSN_PATTERN).search(value)
	return found != null and found.get_string() == value


## The release for a build stamp: "grand-treasure-island@2178+1a2b3c4".
static func release_name(stamp: Dictionary) -> String:
	if stamp.is_empty():
		return ""
	return "grand-treasure-island@%d+%s" % [int(stamp.build), str(stamp.commit).left(7)]


func _init(sdk_backend: Object, game_data_dir: String, project_dsn: String, stamp: Dictionary) -> void:
	backend = sdk_backend
	data_dir = game_data_dir
	dsn = project_dsn
	release = release_name(stamp)
	notice_seen = _kept(NOTICE_KEY, false) == true
	var kept := str(_kept(ID_KEY, ""))
	anonymous_id = kept if not kept.is_empty() and GameStats.anonymous_id(kept) == kept else ""
	own_contexts = system_contexts(stamp)
	for path: String in [OS.get_user_data_dir(), OS.get_executable_path().get_base_dir(), OS.get_environment("APPDATA"), OS.get_environment("LOCALAPPDATA"), OS.get_environment("USERPROFILE"), OS.get_environment("HOME")]:
		if path.length() > 3 and not scrub_paths.has(path):
			scrub_paths.append(path)
	for name: String in [OS.get_environment("USER"), OS.get_environment("USERNAME"), OS.get_environment("LOGNAME"), OS.get_environment("HOSTNAME"), OS.get_environment("COMPUTERNAME")]:
		if name.length() >= 3 and not scrub_names.has(name):
			scrub_names.append(name)


# CrashReports' page (crash_reports.gd's WebPage has the same methods).

## The page's own record: on desktop the switch lives only in the settings file, which
## CrashReports reads, and the notice shows until it has been seen.
func read() -> String:
	return JSON.stringify({"on": null, "notice": not notice_seen})


## The switch: on starts the SDK as soon as it may (_update); off closes it at once.
## On again in a run that turned it off, it gets its new id now and starts with the next
## launch, whose add-on then reads that id as it loads.
func set_enabled(value: bool) -> void:
	if value == on:
		return
	on = value
	if not on:
		_switch_off()
	elif switched_off:
		_new_id()
		_prepare_sdk_ids()
	else:
		_update()


## The notice has been on screen (the loading screen's, or Options' switch turned on).
func notice_shown() -> void:
	if notice_seen:
		return
	notice_seen = true
	notice_seen_now = true
	_keep(NOTICE_KEY, true)
	_update()


## Play started: the run that first showed the notice may now send, beginning with the
## funnel's play_started step and its times.
func play_started() -> void:
	playing = true
	play_ready_msec = Time.get_ticks_msec()
	_update()
	if active:
		_send_funnel("play_started", {"world_ready_ms": world_ready_msec, "play_ready_ms": play_ready_msec, "first_notice": notice_seen_now})


## The world is loaded (main.gd's _on_world_ready): its time for play_started.
func world_ready() -> void:
	world_ready_msec = Time.get_ticks_msec()


## The game's state (GameStats.snapshot, as JSON) on the scope: its bands as tags, all of
## it as the "game" context, so a crash carries the last one.
func snapshot(json: String) -> void:
	if not active:
		return
	var state: Variant = JSON.parse_string(json)
	if not state is Dictionary:
		return
	backend.set_context("game", state)
	var tags := snapshot_tags(state)
	if tags != _tags:
		_tags = tags
		backend.set_tags(tags)


## A timed stats message (GameStats.take_stats, as JSON): one "game stats" transaction.
func stats(json: String) -> void:
	if not active or _stats_sent >= MAX_STATS:
		return
	var window: Variant = JSON.parse_string(json)
	if not window is Dictionary:
		return
	_stats_sent += 1
	send_stats(window)
	if bool(window.get("first", false)):
		_send_funnel("playing_1min", {"play_min": int(window.get("play_min", 0))})


## Sends the stats as a transaction "game stats" (op ti.stats): its numbers as span data,
## one child span per named area and per movement mode with its seconds (the SDK sets no
## span's times, so they last about nothing; the seconds are their data).
func send_stats(window: Dictionary) -> void:
	var data := {"sentry.op": "ti.stats"}
	for key: String in STATS_FIELDS:
		data[key] = window.get(key)
	var state: Dictionary = window.get("snapshot", {}) if window.get("snapshot") is Dictionary else {}
	for key: String in SNAPSHOT_NUMBERS:
		if state.has(key):
			data[key] = state[key]
	data["graphics_changes"] = JSON.stringify(window.get("graphics_changes", []))
	var root: Object = backend.start_transaction("game stats", data)
	for part: Array in [["areas_s", "ti.stats.area"], ["movement_s", "ti.stats.movement"]]:
		var seconds: Variant = window.get(part[0], {})
		if not seconds is Dictionary:
			continue
		for name: Variant in seconds:
			backend.end_span(backend.start_child(root, str(name), {"sentry.op": part[1], "seconds": int(seconds[name])}))
	backend.end_span(root)


# Starting and stopping.

## Starts the SDK once the switch is on and the notice seen, and in the run that first
## showed it, once play has started; not again in a run whose switch went off.
func _update() -> void:
	if active or switched_off or not on or not notice_seen or (notice_seen_now and not playing):
		return
	if anonymous_id.is_empty():
		_new_id()
	_prepare_sdk_ids()
	active = bool(backend.init(_configure))
	if not active:
		push_warning("CRASH_REPORTS: Sentry's SDK did not start")
		return
	backend.set_user_id(anonymous_id)
	_clean_scope()


## The SDK's options: what it captures and what it may send.
func _configure(options: Object) -> void:
	options.set("dsn", dsn)
	options.set("release", release)
	options.set("environment", "production")
	options.set("send_default_pii", false)
	options.set("attach_log", false)
	options.set("attach_scene_tree", false)
	options.set("attach_screenshot", false)
	options.set("enable_app_hang_tracking", false)
	options.set("max_breadcrumbs", 0)
	options.set("traces_sample_rate", TRACES_SAMPLE_RATE)
	options.set("trace_propagation_targets", [])
	var logger: Object = options.get("godot_logger")
	logger.set("event_mask", EVENT_MASK)
	logger.set("breadcrumb_mask", 0)
	logger.set("log_mask", 0)
	logger.set("include_variables", false)
	options.set("before_send", _before_send)
	options.set("before_send_transaction", _before_send_transaction)
	options.set("before_send_log", func(_entry: Object) -> Variant: return null)
	options.set("before_send_metric", func(_metric: Object) -> Variant: return null)
	options.set("before_send_feedback", func(_event: Object) -> Variant: return null)


## A new anonymous id (GameStats.anonymous_id), kept.
func _new_id() -> void:
	anonymous_id = GameStats.anonymous_id("")
	_keep(ID_KEY, anonymous_id)


## Off: the SDK closed at once, the anonymous id deleted, and what the SDK keeps on disk
## (its runtime config with the id, its database: pending reports, its and Crashpad's
## ids) deleted.
func _switch_off() -> void:
	switched_off = true
	if active:
		active = false
		backend.close()
	anonymous_id = ""
	_erase(ID_KEY)
	DirAccess.remove_absolute(data_dir.path_join(SDK_RUNTIME_CONFIG))
	remove_tree(data_dir.path_join(SDK_DATABASE))


## Before each start: the add-on's installation id (its first user id, read as it loads)
## set to the anonymous id for the next launch, and sentry-native's and Crashpad's own ids
## deleted, so each start makes new ones that nothing sends twice.
func _prepare_sdk_ids() -> void:
	var file := ConfigFile.new()
	var path := data_dir.path_join(SDK_RUNTIME_CONFIG)
	file.load(path)
	if str(file.get_value("main", "installation_id", "")) != anonymous_id:
		file.set_value("main", "installation_id", anonymous_id)
		file.save(path)
	for name: String in SDK_DATABASE_IDS:
		var id_path := data_dir.path_join(SDK_DATABASE).path_join(name)
		if FileAccess.file_exists(id_path):
			DirAccess.remove_absolute(id_path)


## The scope's contexts as the SDK set them, replaced: the game's own for the system,
## the rest emptied.
func _clean_scope() -> void:
	for key: String in OWN_CONTEXTS:
		backend.set_context(key, own_contexts[key])
	for key: String in ["culture", "display", "environment"]:
		backend.set_context(key, {})


# What leaves.

## An error or crash about to be sent: none once switched off; each message once and at
## most MAX_ERROR_EVENTS a run, a crash always (handled in the crash's own thread, with
## the scope already clean, so it does nothing more); its text scrubbed, its contexts
## pared down and its user the anonymous id.
func _before_send(event: Object) -> Variant:
	if not active:
		return null
	if bool(event.call("is_crash")):
		return event
	_lock.lock()
	var key := "%s|%s" % [event.call("get_exception_value", 0), event.get("message")]
	var allowed := not _error_keys.has(key) and _errors_sent < MAX_ERROR_EVENTS
	if allowed:
		_error_keys[key] = true
		_errors_sent += 1
	_lock.unlock()
	if not allowed:
		return null
	for index in int(event.call("get_exception_count")):
		event.call("set_exception_value", index, scrub_text(str(event.call("get_exception_value", index)), scrub_paths, scrub_names))
	var message := str(event.get("message"))
	if not message.is_empty():
		event.set("message", scrub_text(message, scrub_paths, scrub_names))
	_clean_event(event)
	return event


## A transaction about to be sent: none once switched off; its contexts pared down and its
## user the anonymous id.
func _before_send_transaction(transaction: Object) -> Variant:
	if not active:
		return null
	_clean_event(transaction)
	return transaction


func _clean_event(event: Object) -> void:
	var parsed: Variant = JSON.parse_string(str(event.call("to_json")))
	var contexts: Dictionary = (parsed as Dictionary).get("contexts", {}) if parsed is Dictionary and (parsed as Dictionary).get("contexts") is Dictionary else {}
	var cleaned := clean_contexts(contexts, own_contexts)
	for key: String in cleaned:
		event.call("set_context", key, cleaned[key])
	event.call("set_user", backend.new_user(anonymous_id) if not anonymous_id.is_empty() else null)


## The contexts to set on a report with these contexts: the game's own for OWN_CONTEXTS,
## "godot_performance" with its numbers alone, every other context but KEPT_CONTEXTS
## emptied.
static func clean_contexts(contexts: Dictionary, own: Dictionary) -> Dictionary:
	var cleaned := {}
	for key: String in OWN_CONTEXTS:
		cleaned[key] = own.get(key, {})
	for key: Variant in contexts:
		var name := str(key)
		if name in OWN_CONTEXTS or name in KEPT_CONTEXTS:
			continue
		var kept := {}
		if name == "godot_performance" and contexts[key] is Dictionary:
			for field: Variant in contexts[key]:
				var value: Variant = contexts[key][field]
				if value is int or value is float:
					kept[field] = value
		cleaned[name] = kept
	return cleaned


## The system as reports carry it: the OS and its version, the CPU architecture, the
## GPU's model (GameStats.coarse_gpu) and vendor, the renderer, the memory class, the
## game's name and build, and the engine's version. Nothing else of the machine.
static func system_contexts(stamp: Dictionary) -> Dictionary:
	var memory := float(OS.get_memory_info().get("physical", 0)) / 1073741824.0
	var os_name := OS.get_name()
	if os_name == "Linux" and not OS.get_distribution_name().is_empty():
		os_name = "Linux (%s)" % OS.get_distribution_name()
	return {
		"os": {"name": os_name, "version": OS.get_version()},
		"device": {"arch": Engine.get_architecture_name(), "device_type": "Desktop", "memory_class": GameStats.band(memory, MEMORY_EDGES_GB) + " GB" if memory > 0.0 else "unknown"},
		"gpu": {"name": GameStats.coarse_gpu(RenderingServer.get_video_adapter_name()), "vendor_name": RenderingServer.get_video_adapter_vendor(), "renderer": "%s (%s)" % [RenderingServer.get_current_rendering_method(), RenderingServer.get_current_rendering_driver_name()]},
		"app": {"app_name": str(ProjectSettings.get_setting("application/config/name")), "app_build": str(stamp.get("build", ""))},
		"godot_engine": {"version": str(Engine.get_version_info().get("string", ""))},
	}


## The snapshot's bands as tags.
static func snapshot_tags(state: Dictionary) -> Dictionary:
	var tags := {}
	for key: String in TAG_FIELDS:
		if state.has(key):
			tags[key] = str(state[key])
	return tags


## Text with no home or data folder, user name or computer name in it: each of paths
## (longest first) becomes <folder>, a user's folder in any other path <user>, and each
## of names, as a whole word, <name>.
static func scrub_text(text: String, paths: PackedStringArray, names: PackedStringArray) -> String:
	var sorted := Array(paths)
	sorted.sort_custom(func(a: String, b: String) -> bool: return a.length() > b.length())
	for path: String in sorted:
		text = text.replace(path, "<folder>").replace(path.replace("/", "\\"), "<folder>")
	text = RegEx.create_from_string(HOME_PATTERN).sub(text, "$1<user>", true)
	for name: String in names:
		text = RegEx.create_from_string("(?i)\\b%s\\b" % _escaped(name)).sub(text, "<name>", true)
	return text


static func _escaped(text: String) -> String:
	var out := ""
	for character in text:
		out += ("\\" + character) if "\\^$.|?*+()[]{}-/".contains(character) else character
	return out


## Deletes a folder and everything in it (links themselves, not what they point to).
static func remove_tree(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.include_hidden = true
	for file: String in dir.get_files():
		DirAccess.remove_absolute(path.path_join(file))
	for sub: String in dir.get_directories():
		if dir.is_link(sub):
			DirAccess.remove_absolute(path.path_join(sub))
		else:
			remove_tree(path.path_join(sub))
	DirAccess.remove_absolute(path)


## A funnel step (GameStats.FUNNEL_STEPS): one small transaction (op ti.funnel), once a run.
func _send_funnel(step: String, data: Dictionary) -> void:
	if _funnel_sent.has(step) or not step in GameStats.FUNNEL_STEPS:
		return
	_funnel_sent[step] = true
	data["sentry.op"] = "ti.funnel"
	backend.end_span(backend.start_transaction(step, data))


# The settings file's privacy section (CrashReports.SECTION).

func _kept(key: String, default: Variant) -> Variant:
	var file := ConfigFile.new()
	if file.load(ShadowQuality.settings_path) != OK:
		return default
	return file.get_value(CrashReports.SECTION, key, default)


func _keep(key: String, value: Variant) -> void:
	var file := ConfigFile.new()
	file.load(ShadowQuality.settings_path)
	file.set_value(CrashReports.SECTION, key, value)
	file.save(ShadowQuality.settings_path)


func _erase(key: String) -> void:
	var file := ConfigFile.new()
	if file.load(ShadowQuality.settings_path) != OK or not file.has_section_key(CrashReports.SECTION, key):
		return
	file.erase_section_key(CrashReports.SECTION, key)
	file.save(ShadowQuality.settings_path)
