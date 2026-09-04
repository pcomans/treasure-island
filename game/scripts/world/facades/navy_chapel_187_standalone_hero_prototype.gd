class_name NavyChapel187StandaloneHeroPrototype
extends Node3D

const CONFIG_PATH := "res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const SOURCE_KEY := "w291189336"
const WALL_KEY := "building:w291189336:wall"
const ROOF_KEY := "building:w291189336:roof"
const WALL_RUN_COUNT := 34
const OBSERVED_SSE_RUNS := [9, 10]
const OBSERVED_PARTIAL_SIDE_RUNS := [11, 12, 13]
const PROTECTED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33]
const PHYSICS_WORLD_SOLID := 1 << 0
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1

const ACCEPTED_CREAM := preload("res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres")
const INFERRED_CREAM_STRUCTURE := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres")
const PROTECTED_NEUTRAL := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres")
const PALE_TRIM := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres")
const OPAQUE_OPENING := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres")
const NEUTRAL_ROOF := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres")

@export var auto_configure_from_frozen_source := true

var _configured := false
var _last_result: Dictionary = {}


func _ready() -> void:
	if auto_configure_from_frozen_source and not _configured:
		var result := configure_from_frozen_source()
		if not bool(result.get("ok", false)):
			push_error("Navy Chapel standalone hero prototype failed closed: %s" % str(result.get("message", "unknown error")))


static func matches_record_pair(wall_record: Dictionary, roof_record: Dictionary) -> bool:
	return _record_contract_matches(wall_record, WALL_KEY, "building_wall", 408, 204) \
		and _record_contract_matches(roof_record, ROOF_KEY, "building_roof", 60, 54)


