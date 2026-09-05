extends SceneTree

const LIVE_MODULES := preload("res://game/scripts/world/facades/w34313525_live_modules.gd")
const REVIEWED_CALIBRATION := preload("res://game/tests/support/w34313525_exact_receiver_calibration.gd")
const ACCEPTED_FIELDS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const CHAPEL_ISOLATION := preload("res://game/tests/support/navy_chapel_187_protected_receiver_test_support.gd")
const RECEIVER_KEY := "building:w34313525:wall"
const REGISTRY_PATH := "res://game/resources/facades/w34313525_exact_receiver_calibration.json"
const REVIEW_PATH := "res://discovery/facades/W34313525_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md"
const LIVE_REVIEW_PATH := "res://discovery/facades/W34313525_LIVE_FIELDS_AND_MODULES_ART_REVIEW.md"
const INVENTORY_PATH := "res://discovery/FACADE_RECEIVER_INVENTORY.json"
const EXPECTED_REGISTRY_SHA256 := "ba22916618510f610719606c1c18f84b8965bbd76fe74eddc5430745470bbddd"
const EXPECTED_HELPER_SHA256 := "a9ff1f94274509cdb39c6208117c59b84ba67598ff8a59a1eb57bf30a4b03532"
const EXPECTED_REVIEW_SHA256 := "d19fdae403d11117b13ce1fe04476f0d62edfdd3adbc8238936845e481831de2"
const EXPECTED_LIVE_REVIEW_SHA256 := "d11041e1abf41fc11843d2f2631e4c33da25f8fc565f93e6ee822589ad229f45"
const EXPECTED_MODULES := {
	"CAL_SSE_ROLLUP_PALE_01": ["CAL-SSE-ROLLUP-PALE-01", "W34313525-ROLLUP-PALE", "SSE", 9, 13, 156],
	"CAL_SSE_ROLLUP_GRAY_01": ["CAL-SSE-ROLLUP-GRAY-01", "W34313525-ROLLUP-GRAY", "SSE", 10, 13, 156],
	"CAL_NNW_PERSONNEL_01": ["CAL-NNW-PERSONNEL-01", "W34313525-PERSONNEL", "NNW", 26, 5, 60],
	"CAL_NNW_HIGH_GROUP_01": ["CAL-NNW-HIGH-GROUP-01", "W34313525-HIGH-GROUP", "NNW", 27, 7, 84],
}
const PROTECTED_RECEIVERS := [
	"building:w34313564:wall",
	"building:w34313515:wall",
	"building:w291196370:wall",
	"building:w34313520:wall",
	"building:w34313547:wall",
	"building:w291189336:wall",
	"building:w291189926:wall",
	"building:w764313741:wall",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Reviewed registry bytes drifted.") \
	or not _require(FileAccess.get_sha256("res://game/tests/support/w34313525_exact_receiver_calibration.gd") == EXPECTED_HELPER_SHA256, "Reviewed exact helper bytes drifted.") \
	or not _require(FileAccess.get_sha256(REVIEW_PATH) == EXPECTED_REVIEW_SHA256, "Independent calibration review bytes drifted.") \
	or not _require(FileAccess.get_sha256(LIVE_REVIEW_PATH) == EXPECTED_LIVE_REVIEW_SHA256, "Independent actual-world review bytes drifted.") \
	or not _require(_current_lifecycle_is_independently_accepted(), "Canonical lifecycle does not preserve the reviewed w34313525 scopes distinctly from the one pending Building 1 field."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var record := _record_for(RECEIVER_KEY)
	if not _require(not registry.is_empty() and not record.is_empty(), "Reviewed registry or generated receiver did not resolve."):
		_finish()
		return
	var builder := WorldChunkBuilder.new()
	var first := builder._build_record(record, false)
	var second := builder._build_record(record, false)
	var detached := REVIEWED_CALIBRATION.build(record, registry)
	if not _require(bool(first.get("ok", false)) and bool(second.get("ok", false)) and bool(detached.get("ok", false)), "Live or detached build failed: first=%s second=%s detached=%s" % [first.get("message", first.get("code", "unknown")), second.get("message", second.get("code", "unknown")), detached.get("message", detached.get("code", "unknown"))]):
		_free_result(first)
		_free_result(second)
		_free_result(detached)
		_finish()
		return
	var first_node := first.node as Node3D
	var second_node := second.node as Node3D
	var detached_root := detached.node as Node3D
	if not _require(_receiver_matches(first, record), "Exact two-field/four-module receiver topology, material, or immutable integration-time metadata failed.") \
	or not _require(_live_matches_reviewed(first_node, detached_root), "Live modules drifted from the reviewed transforms, complete geometry, materials, or truth labels.") \
	or not _require(_deterministic(first_node, second_node), "Live w34313525 receiver build is nondeterministic.") \
	or not _require(_protected_receivers_exclude_scope(builder), "Another receiver gained w34313525 scope."):
		first_node.free()
		second_node.free()
		detached_root.free()
		_finish()
		return
	first_node.free()
	second_node.free()
	detached_root.free()
	await _whole_island_matches()
	if not _failed:
		print("PASS: w34313525 is independently accepted live only on exact MAT-PALE SSE runs 8..12 and NNW runs 26..27 with two reviewed 0.88/0.31 m field surfaces, plus exactly four transform-identical backing-free module-atlas exemplars; its own pending actual-world review is zero and B201-inclusive whole-island topology is 735/950/964/66,636/466/466 (playable rows/meshes/surfaces/triangles/bodies/shapes)")
	_finish()


func _receiver_matches(result: Dictionary, record: Dictionary) -> bool:
	var node := result.node as Node3D
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var live := node.get_node_or_null("W34313525LiveModules") as Node3D
	var field_metadata := node.get_meta("accepted_material_run_trial", {}) as Dictionary
	var live_metadata := node.get_meta("w34313525_live_modules", {}) as Dictionary
	if node.get_child_count() != 3 or mesh == null or body == null or shape == null or live == null \
	or int(result.mesh_instances) != 39 or int(result.surfaces) != 41 or int(result.triangles) != 516 \
	or mesh.get_surface_count() != 3 \
	or mesh.surface_get_name(0) != ACCEPTED_FIELDS.PLACEHOLDER_SURFACE_NAME \
	or mesh.surface_get_name(1) != "trial_w34313525_pale_sse_runs" \
	or mesh.surface_get_name(2) != "trial_w34313525_pale_nnw_runs" \
	or _surface_triangles(mesh, 0) != 46 or _surface_triangles(mesh, 1) != 10 or _surface_triangles(mesh, 2) != 4 \
	or mesh.surface_get_material(1).resource_path != "res://game/resources/materials/world/w34313525/w34313525_pale_exact_trial.tres" \
	or mesh.surface_get_material(2).resource_path != "res://game/resources/materials/world/w34313525/w34313525_pale_exact_trial.tres" \
	or field_metadata != ACCEPTED_FIELDS.metadata_for(RECEIVER_KEY) \
	or str(field_metadata.get("status", "")) != "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending" \
	or str(field_metadata.get("field_actual_world_review_status", "")) != LIVE_MODULES.ACTUAL_WORLD_REVIEW_STATUS \
	or int(field_metadata.get("material_groups", []).size()) != 2 \
	or int(field_metadata.get("modules", -1)) != 4 \
	or int(field_metadata.get("module_motif_types_live", -1)) != 4 \
	or int(live_metadata.get("module_instances", -1)) != 4 \
	or int(live_metadata.get("mesh_instances", -1)) != 38 \
	or int(live_metadata.get("surfaces", -1)) != 38 \
	or int(live_metadata.get("triangles", -1)) != 456 \
	or int(live_metadata.get("field_meshes", -1)) != 0 \
	or int(live_metadata.get("backing_meshes", -1)) != 0 \
	or int(live_metadata.get("collision_nodes", -1)) != 0 \
	or int(live_metadata.get("navigation_nodes", -1)) != 0 \
	or int(live_metadata.get("spray_nodes", -1)) != 0 \
	or str(live_metadata.get("actual_world_review_status", "")) != LIVE_MODULES.ACTUAL_WORLD_REVIEW_STATUS \
	or str(live_metadata.get("high_group_semantic_face_status", "")) != "window_or_grille_not_disambiguated_opaque_proxy_only" \
	or bool(live_metadata.get("surveyed_dimensions", true)) \
	or bool(live_metadata.get("surveyed_coordinates", true)) \
	or bool(live_metadata.get("surveyed_scale", true)) \
	or bool(live_metadata.get("surveyed_count", true)) \
	or bool(live_metadata.get("surveyed_cadence", true)) \
	or bool(live_metadata.get("sequence_inferred", true)) \
	or bool(live_metadata.get("maximum_uncertainty_envelope_contained_for_all_modules", true)) \
	or bool(live_metadata.get("completed_sse_elevation", true)) \
	or bool(live_metadata.get("completed_nnw_elevation", true)) \
	or bool(live_metadata.get("whole_building_accepted", true)) \
	or body.collision_layer != ((1 << 0) | (1 << 2)) or body.collision_mask != 0 \
	or not body.is_in_group("spray_receiver_wall") \
	or shape.get_faces().size() != (record.get("indices", []) as Array).size():
		return false
	for surface_index in [1, 2]:
		var material := mesh.surface_get_material(surface_index) as ShaderMaterial
		if material == null or not is_equal_approx(float(material.get_shader_parameter("primary_scale_m")), 0.88) \
		or not is_equal_approx(float(material.get_shader_parameter("secondary_scale_m")), 0.31):
			return false
	return true


func _current_lifecycle_is_independently_accepted() -> bool:
	var inventory := JSON.parse_string(FileAccess.get_file_as_string(INVENTORY_PATH)) as Dictionary
	if inventory.is_empty():
		return false
	var runtime := inventory.get("runtime_material_contract", {}) as Dictionary
	var batch := inventory.get("batch_06_lifecycle_reconciliation", {}) as Dictionary
	var accepted_fields := batch.get("accepted_exact_field_summary", {}) as Dictionary
	var accepted_modules := batch.get("accepted_live_module_summary", {}) as Dictionary
	var target_modules := batch.get("accepted_live_module_summary_w34313525", {}) as Dictionary
	var accepted_scopes := batch.get("accepted_exact_field_scopes", []) as Array
	var target_scope_count := 0
	for value: Variant in accepted_scopes:
		var scope := value as Dictionary
		if str(scope.get("source_key", "")) == "w34313525" \
		and str(scope.get("actual_world_art_review_status", "")) == "independently_reviewed_keep_with_documented_limitation" \
		and str(scope.get("independent_live_review_sha256", "")) == EXPECTED_LIVE_REVIEW_SHA256:
			target_scope_count += 1
	return target_scope_count == 2 \
		and int(accepted_fields.get("target_receiver_count", -1)) == 6 \
		and int(accepted_fields.get("field_scope_count", -1)) == 8 \
		and int(accepted_fields.get("run_count", -1)) == 113 \
		and int(accepted_modules.get("target_receiver_count", -1)) == 6 \
		and int(accepted_modules.get("placement_count", -1)) == 62 \
		and int(target_modules.get("placement_count", -1)) == 4 \
		and str(target_modules.get("live_review_verdict", "")) == "KEEP_WITH_DOCUMENTED_LIMITATION" \
		and str(target_modules.get("actual_world_art_review_status", "")) == "independently_reviewed_keep_with_documented_limitation" \
		and str(target_modules.get("independent_live_review_sha256", "")) == EXPECTED_LIVE_REVIEW_SHA256 \
		and not bool(target_modules.get("surveyed_dimensions_proven", true)) \
		and not bool(target_modules.get("surveyed_scale_proven", true)) \
		and not bool(target_modules.get("surveyed_coordinates_proven", true)) \
		and not bool(target_modules.get("real_opening_count_proven", true)) \
		and not bool(target_modules.get("cadence_proven", true)) \
		and not bool(target_modules.get("sequence_proven", true)) \
		and not bool(target_modules.get("high_group_semantic_face_resolved", true)) \
		and not bool(target_modules.get("completed_sse_elevation_proven", true)) \
		and not bool(target_modules.get("completed_nnw_elevation_proven", true)) \
		and not bool(target_modules.get("whole_building_accepted", true)) \
		and int(runtime.get("accepted_exact_run_material_attachment_count", -1)) == 9 \
		and int(runtime.get("accepted_exact_field_scope_count", -1)) == 11 \
		and int(runtime.get("accepted_exact_run_count", -1)) == 130 \
		and is_equal_approx(float(runtime.get("accepted_exact_run_length_m", -1.0)), 1024.828178) \
		and is_equal_approx(float(runtime.get("accepted_exact_run_wall_area_m2", -1.0)), 10476.046427) \
		and int(runtime.get("accepted_live_module_target_receiver_count", -1)) == 6 \
		and int(runtime.get("accepted_live_module_placement_count", -1)) == 62 \
		and int(runtime.get("accepted_live_module_mesh_count", -1)) == 546 \
		and int(runtime.get("accepted_live_module_triangle_count", -1)) == 6552 \
		and (runtime.get("pending_independent_actual_world_art_review_runtime_attachments", []) as Array).is_empty() \
		and (batch.get("pending_independent_actual_world_art_review_exact_field_scopes", []) as Array).is_empty()


func _live_matches_reviewed(live_receiver: Node3D, detached_root: Node3D) -> bool:
	var live_root := live_receiver.get_node("W34313525LiveModules") as Node3D
	if live_root.get_child_count() != 4 or _count_type(live_root, MeshInstance3D) != 38 \
	or _count_surfaces(live_root) != 38 or _count_triangles(live_root) != 456 \
	or _count_type(live_root, CollisionObject3D) != 0 \
	or _count_type(live_root, CollisionShape3D) != 0 \
	or _count_type(live_root, NavigationRegion3D) != 0 \
	or _count_type(live_root, Decal) != 0:
		return false
	for module_name: String in EXPECTED_MODULES:
		var expected := EXPECTED_MODULES[module_name] as Array
		var live_module := live_root.get_node_or_null(module_name) as Node3D
		var detached_module := detached_root.get_node_or_null(module_name) as Node3D
		if live_module == null or detached_module == null \
		or not live_module.transform.is_equal_approx(detached_module.transform) \
		or str(live_module.get_meta("placement_id", "")) != str(expected[0]) \
		or str(live_module.get_meta("face", "")) != str(expected[2]) \
		or live_module.get_meta("run_ownership", []) != [int(expected[3])] \
		or live_module.get_meta("exact_ordered_runs", []) != [int(expected[3])] \
		or live_module.get_child_count() != int(expected[4]) \
		or _count_triangles(live_module) != int(expected[5]) \
		or not bool(live_module.get_meta("runtime_attachment", false)) \
		or bool(live_module.get_meta("coordinates_surveyed", true)) \
		or bool(live_module.get_meta("dimensions_surveyed", true)) \
		or bool(live_module.get_meta("scale_surveyed", true)) \
		or bool(live_module.get_meta("count_surveyed", true)) \
		or bool(live_module.get_meta("cadence_surveyed", true)) \
		or bool(live_module.get_meta("cadence_inferred", true)) \
		or bool(live_module.get_meta("sequence_inferred", true)) \
		or bool(live_module.get_meta("module_owns_field_geometry", true)) \
		or not bool(live_module.get_meta("complete_motif", false)) \
		or not bool(live_module.get_meta("module_not_seamless_tile", false)):
			return false
		for child: Node in live_module.get_children():
			var live_mesh := child as MeshInstance3D
			var detached_mesh := detached_module.get_node_or_null(NodePath(str(child.name))) as MeshInstance3D
			if live_mesh == null or detached_mesh == null \
			or not (live_mesh.mesh is BoxMesh) or not (detached_mesh.mesh is BoxMesh) \
			or (live_mesh.mesh as BoxMesh).size != (detached_mesh.mesh as BoxMesh).size \
			or live_mesh.material_override != detached_mesh.material_override \
			or live_mesh.transform != detached_mesh.transform \
			or live_mesh.layers != (1 << 1) \
			or "field" in str(live_mesh.name).to_lower() \
			or "backing" in str(live_mesh.name).to_lower() \
			or "surround" in str(live_mesh.name).to_lower():
				return false
	return str((live_root.get_node("CAL_NNW_HIGH_GROUP_01") as Node3D).get_meta("semantic_face_status", "")) == "window_or_grille_not_disambiguated_opaque_proxy_only"


func _deterministic(first: Node3D, second: Node3D) -> bool:
	var first_root := first.get_node("W34313525LiveModules") as Node3D
	var second_root := second.get_node("W34313525LiveModules") as Node3D
	if first.get_meta("accepted_material_run_trial", {}) != second.get_meta("accepted_material_run_trial", {}) \
	or first.get_meta("w34313525_live_modules", {}) != second.get_meta("w34313525_live_modules", {}):
		return false
	for module_name: String in EXPECTED_MODULES:
		if (first_root.get_node(module_name) as Node3D).transform != (second_root.get_node(module_name) as Node3D).transform:
			return false
	return true


func _protected_receivers_exclude_scope(builder: WorldChunkBuilder) -> bool:
	for receiver_key: String in PROTECTED_RECEIVERS:
		if receiver_key == CHAPEL_ISOLATION.WALL_KEY:
			if not CHAPEL_ISOLATION.exact_pair_excludes_module_family("W34313525LiveModules"):
				return false
			continue
		var record := _record_for(receiver_key)
		if record.is_empty():
			return false
		var result := builder._build_record(record, false)
		if not bool(result.get("ok", false)):
			return false
		var node := result.node as Node3D
		var ok := node.find_children("W34313525LiveModules", "Node3D", true, false).is_empty()
		node.free()
		if not ok:
			return false
	return true


func _whole_island_matches() -> void:
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene failed to load for w34313525 live proof."):
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
	if not _require(failures.is_empty() and ready_reports.size() == 1, "Whole island did not reach one clean world_ready: %s" % JSON.stringify(failures)):
		main.queue_free()
		await process_frame
		return
	var evidence := world.get_runtime_evidence()
	var receiver: Node3D = null
	var live_root_count := 0
	for candidate: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if candidate.name == "W34313525LiveModules":
			live_root_count += 1
		if str(candidate.get_meta("derived_object_key", "")) == RECEIVER_KEY and candidate.get_node_or_null("Mesh") != null:
			receiver = candidate as Node3D
	_require(int(evidence.chunks_loaded) == 38 \
		and int(evidence.playable_rows) == 735 and int(evidence.context_rows) == 4 \
		and int(evidence.mesh_instances) == 950 and int(evidence.surfaces) == 964 and int(evidence.triangles) == 66636 \
		and int(evidence.static_bodies) == 466 and int(evidence.shapes) == 466 \
		and live_root_count == 1 and receiver != null \
		and receiver.get_child_count() == 3 \
		and _count_type(receiver.get_node("W34313525LiveModules"), MeshInstance3D) == 38,
		"Whole-island w34313525 live topology or isolation drifted: %s" % JSON.stringify(evidence))
	main.queue_free()
	await process_frame


func _record_for(receiver_key: String) -> Dictionary:
	var manifest := JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/manifest.json")) as Dictionary
	for chunk_value: Variant in manifest.get("chunks", []):
		var chunk_path := "res://generated/world/chunks/%s.json" % str((chunk_value as Dictionary).get("chunk_id", ""))
		var chunk := JSON.parse_string(FileAccess.get_file_as_string(chunk_path)) as Dictionary
		for value: Variant in chunk.get("records", []):
			var record := value as Dictionary
			if str(record.get("object_key", "")) == receiver_key:
				return record
	return {}


func _surface_triangles(mesh: ArrayMesh, surface_index: int) -> int:
	return int((mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _count_surfaces(node: Node) -> int:
	var count := (node as MeshInstance3D).mesh.get_surface_count() if node is MeshInstance3D and (node as MeshInstance3D).mesh != null else 0
	for child: Node in node.get_children():
		count += _count_surfaces(child)
	return count


func _count_triangles(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mesh := (node as MeshInstance3D).mesh
		for surface_index in mesh.get_surface_count():
			count += int((mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
	for child: Node in node.get_children():
		count += _count_triangles(child)
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
