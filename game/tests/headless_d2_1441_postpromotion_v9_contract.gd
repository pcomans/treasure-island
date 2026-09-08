extends "res://game/tests/headless_d2_1441_production_attachment_contract.gd"

## Current-authority bridge layered over the immutable D2 1441 v8 production
## validator. Capture-time no-credit metadata stays frozen; only the catalog and
## runtime authority advance to v9. This contract never writes or recaptures.

const V9_REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const V9_CONTRACTS_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const V9_CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const V9_SCHEMA_PATH := "res://discovery/facades/facade-recognition-catalog.schema.json"
const V9_LOADER_PATH := "res://game/scripts/world/facades/facade_runtime_registry_loader.gd"
const V9_COMPILER_PATH := "res://tools/build_facade_recognition_registry.mjs"
const V9_REGISTRY_SHA256 := "26dcf64a34cf92aa7766c60940933190cdb5f9bc595dc23dc2f16fa01752e16c"
const V9_CONTRACTS_SHA256 := "8c61ea5601ab94852ac593b8658963b52cb5253aae22a2ff109f2e46771caa93"
const V9_CATALOG_SHA256 := "dc6d121d48621f98a203f2fea458316a46446a11e5f2a77d4064694322b2baa2"
const V9_SCHEMA_SHA256 := "8896fb9dcfd1cb48fc4bf0ed7ddc5fa50fdf7ec31335111291a1e2a2006e106d"
const V9_LOADER_SHA256 := "32e63c8774c0589856f15ac2ca0e7458e1cdce1403380e50a6ba99bd5185bd26"
const V9_COMPILER_SHA256 := "4d6da1afa587d2dd8aefb24775d6ba838dd39ac60131985c9c899209572d3e74"

const FROZEN_ROOT := "res://evidence/first-playable/d2-1441-production-v8-staging-2026-09-05-009"
const FROZEN_STATIC_PATH := FROZEN_ROOT + "/capture-manifest.json"
const FROZEN_TELEMETRY_PATH := FROZEN_ROOT + "/motion-telemetry.json"
const FROZEN_VISUAL_MOTION_PATH := FROZEN_ROOT + "/visual-motion.json"
const FROZEN_PACKAGE_RECEIPT_PATH := FROZEN_ROOT + "/package-verification-receipt.json"
const FROZEN_MECHANICAL_REVIEW_PATH := "res://evidence/reviews/d2-1441-production-v8-staging-2026-09-05-009-INDEPENDENT_CONTRACT_AUDIT.md"
const FROZEN_VISUAL_REVIEW_PATH := "res://evidence/reviews/d2-1441-production-v8-staging-2026-09-05-009-INDEPENDENT_VISUAL_REVIEW.md"
const FROZEN_FOCUSED_PATH := "res://game/tests/headless_d2_1441_production_attachment_contract.gd"
const FROZEN_PACKAGE_CONTRACT_PATH := "res://game/tests/headless_d2_1441_production_attachment_package_contract.gd"
const FROZEN_CAPTURE_GENERATOR_PATH := "res://game/tests/d2_1441_production_attachment_capture.gd"
const FROZEN_STATIC_SHA256 := "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885"
const FROZEN_TELEMETRY_SHA256 := "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd"
const FROZEN_VISUAL_MOTION_SHA256 := "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad"
const FROZEN_TREE_SHA256 := "e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43"
const FROZEN_PACKAGE_RECEIPT_SHA256 := "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061"
const FROZEN_MECHANICAL_REVIEW_SHA256 := "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884"
const FROZEN_VISUAL_REVIEW_SHA256 := "075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144"
const FROZEN_FOCUSED_SHA256 := "6014498a52676ec93c955ccc672db3d6845c90a0b5e7dbfd1f05df3cf1792986"
const FROZEN_PACKAGE_CONTRACT_SHA256 := "cc2942797cda2c1cb2bef97bd2ef757fc993a6dfce223bbbd96d91e89230e580"
const FROZEN_CAPTURE_GENERATOR_SHA256 := "921acef14ef5503569f8d07bcafdb03f6bccf78570742a8a835962e845a858cf"

