@tool
extends Node3D

const SOURCE_KEY := "r16681702"
const RECEIVER_KEY := "building:r16681702:wall"
const FIELD_ID := "B1-MAT-IVORY"
const PROOF_DIMENSIONS_M := Vector2(40.0, 10.0)
const MODULE_IDS := ["B1-WING-W", "B1-CENTRAL-W", "B1-PAV-W", "B1-BASE-O", "B1-DOOR-BLUE", "B1-BAND"]


func _ready() -> void:
	if get_node_or_null("PrototypeGeometry") == null:
		_build()


func _build() -> void:
	var geometry := Node3D.new()
	geometry.name = "PrototypeGeometry"
	geometry.set_meta("prototype_only", true)
	geometry.set_meta("runtime_attachment", false)
	geometry.set_meta("exact_receiver_calibration", false)
	geometry.set_meta("review_status", "native_capture_pending_independent_standalone_art_review")
	geometry.set_meta("one_local_unit_m", 1.0)
	geometry.set_meta("proof_dimensions_m", PROOF_DIMENSIONS_M)
	geometry.set_meta("receiver_height_m", 20.0)
	geometry.set_meta("field_scale_assumption_m", 1.1)
	geometry.set_meta("field_scale_uncertainty_m", Vector2(0.5, 1.8))
	geometry.set_meta("eligible_regions_not_placements", ["OUTER-WING", "OUTER-CENTRAL", "OUTER-PAVILION", "OUTER-BASE", "OUTER-BANDS"])
	geometry.set_meta("receiver_runs_available_not_eligible_placements", "outer_0_99_inner_100_109_exact_observed_endpoint_mapping_blocked")
	geometry.set_meta("survey_status", "stylized_reference_derived_production_inference_not_surveyed")
	add_child(geometry)

	var field := load("res://game/resources/materials/world/building_1/building_1_warm_ivory.tres") as Material
	var trim := load("res://game/resources/materials/world/building_1/building_1_light_trim.tres") as Material
	var rose := load("res://game/resources/materials/world/building_1/building_1_rose_base.tres") as Material
	var glass := load("res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres") as Material
	var door := load("res://game/resources/materials/world/building_1/building_1_blue_door.tres") as Material
	geometry.add_child(_box("WarmIvoryHostFieldMacroProof", Vector3(0.0, 5.0, 0.0), Vector3(PROOF_DIMENSIONS_M.x, PROOF_DIMENSIONS_M.y, 0.12), field))
	geometry.add_child(_build_wing(Vector3(-15.0, 6.8, 0.08), glass, trim))
	geometry.add_child(_build_central(Vector3(-10.4, 6.3, 0.08), glass, trim))
	geometry.add_child(_build_pavilion(Vector3(-3.2, 5.0, 0.08), glass, trim))
	geometry.add_child(_build_base(Vector3(4.7, 1.25, 0.08), glass, trim))
	geometry.add_child(_build_door(Vector3(8.5, 1.45, 0.08), door, trim))
	geometry.add_child(_build_band(Vector3(14.2, 5.1, 0.08), rose))


func _build_wing(position_m: Vector3, glass: Material, trim: Material) -> Node3D:
	var module := _module_root("B1-WING-W", position_m, Vector2(1.7, 1.7), Vector4(1.2, 1.3, 2.0, 2.1), "complete wing punched window: opaque glazing proxy, full raised frame, one vertical and one horizontal mullion")
	var opening := Vector2(1.45, 1.45)
	module.add_child(_box("OpaqueGlazingFace", Vector3.ZERO, Vector3(opening.x, opening.y, 0.06), glass))
	_add_outer_frame(module, "Frame", opening, 0.12, trim)
	module.add_child(_box("MullionVertical", Vector3(0.0, 0.0, 0.025), Vector3(0.09, opening.y, 0.09), trim))
	module.add_child(_box("MullionHorizontal", Vector3(0.0, 0.0, 0.025), Vector3(opening.x, 0.09, 0.09), trim))
	return module


func _build_central(position_m: Vector3, glass: Material, trim: Material) -> Node3D:
	var module := _module_root("B1-CENTRAL-W", position_m, Vector2(1.45, 4.6), Vector4(0.8, 3.0, 1.8, 5.5), "complete tall narrow central window: opaque glazing proxy, full raised frame and four-row multipane study")
	var opening := Vector2(1.2, 4.3)
	module.add_child(_box("OpaqueGlazingFace", Vector3.ZERO, Vector3(opening.x, opening.y, 0.06), glass))
	_add_outer_frame(module, "Frame", opening, 0.125, trim)
	module.add_child(_box("MullionVertical", Vector3(0.0, 0.0, 0.025), Vector3(0.075, opening.y, 0.09), trim))
	for index in 3:
		var y := -opening.y * 0.5 + float(index + 1) * opening.y / 4.0
		module.add_child(_box("MullionHorizontal%02d" % (index + 1), Vector3(0.0, y, 0.025), Vector3(opening.x, 0.075, 0.09), trim))
	return module


