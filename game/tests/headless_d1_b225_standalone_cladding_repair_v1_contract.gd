extends SceneTree

const CONFIG_PATH := "res://game/resources/facades/d1_current/repairs/d1_b225_nnw_long_cladding_repair_v1.json"
const SCENE_PATH := "res://game/scenes/world/facades/d1_current/repairs/d1_b225_standalone_cladding_repair_v1.tscn"
const FACTORY_PATH := "res://game/scripts/world/facades/d1_b225_standalone_cladding_repair_v1.gd"
const UV_HELPER_PATH := "res://game/scripts/world/facades/d1_b225_cumulative_meter_uv_v1.gd"
const MATERIAL_PATH := "res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres"
const TEXTURE_PATH := "res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png"
const IMPORT_PATH := TEXTURE_PATH + ".import"
const LIVE_ADAPTER_PATH := "res://game/scripts/world/facades/d1_b225_live_attachment.gd"
const LIVE_CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b225_live_attachment.json"
const WORLD_BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const CANDIDATE_SEAM_PATH := "res://game/tests/support/d1_b225_" + "prepromotion_candidate_seam.gd"
const CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const RUNTIME_REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const RUNTIME_LOADER_PATH := "res://game/scripts/world/facades/facade_runtime_registry_loader.gd"
const ACCEPTED_TRIALS_PATH := "res://game/scripts/world/facades/accepted_material_run_trials.gd"
const LIVE_ADAPTER_ID := "active-adapter:d1-b225-live:building:w95934119:wall"
const CONTROL_SCENE_PATH := "res://game/scenes/world/facades/d1_current/d1_current_standalone_prototype_pair.tscn"
const EXPECTED_TEXTURE_SHA256 := "63e755e9fe5a5dcfb662b4265f1e769fc1b371987b55579b1ca4ffb63015015b"
const EXPECTED_CONFIG_SHA256 := "7c1c2d508f78236590c6d413604be60b3a5c48865878e69d294177d05c48d166"
const EXPECTED_SCENE_SHA256 := "008669d9e0c2e04801ee8d720976e72e2041c82188c7fd14fe075ad48cb69914"
const EXPECTED_FACTORY_SHA256 := "8c06afec4835441ec386251e700cc7ba91b8fea9fe070549561e401aa530d58e"
const EXPECTED_UV_HELPER_SHA256 := "20d0f597ef0a49f85a0b8062d01186c7ad13262592f99a7f630be06938cd7dc2"
const EXPECTED_MATERIAL_SHA256 := "7fa7f3165dee560c48f5a092f317900b87b0876f27bb6a0e937b9c406a8d4ea1"
const EXPECTED_GEOMETRY_SIGNATURE := "281a471f6cff9b0530aa51c98cc737d276dc0d9210996a5403d9fe44996dd2a2"
const EXPECTED_UV_PLAN_SIGNATURE := "6b33f7b7146815b87fa7aec9bced760309104f4f56038e37e1820199c9b446f5"
const RUN_INDICES := [10, 11, 12, 13]
const RUN_LENGTHS_M := [10.372629078, 6.510893794, 7.049860211, 22.328585289]
const U_STARTS_M := [0.0, 10.372629078, 16.883522872, 23.933383083]
const U_ENDS_M := [10.372629078, 16.883522872, 23.933383083, 46.261968372]
const WIDTH_M := 46.261968372

