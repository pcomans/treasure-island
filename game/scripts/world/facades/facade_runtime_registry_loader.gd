class_name FacadeRuntimeRegistryLoader
extends RefCounted

const DEFAULT_REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const DEFAULT_ADAPTER_CONTRACT_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const DEFAULT_LOADER_PATH := "res://game/scripts/world/facades/facade_runtime_registry_loader.gd"
const REGISTRY_SCHEMA_VERSION := "ti.facade-runtime-registry/5"
const ADAPTER_CONTRACT_SCHEMA_VERSION := "ti.facade-runtime-adapter-contracts/4"
const CATALOG_SCHEMA_VERSION := "ti.facade-recognition-catalog/5"
const COMPILER_VERSION := "1.4.0"
const LOADER_API_VERSION := "ti.facade-runtime-registry-loader/4"
const UNKNOWN_VERSION_POLICY := "reject"
const EXPECTED_UNIT_COUNT := 213
const EXPECTED_RECEIVER_COUNT := 214
const EXPECTED_SOURCE_RECORD_COUNT := 215
const EXPECTED_ADAPTER_COUNT := 14
const EXPECTED_READY_ADAPTER_COUNT := 8
const EXPECTED_DISABLED_ADAPTER_COUNT := 6
const EXPECTED_PROJECTION_DESCRIPTOR_COUNT := 13
const EXPECTED_PROJECTION_OCCURRENCE_COUNT := 13
const EXPECTED_REFERENCE_RECOGNIZABLE_COUNT := 6
const EXPECTED_REFERENCE_RECOGNIZABLE_UNIT_IDS := [
	"physical-building:r16681702",
	"physical-building:w1222720021",
	"physical-building:w1249412093",
	"physical-building:w1249412094",
	"physical-building:w291189336",
	"physical-building:w34313540",
]
const EXPECTED_REVIEW_RECEIPTS := {
	"physical-building:r16681702": ["b12858438d6522b7f3cf42fa06392648d16ee3e0c418eb5e807a3ee1be770c2a", "ebeef887b37c6845c6c8fa3f25e06706351fe7c1dab0e1a3b0eaf47dfb773017"],
	"physical-building:w1222720021": ["fb952a31151805078d1e386117ed965aa0649ffddcd17874d13493b5dd4239bb", "dbe9745f5356b2309e820c2b47987ee4463518eaf4afd77fcd37df0edc8d437a"],
	"physical-building:w1249412093": ["9e4364eaf78412c58bfcac1bad1f4f35241f48a1b373976cdfa42638ce57b680", "e1ab8f526aed22a6234fff1d2fcc5eae5d2245df4260a25a5705cd37a158a921"],
	"physical-building:w1249412094": ["37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8", "23fd6eff4ab8d9696af9d1ecc19bea50537cc824ecf3a7bebdf4fa191cd039d9"],
	"physical-building:w291189336": ["63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9", "54d434c9283a0e2d86aa836e6a21672a8756e5a170cb5724d66066e799223930"],
	"physical-building:w34313540": ["1aee23943b3df4f600b9a4e4fce86d839b75ce575a924de4ca8b187bd9120046", "4b92b71df3c7f8f7dfbb285bd7566b3f422a32be45f810d532328e15d008f5be"],
}
const BUILDING_3_RECEIVER := "building:w34313540:wall"
const NAVY_CHAPEL_RECEIVER := "building:w291189336:wall"
const ISLE_HOUSE_UNIT := "physical-building:w1249412094"
const ISLE_HOUSE_HIGH_RECEIVER := "building-composite:w1249412094:w1282547786:wall"
const ISLE_HOUSE_LOW_RECEIVER := "building-composite:w1249412094:w1282547787:wall"
const ISLE_HOUSE_LIVE_REVIEW_RECEIPT_SHA256 := "37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8"
const ISLE_HOUSE_LIVE_SIGNATURE := "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981"
const ISLE_HOUSE_REPAIR_SIGNATURE := "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69"
const NAVY_CHAPEL_LIVE_REVIEW_RECEIPT_SHA256 := "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9"
const NAVY_CHAPEL_GEOMETRY_SIGNATURE := "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46"
const NAVY_CHAPEL_OWNERSHIP_SIGNATURE := "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7"
const NAVY_CHAPEL_RUNTIME_ASSETS := [
	"res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json",
	"res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres",
	"res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd",
	"res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd",
]
const BUILDING_3_RUNTIME_ASSETS := [
	"res://game/resources/facades/building_3_600_california_ene_layout.json",
	"res://game/resources/facades/building_3_hero_massing.json",
	"res://game/resources/materials/world/building_3/building_3_shadow_recess.tres",
	"res://game/resources/materials/world/building_3/building_3_teal_door.tres",
	"res://game/resources/materials/world/building_3/building_3_white_primary.tres",
	"res://game/scenes/world/facades/building_3/building_3_600_california_facade.tscn",
	"res://game/scenes/world/facades/building_3/building_3_ene_modules.tscn",
	"res://game/scripts/world/facades/building_3_600_california_facade.gd",
	"res://game/scripts/world/massing/building_3_600_california_massing.gd",
]
const ALLOWED_EXECUTABLE_ROOTS := [
	"res://game/scenes/world/",
	"res://game/scripts/world/",
]
const ALLOWED_EXECUTABLE_KINDS := ["gdscript", "packed_scene"]
const TEXT_ASSET_EXTENSIONS := ["gd", "gdshader", "json", "tres", "tscn"]

var _loaded := false
var _registry := {}
var _adapter_contracts := {}
var _units_by_id := {}
var _receivers_by_key := {}
var _adapters_by_id := {}
var _plans_by_receiver := {}
var _projections_by_id := {}
var _last_error_code := ""
var _last_error_message := ""


func load_default(expected_registry_sha256: String = "") -> Dictionary:
	return load_from_path(DEFAULT_REGISTRY_PATH, expected_registry_sha256)


func load_from_path(registry_path: String, expected_registry_sha256: String = "") -> Dictionary:
	_reset()
	if not _require(_is_safe_runtime_json_path(registry_path), "dirty_path", "Registry path is not an allowed game-package JSON path: %s" % registry_path):
		return _status()
	if not _require(FileAccess.file_exists(registry_path), "registry_missing", "Runtime registry is missing: %s" % registry_path):
		return _status()
	var registry_sha256 := FileAccess.get_sha256(registry_path)
	if not expected_registry_sha256.is_empty() and not _require(registry_sha256 == expected_registry_sha256, "registry_hash_drift", "Runtime registry hash does not match the caller's exact pin."):
		return _status()
	var registry_value: Variant = _read_json(registry_path, "registry_invalid_json")
	if _has_error():
		return _status()
	if not _require(registry_value is Dictionary, "registry_invalid_shape", "Runtime registry root must be an object."):
		return _status()
	var registry := registry_value as Dictionary
	if not _validate_registry_header(registry):
		return _status()
	var reference := registry.get("adapter_contract", {}) as Dictionary
	var contract_path := str(reference.get("path", ""))
	if not _require(contract_path == DEFAULT_ADAPTER_CONTRACT_PATH and _is_safe_runtime_json_path(contract_path), "dirty_path", "Adapter-contract path is not the exact allowed package path."):
		return _status()
	if not _require(FileAccess.file_exists(contract_path), "adapter_contract_missing", "Runtime adapter contract is missing: %s" % contract_path):
		return _status()
	var contract_sha256 := FileAccess.get_sha256(contract_path)
	if not _require(contract_sha256 == str(reference.get("sha256", "")), "adapter_contract_hash_drift", "Runtime adapter-contract hash drifted from the registry pin."):
		return _status()
	var contract_value: Variant = _read_json(contract_path, "adapter_contract_invalid_json")
	if _has_error():
		return _status()
	if not _require(contract_value is Dictionary, "adapter_contract_invalid_shape", "Runtime adapter-contract root must be an object."):
		return _status()
	return load_from_data(registry, contract_value as Dictionary, registry_sha256, contract_sha256)


