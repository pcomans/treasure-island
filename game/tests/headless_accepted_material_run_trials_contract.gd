extends SceneTree

const NAVY_CHAPEL_187_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd")

const MANIFEST_PATH := "res://generated/world/manifest.json"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const YMCA_REVIEW_PATH := "res://discovery/facades/BATCH_02_04_MATERIAL_CORRECTION_REVIEW.md"
const YMCA_MAPPING_PATH := "res://discovery/facades/BATCH_02_RUN_MAPPING.json"
const YMCA_REGISTRY_PATH := "res://game/resources/facades/batch_02_material_registry.json"
const YMCA_CORRECTION_MANIFEST_PATH := "res://evidence/first-playable/batch-02-04-material-corrections-2026-08-29/treasure-island-community-ymca/capture-manifest.json"
const YMCA_INVENTORY_PATH := "res://discovery/FACADE_RECEIVER_INVENTORY.json"
const YMCA_REVIEW_SHA256 := "50f5863a1320a7b5d74e56ffa0612930657fa7060d83ba7f1f455c334bd03e99"
const YMCA_MAPPING_SHA256 := "d076ee125168cd3dfe499bc56e94c324019d7ba70bb731b9c23c045ca6759b5f"
const YMCA_REGISTRY_SHA256 := "e7d1167869640867e2857de1f08df81e878e68230b59feff3fb947b16ff56cb7"
const YMCA_CORRECTION_MANIFEST_SHA256 := "d02fcbe38c56eea263900f89bda13eba044a4ae0af9621f5f1b8da76a465808b"
const YMCA_INVENTORY_SHA256 := "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f"
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_BUILDING_WALL := 1 << 1
const EXPECTED_WORLD_MESHES := 944
const EXPECTED_WORLD_SURFACES := 957
const EXPECTED_WORLD_TRIANGLES := 64572

const TARGETS := [
	{
		"source_key": "w291189336",
		"receiver_key": "building:w291189336:wall",
		"chunk": "res://generated/world/chunks/x_-1__z_2.json",
		"chunk_hash": "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
		"runs": [9, 10],
		"length_m": 16.362,
		"material": "res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
		"material_hash": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5",
	},
	{
		"source_key": "w291189926",
		"receiver_key": "building:w291189926:wall",
		"chunk": "res://generated/world/chunks/x_0__z_1.json",
		"chunk_hash": "a35f63a877588d198e0e905167968bf9948f4616c16e708a6799d0e6c1bde00a",
		"runs": [0, 1, 2, 3, 4, 5],
		"length_m": 49.124,
		"material": "res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres",
		"material_hash": "fb50d3989b7aa41421753ad4db5d195366d9a2c25c15087e5e3a2b7863c69602",
	},
	{
		"source_key": "w34313547",
		"receiver_key": "building:w34313547:wall",
		"chunk": "res://generated/world/chunks/x_0__z_-2.json",
		"chunk_hash": "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456",
		"runs": [3, 4, 5, 6, 7, 8, 9, 10, 11],
		"length_m": 101.046,
		"material": "res://game/resources/materials/world/ti_ymca/ti_ymca_primary.tres",
		"material_hash": "b5e44afcf4feb6df6ffba46f4e3b60a25fa6043c07c12c33e31c483cb2bf2399",
		"shader": "res://game/resources/materials/world/ti_ymca/ti_ymca_wall_tangent_aperiodic_field.gdshader",
		"field_kind": 5,
		"relief": 0.08,
	},
]

const REJECTED_FIRE_STATION := {
	"source_key": "w764313741",
	"receiver_key": "building:w764313741:wall",
	"chunk": "res://generated/world/chunks/x_0__z_-2.json",
	"chunk_hash": "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456",
	"rejected_runs": [0, 1, 2, 3, 5, 6, 8, 9, 24, 25],
	"rejected_length_m": 76.157,
	"material": "res://game/resources/materials/world/fire_station_48/fire_station_48_primary.tres",
	"material_hash": "515135c3d0da6bb8eb8681e69d7e3f7818d896d948fe5dcc7c2bd8c6d076b188",
	"review": "res://discovery/facades/ACCEPTED_MATERIAL_RUN_TRIALS_ART_REVIEW.md",
}

