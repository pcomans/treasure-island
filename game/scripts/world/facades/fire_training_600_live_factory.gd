extends RefCounted
## Building 600: long classroom wing and a crosswise, genuinely open training
## entrance at its southern end. Dimensions and hidden schedules are game-art
## inference; the four outer corners come from the supplied frozen roof record.

const KIT := preload("res://game/scripts/world/facades/site_12_housing_kit.gd")
const MASONRY := preload("res://game/resources/facades/fire_training_600_masonry.gdshader")
const SOURCE := "w34313548"
const WALL := "building:w34313548:wall"
const ROOF := "building:w34313548:roof"

var _buckets: Dictionary = {}
var _length := 0.0
var _depth := 0.0
var _cut := 0.0
var _bottom := 0.0
var _corner_correction := Vector3.ZERO
var _far_start_correction := Vector3.ZERO
var _pose := Transform3D.IDENTITY


static func build(wall: Dictionary, roof: Dictionary) -> Dictionary:
	var factory = new()
	return factory._build(wall, roof)


func _build(wall: Dictionary, roof: Dictionary) -> Dictionary:
	var points := PackedVector3Array()
	for i in range(0, roof.vertices.size(), 3):
		points.append(Vector3(roof.vertices[i], roof.vertices[i + 1], roof.vertices[i + 2]))
	if points.size() != 4:
		return {"ok": false, "message": "Building 600 needs its rectangular source footprint."}
	var along := points[1] - points[0]
	along.y = 0.0
	_length = along.length()
	along = along.normalized()
	var front := along.cross(Vector3.UP)
	_depth = (points[3] - points[0]).dot(-front)
	if _length < 80.0 or _depth < 10.0 or _depth > 25.0:
		return {"ok": false, "message": "Building 600 source footprint no longer fits this design."}
	var base := float(wall.flat_base_elevation_m)
	_pose = Transform3D(Basis(along, Vector3.UP, front), Vector3(points[0].x, base, points[0].z))
	# Keep the source's tiny non-parallelogram difference, rather than rounding
	# its fourth corner onto an idealized rectangle.
	_far_start_correction = _pose.affine_inverse() * Vector3(points[3].x, base, points[3].z) - Vector3(0.0, 0.0, -_depth)
	_corner_correction = _pose.affine_inverse() * Vector3(points[2].x, base, points[2].z) - Vector3(_length, 0.0, -_depth)
	_bottom = 0.0
	for i in range(1, wall.vertices.size(), 3):
		_bottom = minf(_bottom, float(wall.vertices[i]) - base - 0.12)
	_cut = _length - 14.2
	for role in ["masonry", "red", "trim", "glass", "metal", "roof", "concrete"]:
		_buckets[role] = KIT.new_bucket()
	_wing()
	_canopy()
	var wall_root := Node3D.new()
	var roof_root := Node3D.new()
	wall_root.name = "FireTraining600Walls"
	roof_root.name = "FireTraining600Roof"
	for pair in [[wall_root, WALL, "building_wall"], [roof_root, ROOF, "building_roof"]]:
		var root: Node3D = pair[0]
		root.transform = _pose
		root.set_meta("source_keys", [SOURCE])
		root.set_meta("derived_object_key", pair[1])
		root.set_meta("feature_kind", pair[2])
		root.set_meta("runtime_supersedes_generated_placeholder", true)
	var walls := _emit(wall_root, ["masonry", "red", "trim", "glass", "concrete"], true)
	var roofs := _emit(roof_root, ["roof", "metal"], false)
	var sign_counts := _sign(wall_root)
	walls.mesh_instances += sign_counts.meshes
	walls.surfaces += sign_counts.meshes
	walls.triangles += sign_counts.triangles
	return {"ok": true, "wall": walls, "roof": roofs}


func _box(role: String, center: Vector3, size: Vector3) -> void:
	KIT.append_box(_buckets[role], center, Vector3.RIGHT, Vector3.BACK, size.x, size.y, size.z)


