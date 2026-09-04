extends SceneTree

const PROTOTYPE := preload("res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd")
const CONFIG_PATH := "res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json"
const SCENE_PATH := "res://game/scenes/world/facades/navy_chapel_187/navy_chapel_187_standalone_hero_prototype.tscn"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const PACKET_PATH := "res://discovery/facades/p3_reference_packets/w291189336_navy_chapel_building_187.md"
const WALL_KEY := "building:w291189336:wall"
const ROOF_KEY := "building:w291189336:roof"
const SOURCE_KEY := "w291189336"
const OBSERVED_SSE_RUNS := [9, 10]
const OBSERVED_PARTIAL_SIDE_RUNS := [11, 12, 13]
const PROTECTED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33]
const EXPECTED_BATCH_TRIANGLES := {
	"ProtectedExactWallAndRearClosure": 65,
	"AcceptedCreamExactSSERuns_9_10": 4,
	"InferredCreamSSEGableBelfryEntry": 25,
	"NeutralRoofAndCap": 26,
	"ObservedPaleTrim": 360,
	"OpaqueExteriorOpenings": 60,
}
const EXPECTED_HASHES := {
	CONFIG_PATH: "c8f2ab09f3943a5ec8abea7cb9a108f49990bff1d83003c3b3622187a269dea2",
	CHUNK_PATH: "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	PACKET_PATH: "7eb592503ce8e276c38ef3ecaf7f2d3dd17e1eeb32adbe45d1059c5cb4693330",
	"res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd": "067c12e29c9fd352915ef2a501fcd7687b450081c79a4281d63bbfef1c19e7db",
	SCENE_PATH: "2ab7db7ef064bf8d9d59fb3dd631dd1b7cddd9fc18eebbb67832e75df8eb8083",
	"res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres": "91cd7ce14550bdfb6773a4013ef0db8bbb24bd5cc9d0734f6c591f23d6552206",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres": "2ee243415387c9f3d9dfd5664c0a5e13107745a83d9dcb489dd39e5aeb2ff17a",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres": "b565aa44566a0bb93d07d041b1e8331d9f35cb83ec34f6a2ec403b362311c380",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres": "253e9c2a5013f81aed446f6e55b702dea3792189658ce285726788d15376bc41",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres": "89be7fbe0feb68525c5423540d3a6f17f269567875174f23522b4e964ba737b1",
}
const PACKAGE_FILES := [
	CONFIG_PATH,
	SCENE_PATH,
	"res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres",
]
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
	if not _require(_hashes_match(), "A Chapel prototype input/package asset drifted from its measured pin.") \
		or not _require(_package_boundary_is_clean(), "The Chapel package contains an external path, URL, source photograph, or live-route attachment."):
		_finish()
		return
	var config := JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH)) as Dictionary
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	var wall := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	if not _require(_truth_contract_matches(config), "The Chapel prototype truth boundary, mapped runs, protected scope, topology, or future seam drifted.") \
		or not _require(PROTOTYPE.matches_record_pair(wall, roof), "The exact Chapel wall+roof source pair did not match the fail-closed seam.") \
		or not _require(_fail_closed_matcher(wall, roof), "The Chapel target matcher accepted a wrong identity, component, or topology."):
		_finish()
		return
	var packed := load(SCENE_PATH) as PackedScene
	if not _require(packed != null, "The standalone Chapel scene did not load."):
		_finish()
		return
	var first := packed.instantiate() as NavyChapel187StandaloneHeroPrototype
	first.auto_configure_from_frozen_source = false
	var first_result := first.configure_records(wall, roof)
	if not _require(bool(first_result.get("ok", false)), str(first_result.get("message", "The first Chapel build failed."))):
		first.free()
		_finish()
		return
	root.add_child(first)
	await process_frame
	await physics_frame
	if not _require(_prototype_matches(first, wall, roof, config), "The Chapel geometry, material scope, protected-run boundary, topology, or collision contract failed.") \
		or not _require(_collision_rays_match(first, wall), "The Chapel entry, pitched roof, or belfry cap did not provide truthful world-solid collision.") \
		or not _require(not bool(first.configure_records(wall, roof).get("ok", true)), "A configured Chapel prototype accepted duplicate configuration."):
		first.queue_free()
		_finish()
		return
	var signature := str(first.get_meta("deterministic_signature", ""))
	first.queue_free()
	await process_frame
	var second_result := PROTOTYPE.build_for_records(wall, roof)
	if not _require(bool(second_result.get("ok", false)), str(second_result.get("message", "The second Chapel factory build failed."))):
		_finish()
		return
	var second := second_result.node as NavyChapel187StandaloneHeroPrototype
	root.add_child(second)
	await process_frame
	if not _require(str(second.get_meta("deterministic_signature", "")) == signature and signature.length() == 64, "Fresh Chapel prototype builds were nondeterministic.") \
		or not _require(_prototype_matches(second, wall, roof, config), "The repeated Chapel prototype build failed its exact contract."):
		second.queue_free()
		_finish()
		return
	second.queue_free()
	print("NAVY_CHAPEL_187_STANDALONE_HERO_SIGNATURE: %s" % signature)
	print("PASS: standalone w291189336 Chapel hero preserves the exact frozen shell/identity, limits observed treatment to SSE runs 9,10 and partial public-side runs 11..13, keeps all other runs quiet, and supplies matched world-solid collision for the inferred gable roof, belfry/cap/cross, and projecting entry without any live attachment or self-acceptance")
	_finish()


