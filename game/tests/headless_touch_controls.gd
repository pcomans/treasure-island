extends SceneTree

const TOUCH := preload("res://game/scripts/ui/touch_controls.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var controls := TOUCH.new()
	root.add_child(controls)
	controls.set_anchors_preset(Control.PRESET_TOP_LEFT)
	controls.size = Vector2(1440, 900)
	controls.set_gameplay_active(true)
	# Two simultaneous fingers must release independently.
	_touch(controls, 1, Vector2(110, 780), true)
	var drag := InputEventScreenDrag.new()
	drag.index = 1
	drag.position = Vector2(110, 716)
	controls._input(drag)
	_touch(controls, 2, Vector2(1352, 788), true)
	if not Input.is_action_pressed("move_forward") or not Input.is_action_pressed("jetpack"):
		_fail("Simultaneous joystick and rise did not press stock actions")
		return
	_touch(controls, 2, Vector2(1352, 788), false)
	if Input.is_action_pressed("jetpack") or not Input.is_action_pressed("move_forward"):
		_fail("Releasing rise also released movement, or left rise held")
		return
	controls.set_gameplay_active(false)
	if Input.is_action_pressed("move_forward"):
		_fail("Pause left movement held")
		return
	controls.set_gameplay_active(true)
	# A finger held across pause must not resume movement on later drag.
	controls._input(drag)
	if Input.is_action_pressed("move_forward"):
		_fail("An old finger resumed after pause")
		return
	_touch(controls, 3, Vector2(1228, 788), true)
	if not Input.is_action_pressed("run"):
		_fail("Run hold did not press stock action")
		return
	_touch(controls, 3, Vector2(1228, 788), false, true)
	if Input.is_action_pressed("run"):
		_fail("Cancelled run remained held")
		return
	_touch(controls, 4, Vector2(1352, 788), true)
	controls.free()
	if Input.is_action_pressed("jetpack"):
		_fail("Teardown left rise held")
		return
	print("PASS: touch multitouch independence, release, pause, stale-finger rejection, cancellation and teardown")
	quit(0)


func _touch(controls: Control, index: int, position: Vector2, pressed: bool, canceled := false) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	event.canceled = canceled
	controls._input(event)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