func load_from_data(registry: Dictionary, adapter_contracts: Dictionary, registry_sha256: String = "", adapter_contract_sha256: String = "") -> Dictionary:
	_reset()
	if not _validate_registry_header(registry):
		return _status()
	if not adapter_contract_sha256.is_empty() and not _require(adapter_contract_sha256 == str((registry.get("adapter_contract", {}) as Dictionary).get("sha256", "")), "adapter_contract_hash_drift", "Runtime adapter-contract hash drifted from the registry pin."):
		return _status()
	if not _validate_registry(registry):
		return _status()
	if not _validate_adapter_contracts(adapter_contracts, registry):
		return _status()
	_registry = registry.duplicate(true)
	_adapter_contracts = adapter_contracts.duplicate(true)
	_loaded = true
	return {
		"adapter_contract_sha256": adapter_contract_sha256,
		"disabled_adapter_receivers": EXPECTED_DISABLED_ADAPTER_COUNT,
		"ok": true,
		"package_safe_adapter_receivers": EXPECTED_READY_ADAPTER_COUNT,
		"receiver_count": _receivers_by_key.size(),
		"registry_sha256": registry_sha256,
		"unit_count": _units_by_id.size(),
	}


func is_loaded() -> bool:
	return _loaded


func get_unit_count() -> int:
	return _units_by_id.size() if _loaded else 0


func get_receiver_count() -> int:
	return _receivers_by_key.size() if _loaded else 0


func get_reference_recognition_metric() -> Dictionary:
	return (_registry.get("recognition_metric", {}) as Dictionary).duplicate(true) if _loaded else {}


func get_unit(unit_id: String) -> Dictionary:
	return (_units_by_id.get(unit_id, {}) as Dictionary).duplicate(true) if _loaded else {}


func get_receiver(receiver_key: String) -> Dictionary:
	return (_receivers_by_key.get(receiver_key, {}) as Dictionary).duplicate(true) if _loaded else {}


func get_content_mode(receiver_key: String) -> String:
	return str((_receivers_by_key.get(receiver_key, {}) as Dictionary).get("runtime_content_mode", "")) if _loaded else ""


func get_adapter_plan(receiver_key: String) -> Dictionary:
	return (_plans_by_receiver.get(receiver_key, {}) as Dictionary).duplicate(true) if _loaded else {}


func get_projection_descriptor(descriptor_id: String) -> Dictionary:
	return (_projections_by_id.get(descriptor_id, {}) as Dictionary).duplicate(true) if _loaded else {}


func resolve_executable_assets(receiver_key: String) -> Dictionary:
	if not _loaded:
		return _resolution_failure("registry_not_loaded", "Load and validate the registry before resolving an adapter.")
	var plan := _plans_by_receiver.get(receiver_key, {}) as Dictionary
	if plan.is_empty():
		return _resolution_failure("adapter_plan_missing", "No adapter plan exists for receiver %s." % receiver_key)
	if str(plan.get("integration_state", "")) != "package_safe_ready_for_integration":
		return {
			"disabled_reason_code": str(plan.get("disabled_reason_code", "")),
			"error_code": "adapter_hard_disabled",
			"error_message": "Adapter has one or more pathless source projections and cannot resolve or execute.",
			"ok": false,
			"projection_descriptor_ids": (plan.get("projection_descriptor_ids", []) as Array).duplicate(),
			"receiver_key": receiver_key,
		}
	var resources := []
	for asset_value: Variant in plan.get("executable_assets", []) as Array:
		var asset := asset_value as Dictionary
		var path := str(asset.get("path", ""))
		var kind := str(asset.get("resource_kind", ""))
		if not _is_allowed_executable(path, kind):
			return _resolution_failure("dirty_path", "Executable asset is outside its allowlist: %s" % path)
		if not FileAccess.file_exists(path):
			return _resolution_failure("executable_asset_missing", "Executable asset is missing: %s" % path)
		if FileAccess.get_sha256(path) != str(asset.get("sha256", "")):
			return _resolution_failure("executable_asset_hash_drift", "Executable asset hash drifted: %s" % path)
		if not ResourceLoader.exists(path):
			return _resolution_failure("executable_asset_unresolvable", "Executable asset is not recognized by ResourceLoader: %s" % path)
		var resource := ResourceLoader.load(path)
		if resource == null:
			return _resolution_failure("executable_asset_load_failed", "Executable asset could not be resolved: %s" % path)
		resources.append({
			"path": path,
			"resource": resource,
			"resource_kind": kind,
		})
	return {
		"instantiated": false,
		"ok": true,
		"receiver_key": receiver_key,
		"resources": resources,
	}


func deterministic_snapshot() -> Dictionary:
	if not _loaded:
		return {}
	var unit_ids := _units_by_id.keys()
	var receiver_keys := _receivers_by_key.keys()
	var plan_receivers := _plans_by_receiver.keys()
	var projection_ids := _projections_by_id.keys()
	unit_ids.sort()
	receiver_keys.sort()
	plan_receivers.sort()
	projection_ids.sort()
	var receiver_modes := []
	for receiver_key_value: Variant in receiver_keys:
		var receiver_key := str(receiver_key_value)
		receiver_modes.append([receiver_key, get_content_mode(receiver_key)])
	return {
		"plan_receivers": plan_receivers,
		"projection_ids": projection_ids,
		"receiver_modes": receiver_modes,
		"schema_version": str(_registry.get("schema_version", "")),
		"unit_ids": unit_ids,
	}


func _validate_registry_header(registry: Dictionary) -> bool:
	if not _require(_has_exact_keys(registry, ["active_runtime_adapters", "adapter_contract", "build_contract", "claim_totals", "claim_vocabulary", "compatibility_contract", "counts", "legacy_adapters", "recognition_metric", "registry_id", "schema_version", "units"]), "unknown_registry_version", "Runtime registry contains unknown top-level fields."):
		return false
	if not _require(str(registry.get("schema_version", "")) == REGISTRY_SCHEMA_VERSION, "unknown_registry_version", "Runtime registry version is unknown or forward-incompatible."):
		return false
	var build_contract := registry.get("build_contract", {}) as Dictionary
	if not _require(_has_exact_keys(build_contract, ["authoring_catalog_sha256", "compiler_version", "generated_content_sha256", "generated_manifest_sha256", "inventory_sha256", "runtime_discovery_dependency"]), "unknown_registry_version", "Runtime registry build contract contains unknown fields."):
		return false
	if not _require(
		str(build_contract.get("compiler_version", "")) == COMPILER_VERSION
		and build_contract.get("runtime_discovery_dependency") == false
		and _is_sha256(str(build_contract.get("authoring_catalog_sha256", "")))
		and _is_sha256(str(build_contract.get("generated_content_sha256", "")))
		and _is_sha256(str(build_contract.get("generated_manifest_sha256", "")))
		and _is_sha256(str(build_contract.get("inventory_sha256", ""))),
		"unknown_registry_version",
		"Runtime registry build contract requests unsupported discovery or compiler behavior.",
	):
		return false
	var compatibility := registry.get("compatibility_contract", {}) as Dictionary
	if not _require(_has_exact_keys(compatibility, ["catalog_schema_version", "compiler_version", "forward_compatible", "loader_api_version", "unknown_version_policy"]), "unknown_registry_version", "Runtime registry compatibility fields are unknown."):
		return false
	return _require(
		str(compatibility.get("catalog_schema_version", "")) == CATALOG_SCHEMA_VERSION
		and str(compatibility.get("compiler_version", "")) == COMPILER_VERSION
		and compatibility.get("forward_compatible") == false
		and str(compatibility.get("loader_api_version", "")) == LOADER_API_VERSION
		and str(compatibility.get("unknown_version_policy", "")) == UNKNOWN_VERSION_POLICY,
		"unknown_registry_version",
		"Runtime registry compatibility contract requests an unsupported or forward version.",
	)


