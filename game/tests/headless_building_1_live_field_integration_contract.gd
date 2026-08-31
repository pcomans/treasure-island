extends SceneTree

const BASELINE_FIELD := preload("res://game/scripts/world/facades/building_1_live_field.gd")
const RECOGNIZABLE := preload("res://game/scripts/world/facades/building_1_recognizable_facade.gd")
const RECEIVER_KEY := "building:r16681702:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const INVENTORY_PATH := "res://discovery/FACADE_RECEIVER_INVENTORY.json"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var record := _record_for(RECEIVER_KEY)
	var baseline := BASELINE_FIELD.build(record)
	var current := WorldChunkBuilder.new()._build_record(record, false)
	if not _require(bool(baseline.get("ok", false)) and bool(current.get("ok", false)), "Accepted Building 1 field baseline or current lifecycle-aware receiver did not build."):
		_free_result(baseline)
		_free_result(current)
		_finish()
		return
	var baseline_root := baseline.node as Node3D
	var baseline_mesh := baseline_root.get_node_or_null("B1_MAT_IVORY_Runs21To51") as MeshInstance3D
	var current_receiver := current.node as Node3D
	var facade := current_receiver.get_node_or_null("Building1RecognizableFacade") as Node3D
	var metadata := current_receiver.get_meta("building_1_recognizable_facade", {}) as Dictionary
	_require(_baseline_exact(baseline_mesh), "The independently accepted 31-run Building 1 ivory baseline asset drifted.")
	_require(_current_contains_accepted_scope(facade, metadata), "The current recognizability composition no longer contains or identifies the accepted runs21..51 field scope.")
	_require(_inventory_promoted(), "Canonical lifecycle did not promote the complete reviewed Building 1 field and recognizability composition.")
	baseline_root.free()
	current_receiver.free()
	await _whole_island_matches()
	if not _failed:
		print("PASS: Building 1's predecessor runs21..51 ivory baseline remains byte/topology bounded inside the independently accepted reversible 63-run field and 45-module recognizability composition, with zero pending review and loaded world 729/1,278/1,288/55,067/466")
	_finish()


