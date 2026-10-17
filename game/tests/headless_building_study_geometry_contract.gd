extends SceneTree

const NativeFitDriver = preload("res://game/tests/shared/building_fit_test.gd")
const Geometry = preload("res://game/tests/support/building_study_geometry.gd")
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	# Deliberately off the TriangleMesh snap grid: raw and get_faces must differ.
	var vertices := PackedVector3Array([Vector3(0.000031,0,0), Vector3(0,0,1), Vector3(1,0,0)])
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([2,0,1])
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var nonindexed := ArrayMesh.new()
	var nonindexed_arrays: Array = []
	nonindexed_arrays.resize(Mesh.ARRAY_MAX)
	nonindexed_arrays[Mesh.ARRAY_VERTEX] = vertices
	nonindexed.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, nonindexed_arrays)
	var rejected := Geometry.collect(nonindexed, [Transform3D.IDENTITY], Geometry.INDEXED_ARRAYS)
	check(not rejected.ok and not rejected.errors.is_empty(), "Nonindexed surface must return failure, not crash")
	var pose := Transform3D(Basis(Vector3.UP, 0.37), Vector3(3,2,-4))
	var raw := Geometry.collect(mesh, [pose], Geometry.INDEXED_ARRAYS)
	var expected := PackedVector3Array([pose*vertices[2], pose*vertices[0], pose*vertices[1]])
	check(Geometry.compare(raw, expected, 3).ok, "Indexed order/transform changed")
	var snapped := Geometry.collect(mesh, [pose], Geometry.MESH_GET_FACES)
	var native := PackedVector3Array()
	for v in mesh.get_faces(): native.append(pose*v)
	check(Geometry.compare(snapped, native, 3).ok, "Actual get_faces producer changed")
	check(raw.faces != snapped.faces, "Producer distinction lost")
	var instances := Geometry.collect(mesh, [Transform3D.IDENTITY, pose], Geometry.INDEXED_ARRAYS)
	check(instances.ok and instances.faces.size() == 6, "Packed collection/instance coverage lost")
	var wrong := expected.duplicate()
	wrong[1] += Vector3(0.001,0,0)
	var failed := Geometry.compare(raw, wrong, 3)
	check(not failed.ok and failed.render_faces.size() == 3 and failed.collision_faces.size() == 3, "Failed operands lost or mismatch accepted")
	check(not Geometry.compare(raw, expected, 6).ok, "Wrong expected coverage accepted")
	var empty := Geometry.collect(mesh, [], Geometry.INDEXED_ARRAYS)
	check(not Geometry.compare(empty, PackedVector3Array(), 0).ok, "Equal empty evidence accepted")
	check(not Geometry.collect(mesh, [pose], "guessed_mode").ok, "Unknown producer accepted")
	# Existing producer-specific filtering is opt-in; no implicit degenerate deletion.
	var collapsed := Transform3D(Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO),Vector3.ZERO)
	check(Geometry.collect(mesh, [collapsed], Geometry.INDEXED_ARRAYS).faces.size() == 3, "Default silently filters faces")
	check(not Geometry.collect(mesh, [collapsed], Geometry.MESH_GET_FACES, 1e-12).ok, "Explicit producer cutoff ignored")
	_check_roof_coverage()
	_check_composite_roof_identity()
	await _check_retained_housing_inventory()
	print(JSON.stringify({"ok":failures.is_empty(), "failures":failures}))
	quit(0 if failures.is_empty() else 1)

func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)


func _roof_rect(x0: float, z0: float, x1: float, z1: float, y: float) -> PackedVector3Array:
	var a := Vector3(x0,y,z0); var b := Vector3(x1,y,z0)
	var c := Vector3(x1,y,z1); var d := Vector3(x0,y,z1)
	return PackedVector3Array([a,b,c,a,c,d])


