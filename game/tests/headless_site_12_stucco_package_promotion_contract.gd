extends SceneTree

const PROMOTED_TEXTURE := "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png"
const PILOT_TEXTURE := "res://game/resources/textures/world/genai_pilot_v1/warm_ivory_mineral_albedo_v2.png"
const PILOT_MATERIAL := "res://game/resources/materials/world/genai_pilot_v1/warm_ivory_mineral_albedo_pilot.tres"
const EXPECTED_RAW_SHA256 := "af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c"
const EXPECTED_DECODED_SHA256 := "1c6d6019bcfbc9700ab43b80e07f481e51323bb6ac7a12ed03e253ed95545f1a"
const EXPECTED_BYTES := 2811712
const EXPECTED_SIZE := Vector2i(1254, 1254)
const STUCCO_MATERIALS := {
	"res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres": Color(0.96, 0.94, 0.87, 1.0),
	"res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres": Color(0.78, 0.61, 0.42, 1.0),
}
const CONFIGS := [
	"res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json",
	"res://game/resources/facades/d2_1444_croaker_standalone_hero_prototype.json",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mounted := "--mounted" in OS.get_cmdline_user_args()
	_require(ResourceLoader.exists(PROMOTED_TEXTURE), "Promoted Site-12 texture is absent.")
	var promoted := load(PROMOTED_TEXTURE) as Texture2D
	var promoted_image := promoted.get_image() if promoted != null else null
	_require(promoted != null and promoted_image != null and not promoted_image.is_empty(), "Promoted texture did not decode.")
	if promoted_image != null:
		_require(promoted_image.get_size() == EXPECTED_SIZE, "Promoted decoded dimensions drifted.")
		print("SITE_12_STUCCO_DECODED_SHA256 ", _decoded_sha256(promoted_image))
		if not EXPECTED_DECODED_SHA256.is_empty():
			_require(_decoded_sha256(promoted_image) == EXPECTED_DECODED_SHA256, "Promoted decoded pixel/mipmap hash drifted.")
	for path: String in STUCCO_MATERIALS:
		_require(_material_matches(path, STUCCO_MATERIALS[path] as Color), "Promoted material contract drifted: %s." % path)
	_require(_config_paths_match(), "1441/1444 config promotion metadata drifted.")
	if mounted:
		_require(FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot"), "Promotion audit did not mount the exported PCK directly.")
		_require(DirAccess.open("res://discovery") == null, "Canonical package exposes a discovery directory.")
		_require(DirAccess.open("res://evidence") == null, "Canonical package exposes an evidence directory.")
		_require(not ResourceLoader.exists(PILOT_TEXTURE) and not FileAccess.file_exists(PILOT_TEXTURE), "Pilot-only texture leaked into canonical package.")
		_require(not ResourceLoader.exists(PILOT_MATERIAL) and not FileAccess.file_exists(PILOT_MATERIAL), "Pilot-only material leaked into canonical package.")
		_require(not FileAccess.file_exists("res://discovery/facades/GENAI_TEXTURE_PILOT_V1.md"), "Discovery provenance leaked into canonical package.")
		_require(not FileAccess.file_exists("res://evidence/first-playable/d2-1444-croaker-standalone-hero-2026-09-04/capture-manifest.json"), "Prior visual evidence leaked into canonical package.")
	else:
		_require(FileAccess.get_sha256(PROMOTED_TEXTURE) == EXPECTED_RAW_SHA256, "Promoted raw PNG hash drifted.")
		_require(FileAccess.get_file_as_bytes(PROMOTED_TEXTURE).size() == EXPECTED_BYTES, "Promoted raw PNG byte count drifted.")
		_require(FileAccess.get_sha256(PILOT_TEXTURE) == EXPECTED_RAW_SHA256, "Historical pilot source hash drifted.")
		_require(FileAccess.get_file_as_bytes(PILOT_TEXTURE) == FileAccess.get_file_as_bytes(PROMOTED_TEXTURE), "Promotion is not byte-identical to reviewed pilot source.")
		var pilot := load(PILOT_TEXTURE) as Texture2D
		var pilot_image := pilot.get_image() if pilot != null else null
		_require(pilot_image != null and promoted_image != null and pilot_image.get_size() == promoted_image.get_size() and pilot_image.get_format() == promoted_image.get_format() and pilot_image.get_data() == promoted_image.get_data(), "Decoded promoted pixels differ from reviewed pilot source.")
		_require(_canonical_preset_matches(), "Canonical export preset promotion/exclusion boundary drifted.")
	if not _failed:
		print("SITE_12_STUCCO_PROMOTION raw_sha256=%s bytes=%d decoded_size=%s" % [EXPECTED_RAW_SHA256, EXPECTED_BYTES, EXPECTED_SIZE])
		print("PASS: %s Site-12 stucco promotion is byte/pixel identical, keeps both scalar materials and meter UV behavior, and preserves the canonical package boundary" % ("mounted" if mounted else "source"))
	quit(1 if _failed else 0)


func _material_matches(path: String, expected_tint: Color) -> bool:
	var material := load(path) as StandardMaterial3D
	return material != null \
		and material.albedo_texture != null \
		and material.albedo_texture.resource_path == PROMOTED_TEXTURE \
		and material.albedo_color.is_equal_approx(expected_tint) \
		and is_equal_approx(material.roughness, 0.88) \
		and is_zero_approx(material.metallic) \
		and material.normal_texture == null \
		and material.roughness_texture == null \
		and is_equal_approx(material.uv1_scale.x, 0.333333) \
		and is_equal_approx(material.uv1_scale.y, 0.333333) \
		and is_equal_approx(material.uv1_scale.z, 1.0)


func _config_paths_match() -> bool:
	for path: String in CONFIGS:
		var config := _json(path)
		var target_stucco := (config.get("material_scope", {}) as Dictionary).get("target_stucco", {}) as Dictionary
		if str(target_stucco.get("path", "")) == "" \
		or not str(target_stucco.get("source", "")).contains("byte-identical package-safe promotion") \
		or not str(target_stucco.get("source", "")).contains(EXPECTED_RAW_SHA256):
			return false
	return true


func _canonical_preset_matches() -> bool:
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	for token: String in [
		"game/resources/textures/world/genai_pilot_v1/*",
		"game/resources/textures/world/genai_pilot_v1/**/*",
		"game/resources/materials/world/genai_pilot_v1/*",
		"game/resources/materials/world/genai_pilot_v1/**/*",
		"discovery/*",
		"discovery/**/*",
		"evidence/*",
		"evidence/**/*",
	]:
		if token not in preset:
			return false
	return "game/resources/textures/world/site_12_housing/*" not in preset \
		and "game/resources/textures/world/site_12_housing/**/*" not in preset


func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _decoded_sha256(image: Image) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(image.get_data())
	return context.finish().hex_encode()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("SITE_12_STUCCO_PROMOTION_FAIL: %s" % message)
	return false
