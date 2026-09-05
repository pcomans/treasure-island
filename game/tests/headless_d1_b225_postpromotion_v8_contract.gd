extends "res://game/tests/headless_d1_b225_production_attachment_contract.gd"

## Current-authority bridge layered over the immutable v7 production validator.
## It proves the unchanged reviewed B225 geometry/config/adapter bytes while
## validating the provisional v8 +1 authority transition. No evidence is read
## as mutable input and this contract never writes or recaptures evidence.

const V8_REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const V8_CONTRACTS_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const V8_CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const V8_SCHEMA_PATH := "res://discovery/facades/facade-recognition-catalog.schema.json"
const V8_LOADER_PATH := "res://game/scripts/world/facades/facade_runtime_registry_loader.gd"
const FROZEN_CAPTURE_MANIFEST_PATH := "res://evidence/first-playable/d1-b225-production-attachment-v7-staging-2026-09-05/capture-manifest.json"
const FROZEN_REVIEW_PATH := "res://evidence/reviews/d1-b225-production-attachment-v7-staging-2026-09-05-INDEPENDENT_VISUAL_REVIEW.md"
const FROZEN_FOCUSED_CONTRACT_PATH := "res://game/tests/headless_d1_b225_production_attachment_contract.gd"
const FROZEN_PACKAGE_CONTRACT_PATH := "res://game/tests/headless_d1_b225_production_attachment_package_contract.gd"
const FROZEN_CAPTURE_GENERATOR_PATH := "res://game/tests/d1_b225_production_attachment_capture.gd"
const V8_REGISTRY_SHA256 := "109f83f40450e9c71ef6d39f1659e76eac5f1457fcfab772538b471cc74c0051"
const V8_CONTRACTS_SHA256 := "dd2d13e3b0f6eee1f8c5f2957927c4f3caba43b31883beea925f9a91b826d65c"
const V8_CATALOG_SHA256 := "d95be7bec8f0eabe97a9b5f7fefe1ce54ec7cbf940d85d28518ff6979eeb16ea"
const V8_SCHEMA_SHA256 := "44584e92e1652fc930f47882b4a83304f5216c14173eb805bc9ce68ea9927cac"
const V8_LOADER_SHA256 := "12e6c64b23b0783ed240b3d6c02499c3940c2b6a14344caa29778b850db06c04"
const FROZEN_CAPTURE_MANIFEST_SHA256 := "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc"
const FROZEN_EVIDENCE_TREE_SHA256 := "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7"
const FROZEN_REVIEW_SHA256 := "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95"
const FROZEN_FOCUSED_CONTRACT_SHA256 := "6a1e6019c3a5bb58b9a5adc009e3e54c619a0a1ef70dbe9f605241942c39a85b"
const FROZEN_PACKAGE_CONTRACT_SHA256 := "80f56708fcaacd81468939c0818cb37af5212666009280304e8f71c620e322d1"
const FROZEN_CAPTURE_GENERATOR_SHA256 := "fbb3b600d8456c4e15a124f5c13bdf6bcf427ebe8c11b00b1cda4a712dec6856"
const V8_EXPECTED_WORLD := {"rows": 735, "meshes": 952, "surfaces": 967, "triangles": 67716, "bodies": 466, "shapes": 466}
const B225_UNIT_ID := "physical-building:w95934119"
const B201_RECEIVER_KEY := "building:w34313545:wall"
const B225_ADAPTER_ID := "active-adapter:d1-b225-live:building:w95934119:wall"


