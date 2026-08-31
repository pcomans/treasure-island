extends SceneTree

const ACCEPTED_MATERIAL_RUN_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const EXPECTED_MANIFEST_HASH := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_CHUNKS := 38
const EXPECTED_RECORDS := 729
const EXPECTED_GENERATED_MESHES := 729
const EXPECTED_GENERATED_SURFACES := 739
const EXPECTED_GENERATED_TRIANGLES := 48389
const EXPECTED_RUNTIME_MESHES := 1278
const EXPECTED_RUNTIME_SURFACES := 1288
const EXPECTED_RUNTIME_TRIANGLES := 55067
const EXPECTED_STATIC_BODIES := 466
const EXPECTED_VEGETATION_SEED := 1414092337
const EXPECTED_VEGETATION_INSTANCES := 124
const EXPECTED_VEGETATION_ASSETS := 15
const EXPECTED_VEGETATION_BATCHES := 19
const EXPECTED_VEGETATION_TRIANGLES := 20178
const EXPECTED_GEOMETRY_SOURCES := 738
const EXPECTED_FERRY_SPAWN_ORIGIN := Vector3(-104.364, 3.457, 786.024)
const EXPECTED_FERRY_SPAWN_YAW := -0.119
const EXPECTED_CATEGORY_COUNTS := {
	"ground": 233,
	"roads": 64,
	"buildings": 428,
	"ybi": 1,
	"bridge": 1,
	"boundary_attached": 2,
}
const PHYSICS_SPRAY_SURFACE := 1 << 2

