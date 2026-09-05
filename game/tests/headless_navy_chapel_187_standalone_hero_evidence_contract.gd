extends SceneTree

const OUTPUT := "res://evidence/first-playable/navy-chapel-187-standalone-hero-2026-09-04"
const MANIFEST_PATH := OUTPUT + "/capture-manifest.json"
const CURRENT_REGISTRY := "res://game/resources/facades/facade-runtime-registry.json"
const CURRENT_REGISTRY_SHA256 := "9c46c1a8c809aa9ded82008d35e9c1b257070e9c61f6d6e41f5650ca7b1c3f27"
const CURRENT_LIVE_MANIFEST := "res://evidence/first-playable/navy-chapel-187-live-replacement-2026-09-04/capture-manifest.json"
const CURRENT_LIVE_MANIFEST_SHA256 := "54d434c9283a0e2d86aa836e6a21672a8756e5a170cb5724d66066e799223930"
const CURRENT_LIVE_REVIEW := "res://evidence/first-playable/navy-chapel-187-live-replacement-2026-09-04/INDEPENDENT_LIVE_BAR_RAISER_REVIEW.md"
const CURRENT_LIVE_REVIEW_SHA256 := "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9"
const STANDALONE_REVIEW := OUTPUT + "/INDEPENDENT_BAR_RAISER_REVIEW.md"
const EXPECTED_HASHES := {
	"res://game/tests/navy_chapel_187_standalone_hero_capture.gd": "887842e96b0a4d9fe519b94eae22941def5fd06ec6c11f7bfc81446a3e9ca2c7",
	STANDALONE_REVIEW: "4232ad42b3600b1d7f945c5d51325bb9698c366e07eb1ddea3fd90f3f49235c6",
	MANIFEST_PATH: "a7e551d1bbadaef3ff61f6fbb27e5ac93af3ba997103ddc1dd00041c8229cd28",
	OUTPUT + "/images/01-whole-object-before.png": "2edeaff94139639da514d049f42f94819881c7a421a4dd24f24b1b305ecd4833",
	OUTPUT + "/images/01-whole-object-after.png": "522c649d0766e2bd84999f9b21ee569e53911094e280480db31bff5a340fe0ed",
	OUTPUT + "/images/02-oblique-approach-before.png": "8cff88807fa537c8360b6a314e322b84413e2af1561bf48134efd45211eb0733",
	OUTPUT + "/images/02-oblique-approach-after.png": "b635da683d31f73e3981c1bf21f25690db40640a06771b0e5b5a52425916a9e5",
}
const EXPECTED_CAPTURE_IDS := [
	"01-whole-object-before",
	"01-whole-object-after",
	"02-oblique-approach-before",
	"02-oblique-approach-after",
]
const CONFUSION_SET := ["w291189918", "w291189926", "w34313521"]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(_hashes_match(), "A sealed Chapel evidence generator, manifest, or PNG drifted."):
		_finish()
		return
	var manifest := JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH)) as Dictionary
	if not _require(_manifest_truth_matches(manifest), "The Chapel evidence truth/review boundary, source binding, native provenance, or topology drifted.") \
		or not _require(_captures_match(manifest.get("captures", []) as Array), "A Chapel evidence frame lost native image integrity, grounded provenance, framing, LOS binding, or capture-time pending-review status.") \
		or not _require(_pairs_match(manifest.get("capture_pairs", []) as Array, manifest.get("captures", []) as Array), "A Chapel before/after pair no longer uses the exact same grounded camera/player transform.") \
		or not _require(_current_navy_supersession_matches(), "Current accepted Navy live supersession authority drifted."):
		_finish()
		return
	print("PASS: four sealed native Chapel PNGs remain technically valid fixed-camera grounded before/after evidence with capture-time standalone verdicts pending; the exact independent standalone review subsequently passed with limitation, and the separate current v7 bridge proves Navy Chapel is accepted through the paired live replacement")
	_finish()


