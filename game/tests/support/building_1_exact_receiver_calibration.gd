extends RefCounted

const EXACT_FIELD := preload("res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres")
const STANDALONE_SCENE := preload("res://game/scenes/world/facades/building_1/building_1_standalone_prototype_set.tscn")
const FIELD_OVERLAY_OFFSET_M := 0.018


static func build(record: Dictionary, registry: Dictionary) -> Dictionary:
	if not _record_matches(record, registry):
		return {"ok": false, "message": "Exact Building 1 generated receiver record does not match the detached calibration target."}
	var field_scope := registry.get("exact_field_scope", {}) as Dictionary
	var ordered_runs := _int_array(field_scope.get("exact_ordered_runs", []) as Array)
	var expected_runs: Array[int] = []
	for run_index in range(21, 52):
		expected_runs.append(run_index)
	if ordered_runs != expected_runs:
		return {"ok": false, "message": "Building 1 exact field scope is not ordered outer runs 21..51."}
	var field_result := _build_exact_field(record, ordered_runs, field_scope)
	if not bool(field_result.get("ok", false)):
		return field_result
	var root := Node3D.new()
	root.name = "DetachedBuilding1ExactReceiverCalibration"
	root.set_meta("controlled_calibration", true)
	root.set_meta("runtime_attachment", false)
	root.set_meta("source_key", "r16681702")
	root.set_meta("receiver_key", "building:r16681702:wall")
	root.set_meta("exact_field_runs", ordered_runs)
	root.set_meta("fit_study_count", 2)
	root.set_meta("actual_world_placement_count", 0)
	root.set_meta("collision_nodes", 0)
	root.set_meta("navigation_nodes", 0)
	root.set_meta("spray_nodes", 0)
	root.add_child(field_result.node as MeshInstance3D)

	var resolved_fit_studies: Array[Dictionary] = []
	for study_value: Variant in registry.get("fit_studies", []):
		var result := _build_fit_study(record, study_value as Dictionary)
		if not bool(result.get("ok", false)):
			root.free()
			return result
		root.add_child(result.node as Node3D)
		resolved_fit_studies.append(result.resolved as Dictionary)
	root.set_meta("resolved_field_scope", field_result.scope)
	root.set_meta("resolved_fit_studies", resolved_fit_studies)
	return {
		"ok": true,
		"node": root,
		"resolved_field_scope": field_result.scope,
		"resolved_fit_studies": resolved_fit_studies,
	}


static func run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var offset := run_index * 12
	if run_index < 0 or offset + 11 >= values.size() or offset + 11 >= normals.size():
		return {}
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var top_end := Vector3(float(values[offset + 6]), float(values[offset + 7]), float(values[offset + 8]))
	var top_start := Vector3(float(values[offset + 9]), float(values[offset + 10]), float(values[offset + 11]))
	var horizontal := end - start
	horizontal.y = 0.0
	var tangent := horizontal.normalized()
	var normal := Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()
	return {
		"run_index": run_index,
		"start": start,
		"end": end,
		"top_end": top_end,
		"top_start": top_start,
		"length_m": horizontal.length(),
		"tangent": tangent,
		"normal": normal,
		"height_start_m": top_start.y - start.y,
		"height_end_m": top_end.y - end.y,
	}


static func chain_frame(record: Dictionary, runs: Array[int], chain_m: float) -> Dictionary:
	var accumulated := 0.0
	for run_index: int in runs:
		var frame := run_frame(record, run_index)
		if frame.is_empty():
			return {}
		var length_m := float(frame.length_m)
		if chain_m <= accumulated + length_m + 0.0001:
			var fraction := clampf((chain_m - accumulated) / length_m, 0.0, 1.0)
			var start := frame.start as Vector3
			var end := frame.end as Vector3
			var top_start := frame.top_start as Vector3
			var top_end := frame.top_end as Vector3
			return {
				"run_index": run_index,
				"run_fraction": fraction,
				"wall_anchor": start.lerp(end, fraction),
				"base_y": lerpf(start.y, end.y, fraction),
				"top_y": lerpf(top_start.y, top_end.y, fraction),
				"tangent": frame.tangent,
				"normal": frame.normal,
				"chain_m": chain_m,
			}
		accumulated += length_m
	return {}


