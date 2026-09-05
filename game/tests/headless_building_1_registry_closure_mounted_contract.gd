extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const ADAPTER_CONTRACTS_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const PUBLIC_FRONT_CONFIG_PATH := "res://game/resources/facades/building_1_public_front_believability.json"
const REGISTRY_SHA256 := "65edf085437bc3fa2b22869406cc8a2c33297b6cc9d48b205e301e367efc734b"
const ADAPTER_CONTRACTS_SHA256 := "503c8d02439d0846389d5d57e2b2a26d8e42ee6156ff08f489de6e9dc4325222"
const PUBLIC_FRONT_CONFIG_SHA256 := "7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806"
const RECEIVER_SOURCES := {
	"building:r16681702:wall": "r16681702",
	"building:w1222720021:wall": "w1222720021",
}
const EXPECTED_RUNTIME_ASSETS := {
	"res://game/resources/facades/building_1_hero_model.json": "f10bc92a6e74cbae41347e742e6c68c50faccddbd52ab3ecce210ac8243bc6e9",
	PUBLIC_FRONT_CONFIG_PATH: PUBLIC_FRONT_CONFIG_SHA256,
	"res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres": "41c1c31d4a78da25d4abfac59e82fe919fbb539afa479ab7601d0fb51939d59f",
	"res://game/resources/materials/world/building_1/building_1_bronze.tres": "7948c9fca74345f4ff5e57a44191beb59300847b66cc54ddc176c5ca1b315ca3",
	"res://game/resources/materials/world/building_1/building_1_canopy_underside.tres": "661a7b8cfaef2394e47a42f9bbd04df5fdfbb2cd4be9e6733d5bf3101817cea9",
	"res://game/resources/materials/world/building_1/building_1_light_trim.tres": "6e543d57ff078c267e952f633f4cee232e0743e30218d2f341dc3f31e4a4c8d9",
	"res://game/resources/materials/world/building_1/building_1_projecting_base_stone.tres": "8bdd85aa10ac78c9225c59aad5ed9d26266ae517ea3f5910b8be3daf41f131ab",
	"res://game/resources/materials/world/building_1/building_1_reveal_shadow.tres": "2e1f36f163c037fe060a1ecfcdcc5dd062849290a96c508970384585b176e14a",
	"res://game/resources/materials/world/building_1/building_1_roof_metal.tres": "8bee442442f8b7bc3004cd3f703ce4e21eb9bc3b1f4d3d8800b02a77268329c8",
	"res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres": "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a",
	"res://game/scripts/world/facades/building_1_hero_model.gd": "e5b11fc7f971ea33bb38c84d3106f8883de0486774f58a5a8310d49d56aa55a5",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := _arguments()
	_require(not args.is_empty(), "Mounted B1 audit requires one absolute PCK path and its independently computed SHA-256.")
	if not args.is_empty():
		_require(_pck_matches(args), "Mounted B1 audit PCK identity drifted.")
	_require(FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot"), "Mounted B1 audit did not receive an exported project.binary-only package.")
	_require(not FileAccess.file_exists("res://override.cfg") and not ResourceLoader.exists("res://override.cfg"), "Temporary capture override leaked into the mounted package.")
	_require(not FileAccess.file_exists("res://discovery/facades/facade-recognition-catalog.json"), "Source catalog leaked into the mounted package.")
	_require(FileAccess.get_sha256(REGISTRY_PATH) == REGISTRY_SHA256, "Mounted runtime registry hash drifted.")
	_require(FileAccess.get_sha256(ADAPTER_CONTRACTS_PATH) == ADAPTER_CONTRACTS_SHA256, "Mounted adapter-contract hash drifted.")
	_require(FileAccess.get_sha256(PUBLIC_FRONT_CONFIG_PATH) == PUBLIC_FRONT_CONFIG_SHA256, "Mounted public-front config hash drifted.")
	var registry := _json(REGISTRY_PATH)
	var contracts := _json(ADAPTER_CONTRACTS_PATH)
	var public_front := _json(PUBLIC_FRONT_CONFIG_PATH)
	_require(_version_contract(registry, contracts), "Mounted registry/adapter v6/v5/1.5 compatibility matrix drifted.")
	_require(str(public_front.get("schema_version", "")) == "ti.building-1-public-front-believability/1" and FileAccess.get_file_as_string(PUBLIC_FRONT_CONFIG_PATH).contains("\"entrance_group_gap\": 0.90"), "Mounted public-front scalar/config schema drifted.")
	_validate_receivers(registry, contracts)
	_validate_mounted_resources()
	if not _failed:
		print("PASS: mounted B1 registry closure is exact and remap-aware: registry /6 %s; adapter /5 %s; loader /5; compiler 1.5.0; two receiver/source bindings; identical 11-asset metadata sets; public config %s; source catalog/override absent" % [REGISTRY_SHA256, ADAPTER_CONTRACTS_SHA256, PUBLIC_FRONT_CONFIG_SHA256])
	quit(1 if _failed else 0)


func _arguments() -> Dictionary:
	var parsed := {}
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mounted-b1-pck="):
			parsed["pck"] = argument.trim_prefix("--mounted-b1-pck=")
		elif argument.begins_with("--mounted-b1-pck-sha256="):
			parsed["sha256"] = argument.trim_prefix("--mounted-b1-pck-sha256=")
		else:
			push_error("Unknown mounted B1 audit argument: %s" % argument)
			return {}
	return parsed if parsed.size() == 2 else {}


func _pck_matches(args: Dictionary) -> bool:
	var path := str(args.get("pck", ""))
	var expected_sha256 := str(args.get("sha256", ""))
	return path.is_absolute_path() \
		and expected_sha256.length() == 64 \
		and FileAccess.file_exists(path) \
		and FileAccess.get_sha256(path) == expected_sha256


func _version_contract(registry: Dictionary, contracts: Dictionary) -> bool:
	var compatibility := registry.get("compatibility_contract", {}) as Dictionary
	var build := contracts.get("build_contract", {}) as Dictionary
	var loader := contracts.get("loader_contract", {}) as Dictionary
	return str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/6" \
		and str(compatibility.get("catalog_schema_version", "")) == "ti.facade-recognition-catalog/6" \
		and str(compatibility.get("compiler_version", "")) == "1.5.0" \
		and str(compatibility.get("loader_api_version", "")) == "ti.facade-runtime-registry-loader/5" \
		and not bool(compatibility.get("forward_compatible", true)) \
		and str(compatibility.get("unknown_version_policy", "")) == "reject" \
		and str(contracts.get("schema_version", "")) == "ti.facade-runtime-adapter-contracts/5" \
		and str(build.get("authoring_catalog_sha256", "")) == "ab8797e86d5985c4b64670a22577394656c6388bb463f83c157a411663fa7b57" \
		and str(build.get("compiler_version", "")) == "1.5.0" \
		and str(build.get("runtime_registry_schema_version", "")) == "ti.facade-runtime-registry/6" \
		and str(loader.get("api_version", "")) == "ti.facade-runtime-registry-loader/5" \
		and not bool(loader.get("instantiation_authorized", true)) \
		and str(loader.get("unknown_version_policy", "")) == "reject"


func _validate_receivers(registry: Dictionary, contracts: Dictionary) -> void:
	var registry_adapters := registry.get("active_runtime_adapters", []) as Array
	var plans := contracts.get("plans", []) as Array
	for receiver_value: Variant in RECEIVER_SOURCES:
		var receiver := str(receiver_value)
		var expected_source := str(RECEIVER_SOURCES[receiver_value])
		var adapter_matches := _records_for_receiver(registry_adapters, receiver)
		var plan_matches := _records_for_receiver(plans, receiver)
		_require(adapter_matches.size() == 1 and plan_matches.size() == 1, "%s does not have exactly one registry adapter and one plan." % receiver)
		if adapter_matches.size() != 1 or plan_matches.size() != 1:
			continue
		var adapter := adapter_matches[0] as Dictionary
		var plan := plan_matches[0] as Dictionary
		var active_contract := adapter.get("active_runtime_contract", {}) as Dictionary
		var registry_assets := _asset_map(adapter.get("runtime_assets", []) as Array)
		var plan_assets := _asset_map(plan.get("runtime_assets", []) as Array)
		_require(str(adapter.get("source_key", "")) == expected_source and str(plan.get("source_key", "")) == expected_source, "%s source mapping drifted." % receiver)
		_require(str(adapter.get("runtime_content_mode", "")) == "active_building_1_hero" and str(plan.get("content_mode", "")) == "active_building_1_hero", "%s content mode drifted." % receiver)
		_require((adapter.get("runtime_asset_projections", []) as Array).is_empty() and (plan.get("projection_descriptor_ids", []) as Array).is_empty(), "%s acquired a pathless projection." % receiver)
		_require(str(active_contract.get("public_front_config_sha256", "")) == PUBLIC_FRONT_CONFIG_SHA256, "%s public-front contract hash drifted." % receiver)
		_require(registry_assets == EXPECTED_RUNTIME_ASSETS and plan_assets == EXPECTED_RUNTIME_ASSETS and registry_assets == plan_assets, "%s does not carry the exact identical 11-asset metadata set." % receiver)
		var executable := plan.get("executable_assets", []) as Array
		_require(executable.size() == 1 and str((executable[0] as Dictionary).get("path", "")) == "res://game/scripts/world/facades/building_1_hero_model.gd" and str((executable[0] as Dictionary).get("sha256", "")) == str(EXPECTED_RUNTIME_ASSETS["res://game/scripts/world/facades/building_1_hero_model.gd"]), "%s executable asset contract drifted." % receiver)


func _validate_mounted_resources() -> void:
	for path_value: Variant in EXPECTED_RUNTIME_ASSETS:
		var path := str(path_value)
		if path.ends_with(".json"):
			_require(FileAccess.file_exists(path) and FileAccess.get_sha256(path) == str(EXPECTED_RUNTIME_ASSETS[path_value]), "Mounted raw JSON asset is missing or hash-drifted: %s." % path)
		else:
			_require(ResourceLoader.exists(path), "Mounted remapped resource is missing: %s." % path)
			if ResourceLoader.exists(path):
				_require(ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) != null, "Mounted remapped resource is not loadable: %s." % path)


func _records_for_receiver(records: Array, receiver: String) -> Array:
	var matches := []
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("receiver_key", "")) == receiver:
			matches.append(record)
	return matches


func _asset_map(assets: Array) -> Dictionary:
	var mapped := {}
	for value: Variant in assets:
		var asset := value as Dictionary
		var path := str(asset.get("path", ""))
		if path.is_empty() or mapped.has(path):
			return {}
		mapped[path] = str(asset.get("sha256", ""))
	return mapped


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("FAIL [building_1_registry_closure_mounted]: %s" % message)
	return false