func _run() -> void:
	_require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256, "Frozen B225 live config bytes drifted.")
	_require(FileAccess.get_sha256(ADAPTER_PATH) == EXPECTED_ADAPTER_SHA256, "Frozen B225 live adapter bytes drifted.")
	_require(FileAccess.get_sha256(BUILDER_PATH) == EXPECTED_BUILDER_SHA256, "Reviewed B225 canonical dispatch bytes drifted.")
	_require(_frozen_inputs_match(), "Frozen v7 B225 production evidence/review/validator bytes drifted.")
	_require(_postpromotion_authority_matches(), "B225 provisional v8 authority, exact +1 receipt, adapter projection, or topology ownership drifted.")
	var chunk := _load_json(CHUNK_PATH)
	var record := _record_for(chunk, ADAPTER.RECEIVER_KEY)
	var roof := _record_for(chunk, ADAPTER.ROOF_KEY)
	_require(not record.is_empty() and not roof.is_empty(), "Exact B225 wall/roof pair did not resolve.")
	_require(bool(ADAPTER.validate_chunk_records(chunk).get("ok", false)), "Exact B225 chunk preflight failed.")
	var prepared := ADAPTER.prepare(record)
	var authored := ADAPTER.authored_transform_spec(record, prepared)
	_require(bool(prepared.get("ok", false)) and bool(authored.get("ok", false)), "B225 deterministic prepared/authored state failed.")
	var standalone_scene := load(STANDALONE_SCENE_PATH) as PackedScene
	var standalone := standalone_scene.instantiate() as Node3D if standalone_scene != null else null
	if standalone != null:
		root.add_child(standalone)
		await process_frame
	_require(standalone != null and _reviewed_standalone_translation_matches(standalone, authored, DisplayServer.get_name() != "headless"), "B225 live clerestory no longer translates the frozen reviewed standalone exactly.")
	var ordinary_result := BUILDER.new()._build_record(record, false)
	if not _require(bool(ordinary_result.get("ok", false)), "B225 ordinary exact receiver failed canonical construction: %s" % ordinary_result):
		_finish()
		return
	var ordinary_node := ordinary_result.get("node") as Node3D
	root.add_child(ordinary_node)
	await process_frame
	_require(_host_and_attachment_match(ordinary_result, record, authored, DisplayServer.get_name() != "headless"), "Canonical builder did not retain the exact B225 production host partition and render-only attachment.")
	_require(_mutation_matrix_fails_closed(chunk, record, ordinary_result), "B225 adversarial record/prepared/partition mutation escaped fail-closed handling.")
	_require(_builder_chunk_mutations_fail_closed(chunk), "Canonical B225 chunk dispatch accepted malformed membership.")
	ordinary_node.queue_free()
	if standalone != null:
		standalone.queue_free()
	await process_frame
	_require(await _postpromotion_world_matches(record, roof, authored), "B225 v8 whole-world topology, roof parity, or sole ownership contract drifted.")
	if not _failed:
		print("PASS: D1 B225 post-promotion v8 authority is exactly 8/213 with one +1 physical-unit receipt bound to frozen v7 evidence; unchanged config/adapter geometry yields sole current 735/952/967/67,716/466/466 topology while B201 remains pre-B225 at 735/950/964/66,636/466/466")
	_finish()


func _frozen_inputs_match() -> bool:
	return FileAccess.get_sha256(FROZEN_CAPTURE_MANIFEST_PATH) == FROZEN_CAPTURE_MANIFEST_SHA256 \
		and FileAccess.get_sha256(FROZEN_REVIEW_PATH) == FROZEN_REVIEW_SHA256 \
		and FileAccess.get_sha256(FROZEN_FOCUSED_CONTRACT_PATH) == FROZEN_FOCUSED_CONTRACT_SHA256 \
		and FileAccess.get_sha256(FROZEN_PACKAGE_CONTRACT_PATH) == FROZEN_PACKAGE_CONTRACT_SHA256 \
		and FileAccess.get_sha256(FROZEN_CAPTURE_GENERATOR_PATH) == FROZEN_CAPTURE_GENERATOR_SHA256


