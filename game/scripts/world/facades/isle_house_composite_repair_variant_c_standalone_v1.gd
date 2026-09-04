class_name IsleHouseCompositeRepairVariantCStandaloneV1
extends "res://game/scripts/world/facades/isle_house_composite_repair_standalone_v1.gd"

## Standalone-only B/C comparison factory. Variant B is detached intact from
## the sealed v1 A/B factory. Variant C replaces only that branch's render-only
## low overlay; it never participates in world construction.

const VARIANT_C_CONFIG_PATH := "res://game/resources/facades/isle_house_composite_repair_variant_c_standalone_v1.json"
const VARIANT_C_CONFIG_SHA256 := "bafdef392ee638e860ba15f140c10de61e266ae63005b12e0e310e52c176897a"
const SEALED_B_SCENE_PATH := "res://game/scenes/world/facades/isle_house/isle_house_composite_repair_standalone_v1.tscn"
const SEALED_B_SCENE_SHA256 := "e16cd72955169e199f7631677f09e75441bea143c4f1b39d08e2409aaefdbb9a"
const SEALED_B_FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_standalone_v1.gd"
const SEALED_B_FACTORY_SHA256 := "b23d9cb3acbedacb323197fd38660f45b13e532dd11c1cca1fafe785338037d8"
const SEALED_B_CONFIG_PATH := "res://game/resources/facades/isle_house_composite_repair_standalone_v1.json"
const SEALED_B_CONFIG_SHA256 := "a3e1865d18cfbb4155cf01df3b5eb265ca67e4ee80acfc07986c84d0cd7db393"
const SEALED_B_REPAIR_SIGNATURE := "a58d9b963b0dc19b5a9fa1cba4872294a2ea2803459a9ba455e276dc1ff5b5bf"
const SEALED_B_TOPOLOGY := {"mesh_instances": 16, "surfaces": 19, "triangles": 14375}
const EXPECTED_VARIANT_C_REPAIR_SIGNATURE := "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69"
const EXPECTED_VARIANT_C_COMPOSITE_SIGNATURE := "d57d5088854d68b80d3747f4382da2f08fdbfc8c64e7acae0f342a2a72f435ec"
const EXPECTED_VARIANT_C_OVERLAY_TOPOLOGY := {"mesh_instances": 7, "surfaces": 11, "triangles": 2242}
const EXPECTED_VARIANT_C_COMPOSITE_TOPOLOGY := {"mesh_instances": 17, "surfaces": 22, "triangles": 14301}
const MODULE_RUNS_C := [2, 3, 6, 8, 9]

const SEALED_B_SCENE := preload(SEALED_B_SCENE_PATH)
const MATERIALS_C := {
	"brick_field": preload("res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres"),
	"frame": preload("res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres"),
	"glass": preload("res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres"),
	"patio": preload("res://game/resources/materials/world/isle_house/isle_house_low_patio.tres"),
	"landscape": preload("res://game/resources/materials/world/isle_house/isle_house_low_landscape_proxy.tres"),
	"podium_light": preload("res://game/resources/materials/world/isle_house/isle_house_podium_light.tres"),
	"podium_mid": preload("res://game/resources/materials/world/isle_house/isle_house_podium_mid_warm_v1.tres"),
	"transition": preload("res://game/resources/materials/world/isle_house/isle_house_support_grey.tres"),
	"quiet_return": preload("res://game/resources/materials/world/isle_house/isle_house_return_quiet_v1.tres"),
}

const SEALED_PACKAGE_HASHES_C := {
	SEALED_B_SCENE_PATH: SEALED_B_SCENE_SHA256,
	SEALED_B_FACTORY_PATH: SEALED_B_FACTORY_SHA256,
	SEALED_B_CONFIG_PATH: SEALED_B_CONFIG_SHA256,
	"res://game/scripts/world/facades/isle_house_39_bruton_high_facade.gd": "f8243cedd3f331cbc37e6343b1b48e76a73a81644c96cc1f80e623e0c71a3113",
	"res://game/scenes/world/facades/isle_house/isle_house_high_facade.tscn": "7ff4a91c402cecea19d2686d29139d2c0f139673b06d21c67d1c14835fd31d12",
	"res://game/resources/facades/isle_house_39_bruton_high_se_layout.json": "c5e6393e90152cef62f6478d7bd87750f3db5598d6ebc36cd307ce20acaa090d",
	"res://game/scripts/world/facades/facade_meter_uv_adapter.gd": "47e710b9ea7c5de5122430199e4105cbba5f672d22f59832f13b8004f16c5a1d",
	"res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres": "488ad52ae9aa0155fd0356eaff128b3ab88ba0c23528c6ae332e7e54c772ffb6",
	"res://game/resources/textures/world/facade_shared_v1/muted_brown_red_brick_albedo_v1.png": "0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d",
	"res://game/resources/materials/world/isle_house/isle_house_podium_mid_warm_v1.tres": "a9c7230ff52d37327e6d98e0f14953eee2bd3eec7426dc993c0b7cf90e0ec037",
	"res://game/resources/materials/world/isle_house/isle_house_return_quiet_v1.tres": "15d4848127a5153724d873dceea9d46121c0d65e5b53be61abed6e70a2f964c1",
}

var _sealed_variant_b: Node3D
var _variant_c: Node3D
var _variant_c_configured := false
var _module_box_count_c := 0
var _upper_relief_box_count_c := 0
var _upper_relief_min_world_y_m := INF
var _upper_relief_max_world_y_m := -INF


