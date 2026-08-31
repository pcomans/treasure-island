class_name Hawkins77BrutonMassing
extends RefCounted

const TARGET_SOURCE_KEY := "w1249412093"
const TARGET_LOGICAL_OBJECT_KEY := "building:w1249412093"
const TARGET_WALL_KEY := "building:w1249412093:wall"
const TARGET_ROOF_KEY := "building:w1249412093:roof"
const SOURCE_TOP_Y := 10.274
const BASE_Y := 4.274
const MAIN_TOP_Y := 25.274
const COMPANION_TOP_Y := 18.274
const WSW_SPLIT_U_M := 60.4
const SE_SPLIT_U_M := 33.0
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1
const FACADE_SCENE := preload("res://game/scenes/world/facades/hawkins/hawkins_77_bruton_facade.tscn")

const A := Vector2(-118.795, 451.595)
const B := Vector2(-79.648, 526.358)
const C := Vector2(-41.556, 480.728)
const D := Vector2(-69.387, 427.417)
const AX := -118.795
const AZ := 451.595
const BX := -79.648
const BZ := 526.358
const CX := -41.556
const CZ := 480.728


static func matches_record(record: Dictionary) -> bool:
	var object_key := str(record.get("object_key", ""))
	if object_key not in [TARGET_WALL_KEY, TARGET_ROOF_KEY]:
		return false
	var source_keys: Array = record.get("source_keys", [])
	return source_keys.size() == 1 \
		and str(source_keys[0]) == TARGET_SOURCE_KEY \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))


static func build_record(record: Dictionary, material: Material) -> Dictionary:
	var validation := _validate_source_record(record)
	if not bool(validation.get("ok", false)):
		return validation
	var object_key := str(record.object_key)
	var geometry := wall_geometry(record) if object_key == TARGET_WALL_KEY else roof_geometry()
	if not bool(geometry.get("ok", false)):
		return geometry

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = geometry.vertices
	arrays[Mesh.ARRAY_NORMAL] = geometry.normals
	arrays[Mesh.ARRAY_TEX_UV] = geometry.uvs
	arrays[Mesh.ARRAY_TANGENT] = geometry.tangents
	arrays[Mesh.ARRAY_INDEX] = geometry.indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)

	var root := Node3D.new()
	root.name = object_key.validate_node_name()
	root.set_meta("derived_object_key", object_key)
	root.set_meta("source_keys", record.source_keys.duplicate())
	root.set_meta("feature_kind", str(record.feature_kind))
	root.set_meta("hawkins_massing_override", true)
	root.set_meta("massing_contract", massing_contract())
	root.set_meta("massing_signature", str(geometry.signature))
	root.set_meta("source_geometry_preserved", true)
	if object_key == TARGET_WALL_KEY:
		root.set_meta("source_exterior_foundation_segments", int(record.exterior_foundation_segments))
		root.set_meta("runtime_exterior_wall_quads", 22)
		root.set_meta("runtime_exposed_step_quads", 1)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	mesh_instance.mesh = mesh
	mesh_instance.layers = RENDER_BUILDING_WALL if object_key == TARGET_WALL_KEY else RENDER_WORLD_VISIBLE
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(mesh_instance)

	var body := StaticBody3D.new()
	body.name = "Collision"
	body.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
	body.collision_mask = 0
	body.set_meta("receiver_kind", str(record.receiver_kind))
	body.set_meta("opaque", bool(record.opaque))
	body.set_meta("derived_object_key", object_key)
	body.set_meta("source_keys", record.source_keys.duplicate())
	body.set_meta("hawkins_massing_override", true)
	body.set_meta("massing_signature", str(geometry.signature))
	if object_key == TARGET_WALL_KEY:
		body.add_to_group("spray_receiver_wall")
	var faces := PackedVector3Array()
	for index_value: int in geometry.indices:
		faces.append(geometry.vertices[index_value])
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	shape.set_meta("receiver_kind", str(record.receiver_kind))
	shape.set_meta("opaque", bool(record.opaque))
	shape.set_meta("derived_object_key", object_key)
	shape.set_meta("source_keys", record.source_keys.duplicate())
	shape.set_meta("hawkins_massing_override", true)
	shape.set_meta("massing_signature", str(geometry.signature))
	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "Shape"
	collision_shape.shape = shape
	body.add_child(collision_shape)
	root.add_child(body)

	var mesh_instances := 1
	var surfaces := 1
	if object_key == TARGET_WALL_KEY:
		var facade := FACADE_SCENE.instantiate() as Hawkins77BrutonFacade
		var facade_result := facade.configure(record, massing_contract())
		if not bool(facade_result.get("ok", false)):
			facade.free()
			root.free()
			return {
				"ok": false,
				"code": "hawkins_facade_contract",
				"message": str(facade_result.get("message", "Could not remap Hawkins facade.")),
				"source_keys": record.source_keys,
			}
		root.add_child(facade)

	return {
		"ok": true,
		"node": root,
		"mesh_instances": mesh_instances,
		"surfaces": surfaces,
		"triangles": int(geometry.indices.size() / 3),
	}


