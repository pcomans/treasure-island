extends SceneTree

const ROOT := "res://evidence/first-playable/treasure-island-building-1-live-ivory-field-2026-08-30"
const RECORD_HASHES := {
	ROOT + "/capture-manifest.json": "e9d0b425b0c9f4f6cdb2b5f35ede320d3cf897d50514aa38e9c3d24dd6c336aa",
	ROOT + "/runtime-isolation.json": "af246731c9ce5755fd8a80bb90095f5d81df881abad5760fe8a3fb3434bf2065",
	ROOT + "/visual-verification.json": "b8ee2a0e197c83ba897146c28e915b42bf3bf89decdcecd634fd5e373c15308c",
	ROOT + "/README.md": "c343b0f5862bd6a466af33dd49b04b263e1dab32566e32bae95eeb9e778fcde3",
	ROOT + "/checksums.sha256": "e17e393c7aa74a695616dc67ec91326af77e962b4289d0b6d2119a7493d223b6",
	"res://discovery/facades/TREASURE_ISLAND_BUILDING_1_EXACT_RECEIVER_MITER_CORRECTION_ART_REVIEW.md": "499f24ae196a42c9c27737fb484c690bd2f228a0ebcc5ba3622606958cd1179e",
	"res://game/resources/facades/building_1_exact_receiver_calibration.json": "10ab1f25d0f9d37ccbb20be9dfe77a37c66f63918b1fdf070c1de9c61633414a",
	"res://game/tests/support/building_1_exact_receiver_calibration.gd": "3a494ba38436b9f68ad02ddaf4e454a0a53c84a777a2999111a67dcc55dae75c",
	"res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres": "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a",
	"res://game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader": "a4a5df4fbb8fd4f13187ec284708879b540677ac2c827642b4c3040b4bce4c09",
	"res://game/scripts/world/facades/building_1_live_field.gd": "dd738d185cba3f0c14edf51253710598d485d1aa3c2aca9b4ca1ea794c1a2fc2",
	"res://game/scripts/world/world_chunk_builder.gd": "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42",
}
const PROTECTED_HASHES := {
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://generated/world/chunks/x_-1__z_2.json": "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://discovery/facades/TREASURE_ISLAND_BUILDING_1_RUN_OWNERSHIP.json": "716f90b9d7cb3267e901d438a5c583047c8eaeb912e544a459005c2dbe6a4359",
	"res://game/resources/facades/building_1_standalone_prototypes.json": "2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc",
	"res://game/resources/facades/r133351_standalone_prototypes.json": "ecde7b80ba595f61d03bfd21f57407956c3b8988e381f0457f95bfe1aa580ad9",
}
const IMAGE_HASHES := {
	"01-close-join-38-39.png": "9c56fbf859af655d287123585995b63e2d741af22ec48380033a30b3858eb273",
	"02-close-join-42-43.png": "b696e044c8f4e0f40528bdb45afe82e170b35ab1705da4777a2e8847a542d18a",
	"03-close-join-21-22.png": "d308bc4395bf45db7c025945e9b60304cee85c7df9eacee0f9249f66ade7d578",
	"04-macro-public-curve-85m.png": "6edb66fdb18a0b7205fd70beba42d1c759e84b9187274a31e60b76ca1d759ee1",
	"05-nearest-gameplay-curve.png": "ad6d3a3a9fcbabaf2ce90ba9e9868a7dd6ab2ec28c351491e03716044c98a0f4",
	"06-ordinary-public-curve.png": "e2f66694b239301f37c3e415b049d6c26a5a77bd3723089002022d980128cf0a",
	"07-oblique-public-curve.png": "e39ec6deb36e50049a1b41091d2d4b3de6fff30d6fed45bd9f94241711b91821",
	"08-multiside-building-context.png": "9e445c7c1656af6aba806ee8b5c926988c61c26622a380af0e9e1d3b8b518a3d",
	"09-whole-building-context.png": "6804449072b5b6c2c623f4f2306246faa91f5d580ea5691f59a16c81c26548bd",
	"10-changed-light-public-curve.png": "052fa3897e88c1ffb3896147bfac02d56f06306a99705340925ed3b3f31896e6",
	"11-whole-island.png": "dd0ce807ff8ada08dba750445ff8d5e0596c8761f9b23cdb77e6f151952128c0",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(_hashes_match(RECORD_HASHES), "A live evidence/source record drifted.")
	_require(_hashes_match(PROTECTED_HASHES), "A protected generated/mapping/standalone/r133351 byte drifted.")
	_require(_images_match(), "A live evidence image drifted or is not a valid 1440x900 PNG.")
	var manifest := _json(ROOT + "/capture-manifest.json")
	var isolation := _json(ROOT + "/runtime-isolation.json")
	var verification := _json(ROOT + "/visual-verification.json")
	var scope := manifest.get("field_scope", {}) as Dictionary
	var delta := manifest.get("exact_runtime_delta", {}) as Dictionary
	var truth := manifest.get("truth_boundary", {}) as Dictionary
	var before := isolation.get("runtime_before", {}) as Dictionary
	var after := isolation.get("runtime_after", {}) as Dictionary
	_require(str(manifest.get("review_status", "")) == "pending_independent_actual_world_art_review_not_self_accepted", "Live review status drifted.")
	_require(int(manifest.get("capture_count", -1)) == 11 and (manifest.get("captures", []) as Array).size() == 11, "Capture inventory drifted.")
	_require(str(manifest.get("display_driver", "")) == "macOS" and str(manifest.get("rendering_method", "")) == "Forward+" and str(manifest.get("rendering_driver", "")) == "Metal", "Renderer contract drifted.")
	_require(int(scope.get("run_count", -1)) == 31 and absf(float(scope.get("physical_length_m", 0.0)) - 85.939934) < 0.000001 and absf(float(scope.get("surface_area_m2", 0.0)) - 1740.731069) < 0.000001, "Exact field scope drifted.")
	_require(_runs_exact(scope.get("exact_ordered_runs", []) as Array), "Exact ordered runs drifted.")
	_require(float(scope.get("maximum_join_gap_m", -1.0)) == 0.0 and float(scope.get("maximum_join_phase_delta_m", -1.0)) == 0.0, "Watertight/phase proof drifted.")
	_require(int(delta.get("overlay_meshes", -1)) == 1 and int(delta.get("overlay_surfaces", -1)) == 1 and int(delta.get("overlay_triangles", -1)) == 62 and int(delta.get("collision_nodes", -1)) == 0, "Exact live delta drifted.")
	_require(int(delta.get("module_placements", -1)) == 0 and int(delta.get("module_meshes", -1)) == 0 and int(truth.get("module_placement_count", -1)) == 0, "A Building 1 module entered live evidence.")
	_require(_topology_exact(before, 924, 934, 50729), "Before topology drifted.")
	_require(_topology_exact(after, 925, 935, 50791), "After topology drifted.")
	_require(str(isolation.get("result", "")) == "PASS" and not bool(isolation.get("receiver_geometry_changed", true)) and not bool(isolation.get("receiver_collision_changed", true)) and not bool(isolation.get("generated_data_changed", true)), "Runtime isolation drifted.")
	_require(bool(verification.get("all_images_opened_and_inspected", false)) and not bool(verification.get("self_acceptance", true)) and str(verification.get("art_verdict", "")) == "withheld_for_independent_actual_world_reviewer", "Visual inspection record is incomplete or self-accepting.")
	if not _failed:
		print("PASS: Building 1 live field evidence seals 11 native actual-world views, exact runs 21..51, 30 watertight joins, +1/+1/+62/+0 topology, zero modules, and protected bytes; independent actual-world art review remains required")
	quit(1 if _failed else 0)


func _runs_exact(runs: Array) -> bool:
	if runs.size() != 31:
		return false
	for index in runs.size():
		if int(runs[index]) != index + 21:
			return false
	return true


func _topology_exact(topology: Dictionary, meshes: int, surfaces: int, triangles: int) -> bool:
	return int(topology.get("records", -1)) == 729 \
		and int(topology.get("meshes", -1)) == meshes \
		and int(topology.get("surfaces", -1)) == surfaces \
		and int(topology.get("triangles", -1)) == triangles \
		and int(topology.get("static_bodies", -1)) == 466 \
		and int(topology.get("shapes", -1)) == 466


func _images_match() -> bool:
	for name_value: Variant in IMAGE_HASHES:
		var name := str(name_value)
		var path := ROOT.path_join("images").path_join(name)
		if FileAccess.get_sha256(path) != str(IMAGE_HASHES[name_value]):
			return false
		var image := Image.load_from_file(path)
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900):
			return false
	return true


func _hashes_match(expected: Dictionary) -> bool:
	for path_value: Variant in expected:
		if FileAccess.get_sha256(str(path_value)) != str(expected[path_value]):
			return false
	return true


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _require(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
