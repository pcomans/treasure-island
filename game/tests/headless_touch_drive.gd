extends SceneTree
## Getting into a car on a phone (owner's report, 2026-11-11: on an iPhone held
## upright the keyboard's "F  Drive" showed under RUN, and no touch button got the
## player into the vans beside it). Headless in the generated world (run with
## --fixed-fps 60), with the touch controls and the 720 px layout that main.gd
## gives a touch browser, in an iPhone's Safari window held upright (the owner's
## screenshot) and then turned sideways. At each:
##   - the touch pause button, then Resume, as the player taps them (the shipped
##     fault: Resume showed the HUD's prompt, whose label still held the scene's
##     "F  Drive", and nothing on a touch screen ever cleared it);
##   - beside a parked car of every drivable body (street_clutter_kit.gd
##     CAR_BODIES; a different car at each shape) the use button shows DRIVE: the
##     car icon, inside the screen and clear of the stick, RUN, RISE, the pause
##     button and their labels; a tap gets the player into that car, where it shows
##     GET OUT, inside and clear the same way, also after a pause and Resume there;
##     a tap gets the player out again;
##   - at every step no keyboard prompt shows (a touch screen has no F key), and
##     nothing else of the HUD lies over a touch control.
## The first failure stops the run.

const TOUCH_CONTROLS := preload("res://game/scripts/ui/touch_controls.gd")
const KIT := preload("res://game/scripts/world/street_clutter_kit.gd")
const PHYSICS_WORLD_SOLID := 1
const PHYSICS_STREET_PROP := 1 << 3
## An iPhone's Safari page in device pixels: upright as in the owner's screenshot
## (1206 px wide, 2148 px under the status bar and over the address bar), and
## sideways (874 x 370 points at 3x).
const SHAPES := {"upright": Vector2i(1206, 2148), "sideways": Vector2i(2622, 1110)}
## The layout main.gd gives a touch browser (its _ready): 720 px or more each way.
const TOUCH_LAYOUT := Vector2i(720, 720)
## The labels drawn under the buttons (touch_controls.gd and touch_use_button.gd:
## 20 px type on a baseline 122 px below a button's top), and under the stick's
## ring (MOVE, 8 px below it): how far each reaches below its control.
const BUTTON_LABEL_PX := 32.0
const STICK_LABEL_PX := 16.0
## The pause button's disc (touch_controls.gd: its radius and its tap radius).
const PAUSE_RADIUS_PX := 34.0
## A spot to stand beside a car: this far out from its parked box (m), with every
## other car more than the vehicles' reach plus this margin away.
const BESIDE_M := 0.75
const OTHER_CAR_MARGIN_M := 0.5
## The highest a spot's ground may stand above or below the car's wheels (m).
const GROUND_STEP_M := 0.6

var _failure := ""
var _main: GameMain
var _touch: TouchControls
var _vehicles: VehicleManager
## The parked cars got into so far, by row id: each shape uses others.
var _used := {}
var _checked: Array[String] = []


