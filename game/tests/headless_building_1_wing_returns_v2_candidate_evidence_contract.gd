extends SceneTree

## Fail-closed verifier for the disposable Building 1 wing-return v2 A/B
## rehearsal. It does not render, recapture, promote, or grade the candidate.
## Create mode writes one receipt outside the repository only after validating
## every original PNG, both exact source/PCK identities, paired poses/lights,
## fixed-60 controller telemetry, and the bounded +1440-triangle visual delta.

const PACKET_ID := "building-1-wing-returns-v2-candidate-2026-09-08-001"
const CAPTURE_DATE := "2026-09-08"
const CAPTURE_SIZE := Vector2i(1440, 900)
const RECEIPT_NAME := "rehearsal-verification-receipt.json"
const CAPTURE_GENERATOR := "res://game/tests/building_1_wing_returns_v2_candidate_capture.gd"
const CAPTURE_GENERATOR_SHA256 := "667b7fde2844d798eb2d13cafaa0fbe802ada1239335c300df40c5e0f0a89fb2"
const PACKAGE_CONTRACT := "res://game/tests/headless_building_1_wing_returns_v2_candidate_package_contract.gd"
const PACKAGE_CONTRACT_SHA256 := "658775e336ac1b582467b4327e34545f5b3bf665708834ef56853a9cfd792289"
const SOURCE_AUDIT := "res://evidence/reviews/building-1-wing-returns-v2-2026-09-08-INDEPENDENT_SOURCE_AUDIT.md"
const SOURCE_AUDIT_SHA256 := "beced0b7bb42589a1214559e193855e46a90a1a0578f5e2a323995a9f2d77958"
const SOURCE_AUDIT_TOKEN := "PASS_FOR_B1_RETURNS_V2_EVIDENCE_CAPTURE"
const PACKAGE_PROOF_SHA256 := "20a54f0a274d1f750aa4d2c5d48cb6cde34c7b95357426b0766c4d1e7a0e0b04"
const PACKAGE_PROOF_TOKEN := "PASS_FOR_B1_RETURNS_V2_SOURCE_CAPTURE"
const REGISTRY_SHA256 := "26dcf64a34cf92aa7766c60940933190cdb5f9bc595dc23dc2f16fa01752e16c"
const CONTRACTS_SHA256 := "8c61ea5601ab94852ac593b8658963b52cb5253aae22a2ff109f2e46771caa93"
const BASELINE_PCK_SHA256 := "0945ac7b08ebd2fc5389ffa05a919b7324ecb298dac46032c8fdc30d8c47404a"
const CANDIDATE_PCK_SHA256 := "59b37cf856dd1ece6aaadeee5c6278327997394339bb8450253193cbd89728da"
const BASELINE_CONFIG_SHA256 := "7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806"
const CANDIDATE_CONFIG_SHA256 := "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb"
const BASELINE_ADAPTER_SHA256 := "e5b11fc7f971ea33bb38c84d3106f8883de0486774f58a5a8310d49d56aa55a5"
const CANDIDATE_ADAPTER_SHA256 := "ce2f21dab02163b5f45d9d7e457f5d0ce96089bc55cca6e65aa9924c9f199c5a"
const CANDIDATE_EXE_SHA256 := "7d47d442cf8b19fab0e2628c79d7b5994961f8f2096b58046a14884e9f8f0af6"
const CANDIDATE_PLIST_SHA256 := "12210013168f4197b156c151636a81d27285741b3d2cdd138740d09853a9f085"
const BASELINE_PCK := "res://build/d2-1441-postpromotion-v9-2026-09-07-001/Treasure Island First Playable.app/Contents/Resources/Treasure Island First Playable.pck"
const CANDIDATE_BUILD_ROOT := "res://build/building-1-wing-returns-v2-candidate-2026-09-08-001/Treasure Island First Playable.app"
const CANDIDATE_EXE := CANDIDATE_BUILD_ROOT + "/Contents/MacOS/Treasure Island First Playable"
const CANDIDATE_PCK := CANDIDATE_BUILD_ROOT + "/Contents/Resources/Treasure Island First Playable.pck"
const CANDIDATE_PLIST := CANDIDATE_BUILD_ROOT + "/Contents/Info.plist"
const POSE_TOLERANCE_M := 0.22
const PAIR_FLOAT_TOLERANCE := 0.00005