func _truth_contract_matches(config: Dictionary) -> bool:
	if str(config.get("schema_version", "")) != "ti.navy-chapel-187-standalone-hero-prototype/1" \
		or str(config.get("scope", "")).find("not connected") < 0:
		push_error("Chapel truth debug: schema/scope")
		return false
	var target := config.get("target", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	var mapped := config.get("mapped_runs", []) as Array
	var protected := config.get("protected_regions", []) as Array
	var collision := config.get("collision_contract", {}) as Dictionary
	var topology := config.get("prototype_topology", {}) as Dictionary
	var seam := config.get("future_integration_seam", {}) as Dictionary
	if str(target.get("source_key", "")) != SOURCE_KEY \
		or str(target.get("wall_object_key", "")) != WALL_KEY \
		or str(target.get("roof_object_key", "")) != ROOF_KEY \
		or str(target.get("geometry_sha256", "")) != "c62a89b238b4831fa2c16e3244c0bffdf17a80ec09498396bc8e582c5c9e696a" \
		or int(target.get("wall_run_count", 0)) != 34 \
		or int(target.get("wall_vertices", 0)) != 136 \
		or int(target.get("wall_triangles", 0)) != 68 \
		or int(target.get("roof_plan_vertices", 0)) != 20 \
		or int(target.get("roof_triangles", 0)) != 18:
		push_error("Chapel truth debug: target")
		return false
	if not bool(truth.get("prototype_only", false)) \
		or bool(truth.get("runtime_attachment", true)) \
		or bool(truth.get("recognition_accepted", true)) \
		or bool(truth.get("believability_accepted", true)) \
		or bool(truth.get("as_built_claim", true)) \
		or bool(truth.get("interior_modeled", true)) \
		or bool(truth.get("surveyed_vertical_dimensions", true)) \
		or bool(truth.get("surveyed_opening_dimensions", true)) \
		or bool(truth.get("surveyed_pane_count", true)) \
		or bool(truth.get("surveyed_side_cadence", true)) \
		or bool(truth.get("reference_pixels_stored_or_copied", true)) \
		or bool(truth.get("horizontal_source_footprint_changed", true)) \
		or bool(truth.get("source_identity_changed", true)) \
		or str(truth.get("all_unsurveyed_dimensions_and_cadence", "")) != "reversible_production_inference":
		push_error("Chapel truth debug: truth boundary")
		return false
	if mapped.size() != 2 \
		or _int_array((mapped[0] as Dictionary).get("ordered_run_indices", []) as Array) != OBSERVED_SSE_RUNS \
		or not is_equal_approx(float((mapped[0] as Dictionary).get("length_m", 0.0)), 16.362) \
		or _int_array((mapped[1] as Dictionary).get("ordered_run_indices", []) as Array) != OBSERVED_PARTIAL_SIDE_RUNS \
		or not is_equal_approx(float((mapped[1] as Dictionary).get("length_m", 0.0)), 11.829) \
		or protected.is_empty() \
		or _int_array((protected[0] as Dictionary).get("run_indices", []) as Array) != PROTECTED_RUNS:
		push_error("Chapel truth debug: mapped/protected runs")
		return false
	if str(collision.get("base_source_wall_shell", "")).find("exact") < 0 \
		or str(collision.get("base_source_roof", "")).find("exact") < 0 \
		or str(collision.get("new_structural_collision", "")).find("triangle-congruent") < 0 \
		or str(collision.get("spray_ownership", "")).find("none") < 0:
		push_error("Chapel truth debug: collision")
		return false
	if int(topology.get("render_batches", 0)) != 6 \
		or int(topology.get("surfaces", 0)) != 6 \
		or int(topology.get("exact_source_wall_triangles", 0)) != 68 \
		or int(topology.get("exact_source_roof_triangles", 0)) != 18 \
		or int(topology.get("new_structural_visual_triangles", 0)) != 58 \
		or int(topology.get("decorative_overlay_triangles", 0)) != 396 \
		or int(topology.get("total_visual_triangles", 0)) != 540 \
		or not _batch_triangles_match(topology.get("visual_batch_triangles", {}) as Dictionary) \
		or int(topology.get("static_bodies", 0)) != 1 \
		or int(topology.get("collision_shapes", 0)) != 1 \
		or int(topology.get("collision_triangles", 0)) != 144 \
		or int(topology.get("collision_face_vertices", 0)) != 432 \
		or int(topology.get("navigation_nodes", -1)) != 0 \
		or int(topology.get("spray_owner_nodes", -1)) != 0:
		push_error("Chapel truth debug: topology %s" % JSON.stringify(topology))
		return false
	if str(seam.get("registry_status", "")) != "not_registered" \
		or str(seam.get("world_builder_status", "")) != "not_attached" \
		or str(seam.get("required_live_behavior", "")).find("wall and roof together") < 0 \
		or str(seam.get("forbidden_partial_attach", "")).find("never attach") < 0:
		push_error("Chapel truth debug: seam")
		return false
	var source_text := JSON.stringify(config.get("source_bindings", [])).to_lower()
	var blocked_text := JSON.stringify(config.get("blocked_claims", [])).to_lower()
	for phrase in ["sse gabled entrance end", "multipane window", "square belfry", "pyramidal cap", "visible cross", "partial public long-side rhythm"]:
		if phrase not in source_text:
			push_error("Chapel truth debug: missing source phrase %s" % phrase)
			return false
	for phrase in ["as-built", "exact pane count", "rear", "private-side", "interior", "recognition", "plaque", "arbitrary accent color"]:
		if phrase not in blocked_text:
			push_error("Chapel truth debug: missing blocked phrase %s" % phrase)
			return false
	return true


func _prototype_matches(instance: NavyChapel187StandaloneHeroPrototype, wall: Dictionary, roof: Dictionary, config: Dictionary) -> bool:
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
		or str(instance.get_meta("vertical_and_roof_geometry_truth_class", "")) != "reversible_production_inference" \
		or instance.get_meta("observed_sse_run_indices", []) != OBSERVED_SSE_RUNS \
		or instance.get_meta("observed_partial_side_run_indices", []) != OBSERVED_PARTIAL_SIDE_RUNS \
		or instance.get_meta("protected_run_indices", []) != PROTECTED_RUNS \
		or bool(instance.get_meta("protected_runs_have_modules", true)) \
		or instance.get_meta("accepted_cream_run_indices", []) != OBSERVED_SSE_RUNS \
		or bool(instance.get_meta("accepted_cream_scope_extended", true)) \
		or str(instance.get_meta("new_structure_cream_truth_class", "")) != "reversible_production_inference_not_material_accepted":
		return false
	if int(instance.get_meta("complete_sse_composition_count", 0)) != 1 \
		or int(instance.get_meta("belfry_count", 0)) != 1 \
		or int(instance.get_meta("pyramidal_cap_count", 0)) != 1 \
		or int(instance.get_meta("cross_count", 0)) != 1 \
		or int(instance.get_meta("tall_divided_window_count", 0)) != 1 \
		or int(instance.get_meta("projecting_entry_count", 0)) != 1 \
		or int(instance.get_meta("partial_side_opening_group_count", 0)) != 3 \
		or not bool(instance.get_meta("entry_and_new_silhouette_collision_congruent", false)) \
		or not bool(instance.get_meta("landing_geometry_includes_pitched_roof_and_cap", false)) \
		or str(instance.get_meta("spray_ownership", "")) != "none_standalone":
		return false
	if int(instance.get_meta("mesh_instances", 0)) != 6 \
		or int(instance.get_meta("surfaces", 0)) != 6 \
		or int(instance.get_meta("visual_triangles", 0)) != 540 \
		or not _batch_triangles_match(instance.get_meta("visual_batch_triangles", {}) as Dictionary) \
		or int(instance.get_meta("static_bodies", 0)) != 1 \
		or int(instance.get_meta("shapes", 0)) != 1 \
		or int(instance.get_meta("collision_triangles", 0)) != 144 \
		or int(instance.get_meta("collision_face_vertices", 0)) != 432:
		return false
	if not _visual_batches_match(instance) \
		or not _exact_wall_shell_matches(instance, wall) \
		or not _roof_plan_and_inferred_footprint_match(instance, roof, config) \
		or not _collision_tree_matches(instance) \
		or _count_type(instance, NavigationRegion3D) != 0 \
		or _any_spray_group(instance) \
		or _node_names_contain_forbidden_token(instance):
		return false
	return true


func _visual_batches_match(instance: Node) -> bool:
	var expected_materials := {
		"ProtectedExactWallAndRearClosure": "res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres",
		"AcceptedCreamExactSSERuns_9_10": "res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
		"InferredCreamSSEGableBelfryEntry": "res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres",
		"NeutralRoofAndCap": "res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres",
		"ObservedPaleTrim": "res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres",
		"OpaqueExteriorOpenings": "res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres",
	}
	for node_name: String in expected_materials:
		var mesh_instance := instance.get_node_or_null(node_name) as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null or mesh_instance.mesh.get_surface_count() != 1:
			return false
		if mesh_instance.mesh.surface_get_material(0).resource_path != str(expected_materials[node_name]):
			return false
		if int(mesh_instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX].size() / 3) != int(EXPECTED_BATCH_TRIANGLES[node_name]):
			return false
	return true


