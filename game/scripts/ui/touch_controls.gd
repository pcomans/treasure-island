class_name TouchControls
extends "res://game/scripts/vendor/selgesel/mobile_controls.gd"

signal pause_requested

const THUMB := preload("res://game/scripts/vendor/selgesel/virtual_thumb_stick.gd")
const BUTTON := preload("res://game/scripts/vendor/selgesel/virtual_button.gd")
const USE_BUTTON := preload("res://game/scripts/ui/touch_use_button.gd")
const BRAKE_ICON := preload("res://game/resources/ui/touch/icon-brake.png")
const ART := "res://game/resources/ui/selgesel/"
const BUTTON_COLOR := Color(0.9, 0.9, 0.9, 0.85)
## How long the player must be off the ground before the use button shows the
## drop arrow (s), so a step down a kerb doesn't flash it.
const AIR_SHOW_S := 0.15
## The pause button: a disc of this radius, and a tap within it (px).
const PAUSE_RADIUS_PX := 34.0
## A button's label sits LABEL_INSET_PX in from its left and on the use button's
## baseline (touch_use_button.gd LABEL_BASELINE_PX); the stick's MOVE label at
## this offset from the stick's corner.
const LABEL_INSET_PX := 18.0
const STICK_LABEL_AT := Vector2(82, 228)
var camera_rig: PlayerCamera
var player: PlayerController
## The drivable cars (main.gd sets them once the world is loaded): the use
## button reads whether the player is in a car or beside one to get into.
var vehicles: VehicleManager
## The context button above RISE: DRIVE, GET OUT or DROP (touch_use_button.gd).
var use_button: TouchUseButton
var _active := false
var _air_s := 0.0
var _driving := false
## RISE's own glyph, back on foot (in a car it shows BRAKE_ICON).
var _rise_texture: Texture2D
var _last_camera_rotation := Vector2.ZERO
var _safe_rect := Rect2()
var _pause_center := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_move_stick = THUMB.new()
	_move_stick.name = "MoveStick"
	_move_stick.max_distance = 90.0
	_texture(_move_stick, "Reticle", "joystick-reticle.png", Vector2(90, 90), Vector2(40, 40))
	_texture(_move_stick, "Ring", "thumb-stick-ring.png", Vector2(20, 20), Vector2(180, 180))
	_texture(_move_stick, "Indicator", "thumb-stick-arrow.png", Vector2(20, 20), Vector2(180, 180))
	add_child(_move_stick)
	_make_button(RiseButton.new(), "jetpack", "icon-jump.png")
	_make_button(BUTTON.new(), "run", "icon-sprint.png")
	_rise_texture = _buttons[0].button_texture
	use_button = USE_BUTTON.new()
	use_button.name = "UseButton"
	use_button.default_color = BUTTON_COLOR
	add_child(use_button)
	resized.connect(_layout)
	_layout()

func _texture(parent: Control, node_name: String, file: String, at: Vector2, dimensions: Vector2) -> void:
	var texture := TextureRect.new()
	texture.name = node_name
	texture.texture = load(ART + file)
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.position = at
	texture.size = dimensions
	texture.pivot_offset = dimensions * 0.5
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture)

func _make_button(button: SelgeselVirtualButton, action: String, icon: String) -> void:
	button.action = action
	button.button_texture = load(ART + icon)
	button.default_color = BUTTON_COLOR
	_texture(button, "TextureRect", icon, Vector2.ZERO, Vector2(96, 96))
	add_child(button)
	_buttons.append(button)

func _layout() -> void:
	_release_all()
	_safe_rect = Rect2(Vector2.ZERO, size)
	if OS.has_feature("web"):
		var insets: Array = JSON.parse_string(str(JavaScriptBridge.eval("JSON.stringify(['left','top','right','bottom'].map(side=>parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--safe-'+side))||0).concat([innerWidth,innerHeight]))")))
		var css_scale := size / Vector2(float(insets[4]), float(insets[5]))
		var start := Vector2(float(insets[0]), float(insets[1])) * css_scale
		var end := Vector2(float(insets[2]), float(insets[3])) * css_scale
		_safe_rect = Rect2(start, size - start - end)
	_pause_center = Vector2(_safe_rect.end.x - 55, _safe_rect.position.y + 55)
	_move_stick.position = Vector2(_safe_rect.position.x + 20, _safe_rect.end.y - 250)
	_move_stick.size = Vector2(220, 220)
	_buttons[0].position = _safe_rect.end - Vector2(144, 208)
	_buttons[1].position = _safe_rect.end - Vector2(272, 208)
	for button in _buttons:
		button.size = Vector2(96, 96)
	# Above RISE, under the same right thumb, clear of RISE's label.
	use_button.position = _safe_rect.end - Vector2(144, 352)
	use_button.size = Vector2(96, 96)
	queue_redraw()

func set_gameplay_active(active: bool) -> void:
	_release_all()
	_active = active
	visible = active
	_sync_camera()

## Look from where the stock camera rig points now.
func _sync_camera() -> void:
	if camera_rig != null:
		_cam_rot = Vector2(rad_to_deg(camera_rig.rotation.y), rad_to_deg(camera_rig.spring_arm.rotation.x))
		min_pitch = camera_rig.minimum_pitch_degrees
		max_pitch = camera_rig.maximum_pitch_degrees
	_last_camera_rotation = _cam_rot

