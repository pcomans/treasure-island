extends SceneTree

const PROTOTYPE := preload("res://game/scripts/world/facades/dormitory_369_standalone_hero_prototype.gd")
const CONFIG_PATH := "res://game/resources/facades/dormitory_369_standalone_hero_prototype.json"
const SCENE_PATH := "res://game/scenes/world/facades/job_corps_dormitory_b369/dormitory_369_standalone_hero_prototype.tscn"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_1.json"
const PACKET_PATH := "res://discovery/facades/p3_reference_packets/w291189926_job_corps_dormitory_369.md"
const RUN_MAP_PATH := "res://discovery/facades/BATCH_04_RUN_MAPPING.json"
const WALL_KEY := "building:w291189926:wall"
const ROOF_KEY := "building:w291189926:roof"
const SOURCE_KEY := "w291189926"
const MAPPED_RUNS := [0, 1, 2, 3, 4, 5]
const PROTECTED_RUNS := [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71]
const HERO_ROOF_Y := 18.39
const EXPECTED_SIGNATURE := "a84ce1e27ef0466d58e35ce57352a8eb43cb8f2d20c7530f0c9d24c0b4b1a121"
const EXPECTED_BATCH_TRIANGLES := {
	"ProtectedLiftedWallRuns_6_71": 132,
	"AcceptedWarmLiftedWallRuns_0_5": 12,
	"NeutralLiftedRoof": 32,
	"BlueGrayStructuralStairEnd": 12,
	"BlueGrayGroundPanels": 48,
	"GreenStructuralEave": 12,
	"GreenEyebrows": 240,
	"OpaqueExteriorOpeningsAndVents": 480,
	"OpeningFramesAndMultiLiteDividers": 2400,
}
const EXPECTED_MATERIALS := {
	"ProtectedLiftedWallRuns_6_71": "res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_protected_neutral.tres",
	"AcceptedWarmLiftedWallRuns_0_5": "res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres",
	"NeutralLiftedRoof": "res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_neutral_roof.tres",
	"BlueGrayStructuralStairEnd": "res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_inferred_blue_gray.tres",
	"BlueGrayGroundPanels": "res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_inferred_blue_gray.tres",
	"GreenStructuralEave": "res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_inferred_green_trim.tres",
	"GreenEyebrows": "res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_inferred_green_trim.tres",
	"OpaqueExteriorOpeningsAndVents": "res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_opaque_opening.tres",
	"OpeningFramesAndMultiLiteDividers": "res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_opening_frame.tres",
}
const PINNED_INPUTS := {
	CONFIG_PATH: "b02b098bfeca628cd6a71e7393897d53f5f46dfd0efddd915e316c2dd5204c2e",
	"res://game/scripts/world/facades/dormitory_369_standalone_hero_prototype.gd": "0416effb03f6d833baaa24bf988fa26ae716b83c98780b2ede224d6759db37a5",
	SCENE_PATH: "e9d1fd159c1a54b48bdfd5d6274c6435f32b6fa2d4b54a9d42503a16930f2720",
	CHUNK_PATH: "a35f63a877588d198e0e905167968bf9948f4616c16e708a6799d0e6c1bde00a",
	PACKET_PATH: "a43d391239c2fd3ce66b13c39dc56c534253211e7a44a12d512dbe5367b3a9f9",
	RUN_MAP_PATH: "3ec81316f9bdfb6131df55faeabe822b3fdfb2b739b95bd452a50a1d97a29e42",
	"res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres": "fb50d3989b7aa41421753ad4db5d195366d9a2c25c15087e5e3a2b7863c69602",
	"res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_protected_neutral.tres": "d193d209dd3a38ab29ff0995ff8f15f4a96d4bc6bc011309d71de2be194b6c47",
	"res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_inferred_blue_gray.tres": "77f9f1dc4e7e0ebcd45cc3725942f2edc35af46c1899c102a23037ed14e65fa6",
	"res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_inferred_green_trim.tres": "81ccefa48d500a56cbc4aa61a202c6219496514405f0b5a5b2427ee1dafc6093",
	"res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_opaque_opening.tres": "046a5cf8ea3b0be4e462c2797840e0701c2a7722fe87263c25b7d8a6751c9a6e",
	"res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_opening_frame.tres": "aefab0d5fd9c1d6c94e82618708624f694a398e540aed1eb9dbe62882b414178",
	"res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_neutral_roof.tres": "f27469e3c8a5625446535a8cb9020eb2664b8202bc4c5bab1135445cd59c629e",
}
const LIVE_ROUTE_FILES := [
	"res://game/scripts/world/world_chunk_builder.gd",
	"res://game/resources/facades/facade-recognition-catalog.json",
	"res://game/resources/facades/facade-runtime-registry.json",
	"res://game/scripts/world/facades/facade_runtime_registry_loader.gd",
	"res://game/scenes/main.tscn",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(_hashes_match(), "A Dormitory 369 prototype input/package asset drifted from its measured pin.") \
		or not _require(_package_boundary_is_clean(), "The Dormitory 369 prototype package contains an external path, source photograph, or live-route attachment."):
		_finish()
		return
	var config := JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH)) as Dictionary
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	var wall := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	if not _require(_truth_contract_matches(config), "The Dormitory 369 truth, mapped/protected scope, topology, or future seam drifted.") \
		or not _require(PROTOTYPE.matches_record_pair(wall, roof), "The exact Dormitory 369 source wall+roof pair failed the matcher.") \
		or not _require(_matcher_fails_closed(wall, roof), "The Dormitory 369 seam accepted a wrong identity, component, height, or topology."):
		_finish()
		return
	var packed := load(SCENE_PATH) as PackedScene
	if not _require(packed != null, "The standalone Dormitory 369 scene did not load."):
		_finish()
		return
	var first := packed.instantiate() as Dormitory369StandaloneHeroPrototype
	first.auto_configure_from_frozen_source = false
	var first_result := first.configure_records(wall, roof)
	if not _require(bool(first_result.get("ok", false)), str(first_result.get("message", "The first Dormitory 369 build failed."))):
		first.free()
		_finish()
		return
	root.add_child(first)
	await process_frame
	await physics_frame
	if not _require(_prototype_matches(first, wall, roof, config), "The Dormitory 369 geometry, material scope, protected runs, topology, collision, or spray contract failed.") \
		or not _require(_collision_rays_match(first, wall, roof), "The elevated wall, roof landing, stair, or eave collision ray failed.") \
		or not _require(not bool(first.configure_records(wall, roof).get("ok", true)), "A configured Dormitory 369 prototype accepted duplicate configuration."):
		first.queue_free()
		_finish()
		return
	var signature := str(first.get_meta("deterministic_signature", ""))
	first.queue_free()
	await process_frame
	var second_result := PROTOTYPE.build_for_records(wall, roof)
	if not _require(bool(second_result.get("ok", false)), str(second_result.get("message", "The second Dormitory 369 build failed."))):
		_finish()
		return
	var second := second_result.node as Dormitory369StandaloneHeroPrototype
	root.add_child(second)
	await process_frame
	if not _require(str(second.get_meta("deterministic_signature", "")) == signature and signature.length() == 64, "Fresh Dormitory 369 prototype builds were nondeterministic.") \
		or not _require(EXPECTED_SIGNATURE.is_empty() or signature == EXPECTED_SIGNATURE, "Dormitory 369 deterministic signature drifted from its measured pin.") \
		or not _require(_prototype_matches(second, wall, roof, config), "The repeated Dormitory 369 prototype build failed its exact contract."):
		second.queue_free()
		_finish()
		return
	second.queue_free()
	print("DORMITORY_369_STANDALONE_HERO_SIGNATURE: %s" % signature)
	print("PASS: standalone w291189926 Dormitory 369 preserves every frozen source XZ and terrain-following wall bottom, replaces the 6 m fallback with a five-tier 15 m hero shell and exact-XZ roof landing, limits accepted warm field and facade modules to mapped runs 0..5, keeps runs 6..71 quiet, and supplies congruent structural collision with no live attachment, spray ownership, or self-acceptance")
	_finish()


