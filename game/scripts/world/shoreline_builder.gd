class_name ShorelineBuilder
extends RefCounted
## Shoreline riprap from generated/world/shoreline.json
## (tools/lib/shoreline-generation.mjs), as GeneratedWorldContract expands it:
## the flat shoulder just outside the island outline, the underlay slope behind
## it and its bare rock faces, the concrete closure faces (pier and platform
## edges, boat ramps), the
## instanced quarry stones (top row, back row, shoulder stones and heap), the
## low cobbles in the band inside the outline and the driftwood, each
## segment's stones and underlay in their own materials (its stone tone,
## blended into its neighbours' at its ends). Visual only,
## like the Yerba Buena context: no collision and no spray receiver. The band
## inside the outline is an ordinary chunk overlay; it and the shoulder share
## BAND_GROUND_FAMILY, the dry grass-and-dirt verge at the top of the riprap,
## so the verge runs on past the outline to the stones.

const RIPRAP_SHADER := preload("res://game/resources/materials/world/shoreline/riprap.gdshader")
const GROUND_COVER := preload("res://game/scripts/world/ground_cover.gd")
const RIPRAP_ALBEDO := preload("res://game/resources/textures/world/shoreline/riprap_albedo.png")
const BOULDER_ALBEDO := preload("res://game/resources/textures/world/shoreline/boulder_albedo.png")
const RENDER_WORLD_VISIBLE := 1
## The shader's `surface` per material.
const SURFACE_SLOPE := 0
const SURFACE_STONE := 1
const SURFACE_WOOD := 2
const SURFACE_WALL := 3
const SLOPE_MATERIAL := "shoreline_riprap"
const FACE_MATERIAL := "shoreline_face"
const VERGE_MATERIAL := "shoreline_verge"
const WALL_MATERIAL := "shoreline_wall"
const STONE_MATERIAL := "shoreline_boulder"
const DRIFTWOOD_MATERIAL := "shoreline_driftwood"
## The ground cover family of the verge: the band inside the outline (a chunk
## overlay, see world_chunk_builder.gd) and the shoulder outside it.
const BAND_GROUND_FAMILY := "verge"

static var _riprap := {}


## The underlay slope's material.
static func slope_material() -> ShaderMaterial:
	return _riprap_material(SLOPE_MATERIAL, SURFACE_SLOPE)


## Every instanced stone: top row, back row, shoulder stones, heap and cobbles.
static func stone_material() -> ShaderMaterial:
	return _riprap_material(STONE_MATERIAL, SURFACE_STONE)


## The driftwood logs and planks.
static func driftwood_material() -> ShaderMaterial:
	return _riprap_material(DRIFTWOOD_MATERIAL, SURFACE_WOOD)


## The concrete closure faces: pier and platform edges, boat ramps.
static func wall_material() -> ShaderMaterial:
	return _riprap_material(WALL_MATERIAL, SURFACE_WALL)


## The shoulder strip outside the outline: the verge's own ground cover.
static func verge_material() -> ShaderMaterial:
	return GROUND_COVER.material(BAND_GROUND_FAMILY)


static func _riprap_material(key: String, surface: int) -> ShaderMaterial:
	if not _riprap.has(key):
		var material := ShaderMaterial.new()
		material.resource_name = key
		material.shader = RIPRAP_SHADER
		material.set_shader_parameter("surface", surface)
		material.set_shader_parameter("riprap_albedo", RIPRAP_ALBEDO)
		material.set_shader_parameter("boulder_albedo", BOULDER_ALBEDO)
		_riprap[key] = material
	return _riprap[key]


