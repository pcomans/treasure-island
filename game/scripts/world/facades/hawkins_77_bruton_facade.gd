class_name Hawkins77BrutonFacade
extends Node3D

const TARGET_SOURCE_KEY := "w1249412093"
const TARGET_LOGICAL_OBJECT_KEY := "building:w1249412093"
const TARGET_RECEIVER_OBJECT_KEY := "building:w1249412093:wall"
const LAYOUT_PATH := "res://game/resources/facades/hawkins_77_bruton_layout.json"
const RENDER_BUILDING_WALL := 1 << 1
const MASSING := preload("res://game/scripts/world/massing/hawkins_77_bruton_massing.gd")

const UPPER_MODULE_LIBRARY := preload("res://game/scenes/world/facades/hawkins/hawkins_upper_modules.tscn")
const GROUND_MODULE_LIBRARY := preload("res://game/scenes/world/facades/hawkins/hawkins_ground_modules.tscn")
const MATERIALS := {
	"pearl_fluted": preload("res://game/resources/materials/world/hawkins/hawkins_pearl_fluted.tres"),
	"pearl_plain": preload("res://game/resources/materials/world/hawkins/hawkins_pearl_plain.tres"),
	"base_smooth": preload("res://game/resources/materials/world/hawkins/hawkins_base_smooth.tres"),
	"base_ribbed": preload("res://game/resources/materials/world/hawkins/hawkins_base_ribbed.tres"),
	"frame_charcoal": preload("res://game/resources/materials/world/hawkins/hawkins_frame_charcoal.tres"),
	"glass_proxy": preload("res://game/resources/materials/world/hawkins/hawkins_glass_proxy.tres"),
	"spandrel_pale": preload("res://game/resources/materials/world/hawkins/hawkins_spandrel_pale.tres"),
	"garage_dark": preload("res://game/resources/materials/world/hawkins/hawkins_garage_dark.tres"),
	"sign_letters": preload("res://game/resources/materials/world/hawkins/hawkins_sign_letters.tres"),
}
const UPPER_MODULE_KINDS := ["W-P", "W-N", "S-H", "R-C"]

var _layout: Dictionary = {}
var _contract: Dictionary = {}
var _sides_by_id: Dictionary = {}
var _side_nodes: Dictionary = {}
var _boxes_by_material: Dictionary = {}
var _module_counts: Dictionary = {}
var _signature_parts: PackedStringArray = []
var _upper_library: Node3D
var _ground_library: Node3D


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


