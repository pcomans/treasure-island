class_name Building3600CaliforniaFacade
extends Node3D

const TARGET_SOURCE_KEY := "w34313540"
const TARGET_LOGICAL_OBJECT_KEY := "building:w34313540"
const TARGET_RECEIVER_OBJECT_KEY := "building:w34313540:wall"
const LAYOUT_PATH := "res://game/resources/facades/building_3_600_california_ene_layout.json"
const RENDER_BUILDING_WALL := 1 << 1

const MODULE_LIBRARY := preload("res://game/scenes/world/facades/building_3/building_3_ene_modules.tscn")
const MATERIALS := {
	"white_primary": preload("res://game/resources/materials/world/building_3/building_3_white_primary.tres"),
	"teal_door": preload("res://game/resources/materials/world/building_3/building_3_teal_door.tres"),
}

var _layout: Dictionary = {}
var _contract: Dictionary = {}
var _boxes_by_material: Dictionary = {}
var _module_counts: Dictionary = {}
var _signature_parts: PackedStringArray = []
var _module_library: Node3D
var _side: Dictionary = {}


static func matches_target(record: Dictionary) -> bool:
	var source_keys: Array = record.get("source_keys", [])
	return str(record.get("object_key", "")) == TARGET_RECEIVER_OBJECT_KEY \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("material_key", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and source_keys.size() == 1 \
		and str(source_keys[0]) == TARGET_SOURCE_KEY


func configure(record: Dictionary) -> Dictionary:
	if not matches_target(record):
		return {"ok": false, "message": "Building 3 facade refused a non-target receiver."}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH))
	if not (parsed is Dictionary):
		return {"ok": false, "message": "Building 3 layout JSON could not be parsed."}
	_layout = parsed as Dictionary
	_contract = _layout.render_contract as Dictionary
	_side = _layout.observed_ene_main as Dictionary
	var target := _layout.target as Dictionary
	if str(target.source_key) != TARGET_SOURCE_KEY \
	or str(target.logical_object_key) != TARGET_LOGICAL_OBJECT_KEY \
	or str(target.receiver_object_key) != TARGET_RECEIVER_OBJECT_KEY \
	or int(target.wall_segments) != 59 \
	or int(target.wall_triangles) != 118 \
	or not _record_massing_matches(record, target) \
	or not _exact_runs_match(record):
		return {"ok": false, "message": "Building 3 layout identity, ENE run scope, or receiver massing drifted."}

	name = "Building3600CaliforniaFacade"
	set_meta("target_source_key", TARGET_SOURCE_KEY)
	set_meta("target_logical_object_key", TARGET_LOGICAL_OBJECT_KEY)
	set_meta("target_receiver_object_key", TARGET_RECEIVER_OBJECT_KEY)
	set_meta("layout_path", LAYOUT_PATH)
	set_meta("layout_sha256", FileAccess.get_sha256(LAYOUT_PATH))
	set_meta("render_only", true)
	set_meta("collision", "none")
	set_meta("navigation", "none")
	set_meta("spray_ray_owner", "unchanged_underlying_receiver")
	set_meta("maximum_relief_m", float(_contract.maximum_relief_m))
	set_meta("styled_run_indices", _int_array(_side.run_indices as Array))
	set_meta("styled_run_length_m", float(_side.length_m))
	set_meta("excluded_run_indices", _int_array(_layout.excluded_run_indices as Array))
	add_to_group("building_3_render_only_facade")

	var side_node := Node3D.new()
	side_node.name = "ENE_Main_Runs_27_35"
	side_node.set_meta("run_indices", _int_array(_side.run_indices as Array))
	side_node.set_meta("length_m", float(_side.length_m))
	side_node.set_meta("module_policy", "observed_complete_modules")
	add_child(side_node)

	var field_result := _build_field(record, target)
	if not bool(field_result.get("ok", false)):
		return field_result
	_module_library = MODULE_LIBRARY.instantiate() as Node3D
	for module_value: Variant in _side.modules:
		var module := module_value as Dictionary
		var kind := str(module.kind)
		_new_module(side_node, kind, float(module.u_m), float(module.center_y_m), float(module.width_m), float(module.height_m))
		if kind == "B3-HANGAR-DOOR":
			_build_hangar_door(float(module.u_m), float(module.center_y_m), float(module.width_m), float(module.height_m))
		elif kind == "B3-BAND":
			_add_box("white_primary", float(module.u_m), float(module.center_y_m), float(module.width_m), float(module.height_m), float(_contract.field_offset_m), 0.055)
	_module_library.free()
	_flush_render_batches()
	set_meta("module_counts", _module_counts.duplicate(true))
	set_meta("field_segment_count", int(field_result.segment_count))
	set_meta("deterministic_signature", "|".join(_signature_parts).sha256_text())
	return {
		"ok": true,
		"module_counts": _module_counts.duplicate(true),
		"field_segment_count": int(field_result.segment_count),
		"deterministic_signature": str(get_meta("deterministic_signature")),
	}


