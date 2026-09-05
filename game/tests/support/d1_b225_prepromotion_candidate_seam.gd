class_name D1B225PrepromotionCandidateSeam
extends RefCounted

## Deliberate, test-only post-construction seam for the B225 live A/B. Neither
## the canonical builder, loader, main scene, nor runtime registry references
## this file. A focused contract or capture harness must load it explicitly and
## supply the complete activation request after the ordinary current world has
## reached its frozen 7/213 topology.

const ADAPTER := preload("res://game/scripts/world/facades/d1_b225_live_attachment.gd")
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_-1.json"
const ACTIVATION_SCHEMA := "ti.d1-b225-prepromotion-candidate-activation/1"
const CANDIDATE_ID := "D1-B225-W95934119-NNW-LONG-PREPROMOTION-LIVE-AB"
const APPLIED_META := "d1_b225_prepromotion_candidate"
const HOST_PARTITION_META := "d1_b225_prepromotion_candidate_host_partition"
const DEFAULT_WORLD_TOPOLOGY := {
	"rows": 735,
	"meshes": 950,
	"surfaces": 964,
	"triangles": 66636,
	"bodies": 466,
	"shapes": 466,
}
const CANDIDATE_WORLD_TOPOLOGY := {
	"rows": 735,
	"meshes": 952,
	"surfaces": 967,
	"triangles": 67716,
	"bodies": 466,
	"shapes": 466,
}
const CANDIDATE_DELTA := {
	"rows": 0,
	"meshes": 2,
	"surfaces": 3,
	"triangles": 1080,
	"bodies": 0,
	"shapes": 0,
}
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2


static func activation_request() -> Dictionary:
	return {
		"schema_version": ACTIVATION_SCHEMA,
		"candidate_id": CANDIDATE_ID,
		"mode": "explicit_post_construction_receiver_live_ab",
		"source_key": ADAPTER.SOURCE_KEY,
		"receiver_key": ADAPTER.RECEIVER_KEY,
		"roof_key": ADAPTER.ROOF_KEY,
		"target_chunk_id": ADAPTER.TARGET_CHUNK_ID,
		"adapter_config_path": ADAPTER.CONFIG_PATH,
		"adapter_config_sha256": ADAPTER.EXPECTED_CONFIG_SHA256,
		"expected_default_world_topology": DEFAULT_WORLD_TOPOLOGY.duplicate(true),
		"expected_candidate_world_topology": CANDIDATE_WORLD_TOPOLOGY.duplicate(true),
		"expected_candidate_delta": CANDIDATE_DELTA.duplicate(true),
	}