const DEFAULT_SUN := [-52.0, -28.0, 0.0]
const CHANGED_SUN := [-18.0, 118.0, 0.0]
const EXPECTED_TOPOLOGY := {
	"baseline": {"rows": 735, "meshes": 959, "surfaces": 974, "triangles": 69252, "bodies": 466, "shapes": 466},
	"candidate": {"rows": 735, "meshes": 959, "surfaces": 974, "triangles": 70692, "bodies": 466, "shapes": 466},
}
const EXPECTED_SOURCE := {
	"baseline": {"render_source": "exact_source_checkout_not_exported_PCK", "sealed_corresponding_PCK_role": "separately_hash_bound_and_direct_mounted_component_contract", "pck_sha256": BASELINE_PCK_SHA256, "config_sha256": BASELINE_CONFIG_SHA256, "adapter_sha256": BASELINE_ADAPTER_SHA256},
	"candidate": {"render_source": "exact_source_checkout_not_exported_PCK", "sealed_corresponding_PCK_role": "separately_hash_bound_and_direct_mounted_component_contract", "pck_sha256": CANDIDATE_PCK_SHA256, "config_sha256": CANDIDATE_CONFIG_SHA256, "adapter_sha256": CANDIDATE_ADAPTER_SHA256},
}
const EXPECTED_MAIN_WALL_TRIANGLES := {"baseline": 8806, "candidate": 10246}
const EXPECTED_REVEAL_TRIANGLES := {"baseline": 168, "candidate": 168}
const EXPECTED_TRIM_TRIANGLES := {"baseline": 6804, "candidate": 8244}
const VIEW_DEFINITIONS := [
	{"id": "01-whole-front", "requested_xz": [-72.9087524414062, 757.150634765625], "aim_target_m": [0.941, 16.281, 749.703]},
	{"id": "02-north-wing-far", "requested_xz": [-73.766048, 758.116777], "aim_target_m": [-33.943094, 13.625, 713.237691]},
	{"id": "03-north-wing-near", "requested_xz": [-50.535992, 731.937310], "aim_target_m": [-33.943094, 13.625, 713.237691]},
	{"id": "04-south-wing-far", "requested_xz": [-68.008646, 758.596130], "aim_target_m": [-10.460366, 13.625, 775.572451]},
	{"id": "05-south-wing-near", "requested_xz": [-34.438816, 768.498984], "aim_target_m": [-10.460366, 13.625, 775.572451]},
]
const MOTION_DEFINITIONS := {
	"north": {"start_xz": [-73.766048, 758.116777], "near_xz": [-50.535992, 731.937310], "target_m": [-33.943094, 13.625, 713.237691]},
	"south": {"start_xz": [-68.008646, 758.596130], "near_xz": [-34.438816, 768.498984], "target_m": [-10.460366, 13.625, 775.572451]},
}
const STILL_IDS := [
	"01-whole-front-changed", "01-whole-front-default", "01-whole-front-grayscale",
	"02-north-wing-far-changed", "02-north-wing-far-default", "02-north-wing-far-grayscale",
	"03-north-wing-near-changed", "03-north-wing-near-default", "03-north-wing-near-grayscale",
	"04-south-wing-far-changed", "04-south-wing-far-default", "04-south-wing-far-grayscale",
	"05-south-wing-near-changed", "05-south-wing-near-default", "05-south-wing-near-grayscale",
	"06-protected-rear-east", "07-tower-accepted-pose-one", "08-tower-accepted-pose-two",
	"09-real-spray-blank-wing-pier", "10-real-player-main-roof-landing", "11-whole-context",
	"12-elevated-overview-diagnostic-only",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var root_path := _argument("--capture-root=")
	var mode := _argument("--receipt-mode=")
	if not root_path.is_absolute_path() or mode not in ["create", "verify"]:
		_fail("Pass an absolute --capture-root and --receipt-mode=create or verify.")
		_finish()
		return
	var result := _validate(root_path, mode)
	if not bool(result.get("ok", false)):
		_fail(str(result.get("message", "Rehearsal evidence validation failed.")))
		_finish()
		return
	var receipt_path := root_path.path_join(RECEIPT_NAME)
	var receipt_text := JSON.stringify(result.receipt, "  ", false) + "\n"
	var receipt_sha := _sha256_text(receipt_text)
	if mode == "create":
		if FileAccess.file_exists(receipt_path) or not _write_new(receipt_path, receipt_text) or FileAccess.get_sha256(receipt_path) != receipt_sha:
			_fail("Could not create the exact rehearsal receipt once.")
			_finish()
			return
	else:
		var expected_receipt_sha := _argument("--receipt-sha256=")
		if expected_receipt_sha.length() != 64 or FileAccess.get_sha256(receipt_path) != expected_receipt_sha \
		or expected_receipt_sha != receipt_sha or FileAccess.get_file_as_string(receipt_path) != receipt_text:
			_fail("Existing rehearsal receipt is missing, drifted, or not exactly reproducible.")
			_finish()
			return
	print("PASS: rehearsal-only B1 returns v2 A/B closure is exact: 92 original PNGs + 6 manifests, byte-rederived grayscale, zero paired pose/controller-tick drift, intended +1440 visual triangles only; receipt=%s" % receipt_sha)
	_finish()


func _validate(root_path: String, mode: String) -> Dictionary:
	var proof := _argument("--package-proof-receipt=")
	if not proof.is_absolute_path() or FileAccess.get_sha256(proof) != PACKAGE_PROOF_SHA256:
		return _bad("Completed composite package receipt is missing or changed.")
	var proof_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(proof))
	if not proof_value is Dictionary or str(proof_value.get("status", "")) != PACKAGE_PROOF_TOKEN \
	or str(proof_value.get("verifier_sha256", "")) != FileAccess.get_sha256("res://tools/verify_building_1_wing_returns_v2_candidate_package.py"):
		return _bad("Composite package verifier or verdict changed.")
	if FileAccess.get_sha256(CAPTURE_GENERATOR) != CAPTURE_GENERATOR_SHA256 \
	or FileAccess.get_sha256(PACKAGE_CONTRACT) != PACKAGE_CONTRACT_SHA256 \
	or FileAccess.get_sha256(SOURCE_AUDIT) != SOURCE_AUDIT_SHA256:
		return _bad("Capture generator, mounted-PCK contract, or independent source audit drifted.")
	if FileAccess.get_sha256(BASELINE_PCK) != BASELINE_PCK_SHA256 \
	or FileAccess.get_sha256(CANDIDATE_PCK) != CANDIDATE_PCK_SHA256 \
	or FileAccess.get_sha256(CANDIDATE_EXE) != CANDIDATE_EXE_SHA256 \
	or FileAccess.get_sha256(CANDIDATE_PLIST) != CANDIDATE_PLIST_SHA256:
		return _bad("Baseline PCK or sealed candidate app inventory drifted.")
	var evidence_paths := _expected_paths()
	var expected_paths := evidence_paths.duplicate()
	var actual_paths := _relative_files(root_path)
	if mode == "verify":
		expected_paths.append(RECEIPT_NAME)
		expected_paths.sort()
	if actual_paths != expected_paths:
		return _bad("Rehearsal inventory is not exact. expected=%s actual=%s" % [expected_paths, actual_paths])
	var manifests := {}
	for stage in ["baseline", "candidate"]:
		for name in ["stills", "motion-north", "motion-south"]:
			var relative := "stages/%s/%s.json" % [stage, name]
			var value := _json(root_path.path_join(relative))
			if value.is_empty() or _contains_absolute_string(value):
				return _bad("Manifest is invalid or contains an absolute path: %s." % relative)
			manifests["%s/%s" % [stage, name]] = value
	var baseline_stills := manifests["baseline/stills"] as Dictionary
	var candidate_stills := manifests["candidate/stills"] as Dictionary
	if not _stills_valid(root_path, baseline_stills, "baseline") \
	or not _stills_valid(root_path, candidate_stills, "candidate") \
	or not _stills_pair_valid(baseline_stills, candidate_stills):
		return _bad("Static A/B still, pose, light, interaction, or contextual closure failed.")
	var max_motion_pose_delta := 0.0
	for side in ["north", "south"]:
		var baseline_motion := manifests["baseline/motion-%s" % side] as Dictionary
		var candidate_motion := manifests["candidate/motion-%s" % side] as Dictionary
		if not _motion_valid(root_path, baseline_motion, "baseline", side) \
		or not _motion_valid(root_path, candidate_motion, "candidate", side):
			return _bad("%s fixed-60 stock-controller motion closure failed." % side)
		var pair := _motion_pair_valid(baseline_motion, candidate_motion)
		if not bool(pair.get("ok", false)):
			return _bad("%s A/B motion pairing failed: %s" % [side, pair.get("message", "unknown")])
		max_motion_pose_delta = maxf(max_motion_pose_delta, float(pair.max_pose_delta_m))
	var inventory := _inventory(root_path, evidence_paths)
	if inventory.size() != 98:
		return _bad("Could not bind all 98 rehearsal inputs into the receipt.")
	var tree_material := ""
	var total_bytes := 0
	for value: Variant in inventory:
		var item := value as Dictionary
		tree_material += "%s|%s|%d\n" % [item.path, item.sha256, int(item.bytes)]
		total_bytes += int(item.bytes)
	var manifest_hashes := {}
	for stage in ["baseline", "candidate"]:
		manifest_hashes[stage] = {
			"stills": FileAccess.get_sha256(root_path.path_join("stages/%s/stills.json" % stage)),
			"motion_north": FileAccess.get_sha256(root_path.path_join("stages/%s/motion-north.json" % stage)),
			"motion_south": FileAccess.get_sha256(root_path.path_join("stages/%s/motion-south.json" % stage)),
		}
	var receipt := {
		"schema_version": "ti.building-1-wing-returns-v2-candidate-rehearsal-verification/1",
		"packet_id": PACKET_ID,
		"capture_date": CAPTURE_DATE,
		"rehearsal_only": true,
		"authoritative_evidence": false,
		"promotion": false,
		"recognition_credit": false,
		"recognition_status": "current_v9_9_of_213_unchanged",
		"review_status": "pending_independent_harness_receipt_audit_then_independent_bar_raiser_review",
		"visual_verdict": "pending_independent_review_not_self_graded",
		"capture_generator": "game/tests/building_1_wing_returns_v2_candidate_capture.gd",
		"capture_generator_sha256": CAPTURE_GENERATOR_SHA256,
		"evidence_contract": "game/tests/headless_building_1_wing_returns_v2_candidate_evidence_contract.gd",
		"evidence_contract_sha256": FileAccess.get_sha256("res://game/tests/headless_building_1_wing_returns_v2_candidate_evidence_contract.gd"),
		"mounted_candidate_pck_contract": "game/tests/headless_building_1_wing_returns_v2_candidate_package_contract.gd",
		"mounted_candidate_pck_contract_sha256": PACKAGE_CONTRACT_SHA256,
		"mounted_candidate_pck_contract_status": "independently_rerunnable_required_before_authoritative_copy",
		"source_audit": {"path": "evidence/reviews/building-1-wing-returns-v2-2026-09-08-INDEPENDENT_SOURCE_AUDIT.md", "sha256": SOURCE_AUDIT_SHA256, "token": SOURCE_AUDIT_TOKEN},
		"package_proof": {"sha256": PACKAGE_PROOF_SHA256, "token": PACKAGE_PROOF_TOKEN, "source_pixels_are_package_pixels": false},
		"source_vs_package_provenance": {
			"render_source": "exact_stage_source_checkouts_not_exported_PCKs",
			"sealed_pcks": {"baseline_sha256": BASELINE_PCK_SHA256, "candidate_sha256": CANDIDATE_PCK_SHA256},
			"candidate_app": {"executable_sha256": CANDIDATE_EXE_SHA256, "pck_sha256": CANDIDATE_PCK_SHA256, "info_plist_sha256": CANDIDATE_PLIST_SHA256},
			"claim": "source renders are hash-paired to sealed PCKs; mounted candidate PCK semantics are a separate contract",
		},
		"authority": {"metric": "9/213", "registry_sha256": REGISTRY_SHA256, "contracts_sha256": CONTRACTS_SHA256, "mutated": false, "frozen_D2_bridges_mutated": false},
		"counts": {"original_pngs": 92, "manifests": 6, "receipt_inputs": 98, "baseline_pngs": 46, "candidate_pngs": 46, "static_pngs_each": 22, "motion_pngs_each_side_each_stage": 12},
		"runtime_topology": EXPECTED_TOPOLOGY.duplicate(true),
		"bounded_delta": {"meshes": 0, "surfaces": 0, "triangles": 1440, "bodies": 0, "shapes": 0, "main_wall_triangles": 1440, "reveal_triangles": 0, "trim_triangles": 1440},
		"pairing": {"static_pose_tolerance_m": PAIR_FLOAT_TOLERANCE, "motion_pose_tolerance_m": POSE_TOLERANCE_M, "observed_max_motion_A_B_pose_delta_m": max_motion_pose_delta, "static_player_and_camera_positions_exact": true, "controller_telemetry_and_engine_ticks_exact": true, "lights_and_view_definitions_exact": true},
		"gates": {
			"native_macos_metal_1440x900": true,
			"stock_player_fov70_spring5_5_visible": true,
			"matched_default_changed_and_byte_rederived_grayscale": true,
			"both_wings_far_near_all_8_upper_7_lower_roles": true,
			"fixed60_input_only_motion_60_45_30_25m": true,
			"zero_motion_transform_writes_or_recoveries": true,
			"protected_return_and_two_exact_tower_poses": true,
			"real_spray_receiver_identity": true,
			"real_jetpack_supported_main_roof_landing": true,
			"whole_context_and_diagnostic_only_overview": true,
			"D2_topology_and_collision_ownership_preserved": true,
			"no_absolute_paths_in_manifests": true,
			"no_self_grade_or_promotion": true,
		},
		"manifest_sha256": manifest_hashes,
		"input_tree_sha256": _sha256_text(tree_material),
		"input_total_bytes": total_bytes,
		"input_inventory": inventory,
	}
	return {"ok": true, "receipt": receipt}


