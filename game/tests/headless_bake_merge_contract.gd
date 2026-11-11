extends SceneTree
## The bake's building merge (tools/merge_baked_buildings.gd) on a hand-built building:
## the same triangles and colours come out, and everything that must stay separate does.
## A part that leaves its source but never reaches a batch fails the merge, and the bake's
## prune frees only inert superseded nodes and fails when fewer bodies go than the
## housing family installer switched off.

const Merge := preload("res://tools/merge_baked_buildings.gd")
## The same tool's source, which _check_merge_counts_drop compiles with a fault. (Merge
## is the script's class here, so Merge.resource_path does not parse.)
const MERGE_SOURCE := "res://tools/merge_baked_buildings.gd"
## Parts in this colour are the ones the faulty copy of the tool in
## _check_merge_counts_drop never records.
const DROPPED_COLOR := Color(0.123, 0.456, 0.789)

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

	# A surface override stays on its surface index, so that part stays whole.
	var overridden := _two_surface_part(_material(Color(0.2, 0.6, 0.3)), glass_material)
	var override_material := _material(Color.ORANGE)
	overridden.set_surface_override_material(0, override_material)
	# A mesh another part or a MultiMesh also draws must keep its surfaces.
	var shared_part := _two_surface_part(_material(Color(0.2, 0.6, 0.3)), glass_material)
	var twin := MeshInstance3D.new()
	twin.mesh = shared_part.mesh
	record.add_child(twin)
	var instanced := _two_surface_part(_material(Color(0.2, 0.6, 0.3)), glass_material)
	var drawn_by_multimesh := MultiMeshInstance3D.new()
	drawn_by_multimesh.multimesh = MultiMesh.new()
	drawn_by_multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	drawn_by_multimesh.multimesh.mesh = instanced.mesh
	drawn_by_multimesh.multimesh.instance_count = 1
	record.add_child(drawn_by_multimesh)

	var report := Merge.merge(buildings)
	check((report.problems as PackedStringArray).is_empty(), "A clean merge must report no problems: %s" % report.problems)
	check(int(report.get("taken_indices", 0)) > 0 and int(report.get("taken_vertices", 0)) > 0, "A merge must count what it takes from its sources: %s" % report)

	check(is_instance_valid(overridden) and overridden.mesh.get_surface_count() == 2 and overridden.get_surface_override_material(0) == override_material, "A part with a surface override must stay whole")
	check(is_instance_valid(shared_part) and is_instance_valid(twin) and twin.mesh.get_surface_count() == 2, "A mesh two parts draw must keep its surfaces")
	check(is_instance_valid(instanced) and instanced.mesh.get_surface_count() == 2 and drawn_by_multimesh.multimesh.mesh == instanced.mesh, "A mesh a MultiMesh draws must keep its surfaces")

	# A merged mesh that came out short must be caught, since its sources are gone by then.
	var part_arrays: Array = instanced.mesh.surface_get_arrays(0)
	var group := {"surfaces": {"a": {"parts": [{"arrays": part_arrays}]}, "b": {"parts": [{"arrays": part_arrays}]}}}
	var built := ArrayMesh.new()
	built.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _indexed(part_arrays))
	check(Merge._build_problem(built, group) != "", "A missing surface must be a problem")
	built.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _indexed(part_arrays))
	check(Merge._build_problem(built, group) == "", "A complete mesh must not be a problem")
	group.surfaces.a.parts.append({"arrays": part_arrays})
	check(Merge._build_problem(built, group) != "", "A surface short of indices must be a problem")
	_check_dropped_parts(part_arrays)
	_check_merge_counts_drop()
	_check_prune()

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


## A part that _add_part fails to record (a script error there, say) has left its source
## all the same, so the batches must account for everything merge() took. triangle: an
## unindexed one-triangle surface's arrays.
func _check_dropped_parts(triangle: Array) -> void:
	var anchor := Node3D.new()
	buildings.add_child(anchor)
	var source := MeshInstance3D.new()
	anchor.add_child(source)
	var plain := _material(Color(0.4, 0.4, 0.4))
	var signature := Merge._signature(plain, {})
	var box: Array = BoxMesh.new().surface_get_arrays(0)
	# Both parts recorded and taken: the batch holds them both.
	var whole_groups := {}
	var whole := Merge._group(whole_groups, source, anchor)
	for arrays: Array in [box, triangle]:
		Merge._add_part(whole, signature, plain, arrays, Transform3D.IDENTITY, {})
		Merge._count_taken(whole, arrays)
	var clean := Merge._build_groups(whole_groups)
	check((clean.problems as PackedStringArray).is_empty() and clean.meshes == 1, "A batch holding every part taken for it must build clean: %s" % clean)
	# The triangle leaves its source, but _add_part never records it.
	var short_groups := {}
	var short := Merge._group(short_groups, source, anchor)
	Merge._add_part(short, signature, plain, box, Transform3D.IDENTITY, {})
	Merge._count_taken(short, box)
	Merge._count_taken(short, triangle)
	var problems: PackedStringArray = Merge._build_groups(short_groups).problems
	check(problems.size() == 1 and problems[0].contains("taken from its sources"), "A part dropped after it left its source must fail the merge: %s" % problems)
	# Every part of a group dropped: no batch at all, which must fail too.
	var lost_groups := {}
	Merge._count_taken(Merge._group(lost_groups, source, anchor), triangle)
	problems = Merge._build_groups(lost_groups).problems
	check(problems.size() == 1 and problems[0].contains("taken from its sources"), "A group whose every part was dropped must fail the merge: %s" % problems)


