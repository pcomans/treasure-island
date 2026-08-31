extends SceneTree

const TEXTURE_ROOT := "res://game/resources/textures/world/polyhaven"
const EXPECTED_MATERIALS := {
	"road_path": {"feature_kind": "road_path", "context": false, "asset": "clean_asphalt", "source_dimension_m": 2.1, "repeat_dimension_m": 2.1, "normal_strength": 0.2},
	"road_path_pedestrian": {"feature_kind": "road_path", "context": false, "asset": "concrete_pavement", "source_dimension_m": 1.8, "repeat_dimension_m": 1.8, "normal_strength": 0.2},
	"major_area_paved": {"feature_kind": "major_area", "context": false, "asset": "concrete_floor_03", "source_dimension_m": 2.5, "repeat_dimension_m": 2.5, "normal_strength": 0.2},
	"land_ground": {"feature_kind": "land_ground", "context": false, "asset": "sparse_grass", "source_dimension_m": 2.0, "repeat_dimension_m": 5.0, "normal_strength": 0.2},
	"major_area_landuse": {"feature_kind": "major_area", "context": false, "asset": "sparse_grass", "source_dimension_m": 2.0, "repeat_dimension_m": 5.0, "normal_strength": 0.2},
	"major_area_leisure": {"feature_kind": "major_area", "context": false, "asset": "sparse_grass", "source_dimension_m": 2.0, "repeat_dimension_m": 5.0, "normal_strength": 0.2},
	"context_ybi": {"feature_kind": "ybi", "context": true, "asset": "sparse_grass", "source_dimension_m": 2.0, "repeat_dimension_m": 5.0, "normal_strength": 0.2},
	"building_wall": {"feature_kind": "building_wall", "context": false, "asset": "plaster_grey_04", "source_dimension_m": 1.5, "repeat_dimension_m": 0.75, "normal_strength": 0.1},
	"building_part_wall": {"feature_kind": "building_part_wall", "context": false, "asset": "plaster_grey_04", "source_dimension_m": 1.5, "repeat_dimension_m": 0.75, "normal_strength": 0.1},
	"building_roof": {"feature_kind": "building_roof", "context": false, "asset": "bitumen", "source_dimension_m": 20.0, "repeat_dimension_m": 10.0, "normal_strength": 0.2},
	"building_part_roof": {"feature_kind": "building_part_roof", "context": false, "asset": "bitumen", "source_dimension_m": 20.0, "repeat_dimension_m": 10.0, "normal_strength": 0.2},
}


func _initialize() -> void:
	var builder := WorldChunkBuilder.new()
	for material_key: String in EXPECTED_MATERIALS:
		var expected: Dictionary = EXPECTED_MATERIALS[material_key]
		var material := builder._material_for(material_key, str(expected.feature_kind), bool(expected.context))
		if not _material_matches(material_key, material, expected):
			quit(1)
			return
	if not _runtime_tangents_are_present(builder):
		quit(1)
		return
	print("PASS: %d Poly Haven semantic materials retain official source dimensions and exact maps while using approved effective repeats, mipmapped filtering, and pinned subtle normals" % EXPECTED_MATERIALS.size())
	quit(0)


