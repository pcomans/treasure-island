class_name Dormitory369StandaloneHeroPrototype
extends Node3D

const CONFIG_PATH := "res://game/resources/facades/dormitory_369_standalone_hero_prototype.json"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_1.json"
const SOURCE_KEY := "w291189926"
const WALL_KEY := "building:w291189926:wall"
const ROOF_KEY := "building:w291189926:roof"
const WALL_RUN_COUNT := 72
const MAPPED_PUBLIC_RUNS := [0, 1, 2, 3, 4, 5]
const PROTECTED_RUNS := [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71]
const PHYSICS_WORLD_SOLID := 1 << 0
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1

const ACCEPTED_WARM := preload("res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres")
const PROTECTED_NEUTRAL := preload("res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_protected_neutral.tres")
const INFERRED_BLUE_GRAY := preload("res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_inferred_blue_gray.tres")
const INFERRED_GREEN := preload("res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_inferred_green_trim.tres")
const OPAQUE_OPENING := preload("res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_opaque_opening.tres")
const OPENING_FRAME := preload("res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_opening_frame.tres")
const NEUTRAL_ROOF := preload("res://game/resources/materials/world/job_corps_dormitory_b369/standalone_hero/dormitory_369_neutral_roof.tres")

@export var auto_configure_from_frozen_source := true

var _configured := false
var _last_result: Dictionary = {}


func _ready() -> void:
	if auto_configure_from_frozen_source and not _configured:
		var result := configure_from_frozen_source()
		if not bool(result.get("ok", false)):
			push_error("Dormitory 369 standalone hero failed closed: %s" % str(result.get("message", "unknown error")))


static func matches_record_pair(wall_record: Dictionary, roof_record: Dictionary) -> bool:
	return _record_contract_matches(wall_record, WALL_KEY, "building_wall", 864, 432) \
		and _record_contract_matches(roof_record, ROOF_KEY, "building_roof", 102, 96)


