extends RefCounted
## Packs the baked world's buildings into far fewer draws without changing what they
## draw. Runs only in the static-world bake (tools/prebuild_static_world.gd); the world
## generated at startup keeps its authored nodes.
##
## A building's opaque surfaces that differ only in base colour become one surface, the
## colour moving into vertex colours. Surfaces that differ in anything else (roughness,
## metallic, textures, cull mode...) stay apart, so each keeps the material it had.
## Merged meshes keep their sources' triangles, in the order the sources were found.
##
## Left exactly as authored:
## - hidden meshes, and anything but a MeshInstance3D;
## - glass and other transparency, and everything with its own shader, such as the
##   Mersea mural: these sort or shade by more than their material's plain values;
## - instances on a reflection layer, or with per-instance rendering settings;
## - triplanar materials, which pattern by object-space position, so moving a part would
##   shift its pattern; and scaled or sheared parts, whose normals the renderer treats
##   differently from a plain rotation;
## - housing support and retained ground meshes: StudyGeometry.retained_ground_contact
##   compares them with their collider face by face, in order.

## Metadata that says which building and role a mesh belongs to. A merged mesh carries
## its sources' values; meshes that differ in any of them don't merge.
const IDENTITY_META: Array[StringName] = [&"source_keys", &"source_key", &"derived_object_key", &"family_role", &"physical_role", &"mersea_role", &"visual_only"]
## The identity metadata that tree walks inherit downwards. A merged mesh hangs from the
## nearest ancestor holding any of these, so those walks read the same roles as before.
const INHERITED_META: Array[StringName] = [&"source_keys", &"source_key", &"derived_object_key", &"family_role", &"physical_role"]
## Layers that plain building parts use. Mersea's glass and tagged metal sit on others,
## where a reflection probe's mask finds them.
const PLAIN_LAYERS := 3
const INSTANCE_DEFAULTS := {
	"transparency": 0.0, "visibility_range_begin": 0.0, "visibility_range_end": 0.0, "extra_cull_margin": 0.0,
	"lod_bias": 1.0, "sorting_offset": 0.0, "custom_aabb": AABB(), "material_overlay": null, "skin": null,
	"gi_mode": GeometryInstance3D.GI_MODE_STATIC, "skeleton": NodePath(),
}
const MATERIAL_DEFAULTS := {
	"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED, "blend_mode": BaseMaterial3D.BLEND_MODE_MIX, "next_pass": null,
	"refraction_enabled": false, "vertex_color_use_as_albedo": false, "uv1_triplanar": false, "uv2_triplanar": false,
	"billboard_mode": BaseMaterial3D.BILLBOARD_DISABLED, "grow": false, "heightmap_enabled": false, "no_depth_test": false,
	"proximity_fade_enabled": false, "distance_fade_mode": BaseMaterial3D.DISTANCE_FADE_DISABLED, "fixed_size": false,
	"use_point_size": false, "use_particle_trails": false,
}
## Material properties that don't take part in matching: the base colour moves to the
## vertices, and the rest don't reach the picture.
const UNMATCHED_PROPERTIES := ["albedo_color", "resource_name", "resource_path", "resource_local_to_scene", "resource_scene_unique_id", "script"]
const CARRIED_CHANNELS: Array[int] = [Mesh.ARRAY_NORMAL, Mesh.ARRAY_TANGENT, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_TEX_UV2]
const UNSUPPORTED_CHANNELS: Array[int] = [Mesh.ARRAY_CUSTOM0, Mesh.ARRAY_CUSTOM1, Mesh.ARRAY_CUSTOM2, Mesh.ARRAY_CUSTOM3, Mesh.ARRAY_BONES, Mesh.ARRAY_WEIGHTS]