func _truth_contract_matches(config: Dictionary) -> bool:
	var target := config.get("target", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	var mapped := config.get("mapped_public_region", {}) as Dictionary
	var protected := config.get("protected_region", {}) as Dictionary
	var inference := config.get("production_inference_m", {}) as Dictionary
	var collision := config.get("collision_contract", {}) as Dictionary
	var topology := config.get("prototype_topology", {}) as Dictionary
	var seam := config.get("future_live_integration_seam", {}) as Dictionary
	if str(config.get("schema_version", "")) != "ti.dormitory-369-standalone-hero-prototype/1" \
		or str(config.get("scope", "")).find("not connected") < 0 \
		or str(target.get("source_key", "")) != SOURCE_KEY \
		or str(target.get("wall_object_key", "")) != WALL_KEY \
		or str(target.get("roof_object_key", "")) != ROOF_KEY \
		or str(target.get("geometry_sha256", "")) != "4ad2f9d3c0e109d194965149b6e73c078e7796d19ec3efdfd8f78df6e9aee3e9" \
		or int(target.get("wall_run_count", 0)) != 72 \
		or int(target.get("wall_vertices", 0)) != 288 \
		or int(target.get("wall_triangles", 0)) != 144 \
		or int(target.get("roof_plan_vertices", 0)) != 34 \
		or int(target.get("roof_triangles", 0)) != 32:
		push_error("Dormitory truth debug: schema/target")
		return false
	for false_key in ["runtime_attachment", "recognition_accepted", "believability_accepted", "as_built_claim", "interior_modeled", "surveyed_height", "surveyed_tier_spacing", "surveyed_opening_dimensions", "surveyed_opening_count_or_cadence", "surveyed_stair_geometry", "reference_pixels_stored_or_copied", "horizontal_source_footprint_changed", "source_identity_changed"]:
		if bool(truth.get(false_key, true)):
			push_error("Dormitory truth debug: truth key %s" % false_key)
			return false
	if not bool(truth.get("prototype_only", false)) \
		or str(truth.get("all_unsurveyed_vertical_opening_and_stair_choices", "")) != "reversible_production_inference" \
		or _int_array(mapped.get("ordered_run_indices", []) as Array) != MAPPED_RUNS \
		or not is_equal_approx(float(mapped.get("length_m", 0.0)), 49.124) \
		or _int_array(protected.get("run_indices", []) as Array) != PROTECTED_RUNS:
		push_error("Dormitory truth debug: truth/mapped/protected")
		return false
	if int(inference.get("tier_count", 0)) != 5 \
		or not is_equal_approx(float(inference.get("tier_pitch", 0.0)), 3.0) \
		or not is_equal_approx(float(inference.get("hero_roof_landing_y", 0.0)), HERO_ROOF_Y) \
		or int(inference.get("opening_column_count", 0)) != 8 \
		or str(inference.get("height_rationale", "")).find("not asserted as measured") < 0:
		push_error("Dormitory truth debug: inference")
		return false
	if bool(collision.get("fallback_6m_collider_retained", true)) \
		or str(collision.get("structural_collision", "")).find("triangle-congruent") < 0 \
		or str(collision.get("spray_ownership", "")).find("none") < 0:
		push_error("Dormitory truth debug: collision")
		return false
	if int(topology.get("render_batches", 0)) != 9 \
		or int(topology.get("surfaces", 0)) != 9 \
		or int(topology.get("lifted_source_wall_triangles", 0)) != 144 \
		or int(topology.get("lifted_source_roof_triangles", 0)) != 32 \
		or int(topology.get("new_structural_visual_triangles", 0)) != 24 \
		or int(topology.get("decorative_overlay_triangles", 0)) != 3168 \
		or int(topology.get("total_visual_triangles", 0)) != 3368 \
		or not _batch_triangles_match(topology.get("visual_batch_triangles", {}) as Dictionary) \
		or int(topology.get("static_bodies", 0)) != 1 \
		or int(topology.get("collision_shapes", 0)) != 1 \
		or int(topology.get("collision_triangles", 0)) != 200 \
		or int(topology.get("collision_face_vertices", 0)) != 600 \
		or int(topology.get("navigation_nodes", -1)) != 0 \
		or int(topology.get("spray_owner_nodes", -1)) != 0:
		push_error("Dormitory truth debug: topology %s" % JSON.stringify(topology))
		return false
	var seam_ok := str(seam.get("registry_status", "")) == "not_registered" \
		and str(seam.get("world_builder_status", "")) == "not_attached" \
		and str(seam.get("required_live_behavior", "")).find("wall and roof together") >= 0 \
		and str(seam.get("forbidden_partial_attach", "")).find("never overlay") >= 0
	if not seam_ok:
		push_error("Dormitory truth debug: seam %s" % JSON.stringify(seam))
	return seam_ok


func _prototype_matches(instance: Dormitory369StandaloneHeroPrototype, wall: Dictionary, roof: Dictionary, config: Dictionary) -> bool:
	if not bool(instance.get_meta("prototype_only", false)) \
		or bool(instance.get_meta("runtime_attachment", true)) \
		or str(instance.get_meta("registry_status", "")) != "not_registered" \
		or str(instance.get_meta("world_builder_status", "")) != "not_attached" \
		or str(instance.get_meta("technical_evidence_status", "")) != "pending_independent_bar_raiser_review" \
		or bool(instance.get_meta("recognition_accepted", true)) \
		or bool(instance.get_meta("believability_accepted", true)) \
		or bool(instance.get_meta("as_built_claim", true)) \
		or bool(instance.get_meta("interior_modeled", true)) \
		or bool(instance.get_meta("horizontal_source_footprint_changed", true)) \
		or bool(instance.get_meta("source_identity_changed", true)) \
		or str(instance.get_meta("vertical_opening_and_stair_truth_class", "")) != "reversible_production_inference" \
		or instance.get_meta("mapped_public_run_indices", []) != MAPPED_RUNS \
		or instance.get_meta("protected_run_indices", []) != PROTECTED_RUNS \
		or bool(instance.get_meta("protected_runs_have_facade_modules", true)) \
		or instance.get_meta("accepted_warm_run_indices", []) != MAPPED_RUNS \
		or bool(instance.get_meta("accepted_warm_scope_extended", true)):
		return false
	if int(instance.get_meta("tier_count", 0)) != 5 \
		or int(instance.get_meta("opening_row_count", 0)) != 5 \
		or int(instance.get_meta("opening_column_count", 0)) != 8 \
		or int(instance.get_meta("broad_opening_count", 0)) != 20 \
		or int(instance.get_meta("narrow_opening_or_panel_count", 0)) != 20 \
		or int(instance.get_meta("green_eyebrow_count", 0)) != 20 \
		or int(instance.get_meta("base_vent_count", 0)) != 4 \
		or int(instance.get_meta("stair_end_volume_count", 0)) != 1 \
		or int(instance.get_meta("mapped_eave_count", 0)) != 1 \
		or bool(instance.get_meta("fallback_6m_collider_retained", true)) \
		or not bool(instance.get_meta("structural_visible_collision_congruent", false)) \
		or not bool(instance.get_meta("landing_geometry_is_lifted_exact_source_roof", false)) \
		or str(instance.get_meta("spray_ownership", "")) != "none_standalone":
		return false
	if int(instance.get_meta("mesh_instances", 0)) != 9 \
		or int(instance.get_meta("surfaces", 0)) != 9 \
		or int(instance.get_meta("visual_triangles", 0)) != 3368 \
		or not _batch_triangles_match(instance.get_meta("visual_batch_triangles", {}) as Dictionary) \
		or int(instance.get_meta("static_bodies", 0)) != 1 \
		or int(instance.get_meta("shapes", 0)) != 1 \
		or int(instance.get_meta("collision_triangles", 0)) != 200 \
		or int(instance.get_meta("collision_face_vertices", 0)) != 600:
		return false
	return _visual_batches_match(instance) \
		and _lifted_wall_matches(instance, wall) \
		and _lifted_roof_matches(instance, roof) \
		and _modules_stay_on_mapped_chain(instance, wall, config) \
		and _collision_tree_matches(instance) \
		and _structural_collision_matches_visible(instance) \
		and _count_type(instance, NavigationRegion3D) == 0 \
		and not _any_spray_group(instance)


func _visual_batches_match(instance: Node) -> bool:
	for node_name: String in EXPECTED_BATCH_TRIANGLES:
		var mesh_instance := instance.get_node_or_null(node_name) as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null or mesh_instance.mesh.get_surface_count() != 1:
			return false
		if int(mesh_instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX].size() / 3) != int(EXPECTED_BATCH_TRIANGLES[node_name]):
			return false
		var material := mesh_instance.mesh.surface_get_material(0)
		if material == null or material.resource_path != str(EXPECTED_MATERIALS[node_name]):
			return false
	return true


