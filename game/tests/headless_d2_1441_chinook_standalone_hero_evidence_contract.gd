extends SceneTree

const OUTPUT := "res://evidence/first-playable/d2-1441-chinook-standalone-hero-2026-09-04"
const MANIFEST_PATH := OUTPUT + "/capture-manifest.json"
const MOTION_PATH := OUTPUT + "/motion-capture.json"
const MOVIE_PATH := OUTPUT + "/d2-1441-chinook-sse-stock-walk.avi"
const EXPECTED_IMAGES := {
	"01-whole-sse-before": "594d8806a38f81fabc0e69d128ce9f132a8883fb8b967fc3d2271c833b942dab",
	"01-whole-sse-after": "69237ce93ee7f7df32a216fa20fab5d40e2ae1cb6f3f52689b20766ffa269442",
	"02-sse-oblique-before": "5d19ed4c9f5ce804a77612f665fb2ce11f0122d38f14db8d1e50e7fbd7b93a16",
	"02-sse-oblique-after": "9e9785f7631a8ceadd56d018dcc9f945d0ee650a5aad8d4e2deaccbfe950b06a",
	"03-sse-oblique-changed-light-before": "b484bfd8b4bdccbbb0d3f0b9d67d9b784a230b1fca2c0c86ecfb51f0c09ba71f",
	"03-sse-oblique-changed-light-after": "77aa0216f48121429bbdd3425db38da31d1fcfeba47b790de8d9fd2ff4a61696",
}
const HISTORICAL_GENERATOR_SHA256 := "17834a3d635107bf582dcf70b66fabe9eda40c3f7f0a8c276b2a0478bf17b90c"
const HISTORICAL_PACKAGE_HASHES := {
	"res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json": "e07fba5d50f9bce4d879203ad63c0db62aa6fa5efc1f1f430ef91beb42e444e0",
	"res://generated/world/chunks/x_-1__z_-1.json": "5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b",
	"res://discovery/facades/d2_reference_packets/w95934105_1441_chinook_court.md": "8135272f4cc012e83fa19f80871651d25db29c4cbd5a50dc07e4faee7563b0bc",
	"res://game/scripts/world/facades/site_12_housing_kit.gd": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
	"res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd": "df3b644c4a708d53b2fd2c7cb8862cb922da5c2033b824e88b80877da311542d",
	"res://game/scenes/world/facades/site_12_housing/d2_1441_chinook_standalone_hero_prototype.tscn": "a551c9dfe1f1139c721999a3748ccaa91637ec38a999a8aa2300f419f673c91c",
	"res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres": "b30d0d750e70ad4b8c28ddddce65cd88ef4ae04412b38dfef580870a2fd0bb5f",
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres": "d97d7b4a442ffe8ad9a0b003e5c1d6466f9ef9effc7cdb2be8ef966195e66782",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres": "389c01066767b085ef8ed8ae4c5e1b06062d9ffb135e3e6a7bfa968b963717d7",
	"res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres": "4159f82cc5c4c17c0d8173eddbc171120326fbd99578aa68012275b1274ce02d",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres": "eddc4900c351dc3a75d163bd380a8b3a39bf6a1c1c3647299e3af19634a60ead",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres": "75c13aa30a4e3c9f49980d78abe41f40c6c7ab270be6152c201eb8a72ebe8720",
	"res://game/resources/textures/world/genai_pilot_v1/warm_ivory_mineral_albedo_v2.png": "af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg": "fa09ed33d59c3bb90ef70d36352207e2e1ca5564cfc61295c0124d1a7d785808",
}
const EXPECTED_BATCH_TRIANGLES := {
	"ProtectedExactWallRuns": 24,
	"MappedSSEExactStuccoWallRuns": 8,
	"ExactPlanShallowGableRoof": 10,
	"MappedSSEBroadEaves": 48,
	"ProjectingWingOpaqueOpenings": 144,
	"ProjectingWingPaleOpeningFrames": 720,
	"RecessedTwoLevelOpaqueVoids": 48,
	"RecessedBalconySlabs": 48,
	"RecessedSimpleMetalRails": 528,
}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manifest := _json(MANIFEST_PATH)
	var motion := _json(MOTION_PATH)
	_require(_manifest_truth_matches(manifest), "Still evidence truth/source/topology contract drifted.")
	_require(_package_hashes_match(manifest.get("pinned_inputs", {}) as Dictionary), "Still package pins drifted.")
	_require(_captures_match(manifest.get("captures", []) as Array), "Still capture files or grounded framing metadata drifted.")
	_require(_pairs_match(manifest.get("capture_pairs", []) as Array, manifest.get("captures", []) as Array), "Same-pose pair contract drifted.")
	_require(_motion_matches(motion), "Continuous stock-player motion contract drifted.")
	_finish()


