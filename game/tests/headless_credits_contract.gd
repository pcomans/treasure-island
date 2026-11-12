extends SceneTree
## The credits (owner, 2026-11-12: "list the sources that we draw from that we need
## to acknowledge ... show that as a menu item in the menu"), headless, on the HUD
## alone (the pause and Resume in the loaded game are headless_gameplay_contract.gd's
## and, on a phone, headless_touch_drive.gd's):
##   - game/resources/ui/credits.json, the only list, reads and is complete: every
##     folder under game/ and generated/ that holds a licence or provenance file,
##     fonts, sounds, videos or 3D models, or sits directly in a vendor, addons or
##     third_party folder, is credited by an entry or marked as the project's own
##     work, and every folder it names is there;
##   - every licence text an entry shows ships with the game: each export preset's
##     include_filter lists it;
##   - the pause menu's Credits button, between Controls and Exit, opens the credits
##     screen in the menu's place. It shows every entry (title, credit, licence,
##     link, use, licence text) and, behind Godot Engine licences, the engine's own
##     licence, every component's copyright holders and every licence text the
##     engine gives; Back goes back a step at a time, to the pause menu;
##   - keys alone work it: Back has the focus, Left reaches Godot Engine licences and
##     Enter opens it; the arrows, Page Up and Down, Home and End scroll;
##   - the wheel and a finger's drag scroll each view, the finger one for one and
##     the container's own touch drag kept out (hud.gd);
##   - the loading screen shows the credits marked for it;
##   - at the desktop frame and in a touch screen's 720 px layout on an iPhone held
##     upright and sideways, the screen lies inside the page, no line runs past its
##     text, and on touch its buttons are big enough for a thumb.
## The first failure stops the run.

const HUD_SCENE := "res://game/scenes/ui/hud.tscn"
const PRESETS_PATH := "res://export_presets.cfg"
## Text files whose name starts with one of these hold a licence or provenance note.
const LICENCE_NAMES := ["LICENSE", "LICENCE", "COPYING", "NOTICE", "PROVENANCE", "ATTRIBUTION", "AUTHORS", "CREDITS", "OFL"]
const TEXT_EXTENSIONS := ["", "txt", "md"]
## Fonts, sounds, videos and 3D models: assets that come with terms of their own.
const ASSET_EXTENSIONS := ["ttf", "otf", "woff", "woff2", "fnt", "wav", "ogg", "mp3", "flac", "opus", "ogv", "webm", "mp4", "glb", "gltf", "fbx", "obj", "blend", "dae", "vox"]
## A folder directly in one of these holds someone else's code or assets.
const THIRD_PARTY_PARENTS := ["vendor", "addons", "third_party", "thirdparty"]
const SCANNED_ROOTS := ["res://game", "res://generated"]
## The desktop frame, and an iPhone's Safari page held upright and sideways in the
## 720 px layout main.gd gives a touch browser (as headless_touch_drive.gd).
const DESKTOP := Vector2i(1440, 900)
const TOUCH_LAYOUT := Vector2i(720, 720)
const PHONE := {"upright": Vector2i(1206, 2148), "sideways": Vector2i(2622, 1110)}
const THUMB_PX := 64.0
const DRAG_PX := 180.0

var _failure := ""
var _hud: GameHUD
## Runs of whitespace: the screen reflows hard-wrapped licence paragraphs, so a
## licence text is compared word for word (_squashed).
var _whitespace := RegEx.create_from_string("\\s+")
## The views that were long enough to scroll, and so had their scrolling checked.
var _scrolled: Array[String] = []


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func() -> void: _finish("The credits contract timed out."))
	call_deferred("_run")


