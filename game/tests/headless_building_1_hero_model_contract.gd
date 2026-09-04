extends SceneTree

const HERO := preload("res://game/scripts/world/facades/building_1_hero_model.gd")
const MAIN_CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const TOWER_CHUNK_PATH := "res://generated/world/chunks/x_0__z_2.json"
const KEYS := [
	"building:r16681702:wall",
	"building:r16681702:roof",
	"building:w1222720021:wall",
	"building:w1222720021:roof",
]
const EXPECTED_COMPONENT_TOPOLOGY := {
	"building:r16681702:wall": {"meshes": 6, "surfaces": 6, "triangles": 8806, "bodies": 1, "shapes": 1, "collision_face_vertices": 2046},
	"building:r16681702:roof": {"meshes": 3, "surfaces": 3, "triangles": 1131, "bodies": 1, "shapes": 1, "collision_face_vertices": 1737},
	"building:w1222720021:wall": {"meshes": 3, "surfaces": 3, "triangles": 760, "bodies": 1, "shapes": 1, "collision_face_vertices": 120},
	"building:w1222720021:roof": {"meshes": 1, "surfaces": 1, "triangles": 14, "bodies": 1, "shapes": 1, "collision_face_vertices": 42},
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var records := _records()
	_require(records.size() == 4, "The four exact Building 1/tower source records did not resolve.")
	var measured := {}
	for key in KEYS:
		var record := records.get(key, {}) as Dictionary
		var first := WorldChunkBuilder.new()._build_record(record, false)
		var second := WorldChunkBuilder.new()._build_record(record, false)
		if not _require(bool(first.get("ok", false)) and bool(second.get("ok", false)), "%s hero replacement did not build twice." % key):
			_free_result(first)
			_free_result(second)
			continue
		var first_node := first.node as Node3D
		var second_node := second.node as Node3D
		var topology := {
			"meshes": int(first.mesh_instances),
			"surfaces": int(first.surfaces),
			"triangles": int(first.triangles),
			"bodies": int(first.get("static_bodies", -1)),
			"shapes": int(first.get("shapes", -1)),
			"collision_face_vertices": int(first_node.get_meta("collision_face_vertices", -1)),
		}
		measured[key] = topology
		_require(_identity_contract(first_node, record), "%s lost its independent source/object identity or truth boundary." % key)
		_require(_collision_contract(first_node, key.ends_with(":wall")), "%s collision/spray ownership drifted." % key)
		_require(_deterministic(first_node, second_node), "%s hero geometry is nondeterministic." % key)
		if not EXPECTED_COMPONENT_TOPOLOGY.is_empty():
			_require(topology == EXPECTED_COMPONENT_TOPOLOGY.get(key, {}), "%s measured topology drifted: %s" % [key, JSON.stringify(topology)])
		if key == HERO.BUILDING_WALL_KEY:
			_require(_exact_building_plan(first_node, record), "Building 1 base no longer begins with all 110 exact source-run wall faces.")
			_require(_building_schedule(first_node), "Building 1 NPS-derived schedule/truth metadata drifted.")
		if key == HERO.BUILDING_ROOF_KEY:
			_require(_exact_building_roof_plan(first_node, record), "Building 1 two-story roof no longer begins with the exact frozen source triangulation.")
		if key == HERO.TOWER_WALL_KEY:
			_require(_exact_tower_plan(first_node, record), "Tower glazing no longer uses the exact separately keyed source plan.")
		if key == HERO.TOWER_ROOF_KEY:
			_require(_exact_tower_roof_plan(first_node, record), "Tower pyramidal roof no longer rises from the exact separately keyed source plan.")
		first_node.free()
		second_node.free()
	print("BUILDING_1_HERO_COMPONENT_TOPOLOGY=%s" % JSON.stringify(measured))
	await _whole_world_contract()
	if not _failed:
		print("PASS: Building 1 hero preserves four source identities and exact horizontal plans while replacing all four generic vertical/collision placeholders deterministically")
	quit(1 if _failed else 0)


func _identity_contract(node: Node3D, record: Dictionary) -> bool:
	return str(node.get_meta("derived_object_key", "")) == str(record.object_key) \
		and node.get_meta("source_keys", []) == record.source_keys \
		and bool(node.get_meta("runtime_supersedes_generated_placeholder", false)) \
		and bool(node.get_meta("horizontal_source_geometry_preserved", false)) \
		and str(node.get_meta("vertical_massing_role", "")) == "reversible_production_inference" \
		and not bool(node.get_meta("surveyed_vertical_dimensions", true)) \
		and not bool(node.get_meta("surveyed_facade_coordinates", true)) \
		and not bool(node.get_meta("surveyed_cadence", true)) \
		and not bool(node.get_meta("interior_modeled", true)) \
		and not bool(node.get_meta("as_built_fidelity_claimed", true)) \
		and not bool(node.get_meta("source_photography_shipped", true)) \
		and str(node.get_meta("visual_review_status", "")) == HERO.VISUAL_REVIEW_STATUS


func _collision_contract(node: Node3D, sprayable: bool) -> bool:
	var bodies := node.find_children("*", "StaticBody3D", true, false)
	var shapes := node.find_children("*", "CollisionShape3D", true, false)
	if bodies.size() != 1 or shapes.size() != 1:
		return false
	var body := bodies[0] as StaticBody3D
	var shape_node := shapes[0] as CollisionShape3D
	var faces := (shape_node.shape as ConcavePolygonShape3D).get_faces()
	return not faces.is_empty() \
		and body.collision_layer == ((1 << 0) | ((1 << 2) if sprayable else 0)) \
		and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") == sprayable \
		and str(body.get_meta("derived_object_key", "")) == str(node.get_meta("derived_object_key", "")) \
		and bool(body.get_meta("building_1_hero", false))


func _exact_building_plan(node: Node3D, record: Dictionary) -> bool:
	var mesh_node := node.get_node_or_null("HeroIvory") as MeshInstance3D
	if mesh_node == null:
		return false
	var arrays := (mesh_node.mesh as ArrayMesh).surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var source := record.vertices as Array
	if vertices.size() < 440:
		return false
	for run_index in range(110):
		var source_offset := run_index * 12
		var mesh_offset := run_index * 4
		var expected_start := Vector2(float(source[source_offset]), float(source[source_offset + 2]))
		var expected_end := Vector2(float(source[source_offset + 3]), float(source[source_offset + 5]))
		if Vector2(vertices[mesh_offset].x, vertices[mesh_offset].z).distance_to(expected_start) > 0.00001 \
		or Vector2(vertices[mesh_offset + 1].x, vertices[mesh_offset + 1].z).distance_to(expected_end) > 0.00001:
			return false
	return true


func _building_schedule(node: Node3D) -> bool:
	var tiers := [14.75, 20.25, 26.281]
	return int(node.get_meta("central_window_count", -1)) == 11 \
		and int(node.get_meta("central_lights_per_window", -1)) == 18 \
		and int(node.get_meta("upper_windows_per_wing", -1)) == 8 \
		and int(node.get_meta("upper_lights_per_window", -1)) == 10 \
		and int(node.get_meta("lower_windows_per_wing", -1)) == 7 \
		and int(node.get_meta("entrance_groups", -1)) == 3 \
		and int(node.get_meta("doors_per_entrance_group", -1)) == 3 \
		and int(node.get_meta("end_composition_count", -1)) == 2 \
		and int(node.get_meta("relief_proxy_count", -1)) == 0 \
		and int(node.get_meta("neutral_end_relief_location_field_count", -1)) == 2 \
		and int(node.get_meta("misleading_cruciform_proxy_count", -1)) == 0 \
		and bool(node.get_meta("public_front_believability_pass", false)) \
		and tiers[0] < tiers[1] and tiers[1] < tiers[2]


func _exact_building_roof_plan(node: Node3D, record: Dictionary) -> bool:
	var mesh_node := node.get_node_or_null("HeroSteppedRoof") as MeshInstance3D
	if mesh_node == null:
		return false
	var vertices := ((mesh_node.mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array)
	var source_vertices := record.vertices as Array
	var source_indices := record.indices as Array
	if vertices.size() < source_indices.size():
		return false
	for offset in source_indices.size():
		var source_offset := int(source_indices[offset]) * 3
		var expected := Vector2(float(source_vertices[source_offset]), float(source_vertices[source_offset + 2]))
		if Vector2(vertices[offset].x, vertices[offset].z).distance_to(expected) > 0.00001 \
		or absf(vertices[offset].y - 14.75) > 0.00001:
			return false
	return true


func _exact_tower_plan(node: Node3D, record: Dictionary) -> bool:
	if not bool(node.get_meta("tower_separate_recognition_entity", false)) \
	or not bool(node.get_meta("exact_source_plan", false)) \
	or int(node.get_meta("exact_plan_run_count", -1)) != 10:
		return false
	var mesh_node := node.get_node_or_null("HeroTowerExactPlanGlass") as MeshInstance3D
	if mesh_node == null:
		return false
	var arrays := (mesh_node.mesh as ArrayMesh).surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var source := record.vertices as Array
	if vertices.size() != 40:
		return false
	for run_index in range(10):
		var source_offset := run_index * 12
		var mesh_offset := run_index * 4
		var expected_start := Vector2(float(source[source_offset]), float(source[source_offset + 2]))
		var expected_end := Vector2(float(source[source_offset + 3]), float(source[source_offset + 5]))
		if Vector2(vertices[mesh_offset].x, vertices[mesh_offset].z).distance_to(expected_start) > 0.00001 \
		or Vector2(vertices[mesh_offset + 1].x, vertices[mesh_offset + 1].z).distance_to(expected_end) > 0.00001 \
		or absf(vertices[mesh_offset].y - 27.35) > 0.00001 \
		or absf(vertices[mesh_offset + 2].y - 32.65) > 0.00001:
			return false
	return true


func _exact_tower_roof_plan(node: Node3D, record: Dictionary) -> bool:
	if not bool(node.get_meta("tower_separate_recognition_entity", false)) \
	or not bool(node.get_meta("exact_source_plan", false)) \
	or int(node.get_meta("source_plan_corner_count", -1)) != 8:
		return false
	var mesh_node := node.get_node_or_null("HeroTowerPlatformAndPyramidalRoof") as MeshInstance3D
	if mesh_node == null:
		return false
	var vertices := ((mesh_node.mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array)
	var source := record.vertices as Array
	if vertices.size() != 42 or source.size() != 24:
		return false
	# Six inferred wider-platform triangles occupy the first 18 vertices. Each
	# following roof triangle starts on one of the eight exact source corners.
	for corner in 8:
		var vertex := vertices[18 + corner * 3]
		var source_offset := corner * 3
		if Vector2(vertex.x, vertex.z).distance_to(Vector2(float(source[source_offset]), float(source[source_offset + 2]))) > 0.00001 \
		or absf(vertex.y - 32.65) > 0.00001 \
		or absf(vertices[20 + corner * 3].y - 35.4) > 0.00001:
			return false
	return true


func _deterministic(first: Node3D, second: Node3D) -> bool:
	if first.name != second.name or first.get_meta_list() != second.get_meta_list() or first.get_child_count() != second.get_child_count():
		return false
	for index in first.get_child_count():
		var left := first.get_child(index)
		var right := second.get_child(index)
		if left.name != right.name or left.get_class() != right.get_class():
			return false
		if left is MeshInstance3D:
			var left_mesh := (left as MeshInstance3D).mesh as ArrayMesh
			var right_mesh := (right as MeshInstance3D).mesh as ArrayMesh
			if left_mesh.surface_get_arrays(0) != right_mesh.surface_get_arrays(0):
				return false
		if left is StaticBody3D:
			var left_faces := (((left as StaticBody3D).get_node("Shape") as CollisionShape3D).shape as ConcavePolygonShape3D).get_faces()
			var right_faces := (((right as StaticBody3D).get_node("Shape") as CollisionShape3D).shape as ConcavePolygonShape3D).get_faces()
			if left_faces != right_faces:
				return false
	return true


func _whole_world_contract() -> void:
	var world := (load("res://game/scenes/world/world_root.tscn") as PackedScene).instantiate() as WorldLoader
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys}))
	root.add_child(world)
	world.load_world("res://generated/world/manifest.json")
	var wait_started := Time.get_ticks_msec()
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - wait_started < 30000:
		await process_frame
	var evidence := world.get_runtime_evidence()
	_require(failures.is_empty() and reports.size() == 1 and evidence != null, "Whole world did not load with the Building 1 hero replacements.")
	if evidence != null:
		print("BUILDING_1_HERO_WORLD_TOPOLOGY=%d/%d/%d/%d/%d" % [evidence.playable_rows, evidence.mesh_instances, evidence.surfaces, evidence.triangles, evidence.static_bodies])
		_require(evidence.playable_rows == 735 and evidence.context_rows == 4 \
			and evidence.mesh_instances == 940 and evidence.surfaces == 954 and evidence.triangles == 64118 \
			and evidence.static_bodies == 466 and evidence.shapes == 466, "Building 1 hero changed source coverage, measured runtime topology, or the four-body collider total.")
		for key in KEYS:
			_require(_record_nodes(world, key).size() == 1, "%s is not represented exactly once in the loaded world." % key)
	await physics_frame
	await physics_frame
	_runtime_collision_contract(world)
	root.remove_child(world)
	world.free()