func _initialize() -> void:
	create_timer(600.0, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	root.content_scale_size = TOUCH_LAYOUT
	root.size = SHAPES.upright
	_main = (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	_main.capture_mouse_on_ready = false
	var load_failures: Array[String] = []
	(_main.get_node("WorldRoot") as WorldLoader).world_failed.connect(func(code: String, message: String, _keys: Array) -> void: load_failures.append("%s: %s" % [code, message]))
	root.add_child(_main)
	_touch = _add_touch_controls()
	var started := Time.get_ticks_msec()
	while not _main.is_play_ready() and load_failures.is_empty() and Time.get_ticks_msec() - started < 180000:
		await process_frame
	if not _require(load_failures.is_empty() and _main.is_play_ready(), "World did not reach play: %s" % [load_failures]):
		return _finish()
	# As main.gd starts play on a touch browser.
	_touch.set_gameplay_active(true)
	_vehicles = _main.vehicles
	if not _require(_vehicles != null and _touch.vehicles == _vehicles, "main.gd did not hand the touch controls the cars."):
		return _finish()
	for _tick in 10:
		await physics_frame
	await process_frame
	if not _check_hud("at the start"):
		return _finish()
	for shape: String in SHAPES:
		if not await _check_shape(shape):
			return _finish()
	print("PASS: touch drive: held upright (%s) and sideways (%s), the touch pause button and Resume left no keyboard prompt and nothing of the HUD over the touch controls; beside a parked %s, a different car at each shape, DRIVE showed the car inside the screen and clear of the stick, RUN, RISE and the pause button and their labels, a tap got the player in, GET OUT showed the same way there (also after a pause and Resume) and a tap got the player out; no keyboard prompt at any step (%d checks)" % [_size_text("upright"), _size_text("sideways"), ", ".join(PackedStringArray(KIT.CAR_BODIES)), _checked.size()])
	_finish()


## The touch controls as main.gd's _ready adds them on a touch browser (where
## navigator.maxTouchPoints > 0), before the world is ready: its _on_world_ready
## then hands them the cars and tells the cars there is no F key, and its pause and
## Resume treat the game as a touch screen's.
func _add_touch_controls() -> TouchControls:
	var touch := TOUCH_CONTROLS.new() as TouchControls
	touch.name = "TouchControls"
	touch.camera_rig = _main.player.camera_rig
	touch.player = _main.player
	_main.hud.add_child(touch)
	touch.set_gameplay_active(false)
	touch.pause_requested.connect(func() -> void: _main._set_paused(true))
	_main.hud.set_touch_instructions()
	_main._touch_controls = touch
	return touch


## One window shape: the page turned to it, a pause and Resume, then every
## drivable body.
func _check_shape(shape: String) -> bool:
	root.size = SHAPES[shape]
	for _frame in 2:
		await process_frame
	var screen := _main.hud.get_viewport_rect().size
	var upright := shape == "upright"
	if not _require((screen.y > screen.x) == upright and is_equal_approx(minf(screen.x, screen.y), float(TOUCH_LAYOUT.x)), "The %s page laid out at %s, not %s with its short side %d px." % [shape, screen, "upright" if upright else "sideways", TOUCH_LAYOUT.x]):
		return false
	if not await _pause_and_resume(shape) or not _check_hud("%s, after the pause and Resume" % shape):
		return false
	for body: String in KIT.CAR_BODIES:
		if not await _drive(shape, body):
			return false
	return true


## Beside a parked car of this body: DRIVE, a tap in, GET OUT (and after a pause
## and Resume), a tap out.
func _drive(shape: String, body: String) -> bool:
	var spot := _spot_beside_car(body)
	if not _require(not spot.is_empty(), "No parked %s left with room to stand beside it on its own." % body):
		return false
	var id: String = spot.id
	_used[id] = true
	var label := "%s, beside the %s %s" % [shape, body, id]
	if not await _stand_player(spot.at, label):
		return false
	if not _require(_vehicles.can_enter(), "%s at %s: the car is not within reach." % [label, _main.player.global_position]) \
	or not _check_use(label, TouchUseButton.Mode.ENTER):
		return false
	print("TOUCH_DRIVE %s %s %s: standing at %s, DRIVE at %s" % [shape, body, id, _main.player.global_position, _touch.use_button.get_global_rect()])
	await _tap_use()
	await _ticks(30)
	var car := _vehicles.active_car()
	if not _require(car != null and car.row_id == id, "%s: a tap on DRIVE did not get the player into it (in %s)." % [label, car.row_id if car != null else "no car"]) \
	or not _check_use("%s, in it" % label, TouchUseButton.Mode.EXIT) \
	or not await _pause_and_resume("%s, in it" % label) \
	or not _check_use("%s, in it after the pause and Resume" % label, TouchUseButton.Mode.EXIT):
		return false
	await _tap_use()
	await _ticks(45)
	if not _require(not _vehicles.is_driving() and not _main.player.is_driving() and _main.player.is_on_floor(), "%s: a tap on GET OUT did not get the player out onto the ground (driving %s, on the floor %s)." % [label, _vehicles.is_driving(), _main.player.is_on_floor()]):
		return false
	print("TOUCH_DRIVE %s %s %s: out at %s, the button %s" % [shape, body, id, _main.player.global_position, _touch.use_button.mode_name()])
	# Out beside the car, DRIVE again.
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


## Where each touch control the player sees lies, in the HUD's pixels: the stick's
## ring and the buttons with the labels drawn under them, and the pause disc.
func _footprints() -> Dictionary:
	var parts := {}
	var stick := _touch.get_node("MoveStick") as Control
	if stick.is_visible_in_tree():
		parts["the stick"] = stick.get_global_rect().grow_side(SIDE_BOTTOM, STICK_LABEL_PX)
	for child: Node in _touch.get_children():
		var button := child as SelgeselVirtualButton
		if button != null and button.is_visible_in_tree():
			parts["RISE" if button.action == "jetpack" else button.action.to_upper()] = button.get_global_rect().grow_side(SIDE_BOTTOM, BUTTON_LABEL_PX)
	if _touch.use_button.is_visible_in_tree():
		parts["use"] = _touch.use_button.get_global_rect().grow_side(SIDE_BOTTOM, BUTTON_LABEL_PX)
	var pause: Array = _touch.describe().pause
	parts["the pause button"] = Rect2(Vector2(pause[0], pause[1]) - Vector2.ONE * PAUSE_RADIUS_PX, Vector2.ONE * PAUSE_RADIUS_PX * 2.0)
	return parts


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


## A parked car of this body not got into yet, and a spot beside it where the
## stock player stands with that car alone in the vehicles' reach: off its right
## or left side, or its back or front, BESIDE_M out from its parked box, on the
## world's ground about level with its wheels (not on a car or another prop), with
## room for the player. {"id", "at"}, or {} if there is none.
func _spot_beside_car(body: String) -> Dictionary:
	var ids := _vehicles.swappable_ids().filter(func(id: String) -> bool:
		var row := _vehicles.row(id)
		return str(row.prop) == "parked_car" and str((row.params as Dictionary).get("body", "")) == body and not _used.has(id))
	ids.sort()
	for id: String in ids:
		var box := _parked_box(id)
		if box.is_empty():
			continue
		var half: Vector3 = box.half
		var xf: Transform3D = box.xf
		for side: Vector3 in [Vector3(half.x + BESIDE_M, 0.0, 0.0), Vector3(-half.x - BESIDE_M, 0.0, 0.0), Vector3(0.0, 0.0, half.z + BESIDE_M), Vector3(0.0, 0.0, -half.z - BESIDE_M)]:
			var at: Vector3 = xf * side
			if _other_car_in_reach(id, at):
				continue
			var ground := _open_ground(at, xf.origin.y - half.y)
			if ground.is_finite():
				return {"id": id, "at": ground}
	return {}


## A parked car's collision box (street_clutter_builder.gd: one box over its body,
## its floor on the ground): its transform and half size, or {}.
func _parked_box(id: String) -> Dictionary:
	var shapes: Array = _vehicles.row(id).get("shapes", [])
	var clutter := _main.world_root.street_detail_layer("clutter").get_node_or_null("GeneratedStreetClutter")
	if clutter == null or shapes.is_empty():
		return {}
	var body := clutter.get_node_or_null(str(shapes[0][0]))
	var shape := body.get_node_or_null(str(shapes[0][1])) as CollisionShape3D if body != null else null
	var box := shape.shape as BoxShape3D if shape != null else null
	if box == null:
		return {}
	return {"xf": shape.global_transform, "half": box.size * 0.5}


## Whether another parked car's box is within the vehicles' reach (and a margin)
## of this point, in plan.
func _other_car_in_reach(id: String, at: Vector3) -> bool:
	for other: String in _vehicles.swappable_ids():
		if other == id or str(_vehicles.row(other).prop) != "parked_car":
			continue
		var origin := (_vehicles.row(other).transform as Transform3D).origin
		if Vector2(origin.x - at.x, origin.z - at.z).length() > 12.0:
			continue
		var box := _parked_box(other)
		if box.is_empty():
			continue
		var local: Vector3 = (box.xf as Transform3D).affine_inverse() * at
		var half: Vector3 = box.half
		if Vector2(maxf(0.0, absf(local.x) - half.x), maxf(0.0, absf(local.z) - half.z)).length() < VehicleManager.ENTER_REACH_M + OTHER_CAR_MARGIN_M:
			return true
	return false


## The world's ground under this point, if the stock player can stand there: the
## first solid straight down is the world's (not a street prop's), within
## GROUND_STEP_M of the car's wheels, with room for the player's capsule. INF if not.
func _open_ground(at: Vector3, wheels_y: float) -> Vector3:
	var player := _main.player
	var space := _main.get_world_3d().direct_space_state
	var ray := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 3.0, at + Vector3.DOWN * 3.0, player.collision_mask, [player.get_rid()])
	ray.hit_back_faces = false
	var hit := space.intersect_ray(ray)
	var collider := hit.get("collider") as CollisionObject3D
	if collider == null or (collider.collision_layer & PHYSICS_WORLD_SOLID) == 0 or (collider.collision_layer & PHYSICS_STREET_PROP) != 0:
		return Vector3.INF
	var ground: Vector3 = hit.position
	if absf(ground.y - wheels_y) > GROUND_STEP_M:
		return Vector3.INF
	var room := PhysicsShapeQueryParameters3D.new()
	room.shape = player.collision_shape.shape
	room.transform = Transform3D(Basis.IDENTITY, ground + player.collision_shape.position + Vector3.UP * 0.15)
	room.collision_mask = player.collision_mask
	room.exclude = [player.get_rid()]
	return Vector3.INF if not space.intersect_shape(room, 1).is_empty() else ground


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
	var scale := float(TOUCH_LAYOUT.x) / float(mini(window.x, window.y))
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
