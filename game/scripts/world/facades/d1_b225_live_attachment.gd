class_name D1B225LiveAttachment
extends RefCounted

## Fail-closed, receiver-relative production translation of the independently
## reviewed Building 225 NNW standalone repair. The supplied generic wall
## remains the sole mesh/collision/spray receiver: its observed NNW runs receive
## one cumulative-metre material partition and this helper adds only the
## reviewed non-coplanar clerestory batches. The canonical chunk builder claims
## only the exact frozen receiver after independent prepromotion review.

const METER_UV := preload("res://game/scripts/world/facades/facade_meter_uv_adapter.gd")
const CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b225_live_attachment.json"
const EXPECTED_CONFIG_SHA256 := "80b42c33fce84361aa7512f64305f5bff273e8fed95640ca4f9c19d49d55621d"
const SOURCE_KEY := "w95934119"
const RECEIVER_KEY := "building:w95934119:wall"
const ROOF_KEY := "building:w95934119:roof"
const TARGET_CHUNK_ID := "x_-2__z_-1"
const MAPPING_ID := "14812-NNW-LONG"
const EXPECTED_CANONICAL_RECORD_SHA256 := "7950095b20ea50b989f7f111e6e4bfd45cdc42cda85ac3e0f3c8cd044c836722"
const EXPECTED_RUNTIME_RECORD_SHA256 := "3ee5133f55454baec65cc8cb31b0ce9b21211689fc7d9b17d2cb204a9aeb636e"
const EXPECTED_CANONICAL_ROOF_RECORD_SHA256 := "338afe9681244b8deca0b4f87891a8a91069002b36bc7a9c4fd8564b420778c0"
const EXPECTED_RUNTIME_ROOF_RECORD_SHA256 := "fc75c1eab69de7273b8ce412c188fb9c540be01eb831b0ef2ca2878dff3b7763"
const EXPECTED_METER_PLAN_SIGNATURE := "6c903f808cc5eb6d917cbb1946dda9f1fb02bfeb663bdbfe1846353238d49450"
const EXPECTED_RUNTIME_CHAIN_TOTAL_M := 46.261983394622803
const EXPECTED_STANDALONE_METER_PLAN_SIGNATURE := "6b33f7b7146815b87fa7aec9bced760309104f4f56038e37e1820199c9b446f5"
const EXPECTED_STANDALONE_GEOMETRY_SIGNATURE := "281a471f6cff9b0530aa51c98cc737d276dc0d9210996a5403d9fe44996dd2a2"
const EXPECTED_DECORATIVE_GEOMETRY_SIGNATURE := "02bd8542dea7aa13041728a5244ec962fa121972db17ecf55fad03b3139fe418"
const RUN_INDICES: Array[int] = [10, 11, 12, 13]
const RUN_LENGTHS_M: Array[float] = [10.372629078, 6.510893794, 7.049860211, 22.328585289]
const CHAIN_LENGTH_M := 46.261968372
const BASE_ELEVATION_M := 2.507
const TOP_ELEVATION_M := 7.507
const HEIGHT_M := 5.0
const MEASURED_MAX_CHORD_DEVIATION_M := 0.00028295380557345431
const RUNTIME_MEASURED_MAX_CHORD_DEVIATION_M := 0.000287945355690
const MAX_ALLOWED_CHORD_DEVIATION_M := 0.001
const STANDALONE_FIELD_FRONT_OFFSET_M := 0.10
const RENDER_BUILDING_WALL := 1 << 1
const EXPECTED_BATCH_COUNT := 2
const EXPECTED_BOX_COUNT := 90
const EXPECTED_TRIANGLES := 1080
const EXPECTED_BATCH_COUNTS := {
	"shared_dark_glass": 10,
	"shared_pale_frame": 80,
}
const GENERIC_WALL_TEXTURE_PATHS := {
	"albedo": "res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_diff_1k.jpg",
	"normal": "res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_nor_gl_1k.jpg",
	"roughness": "res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_rough_1k.jpg",
}
const MATERIAL_SPECS := {
	"b225_cladding_v1": {"path": "res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres", "sha256": "7fa7f3165dee560c48f5a092f317900b87b0876f27bb6a0e937b9c406a8d4ea1", "resource_name": "d1_b225_aged_painted_horizontal_cladding_albedo_v1", "albedo": Color(0.76, 0.755, 0.72, 1.0), "metallic": 0.0, "roughness": 0.88, "albedo_texture_path": "res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png", "albedo_texture_sha256": "63e755e9fe5a5dcfb662b4265f1e769fc1b371987b55579b1ca4ffb63015015b", "uv1_scale": Vector3(0.125, 0.28735632, 1.0)},
	"shared_dark_glass": {"path": "res://game/resources/materials/world/d1_current/shared_dark_glass.tres", "sha256": "ad8931db8954fd5ebc8fdd809f70afb279dd74a36e53e1d9ca907c44409f10d3", "resource_name": "d1_current_shared_dark_opaque_glazing_proxy", "albedo": Color(0.055, 0.095, 0.105, 1.0), "metallic": 0.06, "roughness": 0.28},
	"shared_pale_frame": {"path": "res://game/resources/materials/world/d1_current/shared_pale_frame.tres", "sha256": "9a2de298ff545cf80c5da0ed0aa37d9d4ebbf10fec8eb78810af7e4d012d1436", "resource_name": "d1_current_shared_pale_painted_frame", "albedo": Color(0.72, 0.735, 0.70, 1.0), "metallic": 0.02, "roughness": 0.67},
}


static func claims_record(record: Dictionary) -> bool:
	# Claim by immutable target identity alone. Any other target-field drift must
	# reach build() and fail, never silently fall through to the generic wall.
	var object_key := str(record.get("object_key", ""))
	return object_key == RECEIVER_KEY \
		or (object_key != ROOF_KEY and SOURCE_KEY in (record.get("source_keys", []) as Array))


