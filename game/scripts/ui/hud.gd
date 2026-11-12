class_name GameHUD
extends Control

signal resume_requested
signal exit_requested

## The controls screen: headings in this colour, keys and buttons in the other.
const CONTROLS_HEADING_COLOR := Color(0.62, 0.85, 1.0)
const CONTROLS_KEY_COLOR := Color(1.0, 0.86, 0.55)
## The sources the game acknowledges: the only list, which the credits screen and
## the loading screen's credit line read (its notes describe the entries).
const CREDITS_PATH := "res://game/resources/ui/credits.json"
## The credits screen: titles and licences in the controls screen's colours, notes
## and licence texts in this one.
const CREDITS_NOTE_COLOR := Color(0.8, 0.84, 0.88)
## How far an arrow key scrolls the credits (px), and the share of the view a page
## key scrolls.
const CREDITS_LINE_PX := 40.0
const CREDITS_PAGE_SHARE := 0.9
## The credits panel keeps this far from the screen's edges (px) at any window
## shape, and its text at most this wide.
const CREDITS_MARGIN_PX := 24.0
const CREDITS_MAX_WIDTH_PX := 860.0
## On a touch screen the credits' text is this much larger (px), so on a phone it
## is no smaller than the controls screen's. Licence texts are in the fine print.
const CREDITS_TOUCH_EXTRA_PX := 2
const CREDITS_FINE_PRINT_PX := 14
## The Licences' headings: a section's, and each engine licence text's, the gap
## above them included (px).
const CREDITS_SECTION_PX := 48.0
const CREDITS_LICENCE_HEADING_PX := 44.0
## In a licence text, a line at least this share of its paragraph's longest was
## wrapped at a fixed width (_reflowed).
const REFLOW_FULL_SHARE := 0.6

@onready var feedback_panel: PanelContainer = $FeedbackPanel
@onready var feedback_text: Label = $FeedbackPanel/FeedbackText
## The pause menu: like the controls screen, a solid panel over the dimmed game.
@onready var pause_panel: Control = $PausePanel
@onready var pause_box: PanelContainer = $PausePanel/Center/Box
@onready var resume_button: Button = $PausePanel/Center/Box/PauseLayout/ResumeButton
@onready var controls_button: Button = $PausePanel/Center/Box/PauseLayout/ControlsButton
@onready var credits_button: Button = $PausePanel/Center/Box/PauseLayout/CreditsButton
@onready var exit_button: Button = $PausePanel/Center/Box/PauseLayout/ExitButton
## The controls screen, opened from the pause menu or the loading screen: a
## solid panel over the dimmed game.
@onready var controls_screen: Control = $ControlsScreen
@onready var controls_sections: VBoxContainer = $ControlsScreen/Center/ControlsPanel/ControlsLayout/Sections
@onready var back_button: Button = $ControlsScreen/Center/ControlsPanel/ControlsLayout/BackButton
## The credits screen, opened from the pause menu: the list in CREDITS_PATH and,
## behind its Licences button, the licence texts that ship with the game and the
## engine's own licence and notices. A solid panel over the dimmed game, like the
## controls screen.
@onready var credits_screen: Control = $CreditsScreen
@onready var credits_panel: PanelContainer = $CreditsScreen/Center/CreditsPanel
@onready var credits_layout: VBoxContainer = $CreditsScreen/Center/CreditsPanel/CreditsLayout
@onready var credits_title: Label = $CreditsScreen/Center/CreditsPanel/CreditsLayout/Title
@onready var credits_list: ScrollContainer = $CreditsScreen/Center/CreditsPanel/CreditsLayout/ListScroll
@onready var credits_entries: VBoxContainer = $CreditsScreen/Center/CreditsPanel/CreditsLayout/ListScroll/Entries
@onready var credits_licences: ScrollContainer = $CreditsScreen/Center/CreditsPanel/CreditsLayout/LicencesScroll
@onready var credits_licence_text: VBoxContainer = $CreditsScreen/Center/CreditsPanel/CreditsLayout/LicencesScroll/LicenceText
@onready var credits_licences_button: Button = $CreditsScreen/Center/CreditsPanel/CreditsLayout/Buttons/LicencesButton
@onready var credits_back_button: Button = $CreditsScreen/Center/CreditsPanel/CreditsLayout/Buttons/BackButton
@onready var load_controls_button: Button = $LoadPanel/LoadLayout/LoadStack/ControlsButton
## The loading screen's credit line: the credits marked loading_screen (OSM's,
## which OSMF's attribution guidelines ask a game to show at startup).
@onready var load_credit: Label = $LoadPanel/LoadLayout/LoadStack/LoadCredit
@onready var load_panel: PanelContainer = $LoadPanel
@onready var load_text: Label = $LoadPanel/LoadLayout/LoadStack/LoadText
## The loading screen's treasure chest, the app icon (game/resources/ui/PROVENANCE.md).
@onready var load_icon: TextureRect = $LoadPanel/LoadLayout/LoadStack/LoadIcon
@onready var debug_panel: PanelContainer = $DebugPanel
@onready var debug_text: Label = $DebugPanel/DebugText
@onready var prompt_panel: PanelContainer = $PromptPanel
@onready var prompt_text: Label = $PromptPanel/PromptText

