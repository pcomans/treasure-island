extends SceneTree

const ADAPTER := preload("res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd")
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_-1.json"
const CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const SOURCE_KEY := "w95934105"
const WALL_KEY := "building:w95934105:wall"
const ROOF_KEY := "building:w95934105:roof"
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const EXPECTED_WORLD := {"rows": 735, "meshes": 959, "surfaces": 974, "triangles": 69252, "bodies": 466, "shapes": 466}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var chunk := _json(CHUNK_PATH)
	var records := chunk.get("records", []) as Array
	var wall := _record_for_key(records, WALL_KEY)
	var roof := _record_for_key(records, ROOF_KEY)
	print("D2_1441_LIVE_RECORD_HASHES: canonical_wall=%s runtime_wall=%s projection_wall=%s canonical_roof=%s runtime_roof=%s projection_roof=%s ownership=%s" % [
		ADAPTER.canonical_record_signature(wall), ADAPTER.record_signature(wall), ADAPTER.PROTOTYPE.record_signature(wall),
		ADAPTER.canonical_record_signature(roof), ADAPTER.record_signature(roof), ADAPTER.PROTOTYPE.record_signature(roof),
		ADAPTER.live_ownership_signature(),
	])
	_require(FileAccess.get_sha256(CHUNK_PATH) == ADAPTER.TARGET_CHUNK_SHA256, "Frozen target chunk bytes drifted.")
	_require(ADAPTER.source_dependency_hashes_match(), "A reviewed factory/material/live-config source byte drifted.")
	_require(ADAPTER.runtime_dependency_closure_exists(), "The package-safe executable dependency closure is incomplete.")
	_require(_authority_remains_uncredited(), "Accepted authority is not exact v8 at 8/213 with 1441 still unaccepted and placeholder-owned.")
	_require(_record_authority_matches(wall, roof), "The full canonical/runtime/projection row pins drifted.")
	_require(_adversarial_pair_contract(chunk, wall, roof), "Missing/duplicate/moved/drifted/third-member pair mutation was not rejected.")
	_require(_builder_rejects_partial_pair(chunk, WALL_KEY) and _builder_rejects_partial_pair(chunk, ROOF_KEY), "Canonical builder did not reject a partial target pair before construction.")

	var first := _build_pair(chunk, false)
	_require(bool(first.get("ok", false)), str(first.get("message", "First paired build failed.")))
	var first_signature := ""
	if bool(first.get("ok", false)):
		var host := first.host as Node3D
		root.add_child(host)
		await physics_frame
		await physics_frame
		var wall_root := first.wall as Node3D
		var roof_root := first.roof as Node3D
		_require(_live_node_contract_matches(wall_root, roof_root, wall), "Direct live node/material/collision/protected-scope contract drifted.")
		_require(_old_roof_render_winding_is_rejected(roof_root), "The historical backface-culled roof winding mutation was not rejected.")
		_require(_collision_and_spray_rays_match(wall_root, roof_root, wall), "Direct wall/roof solid and spray ray ownership drifted.")
		first_signature = _live_snapshot(wall_root, roof_root).sha256_text()
		host.queue_free()
		await process_frame

	var second := _build_pair(chunk, true)
	_require(bool(second.get("ok", false)), str(second.get("message", "Reverse-order paired build failed.")))
	if bool(second.get("ok", false)):
		var second_host := second.host as Node3D
		var second_signature := _live_snapshot(second.wall as Node3D, second.roof as Node3D).sha256_text()
		_require(not first_signature.is_empty() and first_signature == second_signature, "Reviewed pair build is not deterministic across source order.")
		second_host.free()

	_require(_unconsumed_plan_frees(chunk), "Unconsumed pair plan did not clear both result owners.")
	_require(_canonical_builder_stages_exact_pair(chunk, wall), "Canonical chunk builder did not replace the exact pair once without generic stack.")
	await _ordinary_main_contract(wall)
	_finish()