static func apply_candidate(world_root: Node, request: Dictionary) -> Dictionary:
	# Validate every authority and stage every replacement resource before the
	# first live node or evidence counter is changed. Any rejected call therefore
	# leaves the supplied ordinary world byte-for-byte/render-for-render intact.
	if not _activation_matches(request):
		return _failure("d1_b225_candidate_activation", "B225 candidate activation was unknown, incomplete, or malformed.")
	if world_root == null or not world_root.has_method("is_world_validated") \
	or not bool(world_root.call("is_world_validated")) \
	or not world_root.has_method("get_runtime_evidence"):
		return _failure("d1_b225_candidate_world", "B225 candidate requires one validated ordinary WorldRoot.")
	if world_root.has_meta(APPLIED_META) or not _candidate_nodes(world_root).is_empty():
		return _failure("d1_b225_candidate_duplicate", "B225 candidate was already applied to this world.")
	var evidence := world_root.call("get_runtime_evidence") as Node
	if evidence == null or _evidence_topology(evidence) != DEFAULT_WORLD_TOPOLOGY:
		return _failure("d1_b225_candidate_default_topology", "B225 candidate requires the exact frozen 7/213 ordinary-world topology.")
	var chunk := _load_json(CHUNK_PATH)
	var chunk_validation := ADAPTER.validate_chunk_records(chunk)
	if not bool(chunk_validation.get("ok", false)) or not bool(chunk_validation.get("applies", false)):
		return _failure("d1_b225_candidate_chunk_authority", "B225 candidate chunk authority did not validate.")
	var wall_record := _record_for(chunk, ADAPTER.RECEIVER_KEY)
	var roof_record := _record_for(chunk, ADAPTER.ROOF_KEY)
	var walls := _record_roots(world_root, ADAPTER.RECEIVER_KEY)
	var roofs := _record_roots(world_root, ADAPTER.ROOF_KEY)
	if wall_record.is_empty() or roof_record.is_empty() or walls.size() != 1 or roofs.size() != 1:
		return _failure("d1_b225_candidate_membership", "B225 candidate did not resolve exactly one live wall and protected roof.")
	var wall := walls[0] as Node3D
	var roof := roofs[0] as Node3D
	if not _ordinary_wall_matches(wall, wall_record) or not _protected_roof_matches(roof, roof_record):
		return _failure("d1_b225_candidate_live_authority", "B225 live wall or protected roof drifted before candidate staging.")
	var prepared := ADAPTER.prepare(wall_record)
	if not bool(prepared.get("ok", false)):
		return _failure("d1_b225_candidate_adapter_prepare", str(prepared.get("message", "B225 candidate adapter preparation failed.")))
	var staged := _stage_candidate(wall, wall_record, prepared)
	if not bool(staged.get("ok", false)):
		return staged

	# Recheck the exact live identities immediately before the short commit. No
	# fallible construction occurs below this point.
	var mesh_instance := wall.get_node_or_null("Mesh") as MeshInstance3D
	if mesh_instance == null or mesh_instance.mesh != staged.get("ordinary_mesh", null) \
	or _evidence_topology(evidence) != DEFAULT_WORLD_TOPOLOGY \
	or wall.has_meta(HOST_PARTITION_META) or world_root.has_meta(APPLIED_META):
		(staged.get("attachment", null) as Node).free()
		return _failure("d1_b225_candidate_commit_guard", "B225 candidate live state changed during staging.")

	var attachment := staged.get("attachment") as Node3D
	var ordinary_mesh := staged.get("ordinary_mesh") as ArrayMesh
	var candidate_mesh := staged.get("candidate_mesh") as ArrayMesh
	var candidate_metadata := _candidate_metadata(wall, roof, ordinary_mesh)
	attachment.name = "D1B225PrepromotionCandidateAttachment"
	mesh_instance.mesh = candidate_mesh
	wall.add_child(attachment)
	wall.set_meta(HOST_PARTITION_META, (staged.get("partition_metadata", {}) as Dictionary).duplicate(true))
	wall.set_meta(APPLIED_META, candidate_metadata.duplicate(true))
	evidence.set("mesh_instances", int(evidence.get("mesh_instances")) + int(CANDIDATE_DELTA.meshes))
	evidence.set("surfaces", int(evidence.get("surfaces")) + int(CANDIDATE_DELTA.surfaces))
	evidence.set("triangles", int(evidence.get("triangles")) + int(CANDIDATE_DELTA.triangles))
	world_root.set_meta(APPLIED_META, candidate_metadata.duplicate(true))
	var final_topology := _evidence_topology(evidence)
	if final_topology != CANDIDATE_WORLD_TOPOLOGY \
	or mesh_instance.mesh != candidate_mesh \
	or attachment.get_parent() != wall \
	or not _protected_roof_matches(roof, roof_record):
		# Defensive rollback for any unexpected postcommit invariant failure.
		wall.remove_child(attachment)
		mesh_instance.mesh = ordinary_mesh
		wall.remove_meta(HOST_PARTITION_META)
		wall.remove_meta(APPLIED_META)
		world_root.remove_meta(APPLIED_META)
		evidence.set("mesh_instances", int(evidence.get("mesh_instances")) - int(CANDIDATE_DELTA.meshes))
		evidence.set("surfaces", int(evidence.get("surfaces")) - int(CANDIDATE_DELTA.surfaces))
		evidence.set("triangles", int(evidence.get("triangles")) - int(CANDIDATE_DELTA.triangles))
		attachment.free()
		return _failure("d1_b225_candidate_postcommit", "B225 candidate failed its postcommit invariants and was rolled back.")
	return {
		"ok": true,
		"applied": true,
		"candidate_id": CANDIDATE_ID,
		"wall": wall,
		"roof": roof,
		"attachment": attachment,
		"default_world_topology": DEFAULT_WORLD_TOPOLOGY.duplicate(true),
		"candidate_world_topology": final_topology,
		"delta": CANDIDATE_DELTA.duplicate(true),
	}


