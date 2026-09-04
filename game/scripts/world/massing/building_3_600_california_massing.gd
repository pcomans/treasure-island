class_name Building3600CaliforniaMassing
extends RefCounted

const TARGET_SOURCE_KEY := "w34313540"
const TARGET_LOGICAL_OBJECT_KEY := "building:w34313540"
const TARGET_WALL_KEY := "building:w34313540:wall"
const TARGET_ROOF_KEY := "building:w34313540:roof"
const CONFIG_PATH := "res://game/resources/facades/building_3_hero_massing.json"
const SOURCE_NOMINAL_BASE_Y := 3.478
const SOURCE_FLAT_TOP_Y := 23.478
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1
const FACADE_SCENE := preload("res://game/scenes/world/facades/building_3/building_3_600_california_facade.tscn")

# These are exact endpoints from the frozen wall receiver. They establish only
# the short/long axes; no horizontal point is moved to this idealized frame.
const WSW_LEFT := Vector2(365.909, 472.390)
const WSW_RIGHT := Vector2(409.171, 554.288)
const ENE_LEFT := Vector2(486.955, 408.860)
const ENE_RIGHT := Vector2(528.784, 488.910)


static func matches_record(record: Dictionary) -> bool:
	var object_key := str(record.get("object_key", ""))
	if object_key not in [TARGET_WALL_KEY, TARGET_ROOF_KEY]:
		return false
	var source_keys: Array = record.get("source_keys", [])
	return source_keys.size() == 1 \
		and str(source_keys[0]) == TARGET_SOURCE_KEY \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))


static func build_record(record: Dictionary, material: Material) -> Dictionary:
	var config_result := _load_and_validate_config()
	if not bool(config_result.get("ok", false)):
		return config_result
	var validation := _validate_source_record(record, config_result.config as Dictionary)
	if not bool(validation.get("ok", false)):
		return validation
	var contract := massing_contract(record, config_result.config as Dictionary)
	var object_key := str(record.object_key)
	var geometry := wall_geometry(record, contract) if object_key == TARGET_WALL_KEY else roof_geometry(record, contract)
	if not bool(geometry.get("ok", false)):
		return geometry

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = geometry.vertices
	arrays[Mesh.ARRAY_NORMAL] = geometry.normals
	arrays[Mesh.ARRAY_TEX_UV] = geometry.uvs
	arrays[Mesh.ARRAY_TANGENT] = geometry.tangents
	arrays[Mesh.ARRAY_INDEX] = geometry.indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_name(0, "building_3_hero_%s" % ("wall" if object_key == TARGET_WALL_KEY else "roof"))
	mesh.surface_set_material(0, material)

	var root := Node3D.new()
	root.name = object_key.validate_node_name()
	root.set_meta("derived_object_key", object_key)
	root.set_meta("source_keys", record.source_keys.duplicate())
	root.set_meta("feature_kind", str(record.feature_kind))
	root.set_meta("building_3_massing_override", true)
	root.set_meta("massing_contract", contract.duplicate(true))
	root.set_meta("massing_signature", str(geometry.signature))
	root.set_meta("horizontal_source_geometry_preserved", true)
	root.set_meta("foundation_geometry_preserved", object_key == TARGET_WALL_KEY)
	root.set_meta("runtime_supersedes_generated_placeholder", true)
	root.set_meta("corrected_nrhp_id", "08000083")
	root.set_meta("frozen_osm_nrhp_ref", "08000081")
	root.set_meta("frozen_osm_nrhp_ref_role", "provenance_only_incorrect_for_building_3")
	root.set_meta("production_inference_reversible", true)
	root.set_meta("exterior_only", true)
	root.set_meta("interior_modeled", false)
	root.set_meta("as_built_fidelity_claimed", false)
	root.set_meta("visual_review_status", "pending_independent_original_detail_review")

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	mesh_instance.mesh = mesh
	mesh_instance.layers = RENDER_BUILDING_WALL if object_key == TARGET_WALL_KEY else RENDER_WORLD_VISIBLE
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(mesh_instance)

	var body := StaticBody3D.new()
	body.name = "Collision"
	body.collision_layer = PHYSICS_WORLD_SOLID | (PHYSICS_SPRAY_SURFACE if object_key == TARGET_WALL_KEY else 0)
	body.collision_mask = 0
	body.set_meta("receiver_kind", str(record.receiver_kind))
	body.set_meta("opaque", bool(record.opaque))
	body.set_meta("derived_object_key", object_key)
	body.set_meta("source_keys", record.source_keys.duplicate())
	body.set_meta("building_3_massing_override", true)
	body.set_meta("massing_signature", str(geometry.signature))
	body.set_meta("runtime_supersedes_generated_placeholder", true)
	if object_key == TARGET_WALL_KEY:
		body.add_to_group("spray_receiver_wall")
	var faces := PackedVector3Array()
	for index_value: int in geometry.indices:
		faces.append(geometry.vertices[index_value])
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	shape.set_meta("receiver_kind", str(record.receiver_kind))
	shape.set_meta("opaque", bool(record.opaque))
	shape.set_meta("derived_object_key", object_key)
	shape.set_meta("source_keys", record.source_keys.duplicate())
	shape.set_meta("building_3_massing_override", true)
	shape.set_meta("massing_signature", str(geometry.signature))
	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "Shape"
	collision_shape.shape = shape
	body.add_child(collision_shape)
	root.add_child(body)

	if object_key == TARGET_WALL_KEY:
		var facade := FACADE_SCENE.instantiate() as Building3600CaliforniaFacade
		var facade_result := facade.configure(record, contract)
		if not bool(facade_result.get("ok", false)):
			facade.free()
			root.free()
			return {
				"ok": false,
				"code": "building_3_facade_contract",
				"message": str(facade_result.get("message", "Could not remap Building 3 facade to hero massing.")),
				"source_keys": record.source_keys,
			}
		root.add_child(facade)

	return {
		"ok": true,
		"node": root,
		"mesh_instances": 1,
		"surfaces": 1,
		"triangles": int(geometry.indices.size() / 3),
	}


