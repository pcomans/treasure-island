class_name RecoveryController
extends Node

signal recovered(cause: String, from_position: Vector3)

## No recovery check runs for this long after one.
const RECOVERY_COOLDOWN_SECONDS := 0.5
## How far above a spot the surface probe starts.
const SURFACE_PROBE_HEADROOM_M := 1.0

@export var fall_recovery_y := -20.0
@export_range(0.1, 2.0, 0.05) var stable_duration_seconds := 0.75
@export_range(0.05, 1.0, 0.05) var safe_velocity_mps := 0.5
## Leaving the playable outline (stepping onto the shoreline riprap, flying out
## over the water) lifts the player this far straight up from where they are.
## They float down at the jetpack's slow descent and can steer or jetpack back.
@export_range(1.0, 20.0, 0.5) var boundary_lift_m := 5.0
## A lifted player who floats farther than this from their first lift goes
## back to it, so a lift never carries anyone off the island.
@export_range(1.0, 50.0, 0.5) var boundary_float_radius_m := 10.0

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
## The player's position on the last frame they were inside the outline.
var _last_inside_position := Vector3.ZERO
## Lifted off the edge and not back inside the outline since.
var _lifted := false
## Where the first of those lifts put them.
var _lift_anchor := Vector3.ZERO
## In the air above what lies below the last lift: the edge waits until they
## are back down at that height, land on something or float too far.
var _floating := false
var _float_floor_y := 0.0


func configure(player: CharacterBody3D, boundary: WorldBoundary, initial_spawn: Transform3D, collision_shape: CollisionShape3D) -> void:
	_player = player
	_boundary = boundary
	_collision_shape = collision_shape
	_initial_spawn = initial_spawn
	_last_safe_transform = initial_spawn
	_candidate_transform = initial_spawn
	_candidate_seconds = 0.0
	_has_last_safe = true
	_last_inside_position = initial_spawn.origin
	_lifted = false
	_floating = false
	_configured = true


func physics_update(delta: float) -> void:
	if not _configured:
		return
	_recovery_cooldown_seconds = maxf(0.0, _recovery_cooldown_seconds - delta)
	var position := _player.global_position
	var inside := _boundary.contains_position(position)
	if inside:
		_last_inside_position = position
		_lifted = false
		_floating = false
	elif _floating and (_player.is_on_floor() or position.y <= _float_floor_y or _floated_too_far(position)):
		_floating = false
	if _recovery_cooldown_seconds <= 0.0:
		if position.y < fall_recovery_y:
			recover("fell_below_world")
			return
		if not inside and not _floating:
			_lift_off_edge(position)
			return
	_update_safe_transform(delta)


## Returns the player to the last safe place (the R key, or a fall below the
## world).
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
	_lifted = false
	_floating = false
	_candidate_transform = _player.global_transform
	_candidate_seconds = 0.0
	_recovery_cooldown_seconds = RECOVERY_COOLDOWN_SECONDS
	recovered.emit(cause, recovery_from)


func has_safe_transform() -> bool:
	return _has_last_safe


## The edge's reset. The player keeps their x and z and rises boundary_lift_m
## above the higher of their own height and what lies below, with no velocity,
## so the controller's slow descent and air control take over. One who has
## floated too far from the first lift goes back to it, keeping any extra
## height.
func _lift_off_edge(from: Vector3) -> void:
	var to: Vector3
	if _lifted and _floated_too_far(from):
		to = Vector3(_lift_anchor.x, maxf(from.y, _lift_anchor.y), _lift_anchor.z)
		_float_floor_y = _surface_below(Vector3(to.x, from.y, to.z))
	else:
		_float_floor_y = _surface_below(from)
		to = Vector3(from.x, maxf(from.y, _float_floor_y) + boundary_lift_m, from.z)
		if not _lifted:
			_lift_anchor = to
			_lifted = true
	_floating = true
	_player.global_position = to
	_player.velocity = Vector3.ZERO
	_candidate_transform = _player.global_transform
	_candidate_seconds = 0.0
	_recovery_cooldown_seconds = RECOVERY_COOLDOWN_SECONDS
	recovered.emit("outside_boundary", from)


func _floated_too_far(position: Vector3) -> bool:
	return Vector2(position.x - _lift_anchor.x, position.z - _lift_anchor.z).length() > boundary_float_radius_m


## The top of what lies below a spot off the outline: the water plane, anything
## solid straight below it, and whatever is below the player's last position
## inside the outline (the land edge they left). The riprap itself has no
## collision (shoreline.json is visual only); its stones sit at that land
## edge's height.
func _surface_below(at: Vector3) -> float:
	var top := GeneratedWorldContract.STREET_DETAIL_WATER_Y_M
	var space := _player.get_world_3d().direct_space_state
	for spot: Vector3 in [at, _last_inside_position]:
		var start := spot + Vector3.UP * SURFACE_PROBE_HEADROOM_M
		if start.y <= top:
			continue
		var query := PhysicsRayQueryParameters3D.create(start, Vector3(spot.x, top, spot.z), _player.collision_mask, [_player.get_rid()])
		# Like the player, the probe doesn't see one-sided collision from behind.
		query.hit_back_faces = false
		var hit := space.intersect_ray(query)
		if not hit.is_empty():
			top = maxf(top, (hit.position as Vector3).y)
	return top


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
	# Everything the player collides with: the world and the street props.
	query.collision_mask = _player.collision_mask
	query.exclude = [_player.get_rid()]
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return _player.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()
