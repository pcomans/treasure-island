class_name D21439ChinookQualityV2Prototype
extends Node3D

const SITE_12_KIT := preload("res://game/scripts/world/facades/site_12_housing_kit.gd")
const CONFIG_PATH := "res://game/resources/facades/d2_1439_chinook_quality_v2_prototype.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_0.json"
const SOURCE_KEY := "w95934144"
const WALL_KEY := "building:w95934144:wall"
const ROOF_KEY := "building:w95934144:roof"
const SOURCE_GEOMETRY_SHA256 := "a59bd2abf2020c25071a55ecb96f32b7871a810e8d1bdd95c213b512273f87f2"
const WALL_RUN_COUNT := 24
const TARGET_RUNS := [11, 12, 16, 17, 18, 19, 22, 23]
const MOTIF_HOST_RUNS := [11, 19, 23]
const MAPPED_MOTIF_FREE_RUNS := [12, 16, 17, 18, 22]
const TINY_FRAGMENT_RUNS := [17, 18]
const BALCONY_RUN := 11
const QUIET_REGISTER_RUN := 19
const PASSAGE_RUN := 23
const PROTECTED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 20, 21]
const EAVE_CHAINS := [[11, 12], [16, 17, 18, 19], [22, 23]]
const EXPECTED_WALL_RECORD_SHA256 := "a801ff083961a7fafab455d18a80f2ea3ea87791ad5e967f91937ad3fc2b82a0"
const EXPECTED_ROOF_RECORD_SHA256 := "83ea383a9a490871fbd7891ebb5a179adfe0af5e27607e727550563a27c20e58"
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1

const TARGET_STUCCO := preload("res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres")
const PROTECTED_NEUTRAL := preload("res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres")
const DARK_ROOF := preload("res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres")
const RECESS_BACKING := preload("res://game/resources/materials/world/site_12_housing/d2_1439_quality_v2_recess_backing.tres")
const OPAQUE_OPENING := preload("res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres")
const DARK_METAL := preload("res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres")

@export var auto_configure_from_frozen_source := true

var _configured := false
var _last_result: Dictionary = {}


func _ready() -> void:
	if auto_configure_from_frozen_source and not _configured:
		var result := configure_from_frozen_source()
		if not bool(result.get("ok", false)):
			push_error("1439 Chinook standalone hero failed closed: %s" % str(result.get("message", "unknown error")))


static func matches_record_pair(wall_record: Dictionary, roof_record: Dictionary) -> bool:
	return _record_contract_matches(wall_record, WALL_KEY, "building_wall", 288, 144, EXPECTED_WALL_RECORD_SHA256) \
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
	var prototype := D21439ChinookQualityV2Prototype.new()
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
		return _failure("d2_1439_source_chunk", "Frozen x_-2__z_0 source chunk could not be loaded.")
	var wall_record := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof_record := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	return configure_records(wall_record, roof_record)


