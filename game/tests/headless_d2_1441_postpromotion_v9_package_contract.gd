extends "res://game/tests/headless_d2_1441_production_attachment_package_contract.gd"

## Source and direct-mounted-PCK bridge for accepted D2 1441 v9 authority.
## The inherited package/runtime checks stay unchanged. This bridge binds the
## immutable -009 no-credit capture to the later single-unit +1 promotion and
## never loads evidence or an alternate activation route in mounted mode.

const V9_REGISTRY_SHA256 := "26dcf64a34cf92aa7766c60940933190cdb5f9bc595dc23dc2f16fa01752e16c"
const V9_CONTRACTS_SHA256 := "8c61ea5601ab94852ac593b8658963b52cb5253aae22a2ff109f2e46771caa93"
const V9_CATALOG_SHA256 := "dc6d121d48621f98a203f2fea458316a46446a11e5f2a77d4064694322b2baa2"
const V9_SCHEMA_SHA256 := "8896fb9dcfd1cb48fc4bf0ed7ddc5fa50fdf7ec31335111291a1e2a2006e106d"
const V9_LOADER_SHA256 := "32e63c8774c0589856f15ac2ca0e7458e1cdce1403380e50a6ba99bd5185bd26"
const V9_COMPILER_SHA256 := "4d6da1afa587d2dd8aefb24775d6ba838dd39ac60131985c9c899209572d3e74"
const V9_FOCUSED_SHA256 := "64a7bdc8d770254df26a56b51493d9e8c7e29a1f786e2ed5888822b7747b870b"
const V9_FOCUSED_PATH := "res://game/tests/headless_d2_1441_postpromotion_v9_contract.gd"
const V9_PACKAGE_PATH := "res://game/tests/headless_d2_1441_postpromotion_v9_package_contract.gd"
const V9_D2_ADAPTER_ID := "active-adapter:d2-1441-live:building:w95934105:wall"
const V9_B225_RECEIVER := "building:w95934119:wall"
const V9_CAPTURE_TIME_METRIC := "8/213"
const V9_CURRENT_METRIC := "9/213"
const V9_CURRENT_WORLD := {"rows": 735, "meshes": 959, "surfaces": 974, "triangles": 69252, "bodies": 466, "shapes": 466}
const V9_B225_WORLD := {"rows": 735, "meshes": 952, "surfaces": 967, "triangles": 67716, "bodies": 466, "shapes": 466}
const V9_FROZEN_ROOT := "res://evidence/first-playable/d2-1441-production-v8-staging-2026-09-05-009"
const V9_FROZEN_FILES := {
	V9_FROZEN_ROOT + "/capture-manifest.json": "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885",
	V9_FROZEN_ROOT + "/motion-telemetry.json": "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd",
	V9_FROZEN_ROOT + "/visual-motion.json": "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad",
	V9_FROZEN_ROOT + "/package-verification-receipt.json": "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061",
	"res://evidence/reviews/d2-1441-production-v8-staging-2026-09-05-009-INDEPENDENT_CONTRACT_AUDIT.md": "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884",
	"res://evidence/reviews/d2-1441-production-v8-staging-2026-09-05-009-INDEPENDENT_VISUAL_REVIEW.md": "075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144",
	"res://game/tests/headless_d2_1441_production_attachment_contract.gd": "6014498a52676ec93c955ccc672db3d6845c90a0b5e7dbfd1f05df3cf1792986",
	"res://game/tests/headless_d2_1441_production_attachment_package_contract.gd": "cc2942797cda2c1cb2bef97bd2ef757fc993a6dfce223bbbd96d91e89230e580",
	"res://game/tests/d2_1441_production_attachment_capture.gd": "921acef14ef5503569f8d07bcafdb03f6bccf78570742a8a835962e845a858cf",
}
const V9_FROZEN_SOURCE_FILES := {
	"res://project.godot": "305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af",
	"res://export_presets.cfg": "e54969d6127ee55691113217e5129a7c5e9b3e841168a6b91f3fc74ba278456f",
	D2_MAIN_SCRIPT_PATH: "1c284eb4d8ee5954500fe36c3ab6845bc7233728da26f5f6848dd8de9a627232",
	D2_BUILDER_PATH: "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a",
	D2_CONFIG_PATH: "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111",
	D2_ADAPTER_PATH: "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1",
	D2_FACTORY_PATH: "6c0bf201bbb38a424453f753471cb7cb8060d0323e2386a9fda3bad84acd5933",
	D2_FACTORY_CONFIG_PATH: "ebb6be74a630ad405030938dc7d27bc6fed46b2d6892a847ee653d374df57f75",
	D2_KIT_PATH: "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
	D2_CHUNK_PATH: "5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b",
	D2_MANIFEST_PATH: "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
}
const V9_FROZEN_APP_ROOT := "res://build/d2-1441-production-v8-staging-2026-09-05-009/Treasure Island First Playable.app"
const V9_FROZEN_APP_FILES := {
	"Contents/Info.plist": "12210013168f4197b156c151636a81d27285741b3d2cdd138740d09853a9f085",
	"Contents/MacOS/Treasure Island First Playable": "e40c888a66f044c5a267ef027d94e99fd8009104462a7ca193b249b6fb6d7cfd",
	"Contents/PkgInfo": "7e50a30efad50208a173203ced60818d693bb61266b75aa10927d1a2adce80cb",
	"Contents/Resources/PrivacyInfo.xcprivacy": "0535353bb08c25b8ce5ed9ac7e442a5994f402e0f6cbc4bed668cfc63c2ceac3",
	"Contents/Resources/Treasure Island First Playable.pck": "c7660d21680649d137af52e2057a23aaa7efab9292c4e427c3e2ef79d1ea80c3",
	"Contents/Resources/icon.icns": "779ff524928785811d6d4c61f47a26491160b1092db9b610e85fcdfd9b2d2b2a",
	"Contents/_CodeSignature/CodeResources": "c4765d7d959f04d8f880f893db3ed74e0d1d74928908345fa16a92402f0d0b1e",
}
const V9_MOUNTED_EXCLUDED_PATHS := [
	D2_CATALOG_PATH,
	D2_SCHEMA_PATH,
	"res://discovery/",
	"res://evidence/",
	"res://source_assets/",
	"res://override.cfg",
	"res://game/scenes/world/facades/site_12_housing/d2_1441_chinook_standalone_hero_prototype.tscn",
	"res://game/tests/d2_1441_chinook_standalone_hero_capture.gd",
	"res://game/tests/d2_1441_chinook_standalone_hero_capture.gd.uid",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_contract.gd",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_contract.gd.uid",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_evidence_contract.gd",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_evidence_contract.gd.uid",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_package_contract.gd",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_package_contract.gd.uid",
]


