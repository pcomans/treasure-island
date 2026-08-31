extends SceneTree

const ROOT := "res://evidence/first-playable/treasure-island-building-1-exact-receiver-calibration-2026-08-30"
const EXPECTED_RECORD_HASHES := {
	"res://evidence/first-playable/treasure-island-building-1-exact-receiver-calibration-2026-08-30/capture-manifest.json": "9e84fb33d095546a422469dc8c5d6433eae194b7300aa1595968cc5a9d2005bb",
	"res://evidence/first-playable/treasure-island-building-1-exact-receiver-calibration-2026-08-30/runtime-isolation.json": "b7d77ef861ce0e5f17a0577e9680f153111b95a477fa330af8ee420894489878",
	"res://evidence/first-playable/treasure-island-building-1-exact-receiver-calibration-2026-08-30/visual-verification.json": "2d7672d43cb6ae67d6bfdb65fda272a18a97fdc1138bdb1590214f8725825f58",
	"res://evidence/first-playable/treasure-island-building-1-exact-receiver-calibration-2026-08-30/README.md": "8ef6448a5dd609575f09a4a8738bcb1441bab28b020cf67eaea90f4d8b170a1a",
	"res://evidence/first-playable/treasure-island-building-1-exact-receiver-calibration-2026-08-30/checksums.sha256": "1578935f859522342396c98feb3116350ff8ae5c43cbddefea278f0b6440ce65",
	"res://game/resources/facades/building_1_exact_receiver_calibration.json": "10ab1f25d0f9d37ccbb20be9dfe77a37c66f63918b1fdf070c1de9c61633414a",
	"res://game/tests/support/building_1_exact_receiver_calibration.gd": "b31bda7a510b2f343f0db0f0199128b0c945cb5e7afc60b69e0d9801aff5be79",
	"res://game/tests/building_1_exact_receiver_calibration_capture.gd": "d642d7a7bdf90ad42b3c1dd0364ae4a005c7666fc99f69e1d26ddf1e4bf8f276",
	"res://game/scenes/world/facades/building_1/building_1_exact_receiver_calibration.tscn": "3fb0c925cec5d65e0d7ed3ca86c1d8d464c4f43965997545af5c0b575978b0cb",
	"res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres": "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a",
	"res://game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader": "a4a5df4fbb8fd4f13187ec284708879b540677ac2c827642b4c3040b4bce4c09",
}
const EXPECTED_PROTECTED_HASHES := {
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://generated/world/chunks/x_-1__z_2.json": "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	"res://game/scripts/world/world_chunk_builder.gd": "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f",
	"res://discovery/facades/TREASURE_ISLAND_BUILDING_1_RUN_OWNERSHIP.json": "716f90b9d7cb3267e901d438a5c583047c8eaeb912e544a459005c2dbe6a4359",
	"res://game/resources/facades/building_1_standalone_prototypes.json": "2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc",
	"res://game/resources/facades/r133351_standalone_prototypes.json": "ecde7b80ba595f61d03bfd21f57407956c3b8988e381f0457f95bfe1aa580ad9",
}
const EXPECTED_IMAGES := {
	"01-field-join-21-22.png": "dac664de10f7d85e16f4cd9d7542bf457f66a5c901bff728f4ecc87245a21229",
	"02-field-join-30-31.png": "c5882a75f47061a58b88929d8b6d56186e5a94d35a632d60721806bcf10c5e42",
	"03-field-join-38-39.png": "ff71bec44e2c9c7a6e04b8fc5c3268a675ac83f01074271db4c2242d74f0370e",
	"04-field-join-45-46.png": "29c88df108519e0820bea52380a631157a0096fcc7596879be1e6b1ea7952d3b",
	"05-field-join-50-51.png": "1bbed6cc060df8e06f8c52e714e7d9e051cf3ae5c5f60982728b5ebc22ee1e65",
	"06-field-macro-85m.png": "a31db222dbb28534835cf87a12d6408261a47646f8d969dc9f912e28c96a5a19",
	"07-central-close.png": "49e4fb3d9cb31f0d1994090c5213296374c3e00c58fc54cb2ed9803ca8c992f2",
	"08-central-oblique.png": "98d827cb998aa0e2176fa7fd31328cd17c0a1e0b2181461a033406c5c8541e00",
	"09-pavilion-close.png": "089c52b7ed2ce17c56373de569ed719bf26073e7a9d637800fe4c83f4c72dbba",
	"10-pavilion-oblique.png": "6d91c4082ebd617b9ede946902f072a5c1e42319088b0d04d9af1bfaa33f1a07",
	"11-central-ordinary.png": "53790b5ea4464fc9a6d391b5e838c2b88ace1545f52f87daf21ac0e0bffeb901",
	"12-pavilion-ordinary.png": "a14d94d642a43c381be253799340942f81bb9aaaf2b6a3f7d7b9670f17a4b67e",
	"13-whole-building-context.png": "a324ec70b13a56a8d98f24d49ad78cd4aa9630fd3006a20b1e87bd64e0451764",
	"14-central-changed-light.png": "74bf13322d27d7d76a2591cd5c9716e692bf29c11fba0b2bba14a3d7b8e0cdb5",
	"15-pavilion-changed-light.png": "9a16b78a89457a6bb7725d47ba06702fc3e9be2cda4b67903d3a1b4bd9810459",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(_hashes_match(EXPECTED_RECORD_HASHES), "A sealed Building 1 calibration evidence/source record drifted.")
	_require(_hashes_match(EXPECTED_PROTECTED_HASHES), "A protected runtime/mapping/standalone/r133351 input drifted.")
	_require(_images_match(), "A Building 1 calibration PNG drifted or failed native image checks.")
	var manifest := _json(ROOT.path_join("capture-manifest.json"))
	var isolation := _json(ROOT.path_join("runtime-isolation.json"))
	var verification := _json(ROOT.path_join("visual-verification.json"))
	_require(_manifest_matches(manifest), "Calibration manifest lost exact scope, renderer, topology, coverage, or truth boundaries.")
	_require(_isolation_matches(isolation), "Calibration runtime-isolation assertions drifted.")
	_require(_verification_matches(verification), "Calibration visual verification is incomplete or self-accepting.")
	if not _failed:
		print("PASS: Building 1 detached calibration evidence seals 15 native 1440x900 Forward+/Metal views, exact MAT-IVORY runs 21..51 at 85.939934 m / 1740.731069 m2 with 30 zero-delta joins, CENTRAL/PAV fit studies on runs 36/6, 23/23/326 topology, and unchanged receiver/runtime/protected bytes; no self-acceptance or live placement claim")
	quit(1 if _failed else 0)


func _manifest_matches(manifest: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.building-1-detached-exact-receiver-calibration-evidence/1" \
	or str(manifest.get("review_status", "")) != "ready_for_independent_detached_exact_receiver_art_review_not_self_accepted" \
	or str(manifest.get("source_key", "")) != "r16681702" \
	or str(manifest.get("receiver_key", "")) != "building:r16681702:wall" \
	or str(manifest.get("display_driver", "")) != "macOS" \
	or str(manifest.get("rendering_method", "")) != "Forward+" \
	or str(manifest.get("rendering_driver", "")) != "Metal" \
	or "Apple M1 Pro" not in str(manifest.get("video_adapter", "")) \
	or manifest.get("viewport", []) != [1440.0, 900.0] \
	or int(manifest.get("capture_count", -1)) != 15:
		return false
	var field := manifest.get("exact_field_scope", {}) as Dictionary
	var uv := field.get("meter_and_uv_contract", {}) as Dictionary
	if int(field.get("run_count", -1)) != 31 \
	or absf(float(field.get("physical_wall_length_m", 0.0)) - 85.939934) > 0.000001 \
	or absf(float(field.get("generated_mesh_surface_area_m2", 0.0)) - 1740.731069) > 0.000001 \
	or int(uv.get("internal_join_count", -1)) != 30 \
	or float(uv.get("maximum_endpoint_delta_m", -1.0)) != 0.0 \
	or float(uv.get("maximum_join_phase_delta_m", -1.0)) != 0.0:
		return false
	var topology := manifest.get("topology", {}) as Dictionary
	if int(topology.get("total_meshes", -1)) != 23 \
	or int(topology.get("total_surfaces", -1)) != 23 \
	or int(topology.get("total_triangles", -1)) != 326 \
	or int(topology.get("module_field_or_backing_meshes", -1)) != 0 \
	or int(topology.get("collision_nodes", -1)) != 0 \
	or int(topology.get("navigation_nodes", -1)) != 0 \
	or int(topology.get("spray_nodes", -1)) != 0 \
	or bool(topology.get("runtime_attachment", true)):
		return false
	var studies := manifest.get("fit_studies", []) as Array
	if studies.size() != 2 \
	or str((studies[0] as Dictionary).get("fit_study_id", "")) != "FIT-CENTRAL-W-R36" \
	or int((studies[0] as Dictionary).get("representative_run", -1)) != 36 \
	or str((studies[1] as Dictionary).get("fit_study_id", "")) != "FIT-PAV-W-R06" \
	or int((studies[1] as Dictionary).get("representative_run", -1)) != 6:
		return false
	for value: Variant in studies:
		var study := value as Dictionary
		if bool(study.get("real_placement_authorized", true)) \
		or bool(study.get("surveyed_dimensions", true)) \
		or bool(study.get("surveyed_coordinates", true)) \
		or bool(study.get("surveyed_count", true)) \
		or bool(study.get("surveyed_cadence", true)):
			return false
	var captures := manifest.get("captures", []) as Array
	if captures.size() != 15:
		return false
	for value: Variant in captures:
		var capture := value as Dictionary
		var name := str(capture.get("file", "")).get_file()
		if not EXPECTED_IMAGES.has(name) \
		or str(capture.get("sha256", "")) != str(EXPECTED_IMAGES[name]) \
		or capture.get("dimensions", []) != [1440.0, 900.0] \
		or float((capture.get("sampled_luminance", {}) as Dictionary).get("range", 0.0)) <= 0.1:
			return false
	var blocked := manifest.get("blocked_claims", {}) as Dictionary
	return blocked.size() >= 10 and not bool(blocked.get("actual_world_anchor", true)) and not bool(blocked.get("whole_building_accepted", true)) and not bool(blocked.get("live_attachment", true))


func _isolation_matches(isolation: Dictionary) -> bool:
	var topology := isolation.get("protected_runtime_topology", {}) as Dictionary
	var assertions := isolation.get("assertions", {}) as Dictionary
	if str(isolation.get("result", "")) != "PASS" \
	or bool(isolation.get("detached_runtime_attachment", true)) \
	or int(isolation.get("actual_world_placement_count", -1)) != 0 \
	or isolation.get("receiver_child_count_before_and_after_overlay", []) != [2.0, 2.0] \
	or int(topology.get("loaded_records", -1)) != 729 \
	or int(topology.get("loaded_meshes", -1)) != 924 \
	or int(topology.get("loaded_surfaces", -1)) != 934 \
	or int(topology.get("loaded_triangles", -1)) != 50729 \
	or int(topology.get("static_bodies", -1)) != 466:
		return false
	for key: Variant in assertions:
		if bool(assertions[key]):
			return false
	return true


func _verification_matches(verification: Dictionary) -> bool:
	return str(verification.get("result", "")) == "PASS_WITH_DOCUMENTED_VISUAL_LIMITATIONS_PENDING_INDEPENDENT_ART_REVIEW" \
		and bool(verification.get("all_images_opened_and_inspected", false)) \
		and int(verification.get("image_count", -1)) == 15 \
		and (verification.get("images", []) as Array).size() == 15 \
		and (verification.get("documented_limitations", []) as Array).size() >= 4 \
		and not bool(verification.get("self_acceptance", true)) \
		and str(verification.get("art_verdict", "")) == "withheld_for_independent_reviewer"


func _images_match() -> bool:
	for name_value: Variant in EXPECTED_IMAGES:
		var name := str(name_value)
		var path := ROOT.path_join("images").path_join(name)
		if FileAccess.get_sha256(path) != str(EXPECTED_IMAGES[name_value]):
			return false
		var image := Image.load_from_file(path)
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900):
			return false
	return true


func _hashes_match(expected: Dictionary) -> bool:
	for path_value: Variant in expected:
		var path := str(path_value)
		if FileAccess.get_sha256(path) != str(expected[path_value]):
			return false
	return true


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _require(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
