extends SceneTree

const ADAPTER := preload("res://game/scripts/world/facades/d1_b225_live_attachment.gd")
const BUILDER := preload("res://game/scripts/world/world_chunk_builder.gd")
const CANDIDATE_SEAM := preload("res://game/tests/support/d1_b225_prepromotion_candidate_seam.gd")
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_-1.json"
const CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b225_live_attachment.json"
const ADAPTER_PATH := "res://game/scripts/world/facades/d1_b225_live_attachment.gd"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const CANDIDATE_SEAM_PATH := "res://game/tests/support/d1_b225_prepromotion_candidate_seam.gd"
const METER_UV_PATH := "res://game/scripts/world/facades/facade_meter_uv_adapter.gd"
const STANDALONE_SCENE_PATH := "res://game/scenes/world/facades/d1_current/repairs/d1_b225_standalone_cladding_repair_v1.tscn"
const STANDALONE_FACTORY_PATH := "res://game/scripts/world/facades/d1_b225_standalone_cladding_repair_v1.gd"
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const SOURCE_PACKET_PATH := "res://discovery/facades/d1_reference_packets/w95934119_building_225.md"
const SOURCE_RECEIPT_PATH := "res://discovery/facades/PRECOMMIT_PACKAGE_SANITIZATION_SOURCE_PROVENANCE.json"
const REPAIR_CONFIG_PATH := "res://game/resources/facades/d1_current/repairs/d1_b225_nnw_long_cladding_repair_v1.json"
const REPAIR_CAPTURE_MANIFEST_PATH := "res://evidence/first-playable/d1-b225-standalone-cladding-repair-v1-2026-09-04/capture-manifest.json"
const STANDALONE_REVIEW_PATH := "res://evidence/first-playable/d1-b225-standalone-cladding-repair-v1-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md"
const CLADDING_MATERIAL_PATH := "res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres"
const CLADDING_TEXTURE_PATH := "res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png"
const DARK_GLASS_MATERIAL_PATH := "res://game/resources/materials/world/d1_current/shared_dark_glass.tres"
const PALE_FRAME_MATERIAL_PATH := "res://game/resources/materials/world/d1_current/shared_pale_frame.tres"
const EXPECTED_CONFIG_SHA256 := "76d66f0c3a5d3ebc99c78208f28df8766a19186fe38bff7118e597a99c55c9ac"
const EXPECTED_ADAPTER_SHA256 := "aed52048bc562f2f07c248bd5f571376611c3870fda1704cbd67de163d4d42ce"
const EXPECTED_BUILDER_SHA256 := "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c"
const EXPECTED_CANDIDATE_SEAM_SHA256 := "1f86f10df49500821adf03f4c7b90b5c38cd06a2e6ac97c9c2f1a7169f7e8295"
const EXPECTED_METER_UV_SHA256 := "47e710b9ea7c5de5122430199e4105cbba5f672d22f59832f13b8004f16c5a1d"
const EXPECTED_REGISTRY_SHA256 := "9c46c1a8c809aa9ded82008d35e9c1b257070e9c61f6d6e41f5650ca7b1c3f27"
const EXPECTED_CATALOG_SHA256 := "a4d9dd474acb09a211f7e0e00d66aeaf7a669927880dd011e24e2f51d13bdd7d"
const EXPECTED_SOURCE_PACKET_SHA256 := "ee3e0cb8a7f3bb29e4ecbc0be688d57268cccc895c33c448c64e2506b2de4fa8"
const EXPECTED_SOURCE_RECEIPT_SHA256 := "269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333"
const EXPECTED_REPAIR_CONFIG_SHA256 := "7c1c2d508f78236590c6d413604be60b3a5c48865878e69d294177d05c48d166"
const EXPECTED_REPAIR_CAPTURE_MANIFEST_SHA256 := "22cbe9edec6e33ccbfcc2c71d719c2c1bc646358fb46242be802affe371b2ec5"
const EXPECTED_STANDALONE_REVIEW_SHA256 := "b35df2e8c39e854b3553d07d369cdd72a76b1a37446ffb7bbe9a5941f8a69015"
const EXPECTED_STANDALONE_SCENE_SHA256 := "008669d9e0c2e04801ee8d720976e72e2041c82188c7fd14fe075ad48cb69914"
const EXPECTED_STANDALONE_FACTORY_SHA256 := "8c06afec4835441ec386251e700cc7ba91b8fea9fe070549561e401aa530d58e"
const EXPECTED_CLADDING_MATERIAL_SHA256 := "7fa7f3165dee560c48f5a092f317900b87b0876f27bb6a0e937b9c406a8d4ea1"
const EXPECTED_CLADDING_TEXTURE_SHA256 := "63e755e9fe5a5dcfb662b4265f1e769fc1b371987b55579b1ca4ffb63015015b"
const EXPECTED_DARK_GLASS_MATERIAL_SHA256 := "ad8931db8954fd5ebc8fdd809f70afb279dd74a36e53e1d9ca907c44409f10d3"
const EXPECTED_PALE_FRAME_MATERIAL_SHA256 := "9a2de298ff545cf80c5da0ed0aa37d9d4ebbf10fec8eb78810af7e4d012d1436"
const EXPECTED_BATCH_COUNTS := {"shared_dark_glass": 10, "shared_pale_frame": 80}
const EXPECTED_DEFAULT_WORLD_TOPOLOGY := {"rows": 735, "meshes": 950, "surfaces": 964, "triangles": 66636, "bodies": 466, "shapes": 466}
const EXPECTED_CANDIDATE_WORLD_TOPOLOGY := {"rows": 735, "meshes": 952, "surfaces": 967, "triangles": 67716, "bodies": 466, "shapes": 466}
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256, "B225 live config bytes drifted.")
	_require(FileAccess.get_sha256(ADAPTER_PATH) == EXPECTED_ADAPTER_SHA256, "B225 live adapter bytes drifted.")
	_require(FileAccess.get_sha256(BUILDER_PATH) == EXPECTED_BUILDER_SHA256, "Canonical world builder drifted from the exact accepted 7/213 bytes.")
	_require(FileAccess.get_sha256(CANDIDATE_SEAM_PATH) == EXPECTED_CANDIDATE_SEAM_SHA256, "B225 prepromotion candidate seam bytes drifted.")
	_require(FileAccess.get_sha256(METER_UV_PATH) == EXPECTED_METER_UV_SHA256, "FacadeMeterUvAdapter bytes drifted.")
	_require(_package_boundary_matches(), "B225 candidate closure leaked into a canonical entrypoint, generic authority, user override, or forbidden source/evidence/private path.")
	_require(_future_runtime_asset_closure_matches(), "B225 candidate did not pin exactly the six intended future promoted-runtime assets.")
	_require(_current_authority_matches(), "B225 source packet, sealed capture-time 6/213 provenance, or exact-current 7/213 authority drifted.")
	var chunk := _load_json(CHUNK_PATH)
	var record := _record_for(chunk, ADAPTER.RECEIVER_KEY)
	var roof := _record_for(chunk, ADAPTER.ROOF_KEY)
	_require(not record.is_empty() and not roof.is_empty(), "Exact B225 wall/roof pair did not resolve.")
	_require(bool(ADAPTER.validate_chunk_records(chunk).get("ok", false)), "Exact B225 chunk preflight failed.")
	_require(ADAPTER.canonical_record_signature(record) == ADAPTER.EXPECTED_CANONICAL_RECORD_SHA256 and ADAPTER.record_signature(record) == ADAPTER.EXPECTED_RUNTIME_RECORD_SHA256, "Exact B225 wall authority signatures drifted.")
	_require(ADAPTER.canonical_record_signature(roof) == ADAPTER.EXPECTED_CANONICAL_ROOF_RECORD_SHA256 and ADAPTER.record_signature(roof) == ADAPTER.EXPECTED_RUNTIME_ROOF_RECORD_SHA256, "Protected B225 roof authority signatures drifted.")
	var builder := BUILDER.new()
	var prepared := ADAPTER.prepare(record)
	var authored := ADAPTER.authored_transform_spec(record, prepared)
	_require(bool(prepared.get("ok", false)) and bool(authored.get("ok", false)), "B225 deterministic prepared/authored state failed.")
	var standalone_scene := load(STANDALONE_SCENE_PATH) as PackedScene
	var standalone := standalone_scene.instantiate() as Node3D if standalone_scene != null else null
	if standalone != null:
		root.add_child(standalone)
		await process_frame
	_require(standalone != null and _reviewed_standalone_translation_matches(standalone, authored, DisplayServer.get_name() != "headless"), "B225 live clerestory was not an exact inward translation of the sealed reviewed standalone.")
	var ordinary_result := builder._build_record(record, false)
	if not _require(bool(ordinary_result.get("ok", false)), "B225 ordinary exact receiver failed canonical construction: %s" % str(ordinary_result.get("message", ordinary_result.get("code", "unknown")))):
		_finish()
		return
	var ordinary_node := ordinary_result.get("node") as Node3D
	root.add_child(ordinary_node)
	await process_frame
	_require(_ordinary_host_matches(ordinary_result, record), "Canonical builder did not leave B225 as one untouched generic host before explicit candidate activation.")
	_require(_mutation_matrix_fails_closed(chunk, record, ordinary_result), "B225 adversarial record/chunk/prepared/partition mutation escaped fail-closed handling.")
	ordinary_node.queue_free()
	if standalone != null:
		standalone.queue_free()
	await process_frame
	_require(await _whole_world_matches(record, roof, authored), "B225 default-off/candidate-on whole-world topology, atomicity, roof parity, or sole ownership contract drifted.")
	if not _failed:
		print("PASS: ordinary/current 7/213 remains byte-exact and default-off at 735/950/964/66,636/466/466 with one untouched generic B225 host; one explicit test-only post-construction candidate transition atomically yields 735/952/967/67,716/466/466, preserves the sole 28-triangle collision/spray host and roof, partitions only runs 10..13, attaches the exact reviewed 90-box clerestory in two render batches, rejects malformed/wrong/duplicate activation, and grants no recognition credit or promotion")
	_finish()


