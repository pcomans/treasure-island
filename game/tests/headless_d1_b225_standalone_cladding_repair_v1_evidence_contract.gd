extends SceneTree

const EVIDENCE_ROOT := "res://evidence/first-playable/d1-b225-standalone-cladding-repair-v1-2026-09-04"
const MANIFEST_PATH := EVIDENCE_ROOT + "/capture-manifest.json"
const PACKAGE_AUDIT_PATH := EVIDENCE_ROOT + "/package-audit.json"
const CONFIG_PATH := "res://game/resources/facades/d1_current/repairs/d1_b225_nnw_long_cladding_repair_v1.json"
const CAPTURE_PATH := "res://game/tests/d1_b225_standalone_cladding_repair_v1_capture.gd"
const STRUCTURAL_CONTRACT_PATH := "res://game/tests/headless_d1_b225_standalone_cladding_repair_v1_contract.gd"
const INDEPENDENT_REVIEW_PATH := EVIDENCE_ROOT + "/INDEPENDENT_BAR_RAISER_REVIEW.md"
const EXPECTED_INDEPENDENT_REVIEW_SHA256 := "b35df2e8c39e854b3553d07d369cdd72a76b1a37446ffb7bbe9a5941f8a69015"
const SOURCE_RECEIPT_PATH := "res://discovery/facades/PRECOMMIT_PACKAGE_SANITIZATION_SOURCE_PROVENANCE.json"
const SOURCE_RECEIPT_SHA256 := "269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333"
const EXPECTED_MANIFEST_SHA256 := "22cbe9edec6e33ccbfcc2c71d719c2c1bc646358fb46242be802affe371b2ec5"
const EXPECTED_CAPTURE_TIME_CONFIG_SHA256 := "89d34d33b48c93c0a6c90d46ff8120cd36c5f897ebe1fc9ea2ee2cd97a3db22c"
const EXPECTED_CURRENT_CONFIG_SHA256 := "7c1c2d508f78236590c6d413604be60b3a5c48865878e69d294177d05c48d166"
const EXPECTED_CAPTURE_SHA256 := "a6b5d7997443279fa63f7418a0921646298e2d4f4e72b130c52970681c6b3ea7"
const EXPECTED_STRUCTURAL_CONTRACT_SHA256 := "54fc4361e70d383d4c1c1acf54e612e980efd1540803bde169f48d1efe704728"
const CAPTURE_SIZE := Vector2i(1440, 900)
const BOUNDARIES := [10.372629078, 16.883522872, 23.933383083]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manifest := _load_json(MANIFEST_PATH)
	var package_audit := _load_json(PACKAGE_AUDIT_PATH)
	if manifest.is_empty() or package_audit.is_empty():
		_finish()
		return
	_require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "B225 native manifest bytes drifted.")
	_require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CURRENT_CONFIG_SHA256, "B225 current package-safe repair config drifted.")
	_require(FileAccess.get_sha256(CAPTURE_PATH) == EXPECTED_CAPTURE_SHA256, "B225 native capture harness drifted.")
	_require(FileAccess.get_sha256(STRUCTURAL_CONTRACT_PATH) == EXPECTED_STRUCTURAL_CONTRACT_SHA256, "B225 structural contract drifted.")
	_require(FileAccess.get_sha256(INDEPENDENT_REVIEW_PATH) == EXPECTED_INDEPENDENT_REVIEW_SHA256, "B225 independent bar-raiser review receipt drifted.")
	_require(_manifest_contract_matches(manifest), "B225 native evidence manifest scope/renderer/topology contract failed.")
	_require(_source_receipt_matches(), "B225 capture-time config hash is not reconciled through the sealed source-only provenance receipt.")
	_require(_static_pairs_match(manifest), "B225 matched control/candidate clean views drifted.")
	_require(_motion_matches(manifest), "B225 consecutive motion/run-boundary contract failed.")
	_require(_package_audit_matches(package_audit), "B225 isolated package-cost audit failed.")
	if not _failed:
		print("PASS: B225 evidence pins four clean control/candidate pairs, 25 consecutive native Metal frames crossing all run joins, exact generated provenance/topology, and isolated package cost; the manifest's capture-time pending label is preserved, and the exact independent review subsequently passed with limitation for a future reversible live promotion while this repair remains unattached")
	_finish()