func _record_authority_matches(wall: Dictionary, roof: Dictionary) -> bool:
	return not wall.is_empty() and not roof.is_empty() \
		and ADAPTER.canonical_record_signature(wall) == ADAPTER.CANONICAL_WALL_RECORD_SHA256 \
		and ADAPTER.canonical_record_signature(roof) == ADAPTER.CANONICAL_ROOF_RECORD_SHA256 \
		and ADAPTER.record_signature(wall) == ADAPTER.EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256 \
		and ADAPTER.record_signature(roof) == ADAPTER.EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256 \
		and ADAPTER.PROTOTYPE.record_signature(wall) == ADAPTER.EXPECTED_WALL_PROJECTION_SHA256 \
		and ADAPTER.PROTOTYPE.record_signature(roof) == ADAPTER.EXPECTED_ROOF_PROJECTION_SHA256


func _authority_remains_uncredited() -> bool:
	var registry := _json(REGISTRY_PATH)
	var catalog := _json(CATALOG_PATH)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted := metric.get("accepted_physical_unit_ids", []) as Array
	var registry_unit := _unit_for(registry.get("units", []) as Array, "physical-building:w95934105")
	var catalog_unit := _unit_for(catalog.get("units", []) as Array, "physical-building:w95934105")
	return str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/8" \
		and int(metric.get("numerator", -1)) == 8 and int(metric.get("denominator", -1)) == 213 \
		and str(metric.get("display", "")) == "8/213" and accepted.size() == 8 \
		and "physical-building:w95934105" not in accepted \
		and registry_unit.get("active_runtime_adapter_ids", []) == [] \
		and str(registry_unit.get("runtime_content_mode", "")) == "all_receivers_generated_placeholder" \
		and str((registry_unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "not_evaluated" \
		and (registry_unit.get("acceptance_records", []) as Array).is_empty() \
		and str((catalog_unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "not_evaluated" \
		and (catalog_unit.get("acceptance_records", []) as Array).is_empty()


func _adversarial_pair_contract(chunk: Dictionary, wall: Dictionary, roof: Dictionary) -> bool:
	var clean := ADAPTER.prepare_chunk_records(chunk)
	if not bool(clean.get("ok", false)) or not bool(clean.get("contains_target", false)):
		return false
	var reversed := chunk.duplicate(true)
	(reversed.records as Array).reverse()
	if not bool(ADAPTER.prepare_chunk_records(reversed).get("ok", false)):
		return false
	var absent_other_chunk := {"chunk_id": "x_9__z_9", "records": []}
	if not bool(ADAPTER.prepare_chunk_records(absent_other_chunk).get("ok", false)) \
	or bool(ADAPTER.prepare_chunk_records({"chunk_id": ADAPTER.TARGET_CHUNK_ID, "records": []}).get("ok", true)):
		return false
	var missing_wall := _without_key(chunk, WALL_KEY)
	var missing_roof := _without_key(chunk, ROOF_KEY)
	var duplicate := chunk.duplicate(true)
	(duplicate.records as Array).append(wall.duplicate(true))
	var moved := chunk.duplicate(true)
	moved.chunk_id = "x_0__z_0"
	var third_membership := chunk.duplicate(true)
	var third := wall.duplicate(true)
	third.object_key = "building:w95934105:unexpected"
	(third_membership.records as Array).append(third)
	for invalid: Dictionary in [missing_wall, missing_roof, duplicate, moved, third_membership]:
		if bool(ADAPTER.prepare_chunk_records(invalid).get("ok", true)):
			return false
	var wall_mutations := [
		{"field": "material_key", "value": "building_roof"},
		{"field": "receiver_kind", "value": "none"},
		{"field": "collision_kind", "value": "none"},
		{"field": "opaque", "value": false},
		{"field": "source_keys", "value": ["w95934144"]},
		{"field": "exterior_foundation_segments", "value": 15},
		{"field": "shared_wall_segments", "value": 1},
	]
	for mutation: Dictionary in wall_mutations:
		var changed := wall.duplicate(true)
		changed[mutation.field] = mutation.value
		if bool(ADAPTER.prepare_chunk_records(_with_record(chunk, WALL_KEY, changed)).get("ok", true)):
			return false
	var moved_vertex := wall.duplicate(true)
	(moved_vertex.vertices as Array)[0] = float((moved_vertex.vertices as Array)[0]) + 0.001
	var extra_field := wall.duplicate(true)
	extra_field["unexpected_live_field"] = true
	var changed_roof := roof.duplicate(true)
	changed_roof.material_key = "building_wall"
	for changed_record: Dictionary in [moved_vertex, extra_field]:
		if bool(ADAPTER.prepare_chunk_records(_with_record(chunk, WALL_KEY, changed_record)).get("ok", true)):
			return false
	return not bool(ADAPTER.prepare_chunk_records(_with_record(chunk, ROOF_KEY, changed_roof)).get("ok", true))