func _exact_wall_shell_matches(instance: Node, wall: Dictionary) -> bool:
	var protected_vertices := _mesh_vertices(instance.get_node("ProtectedExactWallAndRearClosure") as MeshInstance3D)
	var cream_vertices := _mesh_vertices(instance.get_node("AcceptedCreamExactSSERuns_9_10") as MeshInstance3D)
	var protected_cursor := 0
	var cream_cursor := 0
	var values := wall.vertices as Array
	for run_index in range(34):
		var destination := cream_vertices if run_index in OBSERVED_SSE_RUNS else protected_vertices
		var cursor := cream_cursor if run_index in OBSERVED_SSE_RUNS else protected_cursor
		for local_index in range(4):
			var offset := run_index * 12 + local_index * 3
			var expected := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
			if cursor + local_index >= destination.size() or not (destination[cursor + local_index] as Vector3).is_equal_approx(expected):
				return false
		if run_index in OBSERVED_SSE_RUNS:
			cream_cursor += 4
		else:
			protected_cursor += 4
	return cream_cursor == 8 and protected_cursor == 128


func _roof_plan_and_inferred_footprint_match(instance: Node, roof_record: Dictionary, config: Dictionary) -> bool:
	var vertices := _mesh_vertices(instance.get_node("NeutralRoofAndCap") as MeshInstance3D)
	var values := roof_record.vertices as Array
	if vertices.size() != 40:
		return false
	var polygon := PackedVector2Array()
	for source_index in range(20):
		var offset := source_index * 3
		var expected := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
		if not (vertices[source_index] as Vector3).is_equal_approx(expected):
			return false
		polygon.append(Vector2(expected.x, expected.z))
	for inferred_index in range(20, 28):
		var point3 := vertices[inferred_index] as Vector3
		var point := Vector2(point3.x, point3.z)
		if not Geometry2D.is_point_in_polygon(point, polygon) and _distance_to_polygon(point, polygon) > 0.002:
			return false
	var inference := config.production_inference_m as Dictionary
	var maximum_y := -INF
	for point_value: Variant in _all_mesh_vertices(instance):
		maximum_y = maxf(maximum_y, (point_value as Vector3).y)
	var expected_max_y := float(inference.cross_vertical_center_y) + float(inference.cross_vertical_height) * 0.5
	return is_equal_approx(maximum_y, expected_max_y)


