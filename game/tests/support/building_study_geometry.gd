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


# Inventory only: callers still verify native bodies/shapes and exact producer faces.
# Never infer ownership from a display name or adopt foreign/untagged siblings.
static func retained_housing_inventory(scene: Node, family: Node3D, source: String, require_family_roof: bool = true) -> Dictionary:
	var result := {"ok": false, "reason": "invalid retained housing owner", "roof_owners": [], "ground_meshes": []}
	if source.is_empty() or family == null or family.get_meta("source_key", "") != source:
		return result
	var wall := family.get_parent() as Node3D
	if wall == null or wall.get_meta("source_keys", []) != [source] or wall.get_meta("derived_object_key", "") != "building:" + source + ":wall":
		return result
	for node: Node in scene.find_children("*", "Node3D", true, false):
		if node == wall or node is GeometryInstance3D or node is CollisionObject3D or node is CollisionShape3D:
			continue
		if node.get_meta("derived_object_key", "") == "building:" + source + ":roof":
			if node.get_meta("source_keys", []) != [source]:
				result.reason = "mixed or foreign retained roof owner"; return result
			result.roof_owners.append(node)
	if result.roof_owners.size() != 1:
		result.reason = "missing or duplicate retained roof owner"; return result
	for owner: Node3D in [wall, result.roof_owners[0]]:
		var roof := owner != wall
		var positive_roof := false
		for child: Node in owner.get_children():
			if child == family: continue
			if child is MeshInstance3D:
				if child.get_meta("source_keys", []) != [source] or child.get_meta("derived_object_key", "") != owner.get_meta("derived_object_key", ""):
					result.reason = "retained mesh source ownership differs"; return result
				var role := str(child.get_meta("physical_role", ""))
				if roof:
					if role != "roof" or not child.is_visible_in_tree() or child.mesh == null:
						result.reason = "missing or untagged retained roof mesh"; return result
					positive_roof = true
				elif role == "ground_visual" and child.is_visible_in_tree() and child.mesh != null:
					result.ground_meshes.append(child)
				elif role not in ["wall", "detail"] or child.visible:
					result.reason = "unknown retained wall visual"; return result
			elif not child is StaticBody3D:
				result.reason = "unknown retained owner child"; return result
		if roof and not positive_roof:
			result.reason = "missing positive retained roof mesh"; return result
	if result.ground_meshes.is_empty():
		result.reason = "missing positive retained ground visual"; return result
	var family_roof := false
	for child: Node in family.get_children():
		if child is MeshInstance3D and child.get_meta("family_role", "") == "roof" and child.is_visible_in_tree() and child.mesh != null:
			if child.has_meta("source_keys") and child.get_meta("source_keys") != [source]:
				result.reason = "foreign family roof"; return result
			family_roof = true
	if require_family_roof and not family_roof:
		result.reason = "missing positive sectional family roof"; return result
	for node: Node in scene.find_children("*", "StaticBody3D", true, false):
		if source in node.get_meta("source_keys", []) and node.collision_layer != 0 and node.get_parent() != family and node.get_parent() != result.roof_owners[0]:
			result.reason = "additional active retained source body"; return result
	result.ok = true
	result.reason = ""
	return result