func _d2_run() -> void:
	var mounted := FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot")
	var arguments := _v9_mounted_arguments()
	if mounted:
		_d2_require(not arguments.is_empty(), "Mounted D2 v9 audit requires one absolute PCK path and exact independently computed SHA-256.")
		if not arguments.is_empty():
			_d2_require(_d2_pck_matches(arguments), "Mounted D2 v9 PCK identity drifted.")
	else:
		_d2_require(arguments.is_empty(), "Source D2 v9 package contract received mounted-only arguments.")
		_d2_require(_v9_frozen_inputs_match(), "Frozen -009 packet/app/source/validator bytes drifted.")
		_v9_source_boundary_checks()
	_d2_require(not _d2_exists("res://override.cfg"), "Temporary capture override is present.")
	_d2_require(_v9_authority_matches(mounted), "D2 v9 authority is not exactly 9/213 with one +1 receipt over frozen capture-time 8/213 no-credit evidence.")
	_v9_validate_package_resources(mounted)
	if mounted:
		for path: String in V9_MOUNTED_EXCLUDED_PATHS:
			_d2_require(not _d2_exists_with_remaps(path), "Mounted D2 v9 PCK exposes private evidence or a standalone activation route: %s." % path)
	else:
		var ordinary := await _d2_ordinary_main_matches()
		_d2_require(bool(ordinary.get("ok", false)), str(ordinary.get("message", "D2 v9 ordinary-main package check failed.")))
	if not _d2_failed:
		if mounted:
			print("PASS: mounted D2 1441 postpromotion v9 PCK is exact and private; current authority is 9/213 while frozen capture-time authority remains 8/213 no-credit")
		else:
			print("PASS: source D2 1441 postpromotion v9 package bridge is exact; frozen -009 packet/app/source bytes remain immutable and ordinary main remains 735/959/974/69252/466/466")
	quit(1 if _d2_failed else 0)


