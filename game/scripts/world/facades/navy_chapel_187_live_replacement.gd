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

const PROTOTYPE := preload("res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd")

const EXECUTABLE_DEPENDENCIES := [
	"res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd",
	"res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json",
	"res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_metal_cap.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_timber.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_coating.gdshader",
]


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
	return {"ok": true, "contains_target": true, "wall": wall, "roof": roof}


static func build_chunk_plan(prepared_pair: Dictionary) -> Dictionary:
	if not bool(prepared_pair.get("ok", false)):
		return prepared_pair
	if not bool(prepared_pair.get("contains_target", false)):
		return {"ok": true, "contains_target": false, "pending_keys": {}}
	# Require the complete packaged resource closure; the built geometry and
	# material semantics are checked below.
	if not runtime_dependency_closure_exists():
		return _failure("navy_chapel_187_live_dependency", "The approved Chapel executable dependency closure is incomplete.", prepared_pair.get("wall", {}) as Dictionary)
	var wall_record := prepared_pair.get("wall", {}) as Dictionary
	var roof_record := prepared_pair.get("roof", {}) as Dictionary
	if not PROTOTYPE.matches_record_pair(wall_record, roof_record):
		return _failure("navy_chapel_187_live_prepared_pair", "The prepared Chapel pair no longer matches the wall+roof contract.", wall_record)
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


