class_name W34313525LiveModules
extends RefCounted

const RECEIVER_KEY := "building:w34313525:wall"
const SOURCE_KEY := "w34313525"
const REGISTRY_PATH := "res://game/resources/facades/w34313525_exact_receiver_calibration.json"
const REVIEWED_HELPER_PATH := "res://game/tests/support/w34313525_exact_receiver_calibration.gd"
const ART_REVIEW_PATH := "res://discovery/facades/W34313525_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md"
const PLACEMENT_ROLE := "stylized/reference-derived production inference"
const ACTUAL_WORLD_REVIEW_STATUS := "pending_independent_actual_world_art_review"
const RENDER_BUILDING_WALL := 1 << 1
const EXPECTED_PLACEMENTS := {
	"CAL-SSE-ROLLUP-PALE-01": {"motif_id": "W34313525-ROLLUP-PALE", "face": "SSE", "region": "SSE central outer service elevation", "mapping_id": "B06-34313525-SSE-CENTRAL", "anchor_run": 9, "along_run_center_m": 13.862233, "uncertainty_m": 11.262233},
	"CAL-SSE-ROLLUP-GRAY-01": {"motif_id": "W34313525-ROLLUP-GRAY", "face": "SSE", "region": "SSE central outer service elevation", "mapping_id": "B06-34313525-SSE-CENTRAL", "anchor_run": 10, "along_run_center_m": 16.003442, "uncertainty_m": 13.403442},
	"CAL-NNW-PERSONNEL-01": {"motif_id": "W34313525-PERSONNEL", "face": "NNW", "region": "NNW central outer service elevation", "mapping_id": "B06-34313525-NNW-CENTRAL", "anchor_run": 26, "along_run_center_m": 4.269684, "uncertainty_m": 3.444684},
	"CAL-NNW-HIGH-GROUP-01": {"motif_id": "W34313525-HIGH-GROUP", "face": "NNW", "region": "NNW central outer service elevation", "mapping_id": "B06-34313525-NNW-CENTRAL", "anchor_run": 27, "along_run_center_m": 3.698596, "uncertainty_m": 1.298596},
}

const REVIEWED_CALIBRATION := preload("res://game/tests/support/w34313525_exact_receiver_calibration.gd")


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == RECEIVER_KEY \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))



const FAMILY_PATH := "res://game/resources/facades/w34313525_quality_family.json"
const QUALITY_SUPPORT := preload("res://game/scripts/world/facades/housing_quality_support.gd")


