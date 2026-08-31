class_name PlayerCamera
extends Node3D

@export_range(0.0005, 0.01, 0.0001) var look_sensitivity := 0.003
@export_range(-89.0, 0.0, 1.0) var minimum_pitch_degrees := -60.0
@export_range(0.0, 89.0, 1.0) var maximum_pitch_degrees := 25.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var _input_enabled := false


func _ready() -> void:
	set_process_unhandled_input(false)
	var player := get_parent() as CollisionObject3D
	if player != null:
		spring_arm.add_excluded_object(player.get_rid())


func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	set_process_unhandled_input(enabled)


func planar_forward() -> Vector3:
	var forward := -global_transform.basis.z
	forward.y = 0.0
	return forward.normalized()


func planar_right() -> Vector3:
	var right := global_transform.basis.x
	right.y = 0.0
	return right.normalized()


func get_camera() -> Camera3D:
	return camera


func apply_look_delta(relative: Vector2) -> void:
	rotation.y -= relative.x * look_sensitivity
	spring_arm.rotation.x = clampf(
		spring_arm.rotation.x - relative.y * look_sensitivity,
		deg_to_rad(minimum_pitch_degrees),
		deg_to_rad(maximum_pitch_degrees)
	)


func _unhandled_input(event: InputEvent) -> void:
	if not _input_enabled or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion
		apply_look_delta(mouse_motion.relative)
