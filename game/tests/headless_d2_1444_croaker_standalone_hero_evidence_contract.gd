extends SceneTree

const OUTPUT := "res://evidence/first-playable/d2-1444-croaker-standalone-hero-2026-09-04"
const MANIFEST_PATH := OUTPUT + "/capture-manifest.json"
const MOTION_PATH := OUTPUT + "/motion-capture.json"
const MOVIE_PATH := OUTPUT + "/d2-1444-croaker-wsw-stock-walk.avi"
const REVIEW_SHEET_PATH := OUTPUT + "/images/d2-1444-croaker-wsw-motion-review-sheet.png"
const GENERATOR_PATH := "res://game/tests/d2_1444_croaker_standalone_hero_capture.gd"
const HISTORICAL_GENERATOR_SHA256 := "ab84d82ac513b322b3813580aabf73765029cbe3003831a15de250202d57df6c"
const HISTORICAL_CHANGED_INPUT_HASHES := {
	"res://game/resources/facades/d2_1444_croaker_standalone_hero_prototype.json": "fe5cb77ceccadf02c4dac28d82d8b35dc00a4a5a3bac69629558ccaa61cb5c29",
	"res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres": "5cb6000c2ab04a63db92986a02dce4877dc886c6619fa9bef8ed2f7958ead9c3",
}
const EXPECTED_IMAGES := {
	"01-whole-wsw-before": "c14f3a488eab5e4ce462e38c52fa88514b70efeaeccc65dcdc46b3919e314fc7",
	"01-whole-wsw-after": "aeb4f250d9a31d64cbfa658077f25c5419bd380485688aa178fba12e62a59ca3",
	"02-wsw-oblique-before": "f057942bdd593882e1f0f79a839b6195672a7c2149203d2466e251d3ffcda48d",
	"02-wsw-oblique-after": "3a3a21ceed524810f1cd320232d4420d108b6eae9cda76a2159d2886725b18e0",
	"03-wsw-oblique-changed-light-before": "e664a8dc86c94f59874de8dc9d68de71f66a3a8b5c0e2935996a27430d73e693",
	"03-wsw-oblique-changed-light-after": "d850afbba4f6b51bcfe74b7b1a9002554cbcc307cd911b44f5abeb28d2df66c9",
}
const EXPECTED_MOVIE_SHA256 := "3afe7d57f60d8c2b7330f49fa3bc414d915404a23ea774778407fa58710770b4"
const EXPECTED_MOVIE_BYTES := 6078080
const EXPECTED_REVIEW_SHEET_SHA256 := "63aada9bd3ec5f489f4930d46b80bfc41955efc4db449c8c7e7f17618661eefb"
const EXPECTED_SIGNATURE := "8df0202796d56c019b6b3ddb72916808b72316d2d0edee0ba7425b77efa2b127"
const MAPPED_RUNS := [8, 9, 11, 12, 15, 16, 17]
const PROTECTED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 10, 13, 14, 18, 19, 20, 21]
const CONFUSION_SET := ["w95934135", "w95934137", "w95934120"]
const EXPECTED_BATCH_TRIANGLES := {
	"ProtectedExactWallRuns": 30,
	"MappedWSWExactOchreStuccoWallRuns": 14,
	"ExactPlanShallowGableRoof": 10,
	"MappedWSWBroadEaves": 84,
	"BlankEndUndercroftOpaqueShadow": 24,
	"BlankEndUndercroftOchreFrame": 60,
	"SparseReturnOpaqueOpenings": 72,
	"SparseReturnOchreOpeningFrames": 360,
	"FarEndRecessedTwoLevelOpaqueVoids": 24,
	"FarEndBalconyOchreSlabs": 24,
	"FarEndSimpleMetalRails": 96,
}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manifest := _json(MANIFEST_PATH)
	var motion := _json(MOTION_PATH)
	_require(_manifest_truth_matches(manifest), "1444 still evidence truth/source/topology contract drifted.")
	_require(_hashes_match_historical(manifest.get("pinned_inputs", {}) as Dictionary, 14), "1444 still historical package/source pins drifted.")
	_require(_hashes_match_current(manifest.get("capture_fixture_inputs", {}) as Dictionary, 8), "1444 still stock-player fixture pins drifted.")
	_require(_captures_match(manifest.get("captures", []) as Array), "1444 still files, grounding, framing, or receiver bindings drifted.")
	_require(_pairs_match(manifest.get("capture_pairs", []) as Array, manifest.get("captures", []) as Array), "1444 same-pose pair contract drifted.")
	_require(_motion_matches(motion, manifest), "1444 continuous stock-player motion contract drifted.")
	_finish()