## Merges in place under buildings. Returns the counts before and after, for the log,
## and in problems any merged mesh that came out short: the bake fails on those.
static func merge(buildings: Node3D) -> Dictionary:
	var leaves: Array[Node] = buildings.find_children("*", "MeshInstance3D", true, false)
	var uses := {}
	for node: MeshInstance3D in leaves:
		if node.mesh != null:
			uses[node.mesh] = int(uses.get(node.mesh, 0)) + 1
	# A MultiMesh draws its mesh too, so taking surfaces out of it would change those instances.
	for node: MultiMeshInstance3D in buildings.find_children("*", "MultiMeshInstance3D", true, false):
		if node.multimesh != null and node.multimesh.mesh != null:
			uses[node.multimesh.mesh] = int(uses.get(node.multimesh.mesh, 0)) + 1
	var groups := {}
	var signatures := {}
	var materials := {}
	var counts := {"meshes_before": 0, "surfaces_before": 0, "meshes_kept": 0, "surfaces_kept": 0}
	for node: MeshInstance3D in leaves:
		if node.mesh == null or not node.is_visible_in_tree():
			continue
		var mesh := node.mesh
		var surface_count := mesh.get_surface_count()
		counts.meshes_before += 1
		counts.surfaces_before += surface_count
		var anchor := _anchor(node, buildings)
		var to_anchor := _relative_transform(node, anchor)
		var taken: Array[int] = []
		if _may_merge(node, uses, anchor, to_anchor):
			var group := _group(groups, node, anchor)
			for surface in surface_count:
				var material := node.get_active_material(surface)
				var signature := _signature(material, signatures)
				if signature.is_empty():
					continue
				var arrays := mesh.surface_get_arrays(surface)
				if not _has_only_supported_channels(arrays) or (mesh is ArrayMesh and (mesh as ArrayMesh).surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES):
					continue
				_add_part(group, signature, material as StandardMaterial3D, arrays, to_anchor, materials)
				taken.append(surface)
		if surface_count > 0 and taken.size() == surface_count:
			node.get_parent().remove_child(node)
			node.free()
			continue
		# Kept surfaces stay in their own mesh, their buffers untouched.
		taken.reverse()
		for surface in taken:
			(mesh as ArrayMesh).surface_remove(surface)
		counts.meshes_kept += 1
		counts.surfaces_kept += mesh.get_surface_count()
	var merged_meshes := 0
	var merged_surfaces := 0
	var problems := PackedStringArray()
	for group: Dictionary in groups.values():
		# A group stays empty when all its candidates' surfaces had to stay.
		if not group.surfaces.is_empty():
			var built := _build_node(group, merged_meshes)
			var problem := _build_problem(built, group)
			if problem != "":
				problems.append("BakedBatch%d under %s: %s" % [merged_meshes, (group.anchor as Node3D).get_path(), problem])
			merged_surfaces += built.get_surface_count()
			merged_meshes += 1
	counts["meshes_after"] = counts.meshes_kept + merged_meshes
	counts["surfaces_after"] = counts.surfaces_kept + merged_surfaces
	counts["materials_after"] = materials.size()
	counts["problems"] = problems
	return counts


## The nearest ancestor holding inherited identity, or else the building's top node.
static func _anchor(node: Node3D, buildings: Node3D) -> Node3D:
	var current := node.get_parent() as Node3D
	while current != buildings and current.get_parent() != buildings:
		for key: StringName in INHERITED_META:
			if current.has_meta(key):
				return current
		current = current.get_parent() as Node3D
	return current


## Multiplied down from the anchor, so a part with no offset stays exactly in place.
static func _relative_transform(node: Node3D, anchor: Node3D) -> Transform3D:
	var transform := Transform3D.IDENTITY
	var current := node
	while current != anchor:
		transform = current.transform * transform
		current = current.get_parent() as Node3D
	return transform


static func _may_merge(node: MeshInstance3D, uses: Dictionary, anchor: Node3D, to_anchor: Transform3D) -> bool:
	if int(uses[node.mesh]) != 1 or node.get_child_count() != 0 or node.get_script() != null or (node.layers & ~PLAIN_LAYERS) != 0:
		return false
	if _in_contact_proof(node) or not (node.mesh is ArrayMesh or node.mesh.get_surface_count() == 1):
		return false
	if node.mesh is ArrayMesh and (node.mesh as ArrayMesh).get_blend_shape_count() != 0:
		return false
	# Overrides are held by surface index, which taking surfaces out of the mesh would shift.
	for surface in node.get_surface_override_material_count():
		if node.get_surface_override_material(surface) != null:
			return false
	for key: String in INSTANCE_DEFAULTS:
		if node.get(key) != INSTANCE_DEFAULTS[key]:
			return false
	var current := node as Node3D
	while current != anchor:
		if current.top_level:
			return false
		current = current.get_parent() as Node3D
	var basis := to_anchor.basis
	return basis.determinant() > 0.0 and basis.is_equal_approx(basis.orthonormalized())


