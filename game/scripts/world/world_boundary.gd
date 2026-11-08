class_name WorldBoundary
extends Node

var _boundary: Dictionary = {}
var _validated := false
## Every ring of the outline (outer rings and holes) as XZ points, for
## edge_distance().
var _rings: Array[PackedVector2Array] = []


func configure(validated_boundary: Dictionary) -> void:
	_boundary = validated_boundary.duplicate(true)
	_validated = true
	_rings.clear()
	for component_value: Variant in _boundary.get("components", []):
		var component: Dictionary = component_value
		var rings: Array = [component.get("outer", [])]
		rings.append_array(component.get("holes", []))
		for ring_value: Variant in rings:
			var ring := PackedVector2Array()
			for point: Array in ring_value:
				ring.append(Vector2(float(point[0]), float(point[1])))
			_rings.append(ring)


func is_configured() -> bool:
	return _validated


func contains_position(position: Vector3) -> bool:
	return _validated and GeneratedWorldContract.contains_xz(_boundary, Vector2(position.x, position.z))


## How far a position is, across the ground (XZ), from the nearest edge of the
## outline, on either side of it (INF when it is not configured).
func edge_distance(position: Vector3) -> float:
	var point := Vector2(position.x, position.z)
	var best := INF
	for ring: PackedVector2Array in _rings:
		var previous := ring[ring.size() - 1]
		for corner: Vector2 in ring:
			var segment := corner - previous
			var t := clampf((point - previous).dot(segment) / maxf(segment.length_squared(), 1e-9), 0.0, 1.0)
			best = minf(best, point.distance_squared_to(previous + segment * t))
			previous = corner
	return sqrt(best)


func get_boundary_data() -> Dictionary:
	return _boundary.duplicate(true)