func _host_and_attachment_match(result: Dictionary, record: Dictionary, authored: Dictionary, verify_realized_transforms: bool) -> bool:
	var node := result.node as Node3D
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var attachment := node.get_node_or_null("D1B225PrepromotionCandidateAttachment") as Node3D
	var partition_ok := mesh != null and _partition_indices_match(mesh, record)
	var uvs_ok := mesh != null and _host_uvs_match(mesh, record)
	var collision_ok := shape != null and _collision_faces_match(shape.get_faces(), record)
	if node.get_child_count() != 3 or mesh == null or body == null or shape == null or attachment == null \
	or not node.has_meta(CANDIDATE_SEAM.APPLIED_META) \
	or not node.has_meta(CANDIDATE_SEAM.HOST_PARTITION_META) \
	or int(result.mesh_instances) != 3 or int(result.surfaces) != 4 or int(result.triangles) != 1108 \
	or mesh.get_surface_count() != 2 \
	or mesh.surface_get_name(0) != "generated_record_protected_runs_0_9" \
	or mesh.surface_get_name(1) != "d1_b225_nnw_runs_10_13" \
	or mesh.surface_get_material(0).resource_name != "building_wall" \
	or not _live_cladding_material_matches(mesh.surface_get_material(1)) \
	or _surface_triangles(mesh, 0) != 20 or _surface_triangles(mesh, 1) != 8 \
	or not partition_ok \
	or not uvs_ok \
	or body.collision_layer != (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) or body.collision_mask != 0 \
	or not body.is_in_group("spray_receiver_wall") \
	or str(body.get_meta("derived_object_key", "")) != ADAPTER.RECEIVER_KEY \
	or body.get_meta("source_keys", []) != [ADAPTER.SOURCE_KEY] \
	or not collision_ok \
	or str(attachment.get_meta("decorative_geometry_signature", "")) != ADAPTER.EXPECTED_DECORATIVE_GEOMETRY_SIGNATURE \
	or str(attachment.get_meta("standalone_geometry_signature", "")) != ADAPTER.EXPECTED_STANDALONE_GEOMETRY_SIGNATURE \
	or str(attachment.get_meta("meter_plan_signature", "")) != ADAPTER.EXPECTED_METER_PLAN_SIGNATURE \
	or bool(attachment.get_meta("reference_recognizable", true)) \
	or _count_type(attachment, CollisionObject3D) != 0 \
	or _count_type(attachment, CollisionShape3D) != 0 \
	or _count_type(attachment, NavigationRegion3D) != 0 \
	or _count_type(attachment, Decal) != 0:
		print("B225_FOCUSED_DIAGNOSTIC partition=", partition_ok, " uvs=", uvs_ok, " collision=", collision_ok, " child_count=", node.get_child_count(), " result=", {"m": result.mesh_instances, "s": result.surfaces, "t": result.triangles})
		return false
	var topology := ADAPTER.render_topology(attachment)
	if topology != {"mesh_instances": 2, "surfaces": 2, "triangles": 1080}:
		print("B225_FOCUSED_DIAGNOSTIC topology=", topology)
		return false
	var render_root := attachment.get_node_or_null("RenderOnlyBatches") as Node3D
	if render_root == null or render_root.get_child_count() != 2:
		print("B225_FOCUSED_DIAGNOSTIC render_root=", render_root, " children=", -1 if render_root == null else render_root.get_child_count())
		return false
	var counts := {}
	for child: Node in render_root.get_children():
		var instance := child as MultiMeshInstance3D
		if instance == null or instance.multimesh == null or not (instance.multimesh.mesh is BoxMesh) \
		or instance.layers != (1 << 1):
			print("B225_FOCUSED_DIAGNOSTIC bad_batch=", child)
			return false
		var key := str(instance.get_meta("material_key", ""))
		var box := instance.multimesh.mesh as BoxMesh
		var material := box.material as StandardMaterial3D
		var expected_material := ADAPTER.MATERIAL_SPECS.get(key, {}) as Dictionary
		if material == null or expected_material.is_empty() \
		or material.resource_path != str(expected_material.get("path", "")) \
		or material.resource_name != str(expected_material.get("resource_name", "")):
			print("B225_FOCUSED_DIAGNOSTIC material=", key, " path=", "" if material == null else material.resource_path)
			return false
		counts[key] = instance.multimesh.instance_count
		if verify_realized_transforms:
			var expected_transforms := (authored.get("boxes", {}) as Dictionary).get(key, []) as Array
			for index in instance.multimesh.instance_count:
				var transform := instance.multimesh.get_instance_transform(index)
				if not _transform_matches(transform, expected_transforms[index] as Transform3D):
					print("B225_FOCUSED_DIAGNOSTIC realized_transform=", key, " index=", index)
					return false
	var grounding_ok := _authored_transforms_match(authored, record)
	if counts != EXPECTED_BATCH_COUNTS or not grounding_ok:
		print("B225_FOCUSED_DIAGNOSTIC counts=", counts, " expected=", EXPECTED_BATCH_COUNTS, " grounding=", grounding_ok)
	return counts == EXPECTED_BATCH_COUNTS and grounding_ok


