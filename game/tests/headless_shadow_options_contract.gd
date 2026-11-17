extends SceneTree
## The sun's shadow quality on the pause menu's Options screen (owner, 2026-11-12:
## "make shadow quality configurable in-game ... sort of an options item"),
## headless. Each check makes main.tscn and frees it when the check ends, on failure
## too. The first lives a few frames, through the options-screen checks, and its
## world finishes loading meanwhile (the run prints WORLD_READY and PLAY_READY);
## each later one is made and freed with no frame between, before its world starts
## loading. The pause and Resume in the loaded game are headless_gameplay_contract.gd's.
##   - the default: with no saved choice, main puts on Medium, whose sun settings are
##     main.tscn's Sun's and whose shadow map and filter are project.godot's (the
##     engine's own);
##   - each level puts on exactly the settings it claims (ShadowQuality.settings_of):
##     the sun's shadow settings, and the shadow map and filter it hands the engine
##     (recorded by a stand-in); Off has no sun shadows; Low keeps Medium's map and
##     filter over fewer splits and a shorter range; High has a bigger map and a
##     finer filter, its nearest split no deeper than Medium's, over Medium's split
##     count and reach;
##   - the pause menu's Options, between Controls and Credits, opens the options
##     screen in its place with the level on pressed and focused, its focus ring
##     showing when Options was opened from the keys and hidden when by a click
##     (review note, 2026-11-15); Right then Enter choose the next level, which goes
##     on at once; the level in use, and only it, shows pressed, in the headings'
##     blue, whoever changes it; each level's note takes as many lines as every
##     other's, so the panel never jumps; Back returns to the pause menu;
##   - the choice survives a restart of the scene (the settings file), a level
##     chosen again replaces it, and an unknown saved level, a missing file or a
##     file that can't be written fall back quietly;
##   - the shared capture harness's main.use_saved_settings = false gets the default,
##     and a test or capture driver that would read or write the player's settings
##     file is caught (GameMain.player_settings_problem: its run logs an error);
##   - the web's one level (Off) leaves the options screen without the shadow
##     row, while the pause menu keeps Options for the other graphics rows and the
##     sound's volume, which every platform has, the volume focused when Options
##     opens (owner, 2026-11-14: a volume option on the web too; until then this
##     checked that the web had no Options);
##   - the frame rate limits, resolutions and frame rate display beside the shadow
##     levels (GraphicsSettings, owner 2026-11-14): the tables; with nothing kept the
##     engine as it started (no frame limit, project.godot's 3D scale and mode,
##     vsync untouched) and no frame rate shown; each choice on the options screen
##     puts on exactly what it claims at once (FSR below full scale on Forward+),
##     a choice's keyboard focus ring shows on it in use or not (at least
##     FOCUS_CONTRAST against the fill under it: the blue of the one in use, the
##     panel's dark round any other), the switch shows the frame rate, and all
##     three are kept: a restart puts them
##     on again, the capture harness's opt-out gets the defaults, and unknown,
##     missing and unwritable settings fall back quietly; the web offers them with
##     its own default resolution (two thirds, owner 2026-11-15);
##   - the anonymous statistics' switch (CrashReports, owner 2026-11-17):
##     with no page to send them (desktop) Options has no Privacy section; with a
##     page, as a browser has (a stand-in recording what it is told), the switch
##     shows under Privacy after the sound, on by default, the page told so at
##     startup and asked for the start prompt's line about the reports; switched off,
##     the page is told at once and the choice kept, so a restart starts off and tells
##     the page off; off on either side wins over on on the other (a page that kept
##     off and a file that lost it, or the reverse), and the winner is kept; switched
##     on again, the page is told on and that the player has read about the reports;
##     the capture harness's opt-out gets the default (on) and writes nothing.
## Uses its own settings file, removed at the end. The first failure stops the run.

const MAIN_SCENE := "res://game/scenes/main.tscn"
const SUN_KEYS := ["enabled", "mode", "splits", "max_distance"]
## A stand-in for the web page's crash reports (crash_page), as a browser gives main.
const ReportingPage := preload("res://game/tests/shared/reporting_page.gd")
## The least contrast a focus ring must have against what it lies on (WCAG 2's 3:1
## for a control's parts).
const FOCUS_CONTRAST := 3.0

var _failure := ""
var _settings_file := ""
## The main scene made for the check under way (_make_main), freed by the next or
## by _finish.
var _main: GameMain


## Records what the shadow levels hand the engine, in place of the RenderingServer.
class EngineRecorder extends RefCounted:
	var atlas := -1
	var bits_16 := false
	var filter := -1

	func directional_shadow_atlas_set_size(size: int, is_16bits: bool) -> void:
		atlas = size
		bits_16 = is_16bits

	func directional_soft_shadow_filter_set_quality(quality: int) -> void:
		filter = quality


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func() -> void: _finish("The shadow options contract timed out."))
	_settings_file = "user://test-shadow-options-%d.cfg" % OS.get_process_id()
	ShadowQuality.settings_path = _settings_file
	DirAccess.remove_absolute(_settings_file)
	call_deferred("_run")


