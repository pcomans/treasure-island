extends SceneTree
## The sun's shadow quality on the pause menu's Options screen (owner, 2026-11-12:
## "make shadow quality configurable in-game ... sort of an options item"),
## headless, with main.tscn made and freed before its world loads (the pause and
## Resume in the loaded game are headless_gameplay_contract.gd's):
##   - the default is the game as it was: with no saved choice, main puts on Medium,
##     whose sun settings are main.tscn's Sun's and whose shadow map and filter are
##     project.godot's (the engine's own);
##   - each level puts on exactly the settings it claims (ShadowQuality.settings_of):
##     the sun's shadow settings, and the shadow map and filter it hands the engine
##     (recorded by a stand-in); Off has no sun shadows, Low is lighter than Medium
##     and High finer;
##   - the pause menu's Options, between Controls and Credits, opens the options
##     screen in its place with the level on pressed and focused; Right then Enter
##     choose the next level, which goes on at once; Back returns to the pause menu;
##   - the choice survives a restart of the scene (the settings file), a level
##     chosen again replaces it, and an unknown saved level, a missing file or a
##     file that can't be written fall back quietly;
##   - the shared capture harness's main.use_saved_settings = false gets the default;
##   - the web's one level (Off) leaves the pause menu without Options.
## Uses its own settings file, removed at the end. The first failure stops the run.

const MAIN_SCENE := "res://game/scenes/main.tscn"
const SUN_KEYS := ["enabled", "mode", "splits", "max_distance"]

var _failure := ""
var _settings_file := ""


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
	hud.options_button.pressed.emit()
	await process_frame
	var levels := hud.shadow_levels.get_children()
	var medium_button := hud.shadow_levels.get_node("medium") as Button
	if not _require(hud.options_visible() and not hud.pause_panel.visible and levels.size() == ShadowQuality.offered().size() and medium_button.button_pressed and medium_button.has_focus() and hud.shadow_note.text == str(medium.note), "Options must show the shadow levels in the pause menu's place, Medium pressed and focused with its note (shown %s, menu %s, %d buttons, note \"%s\")." % [hud.options_visible(), hud.pause_panel.visible, levels.size(), hud.shadow_note.text]):
		return _finish()
	var next := str(levels[levels.find(medium_button) + 1].name)
	_key(KEY_RIGHT)
	_key(KEY_ENTER)
	await process_frame
	if not _require((hud.shadow_levels.get_node(next) as Button).button_pressed and not medium_button.button_pressed and main.shadows.current == next and _sun_matches(main.get_node("Sun"), main.shadows.settings_of(next)), "Right then Enter on the options screen must put on %s at once (on: %s)." % [next, main.shadows.current]):
		return _finish()
	hud.options_back_button.pressed.emit()
	await process_frame
	if not _require(not hud.options_visible() and hud.pause_panel.visible and hud.options_button.has_focus(), "Back on the options screen must go back to the pause menu, Options focused."):
		return _finish()
	main.free()
	# A restart keeps the choice; choosing again replaces it.
	main = _make_main()
	if not _require(main.shadows.current == next and _sun_matches(main.get_node("Sun"), main.shadows.settings_of(next)) and (main.hud.shadow_levels.get_node(next) as Button).button_pressed, "After a restart the game must put %s on again, as chosen (it put on %s)." % [next, main.shadows.current]):
		return _finish()
	(main.hud.shadow_levels.get_node("off") as Button).button_pressed = true
	main.free()
	main = _make_main()
	if not _require(main.shadows.current == "off" and not (main.get_node("Sun") as DirectionalLight3D).shadow_enabled, "A level chosen again must replace the kept one (after choosing Off and a restart: %s)." % main.shadows.current):
		return _finish()
	main.free()
	# The capture harness's opt-out: the default, whatever is kept.
	main = _make_main(false)
	if not _require(main.shadows.current == ShadowQuality.default_id(), "With use_saved_settings off the game must put on the default, not the kept %s." % main.shadows.current):
		return _finish()
	main.free()
	# The web's levels (Off alone) leave the pause menu without Options.
	var web_hud := (load("res://game/scenes/ui/hud.tscn") as PackedScene).instantiate() as GameHUD
	root.add_child(web_hud)
	web_hud.set_shadow_levels(ShadowQuality.LEVELS.filter(func(level: Dictionary) -> bool: return level.web), "off")
	var web_options := web_hud.options_button.visible
	web_hud.free()
	if not _require(not web_options, "With the web's one level (Off) the pause menu must not show Options."):
		return _finish()
	# Quiet fallbacks: an unknown kept level, a missing file, a file that can't be written.
	var file := ConfigFile.new()
	file.set_value(ShadowQuality.SECTION, ShadowQuality.KEY, "blinding")
	file.save(_settings_file)
	var unknown := ShadowQuality.saved_id()
	DirAccess.remove_absolute(_settings_file)
	var missing := ShadowQuality.saved_id()
	ShadowQuality.settings_path = "user://no-such-folder-%d/settings.cfg" % OS.get_process_id()
	ShadowQuality.save_id("high")
	var unwritten := ShadowQuality.saved_id()
	ShadowQuality.settings_path = _settings_file
	if not _require([unknown, missing, unwritten] == [ShadowQuality.default_id(), ShadowQuality.default_id(), ShadowQuality.default_id()], "An unknown kept level, a missing file and an unwritable one must all give the default, quietly (gave %s, %s, %s)." % [unknown, missing, unwritten]):
		return _finish()
	print("PASS: shadow options: with no kept choice the game puts on Medium, main.tscn's sun and project.godot's shadow map and filter (the game as it was); each level puts on what it claims (%s); the pause menu's Options (between Controls and Credits) opens the levels with the one on pressed, Right and Enter put on %s at once and Back returns; the choice survives a restart and a new one replaces it; the capture harness gets the default; the web's Off alone leaves no Options; unknown, missing and unwritable settings fall back quietly" % ["; ".join(applied), next])
	_finish()


