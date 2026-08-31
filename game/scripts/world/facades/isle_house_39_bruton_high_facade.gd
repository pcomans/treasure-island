class_name IsleHouse39BrutonHighFacade
extends Node3D

const TARGET_PARENT_SOURCE_KEY := "w1249412094"
const TARGET_SOURCE_KEY := "w1282547786"
const TARGET_LOW_SOURCE_KEY := "w1282547787"
const TARGET_LOGICAL_OBJECT_KEY := "building-composite:w1249412094"
const TARGET_RECEIVER_OBJECT_KEY := "building-composite:w1249412094:w1282547786:wall"
const TARGET_LOW_RECEIVER_OBJECT_KEY := "building-composite:w1249412094:w1282547787:wall"
const LAYOUT_PATH := "res://game/resources/facades/isle_house_39_bruton_high_se_layout.json"
const RENDER_BUILDING_WALL := 1 << 1
const EXTERIOR_FIELD_RUN_INDICES := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
const NEW_EXTERIOR_FIELD_RUN_INDICES := [0, 1, 2, 3, 4]
const SHARED_TOWER_FIELD_RUN_INDICES := [10, 11, 12]
const MODULE_FREE_RUN_INDICES := [0, 1, 2, 3, 4, 8, 9, 10, 11, 12]
const RUN_STARTS := [
	Vector3(-133.374, 4.065, 548.466), Vector3(-133.067, 4.074, 549.067),
	Vector3(-128.000, 3.932, 558.996), Vector3(-125.636, 3.923, 563.627),
	Vector3(-120.336, 3.908, 568.336), Vector3(-117.142, 3.942, 571.175),
	Vector3(-96.000, 3.927, 547.172), Vector3(-93.206, 3.968, 544.000),
	Vector3(-89.198, 3.990, 539.449), Vector3(-89.959, 3.954, 537.959),
	Vector3(-95.775, 19.103, 526.591), Vector3(-107.522, 19.103, 522.651),
	Vector3(-130.305, 19.103, 546.840),
]
const RUN_ENDS := [
	Vector3(-133.067, 4.074, 549.067), Vector3(-128.000, 3.932, 558.996),
	Vector3(-125.636, 3.923, 563.627), Vector3(-120.336, 3.908, 568.336),
	Vector3(-117.142, 3.942, 571.175), Vector3(-96.000, 3.927, 547.172),
	Vector3(-93.206, 3.968, 544.000), Vector3(-89.198, 3.990, 539.449),
	Vector3(-89.959, 3.954, 537.959), Vector3(-95.775, 4.099, 526.591),
	Vector3(-107.522, 19.103, 522.651), Vector3(-130.305, 19.103, 546.840),
	Vector3(-133.374, 19.103, 548.466),
]
const RUN_NORMALS_XZ := [
	Vector2(-0.891, 0.455), Vector2(-0.891, 0.455), Vector2(-0.891, 0.455),
	Vector2(-0.664, 0.748), Vector2(-0.664, 0.748), Vector2(0.750, 0.661),
	Vector2(0.750, 0.661), Vector2(0.750, 0.661), Vector2(0.890, -0.455),
	Vector2(0.890, -0.455), Vector2(0.318, -0.948), Vector2(-0.728, -0.686),
	Vector2(-0.468, -0.884),
]

const MODULE_LIBRARY := preload("res://game/scenes/world/facades/isle_house/isle_house_high_modules.tscn")
const MATERIALS := {
	"tower_light": preload("res://game/resources/materials/world/isle_house/isle_house_tower_light.tres"),
	"tower_accent": preload("res://game/resources/materials/world/isle_house/isle_house_tower_accent.tres"),
	"podium_light": preload("res://game/resources/materials/world/isle_house/isle_house_podium_light.tres"),
	"dark_charcoal": preload("res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres"),
	"glass_proxy": preload("res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres"),
	"support_grey": preload("res://game/resources/materials/world/isle_house/isle_house_support_grey.tres"),
	"identifier": preload("res://game/resources/materials/world/isle_house/isle_house_identifier.tres"),
}