func _run() -> void:
	if not _check_levels():
		return _finish()
	# With no saved choice: Medium, the scene's and the project's own settings.
	var main := _make_main()
	var scene_sun := _scene_sun()
	var pristine := _sun_state(scene_sun)
	var medium := main.shadows.settings_of("medium")
	var recorder := EngineRecorder.new()
	var check := ShadowQuality.new(scene_sun)
	check.server = recorder
	check.apply("medium")
	if not _require(main.shadows.current == "medium" and _sun_matches(main.get_node("Sun"), medium), "With no saved choice the game must put on Medium with main.tscn's sun settings (it has %s, sun %s)." % [main.shadows.current, _sun_state(main.get_node("Sun"))]) \
	or not _require(pristine == _sun_state(main.get_node("Sun")), "Medium must leave main.tscn's Sun as the scene has it: %s, not %s." % [pristine, _sun_state(main.get_node("Sun"))]) \
	or not _require(recorder.atlas == int(ProjectSettings.get_setting_with_override("rendering/lights_and_shadows/directional_shadow/size")) and recorder.bits_16 == bool(ProjectSettings.get_setting_with_override("rendering/lights_and_shadows/directional_shadow/16_bits")) and recorder.filter == int(ProjectSettings.get_setting_with_override("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality")), "Medium must hand the engine project.godot's own shadow map and filter (it gave %d px, 16-bit %s, filter %d)." % [recorder.atlas, recorder.bits_16, recorder.filter]):
		return _finish()
	# Each level: exactly what it claims, on the sun and to the engine.
	var applied := PackedStringArray()
	for level: Dictionary in ShadowQuality.LEVELS:
		var claims := check.settings_of(level.id)
		check.apply(level.id)
		if not _require(check.current == level.id and _sun_matches(scene_sun, claims) and recorder.atlas == int(claims.atlas) and recorder.bits_16 == bool(claims.bits_16) and recorder.filter == int(claims.filter), "%s must put on what it claims: sun %s and %d px / filter %d, but put on sun %s and %d px / filter %d." % [level.name, _claimed_sun(claims), claims.atlas, claims.filter, _sun_state(scene_sun), recorder.atlas, recorder.filter]):
			return _finish()
		applied.append("%s %s, %d px, filter %d" % [level.name, "on" if claims.enabled else "off", claims.atlas, claims.filter])
	check.apply("no-such-level")
	if not _require(check.current == ShadowQuality.default_id(), "A level this platform doesn't offer must put on the default, not %s." % check.current):
		return _finish()
	scene_sun.free()
	# The options screen in the pause menu, worked with keys, as in play (the
	# loading screen gone).
	var hud := main.hud
	hud.show_world_ready()
	hud.set_paused(true)
	await process_frame
	var order := PackedStringArray()
	for child: Node in hud.pause_box.get_node("PauseLayout").get_children():
		if child is Button:
			order.append(child.name)
	if not _require(order == PackedStringArray(["ResumeButton", "ControlsButton", "OptionsButton", "CreditsButton", "ExitButton"]) and hud.options_button.visible, "The pause menu must read Resume, Controls, Options, Credits, Exit (it has %s, Options shown %s)." % [order, hud.options_button.visible]):
		return _finish()
	# Opened from the keys (Enter on Options): the level's focus ring shows.
	hud.options_button.grab_focus()
	_key(KEY_ENTER)
	await process_frame
	var levels := hud.shadow_levels.get_children()
	var medium_button := hud.shadow_levels.get_node("medium") as Button
	if not _require(hud.options_visible() and not hud.pause_panel.visible and levels.size() == ShadowQuality.offered().size() and medium_button.button_pressed and medium_button.has_focus(true) and hud.shadow_note.text == str(medium.note), "Options opened with Enter must show the shadow levels in the pause menu's place, Medium pressed and focused with its focus ring showing and its note (shown %s, menu %s, %d buttons, focused %s, ring showing %s, note \"%s\")." % [hud.options_visible(), hud.pause_panel.visible, levels.size(), medium_button.has_focus(), medium_button.has_focus(true), hud.shadow_note.text]):
		return _finish()
	# Each level's note as many lines as every other's: the panel keeps its height.
	var note_lines := {}
	for level: Dictionary in ShadowQuality.offered():
		hud.show_shadow_level(str(level.id))
		note_lines[level.id] = hud.shadow_note.get_line_count()
	hud.show_shadow_level("medium")
	if not _require(note_lines.values().all(func(lines: int) -> bool: return lines == note_lines.medium), "Every shadow level's note must take as many lines as the others, so the options panel keeps its height as the level changes (lines %s)." % [note_lines]):
		return _finish()
	var next := str(levels[levels.find(medium_button) + 1].name)
	_key(KEY_RIGHT)
	_key(KEY_ENTER)
	await process_frame
	if not _require((hud.shadow_levels.get_node(next) as Button).button_pressed and not medium_button.button_pressed and main.shadows.current == next and _sun_matches(main.get_node("Sun"), main.shadows.settings_of(next)), "Right then Enter on the options screen must put on %s at once (on: %s)." % [next, main.shadows.current]) \
	or not _shows_only(hud, next, "after Right and Enter"):
		return _finish()
	# Whoever changes the level, the screen shows that one alone.
	main._on_shadow_quality_chosen("low")
	if not _shows_only(hud, "low", "after main put Low on"):
		return _finish()
	main._on_shadow_quality_chosen(next)
	if not _shows_only(hud, next, "after main put %s on again" % next):
		return _finish()
	hud.options_back_button.pressed.emit()
	await process_frame
	if not _require(not hud.options_visible() and hud.pause_panel.visible and hud.options_button.has_focus(), "Back on the options screen must go back to the pause menu, Options focused."):
		return _finish()
	# Opened by a click: the level in use focused, its ring hidden until a key moves it.
	_click(hud.options_button.get_global_rect().get_center())
	await process_frame
	var clicked := hud.shadow_levels.get_node(next) as Button
	var by_click := [hud.options_visible(), clicked.has_focus(), clicked.has_focus(true)]
	hud.options_back_button.pressed.emit()
	await process_frame
	if not _require(by_click == [true, true, false], "Options opened by a click must focus the level in use with its focus ring hidden ([shown, focused, ring showing] %s)." % [by_click]):
		return _finish()
	# A restart keeps the choice; choosing again replaces it.
	main = _make_main()
	if not _require(main.shadows.current == next and _sun_matches(main.get_node("Sun"), main.shadows.settings_of(next)) and (main.hud.shadow_levels.get_node(next) as Button).button_pressed, "After a restart the game must put %s on again, as chosen (it put on %s)." % [next, main.shadows.current]):
		return _finish()
	(main.hud.shadow_levels.get_node("off") as Button).button_pressed = true
	main = _make_main()
	if not _require(main.shadows.current == "off" and not (main.get_node("Sun") as DirectionalLight3D).shadow_enabled, "A level chosen again must replace the kept one (after choosing Off and a restart: %s)." % main.shadows.current):
		return _finish()
	# The capture harness's opt-out: the default, whatever is kept.
	main = _make_main(false)
	if not _require(main.shadows.current == ShadowQuality.default_id(), "With use_saved_settings off the game must put on the default, not the kept %s." % main.shadows.current):
		return _finish()
	var graphics := _check_graphics()
	if graphics.is_empty():
		return _finish()
	var reports := _check_crash_reports()
	if reports.is_empty():
		return _finish()
	_free_main()
	# A test or capture driver (this run) that would read or write the player's
	# settings file is caught, unless it brought a file of its own: main.gd's own
	# rule, run here without main, as main would report it with an error.
	ShadowQuality.settings_path = ShadowQuality.DEFAULT_SETTINGS_PATH
	var caught := GameMain.player_settings_problem(self, "chose a shadow level, writing")
	ShadowQuality.settings_path = _settings_file
	var own_file_ok := GameMain.player_settings_problem(self, "chose a shadow level, writing")
	if not _require(not caught.is_empty() and own_file_ok.is_empty(), "A driver using the player's settings file must be caught, and one with its own file let be (caught \"%s\", own file \"%s\")." % [caught, own_file_ok]):
		return _finish()
	# The web's levels (Off alone) leave the options screen without shadow levels,
	# and the pause menu with Options for the other graphics rows, as the web offers
	# them, and the sound, the volume focused.
	var web_hud := (load("res://game/scenes/ui/hud.tscn") as PackedScene).instantiate() as GameHUD
	root.add_child(web_hud)
	web_hud.set_shadow_levels(ShadowQuality.LEVELS.filter(func(level: Dictionary) -> bool: return level.web), "off")
	var web_rates := GraphicsSettings.offered(GraphicsSettings.FRAME_RATE_KEY, true)
	var web_resolutions := GraphicsSettings.offered(GraphicsSettings.RESOLUTION_KEY, true)
	web_hud.set_graphics(web_rates, web_resolutions, GraphicsSettings.defaults(true))
	web_hud.show_world_ready()
	web_hud.set_paused(true)
	web_hud.options_button.pressed.emit()
	await process_frame
	var web_options := web_hud.options_button.visible
	var web_shadows := web_hud.shadow_row.is_visible_in_tree() or web_hud.shadow_note.is_visible_in_tree()
	var web_volume := web_hud.sound_volume.is_visible_in_tree() and web_hud.sound_volume.has_focus() and web_hud.sound_mute.is_visible_in_tree()
	var web_graphics := [web_hud.graphics_heading.is_visible_in_tree(), web_hud.frame_rates.is_visible_in_tree(), web_hud.frame_rates.get_child_count(), web_hud.show_frame_rate.is_visible_in_tree(), _pressed(web_hud.frame_rates), web_hud.resolutions.is_visible_in_tree(), _pressed(web_hud.resolutions), web_hud.frame_rate_label.visible]
	web_hud.free()
	var web_expected := [true, web_rates.size() > 1, web_rates.size(), true, PackedStringArray(["unlimited"]), true, PackedStringArray(["67"]), false]
	if not _require(web_options and not web_shadows and web_volume, "With the web's one level (Off) the pause menu must keep Options (shown %s) for the sound, its volume shown and focused (%s), with no shadow levels on it (shown %s)." % [web_options, web_volume, web_shadows]) \
	or not _require(web_graphics == web_expected and web_resolutions.size() == GraphicsSettings.RESOLUTIONS.size(), "The web's options screen must show the Graphics heading, its frame rate limits (%d) with the display switch, every resolution and its defaults (No limit, 67 %%), no frame rate shown: expected %s, shows %s." % [web_rates.size(), web_expected, web_graphics]):
		return _finish()
	# Quiet fallbacks: an unknown kept level, a missing file, a file that can't be
	# written; the graphics the same (a kept value of the wrong kind too).
	var file := ConfigFile.new()
	file.set_value(ShadowQuality.SECTION, ShadowQuality.KEY, "blinding")
	file.set_value(GraphicsSettings.SECTION, GraphicsSettings.FRAME_RATE_KEY, "15")
	file.set_value(GraphicsSettings.SECTION, GraphicsSettings.RESOLUTION_KEY, 33)
	file.set_value(GraphicsSettings.SECTION, GraphicsSettings.SHOW_FRAME_RATE_KEY, "yes")
	file.save(_settings_file)
	var unknown := [ShadowQuality.saved_id(), GraphicsSettings.saved()]
	DirAccess.remove_absolute(_settings_file)
	var missing := [ShadowQuality.saved_id(), GraphicsSettings.saved()]
	ShadowQuality.settings_path = "user://no-such-folder-%d/settings.cfg" % OS.get_process_id()
	ShadowQuality.save_id("high")
	GraphicsSettings.save({GraphicsSettings.FRAME_RATE_KEY: "30", GraphicsSettings.RESOLUTION_KEY: "50", GraphicsSettings.SHOW_FRAME_RATE_KEY: true})
	var unwritten := [ShadowQuality.saved_id(), GraphicsSettings.saved()]
	ShadowQuality.settings_path = _settings_file
	var fallback := [ShadowQuality.default_id(), GraphicsSettings.defaults()]
	if not _require([unknown, missing, unwritten] == [fallback, fallback, fallback], "An unknown kept level or graphics setting, a missing file and an unwritable one must all give the defaults, quietly (gave %s, %s, %s)." % [unknown, missing, unwritten]):
		return _finish()
	print("PASS: shadow options: with no kept choice the game puts on Medium, main.tscn's sun and project.godot's shadow map and filter (the default); each level puts on what it claims (%s); the pause menu's Options (between Controls and Credits) opens the levels with the one on pressed and focused, its focus ring showing when opened with Enter and hidden when by a click, every level's note as many lines as the others' (the panel keeps its height), Right and Enter put on %s at once, the level in use alone shows pressed in the headings' blue whoever changes it, and Back returns; the choice survives a restart and a new one replaces it; the capture harness gets the default and a driver that would use the player's settings file is caught; %s; %s; the web's Off alone leaves Options with its graphics rows (No limit and 67 %% on) and the sound's volume, no shadow levels; unknown, missing and unwritable settings fall back quietly" % ["; ".join(applied), next, graphics, reports])
	_finish()