static func build_for_records(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	var prototype := Dormitory369StandaloneHeroPrototype.new()
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
		return _failure("dormitory_369_source_chunk", "Frozen Dormitory 369 source chunk could not be loaded.")
	var wall_record := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof_record := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	return configure_records(wall_record, roof_record)


func configure_records(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	if _configured:
		return _failure("dormitory_369_duplicate_configuration", "The standalone Dormitory 369 prototype is already configured.")
	var config := _json(CONFIG_PATH)
	if not _config_contract_matches(config):
		return _failure("dormitory_369_config_contract", "The standalone Dormitory 369 truth/configuration contract drifted.")
	if not matches_record_pair(wall_record, roof_record):
		return _failure("dormitory_369_source_contract", "The exact w291189926 wall+roof pair did not match the fail-closed prototype seam.")

	var protected_wall := _bucket()
	var accepted_warm := _bucket()
	var roof := _bucket()
	var blue_structure := _bucket()
	var blue_panels := _bucket()
	var green_structure := _bucket()
	var green_eyebrows := _bucket()
	var openings := _bucket()
	var frames := _bucket()
	var collision := _bucket()
	var inference := config.production_inference_m as Dictionary
	var hero_roof_y := float(inference.hero_roof_landing_y)

	for run_index in range(WALL_RUN_COUNT):
		var visual_bucket := accepted_warm if run_index in MAPPED_PUBLIC_RUNS else protected_wall
		_append_lifted_wall_run(visual_bucket, wall_record, run_index, hero_roof_y)
		_append_lifted_wall_run(collision, wall_record, run_index, hero_roof_y)
	_append_lifted_roof(roof, roof_record, hero_roof_y)
	_append_lifted_roof(collision, roof_record, hero_roof_y)

	var chain := _chain_basis(wall_record, MAPPED_PUBLIC_RUNS)
	if chain.is_empty() or not is_equal_approx(float(chain.length_m), 49.124):
		return _failure("dormitory_369_mapped_chain", "The exact mapped WSW run chain could not be resolved to 49.124 m.")
	_append_stair_end(blue_structure, collision, wall_record, inference, float(chain.length_m))
	_append_eave(green_structure, collision, wall_record, inference, float(chain.length_m))
	_append_five_row_facade(blue_panels, green_eyebrows, openings, frames, wall_record, inference)

	var specs: Array[Dictionary] = [
		{"name": "ProtectedLiftedWallRuns_6_71", "bucket": protected_wall, "material": PROTECTED_NEUTRAL, "layers": RENDER_BUILDING_WALL},
		{"name": "AcceptedWarmLiftedWallRuns_0_5", "bucket": accepted_warm, "material": ACCEPTED_WARM, "layers": RENDER_BUILDING_WALL},
		{"name": "NeutralLiftedRoof", "bucket": roof, "material": NEUTRAL_ROOF, "layers": RENDER_WORLD_VISIBLE},
		{"name": "BlueGrayStructuralStairEnd", "bucket": blue_structure, "material": INFERRED_BLUE_GRAY, "layers": RENDER_BUILDING_WALL},
		{"name": "BlueGrayGroundPanels", "bucket": blue_panels, "material": INFERRED_BLUE_GRAY, "layers": RENDER_BUILDING_WALL},
		{"name": "GreenStructuralEave", "bucket": green_structure, "material": INFERRED_GREEN, "layers": RENDER_BUILDING_WALL},
		{"name": "GreenEyebrows", "bucket": green_eyebrows, "material": INFERRED_GREEN, "layers": RENDER_BUILDING_WALL},
		{"name": "OpaqueExteriorOpeningsAndVents", "bucket": openings, "material": OPAQUE_OPENING, "layers": RENDER_BUILDING_WALL},
		{"name": "OpeningFramesAndMultiLiteDividers", "bucket": frames, "material": OPENING_FRAME, "layers": RENDER_BUILDING_WALL},
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
		return _failure("dormitory_369_collision", "The standalone Dormitory 369 structural collision bucket was empty.")
	add_child(body)

	var collision_triangles := int((collision.indices as Array).size() / 3)
	var signature_payload := {
		"model_id": str(config.model_id),
		"source_key": SOURCE_KEY,
		"source_wall_vertices": wall_record.vertices,
		"source_wall_indices": wall_record.indices,
		"source_roof_vertices": roof_record.vertices,
		"source_roof_indices": roof_record.indices,
		"production_inference_m": inference,
		"mapped_runs": MAPPED_PUBLIC_RUNS,
		"protected_runs": PROTECTED_RUNS,
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
		"vertical_opening_and_stair_truth_class": "reversible_production_inference",
		"surveyed_height": false,
		"surveyed_tier_spacing": false,
		"surveyed_opening_dimensions": false,
		"surveyed_opening_count_or_cadence": false,
		"surveyed_stair_geometry": false,
		"source_photography_shipped": false,
		"mapped_public_run_indices": MAPPED_PUBLIC_RUNS.duplicate(),
		"protected_run_indices": PROTECTED_RUNS.duplicate(),
		"protected_runs_have_facade_modules": false,
		"accepted_warm_run_indices": MAPPED_PUBLIC_RUNS.duplicate(),
		"accepted_warm_scope_extended": false,
		"tier_count": int(inference.tier_count),
		"opening_row_count": int(inference.tier_count),
		"opening_column_count": int(inference.opening_column_count),
		"broad_opening_count": 20,
		"narrow_opening_or_panel_count": 20,
		"green_eyebrow_count": 20,
		"base_vent_count": 4,
		"stair_end_volume_count": 1,
		"mapped_eave_count": 1,
		"fallback_6m_collider_retained": false,
		"structural_visible_collision_congruent": true,
		"landing_geometry_is_lifted_exact_source_roof": true,
		"decorative_overlays_noncolliding_with_hero_wall_behind": true,
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


func _append_stair_end(blue_gray: Dictionary, collision: Dictionary, wall_record: Dictionary, inference: Dictionary, chain_length: float) -> void:
	var width := float(inference.stair_end_width_along_chain)
	var placement := _chain_frame(wall_record, MAPPED_PUBLIC_RUNS, chain_length - width * 0.5)
	if placement.is_empty():
		return
	var anchor := placement.wall_anchor as Vector3
	var tangent := placement.tangent as Vector3
	var normal := placement.normal as Vector3
	var base_y := float(inference.stair_end_base_y)
	var top_y := float(inference.stair_end_top_y)
	var depth := float(inference.stair_end_depth)
	var center := Vector3(anchor.x, (base_y + top_y) * 0.5, anchor.z) + normal * depth * 0.5
	_append_box(blue_gray, center, tangent, normal, width, top_y - base_y, depth)
	_append_box(collision, center, tangent, normal, width, top_y - base_y, depth)


func _append_eave(green: Dictionary, collision: Dictionary, wall_record: Dictionary, inference: Dictionary, chain_length: float) -> void:
	var placement := _chain_frame(wall_record, MAPPED_PUBLIC_RUNS, chain_length * 0.5)
	if placement.is_empty():
		return
	var anchor := placement.wall_anchor as Vector3
	var tangent := placement.tangent as Vector3
	var normal := placement.normal as Vector3
	var depth := float(inference.eave_depth)
	var center := Vector3(anchor.x, float(inference.eave_center_y), anchor.z) + normal * depth * 0.22
	_append_box(green, center, tangent, normal, chain_length, float(inference.eave_height), depth)
	_append_box(collision, center, tangent, normal, chain_length, float(inference.eave_height), depth)


func _append_five_row_facade(blue_gray: Dictionary, green: Dictionary, openings: Dictionary, frames: Dictionary, wall_record: Dictionary, inference: Dictionary) -> void:
	var tier_count := int(inference.tier_count)
	var centers := inference.opening_column_centers_along_chain as Array
	for row_index in range(tier_count):
		var center_y := float(inference.first_row_center_y) + float(row_index) * float(inference.upper_row_pitch)
		var height := float(inference.ground_opening_height) if row_index == 0 else float(inference.upper_opening_height)
		for column_index in range(centers.size()):
			var placement := _chain_frame(wall_record, MAPPED_PUBLIC_RUNS, float(centers[column_index]))
			if placement.is_empty():
				continue
			var tangent := placement.tangent as Vector3
			var normal := placement.normal as Vector3
			var anchor := placement.wall_anchor as Vector3
			var broad := column_index % 2 == 0
			var width := float(inference.broad_opening_width) if broad else float(inference.narrow_opening_width)
			var opening_center := Vector3(anchor.x, center_y, anchor.z) + normal * 0.075
			if row_index == 0 and not broad:
				_append_box(blue_gray, opening_center, tangent, normal, width, height, float(inference.opening_depth))
			else:
				_append_box(openings, opening_center, tangent, normal, width, height, float(inference.opening_depth))
			var frame_center := Vector3(anchor.x, center_y, anchor.z) + normal * 0.14
			_append_frame(frames, frame_center, tangent, normal, width, height, float(inference.frame_member), float(inference.frame_depth))
			if broad:
				var divider_count := int(inference.multi_lite_vertical_dividers)
				for divider_index in range(divider_count):
					var fraction := float(divider_index + 1) / float(divider_count + 1) - 0.5
					_append_box(frames, frame_center + tangent * width * fraction, tangent, normal, float(inference.frame_member) * 0.72, height, float(inference.frame_depth))
				var eyebrow_center := Vector3(anchor.x, center_y + height * 0.5 + float(inference.eyebrow_height), anchor.z) + normal * 0.19
				_append_box(green, eyebrow_center, tangent, normal, width + float(inference.eyebrow_overhang_each_side) * 2.0, float(inference.eyebrow_height), float(inference.eyebrow_depth))
			elif row_index == 0:
				var vent_center := Vector3(anchor.x, float(inference.base_vent_center_y), anchor.z) + normal * 0.13
				_append_box(openings, vent_center, tangent, normal, float(inference.base_vent_width), float(inference.base_vent_height), float(inference.frame_depth))


func _append_frame(bucket: Dictionary, center: Vector3, tangent: Vector3, normal: Vector3, width: float, height: float, member: float, depth: float) -> void:
	_append_box(bucket, center - tangent * (width + member) * 0.5, tangent, normal, member, height + member * 2.0, depth)
	_append_box(bucket, center + tangent * (width + member) * 0.5, tangent, normal, member, height + member * 2.0, depth)
	var top := center
	top.y += (height + member) * 0.5
	var bottom := center
	bottom.y -= (height + member) * 0.5
	_append_box(bucket, top, tangent, normal, width, member, depth)
	_append_box(bucket, bottom, tangent, normal, width, member, depth)


func _append_lifted_wall_run(bucket: Dictionary, record: Dictionary, run_index: int, hero_top_y: float) -> void:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var source_indices := record.indices as Array
	var value_offset := run_index * 12
	var vertex_offset := run_index * 4
	var index_offset := run_index * 6
	var source_points := [
		Vector3(float(values[value_offset]), float(values[value_offset + 1]), float(values[value_offset + 2])),
		Vector3(float(values[value_offset + 3]), float(values[value_offset + 4]), float(values[value_offset + 5])),
		Vector3(float(values[value_offset + 6]), hero_top_y, float(values[value_offset + 8])),
		Vector3(float(values[value_offset + 9]), hero_top_y, float(values[value_offset + 11])),
	]
	var base := (bucket.vertices as Array).size()
	for local_index in range(4):
		var normal_offset := value_offset + local_index * 3
		(bucket.vertices as Array).append(source_points[local_index])
		(bucket.normals as Array).append(Vector3(float(normals[normal_offset]), float(normals[normal_offset + 1]), float(normals[normal_offset + 2])))
		(bucket.uvs as Array).append(Vector2(float((source_points[local_index] as Vector3).x) + float((source_points[local_index] as Vector3).z), float((source_points[local_index] as Vector3).y)))
	for triangle_offset in range(0, 6, 3):
		var first := base + int(source_indices[index_offset + triangle_offset]) - vertex_offset
		var second := base + int(source_indices[index_offset + triangle_offset + 1]) - vertex_offset
		var third := base + int(source_indices[index_offset + triangle_offset + 2]) - vertex_offset
		(bucket.indices as Array).append_array([first, third, second])


func _append_lifted_roof(bucket: Dictionary, record: Dictionary, hero_y: float) -> void:
	var values := record.vertices as Array
	var source_indices := record.indices as Array
	var base := (bucket.vertices as Array).size()
	for offset in range(0, values.size(), 3):
		var point := Vector3(float(values[offset]), hero_y, float(values[offset + 2]))
		(bucket.vertices as Array).append(point)
		(bucket.normals as Array).append(Vector3.UP)
		(bucket.uvs as Array).append(Vector2(point.x, point.z))
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
	body.set_meta("fallback_6m_collider_retained", false)
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
		and is_equal_approx(float(record.get("source_height_m", 0.0)), 6.0) \
		and is_equal_approx(float(record.get("flat_base_elevation_m", 0.0)), 3.39) \
		and is_equal_approx(float(record.get("top_elevation_m", 0.0)), 9.39)


static func _config_contract_matches(config: Dictionary) -> bool:
	if config.is_empty() or str(config.get("schema_version", "")) != "ti.dormitory-369-standalone-hero-prototype/1":
		return false
	var target := config.get("target", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	var mapped := config.get("mapped_public_region", {}) as Dictionary
	var protected := config.get("protected_region", {}) as Dictionary
	var inference := config.get("production_inference_m", {}) as Dictionary
	var topology := config.get("prototype_topology", {}) as Dictionary
	var seam := config.get("future_live_integration_seam", {}) as Dictionary
	if str(target.get("source_key", "")) != SOURCE_KEY \
		or str(target.get("wall_object_key", "")) != WALL_KEY \
		or str(target.get("roof_object_key", "")) != ROOF_KEY \
		or str(target.get("geometry_sha256", "")) != "4ad2f9d3c0e109d194965149b6e73c078e7796d19ec3efdfd8f78df6e9aee3e9" \
		or int(target.get("wall_run_count", 0)) != WALL_RUN_COUNT \
		or int(target.get("wall_vertices", 0)) != 288 \
		or int(target.get("wall_triangles", 0)) != 144 \
		or int(target.get("roof_plan_vertices", 0)) != 34 \
		or int(target.get("roof_triangles", 0)) != 32:
		return false
	if not bool(truth.get("prototype_only", false)) \
		or bool(truth.get("runtime_attachment", true)) \
		or bool(truth.get("recognition_accepted", true)) \
		or bool(truth.get("believability_accepted", true)) \
		or bool(truth.get("as_built_claim", true)) \
		or bool(truth.get("interior_modeled", true)) \
		or bool(truth.get("surveyed_height", true)) \
		or bool(truth.get("surveyed_tier_spacing", true)) \
		or bool(truth.get("surveyed_opening_dimensions", true)) \
		or bool(truth.get("surveyed_opening_count_or_cadence", true)) \
		or bool(truth.get("surveyed_stair_geometry", true)) \
		or bool(truth.get("reference_pixels_stored_or_copied", true)) \
		or bool(truth.get("horizontal_source_footprint_changed", true)) \
		or bool(truth.get("source_identity_changed", true)) \
		or str(truth.get("all_unsurveyed_vertical_opening_and_stair_choices", "")) != "reversible_production_inference":
		return false
	if _int_array(mapped.get("ordered_run_indices", []) as Array) != MAPPED_PUBLIC_RUNS \
		or not is_equal_approx(float(mapped.get("length_m", 0.0)), 49.124) \
		or _int_array(protected.get("run_indices", []) as Array) != PROTECTED_RUNS:
		return false
	if int(inference.get("tier_count", 0)) != 5 \
		or not is_equal_approx(float(inference.get("tier_pitch", 0.0)), 3.0) \
		or not is_equal_approx(float(inference.get("hero_roof_landing_y", 0.0)), 18.39) \
		or int(inference.get("opening_column_count", 0)) != 8 \
		or (inference.get("opening_column_centers_along_chain", []) as Array).size() != 8 \
		or float(inference.get("stair_end_width_along_chain", 0.0)) > 5.6 \
		or float(inference.get("stair_end_depth", 0.0)) > 0.42:
		return false
	var expected_batches := {
		"ProtectedLiftedWallRuns_6_71": 132,
		"AcceptedWarmLiftedWallRuns_0_5": 12,
		"NeutralLiftedRoof": 32,
		"BlueGrayStructuralStairEnd": 12,
		"BlueGrayGroundPanels": 48,
		"GreenStructuralEave": 12,
		"GreenEyebrows": 240,
		"OpaqueExteriorOpeningsAndVents": 480,
		"OpeningFramesAndMultiLiteDividers": 2400,
	}
	if int(topology.get("render_batches", 0)) != 9 \
		or int(topology.get("surfaces", 0)) != 9 \
		or int(topology.get("lifted_source_wall_triangles", 0)) != 144 \
		or int(topology.get("lifted_source_roof_triangles", 0)) != 32 \
		or int(topology.get("new_structural_visual_triangles", 0)) != 24 \
		or int(topology.get("decorative_overlay_triangles", 0)) != 3168 \
		or int(topology.get("total_visual_triangles", 0)) != 3368 \
		or not _batch_triangles_match(topology.get("visual_batch_triangles", {}) as Dictionary, expected_batches) \
		or int(topology.get("static_bodies", 0)) != 1 \
		or int(topology.get("collision_shapes", 0)) != 1 \
		or int(topology.get("collision_triangles", 0)) != 200 \
		or int(topology.get("collision_face_vertices", 0)) != 600 \
		or int(topology.get("navigation_nodes", -1)) != 0 \
		or int(topology.get("spray_owner_nodes", -1)) != 0:
		return false
	return str(seam.get("registry_status", "")) == "not_registered" \
		and str(seam.get("world_builder_status", "")) == "not_attached" \
		and "wall and roof together" in str(seam.get("required_live_behavior", "")) \
		and "never overlay" in str(seam.get("forbidden_partial_attach", ""))


static func _chain_basis(record: Dictionary, runs: Array) -> Dictionary:
	if runs.is_empty():
		return {}
	var first := _run_frame(record, int(runs[0]))
	var last := _run_frame(record, int(runs[runs.size() - 1]))
	if first.is_empty() or last.is_empty():
		return {}
	var length := 0.0
	for run_value: Variant in runs:
		var frame := _run_frame(record, int(run_value))
		if frame.is_empty():
			return {}
		length += float(frame.length_m)
	return {"start": first.start, "end": last.end, "tangent": first.tangent, "normal": first.normal, "length_m": length}


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


static func _batch_triangles_match(actual: Dictionary, expected: Dictionary) -> bool:
	if actual.size() != expected.size():
		return false
	for key: String in expected:
		if int(actual.get(key, -1)) != int(expected[key]):
			return false
	return true


func _clear_children_now() -> void:
	for child in get_children():
		remove_child(child)
		child.free()


static func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "code": code, "message": message}
