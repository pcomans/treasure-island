@tool
extends Node3D

const UV_LAYOUT := preload("res://game/scripts/world/facades/d1_b225_cumulative_meter_uv_v1.gd")
const SOURCE_KEY := "w95934119"
const RECEIVER_KEY := "building:w95934119:wall"
const MAPPING_ID := "14812-NNW-LONG"
const RUNS: Array[int] = [10, 11, 12, 13]
const RUN_LENGTHS_M: Array[float] = [10.372629078, 6.510893794, 7.049860211, 22.328585289]
const WIDTH_M := 46.261968372
const HEIGHT_M := 5.0
const RENDER_BUILDING_WALL := 1 << 1

const MATERIALS := {
	"b225_cladding_v1": preload("res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres"),
	"shared_dark_glass": preload("res://game/resources/materials/world/d1_current/shared_dark_glass.tres"),
	"shared_pale_frame": preload("res://game/resources/materials/world/d1_current/shared_pale_frame.tres"),
}


func _ready() -> void:
	if get_node_or_null("B225_w95934119_CladdingRepairV1") == null:
		_build()


func _build() -> void:
	set_meta("prototype_only", true)
	set_meta("runtime_attachment", false)
	set_meta("exact_receiver_layout", false)
	set_meta("standalone_side_length_calibrated", true)
	set_meta("review_status", "pending_independent_bar_raiser_re_review_not_self_accepted")
	set_meta("one_local_unit_m", 1.0)
	set_meta("collision", "none")
	set_meta("navigation", "none")
	set_meta("spray_owner", "none")

	var prototype := Node3D.new()
	prototype.name = "B225_w95934119_CladdingRepairV1"
	prototype.set_meta("prototype_only", true)
	prototype.set_meta("runtime_attachment", false)
	prototype.set_meta("exact_receiver_layout", false)
	prototype.set_meta("standalone_side_length_calibrated", true)
	prototype.set_meta("source_key", SOURCE_KEY)
	prototype.set_meta("receiver_key_eligibility_only", RECEIVER_KEY)
	prototype.set_meta("mapping_id", MAPPING_ID)
	prototype.set_meta("observed_side", "NNW public long side")
	prototype.set_meta("eligible_run_indices_not_placements", RUNS)
	prototype.set_meta("eligible_run_lengths_m", RUN_LENGTHS_M)
	prototype.set_meta("side_length_m", WIDTH_M)
	prototype.set_meta("height_m", HEIGHT_M)
	prototype.set_meta("recognition_cues", ["varied continuous high clerestory grouping", "restrained aged light horizontal cladding on a low near-flat-roof mass"])
	prototype.set_meta("production_inference", true)
	prototype.set_meta("counts_cadence_dimensions_not_surveyed", true)
	prototype.set_meta("nonclaims", ["common name or current business identity", "cladding substrate or proprietary profile", "exact pane count, group width, cadence or damage", "lower openings or entrances", "unobserved sides, corners, returns or roof equipment"])
	prototype.set_meta("review_status", "pending_independent_bar_raiser_re_review_not_self_accepted")
	prototype.set_meta("collision", "none")
	prototype.set_meta("navigation", "none")
	prototype.set_meta("spray_owner", "none")
	add_child(prototype)

	var plan := UV_LAYOUT.exact_plan() as Dictionary
	assert(bool(plan.get("ok", false)))
	assert(absf(float(plan.get("total_u_m", 0.0)) - WIDTH_M) <= 0.000000001)
	var signature_parts: Array[String] = []
	var render_root := Node3D.new()
	render_root.name = "RenderOnlyMeshes"
	render_root.set_meta("render_only", true)
	render_root.set_meta("collision", "none")
	render_root.set_meta("navigation", "none")
	render_root.set_meta("spray_owner", "none")
	prototype.add_child(render_root)
	render_root.add_child(_build_cumulative_field(plan, signature_parts))

	var boxes: Dictionary = {}
	var group_widths: Array[float] = [3.4, 4.1, 3.2, 5.0, 4.0, 4.4, 3.1, 5.1, 3.5, 4.2]
	var pane_counts: Array[int] = [4, 5, 4, 6, 5, 5, 4, 6, 4, 5]
	var group_gap_m := 0.42
	var group_total_m := 0.0
	for group_width in group_widths:
		group_total_m += group_width
	var group_cursor := -WIDTH_M * 0.5 + (WIDTH_M - group_total_m - group_gap_m * 9.0) * 0.5
	for group_index in group_widths.size():
		var group_width_m := group_widths[group_index]
		var group_center_x := group_cursor + group_width_m * 0.5
		var opening := Vector2(group_width_m, 1.04)
		_add_box(boxes, signature_parts, "shared_dark_glass", "ClerestoryGlass%02d" % group_index, Vector3(group_center_x, 4.08, 0.15), Vector3(opening.x, opening.y, 0.08))
		_add_complete_frame(boxes, signature_parts, "B225Clerestory%02d" % group_index, Vector3(group_center_x, 4.08, 0.21), opening, 0.10, pane_counts[group_index] - 1)
		group_cursor += group_width_m + group_gap_m
	_add_box(boxes, signature_parts, "shared_pale_frame", "ContinuousClerestorySill", Vector3(0.0, 3.48, 0.21), Vector3(WIDTH_M, 0.12, 0.12))
	_add_box(boxes, signature_parts, "shared_pale_frame", "QuietRoofEdgeCap", Vector3(0.0, 4.90, 0.18), Vector3(WIDTH_M, 0.14, 0.12))
	_flush_batches(render_root, boxes)

	var box_count := 0
	for transforms_value: Variant in boxes.values():
		box_count += (transforms_value as Array).size()
	signature_parts.sort()
	var signature := JSON.stringify(signature_parts).sha256_text()
	prototype.set_meta("uv_plan_signature", str(plan.get("signature", "")))
	prototype.set_meta("geometry_signature", signature)
	prototype.set_meta("mesh_instance_count", 3)
	prototype.set_meta("batch_count", 3)
	prototype.set_meta("run_quad_count", 4)
	prototype.set_meta("box_instance_count", box_count)
	prototype.set_meta("triangle_count", 8 + box_count * 12)
	prototype.set_meta("texture_cell_m", Vector2(8.0, 3.48))
	set_meta("geometry_signature", signature)
	set_meta("mesh_instance_count", 3)
	set_meta("batch_count", 3)
	set_meta("run_quad_count", 4)
	set_meta("box_instance_count", box_count)
	set_meta("triangle_count", 8 + box_count * 12)