## The main scene made and readied (its shadow level put on), after freeing the
## one before: each lives a few frames at most, long before its world finishes
## loading. With a page, as a browser gives main (crash_page).
func _make_main(use_saved := true, page: Object = null) -> GameMain:
	_free_main()
	_main = (load(MAIN_SCENE) as PackedScene).instantiate() as GameMain
	_main.capture_mouse_on_ready = false
	_main.use_saved_settings = use_saved
	if page != null:
		_main.crash_page = page
	root.add_child(_main)
	return _main


## The anonymous statistics' switch (CrashReports), in mains made one after
## another as a browser would make them, each with a page standing in for the web
## page's reporting. No frame passes, so no main's world starts loading. Returns a
## summary, or "" after failing.
func _check_crash_reports() -> String:
	DirAccess.remove_absolute(_settings_file)
	# No page (desktop): no Privacy section.
	var main := _make_main()
	if not _require(main.crash_reports.page == null and main.crash_reports.on and not main.hud.privacy_heading.visible and not main.hud.privacy_row.visible, "With no page to send them, Options must have no switch for the crash reports (heading shown %s, row shown %s)." % [main.hud.privacy_heading.visible, main.hud.privacy_row.visible]):
		return ""
	# A page that never had the switch set: on, the page told so and asked for the notice.
	var page := ReportingPage.new()
	main = _make_main(true, page)
	var hud := main.hud
	var order := PackedStringArray()
	for child: Node in hud.options_panel.get_node("OptionsLayout").get_children():
		if (child as Control).visible:
			order.append(child.name)
	if not _require(main.crash_reports.on and hud.crash_reports.button_pressed and hud.privacy_row.visible and page.told == ["on"] and main.crash_reports.notice, "With a page that never had it set, the reports must be on, the switch shown pressed, the page told on and the start prompt asked for the notice (on %s, pressed %s, shown %s, told %s, notice %s)." % [main.crash_reports.on, hud.crash_reports.button_pressed, hud.privacy_row.visible, page.told, main.crash_reports.notice]) \
	or not _require(order.slice(order.size() - 5) == PackedStringArray(["SoundHeading", "SoundRow", "PrivacyHeading", "PrivacyRow", "BackButton"]) and hud.crash_reports.text == "Send anonymous statistics", "Options must end with Sound, then Privacy with \"Send anonymous statistics\", then Back (it reads %s, the switch \"%s\")." % [order, hud.crash_reports.text]):
		return ""
	# Switched off: the page told at once, the choice kept; a restart starts off.
	hud.crash_reports.button_pressed = false
	if not _require(not main.crash_reports.on and page.told.back() == "off" and not CrashReports.saved(), "Switching the reports off must tell the page off at once and keep it (on %s, told %s, kept %s)." % [main.crash_reports.on, page.told, CrashReports.saved()]):
		return ""
	page.told.clear()
	main = _make_main(true, page)
	if not _require(not main.crash_reports.on and not main.hud.crash_reports.button_pressed and page.told == ["off"] and not main.crash_reports.notice, "After a restart the reports must start off, the switch shown off, the page told off and no notice asked for (on %s, told %s, notice %s)." % [main.crash_reports.on, page.told, main.crash_reports.notice]):
		return ""
	# Off on either side wins over on on the other, and the winner is kept.
	CrashReports.save(true)
	page.kept = false
	main = _make_main(true, page)
	var page_off_wins := [main.crash_reports.on, CrashReports.saved()]
	CrashReports.save(false)
	page.kept = true
	page.told.clear()
	main = _make_main(true, page)
	var file_off_wins := [main.crash_reports.on, page.told.duplicate(), CrashReports.saved()]
	if not _require(page_off_wins == [false, false] and file_off_wins == [false, ["off"], false], "Off on either side must win over on on the other and be kept: a page that kept off over a file that says on gave [on, kept] %s; a file that kept off over a page that says on gave [on, told, kept] %s." % [page_off_wins, file_off_wins]):
		return ""
	# Switched on again: the page told on, and that the player has read about them.
	page.told.clear()
	main.hud.crash_reports.button_pressed = true
	if not _require(main.crash_reports.on and page.told == ["on", "notice shown"] and CrashReports.saved(), "Switching the reports on must tell the page on and that the player has read about them, and keep it (on %s, told %s, kept %s)." % [main.crash_reports.on, page.told, CrashReports.saved()]):
		return ""
	# The capture harness's opt-out: the default (on), the settings file untouched.
	CrashReports.save(false)
	page.kept = null
	main = _make_main(false, page)
	if not _require(main.crash_reports.on and not CrashReports.saved(), "With use_saved_settings off the reports must start on (the default) and the settings file stay as it was (on %s, kept %s)." % [main.crash_reports.on, CrashReports.saved()]):
		return ""
	return "the crash reports' switch: none without a page; with one, under Privacy after the sound, on by default and the page told so and asked for the notice; switched off at once on the page and kept over a restart; off on either side winning and kept; switched on again with the page told the player read about them; the capture harness on by default, writing nothing"


