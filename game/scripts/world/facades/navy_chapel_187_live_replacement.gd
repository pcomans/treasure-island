class_name NavyChapel187LiveReplacement
extends RefCounted

## Fail-closed live adapter for the independently approved Navy Chapel 187
## standalone geometry. The actual supplied chunk is pair-validated first, the
## hero visuals are built exactly once, and the collision is split into one
## wall spray receiver plus one non-wall roof/cap/cross landing receiver.

const SOURCE_KEY := "w291189336"
const WALL_KEY := "building:w291189336:wall"
const ROOF_KEY := "building:w291189336:roof"
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const CANONICAL_WALL_RECORD_SHA256 := "69769fef402b480f1626fdce47e6d4ad49ecb710dab2b2e7373e5efa5acf0080"
const CANONICAL_ROOF_RECORD_SHA256 := "54bcd378997d0778bdaee432dc24ecdbb142c5dc5371166cf2d690ebb245b832"
# Godot parses JSON numbers into runtime Variants and has a different compact
# serializer than the Node stableJson authority. These second pins hash the
# entire supplied runtime Dictionaries, including every material/ownership
# field and any unexpected extra field; the canonical hashes remain above.
const EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256 := "cf1b189da2b240065a262ef97326ec4c7b07a646162422a8799186b5e76431fe"
const EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256 := "0b66eba21c542c1a59444d77cb06e336214fb482439072f0879b3ab03e975734"
const EXPECTED_GEOMETRY_SIGNATURE := "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46"
const EXPECTED_LIVE_OWNERSHIP_SIGNATURE := "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7"
const APPROVAL_RECEIPT_ID := "navy-chapel-187-standalone-hero-independent-pass-2026-09-04"
const APPROVAL_RECEIPT_SHA256 := "4232ad42b3600b1d7f945c5d51325bb9698c366e07eb1ddea3fd90f3f49235c6"
const EXPECTED_MESH_INSTANCES := 6
const EXPECTED_SURFACES := 6
const EXPECTED_VISUAL_TRIANGLES := 540
const EXPECTED_COLLISION_TRIANGLES := 144
const EXPECTED_WALL_COLLISION_TRIANGLES := 94
const EXPECTED_ROOF_COLLISION_TRIANGLES := 50
const WALL_COLLISION_TRIANGLE_RANGES := [[0, 67], [90, 103], [132, 143]]
const ROOF_COLLISION_TRIANGLE_RANGES := [[68, 89], [104, 131]]

const PROTOTYPE := preload("res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd")

const EXECUTABLE_DEPENDENCY_HASHES := {
	"res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd": "067c12e29c9fd352915ef2a501fcd7687b450081c79a4281d63bbfef1c19e7db",
	"res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json": "c8f2ab09f3943a5ec8abea7cb9a108f49990bff1d83003c3b3622187a269dea2",
	"res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres": "91cd7ce14550bdfb6773a4013ef0db8bbb24bd5cc9d0734f6c591f23d6552206",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres": "2ee243415387c9f3d9dfd5664c0a5e13107745a83d9dcb489dd39e5aeb2ff17a",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres": "b565aa44566a0bb93d07d041b1e8331d9f35cb83ec34f6a2ec403b362311c380",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres": "253e9c2a5013f81aed446f6e55b702dea3792189658ce285726788d15376bc41",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres": "89be7fbe0feb68525c5423540d3a6f17f269567875174f23522b4e964ba737b1",
}


static func claims_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in [WALL_KEY, ROOF_KEY]


