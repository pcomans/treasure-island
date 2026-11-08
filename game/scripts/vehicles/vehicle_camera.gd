class_name VehicleCamera
extends Node3D
## The chase camera while the player drives (game/scripts/vehicles/vehicle_manager.gd):
## the player rig's own structure and settings, a pivot -> SpringArm3D ->
## Camera3D with the gameplay camera's field of view, near and far planes and
## the arm's margin (game/scenes/player/player.tscn). Its arm stops at the world
## and at street props, parked cars among them, so it never sits inside one; the
## driven car itself is left out. It is current only while driving; the on-foot
## rig (player_camera.gd) is left as it is.
##
## The pivot rides above the car as drawn this frame (the car's interpolated
## visual), so it moves smoothly whatever the frame rate, and never below the
## water's surface (a car sinking in the bay). Its yaw swings behind the car's
## heading, slowly when the car creeps and briskly at speed, and in the air it
## follows the flight instead of a tumbling car. With speed the view widens and
## the arm lengthens a little. Moving the mouse (with the pointer captured)
## glances round with the on-foot sensitivity and pitch limits; a second after
## the mouse stops, the view eases back behind the car.
##
## Getting in, the view moves from where the on-foot camera was to behind the
## car, the short way round, and stays there with the car parked; getting out,
## from here to the on-foot camera: a blend camera of its own carries the view
## between them, so neither change is a cut. It swings round the pivot over the
## car, level, rather than cutting across, so it never passes through the car,
## and its yaw and pitch ease with no roll.

const DRIVABLE_CAR := preload("res://game/scripts/vehicles/drivable_car.gd")
const PHYSICS_WORLD_SOLID := 1
const PHYSICS_STREET_PROP := 1 << 3
const PITCH_REST := deg_to_rad(-10.0)
const MIN_PITCH := deg_to_rad(-60.0)
const MAX_PITCH := deg_to_rad(25.0)
## Yaw follow time constants (s): creeping and at speed (FOLLOW_SPEED_MPS).
const FOLLOW_SLOW_S := 1.0
const FOLLOW_FAST_S := 0.3
const FOLLOW_SPEED_MPS := 10.0
## A glance holds this long after the mouse stops, then eases back (s).
const GLANCE_HOLD_S := 1.0
const GLANCE_RETURN_S := 0.45
## Field of view at rest; toward SPEED_FULL_MPS it widens by FOV_WIDEN degrees
## and the arm lengthens by PULL_BACK_M, easing in and out over SPEED_EASE_S.
const FOV := 70.0
const FOV_WIDEN := 10.0
const PULL_BACK_M := 1.2
const SPEED_FULL_MPS := 30.0
const SPEED_EASE_S := 0.5
## The blends getting in and out (s).
const ENTER_BLEND_S := 0.6
const EXIT_BLEND_S := 0.8
## The pivot stays at least this far over the water.
const WATER_CLEAR_M := 1.2

@export_range(0.0005, 0.01, 0.0001) var look_sensitivity := 0.003

var spring_arm: SpringArm3D
var camera: Camera3D
var _blend: Camera3D
var _car: DRIVABLE_CAR
var _yaw := 0.0
var _glance_yaw := 0.0
var _glance_pitch := 0.0
var _since_glance := 0.0
var _speed_share := 0.0
var _arm_length := 6.0
var _clearance := SphereShape3D.new()
var _query := PhysicsShapeQueryParameters3D.new()
var _blend_from := Transform3D.IDENTITY
## The point the blend swings round: the pivot over the car (followed while
## the car is held, kept where it was once let go).
var _blend_centre := Vector3.ZERO
var _blend_from_fov := FOV
var _blend_to: Camera3D
var _blend_t := -1.0
var _blend_s := ENTER_BLEND_S


func _init() -> void:
	top_level = true
	spring_arm = SpringArm3D.new()
	spring_arm.name = "SpringArm3D"
	spring_arm.margin = 0.15
	spring_arm.collision_mask = PHYSICS_WORLD_SOLID | PHYSICS_STREET_PROP
	spring_arm.rotation = Vector3(PITCH_REST, 0.0, 0.0)
	add_child(spring_arm)
	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.fov = FOV
	camera.near = 0.08
	camera.far = 5000.0
	spring_arm.add_child(camera)
	_blend = Camera3D.new()
	_blend.name = "BlendCamera"
	_blend.top_level = true
	_blend.near = camera.near
	_blend.far = camera.far
	add_child(_blend)
	_clearance.radius = 0.3
	spring_arm.shape = _clearance
	_query.shape = _clearance
	_query.margin = 0.001
	_query.collision_mask = 1


