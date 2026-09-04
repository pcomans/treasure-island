extends SceneTree

const HERO := preload("res://game/scripts/world/facades/building_1_hero_model.gd")
const HISTORICAL_FIELD := preload("res://game/scripts/world/facades/building_1_live_field.gd")
const RECEIVER_KEY := "building:r16681702:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var record := _record_for(RECEIVER_KEY)
	var baseline := HISTORICAL_FIELD.build(record)
	var current := WorldChunkBuilder.new()._build_record(record, false)
	_require(bool(baseline.get("ok", false)) and bool(current.get("ok", false)), "Historical Building 1 field or current hero wall did not build.")
	if not bool(baseline.get("ok", false)) or not bool(current.get("ok", false)):
		_free_result(baseline)
		_free_result(current)
		_finish()
		return

	var baseline_root := baseline.node as Node3D
	var baseline_mesh := baseline_root.get_node_or_null("B1_MAT_IVORY_Runs21To51") as MeshInstance3D
	var current_root := current.node as Node3D
	_require(_baseline_exact(baseline_mesh), "The independently reviewed historical 31-run Building 1 ivory field drifted.")
	_require(_current_hero_supersedes_field(current_root, current), "The current Building 1 hero does not truthfully supersede the historical field attachment.")
	baseline_root.free()
	current_root.free()
	await _whole_island_matches()
	if not _failed:
		print("PASS: Building 1's reviewed runs21..51 ivory field remains byte/topology bounded as historical evidence while the current 6-mesh hero wall supersedes it without duplicate render or collision ownership; world 735/944/957/64,572/466")
	_finish()


func _baseline_exact(field: MeshInstance3D) -> bool:
	if field == null or field.material_override == null \
	or field.material_override.resource_path != HISTORICAL_FIELD.FIELD_MATERIAL_PATH \
	or field.get_meta("exact_ordered_runs", []) != _accepted_runs() \
	or str(field.get_meta("join_geometry", "")) != "shared_xz_mitered_offset_junctions" \
	or float(field.get_meta("maximum_rendered_join_gap_after_m", -1.0)) != 0.0:
		return false
	var mesh := field.mesh as ArrayMesh
	return mesh != null and mesh.get_surface_count() == 1 \
		and (mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() == 124 \
		and (mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() == 186 \
		and _count_type(field, CollisionObject3D) == 0 \
		and _count_type(field, CollisionShape3D) == 0


func _current_hero_supersedes_field(root_node: Node3D, result: Dictionary) -> bool:
	var ivory := root_node.get_node_or_null("HeroIvory") as MeshInstance3D
	var collision := root_node.get_node_or_null("Collision") as StaticBody3D
	if ivory == null or ivory.mesh == null or collision == null:
		return false
	var material := ivory.mesh.surface_get_material(0)
	return root_node.name == "Building1HeroWall" \
		and int(result.mesh_instances) == 6 and int(result.surfaces) == 6 and int(result.triangles) == 8806 \
		and bool(root_node.get_meta("runtime_supersedes_generated_placeholder", false)) \
		and str(root_node.get_meta("visual_review_status", "")) == HERO.VISUAL_REVIEW_STATUS \
		and not bool(root_node.get_meta("as_built_fidelity_claimed", true)) \
		and root_node.get_node_or_null("Building1RecognizableFacade") == null \
		and root_node.get_node_or_null("Building1LiveIvoryField") == null \
		and material != null and material.resource_path == HISTORICAL_FIELD.FIELD_MATERIAL_PATH \
		and collision.collision_layer == ((1 << 0) | (1 << 2)) \
		and collision.is_in_group("spray_receiver_wall")


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
	_require(
		failures.is_empty() and reports.size() == 1 and evidence != null \
		and evidence.playable_rows == 735 and evidence.context_rows == 4 \
		and evidence.mesh_instances == 944 and evidence.surfaces == 957 \
		and evidence.triangles == 64572 and evidence.static_bodies == 466 and evidence.shapes == 466,
		"Whole-island topology or load failed after Building 1 field supersession.",
	)
	var nodes := _nodes_for_key(world, RECEIVER_KEY)
	_require(nodes.size() == 1 and (nodes[0] as Node3D).name == "Building1HeroWall", "Loaded world lacks the current Building 1 hero wall.")
	root.remove_child(world)
	world.free()


func _accepted_runs() -> Array[int]:
	var runs: Array[int] = []
	for run_index in range(21, 52):
		runs.append(run_index)
	return runs


func _record_for(receiver_key: String) -> Dictionary:
	for value: Variant in _json(CHUNK_PATH).get("records", []):
		if str((value as Dictionary).get("object_key", "")) == receiver_key:
			return value as Dictionary
	return {}


func _nodes_for_key(node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for child: Node in node.find_children("*", "Node3D", true, false):
		if str(child.get_meta("derived_object_key", "")) == key and child.get_parent() != null and str(child.get_parent().name).contains("__"):
			result.append(child)
	return result


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _free_result(result: Dictionary) -> void:
	var node := result.get("node") as Node
	if node != null:
		node.free()


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_failed = true
		push_error(message)
	return condition


func _finish() -> void:
	quit(1 if _failed else 0)