func configure_from_chunk() -> Dictionary:
	if not FileAccess.file_exists(CHUNK_PATH) or FileAccess.get_sha256(CHUNK_PATH) != CHUNK_SHA256:
		return _failure("variant_c_chunk_hash", "Exact Isle House chunk bytes are missing or drifted.")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	if not (parsed is Dictionary):
		return _failure("variant_c_chunk_parse", "Exact Isle House chunk could not be parsed.")
	var records := (parsed as Dictionary).get("records", []) as Array
	return configure(
		_record_for_key(records, HIGH_WALL_KEY),
		_record_for_key(records, HIGH_ROOF_KEY),
		_record_for_key(records, LOW_WALL_KEY),
		_record_for_key(records, LOW_ROOF_KEY)
	)


func configure(high_wall: Dictionary, high_roof: Dictionary, low_wall: Dictionary, low_roof: Dictionary) -> Dictionary:
	if _variant_c_configured:
		return _failure("variant_c_duplicate", "Variant C standalone factory refused duplicate configuration.")
	if not _package_contract_matches_c():
		return _failure("variant_c_package", "Variant C standalone factory refused drifted or source-bearing package assets.")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(VARIANT_C_CONFIG_PATH))
	if not (parsed is Dictionary):
		return _failure("variant_c_config_parse", "Variant C config could not be parsed.")
	_config = parsed as Dictionary
	if not validate_variant_c_config_dictionary(_config):
		return _failure("variant_c_config_contract", "Variant C config violated its truth, rhythm, or protected-region contract.")
	if not _records_match(high_wall, high_roof, low_wall, low_roof):
		return _failure("variant_c_records", "Variant C exact high/low wall or roof record drifted.")

	var sealed_b_result := _detach_sealed_b_branch(high_wall, high_roof, low_wall, low_roof)
	if not bool(sealed_b_result.get("ok", false)):
		return sealed_b_result
	_sealed_variant_b = sealed_b_result.node as Node3D
	_sealed_variant_b.name = "VariantB_SealedRepair"
	_sealed_variant_b.set_meta("comparison_role", "sealed_independently_failed_variant_b")
	add_child(_sealed_variant_b)

	var candidate_branch_result := _detach_sealed_b_branch(high_wall, high_roof, low_wall, low_roof)
	if not bool(candidate_branch_result.get("ok", false)):
		_sealed_variant_b.free()
		_sealed_variant_b = null
		return candidate_branch_result
	_variant_c = candidate_branch_result.node as Node3D
	var old_overlay := _variant_c.get_node_or_null("RepairLowOverlay") as Node3D
	if old_overlay == null or str(old_overlay.get_meta("repair_signature", "")) != SEALED_B_REPAIR_SIGNATURE:
		_variant_c.free()
		_sealed_variant_b.free()
		_variant_c = null
		_sealed_variant_b = null
		return _failure("variant_c_sealed_b_overlay", "Variant C could not locate the exact sealed Variant B overlay to replace.")
	_variant_c.remove_child(old_overlay)
	old_overlay.free()
	var overlay_result := _build_variant_c_overlay(low_wall)
	if not bool(overlay_result.get("ok", false)):
		_variant_c.free()
		_sealed_variant_b.free()
		_variant_c = null
		_sealed_variant_b = null
		return overlay_result
	_variant_c.name = "VariantC_StandaloneRepair"
	_variant_c.add_child(overlay_result.node as Node3D)
	var topology_c := _topology_for(_variant_c)
	var composite_signature := JSON.stringify([CHUNK_SHA256, ACCEPTED_HIGH_SIGNATURE, str(overlay_result.repair_signature), topology_c]).sha256_text()
	_variant_c.set_meta("variant_id", "standalone_repair_variant_c_v1")
	_variant_c.set_meta("review_status", "pending_independent_review_not_self_accepted")
	_variant_c.set_meta("composite_signature", composite_signature)
	_variant_c.set_meta("topology", topology_c.duplicate(true))
	add_child(_variant_c)

	if composite_signature != EXPECTED_VARIANT_C_COMPOSITE_SIGNATURE \
	or topology_c != EXPECTED_VARIANT_C_COMPOSITE_TOPOLOGY:
		var message := "Variant C composite drift: signature=%s topology=%s." % [composite_signature, topology_c]
		_sealed_variant_b.free()
		_variant_c.free()
		_sealed_variant_b = null
		_variant_c = null
		return _failure("variant_c_composite_signature", message)

	name = "IsleHouseCompositeRepairVariantCStandaloneV1"
	set_meta("standalone_only", true)
	set_meta("runtime_attachment", false)
	set_meta("live_replacement", false)
	set_meta("recognition_accepted", false)
	set_meta("believability_accepted", false)
	set_meta("as_built_fidelity", false)
	set_meta("upper_schedule_claimed", false)
	set_meta("literal_seven_story_geometry_claimed", false)
	set_meta("protected_return_opening_schedule_claimed", false)
	set_meta("sealed_variant_b_repair_signature", SEALED_B_REPAIR_SIGNATURE)
	set_meta("variant_c_repair_signature", str(overlay_result.repair_signature))
	set_meta("variant_c_composite_signature", composite_signature)
	set_meta("variant_b_topology", SEALED_B_TOPOLOGY.duplicate(true))
	set_meta("variant_c_topology", topology_c.duplicate(true))
	set_meta("config_path", VARIANT_C_CONFIG_PATH)
	set_meta("config_sha256", VARIANT_C_CONFIG_SHA256)
	add_to_group("isle_house_composite_variant_c_standalone_only")
	_variant_c_configured = true
	set_variant("c")
	return {
		"ok": true,
		"variant_b_signature": str(_sealed_variant_b.get_meta("composite_signature", "")),
		"variant_b_topology": SEALED_B_TOPOLOGY.duplicate(true),
		"variant_c_repair_signature": str(overlay_result.repair_signature),
		"variant_c_overlay_topology": (overlay_result.topology as Dictionary).duplicate(true),
		"variant_c_composite_signature": composite_signature,
		"variant_c_topology": topology_c.duplicate(true),
	}