func _run() -> void:
	var data := _read_credits()
	if data.is_empty():
		return _finish()
	var entries: Array = data.entries
	var declared := _check_folders(data)
	if declared.is_empty() or not _check_licence_files_ship(entries):
		return _finish()
	root.content_scale_size = DESKTOP
	root.size = DESKTOP
	_hud = (load(HUD_SCENE) as PackedScene).instantiate() as GameHUD
	root.add_child(_hud)
	await _frames(2)
	if not _check_loading_line(entries) or not await _check_screen(entries, "desktop"):
		return _finish()
	_hud.set_touch_instructions()
	root.content_scale_size = TOUCH_LAYOUT
	for shape: String in PHONE:
		root.size = PHONE[shape]
		await _frames(2)
		var page := _hud.get_viewport_rect().size
		if not _require((page.y > page.x) == (shape == "upright") and is_equal_approx(minf(page.x, page.y), float(TOUCH_LAYOUT.x)), "The %s page laid out at %s, not %s with its short side %d px." % [shape, page, shape, TOUCH_LAYOUT.x]):
			return _finish()
		if not await _check_screen(entries, shape):
			return _finish()
	if not _require(_scrolled.has("upright: the list") and _scrolled.has("desktop: the engine's licences"), "Too little to scroll: the list must outrun an upright phone's view and the engine's licences the desktop's (scrolled: %s)." % [_scrolled]):
		return _finish()
	print("PASS: credits: %s lists %d entries and covers %d folders (%s); its licence texts ship in every export; the pause menu's Credits (between Controls and Exit) opens them in its place and Back returns a step at a time; Godot Engine licences shows the engine's licence, %d components and %d licence texts; keys alone work it; keys, the wheel and a finger scroll it (%s); the loading screen shows OSM's credit; it fits the desktop frame and an iPhone upright and sideways, thumb-sized on touch" % [GameHUD.CREDITS_PATH, entries.size(), declared.size(), ", ".join(PackedStringArray(declared.keys())), Engine.get_copyright_info().size(), Engine.get_license_info().size(), ", ".join(PackedStringArray(_scrolled))])
	_finish()


## The credits file, with every entry's and own-work item's fields as hud.gd and
## this check read them; {} after failing.
func _read_credits() -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(GameHUD.CREDITS_PATH))
	if not _require(data is Dictionary and (data as Dictionary).get("entries") is Array and (data as Dictionary).get("own_work") is Array, "%s must parse, with entries and own_work arrays." % GameHUD.CREDITS_PATH):
		return {}
	var ids := {}
	var engines := 0
	for entry: Variant in data.entries:
		var fields := entry as Dictionary if entry is Dictionary else {}
		var id := str(fields.get("id", ""))
		var problem := ""
		if id.is_empty() or ids.has(id):
			problem = "needs an id of its own"
		for key: String in ["title", "credit", "used_for"]:
			if not fields.get(key) is String or str(fields.get(key)).strip_edges().is_empty():
				problem = "needs a %s" % key
		for key: String in ["licence", "url"]:
			if not fields.get(key) is String:
				problem = "needs a %s (\"\" if none)" % key
		if not fields.get("required") is bool:
			problem = "must say whether the acknowledgement is required (true) or a courtesy (false)"
		if not str(fields.get("url", "")).is_empty() and not str(fields.get("url")).begins_with("https://"):
			problem = "needs an https:// url"
		if fields.has("folders") and not (fields.folders is Array and (fields.folders as Array).all(func(folder: Variant) -> bool: return folder is String and not str(folder).is_empty())):
			problem = "lists folders that are not paths"
		if not _require(problem.is_empty(), "%s entry %s %s." % [GameHUD.CREDITS_PATH, id if not id.is_empty() else str(entry), problem]):
			return {}
		ids[id] = true
		if bool(fields.get("engine", false)):
			engines += 1
	if not _require(engines == 1, "%s must have exactly one engine entry (Godot Engine), not %d." % [GameHUD.CREDITS_PATH, engines]):
		return {}
	for item: Variant in data.own_work:
		if not _require(item is Dictionary and not str((item as Dictionary).get("folder", "")).is_empty() and not str((item as Dictionary).get("made_by", "")).is_empty(), "%s own_work items need a folder and what made it: %s" % [GameHUD.CREDITS_PATH, item]):
			return {}
	return data