func configure(record: Dictionary, runtime_massing: Dictionary = {}) -> Dictionary:
	if not matches_target(record):
		return {"ok": false, "message": "Hawkins facade refused a non-target receiver."}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH))
	if not (parsed is Dictionary):
		return {"ok": false, "message": "Hawkins layout JSON could not be parsed."}
	_layout = parsed as Dictionary
	_contract = _layout.get("render_contract", {}) as Dictionary
	var target := _layout.get("target", {}) as Dictionary
	var massing := _layout.get("massing", {}) as Dictionary
	if str(target.get("source_key", "")) != TARGET_SOURCE_KEY \
	or str(target.get("logical_object_key", "")) != TARGET_LOGICAL_OBJECT_KEY \
	or str(target.get("receiver_object_key", "")) != TARGET_RECEIVER_OBJECT_KEY \
	or int(target.get("source_wall_segments", 0)) != 20 \
	or int(target.get("source_wall_triangles", 0)) != 40 \
	or str(massing.get("schema_version", "")) != "ti.hawkins-massing-runtime/1" \
	or not _record_massing_matches(record, target) \
	or not _runtime_massing_matches(runtime_massing, target):
		return {"ok": false, "message": "Hawkins layout identity or current receiver massing drifted."}

	name = "Hawkins77BrutonFacade"
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
	set_meta("source_height_m", float(target.source_height_m))
	set_meta("base_y_m", float(target.base_y_m))
	set_meta("band_split_y_m", float(target.band_split_y_m))
	set_meta("main_top_y_m", float(target.main_top_y_m))
	set_meta("companion_top_y_m", float(target.companion_top_y_m))
	set_meta("runtime_massing_schema", str(runtime_massing.schema_version))
	add_to_group("hawkins_render_only_facade")

	_upper_library = UPPER_MODULE_LIBRARY.instantiate() as Node3D
	_ground_library = GROUND_MODULE_LIBRARY.instantiate() as Node3D
	for side_value: Variant in _layout.get("sides", []):
		var side := side_value as Dictionary
		var side_id := str(side.side_id)
		_sides_by_id[side_id] = side
		var side_node := Node3D.new()
		side_node.name = side_id
		side_node.set_meta("side_id", side_id)
		side_node.set_meta("observation", str(side.observation))
		side_node.set_meta("module_policy", str(side.module_policy))
		side_node.set_meta("length_m", float(side.length_m))
		side_node.set_meta("foundation_segment_count", 0)
		side_node.set_meta("main_top_y_m", float(target.main_top_y_m))
		side_node.set_meta("companion_top_y_m", float(target.companion_top_y_m))
		add_child(side_node)
		_side_nodes[side_id] = side_node
		_add_field_descriptor(side_node, "base", str(side.base_material), float(target.base_y_m), float(target.band_split_y_m))
		_add_field_descriptor(side_node, "upper", str(side.upper_material), float(target.band_split_y_m), float(target.main_top_y_m))
	var step_node := Node3D.new()
	step_node.name = "side_step"
	step_node.set_meta("side_id", "side_step")
	step_node.set_meta("observation", "derived_exposed_step")
	step_node.set_meta("module_policy", "material_only")
	step_node.set_meta("material_key", str(massing.step_material))
	step_node.set_meta("foundation_segment_count", 0)
	add_child(step_node)
	_side_nodes["side_step"] = step_node
	_add_field_descriptor(step_node, "upper", str(massing.step_material), float(target.companion_top_y_m), float(target.main_top_y_m))

	var field_result := _build_exact_field_mesh(record, target)
	if not bool(field_result.get("ok", false)):
		_upper_library.free()
		_ground_library.free()
		return field_result

	for side_value: Variant in _layout.get("sides", []):
		var side := side_value as Dictionary
		if str(side.module_policy) == "observed_complete_modules":
			_build_upper_facade(side, target, massing)
			_build_ground_facade(side, target)
		else:
			assert((side.upper_windows as Array).is_empty())
			assert((side.ground_modules as Array).is_empty())
			assert(side.connector_u_m == null)

	_flush_render_batches()
	_upper_library.free()
	_ground_library.free()
	set_meta("module_counts", _module_counts.duplicate(true))
	set_meta("foundation_segment_count", 20)
	set_meta("runtime_exterior_wall_quads", int(field_result.exterior_quads))
	set_meta("runtime_exposed_step_quads", int(field_result.step_quads))
	set_meta("deterministic_signature", "|".join(_signature_parts).sha256_text())
	return {
		"ok": true,
		"module_counts": _module_counts.duplicate(true),
		"foundation_segment_count": 20,
		"runtime_exterior_wall_quads": int(field_result.exterior_quads),
		"runtime_exposed_step_quads": int(field_result.step_quads),
		"deterministic_signature": str(get_meta("deterministic_signature")),
	}


func _record_massing_matches(record: Dictionary, target: Dictionary) -> bool:
	var vertices: Array = record.get("vertices", [])
	var indices: Array = record.get("indices", [])
	if vertices.size() != 240 or indices.size() != 120:
		return false
	var top_y := -INF
	for offset in range(1, vertices.size(), 3):
		top_y = maxf(top_y, float(vertices[offset]))
	return is_equal_approx(top_y, float(target.source_top_y_m)) \
		and is_equal_approx(top_y - float(target.base_y_m), float(target.source_height_m))


func _runtime_massing_matches(runtime_massing: Dictionary, target: Dictionary) -> bool:
	return str(runtime_massing.get("schema_version", "")) == "ti.hawkins-massing-runtime/1" \
		and str(runtime_massing.get("target_source_key", "")) == TARGET_SOURCE_KEY \
		and str(runtime_massing.get("target_logical_object_key", "")) == TARGET_LOGICAL_OBJECT_KEY \
		and is_equal_approx(float(runtime_massing.get("base_y_m", 0.0)), float(target.base_y_m)) \
		and is_equal_approx(float(runtime_massing.get("main_top_y_m", 0.0)), float(target.main_top_y_m)) \
		and is_equal_approx(float(runtime_massing.get("companion_top_y_m", 0.0)), float(target.companion_top_y_m)) \
		and int(runtime_massing.get("runtime_wall_quads", 0)) == int(target.runtime_wall_quads) \
		and int(runtime_massing.get("runtime_wall_triangles", 0)) == int(target.runtime_wall_triangles)


