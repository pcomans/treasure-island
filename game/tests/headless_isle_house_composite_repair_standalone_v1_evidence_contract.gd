extends SceneTree

const OUTPUT := "res://evidence/first-playable/isle-house-composite-repair-standalone-v1-2026-09-04"
const CAPTURE_MANIFEST := OUTPUT + "/capture-manifest.json"
const MOTION_MANIFEST := OUTPUT + "/motion-capture.json"
const MOVIE := OUTPUT + "/isle-house-composite-repair-public-corner-stock-walk.avi"
const FACTORY := "res://game/scripts/world/facades/isle_house_composite_repair_standalone_v1.gd"
const CONFIG := "res://game/resources/facades/isle_house_composite_repair_standalone_v1.json"
const SCENE := "res://game/scenes/world/facades/isle_house/isle_house_composite_repair_standalone_v1.tscn"
const LANDSCAPE_MATERIAL := "res://game/resources/materials/world/isle_house/isle_house_low_landscape_proxy.tres"
const CAPTURE_HARNESS := "res://game/tests/isle_house_composite_repair_standalone_v1_capture.gd"
const STANDALONE_REVIEW := OUTPUT + "/INDEPENDENT_BAR_RAISER_REVIEW.md"
const CURRENT_REGISTRY := "res://game/resources/facades/facade-runtime-registry.json"
const CURRENT_REGISTRY_SHA256 := "9c46c1a8c809aa9ded82008d35e9c1b257070e9c61f6d6e41f5650ca7b1c3f27"
const CURRENT_LIVE_MANIFEST := "res://evidence/first-playable/isle-house-composite-repair-variant-c-live-replacement-2026-09-04/capture-manifest.json"
const CURRENT_LIVE_MANIFEST_SHA256 := "23fd6eff4ab8d9696af9d1ecc19bea50537cc824ecf3a7bebdf4fa191cd039d9"
const CURRENT_LIVE_REVIEW := "res://evidence/first-playable/isle-house-composite-repair-variant-c-live-replacement-2026-09-04/INDEPENDENT_LIVE_BAR_RAISER_REVIEW.md"
const CURRENT_LIVE_REVIEW_SHA256 := "37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8"
const HIGH_WALL_KEY := "building-composite:w1249412094:w1282547786:wall"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const FAILED_SIGNATURE := "5d61ab90e5b798ac4aa26c45fea37a5293f3083dada615f06999faad459112cc"
const REPAIR_SIGNATURE := "a58d9b963b0dc19b5a9fa1cba4872294a2ea2803459a9ba455e276dc1ff5b5bf"
const HIGH_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const EXPECTED_HASHES := {
	FACTORY: "b23d9cb3acbedacb323197fd38660f45b13e532dd11c1cca1fafe785338037d8",
	CONFIG: "a3e1865d18cfbb4155cf01df3b5eb265ca67e4ee80acfc07986c84d0cd7db393",
	SCENE: "e16cd72955169e199f7631677f09e75441bea143c4f1b39d08e2409aaefdbb9a",
	LANDSCAPE_MATERIAL: "534cb523b48639e87ec365b120b793a6ddca819e4b09ae590a592fc63d1a010f",
	CAPTURE_HARNESS: "8b02a4f5e2e706da518291e64708cac6ed6bd85b1c1b7eeb20a8adeaac638a8c",
	STANDALONE_REVIEW: "a5dd6b61a0adc25ad8d10879fcd342870ae11c71b18f52892287685ced36cad8",
	CAPTURE_MANIFEST: "bc3faff8b764fe6f3a287a26360a0788c73dac577f4e84aab7ca2391a9c49d6b",
	MOTION_MANIFEST: "3d1cd3c49556e123ab865fd649a912d24085b7efbb7c009171bc70c6ad80effb",
	MOVIE: "18bebf8f60f2c8a201f7ad7f8d392da6edd6c820dd1a8eee261d5af1d39031b0",
	OUTPUT + "/images/wsw-public-whole-composite-a-failed-parent.png": "950c01ef95bc0c11755f2fba183678e8da38240094876ca7f63ced5a1a5edfaa",
	OUTPUT + "/images/wsw-public-whole-composite-b-repair.png": "3affc5fed86500b8cd4327012081b5cbb392cf6a639a3257dba9a8ee64e4a46f",
	OUTPUT + "/images/wsw-public-whole-composite-b-repair-changed-light.png": "38e7e3966456df55485427dbab8e5086918cdeed66824d8147bd35d71c888311",
	OUTPUT + "/images/wsw-public-oblique-whole-composite-a-failed-parent.png": "0475b9963835a3813c2fb14fbd83a8dd599ff4a02058bb3a72704c0ce5b742b5",
	OUTPUT + "/images/wsw-public-oblique-whole-composite-b-repair.png": "609e36bf3056b998186cb79ffe0227c1f6f0231d3a48737877bc3a5bd582d050",
	OUTPUT + "/images/wsw-public-oblique-whole-composite-b-repair-changed-light.png": "cb6130f3c3d8471218f270bcaf1c13013ee72a38bf38a5f4bfa93ee495c5e3d7",
	OUTPUT + "/images/ene-public-low-detail-a-failed-parent.png": "b7253c2145982a1e05e1b905e2953dfdb684025b3df7683c747ec7d46e5617a2",
	OUTPUT + "/images/ene-public-low-detail-b-repair.png": "cdbb596656882419c12459d67ef919a2558366d9beaca9fb2478c665aeceaf14",
	OUTPUT + "/images/ene-public-low-detail-b-repair-changed-light.png": "f76c05f8217de2831dc0730084ccdb1c5a7f10f6ba9240f05ea60252c66249e7",
}
const EXPECTED_IDS := [
	"wsw-public-whole-composite-a-failed-parent",
	"wsw-public-whole-composite-b-repair",
	"wsw-public-whole-composite-b-repair-changed-light",
	"wsw-public-oblique-whole-composite-a-failed-parent",
	"wsw-public-oblique-whole-composite-b-repair",
	"wsw-public-oblique-whole-composite-b-repair-changed-light",
	"ene-public-low-detail-a-failed-parent",
	"ene-public-low-detail-b-repair",
	"ene-public-low-detail-b-repair-changed-light",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(_hashes_match(), "A sealed standalone Isle House source/evidence artifact drifted.")
	var capture := _json(CAPTURE_MANIFEST)
	var motion := _json(MOTION_MANIFEST)
	_require(_capture_manifest_matches(capture), "Standalone Isle House still manifest lost its native, truth-bound, or whole-composite contract.")
	_require(_captures_match(capture.get("captures", []) as Array), "A standalone Isle House still lost its exact pixels, grounded provenance, A/B pairing, LOS, framing, or capture-time pending-review state.")
	_require(_motion_matches(motion), "Standalone Isle House continuous-motion evidence lost its grounded stock-player, exact movie, or capture-time pending-review contract.")
	_require(_current_isle_supersession_matches(), "Current accepted Variant-C supersession authority drifted.")
	if not _failed:
		print("PASS: nine sealed native standalone Isle House A/B/changed-light PNGs and one 222-frame grounded stock-player movie remain technically valid with capture-time standalone verdicts pending; the exact independent standalone review subsequently failed Variant B, while the separate current v7 bridge proves the Isle physical unit is accepted through the later Variant-C live supersession")
	quit(1 if _failed else 0)


func _capture_manifest_matches(manifest: Dictionary) -> bool:
	var bindings := manifest.get("bindings", {}) as Dictionary
	var runtime := manifest.get("current_failed_parent_runtime_topology", {}) as Dictionary
	var delta := manifest.get("detached_preview_delta", {}) as Dictionary
	var provenance := manifest.get("provenance_and_nonclaims", {}) as Dictionary
	return str(manifest.get("schema_version", "")) == "ti.isle-house-composite-repair-standalone-evidence/1" \
		and str(manifest.get("review_status", "")) == "pending_independent_review_not_self_accepted" \
		and str(manifest.get("recognition_status", "")) == "pending_independent_review" \
		and str(manifest.get("believability_status", "")) == "pending_independent_review" \
		and str(manifest.get("generator_sha256", "")) == str(EXPECTED_HASHES[CAPTURE_HARNESS]) \
		and str(manifest.get("factory_sha256", "")) == str(EXPECTED_HASHES[FACTORY]) \
		and str(manifest.get("config_sha256", "")) == str(EXPECTED_HASHES[CONFIG]) \
		and str(manifest.get("display_driver", "")) == "macOS" \
		and "Apple M2" in str(manifest.get("video_adapter", "")) \
		and manifest.get("viewport", []) == [1440.0, 900.0] \
		and int(manifest.get("capture_count", 0)) == 9 \
		and int(manifest.get("same_pose_pairs", 0)) == 3 \
		and int(manifest.get("whole_composite_same_pose_pairs", 0)) == 2 \
		and int(manifest.get("supplemental_ENE_low_detail_pairs", 0)) == 1 \
		and int(manifest.get("changed_light_frames", 0)) == 3 \
		and bindings.get("low_receiver_source_keys", []) == ["w1282547787"] \
		and bindings.get("high_receiver_source_keys", []) == ["w1282547786"] \
		and str(bindings.get("failed_live_signature", "")) == FAILED_SIGNATURE \
		and str(bindings.get("repair_signature", "")) == REPAIR_SIGNATURE \
		and str(bindings.get("accepted_high_signature", "")) == HIGH_SIGNATURE \
		and _topology_matches(bindings.get("candidate_topology", {}) as Dictionary, 6, 8, 2316) \
		and bool(bindings.get("underlying_wall_remains_sole_collision_and_spray_receiver", false)) \
		and bool(bindings.get("standalone_only", false)) \
		and not bool(bindings.get("live_replacement", true)) \
		and not bool(bindings.get("recognition_accepted", true)) \
		and not bool(bindings.get("believability_accepted", true)) \
		and _runtime_matches(runtime, 735, 938, 948, 63720, 466, 466) \
		and _runtime_matches(delta, -1, 6, 8, 2316, 0, 0) \
		and (provenance.get("observed_family", []) as Array).size() == 6 \
		and (provenance.get("production_inference", []) as Array).size() == 10 \
		and "recognition" in (provenance.get("not_claimed", []) as Array) \
		and "live promotion" in (provenance.get("not_claimed", []) as Array) \
		and not bool(manifest.get("source_photography_shipped", true)) \
		and not bool(manifest.get("source_urls_in_runtime", true)) \
		and str(manifest.get("visual_verdict", "")) == "pending_independent_review"


func _captures_match(captures: Array) -> bool:
	if captures.size() != 9:
		return false
	var ids: Array[String] = []
	var by_id: Dictionary = {}
	for value: Variant in captures:
		var capture := value as Dictionary
		var id := str(capture.get("id", ""))
		ids.append(id)
		by_id[id] = capture
		var path := OUTPUT.path_join(str(capture.get("file", "")))
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900) \
		or str(capture.get("sha256", "")) != FileAccess.get_sha256(path) \
		or int(capture.get("bytes", 0)) < 100000 \
		or int(capture.get("sample_unique_colors", 0)) < 8 \
		or float(capture.get("sample_luminance_range", 0.0)) < 0.1 \
		or not bool(capture.get("physics_grounded", false)) \
		or not bool(capture.get("ordinary_player_rig", false)) \
		or not bool(capture.get("input_reachable_camera_orientation", false)) \
		or bool(capture.get("debug_labels_visible", true)) \
		or bool(capture.get("source_photography_in_frame", true)) \
		or bool(capture.get("crop_or_postprocess", true)) \
		or str(capture.get("visual_verdict", "")) != "pending_independent_review" \
		or not bool(capture.get("pair_camera_transform_equal", false)):
			return false
	var pair_prefixes := ["wsw-public-whole-composite", "wsw-public-oblique-whole-composite", "ene-public-low-detail"]
	for prefix: String in pair_prefixes:
		var a := by_id.get(prefix + "-a-failed-parent", {}) as Dictionary
		var b := by_id.get(prefix + "-b-repair", {}) as Dictionary
		var light := by_id.get(prefix + "-b-repair-changed-light", {}) as Dictionary
		if a.is_empty() or b.is_empty() or light.is_empty() \
		or a.get("camera_position_m", []) != b.get("camera_position_m", []) \
		or a.get("player_position_m", []) != b.get("player_position_m", []) \
		or a.get("projection", {}) != b.get("projection", {}) \
		or a.get("camera_position_m", []) != light.get("camera_position_m", []) \
		or str(a.get("variant", "")) != "failed_parent" \
		or str(b.get("variant", "")) != "repair" \
		or str(light.get("variant", "")) != "repair" \
		or str(a.get("lighting", "")) != "world_default" \
		or str(light.get("lighting", "")) != "frozen_changed_light":
			return false
	for prefix: String in pair_prefixes.slice(0, 2):
		var whole := by_id[prefix + "-b-repair"] as Dictionary
		var projection := whole.get("projection", {}) as Dictionary
		var high := projection.get("high", {}) as Dictionary
		var low := projection.get("low", {}) as Dictionary
		if str(whole.get("first_los_hit_receiver", "")) != HIGH_WALL_KEY \
		or whole.get("first_los_hit_source_keys", []) != ["w1282547786"] \
		or float(high.get("clipped_height_px", 0.0)) < 260.0 \
		or float(high.get("clipped_area_fraction", 0.0)) < 0.05 \
		or float(low.get("clipped_height_px", 0.0)) < 70.0 \
		or float(low.get("clipped_area_fraction", 0.0)) < 0.018 \
		or float(projection.get("union_area_fraction", 1.0)) > 0.82 \
		or bool(whole.get("supplemental_detail_not_whole_acceptance_view", false)):
			return false
	for suffix: String in ["a-failed-parent", "b-repair", "b-repair-changed-light"]:
		var detail := by_id["ene-public-low-detail-" + suffix] as Dictionary
		if not bool(detail.get("supplemental_detail_not_whole_acceptance_view", false)) \
		or str(detail.get("first_los_hit_receiver", "")) != LOW_WALL_KEY \
		or detail.get("first_los_hit_source_keys", []) != ["w1282547787"]:
			return false
	return ids == EXPECTED_IDS


