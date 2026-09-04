extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const EXPECTED_REGISTRY_SHA256 := "36eef28d1abce9d9838da6e959222ad6767e40e198b90b734496e6d2dc2cd79b"
const EXPECTED_UNITS := 213
const EXPECTED_RECEIVERS := 214
const EXPECTED_SOURCE_RECORDS := 215
const EXPECTED_RUNS := 4971
const EXPECTED_LEGACY_ADAPTERS := 9
const EXPECTED_ACTIVE_ADAPTERS := 5
const EXPECTED_RUNTIME_ADAPTERS := 14
const EXPECTED_IDENTITY_ASSERTIONS := 2
const ACCEPTED_REFERENCE_UNITS := {
	"physical-building:r16681702": true,
	"physical-building:w1222720021": true,
	"physical-building:w1249412093": true,
	"physical-building:w1249412094": true,
	"physical-building:w291189336": true,
	"physical-building:w34313540": true,
}
const EXPECTED_IDENTITY_CORRECTIONS := {
	"physical-building:w24274434": "08000082",
	"physical-building:w34313540": "08000083",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.file_exists(REGISTRY_PATH), "Runtime facade registry is missing.") \
	or not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Runtime facade registry hash drifted."):
		_finish()
		return
	var registry := _json(REGISTRY_PATH)
	if not _require(not registry.is_empty(), "Runtime facade registry JSON is invalid.") \
	or not _require(str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/5", "Runtime facade registry schema drifted.") \
	or not _require(_runtime_boundary_is_clean(registry), "Runtime facade registry leaks a source-only path or URL."):
		_finish()
		return
	_validate_counts(registry)
	_validate_units(registry)
	_validate_runtime_adapters(registry)
	if not _failed:
		print("PASS: facade recognition registry is package-safe and fail-closed: 213 physical units / 214 direct wall receivers / 215 source records / 4,971 wall runs / 6/213 independently accepted reference-recognizable units / 9 claim-neutral legacy adapters + 5 exact-current active adapters / 2 separated identity corrections; SHA-256 %s" % EXPECTED_REGISTRY_SHA256)
	_finish()


func _validate_counts(registry: Dictionary) -> void:
	var counts := registry.get("counts", {}) as Dictionary
	var claims := registry.get("claim_totals", {}) as Dictionary
	var receiver_claims := claims.get("receiver_complete", {}) as Dictionary
	var game_claims := claims.get("game_distinctive", {}) as Dictionary
	var reference_claims := claims.get("reference_recognizable", {}) as Dictionary
	var as_built_claims := claims.get("as_built_fidelity", {}) as Dictionary
	_require(int(counts.get("recognition_units", -1)) == EXPECTED_UNITS, "Recognition-unit count is not 213.")
	_require(int(counts.get("standalone_units", -1)) == 212 and int(counts.get("composite_units", -1)) == 1, "Standalone/composite unit split is not 212/1.")
	_require(int(counts.get("direct_wall_receivers", -1)) == EXPECTED_RECEIVERS, "Direct wall-receiver count is not 214.")
	_require(int(counts.get("source_record_memberships", -1)) == EXPECTED_SOURCE_RECORDS, "Source-record membership count is not 215.")
	_require(int(counts.get("visible_wall_runs", -1)) == EXPECTED_RUNS, "Visible wall-run count is not 4,971.")
	_require(int(counts.get("legacy_adapter_receivers", -1)) == EXPECTED_LEGACY_ADAPTERS, "Legacy-adapter count is not 9.")
	_require(int(counts.get("active_runtime_adapter_receivers", -1)) == EXPECTED_ACTIVE_ADAPTERS, "Active runtime-adapter count is not 5.")
	_require(int(counts.get("runtime_adapter_receivers", -1)) == EXPECTED_RUNTIME_ADAPTERS, "Combined runtime-adapter count is not 14.")
	_require(int(counts.get("identity_assertion_summaries", -1)) == EXPECTED_IDENTITY_ASSERTIONS, "Identity-assertion summary count is not 2.")
	_require(int(receiver_claims.get("verified", -1)) == EXPECTED_UNITS and int(receiver_claims.get("failed", -1)) == 0, "Receiver-complete claim aggregate drifted.")
	_require(int(game_claims.get("accepted", -1)) == 0 and int(game_claims.get("not_evaluated", -1)) == EXPECTED_UNITS, "Game-distinctive claims were imported or omitted.")
	_require(int(reference_claims.get("accepted", -1)) == 6 and int(reference_claims.get("not_evaluated", -1)) == EXPECTED_UNITS - 6, "Reference-recognition aggregate is not exactly 6/213.")
	_require(int(as_built_claims.get("claimed", -1)) == 0 and int(as_built_claims.get("limited", -1)) == 0 and int(as_built_claims.get("unclaimed", -1)) == EXPECTED_UNITS, "As-built claims were imported or omitted.")
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted_ids := metric.get("accepted_physical_unit_ids", []) as Array
	var expected_ids := ACCEPTED_REFERENCE_UNITS.keys()
	accepted_ids.sort()
	expected_ids.sort()
	_require(int(metric.get("numerator", -1)) == 6 and int(metric.get("denominator", -1)) == EXPECTED_UNITS and str(metric.get("display", "")) == "6/213", "Physical-unit recognition metric is not exactly 6/213.")
	_require(accepted_ids == expected_ids, "Accepted physical-unit set drifted.")
	_require(metric.get("isle_house_non_numerator_source_keys", []) == ["w1282547786", "w1282547787"], "Isle House source parts entered the numerator.")


func _validate_units(registry: Dictionary) -> void:
	var units := registry.get("units", []) as Array
	var source_keys := {}
	var receiver_keys := {}
	var source_count := 0
	var receiver_count := 0
	var run_count := 0
	var composite_count := 0
	var identity_assertion_count := 0
	var building_1_main_seen := false
	var building_1_tower_seen := false
	var building_3_seen := false
	var navy_chapel_seen := false
	_require(units.size() == EXPECTED_UNITS, "Runtime unit array is not 213 entries.")
	for unit_value: Variant in units:
		var unit := unit_value as Dictionary
		var unit_id := str(unit.get("unit_id", ""))
		var claims := unit.get("claim_status", {}) as Dictionary
		var capture := unit.get("capture_contract", {}) as Dictionary
		var frozen_identity := unit.get("identity", {}) as Dictionary
		var identity_assertions := unit.get("identity_assertions", []) as Array
		var recognition := unit.get("recognition_contract", {}) as Dictionary
		var accepted := ACCEPTED_REFERENCE_UNITS.has(unit_id)
		_require(str(claims.get("receiver_complete", "")) == "verified", "%s is not receiver-complete." % unit_id)
		_require(str(claims.get("game_distinctive", "")) == "not_evaluated", "%s imports a game-distinctive claim." % unit_id)
		_require(str(claims.get("reference_recognizable", "")) == ("accepted" if accepted else "not_evaluated"), "%s reference-recognition state does not match the accepted physical-unit set." % unit_id)
		_require(str(claims.get("as_built_fidelity", "")) == "unclaimed", "%s imports an as-built claim." % unit_id)
		_require(bool(recognition.get("game_only_cues_do_not_prove_real_world_recognition", false)), "%s weakens the recognition claim boundary." % unit_id)
		_require(str(recognition.get("capture_status", "")) == ("configured" if accepted else "unconfigured"), "%s capture state does not match its acceptance." % unit_id)
		_require(str(capture.get("status", "")) == ("configured" if accepted else "unconfigured"), "%s runtime capture contract does not match its acceptance." % unit_id)
		var cues := unit.get("recognition_cues", []) as Array
		var acceptance_records := unit.get("acceptance_records", []) as Array
		_require(cues.size() >= 2 if accepted else cues.is_empty(), "%s recognition cues do not match its acceptance state." % unit_id)
		_require(acceptance_records.size() == 1 if accepted else acceptance_records.is_empty(), "%s acceptance-receipt count does not match its acceptance state." % unit_id)
		if accepted and acceptance_records.size() == 1:
			var receipt := acceptance_records[0] as Dictionary
			_require(str(receipt.get("review_kind", "")) == "independent_reference_recognition" and str(receipt.get("status", "")) == "accept", "%s lacks independent reference-recognition acceptance." % unit_id)
			_require(str(receipt.get("review_receipt_sha256", "")).length() == 64 and str(receipt.get("evidence_manifest_sha256", "")).length() == 64, "%s acceptance hashes are invalid." % unit_id)
		_require(not bool(frozen_identity.get("currentness_claimed", true)), "%s silently claims its frozen identity is current." % unit_id)
		if EXPECTED_IDENTITY_CORRECTIONS.has(unit_id):
			_require(identity_assertions.size() == 1, "%s must carry exactly one separated identity correction." % unit_id)
			if identity_assertions.size() == 1:
				var assertion := identity_assertions[0] as Dictionary
				_require(str(assertion.get("asserted_value", "")) == str(EXPECTED_IDENTITY_CORRECTIONS[unit_id]), "%s authoritative correction drifted." % unit_id)
				_require(str(assertion.get("frozen_source_value", "")) == "08000081", "%s frozen NRHP provenance was overwritten." % unit_id)
				_require(bool(assertion.get("frozen_value_preserved", false)) and bool(assertion.get("supersedes_frozen_value", false)), "%s correction does not explicitly preserve and supersede frozen provenance." % unit_id)
				_require(not bool(assertion.get("currentness_claimed", true)), "%s correction silently claims broader currentness." % unit_id)
		else:
			_require(identity_assertions.is_empty(), "%s unexpectedly carries an identity assertion." % unit_id)
		identity_assertion_count += identity_assertions.size()
		var unit_sources := unit.get("source_records", []) as Array
		var unit_receivers := unit.get("direct_receivers", []) as Array
		if str(unit.get("unit_kind", "")) == "composite_building":
			composite_count += 1
			_require(unit_id == "physical-building:w1249412094", "Composite recognition-unit identity drifted.")
			_require(unit_sources.size() == 3 and unit_receivers.size() == 2, "Isle House composite must own three sources and two receivers.")
			var isle_high := _receiver_by_key(unit_receivers, "building-composite:w1249412094:w1282547786:wall")
			var isle_low := _receiver_by_key(unit_receivers, "building-composite:w1249412094:w1282547787:wall")
			_require(not isle_high.is_empty() and str(isle_high.get("runtime_content_mode", "")) == "legacy_adapter" and not str(isle_high.get("runtime_adapter_id", "")).is_empty(), "Isle House high receiver lost its legacy adapter.")
			_require(not isle_low.is_empty() and str(isle_low.get("runtime_content_mode", "")) == "active_isle_house_variant_c" and str(isle_low.get("runtime_adapter_id", "")) == "active-adapter:isle-house-variant-c:building-composite:w1249412094:w1282547787:wall", "Isle House low receiver is not bound to active Variant C.")
			_require(str(unit.get("runtime_content_mode", "")) == "mixed_legacy_high_and_active_variant_c_low", "Isle House receiver states were collapsed at unit level.")
		_require(unit_id not in ["physical-building:w1282547786", "physical-building:w1282547787"], "Isle House source part was promoted to a physical-unit numerator entry.")
		if unit_id == "physical-building:r16681702":
			building_1_main_seen = true
			_require(unit_receivers.size() == 1 and str((unit_receivers[0] as Dictionary).get("receiver_key", "")) == "building:r16681702:wall", "Building 1 main unit no longer owns its exact wall receiver.")
			_require(str((unit_receivers[0] as Dictionary).get("runtime_content_mode", "")) == "active_building_1_hero", "Building 1 main wall is not bound to current hero dispatch.")
			_require((unit.get("legacy_adapter_ids", []) as Array).is_empty() and (unit.get("active_runtime_adapter_ids", []) as Array).size() == 1, "Building 1 main unit retains obsolete or missing adapter membership.")
		if unit_id == "physical-building:w1222720021":
			building_1_tower_seen = true
			_require(unit_receivers.size() == 1 and str((unit_receivers[0] as Dictionary).get("receiver_key", "")) == "building:w1222720021:wall", "Building 1 tower no longer owns its separate wall receiver.")
			_require(str((unit_receivers[0] as Dictionary).get("runtime_content_mode", "")) == "active_building_1_hero", "Building 1 tower wall is not bound to current hero dispatch.")
			_require((unit.get("legacy_adapter_ids", []) as Array).is_empty() and (unit.get("active_runtime_adapter_ids", []) as Array).size() == 1, "Building 1 tower retains obsolete or missing adapter membership.")
		if unit_id == "physical-building:w34313540":
			building_3_seen = true
			_require(unit_receivers.size() == 1 and str((unit_receivers[0] as Dictionary).get("receiver_key", "")) == "building:w34313540:wall", "Building 3 no longer owns its exact wall receiver.")
			_require(str((unit_receivers[0] as Dictionary).get("runtime_content_mode", "")) == "active_building_3_hero", "Building 3 wall is not bound to current wall/roof hero dispatch.")
			_require((unit.get("legacy_adapter_ids", []) as Array).is_empty() and (unit.get("active_runtime_adapter_ids", []) as Array).size() == 1, "Building 3 retains obsolete legacy or missing active adapter membership.")
		if unit_id == "physical-building:w291189336":
			navy_chapel_seen = true
			_require(unit_receivers.size() == 1 and str((unit_receivers[0] as Dictionary).get("receiver_key", "")) == "building:w291189336:wall", "Navy Chapel no longer owns its exact wall receiver.")
			_require(str((unit_receivers[0] as Dictionary).get("runtime_content_mode", "")) == "active_navy_chapel_187_paired_replacement", "Navy Chapel wall is not bound to the paired wall/roof replacement.")
			_require(str(unit.get("runtime_content_mode", "")) == "all_receivers_active_navy_chapel_187_paired_replacement", "Navy Chapel unit mode no longer preserves paired replacement semantics.")
			_require((unit.get("legacy_adapter_ids", []) as Array).is_empty() and (unit.get("active_runtime_adapter_ids", []) as Array).size() == 1, "Navy Chapel retains obsolete legacy or missing active adapter membership.")
		for source_value: Variant in unit_sources:
			var source_key := str((source_value as Dictionary).get("source_key", ""))
			_require(not source_key.is_empty() and not source_keys.has(source_key), "%s has a missing or duplicate source record %s." % [unit_id, source_key])
			source_keys[source_key] = true
			source_count += 1
		for receiver_value: Variant in unit_receivers:
			var receiver := receiver_value as Dictionary
			var receiver_key := str(receiver.get("receiver_key", ""))
			var runs := int(receiver.get("run_count", -1))
			_require(not receiver_key.is_empty() and not receiver_keys.has(receiver_key), "%s has a missing or duplicate receiver %s." % [unit_id, receiver_key])
			_require(str(receiver.get("collision_kind", "")) == "world_solid" and bool(receiver.get("opaque", false)) and bool(receiver.get("spray_receiver_expected", false)), "%s lost wall collision/spray expectations." % receiver_key)
			_require(int(receiver.get("vertex_count", -1)) == runs * 4, "%s no longer has four vertices per run." % receiver_key)
			_require(int(receiver.get("index_count", -1)) == runs * 6 and int(receiver.get("triangle_count", -1)) == runs * 2, "%s no longer has one quad per run." % receiver_key)
			_require(int(receiver.get("exterior_foundation_runs", -1)) + int(receiver.get("shared_wall_runs", -1)) == runs, "%s run ownership does not reconcile." % receiver_key)
			receiver_keys[receiver_key] = true
			receiver_count += 1
			run_count += runs
	_require(composite_count == 1, "Runtime registry does not contain exactly one composite recognition unit.")
	_require(source_count == EXPECTED_SOURCE_RECORDS and source_keys.size() == EXPECTED_SOURCE_RECORDS, "Runtime units do not partition 215 unique source records.")
	_require(receiver_count == EXPECTED_RECEIVERS and receiver_keys.size() == EXPECTED_RECEIVERS, "Runtime units do not partition 214 unique receivers.")
	_require(run_count == EXPECTED_RUNS, "Runtime unit receivers do not total 4,971 runs.")
	_require(identity_assertion_count == EXPECTED_IDENTITY_ASSERTIONS, "Runtime units do not contain exactly two identity corrections.")
	_require(building_1_main_seen and building_1_tower_seen and building_3_seen and navy_chapel_seen, "Building 1 main/tower, Building 3, or Navy Chapel is not separately represented.")


func _validate_runtime_adapters(registry: Dictionary) -> void:
	var legacy_adapters := registry.get("legacy_adapters", []) as Array
	var active_adapters := registry.get("active_runtime_adapters", []) as Array
	var adapters := legacy_adapters.duplicate()
	adapters.append_array(active_adapters)
	var receiver_keys := {}
	_require(legacy_adapters.size() == EXPECTED_LEGACY_ADAPTERS, "Runtime legacy adapter array is not nine entries.")
	_require(active_adapters.size() == EXPECTED_ACTIVE_ADAPTERS, "Runtime active adapter array is not five entries.")
	_require(adapters.size() == EXPECTED_RUNTIME_ADAPTERS, "Combined runtime adapter arrays are not 14 entries.")
	for adapter_value: Variant in adapters:
		var adapter := adapter_value as Dictionary
		var adapter_id := str(adapter.get("adapter_id", ""))
		var receiver_key := str(adapter.get("receiver_key", ""))
		_require(not receiver_keys.has(receiver_key), "%s duplicates runtime receiver %s." % [adapter_id, receiver_key])
		receiver_keys[receiver_key] = true
		_require(not bool(adapter.get("whole_building_recognizability_imported", true)), "%s imports whole-building recognizability." % adapter_id)
		_require(str(adapter.get("recognition_claim_effect", "")) == "none", "%s changes a recognition claim." % adapter_id)
		for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
			var asset := asset_value as Dictionary
			var path := str(asset.get("path", ""))
			_require(path.begins_with("res://game/"), "%s has a non-runtime asset path %s." % [adapter_id, path])
			_require(FileAccess.file_exists(path), "%s runtime asset is absent: %s." % [adapter_id, path])
			_require(FileAccess.get_sha256(path) == str(asset.get("sha256", "")), "%s runtime asset hash drifted: %s." % [adapter_id, path])
			_require(_runtime_asset_closure_is_clean(path, {}), "%s runtime asset dependency closure is not package-safe: %s." % [adapter_id, path])
		for projection_value: Variant in adapter.get("runtime_asset_projections", []) as Array:
			var projection := projection_value as Dictionary
			_require(str(projection.get("package_contract", "")) == "sanitized_adapter_metadata_summary_only", "%s has an invalid sanitized projection contract." % adapter_id)
			_require(str(projection.get("source_asset_sha256", "")).length() == 64, "%s has a projection without a source hash." % adapter_id)
			_require(not projection.has("path"), "%s leaks a source asset path through its projection." % adapter_id)
	for adapter_value: Variant in active_adapters:
		var adapter := adapter_value as Dictionary
		var receiver_key := str(adapter.get("receiver_key", ""))
		_require(receiver_key in ["building-composite:w1249412094:w1282547787:wall", "building:r16681702:wall", "building:w1222720021:wall", "building:w291189336:wall", "building:w34313540:wall"], "Active adapter targets an unexpected receiver: %s." % receiver_key)
		_require(str(adapter.get("state", "")) == "active_runtime_target_specific_content", "%s is not classified as active runtime content." % receiver_key)
		var contract := adapter.get("active_runtime_contract", {}) as Dictionary
		if receiver_key == "building:w34313540:wall":
			var behavior := contract.get("behavior_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var collision := behavior.get("collision_contract", {}) as Dictionary
			_require(str(adapter.get("attachment_kind", "")) == "active_building_3_wall_roof_hero_replacement" and str(adapter.get("runtime_content_mode", "")) == "active_building_3_hero", "Building 3 has stale active-content classification.")
			_require((adapter.get("runtime_assets", []) as Array).size() == 9 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "Building 3 does not account for its complete package-safe wrapper/config/facade set.")
			_require(str(behavior.get("parity_status", "")) == "exact_current_behavior_and_dependency_set_verified" and int(geometry.get("wall_triangles", 0)) == 236 and int(geometry.get("roof_triangles", 0)) == 675, "Building 3 wall/roof geometry parity drifted.")
			_require(bool(collision.get("collision_matches_visible_geometry", false)) and bool(collision.get("roof_landing_world_solid", false)) and str(collision.get("spray_ownership", "")) == "wall_only", "Building 3 collision/landing/spray parity drifted.")
		elif receiver_key == "building-composite:w1249412094:w1282547787:wall":
			var behavior := contract.get("behavior_contract", {}) as Dictionary
			var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var ownership := behavior.get("ownership_contract", {}) as Dictionary
			_require(str(adapter.get("attachment_kind", "")) == "active_isle_house_variant_c_low_part_replacement" and str(adapter.get("runtime_content_mode", "")) == "active_isle_house_variant_c", "Isle House has stale active-content classification.")
			_require((adapter.get("runtime_assets", []) as Array).size() == 1 and (adapter.get("runtime_asset_projections", []) as Array).size() == 3, "Isle House source/package boundary drifted.")
			_require(str(acceptance.get("independent_live_review_receipt_sha256", "")) == "37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8" and int(acceptance.get("numerator_effect", -1)) == 1, "Isle House receipt or numerator effect drifted.")
			_require(str(geometry.get("live_signature", "")) == "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981" and str(geometry.get("overlay_repair_signature", "")) == "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69", "Isle House signatures drifted.")
			_require(int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 944 and int(geometry.get("world_surfaces", -1)) == 957 and int(geometry.get("world_triangles", -1)) == 64572 and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466, "Isle House exact-current world topology drifted.")
			_require(bool(ownership.get("low_receiver_is_sole_collision_and_spray_owner", false)) and int(ownership.get("decorative_collision_nodes", -1)) == 0 and int(ownership.get("decorative_navigation_nodes", -1)) == 0 and int(ownership.get("decorative_spray_nodes", -1)) == 0, "Isle House ownership boundary drifted.")
		elif receiver_key == "building:w291189336:wall":
			var behavior := contract.get("behavior_contract", {}) as Dictionary
			var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var ownership := behavior.get("ownership_contract", {}) as Dictionary
			_require(str(adapter.get("attachment_kind", "")) == "active_navy_chapel_187_paired_wall_roof_replacement" and str(adapter.get("runtime_content_mode", "")) == "active_navy_chapel_187_paired_replacement", "Navy Chapel has stale active-content classification.")
			_require((adapter.get("runtime_assets", []) as Array).size() == 9 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "Navy Chapel does not account for its package-safe adapter/config/prototype/material set.")
			_require(str(acceptance.get("independent_live_review_receipt_sha256", "")) == "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9" and int(acceptance.get("numerator_effect", -1)) == 1 and bool(acceptance.get("wall_and_roof_are_one_physical_unit", false)), "Navy Chapel receipt or one-unit rollup drifted.")
			_require(str(geometry.get("visual_geometry_signature", "")) == "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46" and int(geometry.get("visual_triangles", -1)) == 540 and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 944 and int(geometry.get("world_surfaces", -1)) == 957 and int(geometry.get("world_triangles", -1)) == 64572 and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466, "Navy Chapel geometry/world parity drifted.")
			_require(str(ownership.get("live_ownership_signature", "")) == "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7" and int(ownership.get("structural_owner_count", -1)) == 2 and int(ownership.get("shape_count", -1)) == 2 and int(ownership.get("spray_owner_count", -1)) == 1 and int(ownership.get("wall_collision_triangles", -1)) == 94 and int(ownership.get("roof_collision_triangles", -1)) == 50 and bool(ownership.get("wall_is_sole_spray_receiver", false)) and ownership.get("roof_is_wall_spray_receiver") == false, "Navy Chapel collision/spray ownership parity drifted.")
		else:
			_require(str(adapter.get("attachment_kind", "")) == "active_building_1_hero_replacement" and str(adapter.get("content_classification", "")) == "active_target_specific_hero_replacement", "%s has stale active-content classification." % receiver_key)
			var summary := contract.get("config_summary", {}) as Dictionary
			var target := summary.get("target", {}) as Dictionary
			_require(bool(target.get("tower_remains_separately_reviewable", false)), "%s collapses the tower into the main recognition unit." % receiver_key)
			_require((adapter.get("runtime_assets", []) as Array).size() + (adapter.get("runtime_asset_projections", []) as Array).size() == 10, "%s does not account for its hero script, config, and eight exact-current materials." % receiver_key)
	var registry_text := JSON.stringify(registry)
	_require(not registry_text.contains("building_1_recognizable_facade") and not registry_text.contains("building_1_recognizability_placements"), "Runtime registry retains obsolete Building 1 facade assets.")


func _receiver_by_key(receivers: Array, receiver_key: String) -> Dictionary:
	for receiver_value: Variant in receivers:
		var receiver := receiver_value as Dictionary
		if str(receiver.get("receiver_key", "")) == receiver_key:
			return receiver
	return {}


func _runtime_asset_closure_is_clean(path: String, visited: Dictionary) -> bool:
	if visited.has(path):
		return true
	visited[path] = true
	if not FileAccess.file_exists(path):
		return false
	var extension := path.get_extension().to_lower()
	if not ["gd", "gdshader", "json", "tres", "tscn"].has(extension):
		return true
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var contents := file.get_as_text()
	if not _runtime_asset_text_is_clean(contents):
		return false
	var cursor := 0
	while true:
		var dependency_start := contents.find("res://", cursor)
		if dependency_start < 0:
			break
		var dependency_end := contents.find("\"", dependency_start)
		if dependency_end < 0:
			return false
		var dependency_path := contents.substr(dependency_start, dependency_end - dependency_start)
		if not _runtime_asset_closure_is_clean(dependency_path, visited):
			return false
		cursor = dependency_end + 1
	return true


func _runtime_asset_text_is_clean(text: String) -> bool:
	return not text.contains("discovery/") \
		and not text.contains("evidence/") \
		and not text.contains("/Users/") \
		and not text.contains("/Volumes/") \
		and not text.contains("http://") \
		and not text.contains("https://")


func _runtime_boundary_is_clean(value: Variant) -> bool:
	match typeof(value):
		TYPE_STRING:
			var text := str(value)
			return not text.contains("discovery/") \
				and not text.contains("evidence/") \
				and not text.begins_with("/Users/") \
				and not text.begins_with("/Volumes/") \
				and not text.begins_with("http://") \
				and not text.begins_with("https://")
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
	push_error("FAIL [facade_recognition_registry]: %s" % message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
