extends SceneTree

const TARGET_SOURCE_KEY := "w34313540"
const TARGET_WALL_KEY := "building:w34313540:wall"
const TARGET_ROOF_KEY := "building:w34313540:roof"
const TARGET_CHUNK_PATH := "res://generated/world/chunks/x_1__z_1.json"
const HAWKINS_CHUNK_PATH := "res://generated/world/chunks/x_-1__z_1.json"
const LAYOUT_PATH := "res://game/resources/facades/building_3_600_california_ene_layout.json"
const EXPECTED_CHUNK_SHA256 := "784d89c2ac1392f5ff329b8c6c437ad9050363e9f00b4f993dd9d378851f1758"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_LAYOUT_SHA256 := "a491a3c7916191b9ca5f6adacc6d1f2289c0103f5079516b102b94e3993dae0c"
const EXPECTED_HAWKINS_LAYOUT_SHA256 := "4de2239af2e18fe4121930d51dee15e081d2f81a40393da2f1f29c69464761d9"
const EXPECTED_HAWKINS_SIGNATURE := "d311c103c9273b94fc982588f46bae6ab67ba6be54b0d0a111dd305e39c22219"
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_BUILDING_WALL := 1 << 1

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(TARGET_CHUNK_PATH) == EXPECTED_CHUNK_SHA256, "Building 3 serialized chunk drifted.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated manifest drifted.") \
	or not _require(FileAccess.get_sha256(LAYOUT_PATH) == EXPECTED_LAYOUT_SHA256, "Building 3 layout drifted.") \
	or not _require(FileAccess.get_sha256("res://game/resources/facades/hawkins_77_bruton_layout.json") == EXPECTED_HAWKINS_LAYOUT_SHA256, "Accepted Hawkins layout changed."):
		_finish()
		return
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(TARGET_CHUNK_PATH)) as Dictionary
	var hawkins_chunk := JSON.parse_string(FileAccess.get_file_as_string(HAWKINS_CHUNK_PATH)) as Dictionary
	var layout := JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH)) as Dictionary
	var wall := _record_for_key(chunk.records, TARGET_WALL_KEY)
	var roof := _record_for_key(chunk.records, TARGET_ROOF_KEY)
	var hawkins_wall := _record_for_key(hawkins_chunk.records, "building:w1249412093:wall")
	if not _require(_layout_matches(layout), "Building 3 exact run/module layout contract drifted.") \
	or not _require(_materials_match(), "Building 3 materials are not opaque scalar project-owned dielectric fields.") \
	or not _require(not wall.is_empty() and not roof.is_empty() and not hawkins_wall.is_empty(), "Could not resolve target/roof/Hawkins spillover-control records."):
		_finish()
		return
	var builder := WorldChunkBuilder.new()
	var first_result := builder._build_record(wall, false)
	var second_result := builder._build_record(wall, false)
	var roof_result := builder._build_record(roof, false)
	var hawkins_result := builder._build_record(hawkins_wall, false)
	if not _require(bool(first_result.ok) and bool(second_result.ok) and bool(roof_result.ok) and bool(hawkins_result.ok), "Building 3 deterministic construction or controls failed."):
		_free_results([first_result, second_result, roof_result, hawkins_result])
		_finish()
		return
	var first := first_result.node as Node3D
	var second := second_result.node as Node3D
	var roof_node := roof_result.node as Node3D
	var hawkins := hawkins_result.node as Node3D
	var facade := first.get_node_or_null("Building3600CaliforniaFacade") as Building3600CaliforniaFacade
	var second_facade := second.get_node_or_null("Building3600CaliforniaFacade") as Building3600CaliforniaFacade
	var hawkins_facade := hawkins.get_node_or_null("Hawkins77BrutonFacade") as Hawkins77BrutonFacade
	if not _require(facade != null and second_facade != null, "Exact target did not receive one Building 3 facade.") \
	or not _require(roof_node.get_node_or_null("Building3600CaliforniaFacade") == null and hawkins.get_node_or_null("Building3600CaliforniaFacade") == null, "Building 3 facade spilled to a roof or Hawkins wall.") \
	or not _require(hawkins_facade != null and str(hawkins_facade.get_meta("deterministic_signature", "")) == EXPECTED_HAWKINS_SIGNATURE, "Accepted Hawkins runtime result changed.") \
	or not _require(str(facade.get_meta("deterministic_signature", "")) == str(second_facade.get_meta("deterministic_signature", "")), "Building 3 module/material assignment is nondeterministic.") \
	or not _require(_receiver_matches(first), "Building 3 arched wall/foundation/collision/spray receiver drifted.") \
	or not _require(_roof_matches(roof_node), "Building 3 arched roof/landing collision drifted.") \
	or not _require(_facade_matches(facade), "Building 3 facade scope/completeness/render-only contract drifted."):
		_free_results([first_result, second_result, roof_result, hawkins_result])
		_finish()
		return
	root.add_child(first)
	await physics_frame
	await physics_frame
	if not _require(_spray_ray_hits_wall(first), "Ray through Building 3 hangar door did not hit unchanged spray receiver."):
		root.remove_child(first)
		_free_results([first_result, second_result, roof_result, hawkins_result])
		_finish()
		return
	root.remove_child(first)
	_free_results([first_result, second_result, roof_result, hawkins_result])
	print("PASS: Building 3 exact runs 27..35 follow the arched 236-triangle wall and exact foundation/spray receiver; its congruent 675-triangle roof is landable; one complete door plus one raised band remain deterministic render-only visuals with no spillover; Hawkins remains accepted and unchanged")
	_finish()