## Every folder that needs a credit decision is credited or marked own work, and
## every folder the file names is there. Returns the declared folders (folder ->
## the entry or own work), or {} after failing.
func _check_folders(data: Dictionary) -> Dictionary:
	var declared := {}
	for entry: Dictionary in data.entries:
		for folder: String in entry.get("folders", []):
			declared[folder] = str(entry.id)
	for item: Dictionary in data.own_work:
		declared[str(item.folder)] = "own work"
	for folder: String in declared:
		if not _require(DirAccess.dir_exists_absolute("res://" + folder), "%s names %s, which is gone: drop it (credits list what ships)." % [GameHUD.CREDITS_PATH, folder]):
			return {}
	var needed := {}
	for root_path: String in SCANNED_ROOTS:
		_scan(root_path, needed)
	for folder: String in needed:
		if not _require(declared.has(folder), "%s %s, but %s neither credits it (an entry's folders) nor marks it as this project's own work (own_work)." % [folder, needed[folder], GameHUD.CREDITS_PATH]):
			return {}
	return declared


## Adds every folder under dir_path that needs a credit decision, with the reason.
func _scan(dir_path: String, needed: Dictionary) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	var folder := dir_path.trim_prefix("res://")
	if folder.get_base_dir().get_file() in THIRD_PARTY_PARENTS:
		needed[folder] = "sits in %s/" % folder.get_base_dir()
	for file: String in dir.get_files():
		var extension := file.get_extension().to_lower()
		var stem := file.get_basename().to_upper()
		if extension in TEXT_EXTENSIONS and LICENCE_NAMES.any(func(name: String) -> bool: return stem.begins_with(name)):
			needed[folder] = "holds a licence or provenance note, %s" % file
		elif extension in ASSET_EXTENSIONS:
			needed[folder] = "holds a font, sound, video or 3D model, %s" % file
	for sub: String in dir.get_directories():
		_scan(dir_path.path_join(sub), needed)


## Each licence text an entry shows is there, and every export preset ships it.
func _check_licence_files_ship(entries: Array) -> bool:
	var presets := ConfigFile.new()
	if not _require(presets.load(PRESETS_PATH) == OK, "%s did not load." % PRESETS_PATH):
		return false
	var preset_sections := Array(presets.get_sections()).filter(func(section: String) -> bool: return section.begins_with("preset.") and not section.ends_with(".options"))
	if not _require(not preset_sections.is_empty(), "%s has no export presets." % PRESETS_PATH):
		return false
	for entry: Dictionary in entries:
		var path := str(entry.get("licence_file", ""))
		if path.is_empty():
			continue
		if not _require(not FileAccess.get_file_as_string(path).strip_edges().is_empty(), "%s's licence text %s is missing or empty." % [entry.id, path]):
			return false
		var relative := path.trim_prefix("res://")
		for section: String in preset_sections:
			var filters := str(presets.get_value(section, "include_filter", "")).split(",", false)
			if not _require(Array(filters).any(func(filter: String) -> bool: return relative.match(filter.strip_edges())), "%s's licence text %s would not ship: export preset %s (%s) must list it in include_filter." % [entry.id, relative, section, presets.get_value(section, "name", "")]):
				return false
	return true


## The loading screen's credit line holds every credit marked loading_screen, with
## its link, and lies inside the screen.
func _check_loading_line(entries: Array) -> bool:
	var line := _hud.load_credit
	var screen := Rect2(Vector2.ZERO, _hud.get_viewport_rect().size)
	for entry: Dictionary in entries:
		if bool(entry.get("loading_screen", false)) and not _require(line.text.contains(str(entry.credit)) and line.text.contains(str(entry.url).trim_prefix("https://")), "The loading screen must show %s's credit and link, not \"%s\"." % [entry.id, line.text]):
			return false
	return _require(not line.text.is_empty() and line.is_visible_in_tree() and screen.encloses(line.get_global_rect()), "The loading screen's credit line \"%s\" must show inside the screen (at %s)." % [line.text, line.get_global_rect()])


