extends RefCounted
## Shared geometry mechanics for the two pending housing revisions only.

static func land_triangles(paths: Array) -> Dictionary:
	var triangles: Array = []
	for path: String in paths:
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		for record: Dictionary in data.records:
			if str(record.feature_kind) != "land_ground" or str(record.collision_kind) != "world_solid": continue
			var vertices: Array = record.vertices
			var indices: Array = record.indices
			for i in range(0, indices.size(), 3):
				var tri: Array[Vector3] = []
				for j in 3:
					var offset: int = int(indices[i + j]) * 3
					tri.append(Vector3(vertices[offset], vertices[offset + 1], vertices[offset + 2]))
				triangles.append(tri)
	return {"ok": not triangles.is_empty(), "triangles": triangles, "message": "Local colliding land required."}

static func height_at(p: Vector2, triangles: Array) -> float:
	var highest := -INF
	for triangle: Array in triangles:
		var a: Vector3 = triangle[0]; var b: Vector3 = triangle[1]; var c: Vector3 = triangle[2]
		var u := Vector2(b.x - a.x, b.z - a.z)
		var v := Vector2(c.x - a.x, c.z - a.z)
		var q := p - Vector2(a.x, a.z)
		var determinant := u.cross(v)
		if absf(determinant) < 0.00000001: continue
		var s := q.cross(v) / determinant
		var t := u.cross(q) / determinant
		if s >= -0.00001 and t >= -0.00001 and s + t <= 1.00001:
			highest = maxf(highest, a.y + s * (b.y - a.y) + t * (c.y - a.y))
	return highest

static func attach(model: Node3D, wall: Dictionary, roof: Dictionary, _cfg: Dictionary) -> Dictionary:
	var stair_error := stair_support_error(model, str(wall.source_keys[0]), str(wall.object_key))
	if stair_error != "":
		model.free()
		return {"ok": false, "message": stair_error}
	var roles: Array[String] = ["wall", "detail", "roof"]
	for child: Node in model.get_children():
		if child is MeshInstance3D and child.get_meta("physical_role", "") == "stair_support":
			roles.append("stair_support")
			break
	var roof_root := Node3D.new()
	roof_root.name = "QualityRoof"
	model.add_child(roof_root)
	var bodies: Dictionary = {}
	for role: String in roles:
		var body := StaticBody3D.new()
		body.name = "CurrentGeometry_" + role
		body.collision_layer = 5
		body.collision_mask = 0
		var record: Dictionary = roof if role == "roof" else wall
		var receiver := "building_wall" if role == "wall" else "none"
		for target: Object in [body]:
			target.set_meta("receiver_kind", receiver)
			target.set_meta("opaque", true)
			target.set_meta("derived_object_key", str(record.object_key))
			target.set_meta("source_keys", record.source_keys.duplicate())
			target.set_meta("physical_role", role)
		if role == "wall": body.add_to_group("spray_receiver_wall")
		(roof_root if role == "roof" else model).add_child(body)
		bodies[role] = body
	for child: Node in model.get_children():
		if not child is MeshInstance3D: continue
		var mesh := child as MeshInstance3D
		var role := str(mesh.get_meta("physical_role", ""))
		if role == "ground_visual": continue
		if role == "stair_visual":
			mesh.layers = 1
			continue
		if not bodies.has(role):
			model.free()
			return {"ok": false, "message": "Unclassified physical art mesh."}
		mesh.layers = 3 if role == "wall" else 1
		var faces := PackedVector3Array()
		var raw := mesh.mesh.get_faces()
		for i in range(0, raw.size(), 3):
			var a: Vector3 = mesh.transform * raw[i]
			var b: Vector3 = mesh.transform * raw[i + 1]
			var c: Vector3 = mesh.transform * raw[i + 2]
			if (b - a).cross(c - a).length_squared() < 0.000000000001: continue
			faces.append_array(PackedVector3Array([a, b, c]))
		if not faces.is_empty():
			var shape := ConcavePolygonShape3D.new()
			shape.set_faces(faces)
			shape.backface_collision = true
			shape.set_meta("construction_detail", str(mesh.get_meta("construction_detail", "")))
			for key: String in ["stair_flight_id", "stair_flight_ids"]:
				if mesh.has_meta(key): shape.set_meta(key, mesh.get_meta(key))
			var body := bodies[role] as StaticBody3D
			for key: String in ["receiver_kind", "opaque", "derived_object_key", "source_keys", "physical_role"]:
				shape.set_meta(key, body.get_meta(key))
			var node := CollisionShape3D.new()
			node.name = "ArtContact_%04d" % body.get_child_count()
			node.shape = shape
			body.add_child(node)
		if role == "roof":
			model.remove_child(mesh)
			roof_root.add_child(mesh)
	for owner: Node3D in [model, roof_root]:
		owner.set_meta("old_collision_proxy_retained", false)
		owner.set_meta("collision_geometry", "visible_faces_except_stair_treads_plus_explicit_nosing_support" if "stair_support" in roles else "current_visible_mesh_faces_except_draped_ground_and_shrubs")
	return {"ok": true, "node": model}


