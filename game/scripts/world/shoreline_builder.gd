class_name ShorelineBuilder
extends RefCounted
## Shoreline riprap from generated/world/shoreline.json
## (tools/lib/shoreline-generation.mjs): the rock slope outside the island
## outline and the boulders instanced along the crest, over the slope and at the
## waterline. Visual only, like the Yerba Buena context: no collision and no
## spray receiver. The riprap band inside the outline is an ordinary chunk
## overlay; world_chunk_builder.gd gives it riprap_material().

const RIPRAP_SHADER := preload("res://game/resources/materials/world/shoreline/riprap.gdshader")
const RIPRAP_ALBEDO := preload("res://game/resources/textures/world/shoreline/riprap_albedo.png")
const RENDER_WORLD_VISIBLE := 1
## Instance-colour alpha that marks a boulder for the riprap shader.
const BOULDER_ALPHA := 0.5
## Bleached driftwood, multiplied by each log's instance colour.
const DRIFTWOOD_ALBEDO := Color(0.74, 0.7, 0.63)
const SLOPE_MATERIAL := "shoreline_riprap"
const DRIFTWOOD_MATERIAL := "shoreline_driftwood"

static var _riprap: ShaderMaterial
static var _driftwood: StandardMaterial3D


## The one shared riprap material of the overlay, the slope and the boulders.
static func riprap_material() -> ShaderMaterial:
	if _riprap == null:
		_riprap = ShaderMaterial.new()
		_riprap.resource_name = "shoreline_riprap"
		_riprap.shader = RIPRAP_SHADER
		_riprap.set_shader_parameter("riprap_albedo", RIPRAP_ALBEDO)
	return _riprap


static func driftwood_material() -> StandardMaterial3D:
	if _driftwood == null:
		_driftwood = StandardMaterial3D.new()
		_driftwood.resource_name = "shoreline_driftwood"
		_driftwood.albedo_color = DRIFTWOOD_ALBEDO
		_driftwood.vertex_color_use_as_albedo = true
		_driftwood.roughness = 0.95
	return _driftwood


## Builds the validated document into one Node3D; returns the builder report.
func build(document: Dictionary) -> Dictionary:
	var root := Node3D.new()
	root.name = "GeneratedShoreline"
	root.set_meta("visual_only", true)
	var triangles := 0
	var mesh_instances := 0
	var surfaces := 0
	for record_value: Variant in document.records:
		var record: Dictionary = record_value
		var mesh := _array_mesh(record, riprap_material())
		var instance := MeshInstance3D.new()
		instance.name = str(record.object_key).validate_node_name()
		instance.mesh = mesh
		instance.layers = RENDER_WORLD_VISIBLE
		# Like the terrain overlays, the slope receives shadows but casts none.
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.set_meta("source_keys", (record.source_keys as Array).duplicate())
		instance.set_meta("visual_only", true)
		root.add_child(instance)
		triangles += int(record.indices.size() / 3)
		mesh_instances += 1
		surfaces += 1
	var prototypes := {}
	for prototype_value: Variant in document.prototypes:
		var prototype: Dictionary = prototype_value
		var material: Material = riprap_material()
		if str(prototype.material_key) == DRIFTWOOD_MATERIAL:
			material = driftwood_material()
		prototypes[str(prototype.id)] = {"mesh": _array_mesh(prototype, material), "triangles": int(prototype.indices.size() / 3), "boulder": str(prototype.material_key) == SLOPE_MATERIAL}
	# One MultiMesh per prototype and shore section, so each batch culls and
	# fades with distance on its own. Stones bedded in the slope cast no
	# shadow (the shader's relief shades them); the top course, crest, toe
	# and driftwood do.
	var groups := {}
	for placement_value: Variant in document.placements:
		var placement: Dictionary = placement_value
		var key := "%s_%02d_%s" % [str(placement.prototype), int(placement.section), "bedded" if str(placement.band) == "slope" else "standing"]
		if not groups.has(key):
			groups[key] = []
		(groups[key] as Array).append(placement)
	var keys: Array = groups.keys()
	keys.sort()
	var batches := 0
	var instances := 0
	var boulder_root := Node3D.new()
	boulder_root.name = "Boulders"
	root.add_child(boulder_root)
	for key_value: Variant in keys:
		var key := str(key_value)
		var placements: Array = groups[key]
		var prototype: Dictionary = prototypes[str((placements[0] as Dictionary).prototype)]
		var multi_mesh := MultiMesh.new()
		multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
		multi_mesh.use_colors = true
		multi_mesh.use_custom_data = false
		multi_mesh.mesh = prototype.mesh
		multi_mesh.instance_count = placements.size()
		for index in placements.size():
			var placement: Dictionary = placements[index]
			var b: Array = placement.basis
			var o: Array = placement.origin
			var basis := Basis(
				Vector3(float(b[0]), float(b[1]), float(b[2])),
				Vector3(float(b[3]), float(b[4]), float(b[5])),
				Vector3(float(b[6]), float(b[7]), float(b[8])))
			multi_mesh.set_instance_transform(index, Transform3D(basis, Vector3(float(o[0]), float(o[1]), float(o[2]))))
			var tint: Array = placement.tint
			multi_mesh.set_instance_color(index, Color(float(tint[0]), float(tint[1]), float(tint[2]), BOULDER_ALPHA if bool(prototype.boulder) else 1.0))
		var batch := MultiMeshInstance3D.new()
		batch.name = key
		batch.multimesh = multi_mesh
		batch.layers = RENDER_WORLD_VISIBLE
		batch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if key.ends_with("bedded") else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		batch.visibility_range_end = float(document.visibility_range_m)
		batch.visibility_range_end_margin = float(document.visibility_range_m) * 0.12
		batch.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		batch.set_meta("placement_count", placements.size())
		batch.set_meta("visual_only", true)
		boulder_root.add_child(batch)
		batches += 1
		instances += placements.size()
		triangles += int(prototype.triangles) * placements.size()
	return {
		"ok": true,
		"node": root,
		"mesh_instances": mesh_instances + batches,
		"surfaces": surfaces + batches,
		"triangles": triangles,
		"multimesh_batches": batches,
		"boulders": instances,
	}


## An ArrayMesh from a generated mesh dictionary (vertices, normals, indices).
## The generated contract winds triangles counterclockwise around their
## outward normals; Godot treats clockwise as front-facing, so each triplet is
## turned once here, as world_chunk_builder.gd does for chunk records.
static func _array_mesh(record: Dictionary, material: Material) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	var v: Array = record.vertices
	var n: Array = record.normals
	for index in range(0, v.size(), 3):
		vertices.append(Vector3(float(v[index]), float(v[index + 1]), float(v[index + 2])))
		normals.append(Vector3(float(n[index]), float(n[index + 1]), float(n[index + 2])))
	var source: Array = record.indices
	for index in range(0, source.size(), 3):
		indices.append(int(source[index]))
		indices.append(int(source[index + 2]))
		indices.append(int(source[index + 1]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	mesh.resource_name = str(record.get("object_key", record.get("id", "shoreline")))
	return mesh