func _manifest_truth_matches(manifest: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.navy-chapel-187-standalone-hero-evidence/1" \
		or str(manifest.get("review_status", "")) != "technical_capture_valid_recognition_and_believability_pending_independent_bar_raiser_review" \
		or not bool(manifest.get("recognition_review_prohibited_for_executor", false)) \
		or str(manifest.get("generator", "")) != "game/tests/navy_chapel_187_standalone_hero_capture.gd" \
		or str(manifest.get("generator_sha256", "")) != str(EXPECTED_HASHES["res://game/tests/navy_chapel_187_standalone_hero_capture.gd"]) \
		or str(manifest.get("display_driver", "")) != "macOS" \
		or "Apple M2" not in str(manifest.get("video_adapter", "")) \
		or str(manifest.get("rendering_method", "")) != "Forward+" \
		or str(manifest.get("rendering_driver", "")) != "Metal" \
		or manifest.get("viewport", []) != [1440.0, 900.0]:
		return false
	var target := manifest.get("target", {}) as Dictionary
	var truth := manifest.get("truth_boundary", {}) as Dictionary
	var lighting := manifest.get("lighting", {}) as Dictionary
	var topology := manifest.get("prototype_topology", {}) as Dictionary
	if str(target.get("source_key", "")) != "w291189336" \
		or str(target.get("wall_object_key", "")) != "building:w291189336:wall" \
		or str(target.get("roof_object_key", "")) != "building:w291189336:roof" \
		or str(target.get("geometry_sha256", "")) != "c62a89b238b4831fa2c16e3244c0bffdf17a80ec09498396bc8e582c5c9e696a" \
		or _int_array(target.get("mapped_sse_runs", []) as Array) != [9, 10] \
		or _int_array(target.get("mapped_partial_public_side_runs", []) as Array) != [11, 12, 13] \
		or _int_array(target.get("protected_runs", []) as Array) != [0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33]:
		return false
	if not bool(truth.get("standalone_capture_only", false)) \
		or bool(truth.get("runtime_attachment", true)) \
		or bool(truth.get("recognition_accepted", true)) \
		or bool(truth.get("believability_accepted", true)) \
		or bool(truth.get("as_built_claim", true)) \
		or bool(truth.get("interior_modeled", true)) \
		or str(truth.get("vertical_dimensions_pane_count_and_side_cadence", "")) != "reversible_production_inference" \
		or bool(truth.get("source_photography_stored_or_shown", true)):
		return false
	if manifest.get("confusion_set_source_ids_frozen_before_capture", []) != CONFUSION_SET \
		or (manifest.get("reference_supported_cues_frozen_before_capture", []) as Array).size() != 3 \
		or bool(lighting.get("changed", true)) \
		or not _float_array_approx(lighting.get("sun_rotation_degrees", []) as Array, [-52.0, -28.0, 0.0], 0.001):
		return false
	if int(topology.get("mesh_instances", 0)) != 6 \
		or int(topology.get("surfaces", 0)) != 6 \
		or int(topology.get("visual_triangles", 0)) != 540 \
		or int(topology.get("static_bodies", 0)) != 1 \
		or int(topology.get("shapes", 0)) != 1 \
		or int(topology.get("collision_triangles", 0)) != 144 \
		or str(topology.get("deterministic_signature", "")) != "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46":
		return false
	var instructions := str(manifest.get("reviewer_instruction", "")).to_lower()
	for phrase in ["original detail", "top-1 navy chapel", "confusion set", "at least two", "do not infer acceptance", "reversible production inference", "do not infer an interior", "as-built"]:
		if phrase not in instructions:
			return false
	return true


func _captures_match(captures: Array) -> bool:
	if captures.size() != 4:
		return false
	var ids: Array[String] = []
	for capture_value: Variant in captures:
		var capture := capture_value as Dictionary
		var capture_id := str(capture.get("id", ""))
		ids.append(capture_id)
		var path := OUTPUT.path_join(str(capture.get("file", "")))
		var stage := str(capture.get("stage", ""))
		var expected_receiver := "building:w291189336:wall" if stage == "before" else "prototype:building:w291189336:wall"
		if stage not in ["before", "after"] \
			or str(capture.get("target", "")) != "navy-chapel-187" \
			or str(capture.get("source_identity", "")) != "w291189336" \
			or str(capture.get("recognition_verdict", "")) != "pending_independent_bar_raiser_review" \
			or str(capture.get("believability_verdict", "")) != "pending_independent_bar_raiser_review" \
			or capture.get("confusion_set_source_ids_frozen_before_capture", []) != CONFUSION_SET \
			or capture.get("dimensions", []) != [1440.0, 900.0] \
			or int(capture.get("bytes", 0)) < 100000 \
			or int(capture.get("sample_unique_colors", 0)) < 100 \
			or float(capture.get("sample_luminance_range", 0.0)) < 0.5 \
			or not bool(capture.get("physics_grounded", false)) \
			or not bool(capture.get("ordinary_player_rig", false)) \
			or not bool(capture.get("input_reachable_camera_orientation", false)) \
			or not bool(capture.get("player_visible", false)) \
			or bool(capture.get("debug_labels_visible", true)) \
			or bool(capture.get("source_photography_in_frame", true)) \
			or bool(capture.get("lighting_changed", true)) \
			or not bool(capture.get("full_entity_required_and_in_frame", false)) \
			or not bool(capture.get("target_bounds_fully_in_frame", false)) \
			or int(capture.get("target_bounds_points_behind_camera", -1)) != 0 \
			or float(capture.get("target_projected_width_ratio", 0.0)) < 0.12 \
			or float(capture.get("target_projected_height_ratio", 0.0)) < 0.025 \
			or str(capture.get("first_los_hit_receiver", "")) != expected_receiver \
			or capture.get("first_los_hit_source_keys", []) != ["w291189336"] \
			or int(capture.get("first_los_hit_run_index", -1)) != 9 \
			or float(capture.get("first_los_hit_target_error_m", 1.0)) > 0.001 \
			or str(capture.get("sha256", "")) != FileAccess.get_sha256(path):
			return false
		var hud := capture.get("hud", {}) as Dictionary
		if bool(hud.get("debug_panel_visible", true)) or bool(hud.get("feedback_panel_visible", true)) or bool(hud.get("load_panel_visible", true)) or bool(hud.get("pause_panel_visible", true)) or not bool(hud.get("reticle_visible", false)):
			return false
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900):
			return false
	return ids == EXPECTED_CAPTURE_IDS


