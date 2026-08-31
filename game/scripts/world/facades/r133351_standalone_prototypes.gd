@tool
extends Node3D

const SOURCE_KEY := "r133351"
const RECEIVER_KEY := "building:r133351:wall"
const LIGHT_FIELD_ID := "R133351-MAT-LIGHT"
const OLIVE_FIELD_ID := "R133351-MAT-OLIVE"
const LOWER_FIELD_ID := "R133351-MAT-LOWER"
const HWIN_ID := "R133351-HWIN-LIGHT"
const WEST_LOWER_ID := "R133351-WEST-LOWER"
const WESTERN_ELIGIBLE_RUNS := [0, 1, 2, 3, 4, 5, 6]
const SSE_ELIGIBLE_RUNS := [21, 22, 25, 27, 28, 38, 41]


func _ready() -> void:
	if get_node_or_null("PrototypeGeometry") == null:
		_build()


func _build() -> void:
	var geometry := Node3D.new()
	geometry.name = "PrototypeGeometry"
	geometry.set_meta("source_key", SOURCE_KEY)
	geometry.set_meta("receiver_key", RECEIVER_KEY)
	geometry.set_meta("prototype_only", true)
	geometry.set_meta("runtime_attachment", false)
	geometry.set_meta("exact_receiver_calibration", false)
	geometry.set_meta("one_local_unit_m", 1.0)
	geometry.set_meta("asset_kind_counts", {"homogeneous_material_tile": 3, "architectural_pattern_tile": 0, "module_atlas": 2, "unique_elevation": 0})
	geometry.set_meta("western_eligible_runs_not_placements", WESTERN_ELIGIBLE_RUNS)
	geometry.set_meta("sse_eligible_runs_not_placements", SSE_ELIGIBLE_RUNS)
	geometry.set_meta("survey_status", "stylized_reference_derived_production_inference_not_surveyed")
	geometry.set_meta("count_cadence_sequence_status", "unknown_not_encoded")
	add_child(geometry)

	var light_field := load("res://game/resources/materials/world/r133351/r133351_light_field.tres") as Material
	var olive_field := load("res://game/resources/materials/world/r133351/r133351_olive_field.tres") as Material
	var lower_field := load("res://game/resources/materials/world/r133351/r133351_lower_field.tres") as Material
	var frame := load("res://game/resources/materials/world/r133351/r133351_frame.tres") as Material
	var glass := load("res://game/resources/materials/world/r133351/r133351_glass.tres") as Material

	geometry.add_child(_field_proof("LightFieldProof30m", LIGHT_FIELD_ID, Vector3(-32.0, 1.5, 0.0), Vector3(30.0, 3.0, 0.12), light_field, Vector2(0.9, 0.25), SSE_ELIGIBLE_RUNS))
	geometry.add_child(_field_proof("OliveFieldProof30m", OLIVE_FIELD_ID, Vector3(0.0, 1.5, 0.0), Vector3(30.0, 3.0, 0.12), olive_field, Vector2(0.9, 0.25), WESTERN_ELIGIBLE_RUNS))
	geometry.add_child(_field_proof("LowerFieldProof12m", LOWER_FIELD_ID, Vector3(23.0, 0.6, 0.0), Vector3(12.0, 1.2, 0.12), lower_field, Vector2(0.5, 0.18), WESTERN_ELIGIBLE_RUNS))
	geometry.add_child(_build_hwin(Vector3(-10.0, 5.2, 0.2), frame, glass))
	geometry.add_child(_build_west_lower(Vector3(10.0, 5.1, 0.2), frame, glass, lower_field))


func _field_proof(node_name: String, material_id: String, position_m: Vector3, size_m: Vector3, material: Material, scales_m: Vector2, eligible_runs: Array) -> MeshInstance3D:
	var instance := _box(node_name, position_m, size_m, material)
	instance.set_meta("material_id", material_id)
	instance.set_meta("asset_kind", "homogeneous_material_tile")
	instance.set_meta("contains_facade_scale_motifs", false)
	instance.set_meta("finite_facade_motif_period", "none_by_design")
	instance.set_meta("local_meter_space_aperiodic_field", true)
	instance.set_meta("primary_secondary_scale_m", scales_m)
	instance.set_meta("scale_status", "reversible_unmeasured_stylized_reference_derived_production_inference")
	instance.set_meta("surveyed_color", false)
	instance.set_meta("surveyed_finish_scale", false)
	instance.set_meta("eligible_runs_not_placements", eligible_runs)
	return instance