func _add_field_descriptor(side_node: Node3D, band: String, material_key: String, bottom_y: float, top_y: float) -> void:
	var field := Node3D.new()
	field.name = "Field_%s" % band.capitalize()
	field.set_meta("facade_field", true)
	field.set_meta("band", band)
	field.set_meta("material_key", material_key)
	field.set_meta("bottom_y_m", bottom_y)
	field.set_meta("top_y_m", top_y)
	side_node.add_child(field)


func _build_exact_field_mesh(record: Dictionary, target: Dictionary) -> Dictionary:
	var groups := {
		"base_smooth": _empty_surface_group(),
		"pearl_fluted": _empty_surface_group(),
		"pearl_plain": _empty_surface_group(),
	}
	var geometry := MASSING.wall_geometry(record)
	if not bool(geometry.get("ok", false)):
		return geometry
	var exterior_quads := 0
	var step_quads := 0
	for quad_value: Variant in geometry.quads:
		var quad := quad_value as Dictionary
		var start_bottom := quad.start_bottom as Vector3
		var end_bottom := quad.end_bottom as Vector3
		var end_top := quad.end_top as Vector3
		var start_top := quad.start_top as Vector3
		var normal := (quad.normal as Vector3).normalized()
		var role := str(quad.role)
		if role == "step":
			var step_offset := normal * float(_contract.field_offset_m)
			_append_quad(groups.pearl_plain as Dictionary, [
				start_bottom + step_offset,
				end_bottom + step_offset,
				end_top + step_offset,
				start_top + step_offset,
			], normal)
			step_quads += 1
			continue
		var side := _side_for_normal(normal)
		if side.is_empty():
			return {"ok": false, "message": "Hawkins field segment did not match a canonical side."}
		var side_id := str(side.side_id)
		var side_node := _side_nodes[side_id] as Node3D
		side_node.set_meta("foundation_segment_count", int(side_node.get_meta("foundation_segment_count")) + 1)
		var offset := normal * float(_contract.field_offset_m)
		var split_y := float(target.band_split_y_m)
		_append_quad(groups.base_smooth as Dictionary, [
			start_bottom + offset,
			end_bottom + offset,
			Vector3(end_bottom.x, split_y, end_bottom.z) + offset,
			Vector3(start_bottom.x, split_y, start_bottom.z) + offset,
		], normal)
		var upper_key := str(side.upper_material)
		_append_quad(groups[upper_key] as Dictionary, [
			Vector3(start_top.x, split_y, start_top.z) + offset,
			Vector3(end_top.x, split_y, end_top.z) + offset,
			end_top + offset,
			start_top + offset,
		], normal)
		exterior_quads += 1

	if exterior_quads != 22 or step_quads != 1:
		return {"ok": false, "message": "Hawkins facade fields did not match the exact 22 exterior plus one step wall contract."}
	var mesh := ArrayMesh.new()
	for material_key: String in ["base_smooth", "pearl_fluted", "pearl_plain"]:
		var group := groups[material_key] as Dictionary
		if (group.vertices as PackedVector3Array).is_empty():
			continue
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = group.vertices
		arrays[Mesh.ARRAY_NORMAL] = group.normals
		arrays[Mesh.ARRAY_TANGENT] = group.tangents
		arrays[Mesh.ARRAY_INDEX] = group.indices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(mesh.get_surface_count() - 1, MATERIALS[material_key] as Material)
	var fields := MeshInstance3D.new()
	fields.name = "FacadeFields"
	fields.mesh = mesh
	fields.layers = RENDER_BUILDING_WALL
	fields.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	fields.set_meta("facade_visual", true)
	fields.set_meta("exact_receiver_segments", exterior_quads + step_quads)
	fields.set_meta("runtime_exterior_wall_quads", exterior_quads)
	fields.set_meta("runtime_exposed_step_quads", step_quads)
	add_child(fields)
	_signature_parts.append("fields:%d:%d:%d" % [exterior_quads, step_quads, mesh.get_surface_count()])
	return {"ok": true, "exterior_quads": exterior_quads, "step_quads": step_quads}


