extends SceneTree

const FACADE := preload("res://game/scripts/world/facades/building_1_recognizable_facade.gd")
const BASELINE_FIELD := preload("res://game/scripts/world/facades/building_1_live_field.gd")
const RECEIVER_KEY := "building:r16681702:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const REGISTRY_PATH := "res://game/resources/facades/building_1_recognizability_placements.json"
const EXPECTED_MOTIF_COUNTS := {
	"B1-WING-W": 8,
	"B1-CENTRAL-W": 24,
	"B1-PAV-W": 2,
	"B1-BASE-O": 6,
	"B1-DOOR-BLUE": 1,
	"B1-BAND": 4,
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var record := _record()
	var registry := _json(REGISTRY_PATH)
	var builder := WorldChunkBuilder.new()
	var first := builder._build_record(record, false)
	var second := builder._build_record(record, false)
	var baseline := BASELINE_FIELD.build(record)
	if not _require(not record.is_empty() and not registry.is_empty(), "Building 1 record or recognizability registry did not resolve.") \
	or not _require(bool(first.get("ok", false)) and bool(second.get("ok", false)) and bool(baseline.get("ok", false)), "Building 1 recognizability, deterministic repeat, or accepted field baseline did not build."):
		_free_result(first)
		_free_result(second)
		_free_result(baseline)
		_finish()
		return
	var first_node := first.node as Node3D
	var second_node := second.node as Node3D
	var facade := first_node.get_node_or_null("Building1RecognizableFacade") as Node3D
	_require(_receiver_contract(first, first_node, facade, record), "Building 1 receiver/topology/physics or attachment contract drifted.")
	_require(_field_contract(facade, registry), "Building 1 public ivory field scope, miter, material, or protected-run contract drifted.")
	_require(_module_contract(facade, registry), "Building 1 complete motif, transform, containment, or zero-ownership contract drifted.")
	_require(_deterministic(first_node, second_node), "Building 1 recognizability composition is nondeterministic.")
	_require(_accepted_baseline_preserved(baseline.node as Node3D, facade), "Independently accepted Building 1 ivory field material and exact runs were not preserved inside the expanded composition.")
	first_node.free()
	second_node.free()
	(baseline.node as Node3D).free()
	await _whole_world_contract()
	if not _failed:
		print("PASS: independently accepted Building 1 recognizability composition remains deterministic and reversible: MAT-IVORY on exactly 63 verified public runs in 3 watertight chains plus 45 complete production-inference modules (8 WING / 24 CENTRAL / 2 PAV / 6 BASE / 1 DOOR / 4 BAND), 354 meshes / 354 surfaces / 4,338 triangles / 0 colliders, loaded world 729/1,278/1,288/55,067/466")
	_finish()


func _receiver_contract(result: Dictionary, node: Node3D, facade: Node3D, record: Dictionary) -> bool:
	var receiver_mesh := node.get_node_or_null("Mesh") as MeshInstance3D
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var metadata := node.get_meta("building_1_recognizable_facade", {}) as Dictionary
	return facade != null and receiver_mesh != null and body != null and shape_node != null \
		and node.get_child_count() == 3 \
		and int(result.get("mesh_instances", -1)) == 355 \
		and int(result.get("surfaces", -1)) == 355 \
		and int(result.get("triangles", -1)) == 4558 \
		and _count_type(facade, MeshInstance3D) == 354 \
		and _count_surfaces(facade) == 354 \
		and _count_triangles(facade) == 4338 \
		and _count_type(facade, CollisionObject3D) == 0 \
		and _count_type(facade, CollisionShape3D) == 0 \
		and _count_type(facade, NavigationRegion3D) == 0 \
		and _count_type(facade, Decal) == 0 \
		and str(metadata.get("composition_review_status", "")) == FACADE.COMPOSITION_REVIEW_STATUS \
		and str(metadata.get("accepted_live_field_review_status", "")) == "independently_reviewed_keep_with_documented_limitation" \
		and int(metadata.get("field_run_count", -1)) == 63 \
		and int(metadata.get("module_placement_count", -1)) == 45 \
		and not bool(metadata.get("surveyed_coordinates", true)) \
		and not bool(metadata.get("surveyed_count", true)) \
		and not bool(metadata.get("surveyed_cadence", true)) \
		and not bool(metadata.get("completed_elevation", true)) \
		and not bool(metadata.get("whole_building_accepted", true)) \
		and body.collision_layer == ((1 << 0) | (1 << 2)) and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") \
		and (shape_node.shape as ConcavePolygonShape3D).get_faces().size() == (record.get("indices", []) as Array).size() \
		and (receiver_mesh.mesh as ArrayMesh).get_surface_count() == 1


func _field_contract(facade: Node3D, registry: Dictionary) -> bool:
	var field := registry.get("field_composition", {}) as Dictionary
	var expected_runs := _int_array(field.get("exact_eligible_runs", []) as Array)
	var protected := _int_array((registry.get("protected_scope", {}) as Dictionary).get("protected_runs", []) as Array)
	var observed_runs: Array[int] = []
	var field_nodes := facade.find_children("B1_IVORY_*", "MeshInstance3D", false, false)
	if field_nodes.size() != 3:
		return false
	for node_value: Node in field_nodes:
		var node := node_value as MeshInstance3D
		var runs := _int_array(node.get_meta("exact_ordered_runs", []) as Array)
		observed_runs.append_array(runs)
		if node.material_override == null or node.material_override.resource_path != FACADE.FIELD_MATERIAL_PATH \
		or str(node.get_meta("join_geometry", "")) != "shared_xz_mitered_offset_junctions" \
		or float(node.get_meta("maximum_shared_miter_gap_m", -1.0)) != 0.0 \
		or float(node.get_meta("maximum_join_phase_delta_m", -1.0)) != 0.0:
			return false
		var arrays := (node.mesh as ArrayMesh).surface_get_arrays(0)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		if vertices.size() != runs.size() * 4 or (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() != runs.size() * 6:
			return false
		for join_offset in range(runs.size() - 1):
			var before := join_offset * 4
			var after := (join_offset + 1) * 4
			if vertices[before + 1] != vertices[after] or vertices[before + 2] != vertices[after + 3]:
				return false
	observed_runs.sort()
	if observed_runs != expected_runs:
		return false
	for protected_run: int in protected:
		if protected_run in observed_runs:
			return false
	return true


func _module_contract(facade: Node3D, registry: Dictionary) -> bool:
	var placements := registry.get("placements", []) as Array
	var counts := {}
	var protected := _int_array((registry.get("protected_scope", {}) as Dictionary).get("protected_runs", []) as Array)
	for placement_value: Variant in placements:
		var placement := placement_value as Dictionary
		var node := facade.get_node_or_null(str(placement.get("placement_id", "")).replace("-", "_")) as Node3D
		var motif := str(placement.get("motif_id", ""))
		if node == null or str(node.get_meta("motif_id", "")) != motif \
		or not bool(node.get_meta("complete_motif", false)) \
		or int(node.get_meta("anchor_run", -1)) != int(placement.get("anchor_run", -2)) \
		or int(node.get_meta("anchor_run", -1)) in protected \
		or absf(float(node.get_meta("along_run_center_m", -1.0)) - float(placement.get("along_run_center_m", -2.0))) > 0.000001 \
		or str(node.get_meta("composition_review_status", "")) != FACADE.COMPOSITION_REVIEW_STATUS \
		or bool(node.get_meta("surveyed_coordinates", true)) \
		or bool(node.get_meta("surveyed_count", true)) \
		or bool(node.get_meta("surveyed_cadence", true)):
			return false
		counts[motif] = int(counts.get(motif, 0)) + 1
		var expected_topology := _motif_topology(motif)
		if _count_type(node, MeshInstance3D) != expected_topology.x \
		or _count_triangles(node) != expected_topology.y \
		or _count_type(node, CollisionObject3D) != 0 \
		or _count_type(node, CollisionShape3D) != 0 \
		or _count_type(node, NavigationRegion3D) != 0 \
		or _count_type(node, Decal) != 0:
			return false
	return counts == EXPECTED_MOTIF_COUNTS


func _accepted_baseline_preserved(baseline_root: Node3D, current: Node3D) -> bool:
	var baseline := baseline_root.get_node("B1_MAT_IVORY_Runs21To51") as MeshInstance3D
	var wrap := current.get_node("B1_IVORY_PUBLIC_WRAP") as MeshInstance3D
	var current_runs := _int_array(wrap.get_meta("exact_ordered_runs", []) as Array)
	for run_index in range(21, 52):
		if run_index not in current_runs:
			return false
	return baseline.material_override == wrap.material_override \
		and str(baseline.get_meta("join_geometry", "")) == str(wrap.get_meta("join_geometry", "")) \
		and float(wrap.get_meta("maximum_shared_miter_gap_m", -1.0)) == 0.0


func _deterministic(first: Node3D, second: Node3D) -> bool:
	var a := first.get_node("Building1RecognizableFacade") as Node3D
	var b := second.get_node("Building1RecognizableFacade") as Node3D
	if a.get_meta_list() != b.get_meta_list() or a.get_child_count() != b.get_child_count():
		return false
	for index in a.get_child_count():
		var left := a.get_child(index) as Node3D
		var right := b.get_child(index) as Node3D
		if left.name != right.name or left.transform != right.transform or left.get_meta_list() != right.get_meta_list():
			return false
		if left is MeshInstance3D and right is MeshInstance3D:
			if ((left as MeshInstance3D).mesh as ArrayMesh).surface_get_arrays(0) != ((right as MeshInstance3D).mesh as ArrayMesh).surface_get_arrays(0):
				return false
	return true


func _whole_world_contract() -> void:
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
		and evidence.triangles == 55067 and evidence.static_bodies == 466 and evidence.shapes == 466, "Whole-island topology or load drifted after Building 1 recognizability composition.")
	var nodes := _nodes_for_key(world, RECEIVER_KEY)
	_require(nodes.size() == 1 and (nodes[0] as Node3D).has_node("Building1RecognizableFacade"), "Actual loaded world lacks Building 1 recognizability composition.")
	root.remove_child(world)
	world.free()


func _motif_topology(motif: String) -> Vector2i:
	match motif:
		"B1-WING-W": return Vector2i(7, 84)
		"B1-CENTRAL-W": return Vector2i(9, 108)
		"B1-PAV-W": return Vector2i(13, 156)
		"B1-BASE-O": return Vector2i(6, 72)
		"B1-DOOR-BLUE": return Vector2i(5, 60)
		"B1-BAND": return Vector2i(3, 36)
	return Vector2i(-1, -1)


func _record() -> Dictionary:
	for value: Variant in _json(CHUNK_PATH).get("records", []):
		if str((value as Dictionary).get("object_key", "")) == RECEIVER_KEY:
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
	for child: Node in node.get_children(): count += _count_type(child, node_type)
	return count


func _count_surfaces(node: Node) -> int:
	var count := (node as MeshInstance3D).mesh.get_surface_count() if node is MeshInstance3D and (node as MeshInstance3D).mesh != null else 0
	for child: Node in node.get_children(): count += _count_surfaces(child)
	return count


func _count_triangles(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mesh := (node as MeshInstance3D).mesh
		for surface_index in mesh.get_surface_count(): count += (mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
	for child: Node in node.get_children(): count += _count_triangles(child)
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
