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


# Required samples come from an explicit projected roof domain. The blocking
# caller supplies declared roof geometry before culling; canonical source roof
# geometry is a separate advisory domain for authored footprint differences.
# A one-metre interior lattice plus every source triangle's centroid preserves
# narrow source pieces and naturally omits triangulated courtyard holes.
# This is a finite coverage check, not an exhaustive polygon-union proof.
static func roof_coverage(required: PackedVector3Array, visible: PackedVector3Array) -> Dictionary:
	var samples := {}
	for i in range(0, required.size(), 3):
		if i + 2 >= required.size(): return {"ok": false, "reason": "incomplete source roof triangles"}
		var triangle := PackedVector2Array()
		for j in 3: triangle.append(Vector2(required[i+j].x, required[i+j].z))
		if (triangle[1]-triangle[0]).cross(triangle[2]-triangle[0]) == 0.0: continue
		samples[(triangle[0]+triangle[1]+triangle[2])/3.0] = true
		var lo := triangle[0].min(triangle[1]).min(triangle[2])
		var hi := triangle[0].max(triangle[1]).max(triangle[2])
		for x in range(int(floor(lo.x)), int(ceil(hi.x))):
			for z in range(int(floor(lo.y)), int(ceil(hi.y))):
				var point := Vector2(x+0.5, z+0.5)
				if Geometry2D.is_point_in_polygon(point, triangle): samples[point] = true
	if samples.is_empty(): return {"ok": false, "reason": "missing positive source roof domain"}
	# Spatial bins avoid each source sample scanning every roof triangle.
	var bins := {}
	for i in range(0, visible.size(), 3):
		if i + 2 >= visible.size(): return {"ok": false, "reason": "incomplete visible roof triangles"}
		var triangle := PackedVector2Array()
		for j in 3: triangle.append(Vector2(visible[i+j].x, visible[i+j].z))
		if (triangle[1]-triangle[0]).cross(triangle[2]-triangle[0]) == 0.0: continue
		var lo := triangle[0].min(triangle[1]).min(triangle[2]) / 4.0
		var hi := triangle[0].max(triangle[1]).max(triangle[2]) / 4.0
		for x in range(int(floor(lo.x)), int(floor(hi.x))+1):
			for z in range(int(floor(lo.y)), int(floor(hi.y))+1):
				var bin := Vector2i(x,z)
				if not bins.has(bin): bins[bin] = []
				bins[bin].append(triangle)
	var missing: Array[Vector2] = []
	for point: Vector2 in samples:
		var covered := false
		var bin := Vector2i(int(floor(point.x/4.0)), int(floor(point.y/4.0)))
		for triangle: PackedVector2Array in bins.get(bin, []):
			if Geometry2D.is_point_in_polygon(point, triangle):
				covered = true
				break
		if not covered:
			missing.append(point)
			if missing.size() == 8: break
	return {"ok": missing.is_empty(), "reason": "" if missing.is_empty() else "source roof interior has no sky-visible roof", "samples": samples.size(), "missing": missing}


# Effective material semantics; unknown visibility must fail, never invent a draw.
static func roof_cull_mode(material: Material) -> Dictionary:
	if material == null: return {"ok": true, "mode": BaseMaterial3D.CULL_BACK}
	if material.next_pass != null: return {"ok": false, "reason": "roof material next_pass unsupported"}
	if material is BaseMaterial3D:
		if material.is_grow_enabled():
			return {"ok": false, "reason": "roof material vertex grow unsupported"}
		if material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
			return {"ok": false, "reason": "transparent roof material unsupported"}
		return {"ok": true, "mode": material.cull_mode}
	if material is ShaderMaterial and material.shader != null:
		var code: String = material.shader.code
		var comments := RegEx.new()
		comments.compile("(?s)/\\*.*?\\*/|//[^\\n]*")
		code = comments.sub(code, "", true)
		var unsupported := RegEx.new()
		unsupported.compile("\\b(discard|ALPHA|ALPHA_SCISSOR_THRESHOLD|ALPHA_HASH_SCALE)\\b|#include|\\b(VERTEX|POSITION)(\\.[xyzwrgba]+)?\\s*[-+*/]?=")
		if unsupported.search(code) != null:
			return {"ok": false, "reason": "roof shader displacement/transparency/include unsupported"}
		var modes := RegEx.new()
		modes.compile("render_mode\\s+([^;]+);")
		var mode := BaseMaterial3D.CULL_BACK
		for match_value: RegExMatch in modes.search_all(code):
			for token: String in match_value.get_string(1).split(","):
				if token.strip_edges() == "cull_disabled": mode = BaseMaterial3D.CULL_DISABLED
				elif token.strip_edges() == "cull_front": mode = BaseMaterial3D.CULL_FRONT
		return {"ok": true, "mode": mode}
	return {"ok": false, "reason": "unknown roof material type"}


static func sky_faces(faces: PackedVector3Array, cull_mode: int) -> PackedVector3Array:
	var result := PackedVector3Array()
	for i in range(0, faces.size(), 3):
		var cross_y := (faces[i+1]-faces[i]).cross(faces[i+2]-faces[i]).y
		# Godot's front winding is clockwise. Vertical faces cover no XZ area.
		if cross_y == 0.0: continue
		if cull_mode == BaseMaterial3D.CULL_BACK and cross_y > 0.0: continue
		if cull_mode == BaseMaterial3D.CULL_FRONT and cross_y < 0.0: continue
		result.append_array(PackedVector3Array([faces[i],faces[i+1],faces[i+2]]))
	return result


