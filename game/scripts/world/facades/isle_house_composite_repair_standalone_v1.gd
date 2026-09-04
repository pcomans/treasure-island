class_name IsleHouseCompositeRepairStandaloneV1
extends Node3D

## Isolated A/B factory for the Isle House whole composite. Variant A rebuilds
## the independently failed live candidate exactly. Variant B keeps the accepted
## high facade unchanged and tests a bounded public-side low repair. This script
## is deliberately absent from world construction.

const CONFIG_PATH := "res://game/resources/facades/isle_house_composite_repair_standalone_v1.json"
const CONFIG_SHA256 := "a3e1865d18cfbb4155cf01df3b5eb265ca67e4ee80acfc07986c84d0cd7db393"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const CHUNK_SHA256 := "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce"
const HIGH_WALL_KEY := "building-composite:w1249412094:w1282547786:wall"
const HIGH_ROOF_KEY := "building-composite:w1249412094:w1282547786:roof"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const LOW_ROOF_KEY := "building-composite:w1249412094:w1282547787:roof"
const HIGH_SOURCE_KEY := "w1282547786"
const LOW_SOURCE_KEY := "w1282547787"
const FAILED_LIVE_SIGNATURE := "5d61ab90e5b798ac4aa26c45fea37a5293f3083dada615f06999faad459112cc"
const ACCEPTED_HIGH_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const EXPECTED_REPAIR_SIGNATURE := "a58d9b963b0dc19b5a9fa1cba4872294a2ea2803459a9ba455e276dc1ff5b5bf"
const RENDER_BUILDING_WALL := 1 << 1
const PUBLIC_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
const MODULE_RUNS := [2, 3, 8, 9]
const PROTECTED_RUNS := [10, 11, 12]

const HIGH_FACADE_SCENE := preload("res://game/scenes/world/facades/isle_house/isle_house_high_facade.tscn")
const FAILED_LIVE := preload("res://game/scripts/world/facades/isle_house_39_bruton_low_live_attachment.gd")
const FAILED_LIVE_PATH := "res://game/scripts/world/facades/isle_house_39_bruton_low_live_attachment.gd"
const METER_UV := preload("res://game/scripts/world/facades/facade_meter_uv_adapter.gd")
const MATERIALS := {
	"brick": preload("res://game/resources/materials/world/isle_house/isle_house_low_brick.tres"),
	"brick_field": preload("res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres"),
	"frame": preload("res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres"),
	"glass": preload("res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres"),
	"patio": preload("res://game/resources/materials/world/isle_house/isle_house_low_patio.tres"),
	"landscape": preload("res://game/resources/materials/world/isle_house/isle_house_low_landscape_proxy.tres"),
	"podium": preload("res://game/resources/materials/world/isle_house/isle_house_podium_light.tres"),
	"transition": preload("res://game/resources/materials/world/isle_house/isle_house_support_grey.tres"),
}

const SEALED_DEPENDENCIES := {
	"res://game/scripts/world/facades/isle_house_39_bruton_low_live_attachment.gd": "1b36a0ad92ded4607e0c1e0df5d5581d1c7afff5843cb75cd4c490790a86c413",
	"res://game/scripts/world/facades/isle_house_39_bruton_low_facade_prototype.gd": "68373632dd41989bee82244bdfcef02b89e74202e5a0e22a86d7919285c3e321",
	"res://game/resources/facades/isle_house_39_bruton_low_facade_prototype.json": "a0bfb094bfc4a7878a6dba0b5383dbd29cb8256f5a030a04ece222e912540ae0",
	"res://game/scripts/world/facades/isle_house_39_bruton_high_facade.gd": "f8243cedd3f331cbc37e6343b1b48e76a73a81644c96cc1f80e623e0c71a3113",
	"res://game/scenes/world/facades/isle_house/isle_house_high_facade.tscn": "7ff4a91c402cecea19d2686d29139d2c0f139673b06d21c67d1c14835fd31d12",
	"res://game/resources/facades/isle_house_39_bruton_high_se_layout.json": "c5e6393e90152cef62f6478d7bd87750f3db5598d6ebc36cd307ce20acaa090d",
	"res://game/scripts/world/facades/facade_meter_uv_adapter.gd": "47e710b9ea7c5de5122430199e4105cbba5f672d22f59832f13b8004f16c5a1d",
	"res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres": "488ad52ae9aa0155fd0356eaff128b3ab88ba0c23528c6ae332e7e54c772ffb6",
	"res://game/resources/textures/world/facade_shared_v1/muted_brown_red_brick_albedo_v1.png": "0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d",
	"res://game/resources/materials/world/isle_house/isle_house_low_brick.tres": "fabab09ee257278336c1b7e9a2e6efab5f8e100df65340038ed03c7b0ea89635",
	"res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres": "6910208cb7130a86fbe8a063a6e8fa8e96cfa657d493e02449379b981ce961fe",
	"res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres": "19adff893d82c8c76542140b0ed6f1b3e08fa5e5b75101c0bb55c08b69f2c7ce",
	"res://game/resources/materials/world/isle_house/isle_house_low_patio.tres": "a4790cb821a8bf37e57de4b02e9257a23b0abf6970af5f3da8daf2a22c8eaea5",
	"res://game/resources/materials/world/isle_house/isle_house_low_landscape_proxy.tres": "534cb523b48639e87ec365b120b793a6ddca819e4b09ae590a592fc63d1a010f",
	"res://game/resources/materials/world/isle_house/isle_house_podium_light.tres": "52c57cff2f596f23222ec4f21cdc2a3791d62b667c34d6abb966ca06a0831d7f",
	"res://game/resources/materials/world/isle_house/isle_house_support_grey.tres": "55cb958134db30d533ad311a6a73f10aa523502c8099caf38edb17e30fb4fc04",
}

var _config: Dictionary = {}
var _variant_a: Node3D
var _variant_b: Node3D
var _box_transforms: Dictionary = {}
var _box_counts: Dictionary = {}
var _signature_parts: Array[String] = []
var _module_min_y_m := INF
var _module_max_y_m := -INF
var _configured := false