const D2_UNIT_ID := "physical-building:w95934105"
const D2_ADAPTER_ID := "active-adapter:d2-1441-live:building:w95934105:wall"
const D2_CONTENT_MODE := "active_d2_1441_paired_replacement"
const FROZEN_WORLD := {"rows": 735, "meshes": 959, "surfaces": 974, "triangles": 69252, "bodies": 466, "shapes": 466}
const B225_WORLD := {"rows": 735, "meshes": 952, "surfaces": 967, "triangles": 67716, "bodies": 466, "shapes": 466}
const D2_RUNTIME_ASSET_PATHS := [
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
const FROZEN_SOURCE_HASHES := {
	"res://project.godot": "305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af",
	"res://export_presets.cfg": "e54969d6127ee55691113217e5129a7c5e9b3e841168a6b91f3fc74ba278456f",
	"res://game/scripts/main.gd": "1c284eb4d8ee5954500fe36c3ab6845bc7233728da26f5f6848dd8de9a627232",
	"res://game/scripts/world/world_chunk_builder.gd": "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a",
	"res://game/resources/facades/d2_1441_chinook_live_replacement.json": "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111",
	"res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd": "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1",
	"res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd": "6c0bf201bbb38a424453f753471cb7cb8060d0323e2386a9fda3bad84acd5933",
	"res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json": "ebb6be74a630ad405030938dc7d27bc6fed46b2d6892a847ee653d374df57f75",
	"res://game/scripts/world/facades/site_12_housing_kit.gd": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
	"res://generated/world/chunks/x_-1__z_-1.json": "5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
}
const FROZEN_APP_ROOT := "res://build/d2-1441-production-v8-staging-2026-09-05-009/Treasure Island First Playable.app"
const FROZEN_APP_FILES := {
	"Contents/Info.plist": "12210013168f4197b156c151636a81d27285741b3d2cdd138740d09853a9f085",
	"Contents/MacOS/Treasure Island First Playable": "e40c888a66f044c5a267ef027d94e99fd8009104462a7ca193b249b6fb6d7cfd",
	"Contents/PkgInfo": "7e50a30efad50208a173203ced60818d693bb61266b75aa10927d1a2adce80cb",
	"Contents/Resources/PrivacyInfo.xcprivacy": "0535353bb08c25b8ce5ed9ac7e442a5994f402e0f6cbc4bed668cfc63c2ceac3",
	"Contents/Resources/Treasure Island First Playable.pck": "c7660d21680649d137af52e2057a23aaa7efab9292c4e427c3e2ef79d1ea80c3",
	"Contents/Resources/icon.icns": "779ff524928785811d6d4c61f47a26491160b1092db9b610e85fcdfd9b2d2b2a",
	"Contents/_CodeSignature/CodeResources": "c4765d7d959f04d8f880f893db3ed74e0d1d74928908345fa16a92402f0d0b1e",
}


func _run() -> void:
	_require(_frozen_inputs_match(), "Frozen -009 packet, app, reviews, v8 validators, or reviewed source bytes drifted.")
	_require(_postpromotion_authority_matches(), "D2 1441 v9 authority, exact +1 receipt, adapter projection, or topology ownership drifted.")
	var chunk := _json(CHUNK_PATH)
	var records := chunk.get("records", []) as Array
	var wall := _record_for_key(records, WALL_KEY)
	var roof := _record_for_key(records, ROOF_KEY)
	_require(FileAccess.get_sha256(CHUNK_PATH) == ADAPTER.TARGET_CHUNK_SHA256, "Frozen target chunk bytes drifted.")
	_require(ADAPTER.source_dependency_hashes_match() and ADAPTER.runtime_dependency_closure_exists(), "Reviewed D2 runtime closure drifted.")
	_require(_record_authority_matches(wall, roof), "The canonical/runtime/projection D2 row pins drifted.")
	_require(_adversarial_pair_contract(chunk, wall, roof), "D2 pair mutation matrix did not fail closed.")
	_require(_builder_rejects_partial_pair(chunk, WALL_KEY) and _builder_rejects_partial_pair(chunk, ROOF_KEY), "Canonical builder accepted a partial D2 pair.")

	var first := _build_pair(chunk, false)
	_require(bool(first.get("ok", false)), str(first.get("message", "First paired build failed.")))
	var first_signature := ""
	if bool(first.get("ok", false)):
		var host := first.host as Node3D
		root.add_child(host)
		await physics_frame
		await physics_frame
		var wall_root := first.wall as Node3D
		var roof_root := first.roof as Node3D
		_require(_live_node_contract_matches(wall_root, roof_root, wall), "Direct live D2 topology/material/ownership contract drifted.")
		_require(_old_roof_render_winding_is_rejected(roof_root), "Historical reversed D2 roof winding was accepted.")
		_require(_collision_and_spray_rays_match(wall_root, roof_root, wall), "Direct D2 collision/spray ownership drifted.")
		first_signature = _live_snapshot(wall_root, roof_root).sha256_text()
		host.queue_free()
		await process_frame
	var second := _build_pair(chunk, true)
	_require(bool(second.get("ok", false)), str(second.get("message", "Reverse-order paired build failed.")))
	if bool(second.get("ok", false)):
		var second_host := second.host as Node3D
		_require(not first_signature.is_empty() and first_signature == _live_snapshot(second.wall as Node3D, second.roof as Node3D).sha256_text(), "D2 pair build is not deterministic across source order.")
		second_host.free()
	_require(_unconsumed_plan_frees(chunk), "Unconsumed D2 plan did not free both results.")
	_require(_canonical_builder_stages_exact_pair(chunk, wall), "Canonical builder no longer stages the reviewed D2 pair exactly once.")
	await _ordinary_main_contract(wall)
	if _failures.is_empty():
		print("PASS: D2 1441 postpromotion v9 is exactly 9/213 with one +1 physical-unit receipt; frozen -009 no-credit packet/app/source inputs remain exact and ordinary main remains 735/959/974/69252/466/466")
	quit(1 if not _failures.is_empty() else 0)


func _frozen_inputs_match() -> bool:
	var exact_files := {
		FROZEN_STATIC_PATH: FROZEN_STATIC_SHA256,
		FROZEN_TELEMETRY_PATH: FROZEN_TELEMETRY_SHA256,
		FROZEN_VISUAL_MOTION_PATH: FROZEN_VISUAL_MOTION_SHA256,
		FROZEN_PACKAGE_RECEIPT_PATH: FROZEN_PACKAGE_RECEIPT_SHA256,
		FROZEN_MECHANICAL_REVIEW_PATH: FROZEN_MECHANICAL_REVIEW_SHA256,
		FROZEN_VISUAL_REVIEW_PATH: FROZEN_VISUAL_REVIEW_SHA256,
		FROZEN_FOCUSED_PATH: FROZEN_FOCUSED_SHA256,
		FROZEN_PACKAGE_CONTRACT_PATH: FROZEN_PACKAGE_CONTRACT_SHA256,
		FROZEN_CAPTURE_GENERATOR_PATH: FROZEN_CAPTURE_GENERATOR_SHA256,
	}
	for path: String in exact_files:
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(exact_files[path]):
			return false
	for path: String in FROZEN_SOURCE_HASHES:
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(FROZEN_SOURCE_HASHES[path]):
			return false
	for relative_path: String in FROZEN_APP_FILES:
		var path := FROZEN_APP_ROOT.path_join(relative_path)
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(FROZEN_APP_FILES[relative_path]):
			return false
	var receipt := _json(FROZEN_PACKAGE_RECEIPT_PATH)
	if str(receipt.get("capture_time_recognition_metric", "")) != "8/213" \
	or receipt.get("recognition_credit") != false or receipt.get("additional_recognition_credit") != false or receipt.get("promotion") != false \
	or int(receipt.get("bundle_file_count", -1)) != 7 \
	or str(receipt.get("bundle_identity_sha256", "")) != "81ae851ff3dffd90202e903939f1d6cda7eeb3cfff7e2c752492fa7ed0e1e129" \
	or str(receipt.get("pck_sha256", "")) != "c7660d21680649d137af52e2057a23aaa7efab9292c4e427c3e2ef79d1ea80c3" \
	or str(receipt.get("executable_sha256", "")) != "e40c888a66f044c5a267ef027d94e99fd8009104462a7ca193b249b6fb6d7cfd" \
	or receipt.get("downstream_evidence_hashes_bound_into_v8_authority") != false \
	or receipt.get("postcapture_catalog_or_registry_mutation") != false:
		return false
	for review_path: String in [FROZEN_MECHANICAL_REVIEW_PATH, FROZEN_VISUAL_REVIEW_PATH]:
		var text := FileAccess.get_file_as_string(review_path)
		if "PASS_FOR_1441_PROMOTION_NO_CREDIT" not in text or FROZEN_TREE_SHA256 not in text or "8/213" not in text:
			return false
	return true


func _postpromotion_authority_matches() -> bool:
	var authority_hashes := {
		V9_REGISTRY_PATH: V9_REGISTRY_SHA256,
		V9_CONTRACTS_PATH: V9_CONTRACTS_SHA256,
		V9_CATALOG_PATH: V9_CATALOG_SHA256,
		V9_SCHEMA_PATH: V9_SCHEMA_SHA256,
		V9_LOADER_PATH: V9_LOADER_SHA256,
		V9_COMPILER_PATH: V9_COMPILER_SHA256,
	}
	for path: String in authority_hashes:
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(authority_hashes[path]):
			return false
	var registry := _json(V9_REGISTRY_PATH)
	var catalog := _json(V9_CATALOG_PATH)
	var contracts := _json(V9_CONTRACTS_PATH)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted_ids := metric.get("accepted_physical_unit_ids", []) as Array
	var runtime_unit := _unit_for(registry.get("units", []) as Array, D2_UNIT_ID)
	var catalog_unit := _unit_for(catalog.get("units", []) as Array, D2_UNIT_ID)
	var runtime_receipts := runtime_unit.get("acceptance_records", []) as Array
	var catalog_receipts := catalog_unit.get("acceptance_records", []) as Array
	if str(registry.get("schema_version", "")) != "ti.facade-runtime-registry/9" \
	or str(catalog.get("schema_version", "")) != "ti.facade-recognition-catalog/9" \
	or str(contracts.get("schema_version", "")) != "ti.facade-runtime-adapter-contracts/8" \
	or str((registry.get("compatibility_contract", {}) as Dictionary).get("loader_api_version", "")) != "ti.facade-runtime-registry-loader/8" \
	or str((registry.get("compatibility_contract", {}) as Dictionary).get("compiler_version", "")) != "1.8.0" \
	or int(metric.get("numerator", -1)) != 9 or int(metric.get("denominator", -1)) != 213 or str(metric.get("display", "")) != "9/213" \
	or accepted_ids.size() != 9 or accepted_ids.count(D2_UNIT_ID) != 1 \
	or runtime_receipts.size() != 1 or catalog_receipts.size() != 1:
		return false
	if not _d2_receipt_matches(runtime_receipts[0] as Dictionary) or not _d2_receipt_matches(catalog_receipts[0] as Dictionary):
		return false
	var d2_adapters := _records_for(registry.get("active_runtime_adapters", []) as Array, "receiver_key", WALL_KEY)
	var d2_plans := _records_for(contracts.get("plans", []) as Array, "receiver_key", WALL_KEY)
	var b225_adapters := _records_for(registry.get("active_runtime_adapters", []) as Array, "receiver_key", "building:w95934119:wall")
	if d2_adapters.size() != 1 or d2_plans.size() != 1 or b225_adapters.size() != 1:
		return false
	var adapter := d2_adapters[0] as Dictionary
	var plan := d2_plans[0] as Dictionary
	var behavior := ((adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary)
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	var b225_geometry := ((((b225_adapters[0] as Dictionary).get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary)
	var paths := []
	for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
		paths.append(str((asset_value as Dictionary).get("path", "")))
	paths.sort()
	var expected_paths := D2_RUNTIME_ASSET_PATHS.duplicate()
	expected_paths.sort()
	var current_topology_ids := []
	for value: Variant in registry.get("active_runtime_adapters", []) as Array:
		var candidate := value as Dictionary
		var active_contract_value: Variant = candidate.get("active_runtime_contract", {})
		if not active_contract_value is Dictionary:
			continue
		var candidate_behavior_value: Variant = (active_contract_value as Dictionary).get("behavior_contract", {})
		if not candidate_behavior_value is Dictionary:
			continue
		var candidate_geometry := (candidate_behavior_value as Dictionary).get("geometry_contract", {}) as Dictionary
		if str(candidate_geometry.get("world_topology_scope", "")) == "current_integration_topology":
			current_topology_ids.append(str(candidate.get("adapter_id", "")))
	return str(adapter.get("adapter_id", "")) == D2_ADAPTER_ID \
		and str(adapter.get("runtime_content_mode", "")) == D2_CONTENT_MODE \
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted" \
		and (runtime_unit.get("active_runtime_adapter_ids", []) as Array) == [D2_ADAPTER_ID] \
		and str(runtime_unit.get("runtime_content_mode", "")) == "all_receivers_active_d2_1441_paired_replacement" \
		and str((runtime_unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "accepted" \
		and paths == expected_paths and paths.size() == 13 \
		and JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(behavior) \
		and (plan.get("executable_assets", []) as Array).size() == 3 \
		and _topology_matches(geometry, "current_integration_topology", FROZEN_WORLD) \
		and _topology_matches(b225_geometry, "pre_d2_1441_integration_live_parity", B225_WORLD) \
		and current_topology_ids == [D2_ADAPTER_ID]


func _d2_receipt_matches(receipt: Dictionary) -> bool:
	return str(receipt.get("review_id", "")) == "d2-1441-production-v8-staging-2026-09-05-009" \
		and str(receipt.get("review_kind", "")) == "independent_reference_recognition" and str(receipt.get("status", "")) == "accept" \
		and str(receipt.get("capture_time_recognition_metric", "")) == "8/213" and int(receipt.get("numerator_effect", -1)) == 1 \
		and str(receipt.get("evidence_manifest_sha256", "")) == FROZEN_STATIC_SHA256 \
		and str(receipt.get("motion_telemetry_manifest_sha256", "")) == FROZEN_TELEMETRY_SHA256 \
		and str(receipt.get("visual_motion_manifest_sha256", "")) == FROZEN_VISUAL_MOTION_SHA256 \
		and str(receipt.get("evidence_tree_sha256", "")) == FROZEN_TREE_SHA256 \
		and str(receipt.get("package_verification_receipt_sha256", "")) == FROZEN_PACKAGE_RECEIPT_SHA256 \
		and str(receipt.get("mechanical_review_receipt_sha256", "")) == FROZEN_MECHANICAL_REVIEW_SHA256 \
		and str(receipt.get("review_receipt_sha256", "")) == FROZEN_VISUAL_REVIEW_SHA256


func _records_for(records: Array, field: String, expected: String) -> Array:
	return records.filter(func(value: Variant) -> bool: return value is Dictionary and str((value as Dictionary).get(field, "")) == expected)


func _topology_matches(geometry: Dictionary, scope: String, expected: Dictionary) -> bool:
	return str(geometry.get("world_topology_scope", "")) == scope \
		and int(geometry.get("world_records", -1)) == int(expected.rows) \
		and int(geometry.get("world_mesh_instances", -1)) == int(expected.meshes) \
		and int(geometry.get("world_surfaces", -1)) == int(expected.surfaces) \
		and int(geometry.get("world_triangles", -1)) == int(expected.triangles) \
		and int(geometry.get("world_static_bodies", -1)) == int(expected.bodies) \
		and int(geometry.get("world_shapes", -1)) == int(expected.shapes)