static func validate_chunk_records(chunk: Dictionary) -> Dictionary:
	var records := chunk.get("records", []) as Array
	var exact_walls: Array[Dictionary] = []
	var exact_roofs: Array[Dictionary] = []
	var target_memberships := 0
	var unexpected_target_membership := false
	for value: Variant in records:
		if not (value is Dictionary):
			continue
		var record := value as Dictionary
		var object_key := str(record.get("object_key", ""))
		if object_key == RECEIVER_KEY:
			exact_walls.append(record)
		elif object_key == ROOF_KEY:
			exact_roofs.append(record)
		if SOURCE_KEY in (record.get("source_keys", []) as Array):
			target_memberships += 1
			if object_key not in [RECEIVER_KEY, ROOF_KEY]:
				unexpected_target_membership = true
	var target_chunk := str(chunk.get("chunk_id", "")) == TARGET_CHUNK_ID
	if not target_chunk and exact_walls.is_empty() and exact_roofs.is_empty() and target_memberships == 0:
		return {"ok": true, "applies": false}
	if not target_chunk or exact_walls.size() != 1 or exact_roofs.size() != 1 or target_memberships != 2 or unexpected_target_membership:
		return {"ok": false, "code": "d1_b225_live_chunk_membership", "message": "Supplied B225 chunk membership or exact wall/roof pairing drifted.", "source_keys": [SOURCE_KEY]}
	var wall := exact_walls[0]
	var roof := exact_roofs[0]
	if canonical_record_signature(wall) != EXPECTED_CANONICAL_RECORD_SHA256 \
	or record_signature(wall) != EXPECTED_RUNTIME_RECORD_SHA256 \
	or not _record_shape_matches(wall):
		return _failure("d1_b225_live_chunk_wall_authority", "Supplied B225 wall row drifted before generic construction.", wall)
	if canonical_record_signature(roof) != EXPECTED_CANONICAL_ROOF_RECORD_SHA256 \
	or record_signature(roof) != EXPECTED_RUNTIME_ROOF_RECORD_SHA256 \
	or not _roof_shape_matches(roof):
		return _failure("d1_b225_live_chunk_roof_authority", "Protected B225 roof row drifted before generic construction.", roof)
	return {"ok": true, "applies": true}


static func prepare(record: Dictionary) -> Dictionary:
	if not claims_record(record):
		return _failure("d1_b225_live_unclaimed_receiver", "Record is not the exact B225 target identity.", record)
	if canonical_record_signature(record) != EXPECTED_CANONICAL_RECORD_SHA256 \
	or record_signature(record) != EXPECTED_RUNTIME_RECORD_SHA256 \
	or not _record_shape_matches(record):
		return _failure("d1_b225_live_record_authority", "The supplied B225 target row drifted from full frozen authority.", record)
	var config_result := _validated_config_and_materials()
	if not bool(config_result.get("ok", false)):
		return _failure("d1_b225_live_package_authority", str(config_result.get("message", "Live config or material closure drifted.")), record)
	var chain_result := _receiver_chain(record)
	if not bool(chain_result.get("ok", false)):
		return _failure("d1_b225_live_receiver_chain", str(chain_result.get("message", "Eligible receiver chain drifted.")), record)
	var host_uvs := _host_uvs(record, chain_result.get("plan", {}) as Dictionary)
	if host_uvs.size() != 56:
		return _failure("d1_b225_live_host_uv", "B225 host metre-UV adaptation failed.", record)
	return {
		"ok": true,
		"chain": chain_result,
		"config": config_result.get("config", {}) as Dictionary,
		"materials": config_result.get("materials", {}) as Dictionary,
		"host_uvs": host_uvs,
		"record_canonical_sha256": EXPECTED_CANONICAL_RECORD_SHA256,
		"record_runtime_sha256": EXPECTED_RUNTIME_RECORD_SHA256,
	}


static func build(record: Dictionary) -> Dictionary:
	var prepared := prepare(record)
	if not bool(prepared.get("ok", false)):
		return prepared
	return build_prepared(record, prepared)


static func authored_transform_spec(record: Dictionary, prepared: Dictionary) -> Dictionary:
	# MultiMesh transform readback is identity-only under Godot's Dummy renderer.
	# Expose the exact authored transforms before upload so headless contracts can
	# still prove geometry, host clearance, grounding, counts, and signature.
	if not _prepared_matches(record, prepared):
		return _failure("d1_b225_live_unprepared", "B225 authored transforms require a valid prepared target row.", record)
	return _authored_transform_spec(prepared.get("chain", {}) as Dictionary)


static func build_prepared(record: Dictionary, prepared: Dictionary) -> Dictionary:
	if not _prepared_matches(record, prepared):
		return _failure("d1_b225_live_unprepared", "B225 attachment requires a valid prepared target row.", record)
	var root_node := _build_render_attachment(prepared.get("chain", {}) as Dictionary, prepared.get("materials", {}) as Dictionary)
	if root_node == null:
		return _failure("d1_b225_live_geometry", "Approved B225 render geometry failed to build.", record)
	var topology := render_topology(root_node)
	if int(topology.get("mesh_instances", -1)) != EXPECTED_BATCH_COUNT \
	or int(topology.get("surfaces", -1)) != EXPECTED_BATCH_COUNT \
	or int(topology.get("triangles", -1)) != EXPECTED_TRIANGLES \
	or _count_type(root_node, CollisionObject3D) != 0 \
	or _count_type(root_node, CollisionShape3D) != 0 \
	or _count_type(root_node, NavigationRegion3D) != 0 \
	or _count_type(root_node, Decal) != 0:
		root_node.free()
		return _failure("d1_b225_live_topology", "B225 attachment topology or render-only ownership drifted.", record)
	var metadata := {
		"schema_version": "ti.d1-b225-live-attachment/1",
		"source_key": SOURCE_KEY,
		"receiver_key": RECEIVER_KEY,
		"mapping_id": MAPPING_ID,
		"runtime_attachment": true,
		"integration_stage": "production_runtime_attachment",
		"canonical_entrypoint_reachable": true,
		"attachment_mode": "receiver_host_material_partition_plus_receiver_relative_render_only_details",
		"host_mesh_preserved": true,
		"host_mesh_instance_and_record_geometry_preserved": true,
		"host_array_mesh_resource_replaced_for_surface_partition": false,
		"host_array_mesh_constructed_with_surface_partition": true,
		"host_protected_run_render_preserved": true,
		"host_eligible_run_material_changed": true,
		"host_collision_owner_preserved": true,
		"host_spray_owner_preserved": true,
		"ordered_run_indices": RUN_INDICES.duplicate(),
		"chain_length_m": CHAIN_LENGTH_M,
		"meter_plan_signature": EXPECTED_METER_PLAN_SIGNATURE,
		"standalone_geometry_signature": EXPECTED_STANDALONE_GEOMETRY_SIGNATURE,
		"decorative_geometry_signature": EXPECTED_DECORATIVE_GEOMETRY_SIGNATURE,
		"config_path": CONFIG_PATH,
		"config_sha256": EXPECTED_CONFIG_SHA256,
		"mesh_instances": EXPECTED_BATCH_COUNT,
		"surfaces": EXPECTED_BATCH_COUNT,
		"triangles": EXPECTED_TRIANGLES,
		"collision_nodes": 0,
		"navigation_nodes": 0,
		"spray_nodes": 0,
		"production_inference": true,
		"counts_cadence_dimensions_surveyed": false,
		"reference_pixels_shipped": false,
		"recognition_status": "externally_governed_pending_authority_promotion_and_postpromotion_review",
		"reference_recognizable": false,
	}
	for key: String in metadata:
		root_node.set_meta(key, metadata[key])
	return {
		"ok": true,
		"node": root_node,
		"mesh_instances": EXPECTED_BATCH_COUNT,
		"surfaces": EXPECTED_BATCH_COUNT,
		"triangles": EXPECTED_TRIANGLES,
		"metadata": metadata,
	}