var _feedback_seconds := 0.0
var _evidence: RuntimeEvidence
var _capture_hint: Button
var _paused := false
var _touch := false
## The finger scrolling a credits view, or -1 (_on_credits_scroll_input).
var _credits_finger := -1
## The licence texts the list's entries ship (their licence_file), as [title, text],
## for the Licences view.
var _licence_files: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	exit_button.pressed.connect(func() -> void: exit_requested.emit())
	controls_button.pressed.connect(show_controls)
	load_controls_button.pressed.connect(show_controls)
	back_button.pressed.connect(hide_controls)
	credits_button.pressed.connect(show_credits)
	credits_licences_button.pressed.connect(show_licences)
	credits_back_button.pressed.connect(credits_back)
	for scroll: ScrollContainer in [credits_list, credits_licences]:
		scroll.gui_input.connect(_on_credits_scroll_input.bind(scroll))
	_fill_controls()
	_fill_credits()
	feedback_panel.hide()
	pause_panel.hide()
	controls_screen.hide()
	credits_screen.hide()
	debug_panel.hide()
	prompt_panel.hide()
	resized.connect(_fit_load_icon)
	_fit_load_icon()
	resized.connect(_fit_credits)
	_fit_credits()


## The chest on the loading screen is a quarter of the screen's shorter side, at
## any window shape; the load panel centres it above the text.
func _fit_load_icon() -> void:
	var side := roundf(0.25 * minf(size.x, size.y))
	load_icon.custom_minimum_size = Vector2(side, side)


func _process(delta: float) -> void:
	if _feedback_seconds > 0.0:
		_feedback_seconds -= delta
		if _feedback_seconds <= 0.0:
			feedback_panel.hide()
	if debug_panel.visible and _evidence != null:
		debug_text.text = _evidence.debug_text()


func bind_evidence(evidence: RuntimeEvidence) -> void:
	_evidence = evidence


func show_loading(message: String = "Validating complete Treasure Island world…") -> void:
	load_text.text = message
	load_panel.show()


func update_load_progress(loaded: int, total: int) -> void:
	load_text.text = "Building complete world… %d / %d" % [loaded, total]


## Play starts. A controls screen opened from the loading screen stays open
## (main.gd starts the game paused behind it).
func show_world_ready() -> void:
	load_panel.hide()


func show_load_error(code: String, message: String, source_keys: Array) -> void:
	var source_suffix := ""
	if not source_keys.is_empty():
		source_suffix = "\nSources: %s" % ", ".join(source_keys)
	load_text.text = "WORLD LOAD BLOCKED\n[%s] %s%s\n\nNo partial world was started." % [code, message, source_suffix]
	load_panel.show()


## A short message near the bottom of the screen, tinted green or red. (No tick or
## cross: the web build's font has neither.)
func show_feedback(message: String, success: bool) -> void:
	feedback_text.text = message
	feedback_text.modulate = Color("d9ffe9") if success else Color("ffe1d9")
	feedback_panel.show()
	_feedback_seconds = 2.0