func _ready() -> void:
	set_process(false)
	set_process_unhandled_input(false)


## Takes over behind car, blending from from_camera (the view the player had)
## when there is one; with take_view false (a capture's own camera is showing)
## it follows the car without taking the view.
func attach(car: DRIVABLE_CAR, from_camera: Camera3D, take_view: bool = true) -> void:
	_car = car
	var forward := -car.visual_transform().basis.z
	_yaw = atan2(-forward.x, -forward.z) if Vector2(forward.x, forward.z).length() > 0.2 else 0.0
	_glance_yaw = 0.0
	_glance_pitch = 0.0
	_since_glance = GLANCE_HOLD_S
	_speed_share = 0.0
	_arm_length = 4.2 + 0.55 * car.length_m
	spring_arm.clear_excluded_objects()
	spring_arm.add_excluded_object(car.get_rid())
	_place(0.0, true)
	# The arm's end before its first physics update, so a blend starting now
	# heads for the view behind the car, not the pivot over it.
	camera.position = Vector3(0.0, 0.0, spring_arm.spring_length)
	if not take_view:
		_blend_t = -1.0
	elif from_camera != null and from_camera != camera:
		_start_blend(from_camera.global_transform, from_camera.fov, camera, ENTER_BLEND_S)
	else:
		_blend_t = -1.0
		camera.make_current()
	set_process(true)
	set_process_unhandled_input(true)


## Lets go of the car; while this rig's view is the one shown, blends it to
## to_camera. With blend false (a reset) to_camera shows at once.
func detach(to_camera: Camera3D, blend: bool = true) -> void:
	_car = null
	set_process_unhandled_input(false)
	var showing := get_viewport().get_camera_3d() if is_inside_tree() else null
	if to_camera == null:
		return
	if not blend:
		_blend_t = -1.0
		set_process(false)
		to_camera.make_current()
	elif showing == camera or showing == _blend:
		_start_blend(showing.global_transform, showing.fov, to_camera, EXIT_BLEND_S)
	else:
		# Another camera (a capture's) is showing: leave it be.
		_blend_t = -1.0
		set_process(false)


## True while the view is between the on-foot camera and this one.
func is_blending() -> bool:
	return _blend_t >= 0.0


## Ends a blend now: its target shows, unless another camera took over.
func finish_blend() -> void:
	if _blend_t < 0.0:
		return
	_blend_t = -1.0
	if _blend.current and _blend_to != null and is_instance_valid(_blend_to):
		_blend_to.make_current()


## The view's world yaw and pitch now (handed back to the on-foot rig).
func view_yaw() -> float:
	return _yaw + _glance_yaw


func view_pitch() -> float:
	return clampf(PITCH_REST + _glance_pitch, MIN_PITCH, MAX_PITCH)


func _unhandled_input(event: InputEvent) -> void:
	if _car == null or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		glance((event as InputEventMouseMotion).relative)


## Looks round by this much mouse motion; the view eases back after a moment.
func glance(relative: Vector2) -> void:
	_glance_yaw -= relative.x * look_sensitivity
	_glance_pitch = clampf(PITCH_REST + _glance_pitch - relative.y * look_sensitivity, MIN_PITCH, MAX_PITCH) - PITCH_REST
	_since_glance = 0.0


func _process(delta: float) -> void:
	if _car != null and is_instance_valid(_car):
		_place(delta, false)
	if _blend_t >= 0.0:
		_step_blend(delta)
	elif _car == null:
		set_process(false)


