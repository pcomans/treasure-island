extends RefCounted
## Packs the baked world's buildings into far fewer draws without changing what they
## draw. Runs only in the static-world bake (tools/prebuild_static_world.gd); the world
## generated at startup keeps its authored nodes.
##
## A building's surfaces join in two ways, each only with surfaces of the same building
## (the nearest record holding its identity), and each merged mesh carries that identity:
## - By colour: opaque surfaces whose plain materials differ only in base colour become
##   one surface, the colour moving into vertex colours. Surfaces that differ in anything
##   else (roughness, metallic, textures, cull mode...) stay apart, so each keeps the
##   material it had. Their parts move into the record's space.
## - By material: the other surfaces join those with the same material, or a copy of it
##   equal in every stored value (a shader material's shader, its parameters and its
##   metadata alike), keeping that material and their vertex data byte for byte. Only
##   parts under the same transform join, and the merged mesh keeps that transform, so a
##   shader that reads object-space positions or normals, the model matrix or the node's
##   position, triplanar mapping, and scaled, sheared or mirrored parts all see what they
##   saw. Parts the web culls at different distances stay apart, and the merged mesh
##   carries their size for that culling (PrebuiltWorld.DETAIL_SIZE_META, main.gd). A
##   surface no other shares stays where it is.
## Merged meshes keep their sources' triangles, in the order the sources were found, in
## surfaces of at most MAX_SURFACE_VERTICES vertices, so their indices stay 16-bit.
##
## Left exactly as authored:
## - hidden meshes, and anything but a MeshInstance3D;
## - glass and other transparency, blending and screen or depth reads: these sort or
##   blend per object; and shaders that animate (TIME) or read per-instance values;
## - instances on a reflection layer (a probe's mask finds them), or with per-instance
##   rendering settings;
## - meshes another node or a MultiMesh also draws, nodes with children or a script,
##   surface overrides, blend shapes, skinning, compressed vertex formats, and surfaces
##   with LODs (a merged surface would have none);
## - the meshes of a housing family's ground proof (StudyGeometry.retained_ground_meshes:
##   where a family keeps the production ground, its support meshes and that ground):
##   StudyGeometry.retained_ground_contact compares them with their collider face by
##   face, in order. Other families' support and ground meshes join like any part. The
##   merge fails if, after it, any family's proof would compare other meshes.
##
## Before it the bake frees what the housing family installer replaced
## (prune_superseded): the meshes it hid and the bodies it switched off, where nothing
## else hangs on them.

const PREBUILT_WORLD := preload("res://game/scripts/world/prebuilt_world.gd")
const STUDY_GEOMETRY := preload("res://game/tests/support/building_study_geometry.gd")
## The scope housing_family_live_attachment.gd gives an installed family, the only one
## StudyGeometry.retained_ground_contact compares.
const FAMILY_SCOPE := "approved_shared_family_normal_play"
## Metadata that says which building and role a mesh belongs to. A merged mesh carries
## its sources' values; meshes that differ in any of them don't merge.
const IDENTITY_META: Array[StringName] = [&"source_keys", &"source_key", &"derived_object_key", &"family_role", &"physical_role", &"mersea_role", &"visual_only"]
## The identity metadata that tree walks inherit downwards. A merged mesh hangs from the
## nearest ancestor holding any of these, so those walks read the same roles as before.
const INHERITED_META: Array[StringName] = [&"source_keys", &"source_key", &"derived_object_key", &"family_role", &"physical_role"]
## Layers that plain building parts use. Mersea's glass and tagged metal sit on others,
## where a reflection probe's mask finds them.
const PLAIN_LAYERS := 3
## A merged surface's most vertices, so its indices stay 16-bit (Unity's static batching
## stops at 64,000). A single part over it keeps a surface of its own.
const MAX_SURFACE_VERTICES := 65535
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
## A material that joins by material keeps these settings at their defaults: any other
## value sorts, blends or reads its object (BaseMaterial3D).
const SAME_MATERIAL_DEFAULTS := {
	"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED, "blend_mode": BaseMaterial3D.BLEND_MODE_MIX, "next_pass": null,
	"refraction_enabled": false, "billboard_mode": BaseMaterial3D.BILLBOARD_DISABLED, "grow": false, "heightmap_enabled": false,
	"no_depth_test": false, "proximity_fade_enabled": false, "distance_fade_mode": BaseMaterial3D.DISTANCE_FADE_DISABLED,
	"fixed_size": false, "use_point_size": false, "use_particle_trails": false,
}
## Material properties that don't reach the picture, left out of matching by material.
const UNDRAWN_PROPERTIES := ["resource_name", "resource_path", "resource_local_to_scene", "resource_scene_unique_id"]
## What a shader whose surfaces join by material must not use: alpha, blending, the
## screen or depth behind it, and drawing without the depth test or depth writes sort or
## blend per object; TIME animates; the others read per-instance values. An include
## could hide any of them.
const SHADER_REFUSALS: Array[String] = ["ALPHA", "TIME", "INSTANCE_ID", "INSTANCE_CUSTOM", "SCREEN_TEXTURE", "DEPTH_TEXTURE",
	"NORMAL_ROUGHNESS_TEXTURE", "hint_screen_texture", "hint_depth_texture", "hint_normal_roughness_texture", "blend_add",
	"blend_sub", "blend_mul", "blend_premul_alpha", "depth_test_disabled", "depth_draw_never", "depth_prepass_alpha",
	"alpha_to_coverage", "alpha_to_coverage_and_one", "include"]