## A short key hint near the bottom of the screen ("F  Drive" beside a car);
## "" hides it. The pause hides it too, until play goes on. Its label starts
## empty (hud.tscn), so play goes on with no prompt until one is set; a touch
## screen never sets one (its use button shows instead, touch_controls.gd).
func set_prompt(text: String) -> void:
	prompt_text.text = text
	prompt_panel.visible = not text.is_empty() and not _paused


## The pause menu, in place of play's prompt. A controls screen opened from the
## loading screen stays over the pause (main.gd), and the menu shows when it closes;
## so does an open credits screen when the game pauses again (a lost focus).
func set_paused(paused: bool) -> void:
	_paused = paused
	pause_panel.visible = paused and not controls_screen.visible and not credits_screen.visible
	if not paused:
		controls_screen.hide()
		if credits_licences.visible:
			_show_credits_view(false)
		credits_screen.hide()
	prompt_panel.visible = not paused and not prompt_text.text.is_empty()
	if pause_panel.visible:
		resume_button.grab_focus()


## Shows the controls screen in place of the pause menu (or over the loading
## screen); Back, or Esc (main.gd), returns.
func show_controls() -> void:
	pause_panel.hide()
	controls_screen.show()
	back_button.grab_focus()


func hide_controls() -> void:
	controls_screen.hide()
	if _paused:
		pause_panel.show()
		controls_button.grab_focus()


func controls_visible() -> bool:
	return controls_screen.visible


## Shows the credits screen in place of the pause menu, at the top of its list.
## Back, or Esc (main.gd), goes back a step (credits_back).
func show_credits() -> void:
	pause_panel.hide()
	_show_credits_view(false)
	credits_screen.show()
	credits_back_button.grab_focus()


## The licence texts that ship with the game, then the engine's own licence and the
## software by other authors it includes with their licences, as the engine gives
## them (Godot's "Complying with licenses"), in place of the credits list.
func show_licences() -> void:
	_show_credits_view(true)
	credits_back_button.grab_focus()


## Back on the credits screen (its button, or Esc in main.gd): from the Licences to
## the list, and from the list to the pause menu.
func credits_back() -> void:
	if credits_licences.visible:
		_show_credits_view(false)
		credits_licences_button.grab_focus()
		return
	credits_screen.hide()
	if _paused:
		pause_panel.show()
		credits_button.grab_focus()


func credits_visible() -> bool:
	return credits_screen.visible


## The credits view shown, at its top: the Licences, built as they open, or the
## list, with the Licences' labels freed (about 240 labels and 80 KB of text).
func _show_credits_view(licences: bool) -> void:
	if licences and credits_licence_text.get_child_count() == 0:
		_fill_licences()
	elif not licences:
		_free_children(credits_licence_text)
	credits_list.visible = not licences
	credits_licences.visible = licences
	credits_licences_button.visible = not licences
	credits_title.text = "Licences" if licences else "Credits"
	_credits_finger = -1
	credits_scroll().scroll_vertical = 0


## The credits view on show (the list or the Licences).
func credits_scroll() -> ScrollContainer:
	return credits_licences if credits_licences.visible else credits_list


func _free_children(view: Control) -> void:
	for child: Node in view.get_children():
		view.remove_child(child)
		child.queue_free()