## merge() itself must count what it takes apart from _add_part, or a part that _add_part
## fails to record goes unseen. _add_part records every part merge() can hand it, so the
## drop takes a fault: this compiles the tool's own source with a return put at the top
## of _add_part for parts in DROPPED_COLOR, so they are never recorded (no hook in the
## tool), and runs that copy's merge() on a small building without and with such a part.
func _check_merge_counts_drop() -> void:
	var source := FileAccess.get_file_as_string(MERGE_SOURCE)
	var add_part := RegEx.create_from_string("(?m)^static func _add_part\\(.*\\n").search(source)
	if add_part == null:
		check(false, "The merge tool has no _add_part for the dropped-part case to fault")
		return
	var faulty: Script = GDScript.new()
	faulty.source_code = source.insert(add_part.get_end(), "\tif material.albedo_color.is_equal_approx(%s):\n\t\treturn\n" % var_to_str(DROPPED_COLOR))
	if faulty.reload() != OK:
		check(false, "The merge tool with a faulty _add_part does not compile")
		return
	for drop: bool in [false, true]:
		var site := Node3D.new()
		root.add_child(site)
		var top := Node3D.new()
		site.add_child(top)
		var building := Node3D.new()
		building.set_meta("source_keys", ["w2"])
		top.add_child(building)
		var first := _box(building, _material(Color(0.3, 0.6, 0.2)), Transform3D.IDENTITY)
		var second := _box(building, _material(DROPPED_COLOR if drop else Color(0.6, 0.3, 0.2)), Transform3D.IDENTITY)
		var report: Dictionary = faulty.merge(site)
		var problems: PackedStringArray = report.get("problems", PackedStringArray())
		var taken := not is_instance_valid(first) and not is_instance_valid(second)
		if drop:
			check(taken and problems.size() == 1 and problems[0].contains("taken from its sources"), "merge() must report a part that _add_part dropped after it left its source: %s" % problems)
		else:
			check(taken and problems.is_empty(), "The faulty copy must merge clean when no part drops: %s" % problems)
		site.free()


## The bake's prune of what the housing family installer replaced: every body the
## installer switched off must go.
func _check_prune() -> void:
	var holder := Node3D.new()
	buildings.add_child(holder)
	var hidden := _box(holder, _material(Color.RED), Transform3D.IDENTITY)
	hidden.hide()
	var shown := _box(holder, _material(Color.RED), Transform3D.IDENTITY)
	var first := _switched_off_body(holder)
	var second := _switched_off_body(holder)
	var candidates: Array[Node] = [hidden, shown, first, second]
	var pruned := Merge.prune_superseded(candidates, 2)
	check(pruned.problem == "" and pruned.removed_meshes == 1 and pruned.removed_bodies == 2, "The prune must take the hidden mesh and both switched-off bodies: %s" % pruned)
	check(not is_instance_valid(hidden) and not is_instance_valid(first) and not is_instance_valid(second), "Pruned nodes must be freed")
	check(is_instance_valid(shown), "A shown mesh must stay")
	# Some of the switched-off bodies can't go: one still in a group, one back on a layer.
	var goes := _switched_off_body(holder)
	var grouped := _switched_off_body(holder)
	grouped.add_to_group("still_wanted")
	var live := _switched_off_body(holder)
	live.collision_layer = 1
	var partial: Array[Node] = [goes, grouped, live]
	pruned = Merge.prune_superseded(partial, 3)
	check(pruned.removed_bodies == 1 and str(pruned.problem).contains("switched off 3 bodies") and str(pruned.problem).contains("removed only 1"), "Fewer bodies gone than the installer switched off must fail the prune, naming both counts: %s" % pruned)
	check(not is_instance_valid(goes) and is_instance_valid(grouped) and is_instance_valid(live), "Only the inert body may go: a grouped body and a live one stay")
	# None of them go: no candidates came, none can go, or only meshes go.
	var none: Array[Node] = []
	check(Merge.prune_superseded(none, 3).problem != "", "Switched-off bodies with no candidates must fail the prune")
	var stuck: Array[Node] = [shown, grouped, live]
	check(Merge.prune_superseded(stuck, 2).problem != "", "Candidates none of which can go must fail the prune")
	var hidden_too := _box(holder, _material(Color.RED), Transform3D.IDENTITY)
	hidden_too.hide()
	var meshes_only: Array[Node] = [hidden_too, grouped]
	check(Merge.prune_superseded(meshes_only, 1).problem != "", "Switched-off bodies of which none go must fail the prune, whatever meshes go")
	# A world whose installer switched nothing off has nothing to prune.
	check(Merge.prune_superseded(none, 0).problem == "", "Nothing switched off and nothing to prune must pass")


func _finish() -> void:
	buildings.free()
	if failures.is_empty():
		print("PASS: the bake's building merge keeps triangles, colours and separate surfaces, and fails when a part it took never reaches a batch, merge() itself included; its prune frees only inert superseded nodes and fails when fewer bodies go than the installer switched off")
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


## A body the way the housing installer leaves the one it replaces: off every layer.
func _switched_off_body(parent: Node3D) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = 0
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	body.add_child(shape)
	parent.add_child(body)
	return body


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


## An unindexed triangle's arrays with an index buffer, as merged surfaces have.
func _indexed(arrays: Array) -> Array:
	var copy := arrays.duplicate()
	copy[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2])
	return copy


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
