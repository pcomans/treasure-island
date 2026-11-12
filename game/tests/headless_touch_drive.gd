extends SceneTree
## Getting into a car on a phone (owner's report, 2026-11-11: on an iPhone held
## upright the keyboard's "F  Drive" showed under RUN, and no touch button got the
## player into the vans beside it). Headless in the generated world (run with
## --fixed-fps 60): main set up for touch play by its own use_touch_controls(), as
## on a touch browser, in an iPhone's Safari window held upright (the owner's
## screenshot) and then turned sideways. At each:
##   - the touch pause button, then Resume, as the player taps them (the shipped
##     fault: Resume showed the HUD's prompt, whose label still held the scene's
##     "F  Drive", and nothing on a touch screen ever cleared it);
##   - the touch pause button, the pause menu's Credits and its Licences (owner,
##     2026-11-12): each view lies inside the page with thumb-sized
##     buttons and a finger's drag scrolls it; Back twice and Resume play on;
##   - beside a parked vehicle of every drivable body (the street cars',
##     street_clutter_kit.gd CAR_BODIES, and the storage yards' vans, trucks and
##     RVs, vehicle_spots.gd yard_bodies(); a different one at each shape where
##     the world has another) the use button shows DRIVE: the car icon, inside
##     the screen and clear of the stick, RUN, RISE, the pause button and their
##     labels; a tap gets the player into that vehicle, where it shows GET OUT,
##     inside and clear the same way, also after a pause and Resume there; a tap
##     gets the player out;
##   - at every step no keyboard prompt shows (a touch screen has no F key), and
##     nothing else of the HUD lies over a touch control.
## The first failure stops the run.

const SPOTS := preload("res://game/tests/shared/vehicle_spots.gd")
const KIT := preload("res://game/scripts/world/street_clutter_kit.gd")
## An iPhone's Safari page in device pixels: upright as in the owner's screenshot
## (1206 px wide, 2148 px under the status bar and over the address bar), and
## sideways (874 x 370 points at 3x).
const SHAPES := {"upright": Vector2i(1206, 2148), "sideways": Vector2i(2622, 1110)}
## The height of a menu button on a touch screen (hud.gd's set_touch_instructions),
## and how far a finger drags the credits.
const THUMB_PX := 64.0
const CREDITS_DRAG_PX := 120.0

var _failure := ""
var _main: GameMain
var _touch: TouchControls
var _vehicles: VehicleManager
## The parked vehicles got into so far, by row id: each shape uses others where
## the world has them.
var _used := {}
var _checked: Array[String] = []