const PROTECTED_CORRECTION_TARGETS := [
	{"key": "building:w34313548:wall", "chunk": "res://generated/world/chunks/x_1__z_-2.json"},
	{"key": "building:w34313546:wall", "chunk": "res://generated/world/chunks/x_0__z_-2.json"},
	{"key": "building:w34313569:wall", "chunk": "res://generated/world/chunks/x_-1__z_-4.json"},
	{"key": "building:w95934092:wall", "chunk": "res://generated/world/chunks/x_-3__z_-2.json"},
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "Generated manifest bytes drifted."):
		_finish()
		return
	if not _require(_ymca_lifecycle_inputs_match(), "YMCA correction acceptance, exact run mapping, registry, correction evidence, or live-trial inventory provenance drifted."):
		_finish()
		return
	var accepted_keys := AcceptedMaterialRunTrials.TARGETS.keys()
	accepted_keys.sort()
	if not _require(accepted_keys == ["building:w291189336:wall", "building:w291189926:wall", "building:w34313547:wall"], "The live exact-run target set must contain only Chapel, Dormitory, and YMCA."):
		_finish()
		return
	var batch_06_keys := AcceptedMaterialRunTrials.BATCH_06_ACCEPTED_TARGETS.keys()
	batch_06_keys.sort()
	if not _require(batch_06_keys == ["building:w291196370:wall", "building:w34313515:wall", "building:w34313520:wall", "building:w34313525:wall", "building:w34313564:wall"], "The Batch 06 live exact-field receiver set broadened or narrowed."):
		_finish()
		return
	for receiver_key: String in batch_06_keys:
		var metadata := AcceptedMaterialRunTrials.metadata_for(receiver_key) as Dictionary
		var expected_modules := 5 if receiver_key == "building:w34313564:wall" else (4 if receiver_key in ["building:w34313515:wall", "building:w34313525:wall"] else (3 if receiver_key == "building:w291196370:wall" else 1))
		# This byte-protected helper records integration-time provenance; current mutable
		# lifecycle acceptance is asserted from the canonical inventory by Batch 06 and
		# the focused w34313520/w34313525 live contracts.
		var integration_time_status := "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending" if receiver_key in ["building:w34313520:wall", "building:w34313525:wall"] else AcceptedMaterialRunTrials.BATCH_06_ACCEPTED_STATUS
		if not _require(str(metadata.get("status", "")) == integration_time_status \
		and int(metadata.get("modules", -1)) == expected_modules \
		and int(metadata.get("standalone_modules_live", -1)) == expected_modules, "Batch 06 accepted field/module metadata drifted: %s." % receiver_key):
			_finish()
			return
	var builder := WorldChunkBuilder.new()
	for target_value: Variant in TARGETS:
		var target := target_value as Dictionary
		if not _require(_asset_and_chunk_hashes_match(target), "Reviewed resource or generated chunk bytes drifted for %s." % str(target.source_key)):
			_finish()
			return
		# Chapel's accepted material remains an input to the accepted paired hero,
		# but current construction intentionally rejects an unpaired wall-only build.
		# The actual-world branch below validates that promoted material in the live
		# replacement; the two still-generic targets retain this isolated partition test.
		if str(target.source_key) == "w291189336":
			continue
		var record := _load_record(str(target.chunk), str(target.receiver_key))
		var first_result := builder._build_record(record, false)
		var second_result := builder._build_record(record, false)
		if not _require(bool(first_result.get("ok", false)) and bool(second_result.get("ok", false)), "Accepted material run build failed for %s." % str(target.source_key)):
			_free_result(first_result)
			_free_result(second_result)
			_finish()
			return
		var first := first_result.node as Node3D
		var second := second_result.node as Node3D
		if not _require(_target_receiver_matches(first, record, target), "Exact run/material/geometry/physics contract failed for %s." % str(target.source_key)) \
		or not _require(_two_builds_match(first, second), "Accepted material run partition is nondeterministic for %s." % str(target.source_key)):
			first.free()
			second.free()
			_finish()
			return
		first.free()
		second.free()
	if not _require(_asset_and_chunk_hashes_match(REJECTED_FIRE_STATION), "Rejected Fire Station prototype or generated chunk bytes drifted."):
		_finish()
		return
	var fire_record := _load_record(str(REJECTED_FIRE_STATION.chunk), str(REJECTED_FIRE_STATION.receiver_key))
	var fire_first_result := builder._build_record(fire_record, false)
	var fire_second_result := builder._build_record(fire_record, false)
	if not _require(bool(fire_first_result.get("ok", false)) and bool(fire_second_result.get("ok", false)), "Rejected Fire Station placeholder rebuild failed."):
		_free_result(fire_first_result)
		_free_result(fire_second_result)
		_finish()
		return
	var fire_first := fire_first_result.node as Node3D
	var fire_second := fire_second_result.node as Node3D
	if not _require(_rejected_fire_station_matches(fire_first, fire_record), "Fire Station still has a live accepted-material surface or its placeholder/physics contract drifted.") \
	or not _require(_two_builds_match(fire_first, fire_second), "Rejected Fire Station placeholder rebuild is nondeterministic."):
		fire_first.free()
		fire_second.free()
		_finish()
		return
	fire_first.free()
	fire_second.free()
	for control_value: Variant in PROTECTED_CORRECTION_TARGETS:
		var control := control_value as Dictionary
		if not _require(_protected_target_remains_generic(builder, control), "Correction candidate gained a live material or facade: %s." % str(control.key)):
			_finish()
			return
	var full_world := await _whole_island_matches()
	if not _require(bool(full_world.get("ok", false)), str(full_world.get("message", "Whole-island load failed."))):
		_finish()
		return
	print("PASS: retained non-Building-1 homogeneous fields remain unchanged; historical Building 1 field/module provenance stays byte-stable while accepted Building 1/Building 3/Isle House/Navy Chapel runtime replacements remain exact, Fire Station and protected candidates remain unchanged, and the whole island is 735/944/957/64,572/466")
	_finish()