func _manifest_contract_matches(manifest: Dictionary) -> bool:
	var candidate := manifest.get("candidate", {}) as Dictionary
	var config_record := candidate.get("config", {}) as Dictionary
	var uv := manifest.get("metre_uv_contract", {}) as Dictionary
	var topology := manifest.get("topology", {}) as Dictionary
	var harness := manifest.get("capture_harness", {}) as Dictionary
	return str(manifest.get("schema_version", "")) == "ti.d1-b225-standalone-cladding-repair-native-evidence/1" \
		and str(manifest.get("review_status", "")) == "pending_independent_bar_raiser_re_review_not_self_accepted" \
		and bool(manifest.get("clean_images", false)) \
		and int(manifest.get("image_overlays_or_claim_cards", -1)) == 0 \
		and not bool(manifest.get("runtime_attachment", true)) \
		and not bool(manifest.get("exact_receiver_layout", true)) \
		and str(config_record.get("sha256", "")) == EXPECTED_CAPTURE_TIME_CONFIG_SHA256 \
		and str(harness.get("sha256", "")) == EXPECTED_CAPTURE_SHA256 \
		and str(candidate.get("geometry_signature", "")) == "281a471f6cff9b0530aa51c98cc737d276dc0d9210996a5403d9fe44996dd2a2" \
		and str(candidate.get("uv_plan_signature", "")) == "6b33f7b7146815b87fa7aec9bced760309104f4f56038e37e1820199c9b446f5" \
		and is_equal_approx(float(uv.get("u_start_m", -1.0)), 0.0) \
		and absf(float(uv.get("u_end_m", 0.0)) - 46.261968372) <= 0.000000001 \
		and _numeric_array_approx(uv.get("internal_boundaries_u_m", []) as Array, BOUNDARIES, 0.000000001) \
		and int(uv.get("phase_resets_inside_chain", -1)) == 0 \
		and _numeric_array_approx(uv.get("texture_cell_m", []) as Array, [8.0, 3.48], 0.000001) \
		and int(topology.get("render_geometry_batches", 0)) == 3 \
		and int(topology.get("box_instances", 0)) == 90 \
		and int(topology.get("triangles", 0)) == 1088 \
		and int(topology.get("removed_dark_course_boxes", 0)) == 14 \
		and int(topology.get("collision_nodes", -1)) == 0 \
		and int(topology.get("navigation_nodes", -1)) == 0 \
		and int(topology.get("spray_nodes", -1)) == 0 \
		and str(manifest.get("display_driver", "")) == "macOS" \
		and "Apple M2" in str(manifest.get("video_adapter", "")) \
		and _int_array(manifest.get("viewport", []) as Array) == [1440, 900] \
		and (manifest.get("visual_questions_for_independent_reviewer", []) as Array).size() == 5 \
		and "independent visual acceptance" in str(manifest.get("blocked_claims", []))


func _source_receipt_matches() -> bool:
	if FileAccess.get_sha256(SOURCE_RECEIPT_PATH) != SOURCE_RECEIPT_SHA256:
		return false
	var receipt := _load_json(SOURCE_RECEIPT_PATH)
	var record := (receipt.get("records", {}) as Dictionary).get("D1-B225-REPAIR-AUTHORITY", {}) as Dictionary
	return str(receipt.get("schema_version", "")) == "ti.precommit-package-sanitization-source-provenance/1" \
		and str(record.get("historical_runtime_config_sha256", "")) == EXPECTED_CAPTURE_TIME_CONFIG_SHA256


func _static_pairs_match(manifest: Dictionary) -> bool:
	var captures := manifest.get("static_captures", []) as Array
	if int(manifest.get("static_capture_count", 0)) != 8 or captures.size() != 8:
		return false
	var expected_ids := ["01-front", "02-oblique", "03-close", "04-changed-light"]
	for pair_index in 4:
		var control := captures[pair_index * 2] as Dictionary
		var candidate := captures[pair_index * 2 + 1] as Dictionary
		if str(control.get("id", "")) != expected_ids[pair_index] \
		or str(candidate.get("id", "")) != expected_ids[pair_index] \
		or str(control.get("variant", "")) != "control" \
		or str(candidate.get("variant", "")) != "candidate" \
		or control.get("camera_position_m", []) != candidate.get("camera_position_m", []) \
		or control.get("sun_rotation_degrees", []) != candidate.get("sun_rotation_degrees", []) \
		or str(control.get("sha256", "")) == str(candidate.get("sha256", "")) \
		or not _capture_file_matches(control) \
		or not _capture_file_matches(candidate):
			return false
	return true