func _common_manifest_valid(manifest: Dictionary, stage: String) -> bool:
	var runtime := manifest.get("runtime_environment", {}) as Dictionary
	var authority := manifest.get("authority", {}) as Dictionary
	var camera := manifest.get("camera_contract", {}) as Dictionary
	return str(manifest.get("packet_id", "")) == PACKET_ID \
		and str(manifest.get("capture_date", "")) == CAPTURE_DATE \
		and str(manifest.get("stage", "")) == stage \
		and str(manifest.get("candidate_status", "")) == "isolated_uncommitted_no_credit_quality_candidate" \
		and str(manifest.get("review_status", "")) == "pending_independent_bar_raiser_review_not_self_accepted" \
		and str(manifest.get("recognition_status", "")) == "current_v9_9_of_213_unchanged" \
		and not bool(manifest.get("recognition_credit", true)) and not bool(manifest.get("additional_recognition_credit", true)) \
		and not bool(manifest.get("promotion", true)) and str(manifest.get("visual_verdict", "")) == "pending_independent_bar_raiser_review" \
		and str(manifest.get("generator", "")) == "game/tests/building_1_wing_returns_v2_candidate_capture.gd" \
		and str(manifest.get("generator_sha256", "")) == CAPTURE_GENERATOR_SHA256 \
		and manifest.get("package_proof", {}) == {"sha256": PACKAGE_PROOF_SHA256, "token": PACKAGE_PROOF_TOKEN, "source_pixels_are_package_pixels": false} \
		and manifest.get("source_vs_package_provenance", {}) == EXPECTED_SOURCE[stage] \
		and _values_close(manifest.get("runtime_topology", {}), EXPECTED_TOPOLOGY[stage], 0.0) \
		and str(runtime.get("godot_version", "")).begins_with("4.7.2") and str(runtime.get("display_driver", "")) == "macOS" \
		and str(runtime.get("rendering_method", "")) == "Forward+" and str(runtime.get("rendering_driver", "")) == "Metal" \
		and _values_close(runtime.get("viewport", []), [1440, 900], 0.0) \
		and str(camera.get("rig", "")) == "actual Player/CameraPivot/SpringArm3D/Camera3D" \
		and is_equal_approx(float(camera.get("fov_degrees", -1.0)), 70.0) \
		and is_equal_approx(float(camera.get("configured_spring_length_m", -1.0)), 5.5) \
		and bool(camera.get("player_visible", false)) and not bool(camera.get("detached_camera", true)) \
		and not bool(camera.get("labels_or_debug_overlays", true)) \
		and str(authority.get("registry_sha256", "")) == REGISTRY_SHA256 \
		and str(authority.get("contracts_sha256", "")) == CONTRACTS_SHA256 \
		and str(authority.get("metric", "")) == "9/213" \
		and not bool(authority.get("authority_mutated", true)) and not bool(authority.get("frozen_D2_bridges_mutated", true)) \
		and manifest.get("source_audit", {}) == {"sha256": SOURCE_AUDIT_SHA256, "token": SOURCE_AUDIT_TOKEN} \
		and bool(manifest.get("no_absolute_paths_recorded", false)) \
		and _bindings_valid(manifest.get("bindings", {}) as Dictionary, stage)


