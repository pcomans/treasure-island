@tool
extends Node3D

const SOURCE_KEY := "w34313520"
const RECEIVER_KEY := "building:w34313520:wall"
const FIELD_ID := "W34313520-MAT-PALE"
const BAY_ID := "W34313520-BAY"
const PROOF_DIMENSIONS_M := Vector2(30.0, 11.0)
const BAY_NOMINAL_BOUNDS_M := Vector2(6.8, 9.4)
const BAY_SCALE_UNCERTAINTY_M := Vector4(4.8, 7.6, 9.5, 10.5)
const ELIGIBLE_RUNS := [6, 7, 8, 9, 10]


func _ready() -> void:
	if get_node_or_null("PrototypeGeometry") == null:
		_build()


func _build() -> void:
	var geometry := Node3D.new()
	geometry.name = "PrototypeGeometry"
	geometry.set_meta("prototype_only", true)
	geometry.set_meta("runtime_attachment", false)
	geometry.set_meta("calibration_state", "not_started")
	geometry.set_meta("one_local_unit_m", 1.0)
	geometry.set_meta("proof_dimensions_m", PROOF_DIMENSIONS_M)
	geometry.set_meta("receiver_height_m", 11.0)
	geometry.set_meta("field_scale_assumption_m", 0.95)
	geometry.set_meta("field_scale_uncertainty_m", Vector2(0.35, 1.8))
	geometry.set_meta("mapped_side_region", "SSE long outer elevation only")
	geometry.set_meta("eligible_run_indices_not_placements", ELIGIBLE_RUNS)
	geometry.set_meta("survey_status", "stylized_reference_derived_production_inference_not_surveyed")
	add_child(geometry)

	var field := load("res://game/resources/materials/world/w34313520/w34313520_pale_field.tres") as Material
	var frame := load("res://game/resources/materials/world/w34313520/w34313520_bay_frame.tres") as Material
	var glass := load("res://game/resources/materials/world/w34313520/w34313520_bay_glass.tres") as Material
	geometry.add_child(_box("ContinuousPaleHostFieldProof", Vector3(0.0, 5.5, 0.0), Vector3(PROOF_DIMENSIONS_M.x, PROOF_DIMENSIONS_M.y, 0.12), field))

	var bay := Node3D.new()
	bay.name = "W34313520_BAY"
	bay.position = Vector3(0.0, 5.35, 0.13)
	bay.set_meta("motif_id", BAY_ID)
	bay.set_meta("asset_kind", "module_atlas")
	bay.set_meta("complete_motif", true)
	bay.set_meta("module_not_seamless_tile", true)
	bay.set_meta("opposite_edge_continuity_required", false)
	bay.set_meta("module_owns_field_geometry", false)
	bay.set_meta("module_owned_backing_meshes", 0)
	bay.set_meta("host_field_contract", "continuous_receiver_field_owns_all_nonopening_pixels")
	bay.set_meta("host_provided_boundary", "pale outer and inter-tier pier space remains continuous host field")
	bay.set_meta("allowed_host_material_ids", [FIELD_ID])
	bay.set_meta("nominal_bounds_m", BAY_NOMINAL_BOUNDS_M)
	bay.set_meta("uncertainty_width_height_m", BAY_SCALE_UNCERTAINTY_M)
	bay.set_meta("scale_status", "reversible_unmeasured_production_inference")
	bay.set_meta("placement_state", "none_standalone_only")
	bay.set_meta("eligible_region_not_placement", "B06-34313520-SSE-OUTER:runs_6_10")
	bay.set_meta("cadence_status", "unknown_not_encoded")
	bay.set_meta("description", "Complete three-tier horizontal-window group with full dark frames; pale outer and inter-tier pier boundaries are visible continuous host field, never module backing.")
	for tier in 3:
		_add_unsubdivided_framed_window(bay, "Tier%02d" % (tier + 1), Vector3(0.0, -3.05 + tier * 3.05, 0.13), Vector2(5.6, 1.55), frame, glass)
	geometry.add_child(bay)


func _add_unsubdivided_framed_window(parent: Node3D, prefix: String, position_m: Vector3, opening_m: Vector2, frame: Material, glass: Material) -> void:
	parent.add_child(_box(prefix + "MutedGlazing", position_m, Vector3(opening_m.x, opening_m.y, 0.09), glass))
	var thickness_m := 0.12
	parent.add_child(_box(prefix + "FrameTop", position_m + Vector3(0.0, opening_m.y * 0.5, 0.08), Vector3(opening_m.x + thickness_m, thickness_m, 0.09), frame))
	parent.add_child(_box(prefix + "FrameBottom", position_m + Vector3(0.0, -opening_m.y * 0.5, 0.08), Vector3(opening_m.x + thickness_m, thickness_m, 0.09), frame))
	parent.add_child(_box(prefix + "FrameLeft", position_m + Vector3(-opening_m.x * 0.5, 0.0, 0.08), Vector3(thickness_m, opening_m.y, 0.09), frame))
	parent.add_child(_box(prefix + "FrameRight", position_m + Vector3(opening_m.x * 0.5, 0.0, 0.08), Vector3(thickness_m, opening_m.y, 0.09), frame))


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