static func boundary_frame(record: Dictionary, before_run: int, after_run: int) -> Dictionary:
	var before := run_frame(record, before_run)
	var after := run_frame(record, after_run)
	if before.is_empty() or after.is_empty():
		return {}
	var before_end := before.end as Vector3
	var after_start := after.start as Vector3
	var normal := ((before.normal as Vector3) + (after.normal as Vector3)).normalized()
	return {
		"before_run": before_run,
		"after_run": after_run,
		"junction": (before_end + after_start) * 0.5,
		"endpoint_delta_m": before_end.distance_to(after_start),
		"normal": normal,
	}


static func _record_matches(record: Dictionary, registry: Dictionary) -> bool:
	var target := registry.get("target", {}) as Dictionary
	return str(record.get("object_key", "")) == str(target.get("receiver_key", "")) \
		and record.get("source_keys", []) == [str(target.get("source_key", ""))] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("material_key", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and int(record.get("exterior_foundation_segments", -1)) == int(target.get("run_count", -1)) \
		and int(record.get("shared_wall_segments", -1)) == 0 \
		and (record.get("vertices", []) as Array).size() == int(target.get("run_count", -1)) * 12 \
		and (record.get("indices", []) as Array).size() == int(target.get("run_count", -1)) * 6


static func _build_exact_field(record: Dictionary, ordered_runs: Array[int], field_scope: Dictionary) -> Dictionary:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var run_records: Array[Dictionary] = []
	var frames: Array[Dictionary] = []
	for run_index: int in ordered_runs:
		var resolved_frame := run_frame(record, run_index)
		if resolved_frame.is_empty():
			return {"ok": false, "message": "Exact field run %d could not resolve." % run_index}
		frames.append(resolved_frame)
	var junction_result := _mitered_chain_junctions(frames)
	if not bool(junction_result.get("ok", false)):
		return junction_result
	var bottom_junctions := junction_result.bottom_junctions as Array[Vector3]
	var top_junctions := junction_result.top_junctions as Array[Vector3]
	var accumulated_m := 0.0
	var surface_area_m2 := 0.0
	var maximum_endpoint_delta_m := 0.0
	var maximum_phase_delta_m := 0.0
	var previous_end := Vector3.ZERO
	var previous_phase_end := 0.0
	var has_previous := false
	for run_offset in ordered_runs.size():
		var run_index := ordered_runs[run_offset]
		var frame := frames[run_offset]
		var start := frame.start as Vector3
		var end := frame.end as Vector3
		var top_start := frame.top_start as Vector3
		var top_end := frame.top_end as Vector3
		var normal := frame.normal as Vector3
		var phase_start := accumulated_m
		var phase_end := accumulated_m + float(frame.length_m)
		var endpoint_delta := previous_end.distance_to(start) if has_previous else 0.0
		var phase_delta := absf(previous_phase_end - phase_start) if has_previous else 0.0
		maximum_endpoint_delta_m = maxf(maximum_endpoint_delta_m, endpoint_delta)
		maximum_phase_delta_m = maxf(maximum_phase_delta_m, phase_delta)
		var base_vertex := vertices.size()
		var corners := [bottom_junctions[run_offset], bottom_junctions[run_offset + 1], top_junctions[run_offset + 1], top_junctions[run_offset]]
		var chain_u := [phase_start, phase_end, phase_end, phase_start]
		for corner_index in 4:
			var point := corners[corner_index] as Vector3
			vertices.append(point)
			normals.append(normal)
			uvs.append(Vector2(float(chain_u[corner_index]), point.y))
		indices.append_array(PackedInt32Array([base_vertex, base_vertex + 2, base_vertex + 1, base_vertex, base_vertex + 3, base_vertex + 2]))
		var run_area := _triangle_area(start, top_end, end) + _triangle_area(start, top_start, top_end)
		surface_area_m2 += run_area
		run_records.append({
			"run_index": run_index,
			"length_m": float(frame.length_m),
			"surface_area_m2": run_area,
			"start_world_m": _vector3_array(start),
			"end_world_m": _vector3_array(end),
			"top_start_world_m": _vector3_array(top_start),
			"top_end_world_m": _vector3_array(top_end),
			"tangent_world_xz": [(frame.tangent as Vector3).x, (frame.tangent as Vector3).z],
			"outward_normal_world_xz": [normal.x, normal.z],
			"chain_phase_start_m": phase_start,
			"chain_phase_end_m": phase_end,
			"previous_endpoint_delta_m": endpoint_delta,
			"previous_join_phase_delta_m": phase_delta,
		})
		accumulated_m = phase_end
		previous_end = end
		previous_phase_end = phase_end
		has_previous = true
	# The registry is computed from the JSON decimal source in double precision;
	# Godot's Vector3 rebuild is float32.  These bounds are well below one
	# millimetre and reject any meaningful receiver drift while acknowledging
	# that deterministic representation difference.
	if absf(accumulated_m - float(field_scope.get("physical_wall_length_m", -1.0))) > 0.0001 \
	or absf(surface_area_m2 - float(field_scope.get("generated_mesh_surface_area_m2", -1.0))) > 0.001:
		return {"ok": false, "message": "Exact field length or mesh area drifted from the generated registry (resolved %.9f m / %.9f m2)." % [accumulated_m, surface_area_m2]}
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_name(0, "detached_exact_building_1_ivory_runs_21_51")
	mesh.surface_set_material(0, EXACT_FIELD)
	var field := MeshInstance3D.new()
	field.name = "DetachedExactPublicCurveFieldRuns21To51"
	field.mesh = mesh
	field.material_override = EXACT_FIELD
	field.set_meta("asset_id", "B1-MAT-IVORY")
	field.set_meta("asset_kind", "homogeneous_material_tile")
	field.set_meta("exact_ordered_runs", ordered_runs)
	field.set_meta("physical_length_m", accumulated_m)
	field.set_meta("surface_area_m2", surface_area_m2)
	field.set_meta("uv_contract", "UV.x cumulative ordered horizontal chain metres from run 21 start; UV.y source world Y metres")
	field.set_meta("runtime_attachment", false)
	field.set_meta("field_overlay_offset_m", FIELD_OVERLAY_OFFSET_M)
	field.set_meta("join_geometry", "shared_xz_mitered_offset_junctions")
	field.set_meta("maximum_rendered_join_gap_after_m", float(junction_result.maximum_rendered_gap_after_m))
	return {
		"ok": true,
		"node": field,
		"scope": {
			"exact_ordered_runs": ordered_runs,
			"physical_length_m": accumulated_m,
			"surface_area_m2": surface_area_m2,
			"run_records": run_records,
			"internal_join_count": ordered_runs.size() - 1,
			"maximum_endpoint_delta_m": maximum_endpoint_delta_m,
			"maximum_join_phase_delta_m": maximum_phase_delta_m,
			"overlay_join_miter_correction": junction_result.metrics,
			"overlay_join_records": junction_result.join_records,
			"vertices": vertices.size(),
			"indices": indices.size(),
			"triangles": indices.size() / 3,
			"surfaces": 1,
			"overlay_offset_m": FIELD_OVERLAY_OFFSET_M,
		},
	}


static func _mitered_chain_junctions(frames: Array[Dictionary]) -> Dictionary:
	if frames.is_empty():
		return {"ok": false, "message": "Cannot miter an empty Building 1 field chain."}
	var bottom_junctions: Array[Vector3] = []
	var top_junctions: Array[Vector3] = []
	var join_records: Array[Dictionary] = []
	var first := frames[0]
	var first_normal := first.normal as Vector3
	bottom_junctions.append((first.start as Vector3) + first_normal * FIELD_OVERLAY_OFFSET_M)
	top_junctions.append((first.top_start as Vector3) + first_normal * FIELD_OVERLAY_OFFSET_M)
	var maximum_before_gap := 0.0
	var maximum_after_gap := 0.0
	var maximum_clearance_residual := 0.0
	var maximum_miter_length := FIELD_OVERLAY_OFFSET_M
	var minimum_denominator := 1.0
	var maximum_miter_join := ""
	for offset in range(frames.size() - 1):
		var before := frames[offset]
		var after := frames[offset + 1]
		var before_normal := before.normal as Vector3
		var after_normal := after.normal as Vector3
		var source_bottom := ((before.end as Vector3) + (after.start as Vector3)) * 0.5
		var source_top := ((before.top_end as Vector3) + (after.top_start as Vector3)) * 0.5
		var bottom_miter := _shared_offset_miter(source_bottom, before_normal, after_normal)
		var top_miter := _shared_offset_miter(source_top, before_normal, after_normal)
		if not bool(bottom_miter.get("ok", false)) or not bool(top_miter.get("ok", false)):
			return {"ok": false, "message": "Building 1 offset miter is unstable at run join %d→%d." % [int(before.run_index), int(after.run_index)]}
		var shared_bottom := bottom_miter.point as Vector3
		var shared_top := top_miter.point as Vector3
		bottom_junctions.append(shared_bottom)
		top_junctions.append(shared_top)
		var independent_before_end := source_bottom + before_normal * FIELD_OVERLAY_OFFSET_M
		var independent_after_start := source_bottom + after_normal * FIELD_OVERLAY_OFFSET_M
		var before_gap := independent_before_end.distance_to(independent_after_start)
		var after_bottom_gap := shared_bottom.distance_to(shared_bottom)
		var after_top_gap := shared_top.distance_to(shared_top)
		var before_clearance_residual := absf((shared_bottom - source_bottom).dot(before_normal) - FIELD_OVERLAY_OFFSET_M)
		var after_clearance_residual := absf((shared_bottom - source_bottom).dot(after_normal) - FIELD_OVERLAY_OFFSET_M)
		var clearance_residual := maxf(before_clearance_residual, after_clearance_residual)
		var miter_length := float(bottom_miter.miter_length_m)
		var denominator := float(bottom_miter.denominator)
		maximum_before_gap = maxf(maximum_before_gap, before_gap)
		maximum_after_gap = maxf(maximum_after_gap, maxf(after_bottom_gap, after_top_gap))
		maximum_clearance_residual = maxf(maximum_clearance_residual, clearance_residual)
		minimum_denominator = minf(minimum_denominator, denominator)
		if miter_length > maximum_miter_length:
			maximum_miter_length = miter_length
			maximum_miter_join = "%d→%d" % [int(before.run_index), int(after.run_index)]
		join_records.append({
			"before_run": int(before.run_index),
			"after_run": int(after.run_index),
			"source_endpoint_delta_m": (before.end as Vector3).distance_to(after.start as Vector3),
			"independently_offset_gap_before_m": before_gap,
			"shared_miter_bottom_gap_after_m": after_bottom_gap,
			"shared_miter_top_gap_after_m": after_top_gap,
			"shared_miter_world_xz": [shared_bottom.x, shared_bottom.z],
			"miter_length_m": miter_length,
			"miter_ratio": miter_length / FIELD_OVERLAY_OFFSET_M,
			"miter_denominator": denominator,
			"turn_angle_degrees": rad_to_deg(acos(clampf(before_normal.dot(after_normal), -1.0, 1.0))),
			"maximum_perpendicular_clearance_residual_m": clearance_residual,
		})
	var last := frames[-1]
	var last_normal := last.normal as Vector3
	bottom_junctions.append((last.end as Vector3) + last_normal * FIELD_OVERLAY_OFFSET_M)
	top_junctions.append((last.top_end as Vector3) + last_normal * FIELD_OVERLAY_OFFSET_M)
	return {
		"ok": true,
		"bottom_junctions": bottom_junctions,
		"top_junctions": top_junctions,
		"join_records": join_records,
		"maximum_rendered_gap_after_m": maximum_after_gap,
		"metrics": {
			"correction_kind": "shared_xz_mitered_offset_junctions",
			"offset_depth_m": FIELD_OVERLAY_OFFSET_M,
			"join_count": join_records.size(),
			"maximum_independently_offset_gap_before_m": maximum_before_gap,
			"maximum_shared_miter_gap_after_m": maximum_after_gap,
			"maximum_perpendicular_clearance_residual_m": maximum_clearance_residual,
			"maximum_miter_length_m": maximum_miter_length,
			"maximum_miter_ratio": maximum_miter_length / FIELD_OVERLAY_OFFSET_M,
			"maximum_miter_join": maximum_miter_join,
			"minimum_miter_denominator": minimum_denominator,
		},
	}


static func _shared_offset_miter(source: Vector3, before_normal: Vector3, after_normal: Vector3) -> Dictionary:
	var bisector := before_normal + after_normal
	if bisector.length_squared() < 0.000001:
		return {"ok": false}
	bisector = bisector.normalized()
	var denominator := bisector.dot(before_normal)
	if denominator <= 0.0001:
		return {"ok": false}
	var miter_length := FIELD_OVERLAY_OFFSET_M / denominator
	return {
		"ok": true,
		"point": source + bisector * miter_length,
		"denominator": denominator,
		"miter_length_m": miter_length,
	}


static func _build_fit_study(record: Dictionary, study: Dictionary) -> Dictionary:
	var motif_id := str(study.get("motif_id", ""))
	if motif_id not in ["B1-CENTRAL-W", "B1-PAV-W"]:
		return {"ok": false, "message": "Detached Building 1 fit study requested a blocked motif."}
	var run_index := int(study.get("representative_run", -1))
	var frame := run_frame(record, run_index)
	var along_run_center_m := float(study.get("along_run_center_m", -1.0))
	var horizontal_domain := study.get("mechanically_eligible_center_domain_m", []) as Array
	var vertical_domain := study.get("mechanically_eligible_center_height_domain_m", []) as Array
	var center_height := float(study.get("center_height_above_base_m", -1.0))
	if frame.is_empty() or horizontal_domain.size() != 2 or vertical_domain.size() != 2 \
	or along_run_center_m < float(horizontal_domain[0]) or along_run_center_m > float(horizontal_domain[1]) \
	or center_height < float(vertical_domain[0]) or center_height > float(vertical_domain[1]):
		return {"ok": false, "message": "%s escaped its full uncertainty containment domain." % str(study.get("fit_study_id", motif_id))}
	var fraction := along_run_center_m / float(frame.length_m)
	var start := frame.start as Vector3
	var end := frame.end as Vector3
	var top_start := frame.top_start as Vector3
	var top_end := frame.top_end as Vector3
	var wall_anchor := start.lerp(end, fraction)
	var base_y := lerpf(start.y, end.y, fraction)
	var top_y := lerpf(top_start.y, top_end.y, fraction)
	var module := _accepted_standalone_module(motif_id)
	if module == null:
		return {"ok": false, "message": "Accepted standalone %s could not instantiate byte-for-byte." % motif_id}
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	var origin := wall_anchor + normal * float(study.get("wall_offset_m", 0.06))
	origin.y = base_y + center_height
	module.name = str(study.get("fit_study_id", motif_id)).replace("-", "_")
	module.transform = Transform3D(Basis(tangent, Vector3.UP, normal), origin)
	module.set_meta("fit_study_id", str(study.get("fit_study_id", "")))
	module.set_meta("study_kind", str(study.get("study_kind", "")))
	module.set_meta("representative_run", run_index)
	module.set_meta("exact_ordered_runs", [run_index])
	module.set_meta("along_run_center_m", along_run_center_m)
	module.set_meta("along_run_center_bounds_m", horizontal_domain)
	module.set_meta("side", str(study.get("side", "")))
	module.set_meta("region", str(study.get("region", "")))
	module.set_meta("evidence_status", str(study.get("evidence_status", "")))
	module.set_meta("real_placement_authorized", false)
	module.set_meta("runtime_attachment", false)
	var resolved := {
		"fit_study_id": str(study.get("fit_study_id", "")),
		"motif_id": motif_id,
		"study_kind": str(study.get("study_kind", "")),
		"representative_run": run_index,
		"exact_ordered_runs": [run_index],
		"along_run_center_m": along_run_center_m,
		"along_run_fraction": fraction,
		"mechanically_eligible_center_domain_m": horizontal_domain,
		"center_uncertainty_half_span_m": float(study.get("center_uncertainty_half_span_m", -1.0)),
		"wall_anchor_world_m": _vector3_array(wall_anchor),
		"module_origin_world_m": _vector3_array(origin),
		"tangent_world_xz": [tangent.x, tangent.z],
		"outward_normal_world_xz": [normal.x, normal.z],
		"base_y_m": base_y,
		"top_y_m": top_y,
		"center_height_above_base_m": center_height,
		"side": str(study.get("side", "")),
		"region": str(study.get("region", "")),
		"evidence_status": str(study.get("evidence_status", "")),
		"real_placement_authorized": false,
		"runtime_attachment": false,
	}
	return {"ok": true, "node": module, "resolved": resolved}


static func _accepted_standalone_module(motif_id: String) -> Node3D:
	var source := STANDALONE_SCENE.instantiate() as Node3D
	if source.get_node_or_null("PrototypeGeometry") == null:
		source.call("_build")
	var module := source.get_node_or_null("PrototypeGeometry/%s" % motif_id.replace("-", "_")) as Node3D
	if module == null:
		source.free()
		return null
	module.get_parent().remove_child(module)
	source.free()
	return module


static func _triangle_area(a: Vector3, b: Vector3, c: Vector3) -> float:
	return (b - a).cross(c - a).length() * 0.5


static func _vector3_array(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result