static func massing_contract() -> Dictionary:
	var p := split_p()
	var q := split_q()
	var p_exact := split_p_values()
	var q_exact := split_q_values()
	return {
		"schema_version": "ti.hawkins-massing-runtime/1",
		"target_source_key": TARGET_SOURCE_KEY,
		"target_logical_object_key": TARGET_LOGICAL_OBJECT_KEY,
		"outer_ring_xz": [A, B, C, D],
		"split_p_xz": p,
		"split_q_xz": q,
		"split_p_xz_exact": p_exact,
		"split_q_xz_exact": q_exact,
		"main_ring_xz": [A, p, q, C, D],
		"companion_ring_xz": [p, B, q],
		"base_y_m": BASE_Y,
		"main_top_y_m": MAIN_TOP_Y,
		"companion_top_y_m": COMPANION_TOP_Y,
		"main_height_m": 21.0,
		"companion_height_m": 14.0,
		"main_story_count": 6,
		"companion_story_count": 4,
		"story_height_m": 3.5,
		"band_tops_y_m": [7.774, 11.274, 14.774, 18.274, 21.774, 25.274],
		"wsw_split_u_m": WSW_SPLIT_U_M,
		"se_split_u_m": SE_SPLIT_U_M,
		"step_normal_xz": Vector2(0.1253620420, 0.9921110615),
		"step_length_m": 32.533848657,
		"outer_area_m2": 3970.518805999996,
		"main_area_m2": 3604.806003192094,
		"companion_area_m2": 365.712802807902,
		"runtime_wall_quads": 23,
		"runtime_wall_triangles": 46,
		"runtime_roof_triangles": 4,
		"source_wall_quads": 20,
		"source_wall_triangles": 40,
		"source_top_y_m": SOURCE_TOP_Y,
		"runtime_override": true,
	}


static func split_p() -> Vector2:
	var values := split_p_values()
	return Vector2(values[0], values[1])


static func split_q() -> Vector2:
	var values := split_q_values()
	return Vector2(values[0], values[1])


static func split_p_values() -> PackedFloat64Array:
	var dx := BX - AX
	var dz := BZ - AZ
	var scale := WSW_SPLIT_U_M / sqrt(dx * dx + dz * dz)
	return PackedFloat64Array([AX + dx * scale, AZ + dz * scale])


static func split_q_values() -> PackedFloat64Array:
	var dx := CX - BX
	var dz := CZ - BZ
	var scale := SE_SPLIT_U_M / sqrt(dx * dx + dz * dz)
	return PackedFloat64Array([BX + dx * scale, BZ + dz * scale])


