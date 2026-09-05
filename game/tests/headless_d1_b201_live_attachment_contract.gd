extends SceneTree

const ADAPTER := preload("res://game/scripts/world/facades/d1_b201_live_attachment.gd")
const BUILDER := preload("res://game/scripts/world/world_chunk_builder.gd")
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-2.json"
const CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b201_live_attachment.json"
const ADAPTER_PATH := "res://game/scripts/world/facades/d1_b201_live_attachment.gd"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const METER_UV_PATH := "res://game/scripts/world/facades/facade_meter_uv_adapter.gd"
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const SOURCE_PACKET_PATH := "res://discovery/facades/d1_reference_packets/w34313545_building_201.md"
const SOURCE_RECEIPT_PATH := "res://discovery/facades/PRECOMMIT_PACKAGE_SANITIZATION_SOURCE_PROVENANCE.json"
const STANDALONE_REVIEW_PATH := "res://evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md"
const LIVE_EVIDENCE_MANIFEST_PATH := "res://evidence/first-playable/d1-b201-live-attachment-2026-09-04/capture-manifest.json"
const LIVE_REVIEW_PATH := "res://evidence/first-playable/d1-b201-live-attachment-2026-09-04/INDEPENDENT_LIVE_VISUAL_BAR_RAISER_REVIEW.md"
const EXPECTED_CONFIG_SHA256 := "0f3bf052688ec813b5fa58b077d74c963949574623fe4cf67c12c347e7257229"
const EXPECTED_ADAPTER_SHA256 := "499f6d2657b593ee5b0801cf1205a2925a993f3b1836922d3656a6d00c51cc19"
const EXPECTED_BUILDER_SHA256 := "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c"
const EXPECTED_METER_UV_SHA256 := "47e710b9ea7c5de5122430199e4105cbba5f672d22f59832f13b8004f16c5a1d"
const EXPECTED_REGISTRY_SHA256 := "9c46c1a8c809aa9ded82008d35e9c1b257070e9c61f6d6e41f5650ca7b1c3f27"
const EXPECTED_CATALOG_SHA256 := "a4d9dd474acb09a211f7e0e00d66aeaf7a669927880dd011e24e2f51d13bdd7d"
const EXPECTED_SOURCE_PACKET_SHA256 := "c6fba23d80e95b23c4f3eb172a252baa47767b7a29757096bff329c693db9e5e"
const EXPECTED_SOURCE_RECEIPT_SHA256 := "269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333"
const EXPECTED_STANDALONE_REVIEW_SHA256 := "8567cd5eb9080f8f7cb563152ae83885330d366cc56ecc8513d5ebdadf491feb"
const EXPECTED_LIVE_EVIDENCE_MANIFEST_SHA256 := "f169085620a0a9ff0c685e4dfa98442c5c31e4e580f1decdbd80e84b09c74fe3"
const EXPECTED_LIVE_REVIEW_SHA256 := "b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772"
const EXPECTED_BATCH_COUNTS := {"b201_warm_wall": 20, "shared_dark_glass": 18, "shared_pale_frame": 120, "b201_green_hierarchy": 4, "b201_muted_rust_post": 7, "b201_service_leaf": 3}
const EXPECTED_WORLD_TOPOLOGY := {"rows": 735, "meshes": 950, "surfaces": 964, "triangles": 66636, "bodies": 466, "shapes": 466}
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256, "B201 live config bytes drifted.")
	_require(FileAccess.get_sha256(ADAPTER_PATH) == EXPECTED_ADAPTER_SHA256, "B201 live adapter bytes drifted.")
	_require(FileAccess.get_sha256(BUILDER_PATH) == EXPECTED_BUILDER_SHA256, "World builder B201 seam bytes drifted.")
	_require(FileAccess.get_sha256(METER_UV_PATH) == EXPECTED_METER_UV_SHA256, "FacadeMeterUvAdapter bytes drifted.")
	_require(_package_boundary_matches(), "B201 executable closure contains a forbidden source/evidence/private path or direct standalone factory seam.")
	_require(_current_authority_matches(), "B201 source packet, sealed capture-time 6/213 provenance, or exact-current 7/213 authority drifted.")
	var chunk := _load_json(CHUNK_PATH)
	var record := _record_for(chunk, ADAPTER.RECEIVER_KEY)
	var roof := _record_for(chunk, ADAPTER.ROOF_KEY)
	_require(not record.is_empty() and not roof.is_empty(), "Exact B201 wall/roof pair did not resolve.")
	_require(bool(ADAPTER.validate_chunk_records(chunk).get("ok", false)), "Exact B201 chunk preflight failed.")
	_require(ADAPTER.canonical_record_signature(record) == ADAPTER.EXPECTED_CANONICAL_RECORD_SHA256 and ADAPTER.record_signature(record) == ADAPTER.EXPECTED_RUNTIME_RECORD_SHA256, "Exact B201 wall authority signatures drifted.")
	_require(ADAPTER.canonical_record_signature(roof) == ADAPTER.EXPECTED_CANONICAL_ROOF_RECORD_SHA256 and ADAPTER.record_signature(roof) == ADAPTER.EXPECTED_RUNTIME_ROOF_RECORD_SHA256, "Protected B201 roof authority signatures drifted.")
	var builder := BUILDER.new()
	var prepared := ADAPTER.prepare(record)
	var authored := ADAPTER.authored_transform_spec(record, prepared)
	_require(bool(prepared.get("ok", false)) and bool(authored.get("ok", false)), "B201 deterministic prepared/authored state failed.")
	var result := builder._build_record(record, false)
	if not _require(bool(result.get("ok", false)), "B201 exact receiver failed focused live construction: %s" % str(result.get("message", result.get("code", "unknown")))):
		_finish()
		return
	var node := result.get("node") as Node3D
	root.add_child(node)
	await process_frame
	_require(_host_and_attachment_match(result, record, authored, DisplayServer.get_name() != "headless"), "B201 host partition, decorative topology, grounding, or ownership contract failed.")
	_require(_mutation_matrix_fails_closed(chunk, record, result), "B201 adversarial record/chunk/prepared/partition mutation escaped fail-closed handling.")
	await physics_frame
	await physics_frame
	_require(_spray_ray_matches(node, record), "B201 retained host did not resolve the expected spray ray/normal/identity.")
	node.queue_free()
	await process_frame
	_require(await _whole_world_matches(record, roof), "B201 whole-world topology, live roof parity, or sole ownership contract drifted.")
	if not _failed:
		print("PASS: B201 exact wall remains one 80-triangle host mesh and sole collider/spray receiver; runs 0..9 form one 20-triangle warm metre-UV surface, protected runs 10..39 remain one 60-triangle generic surface, six batches / 172 grounded detail boxes / 2,064 triangles attach with zero collision/navigation/spray ownership, whole world measures 735/950/964/66,636/466/466, capture provenance remains frozen at 6/213, and exact-current recognition is 7/213")
	_finish()