func _validate_registry(registry: Dictionary) -> bool:
	if not _runtime_boundary_is_clean(registry):
		return _require(false, "dirty_path", "Runtime registry contains a source-only path, URL, or absolute path.")
	var adapter_reference := registry.get("adapter_contract", {}) as Dictionary
	if not _require(_has_exact_keys(adapter_reference, ["path", "schema_version", "sha256"]), "adapter_contract_reference_invalid", "Runtime registry adapter-contract reference fields drifted."):
		return false
	if not _require(
		str(adapter_reference.get("path", "")) == DEFAULT_ADAPTER_CONTRACT_PATH
		and str(adapter_reference.get("schema_version", "")) == ADAPTER_CONTRACT_SCHEMA_VERSION
		and _is_sha256(str(adapter_reference.get("sha256", ""))),
		"adapter_contract_reference_invalid",
		"Runtime registry adapter-contract reference is invalid.",
	):
		return false
	var counts := registry.get("counts", {}) as Dictionary
	if not _require(
		int(counts.get("recognition_units", -1)) == EXPECTED_UNIT_COUNT
		and int(counts.get("direct_wall_receivers", -1)) == EXPECTED_RECEIVER_COUNT
		and int(counts.get("source_record_memberships", -1)) == EXPECTED_SOURCE_RECORD_COUNT
		and int(counts.get("runtime_adapter_receivers", -1)) == EXPECTED_ADAPTER_COUNT,
		"registry_count_drift",
		"Runtime registry canonical counts drifted.",
	):
		return false
	var legacy_adapters := registry.get("legacy_adapters", []) as Array
	var active_adapters := registry.get("active_runtime_adapters", []) as Array
	var adapters := legacy_adapters.duplicate()
	adapters.append_array(active_adapters)
	if not _require(legacy_adapters.size() == 9 and active_adapters.size() == 5 and adapters.size() == EXPECTED_ADAPTER_COUNT, "registry_count_drift", "Runtime adapter arrays do not contain nine legacy plus five active entries."):
		return false
	var adapter_receivers := {}
	var registry_projection_ids := {}
	for adapter_value: Variant in adapters:
		var adapter := adapter_value as Dictionary
		var adapter_id := str(adapter.get("adapter_id", ""))
		var receiver_key := str(adapter.get("receiver_key", ""))
		if not _require(not adapter_id.is_empty() and not _adapters_by_id.has(adapter_id), "duplicate_adapter", "Runtime adapter ID is missing or duplicated: %s" % adapter_id):
			return false
		if not _require(not receiver_key.is_empty() and not adapter_receivers.has(receiver_key), "adapter_receiver_missing", "Runtime adapter receiver is missing or duplicated for %s." % adapter_id):
			return false
		adapter_receivers[receiver_key] = true
		_adapters_by_id[adapter_id] = adapter
		for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
			if not _validate_runtime_asset(asset_value as Dictionary, adapter_id):
				return false
		for projection_value: Variant in adapter.get("runtime_asset_projections", []) as Array:
			var projection := projection_value as Dictionary
			if not _require(_has_exact_keys(projection, ["package_contract", "projection_id", "source_asset_sha256", "source_asset_type"]), "projection_path_forbidden", "%s projection contains an executable/source path or unknown field." % adapter_id):
				return false
			if not _require(str(projection.get("package_contract", "")) == "sanitized_adapter_metadata_summary_only" and _is_sha256(str(projection.get("source_asset_sha256", ""))), "projection_invalid", "%s projection is not a valid pathless summary." % adapter_id):
				return false
			var projection_id := str(projection.get("projection_id", ""))
			if not _require(projection_id.begins_with("runtime-projection:") and not registry_projection_ids.has(projection_id), "projection_invalid", "%s projection ID is malformed or duplicated." % adapter_id):
				return false
			registry_projection_ids[projection_id] = true
	var building_3_adapter := {}
	var isle_house_adapter := {}
	var navy_chapel_adapter := {}
	for adapter_value: Variant in active_adapters:
		var active_adapter := adapter_value as Dictionary
		if str(active_adapter.get("receiver_key", "")) == BUILDING_3_RECEIVER:
			building_3_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == ISLE_HOUSE_LOW_RECEIVER:
			isle_house_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NAVY_CHAPEL_RECEIVER:
			navy_chapel_adapter = active_adapter
	if not _validate_building_3_registry_adapter(building_3_adapter):
		return false
	if not _validate_isle_house_registry_adapter(isle_house_adapter):
		return false
	if not _validate_navy_chapel_registry_adapter(navy_chapel_adapter):
		return false
	if not _require(registry_projection_ids.size() == EXPECTED_PROJECTION_OCCURRENCE_COUNT, "adapter_contract_count_drift", "Runtime registry projection occurrence count is not 13."):
		return false
	var units := registry.get("units", []) as Array
	if not _require(units.size() == EXPECTED_UNIT_COUNT, "registry_count_drift", "Runtime registry does not contain 213 units."):
		return false
	var source_keys := {}
	var accepted_reference_unit_ids := []
	for unit_value: Variant in units:
		var unit := unit_value as Dictionary
		var unit_id := str(unit.get("unit_id", ""))
		if not _require(not unit_id.is_empty() and not _units_by_id.has(unit_id), "duplicate_unit", "Runtime unit ID is missing or duplicated: %s" % unit_id):
			return false
		var receivers := unit.get("direct_receivers", []) as Array
		if not _require(str(unit.get("runtime_content_mode", "")) == _derive_unit_content_mode(receivers), "mixed_unit_mismatch", "%s unit summary does not match its receiver-level content modes." % unit_id):
			return false
		var claim_status := unit.get("claim_status", {}) as Dictionary
		var acceptance_records := unit.get("acceptance_records", []) as Array
		if str(claim_status.get("reference_recognizable", "")) == "accepted":
			accepted_reference_unit_ids.append(unit_id)
			if not _validate_reference_acceptance_record(unit_id, acceptance_records):
				return false
		elif not _require(acceptance_records.is_empty(), "recognition_metric_mismatch", "%s exports an acceptance receipt without an accepted physical-unit claim." % unit_id):
			return false
		_units_by_id[unit_id] = unit
		for source_value: Variant in unit.get("source_records", []) as Array:
			var source_key := str((source_value as Dictionary).get("source_key", ""))
			if not _require(not source_key.is_empty() and not source_keys.has(source_key), "duplicate_source_record", "%s has a missing or duplicate source record." % unit_id):
				return false
			source_keys[source_key] = true
		for receiver_value: Variant in receivers:
			var receiver := receiver_value as Dictionary
			var receiver_key := str(receiver.get("receiver_key", ""))
			var content_mode := str(receiver.get("runtime_content_mode", ""))
			var adapter_id_value: Variant = receiver.get("runtime_adapter_id")
			if not _require(not receiver_key.is_empty() and not _receivers_by_key.has(receiver_key), "duplicate_receiver", "%s has a missing or duplicate direct receiver." % unit_id):
				return false
			if not _require(["generated_placeholder", "legacy_adapter", "active_building_1_hero", "active_building_3_hero", "active_isle_house_variant_c", "active_navy_chapel_187_paired_replacement"].has(content_mode), "unknown_content_mode", "%s has an unknown receiver content mode." % receiver_key):
				return false
			if content_mode == "generated_placeholder":
				if not _require(adapter_id_value == null, "receiver_adapter_mismatch", "%s placeholder unexpectedly references an adapter." % receiver_key):
					return false
			else:
				var adapter_id := str(adapter_id_value)
				var adapter := _adapters_by_id.get(adapter_id, {}) as Dictionary
				if not _require(not adapter.is_empty() and str(adapter.get("receiver_key", "")) == receiver_key, "receiver_adapter_mismatch", "%s does not reference its exact adapter." % receiver_key):
					return false
			_receivers_by_key[receiver_key] = receiver
	if not _require(_units_by_id.size() == EXPECTED_UNIT_COUNT and _receivers_by_key.size() == EXPECTED_RECEIVER_COUNT and source_keys.size() == EXPECTED_SOURCE_RECORD_COUNT, "registry_count_drift", "Runtime registry unit/source/receiver partitions drifted."):
		return false
	accepted_reference_unit_ids.sort()
	var expected_accepted_ids := EXPECTED_REFERENCE_RECOGNIZABLE_UNIT_IDS.duplicate()
	expected_accepted_ids.sort()
	if not _require(accepted_reference_unit_ids == expected_accepted_ids, "recognition_metric_mismatch", "Reference-recognizable physical-unit set is not exactly the independently accepted six."):
		return false
	if not _validate_recognition_metric(registry, accepted_reference_unit_ids):
		return false
	var isle := _units_by_id.get(ISLE_HOUSE_UNIT, {}) as Dictionary
	var isle_receivers := isle.get("direct_receivers", []) as Array
	var isle_high := _receiver_by_key(isle_receivers, ISLE_HOUSE_HIGH_RECEIVER)
	var isle_low := _receiver_by_key(isle_receivers, ISLE_HOUSE_LOW_RECEIVER)
	return _require(
		str(isle.get("runtime_content_mode", "")) == "mixed_legacy_high_and_active_variant_c_low"
		and str(isle_high.get("runtime_content_mode", "")) == "legacy_adapter"
		and str(isle_low.get("runtime_content_mode", "")) == "active_isle_house_variant_c"
		and str(isle_low.get("runtime_adapter_id", "")) == "active-adapter:isle-house-variant-c:building-composite:w1249412094:w1282547787:wall"
		and not _units_by_id.has("physical-building:w1282547786")
		and not _units_by_id.has("physical-building:w1282547787"),
		"mixed_unit_mismatch",
		"Isle House high/low receiver state or one-parent numerator boundary is not truthfully represented.",
	)