func _free_main() -> void:
	if is_instance_valid(_main):
		_main.free()
	_main = null


## The frame rate limits, resolutions and frame rate display (GraphicsSettings):
## the tables, then in a main made with nothing kept, the engine as it started and
## each choice on the options screen putting on what it claims at once, a restart
## putting the kept choices on again and the capture harness's opt-out getting the
## defaults. No frame passes, so no main's world starts loading. Returns a summary,
## or "" after failing.
func _check_graphics() -> String:
	# The tables: each choice named and explained, ids unique; No limit and 100 % set
	# nothing of their own; every other limit is a rate and every other resolution a
	# share below one; each platform's defaults are offered there.
	for table: Array in [GraphicsSettings.FRAME_RATES, GraphicsSettings.RESOLUTIONS]:
		var ids := {}
		for choice: Dictionary in table:
			if not _require(not ids.has(choice.id) and not str(choice.get("name", "")).is_empty() and not str(choice.get("note", "")).is_empty() and choice.get("web") is bool, "Graphics choice %s needs an id of its own, a name, a note and whether the web offers it." % choice):
				return ""
			ids[choice.id] = true
	var limits := GraphicsSettings.FRAME_RATES.filter(func(choice: Dictionary) -> bool: return choice.has("max_fps"))
	var scales := GraphicsSettings.RESOLUTIONS.filter(func(choice: Dictionary) -> bool: return choice.has("scale"))
	var desktop := GraphicsSettings.defaults(false)
	var web := GraphicsSettings.defaults(true)
	if not _require(limits.all(func(choice: Dictionary) -> bool: return int(choice.max_fps) > 0) and limits.size() == GraphicsSettings.FRAME_RATES.size() - 1 and not GraphicsSettings.FRAME_RATES.back().has("max_fps"), "Every frame rate limit but the last (No limit) must be a rate, and No limit must set none.") \
	or not _require(scales.all(func(choice: Dictionary) -> bool: return float(choice.scale) > 0.0 and float(choice.scale) < 1.0) and scales.size() == GraphicsSettings.RESOLUTIONS.size() - 1 and not GraphicsSettings.RESOLUTIONS.back().has("scale"), "Every resolution but the last (100 %) must be a share below one, and 100 % must set none.") \
	or not _require(desktop == {"frame_rate": "unlimited", "resolution": "100", "show_frame_rate": false} and web == {"frame_rate": "unlimited", "resolution": "67", "show_frame_rate": false}, "The defaults must be No limit and 100 %% on desktop (the game as it was) and No limit and 67 %% on the web (owner, 2026-11-15), no frame rate shown (are %s and %s)." % [desktop, web]) \
	or not _require(GraphicsSettings.offered(GraphicsSettings.RESOLUTION_KEY, true).any(func(choice: Dictionary) -> bool: return choice.id == web.resolution) and GraphicsSettings.offered(GraphicsSettings.FRAME_RATE_KEY, true).any(func(choice: Dictionary) -> bool: return choice.id == web.frame_rate) and GraphicsSettings.offered(GraphicsSettings.RESOLUTION_KEY).size() == GraphicsSettings.RESOLUTIONS.size() and GraphicsSettings.offered(GraphicsSettings.FRAME_RATE_KEY).size() == GraphicsSettings.FRAME_RATES.size(), "Desktop must offer every frame rate limit and resolution, and the web its own defaults."):
		return ""
	# Nothing kept: the engine as it started, project.godot's (no --max-fps here).
	DirAccess.remove_absolute(_settings_file)
	var vsync := DisplayServer.window_get_vsync_mode()
	var project := {
		"max_fps": int(ProjectSettings.get_setting_with_override("application/run/max_fps")),
		"scale": float(ProjectSettings.get_setting_with_override("rendering/scaling_3d/scale")),
		"mode": int(ProjectSettings.get_setting_with_override("rendering/scaling_3d/mode")),
	}
	var main := _make_main()
	var hud := main.hud
	var window := main.get_viewport()
	if not _require(main.graphics.current == desktop and _engine(window) == [project.max_fps, snappedf(project.scale, 0.01), project.mode] and not hud.frame_rate_label.visible and not hud.show_frame_rate.button_pressed \
			and _pressed(hud.frame_rates) == PackedStringArray(["unlimited"]) and _pressed(hud.resolutions) == PackedStringArray(["100"]) and DisplayServer.window_get_vsync_mode() == vsync, "With nothing kept the game must leave the engine as it started (max_fps, 3D scale and mode %s, not %s), show No limit and 100 %% pressed and no frame rate (%s), and leave vsync alone." % [project.values(), _engine(window), main.graphics.current]):
		return ""
	var order := PackedStringArray()
	for child: Node in hud.options_panel.get_node("OptionsLayout").get_children():
		if (child as Control).visible:
			order.append(child.name)
	if not _require(order.slice(0, 7) == PackedStringArray(["Title", "GraphicsHeading", "ShadowRow", "ShadowNote", "FrameRateRow", "ResolutionRow", "TimeHeading"]), "The options screen must read Options, then Graphics: the sun shadows, their note, the frame rate and the resolution, then the time of day (it reads %s)." % [order]):
		return ""
	# The switches show their track when off. A choice's keyboard focus ring lies on
	# the fill's own shape and shows on it in use or not: against the blue of the one
	# in use (Medium), and against the panel under any other's own fill (High); the
	# rings change over with the choice.
	var rings := []
	for id: String in ["medium", "high"]:
		var button := hud.shadow_levels.get_node(id) as Button
		var ring := button.get_theme_stylebox("focus") as StyleBoxFlat
		var normal := button.get_theme_stylebox("normal") as StyleBoxFlat
		var panel := (hud.options_panel.get_theme_stylebox("panel") as StyleBoxFlat).bg_color
		var under := GameHUD.CONTROLS_HEADING_COLOR if button.button_pressed else (panel.blend(normal.bg_color) if normal != null else panel)
		rings.append([id, button.button_pressed, ring != null and not ring.draw_center and ring.border_width_top >= 2 and ring.expand_margin_top == 0.0, snappedf(_contrast(ring.border_color, under), 0.1) if ring != null else 0.0])
	var medium_button := hud.shadow_levels.get_node("medium") as Button
	var high_button := hud.shadow_levels.get_node("high") as Button
	var before := [medium_button.get_theme_stylebox("focus"), high_button.get_theme_stylebox("focus")]
	high_button.button_pressed = true
	var changed_over := [high_button.get_theme_stylebox("focus"), medium_button.get_theme_stylebox("focus")] == before
	medium_button.button_pressed = true
	var rings_ok: bool = rings.all(func(ring: Array) -> bool: return ring[2] and ring[3] >= FOCUS_CONTRAST) and rings[0][1] and not rings[1][1] and changed_over
	if not _require(hud.show_frame_rate.has_theme_icon_override("unchecked") and hud.sound_mute.has_theme_icon_override("unchecked") and rings_ok, "The switches (Show fps, Mute) must draw their own Off track, and a choice's focus ring lie on its fill's shape with at least %.0f:1 against the fill under it, in use or not, and change over with the choice ([id, in use, on the fill's shape, contrast] %s; changed over %s)." % [FOCUS_CONTRAST, rings, changed_over]):
		return ""
	# Each choice on the options screen, as pressed there: on at once.
	var applied := PackedStringArray()
	for choice: Dictionary in GraphicsSettings.FRAME_RATES:
		(hud.frame_rates.get_node(str(choice.id)) as Button).button_pressed = true
		var want := [int(choice.get("max_fps", project.max_fps)), snappedf(project.scale, 0.01), project.mode]
		if not _require(_engine(window) == want and main.graphics.current.frame_rate == choice.id and _pressed(hud.frame_rates) == PackedStringArray([choice.id]) and DisplayServer.window_get_vsync_mode() == vsync, "The frame rate %s must put on max_fps, 3D scale and mode %s, alone pressed, with vsync left alone (put on %s)." % [choice.name, want, _engine(window)]):
			return ""
		applied.append("%s max_fps %d" % [choice.name, Engine.max_fps])
	for choice: Dictionary in GraphicsSettings.RESOLUTIONS:
		(hud.resolutions.get_node(str(choice.id)) as Button).button_pressed = true
		var below := choice.has("scale")
		var want := [project.max_fps, snappedf(float(choice.get("scale", project.scale)), 0.01), int(Viewport.SCALING_3D_MODE_FSR) if below else project.mode]
		if not _require(_engine(window) == want and main.graphics.current.resolution == choice.id and _pressed(hud.resolutions) == PackedStringArray([choice.id]), "The resolution %s must put on max_fps, 3D scale and mode %s (FSR below full scale), alone pressed (put on %s)." % [choice.name, want, _engine(window)]):
			return ""
		applied.append("%s scale %.2f mode %d" % [choice.name, window.scaling_3d_scale, window.scaling_3d_mode])
	hud.show_frame_rate.button_pressed = true
	if not _require(main.graphics.current.show_frame_rate and hud.frame_rate_label.visible and hud.frame_rate_label.text.ends_with(" fps"), "The switch must show the frame rate (shown %s, \"%s\")." % [hud.frame_rate_label.visible, hud.frame_rate_label.text]):
		return ""
	# Kept: a restart puts 30, 50 % and the frame rate on again.
	(hud.frame_rates.get_node("30") as Button).button_pressed = true
	(hud.resolutions.get_node("50") as Button).button_pressed = true
	main = _make_main()
	window = main.get_viewport()
	var kept := {"frame_rate": "30", "resolution": "50", "show_frame_rate": true}
	if not _require(main.graphics.current == kept and _engine(window) == [30, snappedf(0.5, 0.01), int(Viewport.SCALING_3D_MODE_FSR)] and main.hud.frame_rate_label.visible and main.hud.show_frame_rate.button_pressed \
			and _pressed(main.hud.frame_rates) == PackedStringArray(["30"]) and _pressed(main.hud.resolutions) == PackedStringArray(["50"]), "After a restart the game must put on the kept 30, 50 %% and the frame rate shown (it put on %s, engine %s)." % [main.graphics.current, _engine(window)]):
		return ""
	# The capture harness's opt-out: the defaults, whatever is kept.
	main = _make_main(false)
	window = main.get_viewport()
	if not _require(main.graphics.current == desktop and _engine(window) == [project.max_fps, snappedf(project.scale, 0.01), project.mode] and not main.hud.frame_rate_label.visible, "With use_saved_settings off the game must put on the graphics defaults and leave the engine as it started, not the kept %s (engine %s)." % [main.graphics.current, _engine(window)]):
		return ""
	return "the graphics: with nothing kept the engine as it started (max_fps %d, 3D scale %.2f, mode %d), vsync untouched, and no frame rate shown; each choice on at once (%s), a choice's focus ring showing on its fill in use or not and changing over with it, the switch shows the frame rate; 30, 50 %% and the display kept over a restart, and the capture harness gets the defaults" % [project.max_fps, project.scale, project.mode, "; ".join(applied)]