func _build_cumulative_field(plan: Dictionary, signature_parts: Array[String]) -> MeshInstance3D:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for entry_value: Variant in plan.get("entries", []) as Array:
		var entry := entry_value as Dictionary
		var u_start_m := float(entry.get("u_start_m", 0.0))
		var u_end_m := float(entry.get("u_end_m", 0.0))
		var left_x := -WIDTH_M * 0.5 + u_start_m
		var right_x := -WIDTH_M * 0.5 + u_end_m
		var base := vertices.size()
		vertices.append_array(PackedVector3Array([
			Vector3(left_x, 0.0, 0.10),
			Vector3(right_x, 0.0, 0.10),
			Vector3(right_x, HEIGHT_M, 0.10),
			Vector3(left_x, HEIGHT_M, 0.10),
		]))
		for unused in 4:
			normals.append(Vector3.FORWARD)
		uvs.append_array(UV_LAYOUT.vertical_quad_uvs(u_start_m, u_end_m, HEIGHT_M))
		indices.append_array(PackedInt32Array([base, base + 2, base + 1, base, base + 3, base + 2]))
		signature_parts.append("field|run:%d|x:%.9f:%.9f|uv:%.9f:%.9f|v:0.000000000:%.9f" % [
			int(entry.get("run_index", -1)), left_x, right_x, u_start_m, u_end_m, HEIGHT_M,
		])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, MATERIALS["b225_cladding_v1"] as Material)
	var instance := MeshInstance3D.new()
	instance.name = "Field_CumulativeMetreCladding_Runs10_13"
	instance.mesh = mesh
	instance.layers = RENDER_BUILDING_WALL
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	instance.set_meta("render_only", true)
	instance.set_meta("material_key", "b225_cladding_v1")
	instance.set_meta("ordered_runs", RUNS)
	instance.set_meta("u_start_m", 0.0)
	instance.set_meta("u_end_m", WIDTH_M)
	instance.set_meta("v_start_m", 0.0)
	instance.set_meta("v_end_m", HEIGHT_M)
	instance.set_meta("quad_count", 4)
	instance.set_meta("triangles", 8)
	return instance


