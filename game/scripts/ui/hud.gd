class_name GameHUD
extends Control

signal resume_requested
signal exit_requested

@onready var reticle: Control = $Reticle
@onready var feedback_panel: PanelContainer = $FeedbackPanel
@onready var feedback_text: Label = $FeedbackPanel/FeedbackText
@onready var pause_panel: PanelContainer = $PausePanel
@onready var resume_button: Button = $PausePanel/PauseLayout/ResumeButton
@onready var exit_button: Button = $PausePanel/PauseLayout/ExitButton
@onready var load_panel: PanelContainer = $LoadPanel
@onready var load_text: Label = $LoadPanel/LoadLayout/LoadText
@onready var debug_panel: PanelContainer = $DebugPanel
@onready var debug_text: Label = $DebugPanel/DebugText

var _feedback_seconds := 0.0
var _evidence: RuntimeEvidence
var _capture_hint: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if OS.has_feature("web"):
		$PausePanel/PauseLayout/Controls.text = "WASD move • Shift run • Space jetpack • Mouse look\nR recover • F3 debug • Spray unavailable in browser"
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	exit_button.pressed.connect(func() -> void: exit_requested.emit())
	feedback_panel.hide()
	pause_panel.hide()
	debug_panel.hide()
	reticle.hide()


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


func set_paused(paused: bool) -> void:
	pause_panel.visible = paused
	reticle.visible = not paused and not load_panel.visible
	if paused:
		resume_button.grab_focus()


func toggle_debug() -> void:
	debug_panel.visible = not debug_panel.visible


func set_touch_instructions() -> void:
	$PausePanel/PauseLayout/Controls.text = "Left stick: move • Right drag: look\nHold RISE: jetpack • Release: descend\nHold RUN while moving to run"
	resume_button.text = "Play / Resume"
	resume_button.custom_minimum_size.y = 64.0
	exit_button.custom_minimum_size.y = 64.0
	pause_panel.offset_left = -240.0
	pause_panel.offset_right = 240.0
	pause_panel.offset_top = -165.0
	pause_panel.offset_bottom = 165.0


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
