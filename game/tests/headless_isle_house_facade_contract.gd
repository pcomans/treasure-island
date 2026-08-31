extends SceneTree

const PARENT_SOURCE_KEY := "w1249412094"
const HIGH_SOURCE_KEY := "w1282547786"
const LOW_SOURCE_KEY := "w1282547787"
const HIGH_WALL_KEY := "building-composite:w1249412094:w1282547786:wall"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const HIGH_ROOF_KEY := "building-composite:w1249412094:w1282547786:roof"
const LOW_ROOF_KEY := "building-composite:w1249412094:w1282547787:roof"
const MUSEUM_WALL_KEY := "building:r16681702:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const HAWKINS_CHUNK_PATH := "res://generated/world/chunks/x_-1__z_1.json"
const MANIFEST_PATH := "res://generated/world/manifest.json"
const LAYOUT_PATH := "res://game/resources/facades/isle_house_39_bruton_high_se_layout.json"
const EXPECTED_CHUNK_SHA256 := "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_LAYOUT_SHA256 := "c5e6393e90152cef62f6478d7bd87750f3db5598d6ebc36cd307ce20acaa090d"
const EXPECTED_HAWKINS_SIGNATURE := "d311c103c9273b94fc982588f46bae6ab67ba6be54b0d0a111dd305e39c22219"
const EXPECTED_MODULE_COUNTS := {
	"IH-TW": 170,
	"IH-PW-W": 4,
	"IH-PW-M": 8,
	"IH-PW-N": 6,
	"IH-CW": 1,
	"IH-GG": 5,
	"IH-ENTRY39": 1,
	"IH-LVR": 1,
	"IH-CANOPY": 1,
}
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_BUILDING_WALL := 1 << 1

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(CHUNK_PATH) == EXPECTED_CHUNK_SHA256, "Isle House serialized chunk drifted.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated manifest drifted.") \
	or not _require(FileAccess.get_sha256(LAYOUT_PATH) == EXPECTED_LAYOUT_SHA256, "Isle House high layout drifted."):
		_finish()
		return
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	var hawkins_chunk := JSON.parse_string(FileAccess.get_file_as_string(HAWKINS_CHUNK_PATH)) as Dictionary
	var layout := JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH)) as Dictionary
	var high_wall := _record_for_key(chunk.records, HIGH_WALL_KEY)
	var low_wall := _record_for_key(chunk.records, LOW_WALL_KEY)
	var high_roof := _record_for_key(chunk.records, HIGH_ROOF_KEY)
	var low_roof := _record_for_key(chunk.records, LOW_ROOF_KEY)
	var museum_wall := _record_for_key(chunk.records, MUSEUM_WALL_KEY)
	var hawkins_wall := _record_for_key(hawkins_chunk.records, "building:w1249412093:wall")
	if not _require(_no_parent_receiver(chunk.records), "Composite parent unexpectedly gained a direct receiver.") \
	or not _require(_layout_matches(layout), "Isle House exact SE/partial ENE/shared/low layout policy drifted.") \
	or not _require(_materials_match(), "Isle House materials are not separate opaque scalar dielectric resources.") \
	or not _require(not high_wall.is_empty() and not low_wall.is_empty() and not high_roof.is_empty() and not low_roof.is_empty() and not museum_wall.is_empty() and not hawkins_wall.is_empty(), "Could not resolve Isle part, roof, Museum, or Hawkins controls."):
		_finish()
		return
	var builder := WorldChunkBuilder.new()
	var first_result := builder._build_record(high_wall, false)
	var second_result := builder._build_record(high_wall, false)
	var low_result := builder._build_record(low_wall, false)
	var high_roof_result := builder._build_record(high_roof, false)
	var low_roof_result := builder._build_record(low_roof, false)
	var museum_result := builder._build_record(museum_wall, false)
	var hawkins_result := builder._build_record(hawkins_wall, false)
	var results := [first_result, second_result, low_result, high_roof_result, low_roof_result, museum_result, hawkins_result]
	for value: Variant in results:
		if not _require(bool((value as Dictionary).get("ok", false)), "An Isle House or preservation-control record failed construction."):
			_free_results(results)
			_finish()
			return
	var first := first_result.node as Node3D
	var second := second_result.node as Node3D
	var low := low_result.node as Node3D
	var high_roof_node := high_roof_result.node as Node3D
	var low_roof_node := low_roof_result.node as Node3D
	var museum := museum_result.node as Node3D
	var hawkins := hawkins_result.node as Node3D
	var facade := first.get_node_or_null("IsleHouse39BrutonHighFacade") as IsleHouse39BrutonHighFacade
	var second_facade := second.get_node_or_null("IsleHouse39BrutonHighFacade") as IsleHouse39BrutonHighFacade
	var hawkins_facade := hawkins.get_node_or_null("Hawkins77BrutonFacade") as Hawkins77BrutonFacade
	if not _require(facade != null and second_facade != null, "Exact high part did not receive one Isle House facade.") \
	or not _require(low.get_node_or_null("IsleHouse39BrutonHighFacade") == null and high_roof_node.get_node_or_null("IsleHouse39BrutonHighFacade") == null and low_roof_node.get_node_or_null("IsleHouse39BrutonHighFacade") == null, "Isle House facade spilled to low part or roofs.") \
	or not _require(museum.find_children("*Facade*", "Node", true, false).is_empty(), "Blocked Museum gained facade runtime content.") \
	or not _require(hawkins_facade != null and str(hawkins_facade.get_meta("deterministic_signature", "")) == EXPECTED_HAWKINS_SIGNATURE, "Accepted Hawkins result changed.") \
	or not _require(str(facade.get_meta("deterministic_signature", "")) == str(second_facade.get_meta("deterministic_signature", "")), "Isle House assignments are nondeterministic.") \
	or not _require(_high_receiver_matches(first, high_wall), "High part massing/foundation/collision/spray receiver drifted.") \
	or not _require(_low_receiver_matches(low), "Low part massing/hidden-interface/collision contract drifted.") \
	or not _require(_facade_matches(facade, high_wall, layout), "Isle high all-side fields, accepted modules, protected exclusions, or render-only contract drifted."):
		_free_results(results)
		_finish()
		return
	var facade_signature := str(facade.get_meta("deterministic_signature", ""))
	root.add_child(first)
	await physics_frame
	await physics_frame
	if not _require(_spray_ray_hits_high(first), "Ray through Isle House 39 entrance did not hit unchanged high-part spray receiver."):
		root.remove_child(first)
		_free_results(results)
		_finish()
		return
	root.remove_child(first)
	_free_results(results)
	var full_world := await _full_world_scope_matches()
	if not _require(bool(full_world.get("ok", false)), str(full_world.get("message", "Whole-island Isle House reload failed."))):
		_finish()
		return
	print("ISLE_ALL_SIDE_SIGNATURE: %s" % facade_signature)
	print("PASS: Isle House high has exact homogeneous fields on exterior runs 0..9 and tower-only fields on shared runs 10..12; accepted SE run 5..7 modules, module-free runs 0..4/8..12, low part, roofs, collision, spray, Museum, Hawkins, and one clean whole-island load remain pinned")
	_finish()