func _runtime_collision_contract(world: WorldLoader) -> void:
	var records := _records()
	var building_wall := records[HERO.BUILDING_WALL_KEY] as Dictionary
	var tower_wall := records[HERO.TOWER_WALL_KEY] as Dictionary
	var roof_cases := [
		{"label": "exposed_two_story", "record": building_wall, "run": 75, "depth": 1.25, "y": 14.75, "key": HERO.BUILDING_ROOF_KEY},
		{"label": "north_three_story", "record": building_wall, "run": 13, "depth": 5.0, "y": 20.25, "key": HERO.BUILDING_ROOF_KEY},
		{"label": "central_four_story", "record": building_wall, "run": 35, "depth": 5.0, "y": 26.281, "key": HERO.BUILDING_ROOF_KEY},
		{"label": "south_three_story", "record": building_wall, "run": 50, "depth": 5.0, "y": 20.25, "key": HERO.BUILDING_ROOF_KEY},
	]
	var space := world.get_world_3d().direct_space_state
	for case in roof_cases:
		var point := _run_inward_point(case.record as Dictionary, int(case.run), float(case.depth), float(case.y))
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.65, point - Vector3.UP * 0.65, 1 << 0))
		var collider := hit.get("collider") as CollisionObject3D
		_require(collider != null and str(collider.get_meta("derived_object_key", "")) == str(case.key) and absf((hit.get("position", Vector3.ZERO) as Vector3).y - float(case.y)) < 0.02, "%s roof ray did not hit the truthful visible tier." % str(case.label))
	var tower_center := Vector3(14.590211, 27.35, 722.34404)
	var tower_frame := _run_frame(tower_wall, 0)
	var source_mid := (tower_frame.start as Vector3).lerp(tower_frame.end as Vector3, 0.5)
	var platform_point := Vector3(tower_center.x + (source_mid.x - tower_center.x) * 1.15, 27.35, tower_center.z + (source_mid.z - tower_center.z) * 1.15)
	var platform_hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(platform_point + Vector3.UP * 0.65, platform_point - Vector3.UP * 0.65, 1 << 0))
	var platform_collider := platform_hit.get("collider") as CollisionObject3D
	_require(platform_collider != null and str(platform_collider.get_meta("derived_object_key", "")) == HERO.TOWER_ROOF_KEY and absf((platform_hit.get("position", Vector3.ZERO) as Vector3).y - 27.35) < 0.02, "Tower platform ray did not hit the separately keyed truthful rooftop collider.")
	for wall_case in [
		{"record": building_wall, "run": 36, "y": 10.0, "key": HERO.BUILDING_WALL_KEY},
		{"record": tower_wall, "run": 0, "y": 29.0, "key": HERO.TOWER_WALL_KEY},
	]:
		var frame := _run_frame(wall_case.record as Dictionary, int(wall_case.run))
		var midpoint := (frame.start as Vector3).lerp(frame.end as Vector3, 0.5)
		midpoint.y = float(wall_case.y)
		var normal := frame.normal as Vector3
		var wall_hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(midpoint + normal * 3.0, midpoint - normal * 1.0, (1 << 0) | (1 << 2)))
		var wall_collider := wall_hit.get("collider") as CollisionObject3D
		_require(wall_collider != null and str(wall_collider.get_meta("derived_object_key", "")) == str(wall_case.key) and wall_collider.is_in_group("spray_receiver_wall") and (wall_collider.collision_layer & (1 << 2)) != 0, "%s did not resolve through an actual spray-eligible wall ray." % str(wall_case.key))


func _run_inward_point(record: Dictionary, run_index: int, depth: float, y: float) -> Vector3:
	var frame := _run_frame(record, run_index)
	var point := (frame.start as Vector3).lerp(frame.end as Vector3, 0.5) - (frame.normal as Vector3) * depth
	point.y = y
	return point


func _run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var offset := run_index * 12
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	return {
		"start": start,
		"end": end,
		"normal": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized(),
	}


func _record_nodes(world: WorldLoader, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for child in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(child.get_meta("derived_object_key", "")) == key and child.get_parent() != null and str(child.get_parent().name).contains("__"):
			result.append(child)
	return result


func _records() -> Dictionary:
	var result := {}
	for path in [MAIN_CHUNK_PATH, TOWER_CHUNK_PATH]:
		var chunk := _json(path)
		for value in chunk.get("records", []):
			var record := value as Dictionary
			if str(record.get("object_key", "")) in KEYS:
				result[str(record.object_key)] = record
	return result


func _json(path: String) -> Dictionary:
	var value = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _free_result(result: Dictionary) -> void:
	if result.get("node") is Node:
		(result.node as Node).free()


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_failed = true
		push_error(message)
	return condition