static func _stage_candidate(wall: Node3D, record: Dictionary, prepared: Dictionary) -> Dictionary:
	var mesh_instance := wall.get_node_or_null("Mesh") as MeshInstance3D
	var ordinary_mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	if ordinary_mesh == null or ordinary_mesh.get_surface_count() != 1:
		return _failure("d1_b225_candidate_host_mesh", "B225 ordinary host mesh was not one exact surface.")
	var ordinary_arrays := ordinary_mesh.surface_get_arrays(0)
	var reversed_indices := _reversed_indices(record)
	var host_uvs := ADAPTER.host_uvs(record, prepared)
	var partition := ADAPTER.partition_host(record, reversed_indices, ordinary_mesh.surface_get_material(0), prepared)
	if host_uvs.size() != 56 or not bool(partition.get("ok", false)):
		return _failure("d1_b225_candidate_host_partition", str(partition.get("message", "B225 candidate host partition failed.")))
	var candidate_mesh := ArrayMesh.new()
	for surface_value: Variant in partition.get("surfaces", []):
		var surface := surface_value as Dictionary
		var arrays := ordinary_arrays.duplicate(true)
		arrays[Mesh.ARRAY_TEX_UV] = host_uvs
		arrays[Mesh.ARRAY_INDEX] = surface.get("indices", PackedInt32Array()) as PackedInt32Array
		candidate_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		var surface_index := candidate_mesh.get_surface_count() - 1
		candidate_mesh.surface_set_name(surface_index, str(surface.get("name", "")))
		candidate_mesh.surface_set_material(surface_index, surface.get("material", null) as Material)
	if candidate_mesh.get_surface_count() != 2 \
	or _surface_triangles(candidate_mesh, 0) != 20 \
	or _surface_triangles(candidate_mesh, 1) != 8:
		return _failure("d1_b225_candidate_staged_host", "B225 staged host topology drifted.")
	var attachment_result := ADAPTER.build_prepared(record, prepared)
	if not bool(attachment_result.get("ok", false)):
		return _failure("d1_b225_candidate_attachment", str(attachment_result.get("message", "B225 candidate attachment failed.")))
	return {
		"ok": true,
		"ordinary_mesh": ordinary_mesh,
		"candidate_mesh": candidate_mesh,
		"attachment": attachment_result.get("node") as Node3D,
		"partition_metadata": (partition.get("metadata", {}) as Dictionary).duplicate(true),
	}


static func _activation_matches(actual: Dictionary) -> bool:
	var expected := activation_request()
	if actual.size() != expected.size():
		return false
	for key: String in expected:
		if not actual.has(key):
			return false
		var left: Variant = actual[key]
		var right: Variant = expected[key]
		if left is Dictionary:
			if not right is Dictionary or not _dictionary_matches(left as Dictionary, right as Dictionary):
				return false
		elif left != right:
			return false
	return true


static func _dictionary_matches(actual: Dictionary, expected: Dictionary) -> bool:
	if actual.size() != expected.size():
		return false
	for key: Variant in expected:
		if not actual.has(key) or actual[key] != expected[key]:
			return false
	return true


