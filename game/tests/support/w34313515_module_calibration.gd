extends RefCounted

const FRAME := preload("res://game/resources/materials/world/w34313515/w34313515_frame.tres")
const GLASS := preload("res://game/resources/materials/world/w34313515/w34313515_glass.tres")
const WALL_OFFSET_M := 0.06


static func build(record: Dictionary, registry: Dictionary) -> Dictionary:
	if not _record_matches(record, registry):
		return {"ok": false, "message": "Exact w34313515 receiver record does not match the detached calibration contract."}
	var contract := registry.get("module_contract", {}) as Dictionary
	if str(contract.get("motif_id", "")) != "W34313515-BAY":
		return {"ok": false, "message": "The accepted complete BAY module contract is missing."}
	var root := Node3D.new()
	root.name = "DetachedW34313515BayCalibration"
	root.set_meta("controlled_calibration", true)
	root.set_meta("runtime_attachment", false)
	root.set_meta("source_key", "w34313515")
	root.set_meta("receiver_key", "building:w34313515:wall")
	root.set_meta("asset_classification", "module_atlas")
	root.set_meta("module_owns_field_geometry", false)
	root.set_meta("collision_nodes", 0)
	root.set_meta("navigation_nodes", 0)
	root.set_meta("spray_nodes", 0)
	var resolved: Array[Dictionary] = []
	for placement_value: Variant in registry.get("placements", []):
		var placement := placement_value as Dictionary
		var ordered_runs := _int_array(placement.get("exact_ordered_runs", []) as Array)
		var center_chain_m := float(placement.get("center_chain_m", -1.0))
		var frame := chain_frame(record, ordered_runs, center_chain_m)
		if frame.is_empty():
			root.free()
			return {"ok": false, "message": "Could not resolve chain anchor for %s." % str(placement.get("placement_id", ""))}
		var nominal_bounds := contract.get("nominal_bounds_m", []) as Array
		var ownership := _runs_for_span(record, ordered_runs, center_chain_m, float(nominal_bounds[0]))
		if ownership != _int_array(placement.get("run_ownership", []) as Array) \
		or int(frame.get("run_index", -1)) != int(placement.get("anchor_run", -1)):
			root.free()
			return {"ok": false, "message": "Run ownership drifted for %s." % str(placement.get("placement_id", ""))}
		var module := _build_bay(contract)
		module.name = str(placement.get("placement_id", "")).replace("-", "_")
		var tangent := frame.tangent as Vector3
		var normal := frame.normal as Vector3
		var wall_anchor := frame.wall_anchor as Vector3
		var origin := wall_anchor + normal * WALL_OFFSET_M
		origin.y = float(frame.base_y) + float(contract.get("center_height_above_base_assumption_m", 5.35))
		module.transform = Transform3D(Basis(tangent, Vector3.UP, normal), origin)
		module.set_meta("placement_id", str(placement.placement_id))
		module.set_meta("motif_id", "W34313515-BAY")
		module.set_meta("face", str(placement.face))
		module.set_meta("region", str(placement.region))
		module.set_meta("host_material_id", str(placement.host_material_id))
		module.set_meta("mapping_id", str(placement.mapping_id))
		module.set_meta("evidence_status", str(placement.evidence_status))
		module.set_meta("coordinate_status", str(placement.coordinate_status))
		module.set_meta("count_status", str(placement.count_status))
		module.set_meta("cadence_status", str(placement.cadence_status))
		module.set_meta("run_ownership", ownership)
		module.set_meta("complete_motif", true)
		module.set_meta("module_not_seamless_tile", true)
		module.set_meta("module_owns_field_geometry", false)
		module.set_meta("host_field_contract", "continuous_receiver_field_owns_all_nonopening_pixels")
		module.set_meta("runtime_attachment", false)
		root.add_child(module)
		resolved.append({
			"placement_id": str(placement.placement_id),
			"motif_id": "W34313515-BAY",
			"face": str(placement.face),
			"region": str(placement.region),
			"host_material_id": str(placement.host_material_id),
			"mapping_id": str(placement.mapping_id),
			"evidence_status": str(placement.evidence_status),
			"coordinate_status": str(placement.coordinate_status),
			"count_status": str(placement.count_status),
			"cadence_status": str(placement.cadence_status),
			"run_ownership": ownership,
			"anchor_run": int(frame.run_index),
			"anchor_run_fraction": float(frame.run_fraction),
			"center_chain_m": center_chain_m,
			"center_chain_uncertainty_m": float(placement.center_chain_uncertainty_m),
			"wall_anchor_world_m": [wall_anchor.x, wall_anchor.y, wall_anchor.z],
			"module_origin_world_m": [origin.x, origin.y, origin.z],
			"tangent_world_xz": [tangent.x, tangent.z],
			"outward_normal_world_xz": [normal.x, normal.z],
			"base_y_m": float(frame.base_y),
			"top_y_m": float(frame.top_y),
		})
	root.set_meta("resolved_placements", resolved)
	return {"ok": true, "node": root, "resolved_placements": resolved}


