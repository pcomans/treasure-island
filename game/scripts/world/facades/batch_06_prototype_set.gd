@tool
extends Node3D

@export_enum("w34313515", "w34313564", "w291196370") var target_key: String = "w34313515"


func _ready() -> void:
	if get_node_or_null("PrototypeGeometry") == null:
		_build()


func _build() -> void:
	var geometry := Node3D.new()
	geometry.name = "PrototypeGeometry"
	geometry.set_meta("prototype_only", true)
	geometry.set_meta("runtime_attachment", false)
	geometry.set_meta("one_local_unit_m", 1.0)
	add_child(geometry)
	match target_key:
		"w34313515":
			_build_w34313515(geometry)
		"w34313564":
			_build_w34313564(geometry)
		"w291196370":
			_build_w291196370(geometry)
		_:
			push_error("Unsupported Batch 06 prototype target: %s" % target_key)


func _build_w34313515(root: Node3D) -> void:
	var field := load("res://game/resources/materials/world/w34313515/w34313515_pale_field.tres") as Material
	var frame := load("res://game/resources/materials/world/w34313515/w34313515_frame.tres") as Material
	var glass := load("res://game/resources/materials/world/w34313515/w34313515_glass.tres") as Material
	root.set_meta("proof_dimensions_m", Vector2(10.0, 11.0))
	root.set_meta("field_scale_assumption_m", 1.1)
	root.set_meta("field_scale_uncertainty_m", Vector2(0.55, 1.8))
	root.add_child(_box("PaleFieldProof", Vector3(0.0, 5.5, 0.0), Vector3(10.0, 11.0, 0.12), field))
	var bay := _module("W34313515_BAY", "W34313515-BAY", Vector2(6.2, 10.2), ["B06-34313515-WSW-OUTER:runs_0_8", "B06-34313515-NNW-OUTER:runs_43_47"], ["W34313515-MAT-PALE"], "Complete three-tier horizontal-window group with full frame and mullions over the continuous host field; dimensions are reversible proof assumptions.")
	bay.position = Vector3(0.0, 5.35, 0.11)
	for tier in 3:
		_add_framed_window(bay, "Tier%d" % (tier + 1), Vector3(0.0, -3.15 + tier * 3.15, 0.13), Vector2(5.1, 1.72), frame, glass, 3)
	root.add_child(bay)


func _build_w34313564(root: Node3D) -> void:
	var tan_field := load("res://game/resources/materials/world/w34313564/w34313564_tan_field.tres") as Material
	var pale_field := load("res://game/resources/materials/world/w34313564/w34313564_pale_field.tres") as Material
	var plinth := load("res://game/resources/materials/world/w34313564/w34313564_plinth_field.tres") as Material
	var frame := load("res://game/resources/materials/world/w34313564/w34313564_frame.tres") as Material
	var glass := load("res://game/resources/materials/world/w34313564/w34313564_glass.tres") as Material
	var door_material := load("res://game/resources/materials/world/w34313564/w34313564_door.tres") as Material
	root.set_meta("proof_dimensions_m", Vector2(13.5, 5.0))
	root.set_meta("field_scale_assumption_m", 0.82)
	root.set_meta("field_scale_uncertainty_m", Vector2(0.38, 1.35))
	root.add_child(_box("SSETanFieldProof", Vector3(-2.25, 2.5, 0.0), Vector3(9.0, 5.0, 0.12), tan_field))
	root.add_child(_box("NNWENEPaleFieldProof", Vector3(4.5, 2.5, 0.0), Vector3(4.5, 5.0, 0.12), pale_field))
	root.add_child(_box("PalePlinthProof", Vector3(-2.25, 0.38, 0.08), Vector3(9.0, 0.76, 0.1), plinth))
	var window := _module("W34313564_HWIN", "W34313564-HWIN", Vector2(4.9, 1.9), ["B06-34313564-SSE-CENTRAL:runs_7_9", "B06-34313564-ENE-END:runs_10_13", "B06-34313564-NNW-OUTER:runs_14_19"], ["W34313564-MAT-TAN", "W34313564-MAT-PALE"], "Complete horizontal multi-pane window and full frame over whichever continuous tan or pale host field owns the placement; cadence remains unassigned.")
	window.position = Vector3(-2.6, 3.45, 0.13)
	_add_framed_window(window, "CompleteWindow", Vector3(0.0, 0.0, 0.13), Vector2(4.25, 1.2), frame, glass, 4)
	root.add_child(window)
	var door := _module("W34313564_PDOOR", "W34313564-PDOOR", Vector2(1.9, 3.0), ["B06-34313564-SSE-CENTRAL:runs_7_9", "B06-34313564-NNW-OUTER:runs_14_19"], ["W34313564-MAT-TAN", "W34313564-MAT-PALE"], "Complete plain personnel door and outer frame over whichever continuous tan or pale host field owns the placement; access geometry is excluded.")
	door.position = Vector3(4.45, 1.65, 0.13)
	_add_framed_door(door, "CompleteDoor", Vector3(0.0, -0.12, 0.13), Vector2(1.15, 2.25), frame, door_material)
	root.add_child(door)