static func massing_contract(record: Dictionary = {}, supplied_config: Dictionary = {}) -> Dictionary:
	var config := supplied_config
	if config.is_empty():
		var loaded := _load_and_validate_config()
		if not bool(loaded.get("ok", false)):
			return {}
		config = loaded.config as Dictionary
	var inference := config.reversible_production_inference as Dictionary
	var width_start := (WSW_LEFT + ENE_LEFT) * 0.5
	var width_end := (WSW_RIGHT + ENE_RIGHT) * 0.5
	var long_start := (WSW_LEFT + WSW_RIGHT) * 0.5
	var long_end := (ENE_LEFT + ENE_RIGHT) * 0.5
	var contract := {
		"schema_version": "ti.building-3-massing-runtime/1",
		"config_path": CONFIG_PATH,
		"config_sha256": FileAccess.get_sha256(CONFIG_PATH),
		"target_source_key": TARGET_SOURCE_KEY,
		"target_logical_object_key": TARGET_LOGICAL_OBJECT_KEY,
		"target_wall_key": TARGET_WALL_KEY,
		"target_roof_key": TARGET_ROOF_KEY,
		"corrected_nrhp_id": "08000083",
		"frozen_osm_nrhp_ref": "08000081",
		"frozen_osm_nrhp_ref_role": "provenance_only_incorrect_for_building_3",
		"nominal_base_y_m": SOURCE_NOMINAL_BASE_Y,
		"source_flat_top_y_m": SOURCE_FLAT_TOP_Y,
		"eave_y_m": float(inference.nominal_eave_y_m),
		"crown_y_m": float(inference.crown_y_m),
		"pylon_y_m": float(inference.pylon_y_m),
		"pylon_width_fraction": float(inference.pylon_width_fraction),
		"pylon_end_fraction": float(inference.pylon_end_fraction),
		"wall_subdivisions": int(inference.wall_subdivisions_per_source_run),
		"roof_subdivisions": int(inference.roof_subdivisions_per_source_triangle),
		"width_start_xz": width_start,
		"width_end_xz": width_end,
		"width_axis_xz": (width_end - width_start).normalized(),
		"width_span_m": width_start.distance_to(width_end),
		"long_start_xz": long_start,
		"long_end_xz": long_end,
		"long_axis_xz": (long_end - long_start).normalized(),
		"long_span_m": long_start.distance_to(long_end),
		"source_wall_runs": 59,
		"source_wall_triangles": 118,
		"source_roof_triangles": 27,
		"runtime_wall_triangles": 59 * int(inference.wall_subdivisions_per_source_run) * 2,
		"runtime_roof_triangles": 27 * int(inference.roof_subdivisions_per_source_triangle) * int(inference.roof_subdivisions_per_source_triangle),
		"horizontal_source_footprint_preserved": true,
		"generated_bytes_unchanged": true,
		"production_inference_reversible": true,
		"exterior_only": true,
		"interior_modeled": false,
		"as_built_fidelity_claimed": false,
		"visual_review_status": "pending_independent_original_detail_review",
	}
	if not record.is_empty() and str(record.get("object_key", "")) == TARGET_WALL_KEY:
		contract["wall_run_top_y_samples"] = _wall_run_top_samples(record, contract)
	contract["profile_signature"] = _profile_signature(contract)
	return contract