static func _build_paired_replacement(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	var prototype_result := PROTOTYPE.build_for_records(wall_record, roof_record)
	if not bool(prototype_result.get("ok", false)):
		return _failure("navy_chapel_187_live_factory", str(prototype_result.get("message", "The approved Chapel geometry factory failed.")), wall_record)
	var wall_root := prototype_result.get("node", null) as Node3D
	if wall_root == null:
		return _failure("navy_chapel_187_live_factory_node", "The approved Chapel geometry factory returned no node.", wall_record)
	if not material_semantics_match(wall_root):
		wall_root.free()
		return _failure("navy_chapel_187_live_material_semantics", "The packaged Chapel material roles or values did not match.", wall_record)
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
		return _failure("navy_chapel_187_live_topology", "The Chapel replacement collision or ownership contract did not match.", wall_record)
	var metadata := {
		"schema_version": "ti.navy-chapel-187-live-replacement/1",
		"source_key": SOURCE_KEY,
		"wall_object_key": WALL_KEY,
		"roof_object_key": ROOF_KEY,
		"replacement_mode": "paired_visual_replacement_with_split_wall_and_roof_collision",
		"fallback_allowed": false,
		"stack_allowed": false,
		"structural_owner_count": 2,
		"shape_count": 2,
		"spray_owner_count": 1,
		"roof_receiver_kind": "none",
		"roof_in_wall_spray_group": false,
		"navigation_owner_count": 0,
		"roof_landing_world_solid": true,
		"horizontal_source_footprint_changed": false,
		"measured": measured.duplicate(true),
	}
	wall_root.set_meta("navy_chapel_187_live_replacement", metadata.duplicate(true))
	roof_root.set_meta("navy_chapel_187_live_replacement", metadata.duplicate(true))
	return {"ok": true, "wall_result": {
		"ok": true, "node": wall_root, "metadata": metadata,
		"mesh_instances": int(measured.mesh_instances), "surfaces": int(measured.surfaces),
		"triangles": int(measured.visual_triangles), "static_bodies": 1, "shapes": 1,
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
	return root


static func _apply_live_root_metadata(wall_root: Node3D, roof_root: Node3D) -> void:
	wall_root.name = "NavyChapel187LiveWallVisualAndCollisionReplacement"
	for root: Node3D in [wall_root, roof_root]:
		root.set_meta("runtime_supersedes_generated_placeholder", true)
		root.set_meta("superseded_object_keys", [WALL_KEY, ROOF_KEY])
	wall_root.set_meta("derived_object_key", WALL_KEY)
	wall_root.set_meta("source_keys", [SOURCE_KEY])
	wall_root.set_meta("feature_kind", "building_wall")


static func _split_collision(root: Node3D) -> Dictionary:
	var wall_faces: PackedVector3Array = root.get_meta("chapel_wall_faces", PackedVector3Array())
	var roof_faces: PackedVector3Array = root.get_meta("chapel_roof_faces", PackedVector3Array())
	if wall_faces.is_empty() or roof_faces.is_empty() or wall_faces.size() % 3 != 0 or roof_faces.size() % 3 != 0:
		return {"ok": false, "message": "Chapel semantic wall/roof face partitions are incomplete."}
	var original_bodies: Array[StaticBody3D] = []
	for node: Node in _descendants(root):
		if node is StaticBody3D:
			original_bodies.append(node as StaticBody3D)
	if original_bodies.size() != 1 or original_bodies[0].get_parent() != root:
		return {"ok": false, "message": "Chapel producer must supply one direct combined body before semantic replacement."}
	root.remove_child(original_bodies[0])
	original_bodies[0].free()

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
	body.set_meta("spray_ownership", "wall_receiver" if spray_wall else "none_roof_rejection_blocker")
	body.set_meta("roof_landing_world_solid", not spray_wall)
	body.set_meta("ownership_partition", "wall_like" if spray_wall else "roof_cap_cross_landing")
	if spray_wall:
		body.add_to_group("spray_receiver_wall")
	body.add_child(shape_node)
	return body


static func runtime_dependency_closure_exists() -> bool:
	for path: String in EXECUTABLE_DEPENDENCIES:
		if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
			return false
	return true


static func material_semantics_match(root: Node3D) -> bool:
	var base := "res://game/resources/materials/world/navy_chapel_187/standalone_hero/"
	var expected := {
		"QuietWallAndRearClosure": "navy_chapel_inferred_cream_structure.tres",
		"InferredCreamSSEGableBelfryEntry": "navy_chapel_inferred_cream_structure.tres",
		"NeutralRoofAndCap": "navy_chapel_neutral_roof.tres",
		"RibbedMetalCap": "navy_chapel_metal_cap.tres",
		"WSWFlightDecor": "navy_chapel_pale_trim.tres",
		"WSWFlightSupport": "navy_chapel_pale_trim.tres",
		"ObservedPaleTrim": "navy_chapel_pale_trim.tres",
		"ObservedCross": "navy_chapel_pale_trim.tres",
		"OpaqueExteriorOpenings": "navy_chapel_opaque_opening.tres",
		"ObservedOpaquePanelAndDoor": "navy_chapel_timber.tres",
	}
	var seen := {}
	for value: Node in root.find_children("*", "MeshInstance3D", true, false):
		var instance := value as MeshInstance3D
		if instance.mesh == null or instance.mesh.get_surface_count() != 1 or seen.has(instance.name) or not expected.has(instance.name):
			return false
		var material := instance.mesh.surface_get_material(0)
		if material == null or material.resource_path != base + str(expected[instance.name]) or material.next_pass != null:
			return false
		if instance.name in ["QuietWallAndRearClosure", "InferredCreamSSEGableBelfryEntry", "NeutralRoofAndCap", "RibbedMetalCap", "WSWFlightDecor", "WSWFlightSupport", "ObservedPaleTrim", "ObservedCross", "ObservedOpaquePanelAndDoor"]:
			if not material is ShaderMaterial or (material as ShaderMaterial).shader == null \
				or (material as ShaderMaterial).shader.resource_path != base + "navy_chapel_coating.gdshader":
				return false
		elif not material is StandardMaterial3D or (material as StandardMaterial3D).transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
			return false
		seen[instance.name] = true
	return seen.size() == expected.size()


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
	return int(measured.get("mesh_instances", -1)) > 0 \
		and int(measured.get("visual_triangles", -1)) > 0 \
		and int(measured.get("static_bodies", -1)) == 2 \
		and int(measured.get("shapes", -1)) == 2 \
		and int(measured.get("wall_collision_triangles", -1)) > 0 \
		and int(measured.get("roof_collision_triangles", -1)) > 0 \
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