## Fills the credits list from CREDITS_PATH: each entry's title, its credit, its
## licence, its link on a line of its own, and what the game uses it for; keeps any
## licence text it ships for the Licences; and fills the loading screen's line from
## the entries marked loading_screen. Links show without their https://. Again on a
## touch screen (set_touch_instructions), larger, with the Licences built afresh.
func _fill_credits() -> void:
	_free_children(credits_entries)
	_free_children(credits_licence_text)
	_licence_files.clear()
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(CREDITS_PATH))
	var entries: Array = (data as Dictionary).get("entries", []) if data is Dictionary else []
	if entries.is_empty():
		push_error("The credits list %s could not be read." % CREDITS_PATH)
	var extra := CREDITS_TOUCH_EXTRA_PX if _touch else 0
	var loading := PackedStringArray()
	for entry: Dictionary in entries:
		var block := VBoxContainer.new()
		block.add_theme_constant_override("separation", 2)
		credits_entries.add_child(block)
		var link := str(entry.get("url", "")).trim_prefix("https://")
		_credits_label(block, str(entry.get("title", "")), 20 + extra, CONTROLS_HEADING_COLOR)
		_credits_label(block, str(entry.get("credit", "")), 18 + extra, Color.WHITE)
		for part: String in [str(entry.get("licence", "")), link]:
			if not part.is_empty():
				_credits_label(block, part, 16 + extra, CONTROLS_KEY_COLOR)
		_credits_label(block, str(entry.get("used_for", "")), 16 + extra, CREDITS_NOTE_COLOR)
		var licence_file := str(entry.get("licence_file", ""))
		if not licence_file.is_empty():
			var licence_text := FileAccess.get_file_as_string(licence_file).strip_edges()
			if licence_text.is_empty():
				push_error("The licence text %s is not in the game." % licence_file)
			_licence_files.append([str(entry.get("title", "")), licence_text])
		if bool(entry.get("loading_screen", false)):
			loading.append("%s  ·  %s" % [entry.get("credit", ""), link])
	load_credit.text = "\n".join(loading)


## The Licences: each licence text the list's entries ship, under the entry's
## title; then the engine's licence, each of its components with its copyright
## holders and licence, and the text of each of those licences, from the engine's
## own calls, so nothing here goes stale when the engine changes. Every licence's
## heading has a gap above it.
func _fill_licences() -> void:
	var extra := CREDITS_TOUCH_EXTRA_PX if _touch else 0
	var view := credits_licence_text
	for licence_file: Array in _licence_files:
		_credits_label(view, str(licence_file[0]), 20 + extra, CONTROLS_HEADING_COLOR).custom_minimum_size.y = CREDITS_SECTION_PX
		_credits_label(view, _reflowed(str(licence_file[1])), CREDITS_FINE_PRINT_PX + extra, CREDITS_NOTE_COLOR)
	_credits_label(view, "Godot Engine", 20 + extra, CONTROLS_HEADING_COLOR).custom_minimum_size.y = CREDITS_SECTION_PX
	_credits_label(view, "This game uses Godot Engine, available under the following licence:", 18 + extra, Color.WHITE)
	_credits_label(view, _reflowed(Engine.get_license_text().strip_edges()), 16 + extra, CREDITS_NOTE_COLOR)
	_credits_label(view, "Components and their copyright holders", 20 + extra, CONTROLS_HEADING_COLOR).custom_minimum_size.y = CREDITS_SECTION_PX
	for component: Dictionary in Engine.get_copyright_info():
		var lines := PackedStringArray()
		for part: Dictionary in component.parts:
			for holder: String in part.copyright:
				lines.append("© " + holder)
			lines.append("Licence: " + str(part.license))
		_credits_label(view, str(component.name), 17 + extra, CONTROLS_KEY_COLOR)
		_credits_label(view, "\n".join(lines), CREDITS_FINE_PRINT_PX + extra, CREDITS_NOTE_COLOR)
	_credits_label(view, "Licence texts", 20 + extra, CONTROLS_HEADING_COLOR).custom_minimum_size.y = CREDITS_SECTION_PX
	var licences := Engine.get_license_info()
	for licence: String in licences:
		_credits_label(view, licence, 17 + extra, CONTROLS_KEY_COLOR).custom_minimum_size.y = CREDITS_LICENCE_HEADING_PX + extra
		_credits_label(view, _reflowed(unescaped(str(licences[licence]).strip_edges())), CREDITS_FINE_PRINT_PX + extra, CREDITS_NOTE_COLOR)


## A licence text with a literal backslash-n (the engine's X11 text has one) made
## the line break it stands for.
static func unescaped(text: String) -> String:
	return text.replace("\\n", "\n")