func _build_w291196370(root: Node3D) -> void:
	var siding := load("res://game/resources/materials/world/w291196370/w291196370_siding_field.tres") as Material
	var trim := load("res://game/resources/materials/world/w291196370/w291196370_trim.tres") as Material
	var glass := load("res://game/resources/materials/world/w291196370/w291196370_glass.tres") as Material
	var entry_material := load("res://game/resources/materials/world/w291196370/w291196370_entry.tres") as Material
	var service_material := load("res://game/resources/materials/world/w291196370/w291196370_service.tres") as Material
	root.set_meta("proof_dimensions_m", Vector2(15.0, 6.0))
	root.set_meta("field_scale_assumption_m", 0.2)
	root.set_meta("field_scale_uncertainty_m", Vector2(0.12, 0.3))
	root.add_child(_box("GrayBlueSidingFieldProof", Vector3(0.0, 3.0, 0.0), Vector3(15.0, 6.0, 0.12), siding))
	var window := _module("W291196370_WINSTACK", "W291196370-WINSTACK", Vector2(2.0, 4.5), ["B06-291196370-SSE-PUBLIC:runs_8_10"], ["W291196370-SIDING"], "Complete narrow vertical window stack with white trim over one continuous host siding field; no divider cadence is assigned.")
	window.position = Vector3(-5.0, 3.15, 0.13)
	_add_framed_window(window, "CompleteWindowStack", Vector3(0.0, 0.0, 0.13), Vector2(1.12, 3.72), trim, glass, 1, 3)
	root.add_child(window)
	var entry := _module("W291196370_ENTRY", "W291196370-ENTRY", Vector2(2.1, 3.2), ["B06-291196370-SSE-PUBLIC:runs_8_10"], ["W291196370-SIDING"], "Complete dark personnel entry and immediate trim over one continuous host siding field; stairs, ramp and rails are excluded.")
	entry.position = Vector3(-0.7, 1.85, 0.13)
	_add_framed_door(entry, "CompleteEntry", Vector3(0.0, -0.1, 0.13), Vector2(1.22, 2.35), trim, entry_material)
	root.add_child(entry)
	var service := _module("W291196370_SERVICE", "W291196370-SERVICE", Vector2(4.5, 4.4), ["B06-291196370-ENE-OUTER:runs_17_22"], ["W291196370-SIDING"], "Complete pale service opening and full frame over one continuous host siding field; yard objects and adjacent partial openings are excluded.")
	service.position = Vector3(4.55, 2.5, 0.13)
	service.add_child(_box("CompleteServiceLeaf", Vector3(0.0, -0.12, 0.14), Vector3(3.55, 3.35, 0.1), service_material))
	_add_frame_bars(service, "ServiceFrame", Vector3(0.0, -0.12, 0.22), Vector2(3.65, 3.45), trim, 0.12)
	for seam in 7:
		service.add_child(_box("ServiceCourse%02d" % seam, Vector3(0.0, -1.42 + seam * 0.42, 0.25), Vector3(3.4, 0.035, 0.035), trim))
	root.add_child(service)