func configure_from_chunk() -> Dictionary:
	if not FileAccess.file_exists(CHUNK_PATH) or FileAccess.get_sha256(CHUNK_PATH) != CHUNK_SHA256:
		return _failure("standalone_chunk_hash", "Exact Isle House chunk bytes are missing or drifted.")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	if not (parsed is Dictionary):
		return _failure("standalone_chunk_parse", "Exact Isle House chunk could not be parsed.")
	var records := (parsed as Dictionary).get("records", []) as Array
	return configure(
		_record_for_key(records, HIGH_WALL_KEY),
		_record_for_key(records, HIGH_ROOF_KEY),
		_record_for_key(records, LOW_WALL_KEY),
		_record_for_key(records, LOW_ROOF_KEY)
	)


func configure(high_wall: Dictionary, high_roof: Dictionary, low_wall: Dictionary, low_roof: Dictionary) -> Dictionary:
	if _configured:
		return _failure("standalone_duplicate", "Standalone Isle House composite refused duplicate configuration.")
	if not _package_contract_matches():
		return _failure("standalone_package", "Standalone Isle House composite refused drifted or source-bearing package assets.")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not (parsed is Dictionary):
		return _failure("standalone_config_parse", "Standalone Isle House composite config could not be parsed.")
	_config = parsed as Dictionary
	if not validate_config_dictionary(_config):
		return _failure("standalone_config_contract", "Standalone Isle House composite config violated its truth or scope contract.")
	if not _records_match(high_wall, high_roof, low_wall, low_roof):
		return _failure("standalone_records", "Standalone Isle House composite exact high/low wall or roof record drifted.")

	name = "IsleHouseCompositeRepairStandaloneV1"
	set_meta("standalone_only", true)
	set_meta("runtime_attachment", false)
	set_meta("live_replacement", false)
	set_meta("recognition_accepted", false)
	set_meta("believability_accepted", false)
	set_meta("as_built_fidelity", false)
	set_meta("failed_parent_signature", FAILED_LIVE_SIGNATURE)
	set_meta("accepted_high_signature", ACCEPTED_HIGH_SIGNATURE)
	set_meta("config_path", CONFIG_PATH)
	set_meta("config_sha256", CONFIG_SHA256)
	set_meta("protected_run_indices", PROTECTED_RUNS.duplicate())
	set_meta("candidate_method", "detach_repair_overlay_for_preview")
	add_to_group("isle_house_composite_standalone_only")

	var variant_a_result := _build_variant("VariantA_FailedLiveParent", high_wall, high_roof, low_wall, low_roof, false)
	if not bool(variant_a_result.get("ok", false)):
		return variant_a_result
	_variant_a = variant_a_result.node as Node3D
	add_child(_variant_a)
	var variant_b_result := _build_variant("VariantB_StandaloneRepair", high_wall, high_roof, low_wall, low_roof, true)
	if not bool(variant_b_result.get("ok", false)):
		_variant_a.free()
		_variant_a = null
		return variant_b_result
	_variant_b = variant_b_result.node as Node3D
	add_child(_variant_b)
	var topology_a := _topology_for(_variant_a)
	var topology_b := _topology_for(_variant_b)
	var signature_a := JSON.stringify([CHUNK_SHA256, ACCEPTED_HIGH_SIGNATURE, FAILED_LIVE_SIGNATURE, topology_a]).sha256_text()
	var repair_overlay := _variant_b.get_node("RepairLowOverlay") as Node3D
	var repair_signature := str(repair_overlay.get_meta("repair_signature", ""))
	var signature_b := JSON.stringify([CHUNK_SHA256, ACCEPTED_HIGH_SIGNATURE, repair_signature, topology_b]).sha256_text()
	_variant_a.set_meta("variant_id", "failed_live_parent")
	_variant_a.set_meta("independent_grade", "FAIL")
	_variant_a.set_meta("composite_signature", signature_a)
	_variant_a.set_meta("topology", topology_a.duplicate(true))
	_variant_b.set_meta("variant_id", "standalone_repair_v1")
	_variant_b.set_meta("review_status", "pending_independent_review_not_self_accepted")
	_variant_b.set_meta("composite_signature", signature_b)
	_variant_b.set_meta("topology", topology_b.duplicate(true))
	set_meta("variant_a_signature", signature_a)
	set_meta("variant_b_signature", signature_b)
	set_meta("repair_signature", repair_signature)
	set_meta("variant_a_topology", topology_a.duplicate(true))
	set_meta("variant_b_topology", topology_b.duplicate(true))
	_configured = true
	set_variant("repair")
	return {
		"ok": true,
		"variant_a_signature": signature_a,
		"variant_b_signature": signature_b,
		"repair_signature": repair_signature,
		"variant_a_topology": topology_a,
		"variant_b_topology": topology_b,
	}


func set_variant(variant_id: String) -> bool:
	if not _configured or variant_id not in ["failed_parent", "repair"]:
		return false
	_variant_a.visible = variant_id == "failed_parent"
	_variant_b.visible = variant_id == "repair"
	set_meta("visible_variant", variant_id)
	return true


func detach_repair_overlay_for_preview() -> Node3D:
	if not _configured or _variant_b == null:
		return null
	var overlay := _variant_b.get_node_or_null("RepairLowOverlay") as Node3D
	if overlay == null:
		return null
	_variant_b.remove_child(overlay)
	return overlay