static func top_y_for_xz(point: Vector2, contract: Dictionary) -> float:
	var width_start := contract.width_start_xz as Vector2
	var width_axis := contract.width_axis_xz as Vector2
	var long_axis := contract.long_axis_xz as Vector2
	var across := clampf((point - width_start).dot(width_axis) / float(contract.width_span_m), 0.0, 1.0)
	var eave_y := float(contract.eave_y_m)
	var crown_y := float(contract.crown_y_m)
	var arch_y := eave_y + (crown_y - eave_y) * sin(PI * across)
	var pylon_factor := 0.0
	for corner: Vector2 in [WSW_LEFT, WSW_RIGHT, ENE_LEFT, ENE_RIGHT]:
		var from_corner := point - corner
		var edge_factor := clampf(1.0 - absf(from_corner.dot(width_axis)) / (float(contract.width_span_m) * float(contract.pylon_width_fraction)), 0.0, 1.0)
		var end_factor := clampf(1.0 - absf(from_corner.dot(long_axis)) / (float(contract.long_span_m) * float(contract.pylon_end_fraction)), 0.0, 1.0)
		pylon_factor = maxf(pylon_factor, minf(edge_factor, end_factor))
	var pylon_y := eave_y + (float(contract.pylon_y_m) - eave_y) * pylon_factor
	return maxf(arch_y, pylon_y)


