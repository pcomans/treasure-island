extends SceneTree

const ROOT := "res://evidence/first-playable/isle-house-composite-repair-variant-c-live-replacement-2026-09-04"
const STILL_MANIFEST := ROOT + "/capture-manifest.json"
const MOTION_MANIFEST := ROOT + "/motion-capture.json"
const MOVIE := ROOT + "/isle-house-variant-c-actual-live-public-corner-stock-walk.avi"
const README := ROOT + "/README.md"
const HARNESS := "res://game/tests/isle_house_variant_c_live_replacement_capture.gd"
const LIVE := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd"
const FACTORY := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_repair_only_factory.gd"
const REVIEWED_FACTORY := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"
const BUILDER := "res://game/scripts/world/world_chunk_builder.gd"
const REVIEW := "res://evidence/first-playable/isle-house-composite-repair-variant-c-standalone-v1-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md"
const LOW_KEY := "building-composite:w1249412094:w1282547787:wall"
const HIGH_KEY := "building-composite:w1249412094:w1282547786:wall"
const LIVE_SIGNATURE := "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981"
const REPAIR_SIGNATURE := "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69"
const HIGH_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const REVIEW_SHA := "b9877edb51eb9cc09bfd08f33d2664d7d3de08736daa2b96dc6e36c60d0fb5e5"
const EXPECTED_HASHES := {
	STILL_MANIFEST: "23fd6eff4ab8d9696af9d1ecc19bea50537cc824ecf3a7bebdf4fa191cd039d9",
	MOTION_MANIFEST: "ccdd006da0a4385c241f155c22a18941345ba9a90cd6e48fd9d2031492337259",
	MOVIE: "930c444e5599bb5dad82883d7f29331c0fbfdc9be3039967fb3fc59f9491f957",
	README: "98eb26bdeca0ffae036189fb24b6ad9510be028b05ed0c4bbfd3a92952764a02",
	HARNESS: "1f56f6eeeab9c7538a8d0f901c1647b78ab44f3f80d0d0b5e366576cef0e0811",
	LIVE: "e2767b01fab68d7f16ffe2e7f8e0313c711347e2006a72e028c19aaa2195b891",
	FACTORY: "4336e821e240b973f8d97e5cb46e17332b19dea03869abb1fa81b96a7e380582",
	REVIEWED_FACTORY: "b24fd72cd12aa0c6c45a123f005fc834ea657c343e8332a872eae07fa017ace7",
	BUILDER: "d3d3dc1ba3aace541dc07ce437d242787ce2e4efe66877368ac2907e3facf17c",
	REVIEW: REVIEW_SHA,
	ROOT + "/images/01-wsw-whole-composite-default.png": "42fec29f400095c84d0179d56a73a738a013fd5f9421e37ff5182d571bd284b1",
	ROOT + "/images/02-wsw-whole-composite-changed-light.png": "26d0a98c6c855b615f054a48bc919c3a29f522f1cba449cec7a5c30d7f096f8f",
	ROOT + "/images/03-ene-public-supplemental.png": "4d525e9c545d893bf21655150c92808faea2ccbed9e85c37bd5db1fea3d59f9d",
	ROOT + "/images/04-nnw-quiet-return-direct.png": "48922e04b389c770eca9e4fcb3de1c5af70c9399ff8634db59cc528f3552e677",
}
const IMAGE_BYTES := {
	"01-wsw-whole-composite-default": 613369,
	"02-wsw-whole-composite-changed-light": 533886,
	"03-ene-public-supplemental": 738052,
	"04-nnw-quiet-return-direct": 773312,
}
const WORLD := {"rows": 735, "meshes": 940, "surfaces": 954, "triangles": 64118, "bodies": 466, "shapes": 466}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for path: String in EXPECTED_HASHES:
		_require(FileAccess.get_sha256(path) == str(EXPECTED_HASHES[path]), "Evidence/source hash drifted: %s." % path)
	var stills := _json(STILL_MANIFEST)
	var motion := _json(MOTION_MANIFEST)
	_require(_stills_match(stills), "Actual-live still manifest or PNG contract failed.")
	_require(_motion_matches(motion), "Actual-live continuous-motion contract failed.")
	if not _failed:
		print("PASS: four native actual-live frames and one 300-sample grounded stock-player motion interval remain exact, current-world-bound, preview-free, hash-sealed, and pending independent exact-current live review")
	quit(1 if _failed else 0)


