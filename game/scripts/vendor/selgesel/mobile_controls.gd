# Adapted from selgesel/godot4-third-person-controller player/MobileControls.gd.
# MIT; see LICENSE and README.md beside this file. Input layer only.
extends Control

var _move_stick: SelgeselThumbStick
var _buttons: Array[SelgeselVirtualButton] = []
var _cam_rot := Vector2.ZERO
var _touches := {}
var sensitivity := 0.1 # Upstream degrees per logical viewport pixel.
var min_pitch := -60.0
var max_pitch := 25.0

func handle_mobile_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	# Route the upstream widgets first, then exclude their fingers from look.
	for button in _buttons:
		button.handle_input(event)
	_move_stick.handle_input(event)
	if event is InputEventScreenTouch:
		if not event.pressed or event.canceled:
			_touches.erase(event.index)
		elif event.index != _move_stick._touch_index and event.position.x >= size.x * 0.5 and _touches.is_empty():
			var on_button := false
			for button in _buttons:
				on_button = on_button or button.get_global_rect().has_point(event.position)
			if not on_button:
				_touches[event.index] = {"begin": event.position, "current": event.position}
	if event is InputEventScreenDrag and _touches.has(event.index):
		_touches[event.index].current = event.position
		if _touches.size() == 1:
			_cam_rot.x -= event.relative.x * sensitivity
			_cam_rot.y -= event.relative.y * sensitivity
			_cam_rot.y = clampf(_cam_rot.y, min_pitch, max_pitch)

func get_movement_vector() -> Vector2:
	return _move_stick.get_value()

func get_camera_rotation() -> Vector2:
	return _cam_rot

func release_mobile_input() -> void:
	_touches.clear()
	if _move_stick != null:
		_move_stick.release_all()
	for button in _buttons:
		button._release()