static func _in_contact_proof(node: MeshInstance3D) -> bool:
	if str(node.get_meta("physical_role", "")) == "ground_visual":
		return true
	return node.get_parent().has_meta("scope") and str(node.get_meta("family_role", "support")) == "support"


## The group of surfaces that will share one merged node with this one.
static func _group(groups: Dictionary, node: MeshInstance3D, anchor: Node3D) -> Dictionary:
	var identity := {}
	for key: StringName in IDENTITY_META:
		if node.has_meta(key):
			identity[key] = node.get_meta(key)
	var group_key := "%d|%s|%d|%d" % [anchor.get_instance_id(), identity, node.cast_shadow, node.layers]
	if not groups.has(group_key):
		groups[group_key] = {"anchor": anchor, "identity": identity, "cast_shadow": node.cast_shadow, "layers": node.layers, "surfaces": {}}
	return groups[group_key]


## "" for a material that must keep its own surface. Otherwise a text that two materials
## share exactly when they differ at most in base colour.
static func _signature(material: Material, signatures: Dictionary) -> String:
	if signatures.has(material):
		return signatures[material]
	var signature := ""
	if _is_plain(material):
		var parts := PackedStringArray()
		for property: Dictionary in material.get_property_list():
			var key: String = property.name
			if int(property.usage) & PROPERTY_USAGE_STORAGE != 0 and key not in UNMATCHED_PROPERTIES:
				var value: Variant = material.get(key)
				parts.append(key + "=" + (str(value.get_instance_id()) if value is Resource else var_to_str(value)))
		signature = "|".join(parts)
	signatures[material] = signature
	return signature


static func _is_plain(material: Material) -> bool:
	if not material is StandardMaterial3D:
		return false
	for key: String in MATERIAL_DEFAULTS:
		if material.get(key) != MATERIAL_DEFAULTS[key]:
			return false
	var albedo: Color = material.get("albedo_color")
	return albedo.clamp() == albedo


static func _has_only_supported_channels(arrays: Array) -> bool:
	for channel: int in UNSUPPORTED_CHANNELS:
		if arrays[channel] != null:
			return false
	return true


static func _add_part(group: Dictionary, signature: String, material: StandardMaterial3D, arrays: Array, to_anchor: Transform3D, materials: Dictionary) -> void:
	var channels := 0
	for channel: int in CARRIED_CHANNELS:
		if arrays[channel] != null:
			channels |= 1 << channel
	var surface_key := "%d|%s" % [channels, signature]
	if not group.surfaces.has(surface_key):
		group.surfaces[surface_key] = {"material": _merged_material(material, signature, materials), "channels": channels, "parts": []}
	group.surfaces[surface_key].parts.append({"arrays": arrays, "to_anchor": to_anchor, "color": _vertex_color(material.albedo_color)})


## One material per signature, its colour coming from the vertices.
static func _merged_material(material: StandardMaterial3D, signature: String, materials: Dictionary) -> StandardMaterial3D:
	if not materials.has(signature):
		var merged := material.duplicate() as StandardMaterial3D
		merged.albedo_color = Color.WHITE
		merged.vertex_color_use_as_albedo = true
		# As sRGB, as albedo_color is: both renderers then read the same value from it,
		# where Compatibility would read linear vertex colours far too dark, and the
		# 8 bits per channel a vertex colour stores keep dark colours apart.
		merged.vertex_color_is_srgb = true
		materials[signature] = merged
	return materials[signature]


## The stored byte is the colour rounded to 8 bits. The engine truncates when it stores,
## so aim a quarter step above the byte: rounding and truncation then agree.
static func _vertex_color(color: Color) -> Color:
	return Color((roundf(color.r * 255.0) + 0.25) / 255.0, (roundf(color.g * 255.0) + 0.25) / 255.0, (roundf(color.b * 255.0) + 0.25) / 255.0)