func _layout_matches(layout: Dictionary) -> bool:
	var target := layout.target as Dictionary
	var render := layout.render_contract as Dictionary
	var side := layout.observed_ene_main as Dictionary
	if str(layout.schema_version) != "ti.building-3-facade-layout/2" \
	or str(target.source_key) != TARGET_SOURCE_KEY \
	or str(target.receiver_object_key) != TARGET_WALL_KEY \
	or int(target.wall_segments) != 59 or int(target.wall_triangles) != 118 \
	or not is_equal_approx(float(target.height_m), 20.0) \
	or not is_equal_approx(float(target.base_y_m), 3.478) \
	or not is_equal_approx(float(target.top_y_m), 23.478) \
	or _int_array(side.run_indices as Array) != [27, 28, 29, 30, 31, 32, 33, 34, 35] \
	or not is_equal_approx(float(side.length_m), 90.320) \
	or str(side.module_policy) != "observed_complete_modules" \
	or str(render.collision) != "none" or str(render.navigation) != "none" \
	or str(render.spray_ray_owner) != "runtime_massing_receiver" \
	or not is_equal_approx(float(render.maximum_relief_m), 0.52):
		return false
	var modules: Array = side.modules
	return modules.size() == 2 \
		and str((modules[0] as Dictionary).kind) == "B3-HANGAR-DOOR" \
		and str((modules[1] as Dictionary).kind) == "B3-BAND" \
		and (layout.excluded_run_indices as Array).size() == 50


func _materials_match() -> bool:
	for path: String in [
		"res://game/resources/materials/world/building_3/building_3_white_primary.tres",
		"res://game/resources/materials/world/building_3/building_3_teal_door.tres",
		"res://game/resources/materials/world/building_3/building_3_shadow_recess.tres",
	]:
		var material := load(path) as StandardMaterial3D
		if material == null or not is_zero_approx(material.metallic) \
		or material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED \
		or material.albedo_texture != null or material.normal_texture != null or material.heightmap_enabled:
			return false
	return true