var _failure := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var baseline_nodes := get_node_count()
	var main_scene := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(main_scene != null, "Main scene could not be loaded."):
		_finish(null, baseline_nodes)
		return
	var main := main_scene.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var ready_reports: Array[Dictionary] = []
	var load_failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready_reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void:
		load_failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()})
	)
	root.add_child(main)
	if not _require(not player.visible and not player.is_physics_processing(), "Player was enabled before full-world validation."):
		_finish(main, baseline_nodes)
		return

	var wait_started := Time.get_ticks_msec()
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - wait_started < 30000:
		await process_frame
	if not _require(load_failures.is_empty(), "Real full-world load failed: %s" % [load_failures]):
		_finish(main, baseline_nodes)
		return
	if not _require(ready_reports.size() == 1, "Expected exactly one world_ready signal, got %d." % ready_reports.size()):
		_finish(main, baseline_nodes)
		return

	var evidence := world.get_runtime_evidence()
	var full_load_msec := evidence.load_duration_msec
	var reported_topology := {
		"meshes": evidence.mesh_instances,
		"surfaces": evidence.surfaces,
		"triangles": evidence.triangles,
	}
	var vegetation_metrics := {
		"seed": evidence.vegetation_seed,
		"instances": evidence.vegetation_instances,
		"assets": evidence.vegetation_assets,
		"batches": evidence.vegetation_multimesh_batches,
		"triangles": evidence.vegetation_rendered_triangles,
	}
	var full_memory_mib := float(Performance.get_monitor(Performance.MEMORY_STATIC)) / (1024.0 * 1024.0)
	var report: Dictionary = ready_reports[0]
	var first_visible_clearance := _foot_clearance_m(player)
	if not _require(world.is_world_validated(), "WorldLoader did not retain validated state.") \
	or not _require(str(report.get("content_sha256", "")) == EXPECTED_MANIFEST_HASH, "Unexpected manifest hash at world_ready.") \
	or not _require(evidence.chunks_loaded == EXPECTED_CHUNKS and evidence.chunks_expected == EXPECTED_CHUNKS, "Runtime did not attach all 38 chunks.") \
	or not _require(evidence.playable_rows == 735 and evidence.context_rows == 4, "Runtime coverage is not 735 playable + 4 context.") \
	or not _require(evidence.vegetation_seed == EXPECTED_VEGETATION_SEED and evidence.vegetation_instances == EXPECTED_VEGETATION_INSTANCES, "Runtime vegetation seed/count drifted.") \
	or not _require(evidence.vegetation_assets == EXPECTED_VEGETATION_ASSETS and evidence.vegetation_multimesh_batches == EXPECTED_VEGETATION_BATCHES and evidence.vegetation_rendered_triangles == EXPECTED_VEGETATION_TRIANGLES, "Runtime vegetation batching/triangle metrics drifted.") \
	or not _require(player.visible and player.is_physics_processing(), "Main did not enable the player after world_ready.") \
	or not _require(player.was_first_reveal_grounded() and player.is_on_floor(), "Player's first visible frame was not grounded.") \
	or not _require(first_visible_clearance >= -0.005 and first_visible_clearance <= 0.03, "First-visible foot clearance %.3f m is not on the land surface." % first_visible_clearance):
		_finish(main, baseline_nodes)
		return

	var records := _record_nodes(main)
	var runtime_counts := _inspect_records(records)
	if not _require(records.size() == EXPECTED_RECORDS, "Expected 729 generated record nodes, got %d." % records.size()) \
	or not _require(int(runtime_counts.meshes) == EXPECTED_GENERATED_MESHES and int(runtime_counts.surfaces) == EXPECTED_GENERATED_SURFACES, "Expected exactly 729 generated terrain-aware meshes and 739 disjoint live material surfaces, including the two independently accepted w34313525 field partitions.") \
	or not _require(_accepted_material_run_trials_match_contract(records), "The three accepted Chapel, Dormitory, and YMCA exact-run homogeneous-material partitions drifted.") \
	or not _require(_batch_06_accepted_fields_match_contract(records, runtime_counts), "The generated Batch 06 field surface delta or exact accepted/pending render-only placements drifted.") \
	or not _require(_rejected_fire_station_placeholder_matches(records), "Rejected Fire Station 48 still has a live accepted-material surface or is not fully restored to the generated placeholder.") \
	or not _require(int(runtime_counts.triangles) == EXPECTED_GENERATED_TRIANGLES, "Expected 48,389 generated triangles after Hawkins-only stepped massing, coherent surface draping and western-bridge replacement, got %d." % int(runtime_counts.triangles)) \
	or not _require(int(runtime_counts.static_bodies) == EXPECTED_STATIC_BODIES and int(runtime_counts.shapes) == EXPECTED_STATIC_BODIES, "Expected 466 StaticBody3D/ConcavePolygonShape3D pairs.") \
	or not _require(int(runtime_counts.sources) == EXPECTED_GEOMETRY_SOURCES, "Expected 738 direct generated-geometry source identities.") \
	or not _require(evidence.mesh_instances == EXPECTED_RUNTIME_MESHES and evidence.surfaces == EXPECTED_RUNTIME_SURFACES and evidence.triangles == EXPECTED_RUNTIME_TRIANGLES, "RuntimeEvidence must include the independently accepted reversible Building 1 63-run ivory field and 45-module recognizability composition: 1,278 meshes / 1,288 surfaces / 55,067 triangles.") \
	or not _require(evidence.static_bodies == EXPECTED_STATIC_BODIES and evidence.shapes == EXPECTED_STATIC_BODIES, "RuntimeEvidence collider totals differ from the live tree.") \
	or not _require(_category_counts_match(world), "Generated category attachment counts are incomplete.") \
	or not _require(_vegetation_runtime_matches(world), "Visual-only vegetation MultiMesh runtime contract is invalid.") \
	or not _require(_context_has_no_collision(world), "Non-playable context unexpectedly owns collision.") \
	or not _require(_materials_match_culling_contract(records), "Playable/context material culling contract is invalid.") \
	or not _require(_overlay_shadow_contract(records), "Draped roads/areas must not cast duplicate coplanar shadows.") \
	or not _require(_polyhaven_materials_match_contract(records), "Poly Haven material paths, maps, physical scale, subtle normals, or runtime tangents drifted.") \
	or not _require(_semantic_materials_are_distinct(records), "Semantic area/pier/breakwater palette collapsed to indistinguishable colors.") \
	or not _require(_representative_winding_is_front_facing(records), "Runtime land/roof/wall indices do not match Godot clockwise winding.") \
	or not _require("Memory:" in evidence.debug_text() and "safe transform" in evidence.debug_text() and "Vegetation: seed" in evidence.debug_text(), "Runtime evidence omits memory, vegetation, or recovery-safe-transform status."):
		_finish(main, baseline_nodes)
		return

	var spawn := world.get_spawn_transform()
	var boundary := world.get_boundary()
	if not _require(boundary != null and boundary.is_configured(), "World boundary was not configured.") \
	or not _require(boundary.contains_position(spawn.origin), "Generated spawn is outside the playable boundary.") \
	or not _require(spawn.origin.is_equal_approx(EXPECTED_FERRY_SPAWN_ORIGIN), "Generated ferry spawn origin drifted.") \
	or not _require(spawn.basis.is_equal_approx(Basis(Vector3.UP, EXPECTED_FERRY_SPAWN_YAW)), "Generated ferry spawn orientation drifted.") \
	or not _require(_planar_direction(-player.get_camera().global_basis.z).dot(_planar_direction(-spawn.basis.z)) > 0.999999, "Initial camera is not horizontally oriented with the ferry spawn toward the island interior.") \
	or not _require(_horizontal_distance(player.global_position, spawn.origin) < 0.01 and absf(player.global_position.y - spawn.origin.y) < 0.1, "Player was not configured at the generated spawn."):
		_finish(main, baseline_nodes)
		return
	var recoveries_before_grounding := evidence.recovery_count
	if not await _wait_for_floor(player, 240):
		_fail("Player did not settle onto real generated land collision.")
		_finish(main, baseline_nodes)
		return
	if not _require(evidence.recovery_count == recoveries_before_grounding, "Initial grounding required a fall recovery instead of generated land collision."):
		_finish(main, baseline_nodes)
		return

	var movement := await _exercise_movement(player, spawn)
	if not _require(movement.ok, str(movement.get("message", "Walk/run exercise failed."))):
		_finish(main, baseline_nodes)
		return
	var jetpack := await _exercise_jetpack(player, evidence)
	if not _require(jetpack.ok, str(jetpack.get("message", "Jetpack exercise failed."))):
		_finish(main, baseline_nodes)
		return
	if not await _exercise_camera(player):
		_finish(main, baseline_nodes)
		return
	var recovery := await _exercise_recovery(player, boundary, spawn, evidence)
	if not _require(recovery.ok, str(recovery.get("message", "Recovery exercise failed."))):
		_finish(main, baseline_nodes)
		return
	var spray := await _exercise_spray(player, records, spawn, evidence)
	if not _require(spray.ok, str(spray.get("message", "Spray exercise failed."))):
		_finish(main, baseline_nodes)
		return
	var resumed_displacement := await _exercise_resume_after_interaction(player, spawn)
	if not _require(resumed_displacement > 0.35, "Movement did not resume after spray and recovery (%.3f m)." % resumed_displacement):
		_finish(main, baseline_nodes)
		return
	var final_active_decals := evidence.active_decals
	var final_tag_evictions := evidence.tags_evicted

	# Exercise the loader's fail-closed path only after all successful-world tests.
	var expected_failures := load_failures.size() + 1
	world.load_world("res://generated/world/does-not-exist.json")
	while load_failures.size() < expected_failures and Time.get_ticks_msec() - wait_started < 35000:
		await process_frame
	await process_frame
	if not _require(load_failures.size() == expected_failures, "Invalid reload did not emit world_failed.") \
	or not _require(not world.is_world_validated(), "Loader retained validated state after a failed reload.") \
	or not _require(not player.visible and not player.is_physics_processing(), "Player remained enabled after a failed reload.") \
	or not _require(_attached_generated_count(world) == 0, "Failed reload left partial generated nodes attached.") \
	or not _require(evidence.load_failure_code == "file_open", "Runtime evidence did not record the fail-closed load code."):
		_finish(main, baseline_nodes)
		return

	print("RUNTIME_LOAD: hash=%s chunks=%d records=%d generated_meshes=%d generated_surfaces=%d generated_triangles=%d reported_meshes=%d reported_surfaces=%d reported_triangles=%d bodies=%d shapes=%d sources=%d vegetation=%d/%d assets=%d batches=%d vegetation_triangles=%d load_ms=%d" % [
		EXPECTED_MANIFEST_HASH,
		EXPECTED_CHUNKS,
		EXPECTED_RECORDS,
		int(runtime_counts.meshes),
		int(runtime_counts.surfaces),
		int(runtime_counts.triangles),
		int(reported_topology.meshes),
		int(reported_topology.surfaces),
		int(reported_topology.triangles),
		int(runtime_counts.static_bodies),
		int(runtime_counts.shapes),
		int(runtime_counts.sources),
		int(vegetation_metrics.seed),
		int(vegetation_metrics.instances),
		int(vegetation_metrics.assets),
		int(vegetation_metrics.batches),
		int(vegetation_metrics.triangles),
		full_load_msec,
	])
	print("RUNTIME_GAMEPLAY: first_visible_grounded=%s first_clearance=%.3fm walk=%.3fm run=%.3fm movement_clearance=%.3f..%.3fm jetpack_rise=%.3fm air_walk=%.3fm air_run=%.3fm slow_descent=%.3fm renewed_rise=%.3fm landed=%s landing_clearance=%.3fm resumed=%.3fm manual_recovery=%s boundary_recovery=%s recovery_clearance=%.3fm spray=placed ground=receiver_rejection roof=receiver_rejection context=no_hit tags=%d evicted=%d" % [
		str(player.was_first_reveal_grounded()),
		first_visible_clearance,
		float(movement.walk),
		float(movement.run),
		float(movement.minimum_clearance),
		float(movement.maximum_clearance),
		float(jetpack.rise),
		float(jetpack.air_walk),
		float(jetpack.air_run),
		float(jetpack.descent),
		float(jetpack.renewed_rise),
		str(jetpack.landed),
		float(jetpack.landing_clearance),
		resumed_displacement,
		str(recovery.manual),
		str(recovery.boundary),
		float(recovery.clearance),
		final_active_decals,
		final_tag_evictions,
	])
	print("RUNTIME_HEALTH: static_memory_mib=%.1f failed_reload_code=%s partial_nodes=%d checkpoint_scene_nodes=%d" % [
		full_memory_mib,
		evidence.load_failure_code,
		_attached_generated_count(world),
		get_node_count(),
	])
	_finish(main, baseline_nodes)