static func host_uvs(record: Dictionary, prepared: Dictionary) -> PackedVector2Array:
	if not _prepared_matches(record, prepared):
		return PackedVector2Array()
	return (prepared.get("host_uvs", PackedVector2Array()) as PackedVector2Array).duplicate()


static func partition_host(record: Dictionary, reversed_indices: PackedInt32Array, placeholder_material: Material, prepared: Dictionary) -> Dictionary:
	if not _prepared_matches(record, prepared) \
	or reversed_indices.size() != 84 or not _generic_wall_material_matches(placeholder_material):
		return _failure("d1_b225_live_host_partition_input", "B225 host partition inputs drifted.", record)
	var expected_reversed := PackedInt32Array()
	var source_indices := record.get("indices", []) as Array
	for offset in range(0, source_indices.size(), 3):
		expected_reversed.append(int(source_indices[offset]))
		expected_reversed.append(int(source_indices[offset + 2]))
		expected_reversed.append(int(source_indices[offset + 1]))
	if reversed_indices != expected_reversed:
		return _failure("d1_b225_live_host_partition_indices", "B225 host partition indices were not the exact complete supplied wall winding.", record)
	var materials := prepared.get("materials", {}) as Dictionary
	var cladding_material := materials.get("b225_cladding_v1", null) as Material
	if cladding_material == null:
		return _failure("d1_b225_live_host_partition_material", "B225 host partition material did not resolve.", record)
	var public_indices := PackedInt32Array()
	var protected_indices := PackedInt32Array()
	for offset in range(0, reversed_indices.size(), 3):
		var run_index := int(offset / 6)
		if run_index in RUN_INDICES:
			public_indices.append(reversed_indices[offset])
			public_indices.append(reversed_indices[offset + 1])
			public_indices.append(reversed_indices[offset + 2])
		else:
			protected_indices.append(reversed_indices[offset])
			protected_indices.append(reversed_indices[offset + 1])
			protected_indices.append(reversed_indices[offset + 2])
	if public_indices.size() != 24 or protected_indices.size() != 60:
		return _failure("d1_b225_live_host_partition_scope", "B225 host partition leaked beyond runs 10..13.", record)
	return {
		"ok": true,
		"surfaces": [
			{"name": "generated_record_protected_runs_0_9", "indices": protected_indices, "material": placeholder_material},
			{"name": "d1_b225_nnw_runs_10_13", "indices": public_indices, "material": cladding_material},
		],
		"metadata": {
			"schema_version": "ti.d1-b225-host-partition/1",
			"receiver_key": RECEIVER_KEY,
			"public_material_runs": RUN_INDICES.duplicate(),
			"protected_generic_runs": range(0, 10),
			"public_triangles": 8,
			"protected_triangles": 20,
			"total_triangles": 28,
			"meter_plan_signature": EXPECTED_METER_PLAN_SIGNATURE,
			"host_collision_owner_preserved": true,
			"host_spray_owner_preserved": true,
		},
	}


static func record_signature(record: Dictionary) -> String:
	return JSON.stringify(record).sha256_text()


static func canonical_record_signature(record: Dictionary) -> String:
	return (_stable_json(record, 0) + "\n").sha256_text()