func _empty_surface_group() -> Dictionary:
	return {
		"vertices": PackedVector3Array(),
		"normals": PackedVector3Array(),
		"tangents": PackedFloat32Array(),
		"indices": PackedInt32Array(),
	}


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


func _side_for_normal(normal: Vector3) -> Dictionary:
	var best: Dictionary = {}
	var best_dot := -1.0
	for side_value: Variant in _layout.sides:
		var side := side_value as Dictionary
		var values: Array = side.normal_xz
		var candidate := Vector3(float(values[0]), 0.0, float(values[1])).normalized()
		var dot := normal.dot(candidate)
		if dot > best_dot:
			best_dot = dot
			best = side
	return best if best_dot >= 0.999 else {}


func _build_upper_facade(side: Dictionary, target: Dictionary, massing: Dictionary) -> void:
	var main_centers: Array = massing.main_upper_centers_y_m
	var main_spandrels: Array = massing.main_spandrel_centers_y_m
	var companion_centers: Array = massing.companion_upper_centers_y_m
	var companion_spandrels: Array = massing.companion_spandrel_centers_y_m
	for u_value: Variant in side.main_upper_windows:
		for story_index in main_centers.size():
			_build_upper_window(side, float(u_value), false, float(main_centers[story_index]), float(main_spandrels[story_index]), "main", float(target.main_top_y_m))
	for u_value: Variant in side.companion_upper_windows:
		for story_index in companion_centers.size():
			_build_upper_window(side, float(u_value), false, float(companion_centers[story_index]), float(companion_spandrels[story_index]), "companion", float(target.companion_top_y_m))
	if side.connector_center_u_m != null:
		for story_index in main_centers.size():
			_build_connector(side, float(side.connector_center_u_m), float(main_centers[story_index]), "main", float(target.main_top_y_m))


func _build_ground_facade(side: Dictionary, target: Dictionary) -> void:
	for region_value: Variant in side.ground_material_regions:
		var region := region_value as Dictionary
		var start_u := float(region.start_u_m)
		var end_u := float(region.end_u_m)
		var material_key := str(region.material)
		_add_box(material_key, side, (start_u + end_u) * 0.5, (float(target.base_y_m) + float(target.band_split_y_m)) * 0.5, end_u - start_u, float(target.band_split_y_m) - float(target.base_y_m), float(_contract.field_offset_m) + 0.001, float(_contract.field_offset_m) + 0.007)
		_add_rib_field(side, start_u, end_u, float(target.base_y_m), float(target.band_split_y_m), material_key, float(_contract.base_rib_pitch_m), float(_contract.base_rib_width_m), float(_contract.base_rib_outer_m))
	for module_value: Variant in side.ground_modules:
		var module := module_value as Dictionary
		var kind := str(module.kind)
		var u := float(module.u_m)
		var width := float(module.width_m)
		var height := float(module.height_m)
		var y := float(module.center_y_m)
		_new_module(kind, side, u, y, width, height)
		match kind:
			"L-G":
				_build_lobby(side, u, y, width, height)
			"D-P":
				_build_paired_door(side, u, y, width, height)
			"D-S":
				_build_service_door(side, u, y, width, height)
			"G-G":
				_build_garage(side, u, y, width, height)
			"F-SIGN":
				_build_sign(side, u, y, width, height)
			"C-B":
				_add_box("spandrel_pale", side, u, y, width, height, float(_contract.field_offset_m), float(_contract.spandrel_outer_m))
			"G-W":
				_build_ground_window(side, u, y, width, height)