static func build_for_records(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	var prototype := NavyChapel187StandaloneHeroPrototype.new()
	prototype.auto_configure_from_frozen_source = false
	var result := prototype.configure_records(wall_record, roof_record)
	if not bool(result.get("ok", false)):
		prototype.free()
		return result
	result["node"] = prototype
	return result


func configure_from_frozen_source() -> Dictionary:
	var chunk := _json(CHUNK_PATH)
	if chunk.is_empty():
		return _failure("navy_chapel_source_chunk", "Frozen Chapel source chunk could not be loaded.")
	var wall_record := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof_record := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	return configure_records(wall_record, roof_record)


func configure_records(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	if _configured:
		return _failure("navy_chapel_duplicate_configuration", "The standalone Chapel prototype is already configured.")
	var config := _json(CONFIG_PATH)
	if not _config_contract_matches(config):
		return _failure("navy_chapel_config_contract", "The standalone Chapel truth/configuration contract drifted.")
	if not matches_record_pair(wall_record, roof_record):
		return _failure("navy_chapel_source_contract", "The exact w291189336 wall+roof pair did not match the fail-closed prototype seam.")

	var protected_wall := _bucket()
	var accepted_cream := _bucket()
	var inferred_cream := _bucket()
	var roof := _bucket()
	var trim := _bucket()
	var opening := _bucket()
	var collision := _bucket()

	for run_index in range(WALL_RUN_COUNT):
		var visual_bucket := accepted_cream if run_index in OBSERVED_SSE_RUNS else protected_wall
		_append_record_wall_run(visual_bucket, wall_record, run_index)
		_append_record_wall_run(collision, wall_record, run_index)
	_append_record_mesh(roof, roof_record)
	_append_record_mesh(collision, roof_record)

	var inference := config.production_inference_m as Dictionary
	var sse := _chain_basis(wall_record, OBSERVED_SSE_RUNS)
	if sse.is_empty():
		return _failure("navy_chapel_sse_chain", "The exact SSE run chain could not be resolved.")
	var front_center := sse.start as Vector3
	front_center = front_center.lerp(sse.end as Vector3, 0.5)
	front_center.y = float(inference.main_gable_eave_y)
	var tangent := sse.tangent as Vector3
	var outward := sse.normal as Vector3
	var inward := -outward

	_append_gabled_roof(inferred_cream, protected_wall, roof, collision, front_center, tangent, outward, inference)
	_append_belfry(inferred_cream, roof, trim, collision, front_center, tangent, outward, inference)
	_append_front_composition(inferred_cream, trim, opening, collision, front_center, tangent, outward, inference)
	_append_partial_side_openings(trim, opening, wall_record, inference)

	var specs: Array[Dictionary] = [
		{"name": "ProtectedExactWallAndRearClosure", "bucket": protected_wall, "material": PROTECTED_NEUTRAL, "layers": RENDER_BUILDING_WALL},
		{"name": "AcceptedCreamExactSSERuns_9_10", "bucket": accepted_cream, "material": ACCEPTED_CREAM, "layers": RENDER_BUILDING_WALL},
		{"name": "InferredCreamSSEGableBelfryEntry", "bucket": inferred_cream, "material": INFERRED_CREAM_STRUCTURE, "layers": RENDER_BUILDING_WALL},
		{"name": "NeutralRoofAndCap", "bucket": roof, "material": NEUTRAL_ROOF, "layers": RENDER_WORLD_VISIBLE},
		{"name": "ObservedPaleTrim", "bucket": trim, "material": PALE_TRIM, "layers": RENDER_BUILDING_WALL},
		{"name": "OpaqueExteriorOpenings", "bucket": opening, "material": OPAQUE_OPENING, "layers": RENDER_BUILDING_WALL},
	]
	var visual_triangles := 0
	var mesh_instances := 0
	var batch_triangles := {}
	for spec in specs:
		var bucket := spec.bucket as Dictionary
		var triangle_count := int((bucket.indices as Array).size() / 3)
		if triangle_count <= 0:
			continue
		var instance := _mesh_instance(str(spec.name), bucket, spec.material as Material, int(spec.layers))
		instance.set_meta("prototype_only", true)
		instance.set_meta("material_role", str(spec.name))
		add_child(instance)
		mesh_instances += 1
		visual_triangles += triangle_count
		batch_triangles[str(spec.name)] = triangle_count

	var body := _collision_body(collision)
	if body == null:
		_clear_children_now()
		return _failure("navy_chapel_collision", "The standalone Chapel structural collision bucket was empty.")
	add_child(body)

	var collision_triangles := int((collision.indices as Array).size() / 3)
	var signature_payload := {
		"model_id": str(config.model_id),
		"source_key": SOURCE_KEY,
		"wall_vertices": wall_record.vertices,
		"wall_indices": wall_record.indices,
		"roof_vertices": roof_record.vertices,
		"roof_indices": roof_record.indices,
		"production_inference_m": inference,
		"mapped_runs": [OBSERVED_SSE_RUNS, OBSERVED_PARTIAL_SIDE_RUNS],
		"batch_triangles": batch_triangles,
		"collision_triangles": collision_triangles,
	}
	var deterministic_signature := JSON.stringify(signature_payload).sha256_text()
	var metadata := {
		"model_id": str(config.model_id),
		"config_path": CONFIG_PATH,
		"source_key": SOURCE_KEY,
		"wall_object_key": WALL_KEY,
		"roof_object_key": ROOF_KEY,
		"prototype_only": true,
		"runtime_attachment": false,
		"registry_status": "not_registered",
		"world_builder_status": "not_attached",
		"technical_evidence_status": "pending_independent_bar_raiser_review",
		"recognition_accepted": false,
		"believability_accepted": false,
		"as_built_claim": false,
		"interior_modeled": false,
		"horizontal_source_footprint_changed": false,
		"source_identity_changed": false,
		"vertical_and_roof_geometry_truth_class": "reversible_production_inference",
		"surveyed_vertical_dimensions": false,
		"surveyed_opening_dimensions": false,
		"surveyed_pane_count": false,
		"surveyed_side_cadence": false,
		"source_photography_shipped": false,
		"observed_sse_run_indices": OBSERVED_SSE_RUNS.duplicate(),
		"observed_partial_side_run_indices": OBSERVED_PARTIAL_SIDE_RUNS.duplicate(),
		"protected_run_indices": PROTECTED_RUNS.duplicate(),
		"protected_runs_have_modules": false,
		"accepted_cream_run_indices": OBSERVED_SSE_RUNS.duplicate(),
		"accepted_cream_scope_extended": false,
		"new_structure_cream_truth_class": "reversible_production_inference_not_material_accepted",
		"complete_sse_composition_count": 1,
		"belfry_count": 1,
		"pyramidal_cap_count": 1,
		"cross_count": 1,
		"tall_divided_window_count": 1,
		"projecting_entry_count": 1,
		"partial_side_opening_group_count": 3,
		"entry_and_new_silhouette_collision_congruent": true,
		"decorative_overlays_noncolliding_with_exact_wall_behind": true,
		"landing_geometry_includes_pitched_roof_and_cap": true,
		"spray_ownership": "none_standalone",
		"mesh_instances": mesh_instances,
		"surfaces": mesh_instances,
		"visual_triangles": visual_triangles,
		"visual_batch_triangles": batch_triangles,
		"static_bodies": 1,
		"shapes": 1,
		"collision_triangles": collision_triangles,
		"collision_face_vertices": collision_triangles * 3,
		"deterministic_signature": deterministic_signature,
	}
	for key: String in metadata:
		set_meta(key, metadata[key])
	_configured = true
	_last_result = {
		"ok": true,
		"node": self,
		"metadata": metadata,
		"mesh_instances": mesh_instances,
		"surfaces": mesh_instances,
		"visual_triangles": visual_triangles,
		"collision_triangles": collision_triangles,
		"static_bodies": 1,
		"shapes": 1,
	}
	return _last_result.duplicate(true)


func get_build_result() -> Dictionary:
	return _last_result.duplicate(true)


func _append_gabled_roof(
		cream: Dictionary,
		protected: Dictionary,
		roof: Dictionary,
		collision: Dictionary,
		front_center: Vector3,
		tangent: Vector3,
		outward: Vector3,
		inference: Dictionary) -> void:
	var width := float(inference.main_gable_width)
	var length := float(inference.main_gable_length)
	var eave_y := float(inference.main_gable_eave_y)
	var ridge_y := float(inference.main_gable_ridge_y)
	var inward := -outward
	var start_center := front_center + inward * float(inference.main_gable_front_inset)
	start_center.y = eave_y
	var end_center := start_center + inward * length
	var front_left := start_center - tangent * width * 0.5
	var front_right := start_center + tangent * width * 0.5
	var rear_left := end_center - tangent * width * 0.5
	var rear_right := end_center + tangent * width * 0.5
	var front_ridge := Vector3(start_center.x, ridge_y, start_center.z)
	var rear_ridge := Vector3(end_center.x, ridge_y, end_center.z)
	var left_normal := _upward_normal(front_left, rear_left, rear_ridge)
	var right_normal := _upward_normal(front_ridge, rear_ridge, rear_right)
	_append_quad(roof, front_left, rear_left, rear_ridge, front_ridge, left_normal)
	_append_quad(collision, front_left, rear_left, rear_ridge, front_ridge, left_normal)
	_append_quad(roof, front_ridge, rear_ridge, rear_right, front_right, right_normal)
	_append_quad(collision, front_ridge, rear_ridge, rear_right, front_right, right_normal)
	_append_triangle(cream, front_left, front_right, front_ridge, outward)
	_append_triangle(collision, front_left, front_right, front_ridge, outward)
	_append_triangle(protected, rear_right, rear_left, rear_ridge, inward)
	_append_triangle(collision, rear_right, rear_left, rear_ridge, inward)


func _append_belfry(
		cream: Dictionary,
		roof: Dictionary,
		trim: Dictionary,
		collision: Dictionary,
		front_center: Vector3,
		tangent: Vector3,
		outward: Vector3,
		inference: Dictionary) -> void:
	var center := front_center - outward * float(inference.belfry_center_inward_from_sse_m)
	var base_y := float(inference.belfry_base_y)
	var wall_top_y := float(inference.belfry_wall_top_y)
	center.y = (base_y + wall_top_y) * 0.5
	var width := float(inference.belfry_plan_width)
	var depth := float(inference.belfry_plan_depth)
	_append_box(cream, center, tangent, outward, width, wall_top_y - base_y, depth)
	_append_box(collision, center, tangent, outward, width, wall_top_y - base_y, depth)
	var cap_center := Vector3(center.x, wall_top_y, center.z)
	var half_w := width * 0.5
	var half_d := depth * 0.5
	var fl := cap_center - tangent * half_w + outward * half_d
	var fr := cap_center + tangent * half_w + outward * half_d
	var br := cap_center + tangent * half_w - outward * half_d
	var bl := cap_center - tangent * half_w - outward * half_d
	var apex := Vector3(center.x, float(inference.belfry_cap_apex_y), center.z)
	for triangle: Array in [[fl, fr, apex], [fr, br, apex], [br, bl, apex], [bl, fl, apex]]:
		var a := triangle[0] as Vector3
		var b := triangle[1] as Vector3
		var c := triangle[2] as Vector3
		var normal := _outward_up_normal(a, b, c, center)
		_append_triangle(roof, a, b, c, normal)
		_append_triangle(collision, a, b, c, normal)
	var member := float(inference.cross_member_thickness)
	var vertical_center := Vector3(center.x, float(inference.cross_vertical_center_y), center.z)
	_append_box(trim, vertical_center, tangent, outward, member, float(inference.cross_vertical_height), member)
	_append_box(collision, vertical_center, tangent, outward, member, float(inference.cross_vertical_height), member)
	var horizontal_center := Vector3(center.x, float(inference.cross_horizontal_center_y), center.z)
	_append_box(trim, horizontal_center, tangent, outward, float(inference.cross_horizontal_width), member, member)
	_append_box(collision, horizontal_center, tangent, outward, float(inference.cross_horizontal_width), member, member)


func _append_front_composition(
		cream: Dictionary,
		trim: Dictionary,
		opening: Dictionary,
		collision: Dictionary,
		front_center: Vector3,
		tangent: Vector3,
		outward: Vector3,
		inference: Dictionary) -> void:
	var entry_base := float(inference.entry_base_y)
	var entry_height := float(inference.entry_height)
	var entry_depth := float(inference.entry_depth)
	var entry_center := Vector3(front_center.x, entry_base + entry_height * 0.5, front_center.z) + outward * entry_depth * 0.5
	_append_box(cream, entry_center, tangent, outward, float(inference.entry_width), entry_height, entry_depth)
	_append_box(collision, entry_center, tangent, outward, float(inference.entry_width), entry_height, entry_depth)

	var opening_center := Vector3(front_center.x, entry_base + float(inference.entry_opening_height) * 0.5, front_center.z) + outward * (entry_depth + 0.06)
	_append_box(opening, opening_center, tangent, outward, float(inference.entry_opening_width), float(inference.entry_opening_height), 0.1)
	_append_frame(trim, opening_center + outward * 0.07, tangent, outward, float(inference.entry_opening_width), float(inference.entry_opening_height), 0.18, 0.12)

	var window_bottom := float(inference.tall_window_bottom_y)
	var window_top := float(inference.tall_window_top_y)
	var window_height := window_top - window_bottom
	var window_width := float(inference.tall_window_width)
	var glass_center := Vector3(front_center.x, (window_bottom + window_top) * 0.5, front_center.z) + outward * float(inference.front_reveal_depth)
	_append_box(opening, glass_center, tangent, outward, window_width, window_height, 0.12)
	var frame_center := glass_center + outward * (float(inference.front_frame_projection) - float(inference.front_reveal_depth))
	_append_frame(trim, frame_center, tangent, outward, window_width, window_height, 0.2, 0.14)
	var vertical_dividers := int(inference.tall_window_vertical_dividers)
	for divider_index in range(vertical_dividers):
		var fraction := float(divider_index + 1) / float(vertical_dividers + 1) - 0.5
		_append_box(trim, frame_center + tangent * window_width * fraction, tangent, outward, 0.11, window_height, 0.14)
	var horizontal_dividers := int(inference.tall_window_horizontal_dividers)
	for divider_index in range(horizontal_dividers):
		var fraction := float(divider_index + 1) / float(horizontal_dividers + 1) - 0.5
		var bar_center := frame_center
		bar_center.y += window_height * fraction
		_append_box(trim, bar_center, tangent, outward, window_width, 0.11, 0.14)


func _append_partial_side_openings(trim: Dictionary, opening: Dictionary, wall_record: Dictionary, inference: Dictionary) -> void:
	var width := float(inference.side_window_width)
	var bottom_y := float(inference.side_window_bottom_y)
	var top_y := float(inference.side_window_top_y)
	var height := top_y - bottom_y
	for chain_m_value: Variant in inference.side_window_chain_centers_m as Array:
		var placement := _chain_frame(wall_record, OBSERVED_PARTIAL_SIDE_RUNS, float(chain_m_value))
		if placement.is_empty():
			continue
		var tangent := placement.tangent as Vector3
		var normal := placement.normal as Vector3
		var anchor := placement.wall_anchor as Vector3
		var center := Vector3(anchor.x, (bottom_y + top_y) * 0.5, anchor.z) + normal * 0.12
		_append_box(opening, center, tangent, normal, width, height, 0.1)
		var frame_center := center + normal * (float(inference.side_frame_projection) - 0.12)
		_append_frame(trim, frame_center, tangent, normal, width, height, 0.16, 0.12)
		_append_box(trim, frame_center, tangent, normal, 0.1, height, 0.12)


func _append_frame(bucket: Dictionary, center: Vector3, tangent: Vector3, normal: Vector3, width: float, height: float, member: float, depth: float) -> void:
	_append_box(bucket, center - tangent * (width + member) * 0.5, tangent, normal, member, height + member * 2.0, depth)
	_append_box(bucket, center + tangent * (width + member) * 0.5, tangent, normal, member, height + member * 2.0, depth)
	var top := center
	top.y += (height + member) * 0.5
	var bottom := center
	bottom.y -= (height + member) * 0.5
	_append_box(bucket, top, tangent, normal, width, member, depth)
	_append_box(bucket, bottom, tangent, normal, width, member, depth)


func _append_record_wall_run(bucket: Dictionary, record: Dictionary, run_index: int) -> void:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var source_indices := record.indices as Array
	var value_offset := run_index * 12
	var vertex_offset := run_index * 4
	var index_offset := run_index * 6
	var base := (bucket.vertices as Array).size()
	for local_index in range(4):
		var offset := value_offset + local_index * 3
		(bucket.vertices as Array).append(Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2])))
		(bucket.normals as Array).append(Vector3(float(normals[offset]), float(normals[offset + 1]), float(normals[offset + 2])))
		(bucket.uvs as Array).append(Vector2(float(values[offset]) + float(values[offset + 2]), float(values[offset + 1])))
	# Generated source triangles use the canonical serialized order. Mirror the
	# live WorldChunkBuilder's first/third/second winding so exterior rendering
	# and one-sided world-solid collision agree with the exact current receiver.
	for triangle_offset in range(0, 6, 3):
		var first := base + int(source_indices[index_offset + triangle_offset]) - vertex_offset
		var second := base + int(source_indices[index_offset + triangle_offset + 1]) - vertex_offset
		var third := base + int(source_indices[index_offset + triangle_offset + 2]) - vertex_offset
		(bucket.indices as Array).append_array([first, third, second])


