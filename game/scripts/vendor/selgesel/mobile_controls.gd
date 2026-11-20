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
## Whether a finger may turn the camera (touch_controls.gd: not in a car).
var look_enabled := true

func handle_mobile_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	# Route the upstream widgets first, then exclude their fingers from look.
	for button in _buttons:
		button.handle_input(event)
	_move_stick.handle_input(event)
	if event is InputEventScreenTouch:
		# A lift ends its finger's look. A press of an index still held as a look
		# finger means that finger's lift was lost: its stale look ends first, so it
		# neither blocks a new look nor turns the camera with the reused index.
		_touches.erase(event.index)
		# One look finger, pressed anywhere but on a control.
		if event.pressed and not event.canceled and look_enabled and _touches.is_empty() and event.index != _move_stick._touch_index and not _on_control(event.position):
			_touches[event.index] = {"begin": event.position, "current": event.position}
	if event is InputEventScreenDrag and _touches.has(event.index):
		var relative: Vector2 = event.position - _touches[event.index].current
		_touches[event.index].current = event.position
		if _touches.size() == 1:
			_cam_rot.x -= relative.x * sensitivity
			_cam_rot.y -= relative.y * sensitivity
			_cam_rot.y = clampf(_cam_rot.y, min_pitch, max_pitch)

## Whether a finger pressed here is on a control the player sees: the stick
## (where it takes a finger) or a button. Such a finger never turns the camera,
## even where the control doesn't take it (a second finger on a held one).
func _on_control(at: Vector2) -> bool:
	if _move_stick.is_visible_in_tree() and _move_stick.covers(at):
		return true
	return _buttons.any(func(button: SelgeselVirtualButton) -> bool: return button.is_visible_in_tree() and button.get_global_rect().has_point(at))

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
