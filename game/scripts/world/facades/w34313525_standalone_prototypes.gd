@tool
extends Node3D

const SOURCE_KEY := "w34313525"
const RECEIVER_KEY := "building:w34313525:wall"
const FIELD_ID := "W34313525-MAT-PALE"
const ROLLUP_PALE_ID := "W34313525-ROLLUP-PALE"
const ROLLUP_GRAY_ID := "W34313525-ROLLUP-GRAY"
const PERSONNEL_ID := "W34313525-PERSONNEL"
const HIGH_GROUP_ID := "W34313525-HIGH-GROUP"
const PROOF_DIMENSIONS_M := Vector2(30.0, 5.0)
const ELIGIBLE_RUNS := [8, 9, 10, 11, 12, 26, 27]


func _ready() -> void:
	if get_node_or_null("PrototypeGeometry") == null:
		_build()


func _build() -> void:
	var geometry := Node3D.new()
	geometry.name = "PrototypeGeometry"
	geometry.set_meta("prototype_only", true)
	geometry.set_meta("runtime_attachment", false)
	geometry.set_meta("exact_receiver_calibration", false)
	geometry.set_meta("native_capture_status", "native_capture_pending_owner_session")
	geometry.set_meta("one_local_unit_m", 1.0)
	geometry.set_meta("proof_dimensions_m", PROOF_DIMENSIONS_M)
	geometry.set_meta("receiver_height_m", 5.0)
	geometry.set_meta("field_scale_assumption_m", 0.88)
	geometry.set_meta("field_scale_uncertainty_m", Vector2(0.35, 1.6))
	geometry.set_meta("eligible_regions_not_placements", ["B06-34313525-SSE-CENTRAL:runs_8_12", "B06-34313525-NNW-CENTRAL:runs_26_27"])
	geometry.set_meta("eligible_run_indices_not_placements", ELIGIBLE_RUNS)
	geometry.set_meta("survey_status", "stylized_reference_derived_production_inference_not_surveyed")
	add_child(geometry)

	var field := load("res://game/resources/materials/world/w34313525/w34313525_pale_field.tres") as Material
	var frame := load("res://game/resources/materials/world/w34313525/w34313525_frame.tres") as Material
	var rollup_pale := load("res://game/resources/materials/world/w34313525/w34313525_rollup_pale.tres") as Material
	var rollup_gray := load("res://game/resources/materials/world/w34313525/w34313525_rollup_gray.tres") as Material
	var personnel := load("res://game/resources/materials/world/w34313525/w34313525_personnel.tres") as Material
	var high_group := load("res://game/resources/materials/world/w34313525/w34313525_high_group.tres") as Material
	geometry.add_child(_box("ContinuousAgedPaleHostFieldProof", Vector3(0.0, 2.5, 0.0), Vector3(PROOF_DIMENSIONS_M.x, PROOF_DIMENSIONS_M.y, 0.12), field))

	geometry.add_child(_build_rollup(ROLLUP_PALE_ID, Vector3(-10.4, 1.86, 0.13), rollup_pale, frame))
	geometry.add_child(_build_rollup(ROLLUP_GRAY_ID, Vector3(-4.8, 1.86, 0.13), rollup_gray, frame))
	geometry.add_child(_build_personnel(Vector3(0.0, 1.26, 0.13), personnel, frame))
	geometry.add_child(_build_high_group(Vector3(6.2, 3.75, 0.13), high_group, frame))


func _build_rollup(motif_id: String, position_m: Vector3, leaf: Material, frame: Material) -> Node3D:
	var module := _module_root(motif_id, position_m, Vector2(3.94, 3.49), Vector4(3.2, 3.0, 5.2, 4.5), "complete_rollup_opening_full_outer_frame_and_slat_field")
	var opening := Vector2(3.8, 3.35)
	module.add_child(_box("Leaf", Vector3.ZERO, Vector3(opening.x, opening.y, 0.09), leaf))
	_add_outer_frame(module, "Frame", Vector3.ZERO, opening, 0.14, frame)
	for slat_index in 8:
		var y := -opening.y * 0.5 + (slat_index + 1.0) * opening.y / 9.0
		module.add_child(_box("Slat%02d" % (slat_index + 1), Vector3(0.0, y, 0.075), Vector3(opening.x, 0.035, 0.055), frame))
	return module