func _live_cladding_material_matches(value: Material) -> bool:
	var material := value as StandardMaterial3D
	return material != null \
		and material.resource_path == CLADDING_MATERIAL_PATH \
		and material.resource_name == "d1_b225_aged_painted_horizontal_cladding_albedo_v1" \
		and material.albedo_color.is_equal_approx(Color(0.76, 0.755, 0.72, 1.0)) \
		and is_equal_approx(material.metallic, 0.0) \
		and is_equal_approx(material.roughness, 0.88) \
		and material.albedo_texture != null \
		and material.albedo_texture.resource_path == CLADDING_TEXTURE_PATH \
		and FileAccess.get_sha256(CLADDING_TEXTURE_PATH) == EXPECTED_CLADDING_TEXTURE_SHA256 \
		and material.uv1_scale.is_equal_approx(Vector3(0.125, 0.28735632, 1.0)) \
		and material.texture_filter == BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC \
		and material.get_flag(BaseMaterial3D.FLAG_USE_TEXTURE_REPEAT) \
		and material.normal_texture == null \
		and material.roughness_texture == null \
		and material.metallic_texture == null


func _ordinary_host_matches(result: Dictionary, record: Dictionary) -> bool:
	var node := result.get("node") as Node3D
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D if node != null else null
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D if node != null else null
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D if node != null else null
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if node == null or node.get_child_count() != 2 \
	or node.has_meta(CANDIDATE_SEAM.APPLIED_META) or node.has_meta(CANDIDATE_SEAM.HOST_PARTITION_META) \
	or node.get_node_or_null("D1B225PrepromotionCandidateAttachment") != null \
	or node.get_node_or_null("D1B225LiveAttachment") != null \
	or int(result.get("mesh_instances", -1)) != 1 \
	or int(result.get("surfaces", -1)) != 1 \
	or int(result.get("triangles", -1)) != 28 \
	or mesh == null or mesh.get_surface_count() != 1 \
	or mesh.surface_get_name(0) != "generated_record" \
	or mesh.surface_get_material(0) == null or mesh.surface_get_material(0).resource_name != "building_wall" \
	or _surface_triangles(mesh, 0) != 28 \
	or body == null or shape == null \
	or body.collision_layer != (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) or body.collision_mask != 0 \
	or not body.is_in_group("spray_receiver_wall") \
	or str(body.get_meta("derived_object_key", "")) != ADAPTER.RECEIVER_KEY \
	or body.get_meta("source_keys", []) != [ADAPTER.SOURCE_KEY] \
	or not _collision_faces_match(shape.get_faces(), record):
		return false
	var arrays := mesh.surface_get_arrays(0)
	var actual_uvs := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	var source_uvs := record.get("uvs", []) as Array
	if actual_uvs.size() * 2 != source_uvs.size():
		return false
	for index in actual_uvs.size():
		var scalar := index * 2
		if not actual_uvs[index].is_equal_approx(Vector2(float(source_uvs[scalar]), float(source_uvs[scalar + 1]))):
			return false
	return true


func _reviewed_standalone_translation_matches(standalone: Node3D, authored: Dictionary, verify_realized_transforms: bool) -> bool:
	var prototype := standalone.get_node_or_null("B225_w95934119_CladdingRepairV1") as Node3D
	if prototype == null \
	or str(prototype.get_meta("geometry_signature", "")) != ADAPTER.EXPECTED_STANDALONE_GEOMETRY_SIGNATURE \
	or int(prototype.get_meta("box_instance_count", -1)) != 90 \
	or int(prototype.get_meta("triangle_count", -1)) != 1088:
		return false
	for material_key: String in ["shared_dark_glass", "shared_pale_frame"]:
		var batch := prototype.get_node_or_null("RenderOnlyMeshes/Batch_%s" % material_key) as MultiMeshInstance3D
		var expected := (authored.get("boxes", {}) as Dictionary).get(material_key, []) as Array
		if batch == null or batch.multimesh == null or batch.multimesh.instance_count != expected.size():
			return false
		if not verify_realized_transforms:
			continue
		for index in expected.size():
			var reviewed := batch.multimesh.get_instance_transform(index)
			var translated := expected[index] as Transform3D
			if not reviewed.basis.x.is_equal_approx(translated.basis.x) \
			or not reviewed.basis.y.is_equal_approx(translated.basis.y) \
			or not reviewed.basis.z.is_equal_approx(translated.basis.z) \
			or absf(reviewed.origin.x - translated.origin.x) > 0.000001 \
			or absf(reviewed.origin.y - translated.origin.y) > 0.000001 \
			or absf(reviewed.origin.z - translated.origin.z - ADAPTER.STANDALONE_FIELD_FRONT_OFFSET_M) > 0.000001:
				return false
	return true


func _partition_indices_match(mesh: ArrayMesh, record: Dictionary) -> bool:
	var expected_public := PackedInt32Array()
	var expected_protected := PackedInt32Array()
	var source := record.get("indices", []) as Array
	for offset in range(0, source.size(), 3):
		var target := expected_public if int(offset / 6) in ADAPTER.RUN_INDICES else expected_protected
		target.append(int(source[offset]))
		target.append(int(source[offset + 2]))
		target.append(int(source[offset + 1]))
	# Packed arrays are copy-on-write; rebuild explicitly if the conditional
	# target detached in this runtime.
	if expected_public.size() != 24 or expected_protected.size() != 60:
		expected_public.clear()
		expected_protected.clear()
		for offset in range(0, source.size(), 3):
			if int(offset / 6) in ADAPTER.RUN_INDICES:
				expected_public.append_array(PackedInt32Array([int(source[offset]), int(source[offset + 2]), int(source[offset + 1])]))
			else:
				expected_protected.append_array(PackedInt32Array([int(source[offset]), int(source[offset + 2]), int(source[offset + 1])]))
	var protected_actual := (mesh.surface_get_arrays(0) as Array)[Mesh.ARRAY_INDEX] as PackedInt32Array
	var public_actual := (mesh.surface_get_arrays(1) as Array)[Mesh.ARRAY_INDEX] as PackedInt32Array
	return protected_actual == expected_protected and public_actual == expected_public \
		and _index_set_is_disjoint_complete(public_actual, protected_actual, source.size())


func _index_set_is_disjoint_complete(public_indices: PackedInt32Array, protected_indices: PackedInt32Array, expected_count: int) -> bool:
	# Triangle positions, rather than vertex IDs, define the run partition.
	return public_indices.size() + protected_indices.size() == expected_count \
		and public_indices.size() == 24 and protected_indices.size() == 60


