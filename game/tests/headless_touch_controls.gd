extends SceneTree
## The browser's touch controls on their own (game/scripts/ui/touch_controls.gd and
## the vendored widgets under it), laid out as main.gd lays out a phone's screen (its
## short side GameMain.TOUCH_LAYOUT_PX): an iPhone 16 Pro's 402 x 874 CSS px held
## upright, then sideways. Every point a check touches comes from where the controls
## are laid out (describe() and their rects), never a pixel pinned to one screen. At
## each shape:
##   - the stick keeps its analog strength; RISE and the stick held together let go
##     apart; a look finger's turn comes from its own positions, not a browser's
##     relative value polluted by another finger, and a new look finger starts fresh;
##   - look anywhere (owner, 2026-11-20): a drag that starts anywhere but on a
##     control turns the camera (a grid over the whole screen, the left half beside
##     the stick named on its own, and the hidden use button's place); the stick
##     takes a finger on its disc and a thumb's width round it (one press just
##     inside that edge moves and never turns) but not in its square's corners (one
##     stroke just outside the edge, and one from a corner, turn); a drag that
##     starts on the stick moves and never turns, out past the stick too, and a second
##     finger pressed on the held stick doesn't turn; the stick and a look finger
##     together each do their own; a look drag that slides over RUN, RISE, DRIVE, the
##     stick and the pause button and lifts on RISE presses none of them; a finger
##     pressed on RUN, RISE or the pause button and dragged off turns nothing;
##   - a look finger whose lift was lost (a browser can drop a touchend) and whose
##     index comes back pressed: off the controls it starts a fresh look with no
##     jump, on RUN it is RUN's and turns nothing, and another finger can look after;
##   - pause lets go of everything, and a finger held across it does nothing after;
##     RUN holds and lets go on a cancel; RISE holds the handbrake with the jetpack;
##   - the use button: its tap is one F press that a physics tick sees, neither its
##     finger nor a second one on it turns the camera, and DROP holds C until the
##     finger lifts or is cancelled, the button changes or hides, or the game pauses.
## Then freeing the controls lets go of everything.

const TOUCH := preload("res://game/scripts/ui/touch_controls.gd")
const USE := preload("res://game/scripts/ui/touch_use_button.gd")
## An iPhone 16 Pro's screen in CSS px, held upright.
const PHONE := Vector2(402, 874)
## The upstream look: degrees a logical pixel (mobile_controls.gd sensitivity).
const DEGREES_PER_PX := 0.1
## The look-anywhere grid: this many columns and rows of points over the screen;
## a point nearer a control than CLEAR_PX is not tried, so no check depends on a
## control's exact edge.
const GRID := Vector2i(9, 15)
const CLEAR_PX := 24.0
## A look probe's stroke and the step of a slide (px).
const STROKE := Vector2(20, 0)
const SLIDE_STEP_PX := 8.0
const ACTIONS := [&"jetpack", &"handbrake", &"run", &"fast_drop", &"vehicle_enter_exit"]

var _pauses := 0
var _looked := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var controls := TOUCH.new()
	root.add_child(controls)
	controls.set_anchors_preset(Control.PRESET_TOP_LEFT)
	controls.pause_requested.connect(func() -> void: _pauses += 1)
	var short := float(GameMain.TOUCH_LAYOUT_PX)
	var long := short * PHONE.y / PHONE.x
	var shapes := {"upright": Vector2(short, long), "sideways": Vector2(long, short)}
	controls.set_gameplay_active(true)
	for shape: String in shapes:
		controls.size = shapes[shape]
		controls.use_button.set_mode(USE.Mode.HIDDEN)
		if not await _shape(controls, shape):
			return
	var rise := _centre(controls, "rise")
	_touch(controls, 4, rise, true)
	var use: USE = controls.use_button
	use.set_mode(USE.Mode.DROP)
	_touch(controls, 10, use.get_global_rect().get_center(), true)
	controls.free()
	if _held().size() > 0:
		_fail("Teardown left %s held" % [_held()])
		return
	print("PASS: touch controls upright and sideways (%s): donor analog strength, multitouch independence, release, pause, stale-finger rejection, cancellation and teardown; look anywhere: a drag starting anywhere but on a control turned the camera (%d starts tried, the left half beside the stick and the hidden use button's place among them), one starting on the stick moved and never turned, a second finger on the held stick never turned, the stick and a look finger worked together, and a look drag over RUN, RISE, DRIVE, the stick and the pause button pressed none of them; the stick took a press just inside its disc's edge and none just outside it or in its square's corner; fingers starting on RUN, RISE and the pause button turned nothing; a look finger pressed again after a lost lift looked from where it was or was RUN's, and others looked after; rise holds the handbrake with the jetpack; the use button's tap is one F press that a physics tick sees, neither its finger nor a second one on it turns the camera, and drop holds C until the finger lifts or is cancelled, the button changes or hides, the game pauses or the controls go" % [", ".join(PackedStringArray(shapes.values().map(func(size: Vector2) -> String: return "%d x %d px" % [roundi(size.x), roundi(size.y)]))), _looked])
	quit(0)