## The pause menu's Credits at this window shape: the menu's order, the screen in
## its place with every entry, the engine's licences, the keys, the scrolling, the
## fit, and Back to the pause menu.
func _check_screen(entries: Array, shape: String) -> bool:
	var hud := _hud
	var touch := shape != "desktop"
	hud.set_paused(true)
	await _frames(1)
	var order := PackedStringArray()
	for child: Node in hud.pause_box.get_node("PauseLayout").get_children():
		if child is Button:
			order.append(child.name)
	if not _require(order == PackedStringArray(["ResumeButton", "ControlsButton", "CreditsButton", "ExitButton"]) and hud.credits_button.text == "Credits" and hud.pause_panel.visible, "%s: the pause menu must read Resume, Controls, Credits, Exit (it has %s)." % [shape, order]):
		return false
	hud.credits_button.pressed.emit()
	await _frames(2)
	if not _require(hud.credits_visible() and not hud.pause_panel.visible and hud.credits_list.visible and not hud.credits_engine.visible and hud.credits_title.text == "Credits", "%s: Credits must show the credits list in place of the pause menu." % shape) \
	or not _require(hud.credits_back_button.has_focus(), "%s: Back must have the focus when Credits opens, as on the controls screen." % shape):
		return false
	# Keys alone: Left takes the focus from Back to Godot Engine licences, and Enter
	# opens it (on touch the button opens it, as a tap does).
	if touch:
		hud.credits_engine_button.pressed.emit()
	else:
		_key(KEY_LEFT)
		if not _require(hud.credits_engine_button.has_focus(), "%s: Left must move the focus from Back to Godot Engine licences." % shape):
			return false
		_key(KEY_ENTER)
	await _frames(2)
	if not _require(hud.credits_engine.visible and not hud.credits_list.visible and not hud.credits_engine_button.visible and hud.credits_title.text == "Godot Engine licences" and hud.credits_back_button.has_focus(), "%s: Godot Engine licences must show the engine's licences in the list's place, Back focused." % shape):
		return false
	var engine := _texts(hud.credits_engine_text)
	var engine_words := _squashed(engine)
	if not _require(engine_words.contains(_squashed(Engine.get_license_text())), "%s: the engine's licences do not show Engine.get_license_text()." % shape):
		return false
	for component: Dictionary in Engine.get_copyright_info():
		if not _require(engine.contains(str(component.name)), "%s: the engine's licences do not name the component %s." % [shape, component.name]):
			return false
		for part: Dictionary in component.parts:
			for holder: String in part.copyright:
				if not _require(engine.contains("© " + holder), "%s: the engine's licences do not show %s's holder %s." % [shape, component.name, holder]):
					return false
	var licences := Engine.get_license_info()
	for licence: String in licences:
		if not _require(engine.contains(licence) and engine_words.contains(_squashed(str(licences[licence]))), "%s: the engine's licences do not show the %s licence text." % [shape, licence]):
			return false
	if not _check_fit(shape, hud.credits_engine, touch) or not await _check_scrolling(hud.credits_engine, "%s: the engine's licences" % shape):
		return false
	# Back a step at a time: to the list, then to the pause menu.
	hud.credits_back_button.pressed.emit()
	await _frames(2)
	if not _require(hud.credits_visible() and hud.credits_list.visible and not hud.credits_engine.visible and hud.credits_engine_button.visible and hud.credits_title.text == "Credits", "%s: Back on the engine's licences must go back to the credits list." % shape):
		return false
	var shown := _texts(hud.credits_entries)
	for entry: Dictionary in entries:
		for key: String in ["title", "credit", "licence", "url", "used_for"]:
			# Links show without their https://.
			var text := str(entry[key]).trim_prefix("https://")
			if not text.is_empty() and not _require(shown.contains(text), "%s: the credits do not show %s's %s \"%s\"." % [shape, entry.id, key, text]):
				return false
		var licence_file := str(entry.get("licence_file", ""))
		if not licence_file.is_empty() and not _require(_squashed(shown).contains(_squashed(FileAccess.get_file_as_string(licence_file))), "%s: the credits do not show %s's licence text %s." % [shape, entry.id, licence_file]):
			return false
	if not _check_fit(shape, hud.credits_list, touch) or not await _check_scrolling(hud.credits_list, "%s: the list" % shape):
		return false
	hud.credits_back_button.pressed.emit()
	await _frames(1)
	if not _require(not hud.credits_visible() and hud.pause_panel.visible and hud.credits_button.has_focus(), "%s: Back on the credits list must go back to the pause menu, Credits focused." % shape):
		return false
	# Paused again while it is open (a lost focus) it stays, the menu hidden; play
	# hides it.
	hud.credits_button.pressed.emit()
	hud.set_paused(true)
	if not _require(hud.credits_visible() and not hud.pause_panel.visible, "%s: a pause while the credits are open must keep them, the pause menu hidden." % shape):
		return false
	hud.set_paused(false)
	return _require(not hud.credits_visible() and not hud.pause_panel.visible, "%s: play must hide the credits." % shape)


