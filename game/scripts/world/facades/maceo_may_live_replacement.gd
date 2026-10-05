class_name MaceoMayLiveReplacement
extends RefCounted

## Atomic supplied source pair with reviewed Maceo May study001 with bounded curtain union repair.
## Only receiver ownership and collision partition change at attachment.
const FACTORY := preload("res://game/scripts/world/facades/maceo_may_live_factory.gd")
const ADAPTER_ID := "active-adapter:maceo-may-live:building:r19685981:wall"
const SOURCE_KEY := "r19685981"
const WALL_KEY := "building:r19685981:wall"
const ROOF_KEY := "building:r19685981:roof"
const TARGET_CHUNK_ID := "x_-1__z_1"
const WALL_MESHES := ["ProtectedExactNeutralWallRuns", "ObservedENESSEWallFields"]
const ROOF_MESHES := ["ExactSourceNeutralRoof"]
const ACCEPTED_BATCHES := ["ProtectedExactNeutralWallRuns", "ObservedENESSEWallFields", "ExactSourceNeutralRoof", "PaleCompleteENEFrames", "GraphiteRecessAndMullions", "OpaqueBlueGrayGlazing", "GraphiteLouvers", "RustCompleteSSEFrames", "PaleSmallVentFrames", "RustEntryPanels", "PaleRoundEntranceColumns"]
const SOURCE_DEPENDENCIES := ["res://game/resources/facades/maceo_may_quality_study.json", "res://game/resources/facades/maceo_may_study_geometry.json", "res://game/resources/facades/maceo_may_public_fields.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd", "res://game/scripts/world/facades/maceo_may_live_factory.gd"]
static func claims_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in [WALL_KEY, ROOF_KEY]

static func prepare_chunk_records(chunk:Dictionary) -> Dictionary:
	if not (chunk.get("records",null) is Array):return _failure("maceo_may_chunk_records","Missing supplied records.",{})
	var relevant:Dictionary={}
	for value:Variant in chunk.records:
		if not value is Dictionary:continue
		var record:Dictionary=value
		var key:=str(record.get("object_key",""))
		var sources:Variant=record.get("source_keys",[])
		if claims_record(record) or (sources is Array and SOURCE_KEY in sources):
			if not claims_record(record):return _failure("maceo_may_source_alias","Unexpected target source alias.",record)
			if relevant.has(key):return _failure("maceo_may_duplicate_record","Duplicate target pair member.",record)
			relevant[key]=record
	if relevant.is_empty() and str(chunk.get("chunk_id",""))!=TARGET_CHUNK_ID:return {"ok":true,"contains_target":false}
	if str(chunk.get("chunk_id",""))!=TARGET_CHUNK_ID or not _records_match(relevant):return _failure("maceo_may_pair","Exact supplied wall and roof required in their source chunk.",{})
	return {"ok":true,"contains_target":true,"source_records":relevant}

static func _records_match(records: Dictionary) -> bool:
	if records.size() != 2: return false
	return FACTORY.matches_record_pair(records.get(WALL_KEY, {}), records.get(ROOF_KEY, {}))

static func build_chunk_plan(prepared: Dictionary, source_builder:Callable,tangent_builder:Callable) -> Dictionary:
	if not bool(prepared.get("ok", false)): return prepared
	if not bool(prepared.get("contains_target", false)): return {"ok":true,"contains_target":false,"records":{},"pending_keys":{}}
	var records := prepared.get("source_records", {}) as Dictionary
	if not _records_match(records): return _failure("maceo_may_prepared_pair", "Prepared wall and roof pair required.", {})
	if not runtime_dependency_closure_exists(): return _failure("maceo_may_config", "Live factory or config dependency is missing.", {})
	var result := _build_pair(records,source_builder,tangent_builder)
	if not bool(result.get("ok", false)): return result
	return {"ok":true,"contains_target":true,"records":{WALL_KEY:result.wall_result,ROOF_KEY:result.roof_result},"pending_keys":{WALL_KEY:true,ROOF_KEY:true}}

static func consume_record(record: Dictionary, plan: Dictionary) -> Dictionary:
	var key := str(record.get("object_key", ""))
	if not claims_record(record) or not bool(plan.get("ok", false)) or not bool(plan.get("contains_target", false)):
		return _failure("maceo_may_unprepared", "Validated supplied plan required.", record)
	var pending := plan.get("pending_keys", {}) as Dictionary
	var results := plan.get("records", {}) as Dictionary
	if not pending.has(key) or not results.has(key): return _failure("maceo_may_duplicate_consume", "Pair member missing or consumed twice.", record)
	var result := results[key] as Dictionary
	pending.erase(key); results.erase(key)
	return result