func _host_uvs_match(mesh: ArrayMesh, record: Dictionary) -> bool:
	var public_uvs := (mesh.surface_get_arrays(1) as Array)[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	var protected_uvs := (mesh.surface_get_arrays(0) as Array)[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	var prepared := ADAPTER.prepare(record)
	if not bool(prepared.get("ok", false)):
		return false
	var expected := ADAPTER.host_uvs(record, prepared)
	if public_uvs.size() != expected.size() or protected_uvs.size() != expected.size():
		return false
	for index in expected.size():
		if not public_uvs[index].is_equal_approx(expected[index]) or not protected_uvs[index].is_equal_approx(expected[index]):
			return false
	var source_uvs := record.get("uvs", []) as Array
	for run_index in range(0, 10):
		for corner in 4:
			var uv_index := run_index * 4 + corner
			var scalar := uv_index * 2
			if not expected[uv_index].is_equal_approx(Vector2(float(source_uvs[scalar]), float(source_uvs[scalar + 1]))):
				return false
	return is_equal_approx(expected[40].x, 0.0) \
		and absf(expected[54].x - float((prepared.chain as Dictionary).plan.total_u_m)) <= 0.00002


func _collision_faces_match(actual: PackedVector3Array, record: Dictionary) -> bool:
	var vertices := record.get("vertices", []) as Array
	var source := record.get("indices", []) as Array
	var expected := PackedVector3Array()
	for offset in range(0, source.size(), 3):
		for index_value: Variant in [int(source[offset]), int(source[offset + 2]), int(source[offset + 1])]:
			var base: int = int(index_value) * 3
			expected.append(Vector3(float(vertices[base]), float(vertices[base + 1]), float(vertices[base + 2])))
	if actual.size() != expected.size():
		return false
	for index in actual.size():
		if not actual[index].is_equal_approx(expected[index]):
			return false
	return true


func _authored_transforms_match(authored: Dictionary, record: Dictionary) -> bool:
	var prepared := ADAPTER.prepare(record)
	var chain := prepared.get("chain", {}) as Dictionary
	var boxes := authored.get("boxes", {}) as Dictionary
	if not bool(prepared.get("ok", false)) or not bool(chain.get("ok", false)) \
	or str(authored.get("signature", "")) != ADAPTER.EXPECTED_DECORATIVE_GEOMETRY_SIGNATURE \
	or int(authored.get("box_count", -1)) != 90 \
	or int(authored.get("triangles", -1)) != 1080 \
	or authored.get("batch_counts", {}) != EXPECTED_BATCH_COUNTS \
	or (boxes.get("shared_dark_glass", []) as Array).size() != 10 \
	or (boxes.get("shared_pale_frame", []) as Array).size() != 80:
		return false
	for key: Variant in boxes:
		for transform_value: Variant in boxes[key] as Array:
			var transform := transform_value as Transform3D
			if transform.origin.z - transform.basis.z.length() * 0.5 < 0.009 \
			or transform.origin.z + transform.basis.z.length() * 0.5 > 0.171 \
			or transform.origin.x - transform.basis.x.length() * 0.5 < -ADAPTER.CHAIN_LENGTH_M * 0.5 - 0.0001 \
			or transform.origin.x + transform.basis.x.length() * 0.5 > ADAPTER.CHAIN_LENGTH_M * 0.5 + 0.0001 \
			or transform.origin.y - transform.basis.y.length() * 0.5 < 3.41 \
			or transform.origin.y + transform.basis.y.length() * 0.5 > ADAPTER.HEIGHT_M + 0.0001:
				return false
	return true


func _transform_matches(actual: Transform3D, expected: Transform3D) -> bool:
	return actual.origin.is_equal_approx(expected.origin) \
		and actual.basis.x.is_equal_approx(expected.basis.x) \
		and actual.basis.y.is_equal_approx(expected.basis.y) \
		and actual.basis.z.is_equal_approx(expected.basis.z)


func _spray_ray_matches(node: Node3D, record: Dictionary) -> bool:
	return _run_ray_hits_host(node, record, 12, 4.2) \
		and _run_ray_hits_host(node, record, 0, 4.2)


func _run_ray_hits_host(node: Node3D, record: Dictionary, run_index: int, world_y: float) -> bool:
	var vertices := record.get("vertices", []) as Array
	var offset := run_index * 12
	var start := Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2]))
	var end := Vector3(float(vertices[offset + 3]), float(vertices[offset + 4]), float(vertices[offset + 5]))
	var point := (start + end) * 0.5
	point.y = world_y
	var tangent := Vector3(end.x - start.x, 0.0, end.z - start.z).normalized()
	var outward := tangent.cross(Vector3.UP).normalized()
	var query := PhysicsRayQueryParameters3D.create(point + outward * 2.0, point - outward * 2.0, PHYSICS_SPRAY_SURFACE)
	var hit := root.world_3d.direct_space_state.intersect_ray(query)
	var collider := hit.get("collider", null) as CollisionObject3D
	return collider == node.get_node("Collision") \
		and collider.is_in_group("spray_receiver_wall") \
		and str(collider.get_meta("derived_object_key", "")) == ADAPTER.RECEIVER_KEY \
		and (hit.get("normal", Vector3.ZERO) as Vector3).dot(outward) > 0.99 \
		and absf((hit.get("position", Vector3.ZERO) as Vector3).distance_to(point)) < 0.01