## How Godot 4.7 stores an uncompressed 3D surface's vertex data (RenderingServer
## mesh_create_surface_data_from_arrays): every vertex's position (3 floats), then every
## vertex's normal and tangent (4 bytes each, octahedral), and a separate interleaved
## attribute buffer (colour, UVs, custom). Surfaces joining by material are joined in
## that form, byte for byte, since decoding and encoding again can move a normal by a
## step; _keeps_format leaves a surface whose data has another size where it is.
const POSITION_BYTES := 12
const NORMAL_TANGENT_BYTES := 4
## Format bits a surface joining by material must not have: bones and weights, and
## data that isn't laid out as above (compressed, 2D, or with no vertex array).
const UNJOINED_FORMAT := Mesh.ARRAY_FORMAT_BONES | Mesh.ARRAY_FORMAT_WEIGHTS | Mesh.ARRAY_FLAG_COMPRESS_ATTRIBUTES | Mesh.ARRAY_FLAG_USE_2D_VERTICES | Mesh.ARRAY_FLAG_USES_EMPTY_VERTEX_ARRAY


## Merges in place under buildings. Returns the counts before and after, for the log,
## and in problems any merged mesh that came out short of its group, or of what was
## taken from its sources: the bake fails on those.
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
	var same_groups := {}
	var signatures := {}
	var material_keys := {}
	var materials := {}
	var counts := {"meshes_before": 0, "surfaces_before": 0, "meshes_kept": 0, "surfaces_kept": 0, "surfaces_with_lods": 0, "taken_by_colour": 0, "taken_by_material": 0}
	# The meshes the housing families' ground proofs compare stay as they are.
	var proofs := _ground_proofs(buildings)
	var proof_meshes := {}
	for meshes: Array in proofs.values():
		for mesh: MeshInstance3D in meshes:
			proof_meshes[mesh] = true
	counts["ground_proof_families"] = proofs.size()
	counts["ground_proof_meshes"] = proof_meshes.size()
	# Each drawn node with the surfaces it gives up by colour: [node, [surface, ...]].
	var visited: Array = []
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
		var may_merge := _may_merge(node, uses, anchor) and not proof_meshes.has(node)
		var rigid := _rigid(to_anchor)
		for surface in surface_count:
			# The surface as the renderer holds it.
			var data := RenderingServer.mesh_get_surface(mesh.get_rid(), surface)
			# A merged surface has no LODs, so one that has them keeps its own mesh.
			if not (data.get("lods", []) as Array).is_empty():
				counts.surfaces_with_lods += 1
				continue
			if not may_merge or int(data.get("primitive", -1)) != Mesh.PRIMITIVE_TRIANGLES:
				continue
			var material := node.get_active_material(surface)
			var signature := _signature(material, signatures) if rigid else ""
			if signature != "":
				var arrays := mesh.surface_get_arrays(surface)
				if _has_only_supported_channels(arrays):
					var group := _group(groups, node, anchor)
					_add_part(group, signature, material as StandardMaterial3D, arrays, to_anchor, materials)
					_count_taken(group, arrays)
					counts.taken_by_colour += 1
					taken.append(surface)
					continue
			var key := _material_key(material, material_keys)
			if key != "" and _keeps_format(data):
				_add_same_part(_same_group(same_groups, node, anchor, to_anchor), key, material, data, node, surface)
		visited.append([node, taken])
	# A surface joins by material only beside another: alone it stays where it is.
	var taken_by_material := {}
	for group: Dictionary in same_groups.values():
		for surface_key: String in group.surfaces.keys():
			var parts: Array = group.surfaces[surface_key].parts
			if parts.size() < 2:
				group.surfaces.erase(surface_key)
				continue
			for part: Dictionary in parts:
				group.taken_indices += _part_elements(part)
				group.taken_vertices += _part_vertices(part)
				if not taken_by_material.has(part.node):
					taken_by_material[part.node] = []
				(taken_by_material[part.node] as Array).append(part.surface)
				counts.taken_by_material += 1
	for entry: Array in visited:
		var node: MeshInstance3D = entry[0]
		var mesh := node.mesh
		var taken: Array[int] = (entry[1] as Array[int]).duplicate()
		for surface: int in taken_by_material.get(node, []):
			taken.append(surface)
		if mesh.get_surface_count() > 0 and taken.size() == mesh.get_surface_count():
			node.get_parent().remove_child(node)
			node.free()
			continue
		# Kept surfaces stay in their own mesh, their buffers untouched.
		taken.sort()
		taken.reverse()
		for surface: int in taken:
			(mesh as ArrayMesh).surface_remove(surface)
		counts.meshes_kept += 1
		counts.surfaces_kept += mesh.get_surface_count()
	var batches := _build_groups(groups, false, 0)
	var same_batches := _build_groups(same_groups, true, int(batches.meshes))
	counts["meshes_after"] = counts.meshes_kept + int(batches.meshes) + int(same_batches.meshes)
	counts["surfaces_after"] = counts.surfaces_kept + int(batches.surfaces) + int(same_batches.surfaces)
	counts["meshes_by_material"] = same_batches.meshes
	counts["surfaces_by_material"] = same_batches.surfaces
	counts["materials_after"] = materials.size()
	counts["most_surface_vertices"] = maxi(int(batches.most_vertices), int(same_batches.most_vertices))
	counts["taken_indices"] = int(batches.taken_indices) + int(same_batches.taken_indices)
	counts["taken_vertices"] = int(batches.taken_vertices) + int(same_batches.taken_vertices)
	var problems: PackedStringArray = batches.problems
	problems.append_array(same_batches.problems)
	# A merged mesh must not bring a family into a ground proof, or change what one compares.
	if _ground_proofs(buildings) != proofs:
		problems.append("the housing families' ground proofs compare other meshes after the merge than before it")
	counts["problems"] = problems
	return counts