func _build_upper_window(side: Dictionary, u: float, narrow: bool, center_y: float, spandrel_y: float, volume_role: String, volume_top_y: float) -> void:
	var width := 0.76 if narrow else 2.0
	var height := 2.3 if narrow else 2.45
	var kind := "W-N" if narrow else "W-P"
	_new_module(kind, side, u, center_y, width, height, volume_role, volume_top_y)
	_add_box("glass_proxy", side, u, center_y, width - 0.2, height - 0.2, float(_contract.field_offset_m), float(_contract.glass_outer_m))
	_add_complete_frame(side, u, center_y, width, height, 0.11, 0)
	if not narrow:
		var transom_y := center_y - height * 0.22
		_add_box("frame_charcoal", side, u, transom_y, width - 0.22, 0.085, float(_contract.glass_outer_m), float(_contract.frame_outer_m))
		_new_module("S-H", side, u, spandrel_y, 2.4, 0.2, volume_role, volume_top_y)
		_add_box("spandrel_pale", side, u, spandrel_y, 2.4, 0.2, float(_contract.field_offset_m), float(_contract.spandrel_outer_m))


func _build_connector(side: Dictionary, u: float, center_y: float, volume_role: String, volume_top_y: float) -> void:
	_new_module("R-C", side, u, center_y, 1.45, 2.82, volume_role, volume_top_y)
	_add_box("base_ribbed", side, u, center_y, 1.45, 2.82, float(_contract.field_offset_m), float(_contract.base_rib_outer_m))
	_build_upper_window(side, u, true, center_y, center_y, volume_role, volume_top_y)


func _build_lobby(side: Dictionary, u: float, y: float, width: float, height: float) -> void:
	_add_box("glass_proxy", side, u, y, width - 0.2, height - 0.2, float(_contract.field_offset_m), float(_contract.glass_outer_m))
	_add_complete_frame(side, u, y, width, height, 0.11, 3)


func _build_ground_window(side: Dictionary, u: float, y: float, width: float, height: float) -> void:
	_add_box("glass_proxy", side, u, y, width - 0.18, height - 0.18, float(_contract.field_offset_m), float(_contract.glass_outer_m))
	_add_complete_frame(side, u, y, width, height, 0.1, 0)


func _build_paired_door(side: Dictionary, u: float, y: float, width: float, height: float) -> void:
	_add_box("glass_proxy", side, u, y, width - 0.18, height - 0.18, float(_contract.field_offset_m), float(_contract.glass_outer_m))
	_add_complete_frame(side, u, y, width, height, 0.1, 1)
	_add_box("frame_charcoal", side, u - width * 0.22, y, 0.035, 0.22, float(_contract.glass_outer_m), float(_contract.frame_outer_m))
	_add_box("frame_charcoal", side, u + width * 0.22, y, 0.035, 0.22, float(_contract.glass_outer_m), float(_contract.frame_outer_m))


func _build_service_door(side: Dictionary, u: float, y: float, width: float, height: float) -> void:
	_add_box("garage_dark", side, u, y, width - 0.16, height - 0.16, float(_contract.field_offset_m), float(_contract.glass_outer_m))
	_add_complete_frame(side, u, y, width, height, 0.1, 0)


func _build_garage(side: Dictionary, u: float, y: float, width: float, height: float) -> void:
	_add_box("garage_dark", side, u, y, width - 0.18, height - 0.18, float(_contract.field_offset_m), float(_contract.glass_outer_m))
	_add_complete_frame(side, u, y, width, height, 0.11, 2)
	for index in 5:
		var bar_y := y - height * 0.32 + float(index) * height * 0.16
		_add_box("frame_charcoal", side, u, bar_y, width - 0.22, 0.045, float(_contract.glass_outer_m), float(_contract.frame_outer_m))


func _build_sign(side: Dictionary, u: float, y: float, width: float, height: float) -> void:
	_add_box("base_ribbed", side, u, y, width, height, float(_contract.field_offset_m), float(_contract.base_rib_outer_m))
	_add_sign_letters(side, u, y, width, height)


func _add_complete_frame(side: Dictionary, u: float, y: float, width: float, height: float, stroke: float, internal_mullions: int) -> void:
	var outer := float(_contract.frame_outer_m)
	var inner := float(_contract.glass_outer_m)
	_add_box("frame_charcoal", side, u - width * 0.5 + stroke * 0.5, y, stroke, height, inner, outer)
	_add_box("frame_charcoal", side, u + width * 0.5 - stroke * 0.5, y, stroke, height, inner, outer)
	_add_box("frame_charcoal", side, u, y - height * 0.5 + stroke * 0.5, width, stroke, inner, outer)
	_add_box("frame_charcoal", side, u, y + height * 0.5 - stroke * 0.5, width, stroke, inner, outer)
	for mullion_index in internal_mullions:
		var fraction := float(mullion_index + 1) / float(internal_mullions + 1)
		_add_box("frame_charcoal", side, u - width * 0.5 + width * fraction, y, stroke * 0.72, height - stroke * 2.0, inner, outer)