## A segment's stone or underlay material: the riprap shader with the
## segment's tone and its neighbours' at its ends (document segments' tone), and
## the document's thinning (lod).
static func _segment_material(key: String, surface: int, segment: Dictionary, lod: Dictionary) -> ShaderMaterial:
	var material := (_riprap_material(key, surface).duplicate() as ShaderMaterial)
	material.resource_name = "%s:%s" % [key, str(segment.id)]
	var tone: Dictionary = segment.tone
	material.set_shader_parameter("tone_self", _vector4(tone.stone))
	material.set_shader_parameter("tone_start", _vector4(tone.start.stone))
	material.set_shader_parameter("tone_end", _vector4(tone.end.stone))
	material.set_shader_parameter("joint_start", Vector4(float(tone.start.at[0]), float(tone.start.at[1]), float(tone.start.along[0]), float(tone.start.along[1])))
	material.set_shader_parameter("joint_end", Vector4(float(tone.end.at[0]), float(tone.end.at[1]), float(tone.end.along[0]), float(tone.end.along[1])))
	material.set_shader_parameter("tone_blend_m", float(tone.blend_m))
	material.set_shader_parameter("stone_reach_per_m", float(lod.reach_per_m))
	material.set_shader_parameter("stone_reach_min_m", float(lod.min_m))
	material.set_shader_parameter("stone_reach_max_m", float(lod.max_m))
	material.set_shader_parameter("stone_thin_start", float(lod.start))
	material.set_shader_parameter("underlay_fade_m", Vector2(float(lod.underlay_fade_m[0]), float(lod.underlay_fade_m[1])))
	return material


static func _vector4(values: Array) -> Vector4:
	return Vector4(float(values[0]), float(values[1]), float(values[2]), float(values[3]))


static func _record_material(material_key: String) -> Material:
	match material_key:
		VERGE_MATERIAL:
			return verge_material()
		WALL_MATERIAL:
			return wall_material()
	return slope_material()


## Builds the validated, expanded document into one Node3D; returns the
## builder report.
func build(document: Dictionary) -> Dictionary:
	var root := Node3D.new()
	root.name = "GeneratedShoreline"
	root.set_meta("visual_only", true)
	var triangles := 0
	var mesh_instances := 0
	# Each segment's stones and underlay take their own materials: its tone,
	# blended into its neighbours' at its ends, and the document's thinning.
	var segment_materials := {}
	for segment_value: Variant in document.segments:
		var segment: Dictionary = segment_value
		segment_materials[str(segment.id)] = {
			"stone": _segment_material(STONE_MATERIAL, SURFACE_STONE, segment, document.lod),
			"slope": _segment_material(SLOPE_MATERIAL, SURFACE_SLOPE, segment, document.lod),
			"face": _segment_material(FACE_MATERIAL, SURFACE_SLOPE, segment, document.lod),
		}
		(segment_materials[str(segment.id)].face as ShaderMaterial).set_shader_parameter("rock_face", true)
	for record_value: Variant in document.records:
		var record: Dictionary = record_value
		var instance := MeshInstance3D.new()
		instance.name = str(record.object_key).validate_node_name()
		var record_material := _record_material(str(record.material_key))
		if str(record.material_key) == SLOPE_MATERIAL and segment_materials.has(str(record.segment)):
			record_material = segment_materials[str(record.segment)].slope
		elif str(record.material_key) == FACE_MATERIAL:
			record_material = segment_materials[str(record.segment)].face
		instance.mesh = _array_mesh(record, record_material)
		instance.layers = RENDER_WORLD_VISIBLE
		# Like the terrain overlays, the slope, shoulder and closure faces receive shadows but cast none.
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.set_meta("source_keys", (record.source_keys as Array).duplicate())
		instance.set_meta("visual_only", true)
		root.add_child(instance)
		triangles += int(record.indices.size() / 3)
		mesh_instances += 1
	var prototypes := {}
	for prototype_value: Variant in document.prototypes:
		var prototype: Dictionary = prototype_value
		var material: Material = stone_material() if str(prototype.material_key) == STONE_MATERIAL else driftwood_material()
		prototypes[str(prototype.id)] = {"mesh": _array_mesh(prototype, material), "triangles": int(prototype.indices.size() / 3)}
	# One MultiMesh per generated batch (segment, shore section, band and
	# prototype), so each culls and picks its LOD on its own. The stones carry
	# no colour: the shader tints each one from its position and its segment's
	# tone, and thins them out one by one with distance.
	var stones := Node3D.new()
	stones.name = "Stones"
	root.add_child(stones)
	var batches := 0
	var instances := 0
	for batch_value: Variant in document.batches:
		var batch: Dictionary = batch_value
		var prototype: Dictionary = prototypes[str(batch.prototype)]
		var transforms: PackedFloat32Array = batch.transforms
		var count := int(transforms.size() / GeneratedWorldContract.SHORELINE_PLACEMENT_LENGTH)
		var multi_mesh := MultiMesh.new()
		multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
		multi_mesh.use_colors = false
		multi_mesh.use_custom_data = false
		multi_mesh.mesh = prototype.mesh
		multi_mesh.instance_count = count
		for index in count:
			var at := index * GeneratedWorldContract.SHORELINE_PLACEMENT_LENGTH
			var rotation := Quaternion(transforms[at + 3], transforms[at + 4], transforms[at + 5], transforms[at + 6]).normalized()
			var basis := Basis(rotation) * Basis.from_scale(Vector3(transforms[at + 7], transforms[at + 8], transforms[at + 9]))
			multi_mesh.set_instance_transform(index, Transform3D(basis, Vector3(transforms[at], transforms[at + 1], transforms[at + 2])))
		var node := MultiMeshInstance3D.new()
		node.name = str(batch.id).validate_node_name()
		node.multimesh = multi_mesh
		node.layers = RENDER_WORLD_VISIBLE
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if bool(batch.cast_shadow) else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		node.visibility_range_end = float(batch.visibility_end_m)
		node.visibility_range_end_margin = float(batch.visibility_margin_m)
		if str(batch.band) == "driftwood":
			node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		else:
			# The stones thin out one by one in the shader; the batch range only
			# culls it once its last stone has gone.
			node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
			node.material_override = segment_materials[str(batch.segment)].stone
		node.set_meta("band", str(batch.band))
		node.set_meta("placement_count", count)
		node.set_meta("visual_only", true)
		stones.add_child(node)
		batches += 1
		instances += count
		triangles += int(prototype.triangles) * count
	return {
		"ok": true,
		"node": root,
		"mesh_instances": mesh_instances + batches,
		"surfaces": mesh_instances + batches,
		"triangles": triangles,
		"multimesh_batches": batches,
		"boulders": instances,
	}


