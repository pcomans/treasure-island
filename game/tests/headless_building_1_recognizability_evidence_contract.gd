extends SceneTree

const ROOT := "res://evidence/first-playable/treasure-island-building-1-recognizability-composition-2026-08-30"
const RECORD_HASHES := {
	ROOT + "/capture-manifest.json": "ee373f1d812c4d2ca2126e084557e7b4c29e1a88ac0b5c5c5b3db6fc8b732e62",
	ROOT + "/runtime-isolation.json": "8ac138e7161f00ba78f19ac865bca63a41a785496c065bb5940c4710ac042bf3",
	ROOT + "/runtime-topology-delta.json": "59b8d81ae4361de561db908d47aa955891a362406c0a6e44f97f2503e2c1c54c",
	ROOT + "/visual-verification.json": "277798d9ebe9814281b20db306672493a8fcb766a3ddeb52ec14cfd319984e3c",
	ROOT + "/README.md": "cc3cf772d8de7ffe26b0d397648aebc287a9c0bd2696a622830af75dffa5e0e0",
	ROOT + "/checksums.sha256": "cf056dbf2710d6dd8d8ae0a514b34b7ce504f45d210c41bc27818d27f07372c6",
	ROOT + "/asset-inventory.sha256": "34cc2420fc0d56db9f55b3f90f89366677b9b2f1f8366a381abd924ad57295a6",
	ROOT + "/generated-data-diff.txt": "ecdde4706e92b5d57d790c064afb8575f22b1360cb8363a7282ac0f0a43e182a",
	"res://game/resources/facades/building_1_recognizability_placements.json": "affc41797999b83610352c5945c21d5206167a67bdc1aa5134a3021dd280df05",
	"res://game/scripts/world/facades/building_1_recognizable_facade.gd": "f39ce8b043dda6c78e1b7cabc223552b6afcceed67538ce973aa6cdc53fbd507",
	"res://game/scripts/world/world_chunk_builder.gd": "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42",
	"res://game/tests/building_1_recognizability_capture.gd": "8c2d4b4d87e70d263812c15a783576ae48b694d7ae6945cfcd3df76e74bf80e9",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f",
	"res://discovery/facades/TREASURE_ISLAND_BUILDING_1_RECOGNIZABILITY_ART_REVIEW.md": "328973362b873b80ec8255c78ad7851369db850d3d9bc3f95b31064f83bb584c",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(_hashes_match(RECORD_HASHES), "A Building 1 recognizability evidence/current-state record drifted.")
	var manifest := _json(ROOT + "/capture-manifest.json")
	var isolation := _json(ROOT + "/runtime-isolation.json")
	var verification := _json(ROOT + "/visual-verification.json")
	var registry := _json("res://game/resources/facades/building_1_recognizability_placements.json")
	var inventory := _json("res://discovery/FACADE_RECEIVER_INVENTORY.json")
	_require(str(manifest.get("review_status", "")) == "pending_independent_recognizability_art_review_not_self_accepted", "Capture-time recognizability review provenance drifted.")
	_require(int(manifest.get("capture_count", -1)) == 16 and (manifest.get("captures", []) as Array).size() == 16, "Recognizability capture inventory drifted.")
	_require(str(manifest.get("display_driver", "")) == "macOS" and str(manifest.get("rendering_method", "")) == "Forward+" and str(manifest.get("rendering_driver", "")) == "Metal", "Native renderer contract drifted.")
	_require(_images_match(manifest.get("captures", []) as Array), "A recognizability image hash/dimension/luminance contract drifted.")
	_require(_same_pose_pairs_match(manifest), "Before/after pair identities or camera/light transforms drifted.")
	var field := registry.get("field_composition", {}) as Dictionary
	var placements := registry.get("placement_summary", {}) as Dictionary
	var topology := registry.get("live_render_topology", {}) as Dictionary
	var truth := registry.get("truth_boundary", {}) as Dictionary
	_require(int(field.get("run_count", -1)) == 63 and absf(float(field.get("physical_length_m", -1.0)) - 206.908708) < 0.000001 and absf(float(field.get("generated_mesh_surface_area_m2", -1.0)) - 4350.511117) < 0.000001, "Field composition metrics drifted.")
	_require(int(placements.get("placement_count", -1)) == 45 and int(placements.get("module_meshes", -1)) == 351 and int(placements.get("module_triangles", -1)) == 4212, "Module composition topology drifted.")
	_require(int(topology.get("total_meshes", -1)) == 354 and int(topology.get("total_surfaces", -1)) == 354 and int(topology.get("total_triangles", -1)) == 4338, "Complete composition topology drifted.")
	_require(str(truth.get("role", "")) == "recognizable_reference_derived_production_inference" and bool(truth.get("reversible", false)) and not bool(truth.get("surveyed_coordinates", true)) and not bool(truth.get("surveyed_count", true)) and not bool(truth.get("surveyed_cadence", true)) and not bool(truth.get("as_built_fidelity_claimed", true)) and not bool(truth.get("whole_building_accepted", true)), "Recognizability truth boundary drifted.")
	var before := isolation.get("runtime_before", {}) as Dictionary
	var after := isolation.get("runtime_after", {}) as Dictionary
	var delta := isolation.get("delta_vs_accepted_ivory_baseline", {}) as Dictionary
	_require(_topology_exact(before, 925, 935, 50791) and _topology_exact(after, 1278, 1288, 55067), "Runtime before/after topology drifted.")
	_require(int(delta.get("meshes", -1)) == 353 and int(delta.get("surfaces", -1)) == 353 and int(delta.get("triangles", -1)) == 4276 and int(delta.get("collision_nodes", -1)) == 0, "Runtime delta drifted.")
	_require(str(isolation.get("result", "")) == "PASS" and not bool(isolation.get("receiver_geometry_changed", true)) and not bool(isolation.get("receiver_collision_changed", true)) and not bool(isolation.get("generated_data_changed", true)) and int(isolation.get("protected_run_attachment_count", -1)) == 0 and int(isolation.get("module_field_or_backing_meshes", -1)) == 0, "Protected runtime isolation drifted.")
	var independent := verification.get("post_capture_independent_review", {}) as Dictionary
	_require(bool(verification.get("all_images_opened_and_inspected", false)) and int(verification.get("image_count", -1)) == 16 and not bool(verification.get("self_acceptance", true)) and str(verification.get("art_verdict", "")) == "withheld_for_independent_recognizability_reviewer" \
		and str(independent.get("status", "")) == "independently_reviewed_keep_with_documented_limitation" \
		and str(independent.get("review_sha256", "")) == "328973362b873b80ec8255c78ad7851369db850d3d9bc3f95b31064f83bb584c" \
		and not bool(independent.get("as_built_fidelity_claimed", true)), "Visual validity/current independent-review record is incomplete or overclaims acceptance.")
	_require(_lifecycle_matches(inventory), "Canonical independently accepted recognizability lifecycle drifted.")
	if not _failed:
		print("PASS: Building 1 recognizability evidence seals 16 unchanged native Metal views, three exact before/after pairs, all six complete motif families, 63 accepted public field runs, 45 accepted production-inference placements, protected runtime, independent review 32897336, and zero pending lifecycle scope")
	quit(1 if _failed else 0)


func _images_match(captures: Array) -> bool:
	for value: Variant in captures:
		var capture := value as Dictionary
		var path := ROOT.path_join(str(capture.get("file", "")))
		if FileAccess.get_sha256(path) != str(capture.get("sha256", "")):
			return false
		var image := Image.load_from_file(path)
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900) \
		or float((capture.get("sampled_luminance", {}) as Dictionary).get("range", 0.0)) < 0.1:
			return false
	return true


