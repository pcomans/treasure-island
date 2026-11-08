extends SceneTree

const TOUCH := preload("res://game/scripts/ui/touch_controls.gd")
const USE := preload("res://game/scripts/ui/touch_use_button.gd")
const RISE_AT := Vector2(1344, 740)


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
	# RISE is Space: the jetpack and, for a car, the handbrake.
	_touch(controls, 5, RISE_AT, true)
	if not Input.is_action_pressed("jetpack") or not Input.is_action_pressed("handbrake"):
		_fail("Rise did not press both the jetpack and the handbrake")
		return
	_touch(controls, 5, RISE_AT, false)
	if Input.is_action_pressed("jetpack") or Input.is_action_pressed("handbrake"):
		_fail("Lifting rise left the jetpack or the handbrake held")
		return
	if not await _use_button(controls):
		return
	_touch(controls, 4, RISE_AT, true)
	var use: USE = controls.use_button
	use.set_mode(USE.Mode.DROP)
	_touch(controls, 10, use.get_global_rect().get_center(), true)
	controls.free()
	if Input.is_action_pressed("jetpack") or Input.is_action_pressed("handbrake") or Input.is_action_pressed("fast_drop"):
		_fail("Teardown left rise or drop held")
		return
	print("PASS: donor analog strength, touch multitouch independence, release, pause, stale-finger rejection, cancellation and teardown; rise holds the handbrake with the jetpack; the use button's tap is one F press that a physics tick sees, neither its finger nor a second one on it turns the camera, and drop holds C until the finger lifts or is cancelled, the button changes or hides, the game pauses or the controls go")
	quit(0)


## The use button (touch_use_button.gd), given each mode as touch_controls.gd would.
func _use_button(controls: TouchControls) -> bool:
	var use: USE = controls.use_button
	var at := use.get_global_rect().get_center()
	var icon := use.get_node("Icon") as TextureRect
	# Hidden: a finger there presses nothing.
	_touch(controls, 6, at, true)
	var pressed := Input.is_action_pressed("vehicle_enter_exit") or Input.is_action_pressed("fast_drop")
	_touch(controls, 6, at, false)
	if use.visible or pressed:
		return _fail("The hidden use button showed or pressed an action")
	# DRIVE: a tap lifted at once is still one F press, down until a physics
	# tick has seen it and up after.
	use.set_mode(USE.Mode.ENTER)
	if not use.visible or use.mode_name() != "enter" or icon.texture != USE.CAR_ICON:
		return _fail("DRIVE did not show the car")
	_touch(controls, 6, at, true)
	_touch(controls, 6, at, false)
	if not Input.is_action_pressed("vehicle_enter_exit"):
		return _fail("A quick tap lost its F press")
	await physics_frame
	if not Input.is_action_pressed("vehicle_enter_exit"):
		return _fail("The tap's F went up before a physics tick saw it")
	for _frame in 3:
		await process_frame
	if Input.is_action_pressed("vehicle_enter_exit"):
		return _fail("The tap's F stayed down")
	# A finger left on it presses F once, and never turns the camera.
	use.set_mode(USE.Mode.EXIT)
	if use.mode_name() != "exit" or icon.texture != USE.CAR_ICON:
		return _fail("GET OUT did not show the car")
	var view := controls.get_camera_rotation()
	_touch(controls, 7, at, true)
	var slide := InputEventScreenDrag.new()
	slide.index = 7
	slide.position = at + Vector2(-60, -40)
	controls._input(slide)
	for _tick in 10:
		await physics_frame
	if Input.is_action_pressed("vehicle_enter_exit") or not use.is_touched() or controls.get_camera_rotation() != view:
		return _fail("A finger held on GET OUT kept F down or turned the camera")
	_touch(controls, 7, slide.position, false)
	if use.is_touched():
		return _fail("The lifted finger stayed on the use button")
	# DROP holds C while held, and lets go on a lift, a cancel, a hide (landing),
	# a change (landing beside a car) and a pause.
	use.set_mode(USE.Mode.DROP)
	if use.mode_name() != "drop" or icon.texture != USE.DROP_ICON:
		return _fail("DROP did not show the down arrow")
	_touch(controls, 8, at, true)
	for _tick in 10:
		await physics_frame
	if not Input.is_action_pressed("fast_drop"):
		return _fail("Holding DROP did not hold C")
	# A second finger pressed on the held button is the button's too: it never
	# turns the camera, and its lift leaves the first finger's C held.
	var view_held := controls.get_camera_rotation()
	_touch(controls, 11, at + Vector2(12, 12), true)
	var second := InputEventScreenDrag.new()
	second.index = 11
	second.position = at + Vector2(-80, -60)
	controls._input(second)
	_touch(controls, 11, second.position, false)
	if controls.get_camera_rotation() != view_held or not Input.is_action_pressed("fast_drop") or not use.is_touched():
		return _fail("A second finger on held DROP turned the camera or let go of C")
	_touch(controls, 8, at, false)
	if Input.is_action_pressed("fast_drop"):
		return _fail("Lifting DROP left C held")
	_touch(controls, 8, at, true)
	_touch(controls, 8, at, false, true)
	if Input.is_action_pressed("fast_drop"):
		return _fail("A cancelled DROP left C held")
	_touch(controls, 8, at, true)
	use.set_mode(USE.Mode.HIDDEN)
	if Input.is_action_pressed("fast_drop") or use.visible:
		return _fail("Hiding DROP mid-hold left C held")
	use.set_mode(USE.Mode.DROP)
	_touch(controls, 8, at, true)
	use.set_mode(USE.Mode.ENTER)
	if Input.is_action_pressed("fast_drop") or Input.is_action_pressed("vehicle_enter_exit") or use.is_touched():
		return _fail("Changing from DROP mid-hold left C held or pressed F")
	_touch(controls, 8, at, false)
	use.set_mode(USE.Mode.DROP)
	_touch(controls, 9, at, true)
	controls.set_gameplay_active(false)
	if Input.is_action_pressed("fast_drop"):
		return _fail("Pausing mid-DROP left C held")
	controls.set_gameplay_active(true)
	_touch(controls, 9, at, false)
	if Input.is_action_pressed("fast_drop") or use.is_touched():
		return _fail("A DROP finger held across the pause pressed C again")
	return true


func _touch(controls: Control, index: int, position: Vector2, pressed: bool, canceled := false) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	event.canceled = canceled
	controls._input(event)


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