func _validate_reference_acceptance_record(unit_id: String, records: Array) -> bool:
	if not _require(records.size() == 1 and EXPECTED_REVIEW_RECEIPTS.has(unit_id), "recognition_receipt_mismatch", "%s must have one allowlisted independent recognition receipt." % unit_id):
		return false
	var record := records[0] as Dictionary
	if not _require(_has_exact_keys(record, ["evidence_manifest_sha256", "review_id", "review_kind", "review_receipt_sha256", "status"]), "recognition_receipt_mismatch", "%s acceptance receipt fields drifted." % unit_id):
		return false
	var expected := EXPECTED_REVIEW_RECEIPTS[unit_id] as Array
	return _require(
		str(record.get("review_kind", "")) == "independent_reference_recognition"
		and str(record.get("status", "")) == "accept"
		and str(record.get("review_receipt_sha256", "")) == str(expected[0])
		and str(record.get("evidence_manifest_sha256", "")) == str(expected[1])
		and _is_sha256(str(record.get("review_receipt_sha256", "")))
		and _is_sha256(str(record.get("evidence_manifest_sha256", ""))),
		"recognition_receipt_mismatch",
		"%s independent review or evidence receipt pin drifted." % unit_id,
	)


func _validate_recognition_metric(registry: Dictionary, accepted_unit_ids: Array) -> bool:
	var metric := registry.get("recognition_metric", {}) as Dictionary
	if not _require(_has_exact_keys(metric, ["accepted_physical_unit_ids", "denominator", "denominator_kind", "display", "isle_house_non_numerator_source_keys", "numerator", "rollup_policy"]), "recognition_metric_mismatch", "Runtime recognition metric fields drifted."):
		return false
	var metric_ids := (metric.get("accepted_physical_unit_ids", []) as Array).duplicate()
	metric_ids.sort()
	var claim_totals := registry.get("claim_totals", {}) as Dictionary
	var reference_totals := claim_totals.get("reference_recognizable", {}) as Dictionary
	var game_totals := claim_totals.get("game_distinctive", {}) as Dictionary
	var fidelity_totals := claim_totals.get("as_built_fidelity", {}) as Dictionary
	var receiver_totals := claim_totals.get("receiver_complete", {}) as Dictionary
	return _require(
		metric_ids == accepted_unit_ids
		and int(metric.get("numerator", -1)) == EXPECTED_REFERENCE_RECOGNIZABLE_COUNT
		and int(metric.get("denominator", -1)) == EXPECTED_UNIT_COUNT
		and str(metric.get("display", "")) == "6/213"
		and str(metric.get("denominator_kind", "")) == "immutable_physical_recognition_units"
		and str(metric.get("rollup_policy", "")) == "one_claim_per_physical_recognition_unit"
		and metric.get("isle_house_non_numerator_source_keys", []) == ["w1282547786", "w1282547787"]
		and int(reference_totals.get("accepted", -1)) == EXPECTED_REFERENCE_RECOGNIZABLE_COUNT
		and int(reference_totals.get("not_evaluated", -1)) == EXPECTED_UNIT_COUNT - EXPECTED_REFERENCE_RECOGNIZABLE_COUNT
		and int(reference_totals.get("blocked", -1)) == 0
		and int(reference_totals.get("rejected", -1)) == 0
		and int(game_totals.get("accepted", -1)) == 0
		and int(fidelity_totals.get("claimed", -1)) == 0
		and int(fidelity_totals.get("limited", -1)) == 0
		and int(receiver_totals.get("verified", -1)) == EXPECTED_UNIT_COUNT,
		"recognition_metric_mismatch",
		"Runtime physical-entity recognition rollup is not exactly 6/213 with claim dimensions separated.",
	)


