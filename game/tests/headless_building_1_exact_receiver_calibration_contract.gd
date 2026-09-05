extends SceneTree

const HELPER := preload("res://game/tests/support/building_1_exact_receiver_calibration.gd")
const REGISTRY_PATH := "res://game/resources/facades/building_1_exact_receiver_calibration.json"
const HELPER_PATH := "res://game/tests/support/building_1_exact_receiver_calibration.gd"
const SCENE_PATH := "res://game/scenes/world/facades/building_1/building_1_exact_receiver_calibration.tscn"
const SCENE_SCRIPT_PATH := "res://game/scripts/world/facades/building_1_exact_receiver_calibration_scene.gd"
const MATERIAL_PATH := "res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres"
const SHADER_PATH := "res://game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const RECEIVER_KEY := "building:r16681702:wall"
const EXPECTED_HASHES := {
	REGISTRY_PATH: "10ab1f25d0f9d37ccbb20be9dfe77a37c66f63918b1fdf070c1de9c61633414a",
	HELPER_PATH: "3a494ba38436b9f68ad02ddaf4e454a0a53c84a777a2999111a67dcc55dae75c",
	SCENE_PATH: "3fb0c925cec5d65e0d7ed3ca86c1d8d464c4f43965997545af5c0b575978b0cb",
	SCENE_SCRIPT_PATH: "2b21baff993ee30652072e3f51d95a239d2d22a77e0ff025f0dfe44fb1baa730",
	MATERIAL_PATH: "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a",
	SHADER_PATH: "a4a5df4fbb8fd4f13187ec284708879b540677ac2c827642b4c3040b4bce4c09",
	CHUNK_PATH: "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://game/resources/facades/building_1_standalone_prototypes.json": "2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc",
	"res://game/scripts/world/facades/building_1_standalone_prototypes.gd": "cf18bfcfa40c7770d92aad569cba05da7ac85fe0fc89c0fd8cba6167ef62fb1f",
	"res://game/scenes/world/facades/building_1/building_1_standalone_prototype_set.tscn": "1d205d4d6e176d4ed1e82746d1f1f8c4c2547910b1a71f87a213d9ada14967ef",
	"res://discovery/facades/TREASURE_ISLAND_BUILDING_1_RUN_OWNERSHIP.json": "716f90b9d7cb3267e901d438a5c583047c8eaeb912e544a459005c2dbe6a4359",
	"res://discovery/facades/TREASURE_ISLAND_BUILDING_1_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md": "7c1d4fed00fda41b35b8618565622712368504465c45ab4aa443e3460ab4e85b",
	"res://evidence/first-playable/treasure-island-building-1-run-ownership-mapping-2026-08-30/checksums.sha256": "c5f3372a5f982cd37021802b833b9c3c2eabed59007dcc45cb024f25fa9e1814",
	"res://evidence/first-playable/treasure-island-building-1-standalone-prototypes-2026-08-30/checksums.sha256": "d1e7ab8987f64d01165555fdade3b52dfa042b1ef1a9d5eb2b32ec88cb85ac65",
	"res://game/scripts/world/world_chunk_builder.gd": "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f",
}
const PAUSED_R133351_ASSET_PATH := "res://game/resources/facades/r133351_standalone_prototypes.json"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for path: String in EXPECTED_HASHES:
		_require(FileAccess.get_sha256(path) == str(EXPECTED_HASHES[path]), "Protected detached-calibration byte drifted: %s" % path)
	_require(not FileAccess.file_exists(PAUSED_R133351_ASSET_PATH), "Paused r133351 WIP asset leaked from its dedicated branch into current main.")
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	_require(registry_value is Dictionary, "Building 1 calibration registry did not parse.")
	if not registry_value is Dictionary:
		_finish()
		return
	var registry := registry_value as Dictionary
	var record := _record_data()
	_require(not record.is_empty(), "Building 1 exact receiver record did not resolve.")
	_require(str(registry.get("schema_version", "")) == "ti.building-1-detached-exact-receiver-calibration/1", "Registry schema drifted.")
	_require(str(registry.get("status", "")).contains("not_self_accepted"), "Registry improperly self-accepted.")
	_require(not bool(registry.get("runtime_attachment", false)), "Registry gained runtime attachment.")
	var field_scope := registry.get("exact_field_scope", {}) as Dictionary
	var expected_runs: Array[int] = []
	for run_index in range(21, 52):
		expected_runs.append(run_index)
	_require(_int_array(field_scope.get("exact_ordered_runs", []) as Array) == expected_runs, "Exact field is not ordered runs 21..51.")
	_require(int(field_scope.get("run_count", -1)) == 31, "Exact field run count drifted.")
	_require(absf(float(field_scope.get("physical_wall_length_m", 0.0)) - 85.939934) < 0.000001, "Exact field length drifted.")
	_require(absf(float(field_scope.get("generated_mesh_surface_area_m2", 0.0)) - 1740.731069) < 0.000001, "Exact field mesh area drifted.")
	var uv_contract := field_scope.get("meter_and_uv_contract", {}) as Dictionary
	_require(int(uv_contract.get("internal_join_count", -1)) == 30 \
		and float(uv_contract.get("maximum_endpoint_delta_m", -1.0)) == 0.0 \
		and float(uv_contract.get("maximum_join_phase_delta_m", -1.0)) == 0.0, "Registry chain continuity contract drifted.")
	var parameters := field_scope.get("material_parameters", {}) as Dictionary
	_require(absf(float(parameters.get("primary_scale_m", -1.0)) - 1.1) < 0.000001 \
		and absf(float(parameters.get("secondary_scale_m", -1.0)) - 0.32) < 0.000001 \
		and absf(float(parameters.get("roughness_value", -1.0)) - 0.82) < 0.000001, "Accepted standalone field parameters drifted in calibration.")

	var studies := registry.get("fit_studies", []) as Array
	_require(studies.size() == 2, "Expected exactly two detached module fit studies.")
	if studies.size() == 2:
		_validate_study(studies[0] as Dictionary, "FIT-CENTRAL-W-R36", "B1-CENTRAL-W", 36, 2.008051045)
		_validate_study(studies[1] as Dictionary, "FIT-PAV-W-R06", "B1-PAV-W", 6, 5.511163693)
	var policy := registry.get("fit_study_policy", {}) as Dictionary
	_require(int(policy.get("fit_study_count", -1)) == 2 \
		and int(policy.get("actual_world_placement_count", -1)) == 0 \
		and str(policy.get("cadence_status", "")) == "unknown_not_inferred" \
		and str(policy.get("sequence_status", "")) == "unknown_not_inferred" \
		and not bool(policy.get("runtime_attachment", true)), "Fit-study truth boundary drifted.")
	var locked := registry.get("excluded_checksum_locked_assets", []) as Array
	_require(locked.size() == 4, "Exactly four blocked standalone motifs must remain checksum-locked and absent.")
	_require(_locked_ids(locked) == ["B1-WING-W", "B1-BASE-O", "B1-DOOR-BLUE", "B1-BAND"], "Blocked motif inventory drifted.")

	var first := HELPER.build(record, registry)
	var second := HELPER.build(record, registry)
	_require(bool(first.get("ok", false)), str(first.get("message", "First detached build failed.")))
	_require(bool(second.get("ok", false)), str(second.get("message", "Second detached build failed.")))
	if bool(first.get("ok", false)) and bool(second.get("ok", false)):
		_validate_built(first, registry)
		_require(_geometry_signature(first.node as Node) == _geometry_signature(second.node as Node), "Two detached builds were not deterministic.")
		(first.node as Node).free()
		(second.node as Node).free()

	var packed := load(SCENE_PATH) as PackedScene
	_require(packed != null, "Detached calibration scene did not load.")
	if packed != null:
		var scene := packed.instantiate() as Node3D
		root.add_child(scene)
		await process_frame
		var built := scene.get_node_or_null("DetachedBuilding1ExactReceiverCalibration")
		_require(built != null, "Detached calibration scene did not build its isolated study root.")
		if built != null:
			_require(_count_meshes(built) == 23 and _count_surfaces(built) == 23 and _count_triangles(built) == 326, "Detached scene topology drifted.")
		scene.free()

	_require(not FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd").contains("building_1_exact_receiver_calibration"), "Detached Building 1 calibration leaked into world builder.")
	if not _failed:
		print("PASS: Building 1 detached calibration owns exact MAT-IVORY runs 21..51 at 85.939934 m / 1740.731069 m2 with 30 zero-delta chain-UV joins and 30 watertight shared offset miters, correcting the 0.026857801 m maximum rendered gap to zero; CENTRAL/PAV fit studies remain transform-deterministic at 23/23/326 topology and zero actual placements/backing/collision/navigation/spray/runtime state")
	_finish()


func _validate_study(study: Dictionary, id: String, motif: String, run_index: int, along_m: float) -> void:
	_require(str(study.get("fit_study_id", "")) == id \
		and str(study.get("motif_id", "")) == motif \
		and int(study.get("representative_run", -1)) == run_index \
		and _int_array(study.get("exact_ordered_runs", []) as Array) == [run_index], "%s identity/run drifted." % id)
	_require(absf(float(study.get("along_run_center_m", -1.0)) - along_m) < 0.000001 \
		and absf(float(study.get("along_run_fraction", -1.0)) - 0.5) < 0.000001 \
		and absf(float(study.get("center_height_above_base_m", -1.0)) - 10.0) < 0.000001, "%s deterministic fit-study coordinates drifted." % id)
	_require(str(study.get("study_kind", "")) == "detached_scale_contact_fit_only_not_actual_world_anchor" \
		and not bool(study.get("real_placement_authorized", true)) \
		and not bool(study.get("surveyed_dimensions", true)) \
		and not bool(study.get("surveyed_coordinates", true)) \
		and not bool(study.get("surveyed_count", true)) \
		and not bool(study.get("surveyed_cadence", true)) \
		and not bool(study.get("runtime_attachment", true)), "%s gained a forbidden placement or survey claim." % id)


func _validate_built(result: Dictionary, registry: Dictionary) -> void:
	var calibration := result.node as Node3D
	_require(calibration.get_parent() == null \
		and not bool(calibration.get_meta("runtime_attachment", true)) \
		and int(calibration.get_meta("actual_world_placement_count", -1)) == 0, "Detached root ownership drifted.")
	_require(_count_meshes(calibration) == 23 and _count_surfaces(calibration) == 23 and _count_triangles(calibration) == 326, "Detached overlay topology drifted.")
	_require(_count_type(calibration, CollisionObject3D) == 0 \
		and _count_type(calibration, NavigationRegion3D) == 0 \
		and _count_type(calibration, Decal) == 0, "Detached overlay gained collision/navigation/spray ownership.")
	for blocked_id in ["B1_WING_W", "B1_BASE_O", "B1_DOOR_BLUE", "B1_BAND"]:
		_require(calibration.find_child(blocked_id, true, false) == null, "Blocked motif leaked into calibration: %s" % blocked_id)
	var field := calibration.get_node_or_null("DetachedExactPublicCurveFieldRuns21To51") as MeshInstance3D
	_require(field != null, "Exact detached field mesh is missing.")
	if field != null:
		_require(field.mesh.get_surface_count() == 1 and field.mesh.get_faces().size() / 3 == 62, "Exact field topology drifted.")
		var arrays := field.mesh.surface_get_arrays(0)
		var mesh_vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var uv := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
		_require(mesh_vertices.size() == 124 and uv.size() == 124, "Exact field vertex/UV count drifted.")
		if mesh_vertices.size() == 124 and uv.size() == 124:
			var maximum_join_delta := 0.0
			var maximum_rendered_bottom_gap := 0.0
			var maximum_rendered_top_gap := 0.0
			for run_offset in range(30):
				var before_end := uv[run_offset * 4 + 1].x
				var after_start := uv[(run_offset + 1) * 4].x
				maximum_join_delta = maxf(maximum_join_delta, absf(before_end - after_start))
				maximum_rendered_bottom_gap = maxf(maximum_rendered_bottom_gap, mesh_vertices[run_offset * 4 + 1].distance_to(mesh_vertices[(run_offset + 1) * 4]))
				maximum_rendered_top_gap = maxf(maximum_rendered_top_gap, mesh_vertices[run_offset * 4 + 2].distance_to(mesh_vertices[(run_offset + 1) * 4 + 3]))
			_require(maximum_join_delta == 0.0 \
				and uv[0].x == 0.0 \
				and absf(uv[122].x - float((registry.exact_field_scope as Dictionary).physical_wall_length_m)) < 0.0001, "Exact field UV chain phase drifted.")
			_require(maximum_rendered_bottom_gap == 0.0 and maximum_rendered_top_gap == 0.0, "Shared mitered overlay endpoints are not watertight at all 30 bottom/top joins.")
	var resolved_scope := result.resolved_field_scope as Dictionary
	_require(int(resolved_scope.get("internal_join_count", -1)) == 30 \
		and float(resolved_scope.get("maximum_endpoint_delta_m", -1.0)) == 0.0 \
		and float(resolved_scope.get("maximum_join_phase_delta_m", -1.0)) == 0.0 \
		and absf(float(resolved_scope.get("physical_length_m", 0.0)) - 85.939934) < 0.0001 \
		and absf(float(resolved_scope.get("surface_area_m2", 0.0)) - 1740.731069) < 0.001, "Resolved field proof drifted.")
	var correction := resolved_scope.get("overlay_join_miter_correction", {}) as Dictionary
	var join_records := resolved_scope.get("overlay_join_records", []) as Array
	_require(str(correction.get("correction_kind", "")) == "shared_xz_mitered_offset_junctions" \
		and int(correction.get("join_count", -1)) == 30 \
		and absf(float(correction.get("maximum_independently_offset_gap_before_m", 0.0)) - 0.026857801) < 0.00005 \
		and float(correction.get("maximum_shared_miter_gap_after_m", -1.0)) == 0.0 \
		and float(correction.get("maximum_perpendicular_clearance_residual_m", 1.0)) < 0.00003 \
		and float(correction.get("minimum_miter_denominator", 0.0)) > 0.5 \
		and float(correction.get("maximum_miter_ratio", 100.0)) < 2.0, "All-join shared-miter stability or before→after gap proof drifted: %s" % JSON.stringify(correction))
	_require(join_records.size() == 30, "Expected one numeric correction record for every internal join.")
	var join_38_39 := _join_record(join_records, 38, 39)
	var join_42_43 := _join_record(join_records, 42, 43)
	_require(absf(float(join_38_39.get("independently_offset_gap_before_m", 0.0)) - 0.024844871) < 0.00005 \
		and float(join_38_39.get("shared_miter_bottom_gap_after_m", -1.0)) == 0.0 \
		and float(join_38_39.get("shared_miter_top_gap_after_m", -1.0)) == 0.0, "Reviewed 38→39 rendered gap was not corrected exactly: %s" % JSON.stringify(join_38_39))
	_require(absf(float(join_42_43.get("independently_offset_gap_before_m", 0.0)) - 0.026857801) < 0.00005 \
		and float(join_42_43.get("shared_miter_bottom_gap_after_m", -1.0)) == 0.0 \
		and float(join_42_43.get("shared_miter_top_gap_after_m", -1.0)) == 0.0, "Reviewed maximum 42→43 rendered gap was not corrected exactly: %s" % JSON.stringify(join_42_43))
	var resolved := result.resolved_fit_studies as Array
	_require(resolved.size() == 2, "Resolved fit-study count drifted.")
	if resolved.size() == 2:
		_require(str((resolved[0] as Dictionary).fit_study_id) == "FIT-CENTRAL-W-R36" \
			and str((resolved[1] as Dictionary).fit_study_id) == "FIT-PAV-W-R06" \
			and not bool((resolved[0] as Dictionary).real_placement_authorized) \
			and not bool((resolved[1] as Dictionary).real_placement_authorized), "Resolved fit-study truth drifted.")


func _record_data() -> Dictionary:
	var chunk_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	if not chunk_value is Dictionary:
		return {}
	for value: Variant in (chunk_value as Dictionary).get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == RECEIVER_KEY:
			return record
	return {}


func _geometry_signature(node: Node) -> String:
	var records: Array[String] = []
	_collect_geometry(node, records)
	records.sort()
	return "\n".join(records)


func _collect_geometry(node: Node, records: Array[String]) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var mesh := mesh_instance.mesh
		var material_path := mesh_instance.material_override.resource_path if mesh_instance.material_override != null else ""
		records.append("%s|%s|%s|%s|%s" % [str(node.name), str(mesh_instance.transform), str(mesh.get_aabb()), material_path, str(mesh.get_surface_count())])
	for child in node.get_children():
		_collect_geometry(child, records)


func _count_meshes(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _count_meshes(child)
	return count


func _count_surfaces(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		count += (node as MeshInstance3D).mesh.get_surface_count()
	for child in node.get_children():
		count += _count_surfaces(child)
	return count


func _count_triangles(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		count += (node as MeshInstance3D).mesh.get_faces().size() / 3
	for child in node.get_children():
		count += _count_triangles(child)
	return count


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child in node.get_children():
		count += _count_type(child, node_type)
	return count


func _locked_ids(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in values:
		result.append(str((value as Dictionary).get("motif_id", "")))
	return result


func _join_record(values: Array, before_run: int, after_run: int) -> Dictionary:
	for value: Variant in values:
		var record := value as Dictionary
		if int(record.get("before_run", -1)) == before_run and int(record.get("after_run", -1)) == after_run:
			return record
	return {}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)


func _finish() -> void:
	quit(1 if _failed else 0)