func _host_and_attachment_match(result: Dictionary, record: Dictionary, authored: Dictionary, verify_realized_transforms: bool) -> bool:
	var node := result.node as Node3D
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var attachment := node.get_node_or_null("D1B201LiveAttachment") as Node3D
	var partition_ok := mesh != null and _partition_indices_match(mesh, record)
	var uvs_ok := mesh != null and _host_uvs_match(mesh, record)
	var collision_ok := shape != null and _collision_faces_match(shape.get_faces(), record)
	if node.get_child_count() != 3 or mesh == null or body == null or shape == null or attachment == null \
	or int(result.mesh_instances) != 7 or int(result.surfaces) != 8 or int(result.triangles) != 2144 \
	or mesh.get_surface_count() != 2 \
	or mesh.surface_get_name(0) != "generated_record_protected_runs_10_39" \
	or mesh.surface_get_name(1) != "d1_b201_public_wsw_runs_0_9" \
	or mesh.surface_get_material(0).resource_name != "building_wall" \
	or mesh.surface_get_material(1).resource_path != "res://game/resources/materials/world/d1_current/b201_warm_wall.tres" \
	or _surface_triangles(mesh, 0) != 60 or _surface_triangles(mesh, 1) != 20 \
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
		print("B201_FOCUSED_DIAGNOSTIC partition=", partition_ok, " uvs=", uvs_ok, " collision=", collision_ok, " child_count=", node.get_child_count(), " result=", {"m": result.mesh_instances, "s": result.surfaces, "t": result.triangles})
		return false
	var topology := ADAPTER.render_topology(attachment)
	if topology != {"mesh_instances": 6, "surfaces": 6, "triangles": 2064}:
		print("B201_FOCUSED_DIAGNOSTIC topology=", topology)
		return false
	var render_root := attachment.get_node_or_null("RenderOnlyBatches") as Node3D
	if render_root == null or render_root.get_child_count() != 6:
		print("B201_FOCUSED_DIAGNOSTIC render_root=", render_root, " children=", -1 if render_root == null else render_root.get_child_count())
		return false
	var counts := {}
	for child: Node in render_root.get_children():
		var instance := child as MultiMeshInstance3D
		if instance == null or instance.multimesh == null or not (instance.multimesh.mesh is BoxMesh) \
		or instance.layers != (1 << 1):
			print("B201_FOCUSED_DIAGNOSTIC bad_batch=", child)
			return false
		var key := str(instance.get_meta("material_key", ""))
		var box := instance.multimesh.mesh as BoxMesh
		var material := box.material as StandardMaterial3D
		var expected_material := ADAPTER.MATERIAL_SPECS.get(key, {}) as Dictionary
		if material == null or expected_material.is_empty() \
		or material.resource_path != str(expected_material.get("path", "")) \
		or material.resource_name != str(expected_material.get("resource_name", "")):
			print("B201_FOCUSED_DIAGNOSTIC material=", key, " path=", "" if material == null else material.resource_path)
			return false
		counts[key] = instance.multimesh.instance_count
		if verify_realized_transforms:
			var expected_transforms := (authored.get("boxes", {}) as Dictionary).get(key, []) as Array
			for index in instance.multimesh.instance_count:
				var transform := instance.multimesh.get_instance_transform(index)
				if not _transform_matches(transform, expected_transforms[index] as Transform3D):
					print("B201_FOCUSED_DIAGNOSTIC realized_transform=", key, " index=", index)
					return false
	var grounding_ok := _authored_transforms_match(authored, record)
	if counts != EXPECTED_BATCH_COUNTS or not grounding_ok:
		print("B201_FOCUSED_DIAGNOSTIC counts=", counts, " expected=", EXPECTED_BATCH_COUNTS, " grounding=", grounding_ok)
	return counts == EXPECTED_BATCH_COUNTS and grounding_ok