func _motion_matches(motion: Dictionary) -> bool:
	var bindings := motion.get("bindings", {}) as Dictionary
	var samples := motion.get("samples", []) as Array
	if str(motion.get("schema_version", "")) != "ti.isle-house-composite-repair-standalone-motion-evidence/1" \
	or str(motion.get("review_status", "")) != "pending_independent_review_not_self_accepted" \
	or str(motion.get("generator_sha256", "")) != str(EXPECTED_HASHES[CAPTURE_HARNESS]) \
	or str(motion.get("factory_sha256", "")) != str(EXPECTED_HASHES[FACTORY]) \
	or str(motion.get("config_sha256", "")) != str(EXPECTED_HASHES[CONFIG]) \
	or str(motion.get("movie_sha256", "")) != str(EXPECTED_HASHES[MOVIE]) \
	or int(motion.get("movie_bytes", 0)) != 18648756 \
	or int(motion.get("movie_total_frames_expected_after_close", 0)) != 222 \
	or not bool(motion.get("movie_finalized_after_writer_close", false)) \
	or motion.get("movie_dimensions", []) != [1280.0, 800.0] \
	or int(motion.get("fixed_fps", 0)) != 30 \
	or int(motion.get("physics_ticks_per_second", 0)) != 60 \
	or int(motion.get("motion_physics_frames", 0)) != 300 \
	or not is_equal_approx(float(motion.get("continuous_duration_seconds", 0.0)), 5.0) \
	or absf(float(motion.get("horizontal_displacement_m", 0.0)) - 19.8834915161133) > 0.0001 \
	or float(motion.get("start_along_from_corner_m", 0.0)) >= -7.0 \
	or float(motion.get("end_along_from_corner_m", 0.0)) <= 10.0 \
	or float(motion.get("direction_dot_public_tangent", 0.0)) <= 0.999 \
	or int(motion.get("player_transform_writes_after_input_began", -1)) != 0 \
	or bool(motion.get("camera_orientation_changed_during_motion", true)) \
	or not bool(motion.get("all_samples_grounded", false)) \
	or int(motion.get("recovery_delta", -1)) != 0 \
	or samples.size() != 300 \
	or str(bindings.get("repair_signature", "")) != REPAIR_SIGNATURE \
	or not bool(bindings.get("standalone_only", false)) \
	or bool(bindings.get("live_replacement", true)):
		return false
	for index in samples.size():
		var sample := samples[index] as Dictionary
		if int(sample.get("frame", 0)) != index + 1 or not bool(sample.get("is_on_floor", false)):
			return false
	return true


