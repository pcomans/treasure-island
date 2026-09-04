extends SceneTree

const ROOT := "res://evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04"
const MANIFEST_PATH := ROOT + "/capture-manifest.json"
const INVENTORY_PATH := ROOT + "/asset-inventory.sha256"
const HISTORICAL_MIGRATION_RECEIPT_PATH := ROOT + "/capture-time-sanitization-provenance.json"
const HISTORICAL_MIGRATION_RECEIPT_SHA256 := "da887e603e5783a5d3ce61ac9c6fa03ede8374639f55bfc7fa3c6ef498a6b9ce"
const SOURCE_RECEIPT_PATH := "res://discovery/facades/PRECOMMIT_PACKAGE_SANITIZATION_SOURCE_PROVENANCE.json"
const SOURCE_RECEIPT_SHA256 := "269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333"
const EXPECTED_MANIFEST_SHA256 := "35e60ea88ce9c932de4ecb02a1cdbb21af50e84497bd24e0738d9d5d7bb26f18"
const EXPECTED_INVENTORY_SHA256 := "0cbef82469498cbfb3a9da5dbf69b10b39503615f83f13ad2487ce871eac4dd3"
const EXPECTED_DOC_HASHES := {
	ROOT + "/README.md": "2810be2b32b63689e01250fbf743ec64cc5e03d18ee28876e3f7c589d4ade04c",
	ROOT + "/dirty-scope-audit.txt": "249e180cad0f82b920114037b1a2f15f53e23724a42aee0939aaf49c48830fa8",
	ROOT + "/generated-data-diff.txt": "3d2354181f5e13cee1a50214c5cf31d5c71358af19cacb3da9b76f9d4498d626",
	ROOT + "/verification-results.txt": "72d63737d6e64cf440c41454b529f23151171ecd9695aec8d7c21c219937d436",
}
const EXPECTED_CAPTURE_HASHES := {
	"01-b201-grounded-complete-wsw.png": "ab245665f03b2c4373a7504bb4979fb11fac9b15e8bd195c5b4c3eb837472a3c",
	"02-b201-grounded-canopy-depth.png": "d4f25df5a2cce0aed879de8329fe16605b5beb5d74b5a65fb3a12760ac44a621",
	"03-b201-register-service-close.png": "7855568fdd054bb65d4c4ae120bfaca8bef1ea91260c267af16df0897b3622cb",
	"04-b201-changed-light-oblique.png": "601d85f9493eda46284d89157e6ae21cc01288e65d4477f3d4aa42c309f0fd90",
	"05-b225-grounded-complete-nnw.png": "21b656561966ac75d6e473796728d0d9657f4019be08476b4ccf45d866934122",
	"06-b225-grounded-clerestory-oblique.png": "30597aa75d628550dcee8d06a80343ec5603074dfdfd53a3fc2c85a4e0770bc8",
	"07-b225-clerestory-course-close.png": "45299789b409017ca7b989b3bdc30f8773618f63e6f81076259e62a5af9b70b9",
	"08-b225-changed-light-oblique.png": "2d63b8fd64a8266934b9017249ccb213fe134a217f789a991d74f1858a5a8d45",
	"09-pair-grounded-overview.png": "dde3401df4f4006a31a2129f90292c454060ab8a0094c78f1cf03c75178d6877",
}
const EXPECTED_CAPTURE_TIME_FILES := {
	"res://game/resources/facades/d1_current/d1_b201_public_wsw.json": "3d53efbb0577c9b5e52a2ada4d79a710b95e41faead0bdcdd41cd4f2d862a0fe",
	"res://game/resources/facades/d1_current/d1_b225_nnw_long.json": "63e4f80cc7716146dc1fef46c7678e4da856755377c84ff33f972c0cc0c1f639",
	"res://game/resources/facades/d1_current/d1_current_standalone_pair.json": "c73f8c8da4d30a4e4ebe3e94cde10d63f98377bf5b636a1e12cee92c9bcaafe4",
	"res://game/scripts/world/facades/d1_current_standalone_prototypes.gd": "797bbb81e7f772f3fab3989d358772be4f1b16cb7e31a05571463e0d6ec31a5e",
	"res://game/scripts/world/facades/d1_current_standalone_prototypes.gd.uid": "3f53790e7295f65af6d7df9a0ccfda9f7ce7f1cd4aa8e1ca1dca7457d22a650e",
	"res://game/scenes/world/facades/d1_current/d1_current_standalone_prototype_pair.tscn": "0fdd5d356deb57664549db95fd04e123290c1fb9490b8024569e997616893d7f",
	"res://game/tests/d1_current_standalone_prototype_capture.gd": "93aac927e71e665ed4a15e2721c2260d2f69808c8af0c0280db8f2650df3eee9",
	"res://game/tests/d1_current_standalone_prototype_capture.gd.uid": "ef6cd70068e060b35adfd46635fed001ba5061c485f1c2b35ac425ab9f1a7468",
	"res://game/tests/headless_d1_current_standalone_prototype_contract.gd": "eafe1f8b20cf4a276ad8cda97112acc6870fca183c6d73916dd5bf306a7d099e",
	"res://game/tests/headless_d1_current_standalone_prototype_contract.gd.uid": "61c790ad474f4f2a5e41edf34e737a8f9f2ba162a6445a5b10cb148c8f7ef65f",
}
const EXPECTED_CURRENT_CONFIGS := {
	"res://game/resources/facades/d1_current/d1_b201_public_wsw.json": "30bc1f62e5fa44c60bdcfb1bfd4f6f679d391618fa213373e571080face6ec6c",
	"res://game/resources/facades/d1_current/d1_b225_nnw_long.json": "dc3591df4a68af19b5fa53f402ed15d5e3f83946c4a113f024d5b7d41f2f82b8",
	"res://game/resources/facades/d1_current/d1_current_standalone_pair.json": "fdf00bba0562036f499a5a64e47e5e1b695d49d6cb4ada7acafd450b3dcfefb9",
}
const EXPECTED_CURRENT_PROTOTYPE_CONTRACT_SHA256 := "f36d49c875a4c0000eaf6b1a21ac2273c02840baed3eab683f70f0027fb7aaed"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "D1 capture manifest drifted.")
	_require(FileAccess.get_sha256(INVENTORY_PATH) == EXPECTED_INVENTORY_SHA256, "D1 asset inventory drifted.")
	for path_value: Variant in EXPECTED_DOC_HASHES:
		var path := str(path_value)
		_require(FileAccess.get_sha256(path) == str(EXPECTED_DOC_HASHES[path_value]), "D1 evidence document drifted: %s" % path)
	for path_value: Variant in EXPECTED_CAPTURE_TIME_FILES:
		var path := str(path_value)
		if not EXPECTED_CURRENT_CONFIGS.has(path) and path != "res://game/tests/headless_d1_current_standalone_prototype_contract.gd":
			_require(FileAccess.get_sha256(path) == str(EXPECTED_CAPTURE_TIME_FILES[path_value]), "D1 unchanged implementation/capture input drifted: %s" % path)
	for path_value: Variant in EXPECTED_CURRENT_CONFIGS:
		var path := str(path_value)
		_require(FileAccess.get_sha256(path) == str(EXPECTED_CURRENT_CONFIGS[path_value]), "D1 current package-safe config drifted: %s" % path)
	_require(FileAccess.get_sha256("res://game/tests/headless_d1_current_standalone_prototype_contract.gd") == EXPECTED_CURRENT_PROTOTYPE_CONTRACT_SHA256, "D1 current package-safe prototype contract drifted.")
	_require(_source_receipt_matches(), "D1 historical config hashes are not reconciled through the sealed source-only provenance receipt.")
	_require(_historical_migration_receipt_matches(), "D1 four-file capture-time/current sanitization receipt drifted.")
	var manifest := _json(MANIFEST_PATH)
	_require(_manifest_matches(manifest), "D1 evidence manifest scope/renderer/topology/review contract failed.")
	_require(_captures_match(manifest), "D1 native capture hashes/dimensions/coverage contract failed.")
	_require(_inventory_matches(), "D1 asset inventory content does not pin all expected evidence and inputs.")
	_require(_review_boundary_matches(), "D1 evidence text promoted pending technical proof to recognition/live acceptance.")
	if not _failed:
		print("PASS: nine original 1440x900 native macOS Forward+/Metal D1 standalone captures retain immutable four-file capture-time provenance while the path-addressed ledger validates current package-safe bytes; geometry and review meaning are unchanged")
	quit(1 if _failed else 0)