func _stills_match(manifest: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.isle-house-variant-c-actual-live-evidence/1" \
	or str(manifest.get("review_status", "")) != "pending_independent_exact_current_live_review_not_self_accepted" \
	or str(manifest.get("recognition_status", "")) != "pending_independent_review" \
	or str(manifest.get("believability_status", "")) != "pending_independent_review" \
	or str(manifest.get("generator_sha256", "")) != str(EXPECTED_HASHES[HARNESS]) \
	or not _world_matches(manifest.get("runtime_topology", {}) as Dictionary) \
	or not bool(manifest.get("actual_live_node_resolved", false)) \
	or int(manifest.get("preview_or_standalone_attachment_count", -1)) != 0 \
	or bool(manifest.get("source_photography_shipped", true)) or bool(manifest.get("source_urls_in_runtime", true)) \
	or str(manifest.get("visual_verdict", "")) != "pending_independent_review":
		return false
	var bindings := manifest.get("bindings", {}) as Dictionary
	if not _bindings_match(bindings):
		return false
	var captures := manifest.get("captures", []) as Array
	if captures.size() != 4 or int(manifest.get("capture_count", 0)) != 4:
		return false
	var by_id: Dictionary = {}
	for value: Variant in captures:
		var capture := value as Dictionary
		var id := str(capture.get("id", ""))
		if not IMAGE_BYTES.has(id) or by_id.has(id):
			return false
		by_id[id] = capture
		var path := ROOT.path_join(str(capture.get("file", "")))
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900) \
		or str(capture.get("sha256", "")) != FileAccess.get_sha256(path) \
		or int(capture.get("bytes", 0)) != int(IMAGE_BYTES[id]) \
		or not bool(capture.get("physics_grounded", false)) or not bool(capture.get("ordinary_player_rig", false)) \
		or not bool(capture.get("input_reachable_camera_orientation", false)) \
		or bool(capture.get("debug_labels_visible", true)) or bool(capture.get("source_photography_in_frame", true)) \
		or bool(capture.get("crop_or_postprocess", true)) or str(capture.get("visual_verdict", "")) != "pending_independent_review":
			return false
	var wsw := by_id.get("01-wsw-whole-composite-default", {}) as Dictionary
	var changed := by_id.get("02-wsw-whole-composite-changed-light", {}) as Dictionary
	if str(wsw.get("role", "")) != "grounded_ordinary_player_actual_live_whole_high_plus_low_composite" \
	or str(wsw.get("lighting", "")) != "world_default" or str(changed.get("lighting", "")) != "frozen_changed_light" \
	or str(changed.get("same_pose_as", "")) != "01-wsw-whole-composite-default" \
	or changed.get("player_position_m", []) != wsw.get("player_position_m", []) \
	or changed.get("camera_position_m", []) != wsw.get("camera_position_m", []) \
	or changed.get("camera_forward", []) != wsw.get("camera_forward", []) \
	or str(wsw.get("first_los_hit_receiver", "")) != HIGH_KEY or wsw.get("first_los_hit_source_keys", []) != ["w1282547786"]:
		return false
	var projection := wsw.get("composite_projection", {}) as Dictionary
	var high := projection.get("high", {}) as Dictionary
	var low := projection.get("low", {}) as Dictionary
	if not bool(projection.get("ok", false)) or float(high.get("clipped_height_px", 0.0)) < 260.0 \
	or float(high.get("clipped_area_fraction", 0.0)) < 0.05 or float(low.get("clipped_height_px", 0.0)) < 70.0 \
	or float(low.get("clipped_area_fraction", 0.0)) < 0.018:
		return false
	for id: String in ["03-ene-public-supplemental", "04-nnw-quiet-return-direct"]:
		var detail := by_id[id] as Dictionary
		if str(detail.get("first_los_hit_receiver", "")) != LOW_KEY or detail.get("first_los_hit_source_keys", []) != ["w1282547787"]:
			return false
	return true