## Every check at one window shape.
func _shape(controls: TouchControls, shape: String) -> bool:
	var stick := _centre(controls, "stick")
	var rise := _centre(controls, "rise")
	var run := _centre(controls, "run")
	var reach := float(controls.describe().stick_reach)
	var free := _free_points(controls)
	if free.size() * 2 < GRID.x * GRID.y:
		return _fail("%s: only %d of %d grid points lie off the controls" % [shape, free.size(), GRID.x * GRID.y])
	# Two simultaneous fingers must release independently.
	_touch(controls, 1, stick, true)
	_slide(controls, 1, stick + Vector2(0, -reach * 0.5))
	var magnitude := controls.get_movement_vector().length()
	if magnitude <= 0.1 or magnitude >= 0.9:
		return _fail("%s: half-stick must retain proportional movement (%.2f)" % [shape, magnitude])
	_touch(controls, 2, rise, true)
	if not (controls.get_movement_vector().y < -0.1) or not Input.is_action_pressed("jetpack"):
		return _fail("%s: simultaneous joystick and rise did not press stock actions" % shape)
	_touch(controls, 2, rise, false)
	if Input.is_action_pressed("jetpack") or not (controls.get_movement_vector().y < -0.1):
		return _fail("%s: releasing rise also released movement, or left rise held" % shape)
	# A browser may supply a relative value polluted by another finger. The
	# camera must follow only the look owner's actual positions.
	var look_at := _nearest(free, Rect2(Vector2.ZERO, controls.size).get_center())
	_touch(controls, 8, look_at, true)
	var before := controls.get_camera_rotation()
	var look := InputEventScreenDrag.new()
	look.index = 8
	look.position = look_at + Vector2(8, 0)
	look.relative = Vector2(700, 600)
	_slide(controls, 1, stick + Vector2(0, -reach * 0.5)) # the movement finger, far from look
	controls._input(look)
	if not is_equal_approx(controls.get_camera_rotation().x - before.x, -0.8) or not is_equal_approx(controls.get_camera_rotation().y, before.y):
		return _fail("%s: camera jumped from another finger or a misleading relative delta" % shape)
	_touch(controls, 8, look.position, false, true)
	var again := _nearest(free, look_at + Vector2(controls.size.x * 0.2, -controls.size.y * 0.2))
	_touch(controls, 9, again, true)
	before = controls.get_camera_rotation()
	look.index = 9
	look.position = again + Vector2(8, 0)
	controls._input(look)
	if not is_equal_approx(controls.get_camera_rotation().x - before.x, -0.8):
		return _fail("%s: look reacquisition retained a stale finger origin" % shape)
	_touch(controls, 9, look.position, false)
	controls.set_gameplay_active(false)
	if controls.get_movement_vector().y < -0.1:
		return _fail("%s: pause left movement held" % shape)
	controls.set_gameplay_active(true)
	# A finger held across pause must not resume movement on later drag.
	_slide(controls, 1, stick + Vector2(0, -reach))
	if controls.get_movement_vector().y < -0.1:
		return _fail("%s: an old finger resumed after pause" % shape)
	_touch(controls, 1, stick, false)
	_touch(controls, 3, run, true)
	if not Input.is_action_pressed("run"):
		return _fail("%s: run hold did not press the stock action" % shape)
	_touch(controls, 3, run, false, true)
	if Input.is_action_pressed("run"):
		return _fail("%s: cancelled run remained held" % shape)
	# RISE is Space: the jetpack and, for a car, the handbrake.
	_touch(controls, 5, rise, true)
	if not Input.is_action_pressed("jetpack") or not Input.is_action_pressed("handbrake"):
		return _fail("%s: rise did not press both the jetpack and the handbrake" % shape)
	_touch(controls, 5, rise, false)
	if Input.is_action_pressed("jetpack") or Input.is_action_pressed("handbrake"):
		return _fail("%s: lifting rise left the jetpack or the handbrake held" % shape)
	if not _look_anywhere(controls, shape, free) or not _lost_lift(controls, shape, free):
		return false
	if not await _use_button(controls):
		return false
	controls.use_button.set_mode(USE.Mode.HIDDEN)
	return true


