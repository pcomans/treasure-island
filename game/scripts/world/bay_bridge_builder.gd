extends RefCounted
## Draws the Bay Bridge scenery record (context:bay-bridge, built by
## tools/lib/bay-bridge-generation.mjs): non-colliding, never reached by the player.
##
## Each vertex's UV carries the generator's data: x the material role (ROLE_COLORS,
## in tools/lib/bay-bridge-design.mjs's BRIDGE_ROLES order), y the detail class
## (CLASS_*). Solid triangles become meshes per class and per CELL_M square, so the
## far parts and detail beyond DETAIL_END_M drop out by distance; their colours go to
## sRGB vertex colours on three shared surfaces (painted steel, concrete, asphalt).
## Wires are ribbons of four vertices in the fixed order [start - side, start + side,
## end + side, end - side]; they are rebuilt as centre lines for the wire shader,
## which keeps them at least a pixel or so wide and fades them by the share of that
## width they cover.

const WIRE_SHADER := preload("res://game/resources/materials/world/bay_bridge/bay_bridge_wire.gdshader")

const CLASS_STRUCTURE := 0
const CLASS_DETAIL := 1
const CLASS_WIRE := 2
const CLASS_WIRE_FAR := 3
## Solid detail stops here; wires of class CLASS_WIRE_FAR stand in beyond it.
const DETAIL_END_M := 2400.0
const DETAIL_FADE_M := 250.0
const CELL_M := 400.0
## Wires can be drawn a few pixels wider than their true width (several metres at the
## far plane), so their bounds grow by this much for culling.
const WIRE_BOUNDS_GROW_M := 12.0

## Albedo per role (sRGB), read from dated photographs: the self-anchored span's white
## paint, the Skyway's and the transition structure's light concrete, the western
## span's weathered aluminium paint. Production inference, not paint specifications.
const ROLE_COLORS: Array[Color] = [
	Color8(222, 223, 220), # sas_white
	Color8(186, 183, 175), # concrete
	Color8(122, 119, 112), # concrete_dark
	Color8(88, 89, 92), # roadway
	Color8(204, 201, 193), # barrier
	Color8(168, 172, 176), # steel_silver
	Color8(232, 232, 228), # light_pole
	Color8(222, 223, 220), # suspender
	Color8(160, 164, 168), # cable_silver
	Color8(22, 22, 24), # tunnel_void
]
## Surface family per role: 0 painted steel, 1 concrete, 2 asphalt.
const ROLE_FAMILY: Array[int] = [0, 1, 1, 2, 1, 0, 0, 0, 0, 1]
const FAMILY_NAMES: Array[String] = ["painted_steel", "concrete", "asphalt"]
const FAMILY_ROUGHNESS: Array[float] = [0.55, 0.9, 1.0]
const FAMILY_SPECULAR: Array[float] = [0.45, 0.3, 0.25]

static var _solid_materials: Array[StandardMaterial3D] = []
static var _wire_material: ShaderMaterial


static func matches_record(record: Dictionary, is_context: bool) -> bool:
	return is_context and str(record.get("feature_kind", "")) == "bay_bridge"


static func build_record(record: Dictionary) -> Dictionary:
	var source_vertices: Array = record.vertices
	var source_uvs: Array = record.uvs
	var indices: Array = record.indices
	var vertex_count := int(source_vertices.size() / 3)
	var points := PackedVector3Array()
	points.resize(vertex_count)
	var roles := PackedInt32Array()
	roles.resize(vertex_count)
	var classes := PackedInt32Array()
	classes.resize(vertex_count)
	for index in vertex_count:
		points[index] = Vector3(float(source_vertices[index * 3]), float(source_vertices[index * 3 + 1]), float(source_vertices[index * 3 + 2]))
		roles[index] = int(source_uvs[index * 2])
		classes[index] = int(source_uvs[index * 2 + 1])
		if roles[index] < 0 or roles[index] >= ROLE_COLORS.size() or classes[index] < CLASS_STRUCTURE or classes[index] > CLASS_WIRE_FAR:
			return _failure("Bay Bridge vertex %d has an unknown role or class." % index, record)
	var source_normals: Array = record.normals
	# Buckets: class and cell -> solid triangles or wire quads (first index of each).
	var buckets := {}
	var cursor := 0
	while cursor < indices.size():
		var first := int(indices[cursor])
		var kind := classes[first]
		if kind == CLASS_WIRE or kind == CLASS_WIRE_FAR:
			if cursor + 6 > indices.size() or int(indices[cursor + 3]) != first or int(indices[cursor + 4]) != int(indices[cursor + 2]) \
			or int(indices[cursor + 1]) != first + 1 or int(indices[cursor + 2]) != first + 2 or int(indices[cursor + 5]) != first + 3:
				return _failure("Bay Bridge wire at index %d is not a four-vertex ribbon." % cursor, record)
			var middle := (points[first] + points[first + 2]) * 0.5
			_bucket(buckets, kind, middle).append(first)
			cursor += 6
		else:
			var centroid := (points[first] + points[int(indices[cursor + 1])] + points[int(indices[cursor + 2])]) / 3.0
			_bucket(buckets, kind, centroid).append(cursor)
			cursor += 3
	var root := Node3D.new()
	root.name = str(record.object_key).validate_node_name()
	root.set_meta("derived_object_key", str(record.object_key))
	root.set_meta("source_keys", record.source_keys.duplicate())
	root.set_meta("feature_kind", str(record.feature_kind))
	var mesh_instances := 0
	var surfaces := 0
	var triangles := 0
	var keys := buckets.keys()
	keys.sort()
	for key: String in keys:
		var bucket: Dictionary = buckets[key]
		var kind := int(bucket.kind)
		var center := Vector3(bucket.center)
		var instance := MeshInstance3D.new()
		instance.name = key
		instance.position = center
		instance.layers = 1
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var mesh: ArrayMesh
		if kind == CLASS_WIRE or kind == CLASS_WIRE_FAR:
			mesh = _wire_mesh(bucket.items, points, roles, center)
			triangles += int(bucket.items.size()) * 2
		else:
			mesh = _solid_mesh(bucket.items, indices, points, source_normals, roles, center)
			triangles += int(bucket.items.size())
		instance.mesh = mesh
		if kind == CLASS_DETAIL:
			instance.visibility_range_end = DETAIL_END_M
			instance.visibility_range_end_margin = DETAIL_FADE_M
			instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		elif kind == CLASS_WIRE_FAR:
			instance.visibility_range_begin = DETAIL_END_M
			instance.visibility_range_begin_margin = DETAIL_FADE_M
			instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		root.add_child(instance)
		mesh_instances += 1
		surfaces += mesh.get_surface_count()
	return {"ok": true, "node": root, "mesh_instances": mesh_instances, "surfaces": surfaces, "triangles": triangles}