func _manifest_truth_matches(manifest: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.d2-1444-croaker-standalone-hero-evidence/1" \
	or str(manifest.get("review_status", "")) != "technical_capture_valid_recognition_and_believability_pending_independent_bar_raiser_review" \
	or not bool(manifest.get("technical_self_check_only", false)) \
	or str(manifest.get("visual_verdict", "")) != "pending_independent_bar_raiser_review" \
	or str(manifest.get("generator_sha256", "")) != HISTORICAL_GENERATOR_SHA256:
		return false
	var target := manifest.get("target", {}) as Dictionary
	var truth := manifest.get("truth_boundary", {}) as Dictionary
	var fixture := manifest.get("capture_fixture_contract", {}) as Dictionary
	var topology := manifest.get("prototype_topology", {}) as Dictionary
	return str(target.get("canonical_name", "")) == "1444 Croaker Court" \
		and str(target.get("source_key", "")) == "w95934117" \
		and str(target.get("wall_object_key", "")) == "building:w95934117:wall" \
		and str(target.get("roof_object_key", "")) == "building:w95934117:roof" \
		and str(target.get("source_geometry_sha256", "")) == "52c844ec3cbeae52b97e12014dac8761c8518b6b4e5ce6df5eeee64256eadcc4" \
		and str(target.get("wall_record_sha256", "")) == "1497487d53fc7eeb98f8399fd8fc47c159c2652e68a486ce496b860fddcfffb6" \
		and str(target.get("roof_record_sha256", "")) == "a4e69552758e9f2927c40a5d4021c8b4cd7dcf7c065f3b78c235219e4fe0eb7a" \
		and _int_array(target.get("mapped_public_wsw_runs", []) as Array) == MAPPED_RUNS \
		and _int_array(target.get("protected_runs", []) as Array) == PROTECTED_RUNS \
		and bool(truth.get("standalone_capture_only", false)) \
		and bool(truth.get("isolated_neutral_ground_fixture", false)) \
		and not bool(truth.get("live_world_loaded", true)) \
		and not bool(truth.get("runtime_attachment", true)) \
		and not bool(truth.get("recognition_accepted", true)) \
		and not bool(truth.get("believability_accepted", true)) \
		and not bool(truth.get("as_built_claim", true)) \
		and not bool(truth.get("interior_modeled", true)) \
		and not bool(truth.get("source_photography_stored_or_shown", true)) \
		and not bool(truth.get("protected_runs_have_modules", true)) \
		and not bool(truth.get("fallback_collider_retained", true)) \
		and manifest.get("confusion_set_source_ids_frozen_before_capture", []) == CONFUSION_SET \
		and (manifest.get("reference_supported_cues_frozen_before_capture", []) as Array).size() == 3 \
		and bool(fixture.get("isolated_neutral_ground", false)) \
		and not bool(fixture.get("live_world_loaded", true)) \
		and int(fixture.get("exact_source_wall_triangles", -1)) == 44 \
		and int(fixture.get("exact_flat_source_roof_triangles", -1)) == 10 \
		and int(fixture.get("baseline_collision_triangles", -1)) == 54 \
		and int(topology.get("mesh_instances", -1)) == 11 \
		and int(topology.get("surfaces", -1)) == 11 \
		and int(topology.get("visual_triangles", -1)) == 798 \
		and _batch_triangles_match(topology.get("visual_batch_triangles", {}) as Dictionary) \
		and int(topology.get("static_bodies", -1)) == 1 \
		and int(topology.get("shapes", -1)) == 1 \
		and int(topology.get("collision_triangles", -1)) == 54 \
		and str(topology.get("deterministic_signature", "")) == EXPECTED_SIGNATURE \
		and int(topology.get("undercroft_void_count", -1)) == 2 \
		and int(topology.get("undercroft_pier_count", -1)) == 3 \
		and int(topology.get("sparse_opening_count", -1)) == 6 \
		and int(topology.get("balcony_void_count", -1)) == 2 \
		and int(topology.get("rail_picket_count", -1)) == 4 \
		and int(topology.get("mapped_eave_count", -1)) == 7


func _captures_match(captures: Array) -> bool:
	if captures.size() != EXPECTED_IMAGES.size():
		return false
	var seen := {}
	for value: Variant in captures:
		var capture := value as Dictionary
		var id := str(capture.get("id", ""))
		if not EXPECTED_IMAGES.has(id) or seen.has(id):
			return false
		seen[id] = true
		var path := OUTPUT.path_join(str(capture.get("file", "")))
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		var expected_after := id.ends_with("-after")
		var expected_run := 8 if id.begins_with("01-") else 9
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900) \
		or FileAccess.get_sha256(path) != str(EXPECTED_IMAGES[id]) \
		or str(capture.get("sha256", "")) != str(EXPECTED_IMAGES[id]) \
		or not bool(capture.get("physics_grounded", false)) \
		or not bool(capture.get("ordinary_player_rig", false)) \
		or not bool(capture.get("input_reachable_camera_orientation", false)) \
		or not bool(capture.get("player_visible", false)) \
		or not bool(capture.get("full_entity_required_and_in_frame", false)) \
		or not bool(capture.get("target_bounds_fully_in_frame", false)) \
		or bool(capture.get("source_photography_in_frame", true)) \
		or bool(capture.get("debug_labels_visible", true)) \
		or str(capture.get("ground_feature", "")) != "capture_neutral_ground" \
		or str(capture.get("ground_object", "")) != "capture-only:neutral-ground" \
		or not (capture.get("ground_sources", []) as Array).is_empty() \
		or str(capture.get("recognition_verdict", "")) != "pending_independent_bar_raiser_review" \
		or str(capture.get("believability_verdict", "")) != "pending_independent_bar_raiser_review" \
		or float(capture.get("target_projected_width_ratio", 0.0)) < 0.12 \
		or float(capture.get("target_projected_height_ratio", 0.0)) < 0.035 \
		or absf(float(capture.get("ground_clearance_m", 1.0))) > 0.08 \
		or float(capture.get("settle_horizontal_drift_m", 1.0)) > 0.05 \
		or int(capture.get("settle_recovery_delta", 1)) != 0 \
		or not bool(capture.get("receiver_source_run_first_los", false)) \
		or int(capture.get("first_los_hit_run_index", -1)) != expected_run \
		or bool(capture.get("capture_only_prototype_swap", not expected_after)) != expected_after:
			return false
		if expected_after and str(capture.get("first_los_hit_receiver", "")) != "prototype:building:w95934117:wall":
			return false
		if not expected_after and str(capture.get("first_los_hit_receiver", "")) != "building:w95934117:wall":
			return false
		var should_change_light := id.begins_with("03-")
		if bool(capture.get("lighting_changed", not should_change_light)) != should_change_light:
			return false
	return seen.size() == EXPECTED_IMAGES.size()