func _inspect_records(records: Array) -> Dictionary:
	var meshes := 0
	var surfaces := 0
	var triangles := 0
	var bodies := 0
	var shapes := 0
	var sources: Dictionary = {}
	for record: Node3D in records:
		for source_value: Variant in record.get_meta("source_keys", []):
			sources[str(source_value)] = true
		# Generated-contract totals count the record-owned `Mesh` surface. Optional
		# render-only facade children are validated by their focused contracts and
		# must not redefine the frozen generated-world mesh/triangle inventory.
		var mesh_instance := record.get_node_or_null("Mesh") as MeshInstance3D
		if mesh_instance != null and mesh_instance.mesh != null:
			meshes += 1
			var mesh := mesh_instance.mesh
			surfaces += mesh.get_surface_count()
			triangles += mesh.get_faces().size() / 3
		var body := record.get_node_or_null("Collision") as StaticBody3D
		if body != null:
			bodies += 1
			var collision_shape := body.get_node_or_null("Shape") as CollisionShape3D
			if collision_shape != null and collision_shape.shape is ConcavePolygonShape3D \
			and not (collision_shape.shape as ConcavePolygonShape3D).get_faces().is_empty():
				shapes += 1
	return {
		"meshes": meshes,
		"surfaces": surfaces,
		"triangles": triangles,
		"static_bodies": bodies,
		"shapes": shapes,
		"sources": sources.size(),
	}


func _record_nodes(main: Node) -> Array:
	var records: Array = []
	for node: Node in main.find_children("*", "Node3D", true, false):
		if node.has_meta("feature_kind") and node.has_meta("derived_object_key"):
			records.append(node)
	return records


func _category_counts_match(world: WorldLoader) -> bool:
	return world.get_node("PlayableWorld/GroundAndAreas").get_child_count() == int(EXPECTED_CATEGORY_COUNTS.ground) \
		and world.get_node("PlayableWorld/RoadsAndPaths").get_child_count() == int(EXPECTED_CATEGORY_COUNTS.roads) \
		and world.get_node("PlayableWorld/Buildings").get_child_count() == int(EXPECTED_CATEGORY_COUNTS.buildings) \
		and world.get_node("ContextWorld/YerbaBuenaIsland").get_child_count() == int(EXPECTED_CATEGORY_COUNTS.ybi) \
		and world.get_node("ContextWorld/BayBridge").get_child_count() == int(EXPECTED_CATEGORY_COUNTS.bridge) \
		and world.get_node("ContextWorld/BoundaryAttachedVisuals").get_child_count() == int(EXPECTED_CATEGORY_COUNTS.boundary_attached)


func _vegetation_runtime_matches(world: WorldLoader) -> bool:
	var parent := world.get_node("PlayableWorld/Vegetation") as Node3D
	if parent.get_child_count() != 1:
		return false
	var root := parent.get_child(0) as Node3D
	if root == null or root.get_meta("visual_only", false) != true or int(root.get_meta("seed", 0)) != EXPECTED_VEGETATION_SEED:
		return false
	if not root.find_children("*", "CollisionObject3D", true, false).is_empty():
		return false
	var batches := root.find_children("*", "MultiMeshInstance3D", true, false)
	if batches.size() != EXPECTED_VEGETATION_BATCHES:
		return false
	var logical_asset_counts: Dictionary = {}
	var rendered_triangles := 0
	for batch_value: Node in batches:
		var batch := batch_value as MultiMeshInstance3D
		if batch.multimesh == null or batch.multimesh.mesh == null or batch.multimesh.instance_count <= 0 \
		or batch.get_meta("visual_only", false) != true:
			return false
		var asset_path := str(batch.get_meta("asset_path", ""))
		var placement_count := int(batch.get_meta("placement_count", -1))
		if logical_asset_counts.has(asset_path) and int(logical_asset_counts[asset_path]) != placement_count:
			return false
		logical_asset_counts[asset_path] = placement_count
		rendered_triangles += int(batch.multimesh.mesh.get_faces().size() / 3) * batch.multimesh.instance_count
	var logical_instances := 0
	for count_value: Variant in logical_asset_counts.values():
		logical_instances += int(count_value)
	return logical_asset_counts.size() == EXPECTED_VEGETATION_ASSETS \
		and logical_instances == EXPECTED_VEGETATION_INSTANCES \
		and rendered_triangles == EXPECTED_VEGETATION_TRIANGLES


func _context_has_no_collision(world: WorldLoader) -> bool:
	return world.get_node("ContextWorld").find_children("*", "StaticBody3D", true, false).is_empty()


func _materials_match_culling_contract(records: Array) -> bool:
	for record: Node3D in records:
		var is_context := str(record.get_meta("feature_kind", "")) in ["ybi", "bay_bridge", "boundary_attached_visual"]
		for mesh_instance_value: Node in record.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := mesh_instance_value as MeshInstance3D
			for surface_index in mesh_instance.mesh.get_surface_count():
				var material := mesh_instance.material_override if mesh_instance.material_override != null else mesh_instance.mesh.surface_get_material(surface_index)
				if material is StandardMaterial3D:
					var expected_cull := BaseMaterial3D.CULL_DISABLED if is_context else BaseMaterial3D.CULL_BACK
					if (material as StandardMaterial3D).cull_mode != expected_cull:
						return false
				elif material is ShaderMaterial:
					var shader_material := material as ShaderMaterial
					if not _shader_material_matches_contract(record, shader_material):
						return false
				else:
					return false
	return true