static func _candidate_metadata(wall: Node3D, roof: Node3D, ordinary_mesh: ArrayMesh) -> Dictionary:
	var host_mesh_instance := wall.get_node("Mesh") as MeshInstance3D
	var host_body := wall.get_node("Collision") as StaticBody3D
	var host_shape := wall.get_node("Collision/Shape") as CollisionShape3D
	var roof_mesh_instance := roof.get_node("Mesh") as MeshInstance3D
	var roof_body := roof.get_node("Collision") as StaticBody3D
	var roof_shape := roof.get_node("Collision/Shape") as CollisionShape3D
	return {
		"schema_version": "ti.d1-b225-prepromotion-candidate-state/1",
		"candidate_id": CANDIDATE_ID,
		"stage": "prepromotion_live_ab_only",
		"canonical_entrypoint_reachable": false,
		"catalog_or_registry_promotion": false,
		"recognition_credit": false,
		"host_mesh_instance_preserved": true,
		"host_record_geometry_preserved": true,
		"host_array_mesh_resource_replaced_for_material_partition": true,
		"host_collision_and_spray_nodes_preserved": true,
		"protected_roof_nodes_preserved": true,
		"host_mesh_instance_id": host_mesh_instance.get_instance_id(),
		"ordinary_host_array_mesh_instance_id": ordinary_mesh.get_instance_id(),
		"host_body_instance_id": host_body.get_instance_id(),
		"host_shape_instance_id": host_shape.get_instance_id(),
		"roof_mesh_instance_id": roof_mesh_instance.get_instance_id(),
		"roof_body_instance_id": roof_body.get_instance_id(),
		"roof_shape_instance_id": roof_shape.get_instance_id(),
		"review_status": "pending_independent_live_visual_static_motion_and_package_review",
		"source_key": ADAPTER.SOURCE_KEY,
		"receiver_key": ADAPTER.RECEIVER_KEY,
		"config_sha256": ADAPTER.EXPECTED_CONFIG_SHA256,
	}


static func _ordinary_wall_matches(node: Node3D, record: Dictionary) -> bool:
	var proxy := node.get_parent()
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if proxy == null or not str(proxy.name).begins_with(ADAPTER.TARGET_CHUNK_ID + "__") \
	or node.get_child_count() != 2 or node.has_meta(APPLIED_META) or node.has_meta(HOST_PARTITION_META) \
	or mesh == null or mesh.get_surface_count() != 1 or mesh.surface_get_name(0) != "generated_record" \
	or mesh.surface_get_material(0) == null or mesh.surface_get_material(0).resource_name != "building_wall" \
	or _surface_triangles(mesh, 0) != 28 \
	or body == null or shape == null \
	or body.collision_layer != (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) or body.collision_mask != 0 \
	or not body.is_in_group("spray_receiver_wall") \
	or str(body.get_meta("derived_object_key", "")) != ADAPTER.RECEIVER_KEY \
	or body.get_meta("source_keys", []) != [ADAPTER.SOURCE_KEY] \
	or not _mesh_arrays_match_record(mesh.surface_get_arrays(0), record) \
	or not _collision_faces_match(shape.get_faces(), record):
		return false
	return str(node.get_meta("derived_object_key", "")) == ADAPTER.RECEIVER_KEY \
		and node.get_meta("source_keys", []) == [ADAPTER.SOURCE_KEY]


static func _protected_roof_matches(node: Node3D, record: Dictionary) -> bool:
	var proxy := node.get_parent()
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	return proxy != null and str(proxy.name).begins_with(ADAPTER.TARGET_CHUNK_ID + "__") \
		and node.get_child_count() == 2 and not node.has_meta(APPLIED_META) \
		and mesh != null and mesh.get_surface_count() == 1 and mesh.surface_get_name(0) == "generated_record" \
		and mesh.surface_get_material(0) != null and mesh.surface_get_material(0).resource_name == "building_roof" \
		and _surface_triangles(mesh, 0) == 2 and _mesh_arrays_match_record(mesh.surface_get_arrays(0), record) \
		and body != null and shape != null \
		and body.collision_layer == (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) and body.collision_mask == 0 \
		and not body.is_in_group("spray_receiver_wall") \
		and str(body.get_meta("receiver_kind", "invalid")) == "none" \
		and str(body.get_meta("derived_object_key", "")) == ADAPTER.ROOF_KEY \
		and body.get_meta("source_keys", []) == [ADAPTER.SOURCE_KEY] \
		and _collision_faces_match(shape.get_faces(), record)