# Qualify a hit against only the retained ground subset of a verified mixed
# support bucket. The bucket itself is never treated as homogeneous ground.
static func retained_ground_contact(scene: Node, family: Node3D, body: StaticBody3D,
		hit: Dictionary, land: Dictionary, max_offset: float, tolerance: float, floor_cos: float, proof_cache: Dictionary = {}) -> bool:
	if family == null or body == null or body.get_parent() != family or hit.get("collider") != body or (hit.has("rid") and hit.rid != body.get_rid()): return false
	var source := str(family.get_meta("source_key", ""))
	if family.global_transform != Transform3D.IDENTITY or family.get_meta("scope", "") != "approved_shared_family_normal_play" or not family.get_meta("build_valid", false): return false
	if body.get_meta("source_keys", []) != [source] or body.get_meta("derived_object_key", "") != "building:" + source + ":wall" or body.get_meta("family_role", "") != "support" or body.get_meta("receiver_kind", "") != "none" or body.collision_layer != 1 or body.collision_mask != 0 or body.is_in_group("spray_receiver_wall"): return false
	var owners := body.get_shape_owners()
	if owners.size() != 1 or body.is_shape_owner_disabled(owners[0]) or body.shape_owner_get_shape_count(owners[0]) != 1: return false
	var holder := body.shape_owner_get_owner(owners[0]) as CollisionShape3D
	if holder == null or holder.get_parent() != body or holder.transform != Transform3D.IDENTITY or holder.is_set_as_top_level() or not holder.shape is ConcavePolygonShape3D or not holder.shape.backface_collision: return false
	var index := body.shape_owner_get_shape_index(owners[0], 0)
	if hit.get("shape", -1) != index or PhysicsServer3D.body_get_shape(body.get_rid(), index) != holder.shape.get_rid() or PhysicsServer3D.body_get_shape_transform(body.get_rid(), index) != holder.transform: return false
	var server_pose: Variant = PhysicsServer3D.body_get_state(body.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM)
	if body.is_set_as_top_level() or body.basis != Basis.IDENTITY or not body.global_transform.is_finite() or not server_pose is Transform3D or not server_pose.is_equal_approx(body.global_transform): return false
	var valid_cache: bool = proof_cache.get("scene") == scene and proof_cache.get("body") == body and proof_cache.get("holder") == holder and not proof_cache.get("token", {"dirty": true}).dirty
	if valid_cache:
		for entry: Dictionary in proof_cache.nodes:
			if not is_instance_valid(entry.node) or _ground_proof_state(entry.node) != entry.state:
				valid_cache = false
				break
	if not valid_cache:
		var inventory := retained_housing_inventory(scene, family, source, false)
		if not inventory.ok: return false
		var expected := PackedVector3Array()
		var ground_faces := PackedVector3Array()
		var meshes: Array[MeshInstance3D] = []
		for child: Node in family.get_children():
			if child is MeshInstance3D and child.get_meta("family_role", "support") == "support": meshes.append(child)
		meshes.append_array(inventory.ground_meshes)
		for mesh: MeshInstance3D in meshes:
			if not mesh.is_visible_in_tree() or mesh.layers != 1 or mesh.is_set_as_top_level(): return false
			var retained: bool = mesh in inventory.ground_meshes
			var pose := mesh.transform
			if retained:
				pose = Transform3D.IDENTITY
				var ancestor: Node3D = mesh
				while ancestor != null:
					if ancestor.is_set_as_top_level(): return false
					pose = ancestor.transform * pose
					ancestor = ancestor.get_parent() as Node3D
			var collection := collect(mesh.mesh, [pose], MESH_GET_FACES)
			if not collection.ok: return false
			if retained: ground_faces.append_array(collection.faces)
			for vertex: Vector3 in collection.faces: expected.append(vertex - body.position)
		if expected.is_empty() or expected != holder.shape.get_faces(): return false
		# Cache belongs to the harness/world, never to a global singleton. Resource
		# signals invalidate changed face arrays; descriptors catch replacement,
		# transforms, metadata, visibility and ownership changes without get_faces.
		proof_cache.clear()
		var invalidation_token := {"dirty": false}
		proof_cache.merge({"scene": scene, "body": body, "holder": holder, "token": invalidation_token, "faces": ground_faces, "nodes": []})
		# Callbacks capture only this generation token, never the cache/resources.
		var watched: Array[Node] = [family, body, holder]
		for owner: Node in [family.get_parent(), inventory.roof_owners[0], family]:
			if owner not in watched: watched.append(owner)
			for child: Node in owner.get_children():
				if child not in watched: watched.append(child)
		for node: Node in watched:
			proof_cache.nodes.append({"node": node, "state": _ground_proof_state(node)})
			var resource: Resource = node.mesh if node is MeshInstance3D else (node.shape if node is CollisionShape3D else null)
			if resource != null:
				resource.changed.connect(func() -> void: invalidation_token.dirty = true, CONNECT_ONE_SHOT)
		if scene.is_inside_tree():
			scene.get_tree().tree_changed.connect(func() -> void: invalidation_token.dirty = true, CONNECT_ONE_SHOT)
	var ground_faces: PackedVector3Array = proof_cache.faces
	var land_body := land.get("collider") as CollisionObject3D
	if land_body == null or land_body.get_parent() == null or land_body.get_parent().get_meta("feature_kind", "") != "land_ground" or (land_body.collision_layer & 1) == 0: return false
	return ground_face_contact(hit.get("position", Vector3.INF), hit.get("normal", Vector3.ZERO), ground_faces,
		land.get("position", Vector3.INF), land.get("normal", Vector3.ZERO), max_offset, tolerance, floor_cos)


