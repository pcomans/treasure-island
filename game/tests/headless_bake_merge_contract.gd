extends SceneTree
## The bake's building merge (tools/merge_baked_buildings.gd) on a hand-built building:
## the same triangles and colours come out, and everything that must stay separate does,
## a glow's night role (DaySun) among it.
## A part that leaves its source but never reaches a batch fails the merge, and the bake's
## prune frees only inert superseded nodes and fails when fewer bodies go than the
## housing family installer switched off.

const Merge := preload("res://tools/merge_baked_buildings.gd")
const StudyGeometry := preload("res://game/tests/support/building_study_geometry.gd")
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
	# A family with no ground proof (w1 has no roof record, so
	# StudyGeometry.retained_ground_meshes finds none): its support meshes and the
	# record's ground visual join by colour like any part (_check_ground_proof keeps a
	# proof's own).
	var ground_visual := _box(record, _material(Color.RED), Transform3D.IDENTITY)
	ground_visual.set_meta("physical_role", "ground_visual")
	var family := Node3D.new()
	family.set_meta("scope", "approved_shared_family_normal_play")
	family.set_meta("source_key", "w1")
	record.add_child(family)
	var untagged_support := _box(family, _material(Color.RED), Transform3D.IDENTITY)
	var tagged_support := _box(family, _material(Color(0.2, 0.3, 0.9)), Transform3D.IDENTITY)
	tagged_support.set_meta("family_role", "support")
	var family_wall := _box(family, _material(Color.GREEN), Transform3D.IDENTITY)
	family_wall.set_meta("family_role", "wall")
	# Over 50 m: a support part the web draws at any distance, apart from the 3 m ones.
	var long_support := _box(family, _material(Color(0.25, 0.35, 0.45)), Transform3D.IDENTITY)
	(long_support.mesh as BoxMesh).size = Vector3(80, 1, 1)
	long_support.set_meta("family_role", "support")
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

	# A building's glows keep their night role through the merge (DaySun finds them by
	# it in the baked world): a lamp and a daylight fill that differ only in it and in
	# base colour stay apart, each merged material carrying its own (under a record of their own,
	# so the walls checked below stay as they were).
	var lamp_material := _material(Color(0.9, 0.8, 0.6))
	lamp_material.emission_enabled = true
	lamp_material.emission_energy_multiplier = 0.5
	lamp_material.set_meta(DaySun.NIGHT_ROLE, DaySun.LAMP)
	var fill_material := lamp_material.duplicate() as StandardMaterial3D
	fill_material.albedo_color = Color(0.7, 0.6, 0.5)
	fill_material.set_meta(DaySun.NIGHT_ROLE, DaySun.DAYLIGHT_FILL)
	var glow_record := Node3D.new()
	glow_record.set_meta("source_keys", ["w2"])
	glow_record.set_meta("derived_object_key", "building:w2:wall")
	top.add_child(glow_record)
	var lamp_part := _box(glow_record, lamp_material, Transform3D(Basis.IDENTITY, Vector3(0, 5, 0)))
	var fill_part := _box(glow_record, fill_material, Transform3D(Basis.IDENTITY, Vector3(0, 8, 0)))

	var report := Merge.merge(buildings)
	check((report.problems as PackedStringArray).is_empty(), "A clean merge must report no problems: %s" % report.problems)
	var glows := DaySun.building_glows(buildings)
	check(not is_instance_valid(lamp_part) and not is_instance_valid(fill_part) and (glows[DaySun.LAMP] as Array).size() == 1 and (glows[DaySun.DAYLIGHT_FILL] as Array).size() == 1 and (glows.untagged as Array).is_empty() and glows[DaySun.LAMP][0] != glows[DaySun.DAYLIGHT_FILL][0], "A lamp and a daylight fill must merge apart, each keeping its night role (lamps %s, fills %s, untagged %s)" % [glows[DaySun.LAMP], glows[DaySun.DAYLIGHT_FILL], glows.untagged])
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
	_check_same_material()
	_check_surface_limit()
	_check_ground_proof()
	_check_web_distances()

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
	check(_family_batch(family, "wall") != null, "A family wall must merge under its family and keep its role")
	check(not is_instance_valid(untagged_support) and not is_instance_valid(tagged_support) and not is_instance_valid(long_support) and _family_batch(family, "support", 0.0, 50.0) != null and _family_batch(family, "") != null, "Support meshes of a family with no ground proof must join by colour under the family, keeping their role")
	# The web culls support and ground parts by their size: merged, they keep that.
	var support_batch := _family_batch(family, "support", 0.0, 50.0)
	if support_batch != null:
		check(Merge.PREBUILT_WORLD.web_detail_range(float(support_batch.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, 0.0))) == Vector2(200, 20), "Merged 3 m support parts must keep the web's 200 m culling: %s" % support_batch.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, null))
	var long_batch := _family_batch(family, "support", 50.0, INF)
	check(long_batch != null and long_batch != support_batch and Merge.PREBUILT_WORLD.web_detail_range(float(long_batch.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, 0.0))) == Vector2.ZERO, "A support part the web draws at any distance must join apart")
	var ground_batch := _batch(record, "ground_visual")
	check(not is_instance_valid(ground_visual) and ground_batch != null and ground_batch.has_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META), "A ground visual outside any ground proof must join by colour, keeping its role and the web's culling")
	check(_family_batch(family, "wall") != null and not _family_batch(family, "wall").has_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META) and not wall.has_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META), "Walls merged by colour stay drawn at any distance on the web")
	check(int(report.get("ground_proof_families", -1)) == 0, "A family with no roof record has no ground proof: %s" % report.get("ground_proof_families"))
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


