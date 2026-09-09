class_name PlayerCamera
extends Node3D

@export_range(0.0005, 0.01, 0.0001) var look_sensitivity := 0.003
@export_range(-89.0, 0.0, 1.0) var minimum_pitch_degrees := -60.0
@export_range(0.0, 89.0, 1.0) var maximum_pitch_degrees := 25.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var _input_enabled := false
var _rest_position := Vector3.ZERO
var _player_collision: CollisionShape3D
var _pivot_clearance := SphereShape3D.new()
var _pivot_query := PhysicsShapeQueryParameters3D.new()


func _ready() -> void:
	set_process_unhandled_input(false)
	_rest_position = position
	var player := get_parent() as CollisionObject3D
	if player != null:
		spring_arm.add_excluded_object(player.get_rid())
		_player_collision = player.get_node("CollisionShape3D") as CollisionShape3D
		_pivot_query.exclude = [player.get_rid()]
		# Follow the moved player, then let SpringArm sweep from a clear origin.
		process_physics_priority = player.process_physics_priority + 1
		spring_arm.process_physics_priority = process_physics_priority + 1
	_pivot_query.shape = _pivot_clearance
	_pivot_query.margin = 0.001
	# The same clearance hull protects the camera origin and all near corners,
	# including an oblique approach to a thin wall at the edge of a ceiling.
	_pivot_clearance.radius = spring_arm.margin
	spring_arm.shape = _pivot_clearance


func _physics_process(_delta: float) -> void:
	if _player_collision == null:
		return
	# SpringArm's sweep ignores geometry overlapping its starting camera hull.
	# Sweep from inside the player's capsule so a low ceiling cannot put that
	# hull above the ceiling before the arm even checks its outward motion.
	var size := camera.get_viewport().get_visible_rect().size
	var aspect := size.x / maxf(size.y, 1.0)
	var half_height := camera.near * tan(deg_to_rad(camera.fov * 0.5))
	var half_width := half_height * aspect
	if camera.keep_aspect == Camera3D.KEEP_WIDTH:
		half_width = half_height
		half_height = half_width / aspect
	_pivot_clearance.radius = maxf(spring_arm.margin, Vector3(half_width, half_height, camera.near).length() + 0.01)
	var anchor := _player_collision.global_position
	var desired := get_parent_node_3d().to_global(_rest_position)
	_pivot_query.transform = Transform3D(Basis.IDENTITY, anchor)
	_pivot_query.motion = desired - anchor
	_pivot_query.collision_mask = spring_arm.collision_mask
	var fractions := get_world_3d().direct_space_state.cast_motion(_pivot_query)
	if fractions[0] >= 1.0:
		position = _rest_position
	else:
		var distance := _pivot_query.motion.length()
		global_position = anchor + _pivot_query.motion * maxf(0.0, fractions[0] - 0.005 / maxf(distance, 0.001))


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
