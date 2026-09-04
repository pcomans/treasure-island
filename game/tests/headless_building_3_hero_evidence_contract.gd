extends SceneTree

const EVIDENCE_ROOT := "res://evidence/first-playable/building-3-hero-massing-2026-09-04"
const MANIFEST_PATH := EVIDENCE_ROOT + "/capture-manifest.json"
const EXPECTED_MANIFEST_SHA256 := "4b92b71df3c7f8f7dfbb285bd7566b3f422a32be45f810d532328e15d008f5be"
const EXPECTED_CAPTURE_SCRIPT_SHA256 := "40d7d09e4399054bc139192ffed090d5ac295ea45eedd680f0da995742280763"
const HISTORICAL_SOURCE_SNAPSHOT := "res://discovery/facades/building_3_hero_massing_capture_source_snapshot_2026-09-04.json"
const EXPECTED_HISTORICAL_SOURCE_SHA256 := "149d9211c75e86c769243298d649b79b682c1b4873af5d86d30a5d04aa1a26bd"
const EXPECTED_AFTER := {
	"images/01-building-3-hero-whole-ene.png": "2527f8f32f4792609e92ad07ed693c70805c15476db80825bead4b37c6f09c3b",
	"images/02-building-3-hero-ene-oblique.png": "a994a8eacbb9615d798253aefd6b19ad8530a156c11768c6dde3845e9452f260",
}
const EXPECTED_BEFORE := {
	"evidence/first-playable/p1-existing-live-revalidation-2026-09-04/images/building-3/01-building-3-whole-object.png": "e20ebd6a483234b1b55de5421113a79dbe6d3c18380ab33858ab0f4de7ded1ef",
	"evidence/first-playable/p1-existing-live-revalidation-2026-09-04/images/building-3/02-building-3-oblique-approach.png": "2a3aa0dd7e4f08f37cad515d75c45240eb412043f4f69acbea208fef4848a103",
}
const EXPECTED_CURRENT_FILES := {
	"res://game/resources/facades/building_3_hero_massing.json": "2a7eacee21c88046deb587e53224b2c6c189172922265ed5a63711789ee37553",
	"res://game/resources/facades/building_3_600_california_ene_layout.json": "a491a3c7916191b9ca5f6adacc6d1f2289c0103f5079516b102b94e3993dae0c",
	"res://game/scripts/world/massing/building_3_600_california_massing.gd": "0755ab9846357207143f4bb0a50c27e710d92aa3a529903c61d4d3495bb94419",
	"res://game/scripts/world/facades/building_3_600_california_facade.gd": "5fa9851a90e886bb0a75ff35bf137ed891ed5f1e0cd53d95ee840a0573c2c55a",
	"res://discovery/facades/BUILDING_3_HERO_MASSING_REPAIR.md": "90daf84b4d26e90ec8f7ef07d88aad0317dbd67475eefc39d88c8b08c79e4425",
	"res://discovery/facades/p1_reference_packets/w34313540_building_3.md": "3701d28e19cc7811067c171eb5a85e5efe4098d554c387679f50fed6248fb961",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "Building 3 hero manifest drifted.") \
	or not _require(FileAccess.get_sha256("res://game/tests/building_3_hero_massing_capture.gd") == EXPECTED_CAPTURE_SCRIPT_SHA256, "Building 3 hero capture harness drifted after capture.") \
	or not _require(FileAccess.get_sha256(HISTORICAL_SOURCE_SNAPSHOT) == EXPECTED_HISTORICAL_SOURCE_SHA256, "Building 3 historical source-bearing capture config was not preserved byte-for-byte.") \
	or not _require(_runtime_config_preserves_historical_semantics(), "Building 3 package-safe runtime config is not the historical capture config with only its source URL removed."):
		_finish()
		return
	for path: String in EXPECTED_CURRENT_FILES:
		if not _require(FileAccess.get_sha256(path) == str(EXPECTED_CURRENT_FILES[path]), "Building 3 exact-bound current file drifted: %s" % path):
			_finish()
			return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if not _require(parsed is Dictionary, "Building 3 hero manifest does not parse."):
		_finish()
		return
	var manifest := parsed as Dictionary
	if not _require(_manifest_contract_matches(manifest), "Building 3 hero pending-review/native/exact-binding contract drifted.") \
	or not _require(_after_captures_match(manifest), "Building 3 hero after-image technical evidence drifted.") \
	or not _require(_before_images_match(manifest), "Building 3 immutable before-image binding drifted."):
		_finish()
		return
	print("PASS: Building 3 evidence binds two original-detail 1440x900 native Metal, grounded, exact-first-hit, full-mass after views to two immutable before views and historical source-bearing config; the current package-safe config is behavior-equivalent with only its URL provenance split to discovery")
	_finish()


