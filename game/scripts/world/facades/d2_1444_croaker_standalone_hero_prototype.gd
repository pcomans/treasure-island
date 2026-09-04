class_name D21444CroakerStandaloneHeroPrototype
extends Node3D

const SITE_12_KIT := preload("res://game/scripts/world/facades/site_12_housing_kit.gd")
const CONFIG_PATH := "res://game/resources/facades/d2_1444_croaker_standalone_hero_prototype.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_-1.json"
const SOURCE_KEY := "w95934117"
const WALL_KEY := "building:w95934117:wall"
const ROOF_KEY := "building:w95934117:roof"
const SOURCE_GEOMETRY_SHA256 := "52c844ec3cbeae52b97e12014dac8761c8518b6b4e5ce6df5eeee64256eadcc4"
const WALL_RUN_COUNT := 22
const TARGET_RUNS := [8, 9, 11, 12, 15, 16, 17]
const BLANK_END_RUNS := [8, 9]
const SPARSE_OPENING_RUNS := [11, 16]
const BALCONY_RUNS := [17]
const QUIET_MAPPED_RUNS := [12, 15]
const PROTECTED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 10, 13, 14, 18, 19, 20, 21]
const EXPECTED_WALL_RECORD_SHA256 := "1497487d53fc7eeb98f8399fd8fc47c159c2652e68a486ce496b860fddcfffb6"
const EXPECTED_ROOF_RECORD_SHA256 := "a4e69552758e9f2927c40a5d4021c8b4cd7dcf7c065f3b78c235219e4fe0eb7a"
const PHYSICS_WORLD_SOLID := 1 << 0
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1

const TARGET_STUCCO := preload("res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres")
const PROTECTED_NEUTRAL := preload("res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres")
const DARK_ROOF := preload("res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres")
const VOID_SHADOW := preload("res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres")
const OPAQUE_OPENING := preload("res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres")
const DARK_METAL := preload("res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres")

@export var auto_configure_from_frozen_source := true

var _configured := false
var _last_result: Dictionary = {}


func _ready() -> void:
	if auto_configure_from_frozen_source and not _configured:
		var result := configure_from_frozen_source()
		if not bool(result.get("ok", false)):
			push_error("1444 Croaker standalone hero failed closed: %s" % str(result.get("message", "unknown error")))


static func matches_record_pair(wall_record: Dictionary, roof_record: Dictionary) -> bool:
	return _record_contract_matches(wall_record, WALL_KEY, "building_wall", 264, 132, EXPECTED_WALL_RECORD_SHA256) \
		and _record_contract_matches(roof_record, ROOF_KEY, "building_roof", 36, 30, EXPECTED_ROOF_RECORD_SHA256)


static func record_signature(record: Dictionary) -> String:
	var payload := {
		"object_key": record.get("object_key", ""),
		"source_keys": record.get("source_keys", []),
		"feature_kind": record.get("feature_kind", ""),
		"collision_kind": record.get("collision_kind", ""),
		"receiver_kind": record.get("receiver_kind", ""),
		"opaque": record.get("opaque", false),
		"source_height_m": record.get("source_height_m", 0.0),
		"flat_base_elevation_m": record.get("flat_base_elevation_m", 0.0),
		"top_elevation_m": record.get("top_elevation_m", 0.0),
		"vertices": record.get("vertices", []),
		"normals": record.get("normals", []),
		"uvs": record.get("uvs", []),
		"indices": record.get("indices", []),
	}
	return JSON.stringify(payload).sha256_text()