static func validate_config_dictionary(config: Dictionary) -> bool:
	if str(config.get("schema_version", "")) != "ti.isle-house-composite-repair-standalone/1" \
	or str(config.get("scope", "")) != "isolated full high-plus-low A/B; never loaded by world construction":
		return false
	var target := config.get("target", {}) as Dictionary
	if str(target.get("parent_source_key", "")) != "w1249412094" \
	or str(target.get("high_wall_key", "")) != HIGH_WALL_KEY \
	or str(target.get("low_wall_key", "")) != LOW_WALL_KEY \
	or str(target.get("chunk_sha256", "")) != CHUNK_SHA256 \
	or not is_equal_approx(float(target.get("high_top_y_m", 0.0)), 71.103) \
	or not is_equal_approx(float(target.get("low_top_y_m", 0.0)), 19.103):
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
	or (truth.get("observed_family_facts", []) as Array).size() != 4 \
	or (truth.get("production_inferences", []) as Array).size() < 4:
		return false
	var render := config.get("render_contract", {}) as Dictionary
	if int(render.get("render_layer", -1)) != RENDER_BUILDING_WALL \
	or not is_equal_approx(float(render.get("live_work_band_top_y_m", 0.0)), 10.25) \
	or not is_equal_approx(float(render.get("upper_podium_field_top_y_m", 0.0)), 18.58) \
	or not is_equal_approx(float(render.get("low_top_y_m", 0.0)), 19.103) \
	or float(render.get("maximum_relief_m", 1.0)) > 0.1001 \
	or str(render.get("collision", "")) != "none" \
	or str(render.get("navigation", "")) != "none" \
	or str(render.get("spray", "")) != "none" \
	or str(render.get("silhouette_change", "")) != "none":
		return false
	var brick := render.get("brick_field_material", {}) as Dictionary
	if not is_equal_approx(float(brick.get("cell_m", 0.0)), 2.5) \
	or not is_equal_approx(float(brick.get("roughness", 0.0)), 0.86) \
	or brick.get("tint", []) != [0.70, 0.66, 0.62, 1.0] \
	or str(brick.get("u_rule", "")) != "continuous_xz_metres_within_ordered_public_side" \
	or str(brick.get("v_rule", "")) != "absolute_world_y_metres":
		return false
	var transition := render.get("upper_transition", {}) as Dictionary
	if _int_array(transition.get("run_indices", []) as Array) != PUBLIC_RUNS \
	or "no openings" not in str(transition.get("blocked_expression", "")) \
	or "literal story-count claim" not in str(transition.get("blocked_expression", "")):
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
	var family := config.get("module_family", {}) as Dictionary
	var variants := family.get("variants", []) as Array
	if variants.size() != 4 \
	or str(family.get("sequence_truth_class", "")) != "reversible_production_inference" \
	or str(family.get("exact_dimensions_truth_class", "")) != "reversible_production_inference":
		return false
	var variants_by_id: Dictionary = {}
	for value: Variant in variants:
		var variant := value as Dictionary
		var variant_id := str(variant.get("id", ""))
		if variant_id.is_empty() or variants_by_id.has(variant_id) \
		or float(variant.get("width_m", 0.0)) <= 0.0 \
		or int(variant.get("door_side", 0)) not in [-1, 1] \
		or str(variant.get("planter_policy", "")) not in ["left", "right", "both"]:
			return false
		variants_by_id[variant_id] = variant
	var placements := config.get("placements", []) as Array
	if placements.size() != 8:
		return false
	var placement_ids: Dictionary = {}
	var counts_by_variant: Dictionary = {}
	var intervals_by_run: Dictionary = {}
	var minimum_clearance := float(render.get("minimum_module_corner_clearance_m", 0.0))
	for value: Variant in placements:
		var placement := value as Dictionary
		var placement_id := str(placement.get("id", ""))
		var variant_id := str(placement.get("variant_id", ""))
		var run_index := int(placement.get("run_index", -1))
		if placement_id.is_empty() or placement_ids.has(placement_id) \
		or not variants_by_id.has(variant_id) or run_index not in MODULE_RUNS \
		or str(placement.get("truth_class", "")) != "reversible_production_inference" \
		or str(placement.get("side_id", "")) != str((runs[run_index] as Dictionary).get("side_id", "")):
			return false
		var width := float((variants_by_id[variant_id] as Dictionary).get("width_m", 0.0))
		var center := float(placement.get("run_u_m", -1.0))
		var interval := Vector2(center - width * 0.5, center + width * 0.5)
		if interval.x < minimum_clearance - 0.0001 \
		or interval.y > float((runs[run_index] as Dictionary).get("length_m", 0.0)) - minimum_clearance + 0.0001:
			return false
		if not intervals_by_run.has(run_index):
			intervals_by_run[run_index] = []
		for other_value: Variant in intervals_by_run[run_index] as Array:
			var other := other_value as Vector2
			if interval.x < other.y + 0.25 and interval.y > other.x - 0.25:
				return false
		(intervals_by_run[run_index] as Array).append(interval)
		placement_ids[placement_id] = true
		counts_by_variant[variant_id] = int(counts_by_variant.get(variant_id, 0)) + 1
	if counts_by_variant.size() != 4:
		return false
	for variant_id: Variant in counts_by_variant:
		if int(counts_by_variant[variant_id]) != 2:
			return false
	var protected_text := JSON.stringify(config.get("protected_regions", [])).to_lower()
	var blocked_text := JSON.stringify(config.get("blocked_claims", [])).to_lower()
	var whole_text := JSON.stringify(config).to_lower()
	for forbidden: String in _forbidden_tokens():
		if forbidden in whole_text:
			return false
	return "10" in protected_text and "11" in protected_text and "12" in protected_text \
		and "hidden" in protected_text and "roof" in protected_text \
		and "upper-band openings" in blocked_text and "recognition" in blocked_text