func set_variant(variant_id: String) -> bool:
	if not _variant_c_configured or variant_id not in ["b", "c"]:
		return false
	_sealed_variant_b.visible = variant_id == "b"
	_variant_c.visible = variant_id == "c"
	set_meta("visible_variant", variant_id)
	return true


func detach_variant_b_overlay_for_preview() -> Node3D:
	if not _variant_c_configured or _sealed_variant_b == null:
		return null
	var overlay := _sealed_variant_b.get_node_or_null("RepairLowOverlay") as Node3D
	if overlay == null:
		return null
	_sealed_variant_b.remove_child(overlay)
	overlay.name = "SealedVariantBRepairPreview"
	return overlay


func detach_variant_c_overlay_for_preview() -> Node3D:
	if not _variant_c_configured or _variant_c == null:
		return null
	var overlay := _variant_c.get_node_or_null("VariantCRepairLowOverlay") as Node3D
	if overlay == null:
		return null
	_variant_c.remove_child(overlay)
	overlay.name = "VariantCRepairPreview"
	return overlay


static func validate_variant_c_config_dictionary(config: Dictionary) -> bool:
	if str(config.get("schema_version", "")) != "ti.isle-house-composite-repair-variant-c-standalone/1" \
	or str(config.get("scope", "")) != "isolated full high-plus-low sealed-B versus Variant-C comparison; never loaded by world construction":
		return false
	var target := config.get("target", {}) as Dictionary
	if str(target.get("parent_source_key", "")) != "w1249412094" \
	or str(target.get("chunk_sha256", "")) != CHUNK_SHA256 \
	or str(target.get("high_wall_key", "")) != HIGH_WALL_KEY \
	or str(target.get("low_wall_key", "")) != LOW_WALL_KEY \
	or not is_equal_approx(float(target.get("high_top_y_m", 0.0)), 71.103) \
	or not is_equal_approx(float(target.get("low_top_y_m", 0.0)), 19.103):
		return false
	var sealed_b := config.get("sealed_variant_b", {}) as Dictionary
	if str(sealed_b.get("factory_sha256", "")) != SEALED_B_FACTORY_SHA256 \
	or str(sealed_b.get("config_sha256", "")) != SEALED_B_CONFIG_SHA256 \
	or str(sealed_b.get("repair_signature", "")) != SEALED_B_REPAIR_SIGNATURE \
	or str(sealed_b.get("independent_grade", "")) != "FAIL":
		return false
	var truth := config.get("truth_boundary", {}) as Dictionary
	if not bool(truth.get("standalone_only", false)) \
	or bool(truth.get("runtime_attachment", true)) \
	or bool(truth.get("live_replacement", true)) \
	or bool(truth.get("recognition_accepted", true)) \
	or bool(truth.get("believability_accepted", true)) \
	or bool(truth.get("as_built_fidelity", true)) \
	or bool(truth.get("source_pixels_packaged", true)) \
	or bool(truth.get("upper_schedule_claimed", true)) \
	or bool(truth.get("literal_seven_story_geometry_claimed", true)) \
	or bool(truth.get("protected_return_opening_schedule_claimed", true)):
		return false
	var render := config.get("render_contract", {}) as Dictionary
	if int(render.get("render_layer", -1)) != RENDER_BUILDING_WALL \
	or not is_equal_approx(float(render.get("live_work_band_top_y_m", 0.0)), 10.25) \
	or not is_equal_approx(float(render.get("low_top_y_m", 0.0)), 19.103) \
	or float(render.get("maximum_relief_m", 1.0)) > 0.1801 \
	or str(render.get("collision", "")) != "none" \
	or str(render.get("navigation", "")) != "none" \
	or str(render.get("spray", "")) != "none":
		return false
	var brick := render.get("brick_field_material", {}) as Dictionary
	if brick.get("tint", []) != [0.70, 0.66, 0.62, 1.0] \
	or not is_equal_approx(float(brick.get("cell_m", 0.0)), 2.5) \
	or not is_equal_approx(float(brick.get("roughness", 0.0)), 0.86) \
	or str(brick.get("u_rule", "")) != "continuous_xz_metres_within_ordered_public_side" \
	or str(brick.get("v_rule", "")) != "absolute_world_y_metres":
		return false
	var bands := render.get("upper_massing_bands", []) as Array
	if bands.size() != 4:
		return false
	var cursor := 10.25
	for value: Variant in bands:
		var band := value as Dictionary
		if not is_equal_approx(float(band.get("bottom_y_m", -1.0)), cursor) \
		or float(band.get("top_y_m", -1.0)) <= cursor \
		or float(band.get("offset_m", 1.0)) > 0.1101 \
		or str(band.get("truth_class", "")) != "production_inference_massing_not_story" \
		or str(band.get("material_key", "")) not in ["transition", "podium_mid", "podium_light"]:
			return false
		cursor = float(band.top_y_m)
	if not is_equal_approx(cursor, 19.103):
		return false
	var fallback := render.get("protected_nnw_fallback", {}) as Dictionary
	if _int_array(fallback.get("run_indices", []) as Array) != [10, 11, 12] \
	or str(fallback.get("material_key", "")) != "quiet_return" \
	or int(fallback.get("opening_count", -1)) != 0 \
	or bool(fallback.get("schedule_claimed", true)) \
	or "homogeneous" not in str(fallback.get("treatment", "")):
		return false
	var sides := config.get("public_sides", []) as Array
	if sides.size() != 2 \
	or _int_array((sides[0] as Dictionary).get("ordered_run_indices", []) as Array) != [0, 1, 2, 3, 4] \
	or _int_array((sides[1] as Dictionary).get("ordered_run_indices", []) as Array) != [5, 6, 7, 8, 9]:
		return false
	var runs := config.get("runs", []) as Array
	if runs.size() != 13:
		return false
	for run_index in 13:
		if int((runs[run_index] as Dictionary).get("index", -1)) != run_index:
			return false
	var variants := ((config.get("module_family", {}) as Dictionary).get("variants", []) as Array)
	if variants.size() != 4:
		return false
	var variants_by_id: Dictionary = {}
	for value: Variant in variants:
		var variant := value as Dictionary
		var variant_id := str(variant.get("id", ""))
		var width := float(variant.get("width_m", 0.0))
		var panels := variant.get("panels", []) as Array
		if variant_id.is_empty() or variants_by_id.has(variant_id) or width < 3.0 or panels.size() < 2:
			return false
		for panel_value: Variant in panels:
			var panel := panel_value as Dictionary
			var half_width := float(panel.get("width_m", 0.0)) * 0.5
			var half_height := float(panel.get("height_m", 0.0)) * 0.5
			if str(panel.get("role", "")).is_empty() \
			or absf(float(panel.get("x_m", 0.0))) + half_width > width * 0.5 + 0.0001 \
			or float(panel.get("y_m", 0.0)) - half_height < 4.18 \
			or float(panel.get("y_m", 0.0)) + half_height > 10.05:
				return false
		variants_by_id[variant_id] = variant
	var placements := config.get("placements", []) as Array
	if placements.size() != 8:
		return false
	var counts: Dictionary = {}
	var intervals: Dictionary = {}
	var minimum_clearance := float(render.get("minimum_module_corner_clearance_m", 0.0))
	for value: Variant in placements:
		var placement := value as Dictionary
		var variant_id := str(placement.get("variant_id", ""))
		var run_index := int(placement.get("run_index", -1))
		if not variants_by_id.has(variant_id) or run_index not in MODULE_RUNS_C \
		or str(placement.get("truth_class", "")) != "reversible_production_inference" \
		or str(placement.get("side_id", "")) != str((runs[run_index] as Dictionary).get("side_id", "")):
			return false
		var width := float((variants_by_id[variant_id] as Dictionary).get("width_m", 0.0))
		var center := float(placement.get("run_u_m", -1.0))
		var interval := Vector2(center - width * 0.5, center + width * 0.5)
		if interval.x < minimum_clearance - 0.0001 \
		or interval.y > float((runs[run_index] as Dictionary).get("length_m", 0.0)) - minimum_clearance + 0.0001:
			return false
		if not intervals.has(run_index):
			intervals[run_index] = []
		for other_value: Variant in intervals[run_index] as Array:
			var other := other_value as Vector2
			if interval.x < other.y + 0.45 and interval.y > other.x - 0.45:
				return false
		(intervals[run_index] as Array).append(interval)
		counts[variant_id] = int(counts.get(variant_id, 0)) + 1
	if counts.size() != 4:
		return false
	for value: Variant in counts.values():
		if int(value) != 2:
			return false
	var text := JSON.stringify(config).to_lower()
	for forbidden: String in _forbidden_tokens():
		if forbidden in text:
			return false
	return "upper-band openings" in JSON.stringify(config.get("blocked_claims", [])).to_lower() \
		and "nnw opening schedule" in JSON.stringify(config.get("blocked_claims", [])).to_lower()