func _append_record_mesh(bucket: Dictionary, record: Dictionary) -> void:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var source_indices := record.indices as Array
	var base := (bucket.vertices as Array).size()
	for offset in range(0, values.size(), 3):
		var point := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
		(bucket.vertices as Array).append(point)
		(bucket.normals as Array).append(Vector3(float(normals[offset]), float(normals[offset + 1]), float(normals[offset + 2])))
		(bucket.uvs as Array).append(Vector2(point.x + point.z, point.y))
	for source_offset in range(0, source_indices.size(), 3):
		var first := base + int(source_indices[source_offset])
		var second := base + int(source_indices[source_offset + 1])
		var third := base + int(source_indices[source_offset + 2])
		(bucket.indices as Array).append_array([first, third, second])


func _append_box(bucket: Dictionary, center: Vector3, tangent_value: Vector3, normal_value: Vector3, width: float, height: float, depth: float) -> void:
	var tangent := tangent_value.normalized()
	var normal := normal_value.normalized()
	var tx := tangent * width * 0.5
	var nz := normal * depth * 0.5
	var uy := Vector3.UP * height * 0.5
	var fbl := center - tx - uy + nz
	var fbr := center + tx - uy + nz
	var ftr := center + tx + uy + nz
	var ftl := center - tx + uy + nz
	var bbl := center - tx - uy - nz
	var bbr := center + tx - uy - nz
	var btr := center + tx + uy - nz
	var btl := center - tx + uy - nz
	_append_quad(bucket, fbl, fbr, ftr, ftl, normal)
	_append_quad(bucket, bbr, bbl, btl, btr, -normal)
	_append_quad(bucket, ftl, ftr, btr, btl, Vector3.UP)
	_append_quad(bucket, bbl, bbr, fbr, fbl, Vector3.DOWN)
	_append_quad(bucket, bbl, fbl, ftl, btl, -tangent)
	_append_quad(bucket, fbr, bbr, btr, ftr, tangent)


