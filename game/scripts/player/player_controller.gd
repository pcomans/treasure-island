class_name PlayerController
extends CharacterBody3D

signal feedback_requested(message: String, success: bool)
signal spray_result(code: String)
signal recovered(cause: String, from_position: Vector3)
signal startup_grounded

@export_range(0.5, 12.0, 0.25) var walk_speed_mps := 4.0
@export_range(1.0, 24.0, 0.25) var run_speed_mps := 20.0
# The fast run reaches 20 m/s from rest in about 0.67 s and stops in 0.5 s.
@export_range(1.0, 40.0, 0.5) var acceleration_mps2 := 30.0
@export_range(1.0, 50.0, 0.5) var braking_mps2 := 40.0
@export_range(1.0, 20.0, 0.5) var avatar_turn_speed := 10.0
@export_range(0.5, 12.0, 0.25) var jetpack_ascent_speed_mps := 5.0
@export_range(0.25, 6.0, 0.25) var jetpack_descent_speed_mps := 1.5
@export_range(1.0, 30.0, 0.5) var jetpack_vertical_response_mps2 := 12.0

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var avatar_pivot: Node3D = $AvatarPivot
@onready var camera_rig: PlayerCamera = $CameraPivot
@onready var recovery_controller: RecoveryController = $RecoveryController
@onready var spray_controller: SprayController = $SprayController

var _gameplay_enabled := false
var _startup_settling := false
var _startup_boundary: WorldBoundary
var _first_reveal_grounded := false


func _ready() -> void:
	up_direction = Vector3.UP
	floor_snap_length = 0.35
	floor_max_angle = deg_to_rad(48.0)
	spray_controller.configure(self, camera_rig.get_camera())
	spray_controller.feedback_requested.connect(_on_feedback_requested)
	spray_controller.spray_result.connect(_on_spray_result)
	recovery_controller.recovered.connect(_on_recovered)
	set_gameplay_enabled(false)


func configure_world(spawn_transform: Transform3D, boundary: WorldBoundary) -> void:
	global_transform = spawn_transform
	velocity = Vector3.DOWN * 0.1
	_startup_boundary = boundary
	_startup_settling = true
	_first_reveal_grounded = false
	set_physics_process(true)
	set_process_unhandled_input(false)
	camera_rig.set_input_enabled(false)
	spray_controller.set_input_enabled(false)


func reveal_grounded() -> bool:
	_first_reveal_grounded = _startup_settling == false and is_on_floor()
	if _first_reveal_grounded:
		show()
	return _first_reveal_grounded


func was_first_reveal_grounded() -> bool:
	return _first_reveal_grounded


func set_gameplay_enabled(enabled: bool) -> void:
	_gameplay_enabled = enabled
	set_physics_process(enabled or _startup_settling)
	set_process_unhandled_input(enabled)
	camera_rig.set_input_enabled(enabled)
	spray_controller.set_input_enabled(enabled)
	if not enabled:
		velocity = Vector3.ZERO


func get_camera() -> Camera3D:
	return camera_rig.get_camera()


func get_spray_controller() -> SprayController:
	return spray_controller


func get_recovery_controller() -> RecoveryController:
	return recovery_controller


func _physics_process(delta: float) -> void:
	if _startup_settling:
		velocity.x = 0.0
		velocity.z = 0.0
		velocity.y = minf(velocity.y, -0.1)
		move_and_slide()
		if is_on_floor():
			velocity = Vector3.ZERO
			_startup_settling = false
			recovery_controller.configure(self, _startup_boundary, global_transform, collision_shape)
			set_physics_process(_gameplay_enabled)
			startup_grounded.emit()
		return
	if not _gameplay_enabled:
		return
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	var direction := camera_rig.planar_right() * input_vector.x + camera_rig.planar_forward() * -input_vector.y
	if direction.length_squared() > 0.0001:
		direction = direction.normalized()
	var target_speed := run_speed_mps if Input.is_action_pressed("run") else walk_speed_mps
	var target_velocity := direction * target_speed
	var rate := acceleration_mps2 if not direction.is_zero_approx() else braking_mps2
	velocity.x = move_toward(velocity.x, target_velocity.x, rate * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, rate * delta)
	_update_jetpack_velocity(delta)
	move_and_slide()
	if direction.length_squared() > 0.01:
		var target_yaw := atan2(direction.x, direction.z)
		avatar_pivot.rotation.y = lerp_angle(avatar_pivot.rotation.y, target_yaw, minf(1.0, avatar_turn_speed * delta))
	recovery_controller.physics_update(delta)


func _update_jetpack_velocity(delta: float) -> void:
	if Input.is_action_pressed("jetpack"):
		velocity.y = move_toward(velocity.y, jetpack_ascent_speed_mps, jetpack_vertical_response_mps2 * delta)
	elif is_on_floor() and velocity.y <= 0.0:
		velocity.y = 0.0
	else:
		velocity.y = move_toward(velocity.y, -jetpack_descent_speed_mps, jetpack_vertical_response_mps2 * delta)


func _unhandled_input(event: InputEvent) -> void:
	if _gameplay_enabled and event.is_action_pressed("recover"):
		recovery_controller.recover("manual")
		get_viewport().set_input_as_handled()


func _on_feedback_requested(message: String, success: bool) -> void:
	feedback_requested.emit(message, success)


func _on_spray_result(code: String) -> void:
	spray_result.emit(code)


func _on_recovered(cause: String, from_position: Vector3) -> void:
	feedback_requested.emit("Recovered", true)
	recovered.emit(cause, from_position)
