extends SceneTree

const Geometry = preload("res://game/tests/support/building_study_geometry.gd")
var failures: Array[String] = []

func _initialize() -> void:
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
	print(JSON.stringify({"ok":failures.is_empty(), "failures":failures}))
	quit(0 if failures.is_empty() else 1)

func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