## Counts a surface that merge() takes out of its source against its group. Counted
## apart from _add_part: the surface leaves its source either way, so a part that
## _add_part failed to record still counts as taken.
static func _count_taken(group: Dictionary, arrays: Array) -> void:
	group.taken_indices += _index_count(arrays)
	group.taken_vertices += (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()


## Builds each group's batch under its anchor (by_material: groups of _same_group),
## naming them BakedBatch<first_index>, ... Returns how many meshes and surfaces were
## built, the most vertices in one surface, the indices and vertices taken from the
## sources, and in problems every batch that came out short of its group or of what was
## taken for it.
static func _build_groups(groups: Dictionary, by_material := false, first_index := 0) -> Dictionary:
	var meshes := 0
	var surfaces := 0
	var most_vertices := 0
	var taken_indices := 0
	var taken_vertices := 0
	var problems := PackedStringArray()
	for group: Dictionary in groups.values():
		var built: ArrayMesh = null
		var batch := "No batch"
		# A group stays empty when all its candidates' surfaces had to stay.
		if not group.surfaces.is_empty():
			var index := first_index + meshes
			built = _build_same_node(group, index) if by_material else _build_node(group, index)
			batch = "BakedBatch%d" % index
			if built != null:
				meshes += 1
				surfaces += built.get_surface_count()
				for surface in built.get_surface_count():
					most_vertices = maxi(most_vertices, built.surface_get_array_len(surface))
				var problem := _build_problem(built, group)
				if problem != "":
					problems.append("%s under %s: %s" % [batch, (group.anchor as Node3D).get_path(), problem])
		var shortfall := _taken_problem(built, group)
		if shortfall != "":
			problems.append("%s under %s: %s" % [batch, (group.anchor as Node3D).get_path(), shortfall])
		taken_indices += int(group.taken_indices)
		taken_vertices += int(group.taken_vertices)
	return {"meshes": meshes, "surfaces": surfaces, "most_vertices": most_vertices, "taken_indices": taken_indices, "taken_vertices": taken_vertices, "problems": problems}


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


## Whether a part may give up surfaces at all: drawn by this node alone, with nothing
## hanging on it, and drawn with the defaults (whatever its transform).
static func _may_merge(node: MeshInstance3D, uses: Dictionary, anchor: Node3D) -> bool:
	if int(uses[node.mesh]) != 1 or node.get_child_count() != 0 or node.get_script() != null or (node.layers & ~PLAIN_LAYERS) != 0:
		return false
	if not (node.mesh is ArrayMesh or node.mesh.get_surface_count() == 1):
		return false
	if node.mesh is ArrayMesh and ((node.mesh as ArrayMesh).get_blend_shape_count() != 0 or (node.mesh as ArrayMesh).custom_aabb != AABB()):
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
	return true


## Whether a part's transform to its anchor is a plain rotation and offset, so joining by
## colour may move its vertices into the anchor's space: the renderer treats the normals
## of scaled and sheared parts differently, and a mirrored part's winding flips.
static func _rigid(to_anchor: Transform3D) -> bool:
	var basis := to_anchor.basis
	return basis.determinant() > 0.0 and basis.is_equal_approx(basis.orthonormalized())


## Each installed housing family that has a ground proof, with the meshes it compares
## in order (StudyGeometry.retained_ground_meshes, looked up in the whole tree as the
## proof looks them up in the game's).
static func _ground_proofs(buildings: Node3D) -> Dictionary:
	var scene: Node = buildings.get_tree().root if buildings.is_inside_tree() else buildings
	var proofs := {}
	for family: Node3D in buildings.find_children("*", "Node3D", true, false):
		if str(family.get_meta("scope", "")) == FAMILY_SCOPE:
			var meshes := STUDY_GEOMETRY.retained_ground_meshes(scene, family)
			if not meshes.is_empty():
				proofs[family] = meshes
	return proofs


static func _identity(node: MeshInstance3D) -> Dictionary:
	var identity := {}
	for key: StringName in IDENTITY_META:
		if node.has_meta(key):
			identity[key] = node.get_meta(key)
	return identity


## The group of surfaces that will share one merged node with this one.
static func _group(groups: Dictionary, node: MeshInstance3D, anchor: Node3D) -> Dictionary:
	var identity := _identity(node)
	var group_key := "%d|%s|%d|%d" % [anchor.get_instance_id(), identity, node.cast_shadow, node.layers]
	if not groups.has(group_key):
		# taken_*: what merge() took out of the sources for this group, counted apart
		# from the parts it records, for _taken_problem.
		groups[group_key] = {"anchor": anchor, "identity": identity, "cast_shadow": node.cast_shadow, "layers": node.layers, "surfaces": {}, "taken_indices": 0, "taken_vertices": 0}
	return groups[group_key]


## The group of surfaces joining by material that will share one merged node with this
## one: the same anchor, identity, shadow and layers as _group, the same transform, and
## the same distance the web draws parts of its size to.
static func _same_group(groups: Dictionary, node: MeshInstance3D, anchor: Node3D, to_anchor: Transform3D) -> Dictionary:
	var identity := _identity(node)
	var size := (node.global_transform * node.get_aabb()).size
	var longest := maxf(size.x, maxf(size.y, size.z))
	# The transform by its bytes: a text form may round two transforms together.
	var group_key := "%d|%s|%d|%d|%s|%s" % [anchor.get_instance_id(), identity, node.cast_shadow, node.layers, var_to_bytes(to_anchor).hex_encode(), var_to_str(PREBUILT_WORLD.web_detail_range(longest))]
	if not groups.has(group_key):
		groups[group_key] = {"anchor": anchor, "identity": identity, "cast_shadow": node.cast_shadow, "layers": node.layers, "transform": to_anchor, "detail_m": 0.0, "surfaces": {}, "taken_indices": 0, "taken_vertices": 0}
	var group: Dictionary = groups[group_key]
	group.detail_m = maxf(group.detail_m, longest)
	return group


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


## "" for a material whose surfaces may not join by material (_joins_by_material).
## Otherwise a text that two materials share exactly when every value they store is
## the same (resources by identity: the same Shader, the same textures): the material
## itself, or a copy of it.
static func _material_key(material: Material, keys: Dictionary) -> String:
	if keys.has(material):
		return keys[material]
	var key := ""
	if _joins_by_material(material):
		var parts := PackedStringArray([material.get_class()])
		for property: Dictionary in material.get_property_list():
			var name: String = property.name
			if int(property.usage) & PROPERTY_USAGE_STORAGE != 0 and name not in UNDRAWN_PROPERTIES:
				parts.append(name + "=" + _value_text(material.get(name)))
		# Each uniform's value too, read from the material itself whatever the renderer
		# lists among its properties.
		if material is ShaderMaterial:
			for uniform: String in _uniform_names((material as ShaderMaterial).shader):
				parts.append("uniform " + uniform + "=" + _value_text((material as ShaderMaterial).get_shader_parameter(uniform)))
		key = "|".join(parts)
	keys[material] = key
	return key


## A stored value as text for _material_key: a resource by identity, a collection as
## text, anything else by its bytes, so no rounding can make two values one.
static func _value_text(value: Variant) -> String:
	if value is Resource:
		return "resource " + str((value as Resource).get_instance_id())
	if value is Array or value is Dictionary or value is Object:
		return var_to_str(value)
	return var_to_bytes(value).hex_encode()


## Whether a material's surfaces may join by material: a material with no script, opaque
## and drawn the same way wherever its surfaces sit (SAME_MATERIAL_DEFAULTS for a
## BaseMaterial3D; a spatial shader that refuses none of SHADER_REFUSALS, with no next
## pass). Nothing joins a surface with no material.
static func _joins_by_material(material: Material) -> bool:
	if material == null or material.get_script() != null:
		return false
	if material is BaseMaterial3D:
		for key: String in SAME_MATERIAL_DEFAULTS:
			if material.get(key) != SAME_MATERIAL_DEFAULTS[key]:
				return false
		return (material as BaseMaterial3D).depth_draw_mode != BaseMaterial3D.DEPTH_DRAW_DISABLED
	if material is ShaderMaterial:
		var shader := (material as ShaderMaterial).shader
		return shader != null and material.next_pass == null and shader_refusal(shader) == ""
	return false


## What in a shader keeps its surfaces from joining by material, or "" when nothing.
static func shader_refusal(shader: Shader) -> String:
	if shader.get_mode() != Shader.MODE_SPATIAL:
		return "not a spatial shader"
	var code := _without_comments(shader.code)
	for word: String in SHADER_REFUSALS:
		if RegEx.create_from_string("\\b" + word + "\\b").search(code) != null:
			return word
	if RegEx.create_from_string("\\binstance\\s+uniform\\b").search(code) != null:
		return "instance uniform"
	return ""


static func _without_comments(code: String) -> String:
	var no_blocks := RegEx.create_from_string("(?s)/\\*.*?\\*/").sub(code, " ", true)
	return RegEx.create_from_string("//[^\\n]*").sub(no_blocks, " ", true)


## The names of a shader's uniforms (global ones included, which no material holds).
static func _uniform_names(shader: Shader) -> PackedStringArray:
	var names := PackedStringArray()
	var pattern := RegEx.create_from_string("\\buniform\\s+(?:(?:lowp|mediump|highp)\\s+)?[A-Za-z_]\\w*\\s+([A-Za-z_]\\w*)")
	for found: RegExMatch in pattern.search_all(_without_comments(shader.code)):
		names.append(found.get_string(1))
	return names


## Whether a surface (as RenderingServer.mesh_get_surface gives it) can join by material
## byte for byte: none of UNJOINED_FORMAT, no skin or blend shapes, and vertex and
## attribute data of the sizes the layout above gives its vertices.
static func _keeps_format(data: Dictionary) -> bool:
	var format := int(data.get("format", 0))
	var count := int(data.get("vertex_count", 0))
	if format & UNJOINED_FORMAT != 0 or count <= 0 or not (data.get("skin_data", PackedByteArray()) as PackedByteArray).is_empty() or not (data.get("blend_shape_data", PackedByteArray()) as PackedByteArray).is_empty():
		return false
	var normal_bytes := NORMAL_TANGENT_BYTES * (int(format & Mesh.ARRAY_FORMAT_NORMAL != 0) + int(format & Mesh.ARRAY_FORMAT_TANGENT != 0))
	var attributes := (data.get("attribute_data", PackedByteArray()) as PackedByteArray).size()
	return (data.vertex_data as PackedByteArray).size() == count * (POSITION_BYTES + normal_bytes) and attributes % count == 0


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


## Records a surface that may join by material (merge() takes it once another shares its
## surface): its data, and where it came from. A merged surface has the first such
## surface's material and the format their data share (indexed or not, as a merged
## surface may index them).
static func _add_same_part(group: Dictionary, key: String, material: Material, data: Dictionary, node: MeshInstance3D, surface: int) -> void:
	var shared := int(data.format) & ~Mesh.ARRAY_FORMAT_INDEX
	var surface_key := "%d|%s" % [shared, key]
	if not group.surfaces.has(surface_key):
		group.surfaces[surface_key] = {"material": material, "format": shared, "parts": []}
	group.surfaces[surface_key].parts.append({"data": data, "node": node, "surface": surface})


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


## A surface's parts in runs of at most MAX_SURFACE_VERTICES vertices, in order: one
## merged surface each. A part over that limit runs alone.
static func _chunks(parts: Array) -> Array:
	var chunks: Array = []
	var current: Array = []
	var vertices := 0
	for part: Dictionary in parts:
		var count := _part_vertices(part)
		if not current.is_empty() and vertices + count > MAX_SURFACE_VERTICES:
			chunks.append(current)
			current = []
			vertices = 0
		current.append(part)
		vertices += count
	if not current.is_empty():
		chunks.append(current)
	return chunks


static func _build_node(group: Dictionary, index: int) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	for surface: Dictionary in group.surfaces.values():
		for chunk: Array in _chunks(surface.parts):
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _surface_arrays({"parts": chunk, "channels": surface.channels}))
			mesh.surface_set_material(mesh.get_surface_count() - 1, surface.material)
	var node := _batch_node(group, mesh, index)
	(group.anchor as Node3D).add_child(node)
	return mesh


