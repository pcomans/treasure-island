extends SceneTree

const OUTPUT := "res://evidence/first-playable/d2-1439-chinook-standalone-hero-2026-09-04"
const MANIFEST_PATH := OUTPUT + "/capture-manifest.json"
const MOTION_PATH := OUTPUT + "/motion-capture.json"
const MOVIE_PATH := OUTPUT + "/d2-1439-chinook-sse-stock-walk.avi"
const REVIEW_SHEET_PATH := OUTPUT + "/images/d2-1439-chinook-sse-motion-review-sheet.png"
const GENERATOR_SHA256 := "4cd0f07b8f7dd75ff0891032c116f1f3e2de7f16bc8abca453ae66af07121583"
const EXPECTED_IMAGES := {
	"01-whole-sse-before": "495ab00cc341ee4250a6ef35bccca4f69ace21f8150db3e24d83fae38737f0d7",
	"01-whole-sse-after": "76039556633e13e995b27f4400a942b07d29bf701e9148e929af1dafcc19fef6",
	"02-sse-oblique-before": "fe164a86c23172143758590e385109a828e0188bfc1313330b1edc6f968b43b8",
	"02-sse-oblique-after": "aa67ea1f138d8b5010823f2d0a24223eb31f73ac3e846ad80a16219d251287b8",
	"03-sse-oblique-changed-light-before": "786b12e7c81f3137166892b2c6e4b3345a5304476b05d878a890e9fe4557d694",
	"03-sse-oblique-changed-light-after": "adc66222df56d6284d806865455fc33dbbbcf299f7d5eee2cb28765f332dc035",
}
const EXPECTED_INPUTS := {
	"res://game/resources/facades/d2_1439_chinook_standalone_hero_prototype.json": "bd83cdd7a70a832701fccdf8ee39b976b57602ce4105244b2266f8fd35cac500",
	"res://generated/world/chunks/x_-2__z_0.json": "3e7d1cb020d4a8f8a2852121a181a1e2d441fee40de42d744d37fbbcba59168b",
	"res://discovery/facades/d2_reference_packets/w95934144_1439_chinook_court.md": "050ceb6195bf1f7a4b1c753cde5a509c30b0911599af9233db5746605b9cfeb6",
	"res://game/scripts/world/facades/site_12_housing_kit.gd": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
	"res://game/scripts/world/facades/d2_1439_chinook_standalone_hero_prototype.gd": "70e487d34c9fc7f036d4f2f9119f1f4eca41801c98447319a39fd849ea549f1c",
	"res://game/scenes/world/facades/site_12_housing/d2_1439_chinook_standalone_hero_prototype.tscn": "a5a9fb270e014ba613e422a897c36d0ee39bed456ef6b236ae2e5349ad1c0f0b",
	"res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres": "81fd15832670516b2cc752e89310acda201f30705b01297639703f76f2111a64",
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres": "d97d7b4a442ffe8ad9a0b003e5c1d6466f9ef9effc7cdb2be8ef966195e66782",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres": "389c01066767b085ef8ed8ae4c5e1b06062d9ffb135e3e6a7bfa968b963717d7",
	"res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres": "4159f82cc5c4c17c0d8173eddbc171120326fbd99578aa68012275b1274ce02d",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres": "eddc4900c351dc3a75d163bd380a8b3a39bf6a1c1c3647299e3af19634a60ead",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres": "75c13aa30a4e3c9f49980d78abe41f40c6c7ab270be6152c201eb8a72ebe8720",
	"res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png": "af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg": "fa09ed33d59c3bb90ef70d36352207e2e1ca5564cfc61295c0124d1a7d785808",
}
const EXPECTED_MOVIE_SHA256 := "a7ad0649b4b9a805fe4cdefb1f8f38326aaf597ab381cb5aee101c3b87f2e7aa"
const EXPECTED_MOVIE_BYTES := 6332942
const EXPECTED_REVIEW_SHEET_SHA256 := "e8cd0bc95b3ad70ef2b7f20131822b3f571f074a24f9fe069a863c70e5021cb3"
const MAPPED_RUNS := [11, 12, 16, 17, 18, 19, 22, 23]
const MOTIF_HOST_RUNS := [11, 19, 23]
const MAPPED_MOTIF_FREE_RUNS := [12, 16, 17, 18, 22]
const TINY_FRAGMENT_RUNS := [17, 18]
const PROTECTED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 20, 21]
const CONFUSION_SET := ["w95934113", "w95934105", "w95934131"]
const EXPECTED_BATCH_TRIANGLES := {
	"ProtectedExactWallRuns": 32,
	"MappedSSEExactWarmStuccoWallRuns": 16,
	"ExactPlanShallowGableRoof": 10,
	"MappedSSEContinuousEaveChains": 36,
	"OffsetEndTwoLevelBalconyVoids": 24,
	"OffsetEndBalconySlabs": 24,
	"OffsetEndSimpleMetalRails": 168,
	"QuietRegisterUpperOpaqueOpenings": 36,
	"QuietRegisterUpperPaleFrames": 180,
	"BlankEndGroundPassageShadow": 12,
	"BlankEndGroundPassageFrame": 36,
}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manifest := _json(MANIFEST_PATH)
	var motion := _json(MOTION_PATH)
	_require(_manifest_truth_matches(manifest), "1439 still evidence truth/source/topology contract drifted.")
	_require(_hashes_match(manifest.get("pinned_inputs", {}) as Dictionary, EXPECTED_INPUTS), "1439 still exact package/source pins drifted.")
	_require(_hashes_current(manifest.get("capture_fixture_inputs", {}) as Dictionary, 8), "1439 stock-player fixture pins drifted.")
	_require(_captures_match(manifest.get("captures", []) as Array), "1439 still files, grounding, framing, or receiver bindings drifted.")
	_require(_pairs_match(manifest.get("capture_pairs", []) as Array, manifest.get("captures", []) as Array), "1439 same-pose pair contract drifted.")
	_require(_motion_matches(motion, manifest), "1439 continuous stock-player motion contract drifted.")
	_finish()