## The main scene made and readied (its shadow level put on), before its world
## loads: freed in the same frame, the world never does.
func _make_main(use_saved := true) -> GameMain:
	var main := (load(MAIN_SCENE) as PackedScene).instantiate() as GameMain
	main.capture_mouse_on_ready = false
	main.use_saved_settings = use_saved
	root.add_child(main)
	return main


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
	if not _require(own.is_empty(), "Medium must set nothing of its own (it is the game as it was), but sets %s." % [own]) \
	or not _require(ShadowQuality.default_id() == "medium" and ShadowQuality.offered().size() == ShadowQuality.LEVELS.size(), "On desktop the default must be Medium, with every level offered.") \
	or not _require(web == ["off"], "The web must offer Off, its default, alone (its Compatibility renderer brightened sunlit surfaces with sun shadows on), not %s." % [web]):
		return false
	var sun := _scene_sun()
	var levels := ShadowQuality.new(sun)
	var off := levels.settings_of("off")
	var low := levels.settings_of("low")
	var medium := levels.settings_of("medium")
	sun.free()
	var high := levels.settings_of("high")
	if not _require(high.enabled and int(high.atlas) > int(medium.atlas) and int(high.filter) > int(medium.filter), "High must be finer than Medium: a bigger shadow map and a finer filter."):
		return false
	return _require(not off.enabled, "Off must turn the sun's shadows off.") \
		and _require(low.enabled and int(low.atlas) < int(medium.atlas) and float(low.max_distance) < float(medium.max_distance), "Low must be lighter than Medium: a smaller shadow map over a shorter range.")


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
	DirAccess.remove_absolute(_settings_file)
	if _failure != "":
		push_error("FAIL: " + _failure)
		print("FAIL: " + _failure)
		quit(1)
	else:
		quit(0)