func _bindings_valid(bindings: Dictionary, stage: String) -> bool:
	var components := bindings.get("building_components", {}) as Dictionary
	return _values_close(components.get("building:r16681702:wall", {}), {"meshes": 6, "surfaces": 6, "triangles": EXPECTED_MAIN_WALL_TRIANGLES[stage], "bodies": 1, "shapes": 1}, 0.0) \
		and _values_close(components.get("building:r16681702:roof", {}), {"meshes": 3, "surfaces": 3, "triangles": 1131, "bodies": 1, "shapes": 1}, 0.0) \
		and _values_close(components.get("building:w1222720021:wall", {}), {"meshes": 3, "surfaces": 3, "triangles": 760, "bodies": 1, "shapes": 1}, 0.0) \
		and _values_close(components.get("building:w1222720021:roof", {}), {"meshes": 1, "surfaces": 1, "triangles": 14, "bodies": 1, "shapes": 1}, 0.0) \
		and int(bindings.get("reveal_triangles", -1)) == int(EXPECTED_REVEAL_TRIANGLES[stage]) \
		and int(bindings.get("trim_triangles", -1)) == int(EXPECTED_TRIM_TRIANGLES[stage]) \
		and int(bindings.get("wing_return_openings", -1)) == (0 if stage == "baseline" else 30) \
		and int(bindings.get("wing_return_strips", -1)) == (0 if stage == "baseline" else 120) \
		and int(bindings.get("wing_dark_backing_boxes", -1)) == 0 \
		and _values_close(bindings.get("d2_wall_topology", {}), {"meshes": 8, "surfaces": 8, "triangles": 1568, "bodies": 1, "shapes": 1}, 0.0) \
		and _values_close(bindings.get("d2_roof_topology", {}), {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1}, 0.0) \
		and bool(bindings.get("tower_separate_and_unchanged", false)) \
		and bool(bindings.get("collision_ownership_unchanged", false))


