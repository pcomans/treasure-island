extends SceneTree

const PROMOTED_TEXTURE := "res://game/resources/textures/world/facade_shared_v1/muted_brown_red_brick_albedo_v1.png"
const PROMOTED_MATERIAL := "res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres"
const UV_HELPER := "res://game/scripts/world/facades/facade_meter_uv_adapter.gd"
const ISLE_FACTORY := "res://game/scripts/world/facades/isle_house_39_bruton_low_facade_prototype.gd"
const ISLE_SCENE := "res://game/scenes/world/facades/isle_house/isle_house_low_facade_prototype.tscn"
const ISLE_CONFIG := "res://game/resources/facades/isle_house_39_bruton_low_facade_prototype.json"
const ISLE_LIVE_ADAPTER := "res://game/scripts/world/facades/isle_house_39_bruton_low_live_attachment.gd"
const PILOT_BRICK_TEXTURE := "res://game/resources/textures/world/genai_pilot_v1/muted_brown_red_brick_albedo.png"
const PILOT_STUCCO_TEXTURE := "res://game/resources/textures/world/genai_pilot_v1/warm_ivory_mineral_albedo_v2.png"
const PILOT_BRICK_MATERIAL := "res://game/resources/materials/world/genai_pilot_v1/muted_brown_red_brick_albedo_pilot.tres"
const PILOT_STUCCO_MATERIAL := "res://game/resources/materials/world/genai_pilot_v1/warm_ivory_mineral_albedo_pilot.tres"
const BRICK_SHA256 := "0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mounted_mode := "--mounted" in OS.get_cmdline_user_args()
	if mounted_mode:
		_run_mounted_contract()
	else:
		_run_source_contract()
	_finish()


func _run_source_contract() -> void:
	for path: String in [PROMOTED_TEXTURE, PROMOTED_MATERIAL, UV_HELPER, ISLE_FACTORY, ISLE_SCENE, ISLE_CONFIG, ISLE_LIVE_ADAPTER]:
		_require(FileAccess.file_exists(path), "Missing promoted Phase 2 package resource: %s" % path)
	for path: String in [PILOT_BRICK_TEXTURE, PILOT_STUCCO_TEXTURE, PILOT_BRICK_MATERIAL, PILOT_STUCCO_MATERIAL]:
		_require(FileAccess.file_exists(path), "The non-destructive pilot source boundary lost an artifact: %s" % path)
	_require(FileAccess.get_sha256(PROMOTED_TEXTURE) == BRICK_SHA256, "Promoted brick bytes drifted from the selected asset.")
	_require(FileAccess.get_sha256(PILOT_BRICK_TEXTURE) == BRICK_SHA256, "Selected pilot brick source bytes drifted.")
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	for token: String in [
		"game/resources/textures/world/genai_pilot_v1/*",
		"game/resources/textures/world/genai_pilot_v1/**/*",
		"game/resources/materials/world/genai_pilot_v1/*",
		"game/resources/materials/world/genai_pilot_v1/**/*",
	]:
		_require(token in preset, "all_resources export does not exclude the isolated pilot boundary: %s" % token)
	var factory_source := FileAccess.get_file_as_string(ISLE_FACTORY)
	var live_source := FileAccess.get_file_as_string(ISLE_LIVE_ADAPTER)
	var helper_source := FileAccess.get_file_as_string(UV_HELPER)
	_require(PROMOTED_MATERIAL in factory_source, "Standalone Isle House factory does not use the promoted package material.")
	_require("genai_pilot_v1" not in factory_source, "Standalone Isle House factory directly depends on the excluded pilot tree.")
	_require(ISLE_FACTORY in live_source, "Live Isle House adapter does not reuse the sealed package factory.")
	_require("genai_pilot_v1" not in live_source, "Live Isle House adapter directly depends on the excluded pilot tree.")
	_require("isle_house" not in helper_source.to_lower(), "Generic metre-UV helper contains receiver-specific coupling.")
	_require(_promoted_material_matches(), "Promoted package material is not the approved albedo-only 2.5 m brick configuration.")
	if not _failed:
		print("PASS: source tree retains both pilot families, promotes byte-identical approved brick through a generic package path and bounded Isle House live adapter, and explicitly excludes the isolated pilot tree from all_resources exports")


func _run_mounted_contract() -> void:
	for path: String in [PROMOTED_TEXTURE, PROMOTED_MATERIAL, UV_HELPER, ISLE_FACTORY, ISLE_SCENE, ISLE_CONFIG, ISLE_LIVE_ADAPTER]:
		_require(ResourceLoader.exists(path), "Mounted PCK is missing promoted Phase 2 resource: %s" % path)
	for path: String in [PILOT_BRICK_TEXTURE, PILOT_STUCCO_TEXTURE, PILOT_BRICK_MATERIAL, PILOT_STUCCO_MATERIAL]:
		_require(not ResourceLoader.exists(path), "Mounted PCK still bundles excluded pilot resource: %s" % path)
	_require(_promoted_material_matches(), "Mounted PCK promoted brick material drifted.")
	if not _failed:
		print("PASS: mounted PCK contains the promoted brick/UV/prototype seam plus bounded live adapter and excludes both isolated pilot families, including unused stucco")


func _promoted_material_matches() -> bool:
	var material := load(PROMOTED_MATERIAL) as StandardMaterial3D
	return material != null \
		and material.albedo_texture != null \
		and material.albedo_texture.resource_path == PROMOTED_TEXTURE \
		and material.albedo_color == Color(0.70, 0.66, 0.62, 1.0) \
		and is_zero_approx(material.metallic) \
		and is_equal_approx(material.roughness, 0.86) \
		and material.normal_texture == null \
		and material.roughness_texture == null \
		and material.uv1_scale == Vector3(0.4, 0.4, 1.0) \
		and material.texture_filter == BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
