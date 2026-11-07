extends RefCounted
## Yerba Buena Island's ground material (ybi_ground.gdshader) and its ground-cover map
## (generated/world/context.json ybi_ground_cover: an RGBA8 grid, zlib-deflated, in
## base64). The straw, lawn and soil palettes are copied from Treasure Island's
## ground-cover shader, so the two islands always share one season and tone.

const SHADER := preload("res://game/resources/materials/world/ground_cover/ybi_ground.gdshader")
const ISLAND_SHADER := preload("res://game/resources/materials/world/ground_cover/ground_cover.gdshader")
const DETAIL_ALBEDO := preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_diff_1k.jpg")
const DETAIL_NORMAL := preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_nor_gl_1k.jpg")
const SCHEMA := "ti.ybi-ground-cover/1"
const CHANNELS := ["dark_vegetation", "green", "bare", "rock"]
const FIELDS := ["cell_m", "channels", "height", "origin_xz", "rgba_zlib_base64", "schema_version", "width"]
const SHARED_PALETTE := ["lawn_gap", "lawn_blade", "lawn_straw", "dry_gap", "dry_blade", "dry_straw", "soil_gap", "soil_blade", "soil_straw"]
## The map's largest size, cells a side (the generator draws 630 x 480 at 2 m).
const MAX_CELLS := 2048


## The map's pixels, or an empty array when the document is malformed.
static func cover_bytes(cover: Variant) -> PackedByteArray:
	if not cover is Dictionary:
		return PackedByteArray()
	var doc: Dictionary = cover
	if doc.keys().size() != FIELDS.size() or str(doc.get("schema_version", "")) != SCHEMA or doc.get("channels", null) != CHANNELS:
		return PackedByteArray()
	for field: String in FIELDS:
		if not doc.has(field):
			return PackedByteArray()
	var width := int(doc.width)
	var height := int(doc.height)
	if float(doc.width) != float(width) or float(doc.height) != float(height) or width < 2 or height < 2 or width > MAX_CELLS or height > MAX_CELLS \
	or not doc.origin_xz is Array or (doc.origin_xz as Array).size() != 2 or not (float(doc.cell_m) > 0.0):
		return PackedByteArray()
	var packed := Marshalls.base64_to_raw(str(doc.rgba_zlib_base64))
	if packed.is_empty():
		return PackedByteArray()
	var bytes := packed.decompress(width * height * 4, FileAccess.COMPRESSION_DEFLATE)
	return bytes if bytes.size() == width * height * 4 else PackedByteArray()


## The material for YBI's terrain record, or null when the map is malformed.
static func material(cover: Dictionary) -> ShaderMaterial:
	var bytes := cover_bytes(cover)
	if bytes.is_empty():
		return null
	var image := Image.create_from_data(int(cover.width), int(cover.height), false, Image.FORMAT_RGBA8, bytes)
	image.generate_mipmaps()
	var made := ShaderMaterial.new()
	made.resource_name = "ybi_ground"
	made.shader = SHADER
	made.set_shader_parameter("cover_map", ImageTexture.create_from_image(image))
	var origin: Array = cover.origin_xz
	var cell := float(cover.cell_m)
	made.set_shader_parameter("cover_map_rect", Vector4(float(origin[0]), float(origin[1]), 1.0 / (float(cover.width) * cell), 1.0 / (float(cover.height) * cell)))
	made.set_shader_parameter("detail_albedo", DETAIL_ALBEDO)
	made.set_shader_parameter("detail_normal", DETAIL_NORMAL)
	var palette := island_palette()
	if palette.size() != SHARED_PALETTE.size():
		return null
	for uniform: String in SHARED_PALETTE:
		made.set_shader_parameter(uniform, palette[uniform])
	return made


## Treasure Island's straw, lawn and soil palettes, read from its ground-cover shader's
## own declarations (`uniform vec3 NAME : source_color = vec3(r, g, b);`), so YBI
## follows any retuning of the island's look. Missing names are left out.
static func island_palette() -> Dictionary:
	var palette := {}
	var pattern := RegEx.create_from_string("uniform\\s+vec3\\s+(\\w+)\\s*:\\s*source_color\\s*=\\s*vec3\\(\\s*([0-9.]+)\\s*,\\s*([0-9.]+)\\s*,\\s*([0-9.]+)\\s*\\)")
	for found: RegExMatch in pattern.search_all(ISLAND_SHADER.code):
		var name := found.get_string(1)
		if name in SHARED_PALETTE:
			palette[name] = Color(float(found.get_string(2)), float(found.get_string(3)), float(found.get_string(4)))
	return palette