func _shader_material_matches_contract(record: Node3D, material: ShaderMaterial) -> bool:
	var receiver_key := str(record.get_meta("derived_object_key", ""))
	if receiver_key == "building:w1249412093:wall":
		return material.resource_name == "hawkins_pearl_fluted" \
			and material.shader != null \
			and material.shader.resource_path == "res://game/resources/materials/world/hawkins/hawkins_pearl_fluted.gdshader" \
			and material.shader.code.contains("render_mode depth_draw_opaque, cull_back;")
	if receiver_key == "building:r16681702:wall":
		return material.resource_path == "res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres" \
			and material.shader != null \
			and material.shader.resource_path == "res://game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader" \
			and material.shader.code.contains("render_mode depth_draw_opaque, cull_back;") \
			and material.shader.code.contains("field_position_m = UV;") \
			and is_equal_approx(float(material.get_shader_parameter("primary_scale_m")), 1.1) \
			and is_equal_approx(float(material.get_shader_parameter("secondary_scale_m")), 0.32)
	if ACCEPTED_MATERIAL_RUN_TRIALS.matches_batch_06_accepted_record({"object_key": receiver_key}):
		var accepted_metadata := ACCEPTED_MATERIAL_RUN_TRIALS.metadata_for(receiver_key) as Dictionary
		var accepted_group := {}
		for group_value: Variant in accepted_metadata.get("material_groups", []):
			var group := group_value as Dictionary
			if str(group.get("material_path", "")) == material.resource_path:
				accepted_group = group
				break
		if accepted_group.is_empty() or material.shader == null \
		or not material.shader.code.contains("render_mode depth_draw_opaque, cull_back;") \
		or not material.shader.code.contains("field_position_m = vec2(dot(VERTEX.xz, wall_tangent), VERTEX.y);"):
			return false
		if receiver_key == "building:w291196370:wall":
			return material.shader.resource_path == "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader" \
				and is_equal_approx(float(material.get_shader_parameter("course_height_m")), 0.20)
		return material.shader.resource_path == "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_aperiodic_field.gdshader" \
			and int(material.get_shader_parameter("field_kind")) == 0
	if not ACCEPTED_MATERIAL_RUN_TRIALS.matches_record({"object_key": receiver_key}):
		return false
	var metadata := ACCEPTED_MATERIAL_RUN_TRIALS.metadata_for(receiver_key) as Dictionary
	if material.resource_path != str(metadata.material_path) or material.shader == null \
	or not material.shader.code.contains("render_mode depth_draw_opaque, cull_back;"):
		return false
	if receiver_key == "building:w34313547:wall":
		return material.shader.resource_path == "res://game/resources/materials/world/ti_ymca/ti_ymca_wall_tangent_aperiodic_field.gdshader" \
			and material.shader.code.contains("field_position_m = vec2(dot(VERTEX.xz, wall_tangent), VERTEX.y);") \
			and int(material.get_shader_parameter("field_kind")) == 5 \
			and is_equal_approx(float(material.get_shader_parameter("relief_strength")), 0.08)
	return material.shader.resource_path == "res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader" \
		and int(material.get_shader_parameter("field_kind")) == 4 \
		and is_zero_approx(float(material.get_shader_parameter("relief_strength")))


func _accepted_material_run_trials_match_contract(records: Array) -> bool:
	var seen := {}
	for record: Node3D in records:
		var receiver_key := str(record.get_meta("derived_object_key", ""))
		if not ACCEPTED_MATERIAL_RUN_TRIALS.matches_record({"object_key": receiver_key}):
			continue
		if seen.has(receiver_key):
			return false
		var metadata := record.get_meta("accepted_material_run_trial", {}) as Dictionary
		var expected_metadata := ACCEPTED_MATERIAL_RUN_TRIALS.metadata_for(receiver_key) as Dictionary
		var mesh_instance := record.get_node_or_null("Mesh") as MeshInstance3D
		if metadata != expected_metadata \
		or int(metadata.get("modules", -1)) != 0 \
		or mesh_instance == null \
		or mesh_instance.mesh == null \
		or mesh_instance.mesh.get_surface_count() != 2 \
		or mesh_instance.mesh.surface_get_name(0) != ACCEPTED_MATERIAL_RUN_TRIALS.PLACEHOLDER_SURFACE_NAME \
		or mesh_instance.mesh.surface_get_name(1) != ACCEPTED_MATERIAL_RUN_TRIALS.ACCEPTED_SURFACE_NAME \
		or mesh_instance.mesh.surface_get_material(1).resource_path != str(metadata.material_path):
			return false
		seen[receiver_key] = true
	return seen.size() == ACCEPTED_MATERIAL_RUN_TRIALS.TARGETS.size()


func _batch_06_accepted_fields_match_contract(records: Array, runtime_counts: Dictionary) -> bool:
	var seen := {}
	var batch_06_surface_delta := 0
	for record: Node3D in records:
		var receiver_key := str(record.get_meta("derived_object_key", ""))
		if not ACCEPTED_MATERIAL_RUN_TRIALS.matches_batch_06_accepted_record({"object_key": receiver_key}):
			continue
		if seen.has(receiver_key):
			return false
		var metadata := record.get_meta("accepted_material_run_trial", {}) as Dictionary
		var expected_metadata := ACCEPTED_MATERIAL_RUN_TRIALS.metadata_for(receiver_key) as Dictionary
		var groups := metadata.get("material_groups", []) as Array
		var mesh_instance := record.get_node_or_null("Mesh") as MeshInstance3D
		var is_w34313564_live_receiver := receiver_key == "building:w34313564:wall"
		var is_w34313515_live_receiver := receiver_key == "building:w34313515:wall"
		var is_w291196370_live_receiver := receiver_key == "building:w291196370:wall"
		var is_w34313520_live_receiver := receiver_key == "building:w34313520:wall"
		var is_w34313525_live_receiver := receiver_key == "building:w34313525:wall"
		var is_live_module_receiver := is_w34313564_live_receiver or is_w34313515_live_receiver or is_w291196370_live_receiver or is_w34313520_live_receiver or is_w34313525_live_receiver
		var expected_module_instances := 5 if is_w34313564_live_receiver else (4 if is_w34313515_live_receiver or is_w34313525_live_receiver else (3 if is_w291196370_live_receiver else (1 if is_w34313520_live_receiver else 0)))
		var expected_module_meshes := 34 if is_w34313564_live_receiver else (84 if is_w34313515_live_receiver else (24 if is_w291196370_live_receiver else (15 if is_w34313520_live_receiver else (38 if is_w34313525_live_receiver else 0))))
		var live_root_name := "W34313564LiveModules" if is_w34313564_live_receiver else ("W34313515LiveModules" if is_w34313515_live_receiver else ("W291196370LiveModules" if is_w291196370_live_receiver else ("W34313520LiveModules" if is_w34313520_live_receiver else "W34313525LiveModules")))
		var live_root := record.get_node_or_null(live_root_name) as Node3D if is_live_module_receiver else null
		# The helper's w34313520/w34313525 status is immutable integration-time
		# provenance; canonical current acceptance is asserted by focused lifecycle contracts.
		var integration_time_status := "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending" if is_w34313520_live_receiver or is_w34313525_live_receiver else ACCEPTED_MATERIAL_RUN_TRIALS.BATCH_06_ACCEPTED_STATUS
		if metadata != expected_metadata \
		or str(metadata.get("status", "")) != integration_time_status \
		or int(metadata.get("modules", -1)) != expected_module_instances \
		or int(metadata.get("standalone_modules_live", -1)) != expected_module_instances \
		or groups.is_empty() \
		or mesh_instance == null or mesh_instance.mesh == null \
		or mesh_instance.mesh.get_surface_count() != groups.size() + 1 \
		or mesh_instance.mesh.surface_get_name(0) != ACCEPTED_MATERIAL_RUN_TRIALS.PLACEHOLDER_SURFACE_NAME \
		or (live_root != null) != is_live_module_receiver \
		or (is_live_module_receiver and (live_root.get_child_count() != expected_module_instances \
			or live_root.find_children("*", "MeshInstance3D", true, false).size() != expected_module_meshes \
			or not live_root.find_children("*", "CollisionObject3D", true, false).is_empty() \
			or not live_root.find_children("*", "NavigationRegion3D", true, false).is_empty())):
			return false
		for group_index in groups.size():
			var group := groups[group_index] as Dictionary
			var surface_index := group_index + 1
			if mesh_instance.mesh.surface_get_name(surface_index) != str(group.surface_name) \
			or mesh_instance.mesh.surface_get_material(surface_index).resource_path != str(group.material_path):
				return false
		batch_06_surface_delta += groups.size()
		seen[receiver_key] = true
	return seen.size() == ACCEPTED_MATERIAL_RUN_TRIALS.BATCH_06_ACCEPTED_TARGETS.size() \
		and int(runtime_counts.surfaces) - int(runtime_counts.meshes) == ACCEPTED_MATERIAL_RUN_TRIALS.TARGETS.size() + batch_06_surface_delta