func _lifted_wall_matches(instance: Node, wall: Dictionary) -> bool:
	var mapped_vertices := _mesh_vertices(instance.get_node("AcceptedWarmLiftedWallRuns_0_5") as MeshInstance3D)
	var protected_vertices := _mesh_vertices(instance.get_node("ProtectedLiftedWallRuns_6_71") as MeshInstance3D)
	var mapped_cursor := 0
	var protected_cursor := 0
	var values := wall.vertices as Array
	for run_index in range(72):
		var destination := mapped_vertices if run_index in MAPPED_RUNS else protected_vertices
		var cursor := mapped_cursor if run_index in MAPPED_RUNS else protected_cursor
		for local_index in range(4):
			var source_offset := run_index * 12 + local_index * 3
			var actual := destination[cursor + local_index] as Vector3
			var expected_y := float(values[source_offset + 1]) if local_index < 2 else HERO_ROOF_Y
			if not is_equal_approx(actual.x, float(values[source_offset])) \
				or not is_equal_approx(actual.z, float(values[source_offset + 2])) \
				or not is_equal_approx(actual.y, expected_y):
				return false
		if run_index in MAPPED_RUNS:
			mapped_cursor += 4
		else:
			protected_cursor += 4
	return mapped_cursor == 24 and protected_cursor == 264