static func _ground_proof_state(node: Node) -> Array:
	var metadata := {}
	for key: StringName in node.get_meta_list(): metadata[key] = node.get_meta(key)
	var state: Array = [node.get_parent(), node.get_children(), metadata.duplicate(true)]
	if node is Node3D: state.append_array([node.global_transform, node.is_set_as_top_level(), node.is_visible_in_tree()])
	if node is MeshInstance3D: state.append_array([node.mesh, node.layers])
	if node is CollisionShape3D: state.append_array([node.shape, node.disabled])
	if node is CollisionObject3D: state.append_array([node.get_rid(), node.collision_layer, node.collision_mask, node.is_in_group("spray_receiver_wall")])
	return state


static func ground_face_contact(point: Vector3, normal: Vector3, faces: PackedVector3Array,
		land_point: Vector3, land_normal: Vector3, max_offset: float, tolerance: float, floor_cos: float) -> bool:
	if not point.is_finite() or not normal.is_finite() or not land_point.is_finite() or not land_normal.is_finite() or tolerance <= 0 or max_offset < 0: return false
	if normal.dot(Vector3.UP) < floor_cos or land_normal.dot(Vector3.UP) < floor_cos or Vector2(point.x-land_point.x, point.z-land_point.z).length() > tolerance: return false
	if point.y < land_point.y - tolerance or point.y - land_point.y > max_offset + tolerance: return false
	if faces.is_empty() or faces.size() % 3 != 0: return false
	for i in range(0, faces.size(), 3):
		var a := faces[i]; var b := faces[i+1]; var c := faces[i+2]
		if not a.is_finite() or not b.is_finite() or not c.is_finite(): return false
		var cross := (b-a).cross(c-a)
		if cross.length_squared() <= 1e-20: continue
		var up := cross.normalized()
		if up.y < 0: up = -up
		if up.dot(Vector3.UP) < floor_cos or up.dot(normal) < 0.9999 or absf(up.dot(point-a)) > tolerance: continue
		var v0 := b-a; var v1 := c-a; var v2 := point-a
		var d00 := v0.dot(v0); var d01 := v0.dot(v1); var d11 := v1.dot(v1)
		var denominator := d00*d11-d01*d01
		if denominator <= 1e-20: continue
		var u := (d11*v2.dot(v0)-d01*v2.dot(v1))/denominator
		var v := (d00*v2.dot(v1)-d01*v2.dot(v0))/denominator
		if u >= 0 and v >= 0 and u+v <= 1: return true
	return false


# Review prompts only: sampled union areas avoid double-counting stacked roofs.
# The frozen source-roof triangulation is the canonical horizontal footprint,
# not a survey of footing dimensions. Courtyard holes remain excluded.
static func footprint_advisory(canonical: PackedVector3Array, roof: PackedVector3Array,
		deficit_tolerance: float = 0.05, cell_m: float = 1.0, max_visits: int = 200000) -> Dictionary:
	var result := {"blocking": false, "status": "UNKNOWN", "basis": "canonical_source_footprint_projection", "measurement": "sampled_union_area", "deficit_tolerance": deficit_tolerance}
	if canonical.is_empty() or roof.is_empty() or canonical.size() % 3 != 0 or roof.size() % 3 != 0 or not is_finite(cell_m) or cell_m <= 0.0 or not is_finite(deficit_tolerance) or deficit_tolerance < 0.0 or deficit_tolerance > 1.0:
		return result
	if max_visits <= 0 or canonical.size() + roof.size() > max_visits:
		result.reason = "advisory_work_budget_exhausted"
		return result
	var budget := {"remaining": max_visits - canonical.size() - roof.size()}
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for faces: PackedVector3Array in [canonical, roof]:
		for p: Vector3 in faces:
			if not p.is_finite(): return result
			lo = lo.min(Vector2(p.x, p.z)); hi = hi.max(Vector2(p.x, p.z))
	# Bound diagnostic cost for large composite buildings without changing fit.
	var step := maxf(cell_m, sqrt((hi.x-lo.x)*(hi.y-lo.y)/40000.0))
	if not is_finite(step) or step <= 0.0: return result
	var foundation := _projected_cells(canonical, step, budget)
	var roof_projection := _projected_cells(roof, step, budget)
	if not foundation.ok or not roof_projection.ok:
		result.reason = "advisory_work_budget_exhausted"
		return result
	var foundation_cells: Dictionary = foundation.cells
	var roof_cells: Dictionary = roof_projection.cells
	if foundation_cells.is_empty() or roof_cells.is_empty(): return result
	var overlap := 0
	for key: Vector2i in foundation_cells:
		if roof_cells.has(key): overlap += 1
	var deficit := float(foundation_cells.size()-overlap)/float(foundation_cells.size())
	result.merge({"status": "REVIEW" if deficit > deficit_tolerance else "WITHIN_TOLERANCE", "cell_m": step,
		"foundation_projected_m2": foundation_cells.size()*step*step, "roof_projected_m2": roof_cells.size()*step*step,
		"uncovered_foundation_m2": (foundation_cells.size()-overlap)*step*step, "deficit_fraction": deficit,
		"roof_to_foundation_ratio": float(roof_cells.size())/float(foundation_cells.size()),
		"overhang_m2_informational": (roof_cells.size()-overlap)*step*step}, true)
	return result