const SEALED_HASHES := {
	"res://game/resources/facades/d1_current/d1_b201_public_wsw.json": "30bc1f62e5fa44c60bdcfb1bfd4f6f679d391618fa213373e571080face6ec6c",
	"res://game/resources/facades/d1_current/d1_b225_nnw_long.json": "dc3591df4a68af19b5fa53f402ed15d5e3f83946c4a113f024d5b7d41f2f82b8",
	"res://game/resources/facades/d1_current/d1_current_standalone_pair.json": "fdf00bba0562036f499a5a64e47e5e1b695d49d6cb4ada7acafd450b3dcfefb9",
	"res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres": "5bdd67e659a0cce14abe3605f5a7fbfd85b0374d0a38be23cda326017235fe13",
	"res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres": "be97cdfd7367cd73172c4429ca212db0d1fc68bed34f4db6ce307d02a5225b94",
	"res://game/resources/materials/world/d1_current/b201_service_leaf.tres": "de9895a808e4d64afc2c727e77ef92b590c9c718266ba118e64c489e84690cfd",
	"res://game/resources/materials/world/d1_current/b201_warm_wall.tres": "6f5f6835790ab338454e72be58c2956deb6e470086797e209be0fab4d37ec788",
	"res://game/resources/materials/world/d1_current/b225_aged_horizontal_cladding.tres": "49e2a7cb075707f1384106301583d295ffe955450d10c36a8526a7a87722f9f0",
	"res://game/resources/materials/world/d1_current/shared_dark_glass.tres": "ad8931db8954fd5ebc8fdd809f70afb279dd74a36e53e1d9ca907c44409f10d3",
	"res://game/resources/materials/world/d1_current/shared_deep_reveal.tres": "b15a82b4e37546cffac83d1b7c4e30f5e6828c7940a8da6581b218589cd908d5",
	"res://game/resources/materials/world/d1_current/shared_pale_frame.tres": "9a2de298ff545cf80c5da0ed0aa37d9d4ebbf10fec8eb78810af7e4d012d1436",
	"res://game/scripts/world/facades/d1_current_standalone_prototypes.gd": "797bbb81e7f772f3fab3989d358772be4f1b16cb7e31a05571463e0d6ec31a5e",
	"res://game/scenes/world/facades/d1_current/d1_current_standalone_prototype_pair.tscn": "0fdd5d356deb57664549db95fd04e123290c1fb9490b8024569e997616893d7f",
	"res://evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md": "8567cd5eb9080f8f7cb563152ae83885330d366cc56ecc8513d5ebdadf491feb",
	"res://evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04/05-b225-grounded-complete-nnw.png": "21b656561966ac75d6e473796728d0d9657f4019be08476b4ccf45d866934122",
	"res://evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04/06-b225-grounded-clerestory-oblique.png": "30597aa75d628550dcee8d06a80343ec5603074dfdfd53a3fc2c85a4e0770bc8",
	"res://evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04/07-b225-clerestory-course-close.png": "45299789b409017ca7b989b3bdc30f8773618f63e6f81076259e62a5af9b70b9",
	"res://evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04/08-b225-changed-light-oblique.png": "2d63b8fd64a8266934b9017249ccb213fe134a217f789a991d74f1858a5a8d45",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if "--mounted" in OS.get_cmdline_user_args():
		_run_mounted_contract()
		_finish()
		return
	var config := _load_json(CONFIG_PATH)
	if config.is_empty():
		_finish()
		return
	_require(_byte_contract_matches(), "B225 repair or sealed parent byte contract failed.")
	_require(_config_contract_matches(config), "B225 repair config scope/provenance/topology contract failed.")
	_require(_material_contract_matches(), "B225 generated-albedo scalar-material/import contract failed.")
	_require(_source_isolation_matches(), "B225 standalone isolation or its distinct promoted production route boundary failed.")

	var packed := load(SCENE_PATH) as PackedScene
	var control_packed := load(CONTROL_SCENE_PATH) as PackedScene
	if not _require(packed != null and control_packed != null, "Candidate or sealed control scene did not load."):
		_finish()
		return
	var instance := packed.instantiate() as Node3D
	root.add_child(instance)
	var control := control_packed.instantiate() as Node3D
	root.add_child(control)
	await process_frame
	var prototype := instance.get_node_or_null("B225_w95934119_CladdingRepairV1") as Node3D
	var old_prototype := control.get_node_or_null("B225_w95934119") as Node3D
	_require(prototype != null and old_prototype != null, "B225 candidate or sealed control prototype root missing.")
	if prototype != null and old_prototype != null:
		_require(_geometry_contract_matches(instance, prototype), "B225 candidate metre-UV/topology contract failed.")
		_require(_clerestory_is_byte_for_byte_equivalent(prototype, old_prototype), "Preserved clerestory transforms/material batches drifted from the sealed B225 source.")
		print("D1_B225_REPAIR_GEOMETRY_SIGNATURE=%s" % str(prototype.get_meta("geometry_signature", "")))
		print("D1_B225_REPAIR_UV_PLAN_SIGNATURE=%s" % str(prototype.get_meta("uv_plan_signature", "")))
	instance.queue_free()
	control.queue_free()
	if not _failed:
		print("PASS: the historical B225 standalone repair preserves ten clerestory groups, four cumulative-metre field quads, one albedo plus scalar roughness, and 1,088 triangles; its factory, scene, config, and UV helper remain unwired, while the distinct promoted receiver-relative adapter reuses only the approved material/texture and the prepromotion candidate seam remains test-only")
	_finish()


func _run_mounted_contract() -> void:
	for path: String in [CONFIG_PATH, SCENE_PATH, FACTORY_PATH, UV_HELPER_PATH, MATERIAL_PATH, TEXTURE_PATH]:
		_require(ResourceLoader.exists(path), "Mounted PCK is missing intentional B225 repair candidate resource: %s" % path)
	var material := load(MATERIAL_PATH) as StandardMaterial3D
	_require(material != null and material.albedo_texture != null, "Mounted PCK B225 material/texture failed to load.")
	if not _failed:
		print("PASS: mounted PCK preserves the explicitly costed historical B225 standalone review artifact and its albedo/material/scene/UV resources")


func _byte_contract_matches() -> bool:
	for path_value: Variant in SEALED_HASHES:
		var path := str(path_value)
		if FileAccess.get_sha256(path) != str(SEALED_HASHES[path_value]):
			push_error("Sealed byte drift: %s" % path)
			return false
	if FileAccess.get_sha256(TEXTURE_PATH) != EXPECTED_TEXTURE_SHA256:
		return false
	for pair: Array in [
		[CONFIG_PATH, EXPECTED_CONFIG_SHA256],
		[SCENE_PATH, EXPECTED_SCENE_SHA256],
		[FACTORY_PATH, EXPECTED_FACTORY_SHA256],
		[UV_HELPER_PATH, EXPECTED_UV_HELPER_SHA256],
		[MATERIAL_PATH, EXPECTED_MATERIAL_SHA256],
	]:
		if not str(pair[1]).is_empty() and FileAccess.get_sha256(str(pair[0])) != str(pair[1]):
			return false
	return true


func _config_contract_matches(config: Dictionary) -> bool:
	var eligible := config.get("eligible_region", {}) as Dictionary
	var topology := config.get("render_topology", {}) as Dictionary
	var material := config.get("material_contract", {}) as Dictionary
	var generated := config.get("generated_albedo", {}) as Dictionary
	var source := generated.get("project_asset", {}) as Dictionary
	var sealed := config.get("sealed_b201_byte_guard", {}) as Dictionary
	var checks := {
		"schema": str(config.get("schema_version", "")) == "ti.d1-b225-standalone-cladding-repair/1",
		"source": str(config.get("source_key", "")) == "w95934119",
		"receiver": str(config.get("receiver_key_eligibility_only", "")) == "building:w95934119:wall",
		"review": str(config.get("review_status", "")) == "pending_independent_bar_raiser_re_review_not_self_accepted",
		"runtime": not bool(config.get("runtime_attachment", true)) and not bool(config.get("exact_receiver_layout", true)) and int(config.get("live_placement_count", -1)) == 0,
		"generated": bool(config.get("generated_or_external_texture_assets", false)),
		"edge": _int_array(eligible.get("source_edge_indices", []) as Array) == [3],
		"runs": _int_array(eligible.get("ordered_run_indices", []) as Array) == RUN_INDICES,
		"lengths": _numeric_array_approx(eligible.get("ordered_run_lengths_m", []) as Array, RUN_LENGTHS_M, 0.000000001),
		"total": absf(float(eligible.get("exact_generated_chain_length_m", 0.0)) - WIDTH_M) <= 0.000000001,
		"phase": "without per-run reset" in str(eligible.get("u_phase_rule", "")),
		"topology": int(topology.get("render_geometry_batches", 0)) == 3 and int(topology.get("box_instance_count", 0)) == 90 and int(topology.get("triangle_count", 0)) == 1088,
		"removed": int((topology.get("delta_from_rejected_standalone", {}) as Dictionary).get("full_width_dark_course_boxes", 0)) == -14,
		"zero_ownership": int(topology.get("collision_nodes", -1)) == 0 and int(topology.get("navigation_nodes", -1)) == 0 and int(topology.get("spray_nodes", -1)) == 0,
		"material": bool(material.get("albedo_only", false)) and is_equal_approx(float(material.get("scalar_roughness", 0.0)), 0.88) and int(material.get("fabricated_pbr_maps", -1)) == 0,
		"dimensions": _int_array(source.get("dimensions_px", []) as Array) == [1254, 1254],
		"texture_hash": str(source.get("sha256", "")) == EXPECTED_TEXTURE_SHA256,
		"reference_boundary": (generated.get("reference_images_or_source_pixels", []) as Array).is_empty(),
		"model_nonclaim": "not surfaced" in str(generated.get("model_mode", "")),
		"rejected_initial": str((generated.get("initial_output", {}) as Dictionary).get("disposition", "")).begins_with("rejected"),
		"b201_guard": sealed.size() == 7,
		"integration": str((config.get("live_integration_seam", {}) as Dictionary).get("status", "")).begins_with("blocked_pending_independent"),
	}
	for key_value: Variant in checks:
		if not bool(checks[key_value]):
			push_error("B225 config sub-contract failed: %s" % str(key_value))
			return false
	return true


func _material_contract_matches() -> bool:
	var material := load(MATERIAL_PATH) as StandardMaterial3D
	if material == null \
	or material.albedo_texture == null \
	or material.albedo_texture.resource_path != TEXTURE_PATH \
	or not material.albedo_color.is_equal_approx(Color(0.76, 0.755, 0.72, 1.0)) \
	or not is_zero_approx(material.metallic) \
	or not is_equal_approx(material.roughness, 0.88) \
	or material.normal_texture != null \
	or material.roughness_texture != null \
	or material.metallic_texture != null \
	or material.heightmap_enabled \
	or material.uv1_scale != Vector3(0.125, 0.28735632, 1.0) \
	or not material.texture_repeat \
	or material.texture_filter != BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC:
		return false
	var image := Image.new()
	if image.load(ProjectSettings.globalize_path(TEXTURE_PATH)) != OK:
		return false
	return not image.is_empty() \
		and image.get_size() == Vector2i(1254, 1254) \
		and image.get_format() == Image.FORMAT_RGB8 \
		and "mipmaps/generate=true" in FileAccess.get_file_as_string(IMPORT_PATH)


func _geometry_contract_matches(instance: Node3D, prototype: Node3D) -> bool:
	if bool(instance.get_meta("runtime_attachment", true)) \
	or bool(instance.get_meta("exact_receiver_layout", true)) \
	or int(prototype.get_meta("mesh_instance_count", 0)) != 3 \
	or int(prototype.get_meta("batch_count", 0)) != 3 \
	or int(prototype.get_meta("run_quad_count", 0)) != 4 \
	or int(prototype.get_meta("box_instance_count", 0)) != 90 \
	or int(prototype.get_meta("triangle_count", 0)) != 1088 \
	or (not EXPECTED_GEOMETRY_SIGNATURE.is_empty() and str(prototype.get_meta("geometry_signature", "")) != EXPECTED_GEOMETRY_SIGNATURE) \
	or (not EXPECTED_UV_PLAN_SIGNATURE.is_empty() and str(prototype.get_meta("uv_plan_signature", "")) != EXPECTED_UV_PLAN_SIGNATURE):
		return false
	var field := prototype.get_node_or_null("RenderOnlyMeshes/Field_CumulativeMetreCladding_Runs10_13") as MeshInstance3D
	if field == null or not field.mesh is ArrayMesh or field.mesh.get_surface_count() != 1 or field.layers != 2:
		return false
	var arrays := field.mesh.surface_get_arrays(0) as Array
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var uvs := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	if vertices.size() != 16 or normals.size() != 16 or uvs.size() != 16 or indices.size() != 24:
		return false
	for run_offset in 4:
		var base := run_offset * 4
		if not uvs[base].is_equal_approx(Vector2(U_STARTS_M[run_offset], 0.0)) \
		or not uvs[base + 1].is_equal_approx(Vector2(U_ENDS_M[run_offset], 0.0)) \
		or not uvs[base + 2].is_equal_approx(Vector2(U_ENDS_M[run_offset], 5.0)) \
		or not uvs[base + 3].is_equal_approx(Vector2(U_STARTS_M[run_offset], 5.0)):
			return false
		if run_offset > 0 and not is_equal_approx(uvs[base].x, uvs[base - 3].x):
			return false
	var expected_indices := PackedInt32Array()
	for run_offset in 4:
		var base := run_offset * 4
		expected_indices.append_array(PackedInt32Array([base, base + 2, base + 1, base, base + 3, base + 2]))
	return indices == expected_indices \
		and _count_type(instance, MeshInstance3D) == 1 \
		and _count_type(instance, MultiMeshInstance3D) == 2 \
		and _count_type(instance, CollisionObject3D) == 0 \
		and _count_type(instance, CollisionShape3D) == 0 \
		and _count_type(instance, NavigationRegion3D) == 0 \
		and _count_type(instance, Decal) == 0


func _clerestory_is_byte_for_byte_equivalent(candidate: Node3D, control: Node3D) -> bool:
	for material_key: String in ["shared_dark_glass", "shared_pale_frame"]:
		var candidate_batch := candidate.get_node_or_null("RenderOnlyMeshes/Batch_%s" % material_key) as MultiMeshInstance3D
		var control_batch := control.get_node_or_null("RenderOnlyBatches/Batch_%s" % material_key) as MultiMeshInstance3D
		if candidate_batch == null or control_batch == null \
		or candidate_batch.multimesh.instance_count != control_batch.multimesh.instance_count:
			return false
		for index in candidate_batch.multimesh.instance_count:
			if not candidate_batch.multimesh.get_instance_transform(index).is_equal_approx(control_batch.multimesh.get_instance_transform(index)):
				return false
	return true


func _source_isolation_matches() -> bool:
	var source := FileAccess.get_file_as_string(FACTORY_PATH)
	for forbidden: String in ["shared_deep_reveal", "HorizontalCourse", "b225_aged_horizontal_cladding.tres", "RandomNumberGenerator", "randf(", "randi(", "FastNoise", "NoiseTexture", "ShaderMaterial", "normal_texture", "roughness_texture", "CollisionShape3D.new", "StaticBody3D.new", "NavigationRegion3D.new", "Decal.new"]:
		if forbidden in source:
			return false
	var builder_source := FileAccess.get_file_as_string(WORLD_BUILDER_PATH)
	var adapter_source := FileAccess.get_file_as_string(LIVE_ADAPTER_PATH)
	var candidate_source := FileAccess.get_file_as_string(CANDIDATE_SEAM_PATH)
	var catalog_source := FileAccess.get_file_as_string(CATALOG_PATH)
	var registry_source := FileAccess.get_file_as_string(RUNTIME_REGISTRY_PATH)
	var loader_source := FileAccess.get_file_as_string(RUNTIME_LOADER_PATH)
	var trials_source := FileAccess.get_file_as_string(ACCEPTED_TRIALS_PATH)
	for active_source: String in [builder_source, adapter_source, catalog_source, registry_source, loader_source, trials_source, candidate_source]:
		for standalone_token: String in ["d1_b225_standalone_cladding_repair_v1", "d1_b225_nnw_long_cladding_repair_v1", "d1_b225_cumulative_meter_uv_v1"]:
			if standalone_token in active_source:
				return false
	if builder_source.count('const D1_B225_LIVE_ATTACHMENT := preload("%s")' % LIVE_ADAPTER_PATH) != 1 \
	or builder_source.count("D1_B225_LIVE_ATTACHMENT.validate_chunk_records(chunk)") != 1 \
	or builder_source.count("D1_B225_LIVE_ATTACHMENT.prepare(record)") != 1 \
	or builder_source.count("D1_B225_LIVE_ATTACHMENT.host_uvs(record, b225_prepared)") != 1 \
	or builder_source.count("D1_B225_LIVE_ATTACHMENT.partition_host(record, indices, placeholder_material, b225_prepared)") != 1 \
	or builder_source.count("D1_B225_LIVE_ATTACHMENT.build_prepared(record, b225_prepared)") != 1 \
	or candidate_source.count('const ADAPTER := preload("%s")' % LIVE_ADAPTER_PATH) != 1 \
	or LIVE_CONFIG_PATH not in adapter_source \
	or "d1_b225_repair_v1" not in adapter_source \
	or "b225_aged_painted_horizontal_cladding_albedo_v1" not in adapter_source:
		return false
	var catalog_value: Variant = JSON.parse_string(catalog_source)
	var registry_value: Variant = JSON.parse_string(registry_source)
	if not (catalog_value is Dictionary) or not (registry_value is Dictionary) \
	or not _catalog_production_route_matches(catalog_value as Dictionary) \
	or not _runtime_production_route_matches(registry_value as Dictionary):
		return false
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	return CANDIDATE_SEAM_PATH.trim_prefix("res://") in preset \
		and "d1_b225_repair_v1" not in preset


func _catalog_production_route_matches(catalog: Dictionary) -> bool:
	var matches := (catalog.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool:
		return value is Dictionary and str((value as Dictionary).get("adapter_id", "")) == LIVE_ADAPTER_ID
	)
	if matches.size() != 1:
		return false
	var adapter := matches[0] as Dictionary
	var actual_assets: Array[String] = []
	for value: Variant in adapter.get("runtime_asset_paths", []) as Array:
		actual_assets.append(str(value))
	actual_assets.sort()
	var expected_assets: Array[String] = [
		MATERIAL_PATH.trim_prefix("res://"),
		TEXTURE_PATH.trim_prefix("res://"),
		"game/resources/materials/world/d1_current/shared_dark_glass.tres",
		"game/resources/materials/world/d1_current/shared_pale_frame.tres",
	]
	expected_assets.sort()
	return str(catalog.get("schema_version", "")) == "ti.facade-recognition-catalog/8" \
		and str(adapter.get("runtime_adapter_path", "")) == LIVE_ADAPTER_PATH.trim_prefix("res://") \
		and str(adapter.get("runtime_config_path", "")) == LIVE_CONFIG_PATH.trim_prefix("res://") \
		and str(adapter.get("runtime_dispatch_path", "")) == WORLD_BUILDER_PATH.trim_prefix("res://") \
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted" \
		and actual_assets == expected_assets


func _runtime_production_route_matches(registry: Dictionary) -> bool:
	var matches := (registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool:
		return value is Dictionary and str((value as Dictionary).get("adapter_id", "")) == LIVE_ADAPTER_ID
	)
	if matches.size() != 1:
		return false
	var adapter := matches[0] as Dictionary
	var actual_assets: Array[String] = []
	for value: Variant in adapter.get("runtime_assets", []) as Array:
		if not (value is Dictionary):
			return false
		actual_assets.append(str((value as Dictionary).get("path", "")))
	actual_assets.sort()
	var expected_assets: Array[String] = [
		LIVE_CONFIG_PATH,
		LIVE_ADAPTER_PATH,
		MATERIAL_PATH,
		TEXTURE_PATH,
		"res://game/resources/materials/world/d1_current/shared_dark_glass.tres",
		"res://game/resources/materials/world/d1_current/shared_pale_frame.tres",
	]
	expected_assets.sort()
	return str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/8" \
		and str(adapter.get("runtime_content_mode", "")) == "active_d1_b225_host_partition_attachment" \
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content" \
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted" \
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty() \
		and actual_assets == expected_assets


func _numeric_array_approx(actual: Array, expected: Array, tolerance: float) -> bool:
	if actual.size() != expected.size():
		return false
	for index in actual.size():
		if absf(float(actual[index]) - float(expected[index])) > tolerance:
			return false
	return true


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _count_type(node: Node, type: Variant) -> int:
	var count := 1 if is_instance_of(node, type) else 0
	for child in node.get_children():
		count += _count_type(child, type)
	return count


func _load_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		_fail("Invalid JSON: %s" % path)
		return {}
	return parsed as Dictionary


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	_failed = true
	push_error(message)


func _finish() -> void:
	quit(1 if _failed else 0)