func _validate_adapter_contracts(contracts: Dictionary, registry: Dictionary) -> bool:
	if not _runtime_boundary_is_clean(contracts):
		return _require(false, "dirty_path", "Runtime adapter contracts contain a source-only path, URL, or absolute path.")
	if not _require(_has_exact_keys(contracts, ["build_contract", "contract_id", "counts", "loader_contract", "plans", "projection_descriptors", "schema_version"]), "unknown_adapter_contract_version", "Runtime adapter contracts contain unknown top-level fields."):
		return false
	if not _require(str(contracts.get("schema_version", "")) == ADAPTER_CONTRACT_SCHEMA_VERSION, "unknown_adapter_contract_version", "Runtime adapter-contract version is unknown or forward-incompatible."):
		return false
	if not _require(str(contracts.get("contract_id", "")) == "treasure-island-facade-runtime-adapters", "unknown_adapter_contract_version", "Runtime adapter-contract identity is unknown."):
		return false
	var build_contract := contracts.get("build_contract", {}) as Dictionary
	var registry_build := registry.get("build_contract", {}) as Dictionary
	if not _require(_has_exact_keys(build_contract, ["authoring_catalog_sha256", "compiler_version", "runtime_registry_schema_version", "unknown_version_policy"]), "unknown_adapter_contract_version", "Runtime adapter build contract contains unknown fields."):
		return false
	if not _require(
		str(build_contract.get("compiler_version", "")) == COMPILER_VERSION
		and str(build_contract.get("runtime_registry_schema_version", "")) == REGISTRY_SCHEMA_VERSION
		and str(build_contract.get("unknown_version_policy", "")) == UNKNOWN_VERSION_POLICY
		and str(build_contract.get("authoring_catalog_sha256", "")) == str(registry_build.get("authoring_catalog_sha256", "")),
		"unknown_adapter_contract_version",
		"Runtime adapter build contract requests an unsupported or forward version.",
	):
		return false
	var loader_contract := contracts.get("loader_contract", {}) as Dictionary
	if not _require(_has_exact_keys(loader_contract, ["allowed_executable_kinds", "allowed_executable_roots", "api_version", "instantiation_authorized", "loader_path", "loader_sha256", "projection_execution_policy", "unknown_version_policy"]), "unknown_loader_version", "Runtime loader contract contains unknown fields."):
		return false
	if not _require(
		str(loader_contract.get("api_version", "")) == LOADER_API_VERSION
		and loader_contract.get("allowed_executable_kinds", []) == ALLOWED_EXECUTABLE_KINDS
		and loader_contract.get("allowed_executable_roots", []) == ALLOWED_EXECUTABLE_ROOTS
		and loader_contract.get("instantiation_authorized") == false
		and str(loader_contract.get("loader_path", "")) == DEFAULT_LOADER_PATH
		and _is_sha256(str(loader_contract.get("loader_sha256", "")))
		and FileAccess.file_exists(DEFAULT_LOADER_PATH)
		and FileAccess.get_sha256(DEFAULT_LOADER_PATH) == str(loader_contract.get("loader_sha256", ""))
		and str(loader_contract.get("projection_execution_policy", "")) == "forbidden"
		and str(loader_contract.get("unknown_version_policy", "")) == UNKNOWN_VERSION_POLICY,
		"unknown_loader_version",
		"Runtime loader contract requests unsupported execution or forward compatibility.",
	):
		return false
	var counts := contracts.get("counts", {}) as Dictionary
	if not _require(_has_exact_keys(counts, ["disabled_adapter_receivers", "disabled_projection_occurrences", "disabled_unique_projection_inputs", "package_safe_adapter_receivers", "receiver_adapter_plans"]), "adapter_contract_count_drift", "Runtime adapter counts contain unknown fields."):
		return false
	if not _require(
		int(counts.get("receiver_adapter_plans", -1)) == EXPECTED_ADAPTER_COUNT
		and int(counts.get("package_safe_adapter_receivers", -1)) == EXPECTED_READY_ADAPTER_COUNT
		and int(counts.get("disabled_adapter_receivers", -1)) == EXPECTED_DISABLED_ADAPTER_COUNT
		and int(counts.get("disabled_unique_projection_inputs", -1)) == EXPECTED_PROJECTION_DESCRIPTOR_COUNT
		and int(counts.get("disabled_projection_occurrences", -1)) == EXPECTED_PROJECTION_OCCURRENCE_COUNT,
		"adapter_contract_count_drift",
		"Runtime adapter contract counts drifted.",
	):
		return false
	var descriptors := contracts.get("projection_descriptors", []) as Array
	if not _require(descriptors.size() == EXPECTED_PROJECTION_DESCRIPTOR_COUNT, "adapter_contract_count_drift", "Runtime adapter contract does not contain 13 projection descriptors."):
		return false
	var projection_occurrence_count := 0
	var projection_occurrences := {}
	for descriptor_value: Variant in descriptors:
		var descriptor := descriptor_value as Dictionary
		var descriptor_id := str(descriptor.get("descriptor_id", ""))
		if not _require(_has_exact_keys(descriptor, ["consumer_adapter_ids", "descriptor_id", "disabled_reason_code", "execution_policy", "execution_state", "occurrence_projection_ids", "source_asset_sha256", "source_asset_type"]), "projection_path_forbidden", "%s projection descriptor contains a path or unknown field." % descriptor_id):
			return false
		if not _require(
			descriptor_id.begins_with("disabled-projection-input:")
			and _is_sha256(descriptor_id.trim_prefix("disabled-projection-input:"))
			and not _projections_by_id.has(descriptor_id)
			and str(descriptor.get("execution_state", "")) == "hard_disabled"
			and str(descriptor.get("execution_policy", "")) == "never_resolve_or_execute"
			and str(descriptor.get("disabled_reason_code", "")) == "source_bearing_dependency_closure_requires_independent_package_safe_normalization"
			and _is_sha256(str(descriptor.get("source_asset_sha256", "")))
			and ["gd", "json"].has(str(descriptor.get("source_asset_type", ""))),
			"projection_invalid",
			"%s projection descriptor is not pathless and hard-disabled." % descriptor_id,
		):
			return false
		var occurrences := descriptor.get("occurrence_projection_ids", []) as Array
		var consumers := descriptor.get("consumer_adapter_ids", []) as Array
		if not _require(not consumers.is_empty() and _array_is_unique(consumers), "projection_invalid", "%s projection consumers are missing or duplicated." % descriptor_id):
			return false
		if not _require(not occurrences.is_empty() and _array_is_unique(occurrences), "projection_invalid", "%s projection occurrences are missing or duplicated." % descriptor_id):
			return false
		for occurrence_value: Variant in occurrences:
			var occurrence_id := str(occurrence_value)
			if not _require(occurrence_id.begins_with("runtime-projection:") and not projection_occurrences.has(occurrence_id), "projection_invalid", "%s projection occurrence is malformed or duplicated." % descriptor_id):
				return false
			projection_occurrences[occurrence_id] = descriptor_id
		projection_occurrence_count += occurrences.size()
		_projections_by_id[descriptor_id] = descriptor
	if not _require(projection_occurrence_count == EXPECTED_PROJECTION_OCCURRENCE_COUNT, "adapter_contract_count_drift", "Runtime projection occurrence count drifted."):
		return false
	var plans := contracts.get("plans", []) as Array
	if not _require(plans.size() == EXPECTED_ADAPTER_COUNT, "adapter_contract_count_drift", "Runtime adapter contract does not contain 14 plans."):
		return false
	var ready_count := 0
	var disabled_count := 0
	for plan_value: Variant in plans:
		var plan := plan_value as Dictionary
		var adapter_id := str(plan.get("adapter_id", ""))
		var receiver_key := str(plan.get("receiver_key", ""))
		if not _require(_has_exact_keys(plan, ["adapter_id", "behavior_contract", "content_mode", "disabled_reason_code", "executable_assets", "integration_state", "projection_descriptor_ids", "receiver_key", "resolution_policy", "runtime_assets", "source_key"]), "adapter_plan_mismatch", "%s contains unknown adapter-plan fields." % adapter_id):
			return false
		var adapter := _adapters_by_id.get(adapter_id, {}) as Dictionary
		if not _require(not adapter.is_empty() and str(adapter.get("receiver_key", "")) == receiver_key and str(adapter.get("source_key", "")) == str(plan.get("source_key", "")) and not _plans_by_receiver.has(receiver_key), "adapter_plan_mismatch", "%s does not match one exact runtime adapter receiver/source." % adapter_id):
			return false
		var receiver := _receivers_by_key.get(receiver_key, {}) as Dictionary
		if not _require(not receiver.is_empty() and str(receiver.get("runtime_content_mode", "")) == str(plan.get("content_mode", "")), "adapter_plan_mismatch", "%s content mode does not match its exact receiver." % adapter_id):
			return false
		if not _require(_runtime_asset_arrays_match(adapter.get("runtime_assets", []) as Array, plan.get("runtime_assets", []) as Array), "adapter_plan_mismatch", "%s runtime assets drifted from the registry." % adapter_id):
			return false
		if str(plan.get("content_mode", "")) == "active_building_3_hero":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_building_3_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_isle_house_variant_c":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_isle_house_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s Isle House behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_navy_chapel_187_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_navy_chapel_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s Navy Chapel behavior contract drifted from the registry." % adapter_id):
				return false
		elif not _require(plan.get("behavior_contract") == null, "adapter_plan_mismatch", "%s unexpectedly exports a target-specific behavior contract." % adapter_id):
			return false
		var projection_ids := plan.get("projection_descriptor_ids", []) as Array
		if not _require(projection_ids.all(func(id: Variant) -> bool: return _projections_by_id.has(str(id))), "projection_invalid", "%s references an unknown disabled projection." % adapter_id):
			return false
		var expected_projection_ids := _projection_descriptor_ids_for_adapter(adapter)
		var actual_projection_ids := projection_ids.duplicate()
		expected_projection_ids.sort()
		actual_projection_ids.sort()
		if not _require(actual_projection_ids == expected_projection_ids, "projection_invalid", "%s pathless projection membership drifted from the registry." % adapter_id):
			return false
		var hard_disabled := not projection_ids.is_empty()
		if hard_disabled:
			disabled_count += 1
			if not _require(
				str(plan.get("integration_state", "")) == "hard_disabled_source_projection"
				and str(plan.get("resolution_policy", "")) == "deny_all_executable_resolution"
				and str(plan.get("disabled_reason_code", "")) == "one_or_more_source_bearing_projection_inputs_have_no_parity_proven_package_safe_executable"
				and (plan.get("executable_assets", []) as Array).is_empty(),
				"disabled_adapter_exposes_executable",
				"%s must remain hard-disabled with no executable asset." % adapter_id,
			):
				return false
		else:
			ready_count += 1
			if not _require(str(plan.get("integration_state", "")) == "package_safe_ready_for_integration" and str(plan.get("resolution_policy", "")) == "resolve_only_without_instantiation" and plan.get("disabled_reason_code") == null, "adapter_plan_mismatch", "%s package-safe plan state drifted." % adapter_id):
				return false
		for asset_value: Variant in plan.get("runtime_assets", []) as Array:
			if not _validate_runtime_asset(asset_value as Dictionary, adapter_id):
				return false
		for asset_value: Variant in plan.get("executable_assets", []) as Array:
			var asset := asset_value as Dictionary
			var path := str(asset.get("path", ""))
			var kind := str(asset.get("resource_kind", ""))
			if not _require(_has_exact_keys(asset, ["path", "resource_kind", "sha256"]), "adapter_plan_mismatch", "%s executable asset fields drifted." % adapter_id):
				return false
			if not _require(_is_allowed_executable(path, kind), "dirty_path", "%s executable asset is outside the loader allowlist." % adapter_id):
				return false
			if not _require(_runtime_asset_match(plan.get("runtime_assets", []) as Array, path, str(asset.get("sha256", ""))), "adapter_plan_mismatch", "%s executable asset is not an exact runtime-asset subset." % adapter_id):
				return false
		_plans_by_receiver[receiver_key] = plan
	if not _require(ready_count == EXPECTED_READY_ADAPTER_COUNT and disabled_count == EXPECTED_DISABLED_ADAPTER_COUNT and _plans_by_receiver.size() == EXPECTED_ADAPTER_COUNT, "adapter_contract_count_drift", "Runtime adapter ready/disabled plan partition drifted."):
		return false
	for descriptor_value: Variant in descriptors:
		var descriptor := descriptor_value as Dictionary
		var descriptor_id := str(descriptor.get("descriptor_id", ""))
		for consumer_value: Variant in descriptor.get("consumer_adapter_ids", []) as Array:
			var consumer_id := str(consumer_value)
			var consumer := _adapters_by_id.get(consumer_id, {}) as Dictionary
			var consumer_plan := _plans_by_receiver.get(str(consumer.get("receiver_key", "")), {}) as Dictionary
			if not _require(not consumer.is_empty() and (consumer_plan.get("projection_descriptor_ids", []) as Array).has(descriptor_id), "projection_invalid", "%s consumer does not reference its projection descriptor." % consumer_id):
				return false
		for occurrence_value: Variant in descriptor.get("occurrence_projection_ids", []) as Array:
			if not _require(_registry_projection_occurrence_matches(str(occurrence_value), descriptor), "projection_invalid", "%s occurrence does not match any registry projection." % str(occurrence_value)):
				return false
	return true