static func wall_geometry(record: Dictionary) -> Dictionary:
	if str(record.get("object_key", "")) != TARGET_WALL_KEY:
		return {"ok": false, "code": "hawkins_massing_target", "message": "Wall geometry requested for a non-Hawkins wall."}
	var source_quads := _source_wall_quads(record)
	if source_quads.size() != 20:
		return {"ok": false, "code": "hawkins_massing_source", "message": "Hawkins source wall is not the exact 20-quad receiver."}
	var runtime_quads: Array[Dictionary] = []
	var p3 := Vector3(split_p().x, 0.0, split_p().y)
	var q3 := Vector3(split_q().x, 0.0, split_q().y)
	for source_index in source_quads.size():
		var source := source_quads[source_index]
		if source_index == 4:
			var p_bottom := _interpolated_bottom(source.start_bottom, source.end_bottom, p3)
			_append_wall_quad(runtime_quads, source.start_bottom, p_bottom, MAIN_TOP_Y, source.normal, "outer", "main", source_index)
			_append_wall_quad(runtime_quads, p_bottom, source.end_bottom, COMPANION_TOP_Y, source.normal, "outer", "companion", source_index)
		elif source_index == 9:
			var q_bottom := _interpolated_bottom(source.start_bottom, source.end_bottom, q3)
			_append_wall_quad(runtime_quads, source.start_bottom, q_bottom, COMPANION_TOP_Y, source.normal, "outer", "companion", source_index)
			_append_wall_quad(runtime_quads, q_bottom, source.end_bottom, MAIN_TOP_Y, source.normal, "outer", "main", source_index)
		else:
			var volume := "companion" if source_index in [5, 6, 7, 8] else "main"
			var top_y := COMPANION_TOP_Y if volume == "companion" else MAIN_TOP_Y
			_append_wall_quad(runtime_quads, source.start_bottom, source.end_bottom, top_y, source.normal, "outer", volume, source_index)
	var step_normal_2d := Vector2(0.1253620420, 0.9921110615).normalized()
	var step_normal := Vector3(step_normal_2d.x, 0.0, step_normal_2d.y)
	_append_wall_quad(runtime_quads,
		Vector3(p3.x, COMPANION_TOP_Y, p3.z),
		Vector3(q3.x, COMPANION_TOP_Y, q3.z),
		MAIN_TOP_Y,
		step_normal,
		"step",
		"main",
		-1)
	if runtime_quads.size() != 23:
		return {"ok": false, "code": "hawkins_massing_runtime", "message": "Hawkins runtime wall did not resolve to 23 quads."}
	return _geometry_from_wall_quads(runtime_quads)


static func roof_geometry() -> Dictionary:
	var p := split_p()
	var q := split_q()
	var vertices := PackedVector3Array([
		Vector3(A.x, MAIN_TOP_Y, A.y),
		Vector3(p.x, MAIN_TOP_Y, p.y),
		Vector3(q.x, MAIN_TOP_Y, q.y),
		Vector3(C.x, MAIN_TOP_Y, C.y),
		Vector3(D.x, MAIN_TOP_Y, D.y),
		Vector3(p.x, COMPANION_TOP_Y, p.y),
		Vector3(B.x, COMPANION_TOP_Y, B.y),
		Vector3(q.x, COMPANION_TOP_Y, q.y),
	])
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var tangents := PackedFloat32Array()
	for vertex: Vector3 in vertices:
		normals.append(Vector3.UP)
		uvs.append(Vector2(vertex.x, vertex.z) * 0.1)
		tangents.append_array(PackedFloat32Array([1.0, 0.0, 0.0, 1.0]))
	# Godot's front faces are clockwise when viewed along the outward normal.
	var indices := PackedInt32Array([
		0, 2, 1,
		0, 3, 2,
		0, 4, 3,
		5, 7, 6,
	])
	var signature := _geometry_signature(vertices, indices, "roof")
	return {"ok": true, "vertices": vertices, "normals": normals, "uvs": uvs, "tangents": tangents, "indices": indices, "signature": signature}


static func _source_wall_quads(record: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var raw_vertices: Array = record.get("vertices", [])
	var raw_normals: Array = record.get("normals", [])
	if raw_vertices.size() != 240 or raw_normals.size() != 240:
		return result
	for vertex_index in range(0, 80, 4):
		var offset := vertex_index * 3
		result.append({
			"start_bottom": Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2])),
			"end_bottom": Vector3(float(raw_vertices[offset + 3]), float(raw_vertices[offset + 4]), float(raw_vertices[offset + 5])),
			"normal": Vector3(float(raw_normals[offset]), float(raw_normals[offset + 1]), float(raw_normals[offset + 2])).normalized(),
		})
	return result


static func _interpolated_bottom(start: Vector3, end: Vector3, point_xz: Vector3) -> Vector3:
	var horizontal := Vector2(end.x - start.x, end.z - start.z)
	var along := Vector2(point_xz.x - start.x, point_xz.z - start.z)
	var fraction := along.dot(horizontal) / horizontal.length_squared()
	return Vector3(point_xz.x, lerpf(start.y, end.y, fraction), point_xz.z)