func _baseline_exact(field: MeshInstance3D) -> bool:
	if field == null or field.material_override == null \
	or field.material_override.resource_path != BASELINE_FIELD.FIELD_MATERIAL_PATH \
	or field.get_meta("exact_ordered_runs", []) != _accepted_runs() \
	or str(field.get_meta("join_geometry", "")) != "shared_xz_mitered_offset_junctions" \
	or float(field.get_meta("maximum_rendered_join_gap_after_m", -1.0)) != 0.0:
		return false
	var mesh := field.mesh as ArrayMesh
	return mesh != null and mesh.get_surface_count() == 1 \
		and (mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() == 124 \
		and (mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() == 186 \
		and _count_type(field, CollisionObject3D) == 0 \
		and _count_type(field, CollisionShape3D) == 0 \
		and _count_type(field, NavigationRegion3D) == 0 \
		and _count_type(field, Decal) == 0


func _current_contains_accepted_scope(facade: Node3D, metadata: Dictionary) -> bool:
	if facade == null \
	or str(metadata.get("accepted_live_field_review_status", "")) != "independently_reviewed_keep_with_documented_limitation" \
	or str(metadata.get("accepted_live_field_review_sha256", "")) != RECOGNIZABLE.EXPECTED_FIELD_REVIEW_SHA256 \
	or _int_array(metadata.get("independently_accepted_prior_field_runs", []) as Array) != _accepted_runs() \
	or str(metadata.get("composition_review_status", "")) != RECOGNIZABLE.COMPOSITION_REVIEW_STATUS \
	or bool(metadata.get("completed_elevation", true)) \
	or bool(metadata.get("whole_building_accepted", true)):
		return false
	var wrap := facade.get_node_or_null("B1_IVORY_PUBLIC_WRAP") as MeshInstance3D
	if wrap == null or wrap.material_override == null or wrap.material_override.resource_path != BASELINE_FIELD.FIELD_MATERIAL_PATH:
		return false
	var runs := _int_array(wrap.get_meta("exact_ordered_runs", []) as Array)
	for run_index in _accepted_runs():
		if run_index not in runs:
			return false
	return true


func _inventory_promoted() -> bool:
	var inventory := _json(INVENTORY_PATH)
	var batch := inventory.get("batch_06_lifecycle_reconciliation", {}) as Dictionary
	var accepted := batch.get("accepted_exact_field_scopes", []) as Array
	var pending_fields := batch.get("pending_independent_actual_world_art_review_exact_field_scopes", []) as Array
	var found := false
	for value: Variant in accepted:
		var scope := value as Dictionary
		if str(scope.get("receiver_key", "")) == RECEIVER_KEY:
			found = int(scope.get("run_count", -1)) == 63 \
				and absf(float(scope.get("run_length_m", scope.get("accepted_length_m", 0.0))) - 206.908708) < 0.001 \
				and absf(float(scope.get("wall_area_m2", scope.get("accepted_wall_area_m2", 0.0))) - 4350.511117) < 0.001
	for value: Variant in pending_fields:
		if str((value as Dictionary).get("receiver_key", "")) == RECEIVER_KEY:
			return false
	var runtime := inventory.get("runtime_material_contract", {}) as Dictionary
	var modules := batch.get("accepted_live_module_summary_building_1", {}) as Dictionary
	return found \
		and pending_fields.is_empty() \
		and int(runtime.get("pending_independent_actual_world_art_review_exact_field_scope_count", -1)) == 0 \
		and int(runtime.get("pending_independent_recognizability_live_module_placement_count", -1)) == 0 \
		and int(modules.get("placement_count", -1)) == 45 \
		and str(modules.get("independent_live_review_sha256", "")) == "328973362b873b80ec8255c78ad7851369db850d3d9bc3f95b31064f83bb584c"


func _whole_island_matches() -> void:
	var world := (load("res://game/scenes/world/world_root.tscn") as PackedScene).instantiate() as WorldLoader
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys}))
	root.add_child(world)
	world.load_world("res://generated/world/manifest.json")
	await process_frame
	await process_frame
	var evidence := world.get_runtime_evidence()
	_require(failures.is_empty() and reports.size() == 1 and evidence != null \
		and evidence.playable_rows == 735 and evidence.context_rows == 4 \
		and evidence.mesh_instances == 1278 and evidence.surfaces == 1288 \
		and evidence.triangles == 55067 and evidence.static_bodies == 466 and evidence.shapes == 466, "Whole-island topology or load failed after Building 1 recognizability integration.")
	var nodes := _nodes_for_key(world, RECEIVER_KEY)
	_require(nodes.size() == 1 and (nodes[0] as Node3D).has_node("Building1RecognizableFacade"), "Loaded world lacks current Building 1 recognizable facade.")
	root.remove_child(world)
	world.free()


func _accepted_runs() -> Array[int]:
	var runs: Array[int] = []
	for run_index in range(21, 52): runs.append(run_index)
	return runs


func _record_for(receiver_key: String) -> Dictionary:
	for value: Variant in _json(CHUNK_PATH).get("records", []):
		if str((value as Dictionary).get("object_key", "")) == receiver_key: return value as Dictionary
	return {}


func _nodes_for_key(node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for child: Node in node.find_children("*", "Node3D", true, false):
		if str(child.get_meta("derived_object_key", "")) == key and child.get_parent() != null and str(child.get_parent().name).contains("__"):
			result.append(child)
	return result


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children(): count += _count_type(child, node_type)
	return count


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values: result.append(int(value))
	return result


func _free_result(result: Dictionary) -> void:
	var node := result.get("node") as Node
	if node != null: node.free()


func _require(condition: bool, message: String) -> bool:
	if condition: return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
