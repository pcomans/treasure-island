extends SceneTree

const OUTPUT := "res://evidence/first-playable/isle-house-composite-repair-variant-c-standalone-v1-2026-09-04"
const CAPTURE_MANIFEST := OUTPUT + "/capture-manifest.json"
const MOTION_MANIFEST := OUTPUT + "/motion-capture.json"
const MOVIE := OUTPUT + "/isle-house-composite-repair-variant-c-public-corner-stock-walk.avi"
const REVIEW_SHEET := OUTPUT + "/variant-c-public-corner-motion-review-contact-sheet.png"
const FACTORY := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"
const CONFIG := "res://game/resources/facades/isle_house_composite_repair_variant_c_standalone_v1.json"
const SCENE := "res://game/scenes/world/facades/isle_house/isle_house_composite_repair_variant_c_standalone_v1.tscn"
const MID_MATERIAL := "res://game/resources/materials/world/isle_house/isle_house_podium_mid_warm_v1.tres"
const QUIET_MATERIAL := "res://game/resources/materials/world/isle_house/isle_house_return_quiet_v1.tres"
const CAPTURE_HARNESS := "res://game/tests/isle_house_composite_repair_variant_c_standalone_v1_capture.gd"
const HIGH_WALL_KEY := "building-composite:w1249412094:w1282547786:wall"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const FAILED_LIVE_SIGNATURE := "5d61ab90e5b798ac4aa26c45fea37a5293f3083dada615f06999faad459112cc"
const SEALED_B_SIGNATURE := "a58d9b963b0dc19b5a9fa1cba4872294a2ea2803459a9ba455e276dc1ff5b5bf"
const C_REPAIR_SIGNATURE := "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69"
const HIGH_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const EXPECTED_HASHES := {
	FACTORY: "b24fd72cd12aa0c6c45a123f005fc834ea657c343e8332a872eae07fa017ace7",
	CONFIG: "bafdef392ee638e860ba15f140c10de61e266ae63005b12e0e310e52c176897a",
	SCENE: "568cf7b229ff10aec5aade61562c7a8f48e84119d650b1529af7f84071721d39",
	MID_MATERIAL: "a9c7230ff52d37327e6d98e0f14953eee2bd3eec7426dc993c0b7cf90e0ec037",
	QUIET_MATERIAL: "15d4848127a5153724d873dceea9d46121c0d65e5b53be61abed6e70a2f964c1",
	CAPTURE_HARNESS: "c2a701aed2a71d76dfcb878451b45a5c5d1cd044410cbc4cd44eefb6a6d4c7fd",
	CAPTURE_MANIFEST: "015569b668958e6ae07f6cad6187a1cdc246f183331459315e264bf233bfc0dd",
	MOTION_MANIFEST: "b128e2a1888dc543bc2cba0cc27922a86f19d339a8efe7c7665e49d4c1161809",
	MOVIE: "99623c498180eba8475fda0e3c99eda30fa45608a15ee747c4db62c55b614245",
	REVIEW_SHEET: "f87d0d398c2599d5c5304d42df1c3dcd5fd1c76431d5ae33be5219568bed7eba",
	OUTPUT + "/images/ene-public-low-detail-b-sealed-changed-light.png": "f76c05f8217de2831dc0730084ccdb1c5a7f10f6ba9240f05ea60252c66249e7",
	OUTPUT + "/images/ene-public-low-detail-b-sealed.png": "6b5da4609acec3a9e9af84243dde425f01a7856b26700a52035f4e2f074fbd5b",
	OUTPUT + "/images/ene-public-low-detail-c-candidate-changed-light.png": "93e64afa454c00b4d5f0bed793ee66a3fe6fe0b2441cfbb00f8fbc47219f4df3",
	OUTPUT + "/images/ene-public-low-detail-c-candidate.png": "a11a822261ce9043a8699dfe7b3d4b991b336766f0797d5d9155414669559c18",
	OUTPUT + "/images/nnw-quiet-return-direct-b-sealed-changed-light.png": "5d7940f33a5a1ffa7eecd6223668f0220f3494df79d85e2cb799a4ed4605dd5b",
	OUTPUT + "/images/nnw-quiet-return-direct-b-sealed.png": "872c938a2057513783ae4073ba5f288c2d08f4766ea61e8a0f636dc357d70d39",
	OUTPUT + "/images/nnw-quiet-return-direct-c-candidate-changed-light.png": "1682f55c10fc27f1cdb6a7991f2851fe88c9368d680f4c63402123b1889495bb",
	OUTPUT + "/images/nnw-quiet-return-direct-c-candidate.png": "66a413b09c3a9b19472c520b55f4d06de8b6b11299db722f0a7b4d1ba26cd438",
	OUTPUT + "/images/wsw-public-oblique-whole-composite-b-sealed-changed-light.png": "cb6130f3c3d8471218f270bcaf1c13013ee72a38bf38a5f4bfa93ee495c5e3d7",
	OUTPUT + "/images/wsw-public-oblique-whole-composite-b-sealed.png": "234b91a8b819030d9cb3030e7184764728b216af48ec832ea554ae1069985eff",
	OUTPUT + "/images/wsw-public-oblique-whole-composite-c-candidate-changed-light.png": "4f9c1821fb77062c23e92305f4a227ef366015f9064121791e6862b3320fbd5d",
	OUTPUT + "/images/wsw-public-oblique-whole-composite-c-candidate.png": "a60cf402647f3d0f086d73ca4f01cb3640ee4aacc02fd73582cc44082e87c362",
	OUTPUT + "/images/wsw-public-whole-composite-b-sealed-changed-light.png": "38e7e3966456df55485427dbab8e5086918cdeed66824d8147bd35d71c888311",
	OUTPUT + "/images/wsw-public-whole-composite-b-sealed.png": "618505c32bedc75505bc33843cab657f88c33b11500c12c7bb456431151f4afd",
	OUTPUT + "/images/wsw-public-whole-composite-c-candidate-changed-light.png": "26d0a98c6c855b615f054a48bc919c3a29f522f1cba449cec7a5c30d7f096f8f",
	OUTPUT + "/images/wsw-public-whole-composite-c-candidate.png": "ff10993b25e9a87e56d95d9b7f5d3164718efe89624c68e4831518e29476f32e",
}
const PAIR_PREFIXES := [
	"wsw-public-whole-composite",
	"wsw-public-oblique-whole-composite",
	"ene-public-low-detail",
	"nnw-quiet-return-direct",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(_hashes_match(), "A sealed Variant C source/evidence artifact drifted.")
	var capture := _json(CAPTURE_MANIFEST)
	var motion := _json(MOTION_MANIFEST)
	_require(_capture_manifest_matches(capture), "Variant C still manifest lost its native, truth-bound, or B/C pairing contract.")
	_require(_captures_match(capture.get("captures", []) as Array), "A Variant C still lost exact pixels, grounded provenance, same-pose pairing, LOS, framing, or pending-review state.")
	_require(_motion_matches(motion), "Variant C motion evidence lost its exact movie/review-sheet, grounded stock-player, or pending-review contract.")
	if not _failed:
		print("PASS: sixteen sealed native Variant C B/C default/changed-light PNGs, one direct NNW pair, and one 222-frame grounded stock-player movie plus review sheet remain technically valid; visual grade and live promotion remain pending independent review")
	quit(1 if _failed else 0)


func _capture_manifest_matches(manifest: Dictionary) -> bool:
	var bindings := manifest.get("bindings", {}) as Dictionary
	var runtime := manifest.get("current_failed_parent_runtime_topology", {}) as Dictionary
	var provenance := manifest.get("provenance_and_nonclaims", {}) as Dictionary
	return str(manifest.get("schema_version", "")) == "ti.isle-house-composite-repair-variant-c-standalone-evidence/1" \
		and str(manifest.get("review_status", "")) == "pending_independent_review_not_self_accepted" \
		and str(manifest.get("recognition_status", "")) == "pending_independent_review" \
		and str(manifest.get("believability_status", "")) == "pending_independent_review" \
		and str(manifest.get("generator_sha256", "")) == str(EXPECTED_HASHES[CAPTURE_HARNESS]) \
		and str(manifest.get("factory_sha256", "")) == str(EXPECTED_HASHES[FACTORY]) \
		and str(manifest.get("config_sha256", "")) == str(EXPECTED_HASHES[CONFIG]) \
		and str(manifest.get("display_driver", "")) == "macOS" \
		and "Apple M2" in str(manifest.get("video_adapter", "")) \
		and manifest.get("viewport", []) == [1440.0, 900.0] \
		and int(manifest.get("capture_count", 0)) == 16 \
		and int(manifest.get("default_light_same_pose_pairs", 0)) == 4 \
		and int(manifest.get("changed_light_same_pose_pairs", 0)) == 4 \
		and int(manifest.get("whole_composite_same_pose_pairs", 0)) == 2 \
		and int(manifest.get("whole_composite_changed_light_same_pose_pairs", 0)) == 2 \
		and int(manifest.get("supplemental_ENE_low_detail_pairs", 0)) == 1 \
		and int(manifest.get("direct_NNW_return_pairs", 0)) == 1 \
		and int(manifest.get("changed_light_frames", 0)) == 8 \
		and bindings.get("low_receiver_source_keys", []) == ["w1282547787"] \
		and bindings.get("high_receiver_source_keys", []) == ["w1282547786"] \
		and str(bindings.get("failed_live_signature", "")) == FAILED_LIVE_SIGNATURE \
		and str(bindings.get("sealed_variant_b_repair_signature", "")) == SEALED_B_SIGNATURE \
		and str(bindings.get("variant_c_repair_signature", "")) == C_REPAIR_SIGNATURE \
		and str(bindings.get("accepted_high_signature", "")) == HIGH_SIGNATURE \
		and _topology_matches(bindings.get("sealed_variant_b_topology", {}) as Dictionary, 6, 8, 2316) \
		and _topology_matches(bindings.get("variant_c_topology", {}) as Dictionary, 7, 11, 2242) \
		and bool(bindings.get("underlying_wall_remains_sole_collision_and_spray_receiver", false)) \
		and bool(bindings.get("standalone_only", false)) \
		and not bool(bindings.get("live_replacement", true)) \
		and not bool(bindings.get("recognition_accepted", true)) \
		and not bool(bindings.get("believability_accepted", true)) \
		and _runtime_matches(runtime, 735, 938, 948, 63720, 466, 466) \
		and (provenance.get("observed_family", []) as Array).size() == 6 \
		and (provenance.get("production_inference", []) as Array).size() == 13 \
		and "upper opening, window, floor, or story schedule" in (provenance.get("not_claimed", []) as Array) \
		and "NNW opening schedule or as-built cladding" in (provenance.get("not_claimed", []) as Array) \
		and "live promotion" in (provenance.get("not_claimed", []) as Array) \
		and not bool(manifest.get("source_photography_shipped", true)) \
		and not bool(manifest.get("source_urls_in_runtime", true)) \
		and str(manifest.get("visual_verdict", "")) == "pending_independent_review"


func _captures_match(captures: Array) -> bool:
	if captures.size() != 16:
		return false
	var by_id: Dictionary = {}
	for value: Variant in captures:
		var capture := value as Dictionary
		var id := str(capture.get("id", ""))
		if id.is_empty() or by_id.has(id):
			return false
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
	for prefix: String in PAIR_PREFIXES:
		var b_default := by_id.get(prefix + "-b-sealed", {}) as Dictionary
		var c_default := by_id.get(prefix + "-c-candidate", {}) as Dictionary
		var b_changed := by_id.get(prefix + "-b-sealed-changed-light", {}) as Dictionary
		var c_changed := by_id.get(prefix + "-c-candidate-changed-light", {}) as Dictionary
		if b_default.is_empty() or c_default.is_empty() or b_changed.is_empty() or c_changed.is_empty():
			return false
		for peer: Dictionary in [c_default, b_changed, c_changed]:
			if peer.get("camera_position_m", []) != b_default.get("camera_position_m", []) \
			or peer.get("player_position_m", []) != b_default.get("player_position_m", []) \
			or peer.get("projection", {}) != b_default.get("projection", {}):
				return false
		if str(b_default.get("variant", "")) != "b" or str(b_changed.get("variant", "")) != "b" \
		or str(c_default.get("variant", "")) != "c" or str(c_changed.get("variant", "")) != "c" \
		or str(b_default.get("lighting", "")) != "world_default" or str(c_default.get("lighting", "")) != "world_default" \
		or str(b_changed.get("lighting", "")) != "frozen_changed_light" or str(c_changed.get("lighting", "")) != "frozen_changed_light":
			return false
	for prefix: String in PAIR_PREFIXES.slice(0, 2):
		var whole := by_id[prefix + "-c-candidate"] as Dictionary
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
	for prefix: String in PAIR_PREFIXES.slice(2):
		for suffix: String in ["b-sealed", "c-candidate", "b-sealed-changed-light", "c-candidate-changed-light"]:
			var detail := by_id[prefix + "-" + suffix] as Dictionary
			if not bool(detail.get("supplemental_detail_not_whole_acceptance_view", false)) \
			or str(detail.get("first_los_hit_receiver", "")) != LOW_WALL_KEY \
			or detail.get("first_los_hit_source_keys", []) != ["w1282547787"]:
				return false
			if prefix == "nnw-quiet-return-direct" and not bool(detail.get("direct_NNW_return_grade_view", false)):
				return false
	return by_id.size() == 16


func _motion_matches(motion: Dictionary) -> bool:
	var bindings := motion.get("bindings", {}) as Dictionary
	var samples := motion.get("samples", []) as Array
	var review_frames := motion.get("motion_review_sample_physics_frames", []) as Array
	var sheet := Image.load_from_file(ProjectSettings.globalize_path(REVIEW_SHEET))
	if str(motion.get("schema_version", "")) != "ti.isle-house-composite-repair-variant-c-standalone-motion-evidence/1" \
	or str(motion.get("review_status", "")) != "pending_independent_review_not_self_accepted" \
	or str(motion.get("generator_sha256", "")) != str(EXPECTED_HASHES[CAPTURE_HARNESS]) \
	or str(motion.get("factory_sha256", "")) != str(EXPECTED_HASHES[FACTORY]) \
	or str(motion.get("config_sha256", "")) != str(EXPECTED_HASHES[CONFIG]) \
	or str(motion.get("movie_sha256", "")) != str(EXPECTED_HASHES[MOVIE]) \
	or int(motion.get("movie_bytes", 0)) != 19017750 \
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
	or str(motion.get("motion_review_contact_sheet", "")) != REVIEW_SHEET.get_file() \
	or str(motion.get("motion_review_contact_sheet_sha256", "")) != str(EXPECTED_HASHES[REVIEW_SHEET]) \
	or motion.get("motion_review_contact_sheet_dimensions", []) != [1280.0, 800.0] \
	or sheet == null or sheet.is_empty() or sheet.get_size() != Vector2i(1280, 800) \
	or review_frames != [1.0, 21.0, 41.0, 61.0, 81.0, 101.0, 121.0, 141.0, 161.0, 181.0, 201.0, 221.0, 241.0, 261.0, 281.0, 300.0] \
	or samples.size() != 300 \
	or str(bindings.get("sealed_variant_b_repair_signature", "")) != SEALED_B_SIGNATURE \
	or str(bindings.get("variant_c_repair_signature", "")) != C_REPAIR_SIGNATURE \
	or not bool(bindings.get("standalone_only", false)) \
	or bool(bindings.get("live_replacement", true)):
		return false
	var prior_along := -INF
	for index in samples.size():
		var sample := samples[index] as Dictionary
		var along := float(sample.get("along_from_corner_m", -INF))
		if int(sample.get("frame", 0)) != index + 1 or not bool(sample.get("is_on_floor", false)) or along + 0.001 < prior_along:
			return false
		prior_along = along
	return true


func _topology_matches(actual: Dictionary, meshes: int, surfaces: int, triangles: int) -> bool:
	return int(actual.get("mesh_instances", -1)) == meshes \
		and int(actual.get("surfaces", -1)) == surfaces \
		and int(actual.get("triangles", -1)) == triangles


func _runtime_matches(actual: Dictionary, rows: int, meshes: int, surfaces: int, triangles: int, bodies: int, shapes: int) -> bool:
	return int(actual.get("rows", -1)) == rows \
		and int(actual.get("meshes", -1)) == meshes \
		and int(actual.get("surfaces", -1)) == surfaces \
		and int(actual.get("triangles", -1)) == triangles \
		and int(actual.get("bodies", -1)) == bodies \
		and int(actual.get("shapes", -1)) == shapes


func _hashes_match() -> bool:
	for path: String in EXPECTED_HASHES:
		if FileAccess.get_sha256(path) != str(EXPECTED_HASHES[path]):
			push_error("Variant C evidence hash drift: %s expected=%s actual=%s" % [path, str(EXPECTED_HASHES[path]), FileAccess.get_sha256(path)])
			return false
	return true


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ISLE_COMPOSITE_VARIANT_C_EVIDENCE_FAIL: %s" % message)
	return false