func _postpromotion_authority_matches() -> bool:
	if FileAccess.get_sha256(V8_REGISTRY_PATH) != V8_REGISTRY_SHA256 \
	or FileAccess.get_sha256(V8_CONTRACTS_PATH) != V8_CONTRACTS_SHA256 \
	or FileAccess.get_sha256(V8_CATALOG_PATH) != V8_CATALOG_SHA256 \
	or FileAccess.get_sha256(V8_SCHEMA_PATH) != V8_SCHEMA_SHA256 \
	or FileAccess.get_sha256(V8_LOADER_PATH) != V8_LOADER_SHA256 \
	or FileAccess.get_file_as_string(V8_SCHEMA_PATH).contains("\"candidates\""):
		return false
	var registry := _load_json(V8_REGISTRY_PATH)
	var catalog := _load_json(V8_CATALOG_PATH)
	var contracts := _load_json(V8_CONTRACTS_PATH)
	var compatibility := registry.get("compatibility_contract", {}) as Dictionary
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted_ids := metric.get("accepted_physical_unit_ids", []) as Array
	var runtime_unit := _unit_for(registry.get("units", []) as Array, B225_UNIT_ID)
	var catalog_unit := _unit_for(catalog.get("units", []) as Array, B225_UNIT_ID)
	var runtime_receipts := runtime_unit.get("acceptance_records", []) as Array
	var catalog_receipts := catalog_unit.get("acceptance_records", []) as Array
	if str(registry.get("schema_version", "")) != "ti.facade-runtime-registry/8" \
	or str(catalog.get("schema_version", "")) != "ti.facade-recognition-catalog/8" \
	or str(contracts.get("schema_version", "")) != "ti.facade-runtime-adapter-contracts/7" \
	or str(compatibility.get("loader_api_version", "")) != "ti.facade-runtime-registry-loader/7" \
	or str(compatibility.get("compiler_version", "")) != "1.7.0" \
	or int(metric.get("numerator", -1)) != 8 or int(metric.get("denominator", -1)) != 213 \
	or str(metric.get("display", "")) != "8/213" or accepted_ids.size() != 8 or accepted_ids.count(B225_UNIT_ID) != 1 \
	or runtime_receipts.size() != 1 or catalog_receipts.size() != 1:
		return false
	if not _b225_receipt_matches(runtime_receipts[0] as Dictionary) \
	or not _b225_receipt_matches(catalog_receipts[0] as Dictionary) \
	or str((runtime_unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) != "accepted" \
	or str((catalog_unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) != "accepted":
		return false
	var b225_adapters := (registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == ADAPTER.RECEIVER_KEY)
	var b201_adapters := (registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == B201_RECEIVER_KEY)
	var b225_plans := (contracts.get("plans", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == ADAPTER.RECEIVER_KEY)
	if b225_adapters.size() != 1 or b201_adapters.size() != 1 or b225_plans.size() != 1:
		return false
	var b225_adapter := b225_adapters[0] as Dictionary
	var b201_adapter := b201_adapters[0] as Dictionary
	var b225_plan := b225_plans[0] as Dictionary
	var b225_contract := b225_adapter.get("active_runtime_contract", {}) as Dictionary
	var b225_behavior := b225_contract.get("behavior_contract", {}) as Dictionary
	var b225_acceptance := b225_behavior.get("acceptance_contract", {}) as Dictionary
	var b225_geometry := b225_behavior.get("geometry_contract", {}) as Dictionary
	var b201_behavior := ((b201_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary)
	var b201_geometry := b201_behavior.get("geometry_contract", {}) as Dictionary
	var asset_paths := []
	for value: Variant in b225_adapter.get("runtime_assets", []) as Array:
		asset_paths.append(str((value as Dictionary).get("path", "")))
	asset_paths.sort()
	var expected_paths := [
		CONFIG_PATH,
		ADAPTER_PATH,
		"res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres",
		"res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png",
		"res://game/resources/materials/world/d1_current/shared_dark_glass.tres",
		"res://game/resources/materials/world/d1_current/shared_pale_frame.tres",
	]
	expected_paths.sort()
	if str(b225_adapter.get("adapter_id", "")) != B225_ADAPTER_ID \
	or str(b225_adapter.get("recognition_acceptance_status", "")) != "accepted" \
	or str(b225_adapter.get("runtime_content_mode", "")) != "active_d1_b225_host_partition_attachment" \
	or str(b225_contract.get("adapter_sha256", "")) != EXPECTED_ADAPTER_SHA256 \
	or str(b225_contract.get("config_sha256", "")) != EXPECTED_CONFIG_SHA256 \
	or str(b225_contract.get("dispatch_sha256", "")) != EXPECTED_BUILDER_SHA256 \
	or asset_paths != expected_paths \
	or JSON.stringify(b225_plan.get("behavior_contract", {})) != JSON.stringify(b225_behavior) \
	or (b225_plan.get("executable_assets", []) as Array).size() != 1:
		return false
	if str(b225_acceptance.get("capture_time_recognition_metric", "")) != "7/213" \
	or str(b225_acceptance.get("evidence_manifest_sha256", "")) != FROZEN_CAPTURE_MANIFEST_SHA256 \
	or str(b225_acceptance.get("evidence_tree_sha256", "")) != FROZEN_EVIDENCE_TREE_SHA256 \
	or str(b225_acceptance.get("independent_live_review_receipt_sha256", "")) != FROZEN_REVIEW_SHA256 \
	or int(b225_acceptance.get("numerator_effect", -1)) != 1 \
	or not _topology_matches(b225_geometry, "current_integration_topology", V8_EXPECTED_WORLD) \
	or not _topology_matches(b201_geometry, "pre_b225_integration_live_parity", {"rows": 735, "meshes": 950, "surfaces": 964, "triangles": 66636, "bodies": 466, "shapes": 466}):
		return false
	var current_topology_ids := []
	for value: Variant in registry.get("active_runtime_adapters", []) as Array:
		var candidate := value as Dictionary
		var candidate_contract := candidate.get("active_runtime_contract", {}) as Dictionary
		var candidate_behavior_value: Variant = candidate_contract.get("behavior_contract", {})
		var candidate_behavior := candidate_behavior_value as Dictionary if candidate_behavior_value is Dictionary else {}
		var candidate_geometry := candidate_behavior.get("geometry_contract", {}) as Dictionary
		if str(candidate_geometry.get("world_topology_scope", "")) == "current_integration_topology":
			current_topology_ids.append(str(candidate.get("adapter_id", "")))
	return current_topology_ids == [B225_ADAPTER_ID]


func _b225_receipt_matches(receipt: Dictionary) -> bool:
	return str(receipt.get("capture_time_recognition_metric", "")) == "7/213" \
		and str(receipt.get("evidence_manifest_sha256", "")) == FROZEN_CAPTURE_MANIFEST_SHA256 \
		and str(receipt.get("evidence_tree_sha256", "")) == FROZEN_EVIDENCE_TREE_SHA256 \
		and str(receipt.get("review_receipt_sha256", "")) == FROZEN_REVIEW_SHA256 \
		and int(receipt.get("numerator_effect", -1)) == 1 \
		and str(receipt.get("review_kind", "")) == "independent_reference_recognition" \
		and str(receipt.get("status", "")) == "accept"


func _topology_matches(geometry: Dictionary, scope: String, expected: Dictionary) -> bool:
	return str(geometry.get("world_topology_scope", "")) == scope \
		and int(geometry.get("world_records", -1)) == int(expected.rows) \
		and int(geometry.get("world_mesh_instances", -1)) == int(expected.meshes) \
		and int(geometry.get("world_surfaces", -1)) == int(expected.surfaces) \
		and int(geometry.get("world_triangles", -1)) == int(expected.triangles) \
		and int(geometry.get("world_static_bodies", -1)) == int(expected.bodies) \
		and int(geometry.get("world_shapes", -1)) == int(expected.shapes)


func _postpromotion_world_matches(record: Dictionary, roof_record: Dictionary, authored: Dictionary) -> bool:
	var main_scene := load("res://game/scenes/main.tscn") as PackedScene
	var main := main_scene.instantiate() as GameMain if main_scene != null else null
	if main == null:
		return false
	var world := main.get_node("WorldRoot") as WorldLoader
	var ready: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 45000:
		await process_frame
	var walls := _record_roots(world, ADAPTER.RECEIVER_KEY)
	var roofs := _record_roots(world, ADAPTER.ROOF_KEY)
	var topology := _evidence_topology(world.get_runtime_evidence())
	var ok := failures.is_empty() and ready.size() == 1 and topology == V8_EXPECTED_WORLD \
		and walls.size() == 1 and roofs.size() == 1 \
		and _production_world_has_no_candidate_route(world) \
		and _host_and_attachment_match({"node": walls[0], "mesh_instances": 3, "surfaces": 4, "triangles": 1108}, record, authored, DisplayServer.get_name() != "headless") \
		and _roof_node_matches(roofs[0] as Node3D, roof_record)
	if ok:
		var identities_before := _production_identity_snapshot(walls[0] as Node3D, roofs[0] as Node3D)
		await physics_frame
		await physics_frame
		ok = _spray_ray_matches(walls[0] as Node3D, record) \
			and identities_before == _production_identity_snapshot(walls[0] as Node3D, roofs[0] as Node3D) \
			and _evidence_topology(world.get_runtime_evidence()) == V8_EXPECTED_WORLD
	if not ok:
		print("B225_V8_DIAGNOSTIC failures=", failures, " ready=", ready.size(), " topology=", topology, " walls=", walls.size(), " roofs=", roofs.size())
	main.queue_free()
	await process_frame
	return ok
