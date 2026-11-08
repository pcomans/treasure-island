class_name VehicleCamera
extends Node3D
## The chase camera while the player drives (game/scripts/vehicles/vehicle_manager.gd):
## the player rig's own structure and settings, a pivot -> SpringArm3D ->
## Camera3D with the gameplay camera's field of view, near and far planes and
## the arm's margin and world-solid mask (game/scenes/player/player.tscn), so
## street props, parked cars and the car itself never pull it in. It is current
## only while driving; the on-foot rig (player_camera.gd) is left as it is.
##
## The pivot rides above the car as drawn this frame (the car's interpolated
## visual), so it moves smoothly whatever the frame rate. Its yaw swings behind
## the car's heading, slowly when the car creeps and briskly at speed, and in the
## air it follows the flight instead of a tumbling car. Moving the mouse (with
## the pointer captured) glances round with the on-foot sensitivity and pitch
## limits; a second after the mouse stops, the view eases back behind the car.

const DRIVABLE_CAR := preload("res://game/scripts/vehicles/drivable_car.gd")
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
## Field of view at rest and its widening toward FOV_SPEED_MPS.
const FOV := 70.0
const FOV_WIDEN := 6.0
const FOV_SPEED_MPS := 40.0

@export_range(0.0005, 0.01, 0.0001) var look_sensitivity := 0.003

var spring_arm: SpringArm3D
var camera: Camera3D
var _car: DRIVABLE_CAR
var _yaw := 0.0
var _glance_yaw := 0.0
var _glance_pitch := 0.0
var _since_glance := 0.0
var _clearance := SphereShape3D.new()
var _query := PhysicsShapeQueryParameters3D.new()


func _init() -> void:
	top_level = true
	spring_arm = SpringArm3D.new()
	spring_arm.name = "SpringArm3D"
	spring_arm.margin = 0.15
	spring_arm.collision_mask = 1
	spring_arm.rotation = Vector3(PITCH_REST, 0.0, 0.0)
	add_child(spring_arm)
	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.fov = FOV
	camera.near = 0.08
	camera.far = 5000.0
	spring_arm.add_child(camera)
	_clearance.radius = 0.3
	spring_arm.shape = _clearance
	_query.shape = _clearance
	_query.margin = 0.001
	_query.collision_mask = 1


func _ready() -> void:
	set_process(false)
	set_process_unhandled_input(false)


## Takes over from the on-foot camera at its yaw and pitch, behind car.
func attach(car: DRIVABLE_CAR, start_yaw: float, start_pitch: float) -> void:
	_car = car
	_yaw = start_yaw
	_glance_yaw = 0.0
	_glance_pitch = clampf(start_pitch, MIN_PITCH, MAX_PITCH) - PITCH_REST
	_since_glance = 0.0
	spring_arm.spring_length = 4.2 + 0.55 * car.length_m
	_place(0.0, true)
	camera.make_current()
	set_process(true)
	set_process_unhandled_input(true)


func detach() -> void:
	_car = null
	set_process(false)
	set_process_unhandled_input(false)


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
	if _car == null or not is_instance_valid(_car):
		return
	_place(delta, false)


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
	# The pivot above the car's roof, swept up from inside the car so a low
	# ceiling can't start the arm above it (as the on-foot rig does).
	var anchor := xf.origin + Vector3.UP * (_car.height_m * 0.6)
	var desired := xf.origin + Vector3.UP * (_car.height_m + 0.5)
	_query.transform = Transform3D(Basis.IDENTITY, anchor)
	_query.motion = desired - anchor
	_query.exclude = [_car.get_rid()]
	var fractions := get_world_3d().direct_space_state.cast_motion(_query) if is_inside_tree() else PackedFloat32Array([1.0, 1.0])
	global_position = anchor + _query.motion * clampf(fractions[0] - 0.01, 0.0, 1.0)
	rotation = Vector3(0.0, _yaw + _glance_yaw, 0.0)
	spring_arm.rotation = Vector3(view_pitch(), 0.0, 0.0)
	camera.fov = FOV + FOV_WIDEN * clampf(planar / FOV_SPEED_MPS, 0.0, 1.0)