func _material_matches(material_key: String, material: StandardMaterial3D, expected: Dictionary) -> bool:
	if not _require(material != null, "%s material is null." % material_key) \
	or not _require(material.resource_name == material_key, "%s did not retain its semantic material key." % material_key) \
	or not _require(material.albedo_texture != null and material.normal_texture != null and material.roughness_texture != null, "%s is missing a diffuse, normal, or roughness texture." % material_key):
		return false
	var asset := str(expected.asset)
	var expected_prefix := "%s/%s/%s" % [TEXTURE_ROOT, asset, asset]
	if not _require(material.albedo_texture.resource_path == "%s_diff_1k.jpg" % expected_prefix, "%s diffuse path drifted: %s" % [material_key, material.albedo_texture.resource_path]) \
	or not _require(material.normal_texture.resource_path == "%s_nor_gl_1k.jpg" % expected_prefix, "%s OpenGL normal path drifted: %s" % [material_key, material.normal_texture.resource_path]) \
	or not _require(material.roughness_texture.resource_path == "%s_rough_1k.jpg" % expected_prefix, "%s roughness path drifted: %s" % [material_key, material.roughness_texture.resource_path]) \
	or not _require(material.normal_enabled and is_equal_approx(material.normal_scale, float(expected.normal_strength)), "%s normal strength %.3f does not match %.2f." % [material_key, material.normal_scale, float(expected.normal_strength)]) \
	or not _require(not material.heightmap_enabled, "%s unexpectedly enables displacement." % material_key):
		return false
	var source_set: Dictionary = WorldChunkBuilder.POLYHAVEN_TEXTURE_SETS[asset]
	if not _require(is_equal_approx(float(source_set.source_dimension_m), float(expected.source_dimension_m)), "%s official source dimension drifted from %.2f m." % [asset, float(expected.source_dimension_m)]) \
	or not _require(is_equal_approx(float(source_set.repeat_dimension_m), float(expected.repeat_dimension_m)), "%s effective visual repeat drifted from %.2f m." % [asset, float(expected.repeat_dimension_m)]):
		return false
	var expected_uv_scale := 10.0 / float(expected.repeat_dimension_m)
	if not _require(is_equal_approx(material.uv1_scale.x, expected_uv_scale) and is_equal_approx(material.uv1_scale.y, expected_uv_scale) and is_equal_approx(material.uv1_scale.z, 1.0), "%s UV scale %s is not 10 / %.2f m effective repeat." % [material_key, material.uv1_scale, float(expected.repeat_dimension_m)]) \
	or not _require(material.get_flag(BaseMaterial3D.FLAG_USE_TEXTURE_REPEAT), "%s does not repeat its tileable textures." % material_key) \
	or not _require(material.texture_filter == BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC, "%s does not use mipmapped anisotropic filtering." % material_key):
		return false
	for texture: Texture2D in [material.albedo_texture, material.normal_texture, material.roughness_texture]:
		var image := texture.get_image()
		if not _require(image != null and image.has_mipmaps(), "%s texture lacks imported mipmaps: %s" % [material_key, texture.resource_path]):
			return false
	return true


func _runtime_tangents_are_present(builder: WorldChunkBuilder) -> bool:
	var record := {
		"object_key": "material-contract-triangle",
		"source_keys": ["material-contract"],
		"feature_kind": "road_path",
		"material_key": "road_path",
		"receiver_kind": "ground",
		"collision_kind": "none",
		"opaque": false,
		"vertices": [0.0, 0.0, 0.0, 10.0, 0.0, 0.0, 0.0, 0.0, 10.0],
		"normals": [0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0],
		"uvs": [0.0, 0.0, 1.0, 0.0, 0.0, 1.0],
		"indices": [0, 2, 1],
	}
	var result := builder._build_record(record, false)
	if not _require(bool(result.get("ok", false)), "Textured runtime triangle could not be built."):
		return false
	var record_node := result.node as Node3D
	var mesh_instance := record_node.get_node("Mesh") as MeshInstance3D
	var arrays := (mesh_instance.mesh as ArrayMesh).surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var tangents := arrays[Mesh.ARRAY_TANGENT] as PackedFloat32Array
	var valid := _require(tangents.size() == vertices.size() * 4, "Textured runtime mesh lacks one tangent quaternion per vertex.")
	if valid:
		for offset in range(0, tangents.size(), 4):
			var tangent := Vector3(tangents[offset], tangents[offset + 1], tangents[offset + 2])
			var handedness := tangents[offset + 3]
			if not _require(tangent.is_finite() and tangent.length_squared() > 0.99 and tangent.length_squared() < 1.01 and is_equal_approx(absf(handedness), 1.0), "Textured runtime mesh contains a zero, non-finite, or invalid-handedness tangent."):
				valid = false
				break
	record_node.free()
	return valid


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("FAIL [world_material_contract]: %s" % message)
	return false