func _build_pair(chunk: Dictionary, reverse_order: bool) -> Dictionary:
	var prepared := ADAPTER.prepare_chunk_records(chunk)
	var plan := ADAPTER.build_chunk_plan(prepared)
	if not bool(plan.get("ok", false)):
		return plan
	var targets: Array = []
	for value: Variant in chunk.records as Array:
		var record := value as Dictionary
		if ADAPTER.claims_record(record):
			targets.append(record)
	if reverse_order:
		targets.reverse()
	var host := Node3D.new()
	for record: Dictionary in targets:
		var result := ADAPTER.consume_record(record, plan)
		if not bool(result.get("ok", false)):
			host.free()
			ADAPTER.free_unconsumed(plan)
			return result
		host.add_child(result.node as Node3D)
	if not ADAPTER.plan_was_fully_consumed(plan) or host.get_child_count() != 2:
		host.free()
		ADAPTER.free_unconsumed(plan)
		return {"ok": false, "message": "Pair results were not consumed exactly once."}
	if bool(ADAPTER.consume_record(targets[0] as Dictionary, plan).get("ok", true)):
		host.free()
		return {"ok": false, "message": "Pair plan allowed duplicate consumption."}
	var wall_root := _child_with_key(host, WALL_KEY)
	var roof_root := _child_with_key(host, ROOF_KEY)
	if wall_root == null or roof_root == null:
		host.free()
		return {"ok": false, "message": "Pair results lost wall/roof identity."}
	return {"ok": true, "host": host, "wall": wall_root, "roof": roof_root}


func _unconsumed_plan_frees(chunk: Dictionary) -> bool:
	var plan := ADAPTER.build_chunk_plan(ADAPTER.prepare_chunk_records(chunk))
	if not bool(plan.get("ok", false)) or (plan.get("records", {}) as Dictionary).size() != 2:
		return false
	ADAPTER.free_unconsumed(plan)
	return (plan.get("records", {}) as Dictionary).is_empty() \
		and (plan.get("pending_keys", {}) as Dictionary).is_empty()


func _canonical_builder_stages_exact_pair(chunk: Dictionary, wall_record: Dictionary) -> bool:
	var parents := {"ground": Node3D.new(), "roads": Node3D.new(), "buildings": Node3D.new()}
	var result := WorldChunkBuilder.new().build_chunk(chunk, parents)
	var matches := false
	if bool(result.get("ok", false)):
		var staging := result.node as Node3D
		var walls := _record_roots(staging, WALL_KEY)
		var roofs := _record_roots(staging, ROOF_KEY)
		matches = walls.size() == 1 and roofs.size() == 1 \
			and _live_node_contract_matches(walls[0], roofs[0], wall_record) \
			and walls[0].get_node_or_null("Mesh") == null and roofs[0].get_node_or_null("Mesh") == null \
			and bool((result.get("source_keys", {}) as Dictionary).get(SOURCE_KEY, false))
		staging.free()
	for parent: Node3D in parents.values():
		parent.free()
	return matches