## The panel inside the page, no line past its view's text, and on touch the
## buttons thumb-sized and apart.
func _check_fit(shape: String, view: ScrollContainer, touch: bool) -> bool:
	var page := Rect2(Vector2.ZERO, _hud.get_viewport_rect().size)
	var panel := _hud.credits_panel.get_global_rect()
	if not _require(page.grow(0.5).encloses(panel), "%s: the credits panel %s runs off the page %s." % [shape, panel, page]):
		return false
	var text_right := (view.get_child(0) as Control).get_global_rect().end.x
	for node: Node in view.find_children("*", "Label", true, false):
		var label := node as Label
		if not _require(label.get_global_rect().end.x <= text_right + 0.5 and label.get_global_rect().end.x <= view.get_global_rect().end.x + 0.5, "%s: the line \"%s\" runs past the credits text (%s past %s)." % [shape, label.text.left(60), label.get_global_rect().end.x, text_right]):
			return false
	var buttons := _hud.credits_layout.get_node("Buttons").get_children().filter(func(button: Node) -> bool: return (button as Control).is_visible_in_tree())
	for button: Button in buttons:
		if not _require(panel.encloses(button.get_global_rect()) and (not touch or button.size.y >= THUMB_PX), "%s: the button %s at %s must lie in the panel%s." % [shape, button.text, button.get_global_rect(), " and be at least %d px tall" % THUMB_PX if touch else ""]):
			return false
	return _require(buttons.size() < 2 or not (buttons[0] as Control).get_global_rect().intersects((buttons[1] as Control).get_global_rect()), "%s: the credits buttons overlap." % shape)


