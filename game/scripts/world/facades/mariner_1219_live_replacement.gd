class_name Mariner1219LiveReplacement
extends RefCounted

## Proposed atomic live adapter for the reviewed 1219 Mariner source pair.
## It keeps the exact original and added roof resources together when splitting
## wall and roof results; nested collision ownership is preserved verbatim.

const FACTORY := preload("res://game/scripts/world/facades/mariner_1219_live_factory.gd")
const ADAPTER_ID := "active-adapter:mariner-1219-live:building:w96215680:wall"
const SOURCE_KEY := "w96215680"
const WALL_KEY := "building:w96215680:wall"
const ROOF_KEY := "building:w96215680:roof"
const TARGET_CHUNK_ID := "x_-2__z_-3"
const EXPECTED_FACTORY_SHA256 := "216e83f6ee69313d77ef5c2007720a126e07cff5e30ce23401a1d28cdac84748"
const EXPECTED_CONFIG_SHA256 := "5fd7eeb31c4d2cfac52aadff65f1bc7f35458d3e0c8d8469411f75ce032b9f21"
const MAPPED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
const PROTECTED_RUNS := [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]


static func claims_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in [WALL_KEY, ROOF_KEY]


static func prepare_chunk_records(chunk: Dictionary) -> Dictionary:
	if not (chunk.get("records", null) is Array):
		return _failure("mariner_1219_chunk_records", "Missing supplied records.", {})
	var records: Dictionary = {}
	for value: Variant in chunk.records:
		if not value is Dictionary:
			continue
		var record := value as Dictionary
		var source_value: Variant = record.get("source_keys", [])
		var source_keys := source_value as Array if source_value is Array else []
		if claims_record(record) or SOURCE_KEY in source_keys:
			if not claims_record(record):
				return _failure("mariner_1219_source_alias", "Unexpected target source alias.", record)
			var key := str(record.get("object_key", ""))
			if records.has(key):
				return _failure("mariner_1219_duplicate_record", "Duplicate target pair member.", record)
			records[key] = record
	if records.is_empty() and str(chunk.get("chunk_id", "")) != TARGET_CHUNK_ID:
		return {"ok": true, "contains_target": false}
	if str(chunk.get("chunk_id", "")) != TARGET_CHUNK_ID or not _pair_matches(records):
		return _failure("mariner_1219_pair", "Exact supplied 1219 wall and roof are required.", {})
	return {"ok": true, "contains_target": true, "source_records": records}


static func build_chunk_plan(prepared: Dictionary, source_builder: Callable, tangent_builder: Callable) -> Dictionary:
	if not bool(prepared.get("ok", false)):
		return prepared
	if not bool(prepared.get("contains_target", false)):
		return {"ok": true, "contains_target": false, "records": {}, "pending_keys": {}}
	var records := prepared.get("source_records", {}) as Dictionary
	if not _pair_matches(records) or not _dependencies_match():
		return _failure("mariner_1219_preflight", "Pinned factory, config, or source pair drifted.", {})
	var built := FACTORY.build_for_records(records[WALL_KEY], records[ROOF_KEY], source_builder, tangent_builder)
	if not bool(built.get("ok", false)):
		return _failure("mariner_1219_factory", str(built.get("message", "Factory failed.")), records[WALL_KEY])
	var split := _split_factory_result(built, records[WALL_KEY])
	if not bool(split.get("ok", false)):
		return split
	return {"ok": true, "contains_target": true, "source_records": records, "records": {WALL_KEY: split.wall_result, ROOF_KEY: split.roof_result}, "pending_keys": {WALL_KEY: true, ROOF_KEY: true}}


static func consume_record(record: Dictionary, plan: Dictionary) -> Dictionary:
	var key := str(record.get("object_key", ""))
	if not claims_record(record) or not bool(plan.get("ok", false)) or not bool(plan.get("contains_target", false)):
		return _failure("mariner_1219_unprepared", "Validated supplied plan required.", record)
	if not FACTORY.matches_record_pair(
		record if key == WALL_KEY else (plan.get("source_records", {}) as Dictionary).get(WALL_KEY, {}),
		record if key == ROOF_KEY else (plan.get("source_records", {}) as Dictionary).get(ROOF_KEY, {})
	):
		return _failure("mariner_1219_consumed_drift", "Consumed row differs from the frozen source pair.", record)
	var pending := plan.get("pending_keys", {}) as Dictionary
	var results := plan.get("records", {}) as Dictionary
	if not pending.has(key) or not results.has(key):
		return _failure("mariner_1219_duplicate_consume", "Pair member missing or consumed twice.", record)
	var result := results[key] as Dictionary
	pending.erase(key)
	results.erase(key)
	return result


static func plan_was_fully_consumed(plan: Dictionary) -> bool:
	return not bool(plan.get("contains_target", false)) or (plan.get("pending_keys", {}) as Dictionary).is_empty()


static func free_unconsumed(plan: Dictionary) -> void:
	for value: Variant in (plan.get("records", {}) as Dictionary).values():
		var node := (value as Dictionary).get("node", null) as Node
		if node != null and not node.is_inside_tree():
			node.free()
	(plan.get("records", {}) as Dictionary).clear()
	(plan.get("pending_keys", {}) as Dictionary).clear()


static func _pair_matches(records: Dictionary) -> bool:
	return records.size() == 2 and records.has(WALL_KEY) and records.has(ROOF_KEY) \
		and FACTORY.matches_record_pair(records[WALL_KEY], records[ROOF_KEY])