func _pairs_match(pairs: Array, captures: Array) -> bool:
	if pairs.size() != 2:
		return false
	var by_id := {}
	for capture_value: Variant in captures:
		var capture := capture_value as Dictionary
		by_id[str(capture.id)] = capture
	for pair_value: Variant in pairs:
		var pair := pair_value as Dictionary
		if not bool(pair.get("camera_transform_exactly_reused", false)) \
			or float(pair.get("camera_translation_error_m", 1.0)) > 0.0001 \
			or float(pair.get("camera_basis_error", 1.0)) > 0.0001 \
			or float(pair.get("player_translation_error_m", 1.0)) > 0.0001:
			return false
		var before := by_id.get(str(pair.get("before_capture_id", "")), {}) as Dictionary
		var after := by_id.get(str(pair.get("after_capture_id", "")), {}) as Dictionary
		if before.is_empty() or after.is_empty() \
			or before.get("camera_position_m", []) != after.get("camera_position_m", []) \
			or before.get("player_position_m", []) != after.get("player_position_m", []) \
			or not bool(after.get("capture_only_prototype_swap", false)) \
			or bool(before.get("capture_only_prototype_swap", true)):
			return false
	return true


func _hashes_match() -> bool:
	for path: String in EXPECTED_HASHES:
		if FileAccess.get_sha256(path) != str(EXPECTED_HASHES[path]):
			push_error("Chapel evidence hash drift: %s expected=%s actual=%s" % [path, str(EXPECTED_HASHES[path]), FileAccess.get_sha256(path)])
			return false
	return true


func _current_navy_supersession_matches() -> bool:
	if FileAccess.get_sha256(CURRENT_REGISTRY) != CURRENT_REGISTRY_SHA256 \
		or FileAccess.get_sha256(CURRENT_LIVE_MANIFEST) != CURRENT_LIVE_MANIFEST_SHA256 \
		or FileAccess.get_sha256(CURRENT_LIVE_REVIEW) != CURRENT_LIVE_REVIEW_SHA256:
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CURRENT_REGISTRY))
	if not parsed is Dictionary:
		return false
	var registry := parsed as Dictionary
	var metric := registry.get("recognition_metric", {}) as Dictionary
	if str(registry.get("schema_version", "")) != "ti.facade-runtime-registry/7" \
		or int(metric.get("numerator", -1)) != 7 or int(metric.get("denominator", -1)) != 213:
		return false
	var unit := _find_by_id(registry.get("units", []) as Array, "unit_id", "physical-building:w291189336")
	var adapter := _find_by_id(registry.get("active_runtime_adapters", []) as Array, "adapter_id", "active-adapter:navy-chapel-187:building:w291189336:wall")
	var claim := unit.get("claim_status", {}) as Dictionary
	var scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if str(claim.get("reference_recognizable", "")) != "accepted" \
		or unit.get("active_runtime_adapter_ids", []) != ["active-adapter:navy-chapel-187:building:w291189336:wall"] \
		or not (unit.get("legacy_adapter_ids", []) as Array).is_empty() \
		or str(adapter.get("receiver_key", "")) != "building:w291189336:wall" \
		or str(adapter.get("runtime_content_mode", "")) != "active_navy_chapel_187_paired_replacement" \
		or str(adapter.get("review_status", "")) != "independent_exact_current_live_pass" \
		or str(adapter.get("review_status_scope", "")) != "runtime_asset_original_detail_provenance_only_not_reference_recognition" \
		or str(adapter.get("recognition_acceptance_authority", "")) != "physical_unit_claim_and_independent_acceptance_record" \
		or str(adapter.get("recognition_acceptance_status", "")) != "accepted" \
		or str(scope.get("coverage", "")) != "whole_direct_wall_receiver" or int(scope.get("run_count", -1)) != 34 \
		or (adapter.get("runtime_assets", []) as Array).size() != 9:
		return false
	for value: Variant in unit.get("acceptance_records", []) as Array:
		var record := value as Dictionary
		if str(record.get("review_id", "")) == "navy-chapel-187-live-replacement-2026-09-04" \
			and str(record.get("review_kind", "")) == "independent_reference_recognition" \
			and str(record.get("status", "")) == "accept" \
			and str(record.get("review_receipt_sha256", "")) == CURRENT_LIVE_REVIEW_SHA256 \
			and str(record.get("evidence_manifest_sha256", "")) == CURRENT_LIVE_MANIFEST_SHA256:
			return true
	return false


func _find_by_id(values: Array, key: String, expected: String) -> Dictionary:
	for value: Variant in values:
		var item := value as Dictionary
		if str(item.get(key, "")) == expected:
			return item
	return {}


func _float_array_approx(actual: Array, expected: Array, tolerance: float) -> bool:
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


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