func _layout_matches(layout: Dictionary) -> bool:
	var target := layout.target as Dictionary
	var render := layout.render_contract as Dictionary
	var se := layout.observed_high_se as Dictionary
	var ene := layout.partial_high_ene as Dictionary
	if str(layout.schema_version) != "ti.isle-house-high-facade-layout/1" \
	or str(target.parent_source_key) != PARENT_SOURCE_KEY \
	or str(target.source_key) != HIGH_SOURCE_KEY \
	or str(target.low_source_key) != LOW_SOURCE_KEY \
	or str(target.receiver_object_key) != HIGH_WALL_KEY \
	or str(target.low_receiver_object_key) != LOW_WALL_KEY \
	or int(target.wall_segments) != 13 or int(target.wall_triangles) != 26 \
	or not is_equal_approx(float(target.base_y_m), 4.103) \
	or not is_equal_approx(float(target.low_top_y_m), 19.103) \
	or not is_equal_approx(float(target.top_y_m), 71.103) \
	or _int_array(se.run_indices as Array) != [5, 6, 7] or not is_equal_approx(float(se.length_m), 42.278) \
	or _int_array(ene.run_indices as Array) != [8, 9] or not is_equal_approx(float(ene.length_m), 14.442) \
	or str(se.module_policy) != "observed_complete_modules" \
	or str(ene.module_policy) != "material_only" \
	or _int_array(layout.shared_above_low_run_indices as Array) != [10, 11, 12] \
	or str(layout.low_part_policy) != "unchanged_no_facade_attachment" \
	or str(render.collision) != "none" or str(render.navigation) != "none" \
	or float(render.maximum_relief_m) > 0.08:
		return false
	return (se.tower_window_columns_u_m as Array).size() == 10 \
		and (se.tower_window_rows_y_m as Array).size() == 17 \
		and (se.single_modules as Array).size() == 9


