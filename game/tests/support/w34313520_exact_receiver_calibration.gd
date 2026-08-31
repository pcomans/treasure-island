extends RefCounted

const EXACT_FIELD := preload("res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres")
const STANDALONE_SCENE := preload("res://game/scenes/world/facades/batch_06/w34313520_standalone_prototype_set.tscn")
const FIELD_OVERLAY_OFFSET_M := 0.018
const BAY_WALL_OFFSET_M := 0.06


static func build(record: Dictionary, registry: Dictionary) -> Dictionary:
	if not _record_matches(record, registry):
		return {"ok": false, "message": "Exact w34313520 generated receiver record does not match the calibration target."}
	var field_scope := registry.get("exact_field_scope", {}) as Dictionary
	var ordered_runs := _int_array(field_scope.get("exact_ordered_runs", []) as Array)
	if ordered_runs != [6, 7, 8, 9, 10]:
		return {"ok": false, "message": "Exact pale field scope is not the accepted ordered SSE run chain 6..10."}
	var field_result := _build_exact_field(record, ordered_runs)
	if not bool(field_result.get("ok", false)):
		return field_result
	var root := Node3D.new()
	root.name = "DetachedW34313520ExactReceiverCalibration"
	root.set_meta("controlled_calibration", true)
	root.set_meta("runtime_attachment", false)
	root.set_meta("source_key", "w34313520")
	root.set_meta("receiver_key", "building:w34313520:wall")
	root.set_meta("exact_field_runs", ordered_runs)
	root.set_meta("bay_placement_count", 1)
	root.set_meta("collision_nodes", 0)
	root.set_meta("navigation_nodes", 0)
	root.set_meta("spray_nodes", 0)
	root.add_child(field_result.node as MeshInstance3D)

	var placement := registry.get("placement", {}) as Dictionary
	var run_index := int(placement.get("anchor_run", -1))
	var along_run_center_m := float(placement.get("along_run_center_m", -1.0))
	var frame := run_frame(record, run_index)
	if frame.is_empty() or along_run_center_m < 0.0 or along_run_center_m > float(frame.length_m):
		root.free()
		return {"ok": false, "message": "The single BAY anchor cannot resolve on its exact run."}
	var fraction := along_run_center_m / float(frame.length_m)
	var start := frame.start as Vector3
	var end := frame.end as Vector3
	var top_start := frame.top_start as Vector3
	var top_end := frame.top_end as Vector3
	var wall_anchor := start.lerp(end, fraction)
	var base_y := lerpf(start.y, end.y, fraction)
	var top_y := lerpf(top_start.y, top_end.y, fraction)
	var module_contract := registry.get("module_contract", {}) as Dictionary
	var center_height := float(module_contract.get("center_height_above_base_m", -1.0))
	var center_domain := module_contract.get("mechanically_eligible_center_height_domain_m", []) as Array
	var horizontal_domain := placement.get("mechanically_eligible_center_domain_m", []) as Array
	if horizontal_domain.size() != 2 or center_domain.size() != 2 \
	or along_run_center_m < float(horizontal_domain[0]) or along_run_center_m > float(horizontal_domain[1]) \
	or center_height < float(center_domain[0]) or center_height > float(center_domain[1]):
		root.free()
		return {"ok": false, "message": "The single BAY anchor escaped its full-width or full-height containment domain."}
	var bay := _accepted_standalone_bay()
	if bay == null:
		root.free()
		return {"ok": false, "message": "The accepted standalone BAY could not be instantiated byte-for-byte."}
	bay.name = str(placement.get("placement_id", "CAL-SSE-BAY-01")).replace("-", "_")
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	var origin := wall_anchor + normal * BAY_WALL_OFFSET_M
	origin.y = base_y + center_height
	bay.transform = Transform3D(Basis(tangent, Vector3.UP, normal), origin)
	bay.set_meta("placement_id", str(placement.get("placement_id", "")))
	bay.set_meta("exact_ordered_runs", [run_index])
	bay.set_meta("anchor_run", run_index)
	bay.set_meta("along_run_center_m", along_run_center_m)
	bay.set_meta("along_run_center_bounds_m", horizontal_domain)
	bay.set_meta("face", str(placement.get("face", "")))
	bay.set_meta("region", str(placement.get("region", "")))
	bay.set_meta("evidence_status", str(placement.get("evidence_status", "")))
	bay.set_meta("coordinate_status", str(placement.get("coordinate_status", "")))
	bay.set_meta("count_status", str(placement.get("count_status", "")))
	bay.set_meta("cadence_status", str(placement.get("cadence_status", "")))
	bay.set_meta("runtime_attachment", false)
	root.add_child(bay)
	var resolved_placement := {
		"placement_id": str(placement.get("placement_id", "")),
		"motif_id": "W34313520-BAY",
		"face": str(placement.get("face", "")),
		"region": str(placement.get("region", "")),
		"mapping_id": str(placement.get("mapping_id", "")),
		"exact_ordered_runs": [run_index],
		"anchor_run": run_index,
		"along_run_center_m": along_run_center_m,
		"anchor_run_fraction": fraction,
		"mechanically_eligible_center_domain_m": horizontal_domain,
		"center_uncertainty_half_span_m": float(placement.get("center_uncertainty_half_span_m", -1.0)),
		"wall_anchor_world_m": [wall_anchor.x, wall_anchor.y, wall_anchor.z],
		"module_origin_world_m": [origin.x, origin.y, origin.z],
		"tangent_world_xz": [tangent.x, tangent.z],
		"outward_normal_world_xz": [normal.x, normal.z],
		"base_y_m": base_y,
		"top_y_m": top_y,
		"center_height_above_base_m": center_height,
		"evidence_status": str(placement.get("evidence_status", "")),
		"coordinate_status": str(placement.get("coordinate_status", "")),
		"count_status": str(placement.get("count_status", "")),
		"cadence_status": str(placement.get("cadence_status", "")),
	}
	root.set_meta("resolved_field_scope", field_result.scope)
	root.set_meta("resolved_placement", resolved_placement)
	return {
		"ok": true,
		"node": root,
		"resolved_field_scope": field_result.scope,
		"resolved_placement": resolved_placement,
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


static func _build_exact_field(record: Dictionary, ordered_runs: Array[int]) -> Dictionary:
	var source_vertices := record.get("vertices", []) as Array
	var source_normals := record.get("normals", []) as Array
	var source_uvs := record.get("uvs", []) as Array
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var run_records: Array[Dictionary] = []
	var previous_end_phase := 0.0
	var has_previous := false
	var maximum_phase_delta := 0.0
	for run_index: int in ordered_runs:
		var frame := run_frame(record, run_index)
		if frame.is_empty():
			return {"ok": false, "message": "Exact field run %d could not resolve." % run_index}
		var base_vertex := vertices.size()
		var vertex_offset := run_index * 12
		var uv_offset := run_index * 8
		var normal := frame.normal as Vector3
		for corner in 4:
			var value_offset := vertex_offset + corner * 3
			var point := Vector3(float(source_vertices[value_offset]), float(source_vertices[value_offset + 1]), float(source_vertices[value_offset + 2]))
			vertices.append(point + normal * FIELD_OVERLAY_OFFSET_M)
			normals.append(Vector3(float(source_normals[value_offset]), float(source_normals[value_offset + 1]), float(source_normals[value_offset + 2])))
			var source_uv_offset := uv_offset + corner * 2
			uvs.append(Vector2(float(source_uvs[source_uv_offset]), float(source_uvs[source_uv_offset + 1])))
		indices.append_array(PackedInt32Array([base_vertex, base_vertex + 2, base_vertex + 1, base_vertex, base_vertex + 3, base_vertex + 2]))
		var start_phase := _phase_m(frame.start as Vector3, normal)
		var end_phase := _phase_m(frame.end as Vector3, normal)
		var junction_delta := absf(start_phase - previous_end_phase) if has_previous else 0.0
		maximum_phase_delta = maxf(maximum_phase_delta, junction_delta)
		run_records.append({
			"run_index": run_index,
			"length_m": float(frame.length_m),
			"height_start_m": float(frame.height_start_m),
			"height_end_m": float(frame.height_end_m),
			"start_world_m": _vector3_array(frame.start as Vector3),
			"end_world_m": _vector3_array(frame.end as Vector3),
			"top_start_world_m": _vector3_array(frame.top_start as Vector3),
			"top_end_world_m": _vector3_array(frame.top_end as Vector3),
			"tangent_world_xz": [(frame.tangent as Vector3).x, (frame.tangent as Vector3).z],
			"outward_normal_world_xz": [normal.x, normal.z],
			"field_phase_start_m": start_phase,
			"field_phase_end_m": end_phase,
			"previous_junction_phase_delta_m": junction_delta,
		})
		previous_end_phase = end_phase
		has_previous = true
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_name(0, "detached_exact_w34313520_pale_runs_6_10")
	mesh.surface_set_material(0, EXACT_FIELD)
	var field := MeshInstance3D.new()
	field.name = "DetachedExactSSEFieldRuns06To10"
	field.mesh = mesh
	field.material_override = EXACT_FIELD
	field.set_meta("asset_id", "W34313520-MAT-PALE")
	field.set_meta("asset_kind", "homogeneous_material_tile")
	field.set_meta("exact_ordered_runs", ordered_runs)
	field.set_meta("physical_length_m", 68.156)
	field.set_meta("meter_convention", "one Godot unit equals one metre; shader projects world vertex XZ onto wall tangent and uses world Y")
	field.set_meta("runtime_attachment", false)
	field.set_meta("field_overlay_offset_m", FIELD_OVERLAY_OFFSET_M)
	return {
		"ok": true,
		"node": field,
		"scope": {
			"exact_ordered_runs": ordered_runs,
			"physical_length_m": 68.156,
			"run_records": run_records,
			"maximum_junction_phase_delta_m": maximum_phase_delta,
			"vertices": vertices.size(),
			"indices": indices.size(),
			"triangles": indices.size() / 3,
			"surfaces": 1,
			"overlay_offset_m": FIELD_OVERLAY_OFFSET_M,
		},
	}


static func _accepted_standalone_bay() -> Node3D:
	var source := STANDALONE_SCENE.instantiate() as Node3D
	if source.get_node_or_null("PrototypeGeometry") == null:
		source.call("_build")
	var bay := source.get_node_or_null("PrototypeGeometry/W34313520_BAY") as Node3D
	if bay == null:
		source.free()
		return null
	bay.get_parent().remove_child(bay)
	source.free()
	return bay


static func _phase_m(point: Vector3, normal: Vector3) -> float:
	var tangent_2d := Vector2(normal.z, -normal.x).normalized()
	return Vector2(point.x, point.z).dot(tangent_2d)


static func _vector3_array(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result
