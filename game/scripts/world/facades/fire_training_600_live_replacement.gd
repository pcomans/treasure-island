extends RefCounted
## Atomic replacement of the supplied source pair, with the original footprint
## retained and one wall spray receiver plus one opaque non-wall roof receiver.
const FACTORY := preload("res://game/scripts/world/facades/fire_training_600_live_factory.gd")
const SOURCE := "w34313548"
const WALL := "building:w34313548:wall"
const ROOF := "building:w34313548:roof"
const CHUNK := "x_1__z_-2"


static func claims_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in [WALL, ROOF]


static func prepare_chunk_records(chunk: Dictionary) -> Dictionary:
	var records := {}
	for record: Dictionary in chunk.records:
		var key := str(record.get("object_key", ""))
		if claims_record(record) or SOURCE in record.get("source_keys", []):
			if not claims_record(record) or records.has(key) or record.get("source_keys", []) != [SOURCE]:
				return _failure("Ambiguous Building 600 source ownership.")
			records[key] = record
	if records.is_empty() and str(chunk.chunk_id) != CHUNK:
		return {"ok": true, "contains_target": false}
	if str(chunk.chunk_id) != CHUNK or not records.has(WALL) or not records.has(ROOF):
		return _failure("Building 600 requires its wall and roof together in the source chunk.")
	if str(records[WALL].get("receiver_kind", "")) != "building_wall" or str(records[ROOF].get("receiver_kind", "")) != "none":
		return _failure("Building 600 source receiver semantics changed.")
	return {"ok": true, "contains_target": true, "wall": records[WALL], "roof": records[ROOF]}


static func build_chunk_plan(pair: Dictionary) -> Dictionary:
	if not pair.get("contains_target", false):
		return {"ok": true, "contains_target": false, "records": {}}
	var built := FACTORY.build(pair.wall, pair.roof)
	if not built.get("ok", false):
		return _failure(str(built.get("message", "Building 600 construction failed.")))
	return {"ok": true, "contains_target": true, "records": {WALL: built.wall, ROOF: built.roof}}


static func consume_record(record: Dictionary, plan: Dictionary) -> Dictionary:
	var key := str(record.get("object_key", ""))
	if not claims_record(record) or not plan.get("records", {}).has(key):
		return _failure("Building 600 pair member missing or consumed twice.")
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


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "code": "fire_training_600_pair", "message": message, "source_keys": [SOURCE]}
