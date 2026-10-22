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
	_touch(controls, 1, Vector2(130, 760), true)
	var drag := InputEventScreenDrag.new()
	drag.index = 1
	drag.position = Vector2(130, 715)
	controls._input(drag)
	var magnitude := controls.get_movement_vector().length()
	if magnitude <= 0.1 or magnitude >= 0.9:
		_fail("Half-stick must retain proportional movement")
		return
	_touch(controls, 2, Vector2(1344, 740), true)
	if not (controls.get_movement_vector().y < -0.1) or not Input.is_action_pressed("jetpack"):
		_fail("Simultaneous joystick and rise did not press stock actions")
		return
	_touch(controls, 2, Vector2(1344, 740), false)
	if Input.is_action_pressed("jetpack") or not (controls.get_movement_vector().y < -0.1):
		_fail("Releasing rise also released movement, or left rise held")
		return
	# A browser may supply a relative value polluted by another finger. The
	# camera must follow only the look owner's actual positions.
	_touch(controls, 8, Vector2(900, 440), true)
	var before := controls.get_camera_rotation()
	var look := InputEventScreenDrag.new()
	look.index = 8
	look.position = Vector2(908, 440)
	look.relative = Vector2(700, 600)
	controls._input(drag) # independent movement finger, far from look
	controls._input(look)
	if not is_equal_approx(controls.get_camera_rotation().x - before.x, -0.8) or not is_equal_approx(controls.get_camera_rotation().y, before.y):
		_fail("Camera jumped from another finger or misleading relative delta")
		return
	_touch(controls, 8, look.position, false, true)
	_touch(controls, 9, Vector2(1200, 300), true)
	before = controls.get_camera_rotation()
	look.index = 9
	look.position = Vector2(1208, 300)
	controls._input(look)
	if not is_equal_approx(controls.get_camera_rotation().x - before.x, -0.8):
		_fail("Look reacquisition retained stale finger origin")
		return
	controls.set_gameplay_active(false)
	if (controls.get_movement_vector().y < -0.1):
		_fail("Pause left movement held")
		return
	controls.set_gameplay_active(true)
	# A finger held across pause must not resume movement on later drag.
	controls._input(drag)
	if (controls.get_movement_vector().y < -0.1):
		_fail("An old finger resumed after pause")
		return
	_touch(controls, 3, Vector2(1216, 740), true)
	if not Input.is_action_pressed("run"):
		_fail("Run hold did not press stock action")
		return
	_touch(controls, 3, Vector2(1216, 740), false, true)
	if Input.is_action_pressed("run"):
		_fail("Cancelled run remained held")
		return
	_touch(controls, 4, Vector2(1344, 740), true)
	controls.free()
	if Input.is_action_pressed("jetpack"):
		_fail("Teardown left rise held")
		return
	print("PASS: donor analog strength, touch multitouch independence, release, pause, stale-finger rejection, cancellation and teardown")
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
