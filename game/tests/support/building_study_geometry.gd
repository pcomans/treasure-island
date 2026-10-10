extends RefCounted
## Shared native-evidence collection. Select the producer actually used by the
## collider; indexed arrays and Mesh.get_faces() are deliberately different.
## Callers retain target identity/roles, body ownership and movement/rest checks.

const INDEXED_ARRAYS := "indexed_arrays"
const MESH_GET_FACES := "mesh_get_faces"

# Transforms are applied in supplied order, mesh-local -> collision-local.
# For MultiMesh, pass instance.transform * multimesh.get_instance_transform(i).
# A nonnegative cutoff is only for a producer that already drops such triangles.
static func collect(mesh: Mesh, transforms: Array[Transform3D], producer: String,
		minimum_cross_length_squared: float = -1.0) -> Dictionary:
	var local_faces := PackedVector3Array()
	var faces := PackedVector3Array()
	var errors: Array[String] = []
	if mesh == null:
		errors.append("Missing mesh")
	elif producer == INDEXED_ARRAYS:
		for surface in mesh.get_surface_count():
			if mesh is ArrayMesh and (mesh as ArrayMesh).surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
				errors.append("Non-triangle surface %d" % surface)
				continue
			var arrays: Array = mesh.surface_get_arrays(surface)
			if arrays.size() != Mesh.ARRAY_MAX or not arrays[Mesh.ARRAY_VERTEX] is PackedVector3Array or not arrays[Mesh.ARRAY_INDEX] is PackedInt32Array:
				errors.append("Missing indexed vertex/index arrays at surface %d" % surface)
				continue
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			if indices.is_empty() or indices.size() % 3 != 0:
				errors.append("Missing/incomplete indexed triangles at surface %d" % surface)
				continue
			for index in indices:
				if index < 0 or index >= vertices.size():
					errors.append("Index outside vertex array at surface %d" % surface)
					break
				local_faces.append(vertices[index])
	elif producer == MESH_GET_FACES:
		# Preserve Godot's actual TriangleMesh conversion, including local snapping.
		local_faces = mesh.get_faces()
	else:
		errors.append("Unknown producer: %s" % producer)
	if local_faces.size() % 3 != 0:
		errors.append("Incomplete local triangles")
	if transforms.is_empty():
		errors.append("No instance transforms")
	if errors.is_empty():
		for pose in transforms:
			for offset in range(0, local_faces.size(), 3):
				var a: Vector3 = pose * local_faces[offset]
				var b: Vector3 = pose * local_faces[offset + 1]
				var c: Vector3 = pose * local_faces[offset + 2]
				if not a.is_finite() or not b.is_finite() or not c.is_finite():
					errors.append("Nonfinite transformed triangle")
				if minimum_cross_length_squared >= 0.0 and (b-a).cross(c-a).length_squared() < minimum_cross_length_squared:
					continue
				faces.append(a)
				faces.append(b)
				faces.append(c)
	# Assign completed typed arrays; mutating a cast dictionary temporary can lose data.
	return {"ok": errors.is_empty() and not faces.is_empty(), "errors": errors,
		"producer": producer, "faces": faces, "local_faces": local_faces,
		"transforms": transforms, "minimum_cross_length_squared": minimum_cross_length_squared}

# Exact ordered comparison, not a tolerance/union/ownership or gameplay verdict.
# Write this result into the existing receipt before raising the caller's guard.
static func compare(collection: Dictionary, collision_faces: PackedVector3Array,
		expected_vertex_count: int) -> Dictionary:
	var faces: PackedVector3Array = collection["faces"]
	var predicates := {"collection": bool(collection["ok"]),
		"positive_expected_coverage": expected_vertex_count > 0 and expected_vertex_count % 3 == 0,
		"render_count": faces.size() == expected_vertex_count,
		"collision_count": collision_faces.size() == expected_vertex_count,
		"ordered_faces_equal": faces == collision_faces}
	var ok := true
	for value in predicates.values():
		ok = ok and bool(value)
	return {"ok": ok, "predicates": predicates, "expected_vertex_count": expected_vertex_count,
		"producer": collection["producer"], "errors": collection["errors"],
		"minimum_cross_length_squared": collection["minimum_cross_length_squared"],
		"render_faces": face_values(faces), "collision_faces": face_values(collision_faces),
		"local_faces": face_values(collection["local_faces"]),
		"transforms": var_to_bytes(collection["transforms"]).hex_encode()}

static func face_values(faces: PackedVector3Array) -> Array:
	var rows: Array = []
	for vertex in faces:
		rows.append([vertex.x, vertex.y, vertex.z])
	return rows


# Exact oriented triangle multiset, for producers that reorder material buckets.
# Preserve vertex order and duplicate multiplicity; no snapping or omitted faces.
static func compare_triangle_multiset(render_faces: PackedVector3Array, collision_faces: PackedVector3Array) -> Dictionary:
	var positive := not render_faces.is_empty() and render_faces.size() % 3 == 0
	var complete := collision_faces.size() == render_faces.size() and collision_faces.size() % 3 == 0
	var finite := true
	var remaining := {}
	if positive and complete:
		for offset in range(0, render_faces.size(), 3):
			var triangle := [render_faces[offset], render_faces[offset + 1], render_faces[offset + 2]]
			for vertex: Vector3 in triangle:
				finite = finite and vertex.is_finite()
			remaining[triangle] = int(remaining.get(triangle, 0)) + 1
		for offset in range(0, collision_faces.size(), 3):
			var triangle := [collision_faces[offset], collision_faces[offset + 1], collision_faces[offset + 2]]
			for vertex: Vector3 in triangle:
				finite = finite and vertex.is_finite()
			var count := int(remaining.get(triangle, 0))
			if count <= 0:
				complete = false
				break
			if count == 1:
				remaining.erase(triangle)
			else:
				remaining[triangle] = count - 1
	var predicates := {"positive_render_coverage": positive, "complete_native_coverage": complete,
		"finite_faces": finite, "oriented_triangle_multiset_equal": positive and complete and remaining.is_empty()}
	return {"ok": positive and complete and finite and remaining.is_empty(), "predicates": predicates}