func _build_variant(branch_name: String, high_wall: Dictionary, high_roof: Dictionary, low_wall: Dictionary, low_roof: Dictionary, repair: bool) -> Dictionary:
	var branch := Node3D.new()
	branch.name = branch_name
	branch.set_meta("full_high_low_composite", true)
	branch.set_meta("standalone_only", true)
	branch.set_meta("collision", "none")
	branch.set_meta("navigation", "none")
	branch.set_meta("spray", "none")
	var wall_material := _scalar_material(Color(0.43, 0.45, 0.46, 1.0), 0.88)
	var roof_material := _scalar_material(Color(0.20, 0.22, 0.23, 1.0), 0.91)
	_add_record_mesh(branch, "ExactHighWall", high_wall, wall_material)
	_add_record_mesh(branch, "ExactHighRoof", high_roof, roof_material)
	_add_record_mesh(branch, "ExactLowWall", low_wall, wall_material)
	_add_record_mesh(branch, "ExactLowRoof", low_roof, roof_material)
	var high := HIGH_FACADE_SCENE.instantiate() as Node3D
	var high_result: Dictionary = high.configure(high_wall)
	if not bool(high_result.get("ok", false)) \
	or str(high_result.get("deterministic_signature", "")) != ACCEPTED_HIGH_SIGNATURE:
		high.free()
		branch.free()
		return _failure("standalone_high", "Accepted high facade failed or drifted in standalone branch.")
	high.name = "AcceptedHighFacade"
	branch.add_child(high)
	if repair:
		var repair_result := _build_repair_overlay(low_wall)
		if not bool(repair_result.get("ok", false)):
			branch.free()
			return repair_result
		branch.add_child(repair_result.node as Node3D)
	else:
		var failed: Node3D
		if FileAccess.file_exists(FAILED_LIVE_PATH):
			var failed_result: Dictionary = FAILED_LIVE.build(low_wall)
			if not bool(failed_result.get("ok", false)) \
			or str((failed_result.get("metadata", {}) as Dictionary).get("live_signature", "")) != FAILED_LIVE_SIGNATURE:
				branch.free()
				return _failure("standalone_failed_parent", "Failed live parent could not be reproduced exactly for Variant A.")
			failed = failed_result.node as Node3D
		else:
			# Exported packages remap the sealed live script, so its source-only hash
			# gate cannot run under a direct-mounted editor binary. Rebuild the same
			# overridden geometry and prove its output signature/topology instead.
			failed = FAILED_LIVE.new() as Node3D
			var failed_configured: Dictionary = failed.call("configure", low_wall)
			var packaged_live_signature := JSON.stringify([
				str(failed.get_meta("deterministic_signature", "")),
				"upper_band_max_y=10.250",
				"upper_boundary_clips=56",
			]).sha256_text()
			if not bool(failed_configured.get("ok", false)) \
			or packaged_live_signature != FAILED_LIVE_SIGNATURE \
			or _topology_for(failed) != {"mesh_instances": 5, "surfaces": 5, "triangles": 1844}:
				failed.free()
				branch.free()
				return _failure("standalone_failed_parent_package", "Packaged failed-parent reconstruction lost exact output parity.")
			failed.set_meta("live_deterministic_signature", packaged_live_signature)
		failed.name = "FailedLiveParentLowOverlay"
		branch.add_child(failed)
	return {"ok": true, "node": branch}


func _build_repair_overlay(low_wall: Dictionary) -> Dictionary:
	_box_transforms = {}
	_box_counts = {}
	_signature_parts = []
	_module_min_y_m = INF
	_module_max_y_m = -INF
	var overlay := Node3D.new()
	overlay.name = "RepairLowOverlay"
	overlay.set_meta("standalone_only", true)
	overlay.set_meta("runtime_attachment", false)
	overlay.set_meta("live_replacement", false)
	overlay.set_meta("recognition_accepted", false)
	overlay.set_meta("believability_accepted", false)
	overlay.set_meta("as_built_fidelity", false)
	overlay.set_meta("failed_parent_signature", FAILED_LIVE_SIGNATURE)
	overlay.set_meta("public_run_indices", PUBLIC_RUNS.duplicate())
	overlay.set_meta("module_run_indices", MODULE_RUNS.duplicate())
	overlay.set_meta("protected_run_indices", PROTECTED_RUNS.duplicate())
	overlay.set_meta("upper_schedule_claimed", false)
	overlay.set_meta("literal_seven_story_geometry_claimed", false)
	overlay.set_meta("collision", "none")
	overlay.set_meta("navigation", "none")
	overlay.set_meta("spray", "none")
	overlay.add_to_group("isle_house_composite_repair_standalone_only")
	var fields_result := _build_repair_fields(overlay, low_wall)
	if not bool(fields_result.get("ok", false)):
		overlay.free()
		return fields_result
	var variants_by_id: Dictionary = {}
	for value: Variant in ((_config.get("module_family", {}) as Dictionary).get("variants", []) as Array):
		var variant := value as Dictionary
		variants_by_id[str(variant.get("id", ""))] = variant
	for value: Variant in _config.get("placements", []) as Array:
		var placement := value as Dictionary
		_build_variant_module(overlay, low_wall, placement, variants_by_id[str(placement.get("variant_id", ""))] as Dictionary)
	_flush_batches(overlay)
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
	overlay.set_meta("module_box_counts", _box_counts.duplicate(true))
	overlay.set_meta("module_box_count", _sum_counts(_box_counts))
	overlay.set_meta("module_min_y_m", _module_min_y_m)
	overlay.set_meta("module_max_y_m", _module_max_y_m)
	overlay.set_meta("side_chain_totals_m", fields_result.get("side_chain_totals_m", {}).duplicate(true))
	overlay.set_meta("side_chain_signatures", fields_result.get("side_chain_signatures", {}).duplicate(true))
	if signature != EXPECTED_REPAIR_SIGNATURE:
		overlay.free()
		return _failure("standalone_repair_signature", "Standalone repair output signature drifted.")
	if _count_type(overlay, CollisionObject3D) != 0 \
	or _count_type(overlay, CollisionShape3D) != 0 \
	or _count_type(overlay, NavigationRegion3D) != 0 \
	or _any_node_in_group(overlay, "spray_receiver") \
	or _any_node_in_group(overlay, "spray_receiver_wall"):
		overlay.free()
		return _failure("standalone_repair_ownership", "Standalone repair created forbidden ownership.")
	return {"ok": true, "node": overlay, "repair_signature": signature, "topology": topology}