## The frame limit and the window's 3D scale (to a hundredth: the window keeps a
## 32-bit float) and mode, as the engine has them.
func _engine(window: Viewport) -> Array:
	return [Engine.max_fps, snappedf(window.scaling_3d_scale, 0.01), int(window.scaling_3d_mode)]


## The names of a row's pressed buttons.
func _pressed(row: Control) -> PackedStringArray:
	var pressed := PackedStringArray()
	for button: Node in row.get_children():
		if (button as Button).button_pressed:
			pressed.append(button.name)
	return pressed


## The options screen shows this level, and only it, pressed, filled in the headings'
## blue (not the keyboard focus's white outline), with its note.
func _shows_only(hud: GameHUD, id: String, when: String) -> bool:
	var pressed := PackedStringArray()
	for button: Button in hud.shadow_levels.get_children():
		if button.button_pressed:
			pressed.append(button.name)
	var marker := (hud.shadow_levels.get_node(id) as Button).get_theme_stylebox("pressed") as StyleBoxFlat
	return _require(pressed == PackedStringArray([id]) and marker != null and marker.bg_color == GameHUD.CONTROLS_HEADING_COLOR and hud.shadow_note.text == str(hud.shadow_levels.get_node(id).get_meta("note")), "The options screen must show %s alone pressed, in the headings' blue, with its note, %s (pressed: %s)." % [id, when, pressed])