func _stills_valid(root_path: String, manifest: Dictionary, stage: String) -> bool:
	if not _common_manifest_valid(manifest, stage) \
	or str(manifest.get("schema_version", "")) != "ti.building-1-wing-returns-v2-candidate-stills/1" \
	or str(manifest.get("proof_role", "")) != "matched_native_grounded_stock_player_A_B_stills_plus_contextual_traversal_and_interaction_closure" \
	or int(manifest.get("capture_count", -1)) != 22 or int(manifest.get("expected_capture_count", -1)) != 22 \
	or not bool(manifest.get("elevated_overview_is_diagnostic_only", false)) \
	or not bool(manifest.get("original_color_pngs_preserved", false)) \
	or not bool(manifest.get("grayscale_derived_from_saved_default_pixels", false)):
		return false
	var lighting := manifest.get("lighting", {}) as Dictionary
	if not _values_close(lighting.get("default_sun_rotation_degrees", []), DEFAULT_SUN, 0.0) \
	or not _values_close(lighting.get("changed_sun_rotation_degrees", []), CHANGED_SUN, 0.0) \
	or not bool(lighting.get("same_pose_changed_light", false)) \
	or not _view_definitions_valid(manifest.get("fixed_view_definitions", []) as Array):
		return false
	var captures := manifest.get("captures", []) as Array
	if captures.size() != 22:
		return false
	var by_id := {}
	for value: Variant in captures:
		var capture := value as Dictionary
		var id := str(capture.get("id", ""))
		if id not in STILL_IDS or by_id.has(id) or not _image_valid(root_path, stage, capture):
			return false
		by_id[id] = capture
	for id in STILL_IDS:
		if not by_id.has(id):
			return false
	for value: Variant in VIEW_DEFINITIONS:
		var definition := value as Dictionary
		var base := str(definition.id)
		var default_capture := by_id[base + "-default"] as Dictionary
		var changed_capture := by_id[base + "-changed"] as Dictionary
		var gray_capture := by_id[base + "-grayscale"] as Dictionary
		if not _ordinary_pose_valid(default_capture, definition.requested_xz as Array, definition.aim_target_m as Array, "building:r16681702:wall", ["r16681702"], DEFAULT_SUN) \
		or not _ordinary_pose_valid(changed_capture, definition.requested_xz as Array, definition.aim_target_m as Array, "building:r16681702:wall", ["r16681702"], CHANGED_SUN) \
		or not bool(changed_capture.get("player_transform_exactly_reused", false)) \
		or not bool(changed_capture.get("camera_transform_exactly_reused", false)) \
		or str(changed_capture.get("same_pose_source_capture", "")) != "images/%s-default.png" % base \
		or not _pose_pair(default_capture, changed_capture, PAIR_FLOAT_TOLERANCE) \
		or not _grayscale_valid(root_path, stage, default_capture, gray_capture):
			return false
	var protected := by_id["06-protected-rear-east"] as Dictionary
	var tower_one := by_id["07-tower-accepted-pose-one"] as Dictionary
	var tower_two := by_id["08-tower-accepted-pose-two"] as Dictionary
	var context := by_id["11-whole-context"] as Dictionary
	if not _ordinary_pose_valid(protected, [76.5, 738.0], [4.0, 16.0, 738.0], "building:r16681702:wall", ["r16681702"], DEFAULT_SUN) \
	or not _ordinary_pose_valid(tower_one, [50.451462, 686.886108], [18.0214996337891, 32.25, 720.648986816406], "building:w1222720021:wall", ["w1222720021"], DEFAULT_SUN, false) \
	or not _ordinary_pose_valid(tower_two, [22.211432, 667.034424], [12.8684997558594, 32.25, 718.990478515625], "building:w1222720021:wall", ["w1222720021"], DEFAULT_SUN, false) \
	or not _ordinary_pose_valid(context, [-120.0, 755.0], [-8.0, 16.0, 737.0], "building:r16681702:wall", ["r16681702"], DEFAULT_SUN):
		return false
	var spray := by_id["09-real-spray-blank-wing-pier"] as Dictionary
	if not _base_color_capture_valid(spray, DEFAULT_SUN) \
	or str(spray.get("spray_result", "")) != "placed" \
	or str(spray.get("spray_controller_route", "")) != "real_SprayController_attempt_spray" \
	or str(spray.get("spray_first_hit_object", "")) != "building:r16681702:wall" \
	or spray.get("spray_first_hit_sources", []) != ["r16681702"] \
	or str(spray.get("targeted_blank_pier_band", "")) != "below_lower_north_wing_window_schedule" \
	or not bool(spray.get("tag_visible_in_tree", false)) \
	or float(spray.get("spray_player_to_hit_distance_m", INF)) > 6.1 \
	or not _values_close(spray.get("requested_xz", []), [-45.4565768570446, 719.3789456714961], PAIR_FLOAT_TOLERANCE) \
	or not _values_close(spray.get("aim_target_m", []), [-46.903, 7.8, 716.5245], PAIR_FLOAT_TOLERANCE):
		return false
	var roof := by_id["10-real-player-main-roof-landing"] as Dictionary
	var support := roof.get("support", {}) as Dictionary
	if not _base_color_capture_valid(roof, DEFAULT_SUN) \
	or not bool(roof.get("real_player_jetpack_route", false)) or roof.get("input_actions", []) != ["jetpack", "move_forward"] \
	or int(roof.get("route_physics_ticks", 0)) <= 0 or int(roof.get("jetpack_pressed_ticks", 0)) <= 0 \
	or int(roof.get("descent_physics_ticks", 0)) <= 0 \
	or int(roof.get("player_transform_writes_after_route_start", -1)) != 0 \
	or int(roof.get("camera_transform_writes_after_route_start", -1)) != 0 \
	or int(roof.get("recovery_delta", -1)) != 0 or not bool(roof.get("roof_landing_world_solid", false)) \
	or float(roof.get("landing_horizontal_error_m", INF)) > 1.25 \
	or not bool(support.get("ok", false)) or str(support.get("object_key", "")) != "building:r16681702:roof" \
	or support.get("source_keys", []) != ["r16681702"] \
	or absf(float((support.get("hit_position_m", [0.0, -INF, 0.0]) as Array)[1]) - 14.75) > 0.03:
		return false
	var diagnostic := by_id["12-elevated-overview-diagnostic-only"] as Dictionary
	return _base_color_capture_valid(diagnostic, DEFAULT_SUN) \
		and bool(diagnostic.get("diagnostic_only", false)) and not bool(diagnostic.get("acceptance_view", true)) \
		and bool(diagnostic.get("real_jetpack_input", false)) and bool(diagnostic.get("airborne", false)) \
		and int(diagnostic.get("player_transform_writes", -1)) == 0 \
		and int(diagnostic.get("camera_transform_writes", -1)) == 0 \
		and int(diagnostic.get("recovery_delta", -1)) == 0