static func _dependencies_match() -> bool:
	# Exported scripts are remapped resources; JSON and source records stay raw.
	if FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot"):
		return runtime_dependency_closure_exists()
	return source_dependency_hashes_match()


static func source_dependency_hashes_match() -> bool:
	return FileAccess.get_sha256(FACTORY.SELF_PATH) == EXPECTED_FACTORY_SHA256 \
		and FileAccess.get_sha256(FACTORY.CONFIG_PATH) == EXPECTED_CONFIG_SHA256


static func runtime_dependency_closure_exists() -> bool:
	return ResourceLoader.exists(FACTORY.SELF_PATH) \
		and FileAccess.get_sha256(FACTORY.CONFIG_PATH) == EXPECTED_CONFIG_SHA256


static func _split_factory_result(built: Dictionary, wall_record: Dictionary) -> Dictionary:
	var wall_root := built.get("node", null) as Node3D
	if wall_root == null:
		return _failure("mariner_1219_factory_node", "Factory returned no root.", wall_record)
	var roof_mesh := wall_root.get_node_or_null("ExactSourceNeutralRoof") as MeshInstance3D
	var roof_source := wall_root.get_node_or_null("OriginalRoofRecord") as Node3D
	var roof_addition := wall_root.get_node_or_null("ObservedPublicRoof") as MeshInstance3D
	var roof_body := wall_root.get_node_or_null("ObservedRoof_NoSprayReceiver") as StaticBody3D
	if roof_mesh == null or roof_source == null or roof_addition == null or roof_body == null:
		wall_root.free()
		return _failure("mariner_1219_factory_shape", "Factory did not retain both original and added roof resources.", wall_record)
	var roof_root := Node3D.new()
	# Local transforms remain exact under the new identity root. The added roof
	# body keeps its prototype roof key, nonreceiver metadata and separate shape.
	for child: Node in [roof_mesh, roof_source, roof_addition, roof_body]:
		wall_root.remove_child(child)
		roof_root.add_child(child)
	_apply_live_metadata(wall_root, WALL_KEY, true)
	_apply_live_metadata(roof_root, ROOF_KEY, false)
	# Count the actual split roots. Do not reuse the factory's combined totals.
	var wall_measure := _measure([wall_root])
	var roof_measure := _measure([roof_root])
	var metadata := {
		"adapter_id": ADAPTER_ID,
		"source_key": SOURCE_KEY,
		"factory_calls": 1,
		"mapped_public_run_indices": MAPPED_RUNS.duplicate(),
		"protected_run_indices": PROTECTED_RUNS.duplicate(),
		"partial_pair_allowed": false,
		"fallback_allowed": false,
		"stack_allowed": false,
		"original_source_channels_and_roof_preserved": true,
		"source_wall_spray_eligibility_preserved": true,
		"recognition_accepted": false,
		"package_attachment_pending": true,
	}
	return {
		"ok": true,
		"wall_result": _result(wall_root, metadata, wall_measure),
		"roof_result": _result(roof_root, metadata, roof_measure),
	}


static func _result(node: Node3D, metadata: Dictionary, measured: Dictionary) -> Dictionary:
	return {
		"ok": true,
		"node": node,
		"metadata": metadata.duplicate(true),
		"mesh_instances": int(measured.get("mesh_instances", 0)),
		"surfaces": int(measured.get("surfaces", 0)),
		"triangles": int(measured.get("triangles", 0)),
		"static_bodies": int(measured.get("static_bodies", 0)),
		"shapes": int(measured.get("shapes", 0)),
	}


static func _apply_live_metadata(root: Node3D, key: String, wall: bool) -> void:
	root.name = "Mariner1219LiveWall" if wall else "Mariner1219LiveRoof"
	root.set_meta("derived_object_key", key)
	root.set_meta("source_keys", [SOURCE_KEY])
	root.set_meta("feature_kind", "building_wall" if wall else "building_roof")
	root.set_meta("receiver_kind", "building_wall" if wall else "none")
	root.set_meta("runtime_attachment", true)
	root.set_meta("prototype_only", false)
	root.set_meta("adapter_id", ADAPTER_ID)
	root.set_meta("runtime_supersedes_generated_placeholder", true)
	root.set_meta("superseded_object_keys", [WALL_KEY, ROOF_KEY])
	root.set_meta("recognition_accepted", false)
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			child.set_meta("derived_object_key", key)
			child.set_meta("source_keys", [SOURCE_KEY])
			child.set_meta("runtime_attachment", true)
			child.set_meta("prototype_only", false)


static func _measure(roots: Array) -> Dictionary:
	var result := {"mesh_instances": 0, "surfaces": 0, "triangles": 0, "static_bodies": 0, "shapes": 0}
	for root_value: Variant in roots:
		for node: Node in _descendants(root_value as Node):
			if node is MeshInstance3D:
				result.mesh_instances += 1
				var mesh := (node as MeshInstance3D).mesh
				if mesh != null:
					result.surfaces += mesh.get_surface_count()
					for surface_index in mesh.get_surface_count():
						result.triangles += int(mesh.surface_get_array_index_len(surface_index) / 3)
			elif node is StaticBody3D:
				result.static_bodies += 1
			elif node is CollisionShape3D:
				result.shapes += 1
	return result


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
	var source_value: Variant = record.get("source_keys", [])
	var source_keys := source_value as Array if source_value is Array else []
	return {"ok": false, "code": code, "message": message, "source_keys": source_keys.duplicate()}