## main.tscn's Sun as the scene has it, outside the tree.
func _scene_sun() -> DirectionalLight3D:
	var main := (load(MAIN_SCENE) as PackedScene).instantiate()
	var sun := main.get_node("Sun") as DirectionalLight3D
	main.remove_child(sun)
	main.free()
	return sun


func _sun_state(sun: DirectionalLight3D) -> Dictionary:
	return {"enabled": sun.shadow_enabled, "mode": int(sun.directional_shadow_mode), "splits": [sun.directional_shadow_split_1, sun.directional_shadow_split_2, sun.directional_shadow_split_3], "max_distance": sun.directional_shadow_max_distance}


func _claimed_sun(claims: Dictionary) -> Dictionary:
	var state := {}
	for key: String in SUN_KEYS:
		state[key] = claims[key]
	return state


func _sun_matches(sun: DirectionalLight3D, claims: Dictionary) -> bool:
	var state := _sun_state(sun)
	var splits: Array = claims.splits
	return state.enabled == bool(claims.enabled) and state.mode == int(claims.mode) and is_equal_approx(state.max_distance, float(claims.max_distance)) \
		and is_equal_approx(state.splits[0], float(splits[0])) and is_equal_approx(state.splits[1], float(splits[1])) and is_equal_approx(state.splits[2], float(splits[2]))