func _builder_rejects_partial_pair(chunk: Dictionary, removed_key: String) -> bool:
	var invalid := _without_key(chunk, removed_key)
	var parents := {"ground": Node3D.new(), "roads": Node3D.new(), "buildings": Node3D.new()}
	var result := WorldChunkBuilder.new().build_chunk(invalid, parents)
	for parent: Node3D in parents.values():
		parent.free()
	return not bool(result.get("ok", true)) and not result.has("node") \
		and str(result.get("code", "")).begins_with("d2_1441_live_")


func _ordinary_main_contract(wall_record: Dictionary) -> void:
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Ordinary main scene did not load."):
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var ready: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 45000:
		await process_frame
	if not _require(failures.is_empty() and ready.size() == 1, "Ordinary main failed to reach one world_ready: %s" % [failures]):
		main.queue_free()
		await process_frame
		return
	var evidence := world.get_runtime_evidence()
	var actual := {"rows": evidence.playable_rows, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "bodies": evidence.static_bodies, "shapes": evidence.shapes}
	var walls := _record_roots(world, WALL_KEY)
	var roofs := _record_roots(world, ROOF_KEY)
	_require(actual == EXPECTED_WORLD, "Ordinary main topology is not the uncredited 735/959/974/69252/466/466 candidate: %s" % actual)
	_require(walls.size() == 1 and roofs.size() == 1, "Ordinary main did not contain one exact live wall and roof root.")
	if walls.size() == 1 and roofs.size() == 1:
		_require(_live_node_contract_matches(walls[0], roofs[0], wall_record), "Ordinary main live pair contract drifted.")
		_require(_collision_and_spray_rays_match(walls[0], roofs[0], wall_record), "Ordinary main collision/spray ownership drifted.")
	main.queue_free()
	await process_frame


func _live_node_contract_matches(wall: Node3D, roof: Node3D, wall_record: Dictionary) -> bool:
	if wall == null or roof == null \
	or wall.name != "D21441ChinookLiveWallReplacement" or roof.name != "D21441ChinookLiveRoofReplacement" \
	or wall.get_node_or_null("Mesh") != null or roof.get_node_or_null("Mesh") != null \
	or wall.get_node_or_null(ADAPTER.ROOF_MESH_NAME) != null or roof.get_node_or_null(ADAPTER.ROOF_MESH_NAME) == null:
		return false
	var wall_measure := _measure(wall)
	var roof_measure := _measure(roof)
	var wall_body := wall.get_node_or_null("Collision") as StaticBody3D
	var roof_body := roof.get_node_or_null("Collision") as StaticBody3D
	var wall_shape := wall.get_node_or_null("Collision/Shape") as CollisionShape3D
	var roof_shape := roof.get_node_or_null("Collision/Shape") as CollisionShape3D
	if wall_measure != {"meshes": 8, "surfaces": 8, "triangles": 1568, "bodies": 1, "shapes": 1} \
	or roof_measure != {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1} \
	or wall_body == null or roof_body == null or wall_shape == null or roof_shape == null \
	or not (wall_shape.shape is ConcavePolygonShape3D) or not (roof_shape.shape is ConcavePolygonShape3D):
		return false
	var wall_faces := (wall_shape.shape as ConcavePolygonShape3D).get_faces()
	var roof_faces := (roof_shape.shape as ConcavePolygonShape3D).get_faces()
	var meta := wall.get_meta("d2_1441_chinook_live_replacement", {}) as Dictionary
	var relief_triangles := 0
	for node: Node in wall.find_children("*", "MeshInstance3D", true, false):
		var instance := node as MeshInstance3D
		if instance.name not in ADAPTER.SOURCE_WALL_MESH_NAMES:
			relief_triangles += int(instance.mesh.get_faces().size() / 3)
		if bool(instance.get_meta("prototype_only", true)) or not bool(instance.get_meta("runtime_attachment", false)):
			return false
	return wall_faces.size() == 96 and roof_faces.size() == 30 \
		and _face_signature(wall_faces) == _expected_wall_face_signature(wall_record) \
		and relief_triangles == ADAPTER.EXPECTED_DECORATIVE_TRIANGLES \
		and wall_body.collision_layer == (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) \
		and roof_body.collision_layer == (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) \
		and wall_body.collision_mask == 0 and roof_body.collision_mask == 0 \
		and wall_body.is_in_group("spray_receiver_wall") and not roof_body.is_in_group("spray_receiver_wall") \
		and str(wall_body.get_meta("receiver_kind", "")) == "building_wall" \
		and str(roof_body.get_meta("receiver_kind", "invalid")) == "none" \
		and bool(roof_body.get_meta("roof_landing_world_solid", false)) \
		and str(meta.get("geometry_signature", "")) == ADAPTER.EXPECTED_GEOMETRY_SIGNATURE \
		and str(meta.get("live_ownership_signature", "")) == ADAPTER.EXPECTED_LIVE_OWNERSHIP_SIGNATURE \
		and str(meta.get("accepted_authority_schema", "")) == "ti.facade-runtime-registry/8" \
		and str(meta.get("accepted_recognition_metric", "")) == "8/213" \
		and int(meta.get("candidate_recognition_credit", -1)) == 0 \
		and not bool(meta.get("recognition_accepted", true)) and not bool(meta.get("believability_accepted", true)) \
		and not bool(meta.get("fallback_allowed", true)) and not bool(meta.get("partial_pair_allowed", true)) and not bool(meta.get("stack_allowed", true)) \
		and not wall.has_meta("config_path") and not wall.has_meta("deterministic_signature") \
		and wall.find_children("*", "NavigationRegion3D", true, false).is_empty() \
		and wall.find_children("*", "Decal", true, false).is_empty() \
		and roof.find_children("*", "NavigationRegion3D", true, false).is_empty() \
		and _roof_ordered_front_and_collision_match(roof) \
		and ADAPTER.material_semantics_match(wall, roof)