static func _mesh_arrays_match_record(arrays: Array, record: Dictionary) -> bool:
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var uvs := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	var source_vertices := record.get("vertices", []) as Array
	var source_normals := record.get("normals", []) as Array
	var source_uvs := record.get("uvs", []) as Array
	if vertices.size() * 3 != source_vertices.size() or normals.size() * 3 != source_normals.size() \
	or uvs.size() * 2 != source_uvs.size() or indices != _reversed_indices(record):
		return false
	for index in vertices.size():
		var scalar := index * 3
		var expected_normal := Vector3(float(source_normals[scalar]), float(source_normals[scalar + 1]), float(source_normals[scalar + 2])).normalized()
		if not vertices[index].is_equal_approx(Vector3(float(source_vertices[scalar]), float(source_vertices[scalar + 1]), float(source_vertices[scalar + 2]))) \
		or absf(normals[index].length() - 1.0) > 0.0001 \
		or normals[index].normalized().dot(expected_normal) < 0.999999:
			return false
	for index in uvs.size():
		var scalar := index * 2
		if not uvs[index].is_equal_approx(Vector2(float(source_uvs[scalar]), float(source_uvs[scalar + 1]))):
			return false
	return true


static func _collision_faces_match(actual: PackedVector3Array, record: Dictionary) -> bool:
	var vertices := record.get("vertices", []) as Array
	var indices := _reversed_indices(record)
	if actual.size() != indices.size():
		return false
	for index in indices.size():
		var scalar := int(indices[index]) * 3
		var expected := Vector3(float(vertices[scalar]), float(vertices[scalar + 1]), float(vertices[scalar + 2]))
		if not actual[index].is_equal_approx(expected):
			return false
	return true


static func _record_roots(root_node: Node, object_key: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if str(node.get_meta("derived_object_key", "")) == object_key \
		and node.get_node_or_null("Mesh") is MeshInstance3D:
			result.append(node as Node3D)
	return result


static func _candidate_nodes(root_node: Node) -> Array[Node]:
	var result: Array[Node] = []
	for node: Node in root_node.find_children("*", "", true, false):
		if node.has_meta(APPLIED_META) \
		or node.name in ["D1B225PrepromotionCandidateAttachment", "D1B225LiveAttachment"]:
			result.append(node)
	return result


static func _evidence_topology(evidence: Node) -> Dictionary:
	return {
		"rows": int(evidence.get("playable_rows")),
		"meshes": int(evidence.get("mesh_instances")),
		"surfaces": int(evidence.get("surfaces")),
		"triangles": int(evidence.get("triangles")),
		"bodies": int(evidence.get("static_bodies")),
		"shapes": int(evidence.get("shapes")),
	}


static func _record_for(chunk: Dictionary, object_key: String) -> Dictionary:
	for value: Variant in chunk.get("records", []):
		if value is Dictionary and str((value as Dictionary).get("object_key", "")) == object_key:
			return value as Dictionary
	return {}


static func _reversed_indices(record: Dictionary) -> PackedInt32Array:
	var result := PackedInt32Array()
	var source := record.get("indices", []) as Array
	for offset in range(0, source.size(), 3):
		result.append_array(PackedInt32Array([int(source[offset]), int(source[offset + 2]), int(source[offset + 1])]))
	return result


static func _surface_triangles(mesh: ArrayMesh, surface: int) -> int:
	return int(((mesh.surface_get_arrays(surface) as Array)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)


static func _load_json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


static func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "applied": false, "code": code, "message": message, "source_keys": [ADAPTER.SOURCE_KEY]}