## The level table: each level named and explained, ids unique; Medium sets nothing
## of its own; the default on desktop is Medium, with every level offered, and on
## the web Off, alone; Off turns the sun's shadows off, Low is lighter than Medium and High
## finer.
func _check_levels() -> bool:
	var ids := {}
	for level: Dictionary in ShadowQuality.LEVELS:
		if not _require(not ids.has(level.id) and not str(level.get("name", "")).is_empty() and not str(level.get("note", "")).is_empty() and level.get("web") is bool, "Shadow level %s needs an id of its own, a name, a note and whether the web offers it." % level):
			return false
		ids[level.id] = level
	var own := (ids.medium as Dictionary).keys().filter(func(key: String) -> bool: return not key in ["id", "name", "note", "web"])
	var web := ShadowQuality.LEVELS.filter(func(level: Dictionary) -> bool: return level.web).map(func(level: Dictionary) -> String: return level.id)
	if not _require(own.is_empty(), "Medium must set nothing of its own (it is main.tscn's Sun with project.godot's map and filter), but sets %s." % [own]) \
	or not _require(ShadowQuality.default_id() == "medium" and ShadowQuality.offered().size() == ShadowQuality.LEVELS.size(), "On desktop the default must be Medium, with every level offered.") \
	or not _require(web == ["off"], "The web must offer Off, its default, alone (its Compatibility renderer brightened sunlit surfaces with sun shadows on), not %s." % [web]):
		return false
	var sun := _scene_sun()
	var levels := ShadowQuality.new(sun)
	var off := levels.settings_of("off")
	var low := levels.settings_of("low")
	var medium := levels.settings_of("medium")
	var high := levels.settings_of("high")
	sun.free()
	# The scene's split comes back as a 32-bit float (0.02 reads 0.0199999...).
	var high_first := float((high.splits as Array)[0])
	var medium_first := float((medium.splits as Array)[0])
	if not _require(high.enabled and int(high.atlas) > int(medium.atlas) and int(high.filter) > int(medium.filter) and (high_first < medium_first or is_equal_approx(high_first, medium_first)) \
			and int(high.mode) == int(medium.mode) and is_equal_approx(float(high.max_distance), float(medium.max_distance)), "High must be finer than Medium: a bigger shadow map and a finer filter, its nearest split no deeper than Medium's, with Medium's split count and reach (High's nearest split %s, Medium's %s)." % [high_first, medium_first]):
		return false
	return _require(not off.enabled, "Off must turn the sun's shadows off.") \
		and _require(low.enabled and int(low.atlas) == int(medium.atlas) and int(low.filter) == int(medium.filter) and int(low.mode) < int(medium.mode) and float(low.max_distance) < float(medium.max_distance), "Low must draw Medium's own map and filter (a smaller map and the cheapest filter striped and crawled), and be lighter by fewer splits over a shorter range.")