func _place(delta: float, snap: bool) -> void:
	var xf := _car.visual_transform()
	var velocity := _car.linear_velocity
	var planar := Vector2(velocity.x, velocity.z).length()
	# Behind the heading on the wheels; along the flight in the air.
	var target := _yaw
	if _car.grounded_wheels() > 0 or planar < 5.0:
		var forward := -xf.basis.z
		if Vector2(forward.x, forward.z).length() > 0.2:
			target = atan2(-forward.x, -forward.z)
	elif planar >= 5.0:
		target = atan2(-velocity.x, -velocity.z)
	var tau := lerpf(FOLLOW_SLOW_S, FOLLOW_FAST_S, clampf(planar / FOLLOW_SPEED_MPS, 0.0, 1.0))
	_yaw = target if snap else lerp_angle(_yaw, target, 1.0 - exp(-delta / tau))
	_since_glance += delta
	if _since_glance > GLANCE_HOLD_S and delta > 0.0:
		var ease := 1.0 - exp(-delta / GLANCE_RETURN_S)
		_glance_yaw = lerp_angle(_glance_yaw, 0.0, ease)
		_glance_pitch = lerpf(_glance_pitch, 0.0, ease)
	var speed_target := clampf(planar / SPEED_FULL_MPS, 0.0, 1.0)
	_speed_share = speed_target if snap else lerpf(_speed_share, speed_target, 1.0 - exp(-delta / SPEED_EASE_S))
	# The pivot above the car's roof, swept up from inside the car so a low
	# ceiling can't start the arm above it (as the on-foot rig does), and over
	# the water's surface.
	var floor_y := _car.water_y + WATER_CLEAR_M
	var anchor := xf.origin + Vector3.UP * (_car.height_m * 0.6)
	anchor.y = maxf(anchor.y, floor_y)
	var desired := xf.origin + Vector3.UP * (_car.height_m + 0.5)
	desired.y = maxf(desired.y, floor_y + 0.5)
	_query.transform = Transform3D(Basis.IDENTITY, anchor)
	_query.motion = desired - anchor
	_query.exclude = [_car.get_rid()]
	var fractions := get_world_3d().direct_space_state.cast_motion(_query) if is_inside_tree() else PackedFloat32Array([1.0, 1.0])
	global_position = anchor + _query.motion * clampf(fractions[0] - 0.01, 0.0, 1.0)
	rotation = Vector3(0.0, _yaw + _glance_yaw, 0.0)
	spring_arm.rotation = Vector3(view_pitch(), 0.0, 0.0)
	spring_arm.spring_length = _arm_length + PULL_BACK_M * _speed_share
	camera.fov = FOV + FOV_WIDEN * _speed_share


func _start_blend(from: Transform3D, from_fov: float, to: Camera3D, seconds: float) -> void:
	_blend_from = from
	_blend_centre = global_position
	_blend_from_fov = from_fov
	_blend_to = to
	_blend_s = seconds
	_blend_t = 0.0
	_blend.global_transform = from
	_blend.fov = from_fov
	_blend.make_current()
	set_process(true)


## Moves the blend camera along: eased from where the view was to the target
## camera wherever it is now; at the end the target shows, unless another
## camera took over meanwhile.
func _step_blend(delta: float) -> void:
	if _blend_to == null or not is_instance_valid(_blend_to):
		_blend_t = -1.0
		return
	_blend_t = minf(1.0, _blend_t + delta / _blend_s)
	var eased := _blend_t * _blend_t * (3.0 - 2.0 * _blend_t)
	var to := _blend_to.global_transform
	# Round the pivot, level: the plan offset's bearing turns and its length
	# and height ease.
	if _car != null and is_instance_valid(_car):
		_blend_centre = global_position
	var from_plan := Vector2(_blend_from.origin.x - _blend_centre.x, _blend_from.origin.z - _blend_centre.z)
	var to_plan := Vector2(to.origin.x - _blend_centre.x, to.origin.z - _blend_centre.z)
	var origin := _blend_from.origin.lerp(to.origin, eased)
	if from_plan.length() > 0.5 and to_plan.length() > 0.5:
		var bearing := lerp_angle(from_plan.angle(), to_plan.angle(), eased)
		var plan := Vector2.from_angle(bearing) * lerpf(from_plan.length(), to_plan.length(), eased)
		origin = Vector3(_blend_centre.x + plan.x, origin.y, _blend_centre.z + plan.y)
	# The view's yaw and pitch ease, its roll stays nil.
	var from_euler := _blend_from.basis.get_euler()
	var to_euler := to.basis.get_euler()
	var look := Vector3(lerp_angle(from_euler.x, to_euler.x, eased), lerp_angle(from_euler.y, to_euler.y, eased), 0.0)
	_blend.global_transform = Transform3D(Basis.from_euler(look), origin)
	_blend.fov = lerpf(_blend_from_fov, _blend_to.fov, eased)
	if _blend_t >= 1.0:
		_blend_t = -1.0
		if _blend.current:
			_blend_to.make_current()