static func _record_shape_matches(record: Dictionary) -> bool:
	var expected_keys: Array[String] = [
		"collision_kind", "exterior_foundation_segments", "feature_kind", "flat_base_elevation_m",
		"indices", "material_key", "normals", "object_key", "opaque", "receiver_kind",
		"shared_wall_segments", "source_height_m", "source_keys", "top_elevation_m", "uvs", "vertices",
	]
	var actual_keys: Array[String] = []
	for key: Variant in record.keys():
		actual_keys.append(str(key))
	actual_keys.sort()
	expected_keys.sort()
	return actual_keys == expected_keys \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("material_key", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and is_equal_approx(float(record.get("flat_base_elevation_m", -1.0)), BASE_ELEVATION_M) \
		and is_equal_approx(float(record.get("top_elevation_m", -1.0)), TOP_ELEVATION_M) \
		and is_equal_approx(float(record.get("source_height_m", -1.0)), HEIGHT_M) \
		and int(record.get("exterior_foundation_segments", -1)) == 14 \
		and int(record.get("shared_wall_segments", -1)) == 0 \
		and (record.get("vertices", []) as Array).size() == 168 \
		and (record.get("normals", []) as Array).size() == 168 \
		and (record.get("uvs", []) as Array).size() == 112 \
		and (record.get("indices", []) as Array).size() == 84


static func _roof_shape_matches(record: Dictionary) -> bool:
	var expected_keys: Array[String] = [
		"collision_kind", "feature_kind", "flat_base_elevation_m", "indices", "material_key",
		"normals", "object_key", "opaque", "receiver_kind", "source_height_m", "source_keys",
		"top_elevation_m", "uvs", "vertices",
	]
	var actual_keys: Array[String] = []
	for key: Variant in record.keys():
		actual_keys.append(str(key))
	actual_keys.sort()
	expected_keys.sort()
	return actual_keys == expected_keys \
		and str(record.get("object_key", "")) == ROOF_KEY \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_roof" \
		and str(record.get("material_key", "")) == "building_roof" \
		and str(record.get("receiver_kind", "")) == "none" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and is_equal_approx(float(record.get("flat_base_elevation_m", -1.0)), BASE_ELEVATION_M) \
		and is_equal_approx(float(record.get("top_elevation_m", -1.0)), TOP_ELEVATION_M) \
		and is_equal_approx(float(record.get("source_height_m", -1.0)), HEIGHT_M) \
		and (record.get("vertices", []) as Array).size() == 12 \
		and (record.get("normals", []) as Array).size() == 12 \
		and (record.get("uvs", []) as Array).size() == 8 \
		and (record.get("indices", []) as Array).size() == 6


static func _prepared_matches(record: Dictionary, prepared: Dictionary) -> bool:
	var chain := prepared.get("chain", {}) as Dictionary
	var plan := chain.get("plan", {}) as Dictionary
	if not (bool(prepared.get("ok", false)) \
		and str(prepared.get("record_canonical_sha256", "")) == EXPECTED_CANONICAL_RECORD_SHA256 \
		and str(prepared.get("record_runtime_sha256", "")) == EXPECTED_RUNTIME_RECORD_SHA256 \
		and canonical_record_signature(record) == EXPECTED_CANONICAL_RECORD_SHA256 \
		and record_signature(record) == EXPECTED_RUNTIME_RECORD_SHA256 \
		and _record_shape_matches(record) \
		and FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256 \
		and str(plan.get("signature", "")) == EXPECTED_METER_PLAN_SIGNATURE \
		and absf(float(plan.get("total_u_m", 0.0)) - EXPECTED_RUNTIME_CHAIN_TOTAL_M) <= 0.000001):
		return false
	var expected_chain := _receiver_chain(record)
	if not bool(expected_chain.get("ok", false)) or not _chain_matches(chain, expected_chain):
		return false
	var expected_uvs := _host_uvs(record, expected_chain.get("plan", {}) as Dictionary)
	if not _packed_vector2_array_matches(prepared.get("host_uvs", PackedVector2Array()) as PackedVector2Array, expected_uvs):
		return false
	var current := _validated_config_and_materials()
	if not bool(current.get("ok", false)) \
	or _stable_json(prepared.get("config", {}) as Dictionary, 0) != _stable_json(current.get("config", {}) as Dictionary, 0):
		return false
	return _material_set_matches(prepared.get("materials", {}) as Dictionary)


static func _chain_matches(actual: Dictionary, expected: Dictionary) -> bool:
	if not _dictionary_keys_match(actual, ["end", "measured_maximum_chord_deviation_m", "ok", "outward", "plan", "runs", "start", "tangent"]):
		return false
	if bool(actual.get("ok", false)) != bool(expected.get("ok", false)) \
	or not (actual.get("start", Vector3.ZERO) as Vector3).is_equal_approx(expected.get("start", Vector3.ZERO) as Vector3) \
	or not (actual.get("end", Vector3.ZERO) as Vector3).is_equal_approx(expected.get("end", Vector3.ZERO) as Vector3) \
	or not (actual.get("tangent", Vector3.ZERO) as Vector3).is_equal_approx(expected.get("tangent", Vector3.ZERO) as Vector3) \
	or not (actual.get("outward", Vector3.ZERO) as Vector3).is_equal_approx(expected.get("outward", Vector3.ZERO) as Vector3) \
	or absf(float(actual.get("measured_maximum_chord_deviation_m", -1.0)) - float(expected.get("measured_maximum_chord_deviation_m", -2.0))) > 0.00000001 \
	or not _plan_matches(actual.get("plan", {}) as Dictionary, expected.get("plan", {}) as Dictionary):
		return false
	var actual_runs := actual.get("runs", []) as Array
	var expected_runs := expected.get("runs", []) as Array
	if actual_runs.size() != expected_runs.size():
		return false
	for index in expected_runs.size():
		if not _run_matches(actual_runs[index] as Dictionary, expected_runs[index] as Dictionary):
			return false
	return true


static func _plan_matches(actual: Dictionary, expected: Dictionary) -> bool:
	if not _dictionary_keys_match(actual, ["contract_version", "corner_rule", "endpoint_tolerance_m", "entries", "ok", "side_id", "signature", "total_u_m", "u_phase_rule", "v_phase_rule"]):
		return false
	for key: String in ["contract_version", "corner_rule", "side_id", "signature", "u_phase_rule", "v_phase_rule"]:
		if str(actual.get(key, "")) != str(expected.get(key, "")):
			return false
	if bool(actual.get("ok", false)) != bool(expected.get("ok", false)) \
	or absf(float(actual.get("endpoint_tolerance_m", -1.0)) - float(expected.get("endpoint_tolerance_m", -2.0))) > 0.00000001 \
	or absf(float(actual.get("total_u_m", -1.0)) - float(expected.get("total_u_m", -2.0))) > 0.000001:
		return false
	var actual_entries := actual.get("entries", []) as Array
	var expected_entries := expected.get("entries", []) as Array
	if actual_entries.size() != expected_entries.size():
		return false
	for index in expected_entries.size():
		var left := actual_entries[index] as Dictionary
		var right := expected_entries[index] as Dictionary
		if not _dictionary_keys_match(left, ["length_m", "order_index", "run_index", "seam_before", "side_id", "u_end_m", "u_start_m"]) \
		or int(left.get("order_index", -1)) != int(right.get("order_index", -2)) \
		or int(left.get("run_index", -1)) != int(right.get("run_index", -2)) \
		or str(left.get("seam_before", "")) != str(right.get("seam_before", "")) \
		or str(left.get("side_id", "")) != str(right.get("side_id", "")) \
		or absf(float(left.get("length_m", -1.0)) - float(right.get("length_m", -2.0))) > 0.000001 \
		or absf(float(left.get("u_start_m", -1.0)) - float(right.get("u_start_m", -2.0))) > 0.000001 \
		or absf(float(left.get("u_end_m", -1.0)) - float(right.get("u_end_m", -2.0))) > 0.000001:
			return false
	return true


static func _run_matches(actual: Dictionary, expected: Dictionary) -> bool:
	if not _dictionary_keys_match(actual, ["end_xyz_m", "index", "length_m", "normal", "side_id", "start_xyz_m"]):
		return false
	return int(actual.get("index", -1)) == int(expected.get("index", -2)) \
		and str(actual.get("side_id", "")) == str(expected.get("side_id", "")) \
		and _float_values_match(actual.get("start_xyz_m", []) as Array, expected.get("start_xyz_m", []) as Array, 0.000001) \
		and _float_values_match(actual.get("end_xyz_m", []) as Array, expected.get("end_xyz_m", []) as Array, 0.000001) \
		and absf(float(actual.get("length_m", -1.0)) - float(expected.get("length_m", -2.0))) <= 0.000001 \
		and (actual.get("normal", Vector3.ZERO) as Vector3).is_equal_approx(expected.get("normal", Vector3.ZERO) as Vector3)


static func _receiver_chain(record: Dictionary) -> Dictionary:
	var vertices := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var runs: Array[Dictionary] = []
	var endpoints: Array[Vector3] = []
	for order_index in RUN_INDICES.size():
		var run_index := RUN_INDICES[order_index]
		var offset := run_index * 12
		var start := Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2]))
		var end := Vector3(float(vertices[offset + 3]), float(vertices[offset + 4]), float(vertices[offset + 5]))
		var length_m := Vector2(start.x, start.z).distance_to(Vector2(end.x, end.z))
		if absf(length_m - RUN_LENGTHS_M[order_index]) > 0.00002:
			return {"ok": false, "message": "Eligible run %d length drifted." % run_index}
		if order_index == 0:
			endpoints.append(start)
		endpoints.append(end)
		var normal_offset := run_index * 12
		var normal := Vector3(float(normals[normal_offset]), float(normals[normal_offset + 1]), float(normals[normal_offset + 2]))
		runs.append({
			"index": run_index,
			"side_id": MAPPING_ID,
			"start_xyz_m": [start.x, start.y, start.z],
			"end_xyz_m": [end.x, end.y, end.z],
			"length_m": length_m,
			"normal": normal,
		})
	var plan := METER_UV.plan_side_chain(runs, RUN_INDICES, MAPPING_ID)
	if not bool(plan.get("ok", false)) \
	or str(plan.get("signature", "")) != EXPECTED_METER_PLAN_SIGNATURE \
	or absf(float(plan.get("total_u_m", 0.0)) - EXPECTED_RUNTIME_CHAIN_TOTAL_M) > 0.000001:
		return {"ok": false, "message": "Cumulative metre chain contract drifted."}
	var start := endpoints.front() as Vector3
	var end := endpoints.back() as Vector3
	var tangent := Vector3(end.x - start.x, 0.0, end.z - start.z).normalized()
	var outward := tangent.cross(Vector3.UP).normalized()
	var measured_deviation := 0.0
	for point: Vector3 in endpoints:
		measured_deviation = maxf(measured_deviation, _distance_to_chord_xz(point, start, end))
	if absf(measured_deviation - RUNTIME_MEASURED_MAX_CHORD_DEVIATION_M) > 0.0000001 \
	or measured_deviation > MAX_ALLOWED_CHORD_DEVIATION_M:
		return {"ok": false, "message": "Eligible chain is no longer within the reviewed sub-millimetre chord bound."}
	for run_value: Variant in runs:
		var run := run_value as Dictionary
		if (run.get("normal", Vector3.ZERO) as Vector3).normalized().dot(outward) < 0.999:
			return {"ok": false, "message": "Eligible run normal drifted from the reviewed public face."}
	return {
		"ok": true,
		"plan": plan,
		"runs": runs,
		"start": start,
		"end": end,
		"tangent": tangent,
		"outward": outward,
		"measured_maximum_chord_deviation_m": measured_deviation,
	}