func _record_massing_matches(record: Dictionary, target: Dictionary) -> bool:
	var vertices: Array = record.get("vertices", [])
	var indices: Array = record.get("indices", [])
	if vertices.size() != 708 or indices.size() != 354:
		return false
	var top_y := -INF
	for offset in range(1, vertices.size(), 3):
		top_y = maxf(top_y, float(vertices[offset]))
	return is_equal_approx(top_y, float(target.top_y_m)) \
		and is_equal_approx(top_y - float(target.base_y_m), float(target.height_m))


func _exact_runs_match(record: Dictionary) -> bool:
	var expected_runs: Array = _side.runs
	var raw_vertices: Array = record.vertices
	for run_value: Variant in expected_runs:
		var expected := run_value as Dictionary
		var run_index := int(expected.index)
		var offset := run_index * 12
		var start: Array = expected.start_xz_m
		var end: Array = expected.end_xz_m
		if not is_equal_approx(float(raw_vertices[offset]), float(start[0])) \
		or not is_equal_approx(float(raw_vertices[offset + 2]), float(start[1])) \
		or not is_equal_approx(float(raw_vertices[offset + 3]), float(end[0])) \
		or not is_equal_approx(float(raw_vertices[offset + 5]), float(end[1])):
			return false
	return true


func _build_field(record: Dictionary, target: Dictionary) -> Dictionary:
	var group := _empty_surface_group()
	var raw_vertices: Array = record.vertices
	var raw_normals: Array = record.normals
	for index_value: Variant in _side.run_indices:
		var run_index := int(index_value)
		var offset := run_index * 12
		var start_x := float(raw_vertices[offset])
		var start_z := float(raw_vertices[offset + 2])
		var end_x := float(raw_vertices[offset + 3])
		var end_z := float(raw_vertices[offset + 5])
		var normal := Vector3(float(raw_normals[offset]), 0.0, float(raw_normals[offset + 2])).normalized()
		var outward := normal * float(_contract.field_offset_m)
		_append_quad(group, [
			Vector3(start_x, float(target.base_y_m), start_z) + outward,
			Vector3(end_x, float(target.base_y_m), end_z) + outward,
			Vector3(end_x, float(target.top_y_m), end_z) + outward,
			Vector3(start_x, float(target.top_y_m), start_z) + outward,
		], normal)
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = group.vertices
	arrays[Mesh.ARRAY_NORMAL] = group.normals
	arrays[Mesh.ARRAY_TANGENT] = group.tangents
	arrays[Mesh.ARRAY_INDEX] = group.indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, MATERIALS.white_primary as Material)
	var fields := MeshInstance3D.new()
	fields.name = "FacadeFields_Runs_27_35"
	fields.mesh = mesh
	fields.layers = RENDER_BUILDING_WALL
	fields.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	fields.set_meta("facade_visual", true)
	fields.set_meta("exact_receiver_run_indices", _int_array(_side.run_indices as Array))
	fields.set_meta("foundation_geometry_untouched", true)
	add_child(fields)
	_signature_parts.append("fields:27-35:9:1")
	return {"ok": true, "segment_count": 9}


func _build_hangar_door(u: float, y: float, width: float, height: float) -> void:
	_add_box("teal_door", u, y, width - 1.1, height - 1.1, float(_contract.field_offset_m), 0.035)
	var stroke := 0.55
	_add_box("white_primary", u - width * 0.5 + stroke * 0.5, y, stroke, height, 0.035, 0.075)
	_add_box("white_primary", u + width * 0.5 - stroke * 0.5, y, stroke, height, 0.035, 0.075)
	_add_box("white_primary", u, y - height * 0.5 + stroke * 0.5, width, stroke, 0.035, 0.075)
	_add_box("white_primary", u, y + height * 0.5 - stroke * 0.5, width, stroke, 0.035, 0.075)