func _validate_building_3_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "building_3_parity_mismatch", "Building 3 active wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == "active-adapter:building-3-hero:building:w34313540:wall"
		and str(adapter.get("source_key", "")) == "w34313540"
		and str(adapter.get("attachment_kind", "")) == "active_building_3_wall_roof_hero_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_hero_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_building_3_hero"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"building_3_parity_mismatch",
		"Building 3 active adapter classification or source ownership drifted.",
	):
		return false
	var actual_paths := []
	for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := BUILDING_3_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "building_3_parity_mismatch", "Building 3 active adapter does not contain its exact wrapper/config/facade asset set."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256"]), "building_3_parity_mismatch", "Building 3 active runtime contract fields drifted."):
		return false
	if not _require(
		_runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/scripts/world/massing/building_3_600_california_massing.gd", str(runtime_contract.get("adapter_sha256", "")))
		and _runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/resources/facades/building_3_hero_massing.json", str(runtime_contract.get("config_sha256", "")))
		and _is_sha256(str(runtime_contract.get("dispatch_sha256", ""))),
		"building_3_parity_mismatch",
		"Building 3 wrapper/config hashes or compiler-verified dispatch identity do not bind exact-current runtime behavior.",
	):
		return false
	return _validate_building_3_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_building_3_behavior_contract(contract: Dictionary) -> bool:
	if not _require(_has_exact_keys(contract, ["collision_contract", "facade_contract", "geometry_contract", "parity_status", "replacement_contract", "schema_version"]), "building_3_parity_mismatch", "Building 3 behavior parity fields drifted."):
		return false
	var collision := contract.get("collision_contract", {}) as Dictionary
	var facade := contract.get("facade_contract", {}) as Dictionary
	var geometry := contract.get("geometry_contract", {}) as Dictionary
	var replacement := contract.get("replacement_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(collision, ["collision_matches_visible_geometry", "roof_landing_world_solid", "spray_ownership", "wall_world_solid"])
		and _has_exact_keys(facade, ["collision_owner", "deterministic_signature", "render_only", "runtime_bound_to_wall_massing"])
		and _has_exact_keys(geometry, ["generated_bytes_unchanged", "horizontal_source_footprint_preserved", "profile_signature", "roof_geometry_signature", "roof_triangles", "topology_delta_triangles", "wall_geometry_signature", "wall_triangles"])
		and _has_exact_keys(replacement, ["dispatch_order", "receiver_roles", "roof_object_key", "source_key", "wall_object_key"]),
		"building_3_parity_mismatch",
		"Building 3 nested behavior parity fields drifted.",
	):
		return false
	return _require(
		str(contract.get("schema_version", "")) == "ti.building-3-runtime-parity/1"
		and str(contract.get("parity_status", "")) == "exact_current_behavior_and_dependency_set_verified"
		and replacement.get("receiver_roles", []) == ["wall", "roof"]
		and str(replacement.get("dispatch_order", "")) == "target_specific_before_generic"
		and str(replacement.get("source_key", "")) == "w34313540"
		and str(replacement.get("wall_object_key", "")) == BUILDING_3_RECEIVER
		and str(replacement.get("roof_object_key", "")) == "building:w34313540:roof"
		and bool(geometry.get("horizontal_source_footprint_preserved", false))
		and bool(geometry.get("generated_bytes_unchanged", false))
		and int(geometry.get("wall_triangles", 0)) == 236
		and int(geometry.get("roof_triangles", 0)) == 675
		and int(geometry.get("topology_delta_triangles", 0)) == 766
		and str(geometry.get("profile_signature", "")) == "f82192fe9ebeb04a6da1222bcd84afd217f163ff6ce1cceed826a5d436dd1693"
		and str(geometry.get("wall_geometry_signature", "")) == "e03f830e6a41da16107b5db14bcb8a8ff9f43b46f9df89b1f157958cc68909d4"
		and str(geometry.get("roof_geometry_signature", "")) == "2dee9acf24616423230895d70827acb56c8f402a56ac1fe8e4a93d2409b34b63"
		and bool(collision.get("collision_matches_visible_geometry", false))
		and bool(collision.get("wall_world_solid", false))
		and bool(collision.get("roof_landing_world_solid", false))
		and str(collision.get("spray_ownership", "")) == "wall_only"
		and bool(facade.get("runtime_bound_to_wall_massing", false))
		and bool(facade.get("render_only", false))
		and str(facade.get("collision_owner", "")) == "massing_wall"
		and str(facade.get("deterministic_signature", "")) == "e0b30339bd2ca8642a7b49b5e6153f52017ec4a840e9b0dc1e3841f5373ca5f8",
		"building_3_parity_mismatch",
		"Building 3 wall/roof geometry, collision, landing, spray, or facade parity drifted.",
	)


func _validate_isle_house_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "isle_house_parity_mismatch", "Isle House exact-current Variant C low adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == "active-adapter:isle-house-variant-c:building-composite:w1249412094:w1282547787:wall"
		and str(adapter.get("source_key", "")) == "w1282547787"
		and str(adapter.get("attachment_kind", "")) == "active_isle_house_variant_c_low_part_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_composite_part_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_isle_house_variant_c"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and (adapter.get("runtime_assets", []) as Array).size() == 1
		and (adapter.get("runtime_asset_projections", []) as Array).size() == 3,
		"isle_house_parity_mismatch",
		"Isle House active adapter classification, source ownership, or fail-closed projection boundary drifted.",
	):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "repair_factory_sha256", "reviewed_factory_sha256"]), "isle_house_parity_mismatch", "Isle House active runtime contract fields drifted."):
		return false
	if not _require(
		_runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/resources/facades/isle_house_composite_repair_variant_c_standalone_v1.json", str(runtime_contract.get("config_sha256", "")))
		and str(runtime_contract.get("adapter_sha256", "")) == "e2767b01fab68d7f16ffe2e7f8e0313c711347e2006a72e028c19aaa2195b891"
		and str(runtime_contract.get("repair_factory_sha256", "")) == "4336e821e240b973f8d97e5cb46e17332b19dea03869abb1fa81b96a7e380582"
		and str(runtime_contract.get("reviewed_factory_sha256", "")) == "b24fd72cd12aa0c6c45a123f005fc834ea657c343e8332a872eae07fa017ace7"
		and _is_sha256(str(runtime_contract.get("dispatch_sha256", ""))),
		"isle_house_parity_mismatch",
		"Isle House live/config/factory/dispatch pins do not bind the reviewed exact-current state.",
	):
		return false
	return _validate_isle_house_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_isle_house_behavior_contract(contract: Dictionary) -> bool:
	if not _require(_has_exact_keys(contract, ["acceptance_contract", "geometry_contract", "ownership_contract", "replacement_contract", "schema_version", "truth_boundary"]), "isle_house_parity_mismatch", "Isle House behavior parity fields drifted."):
		return false
	var acceptance := contract.get("acceptance_contract", {}) as Dictionary
	var geometry := contract.get("geometry_contract", {}) as Dictionary
	var ownership := contract.get("ownership_contract", {}) as Dictionary
	var replacement := contract.get("replacement_contract", {}) as Dictionary
	var truth := contract.get("truth_boundary", {}) as Dictionary
	return _require(
		str(contract.get("schema_version", "")) == "ti.isle-house-variant-c-live-parity/1"
		and str(acceptance.get("accepted_physical_unit_id", "")) == ISLE_HOUSE_UNIT
		and str(acceptance.get("independent_live_review_receipt_sha256", "")) == ISLE_HOUSE_LIVE_REVIEW_RECEIPT_SHA256
		and int(acceptance.get("numerator_effect", -1)) == 1
		and acceptance.get("part_source_keys_are_not_units", []) == ["w1282547786", "w1282547787"]
		and bool(acceptance.get("reference_recognizable", false))
		and str(geometry.get("live_signature", "")) == ISLE_HOUSE_LIVE_SIGNATURE
		and str(geometry.get("overlay_repair_signature", "")) == ISLE_HOUSE_REPAIR_SIGNATURE
		and int(geometry.get("overlay_mesh_instances", -1)) == 7
		and int(geometry.get("overlay_surfaces", -1)) == 11
		and int(geometry.get("overlay_triangles", -1)) == 2242
		and int(geometry.get("world_records", -1)) == 735
		and int(geometry.get("world_mesh_instances", -1)) == 944
		and int(geometry.get("world_surfaces", -1)) == 957
		and int(geometry.get("world_triangles", -1)) == 64572
		and int(geometry.get("world_static_bodies", -1)) == 466
		and int(geometry.get("world_shapes", -1)) == 466
		and int(ownership.get("decorative_collision_nodes", -1)) == 0
		and int(ownership.get("decorative_navigation_nodes", -1)) == 0
		and int(ownership.get("decorative_spray_nodes", -1)) == 0
		and bool(ownership.get("high_receiver_unchanged", false))
		and bool(ownership.get("low_receiver_is_sole_collision_and_spray_owner", false))
		and str(replacement.get("target_receiver_key", "")) == ISLE_HOUSE_LOW_RECEIVER
		and str(replacement.get("target_source_key", "")) == "w1282547787"
		and replacement.get("rejected_overlay_fallback_allowed") == false
		and replacement.get("stacking_allowed") == false
		and truth.get("as_built_fidelity_claimed") == false
		and truth.get("game_distinctive_claimed") == false
		and truth.get("receiver_complete_inferred_from_art") == false,
		"isle_house_parity_mismatch",
		"Isle House exact-current receipt, signature, topology, ownership, replacement, or truth boundary drifted.",
	)