## Look anywhere (owner, 2026-11-20): see the header.
func _look_anywhere(controls: TouchControls, shape: String, free: Array[Vector2]) -> bool:
	var stick := _centre(controls, "stick")
	var stick_rect := (controls.get_node("MoveStick") as Control).get_global_rect()
	var rise := _centre(controls, "rise")
	var run := _centre(controls, "run")
	var reach := float(controls.describe().stick_reach)
	var screen := Rect2(Vector2.ZERO, controls.size)
	# The stick's edge, STICK_RADIUS_PX and STICK_TOUCH_MARGIN_PX from its centre: a
	# press just inside it, on the diagonal toward open screen, moves at full
	# strength and never turns; a stroke just outside it on that diagonal, and one
	# from just inside the square's top left corner, both in the stick's square,
	# turn the camera and move nothing.
	var edge: float = TOUCH.STICK_RADIUS_PX + TOUCH.STICK_TOUCH_MARGIN_PX
	var diagonal := Vector2(1, -1).normalized()
	var edge_view := controls.get_camera_rotation()
	var inside := stick + diagonal * (edge - 8.0)
	_touch(controls, 19, inside, true)
	_slide(controls, 19, inside + diagonal * 8.0)
	var pushed := controls.get_movement_vector()
	var turned_inside := controls.get_camera_rotation() != edge_view
	_touch(controls, 19, inside + diagonal * 8.0, false)
	if pushed.length() < 0.9 or turned_inside or not controls.get_movement_vector().is_zero_approx():
		return _fail("%s: a press %.0f px from the stick's centre, inside its edge, must move at full strength and never turn (movement %s, turned %s)" % [shape, edge - 8.0, pushed, turned_inside])
	for at: Vector2 in [stick + diagonal * (edge + 8.0), stick_rect.position + Vector2(8, 8)]:
		if not stick_rect.has_point(at):
			return _fail("%s: the stick-edge probe %s lies outside the stick's square %s" % [shape, at, stick_rect])
		if not _look_stroke(controls, 19, at, "%s: a drag from %s, in the stick's square but off its disc," % [shape, at]):
			return false
	# A drag from every point off the controls turns the camera by its own stroke,
	# and moves or presses nothing.
	for at: Vector2 in free:
		if not _look_stroke(controls, 20, at, "%s: a drag from %s" % [shape, at]):
			return false
	_looked += free.size()
	# The owner's case: the left half, beside and above the stick, and the left
	# half's middle.
	var left := free.filter(func(at: Vector2) -> bool: return at.x < screen.size.x * 0.5 and at.y < stick_rect.position.y and at.y > stick_rect.position.y - stick_rect.size.y)
	if left.is_empty():
		return _fail("%s: no grid point on the left half just above the stick (%s)" % [shape, stick_rect])
	for at: Vector2 in [left[-1], _nearest(free, Vector2(screen.size.x * 0.25, screen.size.y * 0.5))]:
		if at.x >= screen.size.x * 0.5:
			return _fail("%s: no grid point off the controls in the left half's middle (nearest %s)" % [shape, at])
		if not _look_stroke(controls, 20, at, "%s: a drag on the left half away from the stick, from %s," % [shape, at], Vector2(-30, 24)):
			return false
	# A drag that starts on the stick moves, out past the stick too, and never turns.
	var view := controls.get_camera_rotation()
	_touch(controls, 21, stick, true)
	_slide(controls, 21, stick + Vector2(0, -stick_rect.size.y * 1.5))
	var full := controls.get_movement_vector()
	_slide(controls, 21, stick + Vector2(stick_rect.size.x, -stick_rect.size.y * 1.5))
	if full.y > -0.9 or controls.get_camera_rotation() != view:
		return _fail("%s: a drag from the stick out past it must move at full strength and never turn (movement %s, turned %s)" % [shape, full, controls.get_camera_rotation() - view])
	# A second finger pressed on the held stick turns nothing, and leaves the stick to the first.
	_slide(controls, 21, stick + Vector2(0, -reach * 0.5))
	var held := controls.get_movement_vector()
	_touch(controls, 22, stick + Vector2(30, 30), true)
	_slide(controls, 22, stick + Vector2(120, -60))
	if controls.get_camera_rotation() != view or controls.get_movement_vector() != held:
		return _fail("%s: a second finger on the held stick turned the camera or moved the stick" % shape)
	_touch(controls, 22, stick + Vector2(120, -60), false)
	# The stick and a look finger together each do their own.
	_slide(controls, 21, stick + Vector2(0, -reach))
	var look_at: Vector2 = left[0]
	_touch(controls, 23, look_at, true)
	_slide(controls, 23, look_at + Vector2(30, 0))
	var turned := controls.get_camera_rotation() - view
	_slide(controls, 21, stick + Vector2(reach, 0))
	var steered := controls.get_movement_vector()
	if not is_equal_approx(turned.x, -30 * DEGREES_PER_PX) or controls.get_camera_rotation() - view != turned or steered.x < 0.9:
		return _fail("%s: the stick and a look finger together must each do their own (turned %s, then %s; stick %s)" % [shape, turned, controls.get_camera_rotation() - view, steered])
	_touch(controls, 23, look_at + Vector2(30, 0), false)
	_touch(controls, 21, stick + Vector2(reach, 0), false)
	if not controls.get_movement_vector().is_zero_approx():
		return _fail("%s: lifting the stick left movement" % shape)
	# A look drag over RUN, RISE, DRIVE, the stick and the pause button, lifted on
	# RISE, presses none of them and keeps turning by its own stroke.
	controls.use_button.set_mode(USE.Mode.ENTER)
	var pause: Array = controls.describe().pause
	var path: Array[Vector2] = [_nearest(free, run - Vector2(0, 200)), run, rise, _centre(controls, "use"), stick, Vector2(pause[0], pause[1]), rise]
	if not _look_path(controls, 24, path, "%s: a look drag over the controls" % shape):
		return false
	# A finger pressed on RUN, RISE or the pause button and dragged off turns nothing.
	for control: String in ["run", "rise", "pause"]:
		var at := _centre(controls, control)
		var pauses := _pauses
		view = controls.get_camera_rotation()
		_touch(controls, 25, at, true)
		var pressed := Input.is_action_pressed("run") if control == "run" else Input.is_action_pressed("jetpack") if control == "rise" else _pauses > pauses
		_slide(controls, 25, at + (look_at - at) * 0.5)
		_slide(controls, 25, look_at)
		var turned_off := controls.get_camera_rotation() != view
		_touch(controls, 25, look_at, false)
		if not pressed or turned_off or not _held().is_empty():
			return _fail("%s: a finger pressed on %s must work it and turn nothing when dragged off (pressed %s, turned %s, held after %s)" % [shape, control, pressed, turned_off, _held()])
	# The use button's place while it is hidden is open screen.
	controls.use_button.set_mode(USE.Mode.HIDDEN)
	if not _look_stroke(controls, 26, controls.use_button.get_global_rect().get_center(), "%s: a drag from the hidden use button's place" % shape):
		return false
	_looked += 3
	return true