## A licence text for a label that wraps at the screen's width: a line wrapped at
## a fixed width (at least REFLOW_FULL_SHARE of its paragraph's longest, and not
## ending a sentence) runs on into the next, so a narrow screen doesn't break every
## line twice; titles, copyright lines and list items keep their breaks. The words
## are the licence's own.
static func _reflowed(text: String) -> String:
	var paragraphs := PackedStringArray()
	var blank_lines := RegEx.create_from_string("\\n[ \\t]*(?:\\n[ \\t]*)+")
	for paragraph: String in blank_lines.sub(text.replace("\r\n", "\n"), "\n\n", true).split("\n\n"):
		var lines := paragraph.split("\n")
		var longest := 0
		for line: String in lines:
			longest = maxi(longest, line.strip_edges().length())
		var flowed := lines[0]
		for i in range(1, lines.size()):
			var previous := lines[i - 1].strip_edges()
			if previous.length() >= REFLOW_FULL_SHARE * longest and not previous.ends_with("."):
				flowed = flowed.rstrip(" \t") + " " + lines[i].strip_edges()
			else:
				flowed += "\n" + lines[i]
		paragraphs.append(flowed)
	return "\n\n".join(paragraphs)


func _credits_label(parent: Control, text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


## The credits panel fills the screen less CREDITS_MARGIN_PX all round, its text
## at most CREDITS_MAX_WIDTH_PX wide, at any window shape; its views scroll.
func _fit_credits() -> void:
	var chrome := credits_panel.get_theme_stylebox("panel").get_minimum_size()
	var gaps := 2.0 * float(credits_layout.get_theme_constant("separation"))
	var fixed := credits_title.get_combined_minimum_size().y + credits_back_button.get_combined_minimum_size().y + gaps
	var view := Vector2(minf(CREDITS_MAX_WIDTH_PX, size.x - 2.0 * CREDITS_MARGIN_PX - chrome.x), size.y - 2.0 * CREDITS_MARGIN_PX - chrome.y - fixed)
	view = view.max(Vector2.ZERO)
	credits_list.custom_minimum_size = view
	credits_licences.custom_minimum_size = view


## Keys scroll the credits screen's text: the arrows a line, Page Up and Page Down
## most of a page, Home and End to either end. Taken before the menus see them, so
## Left, Right and Tab still move between its buttons.
func _input(event: InputEvent) -> void:
	if not credits_screen.visible:
		return
	var bar := credits_scroll().get_v_scroll_bar()
	var step := 0.0
	if event.is_action_pressed("ui_down", true):
		step = CREDITS_LINE_PX
	elif event.is_action_pressed("ui_up", true):
		step = -CREDITS_LINE_PX
	elif event.is_action_pressed("ui_page_down", true):
		step = bar.page * CREDITS_PAGE_SHARE
	elif event.is_action_pressed("ui_page_up", true):
		step = -bar.page * CREDITS_PAGE_SHARE
	elif event.is_action_pressed("ui_end"):
		step = bar.max_value
	elif event.is_action_pressed("ui_home"):
		step = -bar.max_value
	else:
		return
	bar.value += step
	get_viewport().set_input_as_handled()


## A finger dragging a credits view scrolls it, one for one, with no fling. The
## container's own touch drag (Godot 4.7.2 scene/gui/scroll_container.cpp) times
## its fling by the process step and divides by it, and the pause makes that step
## 0 (main.gd's PauseClock), so the left-button presses and moves it reads, which
## a touch screen makes from the finger, stop here. The wheel goes on to it, and
## the scroll bar, its own child, takes its presses before they come here.
func _on_credits_scroll_input(event: InputEvent, scroll: ScrollContainer) -> void:
	var bar := scroll.get_v_scroll_bar()
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and not (bar.visible and bar.get_rect().has_point(touch.position)):
			_credits_finger = touch.index
		elif touch.index == _credits_finger:
			_credits_finger = -1
		scroll.accept_event()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _credits_finger:
			bar.value -= drag.relative.y
		scroll.accept_event()
	elif event is InputEventMouseMotion or (event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT):
		scroll.accept_event()


## Fills the controls screen with the bindings as they are: the keyboard and
## mouse, or the touch controls on a touch screen. One grid, so both columns
## line up under every heading.
func _fill_controls() -> void:
	for child: Node in controls_sections.get_children():
		controls_sections.remove_child(child)
		child.queue_free()
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 36)
	grid.add_theme_constant_override("v_separation", 3)
	controls_sections.add_child(grid)
	for section: Array in _control_rows():
		for column in 2:
			var heading := Label.new()
			heading.text = section[0] if column == 0 else ""
			heading.add_theme_font_size_override("font_size", 20)
			heading.add_theme_color_override("font_color", CONTROLS_HEADING_COLOR)
			# A gap above every heading but the first.
			heading.custom_minimum_size.y = 26.0 if grid.get_child_count() < 2 else 40.0
			heading.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			grid.add_child(heading)
		for row: Array in section[1]:
			for column in 2:
				var cell := Label.new()
				cell.text = row[column]
				cell.add_theme_font_size_override("font_size", 18)
				if column == 0:
					cell.add_theme_color_override("font_color", CONTROLS_KEY_COLOR)
				grid.add_child(cell)


