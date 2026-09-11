class_name FireStation48LiveReplacement
extends RefCounted

## Atomic supplied source pair with unchanged reviewed Station48 study002 construction.
## Only receiver ownership and collision partition change at attachment.
const FACTORY := preload("res://game/scripts/world/facades/fire_station48_live_factory.gd")
const CONFIG_PATH := "res://game/resources/facades/fire_station48_live_replacement.json"
const ADAPTER_ID := "active-adapter:fire-station48-live:building:w764313741:wall"
const SOURCE_KEY := "w764313741"
const WALL_KEY := "building:w764313741:wall"
const ROOF_KEY := "building:w764313741:roof"
const TARGET_CHUNK_ID := "x_0__z_-2"
const WALL_MESHES := ["ProtectedExactNeutralWallRuns", "ObservedWSWNNWPaleWallFields"]
const ROOF_MESHES := ["ExactSourceNeutralRoof"]
const EXPECTED_BATCH_TRIANGLES := {"ProtectedExactNeutralWallRuns": 32, "ObservedWSWNNWPaleWallFields": 20, "ExactSourceNeutralRoof": 10, "CompletePaleWindowSurrounds": 624, "OpaqueHighWindowGlass": 156, "ThinWindowMullions": 156, "ThinStraightPublicRoofEdge": 92}
const EXPECTED_CONFIG_SHA256 := "4b31025a80909b03b882c089bf17d50dbc6a4ee9d32fa9b072b884fd4eec061a"
const EXPECTED_FACTORY_CONFIG_SHA256 := "2ae853642ed360f81ea6dfe53089fa909531af8776f40462fb129076f16b6795"
const RECORD_HASHES := {"building:w764313741:roof": "a64186052e8331d3ee744718f19ba8dc6350da4f67c8b51f29b9469c903c89d2", "building:w764313741:wall": "0e3b5283ff9c055dc0a642d3608af13057ed6d1c87293d4b845991d9e96f9a8d"}
const SOURCE_DEPENDENCY_HASHES := {"res://game/scripts/world/facades/fire_station48_live_factory.gd": "33c945be3699fe7f94874d7a65ff0d01963092d0c0cb85deacaf4f794d9996d5", "res://game/resources/facades/fire_station48_quality_study.json": "2ae853642ed360f81ea6dfe53089fa909531af8776f40462fb129076f16b6795", "res://game/resources/facades/fire_station48_study_geometry.json": "e198f49df39671d489bb96cd553ec257df12156a0921b489f434d2c2b37d7597", "res://game/resources/facades/fire_station48_upper_cladding.gdshader": "4600d14f6d45455c56ce400cc2b073c124462eee1da0e33f7492b356614f319e", "res://game/scripts/world/facades/site_12_housing_kit.gd": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"}
static func claims_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in [WALL_KEY, ROOF_KEY]

static func prepare_chunk_records(chunk:Dictionary) -> Dictionary:
	if not (chunk.get("records",null) is Array):return _failure("fire_station48_chunk_records","Missing supplied records.",{})
	var relevant:Dictionary={}
	for value:Variant in chunk.records:
		if not value is Dictionary:continue
		var record:Dictionary=value
		var key:=str(record.get("object_key",""))
		var sources:Variant=record.get("source_keys",[])
		if claims_record(record) or (sources is Array and SOURCE_KEY in sources):
			if not claims_record(record):return _failure("fire_station48_source_alias","Unexpected target source alias.",record)
			if relevant.has(key):return _failure("fire_station48_duplicate_record","Duplicate target pair member.",record)
			relevant[key]=record
	if relevant.is_empty() and str(chunk.get("chunk_id",""))!=TARGET_CHUNK_ID:return {"ok":true,"contains_target":false}
	if str(chunk.get("chunk_id",""))!=TARGET_CHUNK_ID or not _records_match(relevant):return _failure("fire_station48_pair","Exact supplied wall and roof required in their source chunk.",{})
	return {"ok":true,"contains_target":true,"source_records":relevant}

static func _records_match(records: Dictionary) -> bool:
	if records.size() != 2: return false
	for key: String in RECORD_HASHES:
		if not (records.get(key, null) is Dictionary) or canonical_record_signature(records[key]) != str(RECORD_HASHES[key]): return false
	return true

static func build_chunk_plan(prepared: Dictionary, source_builder:Callable,tangent_builder:Callable) -> Dictionary:
	if not bool(prepared.get("ok", false)): return prepared
	if not bool(prepared.get("contains_target", false)): return {"ok":true,"contains_target":false,"records":{},"pending_keys":{}}
	var records := prepared.get("source_records", {}) as Dictionary
	if not _records_match(records): return _failure("fire_station48_prepared_drift", "Prepared source pair drifted.", {})
	if not runtime_dependency_closure_exists() or not _validated_config(): return _failure("fire_station48_config", "Pinned live factory/config dependency changed.", {})
	var result := _build_pair(records,source_builder,tangent_builder)
	if not bool(result.get("ok", false)): return result
	return {"ok":true,"contains_target":true,"records":{WALL_KEY:result.wall_result,ROOF_KEY:result.roof_result},"pending_keys":{WALL_KEY:true,ROOF_KEY:true}}

static func consume_record(record: Dictionary, plan: Dictionary) -> Dictionary:
	var key := str(record.get("object_key", ""))
	if not claims_record(record) or not bool(plan.get("ok", false)) or not bool(plan.get("contains_target", false)):
		return _failure("fire_station48_unprepared", "Validated supplied plan required.", record)
	var pending := plan.get("pending_keys", {}) as Dictionary
	var results := plan.get("records", {}) as Dictionary
	if not pending.has(key) or not results.has(key): return _failure("fire_station48_duplicate_consume", "Pair member missing or consumed twice.", record)
	if canonical_record_signature(record) != str(RECORD_HASHES[key]): return _failure("fire_station48_consumed_drift", "Consumed row differs from sealed source.", record)
	var result := results[key] as Dictionary
	pending.erase(key); results.erase(key)
	return result

static func _build_pair(records:Dictionary, source_builder:Callable,tangent_builder:Callable) -> Dictionary:
	var built := FACTORY.build_for_records(records[WALL_KEY], records[ROOF_KEY], source_builder,tangent_builder)
	if not bool(built.get("ok",false)):return _failure("fire_station48_factory",str(built.get("message","Factory failed.")),records[WALL_KEY])
	var wall_root:=built.node as Node3D
	if not _factory_contract_matches(wall_root,built):
		wall_root.free();return _failure("fire_station48_factory_contract","Accepted batches or ordered structure changed.",records[WALL_KEY])
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
	var meta:Dictionary={"adapter_id":ADAPTER_ID,"factory_calls":1,"captured_authority_metric":"14/213","candidate_recognition_credit":0,"recognition_accepted":false,"production_review":"pending","partial_pair_allowed":false,"fallback_allowed":false,"stack_allowed":false,"mapped_public_run_indices":FACTORY.TARGET_RUNS.duplicate(),"protected_run_indices":FACTORY.PROTECTED_RUNS.duplicate(),"accepted_study002_geometry_sha256":"e198f49df39671d489bb96cd553ec257df12156a0921b489f434d2c2b37d7597","all_additions_render_only":true,"source_collision_only":true}
	for root:Node3D in [wall_root,roof_root]:root.set_meta("fire_station48_live_replacement",meta.duplicate(true))
	return {"ok":true,"wall_result":{"ok":true,"node":wall_root,"metadata":meta,"mesh_instances":6,"surfaces":6,"triangles":1080,"static_bodies":1,"shapes":1},"roof_result":{"ok":true,"node":roof_root,"metadata":meta,"mesh_instances":1,"surfaces":1,"triangles":10,"static_bodies":1,"shapes":1}}

static func _factory_contract_matches(root:Node3D,result:Dictionary) -> bool:
	var meta:Dictionary=result.get("metadata",{})
	for pair:Array in [["mesh_instances",7],["surfaces",7],["visual_triangles",1090],["static_bodies",1],["shapes",2],["collision_triangles",62]]:
		if int(meta.get(pair[0],-1))!=int(pair[1]):return false
	var seen:Dictionary={}
	for child:Node in root.get_children():
		if child is MeshInstance3D:
			var mesh:Mesh=child.mesh
			if not EXPECTED_BATCH_TRIANGLES.has(str(child.name)) or mesh==null or mesh.get_surface_count()!=1:return false
			var arrays:=mesh.surface_get_arrays(0);var indices:=arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
			if indices.size()/3!=int(EXPECTED_BATCH_TRIANGLES[str(child.name)]):return false
			seen[str(child.name)]=true
	var body:=root.get_node_or_null("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	if seen.size()!=7 or body==null or body.get_child_count()!=2 or body.collision_layer!=1 or body.collision_mask!=0:return false
	var labels: Array=["ExactClosedSourceWalls","ExactSourceNeutralRoof"]
	var counts:Array=[52,10]
	var groups:Array=[WALL_MESHES,["ExactSourceNeutralRoof"]]
	for index in 2:
		var node:=body.get_child(index) as CollisionShape3D
		if node==null or str(node.name)!=str(labels[index]) or not node.shape is ConcavePolygonShape3D:return false
		var faces:PackedVector3Array=node.shape.get_faces()
		if faces.size()!=int(counts[index])*3 or str(node.shape.get_meta("receiver_kind",""))!="none":return false
		if _oriented_face_signature(faces)!=_mesh_oriented_face_signature(root,groups[index]):return false
	return true

static func _configure_body(body: StaticBody3D, key: String, eligible: bool) -> void:
	_clear_metadata(body)
	body.collision_layer=5; body.collision_mask=0
	body.set_meta("receiver_kind","building_wall" if eligible else "none")
	body.set_meta("derived_object_key",key); body.set_meta("source_keys",[SOURCE_KEY]); body.set_meta("opaque",true)
	body.set_meta("runtime_attachment",true); body.set_meta("prototype_only",false);body.set_meta("spray_ray_blocking",true)
	if eligible:body.add_to_group("spray_receiver_wall")
	else:body.set_meta("roof_landing_world_solid",true)

static func _configure_shape(node: CollisionShape3D, key: String, receiver: String) -> void:
	# Keep exact shape and face data; only ownership metadata changes.
	var role := str(node.shape.get_meta("structural_role",node.name))
	_clear_metadata(node.shape)
	for object:Object in [node,node.shape]:
		object.set_meta("receiver_kind",receiver);object.set_meta("derived_object_key",key);object.set_meta("source_keys",[SOURCE_KEY]);object.set_meta("opaque",true);object.set_meta("structural_role",role);object.set_meta("runtime_attachment",true);object.set_meta("prototype_only",false)

static func _apply_metadata(wall_root: Node3D, roof_root: Node3D) -> void:
	wall_root.name="FireStation48LiveWallReplacement";roof_root.name="FireStation48LiveRoofReplacement"
	for root:Node3D in [wall_root,roof_root]:
		var key := WALL_KEY if root==wall_root else ROOF_KEY
		_clear_metadata(root)
		root.set_meta("derived_object_key",key);root.set_meta("source_keys",[SOURCE_KEY]);root.set_meta("feature_kind","building_wall" if root==wall_root else "building_roof");root.set_meta("receiver_kind","building_wall" if root==wall_root else "none")
		root.set_meta("runtime_attachment",true);root.set_meta("prototype_only",false);root.set_meta("adapter_id",ADAPTER_ID);root.set_meta("runtime_supersedes_generated_placeholder",true);root.set_meta("superseded_object_keys",[WALL_KEY,ROOF_KEY]);root.set_meta("recognition_accepted",false)
		for child:Node in root.get_children():
			if child is MeshInstance3D:
				child.layers=2 if str(child.name) in WALL_MESHES else 1
				child.set_meta("derived_object_key",key);child.set_meta("source_keys",[SOURCE_KEY]);child.set_meta("runtime_attachment",true);child.set_meta("prototype_only",false)

static func _clear_metadata(object: Object) -> void:
	for key:StringName in object.get_meta_list():object.remove_meta(key)

static func _validated_config() -> bool:
	return FileAccess.get_sha256(CONFIG_PATH)==EXPECTED_CONFIG_SHA256 and FileAccess.get_sha256(FACTORY.CONFIG_PATH)==EXPECTED_FACTORY_CONFIG_SHA256

static func source_dependency_hashes_match() -> bool:
	if not _validated_config():return false
	for path:String in SOURCE_DEPENDENCY_HASHES:
		if FileAccess.get_sha256(path)!=str(SOURCE_DEPENDENCY_HASHES[path]):return false
	return true

static func runtime_dependency_closure_exists() -> bool:
	for path:String in SOURCE_DEPENDENCY_HASHES:
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

static func canonical_record_signature(record: Dictionary) -> String:
	return (_stable_json(record, 0) + "\n").sha256_text()

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
			if not is_finite(number):return "__NON_FINITE__"
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