## A look finger whose lift was lost (a browser can drop a touchend) and whose
## index comes back pressed: off the controls it starts a fresh look from where it
## is now, with no jump from the stale position; on RUN it is RUN's and turns
## nothing; and after either, another finger can look.
func _lost_lift(controls: TouchControls, shape: String, free: Array[Vector2]) -> bool:
	var run := _centre(controls, "run")
	var a := free[0]
	var c := _nearest(free, a + controls.size * 0.5)
	_touch(controls, 27, a, true)
	_slide(controls, 27, a + STROKE)
	_touch(controls, 27, c, true)
	var before := controls.get_camera_rotation()
	_slide(controls, 27, c + STROKE)
	var turned := controls.get_camera_rotation() - before
	_touch(controls, 27, c + STROKE, false)
	var relative := (c + STROKE) - c
	if not turned.is_equal_approx(-relative * DEGREES_PER_PX) or _other(controls) != "":
		return _fail("%s: a look finger pressed again at %s after its lift was lost at %s must look from where it is now (turned %s, not %s%s)" % [shape, c, a + STROKE, turned, -relative * DEGREES_PER_PX, _other(controls)])
	if not _look_stroke(controls, 28, a, "%s: a new look finger after a lost lift, from %s," % [shape, a]):
		return false
	_touch(controls, 29, a, true)
	_slide(controls, 29, a + STROKE)
	_touch(controls, 29, run, true)
	var view := controls.get_camera_rotation()
	var running := Input.is_action_pressed("run")
	_slide(controls, 29, a)
	var turned_on_run := controls.get_camera_rotation() != view
	_touch(controls, 29, a, false)
	if not running or turned_on_run or not _held().is_empty():
		return _fail("%s: a look finger pressed again on RUN after its lift was lost must be RUN's and turn nothing (run %s, turned %s, held after the lift %s)" % [shape, running, turned_on_run, _held()])
	return _look_stroke(controls, 30, a, "%s: a new look finger after a lost lift on RUN, from %s," % [shape, a])