static func _build_render_attachment(chain: Dictionary, materials: Dictionary) -> Node3D:
	var root_node := Node3D.new()
	root_node.name = "D1B225LiveAttachment"
	var start := chain.get("start", Vector3.ZERO) as Vector3
	var end := chain.get("end", Vector3.ZERO) as Vector3
	var tangent := chain.get("tangent", Vector3.RIGHT) as Vector3
	var outward := chain.get("outward", Vector3.FORWARD) as Vector3
	root_node.transform = Transform3D(Basis(tangent, Vector3.UP, outward), Vector3((start.x + end.x) * 0.5, BASE_ELEVATION_M, (start.z + end.z) * 0.5))
	var render_root := Node3D.new()
	render_root.name = "RenderOnlyBatches"
	render_root.set_meta("render_only", true)
	render_root.set_meta("collision", "none")
	render_root.set_meta("navigation", "none")
	render_root.set_meta("spray_owner", "none")
	root_node.add_child(render_root)
	var authored := _authored_transform_spec(chain)
	if not bool(authored.get("ok", false)):
		root_node.free()
		return null
	_flush_batches(render_root, authored.get("boxes", {}) as Dictionary, materials)
	return root_node


static func _authored_transform_spec(_chain: Dictionary) -> Dictionary:
	var boxes: Dictionary = {}
	var signature_parts: Array[String] = []
	var group_widths: Array[float] = [3.4, 4.1, 3.2, 5.0, 4.0, 4.4, 3.1, 5.1, 3.5, 4.2]
	var pane_counts: Array[int] = [4, 5, 4, 6, 5, 5, 4, 6, 4, 5]
	var group_gap_m := 0.42
	var group_total_m := 0.0
	for group_width in group_widths:
		group_total_m += group_width
	var group_cursor := -CHAIN_LENGTH_M * 0.5 + (CHAIN_LENGTH_M - group_total_m - group_gap_m * 9.0) * 0.5
	for group_index in group_widths.size():
		var group_width_m := group_widths[group_index]
		var group_center_x := group_cursor + group_width_m * 0.5
		var opening := Vector2(group_width_m, 1.04)
		_add_box(boxes, signature_parts, "shared_dark_glass", "ClerestoryGlass%02d" % group_index, Vector3(group_center_x, 4.08, 0.15), Vector3(opening.x, opening.y, 0.08))
		_add_complete_frame(boxes, signature_parts, "B225Clerestory%02d" % group_index, Vector3(group_center_x, 4.08, 0.21), opening, 0.10, pane_counts[group_index] - 1)
		group_cursor += group_width_m + group_gap_m
	_add_box(boxes, signature_parts, "shared_pale_frame", "ContinuousClerestorySill", Vector3(0.0, 3.48, 0.21), Vector3(CHAIN_LENGTH_M, 0.12, 0.12))
	_add_box(boxes, signature_parts, "shared_pale_frame", "QuietRoofEdgeCap", Vector3(0.0, 4.90, 0.18), Vector3(CHAIN_LENGTH_M, 0.14, 0.12))
	signature_parts.sort()
	var actual_signature := JSON.stringify(signature_parts).sha256_text()
	if actual_signature != EXPECTED_DECORATIVE_GEOMETRY_SIGNATURE \
	or not _batch_counts_match(boxes):
		return {"ok": false, "code": "d1_b225_live_authored_transform_signature"}
	return {
		"ok": true,
		"boxes": boxes,
		"signature_parts": signature_parts,
		"signature": actual_signature,
		"batch_counts": _batch_count_dictionary(boxes),
		"box_count": EXPECTED_BOX_COUNT,
		"triangles": EXPECTED_TRIANGLES,
	}
static func _add_complete_frame(boxes: Dictionary, signature_parts: Array[String], prefix: String, center: Vector3, opening: Vector2, thickness_m: float, internal_mullions: int) -> void:
	_add_outer_frame(boxes, signature_parts, prefix, center, opening, thickness_m)
	for mullion_index in internal_mullions:
		var fraction := float(mullion_index + 1) / float(internal_mullions + 1)
		var x := center.x - opening.x * 0.5 + opening.x * fraction
		_add_box(boxes, signature_parts, "shared_pale_frame", "%sMullion%02d" % [prefix, mullion_index], Vector3(x, center.y, center.z), Vector3(thickness_m, opening.y, 0.12))