func _rejected_fire_station_placeholder_matches(records: Array) -> bool:
	var matches: Array[Node3D] = []
	for record: Node3D in records:
		if str(record.get_meta("derived_object_key", "")) == "building:w764313741:wall":
			matches.append(record)
	if matches.size() != 1:
		return false
	var record := matches[0]
	var mesh_instance := record.get_node_or_null("Mesh") as MeshInstance3D
	var body := record.get_node_or_null("Collision") as StaticBody3D
	var shape_node := record.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if mesh_instance == null or not (mesh_instance.mesh is ArrayMesh) or body == null or shape == null:
		return false
	var mesh := mesh_instance.mesh as ArrayMesh
	var material := mesh.surface_get_material(0) as StandardMaterial3D if mesh.get_surface_count() == 1 else null
	return not ACCEPTED_MATERIAL_RUN_TRIALS.matches_record({"object_key": "building:w764313741:wall"}) \
		and ACCEPTED_MATERIAL_RUN_TRIALS.metadata_for("building:w764313741:wall").is_empty() \
		and not record.has_meta("accepted_material_run_trial") \
		and record.get_meta("source_keys", []) == ["w764313741"] \
		and record.get_child_count() == 2 \
		and mesh.get_surface_count() == 1 \
		and mesh.surface_get_name(0) == "generated_record" \
		and material != null and material.resource_name == "building_wall" \
		and mesh.get_faces().size() == 156 \
		and shape.get_faces().size() == 156 \
		and body.collision_layer == (1 | PHYSICS_SPRAY_SURFACE) \
		and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") \
		and (record.find_children("*", "MeshInstance3D", true, false) as Array).size() == 1 \
		and (record.find_children("*Facade*", "Node", true, false) as Array).is_empty()


func _overlay_shadow_contract(records: Array) -> bool:
	for record: Node3D in records:
		var feature_kind := str(record.get_meta("feature_kind", ""))
		var mesh_instance := record.get_node_or_null("Mesh") as MeshInstance3D
		if mesh_instance == null:
			continue
		var expected := GeometryInstance3D.SHADOW_CASTING_SETTING_OFF \
			if feature_kind in ["road_path", "major_area", "terrain_overlay"] \
			else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if mesh_instance.cast_shadow != expected:
			return false
	return true


func _semantic_materials_are_distinct(records: Array) -> bool:
	var colors := {}
	for record: Node3D in records:
		var mesh_instance := record.get_node("Mesh") as MeshInstance3D
		for surface_index in mesh_instance.mesh.get_surface_count():
			var material := mesh_instance.mesh.surface_get_material(surface_index) as StandardMaterial3D
			if material != null:
				colors[material.resource_name] = material.albedo_color
	var required := [
		"land_ground",
		"major_area_amenity",
		"major_area_landuse",
		"major_area_leisure",
		"major_area_paved",
		"road_path",
		"road_path_pedestrian",
		"terrain_pier",
		"terrain_breakwater",
	]
	for key: String in required:
		if not colors.has(key):
			return false
	for left_index in required.size():
		for right_index in range(left_index + 1, required.size()):
			if (colors[required[left_index]] as Color).is_equal_approx(colors[required[right_index]] as Color):
				return false
	var vehicle := colors.road_path as Color
	var pedestrian := colors.road_path_pedestrian as Color
	var paved := colors.major_area_paved as Color
	return vehicle.is_equal_approx(Color("b0b4b8")) \
		and pedestrian.is_equal_approx(Color("d8d6cf")) \
		and paved.is_equal_approx(Color("adb0ae"))


func _polyhaven_materials_match_contract(records: Array) -> bool:
	var expected := {
		"road_path": ["clean_asphalt", 2.1, 2.1, 0.2],
		"road_path_pedestrian": ["concrete_pavement", 1.8, 1.8, 0.2],
		"major_area_paved": ["concrete_floor_03", 2.5, 2.5, 0.2],
		"land_ground": ["sparse_grass", 2.0, 5.0, 0.2],
		"major_area_landuse": ["sparse_grass", 2.0, 5.0, 0.2],
		"major_area_leisure": ["sparse_grass", 2.0, 5.0, 0.2],
		"context_ybi": ["sparse_grass", 2.0, 5.0, 0.2],
		"building_wall": ["plaster_grey_04", 1.5, 0.75, 0.1],
		"building_part_wall": ["plaster_grey_04", 1.5, 0.75, 0.1],
		"building_roof": ["bitumen", 20.0, 10.0, 0.2],
		"building_part_roof": ["bitumen", 20.0, 10.0, 0.2],
	}
	var found := {}
	for record: Node3D in records:
		var mesh_instance := record.get_node_or_null("Mesh") as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		for surface_index in mesh_instance.mesh.get_surface_count():
			var material := mesh_instance.mesh.surface_get_material(surface_index) as StandardMaterial3D
			if material == null or not expected.has(material.resource_name):
				continue
			var asset := str(expected[material.resource_name][0])
			var source_dimension := float(expected[material.resource_name][1])
			var repeat_dimension := float(expected[material.resource_name][2])
			var normal_strength := float(expected[material.resource_name][3])
			var scale := 10.0 / repeat_dimension
			var source_set: Dictionary = WorldChunkBuilder.POLYHAVEN_TEXTURE_SETS[asset]
			var prefix := "res://game/resources/textures/world/polyhaven/%s/%s" % [asset, asset]
			if not is_equal_approx(float(source_set.source_dimension_m), source_dimension) \
			or not is_equal_approx(float(source_set.repeat_dimension_m), repeat_dimension) \
			or material.albedo_texture == null or material.albedo_texture.resource_path != "%s_diff_1k.jpg" % prefix \
			or material.normal_texture == null or material.normal_texture.resource_path != "%s_nor_gl_1k.jpg" % prefix \
			or material.roughness_texture == null or material.roughness_texture.resource_path != "%s_rough_1k.jpg" % prefix \
			or not material.normal_enabled or not is_equal_approx(material.normal_scale, normal_strength) \
			or not is_equal_approx(material.uv1_scale.x, scale) or not is_equal_approx(material.uv1_scale.y, scale) \
			or not material.get_flag(BaseMaterial3D.FLAG_USE_TEXTURE_REPEAT) \
			or material.texture_filter != BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC \
			or material.heightmap_enabled:
				return false
			var arrays := (mesh_instance.mesh as ArrayMesh).surface_get_arrays(surface_index)
			var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
			var tangents := arrays[Mesh.ARRAY_TANGENT] as PackedFloat32Array
			if tangents.size() != vertices.size() * 4:
				return false
			for tangent_offset in range(0, tangents.size(), 4):
				var tangent := Vector3(tangents[tangent_offset], tangents[tangent_offset + 1], tangents[tangent_offset + 2])
				if not tangent.is_finite() or tangent.length_squared() < 0.99 or tangent.length_squared() > 1.01 \
				or not is_equal_approx(absf(tangents[tangent_offset + 3]), 1.0):
					return false
			found[material.resource_name] = true
	return found.size() == expected.size()