func _append_quad(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal_value: Vector3) -> void:
	var normal := normal_value.normalized()
	var vertices := bucket.vertices as Array
	var normals := bucket.normals as Array
	var uvs := bucket.uvs as Array
	var indices := bucket.indices as Array
	var base := vertices.size()
	for point: Vector3 in [a, b, c, d]:
		vertices.append(point)
		normals.append(normal)
		uvs.append(Vector2(point.x + point.z, point.y))
	if (b - a).cross(c - a).dot(normal) > 0.0:
		indices.append_array([base, base + 2, base + 1, base, base + 3, base + 2])
	else:
		indices.append_array([base, base + 1, base + 2, base, base + 2, base + 3])


func _append_triangle(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, normal_value: Vector3) -> void:
	var normal := normal_value.normalized()
	var vertices := bucket.vertices as Array
	var normals := bucket.normals as Array
	var uvs := bucket.uvs as Array
	var indices := bucket.indices as Array
	var base := vertices.size()
	for point: Vector3 in [a, b, c]:
		vertices.append(point)
		normals.append(normal)
		uvs.append(Vector2(point.x + point.z, point.y))
	if (b - a).cross(c - a).dot(normal) > 0.0:
		indices.append_array([base, base + 2, base + 1])
	else:
		indices.append_array([base, base + 1, base + 2])


