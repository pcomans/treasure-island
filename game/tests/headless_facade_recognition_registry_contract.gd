extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const EXPECTED_REGISTRY_SHA256 := "9247d36589c36c948f28d58f2a72002379906850e5b094e2633129a3cb05e2fc"
const EXPECTED_UNITS := 213
const EXPECTED_RECEIVERS := 214
const EXPECTED_SOURCE_RECORDS := 215
const EXPECTED_RUNS := 4971
const EXPECTED_LEGACY_ADAPTERS := 9
const EXPECTED_ACTIVE_ADAPTERS := 31
const EXPECTED_RUNTIME_ADAPTERS := 40
const EXPECTED_IDENTITY_ASSERTIONS := 2
const ACCEPTED_REFERENCE_UNITS := {
	"physical-building:r16681702": true,
	"physical-building:w1222720021": true,
	"physical-building:w1249412093": true,
	"physical-building:w1249412094": true,
	"physical-building:w291189336": true,
	"physical-building:w34313540": true,
	"physical-building:w34313545": true,
	"physical-building:w95934105": true,
	"physical-building:w95934117": true,
	"physical-building:w95934119": true,
	"physical-building:w95934144": true,
	"physical-building:w96215646": true,
	"physical-building:w95934125": true,
	"physical-building:w764313741": true,
	"physical-building:r19685981": true,
	"physical-building:w96215688": true,
	"physical-building:w96215673": true,
	"physical-building:w96215674": true,
	"physical-building:w96215682": true,
	"physical-building:w96215659": true,
	"physical-building:w96215666": true,
	"physical-building:w96215661": true,
	"physical-building:w96215653": true,
	"physical-building:w96215651": true,
	"physical-building:w96215649": true,
	"physical-building:w96215652": true,
	"physical-building:w96215658": true,
	"physical-building:w96215677": true,
	"physical-building:w96215680": true,
	"physical-building:w96215672": true,
	"physical-building:w96215669": true,
	"physical-building:w95934123": true,
}
const EXPECTED_IDENTITY_CORRECTIONS := {
	"physical-building:w24274434": "08000082",
	"physical-building:w34313540": "08000083",
}
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
	"building:w96215688:wall": "physical-building:w96215688",
	"building:w96215673:wall": "physical-building:w96215673",
	"building:w96215674:wall": "physical-building:w96215674",
	"building:w96215682:wall": "physical-building:w96215682",
	"building:w96215659:wall": "physical-building:w96215659",
	"building:w96215666:wall": "physical-building:w96215666",
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
	"building:w96215688:wall": "independent_exact_current_live_pass",
	"building:w96215673:wall": "independent_exact_current_live_pass",
	"building:w96215674:wall": "independent_exact_current_live_pass",
	"building:w96215682:wall": "independent_exact_current_live_pass",
	"building:w96215659:wall": "independent_exact_current_live_pass",
	"building:w96215666:wall": "independent_exact_current_live_pass",
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
	if not _require(FileAccess.file_exists(REGISTRY_PATH), "Runtime facade registry is missing.") \
	or not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Runtime facade registry hash drifted."):
		_finish()
		return
	var registry := _json(REGISTRY_PATH)
	if not _require(not registry.is_empty(), "Runtime facade registry JSON is invalid.") \
	or not _require(str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/32", "Runtime facade registry schema drifted.") \
	or not _require(_runtime_boundary_is_clean(registry), "Runtime facade registry leaks a source-only path or URL."):
		_finish()
		return
	_validate_counts(registry)
	_validate_units(registry)
	_validate_runtime_adapters(registry)
	if not _failed:
		print("PASS: facade recognition registry is package-safe and fail-closed: 213 physical units / 214 direct wall receivers / 215 source records / 4,971 wall runs / 32/213 independently accepted reference-recognizable units / 9 claim-neutral legacy adapters + 31 exact-current active adapters / 2 separated identity corrections; SHA-256 %s" % EXPECTED_REGISTRY_SHA256)
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
	_require(int(counts.get("active_runtime_adapter_receivers", -1)) == EXPECTED_ACTIVE_ADAPTERS, "Active runtime-adapter count drifted.")
	_require(int(counts.get("runtime_adapter_receivers", -1)) == EXPECTED_RUNTIME_ADAPTERS, "Combined runtime-adapter count drifted.")
	_require(int(counts.get("identity_assertion_summaries", -1)) == EXPECTED_IDENTITY_ASSERTIONS, "Identity-assertion summary count is not 2.")
	_require(int(receiver_claims.get("verified", -1)) == EXPECTED_UNITS and int(receiver_claims.get("failed", -1)) == 0, "Receiver-complete claim aggregate drifted.")
	_require(int(game_claims.get("accepted", -1)) == 0 and int(game_claims.get("not_evaluated", -1)) == EXPECTED_UNITS, "Game-distinctive claims were imported or omitted.")
	_require(int(reference_claims.get("accepted", -1)) == 32 and int(reference_claims.get("not_evaluated", -1)) == EXPECTED_UNITS - 32, "Reference-recognition aggregate is not exactly 32/213.")
	_require(int(as_built_claims.get("claimed", -1)) == 0 and int(as_built_claims.get("limited", -1)) == 0 and int(as_built_claims.get("unclaimed", -1)) == EXPECTED_UNITS, "As-built claims were imported or omitted.")
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted_ids := metric.get("accepted_physical_unit_ids", []) as Array
	var expected_ids := ACCEPTED_REFERENCE_UNITS.keys()
	accepted_ids.sort()
	expected_ids.sort()
	_require(int(metric.get("numerator", -1)) == 32 and int(metric.get("denominator", -1)) == EXPECTED_UNITS and str(metric.get("display", "")) == "32/213", "Physical-unit recognition metric is not exactly 32/213.")
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
	var d1_b201_seen := false
	var d1_b225_seen := false
	var d2_1441_seen := false
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
		if unit_id == "physical-building:w34313545":
			d1_b201_seen = true
			_require(unit_receivers.size() == 1 and str((unit_receivers[0] as Dictionary).get("receiver_key", "")) == "building:w34313545:wall", "D1 B201 no longer owns its exact wall receiver.")
			_require(str((unit_receivers[0] as Dictionary).get("runtime_content_mode", "")) == "active_d1_b201_host_partition_attachment", "D1 B201 wall is not bound to the current host-partition attachment.")
			_require(str(unit.get("runtime_content_mode", "")) == "all_receivers_active_d1_b201_host_partition_attachment", "D1 B201 unit mode no longer preserves host-partition semantics.")
			_require((unit.get("legacy_adapter_ids", []) as Array).is_empty() and (unit.get("active_runtime_adapter_ids", []) as Array).size() == 1, "D1 B201 retains obsolete legacy or missing active adapter membership.")
		if unit_id == "physical-building:w95934119":
			d1_b225_seen = true
			_require(unit_receivers.size() == 1 and str((unit_receivers[0] as Dictionary).get("receiver_key", "")) == "building:w95934119:wall", "D1 B225 no longer owns its exact wall receiver.")
			_require(str((unit_receivers[0] as Dictionary).get("runtime_content_mode", "")) == "active_d1_b225_host_partition_attachment", "D1 B225 wall is not bound to the current host-partition attachment.")
			_require(str(unit.get("runtime_content_mode", "")) == "all_receivers_active_d1_b225_host_partition_attachment", "D1 B225 unit mode no longer preserves host-partition semantics.")
			_require((unit.get("legacy_adapter_ids", []) as Array).is_empty() and (unit.get("active_runtime_adapter_ids", []) as Array).size() == 1, "D1 B225 retains obsolete legacy or missing active adapter membership.")
			if acceptance_records.size() == 1:
				var b225_receipt := acceptance_records[0] as Dictionary
				_require(str(b225_receipt.get("capture_time_recognition_metric", "")) == "7/213" and int(b225_receipt.get("numerator_effect", -1)) == 1, "D1 B225 capture-time metric or one-unit numerator effect drifted.")
				_require(str(b225_receipt.get("evidence_manifest_sha256", "")) == "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc" and str(b225_receipt.get("evidence_tree_sha256", "")) == "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7" and str(b225_receipt.get("review_receipt_sha256", "")) == "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95", "D1 B225 frozen evidence or independent review receipt drifted.")
		if unit_id == "physical-building:w95934105":
			d2_1441_seen = true
			_require(unit_receivers.size() == 1 and str((unit_receivers[0] as Dictionary).get("receiver_key", "")) == "building:w95934105:wall", "D2 1441 no longer owns its exact wall receiver.")
			_require(str((unit_receivers[0] as Dictionary).get("runtime_content_mode", "")) == "active_d2_1441_paired_replacement", "D2 1441 wall is not bound to the paired wall/roof replacement.")
			_require(str(unit.get("runtime_content_mode", "")) == "all_receivers_active_d2_1441_paired_replacement", "D2 1441 unit mode no longer preserves paired replacement semantics.")
			_require((unit.get("legacy_adapter_ids", []) as Array).is_empty() and (unit.get("active_runtime_adapter_ids", []) as Array) == ["active-adapter:d2-1441-live:building:w95934105:wall"], "D2 1441 retains obsolete, duplicate, or missing adapter membership.")
			if acceptance_records.size() == 1:
				var d2_receipt := acceptance_records[0] as Dictionary
				_require(str(d2_receipt.get("capture_time_recognition_metric", "")) == "8/213" and int(d2_receipt.get("numerator_effect", -1)) == 1, "D2 1441 capture-time metric or one-unit numerator effect drifted.")
				_require(str(d2_receipt.get("evidence_manifest_sha256", "")) == "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885" and str(d2_receipt.get("motion_telemetry_manifest_sha256", "")) == "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd" and str(d2_receipt.get("visual_motion_manifest_sha256", "")) == "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad", "D2 1441 static, telemetry, or visual-motion manifest receipt drifted.")
				_require(str(d2_receipt.get("evidence_tree_sha256", "")) == "e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43" and str(d2_receipt.get("package_verification_receipt_sha256", "")) == "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061", "D2 1441 evidence-tree or package receipt drifted.")
				_require(str(d2_receipt.get("mechanical_review_receipt_sha256", "")) == "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884" and str(d2_receipt.get("review_receipt_sha256", "")) == "075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144", "D2 1441 independent mechanical or visual review receipt drifted.")
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
	_require(building_1_main_seen and building_1_tower_seen and building_3_seen and navy_chapel_seen and d1_b201_seen and d1_b225_seen and d2_1441_seen, "Building 1 main/tower, Building 3, Navy Chapel, D1 B201, D1 B225, or D2 1441 is not separately represented.")


func _validate_runtime_adapters(registry: Dictionary) -> void:
	var legacy_adapters := registry.get("legacy_adapters", []) as Array
	var active_adapters := registry.get("active_runtime_adapters", []) as Array
	var adapters := legacy_adapters.duplicate()
	adapters.append_array(active_adapters)
	var receiver_keys := {}
	_require(legacy_adapters.size() == EXPECTED_LEGACY_ADAPTERS, "Runtime legacy adapter array is not nine entries.")
	_require(active_adapters.size() == EXPECTED_ACTIVE_ADAPTERS, "Runtime active adapter array count drifted.")
	_require(adapters.size() == EXPECTED_RUNTIME_ADAPTERS, "Combined runtime adapter array count drifted.")
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
	var current_topology_adapter_ids := []
	for adapter_value: Variant in active_adapters:
		var adapter := adapter_value as Dictionary
		var receiver_key := str(adapter.get("receiver_key", ""))
		_require(ACTIVE_UNIT_BY_RECEIVER.has(receiver_key), "Active adapter targets an unexpected receiver: %s." % receiver_key)
		_require(str(adapter.get("state", "")) == "active_runtime_target_specific_content", "%s is not classified as active runtime content." % receiver_key)
		var unit_id := str(ACTIVE_UNIT_BY_RECEIVER.get(receiver_key, ""))
		var unit := _unit_by_id(registry.get("units", []) as Array, unit_id)
		var direct_receiver := _receiver_by_key(unit.get("direct_receivers", []) as Array, receiver_key)
		var claim_status := unit.get("claim_status", {}) as Dictionary
		var receipts := unit.get("acceptance_records", []) as Array
		var accepted_receipt := receipts.size() == 1 \
			and str((receipts[0] as Dictionary).get("review_kind", "")) == "independent_reference_recognition" \
			and str((receipts[0] as Dictionary).get("status", "")) == "accept"
		_require(not unit.is_empty() and not direct_receiver.is_empty(), "%s does not cross-link to its exact physical recognition unit." % receiver_key)
		_require(str(adapter.get("review_status", "")) == str(ACTIVE_REVIEW_STATUS_BY_RECEIVER.get(receiver_key, "")), "%s review status is not an exact allowed provenance literal." % receiver_key)
		_require(str(adapter.get("review_status_scope", "")) == ACTIVE_REVIEW_STATUS_SCOPE, "%s review-status scope is ambiguous." % receiver_key)
		_require(str(adapter.get("recognition_acceptance_authority", "")) == ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY, "%s recognition authority drifted." % receiver_key)
		_require(str(adapter.get("recognition_acceptance_status", "")) == "accepted" and str(adapter.get("recognition_acceptance_status", "")) == str(claim_status.get("reference_recognizable", "")), "%s recognition acceptance is not derived from its accepted physical unit." % receiver_key)
		_require(accepted_receipt, "%s physical recognition unit lacks one independent acceptance receipt." % receiver_key)
		var contract := adapter.get("active_runtime_contract", {}) as Dictionary
		var authority_behavior_value: Variant = contract.get("behavior_contract", {})
		var authority_behavior := authority_behavior_value as Dictionary if authority_behavior_value is Dictionary else {}
		var authority_geometry := authority_behavior.get("geometry_contract", {}) as Dictionary
		if str(authority_geometry.get("world_topology_scope", "")) == CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE:
			current_topology_adapter_ids.append(str(adapter.get("adapter_id", "")))
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
			_require(str(geometry.get("world_topology_scope", "")) == PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 944 and int(geometry.get("world_surfaces", -1)) == 957 and int(geometry.get("world_triangles", -1)) == 64572 and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466, "Isle House pre-B201 integration world topology parity drifted.")
			_require(bool(ownership.get("low_receiver_is_sole_collision_and_spray_owner", false)) and int(ownership.get("decorative_collision_nodes", -1)) == 0 and int(ownership.get("decorative_navigation_nodes", -1)) == 0 and int(ownership.get("decorative_spray_nodes", -1)) == 0, "Isle House ownership boundary drifted.")
		elif receiver_key == "building:w291189336:wall":
			var behavior := contract.get("behavior_contract", {}) as Dictionary
			var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var ownership := behavior.get("ownership_contract", {}) as Dictionary
			_require(str(adapter.get("attachment_kind", "")) == "active_navy_chapel_187_paired_wall_roof_replacement" and str(adapter.get("runtime_content_mode", "")) == "active_navy_chapel_187_paired_replacement", "Navy Chapel has stale active-content classification.")
			_require((adapter.get("runtime_assets", []) as Array).size() == 9 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "Navy Chapel does not account for its package-safe adapter/config/prototype/material set.")
			_require(str(acceptance.get("independent_live_review_receipt_sha256", "")) == "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9" and int(acceptance.get("numerator_effect", -1)) == 1 and bool(acceptance.get("wall_and_roof_are_one_physical_unit", false)), "Navy Chapel receipt or one-unit rollup drifted.")
			_require(str(geometry.get("world_topology_scope", "")) == PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE and str(geometry.get("visual_geometry_signature", "")) == "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46" and int(geometry.get("visual_triangles", -1)) == 540 and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 944 and int(geometry.get("world_surfaces", -1)) == 957 and int(geometry.get("world_triangles", -1)) == 64572 and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466, "Navy Chapel pre-B201 integration geometry/world parity drifted.")
			_require(str(ownership.get("live_ownership_signature", "")) == "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7" and int(ownership.get("structural_owner_count", -1)) == 2 and int(ownership.get("shape_count", -1)) == 2 and int(ownership.get("spray_owner_count", -1)) == 1 and int(ownership.get("wall_collision_triangles", -1)) == 94 and int(ownership.get("roof_collision_triangles", -1)) == 50 and bool(ownership.get("wall_is_sole_spray_receiver", false)) and ownership.get("roof_is_wall_spray_receiver") == false, "Navy Chapel collision/spray ownership parity drifted.")
		elif receiver_key == "building:w34313545:wall":
			var behavior := contract.get("behavior_contract", {}) as Dictionary
			var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var ownership := behavior.get("ownership_contract", {}) as Dictionary
			var scope := adapter.get("active_receiver_scope", {}) as Dictionary
			var actual_paths := []
			for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
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
			_require(str(adapter.get("attachment_kind", "")) == "active_d1_b201_receiver_host_partition_attachment" and str(adapter.get("runtime_content_mode", "")) == "active_d1_b201_host_partition_attachment", "D1 B201 has stale active-content classification.")
			_require(str(scope.get("coverage", "")) == "whole_direct_wall_receiver" and int(scope.get("run_count", -1)) == 40, "D1 B201 active receiver scope drifted.")
			_require(actual_paths == expected_paths and (adapter.get("runtime_assets", []) as Array).size() == 8 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "D1 B201 exact eight-asset package-safe closure drifted.")
			_require(str(acceptance.get("independent_live_review_receipt_sha256", "")) == "b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772" and str(acceptance.get("evidence_manifest_sha256", "")) == "f169085620a0a9ff0c685e4dfa98442c5c31e4e580f1decdbd80e84b09c74fe3" and int(acceptance.get("numerator_effect", -1)) == 1, "D1 B201 receipt or one-unit rollup drifted.")
			_require(str(geometry.get("decorative_geometry_signature", "")) == "705c5345509f77cd91359f66173fff0e1e132d41ebb9acef3f51ff2c467abb3a" and int(geometry.get("host_triangles", -1)) == 80 and int(geometry.get("eligible_host_triangles", -1)) == 20 and int(geometry.get("protected_host_triangles", -1)) == 60 and int(geometry.get("decorative_triangles", -1)) == 2064, "D1 B201 host partition or decorative geometry parity drifted.")
			_require(str(geometry.get("world_topology_scope", "")) == PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 950 and int(geometry.get("world_surfaces", -1)) == 964 and int(geometry.get("world_triangles", -1)) == 66636 and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466, "D1 B201 pre-B225 integration world topology drifted.")
			_require(bool(ownership.get("host_collision_owner_preserved", false)) and bool(ownership.get("host_spray_owner_preserved", false)) and int(ownership.get("structural_owner_count", -1)) == 1 and int(ownership.get("shape_count", -1)) == 1 and int(ownership.get("spray_owner_count", -1)) == 1 and int(ownership.get("decorative_collision_nodes", -1)) == 0 and int(ownership.get("decorative_navigation_nodes", -1)) == 0 and int(ownership.get("decorative_spray_nodes", -1)) == 0, "D1 B201 collision/navigation/spray ownership parity drifted.")
		elif receiver_key == "building:w95934119:wall":
			var behavior := contract.get("behavior_contract", {}) as Dictionary
			var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
			var geometry := behavior.get("geometry_contract", {}) as Dictionary
			var ownership := behavior.get("ownership_contract", {}) as Dictionary
			var replacement := behavior.get("replacement_contract", {}) as Dictionary
			var scope := adapter.get("active_receiver_scope", {}) as Dictionary
			var actual_paths := []
			for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
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
			_require(str(adapter.get("adapter_id", "")) == "active-adapter:d1-b225-live:building:w95934119:wall" and str(adapter.get("attachment_kind", "")) == "active_d1_b225_receiver_host_partition_attachment" and str(adapter.get("runtime_content_mode", "")) == "active_d1_b225_host_partition_attachment" and str(adapter.get("recognition_acceptance_status", "")) == "accepted", "D1 B225 active authority classification drifted.")
			_require(str(scope.get("coverage", "")) == "whole_direct_wall_receiver" and int(scope.get("run_count", -1)) == 14, "D1 B225 active receiver scope drifted.")
			_require(actual_paths == expected_paths and (adapter.get("runtime_assets", []) as Array).size() == 6 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "D1 B225 exact six-asset package-safe closure drifted.")
			_require(str(contract.get("adapter_sha256", "")) == "4b1defd92a77b23de692437f044dfaa579fa2ee5b3dee77465ec8404f1644ac9" and str(contract.get("config_sha256", "")) == "80b42c33fce84361aa7512f64305f5bff273e8fed95640ca4f9c19d49d55621d" and str(contract.get("dispatch_sha256", "")) == "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a", "D1 B225 config/adapter/dispatch pins drifted.")
			_require(str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w95934119" and str(acceptance.get("capture_time_recognition_metric", "")) == "7/213" and str(acceptance.get("evidence_manifest_sha256", "")) == "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc" and str(acceptance.get("evidence_tree_sha256", "")) == "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7" and str(acceptance.get("independent_live_review_receipt_sha256", "")) == "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95" and int(acceptance.get("numerator_effect", -1)) == 1, "D1 B225 frozen acceptance authority drifted.")
			_require(str(geometry.get("decorative_geometry_signature", "")) == "02bd8542dea7aa13041728a5244ec962fa121972db17ecf55fad03b3139fe418" and int(geometry.get("host_triangles", -1)) == 28 and int(geometry.get("eligible_host_triangles", -1)) == 8 and int(geometry.get("protected_host_triangles", -1)) == 20 and int(geometry.get("decorative_mesh_instances", -1)) == 2 and int(geometry.get("decorative_surfaces", -1)) == 2 and int(geometry.get("decorative_triangles", -1)) == 1080, "D1 B225 host partition or decorative geometry parity drifted.")
			_require(str(geometry.get("world_topology_scope", "")) == PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 952 and int(geometry.get("world_surfaces", -1)) == 967 and int(geometry.get("world_triangles", -1)) == 67716 and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466, "D1 B225 pre-D2 integration world topology drifted.")
			_require(_int_array_matches(replacement.get("eligible_run_indices", []) as Array, [10, 11, 12, 13]) and _int_array_matches(replacement.get("protected_run_indices", []) as Array, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]), "D1 B225 eligible/protected host partition drifted.")
			_require(bool(ownership.get("host_collision_owner_preserved", false)) and bool(ownership.get("host_spray_owner_preserved", false)) and int(ownership.get("structural_owner_count", -1)) == 1 and int(ownership.get("shape_count", -1)) == 1 and int(ownership.get("spray_owner_count", -1)) == 1 and int(ownership.get("decorative_collision_nodes", -1)) == 0 and int(ownership.get("decorative_navigation_nodes", -1)) == 0 and int(ownership.get("decorative_spray_nodes", -1)) == 0, "D1 B225 collision/navigation/spray ownership parity drifted.")
		elif receiver_key == "building:w95934105:wall":
			_validate_d2_1441_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w95934144:wall":
			_validate_d2_1439_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w95934117:wall":
			_validate_d2_1444_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w95934123:wall":
			_validate_d5_1308_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215646:wall":
			_validate_d5_1394_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w95934125:wall":
			_validate_d5_1317_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w764313741:wall":
			_validate_fire_station48_runtime_adapter(adapter, contract)
		elif receiver_key == "building:r19685981:wall":
			_validate_maceo_may_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215688:wall":
			_validate_northern_1240_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215682:wall":
			_validate_northern_1221_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215674:wall":
			_validate_northern_1241_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215673:wall":
			_validate_northern_1232_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215666:wall":
			_validate_northern_1215_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215659:wall":
			_validate_northern_1234_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215651:wall":
			_validate_northern_1202_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215653:wall":
			_validate_northern_1227_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215661:wall":
			_validate_northern_1222_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215658:wall":
			_validate_northern_1239_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215652:wall":
			_validate_northern_1220_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215649:wall":
			_validate_northern_1212_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215680:wall":
			_validate_northern_1219_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215677:wall":
			_validate_northern_1206_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215669:wall":
			_validate_northern_1238_runtime_adapter(adapter, contract)
		elif receiver_key == "building:w96215672:wall":
			_validate_northern_1201_runtime_adapter(adapter, contract)
		else:
			_require(str(adapter.get("attachment_kind", "")) == "active_building_1_hero_replacement" and str(adapter.get("content_classification", "")) == "active_target_specific_hero_replacement", "%s has stale active-content classification." % receiver_key)
			var summary := contract.get("config_summary", {}) as Dictionary
			var target := summary.get("target", {}) as Dictionary
			_require(bool(target.get("tower_remains_separately_reviewable", false)), "%s collapses the tower into the main recognition unit." % receiver_key)
			var assets := adapter.get("runtime_assets", []) as Array
			_require(assets.size() == 11 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "%s does not account for its hero script, two configs, and eight exact-current materials." % receiver_key)
			_require(_has_runtime_asset(assets, "res://game/resources/facades/building_1_public_front_believability.json", "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb"), "%s omits the exact current public-front runtime config." % receiver_key)
			_require(str(contract.get("public_front_config_sha256", "")) == "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb", "%s public-front contract hash drifted." % receiver_key)
	_require(current_topology_adapter_ids == ["active-adapter:northpoint-1240-live:building:w96215688:wall"], "1240 is not the sole current-integration topology authority.")
	var registry_text := JSON.stringify(registry)
	_require(not registry_text.contains("building_1_recognizable_facade") and not registry_text.contains("building_1_recognizability_placements"), "Runtime registry retains obsolete Building 1 facade assets.")
	var world_builder_text := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	_require(not world_builder_text.contains("facade_runtime_registry_loader"), "Generic facade registry loader was wired into world construction.")


func _validate_d2_1439_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	var ownership := behavior.get("ownership_contract", {}) as Dictionary
	var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:d2-1439-live:building:w95934144:wall" and (adapter.get("runtime_assets", []) as Array).size() == 13 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "D2 1439 wall-indexed 13-asset closure drifted.")
	_require(str(contract.get("adapter_sha256", "")) == "d5a4458be7a5c2fb6989f9d8a343d497d2f144eb19c445de6016888e7b3cce5e" and str(contract.get("config_sha256", "")) == "58ba0093d002a3acad06b76876b7333077bb5152827f4a59b0c9b6da132b68d9" and str(contract.get("dispatch_sha256", "")) == "417e4f7269292ed0c5185e85f6b5d12759cdc516ca6be069898145aaab56ab50", "D2 1439 frozen source pins drifted.")
	_require(str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w95934144" and str(acceptance.get("capture_time_recognition_metric", "")) == "9/213" and int(acceptance.get("numerator_effect", -1)) == 1, "D2 1439 one physical unit and capture-time 9/213 boundary drifted.")
	_require(str(geometry.get("world_topology_scope", "")) == PRE_D2_1444_INTEGRATION_WORLD_TOPOLOGY_SCOPE and [int(geometry.get("world_records", -1)), int(geometry.get("world_mesh_instances", -1)), int(geometry.get("world_surfaces", -1)), int(geometry.get("world_triangles", -1)), int(geometry.get("world_static_bodies", -1)), int(geometry.get("world_shapes", -1))] == [735, 968, 983, 71156, 466, 467], "D2 1439 measured current topology drifted.")
	_require(int(ownership.get("eligible_exterior_collision_triangles", -1)) == 62 and int(ownership.get("noneligible_closed_recess_collision_triangles", -1)) == 30 and int(ownership.get("shape_count", -1)) == 3 and not bool(ownership.get("roof_is_wall_spray_receiver", true)) and ownership.get("wall_shape_order", []) == ["eligible_exterior", "noneligible_closed_recess"], "D2 1439 eligible-first closed-recess and separate roof ownership drifted.")


func _validate_d2_1444_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	var ownership := behavior.get("ownership_contract", {}) as Dictionary
	var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:d2-1444-live:building:w95934117:wall" and (adapter.get("runtime_assets", []) as Array).size() == 13 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "D2 1444 wall-indexed 13-asset closure drifted.")
	_require(str(contract.get("adapter_sha256", "")) == "178cc9df2c7add966a95427099b3a9900fde459e5bfc4825211e06c119cc2e32" and str(contract.get("config_sha256", "")) == "472f82f5a3d98b0778aca758ae8277f8b8ba9b4a39875ff54f67781280965135" and str(contract.get("dispatch_sha256", "")) == "cbc3f6d90e5200ea81f1daaccd10442a98b0531c5c6e5358fe825bebef89fcbb", "D2 1444 frozen source pins drifted.")
	_require(str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w95934117" and str(acceptance.get("capture_time_recognition_metric", "")) == "9/213" and int(acceptance.get("numerator_effect", -1)) == 1, "D2 1444 one physical unit and capture-time 9/213 boundary drifted.")
	_require(str(geometry.get("world_topology_scope", "")) == "pre_d5_batch_integration_live_parity" and [int(geometry.get("world_records", -1)), int(geometry.get("world_mesh_instances", -1)), int(geometry.get("world_surfaces", -1)), int(geometry.get("world_triangles", -1)), int(geometry.get("world_static_bodies", -1)), int(geometry.get("world_shapes", -1))] == [735, 977, 992, 71828, 466, 468], "D2 1444 measured current topology drifted.")
	_require(int(ownership.get("eligible_exterior_collision_triangles", -1)) == 64 and int(ownership.get("noneligible_closed_recess_collision_triangles", -1)) == 40 and int(ownership.get("shape_count", -1)) == 3 and not bool(ownership.get("roof_is_wall_spray_receiver", true)) and ownership.get("wall_shape_order", []) == ["eligible_exterior", "noneligible_closed_recess"], "D2 1444 eligible-first closed-recess and separate roof ownership drifted.")


func _validate_d2_1441_runtime_adapter(adapter: Dictionary, runtime_contract: Dictionary) -> void:
	var scope := adapter.get("active_receiver_scope", {}) as Dictionary
	var behavior := runtime_contract.get("behavior_contract", {}) as Dictionary
	var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	var ownership := behavior.get("ownership_contract", {}) as Dictionary
	var replacement := behavior.get("replacement_contract", {}) as Dictionary
	var truth := behavior.get("truth_boundary", {}) as Dictionary
	var assets := adapter.get("runtime_assets", []) as Array
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
		str(adapter.get("adapter_id", "")) == "active-adapter:d2-1441-live:building:w95934105:wall"
		and str(adapter.get("source_key", "")) == "w95934105"
		and str(adapter.get("receiver_key", "")) == "building:w95934105:wall"
		and str(adapter.get("attachment_kind", "")) == "active_d2_1441_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_d2_1441_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(scope.get("run_count", -1)) == 16,
		"D2 1441 exact active paired adapter identity, acceptance, or 16-run scope drifted.",
	)
	_require(actual_paths == expected_paths and assets.size() == 13 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "D2 1441 exact 13-asset package-safe closure drifted.")
	_require(
		str(runtime_contract.get("adapter_sha256", "")) == "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1"
		and str(runtime_contract.get("config_sha256", "")) == "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111"
		and str(runtime_contract.get("dispatch_sha256", "")) == "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a"
		and str(runtime_contract.get("prototype_sha256", "")) == "6c0bf201bbb38a424453f753471cb7cb8060d0323e2386a9fda3bad84acd5933"
		and str(runtime_contract.get("prototype_config_sha256", "")) == "ebb6be74a630ad405030938dc7d27bc6fed46b2d6892a847ee653d374df57f75"
		and str(runtime_contract.get("site_kit_sha256", "")) == "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
		"D2 1441 config/adapter/dispatch/prototype/site-kit pins drifted.",
	)
	_require(
		_has_runtime_asset(assets, "res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd", str(runtime_contract.get("adapter_sha256", "")))
		and _has_runtime_asset(assets, "res://game/resources/facades/d2_1441_chinook_live_replacement.json", str(runtime_contract.get("config_sha256", "")))
		and _has_runtime_asset(assets, "res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd", str(runtime_contract.get("prototype_sha256", "")))
		and _has_runtime_asset(assets, "res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json", str(runtime_contract.get("prototype_config_sha256", "")))
		and _has_runtime_asset(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", str(runtime_contract.get("site_kit_sha256", ""))),
		"D2 1441 runtime closure does not bind all exact executable/config pins.",
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
		"D2 1441 single-record seven-receipt capture-time 8/213 and +1 authority drifted.",
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
		"D2 1441 paired visual/delta/current-world topology drifted.",
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
		"D2 1441 wall/roof/decorative collision, spray, navigation, or landing ownership drifted.",
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
		"D2 1441 mapped/protected paired replacement boundary drifted.",
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
		"D2 1441 capture-time no-credit/inference truth boundary drifted.",
	)


func _receiver_by_key(receivers: Array, receiver_key: String) -> Dictionary:
	for receiver_value: Variant in receivers:
		var receiver := receiver_value as Dictionary
		if str(receiver.get("receiver_key", "")) == receiver_key:
			return receiver
	return {}


func _int_array_matches(values: Array, expected: Array) -> bool:
	if values.size() != expected.size():
		return false
	for index in expected.size():
		if int(values[index]) != int(expected[index]):
			return false
	return true


func _unit_by_id(units: Array, unit_id: String) -> Dictionary:
	for unit_value: Variant in units:
		var unit := unit_value as Dictionary
		if str(unit.get("unit_id", "")) == unit_id:
			return unit
	return {}


func _has_runtime_asset(assets: Array, path: String, sha256: String) -> bool:
	for value: Variant in assets:
		var asset := value as Dictionary
		if str(asset.get("path", "")) == path and str(asset.get("sha256", "")) == sha256:
			return true
	return false


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
	if path in ["res://game/scripts/world/facades/bayside_1226_live_replacement.gd", "res://game/scripts/world/facades/gateview_1397_live_replacement.gd", "res://game/scripts/world/facades/northpoint_1240_live_replacement.gd", "res://game/scripts/world/facades/northpoint_1232_live_replacement.gd", "res://game/scripts/world/facades/northpoint_1241_live_replacement.gd", "res://game/scripts/world/facades/mariner_1221_live_replacement.gd", "res://game/scripts/world/facades/northern_canopy_free_live_replacement.gd", "res://game/scripts/world/facades/mariner_1206_live_replacement.gd", "res://game/scripts/world/facades/mariner_1219_live_replacement.gd", "res://game/scripts/world/facades/mariner_1212_live_replacement.gd", "res://game/scripts/world/facades/bayside_1220_live_replacement.gd", "res://game/scripts/world/facades/northpoint_1239_live_replacement.gd", "res://game/scripts/world/facades/bayside_1222_live_replacement.gd", "res://game/scripts/world/facades/northpoint_1227_live_replacement.gd", "res://game/scripts/world/facades/mariner_1202_live_replacement.gd", "res://game/scripts/world/facades/northpoint_1234_live_replacement.gd", "res://game/scripts/world/facades/bayside_1215_live_replacement.gd", "res://game/scripts/world/facades/northpoint_1238_live_replacement.gd"]:
		var expected_hash: String = "d26993a5443fdf4b30477c9f47e96fdc54fdc1f517c5dbaaeb14d3f8b2120c66" if path == "res://game/scripts/world/facades/bayside_1226_live_replacement.gd" else "a906e841e11ad3c421abe208ef19b4ba3f4fb3e1e2c9ef563d609dd565d5fd77" if path == "res://game/scripts/world/facades/gateview_1397_live_replacement.gd" else "a2c7536488783593e48a5a91641fcc5bf11df490e830beaa61c3d1b7e7cc8b48" if path == "res://game/scripts/world/facades/northpoint_1240_live_replacement.gd" else "1e1cebbd652e2409723c7000398a78aecedf9f4c77624016c5fb9070ffe70c6c" if path == "res://game/scripts/world/facades/northpoint_1241_live_replacement.gd" else "15816708f9b6b8f15ae83f5d5d0ec0823165fbc0a2db51bdaeba442c34004b1e" if path == "res://game/scripts/world/facades/mariner_1221_live_replacement.gd" else "eab24f028a8956a00d415fb058c84a2be84b86f53f3ce357122b48441f9ec27e" if path == "res://game/scripts/world/facades/northpoint_1232_live_replacement.gd" else "6bf227c87c36c2ff02b883bf6224bb35d281f098e76035cc8d64e5ac25bfbbdc" if path.ends_with("/northpoint_1234_live_replacement.gd") else "cc6266cc71e9e0243006af8bb6161f061b981ac313b312fea58c4abd3d607c55" if path.ends_with("/bayside_1215_live_replacement.gd") else "29f17b796ae922d967e87212f7e3ed21fa30db7d9ce4b9c2c7a2ba079e847a70" if path.ends_with("/mariner_1202_live_replacement.gd") else "ace49917dc8935c75124e70f3dc573330a2236a6a82ef948b41b1eeeee451c6e" if path.ends_with("/northpoint_1227_live_replacement.gd") else "a4f6e7242dd4130b3dca67cad165a8a3067129ab2a7455e4e0f0f76ef3c144bf" if path.ends_with("/bayside_1222_live_replacement.gd") else "e397a0879a8beb8eca7e8ec32e80c40652cfb1b5b67a50bf6f52952f4ae44aa5" if path.ends_with("/northpoint_1239_live_replacement.gd") else "1edb75f24c3de6b4c6c780c9bb6b478225925453872e11c76f82fece8a146c38" if path.ends_with("/bayside_1220_live_replacement.gd") else "c0941706e3cee909b260e278a07d846932b805aaeb5e12440463e43678b3513c" if path.ends_with("/mariner_1212_live_replacement.gd") else "c6a0c16cc762d33c62c3f3885d865999be5e65e148f56a66e9da348e6cbfb58a" if path.ends_with("/mariner_1219_live_replacement.gd") else "88e0858a2b9d3559c8d2e766874f93cd44335f89c232e8115ef7c7f97ecc951b" if path.ends_with("/mariner_1206_live_replacement.gd") else "8967229a37be5401962132b846b08f1f527fb27f6aae3cd2d6d97eb70f608b82" if path.ends_with("/northern_canopy_free_live_replacement.gd") else "fef8305341da71b88c1fa90a5ccdd9bba98afc10f999de7208cc6373ff7ba9c3"
		if contents.sha256_text() != expected_hash:
			return false
		for probe_name: String in ["project.binary", "project.godot"]:
			var probe: String = 'FileAccess.file_exists("res' + '://' + probe_name + '")'
			if contents.count(probe) != 1:
				return false
			contents = contents.replace(probe, "true")
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


func _validate_d5_1308_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	var ownership := behavior.get("ownership_contract", {}) as Dictionary
	var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:d5-1308-live:building:w95934123:wall" and (adapter.get("runtime_assets", []) as Array).size() == 7 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "D5 1308 exact wall-indexed runtime assets drifted.")
	_require(str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w95934123" and str(acceptance.get("capture_time_recognition_metric", "")) == "13/213" and int(acceptance.get("numerator_effect", -1)) == 0, "D5 1308 existing-unit quality/capture13 authority drifted.")
	_require(str(acceptance.get("evidence_manifest_sha256", "")) == "7c01ff32b1da4276ec330aee0d034dce4f0cbe8caa510f96d99504084cb314b5", "D5 1308 seven-artifact evidence_manifest_sha256 drifted.")
	_require(str(acceptance.get("motion_telemetry_manifest_sha256", "")) == "f139576c7b45eb76774315745504992f6bd726cd698faab6b88e79f491197960", "D5 1308 seven-artifact motion_telemetry_manifest_sha256 drifted.")
	_require(str(acceptance.get("visual_motion_manifest_sha256", "")) == "f0d21bb4dc14d8a12aba1fc37614e3cced7ff331521dda06a802bfc6fbd69dc9", "D5 1308 seven-artifact visual_motion_manifest_sha256 drifted.")
	_require(str(acceptance.get("package_verification_receipt_sha256", "")) == "c892d30b9c06f280077712c2bbad710eefac67f9fa1dd4b1f92c8f07c0b329dc", "D5 1308 seven-artifact package_verification_receipt_sha256 drifted.")
	_require(str(acceptance.get("evidence_tree_sha256", "")) == "e17f311ea69445d8da9b4029e9d4d93fba19ea2cd2901efa2e2ec1d7dd90556a", "D5 1308 seven-artifact evidence_tree_sha256 drifted.")
	_require(str(acceptance.get("mechanical_review_receipt_sha256", "")) == "9c094ed7a52506404a6763298504b71706b75ade1f44e4cfe2ad3fb6ea81380f", "D5 1308 seven-artifact mechanical_review_receipt_sha256 drifted.")
	_require(str(acceptance.get("review_receipt_sha256", "")) == "87a2af8c5ab11082337265f53ca5fcd3aa9f0dbfdd22f97e7a8968653ad71a06", "D5 1308 seven-artifact review_receipt_sha256 drifted.")
	_require(str(geometry.get("world_topology_scope", "")) == "same_batch_combined_topology_reference" and [int(geometry.get("world_records", -1)), int(geometry.get("world_mesh_instances", -1)), int(geometry.get("world_surfaces", -1)), int(geometry.get("world_triangles", -1)), int(geometry.get("world_static_bodies", -1)), int(geometry.get("world_shapes", -1))] == [735,1006,1021,79913,466,474], "D5 1308 measured combined topology scope drifted.")
	_require(int(ownership.get("shape_count", -1)) == 6 and not bool(ownership.get("roof_is_wall_spray_receiver", true)) and ownership.get("wall_shape_order", []) == ["eligible_exterior", "noneligible_canopy_posts", "noneligible_grade_pads", "noneligible_closed_lower"], "D5 1308 shape/render ownership drifted.")
	_require(int(ownership.get("eligible_exterior_collision_triangles", -1)) == 68, "D5 1308 eligible_exterior_collision_triangles drifted.")
	_require(int(ownership.get("noneligible_canopy_post_collision_triangles", -1)) == 240, "D5 1308 noneligible_canopy_post_collision_triangles drifted.")
	_require(int(ownership.get("noneligible_ground_collision_triangles", -1)) == 96, "D5 1308 noneligible_ground_collision_triangles drifted.")
	_require(int(ownership.get("roof_collision_triangles", -1)) == 1402, "D5 1308 roof_collision_triangles drifted.")


func _validate_d5_1394_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	var ownership := behavior.get("ownership_contract", {}) as Dictionary
	var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:d5-1394-live:building:w96215646:wall" and (adapter.get("runtime_assets", []) as Array).size() == 7 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "D5 1394 exact wall-indexed runtime assets drifted.")
	_require(str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w96215646" and str(acceptance.get("capture_time_recognition_metric", "")) == "13/213" and int(acceptance.get("numerator_effect", -1)) == 0, "D5 1394 existing-unit quality/capture13 authority drifted.")
	_require(str(acceptance.get("evidence_manifest_sha256", "")) == "ec327adb9239a902f40fd7e2ede7afedcd19bf1869b392e9646544721eaec316", "D5 1394 seven-artifact evidence_manifest_sha256 drifted.")
	_require(str(acceptance.get("motion_telemetry_manifest_sha256", "")) == "0ad7ff068f42b8230ba724d9143c9c563130de3c9d40c37837f1ed21f95ecc60", "D5 1394 seven-artifact motion_telemetry_manifest_sha256 drifted.")
	_require(str(acceptance.get("visual_motion_manifest_sha256", "")) == "6a057c2b0236e90d11861499c299b723b35da37ee3590a0a154d0c3390f0b2cb", "D5 1394 seven-artifact visual_motion_manifest_sha256 drifted.")
	_require(str(acceptance.get("package_verification_receipt_sha256", "")) == "9be91b038dc142ac84d3947ed68733c2346aa5756e4ccbb433bf0a173b8ca364", "D5 1394 seven-artifact package_verification_receipt_sha256 drifted.")
	_require(str(acceptance.get("evidence_tree_sha256", "")) == "464224831dfadcc4657fdb3575fc47501190ad41c44163a7dd05885284772689", "D5 1394 seven-artifact evidence_tree_sha256 drifted.")
	_require(str(acceptance.get("mechanical_review_receipt_sha256", "")) == "c2c4ee90347b458e44fda87d900a4a2031b2cf4883c16a0db1ceac0ffeec02cd", "D5 1394 seven-artifact mechanical_review_receipt_sha256 drifted.")
	_require(str(acceptance.get("review_receipt_sha256", "")) == "c7b5079a3a59847b80e201ef8107928381f9370dd74001f2675f0c68de82dbc8", "D5 1394 seven-artifact review_receipt_sha256 drifted.")
	_require(str(geometry.get("world_topology_scope", "")) == "pre_d5_1317_integration_quality_batch_topology" and [int(geometry.get("world_records", -1)), int(geometry.get("world_mesh_instances", -1)), int(geometry.get("world_surfaces", -1)), int(geometry.get("world_triangles", -1)), int(geometry.get("world_static_bodies", -1)), int(geometry.get("world_shapes", -1))] == [735,1006,1021,79913,466,474], "D5 1394 measured combined topology scope drifted.")
	_require(int(ownership.get("shape_count", -1)) == 4 and not bool(ownership.get("roof_is_wall_spray_receiver", true)) and ownership.get("wall_shape_order", []) == ["eligible_exterior", "noneligible_canopy_posts", "noneligible_closed_modules"], "D5 1394 shape/render ownership drifted.")
	_require(int(ownership.get("eligible_exterior_collision_triangles", -1)) == 48, "D5 1394 eligible_exterior_collision_triangles drifted.")
	_require(int(ownership.get("noneligible_canopy_post_collision_triangles", -1)) == 204, "D5 1394 noneligible_canopy_post_collision_triangles drifted.")
	_require(int(ownership.get("noneligible_ground_collision_triangles", -1)) == 2016, "D5 1394 noneligible_ground_collision_triangles drifted.")
	_require(int(ownership.get("roof_collision_triangles", -1)) == 16, "D5 1394 roof_collision_triangles drifted.")

func _validate_d5_1317_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	var ownership := behavior.get("ownership_contract", {}) as Dictionary
	var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:d5-1317-live:building:w95934125:wall" and (adapter.get("runtime_assets", []) as Array).size() == 8 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "D5 1317 exact wall-indexed runtime assets drifted.")
	_require(str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w95934125" and str(acceptance.get("capture_time_recognition_metric", "")) == "13/213" and int(acceptance.get("numerator_effect", -1)) == 1, "D5 1317 new-unit +1/capture13 authority drifted.")
	_require(str(acceptance.get("evidence_manifest_sha256", "")) == "4fcdd7f900dfadb12187f558bf0e545038d8386134ed1e7f9830810be763ddb5", "D5 1317 seven-artifact evidence_manifest_sha256 drifted.")
	_require(str(acceptance.get("motion_telemetry_manifest_sha256", "")) == "a1e3d98ebacaf73c5fb985a2fa2ee4597fe4c2b334cc102c3d3ea460bf361214", "D5 1317 seven-artifact motion_telemetry_manifest_sha256 drifted.")
	_require(str(acceptance.get("visual_motion_manifest_sha256", "")) == "088c0a0df84440cf2ddb35996aabc5d1b1aa5e1fcafe47217cd92dbbca08fc15", "D5 1317 seven-artifact visual_motion_manifest_sha256 drifted.")
	_require(str(acceptance.get("package_verification_receipt_sha256", "")) == "d6041941c9ec59d6a6d8fac4cbb79964fe842cdc135baf5c7a36df3a65a2c98e", "D5 1317 seven-artifact package_verification_receipt_sha256 drifted.")
	_require(str(acceptance.get("evidence_tree_sha256", "")) == "18da75ad3394e86f3129449bbf113efd14d2e845acd767acba995545b3e5f6ee", "D5 1317 seven-artifact evidence_tree_sha256 drifted.")
	_require(str(acceptance.get("mechanical_review_receipt_sha256", "")) == "7cd3ef79e13c19bbb34b601338f86533b9de429d274d35e55e8e6f8fbd8afdce", "D5 1317 seven-artifact mechanical_review_receipt_sha256 drifted.")
	_require(str(acceptance.get("review_receipt_sha256", "")) == "19edda17a50fd957ec09bd9a2ea310b7f82524e717c63467d5198e2e3f9500df", "D5 1317 seven-artifact review_receipt_sha256 drifted.")
	_require(str(geometry.get("world_topology_scope", "")) == "pre_station48_integration_live_parity" and [int(geometry.get("world_records", -1)), int(geometry.get("world_mesh_instances", -1)), int(geometry.get("world_surfaces", -1)), int(geometry.get("world_triangles", -1)), int(geometry.get("world_static_bodies", -1)), int(geometry.get("world_shapes", -1))] == [735,1018,1033,81761,466,477], "D5 1317 measured combined topology scope drifted.")
	_require(int(ownership.get("shape_count", -1)) == 5 and not bool(ownership.get("roof_is_wall_spray_receiver", true)) and ownership.get("wall_shape_order", []) == ["eligible_source_wall", "noneligible_canopies_posts_braces", "noneligible_closed_lower_modules"], "D5 1317 shape/render ownership drifted.")
	_require(int(ownership.get("eligible_exterior_collision_triangles", -1)) == 68, "D5 1317 eligible_exterior_collision_triangles drifted.")
	_require(int(ownership.get("noneligible_canopy_post_collision_triangles", -1)) == 192, "D5 1317 noneligible_canopy_post_collision_triangles drifted.")
	_require(int(ownership.get("noneligible_closed_lower_collision_triangles", -1)) == 648, "D5 1317 noneligible_closed_lower_collision_triangles drifted.")
	_require(int(ownership.get("roof_collision_triangles", -1)) == 130, "D5 1317 roof_collision_triangles drifted.")

func _validate_fire_station48_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	var ownership := behavior.get("ownership_contract", {}) as Dictionary
	var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:fire-station48-live:building:w764313741:wall" and (adapter.get("runtime_assets", []) as Array).size() == 7 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "Station48 exact seven-asset receiver closure.")
	_require(str(acceptance.get("evidence_manifest_sha256", "")) == "f68b77fa5c6e8983288ad9f9ca36a4fd827e716cc1c99877270eeceb547786b6", "Station48 exact evidence_manifest_sha256.")
	_require(str(acceptance.get("motion_telemetry_manifest_sha256", "")) == "4e3a0ea032384bc1381468db84ae15c4ebc1eb75212a9fec20156d165414b028", "Station48 exact motion_telemetry_manifest_sha256.")
	_require(str(acceptance.get("visual_motion_manifest_sha256", "")) == "708692fe592b56c9b18cbf5d9bbc086dadb1c053153d37afbd5c37c6a91c0a3e", "Station48 exact visual_motion_manifest_sha256.")
	_require(str(acceptance.get("package_verification_receipt_sha256", "")) == "502c87a102c90ef446a1e3415b1bb6eca7050d46689c550c18609c3c9dc43b0b", "Station48 exact package_verification_receipt_sha256.")
	_require(str(acceptance.get("evidence_tree_sha256", "")) == "6e8e1a6d8ff3ee12e961d7adaa78cdc72e8aa57dbb607251d5a1361c171eb895", "Station48 exact evidence_tree_sha256.")
	_require(str(acceptance.get("mechanical_review_receipt_sha256", "")) == "fb4802671d8ec92d2cdff091a221fc6fe8f3d1dae6780446aa5604227f7cfed4", "Station48 exact mechanical_review_receipt_sha256.")
	_require(str(acceptance.get("review_receipt_sha256", "")) == "cb06367c7de02d2379c855dfe33915d8bd54b85a33666f0582e949752f9310cf", "Station48 exact review_receipt_sha256.")
	_require(str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w764313741", "Station48 exact accepted_physical_unit_id.")
	_require(str(acceptance.get("capture_time_recognition_metric", "")) == "14/213", "Station48 exact capture_time_recognition_metric.")
	_require(int(acceptance.get("numerator_effect", -1)) == 1, "Station48 exact numerator_effect.")
	_require(bool(acceptance.get("reference_recognizable", false)) == true, "Station48 exact reference_recognizable.")
	_require(bool(acceptance.get("wall_and_roof_are_one_physical_unit", false)) == true, "Station48 exact wall_and_roof_are_one_physical_unit.")
	_require(str(geometry.get("world_topology_scope", "")) == "pre_maceo_may_integration_live_parity" and [int(geometry.get("world_records", -1)), int(geometry.get("world_mesh_instances", -1)), int(geometry.get("world_surfaces", -1)), int(geometry.get("world_triangles", -1)), int(geometry.get("world_static_bodies", -1)), int(geometry.get("world_shapes", -1))] == [735,1023,1038,82789,466,477], "Station48 actual current topology.")
	_require(ownership.get("wall_shape_collision_triangles", []) == [52.0] and ownership.get("roof_shape_collision_triangles", []) == [10.0] and int(ownership.get("shape_count", -1)) == 2 and int(ownership.get("added_collision_triangles", -1)) == 0 and bool(ownership.get("all_additions_render_only", false)) and not bool(ownership.get("roof_is_wall_spray_receiver", true)), "Station48 exact source-only collision and render-only additions.")

func _validate_maceo_may_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:maceo-may-live:building:r19685981:wall" and (adapter.get("runtime_assets", []) as Array).size() == 7 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "Maceo May exact seven-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.maceo-may-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"82543ad09bc51281499280965d9bc949ecc99781d80520801742bd3643404862\",\"motion_telemetry_manifest_sha256\":\"83a8637cd539efa3899b8d97147a82a02d976aa8baed4209824e2724a2ac7e2b\",\"visual_motion_manifest_sha256\":\"3c7c3e933062d4cf3994f47cb48a62c41b7c1cf42fa41693ff82474cec1db86d\",\"package_verification_receipt_sha256\":\"e903e64348aa003ca957b1e1efebc57a516395134f40d56e1ba1c5ebc3ad877f\",\"evidence_tree_sha256\":\"916457b92cee4b002cab5c47b6ecd29a8c8d398a9ad685c05e7bc8f5d9874e0a\",\"mechanical_review_receipt_sha256\":\"749cd826a0ea791b696ab98464e5c19548f14d45734d88111a79376a74dd5c8c\",\"review_receipt_sha256\":\"e08d71c45bfc67e05ab2fd2a8d4e8362ef7692f96d5817d60856a251b473b14e\",\"accepted_physical_unit_id\":\"physical-building:r19685981\",\"capture_time_recognition_metric\":\"14/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"r19685981\",\"wall_object_key\":\"building:r19685981:wall\",\"roof_object_key\":\"building:r19685981:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[8,9,10,11,12,13,14,15,16],\"protected_run_indices\":[0,1,2,3,4,5,6,7,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1},\"geometry_contract\":{\"source_geometry_sha256\":\"4caf46d6c3ebb1ef497fbe8012e5f1fd938a055e11a4132c04ed8e6827da12b3\",\"canonical_wall_record_sha256\":\"c68403647a2a1f39a1957813e44c161882c88911d8f0eae574f7f9806ae07b44\",\"canonical_roof_record_sha256\":\"86a5ea5b74ab4713f75ff1c6c35cf5132b70c7e33c228f988983c6c7303139cc\",\"source_chunk_sha256\":\"b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":11,\"visual_surfaces\":11,\"visual_triangles\":16436,\"world_records\":735,\"world_mesh_instances\":1032,\"world_surfaces\":1047,\"world_triangles\":99129,\"world_static_bodies\":466,\"world_shapes\":478,\"world_topology_scope\":\"pre_northern_batch_integration_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":2,\"shape_count\":3,\"spray_owner_count\":1,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":true,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"noneligible_entrance_columns\"],\"wall_shape_collision_triangles\":[80,320],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"roof_shape_collision_triangles\":[16],\"eligible_exterior_collision_triangles\":80,\"wall_collision_triangles\":400,\"roof_collision_triangles\":16,\"added_collision_triangles\":320,\"all_additions_render_only\":false,\"visual_ground_triangles\":0,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"roof_support_setup_is_separate\":true,\"spray_input_event_dispatch_claimed\":false}}"), "Maceo May exact source/ownership/acceptance and current-world contract in consumed JSON types.")

func _validate_northern_1201_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:northern-canopy-free-live:building:w96215672:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1201 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1201-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"fc250debbc032d160e3de5e3e0148f13934a7e3bb17cc882a19f4d5b336fab95\",\"motion_telemetry_manifest_sha256\":\"5a5de738ac8e8ed4490d4c83d63a739d5cdb9598ce66021984579dac1bf6e0c4\",\"visual_motion_manifest_sha256\":\"c0fcacf741e513402d0b04aa35c7d5927b4205ebb80c85890a62bd2b5456c77d\",\"package_verification_receipt_sha256\":\"21be51860e8e35dcdf76df4753d22155cbca013f134250b365764e873b8eac86\",\"evidence_tree_sha256\":\"df08d70aa4307e2b7689e6c8e3ff0ad31005806b14c2420251456ddb4c60db92\",\"mechanical_review_receipt_sha256\":\"f449c7863040df9873f5bcd268e0eac506a9c26d6e0613881e1b294e9355bb1f\",\"review_receipt_sha256\":\"11f87bb5defc8432d5ba53e8e2eb586f631cd81db920f5fa85dc61cc34261589\",\"accepted_physical_unit_id\":\"physical-building:w96215672\",\"capture_time_recognition_metric\":\"15/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215672\",\"wall_object_key\":\"building:w96215672:wall\",\"roof_object_key\":\"building:w96215672:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[11,12,14,15,17,18],\"protected_run_indices\":[0,1,2,3,4,5,6,7,8,9,10,13,16,19],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":11,\"visual_surfaces\":11,\"visual_triangles\":4950,\"wall_native_counts\":[10,10,4940,2,8],\"roof_native_counts\":[1,1,10,1,1],\"world_records\":735,\"world_mesh_instances\":1050,\"world_surfaces\":1065,\"world_triangles\":108921,\"world_static_bodies\":468,\"world_shapes\":492,\"world_topology_scope\":\"shared_northern_1201_1238_candidate_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":3,\"shape_count\":9,\"spray_owner_count\":1,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":true,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"MaroonClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":false,\"station_held_claimed\":true}}"), "1201 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1238_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:northpoint-1238-live:building:w96215669:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1238 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1238-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"5eb7648cb03fa1ae73c9733c31456539d39c40a462219be43d4a92ecf7d0ce62\",\"motion_telemetry_manifest_sha256\":\"fb3f03daae24bb385cbf6e86ee665a2752017ee9c5c32f54c6e21d00dbc7faf3\",\"visual_motion_manifest_sha256\":\"35edd4f41d0cf9009aa59f66b0345992a93bb08ecd1eda8b61086b6eb5dc09db\",\"package_verification_receipt_sha256\":\"5b6b2455b8068568e2b877b9f155982af76e4cc81f7be3341e9ec663c7c260de\",\"evidence_tree_sha256\":\"a2e2b8aade40eebd01d900728e65c5cabd2cb1f43465399db2ed90329d49a741\",\"mechanical_review_receipt_sha256\":\"6e5961faa00944e793c213e444a96732494a6fe15e1799f06636bdd1dd7ad276\",\"review_receipt_sha256\":\"805f12798185ad8504cfac0742a27bdcb83c9da79b9aa9a192ba84081117fbab\",\"accepted_physical_unit_id\":\"physical-building:w96215669\",\"capture_time_recognition_metric\":\"16/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215669\",\"wall_object_key\":\"building:w96215669:wall\",\"roof_object_key\":\"building:w96215669:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[8,9,10,11,13,14,15,17,18,19,20,21],\"protected_run_indices\":[0,1,2,3,4,5,6,7,12,16,22,23],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":11,\"visual_surfaces\":11,\"visual_triangles\":4956,\"wall_native_counts\":[10,10,4940,2,8],\"roof_native_counts\":[1,1,16,1,1],\"world_records\":735,\"world_mesh_instances\":1050,\"world_surfaces\":1065,\"world_triangles\":108921,\"world_static_bodies\":468,\"world_shapes\":492,\"world_topology_scope\":\"pre_mariner_batch_integration_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":3,\"shape_count\":9,\"spray_owner_count\":1,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":true,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"DarkBlueClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":true,\"station_held_claimed\":false}}"), "1238 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1206_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:mariner-1206-live:building:w96215677:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1206 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1206-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"2ef58e0ef4ab39375107bf4d5354b83399eceda0bc36599b7bbb5e98bb79e6b9\",\"motion_telemetry_manifest_sha256\":\"bd5aacf373d887cddf2c25ed0788ab0286faa0c9daa7cc0e9e03a81ad744bd0e\",\"visual_motion_manifest_sha256\":\"6bee171a27e3a10b3f1927f332a678ec0826e982faa6085e71db525bcdb30096\",\"package_verification_receipt_sha256\":\"03f2cf746dc931dd816f28f337b12ae9f11d7cb5ef3c3087601a46bb9df427c7\",\"evidence_tree_sha256\":\"70f69ef17176b2810b073f4304fd17f6bc7143a70ac031d1a20922996422661c\",\"mechanical_review_receipt_sha256\":\"c806dc1fd6f146f8573e83b3fd8ac8523d87fba1d57e8f5e9d29a066b481f3bd\",\"review_receipt_sha256\":\"b3549c8b8616163a06c8fa2209562bda58ad9ce03ad3ae68751c9ca256b9e09a\",\"accepted_physical_unit_id\":\"physical-building:w96215677\",\"capture_time_recognition_metric\":\"16/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215677\",\"wall_object_key\":\"building:w96215677:wall\",\"roof_object_key\":\"building:w96215677:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[11,12,13,15,16,17,18,19,21,22,23],\"protected_run_indices\":[0,1,2,3,4,5,6,7,8,9,10,14,20,24,25],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":14,\"visual_surfaces\":14,\"visual_triangles\":5132,\"wall_native_counts\":[12,12,5068,2,8],\"roof_native_counts\":[2,2,64,2,2],\"world_records\":735,\"world_mesh_instances\":1074,\"world_surfaces\":1089,\"world_triangles\":119049,\"world_static_bodies\":472,\"world_shapes\":508,\"world_topology_scope\":\"shared_mariner_1206_1219_candidate_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":10,\"spray_owner_count\":1,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":true,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"GreenClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\",\"ObservedPublicRoof\"],\"added_public_roof_triangles\":48,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":false,\"station_held_claimed\":true}}"), "1206 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1219_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:mariner-1219-live:building:w96215680:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1219 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1219-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"892c34c422283ba7eadd3b5a8d005f34b8736e4b359ffc67ba7194a6c4fc110d\",\"motion_telemetry_manifest_sha256\":\"98fe533ab07e2ff5f098094ad68e2b32b20712e13de75881e679eb84fb107c0f\",\"visual_motion_manifest_sha256\":\"754b234c8806726b70400dcd759abbed3a309fad42be12669b2cf877e6e5b415\",\"package_verification_receipt_sha256\":\"4c2e64ec36a96058c8d48a7cb5f5e9c29c0e1154ff2c2db179071cc8f7553e62\",\"evidence_tree_sha256\":\"bd06a1a34a11937410f82ad5d6903de68e8d0a1660b5a9b2d8815afeee990ea6\",\"mechanical_review_receipt_sha256\":\"03003e86b6fb4b7fb28099876e6a788e9c8596bd14f25a794d8a1adce6fd4ecd\",\"review_receipt_sha256\":\"f58284bed7ac7fce861a282a344bac1cdb12d6b69286d0cfbde3936f9022139b\",\"accepted_physical_unit_id\":\"physical-building:w96215680\",\"capture_time_recognition_metric\":\"16/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215680\",\"wall_object_key\":\"building:w96215680:wall\",\"roof_object_key\":\"building:w96215680:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13],\"protected_run_indices\":[14,15,16,17,18,19,20,21,22,23,24,25],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":14,\"visual_surfaces\":14,\"visual_triangles\":5132,\"wall_native_counts\":[12,12,5068,2,8],\"roof_native_counts\":[2,2,64,2,2],\"world_records\":735,\"world_mesh_instances\":1074,\"world_surfaces\":1089,\"world_triangles\":119049,\"world_static_bodies\":472,\"world_shapes\":508,\"world_topology_scope\":\"pre_northern_three_unit_integration_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":10,\"spray_owner_count\":1,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":true,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"DarkBlueClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\",\"ObservedPublicRoof\"],\"added_public_roof_triangles\":48,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":false,\"station_held_claimed\":true}}"), "1219 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1212_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:mariner-1212-live:building:w96215649:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1212 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1212-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"e639c2fe4ca2beebdd067a8d804d231ba4e4a9e55e4d85699496533479267de2\",\"motion_telemetry_manifest_sha256\":\"e78ac76b320df4869bc882a52e5e37ad56a863f5e99734d9b45e2d84764a6424\",\"visual_motion_manifest_sha256\":\"e094b27c9dc69797035270a9acfedcb4db9832338f4915178e101f05621b49af\",\"package_verification_receipt_sha256\":\"276b71133a8ae9c1f0fd8caecdbd0365f16c3ca4655d49e99149bbaec61b0ae0\",\"evidence_tree_sha256\":\"0c46621cf3d43660a7e7d8168dcdf0be5556d96b5ff1a63b0715295311565d35\",\"mechanical_review_receipt_sha256\":\"6f67a10d85551c5e4226ff47edcd15a15ce25f3a179ffa0e3670d3c0981be3fb\",\"review_receipt_sha256\":\"bbc33d45ea0708df973adc24897b27ceaa052117c4f002546df64b2fdb30ef3d\",\"accepted_physical_unit_id\":\"physical-building:w96215649\",\"capture_time_recognition_metric\":\"18/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215649\",\"wall_object_key\":\"building:w96215649:wall\",\"roof_object_key\":\"building:w96215649:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[14,15,16,17,19,20,21,22,24,25,26,27],\"protected_run_indices\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,18,23],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":14,\"visual_surfaces\":14,\"visual_triangles\":5140,\"wall_native_counts\":[12,12,5076,2,8],\"roof_native_counts\":[2,2,64,2,2],\"world_records\":735,\"world_mesh_instances\":1111,\"world_surfaces\":1126,\"world_triangles\":138057,\"world_static_bodies\":478,\"world_shapes\":533,\"world_topology_scope\":\"shared_northern_1212_1220_1239_candidate_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":10,\"spray_owner_count\":1,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":true,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"DarkReddishClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\",\"ObservedPublicRoof\"],\"added_public_roof_triangles\":48,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":true,\"station_held_claimed\":false,\"prior_clipped_tag_failure_retained\":false,\"scoped_hairline_observation_retained\":false,\"native_support_qualification_mm\":4}}"), "1212 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1220_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:bayside-1220-live:building:w96215652:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1220 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1220-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"410d90ee3599491993fddcc0ed8accea3de05bb4e905be9076078629b36f7835\",\"motion_telemetry_manifest_sha256\":\"94994da3f3db23d5bc81d4892e7ddcbafe91228aa891890198b9afee0339e961\",\"visual_motion_manifest_sha256\":\"db006b21c253ea7dbcc937ff6ba5bf7805894f9b00b8ef6164396ee9f6b3af23\",\"package_verification_receipt_sha256\":\"dbef975d3b3afedac4694ea49c57f4e98e50a41f67ed2a61621dae3cc0c12176\",\"evidence_tree_sha256\":\"1d2e5d2682e0b72c9c81b5962680e11c9cdba200d0ab13b11db1c6dac54f1aef\",\"mechanical_review_receipt_sha256\":\"923517f30c75e83af49c039111fdac548d8a20c0486cdf202863e04cca41c3ef\",\"review_receipt_sha256\":\"ca45fe7f855fb98ecadecddf7a04e8b9e13f73355bed128cfc4c8ef83a13fc1c\",\"accepted_physical_unit_id\":\"physical-building:w96215652\",\"capture_time_recognition_metric\":\"18/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215652\",\"wall_object_key\":\"building:w96215652:wall\",\"roof_object_key\":\"building:w96215652:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[0,1,3,4,5,6,7,8,10,11],\"protected_run_indices\":[2,9,12,13,14,15,16,17,18,19,20,21,22,23,24,25],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":14,\"visual_surfaces\":14,\"visual_triangles\":7118,\"wall_native_counts\":[12,12,7040,2,8],\"roof_native_counts\":[2,2,78,2,2],\"world_records\":735,\"world_mesh_instances\":1111,\"world_surfaces\":1126,\"world_triangles\":138057,\"world_static_bodies\":478,\"world_shapes\":533,\"world_topology_scope\":\"shared_northern_1212_1220_1239_candidate_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":10,\"spray_owner_count\":1,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":true,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"DarkBlueClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\",\"ObservedPublicRoof\"],\"added_public_roof_triangles\":64,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":false,\"station_held_claimed\":false,\"prior_clipped_tag_failure_retained\":true,\"scoped_hairline_observation_retained\":false,\"native_support_qualification_mm\":4}}"), "1220 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1239_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:northpoint-1239-live:building:w96215658:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1239 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1239-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"640768775dc2090c5742eb1b8468f0a9992086fbe06cca8ae8f5982309b20ee6\",\"motion_telemetry_manifest_sha256\":\"be716635b72e105c8440c51836735e149360f20eda1fdc95b9a0bfd83f39a6e2\",\"visual_motion_manifest_sha256\":\"47f2d83b04b14b988f9b72c22b8384120201eba933a0a9fd7ca1dd7163eda22c\",\"package_verification_receipt_sha256\":\"2e57bb89f4e646abc95a7db1a7cea82100c058121ad6755ff08edd1fd6403be2\",\"evidence_tree_sha256\":\"7da899b63a2f906a643ac3eeb3a92a793fa3b502e9fa60f395b58fe60139d3e0\",\"mechanical_review_receipt_sha256\":\"d45db6575672f8c713ce96ec41d577d507722a57c14417657f7c2cc564f70f81\",\"review_receipt_sha256\":\"f46366f21b1cc5ed5fb2a230fd35cdc144d02b24833292b9c1ad617f58191c55\",\"accepted_physical_unit_id\":\"physical-building:w96215658\",\"capture_time_recognition_metric\":\"18/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215658\",\"wall_object_key\":\"building:w96215658:wall\",\"roof_object_key\":\"building:w96215658:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,17,18],\"protected_run_indices\":[9,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":15,\"visual_surfaces\":15,\"visual_triangles\":6978,\"wall_native_counts\":[13,13,6892,2,9],\"roof_native_counts\":[2,2,86,2,2],\"world_records\":735,\"world_mesh_instances\":1111,\"world_surfaces\":1126,\"world_triangles\":138057,\"world_static_bodies\":478,\"world_shapes\":533,\"world_topology_scope\":\"pre_northern_1222_1227_1202_integration_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":11,\"spray_owner_count\":1,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":true,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"OchreClosedDoors\",\"MutedRoseClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\",\"ObservedPublicRoof\"],\"added_public_roof_triangles\":64,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":false,\"station_held_claimed\":false,\"prior_clipped_tag_failure_retained\":false,\"scoped_hairline_observation_retained\":true,\"native_support_qualification_mm\":4}}"), "1239 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1222_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:bayside-1222-live:building:w96215661:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1222 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1222-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"c9bdee01510d7e0c2f43be4c454b154437009583b2c59c15ba211f07ee16f259\",\"motion_telemetry_manifest_sha256\":\"ac2950c05d8472b5a8edb0ce2f7b4437159d6af963145dfd142ec5bc59019b98\",\"visual_motion_manifest_sha256\":\"0976e8393145f40ce9e07c861bdc1a032f15b0cf70e6c984244318e2adfb92d3\",\"package_verification_receipt_sha256\":\"a6ea228918898454c56fd5aebe1affbd94d0bc7c1878c966c14fc704409e028b\",\"evidence_tree_sha256\":\"4870b6e92d8d9d42c7107a27f38af1f115f39cd934e920d297363c018d3d2822\",\"mechanical_review_receipt_sha256\":\"ec1e740bd93a8325094811bf634d90d43c672574a002a90c96a1a454662996cf\",\"review_receipt_sha256\":\"20a5a14b31c9918f7e9e4c3884c1ca3deef55af1ccd5720c4c9d581710c42f76\",\"accepted_physical_unit_id\":\"physical-building:w96215661\",\"capture_time_recognition_metric\":\"23/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215661\",\"wall_object_key\":\"building:w96215661:wall\",\"roof_object_key\":\"building:w96215661:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[10,11,12,13,14,15,16,19],\"protected_run_indices\":[0,1,2,3,4,5,6,7,8,9,17,18],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":16,\"visual_surfaces\":16,\"visual_triangles\":5346,\"wall_native_counts\":[15,15,5336,3,11],\"roof_native_counts\":[1,1,10,1,1],\"world_records\":735,\"world_mesh_instances\":1159,\"world_surfaces\":1174,\"world_triangles\":153873,\"world_static_bodies\":484,\"world_shapes\":569,\"world_topology_scope\":\"shared_northern_1222_1227_1202_candidate_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":12,\"spray_owner_count\":2,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":false,\"original_wall_and_projected_front_are_receivers\":true,\"projected_receiver_runs\":[10,11,12,15,16,19],\"projected_receiver_triangles\":6,\"projected_receiver_shape_order\":[\"ProjectedUpperSiding\"],\"projected_receiver_physics_layer\":5,\"projected_receiver_cull_mask\":2,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"ProjectedUpperClosures\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"BlueGrayClosedDoors\",\"PaleClosedDoor\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"added_public_roof_triangles\":0,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":false,\"original_visual_hold_retained\":true,\"metadata_only_observer_retained\":true,\"unexecuted_central_carport_proposal_retained\":false,\"motion_route_scope\":\"one_door_one_screen_finite_routes\",\"station_held_claimed\":false,\"prior_clipped_tag_failure_retained\":false,\"scoped_hairline_observation_retained\":false,\"native_support_qualification_mm\":4}}"), "1222 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1227_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:northpoint-1227-live:building:w96215653:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1227 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1227-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"f240c0a442a66cdb5e20fffa4883e2b9098ce681d0fdefa3c30e846e376d517b\",\"motion_telemetry_manifest_sha256\":\"c45ad15c677f1413d106695f8a1c6e339c0b6da6f4fb67eea0d9b6ae53b64018\",\"visual_motion_manifest_sha256\":\"a28bf431f24e58cc147b3adc6df9983784f68d6f0335c61bea3bda7d02e0cfa8\",\"package_verification_receipt_sha256\":\"802e3287f84f0363a688d35454e88aebef7d34b93db88b88d16785311ec3d7d4\",\"evidence_tree_sha256\":\"34e252f76805cd5e152fd58056f95852ba5c4ebfdc2e73ceeb20f1410c74eadb\",\"mechanical_review_receipt_sha256\":\"45cf53232bcb34f4bf43b2370a7ce0e84ade628dc23e9aa7a8439f70eb102c03\",\"review_receipt_sha256\":\"8957bff439a37e22880af8b0df5c6641e348bb19e13207bd65ac8e94cb1484ad\",\"accepted_physical_unit_id\":\"physical-building:w96215653\",\"capture_time_recognition_metric\":\"23/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215653\",\"wall_object_key\":\"building:w96215653:wall\",\"roof_object_key\":\"building:w96215653:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[4,5,6,7,8,9,10,11,13,14,15,16,17],\"protected_run_indices\":[0,1,2,3,12,18,19,20,21],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"932c924b845a382d746e7900710c0c4e8b7603ab205cb07173ad51933c1341b4\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":20,\"visual_surfaces\":20,\"visual_triangles\":5544,\"wall_native_counts\":[19,19,5528,3,15],\"roof_native_counts\":[1,1,16,1,1],\"world_records\":735,\"world_mesh_instances\":1159,\"world_surfaces\":1174,\"world_triangles\":153873,\"world_static_bodies\":484,\"world_shapes\":569,\"world_topology_scope\":\"shared_northern_1222_1227_1202_candidate_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":16,\"spray_owner_count\":2,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":false,\"original_wall_and_projected_front_are_receivers\":true,\"projected_receiver_runs\":[4,5,6,7,9,10,11,13,14,15,16],\"projected_receiver_triangles\":6,\"projected_receiver_shape_order\":[\"ProjectedUpperSiding\"],\"projected_receiver_physics_layer\":5,\"projected_receiver_cull_mask\":2,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"ObservedPublicRoof\",\"NorthGableSiding\",\"CarportRoof\",\"CarportPosts\",\"ProjectedUpperClosures\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"BlueGrayClosedDoors\",\"PaleClosedDoor\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"added_public_roof_triangles\":92,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":false,\"original_visual_hold_retained\":true,\"metadata_only_observer_retained\":false,\"unexecuted_central_carport_proposal_retained\":false,\"motion_route_scope\":\"one_door_one_screen_finite_routes\",\"station_held_claimed\":false,\"prior_clipped_tag_failure_retained\":false,\"scoped_hairline_observation_retained\":true,\"native_support_qualification_mm\":4}}"), "1227 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1202_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:mariner-1202-live:building:w96215651:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1202 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1202-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"497ce96296ada0265a26c4d24215db320b278cff8883be00b5d637a94d2cfd64\",\"motion_telemetry_manifest_sha256\":\"8205cf8904929d56d9e90842922a6be37cf64869f283c60aac666e42e571c236\",\"visual_motion_manifest_sha256\":\"4de165e49df045101b1fd7156f0f7595c0026617db255ab3c23412b1a4424081\",\"package_verification_receipt_sha256\":\"1da322cc863b923b4befee6eac8f3876c1fa0360a1848527c88cba774c935769\",\"evidence_tree_sha256\":\"3c30e9c73026a885f2ee2b3941b28e7ed6be799571c58fa733d2e209adfad7fe\",\"mechanical_review_receipt_sha256\":\"669f108baf4c343f766da111c808232e6b4b611d13cf919526372e54f8642d34\",\"review_receipt_sha256\":\"6a7813fc1a94f816bd01f55f6901a61f7d421b67e085663b6e51ad865408754e\",\"accepted_physical_unit_id\":\"physical-building:w96215651\",\"capture_time_recognition_metric\":\"23/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215651\",\"wall_object_key\":\"building:w96215651:wall\",\"roof_object_key\":\"building:w96215651:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[10,11,12,13,14,15,16,17,18,19,21],\"protected_run_indices\":[0,1,2,3,4,5,6,7,8,9,20,22,23,24,25],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":18,\"visual_surfaces\":18,\"visual_triangles\":5104,\"wall_native_counts\":[17,17,5088,3,13],\"roof_native_counts\":[1,1,16,1,1],\"world_records\":735,\"world_mesh_instances\":1159,\"world_surfaces\":1174,\"world_triangles\":153873,\"world_static_bodies\":484,\"world_shapes\":569,\"world_topology_scope\":\"pre_northern_1234_1215_integration_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":14,\"spray_owner_count\":2,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":false,\"original_wall_and_projected_front_are_receivers\":true,\"projected_receiver_runs\":[10,11,12,13,14,16,17,18,19,21],\"projected_receiver_triangles\":6,\"projected_receiver_shape_order\":[\"ProjectedUpperSiding\"],\"projected_receiver_physics_layer\":5,\"projected_receiver_cull_mask\":2,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"ObservedPublicRoof\",\"CarportRoof\",\"CarportPosts\",\"ProjectedUpperClosures\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"BlueGrayClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"added_public_roof_triangles\":108,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":false,\"original_visual_hold_retained\":true,\"metadata_only_observer_retained\":false,\"unexecuted_central_carport_proposal_retained\":true,\"motion_route_scope\":\"uncovered_run21\",\"station_held_claimed\":false,\"prior_clipped_tag_failure_retained\":false,\"scoped_hairline_observation_retained\":false,\"native_support_qualification_mm\":4}}"), "1202 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1234_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:northpoint-1234-live:building:w96215659:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1234 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1234-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"29b8208ce1d2061557f5e440b73b29f19d9832f6341ce55d6a00f16d71abdb75\",\"motion_telemetry_manifest_sha256\":\"d5aa947c9f8ccd189bdbfc1fb93089b3423ff39dc082da017b5df46bdabe7ce0\",\"visual_motion_manifest_sha256\":\"9ac0894c8d7f52729f25294d24b666f97a9a8ebca91a4ed7892e766c99a8dae9\",\"package_verification_receipt_sha256\":\"ee10c9345a74c96e2c85b919679405e8d3ec08a296994895ec357dafd2d3fde1\",\"evidence_tree_sha256\":\"f8941af510bc00e6e14ea5125f06b7503514b674449e84a543ffdc1765f64852\",\"mechanical_review_receipt_sha256\":\"48995f50883a6ff1d36af054f545dd0cd7ff9739e68749d5efcce34c119701d2\",\"review_receipt_sha256\":\"607c60defc1825ff28afa0dd591d50e42669a140496ea06afaa14699209e1ef4\",\"accepted_physical_unit_id\":\"physical-building:w96215659\",\"capture_time_recognition_metric\":\"23/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215659\",\"wall_object_key\":\"building:w96215659:wall\",\"roof_object_key\":\"building:w96215659:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[0,1,2,3,4,17,18,19,20,22,23,24,25],\"protected_run_indices\":[5,6,7,8,9,10,11,12,13,14,15,16,21],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true,\"continuity_run_indices\":[0],\"partial_run_20_observed_fraction\":0.3293396850039768,\"partial_run_20_hidden_tail_protected\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"932c924b845a382d746e7900710c0c4e8b7603ab205cb07173ad51933c1341b4\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":19,\"visual_surfaces\":19,\"visual_triangles\":5500,\"wall_native_counts\":[18,18,5484,3,14],\"roof_native_counts\":[1,1,16,1,1],\"world_records\":735,\"world_mesh_instances\":1192,\"world_surfaces\":1207,\"world_triangles\":164001,\"world_static_bodies\":488,\"world_shapes\":594,\"world_topology_scope\":\"shared_northern_1234_1215_candidate_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":15,\"spray_owner_count\":2,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":false,\"original_wall_and_projected_front_are_receivers\":true,\"projected_receiver_runs\":[1,2,3,4,17,18,19,20,22,23,24,25],\"projected_receiver_triangles\":6,\"projected_receiver_shape_order\":[\"ProjectedUpperSiding\"],\"projected_receiver_physics_layer\":5,\"projected_receiver_cull_mask\":2,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"ObservedPublicRoof\",\"CarportRoof\",\"CarportPosts\",\"ProjectedUpperClosures\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"BlueGrayClosedDoors\",\"PlumClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"added_public_roof_triangles\":100,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":false,\"original_visual_hold_retained\":true,\"metadata_only_observer_retained\":false,\"unexecuted_central_carport_proposal_retained\":false,\"motion_route_scope\":\"finite_observed_entry_routes_uncovered_run2\",\"station_held_claimed\":false,\"prior_clipped_tag_failure_retained\":false,\"scoped_hairline_observation_retained\":false,\"native_support_qualification_mm\":4,\"original_failed_mechanics_attempts_retained\":false}}"), "1234 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1215_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:bayside-1215-live:building:w96215666:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1215 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1215-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"685725ca0d2454610a5e304dc5fef6c968fc35cfb98819b0a5a88c64dbfdf084\",\"motion_telemetry_manifest_sha256\":\"7ed10c2427be78afaa26e950c76cb54ccbec6e73d1a4bc3781b7fb1b9e5d9737\",\"visual_motion_manifest_sha256\":\"d25f30eff4d7d0fd4f7c0de034c9f2f88e34f93ce0f7b35e8de7e1c5c9f76462\",\"package_verification_receipt_sha256\":\"191674762a5d82a363698fb5155dc659cba5cc06f20294b26efd1a8789af8a7e\",\"evidence_tree_sha256\":\"7e192e071997d82a527192e787ae7290f5ef4c18c2417afe57348f0da49e35fe\",\"mechanical_review_receipt_sha256\":\"b211c1ad80d9c864d47dc9933985d661af01d25b6bc0d0d211d59bf8edd58feb\",\"review_receipt_sha256\":\"5c6678ebd09028ee5f17c7ada899aaa93aff0baf8bc6dea05f9606638b546b23\",\"accepted_physical_unit_id\":\"physical-building:w96215666\",\"capture_time_recognition_metric\":\"23/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215666\",\"wall_object_key\":\"building:w96215666:wall\",\"roof_object_key\":\"building:w96215666:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[0,1,2,3,4,5,19],\"protected_run_indices\":[6,7,8,9,10,11,12,13,14,15,16,17,18],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true,\"continuity_run_indices\":[0,2],\"partial_run_ownership\":{\"5\":{\"skin_fraction_interval\":[0.0,0.5],\"unestablished_outer_half_protected\":true},\"19\":{\"skin_fraction_interval\":[0.15,1.0],\"cropped_outer_endpoint_protected\":true}}},\"geometry_contract\":{\"source_chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":18,\"visual_surfaces\":18,\"visual_triangles\":4746,\"wall_native_counts\":[17,17,4736,3,13],\"roof_native_counts\":[1,1,10,1,1],\"world_records\":735,\"world_mesh_instances\":1192,\"world_surfaces\":1207,\"world_triangles\":164001,\"world_static_bodies\":488,\"world_shapes\":594,\"world_topology_scope\":\"pre_northern_1232_1241_1221_integration_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":14,\"spray_owner_count\":2,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":false,\"original_wall_and_projected_front_are_receivers\":true,\"projected_receiver_runs\":[1,3,4,5,19],\"projected_receiver_triangles\":6,\"projected_receiver_shape_order\":[\"ProjectedUpperSiding\"],\"projected_receiver_physics_layer\":5,\"projected_receiver_cull_mask\":2,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"ObservedPublicRoof\",\"CarportRoof\",\"CarportPosts\",\"ProjectedUpperClosures\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"BlueGrayClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"added_public_roof_triangles\":100,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"raw_door_station_failure_retained\":false,\"original_visual_hold_retained\":true,\"metadata_only_observer_retained\":false,\"unexecuted_central_carport_proposal_retained\":false,\"motion_route_scope\":\"finite_first_contact_retreat_and_three_spray_cases\",\"station_held_claimed\":false,\"prior_clipped_tag_failure_retained\":false,\"scoped_hairline_observation_retained\":false,\"native_support_qualification_mm\":0,\"original_failed_mechanics_attempts_retained\":true}}"), "1215 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1232_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:northpoint-1232-live:building:w96215673:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1232 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1232-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"d2d9bd3d7f643d92b45d4c1ca974892d3b35210ae2d2cfe55b89fb4afb94df26\",\"motion_telemetry_manifest_sha256\":\"1fd9e52c06c062e48dfc3d6489dfaba4350ba1413a97923f9a44371b052dad39\",\"visual_motion_manifest_sha256\":\"26d44f6abccabc4c3075a214a22feff4ba4f6d5b2f6b1b2815d4c32301c37577\",\"package_verification_receipt_sha256\":\"f38bbb66dce45b62bdb82705335b55547f571992a8389f6b8346b16f56e32c1f\",\"evidence_tree_sha256\":\"c323d879c100e3ac1898905a9841e7f52cc4a76022e7329638ae7feeb586739d\",\"mechanical_review_receipt_sha256\":\"2560c1e1032fd997a2cf8db74de48d0430d9bb0fb61165cc09312efba5e9af5f\",\"review_receipt_sha256\":\"1cbb4737ed14190e9f6a744b152eaaeddf8d18c39f827cfab784ec94f07c16be\",\"accepted_physical_unit_id\":\"physical-building:w96215673\",\"capture_time_recognition_metric\":\"26/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215673\",\"wall_object_key\":\"building:w96215673:wall\",\"roof_object_key\":\"building:w96215673:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[10,11,12,13,14,15,16,17,18],\"protected_run_indices\":[0,1,2,3,4,5,6,7,8,9,19,20,21,22,23],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":19,\"visual_surfaces\":19,\"visual_triangles\":2576,\"wall_native_counts\":[18,18,2560,3,14],\"roof_native_counts\":[1,1,16,1,1],\"world_records\":735,\"world_mesh_instances\":1244,\"world_surfaces\":1259,\"world_triangles\":173181,\"world_static_bodies\":494,\"world_shapes\":633,\"world_topology_scope\":\"shared_northern_1232_1241_1221_candidate_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":15,\"spray_owner_count\":2,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":false,\"original_wall_and_projected_front_are_receivers\":true,\"projected_receiver_runs\":[10,11,12,13,15,16,17,18],\"projected_receiver_triangles\":6,\"projected_receiver_shape_order\":[\"ProjectedUpperSiding\"],\"projected_receiver_physics_layer\":5,\"projected_receiver_cull_mask\":2,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"ObservedPublicRoof\",\"CarportRoof\",\"CarportPosts\",\"CarportFascia\",\"ProjectedUpperClosures\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"BlueGrayClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"added_public_roof_triangles\":36,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"native_support_qualification_mm\":4,\"scope_authority\":\"exact_unit_seventh_attestation_and_retained_first_five\",\"unit_packet_limits_retained\":true,\"motion_route_scope\":\"selected_door10_screen11_three_sprays_separate_setups\"}}"), "1232 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1241_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:northpoint-1241-live:building:w96215674:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1241 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1241-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"465fd62a4b0ce93e7185b6eb17bdf50ede9127e60c492e59848d830d1fb0d2f7\",\"motion_telemetry_manifest_sha256\":\"c2e401e59485819a039b4b40bf0f025edabf9691673b179e89c338927a10939c\",\"visual_motion_manifest_sha256\":\"690e653a17e8adcebe8908ffa06c8a6dd7b2c5e6886d42f9415e1b03f2ecfd9a\",\"package_verification_receipt_sha256\":\"c7a8caf732d9d50ba481b3a889ab9c8aff72833fb2277c56fb997d7af3baef98\",\"evidence_tree_sha256\":\"4b293afae85d79015d9f6c0a0b22dff50962db7bf8b05d9f4ba52e152cb13a32\",\"mechanical_review_receipt_sha256\":\"6c956cd7f3b7502ab73505d11297efa68d365f7f393f8419fd9293fb71a99cb9\",\"review_receipt_sha256\":\"b89b6e90ed0cd33dcf4a540a62965a71ff75c3d8d2eb9ec1e8368b6e3016f869\",\"accepted_physical_unit_id\":\"physical-building:w96215674\",\"capture_time_recognition_metric\":\"28/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215674\",\"wall_object_key\":\"building:w96215674:wall\",\"roof_object_key\":\"building:w96215674:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[0,1,2,3,5,6,7,8,10,11,12],\"protected_run_indices\":[4,9,13,14,15,16,17,18,19,20,21,22,23,24,25],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":19,\"visual_surfaces\":19,\"visual_triangles\":3432,\"wall_native_counts\":[18,18,3416,3,14],\"roof_native_counts\":[1,1,16,1,1],\"world_records\":735,\"world_mesh_instances\":1244,\"world_surfaces\":1259,\"world_triangles\":173181,\"world_static_bodies\":494,\"world_shapes\":633,\"world_topology_scope\":\"shared_northern_1232_1241_1221_candidate_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":15,\"spray_owner_count\":2,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":false,\"original_wall_and_projected_front_are_receivers\":true,\"projected_receiver_runs\":[0,1,2,3,5,6,7,8,10,11,12],\"projected_receiver_triangles\":6,\"projected_receiver_shape_order\":[\"ProjectedUpperSiding\"],\"projected_receiver_physics_layer\":5,\"projected_receiver_cull_mask\":2,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"ObservedPublicRoof\",\"CarportRoof\",\"CarportPosts\",\"CarportFascia\",\"ProjectedUpperClosures\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"MaroonClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"added_public_roof_triangles\":36,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"native_support_qualification_mm\":4,\"scope_authority\":\"exact_unit_seventh_attestation_and_retained_first_five\",\"unit_packet_limits_retained\":true,\"motion_route_scope\":\"selected_run7_door2_screen_partial_run12_spray_separate_setups\"}}"), "1241 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1221_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:mariner-1221-live:building:w96215682:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1221 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1221-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"cb80718812047da42fb907917cafe4ce59a15eada7b2dc9aaef1b26b56697970\",\"motion_telemetry_manifest_sha256\":\"cffac7d9d8bda08c1651fa0db0f4969ddf9de5ce9065548dd25e1aab415e571f\",\"visual_motion_manifest_sha256\":\"a00772f32f2b9a68adc9607638b4045bb1abafa6455c906a718e6e9cc6ef2259\",\"package_verification_receipt_sha256\":\"80140a7a02f241033157e6f22813a98b56ddf718193298ee0237f040562d8885\",\"evidence_tree_sha256\":\"b3861383f25ceb1f14f6f068dcabf145b3afe9fb5ba8b0056f1e6b79a145e757\",\"mechanical_review_receipt_sha256\":\"76517f928240abbe44a989e29546135711039869f595b0d7f6073a3cf8262153\",\"review_receipt_sha256\":\"235ae67b88d48acccd234af320e5a2c439318f9bff2fa1af66744858a01cb41f\",\"accepted_physical_unit_id\":\"physical-building:w96215682\",\"capture_time_recognition_metric\":\"28/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215682\",\"wall_object_key\":\"building:w96215682:wall\",\"roof_object_key\":\"building:w96215682:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[0,1,2,3,4,5,6,7,8,9,10,11,12],\"protected_run_indices\":[13,14,15,16,17,18,19,20,21,22,23,24,25],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":20,\"visual_surfaces\":20,\"visual_triangles\":3372,\"wall_native_counts\":[19,19,3356,3,14],\"roof_native_counts\":[1,1,16,1,1],\"world_records\":735,\"world_mesh_instances\":1244,\"world_surfaces\":1259,\"world_triangles\":173181,\"world_static_bodies\":494,\"world_shapes\":633,\"world_topology_scope\":\"pre_northern_1240_integration_live_parity\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":15,\"spray_owner_count\":2,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":false,\"original_wall_and_projected_front_are_receivers\":true,\"projected_receiver_runs\":[0,1,2,4,5,6,9,10,11,12],\"projected_receiver_triangles\":6,\"projected_receiver_shape_order\":[\"ProjectedUpperSiding\"],\"projected_receiver_physics_layer\":5,\"projected_receiver_cull_mask\":2,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"ObservedPublicRoof\",\"CarportRoof\",\"CarportPosts\",\"CarportFascia\",\"ProjectedUpperClosures\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"MaroonClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"added_public_roof_triangles\":36,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"native_support_qualification_mm\":4,\"scope_authority\":\"exact_unit_seventh_attestation_and_retained_first_five\",\"unit_packet_limits_retained\":true,\"motion_route_scope\":\"selected_door1_screen_first_contact_retreat_three_sprays_separate_setups\"}}"), "1221 exact source/ownership/acceptance and world contract in consumed JSON types.")