## The controls screen's sections: a heading and its rows of [keys or button,
## what it does]. The prompts that show during play ("F  Drive", the touch use
## button) are not repeated here as prompts; they stay where they are.
func _control_rows() -> Array:
	if _touch:
		return [
			["On foot", [
				["MOVE stick", "Move (push further to go faster)"],
				["Drag on the right side", "Look around"],
				["RISE (hold)", "Jetpack up; let go to float down"],
				["RUN (hold while moving)", "Run"],
				["DROP (hold, in the air)", "Drop fast"],
				["DRIVE (beside a parked car)", "Get in"],
			]],
			["In a car", [
				["MOVE stick", "Drive and steer"],
				["BRAKE (hold)", "Handbrake"],
				["GET OUT", "Get out"],
			]],
			["Any time", [
				["II (top right)", "Pause"],
			]],
		]
	# The browser lets go of the mouse on Esc; Click to look takes it again.
	var web := OS.has_feature("web")
	var any_time := [["Esc", "Pause and free the mouse" if web else "Pause"], ["F3", "Debug info"]]
	if not web:
		any_time.append(["Q (while paused)", "Quit"])
	else:
		any_time.push_front(["Click to look (top)", "Let the mouse turn the view"])
	return [
		["On foot", [
			["W A S D or arrow keys", "Move"],
			["Shift (hold)", "Run"],
			["Space (hold)", "Jetpack up; let go to float down"],
			["C (hold, in the air)", "Drop fast"],
			["Mouse", "Look around"],
			["F (beside a parked car)", "Get in"],
			["R", "Back to safe ground"],
		]],
		["In a car", [
			["W / S or up / down arrows", "Drive, brake and reverse"],
			["A / D or left / right arrows", "Steer"],
			["Space (hold)", "Handbrake"],
			["Mouse", "Glance around (the view swings back)"],
			["R", "Back on land"],
			["F", "Get out"],
		]],
		["Any time", any_time],
	]


func toggle_debug() -> void:
	debug_panel.visible = not debug_panel.visible


## On a touch screen (main.gd): the controls screen lists the touch controls, the
## menus' buttons are big enough for a thumb and the credits' text is larger.
func set_touch_instructions() -> void:
	_touch = true
	_fill_controls()
	resume_button.text = "Play / Resume"
	for button: Button in [resume_button, controls_button, credits_button, exit_button, back_button, load_controls_button, credits_licences_button, credits_back_button]:
		button.custom_minimum_size.y = 64.0
	pause_box.custom_minimum_size.x = 420.0
	_fill_credits()
	_fit_credits()


func set_pointer_capture_hint(show_hint: bool) -> void:
	if _capture_hint == null and show_hint:
		_capture_hint = Button.new()
		_capture_hint.text = "Click to look"
		add_child(_capture_hint)
		_capture_hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
		_capture_hint.offset_left = -110.0
		_capture_hint.offset_right = 110.0
		_capture_hint.offset_top = 20.0
		_capture_hint.offset_bottom = 68.0
		_capture_hint.pressed.connect(func() -> void: resume_requested.emit())
	if _capture_hint != null:
		_capture_hint.visible = show_hint
