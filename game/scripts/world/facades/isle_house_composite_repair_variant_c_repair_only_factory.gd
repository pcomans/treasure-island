class_name IsleHouseCompositeRepairVariantCRepairOnlyFactory
extends "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"

## Narrow promotion entry for the independently approved Variant C overlay.
## It deliberately does not construct or detach Variant A/B, so the rejected
## live overlay can never be used as a fallback or stacked under this output.

const REVIEWED_VARIANT_C_FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"
const REVIEWED_VARIANT_C_FACTORY_SHA256 := "b24fd72cd12aa0c6c45a123f005fc834ea657c343e8332a872eae07fa017ace7"


func build_repair_only(low_wall: Dictionary) -> Dictionary:
	if _variant_c_configured:
		return _failure("variant_c_live_duplicate", "Variant C repair-only factory refused duplicate configuration.")
	if not _reviewed_parent_matches():
		return _failure("variant_c_live_reviewed_parent", "Variant C repair-only factory refused missing or drifted reviewed parent bytes.")
	if not _package_contract_matches_c():
		return _failure("variant_c_live_package", "Variant C repair-only factory refused drifted or source-bearing package assets.")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(VARIANT_C_CONFIG_PATH))
	if not (parsed is Dictionary):
		return _failure("variant_c_live_config_parse", "Variant C repair-only config could not be parsed.")
	_config = parsed as Dictionary
	if not validate_variant_c_config_dictionary(_config):
		return _failure("variant_c_live_config_contract", "Variant C repair-only config violated its reviewed truth boundary.")
	if not _record_matches(low_wall, LOW_WALL_KEY, LOW_SOURCE_KEY, "building_part_wall", 52, 26, 19.103) \
	or not _low_runs_match(low_wall):
		return _failure("variant_c_live_receiver", "Variant C repair-only factory refused the exact low wall receiver or run geometry.")
	var overlay_result := _build_variant_c_overlay(low_wall)
	if not bool(overlay_result.get("ok", false)):
		return overlay_result
	_variant_c_configured = true
	return overlay_result


func _reviewed_parent_matches() -> bool:
	if not _runtime_path_is_allowed(REVIEWED_VARIANT_C_FACTORY_PATH):
		return false
	if FileAccess.file_exists(REVIEWED_VARIANT_C_FACTORY_PATH):
		return FileAccess.file_exists(REVIEWED_VARIANT_C_FACTORY_PATH) \
			and FileAccess.get_sha256(REVIEWED_VARIANT_C_FACTORY_PATH) == REVIEWED_VARIANT_C_FACTORY_SHA256
	return ResourceLoader.exists(REVIEWED_VARIANT_C_FACTORY_PATH)
