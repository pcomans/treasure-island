extends SceneTree

const LIVE_MODULES := preload("res://game/scripts/world/facades/w34313515_live_modules.gd")
const REVIEWED_CALIBRATION := preload("res://game/tests/support/w34313515_module_calibration.gd")
const ACCEPTED_FIELDS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const RECEIVER_KEY := "building:w34313515:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_1.json"
const REGISTRY_PATH := "res://game/resources/facades/w34313515_module_calibration.json"
const ART_REVIEW_PATH := "res://discovery/facades/W34313515_BAY_CALIBRATION_ART_REVIEW.md"
const LIVE_ART_REVIEW_PATH := "res://discovery/facades/W34313515_LIVE_MODULES_ART_REVIEW.md"
const EXPECTED_REGISTRY_SHA256 := "2d378a94da4b7badd334d5c00f926a26a4ff9109782abb18e4859301df4b5c1d"
const EXPECTED_REVIEWED_CALIBRATION_SHA256 := "1edfdf4b736a7b1cc2883569a4c09b48814cabf30e3056e9dac86152de22d5f1"
const EXPECTED_ART_REVIEW_SHA256 := "894873141bc589e51bb8ec65e06455461e17a809a18608253db59c7e49e5fedd"
const EXPECTED_LIVE_ART_REVIEW_SHA256 := "cebfe328ec5372f8c0d440fcf59bb0b9bae7a490998ed373d8f5c5e418b5b94e"
const EXPECTED_PLACEMENTS := {
	"CAL-WSW-BAY-01": {"run": 0, "center_m": 6.0, "uncertainty_m": 1.2, "face": "WSW", "region": "observed_WSW_outer_elevation", "mapping_id": "B06-34313515-WSW-OUTER"},
	"CAL-WSW-BAY-02": {"run": 6, "center_m": 71.5, "uncertainty_m": 3.0, "face": "WSW", "region": "observed_WSW_outer_elevation", "mapping_id": "B06-34313515-WSW-OUTER"},
	"CAL-NNW-BAY-01": {"run": 44, "center_m": 14.0, "uncertainty_m": 3.0, "face": "NNW", "region": "observed_NNW_outer_elevation", "mapping_id": "B06-34313515-NNW-OUTER"},
	"CAL-NNW-BAY-02": {"run": 47, "center_m": 55.5, "uncertainty_m": 3.0, "face": "NNW", "region": "observed_NNW_outer_elevation", "mapping_id": "B06-34313515-NNW-OUTER"},
}
const PROTECTED_RECEIVERS := [
	"building:w34313564:wall",
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
	if not _require(_reviewed_inputs_match(), "Reviewed BAY registry, geometry helper, or independent art review identity drifted."):
		_finish()
		return
	var record := _record_for(RECEIVER_KEY)
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	if not _require(not record.is_empty(), "Exact w34313515 generated receiver did not resolve."):
		_finish()
		return
	var builder := WorldChunkBuilder.new()
	var first := builder._build_record(record, false)
	var second := builder._build_record(record, false)
	var detached := REVIEWED_CALIBRATION.build(record, registry)
	if not _require(bool(first.get("ok", false)) and bool(second.get("ok", false)) and bool(detached.get("ok", false)), "Live or detached reviewed BAY build failed: first=%s second=%s detached=%s" % [first.get("message", first.get("code", "unknown")), second.get("message", second.get("code", "unknown")), detached.get("message", detached.get("code", "unknown"))]):
		_free_result(first)
		_free_result(second)
		_free_result(detached)
		_finish()
		return
	var first_node := first.node as Node3D
	var second_node := second.node as Node3D
	var detached_node := detached.node as Node3D
	if not _require(_receiver_matches(first, record), "Exact live w34313515 receiver topology, field, collision, or BAY attachment contract failed.") \
	or not _require(_modules_match_reviewed(first_node, detached_node), "Live BAY modules drifted from the four reviewed transforms, resources, inference labels, or render-only contract.") \
	or not _require(_deterministic(first_node, second_node), "Live BAY receiver build is nondeterministic.") \
	or not _require(_protected_receivers_exclude_bay(builder), "A protected receiver gained w34313515 BAY modules."):
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
		print("PASS: exactly four independently KEEP_WITH_DOCUMENTED_LIMITATION w34313515 BAY module-atlas exemplars remain unchanged at WSW runs 0/6 and NNW runs 44/47; the distinct independently accepted w291196370 and w34313520 scopes remain isolated, and whole-island loaded topology is 729 records / 1278 meshes / 1288 surfaces / 55,067 triangles / 466 collider pairs")
	_finish()


func _reviewed_inputs_match() -> bool:
	return FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256 \
		and FileAccess.get_sha256("res://game/tests/support/w34313515_module_calibration.gd") == EXPECTED_REVIEWED_CALIBRATION_SHA256 \
		and FileAccess.get_sha256(ART_REVIEW_PATH) == EXPECTED_ART_REVIEW_SHA256 \
		and FileAccess.get_sha256(LIVE_ART_REVIEW_PATH) == EXPECTED_LIVE_ART_REVIEW_SHA256 \
		and "The lifecycle **may promote exactly these four rows**" in FileAccess.get_file_as_string(LIVE_ART_REVIEW_PATH) \
		and "whole-building acceptance" in FileAccess.get_file_as_string(LIVE_ART_REVIEW_PATH)


func _receiver_matches(result: Dictionary, record: Dictionary) -> bool:
	var node := result.node as Node3D
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var live := node.get_node_or_null("W34313515LiveModules") as Node3D
	var field_metadata := node.get_meta("accepted_material_run_trial", {}) as Dictionary
	var live_metadata := node.get_meta("w34313515_live_modules", {}) as Dictionary
	if node.get_child_count() != 3 or mesh == null or body == null or shape == null or live == null \
	or int(result.mesh_instances) != 85 or int(result.surfaces) != 86 or int(result.triangles) != 1104 \
	or mesh.get_surface_count() != 2 \
	or mesh.surface_get_name(0) != ACCEPTED_FIELDS.PLACEHOLDER_SURFACE_NAME \
	or mesh.surface_get_name(1) != "trial_w34313515_pale_runs" \
	or mesh.surface_get_material(1).resource_path != "res://game/resources/materials/world/w34313515/w34313515_pale_exact_trial.tres" \
	or field_metadata != ACCEPTED_FIELDS.metadata_for(RECEIVER_KEY) \
	or int(field_metadata.get("modules", -1)) != 4 \
	or int(field_metadata.get("standalone_modules_live", -1)) != 4 \
	or int(field_metadata.get("module_motif_types_live", -1)) != 1 \
	or str(field_metadata.get("module_placement_role", "")) != LIVE_MODULES.PLACEMENT_ROLE \
	or bool(field_metadata.get("module_cadence_inferred", true)) \
	or bool(field_metadata.get("module_total_opening_count_inferred", true)) \
	or int(live_metadata.get("module_instances", -1)) != 4 \
	or int(live_metadata.get("mesh_instances", -1)) != 84 \
	or int(live_metadata.get("surfaces", -1)) != 84 \
	or int(live_metadata.get("triangles", -1)) != 1008 \
	or int(live_metadata.get("field_meshes", -1)) != 0 \
	or int(live_metadata.get("backing_meshes", -1)) != 0 \
	or int(live_metadata.get("collision_nodes", -1)) != 0 \
	or int(live_metadata.get("navigation_nodes", -1)) != 0 \
	or int(live_metadata.get("spray_nodes", -1)) != 0 \
	or bool(live_metadata.get("coordinates_surveyed", true)) \
	or bool(live_metadata.get("count_surveyed", true)) \
	or bool(live_metadata.get("cadence_inferred", true)) \
	or bool(live_metadata.get("whole_building_accepted", true)) \
	or body.collision_layer != ((1 << 0) | (1 << 2)) or body.collision_mask != 0 \
	or not body.is_in_group("spray_receiver_wall") \
	or shape.get_faces().size() != (record.get("indices", []) as Array).size():
		return false
	return _surface_triangles(mesh, 0) == 68 and _surface_triangles(mesh, 1) == 28


func _modules_match_reviewed(live_receiver: Node3D, detached_root: Node3D) -> bool:
	var live_root := live_receiver.get_node("W34313515LiveModules") as Node3D
	if live_root.get_child_count() != 4 \
	or not bool(live_root.get_meta("runtime_attachment", false)) \
	or bool(live_root.get_meta("controlled_calibration", true)) \
	or str(live_root.get_meta("asset_classification", "")) != "module_atlas" \
	or _count_type(live_root, MeshInstance3D) != 84 \
	or _count_type(live_root, CollisionObject3D) != 0 \
	or _count_type(live_root, CollisionShape3D) != 0 \
	or _count_type(live_root, NavigationRegion3D) != 0 \
	or _count_type(live_root, Decal) != 0:
		return false
	var seen := {}
	for child: Node in live_root.get_children():
		var module := child as Node3D
		var placement_id := str(module.get_meta("placement_id", ""))
		var expected := EXPECTED_PLACEMENTS.get(placement_id, {}) as Dictionary
		var detached_module := _module_for(detached_root, placement_id)
		if expected.is_empty() or detached_module == null or seen.has(placement_id) \
		or not module.transform.is_equal_approx(detached_module.transform) \
		or str(module.get_meta("motif_id", "")) != "W34313515-BAY" \
		or module.get_meta("run_ownership", []) != [int(expected.run)] \
		or int(module.get_meta("anchor_run", -1)) != int(expected.run) \
		or not is_equal_approx(float(module.get_meta("center_chain_m", -1.0)), float(expected.center_m)) \
		or not is_equal_approx(float(module.get_meta("center_chain_uncertainty_m", -1.0)), float(expected.uncertainty_m)) \
		or str(module.get_meta("face", "")) != str(expected.face) \
		or str(module.get_meta("region", "")) != str(expected.region) \
		or str(module.get_meta("mapping_id", "")) != str(expected.mapping_id) \
		or str(module.get_meta("placement_role", "")) != LIVE_MODULES.PLACEMENT_ROLE \
		or str(module.get_meta("evidence_status", "")) != "production_inference" \
		or str(module.get_meta("coordinate_status", "")) != "stylized_reference_derived_inference_not_surveyed" \
		or str(module.get_meta("count_status", "")) != "bounded_exemplar_not_surveyed_total" \
		or str(module.get_meta("cadence_status", "")) != "unknown_not_surveyed_not_inferred" \
		or not bool(module.get_meta("runtime_attachment", false)) \
		or bool(module.get_meta("coordinates_surveyed", true)) \
		or bool(module.get_meta("count_surveyed", true)) \
		or bool(module.get_meta("module_owns_field_geometry", true)) \
		or not bool(module.get_meta("complete_motif", false)) \
		or not bool(module.get_meta("module_not_seamless_tile", false)) \
		or module.get_child_count() != 21:
			return false
		seen[placement_id] = true
		var glass_seen := 0
		var frame_seen := 0
		for mesh_value: Node in module.get_children():
			var mesh_instance := mesh_value as MeshInstance3D
			if mesh_instance == null or not (mesh_instance.mesh is BoxMesh) \
			or mesh_instance.layers != (1 << 1) or mesh_instance.material_override == null:
				return false
			var material_path := mesh_instance.material_override.resource_path
			if material_path == "res://game/resources/materials/world/w34313515/w34313515_glass.tres":
				glass_seen += 1
			elif material_path == "res://game/resources/materials/world/w34313515/w34313515_frame.tres":
				frame_seen += 1
			else:
				return false
			var box := mesh_instance.mesh as BoxMesh
			var back_clearance := REVIEWED_CALIBRATION.WALL_OFFSET_M + mesh_instance.position.z - box.size.z * 0.5
			var front_depth := REVIEWED_CALIBRATION.WALL_OFFSET_M + mesh_instance.position.z + box.size.z * 0.5
			if back_clearance < 0.001 or front_depth > 0.18:
				return false
		if glass_seen != 3 or frame_seen != 18:
			return false
	return seen.size() == 4 and _sorted_runs(live_root) == [0, 6, 44, 47]


func _deterministic(first: Node3D, second: Node3D) -> bool:
	var first_root := first.get_node("W34313515LiveModules") as Node3D
	var second_root := second.get_node("W34313515LiveModules") as Node3D
	if first_root.get_child_count() != second_root.get_child_count():
		return false
	for child: Node in first_root.get_children():
		var first_module := child as Node3D
		var second_module := _module_for(second_root, str(first_module.get_meta("placement_id", "")))
		if second_module == null or not first_module.transform.is_equal_approx(second_module.transform):
			return false
	return true


func _protected_receivers_exclude_bay(builder: WorldChunkBuilder) -> bool:
	for receiver_key: String in PROTECTED_RECEIVERS:
		var record := _record_for(receiver_key)
		if record.is_empty():
			return false
		var result := builder._build_record(record, false)
		if not bool(result.get("ok", false)):
			return false
		var node := result.node as Node3D
		var ok := node.find_children("W34313515LiveModules", "Node3D", true, false).is_empty()
		node.free()
		if not ok:
			return false
	return true


func _whole_island_matches() -> void:
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene failed to load for BAY live-integration proof."):
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
		if candidate.name == "W34313515LiveModules":
			live_root_count += 1
		if str(candidate.get_meta("derived_object_key", "")) == RECEIVER_KEY and candidate.get_node_or_null("Mesh") != null:
			receiver = candidate as Node3D
	_require(evidence.chunks_loaded == 38 \
		and evidence.mesh_instances == 1278 and evidence.surfaces == 1288 and evidence.triangles == 55067 \
		and evidence.static_bodies == 466 and evidence.shapes == 466 \
		and live_root_count == 1 and receiver != null \
		and _count_type(receiver, MeshInstance3D) == 85 \
		and _count_surfaces(receiver) == 86 \
		and _count_type(receiver, CollisionObject3D) == 1 \
		and _count_type(receiver, CollisionShape3D) == 1, "Whole-island BAY live-module topology or exact-one-target ownership drifted: chunks=%d meshes=%d surfaces=%d triangles=%d bodies=%d shapes=%d roots=%d receiver=%s receiver_meshes=%d receiver_surfaces=%d receiver_bodies=%d receiver_shapes=%d" % [evidence.chunks_loaded, evidence.mesh_instances, evidence.surfaces, evidence.triangles, evidence.static_bodies, evidence.shapes, live_root_count, receiver, _count_type(receiver, MeshInstance3D) if receiver != null else -1, _count_surfaces(receiver) if receiver != null else -1, _count_type(receiver, CollisionObject3D) if receiver != null else -1, _count_type(receiver, CollisionShape3D) if receiver != null else -1])
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


func _sorted_runs(live_root: Node3D) -> Array[int]:
	var result: Array[int] = []
	for child: Node in live_root.get_children():
		result.append(int(child.get_meta("anchor_run", -1)))
	result.sort()
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
	push_error("W34313515_LIVE_MODULE_INTEGRATION_FAIL: %s" % message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