func _stills_pair_valid(left: Dictionary, right: Dictionary) -> bool:
	if not _values_close(left.get("fixed_view_definitions", []), right.get("fixed_view_definitions", []), PAIR_FLOAT_TOLERANCE) \
	or not _values_close(left.get("lighting", {}), right.get("lighting", {}), 0.0):
		return false
	var left_by_id := _by_id(left.get("captures", []) as Array)
	var right_by_id := _by_id(right.get("captures", []) as Array)
	for id in STILL_IDS:
		var a := left_by_id.get(id, {}) as Dictionary
		var b := right_by_id.get(id, {}) as Dictionary
		if a.is_empty() or b.is_empty():
			return false
		if id.ends_with("-grayscale"):
			continue
		for key in ["id", "role", "lighting", "requested_xz", "player_position_m", "camera_position_m", "camera_forward", "aim_target_m", "sun_rotation_degrees", "recovery_delta"]:
			if not _values_close(a.get(key), b.get(key), PAIR_FLOAT_TOLERANCE):
				return false
		if id == "09-real-spray-blank-wing-pier":
			for key in ["spray_result", "spray_controller_route", "spray_first_hit_object", "spray_first_hit_sources", "spray_first_hit_position_m", "tag_position_m"]:
				if not _values_close(a.get(key), b.get(key), PAIR_FLOAT_TOLERANCE):
					return false
		if id == "10-real-player-main-roof-landing":
			for key in ["route_physics_ticks", "jetpack_pressed_ticks", "descent_physics_ticks", "player_position_m", "support", "landing_horizontal_error_m"]:
				if not _values_close(a.get(key), b.get(key), PAIR_FLOAT_TOLERANCE):
					return false
	return true


func _motion_valid(root_path: String, manifest: Dictionary, stage: String, side: String) -> bool:
	if not _common_manifest_valid(manifest, stage) \
	or str(manifest.get("schema_version", "")) != "ti.building-1-wing-returns-v2-candidate-motion/1" \
	or str(manifest.get("side", "")) != side \
	or str(manifest.get("proof_role", "")) != "fixed_60fps_true_stock_controller_60m_to_25m_parallax_shimmer_zfight_motion" \
	or int(manifest.get("fixed_fps_operator_request", -1)) != 60 or int(manifest.get("physics_ticks_per_second", -1)) != 60 \
	or str(manifest.get("input_action", "")) != "move_forward" \
	or bool(manifest.get("run_action_pressed", true)) or bool(manifest.get("jetpack_action_pressed", true)) \
	or int(manifest.get("player_transform_writes_after_motion_start", -1)) != 0 \
	or int(manifest.get("camera_transform_writes_after_motion_start", -1)) != 0 \
	or not bool(manifest.get("camera_basis_unchanged", false)) or int(manifest.get("recovery_delta", -1)) != 0 \
	or not _values_close(manifest.get("thresholds_m", []), [60.0, 45.0, 30.0, 25.0], 0.0) \
	or int(manifest.get("images_per_threshold", -1)) != 3 \
	or not is_equal_approx(float(manifest.get("capture_tolerance_m", -1.0)), POSE_TOLERANCE_M) \
	or not bool(manifest.get("sampler_priority_strictly_after_player", false)) \
	or str(manifest.get("sampler_phase", "")) != "dedicated_node_physics_callback_after_PlayerController" \
	or not bool(manifest.get("png_encoding_deferred_until_after_input_release", false)) \
	or int(manifest.get("capture_count", -1)) != 12:
		return false
	var expected := MOTION_DEFINITIONS[side] as Dictionary
	var trajectory := manifest.get("trajectory", {}) as Dictionary
	if not _values_close(trajectory.get("start_xz", []), expected.start_xz, PAIR_FLOAT_TOLERANCE) \
	or not _values_close(trajectory.get("near_xz", []), expected.near_xz, PAIR_FLOAT_TOLERANCE) \
	or not _values_close(trajectory.get("target_m", []), expected.target_m, PAIR_FLOAT_TOLERANCE) \
	or absf(float(trajectory.get("start_distance_m", -INF)) - 60.0) > 0.05 \
	or absf(float(trajectory.get("near_distance_m", -INF)) - 25.0) > 0.001:
		return false
	var start := manifest.get("motion_start_pose", {}) as Dictionary
	if not _base_pose_valid(start) or not _values_close(start.get("requested_xz", []), expected.start_xz, PAIR_FLOAT_TOLERANCE) \
	or not _values_close(start.get("aim_target_m", []), expected.target_m, PAIR_FLOAT_TOLERANCE):
		return false
	var route_frames := int(manifest.get("route_physics_frames", -1))
	var telemetry := manifest.get("telemetry", []) as Array
	if route_frames <= 0 or telemetry.size() != route_frames:
		return false
	var previous_distance := INF
	var previous_engine_frame := -1
	for index in telemetry.size():
		var sample := telemetry[index] as Dictionary
		var distance := float(sample.get("target_distance_m", INF))
		var engine_frame := int(sample.get("engine_physics_frame", -1))
		if int(sample.get("route_frame", -1)) != index + 1 or not bool(sample.get("grounded", false)) \
		or distance > previous_distance + 0.0001 or engine_frame != previous_engine_frame + 1 and previous_engine_frame >= 0:
			return false
		previous_distance = distance
		previous_engine_frame = engine_frame
	var captures := manifest.get("captures", []) as Array
	if captures.size() != 12:
		return false
	var counts := {60: 0, 45: 0, 30: 0, 25: 0}
	var ids := {}
	for value: Variant in captures:
		var capture := value as Dictionary
		var threshold := int(round(float(capture.get("threshold_m", -1.0))))
		var offset := int(capture.get("sequence_offset", -1))
		var id := str(capture.get("id", ""))
		if not counts.has(threshold) or offset not in [0, 1, 2] \
		or id != "%s-%02dm-%d" % [side, threshold, offset] or ids.has(id) \
		or str(capture.get("side", "")) != side \
		or str(capture.get("file", "")) != "motion/%s/%02dm-%d.png" % [side, threshold, offset] \
		or absf(float(capture.get("actual_distance_m", INF)) - float(threshold)) > POSE_TOLERANCE_M \
		or not bool(capture.get("post_draw_original_pixels", false)) \
		or not _image_valid(root_path, stage, capture):
			return false
		counts[threshold] += 1
		ids[id] = true
	return counts == {60: 3, 45: 3, 30: 3, 25: 3}