## A batch of surfaces joining by material: under its anchor at the transform its parts
## had, their data as it was, with the size of its parts for the web's culling.
static func _build_same_node(group: Dictionary, index: int) -> ArrayMesh:
	var joined: Array[Dictionary] = []
	var materials: Array[Material] = []
	for surface: Dictionary in group.surfaces.values():
		for chunk: Array in _chunks(surface.parts):
			joined.append(_joined_data(chunk, surface.format))
			materials.append(surface.material)
	var mesh := ArrayMesh.new()
	# The surfaces as ArrayMesh saves and loads them, so their bytes go in unchanged.
	mesh.set("_surfaces", joined)
	for surface in mesh.get_surface_count():
		mesh.surface_set_material(surface, materials[surface])
	var node := _batch_node(group, mesh, index)
	node.transform = group.transform
	node.set_meta(PREBUILT_WORLD.DETAIL_SIZE_META, group.detail_m)
	(group.anchor as Node3D).add_child(node)
	return mesh


static func _batch_node(group: Dictionary, mesh: ArrayMesh, index: int) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = "BakedBatch%d" % index
	node.mesh = mesh
	node.cast_shadow = group.cast_shadow
	node.layers = group.layers
	for key: StringName in group.identity:
		node.set_meta(key, group.identity[key])
	# main.gd leaves these whole: their distance culling would drop an entire building
	# (unless they carry their parts' size, PrebuiltWorld.DETAIL_SIZE_META).
	node.set_meta("baked_merge", true)
	return node