static func _projected_cells(faces: PackedVector3Array, step: float, budget: Dictionary) -> Dictionary:
	var cells := {}
	for i in range(0, faces.size(), 3):
		if int(budget.remaining) <= 0: return {"ok": false, "cells": {}}
		budget.remaining = int(budget.remaining) - 1
		var tri := PackedVector2Array([Vector2(faces[i].x,faces[i].z), Vector2(faces[i+1].x,faces[i+1].z), Vector2(faces[i+2].x,faces[i+2].z)])
		if absf((tri[1]-tri[0]).cross(tri[2]-tri[0])) < 1e-10: continue
		var lo := tri[0].min(tri[1]).min(tri[2])/step
		var hi := tri[0].max(tri[1]).max(tri[2])/step
		var width: float = ceilf(hi.x) - floorf(lo.x)
		var height: float = ceilf(hi.y) - floorf(lo.y)
		var visits := width * height
		# Check before constructing ranges; a long thin triangle can have huge width.
		if not is_finite(visits) or width > float(budget.remaining) or height > float(budget.remaining) or visits > float(budget.remaining): return {"ok": false, "cells": {}}
		budget.remaining = int(budget.remaining) - int(visits)
		for x in range(int(floor(lo.x)), int(ceil(hi.x))):
			for z in range(int(floor(lo.y)), int(ceil(hi.y))):
				if Geometry2D.is_point_in_polygon(Vector2(x+0.5,z+0.5)*step, tri): cells[Vector2i(x,z)] = true
	return {"ok": true, "cells": cells}


# Explicit semantic values only; node names/substrings never establish an opening.
# Unknown inventory cannot establish absence, even if no door was identified.
static func opening_advisory(semantics: Array, side_ids: Array, inventory_complete: bool = false) -> Dictionary:
	var doors := 0
	var windows := {}
	var identified_windows := 0
	var unlocalized_windows := 0
	var unknown := 0
	for item: Dictionary in semantics:
		var kind := str(item.get("kind", "unknown"))
		if kind == "door": doors += 1
		elif kind == "window":
			identified_windows += 1
			var localized := false
			for side: String in item.get("sides", []):
				if side in side_ids:
					windows[side] = true
					localized = true
			if not localized: unlocalized_windows += 1
		else: unknown += 1
	var sides := {}
	for side: String in side_ids:
		sides[side] = "IDENTIFIED" if windows.has(side) else ("REVIEW_NONE_IDENTIFIED" if inventory_complete and unknown == 0 and unlocalized_windows == 0 else "UNKNOWN")
	return {"blocking": false, "door": "IDENTIFIED" if doors > 0 else ("REVIEW_NONE_IDENTIFIED" if inventory_complete and unknown == 0 else "UNKNOWN"),
		"window_by_orientation": sides, "identified_door_components": doors, "identified_window_components": identified_windows,
		"door_inspection_prompt": doors == 0, "window_inspection_orientations": side_ids.filter(func(side: String) -> bool: return not windows.has(side)),
		"unlocalized_window_components": unlocalized_windows, "inventory_complete": inventory_complete, "unclassified": unknown, "scope": "explicit_source_owned_opening_semantics; orientation groups combine stepped parallel chains",
		"note": "Inspect UNKNOWN or REVIEW sides/entrance against references; components are not a surveyed opening count. Blank sides may be legitimate. No recognition decision."}