func _roof_ordered_front_and_collision_match(roof: Node3D) -> bool:
	var roof_mesh := roof.get_node_or_null(ADAPTER.ROOF_MESH_NAME) as MeshInstance3D
	var roof_shape := roof.get_node_or_null("Collision/Shape") as CollisionShape3D
	if roof_mesh == null or roof_mesh.mesh == null or roof_shape == null \
	or not (roof_shape.shape is ConcavePolygonShape3D) \
	or not ADAPTER.roof_render_front_face_matches(roof_mesh):
		return false
	var visual_faces := roof_mesh.mesh.get_faces()
	var collision_faces := (roof_shape.shape as ConcavePolygonShape3D).get_faces()
	if visual_faces.size() != ADAPTER.EXPECTED_ROOF_VISUAL_TRIANGLES * 3 \
	or collision_faces.size() != visual_faces.size():
		return false
	for offset in range(0, visual_faces.size(), 3):
		for corner in 3:
			if not visual_faces[offset + corner].is_equal_approx(collision_faces[offset + corner]):
				return false
		var visual_winding := (visual_faces[offset + 1] - visual_faces[offset]).cross(visual_faces[offset + 2] - visual_faces[offset]).normalized()
		var collision_winding := (collision_faces[offset + 1] - collision_faces[offset]).cross(collision_faces[offset + 2] - collision_faces[offset]).normalized()
		if visual_winding.y >= -0.4 or collision_winding.y >= -0.4:
			return false
	return true


func _old_roof_render_winding_is_rejected(roof: Node3D) -> bool:
	var roof_mesh := roof.get_node_or_null(ADAPTER.ROOF_MESH_NAME) as MeshInstance3D
	if roof_mesh == null or roof_mesh.mesh == null or roof_mesh.mesh.get_surface_count() != 1:
		return false
	var arrays := roof_mesh.mesh.surface_get_arrays(0)
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	for offset in range(0, indices.size(), 3):
		var swap := indices[offset + 1]
		indices[offset + 1] = indices[offset + 2]
		indices[offset + 2] = swap
	arrays[Mesh.ARRAY_INDEX] = indices
	var historical := ArrayMesh.new()
	historical.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	historical.surface_set_material(0, roof_mesh.mesh.surface_get_material(0))
	var historical_instance := MeshInstance3D.new()
	historical_instance.mesh = historical
	var rejected := not ADAPTER.roof_render_front_face_matches(historical_instance)
	historical_instance.free()
	return rejected


