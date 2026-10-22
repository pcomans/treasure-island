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
	_move_stick.position = Vector2(20, size.y - 250)
	_move_stick.size = Vector2(220, 220)
	_buttons[0].position = Vector2(size.x - 144, size.y - 208)
	_buttons[1].position = Vector2(size.x - 272, size.y - 208)
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
	if event is InputEventScreenTouch and event.pressed and not event.canceled and event.position.distance_to(Vector2(size.x - 55, 55)) <= 34.0:
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
	var font := ThemeDB.fallback_font
	for item in [[Vector2(102, size.y - 22), "MOVE"], [Vector2(size.x - 126, size.y - 86), "RISE"], [Vector2(size.x - 254, size.y - 86), "RUN"], [Vector2(size.x * 0.55, size.y - 30), "Drag right side to look"]]:
		draw_string(font, item[0], item[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	draw_circle(Vector2(size.x - 55, 55), 34, Color(0.03, 0.1, 0.14, 0.65))
	draw_string(font, Vector2(size.x - 63, 62), "II", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