func _manifest_truth_matches(manifest: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.d2-1441-chinook-standalone-hero-evidence/1" \
	or str(manifest.get("review_status", "")) != "technical_capture_valid_recognition_and_believability_pending_independent_bar_raiser_review" \
	or not bool(manifest.get("technical_self_check_only", false)) \
	or str(manifest.get("visual_verdict", "")) != "pending_independent_bar_raiser_review" \
	or str(manifest.get("generator_sha256", "")) != HISTORICAL_GENERATOR_SHA256:
		return false
	var target := manifest.target as Dictionary
	var truth := manifest.truth_boundary as Dictionary
	var topology := manifest.prototype_topology as Dictionary
	return str(target.source_key) == "w95934105" \
		and str(target.wall_object_key) == "building:w95934105:wall" \
		and str(target.roof_object_key) == "building:w95934105:roof" \
		and str(target.source_geometry_sha256) == "952df7a4edca5dbaec7d74cb795b564cb1fa5567ea737d1a861e222b29ddf07f" \
		and str(target.wall_record_sha256) == "2f89ec3b90d7ab5999d79f92e7ebbae1265cf0b93e3931f8968e348ad91d8a5a" \
		and str(target.roof_record_sha256) == "41a9b67b0c65aa26ca241183d37932e481f12bdc75b6253d928e4a1623013214" \
		and _int_array(target.mapped_public_sse_runs as Array) == [10, 12, 13, 15] \
		and _int_array(target.protected_runs as Array) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14] \
		and bool(truth.standalone_capture_only) and not bool(truth.runtime_attachment) \
		and not bool(truth.recognition_accepted) and not bool(truth.believability_accepted) \
		and not bool(truth.as_built_claim) and not bool(truth.interior_modeled) \
		and not bool(truth.source_photography_stored_or_shown) \
		and not bool(truth.protected_runs_have_modules) and not bool(truth.fallback_collider_retained) \
		and int(topology.mesh_instances) == 9 and int(topology.surfaces) == 9 \
		and int(topology.visual_triangles) == 1578 \
		and _batch_triangles_match(topology.visual_batch_triangles as Dictionary) \
		and int(topology.static_bodies) == 1 and int(topology.shapes) == 1 \
		and int(topology.collision_triangles) == 42 \
		and str(topology.deterministic_signature) == "b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195" \
		and int(topology.wing_opening_count) == 12 and int(topology.recess_void_count) == 4 \
		and int(topology.rail_picket_count) == 36 and int(topology.mapped_eave_count) == 4 \
		and manifest.get("confusion_set_source_ids_frozen_before_capture", []) == ["w95934144", "w95934107", "w95934118", "w95934120"] \
		and (manifest.get("reference_supported_cues_frozen_before_capture", []) as Array).size() == 3


func _package_hashes_match(actual: Dictionary) -> bool:
	if actual != HISTORICAL_PACKAGE_HASHES:
		return false
	# The sealed captures stay immutable. The config and warm-stucco material were
	# deliberately superseded by the byte-identical package-safe promotion, so
	# their historical bytes are checked above rather than against current source.
	for path: String in HISTORICAL_PACKAGE_HASHES:
		if path in [
			"res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json",
			"res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
		]:
			continue
		if FileAccess.get_sha256(path) != str(HISTORICAL_PACKAGE_HASHES[path]):
			return false
	return true


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
		or str(capture.get("recognition_verdict", "")) != "pending_independent_bar_raiser_review" \
		or str(capture.get("believability_verdict", "")) != "pending_independent_bar_raiser_review" \
		or float(capture.get("target_projected_width_ratio", 0.0)) < 0.12 \
		or float(capture.get("target_projected_height_ratio", 0.0)) < 0.035 \
		or float(capture.get("ground_clearance_m", 1.0)) > 0.08 \
		or float(capture.get("settle_horizontal_drift_m", 1.0)) > 0.05 \
		or int(capture.get("settle_recovery_delta", 1)) != 0 \
		or not bool(capture.get("receiver_source_run_first_los", false)):
			return false
		var expected_after := id.ends_with("-after")
		if bool(capture.get("capture_only_prototype_swap", not expected_after)) != expected_after:
			return false
		if expected_after and not str(capture.get("first_los_hit_receiver", "")).begins_with("prototype:"):
			return false
		if not expected_after and str(capture.get("first_los_hit_receiver", "")) != "building:w95934105:wall":
			return false
	return seen.size() == EXPECTED_IMAGES.size()