static func _build_node(group: Dictionary, index: int) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	for surface: Dictionary in group.surfaces.values():
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _surface_arrays(surface))
		mesh.surface_set_material(mesh.get_surface_count() - 1, surface.material)
	var node := MeshInstance3D.new()
	node.name = "BakedBatch%d" % index
	node.mesh = mesh
	node.cast_shadow = group.cast_shadow
	node.layers = group.layers
	for key: StringName in group.identity:
		node.set_meta(key, group.identity[key])
	# main.gd leaves these whole: their distance culling would drop an entire building.
	node.set_meta("baked_merge", true)
	(group.anchor as Node3D).add_child(node)
	return mesh


## Why a built mesh doesn't hold all of its group, or "" when it does. A surface that won't
## build only logs an engine error, and its source meshes are gone by then.
static func _build_problem(mesh: ArrayMesh, group: Dictionary) -> String:
	var surfaces: Array = group.surfaces.values()
	if mesh.get_surface_count() != surfaces.size():
		return "%d of %d surfaces built" % [mesh.get_surface_count(), surfaces.size()]
	for surface in surfaces.size():
		var wanted := 0
		for part: Dictionary in surfaces[surface].parts:
			var arrays: Array = part.arrays
			wanted += (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() if arrays[Mesh.ARRAY_INDEX] != null else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
		if mesh.surface_get_array_index_len(surface) != wanted:
			return "surface %d has %d of %d indices" % [surface, mesh.surface_get_array_index_len(surface), wanted]
	return ""


static func _surface_arrays(surface: Dictionary) -> Array:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var tangents := PackedFloat32Array()
	var colors := PackedColorArray()
	var uvs := PackedVector2Array()
	var uv2s := PackedVector2Array()
	var indices := PackedInt32Array()
	for part: Dictionary in surface.parts:
		var arrays: Array = part.arrays
		var to_anchor: Transform3D = part.to_anchor
		var part_vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var count := part_vertices.size()
		var base := vertices.size()
		vertices.append_array(part_vertices if to_anchor == Transform3D.IDENTITY else to_anchor * part_vertices)
		var rotated := to_anchor.basis != Basis.IDENTITY
		if arrays[Mesh.ARRAY_NORMAL] != null:
			var part_normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			normals.append_array(Transform3D(to_anchor.basis, Vector3.ZERO) * part_normals if rotated else part_normals)
		if arrays[Mesh.ARRAY_TANGENT] != null:
			var part_tangents: PackedFloat32Array = arrays[Mesh.ARRAY_TANGENT]
			if rotated:
				for i in range(0, part_tangents.size(), 4):
					var tangent: Vector3 = to_anchor.basis * Vector3(part_tangents[i], part_tangents[i + 1], part_tangents[i + 2])
					part_tangents[i] = tangent.x
					part_tangents[i + 1] = tangent.y
					part_tangents[i + 2] = tangent.z
			tangents.append_array(part_tangents)
		if arrays[Mesh.ARRAY_TEX_UV] != null:
			uvs.append_array(arrays[Mesh.ARRAY_TEX_UV])
		if arrays[Mesh.ARRAY_TEX_UV2] != null:
			uv2s.append_array(arrays[Mesh.ARRAY_TEX_UV2])
		var fill := PackedColorArray()
		fill.resize(count)
		fill.fill(part.color)
		colors.append_array(fill)
		var at := indices.size()
		if arrays[Mesh.ARRAY_INDEX] == null:
			indices.resize(at + count)
			for i in count:
				indices[at + i] = base + i
		else:
			var part_indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			indices.resize(at + part_indices.size())
			for i in part_indices.size():
				indices[at + i] = base + part_indices[i]
	var result: Array = []
	result.resize(Mesh.ARRAY_MAX)
	result[Mesh.ARRAY_VERTEX] = vertices
	result[Mesh.ARRAY_COLOR] = colors
	result[Mesh.ARRAY_INDEX] = indices
	var channels: int = surface.channels
	if channels & (1 << Mesh.ARRAY_NORMAL):
		result[Mesh.ARRAY_NORMAL] = normals
	if channels & (1 << Mesh.ARRAY_TANGENT):
		result[Mesh.ARRAY_TANGENT] = tangents
	if channels & (1 << Mesh.ARRAY_TEX_UV):
		result[Mesh.ARRAY_TEX_UV] = uvs
	if channels & (1 << Mesh.ARRAY_TEX_UV2):
		result[Mesh.ARRAY_TEX_UV2] = uv2s
	return result
