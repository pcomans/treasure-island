extends SceneTree

const TEXTURE_ROOT := "res://game/resources/textures/world/polyhaven"
const GROUND_COVER := preload("res://game/scripts/world/ground_cover.gd")
const GROUND_COVER_SHADER_PATH := "res://game/resources/materials/world/ground_cover/ground_cover.gdshader"
const GROUND_COVER_MAP_PATH := "res://game/resources/textures/world/ground_cover/cover_map.png"
const GROUND_COVER_CONFIG_PATH := "res://tools/config/ground-cover.json"
const COVERAGE_LEDGER_PATH := "res://generated/world/coverage-ledger.csv"
const SHORELINE_SHADER_PATH := "res://game/resources/materials/world/shoreline/riprap.gdshader"
const SHORELINE_ALBEDO_PATHS := {
	"riprap_albedo": "res://game/resources/textures/world/shoreline/riprap_albedo.png",
	"boulder_albedo": "res://game/resources/textures/world/shoreline/boulder_albedo.png",
}
const EXPECTED_MATERIALS := {
	"road_path": {"feature_kind": "road_path", "context": false, "asset": "clean_asphalt", "source_dimension_m": 2.1, "repeat_dimension_m": 2.1, "normal_strength": 0.2},
	"road_path_pedestrian": {"feature_kind": "road_path", "context": false, "asset": "concrete_pavement", "source_dimension_m": 1.8, "repeat_dimension_m": 1.8, "normal_strength": 0.2},
	"major_area_paved": {"feature_kind": "major_area", "context": false, "asset": "clean_asphalt", "source_dimension_m": 2.1, "repeat_dimension_m": 2.1, "normal_strength": 0.2},
	"major_area_court": {"feature_kind": "major_area", "context": false, "asset": "concrete_floor_03", "source_dimension_m": 2.5, "repeat_dimension_m": 2.5, "normal_strength": 0.2},
	# Yerba Buena Island's L1 buildings, surfaces and walls wear Treasure Island's own maps
	# (its terrain draws its own ground shader: ybi_ground.gd).
	"context_ybi_building_wall": {"feature_kind": "ybi_building", "context": true, "asset": "plaster_grey_04", "source_dimension_m": 1.5, "repeat_dimension_m": 0.75, "normal_strength": 0.1},
	"context_ybi_road": {"feature_kind": "ybi_surface", "context": true, "asset": "clean_asphalt", "source_dimension_m": 2.1, "repeat_dimension_m": 2.1, "normal_strength": 0.2},
	"context_ybi_paved": {"feature_kind": "ybi_surface", "context": true, "asset": "clean_asphalt", "source_dimension_m": 2.1, "repeat_dimension_m": 2.1, "normal_strength": 0.2},
	"context_ybi_path": {"feature_kind": "ybi_surface", "context": true, "asset": "concrete_pavement", "source_dimension_m": 1.8, "repeat_dimension_m": 1.8, "normal_strength": 0.2},
	"context_ybi_construction": {"feature_kind": "ybi_surface", "context": true, "asset": "concrete_floor_03", "source_dimension_m": 2.5, "repeat_dimension_m": 2.5, "normal_strength": 0.2},
	"context_ybi_wall": {"feature_kind": "ybi_building", "context": true, "asset": "concrete_floor_03", "source_dimension_m": 2.5, "repeat_dimension_m": 2.5, "normal_strength": 0.2},
	"context_ybi_bank": {"feature_kind": "ybi_surface", "context": true, "asset": "concrete_floor_03", "source_dimension_m": 2.5, "repeat_dimension_m": 2.5, "normal_strength": 0.2},
	"building_wall": {"feature_kind": "building_wall", "context": false, "asset": "plaster_grey_04", "source_dimension_m": 1.5, "repeat_dimension_m": 0.75, "normal_strength": 0.1},
	"building_part_wall": {"feature_kind": "building_part_wall", "context": false, "asset": "plaster_grey_04", "source_dimension_m": 1.5, "repeat_dimension_m": 0.75, "normal_strength": 0.1},
	"building_roof": {"feature_kind": "building_roof", "context": false, "asset": "bitumen", "source_dimension_m": 20.0, "repeat_dimension_m": 10.0, "normal_strength": 0.2},
	"building_part_roof": {"feature_kind": "building_part_roof", "context": false, "asset": "bitumen", "source_dimension_m": 20.0, "repeat_dimension_m": 10.0, "normal_strength": 0.2},
}
## One generated record per ground route: feature kind, material key, source
## key and the family it must use ("" keeps the builder's own material).
const GROUND_ROUTES := [
	["land_ground", "land_ground", "w26767313", "field"],
	["major_area", "major_area_landuse", "r17241151", "field"],
	["major_area", "major_area_landuse", "w1252737732", "bare"],
	["major_area", "major_area_landuse", "w1252737754", "turf"],
	["major_area", "major_area_landuse", "w1098437861", "straw"],
	["major_area", "major_area_leisure", "w1428380753", "lawn"],
	["major_area", "major_area_leisure", "w1428380754", "park_lawn"],
	["major_area", "major_area_leisure", "w99060807", "watered_pitch"],
	["major_area", "major_area_leisure", "w96665888", "paved"],
	["major_area", "major_area_amenity", "w1252737750", "straw"],
	["major_area", "major_area_amenity", "w1043836449", "field"],
	["major_area", "major_area_paved", "w95934095", ""],
	["terrain_overlay", "terrain_sand", "w109042224", "sand_pad"],
	["terrain_overlay", "terrain_wetland", "w1473022589", "red_marsh"],
	["terrain_overlay", "terrain_breakwater", "w1222684027", ""],
]


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
	if not _ground_families_match() or not _ground_cover_map_matches() or not _ground_routes_match(builder) or not _ground_overrides_name_generated_areas():
		quit(1)
		return
	if not _shoreline_material_matches(builder):
		quit(1)
		return
	if not _ybi_ground_matches():
		quit(1)
		return
	print("PASS: %d Poly Haven semantic materials retain official source dimensions and exact maps while using approved effective repeats, mipmapped filtering, and pinned subtle normals; land and area records use the shared ground-cover families, which read the ground-cover map over its configured rectangle; the shoreline slope and stones share one riprap shader with mipmapped textures, and its band and shoulder share the verge's ground cover" % EXPECTED_MATERIALS.size())
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