func _detach_sealed_b_branch(high_wall: Dictionary, high_roof: Dictionary, low_wall: Dictionary, low_roof: Dictionary) -> Dictionary:
	var sealed := SEALED_B_SCENE.instantiate() as IsleHouseCompositeRepairStandaloneV1
	if sealed == null:
		return _failure("variant_c_sealed_b_scene", "Sealed Variant B scene did not instantiate.")
	var configured := sealed.configure(high_wall, high_roof, low_wall, low_roof)
	if not bool(configured.get("ok", false)) \
	or str(configured.get("repair_signature", "")) != SEALED_B_REPAIR_SIGNATURE \
	or configured.get("variant_b_topology", {}) != SEALED_B_TOPOLOGY:
		sealed.free()
		return _failure("variant_c_sealed_b_rebuild", "Sealed Variant B did not reproduce exactly.")
	var branch := sealed.get_node_or_null("VariantB_StandaloneRepair") as Node3D
	if branch == null or _topology_for(branch) != SEALED_B_TOPOLOGY:
		sealed.free()
		return _failure("variant_c_sealed_b_branch", "Sealed Variant B branch topology drifted.")
	sealed.remove_child(branch)
	sealed.free()
	return {"ok": true, "node": branch}


func _build_variant_c_overlay(low_wall: Dictionary) -> Dictionary:
	_box_transforms = {}
	_box_counts = {}
	_signature_parts = []
	_module_min_y_m = INF
	_module_max_y_m = -INF
	_module_box_count_c = 0
	_upper_relief_box_count_c = 0
	_upper_relief_min_world_y_m = INF
	_upper_relief_max_world_y_m = -INF
	var overlay := Node3D.new()
	overlay.name = "VariantCRepairLowOverlay"
	overlay.set_meta("standalone_only", true)
	overlay.set_meta("runtime_attachment", false)
	overlay.set_meta("live_replacement", false)
	overlay.set_meta("recognition_accepted", false)
	overlay.set_meta("believability_accepted", false)
	overlay.set_meta("as_built_fidelity", false)
	overlay.set_meta("upper_schedule_claimed", false)
	overlay.set_meta("literal_seven_story_geometry_claimed", false)
	overlay.set_meta("protected_return_opening_schedule_claimed", false)
	overlay.set_meta("sealed_variant_b_repair_signature", SEALED_B_REPAIR_SIGNATURE)
	overlay.set_meta("collision", "none")
	overlay.set_meta("navigation", "none")
	overlay.set_meta("spray", "none")
	overlay.add_to_group("isle_house_composite_variant_c_standalone_only")
	var fields_result := _build_variant_c_fields(overlay, low_wall)
	if not bool(fields_result.get("ok", false)):
		overlay.free()
		return fields_result
	var variants_by_id: Dictionary = {}
	for value: Variant in ((_config.get("module_family", {}) as Dictionary).get("variants", []) as Array):
		var variant := value as Dictionary
		variants_by_id[str(variant.get("id", ""))] = variant
	for value: Variant in _config.get("placements", []) as Array:
		var placement := value as Dictionary
		_build_variant_c_module(overlay, low_wall, placement, variants_by_id[str(placement.get("variant_id", ""))] as Dictionary)
	_flush_variant_c_batches(overlay)
	var sorted_signature := _signature_parts.duplicate()
	sorted_signature.sort()
	var signature := JSON.stringify(sorted_signature).sha256_text()
	var topology := _topology_for(overlay)
	overlay.set_meta("repair_signature", signature)
	overlay.set_meta("topology", topology.duplicate(true))
	overlay.set_meta("field_triangle_count", int(fields_result.get("triangles", 0)))
	overlay.set_meta("field_surface_count", int(fields_result.get("surfaces", 0)))
	overlay.set_meta("module_count", (_config.get("placements", []) as Array).size())
	overlay.set_meta("module_variant_count", variants_by_id.size())
	overlay.set_meta("module_box_count", _module_box_count_c)
	overlay.set_meta("upper_relief_box_count", _upper_relief_box_count_c)
	overlay.set_meta("upper_relief_min_world_y_m", _upper_relief_min_world_y_m)
	overlay.set_meta("upper_relief_max_world_y_m", _upper_relief_max_world_y_m)
	overlay.set_meta("box_counts_by_material", _box_counts.duplicate(true))
	overlay.set_meta("module_min_y_m", _module_min_y_m)
	overlay.set_meta("module_max_y_m", _module_max_y_m)
	overlay.set_meta("public_side_chain_totals_m", fields_result.get("side_chain_totals_m", {}).duplicate(true))
	overlay.set_meta("quiet_nnw_run_indices", [10, 11, 12])
	overlay.set_meta("quiet_nnw_opening_count", 0)
	overlay.set_meta("upper_band_ids", fields_result.get("upper_band_ids", []).duplicate())
	if signature != EXPECTED_VARIANT_C_REPAIR_SIGNATURE \
	or topology != EXPECTED_VARIANT_C_OVERLAY_TOPOLOGY:
		var message := "Variant C overlay drift: signature=%s topology=%s boxes=%s." % [signature, topology, _box_counts]
		overlay.free()
		return _failure("variant_c_repair_signature", message)
	if _count_type(overlay, CollisionObject3D) != 0 \
	or _count_type(overlay, CollisionShape3D) != 0 \
	or _count_type(overlay, NavigationRegion3D) != 0 \
	or _any_node_in_group(overlay, "spray_receiver") \
	or _any_node_in_group(overlay, "spray_receiver_wall"):
		overlay.free()
		return _failure("variant_c_ownership", "Variant C created forbidden collision, navigation, or spray ownership.")
	return {"ok": true, "node": overlay, "repair_signature": signature, "topology": topology}