func _validate_navy_chapel_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "navy_chapel_parity_mismatch", "Navy Chapel exact-current paired adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == "active-adapter:navy-chapel-187:building:w291189336:wall"
		and str(adapter.get("source_key", "")) == "w291189336"
		and str(adapter.get("attachment_kind", "")) == "active_navy_chapel_187_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_navy_chapel_187_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"navy_chapel_parity_mismatch",
		"Navy Chapel active adapter classification, source ownership, or package boundary drifted.",
	):
		return false
	var actual_paths := []
	for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NAVY_CHAPEL_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "navy_chapel_parity_mismatch", "Navy Chapel active adapter does not contain its exact live/config/prototype/material set."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_sha256"]), "navy_chapel_parity_mismatch", "Navy Chapel active runtime contract fields drifted."):
		return false
	if not _require(
		_runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd", str(runtime_contract.get("adapter_sha256", "")))
		and _runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json", str(runtime_contract.get("config_sha256", "")))
		and _runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd", str(runtime_contract.get("prototype_sha256", "")))
		and str(runtime_contract.get("adapter_sha256", "")) == "deffb5956d8e808565d1c557208647a89dff4730c15f97aa9b1085a087968cad"
		and str(runtime_contract.get("config_sha256", "")) == "c8f2ab09f3943a5ec8abea7cb9a108f49990bff1d83003c3b3622187a269dea2"
		and str(runtime_contract.get("prototype_sha256", "")) == "067c12e29c9fd352915ef2a501fcd7687b450081c79a4281d63bbfef1c19e7db"
		and _is_sha256(str(runtime_contract.get("dispatch_sha256", ""))),
		"navy_chapel_parity_mismatch",
		"Navy Chapel live/config/prototype/dispatch pins do not bind the reviewed exact-current state.",
	):
		return false
	return _validate_navy_chapel_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_navy_chapel_behavior_contract(contract: Dictionary) -> bool:
	if not _require(_has_exact_keys(contract, ["acceptance_contract", "geometry_contract", "ownership_contract", "replacement_contract", "schema_version", "truth_boundary"]), "navy_chapel_parity_mismatch", "Navy Chapel behavior parity fields drifted."):
		return false
	var acceptance := contract.get("acceptance_contract", {}) as Dictionary
	var geometry := contract.get("geometry_contract", {}) as Dictionary
	var ownership := contract.get("ownership_contract", {}) as Dictionary
	var replacement := contract.get("replacement_contract", {}) as Dictionary
	var truth := contract.get("truth_boundary", {}) as Dictionary
	return _require(
		str(contract.get("schema_version", "")) == "ti.navy-chapel-187-live-parity/1"
		and str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w291189336"
		and str(acceptance.get("independent_live_review_receipt_sha256", "")) == NAVY_CHAPEL_LIVE_REVIEW_RECEIPT_SHA256
		and int(acceptance.get("numerator_effect", -1)) == 1
		and bool(acceptance.get("reference_recognizable", false))
		and bool(acceptance.get("wall_and_roof_are_one_physical_unit", false))
		and str(geometry.get("canonical_wall_record_sha256", "")) == "69769fef402b480f1626fdce47e6d4ad49ecb710dab2b2e7373e5efa5acf0080"
		and str(geometry.get("canonical_roof_record_sha256", "")) == "54bcd378997d0778bdaee432dc24ecdbb142c5dc5371166cf2d690ebb245b832"
		and bool(geometry.get("horizontal_source_footprint_preserved", false))
		and str(geometry.get("visual_geometry_signature", "")) == NAVY_CHAPEL_GEOMETRY_SIGNATURE
		and int(geometry.get("visual_mesh_instances", -1)) == 6
		and int(geometry.get("visual_surfaces", -1)) == 6
		and int(geometry.get("visual_triangles", -1)) == 540
		and int(geometry.get("world_records", -1)) == 735
		and int(geometry.get("world_mesh_instances", -1)) == 944
		and int(geometry.get("world_surfaces", -1)) == 957
		and int(geometry.get("world_triangles", -1)) == 64572
		and int(geometry.get("world_static_bodies", -1)) == 466
		and int(geometry.get("world_shapes", -1)) == 466
		and str(ownership.get("live_ownership_signature", "")) == NAVY_CHAPEL_OWNERSHIP_SIGNATURE
		and int(ownership.get("structural_owner_count", -1)) == 2
		and int(ownership.get("shape_count", -1)) == 2
		and int(ownership.get("spray_owner_count", -1)) == 1
		and int(ownership.get("navigation_owner_count", -1)) == 0
		and int(ownership.get("wall_collision_triangles", -1)) == 94
		and int(ownership.get("roof_collision_triangles", -1)) == 50
		and bool(ownership.get("wall_is_sole_spray_receiver", false))
		and ownership.get("roof_is_wall_spray_receiver") == false
		and str(replacement.get("source_key", "")) == "w291189336"
		and str(replacement.get("wall_object_key", "")) == NAVY_CHAPEL_RECEIVER
		and str(replacement.get("roof_object_key", "")) == "building:w291189336:roof"
		and bool(replacement.get("actual_supplied_chunk_pair_required", false))
		and replacement.get("fallback_allowed") == false
		and replacement.get("generic_stack_allowed") == false
		and truth.get("as_built_fidelity_claimed") == false
		and truth.get("game_distinctive_claimed") == false
		and truth.get("receiver_complete_inferred_from_art") == false
		and bool(truth.get("protected_runs_module_free", false))
		and bool(truth.get("side_count_and_spacing_are_production_inference", false)),
		"navy_chapel_parity_mismatch",
		"Navy Chapel receipt, paired geometry, topology, ownership, replacement, or truth boundary drifted.",
	)


func _validate_runtime_asset(asset: Dictionary, owner_id: String) -> bool:
	if not _require(_has_exact_keys(asset, ["path", "sha256"]), "runtime_asset_invalid", "%s runtime asset fields drifted." % owner_id):
		return false
	var path := str(asset.get("path", ""))
	if not _require(_is_safe_runtime_path(path), "dirty_path", "%s runtime asset escapes the game package: %s" % [owner_id, path]):
		return false
	if not _require(FileAccess.file_exists(path), "runtime_asset_missing", "%s runtime asset is missing: %s" % [owner_id, path]):
		return false
	if not _require(_is_sha256(str(asset.get("sha256", ""))) and FileAccess.get_sha256(path) == str(asset.get("sha256", "")), "runtime_asset_hash_drift", "%s runtime asset hash drifted: %s" % [owner_id, path]):
		return false
	return _runtime_asset_closure_is_clean(path, {})


