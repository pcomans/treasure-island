class_name RecoveryController
extends Node

signal recovered(cause: String, from_position: Vector3)

const PHYSICS_WORLD_SOLID := 1 << 0

@export var fall_recovery_y := -20.0
@export_range(0.1, 2.0, 0.05) var stable_duration_seconds := 0.75
@export_range(0.05, 1.0, 0.05) var safe_velocity_mps := 0.5

var _player: CharacterBody3D
var _boundary: WorldBoundary
var _collision_shape: CollisionShape3D
var _initial_spawn := Transform3D.IDENTITY
var _last_safe_transform := Transform3D.IDENTITY
var _candidate_transform := Transform3D.IDENTITY
var _candidate_seconds := 0.0
var _has_last_safe := false
var _configured := false
var _recovery_cooldown_seconds := 0.0


func configure(player: CharacterBody3D, boundary: WorldBoundary, initial_spawn: Transform3D, collision_shape: CollisionShape3D) -> void:
	_player = player
	_boundary = boundary
	_collision_shape = collision_shape
	_initial_spawn = initial_spawn
	_last_safe_transform = initial_spawn
	_candidate_transform = initial_spawn
	_candidate_seconds = 0.0
	_has_last_safe = true
	_configured = true


func physics_update(delta: float) -> void:
	if not _configured:
		return
	_recovery_cooldown_seconds = maxf(0.0, _recovery_cooldown_seconds - delta)
	if _recovery_cooldown_seconds <= 0.0:
		if _player.global_position.y < fall_recovery_y:
			recover("fell_below_world")
			return
		if not _boundary.contains_position(_player.global_position):
			recover("outside_boundary")
			return
	_update_safe_transform(delta)


func recover(cause: String = "manual") -> void:
	if not _configured:
		return
	var recovery_from := _player.global_position
	var camera_pivot := _player.get_node_or_null("CameraPivot") as Node3D
	var preserved_camera_yaw := 0.0 if camera_pivot == null else camera_pivot.rotation.y
	_player.global_transform = _last_safe_transform if _has_last_safe else _initial_spawn
	_player.velocity = Vector3.ZERO
	if camera_pivot != null:
		camera_pivot.rotation.y = preserved_camera_yaw
	_candidate_transform = _player.global_transform
	_candidate_seconds = 0.0
	_recovery_cooldown_seconds = 0.5
	recovered.emit(cause, recovery_from)


func has_safe_transform() -> bool:
	return _has_last_safe


func _update_safe_transform(delta: float) -> void:
	var horizontal_speed := Vector2(_player.velocity.x, _player.velocity.z).length()
	var safe_now := _player.is_on_floor() \
		and _boundary.contains_position(_player.global_position) \
		and horizontal_speed <= safe_velocity_mps \
		and _has_capsule_clearance()
	if not safe_now:
		_candidate_seconds = 0.0
		_candidate_transform = _player.global_transform
		return
	if _candidate_transform.origin.distance_to(_player.global_position) > 0.35:
		_candidate_transform = _player.global_transform
		_candidate_seconds = 0.0
		return
	_candidate_seconds += delta
	if _candidate_seconds >= stable_duration_seconds:
		_last_safe_transform = _player.global_transform
		_has_last_safe = true
		_candidate_transform = _last_safe_transform
		_candidate_seconds = 0.0


func _has_capsule_clearance() -> bool:
	if _collision_shape == null or _collision_shape.shape == null or _player.get_world_3d() == null:
		return false
	var query_shape := _collision_shape.shape.duplicate() as Shape3D
	if query_shape is CapsuleShape3D:
		var capsule := query_shape as CapsuleShape3D
		capsule.radius = maxf(0.05, capsule.radius - 0.03)
		capsule.height = maxf(capsule.radius * 2.0, capsule.height - 0.06)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = query_shape
	query.transform = _collision_shape.global_transform
	query.collision_mask = PHYSICS_WORLD_SOLID
	query.exclude = [_player.get_rid()]
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return _player.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()
