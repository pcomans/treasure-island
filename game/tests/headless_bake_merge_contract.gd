extends SceneTree
## The bake's building merge (tools/merge_baked_buildings.gd) on a hand-built building:
## the same triangles and colours come out, and everything that must stay separate does.

const Merge := preload("res://tools/merge_baked_buildings.gd")

var failures: Array[String] = []
var buildings: Node3D
var record: Node3D


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	buildings = Node3D.new()
	root.add_child(buildings)
	var top := Node3D.new()
	buildings.add_child(top)
	record = Node3D.new()
	record.position = Vector3(100, 0, -50)
	record.set_meta("source_keys", ["w1"])
	record.set_meta("derived_object_key", "building:w1:wall")
	top.add_child(record)
	var wing := Node3D.new()
	wing.position = Vector3(3, 0, 1)
	wing.rotation = Vector3(0, 0.6, 0)
	record.add_child(wing)

	var red := _box(wing, _material(Color(0.8, 0.1, 0.2)), Transform3D(Basis(Vector3.RIGHT, 0.4), Vector3(1, 2, 3)))
	var blue := _box(wing, _material(Color(0.1, 0.2, 0.9)), Transform3D.IDENTITY)
	var unrotated := _box(record, _material(Color(0.5, 0.5, 0.5)), Transform3D.IDENTITY)
	var rough := _box(record, _material(Color(0.8, 0.1, 0.2), 0.2), Transform3D.IDENTITY)
	var roof := _box(record, _material(Color(0.3, 0.3, 0.3)), Transform3D.IDENTITY)
	roof.set_meta("physical_role", "roof")
	var expected := {"red": _world_triangles(red, 0), "blue": _world_triangles(blue, 0), "unrotated": _world_triangles(unrotated, 0), "rough": _world_triangles(rough, 0), "roof": _world_triangles(roof, 0)}
	var red_uvs: PackedVector2Array = red.mesh.surface_get_arrays(0)[Mesh.ARRAY_TEX_UV]
	var red_normal := (red.global_basis * (red.mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL] as PackedVector3Array)[0]).normalized()

	var glass_material := _material(Color(0.6, 0.7, 0.8, 0.4))
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var shader_material := ShaderMaterial.new()
	shader_material.shader = Shader.new()
	shader_material.shader.code = "shader_type spatial;"
	var triplanar_material := _material(Color(0.4, 0.5, 0.6))
	triplanar_material.uv1_triplanar = true
	var kept: Array[MeshInstance3D] = [
		_box(record, glass_material, Transform3D.IDENTITY),
		_box(record, shader_material, Transform3D.IDENTITY),
		_box(record, triplanar_material, Transform3D(Basis.IDENTITY, Vector3(2, 0, 0))),
		_box(record, _material(Color.RED), Transform3D(Basis.IDENTITY.scaled(Vector3(1, 2, 1)), Vector3.ZERO)),
		_box(record, _material(Color.RED), Transform3D(Basis(Vector3(1, 0, 0), Vector3(0.3, 1, 0), Vector3(0, 0, 1)), Vector3.ZERO)),
	]
	var hidden := _box(record, _material(Color.RED), Transform3D.IDENTITY)
	hidden.hide()
	kept.append(hidden)
	var reflective := _box(record, _material(Color.RED), Transform3D.IDENTITY)
	reflective.layers = 4
	kept.append(reflective)
	var ground_visual := _box(record, _material(Color.RED), Transform3D.IDENTITY)
	ground_visual.set_meta("physical_role", "ground_visual")
	kept.append(ground_visual)
	var family := Node3D.new()
	family.set_meta("scope", "approved_shared_family_normal_play")
	family.set_meta("source_key", "w1")
	record.add_child(family)
	kept.append(_box(family, _material(Color.RED), Transform3D.IDENTITY))
	var tagged_support := _box(family, _material(Color.RED), Transform3D.IDENTITY)
	tagged_support.set_meta("family_role", "support")
	kept.append(tagged_support)
	var family_wall := _box(family, _material(Color.GREEN), Transform3D.IDENTITY)
	family_wall.set_meta("family_role", "wall")
	var kept_meshes: Array[Mesh] = []
	for part in kept:
		kept_meshes.append(part.mesh)

	var mixed := _two_surface_part(_material(Color(0.2, 0.6, 0.3)), glass_material)
	var mixed_glass := _triangles(mixed.mesh, 1)

	Merge.merge(buildings)

	check(not is_instance_valid(red) and not is_instance_valid(blue), "Parts that merged must leave the tree")
	for index in kept.size():
		check(is_instance_valid(kept[index]) and kept[index].mesh == kept_meshes[index], "Kept part %d must stay as authored" % index)
	check(is_instance_valid(mixed) and mixed.mesh.get_surface_count() == 1 and mixed.mesh.surface_get_material(0) == glass_material, "A mixed mesh must keep only its glass surface")
	check(is_instance_valid(mixed) and _triangles(mixed.mesh, 0) == mixed_glass, "A kept surface must keep its triangles")

	var wall := _batch(record, "")
	var roof_batch := _batch(record, "roof")
	check(wall != null and roof_batch != null, "Walls and roofs must merge into separate meshes under their record")
	if wall == null or roof_batch == null:
		_finish()
		return
	check(wall.get_meta("baked_merge", false), "Merged meshes must be marked for the web's distance culling")
	check(wall.get_meta("source_keys", []) == [] and wall.get_meta("derived_object_key", "") == "", "A merged mesh must inherit identity its sources inherited")
	check(roof_batch.get_meta("physical_role", "") == "roof", "A merged mesh must carry its sources' role")
	check(wall.mesh.get_surface_count() == 3, "Two roughnesses and one mixed part's channels must stay apart: %d" % wall.mesh.get_surface_count())
	var plain := _surface_with(wall, 0.7, true)
	check(plain >= 0, "The parts that differ only in colour must share a surface")
	if plain >= 0:
		var merged := _world_triangles(wall, plain)
		var want := PackedVector3Array()
		for key: String in ["red", "blue", "unrotated"]:
			want.append_array(expected[key])
		check(_close(merged, want), "Merged triangles must keep their world positions and winding")
		var material := wall.mesh.surface_get_material(plain) as StandardMaterial3D
		check(material.vertex_color_use_as_albedo and material.vertex_color_is_srgb and material.albedo_color == Color.WHITE, "A merged material must take its colour from sRGB vertices")
		var arrays := wall.mesh.surface_get_arrays(plain)
		var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
		check(_byte(colors[0].r) == 204 and _byte(colors[0].g) == 26 and _byte(colors[0].b) == 51, "Vertices must carry the first part's colour, rounded to 8 bits: %s" % colors[0])
		check(_byte(colors[colors.size() - 1].r) == 128, "Vertices must carry the last part's colour: %s" % colors[colors.size() - 1])
		var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
		check(uvs.slice(0, red_uvs.size()) == red_uvs, "UVs must not change")
		var normal := (wall.global_basis * (arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array)[0]).normalized()
		check(normal.distance_to(red_normal) < 0.001, "Normals must follow the part's rotation: %s against %s" % [normal, red_normal])
	check(_close(_world_triangles(roof_batch, 0), expected["roof"]), "A roof's triangles must not move")
	var family_batch := _batch(family, "")
	check(family_batch != null and family_batch.get_meta("family_role", "") == "wall", "A family wall must merge under its family and keep its role")
	_finish()