static func _bucket(buckets: Dictionary, kind: int, at: Vector3) -> Array:
	var column := int(floor(at.x / CELL_M))
	var row := int(floor(at.z / CELL_M))
	var key := "c%d_x%d_z%d" % [kind, column, row]
	if not buckets.has(key):
		buckets[key] = {"kind": kind, "items": [], "center": Vector3((column + 0.5) * CELL_M, 0.0, (row + 0.5) * CELL_M)}
	return buckets[key].items


## Solid triangles of one bucket: shared vertices per family surface, positions
## relative to the bucket's centre, the generated counterclockwise triangles turned
## to Godot's clockwise front faces.
static func _solid_mesh(items: Array, indices: Array, points: PackedVector3Array, source_normals: Array, roles: PackedInt32Array, center: Vector3) -> ArrayMesh:
	var families := []
	for family in FAMILY_NAMES.size():
		families.append({"remap": {}, "vertices": PackedVector3Array(), "normals": PackedVector3Array(), "colors": PackedColorArray(), "indices": PackedInt32Array()})
	for cursor: int in items:
		var corners := [int(indices[cursor]), int(indices[cursor + 2]), int(indices[cursor + 1])]
		var surface: Dictionary = families[ROLE_FAMILY[roles[corners[0]]]]
		for corner: int in corners:
			if not surface.remap.has(corner):
				surface.remap[corner] = surface.vertices.size()
				surface.vertices.append(points[corner] - center)
				surface.normals.append(Vector3(float(source_normals[corner * 3]), float(source_normals[corner * 3 + 1]), float(source_normals[corner * 3 + 2])))
				surface.colors.append(ROLE_COLORS[roles[corner]])
			surface.indices.append(int(surface.remap[corner]))
	var mesh := ArrayMesh.new()
	for family in FAMILY_NAMES.size():
		var surface: Dictionary = families[family]
		if surface.indices.is_empty():
			continue
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = surface.vertices
		arrays[Mesh.ARRAY_NORMAL] = surface.normals
		arrays[Mesh.ARRAY_COLOR] = surface.colors
		arrays[Mesh.ARRAY_INDEX] = surface.indices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		var surface_index := mesh.get_surface_count() - 1
		mesh.surface_set_name(surface_index, FAMILY_NAMES[family])
		mesh.surface_set_material(surface_index, _solid_material(family))
	return mesh


## Wire ribbons of one bucket as centre-line strips for the wire shader.
static func _wire_mesh(items: Array, points: PackedVector3Array, roles: PackedInt32Array, center: Vector3) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	var strip_indices := PackedInt32Array()
	var bounds := AABB()
	for first: int in items:
		var start := (points[first] + points[first + 1]) * 0.5 - center
		var end := (points[first + 2] + points[first + 3]) * 0.5 - center
		var radius := points[first].distance_to(points[first + 1]) * 0.5
		var direction := (end - start).normalized()
		var color := ROLE_COLORS[roles[first]]
		var base := vertices.size()
		for corner in [[start, -1.0], [start, 1.0], [end, 1.0], [end, -1.0]]:
			vertices.append(corner[0])
			normals.append(direction)
			uvs.append(Vector2(float(corner[1]), radius))
			colors.append(color)
		strip_indices.append_array([base, base + 1, base + 2, base, base + 2, base + 3])
		bounds = AABB(start, Vector3.ZERO) if base == 0 else bounds.expand(start)
		bounds = bounds.expand(end)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = strip_indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_name(0, "wires")
	mesh.surface_set_material(0, _wire_shader_material())
	mesh.custom_aabb = bounds.grow(WIRE_BOUNDS_GROW_M)
	return mesh


static func _solid_material(family: int) -> StandardMaterial3D:
	if _solid_materials.is_empty():
		for index in FAMILY_NAMES.size():
			var material := StandardMaterial3D.new()
			material.resource_name = "bay_bridge_" + FAMILY_NAMES[index]
			material.vertex_color_use_as_albedo = true
			material.vertex_color_is_srgb = true
			material.albedo_color = Color.WHITE
			material.roughness = FAMILY_ROUGHNESS[index]
			material.metallic_specular = FAMILY_SPECULAR[index]
			_solid_materials.append(material)
	return _solid_materials[family]


static func _wire_shader_material() -> ShaderMaterial:
	if _wire_material == null:
		_wire_material = ShaderMaterial.new()
		_wire_material.resource_name = "bay_bridge_wires"
		_wire_material.shader = WIRE_SHADER
	return _wire_material


static func _failure(message: String, record: Dictionary) -> Dictionary:
	return {"ok": false, "code": "bay_bridge_record", "message": message, "source_keys": record.get("source_keys", [])}
