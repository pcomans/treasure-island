extends SceneTree

const RegistryLoader := preload("res://game/scripts/world/facades/facade_runtime_registry_loader.gd")
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const ADAPTER_CONTRACT_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const EXPECTED_REGISTRY_SHA256 := "36eef28d1abce9d9838da6e959222ad6767e40e198b90b734496e6d2dc2cd79b"
const EXPECTED_ADAPTER_CONTRACT_SHA256 := "2064accb205c891cf7a7a09a7117be63360dee8d05f904cf31e99455368129d1"
const READY_RECEIVERS := [
	"building-composite:w1249412094:w1282547786:wall",
	"building:r16681702:wall",
	"building:w1222720021:wall",
	"building:w1249412093:wall",
	"building:w291189336:wall",
	"building:w291189926:wall",
	"building:w34313540:wall",
	"building:w34313547:wall",
]
const DISABLED_RECEIVERS := [
	"building-composite:w1249412094:w1282547787:wall",
	"building:w291196370:wall",
	"building:w34313515:wall",
	"building:w34313520:wall",
	"building:w34313525:wall",
	"building:w34313564:wall",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var baseline_nodes := get_node_count()
	var registry := _json(REGISTRY_PATH)
	var contracts := _json(ADAPTER_CONTRACT_PATH)
	if not _require(not registry.is_empty() and not contracts.is_empty(), "Generated registry/adapter contracts are missing or invalid JSON."):
		_finish()
		return
	var loader := RegistryLoader.new()
	var loaded := loader.load_default(EXPECTED_REGISTRY_SHA256)
	if not _require(bool(loaded.get("ok", false)), "Default registry load failed: %s" % str(loaded)):
		_finish()
		return
	_require(str(loaded.get("adapter_contract_sha256", "")) == EXPECTED_ADAPTER_CONTRACT_SHA256, "Loader did not return the exact adapter-contract hash.")
	_require(loader.is_loaded() and loader.get_unit_count() == 213 and loader.get_receiver_count() == 214, "Loader lookup cardinality is not 213 units / 214 receivers.")
	_validate_receiver_modes(loader)
	_validate_adapter_resolution(loader)
	var first_snapshot := JSON.stringify(loader.deterministic_snapshot())
	var second_loader := RegistryLoader.new()
	var second_loaded := second_loader.load_default(EXPECTED_REGISTRY_SHA256)
	_require(bool(second_loaded.get("ok", false)), "Second deterministic registry load failed.")
	var second_snapshot := JSON.stringify(second_loader.deterministic_snapshot())
	_require(first_snapshot == second_snapshot, "Two clean loader runs produced different lookup snapshots.")
	_require(get_node_count() == baseline_nodes, "Topology-neutral loader/resource resolution added or removed scene-tree nodes.")
	_validate_fail_closed_mutations(registry, contracts)
	if not _failed:
		print("PASS: facade runtime loader is version-pinned and topology-neutral: 213 units / 214 receivers / 6/213 reference-recognizable physical units / 14 adapter plans / 8 package-safe / 6 hard-disabled receivers / 13 unique pathless disabled projection inputs across 13 occurrences; registry %s; adapter contracts %s; snapshot %s" % [EXPECTED_REGISTRY_SHA256, EXPECTED_ADAPTER_CONTRACT_SHA256, first_snapshot.sha256_text()])
	_finish()


func _validate_receiver_modes(loader: RefCounted) -> void:
	_require(loader.get_content_mode("building-composite:w1249412094:w1282547786:wall") == "legacy_adapter", "Isle House high receiver lost legacy content mode.")
	_require(loader.get_content_mode("building-composite:w1249412094:w1282547787:wall") == "active_isle_house_variant_c", "Isle House low receiver lost active Variant C content mode.")
	var isle: Dictionary = loader.get_unit("physical-building:w1249412094")
	_require(str(isle.get("runtime_content_mode", "")) == "mixed_legacy_high_and_active_variant_c_low", "Loader collapses Isle House's accepted mixed unit state.")
	_require(loader.get_content_mode("building:r16681702:wall") == "active_building_1_hero", "Building 1 main receiver content mode drifted.")
	_require(loader.get_content_mode("building:w1222720021:wall") == "active_building_1_hero", "Building 1 tower receiver content mode drifted.")
	_require(loader.get_content_mode("building:w34313540:wall") == "active_building_3_hero", "Building 3 wall receiver content mode drifted.")
	var building_3: Dictionary = loader.get_unit("physical-building:w34313540")
	_require(str(building_3.get("runtime_content_mode", "")) == "all_receivers_active_building_3_hero", "Building 3 unit mode does not reflect its exact active receiver.")
	_require(loader.get_content_mode("building:w291189336:wall") == "active_navy_chapel_187_paired_replacement", "Navy Chapel wall receiver content mode drifted.")
	var navy_chapel: Dictionary = loader.get_unit("physical-building:w291189336")
	_require(str(navy_chapel.get("runtime_content_mode", "")) == "all_receivers_active_navy_chapel_187_paired_replacement", "Navy Chapel unit mode does not preserve paired replacement semantics.")
	var metric: Dictionary = loader.get_reference_recognition_metric()
	var accepted_ids := metric.get("accepted_physical_unit_ids", []) as Array
	var expected_ids := ["physical-building:r16681702", "physical-building:w1222720021", "physical-building:w1249412093", "physical-building:w1249412094", "physical-building:w291189336", "physical-building:w34313540"]
	accepted_ids.sort()
	expected_ids.sort()
	_require(int(metric.get("numerator", -1)) == 6 and int(metric.get("denominator", -1)) == 213 and str(metric.get("display", "")) == "6/213" and accepted_ids == expected_ids, "Loader recognition metric is not exactly the accepted 6/213 physical-unit rollup.")
	_require(metric.get("isle_house_non_numerator_source_keys", []) == ["w1282547786", "w1282547787"], "Loader promotes Isle House source parts into numerator entries.")


func _validate_adapter_resolution(loader: RefCounted) -> void:
	var ready_seen := []
	var disabled_seen := []
	for receiver_value: Variant in READY_RECEIVERS:
		var receiver_key := str(receiver_value)
		var plan: Dictionary = loader.get_adapter_plan(receiver_key)
		_require(str(plan.get("integration_state", "")) == "package_safe_ready_for_integration", "%s is not a package-safe integration plan." % receiver_key)
		if receiver_key == "building:w34313540:wall":
			var behavior := plan.get("behavior_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var collision := behavior.get("collision_contract", {}) as Dictionary
			_require(str(plan.get("content_mode", "")) == "active_building_3_hero", "Building 3 plan has stale legacy content mode.")
			_require((plan.get("runtime_assets", []) as Array).size() == 9, "Building 3 plan does not pin its complete wrapper/config/facade asset set.")
			_require(str(behavior.get("parity_status", "")) == "exact_current_behavior_and_dependency_set_verified", "Building 3 exact-current parity is not proven.")
			_require(int(geometry.get("wall_triangles", 0)) == 236 and int(geometry.get("roof_triangles", 0)) == 675 and int(geometry.get("topology_delta_triangles", 0)) == 766, "Building 3 geometry parity drifted.")
			_require(bool(collision.get("roof_landing_world_solid", false)) and str(collision.get("spray_ownership", "")) == "wall_only", "Building 3 collision/landing/spray parity drifted.")
		if receiver_key == "building:w291189336:wall":
			var behavior := plan.get("behavior_contract", {}) as Dictionary
			var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var ownership := behavior.get("ownership_contract", {}) as Dictionary
			_require(str(plan.get("content_mode", "")) == "active_navy_chapel_187_paired_replacement", "Navy Chapel plan has stale legacy content mode.")
			_require((plan.get("runtime_assets", []) as Array).size() == 9, "Navy Chapel plan does not pin its complete adapter/config/prototype/material set.")
			_require(str(acceptance.get("independent_live_review_receipt_sha256", "")) == "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9" and int(acceptance.get("numerator_effect", -1)) == 1 and bool(acceptance.get("wall_and_roof_are_one_physical_unit", false)), "Navy Chapel receipt or one-unit rollup drifted.")
			_require(str(geometry.get("visual_geometry_signature", "")) == "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46" and int(geometry.get("visual_triangles", -1)) == 540 and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 944 and int(geometry.get("world_surfaces", -1)) == 957 and int(geometry.get("world_triangles", -1)) == 64572 and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466, "Navy Chapel geometry/world parity drifted.")
			_require(str(ownership.get("live_ownership_signature", "")) == "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7" and int(ownership.get("wall_collision_triangles", -1)) == 94 and int(ownership.get("roof_collision_triangles", -1)) == 50 and bool(ownership.get("wall_is_sole_spray_receiver", false)) and ownership.get("roof_is_wall_spray_receiver") == false, "Navy Chapel collision/spray ownership parity drifted.")
		var result: Dictionary = loader.resolve_executable_assets(receiver_key)
		_require(bool(result.get("ok", false)) and result.get("instantiated") == false, "%s package-safe assets did not resolve without instantiation: %s" % [receiver_key, str(result)])
		ready_seen.append(receiver_key)
	for receiver_value: Variant in DISABLED_RECEIVERS:
		var receiver_key := str(receiver_value)
		var plan: Dictionary = loader.get_adapter_plan(receiver_key)
		_require(str(plan.get("integration_state", "")) == "hard_disabled_source_projection", "%s is not hard-disabled." % receiver_key)
		_require((plan.get("executable_assets", []) as Array).is_empty(), "%s exposes an executable asset while disabled." % receiver_key)
		if receiver_key == "building-composite:w1249412094:w1282547787:wall":
			var behavior := plan.get("behavior_contract", {}) as Dictionary
			var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var ownership := behavior.get("ownership_contract", {}) as Dictionary
			_require(str(plan.get("content_mode", "")) == "active_isle_house_variant_c" and (plan.get("runtime_assets", []) as Array).size() == 1 and (plan.get("projection_descriptor_ids", []) as Array).size() == 3, "Isle House fail-closed active plan boundary drifted.")
			_require(str(acceptance.get("independent_live_review_receipt_sha256", "")) == "37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8" and int(acceptance.get("numerator_effect", -1)) == 1, "Isle House independent acceptance receipt drifted.")
			_require(str(geometry.get("live_signature", "")) == "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981" and int(geometry.get("world_triangles", -1)) == 64572 and int(geometry.get("world_mesh_instances", -1)) == 944 and int(geometry.get("world_surfaces", -1)) == 957, "Isle House exact-current signature/topology parity drifted.")
			_require(bool(ownership.get("low_receiver_is_sole_collision_and_spray_owner", false)) and int(ownership.get("decorative_collision_nodes", -1)) == 0 and int(ownership.get("decorative_navigation_nodes", -1)) == 0 and int(ownership.get("decorative_spray_nodes", -1)) == 0, "Isle House ownership parity drifted.")
		var result: Dictionary = loader.resolve_executable_assets(receiver_key)
		_require(not bool(result.get("ok", true)) and str(result.get("error_code", "")) == "adapter_hard_disabled", "%s pathless projections were executable." % receiver_key)
		disabled_seen.append(receiver_key)
	ready_seen.sort()
	disabled_seen.sort()
	var expected_ready := READY_RECEIVERS.duplicate()
	var expected_disabled := DISABLED_RECEIVERS.duplicate()
	expected_ready.sort()
	expected_disabled.sort()
	_require(ready_seen == expected_ready and disabled_seen == expected_disabled, "Ready/disabled receiver partition drifted.")


func _validate_fail_closed_mutations(registry: Dictionary, contracts: Dictionary) -> void:
	var missing_loader := RegistryLoader.new()
	_expect_error(missing_loader.load_from_path("res://game/resources/facades/__missing_facade_registry__.json"), "registry_missing", "missing registry")
	var wrong_pin_loader := RegistryLoader.new()
	_expect_error(wrong_pin_loader.load_default("0000000000000000000000000000000000000000000000000000000000000000"), "registry_hash_drift", "hash-drifted registry pin")
	var version_registry := registry.duplicate(true)
	version_registry["schema_version"] = "ti.facade-runtime-registry/999"
	_expect_data_error(version_registry, contracts, "unknown_registry_version", "unknown registry version")
	var version_contracts := contracts.duplicate(true)
	version_contracts["schema_version"] = "ti.facade-runtime-adapter-contracts/999"
	_expect_data_error(registry, version_contracts, "unknown_adapter_contract_version", "unknown adapter-contract version")
	var future_registry := registry.duplicate(true)
	(future_registry.get("compatibility_contract", {}) as Dictionary)["loader_api_version"] = "ti.facade-runtime-registry-loader/999"
	_expect_data_error(future_registry, contracts, "unknown_registry_version", "unsupported future loader version")
	var hash_registry := registry.duplicate(true)
	var hash_adapter := (hash_registry.get("legacy_adapters", []) as Array)[0] as Dictionary
	var hash_asset := (hash_adapter.get("runtime_assets", []) as Array)[0] as Dictionary
	hash_asset["sha256"] = "0000000000000000000000000000000000000000000000000000000000000000"
	_expect_data_error(hash_registry, contracts, "runtime_asset_hash_drift", "hash-drifted runtime asset")
	var missing_asset_registry := registry.duplicate(true)
	var missing_asset_adapter := (missing_asset_registry.get("legacy_adapters", []) as Array)[0] as Dictionary
	var missing_asset := (missing_asset_adapter.get("runtime_assets", []) as Array)[0] as Dictionary
	missing_asset["path"] = "res://game/resources/facades/__missing_runtime_asset__.tres"
	_expect_data_error(missing_asset_registry, contracts, "runtime_asset_missing", "missing runtime asset")
	var dirty_contracts := contracts.duplicate(true)
	var dirty_plan := (dirty_contracts.get("plans", []) as Array).filter(func(plan: Variant) -> bool: return not (plan as Dictionary).get("executable_assets", []).is_empty())[0] as Dictionary
	var dirty_asset := (dirty_plan.get("executable_assets", []) as Array)[0] as Dictionary
	dirty_asset["path"] = "res://discovery/forbidden_adapter.gd"
	_expect_data_error(registry, dirty_contracts, "dirty_path", "dirty executable path")
	var projection_contracts := contracts.duplicate(true)
	var projection := (projection_contracts.get("projection_descriptors", []) as Array)[0] as Dictionary
	projection["path"] = "res://game/resources/facades/source-bearing.json"
	_expect_data_error(registry, projection_contracts, "projection_path_forbidden", "path smuggled into disabled projection")
	var mixed_registry := registry.duplicate(true)
	var isle := (mixed_registry.get("units", []) as Array).filter(func(unit: Variant) -> bool: return str((unit as Dictionary).get("unit_id", "")) == "physical-building:w1249412094")[0] as Dictionary
	var low := (isle.get("direct_receivers", []) as Array).filter(func(receiver: Variant) -> bool: return str((receiver as Dictionary).get("receiver_key", "")).ends_with(":w1282547787:wall"))[0] as Dictionary
	low["runtime_content_mode"] = "legacy_adapter"
	low["runtime_adapter_id"] = "legacy-adapter:building-composite:w1249412094:w1282547786:wall"
	_expect_data_error(mixed_registry, contracts, "mixed_unit_mismatch", "collapsed mixed-unit receiver state")
	var metric_registry := registry.duplicate(true)
	(metric_registry.get("recognition_metric", {}) as Dictionary)["numerator"] = 7
	(metric_registry.get("recognition_metric", {}) as Dictionary)["display"] = "7/213"
	_expect_data_error(metric_registry, contracts, "recognition_metric_mismatch", "drifted physical-unit recognition numerator")
	var receipt_registry := registry.duplicate(true)
	var accepted_isle := (receipt_registry.get("units", []) as Array).filter(func(unit: Variant) -> bool: return str((unit as Dictionary).get("unit_id", "")) == "physical-building:w1249412094")[0] as Dictionary
	var acceptance_record := (accepted_isle.get("acceptance_records", []) as Array)[0] as Dictionary
	acceptance_record["review_receipt_sha256"] = "0000000000000000000000000000000000000000000000000000000000000000"
	_expect_data_error(receipt_registry, contracts, "recognition_receipt_mismatch", "drifted Isle House acceptance receipt")
	var building_3_contracts := contracts.duplicate(true)
	var building_3_plan := (building_3_contracts.get("plans", []) as Array).filter(func(plan: Variant) -> bool: return str((plan as Dictionary).get("receiver_key", "")) == "building:w34313540:wall")[0] as Dictionary
	((building_3_plan.get("behavior_contract", {}) as Dictionary).get("collision_contract", {}) as Dictionary)["spray_ownership"] = "wall_and_roof"
	_expect_data_error(registry, building_3_contracts, "building_3_parity_mismatch", "drifted Building 3 spray ownership")
	var chapel_contracts := contracts.duplicate(true)
	var chapel_plan := (chapel_contracts.get("plans", []) as Array).filter(func(plan: Variant) -> bool: return str((plan as Dictionary).get("receiver_key", "")) == "building:w291189336:wall")[0] as Dictionary
	((chapel_plan.get("behavior_contract", {}) as Dictionary).get("ownership_contract", {}) as Dictionary)["roof_collision_triangles"] = 49
	_expect_data_error(registry, chapel_contracts, "navy_chapel_parity_mismatch", "drifted Navy Chapel roof collision partition")


func _expect_data_error(registry: Dictionary, contracts: Dictionary, expected_code: String, label: String) -> void:
	var loader := RegistryLoader.new()
	_expect_error(loader.load_from_data(registry, contracts), expected_code, label)


func _expect_error(result: Dictionary, expected_code: String, label: String) -> void:
	_require(not bool(result.get("ok", true)) and str(result.get("error_code", "")) == expected_code, "Loader accepted %s or returned the wrong error: %s" % [label, str(result)])


func _json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("FAIL [facade_runtime_registry_loader]: %s" % message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