func _pairs_match(pairs: Array, captures: Array) -> bool:
	if pairs.size() != 3:
		return false
	var by_id := {}
	for value: Variant in captures:
		var capture := value as Dictionary
		by_id[str(capture.get("id", ""))] = capture
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
		or before.get("player_position_m", []) != after.get("player_position_m", []) \
		or before.get("camera_position_m", []) != after.get("camera_position_m", []) \
		or before.get("requested_xz", []) != after.get("requested_xz", []):
			return false
	return true


func _motion_matches(motion: Dictionary, manifest: Dictionary) -> bool:
	if str(motion.get("schema_version", "")) != "ti.d2-1444-croaker-standalone-motion-evidence/1" \
	or str(motion.get("review_status", "")) != "technical_motion_valid_visual_review_pending" \
	or str(motion.get("visual_verdict", "")) != "pending_independent_bar_raiser_review" \
	or str(motion.get("generator_sha256", "")) != HISTORICAL_GENERATOR_SHA256 \
	or motion.get("package_hashes", {}) != manifest.get("pinned_inputs", {}) \
	or motion.get("capture_fixture_inputs", {}) != manifest.get("capture_fixture_inputs", {}) \
	or str(motion.get("movie_sha256", "")) != EXPECTED_MOVIE_SHA256 \
	or FileAccess.get_sha256(MOVIE_PATH) != EXPECTED_MOVIE_SHA256 \
	or int(motion.get("movie_bytes", -1)) != EXPECTED_MOVIE_BYTES \
	or FileAccess.get_file_as_bytes(MOVIE_PATH).size() != EXPECTED_MOVIE_BYTES \
	or not bool(motion.get("movie_finalized_after_writer_close", false)) \
	or str(motion.get("motion_review_contact_sheet_sha256", "")) != EXPECTED_REVIEW_SHEET_SHA256 \
	or FileAccess.get_sha256(REVIEW_SHEET_PATH) != EXPECTED_REVIEW_SHEET_SHA256 \
	or _vector2i(motion.get("motion_review_contact_sheet_dimensions", []) as Array) != Vector2i(1280, 800) \
	or int(motion.get("motion_physics_frames", 0)) != 240 \
	or not is_equal_approx(float(motion.get("continuous_duration_seconds", 0.0)), 4.0) \
	or str(motion.get("input_action", "")) != "move_right" \
	or bool(motion.get("run_action_pressed", true)) \
	or float(motion.get("horizontal_displacement_m", 0.0)) < 10.0 \
	or float(motion.get("direction_dot_public_tangent_abs", 0.0)) < 0.90 \
	or int(motion.get("recovery_delta", 1)) != 0 \
	or int(motion.get("player_transform_writes_after_input_began", 1)) != 0 \
	or bool(motion.get("camera_orientation_changed_during_motion", true)) \
	or not bool(motion.get("all_samples_grounded", false)) \
	or not bool((motion.get("capture_fixture_contract", {}) as Dictionary).get("isolated_neutral_ground", false)) \
	or bool((motion.get("capture_fixture_contract", {}) as Dictionary).get("live_world_loaded", true)) \
	or _int_array(motion.get("mapped_public_runs_under_review", []) as Array) != MAPPED_RUNS \
	or motion.get("confusion_set_source_ids_frozen_before_capture", []) != CONFUSION_SET:
		return false
	var samples := motion.get("samples", []) as Array
	if samples.size() != 240:
		return false
	for index in samples.size():
		var sample := samples[index] as Dictionary
		if int(sample.get("frame", 0)) != index + 1 or not bool(sample.get("is_on_floor", false)):
			return false
	return true