func _add_rib_field(side: Dictionary, start_u: float, end_u: float, bottom_y: float, top_y: float, material_key: String, pitch: float, rib_width: float, outer: float) -> void:
	var usable := end_u - start_u
	if usable <= pitch:
		return
	var count := int(floor((usable - rib_width * 2.0) / pitch)) + 1
	var span := float(count - 1) * pitch
	var first := start_u + (usable - span) * 0.5
	for index in count:
		_add_box(material_key, side, first + float(index) * pitch, (bottom_y + top_y) * 0.5, rib_width, top_y - bottom_y, float(_contract.field_offset_m), outer)


func _new_module(kind: String, side: Dictionary, u: float, y: float, width: float, height: float, volume_role: String = "ground", volume_top_y: float = INF) -> Node3D:
	assert(u - width * 0.5 >= -0.0001 and u + width * 0.5 <= float(side.length_m) + 0.0001)
	var maximum_y := float(_layout.target.main_top_y_m) if is_inf(volume_top_y) else volume_top_y
	assert(y - height * 0.5 >= float(_layout.target.base_y_m) - 0.0001 and y + height * 0.5 <= maximum_y + 0.0001)
	var library := _upper_library if kind in UPPER_MODULE_KINDS else _ground_library
	var template_name := kind.replace("-", "_")
	var template := library.get_node(template_name) as Node3D
	assert(template != null and bool(template.get_meta("complete_motif", false)))
	var module := template.duplicate() as Node3D
	var count := int(_module_counts.get(kind, 0)) + 1
	_module_counts[kind] = count
	module.name = "Module_%s_%03d" % [template_name, count]
	module.set_meta("module_kind", kind)
	module.set_meta("side_id", str(side.side_id))
	module.set_meta("side_u_m", u)
	module.set_meta("width_m", width)
	module.set_meta("height_m", height)
	module.set_meta("volume_role", volume_role)
	module.set_meta("volume_top_y_m", maximum_y)
	module.set_meta("render_only", true)
	module.transform = Transform3D(_side_basis(side), _side_point(side, u, y, float(_contract.field_offset_m)))
	(_side_nodes[str(side.side_id)] as Node3D).add_child(module)
	_signature_parts.append("module:%s:%s:%s:%.3f:%.3f:%.3f:%.3f" % [str(side.side_id), volume_role, kind, u, y, width, height])
	return module


func _add_box(material_key: String, side: Dictionary, u: float, y: float, width: float, height: float, inner: float, outer: float) -> void:
	assert(MATERIALS.has(material_key))
	assert(width > 0.0 and height > 0.0 and outer >= inner)
	assert(u - width * 0.5 >= -0.0001 and u + width * 0.5 <= float(side.length_m) + 0.0001)
	assert(y - height * 0.5 >= float(_layout.target.base_y_m) - 0.0001 and y + height * 0.5 <= float(_layout.target.main_top_y_m) + 0.0001)
	assert(outer <= float(_contract.maximum_relief_m) + 0.0001)
	var basis := _side_basis(side)
	basis.x *= width
	basis.y *= height
	basis.z *= outer - inner
	var transform := Transform3D(basis, _side_point(side, u, y, (inner + outer) * 0.5))
	if not _boxes_by_material.has(material_key):
		_boxes_by_material[material_key] = []
	(_boxes_by_material[material_key] as Array).append(transform)