## Why a built mesh doesn't hold all of its group, or "" when it does. A surface that won't
## build only logs an engine error, and its source meshes are gone by then.
static func _build_problem(mesh: ArrayMesh, group: Dictionary) -> String:
	var wanted: Array[int] = []
	for surface: Dictionary in group.surfaces.values():
		for chunk: Array in _chunks(surface.parts):
			var elements := 0
			for part: Dictionary in chunk:
				elements += _part_elements(part)
			wanted.append(elements)
	if mesh.get_surface_count() != wanted.size():
		return "%d of %d surfaces built" % [mesh.get_surface_count(), wanted.size()]
	for surface in wanted.size():
		if _element_count(mesh, surface) != wanted[surface]:
			return "surface %d has %d of %d indices" % [surface, _element_count(mesh, surface), wanted[surface]]
	return ""


## Why a group's built mesh (null if none was built) doesn't hold everything merge() took
## out of its sources, or "" when it does. Unlike _build_problem, this doesn't trust the
## parts the group recorded: a part that _add_part dropped is missing from those too.
static func _taken_problem(mesh: ArrayMesh, group: Dictionary) -> String:
	var indices := 0
	var vertices := 0
	if mesh != null:
		for surface in mesh.get_surface_count():
			indices += _element_count(mesh, surface)
			vertices += mesh.surface_get_array_len(surface)
	if indices != int(group.taken_indices) or vertices != int(group.taken_vertices):
		return "holds %d of the %d indices and %d of the %d vertices taken from its sources" % [indices, group.taken_indices, vertices, group.taken_vertices]
	return ""