func _build_repair_fields(parent: Node3D, low_wall: Dictionary) -> Dictionary:
	var groups := {
		"brick_field": _empty_surface_group(),
		"podium": _empty_surface_group(),
		"transition": _empty_surface_group(),
	}
	var render := _config.get("render_contract", {}) as Dictionary
	var raw_vertices := low_wall.get("vertices", []) as Array
	var raw_normals := low_wall.get("normals", []) as Array
	var runs := _config.get("runs", []) as Array
	var entries_by_run: Dictionary = {}
	var side_chain_totals_m: Dictionary = {}
	var side_chain_signatures: Dictionary = {}
	for side_value: Variant in _config.get("public_sides", []) as Array:
		var side := side_value as Dictionary
		var side_id := str(side.get("id", ""))
		var plan := METER_UV.plan_side_chain(runs, side.get("ordered_run_indices", []) as Array, side_id) as Dictionary
		if not bool(plan.get("ok", false)):
			return _failure("standalone_uv_plan", "Metre-UV helper refused public side %s." % side_id)
		side_chain_totals_m[side_id] = float(plan.get("total_u_m", 0.0))
		side_chain_signatures[side_id] = str(plan.get("signature", ""))
		for entry_value: Variant in plan.get("entries", []) as Array:
			var entry := entry_value as Dictionary
			entries_by_run[int(entry.get("run_index", -1))] = entry
	if entries_by_run.size() != PUBLIC_RUNS.size():
		return _failure("standalone_uv_coverage", "Metre-UV plan did not cover all and only public runs.")
	for run_index_value: Variant in PUBLIC_RUNS:
		var run_index := int(run_index_value)
		var offset := run_index * 12
		var start := Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2]))
		var end := Vector3(float(raw_vertices[offset + 3]), float(raw_vertices[offset + 4]), float(raw_vertices[offset + 5]))
		var normal := Vector3(float(raw_normals[offset]), 0.0, float(raw_normals[offset + 2])).normalized()
		var lower_outward := normal * float(render.get("lower_field_offset_m", 0.0))
		var upper_outward := normal * float(render.get("upper_field_offset_m", 0.0))
		var reveal_outward := normal * float(render.get("transition_reveal_offset_m", 0.0))
		var lower_top := float(render.get("live_work_band_top_y_m", 0.0))
		var upper_top := float(render.get("upper_podium_field_top_y_m", 0.0))
		var low_top := float(render.get("low_top_y_m", 0.0))
		var lower_corners := [
			start + lower_outward,
			end + lower_outward,
			Vector3(end.x, lower_top, end.z) + lower_outward,
			Vector3(start.x, lower_top, start.z) + lower_outward,
		]
		var entry := entries_by_run[run_index] as Dictionary
		var lower_uvs := METER_UV.vertical_quad_uvs(lower_corners, float(entry.get("u_start_m", 0.0))) as PackedVector2Array
		if lower_uvs.size() != 4:
			return _failure("standalone_uv_quad", "Metre-UV helper refused a public lower quad.")
		_append_quad(groups["brick_field"] as Dictionary, lower_corners, normal, lower_uvs)
		var upper_corners := [
			Vector3(start.x, lower_top, start.z) + upper_outward,
			Vector3(end.x, lower_top, end.z) + upper_outward,
			Vector3(end.x, upper_top, end.z) + upper_outward,
			Vector3(start.x, upper_top, start.z) + upper_outward,
		]
		_append_quad(groups["podium"] as Dictionary, upper_corners, normal, _plain_uvs(float(entry.get("u_start_m", 0.0)), float(entry.get("u_end_m", 0.0)), lower_top, upper_top))
		var reveal_corners := [
			Vector3(start.x, upper_top, start.z) + reveal_outward,
			Vector3(end.x, upper_top, end.z) + reveal_outward,
			Vector3(end.x, low_top, end.z) + reveal_outward,
			Vector3(start.x, low_top, start.z) + reveal_outward,
		]
		_append_quad(groups["transition"] as Dictionary, reveal_corners, normal, _plain_uvs(float(entry.get("u_start_m", 0.0)), float(entry.get("u_end_m", 0.0)), upper_top, low_top))
		_signature_parts.append("fields:%02d:%s:%s:%s" % [run_index, _corners_token(lower_corners), _corners_token(upper_corners), _corners_token(reveal_corners)])
		_signature_parts.append("brick_uv:%02d:%s" % [run_index, _uvs_token(lower_uvs)])
	var mesh := ArrayMesh.new()
	for material_key: String in ["brick_field", "podium", "transition"]:
		var group := groups[material_key] as Dictionary
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = group.vertices
		arrays[Mesh.ARRAY_NORMAL] = group.normals
		arrays[Mesh.ARRAY_TANGENT] = group.tangents
		arrays[Mesh.ARRAY_TEX_UV] = group.uvs
		arrays[Mesh.ARRAY_INDEX] = group.indices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(mesh.get_surface_count() - 1, MATERIALS[material_key] as Material)
	var fields := MeshInstance3D.new()
	fields.name = "PublicLowFieldAndPodiumTransition_Runs_0_9"
	fields.mesh = mesh
	fields.layers = RENDER_BUILDING_WALL
	fields.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	fields.set_meta("facade_visual", true)
	fields.set_meta("public_run_indices", PUBLIC_RUNS.duplicate())
	fields.set_meta("protected_run_indices", PROTECTED_RUNS.duplicate())
	fields.set_meta("lower_field_top_y_m", float(render.get("live_work_band_top_y_m", 0.0)))
	fields.set_meta("upper_field_top_y_m", float(render.get("upper_podium_field_top_y_m", 0.0)))
	fields.set_meta("low_top_y_m", float(render.get("low_top_y_m", 0.0)))
	fields.set_meta("upper_schedule_claimed", false)
	fields.set_meta("literal_seven_story_geometry_claimed", false)
	fields.set_meta("uv_contract", METER_UV.contract_metadata())
	fields.set_meta("side_chain_totals_m", side_chain_totals_m.duplicate(true))
	fields.set_meta("side_chain_signatures", side_chain_signatures.duplicate(true))
	parent.add_child(fields)
	return {"ok": true, "surfaces": 3, "triangles": 60, "side_chain_totals_m": side_chain_totals_m, "side_chain_signatures": side_chain_signatures}