func configure_records(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	if _configured:
		return _failure("d2_1439_duplicate_configuration", "The standalone 1439 Chinook prototype is already configured.")
	var config := _json(CONFIG_PATH)
	if not _config_contract_matches(config):
		return _failure("d2_1439_config_contract", "The standalone 1439 Chinook truth/configuration contract drifted.")
	if not matches_record_pair(wall_record, roof_record):
		return _failure(
			"d2_1439_source_contract",
			"Exact w95934144 wall+roof pair mismatch. Actual signatures: wall=%s roof=%s" % [record_signature(wall_record), record_signature(roof_record)]
		)

	var protected_walls := SITE_12_KIT.new_bucket()
	var target_walls := SITE_12_KIT.new_bucket()
	var roof := SITE_12_KIT.new_bucket()
	var eaves := SITE_12_KIT.new_bucket()
	var balcony_voids := SITE_12_KIT.new_bucket()
	var balcony_slabs := SITE_12_KIT.new_bucket()
	var balcony_rails := SITE_12_KIT.new_bucket()
	var quiet_upper_openings := SITE_12_KIT.new_bucket()
	var quiet_upper_frames := SITE_12_KIT.new_bucket()
	var passage_void := SITE_12_KIT.new_bucket()
	var passage_frame := SITE_12_KIT.new_bucket()
	var collision := SITE_12_KIT.new_bucket()
	var closure_collision := SITE_12_KIT.new_bucket()
	var roof_collision := SITE_12_KIT.new_bucket()
	var inference := config.production_inference_m as Dictionary

	for run_index in range(WALL_RUN_COUNT):
		if run_index in [BALCONY_RUN, PASSAGE_RUN]:
			_append_cut_host(target_walls, collision, wall_record, run_index, inference)
		else:
			SITE_12_KIT.append_source_wall_run(target_walls if run_index in TARGET_RUNS else protected_walls, wall_record, run_index)
			SITE_12_KIT.append_source_wall_run(collision, wall_record, run_index)
	_append_exact_plan_gable(roof, roof_record, wall_record, inference)
	_append_exact_plan_gable(roof_collision, roof_record, wall_record, inference)

	for chain_value: Variant in EAVE_CHAINS:
		var chain := chain_value as Array
		if not _append_eave_chain(eaves, wall_record, int(chain.front()), int(chain.back()), config, inference):
			_clear_children_now()
			return _failure("d2_1439_eave_chain", "A mapped SSE eave chain could not be resolved as one continuous field.")

	var balcony_frame := _recess_frame(wall_record, BALCONY_RUN)
	var rail_picket_count := 0
	var balcony_void_count := 0
	for opening: Dictionary in _apertures(wall_record, BALCONY_RUN, inference):
		_append_closed_recess(balcony_voids, balcony_slabs, closure_collision, balcony_frame, opening, float(inference.closed_recess_depth))
		# Retain the usable five-picket rail, now attached between the actual
		# mouth edges. Decorative metal remains noncolliding, as in the prototype.
		var rail_depth := float(inference.rail_depth)
		var rail_center := _recess_point(balcony_frame, (float(opening.left) + float(opening.right)) * 0.5,
			float(opening.bottom) + 0.74, -rail_depth * 0.5)
		rail_picket_count += SITE_12_KIT.append_simple_rail(balcony_rails, rail_center,
			balcony_frame.tangent as Vector3, balcony_frame.normal as Vector3,
			float(opening.right) - float(opening.left), float(inference.rail_height), float(inference.rail_top_and_bottom_member),
			float(inference.rail_picket_width), float(inference.rail_picket_spacing), rail_depth)
		balcony_void_count += 1

	var quiet_frame := SITE_12_KIT.run_frame(wall_record, QUIET_REGISTER_RUN)
	if quiet_frame.is_empty():
		return _failure("d2_1439_quiet_register_run", "Mapped quiet-register host run 19 could not be resolved.")
	var quiet_upper_opening_count := 0
	for fraction_value: Variant in inference.quiet_register_opening_fractions as Array:
		var opening_anchor := (quiet_frame.start as Vector3).lerp(quiet_frame.end as Vector3, float(fraction_value))
		opening_anchor.y = float(inference.upper_row_center_y)
		SITE_12_KIT.append_grouped_opening(
			quiet_upper_openings,
			quiet_upper_frames,
			opening_anchor,
			quiet_frame.tangent as Vector3,
			quiet_frame.normal as Vector3,
			float(inference.upper_opening_width),
			float(inference.upper_opening_height),
			float(inference.upper_opening_depth),
			float(inference.opening_frame_member),
			float(inference.opening_frame_depth),
			float(inference.opening_mullion_width)
		)
		quiet_upper_opening_count += 1

	var passage_host := _recess_frame(wall_record, PASSAGE_RUN)
	for opening: Dictionary in _apertures(wall_record, PASSAGE_RUN, inference):
		_append_closed_recess(passage_void, passage_frame, closure_collision, passage_host, opening, float(inference.closed_recess_depth))

	var specs: Array[Dictionary] = [
		{"name": "ProtectedExactWallRuns", "bucket": protected_walls, "material": PROTECTED_NEUTRAL, "layers": RENDER_BUILDING_WALL},
		{"name": "MappedSSEExactWarmStuccoWallRuns", "bucket": target_walls, "material": TARGET_STUCCO, "layers": RENDER_BUILDING_WALL},
		{"name": "ExactPlanShallowGableRoof", "bucket": roof, "material": DARK_ROOF, "layers": RENDER_WORLD_VISIBLE},
		{"name": "MappedSSEContinuousEaveChains", "bucket": eaves, "material": DARK_ROOF, "layers": RENDER_BUILDING_WALL},
		{"name": "OffsetEndTwoLevelBalconyVoids", "bucket": balcony_voids, "material": RECESS_BACKING, "layers": RENDER_WORLD_VISIBLE},
		{"name": "OffsetEndBalconySlabsAndSideReturns", "bucket": balcony_slabs, "material": TARGET_STUCCO, "layers": RENDER_WORLD_VISIBLE},
		{"name": "OffsetEndSimpleMetalRails", "bucket": balcony_rails, "material": DARK_METAL, "layers": RENDER_WORLD_VISIBLE},
		{"name": "QuietRegisterUpperOpaqueOpenings", "bucket": quiet_upper_openings, "material": OPAQUE_OPENING, "layers": RENDER_BUILDING_WALL},
		{"name": "QuietRegisterUpperPaleFrames", "bucket": quiet_upper_frames, "material": TARGET_STUCCO, "layers": RENDER_BUILDING_WALL},
		{"name": "BlankEndGroundPassageShadow", "bucket": passage_void, "material": RECESS_BACKING, "layers": RENDER_WORLD_VISIBLE},
		{"name": "BlankEndGroundPassageFrame", "bucket": passage_frame, "material": TARGET_STUCCO, "layers": RENDER_WORLD_VISIBLE},
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

	var body := _collision_body(collision, closure_collision, roof_collision)
	if body == null:
		_clear_children_now()
		return _failure("d2_1439_collision", "The standalone structural collision bucket was empty.")
	add_child(body)
	var collision_triangles := int(((collision.indices as Array).size() + (closure_collision.indices as Array).size() + (roof_collision.indices as Array).size()) / 3)
	var signature_payload := {
		"model_id": str(config.model_id),
		"kit_id": SITE_12_KIT.KIT_ID,
		"source_geometry_sha256": SOURCE_GEOMETRY_SHA256,
		"wall_record_sha256": record_signature(wall_record),
		"roof_record_sha256": record_signature(roof_record),
		"production_inference_m": inference,
		"target_runs": TARGET_RUNS,
		"motif_host_runs": MOTIF_HOST_RUNS,
		"mapped_motif_free_runs": MAPPED_MOTIF_FREE_RUNS,
		"tiny_fragment_runs": TINY_FRAGMENT_RUNS,
		"protected_runs": PROTECTED_RUNS,
		"eave_chains": EAVE_CHAINS,
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
		"motif_host_run_indices": MOTIF_HOST_RUNS.duplicate(),
		"mapped_motif_free_run_indices": MAPPED_MOTIF_FREE_RUNS.duplicate(),
		"tiny_fragment_run_indices": TINY_FRAGMENT_RUNS.duplicate(),
		"protected_run_indices": PROTECTED_RUNS.duplicate(),
		"protected_runs_have_facade_modules": false,
		"mapped_motif_free_runs_have_addressable_motifs": false,
		"balcony_void_count": balcony_void_count,
		"balcony_side_return_count": 4,
		"passage_floor_return_triangles": 2,
		"quality_v2_revision": 3,
		"rail_picket_count": rail_picket_count,
		"quiet_upper_opening_count": quiet_upper_opening_count,
		"passage_void_count": 1,
		"passage_pier_count": 2,
		"mapped_eave_chain_count": EAVE_CHAINS.size(),
		"mapped_eave_covered_run_indices": TARGET_RUNS.duplicate(),
		"fallback_collider_retained": false,
		"structural_visible_collision_congruent": true,
		"decorative_rails_noncolliding": true,
		"closed_recess_count": 3,
		"recess_depth_m": float(inference.closed_recess_depth),
		"eligible_wall_triangles": int((collision.indices as Array).size() / 3),
		"noneligible_recess_triangles": int((closure_collision.indices as Array).size() / 3),
		"spray_ownership": "explicit_exterior_wall_only_standalone",
		"meter_uv_geometry_units": "meters",
		"generated_new_albedo_texture": false,
		"generated_normal_or_roughness_maps": false,
		"mesh_instances": mesh_instances,
		"surfaces": mesh_instances,
		"visual_triangles": visual_triangles,
		"visual_batch_triangles": batch_triangles,
		"static_bodies": 1,
		"shapes": 3,
		"collision_triangles": collision_triangles,
		"collision_face_vertices": collision_triangles * 3,
		"navigation_nodes": 0,
		"spray_owner_nodes": 1,
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
		"shapes": 3,
	}
	return _last_result.duplicate(true)


static func _recess_frame(record: Dictionary, run: int) -> Dictionary:
	var frame := SITE_12_KIT.run_frame(record, run)
	var tangent := frame.tangent as Vector3
	var normal := Vector3(-tangent.z, 0.0, tangent.x)
	if normal.dot(frame.normal as Vector3) < 0.0:
		normal = -normal
	frame.normal = normal
	return frame


static func _apertures(record: Dictionary, run: int, inference: Dictionary) -> Array[Dictionary]:
	var frame := _recess_frame(record, run)
	var is_balcony := run == BALCONY_RUN
	var width := float(inference.balcony_width) - 2.0 * float(inference.balcony_side_return_width) if is_balcony else float(inference.passage_width)
	var center := float(frame.length_m) * float(inference.balcony_anchor_fraction if is_balcony else inference.passage_anchor_fraction)
	var result: Array[Dictionary] = []
	var rows: Array = [inference.lower_row_center_y, inference.upper_row_center_y] if is_balcony else [inference.passage_center_y]
	for y: float in rows:
		var height := float(inference.balcony_void_height if is_balcony else inference.passage_height)
		result.append({"left": center - width * 0.5, "right": center + width * 0.5,
			"bottom": y - height * 0.5 + (float(inference.balcony_slab_height) if is_balcony else 0.0), "top": y + height * 0.5})
	return result


static func _recess_point(frame: Dictionary, station: float, y: float, depth: float) -> Vector3:
	var point := (frame.start as Vector3) + (frame.tangent as Vector3) * station + (frame.normal as Vector3) * depth
	point.y = y
	return point


func _append_cut_host(visual: Dictionary, collision: Dictionary, record: Dictionary, run: int, inference: Dictionary) -> void:
	var frame := _recess_frame(record, run)
	var openings := _apertures(record, run, inference)
	var first := openings.front() as Dictionary
	var length := float(frame.length_m)
	var base := float((frame.start as Vector3).y)
	var top := float((record.vertices as Array)[run * 12 + 7])
	var rectangles: Array = [[0.0, float(first.left), base, top], [float(first.right), length, base, top]]
	var previous_y := base
	for opening: Dictionary in openings:
		rectangles.append([float(opening.left), float(opening.right), previous_y, float(opening.bottom)])
		previous_y = float(opening.top)
	rectangles.append([float(first.left), float(first.right), previous_y, top])
	for rect: Array in rectangles:
		var bottom_a := float(rect[2])
		var bottom_b := float(rect[2])
		if is_equal_approx(bottom_a, base):
			# Preserve the exact source terrain-following bottom edge, including
			# its unequal endpoint heights on both supported aperture hosts.
			bottom_a = lerpf(base, (frame.end as Vector3).y, float(rect[0]) / length)
			bottom_b = lerpf(base, (frame.end as Vector3).y, float(rect[1]) / length)
		var a := _recess_point(frame, rect[0], bottom_a, 0.0)
		var b := _recess_point(frame, rect[1], bottom_b, 0.0)
		var c := _recess_point(frame, rect[1], rect[3], 0.0)
		var d := _recess_point(frame, rect[0], rect[3], 0.0)
		for bucket: Dictionary in [visual, collision]:
			var first_vertex := (bucket.vertices as Array).size()
			SITE_12_KIT.append_quad(bucket, a, b, c, d, frame.normal as Vector3,
				Vector2.ZERO, Vector2.ONE)
			# Match source-wall meter scale and phase at every emitted vertex.
			# A sloping source bottom cannot use rectangular UV extents.
			for index in range(first_vertex, first_vertex + 4):
				var point := bucket.vertices[index] as Vector3
				bucket.uvs[index] = Vector2(point.dot(frame.tangent as Vector3), point.y)


func _append_closed_recess(back: Dictionary, returns: Dictionary, collision: Dictionary, frame: Dictionary, opening: Dictionary, depth: float) -> void:
	var l := float(opening.left)
	var r := float(opening.right)
	var b := float(opening.bottom)
	var t := float(opening.top)
	var a := _recess_point(frame, l, b, 0.0)
	var c := _recess_point(frame, r, b, 0.0)
	var d := _recess_point(frame, r, t, 0.0)
	var e := _recess_point(frame, l, t, 0.0)
	var inward := -(frame.normal as Vector3) * depth
	var specs: Array = [
		[back, a + inward, c + inward, d + inward, e + inward, frame.normal, Vector2(r - l, t - b)],
		[returns, a, a + inward, e + inward, e, frame.tangent, Vector2(depth, t - b)],
		[returns, c + inward, c, d, d + inward, -(frame.tangent as Vector3), Vector2(depth, t - b)],
		[returns, a, c, c + inward, a + inward, Vector3.UP, Vector2(r - l, depth)],
		[returns, e + inward, d + inward, d, e, Vector3.DOWN, Vector2(r - l, depth)],
	]
	for spec: Array in specs:
		for bucket: Dictionary in [spec[0], collision]:
			SITE_12_KIT.append_quad(bucket, spec[1], spec[2], spec[3], spec[4], spec[5], Vector2.ZERO, spec[6])


func get_build_result() -> Dictionary:
	return _last_result.duplicate(true)


func _append_eave_chain(bucket: Dictionary, wall_record: Dictionary, first_run: int, last_run: int, config: Dictionary, inference: Dictionary) -> bool:
	var first := SITE_12_KIT.run_frame(wall_record, first_run)
	var last := SITE_12_KIT.run_frame(wall_record, last_run)
	if first.is_empty() or last.is_empty():
		return false
	var tangent_vector := (last.end as Vector3) - (first.start as Vector3)
	tangent_vector.y = 0.0
	if tangent_vector.length_squared() <= 0.000001:
		return false
	var tangent := tangent_vector.normalized()
	var first_tangent := first.tangent as Vector3
	var last_tangent := last.tangent as Vector3
	if absf(tangent.dot(first_tangent)) < 0.999 or absf(tangent.dot(last_tangent)) < 0.999:
		return false
	var midpoint := ((first.start as Vector3) + (last.end as Vector3)) * 0.5
	midpoint.y = float((config.target as Dictionary).source_wall_top_y_m) + float(inference.eave_height) * 0.5
	SITE_12_KIT.append_eave_band(
		bucket,
		midpoint,
		tangent,
		first.normal as Vector3,
		tangent_vector.length() + float(inference.eave_chain_end_overhang) * 2.0,
		float(inference.eave_height),
		float(inference.eave_depth)
	)
	return true


func _append_exact_plan_gable(bucket: Dictionary, roof_record: Dictionary, wall_record: Dictionary, inference: Dictionary) -> void:
	var values := roof_record.vertices as Array
	var source_indices := roof_record.indices as Array
	var public_frame := SITE_12_KIT.run_frame(wall_record, BALCONY_RUN)
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


func _collision_body(wall: Dictionary, closure: Dictionary, roof: Dictionary) -> StaticBody3D:
	var body := StaticBody3D.new()
	# Preserve the fixture node path used by the frozen view-switch behavior.
	body.name = "ExactFootprintStructuralCollision_NoSprayOwnership"
	body.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
	body.collision_mask = 0
	body.set_meta("receiver_kind", "building_wall")
	body.set_meta("opaque", true)
	body.set_meta("derived_object_key", WALL_KEY)
	body.set_meta("source_keys", [SOURCE_KEY])
	body.set_meta("prototype_only", true)
	body.set_meta("runtime_attachment", false)
	body.set_meta("spray_ownership", "explicit_exterior_wall_only_standalone")
	body.set_meta("fallback_collider_retained", false)
	body.set_meta("structural_visible_collision_congruent", true)
	body.add_to_group("spray_receiver_wall")
	# Owner 0 falls back to body metadata in the unchanged spray controller.
	# Therefore eligible visible wall MUST remain the first shape.
	for spec: Dictionary in [
		{"name": "EligibleExteriorWallShape", "bucket": wall, "kind": "building_wall", "key": WALL_KEY},
		{"name": "NoneligibleClosedRecessShape", "bucket": closure, "kind": "none", "key": WALL_KEY},
		{"name": "NoneligibleExactRoofShape", "bucket": roof, "kind": "none", "key": ROOF_KEY},
	]:
		var bucket := spec.bucket as Dictionary
		var faces := PackedVector3Array()
		for index: int in bucket.indices as Array:
			faces.append((bucket.vertices as Array)[index] as Vector3)
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(faces)
		shape.set_meta("receiver_kind", str(spec.kind))
		shape.set_meta("opaque", true)
		shape.set_meta("derived_object_key", str(spec.key))
		shape.set_meta("source_keys", [SOURCE_KEY])
		var node := CollisionShape3D.new()
		node.name = str(spec.name)
		node.shape = shape
		body.add_child(node)
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
		and is_equal_approx(float(record.get("flat_base_elevation_m", 0.0)), 3.536) \
		and is_equal_approx(float(record.get("top_elevation_m", 0.0)), 9.536) \
		and record_signature(record) == expected_signature


static func _config_contract_matches(config: Dictionary) -> bool:
	if config.is_empty() or str(config.get("schema_version", "")) != "ti.d2-1439-chinook-standalone-hero-prototype/1":
		return false
	var target := config.get("target", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	var mapped := config.get("mapped_public_region", {}) as Dictionary
	var protected := config.get("protected_region", {}) as Dictionary
	var uv_contract := config.get("meter_uv_contract", {}) as Dictionary
	var kit_contract := config.get("site_12_kit_contract", {}) as Dictionary
	var seam := config.get("future_live_integration_seam", {}) as Dictionary
	return str(config.get("model_id", "")) == "d2-1439-chinook-quality-v2-prototype" \
		and str(target.get("source_key", "")) == SOURCE_KEY \
		and str(target.get("wall_object_key", "")) == WALL_KEY \
		and str(target.get("roof_object_key", "")) == ROOF_KEY \
		and str(target.get("source_geometry_sha256", "")) == SOURCE_GEOMETRY_SHA256 \
		and int(target.get("wall_run_count", 0)) == WALL_RUN_COUNT \
		and int(target.get("wall_vertices", 0)) == 96 \
		and int(target.get("wall_triangles", 0)) == 48 \
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
		and _int_array(mapped.get("motif_host_runs", []) as Array) == MOTIF_HOST_RUNS \
		and _int_array(mapped.get("mapped_motif_free_runs", []) as Array) == MAPPED_MOTIF_FREE_RUNS \
		and _int_array(mapped.get("tiny_fragment_runs", []) as Array) == TINY_FRAGMENT_RUNS \
		and _int_array(protected.get("run_indices", []) as Array) == PROTECTED_RUNS \
		and str(uv_contract.get("geometry_uv_units", "")) == "one UV unit equals one modeled meter" \
		and not bool(uv_contract.get("generated_normal_or_roughness_maps", true)) \
		and str(kit_contract.get("kit_id", "")) == SITE_12_KIT.KIT_ID \
		and str(seam.get("registry_status", "")) == "not_registered" \
		and str(seam.get("world_builder_status", "")) == "not_attached" \
		and _confusion_contract_matches(config)


static func _confusion_contract_matches(config: Dictionary) -> bool:
	var authoritative := config.get("authoritative_confusion_set", []) as Array
	var implemented := config.get("implemented_comparison_set", []) as Array
	if authoritative.size() != 3 or implemented.size() != 2:
		return false
	var expected_authoritative := {
		"1437 Chinook Court": "w95934113",
		"1441 Chinook Court": "w95934105",
		"1438 Chinook Court": "w95934131",
	}
	for value: Variant in authoritative:
		var item := value as Dictionary
		if str(expected_authoritative.get(str(item.get("name", "")), "")) != str(item.get("source_key", "")):
			return false
	var implemented_ids: Array[String] = []
	for value: Variant in implemented:
		implemented_ids.append(str((value as Dictionary).get("source_key", "")))
	implemented_ids.sort()
	return implemented_ids == ["w95934105", "w95934117"]


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