static func _add_outer_frame(boxes: Dictionary, signature_parts: Array[String], prefix: String, center: Vector3, opening: Vector2, thickness_m: float) -> void:
	_add_box(boxes, signature_parts, "shared_pale_frame", prefix + "Top", center + Vector3(0.0, opening.y * 0.5 + thickness_m * 0.5, 0.0), Vector3(opening.x + thickness_m * 2.0, thickness_m, 0.12))
	_add_box(boxes, signature_parts, "shared_pale_frame", prefix + "Bottom", center + Vector3(0.0, -opening.y * 0.5 - thickness_m * 0.5, 0.0), Vector3(opening.x + thickness_m * 2.0, thickness_m, 0.12))
	_add_box(boxes, signature_parts, "shared_pale_frame", prefix + "Left", center + Vector3(-opening.x * 0.5 - thickness_m * 0.5, 0.0, 0.0), Vector3(thickness_m, opening.y, 0.12))
	_add_box(boxes, signature_parts, "shared_pale_frame", prefix + "Right", center + Vector3(opening.x * 0.5 + thickness_m * 0.5, 0.0, 0.0), Vector3(thickness_m, opening.y, 0.12))


static func _add_box(boxes: Dictionary, signature_parts: Array[String], material_key: String, component_name: String, origin: Vector3, size: Vector3) -> void:
	origin.z -= STANDALONE_FIELD_FRONT_OFFSET_M
	var transform := Transform3D(Basis(Vector3.RIGHT * size.x, Vector3.UP * size.y, Vector3.BACK * size.z), origin)
	if not boxes.has(material_key):
		boxes[material_key] = []
	(boxes[material_key] as Array).append(transform)
	signature_parts.append("%s|%s|%s" % [material_key, component_name, _transform_token(transform)])


static func _flush_batches(render_root: Node3D, boxes: Dictionary, materials: Dictionary) -> void:
	var material_keys := boxes.keys()
	material_keys.sort()
	for material_key_value: Variant in material_keys:
		var material_key := str(material_key_value)
		var transforms := boxes[material_key] as Array
		var box := BoxMesh.new()
		box.size = Vector3.ONE
		box.material = materials[material_key] as Material
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = box
		multimesh.instance_count = transforms.size()
		for index in transforms.size():
			multimesh.set_instance_transform(index, transforms[index] as Transform3D)
		var instance := MultiMeshInstance3D.new()
		instance.name = "Batch_%s" % material_key
		instance.multimesh = multimesh
		instance.layers = RENDER_BUILDING_WALL
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		instance.set_meta("render_only", true)
		instance.set_meta("material_key", material_key)
		instance.set_meta("instance_count", transforms.size())
		instance.set_meta("triangles", transforms.size() * 12)
		render_root.add_child(instance)


static func _batch_counts_match(boxes: Dictionary) -> bool:
	if boxes.size() != EXPECTED_BATCH_COUNTS.size():
		return false
	var total := 0
	for key: String in EXPECTED_BATCH_COUNTS:
		if not boxes.has(key) or (boxes[key] as Array).size() != int(EXPECTED_BATCH_COUNTS[key]):
			return false
		total += (boxes[key] as Array).size()
	return total == EXPECTED_BOX_COUNT


static func _batch_count_dictionary(boxes: Dictionary) -> Dictionary:
	var result := {}
	for key: Variant in boxes:
		result[str(key)] = (boxes[key] as Array).size()
	return result