var _layout: Dictionary = {}
var _contract: Dictionary = {}
var _se: Dictionary = {}
var _ene: Dictionary = {}
var _boxes_by_material: Dictionary = {}
var _module_counts: Dictionary = {}
var _signature_parts: PackedStringArray = []
var _module_library: Node3D
var _side_nodes: Dictionary = {}


static func matches_target(record: Dictionary) -> bool:
	var source_keys: Array = record.get("source_keys", [])
	return str(record.get("object_key", "")) == TARGET_RECEIVER_OBJECT_KEY \
		and str(record.get("feature_kind", "")) == "building_part_wall" \
		and str(record.get("material_key", "")) == "building_part_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and source_keys.size() == 1 \
		and str(source_keys[0]) == TARGET_SOURCE_KEY


func configure(record: Dictionary) -> Dictionary:
	if not matches_target(record):
		return {"ok": false, "message": "Isle House high facade refused a non-target receiver."}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH))
	if not (parsed is Dictionary):
		return {"ok": false, "message": "Isle House high layout JSON could not be parsed."}
	_layout = parsed as Dictionary
	_contract = _layout.render_contract as Dictionary
	_se = _layout.observed_high_se as Dictionary
	_ene = _layout.partial_high_ene as Dictionary
	var target := _layout.target as Dictionary
	if str(target.parent_source_key) != TARGET_PARENT_SOURCE_KEY \
	or str(target.source_key) != TARGET_SOURCE_KEY \
	or str(target.low_source_key) != TARGET_LOW_SOURCE_KEY \
	or str(target.logical_object_key) != TARGET_LOGICAL_OBJECT_KEY \
	or str(target.receiver_object_key) != TARGET_RECEIVER_OBJECT_KEY \
	or str(target.low_receiver_object_key) != TARGET_LOW_RECEIVER_OBJECT_KEY \
	or int(target.wall_segments) != 13 \
	or int(target.wall_triangles) != 26 \
	or not _record_massing_matches(record, target) \
	or not _all_runs_match(record, target) \
	or not _exact_runs_match(record, _se) \
	or not _exact_runs_match(record, _ene):
		return {"ok": false, "message": "Isle House layout identity, scoped runs, or high receiver massing drifted."}

	name = "IsleHouse39BrutonHighFacade"
	set_meta("target_parent_source_key", TARGET_PARENT_SOURCE_KEY)
	set_meta("target_source_key", TARGET_SOURCE_KEY)
	set_meta("target_low_source_key", TARGET_LOW_SOURCE_KEY)
	set_meta("target_logical_object_key", TARGET_LOGICAL_OBJECT_KEY)
	set_meta("target_receiver_object_key", TARGET_RECEIVER_OBJECT_KEY)
	set_meta("layout_path", LAYOUT_PATH)
	set_meta("layout_sha256", FileAccess.get_sha256(LAYOUT_PATH))
	set_meta("render_only", true)
	set_meta("collision", "none")
	set_meta("navigation", "none")
	set_meta("spray_ray_owner", "unchanged_underlying_receiver")
	set_meta("maximum_relief_m", float(_contract.maximum_relief_m))
	set_meta("module_run_indices", _int_array(_se.run_indices as Array))
	set_meta("exterior_field_run_indices", EXTERIOR_FIELD_RUN_INDICES.duplicate())
	set_meta("new_exterior_field_run_indices", NEW_EXTERIOR_FIELD_RUN_INDICES.duplicate())
	set_meta("material_only_run_indices", MODULE_FREE_RUN_INDICES.duplicate())
	set_meta("preserved_partial_material_only_run_indices", _int_array(_ene.run_indices as Array))
	set_meta("shared_tower_field_run_indices", SHARED_TOWER_FIELD_RUN_INDICES.duplicate())
	set_meta("excluded_high_run_indices", _int_array(_layout.excluded_high_run_indices as Array))
	set_meta("shared_above_low_run_indices", _int_array(_layout.shared_above_low_run_indices as Array))
	set_meta("low_part_policy", str(_layout.low_part_policy))
	add_to_group("isle_house_high_render_only_facade")

	_add_side_node("High_WSW_SW_Runs_0_4", {"run_indices": NEW_EXTERIOR_FIELD_RUN_INDICES, "length_m": 28.385}, "material_only")
	_add_side_node("High_SE_Runs_5_7", _se, "observed_complete_modules")
	_add_side_node("High_ENE_Runs_8_9", _ene, "material_only")
	_add_side_node("High_Shared_Runs_10_12", {"run_indices": SHARED_TOWER_FIELD_RUN_INDICES, "length_m": 49.092}, "tower_field_only")
	var field_result := _build_fields(record, target)
	if not bool(field_result.get("ok", false)):
		return field_result

	_module_library = MODULE_LIBRARY.instantiate() as Node3D
	_build_tower_modules()
	_build_podium_modules()
	for module_value: Variant in _se.single_modules:
		_build_single_module(module_value as Dictionary)
	_module_library.free()
	_flush_render_batches()
	set_meta("module_counts", _module_counts.duplicate(true))
	set_meta("field_segment_count", int(field_result.segment_count))
	set_meta("field_quad_count", int(field_result.quad_count))
	set_meta("deterministic_signature", "|".join(_signature_parts).sha256_text())
	return {
		"ok": true,
		"module_counts": _module_counts.duplicate(true),
		"field_segment_count": int(field_result.segment_count),
		"field_quad_count": int(field_result.quad_count),
		"deterministic_signature": str(get_meta("deterministic_signature")),
	}