static func build(record: Dictionary) -> Dictionary:
	var legacy := _legacy_build(record)
	if not bool(legacy.get("ok", false)): return legacy
	var root := legacy.node as Node3D
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(FAMILY_PATH))
	if not parsed is Dictionary:
		root.free()
		return _failure("w34313525_family", "Missing target family configuration.", record)
	var cfg: Dictionary = parsed
	var raw_runs: Variant = cfg.get("runs")
	if not raw_runs is Array:
		root.free()
		return _failure("w34313525_family", "Family runs must be a numeric array.", record)
	for value: Variant in raw_runs:
		if not (value is int or value is float) or not is_finite(float(value)) or float(value) != floorf(float(value)) or float(value) < 0.0 or float(value) >= 30.0:
			root.free()
			return _failure("w34313525_family", "Family run must be a finite integral source index.", record)
	var runs: Array[int] = _int_array(raw_runs as Array)
	if cfg.get("source_key") != SOURCE_KEY or cfg.get("receiver_key") != RECEIVER_KEY or runs != [24, 25, 26, 27, 28, 29]:
		root.free()
		return _failure("w34313525_family", "Family source or protected boundary differs.", record)
	# Replace both old NNW exemplars; retain the exact SSE modules unchanged.
	for child: Node in root.get_children():
		if str(child.get_meta("placement_id", "")).begins_with("CAL-NNW-"):
			root.remove_child(child)
			child.free()
	if not _flatten_retained_sse(root):
		root.free()
		return _failure("w34313525_family", "Retained SSE geometry changed during native migration.", record)
	var first := REVIEWED_CALIBRATION.run_frame(record, 24)
	var last := REVIEWED_CALIBRATION.run_frame(record, 29)
	var origin: Vector3 = first.start
	var delta: Vector3 = last.end - origin
	delta.y = 0.0
	var length_m: float = delta.length()
	var tangent: Vector3 = delta.normalized()
	var normal: Vector3 = tangent.cross(Vector3.UP).normalized()
	if normal.dot(first.normal as Vector3) < 0.0: normal = -normal
	var basis := Basis(tangent, Vector3.UP, normal)
	var top := float(record.top_elevation_m)
	var base := float(record.flat_base_elevation_m)
	var pale := _family_material(Color(0.78, 0.80, 0.79))
	var cool := _family_material(Color(0.62, 0.68, 0.70))
	var trim := _family_material(Color(0.73, 0.75, 0.72))
	var soffit := _family_material(Color(0.39, 0.43, 0.43))
	var pane := _family_material(Color(0.40, 0.52, 0.57))
	for run: int in range(24, 30):
		var frame := REVIEWED_CALIBRATION.run_frame(record, run)
		for point: Vector3 in [frame.start, frame.end]:
			if absf((point - origin).dot(normal)) > 0.025:
				root.free()
				return _failure("w34313525_family", "NNW host is not planar.", record)
		_family_host(root, frame, normal, pale)
	# Broad patch fields are subordinate to the complete opening/eave rhythm.
	for patch: Dictionary in cfg.repair_fields:
		_family_box(root, "Repair%d" % root.get_child_count(), basis, origin,
			Vector3(float(patch.center_m), base + 2.10, 0.045), Vector3(float(patch.width_m), 4.10, 0.025), cool, "wall", "NNWRepairField")
	var modules := REVIEWED_CALIBRATION._accepted_standalone_modules()
	for index: int in cfg.groups.size():
		var group: Dictionary = cfg.groups[index]
		var along := float(group.center_m)
		var scale_x := float(group.width_scale)
		if along - 1.75 * scale_x < 0.2 or along + 1.75 * scale_x > length_m - 0.2:
			REVIEWED_CALIBRATION._free_modules(modules)
			root.free()
			return _failure("w34313525_family", "Complete opening escapes NNW host.", record)
		_family_module(root, modules["W34313525-HIGH-GROUP"], basis, origin, Vector3(along, top - float(cfg.high_group_below_roof_m), 0.12), Vector3(scale_x, float(cfg.high_group_height_scale), 1.0), "High%02d" % index, "NNWHighOpening", pane)
		if bool(group.service_leaf):
			_family_module(root, modules["W34313525-PERSONNEL"], basis, origin, Vector3(along - 0.60, base + 1.42, 0.12), Vector3(1.15, 1.15, 1.0), "Service%02d" % index, "NNWClosedServiceLeaf")
	REVIEWED_CALIBRATION._free_modules(modules)
	var projection := float(cfg.eave_projection_m)
	# Closed shallow eave contacts the retained roof edge; no new roof plane.
	_family_box(root, "NNWEave", basis, origin, Vector3(length_m * 0.5, top - 0.08, projection * 0.5), Vector3(length_m, 0.16, projection), soffit, "detail", "NNWEaveSoffit")
	_family_box(root, "NNWFascia", basis, origin, Vector3(length_m * 0.5, top - 0.14, projection - 0.035), Vector3(length_m, 0.28, 0.07), pale, "detail", "NNWEaveFascia")
	var rafters := int(floor((length_m - 0.4) / float(cfg.rafter_spacing_m)))
	for index: int in rafters + 1:
		var along: float = 0.2 + (length_m - 0.4) * float(index) / float(rafters)
		_family_box(root, "NNWRafter%03d" % index, basis, origin, Vector3(along, top - 0.25, projection * 0.5 - 0.01), Vector3(0.14, 0.18, projection - 0.02), trim, "detail", "NNWExposedRafter")
	var support := QUALITY_SUPPORT.attach(root, record, record, {})
	if not bool(support.get("ok", false)): return support
	var counts := _render_topology(root)
	var metadata := {"source_key": SOURCE_KEY, "receiver_key": RECEIVER_KEY, "observed_runs": [25, 26], "production_inference_runs": [24, 27, 28, 29], "protected_runs": "0–23", "placement_role": "production_inference", "completed_nnw_study": true, "reference_recognizable": false}
	for key: String in metadata: root.set_meta(key, metadata[key])
	return {"ok": true, "node": root, "metadata": metadata, "mesh_instances": counts.mesh_instances, "surfaces": counts.surfaces, "triangles": counts.triangles}



