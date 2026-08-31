extends SceneTree

const CALIBRATION_HELPER := preload("res://game/tests/support/w34313525_exact_receiver_calibration.gd")
const REGISTRY_PATH := "res://game/resources/facades/w34313525_exact_receiver_calibration.json"
const CHUNK_PATH := "res://generated/world/chunks/x_1__z_-1.json"
const RECEIVER_KEY := "building:w34313525:wall"
const EXPECTED_REGISTRY_SHA256 := "ba22916618510f610719606c1c18f84b8965bbd76fe74eddc5430745470bbddd"
const EXPECTED_PROTECTED_HASHES := {
	REGISTRY_PATH: EXPECTED_REGISTRY_SHA256,
	"res://game/tests/support/w34313525_exact_receiver_calibration.gd": "a9ff1f94274509cdb39c6208117c59b84ba67598ff8a59a1eb57bf30a4b03532",
	"res://game/resources/materials/world/w34313525/w34313525_pale_exact_trial.tres": "d8a4500d3f3ec036b5e0b4c4273caf0644abdc3bda626fb831e2989d63559752",
	"res://game/resources/facades/w34313525_standalone_prototypes.json": "86d3634e62f367f24bef98206fe1e6f34124023f0d9672bbd318c45c0a33b170",
	"res://game/scenes/world/facades/batch_06/w34313525_standalone_prototype_set.tscn": "9259ab6f231fee7d3d3ad8bfea0a290a455b1490b291a1d05b7cd64df4965cbe",
	"res://game/scripts/world/facades/w34313525_standalone_prototypes.gd": "a8e432b8cae545532aa976b095e2dc012454dd73648dccf09d55be550ccbcc76",
	"res://game/resources/materials/world/w34313525/w34313525_pale_field.tres": "00ad40bbc932d7b7d4a3ce77d13a3798f25a35e908bd45a1a5f7f38ba4c80eff",
	"res://game/resources/materials/world/w34313525/w34313525_frame.tres": "2298f55a4129757eb69af498236e609384acb1565a2c0654e8200bc79e0ae21e",
	"res://game/resources/materials/world/w34313525/w34313525_rollup_pale.tres": "ded6d1de11ce4e77c71ee384be689257707c522718c9f8fad20fb3d1933fee47",
	"res://game/resources/materials/world/w34313525/w34313525_rollup_gray.tres": "b0beeb8e0cf894e3cafd8f7084e0d235074b67daf29c2a863f514d5386173b8a",
	"res://game/resources/materials/world/w34313525/w34313525_personnel.tres": "bcc6295ffe9229f6b7105c13896f0ff0cfcd5d3227e3b30046d9957c2272a88f",
	"res://game/resources/materials/world/w34313525/w34313525_high_group.tres": "68f56c35a7e2ef870dd395e5f2e38b8cc5d640b532de32339ae4b22ffbabadfb",
	"res://discovery/facades/W34313525_STANDALONE_PROTOTYPE_ART_REVIEW.md": "3a75990173f6d272bf45b5f7c5ab6b411132a786751f1ed1f240a79d207231e6",
	"res://discovery/facades/W34313525_REFERENCE_SPEC.md": "c373708e12ef4aefaabfd678ac8aad455e0a846f9d833c710f569b39fdb1ab42",
	"res://discovery/facades/BATCH_06_STREETVIEW_OBSERVATIONS.md": "259e562e69b1186912fce2dfb466f4512fbc69cc8e64562574971c0a8c40028b",
	"res://discovery/facades/BATCH_06_REFERENCE_INDEX.md": "3808ca452c4ef3ed970a2d2a8d73077353160bc60d6847e5919aefc57a22d9ef",
	"res://discovery/facades/BATCH_06_RUN_MAPPING.json": "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d",
	CHUNK_PATH: "a952756b1c6d8d547669dffb89723c2be81d6c9a4b3afd2ae7f2dc3702a82b0d",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://game/scripts/world/world_chunk_builder.gd": "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://game/scripts/world/facades/w34313525_live_modules.gd": "f9b31302eaf98fd4185aed4f28d3651794e2e50958ad2641c04aec0dd45f05e1",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f",
	"res://game/resources/facades/batch_06_prototype_registry.json": "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(_protected_hashes_match(), "An accepted standalone asset, approved reference, exact geometry, runtime input, or calibration artifact drifted."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var record := _record_data()
	if not _require(_registry_matches(registry, record), "Exact field scopes, four placement records, inference flags, or blockers drifted.") \
	or not _require(_material_matches(), "The exact wall-tangent trial no longer preserves every accepted standalone field parameter.") \
	or not _require(_bounded_live_integration_matches(), "The detached package drifted or current live integration is broader than its reviewed registry."):
		_finish()
		return
	var first_result := CALIBRATION_HELPER.build(record, registry)
	var second_result := CALIBRATION_HELPER.build(record, registry)
	if not _require(bool(first_result.get("ok", false)) and bool(second_result.get("ok", false)), "The detached exact-receiver helper failed to build twice."):
		_free_result(first_result)
		_free_result(second_result)
		_finish()
		return
	var first := first_result.node as Node3D
	var second := second_result.node as Node3D
	root.add_child(first)
	root.add_child(second)
	if not _require(JSON.stringify(first_result.resolved_field_scopes) == JSON.stringify(second_result.resolved_field_scopes) \
	and JSON.stringify(first_result.resolved_placements) == JSON.stringify(second_result.resolved_placements) \
	and _geometry_signature(first) == _geometry_signature(second), "Fresh detached builds are not deterministic.") \
	or not _require(_field_geometry_matches(first, first_result.resolved_field_scopes as Array), "The exact seven-run/two-side field geometry, physical spans, or per-side phase continuity failed.") \
	or not _require(_module_geometry_matches(first, first_result.resolved_placements as Array), "The four complete module transforms, containment, or zero-backing contract failed.") \
	or not _require(_standalone_module_signatures_match(first), "Detached module child geometry/material identity differs from the independently accepted standalone assets."):
		first.free()
		second.free()
		_finish()
		return
	first.free()
	second.free()
	print("PASS: w34313525 detached exact-receiver calibration remains byte-identical and deterministic over exact SSE runs 8..12 and NNW runs 26..27 plus exactly four backing-free exemplars on runs 9, 10, 26, and 27; current live integration consumes only that independently reviewed registry while all scale/coordinate/dimension/count/cadence/sequence/elevation/building claims remain unsurveyed or false")
	_finish()


func _registry_matches(registry: Dictionary, record: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.w34313525-detached-exact-receiver-calibration/1" \
	or str(registry.get("status", "")) != "detached_exact_receiver_calibration_ready_for_independent_art_review_not_self_accepted" \
	or record.is_empty():
		push_error("Registry header or record failed.")
		return false
	var scopes := registry.get("exact_field_scopes", []) as Array
	var placements := registry.get("placements", []) as Array
	if scopes.size() != 2 or placements.size() != 4:
		push_error("Registry scope/placement counts failed: %d/%d" % [scopes.size(), placements.size()])
		return false
	if _int_array((scopes[0] as Dictionary).get("exact_ordered_runs", []) as Array) != [8, 9, 10, 11, 12] \
	or _int_array((scopes[1] as Dictionary).get("exact_ordered_runs", []) as Array) != [26, 27] \
	or absf(float((scopes[0] as Dictionary).get("physical_wall_length_m", 0.0)) - 75.31091) > 0.00001 \
	or absf(float((scopes[1] as Dictionary).get("physical_wall_length_m", 0.0)) - 15.93656) > 0.00001:
		push_error("Registry exact scope chains or lengths failed: %s / %s / %.9f / %.9f" % [str((scopes[0] as Dictionary).get("exact_ordered_runs", [])), str((scopes[1] as Dictionary).get("exact_ordered_runs", [])), float((scopes[0] as Dictionary).get("physical_wall_length_m", 0.0)), float((scopes[1] as Dictionary).get("physical_wall_length_m", 0.0))])
		return false
	var expected := {
		"CAL-SSE-ROLLUP-PALE-01": ["W34313525-ROLLUP-PALE", "SSE", 9, 13.862233],
		"CAL-SSE-ROLLUP-GRAY-01": ["W34313525-ROLLUP-GRAY", "SSE", 10, 16.003442],
		"CAL-NNW-PERSONNEL-01": ["W34313525-PERSONNEL", "NNW", 26, 4.269684],
		"CAL-NNW-HIGH-GROUP-01": ["W34313525-HIGH-GROUP", "NNW", 27, 3.698596],
	}
	for value: Variant in placements:
		var placement := value as Dictionary
		var id := str(placement.get("placement_id", ""))
		if not expected.has(id):
			push_error("Unexpected placement id: %s" % id)
			return false
		var tuple := expected[id] as Array
		if str(placement.get("motif_id", "")) != str(tuple[0]) \
		or str(placement.get("face", "")) != str(tuple[1]) \
		or int(placement.get("anchor_run", -1)) != int(tuple[2]) \
		or absf(float(placement.get("along_run_center_m", -1.0)) - float(tuple[3])) > 0.000001:
			push_error("Placement tuple failed: %s" % id)
			return false
		for false_key in ["surveyed_dimensions", "surveyed_coordinates", "surveyed_count", "surveyed_cadence", "completed_elevation", "whole_building_accepted", "runtime_attachment"]:
			if bool(placement.get(false_key, true)):
				push_error("Placement false claim failed: %s/%s" % [id, false_key])
				return false
	var false_claims := registry.get("preserved_false_claims", {}) as Dictionary
	for value: Variant in false_claims.values():
		if bool(value):
			push_error("Preserved false-claim value became true.")
			return false
	return str((placements[3] as Dictionary).get("semantic_face_status", "")) == "window_or_grille_not_disambiguated_opaque_proxy_only" \
		and int((registry.get("placement_policy", {}) as Dictionary).get("placement_count", -1)) == 4 \
		and not bool((registry.get("detached_overlay_contract", {}) as Dictionary).get("runtime_attachment", true))


func _material_matches() -> bool:
	var standalone := load("res://game/resources/materials/world/w34313525/w34313525_pale_field.tres") as ShaderMaterial
	var exact := load("res://game/resources/materials/world/w34313525/w34313525_pale_exact_trial.tres") as ShaderMaterial
	if standalone == null or exact == null or exact.shader.resource_path != "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_aperiodic_field.gdshader":
		return false
	for parameter in ["base_color", "secondary_color", "roughness_value", "field_kind", "primary_scale_m", "secondary_scale_m", "relief_strength", "color_variation", "filter_start_cycles_per_pixel", "filter_end_cycles_per_pixel"]:
		if standalone.get_shader_parameter(parameter) != exact.get_shader_parameter(parameter):
			return false
	return true


func _field_geometry_matches(root_node: Node3D, scopes: Array) -> bool:
	if scopes.size() != 2:
		return false
	var sse := scopes[0] as Dictionary
	var nnw := scopes[1] as Dictionary
	return root_node.get_node_or_null("CAL_FIELD_SSE_PALE_01") is MeshInstance3D \
		and root_node.get_node_or_null("CAL_FIELD_NNW_PALE_01") is MeshInstance3D \
		and _int_array(sse.get("exact_ordered_runs", []) as Array) == [8, 9, 10, 11, 12] \
		and _int_array(nnw.get("exact_ordered_runs", []) as Array) == [26, 27] \
		and absf(float(sse.get("physical_length_m", 0.0)) - 75.31091) < 0.0001 \
		and absf(float(nnw.get("physical_length_m", 0.0)) - 15.93656) < 0.0001 \
		and absf(float(sse.get("physical_area_m2", 0.0)) - 377.392952) < 0.001 \
		and absf(float(nnw.get("physical_area_m2", 0.0)) - 80.510358) < 0.001 \
		and float(sse.get("maximum_junction_phase_delta_m", 1.0)) < 0.0001 \
		and float(nnw.get("maximum_junction_phase_delta_m", 1.0)) < 0.0001 \
		and int(sse.get("triangles", -1)) == 10 \
		and int(nnw.get("triangles", -1)) == 4


func _module_geometry_matches(root_node: Node3D, resolved: Array) -> bool:
	if resolved.size() != 4 or _count_meshes(root_node) != 40 or _count_surfaces(root_node) != 40 or _count_triangles(root_node) != 470:
		return false
	if _count_type(root_node, CollisionObject3D) != 0 or _count_type(root_node, CollisionShape3D) != 0 or _count_type(root_node, NavigationRegion3D) != 0:
		return false
	var expected_origins := {
		"CAL-SSE-ROLLUP-PALE-01": Vector3(307.809835, 5.566, -70.494612),
		"CAL-SSE-ROLLUP-GRAY-01": Vector3(334.134335, 5.561, -84.600612),
		"CAL-NNW-PERSONNEL-01": Vector3(291.735165, 4.92, -133.563388),
		"CAL-NNW-HIGH-GROUP-01": Vector3(284.711665, 7.408, -129.799888),
	}
	for value: Variant in resolved:
		var placement := value as Dictionary
		var id := str(placement.get("placement_id", ""))
		if not expected_origins.has(id) or _vector3(placement.get("module_origin_world_m", []) as Array).distance_to(expected_origins[id] as Vector3) > 0.0002:
			return false
		var module := root_node.get_node_or_null(id.replace("-", "_")) as Node3D
		if module == null or bool(module.get_meta("module_owns_field_geometry", true)) or bool(module.get_meta("runtime_attachment", true)):
			return false
		for child in module.find_children("*", "MeshInstance3D", true, false):
			var lower_name := child.name.to_lower()
			if "backing" in lower_name or "surround" in lower_name or "field" in lower_name:
				return false
	return true


func _standalone_module_signatures_match(detached_root: Node3D) -> bool:
	var packed := load("res://game/scenes/world/facades/batch_06/w34313525_standalone_prototype_set.tscn") as PackedScene
	var standalone := packed.instantiate() as Node3D
	standalone.call("_build")
	var pairs := {
		"W34313525_ROLLUP_PALE": "CAL_SSE_ROLLUP_PALE_01",
		"W34313525_ROLLUP_GRAY": "CAL_SSE_ROLLUP_GRAY_01",
		"W34313525_PERSONNEL": "CAL_NNW_PERSONNEL_01",
		"W34313525_HIGH_GROUP": "CAL_NNW_HIGH_GROUP_01",
	}
	for source_name: String in pairs:
		var source_module := standalone.get_node("PrototypeGeometry/%s" % source_name) as Node3D
		var detached_module := detached_root.get_node(str(pairs[source_name])) as Node3D
		if _module_child_signature(source_module) != _module_child_signature(detached_module):
			standalone.free()
			return false
	standalone.free()
	return true


func _bounded_live_integration_matches() -> bool:
	var builder := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	var accepted := FileAccess.get_file_as_string("res://game/scripts/world/facades/accepted_material_run_trials.gd")
	var live_adapter := FileAccess.get_file_as_string("res://game/scripts/world/facades/w34313525_live_modules.gd")
	return "w34313525_live_modules.gd" in builder \
		and "building:w34313525:wall" in accepted \
		and "trial_w34313525_pale_sse_runs" in accepted \
		and "trial_w34313525_pale_nnw_runs" in accepted \
		and "w34313525_standalone_prototype_set.tscn" not in builder \
		and "w34313525_standalone_prototypes.gd" not in builder \
		and "CAL-SSE-ROLLUP-PALE-01" in live_adapter \
		and "CAL-SSE-ROLLUP-GRAY-01" in live_adapter \
		and "CAL-NNW-PERSONNEL-01" in live_adapter \
		and "CAL-NNW-HIGH-GROUP-01" in live_adapter


func _protected_hashes_match() -> bool:
	for file_name: String in EXPECTED_PROTECTED_HASHES:
		if FileAccess.get_sha256(file_name) != str(EXPECTED_PROTECTED_HASHES[file_name]):
			push_error("Protected file drifted: %s" % file_name)
			return false
	return true


func _record_data() -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	for record_value: Variant in chunk.get("records", []):
		var record := record_value as Dictionary
		if str(record.get("object_key", "")) == RECEIVER_KEY:
			return record
	return {}


func _geometry_signature(node: Node) -> String:
	var records: Array[String] = []
	_collect_geometry(node, records, true)
	records.sort()
	return JSON.stringify(records).sha256_text()


func _module_child_signature(node: Node) -> String:
	var records: Array[String] = []
	for child in node.get_children():
		_collect_geometry(child, records, false)
	records.sort()
	return JSON.stringify(records).sha256_text()


func _collect_geometry(node: Node, records: Array[String], include_global_transform: bool) -> void:
	if node is MeshInstance3D:
		var instance := node as MeshInstance3D
		var material_paths: Array[String] = []
		for surface in instance.mesh.get_surface_count():
			var material := instance.get_surface_override_material(surface)
			if material == null:
				material = instance.material_override
			if material == null:
				material = instance.mesh.surface_get_material(surface)
			material_paths.append(material.resource_path if material != null else "")
		var transform := instance.global_transform if include_global_transform else instance.transform
		records.append(JSON.stringify([instance.name, transform, instance.mesh.get_surface_count(), _mesh_triangles(instance.mesh), material_paths]))
	for child in node.get_children():
		_collect_geometry(child, records, include_global_transform)


func _count_meshes(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _count_meshes(child)
	return count


func _count_surfaces(node: Node) -> int:
	var count := (node as MeshInstance3D).mesh.get_surface_count() if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _count_surfaces(child)
	return count


func _count_triangles(node: Node) -> int:
	var count := _mesh_triangles((node as MeshInstance3D).mesh) if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _count_triangles(child)
	return count


func _mesh_triangles(mesh: Mesh) -> int:
	var triangles := 0
	for surface in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(surface)
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		if indices.size() > 0:
			triangles += indices.size() / 3
		else:
			triangles += (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	return triangles


func _count_type(node: Node, type: Variant) -> int:
	var count := 1 if is_instance_of(node, type) else 0
	for child in node.get_children():
		count += _count_type(child, type)
	return count


func _vector3(values: Array) -> Vector3:
	if values.size() != 3:
		return Vector3.INF
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _free_result(result: Dictionary) -> void:
	var node := result.get("node") as Node
	if node != null:
		node.free()


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_failed = true
		push_error(message)
	return condition


func _finish() -> void:
	quit(1 if _failed else 0)