func _record_massing_matches(record: Dictionary, target: Dictionary) -> bool:
	var vertices: Array = record.get("vertices", [])
	var indices: Array = record.get("indices", [])
	if vertices.size() != 156 or indices.size() != 78:
		return false
	var top_y := -INF
	for offset in range(1, vertices.size(), 3):
		top_y = maxf(top_y, float(vertices[offset]))
	return is_equal_approx(top_y, float(target.top_y_m)) \
		and is_equal_approx(top_y - float(target.base_y_m), float(target.height_m))


func _all_runs_match(record: Dictionary, target: Dictionary) -> bool:
	var raw_vertices: Array = record.get("vertices", [])
	var raw_normals: Array = record.get("normals", [])
	if raw_vertices.size() != 156 or raw_normals.size() != 156:
		return false
	for run_index in 13:
		var offset := run_index * 12
		var actual_start := Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2]))
		var actual_end := Vector3(float(raw_vertices[offset + 3]), float(raw_vertices[offset + 4]), float(raw_vertices[offset + 5]))
		var actual_normal := Vector2(float(raw_normals[offset]), float(raw_normals[offset + 2])).normalized()
		if actual_start.distance_to(RUN_STARTS[run_index]) > 0.0006 \
		or actual_end.distance_to(RUN_ENDS[run_index]) > 0.0006 \
		or actual_normal.distance_to((RUN_NORMALS_XZ[run_index] as Vector2).normalized()) > 0.001 \
		or absf(float(raw_vertices[offset + 7]) - float(target.top_y_m)) > 0.0006 \
		or absf(float(raw_vertices[offset + 10]) - float(target.top_y_m)) > 0.0006:
			return false
	return true


func _exact_runs_match(record: Dictionary, side: Dictionary) -> bool:
	var raw_vertices: Array = record.vertices
	for run_value: Variant in side.runs:
		var expected := run_value as Dictionary
		var offset := int(expected.index) * 12
		var start: Array = expected.start_xz_m
		var end: Array = expected.end_xz_m
		if not is_equal_approx(float(raw_vertices[offset]), float(start[0])) \
		or not is_equal_approx(float(raw_vertices[offset + 2]), float(start[1])) \
		or not is_equal_approx(float(raw_vertices[offset + 3]), float(end[0])) \
		or not is_equal_approx(float(raw_vertices[offset + 5]), float(end[1])):
			return false
	return true