func _validate_northern_1240_runtime_adapter(adapter: Dictionary, contract: Dictionary) -> void:
	var behavior := contract.get("behavior_contract", {}) as Dictionary
	_require(str(adapter.get("adapter_id", "")) == "active-adapter:northpoint-1240-live:building:w96215688:wall" and (adapter.get("runtime_assets", []) as Array).size() == 5 and (adapter.get("runtime_asset_projections", []) as Array).is_empty(), "1240 exact five-asset receiver closure.")
	_require(behavior == JSON.parse_string("{\"schema_version\":\"ti.northern-1240-production-live-parity/1\",\"acceptance_contract\":{\"evidence_manifest_sha256\":\"35ca950b839ba5337ec6aa1afa23c3a41b541ddbcc72d8cd948fd3ff945f357e\",\"motion_telemetry_manifest_sha256\":\"6940be3303a7bb398e89594dbbe029913b6199836e96b58ca5ed6f8cfdab6d3d\",\"visual_motion_manifest_sha256\":\"cef4880c25f45a6d11699843dce565efd2620fc48a0904aa5af2e6f4aa8b2b9e\",\"package_verification_receipt_sha256\":\"aa9865bc070916b027cb58759259bd8ee0b27d1ca36ac413360d4b9d261c1ad4\",\"evidence_tree_sha256\":\"d272fe5677097e67016ea21af2e9eb5e9a5daff69ad7f86deb1d343b02b7e18c\",\"mechanical_review_receipt_sha256\":\"0a6727056299a7bbf91fc97137ff794d5350128c9b3f15276f7680de9aa921d3\",\"review_receipt_sha256\":\"deee84ad808e2a740f79f3c796b87c18b242e18f005a902646d3645d9c580939\",\"accepted_physical_unit_id\":\"physical-building:w96215688\",\"capture_time_recognition_metric\":\"31/213\",\"numerator_effect\":1,\"reference_recognizable\":true,\"wall_and_roof_are_one_physical_unit\":true},\"replacement_contract\":{\"source_key\":\"w96215688\",\"wall_object_key\":\"building:w96215688:wall\",\"roof_object_key\":\"building:w96215688:roof\",\"actual_supplied_chunk_pair_required\":true,\"actual_land_and_area_records_required\":false,\"mapped_public_run_indices\":[15,16,18,19,20,21,23,24,25],\"protected_run_indices\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,17,22,26,27],\"partial_pair_allowed\":false,\"fallback_allowed\":false,\"generic_stack_allowed\":false,\"factory_calls\":1,\"raw_source_constructor_callback_required\":true,\"tangent_callback_required\":true},\"geometry_contract\":{\"source_chunk_sha256\":\"bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac\",\"horizontal_source_footprint_preserved\":true,\"original_source_channels_and_roof_preserved\":true,\"visual_mesh_instances\":18,\"visual_surfaces\":18,\"visual_triangles\":3056,\"wall_native_counts\":[17,17,3040,3,14],\"roof_native_counts\":[1,1,16,1,1],\"world_records\":735,\"world_mesh_instances\":1260,\"world_surfaces\":1275,\"world_triangles\":176165,\"world_static_bodies\":496,\"world_shapes\":646,\"world_topology_scope\":\"current_integration_topology\"},\"ownership_contract\":{\"structural_owner_count\":4,\"shape_count\":15,\"spray_owner_count\":2,\"navigation_owner_count\":0,\"wall_is_sole_spray_receiver\":false,\"original_wall_and_projected_front_are_receivers\":true,\"projected_receiver_runs\":[15,16,18,19,20,21,23,24,25],\"projected_receiver_triangles\":6,\"projected_receiver_shape_order\":[\"ProjectedUpperSiding\"],\"projected_receiver_physics_layer\":5,\"projected_receiver_cull_mask\":2,\"wall_decal_cull_mask\":2,\"wall_shape_order\":[\"exact_eligible_source_wall\",\"ObservedPublicRoof\",\"CarportRoof\",\"CarportPosts\",\"CarportFascia\",\"ProjectedUpperClosures\",\"PaleCompleteTrim\",\"BlueOpaqueGlazing\",\"DarkOpaqueGlazing\",\"MaroonClosedDoors\",\"LocalPrivacyScreens\",\"PaleDrainageAndFascia\",\"DoorHardware\"],\"roof_shape_order\":[\"exact_noneligible_source_roof\"],\"added_public_roof_triangles\":36,\"original_flat_roof_preserved\":true,\"added_public_roof_is_nonreceiver\":true,\"all_additions_render_only\":false,\"added_ground_collision_triangles\":0,\"roof_is_wall_spray_receiver\":false,\"roof_world_solid_landing\":true,\"eligible_render_layer\":2,\"noneligible_render_layer\":1,\"terrain_geometry_and_ownership_unchanged\":true},\"truth_boundary\":{\"as_built_fidelity_claimed\":false,\"interior_modeled\":false,\"hidden_schedule_invented\":false,\"capture_time_recognition_credit\":false,\"capture_time_candidate_promoted\":false,\"reference_pixels_packaged\":false,\"receiver_complete_inferred_from_art\":false,\"game_distinctive_claimed\":false,\"unobserved_sides_protected\":true,\"unsurveyed_dimensions_and_counts_are_production_inference\":true,\"continuous_motion_review_claimed\":false,\"ground_to_roof_traversal_claimed\":false,\"spray_input_event_dispatch_claimed\":false,\"separate_setup_poses_retained\":true,\"sparse_movie_samples_only\":true,\"native_support_qualification_mm\":4,\"scope_authority\":\"exact_unit_seventh_attestation_and_retained_first_five\",\"unit_packet_limits_retained\":true,\"motion_route_scope\":\"six_selected_stock_approaches_returns_four_spray_callbacks_separate_setups_activation_limit_retained\"}}"), "1240 exact source/ownership/acceptance and world contract in consumed JSON types.")