func _collision_and_spray_rays_match(wall_root: Node3D, roof_root: Node3D, wall_record: Dictionary) -> bool:
	var offset := 10 * 12
	var values := wall_record.vertices as Array
	var normals := wall_record.normals as Array
	var bottom := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var top_far := Vector3(float(values[offset + 6]), float(values[offset + 7]), float(values[offset + 8]))
	var wall_point := (bottom + top_far) * 0.5
	var outward := Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()
	var wall_body := wall_root.get_node("Collision") as StaticBody3D
	var roof_body := roof_root.get_node("Collision") as StaticBody3D
	var space := wall_root.get_world_3d().direct_space_state
	var wall_solid := space.intersect_ray(PhysicsRayQueryParameters3D.create(wall_point + outward * 3.0, wall_point - outward * 1.0, PHYSICS_WORLD_SOLID))
	var wall_spray := space.intersect_ray(PhysicsRayQueryParameters3D.create(wall_point + outward * 3.0, wall_point - outward * 1.0, PHYSICS_SPRAY_SURFACE))
	var roof_mesh := roof_root.get_node(ADAPTER.ROOF_MESH_NAME) as MeshInstance3D
	var roof_faces := roof_mesh.mesh.get_faces()
	var roof_point := (roof_faces[0] + roof_faces[1] + roof_faces[2]) / 3.0
	roof_point = roof_mesh.to_global(roof_point)
	var roof_solid := space.intersect_ray(PhysicsRayQueryParameters3D.create(roof_point + Vector3.UP * 3.0, roof_point - Vector3.UP * 1.0, PHYSICS_WORLD_SOLID))
	var roof_spray := space.intersect_ray(PhysicsRayQueryParameters3D.create(roof_point + Vector3.UP * 3.0, roof_point - Vector3.UP * 1.0, PHYSICS_SPRAY_SURFACE))
	if wall_solid.is_empty() or wall_spray.is_empty() or roof_solid.is_empty() or roof_spray.is_empty() \
	or wall_solid.get("collider") != wall_body or wall_spray.get("collider") != wall_body \
	or roof_solid.get("collider") != roof_body or roof_spray.get("collider") != roof_body:
		print("D2_1441_RAY_DIAGNOSTIC: wall_point=%s outward=%s wall_solid=%s wall_spray=%s roof_point=%s roof_solid=%s roof_spray=%s" % [wall_point, outward, wall_solid, wall_spray, roof_point, roof_solid, roof_spray])
	return not wall_solid.is_empty() and wall_solid.collider == wall_body \
		and not wall_spray.is_empty() and wall_spray.collider == wall_body \
		and absf((wall_spray.normal as Vector3).y) < 0.2 \
		and not roof_solid.is_empty() and roof_solid.collider == roof_body \
		and not roof_spray.is_empty() and roof_spray.collider == roof_body \
		and (roof_spray.normal as Vector3).y > 0.4 \
		and str(roof_body.get_meta("receiver_kind", "invalid")) == "none" \
		and not roof_body.is_in_group("spray_receiver_wall")


func _live_snapshot(wall: Node3D, roof: Node3D) -> String:
	var paths: Array[String] = []
	for root_node: Node3D in [wall, roof]:
		for node: Node in root_node.find_children("*", "MeshInstance3D", true, false):
			var instance := node as MeshInstance3D
			paths.append("%s|%s|%d" % [instance.name, instance.mesh.surface_get_material(0).resource_path, instance.mesh.get_faces().size() / 3])
	paths.sort()
	return JSON.stringify({"ownership": ADAPTER.live_ownership_signature(), "wall": _measure(wall), "roof": _measure(roof), "meshes": paths})