static func _append_wall_quad(target: Array[Dictionary], start_bottom: Vector3, end_bottom: Vector3, top_y: float, normal: Vector3, role: String, volume: String, source_segment: int) -> void:
	target.append({
		"start_bottom": start_bottom,
		"end_bottom": end_bottom,
		"end_top": Vector3(end_bottom.x, top_y, end_bottom.z),
		"start_top": Vector3(start_bottom.x, top_y, start_bottom.z),
		"normal": normal.normalized(),
		"role": role,
		"volume": volume,
		"source_segment": source_segment,
	})


static func _geometry_from_wall_quads(quads: Array[Dictionary]) -> Dictionary:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var tangents := PackedFloat32Array()
	var indices := PackedInt32Array()
	for quad: Dictionary in quads:
		var base := vertices.size()
		var normal := quad.normal as Vector3
		var tangent := Vector3(normal.z, 0.0, -normal.x).normalized()
		var start_bottom := quad.start_bottom as Vector3
		var end_bottom := quad.end_bottom as Vector3
		var end_top := quad.end_top as Vector3
		var start_top := quad.start_top as Vector3
		var length := Vector2(end_bottom.x - start_bottom.x, end_bottom.z - start_bottom.z).length()
		for vertex: Vector3 in [start_bottom, end_bottom, end_top, start_top]:
			vertices.append(vertex)
			normals.append(normal)
			tangents.append_array(PackedFloat32Array([tangent.x, tangent.y, tangent.z, 1.0]))
		uvs.append_array(PackedVector2Array([Vector2(0.0, start_bottom.y * 0.1), Vector2(length * 0.1, end_bottom.y * 0.1), Vector2(length * 0.1, end_top.y * 0.1), Vector2(0.0, start_top.y * 0.1)]))
		indices.append_array(PackedInt32Array([base, base + 2, base + 1, base, base + 3, base + 2]))
	var signature := _geometry_signature(vertices, indices, "wall")
	return {"ok": true, "vertices": vertices, "normals": normals, "uvs": uvs, "tangents": tangents, "indices": indices, "quads": quads, "signature": signature}


static func _geometry_signature(vertices: PackedVector3Array, indices: PackedInt32Array, role: String) -> String:
	var parts := PackedStringArray([role, TARGET_SOURCE_KEY])
	for vertex: Vector3 in vertices:
		parts.append("%.9f,%.9f,%.9f" % [vertex.x, vertex.y, vertex.z])
	for index: int in indices:
		parts.append(str(index))
	return "|".join(parts).sha256_text()


static func _validate_source_record(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return {"ok": false, "code": "hawkins_massing_target", "message": "Hawkins massing refused a non-target record.", "source_keys": record.get("source_keys", [])}
	var object_key := str(record.object_key)
	var expected_feature := "building_wall" if object_key == TARGET_WALL_KEY else "building_roof"
	var expected_material := expected_feature
	var expected_receiver := "building_wall" if object_key == TARGET_WALL_KEY else "none"
	var expected_vertex_values := 240 if object_key == TARGET_WALL_KEY else 12
	var expected_index_values := 120 if object_key == TARGET_WALL_KEY else 6
	if str(record.get("feature_kind", "")) != expected_feature \
		or str(record.get("material_key", "")) != expected_material \
		or str(record.get("receiver_kind", "")) != expected_receiver \
		or (record.get("vertices", []) as Array).size() != expected_vertex_values \
		or (record.get("indices", []) as Array).size() != expected_index_values:
		return {"ok": false, "code": "hawkins_massing_source", "message": "Hawkins generated receiver contract drifted.", "source_keys": record.source_keys}
	var top_y := -INF
	for offset in range(1, (record.vertices as Array).size(), 3):
		top_y = maxf(top_y, float(record.vertices[offset]))
	if not is_equal_approx(top_y, SOURCE_TOP_Y):
		return {"ok": false, "code": "hawkins_massing_source", "message": "Hawkins source top is no longer the approved reversible 6 m assumption.", "source_keys": record.source_keys}
	if object_key == TARGET_WALL_KEY and (int(record.get("exterior_foundation_segments", -1)) != 20 or int(record.get("shared_wall_segments", -1)) != 0):
		return {"ok": false, "code": "hawkins_massing_source", "message": "Hawkins source foundation segmentation drifted.", "source_keys": record.source_keys}
	return {"ok": true}