## Explicit opt-in collision-only nosing planes, bounded by the associated visible
## flight in the ramp's local frame. Old wall/detail/ground callers are unchanged.
## Exact tread/nosing alignment and stock traversal remain separate required proof.
static func stair_support_error(model: Node3D, source: String, receiver: String) -> String:
	var supports: Array[MeshInstance3D] = []
	var treads: Array[MeshInstance3D] = []
	var visuals: Array[MeshInstance3D] = []
	for child: Node in model.get_children():
		if not child is MeshInstance3D: continue
		var mesh := child as MeshInstance3D
		var role := str(mesh.get_meta("physical_role", ""))
		if role not in ["stair_support", "stair_visual"] and not mesh.has_meta("stair_flight_ids"): continue
		if mesh.mesh == null or not mesh.transform.is_finite() or mesh.is_set_as_top_level() or mesh.get_meta("source_keys", []) != [source] or str(mesh.get_meta("derived_object_key", "")) != receiver:
			return "Stair geometry source/transform/mesh differs"
		if role == "stair_support":
			if mesh.visible or str(mesh.get_meta("stair_flight_id", "")).is_empty(): return "Stair support must be explicit hidden flight geometry"
			supports.append(mesh)
		else:
			if not mesh.visible: return "Stair flight visual must remain visible"
			visuals.append(mesh)
			if role == "stair_visual":
				if str(mesh.get_meta("stair_flight_id", "")).is_empty(): return "Stair tread needs flight identity"
				treads.append(mesh)
	if supports.is_empty() and treads.is_empty(): return ""
	if supports.is_empty() or treads.is_empty(): return "Stair support and visible treads both required"
	var covered := {}
	for ramp: MeshInstance3D in supports:
		var flight := str(ramp.get_meta("stair_flight_id"))
		if covered.has(flight): return "Ambiguous stair support flight"
		var points := PackedVector3Array()
		var has_tread := false
		var has_landing := false
		for mesh: MeshInstance3D in visuals:
			var ids: Variant = mesh.get_meta("stair_flight_ids", [])
			if not ids is Array: return "Stair landing flight identities must be an array"
			if str(mesh.get_meta("stair_flight_id", "")) != flight and flight not in ids: continue
			has_tread = has_tread or mesh in treads
			has_landing = has_landing or (mesh.get_meta("physical_role", "") == "detail" and mesh.get_meta("construction_detail", "") == "StairLanding")
			var relative := ramp.transform.affine_inverse() * mesh.transform
			for point: Vector3 in mesh.mesh.get_faces():
				var transformed := relative * point
				if not transformed.is_finite(): return "Nonfinite stair visual geometry"
				points.append(transformed)
		if not has_tread or not has_landing or points.is_empty(): return "Stair support lacks positive associated tread/landing coverage"
		var bounds := AABB(points[0], Vector3.ZERO)
		for point: Vector3 in points: bounds = bounds.expand(point)
		var faces := ramp.mesh.get_faces()
		if faces.is_empty() or faces.size() % 3 != 0: return "Stair support faces missing"
		for point: Vector3 in faces:
			if not point.is_finite() or not bounds.grow(0.002).has_point(point): return "Stair support escapes visible flight envelope"
		covered[flight] = true
	for tread: MeshInstance3D in treads:
		if not covered.has(str(tread.get_meta("stair_flight_id"))): return "Visible stair flight lacks native support"
	return ""