func _asset_and_chunk_hashes_match(target: Dictionary) -> bool:
	if FileAccess.get_sha256(str(target.chunk)) != str(target.chunk_hash) \
	or FileAccess.get_sha256(str(target.material)) != str(target.material_hash):
		return false
	var material := load(str(target.material)) as ShaderMaterial
	var expected_shader := str(target.get("shader", "res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader"))
	var expected_field_kind := int(target.get("field_kind", 4))
	var expected_relief := float(target.get("relief", 0.0))
	return material != null and material.resource_path == str(target.material) \
		and material.shader != null \
		and material.shader.resource_path == expected_shader \
		and int(material.get_shader_parameter("field_kind")) == expected_field_kind \
		and is_equal_approx(float(material.get_shader_parameter("relief_strength")), expected_relief)


func _ymca_lifecycle_inputs_match() -> bool:
	var hashes := {
		YMCA_REVIEW_PATH: YMCA_REVIEW_SHA256,
		YMCA_MAPPING_PATH: YMCA_MAPPING_SHA256,
		YMCA_REGISTRY_PATH: YMCA_REGISTRY_SHA256,
		YMCA_CORRECTION_MANIFEST_PATH: YMCA_CORRECTION_MANIFEST_SHA256,
		YMCA_INVENTORY_PATH: YMCA_INVENTORY_SHA256,
	}
	for path: String in hashes:
		var actual_hash := FileAccess.get_sha256(path)
		if actual_hash != str(hashes[path]):
			push_error("YMCA lifecycle hash drift at %s: expected %s, got %s." % [path, str(hashes[path]), actual_hash])
			return false
	var review := FileAccess.get_file_as_string(YMCA_REVIEW_PATH)
	if not "C1" in review or not "Correction passes" in review \
	or not "building:w34313547:wall`, runs `3..11`, `101.046 m" in review \
	or not "pending independent exact-receiver review" in review:
		push_error("YMCA review acceptance/scope text drifted.")
		return false
	var mapping := JSON.parse_string(FileAccess.get_file_as_string(YMCA_MAPPING_PATH)) as Dictionary
	var mapped_target := {}
	for value: Variant in mapping.get("targets", []):
		if str((value as Dictionary).get("source_key", "")) == "w34313547":
			mapped_target = value as Dictionary
			break
	if mapped_target.is_empty() \
	or str(mapped_target.get("receiver_object_key", "")) != "building:w34313547:wall" \
	or _int_array((mapped_target.get("safe_runtime_scope", {}) as Dictionary).get("allowed_run_indices", []) as Array) != [3, 4, 5, 6, 7, 8, 9, 10, 11]:
		push_error("YMCA exact-run mapping identity or allowed run set drifted.")
		return false
	var correction := JSON.parse_string(FileAccess.get_file_as_string(YMCA_CORRECTION_MANIFEST_PATH)) as Dictionary
	var correction_matches := str(correction.get("correction_id", "")) == "C1" \
		and str(correction.get("source_key", "")) == "w34313547" \
		and str(correction.get("receiver_key", "")) == "building:w34313547:wall" \
		and str(correction.get("material_sha256", "")) == "c44f1f2e1d12acdda1cd79ca47e4a0188a8543377c1d0ff7742c69d7d01c5681" \
		and not bool(correction.get("runtime_attachment", true))
	if not correction_matches:
		push_error("YMCA C1 correction manifest identity drifted: %s." % JSON.stringify(correction))
	return correction_matches