func _build_variant_c_fields(parent: Node3D, low_wall: Dictionary) -> Dictionary:
	var groups := {
		"brick_field": _empty_surface_group(),
		"transition": _empty_surface_group(),
		"podium_mid": _empty_surface_group(),
		"podium_light": _empty_surface_group(),
		"quiet_return": _empty_surface_group(),
	}
	var render := _config.get("render_contract", {}) as Dictionary
	var raw_vertices := low_wall.get("vertices", []) as Array
	var raw_normals := low_wall.get("normals", []) as Array
	var runs := _config.get("runs", []) as Array
	var entries_by_run: Dictionary = {}
	var side_chain_totals_m: Dictionary = {}
	for side_value: Variant in _config.get("public_sides", []) as Array:
		var side := side_value as Dictionary
		var side_id := str(side.get("id", ""))
		var plan := METER_UV.plan_side_chain(runs, side.get("ordered_run_indices", []) as Array, side_id) as Dictionary
		if not bool(plan.get("ok", false)):
			return _failure("variant_c_uv_plan", "Metre-UV helper refused public side %s." % side_id)
		side_chain_totals_m[side_id] = float(plan.get("total_u_m", 0.0))
		for entry_value: Variant in plan.get("entries", []) as Array:
			var entry := entry_value as Dictionary
			entries_by_run[int(entry.get("run_index", -1))] = entry
	if entries_by_run.size() != PUBLIC_RUNS.size():
		return _failure("variant_c_uv_coverage", "Metre-UV plan did not cover all and only public runs.")
	var bands := render.get("upper_massing_bands", []) as Array
	for run_index_value: Variant in PUBLIC_RUNS:
		var run_index := int(run_index_value)
		var offset := run_index * 12
		var start := Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2]))
		var end := Vector3(float(raw_vertices[offset + 3]), float(raw_vertices[offset + 4]), float(raw_vertices[offset + 5]))
		var normal := Vector3(float(raw_normals[offset]), 0.0, float(raw_normals[offset + 2])).normalized()
		var entry := entries_by_run[run_index] as Dictionary
		var lower_outward := normal * float(render.get("lower_field_offset_m", 0.0))
		var lower_top := float(render.get("live_work_band_top_y_m", 0.0))
		var lower_corners := [start + lower_outward, end + lower_outward, Vector3(end.x, lower_top, end.z) + lower_outward, Vector3(start.x, lower_top, start.z) + lower_outward]
		var lower_uvs := METER_UV.vertical_quad_uvs(lower_corners, float(entry.get("u_start_m", 0.0))) as PackedVector2Array
		if lower_uvs.size() != 4:
			return _failure("variant_c_uv_quad", "Metre-UV helper refused a public lower quad.")
		_append_quad(groups.brick_field as Dictionary, lower_corners, normal, lower_uvs)
		_signature_parts.append("lower:%02d:%s:%s" % [run_index, _corners_token(lower_corners), _uvs_token(lower_uvs)])
		for band_value: Variant in bands:
			var band := band_value as Dictionary
			var outward := normal * float(band.get("offset_m", 0.0))
			var bottom_y := float(band.get("bottom_y_m", 0.0))
			var top_y := float(band.get("top_y_m", 0.0))
			var corners := [Vector3(start.x, bottom_y, start.z) + outward, Vector3(end.x, bottom_y, end.z) + outward, Vector3(end.x, top_y, end.z) + outward, Vector3(start.x, top_y, start.z) + outward]
			var material_key := str(band.get("material_key", ""))
			_append_quad(groups[material_key] as Dictionary, corners, normal, _plain_uvs(float(entry.get("u_start_m", 0.0)), float(entry.get("u_end_m", 0.0)), bottom_y, top_y))
			_signature_parts.append("upper:%02d:%s:%s" % [run_index, str(band.get("id", "")), _corners_token(corners)])
		var tangent := (end - start).normalized()
		var length := start.distance_to(end)
		var midpoint := (start + end) * 0.5
		# The cap config stores absolute world Y. Keep the run basis origin at Y=0
		# so the frozen receiver's ~4.1 m base elevation is not added twice.
		var run_transform := Transform3D(Basis(tangent, Vector3.UP, normal), Vector3(midpoint.x, 0.0, midpoint.z))
		for cap_value: Variant in render.get("upper_relief_caps", []) as Array:
			var cap := cap_value as Dictionary
			_add_c_box(str(cap.get("material_key", "")), "UPPER-RUN-%02d" % run_index, str(cap.get("id", "")), run_transform, Vector3(0.0, float(cap.get("center_y_m", 0.0)), float(cap.get("outward_center_m", 0.0))), Vector3(length + 0.04, float(cap.get("height_m", 0.0)), float(cap.get("depth_m", 0.0))), "upper_relief")
	var fallback := render.get("protected_nnw_fallback", {}) as Dictionary
	for run_index_value: Variant in fallback.get("run_indices", []) as Array:
		var run_index := int(run_index_value)
		var offset := run_index * 12
		var start := Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2]))
		var end := Vector3(float(raw_vertices[offset + 3]), float(raw_vertices[offset + 4]), float(raw_vertices[offset + 5]))
		var normal := Vector3(float(raw_normals[offset]), 0.0, float(raw_normals[offset + 2])).normalized()
		var outward := normal * float(fallback.get("offset_m", 0.0))
		var top_y := float(fallback.get("top_y_m", 0.0))
		var corners := [start + outward, end + outward, Vector3(end.x, top_y, end.z) + outward, Vector3(start.x, top_y, start.z) + outward]
		_append_quad(groups.quiet_return as Dictionary, corners, normal, _plain_uvs(0.0, start.distance_to(end), minf(start.y, end.y), top_y))
		_signature_parts.append("quiet_return:%02d:%s" % [run_index, _corners_token(corners)])
	var mesh := ArrayMesh.new()
	for material_key: String in ["brick_field", "transition", "podium_mid", "podium_light", "quiet_return"]:
		var group := groups[material_key] as Dictionary
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = group.vertices
		arrays[Mesh.ARRAY_NORMAL] = group.normals
		arrays[Mesh.ARRAY_TANGENT] = group.tangents
		arrays[Mesh.ARRAY_TEX_UV] = group.uvs
		arrays[Mesh.ARRAY_INDEX] = group.indices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_name(mesh.get_surface_count() - 1, material_key)
		mesh.surface_set_material(mesh.get_surface_count() - 1, MATERIALS_C[material_key] as Material)
	var fields := MeshInstance3D.new()
	fields.name = "VariantC_PublicFieldsAndQuietNNW"
	fields.mesh = mesh
	fields.layers = RENDER_BUILDING_WALL
	fields.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	fields.set_meta("public_run_indices", PUBLIC_RUNS.duplicate())
	fields.set_meta("quiet_nnw_run_indices", [10, 11, 12])
	fields.set_meta("quiet_nnw_opening_count", 0)
	fields.set_meta("upper_schedule_claimed", false)
	fields.set_meta("literal_seven_story_geometry_claimed", false)
	fields.set_meta("protected_return_opening_schedule_claimed", false)
	fields.set_meta("uv_contract", METER_UV.contract_metadata())
	fields.set_meta("public_side_chain_totals_m", side_chain_totals_m.duplicate(true))
	fields.set_meta("upper_band_ids", ["TRANSFER-PLINTH", "PODIUM-BODY", "PODIUM-CROWN", "TOP-SHADOW-CAP"])
	parent.add_child(fields)
	return {"ok": true, "surfaces": 5, "triangles": 106, "side_chain_totals_m": side_chain_totals_m, "upper_band_ids": fields.get_meta("upper_band_ids")}


