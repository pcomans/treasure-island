class_name SprayController
extends Node

signal feedback_requested(message: String, success: bool)
signal spray_result(code: String)
signal spray_identity(derived_object_key: String, source_keys: Array)

const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_BUILDING_WALL := 1 << 1
const TAG_TEXTURE_PATH := "res://game/resources/textures/tag/predefined_tag.svg"

@export_range(1.0, 12.0, 0.25) var maximum_range_m := 6.0
@export_range(0.0, 0.8, 0.05) var maximum_wall_up_dot := 0.3
@export var tag_size := Vector2(1.2, 0.65)
@export_range(0.01, 0.25, 0.01) var projection_depth_m := 0.08

@onready var tag_instances: TagInstancePool = $TagInstances

var _player: CharacterBody3D
var _camera: Camera3D
var _enabled := false
var _tag_texture: Texture2D


func _ready() -> void:
	_tag_texture = load(TAG_TEXTURE_PATH) as Texture2D
	set_process_unhandled_input(false)


func configure(player: CharacterBody3D, camera: Camera3D) -> void:
	_player = player
	_camera = camera


func set_input_enabled(enabled: bool) -> void:
	_enabled = enabled
	set_process_unhandled_input(enabled)


func _unhandled_input(event: InputEvent) -> void:
	if not _enabled or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event.is_action_pressed("spray"):
		attempt_spray()
		get_viewport().set_input_as_handled()


func attempt_spray() -> void:
	if _player == null or _camera == null or _player.get_world_3d() == null:
		_reject("Aim at an exterior building wall", "no_hit")
		return
	var viewport_center := _camera.get_viewport().get_visible_rect().size * 0.5
	var ray_origin := _camera.project_ray_origin(viewport_center)
	var ray_direction := _camera.project_ray_normal(viewport_center).normalized()
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * 1000.0, PHYSICS_SPRAY_SURFACE, [_player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := _player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		_reject("No surface in sight", "no_hit")
		return
	var hit_position: Vector3 = hit.position
	if _player.global_position.distance_to(hit_position) > maximum_range_m:
		_reject("Wall is out of range", "range_rejection")
		return
	var collider := hit.get("collider", null) as CollisionObject3D
	var metadata := _resolve_hit_metadata(collider, int(hit.get("shape", -1)))
	if collider == null or not collider.is_in_group("spray_receiver_wall") \
	or str(metadata.get("receiver_kind", "")) != "building_wall" \
	or not bool(metadata.get("opaque", false)):
		_reject("Aim at an exterior building wall", "receiver_rejection")
		return
	var normal: Vector3 = hit.normal.normalized()
	if absf(normal.dot(Vector3.UP)) > maximum_wall_up_dot:
		_reject("Aim at a vertical building wall", "receiver_rejection")
		return
	var object_key := str(metadata.get("derived_object_key", ""))
	var source_keys: Array = metadata.get("source_keys", [])
	if object_key.is_empty() or source_keys.is_empty():
		_reject("Wall identity is unavailable", "identity_error")
		return
	if _tag_texture == null:
		_reject("Tag texture is unavailable", "identity_error")
		return

	# Godot decals project along local -Y. Keep local +Y pointed out of the
	# receiver so the projection travels back into the wall, and local +Z up so
	# the predefined tag is not vertically flipped.
	var right := normal.cross(Vector3.UP).normalized()
	if right.length_squared() < 0.5:
		_reject("Aim at a vertical building wall", "receiver_rejection")
		return
	var upright := right.cross(normal).normalized()
	var decal := Decal.new()
	decal.name = "Tag_%03d" % (tag_instances.active_count() + 1)
	decal.texture_albedo = _tag_texture
	decal.size = Vector3(tag_size.x, projection_depth_m, tag_size.y)
	decal.cull_mask = RENDER_BUILDING_WALL
	decal.normal_fade = 0.15
	decal.upper_fade = 0.02
	decal.lower_fade = 0.02
	decal.transform = Transform3D(Basis(right, normal, upright).orthonormalized(), hit_position + normal * 0.015)
	decal.set_meta("derived_object_key", object_key)
	decal.set_meta("source_keys", source_keys.duplicate())
	tag_instances.add_tag(decal)
	feedback_requested.emit("Tag placed", true)
	spray_identity.emit(object_key, source_keys.duplicate())
	spray_result.emit("placed")


func _resolve_hit_metadata(collider: CollisionObject3D, shape_index: int) -> Dictionary:
	if collider == null:
		return {}
	var metadata := {
		"receiver_kind": collider.get_meta("receiver_kind", ""),
		"opaque": collider.get_meta("opaque", false),
		"derived_object_key": collider.get_meta("derived_object_key", ""),
		"source_keys": collider.get_meta("source_keys", []),
	}
	if shape_index < 0:
		return metadata
	var owner_id := collider.shape_find_owner(shape_index)
	if owner_id == 0 or collider.shape_owner_get_shape_count(owner_id) == 0:
		return metadata
	var shape := collider.shape_owner_get_shape(owner_id, 0)
	if shape != null:
		for key: String in ["receiver_kind", "opaque", "derived_object_key", "source_keys"]:
			if shape.has_meta(key):
				metadata[key] = shape.get_meta(key)
	return metadata


func _reject(message: String, code: String) -> void:
	feedback_requested.emit(message, false)
	spray_result.emit(code)