func _wing() -> void:
	var top := 4.0
	var height := top - _bottom
	# Four thin, solid walls with no hidden solid box across the canopy.
	_box("masonry", Vector3(_cut * 0.5, (top + _bottom) * 0.5, -0.18), Vector3(_cut, height, 0.36))
	_box("masonry", Vector3(_cut * 0.5, (top + _bottom) * 0.5, -_depth + 0.18), Vector3(_cut, height, 0.36))
	for x in [0.18, _cut - 0.18]:
		_box("masonry", Vector3(x, (top + _bottom) * 0.5, -_depth * 0.5), Vector3(0.36, height, _depth))
	# Bury the roof end inside the return rather than duplicate its exposed plane.
	var roof_end := _cut - 0.18
	_box("roof", Vector3(roof_end * 0.5, 4.05, -_depth * 0.5), Vector3(roof_end, 0.22, _depth))
	# The classroom end rises to the canopy soffit; the public wing roof stays
	# lower. The dated through-passage view shows a solid return, not an opening.
	_box("masonry", Vector3(_cut - 0.18, 4.875, -_depth * 0.5), Vector3(0.36, 1.75, _depth - 0.96))
	for z in [-0.03, -_depth + 0.03]:
		_box("trim", Vector3(_cut * 0.5, 3.94, z), Vector3(_cut, 0.16, 0.16))
	# The street's heavily tree-obscured wing has both high small windows and
	# broad low groups near the entrance. Counts/spacing are inferred, not surveyed.
	for i in 11:
		var x := 4.0 + i * 5.25
		_window(Vector3(x, 2.97, 0.025), 1.8, 0.82, true, 2)
	for x in [_cut - 23.0, _cut - 17.8, _cut - 12.6, _cut - 7.4, _cut - 2.2]:
		_window(Vector3(x, 1.98, 0.025), 3.5, 1.8, true, 3)
	# Restrained yard-facing service bays, inferred from SFFD's training photo.
	for i in 10:
		var x := 5.0 + i * 8.0
		_box("trim", Vector3(x, 1.57, -_depth - 0.015), Vector3(3.9, 2.95, 0.06))
		_box("glass", Vector3(x, 1.56, -_depth - 0.055), Vector3(3.56, 2.64, 0.045))
		for y in [0.65, 1.25, 1.85, 2.45]:
			_box("metal", Vector3(x, y, -_depth - 0.09), Vector3(3.54, 0.035, 0.025))
		_window(Vector3(x, 3.52, -_depth - 0.025), 2.0, 0.45, false, 2)
	# End wall remains low-information; no invented unique entrance.
	# The classroom wall inside the canopy is visible in the 2019 photograph.
	_box("glass", Vector3(_cut + 0.02, 1.8, -3.6), Vector3(0.04, 1.8, 2.2))
	for z in [-4.75, -2.45]:
		_box("trim", Vector3(_cut + 0.07, 1.8, z), Vector3(0.14, 2.0, 0.12))
	for y in [0.86, 2.74]:
		_box("trim", Vector3(_cut + 0.07, y, -3.6), Vector3(0.14, 0.12, 2.4))


func _window(center: Vector3, width: float, height: float, front: bool, panes: int) -> void:
	var outward := 1.0 if front else -1.0
	_box("trim", center, Vector3(width + 0.22, height + 0.22, 0.10))
	_box("glass", center + Vector3(0.0, 0.0, outward * 0.065), Vector3(width, height, 0.045))
	for i in range(1, panes):
		var x := center.x - width * 0.5 + width * float(i) / panes
		_box("trim", Vector3(x, center.y, center.z + outward * 0.10), Vector3(0.055, height, 0.045))
	_box("trim", center + Vector3(0.0, -height * 0.5 - 0.12, outward * 0.07), Vector3(width + 0.3, 0.12, 0.23))


func _arch_y(x: float) -> float:
	var t := (x - (_cut + _length) * 0.5) / ((_length - _cut) * 0.5 - 1.0)
	return 3.12 + 2.1 * (1.0 - t * t)