func _hashes_match_current(actual: Dictionary, expected_count: int) -> bool:
	if actual.size() != expected_count:
		return false
	for path: String in actual:
		if not FileAccess.file_exists(path) or str(actual[path]) != FileAccess.get_sha256(path):
			return false
	return true


func _hashes_match_historical(actual: Dictionary, expected_count: int) -> bool:
	if actual.size() != expected_count:
		return false
	# Keep the already-reviewed evidence immutable while distinguishing its
	# historical pins from the current package-safe config/material revisions.
	for path: String in actual:
		var expected := str(HISTORICAL_CHANGED_INPUT_HASHES.get(path, FileAccess.get_sha256(path)))
		if str(actual[path]) != expected:
			return false
	return true


func _batch_triangles_match(actual: Dictionary) -> bool:
	if actual.size() != EXPECTED_BATCH_TRIANGLES.size():
		return false
	for key: String in EXPECTED_BATCH_TRIANGLES:
		if int(actual.get(key, -1)) != int(EXPECTED_BATCH_TRIANGLES[key]):
			return false
	return true


func _vector2i(values: Array) -> Vector2i:
	return Vector2i(int(values[0]), int(values[1])) if values.size() == 2 else Vector2i.ZERO


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _finish() -> void:
	if _failures.is_empty():
		print("PASS: sealed 1444 Croaker isolated same-pose stills, changed light, exact package/source pins, and continuous grounded stock-player motion evidence")
		quit(0)
	else:
		push_error("FAIL: %s" % _failures)
		quit(1)