func _partition_indices_match(mesh: ArrayMesh, record: Dictionary) -> bool:
	var expected_public := PackedInt32Array()
	var expected_protected := PackedInt32Array()
	var source := record.get("indices", []) as Array
	for offset in range(0, source.size(), 3):
		var target := expected_public if int(offset / 6) < 10 else expected_protected
		target.append(int(source[offset]))
		target.append(int(source[offset + 2]))
		target.append(int(source[offset + 1]))
	# Packed arrays are copy-on-write; rebuild explicitly if the conditional
	# target detached in this runtime.
	if expected_public.size() != 60 or expected_protected.size() != 180:
		expected_public.clear()
		expected_protected.clear()
		for offset in range(0, source.size(), 3):
			if int(offset / 6) < 10:
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
		and public_indices.size() == 60 and protected_indices.size() == 180


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
	for run_index in range(10, 40):
		for corner in 4:
			var uv_index := run_index * 4 + corner
			var scalar := uv_index * 2
			if not expected[uv_index].is_equal_approx(Vector2(float(source_uvs[scalar]), float(source_uvs[scalar + 1]))):
				return false
	return is_equal_approx(expected[0].x, 0.0) \
		and absf(expected[38].x - float((prepared.chain as Dictionary).plan.total_u_m)) <= 0.00002


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
	if str(authored.get("signature", "")) != ADAPTER.EXPECTED_DECORATIVE_GEOMETRY_SIGNATURE \
	or int(authored.get("box_count", -1)) != 172 \
	or int(authored.get("triangles", -1)) != 2064 \
	or authored.get("batch_counts", {}) != EXPECTED_BATCH_COUNTS:
		return false
	for key: Variant in boxes:
		for transform_value: Variant in boxes[key] as Array:
			var transform := transform_value as Transform3D
			if transform.origin.z - transform.basis.z.length() * 0.5 < -0.00001:
				return false
	var posts := boxes.get("b201_muted_rust_post", []) as Array
	var services := boxes.get("b201_service_leaf", []) as Array
	if posts.size() != 7 or services.size() != 3:
		return false
	var canopy_center_x := -6.0
	var canopy_width_m := 58.0
	for index in 7:
		var x := canopy_center_x - canopy_width_m * 0.5 + 2.2 + index * ((canopy_width_m - 4.4) / 6.0)
		var transform := posts[index] as Transform3D
		if absf((transform.origin.y - transform.basis.y.length() * 0.5) - (ADAPTER._sample_host_bottom_local_y(chain, x) - 0.06)) > 0.00001:
			return false
	var service_xs := [-43.0, -4.0, 38.0]
	for index in 3:
		var transform := services[index] as Transform3D
		if absf((transform.origin.y - transform.basis.y.length() * 0.5) - (ADAPTER._sample_host_bottom_local_y(chain, float(service_xs[index])) - 0.04)) > 0.00001:
			return false
	return true


