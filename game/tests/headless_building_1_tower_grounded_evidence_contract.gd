extends SceneTree

const OUTPUT := "res://evidence/first-playable/building-1-tower-grounded-correction-2026-09-04"
const MANIFEST_PATH := OUTPUT + "/capture-manifest.json"
const PREVIOUS_OUTPUT := "res://evidence/first-playable/building-1-hero-2026-09-04"
const GENERATOR_PATH := "res://game/tests/building_1_tower_grounded_capture.gd"
const CONFIG_PATH := "res://game/resources/facades/building_1_hero_model.json"
const SOURCE_RECEIPT_PATH := "res://discovery/facades/PRECOMMIT_PACKAGE_SANITIZATION_SOURCE_PROVENANCE.json"
const SOURCE_RECEIPT_SHA256 := "269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333"
const CAPTURE_TIME_CONFIG_SHA256 := "6c99f43550631a1e6bca1f52764ad23c6a5b8b891403f30c78ff9b9545192690"
const CURRENT_PACKAGE_SAFE_CONFIG_SHA256 := "f10bc92a6e74cbae41347e742e6c68c50faccddbd52ab3ecce210ac8243bc6e9"
const INDEPENDENT_REVIEW_SHA256 := "fb952a31151805078d1e386117ed965aa0649ffddcd17874d13493b5dd4239bb"
const EXPECTED_IDS := ["01-grounded-tower-family", "02-grounded-oblique-silhouette"]
const EXPECTED_RUNS := [5, 8]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manifest := _json(MANIFEST_PATH)
	var previous_manifest := _json(PREVIOUS_OUTPUT + "/capture-manifest.json")
	_require(not manifest.is_empty() and not previous_manifest.is_empty(), "Current or superseded tower evidence manifest is missing.")
	_require(str(manifest.get("schema_version", "")) == "ti.building-1-tower-grounded-evidence/1", "Grounded tower evidence schema drifted.")
	_require(str(manifest.get("review_status", "")) == "pending_independent_tower_re_review_not_self_accepted", "Tower evidence must remain pending independent re-review.")
	_require(str(manifest.get("correction_kind", "")) == "capture_only" and not bool(manifest.get("runtime_changed_for_correction", true)) and (manifest.get("runtime_files_changed_for_correction", []) as Array).is_empty(), "Capture-only correction incorrectly claims a runtime change.")
	_require(FileAccess.get_sha256(OUTPUT + "/INDEPENDENT_REVIEW.md") == INDEPENDENT_REVIEW_SHA256, "Independent grounded-tower review receipt is missing or drifted.")
	_require(str(manifest.get("display_driver", "")) == "macOS" and str(manifest.get("rendering_method", "")) == "Forward+" and str(manifest.get("rendering_driver", "")) == "Metal", "Grounded tower evidence is not native macOS Forward+/Metal.")
	_require(_int_pair(manifest.get("viewport", []), 1440, 900), "Grounded tower evidence viewport drifted.")
	var camera := manifest.get("shipped_player_camera", {}) as Dictionary
	_require(is_equal_approx(float(camera.get("fov_degrees", 0.0)), 70.0) and is_equal_approx(float(camera.get("spring_length_m", 0.0)), 5.5), "Grounded tower evidence did not use the shipped player camera.")
	_require(not bool(manifest.get("debug_overlays_visible", true)) and not bool(manifest.get("hud_visible", true)), "Grounded tower evidence contains a HUD/debug overlay.")
	_require(str(manifest.get("target_source_key", "")) == "w1222720021" and manifest.get("target_object_keys", []) == ["building:w1222720021:wall", "building:w1222720021:roof"], "Grounded tower evidence target identity drifted.")
	_require(str(manifest.get("generator_sha256", "")) == FileAccess.get_sha256(GENERATOR_PATH), "Grounded tower evidence generator hash is stale.")
	_require(str(manifest.get("config_sha256", "")) == CAPTURE_TIME_CONFIG_SHA256, "Grounded tower capture-time config hash drifted.")
	_require(str(manifest.get("config_sha256", "")) == str(previous_manifest.get("config_sha256", "")) and str(manifest.get("adapter_sha256", "")) == str(previous_manifest.get("adapter_sha256", "")) and str(manifest.get("world_builder_sha256", "")) == str(previous_manifest.get("world_builder_sha256", "")), "Capture-only correction changed the reviewed Building 1 runtime.")
	_require(_current_package_migration_matches(), "Current package-safe Building 1 config or its source-only migration receipt drifted.")
	_require(str(manifest.get("superseded_rejected_manifest_sha256", "")) == FileAccess.get_sha256(PREVIOUS_OUTPUT + "/capture-manifest.json") and str(manifest.get("superseded_review_sha256", "")) == FileAccess.get_sha256(PREVIOUS_OUTPUT + "/INDEPENDENT_REVIEW.md"), "Superseded rejection provenance is stale.")
	var topology := manifest.get("runtime_topology", {}) as Dictionary
	_require(
		int(topology.get("records", -1)) == 735
		and int(topology.get("meshes", -1)) == 931
		and int(topology.get("surfaces", -1)) == 941
		and int(topology.get("triangles", -1)) == 59778
		and int(topology.get("static_bodies", -1)) == 466
		and int(topology.get("shapes", -1)) == 466,
		"Grounded tower capture topology drifted."
	)
	var selection := manifest.get("selection_contract", {}) as Dictionary
	_require(str(selection.get("selection_mode", "")) == "two_source_run_anchored_fixed_ground_poses_after_bounded_search" and int(selection.get("retained_pose_count", 0)) == 2, "Grounded tower pose selection contract drifted.")
	var captures := manifest.get("captures", []) as Array
	_require(int(manifest.get("capture_count", -1)) == 2 and captures.size() == 2, "Grounded tower evidence must contain exactly two captures.")
	var azimuths: Array[float] = []
	var player_positions: Array[Vector3] = []
	for index in captures.size():
		var capture := captures[index] as Dictionary
		_require(str(capture.get("id", "")) == EXPECTED_IDS[index] and int(capture.get("candidate_source_run", -1)) == EXPECTED_RUNS[index], "Grounded tower fixed pose identity drifted at capture %d." % index)
		var image_path := OUTPUT.path_join(str(capture.get("file", "")))
		_require(FileAccess.file_exists(image_path) and str(capture.get("sha256", "")) == FileAccess.get_sha256(image_path) and int(capture.get("bytes", -1)) == FileAccess.get_file_as_bytes(image_path).size() and _int_pair(capture.get("dimensions", []), 1440, 900), "Grounded tower image bytes or dimensions drifted at capture %d." % index)
		_require(bool(capture.get("physics_grounded_pose", false)) and str(capture.get("ground_feature_kind", "")) in ["land_ground", "road_path"] and bool(capture.get("in_playable_boundary", false)), "Grounded tower pose is not on proven playable ground at capture %d." % index)
		_require(float(capture.get("camera_height_above_ground_m", 0.0)) >= float(selection.get("minimum_camera_height_above_ground_m", INF)), "Grounded tower camera is below the ordinary-height gate at capture %d." % index)
		_require(str(capture.get("exact_los_ray_kind", "")) == "direct_camera_to_in_frame_tower_point" and _viewport_point(capture.get("exact_los_target_viewport_px", [])), "Grounded tower exact LOS target is not in frame at capture %d." % index)
		_require(str(capture.get("exact_los_hit_object", "")) == "building:w1222720021:wall" and capture.get("exact_los_hit_sources", []) == ["w1222720021"], "Grounded tower pose lacks exact wall LOS at capture %d." % index)
		_require(not bool(capture.get("hud_visible", true)) and not bool(capture.get("debug_overlays_visible", true)) and not bool(capture.get("player_visible", true)), "Grounded tower image has a UI/avatar obstruction at capture %d." % index)
		_require(is_equal_approx(float(capture.get("camera_fov_degrees", 0.0)), 70.0) and is_equal_approx(float(capture.get("spring_length_m", 0.0)), 5.5), "Grounded tower capture changed the shipped lens/arm at capture %d." % index)
		_require(float(capture.get("tower_projected_width_px", 0.0)) >= float(selection.get("minimum_projected_width_px", INF)) and float(capture.get("tower_projected_height_px", 0.0)) >= float(selection.get("minimum_projected_height_px", INF)) and bool(capture.get("tower_fully_inside_viewport", false)), "Grounded tower projected-size gate failed at capture %d." % index)
		azimuths.append(float(capture.get("view_azimuth_degrees", 0.0)))
		player_positions.append(_vector3(capture.get("player_position_m", [])))
	var separation := _angle_separation(azimuths[0], azimuths[1]) if azimuths.size() == 2 else 0.0
	_require(separation >= float(selection.get("minimum_view_separation_degrees", INF)) and absf(separation - float(selection.get("actual_view_separation_degrees", -1.0))) < 0.001, "Grounded tower views are not distinctly separated.")
	_require(player_positions.size() == 2 and player_positions[0].distance_to(player_positions[1]) > 20.0, "Grounded tower captures reuse effectively the same ground position.")
	if not _failed:
		print("PASS: grounded tower evidence preserves exact capture-time runtime hashes and independent review while the current B1 config is package-safely migrated")
	quit(1 if _failed else 0)


