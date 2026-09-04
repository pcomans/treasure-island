extends SceneTree

const SCENE_PATH := "res://game/scenes/world/facades/isle_house/isle_house_composite_repair_variant_c_standalone_v1.tscn"
const FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"
const CONFIG_PATH := "res://game/resources/facades/isle_house_composite_repair_variant_c_standalone_v1.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const SEALED_B_FACTORY := "res://game/scripts/world/facades/isle_house_composite_repair_standalone_v1.gd"
const SEALED_B_CONFIG := "res://game/resources/facades/isle_house_composite_repair_standalone_v1.json"
const SEALED_B_SCENE := "res://game/scenes/world/facades/isle_house/isle_house_composite_repair_standalone_v1.tscn"
const VARIANT_C_FACTORY := preload("res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd")
const SEALED_B_HASHES := {
	SEALED_B_FACTORY: "b23d9cb3acbedacb323197fd38660f45b13e532dd11c1cca1fafe785338037d8",
	SEALED_B_CONFIG: "a3e1865d18cfbb4155cf01df3b5eb265ca67e4ee80acfc07986c84d0cd7db393",
	SEALED_B_SCENE: "e16cd72955169e199f7631677f09e75441bea143c4f1b39d08e2409aaefdbb9a",
	"res://game/scripts/world/facades/isle_house_39_bruton_high_facade.gd": "f8243cedd3f331cbc37e6343b1b48e76a73a81644c96cc1f80e623e0c71a3113",
	"res://game/scenes/world/facades/isle_house/isle_house_high_facade.tscn": "7ff4a91c402cecea19d2686d29139d2c0f139673b06d21c67d1c14835fd31d12",
	"res://game/resources/facades/isle_house_39_bruton_high_se_layout.json": "c5e6393e90152cef62f6478d7bd87750f3db5598d6ebc36cd307ce20acaa090d",
}
const SEALED_B_REPAIR_SIGNATURE := "a58d9b963b0dc19b5a9fa1cba4872294a2ea2803459a9ba455e276dc1ff5b5bf"
const SEALED_B_TOPOLOGY := {"mesh_instances": 16, "surfaces": 19, "triangles": 14375}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for path: String in [SCENE_PATH, FACTORY_PATH, CONFIG_PATH, CHUNK_PATH]:
		_require(FileAccess.file_exists(path), "Missing Variant C standalone asset %s." % path)
	for path: String in SEALED_B_HASHES:
		_require(FileAccess.get_sha256(path) == str(SEALED_B_HASHES[path]), "Sealed A/B, accepted high, or world builder bytes drifted: %s." % path)
	var builder := FileAccess.get_file_as_string(BUILDER_PATH)
	_require("isle_house_composite_repair_variant_c_standalone_v1.tscn" not in builder.to_lower(), "Historical Variant C standalone scene was wired directly into world construction.")
	_require("isle_house_composite_repair_variant_c_live_attachment.gd" in builder.to_lower(), "Approved Variant C live promotion is not routed through its narrow attachment adapter.")
	var config := _json(CONFIG_PATH)
	_require(VARIANT_C_FACTORY.validate_variant_c_config_dictionary(config), "Variant C config did not validate.")
	_validate_mutations(config)
	var packed := load(SCENE_PATH) as PackedScene
	_require(packed != null, "Variant C standalone scene failed to load.")
	if packed == null:
		_finish()
		return
	var first := packed.instantiate()
	var second := packed.instantiate()
	var first_result: Dictionary = first.call("configure_from_chunk")
	var second_result: Dictionary = second.call("configure_from_chunk")
	_require(bool(first_result.get("ok", false)), "First Variant C build failed: %s" % first_result)
	_require(bool(second_result.get("ok", false)), "Second Variant C build failed: %s" % second_result)
	if not bool(first_result.get("ok", false)) or not bool(second_result.get("ok", false)):
		first.free()
		second.free()
		_finish()
		return
	_require(first_result == second_result, "Two clean Variant C builds were nondeterministic.")
	_require(first_result.get("variant_b_topology", {}) == SEALED_B_TOPOLOGY, "Sealed Variant B topology changed inside B/C factory.")
	_require(str(first.get_meta("sealed_variant_b_repair_signature", "")) == SEALED_B_REPAIR_SIGNATURE, "Sealed Variant B repair signature changed.")
	_require(first.set_variant("b") and first.get_node("VariantB_SealedRepair").visible and not first.get_node("VariantC_StandaloneRepair").visible, "B comparison selection failed.")
	_require(first.set_variant("c") and not first.get_node("VariantB_SealedRepair").visible and first.get_node("VariantC_StandaloneRepair").visible, "C comparison selection failed.")
	var repair := first.get_node("VariantC_StandaloneRepair/VariantCRepairLowOverlay") as Node3D
	_validate_truth(repair)
	_validate_fields(repair)
	_validate_macro_rhythm(repair)
	_validate_zero_ownership(repair)
	_require(not bool(first.get_meta("recognition_accepted", true)) and not bool(first.get_meta("believability_accepted", true)) and not bool(first.get_meta("live_replacement", true)), "Variant C self-promoted a visual claim.")
	print("VARIANT_C_REPAIR_SIGNATURE: %s" % str(first_result.get("variant_c_repair_signature", "")))
	print("VARIANT_C_COMPOSITE_SIGNATURE: %s" % str(first_result.get("variant_c_composite_signature", "")))
	print("VARIANT_C_OVERLAY_TOPOLOGY: %s" % JSON.stringify(first_result.get("variant_c_overlay_topology", {})))
	print("VARIANT_C_COMPOSITE_TOPOLOGY: %s" % JSON.stringify(first_result.get("variant_c_topology", {})))
	print("VARIANT_C_BOX_COUNTS: %s" % JSON.stringify(repair.get_meta("box_counts_by_material", {})))
	first.free()
	second.free()
	if not _failed:
		print("PASS: sealed Variant B remains exactly reproducible while standalone-only Variant C adds a quiet schedule-free NNW field, unequal schedule-free podium massing hierarchy, and four perceptually distinct inference-labeled lower macro rhythms with zero collision/navigation/spray ownership")
	_finish()


