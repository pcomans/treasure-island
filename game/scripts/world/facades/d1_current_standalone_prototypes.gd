@tool
extends Node3D

const B201_SOURCE_KEY := "w34313545"
const B201_RECEIVER_KEY := "building:w34313545:wall"
const B201_MAPPING_ID := "800I-PUBLIC-WSW"
const B201_RUNS: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
const B201_RUN_LENGTHS_M: Array[float] = [8.395309702, 10.181251102, 13.457963962, 22.843742360, 0.795472815, 1.484884507, 22.154330547, 11.867490763, 11.771724300, 12.560491431]
const B201_WIDTH_M := 115.512661489
const B201_POSITION := Vector3(-32.0, 0.0, 0.0)

const B225_SOURCE_KEY := "w95934119"
const B225_RECEIVER_KEY := "building:w95934119:wall"
const B225_MAPPING_ID := "14812-NNW-LONG"
const B225_RUNS: Array[int] = [10, 11, 12, 13]
const B225_RUN_LENGTHS_M: Array[float] = [10.372629078, 6.510893794, 7.049860211, 22.328585289]
const B225_WIDTH_M := 46.261968372
const B225_POSITION := Vector3(68.0, 0.0, 0.0)

const HEIGHT_M := 5.0
const RENDER_BUILDING_WALL := 1 << 1

const MATERIALS := {
	"shared_dark_glass": preload("res://game/resources/materials/world/d1_current/shared_dark_glass.tres"),
	"shared_pale_frame": preload("res://game/resources/materials/world/d1_current/shared_pale_frame.tres"),
	"shared_deep_reveal": preload("res://game/resources/materials/world/d1_current/shared_deep_reveal.tres"),
	"b201_warm_wall": preload("res://game/resources/materials/world/d1_current/b201_warm_wall.tres"),
	"b201_green_hierarchy": preload("res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres"),
	"b201_muted_rust_post": preload("res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres"),
	"b201_service_leaf": preload("res://game/resources/materials/world/d1_current/b201_service_leaf.tres"),
	"b225_aged_cladding": preload("res://game/resources/materials/world/d1_current/b225_aged_horizontal_cladding.tres"),
}


func _ready() -> void:
	if get_node_or_null("B201_w34313545") == null:
		_build()


func _build() -> void:
	set_meta("prototype_only", true)
	set_meta("runtime_attachment", false)
	set_meta("exact_receiver_layout", false)
	set_meta("standalone_side_length_calibrated", true)
	set_meta("review_status", "pending_independent_recognition_and_bar_review_not_self_accepted")
	set_meta("one_local_unit_m", 1.0)
	set_meta("collision", "none")
	set_meta("navigation", "none")
	set_meta("spray_owner", "none")

	var b201 := _build_b201()
	b201.position = B201_POSITION
	add_child(b201)
	var b225 := _build_b225()
	b225.position = B225_POSITION
	add_child(b225)
	var pair_signature := "%s|%s" % [str(b201.get_meta("geometry_signature", "")), str(b225.get_meta("geometry_signature", ""))]
	set_meta("geometry_signature", pair_signature.sha256_text())
	set_meta("box_instance_count", int(b201.get_meta("box_instance_count", 0)) + int(b225.get_meta("box_instance_count", 0)))
	set_meta("triangle_count", int(b201.get_meta("triangle_count", 0)) + int(b225.get_meta("triangle_count", 0)))