static func _flatten_retained_sse(root: Node3D) -> bool:
	var retained := {
		"CAL-SSE-ROLLUP-PALE-01": {"detail": "RetainedSSERollupPale", "run": 9},
		"CAL-SSE-ROLLUP-GRAY-01": {"detail": "RetainedSSERollupGray", "run": 10},
	}
	for child: Node in root.get_children():
		var module := child as Node3D
		var placement := str(module.get_meta("placement_id", ""))
		if not retained.has(placement): return false
		var spec: Dictionary = retained[placement]
		for part: Node in module.get_children():
			var mesh := part as MeshInstance3D
			if mesh == null or mesh.mesh == null: return false
			var source_mesh: Mesh = mesh.mesh
			var source_material: Material = mesh.material_override
			var composed: Transform3D = module.transform * mesh.transform
			var before_bounds: AABB = composed * source_mesh.get_aabb()
			var before_faces := PackedVector3Array()
			for vertex: Vector3 in source_mesh.get_faces(): before_faces.append(composed * vertex)
			module.remove_child(mesh)
			mesh.transform = composed
			mesh.name = placement.replace("-", "_") + "_" + str(mesh.name)
			_family_tag(mesh, "wall", str(spec.detail))
			mesh.set_meta("host_runs", [int(spec.run)])
			mesh.set_meta("placement_id", placement)
			mesh.set_meta("complete_motif", true)
			root.add_child(mesh)
			if mesh.mesh != source_mesh or mesh.material_override != source_material or not (mesh.transform * mesh.mesh.get_aabb()).is_equal_approx(before_bounds): return false
			var after_faces: PackedVector3Array = mesh.mesh.get_faces()
			for index: int in after_faces.size():
				if not (mesh.transform * after_faces[index]).is_equal_approx(before_faces[index]): return false
			if mesh.get_meta("source_keys") != [SOURCE_KEY] or mesh.get_meta("derived_object_key") != RECEIVER_KEY: return false
		root.remove_child(module)
		module.free()
	return true


static func _family_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material


static func _family_tag(mesh: MeshInstance3D, role: String, detail: String) -> void:
	mesh.layers = 3 if role == "wall" else 1
	mesh.set_meta("physical_role", role)
	mesh.set_meta("construction_detail", detail)
	mesh.set_meta("source_keys", [SOURCE_KEY])
	mesh.set_meta("derived_object_key", RECEIVER_KEY)
	mesh.set_meta("placement_status", "production_inference")
	mesh.set_meta("host_runs", [24, 25, 26, 27, 28, 29])


static func _family_box(root: Node3D, label: String, basis: Basis, origin: Vector3, center: Vector3, size: Vector3, material: Material, role: String, detail: String) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.name = label
	var position := origin + basis.x * center.x + basis.z * center.z
	position.y = center.y
	mesh.transform = Transform3D(basis, position)
	mesh.material_override = material
	_family_tag(mesh, role, detail)
	root.add_child(mesh)


static func _family_module(root: Node3D, source: Node3D, basis: Basis, origin: Vector3, center: Vector3, scale_m: Vector3, label: String, detail: String, pane: Material = null) -> void:
	var position := origin + basis.x * center.x + basis.z * center.z
	position.y = center.y
	var placement := Transform3D(Basis(basis.x * scale_m.x, basis.y * scale_m.y, basis.z * scale_m.z), position)
	for child: Node in source.get_children():
		var mesh := child.duplicate() as MeshInstance3D
		mesh.name = label + str(child.name)
		if pane != null and str(child.name) == "OpaqueWindowOrGrilleFace": mesh.material_override = pane
		mesh.transform = placement * (child as Node3D).transform
		_family_tag(mesh, "wall", detail)
		root.add_child(mesh)