func _representative_winding_is_front_facing(records: Array) -> bool:
	for feature_kind: String in ["land_ground", "building_roof", "building_wall"]:
		var record := _first_record(records, feature_kind)
		if record == null or not _record_has_godot_front_winding(record):
			return false
	return true


func _record_has_godot_front_winding(record: Node3D) -> bool:
	var mesh_instance := record.get_node("Mesh") as MeshInstance3D
	var arrays := (mesh_instance.mesh as ArrayMesh).surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	for offset in range(0, indices.size(), 3):
		var a := vertices[indices[offset]]
		var b := vertices[indices[offset + 1]]
		var c := vertices[indices[offset + 2]]
		var stored_normal := (normals[indices[offset]] + normals[indices[offset + 1]] + normals[indices[offset + 2]]).normalized()
		if (b - a).cross(c - a).dot(stored_normal) >= 0.0:
			return false
	return true


func _attached_generated_count(world: WorldLoader) -> int:
	return world.get_node("PlayableWorld/GroundAndAreas").get_child_count() \
		+ world.get_node("PlayableWorld/RoadsAndPaths").get_child_count() \
		+ world.get_node("PlayableWorld/Buildings").get_child_count() \
		+ world.get_node("PlayableWorld/Vegetation").get_child_count() \
		+ world.get_node("ContextWorld/YerbaBuenaIsland").get_child_count() \
		+ world.get_node("ContextWorld/BayBridge").get_child_count() \
		+ world.get_node("ContextWorld/BoundaryAttachedVisuals").get_child_count()


func _wait_for_floor(player: PlayerController, maximum_frames: int) -> bool:
	for _frame in maximum_frames:
		await physics_frame
		if player.is_on_floor():
			return true
	return false


func _foot_clearance_m(player: PlayerController) -> float:
	var origin := player.global_position + Vector3.UP * 0.5
	var target := player.global_position + Vector3.DOWN * 0.5
	var query := PhysicsRayQueryParameters3D.create(origin, target, 1, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	return INF if hit.is_empty() else player.global_position.y - (hit.position as Vector3).y


func _planar_direction(direction: Vector3) -> Vector3:
	direction.y = 0.0
	return direction.normalized()


func _exercise_movement(player: PlayerController, spawn: Transform3D) -> Dictionary:
	player.get_recovery_controller().recover("manual")
	if not await _wait_for_floor(player, 240):
		return {"ok": false, "message": "Player did not settle before walk test."}
	var walk_start := player.global_position
	var maximum_clearance := _foot_clearance_m(player)
	var minimum_clearance := maximum_clearance
	Input.action_press("move_forward")
	for _frame in 30:
		await physics_frame
		if not player.is_on_floor():
			Input.action_release("move_forward")
			return {"ok": false, "message": "Player left the surface during the walk test."}
		maximum_clearance = maxf(maximum_clearance, _foot_clearance_m(player))
		minimum_clearance = minf(minimum_clearance, _foot_clearance_m(player))
	Input.action_release("move_forward")
	var walk_distance := _horizontal_distance(walk_start, player.global_position)

	player.get_recovery_controller().recover("manual")
	if not await _wait_for_floor(player, 240):
		return {"ok": false, "message": "Player did not settle before run test."}
	var run_start := player.global_position
	Input.action_press("move_forward")
	Input.action_press("run")
	for _frame in 30:
		await physics_frame
		if not player.is_on_floor():
			Input.action_release("run")
			Input.action_release("move_forward")
			return {"ok": false, "message": "Player left the surface during the run test."}
		maximum_clearance = maxf(maximum_clearance, _foot_clearance_m(player))
		minimum_clearance = minf(minimum_clearance, _foot_clearance_m(player))
	Input.action_release("run")
	Input.action_release("move_forward")
	var run_distance := _horizontal_distance(run_start, player.global_position)
	if walk_distance <= 0.5 or run_distance <= walk_distance * 1.25 \
	or minimum_clearance < -0.005 or maximum_clearance > 0.03:
		return {"ok": false, "message": "Walk/run displacement contract failed: walk %.3f m, run %.3f m." % [walk_distance, run_distance]}
	return {"ok": true, "walk": walk_distance, "run": run_distance, "minimum_clearance": minimum_clearance, "maximum_clearance": maximum_clearance, "spawn": spawn.origin}


func _exercise_jetpack(player: PlayerController, evidence: RuntimeEvidence) -> Dictionary:
	player.get_recovery_controller().recover("manual")
	if not await _wait_for_floor(player, 240):
		return {"ok": false, "message": "Player did not settle before jetpack test."}
	var recovery_count := evidence.recovery_count
	var start := player.global_position
	Input.action_press("jetpack")
	Input.action_press("move_forward")
	for _frame in 30:
		await physics_frame
	var air_walk_end := player.global_position
	Input.action_press("run")
	for _frame in 30:
		await physics_frame
	Input.action_release("run")
	Input.action_release("jetpack")
	Input.action_release("move_forward")
	var rise := player.global_position.y - start.y
	var air_walk := _horizontal_distance(start, air_walk_end)
	var air_run := _horizontal_distance(air_walk_end, player.global_position)
	if rise <= 2.5 or air_walk <= 1.0 or air_run <= air_walk * 1.25 or player.velocity.y <= 0.0 \
	or player.velocity.y > player.jetpack_ascent_speed_mps + 0.01:
		return {
			"ok": false,
			"message": "Jetpack ascent/air-control contract failed: rise %.3f m, air walk %.3f m, air run %.3f m, velocity %.3f m/s." % [rise, air_walk, air_run, player.velocity.y],
		}

	var reached_slow_descent := false
	for _frame in 90:
		await physics_frame
		if player.velocity.y <= -player.jetpack_descent_speed_mps + 0.05:
			reached_slow_descent = true
			break
	if not reached_slow_descent:
		return {"ok": false, "message": "Released jetpack did not transition to slow descent."}
	var descent_start_y := player.global_position.y
	var minimum_velocity_y := player.velocity.y
	for _frame in 20:
		await physics_frame
		minimum_velocity_y = minf(minimum_velocity_y, player.velocity.y)
	var descent := descent_start_y - player.global_position.y
	if descent <= 0.2 or descent >= 0.8 \
	or minimum_velocity_y < -player.jetpack_descent_speed_mps - 0.01:
		return {
			"ok": false,
			"message": "Jetpack slow-descent cap failed: drop %.3f m, minimum velocity %.3f m/s." % [descent, minimum_velocity_y],
		}

	var renewed_start_y := player.global_position.y
	Input.action_press("jetpack")
	for _frame in 35:
		await physics_frame
	Input.action_release("jetpack")
	var renewed_rise := player.global_position.y - renewed_start_y
	if renewed_rise <= 0.3 or player.velocity.y <= 0.0:
		return {
			"ok": false,
			"message": "Jetpack did not renew ascent in mid-air: rise %.3f m, velocity %.3f m/s." % [renewed_rise, player.velocity.y],
		}
	if not await _wait_for_floor(player, 600):
		return {"ok": false, "message": "Player did not land after releasing the jetpack."}
	if evidence.recovery_count != recovery_count:
		return {
			"ok": false,
			"message": "Jetpack landing triggered recovery: delta %d." % [evidence.recovery_count - recovery_count],
		}
	var landing_clearance := _foot_clearance_m(player)
	if landing_clearance < -0.005 or landing_clearance > 0.03:
		return {"ok": false, "message": "Jetpack landing foot clearance %.3f m is off the land surface." % landing_clearance}
	return {"ok": true, "rise": rise, "air_walk": air_walk, "air_run": air_run, "descent": descent, "renewed_rise": renewed_rise, "landed": true, "landing_clearance": landing_clearance}


func _exercise_camera(player: PlayerController) -> bool:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3.ZERO
	rig.apply_look_delta(Vector2(100.0, 100000.0))
	if not _require(is_equal_approx(rig.rotation.y, -0.3), "Camera yaw did not follow sensitivity contract: yaw=%.6f." % rig.rotation.y) \
	or not _require(is_equal_approx(arm.rotation.x, deg_to_rad(rig.minimum_pitch_degrees)), "Camera minimum pitch clamp failed."):
		return false
	rig.apply_look_delta(Vector2(0.0, -100000.0))
	if not _require(is_equal_approx(arm.rotation.x, deg_to_rad(rig.maximum_pitch_degrees)), "Camera maximum pitch clamp failed."):
		return false

	# Exercise the actual SpringArm3D collision query with a test-owned solid.
	# Recover to a generated-safe transform first so existing world geometry cannot
	# masquerade as the obstacle installed by this test.
	player.get_recovery_controller().recover("camera_collision_test")
	if not await _wait_for_floor(player, 240):
		return _require(false, "Player did not settle before the spring-arm collision test.")
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3.ZERO
	player.force_update_transform()
	rig.force_update_transform()
	arm.force_update_transform()
	for _frame in 3:
		await physics_frame
	var baseline_hit_length := arm.get_hit_length()
	if not _require(baseline_hit_length >= arm.spring_length - 0.05, "Spring arm was unexpectedly compressed before the test obstacle: hit %.3f m, configured %.3f m." % [baseline_hit_length, arm.spring_length]):
		return false

	var test_solid := StaticBody3D.new()
	test_solid.name = "TestSpringArmSolid"
	test_solid.collision_layer = 1
	test_solid.collision_mask = 0
	var test_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3.0, 4.0, 0.4)
	test_shape.shape = box
	test_solid.add_child(test_shape)
	player.get_parent().add_child(test_solid)
	var arm_basis := arm.global_basis.orthonormalized()
	test_solid.global_transform = Transform3D(arm_basis, arm.global_position + arm_basis.z * 2.0)
	for _frame in 3:
		await physics_frame
	var compressed_hit_length := arm.get_hit_length()
	var compressed := compressed_hit_length > 0.1 and compressed_hit_length < arm.spring_length - 0.5

	test_solid.queue_free()
	await process_frame
	for _frame in 3:
		await physics_frame
	var restored_hit_length := arm.get_hit_length()
	var restored := restored_hit_length >= arm.spring_length - 0.05
	print("RUNTIME_CAMERA: baseline=%.3fm compressed=%.3fm restored=%.3fm configured=%.3fm" % [
		baseline_hit_length, compressed_hit_length, restored_hit_length, arm.spring_length,
	])
	return _require(compressed, "Spring arm did not shorten for the test-owned solid: hit %.3f m, configured %.3f m." % [compressed_hit_length, arm.spring_length]) \
		and _require(restored, "Spring arm did not re-extend after removing the test-owned solid: hit %.3f m, configured %.3f m." % [restored_hit_length, arm.spring_length])