func _mutation_matrix_fails_closed(chunk: Dictionary, record: Dictionary, result: Dictionary) -> bool:
	var mutations := [
		["source_keys", ["w0"]],
		["material_key", "building_roof"],
		["receiver_kind", "none"],
		["exterior_foundation_segments", 13],
	]
	for mutation: Array in mutations:
		var changed := chunk.duplicate(true)
		(_record_for(changed, ADAPTER.RECEIVER_KEY))[mutation[0]] = mutation[1]
		if bool(ADAPTER.validate_chunk_records(changed).get("ok", false)):
			return false
	var vertex_changed := chunk.duplicate(true)
	var vertex_record := _record_for(vertex_changed, ADAPTER.RECEIVER_KEY)
	(vertex_record.vertices as Array)[0] = float((vertex_record.vertices as Array)[0]) + 0.01
	if bool(ADAPTER.validate_chunk_records(vertex_changed).get("ok", false)):
		return false
	var extra_changed := chunk.duplicate(true)
	(_record_for(extra_changed, ADAPTER.RECEIVER_KEY))["unexpected"] = true
	if bool(ADAPTER.validate_chunk_records(extra_changed).get("ok", false)):
		return false
	var key_changed := chunk.duplicate(true)
	(_record_for(key_changed, ADAPTER.RECEIVER_KEY))["object_key"] = "building:w95934119:wall-drift"
	if bool(ADAPTER.validate_chunk_records(key_changed).get("ok", false)):
		return false
	var missing_changed := chunk.duplicate(true)
	var missing_record := _record_for(missing_changed, ADAPTER.RECEIVER_KEY)
	missing_record["object_key"] = "building:w0:wall"
	missing_record["source_keys"] = ["w0"]
	if bool(ADAPTER.validate_chunk_records(missing_changed).get("ok", false)):
		return false
	var roof_changed := chunk.duplicate(true)
	(_record_for(roof_changed, ADAPTER.ROOF_KEY))["material_key"] = "building_wall"
	if bool(ADAPTER.validate_chunk_records(roof_changed).get("ok", false)):
		return false
	var wrong_chunk := chunk.duplicate(true)
	wrong_chunk["chunk_id"] = "x_0__z_0"
	if bool(ADAPTER.validate_chunk_records(wrong_chunk).get("ok", false)):
		return false
	var rogue_roof := (_record_for(chunk, ADAPTER.ROOF_KEY) as Dictionary).duplicate(true)
	rogue_roof["source_keys"] = ["w0"]
	var rogue_wrong_chunk := {"chunk_id": "x_0__z_0", "records": [rogue_roof]}
	if bool(ADAPTER.validate_chunk_records(rogue_wrong_chunk).get("ok", false)):
		return false
	var prepared := ADAPTER.prepare(record)
	var reversed := _reversed_indices(record)
	var host := (result.get("node") as Node3D).get_node("Mesh") as MeshInstance3D
	var placeholder := (host.mesh as ArrayMesh).surface_get_material(0)
	if not bool(ADAPTER.partition_host(record, reversed, placeholder, prepared).get("ok", false)):
		return false
	if bool(ADAPTER.partition_host(record, reversed, StandardMaterial3D.new(), prepared).get("ok", false)):
		return false
	var wrong_indices := reversed.duplicate()
	var swap := wrong_indices[0]
	wrong_indices[0] = wrong_indices[1]
	wrong_indices[1] = swap
	if bool(ADAPTER.partition_host(record, wrong_indices, placeholder, prepared).get("ok", false)):
		return false
	var forged := prepared.duplicate(true)
	forged["record_runtime_sha256"] = "0".repeat(64)
	if not _prepared_seams_reject(record, reversed, placeholder, forged):
		return false
	var reversed_basis := prepared.duplicate(true)
	var reversed_chain := (prepared.get("chain", {}) as Dictionary).duplicate(true)
	reversed_chain["outward"] = -(reversed_chain.get("outward", Vector3.ZERO) as Vector3)
	reversed_basis["chain"] = reversed_chain
	if not _prepared_seams_reject(record, reversed, placeholder, reversed_basis):
		return false
	var changed_run := prepared.duplicate(true)
	var run_chain := (prepared.get("chain", {}) as Dictionary).duplicate(true)
	var runs := (run_chain.get("runs", []) as Array).duplicate(true)
	var first_run := (runs[0] as Dictionary).duplicate(true)
	var first_start := (first_run.get("start_xyz_m", []) as Array).duplicate()
	first_start[0] = float(first_start[0]) + 0.01
	first_run["start_xyz_m"] = first_start
	runs[0] = first_run
	run_chain["runs"] = runs
	changed_run["chain"] = run_chain
	if not _prepared_seams_reject(record, reversed, placeholder, changed_run):
		return false
	var changed_plan := prepared.duplicate(true)
	var plan_chain := (prepared.get("chain", {}) as Dictionary).duplicate(true)
	var plan := (plan_chain.get("plan", {}) as Dictionary).duplicate(true)
	var entries := (plan.get("entries", []) as Array).duplicate(true)
	var first_entry := (entries[0] as Dictionary).duplicate(true)
	first_entry["u_end_m"] = float(first_entry.get("u_end_m", 0.0)) + 0.01
	entries[0] = first_entry
	plan["entries"] = entries
	plan_chain["plan"] = plan
	changed_plan["chain"] = plan_chain
	if not _prepared_seams_reject(record, reversed, placeholder, changed_plan):
		return false
	var changed_uv := prepared.duplicate(true)
	var uvs := (prepared.get("host_uvs", PackedVector2Array()) as PackedVector2Array).duplicate()
	uvs[40] += Vector2(0.25, 0.0)
	changed_uv["host_uvs"] = uvs
	if not _prepared_seams_reject(record, reversed, placeholder, changed_uv):
		return false
	var changed_material := prepared.duplicate(true)
	var materials := (prepared.get("materials", {}) as Dictionary).duplicate()
	materials["b225_cladding_v1"] = materials["shared_dark_glass"]
	changed_material["materials"] = materials
	return _prepared_seams_reject(record, reversed, placeholder, changed_material)


func _prepared_seams_reject(record: Dictionary, reversed: PackedInt32Array, placeholder: Material, prepared: Dictionary) -> bool:
	return ADAPTER.host_uvs(record, prepared).is_empty() \
		and not bool(ADAPTER.authored_transform_spec(record, prepared).get("ok", false)) \
		and not bool(ADAPTER.build_prepared(record, prepared).get("ok", false)) \
		and not bool(ADAPTER.partition_host(record, reversed, placeholder, prepared).get("ok", false))