func _motion_pair_valid(left: Dictionary, right: Dictionary) -> Dictionary:
	for key in ["side", "trajectory", "motion_start_pose", "fixed_fps_operator_request", "physics_ticks_per_second", "input_action", "thresholds_m", "images_per_threshold", "route_physics_frames", "baseline_sampler_snapshot", "telemetry"]:
		if not _values_close(left.get(key), right.get(key), PAIR_FLOAT_TOLERANCE):
			return _bad("controller field differs: %s" % key)
	var left_captures := left.get("captures", []) as Array
	var right_captures := right.get("captures", []) as Array
	if left_captures.size() != right_captures.size():
		return _bad("capture count differs")
	var max_delta := 0.0
	for index in left_captures.size():
		var a := left_captures[index] as Dictionary
		var b := right_captures[index] as Dictionary
		for key in ["id", "file", "side", "threshold_m", "sequence_offset", "actual_distance_m", "actual_minus_threshold_m", "engine_physics_frame", "sampler_sequence"]:
			if not _values_close(a.get(key), b.get(key), PAIR_FLOAT_TOLERANCE):
				return _bad("motion capture field differs: %s/%s" % [a.get("id", "?"), key])
		var player_delta := _vector_distance(a.get("player_position_m", []) as Array, b.get("player_position_m", []) as Array)
		var camera_delta := _vector_distance(a.get("camera_position_m", []) as Array, b.get("camera_position_m", []) as Array)
		max_delta = maxf(max_delta, maxf(player_delta, camera_delta))
		if player_delta > POSE_TOLERANCE_M or camera_delta > POSE_TOLERANCE_M:
			return _bad("motion capture pose exceeds 0.22m")
	return {"ok": true, "max_pose_delta_m": max_delta}


func _view_definitions_valid(values: Array) -> bool:
	if values.size() != VIEW_DEFINITIONS.size():
		return false
	for index in values.size():
		var actual := values[index] as Dictionary
		var expected := VIEW_DEFINITIONS[index] as Dictionary
		if str(actual.get("id", "")) != str(expected.id) \
		or not _values_close(actual.get("requested_xz", []), expected.requested_xz, PAIR_FLOAT_TOLERANCE) \
		or not _values_close(actual.get("aim_target_m", []), expected.aim_target_m, PAIR_FLOAT_TOLERANCE) \
		or not _values_close(actual.get("default_sun_rotation_degrees", []), DEFAULT_SUN, 0.0) \
		or not _values_close(actual.get("changed_sun_rotation_degrees", []), CHANGED_SUN, 0.0):
			return false
	return true


func _ordinary_pose_valid(capture: Dictionary, requested_xz: Array, target: Array, receiver: String, sources: Array, sun: Array, require_centered_target: bool = true) -> bool:
	var screen_valid := true
	if require_centered_target:
		screen_valid = _values_close(capture.get("aim_target_screen_px", []), [720.0, 450.0], 1.0)
	else:
		var screen := capture.get("aim_target_screen_px", []) as Array
		screen_valid = screen.size() == 2 and float(screen[0]) >= 0.0 and float(screen[0]) <= 1440.0 \
			and float(screen[1]) >= 0.0 and float(screen[1]) <= 900.0
	return screen_valid and _base_color_capture_valid(capture, sun) and _base_pose_valid(capture) \
		and _values_close(capture.get("requested_xz", []), requested_xz, PAIR_FLOAT_TOLERANCE) \
		and _values_close(capture.get("aim_target_m", []), target, PAIR_FLOAT_TOLERANCE) \
		and bool(capture.get("receiver_first_los", false)) \
		and str(capture.get("first_los_hit_receiver", "")) == receiver \
		and capture.get("first_los_hit_source_keys", []) == sources


func _base_pose_valid(capture: Dictionary) -> bool:
	var aim := capture.get("input_aim", {}) as Dictionary
	return bool(capture.get("physics_grounded", false)) \
		and int(capture.get("recovery_delta", -1)) == 0 \
		and float(capture.get("settle_horizontal_drift_m", INF)) <= 0.02 \
		and is_equal_approx(float(capture.get("camera_fov_degrees", -1.0)), 70.0) \
		and is_equal_approx(float(capture.get("configured_spring_length_m", -1.0)), 5.5) \
		and str(aim.get("input_route", "")) == "Input.parse_input_event_to_stock_PlayerCamera" \
		and bool(aim.get("ok", false)) \
		and int(capture.get("player_transform_writes_for_static_pose", -1)) == 1 \
		and int(capture.get("camera_transform_writes", -1)) == 0