func _pairs_match(pairs: Array, captures: Array) -> bool:
	if pairs.size() != 3:
		return false
	var by_id := {}
	for value: Variant in captures:
		var capture := value as Dictionary
		by_id[str(capture.id)] = capture
	for pair_value: Variant in pairs:
		var pair := pair_value as Dictionary
		if not bool(pair.get("camera_transform_exactly_reused", false)) \
		or float(pair.get("camera_translation_error_m", 1.0)) > 0.0001 \
		or float(pair.get("camera_basis_error", 1.0)) > 0.0001 \
		or float(pair.get("player_translation_error_m", 1.0)) > 0.0001:
			return false
		var before := by_id.get(str(pair.before_capture_id), {}) as Dictionary
		var after := by_id.get(str(pair.after_capture_id), {}) as Dictionary
		if before.is_empty() or after.is_empty() \
		or before.get("player_position_m", []) != after.get("player_position_m", []) \
		or before.get("camera_position_m", []) != after.get("camera_position_m", []) \
		or before.get("requested_xz", []) != after.get("requested_xz", []):
			return false
	return true


func _motion_matches(motion: Dictionary) -> bool:
	if str(motion.get("schema_version", "")) != "ti.d2-1441-chinook-standalone-motion-evidence/1" \
	or str(motion.get("review_status", "")) != "technical_motion_valid_visual_review_pending" \
	or str(motion.get("visual_verdict", "")) != "pending_independent_bar_raiser_review" \
	or str(motion.get("generator_sha256", "")) != HISTORICAL_GENERATOR_SHA256 \
	or not _package_hashes_match(motion.get("package_hashes", {}) as Dictionary) \
	or str(motion.get("movie_sha256", "")) != "1f7b42f4b83c0225146044cfc9794f71575d19e06147e15ebc7f0aa46b3f7d03" \
	or FileAccess.get_sha256(MOVIE_PATH) != str(motion.get("movie_sha256", "")) \
	or int(motion.get("movie_bytes", -1)) != 15553064 \
	or FileAccess.get_file_as_bytes(MOVIE_PATH).size() != 15553064 \
	or not bool(motion.get("movie_finalized_after_writer_close", false)) \
	or int(motion.get("motion_physics_frames", 0)) != 240 \
	or not is_equal_approx(float(motion.get("continuous_duration_seconds", 0.0)), 4.0) \
	or float(motion.get("horizontal_displacement_m", 0.0)) < 10.0 \
	or int(motion.get("recovery_delta", 1)) != 0 \
	or int(motion.get("player_transform_writes_after_input_began", 1)) != 0 \
	or bool(motion.get("camera_orientation_changed_during_motion", true)) \
	or not bool(motion.get("all_samples_grounded", false)) \
	or _int_array(motion.get("mapped_public_runs_under_review", []) as Array) != [10, 12, 13, 15]:
		return false
	var samples := motion.get("samples", []) as Array
	if samples.size() != 240:
		return false
	for index in samples.size():
		var sample := samples[index] as Dictionary
		if int(sample.get("frame", 0)) != index + 1 or not bool(sample.get("is_on_floor", false)):
			return false
	return true


func _batch_triangles_match(actual: Dictionary) -> bool:
	if actual.size() != EXPECTED_BATCH_TRIANGLES.size():
		return false
	for key: String in EXPECTED_BATCH_TRIANGLES:
		if int(actual.get(key, -1)) != int(EXPECTED_BATCH_TRIANGLES[key]):
			return false
	return true


func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _require(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _finish() -> void:
	if _failures.is_empty():
		print("PASS: sealed 1441 Chinook native same-pose stills, changed light, package pins, and continuous stock-player motion evidence")
		quit(0)
	else:
		push_error("FAIL: %s" % _failures)
		quit(1)