static func _validated_config_and_materials() -> Dictionary:
	if FileAccess.get_sha256(CONFIG_PATH) != EXPECTED_CONFIG_SHA256:
		return {"ok": false, "message": "Package-safe B225 live config bytes drifted."}
	var config_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not (config_value is Dictionary):
		return {"ok": false, "message": "Package-safe B225 live config did not parse."}
	var config := config_value as Dictionary
	var runtime := config.get("runtime_contract", {}) as Dictionary
	var chain := config.get("eligible_public_chain", {}) as Dictionary
	var geometry := config.get("approved_geometry", {}) as Dictionary
	var translation := config.get("production_translation", {}) as Dictionary
	var translated_counts := translation.get("decorative_batch_instance_counts", {}) as Dictionary
	var protected := config.get("protected_scope", {}) as Dictionary
	if str(config.get("schema_version", "")) != "ti.d1-b225-live-attachment/1" \
	or str(config.get("source_key", "")) != SOURCE_KEY \
	or str(config.get("receiver_key", "")) != RECEIVER_KEY \
	or str(chain.get("mapping_id", "")) != MAPPING_ID \
	or _int_array(chain.get("ordered_run_indices", []) as Array) != RUN_INDICES \
	or not _float_array_matches(chain.get("ordered_run_lengths_m", []) as Array, RUN_LENGTHS_M, 0.000000001) \
	or absf(float(chain.get("chain_length_m", 0.0)) - CHAIN_LENGTH_M) > 0.000000001 \
	or str(chain.get("runtime_meter_plan_signature", "")) != EXPECTED_METER_PLAN_SIGNATURE \
	or absf(float(chain.get("runtime_meter_plan_total_m", 0.0)) - EXPECTED_RUNTIME_CHAIN_TOTAL_M) > 0.000001 \
	or absf(float(chain.get("measured_maximum_chord_deviation_m", -1.0)) - MEASURED_MAX_CHORD_DEVIATION_M) > 0.0000001 \
	or absf(float(chain.get("runtime_float_measured_maximum_chord_deviation_m", -1.0)) - RUNTIME_MEASURED_MAX_CHORD_DEVIATION_M) > 0.0000001 \
	or absf(float(chain.get("maximum_allowed_chord_deviation_m", -1.0)) - MAX_ALLOWED_CHORD_DEVIATION_M) > 0.0000001 \
	or str(chain.get("standalone_meter_plan_signature", "")) != EXPECTED_STANDALONE_METER_PLAN_SIGNATURE \
	or str(geometry.get("standalone_geometry_signature", "")) != EXPECTED_STANDALONE_GEOMETRY_SIGNATURE \
	or str(geometry.get("standalone_meter_plan_signature", "")) != EXPECTED_STANDALONE_METER_PLAN_SIGNATURE \
	or int(geometry.get("batch_count", -1)) != 3 \
	or int(geometry.get("field_run_quad_count", -1)) != 4 \
	or int(geometry.get("box_instance_count", -1)) != EXPECTED_BOX_COUNT \
	or int(geometry.get("triangle_count", -1)) != 1088 \
	or int(translation.get("decorative_box_instance_count", -1)) != EXPECTED_BOX_COUNT \
	or int(translation.get("decorative_triangle_count", -1)) != EXPECTED_TRIANGLES \
	or str(translation.get("decorative_geometry_signature", "")) != EXPECTED_DECORATIVE_GEOMETRY_SIGNATURE \
	or int(translation.get("host_triangle_count_unchanged", -1)) != 28 \
	or int(translation.get("host_surface_count_delta", -1)) != 1 \
	or not _numeric_dictionary_matches(translated_counts, EXPECTED_BATCH_COUNTS) \
	or str(protected.get("protected_roof_canonical_stable_json_sha256", "")) != EXPECTED_CANONICAL_ROOF_RECORD_SHA256 \
	or str(protected.get("protected_roof_runtime_dictionary_sha256", "")) != EXPECTED_RUNTIME_ROOF_RECORD_SHA256 \
	or not bool(protected.get("host_mesh_instance_and_record_geometry_preserved", false)) \
	or bool(protected.get("host_array_mesh_resource_replaced_for_surface_partition", true)) \
	or not bool(protected.get("host_array_mesh_constructed_with_surface_partition", false)) \
	or str(runtime.get("integration_stage", "")) != "production_runtime_attachment" \
	or not bool(runtime.get("canonical_entrypoint_reachable", false)) \
	or str(runtime.get("ordinary_default_runtime_mode", "")) != "exact_target_receiver_host_partition_plus_receiver_relative_render_attachment" \
	or str(runtime.get("production_activation", "")) != "canonical_world_chunk_builder_exact_target_dispatch" \
	or str(runtime.get("attachment_mode", "")) != "receiver_host_material_partition_plus_receiver_relative_render_only_details" \
	or bool(runtime.get("standalone_scene_instantiation", true)) \
	or not bool(runtime.get("host_array_mesh_constructed_with_surface_partition", false)) \
	or int(runtime.get("mesh_instances", -1)) != EXPECTED_BATCH_COUNT \
	or int(runtime.get("surfaces", -1)) != EXPECTED_BATCH_COUNT \
	or int(runtime.get("triangles", -1)) != EXPECTED_TRIANGLES \
	or int(runtime.get("collision_nodes", -1)) != 0 \
	or int(runtime.get("navigation_nodes", -1)) != 0 \
	or int(runtime.get("spray_nodes", -1)) != 0 \
	or str(runtime.get("recognition_status", "")) != "externally_governed_pending_authority_promotion_and_postpromotion_review" \
	or bool(runtime.get("reference_recognizable", true)) \
	or bool(runtime.get("catalog_or_registry_promotion", true)):
		return {"ok": false, "message": "Package-safe B225 live config semantics drifted."}
	var materials: Dictionary = {}
	var declared := config.get("material_assets", {}) as Dictionary
	if declared.size() != MATERIAL_SPECS.size():
		return {"ok": false, "message": "B225 live material declaration set drifted."}
	for material_key: String in MATERIAL_SPECS:
		var expected := MATERIAL_SPECS[material_key] as Dictionary
		var entry := declared.get(material_key, {}) as Dictionary
		var path := str(expected.get("path", ""))
		if str(entry.get("path", "")) != path \
		or str(entry.get("source_sha256", "")) != str(expected.get("sha256", "")) \
		or not ResourceLoader.exists(path):
			return {"ok": false, "message": "B225 live material closure drifted for %s." % material_key}
		if OS.has_feature("editor") and FileAccess.get_sha256(path) != str(expected.get("sha256", "")):
			return {"ok": false, "message": "B225 source material bytes drifted for %s." % material_key}
		var material := load(path) as StandardMaterial3D
		if not _material_matches(material, expected):
			return {"ok": false, "message": "B225 material semantics drifted for %s." % material_key}
		materials[material_key] = material
	return {"ok": true, "config": config, "materials": materials}


static func _numeric_dictionary_matches(actual: Dictionary, expected: Dictionary) -> bool:
	if actual.size() != expected.size():
		return false
	for key: String in expected:
		if not actual.has(key) or int(actual[key]) != int(expected[key]):
			return false
	return true


static func _host_uvs(record: Dictionary, plan: Dictionary) -> PackedVector2Array:
	var source_uvs := record.get("uvs", []) as Array
	var vertices := record.get("vertices", []) as Array
	if source_uvs.size() != 112 or not bool(plan.get("ok", false)):
		return PackedVector2Array()
	var result := PackedVector2Array()
	for offset in range(0, source_uvs.size(), 2):
		result.append(Vector2(float(source_uvs[offset]), float(source_uvs[offset + 1])))
	for run_index in RUN_INDICES:
		var entry := METER_UV.entry_for_run(plan, run_index)
		if entry.is_empty():
			return PackedVector2Array()
		var base := run_index * 12
		var corners: Array[Vector3] = []
		for corner_index in 4:
			var vertex_offset := base + corner_index * 3
			corners.append(Vector3(float(vertices[vertex_offset]), float(vertices[vertex_offset + 1]), float(vertices[vertex_offset + 2])))
		var adapted := METER_UV.vertical_quad_uvs(corners, float(entry.get("u_start_m", 0.0)))
		if adapted.size() != 4:
			return PackedVector2Array()
		for corner_index in 4:
			result[run_index * 4 + corner_index] = adapted[corner_index]
	return result


static func _material_matches(material: StandardMaterial3D, expected: Dictionary) -> bool:
	if not (material != null \
		and material.resource_name == str(expected.get("resource_name", "")) \
		and material.albedo_color.is_equal_approx(expected.get("albedo", Color.TRANSPARENT) as Color) \
		and is_equal_approx(material.metallic, float(expected.get("metallic", -1.0))) \
		and is_equal_approx(material.roughness, float(expected.get("roughness", -1.0))) \
		and material.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED \
		and material.albedo_color.a == 1.0 \
		and material.normal_texture == null \
		and material.roughness_texture == null \
		and material.metallic_texture == null \
		and not material.heightmap_enabled \
		and material.next_pass == null):
		return false
	var texture_path := str(expected.get("albedo_texture_path", ""))
	if texture_path.is_empty():
		return material.albedo_texture == null
	return material.albedo_texture != null \
		and material.albedo_texture.resource_path == texture_path \
		and ResourceLoader.exists(texture_path) \
		and material.uv1_scale.is_equal_approx(expected.get("uv1_scale", Vector3.ZERO) as Vector3) \
		and material.texture_filter == BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC \
		and material.get_flag(BaseMaterial3D.FLAG_USE_TEXTURE_REPEAT) \
		and (not OS.has_feature("editor") or FileAccess.get_sha256(texture_path) == str(expected.get("albedo_texture_sha256", "")))