func _topology_matches(actual: Dictionary, meshes: int, surfaces: int, triangles: int) -> bool:
	return int(actual.get("mesh_instances", -1)) == meshes \
		and int(actual.get("surfaces", -1)) == surfaces \
		and int(actual.get("triangles", -1)) == triangles


func _runtime_matches(actual: Dictionary, rows: int, meshes: int, surfaces: int, triangles: int, bodies: int, shapes: int) -> bool:
	return (rows < 0 or int(actual.get("rows", -1)) == rows) \
		and int(actual.get("meshes", -1)) == meshes \
		and int(actual.get("surfaces", -1)) == surfaces \
		and int(actual.get("triangles", -1)) == triangles \
		and int(actual.get("bodies", -1)) == bodies \
		and int(actual.get("shapes", -1)) == shapes


func _hashes_match() -> bool:
	for path: String in EXPECTED_HASHES:
		if FileAccess.get_sha256(path) != str(EXPECTED_HASHES[path]):
			push_error("Standalone Isle House evidence hash drift: %s expected=%s actual=%s" % [path, str(EXPECTED_HASHES[path]), FileAccess.get_sha256(path)])
			return false
	return true


func _current_isle_supersession_matches() -> bool:
	if FileAccess.get_sha256(CURRENT_REGISTRY) != CURRENT_REGISTRY_SHA256 \
		or FileAccess.get_sha256(CURRENT_LIVE_MANIFEST) != CURRENT_LIVE_MANIFEST_SHA256 \
		or FileAccess.get_sha256(CURRENT_LIVE_REVIEW) != CURRENT_LIVE_REVIEW_SHA256:
		return false
	var registry := _json(CURRENT_REGISTRY)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	if str(registry.get("schema_version", "")) != "ti.facade-runtime-registry/7" \
		or int(metric.get("numerator", -1)) != 7 or int(metric.get("denominator", -1)) != 213:
		return false
	var unit := _find_by_id(registry.get("units", []) as Array, "unit_id", "physical-building:w1249412094")
	var adapter := _find_by_id(registry.get("active_runtime_adapters", []) as Array, "adapter_id", "active-adapter:isle-house-variant-c:building-composite:w1249412094:w1282547787:wall")
	var claim := unit.get("claim_status", {}) as Dictionary
	var scope := adapter.get("active_receiver_scope", {}) as Dictionary
	return str(claim.get("reference_recognizable", "")) == "accepted" \
		and unit.get("active_runtime_adapter_ids", []) == ["active-adapter:isle-house-variant-c:building-composite:w1249412094:w1282547787:wall"] \
		and unit.get("legacy_adapter_ids", []) == ["legacy-adapter:building-composite:w1249412094:w1282547786:wall"] \
		and str(adapter.get("receiver_key", "")) == LOW_WALL_KEY \
		and str(adapter.get("review_status", "")) == "independent_exact_current_live_pass" \
		and str(adapter.get("review_status_scope", "")) == "runtime_asset_original_detail_provenance_only_not_reference_recognition" \
		and str(adapter.get("recognition_acceptance_authority", "")) == "physical_unit_claim_and_independent_acceptance_record" \
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted" \
		and str(scope.get("coverage", "")) == "whole_direct_wall_receiver" and int(scope.get("run_count", -1)) == 13 \
		and _has_receipt(unit, "isle-house-variant-c-live-replacement-2026-09-04", CURRENT_LIVE_REVIEW_SHA256, CURRENT_LIVE_MANIFEST_SHA256)


func _find_by_id(values: Array, key: String, expected: String) -> Dictionary:
	for value: Variant in values:
		var item := value as Dictionary
		if str(item.get(key, "")) == expected:
			return item
	return {}


func _has_receipt(unit: Dictionary, review_id: String, receipt: String, manifest: String) -> bool:
	for value: Variant in unit.get("acceptance_records", []) as Array:
		var record := value as Dictionary
		if str(record.get("review_id", "")) == review_id \
			and str(record.get("review_kind", "")) == "independent_reference_recognition" \
			and str(record.get("status", "")) == "accept" \
			and str(record.get("review_receipt_sha256", "")) == receipt \
			and str(record.get("evidence_manifest_sha256", "")) == manifest:
			return true
	return false


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ISLE_COMPOSITE_REPAIR_EVIDENCE_FAIL: %s" % message)
	return false
