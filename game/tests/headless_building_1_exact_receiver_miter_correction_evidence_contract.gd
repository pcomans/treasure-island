extends SceneTree

const ROOT := "res://evidence/first-playable/treasure-island-building-1-exact-receiver-miter-correction-2026-08-30"
const RECORD_HASHES := {
	ROOT + "/capture-manifest.json": "63ff0b15e9072b6894e78105a780c3aa401ac6ae58af37840dc501af939f1051",
	ROOT + "/runtime-isolation.json": "756861cbd4a17d48c591efb62fdca2106028df9bd14122bc4f14c9532dbe0479",
	ROOT + "/visual-verification.json": "36c746caca1d4d2208344cc73c0993ef8978ab306eb0d695cb15fa23d33b40e7",
	ROOT + "/README.md": "e6ebf8639ba089fece82eae64d8591f5f53d77ef6c97e95b0d77d652e1b272a8",
	ROOT + "/checksums.sha256": "0fc6f3d2d4c0edeac5f43a5b55210326e208b35facc4b7694899cd7fa2dfec7e",
	"res://discovery/facades/TREASURE_ISLAND_BUILDING_1_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md": "7c1d4fed00fda41b35b8618565622712368504465c45ab4aa443e3460ab4e85b",
	"res://game/resources/facades/building_1_exact_receiver_calibration.json": "10ab1f25d0f9d37ccbb20be9dfe77a37c66f63918b1fdf070c1de9c61633414a",
	"res://game/tests/support/building_1_exact_receiver_calibration.gd": "3a494ba38436b9f68ad02ddaf4e454a0a53c84a777a2999111a67dcc55dae75c",
	"res://game/tests/building_1_exact_receiver_calibration_capture.gd": "addd00cd70c89cb68d888a9e89f8783f6f4e1f15c7914d91ac6f28a54f1337d9",
	"res://game/scenes/world/facades/building_1/building_1_exact_receiver_calibration.tscn": "3fb0c925cec5d65e0d7ed3ca86c1d8d464c4f43965997545af5c0b575978b0cb",
	"res://game/scripts/world/facades/building_1_exact_receiver_calibration_scene.gd": "2b21baff993ee30652072e3f51d95a239d2d22a77e0ff025f0dfe44fb1baa730",
	"res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres": "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a",
	"res://game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader": "a4a5df4fbb8fd4f13187ec284708879b540677ac2c827642b4c3040b4bce4c09",
	"res://evidence/first-playable/treasure-island-building-1-exact-receiver-calibration-2026-08-30/capture-manifest.json": "9e84fb33d095546a422469dc8c5d6433eae194b7300aa1595968cc5a9d2005bb",
}
const PROTECTED_HASHES := {
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://generated/world/chunks/x_-1__z_2.json": "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	"res://game/scripts/world/world_chunk_builder.gd": "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f",
	"res://discovery/facades/TREASURE_ISLAND_BUILDING_1_RUN_OWNERSHIP.json": "716f90b9d7cb3267e901d438a5c583047c8eaeb912e544a459005c2dbe6a4359",
	"res://game/resources/facades/building_1_standalone_prototypes.json": "2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc",
	"res://game/resources/facades/r133351_standalone_prototypes.json": "ecde7b80ba595f61d03bfd21f57407956c3b8988e381f0457f95bfe1aa580ad9",
}
const IMAGE_HASHES := {
	"01-field-join-21-22.png": "67360459c022a2c643523a88de094f914742755162b9e856c35521a095c323e5",
	"02-field-join-30-31.png": "147a38e0ed2d1fc5dba6f1295027535c246318280f56db884b177651c898d91a",
	"03-field-join-38-39.png": "e11b8dd440708612f30ceb1602b18b354301e97139d067a086bc4faa6d89adc5",
	"04-field-join-45-46.png": "33685763c0e67e08d210df71d21bf4c5b68a733b9b55eb00a21caf0cf8d130db",
	"05-field-join-50-51.png": "284ffeb8433530047b4b864235ebcf1579a310e1a5eaa2c08d5358f6d379a354",
	"06-field-macro-85m.png": "e587f8a2ef4464132feb735d5985c731f80ac942a3c50769abedab0d2b0d0a62",
	"07-central-close.png": "650699348a20770a0b057b3e1e12a6e86741266cd9722fed663f4d1e21e78be0",
	"08-central-oblique.png": "7772827d15579eaee94c59e18250a324c64f1f42e566f84af0fa7792422bc47b",
	"09-pavilion-close.png": "623b38dbfb16c0340b55fa797a65bd4d4e1c921264c80e2d7d3609f861621fc0",
	"10-pavilion-oblique.png": "9ef73820384346ace6beacd26220994897459e54df7129a4cb0995f01de65b5c",
	"11-central-ordinary.png": "cd2bd63dea6c15d75cd240283763deb94d4c7d7fafeb528510c755c22cdb68ee",
	"12-pavilion-ordinary.png": "2cdf34dde54e7938fdafe4a6867e3640d05bf2ccbf4f9b284ceb08cff8ee6373",
	"13-whole-building-context.png": "0262a608bb4d3241a25d3364648ac0c11b0d5633ddc1767d93e703599a8fb51f",
	"14-central-changed-light.png": "99326bfc20bceffef2c675304990c65c88cfc8fdca0b1d54713c8e6188bd816c",
	"15-pavilion-changed-light.png": "16afc30b602d258a807df6841fcb8ddf7fc7d5d6e58e8e641514c569e585150d",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(_hashes_match(RECORD_HASHES), "A correction evidence/source record drifted.")
	_require(_hashes_match(PROTECTED_HASHES), "A protected runtime/mapping/standalone/r133351 byte drifted.")
	_require(_images_match(), "A correction image drifted or is not a valid 1440x900 PNG.")
	var manifest := _json(ROOT + "/capture-manifest.json")
	var isolation := _json(ROOT + "/runtime-isolation.json")
	var verification := _json(ROOT + "/visual-verification.json")
	var miter := manifest.get("rendered_overlay_miter_correction", {}) as Dictionary
	var joins := manifest.get("rendered_overlay_join_records", []) as Array
	var topology := manifest.get("topology", {}) as Dictionary
	_require(str(manifest.get("review_status", "")) == "ready_for_independent_detached_miter_correction_rereview_not_self_accepted", "Correction review status drifted.")
	_require(int(miter.get("join_count", -1)) == 30 and float(miter.get("maximum_shared_miter_gap_after_m", -1.0)) == 0.0, "Complete shared-miter proof drifted.")
	_require(absf(float(miter.get("maximum_independently_offset_gap_before_m", 0.0)) - 0.026857801) < 0.00005, "Maximum before-gap no longer agrees with review tolerance.")
	_require(joins.size() == 30 and _all_joins_closed(joins), "One of 30 corrected joins is not watertight.")
	_require(int(topology.get("field_vertices", -1)) == 124 and int(topology.get("field_triangles", -1)) == 62 and int(topology.get("total_meshes", -1)) == 23 and int(topology.get("total_surfaces", -1)) == 23 and int(topology.get("total_triangles", -1)) == 326, "Correction changed topology.")
	_require(str(isolation.get("result", "")) == "PASS" and not bool(isolation.get("detached_runtime_attachment", true)) and isolation.get("receiver_child_count_before_and_after_overlay", []) == [2.0, 2.0], "Runtime isolation drifted.")
	_require(str(verification.get("art_verdict", "")) == "withheld_for_independent_correction_reviewer" and bool(verification.get("all_images_opened_and_inspected", false)) and not bool(verification.get("self_acceptance", true)), "Visual inspection record is incomplete or self-accepting.")
	if not _failed:
		print("PASS: Building 1 shared-miter correction evidence seals 15 native views, all 30 joins at 0.0 m after-gap, unchanged 23/23/326 detached topology, unchanged module studies, and protected runtime bytes; independent correction re-review remains required")
	quit(1 if _failed else 0)


func _all_joins_closed(joins: Array) -> bool:
	for value: Variant in joins:
		var join := value as Dictionary
		if float(join.get("shared_miter_bottom_gap_after_m", -1.0)) != 0.0 or float(join.get("shared_miter_top_gap_after_m", -1.0)) != 0.0:
			return false
	return true


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