## Surfaces joining by material: the same material, or a copy equal in every value,
## joins under one transform, every vertex attribute kept as it was; anything else that
## differs (a parameter, the render priority, the Shader object, the transform, the
## web's distance class) keeps them apart; shaders that sort, blend, animate or read
## per-instance values, transparency and surfaces with LODs stay as authored; a
## surface alone stays in its source.
func _check_same_material() -> void:
	var site := Node3D.new()
	root.add_child(site)
	var top := Node3D.new()
	site.add_child(top)
	var building := Node3D.new()
	building.position = Vector3(-40, 2, 25)
	building.rotation = Vector3(0, 0.8, 0)
	building.set_meta("source_keys", ["w3"])
	building.set_meta("derived_object_key", "building:w3:wall")
	top.add_child(building)
	var object_space := _shader("shader_type spatial;\nuniform vec4 tint : source_color = vec4(0.5, 0.4, 0.3, 1.0);\nvarying vec3 local_position;\nvoid vertex() { local_position = VERTEX; }\nvoid fragment() { ALBEDO = tint.rgb * (0.8 + 0.2 * fract(local_position.y)); }")
	var shared := _shader_material(object_space, Color(0.6, 0.5, 0.4))
	var copy := shared.duplicate() as ShaderMaterial
	var other_tint := _shader_material(object_space, Color(0.6, 0.5, 0.41))
	var other_priority := shared.duplicate() as ShaderMaterial
	other_priority.render_priority = 1
	var same_code := _shader_material(_shader(object_space.code), Color(0.6, 0.5, 0.4))
	var turned := Transform3D(Basis(Vector3.UP, 0.7), Vector3(3, 0, -2))
	var stretched := Transform3D(Basis.IDENTITY.scaled(Vector3(1, 1.5, 1)), Vector3(0, 0, 6))
	var first := _channel_part(building, shared, Transform3D.IDENTITY, true, 4.0, 1)
	var second := _channel_part(building, copy, Transform3D.IDENTITY, false, 4.0, 2)
	var expected := {"first": first.mesh.surface_get_arrays(0), "second": second.mesh.surface_get_arrays(0)}
	var first_global := first.global_transform * (expected.first[Mesh.ARRAY_VERTEX] as PackedVector3Array)
	var detail := maxf(_world_longest(first), _world_longest(second))
	check(Merge.shader_refusal(object_space) == "", "An opaque shader reading object space must not be refused: %s" % Merge.shader_refusal(object_space))
	var alone: Array[MeshInstance3D] = [
		_channel_part(building, other_tint, Transform3D.IDENTITY, true, 4.0, 3),
		_channel_part(building, other_priority, Transform3D.IDENTITY, true, 4.0, 4),
		_channel_part(building, same_code, Transform3D.IDENTITY, true, 4.0, 5),
	]
	var turned_parts: Array[MeshInstance3D] = [_channel_part(building, shared, turned, true, 4.0, 6), _channel_part(building, shared, turned, false, 4.0, 7)]
	var turned_arrays: Array = [turned_parts[0].mesh.surface_get_arrays(0), turned_parts[1].mesh.surface_get_arrays(0)]
	var turned_global := turned_parts[1].global_transform * (turned_arrays[1][Mesh.ARRAY_VERTEX] as PackedVector3Array)
	var stretched_parts: Array[MeshInstance3D] = [_channel_part(building, shared, stretched, true, 4.0, 8), _channel_part(building, copy, stretched, true, 4.0, 9)]
	# Over 50 m long however it turns: a part the web draws at any distance, apart from the 4 m ones.
	var long_parts: Array[MeshInstance3D] = [_channel_part(building, shared, Transform3D.IDENTITY, true, 90.0, 10), _channel_part(building, shared, Transform3D.IDENTITY, true, 90.0, 11)]
	# Pairs that would join but for what they draw with.
	var refused := {}
	for case: String in ["ALPHA", "TIME", "INSTANCE_ID", "VERTEX_ID", "instance uniform", "depth_draw_never", "blend_add"]:
		var code: String = {
			"ALPHA": "shader_type spatial;\nvoid fragment() { ALBEDO = vec3(0.5); ALPHA = 0.5; }",
			"TIME": "shader_type spatial;\nvoid fragment() { ALBEDO = vec3(fract(TIME)); }",
			"INSTANCE_ID": "shader_type spatial;\nvarying float id;\nvoid vertex() { id = float(INSTANCE_ID); }\nvoid fragment() { ALBEDO = vec3(id); }",
			"VERTEX_ID": "shader_type spatial;\nvarying float id;\nvoid vertex() { id = float(VERTEX_ID); }\nvoid fragment() { ALBEDO = vec3(id); }",
			"instance uniform": "shader_type spatial;\ninstance uniform vec4 shade : source_color;\nvoid fragment() { ALBEDO = shade.rgb; }",
			"depth_draw_never": "shader_type spatial;\nrender_mode depth_draw_never;\nvoid fragment() { ALBEDO = vec3(0.3); }",
			"blend_add": "shader_type spatial;\nrender_mode blend_add;\nvoid fragment() { ALBEDO = vec3(0.3); }",
		}[case]
		var material := _shader_material(_shader(code), Color.WHITE)
		check(Merge.shader_refusal(material.shader) != "", "A shader using %s must be refused" % case)
		refused[case] = [_channel_part(building, material, Transform3D.IDENTITY, true, 4.0, 20), _channel_part(building, material, Transform3D.IDENTITY, true, 4.0, 21)]
	var see_through := _material(Color(0.5, 0.6, 0.7, 0.5))
	see_through.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	refused["transparency"] = [_channel_part(building, see_through, Transform3D.IDENTITY, true, 4.0, 22), _channel_part(building, see_through, Transform3D.IDENTITY, true, 4.0, 23)]
	var lod_material := _shader_material(object_space, Color(0.2, 0.3, 0.4))
	refused["lods"] = [_channel_part(building, lod_material, Transform3D.IDENTITY, true, 4.0, 24, true), _channel_part(building, lod_material, Transform3D.IDENTITY, true, 4.0, 25, true)]
	var refused_meshes := {}
	for case: String in refused:
		refused_meshes[case] = [refused[case][0].mesh, refused[case][1].mesh]
	# Triplanar mapping by object space joins under one transform only.
	var triplanar := _material(Color(0.4, 0.5, 0.6))
	triplanar.uv1_triplanar = true
	var triplanar_joined: Array[MeshInstance3D] = [_channel_part(building, triplanar, turned, true, 4.0, 30), _channel_part(building, triplanar, turned, true, 4.0, 31)]
	var triplanar_apart: Array[MeshInstance3D] = [_channel_part(building, triplanar, Transform3D(Basis.IDENTITY, Vector3(1, 0, 0)), true, 4.0, 32), _channel_part(building, triplanar, Transform3D(Basis.IDENTITY, Vector3(2, 0, 0)), true, 4.0, 33)]
	# A building's lamps keep their night role (DaySun finds them by it).
	var lamp := _shader_material(_shader("shader_type spatial;\nuniform vec4 glow : source_color = vec4(1.0, 0.8, 0.5, 1.0);\nvoid fragment() { ALBEDO = vec3(0.1); EMISSION = glow.rgb; }"), Color(1.0, 0.8, 0.5))
	lamp.set_meta(DaySun.NIGHT_ROLE, DaySun.LAMP)
	var lamp_copy := lamp.duplicate() as ShaderMaterial
	var lamps: Array[MeshInstance3D] = [_channel_part(building, lamp, Transform3D.IDENTITY, true, 4.0, 40), _channel_part(building, lamp_copy, Transform3D.IDENTITY, true, 4.0, 41)]
	# The 4 m parts under no transform that join: the batch's box must be theirs.
	var bounds := first.mesh.get_aabb()
	for part: MeshInstance3D in [second, lamps[0], lamps[1]]:
		bounds = bounds.merge(part.mesh.get_aabb())

	var report := Merge.merge(site)
	check((report.problems as PackedStringArray).is_empty(), "A clean merge by material must report no problems: %s" % report.problems)
	check(int(report.get("surfaces_by_material", 0)) > 0 and int(report.get("taken_by_material", 0)) > 0, "A merge by material must count what it takes: %s" % report)
	check(not is_instance_valid(first) and not is_instance_valid(second), "The same material and an equal copy must join")
	var joined := _batch_with(building, shared, Transform3D.IDENTITY, 0.0, 50.0)
	check(joined != null, "Parts of one material under one transform must join into a batch under their record")
	if joined != null:
		var surface := _surface_of(joined, shared)
		check(joined.get_meta("baked_merge", false) and is_equal_approx(float(joined.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, -1.0)), detail), "A batch by material must carry its parts' size for the web's culling: %s against %s" % [joined.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, null), detail])
		check(Merge.PREBUILT_WORLD.web_detail_range(float(joined.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, 0.0))) == Vector2(200, 20), "4 m parts must keep the web's 200 m culling")
		check(surface >= 0, "The batch must draw with the first part's own material")
		if surface >= 0:
			var arrays := joined.mesh.surface_get_arrays(surface)
			for channel: int in [Mesh.ARRAY_VERTEX, Mesh.ARRAY_NORMAL, Mesh.ARRAY_TANGENT, Mesh.ARRAY_COLOR, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_TEX_UV2, Mesh.ARRAY_CUSTOM0]:
				var want: Variant = expected.first[channel].duplicate()
				want.append_array(expected.second[channel])
				check(arrays[channel] == want, "Channel %d must come through exactly: %s" % [channel, _difference(arrays[channel], want)])
			var count := (expected.first[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
			var indices := PackedInt32Array(expected.first[Mesh.ARRAY_INDEX])
			for i in (expected.second[Mesh.ARRAY_VERTEX] as PackedVector3Array).size():
				indices.append(count + i)
			check(arrays[Mesh.ARRAY_INDEX] == indices, "Triangles must keep their order, an unindexed part's indexed one per vertex")
			check(joined.global_transform * (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).slice(0, count) == first_global, "A part under no transform must keep its world positions exactly")
			check(joined.mesh.get_aabb().is_equal_approx(bounds), "A batch's box must be its parts' box: %s against %s" % [joined.mesh.get_aabb(), bounds])
	for index in alone.size():
		check(is_instance_valid(alone[index]), "A part whose material differs (%s) must stay as authored" % ["a parameter", "the render priority", "another Shader object"][index])
	var turned_batch := _batch_with(building, shared, turned)
	check(turned_batch != null and not is_instance_valid(turned_parts[0]) and not is_instance_valid(turned_parts[1]), "Parts under one turned transform must join, the batch keeping that transform")
	if turned_batch != null:
		var arrays := turned_batch.mesh.surface_get_arrays(_surface_of(turned_batch, shared))
		var count := (turned_arrays[0][Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
		check((arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).slice(count) == turned_arrays[1][Mesh.ARRAY_VERTEX], "Joined parts must keep their object-space positions")
		check(_close(turned_batch.global_transform * (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).slice(count), turned_global), "Joined parts must keep their world positions")
	check(_batch_with(building, shared, stretched) != null and not is_instance_valid(stretched_parts[0]) and not is_instance_valid(stretched_parts[1]), "Scaled parts under one transform must join, the batch keeping the scale")
	var long_batch := _batch_with(building, shared, Transform3D.IDENTITY, 50.0, INF)
	check(long_batch != null and long_batch != joined and Merge.PREBUILT_WORLD.web_detail_range(float(long_batch.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, 0.0))) == Vector2.ZERO, "Parts the web culls at another distance must join apart")
	for case: String in refused:
		var parts: Array = refused[case]
		check(is_instance_valid(parts[0]) and is_instance_valid(parts[1]) and parts[0].mesh == refused_meshes[case][0] and parts[1].mesh == refused_meshes[case][1] and parts[0].mesh.get_surface_count() == 1, "Parts with %s must stay as authored" % case)
	check(int(report.get("surfaces_with_lods", 0)) == 2, "Surfaces with LODs must be counted and kept: %s" % report.get("surfaces_with_lods"))
	check(_batch_with(building, triplanar, turned) != null and not is_instance_valid(triplanar_joined[0]), "Triplanar parts under one transform must join")
	check(is_instance_valid(triplanar_apart[0]) and is_instance_valid(triplanar_apart[1]), "Triplanar parts under different transforms must stay apart")
	var glows := DaySun.building_glows(site)
	check(not is_instance_valid(lamps[0]) and not is_instance_valid(lamps[1]) and glows[DaySun.LAMP] == [lamp] and (glows.untagged as Array).is_empty(), "Lamps must join and keep their night role: %s" % [glows])
	site.free()


## The colour merge and the merge by material each split a batch into surfaces of at most
## MAX_SURFACE_VERTICES vertices, at parts' edges, keeping every triangle.
func _check_surface_limit() -> void:
	var site := Node3D.new()
	root.add_child(site)
	var top := Node3D.new()
	site.add_child(top)
	var building := Node3D.new()
	building.set_meta("source_keys", ["w4"])
	top.add_child(building)
	var shader := _shader_material(_shader("shader_type spatial;\nvoid fragment() { ALBEDO = vec3(0.4); }"), Color.WHITE)
	var parts := 3
	var per_part := 30000
	for index in parts:
		for material: Material in [shader, _material(Color(0.1 * index, 0.2, 0.3))]:
			var arrays: Array = []
			arrays.resize(Mesh.ARRAY_MAX)
			var vertices := PackedVector3Array()
			for i in per_part:
				vertices.append(Vector3(fmod(i * 0.37, 8.0), fmod(i * 0.61, 8.0), fmod(i * 0.89, 8.0)))
			arrays[Mesh.ARRAY_VERTEX] = vertices
			var mesh := ArrayMesh.new()
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			var part := MeshInstance3D.new()
			part.mesh = mesh
			part.material_override = material
			building.add_child(part)
	var report := Merge.merge(site)
	check((report.problems as PackedStringArray).is_empty(), "A split batch must build clean: %s" % report.problems)
	var batches := 0
	for child: Node in building.get_children():
		if child.has_meta("baked_merge"):
			batches += 1
			var mesh := (child as MeshInstance3D).mesh
			var total := 0
			for surface in mesh.get_surface_count():
				check(mesh.surface_get_array_len(surface) <= Merge.MAX_SURFACE_VERTICES, "A merged surface must stay within 16-bit indices: %d vertices" % mesh.surface_get_array_len(surface))
				total += mesh.surface_get_array_len(surface)
			check(mesh.get_surface_count() == 2 and total == parts * per_part, "Three parts of %d vertices must split in two surfaces holding them all: %d surfaces, %d vertices" % [per_part, mesh.get_surface_count(), total])
	check(batches == 2, "Both merges must build their batch: %d" % batches)
	site.free()


## A housing family that keeps the production ground (a roof record with its roof, a
## ground visual beside the family): StudyGeometry.retained_ground_contact compares its
## support meshes and that ground with their collider in order, so the merge leaves
## exactly those (StudyGeometry.retained_ground_meshes) as they are, though their plain
## materials would join by colour, and they are still what the proof compares after it.
func _check_ground_proof() -> void:
	var site := Node3D.new()
	root.add_child(site)
	var top := Node3D.new()
	site.add_child(top)
	var wall := Node3D.new()
	wall.set_meta("source_keys", ["w5"])
	wall.set_meta("derived_object_key", "building:w5:wall")
	top.add_child(wall)
	var family := Node3D.new()
	family.set_meta("scope", "approved_shared_family_normal_play")
	family.set_meta("source_key", "w5")
	family.set_meta("build_valid", true)
	wall.add_child(family)
	var steps := _box(family, _material(Color(0.5, 0.4, 0.3)), Transform3D.IDENTITY)
	var porch := _box(family, _material(Color(0.3, 0.4, 0.5)), Transform3D(Basis.IDENTITY, Vector3(0, 0, 4)))
	porch.set_meta("family_role", "support")
	var ground := _box(wall, _material(Color(0.4, 0.5, 0.4)), Transform3D(Basis.IDENTITY, Vector3(5, 0, 0)))
	for key: String in ["source_keys", "derived_object_key"]:
		ground.set_meta(key, wall.get_meta(key))
	ground.set_meta("physical_role", "ground_visual")
	var roof_owner := Node3D.new()
	roof_owner.set_meta("source_keys", ["w5"])
	roof_owner.set_meta("derived_object_key", "building:w5:roof")
	top.add_child(roof_owner)
	var roof := _box(roof_owner, _material(Color(0.3, 0.3, 0.3)), Transform3D(Basis.IDENTITY, Vector3(0, 6, 0)))
	for key: String in ["source_keys", "derived_object_key"]:
		roof.set_meta(key, roof_owner.get_meta(key))
	roof.set_meta("physical_role", "roof")
	var proof := StudyGeometry.retained_ground_meshes(root, family)
	check(proof == [steps, porch, ground], "The fixture must have a ground proof of its support meshes and ground, in order: %s" % [proof])
	var meshes := [steps.mesh, porch.mesh, ground.mesh]
	var report := Merge.merge(site)
	check((report.problems as PackedStringArray).is_empty(), "A merge beside a ground proof must report no problems: %s" % report.problems)
	check(int(report.get("ground_proof_families", 0)) == 1 and int(report.get("ground_proof_meshes", 0)) == 3, "The merge must find the one proof and its three meshes: %s" % report)
	check(is_instance_valid(steps) and is_instance_valid(porch) and is_instance_valid(ground) and [steps.mesh, porch.mesh, ground.mesh] == meshes, "A ground proof's meshes must stay as authored")
	check(StudyGeometry.retained_ground_meshes(root, family) == proof, "The proof must compare the same meshes after the merge")
	check(not is_instance_valid(roof) and _batch(roof_owner, "roof") != null, "The kept roof must still join by colour under its record, keeping its role")
	site.free()


## The web culls each unmerged part by its whole mesh's size, and drew a mesh the merge
## by colour had partly taken by what that left of it (main.gd). Merged and left-over
## parts keep the distance the web drew them to: a surface joining by material from a
## mesh the merge by colour left takes that left-over size, not the mesh's; a mesh
## that keeps some surfaces keeps its size and box; a batch never mixes distances; the
## merge says how far a batch's fade moved from its parts'.
func _check_web_distances() -> void:
	var site := Node3D.new()
	root.add_child(site)
	var top := Node3D.new()
	site.add_child(top)
	var building := Node3D.new()
	building.set_meta("source_keys", ["w6"])
	top.add_child(building)
	var shader := _shader("shader_type spatial;\nuniform vec4 tint : source_color = vec4(0.5, 0.4, 0.3, 1.0);\nvoid fragment() { ALBEDO = tint.rgb; }")
	var long_material := _shader_material(shader, Color(0.6, 0.5, 0.4))
	var unique := _shader_material(shader, Color(0.2, 0.5, 0.4))
	var small_material := _shader_material(shader, Color(0.3, 0.3, 0.6))
	# A 60 m surface joins by material; its mesh keeps a 5 m one (both drawn at any
	# distance before, as their mesh was 60 m long).
	var keeper := _strip_part(building, [[long_material, 60.0, 0.0], [unique, 5.0, 1.0]])
	var keeper_box := keeper.mesh.get_aabb()
	var twin := _strip_part(building, [[long_material, 60.0, 2.0]])
	# 5 m surfaces whose 60 m plain neighbours join by colour: the web drew them by the
	# 5 m the merge by colour left, culling them at 200 m.
	var left := _strip_part(building, [[_material(Color(0.7, 0.7, 0.7)), 60.0, 10.0], [small_material, 5.0, 11.0]])
	var right := _strip_part(building, [[_material(Color(0.6, 0.6, 0.7)), 60.0, 12.0], [small_material, 5.0, 13.0]])
	var report := Merge.merge(site)
	check((report.problems as PackedStringArray).is_empty(), "A merge of partly taken meshes must report no problems: %s" % report.problems)
	var long_batch := _batch_with(building, long_material, Transform3D.IDENTITY)
	check(long_batch != null and not is_instance_valid(twin) and Merge.PREBUILT_WORLD.web_detail_range(float(long_batch.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, -1.0))) == Vector2.ZERO, "A 60 m surface joining by material must keep being drawn at any distance")
	check(is_instance_valid(keeper) and keeper.mesh.get_surface_count() == 1 and keeper.mesh.surface_get_material(0) == unique, "A mesh must keep the surface no other shares")
	if is_instance_valid(keeper):
		check(keeper.custom_aabb == keeper_box and Merge.PREBUILT_WORLD.web_detail_range(float(keeper.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, -1.0))) == Vector2.ZERO, "A mesh that kept a 5 m surface of a 60 m one must keep its box and its distance: %s, %s" % [keeper.custom_aabb, keeper.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, null)])
	var small_batch := _batch_with(building, small_material, Transform3D.IDENTITY)
	check(small_batch != null and not is_instance_valid(left) and not is_instance_valid(right), "5 m surfaces must join by material once their 60 m neighbours joined by colour")
	if small_batch != null:
		check(Merge.PREBUILT_WORLD.web_detail_range(float(small_batch.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, -1.0))) == Vector2(200, 20), "5 m surfaces the web culled at 200 m must keep that once joined, not take their old meshes' 60 m: %s" % small_batch.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, null))
	for child: Node in building.get_children():
		if child.has_meta("baked_merge") and child.has_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META):
			var range_m := Merge.PREBUILT_WORLD.web_detail_range(float(child.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META)))
			for surface in (child as MeshInstance3D).mesh.get_surface_count():
				var material: Material = (child as MeshInstance3D).mesh.surface_get_material(surface)
				var expected := Vector2(200, 20) if material == small_material else Vector2.ZERO
				check(range_m == expected, "A batch must hold parts of one web distance, its own: %s holds %s" % [range_m, material])
		elif child.has_meta("baked_merge"):
			check(not (child as MeshInstance3D).mesh.surface_get_material(0) is ShaderMaterial, "Only the merge by colour's own batches may go without a size")
	var shift := float(report.get("most_fade_shift_m", -1.0))
	check(shift > 0.5 and shift < 2.0, "The merge must say how far a culled batch's fade moved from its parts' (two 5 m parts 2 m apart): %s" % shift)
	site.free()