func _canopy() -> void:
	var width := _length - _cut
	for z in [-0.24, -_depth + 0.24]:
		for x in [_cut + 0.5, _length - 0.5]:
			_box("red", Vector3(x, (6.2 + _bottom) * 0.5, z), Vector3(1.0, 6.2 - _bottom, 0.48))
		# Extruded curved spandrel: front/back, underside and top are actual mesh.
		for i in 32:
			var a := lerpf(_cut + 1.0, _length - 1.0, float(i) / 32.0)
			var b := lerpf(_cut + 1.0, _length - 1.0, float(i + 1) / 32.0)
			var ya := _arch_y(a)
			var yb := _arch_y(b)
			var bucket: Dictionary = _buckets.red
			for face in [-1.0, 1.0]:
				KIT.append_quad(bucket, Vector3(a, ya, z + face * 0.24), Vector3(b, yb, z + face * 0.24), Vector3(b, 6.2, z + face * 0.24), Vector3(a, 6.2, z + face * 0.24), Vector3(0, 0, face), Vector2(a, ya), Vector2(b - a, 6.2 - ya))
			KIT.append_quad(bucket, Vector3(a, ya, z - 0.24), Vector3(a, ya, z + 0.24), Vector3(b, yb, z + 0.24), Vector3(b, yb, z - 0.24), Vector3(yb - ya, a - b, 0).normalized(), Vector2.ZERO, Vector2(0.48, b - a))
			KIT.append_quad(bucket, Vector3(a, 6.2, z - 0.24), Vector3(b, 6.2, z - 0.24), Vector3(b, 6.2, z + 0.24), Vector3(a, 6.2, z + 0.24), Vector3.UP, Vector2.ZERO, Vector2(b - a, 0.48))
	# Full-depth flat metal canopy above open passage. Narrow exposed ribs and
	# triangulated open-web roof framing are visible through the arch.
	_box("roof", Vector3((_cut + _length) * 0.5, 5.84, -_depth * 0.5), Vector3(width, 0.18, _depth - 0.96))
	for i in 9:
		var z := -0.8 - float(i) * (_depth - 1.6) / 8.0
		_beam(Vector3(_cut, 5.58, z), Vector3(_length - 0.36, 5.58, z), 0.09)
		_beam(Vector3(_cut, 5.19, z), Vector3(_length - 0.36, 5.19, z), 0.07)
		for j in 8:
			var x := _cut + 0.4 + j * (width - 0.8) / 8.0
			var nx := _cut + 0.4 + (j + 1) * (width - 0.8) / 8.0
			_beam(Vector3(x, 5.19 if j % 2 == 0 else 5.58, z), Vector3(nx, 5.58 if j % 2 == 0 else 5.19, z), 0.045)
	for i in 13:
		_box("metal", Vector3(_cut + 0.6 + i * (width - 1.2) / 12.0, 5.73, -_depth * 0.5), Vector3(0.055, 0.07, _depth - 1.0))
	# South screen: solid base and three rows of real square voids, not black paint.
	_box("masonry", Vector3(_length - 0.18, (1.3 + _bottom) * 0.5, -_depth * 0.5), Vector3(0.36, 1.3 - _bottom, _depth - 0.96))
	for y in [1.45, 2.28, 3.1, 3.93]:
		_box("masonry", Vector3(_length - 0.18, y, -_depth * 0.5), Vector3(0.36, 0.27, _depth - 0.96))
	for i in 19:
		var z := -0.62 - float(i) * (_depth - 1.24) / 18.0
		_box("masonry", Vector3(_length - 0.18, 2.70, z), Vector3(0.36, 2.46, 0.27))
	_box("masonry", Vector3(_length - 0.18, 4.9075, -_depth * 0.5), Vector3(0.36, 1.685, _depth - 0.96))
	# The 2025 frontage has a row of protective bollards. Keep human-width gaps.
	for i in 7:
		var x := _cut + 2.0 + i * (width - 4.0) / 6.0
		_box("concrete", Vector3(x, (1.165 + _bottom) * 0.5, -0.7), Vector3(0.28, 1.165 - _bottom, 0.28))
		_box("metal", Vector3(x, 1.18, -0.7), Vector3(0.29, 0.12, 0.29))
	# Subtle recessed-panel outlines on the street spandrel's outer corners.
	for x in [_cut + 1.0, _length - 1.0]:
		for y in [5.24, 5.74]:
			_box("red", Vector3(x, y, 0.012), Vector3(0.62, 0.025, 0.025))
		for edge in [-0.31, 0.31]:
			_box("red", Vector3(x + edge, 5.49, 0.012), Vector3(0.025, 0.5, 0.025))