static func build_for_records(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	var prototype := D21444CroakerStandaloneHeroPrototype.new()
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
		return _failure("d2_1444_source_chunk", "Frozen x_-2__z_-1 source chunk could not be loaded.")
	var wall_record := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof_record := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	return configure_records(wall_record, roof_record)


func configure_records(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	if _configured:
		return _failure("d2_1444_duplicate_configuration", "The standalone 1444 Croaker prototype is already configured.")
	var config := _json(CONFIG_PATH)
	if not _config_contract_matches(config):
		return _failure("d2_1444_config_contract", "The standalone 1444 Croaker truth/configuration contract drifted.")
	if not matches_record_pair(wall_record, roof_record):
		return _failure(
			"d2_1444_source_contract",
			"Exact w95934117 wall+roof pair mismatch. Actual signatures: wall=%s roof=%s" % [record_signature(wall_record), record_signature(roof_record)]
		)

	var protected_walls := SITE_12_KIT.new_bucket()
	var target_walls := SITE_12_KIT.new_bucket()
	var roof := SITE_12_KIT.new_bucket()
	var eaves := SITE_12_KIT.new_bucket()
	var undercroft_voids := SITE_12_KIT.new_bucket()
	var undercroft_frames := SITE_12_KIT.new_bucket()
	var sparse_openings := SITE_12_KIT.new_bucket()
	var opening_frames := SITE_12_KIT.new_bucket()
	var balcony_voids := SITE_12_KIT.new_bucket()
	var balcony_slabs := SITE_12_KIT.new_bucket()
	var rails := SITE_12_KIT.new_bucket()
	var collision := SITE_12_KIT.new_bucket()
	var inference := config.production_inference_m as Dictionary

	for run_index in range(WALL_RUN_COUNT):
		SITE_12_KIT.append_source_wall_run(target_walls if run_index in TARGET_RUNS else protected_walls, wall_record, run_index)
		SITE_12_KIT.append_source_wall_run(collision, wall_record, run_index)
	_append_exact_plan_gable(roof, roof_record, wall_record, inference)
	_append_exact_plan_gable(collision, roof_record, wall_record, inference)

	for run_index: int in TARGET_RUNS:
		var frame := SITE_12_KIT.run_frame(wall_record, run_index)
		if frame.is_empty():
			_clear_children_now()
			return _failure("d2_1444_target_run", "Mapped WSW run %d could not be resolved." % run_index)
		var run_mid := frame.midpoint as Vector3
		var eave_center := Vector3(run_mid.x, float(config.target.source_wall_top_y_m) + float(inference.eave_height) * 0.5, run_mid.z)
		SITE_12_KIT.append_eave_band(
			eaves,
			eave_center,
			frame.tangent as Vector3,
			frame.normal as Vector3,
			float(frame.length_m) + float(inference.eave_side_overhang) * 2.0,
			float(inference.eave_height),
			float(inference.eave_depth)
		)

	var undercroft_void_count := 0
	for run_index: int in BLANK_END_RUNS:
		var frame := SITE_12_KIT.run_frame(wall_record, run_index)
		var width := float(frame.length_m) - float(inference.undercroft_side_margin) * 2.0
		if width <= 1.0:
			_clear_children_now()
			return _failure("d2_1444_undercroft_width", "Mapped blank-end run %d is too short for its bounded undercroft field." % run_index)
		var void_center := frame.midpoint as Vector3
		void_center.y = float(inference.undercroft_center_y)
		SITE_12_KIT.append_box(
			undercroft_voids,
			void_center + (frame.normal as Vector3) * float(inference.undercroft_visual_depth) * 0.5,
			frame.tangent as Vector3,
			frame.normal as Vector3,
			width,
			float(inference.undercroft_height),
			float(inference.undercroft_visual_depth)
		)
		var beam_center := frame.midpoint as Vector3
		beam_center.y = float(inference.undercroft_center_y) + float(inference.undercroft_height) * 0.5 + float(inference.undercroft_head_beam_height) * 0.5
		SITE_12_KIT.append_box(
			undercroft_frames,
			beam_center + (frame.normal as Vector3) * float(inference.undercroft_head_beam_depth) * 0.5,
			frame.tangent as Vector3,
			frame.normal as Vector3,
			float(frame.length_m) + 0.08,
			float(inference.undercroft_head_beam_height),
			float(inference.undercroft_head_beam_depth)
		)
		undercroft_void_count += 1

	var blank_frame := SITE_12_KIT.run_frame(wall_record, 8)
	var blank_end_frame := SITE_12_KIT.run_frame(wall_record, 9)
	var pier_positions: Array[Vector3] = [blank_frame.start as Vector3, blank_frame.end as Vector3, blank_end_frame.end as Vector3]
	for pier_position: Vector3 in pier_positions:
		pier_position.y = float(config.target.source_base_y_m) + float(inference.undercroft_pier_height) * 0.5
		SITE_12_KIT.append_box(
			undercroft_frames,
			pier_position + (blank_frame.normal as Vector3) * float(inference.undercroft_pier_depth) * 0.5,
			blank_frame.tangent as Vector3,
			blank_frame.normal as Vector3,
			float(inference.undercroft_pier_width),
			float(inference.undercroft_pier_height),
			float(inference.undercroft_pier_depth)
		)

	var sparse_opening_count := 0
	for run_index: int in SPARSE_OPENING_RUNS:
		var frame := SITE_12_KIT.run_frame(wall_record, run_index)
		var fractions: Array = inference.run_11_opening_fractions as Array if run_index == 11 else inference.run_16_opening_fractions as Array
		for row_y: float in [float(inference.lower_row_center_y), float(inference.upper_row_center_y)]:
			for fraction_value: Variant in fractions:
				var anchor := (frame.start as Vector3).lerp(frame.end as Vector3, float(fraction_value))
				anchor.y = row_y
				SITE_12_KIT.append_grouped_opening(
					sparse_openings,
					opening_frames,
					anchor,
					frame.tangent as Vector3,
					frame.normal as Vector3,
					float(inference.opening_width),
					float(inference.opening_height),
					float(inference.opening_depth),
					float(inference.opening_frame_member),
					float(inference.opening_frame_depth),
					float(inference.opening_mullion_width)
				)
				sparse_opening_count += 1

	var balcony_void_count := 0
	var rail_picket_count := 0
	for run_index: int in BALCONY_RUNS:
		var frame := SITE_12_KIT.run_frame(wall_record, run_index)
		var bay_width := float(frame.length_m) - float(inference.balcony_side_margin) * 2.0
		if bay_width <= 1.0:
			_clear_children_now()
			return _failure("d2_1444_balcony_width", "Mapped far-end run %d is too short for its bounded balcony stack." % run_index)
		for row_y: float in [float(inference.lower_row_center_y), float(inference.upper_row_center_y)]:
			var anchor := frame.midpoint as Vector3
			anchor.y = row_y
			rail_picket_count += SITE_12_KIT.append_recessed_balcony_or_breezeway(
				balcony_voids,
				balcony_slabs,
				rails,
				anchor,
				frame.tangent as Vector3,
				frame.normal as Vector3,
				bay_width,
				float(inference.balcony_void_height),
				float(inference.balcony_void_depth),
				float(inference.balcony_slab_height),
				float(inference.balcony_slab_depth),
				row_y + float(inference.rail_center_above_row_center),
				float(inference.rail_height),
				float(inference.rail_top_and_bottom_member),
				float(inference.rail_picket_width),
				float(inference.rail_picket_spacing),
				float(inference.rail_depth)
			)
			balcony_void_count += 1

	var specs: Array[Dictionary] = [
		{"name": "ProtectedExactWallRuns", "bucket": protected_walls, "material": PROTECTED_NEUTRAL, "layers": RENDER_BUILDING_WALL},
		{"name": "MappedWSWExactOchreStuccoWallRuns", "bucket": target_walls, "material": TARGET_STUCCO, "layers": RENDER_BUILDING_WALL},
		{"name": "ExactPlanShallowGableRoof", "bucket": roof, "material": DARK_ROOF, "layers": RENDER_WORLD_VISIBLE},
		{"name": "MappedWSWBroadEaves", "bucket": eaves, "material": DARK_ROOF, "layers": RENDER_BUILDING_WALL},
		{"name": "BlankEndUndercroftOpaqueShadow", "bucket": undercroft_voids, "material": VOID_SHADOW, "layers": RENDER_BUILDING_WALL},
		{"name": "BlankEndUndercroftOchreFrame", "bucket": undercroft_frames, "material": TARGET_STUCCO, "layers": RENDER_BUILDING_WALL},
		{"name": "SparseReturnOpaqueOpenings", "bucket": sparse_openings, "material": OPAQUE_OPENING, "layers": RENDER_BUILDING_WALL},
		{"name": "SparseReturnOchreOpeningFrames", "bucket": opening_frames, "material": TARGET_STUCCO, "layers": RENDER_BUILDING_WALL},
		{"name": "FarEndRecessedTwoLevelOpaqueVoids", "bucket": balcony_voids, "material": VOID_SHADOW, "layers": RENDER_BUILDING_WALL},
		{"name": "FarEndBalconyOchreSlabs", "bucket": balcony_slabs, "material": TARGET_STUCCO, "layers": RENDER_BUILDING_WALL},
		{"name": "FarEndSimpleMetalRails", "bucket": rails, "material": DARK_METAL, "layers": RENDER_BUILDING_WALL},
	]
	var visual_triangles := 0
	var mesh_instances := 0
	var batch_triangles := {}
	for spec: Dictionary in specs:
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
		return _failure("d2_1444_collision", "The standalone structural collision bucket was empty.")
	add_child(body)
	var collision_triangles := int((collision.indices as Array).size() / 3)
	var signature_payload := {
		"model_id": str(config.model_id),
		"kit_id": SITE_12_KIT.KIT_ID,
		"source_geometry_sha256": SOURCE_GEOMETRY_SHA256,
		"wall_record_sha256": record_signature(wall_record),
		"roof_record_sha256": record_signature(roof_record),
		"production_inference_m": inference,
		"target_runs": TARGET_RUNS,
		"blank_end_runs": BLANK_END_RUNS,
		"sparse_opening_runs": SPARSE_OPENING_RUNS,
		"balcony_runs": BALCONY_RUNS,
		"quiet_mapped_runs": QUIET_MAPPED_RUNS,
		"protected_runs": PROTECTED_RUNS,
		"batch_triangles": batch_triangles,
		"collision_triangles": collision_triangles,
	}
	var deterministic_signature := JSON.stringify(signature_payload).sha256_text()
	var metadata := {
		"model_id": str(config.model_id),
		"kit_id": SITE_12_KIT.KIT_ID,
		"config_path": CONFIG_PATH,
		"source_key": SOURCE_KEY,
		"wall_object_key": WALL_KEY,
		"roof_object_key": ROOF_KEY,
		"source_geometry_sha256": SOURCE_GEOMETRY_SHA256,
		"wall_record_sha256": record_signature(wall_record),
		"roof_record_sha256": record_signature(roof_record),
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
		"source_wall_height_changed": false,
		"source_photography_shipped": false,
		"mapped_public_run_indices": TARGET_RUNS.duplicate(),
		"blank_end_run_indices": BLANK_END_RUNS.duplicate(),
		"sparse_opening_run_indices": SPARSE_OPENING_RUNS.duplicate(),
		"balcony_run_indices": BALCONY_RUNS.duplicate(),
		"quiet_mapped_run_indices": QUIET_MAPPED_RUNS.duplicate(),
		"protected_run_indices": PROTECTED_RUNS.duplicate(),
		"protected_runs_have_facade_modules": false,
		"undercroft_void_count": undercroft_void_count,
		"undercroft_pier_count": pier_positions.size(),
		"sparse_opening_count": sparse_opening_count,
		"balcony_void_count": balcony_void_count,
		"rail_picket_count": rail_picket_count,
		"mapped_eave_count": TARGET_RUNS.size(),
		"fallback_collider_retained": false,
		"structural_visible_collision_congruent": true,
		"facade_relief_noncolliding_with_source_wall_behind": true,
		"spray_ownership": "none_standalone",
		"meter_uv_geometry_units": "meters",
		"generated_new_albedo_texture": false,
		"generated_normal_or_roughness_maps": false,
		"mesh_instances": mesh_instances,
		"surfaces": mesh_instances,
		"visual_triangles": visual_triangles,
		"visual_batch_triangles": batch_triangles,
		"static_bodies": 1,
		"shapes": 1,
		"collision_triangles": collision_triangles,
		"collision_face_vertices": collision_triangles * 3,
		"navigation_nodes": 0,
		"spray_owner_nodes": 0,
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


func _append_exact_plan_gable(bucket: Dictionary, roof_record: Dictionary, wall_record: Dictionary, inference: Dictionary) -> void:
	var values := roof_record.vertices as Array
	var source_indices := roof_record.indices as Array
	var public_frame := SITE_12_KIT.run_frame(wall_record, 8)
	var tangent := public_frame.tangent as Vector3
	var outward := public_frame.normal as Vector3
	var projection_min := INF
	var projection_max := -INF
	for offset in range(0, values.size(), 3):
		var source_point := Vector3(float(values[offset]), 0.0, float(values[offset + 2]))
		var projection := source_point.dot(outward)
		projection_min = minf(projection_min, projection)
		projection_max = maxf(projection_max, projection)
	var projection_mid := (projection_min + projection_max) * 0.5
	var projection_half := (projection_max - projection_min) * 0.5
	for index_offset in range(0, source_indices.size(), 3):
		var triangle: Array[Vector3] = []
		for local_index in range(3):
			var source_vertex_index := int(source_indices[index_offset + local_index])
			var source_offset := source_vertex_index * 3
			var point := Vector3(float(values[source_offset]), 0.0, float(values[source_offset + 2]))
			var ridge_factor := 1.0 - absf(point.dot(outward) - projection_mid) / projection_half
			point.y = float(roof_record.top_elevation_m) + float(inference.roof_edge_lift) + maxf(0.0, ridge_factor) * float(inference.roof_ridge_rise)
			triangle.append(point)
		_append_meter_triangle(bucket, triangle[0], triangle[1], triangle[2], tangent, outward)


func _append_meter_triangle(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, tangent: Vector3, roof_cross_axis: Vector3) -> void:
	var normal := (b - a).cross(c - a).normalized()
	if normal.y < 0.0:
		var swap := b
		b = c
		c = swap
		normal = -normal
	var base := (bucket.vertices as Array).size()
	for point: Vector3 in [a, b, c]:
		(bucket.vertices as Array).append(point)
		(bucket.normals as Array).append(normal)
		(bucket.uvs as Array).append(Vector2(point.dot(tangent), point.dot(roof_cross_axis)))
	(bucket.indices as Array).append_array([base, base + 1, base + 2])


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
	shape_node.name = "ExactFootprintStructuralShape"
	shape_node.shape = shape
	var body := StaticBody3D.new()
	body.name = "ExactFootprintStructuralCollision_NoSprayOwnership"
	body.collision_layer = PHYSICS_WORLD_SOLID
	body.collision_mask = 0
	body.set_meta("receiver_kind", "none")
	body.set_meta("opaque", true)
	body.set_meta("derived_object_key", "prototype:%s" % WALL_KEY)
	body.set_meta("source_keys", [SOURCE_KEY])
	body.set_meta("prototype_only", true)
	body.set_meta("runtime_attachment", false)
	body.set_meta("spray_ownership", "none_standalone")
	body.set_meta("fallback_collider_retained", false)
	body.set_meta("structural_visible_collision_congruent", true)
	body.add_child(shape_node)
	return body


static func _record_contract_matches(record: Dictionary, object_key: String, feature_kind: String, vertex_value_count: int, index_count: int, expected_signature: String) -> bool:
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
		and is_equal_approx(float(record.get("flat_base_elevation_m", 0.0)), 2.521) \
		and is_equal_approx(float(record.get("top_elevation_m", 0.0)), 8.521) \
		and record_signature(record) == expected_signature


static func _config_contract_matches(config: Dictionary) -> bool:
	if config.is_empty() or str(config.get("schema_version", "")) != "ti.d2-1444-croaker-standalone-hero-prototype/1":
		return false
	var target := config.get("target", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	var mapped := config.get("mapped_public_region", {}) as Dictionary
	var protected := config.get("protected_region", {}) as Dictionary
	var uv_contract := config.get("meter_uv_contract", {}) as Dictionary
	var kit_contract := config.get("site_12_kit_contract", {}) as Dictionary
	var seam := config.get("future_live_integration_seam", {}) as Dictionary
	var confusion := config.get("confusion_set", []) as Array
	return str(config.get("model_id", "")) == "d2-1444-croaker-standalone-hero-prototype-v1" \
		and str(target.get("source_key", "")) == SOURCE_KEY \
		and str(target.get("wall_object_key", "")) == WALL_KEY \
		and str(target.get("roof_object_key", "")) == ROOF_KEY \
		and str(target.get("source_geometry_sha256", "")) == SOURCE_GEOMETRY_SHA256 \
		and int(target.get("wall_run_count", 0)) == WALL_RUN_COUNT \
		and int(target.get("wall_vertices", 0)) == 88 \
		and int(target.get("wall_triangles", 0)) == 44 \
		and int(target.get("roof_plan_vertices", 0)) == 12 \
		and int(target.get("roof_triangles", 0)) == 10 \
		and bool(truth.get("prototype_only", false)) \
		and not bool(truth.get("runtime_attachment", true)) \
		and not bool(truth.get("recognition_accepted", true)) \
		and not bool(truth.get("believability_accepted", true)) \
		and not bool(truth.get("as_built_claim", true)) \
		and not bool(truth.get("interior_modeled", true)) \
		and not bool(truth.get("reference_pixels_stored_or_copied", true)) \
		and not bool(truth.get("horizontal_source_footprint_changed", true)) \
		and not bool(truth.get("source_wall_height_changed", true)) \
		and _int_array(mapped.get("ordered_run_indices", []) as Array) == TARGET_RUNS \
		and is_equal_approx(float(mapped.get("total_length_m", 0.0)), 32.864) \
		and _int_array(protected.get("run_indices", []) as Array) == PROTECTED_RUNS \
		and str(uv_contract.get("geometry_uv_units", "")) == "one UV unit equals one modeled meter" \
		and not bool(uv_contract.get("generated_normal_or_roughness_maps", true)) \
		and str(kit_contract.get("kit_id", "")) == SITE_12_KIT.KIT_ID \
		and str(seam.get("registry_status", "")) == "not_registered" \
		and str(seam.get("world_builder_status", "")) == "not_attached" \
		and _confusion_contract_matches(confusion)


static func _confusion_contract_matches(confusion: Array) -> bool:
	if confusion.size() != 3:
		return false
	var expected := {
		"1431 Halibut Court": "w95934135",
		"1436 Chinook Court": "w95934137",
		"1449 Croaker Court": "w95934120",
	}
	for value: Variant in confusion:
		var item := value as Dictionary
		if str(expected.get(str(item.get("name", "")), "")) != str(item.get("source_key", "")):
			return false
	return true


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


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _clear_children_now() -> void:
	for child in get_children():
		remove_child(child)
		child.free()


static func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "code": code, "message": message}