## A part with one surface per [material, length along x (m), z], each a 1 m wide strip.
func _strip_part(parent: Node3D, strips: Array) -> MeshInstance3D:
	var mesh := ArrayMesh.new()
	for strip: Array in strips:
		var length: float = strip[1]
		var z: float = strip[2]
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3(0, 0, z), Vector3(length, 0, z), Vector3(0, 0, z + 1), Vector3(length, 0, z + 1)])
		arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array([Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP])
		arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2, 2, 1, 3])
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(mesh.get_surface_count() - 1, strip[0])
	var part := MeshInstance3D.new()
	part.mesh = mesh
	parent.add_child(part, true)
	return part


func _finish() -> void:
	buildings.free()
	if failures.is_empty():
		print("PASS: the bake's building merge keeps triangles, colours and separate surfaces, and fails when a part it took never reaches a batch, merge() itself included; surfaces of one material (or an equal copy) join under one transform with every attribute as it was, while other materials, transforms, web distances, shaders that sort, blend, animate or read per-instance values, transparency and surfaces with LODs stay apart; merged surfaces stay within 16-bit indices; a housing family's ground proof keeps its meshes as authored while other families' support and ground meshes join by colour; every merged or left-over part keeps the distance the web drew it to, a batch never mixing distances; its prune frees only inert superseded nodes and fails when fewer bodies go than the installer switched off")
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