func _mesh_instance(node_name: String, bucket: Dictionary, material: Material, layers: int) -> MeshInstance3D:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(bucket.vertices as Array)
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(bucket.normals as Array)
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(bucket.uvs as Array)
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(bucket.indices as Array)
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_name(0, node_name.to_snake_case())
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.layers = layers
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return instance


func _collision_body(bucket: Dictionary) -> StaticBody3D:
	if (bucket.indices as Array).is_empty():
		return null
	var source_vertices := bucket.vertices as Array
	var faces := PackedVector3Array()
	for index_value: Variant in bucket.indices as Array:
		faces.append(source_vertices[int(index_value)] as Vector3)
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	shape.set_meta("receiver_kind", "none")
	shape.set_meta("opaque", true)
	shape.set_meta("derived_object_key", "prototype:%s" % WALL_KEY)
	shape.set_meta("source_keys", [SOURCE_KEY])
	shape.set_meta("prototype_only", true)
	shape.set_meta("structural_visible_collision_congruent", true)
	var shape_node := CollisionShape3D.new()
	shape_node.name = "StructuralShape"
	shape_node.shape = shape
	var body := StaticBody3D.new()
	body.name = "StructuralCollision_NoSprayOwnership"
	body.collision_layer = PHYSICS_WORLD_SOLID
	body.collision_mask = 0
	body.set_meta("receiver_kind", "none")
	body.set_meta("opaque", true)
	body.set_meta("derived_object_key", "prototype:%s" % WALL_KEY)
	body.set_meta("source_keys", [SOURCE_KEY])
	body.set_meta("prototype_only", true)
	body.set_meta("runtime_attachment", false)
	body.set_meta("spray_ownership", "none_standalone")
	body.set_meta("structural_visible_collision_congruent", true)
	body.add_child(shape_node)
	return body