func _build_b201() -> Node3D:
	var prototype := _prototype_root(
		"B201_w34313545",
		B201_SOURCE_KEY,
		B201_RECEIVER_KEY,
		B201_MAPPING_ID,
		B201_RUNS,
		B201_RUN_LENGTHS_M,
		B201_WIDTH_M,
		"WSW public long side",
		["green-bounded broad upper-window register", "mostly solid light lower field with sparse nonsemantic openings"],
		["address or tenant identity", "exact window count, width or cadence", "exact canopy dimensions or endpoints", "service ENE, SSE, NNW, short, corner or return geometry"]
	)
	var boxes: Dictionary = {}
	var signature_parts: Array[String] = []

	var run_cursor := -B201_WIDTH_M * 0.5
	for run_offset in B201_RUN_LENGTHS_M.size():
		var length_m := B201_RUN_LENGTHS_M[run_offset]
		_add_box(boxes, signature_parts, "b201_warm_wall", "RunField%02d" % B201_RUNS[run_offset], Vector3(run_cursor + length_m * 0.5, HEIGHT_M * 0.5, 0.0), Vector3(length_m, HEIGHT_M, 0.20))
		run_cursor += length_m

	var register_margin_m := 1.35
	var register_span_m := B201_WIDTH_M - register_margin_m * 2.0
	var bay_pitch_m := register_span_m / 18.0
	var glass_width_m := bay_pitch_m - 0.88
	var register_start_m := -B201_WIDTH_M * 0.5 + register_margin_m
	for pier_index in 19:
		_add_box(boxes, signature_parts, "b201_warm_wall", "UpperPier%02d" % pier_index, Vector3(register_start_m + bay_pitch_m * pier_index, 3.66, 0.17), Vector3(0.56, 1.28, 0.14))
	for bay_index in 18:
		var center_x := register_start_m + bay_pitch_m * (bay_index + 0.5)
		var opening := Vector2(glass_width_m, 1.05)
		_add_box(boxes, signature_parts, "shared_dark_glass", "UpperGlass%02d" % bay_index, Vector3(center_x, 3.66, 0.15), Vector3(opening.x, opening.y, 0.08))
		_add_complete_frame(boxes, signature_parts, "B201Upper%02d" % bay_index, Vector3(center_x, 3.66, 0.21), opening, 0.11, 2)

	_add_box(boxes, signature_parts, "b201_green_hierarchy", "LowerRegisterBand", Vector3(0.0, 3.02, 0.22), Vector3(B201_WIDTH_M, 0.22, 0.16))
	_add_box(boxes, signature_parts, "b201_green_hierarchy", "UpperRegisterBand", Vector3(0.0, 4.30, 0.22), Vector3(B201_WIDTH_M, 0.20, 0.16))
	_add_box(boxes, signature_parts, "b201_green_hierarchy", "RoofParapetCap", Vector3(0.0, 4.91, 0.20), Vector3(B201_WIDTH_M, 0.18, 0.16))
	var canopy_center_x := -6.0
	var canopy_width_m := 58.0
	_add_box(boxes, signature_parts, "b201_warm_wall", "CanopySlab", Vector3(canopy_center_x, 2.73, 0.98), Vector3(canopy_width_m, 0.18, 1.76))
	_add_box(boxes, signature_parts, "b201_green_hierarchy", "CanopyFrontFascia", Vector3(canopy_center_x, 2.70, 1.91), Vector3(canopy_width_m, 0.34, 0.12))
	for post_index in 7:
		var post_x := canopy_center_x - canopy_width_m * 0.5 + 2.2 + post_index * ((canopy_width_m - 4.4) / 6.0)
		_add_box(boxes, signature_parts, "b201_muted_rust_post", "CanopyPost%02d" % post_index, Vector3(post_x, 1.31, 1.66), Vector3(0.18, 2.62, 0.18))

	var service_xs: Array[float] = [-43.0, -4.0, 38.0]
	for door_index in service_xs.size():
		var door_center := Vector3(service_xs[door_index], 1.14, 0.16)
		var door_opening := Vector2(1.34, 2.14)
		_add_box(boxes, signature_parts, "b201_service_leaf", "SparseServiceLeaf%02d" % door_index, door_center, Vector3(door_opening.x, door_opening.y, 0.09))
		_add_outer_frame(boxes, signature_parts, "B201Service%02d" % door_index, door_center + Vector3(0.0, 0.0, 0.06), door_opening, 0.11)

	_flush_batches(prototype, boxes)
	_finish_prototype(prototype, boxes, signature_parts)
	return prototype