func _lifted_roof_matches(instance: Node, roof: Dictionary) -> bool:
	var actual := _mesh_vertices(instance.get_node("NeutralLiftedRoof") as MeshInstance3D)
	var values := roof.vertices as Array
	if actual.size() != 34:
		return false
	for index in range(34):
		var source_offset := index * 3
		var point := actual[index] as Vector3
		if not is_equal_approx(point.x, float(values[source_offset])) \
			or not is_equal_approx(point.z, float(values[source_offset + 2])) \
			or not is_equal_approx(point.y, HERO_ROOF_Y):
			return false
	return true


func _modules_stay_on_mapped_chain(instance: Node, wall: Dictionary, config: Dictionary) -> bool:
	var frame := _run_frame(wall, 0)
	if frame.is_empty():
		return false
	var start := frame.start as Vector3
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	var module_names := ["BlueGrayStructuralStairEnd", "BlueGrayGroundPanels", "GreenStructuralEave", "GreenEyebrows", "OpaqueExteriorOpeningsAndVents", "OpeningFramesAndMultiLiteDividers"]
	for node_name: String in module_names:
		for point: Vector3 in _mesh_vertices(instance.get_node(node_name) as MeshInstance3D):
			var delta := point - start
			var along := delta.dot(tangent)
			var relief := delta.dot(normal)
			if along < -0.01 or along > 49.134 or relief < -0.25 or relief > 0.5:
				return false
	var protected_text := JSON.stringify(config.get("protected_region", {})).to_lower()
	return "no facade modules" in protected_text and instance.get_meta("protected_run_indices", []) == PROTECTED_RUNS