func _check_roof_coverage() -> void:
	var required := _roof_rect(0,0,4,4,10)
	var valid := _roof_rect(0,0,4,4,7)
	# Mixed slope heights deliberately differ from the frozen flat source slab.
	valid[1].y = 9; valid[2].y = 11; valid[4].y = 11
	check(Geometry.roof_coverage(required, Geometry.sky_faces(valid, BaseMaterial3D.CULL_BACK)).ok, "Valid sloped/lower-eave roof rejected")
	check(not Geometry.roof_coverage(required, PackedVector3Array()).ok, "Absent roof passed coverage")
	check(not Geometry.roof_coverage(required, _roof_rect(0,0,2,4,7)).ok, "Partial roof passed required source coverage")
	var reversed := PackedVector3Array()
	for i in range(0, valid.size(), 3): reversed.append_array(PackedVector3Array([valid[i],valid[i+2],valid[i+1]]))
	check(not Geometry.roof_coverage(required, Geometry.sky_faces(reversed, BaseMaterial3D.CULL_BACK)).ok, "Culled reversed roof passed")
	check(Geometry.roof_coverage(required, Geometry.sky_faces(reversed, BaseMaterial3D.CULL_FRONT)).ok, "Actual front-cull roof rejected")
	check(Geometry.roof_coverage(required, Geometry.sky_faces(reversed, BaseMaterial3D.CULL_DISABLED)).ok, "Actual double-sided roof rejected")
	var mixed := reversed.duplicate()
	mixed.append_array(_roof_rect(0,0,1,1,12))
	check(not Geometry.roof_coverage(mixed, Geometry.sky_faces(mixed, BaseMaterial3D.CULL_BACK)).ok, "Small upward roof concealed reversed main roof")
	var inset := _roof_rect(1,1,3,3,7)
	var inset_blocking := Geometry.roof_coverage(inset, Geometry.sky_faces(inset, BaseMaterial3D.CULL_BACK))
	var inset_advisory := Geometry.roof_coverage(required, inset)
	check(inset_blocking.ok and not inset_advisory.ok, "Valid intended inset must pass while larger canonical outline prompts review")
	check(not Geometry.roof_coverage(PackedVector3Array(), PackedVector3Array()).ok, "Absent positive intended roof accepted")
	var courtyard := _roof_rect(0,0,6,2,10)
	courtyard.append_array(_roof_rect(0,4,6,6,10))
	courtyard.append_array(_roof_rect(0,2,2,4,10))
	courtyard.append_array(_roof_rect(4,2,6,4,10))
	check(Geometry.roof_coverage(courtyard, courtyard).ok, "Legitimate source courtyard hole treated as missing roof")
	check(not Geometry.roof_coverage(_roof_rect(0,0,6,6,10), courtyard).ok, "Unspecified courtyard hole incorrectly accepted")
	var shader := Shader.new(); shader.code = "shader_type spatial; render_mode cull_front;"
	var shader_material := ShaderMaterial.new(); shader_material.shader = shader
	check(Geometry.roof_cull_mode(shader_material).mode == BaseMaterial3D.CULL_FRONT, "Shader culling mode ignored")
	shader.code = "shader_type spatial; void fragment() { discard; }"
	check(not Geometry.roof_cull_mode(shader_material).ok, "Ambiguous shader draw assumed visible")
	var owner := Node3D.new(); owner.set_meta("source_keys", ["fixture"])
	owner.set_meta("derived_object_key", "building:fixture:roof")
	root.add_child(owner)
	var visual := MeshInstance3D.new()
	var mesh := ArrayMesh.new(); var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = valid
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var grow := StandardMaterial3D.new(); grow.set_grow_enabled(true)
	check(not Geometry.roof_cull_mode(grow).ok, "Unsupported material vertex grow accepted")
	var back := StandardMaterial3D.new()
	mesh.surface_set_material(0, back)
	visual.mesh = mesh; owner.add_child(visual)
	var source_nodes: Array[Node3D] = [owner]
	var declared := Geometry.visible_roof_faces(source_nodes, "fixture")
	check(Geometry.roof_coverage(required, declared.intended_faces).ok, "Collector omitted intended roof before culling")
	check(Geometry.roof_coverage(required, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Source-owned roof material fallback lost")
	var front := StandardMaterial3D.new(); front.cull_mode = BaseMaterial3D.CULL_FRONT
	visual.set_surface_override_material(0, front)
	declared = Geometry.visible_roof_faces(source_nodes, "fixture")
	check(Geometry.roof_coverage(required, declared.intended_faces).ok and not Geometry.roof_coverage(declared.intended_faces, declared.faces).ok, "Collector discarded culled intended geometry before coverage check")
	check(not Geometry.roof_coverage(required, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Surface material override ignored")
	visual.material_override = back
	check(Geometry.roof_coverage(required, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Instance material override precedence lost")
	visual.set_meta("physical_role", "ground_visual")
	check(not Geometry.roof_coverage(required, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Ground visual counted as roof")
	visual.set_meta("physical_role", "wall")
	check(not Geometry.roof_coverage(required, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Wall top counted as roof")
	# A separately classified pylon roof may share its source wall record owner.
	owner.set_meta("derived_object_key", "building:fixture:wall")
	var corner := _roof_rect(0,0,1,1,10)
	var wall_sibling := MeshInstance3D.new(); wall_sibling.mesh = mesh
	owner.add_child(wall_sibling)
	visual.set_meta("physical_role", "roof")
	check(Geometry.roof_coverage(corner, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Explicit roof child below wall owner omitted")
	visual.visible = false
	check(not Geometry.roof_coverage(corner, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Untagged wall sibling supplied corner roof coverage")
	visual.visible = true
	visual.set_meta("source_key", "other_source")
	check(not Geometry.roof_coverage(corner, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Foreign explicit roof child supplied corner coverage")
	visual.remove_meta("source_key")
	wall_sibling.free()
	# Match normal-play housing: source-bound family under a wall record owner.
	visual.remove_meta("physical_role")
	owner.set_meta("derived_object_key", "building:fixture:wall")
	var family := Node3D.new(); family.set_meta("source_key", "fixture")
	owner.add_child(family)
	owner.remove_child(visual); family.add_child(visual)
	visual.set_meta("family_role", "roof")
	check(Geometry.roof_coverage(required, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Housing roof below wall owner omitted")
	visual.set_meta("family_role", "ground")
	check(not Geometry.roof_coverage(required, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Housing ground accepted as roof")
	visual.set_meta("family_role", "wall")
	check(not Geometry.roof_coverage(required, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Housing wall accepted as roof")
	visual.set_meta("family_role", "roof")
	family.set_meta("source_key", "other_source")
	check(not Geometry.roof_coverage(required, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Foreign housing source supplied roof coverage")
	family.set_meta("source_key", "fixture")
	visual.layers = 2
	check(not Geometry.roof_coverage(required, Geometry.visible_roof_faces(source_nodes, "fixture", 1).faces).ok, "Camera-masked roof supplied coverage")
	visual.layers = 1
	visual.position = Vector3(8,2,0)
	var shifted := _roof_rect(8,0,12,4,10)
	check(Geometry.roof_coverage(shifted, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Actual roof instance transform ignored")
	check(not Geometry.roof_coverage(required, Geometry.visible_roof_faces(source_nodes, "fixture").faces).ok, "Moved roof covered old source position")
	owner.free()


func _check_composite_roof_identity() -> void:
	var nodes: Array[Node3D] = []
	var authorized: Dictionary = {}
	var roofs: Array[MeshInstance3D] = []
	var required := PackedVector3Array()
	for part: String in ["part_a", "part_b"]:
		var domain := _roof_rect(0 if part == "part_a" else 8, 0, 4 if part == "part_a" else 12, 4, 10)
		required.append_array(domain)
		for role: String in ["roof", "wall"]:
			var key := "building-composite:parent:" + part + ":" + role
			var owner := Node3D.new()
			owner.set_meta("source_keys", [part])
			owner.set_meta("derived_object_key", key)
			root.add_child(owner); nodes.append(owner); authorized[key] = part
			var mesh := ArrayMesh.new(); var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = domain
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			mesh.surface_set_material(0, StandardMaterial3D.new())
			var visual := MeshInstance3D.new(); visual.mesh = mesh
			owner.add_child(visual)
			if role == "roof": roofs.append(visual)
	var observed := Geometry.visible_roof_faces(nodes, "parent", 0xFFFFF, authorized)
	check(observed.ok and Geometry.roof_coverage(required, observed.faces).ok, "Authorized disjoint composite part roofs omitted")
	check(not Geometry.visible_roof_faces(nodes, "other_parent", 0xFFFFF, authorized).ok, "Wrong composite parent authorization accepted")
	var roof_owner := roofs[0].get_parent()
	var original_key := str(roof_owner.get_meta("derived_object_key"))
	roof_owner.set_meta("derived_object_key", "building-composite:other_parent:part_a:roof")
	check(not Geometry.visible_roof_faces(nodes, "parent", 0xFFFFF, authorized).ok, "Foreign parent record supplied authorized roof")
	roof_owner.set_meta("derived_object_key", "building-composite:parent:unlisted:roof")
	check(not Geometry.visible_roof_faces(nodes, "parent", 0xFFFFF, authorized).ok, "Unlisted composite record supplied roof")
	roof_owner.set_meta("derived_object_key", original_key)
	roof_owner.set_meta("source_keys", ["part_b"])
	check(not Geometry.visible_roof_faces(nodes, "parent", 0xFFFFF, authorized).ok, "Wrong singleton part source accepted")
	roof_owner.set_meta("source_keys", ["part_a", "part_b"])
	check(not Geometry.visible_roof_faces(nodes, "parent", 0xFFFFF, authorized).ok, "Mixed part ownership accepted")
	roof_owner.set_meta("source_keys", ["part_a"])
	roofs[0].set_meta("source_key", "part_b")
	roofs[0].set_meta("physical_role", "roof")
	check(not Geometry.visible_roof_faces(nodes, "parent", 0xFFFFF, authorized).ok, "Sibling part borrowed descendant ownership")
	roofs[0].remove_meta("source_key")
	roofs[0].remove_meta("physical_role")
	# A matching upward wall sibling cannot rescue an absent declared roof.
	roofs[0].visible = false
	check(not Geometry.visible_roof_faces(nodes, "parent", 0xFFFFF, authorized).ok, "Untagged upward wall rescued missing part roof")
	roofs[0].visible = true
	var reversed := StandardMaterial3D.new(); reversed.cull_mode = BaseMaterial3D.CULL_FRONT
	roofs[0].material_override = reversed
	observed = Geometry.visible_roof_faces(nodes, "parent", 0xFFFFF, authorized)
	check(observed.ok and Geometry.roof_coverage(required, observed.intended_faces).ok and not Geometry.roof_coverage(observed.intended_faces, observed.faces).ok, "Reversed composite roof lost blocking intended domain")
	for node: Node3D in nodes: node.free()


func _check_retained_housing_inventory() -> void:
	var legacy_domain := _roof_rect(0,0,2,4,7)
	var sectional_domain := _roof_rect(2,0,4,4,8)
	var combined := legacy_domain.duplicate(); combined.append_array(sectional_domain)
	check(Geometry.roof_coverage(_roof_rect(0,0,4,4,9), combined).ok, "Both retained roof domains rejected")
	check(not Geometry.roof_coverage(combined, legacy_domain).ok and not Geometry.roof_coverage(combined, sectional_domain).ok, "One roof producer concealed missing other domain")
	var scene := Node3D.new(); root.add_child(scene)
	var wall := Node3D.new(); scene.add_child(wall)
	wall.set_meta("source_keys", ["fixture"]); wall.set_meta("derived_object_key", "building:fixture:wall")
	var family := Node3D.new(); wall.add_child(family); family.set_meta("source_key", "fixture")
	var roof := Node3D.new(); scene.add_child(roof)
	roof.set_meta("source_keys", ["fixture"]); roof.set_meta("derived_object_key", "building:fixture:roof")
	var ground := MeshInstance3D.new(); wall.add_child(ground)
	var top := MeshInstance3D.new(); roof.add_child(top)
	for pair in [[ground, "ground_visual", "building:fixture:wall"], [top, "roof", "building:fixture:roof"]]:
		var node: MeshInstance3D = pair[0]
		node.mesh = BoxMesh.new(); node.set_meta("physical_role", pair[1])
		node.set_meta("source_keys", ["fixture"]); node.set_meta("derived_object_key", pair[2])
	var sectional := MeshInstance3D.new(); family.add_child(sectional)
	sectional.mesh = BoxMesh.new(); sectional.set_meta("family_role", "roof")
	check(Geometry.retained_housing_inventory(scene, family, "fixture").ok, "Valid retained housing inventory rejected")
	sectional.visible = false
	check(not Geometry.retained_housing_inventory(scene, family, "fixture").ok, "Missing sectional roof accepted")
	sectional.visible = true
	sectional.set_meta("source_keys", ["other"])
	check(not Geometry.retained_housing_inventory(scene, family, "fixture").ok, "Foreign sectional roof accepted")
	sectional.remove_meta("source_keys")
	var extra_body := StaticBody3D.new(); scene.add_child(extra_body)
	extra_body.set_meta("source_keys", ["fixture"])
	check(not Geometry.retained_housing_inventory(scene, family, "fixture").ok, "Additional active native owner accepted")
	extra_body.free()

	for wrong in [["other"], ["fixture", "other"]]:
		roof.set_meta("source_keys", wrong)
		check(not Geometry.retained_housing_inventory(scene, family, "fixture").ok, "Foreign/mixed retained roof accepted")
	roof.set_meta("source_keys", ["fixture"])
	for node: MeshInstance3D in [ground, top]:
		var role = node.get_meta("physical_role")
		node.remove_meta("physical_role")
		check(not Geometry.retained_housing_inventory(scene, family, "fixture").ok, "Untagged retained mesh accepted")
		node.set_meta("physical_role", role)
		node.visible = false
		check(not Geometry.retained_housing_inventory(scene, family, "fixture").ok, "Missing retained visual accepted")
		node.visible = true
	var duplicate := Node3D.new(); scene.add_child(duplicate)
	duplicate.set_meta("source_keys", ["fixture"]); duplicate.set_meta("derived_object_key", "building:fixture:roof")
	check(not Geometry.retained_housing_inventory(scene, family, "fixture").ok, "Duplicate retained roof accepted")
	duplicate.free()
	var unclassified := Node3D.new(); wall.add_child(unclassified)
	check(not Geometry.retained_housing_inventory(scene, family, "fixture").ok, "Unknown retained child accepted")
	unclassified.free()
	# Match retained ground ancestry, then append in producer order.
	ground.position = Vector3(2,3,4)
	var first := Geometry.collect(top.mesh, [top.transform], Geometry.MESH_GET_FACES)
	var second := Geometry.collect(ground.mesh, [wall.transform * ground.transform], Geometry.MESH_GET_FACES)
	var faces: PackedVector3Array = first.faces.duplicate(); faces.append_array(second.faces)
	var collection := first.duplicate(); collection.faces = faces
	check(Geometry.compare(collection, faces, faces.size()).ok, "Positive ordered retained append rejected")
	var swapped: PackedVector3Array = second.faces.duplicate(); swapped.append_array(first.faces)
	check(not Geometry.compare(collection, swapped, faces.size()).ok, "Reordered retained append accepted")
	check(not Geometry.compare(collection, first.faces, faces.size()).ok, "Omitted retained ground accepted")
	# Exercise the actual retained-ground predicate against real native shape owners.
	family.set_meta("scope", "approved_shared_family_normal_play"); family.set_meta("build_valid", true)
	var support_mesh := MeshInstance3D.new(); family.add_child(support_mesh)
	support_mesh.mesh = BoxMesh.new(); support_mesh.position = Vector3(10,0,0)
	support_mesh.set_meta("family_role", "support")
	var support := StaticBody3D.new(); family.add_child(support)
	support.collision_layer = 1; support.collision_mask = 0
	support.set_meta("source_keys", ["fixture"]); support.set_meta("derived_object_key", "building:fixture:wall")
	support.set_meta("family_role", "support"); support.set_meta("receiver_kind", "none")
	var support_faces: PackedVector3Array = Geometry.collect(support_mesh.mesh, [support_mesh.transform], Geometry.MESH_GET_FACES).faces
	support_faces.append_array(second.faces)
	var holder := CollisionShape3D.new(); var shape := ConcavePolygonShape3D.new()
	shape.set_faces(support_faces); shape.backface_collision = true; holder.shape = shape; support.add_child(holder)
	var land_owner := Node3D.new(); scene.add_child(land_owner); land_owner.set_meta("feature_kind", "land_ground")
	var land_body := StaticBody3D.new(); land_owner.add_child(land_body)
	await physics_frame
	await physics_frame
	var hit := {"collider": support, "rid": support.get_rid(), "shape": support.shape_owner_get_shape_index(support.get_shape_owners()[0], 0), "position": Vector3(2,3.5,4), "normal": Vector3.UP}
	var land_hit := {"collider": land_body, "position": Vector3(2,3.46,4), "normal": Vector3.UP}
	var proof_cache := {}
	check(Geometry.retained_ground_contact(scene, family, support, hit, land_hit, .35, .001, .7, proof_cache), "Actual retained ground native contact rejected")
	var motion_hit := hit.duplicate()
	motion_hit.erase("rid")
	check(Geometry.retained_ground_contact(scene, family, support, motion_hit, land_hit, .35, .001, .7, proof_cache), "Motion contact without RID rejected")
	motion_hit.rid = land_body.get_rid()
	check(not Geometry.retained_ground_contact(scene, family, support, motion_hit, land_hit, .35, .001, .7, proof_cache), "Explicit wrong RID accepted")
	ground.position.x += 1
	check(not Geometry.retained_ground_contact(scene, family, support, hit, land_hit, .35, .001, .7, proof_cache), "Changed ground transform reused stale proof")
	ground.position.x -= 1
	land_hit.position.y = 0
	check(not Geometry.retained_ground_contact(scene, family, support, hit, land_hit, .35, .001, .7, proof_cache), "Elevated retained ground accepted")
	land_hit.position.y = 3.46
	hit.position.x = 3; land_hit.position.x = 3
	check(not Geometry.retained_ground_contact(scene, family, support, hit, land_hit, .35, .001, .7, proof_cache), "Outside ground face accepted")
	hit.position = Vector3(10,.5,0); land_hit.position = Vector3(10,.46,0)
	check(not Geometry.retained_ground_contact(scene, family, support, hit, land_hit, .35, .001, .7, proof_cache), "Other support face accepted as ground")
	hit.position = Vector3(2,3.5,4); land_hit.position = Vector3(2,3.46,4)
	ground.remove_meta("physical_role")
	check(not Geometry.retained_ground_contact(scene, family, support, hit, land_hit, .35, .001, .7, proof_cache), "Untagged contact accepted")
	ground.set_meta("physical_role", "ground_visual")
	support.set_meta("source_keys", ["other"])
	check(not Geometry.retained_ground_contact(scene, family, support, hit, land_hit, .35, .001, .7, proof_cache), "Foreign support contact accepted")
	support.set_meta("source_keys", ["fixture"])
	hit.shape = -1
	check(not Geometry.retained_ground_contact(scene, family, support, hit, land_hit, .35, .001, .7, proof_cache), "Wrong native shape accepted")
	hit.shape = support.shape_owner_get_shape_index(support.get_shape_owners()[0], 0)
	shape.set_faces(second.faces)
	check(not Geometry.retained_ground_contact(scene, family, support, hit, land_hit, .35, .001, .7, proof_cache), "Incomplete native bucket accepted")
	# Teardown must release both changed resources and still-connected callbacks.
	var shape_lifetime: WeakRef = weakref(shape)
	var mesh_lifetime: WeakRef = weakref(ground.mesh)
	proof_cache.clear()
	scene.free()
	shape = null
	await process_frame
	check(shape_lifetime.get_ref() == null, "Retained proof keeps changed shape alive after teardown")
	check(mesh_lifetime.get_ref() == null, "Retained proof keeps mesh alive after teardown")