func _initialize() -> void:
	create_timer(900.0, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	root.size = SHAPES.upright
	_main = (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	_main.capture_mouse_on_ready = false
	var load_failures: Array[String] = []
	(_main.get_node("WorldRoot") as WorldLoader).world_failed.connect(func(code: String, message: String, _keys: Array) -> void: load_failures.append("%s: %s" % [code, message]))
	root.add_child(_main)
	# As main.gd's _ready does on a touch browser, before the world is ready.
	_touch = _main.use_touch_controls()
	var started := Time.get_ticks_msec()
	while not _main.is_play_ready() and load_failures.is_empty() and Time.get_ticks_msec() - started < 180000:
		await process_frame
	if not _require(load_failures.is_empty() and _main.is_play_ready(), "World did not reach play: %s" % [load_failures]):
		return _finish()
	_vehicles = _main.vehicles
	if not _require(_vehicles != null and _touch.vehicles == _vehicles and _touch.visible, "main.gd did not hand the touch controls the cars and start them (visible %s)." % _touch.visible):
		return _finish()
	await _ticks(10)
	if not _check_hud("at the start"):
		return _finish()
	for shape: String in SHAPES:
		if not await _check_shape(shape):
			return _finish()
	print("PASS: touch drive: held upright (%s) and sideways (%s), the touch pause button and Resume left no keyboard prompt and nothing of the HUD over the touch controls, nor did Credits and its Licences, which lay inside the page with thumb-sized buttons and scrolled under a finger; beside a parked %s, a different one at each shape where the world has another, DRIVE showed the car inside the screen and clear of the stick, RUN, RISE and the pause button and their labels, a tap got the player in, GET OUT showed the same way there (also after a pause and Resume) and a tap got the player out; no keyboard prompt at any step (%d checks)" % [_size_text("upright"), _size_text("sideways"), ", ".join(PackedStringArray(_bodies())), _checked.size()])
	_finish()


## One window shape: the page turned to it, a pause and Resume, then every
## drivable body.
func _check_shape(shape: String) -> bool:
	root.size = SHAPES[shape]
	for _frame in 2:
		await process_frame
	var screen := _main.hud.get_viewport_rect().size
	var upright := shape == "upright"
	if not _require((screen.y > screen.x) == upright and is_equal_approx(minf(screen.x, screen.y), float(GameMain.TOUCH_LAYOUT_PX)), "The %s page laid out at %s, not %s with its short side %d px." % [shape, screen, "upright" if upright else "sideways", GameMain.TOUCH_LAYOUT_PX]):
		return false
	if not await _pause_and_resume(shape) or not _check_hud("%s, after the pause and Resume" % shape) \
	or not await _credits_and_resume(shape):
		return false
	for body: String in _bodies():
		if not await _drive(shape, body):
			return false
	return true


## Every drivable body: the street cars' and the yards' vehicles'.
func _bodies() -> Array:
	return KIT.CAR_BODIES + SPOTS.yard_bodies()


## Beside a parked vehicle of this body: DRIVE, a tap in, GET OUT (and after a
## pause and Resume), a tap out.
func _drive(shape: String, body: String) -> bool:
	var spot := SPOTS.beside(_main, _vehicles, body, _used)
	if not _require(not spot.is_empty(), "No parked %s left with room to stand beside it on its own." % body):
		return false
	var id: String = spot.id
	_used[id] = true
	var label := "%s, beside the %s %s" % [shape, body, id]
	if not await _stand_player(spot.at, label):
		return false
	if not _require(_vehicles.can_enter(), "%s at %s: the vehicle is not within reach." % [label, _main.player.global_position]) \
	or not _check_use(label, TouchUseButton.Mode.ENTER):
		return false
	print("TOUCH_DRIVE %s %s %s: standing at %s, DRIVE at %s" % [shape, body, id, _main.player.global_position, _touch.use_button.get_global_rect()])
	await _tap_use()
	await _ticks(30)
	var car := _vehicles.active_car()
	if not _require(car != null and car.row_id == id and car.body == body, "%s: a tap on DRIVE did not get the player into it (in %s)." % [label, car.row_id if car != null else "no car"]) \
	or not _check_use("%s, in it" % label, TouchUseButton.Mode.EXIT) \
	or not await _pause_and_resume("%s, in it" % label) \
	or not _check_use("%s, in it after the pause and Resume" % label, TouchUseButton.Mode.EXIT):
		return false
	await _tap_use()
	await _ticks(45)
	if not _require(not _vehicles.is_driving() and not _main.player.is_driving() and _main.player.is_on_floor(), "%s: a tap on GET OUT did not get the player out onto the ground (driving %s, on the floor %s)." % [label, _vehicles.is_driving(), _main.player.is_on_floor()]):
		return false
	print("TOUCH_DRIVE %s %s %s: out at %s, the button %s" % [shape, body, id, _main.player.global_position, _touch.use_button.mode_name()])
	# Out beside the vehicle, DRIVE again.
	return _check_use("%s, out again" % label, TouchUseButton.Mode.ENTER) if _vehicles.can_enter() else _check_hud("%s, out again" % label)


## The use button in this mode as the player sees it: the car icon, inside the
## screen and clear of every other touch control the player sees; then the HUD
## (_check_hud).
func _check_use(label: String, mode: TouchUseButton.Mode) -> bool:
	var use := _touch.use_button
	var icon := use.get_node("Icon") as TextureRect
	if not _require(use.mode == mode and use.is_visible_in_tree() and icon.texture == TouchUseButton.CAR_ICON, "%s: the use button must show %s with the car (it shows %s, visible %s)." % [label, TouchUseButton.LABELS[mode], use.mode_name(), use.is_visible_in_tree()]):
		return false
	var parts := _footprints()
	var at: Rect2 = parts.use
	var screen := Rect2(Vector2.ZERO, _main.hud.get_viewport_rect().size)
	if not _require(screen.encloses(at), "%s: %s at %s is not inside the screen %s." % [label, TouchUseButton.LABELS[mode], at, screen]):
		return false
	for part: String in parts:
		if part != "use" and at.intersects(parts[part]):
			return _require(false, "%s: %s at %s overlaps %s at %s." % [label, TouchUseButton.LABELS[mode], at, part, parts[part]])
	return _check_hud(label)


## No keyboard prompt on a touch screen, and nothing else the HUD shows lies over
## a touch control the player sees.
func _check_hud(label: String) -> bool:
	_checked.append(label)
	var hud := _main.hud
	if not _require(not hud.prompt_panel.is_visible_in_tree(), "%s: the keyboard prompt \"%s\" shows on a touch screen." % [label, hud.prompt_text.text]):
		return false
	var parts := _footprints()
	for child: Node in hud.get_children():
		var control := child as Control
		if control == null or control == _touch or not control.is_visible_in_tree():
			continue
		var rect := control.get_global_rect()
		for part: String in parts:
			if rect.intersects(parts[part]):
				return _require(false, "%s: the HUD's %s at %s lies over the touch %s at %s." % [label, control.name, rect, part, parts[part]])
	return true


## Where each touch control the player sees lies, in the HUD's pixels: the
## stick's ring and the buttons down to the bottom of the labels drawn under them
## (touch_controls.gd STICK_LABEL_AT, touch_use_button.gd LABEL_BASELINE_PX, in
## the fallback font at LABEL_FONT_SIZE), and the pause disc (PAUSE_RADIUS_PX).
func _footprints() -> Dictionary:
	var descent := ThemeDB.fallback_font.get_descent(TouchUseButton.LABEL_FONT_SIZE)
	var parts := {}
	var stick := _touch.get_node("MoveStick") as Control
	if stick.is_visible_in_tree():
		parts["the stick"] = _down_to(stick.get_global_rect(), TouchControls.STICK_LABEL_AT.y + descent)
	for child: Node in _touch.get_children():
		var button := child as SelgeselVirtualButton
		if button != null and button.is_visible_in_tree():
			parts["RISE" if button.action == "jetpack" else button.action.to_upper()] = _down_to(button.get_global_rect(), TouchUseButton.LABEL_BASELINE_PX + descent)
	if _touch.use_button.is_visible_in_tree():
		parts["use"] = _down_to(_touch.use_button.get_global_rect(), TouchUseButton.LABEL_BASELINE_PX + descent)
	var pause: Array = _touch.describe().pause
	parts["the pause button"] = Rect2(Vector2(pause[0], pause[1]) - Vector2.ONE * TouchControls.PAUSE_RADIUS_PX, Vector2.ONE * TouchControls.PAUSE_RADIUS_PX * 2.0)
	return parts


## A control's rect reaching at least this far below its top (its label).
static func _down_to(rect: Rect2, below: float) -> Rect2:
	return rect.grow_side(SIDE_BOTTOM, maxf(0.0, below - rect.size.y))


## The touch pause button, then the pause menu's Resume, as the player taps them
## (from the idle step, where input arrives).
func _pause_and_resume(label: String) -> bool:
	await process_frame
	var at: Array = _touch.describe().pause
	_finger(4, Vector2(at[0], at[1]), true)
	_finger(4, Vector2(at[0], at[1]), false)
	if not _require(paused and _main.hud.pause_panel.visible and not _touch.visible, "%s: the touch pause button did not pause (paused %s, menu %s)." % [label, paused, _main.hud.pause_panel.visible]):
		return false
	_main.hud.resume_button.pressed.emit()
	await process_frame
	if not _require(not paused and _touch.visible, "%s: Resume did not go back to play." % label):
		return false
	await _ticks(5)
	return true


## The pause menu's Credits on a phone, as the player taps it: the touch pause
## button, Credits, then Licences. Each view lies inside the page, the
## game still paused, with its buttons at least THUMB_PX tall, and a finger dragging
## it up scrolls it as far. Back twice returns to the pause menu, and Resume to play,
## where no keyboard prompt shows and nothing of the HUD lies over a touch control.
func _credits_and_resume(shape: String) -> bool:
	await process_frame
	var hud := _main.hud
	var at: Array = _touch.describe().pause
	_finger(4, Vector2(at[0], at[1]), true)
	_finger(4, Vector2(at[0], at[1]), false)
	if not _require(paused and hud.pause_panel.visible, "%s: the touch pause button did not pause before Credits." % shape):
		return false
	hud.credits_button.pressed.emit()
	for view: ScrollContainer in [hud.credits_list, hud.credits_licences]:
		if view == hud.credits_licences:
			hud.credits_licences_button.pressed.emit()
		for _frame in 2:
			await process_frame
		var label := "%s, the credits' %s" % [shape, "Licences" if view == hud.credits_licences else "list"]
		var page := Rect2(Vector2.ZERO, hud.get_viewport_rect().size)
		var panel := hud.credits_panel.get_global_rect()
		if not _require(paused and hud.credits_visible() and view.is_visible_in_tree() and page.encloses(panel), "%s: shows at %s, not inside the page %s (paused %s)." % [label, panel, page, paused]):
			return false
		for button: Button in [hud.credits_licences_button, hud.credits_back_button]:
			if button.is_visible_in_tree() and not _require(button.size.y >= THUMB_PX and panel.encloses(button.get_global_rect()), "%s: %s must lie in the panel and be at least %d px tall (%s)." % [label, button.text, THUMB_PX, button.get_global_rect()]):
				return false
		var bar := view.get_v_scroll_bar()
		var expected := minf(CREDITS_DRAG_PX, bar.max_value - bar.page)
		if expected >= 1.0:
			_screen_drag(5, view.get_global_rect().get_center() + Vector2(0.0, CREDITS_DRAG_PX * 0.5), -CREDITS_DRAG_PX)
			await process_frame
			if not _require(absf(bar.value - expected) <= 1.0, "%s: a finger dragging up %.0f px scrolled it %.0f px, not %.0f." % [label, CREDITS_DRAG_PX, bar.value, expected]):
				return false
	hud.credits_back_button.pressed.emit()
	hud.credits_back_button.pressed.emit()
	if not _require(paused and not hud.credits_visible() and hud.pause_panel.visible, "%s: Back twice on the Licences must go back to the pause menu, still paused." % shape):
		return false
	hud.resume_button.pressed.emit()
	await process_frame
	if not _require(not paused and _touch.visible, "%s: Resume after the credits did not go back to play." % shape):
		return false
	await _ticks(5)
	return _check_hud("%s, after the credits and Resume" % shape)


## A finger down at `from`, dragged `by` px down (negative: up) and lifted, through
## the HUD's window as a touch screen sends it (in the HUD's pixels).
func _screen_drag(index: int, from: Vector2, by: float) -> void:
	var touch := InputEventScreenTouch.new()
	touch.index = index
	touch.position = from
	touch.pressed = true
	root.push_input(touch, true)
	var drag := InputEventScreenDrag.new()
	drag.index = index
	drag.relative = Vector2(0.0, by)
	drag.position = from + drag.relative
	root.push_input(drag, true)
	touch = touch.duplicate() as InputEventScreenTouch
	touch.position = drag.position
	touch.pressed = false
	root.push_input(touch, true)


## The stock player standing still on the ground here, walking enabled.
func _stand_player(at: Vector3, label: String) -> bool:
	var player := _main.player
	player.set_gameplay_enabled(false)
	player.global_transform = Transform3D(Basis.IDENTITY, at + Vector3.UP * 0.1)
	player.velocity = Vector3.ZERO
	player.set_gameplay_enabled(true)
	for _tick in 90:
		await physics_frame
		if player.is_on_floor() and player.velocity.length() < 0.05:
			await _ticks(5)
			return true
	return _require(false, "%s: the player did not settle at %s." % [label, at])


## A quick tap on the use button, lifted before any physics tick.
func _tap_use() -> void:
	var at := _touch.use_button.get_global_rect().get_center()
	_finger(9, at, true)
	_finger(9, at, false)
	await _ticks(3)


func _finger(index: int, at: Vector2, down: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = at
	event.pressed = down
	_touch._input(event)


## Physics ticks, then an idle step, where the touch controls show what changed.
func _ticks(count: int) -> void:
	for _tick in count:
		await physics_frame
	await process_frame


func _size_text(shape: String) -> String:
	var window: Vector2i = SHAPES[shape]
	var scale := float(GameMain.TOUCH_LAYOUT_PX) / float(mini(window.x, window.y))
	return "%d x %d px" % [roundi(window.x * scale), roundi(window.y * scale)]


func _require(condition: bool, message: String) -> bool:
	if not condition and _failure == "":
		_failure = message
	return condition


func _on_timeout() -> void:
	if _failure == "":
		_failure = "The touch drive test timed out."
	_finish()


func _finish() -> void:
	for action: StringName in GameMain.GAMEPLAY_ACTIONS:
		Input.action_release(action)
	if _failure != "":
		push_error("FAIL: " + _failure)
		print("FAIL: " + _failure)
		quit(1)
	else:
		quit(0)