func _add_complete_frame(boxes: Dictionary, signature_parts: Array[String], prefix: String, center: Vector3, opening: Vector2, thickness_m: float, internal_mullions: int) -> void:
	_add_outer_frame(boxes, signature_parts, prefix, center, opening, thickness_m)
	for mullion_index in internal_mullions:
		var fraction := float(mullion_index + 1) / float(internal_mullions + 1)
		var x := center.x - opening.x * 0.5 + opening.x * fraction
		_add_box(boxes, signature_parts, "shared_pale_frame", "%sMullion%02d" % [prefix, mullion_index], Vector3(x, center.y, center.z), Vector3(thickness_m, opening.y, 0.12))


func _add_outer_frame(boxes: Dictionary, signature_parts: Array[String], prefix: String, center: Vector3, opening: Vector2, thickness_m: float) -> void:
	_add_box(boxes, signature_parts, "shared_pale_frame", prefix + "Top", center + Vector3(0.0, opening.y * 0.5 + thickness_m * 0.5, 0.0), Vector3(opening.x + thickness_m * 2.0, thickness_m, 0.12))
	_add_box(boxes, signature_parts, "shared_pale_frame", prefix + "Bottom", center + Vector3(0.0, -opening.y * 0.5 - thickness_m * 0.5, 0.0), Vector3(opening.x + thickness_m * 2.0, thickness_m, 0.12))
	_add_box(boxes, signature_parts, "shared_pale_frame", prefix + "Left", center + Vector3(-opening.x * 0.5 - thickness_m * 0.5, 0.0, 0.0), Vector3(thickness_m, opening.y, 0.12))
	_add_box(boxes, signature_parts, "shared_pale_frame", prefix + "Right", center + Vector3(opening.x * 0.5 + thickness_m * 0.5, 0.0, 0.0), Vector3(thickness_m, opening.y, 0.12))


func _add_box(boxes: Dictionary, signature_parts: Array[String], material_key: String, component_name: String, origin: Vector3, size: Vector3) -> void:
	assert(MATERIALS.has(material_key))
	assert(size.x > 0.0 and size.y > 0.0 and size.z > 0.0)
	var basis := Basis(Vector3.RIGHT * size.x, Vector3.UP * size.y, Vector3.BACK * size.z)
	var transform := Transform3D(basis, origin)
	if not boxes.has(material_key):
		boxes[material_key] = []
	(boxes[material_key] as Array).append(transform)
	signature_parts.append("%s|%s|%s" % [material_key, component_name, _transform_token(transform)])


func _flush_batches(render_root: Node3D, boxes: Dictionary) -> void:
	var material_keys := boxes.keys()
	material_keys.sort()
	for material_key_value: Variant in material_keys:
		var material_key := str(material_key_value)
		var transforms := boxes[material_key] as Array
		var box := BoxMesh.new()
		box.size = Vector3.ONE
		box.material = MATERIALS[material_key] as Material
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = box
		multimesh.instance_count = transforms.size()
		for index in transforms.size():
			multimesh.set_instance_transform(index, transforms[index] as Transform3D)
		var instance := MultiMeshInstance3D.new()
		instance.name = "Batch_%s" % material_key
		instance.multimesh = multimesh
		instance.layers = RENDER_BUILDING_WALL
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		instance.set_meta("render_only", true)
		instance.set_meta("material_key", material_key)
		instance.set_meta("instance_count", transforms.size())
		instance.set_meta("triangles", transforms.size() * 12)
		render_root.add_child(instance)


func _transform_token(value: Transform3D) -> String:
	return "%.6f,%.6f,%.6f|%.6f,%.6f,%.6f|%.6f,%.6f,%.6f|%.6f,%.6f,%.6f" % [
		value.basis.x.x, value.basis.x.y, value.basis.x.z,
		value.basis.y.x, value.basis.y.y, value.basis.y.z,
		value.basis.z.x, value.basis.z.y, value.basis.z.z,
		value.origin.x, value.origin.y, value.origin.z,
	]