func _receiver_matches(node: Node3D) -> bool:
	var mesh_instance := node.get_node("Mesh") as MeshInstance3D
	var body := node.get_node("Collision") as StaticBody3D
	var shape := (node.get_node("Collision/Shape") as CollisionShape3D).shape as ConcavePolygonShape3D
	var mesh := mesh_instance.mesh as ArrayMesh
	var vertices := mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var lowest := INF
	var highest := -INF
	for vertex: Vector3 in vertices:
		lowest = minf(lowest, vertex.y)
		highest = maxf(highest, vertex.y)
	return vertices.size() == 472 and mesh.get_faces().size() == 708 and shape.get_faces().size() == 708 \
		and is_equal_approx(lowest, 2.806) and highest >= 27.86 and highest <= 27.863 \
		and body.collision_layer == (1 | PHYSICS_SPRAY_SURFACE) and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") and body.get_meta("source_keys", []) == [TARGET_SOURCE_KEY] \
		and bool(node.get_meta("building_3_massing_override", false)) \
		and bool(node.get_meta("runtime_supersedes_generated_placeholder", false)) \
		and (node.find_children("*", "CollisionObject3D", true, false) as Array).size() == 1


func _roof_matches(node: Node3D) -> bool:
	var mesh_instance := node.get_node("Mesh") as MeshInstance3D
	var body := node.get_node("Collision") as StaticBody3D
	var shape := (node.get_node("Collision/Shape") as CollisionShape3D).shape as ConcavePolygonShape3D
	var mesh := mesh_instance.mesh as ArrayMesh
	var vertices := mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var highest := -INF
	for vertex: Vector3 in vertices:
		highest = maxf(highest, vertex.y)
	return vertices.size() == 2025 and mesh.get_faces().size() == 2025 and shape.get_faces().size() == 2025 \
		and highest >= 27.85 and highest <= 27.86 \
		and body.collision_layer == 1 and body.collision_mask == 0 \
		and not body.is_in_group("spray_receiver_wall") \
		and bool(node.get_meta("building_3_massing_override", false)) \
		and (node.find_children("*", "CollisionObject3D", true, false) as Array).size() == 1


func _facade_matches(facade: Building3600CaliforniaFacade) -> bool:
	if str(facade.get_meta("layout_sha256", "")) != EXPECTED_LAYOUT_SHA256 \
	or facade.get_meta("styled_run_indices", []) != [27, 28, 29, 30, 31, 32, 33, 34, 35] \
	or int(facade.get_meta("field_segment_count", 0)) != 18 \
	or int(facade.get_meta("reference_pylon_relief_count", 0)) != 2 \
	or facade.get_meta("module_counts", {}) != {"B3-HANGAR-DOOR": 1, "B3-BAND": 1} \
	or not bool(facade.get_meta("render_only", false)) \
	or facade.is_in_group("spray_receiver_wall") \
	or not facade.find_children("*", "CollisionObject3D", true, false).is_empty() \
	or not facade.find_children("*", "NavigationRegion3D", true, false).is_empty():
		return false
	var fields := facade.get_node("FacadeFields_Runs_27_35") as MeshInstance3D
	var mesh := fields.mesh as ArrayMesh
	if fields.layers != RENDER_BUILDING_WALL or mesh.get_surface_count() != 1 or mesh.get_faces().size() != 108:
		return false
	var side := facade.get_node("ENE_Main_Runs_27_35") as Node3D
	var kinds: Array[String] = []
	for child: Node in side.get_children():
		if child.has_meta("module_kind"):
			if not bool(child.get_meta("complete_motif", false)):
				return false
			kinds.append(str(child.get_meta("module_kind")))
	return kinds == ["B3-HANGAR-DOOR", "B3-BAND"]


func _spray_ray_hits_wall(node: Node3D) -> bool:
	var start := Vector3(528.784, 9.728, 488.910)
	var end := Vector3(486.955, 9.728, 408.860)
	var point := start + (end - start).normalized() * 45.160
	var normal := Vector3(0.886, 0.0, -0.463).normalized()
	var query := PhysicsRayQueryParameters3D.create(point + normal * 3.0, point - normal * 3.0, PHYSICS_SPRAY_SURFACE)
	var hit := node.get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == node.get_node("Collision") \
		and str((hit.collider as CollisionObject3D).get_meta("derived_object_key", "")) == TARGET_WALL_KEY


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


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
