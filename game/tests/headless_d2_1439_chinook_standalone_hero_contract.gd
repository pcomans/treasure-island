extends SceneTree

const PROTOTYPE := preload("res://game/scripts/world/facades/d2_1439_chinook_standalone_hero_prototype.gd")
const CONFIG_PATH := "res://game/resources/facades/d2_1439_chinook_standalone_hero_prototype.json"
const SCENE_PATH := "res://game/scenes/world/facades/site_12_housing/d2_1439_chinook_standalone_hero_prototype.tscn"
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_0.json"
const PACKET_PATH := "res://discovery/facades/d2_reference_packets/w95934144_1439_chinook_court.md"
const WALL_KEY := "building:w95934144:wall"
const ROOF_KEY := "building:w95934144:roof"
const SOURCE_KEY := "w95934144"
const TARGET_RUNS := [11, 12, 16, 17, 18, 19, 22, 23]
const MOTIF_HOST_RUNS := [11, 19, 23]
const MAPPED_MOTIF_FREE_RUNS := [12, 16, 17, 18, 22]
const TINY_FRAGMENT_RUNS := [17, 18]
const PROTECTED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 20, 21]
const EXPECTED_CHUNK_SHA256 := "3e7d1cb020d4a8f8a2852121a181a1e2d441fee40de42d744d37fbbcba59168b"
const EXPECTED_PACKET_SHA256 := "050ceb6195bf1f7a4b1c753cde5a509c30b0911599af9233db5746605b9cfeb6"
const EXPECTED_SIGNATURE := "b82660eb7774ab022c417c7d417d51646f68fd288d916ad47a91d58db5bc8fb9"
const EXPECTED_BATCH_TRIANGLES := {
	"ProtectedExactWallRuns": 32,
	"MappedSSEExactWarmStuccoWallRuns": 16,
	"ExactPlanShallowGableRoof": 10,
	"MappedSSEContinuousEaveChains": 36,
	"OffsetEndTwoLevelBalconyVoids": 24,
	"OffsetEndBalconySlabs": 24,
	"OffsetEndSimpleMetalRails": 168,
	"QuietRegisterUpperOpaqueOpenings": 36,
	"QuietRegisterUpperPaleFrames": 180,
	"BlankEndGroundPassageShadow": 12,
	"BlankEndGroundPassageFrame": 36,
}
const EXPECTED_MATERIALS := {
	"ProtectedExactWallRuns": "res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
	"MappedSSEExactWarmStuccoWallRuns": "res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
	"ExactPlanShallowGableRoof": "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
	"MappedSSEContinuousEaveChains": "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
	"OffsetEndTwoLevelBalconyVoids": "res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
	"OffsetEndBalconySlabs": "res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
	"OffsetEndSimpleMetalRails": "res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
	"QuietRegisterUpperOpaqueOpenings": "res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
	"QuietRegisterUpperPaleFrames": "res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
	"BlankEndGroundPassageShadow": "res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
	"BlankEndGroundPassageFrame": "res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
}
const LIVE_ROUTE_FILES := [
	"res://game/scripts/world/world_chunk_builder.gd",
	"res://game/scripts/main.gd",
	"res://game/resources/facades/facade-runtime-registry.json",
	"res://game/scripts/world/facades/facade_runtime_registry_loader.gd",
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config := _json(CONFIG_PATH)
	var chunk := _json(CHUNK_PATH)
	var wall := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	print("D2_1439_RECORD_SIGNATURES wall=", PROTOTYPE.record_signature(wall), " roof=", PROTOTYPE.record_signature(roof))
	_require(FileAccess.get_sha256(CHUNK_PATH) == EXPECTED_CHUNK_SHA256, "Frozen chunk hash drifted.")
	_require(FileAccess.get_sha256(PACKET_PATH) == EXPECTED_PACKET_SHA256, "Authoritative packet hash drifted.")
	_require(_truth_contract_matches(config), "Truth/config contract drifted.")
	_require(PROTOTYPE.record_signature(wall) == PROTOTYPE.EXPECTED_WALL_RECORD_SHA256, "Wall record signature drifted.")
	_require(PROTOTYPE.record_signature(roof) == PROTOTYPE.EXPECTED_ROOF_RECORD_SHA256, "Roof record signature drifted.")
	_require(PROTOTYPE.matches_record_pair(wall, roof), "Exact source pair did not match.")
	var result := PROTOTYPE.build_for_records(wall, roof)
	_require(bool(result.get("ok", false)), "Factory failed: %s" % result)
	if bool(result.get("ok", false)):
		var instance := result.node as Node3D
		root.add_child(instance)
		await physics_frame
		var metadata := result.metadata as Dictionary
		print("D2_1439_TOPOLOGY ", JSON.stringify({"signature": metadata.deterministic_signature, "batches": metadata.visual_batch_triangles, "visual_triangles": metadata.visual_triangles, "collision_triangles": metadata.collision_triangles, "rail_pickets": metadata.rail_picket_count}))
		_require(_prototype_matches(instance, metadata, wall, roof), "Built prototype contract drifted.")
		_require(_visual_batches_match(instance), "Visual batch/material contract drifted.")
		_require(_source_shell_matches(instance, wall), "Exact source wall shell was not preserved.")
		_require(_roof_plan_matches(instance, roof), "Exact source roof XZ triangles were not preserved.")
		_require(_motifs_stay_near_hosts(instance, wall), "Facade motifs escaped runs 11, 19, or 23.")
		_require(_eaves_stay_near_target_runs(instance, wall), "Continuous eaves escaped the exact mapped SSE run family.")
		_require(_collision_tree_matches(instance), "Collision/ownership topology drifted.")
		_require(_mesh_uvs_complete(instance), "A visual batch lost its meter-authored UV channel.")
		instance.queue_free()
		await process_frame
	_require(_matcher_fails_closed(wall, roof), "Matcher did not fail closed under identity, geometry, or topology mutation.")
	_require(_material_uv_contract_matches(), "Meter UV/material-map boundary drifted.")
	_require(_package_boundary_is_clean(), "Prototype leaked into a live route file.")
	var packed := load(SCENE_PATH) as PackedScene
	_require(packed != null, "Standalone scene did not load.")
	if packed != null:
		var scene_instance := packed.instantiate()
		root.add_child(scene_instance)
		await physics_frame
		_require(bool(scene_instance.get_meta("prototype_only", false)), "Scene did not auto-configure exact standalone prototype.")
		scene_instance.queue_free()
	await process_frame
	_finish()


func _truth_contract_matches(config: Dictionary) -> bool:
	if str(config.get("schema_version", "")) != "ti.d2-1439-chinook-standalone-hero-prototype/1":
		return false
	var target := config.get("target", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	var mapped := config.get("mapped_public_region", {}) as Dictionary
	var protected := config.get("protected_region", {}) as Dictionary
	var collision := config.get("collision_contract", {}) as Dictionary
	var kit := config.get("site_12_kit_contract", {}) as Dictionary
	var material := config.get("material_scope", {}) as Dictionary
	return str(target.get("source_key", "")) == SOURCE_KEY \
		and str(target.get("wall_object_key", "")) == WALL_KEY \
		and str(target.get("roof_object_key", "")) == ROOF_KEY \
		and str(target.get("source_geometry_sha256", "")) == PROTOTYPE.SOURCE_GEOMETRY_SHA256 \
		and float(target.get("source_height_m", 0.0)) == 6.0 \
		and float(target.get("source_base_y_m", 0.0)) == 3.536 \
		and float(target.get("source_wall_top_y_m", 0.0)) == 9.536 \
		and int(target.get("wall_run_count", 0)) == 24 \
		and bool(truth.get("prototype_only", false)) and not bool(truth.get("runtime_attachment", true)) \
		and not bool(truth.get("recognition_accepted", true)) and not bool(truth.get("believability_accepted", true)) \
		and not bool(truth.get("as_built_claim", true)) and not bool(truth.get("interior_modeled", true)) \
		and not bool(truth.get("reference_pixels_stored_or_copied", true)) \
		and not bool(truth.get("horizontal_source_footprint_changed", true)) \
		and not bool(truth.get("source_wall_height_changed", true)) \
		and _int_array(mapped.get("ordered_run_indices", []) as Array) == TARGET_RUNS \
		and _int_array(mapped.get("motif_host_runs", []) as Array) == MOTIF_HOST_RUNS \
		and _int_array(mapped.get("mapped_motif_free_runs", []) as Array) == MAPPED_MOTIF_FREE_RUNS \
		and _int_array(mapped.get("tiny_fragment_runs", []) as Array) == TINY_FRAGMENT_RUNS \
		and _int_array(protected.get("run_indices", []) as Array) == PROTECTED_RUNS \
		and str(collision.get("spray_ownership", "")).begins_with("none in standalone") \
		and str(kit.get("kit_id", "")) == "site-12-housing-kit-v1" \
		and str(kit.get("entity_specific_schedule_location", "")).contains("d2_1439_chinook") \
		and str((material.get("target_stucco", {}) as Dictionary).get("application", "")).contains("eaves use the dark roof surrogate") \
		and _confusion_matches(config)


func _confusion_matches(config: Dictionary) -> bool:
	var authoritative := config.get("authoritative_confusion_set", []) as Array
	var implemented := config.get("implemented_comparison_set", []) as Array
	if authoritative.size() != 3 or implemented.size() != 2:
		return false
	var expected_authoritative := {
		"1437 Chinook Court": "w95934113",
		"1441 Chinook Court": "w95934105",
		"1438 Chinook Court": "w95934131",
	}
	for value: Variant in authoritative:
		var item := value as Dictionary
		if str(expected_authoritative.get(str(item.get("name", "")), "")) != str(item.get("source_key", "")):
			return false
	var implemented_ids: Array[String] = []
	for value: Variant in implemented:
		implemented_ids.append(str((value as Dictionary).get("source_key", "")))
	implemented_ids.sort()
	return implemented_ids == ["w95934105", "w95934117"]


func _prototype_matches(instance: Node3D, metadata: Dictionary, wall: Dictionary, roof: Dictionary) -> bool:
	return str(metadata.get("model_id", "")) == "d2-1439-chinook-standalone-hero-prototype-v1" \
		and str(metadata.get("kit_id", "")) == "site-12-housing-kit-v1" \
		and str(metadata.get("wall_record_sha256", "")) == PROTOTYPE.record_signature(wall) \
		and str(metadata.get("roof_record_sha256", "")) == PROTOTYPE.record_signature(roof) \
		and bool(metadata.get("prototype_only", false)) and not bool(metadata.get("runtime_attachment", true)) \
		and not bool(metadata.get("recognition_accepted", true)) and not bool(metadata.get("believability_accepted", true)) \
		and not bool(metadata.get("as_built_claim", true)) and not bool(metadata.get("interior_modeled", true)) \
		and not bool(metadata.get("horizontal_source_footprint_changed", true)) \
		and not bool(metadata.get("source_wall_height_changed", true)) \
		and _int_array(metadata.get("mapped_public_run_indices", []) as Array) == TARGET_RUNS \
		and _int_array(metadata.get("motif_host_run_indices", []) as Array) == MOTIF_HOST_RUNS \
		and _int_array(metadata.get("mapped_motif_free_run_indices", []) as Array) == MAPPED_MOTIF_FREE_RUNS \
		and _int_array(metadata.get("tiny_fragment_run_indices", []) as Array) == TINY_FRAGMENT_RUNS \
		and _int_array(metadata.get("protected_run_indices", []) as Array) == PROTECTED_RUNS \
		and not bool(metadata.get("protected_runs_have_facade_modules", true)) \
		and int(metadata.get("balcony_void_count", -1)) == 2 \
		and int(metadata.get("rail_picket_count", -1)) == 10 \
		and int(metadata.get("quiet_upper_opening_count", -1)) == 3 \
		and int(metadata.get("passage_void_count", -1)) == 1 \
		and int(metadata.get("passage_pier_count", -1)) == 2 \
		and int(metadata.get("mapped_eave_chain_count", -1)) == 3 \
		and int(metadata.get("mesh_instances", -1)) == 11 and int(metadata.get("surfaces", -1)) == 11 \
		and int(metadata.get("visual_triangles", -1)) == 574 \
		and _batch_triangles_match(metadata.get("visual_batch_triangles", {}) as Dictionary) \
		and int(metadata.get("static_bodies", -1)) == 1 and int(metadata.get("shapes", -1)) == 1 \
		and int(metadata.get("collision_triangles", -1)) == 58 \
		and str(metadata.get("deterministic_signature", "")) == EXPECTED_SIGNATURE \
		and not bool(metadata.get("generated_new_albedo_texture", true)) \
		and not bool(metadata.get("generated_normal_or_roughness_maps", true)) \
		and str(metadata.get("technical_evidence_status", "")) == "pending_independent_bar_raiser_review"


func _visual_batches_match(instance: Node3D) -> bool:
	if _count_type(instance, MeshInstance3D) != EXPECTED_BATCH_TRIANGLES.size():
		return false
	for name: String in EXPECTED_BATCH_TRIANGLES:
		var mesh_instance := instance.get_node_or_null(name) as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null or mesh_instance.mesh.get_surface_count() != 1:
			return false
		if int(mesh_instance.mesh.surface_get_array_index_len(0) / 3) != int(EXPECTED_BATCH_TRIANGLES[name]):
			return false
		var material := mesh_instance.mesh.surface_get_material(0)
		if material == null or material.resource_path != str(EXPECTED_MATERIALS[name]):
			return false
	return true


func _source_shell_matches(instance: Node3D, wall: Dictionary) -> bool:
	var observed := {}
	for batch_name: String in ["ProtectedExactWallRuns", "MappedSSEExactWarmStuccoWallRuns"]:
		var mesh_instance := instance.get_node(batch_name) as MeshInstance3D
		for point: Vector3 in mesh_instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array:
			observed[_point_key(point)] = int(observed.get(_point_key(point), 0)) + 1
	var expected := {}
	var values := wall.vertices as Array
	for offset in range(0, values.size(), 3):
		var point := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
		expected[_point_key(point)] = int(expected.get(_point_key(point), 0)) + 1
	return observed == expected


func _roof_plan_matches(instance: Node3D, roof: Dictionary) -> bool:
	var mesh := (instance.get_node("ExactPlanShallowGableRoof") as MeshInstance3D).mesh
	var vertices := mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var indices := roof.indices as Array
	var source_values := roof.vertices as Array
	if vertices.size() != indices.size():
		return false
	for index_offset in indices.size():
		var source_offset := int(indices[index_offset]) * 3
		var source_xz := Vector2(float(source_values[source_offset]), float(source_values[source_offset + 2]))
		if Vector2(vertices[index_offset].x, vertices[index_offset].z).distance_to(source_xz) > 0.0001:
			return false
	return true


func _motifs_stay_near_hosts(instance: Node3D, wall: Dictionary) -> bool:
	var host_by_batch := {
		"OffsetEndTwoLevelBalconyVoids": [11],
		"OffsetEndBalconySlabs": [11],
		"OffsetEndSimpleMetalRails": [11],
		"QuietRegisterUpperOpaqueOpenings": [19],
		"QuietRegisterUpperPaleFrames": [19],
		"BlankEndGroundPassageShadow": [23],
		"BlankEndGroundPassageFrame": [23],
	}
	for batch_name: String in host_by_batch:
		var mesh_instance := instance.get_node_or_null(batch_name) as MeshInstance3D
		if mesh_instance == null:
			return false
		var vertices := mesh_instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
		for point: Vector3 in vertices:
			var nearest := INF
			for run_index: int in host_by_batch[batch_name] as Array:
				nearest = minf(nearest, _distance_to_run(point, wall, run_index))
			if nearest > 1.05:
				return false
	return true


func _eaves_stay_near_target_runs(instance: Node3D, wall: Dictionary) -> bool:
	var mesh_instance := instance.get_node_or_null("MappedSSEContinuousEaveChains") as MeshInstance3D
	if mesh_instance == null:
		return false
	for point: Vector3 in mesh_instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array:
		var nearest := INF
		for run_index: int in TARGET_RUNS:
			nearest = minf(nearest, _distance_to_run(point, wall, run_index))
		if nearest > 1.05:
			return false
	return true


func _collision_tree_matches(instance: Node3D) -> bool:
	var body := instance.get_node_or_null("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	if body == null or body.collision_layer != 1 or body.collision_mask != 0 or body.get_child_count() != 1:
		return false
	var shape_node := body.get_child(0) as CollisionShape3D
	if shape_node == null or not (shape_node.shape is ConcavePolygonShape3D):
		return false
	var shape := shape_node.shape as ConcavePolygonShape3D
	return shape.get_faces().size() == 174 \
		and str(body.get_meta("receiver_kind", "bad")) == "none" \
		and body.get_meta("source_keys", []) == [SOURCE_KEY] \
		and str(body.get_meta("spray_ownership", "bad")) == "none_standalone" \
		and _count_type(instance, StaticBody3D) == 1 \
		and _count_type(instance, CollisionShape3D) == 1 \
		and _count_type(instance, NavigationRegion3D) == 0 \
		and not _any_spray_group(instance)


func _mesh_uvs_complete(instance: Node3D) -> bool:
	for child: Node in instance.get_children():
		if not (child is MeshInstance3D):
			continue
		var arrays := (child as MeshInstance3D).mesh.surface_get_arrays(0)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var uvs := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
		if vertices.is_empty() or uvs.size() != vertices.size():
			return false
		for uv: Vector2 in uvs:
			if not is_finite(uv.x) or not is_finite(uv.y):
				return false
	return true


func _matcher_fails_closed(wall: Dictionary, roof: Dictionary) -> bool:
	var moved_wall := wall.duplicate(true)
	(moved_wall.vertices as Array)[0] = float((moved_wall.vertices as Array)[0]) + 0.001
	var reindexed_roof := roof.duplicate(true)
	var roof_indices := reindexed_roof.indices as Array
	var swap: Variant = roof_indices[0]
	roof_indices[0] = roof_indices[1]
	roof_indices[1] = swap
	var wrong_identity := wall.duplicate(true)
	wrong_identity["source_keys"] = ["w95934105"]
	var missing_wall := wall.duplicate(true)
	missing_wall.erase("source_keys")
	return not PROTOTYPE.matches_record_pair(moved_wall, roof) \
		and not PROTOTYPE.matches_record_pair(wall, reindexed_roof) \
		and not PROTOTYPE.matches_record_pair(wrong_identity, roof) \
		and not PROTOTYPE.matches_record_pair(missing_wall, roof)


func _material_uv_contract_matches() -> bool:
	var stucco := load("res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres") as StandardMaterial3D
	var roof := load("res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres") as StandardMaterial3D
	return stucco != null and roof != null \
		and stucco.albedo_texture != null and roof.albedo_texture != null \
		and stucco.albedo_texture.resource_path == "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png" \
		and roof.albedo_texture.resource_path == "res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg" \
		and stucco.albedo_color.is_equal_approx(Color(0.96, 0.94, 0.87, 1.0)) \
		and is_equal_approx(stucco.roughness, 0.88) and is_zero_approx(stucco.metallic) \
		and stucco.normal_texture == null and stucco.roughness_texture == null \
		and roof.normal_texture == null and roof.roughness_texture == null \
		and is_equal_approx(stucco.uv1_scale.x, 0.333333) and is_equal_approx(stucco.uv1_scale.y, 0.333333) \
		and is_equal_approx(roof.uv1_scale.x, 0.2) and is_equal_approx(roof.uv1_scale.y, 0.2)


func _package_boundary_is_clean() -> bool:
	for path: String in LIVE_ROUTE_FILES:
		if not FileAccess.file_exists(path):
			return false
		var source := FileAccess.get_file_as_string(path)
		if source.contains("D21439ChinookStandaloneHeroPrototype") or source.contains("d2_1439_chinook_standalone_hero_prototype"):
			return false
	return true


func _distance_to_run(point: Vector3, wall: Dictionary, run_index: int) -> float:
	var values := wall.vertices as Array
	var offset := run_index * 12
	return _point_segment_distance(
		Vector2(point.x, point.z),
		Vector2(float(values[offset]), float(values[offset + 2])),
		Vector2(float(values[offset + 3]), float(values[offset + 5]))
	)


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _batch_triangles_match(actual: Dictionary) -> bool:
	if actual.size() != EXPECTED_BATCH_TRIANGLES.size():
		return false
	for key: String in EXPECTED_BATCH_TRIANGLES:
		if int(actual.get(key, -1)) != int(EXPECTED_BATCH_TRIANGLES[key]):
			return false
	return true


func _point_segment_distance(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	if segment.length_squared() <= 0.0000001:
		return point.distance_to(start)
	return point.distance_to(start + segment * clampf((point - start).dot(segment) / segment.length_squared(), 0.0, 1.0))


func _point_key(point: Vector3) -> String:
	return "%.4f|%.4f|%.4f" % [point.x, point.y, point.z]


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 0
	for child: Node in node.find_children("*", "", true, false):
		if is_instance_of(child, node_type):
			count += 1
	return count


func _any_spray_group(node: Node) -> bool:
	for child: Node in node.find_children("*", "", true, false):
		if child.is_in_group("spray_receiver") or child.is_in_group("spray_receiver_wall"):
			return true
	return false


func _require(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _finish() -> void:
	if _failures.is_empty():
		print("PASS: 1439 Chinook exact-footprint standalone hero, target-specific SSE hierarchy, Site-12 kit, meter UV, collision, source, and package-boundary contracts")
		quit(0)
	else:
		push_error("FAIL: %s" % [_failures])
		quit(1)