func _exercise_recovery(player: PlayerController, boundary: WorldBoundary, spawn: Transform3D, evidence: RuntimeEvidence) -> Dictionary:
	var prior_recoveries := evidence.recovery_count
	player.global_position = Vector3(5000.0, spawn.origin.y, 5000.0)
	player.velocity = Vector3.ZERO
	player.force_update_transform()
	for _frame in 120:
		await physics_frame
		if evidence.recovery_count > prior_recoveries and evidence.last_recovery_cause == "outside_boundary":
			break
	if evidence.recovery_count <= prior_recoveries or evidence.last_recovery_cause != "outside_boundary" \
	or not boundary.contains_position(player.global_position):
		return {"ok": false, "message": "Out-of-bound physics recovery did not return to the playable world."}
	var boundary_cause := evidence.last_recovery_cause
	prior_recoveries = evidence.recovery_count
	player.global_position += Vector3(4.0, 0.0, 0.0)
	player.get_recovery_controller().recover("manual")
	if not await _wait_for_floor(player, 30):
		return {"ok": false, "message": "Manual recovery did not remain grounded."}
	if evidence.recovery_count != prior_recoveries + 1 or evidence.last_recovery_cause != "manual" \
	or not boundary.contains_position(player.global_position):
		return {"ok": false, "message": "Manual recovery contract failed."}
	var clearance := _foot_clearance_m(player)
	if clearance < -0.005 or clearance > 0.03:
		return {"ok": false, "message": "Recovered foot clearance %.3f m is off the land surface." % clearance}
	return {"ok": true, "manual": evidence.last_recovery_cause, "boundary": boundary_cause, "clearance": clearance}