## WCAG's contrast ratio of two colours (sRGB, alpha aside): 1 to 21.
static func _contrast(a: Color, b: Color) -> float:
	var lighter := maxf(a.srgb_to_linear().get_luminance(), b.srgb_to_linear().get_luminance())
	var darker := minf(a.srgb_to_linear().get_luminance(), b.srgb_to_linear().get_luminance())
	return (lighter + 0.05) / (darker + 0.05)


## A left click (down and up) at `at`, in the HUD's pixels.
func _click(at: Vector2) -> void:
	for pressed: bool in [true, false]:
		var button := InputEventMouseButton.new()
		button.button_index = MOUSE_BUTTON_LEFT
		button.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		button.position = at
		button.global_position = at
		button.pressed = pressed
		root.push_input(button, true)


func _key(keycode: Key) -> void:
	for pressed: bool in [true, false]:
		var key := InputEventKey.new()
		key.keycode = keycode
		key.physical_keycode = keycode
		key.pressed = pressed
		root.push_input(key)


func _require(condition: bool, message: String) -> bool:
	if not condition and _failure == "":
		_failure = message
	return condition


func _finish(timeout_message := "") -> void:
	if timeout_message != "" and _failure == "":
		_failure = timeout_message
	_free_main()
	DirAccess.remove_absolute(_settings_file)
	if _failure != "":
		push_error("FAIL: " + _failure)
		print("FAIL: " + _failure)
		quit(1)
	else:
		quit(0)
