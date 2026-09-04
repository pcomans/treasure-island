extends SceneTree

const TEXTURE_ROOT := "res://game/resources/textures/world/genai_pilot_v1"
const MATERIAL_ROOT := "res://game/resources/materials/world/genai_pilot_v1"
const TEXTURES := {
	"warm_ivory_mineral": {
		"path": TEXTURE_ROOT + "/warm_ivory_mineral_albedo_v2.png",
		"sha256": "af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c",
		"material": MATERIAL_ROOT + "/warm_ivory_mineral_albedo_pilot.tres",
		"tint": Color(0.9, 0.87, 0.78, 1),
	},
	"muted_brown_red_brick": {
		"path": TEXTURE_ROOT + "/muted_brown_red_brick_albedo.png",
		"sha256": "0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d",
		"material": MATERIAL_ROOT + "/muted_brown_red_brick_albedo_pilot.tres",
		"tint": Color(0.78, 0.72, 0.66, 1),
	},
}
const FORBIDDEN_LIVE_FILES := [
	"res://game/scripts/main.gd",
	"res://game/scripts/world/world_chunk_builder.gd",
	"res://game/scripts/world/facades/building_1_hero_model.gd",
	"res://game/scripts/world/facades/isle_house_39_bruton_high_facade.gd",
	"res://game/scripts/world/facades/isle_house_39_bruton_low_facade_prototype.gd",
]

var _failed := false


func _initialize() -> void:
	for family: String in TEXTURES:
		var expected := TEXTURES[family] as Dictionary
		if not _texture_matches(family, expected) or not _material_matches(family, expected):
			quit(1)
			return
	for path: String in FORBIDDEN_LIVE_FILES:
		if not _require(FileAccess.file_exists(path), "Live-boundary file is missing: %s" % path) \
		or not _require("genai_pilot_v1" not in FileAccess.get_file_as_string(path), "Pilot content leaked into live runtime file: %s" % path):
			quit(1)
			return
	print("PASS: two isolated GenAI pilot albedos import as repeatable mipmapped 1254px RGB textures with scalar roughness, no fabricated PBR maps, and no live Building 1, Isle House, world-builder, or main-scene attachment")
	quit(0)


func _texture_matches(family: String, expected: Dictionary) -> bool:
	var path := str(expected.path)
	var texture := load(path) as Texture2D
	if not _require(FileAccess.get_sha256(path) == str(expected.sha256), "%s source hash drifted." % family) \
	or not _require(texture != null, "%s did not import as Texture2D." % family):
		return false
	var image := texture.get_image()
	return _require(image != null and not image.is_empty(), "%s imported image is empty." % family) \
		and _require(image.get_size() == Vector2i(1254, 1254), "%s dimensions are not the generated 1254x1254 source." % family) \
		and _require(not image.detect_alpha(), "%s unexpectedly gained alpha." % family) \
		and _require(image.has_mipmaps(), "%s lacks imported mipmaps." % family)


func _material_matches(family: String, expected: Dictionary) -> bool:
	var material := load(str(expected.material)) as StandardMaterial3D
	if not _require(material != null, "%s pilot material did not load." % family):
		return false
	return _require(material.albedo_texture != null and material.albedo_texture.resource_path == str(expected.path), "%s material does not use its selected albedo." % family) \
		and _require(material.albedo_color.is_equal_approx(expected.tint as Color), "%s reversible pilot tint drifted." % family) \
		and _require(material.normal_texture == null and material.roughness_texture == null and not material.normal_enabled, "%s fabricated or borrowed a mismatched PBR map." % family) \
		and _require(is_equal_approx(material.roughness, 0.86) and is_zero_approx(material.metallic), "%s is not using the pinned scalar roughness/metalness pilot." % family) \
		and _require(material.get_flag(BaseMaterial3D.FLAG_USE_TEXTURE_REPEAT), "%s material disabled repeat." % family) \
		and _require(material.texture_filter == BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC, "%s material lacks anisotropic mip filtering." % family) \
		and _require(material.uv1_scale.is_equal_approx(Vector3(1.0 / 3.0, 1.0 / 3.0, 1.0)), "%s does not use the reversible 3m pilot repeat." % family)


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("FAIL [genai_texture_pilot_v1]: %s" % message)
	return false