static func prepare_chunk_records(records: Array) -> Dictionary:
	var target_records: Array[Dictionary] = []
	for record_value: Variant in records:
		var record := record_value as Dictionary
		var object_key := str(record.get("object_key", ""))
		var source_keys := record.get("source_keys", []) as Array
		if object_key in [WALL_KEY, ROOF_KEY] or SOURCE_KEY in source_keys:
			target_records.append(record)
	if target_records.is_empty():
		return {"ok": true, "contains_target": false}
	if target_records.size() != 2:
		return _failure("navy_chapel_187_live_chunk_pair_count", "The supplied chunk must contain exactly the Chapel wall and roof rows together.", target_records[0])
	var wall := _record_for_key(target_records, WALL_KEY)
	var roof := _record_for_key(target_records, ROOF_KEY)
	if wall.is_empty() or roof.is_empty() or not PROTOTYPE.matches_record_pair(wall, roof):
		return _failure("navy_chapel_187_live_chunk_pair", "The supplied chunk Chapel wall+roof pair is missing, duplicated, or structurally invalid.", target_records[0])
	if canonical_record_signature(wall) != CANONICAL_WALL_RECORD_SHA256 \
	or canonical_record_signature(roof) != CANONICAL_ROOF_RECORD_SHA256 \
	or record_signature(wall) != EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256 \
	or record_signature(roof) != EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256:
		return _failure("navy_chapel_187_live_chunk_hash", "The supplied chunk Chapel wall or roof bytes drifted (wall %s, roof %s)." % [record_signature(wall), record_signature(roof)], target_records[0])
	return {"ok": true, "contains_target": true, "wall": wall, "roof": roof}


static func build_chunk_plan(prepared_pair: Dictionary) -> Dictionary:
	if not bool(prepared_pair.get("ok", false)):
		return prepared_pair
	if not bool(prepared_pair.get("contains_target", false)):
		return {"ok": true, "contains_target": false, "pending_keys": {}}
	# Exported PCKs compile/remap GDScript and material resources, so source-file
	# hashes are not a valid runtime identity. Require the complete packaged
	# resource closure here; source contracts separately pin every authoring byte,
	# while the built geometry/material semantics are checked below.
	if not runtime_dependency_closure_exists():
		return _failure("navy_chapel_187_live_dependency", "The approved Chapel executable dependency closure is incomplete.", prepared_pair.get("wall", {}) as Dictionary)
	var wall_record := prepared_pair.get("wall", {}) as Dictionary
	var roof_record := prepared_pair.get("roof", {}) as Dictionary
	if not PROTOTYPE.matches_record_pair(wall_record, roof_record) \
	or canonical_record_signature(wall_record) != CANONICAL_WALL_RECORD_SHA256 \
	or canonical_record_signature(roof_record) != CANONICAL_ROOF_RECORD_SHA256 \
	or record_signature(wall_record) != EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256 \
	or record_signature(roof_record) != EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256:
		return _failure("navy_chapel_187_live_prepared_pair", "The prepared Chapel pair drifted after chunk preflight.", wall_record)
	var pair_result := _build_paired_replacement(wall_record, roof_record)
	if not bool(pair_result.get("ok", false)):
		return pair_result
	return {
		"ok": true,
		"contains_target": true,
		"records": {WALL_KEY: pair_result.wall_result, ROOF_KEY: pair_result.roof_result},
		"pending_keys": {WALL_KEY: true, ROOF_KEY: true},
	}


static func consume_record(record: Dictionary, chunk_plan: Dictionary) -> Dictionary:
	if not claims_record(record):
		return _failure("navy_chapel_187_live_target", "The Chapel live adapter received an unrelated record.", record)
	if not bool(chunk_plan.get("ok", false)) or not bool(chunk_plan.get("contains_target", false)):
		return _failure("navy_chapel_187_live_unprepared_pair", "The Chapel live adapter requires the validated plan from this supplied chunk.", record)
	var key := str(record.object_key)
	var pending := chunk_plan.get("pending_keys", {}) as Dictionary
	var results := chunk_plan.get("records", {}) as Dictionary
	if not pending.has(key) or not results.has(key):
		return _failure("navy_chapel_187_live_duplicate_consume", "A Chapel row was missing from or consumed twice in the paired plan.", record)
	var expected_hash := EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256 if key == WALL_KEY else EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256
	var canonical_hash := CANONICAL_WALL_RECORD_SHA256 if key == WALL_KEY else CANONICAL_ROOF_RECORD_SHA256
	if record_signature(record) != expected_hash or canonical_record_signature(record) != canonical_hash:
		return _failure("navy_chapel_187_live_supplied_record", "The supplied Chapel receiver bytes differ from the sealed chunk plan.", record)
	var result := results[key] as Dictionary
	pending.erase(key)
	results.erase(key)
	return result