func _manifest_matches(manifest: Dictionary) -> bool:
	var topology := manifest.get("topology", {}) as Dictionary
	var signatures := manifest.get("geometry_signatures", {}) as Dictionary
	var materials := manifest.get("materials", {}) as Dictionary
	return str(manifest.get("schema_version", "")) == "ti.d1-current-standalone-native-evidence/1" \
		and str(manifest.get("review_status", "")) == "pending_independent_recognition_and_bar_review_not_self_accepted" \
		and str(manifest.get("display_driver", "")) == "macOS" \
		and str(manifest.get("video_adapter", "")).contains("Apple M2") \
		and str(manifest.get("rendering_method", "")) == "Forward+" \
		and str(manifest.get("rendering_driver", "")) == "Metal" \
		and manifest.get("viewport", []) == [1440.0, 900.0] \
		and int(manifest.get("capture_count", 0)) == 9 \
		and not bool(manifest.get("runtime_attachment", true)) \
		and not bool(manifest.get("exact_receiver_layout", true)) \
		and int(topology.get("batch_count", 0)) == 10 \
		and int(topology.get("box_instance_count", 0)) == 290 \
		and int(topology.get("triangle_count", 0)) == 3480 \
		and int(topology.get("collision_nodes", -1)) == 0 \
		and int(topology.get("navigation_nodes", -1)) == 0 \
		and int(topology.get("spray_nodes", -1)) == 0 \
		and str(signatures.get("w34313545", "")) == "57573bc19d6c6a45b946827e76a346c592d5238a310e923a30a41b149f963511" \
		and str(signatures.get("w95934119", "")) == "179d898c4635917743e967819998256c7fe4938981da69e7d4664e1e7e13b58a" \
		and str(signatures.get("pair", "")) == "17c560633517963489b76430729bb6476065bb0d9a6385b3a913103a778c32ad" \
		and int(materials.get("local_standard_materials", 0)) == 8 \
		and int(materials.get("bitmap_textures", -1)) == 0 \
		and int(materials.get("generated_images", -1)) == 0 \
		and int(materials.get("random_or_noise_generators", -1)) == 0 \
		and (manifest.get("observed_scope", []) as Array).size() == 2 \
		and (manifest.get("blocked_claims", []) as Array).size() >= 8