func _build_variant_module(parent: Node3D, low_wall: Dictionary, placement: Dictionary, variant: Dictionary) -> void:
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
	module.set_meta("truth_class", "reference_supported_family_with_inferred_arrangement_dimensions_sequence")
	module.set_meta("side_id", str(placement.get("side_id", "")))
	module.set_meta("run_index", run_index)
	module.set_meta("run_u_m", run_u)
	module.set_meta("width_m", width)
	module.set_meta("observed_family_cues", ["warm_brick", "two_level_glazing", "individual_entry", "dutch_half_door", "landscaped_patio_threshold"])
	module.set_meta("production_inferences", ["variant_label", "mirroring", "width", "spacing", "sequence", "opaque_glazing", "planter_proxy"])
	module.set_meta("render_only", true)
	module.set_meta("collision", "none")
	module.set_meta("navigation", "none")
	module.set_meta("spray", "none")
	parent.add_child(module)

	var door_side := int(variant.get("door_side", -1))
	var door_width := float(variant.get("door_width_m", 1.0))
	var edge_inset := 0.17
	var gap := 0.20
	var door_center := (-width * 0.5 + edge_inset + door_width * 0.5) if door_side < 0 else (width * 0.5 - edge_inset - door_width * 0.5)
	var gallery_min := -width * 0.5 + edge_inset
	var gallery_max := width * 0.5 - edge_inset
	if door_side < 0:
		gallery_min = door_center + door_width * 0.5 + gap
	else:
		gallery_max = door_center - door_width * 0.5 - gap
	var gallery_width := gallery_max - gallery_min
	var gallery_center := (gallery_min + gallery_max) * 0.5
	var divider_center := gallery_min - gap * 0.5 if door_side < 0 else gallery_max + gap * 0.5

	_add_box("brick", placement, "BrickPierLeft", module_transform, Vector3(-width * 0.5 + 0.12, 7.18, 0.050), Vector3(0.24, 6.00, 0.076))
	_add_box("brick", placement, "BrickEntryGalleryDivider", module_transform, Vector3(divider_center, 7.18, 0.050), Vector3(0.24, 6.00, 0.076))
	_add_box("brick", placement, "BrickPierRight", module_transform, Vector3(width * 0.5 - 0.12, 7.18, 0.050), Vector3(0.24, 6.00, 0.076))

	_add_box("glass", placement, "GalleryGlazingLower", module_transform, Vector3(gallery_center, 5.62, 0.052), Vector3(gallery_width - 0.16, 2.48, 0.052))
	_add_box("glass", placement, "GalleryGlazingUpper", module_transform, Vector3(gallery_center, 8.52, 0.052), Vector3(gallery_width - 0.16, 2.78, 0.052))
	_add_box("frame", placement, "GalleryFrameLeft", module_transform, Vector3(gallery_min + 0.06, 7.17, 0.074), Vector3(0.12, 5.94, 0.052))
	_add_box("frame", placement, "GalleryFrameRight", module_transform, Vector3(gallery_max - 0.06, 7.17, 0.074), Vector3(0.12, 5.94, 0.052))
	_add_box("frame", placement, "GalleryFrameBottom", module_transform, Vector3(gallery_center, 4.24, 0.074), Vector3(gallery_width, 0.12, 0.052))
	_add_box("frame", placement, "GalleryFrameLevel", module_transform, Vector3(gallery_center, 6.98, 0.074), Vector3(gallery_width, 0.14, 0.052))
	_add_box("frame", placement, "GalleryFrameTop", module_transform, Vector3(gallery_center, 10.14, 0.074), Vector3(gallery_width, 0.12, 0.052))
	var mullion_count := int(variant.get("gallery_mullions", 1))
	for mullion_index in mullion_count:
		var fraction := float(mullion_index + 1) / float(mullion_count + 1)
		var mullion_x := lerpf(gallery_min, gallery_max, fraction)
		_add_box("frame", placement, "GalleryMullion%02d" % mullion_index, module_transform, Vector3(mullion_x, 7.17, 0.073), Vector3(0.10, 5.82, 0.054))

	_add_box("glass", placement, "HalfDoorUpperGlazing", module_transform, Vector3(door_center, 6.48, 0.057), Vector3(door_width - 0.18, 1.32, 0.058))
	_add_box("glass", placement, "HalfDoorLowerPanel", module_transform, Vector3(door_center, 5.00, 0.057), Vector3(door_width - 0.18, 1.42, 0.058))
	_add_box("frame", placement, "HalfDoorFrameLeft", module_transform, Vector3(door_center - door_width * 0.5 + 0.06, 5.74, 0.071), Vector3(0.12, 2.96, 0.056))
	_add_box("frame", placement, "HalfDoorFrameRight", module_transform, Vector3(door_center + door_width * 0.5 - 0.06, 5.74, 0.071), Vector3(0.12, 2.96, 0.056))
	_add_box("frame", placement, "HalfDoorFrameBottom", module_transform, Vector3(door_center, 4.28, 0.071), Vector3(door_width, 0.12, 0.056))
	_add_box("frame", placement, "HalfDoorFrameSplit", module_transform, Vector3(door_center, 5.76, 0.071), Vector3(door_width, 0.14, 0.056))
	_add_box("frame", placement, "HalfDoorFrameTop", module_transform, Vector3(door_center, 7.20, 0.071), Vector3(door_width, 0.12, 0.056))
	_add_box("frame", placement, "EntryCanopy", module_transform, Vector3(door_center, 7.40, 0.078), Vector3(float(variant.get("canopy_width_m", 1.4)), 0.16, 0.040))

	_add_box("patio", placement, "PatioThreshold", module_transform, Vector3(0.0, 4.20, 0.066), Vector3(width - 0.10, 0.18, 0.068))
	var planter_policy := str(variant.get("planter_policy", ""))
	if planter_policy in ["left", "both"]:
		_add_planter(placement, module_transform, -width * 0.5 + 0.48, "Left")
	if planter_policy in ["right", "both"]:
		_add_planter(placement, module_transform, width * 0.5 - 0.48, "Right")
	_signature_parts.append("module:%s:variant=%s:run=%02d:u=%.3f:w=%.3f" % [str(placement.get("id", "")), str(variant.get("id", "")), run_index, run_u, width])