## YBI's terrain draws its ground-cover map with Treasure Island's straw, lawn and soil
## palettes (one season for both islands), and a malformed map builds nothing.
func _ybi_ground_matches() -> bool:
	const YBI_GROUND := preload("res://game/scripts/world/ybi_ground.gd")
	var pixels := PackedByteArray()
	for value: int in [255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 255]:
		pixels.append(value)
	var cover := {
		"schema_version": YBI_GROUND.SCHEMA,
		"origin_xz": [-180.0, 920.0],
		"cell_m": 2.0,
		"width": 2,
		"height": 2,
		"channels": YBI_GROUND.CHANNELS,
		"rgba_zlib_base64": Marshalls.raw_to_base64(pixels.compress(FileAccess.COMPRESSION_DEFLATE)),
	}
	var material: ShaderMaterial = YBI_GROUND.material(cover)
	if not _require(material != null and material.shader == YBI_GROUND.SHADER, "YBI ground material did not build from a well-formed map."):
		return false
	var texture := material.get_shader_parameter("cover_map") as Texture2D
	if not _require(texture != null and texture.get_image().has_mipmaps() and texture.get_width() == 2, "YBI ground-cover map is not a mipmapped texture of its grid."):
		return false
	var rect: Vector4 = material.get_shader_parameter("cover_map_rect")
	if not _require(rect.is_equal_approx(Vector4(-180.0, 920.0, 0.25, 0.25)), "YBI ground-cover rectangle %s is not its grid's." % rect):
		return false
	var palette: Dictionary = YBI_GROUND.island_palette()
	if not _require(palette.size() == YBI_GROUND.SHARED_PALETTE.size(), "Treasure Island's ground-cover shader no longer declares every shared palette colour."):
		return false
	for uniform: String in YBI_GROUND.SHARED_PALETTE:
		var island: Color = palette[uniform]
		if not _require(material.get_shader_parameter(uniform) == island and GROUND_COVER.SHADER.code.contains("uniform vec3 %s : source_color = vec3(%s, %s, %s);" % [uniform, _decimal(island.r), _decimal(island.g), _decimal(island.b)]), "YBI ground %s does not follow Treasure Island's." % uniform):
			return false
	cover.channels = ["dark_vegetation", "green"]
	return _require(YBI_GROUND.material(cover) == null, "A malformed YBI ground-cover map still built a material.")