## One finger down at `at`, a stroke and back, lifted: the camera turns by the
## stroke (DEGREES_PER_PX, the pitch within its limits) and nothing else happens.
func _look_stroke(controls: TouchControls, index: int, at: Vector2, label: String, stroke := STROKE) -> bool:
	var before := controls.get_camera_rotation()
	var pauses := _pauses
	var relative := (at + stroke) - at
	var expected := Vector2(before.x - relative.x * DEGREES_PER_PX, clampf(before.y - relative.y * DEGREES_PER_PX, controls.min_pitch, controls.max_pitch))
	_touch(controls, index, at, true)
	_slide(controls, index, at + stroke)
	var turned := controls.get_camera_rotation()
	var other := _other(controls)
	_slide(controls, index, at)
	_touch(controls, index, at, false)
	if _pauses != pauses:
		other += ", paused"
	if not turned.is_equal_approx(expected) or other != "":
		return _fail("%s must turn the camera from %s to %s, and only that (turned to %s%s)" % [label, before, expected, turned, other])
	return true


## One look finger along a path of points, a slide every SLIDE_STEP_PX, lifted at
## its end: at every step the camera has turned by the finger's own travel and
## nothing else has happened, and after the lift nothing is held.
func _look_path(controls: TouchControls, index: int, path: Array[Vector2], label: String) -> bool:
	var expected := controls.get_camera_rotation()
	var pauses := _pauses
	var last := path[0]
	_touch(controls, index, last, true)
	for leg in range(1, path.size()):
		var steps := maxi(1, ceili(path[leg - 1].distance_to(path[leg]) / SLIDE_STEP_PX))
		for step in steps:
			var to := path[leg - 1].lerp(path[leg], float(step + 1) / steps)
			var relative := to - last
			expected = Vector2(expected.x - relative.x * DEGREES_PER_PX, clampf(expected.y - relative.y * DEGREES_PER_PX, controls.min_pitch, controls.max_pitch))
			_slide(controls, index, to)
			last = to
			var other := _other(controls) + (", paused" if _pauses != pauses else "")
			if not controls.get_camera_rotation().is_equal_approx(expected) or other != "":
				_touch(controls, index, to, false)
				return _fail("%s, at %s on its way to %s, must turn the camera to %s and press nothing (camera %s%s)" % [label, to, path[leg], expected, controls.get_camera_rotation(), other])
	_touch(controls, index, last, false)
	if _other(controls) != "" or _pauses != pauses:
		return _fail("%s, lifted at %s, left%s (pauses %d)" % [label, last, _other(controls), _pauses - pauses])
	return true


## What a look finger must not do: move, press or touch a control, or pause.
func _other(controls: TouchControls) -> String:
	var found := ""
	if not controls.get_movement_vector().is_zero_approx():
		found += ", the stick moved"
	if not _held().is_empty():
		found += ", %s held" % [_held()]
	if controls.use_button.is_touched():
		found += ", the use button touched"
	return found


## The grid's points (GRID over the screen) at least CLEAR_PX from every control
## the player sees: the stick, RISE and RUN, the use button while it shows, and the
## pause disc.
func _free_points(controls: TouchControls) -> Array[Vector2]:
	var rects: Array[Rect2] = []
	for child: Node in controls.get_children():
		var control := child as Control
		if control != null and control.is_visible_in_tree():
			rects.append(control.get_global_rect().grow(CLEAR_PX))
	var pause: Array = controls.describe().pause
	var disc := Vector2(pause[0], pause[1])
	var free: Array[Vector2] = []
	for row in GRID.y:
		for col in GRID.x:
			var at := (Vector2(col, row) + Vector2(0.5, 0.5)) * controls.size / Vector2(GRID)
			if at.distance_to(disc) > TouchControls.PAUSE_RADIUS_PX + CLEAR_PX and rects.all(func(rect: Rect2) -> bool: return not rect.has_point(at)):
				free.append(at)
	return free


static func _nearest(points: Array[Vector2], to: Vector2) -> Vector2:
	var best := points[0]
	for at: Vector2 in points:
		if at.distance_to(to) < best.distance_to(to):
			best = at
	return best


static func _centre(controls: TouchControls, control: String) -> Vector2:
	var at: Array = controls.describe()[control]
	return Vector2(float(at[0]), float(at[1]))


static func _held() -> Array:
	return ACTIONS.filter(func(action: StringName) -> bool: return Input.is_action_pressed(action))


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


func _slide(controls: Control, index: int, position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position
	controls._input(event)


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
