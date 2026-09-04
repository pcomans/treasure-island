extends SceneTree

const MASSING := preload("res://game/scripts/world/massing/building_3_600_california_massing.gd")
const TARGET_SOURCE_KEY := "w34313540"
const TARGET_WALL_KEY := "building:w34313540:wall"
const TARGET_ROOF_KEY := "building:w34313540:roof"
const TARGET_CHUNK_PATH := "res://generated/world/chunks/x_1__z_1.json"
const CONFIG_PATH := "res://game/resources/facades/building_3_hero_massing.json"
const LAYOUT_PATH := "res://game/resources/facades/building_3_600_california_ene_layout.json"
const EXPECTED_CHUNK_SHA256 := "784d89c2ac1392f5ff329b8c6c437ad9050363e9f00b4f993dd9d378851f1758"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_CONFIG_SHA256 := "2a7eacee21c88046deb587e53224b2c6c189172922265ed5a63711789ee37553"
const EXPECTED_LAYOUT_SHA256 := "a491a3c7916191b9ca5f6adacc6d1f2289c0103f5079516b102b94e3993dae0c"
const EXPECTED_WALL_TRIANGLES := 236
const EXPECTED_ROOF_TRIANGLES := 675
const EXPECTED_TOPOLOGY_DELTA := 766
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(TARGET_CHUNK_PATH) == EXPECTED_CHUNK_SHA256, "Building 3 frozen chunk drifted.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated manifest drifted.") \
	or not _require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256, "Building 3 hero massing config drifted.") \
	or not _require(FileAccess.get_sha256(LAYOUT_PATH) == EXPECTED_LAYOUT_SHA256, "Building 3 ENE facade layout drifted."):
		_finish()
		return
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(TARGET_CHUNK_PATH)) as Dictionary
	var wall := _record_for_key(chunk.records, TARGET_WALL_KEY)
	var roof := _record_for_key(chunk.records, TARGET_ROOF_KEY)
	if not _require(not wall.is_empty() and not roof.is_empty(), "Could not resolve both exact Building 3 records."):
		_finish()
		return
	var builder := WorldChunkBuilder.new()
	var wall_first := builder._build_record(wall, false)
	var wall_second := builder._build_record(wall, false)
	var roof_first := builder._build_record(roof, false)
	var roof_second := builder._build_record(roof, false)
	var results := [wall_first, wall_second, roof_first, roof_second]
	if not _require(_all_ok(results), "Building 3 wall/roof construction failed."):
		_free_results(results)
		_finish()
		return
	var wall_node := wall_first.node as Node3D
	var wall_repeat := wall_second.node as Node3D
	var roof_node := roof_first.node as Node3D
	var roof_repeat := roof_second.node as Node3D
	var contract := wall_node.get_meta("massing_contract", {}) as Dictionary
	if not _require(_truth_contract_matches(contract), "Building 3 identity or production-inference boundary drifted.") \
	or not _require(_node_contract_matches(wall_node, true), "Building 3 wall override/collision contract drifted.") \
	or not _require(_node_contract_matches(roof_node, false), "Building 3 roof override/collision contract drifted.") \
	or not _require(_deterministic_pair(wall_node, wall_repeat), "Building 3 wall geometry is nondeterministic.") \
	or not _require(_deterministic_pair(roof_node, roof_repeat), "Building 3 roof geometry is nondeterministic.") \
	or not _require(_wall_horizontal_and_foundation_match(wall, wall_node, contract), "Building 3 wall did not preserve exact source X/Z and terrain-following foundation.") \
	or not _require(_roof_horizontal_footprint_matches(roof, roof_node), "Building 3 roof subdivisions escaped or shrank the exact source footprint.") \
	or not _require(_profile_is_legible(contract, wall_node, roof_node), "Building 3 crown/shoulder/pylon profile is not geometrically legible.") \
	or not _require(_facade_matches(wall_node, contract), "Building 3 ENE facade was not coherently remapped to the hero wall."):
		_free_results(results)
		_finish()
		return
	root.add_child(wall_node)
	root.add_child(roof_node)
	await physics_frame
	await physics_frame
	if not _require(_spray_ray_hits_wall(wall_node), "Building 3 door ray did not hit the replacement spray wall.") \
	or not _require(_roof_landing_ray_hits_roof(roof_node), "Building 3 crown ray did not hit the replacement roof landing collider."):
		root.remove_child(wall_node)
		root.remove_child(roof_node)
		_free_results(results)
		_finish()
		return
	root.remove_child(wall_node)
	root.remove_child(roof_node)
	print("BUILDING_3_SIGNATURES: profile=%s wall=%s roof=%s facade=%s" % [str(contract.profile_signature), str(wall_node.get_meta("massing_signature", "")), str(roof_node.get_meta("massing_signature", "")), str((wall_node.get_node("Building3600CaliforniaFacade") as Node3D).get_meta("deterministic_signature", ""))])
	_free_results(results)
	print("PASS: Building 3 exact footprint/foundation now carries congruent visible+collision arched massing, four tapered corner shoulders, 236 wall + 675 roof triangles (runtime delta +766), wall-only spray, roof landing, corrected NRHP 08000083 truth boundary, and a deterministic 18-segment ENE facade pending independent review")
	_finish()