func _exercise_spray(player: PlayerController, records: Array, spawn: Transform3D, evidence: RuntimeEvidence) -> Dictionary:
	player.set_gameplay_enabled(false)
	Input.action_release("move_forward")
	Input.action_release("run")
	var wall := _first_record(records, "building_wall")
	var ground := _first_record(records, "land_ground")
	var roof := _first_record(records, "building_roof")
	var context := _first_record(records, "ybi")
	if wall == null or ground == null or roof == null or context == null:
		return {"ok": false, "message": "Could not locate generated wall/ground/roof/context records."}

	var wall_face := _face_for_record(wall, true, spawn.origin)
	if wall_face.is_empty():
		return {"ok": false, "message": "Could not locate a usable generated wall triangle."}
	await _aim_at(player, wall_face.center, wall_face.normal * 2.0)
	var wall_hit := _camera_spray_hit(player)
	if wall_hit.is_empty() or not (wall_hit.collider as CollisionObject3D).is_in_group("spray_receiver_wall"):
		return {"ok": false, "message": "Actual spray ray did not resolve a generated eligible wall first."}
	var placed_before := int(evidence.spray_counts.placed)
	player.get_spray_controller().attempt_spray()
	if int(evidence.spray_counts.placed) != placed_before + 1:
		return {"ok": false, "message": "Eligible generated wall did not place a tag."}
	var pool := player.get_spray_controller().tag_instances
	var first_tag := pool.get_child(pool.get_child_count() - 1) as Decal
	var hit_normal: Vector3 = wall_hit.normal.normalized()
	if first_tag == null or first_tag.global_basis.y.dot(hit_normal) < 0.99 or first_tag.global_basis.z.dot(Vector3.UP) < 0.99:
		return {"ok": false, "message": "Placed Decal projection/upright basis is reversed."}

	var ground_face := _face_for_record(ground, false, spawn.origin)
	await _aim_at(player, ground_face.center, Vector3(0.0, 2.0, 2.0))
	var ground_hit := _camera_spray_hit(player)
	if ground_hit.is_empty() or str((ground_hit.collider as Node).get_parent().get_meta("feature_kind", "")) != "land_ground":
		return {"ok": false, "message": "Actual ray did not reach generated land collision for rejection test."}
	var rejected_before := int(evidence.spray_counts.receiver_rejection)
	player.get_spray_controller().attempt_spray()
	if int(evidence.spray_counts.receiver_rejection) != rejected_before + 1:
		return {"ok": false, "message": "Generated ground was not rejected as an ineligible receiver."}

	var roof_face := _face_for_record(roof, false, spawn.origin)
	await _aim_at(player, roof_face.center, Vector3(0.0, 2.0, 2.0))
	var roof_hit := _camera_spray_hit(player)
	if roof_hit.is_empty() or str((roof_hit.collider as Node).get_parent().get_meta("feature_kind", "")) != "building_roof":
		return {"ok": false, "message": "Actual ray did not reach generated roof collision for rejection test."}
	rejected_before = int(evidence.spray_counts.receiver_rejection)
	player.get_spray_controller().attempt_spray()
	if int(evidence.spray_counts.receiver_rejection) != rejected_before + 1:
		return {"ok": false, "message": "Generated roof was not rejected as an ineligible receiver."}

	var context_face := _mesh_face_for_record(context)
	await _aim_at(player, context_face.center, Vector3(0.0, 2.0, 2.0))
	if not _camera_spray_hit(player).is_empty():
		return {"ok": false, "message": "Context aim ray unexpectedly hit spray collision."}
	var no_hit_before := int(evidence.spray_counts.no_hit)
	player.get_spray_controller().attempt_spray()
	if int(evidence.spray_counts.no_hit) != no_hit_before + 1:
		return {"ok": false, "message": "Non-colliding generated context was not rejected."}

	await _aim_at(player, wall_face.center, wall_face.normal * 2.0)
	for _placement in pool.session_limit - pool.active_count() + 1:
		player.get_spray_controller().attempt_spray()
	await process_frame
	if pool.active_count() != pool.session_limit or evidence.tags_evicted != 1:
		return {"ok": false, "message": "Session tag pool did not cap at 64 with one deterministic eviction."}
	return {"ok": true}


func _exercise_resume_after_interaction(player: PlayerController, spawn: Transform3D) -> float:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3.ZERO
	player.set_gameplay_enabled(true)
	player.get_recovery_controller().recover("manual")
	if not await _wait_for_floor(player, 240):
		return 0.0
	var start := player.global_position
	Input.action_press("move_forward")
	for _frame in 20:
		await physics_frame
	Input.action_release("move_forward")
	return _horizontal_distance(start, player.global_position)


func _first_record(records: Array, feature_kind: String) -> Node3D:
	for record: Node3D in records:
		if str(record.get_meta("feature_kind", "")) == feature_kind:
			return record
	return null


func _face_for_record(record: Node3D, require_vertical: bool, near_position: Vector3) -> Dictionary:
	var collision_shape := record.get_node("Collision/Shape") as CollisionShape3D
	var faces := (collision_shape.shape as ConcavePolygonShape3D).get_faces()
	var best: Dictionary = {}
	var best_distance := INF
	for index in range(0, faces.size(), 3):
		var a: Vector3 = collision_shape.global_transform * faces[index]
		var b: Vector3 = collision_shape.global_transform * faces[index + 1]
		var c: Vector3 = collision_shape.global_transform * faces[index + 2]
		var cross := (b - a).cross(c - a)
		if cross.length_squared() < 0.04:
			continue
		var normal := -cross.normalized()
		if require_vertical and absf(normal.y) > 0.1:
			continue
		var center := (a + b + c) / 3.0
		var distance := Vector2(center.x - near_position.x, center.z - near_position.z).length_squared()
		if require_vertical:
			return {"center": center, "normal": normal}
		if distance < best_distance:
			best = {"center": center, "normal": normal}
			best_distance = distance
	return best


func _mesh_face_for_record(record: Node3D) -> Dictionary:
	var mesh_instance := record.get_node("Mesh") as MeshInstance3D
	var arrays := (mesh_instance.mesh as ArrayMesh).surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	for offset in range(0, indices.size(), 3):
		var a: Vector3 = mesh_instance.global_transform * vertices[indices[offset]]
		var b: Vector3 = mesh_instance.global_transform * vertices[indices[offset + 1]]
		var c: Vector3 = mesh_instance.global_transform * vertices[indices[offset + 2]]
		var cross := (b - a).cross(c - a)
		if cross.length_squared() >= 0.04:
			return {"center": (a + b + c) / 3.0, "normal": -cross.normalized()}
	return {}


func _aim_at(player: PlayerController, target: Vector3, player_offset: Vector3) -> void:
	player.global_transform = Transform3D(Basis.IDENTITY, target + player_offset)
	player.velocity = Vector3.ZERO
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3.ZERO
	rig.look_at(target, Vector3.UP)
	player.force_update_transform()
	rig.force_update_transform()
	await process_frame


func _camera_spray_hit(player: PlayerController) -> Dictionary:
	var camera := player.get_camera()
	var viewport_center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(viewport_center)
	var direction := camera.project_ray_normal(viewport_center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0, PHYSICS_SPRAY_SURFACE, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _horizontal_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_fail(message)
		return false
	return true


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error(message)


func _finish(main: Node, baseline_nodes: int) -> void:
	for action: StringName in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		Input.action_release(action)
	if main != null and is_instance_valid(main):
		main.queue_free()
		await process_frame
		await process_frame
	if _failure.is_empty() and get_node_count() != baseline_nodes:
		_fail("Runtime test leaked scene-tree nodes: baseline %d, final %d." % [baseline_nodes, get_node_count()])
	if _failure.is_empty():
		print("RUNTIME_CLEANUP: baseline_scene_nodes=%d final_scene_nodes=%d" % [baseline_nodes, get_node_count()])
		print("PASS: real main scene reached world_ready, enabled player, exercised generated physics/interactions, and failed closed without a partial world")
	quit(0 if _failure.is_empty() else 1)