func _target_receiver_matches(node: Node3D, record: Dictionary, target: Dictionary) -> bool:
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if mesh_instance == null or body == null or shape == null or not (mesh_instance.mesh is ArrayMesh):
		return false
	var mesh := mesh_instance.mesh as ArrayMesh
	if node.get_child_count() != 2 or mesh.get_surface_count() != 2 \
	or mesh.surface_get_name(0) != AcceptedMaterialRunTrials.PLACEHOLDER_SURFACE_NAME \
	or mesh.surface_get_name(1) != AcceptedMaterialRunTrials.ACCEPTED_SURFACE_NAME:
		return false
	var placeholder_material := mesh.surface_get_material(0) as StandardMaterial3D
	var accepted_material := mesh.surface_get_material(1) as ShaderMaterial
	if placeholder_material == null or placeholder_material.resource_name != "building_wall" \
	or accepted_material == null or accepted_material.resource_path != str(target.material):
		return false
	var accepted_runs := _runs_for_surface(mesh, 1)
	var placeholder_runs := _runs_for_surface(mesh, 0)
	var expected_runs := _int_array(target.runs as Array)
	var all_expected_runs: Array[int] = []
	for run_index in int(record.exterior_foundation_segments):
		all_expected_runs.append(run_index)
	var placeholder_expected := all_expected_runs.filter(func(run_index: int) -> bool: return not expected_runs.has(run_index))
	if accepted_runs != expected_runs or placeholder_runs != placeholder_expected:
		return false
	var metadata := node.get_meta("accepted_material_run_trial", {}) as Dictionary
	if str(metadata.get("source_key", "")) != str(target.source_key) \
	or str(metadata.get("receiver_key", "")) != str(target.receiver_key) \
	or _int_array(metadata.get("accepted_runs", []) as Array) != expected_runs \
	or str(metadata.get("material_path", "")) != str(target.material) \
	or int(metadata.get("modules", -1)) != 0 \
	or not is_equal_approx(float(metadata.get("accepted_length_m", 0.0)), float(target.length_m)):
		return false
	if absf(_run_length(record, expected_runs) - float(target.length_m)) > 0.002:
		return false
	var mesh_triangles := _triangle_signatures_for_mesh(mesh)
	var collision_triangles := _triangle_signatures_for_faces(shape.get_faces())
	if mesh_triangles.size() != (record.indices as Array).size() / 3 \
	or collision_triangles.size() != mesh_triangles.size() \
	or _sorted_keys(mesh_triangles) != _sorted_keys(collision_triangles):
		return false
	return mesh.get_faces().size() == (record.indices as Array).size() \
		and shape.get_faces().size() == (record.indices as Array).size() \
		and mesh_instance.layers == RENDER_BUILDING_WALL \
		and body.collision_layer == (1 | PHYSICS_SPRAY_SURFACE) and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") \
		and str(body.get_meta("receiver_kind", "")) == "building_wall" \
		and str(body.get_meta("derived_object_key", "")) == str(target.receiver_key) \
		and body.get_meta("source_keys", []) == [str(target.source_key)] \
		and (node.find_children("*", "MeshInstance3D", true, false) as Array).size() == 1 \
		and (node.find_children("*", "CollisionObject3D", true, false) as Array).size() == 1 \
		and (node.find_children("*", "NavigationRegion3D", true, false) as Array).is_empty() \
		and (node.find_children("*Facade*", "Node", true, false) as Array).is_empty()