static func plan_was_fully_consumed(chunk_plan: Dictionary) -> bool:
	return not bool(chunk_plan.get("contains_target", false)) \
		or (chunk_plan.get("pending_keys", {}) as Dictionary).is_empty()


static func free_unconsumed(chunk_plan: Dictionary) -> void:
	var results := chunk_plan.get("records", {}) as Dictionary
	for key: Variant in results.keys():
		var result := results[key] as Dictionary
		var node := result.get("node", null) as Node
		if node != null and not node.is_inside_tree():
			node.free()
	results.clear()
	(chunk_plan.get("pending_keys", {}) as Dictionary).clear()


static func record_signature(record: Dictionary) -> String:
	return JSON.stringify(record).sha256_text()


static func canonical_record_signature(record: Dictionary) -> String:
	# Runtime port of tools/lib/world-contract.mjs stableJson: recursively sorted
	# object keys, two-space JSON indentation, array order preserved, one LF.
	return (_stable_json(record, 0) + "\n").sha256_text()


static func _stable_json(value: Variant, depth: int) -> String:
	match typeof(value):
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "true" if bool(value) else "false"
		TYPE_INT:
			return str(int(value))
		TYPE_FLOAT:
			var number := float(value)
			return str(int(number)) if number == floor(number) else JSON.stringify(number)
		TYPE_STRING, TYPE_STRING_NAME:
			return JSON.stringify(str(value))
		TYPE_ARRAY:
			var values := value as Array
			if values.is_empty():
				return "[]"
			var lines: Array[String] = []
			for item: Variant in values:
				lines.append(" ".repeat((depth + 1) * 2) + _stable_json(item, depth + 1))
			return "[\n%s\n%s]" % [",\n".join(lines), " ".repeat(depth * 2)]
		TYPE_DICTIONARY:
			var object := value as Dictionary
			if object.is_empty():
				return "{}"
			var keys: Array[String] = []
			for key: Variant in object.keys():
				keys.append(str(key))
			keys.sort()
			var lines: Array[String] = []
			for key: String in keys:
				lines.append(" ".repeat((depth + 1) * 2) + JSON.stringify(key) + ": " + _stable_json(object[key], depth + 1))
			return "{\n%s\n%s}" % [",\n".join(lines), " ".repeat(depth * 2)]
	return JSON.stringify(value)