func _truth_contract_matches(contract: Dictionary) -> bool:
	return str(contract.get("schema_version", "")) == "ti.building-3-massing-runtime/1" \
		and str(contract.get("target_source_key", "")) == TARGET_SOURCE_KEY \
		and str(contract.get("corrected_nrhp_id", "")) == "08000083" \
		and str(contract.get("frozen_osm_nrhp_ref", "")) == "08000081" \
		and str(contract.get("frozen_osm_nrhp_ref_role", "")) == "provenance_only_incorrect_for_building_3" \
		and is_equal_approx(float(contract.get("eave_y_m", 0.0)), 21.278) \
		and is_equal_approx(float(contract.get("crown_y_m", 0.0)), 27.862) \
		and is_equal_approx(float(contract.get("pylon_y_m", 0.0)), 24.179) \
		and int(contract.get("runtime_wall_triangles", 0)) == EXPECTED_WALL_TRIANGLES \
		and int(contract.get("runtime_roof_triangles", 0)) == EXPECTED_ROOF_TRIANGLES \
		and int(contract.get("runtime_wall_triangles", 0)) + int(contract.get("runtime_roof_triangles", 0)) - 145 == EXPECTED_TOPOLOGY_DELTA \
		and bool(contract.get("horizontal_source_footprint_preserved", false)) \
		and bool(contract.get("production_inference_reversible", false)) \
		and bool(contract.get("exterior_only", false)) \
		and not bool(contract.get("interior_modeled", true)) \
		and not bool(contract.get("as_built_fidelity_claimed", true)) \
		and str(contract.get("visual_review_status", "")) == "pending_independent_original_detail_review" \
		and str(contract.get("profile_signature", "")) != ""


func _node_contract_matches(node: Node3D, is_wall: bool) -> bool:
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var collision_shape := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	if mesh_instance == null or body == null or collision_shape == null:
		return false
	var mesh := mesh_instance.mesh as ArrayMesh
	var shape := collision_shape.shape as ConcavePolygonShape3D
	var expected_triangles := EXPECTED_WALL_TRIANGLES if is_wall else EXPECTED_ROOF_TRIANGLES
	var expected_layer := PHYSICS_WORLD_SOLID | (PHYSICS_SPRAY_SURFACE if is_wall else 0)
	var matches := bool(node.get_meta("building_3_massing_override", false)) \
		and bool(node.get_meta("runtime_supersedes_generated_placeholder", false)) \
		and bool(node.get_meta("horizontal_source_geometry_preserved", false)) \
		and str(node.get_meta("corrected_nrhp_id", "")) == "08000083" \
		and str(node.get_meta("frozen_osm_nrhp_ref_role", "")) == "provenance_only_incorrect_for_building_3" \
		and (mesh.get_faces() as PackedVector3Array).size() == expected_triangles * 3 \
		and shape.get_faces().size() == expected_triangles * 3 \
		and _same_face_vertex_multiset(mesh.get_faces(), shape.get_faces()) \
		and body.collision_layer == expected_layer and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") == is_wall \
		and (node.find_children("*", "CollisionObject3D", true, false) as Array).size() == 1 \
		and str(node.get_meta("massing_signature", "")) == str(body.get_meta("massing_signature", "")) \
		and str(node.get_meta("massing_signature", "")) != ""
	if not matches:
		print("Building 3 node diagnostic: wall=", is_wall, " mesh_faces=", mesh.get_faces().size(), " shape_faces=", shape.get_faces().size(), " congruent=", _same_face_vertex_multiset(mesh.get_faces(), shape.get_faces()), " mesh_first=", mesh.get_faces().slice(0, 3), " shape_first=", shape.get_faces().slice(0, 3), " layer=", body.collision_layer, " group=", body.is_in_group("spray_receiver_wall"), " collision_objects=", (node.find_children("*", "CollisionObject3D", true, false) as Array).size(), " root_sig=", node.get_meta("massing_signature", ""), " body_sig=", body.get_meta("massing_signature", ""))
	return matches


func _same_face_vertex_multiset(first: PackedVector3Array, second: PackedVector3Array) -> bool:
	if first.size() != second.size():
		return false
	for index in first.size():
		if not first[index].is_equal_approx(second[index]):
			return false
	return true