static func wall_geometry(record: Dictionary, contract: Dictionary = {}) -> Dictionary:
	if str(record.get("object_key", "")) != TARGET_WALL_KEY:
		return {"ok": false, "code": "building_3_massing_target", "message": "Wall geometry requested for a non-Building-3 wall."}
	if contract.is_empty():
		contract = massing_contract(record)
	var subdivisions := int(contract.wall_subdivisions)
	var raw_vertices: Array = record.vertices
	var raw_normals: Array = record.normals
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var tangents := PackedFloat32Array()
	var indices := PackedInt32Array()
	for run_index in 59:
		var offset := run_index * 12
		var start_bottom := Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2]))
		var end_bottom := Vector3(float(raw_vertices[offset + 3]), float(raw_vertices[offset + 4]), float(raw_vertices[offset + 5]))
		var normal := Vector3(float(raw_normals[offset]), 0.0, float(raw_normals[offset + 2])).normalized()
		var tangent := Vector3(normal.z, 0.0, -normal.x).normalized()
		var run_length := Vector2(start_bottom.x, start_bottom.z).distance_to(Vector2(end_bottom.x, end_bottom.z))
		for subdivision in subdivisions:
			var first_fraction := float(subdivision) / float(subdivisions)
			var second_fraction := float(subdivision + 1) / float(subdivisions)
			var first_bottom := start_bottom.lerp(end_bottom, first_fraction)
			var second_bottom := start_bottom.lerp(end_bottom, second_fraction)
			var first_top := Vector3(first_bottom.x, top_y_for_xz(Vector2(first_bottom.x, first_bottom.z), contract), first_bottom.z)
			var second_top := Vector3(second_bottom.x, top_y_for_xz(Vector2(second_bottom.x, second_bottom.z), contract), second_bottom.z)
			var base := vertices.size()
			for vertex: Vector3 in [first_bottom, second_bottom, second_top, first_top]:
				vertices.append(vertex)
				normals.append(normal)
				tangents.append_array(PackedFloat32Array([tangent.x, tangent.y, tangent.z, 1.0]))
			uvs.append(Vector2(run_length * first_fraction * 0.1, first_bottom.y * 0.1))
			uvs.append(Vector2(run_length * second_fraction * 0.1, second_bottom.y * 0.1))
			uvs.append(Vector2(run_length * second_fraction * 0.1, second_top.y * 0.1))
			uvs.append(Vector2(run_length * first_fraction * 0.1, first_top.y * 0.1))
			indices.append_array(PackedInt32Array([base, base + 2, base + 1, base, base + 3, base + 2]))
	var signature := _geometry_signature(vertices, indices, "wall")
	return {"ok": true, "vertices": vertices, "normals": normals, "uvs": uvs, "tangents": tangents, "indices": indices, "signature": signature}


static func roof_geometry(record: Dictionary, contract: Dictionary = {}) -> Dictionary:
	if str(record.get("object_key", "")) != TARGET_ROOF_KEY:
		return {"ok": false, "code": "building_3_massing_target", "message": "Roof geometry requested for a non-Building-3 roof."}
	if contract.is_empty():
		contract = massing_contract(record)
	var raw_vertices: Array = record.vertices
	var raw_indices: Array = record.indices
	var subdivisions := int(contract.roof_subdivisions)
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var tangents := PackedFloat32Array()
	var indices := PackedInt32Array()
	for source_offset in range(0, raw_indices.size(), 3):
		var source_points: Array[Vector2] = []
		for corner_offset in 3:
			var source_index := int(raw_indices[source_offset + corner_offset])
			var vertex_offset := source_index * 3
			source_points.append(Vector2(float(raw_vertices[vertex_offset]), float(raw_vertices[vertex_offset + 2])))
		for first_step in subdivisions:
			for second_step in range(subdivisions - first_step):
				var first := _roof_sample(source_points, first_step, second_step, subdivisions, contract)
				var second := _roof_sample(source_points, first_step + 1, second_step, subdivisions, contract)
				var third := _roof_sample(source_points, first_step, second_step + 1, subdivisions, contract)
				_append_roof_triangle(vertices, normals, uvs, tangents, indices, first, second, third)
				if first_step + second_step < subdivisions - 1:
					var fourth := _roof_sample(source_points, first_step + 1, second_step + 1, subdivisions, contract)
					_append_roof_triangle(vertices, normals, uvs, tangents, indices, second, fourth, third)
	var signature := _geometry_signature(vertices, indices, "roof")
	return {"ok": true, "vertices": vertices, "normals": normals, "uvs": uvs, "tangents": tangents, "indices": indices, "signature": signature}


static func _roof_sample(source_points: Array[Vector2], first_step: int, second_step: int, subdivisions: int, contract: Dictionary) -> Vector3:
	var first_weight := float(first_step) / float(subdivisions)
	var second_weight := float(second_step) / float(subdivisions)
	var point := source_points[0] + (source_points[1] - source_points[0]) * first_weight + (source_points[2] - source_points[0]) * second_weight
	return Vector3(point.x, top_y_for_xz(point, contract), point.y)