func _module(node_name: String, motif_id: String, nominal_bounds_m: Vector2, placement_bounds: Array[String], allowed_host_material_ids: Array[String], description: String) -> Node3D:
	var module := Node3D.new()
	module.name = node_name
	module.set_meta("motif_id", motif_id)
	module.set_meta("complete_motif", true)
	module.set_meta("module_not_seamless_tile", true)
	module.set_meta("opposite_edge_continuity_required", false)
	module.set_meta("module_owns_field_geometry", false)
	module.set_meta("host_field_contract", "continuous_receiver_field_owns_all_nonopening_pixels")
	module.set_meta("allowed_host_material_ids", allowed_host_material_ids)
	module.set_meta("nominal_bounds_m", nominal_bounds_m)
	module.set_meta("scale_status", "reversible_unmeasured_proof_assumption")
	module.set_meta("placement_bounds", placement_bounds)
	module.set_meta("description", description)
	return module


func _add_framed_window(parent: Node3D, prefix: String, position_m: Vector3, opening_m: Vector2, frame: Material, glass: Material, columns: int, rows: int = 1) -> void:
	parent.add_child(_box(prefix + "Glass", position_m, Vector3(opening_m.x, opening_m.y, 0.09), glass))
	_add_frame_bars(parent, prefix + "Frame", position_m + Vector3(0.0, 0.0, 0.07), opening_m, frame, 0.11)
	for column in range(1, columns):
		var x := -opening_m.x * 0.5 + opening_m.x * float(column) / float(columns)
		parent.add_child(_box(prefix + "MullionV%02d" % column, position_m + Vector3(x, 0.0, 0.09), Vector3(0.085, opening_m.y, 0.08), frame))
	for row in range(1, rows):
		var y := -opening_m.y * 0.5 + opening_m.y * float(row) / float(rows)
		parent.add_child(_box(prefix + "MullionH%02d" % row, position_m + Vector3(0.0, y, 0.09), Vector3(opening_m.x, 0.085, 0.08), frame))


func _add_framed_door(parent: Node3D, prefix: String, position_m: Vector3, opening_m: Vector2, frame: Material, leaf: Material) -> void:
	parent.add_child(_box(prefix + "Leaf", position_m, Vector3(opening_m.x, opening_m.y, 0.1), leaf))
	_add_frame_bars(parent, prefix + "Frame", position_m + Vector3(0.0, 0.0, 0.07), opening_m, frame, 0.1)


func _add_frame_bars(parent: Node3D, prefix: String, position_m: Vector3, opening_m: Vector2, material: Material, thickness_m: float) -> void:
	parent.add_child(_box(prefix + "Top", position_m + Vector3(0.0, opening_m.y * 0.5, 0.0), Vector3(opening_m.x + thickness_m, thickness_m, 0.09), material))
	parent.add_child(_box(prefix + "Bottom", position_m + Vector3(0.0, -opening_m.y * 0.5, 0.0), Vector3(opening_m.x + thickness_m, thickness_m, 0.09), material))
	parent.add_child(_box(prefix + "Left", position_m + Vector3(-opening_m.x * 0.5, 0.0, 0.0), Vector3(thickness_m, opening_m.y, 0.09), material))
	parent.add_child(_box(prefix + "Right", position_m + Vector3(opening_m.x * 0.5, 0.0, 0.0), Vector3(thickness_m, opening_m.y, 0.09), material))


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