func _collision_tree_matches(instance: Node) -> bool:
	var body := instance.get_node_or_null("StructuralCollision_NoSprayOwnership") as StaticBody3D
	if body == null or body.collision_layer != 1 or body.collision_mask != 0 \
		or str(body.get_meta("receiver_kind", "")) != "none" \
		or str(body.get_meta("derived_object_key", "")) != "prototype:%s" % WALL_KEY \
		or body.get_meta("source_keys", []) != [SOURCE_KEY] \
		or str(body.get_meta("spray_ownership", "")) != "none_standalone" \
		or bool(body.get_meta("fallback_6m_collider_retained", true)) \
		or not bool(body.get_meta("structural_visible_collision_congruent", false)):
		return false
	var shape_node := body.get_node_or_null("StructuralShape") as CollisionShape3D
	if shape_node == null or not (shape_node.shape is ConcavePolygonShape3D):
		return false
	var shape := shape_node.shape as ConcavePolygonShape3D
	return shape.get_faces().size() == 600 \
		and _count_type(instance, StaticBody3D) == 1 \
		and _count_type(instance, CollisionShape3D) == 1


func _structural_collision_matches_visible(instance: Node) -> bool:
	var expected := {}
	for node_name in ["ProtectedLiftedWallRuns_6_71", "AcceptedWarmLiftedWallRuns_0_5", "NeutralLiftedRoof", "BlueGrayStructuralStairEnd", "GreenStructuralEave"]:
		var mesh_instance := instance.get_node(node_name) as MeshInstance3D
		var arrays := mesh_instance.mesh.surface_get_arrays(0)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		for offset in range(0, indices.size(), 3):
			_add_triangle_key(expected, vertices[indices[offset]], vertices[indices[offset + 1]], vertices[indices[offset + 2]])
	var shape := (instance.get_node("StructuralCollision_NoSprayOwnership/StructuralShape") as CollisionShape3D).shape as ConcavePolygonShape3D
	var actual := {}
	var faces := shape.get_faces()
	for offset in range(0, faces.size(), 3):
		_add_triangle_key(actual, faces[offset], faces[offset + 1], faces[offset + 2])
	return expected == actual and _triangle_dictionary_count(expected) == 200