func _materials_match() -> bool:
	var paths := [
		"res://game/resources/materials/world/isle_house/isle_house_tower_light.tres",
		"res://game/resources/materials/world/isle_house/isle_house_tower_accent.tres",
		"res://game/resources/materials/world/isle_house/isle_house_podium_light.tres",
		"res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres",
		"res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres",
		"res://game/resources/materials/world/isle_house/isle_house_support_grey.tres",
		"res://game/resources/materials/world/isle_house/isle_house_identifier.tres",
	]
	var resources: Array[Resource] = []
	for path: String in paths:
		var material := load(path) as StandardMaterial3D
		if material == null or not is_zero_approx(material.metallic) \
		or material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED \
		or material.albedo_texture != null or material.normal_texture != null or material.heightmap_enabled:
			return false
		resources.append(material)
	for first_index in resources.size():
		for second_index in range(first_index + 1, resources.size()):
			if resources[first_index] == resources[second_index]:
				return false
	return true


func _high_receiver_matches(node: Node3D, record: Dictionary) -> bool:
	var mesh := (node.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	var body := node.get_node("Collision") as StaticBody3D
	var shape := (node.get_node("Collision/Shape") as CollisionShape3D).shape as ConcavePolygonShape3D
	var vertices := mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var lowest := INF
	var highest := -INF
	for vertex: Vector3 in vertices:
		lowest = minf(lowest, vertex.y)
		highest = maxf(highest, vertex.y)
	for run_index in [10, 11, 12]:
		if not is_equal_approx(float((record.vertices as Array)[run_index * 12 + 1]), 19.103):
			return false
	return vertices.size() == 52 and mesh.get_faces().size() == 78 and shape.get_faces().size() == 78 \
		and is_equal_approx(lowest, 3.908) and is_equal_approx(highest, 71.103) \
		and body.collision_layer == (1 | PHYSICS_SPRAY_SURFACE) and body.is_in_group("spray_receiver_wall") \
		and body.get_meta("source_keys", []) == [HIGH_SOURCE_KEY] \
		and (node.find_children("*", "CollisionObject3D", true, false) as Array).size() == 1


func _low_receiver_matches(node: Node3D) -> bool:
	var mesh := (node.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	var vertices := mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var lowest := INF
	var highest := -INF
	for vertex: Vector3 in vertices:
		lowest = minf(lowest, vertex.y)
		highest = maxf(highest, vertex.y)
	return vertices.size() == 52 and mesh.get_faces().size() == 78 \
		and is_equal_approx(lowest, 3.983) and is_equal_approx(highest, 19.103) \
		and node.get_node_or_null("IsleHouse39BrutonHighFacade") == null \
		and (node.find_children("*", "CollisionObject3D", true, false) as Array).size() == 1


func _facade_matches(facade: IsleHouse39BrutonHighFacade, high_wall: Dictionary, layout: Dictionary) -> bool:
	if str(facade.get_meta("layout_sha256", "")) != EXPECTED_LAYOUT_SHA256 \
	or facade.get_meta("module_run_indices", []) != [5, 6, 7] \
	or facade.get_meta("exterior_field_run_indices", []) != [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] \
	or facade.get_meta("new_exterior_field_run_indices", []) != [0, 1, 2, 3, 4] \
	or facade.get_meta("material_only_run_indices", []) != [0, 1, 2, 3, 4, 8, 9, 10, 11, 12] \
	or facade.get_meta("preserved_partial_material_only_run_indices", []) != [8, 9] \
	or facade.get_meta("shared_above_low_run_indices", []) != [10, 11, 12] \
	or facade.get_meta("shared_tower_field_run_indices", []) != [10, 11, 12] \
	or facade.get_meta("module_counts", {}) != EXPECTED_MODULE_COUNTS \
	or int(facade.get_meta("field_segment_count", 0)) != 13 \
	or int(facade.get_meta("field_quad_count", 0)) != 23 \
	or not bool(facade.get_meta("render_only", false)) \
	or facade.is_in_group("spray_receiver_wall") \
	or not facade.find_children("*", "CollisionObject3D", true, false).is_empty() \
	or not facade.find_children("*", "NavigationRegion3D", true, false).is_empty():
		return false
	var fields := facade.get_node("FacadeFields_All_High_Runs") as MeshInstance3D
	var mesh := fields.mesh as ArrayMesh
	if fields.layers != RENDER_BUILDING_WALL or mesh.get_surface_count() != 2 or mesh.get_faces().size() != 138 \
	or fields.get_meta("exterior_field_run_indices", []) != [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] \
	or fields.get_meta("new_exterior_field_run_indices", []) != [0, 1, 2, 3, 4] \
	or fields.get_meta("module_run_indices", []) != [5, 6, 7] \
	or fields.get_meta("module_free_run_indices", []) != [0, 1, 2, 3, 4, 8, 9, 10, 11, 12] \
	or fields.get_meta("shared_tower_field_run_indices", []) != [10, 11, 12] \
	or not bool(fields.get_meta("low_receiver_untouched", false)) \
	or not _field_coverage_matches(mesh, high_wall):
		return false
	var new_side := facade.get_node("High_WSW_SW_Runs_0_4") as Node3D
	var se := facade.get_node("High_SE_Runs_5_7") as Node3D
	var ene := facade.get_node("High_ENE_Runs_8_9") as Node3D
	var shared := facade.get_node("High_Shared_Runs_10_12") as Node3D
	if new_side.get_meta("run_indices", []) != [0, 1, 2, 3, 4] \
	or str(new_side.get_meta("module_policy", "")) != "material_only" \
	or str(se.get_meta("module_policy", "")) != "observed_complete_modules" \
	or str(ene.get_meta("module_policy", "")) != "material_only" \
	or shared.get_meta("run_indices", []) != [10, 11, 12] \
	or str(shared.get_meta("module_policy", "")) != "tower_field_only":
		return false
	for protected_side: Node3D in [new_side, ene, shared]:
		for child: Node in protected_side.get_children():
			if child.has_meta("module_kind"):
				return false
	var observed_counts: Dictionary = {}
	for child: Node in se.get_children():
		if child.has_meta("module_kind"):
			if not bool(child.get_meta("complete_motif", false)) or str(child.get_meta("run_scope", "")) != "high_se_5_7":
				return false
			var kind := str(child.get_meta("module_kind"))
			observed_counts[kind] = int(observed_counts.get(kind, 0)) + 1
	return observed_counts == EXPECTED_MODULE_COUNTS and _accepted_module_schedule_matches(se, layout.observed_high_se as Dictionary)


func _field_coverage_matches(mesh: ArrayMesh, record: Dictionary) -> bool:
	var expected_paths := {
		"isle_house_podium_light.tres": range(10),
		"isle_house_tower_light.tres": range(13),
	}
	var seen_paths: Array[String] = []
	var exact_quads: Dictionary = {}
	for surface_index in mesh.get_surface_count():
		var material := mesh.surface_get_material(surface_index) as Material
		var filename := material.resource_path.get_file() if material != null else ""
		if filename not in expected_paths or filename in seen_paths:
			return false
		seen_paths.append(filename)
		var vertices := (mesh.surface_get_arrays(surface_index) as Array)[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var run_indices: Array = expected_paths[filename]
		if vertices.size() != run_indices.size() * 4:
			return false
		for quad_index in run_indices.size():
			var run_index := int(run_indices[quad_index])
			var offset := run_index * 12
			var raw_vertices: Array = record.vertices
			var raw_normals: Array = record.normals
			var normal := Vector3(float(raw_normals[offset]), 0.0, float(raw_normals[offset + 2])).normalized()
			var outward := normal * 0.012
			var lower_start_y := float(raw_vertices[offset + 1]) if filename == "isle_house_podium_light.tres" else 19.103
			var lower_end_y := float(raw_vertices[offset + 4]) if filename == "isle_house_podium_light.tres" else 19.103
			var upper_y := 19.103 if filename == "isle_house_podium_light.tres" else 71.103
			var expected := [
				Vector3(float(raw_vertices[offset]), lower_start_y, float(raw_vertices[offset + 2])) + outward,
				Vector3(float(raw_vertices[offset + 3]), lower_end_y, float(raw_vertices[offset + 5])) + outward,
				Vector3(float(raw_vertices[offset + 3]), upper_y, float(raw_vertices[offset + 5])) + outward,
				Vector3(float(raw_vertices[offset]), upper_y, float(raw_vertices[offset + 2])) + outward,
			]
			var corners: Array[Vector3] = []
			for corner_index in 4:
				var actual := vertices[quad_index * 4 + corner_index]
				if actual.distance_to(expected[corner_index] as Vector3) > 0.0001:
					return false
				corners.append(actual)
			var token := _quad_token(corners)
			if exact_quads.has(token):
				return false
			exact_quads[token] = true
	return seen_paths.size() == 2 and exact_quads.size() == 23


func _accepted_module_schedule_matches(side: Node3D, schedule: Dictionary) -> bool:
	var actual: Array[String] = []
	for child: Node in side.get_children():
		if child.has_meta("module_kind"):
			actual.append(_module_token(str(child.get_meta("module_kind")), float(child.get_meta("side_u_m")), (child as Node3D).transform.origin.y, float(child.get_meta("width_m")), float(child.get_meta("height_m"))))
	var expected: Array[String] = []
	var tower := schedule.tower_window as Dictionary
	for u_value: Variant in schedule.tower_window_columns_u_m:
		for y_value: Variant in schedule.tower_window_rows_y_m:
			expected.append(_module_token("IH-TW", float(u_value), float(y_value), float(tower.width_m), float(tower.height_m)))
	for family_value: Variant in schedule.podium_window_families:
		var family := family_value as Dictionary
		for u_value: Variant in family.columns_u_m:
			for y_value: Variant in schedule.podium_window_rows_y_m:
				expected.append(_module_token(str(family.kind), float(u_value), float(y_value), float(family.width_m), float(family.height_m)))
	for module_value: Variant in schedule.single_modules:
		var module := module_value as Dictionary
		expected.append(_module_token(str(module.kind), float(module.u_m), float(module.center_y_m), float(module.width_m), float(module.height_m)))
	actual.sort()
	expected.sort()
	return actual == expected


func _module_token(kind: String, u: float, y: float, width: float, height: float) -> String:
	return "%s|%.3f|%.3f|%.3f|%.3f" % [kind, u, y, width, height]


func _quad_token(corners: Array[Vector3]) -> String:
	var values: Array[String] = []
	for corner: Vector3 in corners:
		values.append("%.5f,%.5f,%.5f" % [corner.x, corner.y, corner.z])
	values.sort()
	return "|".join(values)


func _spray_ray_hits_high(node: Node3D) -> bool:
	var start := Vector3(-117.142, 6.4, 571.175)
	var end := Vector3(-89.198, 6.4, 539.449)
	var point := start + (end - start).normalized() * 14.3
	var normal := Vector3(0.750, 0.0, 0.661).normalized()
	var query := PhysicsRayQueryParameters3D.create(point + normal * 3.0, point - normal * 3.0, PHYSICS_SPRAY_SURFACE)
	var hit := node.get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == node.get_node("Collision") \
		and str((hit.collider as CollisionObject3D).get_meta("derived_object_key", "")) == HIGH_WALL_KEY


func _full_world_scope_matches() -> Dictionary:
	var packed := load("res://game/scenes/world/world_root.tscn") as PackedScene
	if packed == null:
		return {"ok": false, "message": "Could not load WorldRoot for the Isle House whole-island check."}
	var world := packed.instantiate() as WorldLoader
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys}))
	root.add_child(world)
	world.load_world(MANIFEST_PATH)
	await process_frame
	await process_frame
	var high_nodes := _nodes_for_key(world, HIGH_WALL_KEY)
	var low_nodes := _nodes_for_key(world, LOW_WALL_KEY)
	var ok := failures.is_empty() and reports.size() == 1 and high_nodes.size() == 1 and low_nodes.size() == 1
	if ok:
		var high := high_nodes[0] as Node3D
		var low := low_nodes[0] as Node3D
		var facade := high.get_node_or_null("IsleHouse39BrutonHighFacade") as IsleHouse39BrutonHighFacade
		ok = facade != null \
			and int(facade.get_meta("field_segment_count", 0)) == 13 \
			and int(facade.get_meta("field_quad_count", 0)) == 23 \
			and facade.get_node_or_null("FacadeFields_All_High_Runs") != null \
			and low.get_node_or_null("IsleHouse39BrutonHighFacade") == null
	root.remove_child(world)
	world.free()
	return {"ok": ok, "message": "Whole-island load did not retain exactly one scoped high facade and one untouched low receiver: failures=%s reports=%d high=%d low=%d" % [failures, reports.size(), high_nodes.size(), low_nodes.size()]}


func _nodes_for_key(root_node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if str(node.get_meta("derived_object_key", "")) == key and node.get_parent() != null and str(node.get_parent().name).contains("__"):
			result.append(node)
	return result


func _no_parent_receiver(records: Array) -> bool:
	for value: Variant in records:
		var key := str((value as Dictionary).get("object_key", ""))
		if key == "building-composite:w1249412094" or key == "building:w1249412094:wall":
			return false
	return true


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
