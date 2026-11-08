class_name TouchUseButton
extends Control
## The touch controls' context button, above RISE (touch_controls.gd decides what
## it shows). On the ground beside a car the player could get into, it shows a
## car (DRIVE), and in a car the car again (GET OUT): a tap there is one press of
## F (vehicle_enter_exit), held until a physics tick has read it and then let go,
## so a quick tap is never missed and a finger left on it never toggles twice. In
## the air it shows a down arrow (DROP): holding it holds C (fast_drop) until the
## finger lifts or the touch is cancelled, and whenever the button changes or
## hides (landing, pausing) it lets go, so C is never left held. Hidden otherwise.
## A second finger pressed on it while it is held is taken too, doing nothing, so
## it can't become a look drag.
## It looks like the vendored RISE and RUN buttons: a white ring and glyph
## (tools/draw_touch_icons.sh) tinted as they are, blue while touched, and its
## label underneath.

enum Mode { HIDDEN, ENTER, EXIT, DROP }

const CAR_ICON := preload("res://game/resources/ui/touch/icon-car.png")
const DROP_ICON := preload("res://game/resources/ui/touch/icon-drop.png")
const ICONS := {Mode.ENTER: CAR_ICON, Mode.EXIT: CAR_ICON, Mode.DROP: DROP_ICON}
const LABELS := {Mode.ENTER: "DRIVE", Mode.EXIT: "GET OUT", Mode.DROP: "DROP"}
const ACTIONS := {Mode.ENTER: &"vehicle_enter_exit", Mode.EXIT: &"vehicle_enter_exit", Mode.DROP: &"fast_drop"}

var default_color := Color(0.9, 0.9, 0.9, 0.85)
var active_color := Color("00c3ff")
var mode := Mode.HIDDEN
var _icon: TextureRect
var _touch_index := -1
## The action this button holds now (&"" none), and the physics frame a tap's F
## went down in.
var _held := &""
var _tap_frame := -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon = TextureRect.new()
	_icon.name = "Icon"
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon)
	_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_refresh()


## What the button offers; a change lets go of the finger and anything it holds.
func set_mode(next: Mode) -> void:
	if next == mode:
		return
	release()
	mode = next
	visible = mode != Mode.HIDDEN
	_refresh()


## "hidden", "enter", "exit" or "drop" (tests and the web state read it).
func mode_name() -> String:
	return str(Mode.keys()[mode]).to_lower()


func is_touched() -> bool:
	return _touch_index != -1


## Lets go of the finger and of whatever it holds, at once.
func release() -> void:
	_touch_index = -1
	_let_go()
	_refresh()


## Takes a finger pressed on the visible button (true: the event is this
## button's) and follows that finger's lift or cancel.
func handle_input(event: InputEvent) -> bool:
	var touch := event as InputEventScreenTouch
	if touch == null:
		return false
	if touch.pressed and not touch.canceled:
		if mode == Mode.HIDDEN or not is_visible_in_tree() or not get_global_rect().has_point(touch.position):
			return false
		if _touch_index != -1:
			return true
		_touch_index = touch.index
		_let_go()
		_held = ACTIONS[mode]
		_tap_frame = Engine.get_physics_frames()
		Input.action_press(_held)
		_refresh()
		return true
	if touch.index == _touch_index:
		_touch_index = -1
		# A tap's F stays down until a physics tick has read it (_process).
		if _held == &"fast_drop":
			_let_go()
		_refresh()
	return false


func _process(_delta: float) -> void:
	# The physics frame count goes up as each tick starts, before the vehicles
	# read F in it; once it has passed the tap's frame, a tick has seen the press.
	if _held == &"vehicle_enter_exit" and Engine.get_physics_frames() > _tap_frame:
		_let_go()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		release()


func _exit_tree() -> void:
	release()


func _let_go() -> void:
	if _held != &"":
		Input.action_release(_held)
		_held = &""


func _refresh() -> void:
	if _icon == null:
		return
	_icon.texture = ICONS.get(mode)
	_icon.modulate = active_color if _touch_index != -1 else default_color
	queue_redraw()


func _draw() -> void:
	if mode == Mode.HIDDEN:
		return
	# The same font, size and baseline as the RISE and RUN labels, centred.
	draw_string(ThemeDB.fallback_font, Vector2(0, 122), LABELS[mode], HORIZONTAL_ALIGNMENT_CENTER, size.x, 20, Color.WHITE)
