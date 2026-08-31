extends SceneTree

const ROOT := "res://evidence/first-playable/w34313525-live-fields-and-modules-2026-08-30"
const MANIFEST_PATH := ROOT + "/capture-manifest.json"
const EXPECTED_MANIFEST_SHA256 := "bf97fc1df3b80e7d90cda9d9ca2cc3586681c7d3f3192cf76040835f51e49a1a"
const EXPECTED_IMAGES := {
	"images/01-sse-field-join-08-09.png": "79e689c51dd6e67c5a24aae704dd291f317b9c73bb55e567db49164bcd01cdc2",
	"images/02-sse-field-join-09-10.png": "ef03c7735e7aa275e36b6049841b6a4f86410140ba5d71d0edef07c3285b49dd",
	"images/03-sse-field-join-10-11.png": "1a8a529edc502167f8ea76e287949ec11ecccff798915173f3b740b101c14fda",
	"images/04-sse-field-join-11-12.png": "dea0fd5f2bcafd9edf52cf5c17a7456e856b8b03f1611010fab1c0acf2024a19",
	"images/05-nnw-field-join-26-27.png": "4fac427ebb995abfa306a8556822ba3b31bbbd5b7ca5eeba9501aeb6afec0671",
	"images/06-close-rollup-pale.png": "2942c0eca4e7ecfa51c165be28b4d454d6c0dcaa69aa9d7cbb974cda837832d9",
	"images/07-close-rollup-gray.png": "c895ff4ea370ff10940481669e9b68986d56b84147ce4e807d29ac0fa478604b",
	"images/08-close-personnel.png": "f632dbdf0355bd4d37938d699b5f4247e35b39eb389d1b82c8119ed0eef714f3",
	"images/09-close-high-group.png": "36d7413ef2225e94d8e5b57dee38920e9acb6675bf0fe52e5d3ff8bbcf615e31",
	"images/10-ordinary-sse-macro.png": "ab594cc3ee93c65c945f1a0928fd09b3792ac0c9528ef3fb843b0ccc8bf116c2",
	"images/11-ordinary-nnw-full-scope.png": "2c063cc8bf31e6c364a7510ed2e5daecacd07f0dcb2d8d6d14e801c314e979d4",
	"images/12-building-multiside-context.png": "c5129fdc2885c8ae5e8ffdb0fde81396efbb637c39e84a4bee36d521841129e4",
	"images/13-changed-light-sse.png": "81462e8f1322c4c006a15c683d74965a50ded301362f7d29780e06e6c9b09c3c",
	"images/14-changed-light-nnw.png": "a93e4a198fca0e2ed3d2312f6efc0c86bcf9e72c98973d8bf284e933fe0021d2",
	"images/15-whole-island.png": "97fbd5102f362dbe47a789283548bcc005808c29cfd1b1660bca4a8ca52cb952",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manifest := JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH)) as Dictionary
	if not _require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "Live capture manifest bytes drifted.") \
	or not _require(_manifest_matches(manifest), "Live capture metadata, topology, coverage, or truth boundary drifted.") \
	or not _require(_images_match(manifest), "A live evidence PNG is missing, invalid, or hash-mismatched."):
		_finish()
		return
	print("PASS: fifteen native 1440x900 Forward+/Metal actual-world frames remain byte-sealed and cover all five joins, four complete motifs, ordinary/macro SSE and NNW, both changed-light sides, multi-side context, and whole island; the manifest preserves capture-time pre-review provenance while canonical lifecycle acceptance is asserted separately, and all surveyed/completion claims remain false")
	_finish()


func _manifest_matches(manifest: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.w34313525-live-fields-and-modules-evidence/1" \
	or str(manifest.get("source_key", "")) != "w34313525" \
	or str(manifest.get("receiver_key", "")) != "building:w34313525:wall" \
	or str(manifest.get("review_status", "")) != "ready_for_independent_actual_world_art_review_not_self_accepted" \
	or int(manifest.get("capture_count", -1)) != 15 \
	or str(manifest.get("godot_version", "")) != "4.7.2-stable (official)" \
	or str(manifest.get("rendering_method", "")) != "Forward+" \
	or str(manifest.get("rendering_driver", "")) != "Metal" \
	or not bool(manifest.get("generated_source_and_data_bytes_unchanged", false)):
		return false
	var before := manifest.get("loaded_world_before_this_integration", {}) as Dictionary
	var live := manifest.get("live_reported_world", {}) as Dictionary
	var delta := manifest.get("exact_runtime_delta", {}) as Dictionary
	if int(before.get("meshes", -1)) != 886 or int(before.get("surfaces", -1)) != 894 or int(before.get("triangles", -1)) != 50273 \
	or int(live.get("meshes", -1)) != 924 or int(live.get("surfaces", -1)) != 934 or int(live.get("triangles", -1)) != 50729 or int(live.get("static_bodies", -1)) != 466 or int(live.get("shapes", -1)) != 466 \
	or int(delta.get("mesh_instances", -1)) != 38 or int(delta.get("loaded_surfaces", -1)) != 40 or int(delta.get("triangles", -1)) != 456 or int(delta.get("collision_nodes", -1)) != 0:
		return false
	if manifest.get("field_join_capture_ids", []) != ["01-sse-field-join-08-09", "02-sse-field-join-09-10", "03-sse-field-join-10-11", "04-sse-field-join-11-12", "05-nnw-field-join-26-27"] \
	or manifest.get("changed_light_capture_ids", []) != ["13-changed-light-sse", "14-changed-light-nnw"] \
	or str(manifest.get("whole_island_capture_id", "")) != "15-whole-island":
		return false
	var truth := manifest.get("truth_boundary", {}) as Dictionary
	for key in ["cadence_inferred", "cadence_surveyed", "completed_nnw_elevation", "completed_sse_elevation", "coordinates_surveyed", "count_surveyed", "cross_side_transfer_accepted", "dimensions_surveyed", "maximum_uncertainty_envelope_contained_for_all_modules", "scale_surveyed", "sequence_inferred", "whole_building_accepted"]:
		if bool(truth.get(key, true)):
			return false
	return str(truth.get("high_group_semantic_face_status", "")) == "window_or_grille_not_disambiguated_opaque_proxy_only"


func _images_match(manifest: Dictionary) -> bool:
	var captures := manifest.get("captures", []) as Array
	if captures.size() != EXPECTED_IMAGES.size():
		return false
	var seen := {}
	for value: Variant in captures:
		var capture := value as Dictionary
		var path := str(capture.get("file", ""))
		if not EXPECTED_IMAGES.has(path) or seen.has(path) \
		or str(capture.get("sha256", "")) != str(EXPECTED_IMAGES[path]) \
		or FileAccess.get_sha256("%s/%s" % [ROOT, path]) != str(EXPECTED_IMAGES[path]) \
		or int(capture.get("bytes", 0)) < 100000:
			return false
		var image := Image.load_from_file("%s/%s" % [ROOT, path])
		if image == null or image.get_width() != 1440 or image.get_height() != 900:
			return false
		seen[path] = true
	return seen.size() == EXPECTED_IMAGES.size()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