func _rejected_fire_station_matches(node: Node3D, record: Dictionary) -> bool:
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if mesh_instance == null or body == null or shape == null or not (mesh_instance.mesh is ArrayMesh):
		return false
	var mesh := mesh_instance.mesh as ArrayMesh
	var material := mesh.surface_get_material(0) as StandardMaterial3D if mesh.get_surface_count() == 1 else null
	var expected_runs: Array[int] = []
	for run_index in int(record.exterior_foundation_segments):
		expected_runs.append(run_index)
	var render_triangles := _triangle_signatures_for_mesh(mesh)
	var collision_triangles := _triangle_signatures_for_faces(shape.get_faces())
	return not AcceptedMaterialRunTrials.matches_record(record) \
		and AcceptedMaterialRunTrials.metadata_for(str(REJECTED_FIRE_STATION.receiver_key)).is_empty() \
		and not node.has_meta("accepted_material_run_trial") \
		and node.get_child_count() == 2 \
		and mesh.get_surface_count() == 1 \
		and mesh.surface_get_name(0) == "generated_record" \
		and material != null and material.resource_name == "building_wall" \
		and _runs_for_surface(mesh, 0) == expected_runs \
		and render_triangles.size() == (record.indices as Array).size() / 3 \
		and _sorted_keys(render_triangles) == _sorted_keys(collision_triangles) \
		and mesh.get_faces().size() == (record.indices as Array).size() \
		and shape.get_faces().size() == (record.indices as Array).size() \
		and mesh_instance.layers == RENDER_BUILDING_WALL \
		and body.collision_layer == (1 | PHYSICS_SPRAY_SURFACE) and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") \
		and str(body.get_meta("derived_object_key", "")) == str(REJECTED_FIRE_STATION.receiver_key) \
		and body.get_meta("source_keys", []) == [str(REJECTED_FIRE_STATION.source_key)] \
		and (node.find_children("*", "MeshInstance3D", true, false) as Array).size() == 1 \
		and (node.find_children("*", "CollisionObject3D", true, false) as Array).size() == 1 \
		and (node.find_children("*", "NavigationRegion3D", true, false) as Array).is_empty() \
		and (node.find_children("*Facade*", "Node", true, false) as Array).is_empty()


func _runs_for_surface(mesh: ArrayMesh, surface_index: int) -> Array[int]:
	var arrays := mesh.surface_get_arrays(surface_index)
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	var counts := {}
	for vertex_index: int in indices:
		var run_index := vertex_index / 4
		counts[run_index] = int(counts.get(run_index, 0)) + 1
	var runs: Array[int] = []
	for run_value: Variant in counts.keys():
		var run_index := int(run_value)
		if int(counts[run_index]) != 6:
			return []
		runs.append(run_index)
	runs.sort()
	return runs


func _run_length(record: Dictionary, runs: Array[int]) -> float:
	var values := record.vertices as Array
	var result := 0.0
	for run_index: int in runs:
		var offset := run_index * 12
		var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
		var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
		result += Vector2(start.x, start.z).distance_to(Vector2(end.x, end.z))
	return result


func _triangle_signatures_for_mesh(mesh: ArrayMesh) -> Dictionary:
	var signatures := {}
	for surface_index in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(surface_index)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		for offset in range(0, indices.size(), 3):
			var signature := _triangle_signature(vertices[indices[offset]], vertices[indices[offset + 1]], vertices[indices[offset + 2]])
			if signatures.has(signature):
				return {}
			signatures[signature] = true
	return signatures


func _triangle_signatures_for_faces(faces: PackedVector3Array) -> Dictionary:
	var signatures := {}
	for offset in range(0, faces.size(), 3):
		var signature := _triangle_signature(faces[offset], faces[offset + 1], faces[offset + 2])
		if signatures.has(signature):
			return {}
		signatures[signature] = true
	return signatures


func _triangle_signature(a: Vector3, b: Vector3, c: Vector3) -> String:
	var points := [_vector_signature(a), _vector_signature(b), _vector_signature(c)]
	points.sort()
	return "%s|%s|%s" % points


func _vector_signature(value: Vector3) -> String:
	return "%.6f,%.6f,%.6f" % [value.x, value.y, value.z]


func _sorted_keys(values: Dictionary) -> Array:
	var keys := values.keys()
	keys.sort()
	return keys