func _motion_matches(manifest: Dictionary) -> bool:
	var motion := manifest.get("motion", {}) as Dictionary
	var frames := motion.get("frames", []) as Array
	if int(motion.get("frame_count", 0)) != 25 \
	or frames.size() != 25 \
	or not bool(motion.get("crosses_all_internal_run_boundaries", false)) \
	or not is_equal_approx(float(motion.get("ordinary_standoff_m", 0.0)), 12.0) \
	or not is_equal_approx(float(motion.get("step_m", 0.0)), 0.75) \
	or not is_equal_approx(float(motion.get("chain_u_start_m", 0.0)), 8.0) \
	or not is_equal_approx(float(motion.get("chain_u_end_m", 0.0)), 26.0) \
	or "consecutive native rendered frames" not in str(motion.get("kind", "")):
		return false
	var hashes: Dictionary = {}
	for index in frames.size():
		var frame := frames[index] as Dictionary
		var expected_u := 8.0 + float(index) * 0.75
		var expected_crossed: Array[float] = []
		for boundary in BOUNDARIES:
			if float(boundary) <= expected_u:
				expected_crossed.append(float(boundary))
		var hash := str(frame.get("sha256", ""))
		if int(frame.get("frame", -1)) != index \
		or str(frame.get("file", "")) != "motion/frame-%02d.png" % index \
		or not is_equal_approx(float(frame.get("camera_chain_u_m", 0.0)), expected_u) \
		or not _numeric_array_approx(frame.get("crossed_internal_boundaries_u_m", []) as Array, expected_crossed, 0.000000001) \
		or hashes.has(hash) \
		or not _capture_file_matches(frame):
			return false
		hashes[hash] = true
	return true


func _capture_file_matches(record: Dictionary) -> bool:
	var path := EVIDENCE_ROOT.path_join(str(record.get("file", "")))
	if not FileAccess.file_exists(path) \
	or FileAccess.get_sha256(path) != str(record.get("sha256", "")) \
	or FileAccess.get_file_as_bytes(path).size() != int(record.get("bytes", -1)):
		return false
	var image := Image.new()
	return image.load(ProjectSettings.globalize_path(path)) == OK and image.get_size() == CAPTURE_SIZE


func _package_audit_matches(audit: Dictionary) -> bool:
	var without_record := audit.get("branch_excluded_pack", {}) as Dictionary
	var with_record := audit.get("branch_included_pack", {}) as Dictionary
	var without_path := str(without_record.get("path", ""))
	var with_path := str(with_record.get("path", ""))
	var without_size := _file_size(without_path)
	var with_size := _file_size(with_path)
	return str(audit.get("schema_version", "")) == "ti.d1-b225-isolated-package-cost/1" \
		and str(audit.get("measurement_method", "")).begins_with("two exports from one immutable temporary snapshot") \
		and without_size > 0 \
		and with_size > without_size \
		and int(without_record.get("bytes", -1)) == without_size \
		and int(with_record.get("bytes", -1)) == with_size \
		and FileAccess.get_sha256(without_path) == str(without_record.get("sha256", "")) \
		and FileAccess.get_sha256(with_path) == str(with_record.get("sha256", "")) \
		and int(audit.get("isolated_branch_delta_bytes", 0)) == with_size - without_size \
		and int(audit.get("selected_source_png_bytes", 0)) == 2140085 \
		and int(audit.get("imported_ctex_bytes", 0)) == 2031028 \
		and int(audit.get("estimated_full_rgba8_mip_chain_runtime_bytes", 0)) == 8386752 \
		and bool(audit.get("evidence_excluded_from_export", false)) \
		and bool(audit.get("rejected_generation_outside_project", false)) \
		and str(audit.get("shipping_policy", "")).begins_with("currently bundled and explicitly costed")


func _file_size(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return -1
	var size := file.get_length()
	file.close()
	return size


func _numeric_array_approx(actual: Array, expected: Array, tolerance: float) -> bool:
	if actual.size() != expected.size():
		return false
	for index in actual.size():
		if absf(float(actual[index]) - float(expected[index])) > tolerance:
			return false
	return true


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		_fail("Missing JSON: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		_fail("Invalid JSON object: %s" % path)
		return {}
	return parsed as Dictionary


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	_failed = true
	push_error(message)


func _finish() -> void:
	quit(1 if _failed else 0)