func _add_side_node(node_name: String, side: Dictionary, policy: String) -> void:
	var side_node := Node3D.new()
	side_node.name = node_name
	side_node.set_meta("run_indices", _int_array(side.run_indices as Array))
	side_node.set_meta("length_m", float(side.length_m))
	side_node.set_meta("module_policy", policy)
	side_node.set_meta("foundation_geometry_untouched", true)
	add_child(side_node)
	_side_nodes[node_name] = side_node


func _build_fields(record: Dictionary, target: Dictionary) -> Dictionary:
	var groups := {"podium_light": _empty_surface_group(), "tower_light": _empty_surface_group()}
	var raw_vertices: Array = record.vertices
	var raw_normals: Array = record.normals
	for run_index in 13:
		var offset := run_index * 12
		var start_x := float(raw_vertices[offset])
		var start_y := float(raw_vertices[offset + 1])
		var start_z := float(raw_vertices[offset + 2])
		var end_x := float(raw_vertices[offset + 3])
		var end_y := float(raw_vertices[offset + 4])
		var end_z := float(raw_vertices[offset + 5])
		var normal := Vector3(float(raw_normals[offset]), 0.0, float(raw_normals[offset + 2])).normalized()
		var outward := normal * float(_contract.field_offset_m)
		if run_index in EXTERIOR_FIELD_RUN_INDICES:
			_append_quad(groups.podium_light as Dictionary, [
				Vector3(start_x, start_y, start_z) + outward,
				Vector3(end_x, end_y, end_z) + outward,
				Vector3(end_x, float(target.low_top_y_m), end_z) + outward,
				Vector3(start_x, float(target.low_top_y_m), start_z) + outward,
			], normal)
		_append_quad(groups.tower_light as Dictionary, [
			Vector3(start_x, float(target.low_top_y_m), start_z) + outward,
			Vector3(end_x, float(target.low_top_y_m), end_z) + outward,
			Vector3(end_x, float(target.top_y_m), end_z) + outward,
			Vector3(start_x, float(target.top_y_m), start_z) + outward,
		], normal)
	var mesh := ArrayMesh.new()
	for material_key: String in ["podium_light", "tower_light"]:
		var group := groups[material_key] as Dictionary
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = group.vertices
		arrays[Mesh.ARRAY_NORMAL] = group.normals
		arrays[Mesh.ARRAY_TANGENT] = group.tangents
		arrays[Mesh.ARRAY_INDEX] = group.indices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(mesh.get_surface_count() - 1, MATERIALS[material_key] as Material)
	var fields := MeshInstance3D.new()
	fields.name = "FacadeFields_All_High_Runs"
	fields.mesh = mesh
	fields.layers = RENDER_BUILDING_WALL
	fields.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	fields.set_meta("facade_visual", true)
	fields.set_meta("exterior_field_run_indices", EXTERIOR_FIELD_RUN_INDICES.duplicate())
	fields.set_meta("new_exterior_field_run_indices", NEW_EXTERIOR_FIELD_RUN_INDICES.duplicate())
	fields.set_meta("module_run_indices", _int_array(_se.run_indices as Array))
	fields.set_meta("module_free_run_indices", MODULE_FREE_RUN_INDICES.duplicate())
	fields.set_meta("shared_tower_field_run_indices", SHARED_TOWER_FIELD_RUN_INDICES.duplicate())
	fields.set_meta("low_receiver_untouched", true)
	add_child(fields)
	_signature_parts.append("fields:all-high:13:23:2")
	return {"ok": true, "segment_count": 13, "quad_count": 23}