func _build_variant_c_module(parent: Node3D, low_wall: Dictionary, placement: Dictionary, variant: Dictionary) -> void:
	var run_index := int(placement.get("run_index", -1))
	var run_u := float(placement.get("run_u_m", 0.0))
	var width := float(variant.get("width_m", 0.0))
	var offset := run_index * 12
	var vertices := low_wall.get("vertices", []) as Array
	var normals := low_wall.get("normals", []) as Array
	var start := Vector3(float(vertices[offset]), 0.0, float(vertices[offset + 2]))
	var end := Vector3(float(vertices[offset + 3]), 0.0, float(vertices[offset + 5]))
	var tangent := (end - start).normalized()
	var normal := Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()
	var module_transform := Transform3D(Basis(tangent, Vector3.UP, normal), start + tangent * run_u)
	var module := Node3D.new()
	module.name = str(placement.get("id", "UNNAMED")).replace("-", "_")
	module.transform = module_transform
	module.set_meta("placement_id", str(placement.get("id", "")))
	module.set_meta("variant_id", str(variant.get("id", "")))
	module.set_meta("macro_class", str(variant.get("macro_class", "")))
	module.set_meta("truth_class", "reference_supported_family_with_inferred_macro_arrangement_dimensions_sequence")
	module.set_meta("production_inferences", ["macro_class", "panel_proportions", "cluster", "offset", "width", "spacing", "pause", "sequence", "mirroring", "opaque_glazing", "canopy_depth", "patio_depth", "planter_proxy"])
	module.set_meta("side_id", str(placement.get("side_id", "")))
	module.set_meta("run_index", run_index)
	module.set_meta("run_u_m", run_u)
	module.set_meta("width_m", width)
	module.set_meta("panel_roles", _panel_roles(variant.get("panels", []) as Array))
	module.set_meta("collision", "none")
	module.set_meta("navigation", "none")
	module.set_meta("spray", "none")
	parent.add_child(module)
	for panel_value: Variant in variant.get("panels", []) as Array:
		_add_framed_panel_c(placement, module_transform, panel_value as Dictionary)
	for canopy_value: Variant in variant.get("canopies", []) as Array:
		var canopy := canopy_value as Dictionary
		_add_c_box("patio", placement.get("id", ""), "Canopy", module_transform, Vector3(float(canopy.get("x_m", 0.0)), float(canopy.get("y_m", 0.0)), 0.090), Vector3(float(canopy.get("width_m", 0.0)), 0.18, float(canopy.get("depth_m", 0.0))), "module")
	var patio := variant.get("patio", {}) as Dictionary
	_add_c_box("patio", placement.get("id", ""), "PatioThreshold", module_transform, Vector3(float(patio.get("x_m", 0.0)), 4.19, 0.085), Vector3(float(patio.get("width_m", 0.0)), 0.18, float(patio.get("depth_m", 0.0))), "module")
	for planter_x_value: Variant in variant.get("planter_x_m", []) as Array:
		var planter_x := float(planter_x_value)
		_add_c_box("patio", placement.get("id", ""), "Planter", module_transform, Vector3(planter_x, 4.47, 0.090), Vector3(0.72, 0.56, 0.12), "module")
		_add_c_box("landscape", placement.get("id", ""), "Landscape", module_transform, Vector3(planter_x, 4.90, 0.105), Vector3(0.56, 0.30, 0.08), "module")
	_signature_parts.append("module_c:%s:variant=%s:run=%02d:u=%.3f:w=%.3f" % [str(placement.get("id", "")), str(variant.get("id", "")), run_index, run_u, width])