func _current_authority_matches() -> bool:
	var expected_hashes := {
		REGISTRY_PATH: EXPECTED_REGISTRY_SHA256,
		CATALOG_PATH: EXPECTED_CATALOG_SHA256,
		SOURCE_PACKET_PATH: EXPECTED_SOURCE_PACKET_SHA256,
		SOURCE_RECEIPT_PATH: EXPECTED_SOURCE_RECEIPT_SHA256,
		REPAIR_CONFIG_PATH: EXPECTED_REPAIR_CONFIG_SHA256,
		REPAIR_CAPTURE_MANIFEST_PATH: EXPECTED_REPAIR_CAPTURE_MANIFEST_SHA256,
		STANDALONE_REVIEW_PATH: EXPECTED_STANDALONE_REVIEW_SHA256,
		STANDALONE_SCENE_PATH: EXPECTED_STANDALONE_SCENE_SHA256,
		STANDALONE_FACTORY_PATH: EXPECTED_STANDALONE_FACTORY_SHA256,
	}
	for path: String in expected_hashes:
		if FileAccess.get_sha256(path) != str(expected_hashes[path]):
			return false
	var config := _load_json(CONFIG_PATH)
	var receipts := config.get("source_receipts", {}) as Dictionary
	var runtime := config.get("runtime_contract", {}) as Dictionary
	if str(receipts.get("authoritative_packet_receipt_sha256", "")) != EXPECTED_SOURCE_RECEIPT_SHA256 \
	or str(receipts.get("authoritative_packet_sha256", "")) != EXPECTED_SOURCE_PACKET_SHA256 \
	or str(receipts.get("current_sanitized_standalone_repair_config_sha256", "")) != EXPECTED_REPAIR_CONFIG_SHA256 \
	or str(receipts.get("capture_time_standalone_repair_config_sha256", "")) != "89d34d33b48c93c0a6c90d46ff8120cd36c5f897ebe1fc9ea2ee2cd97a3db22c" \
	or str(receipts.get("standalone_repair_capture_manifest_sha256", "")) != EXPECTED_REPAIR_CAPTURE_MANIFEST_SHA256 \
	or str(receipts.get("standalone_repair_review_receipt_sha256", "")) != EXPECTED_STANDALONE_REVIEW_SHA256 \
	or str(runtime.get("integration_stage", "")) != "prepromotion_candidate_only" \
	or bool(runtime.get("canonical_entrypoint_reachable", true)) \
	or str(runtime.get("ordinary_default_runtime_mode", "")) != "generated_placeholder_wall_and_roof_at_exact_current_7_of_213" \
	or str(runtime.get("candidate_activation", "")) != "direct_test_only_post_world_construction_seam" \
	or bool(runtime.get("reference_recognizable", true)) \
	or bool(runtime.get("catalog_or_registry_promotion", true)) \
	or str(runtime.get("recognition_status", "")) != "pending_independent_live_visual_static_motion_and_package_review":
		return false
	var repair := _load_json(REPAIR_CONFIG_PATH)
	if str(repair.get("review_status", "")) != "pending_independent_bar_raiser_re_review_not_self_accepted" \
	or bool(repair.get("runtime_attachment", true)) \
	or bool(repair.get("exact_receiver_layout", true)) \
	or int(repair.get("live_placement_count", -1)) != 0:
		return false
	var registry := _load_json(REGISTRY_PATH)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted := metric.get("accepted_physical_unit_ids", []) as Array
	if int(metric.get("numerator", -1)) != 7 or int(metric.get("denominator", -1)) != 213 \
	or str(metric.get("display", "")) != "7/213" or accepted.size() != 7 \
	or accepted.count("physical-building:w95934119") != 0 \
	or str(registry.get("schema_version", "")) != "ti.facade-runtime-registry/7" \
	or str((registry.get("build_contract", {}) as Dictionary).get("compiler_version", "")) != "1.6.0" \
	or str((registry.get("adapter_contract", {}) as Dictionary).get("schema_version", "")) != "ti.facade-runtime-adapter-contracts/6" \
	or str((registry.get("compatibility_contract", {}) as Dictionary).get("loader_api_version", "")) != "ti.facade-runtime-registry-loader/6" \
	or str((registry.get("compatibility_contract", {}) as Dictionary).get("unknown_version_policy", "")) != "reject":
		return false
	var b225_runtime := _unit_for(registry.get("units", []) as Array, "physical-building:w95934119")
	var adapters := (registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == ADAPTER.RECEIVER_KEY)
	var catalog := _load_json(CATALOG_PATH)
	var counts := catalog.get("expected_counts", {}) as Dictionary
	var b225_catalog := _unit_for(catalog.get("units", []) as Array, "physical-building:w95934119")
	return not b225_runtime.is_empty() and not b225_catalog.is_empty() \
		and adapters.is_empty() \
		and (b225_runtime.get("acceptance_records", []) as Array).is_empty() \
		and (b225_runtime.get("active_runtime_adapter_ids", []) as Array).is_empty() \
		and str((b225_runtime.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "not_evaluated" \
		and str((b225_runtime.get("claim_status", {}) as Dictionary).get("game_distinctive", "")) == "not_evaluated" \
		and str((b225_runtime.get("capture_contract", {}) as Dictionary).get("status", "")) == "unconfigured" \
		and str(b225_runtime.get("runtime_content_mode", "")) == "all_receivers_generated_placeholder" \
		and (b225_catalog.get("acceptance_records", []) as Array).is_empty() \
		and (b225_catalog.get("recognition_cues", []) as Array).is_empty() \
		and str((b225_catalog.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "not_evaluated" \
		and str(catalog.get("schema_version", "")) == "ti.facade-recognition-catalog/7" \
		and str((catalog.get("compiler_contract", {}) as Dictionary).get("required_compiler_version", "")) == "1.6.0" \
		and str((catalog.get("compiler_contract", {}) as Dictionary).get("emitted_runtime_schema_version", "")) == "ti.facade-runtime-registry/7" \
		and int(counts.get("recognition_units", -1)) == 213 \
		and int(counts.get("active_runtime_adapter_receivers", -1)) == 6 \
		and int((registry.get("counts", {}) as Dictionary).get("active_runtime_adapter_receivers", -1)) == 6


func _whole_world_matches(record: Dictionary, roof_record: Dictionary, authored: Dictionary) -> bool:
	var main_scene := load("res://game/scenes/main.tscn") as PackedScene
	var main := main_scene.instantiate() as GameMain if main_scene != null else null
	if main == null:
		return false
	var world := main.get_node("WorldRoot") as WorldLoader
	var ready: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 45000:
		await process_frame
	if not failures.is_empty() or ready.size() != 1:
		print("B225_FOCUSED_DIAGNOSTIC world_failures=", failures)
		main.queue_free()
		await process_frame
		return false
	var evidence := world.get_runtime_evidence()
	var walls := _record_roots(world, ADAPTER.RECEIVER_KEY)
	var roofs := _record_roots(world, ADAPTER.ROOF_KEY)
	var default_topology := _evidence_topology(evidence)
	var result := default_topology == EXPECTED_DEFAULT_WORLD_TOPOLOGY \
		and walls.size() == 1 and roofs.size() == 1 \
		and _ordinary_world_has_no_candidate(world) \
		and _ordinary_host_matches({"node": walls[0], "mesh_instances": 1, "surfaces": 1, "triangles": 28}, record) \
		and _roof_node_matches(roofs[0] as Node3D, roof_record)
	if not result:
		print("B225_FOCUSED_DIAGNOSTIC default_topology=", default_topology, " walls=", walls.size(), " roofs=", roofs.size())
		main.queue_free()
		await process_frame
		return false

	var wall := walls[0] as Node3D
	var roof := roofs[0] as Node3D
	var default_snapshot := _candidate_snapshot(world, wall, roof)
	var malformed := CANDIDATE_SEAM.activation_request()
	malformed["candidate_id"] = "unknown-candidate"
	var malformed_result := CANDIDATE_SEAM.apply_candidate(world, malformed)
	result = result and not bool(malformed_result.get("ok", false)) \
		and str(malformed_result.get("code", "")) == "d1_b225_candidate_activation" \
		and _candidate_snapshot(world, wall, roof) == default_snapshot
	var missing_field := CANDIDATE_SEAM.activation_request()
	missing_field.erase("adapter_config_sha256")
	var missing_result := CANDIDATE_SEAM.apply_candidate(world, missing_field)
	result = result and not bool(missing_result.get("ok", false)) \
		and _candidate_snapshot(world, wall, roof) == default_snapshot
	var extra_field := CANDIDATE_SEAM.activation_request()
	extra_field["allow_generic_override"] = true
	var extra_result := CANDIDATE_SEAM.apply_candidate(world, extra_field)
	result = result and not bool(extra_result.get("ok", false)) \
		and _candidate_snapshot(world, wall, roof) == default_snapshot
	var wrong_target := CANDIDATE_SEAM.activation_request()
	wrong_target["receiver_key"] = "building:w0:wall"
	var wrong_target_result := CANDIDATE_SEAM.apply_candidate(world, wrong_target)
	result = result and not bool(wrong_target_result.get("ok", false)) \
		and _candidate_snapshot(world, wall, roof) == default_snapshot
	var wrong_root_result := CANDIDATE_SEAM.apply_candidate(main, CANDIDATE_SEAM.activation_request())
	result = result and not bool(wrong_root_result.get("ok", false)) \
		and _candidate_snapshot(world, wall, roof) == default_snapshot
	if not result:
		print("B225_FOCUSED_DIAGNOSTIC candidate_rejection_mutated_default=", _candidate_snapshot(world, wall, roof), " expected=", default_snapshot)
		main.queue_free()
		await process_frame
		return false

	var apply_result := CANDIDATE_SEAM.apply_candidate(world, CANDIDATE_SEAM.activation_request())
	if not bool(apply_result.get("ok", false)):
		var diagnostic_wall_mesh := (wall.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
		var diagnostic_roof_mesh := (roof.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
		print("B225_FOCUSED_DIAGNOSTIC seam_wall_ok=", CANDIDATE_SEAM._ordinary_wall_matches(wall, record), " seam_roof_ok=", CANDIDATE_SEAM._protected_roof_matches(roof, roof_record), " wall_proxy=", wall.get_parent().name, " roof_proxy=", roof.get_parent().name, " wall_surfaces=", diagnostic_wall_mesh.get_surface_count(), " roof_surfaces=", diagnostic_roof_mesh.get_surface_count())
		print("B225_FOCUSED_DIAGNOSTIC seam_components wall_prefix=", str(wall.get_parent().name).begins_with(ADAPTER.TARGET_CHUNK_ID + "__"), " roof_prefix=", str(roof.get_parent().name).begins_with(ADAPTER.TARGET_CHUNK_ID + "__"), " wall_arrays=", CANDIDATE_SEAM._mesh_arrays_match_record(diagnostic_wall_mesh.surface_get_arrays(0), record), " roof_arrays=", CANDIDATE_SEAM._mesh_arrays_match_record(diagnostic_roof_mesh.surface_get_arrays(0), roof_record), " wall_collision=", CANDIDATE_SEAM._collision_faces_match(((wall.get_node("Collision/Shape") as CollisionShape3D).shape as ConcavePolygonShape3D).get_faces(), record), " roof_collision=", CANDIDATE_SEAM._collision_faces_match(((roof.get_node("Collision/Shape") as CollisionShape3D).shape as ConcavePolygonShape3D).get_faces(), roof_record))
		var diagnostic_arrays := diagnostic_wall_mesh.surface_get_arrays(0)
		print("B225_FOCUSED_DIAGNOSTIC wall_array_sizes v=", (diagnostic_arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size(), "/", (record.vertices as Array).size(), " n=", (diagnostic_arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array).size(), "/", (record.normals as Array).size(), " uv=", (diagnostic_arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array).size(), "/", (record.uvs as Array).size(), " i=", (diagnostic_arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size(), " index_equal=", (diagnostic_arrays[Mesh.ARRAY_INDEX] as PackedInt32Array) == _reversed_indices(record), " first_v=", (diagnostic_arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array)[0], " expected=", Vector3(float(record.vertices[0]), float(record.vertices[1]), float(record.vertices[2])), " first_n=", (diagnostic_arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array)[0], " expected_n=", Vector3(float(record.normals[0]), float(record.normals[1]), float(record.normals[2])), " first_uv=", (diagnostic_arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array)[0], " expected_uv=", Vector2(float(record.uvs[0]), float(record.uvs[1])))
	await process_frame
	var candidate_topology := _evidence_topology(evidence)
	var candidate_snapshot := _candidate_snapshot(world, wall, roof)
	var default_ids := default_snapshot.get("instance_ids", {}) as Dictionary
	var candidate_ids := candidate_snapshot.get("instance_ids", {}) as Dictionary
	result = bool(apply_result.get("ok", false)) \
		and bool(apply_result.get("applied", false)) \
		and candidate_topology == EXPECTED_CANDIDATE_WORLD_TOPOLOGY \
		and _host_and_attachment_match({"node": wall, "mesh_instances": 3, "surfaces": 4, "triangles": 1108}, record, authored, DisplayServer.get_name() != "headless") \
		and _roof_node_matches(roof, roof_record) \
		and int(candidate_ids.get("host_mesh_instance", -1)) == int(default_ids.get("host_mesh_instance", -2)) \
		and int(candidate_ids.get("host_body", -1)) == int(default_ids.get("host_body", -2)) \
		and int(candidate_ids.get("host_shape", -1)) == int(default_ids.get("host_shape", -2)) \
		and int(candidate_ids.get("roof_mesh_instance", -1)) == int(default_ids.get("roof_mesh_instance", -2)) \
		and int(candidate_ids.get("roof_mesh_resource", -1)) == int(default_ids.get("roof_mesh_resource", -2)) \
		and int(candidate_ids.get("roof_body", -1)) == int(default_ids.get("roof_body", -2)) \
		and int(candidate_ids.get("roof_shape", -1)) == int(default_ids.get("roof_shape", -2)) \
		and int(candidate_ids.get("host_mesh_resource", -1)) != int(default_ids.get("host_mesh_resource", -1))
	await physics_frame
	await physics_frame
	result = result and _spray_ray_matches(wall, record)
	var duplicate_result := CANDIDATE_SEAM.apply_candidate(world, CANDIDATE_SEAM.activation_request())
	result = result and not bool(duplicate_result.get("ok", false)) \
		and str(duplicate_result.get("code", "")) == "d1_b225_candidate_duplicate" \
		and _candidate_snapshot(world, wall, roof) == candidate_snapshot
	if not result:
		print("B225_FOCUSED_DIAGNOSTIC candidate_topology=", candidate_topology, " apply=", apply_result, " duplicate=", duplicate_result)
	else:
		print("D1_B225_PREPROMOTION_CANDIDATE_TOPOLOGY: default=735/950/964/66636/466/466 candidate=735/952/967/67716/466/466 delta=+0/+2/+3/+1080/+0/+0")
	main.queue_free()
	await process_frame
	return result


func _roof_node_matches(node: Node3D, record: Dictionary) -> bool:
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	return node.get_node_or_null("D1B225LiveAttachment") == null \
		and _count_type(node, MeshInstance3D) == 1 \
		and _count_type(node, StaticBody3D) == 1 \
		and _count_type(node, CollisionShape3D) == 1 \
		and mesh != null and mesh.get_surface_count() == 1 and _surface_triangles(mesh, 0) == 2 \
		and mesh.surface_get_material(0).resource_name == "building_roof" \
		and body != null and shape != null \
		and body.collision_layer == (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) and body.collision_mask == 0 \
		and not body.is_in_group("spray_receiver_wall") \
		and str(body.get_meta("receiver_kind", "invalid")) == "none" \
		and str(body.get_meta("derived_object_key", "")) == ADAPTER.ROOF_KEY \
		and body.get_meta("source_keys", []) == [ADAPTER.SOURCE_KEY] \
		and str(shape.get_meta("receiver_kind", "invalid")) == "none" \
		and str(shape.get_meta("derived_object_key", "")) == ADAPTER.ROOF_KEY \
		and shape.get_meta("source_keys", []) == [ADAPTER.SOURCE_KEY] \
		and _collision_faces_match(shape.get_faces(), record)


func _evidence_topology(evidence: RuntimeEvidence) -> Dictionary:
	return {
		"rows": evidence.playable_rows,
		"meshes": evidence.mesh_instances,
		"surfaces": evidence.surfaces,
		"triangles": evidence.triangles,
		"bodies": evidence.static_bodies,
		"shapes": evidence.shapes,
	}


func _ordinary_world_has_no_candidate(world: Node) -> bool:
	if world.has_meta(CANDIDATE_SEAM.APPLIED_META):
		return false
	for node: Node in world.find_children("*", "", true, false):
		if node.has_meta(CANDIDATE_SEAM.APPLIED_META) \
		or node.has_meta(CANDIDATE_SEAM.HOST_PARTITION_META) \
		or node.name in ["D1B225PrepromotionCandidateAttachment", "D1B225LiveAttachment"]:
			return false
	return true


func _candidate_snapshot(world: WorldLoader, wall: Node3D, roof: Node3D) -> Dictionary:
	var host_mesh_instance := wall.get_node("Mesh") as MeshInstance3D
	var host_body := wall.get_node("Collision") as StaticBody3D
	var host_shape := wall.get_node("Collision/Shape") as CollisionShape3D
	var roof_mesh_instance := roof.get_node("Mesh") as MeshInstance3D
	var roof_body := roof.get_node("Collision") as StaticBody3D
	var roof_shape := roof.get_node("Collision/Shape") as CollisionShape3D
	return {
		"topology": _evidence_topology(world.get_runtime_evidence()),
		"instance_ids": {
			"host_mesh_instance": host_mesh_instance.get_instance_id(),
			"host_mesh_resource": host_mesh_instance.mesh.get_instance_id(),
			"host_body": host_body.get_instance_id(),
			"host_shape": host_shape.get_instance_id(),
			"roof_mesh_instance": roof_mesh_instance.get_instance_id(),
			"roof_mesh_resource": roof_mesh_instance.mesh.get_instance_id(),
			"roof_body": roof_body.get_instance_id(),
			"roof_shape": roof_shape.get_instance_id(),
		},
		"wall_child_count": wall.get_child_count(),
		"roof_child_count": roof.get_child_count(),
		"world_candidate_meta": world.has_meta(CANDIDATE_SEAM.APPLIED_META),
		"wall_candidate_meta": wall.has_meta(CANDIDATE_SEAM.APPLIED_META),
		"wall_partition_meta": wall.has_meta(CANDIDATE_SEAM.HOST_PARTITION_META),
		"candidate_attachment_count": wall.find_children("D1B225PrepromotionCandidateAttachment", "Node3D", false, false).size(),
	}


func _package_boundary_matches() -> bool:
	var seam_source := FileAccess.get_file_as_string(CANDIDATE_SEAM_PATH)
	var executable := FileAccess.get_file_as_string(ADAPTER_PATH) + "\n" + seam_source + "\n" + FileAccess.get_file_as_string(CONFIG_PATH)
	for banned in ["res://discovery/", "res://evidence/", "http://", "https://", "/Users/", "/Volumes/", "source_assets"]:
		if banned in executable:
			return false
	var adapter_source := FileAccess.get_file_as_string(ADAPTER_PATH)
	for forbidden_override in ["ProjectSettings", "OS.get_environment", "OS.get_cmdline", "get_cmdline_user_args", "--d1-b225", "--b225"]:
		if forbidden_override in seam_source:
			return false
	for canonical_path: String in [
		BUILDER_PATH,
		"res://game/scripts/world/world_loader.gd",
		"res://game/scripts/main.gd",
		"res://game/scripts/world/facades/accepted_material_run_trials.gd",
		"res://game/scripts/world/facades/facade_runtime_registry_loader.gd",
		REGISTRY_PATH,
		CATALOG_PATH,
	]:
		var canonical_source := FileAccess.get_file_as_string(canonical_path)
		for forbidden_candidate_token: String in ["d1_b225_prepromotion_candidate_seam", "d1_b225_live_attachment", "D1B225LiveAttachment", "D1B225PrepromotionCandidate"]:
			if forbidden_candidate_token in canonical_source:
				return false
	var callers := _gd_files_referencing("res://game", "d1_b225_prepromotion_candidate_seam.gd")
	var allowed_callers := [
		"res://game/tests/headless_d1_b225_live_attachment_contract.gd",
		"res://game/tests/d1_b225_prepromotion_candidate_capture.gd",
	]
	if callers.is_empty() or not callers.has("res://game/tests/headless_d1_b225_live_attachment_contract.gd"):
		return false
	for caller: String in callers:
		if caller not in allowed_callers:
			return false
	return "d1_b225_standalone_cladding_repair_v1" not in adapter_source \
		and "d1_current_standalone_prototype_pair" not in adapter_source \
		and "d1_current_standalone_prototypes" not in adapter_source


func _future_runtime_asset_closure_matches() -> bool:
	var exact_six := {
		ADAPTER_PATH: EXPECTED_ADAPTER_SHA256,
		CONFIG_PATH: EXPECTED_CONFIG_SHA256,
		CLADDING_MATERIAL_PATH: EXPECTED_CLADDING_MATERIAL_SHA256,
		CLADDING_TEXTURE_PATH: EXPECTED_CLADDING_TEXTURE_SHA256,
		DARK_GLASS_MATERIAL_PATH: EXPECTED_DARK_GLASS_MATERIAL_SHA256,
		PALE_FRAME_MATERIAL_PATH: EXPECTED_PALE_FRAME_MATERIAL_SHA256,
	}
	if exact_six.size() != 6:
		return false
	for path: String in exact_six:
		if FileAccess.get_sha256(path) != str(exact_six[path]):
			return false
	var config := _load_json(CONFIG_PATH)
	var assets := config.get("material_assets", {}) as Dictionary
	return assets.size() == 3 \
		and str((assets.get("b225_cladding_v1", {}) as Dictionary).get("path", "")) == CLADDING_MATERIAL_PATH \
		and str((assets.get("b225_cladding_v1", {}) as Dictionary).get("albedo_texture_path", "")) == CLADDING_TEXTURE_PATH \
		and str((assets.get("shared_dark_glass", {}) as Dictionary).get("path", "")) == DARK_GLASS_MATERIAL_PATH \
		and str((assets.get("shared_pale_frame", {}) as Dictionary).get("path", "")) == PALE_FRAME_MATERIAL_PATH


func _gd_files_referencing(directory_path: String, token: String) -> Array[String]:
	var result: Array[String] = []
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return result
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry not in [".", ".."]:
			var path := directory_path.path_join(entry)
			if directory.current_is_dir():
				result.append_array(_gd_files_referencing(path, token))
			elif entry.ends_with(".gd") and token in FileAccess.get_file_as_string(path):
				result.append(path)
		entry = directory.get_next()
	directory.list_dir_end()
	result.sort()
	return result


func _reversed_indices(record: Dictionary) -> PackedInt32Array:
	var result := PackedInt32Array()
	var source := record.get("indices", []) as Array
	for offset in range(0, source.size(), 3):
		result.append_array(PackedInt32Array([int(source[offset]), int(source[offset + 2]), int(source[offset + 1])]))
	return result


func _surface_triangles(mesh: ArrayMesh, surface: int) -> int:
	return int(((mesh.surface_get_arrays(surface) as Array)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)


func _record_for(chunk: Dictionary, object_key: String) -> Dictionary:
	for value: Variant in chunk.get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == object_key:
			return record
	return {}


func _unit_for(units: Array, unit_id: String) -> Dictionary:
	for value: Variant in units:
		var unit := value as Dictionary
		if str(unit.get("unit_id", "")) == unit_id:
			return unit
	return {}


func _record_roots(root_node: Node, object_key: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if str(node.get_meta("derived_object_key", "")) == object_key \
		and node.get_node_or_null("Mesh") is MeshInstance3D:
			result.append(node as Node3D)
	return result


func _load_json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