func _v9_mounted_arguments() -> Dictionary:
	var parsed := {}
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mounted-d2-1441-postpromotion-v9-pck="):
			if parsed.has("pck"):
				return {}
			parsed["pck"] = argument.trim_prefix("--mounted-d2-1441-postpromotion-v9-pck=")
		elif argument.begins_with("--mounted-d2-1441-postpromotion-v9-pck-sha256="):
			if parsed.has("sha256"):
				return {}
			parsed["sha256"] = argument.trim_prefix("--mounted-d2-1441-postpromotion-v9-pck-sha256=")
		else:
			_d2_failed = true
			push_error("D2_1441_POSTPROMOTION_V9_PACKAGE_FAIL: unknown mounted argument %s" % argument)
			return {}
	if parsed.is_empty():
		return {}
	if parsed.size() != 2 or not str(parsed.get("pck", "")).is_absolute_path() or not _d2_lower_sha256(str(parsed.get("sha256", ""))):
		_d2_failed = true
		return {}
	return parsed


func _v9_frozen_inputs_match() -> bool:
	for path: String in V9_FROZEN_FILES:
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(V9_FROZEN_FILES[path]):
			return false
	for path: String in V9_FROZEN_SOURCE_FILES:
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(V9_FROZEN_SOURCE_FILES[path]):
			return false
	for relative_path: String in V9_FROZEN_APP_FILES:
		var path := V9_FROZEN_APP_ROOT.path_join(relative_path)
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(V9_FROZEN_APP_FILES[relative_path]):
			return false
	var receipt := _d2_json(V9_FROZEN_ROOT + "/package-verification-receipt.json")
	return str(receipt.get("capture_time_recognition_metric", "")) == V9_CAPTURE_TIME_METRIC \
		and receipt.get("recognition_credit") == false \
		and receipt.get("additional_recognition_credit") == false \
		and receipt.get("promotion") == false \
		and receipt.get("postcapture_catalog_or_registry_mutation") == false \
		and int(receipt.get("bundle_file_count", -1)) == 7 \
		and str(receipt.get("bundle_identity_sha256", "")) == "81ae851ff3dffd90202e903939f1d6cda7eeb3cfff7e2c752492fa7ed0e1e129" \
		and str(receipt.get("pck_sha256", "")) == "c7660d21680649d137af52e2057a23aaa7efab9292c4e427c3e2ef79d1ea80c3" \
		and str(receipt.get("executable_sha256", "")) == "e40c888a66f044c5a267ef027d94e99fd8009104462a7ca193b249b6fb6d7cfd"


func _v9_source_boundary_checks() -> void:
	var authority := {
		D2_REGISTRY_PATH: V9_REGISTRY_SHA256,
		D2_CONTRACTS_PATH: V9_CONTRACTS_SHA256,
		D2_CATALOG_PATH: V9_CATALOG_SHA256,
		D2_SCHEMA_PATH: V9_SCHEMA_SHA256,
		D2_LOADER_PATH: V9_LOADER_SHA256,
		D2_COMPILER_PATH: V9_COMPILER_SHA256,
		V9_FOCUSED_PATH: V9_FOCUSED_SHA256,
	}
	for path: String in authority:
		_d2_require(FileAccess.file_exists(path) and FileAccess.get_sha256(path) == str(authority[path]), "D2 v9 source authority hash drifted: %s." % path)
	_d2_require(D2_LIVE.source_dependency_hashes_match(), "Reviewed D2 factory/material source bytes drifted.")
	_d2_require(D2_LIVE.runtime_dependency_closure_exists(), "D2 executable resource closure is incomplete.")
	_d2_require(_d2_builder_seam_matches(), "Canonical D2 builder seam is no longer one ordered atomic direct route.")
	var preset := FileAccess.get_file_as_string(D2_EXPORT_PRESET_PATH)
	for token: String in ["discovery/*", "discovery/**/*", "evidence/*", "evidence/**/*", "source_assets/*", "source_assets/**/*"]:
		_d2_require(token in preset, "Export preset lost private boundary %s." % token)