func _collision_tree_matches(instance: Node) -> bool:
	var body := instance.get_node_or_null("StructuralCollision_NoSprayOwnership") as StaticBody3D
	if body == null or body.collision_layer != 1 or body.collision_mask != 0 \
		or str(body.get_meta("receiver_kind", "")) != "none" \
		or str(body.get_meta("derived_object_key", "")) != "prototype:%s" % WALL_KEY \
		or body.get_meta("source_keys", []) != [SOURCE_KEY] \
		or str(body.get_meta("spray_ownership", "")) != "none_standalone" \
		or not bool(body.get_meta("structural_visible_collision_congruent", false)):
		return false
	var shape_node := body.get_node_or_null("StructuralShape") as CollisionShape3D
	if shape_node == null or not (shape_node.shape is ConcavePolygonShape3D):
		return false
	var shape := shape_node.shape as ConcavePolygonShape3D
	return shape.get_faces().size() == 432 \
		and str(shape.get_meta("derived_object_key", "")) == "prototype:%s" % WALL_KEY \
		and shape.get_meta("source_keys", []) == [SOURCE_KEY] \
		and _count_type(instance, StaticBody3D) == 1 \
		and _count_type(instance, CollisionShape3D) == 1


func _collision_rays_match(instance: Node3D, wall: Dictionary) -> bool:
	var basis := _chain_basis(wall, OBSERVED_SSE_RUNS)
	if basis.is_empty():
		return false
	var front := (basis.start as Vector3).lerp(basis.end as Vector3, 0.5)
	var tangent := basis.tangent as Vector3
	var outward := basis.normal as Vector3
	var entry_target := Vector3(front.x, 5.5, front.z) + outward * 0.75
	var world := instance.get_world_3d()
	var entry_hit := _ray(world, entry_target + outward * 10.0, entry_target - outward * 1.0)
	var roof_xz := front - outward * 5.0 - tangent * 4.5
	var roof_hit := _ray(world, Vector3(roof_xz.x, 30.0, roof_xz.z), Vector3(roof_xz.x, 0.0, roof_xz.z))
	var cap_xz := front - outward * 8.5 + tangent * 0.7
	var cap_hit := _ray(world, Vector3(cap_xz.x, 30.0, cap_xz.z), Vector3(cap_xz.x, 0.0, cap_xz.z))
	for hit: Dictionary in [entry_hit, roof_hit, cap_hit]:
		if hit.is_empty() or hit.get("collider") != instance.get_node("StructuralCollision_NoSprayOwnership"):
			return false
	return (roof_hit.normal as Vector3).y > 0.4 \
		and float((roof_hit.position as Vector3).y) > 14.04 \
		and (cap_hit.normal as Vector3).y > 0.25 \
		and float((cap_hit.position as Vector3).y) > 21.0


