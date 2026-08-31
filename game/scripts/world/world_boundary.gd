class_name WorldBoundary
extends Node

var _boundary: Dictionary = {}
var _validated := false


func configure(validated_boundary: Dictionary) -> void:
	_boundary = validated_boundary.duplicate(true)
	_validated = true


func is_configured() -> bool:
	return _validated


func contains_position(position: Vector3) -> bool:
	return _validated and GeneratedWorldContract.contains_xz(_boundary, Vector2(position.x, position.z))


func get_boundary_data() -> Dictionary:
	return _boundary.duplicate(true)