static func _build_pair(records:Dictionary, source_builder:Callable,tangent_builder:Callable) -> Dictionary:
	var built := FACTORY.build_for_records(records[WALL_KEY], records[ROOF_KEY], source_builder,tangent_builder)
	if not bool(built.get("ok",false)):return _failure("maceo_may_factory",str(built.get("message","Factory failed.")),records[WALL_KEY])
	var wall_root:=built.node as Node3D
	if not _factory_contract_matches(wall_root,records):
		wall_root.free();return _failure("maceo_may_factory_contract","Accepted batches or ordered structure changed.",records[WALL_KEY])
	var original:=wall_root.get_node("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	var roof_root:=Node3D.new();var roof_body:=StaticBody3D.new();roof_body.name="Collision"
	for label:String in ROOF_MESHES:
		var mesh:=wall_root.get_node(label) as MeshInstance3D;wall_root.remove_child(mesh);roof_root.add_child(mesh)
	for label:String in ["ExactSourceNeutralRoof"]:
		var shape:=original.get_node(label) as CollisionShape3D;original.remove_child(shape);roof_body.add_child(shape);_configure_shape(shape,ROOF_KEY,"none")
	roof_root.add_child(roof_body);original.name="Collision"
	_configure_body(original,WALL_KEY,true);_configure_body(roof_body,ROOF_KEY,false)
	for index in original.get_child_count():_configure_shape(original.get_child(index) as CollisionShape3D,WALL_KEY,"building_wall" if index==0 else "none")
	_apply_metadata(wall_root,roof_root)
	var meta:Dictionary={"adapter_id":ADAPTER_ID,"factory_calls":1,"partial_pair_allowed":false,"fallback_allowed":false,"stack_allowed":false,"mapped_public_run_indices":FACTORY.TARGET_RUNS.duplicate(),"protected_run_indices":FACTORY.PROTECTED_RUNS.duplicate(),"all_additions_render_only":false,"source_collision_only":false,"added_collision_scope":"Five unchanged visible round columns, separate nonreceiver shape"}
	for root:Node3D in [wall_root,roof_root]:root.set_meta("maceo_may_live_replacement",meta.duplicate(true))
	return {"ok":true,"wall_result":{"ok":true,"node":wall_root,"metadata":meta,"mesh_instances":10,"surfaces":10,"triangles":16420,"static_bodies":1,"shapes":2},"roof_result":{"ok":true,"node":roof_root,"metadata":meta,"mesh_instances":1,"surfaces":1,"triangles":16,"static_bodies":1,"shapes":1}}

static func _factory_contract_matches(root:Node3D,records:Dictionary) -> bool:
	var seen:Dictionary={}
	for child:Node in root.get_children():
		if child is MeshInstance3D:
			var mesh:Mesh=child.mesh
			if not ACCEPTED_BATCHES.has(str(child.name)) or mesh==null or mesh.get_surface_count()!=1:return false
			seen[str(child.name)]=true
	var body:=root.get_node_or_null("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	if seen.size()!=ACCEPTED_BATCHES.size() or body==null or body.get_child_count()!=3 or body.collision_layer!=1 or body.collision_mask!=0:return false
	var labels: Array=["ExactClosedSourceWalls","ExactSourceNeutralRoof","EntranceColumnRelief"]
	var groups:Array=[WALL_MESHES,["ExactSourceNeutralRoof"],["PaleRoundEntranceColumns"]]
	for index in 3:
		var node:=body.get_child(index) as CollisionShape3D
		if node==null or str(node.name)!=str(labels[index]) or not node.shape is ConcavePolygonShape3D:return false
		var faces:PackedVector3Array=node.shape.get_faces()
		if faces.is_empty() or str(node.shape.get_meta("receiver_kind",""))!="none":return false
		if _oriented_face_signature(faces)!=_mesh_oriented_face_signature(root,groups[index]):return false
		var ordered:PackedVector3Array=_source_collision_faces(records[WALL_KEY if index==0 else ROOF_KEY]) if index<2 else _mesh_faces(root,groups[index])
		if var_to_bytes(faces)!=var_to_bytes(ordered):return false
	return true

static func _source_collision_faces(record:Dictionary) -> PackedVector3Array:
	var vertices:=PackedVector3Array()
	for offset in range(0,record.vertices.size(),3):vertices.append(Vector3(float(record.vertices[offset]),float(record.vertices[offset+1]),float(record.vertices[offset+2])))
	var faces:=PackedVector3Array()
	for offset in range(0,record.indices.size(),3):
		for local in [0,2,1]:faces.append(vertices[int(record.indices[offset+local])])
	return faces

static func _mesh_faces(root:Node,names:Array) -> PackedVector3Array:
	var faces:=PackedVector3Array()
	for label:String in names:
		var instance:MeshInstance3D=root.get_node(label) as MeshInstance3D
		var arrays:Array=instance.mesh.surface_get_arrays(0)
		var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
		for index:int in arrays[Mesh.ARRAY_INDEX]:faces.append(vertices[index])
	return faces

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
	wall_root.name="MaceoMayLiveWallReplacement";roof_root.name="MaceoMayLiveRoofReplacement"
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

static func _oriented_face_signature(faces:PackedVector3Array) -> String:
	if faces.size()%3!=0:return ""
	var triangles:Array[String]=[]
	for offset in range(0,faces.size(),3):triangles.append(var_to_bytes(faces.slice(offset,offset+3)).hex_encode())
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