func _validate_mutations(config: Dictionary) -> void:
	var mutations := []
	var truth := config.duplicate(true)
	truth.truth_boundary.upper_schedule_claimed = true
	mutations.append(truth)
	var literal := config.duplicate(true)
	literal.truth_boundary.literal_seven_story_geometry_claimed = true
	mutations.append(literal)
	var nnw := config.duplicate(true)
	nnw.render_contract.protected_nnw_fallback.opening_count = 1
	mutations.append(nnw)
	var band := config.duplicate(true)
	band.render_contract.upper_massing_bands[1].bottom_y_m = 12.0
	mutations.append(band)
	var placement := config.duplicate(true)
	placement.placements[0].run_u_m = 0.1
	mutations.append(placement)
	var duplicate_variant := config.duplicate(true)
	duplicate_variant.module_family.variants[1].id = str(duplicate_variant.module_family.variants[0].id)
	mutations.append(duplicate_variant)
	for mutation: Dictionary in mutations:
		_require(not VARIANT_C_FACTORY.validate_variant_c_config_dictionary(mutation), "Variant C schema accepted a forbidden mutation.")


func _validate_truth(repair: Node3D) -> void:
	_require(repair != null and bool(repair.get_meta("standalone_only", false)) and not bool(repair.get_meta("runtime_attachment", true)) and not bool(repair.get_meta("live_replacement", true)), "Variant C repair lost standalone-only truth.")
	_require(not bool(repair.get_meta("upper_schedule_claimed", true)) and not bool(repair.get_meta("literal_seven_story_geometry_claimed", true)) and not bool(repair.get_meta("protected_return_opening_schedule_claimed", true)), "Variant C made a forbidden upper/story/NNW schedule claim.")
	_require(repair.get_meta("quiet_nnw_run_indices", []) == [10, 11, 12] and int(repair.get_meta("quiet_nnw_opening_count", -1)) == 0, "Variant C quiet NNW scope drifted.")
	_require(repair.get_meta("upper_band_ids", []) == ["TRANSFER-PLINTH", "PODIUM-BODY", "PODIUM-CROWN", "TOP-SHADOW-CAP"], "Variant C upper massing hierarchy drifted.")


