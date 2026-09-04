extends SceneTree

const OUTPUT := "res://evidence/first-playable/dormitory-369-standalone-hero-2026-09-04"
const MANIFEST_PATH := OUTPUT + "/capture-manifest.json"
const CONFIG_PATH := "res://game/resources/facades/dormitory_369_standalone_hero_prototype.json"
const SOURCE_RECEIPT_PATH := "res://discovery/facades/PRECOMMIT_PACKAGE_SANITIZATION_SOURCE_PROVENANCE.json"
const SOURCE_RECEIPT_SHA256 := "269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333"
const HISTORICAL_CONFIG_SHA256 := "a6086d13a986bdd4a6c281b75ec7fb58524257ae4b8ea6b849840a324cc59dc2"
const CURRENT_CONFIG_SHA256 := "b02b098bfeca628cd6a71e7393897d53f5f46dfd0efddd915e316c2dd5204c2e"
const CAPTURE_TIME_CONTEXT := {
	"game/scenes/main.tscn": "959a0f8a14057ea8402790ba374c7839d5f9835ce20ad194846f0a4d45b43d66",
	"game/scripts/main.gd": "7ae840aa08a00bc38a3b714ebb0fe3fcd611fb643c86fc828aec44efb4d85843",
	"game/scripts/world/world_chunk_builder.gd": "9525ead815e95d7bc0b5fa8beae389954e232a9bbf51b54ed049a84a3613b9c0",
	"generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
}
const EXPECTED_HASHES := {
	"res://game/tests/dormitory_369_standalone_hero_capture.gd": "38b46b680bfae521f742e51a6b4051b51b2fb3617871d9a623168e75eb43694a",
	MANIFEST_PATH: "4834dbed96cdffd93983151332104ae3b8d7c6d5f5c1121b474b405f80fd2d17",
	OUTPUT + "/checksums.sha256": "1d83a211aa194a86985d094fa20d3a6e5f195d968467ecf4c2eade15a61f4198",
	OUTPUT + "/images/01-whole-object-before.png": "3fd9f0d6b966b26dc06e3af447bb6c0fd70adba5b003409da37dc6edd1ae5839",
	OUTPUT + "/images/01-whole-object-after.png": "e0bdb99986f992b436d3d8dea9558d02879ad48886832ffec1e084ab297a2004",
	OUTPUT + "/images/02-oblique-approach-before.png": "08bae25a6b8e62619487be528c21589edcef1429cccd844b18cd3a59ed39eb24",
	OUTPUT + "/images/02-oblique-approach-after.png": "244f11be2b064c293848eb2ec242c2c8c61d13a59e128b398effab099619f3d2",
	OUTPUT + "/images/03-changed-light-oblique-before.png": "faef68ec106fff1833fee87cb804dd9df1937e5d3a69e9c8c1474ce7e216d257",
	OUTPUT + "/images/03-changed-light-oblique-after.png": "c06407d48d9ae35c01343966a98acdec031d6b949efec3ec23b33bc1ba910039",
}
const EXPECTED_CAPTURE_IDS := [
	"01-whole-object-before",
	"01-whole-object-after",
	"02-oblique-approach-before",
	"02-oblique-approach-after",
	"03-changed-light-oblique-before",
	"03-changed-light-oblique-after",
]
const CONFUSION_SET := ["w34313514", "w34313521", "w291189918"]
const MAPPED_RUNS := [0, 1, 2, 3, 4, 5]
const EXPECTED_BATCH_TRIANGLES := {
	"ProtectedLiftedWallRuns_6_71": 132,
	"AcceptedWarmLiftedWallRuns_0_5": 12,
	"NeutralLiftedRoof": 32,
	"BlueGrayStructuralStairEnd": 12,
	"BlueGrayGroundPanels": 48,
	"GreenStructuralEave": 12,
	"GreenEyebrows": 240,
	"OpaqueExteriorOpeningsAndVents": 480,
	"OpeningFramesAndMultiLiteDividers": 2400,
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(_hashes_match(), "A sealed Dormitory 369 evidence generator, manifest, or PNG drifted."):
		_finish()
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if not _require(parsed is Dictionary, "The Dormitory 369 evidence manifest does not parse."):
		_finish()
		return
	var manifest := parsed as Dictionary
	if not _require(_manifest_truth_matches(manifest), "The Dormitory 369 evidence truth, native provenance, exact binding, inference boundary, or topology drifted.") \
		or not _require(_pinned_inputs_match(manifest), "A source, package, or exact-current runtime input pinned by the Dormitory 369 capture drifted.") \
		or not _require(_captures_match(manifest.get("captures", []) as Array), "A Dormitory 369 evidence frame lost image integrity, grounded provenance, ordinary-player framing, exact LOS binding, or pending-review status.") \
		or not _require(_pairs_match(manifest.get("capture_pairs", []) as Array, manifest.get("captures", []) as Array), "A Dormitory 369 before/after pair no longer uses the same grounded camera/player transform and lighting."):
		_finish()
		return
	print("PASS: six sealed native Dormitory 369 PNGs remain technically valid grounded fixed-camera before/after evidence, including materially changed light; all recognition, believability, and as-built verdicts remain pending independent bar-raiser review")
	_finish()


func _manifest_truth_matches(manifest: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.dormitory-369-standalone-hero-evidence/1" \
		or str(manifest.get("review_status", "")) != "technical_capture_valid_recognition_and_believability_pending_independent_bar_raiser_review" \
		or not bool(manifest.get("recognition_review_prohibited_for_executor", false)) \
		or str(manifest.get("generator", "")) != "game/tests/dormitory_369_standalone_hero_capture.gd" \
		or str(manifest.get("generator_sha256", "")) != str(EXPECTED_HASHES["res://game/tests/dormitory_369_standalone_hero_capture.gd"]) \
		or str(manifest.get("display_driver", "")) != "macOS" \
		or "Apple M2" not in str(manifest.get("video_adapter", "")) \
		or str(manifest.get("rendering_method", "")) != "Forward+" \
		or str(manifest.get("rendering_driver", "")) != "Metal" \
		or not _float_array_approx(manifest.get("viewport", []) as Array, [1440.0, 900.0], 0.001):
		return false

	var target := manifest.get("target", {}) as Dictionary
	var protected_runs := _int_array(target.get("protected_runs", []) as Array)
	if str(target.get("source_key", "")) != "w291189926" \
		or str(target.get("wall_object_key", "")) != "building:w291189926:wall" \
		or str(target.get("roof_object_key", "")) != "building:w291189926:roof" \
		or str(target.get("geometry_sha256", "")) != "4ad2f9d3c0e109d194965149b6e73c078e7796d19ec3efdfd8f78df6e9aee3e9" \
		or _int_array(target.get("mapped_public_wsw_runs", []) as Array) != MAPPED_RUNS \
		or not is_equal_approx(float(target.get("mapped_public_chain_length_m", 0.0)), 49.124) \
		or protected_runs.size() != 66 \
		or protected_runs.front() != 6 \
		or protected_runs.back() != 71 \
		or not _is_contiguous(protected_runs) \
		or not _float_array_approx(target.get("fallback_base_top_y_m", []) as Array, [3.39, 9.39], 0.0001) \
		or not _float_array_approx(target.get("prototype_nominal_base_roof_y_m", []) as Array, [3.39, 18.39], 0.0001) \
		or int(target.get("prototype_tier_count", 0)) != 5:
		return false

	var truth := manifest.get("truth_boundary", {}) as Dictionary
	if not bool(truth.get("standalone_capture_only", false)) \
		or bool(truth.get("runtime_attachment", true)) \
		or bool(truth.get("recognition_accepted", true)) \
		or bool(truth.get("believability_accepted", true)) \
		or bool(truth.get("as_built_claim", true)) \
		or bool(truth.get("interior_modeled", true)) \
		or str(truth.get("height_tier_spacing_openings_cadence_and_stair_geometry", "")) != "reversible_production_inference" \
		or bool(truth.get("source_photography_stored_or_shown", true)) \
		or bool(truth.get("protected_runs_have_modules", true)) \
		or bool(truth.get("accepted_warm_scope_extended", true)) \
		or bool(truth.get("fallback_6m_collider_retained", true)):
		return false

	var lighting := manifest.get("lighting", {}) as Dictionary
	if manifest.get("confusion_set_source_ids_frozen_before_capture", []) != CONFUSION_SET \
		or (manifest.get("reference_supported_cues_frozen_before_capture", []) as Array).size() != 3 \
		or not _float_array_approx(lighting.get("default_sun_rotation_degrees", []) as Array, [-52.0, -28.0, 0.0], 0.001) \
		or not _float_array_approx(lighting.get("changed_sun_rotation_degrees", []) as Array, [-24.0, 118.0, 0.0], 0.001) \
		or str(lighting.get("changed_light_pair_id", "")) != "03-changed-light-oblique":
		return false

	var topology := manifest.get("prototype_topology", {}) as Dictionary
	if int(topology.get("mesh_instances", 0)) != 9 \
		or int(topology.get("surfaces", 0)) != 9 \
		or int(topology.get("visual_triangles", 0)) != 3368 \
		or int(topology.get("static_bodies", 0)) != 1 \
		or int(topology.get("shapes", 0)) != 1 \
		or int(topology.get("collision_triangles", 0)) != 200 \
		or str(topology.get("deterministic_signature", "")) != "a84ce1e27ef0466d58e35ce57352a8eb43cb8f2d20c7530f0c9d24c0b4b1a121" \
		or not _batch_triangles_match(topology.get("visual_batch_triangles", {}) as Dictionary):
		return false

	var instructions := str(manifest.get("reviewer_instruction", "")).to_lower()
	for phrase in ["original detail", "top-1 dormitory 369", "at least two supported cues", "five-tier facade family", "changed light", "without relying on hue", "reversible production inference", "do not infer interiors", "as-built fidelity"]:
		if phrase not in instructions:
			return false
	return true


func _pinned_inputs_match(manifest: Dictionary) -> bool:
	var pinned := manifest.get("pinned_inputs", {}) as Dictionary
	if pinned.size() != 13:
		return false
	for path: String in pinned:
		if not path.begins_with("res://"):
			return false
		if path == CONFIG_PATH:
			if str(pinned[path]) != HISTORICAL_CONFIG_SHA256 or FileAccess.get_sha256(path) != CURRENT_CONFIG_SHA256:
				push_error("Dormitory 369 historical/current config migration drift: %s" % path)
				return false
			continue
		if FileAccess.get_sha256(path) != str(pinned[path]):
			push_error("Dormitory 369 pinned input drift: %s" % path)
			return false
	var context := manifest.get("exact_current_context_hashes_not_prototype_dependencies", {}) as Dictionary
	if context != CAPTURE_TIME_CONTEXT:
		return false
	for relative_path: String in context:
		var path := "res://%s" % relative_path
		if not FileAccess.file_exists(path):
			push_error("Dormitory 369 captured runtime context path is missing: %s" % path)
			return false
	if FileAccess.get_sha256(SOURCE_RECEIPT_PATH) != SOURCE_RECEIPT_SHA256:
		return false
	var receipt := JSON.parse_string(FileAccess.get_file_as_string(SOURCE_RECEIPT_PATH)) as Dictionary
	var record := (receipt.get("records", {}) as Dictionary).get("DORMITORY-369-AUTHORITY", {}) as Dictionary
	return str(receipt.get("schema_version", "")) == "ti.precommit-package-sanitization-source-provenance/1" \
		and str(record.get("historical_runtime_config_sha256", "")) == HISTORICAL_CONFIG_SHA256


func _captures_match(captures: Array) -> bool:
	if captures.size() != 6:
		return false
	var ids: Array[String] = []
	for capture_value: Variant in captures:
		var capture := capture_value as Dictionary
		var capture_id := str(capture.get("id", ""))
		var stage := str(capture.get("stage", ""))
		var changed_light := capture_id.begins_with("03-")
		var expected_run := 12 if capture_id.begins_with("01-") else 2
		var expected_receiver := "building:w291189926:wall" if stage == "before" else "prototype:building:w291189926:wall"
		var path := OUTPUT.path_join(str(capture.get("file", "")))
		ids.append(capture_id)
		if stage not in ["before", "after"] \
			or str(capture.get("target", "")) != "dormitory-369" \
			or str(capture.get("source_identity", "")) != "w291189926" \
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
			or bool(capture.get("lighting_changed", not changed_light)) != changed_light \
			or not bool(capture.get("full_entity_required_and_in_frame", false)) \
			or not bool(capture.get("protected_untreated_faces_intentionally_not_hidden", false)) \
			or not bool(capture.get("target_bounds_fully_in_frame", false)) \
			or int(capture.get("target_bounds_points_behind_camera", -1)) != 0 \
			or float(capture.get("target_projected_width_ratio", 0.0)) < 0.30 \
			or float(capture.get("target_projected_height_ratio", 0.0)) < 0.025 \
			or not is_equal_approx(float(capture.get("camera_fov_degrees", 0.0)), 70.0) \
			or absf(float(capture.get("configured_spring_length_m", 0.0)) - 5.5) > 0.001 \
			or absf(float(capture.get("actual_spring_length_m", 0.0)) - 5.5) > 0.01 \
			or absf(float(capture.get("ground_clearance_m", 1.0))) > 0.02 \
			or float(capture.get("settle_horizontal_drift_m", 1.0)) > 0.01 \
			or str(capture.get("first_los_hit_receiver", "")) != expected_receiver \
			or capture.get("first_los_hit_source_keys", []) != ["w291189926"] \
			or int(capture.get("first_los_hit_run_index", -1)) != expected_run \
			or int(capture.get("expected_los_run_index", -1)) != expected_run \
			or not bool(capture.get("receiver_source_run_first_los", false)) \
			or float(capture.get("first_los_hit_target_error_m", 1.0)) > 0.001 \
			or bool(capture.get("capture_only_prototype_swap", stage == "before")) != (stage == "after") \
			or str(capture.get("sha256", "")) != FileAccess.get_sha256(path):
			return false
		var expected_sun := [-24.0, 118.0, 0.0] if changed_light else [-52.0, -28.0, 0.0]
		if not _float_array_approx(capture.get("sun_rotation_degrees", []) as Array, expected_sun, 0.001):
			return false
		var hud := capture.get("hud", {}) as Dictionary
		if bool(hud.get("debug_panel_visible", true)) \
			or bool(hud.get("feedback_panel_visible", true)) \
			or bool(hud.get("load_panel_visible", true)) \
			or bool(hud.get("pause_panel_visible", true)) \
			or not bool(hud.get("reticle_visible", false)):
			return false
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900):
			return false
	return ids == EXPECTED_CAPTURE_IDS


func _pairs_match(pairs: Array, captures: Array) -> bool:
	if pairs.size() != 3:
		return false
	var by_id := {}
	for capture_value: Variant in captures:
		var capture := capture_value as Dictionary
		by_id[str(capture.id)] = capture
	var expected_views := ["01-whole-object", "02-oblique-approach", "03-changed-light-oblique"]
	for pair_index in pairs.size():
		var pair := pairs[pair_index] as Dictionary
		if str(pair.get("view_id", "")) != expected_views[pair_index] \
			or not bool(pair.get("camera_transform_exactly_reused", false)) \
			or float(pair.get("camera_translation_error_m", 1.0)) > 0.0001 \
			or float(pair.get("camera_basis_error", 1.0)) > 0.0001 \
			or float(pair.get("player_translation_error_m", 1.0)) > 0.0001:
			return false
		var before := by_id.get(str(pair.get("before_capture_id", "")), {}) as Dictionary
		var after := by_id.get(str(pair.get("after_capture_id", "")), {}) as Dictionary
		if before.is_empty() or after.is_empty() \
			or before.get("camera_position_m", []) != after.get("camera_position_m", []) \
			or before.get("player_position_m", []) != after.get("player_position_m", []) \
			or before.get("requested_xz", []) != after.get("requested_xz", []) \
			or not _float_array_approx(before.get("sun_rotation_degrees", []) as Array, after.get("sun_rotation_degrees", []) as Array, 0.0001) \
			or not bool(after.get("capture_only_prototype_swap", false)) \
			or bool(before.get("capture_only_prototype_swap", true)):
			return false
	return true


func _batch_triangles_match(actual: Dictionary) -> bool:
	if actual.size() != EXPECTED_BATCH_TRIANGLES.size():
		return false
	for key: String in EXPECTED_BATCH_TRIANGLES:
		if int(actual.get(key, -1)) != int(EXPECTED_BATCH_TRIANGLES[key]):
			return false
	return true


func _hashes_match() -> bool:
	for path: String in EXPECTED_HASHES:
		var actual := FileAccess.get_sha256(path)
		if actual != str(EXPECTED_HASHES[path]):
			push_error("Dormitory 369 evidence hash drift: %s expected=%s actual=%s" % [path, str(EXPECTED_HASHES[path]), actual])
			return false
	return true


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


func _is_contiguous(values: Array[int]) -> bool:
	for index in values.size():
		if values[index] != values.front() + index:
			return false
	return true


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