func _build_personnel(position_m: Vector3, leaf: Material, frame: Material) -> Node3D:
	var module := _module_root(PERSONNEL_ID, position_m, Vector2(1.21, 2.31), Vector4(0.85, 1.9, 1.65, 2.8), "complete_plain_personnel_service_door_with_full_outer_frame")
	var opening := Vector2(1.1, 2.2)
	module.add_child(_box("DoorLeaf", Vector3.ZERO, Vector3(opening.x, opening.y, 0.09), leaf))
	_add_outer_frame(module, "Frame", Vector3.ZERO, opening, 0.11, frame)
	return module


func _build_high_group(position_m: Vector3, face: Material, frame: Material) -> Node3D:
	var module := _module_root(HIGH_GROUP_ID, position_m, Vector2(3.3, 0.85), Vector4(2.4, 0.55, 4.8, 1.35), "complete_high_horizontal_window_or_grille_group_with_full_outer_frame")
	var opening := Vector2(3.2, 0.75)
	module.add_child(_box("OpaqueWindowOrGrilleFace", Vector3.ZERO, Vector3(opening.x, opening.y, 0.09), face))
	_add_outer_frame(module, "Frame", Vector3.ZERO, opening, 0.1, frame)
	module.add_child(_box("Mullion01", Vector3(-0.8, 0.0, 0.075), Vector3(0.08, opening.y, 0.055), frame))
	module.add_child(_box("Mullion02", Vector3(0.8, 0.0, 0.075), Vector3(0.08, opening.y, 0.055), frame))
	return module


func _module_root(motif_id: String, position_m: Vector3, nominal_bounds_m: Vector2, uncertainty_bounds_m: Vector4, description: String) -> Node3D:
	var module := Node3D.new()
	module.name = motif_id.replace("-", "_")
	module.position = position_m
	module.set_meta("motif_id", motif_id)
	module.set_meta("asset_kind", "module_atlas")
	module.set_meta("complete_motif", true)
	module.set_meta("module_not_seamless_tile", true)
	module.set_meta("opposite_edge_continuity_required", false)
	module.set_meta("module_owns_field_geometry", false)
	module.set_meta("module_owned_backing_meshes", 0)
	module.set_meta("host_field_contract", "continuous_receiver_field_owns_all_nonopening_pixels")
	module.set_meta("allowed_host_material_ids", [FIELD_ID])
	module.set_meta("nominal_bounds_m", nominal_bounds_m)
	module.set_meta("uncertainty_width_height_m", uncertainty_bounds_m)
	module.set_meta("scale_status", "reversible_unmeasured_production_inference")
	module.set_meta("placement_state", "none_standalone_only")
	module.set_meta("count_status", "unknown_not_encoded")
	module.set_meta("cadence_status", "unknown_not_encoded")
	module.set_meta("surveyed_dimensions", false)
	module.set_meta("surveyed_coordinates", false)
	module.set_meta("eligible_regions_not_placements", ["B06-34313525-SSE-CENTRAL:runs_8_12", "B06-34313525-NNW-CENTRAL:runs_26_27"])
	module.set_meta("description", description)
	return module


func _add_outer_frame(parent: Node3D, prefix: String, position_m: Vector3, opening_m: Vector2, thickness_m: float, material: Material) -> void:
	parent.add_child(_box(prefix + "Top", position_m + Vector3(0.0, opening_m.y * 0.5 + thickness_m * 0.5, 0.08), Vector3(opening_m.x + thickness_m * 2.0, thickness_m, 0.09), material))
	parent.add_child(_box(prefix + "Bottom", position_m + Vector3(0.0, -opening_m.y * 0.5 - thickness_m * 0.5, 0.08), Vector3(opening_m.x + thickness_m * 2.0, thickness_m, 0.09), material))
	parent.add_child(_box(prefix + "Left", position_m + Vector3(-opening_m.x * 0.5 - thickness_m * 0.5, 0.0, 0.08), Vector3(thickness_m, opening_m.y, 0.09), material))
	parent.add_child(_box(prefix + "Right", position_m + Vector3(opening_m.x * 0.5 + thickness_m * 0.5, 0.0, 0.08), Vector3(thickness_m, opening_m.y, 0.09), material))


func _box(node_name: String, position_m: Vector3, size_m: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size_m
	instance.mesh = mesh
	instance.position = position_m
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return instance