func _add_sign_letters(side: Dictionary, center_u: float, center_y: float, fascia_width: float, fascia_height: float) -> void:
	var glyphs := {
		"H": [[0.0, 0.0, 0.0, 1.0], [1.0, 0.0, 1.0, 1.0], [0.0, 0.5, 1.0, 0.5]],
		"A": [[0.0, 0.0, 0.18, 1.0], [1.0, 0.0, 0.82, 1.0], [0.18, 1.0, 0.82, 1.0], [0.1, 0.52, 0.9, 0.52]],
		"W": [[0.0, 1.0, 0.2, 0.0], [0.2, 0.0, 0.5, 0.55], [0.5, 0.55, 0.8, 0.0], [0.8, 0.0, 1.0, 1.0]],
		"K": [[0.0, 0.0, 0.0, 1.0], [0.0, 0.5, 1.0, 1.0], [0.0, 0.5, 1.0, 0.0]],
		"I": [[0.0, 1.0, 1.0, 1.0], [0.5, 0.0, 0.5, 1.0], [0.0, 0.0, 1.0, 0.0]],
		"N": [[0.0, 0.0, 0.0, 1.0], [0.0, 1.0, 1.0, 0.0], [1.0, 0.0, 1.0, 1.0]],
		"S": [[0.0, 1.0, 1.0, 1.0], [0.0, 0.5, 1.0, 0.5], [0.0, 0.0, 1.0, 0.0], [0.0, 0.5, 0.0, 1.0], [1.0, 0.0, 1.0, 0.5]],
	}
	var text := "HAWKINS"
	var letter_width := minf(0.38, fascia_width / 9.5)
	var letter_height := minf(0.34, fascia_height * 0.62)
	var gap := letter_width * 0.26
	var total_width := float(text.length()) * letter_width + float(text.length() - 1) * gap
	var start_u := center_u - total_width * 0.5
	var stroke := minf(0.055, letter_width * 0.16)
	for letter_index in text.length():
		var letter := text.substr(letter_index, 1)
		var letter_u := start_u + float(letter_index) * (letter_width + gap)
		for segment_value: Variant in glyphs[letter]:
			var segment := segment_value as Array
			var from := Vector2(letter_u + float(segment[0]) * letter_width, center_y - letter_height * 0.5 + float(segment[1]) * letter_height)
			var to := Vector2(letter_u + float(segment[2]) * letter_width, center_y - letter_height * 0.5 + float(segment[3]) * letter_height)
			_add_facade_bar("sign_letters", side, from, to, stroke, float(_contract.base_rib_outer_m), float(_contract.letter_outer_m))


func _add_facade_bar(material_key: String, side: Dictionary, from: Vector2, to: Vector2, stroke: float, inner: float, outer: float) -> void:
	var delta := to - from
	var length := delta.length()
	if length <= 0.0001:
		return
	var local_direction := delta / length
	var tangent := _side_basis(side).x
	var normal := _side_basis(side).z
	var direction := tangent * local_direction.x + Vector3.UP * local_direction.y
	var perpendicular := tangent * -local_direction.y + Vector3.UP * local_direction.x
	var basis := Basis(direction * length, perpendicular * stroke, normal * (outer - inner))
	var midpoint := (from + to) * 0.5
	var origin := _side_point(side, midpoint.x, midpoint.y, (inner + outer) * 0.5)
	if not _boxes_by_material.has(material_key):
		_boxes_by_material[material_key] = []
	(_boxes_by_material[material_key] as Array).append(Transform3D(basis, origin))


func _side_basis(side: Dictionary) -> Basis:
	var start_values: Array = side.start_xz_m
	var end_values: Array = side.end_xz_m
	var normal_values: Array = side.normal_xz
	var tangent := Vector3(float(end_values[0]) - float(start_values[0]), 0.0, float(end_values[1]) - float(start_values[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	return Basis(tangent, Vector3.UP, normal)


func _side_point(side: Dictionary, u: float, y: float, outward: float) -> Vector3:
	var start_values: Array = side.start_xz_m
	var basis := _side_basis(side)
	return Vector3(float(start_values[0]), y, float(start_values[1])) + basis.x * u + basis.z * outward


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
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF \
			if material_key == "pearl_fluted" \
			else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		instance.set_meta("facade_visual", true)
		instance.set_meta("material_key", material_key)
		instance.set_meta("instance_count", transforms.size())
		batches.add_child(instance)


func _transform_token(value: Transform3D) -> String:
	return "%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f" % [
		value.basis.x.x, value.basis.x.y, value.basis.x.z,
		value.basis.y.x, value.basis.y.y, value.basis.y.z,
		value.basis.z.x, value.basis.z.y, value.basis.z.z,
		value.origin.x, value.origin.y, value.origin.z,
	]