func _build_b225() -> Node3D:
	var prototype := _prototype_root(
		"B225_w95934119",
		B225_SOURCE_KEY,
		B225_RECEIVER_KEY,
		B225_MAPPING_ID,
		B225_RUNS,
		B225_RUN_LENGTHS_M,
		B225_WIDTH_M,
		"NNW public long side",
		["varied continuous high clerestory grouping", "aged light horizontal cladding on a low near-flat-roof mass"],
		["common name or current business identity", "exact pane count, group width, cadence or damage", "lower openings or entrances", "WSW end openings, SSE, ENE, endpoint, corner or roof-equipment geometry"]
	)
	var boxes: Dictionary = {}
	var signature_parts: Array[String] = []

	var run_cursor := -B225_WIDTH_M * 0.5
	for run_offset in B225_RUN_LENGTHS_M.size():
		var length_m := B225_RUN_LENGTHS_M[run_offset]
		_add_box(boxes, signature_parts, "b225_aged_cladding", "RunField%02d" % B225_RUNS[run_offset], Vector3(run_cursor + length_m * 0.5, HEIGHT_M * 0.5, 0.0), Vector3(length_m, HEIGHT_M, 0.20))
		run_cursor += length_m

	for course_index in 14:
		var course_y := 0.43 + course_index * 0.245
		_add_box(boxes, signature_parts, "shared_deep_reveal", "HorizontalCourse%02d" % course_index, Vector3(0.0, course_y, 0.125), Vector3(B225_WIDTH_M, 0.034, 0.035))

	var group_widths: Array[float] = [3.4, 4.1, 3.2, 5.0, 4.0, 4.4, 3.1, 5.1, 3.5, 4.2]
	var pane_counts: Array[int] = [4, 5, 4, 6, 5, 5, 4, 6, 4, 5]
	var group_gap_m := 0.42
	var group_total_m := 0.0
	for group_width in group_widths:
		group_total_m += group_width
	var group_cursor := -B225_WIDTH_M * 0.5 + (B225_WIDTH_M - group_total_m - group_gap_m * 9.0) * 0.5
	for group_index in group_widths.size():
		var group_width_m := group_widths[group_index]
		var group_center_x := group_cursor + group_width_m * 0.5
		var opening := Vector2(group_width_m, 1.04)
		_add_box(boxes, signature_parts, "shared_dark_glass", "ClerestoryGlass%02d" % group_index, Vector3(group_center_x, 4.08, 0.15), Vector3(opening.x, opening.y, 0.08))
		_add_complete_frame(boxes, signature_parts, "B225Clerestory%02d" % group_index, Vector3(group_center_x, 4.08, 0.21), opening, 0.10, pane_counts[group_index] - 1)
		group_cursor += group_width_m + group_gap_m
	_add_box(boxes, signature_parts, "shared_pale_frame", "ContinuousClerestorySill", Vector3(0.0, 3.48, 0.21), Vector3(B225_WIDTH_M, 0.12, 0.12))
	_add_box(boxes, signature_parts, "shared_pale_frame", "QuietRoofEdgeCap", Vector3(0.0, 4.90, 0.18), Vector3(B225_WIDTH_M, 0.14, 0.12))

	_flush_batches(prototype, boxes)
	_finish_prototype(prototype, boxes, signature_parts)
	return prototype


func _prototype_root(node_name: String, source_key: String, receiver_key: String, mapping_id: String, run_indices: Array[int], run_lengths_m: Array[float], width_m: float, observed_side: String, recognition_cues: Array[String], nonclaims: Array[String]) -> Node3D:
	var prototype := Node3D.new()
	prototype.name = node_name
	prototype.set_meta("prototype_only", true)
	prototype.set_meta("runtime_attachment", false)
	prototype.set_meta("exact_receiver_layout", false)
	prototype.set_meta("standalone_side_length_calibrated", true)
	prototype.set_meta("source_key", source_key)
	prototype.set_meta("receiver_key_eligibility_only", receiver_key)
	prototype.set_meta("mapping_id", mapping_id)
	prototype.set_meta("observed_side", observed_side)
	prototype.set_meta("eligible_run_indices_not_placements", run_indices)
	prototype.set_meta("eligible_run_lengths_m", run_lengths_m)
	prototype.set_meta("side_length_m", width_m)
	prototype.set_meta("height_m", HEIGHT_M)
	prototype.set_meta("recognition_cues", recognition_cues)
	prototype.set_meta("production_inference", true)
	prototype.set_meta("counts_cadence_dimensions_not_surveyed", true)
	prototype.set_meta("nonclaims", nonclaims)
	prototype.set_meta("identity_provenance_not_visual_proof", true)
	prototype.set_meta("review_status", "pending_independent_recognition_and_bar_review_not_self_accepted")
	prototype.set_meta("collision", "none")
	prototype.set_meta("navigation", "none")
	prototype.set_meta("spray_owner", "none")
	return prototype


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


func _flush_batches(prototype: Node3D, boxes: Dictionary) -> void:
	var batches := Node3D.new()
	batches.name = "RenderOnlyBatches"
	batches.set_meta("render_only", true)
	batches.set_meta("collision", "none")
	batches.set_meta("navigation", "none")
	batches.set_meta("spray_owner", "none")
	prototype.add_child(batches)
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
		batches.add_child(instance)


func _finish_prototype(prototype: Node3D, boxes: Dictionary, signature_parts: Array[String]) -> void:
	var box_count := 0
	for transforms_value: Variant in boxes.values():
		box_count += (transforms_value as Array).size()
	signature_parts.sort()
	prototype.set_meta("geometry_signature", JSON.stringify(signature_parts).sha256_text())
	prototype.set_meta("batch_count", boxes.size())
	prototype.set_meta("box_instance_count", box_count)
	prototype.set_meta("triangle_count", box_count * 12)


func _transform_token(value: Transform3D) -> String:
	return "%.6f,%.6f,%.6f|%.6f,%.6f,%.6f|%.6f,%.6f,%.6f|%.6f,%.6f,%.6f" % [
		value.basis.x.x, value.basis.x.y, value.basis.x.z,
		value.basis.y.x, value.basis.y.y, value.basis.y.z,
		value.basis.z.x, value.basis.z.y, value.basis.z.z,
		value.origin.x, value.origin.y, value.origin.z,
	]