func _build_hwin(position_m: Vector3, frame: Material, glass: Material) -> Node3D:
	var module := _module_root(HWIN_ID, position_m, Vector2(3.6, 1.2), Vector4(2.4, 0.75, 5.4, 1.65), SSE_ELIGIBLE_RUNS, "complete broad multi-pane dark window group with full outer frame and zero pale wall backing")
	var opening := Vector2(3.4, 1.0)
	module.add_child(_box("GlazingFace", Vector3.ZERO, Vector3(opening.x, opening.y, 0.09), glass))
	_add_outer_frame(module, "Frame", Vector3.ZERO, opening, 0.1, frame)
	for index in 3:
		var x := -0.85 + float(index) * 0.85
		module.add_child(_box("Mullion%02d" % (index + 1), Vector3(x, 0.0, 0.075), Vector3(0.07, opening.y, 0.055), frame))
	module.set_meta("internal_pane_count", 4)
	module.set_meta("surveyed_pane_count", false)
	return module


func _build_west_lower(position_m: Vector3, frame: Material, glass: Material, lower: Material) -> Node3D:
	var module := _module_root(WEST_LOWER_ID, position_m, Vector2(3.6, 2.1), Vector4(2.4, 1.35, 5.4, 2.7), WESTERN_ELIGIBLE_RUNS, "complete western dark window group with full outer frame and one bounded red-brown lower panel, zero olive wall backing")
	var opening := Vector2(3.4, 1.1)
	var opening_center := Vector3(0.0, 0.4, 0.0)
	module.add_child(_box("GlazingFace", opening_center, Vector3(opening.x, opening.y, 0.09), glass))
	_add_outer_frame(module, "Frame", opening_center, opening, 0.1, frame)
	for index in 3:
		var x := -0.85 + float(index) * 0.85
		module.add_child(_box("Mullion%02d" % (index + 1), opening_center + Vector3(x, 0.0, 0.075), Vector3(0.07, opening.y, 0.055), frame))
	module.add_child(_box("BoundedLowerPanel", Vector3(0.0, -0.675, 0.0), Vector3(3.6, 0.75, 0.09), lower))
	module.set_meta("internal_pane_count", 4)
	module.set_meta("surveyed_pane_count", false)
	module.set_meta("lower_panel_is_discrete_module_content", true)
	module.set_meta("lower_panel_height_m", 0.75)
	module.set_meta("surveyed_lower_panel_height", false)
	return module


func _module_root(motif_id: String, position_m: Vector3, nominal_bounds_m: Vector2, uncertainty_bounds_m: Vector4, eligible_runs: Array, description: String) -> Node3D:
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
	module.set_meta("module_owned_collision_nodes", 0)
	module.set_meta("module_owned_navigation_nodes", 0)
	module.set_meta("module_owned_spray_nodes", 0)
	module.set_meta("host_field_contract", "continuous_receiver_field_owns_all_nonopening_pixels")
	module.set_meta("nominal_bounds_m", nominal_bounds_m)
	module.set_meta("uncertainty_width_height_m", uncertainty_bounds_m)
	module.set_meta("scale_status", "reversible_unmeasured_stylized_reference_derived_production_inference")
	module.set_meta("placement_state", "none_standalone_only")
	module.set_meta("count_status", "unknown_not_encoded")
	module.set_meta("cadence_status", "unknown_not_encoded")
	module.set_meta("sequence_status", "unknown_not_encoded")
	module.set_meta("surveyed_dimensions", false)
	module.set_meta("surveyed_coordinates", false)
	module.set_meta("surveyed_count", false)
	module.set_meta("surveyed_cadence", false)
	module.set_meta("eligible_runs_not_placements", eligible_runs)
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