func _collision_rays_match(instance: Node3D, wall: Dictionary, roof: Dictionary) -> bool:
	var body := instance.get_node("StructuralCollision_NoSprayOwnership") as StaticBody3D
	var wall_frame := _run_frame(wall, 2)
	var wall_anchor := (wall_frame.start as Vector3).lerp(wall_frame.end as Vector3, 0.5)
	var wall_target := Vector3(wall_anchor.x, 14.0, wall_anchor.z)
	var wall_hit := _ray(instance, wall_target + (wall_frame.normal as Vector3) * 8.0, wall_target - (wall_frame.normal as Vector3) * 2.0)
	var roof_values := roof.vertices as Array
	var roof_indices := roof.indices as Array
	var roof_point := Vector3.ZERO
	for source_index in range(3):
		var vertex_index := int(roof_indices[source_index])
		roof_point += Vector3(float(roof_values[vertex_index * 3]), HERO_ROOF_Y, float(roof_values[vertex_index * 3 + 2])) / 3.0
	var roof_hit := _ray(instance, roof_point + Vector3.UP * 8.0, roof_point - Vector3.UP * 3.0)
	var chain_end := _chain_frame(wall, MAPPED_RUNS, 46.324)
	var stair_anchor := chain_end.wall_anchor as Vector3
	var stair_target := Vector3(stair_anchor.x, 12.0, stair_anchor.z)
	var stair_hit := _ray(instance, stair_target + (chain_end.normal as Vector3) * 8.0, stair_target - (chain_end.normal as Vector3) * 2.0)
	var chain_mid := _chain_frame(wall, MAPPED_RUNS, 24.562)
	var eave_anchor := chain_mid.wall_anchor as Vector3
	var eave_target := Vector3(eave_anchor.x, 18.25, eave_anchor.z)
	var eave_hit := _ray(instance, eave_target + (chain_mid.normal as Vector3) * 8.0, eave_target - (chain_mid.normal as Vector3) * 2.0)
	for hit: Dictionary in [wall_hit, roof_hit, stair_hit, eave_hit]:
		if hit.is_empty() or hit.get("collider") != body:
			return false
	return float((wall_hit.position as Vector3).y) > 9.39 \
		and is_equal_approx(float((roof_hit.position as Vector3).y), HERO_ROOF_Y) \
		and (roof_hit.normal as Vector3).dot(Vector3.UP) > 0.9 \
		and (stair_hit.position as Vector3).distance_to(stair_target) > 0.15 \
		and (eave_hit.position as Vector3).distance_to(eave_target) > 0.15


