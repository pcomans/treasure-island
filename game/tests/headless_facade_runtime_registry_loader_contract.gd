extends SceneTree

const RegistryLoader := preload("res://game/scripts/world/facades/facade_runtime_registry_loader.gd")
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const ADAPTER_CONTRACT_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const EXPECTED_REGISTRY_SHA256 := "f727cfdc2e514ebe201f2267f978a3a9674b718a6435f409a7f42690085820e7"
const EXPECTED_ADAPTER_CONTRACT_SHA256 := "3c895baac0ebbd5ec40797adc55812a8763f72ef9e0b23d41660c89c2f0ebf69"
const READY_RECEIVERS := [
	"building-composite:w1249412094:w1282547786:wall",
	"building:r16681702:wall",
	"building:w1222720021:wall",
	"building:w1249412093:wall",
	"building:w291189336:wall",
	"building:w291189926:wall",
	"building:w34313540:wall",
	"building:w34313545:wall",
	"building:w34313547:wall",
	"building:w95934105:wall",
	"building:w95934117:wall",
	"building:w95934119:wall",
	"building:w95934144:wall",
	"building:w96215646:wall",
	"building:w95934125:wall",
	"building:w764313741:wall",
	"building:r19685981:wall",
	"building:w96215661:wall",
	"building:w96215653:wall",
	"building:w96215651:wall",
	"building:w96215649:wall",
	"building:w96215652:wall",
	"building:w96215658:wall",
	"building:w96215677:wall",
	"building:w96215680:wall",
	"building:w96215672:wall",
	"building:w96215669:wall",
	"building:w95934123:wall",
]
const DISABLED_RECEIVERS := [
	"building-composite:w1249412094:w1282547787:wall",
	"building:w291196370:wall",
	"building:w34313515:wall",
	"building:w34313520:wall",
	"building:w34313525:wall",
	"building:w34313564:wall",
]
const ACTIVE_REVIEW_STATUS_SCOPE := "runtime_asset_original_detail_provenance_only_not_reference_recognition"
const ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY := "physical_unit_claim_and_independent_acceptance_record"
const PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "pre_b201_integration_live_parity"
const PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "pre_b225_integration_live_parity"
const PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "pre_d2_1441_integration_live_parity"
const PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "pre_d2_1439_integration_live_parity"
const PRE_D2_1444_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "pre_d2_1444_integration_live_parity"
const CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "current_integration_topology"
const ACTIVE_UNIT_BY_RECEIVER := {
	"building-composite:w1249412094:w1282547787:wall": "physical-building:w1249412094",
	"building:r16681702:wall": "physical-building:r16681702",
	"building:w1222720021:wall": "physical-building:w1222720021",
	"building:w291189336:wall": "physical-building:w291189336",
	"building:w34313540:wall": "physical-building:w34313540",
	"building:w34313545:wall": "physical-building:w34313545",
	"building:w95934105:wall": "physical-building:w95934105",
	"building:w95934119:wall": "physical-building:w95934119",
	"building:w95934144:wall": "physical-building:w95934144",
	"building:w95934117:wall": "physical-building:w95934117",
	"building:w96215646:wall": "physical-building:w96215646",
	"building:w95934125:wall": "physical-building:w95934125",
	"building:w764313741:wall": "physical-building:w764313741",
	"building:r19685981:wall": "physical-building:r19685981",
	"building:w96215661:wall": "physical-building:w96215661",
	"building:w96215653:wall": "physical-building:w96215653",
	"building:w96215651:wall": "physical-building:w96215651",
	"building:w96215649:wall": "physical-building:w96215649",
	"building:w96215652:wall": "physical-building:w96215652",
	"building:w96215658:wall": "physical-building:w96215658",
	"building:w96215677:wall": "physical-building:w96215677",
	"building:w96215680:wall": "physical-building:w96215680",
	"building:w96215672:wall": "physical-building:w96215672",
	"building:w96215669:wall": "physical-building:w96215669",
	"building:w95934123:wall": "physical-building:w95934123",
}
const ACTIVE_REVIEW_STATUS_BY_RECEIVER := {
	"building-composite:w1249412094:w1282547787:wall": "independent_exact_current_live_pass",
	"building:r16681702:wall": "pending_independent_original_detail_review",
	"building:w1222720021:wall": "pending_independent_original_detail_review",
	"building:w291189336:wall": "independent_exact_current_live_pass",
	"building:w34313540:wall": "pending_independent_original_detail_review",
	"building:w34313545:wall": "independent_exact_current_live_pass",
	"building:w95934105:wall": "independent_exact_current_live_pass",
	"building:w95934119:wall": "independent_exact_current_live_pass",
	"building:w95934144:wall": "independent_exact_current_live_pass",
	"building:w95934117:wall": "independent_exact_current_live_pass",
	"building:w96215646:wall": "independent_exact_current_live_pass",
	"building:w95934125:wall": "independent_exact_current_live_pass",
	"building:w764313741:wall": "independent_exact_current_live_pass",
	"building:r19685981:wall": "independent_exact_current_live_pass",
	"building:w96215661:wall": "independent_exact_current_live_pass",
	"building:w96215653:wall": "independent_exact_current_live_pass",
	"building:w96215651:wall": "independent_exact_current_live_pass",
	"building:w96215649:wall": "independent_exact_current_live_pass",
	"building:w96215652:wall": "independent_exact_current_live_pass",
	"building:w96215658:wall": "independent_exact_current_live_pass",
	"building:w96215677:wall": "independent_exact_current_live_pass",
	"building:w96215680:wall": "independent_exact_current_live_pass",
	"building:w96215672:wall": "independent_exact_current_live_pass",
	"building:w96215669:wall": "independent_exact_current_live_pass",
	"building:w95934123:wall": "independent_exact_current_live_pass",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	RegistryLoader.begin_measurement()
	var phase_started_usec: int = Time.get_ticks_usec()
	var phase_counters: Dictionary = RegistryLoader.measurement_snapshot()
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
	_validate_active_authority_records(registry)
	_require(loader.is_loaded() and loader.get_unit_count() == 213 and loader.get_receiver_count() == 214, "Loader lookup cardinality is not 213 units / 214 receivers.")
	_require(not FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd").contains("facade_runtime_registry_loader"), "Generic facade registry loader was wired into world construction.")
	_report_measurement_phase("first_clean_load_and_authority", phase_started_usec, phase_counters)
	phase_started_usec = Time.get_ticks_usec()
	phase_counters = RegistryLoader.measurement_snapshot()
	_validate_receiver_modes(loader)
	_validate_adapter_resolution(loader)
	_report_measurement_phase("receiver_and_resource_resolution", phase_started_usec, phase_counters)
	phase_started_usec = Time.get_ticks_usec()
	phase_counters = RegistryLoader.measurement_snapshot()
	var first_snapshot := JSON.stringify(loader.deterministic_snapshot())
	var second_loader := RegistryLoader.new()
	var second_loaded := second_loader.load_default(EXPECTED_REGISTRY_SHA256)
	_require(bool(second_loaded.get("ok", false)), "Second deterministic registry load failed.")
	var second_snapshot := JSON.stringify(second_loader.deterministic_snapshot())
	_require(first_snapshot == second_snapshot, "Two clean loader runs produced different lookup snapshots.")
	_require(get_node_count() == baseline_nodes, "Topology-neutral loader/resource resolution added or removed scene-tree nodes.")
	_report_measurement_phase("second_clean_load_and_snapshots", phase_started_usec, phase_counters)
	phase_started_usec = Time.get_ticks_usec()
	phase_counters = RegistryLoader.measurement_snapshot()
	_validate_fail_closed_mutations(registry, contracts)
	_report_measurement_phase("existing_mutations", phase_started_usec, phase_counters)
	phase_started_usec = Time.get_ticks_usec()
	phase_counters = RegistryLoader.measurement_snapshot()
	_validate_d5_batch_mutations(registry, contracts)
	_report_measurement_phase("fifteen_target_mutations", phase_started_usec, phase_counters)
	phase_started_usec = Time.get_ticks_usec()
	phase_counters = RegistryLoader.measurement_snapshot()
	if not _failed:
		print("PASS: facade runtime loader is version-pinned and topology-neutral: 213 units / 214 receivers / 26/213 reference-recognizable physical units / 34 adapter plans / 28 package-safe / 6 hard-disabled receivers / 13 unique pathless disabled projection inputs across 13 occurrences; registry %s; adapter contracts %s; snapshot %s" % [EXPECTED_REGISTRY_SHA256, EXPECTED_ADAPTER_CONTRACT_SHA256, first_snapshot.sha256_text()])
	print("FACADE_LOADER_MEASUREMENT_TOTAL: " + JSON.stringify(RegistryLoader.end_measurement()))
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
	_require(loader.get_content_mode("building:w34313545:wall") == "active_d1_b201_host_partition_attachment", "D1 B201 wall receiver content mode drifted.")
	var d1_b201: Dictionary = loader.get_unit("physical-building:w34313545")
	_require(str(d1_b201.get("runtime_content_mode", "")) == "all_receivers_active_d1_b201_host_partition_attachment", "D1 B201 unit mode does not preserve host-partition semantics.")
	_require(loader.get_content_mode("building:w95934119:wall") == "active_d1_b225_host_partition_attachment", "D1 B225 wall receiver content mode drifted.")
	var d1_b225: Dictionary = loader.get_unit("physical-building:w95934119")
	_require(str(d1_b225.get("runtime_content_mode", "")) == "all_receivers_active_d1_b225_host_partition_attachment", "D1 B225 unit mode does not preserve host-partition semantics.")
	_require(loader.get_content_mode("building:w95934105:wall") == "active_d2_1441_paired_replacement", "D2 1441 wall receiver content mode drifted.")
	var d2_1441: Dictionary = loader.get_unit("physical-building:w95934105")
	_require(str(d2_1441.get("runtime_content_mode", "")) == "all_receivers_active_d2_1441_paired_replacement", "D2 1441 unit mode does not preserve paired replacement semantics.")
	_require(loader.get_content_mode("building:w95934144:wall") == "active_d2_1439_paired_replacement" and str((loader.get_unit("physical-building:w95934144") as Dictionary).get("runtime_content_mode", "")) == "all_receivers_active_d2_1439_paired_replacement", "D2 1439 one wall-indexed paired unit mode drifted.")
	_require(loader.get_content_mode("building:w95934117:wall") == "active_d2_1444_paired_replacement" and str((loader.get_unit("physical-building:w95934117") as Dictionary).get("runtime_content_mode", "")) == "all_receivers_active_d2_1444_paired_replacement", "D2 1444 one wall-indexed paired unit mode drifted.")
	var metric: Dictionary = loader.get_reference_recognition_metric()
	var accepted_ids := metric.get("accepted_physical_unit_ids", []) as Array
	var expected_ids := ["physical-building:r16681702", "physical-building:r19685981", "physical-building:w96215651", "physical-building:w96215653", "physical-building:w96215661", "physical-building:w96215658", "physical-building:w96215652", "physical-building:w96215649", "physical-building:w96215680", "physical-building:w96215677", "physical-building:w96215669", "physical-building:w96215672", "physical-building:w1222720021", "physical-building:w1249412093", "physical-building:w1249412094", "physical-building:w291189336", "physical-building:w34313540", "physical-building:w34313545", "physical-building:w95934105", "physical-building:w95934117", "physical-building:w95934119", "physical-building:w95934144", "physical-building:w95934123", "physical-building:w96215646", "physical-building:w95934125", "physical-building:w764313741"]
	accepted_ids.sort()
	expected_ids.sort()
	_require(int(metric.get("numerator", -1)) == 26 and int(metric.get("denominator", -1)) == 213 and str(metric.get("display", "")) == "26/213" and accepted_ids == expected_ids, "Loader recognition metric is not exactly the accepted 26/213 physical-unit rollup.")
	_require(metric.get("isle_house_non_numerator_source_keys", []) == ["w1282547786", "w1282547787"], "Loader promotes Isle House source parts into numerator entries.")


func _validate_active_authority_records(registry: Dictionary) -> void:
	var units := registry.get("units", []) as Array
	var adapters := registry.get("active_runtime_adapters", []) as Array
	_require(adapters.size() == ACTIVE_UNIT_BY_RECEIVER.size(), "Active recognition-authority adapter count drifted.")
	for adapter_value: Variant in adapters:
		var adapter := adapter_value as Dictionary
		var receiver_key := str(adapter.get("receiver_key", ""))
		var unit_id := str(ACTIVE_UNIT_BY_RECEIVER.get(receiver_key, ""))
		var unit := _unit_by_id(units, unit_id)
		var receiver := _receiver_by_key(unit.get("direct_receivers", []) as Array, receiver_key)
		var claim_status := unit.get("claim_status", {}) as Dictionary
		var receipts := unit.get("acceptance_records", []) as Array
		var accepted_receipt := receipts.size() == 1 \
			and str((receipts[0] as Dictionary).get("review_kind", "")) == "independent_reference_recognition" \
			and str((receipts[0] as Dictionary).get("status", "")) == "accept"
		_require(not unit.is_empty() and not receiver.is_empty(), "%s does not cross-link to its exact physical unit." % receiver_key)
		_require(str(adapter.get("review_status", "")) == str(ACTIVE_REVIEW_STATUS_BY_RECEIVER.get(receiver_key, "")), "%s review status is not an exact allowed provenance literal." % receiver_key)
		_require(str(adapter.get("review_status_scope", "")) == ACTIVE_REVIEW_STATUS_SCOPE, "%s review-status scope drifted." % receiver_key)
		_require(str(adapter.get("recognition_acceptance_authority", "")) == ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY, "%s recognition authority drifted." % receiver_key)
		_require(str(adapter.get("recognition_acceptance_status", "")) == "accepted" and str(adapter.get("recognition_acceptance_status", "")) == str(claim_status.get("reference_recognizable", "")), "%s recognition status is not derived from its physical unit." % receiver_key)
		_require(accepted_receipt, "%s physical unit lacks its independent recognition receipt." % receiver_key)
		if receiver_key == "building:w95934119:wall" and receipts.size() == 1:
			var b225_receipt := receipts[0] as Dictionary
			_require(str(b225_receipt.get("capture_time_recognition_metric", "")) == "7/213" and int(b225_receipt.get("numerator_effect", -1)) == 1, "D1 B225 capture-time metric or numerator effect drifted.")
			_require(str(b225_receipt.get("evidence_manifest_sha256", "")) == "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc" and str(b225_receipt.get("evidence_tree_sha256", "")) == "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7" and str(b225_receipt.get("review_receipt_sha256", "")) == "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95", "D1 B225 frozen evidence or independent review receipt drifted.")
		if receiver_key == "building:w95934105:wall" and receipts.size() == 1:
			var d2_receipt := receipts[0] as Dictionary
			_require(str(d2_receipt.get("capture_time_recognition_metric", "")) == "8/213" and int(d2_receipt.get("numerator_effect", -1)) == 1, "D2 1441 capture-time metric or one-unit effect drifted.")
			_require(str(d2_receipt.get("evidence_manifest_sha256", "")) == "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885" and str(d2_receipt.get("motion_telemetry_manifest_sha256", "")) == "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd" and str(d2_receipt.get("visual_motion_manifest_sha256", "")) == "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad", "D2 1441 frozen static/telemetry/visual manifests drifted.")
			_require(str(d2_receipt.get("evidence_tree_sha256", "")) == "e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43" and str(d2_receipt.get("package_verification_receipt_sha256", "")) == "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061", "D2 1441 frozen evidence tree or package receipt drifted.")
			_require(str(d2_receipt.get("mechanical_review_receipt_sha256", "")) == "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884" and str(d2_receipt.get("review_receipt_sha256", "")) == "075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144", "D2 1441 independent mechanical or visual review drifted.")


func _validate_adapter_resolution(loader: RefCounted) -> void:
	var ready_seen := []
	var disabled_seen := []
	var current_topology_plan_ids := []
	for receiver_value: Variant in READY_RECEIVERS:
		var receiver_key := str(receiver_value)
		var plan: Dictionary = loader.get_adapter_plan(receiver_key)
		var topology_behavior_value: Variant = plan.get("behavior_contract", {})
		var topology_behavior := topology_behavior_value as Dictionary if topology_behavior_value is Dictionary else {}
		var topology_geometry := topology_behavior.get("geometry_contract", {}) as Dictionary
		if str(topology_geometry.get("world_topology_scope", "")) == CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE:
			current_topology_plan_ids.append(str(plan.get("adapter_id", "")))
		_require(str(plan.get("integration_state", "")) == "package_safe_ready_for_integration", "%s is not a package-safe integration plan." % receiver_key)
		if receiver_key in ["building:r16681702:wall", "building:w1222720021:wall"]:
			var b1_assets := plan.get("runtime_assets", []) as Array
			_require(b1_assets.size() == 11 and _has_asset(b1_assets, "res://game/resources/facades/building_1_public_front_believability.json", "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb"), "%s omits the exact current public-front config from its 11-asset closure." % receiver_key)
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
			_require(str(geometry.get("world_topology_scope", "")) == PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE and str(geometry.get("visual_geometry_signature", "")) == "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46" and int(geometry.get("visual_triangles", -1)) == 540 and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 944 and int(geometry.get("world_surfaces", -1)) == 957 and int(geometry.get("world_triangles", -1)) == 64572 and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466, "Navy Chapel pre-B201 integration geometry/world parity drifted.")
			_require(str(ownership.get("live_ownership_signature", "")) == "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7" and int(ownership.get("wall_collision_triangles", -1)) == 94 and int(ownership.get("roof_collision_triangles", -1)) == 50 and bool(ownership.get("wall_is_sole_spray_receiver", false)) and ownership.get("roof_is_wall_spray_receiver") == false, "Navy Chapel collision/spray ownership parity drifted.")
		if receiver_key == "building:w34313545:wall":
			var behavior := plan.get("behavior_contract", {}) as Dictionary
			var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var ownership := behavior.get("ownership_contract", {}) as Dictionary
			var actual_paths := []
			for asset_value: Variant in plan.get("runtime_assets", []) as Array:
				actual_paths.append(str((asset_value as Dictionary).get("path", "")))
			actual_paths.sort()
			var expected_paths := [
				"res://game/resources/facades/d1_current/d1_b201_live_attachment.json",
				"res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres",
				"res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres",
				"res://game/resources/materials/world/d1_current/b201_service_leaf.tres",
				"res://game/resources/materials/world/d1_current/b201_warm_wall.tres",
				"res://game/resources/materials/world/d1_current/shared_dark_glass.tres",
				"res://game/resources/materials/world/d1_current/shared_pale_frame.tres",
				"res://game/scripts/world/facades/d1_b201_live_attachment.gd",
			]
			expected_paths.sort()
			_require(str(plan.get("content_mode", "")) == "active_d1_b201_host_partition_attachment", "D1 B201 plan has stale content mode.")
			_require(actual_paths == expected_paths and (plan.get("runtime_assets", []) as Array).size() == 8 and (plan.get("projection_descriptor_ids", []) as Array).is_empty(), "D1 B201 plan does not pin its exact eight-asset package-safe closure.")
			var executable := plan.get("executable_assets", []) as Array
			_require(executable.size() == 1 and str((executable[0] as Dictionary).get("path", "")) == "res://game/scripts/world/facades/d1_b201_live_attachment.gd", "D1 B201 executable subset drifted.")
			_require(str(acceptance.get("independent_live_review_receipt_sha256", "")) == "b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772" and str(acceptance.get("evidence_manifest_sha256", "")) == "f169085620a0a9ff0c685e4dfa98442c5c31e4e580f1decdbd80e84b09c74fe3" and int(acceptance.get("numerator_effect", -1)) == 1, "D1 B201 receipt or one-unit rollup drifted.")
			_require(str(geometry.get("decorative_geometry_signature", "")) == "705c5345509f77cd91359f66173fff0e1e132d41ebb9acef3f51ff2c467abb3a" and int(geometry.get("host_triangles", -1)) == 80 and int(geometry.get("eligible_host_triangles", -1)) == 20 and int(geometry.get("protected_host_triangles", -1)) == 60 and int(geometry.get("decorative_triangles", -1)) == 2064, "D1 B201 host partition or decorative geometry parity drifted.")
			_require(str(geometry.get("world_topology_scope", "")) == PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 950 and int(geometry.get("world_surfaces", -1)) == 964 and int(geometry.get("world_triangles", -1)) == 66636 and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466, "D1 B201 pre-B225 integration world topology drifted.")
			_require(bool(ownership.get("host_collision_owner_preserved", false)) and bool(ownership.get("host_spray_owner_preserved", false)) and int(ownership.get("structural_owner_count", -1)) == 1 and int(ownership.get("shape_count", -1)) == 1 and int(ownership.get("spray_owner_count", -1)) == 1 and int(ownership.get("decorative_collision_nodes", -1)) == 0 and int(ownership.get("decorative_navigation_nodes", -1)) == 0 and int(ownership.get("decorative_spray_nodes", -1)) == 0, "D1 B201 collision/navigation/spray ownership parity drifted.")
		if receiver_key == "building:w95934119:wall":
			var behavior := plan.get("behavior_contract", {}) as Dictionary
			var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var ownership := behavior.get("ownership_contract", {}) as Dictionary
			var replacement := behavior.get("replacement_contract", {}) as Dictionary
			var actual_paths := []
			for asset_value: Variant in plan.get("runtime_assets", []) as Array:
				actual_paths.append(str((asset_value as Dictionary).get("path", "")))
			actual_paths.sort()
			var expected_paths := [
				"res://game/resources/facades/d1_current/d1_b225_live_attachment.json",
				"res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres",
				"res://game/resources/materials/world/d1_current/shared_dark_glass.tres",
				"res://game/resources/materials/world/d1_current/shared_pale_frame.tres",
				"res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png",
				"res://game/scripts/world/facades/d1_b225_live_attachment.gd",
			]
			expected_paths.sort()
			_require(str(plan.get("adapter_id", "")) == "active-adapter:d1-b225-live:building:w95934119:wall" and str(plan.get("content_mode", "")) == "active_d1_b225_host_partition_attachment", "D1 B225 plan authority classification drifted.")
			_require(actual_paths == expected_paths and (plan.get("runtime_assets", []) as Array).size() == 6 and (plan.get("projection_descriptor_ids", []) as Array).is_empty(), "D1 B225 plan does not pin its exact six-asset package-safe closure.")
			var executable := plan.get("executable_assets", []) as Array
			_require(executable.size() == 1 and str((executable[0] as Dictionary).get("path", "")) == "res://game/scripts/world/facades/d1_b225_live_attachment.gd" and str((executable[0] as Dictionary).get("sha256", "")) == "4b1defd92a77b23de692437f044dfaa579fa2ee5b3dee77465ec8404f1644ac9", "D1 B225 executable subset drifted.")
			_require(str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w95934119" and str(acceptance.get("capture_time_recognition_metric", "")) == "7/213" and str(acceptance.get("evidence_manifest_sha256", "")) == "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc" and str(acceptance.get("evidence_tree_sha256", "")) == "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7" and str(acceptance.get("independent_live_review_receipt_sha256", "")) == "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95" and int(acceptance.get("numerator_effect", -1)) == 1, "D1 B225 frozen receipt authority or one-unit rollup drifted.")
			_require(str(geometry.get("decorative_geometry_signature", "")) == "02bd8542dea7aa13041728a5244ec962fa121972db17ecf55fad03b3139fe418" and int(geometry.get("host_triangles", -1)) == 28 and int(geometry.get("eligible_host_triangles", -1)) == 8 and int(geometry.get("protected_host_triangles", -1)) == 20 and int(geometry.get("decorative_mesh_instances", -1)) == 2 and int(geometry.get("decorative_surfaces", -1)) == 2 and int(geometry.get("decorative_triangles", -1)) == 1080, "D1 B225 host partition or decorative geometry parity drifted.")
			_require(str(geometry.get("world_topology_scope", "")) == PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 952 and int(geometry.get("world_surfaces", -1)) == 967 and int(geometry.get("world_triangles", -1)) == 67716 and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466, "D1 B225 pre-D2 integration world topology drifted.")
			_require(_int_array_matches(replacement.get("eligible_run_indices", []) as Array, [10, 11, 12, 13]) and _int_array_matches(replacement.get("protected_run_indices", []) as Array, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]), "D1 B225 eligible/protected host partition drifted.")
			_require(bool(ownership.get("host_collision_owner_preserved", false)) and bool(ownership.get("host_spray_owner_preserved", false)) and int(ownership.get("structural_owner_count", -1)) == 1 and int(ownership.get("shape_count", -1)) == 1 and int(ownership.get("spray_owner_count", -1)) == 1 and int(ownership.get("decorative_collision_nodes", -1)) == 0 and int(ownership.get("decorative_navigation_nodes", -1)) == 0 and int(ownership.get("decorative_spray_nodes", -1)) == 0, "D1 B225 collision/navigation/spray ownership parity drifted.")
		if receiver_key == "building:w95934105:wall":
			_validate_d2_1441_plan(plan)
		var result: Dictionary = loader.resolve_executable_assets(receiver_key)
		_require(bool(result.get("ok", false)) and result.get("instantiated") == false, "%s package-safe assets did not resolve without instantiation: %s" % [receiver_key, str(result)])
		ready_seen.append(receiver_key)
	for receiver_value: Variant in DISABLED_RECEIVERS:
		var receiver_key := str(receiver_value)
		var plan: Dictionary = loader.get_adapter_plan(receiver_key)
		var topology_behavior_value: Variant = plan.get("behavior_contract", {})
		var topology_behavior := topology_behavior_value as Dictionary if topology_behavior_value is Dictionary else {}
		var topology_geometry := topology_behavior.get("geometry_contract", {}) as Dictionary
		if str(topology_geometry.get("world_topology_scope", "")) == CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE:
			current_topology_plan_ids.append(str(plan.get("adapter_id", "")))
		_require(str(plan.get("integration_state", "")) == "hard_disabled_source_projection", "%s is not hard-disabled." % receiver_key)
		_require((plan.get("executable_assets", []) as Array).is_empty(), "%s exposes an executable asset while disabled." % receiver_key)
		if receiver_key == "building-composite:w1249412094:w1282547787:wall":
			var behavior := plan.get("behavior_contract", {}) as Dictionary
			var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var ownership := behavior.get("ownership_contract", {}) as Dictionary
			_require(str(plan.get("content_mode", "")) == "active_isle_house_variant_c" and (plan.get("runtime_assets", []) as Array).size() == 1 and (plan.get("projection_descriptor_ids", []) as Array).size() == 3, "Isle House fail-closed active plan boundary drifted.")
			_require(str(acceptance.get("independent_live_review_receipt_sha256", "")) == "37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8" and int(acceptance.get("numerator_effect", -1)) == 1, "Isle House independent acceptance receipt drifted.")
			_require(str(geometry.get("world_topology_scope", "")) == PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE and str(geometry.get("live_signature", "")) == "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981" and int(geometry.get("world_triangles", -1)) == 64572 and int(geometry.get("world_mesh_instances", -1)) == 944 and int(geometry.get("world_surfaces", -1)) == 957, "Isle House pre-B201 integration signature/topology parity drifted.")
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
	_require(current_topology_plan_ids == ["active-adapter:mariner-1202-live:building:w96215651:wall"], "1202 is not the sole current-integration topology plan authority.")


func _validate_d2_1441_plan(plan: Dictionary) -> void:
	var behavior := plan.get("behavior_contract", {}) as Dictionary
	var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	var ownership := behavior.get("ownership_contract", {}) as Dictionary
	var replacement := behavior.get("replacement_contract", {}) as Dictionary
	var truth := behavior.get("truth_boundary", {}) as Dictionary
	var assets := plan.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := [
		"res://game/resources/facades/d2_1441_chinook_live_replacement.json",
		"res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json",
		"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
		"res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
		"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
		"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
		"res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
		"res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
		"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
		"res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png",
		"res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd",
		"res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd",
		"res://game/scripts/world/facades/site_12_housing_kit.gd",
	]
	expected_paths.sort()
	_require(
		str(plan.get("adapter_id", "")) == "active-adapter:d2-1441-live:building:w95934105:wall"
		and str(plan.get("receiver_key", "")) == "building:w95934105:wall"
		and str(plan.get("source_key", "")) == "w95934105"
		and str(plan.get("content_mode", "")) == "active_d2_1441_paired_replacement"
		and str(plan.get("integration_state", "")) == "package_safe_ready_for_integration"
		and str(plan.get("resolution_policy", "")) == "resolve_only_without_instantiation"
		and plan.get("disabled_reason_code") == null
		and (plan.get("projection_descriptor_ids", []) as Array).is_empty(),
		"D2 1441 package-safe paired plan identity or state drifted.",
	)
	_require(actual_paths == expected_paths and assets.size() == 13, "D2 1441 plan does not pin its exact 13-asset package-safe closure.")
	var executable := plan.get("executable_assets", []) as Array
	_require(
		executable.size() == 3
		and _has_asset(executable, "res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd", "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1")
		and _has_asset(executable, "res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd", "6c0bf201bbb38a424453f753471cb7cb8060d0323e2386a9fda3bad84acd5933")
		and _has_asset(executable, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"),
		"D2 1441 exact three-script executable subset drifted.",
	)
	_require(
		str(behavior.get("schema_version", "")) == "ti.d2-1441-production-live-parity/1"
		and str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w95934105"
		and str(acceptance.get("capture_time_recognition_metric", "")) == "8/213"
		and str(acceptance.get("evidence_manifest_sha256", "")) == "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885"
		and str(acceptance.get("motion_telemetry_manifest_sha256", "")) == "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd"
		and str(acceptance.get("visual_motion_manifest_sha256", "")) == "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad"
		and str(acceptance.get("evidence_tree_sha256", "")) == "e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43"
		and str(acceptance.get("package_verification_receipt_sha256", "")) == "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061"
		and str(acceptance.get("mechanical_review_receipt_sha256", "")) == "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884"
		and str(acceptance.get("independent_live_review_receipt_sha256", "")) == "075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144"
		and int(acceptance.get("numerator_effect", -1)) == 1
		and bool(acceptance.get("reference_recognizable", false))
		and bool(acceptance.get("wall_and_roof_are_one_physical_unit", false)),
		"D2 1441 single-record seven-receipt capture-time 8/213 and +1 plan authority drifted.",
	)
	_require(
		str(geometry.get("canonical_wall_record_sha256", "")) == "00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c"
		and str(geometry.get("canonical_roof_record_sha256", "")) == "e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55"
		and bool(geometry.get("horizontal_source_footprint_preserved", false))
		and str(geometry.get("visual_geometry_signature", "")) == "b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195"
		and int(geometry.get("visual_mesh_instances", -1)) == 9
		and int(geometry.get("visual_surfaces", -1)) == 9
		and int(geometry.get("visual_triangles", -1)) == 1578
		and int(geometry.get("topology_delta_records", -1)) == 0
		and int(geometry.get("topology_delta_mesh_instances", -1)) == 7
		and int(geometry.get("topology_delta_surfaces", -1)) == 7
		and int(geometry.get("topology_delta_triangles", -1)) == 1536
		and int(geometry.get("topology_delta_static_bodies", -1)) == 0
		and int(geometry.get("topology_delta_shapes", -1)) == 0
		and str(geometry.get("world_topology_scope", "")) == PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE
		and int(geometry.get("world_records", -1)) == 735
		and int(geometry.get("world_mesh_instances", -1)) == 959
		and int(geometry.get("world_surfaces", -1)) == 974
		and int(geometry.get("world_triangles", -1)) == 70692
		and int(geometry.get("world_static_bodies", -1)) == 466
		and int(geometry.get("world_shapes", -1)) == 466,
		"D2 1441 plan visual/delta/current-world topology drifted.",
	)
	_require(
		str(ownership.get("live_ownership_signature", "")) == "fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d"
		and int(ownership.get("structural_owner_count", -1)) == 2
		and int(ownership.get("shape_count", -1)) == 2
		and int(ownership.get("spray_owner_count", -1)) == 1
		and int(ownership.get("navigation_owner_count", -1)) == 0
		and int(ownership.get("wall_collision_triangles", -1)) == 32
		and int(ownership.get("roof_collision_triangles", -1)) == 10
		and int(ownership.get("decorative_relief_triangles", -1)) == 1536
		and int(ownership.get("decorative_collision_triangles", -1)) == 0
		and int(ownership.get("decorative_navigation_nodes", -1)) == 0
		and bool(ownership.get("wall_is_sole_spray_receiver", false))
		and ownership.get("roof_is_wall_spray_receiver") == false
		and bool(ownership.get("roof_world_solid_landing", false)),
		"D2 1441 plan collision/spray/navigation/landing ownership drifted.",
	)
	_require(
		str(replacement.get("source_key", "")) == "w95934105"
		and str(replacement.get("wall_object_key", "")) == "building:w95934105:wall"
		and str(replacement.get("roof_object_key", "")) == "building:w95934105:roof"
		and _int_array_matches(replacement.get("mapped_public_run_indices", []) as Array, [10, 12, 13, 15])
		and _int_array_matches(replacement.get("protected_run_indices", []) as Array, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14])
		and bool(replacement.get("actual_supplied_chunk_pair_required", false))
		and replacement.get("fallback_allowed") == false
		and replacement.get("generic_stack_allowed") == false
		and replacement.get("partial_pair_allowed") == false,
		"D2 1441 plan mapped/protected paired replacement boundary drifted.",
	)
	_require(
		truth.get("as_built_fidelity_claimed") == false
		and truth.get("capture_time_candidate_promoted") == false
		and truth.get("capture_time_recognition_credit") == false
		and truth.get("game_distinctive_claimed") == false
		and truth.get("reference_pixels_packaged") == false
		and truth.get("receiver_complete_inferred_from_art") == false
		and bool(truth.get("unsurveyed_opening_roof_void_rail_dimensions_and_counts_are_production_inference", false))
		and bool(truth.get("unobserved_sides_protected", false)),
		"D2 1441 plan capture-time no-credit/inference truth boundary drifted.",
	)


func _has_asset(assets: Array, path: String, sha256: String) -> bool:
	for value: Variant in assets:
		var asset := value as Dictionary
		if str(asset.get("path", "")) == path and str(asset.get("sha256", "")) == sha256:
			return true
	return false


func _validate_fail_closed_mutations(registry: Dictionary, contracts: Dictionary) -> void:
	var baseline_loader := RegistryLoader.new()
	var baseline_result := baseline_loader.load_from_data(registry.duplicate(true), contracts.duplicate(true))
	_require(bool(baseline_result.get("ok", false)), "Unchanged registry/contracts negative control did not remain valid: %s" % str(baseline_result))
	_require(not _error_matches(baseline_result, "recognition_metric_mismatch"), "No-op registry/contracts negative control falsely matched a mutation error.")
	var missing_loader := RegistryLoader.new()
	_expect_error(missing_loader.load_from_path("res://game/resources/facades/__missing_facade_registry__.json"), "registry_missing", "missing registry")
	var wrong_pin_loader := RegistryLoader.new()
	_expect_error(wrong_pin_loader.load_default("0000000000000000000000000000000000000000000000000000000000000000"), "registry_hash_drift", "hash-drifted registry pin")
	var version_registry := registry.duplicate(true)
	version_registry["schema_version"] = "ti.facade-runtime-registry/1099"
	_expect_data_error(version_registry, contracts, "unknown_registry_version", "unknown registry version")
	var version_contracts := contracts.duplicate(true)
	version_contracts["schema_version"] = "ti.facade-runtime-adapter-contracts/999"
	_expect_data_error(registry, version_contracts, "unknown_adapter_contract_version", "unknown adapter-contract version")
	var future_registry := registry.duplicate(true)
	(future_registry.get("compatibility_contract", {}) as Dictionary)["loader_api_version"] = "ti.facade-runtime-registry-loader/999"
	_expect_data_error(future_registry, contracts, "unknown_registry_version", "unsupported future loader version")
	var old_registry := registry.duplicate(true)
	old_registry["schema_version"] = "ti.facade-runtime-registry/7"
	(old_registry.get("build_contract", {}) as Dictionary)["compiler_version"] = "1.6.0"
	var old_compatibility := old_registry.get("compatibility_contract", {}) as Dictionary
	old_compatibility["catalog_schema_version"] = "ti.facade-recognition-catalog/7"
	old_compatibility["compiler_version"] = "1.6.0"
	old_compatibility["loader_api_version"] = "ti.facade-runtime-registry-loader/6"
	_require(old_registry != registry, "Superseded runtime v7 negative control was a no-op.")
	_expect_data_error(old_registry, contracts, "unknown_registry_version", "newly superseded runtime registry version 7")
	var old_contracts := contracts.duplicate(true)
	old_contracts["schema_version"] = "ti.facade-runtime-adapter-contracts/6"
	(old_contracts.get("build_contract", {}) as Dictionary)["compiler_version"] = "1.6.0"
	(old_contracts.get("build_contract", {}) as Dictionary)["runtime_registry_schema_version"] = "ti.facade-runtime-registry/7"
	(old_contracts.get("loader_contract", {}) as Dictionary)["api_version"] = "ti.facade-runtime-registry-loader/6"
	_require(old_contracts != contracts, "Superseded adapter-contract v6 negative control was a no-op.")
	_expect_data_error(registry, old_contracts, "unknown_adapter_contract_version", "newly superseded adapter-contract version 6")
	var omitted_registry := registry.duplicate(true)
	var omitted_contracts := contracts.duplicate(true)
	for adapter_value: Variant in omitted_registry.get("active_runtime_adapters", []) as Array:
		var adapter := adapter_value as Dictionary
		if str(adapter.get("receiver_key", "")) in ["building:r16681702:wall", "building:w1222720021:wall"]:
			_remove_runtime_asset(adapter.get("runtime_assets", []) as Array, "res://game/resources/facades/building_1_public_front_believability.json")
			(adapter.get("active_runtime_contract", {}) as Dictionary).erase("public_front_config_sha256")
	for plan_value: Variant in omitted_contracts.get("plans", []) as Array:
		var plan := plan_value as Dictionary
		if str(plan.get("receiver_key", "")) in ["building:r16681702:wall", "building:w1222720021:wall"]:
			_remove_runtime_asset(plan.get("runtime_assets", []) as Array, "res://game/resources/facades/building_1_public_front_believability.json")
	_expect_data_error(omitted_registry, omitted_contracts, "building_1_closure_mismatch", "coordinated Building 1 public-front omission")
	var substituted_registry := registry.duplicate(true)
	var substituted_adapter := (substituted_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:r16681702:wall")[0] as Dictionary
	var substituted_assets := substituted_adapter.get("runtime_assets", []) as Array
	var public_index := _runtime_asset_index(substituted_assets, "res://game/resources/facades/building_1_public_front_believability.json")
	substituted_assets[public_index] = (substituted_assets[2] as Dictionary).duplicate(true)
	_expect_data_error(substituted_registry, contracts, "building_1_closure_mismatch", "substituted Building 1 public-front dependency")
	var non_public_substitution := registry.duplicate(true)
	var non_public_adapter := (non_public_substitution.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:r16681702:wall")[0] as Dictionary
	var non_public_assets := non_public_adapter.get("runtime_assets", []) as Array
	var bronze_index := _runtime_asset_index(non_public_assets, "res://game/resources/materials/world/building_1/building_1_bronze.tres")
	var glass_index := _runtime_asset_index(non_public_assets, "res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres")
	non_public_assets[bronze_index] = (non_public_assets[glass_index] as Dictionary).duplicate(true)
	_expect_data_error(non_public_substitution, contracts, "building_1_closure_mismatch", "substituted Building 1 non-public dependency")
	var swapped_sources := registry.duplicate(true)
	var swapped_main := (swapped_sources.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:r16681702:wall")[0] as Dictionary
	var swapped_tower := (swapped_sources.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w1222720021:wall")[0] as Dictionary
	var original_main_source := str(swapped_main.get("source_key", ""))
	swapped_main["source_key"] = swapped_tower.get("source_key")
	swapped_tower["source_key"] = original_main_source
	_expect_data_error(swapped_sources, contracts, "building_1_closure_mismatch", "swapped Building 1/tower source mappings")
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
	_require(metric_registry != registry, "Recognition-metric negative control was a no-op.")
	_expect_data_error(metric_registry, contracts, "recognition_metric_mismatch", "drifted physical-unit recognition numerator")
	var missing_scope_registry := registry.duplicate(true)
	var missing_scope_adapter := (missing_scope_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:r16681702:wall")[0] as Dictionary
	missing_scope_adapter.erase("review_status_scope")
	_require(missing_scope_registry != registry and not missing_scope_adapter.has("review_status_scope"), "Active review-status-scope omission negative control was a no-op.")
	_expect_data_error(missing_scope_registry, contracts, "recognition_authority_mismatch", "same-version active-adapter review-status-scope omission")
	var wrong_scope_registry := registry.duplicate(true)
	var wrong_scope_adapter := (wrong_scope_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:r16681702:wall")[0] as Dictionary
	wrong_scope_adapter["review_status_scope"] = "reference_recognition_pending"
	_require(wrong_scope_registry != registry and str(wrong_scope_adapter.get("review_status_scope", "")) != ACTIVE_REVIEW_STATUS_SCOPE, "Active review-status-scope mutation negative control was a no-op.")
	_expect_data_error(wrong_scope_registry, contracts, "recognition_authority_mismatch", "same-version active-adapter review-status-scope mutation")
	var wrong_authority_registry := registry.duplicate(true)
	var wrong_authority_adapter := (wrong_authority_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w34313545:wall")[0] as Dictionary
	wrong_authority_adapter["recognition_acceptance_authority"] = "runtime_adapter_self_assertion"
	_require(wrong_authority_registry != registry and str(wrong_authority_adapter.get("recognition_acceptance_authority", "")) != ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY, "Active recognition-authority mutation negative control was a no-op.")
	_expect_data_error(wrong_authority_registry, contracts, "recognition_authority_mismatch", "same-version active-adapter recognition-authority mutation")
	var wrong_status_registry := registry.duplicate(true)
	var wrong_status_adapter := (wrong_status_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w34313545:wall")[0] as Dictionary
	wrong_status_adapter["recognition_acceptance_status"] = "not_evaluated"
	_require(wrong_status_registry != registry and str(wrong_status_adapter.get("recognition_acceptance_status", "")) != "accepted", "Active recognition-status mutation negative control was a no-op.")
	_expect_data_error(wrong_status_registry, contracts, "recognition_authority_mismatch", "same-version active-adapter duplicated recognition-status mutation")
	var wrong_review_status_registry := registry.duplicate(true)
	var wrong_review_status_adapter := (wrong_review_status_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:r16681702:wall")[0] as Dictionary
	wrong_review_status_adapter["review_status"] = "independent_exact_current_live_pass"
	_require(wrong_review_status_registry != registry and str(wrong_review_status_adapter.get("review_status", "")) != str(ACTIVE_REVIEW_STATUS_BY_RECEIVER["building:r16681702:wall"]), "Active review-status mutation negative control was a no-op.")
	_expect_data_error(wrong_review_status_registry, contracts, "recognition_authority_mismatch", "same-version active-adapter provenance-status mutation")
	var missing_receipt_registry := registry.duplicate(true)
	var missing_receipt_unit := (missing_receipt_registry.get("units", []) as Array).filter(func(unit: Variant) -> bool: return str((unit as Dictionary).get("unit_id", "")) == "physical-building:w34313545")[0] as Dictionary
	(missing_receipt_unit.get("acceptance_records", []) as Array).clear()
	_require(missing_receipt_registry != registry and (missing_receipt_unit.get("acceptance_records", []) as Array).is_empty(), "Active-unit receipt omission negative control was a no-op.")
	_expect_data_error(missing_receipt_registry, contracts, "recognition_receipt_mismatch", "same-version active-unit acceptance-receipt omission")
	var non_accept_receipt_registry := registry.duplicate(true)
	var non_accept_receipt_unit := (non_accept_receipt_registry.get("units", []) as Array).filter(func(unit: Variant) -> bool: return str((unit as Dictionary).get("unit_id", "")) == "physical-building:w34313545")[0] as Dictionary
	var non_accept_record := (non_accept_receipt_unit.get("acceptance_records", []) as Array)[0] as Dictionary
	non_accept_record["status"] = "reject"
	_require(non_accept_receipt_registry != registry and str(non_accept_record.get("status", "")) == "reject", "Active-unit non-accept receipt negative control was a no-op.")
	_expect_data_error(non_accept_receipt_registry, contracts, "recognition_receipt_mismatch", "same-version active-unit non-accept receipt")
	var isle_topology_scope_registry := registry.duplicate(true)
	var isle_scope_adapter := (isle_topology_scope_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building-composite:w1249412094:w1282547787:wall")[0] as Dictionary
	var isle_geometry := ((isle_scope_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	var isle_original_scope := str(isle_geometry.get("world_topology_scope", ""))
	isle_geometry["world_topology_scope"] = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE
	_require(isle_topology_scope_registry != registry and isle_original_scope == PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE and str(isle_geometry.get("world_topology_scope", "")) != isle_original_scope, "Isle House topology-scope negative control was a no-op.")
	_expect_data_error(isle_topology_scope_registry, contracts, "isle_house_parity_mismatch", "same-version Isle House topology-scope mutation")
	var isle_missing_topology_scope_registry := registry.duplicate(true)
	var isle_missing_scope_adapter := (isle_missing_topology_scope_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building-composite:w1249412094:w1282547787:wall")[0] as Dictionary
	var isle_missing_geometry := ((isle_missing_scope_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	isle_missing_geometry.erase("world_topology_scope")
	_require(isle_missing_topology_scope_registry != registry and not isle_missing_geometry.has("world_topology_scope"), "Isle House topology-scope omission negative control was a no-op.")
	_expect_data_error(isle_missing_topology_scope_registry, contracts, "isle_house_parity_mismatch", "same-version Isle House topology-scope omission")
	var navy_topology_scope_registry := registry.duplicate(true)
	var navy_scope_adapter := (navy_topology_scope_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w291189336:wall")[0] as Dictionary
	var navy_geometry := ((navy_scope_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	var navy_original_scope := str(navy_geometry.get("world_topology_scope", ""))
	navy_geometry["world_topology_scope"] = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE
	_require(navy_topology_scope_registry != registry and navy_original_scope == PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE and str(navy_geometry.get("world_topology_scope", "")) != navy_original_scope, "Navy Chapel topology-scope negative control was a no-op.")
	_expect_data_error(navy_topology_scope_registry, contracts, "navy_chapel_parity_mismatch", "same-version Navy Chapel topology-scope mutation")
	var navy_missing_topology_scope_registry := registry.duplicate(true)
	var navy_missing_scope_adapter := (navy_missing_topology_scope_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w291189336:wall")[0] as Dictionary
	var navy_missing_geometry := ((navy_missing_scope_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	navy_missing_geometry.erase("world_topology_scope")
	_require(navy_missing_topology_scope_registry != registry and not navy_missing_geometry.has("world_topology_scope"), "Navy Chapel topology-scope omission negative control was a no-op.")
	_expect_data_error(navy_missing_topology_scope_registry, contracts, "navy_chapel_parity_mismatch", "same-version Navy Chapel topology-scope omission")
	var b201_topology_scope_registry := registry.duplicate(true)
	var b201_scope_adapter := (b201_topology_scope_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w34313545:wall")[0] as Dictionary
	var b201_geometry := ((b201_scope_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	var b201_original_scope := str(b201_geometry.get("world_topology_scope", ""))
	b201_geometry["world_topology_scope"] = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE
	_require(b201_topology_scope_registry != registry and b201_original_scope == PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE and str(b201_geometry.get("world_topology_scope", "")) != b201_original_scope, "D1 B201 topology-scope negative control was a no-op.")
	_expect_data_error(b201_topology_scope_registry, contracts, "d1_b201_parity_mismatch", "same-version D1 B201 topology-scope mutation")
	var b201_missing_topology_scope_registry := registry.duplicate(true)
	var b201_missing_scope_adapter := (b201_missing_topology_scope_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w34313545:wall")[0] as Dictionary
	var b201_missing_geometry := ((b201_missing_scope_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	b201_missing_geometry.erase("world_topology_scope")
	_require(b201_missing_topology_scope_registry != registry and not b201_missing_geometry.has("world_topology_scope"), "D1 B201 topology-scope omission negative control was a no-op.")
	_expect_data_error(b201_missing_topology_scope_registry, contracts, "d1_b201_parity_mismatch", "same-version D1 B201 topology-scope omission")
	var b225_topology_scope_registry := registry.duplicate(true)
	var b225_scope_adapter := (b225_topology_scope_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w95934119:wall")[0] as Dictionary
	var b225_geometry := ((b225_scope_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	b225_geometry["world_topology_scope"] = PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE
	_require(b225_topology_scope_registry != registry and str(b225_geometry.get("world_topology_scope", "")) != CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE, "D1 B225 topology-scope negative control was a no-op.")
	_expect_data_error(b225_topology_scope_registry, contracts, "d1_b225_parity_mismatch", "same-version D1 B225 topology-scope mutation")
	var b225_receipt_registry := registry.duplicate(true)
	var b225_receipt_unit := (b225_receipt_registry.get("units", []) as Array).filter(func(unit: Variant) -> bool: return str((unit as Dictionary).get("unit_id", "")) == "physical-building:w95934119")[0] as Dictionary
	var b225_acceptance_record := (b225_receipt_unit.get("acceptance_records", []) as Array)[0] as Dictionary
	b225_acceptance_record["evidence_tree_sha256"] = "0000000000000000000000000000000000000000000000000000000000000000"
	_require(b225_receipt_registry != registry, "D1 B225 evidence-tree negative control was a no-op.")
	_expect_data_error(b225_receipt_registry, contracts, "recognition_receipt_mismatch", "same-version D1 B225 evidence-tree mutation")
	var isle_topology_scope_contracts := contracts.duplicate(true)
	var isle_scope_plan := (isle_topology_scope_contracts.get("plans", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building-composite:w1249412094:w1282547787:wall")[0] as Dictionary
	var isle_plan_geometry := (isle_scope_plan.get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	var isle_plan_original_scope := str(isle_plan_geometry.get("world_topology_scope", ""))
	isle_plan_geometry["world_topology_scope"] = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE
	_require(isle_topology_scope_contracts != contracts and isle_plan_original_scope == PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE and str(isle_plan_geometry.get("world_topology_scope", "")) != isle_plan_original_scope, "Isle House plan topology-scope negative control was a no-op.")
	_expect_data_error(registry, isle_topology_scope_contracts, "isle_house_parity_mismatch", "same-version Isle House plan topology-scope mutation")
	var navy_topology_scope_contracts := contracts.duplicate(true)
	var navy_scope_plan := (navy_topology_scope_contracts.get("plans", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w291189336:wall")[0] as Dictionary
	var navy_plan_geometry := (navy_scope_plan.get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	var navy_plan_original_scope := str(navy_plan_geometry.get("world_topology_scope", ""))
	navy_plan_geometry["world_topology_scope"] = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE
	_require(navy_topology_scope_contracts != contracts and navy_plan_original_scope == PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE and str(navy_plan_geometry.get("world_topology_scope", "")) != navy_plan_original_scope, "Navy Chapel plan topology-scope negative control was a no-op.")
	_expect_data_error(registry, navy_topology_scope_contracts, "navy_chapel_parity_mismatch", "same-version Navy Chapel plan topology-scope mutation")
	var b201_topology_scope_contracts := contracts.duplicate(true)
	var b201_scope_plan := (b201_topology_scope_contracts.get("plans", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w34313545:wall")[0] as Dictionary
	var b201_plan_geometry := (b201_scope_plan.get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	var b201_plan_original_scope := str(b201_plan_geometry.get("world_topology_scope", ""))
	b201_plan_geometry["world_topology_scope"] = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE
	_require(b201_topology_scope_contracts != contracts and b201_plan_original_scope == PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE and str(b201_plan_geometry.get("world_topology_scope", "")) != b201_plan_original_scope, "D1 B201 plan topology-scope negative control was a no-op.")
	_expect_data_error(registry, b201_topology_scope_contracts, "d1_b201_parity_mismatch", "same-version D1 B201 plan topology-scope mutation")
	var b225_topology_scope_contracts := contracts.duplicate(true)
	var b225_scope_plan := (b225_topology_scope_contracts.get("plans", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w95934119:wall")[0] as Dictionary
	var b225_plan_geometry := (b225_scope_plan.get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	b225_plan_geometry["world_triangles"] = 67715
	_require(b225_topology_scope_contracts != contracts, "D1 B225 plan topology negative control was a no-op.")
	_expect_data_error(registry, b225_topology_scope_contracts, "d1_b225_parity_mismatch", "same-version D1 B225 plan topology mutation")
	var extra_nested_field_registry := registry.duplicate(true)
	var extra_nested_adapter := (extra_nested_field_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building-composite:w1249412094:w1282547787:wall")[0] as Dictionary
	var extra_nested_geometry := ((extra_nested_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	extra_nested_geometry["alternate_world_topology_scope"] = PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE
	_require(extra_nested_field_registry != registry and extra_nested_geometry.has("alternate_world_topology_scope"), "Isle House unknown nested-field negative control was a no-op.")
	_expect_data_error(extra_nested_field_registry, contracts, "isle_house_parity_mismatch", "same-version Isle House unknown nested geometry field")
	var b201_coverage_registry := registry.duplicate(true)
	var b201_coverage_adapter := (b201_coverage_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w34313545:wall")[0] as Dictionary
	var b201_coverage_scope := b201_coverage_adapter.get("active_receiver_scope", {}) as Dictionary
	b201_coverage_scope["coverage"] = "eligible_runs_only"
	_require(b201_coverage_registry != registry and str(b201_coverage_scope.get("coverage", "")) != "whole_direct_wall_receiver", "D1 B201 coverage negative control was a no-op.")
	_expect_data_error(b201_coverage_registry, contracts, "d1_b201_parity_mismatch", "same-version D1 B201 active receiver coverage mutation")
	var b201_run_count_registry := registry.duplicate(true)
	var b201_run_count_adapter := (b201_run_count_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w34313545:wall")[0] as Dictionary
	var b201_run_count_scope := b201_run_count_adapter.get("active_receiver_scope", {}) as Dictionary
	b201_run_count_scope["run_count"] = 39
	_require(b201_run_count_registry != registry and int(b201_run_count_scope.get("run_count", -1)) != 40, "D1 B201 run-count negative control was a no-op.")
	_expect_data_error(b201_run_count_registry, contracts, "d1_b201_parity_mismatch", "same-version D1 B201 active receiver run-count mutation")
	var b225_run_count_registry := registry.duplicate(true)
	var b225_run_count_adapter := (b225_run_count_registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == "building:w95934119:wall")[0] as Dictionary
	var b225_run_count_scope := b225_run_count_adapter.get("active_receiver_scope", {}) as Dictionary
	b225_run_count_scope["run_count"] = 13
	_require(b225_run_count_registry != registry and int(b225_run_count_scope.get("run_count", -1)) != 14, "D1 B225 run-count negative control was a no-op.")
	_expect_data_error(b225_run_count_registry, contracts, "d1_b225_parity_mismatch", "same-version D1 B225 active receiver run-count mutation")
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
	var zero_sha := "0000000000000000000000000000000000000000000000000000000000000000"
	for receipt_field: String in ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "evidence_tree_sha256", "package_verification_receipt_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256"]:
		var d2_receipt_registry := registry.duplicate(true)
		var d2_receipt_unit := _unit_by_id(d2_receipt_registry.get("units", []) as Array, "physical-building:w95934105")
		var d2_receipt := (d2_receipt_unit.get("acceptance_records", []) as Array)[0] as Dictionary
		d2_receipt[receipt_field] = zero_sha
		_expect_data_error(d2_receipt_registry, contracts, "recognition_receipt_mismatch", "D2 1441 %s receipt mutation" % receipt_field)
	var d2_metric_registry := registry.duplicate(true)
	var d2_metric_unit := _unit_by_id(d2_metric_registry.get("units", []) as Array, "physical-building:w95934105")
	((d2_metric_unit.get("acceptance_records", []) as Array)[0] as Dictionary)["capture_time_recognition_metric"] = "10/213"
	_expect_data_error(d2_metric_registry, contracts, "recognition_receipt_mismatch", "D2 1441 capture-time metric mutation")
	var d2_numerator_registry := registry.duplicate(true)
	var d2_numerator_unit := _unit_by_id(d2_numerator_registry.get("units", []) as Array, "physical-building:w95934105")
	((d2_numerator_unit.get("acceptance_records", []) as Array)[0] as Dictionary)["numerator_effect"] = 2
	_expect_data_error(d2_numerator_registry, contracts, "recognition_receipt_mismatch", "D2 1441 numerator-effect mutation")
	var d2_scope_registry := registry.duplicate(true)
	var d2_scope_adapter := _active_adapter_by_receiver(d2_scope_registry, "building:w95934105:wall")
	(d2_scope_adapter.get("active_receiver_scope", {}) as Dictionary)["run_count"] = 15
	_expect_data_error(d2_scope_registry, contracts, "d2_1441_parity_mismatch", "D2 1441 16-run receiver-scope mutation")
	var d2_dependency_registry := registry.duplicate(true)
	var d2_dependency_adapter := _active_adapter_by_receiver(d2_dependency_registry, "building:w95934105:wall")
	(d2_dependency_adapter.get("active_runtime_contract", {}) as Dictionary)["prototype_sha256"] = zero_sha
	_expect_data_error(d2_dependency_registry, contracts, "d2_1441_parity_mismatch", "D2 1441 prototype dependency mutation")
	var d2_asset_registry := registry.duplicate(true)
	var d2_asset_adapter := _active_adapter_by_receiver(d2_asset_registry, "building:w95934105:wall")
	_remove_runtime_asset(d2_asset_adapter.get("runtime_assets", []) as Array, "res://game/scripts/world/facades/site_12_housing_kit.gd")
	_expect_data_error(d2_asset_registry, contracts, "d2_1441_parity_mismatch", "D2 1441 runtime-asset omission")
	for mutation: Dictionary in [
		{"section": "acceptance_contract", "field": "mechanical_review_receipt_sha256", "value": zero_sha},
		{"section": "geometry_contract", "field": "visual_geometry_signature", "value": zero_sha},
		{"section": "geometry_contract", "field": "world_triangles", "value": 69251},
		{"section": "geometry_contract", "field": "world_topology_scope", "value": PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE},
		{"section": "ownership_contract", "field": "live_ownership_signature", "value": zero_sha},
		{"section": "ownership_contract", "field": "roof_collision_triangles", "value": 9},
		{"section": "replacement_contract", "field": "mapped_public_run_indices", "value": [10, 12, 13]},
		{"section": "replacement_contract", "field": "protected_run_indices", "value": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11]},
		{"section": "replacement_contract", "field": "partial_pair_allowed", "value": true},
		{"section": "truth_boundary", "field": "capture_time_recognition_credit", "value": true},
	]:
		var d2_behavior_registry := registry.duplicate(true)
		var d2_behavior_adapter := _active_adapter_by_receiver(d2_behavior_registry, "building:w95934105:wall")
		var d2_behavior := (d2_behavior_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary
		(d2_behavior.get(str(mutation.get("section", "")), {}) as Dictionary)[str(mutation.get("field", ""))] = mutation.get("value")
		_expect_data_error(d2_behavior_registry, contracts, "d2_1441_parity_mismatch", "D2 1441 registry behavior %s mutation" % str(mutation.get("field", "")))
	for mutation: Dictionary in [
		{"section": "acceptance_contract", "field": "package_verification_receipt_sha256", "value": zero_sha},
		{"section": "geometry_contract", "field": "topology_delta_triangles", "value": 1535},
		{"section": "ownership_contract", "field": "wall_is_sole_spray_receiver", "value": false},
		{"section": "replacement_contract", "field": "generic_stack_allowed", "value": true},
		{"section": "truth_boundary", "field": "capture_time_candidate_promoted", "value": true},
	]:
		var d2_behavior_contracts := contracts.duplicate(true)
		var d2_behavior_plan := _plan_by_receiver(d2_behavior_contracts, "building:w95934105:wall")
		var d2_plan_behavior := d2_behavior_plan.get("behavior_contract", {}) as Dictionary
		(d2_plan_behavior.get(str(mutation.get("section", "")), {}) as Dictionary)[str(mutation.get("field", ""))] = mutation.get("value")
		_expect_data_error(registry, d2_behavior_contracts, "d2_1441_parity_mismatch", "D2 1441 plan behavior %s mutation" % str(mutation.get("field", "")))
	var d2_executable_contracts := contracts.duplicate(true)
	var d2_executable_plan := _plan_by_receiver(d2_executable_contracts, "building:w95934105:wall")
	_remove_runtime_asset(d2_executable_plan.get("executable_assets", []) as Array, "res://game/scripts/world/facades/site_12_housing_kit.gd")
	_expect_data_error(registry, d2_executable_contracts, "d2_1441_parity_mismatch", "D2 1441 executable-subset omission")
	var d2_unknown_field_registry := registry.duplicate(true)
	var d2_unknown_adapter := _active_adapter_by_receiver(d2_unknown_field_registry, "building:w95934105:wall")
	var d2_unknown_geometry := ((d2_unknown_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	d2_unknown_geometry["capture_only_topology"] = 69252
	_expect_data_error(d2_unknown_field_registry, contracts, "d2_1441_parity_mismatch", "D2 1441 unknown nested behavior field")

	# Mirror the established acceptance/plan rejection boundary for the new paired unit.
	for receipt_field: String in ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "evidence_tree_sha256", "package_verification_receipt_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256"]:
		var d2_1439_receipt_registry := registry.duplicate(true)
		var d2_1439_receipt_unit := _unit_by_id(d2_1439_receipt_registry.get("units", []) as Array, "physical-building:w95934144")
		var d2_1439_receipt := (d2_1439_receipt_unit.get("acceptance_records", []) as Array)[0] as Dictionary
		d2_1439_receipt[receipt_field] = zero_sha
		_expect_data_error(d2_1439_receipt_registry, contracts, "recognition_receipt_mismatch", "D2 1439 %s receipt mutation" % receipt_field)
	var d2_1439_metric_registry := registry.duplicate(true)
	var d2_1439_metric_unit := _unit_by_id(d2_1439_metric_registry.get("units", []) as Array, "physical-building:w95934144")
	((d2_1439_metric_unit.get("acceptance_records", []) as Array)[0] as Dictionary)["capture_time_recognition_metric"] = "10/213"
	_expect_data_error(d2_1439_metric_registry, contracts, "recognition_receipt_mismatch", "D2 1439 capture-time metric mutation")
	var d2_1439_numerator_registry := registry.duplicate(true)
	var d2_1439_numerator_unit := _unit_by_id(d2_1439_numerator_registry.get("units", []) as Array, "physical-building:w95934144")
	((d2_1439_numerator_unit.get("acceptance_records", []) as Array)[0] as Dictionary)["numerator_effect"] = 2
	_expect_data_error(d2_1439_numerator_registry, contracts, "recognition_receipt_mismatch", "D2 1439 numerator-effect mutation")
	var d2_1439_scope_registry := registry.duplicate(true)
	var d2_1439_scope_adapter := _active_adapter_by_receiver(d2_1439_scope_registry, "building:w95934144:wall")
	(d2_1439_scope_adapter.get("active_receiver_scope", {}) as Dictionary)["run_count"] = 23
	_expect_data_error(d2_1439_scope_registry, contracts, "d2_1439_parity_mismatch", "D2 1439 24-run receiver-scope mutation")
	var d2_1439_dependency_registry := registry.duplicate(true)
	var d2_1439_dependency_adapter := _active_adapter_by_receiver(d2_1439_dependency_registry, "building:w95934144:wall")
	(d2_1439_dependency_adapter.get("active_runtime_contract", {}) as Dictionary)["prototype_sha256"] = zero_sha
	_expect_data_error(d2_1439_dependency_registry, contracts, "d2_1439_parity_mismatch", "D2 1439 prototype dependency mutation")
	var d2_1439_asset_registry := registry.duplicate(true)
	var d2_1439_asset_adapter := _active_adapter_by_receiver(d2_1439_asset_registry, "building:w95934144:wall")
	_remove_runtime_asset(d2_1439_asset_adapter.get("runtime_assets", []) as Array, "res://game/scripts/world/facades/site_12_housing_kit.gd")
	_expect_data_error(d2_1439_asset_registry, contracts, "d2_1439_parity_mismatch", "D2 1439 runtime-asset omission")
	for mutation: Dictionary in [
		{"section": "acceptance_contract", "field": "mechanical_review_receipt_sha256", "value": zero_sha},
		{"section": "geometry_contract", "field": "visual_geometry_signature", "value": zero_sha},
		{"section": "geometry_contract", "field": "world_triangles", "value": 71155},
		{"section": "geometry_contract", "field": "world_topology_scope", "value": PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE},
		{"section": "ownership_contract", "field": "live_ownership_signature", "value": zero_sha},
		{"section": "ownership_contract", "field": "roof_collision_triangles", "value": 9},
		{"section": "replacement_contract", "field": "mapped_public_run_indices", "value": [10, 12, 13]},
		{"section": "replacement_contract", "field": "protected_run_indices", "value": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11]},
		{"section": "replacement_contract", "field": "partial_pair_allowed", "value": true},
		{"section": "truth_boundary", "field": "capture_time_recognition_credit", "value": true},
	]:
		var d2_1439_behavior_registry := registry.duplicate(true)
		var d2_1439_behavior_adapter := _active_adapter_by_receiver(d2_1439_behavior_registry, "building:w95934144:wall")
		var d2_1439_behavior := (d2_1439_behavior_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary
		(d2_1439_behavior.get(str(mutation.get("section", "")), {}) as Dictionary)[str(mutation.get("field", ""))] = mutation.get("value")
		_expect_data_error(d2_1439_behavior_registry, contracts, "d2_1439_parity_mismatch", "D2 1439 registry behavior %s mutation" % str(mutation.get("field", "")))
	for mutation: Dictionary in [
		{"section": "acceptance_contract", "field": "package_verification_receipt_sha256", "value": zero_sha},
		{"section": "geometry_contract", "field": "topology_delta_triangles", "value": 1535},
		{"section": "ownership_contract", "field": "wall_is_sole_spray_receiver", "value": false},
		{"section": "replacement_contract", "field": "generic_stack_allowed", "value": true},
		{"section": "truth_boundary", "field": "capture_time_candidate_promoted", "value": true},
	]:
		var d2_1439_behavior_contracts := contracts.duplicate(true)
		var d2_1439_behavior_plan := _plan_by_receiver(d2_1439_behavior_contracts, "building:w95934144:wall")
		var d2_1439_plan_behavior := d2_1439_behavior_plan.get("behavior_contract", {}) as Dictionary
		(d2_1439_plan_behavior.get(str(mutation.get("section", "")), {}) as Dictionary)[str(mutation.get("field", ""))] = mutation.get("value")
		_expect_data_error(registry, d2_1439_behavior_contracts, "d2_1439_parity_mismatch", "D2 1439 plan behavior %s mutation" % str(mutation.get("field", "")))
	var d2_1439_executable_contracts := contracts.duplicate(true)
	var d2_1439_executable_plan := _plan_by_receiver(d2_1439_executable_contracts, "building:w95934144:wall")
	_remove_runtime_asset(d2_1439_executable_plan.get("executable_assets", []) as Array, "res://game/scripts/world/facades/site_12_housing_kit.gd")
	_expect_data_error(registry, d2_1439_executable_contracts, "d2_1439_parity_mismatch", "D2 1439 executable-subset omission")
	var d2_1439_unknown_field_registry := registry.duplicate(true)
	var d2_1439_unknown_adapter := _active_adapter_by_receiver(d2_1439_unknown_field_registry, "building:w95934144:wall")
	var d2_1439_unknown_geometry := ((d2_1439_unknown_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	d2_1439_unknown_geometry["capture_only_topology"] = 69252
	_expect_data_error(d2_1439_unknown_field_registry, contracts, "d2_1439_parity_mismatch", "D2 1439 unknown nested behavior field")


	var duplicate_1439_registry := registry.duplicate(true)
	var duplicate_1439_unit := _unit_by_id(duplicate_1439_registry.get("units", []) as Array, "physical-building:w95934144")
	var duplicate_1439_records := duplicate_1439_unit.get("acceptance_records", []) as Array
	duplicate_1439_records.append((duplicate_1439_records[0] as Dictionary).duplicate(true))
	_expect_data_error(duplicate_1439_registry, contracts, "recognition_receipt_mismatch", "D2 1439 duplicate recognition credit")
	for receipt_field: String in ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "evidence_tree_sha256", "package_verification_receipt_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256"]:
		var missing_1439_registry := registry.duplicate(true)
		var missing_1439_unit := _unit_by_id(missing_1439_registry.get("units", []) as Array, "physical-building:w95934144")
		((missing_1439_unit.get("acceptance_records", []) as Array)[0] as Dictionary).erase(receipt_field)
		_expect_data_error(missing_1439_registry, contracts, "recognition_receipt_mismatch", "D2 1439 omitted %s artifact binding" % receipt_field)
	for mutation: Dictionary in [
		{"section": "ownership_contract", "field": "roof_is_wall_spray_receiver", "value": true},
		{"section": "ownership_contract", "field": "wall_shape_order", "value": ["noneligible_closed_recess", "eligible_exterior"]},
		{"section": "geometry_contract", "field": "world_shapes", "value": 466},
	]:
		var invalid_1439_registry := registry.duplicate(true)
		var invalid_1439_adapter := _active_adapter_by_receiver(invalid_1439_registry, "building:w95934144:wall")
		var invalid_1439_behavior := (invalid_1439_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary
		(invalid_1439_behavior.get(str(mutation.get("section", "")), {}) as Dictionary)[str(mutation.get("field", ""))] = mutation.get("value")
		_expect_data_error(invalid_1439_registry, contracts, "d2_1439_parity_mismatch", "D2 1439 roof/closed-recess topology mutation")

	# Mirror the established acceptance/plan rejection boundary for the new paired unit.
	for receipt_field: String in ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "evidence_tree_sha256", "package_verification_receipt_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256"]:
		var d2_1444_receipt_registry := registry.duplicate(true)
		var d2_1444_receipt_unit := _unit_by_id(d2_1444_receipt_registry.get("units", []) as Array, "physical-building:w95934117")
		var d2_1444_receipt := (d2_1444_receipt_unit.get("acceptance_records", []) as Array)[0] as Dictionary
		d2_1444_receipt[receipt_field] = zero_sha
		_expect_data_error(d2_1444_receipt_registry, contracts, "recognition_receipt_mismatch", "D2 1444 %s receipt mutation" % receipt_field)
	var d2_1444_metric_registry := registry.duplicate(true)
	var d2_1444_metric_unit := _unit_by_id(d2_1444_metric_registry.get("units", []) as Array, "physical-building:w95934117")
	((d2_1444_metric_unit.get("acceptance_records", []) as Array)[0] as Dictionary)["capture_time_recognition_metric"] = "10/213"
	_expect_data_error(d2_1444_metric_registry, contracts, "recognition_receipt_mismatch", "D2 1444 capture-time metric mutation")
	var d2_1444_numerator_registry := registry.duplicate(true)
	var d2_1444_numerator_unit := _unit_by_id(d2_1444_numerator_registry.get("units", []) as Array, "physical-building:w95934117")
	((d2_1444_numerator_unit.get("acceptance_records", []) as Array)[0] as Dictionary)["numerator_effect"] = 2
	_expect_data_error(d2_1444_numerator_registry, contracts, "recognition_receipt_mismatch", "D2 1444 numerator-effect mutation")
	var d2_1444_scope_registry := registry.duplicate(true)
	var d2_1444_scope_adapter := _active_adapter_by_receiver(d2_1444_scope_registry, "building:w95934117:wall")
	(d2_1444_scope_adapter.get("active_receiver_scope", {}) as Dictionary)["run_count"] = 23
	_expect_data_error(d2_1444_scope_registry, contracts, "d2_1444_parity_mismatch", "D2 1444 22-run receiver-scope mutation")
	var fractional_1444_registry := registry.duplicate(true)
	var fractional_1444_contracts := contracts.duplicate(true)
	var fractional_1444_adapter := _active_adapter_by_receiver(fractional_1444_registry, "building:w95934117:wall")
	var fractional_1444_runtime := fractional_1444_adapter.get("active_runtime_contract", {}) as Dictionary
	var fractional_1444_behavior := fractional_1444_runtime.get("behavior_contract", {}) as Dictionary
	var fractional_1444_plan := _plan_by_receiver(fractional_1444_contracts, "building:w95934117:wall")
	for behavior: Dictionary in [fractional_1444_behavior, fractional_1444_plan.get("behavior_contract", {}) as Dictionary]:
		var replacement := behavior.get("replacement_contract", {}) as Dictionary
		(replacement.get("mapped_public_run_indices", []) as Array)[0] = 8.5
	_expect_data_error(fractional_1444_registry, fractional_1444_contracts, "d2_1444_parity_mismatch", "D2 1444 coherent fractional mapped-run mutation")
	var d2_1444_dependency_registry := registry.duplicate(true)
	var d2_1444_dependency_adapter := _active_adapter_by_receiver(d2_1444_dependency_registry, "building:w95934117:wall")
	(d2_1444_dependency_adapter.get("active_runtime_contract", {}) as Dictionary)["prototype_sha256"] = zero_sha
	_expect_data_error(d2_1444_dependency_registry, contracts, "d2_1444_parity_mismatch", "D2 1444 prototype dependency mutation")
	var d2_1444_asset_registry := registry.duplicate(true)
	var d2_1444_asset_adapter := _active_adapter_by_receiver(d2_1444_asset_registry, "building:w95934117:wall")
	_remove_runtime_asset(d2_1444_asset_adapter.get("runtime_assets", []) as Array, "res://game/scripts/world/facades/site_12_housing_kit.gd")
	_expect_data_error(d2_1444_asset_registry, contracts, "d2_1444_parity_mismatch", "D2 1444 runtime-asset omission")
	for mutation: Dictionary in [
		{"section": "acceptance_contract", "field": "mechanical_review_receipt_sha256", "value": zero_sha},
		{"section": "geometry_contract", "field": "visual_geometry_signature", "value": zero_sha},
		{"section": "geometry_contract", "field": "world_triangles", "value": 71155},
		{"section": "geometry_contract", "field": "world_topology_scope", "value": PRE_D2_1444_INTEGRATION_WORLD_TOPOLOGY_SCOPE},
		{"section": "ownership_contract", "field": "live_ownership_signature", "value": zero_sha},
		{"section": "ownership_contract", "field": "roof_collision_triangles", "value": 9},
		{"section": "replacement_contract", "field": "mapped_public_run_indices", "value": [10, 12, 13]},
		{"section": "replacement_contract", "field": "protected_run_indices", "value": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11]},
		{"section": "replacement_contract", "field": "partial_pair_allowed", "value": true},
		{"section": "truth_boundary", "field": "capture_time_recognition_credit", "value": true},
	]:
		var d2_1444_behavior_registry := registry.duplicate(true)
		var d2_1444_behavior_adapter := _active_adapter_by_receiver(d2_1444_behavior_registry, "building:w95934117:wall")
		var d2_1444_behavior := (d2_1444_behavior_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary
		(d2_1444_behavior.get(str(mutation.get("section", "")), {}) as Dictionary)[str(mutation.get("field", ""))] = mutation.get("value")
		_expect_data_error(d2_1444_behavior_registry, contracts, "d2_1444_parity_mismatch", "D2 1444 registry behavior %s mutation" % str(mutation.get("field", "")))
	for mutation: Dictionary in [
		{"section": "acceptance_contract", "field": "package_verification_receipt_sha256", "value": zero_sha},
		{"section": "geometry_contract", "field": "topology_delta_triangles", "value": 1535},
		{"section": "ownership_contract", "field": "wall_is_sole_spray_receiver", "value": false},
		{"section": "replacement_contract", "field": "generic_stack_allowed", "value": true},
		{"section": "truth_boundary", "field": "capture_time_candidate_promoted", "value": true},
	]:
		var d2_1444_behavior_contracts := contracts.duplicate(true)
		var d2_1444_behavior_plan := _plan_by_receiver(d2_1444_behavior_contracts, "building:w95934117:wall")
		var d2_1444_plan_behavior := d2_1444_behavior_plan.get("behavior_contract", {}) as Dictionary
		(d2_1444_plan_behavior.get(str(mutation.get("section", "")), {}) as Dictionary)[str(mutation.get("field", ""))] = mutation.get("value")
		_expect_data_error(registry, d2_1444_behavior_contracts, "d2_1444_parity_mismatch", "D2 1444 plan behavior %s mutation" % str(mutation.get("field", "")))
	var d2_1444_executable_contracts := contracts.duplicate(true)
	var d2_1444_executable_plan := _plan_by_receiver(d2_1444_executable_contracts, "building:w95934117:wall")
	_remove_runtime_asset(d2_1444_executable_plan.get("executable_assets", []) as Array, "res://game/scripts/world/facades/site_12_housing_kit.gd")
	_expect_data_error(registry, d2_1444_executable_contracts, "d2_1444_parity_mismatch", "D2 1444 executable-subset omission")
	var d2_1444_unknown_field_registry := registry.duplicate(true)
	var d2_1444_unknown_adapter := _active_adapter_by_receiver(d2_1444_unknown_field_registry, "building:w95934117:wall")
	var d2_1444_unknown_geometry := ((d2_1444_unknown_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	d2_1444_unknown_geometry["capture_only_topology"] = 69252
	_expect_data_error(d2_1444_unknown_field_registry, contracts, "d2_1444_parity_mismatch", "D2 1444 unknown nested behavior field")


	var duplicate_1444_registry := registry.duplicate(true)
	var duplicate_1444_unit := _unit_by_id(duplicate_1444_registry.get("units", []) as Array, "physical-building:w95934117")
	var duplicate_1444_records := duplicate_1444_unit.get("acceptance_records", []) as Array
	duplicate_1444_records.append((duplicate_1444_records[0] as Dictionary).duplicate(true))
	_expect_data_error(duplicate_1444_registry, contracts, "recognition_receipt_mismatch", "D2 1444 duplicate recognition credit")
	for receipt_field: String in ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "evidence_tree_sha256", "package_verification_receipt_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256"]:
		var missing_1444_registry := registry.duplicate(true)
		var missing_1444_unit := _unit_by_id(missing_1444_registry.get("units", []) as Array, "physical-building:w95934117")
		((missing_1444_unit.get("acceptance_records", []) as Array)[0] as Dictionary).erase(receipt_field)
		_expect_data_error(missing_1444_registry, contracts, "recognition_receipt_mismatch", "D2 1444 omitted %s artifact binding" % receipt_field)
	for mutation: Dictionary in [
		{"section": "ownership_contract", "field": "roof_is_wall_spray_receiver", "value": true},
		{"section": "ownership_contract", "field": "wall_shape_order", "value": ["noneligible_closed_recess", "eligible_exterior"]},
		{"section": "geometry_contract", "field": "world_shapes", "value": 466},
	]:
		var invalid_1444_registry := registry.duplicate(true)
		var invalid_1444_adapter := _active_adapter_by_receiver(invalid_1444_registry, "building:w95934117:wall")
		var invalid_1444_behavior := (invalid_1444_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary
		(invalid_1444_behavior.get(str(mutation.get("section", "")), {}) as Dictionary)[str(mutation.get("field", ""))] = mutation.get("value")
		_expect_data_error(invalid_1444_registry, contracts, "d2_1444_parity_mismatch", "D2 1444 roof/closed-recess topology mutation")


func _remove_runtime_asset(assets: Array, path: String) -> void:
	var index := _runtime_asset_index(assets, path)
	if index >= 0:
		assets.remove_at(index)


func _active_adapter_by_receiver(registry: Dictionary, receiver_key: String) -> Dictionary:
	for adapter_value: Variant in registry.get("active_runtime_adapters", []) as Array:
		var adapter := adapter_value as Dictionary
		if str(adapter.get("receiver_key", "")) == receiver_key:
			return adapter
	return {}


func _plan_by_receiver(contracts: Dictionary, receiver_key: String) -> Dictionary:
	for plan_value: Variant in contracts.get("plans", []) as Array:
		var plan := plan_value as Dictionary
		if str(plan.get("receiver_key", "")) == receiver_key:
			return plan
	return {}


func _int_array_matches(values: Array, expected: Array) -> bool:
	if values.size() != expected.size():
		return false
	for index in expected.size():
		if int(values[index]) != int(expected[index]):
			return false
	return true


func _runtime_asset_index(assets: Array, path: String) -> int:
	for index in assets.size():
		if str((assets[index] as Dictionary).get("path", "")) == path:
			return index
	return -1


func _unit_by_id(units: Array, unit_id: String) -> Dictionary:
	for unit_value: Variant in units:
		var unit := unit_value as Dictionary
		if str(unit.get("unit_id", "")) == unit_id:
			return unit
	return {}


func _receiver_by_key(receivers: Array, receiver_key: String) -> Dictionary:
	for receiver_value: Variant in receivers:
		var receiver := receiver_value as Dictionary
		if str(receiver.get("receiver_key", "")) == receiver_key:
			return receiver
	return {}


func _expect_data_error(registry: Dictionary, contracts: Dictionary, expected_code: String, label: String) -> void:
	var loader := RegistryLoader.new()
	_expect_error(loader.load_from_data(registry, contracts), expected_code, label)


func _expect_error(result: Dictionary, expected_code: String, label: String) -> void:
	_require(_error_matches(result, expected_code), "Loader accepted %s or returned the wrong error: %s" % [label, str(result)])


func _error_matches(result: Dictionary, expected_code: String) -> bool:
	return not bool(result.get("ok", true)) and str(result.get("error_code", "")) == expected_code


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


func _validate_d5_batch_mutations(registry: Dictionary, contracts: Dictionary) -> void:
	for target: Dictionary in [{"unit_id": "physical-building:w95934123", "wall": "building:w95934123:wall", "number": "1308"}, {"unit_id": "physical-building:w96215646", "wall": "building:w96215646:wall", "number": "1394"}, {"unit_id": "physical-building:w95934125", "wall": "building:w95934125:wall", "number": "1317"}, {"unit_id": "physical-building:w764313741", "wall": "building:w764313741:wall", "number": "station48"}, {"unit_id": "physical-building:r19685981", "wall": "building:r19685981:wall", "number": "maceo"}, {"unit_id": "physical-building:w96215672", "wall": "building:w96215672:wall", "number": "1201"}, {"unit_id": "physical-building:w96215669", "wall": "building:w96215669:wall", "number": "1238"}, {"unit_id": "physical-building:w96215677", "wall": "building:w96215677:wall", "number": "1206"}, {"unit_id": "physical-building:w96215680", "wall": "building:w96215680:wall", "number": "1219"}, {"unit_id": "physical-building:w96215649", "wall": "building:w96215649:wall", "number": "1212"}, {"unit_id": "physical-building:w96215652", "wall": "building:w96215652:wall", "number": "1220"}, {"unit_id": "physical-building:w96215658", "wall": "building:w96215658:wall", "number": "1239"}, {"unit_id": "physical-building:w96215661", "wall": "building:w96215661:wall", "number": "1222"}, {"unit_id": "physical-building:w96215653", "wall": "building:w96215653:wall", "number": "1227"}, {"unit_id": "physical-building:w96215651", "wall": "building:w96215651:wall", "number": "1202"}]:
		var receiver := str(target.wall)
		var unit_id := str(target.unit_id)
		var code := "northern_1202_parity_mismatch" if str(target.number) == "1202" else "northern_1227_parity_mismatch" if str(target.number) == "1227" else "northern_1222_parity_mismatch" if str(target.number) == "1222" else "northern_1239_parity_mismatch" if str(target.number) == "1239" else "northern_1220_parity_mismatch" if str(target.number) == "1220" else "northern_1212_parity_mismatch" if str(target.number) == "1212" else "northern_1219_parity_mismatch" if str(target.number) == "1219" else "northern_1206_parity_mismatch" if str(target.number) == "1206" else "northern_1238_parity_mismatch" if str(target.number) == "1238" else "northern_1201_parity_mismatch" if str(target.number) == "1201" else "maceo_may_parity_mismatch" if str(target.number) == "maceo" else "fire_station48_parity_mismatch" if str(target.number) == "station48" else "d5_%s_parity_mismatch" % str(target.number)
		var duplicate_registry := registry.duplicate(true)
		var records := _unit_by_id(duplicate_registry.get("units", []) as Array, unit_id).get("acceptance_records", []) as Array
		records.append((records[0] as Dictionary).duplicate(true))
		_expect_data_error(duplicate_registry, contracts, "recognition_receipt_mismatch", "D5 duplicate physical-unit credit")
		for field: String in ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "mechanical_review_receipt_sha256", "evidence_tree_sha256", "review_receipt_sha256"]:
			var missing_registry := registry.duplicate(true)
			var missing_records := _unit_by_id(missing_registry.get("units", []) as Array, unit_id).get("acceptance_records", []) as Array
			(missing_records[0] as Dictionary).erase(field)
			_expect_data_error(missing_registry, contracts, "recognition_receipt_mismatch", "D5 omitted literal artifact " + field)
		# Mutate both copies coherently, so the exact run guard must reject it.
		for field: String in ["mapped_public_run_indices", "protected_run_indices"]:
			for invalid: Variant in [0.5, "0", true, INF, NAN]:
				var fractional_registry := registry.duplicate(true)
				var fractional_contracts := contracts.duplicate(true)
				var adapter := _active_adapter_by_receiver(fractional_registry, receiver)
				var behavior := (adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary
				var replacement := behavior.get("replacement_contract", {}) as Dictionary
				var values := replacement.get(field, []) as Array
				values[0] = float(values[0]) + invalid if typeof(invalid) == TYPE_FLOAT else invalid
				var plan := _plan_by_receiver(fractional_contracts, receiver)
				plan["behavior_contract"] = behavior.duplicate(true)
				_expect_data_error(fractional_registry, fractional_contracts, code, "D5 coherent invalid exact-run number")
		for mutation: Dictionary in [
			{"section":"ownership_contract", "field":"roof_is_wall_spray_receiver", "value":true},
			{"section":"geometry_contract", "field":"world_shapes", "value":470},
			{"section":"replacement_contract", "field":"actual_land_and_area_records_required", "value":str(target.number) in ["station48", "maceo", "1201", "1238", "1206", "1219", "1212", "1220", "1239", "1222", "1227", "1202"]},
		]:
			var invalid_registry := registry.duplicate(true)
			var invalid_adapter := _active_adapter_by_receiver(invalid_registry, receiver)
			var invalid_behavior := (invalid_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary
			(invalid_behavior.get(str(mutation.section), {}) as Dictionary)[str(mutation.field)] = mutation.value
			_expect_data_error(invalid_registry, contracts, code, "D5 topology/roof/terrain ownership drift")


func _report_measurement_phase(label: String, started_usec: int, before: Dictionary) -> void:
	var after: Dictionary = RegistryLoader.measurement_snapshot()
	var delta: Dictionary = {}
	for key: String in after:
		delta[key] = int(after[key]) - int(before.get(key, 0))
	print("FACADE_LOADER_MEASUREMENT_PHASE: " + JSON.stringify({"phase": label, "wall_usec": Time.get_ticks_usec() - started_usec, "counters": delta, "scope": "aggregate instrumentation; hash/read elapsed are subsets of phase wall time; no avoided-time claim"}))