func _add_framed_panel_c(placement: Dictionary, module_transform: Transform3D, panel: Dictionary) -> void:
	var panel_id := str(panel.get("id", "PANEL"))
	var x := float(panel.get("x_m", 0.0))
	var y := float(panel.get("y_m", 0.0))
	var width := float(panel.get("width_m", 0.0))
	var height := float(panel.get("height_m", 0.0))
	var frame := 0.14
	_add_c_box("glass", placement.get("id", ""), "%s_Glass" % panel_id, module_transform, Vector3(x, y, 0.038), Vector3(width - frame * 1.25, height - frame * 1.25, 0.055), "module")
	_add_c_box("frame", placement.get("id", ""), "%s_Left" % panel_id, module_transform, Vector3(x - width * 0.5 + frame * 0.5, y, 0.082), Vector3(frame, height, 0.055), "module")
	_add_c_box("frame", placement.get("id", ""), "%s_Right" % panel_id, module_transform, Vector3(x + width * 0.5 - frame * 0.5, y, 0.082), Vector3(frame, height, 0.055), "module")
	_add_c_box("frame", placement.get("id", ""), "%s_Bottom" % panel_id, module_transform, Vector3(x, y - height * 0.5 + frame * 0.5, 0.082), Vector3(width, frame, 0.055), "module")
	_add_c_box("frame", placement.get("id", ""), "%s_Top" % panel_id, module_transform, Vector3(x, y + height * 0.5 - frame * 0.5, 0.082), Vector3(width, frame, 0.055), "module")
	if bool(panel.get("half_door", false)):
		_add_c_box("frame", placement.get("id", ""), "%s_HalfDoorSplit" % panel_id, module_transform, Vector3(x, y, 0.084), Vector3(width, frame, 0.058), "module")