func _json(path: String) -> Dictionary:
	var value = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _current_package_migration_matches() -> bool:
	if FileAccess.get_sha256(CONFIG_PATH) != CURRENT_PACKAGE_SAFE_CONFIG_SHA256 \
	or FileAccess.get_sha256(SOURCE_RECEIPT_PATH) != SOURCE_RECEIPT_SHA256:
		return false
	var config := _json(CONFIG_PATH)
	var authority := config.get("authority", {}) as Dictionary
	var receipt := _json(SOURCE_RECEIPT_PATH)
	var records := receipt.get("records", {}) as Dictionary
	var historical := records.get("B1-HERO-AUTHORITY", {}) as Dictionary
	return str(authority.get("source_provenance_receipt_id", "")) == "B1-HERO-AUTHORITY" \
		and str(authority.get("source_provenance_receipt_sha256", "")) == SOURCE_RECEIPT_SHA256 \
		and str(historical.get("historical_runtime_config_sha256", "")) == CAPTURE_TIME_CONFIG_SHA256


func _vector3(value: Variant) -> Vector3:
	var items := value as Array if value is Array else []
	return Vector3(float(items[0]), float(items[1]), float(items[2])) if items.size() == 3 else Vector3.ZERO


func _int_pair(value: Variant, first: int, second: int) -> bool:
	var items := value as Array if value is Array else []
	return items.size() == 2 and int(items[0]) == first and int(items[1]) == second


func _viewport_point(value: Variant) -> bool:
	var items := value as Array if value is Array else []
	return items.size() == 2 and float(items[0]) >= 0.0 and float(items[0]) <= 1440.0 and float(items[1]) >= 0.0 and float(items[1]) <= 900.0


func _angle_separation(first: float, second: float) -> float:
	var delta := absf(first - second)
	return minf(delta, 360.0 - delta)


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_failed = true
		push_error(message)
	return condition