func _motion_matches(motion: Dictionary) -> bool:
	if str(motion.get("schema_version", "")) != "ti.isle-house-variant-c-actual-live-motion-evidence/1" \
	or str(motion.get("review_status", "")) != "pending_independent_exact_current_live_review_not_self_accepted" \
	or str(motion.get("generator_sha256", "")) != str(EXPECTED_HASHES[HARNESS]) \
	or str(motion.get("movie_sha256", "")) != str(EXPECTED_HASHES[MOVIE]) \
	or int(motion.get("movie_bytes", 0)) != 19833852 or not bool(motion.get("movie_finalized_after_writer_close", false)) \
	or motion.get("movie_dimensions", []) != [1280.0, 800.0] \
	or int(motion.get("fixed_fps", 0)) != 30 or int(motion.get("physics_ticks_per_second", 0)) != 60 \
	or int(motion.get("motion_physics_frames", 0)) != 300 or not is_equal_approx(float(motion.get("continuous_duration_seconds", 0.0)), 5.0) \
	or absf(float(motion.get("horizontal_displacement_m", 0.0)) - 19.8834915161133) > 0.0001 \
	or float(motion.get("start_along_from_corner_m", 0.0)) >= -7.0 or float(motion.get("end_along_from_corner_m", 0.0)) <= 10.0 \
	or float(motion.get("direction_dot_public_tangent", 0.0)) <= 0.995 \
	or int(motion.get("player_transform_writes_after_input_began", -1)) != 0 \
	or bool(motion.get("camera_orientation_changed_during_motion", true)) or not bool(motion.get("all_samples_grounded", false)) \
	or int(motion.get("recovery_delta", -1)) != 0 or not _world_matches(motion.get("runtime_topology", {}) as Dictionary) \
	or not _bindings_match(motion.get("bindings", {}) as Dictionary) \
	or str(motion.get("visual_verdict", "")) != "pending_independent_review":
		return false
	var samples := motion.get("samples", []) as Array
	if samples.size() != 300:
		return false
	var previous := -INF
	for index in samples.size():
		var sample := samples[index] as Dictionary
		var along := float(sample.get("along_from_corner_m", -INF))
		if int(sample.get("frame", 0)) != index + 1 or not bool(sample.get("is_on_floor", false)) or along + 0.001 < previous:
			return false
		previous = along
	return true


func _bindings_match(bindings: Dictionary) -> bool:
	return bindings.get("low_receiver_source_keys", []) == ["w1282547787"] \
		and bindings.get("high_receiver_source_keys", []) == ["w1282547786"] \
		and str(bindings.get("live_signature", "")) == LIVE_SIGNATURE \
		and str(bindings.get("repair_signature", "")) == REPAIR_SIGNATURE \
		and str(bindings.get("approval_review_sha256", "")) == REVIEW_SHA \
		and str(bindings.get("high_facade_signature", "")) == HIGH_SIGNATURE \
		and int(bindings.get("preview_nodes_attached", -1)) == 0 \
		and not bool(bindings.get("rejected_overlay_present", true)) \
		and not bool(bindings.get("overlay_stacked", true)) \
		and bool(bindings.get("underlying_wall_is_sole_collision_and_spray_receiver", false)) \
		and not bool(bindings.get("recognition_accepted", true)) and not bool(bindings.get("believability_accepted", true))


func _world_matches(actual: Dictionary) -> bool:
	for key: String in WORLD:
		if int(actual.get(key, -1)) != int(WORLD[key]):
			return false
	return true


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ISLE_VARIANT_C_LIVE_EVIDENCE_FAIL: %s" % message)
	return false