func _add_c_box(material_key: String, owner_id: Variant, component_name: String, basis_transform: Transform3D, local_origin: Vector3, size: Vector3, scope: String) -> void:
	assert(MATERIALS_C.has(material_key))
	assert(size.x > 0.0 and size.y > 0.0 and size.z > 0.0)
	var render := _config.get("render_contract", {}) as Dictionary
	var bottom_y := local_origin.y - size.y * 0.5
	var top_y := local_origin.y + size.y * 0.5
	var outer := local_origin.z + size.z * 0.5
	assert(bottom_y >= 3.9799 and top_y <= 19.1031 and outer <= float(render.get("maximum_relief_m", 0.0)) + 0.0001)
	var local_basis := Basis(Vector3.RIGHT * size.x, Vector3.UP * size.y, Vector3.BACK * size.z)
	var world_transform := basis_transform * Transform3D(local_basis, local_origin)
	if scope == "module":
		_module_min_y_m = minf(_module_min_y_m, bottom_y)
		_module_max_y_m = maxf(_module_max_y_m, top_y)
		_module_box_count_c += 1
	else:
		_upper_relief_box_count_c += 1
		_upper_relief_min_world_y_m = minf(_upper_relief_min_world_y_m, world_transform.origin.y)
		_upper_relief_max_world_y_m = maxf(_upper_relief_max_world_y_m, world_transform.origin.y)
	if not _box_transforms.has(material_key):
		_box_transforms[material_key] = []
	(_box_transforms[material_key] as Array).append(world_transform)
	_box_counts[material_key] = int(_box_counts.get(material_key, 0)) + 1
	_signature_parts.append("box_c:%s:%s:%s:%s:%s" % [scope, material_key, str(owner_id), component_name, _transform_token(world_transform)])


func _flush_variant_c_batches(parent: Node3D) -> void:
	var batches := Node3D.new()
	batches.name = "VariantCRenderOnlyBatches"
	batches.set_meta("render_only", true)
	batches.set_meta("collision", "none")
	batches.set_meta("navigation", "none")
	batches.set_meta("spray", "none")
	parent.add_child(batches)
	var material_keys := _box_transforms.keys()
	material_keys.sort()
	for value: Variant in material_keys:
		var material_key := str(value)
		var transforms := _box_transforms[material_key] as Array
		var box := BoxMesh.new()
		box.size = Vector3.ONE
		box.material = MATERIALS_C[material_key] as Material
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = box
		multimesh.instance_count = transforms.size()
		for index in transforms.size():
			multimesh.set_instance_transform(index, transforms[index] as Transform3D)
		var instance := MultiMeshInstance3D.new()
		instance.name = "Batch_%s" % material_key
		instance.multimesh = multimesh
		instance.layers = RENDER_BUILDING_WALL
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		instance.set_meta("material_key", material_key)
		instance.set_meta("instance_count", transforms.size())
		instance.set_meta("render_only", true)
		batches.add_child(instance)


func _package_contract_matches_c() -> bool:
	if not FileAccess.file_exists(VARIANT_C_CONFIG_PATH) or FileAccess.get_sha256(VARIANT_C_CONFIG_PATH) != VARIANT_C_CONFIG_SHA256:
		return false
	for value: Variant in SEALED_PACKAGE_HASHES_C:
		var path := str(value)
		if not _runtime_path_is_allowed(path):
			return false
		if FileAccess.file_exists(path):
			if FileAccess.get_sha256(path) != str(SEALED_PACKAGE_HASHES_C[path]):
				return false
		elif not ResourceLoader.exists(path):
			return false
	if FileAccess.file_exists("res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"):
		for path: String in [VARIANT_C_CONFIG_PATH, "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd", "res://game/scenes/world/facades/isle_house/isle_house_composite_repair_variant_c_standalone_v1.tscn"]:
			if not FileAccess.file_exists(path):
				return false
			var text := FileAccess.get_file_as_string(path).to_lower()
			for forbidden: String in _forbidden_tokens():
				if forbidden in text:
					return false
	return _materials_match_c()


func _materials_match_c() -> bool:
	var brick := MATERIALS_C.brick_field as StandardMaterial3D
	var mid := MATERIALS_C.podium_mid as StandardMaterial3D
	var quiet := MATERIALS_C.quiet_return as StandardMaterial3D
	return brick != null and brick.albedo_texture != null \
		and brick.albedo_color == Color(0.70, 0.66, 0.62, 1.0) \
		and is_equal_approx(brick.roughness, 0.86) \
		and brick.uv1_scale == Vector3(0.4, 0.4, 1.0) \
		and mid != null and mid.albedo_color == Color(0.545, 0.53, 0.505, 1.0) and is_equal_approx(mid.roughness, 0.88) \
		and quiet != null and quiet.albedo_texture == null and quiet.albedo_color == Color(0.465, 0.45, 0.425, 1.0) and is_equal_approx(quiet.roughness, 0.92)


static func _panel_roles(panels: Array) -> Array[String]:
	var roles: Array[String] = []
	for value: Variant in panels:
		roles.append(str((value as Dictionary).get("role", "")))
	return roles