static func _append_roof_triangle(vertices: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, tangents: PackedFloat32Array, indices: PackedInt32Array, first: Vector3, second: Vector3, third: Vector3) -> void:
	var normal := (second - first).cross(third - first).normalized()
	if normal.y < 0.0:
		normal = -normal
	var reference_tangent := Vector3(second.x - first.x, second.y - first.y, second.z - first.z).normalized()
	if reference_tangent.length_squared() <= 0.000001:
		reference_tangent = Vector3.RIGHT
	var base := vertices.size()
	for vertex: Vector3 in [first, second, third]:
		vertices.append(vertex)
		normals.append(normal)
		uvs.append(Vector2(vertex.x, vertex.z) * 0.1)
		tangents.append_array(PackedFloat32Array([reference_tangent.x, reference_tangent.y, reference_tangent.z, 1.0]))
	# Preserve the generated counterclockwise orientation while adapting it once
	# to Godot's clockwise front-face convention.
	indices.append_array(PackedInt32Array([base, base + 2, base + 1]))


static func _wall_run_top_samples(record: Dictionary, contract: Dictionary) -> Array:
	var samples: Array = []
	var raw_vertices: Array = record.vertices
	var subdivisions := int(contract.wall_subdivisions)
	for run_index in 59:
		var offset := run_index * 12
		var start := Vector2(float(raw_vertices[offset]), float(raw_vertices[offset + 2]))
		var end := Vector2(float(raw_vertices[offset + 3]), float(raw_vertices[offset + 5]))
		var run_samples: Array[float] = []
		for sample_index in subdivisions + 1:
			var fraction := float(sample_index) / float(subdivisions)
			run_samples.append(top_y_for_xz(start.lerp(end, fraction), contract))
		samples.append(run_samples)
	return samples


static func _profile_signature(contract: Dictionary) -> String:
	var parts := PackedStringArray([
		str(contract.schema_version), TARGET_SOURCE_KEY, "08000083", "frozen-osm-08000081-provenance-only",
		"%.6f" % float(contract.eave_y_m), "%.6f" % float(contract.crown_y_m), "%.6f" % float(contract.pylon_y_m),
		"%.6f" % float(contract.pylon_width_fraction), "%.6f" % float(contract.pylon_end_fraction),
		str(contract.wall_subdivisions), str(contract.roof_subdivisions),
	])
	for value: Vector2 in [contract.width_start_xz as Vector2, contract.width_end_xz as Vector2, contract.long_start_xz as Vector2, contract.long_end_xz as Vector2]:
		parts.append("%.6f,%.6f" % [value.x, value.y])
	if contract.has("wall_run_top_y_samples"):
		for run_value: Variant in contract.wall_run_top_y_samples:
			for height_value: Variant in run_value as Array:
				parts.append("%.6f" % float(height_value))
	return "|".join(parts).sha256_text()


static func _geometry_signature(vertices: PackedVector3Array, indices: PackedInt32Array, role: String) -> String:
	var parts := PackedStringArray([role, TARGET_SOURCE_KEY, "08000083"])
	for vertex: Vector3 in vertices:
		parts.append("%.9f,%.9f,%.9f" % [vertex.x, vertex.y, vertex.z])
	for index: int in indices:
		parts.append(str(index))
	return "|".join(parts).sha256_text()