func _add_planter(placement: Dictionary, module_transform: Transform3D, local_x: float, suffix: String) -> void:
	_add_box("patio", placement, "Planter%s" % suffix, module_transform, Vector3(local_x, 4.52, 0.074), Vector3(0.66, 0.52, 0.052))
	_add_box("landscape", placement, "Landscape%s" % suffix, module_transform, Vector3(local_x, 4.92, 0.083), Vector3(0.52, 0.38, 0.034))


func _add_box(material_key: String, placement: Dictionary, component_name: String, module_transform: Transform3D, local_origin: Vector3, size: Vector3) -> void:
	assert(size.x > 0.0 and size.y > 0.0 and size.z > 0.0)
	var maximum_relief := float((_config.get("render_contract", {}) as Dictionary).get("maximum_relief_m", 0.0))
	var top_y := local_origin.y + size.y * 0.5
	var bottom_y := local_origin.y - size.y * 0.5
	var outer := local_origin.z + size.z * 0.5
	assert(top_y <= 10.2501 and bottom_y >= 3.98 and outer <= maximum_relief + 0.0001)
	_module_min_y_m = minf(_module_min_y_m, bottom_y)
	_module_max_y_m = maxf(_module_max_y_m, top_y)
	var local_basis := Basis(Vector3.RIGHT * size.x, Vector3.UP * size.y, Vector3.BACK * size.z)
	var world_transform := module_transform * Transform3D(local_basis, local_origin)
	if not _box_transforms.has(material_key):
		_box_transforms[material_key] = []
	(_box_transforms[material_key] as Array).append(world_transform)
	_box_counts[material_key] = int(_box_counts.get(material_key, 0)) + 1
	_signature_parts.append("box:%s:%s:%s:%s" % [material_key, str(placement.get("id", "")), component_name, _transform_token(world_transform)])


func _flush_batches(parent: Node3D) -> void:
	var batches := Node3D.new()
	batches.name = "RenderOnlyVariantModuleBatches"
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
		box.material = MATERIALS[material_key] as Material
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
		instance.set_meta("facade_visual", true)
		instance.set_meta("material_key", material_key)
		instance.set_meta("instance_count", transforms.size())
		instance.set_meta("render_only", true)
		batches.add_child(instance)


func _records_match(high_wall: Dictionary, high_roof: Dictionary, low_wall: Dictionary, low_roof: Dictionary) -> bool:
	return _record_matches(high_wall, HIGH_WALL_KEY, HIGH_SOURCE_KEY, "building_part_wall", 52, 26, 71.103) \
		and _record_matches(high_roof, HIGH_ROOF_KEY, HIGH_SOURCE_KEY, "building_part_roof", 7, 5, 71.103) \
		and _record_matches(low_wall, LOW_WALL_KEY, LOW_SOURCE_KEY, "building_part_wall", 52, 26, 19.103) \
		and _record_matches(low_roof, LOW_ROOF_KEY, LOW_SOURCE_KEY, "building_part_roof", 6, 4, 19.103) \
		and _low_runs_match(low_wall)


func _record_matches(record: Dictionary, object_key: String, source_key: String, feature_kind: String, vertex_count: int, triangle_count: int, top_y: float) -> bool:
	return str(record.get("object_key", "")) == object_key \
		and record.get("source_keys", []) == [source_key] \
		and str(record.get("feature_kind", "")) == feature_kind \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and (record.get("vertices", []) as Array).size() == vertex_count * 3 \
		and (record.get("indices", []) as Array).size() == triangle_count * 3 \
		and is_equal_approx(float(record.get("top_elevation_m", 0.0)), top_y)


func _low_runs_match(low_wall: Dictionary) -> bool:
	var vertices := low_wall.get("vertices", []) as Array
	var normals := low_wall.get("normals", []) as Array
	var runs := _config.get("runs", []) as Array
	if vertices.size() != 156 or normals.size() != 156 or runs.size() != 13:
		return false
	for run_index in 13:
		var run := runs[run_index] as Dictionary
		var start_values := run.get("start_xyz_m", []) as Array
		var end_values := run.get("end_xyz_m", []) as Array
		var normal_values := run.get("normal_xz", []) as Array
		var offset := run_index * 12
		var start := Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2]))
		var end := Vector3(float(vertices[offset + 3]), float(vertices[offset + 4]), float(vertices[offset + 5]))
		var expected_start := Vector3(float(start_values[0]), float(start_values[1]), float(start_values[2]))
		var expected_end := Vector3(float(end_values[0]), float(end_values[1]), float(end_values[2]))
		var normal := Vector2(float(normals[offset]), float(normals[offset + 2])).normalized()
		var expected_normal := Vector2(float(normal_values[0]), float(normal_values[1])).normalized()
		if start.distance_to(expected_start) > 0.0006 \
		or end.distance_to(expected_end) > 0.0006 \
		or normal.distance_to(expected_normal) > 0.001 \
		or absf(float(vertices[offset + 7]) - 19.103) > 0.0006 \
		or absf(float(vertices[offset + 10]) - 19.103) > 0.0006:
			return false
	return true


func _package_contract_matches() -> bool:
	if not FileAccess.file_exists(CONFIG_PATH) or FileAccess.get_sha256(CONFIG_PATH) != CONFIG_SHA256:
		return false
	for value: Variant in SEALED_DEPENDENCIES:
		var path := str(value)
		if not _runtime_path_is_allowed(path):
			return false
		if FileAccess.file_exists(path):
			if FileAccess.get_sha256(path) != str(SEALED_DEPENDENCIES[path]):
				return false
		elif not ResourceLoader.exists(path):
			return false
	if FileAccess.file_exists("res://game/scripts/world/facades/isle_house_composite_repair_standalone_v1.gd"):
		for path: String in [CONFIG_PATH, "res://game/scripts/world/facades/isle_house_composite_repair_standalone_v1.gd", "res://game/scenes/world/facades/isle_house/isle_house_composite_repair_standalone_v1.tscn"]:
			var text := FileAccess.get_file_as_string(path).to_lower()
			for forbidden: String in _forbidden_tokens():
				if forbidden in text:
					return false
	return true