func _build_tower_modules() -> void:
	for region_value: Variant in _se.tower_accent_regions:
		var region := region_value as Dictionary
		_add_box("tower_accent", float(region.u_m), (float(region.bottom_y_m) + float(region.top_y_m)) * 0.5, float(region.width_m), float(region.top_y_m) - float(region.bottom_y_m), float(_contract.field_offset_m), 0.028)
	var descriptor := _se.tower_window as Dictionary
	for u_value: Variant in _se.tower_window_columns_u_m:
		for y_value: Variant in _se.tower_window_rows_y_m:
			var u := float(u_value)
			var y := float(y_value)
			var width := float(descriptor.width_m)
			var height := float(descriptor.height_m)
			_new_module("IH-TW", u, y, width, height)
			_build_framed_glazing(u, y, width, height, 0.085, "dark_charcoal")


func _build_podium_modules() -> void:
	for family_value: Variant in _se.podium_window_families:
		var family := family_value as Dictionary
		for u_value: Variant in family.columns_u_m:
			for y_value: Variant in _se.podium_window_rows_y_m:
				var u := float(u_value)
				var y := float(y_value)
				var width := float(family.width_m)
				var height := float(family.height_m)
				_new_module(str(family.kind), u, y, width, height)
				_build_framed_glazing(u, y, width, height, 0.13, "dark_charcoal")


func _build_single_module(module: Dictionary) -> void:
	var kind := str(module.kind)
	var u := float(module.u_m)
	var y := float(module.center_y_m)
	var width := float(module.width_m)
	var height := float(module.height_m)
	_new_module(kind, u, y, width, height)
	match kind:
		"IH-CW":
			_build_framed_glazing(u, y, width, height, 0.14, "support_grey")
			for division in [0.25, 0.5, 0.75]:
				_add_box("support_grey", u, y - height * 0.5 + height * float(division), width - 0.28, 0.07, 0.03, 0.052)
		"IH-GG":
			_build_framed_glazing(u, y, width, height, 0.15, "support_grey")
		"IH-ENTRY39":
			_build_framed_glazing(u, y, width, height, 0.15, "support_grey")
			_add_box("support_grey", u, y - 0.25, 0.09, height - 0.3, 0.03, 0.058)
			_add_box("support_grey", u, y + height * 0.24, width - 0.3, 0.10, 0.03, 0.058)
			_add_identifier_39(u, y + 1.2)
		"IH-LVR":
			_add_box("dark_charcoal", u, y, width, height, float(_contract.field_offset_m), 0.052)
			for index in 4:
				_add_box("support_grey", u, y - height * 0.3 + float(index) * height * 0.2, width - 0.18, 0.035, 0.052, 0.066)
		"IH-CANOPY":
			_add_box("dark_charcoal", u, y, width, height, float(_contract.field_offset_m), 0.078)


func _build_framed_glazing(u: float, y: float, width: float, height: float, stroke: float, frame_material: String) -> void:
	_add_box("glass_proxy", u, y, width - stroke * 2.0, height - stroke * 2.0, float(_contract.field_offset_m), 0.032)
	_add_box(frame_material, u - width * 0.5 + stroke * 0.5, y, stroke, height, 0.032, 0.058)
	_add_box(frame_material, u + width * 0.5 - stroke * 0.5, y, stroke, height, 0.032, 0.058)
	_add_box(frame_material, u, y - height * 0.5 + stroke * 0.5, width, stroke, 0.032, 0.058)
	_add_box(frame_material, u, y + height * 0.5 - stroke * 0.5, width, stroke, 0.032, 0.058)