## An ArrayMesh from a mesh dictionary: vertices and normals (packed Vector3
## arrays, or flat number arrays as in the prototypes), indices, and optional
## uvs and lods ([{error_m, indices}]). The generated contract winds triangles
## counterclockwise around their outward normals; Godot treats clockwise as
## front-facing, so each triplet is turned once here, as world_chunk_builder.gd
## does for chunk records. A mesh with UVs (the shoulder) also gets tangents
## for the ground cover's normal map.
static func _array_mesh(record: Dictionary, material: Material) -> ArrayMesh:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _vector3s(record.vertices)
	arrays[Mesh.ARRAY_NORMAL] = _vector3s(record.normals)
	arrays[Mesh.ARRAY_INDEX] = _clockwise(record.indices)
	# Coarser index sets over the same vertices, keyed by their error for a 1 m stone.
	var lods := {}
	for lod_value: Variant in record.get("lods", []):
		var lod: Dictionary = lod_value
		lods[float(lod.error_m)] = _clockwise(lod.indices)
	var mesh := ArrayMesh.new()
	if record.has("uvs"):
		var uvs := PackedVector2Array()
		var source: Variant = record.uvs
		if source is PackedVector2Array:
			uvs = source
		else:
			var flat: Array = source
			for index in range(0, flat.size(), 2):
				uvs.append(Vector2(float(flat[index]), float(flat[index + 1])))
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		var tool := SurfaceTool.new()
		tool.create_from_arrays(arrays)
		tool.generate_tangents()
		mesh = tool.commit()
	else:
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], lods)
	mesh.surface_set_material(0, material)
	mesh.resource_name = str(record.get("object_key", record.get("id", "shoreline")))
	return mesh


## Packed Vector3 values as they are, or a flat [x, y, z, ...] number array as Vector3s.
static func _vector3s(source: Variant) -> PackedVector3Array:
	if source is PackedVector3Array:
		return source
	var values := PackedVector3Array()
	var flat: Array = source
	for index in range(0, flat.size(), 3):
		values.append(Vector3(float(flat[index]), float(flat[index + 1]), float(flat[index + 2])))
	return values


## Index triplets turned from counterclockwise to Godot's clockwise.
static func _clockwise(source: Variant) -> PackedInt32Array:
	var values: PackedInt32Array = source if source is PackedInt32Array else PackedInt32Array(source as Array)
	var indices := PackedInt32Array()
	indices.resize(values.size())
	for index in range(0, values.size(), 3):
		indices[index] = values[index]
		indices[index + 1] = values[index + 2]
		indices[index + 2] = values[index + 1]
	return indices
