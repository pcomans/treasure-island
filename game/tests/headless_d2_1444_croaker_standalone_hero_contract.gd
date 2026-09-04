extends SceneTree

const PROTOTYPE := preload("res://game/scripts/world/facades/d2_1444_croaker_standalone_hero_prototype.gd")
const CONFIG_PATH := "res://game/resources/facades/d2_1444_croaker_standalone_hero_prototype.json"
const SCENE_PATH := "res://game/scenes/world/facades/site_12_housing/d2_1444_croaker_standalone_hero_prototype.tscn"
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_-1.json"
const PACKET_PATH := "res://discovery/facades/d2_reference_packets/w95934117_1444_croaker_court.md"
const WALL_KEY := "building:w95934117:wall"
const ROOF_KEY := "building:w95934117:roof"
const SOURCE_KEY := "w95934117"
const TARGET_RUNS := [8, 9, 11, 12, 15, 16, 17]
const BLANK_END_RUNS := [8, 9]
const SPARSE_OPENING_RUNS := [11, 16]
const BALCONY_RUNS := [17]
const QUIET_MAPPED_RUNS := [12, 15]
const PROTECTED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 10, 13, 14, 18, 19, 20, 21]
const EXPECTED_CHUNK_SHA256 := "6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2"
const EXPECTED_PACKET_SHA256 := "51c70c213b055572447c8a7aebaf3a3da2b8e759d4bcd48aa65949ec0530fa90"
const EXPECTED_SIGNATURE := "8df0202796d56c019b6b3ddb72916808b72316d2d0edee0ba7425b77efa2b127"
const EXPECTED_BATCH_TRIANGLES := {
	"ProtectedExactWallRuns": 30,
	"MappedWSWExactOchreStuccoWallRuns": 14,
	"ExactPlanShallowGableRoof": 10,
	"MappedWSWBroadEaves": 84,
	"BlankEndUndercroftOpaqueShadow": 24,
	"BlankEndUndercroftOchreFrame": 60,
	"SparseReturnOpaqueOpenings": 72,
	"SparseReturnOchreOpeningFrames": 360,
	"FarEndRecessedTwoLevelOpaqueVoids": 24,
	"FarEndBalconyOchreSlabs": 24,
	"FarEndSimpleMetalRails": 96,
}
const EXPECTED_MATERIALS := {
	"ProtectedExactWallRuns": "res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
	"MappedWSWExactOchreStuccoWallRuns": "res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres",
	"ExactPlanShallowGableRoof": "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
	"MappedWSWBroadEaves": "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
	"BlankEndUndercroftOpaqueShadow": "res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
	"BlankEndUndercroftOchreFrame": "res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres",
	"SparseReturnOpaqueOpenings": "res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
	"SparseReturnOchreOpeningFrames": "res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres",
	"FarEndRecessedTwoLevelOpaqueVoids": "res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
	"FarEndBalconyOchreSlabs": "res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres",
	"FarEndSimpleMetalRails": "res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
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
		print("D2_1444_TOPOLOGY ", JSON.stringify({"signature": metadata.deterministic_signature, "batches": metadata.visual_batch_triangles, "visual_triangles": metadata.visual_triangles, "collision_triangles": metadata.collision_triangles, "rail_pickets": metadata.rail_picket_count}))
		_require(_prototype_matches(instance, metadata, wall, roof), "Built prototype contract drifted.")
		_require(_visual_batches_match(instance), "Visual batch/material contract drifted.")
		_require(_source_shell_matches(instance, wall), "Exact source wall shell was not preserved.")
		_require(_roof_plan_matches(instance, roof), "Exact source roof XZ triangles were not preserved.")
		_require(_modules_stay_near_target_runs(instance, wall), "Facade modules escaped the seven mapped WSW runs.")
		_require(_collision_tree_matches(instance), "Collision/ownership topology drifted.")
		instance.queue_free()
		await process_frame
	_require(_matcher_fails_closed(wall, roof), "Matcher did not fail closed under geometry/topology mutation.")
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
	if str(config.get("schema_version", "")) != "ti.d2-1444-croaker-standalone-hero-prototype/1":
		return false
	var target := config.target as Dictionary
	var truth := config.truth_boundary as Dictionary
	var mapped := config.mapped_public_region as Dictionary
	var protected := config.protected_region as Dictionary
	var collision := config.collision_contract as Dictionary
	var kit := config.site_12_kit_contract as Dictionary
	var material := config.material_scope as Dictionary
	var confusion := config.confusion_set as Array
	return str(target.source_key) == SOURCE_KEY \
		and str(target.wall_object_key) == WALL_KEY \
		and str(target.roof_object_key) == ROOF_KEY \
		and str(target.source_geometry_sha256) == PROTOTYPE.SOURCE_GEOMETRY_SHA256 \
		and float(target.source_height_m) == 6.0 \
		and float(target.source_base_y_m) == 2.521 \
		and float(target.source_wall_top_y_m) == 8.521 \
		and bool(truth.prototype_only) and not bool(truth.runtime_attachment) \
		and not bool(truth.recognition_accepted) and not bool(truth.believability_accepted) \
		and not bool(truth.as_built_claim) and not bool(truth.interior_modeled) \
		and not bool(truth.reference_pixels_stored_or_copied) \
		and not bool(truth.horizontal_source_footprint_changed) \
		and not bool(truth.source_wall_height_changed) \
		and _int_array(mapped.ordered_run_indices as Array) == TARGET_RUNS \
		and _int_array(protected.run_indices as Array) == PROTECTED_RUNS \
		and str(collision.spray_ownership).begins_with("none in standalone") \
		and str(kit.kit_id) == "site-12-housing-kit-v1" \
		and str(kit.entity_specific_schedule_location).contains("d2_1444_croaker") \
		and str((material.target_stucco as Dictionary).application).contains("undercroft frame/piers") \
		and str((material.roof_surrogate as Dictionary).application).contains("eave") \
		and _confusion_matches(confusion)


func _confusion_matches(values: Array) -> bool:
	if values.size() != 3:
		return false
	var expected := {
		"1431 Halibut Court": "w95934135",
		"1436 Chinook Court": "w95934137",
		"1449 Croaker Court": "w95934120",
	}
	for value: Variant in values:
		var item := value as Dictionary
		if str(expected.get(str(item.get("name", "")), "")) != str(item.get("source_key", "")):
			return false
	return true


func _prototype_matches(instance: Node3D, metadata: Dictionary, wall: Dictionary, roof: Dictionary) -> bool:
	return str(metadata.model_id) == "d2-1444-croaker-standalone-hero-prototype-v1" \
		and str(metadata.kit_id) == "site-12-housing-kit-v1" \
		and str(metadata.wall_record_sha256) == PROTOTYPE.record_signature(wall) \
		and str(metadata.roof_record_sha256) == PROTOTYPE.record_signature(roof) \
		and bool(metadata.prototype_only) and not bool(metadata.runtime_attachment) \
		and not bool(metadata.recognition_accepted) and not bool(metadata.believability_accepted) \
		and not bool(metadata.as_built_claim) and not bool(metadata.interior_modeled) \
		and not bool(metadata.horizontal_source_footprint_changed) \
		and not bool(metadata.source_wall_height_changed) \
		and _int_array(metadata.mapped_public_run_indices as Array) == TARGET_RUNS \
		and _int_array(metadata.blank_end_run_indices as Array) == BLANK_END_RUNS \
		and _int_array(metadata.sparse_opening_run_indices as Array) == SPARSE_OPENING_RUNS \
		and _int_array(metadata.balcony_run_indices as Array) == BALCONY_RUNS \
		and _int_array(metadata.quiet_mapped_run_indices as Array) == QUIET_MAPPED_RUNS \
		and _int_array(metadata.protected_run_indices as Array) == PROTECTED_RUNS \
		and not bool(metadata.protected_runs_have_facade_modules) \
		and int(metadata.undercroft_void_count) == 2 \
		and int(metadata.undercroft_pier_count) == 3 \
		and int(metadata.sparse_opening_count) == 6 \
		and int(metadata.balcony_void_count) == 2 \
		and int(metadata.rail_picket_count) == 4 \
		and int(metadata.mapped_eave_count) == 7 \
		and int(metadata.mesh_instances) == 11 and int(metadata.surfaces) == 11 \
		and int(metadata.visual_triangles) == 798 \
		and _batch_triangles_match(metadata.visual_batch_triangles as Dictionary) \
		and int(metadata.static_bodies) == 1 and int(metadata.shapes) == 1 \
		and int(metadata.collision_triangles) == 54 \
		and str(metadata.deterministic_signature) == EXPECTED_SIGNATURE \
		and not bool(metadata.generated_new_albedo_texture) \
		and not bool(metadata.generated_normal_or_roughness_maps) \
		and str(metadata.technical_evidence_status) == "pending_independent_bar_raiser_review"


func _visual_batches_match(instance: Node3D) -> bool:
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
	for batch_name: String in ["ProtectedExactWallRuns", "MappedWSWExactOchreStuccoWallRuns"]:
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


func _modules_stay_near_target_runs(instance: Node3D, wall: Dictionary) -> bool:
	var names := [
		"MappedWSWBroadEaves",
		"BlankEndUndercroftOpaqueShadow",
		"BlankEndUndercroftOchreFrame",
		"SparseReturnOpaqueOpenings",
		"SparseReturnOchreOpeningFrames",
		"FarEndRecessedTwoLevelOpaqueVoids",
		"FarEndBalconyOchreSlabs",
		"FarEndSimpleMetalRails",
	]
	for batch_name: String in names:
		var vertices := (instance.get_node(batch_name) as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
		for point: Vector3 in vertices:
			var nearest := INF
			for run_index: int in TARGET_RUNS:
				var offset := run_index * 12
				var values := wall.vertices as Array
				nearest = minf(nearest, _point_segment_distance(Vector2(point.x, point.z), Vector2(float(values[offset]), float(values[offset + 2])), Vector2(float(values[offset + 3]), float(values[offset + 5]))))
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
	return shape.get_faces().size() == 162 \
		and str(body.get_meta("receiver_kind", "bad")) == "none" \
		and body.get_meta("source_keys", []) == [SOURCE_KEY] \
		and str(body.get_meta("spray_ownership", "bad")) == "none_standalone" \
		and _count_type(instance, StaticBody3D) == 1 \
		and _count_type(instance, CollisionShape3D) == 1 \
		and _count_type(instance, NavigationRegion3D) == 0 \
		and not _any_spray_group(instance)


func _matcher_fails_closed(wall: Dictionary, roof: Dictionary) -> bool:
	var moved_wall := wall.duplicate(true)
	(moved_wall.vertices as Array)[0] = float((moved_wall.vertices as Array)[0]) + 0.001
	var reindexed_roof := roof.duplicate(true)
	var roof_indices := reindexed_roof.indices as Array
	var swap: Variant = roof_indices[0]
	roof_indices[0] = roof_indices[1]
	roof_indices[1] = swap
	var missing_wall := wall.duplicate(true)
	missing_wall.erase("source_keys")
	return not PROTOTYPE.matches_record_pair(moved_wall, roof) \
		and not PROTOTYPE.matches_record_pair(wall, reindexed_roof) \
		and not PROTOTYPE.matches_record_pair(missing_wall, roof)


func _material_uv_contract_matches() -> bool:
	var stucco := load("res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres") as StandardMaterial3D
	var roof := load("res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres") as StandardMaterial3D
	return stucco != null and roof != null \
		and stucco.albedo_texture != null and roof.albedo_texture != null \
		and stucco.albedo_texture.resource_path == "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png" \
		and roof.albedo_texture.resource_path == "res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg" \
		and stucco.albedo_color.is_equal_approx(Color(0.78, 0.61, 0.42, 1.0)) \
		and stucco.normal_texture == null and stucco.roughness_texture == null \
		and roof.normal_texture == null and roof.roughness_texture == null \
		and is_equal_approx(stucco.uv1_scale.x, 0.333333) and is_equal_approx(stucco.uv1_scale.y, 0.333333) \
		and is_equal_approx(roof.uv1_scale.x, 0.2) and is_equal_approx(roof.uv1_scale.y, 0.2)


func _package_boundary_is_clean() -> bool:
	for path: String in LIVE_ROUTE_FILES:
		if not FileAccess.file_exists(path):
			return false
		var source := FileAccess.get_file_as_string(path)
		if source.contains("D21444CroakerStandaloneHeroPrototype") or source.contains("d2_1444_croaker_standalone_hero_prototype"):
			return false
	return true


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


func _count_type(node: Node, type: Variant) -> int:
	var count := 0
	for child: Node in node.find_children("*", "", true, false):
		if is_instance_of(child, type):
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
		print("PASS: 1444 Croaker exact-footprint standalone hero, target-specific WSW hierarchy, Site-12 kit, meter UV, collision, source, and package-boundary contracts")
		quit(0)
	else:
		push_error("FAIL: %s" % _failures)
		quit(1)
