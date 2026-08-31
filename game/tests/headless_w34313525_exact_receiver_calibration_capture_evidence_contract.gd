extends SceneTree

const ROOT := "res://evidence/first-playable/batch-06-w34313525-exact-receiver-calibration-2026-08-30"
const MANIFEST_PATH := ROOT + "/capture-manifest.json"
const EXPECTED_MANIFEST_SHA256 := "2d5bb60145357287c4b45ad10bccfc74ad73e0abd658851868c42cf332e8a0ec"
const EXPECTED_IMAGE_HASHES := {
	"01-sse-field-join-08-09": "427e6f1f8b3931cadfa89c0ad00653a295b623d88471d7498722b41237dc55ae",
	"02-sse-field-join-09-10": "820b0caad71f31ef6bec192d2a8a2df78332782ce17f39f89625833e2f49d6f2",
	"03-sse-field-join-10-11": "cf1d73dd025ea0a17afd9717f9809654bdc97ca08927b0fe642b95388cf13b58",
	"04-sse-field-join-11-12": "e3a71a97e3563d74716aa16ba0518469be71c92c95300a58c28070d13ed405ad",
	"05-nnw-field-join-26-27": "4501722e7aabebd81031018bb385147d1dd6b72b5f50da182085d6fdc58431d3",
	"06-close-rollup-pale": "287356a18f32f9fcb00e2dd41304c4427805468bf1b4cae5d99a94a82505e078",
	"07-close-rollup-gray": "e203ae35cd642c2c546666e798e4066975f0dbd586fd9c4c06f8e158c8700e69",
	"08-close-personnel": "b740600245b56df7471024de369335e4309480fd19ee7c412cdad520aa29d234",
	"09-close-high-group": "b20197315ffc3e80334a34421c31897c9055e1655c12f651448f215ef1a92416",
	"10-ordinary-sse-macro": "9be8eed713f306149adc22d5d557ccfa39c01c9869ef4af0bd77a90b28f48a52",
	"11-ordinary-nnw-macro": "6ac10e071b1441a7b0efca9e7a795aff8a744fcca248660607e071edfdbd5f4a",
	"12-building-multiside-context": "54ab377a6034fb015fa949e51026dd84aa15f3e542e8fa1157da2765baed2d5c",
	"13-changed-light-sse": "02058eb87d2b3528aa5f7eef5a08ec71c37d4ddd028141ee07f8ab84ad417e06",
	"14-changed-light-nnw": "64d9524785a70b810844eef23b71963a31df7b74ecd5a34b1aff2f1cd69202d4",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "w34313525 calibration capture manifest drifted."):
		_finish()
		return
	var manifest := JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH)) as Dictionary
	if not _require(_manifest_matches(manifest), "Renderer, scope, topology isolation, truth boundary, or coverage metadata drifted.") \
	or not _require(_images_match(manifest), "One or more of the fourteen native PNGs drifted, became invalid, or lost manifest identity."):
		_finish()
		return
	print("PASS: w34313525 detached exact-receiver evidence retains fourteen inspected 1440x900 native Forward+/Metal frames covering every SSE/NNW field join, all four complete modules, both ordinary side contexts, building context, and changed light for every material family; manifest, PNG hashes, receiver 2→2 isolation, and loaded-world 886/894/50273 topology identity all match")
	_finish()


func _manifest_matches(manifest: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.w34313525-exact-receiver-calibration-evidence/1" \
	or str(manifest.get("review_status", "")) != "ready_for_independent_detached_exact_receiver_art_review_not_self_accepted" \
	or str(manifest.get("display_driver", "")) != "macOS" \
	or str(manifest.get("rendering_method", "")) != "Forward+" \
	or str(manifest.get("rendering_driver", "")) != "Metal" \
	or int(manifest.get("capture_count", -1)) != 14 \
	or manifest.get("viewport", []) != [1440.0, 900.0]:
		return false
	if str(manifest.get("registry_sha256", "")) != "ba22916618510f610719606c1c18f84b8965bbd76fe74eddc5430745470bbddd" \
	or str(manifest.get("helper_sha256", "")) != "a9ff1f94274509cdb39c6208117c59b84ba67598ff8a59a1eb57bf30a4b03532":
		return false
	var topology := manifest.get("loaded_world_before_and_after_overlay", {}) as Dictionary
	var before := topology.get("before", {}) as Dictionary
	var after := topology.get("after", {}) as Dictionary
	if JSON.stringify(before) != JSON.stringify(after) \
	or int(before.get("chunks", -1)) != 38 \
	or int(before.get("meshes", -1)) != 886 \
	or int(before.get("surfaces", -1)) != 894 \
	or int(before.get("triangles", -1)) != 50273 \
	or int(before.get("static_bodies", -1)) != 466 \
	or int(before.get("shapes", -1)) != 466 \
	or manifest.get("receiver_child_count_before_and_after_overlay", []) != [2.0, 2.0]:
		return false
	var scopes := manifest.get("exact_field_scopes", []) as Array
	var placements := manifest.get("placements", []) as Array
	var resolved := manifest.get("resolved_placements", []) as Array
	if scopes.size() != 2 or placements.size() != 4 or resolved.size() != 4:
		return false
	for value: Variant in placements:
		var placement := value as Dictionary
		for false_key in ["surveyed_dimensions", "surveyed_coordinates", "surveyed_count", "surveyed_cadence", "completed_elevation", "whole_building_accepted", "runtime_attachment"]:
			if bool(placement.get(false_key, true)):
				return false
	var detached := manifest.get("detached_overlay", {}) as Dictionary
	return int(detached.get("total_meshes", -1)) == 40 \
		and int(detached.get("total_surfaces", -1)) == 40 \
		and int(detached.get("total_triangles", -1)) == 470 \
		and int(detached.get("module_field_or_backing_meshes", -1)) == 0 \
		and not bool(detached.get("runtime_attachment", true))


func _images_match(manifest: Dictionary) -> bool:
	var captures := manifest.get("captures", []) as Array
	if captures.size() != EXPECTED_IMAGE_HASHES.size():
		return false
	var covered_ids := {}
	for value: Variant in captures:
		var capture := value as Dictionary
		var id := str(capture.get("id", ""))
		if not EXPECTED_IMAGE_HASHES.has(id) or covered_ids.has(id):
			return false
		covered_ids[id] = true
		var path := ROOT.path_join(str(capture.get("file", "")))
		var expected_hash := str(EXPECTED_IMAGE_HASHES[id])
		if not FileAccess.file_exists(path) \
		or FileAccess.get_sha256(path) != expected_hash \
		or str(capture.get("sha256", "")) != expected_hash \
		or int(capture.get("bytes", 0)) != FileAccess.get_file_as_bytes(path).size() \
		or capture.get("dimensions", []) != [1440.0, 900.0] \
		or float((capture.get("sampled_luminance", {}) as Dictionary).get("range", 0.0)) < 0.1:
			return false
	var required := [
		"01-sse-field-join-08-09", "02-sse-field-join-09-10", "03-sse-field-join-10-11", "04-sse-field-join-11-12", "05-nnw-field-join-26-27",
		"06-close-rollup-pale", "07-close-rollup-gray", "08-close-personnel", "09-close-high-group",
		"10-ordinary-sse-macro", "11-ordinary-nnw-macro", "12-building-multiside-context", "13-changed-light-sse", "14-changed-light-nnw"
	]
	for id: String in required:
		if not covered_ids.has(id):
			return false
	return true


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_failed = true
		push_error(message)
	return condition


func _finish() -> void:
	quit(1 if _failed else 0)
