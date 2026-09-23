extends RefCounted
## Shared geometry mechanics for the two pending housing revisions only.

static func land_triangles(paths: Dictionary) -> Dictionary:
	var triangles: Array = []
	for path: String in paths:
		if FileAccess.get_sha256(path) != str(paths[path]):
			return {"ok": false, "message": "Frozen colliding-land chunk drifted."}
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

static func attach(model: Node3D, wall: Dictionary, roof: Dictionary, cfg: Dictionary) -> Dictionary:
	var roof_root := Node3D.new()
	roof_root.name = "QualityRoof"
	model.add_child(roof_root)
	var bodies: Dictionary = {}
	for role: String in ["wall", "detail", "roof"]:
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
		owner.set_meta("revision_acceptance", "pending")
		owner.set_meta("reviewed_art_sha256", str(cfg.reviewed_art_sha256))
		owner.set_meta("historical_recognition_credit_unchanged", true)
		owner.set_meta("old_collision_proxy_retained", false)
		owner.set_meta("collision_geometry", "current_visible_mesh_faces_except_draped_ground_and_shrubs")
	return {"ok": true, "node": model}