func _base_color_capture_valid(capture: Dictionary, sun: Array) -> bool:
	return _values_close(capture.get("dimensions", []), [1440, 900], 0.0) \
		and bool(capture.get("player_visible", false)) and bool(capture.get("stock_player_rig", false)) \
		and not bool(capture.get("debug_labels_visible", true)) and not bool(capture.get("crop_or_postprocess", true)) \
		and not bool(capture.get("source_photography_in_frame", true)) \
		and str(capture.get("visual_verdict", "")) == "pending_independent_bar_raiser_review" \
		and _values_close(capture.get("sun_rotation_degrees", []), sun, PAIR_FLOAT_TOLERANCE)


func _pose_pair(left: Dictionary, right: Dictionary, tolerance: float) -> bool:
	for key in ["requested_xz", "player_position_m", "camera_position_m", "camera_forward", "aim_target_m", "camera_fov_degrees", "configured_spring_length_m"]:
		if not _values_close(left.get(key), right.get(key), tolerance):
			return false
	return true


func _grayscale_valid(root_path: String, stage: String, source: Dictionary, gray: Dictionary) -> bool:
	if str(gray.get("derivation_source", "")) != str(source.get("file", "")) \
	or str(gray.get("derivation_source_sha256", "")) != str(source.get("sha256", "")) \
	or not bool(gray.get("grayscale_only", false)) \
	or not bool(gray.get("derived_byte_for_byte_from_saved_default_pixels", false)) \
	or bool(gray.get("crop_or_postprocess", true)) \
	or str(gray.get("lighting", "")) != "derived_from_world_default":
		return false
	var source_image := Image.load_from_file(root_path.path_join("stages/%s/%s" % [stage, source.file]))
	var gray_image := Image.load_from_file(root_path.path_join("stages/%s/%s" % [stage, gray.file]))
	if source_image == null or gray_image == null or source_image.is_empty() or gray_image.is_empty():
		return false
	source_image.convert(Image.FORMAT_L8)
	gray_image.convert(Image.FORMAT_L8)
	return source_image.get_size() == CAPTURE_SIZE and gray_image.get_size() == CAPTURE_SIZE \
		and source_image.get_data() == gray_image.get_data()


func _image_valid(root_path: String, stage: String, capture: Dictionary) -> bool:
	var relative := str(capture.get("file", ""))
	if relative.is_empty() or relative.is_absolute_path() or relative.contains(".."):
		return false
	var path := root_path.path_join("stages/%s/%s" % [stage, relative])
	if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(capture.get("sha256", "")) \
	or FileAccess.get_file_as_bytes(path).size() != int(capture.get("bytes", -1)):
		return false
	var image := Image.load_from_file(path)
	return image != null and not image.is_empty() and image.get_size() == CAPTURE_SIZE \
		and _values_close(capture.get("dimensions", []), [1440, 900], 0.0)


func _expected_paths() -> Array[String]:
	var paths: Array[String] = []
	for stage in ["baseline", "candidate"]:
		paths.append("stages/%s/stills.json" % stage)
		paths.append("stages/%s/motion-north.json" % stage)
		paths.append("stages/%s/motion-south.json" % stage)
		for id in STILL_IDS:
			paths.append("stages/%s/images/%s.png" % [stage, id])
		for side in ["north", "south"]:
			for threshold in [60, 45, 30, 25]:
				for offset in [0, 1, 2]:
					paths.append("stages/%s/motion/%s/%02dm-%d.png" % [stage, side, threshold, offset])
	paths.sort()
	return paths


func _relative_files(root_path: String) -> Array[String]:
	var result: Array[String] = []
	_collect_files(root_path, "", result)
	result.sort()
	return result


func _collect_files(root_path: String, relative: String, result: Array[String]) -> void:
	var absolute := root_path if relative.is_empty() else root_path.path_join(relative)
	var directory := DirAccess.open(absolute)
	if directory == null:
		return
	directory.list_dir_begin()
	var name := directory.get_next()
	while not name.is_empty():
		if name != "." and name != "..":
			var child := name if relative.is_empty() else relative.path_join(name)
			if directory.current_is_dir():
				_collect_files(root_path, child, result)
			else:
				result.append(child)
		name = directory.get_next()
	directory.list_dir_end()


func _inventory(root_path: String, paths: Array[String]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for relative in paths:
		var path := root_path.path_join(relative)
		if not FileAccess.file_exists(path):
			return []
		result.append({"path": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size()})
	return result


func _contains_absolute_string(value: Variant) -> bool:
	if value is String:
		var text := value as String
		return text.is_absolute_path() or text.begins_with("res://") or text.begins_with("user://")
	if value is Array:
		for child: Variant in value:
			if _contains_absolute_string(child):
				return true
	if value is Dictionary:
		for key: Variant in value:
			if _contains_absolute_string(value[key]):
				return true
	return false


func _by_id(values: Array) -> Dictionary:
	var result := {}
	for value: Variant in values:
		var item := value as Dictionary
		result[str(item.get("id", ""))] = item
	return result


func _values_close(left: Variant, right: Variant, tolerance: float) -> bool:
	if left is Array and right is Array:
		if left.size() != right.size():
			return false
		for index in left.size():
			if not _values_close(left[index], right[index], tolerance):
				return false
		return true
	if left is Dictionary and right is Dictionary:
		if left.size() != right.size():
			return false
		for key: Variant in left:
			if not right.has(key) or not _values_close(left[key], right[key], tolerance):
				return false
		return true
	if left is float or left is int:
		return absf(float(left) - float(right)) <= tolerance
	return left == right


func _vector_distance(left: Array, right: Array) -> float:
	if left.size() != right.size() or left.is_empty():
		return INF
	var sum := 0.0
	for index in left.size():
		sum += pow(float(left[index]) - float(right[index]), 2.0)
	return sqrt(sum)


func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _write_new(path: String, text: String) -> bool:
	if FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	file.close()
	return true


func _sha256_text(text: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(text.to_utf8_buffer())
	return context.finish().hex_encode()


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _bad(message: String) -> Dictionary:
	return {"ok": false, "message": message}


func _fail(message: String) -> void:
	_failed = true
	push_error(message)


func _finish() -> void:
	quit(1 if _failed else 0)