func _captures_match(manifest: Dictionary) -> bool:
	var captures := manifest.get("captures", []) as Array
	if captures.size() != EXPECTED_CAPTURE_HASHES.size():
		return false
	var seen := {}
	var grounded_or_close := 0
	var changed_light := 0
	for capture_value: Variant in captures:
		var capture := capture_value as Dictionary
		var filename := str(capture.get("file", ""))
		if not EXPECTED_CAPTURE_HASHES.has(filename) or seen.has(filename):
			return false
		seen[filename] = true
		var path := ROOT.path_join(filename)
		var expected_hash := str(EXPECTED_CAPTURE_HASHES[filename])
		var dimensions := capture.get("dimensions", []) as Array
		var luminance := capture.get("sampled_luminance", {}) as Dictionary
		if str(capture.get("sha256", "")) != expected_hash \
		or FileAccess.get_sha256(path) != expected_hash \
		or dimensions.size() != 2 or int(dimensions[0]) != 1440 or int(dimensions[1]) != 900 \
		or int(capture.get("bytes", 0)) < 70000 \
		or float(luminance.get("range", 0.0)) < 0.9:
			return false
		var image := Image.load_from_file(path)
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900):
			return false
		var view_kind := str(capture.get("view_kind", ""))
		if "grounded" in view_kind:
			grounded_or_close += 1
		if "changed_light" in view_kind:
			changed_light += 1
	return seen.size() == EXPECTED_CAPTURE_HASHES.size() and grounded_or_close >= 7 and changed_light == 2