func _transform_matches(actual: Transform3D, expected: Transform3D) -> bool:
	return actual.origin.is_equal_approx(expected.origin) \
		and actual.basis.x.is_equal_approx(expected.basis.x) \
		and actual.basis.y.is_equal_approx(expected.basis.y) \
		and actual.basis.z.is_equal_approx(expected.basis.z)


func _spray_ray_matches(node: Node3D, record: Dictionary) -> bool:
	var vertices := record.get("vertices", []) as Array
	var start := Vector3(float(vertices[0]), float(vertices[1]), float(vertices[2]))
	var end := Vector3(float(vertices[3]), float(vertices[4]), float(vertices[5]))
	var point := (start + end) * 0.5
	point.y = 4.2
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
		["exterior_foundation_segments", 39],
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
	(_record_for(key_changed, ADAPTER.RECEIVER_KEY))["object_key"] = "building:w34313545:wall-drift"
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
	materials["b201_warm_wall"] = materials["shared_dark_glass"]
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
		STANDALONE_REVIEW_PATH: EXPECTED_STANDALONE_REVIEW_SHA256,
		LIVE_EVIDENCE_MANIFEST_PATH: EXPECTED_LIVE_EVIDENCE_MANIFEST_SHA256,
		LIVE_REVIEW_PATH: EXPECTED_LIVE_REVIEW_SHA256,
	}
	for path: String in expected_hashes:
		if FileAccess.get_sha256(path) != str(expected_hashes[path]):
			return false
	var config := _load_json(CONFIG_PATH)
	var receipts := config.get("source_receipts", {}) as Dictionary
	var runtime := config.get("runtime_contract", {}) as Dictionary
	if str(receipts.get("authoritative_packet_receipt_sha256", "")) != EXPECTED_SOURCE_RECEIPT_SHA256 \
	or str(receipts.get("authoritative_packet_sha256", "")) != EXPECTED_SOURCE_PACKET_SHA256 \
	or str(receipts.get("standalone_review_receipt_sha256", "")) != EXPECTED_STANDALONE_REVIEW_SHA256 \
	or bool(runtime.get("reference_recognizable", true)) \
	or str(runtime.get("recognition_status", "")) != "pending_independent_live_visual_static_and_package_review":
		return false
	var capture_manifest := _load_json(LIVE_EVIDENCE_MANIFEST_PATH)
	if str(capture_manifest.get("recognition_metric_frozen", "")) != "6/213" \
	or str(capture_manifest.get("review_status", "")) != "pending_independent_live_visual_static_and_package_review_not_self_accepted" \
	or bool((capture_manifest.get("bindings", {}) as Dictionary).get("recognition_accepted", true)) \
	or str((capture_manifest.get("bindings", {}) as Dictionary).get("recognition_metric", "")) != "6/213":
		return false
	var registry := _load_json(REGISTRY_PATH)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted := metric.get("accepted_physical_unit_ids", []) as Array
	if int(metric.get("numerator", -1)) != 7 or int(metric.get("denominator", -1)) != 213 \
	or str(metric.get("display", "")) != "7/213" or accepted.size() != 7 \
	or accepted.count("physical-building:w34313545") != 1:
		return false
	var b201 := _unit_for(registry.get("units", []) as Array, "physical-building:w34313545")
	var acceptance_records := b201.get("acceptance_records", []) as Array
	var adapters := (registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == ADAPTER.RECEIVER_KEY)
	var catalog := _load_json(CATALOG_PATH)
	var counts := catalog.get("expected_counts", {}) as Dictionary
	var behavior := ((adapters[0] as Dictionary).get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary if adapters.size() == 1 else {}
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	return not b201.is_empty() \
		and adapters.size() == 1 \
		and str((adapters[0] as Dictionary).get("review_status", "")) == "independent_exact_current_live_pass" \
		and str((adapters[0] as Dictionary).get("review_status_scope", "")) == "runtime_asset_original_detail_provenance_only_not_reference_recognition" \
		and str((adapters[0] as Dictionary).get("recognition_acceptance_authority", "")) == "physical_unit_claim_and_independent_acceptance_record" \
		and str((adapters[0] as Dictionary).get("recognition_acceptance_status", "")) == str((b201.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) \
		and str(geometry.get("world_topology_scope", "")) == "current_integration_topology" \
		and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 950 \
		and int(geometry.get("world_surfaces", -1)) == 964 and int(geometry.get("world_triangles", -1)) == 66636 \
		and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466 \
		and acceptance_records.size() == 1 \
		and str((acceptance_records[0] as Dictionary).get("review_kind", "")) == "independent_reference_recognition" \
		and str((acceptance_records[0] as Dictionary).get("status", "")) == "accept" \
		and str((acceptance_records[0] as Dictionary).get("review_receipt_sha256", "")) == EXPECTED_LIVE_REVIEW_SHA256 \
		and str((acceptance_records[0] as Dictionary).get("evidence_manifest_sha256", "")) == EXPECTED_LIVE_EVIDENCE_MANIFEST_SHA256 \
		and (b201.get("active_runtime_adapter_ids", []) as Array) == ["active-adapter:d1-b201-live:building:w34313545:wall"] \
		and str((b201.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "accepted" \
		and str((b201.get("capture_contract", {}) as Dictionary).get("status", "")) == "configured" \
		and int(counts.get("recognition_units", -1)) == 213 \
		and int(counts.get("active_runtime_adapter_receivers", -1)) == 6


func _whole_world_matches(record: Dictionary, roof_record: Dictionary) -> bool:
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
		print("B201_FOCUSED_DIAGNOSTIC world_failures=", failures)
		main.queue_free()
		await process_frame
		return false
	var evidence := world.get_runtime_evidence()
	var topology := {"rows": evidence.playable_rows, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "bodies": evidence.static_bodies, "shapes": evidence.shapes}
	var walls := _record_roots(world, ADAPTER.RECEIVER_KEY)
	var roofs := _record_roots(world, ADAPTER.ROOF_KEY)
	var result := topology == EXPECTED_WORLD_TOPOLOGY and walls.size() == 1 and roofs.size() == 1
	if result:
		var prepared := ADAPTER.prepare(record)
		var authored := ADAPTER.authored_transform_spec(record, prepared)
		result = _host_and_attachment_match({"node": walls[0], "mesh_instances": 7, "surfaces": 8, "triangles": 2144}, record, authored, DisplayServer.get_name() != "headless") \
			and _roof_node_matches(roofs[0] as Node3D, roof_record)
	if not result:
		print("B201_FOCUSED_DIAGNOSTIC world_topology=", topology, " walls=", walls.size(), " roofs=", roofs.size())
	else:
		print("D1_B201_LIVE_TOPOLOGY: rows=%d meshes=%d surfaces=%d triangles=%d bodies=%d shapes=%d delta=+0/+6/+7/+2064/+0/+0" % [evidence.playable_rows, evidence.mesh_instances, evidence.surfaces, evidence.triangles, evidence.static_bodies, evidence.shapes])
	main.queue_free()
	await process_frame
	return result


func _roof_node_matches(node: Node3D, record: Dictionary) -> bool:
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	return node.get_node_or_null("D1B201LiveAttachment") == null \
		and _count_type(node, MeshInstance3D) == 1 \
		and _count_type(node, StaticBody3D) == 1 \
		and _count_type(node, CollisionShape3D) == 1 \
		and mesh != null and mesh.get_surface_count() == 1 and _surface_triangles(mesh, 0) == 12 \
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


func _package_boundary_matches() -> bool:
	var executable := FileAccess.get_file_as_string(ADAPTER_PATH) + "\n" + FileAccess.get_file_as_string(BUILDER_PATH) + "\n" + FileAccess.get_file_as_string(CONFIG_PATH)
	for banned in ["res://discovery/", "res://evidence/", "http://", "https://", "/Users/", "/Volumes/", "source_assets"]:
		if banned in executable:
			return false
	var builder_source := FileAccess.get_file_as_string(BUILDER_PATH)
	var adapter_source := FileAccess.get_file_as_string(ADAPTER_PATH)
	return "d1_current_standalone_prototype_pair" not in builder_source \
		and "d1_current_standalone_prototypes" not in builder_source \
		and "d1_current_standalone_prototype_pair" not in adapter_source \
		and "d1_current_standalone_prototypes" not in adapter_source


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