## A shader literal's three decimals (the palette declarations write 0.233, not 0.2330).
func _decimal(value: float) -> String:
	return String.num(value, 3).pad_decimals(3)


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


## Every family is the shared ground-cover shader on the exact sparse_grass
## maps, and every family setting names a float uniform the shader declares, so
## a renamed or misspelt setting cannot silently stop applying.
func _ground_families_match() -> bool:
	var detail := "%s/sparse_grass/sparse_grass" % TEXTURE_ROOT
	var maps := {"detail_albedo": "_diff_1k.jpg", "detail_normal": "_nor_gl_1k.jpg", "detail_roughness": "_rough_1k.jpg"}
	var float_uniforms := {}
	for found: RegExMatch in RegEx.create_from_string("uniform\\s+float\\s+(\\w+)").search_all((GROUND_COVER.SHADER as Shader).code):
		float_uniforms[found.get_string(1)] = true
	for family: String in GROUND_COVER.FAMILIES:
		var material := GROUND_COVER.material(family)
		if not _require(material is ShaderMaterial and material.shader != null and material.shader.resource_path == GROUND_COVER_SHADER_PATH, "%s ground cover is not the shared shader." % family) \
		or not _require(material.resource_name == "ground_cover_" + family, "%s ground cover lost its family name." % family) \
		or not _require(GROUND_COVER.material(family) == material, "%s ground cover is not one shared material." % family):
			return false
		for parameter: String in maps:
			var texture := material.get_shader_parameter(parameter) as Texture2D
			if not _require(texture != null and texture.resource_path == detail + str(maps[parameter]), "%s %s is not the sparse_grass map." % [family, parameter]):
				return false
			var image := texture.get_image()
			if not _require(image != null and image.has_mipmaps(), "%s %s lacks imported mipmaps." % [family, parameter]):
				return false
		for parameter: String in GROUND_COVER.FAMILIES[family]:
			if not _require(float_uniforms.has(parameter), "%s setting %s is not a float uniform of the ground-cover shader." % [family, parameter]):
				return false
	return true


## Every family reads the committed ground-cover map (lossless, mipmapped)
## over the rectangle tools/config/ground-cover.json draws it for, at one texel
## per map cell, and draws each map channel with its recipe family's mix.
func _ground_cover_map_matches() -> bool:
	var config: Variant = JSON.parse_string(FileAccess.get_file_as_string(GROUND_COVER_CONFIG_PATH))
	if not _require(config is Dictionary and config.get("map") is Dictionary, "Cannot read the ground-cover map rectangle from %s." % GROUND_COVER_CONFIG_PATH):
		return false
	var map: Dictionary = config.map
	var origin := Vector2(float(map.origin_xz[0]), float(map.origin_xz[1]))
	var size := Vector2(float(map.size_m[0]), float(map.size_m[1]))
	if not _require(origin == GROUND_COVER.COVER_MAP_ORIGIN and size == GROUND_COVER.COVER_MAP_SIZE_M, "ground_cover.gd's map rectangle differs from %s." % GROUND_COVER_CONFIG_PATH):
		return false
	var texture := GROUND_COVER.COVER_MAP as Texture2D
	var image := texture.get_image() if texture != null else null
	if not _require(texture != null and texture.resource_path == GROUND_COVER_MAP_PATH and image != null and image.has_mipmaps(), "The ground-cover map is missing or lacks mipmaps.") \
	or not _require(Vector2(image.get_width(), image.get_height()) * float(map.cell_m) == size, "The ground-cover map is not one texel per %s m cell of its rectangle." % map.cell_m):
		return false
	var rect := Vector4(origin.x, origin.y, 1.0 / size.x, 1.0 / size.y)
	for family: String in GROUND_COVER.FAMILIES:
		var material := GROUND_COVER.material(family)
		if not _require(material.get_shader_parameter("cover_map") == texture and material.get_shader_parameter("cover_map_rect") == rect, "%s ground cover does not read the ground-cover map." % family) \
		or not _require(material.get_shader_parameter("marsh_map") == GROUND_COVER.MARSH_MAP, "%s ground cover does not read the marsh map." % family) \
		or not _require(material.get_shader_parameter("marsh_grain") == GROUND_COVER.MARSH_GRAIN, "%s ground cover does not read the marsh's grain." % family):
			return false
		for uniform: String in GROUND_COVER.COVER_MAP_RECIPES:
			var recipe: Dictionary = GROUND_COVER.FAMILIES[GROUND_COVER.COVER_MAP_RECIPES[uniform]]
			if not _require(material.get_shader_parameter(uniform) == Vector3(recipe.dry_threshold, recipe.bare_threshold, recipe.green_dryness), "%s ground cover's %s is not its recipe family's mix." % [family, uniform]):
				return false
	return true