func _inventory_matches() -> bool:
	var content := FileAccess.get_file_as_string(INVENTORY_PATH)
	for filename_value: Variant in EXPECTED_CAPTURE_HASHES:
		var filename := str(filename_value)
		if "%s  evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04/%s" % [str(EXPECTED_CAPTURE_HASHES[filename_value]), filename] not in content:
			return false
	for path_value: Variant in EXPECTED_CAPTURE_TIME_FILES:
		var path := str(path_value)
		var ledger_hash := str(EXPECTED_CAPTURE_TIME_FILES[path_value])
		if EXPECTED_CURRENT_CONFIGS.has(path):
			ledger_hash = str(EXPECTED_CURRENT_CONFIGS[path])
		elif path == "res://game/tests/headless_d1_current_standalone_prototype_contract.gd":
			ledger_hash = EXPECTED_CURRENT_PROTOTYPE_CONTRACT_SHA256
		if "%s  %s" % [ledger_hash, path.trim_prefix("res://")] not in content:
			return false
	return "%s  evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04/capture-manifest.json" % EXPECTED_MANIFEST_SHA256 in content \
		and "%s  evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04/capture-time-sanitization-provenance.json" % HISTORICAL_MIGRATION_RECEIPT_SHA256 in content


func _source_receipt_matches() -> bool:
	if FileAccess.get_sha256(SOURCE_RECEIPT_PATH) != SOURCE_RECEIPT_SHA256:
		return false
	var receipt := _json(SOURCE_RECEIPT_PATH)
	var records := receipt.get("records", {}) as Dictionary
	return str(receipt.get("schema_version", "")) == "ti.precommit-package-sanitization-source-provenance/1" \
		and str((records.get("D1-B201-AUTHORITY", {}) as Dictionary).get("historical_runtime_config_sha256", "")) == str(EXPECTED_CAPTURE_TIME_FILES["res://game/resources/facades/d1_current/d1_b201_public_wsw.json"]) \
		and str((records.get("D1-B225-AUTHORITY", {}) as Dictionary).get("historical_runtime_config_sha256", "")) == str(EXPECTED_CAPTURE_TIME_FILES["res://game/resources/facades/d1_current/d1_b225_nnw_long.json"]) \
		and str((records.get("D1-PAIR-AUTHORITY", {}) as Dictionary).get("historical_runtime_config_sha256", "")) == str(EXPECTED_CAPTURE_TIME_FILES["res://game/resources/facades/d1_current/d1_current_standalone_pair.json"])


func _historical_migration_receipt_matches() -> bool:
	if FileAccess.get_sha256(HISTORICAL_MIGRATION_RECEIPT_PATH) != HISTORICAL_MIGRATION_RECEIPT_SHA256:
		return false
	var receipt := _json(HISTORICAL_MIGRATION_RECEIPT_PATH)
	var files := receipt.get("migrated_files", {}) as Dictionary
	if str(receipt.get("schema_version", "")) != "ti.d1-current-standalone-capture-time-sanitization-provenance/1" \
		or str(receipt.get("capture_manifest_sha256", "")) != EXPECTED_MANIFEST_SHA256 \
		or files.size() != 4:
		return false
	for path_value: Variant in files:
		var repository_path := str(path_value)
		var res_path := "res://" + repository_path
		var record := files[path_value] as Dictionary
		if not EXPECTED_CAPTURE_TIME_FILES.has(res_path) \
			or str(record.get("capture_time_sha256", "")) != str(EXPECTED_CAPTURE_TIME_FILES[res_path]):
			return false
		var expected_current := EXPECTED_CURRENT_PROTOTYPE_CONTRACT_SHA256
		if EXPECTED_CURRENT_CONFIGS.has(res_path):
			expected_current = str(EXPECTED_CURRENT_CONFIGS[res_path])
		elif res_path != "res://game/tests/headless_d1_current_standalone_prototype_contract.gd":
			return false
		if str(record.get("current_package_safe_sha256_at_migration", "")) != expected_current \
			or FileAccess.get_sha256(res_path) != expected_current:
			return false
	return true


func _review_boundary_matches() -> bool:
	var manifest_text := FileAccess.get_file_as_string(MANIFEST_PATH)
	var readme := FileAccess.get_file_as_string(ROOT + "/README.md")
	var verification := FileAccess.get_file_as_string(ROOT + "/verification-results.txt")
	return "pending_independent_recognition_and_bar_review_not_self_accepted" in manifest_text \
		and "not self-accepted" in readme \
		and "not evidence of live receiver placement" in readme \
		and "REVIEW STATE\npending_independent_recognition_and_bar_review_not_self_accepted" in verification \
		and "independently accepted" not in manifest_text.to_lower() \
		and "recognition verdict: pass" not in readme.to_lower()


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not value is Dictionary:
		_fail("Invalid D1 evidence JSON: %s" % path)
		return {}
	return value as Dictionary


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	_failed = true
	push_error(message)
