class_name D51394GateviewLiveReplacement
extends RefCounted

## One supplied wall/roof pair with its frozen local grade, translated once.
## Accepted revision003 geometry/materials remain unchanged. Only ownership,
## decal layers and the factory input boundary change in this live candidate.
const FACTORY := preload("res://game/scripts/world/facades/d5_1394_gateview_live_factory.gd")
const ADAPTER_ID := "active-adapter:d5-1394-live:building:w96215646:wall"
const SOURCE_KEY := "w96215646"
const WALL_KEY := "building:w96215646:wall"
const ROOF_KEY := "building:w96215646:roof"
const LAND_KEY := "land:w26767313:x_-2__z_-3"
const AREA_KEY := "area:r17241151:x_-2__z_-3"
const TARGET_CHUNK_ID := "x_-2__z_-3"
const WALL_MESHES := ["ProtectedExactNeutralWallRuns", "ObservedWHorizontalSidingFields"]
const ROOF_MESH := "ExactSourceNeutralRoof"
const STRUCTURE_MESHES := ["ContinuousFlatCanopyRoof", "ContinuousFlatCanopyFasciaAndSoffit", "RealCanopyFrontSupports"]
const GROUND_MESHES := ["GroundClosedDoors", "GroundOpaqueWindowGlass", "GroundModuleFrames", "GroundDoorHandles", "ProjectedSlattedPrivacyScreens"]
const ACCEPTED_BATCHES := ["ContinuousFlatCanopyFasciaAndSoffit", "ContinuousFlatCanopyRoof", "ExactSourceNeutralRoof", "GroundClosedDoors", "ProjectedSlattedPrivacyScreens", "LocalParkingAsphalt", "LocalWalkAndDoorApproaches", "LocalLawn", "GroundDoorHandles", "GroundModuleFrames", "GroundOpaqueWindowGlass", "ObservedWHorizontalSidingFields", "ProtectedExactNeutralWallRuns", "RealCanopyFrontSupports", "RepeatedOpaqueUpperSliders", "RestrainedRealWindowAndCanopyTrim"]
const SOURCE_RECORD_KEYS := FACTORY.SOURCE_RECORD_KEYS
const SOURCE_DEPENDENCIES := ["res://game/resources/facades/d5_1394_gateview_live_factory.json", "res://game/resources/facades/d5_1394_siding_marks.gdshader", "res://game/scripts/world/facades/d5_1394_gateview_live_factory.gd", "res://game/scripts/world/facades/site_12_housing_kit.gd", "res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_diff_1k.jpg", "res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_rough_1k.jpg", "res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_diff_1k.jpg", "res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_rough_1k.jpg", "res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_diff_1k.jpg", "res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_rough_1k.jpg", "res://game/resources/facades/d5_1394_lawn_tone.gdshader"]

static func claims_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in [WALL_KEY, ROOF_KEY]

static func prepare_chunk_records(chunk: Dictionary) -> Dictionary:
	if not (chunk.get("records", null) is Array):
		return _failure("d5_1394_chunk_records", "Missing supplied records.", {})
	var relevant: Dictionary = {}
	var target_count := 0
	for value: Variant in chunk.records:
		if not (value is Dictionary): continue
		var record := value as Dictionary
		var key := str(record.get("object_key", ""))
		var sources: Variant = record.get("source_keys", [])
		if claims_record(record) or (sources is Array and SOURCE_KEY in sources):
			target_count += 1
			if not claims_record(record):
				return _failure("d5_1394_source_alias", "Unexpected supplied target source alias.", record)
		if SOURCE_RECORD_KEYS.has(key):
			if relevant.has(key): return _failure("d5_1394_duplicate_record", "Duplicate pair or local grade record.", record)
			relevant[key] = record
	if target_count == 0 and str(chunk.get("chunk_id", "")) != TARGET_CHUNK_ID:
		return {"ok":true,"contains_target":false}
	if str(chunk.get("chunk_id", "")) != TARGET_CHUNK_ID or target_count != 2 or not _records_match(relevant):
		return _failure("d5_1394_pair_or_grade", "The exact supplied wall, roof, land and area are required.", {})
	return {"ok":true,"contains_target":true,"source_records":relevant}

static func _records_match(records: Dictionary) -> bool:
	if records.size() != 4: return false
	for key: String in SOURCE_RECORD_KEYS:
		if not (records.get(key, null) is Dictionary) or str((records[key] as Dictionary).get("object_key", "")) != key: return false
	return true