static func _material_set_matches(materials: Dictionary) -> bool:
	if not _dictionary_keys_match(materials, MATERIAL_SPECS.keys()):
		return false
	for material_key: String in MATERIAL_SPECS:
		var material := materials.get(material_key, null) as StandardMaterial3D
		var expected := MATERIAL_SPECS[material_key] as Dictionary
		if material == null \
		or material.resource_path != str(expected.get("path", "")) \
		or not _material_matches(material, expected):
			return false
	return true


static func _generic_wall_material_matches(material: Material) -> bool:
	var standard := material as StandardMaterial3D
	if standard == null:
		return false
	var albedo := standard.albedo_texture
	var normal := standard.normal_texture
	var roughness := standard.roughness_texture
	return standard.resource_name == "building_wall" \
		and standard.albedo_color.is_equal_approx(Color("f7f2eb")) \
		and is_equal_approx(standard.metallic, 0.0) \
		and is_equal_approx(standard.roughness, 0.92) \
		and standard.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED \
		and standard.cull_mode == BaseMaterial3D.CULL_BACK \
		and albedo != null and albedo.resource_path == str(GENERIC_WALL_TEXTURE_PATHS.albedo) \
		and standard.normal_enabled and normal != null and normal.resource_path == str(GENERIC_WALL_TEXTURE_PATHS.normal) \
		and is_equal_approx(standard.normal_scale, 0.1) \
		and roughness != null and roughness.resource_path == str(GENERIC_WALL_TEXTURE_PATHS.roughness) \
		and standard.metallic_texture == null \
		and not standard.heightmap_enabled \
		and standard.next_pass == null \
		and standard.uv1_scale.is_equal_approx(Vector3(10.0 / 0.75, 10.0 / 0.75, 1.0)) \
		and standard.texture_filter == BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC \
		and standard.get_flag(BaseMaterial3D.FLAG_USE_TEXTURE_REPEAT)


static func _dictionary_keys_match(actual: Dictionary, expected_values: Array) -> bool:
	var actual_keys: Array[String] = []
	var expected_keys: Array[String] = []
	for key: Variant in actual.keys():
		actual_keys.append(str(key))
	for key: Variant in expected_values:
		expected_keys.append(str(key))
	actual_keys.sort()
	expected_keys.sort()
	return actual_keys == expected_keys


static func _float_values_match(actual: Array, expected: Array, tolerance: float) -> bool:
	if actual.size() != expected.size():
		return false
	for index in expected.size():
		if absf(float(actual[index]) - float(expected[index])) > tolerance:
			return false
	return true


static func _packed_vector2_array_matches(actual: PackedVector2Array, expected: PackedVector2Array) -> bool:
	if actual.size() != expected.size():
		return false
	for index in expected.size():
		if not actual[index].is_equal_approx(expected[index]):
			return false
	return true


static func render_topology(root_node: Node) -> Dictionary:
	var result := {"mesh_instances": 0, "surfaces": 0, "triangles": 0}
	if root_node is MultiMeshInstance3D:
		var multimesh := (root_node as MultiMeshInstance3D).multimesh
		if multimesh != null and multimesh.mesh != null:
			result.mesh_instances = 1
			result.surfaces = multimesh.mesh.get_surface_count()
			result.triangles = multimesh.instance_count * 12
	elif root_node is MeshInstance3D:
		var mesh := (root_node as MeshInstance3D).mesh
		if mesh != null:
			result.mesh_instances = 1
			result.surfaces = mesh.get_surface_count()
			for surface_index in mesh.get_surface_count():
				var arrays := mesh.surface_get_arrays(surface_index)
				result.triangles += int((arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
	for child: Node in root_node.get_children():
		var child_result := render_topology(child)
		result.mesh_instances += int(child_result.mesh_instances)
		result.surfaces += int(child_result.surfaces)
		result.triangles += int(child_result.triangles)
	return result


static func _distance_to_chord_xz(point: Vector3, start: Vector3, end: Vector3) -> float:
	var chord := Vector2(end.x - start.x, end.z - start.z)
	var offset := Vector2(point.x - start.x, point.z - start.z)
	return absf(chord.cross(offset)) / chord.length()


static func _transform_token(value: Transform3D) -> String:
	return "%.6f,%.6f,%.6f|%.6f,%.6f,%.6f|%.6f,%.6f,%.6f|%.6f,%.6f,%.6f" % [
		value.basis.x.x, value.basis.x.y, value.basis.x.z,
		value.basis.y.x, value.basis.y.y, value.basis.y.z,
		value.basis.z.x, value.basis.z.y, value.basis.z.z,
		value.origin.x, value.origin.y, value.origin.z,
	]


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func _float_array_matches(actual: Array, expected: Array[float], tolerance: float) -> bool:
	if actual.size() != expected.size():
		return false
	for index in expected.size():
		if absf(float(actual[index]) - expected[index]) > tolerance:
			return false
	return true


static func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


static func _stable_json(value: Variant, depth: int) -> String:
	match typeof(value):
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "true" if bool(value) else "false"
		TYPE_INT:
			return str(int(value))
		TYPE_FLOAT:
			var number := float(value)
			return str(int(number)) if number == floor(number) else JSON.stringify(number)
		TYPE_STRING, TYPE_STRING_NAME:
			return JSON.stringify(str(value))
		TYPE_ARRAY:
			var values := value as Array
			if values.is_empty():
				return "[]"
			var lines: Array[String] = []
			for item: Variant in values:
				lines.append(" ".repeat((depth + 1) * 2) + _stable_json(item, depth + 1))
			return "[\n%s\n%s]" % [",\n".join(lines), " ".repeat(depth * 2)]
		TYPE_DICTIONARY:
			var object := value as Dictionary
			if object.is_empty():
				return "{}"
			var keys: Array[String] = []
			for key: Variant in object.keys():
				keys.append(str(key))
			keys.sort()
			var lines: Array[String] = []
			for key: String in keys:
				lines.append(" ".repeat((depth + 1) * 2) + JSON.stringify(key) + ": " + _stable_json(object[key], depth + 1))
			return "{\n%s\n%s}" % [",\n".join(lines), " ".repeat(depth * 2)]
	return JSON.stringify(value)


static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	return {"ok": false, "code": code, "message": message, "source_keys": record.get("source_keys", [])}