# The caller supplies source-owned roots from WorldHarness. Semantic roles take
# precedence over inherited record identity; ground/wall/support are never roofs.
static func visible_roof_faces(nodes: Array[Node3D], source: String, render_mask: int = 0xFFFFF, composite_records: Dictionary = {}) -> Dictionary:
	var result := {"ok": true, "reason": "", "faces": PackedVector3Array(), "intended_faces": PackedVector3Array()}
	# Caller authorizes exact generated records; no name/substring-based adoption.
	for key: String in composite_records:
		var part := str(composite_records[key])
		if part.is_empty() or part == source or key not in ["building-composite:" + source + ":" + part + ":roof", "building-composite:" + source + ":" + part + ":wall"]:
			result.ok = false; result.reason = "invalid composite record authorization"; return result
	var visited: Dictionary = {}
	for node: Node3D in nodes:
		var key := str(node.get_meta("derived_object_key", ""))
		if composite_records.has(key):
			var part := str(composite_records[key])
			if visited.has(key) or node.get_meta("source_keys", []) != [part] or (node.has_meta("source_key") and str(node.get_meta("source_key")) != part):
				result.ok = false; result.reason = "ambiguous composite branch ownership"; return result
			visited[key] = true
			var branch := {"ok": true, "reason": "", "faces": PackedVector3Array(), "intended_faces": PackedVector3Array()}
			_roof_node(node, part, false, render_mask, branch)
			if not branch.ok: return branch
			if key.ends_with(":roof") and not roof_coverage(branch.intended_faces, branch.intended_faces).ok:
				result.ok = false; result.reason = "missing positive authorized part roof: " + key; return result
			var visible_faces: PackedVector3Array = result.faces
			visible_faces.append_array(branch.faces)
			result.faces = visible_faces
			var intended_faces: PackedVector3Array = result.intended_faces
			intended_faces.append_array(branch.intended_faces)
			result.intended_faces = intended_faces
		else:
			_roof_node(node, source, false, render_mask, result)
	for key: String in composite_records:
		if not visited.has(key):
			result.ok = false; result.reason = "missing authorized composite branch: " + key; return result
	return result


static func _roof_node(node: Node, source: String, inherited_roof: bool, render_mask: int, result: Dictionary) -> void:
	if not result.ok: return
	if node.has_meta("source_keys") and source not in node.get_meta("source_keys"):
		return
	if node.has_meta("source_key") and str(node.get_meta("source_key")) != source:
		return
	var roof := inherited_roof
	if node.has_meta("derived_object_key"):
		var key := str(node.get_meta("derived_object_key"))
		if (":" + source + ":") not in key: return
		roof = key.ends_with(":" + source + ":roof")
	# Housing installs family_role meshes below the retained wall record owner.
	# Both supported explicit role channels override the inherited record role.
	if node.has_meta("family_role"):
		roof = str(node.get_meta("family_role")) == "roof"
	if node.has_meta("physical_role"):
		if node.has_meta("family_role") and roof != (str(node.get_meta("physical_role")) == "roof"):
			result.ok = false; result.reason = "conflicting explicit roof roles"; return
		roof = str(node.get_meta("physical_role")) == "roof"
	if roof and node is GeometryInstance3D and node.is_visible_in_tree() and (node.layers & render_mask) != 0:
		if node.material_overlay != null or node.transparency != 0.0:
			result.ok = false; result.reason = "roof overlay/instance transparency unsupported"; return
		var mesh: Mesh
		var transforms: Array[Transform3D] = []
		if node is MeshInstance3D:
			mesh = node.mesh
			transforms.append(node.global_transform)
		elif node is MultiMeshInstance3D and node.multimesh != null:
			mesh = node.multimesh.mesh
			if node.multimesh.transform_format != MultiMesh.TRANSFORM_3D:
				result.ok = false; result.reason = "unsupported roof MultiMesh transform"; return
			var count: int = node.multimesh.visible_instance_count if node.multimesh.visible_instance_count >= 0 else node.multimesh.instance_count
			for i in count: transforms.append(node.global_transform * node.multimesh.get_instance_transform(i))
		else:
			result.ok = false; result.reason = "unsupported roof geometry instance"; return
		if mesh == null or transforms.is_empty():
			result.ok = false; result.reason = "missing positive roof mesh/instances"; return
		for pose: Transform3D in transforms:
			if not pose.is_finite() or pose.basis.determinant() <= 0.0:
				result.ok = false; result.reason = "unsupported reflected/degenerate roof transform"; return
		for surface in mesh.get_surface_count():
			var material: Material = node.material_override
			if material == null and node is MeshInstance3D: material = node.get_surface_override_material(surface)
			if material == null: material = mesh.surface_get_material(surface)
			var cull := roof_cull_mode(material)
			if not cull.ok:
				result.ok = false; result.reason = str(node.get_path()) + ": " + cull.reason; return
			if mesh is ArrayMesh and mesh.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
				result.ok = false; result.reason = "unsupported roof surface primitive"; return
			var one_surface := ArrayMesh.new()
			one_surface.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh.surface_get_arrays(surface))
			var collection := collect(one_surface, transforms, MESH_GET_FACES)
			if not collection.ok:
				result.ok = false; result.reason = "roof surface collection failed: " + str(collection.errors); return
			var intended: PackedVector3Array = result.intended_faces
			intended.append_array(collection.faces)
			result.intended_faces = intended
			var faces: PackedVector3Array = result.faces
			faces.append_array(sky_faces(collection.faces, cull.mode))
			result.faces = faces
	for child: Node in node.get_children(): _roof_node(child, source, roof, render_mask, result)