## The batch directly under a family holding the given family role ("" for none), and
## for a batch carrying its parts' size for the web's culling, that size in
## [detail_from, detail_to).
func _family_batch(family: Node3D, role: String, detail_from := -INF, detail_to := INF) -> MeshInstance3D:
	for child: Node in family.get_children():
		if child.has_meta("baked_merge") and str(child.get_meta("family_role", "")) == role:
			var detail := float(child.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, 0.0))
			if detail >= detail_from and detail < detail_to:
				return child as MeshInstance3D
	return null


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


func _shader(code: String) -> Shader:
	var shader := Shader.new()
	shader.code = code
	return shader


func _shader_material(shader: Shader, tint: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = shader
	if shader.code.contains("uniform vec4 tint"):
		material.set_shader_parameter("tint", tint)
	return material


## A part of size metres along x whose one surface carries every channel a merge by
## material keeps (normals, tangents, colours, two UV sets, an RGBA8 custom channel),
## with values that vary by seed; indexed or not, with LODs or not.
func _channel_part(parent: Node3D, material: Material, pose: Transform3D, indexed: bool, size: float, seed: int, lods := false) -> MeshInstance3D:
	var count := 4 if indexed else 6
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var tangents := PackedFloat32Array()
	var colors := PackedColorArray()
	var uvs := PackedVector2Array()
	var uv2s := PackedVector2Array()
	var custom := PackedByteArray()
	for i in count:
		var t := float(i * 7 + seed)
		vertices.append(Vector3(size * float(i % 2), 0.5 * floorf(i / 2.0) + 0.01 * seed, 0.3 * sin(t)))
		var normal := Vector3(sin(t * 1.3), cos(t * 0.7) + 0.2, sin(t * 0.3 + 1.0)).normalized()
		normals.append(normal)
		var tangent := normal.cross(Vector3.UP if absf(normal.y) < 0.9 else Vector3.RIGHT).normalized()
		tangents.append_array(PackedFloat32Array([tangent.x, tangent.y, tangent.z, 1.0 if i % 2 == 0 else -1.0]))
		colors.append(Color(fmod(t * 0.13, 1.0), fmod(t * 0.29, 1.0), fmod(t * 0.47, 1.0), 1.0))
		uvs.append(Vector2(t * 0.01, t * 0.02))
		uv2s.append(Vector2(t * 0.03, -t * 0.05))
		custom.append_array(PackedByteArray([(seed * 11 + i) % 256, (seed * 13 + i * 3) % 256, (seed * 17 + i * 5) % 256, 255]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TANGENT] = tangents
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_TEX_UV2] = uv2s
	arrays[Mesh.ARRAY_CUSTOM0] = custom
	if indexed:
		arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2, 2, 1, 3])
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {0.25: PackedInt32Array([0, 1, 2])} if lods else {}, Mesh.ARRAY_CUSTOM_RGBA8_UNORM << Mesh.ARRAY_FORMAT_CUSTOM0_SHIFT)
	mesh.surface_set_material(0, material)
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.transform = pose
	parent.add_child(part, true)
	return part