## Built records get their family's material and tangents for its normal map;
## parking and terrain overlays keep their own materials, the flat breakwater's
## being the riprap's bare rock.
func _ground_routes_match(builder: WorldChunkBuilder) -> bool:
	for route: Array in GROUND_ROUTES:
		var record := {
			"object_key": "material-contract-%s" % route[2],
			"source_keys": [route[2]],
			"feature_kind": route[0],
			"material_key": route[1],
			"receiver_kind": "none",
			"collision_kind": "world_solid" if route[0] == "land_ground" else "none",
			"opaque": route[0] == "land_ground",
			"vertices": [0.0, 0.0, 0.0, 10.0, 0.0, 0.0, 0.0, 0.0, 10.0],
			"normals": [0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0],
			"uvs": [0.0, 0.0, 1.0, 0.0, 0.0, 1.0],
			"indices": [0, 2, 1],
		}
		var family := str(route[3])
		if not _require(GROUND_COVER.family_for(record, false) == family, "%s %s routes to %s, not %s." % [route[1], route[2], GROUND_COVER.family_for(record, false), family]):
			return false
		var result := builder._build_record(record, false)
		if not _require(bool(result.get("ok", false)), "%s %s could not be built." % [route[1], route[2]]):
			return false
		var record_node := result.node as Node3D
		var mesh := (record_node.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
		var material := mesh.surface_get_material(0)
		var expected: Material
		if family == GROUND_COVER.PAVED:
			expected = builder._material_for("major_area_court", "major_area", false)
		elif family != "":
			expected = GROUND_COVER.material(family)
		elif str(route[1]) == WorldChunkBuilder.SHORELINE_ROCK_OVERLAY:
			expected = ShorelineBuilder.rock_ground_material()
		else:
			expected = builder._material_for(str(route[1]), str(route[0]), false)
		var arrays := mesh.surface_get_arrays(0)
		var has_tangents := arrays[Mesh.ARRAY_TANGENT] is PackedFloat32Array and (arrays[Mesh.ARRAY_TANGENT] as PackedFloat32Array).size() == 12
		record_node.free()
		if not _require(material == expected, "%s %s did not get its %s material." % [route[1], route[2], family if family != "" else "own"]) \
		or not _require(family == "" or has_tangents, "%s %s lacks tangents for its normal map." % [route[1], route[2]]):
			return false
	return true


## Each frozen OSM override names a generated major area and a real family.
func _ground_overrides_name_generated_areas() -> bool:
	var file := FileAccess.open(COVERAGE_LEDGER_PATH, FileAccess.READ)
	if not _require(file != null, "Cannot read %s." % COVERAGE_LEDGER_PATH):
		return false
	var header := file.get_csv_line()
	var source_column := header.find("source_key")
	var category_column := header.find("categories")
	var areas := {}
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() == header.size() and "major_area" in row[category_column].split("|"):
			areas[row[source_column]] = true
	for source: String in GROUND_COVER.FAMILY_BY_SOURCE:
		var family := str(GROUND_COVER.FAMILY_BY_SOURCE[source])
		if not _require(areas.has(source), "Ground-cover override %s is not a generated major area." % source) \
		or not _require(GROUND_COVER.FAMILIES.has(family) or family == GROUND_COVER.PAVED, "Ground-cover override %s names unknown family %s." % [source, family]):
			return false
	return true


## The shoreline slope and the stones are two shared materials of one riprap
## shader whose generated textures load with mipmaps; a riprap overlay record
## (the band inside the outline) gets the verge's ground cover with tangents and
## no collision, and the shoulder outside the outline gets the same cover.
func _shoreline_material_matches(builder: WorldChunkBuilder) -> bool:
	var materials := [ShorelineBuilder.slope_material(), ShorelineBuilder.stone_material()]
	for index in materials.size():
		var material: ShaderMaterial = materials[index]
		if not _require(material != null and material.shader != null and material.shader.resource_path == SHORELINE_SHADER_PATH, "Shoreline material %d is not the riprap shader." % index) \
		or not _require(int(material.get_shader_parameter("surface")) == index, "Shoreline material %d draws the wrong surface." % index):
			return false
		for parameter: String in SHORELINE_ALBEDO_PATHS:
			var albedo := material.get_shader_parameter(parameter) as Texture2D
			if not _require(albedo != null and albedo.resource_path == SHORELINE_ALBEDO_PATHS[parameter], "Shoreline %s is not the generated texture." % parameter):
				return false
			var image := albedo.get_image()
			if not _require(image != null and image.has_mipmaps(), "Shoreline %s lacks imported mipmaps." % parameter):
				return false
	if not _require(ShorelineBuilder.slope_material() == materials[0] and ShorelineBuilder.stone_material() == materials[1], "Shoreline materials are not shared."):
		return false
	var record := {
		"object_key": "material-contract-shoreline",
		"source_keys": ["w1222685424"],
		"feature_kind": "terrain_overlay",
		"material_key": "terrain_riprap",
		"receiver_kind": "none",
		"collision_kind": "none",
		"opaque": false,
		"vertices": [0.0, 0.0, 0.0, 10.0, 0.0, 0.0, 0.0, 0.0, 10.0],
		"normals": [0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0],
		"uvs": [0.0, 0.0, 1.0, 0.0, 0.0, 1.0],
		"indices": [0, 2, 1],
	}
	var result := builder._build_record(record, false)
	if not _require(bool(result.get("ok", false)), "A riprap overlay record could not be built."):
		return false
	var record_node := result.node as Node3D
	var mesh := (record_node.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	var built := mesh.surface_get_material(0)
	var arrays := mesh.surface_get_arrays(0)
	var has_tangents := arrays[Mesh.ARRAY_TANGENT] is PackedFloat32Array and (arrays[Mesh.ARRAY_TANGENT] as PackedFloat32Array).size() == 12
	var has_collision := record_node.get_node_or_null("Collision") != null
	record_node.free()
	var verge := GROUND_COVER.material(ShorelineBuilder.BAND_GROUND_FAMILY)
	# A shoulder record (it carries the land's UVs) gets tangents for the same normal map.
	var shoulder := ShorelineBuilder._array_mesh({"vertices": record.vertices, "normals": record.normals, "uvs": record.uvs, "indices": record.indices}, ShorelineBuilder.verge_material())
	var shoulder_arrays := shoulder.surface_get_arrays(0)
	var shoulder_has_tangents := shoulder_arrays[Mesh.ARRAY_TANGENT] is PackedFloat32Array and (shoulder_arrays[Mesh.ARRAY_TANGENT] as PackedFloat32Array).size() == 12
	return _require(built == verge, "A riprap overlay record did not get the verge's ground cover.") \
		and _require(ShorelineBuilder.verge_material() == verge and shoulder.surface_get_material(0) == verge, "The shoreline shoulder does not share the verge's ground cover.") \
		and _require(shoulder_has_tangents, "A shoreline shoulder mesh lacks tangents for the ground cover's normal map.") \
		and _require(has_tangents, "A riprap overlay record lacks tangents for the ground cover's normal map.") \
		and _require(not has_collision, "A riprap overlay record has collision.")


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("FAIL [world_material_contract]: %s" % message)
	return false
