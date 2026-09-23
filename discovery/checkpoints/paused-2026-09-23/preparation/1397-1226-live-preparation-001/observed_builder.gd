extends "res://game/scripts/world/world_chunk_builder.gd"
var target_keys: Array = []
var raw_calls: Array = []
var detail_tangent_calls := 0
var source_tangent_calls := 0
var raw_depth := 0
var held_nodes: Array[Node] = []
var injected_failure_key := ""
var skip_consumption_key := ""

func _build_unpaired_record(record: Dictionary, is_context: bool) -> Dictionary:
	raw_depth += 1
	var result: Dictionary = super._build_unpaired_record(record, is_context)
	raw_depth -= 1
	if str(record.object_key) in target_keys:
		raw_calls.append({"key": str(record.object_key), "is_context": is_context})
	# Retain all raw-source node references so cleanup also covers pending1201 and1206.
	if result.has("node"): held_nodes.append(result.node)
	return result

func _tangents_for(vertices: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, indices: PackedInt32Array) -> PackedFloat32Array:
	if raw_depth == 0: detail_tangent_calls += 1
	else: source_tangent_calls += 1
	return super._tangents_for(vertices, normals, uvs, indices)

func _build_record(record: Dictionary, is_context: bool, chapel_plan: Dictionary = {}, d2_1441_plan: Dictionary = {}, d2_1439_plan: Dictionary = {}, d2_1444_plan: Dictionary = {}, d5_1308_plan: Dictionary = {}, d5_1394_plan: Dictionary = {}, d5_1317_plan: Dictionary = {}, fs48_plan: Dictionary = {}, maceo_plan: Dictionary = {}, northern_canopy_plan: Dictionary = {}, northpoint_1238_plan: Dictionary = {}, mariner_1206_plan: Dictionary = {}, mariner_1219_plan: Dictionary = {}, mariner_1212_plan: Dictionary = {}, bayside_1220_plan: Dictionary = {}, northpoint_1239_plan: Dictionary = {}, bayside_1222_plan: Dictionary = {}, northpoint_1227_plan: Dictionary = {}, mariner_1202_plan: Dictionary = {}, northpoint_1234_plan: Dictionary = {}, bayside_1215_plan: Dictionary = {}, northpoint_1232_plan: Dictionary = {}, northpoint_1241_plan: Dictionary = {}, mariner_1221_plan: Dictionary = {}, northpoint_1240_plan: Dictionary = {}, gateview_1397_plan: Dictionary = {}, bayside_1226_plan: Dictionary = {}) -> Dictionary:
	if not injected_failure_key.is_empty() and str(record.object_key) == injected_failure_key:
		return {"ok": false, "code": "probe_later_record_failure", "message": "Bounded caller cleanup fixture", "source_keys": record.source_keys}
	var result: Dictionary
	if not skip_consumption_key.is_empty() and str(record.object_key) == skip_consumption_key:
		result = _build_unpaired_record(record, is_context)
	else:
		result = super._build_record(record, is_context, chapel_plan, d2_1441_plan, d2_1439_plan, d2_1444_plan, d5_1308_plan, d5_1394_plan, d5_1317_plan, fs48_plan, maceo_plan, northern_canopy_plan, northpoint_1238_plan, mariner_1206_plan, mariner_1219_plan, mariner_1212_plan, bayside_1220_plan, northpoint_1239_plan, bayside_1222_plan, northpoint_1227_plan, mariner_1202_plan, northpoint_1234_plan, bayside_1215_plan, northpoint_1232_plan, northpoint_1241_plan, mariner_1221_plan, northpoint_1240_plan, gateview_1397_plan, bayside_1226_plan)
	if result.has("node"): held_nodes.append(result.node)
	return result