## The batch directly under parent drawn at pose with this material, whose parts' size
## (for the web's culling) is in [detail_from, detail_to), or null.
func _batch_with(parent: Node3D, material: Material, pose: Transform3D, detail_from := 0.0, detail_to := INF) -> MeshInstance3D:
	for child: Node in parent.get_children():
		if child.has_meta("baked_merge") and (child as MeshInstance3D).transform == pose and _surface_of(child, material) >= 0:
			var detail := float(child.get_meta(Merge.PREBUILT_WORLD.DETAIL_SIZE_META, 0.0))
			if detail >= detail_from and detail < detail_to:
				return child as MeshInstance3D
	return null


func _surface_of(part: MeshInstance3D, material: Material) -> int:
	for surface in part.mesh.get_surface_count():
		if part.mesh.surface_get_material(surface) == material:
			return surface
	return -1


func _world_longest(part: MeshInstance3D) -> float:
	var size := (part.global_transform * part.get_aabb()).size
	return maxf(size.x, maxf(size.y, size.z))


## Where two arrays first differ, for a failure message.
func _difference(got: Variant, want: Variant) -> String:
	if got == null or want == null:
		return "got %s, want %s" % [type_string(typeof(got)), type_string(typeof(want))]
	if got.size() != want.size():
		return "%d values, want %d" % [got.size(), want.size()]
	for i in got.size():
		if got[i] != want[i]:
			return "first at %d: %s, want %s" % [i, got[i], want[i]]
	return "none"
