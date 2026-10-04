class_name D1B201LiveAttachment
extends RefCounted

## Fail-closed, receiver-relative promotion of the independently reviewed
## Building 201 WSW standalone composition. The supplied generic wall remains
## the sole mesh/collision/spray receiver: its public runs receive one material
## partition and this helper adds only non-coplanar render detail batches.

const METER_UV := preload("res://game/scripts/world/facades/facade_meter_uv_adapter.gd")
const CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b201_live_attachment.json"
const SOURCE_KEY := "w34313545"
const RECEIVER_KEY := "building:w34313545:wall"
const ROOF_KEY := "building:w34313545:roof"
const TARGET_CHUNK_ID := "x_0__z_-2"
const MAPPING_ID := "800I-PUBLIC-WSW"
const RUN_INDICES: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
const RUN_LENGTHS_M: Array[float] = [8.395309702, 10.181251102, 13.457963962, 22.843742360, 0.795472815, 1.484884507, 22.154330547, 11.867490763, 11.771724300, 12.560491431]
const CHAIN_LENGTH_M := 115.512661489
const BASE_ELEVATION_M := 3.402
const TOP_ELEVATION_M := 8.402
const HEIGHT_M := 5.0
const MAX_ALLOWED_CHORD_DEVIATION_M := 0.001
const STANDALONE_FIELD_FRONT_OFFSET_M := 0.10
const RENDER_BUILDING_WALL := 1 << 1
const MATERIAL_SPECS := {
	"b201_green_hierarchy": {"path": "res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres"},
	"b201_muted_rust_post": {"path": "res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres"},
	"b201_service_leaf": {"path": "res://game/resources/materials/world/d1_current/b201_service_leaf.tres"},
	"b201_warm_wall": {"path": "res://game/resources/materials/world/d1_current/b201_warm_wall.tres"},
	"shared_dark_glass": {"path": "res://game/resources/materials/world/d1_current/shared_dark_glass.tres"},
	"shared_pale_frame": {"path": "res://game/resources/materials/world/d1_current/shared_pale_frame.tres"},
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
	if not target_chunk and exact_walls.is_empty() and target_memberships == 0:
		return {"ok": true, "applies": false}
	if not target_chunk or exact_walls.size() != 1 or exact_roofs.size() != 1 or target_memberships != 2 or unexpected_target_membership:
		return {"ok": false, "code": "d1_b201_live_chunk_membership", "message": "Supplied B201 chunk membership or exact wall/roof pairing drifted.", "source_keys": [SOURCE_KEY]}
	var wall := exact_walls[0]
	var roof := exact_roofs[0]
	if not _record_shape_matches(wall):
		return _failure("d1_b201_live_chunk_wall_authority", "Supplied B201 wall row does not have the expected wall structure.", wall)
	if not _roof_shape_matches(roof):
		return _failure("d1_b201_live_chunk_roof_authority", "Protected B201 roof row does not have the expected roof structure.", roof)
	return {"ok": true, "applies": true}


static func prepare(record: Dictionary) -> Dictionary:
	if not claims_record(record):
		return _failure("d1_b201_live_unclaimed_receiver", "Record is not the exact B201 target identity.", record)
	if not _record_shape_matches(record):
		return _failure("d1_b201_live_record_authority", "The supplied B201 target row does not have the expected wall structure.", record)
	var config_result := _validated_config_and_materials()
	if not bool(config_result.get("ok", false)):
		return _failure("d1_b201_live_package_authority", str(config_result.get("message", "Live config or material closure drifted.")), record)
	var chain_result := _receiver_chain(record)
	if not bool(chain_result.get("ok", false)):
		return _failure("d1_b201_live_receiver_chain", str(chain_result.get("message", "Eligible receiver chain drifted.")), record)
	var host_uvs := _host_uvs(record, chain_result.get("plan", {}) as Dictionary)
	if host_uvs.size() != 160:
		return _failure("d1_b201_live_host_uv", "B201 host metre-UV adaptation failed.", record)
	return {
		"ok": true,
		"chain": chain_result,
		"config": config_result.get("config", {}) as Dictionary,
		"materials": config_result.get("materials", {}) as Dictionary,
		"host_uvs": host_uvs,
	}


static func build(record: Dictionary) -> Dictionary:
	var prepared := prepare(record)
	if not bool(prepared.get("ok", false)):
		return prepared
	return build_prepared(record, prepared)


static func authored_transform_spec(record: Dictionary, prepared: Dictionary) -> Dictionary:
	# MultiMesh transform readback is identity-only under Godot's Dummy renderer.
	# Expose the exact authored transforms before upload so headless contracts can
	# still prove geometry, host clearance, and grounding.
	if not _prepared_matches(record, prepared):
		return _failure("d1_b201_live_unprepared", "B201 authored transforms require a valid prepared target row.", record)
	return _authored_transform_spec(prepared.get("chain", {}) as Dictionary)


static func build_prepared(record: Dictionary, prepared: Dictionary) -> Dictionary:
	if not _prepared_matches(record, prepared):
		return _failure("d1_b201_live_unprepared", "B201 attachment requires a valid prepared target row.", record)
	var root_node := _build_render_attachment(prepared.get("chain", {}) as Dictionary, prepared.get("materials", {}) as Dictionary)
	if root_node == null:
		return _failure("d1_b201_live_geometry", "Approved B201 render geometry failed to build.", record)
	var topology := render_topology(root_node)
	if int(topology.get("triangles", 0)) <= 0 \
	or _count_type(root_node, CollisionObject3D) != 0 \
	or _count_type(root_node, CollisionShape3D) != 0 \
	or _count_type(root_node, NavigationRegion3D) != 0 \
	or _count_type(root_node, Decal) != 0:
		root_node.free()
		return _failure("d1_b201_live_topology", "B201 attachment is empty or owns collision, navigation, or decals.", record)
	var metadata := {
		"schema_version": "ti.d1-b201-live-attachment/1",
		"source_key": SOURCE_KEY,
		"receiver_key": RECEIVER_KEY,
		"mapping_id": MAPPING_ID,
		"attachment_mode": "receiver_host_material_partition_plus_receiver_relative_render_only_details",
		"host_mesh_preserved": true,
		"host_protected_run_render_preserved": true,
		"host_eligible_run_material_changed": true,
		"host_collision_owner_preserved": true,
		"host_spray_owner_preserved": true,
		"ordered_run_indices": RUN_INDICES.duplicate(),
		"chain_length_m": CHAIN_LENGTH_M,
		"config_path": CONFIG_PATH,
		"mesh_instances": int(topology.mesh_instances),
		"surfaces": int(topology.surfaces),
		"triangles": int(topology.triangles),
		"collision_nodes": 0,
		"navigation_nodes": 0,
		"spray_nodes": 0,
	}
	for key: String in metadata:
		root_node.set_meta(key, metadata[key])
	return {
		"ok": true,
		"node": root_node,
		"mesh_instances": int(topology.mesh_instances),
		"surfaces": int(topology.surfaces),
		"triangles": int(topology.triangles),
		"metadata": metadata,
	}


static func host_uvs(record: Dictionary, prepared: Dictionary) -> PackedVector2Array:
	if not _prepared_matches(record, prepared):
		return PackedVector2Array()
	return (prepared.get("host_uvs", PackedVector2Array()) as PackedVector2Array).duplicate()


static func partition_host(record: Dictionary, reversed_indices: PackedInt32Array, placeholder_material: Material, prepared: Dictionary) -> Dictionary:
	if not _prepared_matches(record, prepared) \
	or reversed_indices.size() != 240 or not _generic_wall_material_matches(placeholder_material):
		return _failure("d1_b201_live_host_partition_input", "B201 host partition inputs drifted.", record)
	var expected_reversed := PackedInt32Array()
	var source_indices := record.get("indices", []) as Array
	for offset in range(0, source_indices.size(), 3):
		expected_reversed.append(int(source_indices[offset]))
		expected_reversed.append(int(source_indices[offset + 2]))
		expected_reversed.append(int(source_indices[offset + 1]))
	if reversed_indices != expected_reversed:
		return _failure("d1_b201_live_host_partition_indices", "B201 host partition indices were not the exact complete supplied wall winding.", record)
	var materials := prepared.get("materials", {}) as Dictionary
	var warm_material := materials.get("b201_warm_wall", null) as Material
	if warm_material == null:
		return _failure("d1_b201_live_host_partition_material", "B201 host partition material did not resolve.", record)
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
	if public_indices.size() != 60 or protected_indices.size() != 180:
		return _failure("d1_b201_live_host_partition_scope", "B201 host partition leaked beyond runs 0..9.", record)
	return {
		"ok": true,
		"surfaces": [
			{"name": "generated_record_protected_runs_10_39", "indices": protected_indices, "material": placeholder_material},
			{"name": "d1_b201_public_wsw_runs_0_9", "indices": public_indices, "material": warm_material},
		],
		"metadata": {
			"schema_version": "ti.d1-b201-host-partition/1",
			"receiver_key": RECEIVER_KEY,
			"public_material_runs": RUN_INDICES.duplicate(),
			"protected_generic_runs": range(10, 40),
			"public_triangles": 20,
			"protected_triangles": 60,
			"total_triangles": 80,
			"host_collision_owner_preserved": true,
			"host_spray_owner_preserved": true,
		},
	}


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
		and str(record.get("object_key", "")) == RECEIVER_KEY \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("material_key", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and is_equal_approx(float(record.get("flat_base_elevation_m", -1.0)), BASE_ELEVATION_M) \
		and is_equal_approx(float(record.get("top_elevation_m", -1.0)), TOP_ELEVATION_M) \
		and is_equal_approx(float(record.get("source_height_m", -1.0)), HEIGHT_M) \
		and int(record.get("exterior_foundation_segments", -1)) == 40 \
		and int(record.get("shared_wall_segments", -1)) == 0 \
		and (record.get("vertices", []) as Array).size() == 480 \
		and (record.get("normals", []) as Array).size() == 480 \
		and (record.get("uvs", []) as Array).size() == 320 \
		and (record.get("indices", []) as Array).size() == 240


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
		and (record.get("vertices", []) as Array).size() == 42 \
		and (record.get("normals", []) as Array).size() == 42 \
		and (record.get("uvs", []) as Array).size() == 28 \
		and (record.get("indices", []) as Array).size() == 36


static func _prepared_matches(record: Dictionary, prepared: Dictionary) -> bool:
	var chain := prepared.get("chain", {}) as Dictionary
	if not (bool(prepared.get("ok", false)) \
		and _record_shape_matches(record)):
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
	if not bool(plan.get("ok", false)):
		return {"ok": false, "message": "Cumulative metre chain contract drifted."}
	var start := endpoints.front() as Vector3
	var end := endpoints.back() as Vector3
	var tangent := Vector3(end.x - start.x, 0.0, end.z - start.z).normalized()
	var outward := tangent.cross(Vector3.UP).normalized()
	var measured_deviation := 0.0
	for point: Vector3 in endpoints:
		measured_deviation = maxf(measured_deviation, _distance_to_chord_xz(point, start, end))
	if measured_deviation > MAX_ALLOWED_CHORD_DEVIATION_M:
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
	root_node.name = "D1B201LiveAttachment"
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


static func _authored_transform_spec(chain: Dictionary) -> Dictionary:
	var boxes: Dictionary = {}
	var register_margin_m := 1.35
	var register_span_m := CHAIN_LENGTH_M - register_margin_m * 2.0
	var bay_pitch_m := register_span_m / 18.0
	var glass_width_m := bay_pitch_m - 0.88
	var register_start_m := -CHAIN_LENGTH_M * 0.5 + register_margin_m
	for pier_index in 19:
		_add_box(boxes, "b201_warm_wall", "UpperPier%02d" % pier_index, Vector3(register_start_m + bay_pitch_m * pier_index, 3.66, 0.17), Vector3(0.56, 1.28, 0.14))
	for bay_index in 18:
		var center_x := register_start_m + bay_pitch_m * (bay_index + 0.5)
		var opening := Vector2(glass_width_m, 1.05)
		_add_box(boxes, "shared_dark_glass", "UpperGlass%02d" % bay_index, Vector3(center_x, 3.66, 0.15), Vector3(opening.x, opening.y, 0.08))
		_add_complete_frame(boxes, "B201Upper%02d" % bay_index, Vector3(center_x, 3.66, 0.21), opening, 0.11, 2)
	_add_box(boxes, "b201_green_hierarchy", "LowerRegisterBand", Vector3(0.0, 3.02, 0.22), Vector3(CHAIN_LENGTH_M, 0.22, 0.16))
	_add_box(boxes, "b201_green_hierarchy", "UpperRegisterBand", Vector3(0.0, 4.30, 0.22), Vector3(CHAIN_LENGTH_M, 0.20, 0.16))
	_add_box(boxes, "b201_green_hierarchy", "RoofParapetCap", Vector3(0.0, 4.91, 0.20), Vector3(CHAIN_LENGTH_M, 0.18, 0.16))
	var canopy_center_x := -6.0
	var canopy_width_m := 58.0
	_add_box(boxes, "b201_warm_wall", "CanopySlab", Vector3(canopy_center_x, 2.73, 0.98), Vector3(canopy_width_m, 0.18, 1.76))
	_add_box(boxes, "b201_green_hierarchy", "CanopyFrontFascia", Vector3(canopy_center_x, 2.70, 1.91), Vector3(canopy_width_m, 0.34, 0.12))
	for post_index in 7:
		var post_x := canopy_center_x - canopy_width_m * 0.5 + 2.2 + post_index * ((canopy_width_m - 4.4) / 6.0)
		var post_bottom_y := _sample_host_bottom_local_y(chain, post_x) - 0.06
		var post_top_y := 2.62
		_add_box(boxes, "b201_muted_rust_post", "CanopyPost%02d" % post_index, Vector3(post_x, (post_bottom_y + post_top_y) * 0.5, 1.66), Vector3(0.18, post_top_y - post_bottom_y, 0.18))
	var service_xs: Array[float] = [-43.0, -4.0, 38.0]
	for door_index in service_xs.size():
		var door_x := service_xs[door_index]
		var door_bottom_y := _sample_host_bottom_local_y(chain, door_x) - 0.04
		var door_top_y := 2.21
		var door_opening := Vector2(1.34, door_top_y - door_bottom_y)
		var door_center := Vector3(door_x, (door_bottom_y + door_top_y) * 0.5, 0.16)
		_add_box(boxes, "b201_service_leaf", "SparseServiceLeaf%02d" % door_index, door_center, Vector3(door_opening.x, door_opening.y, 0.09))
		_add_outer_frame(boxes, "B201Service%02d" % door_index, door_center + Vector3(0.0, 0.0, 0.06), door_opening, 0.11)
	var box_count := 0
	for key: Variant in boxes:
		box_count += (boxes[key] as Array).size()
	return {
		"ok": true,
		"boxes": boxes,
		"batch_counts": _batch_count_dictionary(boxes),
		"box_count": box_count,
		"triangles": box_count * 12,
	}


static func _sample_host_bottom_local_y(chain: Dictionary, local_x: float) -> float:
	var chain_u := clampf(local_x + CHAIN_LENGTH_M * 0.5, 0.0, CHAIN_LENGTH_M)
	var plan := chain.get("plan", {}) as Dictionary
	var runs := chain.get("runs", []) as Array
	for entry_value: Variant in plan.get("entries", []) as Array:
		var entry := entry_value as Dictionary
		var u_start := float(entry.get("u_start_m", 0.0))
		var u_end := float(entry.get("u_end_m", 0.0))
		if chain_u <= u_end + 0.000001:
			var order_index := int(entry.get("order_index", -1))
			if order_index < 0 or order_index >= runs.size() or u_end <= u_start:
				return -1000.0
			var run := runs[order_index] as Dictionary
			var start_values := run.get("start_xyz_m", []) as Array
			var end_values := run.get("end_xyz_m", []) as Array
			var fraction := clampf((chain_u - u_start) / (u_end - u_start), 0.0, 1.0)
			return lerpf(float(start_values[1]), float(end_values[1]), fraction) - BASE_ELEVATION_M
	return -1000.0


static func _add_complete_frame(boxes: Dictionary, prefix: String, center: Vector3, opening: Vector2, thickness_m: float, internal_mullions: int) -> void:
	_add_outer_frame(boxes, prefix, center, opening, thickness_m)
	for mullion_index in internal_mullions:
		var fraction := float(mullion_index + 1) / float(internal_mullions + 1)
		var x := center.x - opening.x * 0.5 + opening.x * fraction
		_add_box(boxes, "shared_pale_frame", "%sMullion%02d" % [prefix, mullion_index], Vector3(x, center.y, center.z), Vector3(thickness_m, opening.y, 0.12))


static func _add_outer_frame(boxes: Dictionary, prefix: String, center: Vector3, opening: Vector2, thickness_m: float) -> void:
	_add_box(boxes, "shared_pale_frame", prefix + "Top", center + Vector3(0.0, opening.y * 0.5 + thickness_m * 0.5, 0.0), Vector3(opening.x + thickness_m * 2.0, thickness_m, 0.12))
	_add_box(boxes, "shared_pale_frame", prefix + "Bottom", center + Vector3(0.0, -opening.y * 0.5 - thickness_m * 0.5, 0.0), Vector3(opening.x + thickness_m * 2.0, thickness_m, 0.12))
	_add_box(boxes, "shared_pale_frame", prefix + "Left", center + Vector3(-opening.x * 0.5 - thickness_m * 0.5, 0.0, 0.0), Vector3(thickness_m, opening.y, 0.12))
	_add_box(boxes, "shared_pale_frame", prefix + "Right", center + Vector3(opening.x * 0.5 + thickness_m * 0.5, 0.0, 0.0), Vector3(thickness_m, opening.y, 0.12))


static func _add_box(boxes: Dictionary, material_key: String, _component_name: String, origin: Vector3, size: Vector3) -> void:
	origin.z -= STANDALONE_FIELD_FRONT_OFFSET_M
	var transform := Transform3D(Basis(Vector3.RIGHT * size.x, Vector3.UP * size.y, Vector3.BACK * size.z), origin)
	if not boxes.has(material_key):
		boxes[material_key] = []
	(boxes[material_key] as Array).append(transform)


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


static func _batch_count_dictionary(boxes: Dictionary) -> Dictionary:
	var result := {}
	for key: Variant in boxes:
		result[str(key)] = (boxes[key] as Array).size()
	return result


static func _validated_config_and_materials() -> Dictionary:
	var config_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not (config_value is Dictionary):
		return {"ok": false, "message": "Package-safe B201 live config did not parse."}
	var config := config_value as Dictionary
	var chain := config.get("eligible_public_chain", {}) as Dictionary
	if str(config.get("schema_version", "")) != "ti.d1-b201-live-attachment/1" \
	or str(config.get("source_key", "")) != SOURCE_KEY \
	or str(config.get("receiver_key", "")) != RECEIVER_KEY \
	or str(chain.get("mapping_id", "")) != MAPPING_ID \
	or _int_array(chain.get("ordered_run_indices", []) as Array) != RUN_INDICES:
		return {"ok": false, "message": "Package-safe B201 live config does not describe this receiver."}
	var materials: Dictionary = {}
	var declared := config.get("material_assets", {}) as Dictionary
	if declared.size() != MATERIAL_SPECS.size():
		return {"ok": false, "message": "B201 live material declaration set drifted."}
	for material_key: String in MATERIAL_SPECS:
		var expected := MATERIAL_SPECS[material_key] as Dictionary
		var entry := declared.get(material_key, {}) as Dictionary
		var path := str(expected.get("path", ""))
		if str(entry.get("path", "")) != path \
		or not ResourceLoader.exists(path):
			return {"ok": false, "message": "B201 live material is missing or mis-declared for %s." % material_key}
		var material := load(path) as StandardMaterial3D
		if not _material_matches(material, expected):
			return {"ok": false, "message": "B201 material semantics drifted for %s." % material_key}
		materials[material_key] = material
	return {"ok": true, "config": config, "materials": materials}


static func _host_uvs(record: Dictionary, plan: Dictionary) -> PackedVector2Array:
	var source_uvs := record.get("uvs", []) as Array
	var vertices := record.get("vertices", []) as Array
	if source_uvs.size() != 320 or not bool(plan.get("ok", false)):
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
	if material == null:
		return false
	var texture_path := str(expected.get("albedo_texture_path", ""))
	return texture_path.is_empty() or ResourceLoader.exists(texture_path)


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
	return standard != null and standard.resource_name == "building_wall"


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


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


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