static func build_chunk_plan(prepared: Dictionary, neutral_wall: StandardMaterial3D, neutral_roof: StandardMaterial3D) -> Dictionary:
	if not bool(prepared.get("ok", false)): return prepared
	if not bool(prepared.get("contains_target", false)): return {"ok":true,"contains_target":false,"records":{},"pending_keys":{}}
	var records := prepared.get("source_records", {}) as Dictionary
	if not _records_match(records): return _failure("d5_1394_prepared_records", "Prepared pair and grade records required.", {})
	if not runtime_dependency_closure_exists(): return _failure("d5_1394_config", "Live factory or config dependency is missing.", {})
	var result := _build_pair(records, neutral_wall, neutral_roof)
	if not bool(result.get("ok", false)): return result
	return {"ok":true,"contains_target":true,"records":{WALL_KEY:result.wall_result,ROOF_KEY:result.roof_result},"pending_keys":{WALL_KEY:true,ROOF_KEY:true}}

static func consume_record(record: Dictionary, plan: Dictionary) -> Dictionary:
	var key := str(record.get("object_key", ""))
	if not claims_record(record) or not bool(plan.get("ok", false)) or not bool(plan.get("contains_target", false)):
		return _failure("d5_1394_unprepared", "Validated supplied plan required.", record)
	var pending := plan.get("pending_keys", {}) as Dictionary
	var results := plan.get("records", {}) as Dictionary
	if not pending.has(key) or not results.has(key): return _failure("d5_1394_duplicate_consume", "Pair member missing or consumed twice.", record)
	var result := results[key] as Dictionary
	pending.erase(key); results.erase(key)
	return result