func _runtime_config_preserves_historical_semantics() -> bool:
	var historical_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(HISTORICAL_SOURCE_SNAPSHOT))
	var runtime_value: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/facades/building_3_hero_massing.json"))
	if not (historical_value is Dictionary) or not (runtime_value is Dictionary):
		return false
	var historical := (historical_value as Dictionary).duplicate(true)
	var identity := historical.get("authoritative_identity", {}) as Dictionary
	if str(identity.get("nps_asset_url", "")) != "https://npgallery.nps.gov/AssetDetail/NRIS/08000083":
		return false
	identity.erase("nps_asset_url")
	return historical == (runtime_value as Dictionary) \
		and not FileAccess.get_file_as_string("res://game/resources/facades/building_3_hero_massing.json").contains("http")


func _manifest_contract_matches(manifest: Dictionary) -> bool:
	var binding := manifest.get("exact_binding", {}) as Dictionary
	var world := manifest.get("generated_world", {}) as Dictionary
	var truth := manifest.get("truth_boundary", {}) as Dictionary
	var camera := manifest.get("camera_contract", {}) as Dictionary
	var header_ok: bool = str(manifest.get("schema_version", "")) == "ti.building-3-hero-massing-evidence/1" \
		and str(manifest.get("review_status", "")) == "pending_independent_original_detail_review_not_self_accepted" \
		and str(manifest.get("recognition_verdict", "")) == "pending_independent_review" \
		and str(manifest.get("executor_role", "")) == "builder_and_technical_capture_only" \
		and bool(manifest.get("recognition_review_prohibited_for_executor", false)) \
		and str(manifest.get("display_driver", "")) == "macOS" \
		and str(manifest.get("video_adapter", "")).contains("Apple M2") \
		and str(manifest.get("rendering_method", "")) == "Forward+" \
		and str(manifest.get("rendering_driver", "")) == "Metal" \
		and (manifest.get("viewport", []) as Array).size() == 2 \
		and int((manifest.get("viewport", []) as Array)[0]) == 1440 \
		and int((manifest.get("viewport", []) as Array)[1]) == 900
	var identity_ok: bool = str(manifest.get("source_identity", "")) == "w34313540" \
		and str(manifest.get("corrected_nrhp_id", "")) == "08000083" \
		and str(manifest.get("frozen_osm_nrhp_ref_role", "")) == "provenance_only_incorrect_for_building_3" \
		and manifest.get("confusion_set_source_ids_frozen_before_review", []) == ["w24274434", "r16681702"] \
		and int(manifest.get("capture_count", 0)) == 2
	var binding_ok: bool = str(binding.get("profile_signature", "")) == "f82192fe9ebeb04a6da1222bcd84afd217f163ff6ce1cceed826a5d436dd1693" \
		and str(binding.get("wall_geometry_signature", "")) == "e03f830e6a41da16107b5db14bcb8a8ff9f43b46f9df89b1f157958cc68909d4" \
		and str(binding.get("roof_geometry_signature", "")) == "2dee9acf24616423230895d70827acb56c8f402a56ac1fe8e4a93d2409b34b63" \
		and str(binding.get("facade_signature", "")) == "e0b30339bd2ca8642a7b49b5e6153f52017ec4a840e9b0dc1e3841f5373ca5f8" \
		and int(binding.get("wall_triangles", 0)) == 236 \
		and int(binding.get("roof_triangles", 0)) == 675 \
		and int(binding.get("topology_delta_triangles", 0)) == 766 \
		and not bool(binding.get("hidden_generic_wall_or_roof_collision", true))
	var world_ok: bool = int(world.get("meshes", 0)) == 931 and int(world.get("surfaces", 0)) == 941 \
		and int(world.get("triangles", 0)) == 60544 \
		and int(world.get("static_bodies", 0)) == 466 and int(world.get("shapes", 0)) == 466
	var truth_ok: bool = bool(truth.get("horizontal_source_footprint_preserved", false)) \
		and str(truth.get("vertical_dimensions", "")) == "reversible_production_inference_not_surveyed" \
		and bool(truth.get("exterior_only", false)) \
		and not bool(truth.get("interior_modeled", true)) \
		and not bool(truth.get("as_built_fidelity_claimed", true)) \
		and not bool(truth.get("source_photography_shipped", true))
	var camera_ok: bool = bool(camera.get("physics_grounded", false)) \
		and not bool(camera.get("detached_camera", true)) \
		and not bool(camera.get("context_hidden", true)) \
		and not bool(camera.get("lighting_changed", true)) \
		and not bool(camera.get("crop_or_postprocess", true)) \
		and not bool(camera.get("debug_labels_visible", true))
	if not (header_ok and identity_ok and binding_ok and world_ok and truth_ok and camera_ok):
		print("Building 3 evidence manifest diagnostic: header=", header_ok, " identity=", identity_ok, " binding=", binding_ok, " world=", world_ok, " truth=", truth_ok, " camera=", camera_ok)
	return header_ok and identity_ok and binding_ok and world_ok and truth_ok and camera_ok