func _finish() -> void:
	buildings.free()
	if failures.is_empty():
		print("PASS: the bake's building merge keeps triangles, colours and separate surfaces")
		quit(0)
		return
	for message in failures:
		print("FAIL: " + message)
	quit(1)


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _material(color: Color, roughness := 0.7) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material


func _box(parent: Node3D, material: Material, pose: Transform3D) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1, 2, 3)
	part.mesh = mesh
	part.material_override = material
	part.transform = pose
	parent.add_child(part, true)
	return part


func _two_surface_part(first: Material, second: Material) -> MeshInstance3D:
	var mesh := ArrayMesh.new()
	for material: Material in [first, second]:
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0)])
		arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array([Vector3.BACK, Vector3.BACK, Vector3.BACK])
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(mesh.get_surface_count() - 1, material)
	var part := MeshInstance3D.new()
	part.mesh = mesh
	record.add_child(part)
	return part


## The batch directly under parent holding the given physical role ("" for none).
func _batch(parent: Node3D, role: String) -> MeshInstance3D:
	for child: Node in parent.get_children():
		if child.has_meta("baked_merge") and str(child.get_meta("physical_role", "")) == role:
			return child as MeshInstance3D
	return null


## The surface of part with this roughness and whether it has UVs, or -1.
func _surface_with(part: MeshInstance3D, roughness: float, has_uvs: bool) -> int:
	for surface in part.mesh.get_surface_count():
		var material := part.mesh.surface_get_material(surface) as StandardMaterial3D
		if is_equal_approx(material.roughness, roughness) and (part.mesh.surface_get_arrays(surface)[Mesh.ARRAY_TEX_UV] != null) == has_uvs:
			return surface
	return -1


func _triangles(mesh: Mesh, surface: int) -> PackedVector3Array:
	var arrays := mesh.surface_get_arrays(surface)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	if arrays[Mesh.ARRAY_INDEX] == null:
		return vertices
	var triangles := PackedVector3Array()
	for index: int in arrays[Mesh.ARRAY_INDEX]:
		triangles.append(vertices[index])
	return triangles


func _world_triangles(part: MeshInstance3D, surface: int) -> PackedVector3Array:
	return part.global_transform * _triangles(part.mesh, surface)


func _close(a: PackedVector3Array, b: PackedVector3Array) -> bool:
	if a.size() != b.size() or a.is_empty():
		return false
	for i in a.size():
		if a[i].distance_to(b[i]) > 0.0002:
			return false
	return true


func _byte(channel: float) -> int:
	return roundi(channel * 255.0)
