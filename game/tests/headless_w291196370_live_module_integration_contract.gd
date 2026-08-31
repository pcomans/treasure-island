extends SceneTree

const LIVE_MODULES := preload("res://game/scripts/world/facades/w291196370_live_modules.gd")
const REVIEWED_CALIBRATION := preload("res://game/tests/support/w291196370_module_calibration.gd")
const ACCEPTED_FIELDS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const RECEIVER_KEY := "building:w291196370:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-3.json"
const REGISTRY_PATH := "res://game/resources/facades/w291196370_module_calibration.json"
const ART_REVIEW_PATH := "res://discovery/facades/W291196370_MODULE_CALIBRATION_ART_REVIEW.md"
const LIVE_ART_REVIEW_PATH := "res://discovery/facades/W291196370_LIVE_MODULES_ART_REVIEW.md"
const EXPECTED_REGISTRY_SHA256 := "b30a8f19091288cde4b8e891ec40287ab28a73776588f96ee86fc5565cfc25b8"
const EXPECTED_REVIEWED_CALIBRATION_SHA256 := "ba621cffc5ee155e8b7c7338c3b5d444d1180dad6dbe11528219ada6de05dfdf"
const EXPECTED_ART_REVIEW_SHA256 := "967ab07d109096a743be01fb0bce959280967f5eab65c82ac0652eb5dcd3023b"
const EXPECTED_LIVE_ART_REVIEW_SHA256 := "410ffa891bdebe92d689155b4c7986f7e9a07bef1028900cd0dac00bcb8222ca"
const EXPECTED_LIVE_ADAPTER_SHA256 := "e297d40ac9841485ee00a76b955f8ec454639b394c23759e8017e170aa84cbf8"
const EXPECTED_PLACEMENTS := {
	"CAL-SSE-WINSTACK-01": {"motif_id": "W291196370-WINSTACK", "run": 8, "center_m": 5.5, "uncertainty_m": 2.0, "face": "SSE", "region": "observed_SSE_public_elevation", "mapping_id": "B06-291196370-SSE-PUBLIC", "mesh_count": 7},
	"CAL-SSE-ENTRY-01": {"motif_id": "W291196370-ENTRY", "run": 10, "center_m": 32.0, "uncertainty_m": 3.0, "face": "SSE", "region": "observed_SSE_public_elevation", "mapping_id": "B06-291196370-SSE-PUBLIC", "mesh_count": 5},
	"CAL-ENE-SERVICE-01": {"motif_id": "W291196370-SERVICE", "run": 20, "center_m": 39.5, "uncertainty_m": 4.0, "face": "ENE", "region": "observed_ENE_outer_end", "mapping_id": "B06-291196370-ENE-OUTER", "mesh_count": 12},
}
const PROTECTED_RECEIVERS := [
	"building:w34313564:wall",
	"building:w34313515:wall",
	"building:w34313547:wall",
	"building:w291189336:wall",
	"building:w291189926:wall",
	"building:w764313741:wall",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(_reviewed_inputs_match(), "Reviewed w291196370 registry, geometry helper, or independent detached art review identity drifted."):
		_finish()
		return
	var record := _record_for(RECEIVER_KEY)
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	if not _require(not record.is_empty(), "Exact w291196370 generated receiver did not resolve."):
		_finish()
		return
	var builder := WorldChunkBuilder.new()
	var first := builder._build_record(record, false)
	var second := builder._build_record(record, false)
	var detached := REVIEWED_CALIBRATION.build(record, registry)
	if not _require(bool(first.get("ok", false)) and bool(second.get("ok", false)) and bool(detached.get("ok", false)), "Live or detached reviewed w291196370 build failed: first=%s second=%s detached=%s" % [first.get("message", first.get("code", "unknown")), second.get("message", second.get("code", "unknown")), detached.get("message", detached.get("code", "unknown"))]):
		_free_result(first)
		_free_result(second)
		_free_result(detached)
		_finish()
		return
	var first_node := first.node as Node3D
	var second_node := second.node as Node3D
	var detached_node := detached.node as Node3D
	if not _require(_receiver_matches(first, record), "Exact live w291196370 receiver topology, siding field, collision, or module attachment contract failed.") \
	or not _require(_modules_match_reviewed(first_node, detached_node), "Live modules drifted from the three reviewed transforms, resources, inference labels, or render-only contract.") \
	or not _require(_deterministic(first_node, second_node), "Live w291196370 receiver build is nondeterministic.") \
	or not _require(_protected_receivers_exclude_modules(builder), "A protected receiver gained w291196370 module geometry."):
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
		print("PASS: exactly three independently KEEP_WITH_DOCUMENTED_LIMITATION w291196370 complete module-atlas exemplars remain unchanged at SSE runs 8/10 and ENE run 20; the distinct independently accepted w34313520 scope remains isolated, and whole-island loaded topology is 729 records / 1278 meshes / 1288 surfaces / 55,067 triangles / 466 collider pairs")
	_finish()


func _reviewed_inputs_match() -> bool:
	var review := FileAccess.get_file_as_string(ART_REVIEW_PATH)
	var live_review := FileAccess.get_file_as_string(LIVE_ART_REVIEW_PATH)
	return FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256 \
		and FileAccess.get_sha256("res://game/tests/support/w291196370_module_calibration.gd") == EXPECTED_REVIEWED_CALIBRATION_SHA256 \
		and FileAccess.get_sha256(ART_REVIEW_PATH) == EXPECTED_ART_REVIEW_SHA256 \
		and FileAccess.get_sha256(LIVE_ART_REVIEW_PATH) == EXPECTED_LIVE_ART_REVIEW_SHA256 \
		and FileAccess.get_sha256("res://game/scripts/world/facades/w291196370_live_modules.gd") == EXPECTED_LIVE_ADAPTER_SHA256 \
		and "All three exact placements are eligible for a bounded live-integration proof at their registered transforms." in review \
		and "Subsequent actual-world review remains required." in review \
		and "Whole-building resemblance" in review \
		and "Aggregate actual-world verdict: `KEEP_WITH_DOCUMENTED_LIMITATION`" in live_review \
		and "The lifecycle may promote **exactly these three rows**" in live_review \
		and "whole-building resemblance" in live_review


func _receiver_matches(result: Dictionary, record: Dictionary) -> bool:
	var node := result.node as Node3D
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var live := node.get_node_or_null("W291196370LiveModules") as Node3D
	var field_metadata := node.get_meta("accepted_material_run_trial", {}) as Dictionary
	var live_metadata := node.get_meta("w291196370_live_modules", {}) as Dictionary
	if node.get_child_count() != 3 or mesh == null or body == null or shape == null or live == null \
	or int(result.mesh_instances) != 25 or int(result.surfaces) != 26 or int(result.triangles) != 360 \
	or mesh.get_surface_count() != 2 \
	or mesh.surface_get_name(0) != ACCEPTED_FIELDS.PLACEHOLDER_SURFACE_NAME \
	or mesh.surface_get_name(1) != "trial_w291196370_siding_runs" \
	or mesh.surface_get_material(1).resource_path != "res://game/resources/materials/world/w291196370/w291196370_siding_exact_trial.tres" \
	or field_metadata != ACCEPTED_FIELDS.metadata_for(RECEIVER_KEY) \
	or int(field_metadata.get("modules", -1)) != 3 \
	or int(field_metadata.get("standalone_modules_live", -1)) != 3 \
	or int(field_metadata.get("module_motif_types_live", -1)) != 3 \
	or str(field_metadata.get("module_placement_role", "")) != LIVE_MODULES.PLACEMENT_ROLE \
	or field_metadata.get("module_position_uncertainty_by_placement_m", {}) != {"CAL-SSE-WINSTACK-01": 2.0, "CAL-SSE-ENTRY-01": 3.0, "CAL-ENE-SERVICE-01": 4.0} \
	or bool(field_metadata.get("module_cadence_inferred", true)) \
	or bool(field_metadata.get("module_total_opening_count_inferred", true)) \
	or int(live_metadata.get("module_instances", -1)) != 3 \
	or int(live_metadata.get("mesh_instances", -1)) != 24 \
	or int(live_metadata.get("surfaces", -1)) != 24 \
	or int(live_metadata.get("triangles", -1)) != 288 \
	or int(live_metadata.get("field_meshes", -1)) != 0 \
	or int(live_metadata.get("backing_meshes", -1)) != 0 \
	or int(live_metadata.get("collision_nodes", -1)) != 0 \
	or int(live_metadata.get("navigation_nodes", -1)) != 0 \
	or int(live_metadata.get("spray_nodes", -1)) != 0 \
	or bool(live_metadata.get("coordinates_surveyed", true)) \
	or bool(live_metadata.get("scale_surveyed", true)) \
	or bool(live_metadata.get("count_surveyed", true)) \
	or bool(live_metadata.get("cadence_inferred", true)) \
	or bool(live_metadata.get("completed_sse_elevation", true)) \
	or bool(live_metadata.get("completed_ene_elevation", true)) \
	or bool(live_metadata.get("cross_side_transfer_accepted", true)) \
	or bool(live_metadata.get("whole_building_accepted", true)) \
	or body.collision_layer != ((1 << 0) | (1 << 2)) or body.collision_mask != 0 \
	or not body.is_in_group("spray_receiver_wall") \
	or shape.get_faces().size() != (record.get("indices", []) as Array).size():
		return false
	return _surface_triangles(mesh, 0) == 54 and _surface_triangles(mesh, 1) == 18


func _modules_match_reviewed(live_receiver: Node3D, detached_root: Node3D) -> bool:
	var live_root := live_receiver.get_node("W291196370LiveModules") as Node3D
	if live_root.get_child_count() != 3 \
	or not bool(live_root.get_meta("runtime_attachment", false)) \
	or bool(live_root.get_meta("controlled_calibration", true)) \
	or str(live_root.get_meta("asset_classification", "")) != "module_atlas" \
	or _count_type(live_root, MeshInstance3D) != 24 \
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
		or str(module.get_meta("motif_id", "")) != str(expected.motif_id) \
		or module.get_meta("run_ownership", []) != [int(expected.run)] \
		or int(module.get_meta("anchor_run", -1)) != int(expected.run) \
		or not is_equal_approx(float(module.get_meta("center_chain_m", -1.0)), float(expected.center_m)) \
		or not is_equal_approx(float(module.get_meta("center_chain_uncertainty_m", -1.0)), float(expected.uncertainty_m)) \
		or str(module.get_meta("face", "")) != str(expected.face) \
		or str(module.get_meta("region", "")) != str(expected.region) \
		or str(module.get_meta("mapping_id", "")) != str(expected.mapping_id) \
		or str(module.get_meta("host_material_id", "")) != "W291196370-SIDING" \
		or str(module.get_meta("placement_role", "")) != LIVE_MODULES.PLACEMENT_ROLE \
		or str(module.get_meta("evidence_status", "")) != "production_inference" \
		or str(module.get_meta("coordinate_status", "")) != "stylized_reference_derived_inference_not_surveyed" \
		or str(module.get_meta("count_status", "")) != "bounded_exemplar_not_surveyed_total" \
		or str(module.get_meta("cadence_status", "")) != "unknown_not_surveyed_not_inferred" \
		or not bool(module.get_meta("runtime_attachment", false)) \
		or bool(module.get_meta("coordinates_surveyed", true)) \
		or bool(module.get_meta("scale_surveyed", true)) \
		or bool(module.get_meta("count_surveyed", true)) \
		or bool(module.get_meta("module_owns_field_geometry", true)) \
		or not bool(module.get_meta("complete_motif", false)) \
		or not bool(module.get_meta("module_not_seamless_tile", false)) \
		or module.get_child_count() != int(expected.mesh_count):
			return false
		seen[placement_id] = true
		for mesh_value: Node in module.get_children():
			var mesh_instance := mesh_value as MeshInstance3D
			if mesh_instance == null or not (mesh_instance.mesh is BoxMesh) \
			or mesh_instance.layers != (1 << 1) or mesh_instance.material_override == null \
			or "field" in str(mesh_instance.name).to_lower() \
			or "backing" in str(mesh_instance.name).to_lower() \
			or "surround" in str(mesh_instance.name).to_lower():
				return false
			var box := mesh_instance.mesh as BoxMesh
			var back_clearance := REVIEWED_CALIBRATION.WALL_OFFSET_M + mesh_instance.position.z - box.size.z * 0.5
			var front_depth := REVIEWED_CALIBRATION.WALL_OFFSET_M + mesh_instance.position.z + box.size.z * 0.5
			if back_clearance < 0.001 or front_depth > 0.18:
				return false
	return seen.size() == 3 and _sorted_runs(live_root) == [8, 10, 20]


func _deterministic(first: Node3D, second: Node3D) -> bool:
	var first_root := first.get_node("W291196370LiveModules") as Node3D
	var second_root := second.get_node("W291196370LiveModules") as Node3D
	if first_root.get_child_count() != second_root.get_child_count():
		return false
	for child: Node in first_root.get_children():
		var first_module := child as Node3D
		var second_module := _module_for(second_root, str(first_module.get_meta("placement_id", "")))
		if second_module == null or not first_module.transform.is_equal_approx(second_module.transform):
			return false
	return true


func _protected_receivers_exclude_modules(builder: WorldChunkBuilder) -> bool:
	for receiver_key: String in PROTECTED_RECEIVERS:
		var record := _record_for(receiver_key)
		if record.is_empty():
			return false
		var result := builder._build_record(record, false)
		if not bool(result.get("ok", false)):
			return false
		var node := result.node as Node3D
		var ok := node.find_children("W291196370LiveModules", "Node3D", true, false).is_empty()
		node.free()
		if not ok:
			return false
	return true


func _whole_island_matches() -> void:
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene failed to load for w291196370 live-integration proof."):
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
		if candidate.name == "W291196370LiveModules":
			live_root_count += 1
		if str(candidate.get_meta("derived_object_key", "")) == RECEIVER_KEY and candidate.get_node_or_null("Mesh") != null:
			receiver = candidate as Node3D
	_require(evidence.chunks_loaded == 38 \
		and evidence.mesh_instances == 1278 and evidence.surfaces == 1288 and evidence.triangles == 55067 \
		and evidence.static_bodies == 466 and evidence.shapes == 466 \
		and live_root_count == 1 and receiver != null \
		and _count_type(receiver, MeshInstance3D) == 25 \
		and _count_surfaces(receiver) == 26 \
		and _count_type(receiver, CollisionObject3D) == 1 \
		and _count_type(receiver, CollisionShape3D) == 1, "Whole-island w291196370 live-module topology or exact-one-target ownership drifted: chunks=%d meshes=%d surfaces=%d triangles=%d bodies=%d shapes=%d roots=%d receiver=%s receiver_meshes=%d receiver_surfaces=%d receiver_bodies=%d receiver_shapes=%d" % [evidence.chunks_loaded, evidence.mesh_instances, evidence.surfaces, evidence.triangles, evidence.static_bodies, evidence.shapes, live_root_count, receiver, _count_type(receiver, MeshInstance3D) if receiver != null else -1, _count_surfaces(receiver) if receiver != null else -1, _count_type(receiver, CollisionObject3D) if receiver != null else -1, _count_type(receiver, CollisionShape3D) if receiver != null else -1])
	main.queue_free()
	await process_frame
	await process_frame


func _record_for(receiver_key: String) -> Dictionary:
	for chunk_name: String in ["x_-1__z_1.json", "x_0__z_-3.json", "x_0__z_-1.json", "x_0__z_0.json"]:
		var path := "res://generated/world/chunks/%s" % chunk_name
		var chunk := JSON.parse_string(FileAccess.get_file_as_string(path)) as Dictionary
		for value: Variant in chunk.get("records", []):
			var record := value as Dictionary
			if str(record.get("object_key", "")) == receiver_key:
				return record
	return _record_from_all_chunks(receiver_key)


func _record_from_all_chunks(receiver_key: String) -> Dictionary:
	for path: String in DirAccess.get_files_at("res://generated/world/chunks"):
		if not path.ends_with(".json"):
			continue
		var chunk := JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/chunks/%s" % path)) as Dictionary
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


func _sorted_runs(root_node: Node3D) -> Array[int]:
	var result: Array[int] = []
	for child: Node in root_node.get_children():
		result.append(int(child.get_meta("anchor_run", -1)))
	result.sort()
	return result


func _surface_triangles(mesh: ArrayMesh, surface_index: int) -> int:
	var arrays := mesh.surface_get_arrays(surface_index)
	return int((arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)


func _count_surfaces(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D:
		var mesh := (node as MeshInstance3D).mesh
		count = mesh.get_surface_count() if mesh != null else 0
	for child: Node in node.get_children():
		count += _count_surfaces(child)
	return count


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _free_result(result: Dictionary) -> void:
	var node := result.get("node") as Node
	if node != null:
		node.free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
