extends "res://game/scripts/world/western_background_blockout.gd"
## Bounded L1 eastern context; no collision and no duplicate Bay Bridge.
func build_scenery() -> void:
	if get_child_count() > 0:
		return
	# Kept in registration (the base script's), as the western background keeps its own.
	registration = JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/context/eastern_blockout.json"))
	for region: Dictionary in registration.profiles:
		_profile(region)
	for building: Dictionary in registration.buildings:
		var vertices := PackedVector3Array()
		var indices := PackedInt32Array()
		var outline := PackedVector2Array()
		for p: Array in building.points:
			vertices.append(Vector3(p[0], 0, p[1]))
			vertices.append(Vector3(p[0], building.height, p[1]))
			outline.append(Vector2(p[0], p[1]))
		for i in range(outline.size()):
			var k := i * 2
			var j := ((i + 1) % outline.size()) * 2
			indices.append_array(PackedInt32Array([k, k + 1, j, k + 1, j + 1, j]))
		for k: int in Geometry2D.triangulate_polygon(outline):
			indices.append(k * 2 + 1)
		_mesh("EastMappedMass" + str(building.id), vertices, indices, Color(0.63, 0.66, 0.64))
	for crane: Dictionary in registration.cranes:
		var p := Vector3(crane.xz[0], 0, crane.xz[1])
		var c := Color(0.40, 0.47, 0.50)
		# Broad portal silhouette only; orientation/height inferred, node XZ mapped.
		_beam("PortLeg" + str(crane.id), p, p + Vector3(0, crane.height, 0), 4.0, c)
		_beam("PortBoom" + str(crane.id), p + Vector3(-45, crane.height, 0), p + Vector3(45, crane.height, 0), 3.0, c)