func _runtime_path_is_allowed(path: String) -> bool:
	if not path.begins_with("res://game/"):
		return false
	var lower := path.to_lower()
	for forbidden: String in _forbidden_tokens():
		if forbidden in lower:
			return false
	return true


func _add_record_mesh(parent: Node3D, node_name: String, record: Dictionary, material: Material) -> void:
	var raw_vertices := record.get("vertices", []) as Array
	var raw_normals := record.get("normals", []) as Array
	var raw_indices := record.get("indices", []) as Array
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	for offset in range(0, raw_vertices.size(), 3):
		vertices.append(Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2])))
	for offset in range(0, raw_normals.size(), 3):
		normals.append(Vector3(float(raw_normals[offset]), float(raw_normals[offset + 1]), float(raw_normals[offset + 2])))
	for value: Variant in raw_indices:
		indices.append(int(value))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.layers = RENDER_BUILDING_WALL
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	instance.set_meta("exact_object_key", str(record.get("object_key", "")))
	instance.set_meta("source_keys", (record.get("source_keys", []) as Array).duplicate())
	instance.set_meta("standalone_visual_copy", true)
	instance.set_meta("collision", "none")
	instance.set_meta("navigation", "none")
	instance.set_meta("spray", "none")
	parent.add_child(instance)


func _scalar_material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.0
	material.roughness = roughness
	return material


func _empty_surface_group() -> Dictionary:
	return {
		"vertices": PackedVector3Array(),
		"normals": PackedVector3Array(),
		"tangents": PackedFloat32Array(),
		"uvs": PackedVector2Array(),
		"indices": PackedInt32Array(),
	}


func _append_quad(group: Dictionary, corners: Array, normal: Vector3, uvs_value: PackedVector2Array) -> void:
	var vertices := group.vertices as PackedVector3Array
	var normals := group.normals as PackedVector3Array
	var tangents := group.tangents as PackedFloat32Array
	var uvs := group.uvs as PackedVector2Array
	var indices := group.indices as PackedInt32Array
	var base := vertices.size()
	var tangent := Vector3(normal.z, 0.0, -normal.x).normalized()
	for corner_index in corners.size():
		vertices.append(corners[corner_index] as Vector3)
		normals.append(normal)
		tangents.append_array(PackedFloat32Array([tangent.x, tangent.y, tangent.z, 1.0]))
		uvs.append(uvs_value[corner_index])
	indices.append_array(PackedInt32Array([base, base + 2, base + 1, base, base + 3, base + 2]))
	group["vertices"] = vertices
	group["normals"] = normals
	group["tangents"] = tangents
	group["uvs"] = uvs
	group["indices"] = indices


func _plain_uvs(u_start: float, u_end: float, bottom_y: float, top_y: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(u_start, bottom_y), Vector2(u_end, bottom_y),
		Vector2(u_end, top_y), Vector2(u_start, top_y),
	])


func _corners_token(corners: Array) -> String:
	var values: Array[String] = []
	for value: Variant in corners:
		var corner := value as Vector3
		values.append("%.6f,%.6f,%.6f" % [corner.x, corner.y, corner.z])
	return ";".join(values)


func _uvs_token(uvs: PackedVector2Array) -> String:
	var values: Array[String] = []
	for uv: Vector2 in uvs:
		values.append("%.6f,%.6f" % [uv.x, uv.y])
	return ";".join(values)


func _transform_token(value: Transform3D) -> String:
	return "%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f" % [
		value.basis.x.x, value.basis.x.y, value.basis.x.z,
		value.basis.y.x, value.basis.y.y, value.basis.y.z,
		value.basis.z.x, value.basis.z.y, value.basis.z.z,
		value.origin.x, value.origin.y, value.origin.z,
	]


static func _topology_for(node: Node) -> Dictionary:
	var mesh_instances := 0
	var surfaces := 0
	var triangles := 0
	for descendant: Node in _descendants_including(node):
		if descendant is MeshInstance3D:
			var mesh := (descendant as MeshInstance3D).mesh
			if mesh == null:
				continue
			mesh_instances += 1
			surfaces += mesh.get_surface_count()
			triangles += mesh.get_faces().size() / 3
		elif descendant is MultiMeshInstance3D:
			var multimesh := (descendant as MultiMeshInstance3D).multimesh
			if multimesh == null or multimesh.mesh == null:
				continue
			mesh_instances += 1
			surfaces += multimesh.mesh.get_surface_count()
			triangles += int(multimesh.mesh.get_faces().size() / 3) * multimesh.instance_count
	return {"mesh_instances": mesh_instances, "surfaces": surfaces, "triangles": triangles}


static func _descendants_including(node: Node) -> Array[Node]:
	var result: Array[Node] = [node]
	for child: Node in node.get_children():
		result.append_array(_descendants_including(child))
	return result


static func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


static func _any_node_in_group(node: Node, group_name: StringName) -> bool:
	if node.is_in_group(group_name):
		return true
	for child: Node in node.get_children():
		if _any_node_in_group(child, group_name):
			return true
	return false


static func _record_for_key(records: Array, object_key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == object_key:
			return record
	return {}


static func _sum_counts(counts: Dictionary) -> int:
	var total := 0
	for value: Variant in counts.values():
		total += int(value)
	return total


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func _forbidden_tokens() -> Array[String]:
	# Assemble the tokens so scanning this guard does not match its own literals.
	return [
		"res://" + "discovery/", "res://" + "evidence/",
		"http" + "://", "https" + "://", "file" + "://",
		"/" + "volumes/", "/" + "users/",
	]


static func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "code": code, "message": message}