func _beam(a: Vector3, b: Vector3, thickness: float) -> void:
	var temp := KIT.new_bucket()
	KIT.append_box(temp, Vector3.ZERO, Vector3.RIGHT, Vector3.BACK, a.distance_to(b), thickness, thickness)
	var x := (b - a).normalized()
	var z := Vector3.BACK
	var y := z.cross(x).normalized()
	var pose := Transform3D(Basis(x, y, z), (a + b) * 0.5)
	var bucket: Dictionary = _buckets.metal
	var offset: int = bucket.vertices.size()
	for vertex: Vector3 in temp.vertices:
		bucket.vertices.append(pose * vertex)
	for normal: Vector3 in temp.normals:
		bucket.normals.append(pose.basis * normal)
	bucket.uvs.append_array(temp.uvs)
	for index: int in temp.indices:
		bucket.indices.append(index + offset)


func _material(role: String) -> Material:
	if role == "masonry":
		var shader := ShaderMaterial.new()
		shader.shader = MASONRY
		return shader
	var material := StandardMaterial3D.new()
	material.albedo_color = {"red": Color("753b3c"), "trim": Color("b4b6a4"), "glass": Color("406875"), "metal": Color("263334"), "roof": Color("aeb0a2"), "concrete": Color("95988e")}[role]
	material.roughness = 0.83 if role != "glass" else 0.36
	return material


func _emit(root: Node3D, roles: Array, wall: bool) -> Dictionary:
	var faces := PackedVector3Array()
	var count := 0
	var triangles := 0
	for role: String in roles:
		var bucket: Dictionary = _buckets[role]
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		var vertices := PackedVector3Array()
		for point: Vector3 in bucket.vertices:
			# Bilinear correction preserves all four exact frozen outer corners.
			vertices.append(point + _far_start_correction * (1.0 - point.x / _length) * (-point.z / _depth) + _corner_correction * (point.x / _length) * (-point.z / _depth))
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(bucket.normals)
		arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(bucket.uvs)
		arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(bucket.indices)
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(0, _material(role))
		var instance := MeshInstance3D.new()
		instance.name = role.capitalize()
		instance.mesh = mesh
		root.add_child(instance)
		faces.append_array(mesh.get_faces())
		triangles += bucket.indices.size() / 3
		count += 1
	var body := StaticBody3D.new()
	body.name = "Collision"
	body.collision_layer = 5
	body.collision_mask = 0
	body.set_meta("source_keys", [SOURCE])
	body.set_meta("derived_object_key", WALL if wall else ROOF)
	body.set_meta("receiver_kind", "building_wall" if wall else "none")
	body.set_meta("opaque", true)
	if wall:
		body.add_to_group("spray_receiver_wall")
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	shape.backface_collision = true
	var collision := CollisionShape3D.new()
	collision.name = "Shape"
	collision.shape = shape
	body.add_child(collision)
	root.add_child(body)
	return {"ok": true, "node": root, "mesh_instances": count, "surfaces": count, "triangles": triangles, "static_bodies": 1, "shapes": 1}


func _sign(root: Node3D) -> Dictionary:
	var text := "SFFD FIRE FIGHTING SCHOOL"
	var middle := (_cut + _length) * 0.5
	var spacing := 0.40
	var counts := {"meshes": 0, "triangles": 0}
	for i in text.length():
		if text[i] == " ":
			continue
		var x := middle + (float(i) - float(text.length() - 1) * 0.5) * spacing
		var letters := TextMesh.new()
		letters.text = text[i]
		letters.font_size = 48
		letters.pixel_size = 0.009
		letters.depth = 0.035
		var instance := MeshInstance3D.new()
		instance.name = "SchoolLetter%d" % i
		instance.mesh = letters
		instance.material_override = _material("trim")
		instance.position = Vector3(x, _arch_y(x) + 0.34, 0.04)
		instance.rotation.z = atan(-4.2 * (x - middle) / pow((_length - _cut) * 0.5 - 1.0, 2.0))
		root.add_child(instance)
		counts.meshes += 1
		counts.triangles += letters.get_faces().size() / 3
	var marker := Label3D.new()
	marker.name = "BuildingNumber"
	marker.text = "600"
	marker.font_size = 64
	marker.pixel_size = 0.005
	marker.modulate = Color("ece7d5")
	marker.position = Vector3(_cut + 0.5, 1.55, 0.035)
	root.add_child(marker)
	return counts