static func chain_frame(record: Dictionary, runs: Array[int], chain_m: float) -> Dictionary:
	if runs.is_empty() or chain_m < 0.0:
		return {}
	var accumulated := 0.0
	for run_index: int in runs:
		var frame := _run_frame(record, run_index)
		if frame.is_empty():
			return {}
		var length_m := float(frame.length_m)
		if chain_m <= accumulated + length_m + 0.0001:
			var fraction := clampf((chain_m - accumulated) / length_m, 0.0, 1.0)
			var start := frame.start as Vector3
			var end := frame.end as Vector3
			var top_start := frame.top_start as Vector3
			var top_end := frame.top_end as Vector3
			var wall_anchor := start.lerp(end, fraction)
			return {
				"run_index": run_index,
				"run_fraction": fraction,
				"wall_anchor": wall_anchor,
				"base_y": lerpf(start.y, end.y, fraction),
				"top_y": lerpf(top_start.y, top_end.y, fraction),
				"tangent": frame.tangent,
				"normal": frame.normal,
				"chain_m": chain_m,
			}
		accumulated += length_m
	return {}


static func boundary_frame(record: Dictionary, before_run: int, after_run: int) -> Dictionary:
	var before := _run_frame(record, before_run)
	var after := _run_frame(record, after_run)
	if before.is_empty() or after.is_empty():
		return {}
	var junction := ((before.end as Vector3) + (after.start as Vector3)) * 0.5
	var outward := ((before.normal as Vector3) + (after.normal as Vector3)).normalized()
	if outward.length_squared() < 0.25:
		outward = before.normal as Vector3
	return {"junction": junction, "outward": outward, "before": before, "after": after}


static func _record_matches(record: Dictionary, registry: Dictionary) -> bool:
	var target := registry.get("target", {}) as Dictionary
	return str(record.get("object_key", "")) == str(target.get("receiver_key", "")) \
		and record.get("source_keys", []) == [str(target.get("source_key", ""))] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and int(record.get("exterior_foundation_segments", -1)) == int(target.get("run_count", -1)) \
		and int(record.get("shared_wall_segments", -1)) == 0 \
		and (record.get("vertices", []) as Array).size() == int(target.get("run_count", -1)) * 12 \
		and (record.get("indices", []) as Array).size() == int(target.get("run_count", -1)) * 6


static func _run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var offset := run_index * 12
	if run_index < 0 or offset + 11 >= values.size() or offset + 2 >= normals.size():
		return {}
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var top_end := Vector3(float(values[offset + 6]), float(values[offset + 7]), float(values[offset + 8]))
	var top_start := Vector3(float(values[offset + 9]), float(values[offset + 10]), float(values[offset + 11]))
	var horizontal := end - start
	horizontal.y = 0.0
	var tangent := horizontal.normalized()
	var normal := Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()
	return {"start": start, "end": end, "top_end": top_end, "top_start": top_start, "length_m": horizontal.length(), "tangent": tangent, "normal": normal}


static func _runs_for_span(record: Dictionary, runs: Array[int], center_m: float, width_m: float) -> Array[int]:
	var lower := center_m - width_m * 0.5
	var upper := center_m + width_m * 0.5
	var accumulated := 0.0
	var result: Array[int] = []
	for run_index: int in runs:
		var frame := _run_frame(record, run_index)
		var end_m := accumulated + float(frame.get("length_m", 0.0))
		if upper > accumulated + 0.0001 and lower < end_m - 0.0001:
			result.append(run_index)
		accumulated = end_m
	return result


static func _build_bay(contract: Dictionary) -> Node3D:
	var module := Node3D.new()
	var opening_values := contract.opening_per_tier_m as Array
	var opening := Vector2(float(opening_values[0]), float(opening_values[1]))
	var thickness := float(contract.frame_thickness_m)
	var tier_offsets := contract.tier_offsets_from_center_m as Array
	for tier_index in int(contract.tier_count):
		var center := Vector3(0.0, float(tier_offsets[tier_index]), 0.025)
		var prefix := "CompleteTier%02d" % (tier_index + 1)
		module.add_child(_box(prefix + "Glass", center, Vector3(opening.x, opening.y, 0.05), GLASS))
		_add_frame_bars(module, prefix + "Frame", Vector3(center.x, center.y, 0.06), opening, thickness)
		for column in range(1, int(contract.pane_count_per_tier)):
			var x := -opening.x * 0.5 + opening.x * float(column) / float(contract.pane_count_per_tier)
			module.add_child(_box(prefix + "Mullion%02d" % column, Vector3(x, center.y, 0.065), Vector3(0.085, opening.y, 0.07), FRAME))
	return module


static func _add_frame_bars(parent: Node3D, prefix: String, center: Vector3, opening: Vector2, thickness: float) -> void:
	parent.add_child(_box(prefix + "Top", center + Vector3(0.0, opening.y * 0.5, 0.0), Vector3(opening.x + thickness, thickness, 0.08), FRAME))
	parent.add_child(_box(prefix + "Bottom", center + Vector3(0.0, -opening.y * 0.5, 0.0), Vector3(opening.x + thickness, thickness, 0.08), FRAME))
	parent.add_child(_box(prefix + "Left", center + Vector3(-opening.x * 0.5, 0.0, 0.0), Vector3(thickness, opening.y, 0.08), FRAME))
	parent.add_child(_box(prefix + "Right", center + Vector3(opening.x * 0.5, 0.0, 0.0), Vector3(thickness, opening.y, 0.08), FRAME))


static func _box(node_name: String, position_m: Vector3, size_m: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size_m
	instance.mesh = mesh
	instance.position = position_m
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return instance


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result
