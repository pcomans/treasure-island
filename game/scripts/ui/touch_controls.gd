class_name TouchControls
extends "res://game/scripts/vendor/selgesel/mobile_controls.gd"

signal pause_requested

const THUMB := preload("res://game/scripts/vendor/selgesel/virtual_thumb_stick.gd")
const BUTTON := preload("res://game/scripts/vendor/selgesel/virtual_button.gd")
const ART := "res://game/resources/ui/selgesel/"
var camera_rig: PlayerCamera
var player: PlayerController
var _active := false
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
	_make_button("jetpack", "icon-jump.png")
	_make_button("run", "icon-sprint.png")
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

func _make_button(action: String, icon: String) -> void:
	var button := BUTTON.new()
	button.action = action
	button.button_texture = load(ART + icon)
	button.default_color = Color(0.9, 0.9, 0.9, 0.85)
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
	queue_redraw()

func set_gameplay_active(active: bool) -> void:
	_release_all()
	_active = active
	visible = active
	if camera_rig != null:
		_cam_rot = Vector2(rad_to_deg(camera_rig.rotation.y), rad_to_deg(camera_rig.spring_arm.rotation.x))
		min_pitch = camera_rig.minimum_pitch_degrees
		max_pitch = camera_rig.maximum_pitch_degrees
	_last_camera_rotation = _cam_rot

func _input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventScreenTouch and event.pressed and not event.canceled and event.position.distance_to(_pause_center) <= 34.0:
		pause_requested.emit()
		get_viewport().set_input_as_handled()
		return
	handle_mobile_input(event)
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not _active:
		return
	if player != null:
		player.touch_input_vector = get_movement_vector()
	if camera_rig != null:
		var change := get_camera_rotation() - _last_camera_rotation
		camera_rig.apply_look_delta(-change * (PI / 180.0) / camera_rig.look_sensitivity)
	_last_camera_rotation = get_camera_rotation()

func _release_all() -> void:
	release_mobile_input()
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
	for item in [[_move_stick.position + Vector2(82, 228), "MOVE"], [_buttons[0].position + Vector2(18, 122), "RISE"], [_buttons[1].position + Vector2(18, 122), "RUN"], [Vector2(_safe_rect.position.x + _safe_rect.size.x * 0.55, _safe_rect.end.y - 30), "Drag right side to look"]]:
		draw_string(font, item[0], item[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	draw_circle(_pause_center, 34, Color(0.03, 0.1, 0.14, 0.65))
	draw_string(font, _pause_center + Vector2(-8, 7), "II", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