func _two_builds_match(first: Node3D, second: Node3D) -> bool:
	var first_mesh := (first.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	var second_mesh := (second.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	if first_mesh.get_surface_count() != second_mesh.get_surface_count():
		return false
	for surface_index in first_mesh.get_surface_count():
		if first_mesh.surface_get_name(surface_index) != second_mesh.surface_get_name(surface_index) \
		or first_mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] != second_mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] \
		or first_mesh.surface_get_material(surface_index).resource_path != second_mesh.surface_get_material(surface_index).resource_path:
			return false
	return (first.get_node("Collision/Shape") as CollisionShape3D).shape.get_faces() == (second.get_node("Collision/Shape") as CollisionShape3D).shape.get_faces()


func _protected_target_remains_generic(builder: WorldChunkBuilder, control: Dictionary) -> bool:
	var record := _load_record(str(control.chunk), str(control.key))
	var result := builder._build_record(record, false)
	if not bool(result.get("ok", false)):
		_free_result(result)
		return false
	var node := result.node as Node3D
	var mesh := (node.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	var matches := node.get_child_count() == 2 and not node.has_meta("accepted_material_run_trial") \
		and mesh.get_surface_count() == 1 and mesh.surface_get_material(0).resource_name == "building_wall" \
		and (node.find_children("*Facade*", "Node", true, false) as Array).is_empty()
	node.free()
	return matches


func _whole_island_matches() -> Dictionary:
	var packed := load("res://game/scenes/world/world_root.tscn") as PackedScene
	if packed == null:
		return {"ok": false, "message": "Could not load WorldRoot."}
	var world := packed.instantiate() as WorldLoader
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys}))
	root.add_child(world)
	world.load_world(MANIFEST_PATH)
	var wait_started := Time.get_ticks_msec()
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - wait_started < 30000:
		await process_frame
	var evidence := world.get_runtime_evidence()
	var ok := failures.is_empty() and reports.size() == 1 and evidence != null \
		and evidence.mesh_instances == EXPECTED_WORLD_MESHES and evidence.surfaces == EXPECTED_WORLD_SURFACES \
		and evidence.triangles == EXPECTED_WORLD_TRIANGLES and evidence.static_bodies == 466 and evidence.shapes == 466
	if ok:
		for target_value: Variant in TARGETS:
			var target := target_value as Dictionary
			var nodes := _nodes_for_key(world, str(target.receiver_key))
			var record := _load_record(str(target.chunk), str(target.receiver_key))
			if nodes.size() != 1 or not _current_target_receiver_matches(nodes[0] as Node3D, record, target):
				ok = false
				break
	if ok:
		var fire_nodes := _nodes_for_key(world, str(REJECTED_FIRE_STATION.receiver_key))
		var fire_record := _load_record(str(REJECTED_FIRE_STATION.chunk), str(REJECTED_FIRE_STATION.receiver_key))
		ok = fire_nodes.size() == 1 and _rejected_fire_station_matches(fire_nodes[0] as Node3D, fire_record)
	root.remove_child(world)
	world.free()
	return {"ok": ok, "message": "Whole-island load mismatch: failures=%s reports=%d surfaces=%s" % [failures, reports.size(), evidence.surfaces if evidence != null else "null"]}


func _current_target_receiver_matches(node: Node3D, record: Dictionary, target: Dictionary) -> bool:
	if str(target.receiver_key) != "building:w291189336:wall":
		return _target_receiver_matches(node, record, target)
	var metadata := node.get_meta("navy_chapel_187_live_replacement", {}) as Dictionary
	return node.get_node_or_null("Mesh") == null \
		and NAVY_CHAPEL_187_LIVE_REPLACEMENT.material_semantics_match(node) \
		and str(metadata.get("geometry_signature", "")) == NAVY_CHAPEL_187_LIVE_REPLACEMENT.EXPECTED_GEOMETRY_SIGNATURE \
		and str(metadata.get("live_ownership_signature", "")) == NAVY_CHAPEL_187_LIVE_REPLACEMENT.EXPECTED_LIVE_OWNERSHIP_SIGNATURE \
		and not bool(metadata.get("fallback_allowed", true)) \
		and not bool(metadata.get("stack_allowed", true))


func _nodes_for_key(root_node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if str(node.get_meta("derived_object_key", "")) == key and node.get_parent() != null and str(node.get_parent().name).contains("__"):
			result.append(node)
	return result


func _load_record(chunk_path: String, object_key: String) -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(chunk_path)) as Dictionary
	for value: Variant in chunk.records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == object_key:
			return record
	return {}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _free_result(result: Dictionary) -> void:
	var node := result.get("node", null) as Node
	if node != null and not node.is_inside_tree():
		node.free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