func _deterministic_pair(first: Node3D, second: Node3D) -> bool:
	var first_mesh := (first.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	var second_mesh := (second.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	return str(first.get_meta("massing_signature", "")) == str(second.get_meta("massing_signature", "")) \
		and first_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] == second_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] \
		and first_mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX] == second_mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX]


func _wall_horizontal_and_foundation_match(record: Dictionary, node: Node3D, contract: Dictionary) -> bool:
	var mesh := ((node.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh)
	var runtime_vertices := mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var raw: Array = record.vertices
	var subdivisions := int(contract.wall_subdivisions)
	if runtime_vertices.size() != 59 * subdivisions * 4:
		return false
	for run_index in 59:
		var offset := run_index * 12
		var source_start := Vector3(float(raw[offset]), float(raw[offset + 1]), float(raw[offset + 2]))
		var source_end := Vector3(float(raw[offset + 3]), float(raw[offset + 4]), float(raw[offset + 5]))
		for subdivision in subdivisions:
			var runtime_offset := (run_index * subdivisions + subdivision) * 4
			var expected_start := source_start.lerp(source_end, float(subdivision) / float(subdivisions))
			var expected_end := source_start.lerp(source_end, float(subdivision + 1) / float(subdivisions))
			var runtime_start := runtime_vertices[runtime_offset]
			var runtime_end := runtime_vertices[runtime_offset + 1]
			if not runtime_start.is_equal_approx(expected_start) or not runtime_end.is_equal_approx(expected_end):
				return false
			if not is_equal_approx(runtime_vertices[runtime_offset + 3].x, expected_start.x) \
			or not is_equal_approx(runtime_vertices[runtime_offset + 3].z, expected_start.z) \
			or not is_equal_approx(runtime_vertices[runtime_offset + 2].x, expected_end.x) \
			or not is_equal_approx(runtime_vertices[runtime_offset + 2].z, expected_end.z):
				return false
	return true


func _roof_horizontal_footprint_matches(record: Dictionary, node: Node3D) -> bool:
	var mesh := ((node.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh)
	var runtime_vertices := mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var raw_vertices: Array = record.vertices
	var raw_indices: Array = record.indices
	var source_min := Vector2(INF, INF)
	var source_max := Vector2(-INF, -INF)
	for offset in range(0, raw_vertices.size(), 3):
		var source_point := Vector2(float(raw_vertices[offset]), float(raw_vertices[offset + 2]))
		source_min = source_min.min(source_point)
		source_max = source_max.max(source_point)
		var found := false
		for runtime: Vector3 in runtime_vertices:
			if Vector2(runtime.x, runtime.z).is_equal_approx(source_point):
				found = true
				break
		if not found:
			return false
	var runtime_min := Vector2(INF, INF)
	var runtime_max := Vector2(-INF, -INF)
	for runtime: Vector3 in runtime_vertices:
		var point := Vector2(runtime.x, runtime.z)
		runtime_min = runtime_min.min(point)
		runtime_max = runtime_max.max(point)
		if not _inside_any_source_triangle(point, raw_vertices, raw_indices):
			return false
	return runtime_min.is_equal_approx(source_min) and runtime_max.is_equal_approx(source_max)


func _inside_any_source_triangle(point: Vector2, vertices: Array, indices: Array) -> bool:
	for offset in range(0, indices.size(), 3):
		var corners: Array[Vector2] = []
		for corner in 3:
			var vertex_offset := int(indices[offset + corner]) * 3
			corners.append(Vector2(float(vertices[vertex_offset]), float(vertices[vertex_offset + 2])))
		if Geometry2D.is_point_in_polygon(point, PackedVector2Array(corners)) or _on_triangle_edge(point, corners):
			return true
	return false


func _on_triangle_edge(point: Vector2, corners: Array[Vector2]) -> bool:
	for edge in 3:
		var first := corners[edge]
		var second := corners[(edge + 1) % 3]
		var closest := Geometry2D.get_closest_point_to_segment(point, first, second)
		if closest.distance_to(point) <= 0.001:
			return true
	return false


func _profile_is_legible(contract: Dictionary, wall_node: Node3D, roof_node: Node3D) -> bool:
	var width_start := contract.width_start_xz as Vector2
	var width_end := contract.width_end_xz as Vector2
	var midpoint := width_start.lerp(width_end, 0.5)
	var crown := MASSING.top_y_for_xz(midpoint, contract)
	var pylon_heights := PackedFloat32Array([
		MASSING.top_y_for_xz(Vector2(365.909, 472.390), contract),
		MASSING.top_y_for_xz(Vector2(409.171, 554.288), contract),
		MASSING.top_y_for_xz(Vector2(486.955, 408.860), contract),
		MASSING.top_y_for_xz(Vector2(528.784, 488.910), contract),
	])
	var pylon_min := INF
	var pylon_max := -INF
	for height: float in pylon_heights:
		pylon_min = minf(pylon_min, height)
		pylon_max = maxf(pylon_max, height)
	var roof_mesh := ((roof_node.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh)
	var roof_vertices := roof_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var wall_mesh := ((wall_node.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh)
	var wall_vertices := wall_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var unique_heights := {}
	var observed_peak := -INF
	for vertex: Vector3 in roof_vertices:
		unique_heights[snappedf(vertex.y, 0.01)] = true
		observed_peak = maxf(observed_peak, vertex.y)
	var wall_peak := -INF
	for vertex: Vector3 in wall_vertices:
		wall_peak = maxf(wall_peak, vertex.y)
	var matches := pylon_min >= 24.0 and pylon_max <= 24.2 \
		and crown >= 27.861 and crown <= 27.863 \
		and crown - pylon_max > 3.5 \
		and unique_heights.size() >= 25 \
		and observed_peak >= 27.80 \
		and wall_peak >= 27.70 \
		and observed_peak > float(contract.source_flat_top_y_m) + 4.0
	if not matches:
		print("Building 3 profile diagnostic: pylons=", pylon_heights, " crown=", crown, " unique=", unique_heights.size(), " roof_peak=", observed_peak, " wall_peak=", wall_peak)
	return matches


func _facade_matches(wall_node: Node3D, contract: Dictionary) -> bool:
	var facade := wall_node.get_node_or_null("Building3600CaliforniaFacade") as Building3600CaliforniaFacade
	if facade == null:
		return false
	var fields := facade.get_node_or_null("FacadeFields_Runs_27_35") as MeshInstance3D
	var shadow_batch := facade.get_node_or_null("RenderBatches/Batch_shadow_recess") as MultiMeshInstance3D
	return fields != null \
		and shadow_batch != null and shadow_batch.multimesh.instance_count == 1 \
		and bool(facade.get_meta("render_only", false)) \
		and bool(facade.get_meta("runtime_massing_bound", false)) \
		and bool(facade.get_meta("production_inference_reversible", false)) \
		and str(facade.get_meta("runtime_massing_signature", "")) == str(contract.profile_signature) \
		and str(facade.get_meta("spray_ray_owner", "")) == "runtime_massing_receiver" \
		and int(facade.get_meta("field_segment_count", 0)) == 18 \
		and int(facade.get_meta("reference_pylon_relief_count", 0)) == 2 \
		and str(facade.get_meta("upper_band_shadow_recess", "")) == "reversible_neutral_depth_read_production_inference" \
		and facade.get_meta("module_counts", {}) == {"B3-HANGAR-DOOR": 1, "B3-BAND": 1} \
		and ((fields.mesh as ArrayMesh).get_faces() as PackedVector3Array).size() == 108 \
		and facade.find_children("*", "CollisionObject3D", true, false).is_empty()


func _spray_ray_hits_wall(wall_node: Node3D) -> bool:
	var start := Vector3(528.784, 9.728, 488.910)
	var end := Vector3(486.955, 9.728, 408.860)
	var point := start + (end - start).normalized() * 45.160
	var normal := Vector3(0.886, 0.0, -0.463).normalized()
	var query := PhysicsRayQueryParameters3D.create(point + normal * 3.0, point - normal * 3.0, PHYSICS_SPRAY_SURFACE)
	var hit := wall_node.get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == wall_node.get_node("Collision") \
		and str((hit.collider as CollisionObject3D).get_meta("derived_object_key", "")) == TARGET_WALL_KEY


func _roof_landing_ray_hits_roof(roof_node: Node3D) -> bool:
	var contract := roof_node.get_meta("massing_contract", {}) as Dictionary
	var center := (contract.width_start_xz as Vector2).lerp(contract.width_end_xz as Vector2, 0.5)
	var query := PhysicsRayQueryParameters3D.create(Vector3(center.x, 40.0, center.y), Vector3(center.x, 15.0, center.y), PHYSICS_WORLD_SOLID)
	var hit := roof_node.get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == roof_node.get_node("Collision") \
		and float((hit as Dictionary).position.y) > 27.5


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _all_ok(results: Array) -> bool:
	for value: Variant in results:
		if not bool((value as Dictionary).get("ok", false)):
			return false
	return true


func _free_results(results: Array) -> void:
	for value: Variant in results:
		var node := (value as Dictionary).get("node", null) as Node
		if node != null and not node.is_inside_tree():
			node.free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
