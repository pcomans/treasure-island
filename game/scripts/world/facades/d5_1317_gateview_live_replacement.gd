class_name D51317GateviewLiveReplacement
extends RefCounted

## Atomic supplied source pair with unchanged accepted art002 construction.
## Only receiver ownership and collision partition change at attachment.
const FACTORY := preload("res://game/scripts/world/facades/d5_1317_gateview_live_factory.gd")
const CONFIG_PATH := "res://game/resources/facades/d5_1317_gateview_live_replacement.json"
const ADAPTER_ID := "active-adapter:d5-1317-live:building:w95934125:wall"
const SOURCE_KEY := "w95934125"
const WALL_KEY := "building:w95934125:wall"
const ROOF_KEY := "building:w95934125:roof"
const LAND_KEY := "land:w26767313:x_-3__z_-2"
const AREA_KEY := "area:r17241151:x_-3__z_-2"
const TARGET_CHUNK_ID := "x_-3__z_-2"
const WALL_MESHES := ["ProtectedExactNeutralWallRuns", "ObservedENEHorizontalSidingFields"]
const ROOF_MESHES := ["ExactSourceNeutralRoof", "PublicShallowBrownMainRoof"]
const EXPECTED_BATCH_TRIANGLES := {"ProtectedExactNeutralWallRuns": 44, "ObservedENEHorizontalSidingFields": 24, "ExactSourceNeutralRoof": 22, "UpperWarmBoardedFields": 96, "UpperDarkOpaqueFields": 48, "PaleUpperFrames": 576, "PaleGroundFrames": 504, "ClosedGroundBoardedFields": 144, "BrownCanopyTopsAndSides": 39, "PaleCanopyFrontGables": 9, "SlimCanopyTrim": 144, "GroundFittedPostsAndBraces": 144, "PublicShallowBrownMainRoof": 108, "LocalConcretePorchesAndApproaches": 36}
const EXPECTED_CONFIG_SHA256 := "d15f6ea9e14ca9723dfd3f5794718fab6ad6d0cbf24091ce0e81fd34821e554f"
const EXPECTED_FACTORY_CONFIG_SHA256 := "33b54fb72cf829e933a0e386e984f6ffe9d9a7c9d335ecb034e779c12bf89a26"
const RECORD_HASHES := {"area:r17241151:x_-3__z_-2": "336bb7c5d763d853c19184da045cf4a114f25493ecf02a367ca1e0523d8bebd1", "area:r17241152:x_-3__z_-2": "104faf44f5234729b0411e75595abeec1888f867d0efa6a3d765aaa4f93d991e", "building:w95934125:roof": "ae444960fc7ae2d8cae3a7fa28637ecd06b9c17d691d3c69c146564d5c6874ef", "building:w95934125:wall": "3537997ae045f8022bbe4c6449cec82655797411e417397d15ace85fedc3a6ef", "land:w26767313:x_-3__z_-2": "9ff2ddf4241136939a8dbe377679ef9f30e4c17e229b91ffbafc117c03d47c04"}
const SOURCE_DEPENDENCY_HASHES := {"res://game/resources/facades/d5_1317_gateview_quality_study.json": "33b54fb72cf829e933a0e386e984f6ffe9d9a7c9d335ecb034e779c12bf89a26", "res://game/resources/facades/d5_1317_quality_study_geometry.json": "48ba2658a74b4e51ab43fb07b3940a737ffa351350081063c45908e878a5bcf9", "res://game/resources/facades/d5_1317_siding_marks.gdshader": "1575f777f114d4e00b8e8492b93be6ce35b76070030c589e9b38514d3ff04a7e", "res://game/resources/facades/d5_1317_surface_tone.gdshader": "2388fbee5821352c30ec5925f4ff159439090c8cb1f4973344a947c65b4e4da0", "res://game/scripts/world/facades/d5_1317_gateview_live_factory.gd": "80930edee46371825bfb7b337b94bdbb4e3b7fc064aa2ba3061b6a86886af884", "res://game/scripts/world/facades/site_12_housing_kit.gd": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"}
static func claims_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in [WALL_KEY, ROOF_KEY]

static func prepare_chunk_records(chunk: Dictionary) -> Dictionary:
	if not (chunk.get("records", null) is Array):
		return _failure("d5_1317_chunk_records", "Missing supplied records.", {})
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
				return _failure("d5_1317_source_alias", "Unexpected supplied target source alias.", record)
		if RECORD_HASHES.has(key):
			if relevant.has(key): return _failure("d5_1317_duplicate_record", "Duplicate pair or local grade record.", record)
			relevant[key] = record
	if target_count == 0 and str(chunk.get("chunk_id", "")) != TARGET_CHUNK_ID:
		return {"ok":true,"contains_target":false}
	if str(chunk.get("chunk_id", "")) != TARGET_CHUNK_ID or target_count != 2 or not _records_match(relevant):
		return _failure("d5_1317_pair_or_grade", "The exact supplied wall, roof, land and both areas are required.", {})
	return {"ok":true,"contains_target":true,"source_records":relevant}

static func _records_match(records: Dictionary) -> bool:
	if records.size() != 5: return false
	for key: String in RECORD_HASHES:
		if not (records.get(key, null) is Dictionary) or canonical_record_signature(records[key]) != str(RECORD_HASHES[key]): return false
	return true

static func build_chunk_plan(prepared: Dictionary, neutral_wall: StandardMaterial3D, neutral_roof: StandardMaterial3D) -> Dictionary:
	if not bool(prepared.get("ok", false)): return prepared
	if not bool(prepared.get("contains_target", false)): return {"ok":true,"contains_target":false,"records":{},"pending_keys":{}}
	var records := prepared.get("source_records", {}) as Dictionary
	if not _records_match(records): return _failure("d5_1317_prepared_drift", "Prepared pair or grade drifted.", {})
	if not runtime_dependency_closure_exists() or not _validated_config(): return _failure("d5_1317_config", "Pinned live factory/config dependency changed.", {})
	var result := _build_pair(records, neutral_wall, neutral_roof)
	if not bool(result.get("ok", false)): return result
	return {"ok":true,"contains_target":true,"records":{WALL_KEY:result.wall_result,ROOF_KEY:result.roof_result},"pending_keys":{WALL_KEY:true,ROOF_KEY:true}}

static func consume_record(record: Dictionary, plan: Dictionary) -> Dictionary:
	var key := str(record.get("object_key", ""))
	if not claims_record(record) or not bool(plan.get("ok", false)) or not bool(plan.get("contains_target", false)):
		return _failure("d5_1317_unprepared", "Validated supplied plan required.", record)
	var pending := plan.get("pending_keys", {}) as Dictionary
	var results := plan.get("records", {}) as Dictionary
	if not pending.has(key) or not results.has(key): return _failure("d5_1317_duplicate_consume", "Pair member missing or consumed twice.", record)
	if canonical_record_signature(record) != str(RECORD_HASHES[key]): return _failure("d5_1317_consumed_drift", "Consumed row differs from sealed source.", record)
	var result := results[key] as Dictionary
	pending.erase(key); results.erase(key)
	return result

static func _build_pair(records:Dictionary, neutral_wall:StandardMaterial3D, neutral_roof:StandardMaterial3D) -> Dictionary:
	var built := FACTORY.build_for_records(records[WALL_KEY], records[ROOF_KEY], neutral_wall, neutral_roof, records)
	if not bool(built.get("ok",false)):return _failure("d5_1317_factory",str(built.get("message","Factory failed.")),records[WALL_KEY])
	var wall_root:=built.node as Node3D
	if not _factory_contract_matches(wall_root,built):
		wall_root.free();return _failure("d5_1317_factory_contract","Accepted batches or ordered structure changed.",records[WALL_KEY])
	var original:=wall_root.get_node("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	var roof_root:=Node3D.new();var roof_body:=StaticBody3D.new();roof_body.name="Collision"
	for label:String in ROOF_MESHES:
		var mesh:=wall_root.get_node(label) as MeshInstance3D;wall_root.remove_child(mesh);roof_root.add_child(mesh)
	for label:String in ["ExactSourceNeutralRoof","PublicShallowMainRoof"]:
		var shape:=original.get_node(label) as CollisionShape3D;original.remove_child(shape);roof_body.add_child(shape);_configure_shape(shape,ROOF_KEY,"none")
	roof_root.add_child(roof_body);original.name="Collision"
	_configure_body(original,WALL_KEY,true);_configure_body(roof_body,ROOF_KEY,false)
	for index in original.get_child_count():_configure_shape(original.get_child(index) as CollisionShape3D,WALL_KEY,"building_wall" if index==0 else "none")
	_apply_metadata(wall_root,roof_root)
	var meta:Dictionary={"adapter_id":ADAPTER_ID,"factory_calls":1,"captured_authority_metric":"13/213","candidate_recognition_credit":0,"recognition_accepted":false,"production_review":"pending","partial_pair_allowed":false,"fallback_allowed":false,"stack_allowed":false,"mapped_public_run_indices":FACTORY.TARGET_RUNS.duplicate(),"protected_run_indices":FACTORY.PROTECTED_RUNS.duplicate(),"accepted_art002_geometry_sha256":"48ba2658a74b4e51ab43fb07b3940a737ffa351350081063c45908e878a5bcf9"}
	for root:Node3D in [wall_root,roof_root]:root.set_meta("d5_1317_gateview_live_replacement",meta.duplicate(true))
	return {"ok":true,"wall_result":{"ok":true,"node":wall_root,"metadata":meta,"mesh_instances":12,"surfaces":12,"triangles":1808,"static_bodies":1,"shapes":3},"roof_result":{"ok":true,"node":roof_root,"metadata":meta,"mesh_instances":2,"surfaces":2,"triangles":130,"static_bodies":1,"shapes":2}}

static func _factory_contract_matches(root:Node3D,result:Dictionary) -> bool:
	var meta:Dictionary=result.get("metadata",{})
	for pair:Array in [["mesh_instances",14],["surfaces",14],["visual_triangles",1938],["static_bodies",1],["shapes",5],["collision_triangles",1038]]:
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
	if seen.size()!=14 or body==null or body.get_child_count()!=5 or body.collision_layer!=1 or body.collision_mask!=0:return false
	var labels: Array=["ExactClosedSourceWalls","ExactSourceNeutralRoof","CanopiesPostsBraces","ClosedLowerModules","PublicShallowMainRoof"]
	var counts:Array=[68,22,192,648,108]
	var groups:Array=[WALL_MESHES,["ExactSourceNeutralRoof"],["BrownCanopyTopsAndSides","PaleCanopyFrontGables","GroundFittedPostsAndBraces"],["ClosedGroundBoardedFields","PaleGroundFrames"],["PublicShallowBrownMainRoof"]]
	for index in 5:
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
	wall_root.name="D51317GateviewLiveWallReplacement";roof_root.name="D51317GateviewLiveRoofReplacement"
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

