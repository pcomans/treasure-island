class_name GameHUD
extends Control

signal resume_requested
signal exit_requested

## The controls screen: headings in this colour, keys and buttons in the other.
const CONTROLS_HEADING_COLOR := Color(0.62, 0.85, 1.0)
const CONTROLS_KEY_COLOR := Color(1.0, 0.86, 0.55)

@onready var reticle: Control = $Reticle
@onready var feedback_panel: PanelContainer = $FeedbackPanel
@onready var feedback_text: Label = $FeedbackPanel/FeedbackText
@onready var pause_panel: PanelContainer = $PausePanel
@onready var resume_button: Button = $PausePanel/PauseLayout/ResumeButton
@onready var controls_button: Button = $PausePanel/PauseLayout/ControlsButton
@onready var exit_button: Button = $PausePanel/PauseLayout/ExitButton
## The controls screen, opened from the pause menu or the loading screen: a
## solid panel over the dimmed game.
@onready var controls_screen: Control = $ControlsScreen
@onready var controls_sections: VBoxContainer = $ControlsScreen/Center/ControlsPanel/ControlsLayout/Sections
@onready var back_button: Button = $ControlsScreen/Center/ControlsPanel/ControlsLayout/BackButton
@onready var load_controls_button: Button = $LoadPanel/LoadLayout/LoadStack/ControlsButton
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


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	exit_button.pressed.connect(func() -> void: exit_requested.emit())
	controls_button.pressed.connect(show_controls)
	load_controls_button.pressed.connect(show_controls)
	back_button.pressed.connect(hide_controls)
	_fill_controls()
	feedback_panel.hide()
	pause_panel.hide()
	controls_screen.hide()
	debug_panel.hide()
	prompt_panel.hide()
	reticle.hide()
	resized.connect(_fit_load_icon)
	_fit_load_icon()


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
	reticle.hide()


func update_load_progress(loaded: int, total: int) -> void:
	load_text.text = "Building complete world… %d / %d" % [loaded, total]


func show_world_ready() -> void:
	load_panel.hide()
	# Play starts: a controls screen opened from the loading screen closes too.
	controls_screen.hide()
	reticle.show()


func show_load_error(code: String, message: String, source_keys: Array) -> void:
	var source_suffix := ""
	if not source_keys.is_empty():
		source_suffix = "\nSources: %s" % ", ".join(source_keys)
	load_text.text = "WORLD LOAD BLOCKED\n[%s] %s%s\n\nNo partial world was started." % [code, message, source_suffix]
	load_panel.show()
	reticle.hide()


func show_feedback(message: String, success: bool) -> void:
	feedback_text.text = ("✓ " if success else "✕ ") + message
	feedback_text.modulate = Color("d9ffe9") if success else Color("ffe1d9")
	feedback_panel.show()
	_feedback_seconds = 2.0


## A short key hint near the bottom of the screen ("F  Drive" beside a car);
## "" hides it.
func set_prompt(text: String) -> void:
	prompt_text.text = text
	prompt_panel.visible = not text.is_empty()


func set_paused(paused: bool) -> void:
	_paused = paused
	pause_panel.visible = paused
	controls_screen.hide()
	reticle.visible = not paused and not load_panel.visible
	if paused:
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
				["Left stick", "Move (push further to go faster)"],
				["Drag on the right side", "Look around"],
				["RISE (hold)", "Jetpack up; let go to float down"],
				["RUN (hold while moving)", "Run"],
				["DROP (hold, in the air)", "Drop fast"],
				["DRIVE (beside a parked car)", "Get in"],
			]],
			["In a car", [
				["Left stick", "Drive and steer"],
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
	return [
		["On foot", [
			["W A S D or arrow keys", "Move"],
			["Shift (hold)", "Run"],
			["Space (hold)", "Jetpack up; let go to float down"],
			["C (hold, in the air)", "Drop fast"],
			["Mouse", "Look around, after Click to look" if web else "Look around"],
			["F (beside a parked car)", "Get in"],
			["R", "Back to safe ground"],
		]],
		["In a car", [
			["W / S or up / down arrows", "Drive, brake and reverse"],
			["A / D or left / right arrows", "Steer"],
			["Space (hold)", "Handbrake"],
			["Mouse", "Look around"],
			["R", "Back on land"],
			["F", "Get out"],
		]],
		["Any time", any_time],
	]


func toggle_debug() -> void:
	debug_panel.visible = not debug_panel.visible


## On a touch screen (main.gd): the controls screen lists the touch controls, and
## the menus' buttons are big enough for a thumb.
func set_touch_instructions() -> void:
	_touch = true
	_fill_controls()
	resume_button.text = "Play / Resume"
	for button: Button in [resume_button, controls_button, exit_button, back_button, load_controls_button]:
		button.custom_minimum_size.y = 64.0
	pause_panel.offset_left = -200.0
	pause_panel.offset_right = 200.0
	pause_panel.offset_top = -170.0
	pause_panel.offset_bottom = 170.0


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