func _manifest_truth_matches(manifest: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.d2-1439-chinook-standalone-hero-evidence/1" \
	or str(manifest.get("review_status", "")) != "technical_capture_valid_recognition_and_believability_pending_independent_bar_raiser_review" \
	or not bool(manifest.get("technical_self_check_only", false)) \
	or str(manifest.get("visual_verdict", "")) != "pending_independent_bar_raiser_review" \
	or str(manifest.get("generator_sha256", "")) != GENERATOR_SHA256:
		return false
	var target := manifest.get("target", {}) as Dictionary
	var truth := manifest.get("truth_boundary", {}) as Dictionary
	var fixture := manifest.get("capture_fixture_contract", {}) as Dictionary
	var topology := manifest.get("prototype_topology", {}) as Dictionary
	return str(target.get("canonical_name", "")) == "1439 Chinook Court" \
		and str(target.get("source_key", "")) == "w95934144" \
		and str(target.get("wall_object_key", "")) == "building:w95934144:wall" \
		and str(target.get("roof_object_key", "")) == "building:w95934144:roof" \
		and str(target.get("source_geometry_sha256", "")) == "a59bd2abf2020c25071a55ecb96f32b7871a810e8d1bdd95c213b512273f87f2" \
		and str(target.get("wall_record_sha256", "")) == "a801ff083961a7fafab455d18a80f2ea3ea87791ad5e967f91937ad3fc2b82a0" \
		and str(target.get("roof_record_sha256", "")) == "83ea383a9a490871fbd7891ebb5a179adfe0af5e27607e727550563a27c20e58" \
		and _ints(target.get("mapped_public_sse_runs", []) as Array) == MAPPED_RUNS \
		and _ints(target.get("motif_host_runs", []) as Array) == MOTIF_HOST_RUNS \
		and _ints(target.get("mapped_motif_free_runs", []) as Array) == MAPPED_MOTIF_FREE_RUNS \
		and _ints(target.get("tiny_fragment_runs", []) as Array) == TINY_FRAGMENT_RUNS \
		and _ints(target.get("protected_runs", []) as Array) == PROTECTED_RUNS \
		and bool(truth.get("standalone_capture_only", false)) \
		and bool(truth.get("isolated_neutral_ground_fixture", false)) \
		and not bool(truth.get("live_world_loaded", true)) \
		and not bool(truth.get("runtime_attachment", true)) \
		and not bool(truth.get("recognition_accepted", true)) \
		and not bool(truth.get("believability_accepted", true)) \
		and not bool(truth.get("as_built_claim", true)) \
		and not bool(truth.get("protected_runs_have_modules", true)) \
		and not bool(truth.get("mapped_motif_free_runs_have_addressable_motifs", true)) \
		and not bool(truth.get("tiny_fragments_receive_standalone_motifs", true)) \
		and manifest.get("confusion_set_source_ids_frozen_before_capture", []) == CONFUSION_SET \
		and bool(fixture.get("isolated_neutral_ground", false)) \
		and not bool(fixture.get("live_world_loaded", true)) \
		and int(fixture.get("exact_source_wall_triangles", -1)) == 48 \
		and int(fixture.get("exact_flat_source_roof_triangles", -1)) == 10 \
		and int(fixture.get("baseline_collision_triangles", -1)) == 58 \
		and int(topology.get("mesh_instances", -1)) == 11 \
		and int(topology.get("surfaces", -1)) == 11 \
		and int(topology.get("visual_triangles", -1)) == 574 \
		and _batch_triangles_match(topology.get("visual_batch_triangles", {}) as Dictionary) \
		and int(topology.get("static_bodies", -1)) == 1 \
		and int(topology.get("shapes", -1)) == 1 \
		and int(topology.get("collision_triangles", -1)) == 58 \
		and str(topology.get("deterministic_signature", "")) == "b82660eb7774ab022c417c7d417d51646f68fd288d916ad47a91d58db5bc8fb9" \
		and int(topology.get("balcony_void_count", -1)) == 2 \
		and int(topology.get("rail_picket_count", -1)) == 10 \
		and int(topology.get("quiet_upper_opening_count", -1)) == 3 \
		and int(topology.get("passage_void_count", -1)) == 1 \
		and int(topology.get("passage_pier_count", -1)) == 2 \
		and int(topology.get("mapped_eave_chain_count", -1)) == 3


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
		var after := id.ends_with("-after")
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
		or not (capture.get("ground_sources", []) as Array).is_empty() \
		or str(capture.get("recognition_verdict", "")) != "pending_independent_bar_raiser_review" \
		or str(capture.get("believability_verdict", "")) != "pending_independent_bar_raiser_review" \
		or absf(float(capture.get("ground_clearance_m", 1.0))) > 0.08 \
		or float(capture.get("settle_horizontal_drift_m", 1.0)) > 0.05 \
		or int(capture.get("settle_recovery_delta", 1)) != 0 \
		or not bool(capture.get("receiver_source_run_first_los", false)) \
		or int(capture.get("first_los_hit_run_index", -1)) != 19 \
		or bool(capture.get("capture_only_prototype_swap", not after)) != after:
			return false
		var expected_receiver := "prototype:building:w95934144:wall" if after else "building:w95934144:wall"
		if str(capture.get("first_los_hit_receiver", "")) != expected_receiver:
			return false
		if bool(capture.get("lighting_changed", not id.begins_with("03-"))) != id.begins_with("03-"):
			return false
	return seen.size() == EXPECTED_IMAGES.size()


func _pairs_match(pairs: Array, captures: Array) -> bool:
	if pairs.size() != 3:
		return false
	var by_id := {}
	for value: Variant in captures:
		var capture := value as Dictionary
		by_id[str(capture.get("id", ""))] = capture
	for value: Variant in pairs:
		var pair := value as Dictionary
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
	if str(motion.get("schema_version", "")) != "ti.d2-1439-chinook-standalone-motion-evidence/1" \
	or str(motion.get("review_status", "")) != "technical_motion_valid_visual_review_pending" \
	or str(motion.get("visual_verdict", "")) != "pending_independent_bar_raiser_review" \
	or str(motion.get("generator_sha256", "")) != GENERATOR_SHA256 \
	or motion.get("package_hashes", {}) != manifest.get("pinned_inputs", {}) \
	or motion.get("capture_fixture_inputs", {}) != manifest.get("capture_fixture_inputs", {}) \
	or str(motion.get("movie_sha256", "")) != EXPECTED_MOVIE_SHA256 \
	or FileAccess.get_sha256(MOVIE_PATH) != EXPECTED_MOVIE_SHA256 \
	or int(motion.get("movie_bytes", -1)) != EXPECTED_MOVIE_BYTES \
	or FileAccess.get_file_as_bytes(MOVIE_PATH).size() != EXPECTED_MOVIE_BYTES \
	or not bool(motion.get("movie_finalized_after_writer_close", false)) \
	or int(motion.get("movie_total_frames_expected_after_close", 0)) != 191 \
	or str(motion.get("motion_review_contact_sheet_sha256", "")) != EXPECTED_REVIEW_SHEET_SHA256 \
	or FileAccess.get_sha256(REVIEW_SHEET_PATH) != EXPECTED_REVIEW_SHEET_SHA256 \
	or _vec2i(motion.get("motion_review_contact_sheet_dimensions", []) as Array) != Vector2i(1280, 800) \
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
	or _ints(motion.get("mapped_public_runs_under_review", []) as Array) != MAPPED_RUNS \
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


func _hashes_match(actual: Dictionary, expected: Dictionary) -> bool:
	if actual.size() != expected.size():
		return false
	for path: String in expected:
		if str(actual.get(path, "")) != str(expected[path]) or FileAccess.get_sha256(path) != str(expected[path]):
			return false
	return true


func _hashes_current(actual: Dictionary, expected_count: int) -> bool:
	if actual.size() != expected_count:
		return false
	for path: String in actual:
		if not FileAccess.file_exists(path) or str(actual[path]) != FileAccess.get_sha256(path):
			return false
	return true


func _batch_triangles_match(actual: Dictionary) -> bool:
	if actual.size() != EXPECTED_BATCH_TRIANGLES.size():
		return false
	for key: String in EXPECTED_BATCH_TRIANGLES:
		if int(actual.get(key, -1)) != int(EXPECTED_BATCH_TRIANGLES[key]):
			return false
	return true


func _ints(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _vec2i(values: Array) -> Vector2i:
	return Vector2i(int(values[0]), int(values[1])) if values.size() == 2 else Vector2i.ZERO


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
		print("PASS: sealed 1439 Chinook isolated same-pose stills, changed light, exact package/source pins, and continuous grounded stock-player motion evidence")
		quit(0)
	else:
		push_error("FAIL: %s" % _failures)
		quit(1)