static func _build_pair(records: Dictionary, neutral_wall: StandardMaterial3D, neutral_roof: StandardMaterial3D) -> Dictionary:
	var wall: Dictionary = records[WALL_KEY]
	var roof: Dictionary = records[ROOF_KEY]
	var built := FACTORY.build_for_records(wall, roof, neutral_wall, neutral_roof, records)
	if not bool(built.get("ok", false)): return _failure("d5_1394_factory", str(built.get("message", "Factory failed.")), wall)
	var wall_root := built.node as Node3D
	if not _factory_contract_matches(wall_root):
		wall_root.free(); return _failure("d5_1394_factory_contract", "Reviewed batches or ordered structure changed.", wall)
	var original := wall_root.get_node("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	var source_roof_shape := original.get_child(1) as CollisionShape3D
	original.remove_child(source_roof_shape)
	var roof_root := Node3D.new()
	var roof_mesh := wall_root.get_node(ROOF_MESH) as MeshInstance3D
	wall_root.remove_child(roof_mesh); roof_root.add_child(roof_mesh)
	var roof_body := StaticBody3D.new(); roof_body.name="Collision"
	roof_body.add_child(source_roof_shape); roof_root.add_child(roof_body)
	# Source1394 already has accepted clockwise roof order: no winding edit here.
	original.name="Collision"
	_configure_body(original, WALL_KEY, true)
	_configure_body(roof_body, ROOF_KEY, false)
	for index in original.get_child_count():
		var shape_node := original.get_child(index) as CollisionShape3D
		_configure_shape(shape_node, WALL_KEY, "building_wall" if index==0 else "none")
	_configure_shape(source_roof_shape, ROOF_KEY, "none")
	_apply_metadata(wall_root, roof_root)
	var meta := {"adapter_id":ADAPTER_ID,"factory_calls":1,"partial_pair_allowed":false,"fallback_allowed":false,"stack_allowed":false,"mapped_public_run_indices":FACTORY.TARGET_RUNS.duplicate(),"protected_run_indices":FACTORY.PROTECTED_RUNS.duplicate()}
	for root:Node3D in [wall_root,roof_root]:root.set_meta("d5_1394_gateview_live_replacement",meta.duplicate(true))
	return {"ok":true,"wall_result":{"ok":true,"node":wall_root,"metadata":meta,"mesh_instances":15,"surfaces":15,"triangles":3352,"static_bodies":1,"shapes":3},"roof_result":{"ok":true,"node":roof_root,"metadata":meta,"mesh_instances":1,"surfaces":1,"triangles":16,"static_bodies":1,"shapes":1}}

static func _factory_contract_matches(root: Node3D) -> bool:
	var seen := {}
	for child:Node in root.get_children():
		if child is MeshInstance3D:
			var mesh := (child as MeshInstance3D).mesh
			if not ACCEPTED_BATCHES.has(str(child.name)) or mesh==null or mesh.get_surface_count()!=1: return false
			seen[str(child.name)] = true
	var body := root.get_node_or_null("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	if seen.size()!=ACCEPTED_BATCHES.size() or body==null or body.get_child_count()!=4 or body.collision_layer!=1: return false
	var labels := ["ExactClosedSourceWalls","ExactSourceNeutralRoof","ContinuousFlatCanopyAndPosts","OpaqueClosedGroundModuleAssemblies"]
	var mesh_groups := [WALL_MESHES,[ROOF_MESH],STRUCTURE_MESHES,GROUND_MESHES]
	for index in 4:
		var node := body.get_child(index) as CollisionShape3D
		if node==null or str(node.name)!=str(labels[index]) or not (node.shape is ConcavePolygonShape3D): return false
		var faces := (node.shape as ConcavePolygonShape3D).get_faces()
		if faces.is_empty() or str(node.shape.get_meta("receiver_kind",""))!="none": return false
		if _oriented_face_signature(faces)!=_mesh_oriented_face_signature(root,mesh_groups[index]): return false
	return true

static func _configure_body(body: StaticBody3D, key: String, eligible: bool) -> void:
	_clear_metadata(body)
	body.collision_layer=5; body.collision_mask=0
	body.set_meta("receiver_kind","building_wall" if eligible else "none")
	body.set_meta("derived_object_key",key); body.set_meta("source_keys",[SOURCE_KEY]); body.set_meta("opaque",true)
	body.set_meta("spray_ray_blocking",true)
	if eligible:body.add_to_group("spray_receiver_wall")
	else:body.set_meta("roof_landing_world_solid",true)

static func _configure_shape(node: CollisionShape3D, key: String, receiver: String) -> void:
	# Keep exact shape and face data; only ownership metadata changes.
	var role := str(node.shape.get_meta("structural_role",node.name))
	_clear_metadata(node.shape)
	for object:Object in [node,node.shape]:
		object.set_meta("receiver_kind",receiver);object.set_meta("derived_object_key",key);object.set_meta("source_keys",[SOURCE_KEY]);object.set_meta("opaque",true);object.set_meta("structural_role",role)

static func _apply_metadata(wall_root: Node3D, roof_root: Node3D) -> void:
	wall_root.name="D51394GateviewLiveWallReplacement";roof_root.name="D51394GateviewLiveRoofReplacement"
	for root:Node3D in [wall_root,roof_root]:
		var key := WALL_KEY if root==wall_root else ROOF_KEY
		_clear_metadata(root)
		root.set_meta("derived_object_key",key);root.set_meta("source_keys",[SOURCE_KEY]);root.set_meta("feature_kind","building_wall" if root==wall_root else "building_roof");root.set_meta("receiver_kind","building_wall" if root==wall_root else "none")
		root.set_meta("adapter_id",ADAPTER_ID);root.set_meta("runtime_supersedes_generated_placeholder",true);root.set_meta("superseded_object_keys",[WALL_KEY,ROOF_KEY])
		for child:Node in root.get_children():
			if child is MeshInstance3D:
				child.layers=2 if str(child.name) in WALL_MESHES else 1
				child.set_meta("derived_object_key",key);child.set_meta("source_keys",[SOURCE_KEY])

static func _clear_metadata(object: Object) -> void:
	for key:StringName in object.get_meta_list():object.remove_meta(key)

static func runtime_dependency_closure_exists() -> bool:
	for path:String in SOURCE_DEPENDENCIES:
		if path.get_extension()=="json":
			if not FileAccess.file_exists(path):return false
		elif not ResourceLoader.exists(path) and not FileAccess.file_exists(path):return false
	return true

static func plan_was_fully_consumed(chunk_plan: Dictionary) -> bool:
	return not bool(chunk_plan.get("contains_target", false)) or (chunk_plan.get("pending_keys", {}) as Dictionary).is_empty()

static func free_unconsumed(chunk_plan: Dictionary) -> void:
	var results := chunk_plan.get("records", {}) as Dictionary
	for key: Variant in results.keys():
		var result := results[key] as Dictionary
		var node := result.get("node", null) as Node
		if node != null and not node.is_inside_tree():
			node.free()
	results.clear()
	(chunk_plan.get("pending_keys", {}) as Dictionary).clear()

static func _mesh_oriented_face_signature(root: Node, names: Array) -> String:
	var faces := PackedVector3Array()
	for name_value: Variant in names:
		var instance := root.get_node_or_null(str(name_value)) as MeshInstance3D
		if instance == null or instance.mesh == null or instance.mesh.get_surface_count() != 1:
			return ""
		var arrays := instance.mesh.surface_get_arrays(0)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		for index: int in indices:
			faces.append(vertices[index])
	return _oriented_face_signature(faces)

static func _oriented_face_signature(faces: PackedVector3Array) -> String:
	if faces.size() % 3 != 0:
		return ""
	var triangles: Array[String] = []
	for offset in range(0, faces.size(), 3):
		var points: Array[String] = []
		for corner in 3:
			var point := faces[offset + corner]
			points.append("%.5f|%.5f|%.5f" % [point.x, point.y, point.z])
		triangles.append("/".join(points))
	triangles.sort()
	return "\n".join(triangles).sha256_text()

static func _descendants(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	var pending: Array[Node] = [root]
	while not pending.is_empty():
		var current := pending.pop_back() as Node
		result.append(current)
		for child: Node in current.get_children():
			pending.append(child)
	return result

static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	var source_keys_value: Variant = record.get("source_keys", [])
	var source_keys := source_keys_value as Array if source_keys_value is Array else []
	return {"ok": false, "code": code, "message": message, "source_keys": source_keys.duplicate()}

