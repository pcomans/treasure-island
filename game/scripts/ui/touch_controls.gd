class_name TouchControls
extends Control

# Browser-only adapter: the stock player still owns movement and jetpack physics.
signal pause_requested

const MOVE_ACTIONS := ["move_left", "move_right", "move_forward", "move_back"]
const STICK_RADIUS := 64.0
var camera_rig: PlayerCamera
var _active := false
var _fingers: Dictionary = {}
var _stick_origin := Vector2.ZERO
var _stick_offset := Vector2.ZERO
var _owned_actions: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_release_all)


func set_gameplay_active(active: bool) -> void:
	_release_all()
	_active = active
	visible = active
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventScreenTouch:
		if not event.pressed or event.canceled:
			_release_finger(event.index)
		else:
			var role := _role_at(event.position)
			if role == "pause":
				pause_requested.emit()
			elif not role.is_empty() and not _fingers.values().has(role):
				_fingers[event.index] = role
				if role == "move":
					_stick_origin = event.position
				elif role == "run" or role == "jetpack":
					_set_action(role, 1.0)
		get_viewport().set_input_as_handled()
		queue_redraw()
	elif event is InputEventScreenDrag and _fingers.has(event.index):
		var role: String = _fingers[event.index]
		if role == "move":
			_stick_offset = (event.position - _stick_origin).limit_length(STICK_RADIUS)
			var axis := _stick_offset / STICK_RADIUS
			if axis.length() < 0.12:
				axis = Vector2.ZERO
			_set_action("move_left", maxf(-axis.x, 0.0))
			_set_action("move_right", maxf(axis.x, 0.0))
			_set_action("move_forward", maxf(-axis.y, 0.0))
			_set_action("move_back", maxf(axis.y, 0.0))
		elif role == "look" and camera_rig != null:
			camera_rig.apply_look_delta(event.screen_relative)
		get_viewport().set_input_as_handled()
		queue_redraw()


func _role_at(point: Vector2) -> String:
	if point.distance_to(_pause_center()) <= 34.0:
		return "pause"
	if point.distance_to(_rise_center()) <= 54.0:
		return "jetpack"
	if point.distance_to(_run_center()) <= 45.0:
		return "run"
	if point.x < size.x * 0.4 and point.y > size.y * 0.45:
		return "move"
	if point.x >= size.x * 0.5:
		return "look"
	return ""


func _set_action(action: String, strength: float) -> void:
	if strength > 0.0:
		Input.action_press(action, strength)
		_owned_actions[action] = true
	elif _owned_actions.erase(action):
		Input.action_release(action)


func _release_finger(index: int) -> void:
	var role: String = _fingers.get(index, "")
	_fingers.erase(index)
	if role == "move":
		for action: String in MOVE_ACTIONS:
			_set_action(action, 0.0)
		_stick_offset = Vector2.ZERO
	elif role == "run" or role == "jetpack":
		_set_action(role, 0.0)


func _release_all() -> void:
	for action: String in _owned_actions.keys():
		Input.action_release(action)
	_owned_actions.clear()
	_fingers.clear()
	_stick_offset = Vector2.ZERO
	queue_redraw()


func _exit_tree() -> void:
	_release_all()


func _rise_center() -> Vector2:
	return Vector2(size.x - 88.0, size.y - 112.0)


func _run_center() -> Vector2:
	return Vector2(size.x - 212.0, size.y - 112.0)


func _pause_center() -> Vector2:
	return Vector2(size.x - 55.0, 55.0)


func _draw() -> void:
	if not _active:
		return
	var stick := _stick_origin if _fingers.values().has("move") else Vector2(110.0, size.y - 120.0)
	draw_circle(stick, STICK_RADIUS, Color(0.03, 0.10, 0.14, 0.55))
	draw_arc(stick, STICK_RADIUS, 0.0, TAU, 48, Color(1, 1, 1, 0.7), 2.0, true)
	draw_circle(stick + _stick_offset, 26.0, Color(0.4, 0.9, 0.9, 0.8))
	_label(stick + Vector2(0, 95), "MOVE")
	_button(_rise_center(), 54.0, "RISE", _owned_actions.has("jetpack"))
	_button(_run_center(), 45.0, "RUN", _owned_actions.has("run"))
	_button(_pause_center(), 34.0, "II", false)
	_label(Vector2(size.x * 0.66, size.y - 35), "Drag right side to look")


func _button(center: Vector2, radius: float, text: String, pressed: bool) -> void:
	draw_circle(center, radius, Color(0.1, 0.55, 0.6, 0.8) if pressed else Color(0.03, 0.10, 0.14, 0.65))
	draw_arc(center, radius, 0.0, TAU, 48, Color(1, 1, 1, 0.7), 2.0, true)
	_label(center + Vector2(0, 7), text)


func _label(center: Vector2, text: String) -> void:
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	draw_string(font, center - Vector2(width * 0.5, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
