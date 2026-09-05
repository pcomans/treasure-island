extends SceneTree

const ADAPTER := preload("res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd")
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const WALL_KEY := "building:w291189336:wall"
const ROOF_KEY := "building:w291189336:roof"
const SOURCE_KEY := "w291189336"
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const EXPECTED_WORLD_TOPOLOGY := {
	"rows": 735, "meshes": 944, "surfaces": 957, "triangles": 64572,
	"bodies": 466, "shapes": 466,
}
const EXPECTED_HASHES := {
	CHUNK_PATH: "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	"res://discovery/facades/p3_reference_packets/w291189336_navy_chapel_building_187.md": "7eb592503ce8e276c38ef3ecaf7f2d3dd17e1eeb32adbe45d1059c5cb4693330",
	"res://evidence/first-playable/navy-chapel-187-standalone-hero-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md": "4232ad42b3600b1d7f945c5d51325bb9698c366e07eb1ddea3fd90f3f49235c6",
	"res://evidence/first-playable/navy-chapel-187-standalone-hero-2026-09-04/capture-manifest.json": "a7e551d1bbadaef3ff61f6fbb27e5ac93af3ba997103ddc1dd00041c8229cd28",
	"res://evidence/first-playable/navy-chapel-187-live-replacement-2026-09-04/INDEPENDENT_LIVE_BAR_RAISER_REVIEW.md": "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9",
	"res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd": "067c12e29c9fd352915ef2a501fcd7687b450081c79a4281d63bbfef1c19e7db",
	"res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json": "c8f2ab09f3943a5ec8abea7cb9a108f49990bff1d83003c3b3622187a269dea2",
	"res://discovery/facades/facade-recognition-catalog.json": "ab8797e86d5985c4b64670a22577394656c6388bb463f83c157a411663fa7b57",
	"res://game/resources/facades/facade-runtime-registry.json": "65edf085437bc3fa2b22869406cc8a2c33297b6cc9d48b205e301e367efc734b",
}
const PACKAGE_FILES := [
	"res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd",
	"res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd",
	"res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json",
	"res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(_hashes_match(), "A frozen Chapel source, approval receipt, independent live receipt, or current 6/213 registry authority drifted.") \
	or not _require(ADAPTER.source_dependency_hashes_match(), "An approved Chapel source dependency byte drifted.") \
	or not _require(_package_boundary_is_clean(), "The executable Chapel closure contains a URL, private/source path, or source-pixel reference."):
		_finish(null)
		return
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	var records := chunk.get("records", []) as Array
	var wall := _record_for_key(records, WALL_KEY)
	var roof := _record_for_key(records, ROOF_KEY)
	if not _require(_canonical_authority_matches(wall, roof), "The full-row canonical/runtime authority pins drifted.") \
	or not _require(_adversarial_pair_contract(records, wall, roof), "The supplied-chunk pair seam accepted missing, duplicate, reordered, or field-drifted Chapel rows."):
		_finish(null)
		return
	var deterministic := _build_twice(records)
	if not _require(bool(deterministic.get("ok", false)), str(deterministic.get("message", "The paired adapter build was not deterministic."))):
		_finish(null)
		return
	var main_scene := load("res://game/scenes/main.tscn") as PackedScene
	var main := main_scene.instantiate() as GameMain if main_scene != null else null
	if not _require(main != null, "The actual main scene did not instantiate."):
		_finish(null)
		return
	var world := main.get_node("WorldRoot") as WorldLoader
	var ready: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 45000:
		await process_frame
	if not _require(failures.is_empty() and ready.size() == 1, "Actual main did not reach one clean world_ready state: %s" % [failures]):
		_finish(main)
		return
	var live := _live_nodes(world)
	if not _require(bool(live.get("ok", false)), str(live.get("message", "The live Chapel nodes did not resolve."))):
		_finish(main)
		return
	await physics_frame
	await physics_frame
	if not _require(_live_topology_matches(world), "The measured candidate world is not 735/944/957/64,572/466/466.") \
	or not _require(_live_node_contract_matches(live.wall as Node3D, live.roof as Node3D), "The actual live visual/replacement/collision ownership contract drifted.") \
	or not _require(_collision_and_spray_rays_match(live.wall as Node3D, live.roof as Node3D, wall), "Entry/roof/cap collision or wall-vs-roof spray-ray behavior drifted."):
		_finish(main)
		return
	var evidence := world.get_runtime_evidence()
	print("NAVY_CHAPEL_187_LIVE_SIGNATURES: geometry=%s ownership=%s wall_record=%s roof_record=%s" % [
		ADAPTER.EXPECTED_GEOMETRY_SIGNATURE,
		ADAPTER.EXPECTED_LIVE_OWNERSHIP_SIGNATURE,
		ADAPTER.CANONICAL_WALL_RECORD_SHA256,
		ADAPTER.CANONICAL_ROOF_RECORD_SHA256,
	])
	print("NAVY_CHAPEL_187_LIVE_TOPOLOGY: rows=%d meshes=%d surfaces=%d triangles=%d bodies=%d shapes=%d delta=+0/+4/+3/+454/+0/+0" % [
		evidence.playable_rows, evidence.mesh_instances, evidence.surfaces, evidence.triangles,
		evidence.static_bodies, evidence.shapes,
	])
	print("PASS: actual supplied Chapel wall+roof rows are consumed once without generic stack/fallback; approved visuals remain byte-pinned; collision is split into 94 wall-spray + 50 non-wall roof/cap/cross triangles; the external independent receipt binds exactly +1 physical unit in the canonical 6/213 registry while capture-time node metadata remains immutable")
	_finish(main)


func _canonical_authority_matches(wall: Dictionary, roof: Dictionary) -> bool:
	return not wall.is_empty() and not roof.is_empty() \
		and ADAPTER.CANONICAL_WALL_RECORD_SHA256 == "69769fef402b480f1626fdce47e6d4ad49ecb710dab2b2e7373e5efa5acf0080" \
		and ADAPTER.CANONICAL_ROOF_RECORD_SHA256 == "54bcd378997d0778bdaee432dc24ecdbb142c5dc5371166cf2d690ebb245b832" \
		and ADAPTER.canonical_record_signature(wall) == ADAPTER.CANONICAL_WALL_RECORD_SHA256 \
		and ADAPTER.canonical_record_signature(roof) == ADAPTER.CANONICAL_ROOF_RECORD_SHA256 \
		and ADAPTER.record_signature(wall) == ADAPTER.EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256 \
		and ADAPTER.record_signature(roof) == ADAPTER.EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256 \
		and int(wall.get("exterior_foundation_segments", -1)) == 34 \
		and int(wall.get("shared_wall_segments", -1)) == 0 \
		and str(wall.get("material_key", "")) == "building_wall" \
		and str(roof.get("material_key", "")) == "building_roof"


func _adversarial_pair_contract(records: Array, wall: Dictionary, roof: Dictionary) -> bool:
	var clean := ADAPTER.prepare_chunk_records(records)
	if not bool(clean.get("ok", false)) or not bool(clean.get("contains_target", false)):
		return false
	var reversed := records.duplicate(true)
	reversed.reverse()
	if not bool(ADAPTER.prepare_chunk_records(reversed).get("ok", false)):
		return false
	var missing_wall := _without_key(records, WALL_KEY)
	var missing_roof := _without_key(records, ROOF_KEY)
	var duplicated := records.duplicate(true)
	duplicated.append(wall.duplicate(true))
	if bool(ADAPTER.prepare_chunk_records(missing_wall).get("ok", true)) \
	or bool(ADAPTER.prepare_chunk_records(missing_roof).get("ok", true)) \
	or bool(ADAPTER.prepare_chunk_records(duplicated).get("ok", true)):
		return false
	var mutations: Array[Dictionary] = []
	for field: String in ["material_key", "exterior_foundation_segments", "shared_wall_segments", "source_keys", "object_key", "vertices"]:
		var changed_wall := wall.duplicate(true)
		match field:
			"material_key": changed_wall[field] = "building_roof"
			"exterior_foundation_segments": changed_wall[field] = 33
			"shared_wall_segments": changed_wall[field] = 1
			"source_keys": changed_wall[field] = ["w291189918"]
			"object_key": changed_wall[field] = "building:w291189918:wall"
			"vertices": (changed_wall[field] as Array)[0] = float((changed_wall[field] as Array)[0]) + 0.001
		mutations.append(changed_wall)
	var changed_roof := roof.duplicate(true)
	changed_roof["material_key"] = "building_wall"
	mutations.append(changed_roof)
	var extra_field := wall.duplicate(true)
	extra_field["unexpected_live_field"] = true
	mutations.append(extra_field)
	for changed_wall: Dictionary in mutations:
		var candidate := records.duplicate(true)
		var replace_key := WALL_KEY if str(changed_wall.get("feature_kind", "")) == "building_wall" else ROOF_KEY
		_replace_record(candidate, replace_key, changed_wall)
		if bool(ADAPTER.prepare_chunk_records(candidate).get("ok", true)):
			return false
	# Prove the real builder also fails before producing a partial/generic chunk.
	for bad_records: Array in [missing_wall, missing_roof]:
		var bad_chunk := {"chunk_id": "adversarial_chapel", "records": bad_records}
		var parents := {"ground": Node3D.new(), "roads": Node3D.new(), "buildings": Node3D.new()}
		var result := WorldChunkBuilder.new().build_chunk(bad_chunk, parents)
		for parent: Node3D in parents.values():
			parent.free()
		if bool(result.get("ok", true)) or result.has("node"):
			return false
	return true


func _build_twice(records: Array) -> Dictionary:
	var signatures: Array[String] = []
	for reverse_order in [false, true]:
		var prepared := ADAPTER.prepare_chunk_records(records)
		var plan := ADAPTER.build_chunk_plan(prepared)
		if not bool(plan.get("ok", false)):
			return plan
		var host := Node3D.new()
		var ordered := records.duplicate()
		if reverse_order:
			ordered.reverse()
		for record_value: Variant in ordered:
			var record := record_value as Dictionary
			if not ADAPTER.claims_record(record):
				continue
			var result := ADAPTER.consume_record(record, plan)
			if not bool(result.get("ok", false)):
				host.free()
				ADAPTER.free_unconsumed(plan)
				return result
			host.add_child(result.node as Node3D)
		if not ADAPTER.plan_was_fully_consumed(plan) or host.get_child_count() != 2:
			host.free()
			ADAPTER.free_unconsumed(plan)
			return {"ok": false, "message": "The paired plan was not consumed exactly once in either order."}
		var wall_root := _child_with_key(host, WALL_KEY)
		var roof_root := _child_with_key(host, ROOF_KEY)
		if wall_root == null or roof_root == null or not _live_node_contract_matches(wall_root, roof_root):
			host.free()
			return {"ok": false, "message": "A deterministic paired build violated its live node contract."}
		if not ADAPTER.material_semantics_match(wall_root):
			host.free()
			return {"ok": false, "message": "A deterministic paired build violated its material semantics."}
		if not reverse_order and not _material_mutation_is_rejected(wall_root):
			host.free()
			return {"ok": false, "message": "The live adapter accepted a drifted packaged material value."}
		signatures.append(str((wall_root.get_meta("navy_chapel_187_live_replacement", {}) as Dictionary).get("live_ownership_signature", "")))
		host.free()
	return {"ok": signatures.size() == 2 and signatures[0] == signatures[1] and signatures[0] == ADAPTER.EXPECTED_LIVE_OWNERSHIP_SIGNATURE}


func _material_mutation_is_rejected(wall_root: Node3D) -> bool:
	for value: Node in wall_root.find_children("*", "MeshInstance3D", true, false):
		var instance := value as MeshInstance3D
		var material := instance.mesh.surface_get_material(0)
		if material is StandardMaterial3D:
			var changed := material.duplicate() as StandardMaterial3D
			changed.roughness = 0.123
			instance.mesh.surface_set_material(0, changed)
			return not ADAPTER.material_semantics_match(wall_root)
	return false


func _live_nodes(world: WorldLoader) -> Dictionary:
	var walls := _record_roots(world, WALL_KEY)
	var roofs := _record_roots(world, ROOF_KEY)
	if walls.size() != 1 or roofs.size() != 1:
		return {"ok": false, "message": "Expected one exact live Chapel wall root and roof root, got %d/%d." % [walls.size(), roofs.size()]}
	return {"ok": true, "wall": walls[0], "roof": roofs[0]}


func _live_node_contract_matches(wall: Node3D, roof: Node3D) -> bool:
	if wall == null or roof == null \
	or wall.name != "NavyChapel187LiveWallVisualAndCollisionReplacement" \
	or roof.name != "NavyChapel187LiveRoofCollisionReplacement" \
	or wall.get_node_or_null("Mesh") != null or roof.find_children("*", "MeshInstance3D", true, false).size() != 0:
		return false
	var meshes := wall.find_children("*", "MeshInstance3D", true, false)
	var surfaces := 0
	var triangles := 0
	for value: Node in meshes:
		var mesh := (value as MeshInstance3D).mesh
		surfaces += mesh.get_surface_count()
		triangles += int(mesh.get_faces().size() / 3)
	var wall_body := wall.get_node_or_null("Collision") as StaticBody3D
	var roof_body := roof.get_node_or_null("Collision") as StaticBody3D
	var wall_shape := wall.get_node_or_null("Collision/Shape") as CollisionShape3D
	var roof_shape := roof.get_node_or_null("Collision/Shape") as CollisionShape3D
	if meshes.size() != 6 or surfaces != 6 or triangles != 540 \
	or wall_body == null or roof_body == null or wall_shape == null or roof_shape == null \
	or not (wall_shape.shape is ConcavePolygonShape3D) or not (roof_shape.shape is ConcavePolygonShape3D):
		return false
	var wall_meta := wall.get_meta("navy_chapel_187_live_replacement", {}) as Dictionary
	return (wall_shape.shape as ConcavePolygonShape3D).get_faces().size() == 94 * 3 \
		and (roof_shape.shape as ConcavePolygonShape3D).get_faces().size() == 50 * 3 \
		and wall_body.collision_layer == (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) \
		and roof_body.collision_layer == (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) \
		and wall_body.collision_mask == 0 and roof_body.collision_mask == 0 \
		and wall_body.is_in_group("spray_receiver_wall") \
		and not roof_body.is_in_group("spray_receiver_wall") \
		and str(wall_body.get_meta("receiver_kind", "")) == "building_wall" \
		and str(roof_body.get_meta("receiver_kind", "invalid")) == "none" \
		and str(wall_body.get_meta("derived_object_key", "")) == WALL_KEY \
		and str(roof_body.get_meta("derived_object_key", "")) == ROOF_KEY \
		and wall_body.get_meta("source_keys", []) == [SOURCE_KEY] \
		and roof_body.get_meta("source_keys", []) == [SOURCE_KEY] \
		and str(wall_meta.get("geometry_signature", "")) == ADAPTER.EXPECTED_GEOMETRY_SIGNATURE \
		and str(wall_meta.get("live_ownership_signature", "")) == ADAPTER.EXPECTED_LIVE_OWNERSHIP_SIGNATURE \
		and not bool(wall_meta.get("fallback_allowed", true)) \
		and not bool(wall_meta.get("stack_allowed", true)) \
		and not bool(wall_meta.get("recognition_accepted", true)) \
		and not bool(wall_meta.get("believability_accepted", true)) \
		and _count_type(wall, "CollisionObject3D") == 1 \
		and _count_type(roof, "CollisionObject3D") == 1 \
		and _count_type(wall, "NavigationRegion3D") + _count_type(roof, "NavigationRegion3D") == 0


func _collision_and_spray_rays_match(wall_root: Node3D, roof_root: Node3D, wall_record: Dictionary) -> bool:
	var basis := _chain_basis(wall_record, [9, 10])
	if basis.is_empty():
		return false
	var front := (basis.start as Vector3).lerp(basis.end as Vector3, 0.5)
	var tangent := basis.tangent as Vector3
	var outward := basis.normal as Vector3
	var entry_target := Vector3(front.x, 5.5, front.z) + outward * 0.75
	var roof_xz := front - outward * 5.0 - tangent * 4.5
	var cap_xz := front - outward * 8.5 + tangent * 0.7
	var world := wall_root.get_world_3d()
	var entry_solid := _ray(world, entry_target + outward * 10.0, entry_target - outward * 1.0, PHYSICS_WORLD_SOLID)
	var entry_spray := _ray(world, entry_target + outward * 10.0, entry_target - outward * 1.0, PHYSICS_SPRAY_SURFACE)
	var roof_solid := _ray(world, Vector3(roof_xz.x, 30.0, roof_xz.z), Vector3(roof_xz.x, 0.0, roof_xz.z), PHYSICS_WORLD_SOLID)
	var roof_spray := _ray(world, Vector3(roof_xz.x, 30.0, roof_xz.z), Vector3(roof_xz.x, 0.0, roof_xz.z), PHYSICS_SPRAY_SURFACE)
	var cap_solid := _ray(world, Vector3(cap_xz.x, 30.0, cap_xz.z), Vector3(cap_xz.x, 0.0, cap_xz.z), PHYSICS_WORLD_SOLID)
	var wall_body := wall_root.get_node("Collision") as StaticBody3D
	var roof_body := roof_root.get_node("Collision") as StaticBody3D
	return not entry_solid.is_empty() and entry_solid.collider == wall_body \
		and not entry_spray.is_empty() and entry_spray.collider == wall_body \
		and absf((entry_spray.normal as Vector3).dot(Vector3.UP)) < 0.2 \
		and str(wall_body.get_meta("receiver_kind", "")) == "building_wall" \
		and wall_body.is_in_group("spray_receiver_wall") \
		and not roof_solid.is_empty() and roof_solid.collider == roof_body \
		and not roof_spray.is_empty() and roof_spray.collider == roof_body \
		and (roof_spray.normal as Vector3).y > 0.4 \
		and str(roof_body.get_meta("receiver_kind", "invalid")) == "none" \
		and not roof_body.is_in_group("spray_receiver_wall") \
		and float((roof_solid.position as Vector3).y) > 14.04 \
		and not cap_solid.is_empty() and cap_solid.collider == roof_body \
		and (cap_solid.normal as Vector3).y > 0.25 \
		and float((cap_solid.position as Vector3).y) > 21.0


func _live_topology_matches(world: WorldLoader) -> bool:
	var evidence := world.get_runtime_evidence()
	return {"rows": evidence.playable_rows, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "bodies": evidence.static_bodies, "shapes": evidence.shapes} == EXPECTED_WORLD_TOPOLOGY


func _package_boundary_is_clean() -> bool:
	for path: String in PACKAGE_FILES:
		var lower := FileAccess.get_file_as_string(path).to_lower()
		for forbidden: String in ["http://", "https://", "file://", "/volumes/", "/users/", "res://discovery", "res://evidence", "source_assets", ".jpg", ".jpeg", ".webp"]:
			if forbidden in lower:
				return false
	return true


func _hashes_match() -> bool:
	for path: String in EXPECTED_HASHES:
		if FileAccess.get_sha256(path) != str(EXPECTED_HASHES[path]):
			push_error("Chapel authority hash drift: %s expected=%s actual=%s" % [path, EXPECTED_HASHES[path], FileAccess.get_sha256(path)])
			return false
	return true


func _record_roots(root_node: Node, key: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if node.has_meta("feature_kind") and str(node.get_meta("derived_object_key", "")) == key:
			result.append(node as Node3D)
	return result


func _child_with_key(root_node: Node, key: String) -> Node3D:
	for child: Node in root_node.get_children():
		if str(child.get_meta("derived_object_key", "")) == key:
			return child as Node3D
	return null


func _without_key(records: Array, key: String) -> Array:
	var result := records.duplicate(true)
	for index in range(result.size() - 1, -1, -1):
		if str((result[index] as Dictionary).get("object_key", "")) == key:
			result.remove_at(index)
	return result


func _replace_record(records: Array, key: String, replacement: Dictionary) -> void:
	for index in records.size():
		if str((records[index] as Dictionary).get("object_key", "")) == key:
			records[index] = replacement
			return


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _chain_basis(record: Dictionary, runs: Array) -> Dictionary:
	var first := _run_frame(record, int(runs[0]))
	var last := _run_frame(record, int(runs[runs.size() - 1]))
	return {"start": first.start, "end": last.end, "tangent": first.tangent, "normal": first.normal} if not first.is_empty() and not last.is_empty() else {}


func _run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var offset := run_index * 12
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var tangent := end - start
	tangent.y = 0.0
	return {"start": start, "end": end, "tangent": tangent.normalized(), "normal": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()}


func _ray(world: World3D, from: Vector3, to: Vector3, mask: int) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, mask)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return world.direct_space_state.intersect_ray(query)


func _count_type(root_node: Node, type_name: String) -> int:
	return root_node.find_children("*", type_name, true, false).size()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish(main: Node) -> void:
	if main != null:
		main.queue_free()
	call_deferred("_quit_after_cleanup")


func _quit_after_cleanup() -> void:
	await process_frame
	quit(1 if _failed else 0)