func _input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventScreenTouch and event.pressed and not event.canceled and event.position.distance_to(_pause_center) <= PAUSE_RADIUS_PX:
		pause_requested.emit()
		get_viewport().set_input_as_handled()
		return
	# The use button's own finger never reaches the stick, buttons or look.
	if use_button.handle_input(event):
		get_viewport().set_input_as_handled()
		return
	handle_mobile_input(event)
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not _active:
		return
	if player != null:
		player.touch_input_vector = get_movement_vector()
	if camera_rig != null:
		var change := get_camera_rotation() - _last_camera_rotation
		camera_rig.apply_look_delta(-change * (PI / 180.0) / camera_rig.look_sensitivity)
	_last_camera_rotation = get_camera_rotation()
	_update_use_button(delta)

## The use button's context: in a car GET OUT; off the ground for AIR_SHOW_S,
## DROP; on the ground beside a car to get into (the vehicles' "F  Drive" test),
## DRIVE; else hidden. Without a player it keeps what it was given.
func _update_use_button(delta: float) -> void:
	var driving := vehicles != null and vehicles.is_driving()
	if driving != _driving:
		_driving = driving
		# Getting out turns the stock camera rig to the car's view.
		_sync_camera()
		_show_driving(driving)
	if player == null:
		return
	_air_s = 0.0 if driving or player.is_on_floor() else _air_s + delta
	var mode := TouchUseButton.Mode.HIDDEN
	if driving:
		mode = TouchUseButton.Mode.EXIT
	elif player.is_processing_unhandled_input():
		if _air_s >= AIR_SHOW_S:
			mode = TouchUseButton.Mode.DROP
		elif vehicles != null and vehicles.can_enter():
			mode = TouchUseButton.Mode.ENTER
	use_button.set_mode(mode)

## In a car RISE is the handbrake, shown with its own glyph and label, and RUN
## and the look hint go (a car reads neither the run nor a touch look); on foot
## all come back. RUN lets go of its finger first, so no run outlasts the hide.
func _show_driving(driving: bool) -> void:
	_buttons[0].set_button_texture(BRAKE_ICON if driving else _rise_texture)
	if driving:
		_buttons[1]._release()
	_buttons[1].visible = not driving
	queue_redraw()

## Where the controls are, in viewport pixels, and what they show (the web
## state readback; a capture driver touches them there).
func describe() -> Dictionary:
	var at := func(point: Vector2) -> Array: return [point.x, point.y]
	return {
		"stick": at.call(_move_stick.get_global_rect().get_center()),
		"rise": at.call(_buttons[0].get_global_rect().get_center()),
		"run": at.call(_buttons[1].get_global_rect().get_center()),
		"use": at.call(use_button.get_global_rect().get_center()),
		"pause": at.call(_pause_center),
		"stick_reach": _move_stick.max_distance,
		"use_mode": use_button.mode_name(),
		"use_touched": use_button.is_touched(),
		"rise_label": _rise_label(),
		"rise_icon": "brake" if _buttons[0].button_texture == BRAKE_ICON else "jump",
		"run_visible": _buttons[1].visible,
		"look_hint": not _driving,
	}

func _rise_label() -> String:
	return "BRAKE" if _driving else "RISE"

func _release_all() -> void:
	release_mobile_input()
	if use_button != null:
		use_button.release()
	if player != null:
		player.touch_input_vector = Vector2.ZERO

func _exit_tree() -> void:
	_release_all()

func _draw() -> void:
	# Keep the upstream stick texture readable over pale paths and grass.
	var stick_center := _move_stick.position + Vector2(110, 110)
	draw_circle(stick_center, 94, Color(0.02, 0.06, 0.09, 0.62))
	draw_arc(stick_center, 90, 0, TAU, 64, Color(0.75, 0.9, 0.95, 0.75), 2, true)
	draw_circle(stick_center, 24, Color(0.04, 0.22, 0.28, 0.85))
	var font := ThemeDB.fallback_font
	var label_at := Vector2(LABEL_INSET_PX, USE_BUTTON.LABEL_BASELINE_PX)
	var labels := [[_move_stick.position + STICK_LABEL_AT, "MOVE"], [_buttons[0].position + label_at, _rise_label()]]
	if not _driving:
		labels.append_array([[_buttons[1].position + label_at, "RUN"], [Vector2(_safe_rect.position.x + _safe_rect.size.x * 0.55, _safe_rect.end.y - 30), "Drag right side to look"]])
	for item in labels:
		draw_string(font, item[0], item[1], HORIZONTAL_ALIGNMENT_LEFT, -1, USE_BUTTON.LABEL_FONT_SIZE, Color.WHITE)
	draw_circle(_pause_center, PAUSE_RADIUS_PX, Color(0.03, 0.1, 0.14, 0.65))
	draw_string(font, _pause_center + Vector2(-8, 7), "II", HORIZONTAL_ALIGNMENT_LEFT, -1, USE_BUTTON.LABEL_FONT_SIZE, Color.WHITE)

## RISE presses the jetpack and, as Space does, the handbrake: in a car the
## vehicles read it (the jetpack is off there); on foot nothing reads it.
## (Untyped, as the vendored methods they override are.)
class RiseButton extends SelgeselVirtualButton:
	func handle_input(event):
		super.handle_input(event)
		if _touch_index != -1 and not Input.is_action_pressed("handbrake"):
			Input.action_press("handbrake")

	func _release():
		super._release()
		Input.action_release("handbrake")
