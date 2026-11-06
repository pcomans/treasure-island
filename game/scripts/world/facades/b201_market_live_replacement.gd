extends RefCounted
## Replaces Building 201's generated wall and roof with the market model: the model
## as the wall node, with its roof mesh and roof collision moved into a separate
## roof node (one node per source record).
const MODEL := preload("res://game/scripts/world/facades/b201_market_model.gd")
const SOURCE := "w34313545"
const WALL := "building:w34313545:wall"
const ROOF := "building:w34313545:roof"
const CHUNK := "x_0__z_-2"


static func claims_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in [WALL, ROOF]


static func prepare_chunk_records(chunk: Dictionary) -> Dictionary:
	var records := {}
	for record: Dictionary in chunk.records:
		var key := str(record.get("object_key", ""))
		if claims_record(record) or SOURCE in record.get("source_keys", []):
			if not claims_record(record) or records.has(key) or record.get("source_keys", []) != [SOURCE]:
				return _failure("Ambiguous Building 201 source ownership.")
			records[key] = record
	if records.is_empty() and str(chunk.chunk_id) != CHUNK:
		return {"ok": true, "contains_target": false}
	if str(chunk.chunk_id) != CHUNK or not records.has(WALL) or not records.has(ROOF):
		return _failure("Building 201 requires its wall and roof together in the source chunk.")
	if str(records[WALL].get("receiver_kind", "")) != "building_wall" or str(records[ROOF].get("receiver_kind", "")) != "none":
		return _failure("Building 201 source receiver semantics changed.")
	return {"ok": true, "contains_target": true, "wall": records[WALL], "roof": records[ROOF]}


static func build_chunk_plan(pair: Dictionary) -> Dictionary:
	if not pair.get("contains_target", false):
		return {"ok": true, "contains_target": false, "records": {}}
	var model: Node3D = MODEL.new()
	var built: Dictionary = model.build(pair.roof, pair.wall)
	if not built.get("ok", false):
		model.free()
		return _failure(str(built.get("message", "Building 201 construction failed.")))
	model.set_meta("feature_kind", "building_wall")
	var roof_root := Node3D.new()
	roof_root.name = "B201MarketRoof"
	roof_root.transform = model.transform
	for child: Node in model.get_children():
		if str(child.get_meta("derived_object_key", "")) == ROOF:
			model.remove_child(child)
			roof_root.add_child(child)
	roof_root.set_meta("source_keys", [SOURCE])
	roof_root.set_meta("derived_object_key", ROOF)
	roof_root.set_meta("feature_kind", "building_roof")
	return {"ok": true, "contains_target": true, "records": {WALL: _result(model), ROOF: _result(roof_root)}}


static func consume_record(record: Dictionary, plan: Dictionary) -> Dictionary:
	var key := str(record.get("object_key", ""))
	if not claims_record(record) or not plan.get("records", {}).has(key):
		return _failure("Building 201 pair member missing or consumed twice.")
	var result: Dictionary = plan.records[key]
	plan.records.erase(key)
	return result


static func plan_was_fully_consumed(plan: Dictionary) -> bool:
	return plan.get("records", {}).is_empty()


static func free_unconsumed(plan: Dictionary) -> void:
	for result: Dictionary in plan.get("records", {}).values():
		var node: Node = result.node
		if not node.is_inside_tree():
			node.free()
	plan.get("records", {}).clear()


## The node plus the counts the world builder adds to its totals.
static func _result(root: Node3D) -> Dictionary:
	var meshes := 0
	var surfaces := 0
	var triangles := 0
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh := (node as MeshInstance3D).mesh
		meshes += 1
		surfaces += mesh.get_surface_count()
		triangles += mesh.get_faces().size() / 3
	var multimeshes := root.find_children("*", "MultiMeshInstance3D", true, false)
	var bodies := root.find_children("*", "CollisionObject3D", true, false)
	var shapes := root.find_children("*", "CollisionShape3D", true, false)
	return {"ok": true, "node": root, "mesh_instances": meshes + multimeshes.size(), "surfaces": surfaces + multimeshes.size(), "triangles": triangles, "static_bodies": bodies.size(), "shapes": shapes.size()}


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "code": "b201_market_pair", "message": message, "source_keys": [SOURCE]}