func _ray(world: World3D, from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return world.direct_space_state.intersect_ray(query)


func _fail_closed_matcher(wall: Dictionary, roof: Dictionary) -> bool:
	var wrong_wall_key := wall.duplicate(true)
	wrong_wall_key["object_key"] = "building:w291189918:wall"
	var wrong_wall_source := wall.duplicate(true)
	wrong_wall_source["source_keys"] = ["w291189918"]
	var wrong_wall_kind := wall.duplicate(true)
	wrong_wall_kind["feature_kind"] = "building_roof"
	var wrong_roof_key := roof.duplicate(true)
	wrong_roof_key["object_key"] = "building:w291189336:wall"
	var wrong_roof_topology := roof.duplicate(true)
	(wrong_roof_topology["indices"] as Array).pop_back()
	return not PROTOTYPE.matches_record_pair(wrong_wall_key, roof) \
		and not PROTOTYPE.matches_record_pair(wrong_wall_source, roof) \
		and not PROTOTYPE.matches_record_pair(wrong_wall_kind, roof) \
		and not PROTOTYPE.matches_record_pair(wall, wrong_roof_key) \
		and not PROTOTYPE.matches_record_pair(wall, wrong_roof_topology)


func _package_boundary_is_clean() -> bool:
	for path: String in PACKAGE_FILES:
		var text := FileAccess.get_file_as_string(path).to_lower()
		for forbidden in ["http://", "https://", "file://", "/volumes/", "/users/", ".jpg", ".jpeg", ".webp"]:
			if forbidden in text:
				return false
	var tokens := ["navy_chapel_187_standalone_hero_prototype", "NavyChapel187StandaloneHeroPrototype"]
	for path: String in LIVE_ROUTE_FILES:
		if not FileAccess.file_exists(path):
			continue
		var live_text := FileAccess.get_file_as_string(path)
		for token: String in tokens:
			if token in live_text:
				return false
	return true


func _hashes_match() -> bool:
	for path: String in EXPECTED_HASHES:
		if FileAccess.get_sha256(path) != str(EXPECTED_HASHES[path]):
			push_error("Hash drift: %s expected=%s actual=%s" % [path, str(EXPECTED_HASHES[path]), FileAccess.get_sha256(path)])
			return false
	return true


func _batch_triangles_match(actual: Dictionary) -> bool:
	if actual.size() != EXPECTED_BATCH_TRIANGLES.size():
		return false
	for key: String in EXPECTED_BATCH_TRIANGLES:
		if int(actual.get(key, -1)) != int(EXPECTED_BATCH_TRIANGLES[key]):
			return false
	return true


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _chain_basis(record: Dictionary, runs: Array) -> Dictionary:
	var first := _run_frame(record, int(runs[0]))
	var last := _run_frame(record, int(runs[runs.size() - 1]))
	if first.is_empty() or last.is_empty():
		return {}
	return {"start": first.start, "end": last.end, "tangent": first.tangent, "normal": first.normal}


func _run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var offset := run_index * 12
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var tangent := end - start
	tangent.y = 0.0
	return {
		"start": start,
		"end": end,
		"tangent": tangent.normalized(),
		"normal": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized(),
	}


func _mesh_vertices(mesh_instance: MeshInstance3D) -> PackedVector3Array:
	return mesh_instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array


func _all_mesh_vertices(node: Node) -> Array:
	var result: Array = []
	for child in node.get_children():
		if child is MeshInstance3D:
			result.append_array(Array(_mesh_vertices(child as MeshInstance3D)))
	return result


func _distance_to_polygon(point: Vector2, polygon: PackedVector2Array) -> float:
	var minimum := INF
	for index in range(polygon.size()):
		minimum = minf(minimum, Geometry2D.get_closest_point_to_segment(point, polygon[index], polygon[(index + 1) % polygon.size()]).distance_to(point))
	return minimum


func _count_type(node: Node, type_value: Variant) -> int:
	var count := 0
	for child in node.get_children():
		if is_instance_of(child, type_value):
			count += 1
		count += _count_type(child, type_value)
	return count


func _any_spray_group(node: Node) -> bool:
	for group in ["spray_receiver_wall", "spray_receiver"]:
		if node.is_in_group(group):
			return true
	for child in node.get_children():
		if _any_spray_group(child):
			return true
	return false


func _node_names_contain_forbidden_token(node: Node) -> bool:
	var lowered := str(node.name).to_lower()
	for token in ["plaque", "sign", "label", "stained"]:
		if token in lowered:
			return true
	for child in node.get_children():
		if _node_names_contain_forbidden_token(child):
			return true
	return false


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