func _v9_authority_matches(mounted: bool) -> bool:
	if FileAccess.get_sha256(D2_REGISTRY_PATH) != V9_REGISTRY_SHA256 or FileAccess.get_sha256(D2_CONTRACTS_PATH) != V9_CONTRACTS_SHA256:
		return false
	if not mounted and (FileAccess.get_sha256(D2_CATALOG_PATH) != V9_CATALOG_SHA256 or FileAccess.get_sha256(D2_SCHEMA_PATH) != V9_SCHEMA_SHA256 or FileAccess.get_sha256(D2_LOADER_PATH) != V9_LOADER_SHA256):
		return false
	var registry := _d2_json(D2_REGISTRY_PATH)
	var contracts := _d2_json(D2_CONTRACTS_PATH)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted := metric.get("accepted_physical_unit_ids", []) as Array
	var unit := _d2_record_for(registry.get("units", []) as Array, "unit_id", D2_UNIT_ID)
	var receipts := unit.get("acceptance_records", []) as Array
	var adapters := (registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return value is Dictionary and str((value as Dictionary).get("receiver_key", "")) == D2_WALL_KEY)
	var b225_adapters := (registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return value is Dictionary and str((value as Dictionary).get("receiver_key", "")) == V9_B225_RECEIVER)
	var plans := (contracts.get("plans", []) as Array).filter(func(value: Variant) -> bool: return value is Dictionary and str((value as Dictionary).get("receiver_key", "")) == D2_WALL_KEY)
	if receipts.size() != 1 or adapters.size() != 1 or b225_adapters.size() != 1 or plans.size() != 1:
		return false
	var receipt := receipts[0] as Dictionary
	var adapter := adapters[0] as Dictionary
	var behavior := ((adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary)
	var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	var ownership := behavior.get("ownership_contract", {}) as Dictionary
	var replacement := behavior.get("replacement_contract", {}) as Dictionary
	var truth := behavior.get("truth_boundary", {}) as Dictionary
	var b225_geometry := ((((b225_adapters[0] as Dictionary).get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary)
	var current_topology_owners: Array[String] = []
	for value: Variant in registry.get("active_runtime_adapters", []) as Array:
		var current_adapter := value as Dictionary
		var active_contract_value: Variant = current_adapter.get("active_runtime_contract", {})
		if not active_contract_value is Dictionary:
			continue
		var current_behavior_value: Variant = (active_contract_value as Dictionary).get("behavior_contract", {})
		if not current_behavior_value is Dictionary:
			continue
		var current_geometry := (current_behavior_value as Dictionary).get("geometry_contract", {}) as Dictionary
		if str(current_geometry.get("world_topology_scope", "")) == "current_integration_topology":
			current_topology_owners.append(str(current_adapter.get("adapter_id", "")))
	var runtime_paths := []
	for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
		runtime_paths.append(str((asset_value as Dictionary).get("path", "")))
	var expected_paths := D2_REQUIRED_RUNTIME_CLOSURE.duplicate()
	runtime_paths.sort()
	expected_paths.sort()
	return str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/9" \
		and str(contracts.get("schema_version", "")) == "ti.facade-runtime-adapter-contracts/8" \
		and str((registry.get("compatibility_contract", {}) as Dictionary).get("catalog_schema_version", "")) == "ti.facade-recognition-catalog/9" \
		and str((registry.get("compatibility_contract", {}) as Dictionary).get("compiler_version", "")) == "1.8.0" \
		and str((registry.get("compatibility_contract", {}) as Dictionary).get("loader_api_version", "")) == "ti.facade-runtime-registry-loader/8" \
		and int(metric.get("numerator", -1)) == 9 and int(metric.get("denominator", -1)) == 213 and str(metric.get("display", "")) == V9_CURRENT_METRIC \
		and accepted.size() == 9 and accepted.count(D2_UNIT_ID) == 1 \
		and (registry.get("active_runtime_adapters", []) as Array).size() == 8 \
		and (contracts.get("plans", []) as Array).size() == 17 \
		and str(unit.get("runtime_content_mode", "")) == "all_receivers_active_d2_1441_paired_replacement" \
		and (unit.get("active_runtime_adapter_ids", []) as Array) == [V9_D2_ADAPTER_ID] \
		and _v9_receipt_matches(receipt) \
		and str(adapter.get("adapter_id", "")) == V9_D2_ADAPTER_ID \
		and str(adapter.get("attachment_kind", "")) == "active_d2_1441_paired_wall_roof_replacement" \
		and runtime_paths == expected_paths and runtime_paths.size() == 13 \
		and (plans[0] as Dictionary).get("behavior_contract", {}) == behavior \
		and ((plans[0] as Dictionary).get("executable_assets", []) as Array).size() == 3 \
		and str(acceptance.get("capture_time_recognition_metric", "")) == V9_CAPTURE_TIME_METRIC \
		and str(acceptance.get("evidence_manifest_sha256", "")) == "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885" \
		and str(acceptance.get("motion_telemetry_manifest_sha256", "")) == "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd" \
		and str(acceptance.get("visual_motion_manifest_sha256", "")) == "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad" \
		and str(acceptance.get("evidence_tree_sha256", "")) == "e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43" \
		and str(acceptance.get("package_verification_receipt_sha256", "")) == "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061" \
		and str(acceptance.get("mechanical_review_receipt_sha256", "")) == "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884" \
		and str(acceptance.get("independent_live_review_receipt_sha256", "")) == "075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144" \
		and int(acceptance.get("numerator_effect", -1)) == 1 \
		and _v9_topology_matches(geometry, "current_integration_topology", V9_CURRENT_WORLD) \
		and _v9_topology_matches(b225_geometry, "pre_d2_1441_integration_live_parity", V9_B225_WORLD) \
		and str(geometry.get("visual_geometry_signature", "")) == "b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195" \
		and str(ownership.get("live_ownership_signature", "")) == "fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d" \
		and int(ownership.get("wall_collision_triangles", -1)) == 32 and int(ownership.get("roof_collision_triangles", -1)) == 10 \
		and _v9_int_array_matches(replacement.get("mapped_public_run_indices", []) as Array, [10, 12, 13, 15]) \
		and _v9_int_array_matches(replacement.get("protected_run_indices", []) as Array, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14]) \
		and truth.get("capture_time_candidate_promoted") == false and truth.get("capture_time_recognition_credit") == false \
		and current_topology_owners == [V9_D2_ADAPTER_ID]


func _v9_receipt_matches(receipt: Dictionary) -> bool:
	return str(receipt.get("review_id", "")) == "d2-1441-production-v8-staging-2026-09-05-009" \
		and str(receipt.get("review_kind", "")) == "independent_reference_recognition" \
		and str(receipt.get("status", "")) == "accept" \
		and str(receipt.get("capture_time_recognition_metric", "")) == V9_CAPTURE_TIME_METRIC \
		and int(receipt.get("numerator_effect", -1)) == 1 \
		and str(receipt.get("evidence_manifest_sha256", "")) == "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885" \
		and str(receipt.get("motion_telemetry_manifest_sha256", "")) == "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd" \
		and str(receipt.get("visual_motion_manifest_sha256", "")) == "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad" \
		and str(receipt.get("evidence_tree_sha256", "")) == "e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43" \
		and str(receipt.get("package_verification_receipt_sha256", "")) == "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061" \
		and str(receipt.get("mechanical_review_receipt_sha256", "")) == "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884" \
		and str(receipt.get("review_receipt_sha256", "")) == "075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144"


func _v9_validate_package_resources(mounted: bool) -> void:
	for path: String in [D2_MAIN_SCENE_PATH, D2_WORLD_SCENE_PATH, D2_MANIFEST_PATH, D2_CHUNK_PATH, D2_REGISTRY_PATH, D2_CONTRACTS_PATH, V9_FOCUSED_PATH, V9_PACKAGE_PATH]:
		_d2_require(_d2_exists(path), "D2 v9 package closure is missing %s." % path)
	_d2_require(get_script() != null and get_script().resource_path == V9_PACKAGE_PATH, "The D2 v9 package bridge is not the executing script.")
	_d2_require(ResourceLoader.load(V9_FOCUSED_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) != null, "D2 v9 focused bridge is not remap-loadable.")
	for path: String in D2_REQUIRED_RUNTIME_CLOSURE:
		_d2_require(_d2_exists(path), "D2 v9 runtime closure is missing %s." % path)
		if path.get_extension() != "json":
			_d2_require(ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) != null, "D2 v9 runtime resource is not remap-loadable: %s." % path)
		elif not mounted:
			_d2_require(not _d2_json(path).is_empty(), "D2 v9 source JSON is invalid: %s." % path)


func _v9_topology_matches(geometry: Dictionary, scope: String, expected: Dictionary) -> bool:
	return str(geometry.get("world_topology_scope", "")) == scope \
		and int(geometry.get("world_records", -1)) == int(expected.get("rows", -1)) \
		and int(geometry.get("world_mesh_instances", -1)) == int(expected.get("meshes", -1)) \
		and int(geometry.get("world_surfaces", -1)) == int(expected.get("surfaces", -1)) \
		and int(geometry.get("world_triangles", -1)) == int(expected.get("triangles", -1)) \
		and int(geometry.get("world_static_bodies", -1)) == int(expected.get("bodies", -1)) \
		and int(geometry.get("world_shapes", -1)) == int(expected.get("shapes", -1))


func _v9_int_array_matches(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for index in expected.size():
		if int(actual[index]) != int(expected[index]):
			return false
	return true