## The indices a source surface brings into a merged surface: its own, or one per
## vertex if it had none.
static func _index_count(arrays: Array) -> int:
	if arrays[Mesh.ARRAY_INDEX] != null:
		return (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size()
	return (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()


## A built surface's indices, or its vertices if it has none (as _index_count counts).
static func _element_count(mesh: ArrayMesh, surface: int) -> int:
	var indices := mesh.surface_get_array_index_len(surface)
	return indices if indices > 0 else mesh.surface_get_array_len(surface)


## A recorded part's vertices: from its arrays (joining by colour) or its data.
static func _part_vertices(part: Dictionary) -> int:
	if part.has("data"):
		return int(part.data.vertex_count)
	return (part.arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()


## A recorded part's indices as _index_count counts them.
static func _part_elements(part: Dictionary) -> int:
	if part.has("data"):
		var indices := int(part.data.get("index_count", 0))
		return indices if indices > 0 else int(part.data.vertex_count)
	return _index_count(part.arrays)


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
		_append_indices(indices, arrays, base, count)
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


## The parts' data (which share format) joined into one surface as ArrayMesh's _surfaces
## holds it: positions, then normals and tangents, then attributes, each part's bytes as
## they were; the surface is indexed when any part is (one index per vertex for a part
## without), its indices 16-bit when its vertices allow, as the engine stores them.
static func _joined_data(parts: Array, format: int) -> Dictionary:
	var positions := PackedByteArray()
	var normals := PackedByteArray()
	var attributes := PackedByteArray()
	var box := AABB()
	var vertices := 0
	var indexed := false
	for part: Dictionary in parts:
		var data: Dictionary = part.data
		var count := int(data.vertex_count)
		var vertex_data: PackedByteArray = data.vertex_data
		positions.append_array(vertex_data.slice(0, count * POSITION_BYTES))
		normals.append_array(vertex_data.slice(count * POSITION_BYTES))
		attributes.append_array(data.get("attribute_data", PackedByteArray()))
		box = data.aabb if vertices == 0 else box.merge(data.aabb)
		vertices += count
		indexed = indexed or int(data.get("index_count", 0)) > 0
	positions.append_array(normals)
	var joined := {"format": format, "primitive": Mesh.PRIMITIVE_TRIANGLES, "vertex_data": positions, "vertex_count": vertices, "aabb": box}
	if not attributes.is_empty():
		joined["attribute_data"] = attributes
	if indexed:
		var indices := PackedInt32Array()
		var base := 0
		for part: Dictionary in parts:
			var data: Dictionary = part.data
			var count := int(data.vertex_count)
			var index_count := int(data.get("index_count", 0))
			var at := indices.size()
			if index_count == 0:
				indices.resize(at + count)
				for i in count:
					indices[at + i] = base + i
			else:
				var index_data: PackedByteArray = data.index_data
				var wide := index_data.size() == index_count * 4
				indices.resize(at + index_count)
				for i in index_count:
					indices[at + i] = base + (index_data.decode_u32(i * 4) if wide else index_data.decode_u16(i * 2))
			base += count
		var short := vertices <= 65536
		var index_bytes := PackedByteArray()
		index_bytes.resize(indices.size() * (2 if short else 4))
		for i in indices.size():
			if short:
				index_bytes.encode_u16(i * 2, indices[i])
			else:
				index_bytes.encode_u32(i * 4, indices[i])
		joined["format"] = format | Mesh.ARRAY_FORMAT_INDEX
		joined["index_data"] = index_bytes
		joined["index_count"] = indices.size()
	return joined


## Appends a part's indices (one per vertex if it has none), offset to where its
## vertices start.
static func _append_indices(indices: PackedInt32Array, arrays: Array, base: int, count: int) -> void:
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


## Frees the superseded housing nodes the bake collected through the installer's
## BAKE_SUPERSEDED_META (housing_family_live_attachment.gd: the meshes it hid and the
## bodies it switched off) where they are inert (_can_prune). superseded_bodies is how
## many bodies the installer's own report says it switched off (disabled_legacy_bodies),
## counted whether or not the bake asked for candidates. Each of those should be a plain
## body the prune can remove, so returns the counts for the log, and a problem when
## fewer bodies went: candidates went missing, or some could not go. The bake fails on
## that rather than carry superseded geometry quietly.
static func prune_superseded(candidates: Array[Node], superseded_bodies: int) -> Dictionary:
	var meshes := 0
	var bodies := 0
	for node in candidates:
		if is_instance_valid(node) and _can_prune(node):
			if node is MeshInstance3D:
				meshes += 1
			else:
				bodies += 1
			node.free()
	var problem := ""
	if bodies < superseded_bodies:
		problem = "the housing family installer switched off %d bodies, but the prune removed only %d of them, so the rest would stay in the bake (%d candidates reached it, %d hidden meshes removed)" % [superseded_bodies, bodies, candidates.size(), meshes]
	return {"candidates": candidates.size(), "removed_meshes": meshes, "removed_bodies": bodies, "superseded_bodies": superseded_bodies, "problem": problem}


## Only inert visual leaves, and switched-off bodies whose children are plain shapes.
static func _can_prune(node: Node) -> bool:
	if node.get_script() != null or node.unique_name_in_owner or not node.get_groups().is_empty():
		return false
	if node is MeshInstance3D:
		return not node.visible and node.get_child_count(true) == 0
	if not node is StaticBody3D or node.collision_layer != 0 or node.collision_mask != 0:
		return false
	for child: Node in node.get_children(true):
		if (not child is CollisionShape3D or child.get_child_count(true) != 0
			or child.get_script() != null or child.unique_name_in_owner or not child.get_groups().is_empty()):
			return false
	return true