func _new_module(parent: Node3D, kind: String, u: float, y: float, width: float, height: float) -> void:
	var template := _module_library.get_node(kind.replace("-", "_")) as Node3D
	assert(template != null and bool(template.get_meta("complete_motif", false)))
	var module := template.duplicate() as Node3D
	var count := int(_module_counts.get(kind, 0)) + 1
	_module_counts[kind] = count
	module.name = "Module_%s_%03d" % [kind.replace("-", "_"), count]
	module.set_meta("module_kind", kind)
	module.set_meta("side_u_m", u)
	module.set_meta("width_m", width)
	module.set_meta("height_m", height)
	module.set_meta("render_only", true)
	module.transform = Transform3D(_side_basis(), _side_point(u, y, float(_contract.field_offset_m)))
	parent.add_child(module)
	_signature_parts.append("module:%s:%.3f:%.3f:%.3f:%.3f" % [kind, u, y, width, height])


func _add_box(material_key: String, u: float, y: float, width: float, height: float, inner: float, outer: float) -> void:
	assert(width > 0.0 and height > 0.0 and outer >= inner)
	assert(outer <= float(_contract.maximum_relief_m) + 0.0001)
	assert(u - width * 0.5 >= 0.0 and u + width * 0.5 <= float(_side.length_m) + 0.0001)
	var basis := _side_basis()
	basis.x *= width
	basis.y *= height
	basis.z *= outer - inner
	var transform := Transform3D(basis, _side_point(u, y, (inner + outer) * 0.5))
	if not _boxes_by_material.has(material_key):
		_boxes_by_material[material_key] = []
	(_boxes_by_material[material_key] as Array).append(transform)


func _side_basis() -> Basis:
	var start: Array = _side.start_xz_m
	var end: Array = _side.end_xz_m
	var normal_values: Array = _side.normal_xz
	var tangent := Vector3(float(end[0]) - float(start[0]), 0.0, float(end[1]) - float(start[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	return Basis(tangent, Vector3.UP, normal)


func _side_point(u: float, y: float, outward: float) -> Vector3:
	var start: Array = _side.start_xz_m
	var basis := _side_basis()
	return Vector3(float(start[0]), y, float(start[1])) + basis.x * u + basis.z * outward


func _flush_render_batches() -> void:
	var batches := Node3D.new()
	batches.name = "RenderBatches"
	batches.set_meta("render_only", true)
	add_child(batches)
	var keys := _boxes_by_material.keys()
	keys.sort()
	for key_value: Variant in keys:
		var material_key := str(key_value)
		var transforms := _boxes_by_material[material_key] as Array
		var box := BoxMesh.new()
		box.size = Vector3.ONE
		box.material = MATERIALS[material_key] as Material
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = box
		multimesh.instance_count = transforms.size()
		for index in transforms.size():
			var instance_transform := transforms[index] as Transform3D
			multimesh.set_instance_transform(index, instance_transform)
			_signature_parts.append("box:%s:%s" % [material_key, _transform_token(instance_transform)])
		var instance := MultiMeshInstance3D.new()
		instance.name = "Batch_%s" % material_key
		instance.multimesh = multimesh
		instance.layers = RENDER_BUILDING_WALL
		instance.set_meta("facade_visual", true)
		instance.set_meta("material_key", material_key)
		instance.set_meta("instance_count", transforms.size())
		batches.add_child(instance)


func _empty_surface_group() -> Dictionary:
	return {"vertices": PackedVector3Array(), "normals": PackedVector3Array(), "tangents": PackedFloat32Array(), "indices": PackedInt32Array()}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _append_quad(group: Dictionary, corners: Array, normal: Vector3) -> void:
	var vertices := group.vertices as PackedVector3Array
	var normals := group.normals as PackedVector3Array
	var tangents := group.tangents as PackedFloat32Array
	var indices := group.indices as PackedInt32Array
	var base := vertices.size()
	var tangent := Vector3(normal.z, 0.0, -normal.x).normalized()
	for corner_value: Variant in corners:
		vertices.append(corner_value as Vector3)
		normals.append(normal)
		tangents.append_array(PackedFloat32Array([tangent.x, tangent.y, tangent.z, 1.0]))
	indices.append_array(PackedInt32Array([base, base + 2, base + 1, base, base + 3, base + 2]))
	group["vertices"] = vertices
	group["normals"] = normals
	group["tangents"] = tangents
	group["indices"] = indices


func _transform_token(value: Transform3D) -> String:
	return "%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f" % [
		value.basis.x.x, value.basis.x.y, value.basis.x.z,
		value.basis.y.x, value.basis.y.y, value.basis.y.z,
		value.basis.z.x, value.basis.z.y, value.basis.z.z,
		value.origin.x, value.origin.y, value.origin.z,
	]