func _after_captures_match(manifest: Dictionary) -> bool:
	var captures: Array = manifest.get("captures", [])
	if captures.size() != 2:
		return false
	var seen := {}
	for value: Variant in captures:
		var capture := value as Dictionary
		var relative := str(capture.get("file", ""))
		if not EXPECTED_AFTER.has(relative) or seen.has(relative):
			return false
		seen[relative] = true
		var path := EVIDENCE_ROOT.path_join(relative)
		if str(capture.get("sha256", "")) != str(EXPECTED_AFTER[relative]) \
		or FileAccess.get_sha256(path) != str(EXPECTED_AFTER[relative]) \
		or (capture.get("dimensions", []) as Array).size() != 2 \
		or int((capture.get("dimensions", []) as Array)[0]) != 1440 \
		or int((capture.get("dimensions", []) as Array)[1]) != 900 \
		or not bool(capture.get("physics_grounded", false)) \
		or str(capture.get("first_los_hit_receiver", "")) != "building:w34313540:wall" \
		or capture.get("first_los_hit_source_keys", []) != ["w34313540"] \
		or not bool(capture.get("receiver_first_los", false)) \
		or not bool(capture.get("target_bounds_fully_in_frame", false)) \
		or float(capture.get("target_projected_width_ratio", 0.0)) < 0.18 \
		or float(capture.get("target_projected_height_ratio", 0.0)) < 0.12 \
		or not is_equal_approx(float(capture.get("camera_fov_degrees", 0.0)), 70.0) \
		or float(capture.get("actual_spring_length_m", 0.0)) < 4.5 \
		or bool((capture.get("hud", {}) as Dictionary).get("debug_panel_visible", true)) \
		or bool(capture.get("debug_labels_visible", true)) \
		or bool(capture.get("source_photography_in_frame", true)):
			return false
		var image := Image.new()
		if image.load(ProjectSettings.globalize_path(path)) != OK or image.get_size() != Vector2i(1440, 900):
			return false
	return seen.size() == EXPECTED_AFTER.size()


func _before_images_match(manifest: Dictionary) -> bool:
	var before_images: Array = manifest.get("before_images_immutable_prior_runtime", [])
	if before_images.size() != 2:
		return false
	var seen := {}
	for value: Variant in before_images:
		var before := value as Dictionary
		var relative := str(before.get("file", ""))
		if not EXPECTED_BEFORE.has(relative) or seen.has(relative):
			return false
		seen[relative] = true
		if str(before.get("sha256", "")) != str(EXPECTED_BEFORE[relative]) \
		or FileAccess.get_sha256("res://%s" % relative) != str(EXPECTED_BEFORE[relative]):
			return false
	return seen.size() == EXPECTED_BEFORE.size()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