static func _record_contract_matches(record: Dictionary, object_key: String, feature_kind: String, vertex_value_count: int, index_count: int) -> bool:
	return not record.is_empty() \
		and str(record.get("object_key", "")) == object_key \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == feature_kind \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and (record.get("vertices", []) as Array).size() == vertex_value_count \
		and (record.get("normals", []) as Array).size() == vertex_value_count \
		and (record.get("indices", []) as Array).size() == index_count \
		and is_equal_approx(float(record.get("top_elevation_m", 0.0)), 14.04)


static func _config_contract_matches(config: Dictionary) -> bool:
	if config.is_empty() or str(config.get("schema_version", "")) != "ti.navy-chapel-187-standalone-hero-prototype/1":
		return false
	var target := config.get("target", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	var inference := config.get("production_inference_m", {}) as Dictionary
	var seam := config.get("future_integration_seam", {}) as Dictionary
	if str(target.get("source_key", "")) != SOURCE_KEY \
		or str(target.get("wall_object_key", "")) != WALL_KEY \
		or str(target.get("roof_object_key", "")) != ROOF_KEY \
		or int(target.get("wall_run_count", 0)) != WALL_RUN_COUNT \
		or int(target.get("wall_vertices", 0)) != 136 \
		or int(target.get("wall_triangles", 0)) != 68 \
		or int(target.get("roof_plan_vertices", 0)) != 20 \
		or int(target.get("roof_triangles", 0)) != 18:
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
		or bool(truth.get("source_identity_changed", true)):
		return false
	var mapped := config.get("mapped_runs", []) as Array
	var protected := config.get("protected_regions", []) as Array
	if mapped.size() != 2 \
		or _int_array((mapped[0] as Dictionary).get("ordered_run_indices", []) as Array) != OBSERVED_SSE_RUNS \
		or _int_array((mapped[1] as Dictionary).get("ordered_run_indices", []) as Array) != OBSERVED_PARTIAL_SIDE_RUNS \
		or protected.is_empty() \
		or _int_array((protected[0] as Dictionary).get("run_indices", []) as Array) != PROTECTED_RUNS:
		return false
	if float(inference.get("main_gable_width", 0.0)) > 14.0 \
		or float(inference.get("main_gable_length", 0.0)) > 20.0 \
		or float(inference.get("main_gable_eave_y", 0.0)) != 14.04 \
		or float(inference.get("main_gable_ridge_y", 0.0)) <= 14.04 \
		or float(inference.get("belfry_cap_apex_y", 0.0)) <= float(inference.get("belfry_wall_top_y", 0.0)) \
		or float(inference.get("cross_vertical_center_y", 0.0)) <= float(inference.get("belfry_cap_apex_y", 0.0)) \
		or (inference.get("side_window_chain_centers_m", []) as Array).size() != 3:
		return false
	return str(seam.get("registry_status", "")) == "not_registered" \
		and str(seam.get("world_builder_status", "")) == "not_attached" \
		and "wall and roof together" in str(seam.get("required_live_behavior", ""))


static func _chain_basis(record: Dictionary, runs: Array) -> Dictionary:
	if runs.is_empty():
		return {}
	var first := _run_frame(record, int(runs[0]))
	var last := _run_frame(record, int(runs[runs.size() - 1]))
	if first.is_empty() or last.is_empty():
		return {}
	return {
		"start": first.start,
		"end": last.end,
		"tangent": first.tangent,
		"normal": first.normal,
	}


static func _chain_frame(record: Dictionary, runs: Array, chain_m: float) -> Dictionary:
	var accumulated := 0.0
	for run_value: Variant in runs:
		var run_index := int(run_value)
		var frame := _run_frame(record, run_index)
		if frame.is_empty():
			return {}
		var length := float(frame.length_m)
		if chain_m <= accumulated + length + 0.0001:
			var fraction := clampf((chain_m - accumulated) / length, 0.0, 1.0)
			return {
				"wall_anchor": (frame.start as Vector3).lerp(frame.end as Vector3, fraction),
				"tangent": frame.tangent,
				"normal": frame.normal,
				"run_index": run_index,
			}
		accumulated += length
	return {}


static func _run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var offset := run_index * 12
	if run_index < 0 or offset + 11 >= values.size():
		return {}
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var tangent := end - start
	tangent.y = 0.0
	if tangent.length_squared() <= 0.000001:
		return {}
	return {
		"start": start,
		"end": end,
		"length_m": tangent.length(),
		"tangent": tangent.normalized(),
		"normal": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized(),
	}


static func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


static func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


static func _bucket() -> Dictionary:
	return {"vertices": [], "normals": [], "uvs": [], "indices": []}


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func _upward_normal(a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	var normal := (b - a).cross(c - a).normalized()
	return -normal if normal.y < 0.0 else normal


static func _outward_up_normal(a: Vector3, b: Vector3, c: Vector3, center: Vector3) -> Vector3:
	var normal := (b - a).cross(c - a).normalized()
	var face_center := (a + b + c) / 3.0
	var outward := face_center - center
	outward.y = maxf(outward.y, 0.25)
	return -normal if normal.dot(outward) < 0.0 else normal


func _clear_children_now() -> void:
	for child in get_children():
		remove_child(child)
		child.free()


static func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "code": code, "message": message}