static func _build_paired_replacement(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	var prototype_result := PROTOTYPE.build_for_records(wall_record, roof_record)
	if not bool(prototype_result.get("ok", false)):
		return _failure("navy_chapel_187_live_factory", str(prototype_result.get("message", "The approved Chapel geometry factory failed.")), wall_record)
	var wall_root := prototype_result.get("node", null) as Node3D
	if wall_root == null:
		return _failure("navy_chapel_187_live_factory_node", "The approved Chapel geometry factory returned no node.", wall_record)
	if str(wall_root.get_meta("deterministic_signature", "")) != EXPECTED_GEOMETRY_SIGNATURE:
		wall_root.free()
		return _failure("navy_chapel_187_live_signature", "The approved Chapel geometry signature drifted.", wall_record)
	if not material_semantics_match(wall_root):
		wall_root.free()
		return _failure("navy_chapel_187_live_material_semantics", "The packaged Chapel material roles or values drifted.", wall_record)
	var split := _split_collision(wall_root)
	if not bool(split.get("ok", false)):
		wall_root.free()
		return _failure("navy_chapel_187_live_collision_partition", str(split.get("message", "The Chapel collision partition failed.")), wall_record)
	var roof_root := _roof_replacement_root()
	wall_root.add_child(split.wall_body as StaticBody3D)
	roof_root.add_child(split.roof_body as StaticBody3D)
	_apply_live_root_metadata(wall_root, roof_root)
	var measured := _measure([wall_root, roof_root])
	if not _measured_contract_matches(measured):
		wall_root.free()
		roof_root.free()
		return _failure("navy_chapel_187_live_topology", "The Chapel replacement topology or ownership drifted.", wall_record)
	var ownership_signature := _live_ownership_signature()
	if ownership_signature != EXPECTED_LIVE_OWNERSHIP_SIGNATURE:
		wall_root.free()
		roof_root.free()
		return _failure("navy_chapel_187_live_ownership_signature", "The Chapel wall/roof collision ownership signature drifted (%s)." % ownership_signature, wall_record)
	var metadata := {
		"schema_version": "ti.navy-chapel-187-live-replacement/1",
		"source_key": SOURCE_KEY,
		"wall_object_key": WALL_KEY,
		"roof_object_key": ROOF_KEY,
		"canonical_wall_record_sha256": CANONICAL_WALL_RECORD_SHA256,
		"canonical_roof_record_sha256": CANONICAL_ROOF_RECORD_SHA256,
		"runtime_wall_dictionary_sha256": EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256,
		"runtime_roof_dictionary_sha256": EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256,
		"geometry_signature": EXPECTED_GEOMETRY_SIGNATURE,
		"live_ownership_signature": ownership_signature,
		"approval_receipt_id": APPROVAL_RECEIPT_ID,
		"approval_receipt_sha256": APPROVAL_RECEIPT_SHA256,
		"replacement_mode": "paired_visual_replacement_with_split_wall_and_roof_collision",
		"fallback_allowed": false,
		"stack_allowed": false,
		"structural_owner_count": 2,
		"shape_count": 2,
		"spray_owner_count": 1,
		"wall_collision_triangles": EXPECTED_WALL_COLLISION_TRIANGLES,
		"roof_collision_triangles": EXPECTED_ROOF_COLLISION_TRIANGLES,
		"roof_receiver_kind": "none",
		"roof_in_wall_spray_group": false,
		"navigation_owner_count": 0,
		"roof_landing_world_solid": true,
		"horizontal_source_footprint_changed": false,
		"recognition_accepted": false,
		"believability_accepted": false,
		"as_built_fidelity_claimed": false,
		"independent_live_review_status": "pending",
		"measured": measured.duplicate(true),
	}
	wall_root.set_meta("navy_chapel_187_live_replacement", metadata.duplicate(true))
	roof_root.set_meta("navy_chapel_187_live_replacement", metadata.duplicate(true))
	return {"ok": true, "wall_result": {
		"ok": true, "node": wall_root, "metadata": metadata,
		"mesh_instances": EXPECTED_MESH_INSTANCES, "surfaces": EXPECTED_SURFACES,
		"triangles": EXPECTED_VISUAL_TRIANGLES, "static_bodies": 1, "shapes": 1,
	}, "roof_result": {
		"ok": true, "node": roof_root, "metadata": metadata,
		"mesh_instances": 0, "surfaces": 0, "triangles": 0, "static_bodies": 1, "shapes": 1,
	}}


static func _roof_replacement_root() -> Node3D:
	var root := Node3D.new()
	root.name = "NavyChapel187LiveRoofCollisionReplacement"
	root.set_meta("derived_object_key", ROOF_KEY)
	root.set_meta("source_keys", [SOURCE_KEY])
	root.set_meta("feature_kind", "building_roof")
	root.set_meta("runtime_superseded", true)
	root.set_meta("visuals_owned_by", WALL_KEY)
	root.set_meta("replacement_mode", "paired_roof_collision_without_duplicate_visuals")
	root.set_meta("canonical_roof_record_sha256", CANONICAL_ROOF_RECORD_SHA256)
	root.set_meta("runtime_roof_dictionary_sha256", EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256)
	root.set_meta("approval_receipt_sha256", APPROVAL_RECEIPT_SHA256)
	return root


static func _apply_live_root_metadata(wall_root: Node3D, roof_root: Node3D) -> void:
	wall_root.name = "NavyChapel187LiveWallVisualAndCollisionReplacement"
	for root: Node3D in [wall_root, roof_root]:
		root.set_meta("prototype_only", false)
		root.set_meta("runtime_attachment", true)
		root.set_meta("registry_status", "not_reconciled_pending_independent_live_review")
		root.set_meta("world_builder_status", "attached_candidate_pending_independent_live_review")
		root.set_meta("technical_evidence_status", "live_capture_pending")
		root.set_meta("recognition_accepted", false)
		root.set_meta("believability_accepted", false)
		root.set_meta("runtime_supersedes_generated_placeholder", true)
		root.set_meta("superseded_object_keys", [WALL_KEY, ROOF_KEY])
		root.set_meta("canonical_wall_record_sha256", CANONICAL_WALL_RECORD_SHA256)
		root.set_meta("canonical_roof_record_sha256", CANONICAL_ROOF_RECORD_SHA256)
		root.set_meta("runtime_wall_dictionary_sha256", EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256)
		root.set_meta("runtime_roof_dictionary_sha256", EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256)
		root.set_meta("approval_receipt_sha256", APPROVAL_RECEIPT_SHA256)
	wall_root.set_meta("derived_object_key", WALL_KEY)
	wall_root.set_meta("source_keys", [SOURCE_KEY])
	wall_root.set_meta("feature_kind", "building_wall")
	for child: Node in _descendants(wall_root):
		if child is MeshInstance3D:
			child.set_meta("prototype_only", false)
			child.set_meta("runtime_attachment", true)


static func _split_collision(root: Node3D) -> Dictionary:
	var original_bodies: Array[StaticBody3D] = []
	for node: Node in _descendants(root):
		if node is StaticBody3D:
			original_bodies.append(node as StaticBody3D)
	if original_bodies.size() != 1:
		return {"ok": false, "message": "Approved Chapel factory no longer has one combined source collision body."}
	var original_body := original_bodies[0]
	if original_body.get_child_count() != 1:
		return {"ok": false, "message": "Approved Chapel combined collision body no longer has one shape node."}
	var original_shape_node := original_body.get_child(0) as CollisionShape3D
	if original_shape_node == null or not (original_shape_node.shape is ConcavePolygonShape3D):
		return {"ok": false, "message": "Approved Chapel combined collision shape is missing."}
	var combined_faces := (original_shape_node.shape as ConcavePolygonShape3D).get_faces()
	if combined_faces.size() != EXPECTED_COLLISION_TRIANGLES * 3:
		return {"ok": false, "message": "Approved Chapel combined collision face count drifted."}
	var wall_faces := PackedVector3Array()
	var roof_faces := PackedVector3Array()
	for triangle_index in EXPECTED_COLLISION_TRIANGLES:
		if _triangle_in_ranges(triangle_index, WALL_COLLISION_TRIANGLE_RANGES):
			for corner in 3:
				wall_faces.append(combined_faces[triangle_index * 3 + corner])
		else:
			for corner in 3:
				roof_faces.append(combined_faces[triangle_index * 3 + corner])
	if wall_faces.size() != EXPECTED_WALL_COLLISION_TRIANGLES * 3 \
	or roof_faces.size() != EXPECTED_ROOF_COLLISION_TRIANGLES * 3:
		return {"ok": false, "message": "Chapel wall/roof collision partition counts drifted."}
	root.remove_child(original_body)
	original_body.free()
	return {
		"ok": true,
		"wall_body": _collision_body("Collision", wall_faces, WALL_KEY, "building_wall", true),
		"roof_body": _collision_body("Collision", roof_faces, ROOF_KEY, "none", false),
	}


static func _collision_body(node_name: String, faces: PackedVector3Array, object_key: String, receiver_kind: String, spray_wall: bool) -> StaticBody3D:
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	shape.set_meta("receiver_kind", receiver_kind)
	shape.set_meta("opaque", true)
	shape.set_meta("derived_object_key", object_key)
	shape.set_meta("source_keys", [SOURCE_KEY])
	shape.set_meta("prototype_only", false)
	shape.set_meta("runtime_attachment", true)
	shape.set_meta("ownership_partition", "wall_like" if spray_wall else "roof_cap_cross_landing")
	var shape_node := CollisionShape3D.new()
	shape_node.name = "Shape"
	shape_node.shape = shape
	var body := StaticBody3D.new()
	body.name = node_name
	# Keep both opaque partitions in the spray ray mask. The roof partition has
	# receiver_kind=none and no wall group, so it blocks/rejects rather than
	# allowing a ray to pass through to an unrelated wall, matching prior roofs.
	body.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
	body.collision_mask = 0
	body.set_meta("receiver_kind", receiver_kind)
	body.set_meta("opaque", true)
	body.set_meta("derived_object_key", object_key)
	body.set_meta("source_keys", [SOURCE_KEY])
	body.set_meta("prototype_only", false)
	body.set_meta("runtime_attachment", true)
	body.set_meta("spray_ownership", "wall_receiver" if spray_wall else "none_roof_rejection_blocker")
	body.set_meta("roof_landing_world_solid", not spray_wall)
	body.set_meta("ownership_partition", "wall_like" if spray_wall else "roof_cap_cross_landing")
	if spray_wall:
		body.add_to_group("spray_receiver_wall")
	body.add_child(shape_node)
	return body


static func _triangle_in_ranges(triangle_index: int, ranges: Array) -> bool:
	for value: Variant in ranges:
		var bounds := value as Array
		if triangle_index >= int(bounds[0]) and triangle_index <= int(bounds[1]):
			return true
	return false


static func _live_ownership_signature() -> String:
	return JSON.stringify({
		"schema_version": "ti.navy-chapel-187-live-ownership/1",
		"geometry_signature": EXPECTED_GEOMETRY_SIGNATURE,
		"wall_record_sha256": CANONICAL_WALL_RECORD_SHA256,
		"roof_record_sha256": CANONICAL_ROOF_RECORD_SHA256,
		"wall_triangle_ranges": WALL_COLLISION_TRIANGLE_RANGES,
		"roof_triangle_ranges": ROOF_COLLISION_TRIANGLE_RANGES,
		"wall_collision_triangles": EXPECTED_WALL_COLLISION_TRIANGLES,
		"roof_collision_triangles": EXPECTED_ROOF_COLLISION_TRIANGLES,
		"wall_spray_owner_count": 1,
		"roof_spray_owner_count": 0,
	}).sha256_text()


static func source_dependency_hashes_match() -> bool:
	for path: String in EXECUTABLE_DEPENDENCY_HASHES:
		if FileAccess.get_sha256(path) != str(EXECUTABLE_DEPENDENCY_HASHES[path]):
			return false
	return true


static func runtime_dependency_closure_exists() -> bool:
	for path: String in EXECUTABLE_DEPENDENCY_HASHES:
		if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
			return false
	return true


static func material_semantics_match(root: Node3D) -> bool:
	var expected := {
		"ProtectedExactWallAndRearClosure": {
			"path": "res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres",
			"name": "navy_chapel_protected_neutral_nonclaim", "color": Color(0.72, 0.71, 0.68, 1.0), "roughness": 0.9,
		},
		"InferredCreamSSEGableBelfryEntry": {
			"path": "res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres",
			"name": "navy_chapel_inferred_cream_structure_not_material_accepted", "color": Color(0.82, 0.77, 0.65, 1.0), "roughness": 0.8,
		},
		"NeutralRoofAndCap": {
			"path": "res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres",
			"name": "navy_chapel_neutral_roof_color_unasserted", "color": Color(0.16, 0.17, 0.16, 1.0), "roughness": 0.86,
		},
		"ObservedPaleTrim": {
			"path": "res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres",
			"name": "navy_chapel_observed_pale_trim_proxy", "color": Color(0.88, 0.85, 0.74, 1.0), "roughness": 0.8,
		},
		"OpaqueExteriorOpenings": {
			"path": "res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres",
			"name": "navy_chapel_opaque_opening_no_interior_claim", "color": Color(0.075, 0.095, 0.1, 1.0), "roughness": 0.5,
		},
	}
	var seen := {}
	for value: Node in root.find_children("*", "MeshInstance3D", true, false):
		var instance := value as MeshInstance3D
		if instance.mesh == null or instance.mesh.get_surface_count() != 1 or seen.has(instance.name):
			return false
		var material := instance.mesh.surface_get_material(0)
		if instance.name == "AcceptedCreamExactSSERuns_9_10":
			if not _accepted_shader_material_matches(material):
				return false
		else:
			if not expected.has(instance.name) or not _standard_material_matches(material, expected[instance.name] as Dictionary):
				return false
		seen[instance.name] = true
	return seen.size() == 6 and seen.has("AcceptedCreamExactSSERuns_9_10") and seen.size() == expected.size() + 1


static func _standard_material_matches(material: Material, expected: Dictionary) -> bool:
	if not (material is StandardMaterial3D):
		return false
	var standard := material as StandardMaterial3D
	return standard.resource_path == str(expected.path) \
		and standard.resource_name == str(expected.name) \
		and standard.albedo_color.is_equal_approx(expected.color as Color) \
		and is_equal_approx(standard.roughness, float(expected.roughness)) \
		and is_zero_approx(standard.metallic) \
		and standard.albedo_texture == null and standard.normal_texture == null \
		and standard.next_pass == null


static func _accepted_shader_material_matches(material: Material) -> bool:
	if not (material is ShaderMaterial):
		return false
	var shader_material := material as ShaderMaterial
	var shader := shader_material.shader
	return shader_material.resource_path == "res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres" \
		and shader_material.resource_name == "navy_chapel_sse_warm_cream_painted_prototype" \
		and shader != null and shader.resource_path == "res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader" \
		and (shader_material.get_shader_parameter("base_color") as Color).is_equal_approx(Color(0.82, 0.77, 0.65, 1.0)) \
		and (shader_material.get_shader_parameter("secondary_color") as Color).is_equal_approx(Color(0.76, 0.71, 0.60, 1.0)) \
		and is_equal_approx(float(shader_material.get_shader_parameter("roughness_value")), 0.76) \
		and int(shader_material.get_shader_parameter("field_kind")) == 4 \
		and is_equal_approx(float(shader_material.get_shader_parameter("primary_scale_m")), 1.65) \
		and is_equal_approx(float(shader_material.get_shader_parameter("secondary_scale_m")), 0.55) \
		and is_zero_approx(float(shader_material.get_shader_parameter("relief_strength"))) \
		and is_equal_approx(float(shader_material.get_shader_parameter("color_variation")), 0.025) \
		and is_equal_approx(float(shader_material.get_shader_parameter("filter_start_cycles_per_pixel")), 0.12) \
		and is_equal_approx(float(shader_material.get_shader_parameter("filter_end_cycles_per_pixel")), 0.34) \
		and shader_material.next_pass == null


static func _measure(roots: Array) -> Dictionary:
	var mesh_instances := 0
	var surfaces := 0
	var triangles := 0
	var bodies := 0
	var shapes := 0
	var navigation_nodes := 0
	var spray_owners := 0
	var roof_spray_owners := 0
	var collision_triangles := 0
	var wall_collision_triangles := 0
	var roof_collision_triangles := 0
	for root_value: Variant in roots:
		var root := root_value as Node
		for node: Node in _descendants(root):
			if node is MeshInstance3D:
				mesh_instances += 1
				var mesh := (node as MeshInstance3D).mesh
				if mesh != null:
					surfaces += mesh.get_surface_count()
					for surface_index in mesh.get_surface_count():
						var arrays := mesh.surface_get_arrays(surface_index)
						triangles += int((arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
			if node is StaticBody3D:
				bodies += 1
				if node.is_in_group("spray_receiver_wall"):
					spray_owners += 1
					if str(node.get_meta("derived_object_key", "")) == ROOF_KEY:
						roof_spray_owners += 1
			if node is CollisionShape3D:
				shapes += 1
				var collision_shape := (node as CollisionShape3D).shape
				if collision_shape is ConcavePolygonShape3D:
					var shape_triangles := int((collision_shape as ConcavePolygonShape3D).get_faces().size() / 3)
					collision_triangles += shape_triangles
					if str(collision_shape.get_meta("derived_object_key", "")) == WALL_KEY:
						wall_collision_triangles += shape_triangles
					elif str(collision_shape.get_meta("derived_object_key", "")) == ROOF_KEY:
						roof_collision_triangles += shape_triangles
			if node is NavigationRegion3D or node is NavigationObstacle3D or node is NavigationLink3D:
				navigation_nodes += 1
	return {
		"mesh_instances": mesh_instances,
		"surfaces": surfaces,
		"visual_triangles": triangles,
		"static_bodies": bodies,
		"shapes": shapes,
		"collision_triangles": collision_triangles,
		"wall_collision_triangles": wall_collision_triangles,
		"roof_collision_triangles": roof_collision_triangles,
		"spray_owners": spray_owners,
		"roof_spray_owners": roof_spray_owners,
		"navigation_nodes": navigation_nodes,
	}


static func _measured_contract_matches(measured: Dictionary) -> bool:
	return int(measured.get("mesh_instances", -1)) == EXPECTED_MESH_INSTANCES \
		and int(measured.get("surfaces", -1)) == EXPECTED_SURFACES \
		and int(measured.get("visual_triangles", -1)) == EXPECTED_VISUAL_TRIANGLES \
		and int(measured.get("static_bodies", -1)) == 2 \
		and int(measured.get("shapes", -1)) == 2 \
		and int(measured.get("collision_triangles", -1)) == EXPECTED_COLLISION_TRIANGLES \
		and int(measured.get("wall_collision_triangles", -1)) == EXPECTED_WALL_COLLISION_TRIANGLES \
		and int(measured.get("roof_collision_triangles", -1)) == EXPECTED_ROOF_COLLISION_TRIANGLES \
		and int(measured.get("spray_owners", -1)) == 1 \
		and int(measured.get("roof_spray_owners", -1)) == 0 \
		and int(measured.get("navigation_nodes", -1)) == 0


static func _descendants(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	var pending: Array[Node] = [root]
	while not pending.is_empty():
		var current := pending.pop_back() as Node
		result.append(current)
		for child: Node in current.get_children():
			pending.append(child)
	return result


static func _record_for_key(records: Array, object_key: String) -> Dictionary:
	for record_value: Variant in records:
		var record := record_value as Dictionary
		if str(record.get("object_key", "")) == object_key:
			return record
	return {}


static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	return {
		"ok": false,
		"code": code,
		"message": message,
		"source_keys": record.get("source_keys", []).duplicate(),
	}