func _new_module(kind: String, u: float, y: float, width: float, height: float) -> void:
	var template := _module_library.get_node(kind.replace("-", "_")) as Node3D
	assert(template != null and bool(template.get_meta("complete_motif", false)))
	assert(u - width * 0.5 >= -0.0001 and u + width * 0.5 <= float(_se.length_m) + 0.0001)
	var module := template.duplicate() as Node3D
	var count := int(_module_counts.get(kind, 0)) + 1
	_module_counts[kind] = count
	module.name = "Module_%s_%03d" % [kind.replace("-", "_"), count]
	module.set_meta("module_kind", kind)
	module.set_meta("run_scope", "high_se_5_7")
	module.set_meta("side_u_m", u)
	module.set_meta("width_m", width)
	module.set_meta("height_m", height)
	module.set_meta("render_only", true)
	module.transform = Transform3D(_side_basis(_se), _side_point(_se, u, y, float(_contract.field_offset_m)))
	(_side_nodes["High_SE_Runs_5_7"] as Node3D).add_child(module)
	_signature_parts.append("module:%s:%.3f:%.3f:%.3f:%.3f" % [kind, u, y, width, height])


func _add_box(material_key: String, u: float, y: float, width: float, height: float, inner: float, outer: float) -> void:
	assert(width > 0.0 and height > 0.0 and outer >= inner)
	assert(outer <= float(_contract.maximum_relief_m) + 0.0001)
	assert(u - width * 0.5 >= -0.0001 and u + width * 0.5 <= float(_se.length_m) + 0.0001)
	var basis := _side_basis(_se)
	basis.x *= width
	basis.y *= height
	basis.z *= outer - inner
	var transform := Transform3D(basis, _side_point(_se, u, y, (inner + outer) * 0.5))
	if not _boxes_by_material.has(material_key):
		_boxes_by_material[material_key] = []
	(_boxes_by_material[material_key] as Array).append(transform)


func _add_identifier_39(center_u: float, center_y: float) -> void:
	var glyphs := {
		"3": [[0.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 0.0], [0.0, 0.5, 1.0, 0.5], [0.0, 0.0, 1.0, 0.0]],
		"9": [[0.0, 1.0, 1.0, 1.0], [0.0, 0.5, 0.0, 1.0], [0.0, 0.5, 1.0, 0.5], [1.0, 1.0, 1.0, 0.0]],
	}
	var width := 0.26
	var height := 0.38
	var stroke := 0.045
	for glyph_index in 2:
		var glyph := "3" if glyph_index == 0 else "9"
		var glyph_u := center_u - 0.34 + float(glyph_index) * 0.42
		for segment_value: Variant in glyphs[glyph]:
			var segment := segment_value as Array
			var from := Vector2(glyph_u + float(segment[0]) * width, center_y - height * 0.5 + float(segment[1]) * height)
			var to := Vector2(glyph_u + float(segment[2]) * width, center_y - height * 0.5 + float(segment[3]) * height)
			_add_facade_bar("identifier", from, to, stroke, 0.058, 0.074)


func _add_facade_bar(material_key: String, from: Vector2, to: Vector2, stroke: float, inner: float, outer: float) -> void:
	var delta := to - from
	var length := delta.length()
	if length <= 0.0001:
		return
	var local_direction := delta / length
	var tangent := _side_basis(_se).x
	var normal := _side_basis(_se).z
	var direction := tangent * local_direction.x + Vector3.UP * local_direction.y
	var perpendicular := tangent * -local_direction.y + Vector3.UP * local_direction.x
	var basis := Basis(direction * length, perpendicular * stroke, normal * (outer - inner))
	var midpoint := (from + to) * 0.5
	var origin := _side_point(_se, midpoint.x, midpoint.y, (inner + outer) * 0.5)
	if not _boxes_by_material.has(material_key):
		_boxes_by_material[material_key] = []
	(_boxes_by_material[material_key] as Array).append(Transform3D(basis, origin))


func _side_basis(side: Dictionary) -> Basis:
	var start: Array = side.start_xz_m
	var end: Array = side.end_xz_m
	var normal_values: Array = side.normal_xz
	var tangent := Vector3(float(end[0]) - float(start[0]), 0.0, float(end[1]) - float(start[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	return Basis(tangent, Vector3.UP, normal)


func _side_point(side: Dictionary, u: float, y: float, outward: float) -> Vector3:
	var start: Array = side.start_xz_m
	var basis := _side_basis(side)
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
