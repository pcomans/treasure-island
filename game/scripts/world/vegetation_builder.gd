class_name VegetationBuilder
extends RefCounted

const RENDER_WORLD_VISIBLE := 1
const FOLIAGE_MATERIAL_MARKERS := ["leaf", "grass"]
const MIN_VEGETATION_ROUGHNESS := 0.82
const PALM_FOLIAGE_ALBEDO := Color(0.16, 0.38, 0.16, 1.0)
const PALM_WOOD_ALBEDO := Color(0.36, 0.23, 0.12, 1.0)


func build(document: Dictionary) -> Dictionary:
	var root := Node3D.new()
	root.name = "GeneratedVegetation"
	root.set_meta("visual_only", true)
	root.set_meta("seed", int(document.seed))
	var placements_by_asset: Dictionary = {}
	for placement_value: Variant in document.placements:
		var placement: Dictionary = placement_value
		var asset_path := str(placement.asset_path)
		if not placements_by_asset.has(asset_path):
			placements_by_asset[asset_path] = []
		placements_by_asset[asset_path].append(placement)
	var asset_paths: Array = placements_by_asset.keys()
	asset_paths.sort()
	var batch_count := 0
	var rendered_triangles := 0
	for asset_path_value: Variant in asset_paths:
		var asset_path := str(asset_path_value)
		var packed := load(asset_path) as PackedScene
		if packed == null:
			root.free()
			return {"ok": false, "code": "vegetation_asset_load", "message": "Could not load validated vegetation asset %s." % asset_path, "source_keys": []}
		var source := packed.instantiate()
		if source == null:
			root.free()
			return {"ok": false, "code": "vegetation_asset_instance", "message": "Could not inspect validated vegetation asset %s." % asset_path, "source_keys": []}
		var components: Array[Dictionary] = []
		_collect_mesh_components(source, Transform3D.IDENTITY, components)
		if components.is_empty():
			source.free()
			root.free()
			return {"ok": false, "code": "vegetation_asset_mesh", "message": "Validated vegetation asset has no mesh: %s." % asset_path, "source_keys": []}
		var placements: Array = placements_by_asset[asset_path]
		for component_index in components.size():
			var component: Dictionary = components[component_index]
			var mesh := _normalized_visual_mesh(component.mesh as Mesh, asset_path)
			if mesh == null:
				source.free()
				root.free()
				return {"ok": false, "code": "vegetation_asset_material", "message": "Could not prepare non-metallic vegetation materials for %s." % asset_path, "source_keys": []}
			var multi_mesh := MultiMesh.new()
			multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
			multi_mesh.use_colors = false
			multi_mesh.use_custom_data = false
			multi_mesh.mesh = mesh
			multi_mesh.instance_count = placements.size()
			for placement_index in placements.size():
				var placement: Dictionary = placements[placement_index]
				var position: Array = placement.position_m
				var uniform_scale := float(placement.uniform_scale)
				var placement_transform := Transform3D(
					Basis(Vector3.UP, float(placement.yaw_radians)).scaled(Vector3.ONE * uniform_scale),
					Vector3(float(position[0]), float(position[1]), float(position[2]))
				)
				multi_mesh.set_instance_transform(placement_index, placement_transform * (component.transform as Transform3D))
			var instance := MultiMeshInstance3D.new()
			instance.name = "%s_%02d" % [asset_path.get_file().get_basename(), component_index]
			instance.multimesh = multi_mesh
			instance.layers = RENDER_WORLD_VISIBLE
			instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			instance.set_meta("asset_path", asset_path)
			instance.set_meta("placement_count", placements.size())
			instance.set_meta("visual_only", true)
			root.add_child(instance)
			batch_count += 1
			rendered_triangles += int(mesh.get_faces().size() / 3) * placements.size()
		source.free()
	return {
		"ok": true,
		"node": root,
		"seed": int(document.seed),
		"instances": int(document.counts.total),
		"assets": asset_paths.size(),
		"multimesh_batches": batch_count,
		"rendered_triangles": rendered_triangles,
		"species_counts": document.counts.by_species.duplicate(true),
		"zone_counts": document.counts.by_zone.duplicate(true),
	}


func _collect_mesh_components(node: Node, parent_transform: Transform3D, output: Array[Dictionary]) -> void:
	var current_transform := parent_transform
	if node is Node3D:
		current_transform = parent_transform * (node as Node3D).transform
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh != null:
			output.append({"mesh": mesh_instance.mesh, "transform": current_transform})
	for child: Node in node.get_children():
		_collect_mesh_components(child, current_transform, output)


func _normalized_visual_mesh(source_mesh: Mesh, asset_path: String) -> Mesh:
	if source_mesh == null:
		return null
	var mesh := source_mesh.duplicate(true) as Mesh
	if mesh == null:
		return null
	for surface_index in mesh.get_surface_count():
		var source_material := mesh.surface_get_material(surface_index) as StandardMaterial3D
		if source_material == null:
			return null
		var material := source_material.duplicate(true) as StandardMaterial3D
		if material == null:
			return null
		var is_foliage := _is_foliage_material(source_material.resource_name)
		# The curated Kenney GLBs declare even bark and foliage fully metallic.
		# Correct that import-time placeholder while retaining the asset-authored
		# palette, geometry, transforms, and deterministic placement contract.
		material.metallic = 0.0
		material.roughness = maxf(material.roughness, MIN_VEGETATION_ROUGHNESS)
		if is_foliage:
			material.cull_mode = BaseMaterial3D.CULL_DISABLED
		if asset_path.get_file().begins_with("tree_palm"):
			# Keep the source hue roles but pull the enlarged palms out of the
			# conspicuous pastel placeholder range used by their raw GLB colors.
			material.albedo_color = PALM_FOLIAGE_ALBEDO if is_foliage else PALM_WOOD_ALBEDO
		material.set_meta("vegetation_material_normalized", true)
		material.set_meta("vegetation_source_material_name", source_material.resource_name)
		material.set_meta("vegetation_foliage_two_sided", is_foliage)
		mesh.surface_set_material(surface_index, material)
	return mesh


func _is_foliage_material(material_name: String) -> bool:
	var normalized_name := material_name.to_lower()
	for marker: String in FOLIAGE_MATERIAL_MARKERS:
		if normalized_name.contains(marker):
			return true
	return false