static func _family_host(root: Node3D, frame: Dictionary, normal: Vector3, material: Material) -> void:
	var points := PackedVector3Array()
	for point: Vector3 in [frame.start, frame.end, frame.top_end, frame.top_start]: points.append(point + normal * 0.025)
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array([normal, normal, normal, normal])
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 2, 1, 0, 3, 2])
	var surface := ArrayMesh.new()
	surface.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mesh := MeshInstance3D.new()
	mesh.name = "NNWHost%d" % int(frame.run_index)
	mesh.mesh = surface
	mesh.material_override = material
	_family_tag(mesh, "wall", "NNWPaleHost")
	root.add_child(mesh)


static func _legacy_build(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return _failure("w34313525_live_module_receiver", "Live four-motif target receiver identity does not match.", record)
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not (registry_value is Dictionary):
		return _failure("w34313525_live_module_registry", "Reviewed exact-receiver registry did not parse.", record)
	var registry := registry_value as Dictionary
	if not _registry_matches_exact_live_scope(registry):
		return _failure("w34313525_live_module_scope", "Reviewed registry no longer matches the exact two-field/four-placement authorization.", record)
	var reviewed := REVIEWED_CALIBRATION.build(record, registry)
	if not bool(reviewed.get("ok", false)):
		return reviewed
	var detached_root := reviewed.get("node") as Node3D
	if detached_root == null:
		return _failure("w34313525_live_module_geometry", "Reviewed calibration did not produce a detached root.", record)
	var reviewed_transforms := {}
	var live_modules: Array[Node3D] = []
	for placement_id: String in EXPECTED_PLACEMENTS:
		var module := detached_root.get_node_or_null(placement_id.replace("-", "_")) as Node3D
		if module == null or not _promote_module_to_live(module, registry):
			detached_root.free()
			return _failure("w34313525_live_module_geometry", "Reviewed module %s failed the render-only live attachment contract." % placement_id, record)
		reviewed_transforms[placement_id] = module.transform
		detached_root.remove_child(module)
		live_modules.append(module)
	detached_root.free()
	var live_root := Node3D.new()
	live_root.name = "W34313525LiveModules"
	for module: Node3D in live_modules:
		live_root.add_child(module)
		var placement_id := str(module.get_meta("placement_id", ""))
		if not module.transform.is_equal_approx(reviewed_transforms[placement_id] as Transform3D):
			live_root.free()
			return _failure("w34313525_live_module_transform", "Live module %s transform drifted while detaching it from calibration-only field overlays." % placement_id, record)
	var topology := _render_topology(live_root)
	if int(topology.mesh_instances) == 0 or int(topology.triangles) == 0:
		live_root.free()
		return _failure("w34313525_live_module_topology", "Reviewed four-motif modules produced no render geometry.", record)
	var resolved_placements := (reviewed.get("resolved_placements", []) as Array).duplicate(true)
	var metadata := {
		"source_key": SOURCE_KEY,
		"receiver_key": RECEIVER_KEY,
		"placement_review_verdict": "ACCEPT_WITH_DOCUMENTED_LIMITATION",
		"placement_role": PLACEMENT_ROLE,
		"module_instances": EXPECTED_PLACEMENTS.size(),
		"motif_instance_counts": {
			"W34313525-ROLLUP-PALE": 1,
			"W34313525-ROLLUP-GRAY": 1,
			"W34313525-PERSONNEL": 1,
			"W34313525-HIGH-GROUP": 1,
		},
		"asset_classification": "module_atlas",
		"complete_motif": true,
		"module_not_seamless_tile": true,
		"high_group_semantic_face_status": "window_or_grille_not_disambiguated_opaque_proxy_only",
		"mesh_instances": int(topology.mesh_instances),
		"surfaces": int(topology.surfaces),
		"triangles": int(topology.triangles),
		"field_meshes": 0,
		"backing_meshes": 0,
		"collision_nodes": 0,
		"navigation_nodes": 0,
		"spray_nodes": 0,
		"surveyed_dimensions": false,
		"surveyed_coordinates": false,
		"surveyed_scale": false,
		"surveyed_count": false,
		"surveyed_cadence": false,
		"cadence_inferred": false,
		"sequence_inferred": false,
		"maximum_uncertainty_envelope_contained_for_all_modules": false,
		"completed_sse_elevation": false,
		"completed_nnw_elevation": false,
		"reviewed_registry_path": REGISTRY_PATH,
		"reviewed_geometry_helper_path": REVIEWED_HELPER_PATH,
		"independent_calibration_review_path": ART_REVIEW_PATH,
		"resolved_placements": resolved_placements,
	}
	for key: String in metadata:
		live_root.set_meta(key, metadata[key])
	return {
		"ok": true,
		"node": live_root,
		"mesh_instances": int(topology.mesh_instances),
		"surfaces": int(topology.surfaces),
		"triangles": int(topology.triangles),
		"metadata": metadata,
		"resolved_placements": resolved_placements,
	}


static func _registry_matches_exact_live_scope(registry: Dictionary) -> bool:
	var target := registry.get("target", {}) as Dictionary
	var scopes := registry.get("exact_field_scopes", []) as Array
	var contracts := registry.get("module_contracts", []) as Array
	var policy := registry.get("placement_policy", {}) as Dictionary
	var field_contract := registry.get("field_material_contract", {}) as Dictionary
	var field_parameters := field_contract.get("material_parameters", {}) as Dictionary
	if str(target.get("receiver_key", "")) != RECEIVER_KEY \
	or int(target.get("run_count", -1)) != 30 \
	or scopes.size() != 2 \
	or contracts.size() != 4 \
	or int(policy.get("placement_count", -1)) != EXPECTED_PLACEMENTS.size() \
	or not is_equal_approx(float(field_parameters.get("primary_scale_m", -1.0)), 0.88) \
	or not is_equal_approx(float(field_parameters.get("secondary_scale_m", -1.0)), 0.31) \
	or int(policy.get("collision_nodes", -1)) != 0 \
	or int(policy.get("navigation_nodes", -1)) != 0 \
	or int(policy.get("spray_nodes", -1)) != 0:
		return false
	var scope_runs := {}
	for value: Variant in scopes:
		var scope := value as Dictionary
		scope_runs[str(scope.get("scope_id", ""))] = _int_array(scope.get("exact_ordered_runs", []) as Array)
		if str(scope.get("material_id", "")) != "W34313525-MAT-PALE" \
		or str(scope.get("asset_kind", "")) != "homogeneous_material_tile":
			return false
	if scope_runs != {"CAL-FIELD-SSE-PALE-01": [8, 9, 10, 11, 12], "CAL-FIELD-NNW-PALE-01": [26, 27]}:
		return false
	var contract_ids: Array[String] = []
	for value: Variant in contracts:
		var contract := value as Dictionary
		contract_ids.append(str(contract.get("motif_id", "")))
		if str(contract.get("asset_kind", "")) != "module_atlas" \
		or not bool(contract.get("complete_motif", false)) \
		or not bool(contract.get("module_not_seamless_wall_tile", false)) \
		or bool(contract.get("module_owns_field_geometry", true)):
			return false
	contract_ids.sort()
	if contract_ids != ["W34313525-HIGH-GROUP", "W34313525-PERSONNEL", "W34313525-ROLLUP-GRAY", "W34313525-ROLLUP-PALE"]:
		return false
	var seen := {}
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		var placement_id := str(placement.get("placement_id", ""))
		var expected := EXPECTED_PLACEMENTS.get(placement_id, {}) as Dictionary
		if expected.is_empty() or seen.has(placement_id):
			return false
		seen[placement_id] = true
		if str(placement.get("motif_id", "")) != str(expected.motif_id) \
		or str(placement.get("face", "")) != str(expected.face) \
		or str(placement.get("region", "")) != str(expected.region) \
		or str(placement.get("mapping_id", "")) != str(expected.mapping_id) \
		or int(placement.get("anchor_run", -1)) != int(expected.anchor_run) \
		or _int_array(placement.get("exact_ordered_runs", []) as Array) != [int(expected.anchor_run)] \
		or not is_equal_approx(float(placement.get("along_run_center_m", -1.0)), float(expected.along_run_center_m)):
			return false
	return seen.size() == EXPECTED_PLACEMENTS.size()


static func _promote_module_to_live(module: Node3D, registry: Dictionary) -> bool:
	var placement_id := str(module.get_meta("placement_id", ""))
	var expected := EXPECTED_PLACEMENTS.get(placement_id, {}) as Dictionary
	var placement := _placement_for(registry, placement_id)
	if expected.is_empty() or placement.is_empty() \
	or module.get_child_count() == 0 \
	or _count_type(module, CollisionObject3D) != 0 \
	or _count_type(module, CollisionShape3D) != 0 \
	or _count_type(module, NavigationRegion3D) != 0 \
	or _count_type(module, Decal) != 0:
		return false
	module.set_meta("placement_role", PLACEMENT_ROLE)
	module.set_meta("host_material_id", "W34313525-MAT-PALE")
	module.set_meta("run_ownership", [int(expected.anchor_run)])
	module.set_meta("exact_ordered_runs", [int(expected.anchor_run)])
	module.set_meta("anchor_run", int(expected.anchor_run))
	module.set_meta("along_run_center_m", float(expected.along_run_center_m))
	module.set_meta("along_run_center_uncertainty_m", float(expected.uncertainty_m))
	module.set_meta("coordinates_surveyed", false)
	module.set_meta("dimensions_surveyed", false)
	module.set_meta("scale_surveyed", false)
	module.set_meta("count_surveyed", false)
	module.set_meta("cadence_surveyed", false)
	module.set_meta("cadence_inferred", false)
	module.set_meta("sequence_inferred", false)
	module.set_meta("completed_sse_elevation", false)
	module.set_meta("completed_nnw_elevation", false)
	module.set_meta("complete_motif", true)
	module.set_meta("module_not_seamless_tile", true)
	module.set_meta("module_owns_field_geometry", false)
	if str(expected.motif_id) == "W34313525-HIGH-GROUP":
		module.set_meta("semantic_face_status", "window_or_grille_not_disambiguated_opaque_proxy_only")
	for child: Node in module.get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null or not (mesh_instance.mesh is BoxMesh) \
		or mesh_instance.material_override == null \
		or "field" in str(mesh_instance.name).to_lower() \
		or "backing" in str(mesh_instance.name).to_lower() \
		or "surround" in str(mesh_instance.name).to_lower():
			return false
		mesh_instance.layers = RENDER_BUILDING_WALL
		var box := mesh_instance.mesh as BoxMesh
		var back_clearance := REVIEWED_CALIBRATION.MODULE_WALL_OFFSET_M + mesh_instance.position.z - box.size.z * 0.5
		if back_clearance < 0.001:
			return false
	return true


static func _render_topology(node: Node) -> Dictionary:
	var result := {"mesh_instances": 0, "surfaces": 0, "triangles": 0}
	if node is MeshInstance3D:
		var mesh := (node as MeshInstance3D).mesh
		if mesh != null:
			result.mesh_instances = 1
			result.surfaces = mesh.get_surface_count()
			for surface_index in mesh.get_surface_count():
				var arrays := mesh.surface_get_arrays(surface_index)
				result.triangles += int((arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
	for child: Node in node.get_children():
		var child_result := _render_topology(child)
		result.mesh_instances += int(child_result.mesh_instances)
		result.surfaces += int(child_result.surfaces)
		result.triangles += int(child_result.triangles)
	return result


static func _placement_for(registry: Dictionary, placement_id: String) -> Dictionary:
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		if str(placement.get("placement_id", "")) == placement_id:
			return placement
	return {}


static func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	return {"ok": false, "code": code, "message": message, "source_keys": record.get("source_keys", [])}