func _validate_fields(repair: Node3D) -> void:
	var fields := repair.get_node_or_null("VariantC_PublicFieldsAndQuietNNW") as MeshInstance3D
	_require(fields != null and fields.mesh != null and fields.mesh.get_surface_count() == 5, "Variant C field mesh lost its five material roles.")
	if fields == null or fields.mesh == null:
		return
	var names: Array[String] = []
	for surface_index in fields.mesh.get_surface_count():
		names.append(fields.mesh.surface_get_name(surface_index))
	_require(names == ["brick_field", "transition", "podium_mid", "podium_light", "quiet_return"], "Variant C field roles drifted: %s." % JSON.stringify(names))
	_require(fields.get_meta("quiet_nnw_run_indices", []) == [10, 11, 12] and int(fields.get_meta("quiet_nnw_opening_count", -1)) == 0, "Quiet NNW fallback gained an opening or lost a run.")
	var totals := fields.get_meta("public_side_chain_totals_m", {}) as Dictionary
	_require(is_equal_approx(float(totals.get("LOW-WSW-AVENUE-OF-THE-PALMS", 0.0)), 51.6984152793884) and is_equal_approx(float(totals.get("LOW-ENE-GARDEN-WALK", 0.0)), 49.7970167398453), "Promoted brick side-chain metre UV totals drifted.")
	_require(is_equal_approx(float(repair.get_meta("upper_relief_min_world_y_m", -INF)), 10.38) and is_equal_approx(float(repair.get_meta("upper_relief_max_world_y_m", INF)), 18.63), "Variant C caps escaped the intended absolute world-Y levels.")


func _validate_macro_rhythm(repair: Node3D) -> void:
	var variants: Dictionary = {}
	var run_counts: Dictionary = {}
	for child: Node in repair.get_children():
		if not child.has_meta("variant_id"):
			continue
		var variant_id := str(child.get_meta("variant_id", ""))
		variants[variant_id] = int(variants.get(variant_id, 0)) + 1
		var run_index := int(child.get_meta("run_index", -1))
		run_counts[run_index] = int(run_counts.get(run_index, 0)) + 1
		_require("cluster" in (child.get_meta("production_inferences", []) as Array) and "pause" in (child.get_meta("production_inferences", []) as Array), "Variant C module hid its macro-rhythm inference.")
	_require(variants == {"LAYERED-PATIO-RECESS": 2, "OFFSET-ENTRY-PAUSE": 2, "SPLIT-GALLERY-CLUSTER": 2, "WIDE-GALLERY-ENTRY": 2}, "Variant C did not retain four-by-two macro arrangements: %s." % variants)
	_require(run_counts == {2: 2, 3: 2, 6: 1, 8: 2, 9: 1}, "Variant C placements lost their clustered/paused run rhythm: %s." % run_counts)
	_require(int(repair.get_meta("module_count", 0)) == 8 and int(repair.get_meta("module_variant_count", 0)) == 4 and int(repair.get_meta("module_box_count", 0)) > 100, "Variant C macro module count or richness drifted.")
	_require(int(repair.get_meta("upper_relief_box_count", 0)) == 20, "Variant C transfer/crown caps drifted.")
	_require(float(repair.get_meta("module_min_y_m", -INF)) >= 4.099 and float(repair.get_meta("module_max_y_m", INF)) <= 10.051, "Variant C modules escaped the live-work band.")


func _validate_zero_ownership(repair: Node3D) -> void:
	_require(_count_type(repair, CollisionObject3D) == 0 and _count_type(repair, CollisionShape3D) == 0 and _count_type(repair, NavigationRegion3D) == 0 and not _any_node_in_group(repair, "spray_receiver") and not _any_node_in_group(repair, "spray_receiver_wall"), "Variant C decorative geometry acquired collision/navigation/spray ownership.")


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _any_node_in_group(node: Node, group_name: StringName) -> bool:
	if node.is_in_group(group_name):
		return true
	for child: Node in node.get_children():
		if _any_node_in_group(child, group_name):
			return true
	return false


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("FAIL [headless_isle_house_composite_repair_variant_c_standalone_v1_contract]: %s" % message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
