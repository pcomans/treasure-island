extends SceneTree

const LIVE_MODULES := preload("res://game/scripts/world/facades/w34313564_live_modules.gd")
const REVIEWED_CALIBRATION := preload("res://game/tests/support/w34313564_module_calibration.gd")
const ACCEPTED_FIELDS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const RECEIVER_KEY := "building:w34313564:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-3.json"
const REGISTRY_PATH := "res://game/resources/facades/w34313564_module_calibration.json"
const LIVE_HELPER_PATH := "res://game/scripts/world/facades/w34313564_live_modules.gd"
const WORLD_BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const FIELD_HELPER_PATH := "res://game/scripts/world/facades/accepted_material_run_trials.gd"
const FINAL_REVIEW_PATH := "res://discovery/facades/W34313564_MODULE_CALIBRATION_CORRECTION_ART_REVIEW.md"
const EXPECTED_REGISTRY_SHA256 := "45a47d333c997887cef7d1c97a633d37ae050efda597186430c7af6d52116f0f"
const EXPECTED_REVIEWED_CALIBRATION_SHA256 := "b49b8c20fbbe40f2728c0acadf8d53f0593856091e6df897a613d4f2f8680b71"
const EXPECTED_FINAL_REVIEW_SHA256 := "a8f1396e2d126c0c38b37edf770df975c4fa95e25e34fb2c7c1e766630fd1591"
const EXPECTED_LIVE_HELPER_SHA256 := "74a7eb9a29750baf47e59194374c2669278bba5af091f5cbe04b13f45c230b8e"
const EXPECTED_WORLD_BUILDER_SHA256 := "28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682"
const EXPECTED_FIELD_HELPER_SHA256 := "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c"
const EXPECTED_PLACEMENTS := {
	"CAL-SSE-PDOOR-01": {"motif_id": "W34313564-PDOOR", "run": 7, "center_m": 47.5, "face": "SSE", "mapping_id": "B06-34313564-SSE-CENTRAL", "material": "res://game/resources/materials/world/w34313564/w34313564_door.tres", "meshes": 5},
	"CAL-SSE-HWIN-01": {"motif_id": "W34313564-HWIN", "run": 8, "center_m": 68.0, "face": "SSE", "mapping_id": "B06-34313564-SSE-CENTRAL", "material": "res://game/resources/materials/world/w34313564/w34313564_glass.tres", "meshes": 8},
	"CAL-ENE-HWIN-01": {"motif_id": "W34313564-HWIN", "run": 12, "center_m": 18.0, "face": "ENE", "mapping_id": "B06-34313564-ENE-END", "material": "res://game/resources/materials/world/w34313564/w34313564_glass.tres", "meshes": 8},
	"CAL-NNW-PDOOR-01": {"motif_id": "W34313564-PDOOR", "run": 16, "center_m": 32.0, "face": "NNW", "mapping_id": "B06-34313564-NNW-OUTER", "material": "res://game/resources/materials/world/w34313564/w34313564_door.tres", "meshes": 5},
	"CAL-NNW-HWIN-01": {"motif_id": "W34313564-HWIN", "run": 17, "center_m": 54.0, "face": "NNW", "mapping_id": "B06-34313564-NNW-OUTER", "material": "res://game/resources/materials/world/w34313564/w34313564_glass.tres", "meshes": 8},
}
const PROTECTED_RECEIVERS := [
	"building:w34313515:wall",
	"building:w291196370:wall",
	"building:w34313547:wall",
	"building:w291189336:wall",
	"building:w291189926:wall",
	"building:w764313741:wall",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(_current_inputs_match(), "Reviewed or current live-integration input identity drifted."):
		_finish()
		return
	var record := _record_for(RECEIVER_KEY)
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	if not _require(not record.is_empty(), "Exact w34313564 generated receiver did not resolve."):
		_finish()
		return
	var builder := WorldChunkBuilder.new()
	var first := builder._build_record(record, false)
	var second := builder._build_record(record, false)
	var detached := REVIEWED_CALIBRATION.build(record, registry)
	if not _require(bool(first.get("ok", false)) and bool(second.get("ok", false)) and bool(detached.get("ok", false)), "Live or detached reviewed module build failed: first=%s second=%s detached=%s" % [first.get("message", first.get("code", "unknown")), second.get("message", second.get("code", "unknown")), detached.get("message", detached.get("code", "unknown"))]):
		_free_result(first)
		_free_result(second)
		_free_result(detached)
		_finish()
		return
	var first_node := first.node as Node3D
	var second_node := second.node as Node3D
	var detached_node := detached.node as Node3D
	if not _require(_receiver_matches(first, record), "Exact live receiver topology, field, collision, or module attachment contract failed.") \
	or not _require(_modules_match_reviewed(first_node, detached_node), "Live modules drifted from the five reviewed transforms, resources, roles, or render-only contract.") \
	or not _require(_deterministic(first_node, second_node), "Live receiver build is nondeterministic.") \
	or not _require(_protected_receivers_unchanged(builder), "A protected receiver gained w34313564 modules or changed its existing material partition."):
		first_node.free()
		second_node.free()
		detached_node.free()
		_finish()
		return
	first_node.free()
	second_node.free()
	detached_node.free()
	await _whole_island_matches()
	if not _failed:
		print("PASS: exactly five reviewed w34313564 live receiver modules remain unchanged at runs 7/8/12/16/17 with 34 render-only meshes / 34 surfaces / 408 triangles and zero backing/collision/navigation/spray; the separately accepted w34313515/w291196370/w34313520 scopes remain isolated, and whole-island topology is 735/940/954/64,118/466/466 (playable rows/meshes/surfaces/triangles/bodies/shapes)")
	_finish()


func _current_inputs_match() -> bool:
	return FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256 \
		and FileAccess.get_sha256("res://game/tests/support/w34313564_module_calibration.gd") == EXPECTED_REVIEWED_CALIBRATION_SHA256 \
		and FileAccess.get_sha256(FINAL_REVIEW_PATH) == EXPECTED_FINAL_REVIEW_SHA256 \
		and FileAccess.get_sha256(LIVE_HELPER_PATH) == EXPECTED_LIVE_HELPER_SHA256 \
		and FileAccess.get_sha256(WORLD_BUILDER_PATH) == EXPECTED_WORLD_BUILDER_SHA256 \
		and FileAccess.get_sha256(FIELD_HELPER_PATH) == EXPECTED_FIELD_HELPER_SHA256


func _receiver_matches(result: Dictionary, record: Dictionary) -> bool:
	var node := result.node as Node3D
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var live := node.get_node_or_null("W34313564LiveModules") as Node3D
	var field_metadata := node.get_meta("accepted_material_run_trial", {}) as Dictionary
	var live_metadata := node.get_meta("w34313564_live_modules", {}) as Dictionary
	if node.get_child_count() != 3 or mesh == null or body == null or shape == null or live == null \
	or int(result.mesh_instances) != 35 or int(result.surfaces) != 37 or int(result.triangles) != 448 \
	or mesh.get_surface_count() != 3 \
	or mesh.surface_get_name(0) != ACCEPTED_FIELDS.PLACEHOLDER_SURFACE_NAME \
	or mesh.surface_get_name(1) != "trial_w34313564_tan_runs" \
	or mesh.surface_get_name(2) != "trial_w34313564_pale_runs" \
	or mesh.surface_get_material(1).resource_path != "res://game/resources/materials/world/w34313564/w34313564_tan_exact_trial.tres" \
	or mesh.surface_get_material(2).resource_path != "res://game/resources/materials/world/w34313564/w34313564_pale_exact_trial.tres" \
	or field_metadata != ACCEPTED_FIELDS.metadata_for(RECEIVER_KEY) \
	or int(field_metadata.get("modules", -1)) != 5 \
	or int(field_metadata.get("standalone_modules_live", -1)) != 5 \
	or str(field_metadata.get("module_placement_role", "")) != LIVE_MODULES.PLACEMENT_ROLE \
	or not is_equal_approx(float(field_metadata.get("module_position_uncertainty_m", -1.0)), 4.0) \
	or bool(field_metadata.get("module_cadence_inferred", true)) \
	or bool(field_metadata.get("module_total_opening_count_inferred", true)) \
	or int(live_metadata.get("module_instances", -1)) != 5 \
	or int(live_metadata.get("mesh_instances", -1)) != 34 \
	or int(live_metadata.get("surfaces", -1)) != 34 \
	or int(live_metadata.get("triangles", -1)) != 408 \
	or int(live_metadata.get("collision_nodes", -1)) != 0 \
	or int(live_metadata.get("navigation_nodes", -1)) != 0 \
	or int(live_metadata.get("spray_nodes", -1)) != 0 \
	or body.collision_layer != ((1 << 0) | (1 << 2)) \
	or body.collision_mask != 0 \
	or not body.is_in_group("spray_receiver_wall") \
	or shape.get_faces().size() != (record.get("indices", []) as Array).size():
		return false
	return _surface_triangles(mesh, 0) == 10 \
		and _surface_triangles(mesh, 1) == 10 \
		and _surface_triangles(mesh, 2) == 20


func _modules_match_reviewed(live_receiver: Node3D, detached_root: Node3D) -> bool:
	var live_root := live_receiver.get_node("W34313564LiveModules") as Node3D
	if live_root.get_child_count() != 5 \
	or not bool(live_root.get_meta("runtime_attachment", false)) \
	or bool(live_root.get_meta("controlled_calibration", true)) \
	or _count_type(live_root, MeshInstance3D) != 34 \
	or _count_type(live_root, CollisionObject3D) != 0 \
	or _count_type(live_root, CollisionShape3D) != 0 \
	or _count_type(live_root, NavigationRegion3D) != 0 \
	or _count_type(live_root, Decal) != 0:
		return false
	var seen := {}
	var geometry_signatures := {}
	for child: Node in live_root.get_children():
		var module := child as Node3D
		var placement_id := str(module.get_meta("placement_id", ""))
		var expected := EXPECTED_PLACEMENTS.get(placement_id, {}) as Dictionary
		var detached_module := _module_for(detached_root, placement_id)
		if expected.is_empty() or detached_module == null or seen.has(placement_id) \
		or not module.transform.is_equal_approx(detached_module.transform) \
		or str(module.get_meta("motif_id", "")) != str(expected.motif_id) \
		or module.get_meta("run_ownership", []) != [int(expected.run)] \
		or int(module.get_meta("anchor_run", -1)) != int(expected.run) \
		or not is_equal_approx(float(module.get_meta("center_chain_m", -1.0)), float(expected.center_m)) \
		or not is_equal_approx(float(module.get_meta("center_chain_uncertainty_m", -1.0)), 4.0) \
		or str(module.get_meta("face", "")) != str(expected.face) \
		or str(module.get_meta("mapping_id", "")) != str(expected.mapping_id) \
		or str(module.get_meta("placement_role", "")) != LIVE_MODULES.PLACEMENT_ROLE \
		or not bool(module.get_meta("runtime_attachment", false)) \
		or bool(module.get_meta("module_owns_field_geometry", true)) \
		or bool(module.get_meta("cadence_inferred", true)) \
		or bool(module.get_meta("total_opening_count_inferred", true)) \
		or module.get_child_count() != int(expected.meshes):
			return false
		seen[placement_id] = true
		var primary_material_seen := false
		for mesh_value: Node in module.get_children():
			var mesh_instance := mesh_value as MeshInstance3D
			if mesh_instance == null or not (mesh_instance.mesh is BoxMesh) \
			or mesh_instance.layers != (1 << 1) or mesh_instance.material_override == null:
				return false
			var material_path := mesh_instance.material_override.resource_path
			if material_path == str(expected.material):
				primary_material_seen = true
			elif material_path != "res://game/resources/materials/world/w34313564/w34313564_frame.tres":
				return false
			var box := mesh_instance.mesh as BoxMesh
			var clearance := REVIEWED_CALIBRATION.WALL_OFFSET_M + mesh_instance.position.z - box.size.z * 0.5
			if clearance < 0.001 or clearance > 0.18:
				return false
			var world_transform := module.transform * mesh_instance.transform
			var signature := "%s|%s|%s" % [world_transform.origin, world_transform.basis, box.size]
			if geometry_signatures.has(signature):
				return false
			geometry_signatures[signature] = true
		if not primary_material_seen:
			return false
	return seen.size() == EXPECTED_PLACEMENTS.size() and _int_array_from_seen_runs(seen, live_root) == [7, 8, 12, 16, 17]


func _deterministic(first: Node3D, second: Node3D) -> bool:
	var first_root := first.get_node("W34313564LiveModules") as Node3D
	var second_root := second.get_node("W34313564LiveModules") as Node3D
	if first_root.get_child_count() != second_root.get_child_count():
		return false
	for child: Node in first_root.get_children():
		var first_module := child as Node3D
		var second_module := _module_for(second_root, str(first_module.get_meta("placement_id", "")))
		if second_module == null or not first_module.transform.is_equal_approx(second_module.transform):
			return false
	return true


func _protected_receivers_unchanged(builder: WorldChunkBuilder) -> bool:
	for receiver_key: String in PROTECTED_RECEIVERS:
		var record := _record_for(receiver_key)
		if record.is_empty():
			return false
		var result := builder._build_record(record, false)
		if not bool(result.get("ok", false)):
			return false
		var node := result.node as Node3D
		var live_roots := node.find_children("W34313564LiveModules", "Node3D", true, false)
		var expected_surfaces := 1
		if ACCEPTED_FIELDS.matches_record(record) or ACCEPTED_FIELDS.matches_batch_06_accepted_record(record):
			expected_surfaces = (ACCEPTED_FIELDS.partition(record, _reversed_indices(record), StandardMaterial3D.new()).surfaces as Array).size()
		var mesh := (node.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
		var ok := live_roots.is_empty() and _count_type(node, CollisionObject3D) == 1 \
			and mesh.get_surface_count() == expected_surfaces
		node.free()
		if not ok:
			return false
	return true


func _whole_island_matches() -> void:
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene failed to load for live-module whole-island proof."):
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var ready_reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready_reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready_reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 50000:
		await process_frame
	if not _require(failures.is_empty() and ready_reports.size() == 1, "Whole island did not reach one clean world_ready."):
		main.queue_free()
		await process_frame
		return
	var evidence := world.get_runtime_evidence()
	var receiver: Node3D = null
	var live_root_count := 0
	for candidate: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if candidate.name == "W34313564LiveModules":
			live_root_count += 1
		if str(candidate.get_meta("derived_object_key", "")) == RECEIVER_KEY and candidate.get_node_or_null("Mesh") != null:
			receiver = candidate as Node3D
	_require(evidence.chunks_loaded == 38 \
		and evidence.playable_rows == 735 and evidence.context_rows == 4 \
		and evidence.mesh_instances == 940 and evidence.surfaces == 954 and evidence.triangles == 64118 \
		and evidence.static_bodies == 466 and evidence.shapes == 466 \
		and live_root_count == 1 and receiver != null \
		and _count_type(receiver, MeshInstance3D) == 35 \
		and _count_surfaces(receiver) == 37 \
		and _count_type(receiver, CollisionObject3D) == 1 \
		and _count_type(receiver, CollisionShape3D) == 1, "Whole-island live-module topology or exact-one-target ownership drifted: chunks=%d meshes=%d surfaces=%d triangles=%d bodies=%d shapes=%d roots=%d receiver=%s receiver_meshes=%d receiver_surfaces=%d receiver_bodies=%d receiver_shapes=%d" % [evidence.chunks_loaded, evidence.mesh_instances, evidence.surfaces, evidence.triangles, evidence.static_bodies, evidence.shapes, live_root_count, receiver, _count_type(receiver, MeshInstance3D) if receiver != null else -1, _count_surfaces(receiver) if receiver != null else -1, _count_type(receiver, CollisionObject3D) if receiver != null else -1, _count_type(receiver, CollisionShape3D) if receiver != null else -1])
	main.queue_free()
	await process_frame
	await process_frame


func _record_for(receiver_key: String) -> Dictionary:
	var directory := DirAccess.open("res://generated/world/chunks")
	if directory == null:
		return {}
	for file_name: String in directory.get_files():
		if not file_name.ends_with(".json"):
			continue
		var chunk := JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/chunks/%s" % file_name)) as Dictionary
		for value: Variant in chunk.get("records", []):
			var record := value as Dictionary
			if str(record.get("object_key", "")) == receiver_key:
				return record
	return {}


func _module_for(root_node: Node3D, placement_id: String) -> Node3D:
	for child: Node in root_node.get_children():
		if str(child.get_meta("placement_id", "")) == placement_id:
			return child as Node3D
	return null


func _int_array_from_seen_runs(_seen: Dictionary, live_root: Node3D) -> Array[int]:
	var result: Array[int] = []
	for child: Node in live_root.get_children():
		result.append(int(child.get_meta("anchor_run", -1)))
	result.sort()
	return result


func _reversed_indices(record: Dictionary) -> PackedInt32Array:
	var result := PackedInt32Array()
	var values := record.get("indices", []) as Array
	for index in range(0, values.size(), 3):
		result.append(int(values[index]))
		result.append(int(values[index + 2]))
		result.append(int(values[index + 1]))
	return result


func _surface_triangles(mesh: ArrayMesh, surface_index: int) -> int:
	return int((mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _count_surfaces(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		count = (node as MeshInstance3D).mesh.get_surface_count()
	for child: Node in node.get_children():
		count += _count_surfaces(child)
	return count


func _free_result(result: Dictionary) -> void:
	if result.has("node") and is_instance_valid(result.node):
		(result.node as Node).free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