func _runtime_asset_closure_is_clean(path: String, visited: Dictionary) -> bool:
	if visited.has(path):
		return true
	visited[path] = true
	if not FileAccess.file_exists(path):
		return _require(false, "runtime_asset_missing", "Runtime dependency is missing: %s" % path)
	if not TEXT_ASSET_EXTENSIONS.has(path.get_extension().to_lower()):
		return true
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _require(false, "runtime_asset_missing", "Runtime dependency cannot be opened: %s" % path)
	var contents := file.get_as_text()
	if not _runtime_asset_text_is_clean(contents):
		return _require(false, "dirty_asset_closure", "Runtime dependency closure contains a source-only path or URL: %s" % path)
	var cursor := 0
	while true:
		var dependency_start := contents.find("res://", cursor)
		if dependency_start < 0:
			break
		var dependency_end := contents.find("\"", dependency_start)
		if dependency_end < 0:
			return _require(false, "runtime_asset_invalid", "Runtime dependency path is unterminated in %s." % path)
		var dependency_path := contents.substr(dependency_start, dependency_end - dependency_start)
		if dependency_path.ends_with("/"):
			cursor = dependency_end + 1
			continue
		if not _is_safe_runtime_dependency_path(dependency_path):
			return _require(false, "dirty_asset_closure", "Runtime dependency escapes the game package: %s" % dependency_path)
		if not _runtime_asset_closure_is_clean(dependency_path, visited):
			return false
		cursor = dependency_end + 1
	return true


func _runtime_asset_match(assets: Array, path: String, sha256: String) -> bool:
	for asset_value: Variant in assets:
		var asset := asset_value as Dictionary
		if str(asset.get("path", "")) == path and str(asset.get("sha256", "")) == sha256:
			return true
	return false


func _runtime_asset_arrays_match(left: Array, right: Array) -> bool:
	var left_signatures := []
	var right_signatures := []
	for asset_value: Variant in left:
		var asset := asset_value as Dictionary
		left_signatures.append("%s:%s" % [str(asset.get("path", "")), str(asset.get("sha256", ""))])
	for asset_value: Variant in right:
		var asset := asset_value as Dictionary
		right_signatures.append("%s:%s" % [str(asset.get("path", "")), str(asset.get("sha256", ""))])
	left_signatures.sort()
	right_signatures.sort()
	return left_signatures == right_signatures


func _projection_descriptor_ids_for_adapter(adapter: Dictionary) -> Array:
	var descriptor_ids := []
	for projection_value: Variant in adapter.get("runtime_asset_projections", []) as Array:
		var projection := projection_value as Dictionary
		var matched_id := ""
		for descriptor_value: Variant in _projections_by_id.values():
			var descriptor := descriptor_value as Dictionary
			if str(descriptor.get("source_asset_sha256", "")) == str(projection.get("source_asset_sha256", "")) \
			and str(descriptor.get("source_asset_type", "")) == str(projection.get("source_asset_type", "")):
				matched_id = str(descriptor.get("descriptor_id", ""))
				break
		if matched_id.is_empty():
			return ["__missing_projection_descriptor__"]
		if not descriptor_ids.has(matched_id):
			descriptor_ids.append(matched_id)
	return descriptor_ids


func _registry_projection_occurrence_matches(occurrence_id: String, descriptor: Dictionary) -> bool:
	for adapter_value: Variant in _adapters_by_id.values():
		var adapter := adapter_value as Dictionary
		for projection_value: Variant in adapter.get("runtime_asset_projections", []) as Array:
			var projection := projection_value as Dictionary
			if str(projection.get("projection_id", "")) != occurrence_id:
				continue
			return str(projection.get("source_asset_sha256", "")) == str(descriptor.get("source_asset_sha256", "")) \
				and str(projection.get("source_asset_type", "")) == str(descriptor.get("source_asset_type", "")) \
				and (descriptor.get("consumer_adapter_ids", []) as Array).has(str(adapter.get("adapter_id", "")))
	return false


func _array_is_unique(values: Array) -> bool:
	var seen := {}
	for value: Variant in values:
		var key := str(value)
		if seen.has(key):
			return false
		seen[key] = true
	return true


func _derive_unit_content_mode(receivers: Array) -> String:
	var modes := {}
	for receiver_value: Variant in receivers:
		modes[str((receiver_value as Dictionary).get("runtime_content_mode", ""))] = true
	var values := modes.keys()
	values.sort()
	if values == ["generated_placeholder"]:
		return "all_receivers_generated_placeholder"
	if values == ["legacy_adapter"]:
		return "all_receivers_legacy_adapter"
	if values == ["active_building_1_hero"]:
		return "all_receivers_active_building_1_hero"
	if values == ["active_building_3_hero"]:
		return "all_receivers_active_building_3_hero"
	if values == ["active_isle_house_variant_c"]:
		return "all_receivers_active_isle_house_variant_c"
	if values == ["active_navy_chapel_187_paired_replacement"]:
		return "all_receivers_active_navy_chapel_187_paired_replacement"
	if values == ["generated_placeholder", "legacy_adapter"]:
		return "mixed_legacy_adapter_and_generated_placeholder"
	if values == ["active_isle_house_variant_c", "legacy_adapter"]:
		return "mixed_legacy_high_and_active_variant_c_low"
	return "mixed_runtime_content"


func _receiver_by_key(receivers: Array, receiver_key: String) -> Dictionary:
	for receiver_value: Variant in receivers:
		var receiver := receiver_value as Dictionary
		if str(receiver.get("receiver_key", "")) == receiver_key:
			return receiver
	return {}


func _is_allowed_executable(path: String, kind: String) -> bool:
	if not ALLOWED_EXECUTABLE_KINDS.has(kind) or not _is_safe_runtime_path(path):
		return false
	if not ALLOWED_EXECUTABLE_ROOTS.any(func(root: Variant) -> bool: return path.begins_with(str(root))):
		return false
	return (kind == "gdscript" and path.ends_with(".gd")) or (kind == "packed_scene" and path.ends_with(".tscn"))


func _is_safe_runtime_json_path(path: String) -> bool:
	return _is_safe_runtime_path(path) and path.ends_with(".json")


func _is_safe_runtime_dependency_path(path: String) -> bool:
	return (_is_safe_runtime_path(path) or path.begins_with("res://generated/world/")) \
		and not path.contains("..") \
		and not path.contains("\\") \
		and _runtime_asset_text_is_clean(path)


func _is_safe_runtime_path(path: String) -> bool:
	return path.begins_with("res://game/") \
		and not path.contains("..") \
		and not path.contains("\\") \
		and _runtime_asset_text_is_clean(path)


func _runtime_asset_text_is_clean(text: String) -> bool:
	var slash := "/"
	return not text.contains("discovery" + slash) \
		and not text.contains("evidence" + slash) \
		and not text.contains(slash + "Users" + slash) \
		and not text.contains(slash + "Volumes" + slash) \
		and not text.contains("http:" + slash + slash) \
		and not text.contains("https:" + slash + slash)


func _runtime_boundary_is_clean(value: Variant) -> bool:
	match typeof(value):
		TYPE_STRING:
			return _runtime_asset_text_is_clean(str(value))
		TYPE_ARRAY:
			for child: Variant in value as Array:
				if not _runtime_boundary_is_clean(child):
					return false
			return true
		TYPE_DICTIONARY:
			for child: Variant in (value as Dictionary).values():
				if not _runtime_boundary_is_clean(child):
					return false
			return true
	return true


func _has_exact_keys(value: Dictionary, expected: Array) -> bool:
	var actual := value.keys()
	var wanted := expected.duplicate()
	actual.sort()
	wanted.sort()
	return actual == wanted


func _is_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for index in value.length():
		var character := value.substr(index, 1)
		if not "0123456789abcdef".contains(character):
			return false
	return true


func _read_json(path: String, error_code: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_require(false, error_code, "JSON file cannot be opened: %s" % path)
		return null
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	if parse_error != OK:
		_require(false, error_code, "JSON parse failed at line %d: %s" % [parser.get_error_line(), parser.get_error_message()])
		return null
	return parser.data


func _resolution_failure(code: String, message: String) -> Dictionary:
	return {
		"error_code": code,
		"error_message": message,
		"ok": false,
	}


func _require(condition: bool, code: String, message: String) -> bool:
	if condition:
		return true
	if _last_error_code.is_empty():
		_last_error_code = code
		_last_error_message = message
	return false


func _has_error() -> bool:
	return not _last_error_code.is_empty()


func _status() -> Dictionary:
	return {
		"error_code": _last_error_code,
		"error_message": _last_error_message,
		"ok": false,
	}


func _reset() -> void:
	_loaded = false
	_registry = {}
	_adapter_contracts = {}
	_units_by_id = {}
	_receivers_by_key = {}
	_adapters_by_id = {}
	_plans_by_receiver = {}
	_projections_by_id = {}
	_last_error_code = ""
	_last_error_message = ""
