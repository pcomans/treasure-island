extends SceneTree

const SOURCE_RECEIPT_PATH := "res://discovery/facades/PRECOMMIT_PACKAGE_SANITIZATION_SOURCE_PROVENANCE.json"
const SOURCE_RECEIPT_SHA256 := "269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333"
const EXPORT_PRESET_PATH := "res://export_presets.cfg"
const CONFIG_HASHES := {
	"res://game/resources/facades/building_1_hero_model.json": "f10bc92a6e74cbae41347e742e6c68c50faccddbd52ab3ecce210ac8243bc6e9",
	"res://game/resources/facades/building_1_public_front_believability.json": "7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806",
	"res://game/resources/facades/d1_current/d1_b201_public_wsw.json": "30bc1f62e5fa44c60bdcfb1bfd4f6f679d391618fa213373e571080face6ec6c",
	"res://game/resources/facades/d1_current/d1_b225_nnw_long.json": "dc3591df4a68af19b5fa53f402ed15d5e3f83946c4a113f024d5b7d41f2f82b8",
	"res://game/resources/facades/d1_current/d1_current_standalone_pair.json": "fdf00bba0562036f499a5a64e47e5e1b695d49d6cb4ada7acafd450b3dcfefb9",
	"res://game/resources/facades/d1_current/repairs/d1_b225_nnw_long_cladding_repair_v1.json": "7c1c2d508f78236590c6d413604be60b3a5c48865878e69d294177d05c48d166",
	"res://game/resources/facades/dormitory_369_standalone_hero_prototype.json": "b02b098bfeca628cd6a71e7393897d53f5f46dfd0efddd915e316c2dd5204c2e",
}
const HISTORICAL_CONFIG_HASHES := {
	"B1-HERO-AUTHORITY": "6c99f43550631a1e6bca1f52764ad23c6a5b8b891403f30c78ff9b9545192690",
	"B1-PUBLIC-FRONT-AUTHORITY": "e11710374f837e15b45adf3b6df0e762a6793b363e6c3109870e1bf2f7a0ee0e",
	"D1-B201-AUTHORITY": "3d53efbb0577c9b5e52a2ada4d79a710b95e41faead0bdcdd41cd4f2d862a0fe",
	"D1-B225-AUTHORITY": "63e4f80cc7716146dc1fef46c7678e4da856755377c84ff33f972c0cc0c1f639",
	"D1-PAIR-AUTHORITY": "c73f8c8da4d30a4e4ebe3e94cde10d63f98377bf5b636a1e12cee92c9bcaafe4",
	"D1-B225-REPAIR-AUTHORITY": "89d34d33b48c93c0a6c90d46ff8120cd36c5f897ebe1fc9ea2ee2cd97a3db22c",
	"DORMITORY-369-AUTHORITY": "a6086d13a986bdd4a6c281b75ec7fb58524257ae4b8ea6b849840a324cc59dc2",
}
const PUBLISHABLE_SOURCE_HASHES := {
	"res://evidence/first-playable/d1-b225-standalone-cladding-repair-v1-2026-09-04/capture-manifest.json": "22cbe9edec6e33ccbfcc2c71d719c2c1bc646358fb46242be802affe371b2ec5",
	"res://evidence/first-playable/d1-b225-standalone-cladding-repair-v1-2026-09-04/verification-results.txt": "52faf8e6a03d8c96bdfb7b1e5a8120257187cc68dcd2cfa331ae455eae9fd6ad",
	"res://discovery/facades/GENAI_TEXTURE_PILOT_V1.md": "a4dbca10ca3fb8cc419784fac295de0b3f114ad8f9d2a06a4ceb2e8318bfad36",
}
const BANNED_MOUNTED_ROOTS := [
	"res://discovery/",
	"res://evidence/",
	"res://source_assets/",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mounted := OS.get_cmdline_user_args().has("--mounted-package")
	_require(_configs_match(), "One of the seven publishable facade configs drifted or contains a source-only locator.")
	_require(_config_semantics_match(), "A package-safe receipt, standalone boundary, or source-pixel nonclaim drifted.")
	if mounted:
		_require(FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot"), "Mounted mode did not receive an exported project.binary-only package.")
		_require(not FileAccess.file_exists(SOURCE_RECEIPT_PATH), "Source-only provenance receipt leaked into the mounted package.")
		for path: String in BANNED_MOUNTED_ROOTS:
			_require(not DirAccess.dir_exists_absolute(path) and not FileAccess.file_exists(path), "Mounted package exposes banned authoring root: %s" % path)
	else:
		_require(FileAccess.file_exists("res://project.godot"), "Source mode did not run from the repository project.")
		_require(_source_receipt_matches(), "The source-only historical provenance receipt drifted.")
		_require(_publishable_source_files_match(), "A specifically sanitized publishable source/evidence file drifted or regained a private path.")
		_require(_export_boundary_matches(), "The canonical export filter does not exclude discovery, evidence, source assets, or source pixels.")
	if not _failed:
		print("PASS: precommit package sanitization scope=7 facade configs mode=%s current_hashes=7 historical_receipt_bindings=7 publishable_source_files=%d source_locators_in_runtime=0 private_paths=0 source_pixels=0" % [("mounted" if mounted else "source"), (0 if mounted else PUBLISHABLE_SOURCE_HASHES.size())])
	quit(1 if _failed else 0)


func _configs_match() -> bool:
	for path_value: Variant in CONFIG_HASHES:
		var path := str(path_value)
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(CONFIG_HASHES[path_value]):
			push_error("Sanitized config hash drift: %s" % path)
			return false
		var text := FileAccess.get_file_as_string(path)
		var parsed: Variant = JSON.parse_string(text)
		if not parsed is Dictionary or not _text_is_package_safe(text):
			push_error("Sanitized config boundary drift: %s" % path)
			return false
	return true


func _config_semantics_match() -> bool:
	var hero := _json("res://game/resources/facades/building_1_hero_model.json")
	var hero_authority := hero.get("authority", {}) as Dictionary
	var public_front := _json("res://game/resources/facades/building_1_public_front_believability.json")
	var public_authority := public_front.get("authority", {}) as Dictionary
	var pair := _json("res://game/resources/facades/d1_current/d1_current_standalone_pair.json")
	var pair_authority := pair.get("authoritative_pins", {}) as Dictionary
	var repair := _json("res://game/resources/facades/d1_current/repairs/d1_b225_nnw_long_cladding_repair_v1.json")
	var repair_generated := repair.get("generated_albedo", {}) as Dictionary
	var dorm := _json("res://game/resources/facades/dormitory_369_standalone_hero_prototype.json")
	var dorm_truth := dorm.get("truth_boundary", {}) as Dictionary
	return str(hero_authority.get("source_provenance_receipt_id", "")) == "B1-HERO-AUTHORITY" \
		and str(hero_authority.get("source_provenance_receipt_sha256", "")) == SOURCE_RECEIPT_SHA256 \
		and str(public_authority.get("source_provenance_receipt_id", "")) == "B1-PUBLIC-FRONT-AUTHORITY" \
		and str(public_authority.get("source_provenance_receipt_sha256", "")) == SOURCE_RECEIPT_SHA256 \
		and str(pair_authority.get("source_provenance_receipt_id", "")) == "D1-PAIR-AUTHORITY" \
		and str(pair_authority.get("source_provenance_receipt_sha256", "")) == SOURCE_RECEIPT_SHA256 \
		and not bool(pair.get("runtime_attachment", true)) \
		and int(pair.get("live_placement_count", -1)) == 0 \
		and (repair_generated.get("reference_images_or_source_pixels", []) as Array).is_empty() \
		and str((repair_generated.get("initial_output", {}) as Dictionary).get("opaque_output_id", "")).begins_with("imagegen:") \
		and str((repair_generated.get("selected_source_output", {}) as Dictionary).get("opaque_output_id", "")).begins_with("imagegen:") \
		and not bool(repair.get("runtime_attachment", true)) \
		and bool(dorm_truth.get("prototype_only", false)) \
		and not bool(dorm_truth.get("runtime_attachment", true)) \
		and not bool(dorm_truth.get("reference_pixels_stored_or_copied", true))


func _source_receipt_matches() -> bool:
	if FileAccess.get_sha256(SOURCE_RECEIPT_PATH) != SOURCE_RECEIPT_SHA256:
		return false
	var receipt := _json(SOURCE_RECEIPT_PATH)
	var records := receipt.get("records", {}) as Dictionary
	if str(receipt.get("schema_version", "")) != "ti.precommit-package-sanitization-source-provenance/1" \
		or not str(receipt.get("scope", "")).contains("excluded from the canonical game package") \
		or records.size() != 8 \
		or not _text_has_no_private_path(FileAccess.get_file_as_string(SOURCE_RECEIPT_PATH)):
		return false
	for receipt_id_value: Variant in HISTORICAL_CONFIG_HASHES:
		var receipt_id := str(receipt_id_value)
		var record := records.get(receipt_id, {}) as Dictionary
		if str(record.get("historical_runtime_config_sha256", "")) != str(HISTORICAL_CONFIG_HASHES[receipt_id_value]):
			return false
	return true


func _publishable_source_files_match() -> bool:
	for path_value: Variant in PUBLISHABLE_SOURCE_HASHES:
		var path := str(path_value)
		if FileAccess.get_sha256(path) != str(PUBLISHABLE_SOURCE_HASHES[path_value]) \
		or not _text_has_no_private_path(FileAccess.get_file_as_string(path)):
			return false
	return true


func _export_boundary_matches() -> bool:
	var preset := FileAccess.get_file_as_string(EXPORT_PRESET_PATH)
	for pattern: String in ["discovery/*", "evidence/*", "source_assets/*"]:
		if pattern not in preset:
			return false
	return true


func _text_is_package_safe(text: String) -> bool:
	var lower := text.to_lower()
	for token: String in [
		"discovery/",
		"evidence/",
		"source_assets/",
		"http" + "://",
		"https" + "://",
		"file" + "://",
		"/" + "users" + "/",
		"/" + "volumes" + "/",
		"path_outside_project",
	]:
		if token in lower:
			return false
	return true


func _text_has_no_private_path(text: String) -> bool:
	var lower := text.to_lower()
	return "/" + "users" + "/" not in lower and "/" + "volumes" + "/" not in lower and "file" + "://" not in lower


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_failed = true
		push_error(message)
	return condition