func _build_pavilion(position_m: Vector3, glass: Material, trim: Material) -> Node3D:
	var module := _module_root("B1-PAV-W", position_m, Vector2(5.4, 10.0), Vector4(4.0, 8.0, 7.0, 14.0), "complete pavilion group: opaque glazing proxy, full multipane frame and two shallow stepped pilaster strips")
	var opening := Vector2(4.6, 9.2)
	module.add_child(_box("OpaqueGlazingFace", Vector3.ZERO, Vector3(opening.x, opening.y, 0.06), glass))
	_add_outer_frame(module, "Frame", opening, 0.18, trim)
	module.add_child(_box("MullionVerticalLeft", Vector3(-opening.x / 6.0, 0.0, 0.025), Vector3(0.11, opening.y, 0.09), trim))
	module.add_child(_box("MullionVerticalRight", Vector3(opening.x / 6.0, 0.0, 0.025), Vector3(0.11, opening.y, 0.09), trim))
	for index in 4:
		var y := -opening.y * 0.5 + float(index + 1) * opening.y / 5.0
		module.add_child(_box("MullionHorizontal%02d" % (index + 1), Vector3(0.0, y, 0.025), Vector3(opening.x, 0.11, 0.09), trim))
	module.add_child(_box("PilasterLeft", Vector3(-2.57, 0.0, 0.035), Vector3(0.32, 9.75, 0.1), trim))
	module.add_child(_box("PilasterRight", Vector3(2.57, 0.0, 0.035), Vector3(0.32, 9.75, 0.1), trim))
	return module


func _build_base(position_m: Vector3, glass: Material, trim: Material) -> Node3D:
	var module := _module_root("B1-BASE-O", position_m, Vector2(1.25, 0.9), Vector4(0.6, 0.45, 1.4, 1.2), "complete small base opening or vent: opaque unresolved face, full raised frame and center divider")
	var opening := Vector2(1.05, 0.7)
	module.add_child(_box("OpaqueOpeningOrVentFace", Vector3.ZERO, Vector3(opening.x, opening.y, 0.06), glass))
	_add_outer_frame(module, "Frame", opening, 0.1, trim)
	module.add_child(_box("Divider", Vector3(0.0, 0.0, 0.025), Vector3(0.07, opening.y, 0.09), trim))
	return module


func _build_door(position_m: Vector3, door: Material, trim: Material) -> Node3D:
	var module := _module_root("B1-DOOR-BLUE", position_m, Vector2(1.35, 2.75), Vector4(0.9, 2.0, 1.7, 3.1), "complete opaque blue personnel or utility door leaf and full raised frame")
	var opening := Vector2(1.15, 2.55)
	module.add_child(_box("DoorLeaf", Vector3.ZERO, Vector3(opening.x, opening.y, 0.07), door))
	_add_outer_frame(module, "Frame", opening, 0.1, trim)
	return module


func _build_band(position_m: Vector3, rose: Material) -> Node3D:
	var module := _module_root("B1-BAND", position_m, Vector2(4.2, 0.38), Vector4(2.0, 0.2, 8.0, 0.5), "complete shallow observed base-band exemplar with explicit finished terminals; not a seamless wall tile")
	module.add_child(_box("BandCore", Vector3.ZERO, Vector3(3.8, 0.38, 0.08), rose))
	module.add_child(_box("TerminalLeft", Vector3(-2.0, 0.0, 0.02), Vector3(0.2, 0.46, 0.1), rose))
	module.add_child(_box("TerminalRight", Vector3(2.0, 0.0, 0.02), Vector3(0.2, 0.46, 0.1), rose))
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
	module.set_meta("host_field_contract", "receiver warm-ivory field owns every non-module pixel")
	module.set_meta("allowed_host_material_ids", [FIELD_ID])
	module.set_meta("nominal_bounds_m", nominal_bounds_m)
	module.set_meta("uncertainty_width_height_m", uncertainty_bounds_m)
	module.set_meta("scale_status", "reversible_unmeasured_stylized_reference_derived_production_inference")
	module.set_meta("placement_state", "none_standalone_only")
	module.set_meta("count_status", "unknown_not_encoded")
	module.set_meta("cadence_status", "unknown_not_encoded")
	module.set_meta("surveyed_dimensions", false)
	module.set_meta("surveyed_coordinates", false)
	module.set_meta("completed_elevation", false)
	module.set_meta("whole_building_acceptance", false)
	module.set_meta("description", description)
	return module


func _add_outer_frame(parent: Node3D, prefix: String, opening_m: Vector2, thickness_m: float, material: Material) -> void:
	parent.add_child(_box(prefix + "Top", Vector3(0.0, opening_m.y * 0.5 + thickness_m * 0.5, 0.025), Vector3(opening_m.x + thickness_m * 2.0, thickness_m, 0.09), material))
	parent.add_child(_box(prefix + "Bottom", Vector3(0.0, -opening_m.y * 0.5 - thickness_m * 0.5, 0.025), Vector3(opening_m.x + thickness_m * 2.0, thickness_m, 0.09), material))
	parent.add_child(_box(prefix + "Left", Vector3(-opening_m.x * 0.5 - thickness_m * 0.5, 0.0, 0.025), Vector3(thickness_m, opening_m.y, 0.09), material))
	parent.add_child(_box(prefix + "Right", Vector3(opening_m.x * 0.5 + thickness_m * 0.5, 0.0, 0.025), Vector3(thickness_m, opening_m.y, 0.09), material))


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