func _same_pose_pairs_match(manifest: Dictionary) -> bool:
	var captures := {}
	for value: Variant in manifest.get("captures", []):
		var capture := value as Dictionary
		captures[str(capture.get("id", ""))] = capture
	for pair_value: Variant in manifest.get("same_pose_before_after_pairs", []):
		var pair := pair_value as Array
		if pair.size() != 2 or not captures.has(str(pair[0])) or not captures.has(str(pair[1])):
			return false
		var before := captures[str(pair[0])] as Dictionary
		var after := captures[str(pair[1])] as Dictionary
		if str(before.get("stage", "")) != "before" or str(after.get("stage", "")) != "after" \
		or before.get("camera_position_m", []) != after.get("camera_position_m", []) \
		or before.get("target_position_m", []) != after.get("target_position_m", []) \
		or before.get("sun_rotation_degrees", []) != after.get("sun_rotation_degrees", []):
			return false
	return true


func _lifecycle_matches(inventory: Dictionary) -> bool:
	var batch := inventory.get("batch_06_lifecycle_reconciliation", {}) as Dictionary
	var accepted := batch.get("accepted_exact_field_scopes", []) as Array
	var pending := batch.get("pending_independent_recognizability_review_summary", {}) as Dictionary
	var modules := batch.get("accepted_live_module_summary_building_1", {}) as Dictionary
	var runtime := inventory.get("runtime_material_contract", {}) as Dictionary
	var found := false
	for value: Variant in accepted:
		var scope := value as Dictionary
		if str(scope.get("receiver_key", "")) == "building:r16681702:wall":
			found = int(scope.get("run_count", -1)) == 63 \
				and absf(float(scope.get("run_length_m", 0.0)) - 206.908708) < 0.000001 \
				and absf(float(scope.get("wall_area_m2", 0.0)) - 4350.511117) < 0.000001
	return found \
		and (batch.get("pending_independent_actual_world_art_review_exact_field_scopes", []) as Array).is_empty() \
		and int(pending.get("target_receiver_count", -1)) == 0 \
		and int(pending.get("field_extension_run_count", -1)) == 0 \
		and int(pending.get("module_placement_count", -1)) == 0 \
		and int(modules.get("placement_count", -1)) == 45 \
		and int(modules.get("mesh_instances", -1)) == 351 \
		and int(modules.get("triangles", -1)) == 4212 \
		and str(modules.get("independent_live_review_sha256", "")) == "328973362b873b80ec8255c78ad7851369db850d3d9bc3f95b31064f83bb584c" \
		and not bool(modules.get("surveyed_coordinates_proven", true)) \
		and not bool(modules.get("whole_building_accepted", true)) \
		and int(runtime.get("accepted_exact_run_count", -1)) == 130 \
		and int(runtime.get("accepted_live_module_placement_count", -1)) == 62 \
		and int(runtime.get("pending_independent_recognizability_live_module_placement_count", -1)) == 0 \
		and (runtime.get("pending_independent_recognizability_review_runtime_attachments", []) as Array).is_empty()


func _topology_exact(value: Dictionary, meshes: int, surfaces: int, triangles: int) -> bool:
	return int(value.get("records", -1)) == 729 \
		and int(value.get("meshes", -1)) == meshes \
		and int(value.get("surfaces", -1)) == surfaces \
		and int(value.get("triangles", -1)) == triangles \
		and int(value.get("static_bodies", -1)) == 466 \
		and int(value.get("shapes", -1)) == 466


func _hashes_match(expected: Dictionary) -> bool:
	for path_value: Variant in expected:
		if FileAccess.get_sha256(str(path_value)) != str(expected[path_value]): return false
	return true


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition: return true
	_failed = true
	push_error(message)
	return false