## When the view is longer than it shows: Down and Up a line, Page Down most of a
## page, End and Home to either end, the wheel, and a finger dragging up one for
## one (with the mouse events a touch screen makes from it, which must not move it
## again), while a finger starting on the scroll bar is left to the bar. A view
## that fits has nothing to scroll.
func _check_scrolling(view: ScrollContainer, label: String) -> bool:
	await _frames(2)
	var bar := view.get_v_scroll_bar()
	var end := bar.max_value - bar.page
	if end < 1.0:
		return true
	view.scroll_vertical = 0
	var checks := [
		[KEY_DOWN, GameHUD.CREDITS_LINE_PX, "Down"],
		[KEY_PAGEDOWN, GameHUD.CREDITS_LINE_PX + minf(bar.page * GameHUD.CREDITS_PAGE_SHARE, end - GameHUD.CREDITS_LINE_PX), "Page Down"],
		[KEY_END, end, "End"],
		[KEY_UP, end - GameHUD.CREDITS_LINE_PX, "Up"],
		[KEY_HOME, 0.0, "Home"],
	]
	for check: Array in checks:
		_key(check[0])
		if not _require(absf(bar.value - float(check[1])) <= 1.0, "%s: %s must scroll to %.0f px, not %.0f." % [label, check[2], check[1], bar.value]):
			return false
	var middle := view.get_global_rect().get_center()
	for pressed: bool in [true, false]:
		var wheel := InputEventMouseButton.new()
		wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
		wheel.factor = 1.0
		wheel.pressed = pressed
		wheel.position = middle
		root.push_input(wheel, true)
	if not _require(bar.value > 0.0, "%s: the wheel did not scroll it." % label):
		return false
	view.scroll_vertical = 0
	var drag := minf(DRAG_PX, end)
	_finger_drag(1, middle + Vector2(0.0, drag * 0.5), -drag)
	await _frames(1)
	if not _require(absf(bar.value - drag) <= 1.0, "%s: a finger dragging up %.0f px must scroll it %.0f px, not %.0f." % [label, drag, drag, bar.value]):
		return false
	var on_bar := bar.get_global_rect().get_center()
	var before := bar.value
	_finger_drag(2, on_bar, drag * 0.5, false)
	await _frames(1)
	if not _require(is_equal_approx(bar.value, before), "%s: a finger starting on the scroll bar must leave the scrolling to the bar (it moved %.0f px)." % [label, bar.value - before]):
		return false
	_scrolled.append(label)
	view.scroll_vertical = 0
	return true


## A finger down at `from`, dragged `by` px down (negative: up) in four moves and
## lifted, through the window as a touch screen sends it: with emulate, also the
## left-button press, moves and release it makes from the finger.
func _finger_drag(index: int, from: Vector2, by: float, emulate := true) -> void:
	var at := from
	var touch := InputEventScreenTouch.new()
	touch.index = index
	touch.position = at
	touch.pressed = true
	root.push_input(touch, true)
	if emulate:
		_emulated_button(at, true)
	for _move in 4:
		var drag := InputEventScreenDrag.new()
		drag.index = index
		drag.relative = Vector2(0.0, by / 4.0)
		at += drag.relative
		drag.position = at
		root.push_input(drag, true)
		if emulate:
			var motion := InputEventMouseMotion.new()
			motion.device = InputEvent.DEVICE_ID_EMULATION
			motion.button_mask = MOUSE_BUTTON_MASK_LEFT
			motion.position = at
			motion.relative = drag.relative
			root.push_input(motion, true)
	touch = touch.duplicate() as InputEventScreenTouch
	touch.position = at
	touch.pressed = false
	root.push_input(touch, true)
	if emulate:
		_emulated_button(at, false)


func _emulated_button(at: Vector2, pressed: bool) -> void:
	var button := InputEventMouseButton.new()
	button.device = InputEvent.DEVICE_ID_EMULATION
	button.button_index = MOUSE_BUTTON_LEFT
	button.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	button.position = at
	button.pressed = pressed
	root.push_input(button, true)


## The text's words, each run of whitespace one space.
func _squashed(text: String) -> String:
	return _whitespace.sub(text, " ", true).strip_edges()


## Every line the labels under `node` show.
func _texts(node: Node) -> String:
	var lines := PackedStringArray()
	for label: Node in node.find_children("*", "Label", true, false):
		lines.append((label as Label).text)
	return "\n".join(lines)


## A tap of a key, delivered as the window delivers it.
func _key(keycode: Key) -> void:
	for pressed: bool in [true, false]:
		var key := InputEventKey.new()
		key.keycode = keycode
		key.physical_keycode = keycode
		key.pressed = pressed
		root.push_input(key)


func _frames(count: int) -> void:
	for _frame in count:
		await process_frame


func _require(condition: bool, message: String) -> bool:
	if not condition and _failure == "":
		_failure = message
	return condition


func _finish(timeout_message := "") -> void:
	if timeout_message != "" and _failure == "":
		_failure = timeout_message
	if _failure != "":
		push_error("FAIL: " + _failure)
		print("FAIL: " + _failure)
		quit(1)
	else:
		quit(0)
