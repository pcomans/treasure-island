class_name Building1RecognizableFacade
extends RefCounted

const SOURCE_KEY := "r16681702"
const RECEIVER_KEY := "building:r16681702:wall"
const REGISTRY_PATH := "res://game/resources/facades/building_1_recognizability_placements.json"
const EXPECTED_REGISTRY_SHA256 := "affc41797999b83610352c5945c21d5206167a67bdc1aa5134a3021dd280df05"
const EXPECTED_STANDALONE_REGISTRY_SHA256 := "2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc"
const EXPECTED_STANDALONE_FACTORY_SHA256 := "cf18bfcfa40c7770d92aad569cba05da7ac85fe0fc89c0fd8cba6167ef62fb1f"
const EXPECTED_PLACEMENT_BRIEF_SHA256 := "f4f9d3d123ce923713b113d4c020e64d0d83356e2d8f3d8bc6dd3b1eac3c5be4"
const EXPECTED_FIELD_REVIEW_SHA256 := "35d8e0d306b381feee997c068824222e22ff4199c8ef5433bbe5ae082fa4c048"
const EXPECTED_FIELD_MATERIAL_SHA256 := "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a"
const EXPECTED_FIELD_SHADER_SHA256 := "a4a5df4fbb8fd4f13187ec284708879b540677ac2c827642b4c3040b4bce4c09"
const STANDALONE_REGISTRY_PATH := "res://game/resources/facades/building_1_standalone_prototypes.json"
const STANDALONE_FACTORY_PATH := "res://game/scripts/world/facades/building_1_standalone_prototypes.gd"
const PLACEMENT_BRIEF_PATH := "res://discovery/facades/TREASURE_ISLAND_BUILDING_1_RECOGNIZABILITY_PLACEMENT_BRIEF.md"
const FIELD_REVIEW_PATH := "res://discovery/facades/TREASURE_ISLAND_BUILDING_1_LIVE_IVORY_FIELD_ART_REVIEW.md"
const FIELD_MATERIAL_PATH := "res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres"
const FIELD_SHADER_PATH := "res://game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader"
const FIELD_OFFSET_M := 0.018
const RENDER_BUILDING_WALL := 1 << 1
const COMPOSITION_REVIEW_STATUS := "pending_independent_recognizability_art_review"

const RUN_GEOMETRY := preload("res://game/tests/support/building_1_exact_receiver_calibration.gd")
const STANDALONE_SCENE := preload("res://game/scenes/world/facades/building_1/building_1_standalone_prototype_set.tscn")
const FIELD_MATERIAL := preload("res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres")


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == RECEIVER_KEY \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))