func _measure(root_node: Node) -> Dictionary:
	var result := {"meshes": 0, "surfaces": 0, "triangles": 0, "bodies": 0, "shapes": 0}
	for node: Node in _all_nodes(root_node):
		if node is MeshInstance3D:
			result.meshes += 1
			var mesh := (node as MeshInstance3D).mesh
			result.surfaces += mesh.get_surface_count()
			result.triangles += int(mesh.get_faces().size() / 3)
		elif node is StaticBody3D:
			result.bodies += 1
		elif node is CollisionShape3D:
			result.shapes += 1
	return result


func _expected_wall_face_signature(record: Dictionary) -> String:
	var values := record.vertices as Array
	var indices := record.indices as Array
	var faces := PackedVector3Array()
	for offset in range(0, indices.size(), 3):
		for source_offset: int in [0, 2, 1]:
			var index := int(indices[offset + source_offset]) * 3
			faces.append(Vector3(float(values[index]), float(values[index + 1]), float(values[index + 2])))
	return _face_signature(faces)


func _face_signature(faces: PackedVector3Array) -> String:
	var triangles: Array[String] = []
	for offset in range(0, faces.size(), 3):
		var points: Array[String] = []
		for corner in 3:
			var point := faces[offset + corner]
			points.append("%.5f|%.5f|%.5f" % [point.x, point.y, point.z])
		points.sort()
		triangles.append("/".join(points))
	triangles.sort()
	return "\n".join(triangles).sha256_text()


func _record_roots(root_node: Node, object_key: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if node.has_meta("feature_kind") and str(node.get_meta("derived_object_key", "")) == object_key:
			result.append(node as Node3D)
	return result


func _all_nodes(root_node: Node) -> Array[Node]:
	var result: Array[Node] = [root_node]
	for child: Node in root_node.get_children():
		result.append_array(_all_nodes(child))
	return result


func _child_with_key(root_node: Node, object_key: String) -> Node3D:
	for child: Node in root_node.get_children():
		if str(child.get_meta("derived_object_key", "")) == object_key:
			return child as Node3D
	return null


func _unit_for(units: Array, unit_id: String) -> Dictionary:
	for value: Variant in units:
		var unit := value as Dictionary
		if str(unit.get("unit_id", "")) == unit_id:
			return unit
	return {}


func _without_key(chunk: Dictionary, object_key: String) -> Dictionary:
	var changed := chunk.duplicate(true)
	var filtered: Array = []
	for value: Variant in changed.records as Array:
		if str((value as Dictionary).get("object_key", "")) != object_key:
			filtered.append(value)
	changed.records = filtered
	return changed


func _with_record(chunk: Dictionary, object_key: String, replacement: Dictionary) -> Dictionary:
	var changed := chunk.duplicate(true)
	var records := changed.records as Array
	for index in records.size():
		if str((records[index] as Dictionary).get("object_key", "")) == object_key:
			records[index] = replacement
			break
	return changed


func _record_for_key(records: Array, object_key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == object_key:
			return record
	return {}


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failures.append(message)
	push_error("D2_1441_LIVE_FAIL: %s" % message)
	return false


func _finish() -> void:
	if _failures.is_empty():
		print("D2_1441_LIVE_TOPOLOGY: accepted_authority=v8:8/213 uncredited_candidate=735/959/974/69252/466/466 delta_from_b225=+0/+7/+7/+1536/+0/+0")
		print("PASS: exact supplied 1441 Chinook wall+roof pair is factory-built once and consumed once without fallback/stack; reviewed 9/9/1578 art is split 8+1, exact collision is split 32 wall-spray + 10 roof-blocking/landing, relief remains noncolliding, ordinary main is live, and authority remains v8 at 8/213 with zero candidate credit")
		quit(0)
	else:
		push_error("D2_1441_LIVE_FAILURES: %s" % [_failures])
		quit(1)