func _matcher_fails_closed(wall: Dictionary, roof: Dictionary) -> bool:
	var wrong_wall := wall.duplicate(true)
	wrong_wall.object_key = "building:w291189918:wall"
	if PROTOTYPE.matches_record_pair(wrong_wall, roof):
		return false
	wrong_wall = wall.duplicate(true)
	wrong_wall.source_keys = ["w291189918"]
	if PROTOTYPE.matches_record_pair(wrong_wall, roof):
		return false
	wrong_wall = wall.duplicate(true)
	wrong_wall.top_elevation_m = 9.391
	if PROTOTYPE.matches_record_pair(wrong_wall, roof):
		return false
	wrong_wall = wall.duplicate(true)
	wrong_wall.indices = (wrong_wall.indices as Array).slice(0, 429)
	if PROTOTYPE.matches_record_pair(wrong_wall, roof):
		return false
	var wrong_roof := roof.duplicate(true)
	wrong_roof.object_key = "building:w291189926:wall"
	return not PROTOTYPE.matches_record_pair(wall, wrong_roof)


func _hashes_match() -> bool:
	for path: String in PINNED_INPUTS:
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(PINNED_INPUTS[path]):
			push_error("Dormitory 369 hash debug: %s expected %s got %s" % [path, str(PINNED_INPUTS[path]), FileAccess.get_sha256(path)])
			return false
	return true


func _package_boundary_is_clean() -> bool:
	for path: String in PINNED_INPUTS:
		if not path.begins_with("res://game/") and not path.begins_with("res://generated/world/"):
			continue
		if path.ends_with(".json") or path.ends_with(".gd") or path.ends_with(".tscn") or path.ends_with(".tres"):
			var lower := FileAccess.get_file_as_string(path).to_lower()
			for token in ["file://", "/volumes/", "/users/", "res://discovery/", "res://evidence/", "res://source_assets/", "http://", "https://", "source_photograph.png", "source_photo.jpg"]:
				if token in lower:
					return false
	for path: String in LIVE_ROUTE_FILES:
		if FileAccess.file_exists(path) and "dormitory_369_standalone_hero" in FileAccess.get_file_as_string(path):
			return false
	return true


func _mesh_vertices(mesh_instance: MeshInstance3D) -> PackedVector3Array:
	return mesh_instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array


func _run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var offset := run_index * 12
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var tangent := end - start
	tangent.y = 0.0
	if tangent.length_squared() <= 0.000001:
		return {}
	return {"start": start, "end": end, "length_m": tangent.length(), "tangent": tangent.normalized(), "normal": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()}


func _chain_frame(record: Dictionary, runs: Array, chain_m: float) -> Dictionary:
	var accumulated := 0.0
	for run_value: Variant in runs:
		var frame := _run_frame(record, int(run_value))
		var length := float(frame.length_m)
		if chain_m <= accumulated + length + 0.0001:
			var fraction := clampf((chain_m - accumulated) / length, 0.0, 1.0)
			return {"wall_anchor": (frame.start as Vector3).lerp(frame.end as Vector3, fraction), "tangent": frame.tangent, "normal": frame.normal}
		accumulated += length
	return {}


func _ray(instance: Node3D, from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return instance.get_world_3d().direct_space_state.intersect_ray(query)


func _add_triangle_key(target: Dictionary, a: Vector3, b: Vector3, c: Vector3) -> void:
	var points := [_point_key(a), _point_key(b), _point_key(c)]
	points.sort()
	var key := "%s|%s|%s" % points
	target[key] = int(target.get(key, 0)) + 1


func _point_key(point: Vector3) -> String:
	return "%d,%d,%d" % [roundi(point.x * 10000.0), roundi(point.y * 10000.0), roundi(point.z * 10000.0)]


func _triangle_dictionary_count(values: Dictionary) -> int:
	var total := 0
	for value: Variant in values.values():
		total += int(value)
	return total


func _count_type(node: Node, type: Variant) -> int:
	var count := 1 if is_instance_of(node, type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, type)
	return count


func _any_spray_group(node: Node) -> bool:
	if node.is_in_group("spray_receiver"):
		return true
	for child: Node in node.get_children():
		if _any_spray_group(child):
			return true
	return false


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _batch_triangles_match(actual: Dictionary) -> bool:
	if actual.size() != EXPECTED_BATCH_TRIANGLES.size():
		return false
	for key: String in EXPECTED_BATCH_TRIANGLES:
		if int(actual.get(key, -1)) != int(EXPECTED_BATCH_TRIANGLES[key]):
			return false
	return true


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