static func build(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return _failure("building_1_recognizability_receiver", "Building 1 recognizability receiver identity drifted.", record)
	if not _source_hashes_match():
		return _failure("building_1_recognizability_sources", "A reviewed Building 1 source byte drifted.", record)
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not registry_value is Dictionary:
		return _failure("building_1_recognizability_registry", "Building 1 recognizability registry did not parse.", record)
	var registry := registry_value as Dictionary
	if not _registry_matches(registry):
		return _failure("building_1_recognizability_scope", "Building 1 recognizability registry escaped the authorized public scope.", record)

	var root := Node3D.new()
	root.name = "Building1RecognizableFacade"
	var resolved_fields: Array[Dictionary] = []
	for scope_value: Variant in (registry.get("field_composition", {}) as Dictionary).get("render_chains", []):
		var scope := scope_value as Dictionary
		var field_result := _build_field_chain(record, scope)
		if not bool(field_result.get("ok", false)):
			root.free()
			return field_result
		root.add_child(field_result.node as MeshInstance3D)
		resolved_fields.append((field_result.resolved as Dictionary).duplicate(true))

	var resolved_placements: Array[Dictionary] = []
	for placement_value: Variant in registry.get("placements", []):
		var placement := placement_value as Dictionary
		var placement_result := _build_module(record, placement)
		if not bool(placement_result.get("ok", false)):
			root.free()
			return placement_result
		root.add_child(placement_result.node as Node3D)
		resolved_placements.append((placement_result.resolved as Dictionary).duplicate(true))

	var topology := (registry.get("live_render_topology", {}) as Dictionary).duplicate(true)
	if _count_type(root, MeshInstance3D) != int(topology.get("total_meshes", -1)) \
	or _count_surfaces(root) != int(topology.get("total_surfaces", -1)) \
	or _count_triangles(root) != int(topology.get("total_triangles", -1)) \
	or _count_type(root, CollisionObject3D) != 0 \
	or _count_type(root, CollisionShape3D) != 0 \
	or _count_type(root, NavigationRegion3D) != 0 \
	or _count_type(root, Decal) != 0:
		root.free()
		return _failure("building_1_recognizability_topology", "Building 1 recognizability topology or zero-ownership contract drifted.", record)

	var metadata := {
		"source_key": SOURCE_KEY,
		"receiver_key": RECEIVER_KEY,
		"runtime_attachment": true,
		"role": "recognizable_reference_derived_production_inference",
		"composition_review_status": COMPOSITION_REVIEW_STATUS,
		"accepted_live_field_review_status": "independently_reviewed_keep_with_documented_limitation",
		"accepted_live_field_review_sha256": EXPECTED_FIELD_REVIEW_SHA256,
		"field_id": "B1-MAT-IVORY",
		"exact_field_runs": (registry.get("field_composition", {}) as Dictionary).get("exact_eligible_runs", []).duplicate(),
		"field_run_count": int((registry.get("field_composition", {}) as Dictionary).get("run_count", -1)),
		"field_physical_length_m": float((registry.get("field_composition", {}) as Dictionary).get("physical_length_m", -1.0)),
		"field_surface_area_m2": float((registry.get("field_composition", {}) as Dictionary).get("generated_mesh_surface_area_m2", -1.0)),
		"independently_accepted_prior_field_runs": (registry.get("field_composition", {}) as Dictionary).get("independently_accepted_prior_scope", {}).get("exact_ordered_runs", []).duplicate(),
		"module_placement_count": (registry.get("placements", []) as Array).size(),
		"motif_instance_counts": (registry.get("placement_summary", {}) as Dictionary).get("motif_instance_counts", {}).duplicate(true),
		"topology": topology,
		"resolved_field_scopes": resolved_fields,
		"resolved_placements": resolved_placements,
		"protected_runs": (registry.get("protected_scope", {}) as Dictionary).get("protected_runs", []).duplicate(),
		"registry_path": REGISTRY_PATH,
		"registry_sha256": EXPECTED_REGISTRY_SHA256,
		"surveyed_dimensions": false,
		"surveyed_scale": false,
		"surveyed_coordinates": false,
		"surveyed_count": false,
		"surveyed_cadence": false,
		"surveyed_sequence": false,
		"completed_elevation": false,
		"whole_building_accepted": false,
	}
	for key: String in metadata:
		root.set_meta(key, metadata[key])
	return {
		"ok": true,
		"node": root,
		"mesh_instances": int(topology.total_meshes),
		"surfaces": int(topology.total_surfaces),
		"triangles": int(topology.total_triangles),
		"metadata": metadata,
	}


static func _source_hashes_match() -> bool:
	# Export templates remap imported sources and omit authoring reviews; the
	# semantic registry/geometry contract remains the packaged gate.
	if not OS.has_feature("editor"):
		return true
	return FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256 \
		and FileAccess.get_sha256(STANDALONE_REGISTRY_PATH) == EXPECTED_STANDALONE_REGISTRY_SHA256 \
		and FileAccess.get_sha256(STANDALONE_FACTORY_PATH) == EXPECTED_STANDALONE_FACTORY_SHA256 \
		and FileAccess.get_sha256(PLACEMENT_BRIEF_PATH) == EXPECTED_PLACEMENT_BRIEF_SHA256 \
		and FileAccess.get_sha256(FIELD_REVIEW_PATH) == EXPECTED_FIELD_REVIEW_SHA256 \
		and FileAccess.get_sha256(FIELD_MATERIAL_PATH) == EXPECTED_FIELD_MATERIAL_SHA256 \
		and FileAccess.get_sha256(FIELD_SHADER_PATH) == EXPECTED_FIELD_SHADER_SHA256


static func _registry_matches(registry: Dictionary) -> bool:
	var target := registry.get("target", {}) as Dictionary
	var field := registry.get("field_composition", {}) as Dictionary
	var summary := registry.get("placement_summary", {}) as Dictionary
	var topology := registry.get("live_render_topology", {}) as Dictionary
	var truth := registry.get("truth_boundary", {}) as Dictionary
	var protected := _int_array((registry.get("protected_scope", {}) as Dictionary).get("protected_runs", []) as Array)
	return str(target.get("source_key", "")) == SOURCE_KEY \
		and str(target.get("receiver_key", "")) == RECEIVER_KEY \
		and int(target.get("generated_wall_run_count", -1)) == 110 \
		and _int_array(field.get("exact_eligible_runs", []) as Array) == _expected_field_runs() \
		and int(field.get("run_count", -1)) == 63 \
		and absf(float(field.get("physical_length_m", -1.0)) - 206.908708) < 0.000001 \
		and absf(float(field.get("generated_mesh_surface_area_m2", -1.0)) - 4350.511117) < 0.000001 \
		and (field.get("render_chains", []) as Array).size() == 3 \
		and (registry.get("placements", []) as Array).size() == 45 \
		and int(summary.get("module_meshes", -1)) == 351 \
		and int(summary.get("module_triangles", -1)) == 4212 \
		and int(topology.get("total_meshes", -1)) == 354 \
		and int(topology.get("total_surfaces", -1)) == 354 \
		and int(topology.get("total_triangles", -1)) == 4338 \
		and protected == _expected_protected_runs() \
		and str(truth.get("role", "")) == "recognizable_reference_derived_production_inference" \
		and bool(truth.get("reversible", false)) \
		and not bool(truth.get("as_built_fidelity_claimed", true)) \
		and not bool(truth.get("surveyed_coordinates", true)) \
		and not bool(truth.get("surveyed_count", true)) \
		and not bool(truth.get("surveyed_cadence", true)) \
		and not bool(truth.get("whole_building_accepted", true))


static func _build_field_chain(record: Dictionary, scope: Dictionary) -> Dictionary:
	var runs := _int_array(scope.get("exact_ordered_runs", []) as Array)
	var frames: Array[Dictionary] = []
	for run_index: int in runs:
		if run_index in _expected_protected_runs():
			return _failure("building_1_recognizability_protected_run", "A protected Building 1 run entered a field chain.", record)
		var frame := RUN_GEOMETRY.run_frame(record, run_index)
		if frame.is_empty():
			return _failure("building_1_recognizability_field_frame", "A Building 1 field frame did not resolve.", record)
		frames.append(frame)
	var junction_result := _mitered_chain_junctions(frames)
	if not bool(junction_result.get("ok", false)):
		return junction_result
	var bottoms := junction_result.bottoms as Array[Vector3]
	var tops := junction_result.tops as Array[Vector3]
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var accumulated_m := 0.0
	var surface_area_m2 := 0.0
	for offset in runs.size():
		var frame := frames[offset]
		var phase_start := accumulated_m
		var phase_end := phase_start + float(frame.length_m)
		var corners: Array[Vector3] = [bottoms[offset], bottoms[offset + 1], tops[offset + 1], tops[offset]]
		var chain_u := [phase_start, phase_end, phase_end, phase_start]
		var base_vertex := vertices.size()
		for corner_index in 4:
			var point := corners[corner_index]
			vertices.append(point)
			normals.append(frame.normal as Vector3)
			uvs.append(Vector2(float(chain_u[corner_index]), point.y))
		indices.append_array(PackedInt32Array([base_vertex, base_vertex + 2, base_vertex + 1, base_vertex, base_vertex + 3, base_vertex + 2]))
		var start := frame.start as Vector3
		var end := frame.end as Vector3
		var top_start := frame.top_start as Vector3
		var top_end := frame.top_end as Vector3
		surface_area_m2 += _triangle_area(start, top_end, end) + _triangle_area(start, top_start, top_end)
		accumulated_m = phase_end
	# The registry is double precision while Godot rebuilds generated JSON
	# coordinates as Vector3 float32.  Bounds remain sub-millimetre in length
	# and one square centimetre in area even across the 61-run public chain.
	if absf(accumulated_m - float(scope.get("physical_length_m", -1.0))) > 0.001 \
	or absf(surface_area_m2 - float(scope.get("generated_mesh_surface_area_m2", -1.0))) > 0.01:
		return _failure("building_1_recognizability_field_metrics", "Building 1 field length or area drifted.", record)
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_name(0, str(scope.get("scope_id", "B1-IVORY")).to_lower())
	mesh.surface_set_material(0, FIELD_MATERIAL)
	var field := MeshInstance3D.new()
	field.name = str(scope.get("scope_id", "B1-IVORY")).replace("-", "_")
	field.mesh = mesh
	field.material_override = FIELD_MATERIAL
	field.layers = RENDER_BUILDING_WALL
	field.set_meta("field_id", "B1-MAT-IVORY")
	field.set_meta("asset_kind", "homogeneous_material_tile")
	field.set_meta("exact_ordered_runs", runs)
	field.set_meta("physical_length_m", accumulated_m)
	field.set_meta("surface_area_m2", surface_area_m2)
	field.set_meta("join_geometry", "shared_xz_mitered_offset_junctions")
	field.set_meta("maximum_shared_miter_gap_m", 0.0)
	field.set_meta("maximum_join_phase_delta_m", 0.0)
	field.set_meta("runtime_attachment", true)
	field.set_meta("composition_review_status", COMPOSITION_REVIEW_STATUS)
	return {
		"ok": true,
		"node": field,
		"resolved": {
			"scope_id": str(scope.get("scope_id", "")),
			"exact_ordered_runs": runs,
			"run_count": runs.size(),
			"physical_length_m": accumulated_m,
			"surface_area_m2": surface_area_m2,
			"internal_join_count": maxi(0, runs.size() - 1),
			"maximum_shared_miter_gap_m": 0.0,
			"maximum_join_phase_delta_m": 0.0,
			"vertices": vertices.size(),
			"triangles": indices.size() / 3,
		},
	}


static func _mitered_chain_junctions(frames: Array[Dictionary]) -> Dictionary:
	if frames.is_empty():
		return {"ok": false, "message": "Cannot miter an empty Building 1 recognizability field chain."}
	var bottoms: Array[Vector3] = []
	var tops: Array[Vector3] = []
	var first := frames[0]
	bottoms.append((first.start as Vector3) + (first.normal as Vector3) * FIELD_OFFSET_M)
	tops.append((first.top_start as Vector3) + (first.normal as Vector3) * FIELD_OFFSET_M)
	for offset in range(frames.size() - 1):
		var before := frames[offset]
		var after := frames[offset + 1]
		var source_bottom := ((before.end as Vector3) + (after.start as Vector3)) * 0.5
		var source_top := ((before.top_end as Vector3) + (after.top_start as Vector3)) * 0.5
		var bottom := _shared_offset_miter(source_bottom, before.normal as Vector3, after.normal as Vector3)
		var top := _shared_offset_miter(source_top, before.normal as Vector3, after.normal as Vector3)
		if not bool(bottom.get("ok", false)) or not bool(top.get("ok", false)):
			return {"ok": false, "message": "Building 1 recognizability miter is unstable at %d→%d." % [int(before.run_index), int(after.run_index)]}
		bottoms.append(bottom.point as Vector3)
		tops.append(top.point as Vector3)
	var last := frames[-1]
	bottoms.append((last.end as Vector3) + (last.normal as Vector3) * FIELD_OFFSET_M)
	tops.append((last.top_end as Vector3) + (last.normal as Vector3) * FIELD_OFFSET_M)
	return {"ok": true, "bottoms": bottoms, "tops": tops}


static func _shared_offset_miter(source: Vector3, before_normal: Vector3, after_normal: Vector3) -> Dictionary:
	var bisector := before_normal + after_normal
	if bisector.length_squared() < 0.000001:
		return {"ok": false}
	bisector = bisector.normalized()
	var denominator := bisector.dot(before_normal)
	if denominator <= 0.0001:
		return {"ok": false}
	return {"ok": true, "point": source + bisector * (FIELD_OFFSET_M / denominator)}


static func _build_module(record: Dictionary, placement: Dictionary) -> Dictionary:
	var motif_id := str(placement.get("motif_id", ""))
	if motif_id not in ["B1-WING-W", "B1-CENTRAL-W", "B1-PAV-W", "B1-BASE-O", "B1-DOOR-BLUE", "B1-BAND"]:
		return _failure("building_1_recognizability_motif", "A blocked Building 1 motif was requested.", record)
	var run_index := int(placement.get("anchor_run", -1))
	if run_index in _expected_protected_runs():
		return _failure("building_1_recognizability_protected_module", "A Building 1 module targeted a protected run.", record)
	var frame := RUN_GEOMETRY.run_frame(record, run_index)
	var along_m := float(placement.get("along_run_center_m", -1.0))
	var center_height := float(placement.get("center_height_above_base_m", -1.0))
	var bounds := placement.get("nominal_bounds_m", []) as Array
	if frame.is_empty() or bounds.size() != 2:
		return _failure("building_1_recognizability_module_frame", "A Building 1 module frame did not resolve.", record)
	var fraction := along_m / float(frame.length_m)
	var width := float(bounds[0])
	var height := float(bounds[1])
	var start := frame.start as Vector3
	var end := frame.end as Vector3
	var top_start := frame.top_start as Vector3
	var top_end := frame.top_end as Vector3
	var base_y := lerpf(start.y, end.y, fraction)
	var top_y := lerpf(top_start.y, top_end.y, fraction)
	if along_m - width * 0.5 < 0.05 or along_m + width * 0.5 > float(frame.length_m) - 0.05 \
	or center_height - height * 0.5 < 0.05 or center_height + height * 0.5 > top_y - base_y - 0.05:
		return _failure("building_1_recognizability_containment", "%s escaped nominal run containment." % str(placement.get("placement_id", motif_id)), record)
	var module := _accepted_standalone_module(motif_id)
	if module == null:
		return _failure("building_1_recognizability_module_asset", "Accepted Building 1 motif could not instantiate.", record)
	var wall_anchor := start.lerp(end, fraction)
	var normal := frame.normal as Vector3
	var tangent := frame.tangent as Vector3
	var origin := wall_anchor + normal * float(placement.get("wall_offset_m", 0.075))
	origin.y = base_y + center_height
	var expected_origin_array := placement.get("expected_module_origin_world_m", []) as Array
	var expected_origin := Vector3(float(expected_origin_array[0]), float(expected_origin_array[1]), float(expected_origin_array[2]))
	if origin.distance_to(expected_origin) > 0.001:
		module.free()
		return _failure("building_1_recognizability_transform", "A Building 1 production-inference transform drifted from its registry.", record)
	module.name = str(placement.get("placement_id", motif_id)).replace("-", "_")
	module.transform = Transform3D(Basis(tangent, Vector3.UP, normal), origin)
	module.set_meta("placement_id", str(placement.get("placement_id", "")))
	module.set_meta("motif_id", motif_id)
	module.set_meta("asset_kind", "module_atlas")
	module.set_meta("complete_motif", true)
	module.set_meta("anchor_run", run_index)
	module.set_meta("along_run_center_m", along_m)
	module.set_meta("center_height_above_base_m", center_height)
	module.set_meta("evidence_status", str(placement.get("evidence_status", "")))
	module.set_meta("runtime_attachment", true)
	module.set_meta("composition_review_status", COMPOSITION_REVIEW_STATUS)
	module.set_meta("surveyed_coordinates", false)
	module.set_meta("surveyed_count", false)
	module.set_meta("surveyed_cadence", false)
	return {
		"ok": true,
		"node": module,
		"resolved": {
			"placement_id": str(placement.get("placement_id", "")),
			"motif_id": motif_id,
			"anchor_run": run_index,
			"along_run_center_m": along_m,
			"center_height_above_base_m": center_height,
			"module_origin_world_m": [origin.x, origin.y, origin.z],
			"tangent_world_xz": [tangent.x, tangent.z],
			"outward_normal_world_xz": [normal.x, normal.z],
			"region": str(placement.get("region", "")),
			"evidence_status": str(placement.get("evidence_status", "")),
		},
	}


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


static func _expected_field_runs() -> Array[int]:
	var runs: Array[int] = []
	for run_index in range(57):
		runs.append(run_index)
	runs.append_array([58, 60, 93, 94, 95, 96])
	return runs


static func _expected_protected_runs() -> Array[int]:
	var runs: Array[int] = [57, 59, 61]
	for run_index in range(62, 93):
		runs.append(run_index)
	for run_index in range(97, 110):
		runs.append(run_index)
	return runs


static func _triangle_area(a: Vector3, b: Vector3, c: Vector3) -> float:
	return (b - a).cross(c - a).length() * 0.5


static func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


static func _count_surfaces(node: Node) -> int:
	var count := (node as MeshInstance3D).mesh.get_surface_count() if node is MeshInstance3D and (node as MeshInstance3D).mesh != null else 0
	for child: Node in node.get_children():
		count += _count_surfaces(child)
	return count


static func _count_triangles(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mesh := (node as MeshInstance3D).mesh
		for surface_index in mesh.get_surface_count():
			count += (mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
	for child: Node in node.get_children():
		count += _count_triangles(child)
	return count


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	return {"ok": false, "code": code, "message": message, "source_keys": record.get("source_keys", [])}