static func _load_and_validate_config() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not (parsed is Dictionary):
		return {"ok": false, "code": "building_3_massing_config", "message": "Building 3 hero massing JSON could not be parsed."}
	var config := parsed as Dictionary
	var target := config.get("target", {}) as Dictionary
	var identity := config.get("authoritative_identity", {}) as Dictionary
	var inference := config.get("reversible_production_inference", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	if str(config.get("schema_version", "")) != "ti.building-3-hero-massing/1" \
		or str(target.get("source_key", "")) != TARGET_SOURCE_KEY \
		or str(target.get("wall_object_key", "")) != TARGET_WALL_KEY \
		or str(target.get("roof_object_key", "")) != TARGET_ROOF_KEY \
		or str(identity.get("nrhp_id", "")) != "08000083" \
		or str(identity.get("frozen_osm_nrhp_ref", "")) != "08000081" \
		or str(identity.get("frozen_osm_nrhp_ref_role", "")) != "preserved_provenance_only_incorrect_for_building_3" \
		or int(inference.get("wall_subdivisions_per_source_run", 0)) < 1 \
		or int(inference.get("roof_subdivisions_per_source_triangle", 0)) < 2 \
		or float(inference.get("nominal_eave_y_m", 0.0)) <= SOURCE_NOMINAL_BASE_Y \
		or float(inference.get("crown_y_m", 0.0)) <= float(inference.get("pylon_y_m", 0.0)) \
		or float(inference.get("pylon_y_m", 0.0)) <= float(inference.get("nominal_eave_y_m", 0.0)) \
		or not bool(truth.get("horizontal_source_footprint_preserved", false)) \
		or not bool(truth.get("exterior_only", false)) \
		or bool(truth.get("interior_modeled", true)) \
		or bool(truth.get("as_built_fidelity_claimed", true)):
		return {"ok": false, "code": "building_3_massing_config", "message": "Building 3 hero massing truth/identity/profile contract drifted."}
	return {"ok": true, "config": config}


static func _validate_source_record(record: Dictionary, config: Dictionary) -> Dictionary:
	if not matches_record(record):
		return {"ok": false, "code": "building_3_massing_target", "message": "Building 3 massing refused a non-target record.", "source_keys": record.get("source_keys", [])}
	var target := config.target as Dictionary
	var object_key := str(record.object_key)
	var is_wall := object_key == TARGET_WALL_KEY
	var expected_feature := "building_wall" if is_wall else "building_roof"
	var expected_receiver := "building_wall" if is_wall else "none"
	var expected_vertex_values := int(target.source_wall_vertex_values) if is_wall else int(target.source_roof_vertex_values)
	var expected_index_values := int(target.source_wall_index_values) if is_wall else int(target.source_roof_index_values)
	var raw_vertices: Array = record.get("vertices", [])
	if str(record.get("feature_kind", "")) != expected_feature \
		or str(record.get("material_key", "")) != expected_feature \
		or str(record.get("receiver_kind", "")) != expected_receiver \
		or raw_vertices.size() != expected_vertex_values \
		or (record.get("indices", []) as Array).size() != expected_index_values:
		return {"ok": false, "code": "building_3_massing_source", "message": "Building 3 generated receiver topology drifted.", "source_keys": record.source_keys}
	var highest := -INF
	for offset in range(1, raw_vertices.size(), 3):
		highest = maxf(highest, float(raw_vertices[offset]))
	if not is_equal_approx(highest, SOURCE_FLAT_TOP_Y):
		return {"ok": false, "code": "building_3_massing_source", "message": "Building 3 generated flat-top anchor drifted.", "source_keys": record.source_keys}
	if is_wall:
		var exact_points := [
			Vector2(float(raw_vertices[0]), float(raw_vertices[2])),
			Vector2(float(raw_vertices[9 * 12 + 3]), float(raw_vertices[9 * 12 + 5])),
			Vector2(float(raw_vertices[35 * 12 + 3]), float(raw_vertices[35 * 12 + 5])),
			Vector2(float(raw_vertices[27 * 12]), float(raw_vertices[27 * 12 + 2])),
		]
		if exact_points != [WSW_LEFT, WSW_RIGHT, ENE_LEFT, ENE_RIGHT]:
			return {"ok": false, "code": "building_3_massing_source", "message": "Building 3 exact profile-frame endpoints drifted.", "source_keys": record.source_keys}
	return {"ok": true}
