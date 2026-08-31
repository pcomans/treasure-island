extends SceneTree

const CALIBRATION_HELPER := preload("res://game/tests/support/w34313520_exact_receiver_calibration.gd")
const REGISTRY_PATH := "res://game/resources/facades/w34313520_exact_receiver_calibration.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_0.json"
const RECEIVER_KEY := "building:w34313520:wall"
const EXPECTED_REGISTRY_SHA256 := "28ea8b6e506d747299a920e4d456d8676031e18ec3b6d9e959cab31fa33de4f1"
const EXPECTED_PROTECTED_HASHES := {
	REGISTRY_PATH: EXPECTED_REGISTRY_SHA256,
	"res://game/tests/support/w34313520_exact_receiver_calibration.gd": "d747d9f9ca5798b09909efeeb930cdee119f1b3c310e95f9a2c426a3ee6ceea4",
	"res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres": "89fbb97ed797275a86c394af7eab13f946cbf23f29cba58b89a2b2d467030ab2",
	"res://game/resources/facades/w34313520_standalone_prototypes.json": "ab80f0cd0424c22f7f24e5fc82211353e9aee7c95bea4903022681a48c5620a4",
	"res://game/resources/materials/world/w34313520/w34313520_pale_field.tres": "7944151fd5ab8e977e7052d0cdb8df20132c82f967d8ebfefff83ede8fcf07a4",
	"res://game/resources/materials/world/w34313520/w34313520_bay_frame.tres": "445d3bec9d2ef3130aab27c816b27e384c689af68298b2db5ada37e0178f249b",
	"res://game/resources/materials/world/w34313520/w34313520_bay_glass.tres": "40caf8b054b51ebf247a41286dec9efdbf925f09acf698a75285a4321a41bba6",
	"res://game/scripts/world/facades/w34313520_standalone_prototypes.gd": "1244f590ed0854219f50a25a4c7931f4f094ce19fb65cefcf2d61b8ce4cd8566",
	"res://game/scenes/world/facades/batch_06/w34313520_standalone_prototype_set.tscn": "4d0ee0e79ea6fd5a7e85b21cdf4a103d125818626b6c97875737cad44cc65785",
	"res://discovery/facades/W34313520_STANDALONE_PROTOTYPE_ART_REVIEW.md": "3d778413b2ef8b93c2fb321dd76301677ea2ea1dc532862457a452a6d972f35e",
	"res://discovery/facades/W34313520_REFERENCE_SPEC.md": "b81e453fc711626422e2770a943549c380e25b533d9544cf22d7dc400f597f2f",
	"res://discovery/facades/BATCH_06_STREETVIEW_OBSERVATIONS.md": "259e562e69b1186912fce2dfb466f4512fbc69cc8e64562574971c0a8c40028b",
	"res://discovery/facades/BATCH_06_RUN_MAPPING.json": "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d",
	CHUNK_PATH: "b935890b89202fa181248552176364668e506a7630f0024ec86f12a084743d86",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://game/scripts/world/world_chunk_builder.gd": "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://game/scripts/world/facades/w34313520_live_modules.gd": "7675d651d834ac20328c12c9eb543bda1af453730cb3d8d8c8a41e899e63a8d2",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f",
	"res://game/resources/facades/batch_06_prototype_registry.json": "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132",
	"res://game/scripts/world/facades/w34313564_live_modules.gd": "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee",
	"res://game/scripts/world/facades/w34313515_live_modules.gd": "4420ad2d0a029f03da7a14fe84084d53edfa2323867a5c660c63f875c2a71ccb",
	"res://game/scripts/world/facades/w291196370_live_modules.gd": "e297d40ac9841485ee00a76b955f8ec454639b394c23759e8017e170aa84cbf8",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(_protected_hashes_match(), "A standalone asset, approved reference, exact geometry, live runtime input, or calibration artifact drifted."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var record := _record_data()
	if not _require(_registry_matches(registry, record), "Exact field scope, meter convention, single placement, inference flags, or blockers drifted.") \
	or not _require(_materials_match(registry), "The exact wall-tangent trial no longer preserves every accepted standalone field parameter.") \
	or not _require(_runtime_isolation_matches(), "The detached calibration leaked into the live builder, accepted-run helper, or a live target adapter."):
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
	if not _require(JSON.stringify(first_result.resolved_field_scope) == JSON.stringify(second_result.resolved_field_scope) \
	and JSON.stringify(first_result.resolved_placement) == JSON.stringify(second_result.resolved_placement) \
	and _geometry_signature(first) == _geometry_signature(second), "Fresh detached builds are not deterministic.") \
	or not _require(_field_geometry_matches(first, first_result.resolved_field_scope), "The exact five-run field mesh, physical span, or cross-run phase continuity failed.") \
	or not _require(_bay_geometry_matches(first, first_result.resolved_placement), "The single accepted BAY geometry, transform, containment, or zero-backing contract failed.") \
	or not _require(_standalone_bay_signature_matches(first), "Detached BAY child geometry/material identity differs from the independently accepted standalone asset."):
		first.free()
		second.free()
		_finish()
		return
	first.free()
	second.free()
	print("PASS: w34313520 detached exact-receiver calibration bytes remain deterministic and project the accepted pale field in world metres across exact SSE runs 6..10 with zero phase reset and exactly one complete backing-free BAY at the midpoint of flat run 7; every scale/coordinate/dimension/count/cadence/elevation/building claim remains explicitly unsurveyed or false while the separate reviewed live adapter stays isolated")
	_finish()


func _protected_hashes_match() -> bool:
	for file_name: String in EXPECTED_PROTECTED_HASHES:
		if FileAccess.get_sha256(file_name) != str(EXPECTED_PROTECTED_HASHES[file_name]):
			push_error("Protected file drifted: %s" % file_name)
			return false
	return true


func _registry_matches(registry: Dictionary, record: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.w34313520-detached-exact-receiver-calibration/1" \
	or str(registry.get("status", "")) != "detached_exact_receiver_calibration_ready_for_independent_art_review_not_self_accepted" \
	or not "not live attachment" in str(registry.get("evidence_role", "")):
		return false
	var target := registry.get("target", {}) as Dictionary
	if str(target.get("source_key", "")) != "w34313520" \
	or str(target.get("receiver_key", "")) != RECEIVER_KEY \
	or int(target.get("run_count", 0)) != 34 \
	or int(target.get("shared_run_count", -1)) != 0 \
	or record.get("source_keys", []) != ["w34313520"]:
		return false
	var acceptance := registry.get("standalone_acceptance", {}) as Dictionary
	if str(acceptance.get("verdict", "")) != "ACCEPT_WITH_DOCUMENTED_LIMITATION" \
	or bool(acceptance.get("correction_requested", true)) \
	or acceptance.get("eligible_assets", []) != ["W34313520-MAT-PALE", "W34313520-BAY"]:
		return false
	var field := registry.get("exact_field_scope", {}) as Dictionary
	if _int_array(field.get("exact_ordered_runs", []) as Array) != [6, 7, 8, 9, 10] \
	or str(field.get("asset_kind", "")) != "homogeneous_material_tile" \
	or not is_equal_approx(float(field.get("physical_wall_length_m", 0.0)), 68.156) \
	or (field.get("runs", []) as Array).size() != 5 \
	or str(field.get("scale_status", "")) != "production_inference_preserved_from_accepted_standalone_not_surveyed" \
	or bool(field.get("runtime_attachment", true)) \
	or bool(field.get("surveyed_scale", true)) \
	or bool(field.get("completed_elevation", true)) \
	or bool(field.get("whole_building_accepted", true)):
		return false
	var meter := field.get("meter_and_uv_contract", {}) as Dictionary
	if float(meter.get("one_godot_unit_m", 0.0)) != 1.0 \
	or not "wall_tangent" in str(meter.get("field_position_formula", "")) \
	or not "ignored" in str(meter.get("generated_uvs", "")) \
	or not "no reset" in str(meter.get("phase_rule", "")) \
	or float(meter.get("macro_review_span_m", 0.0)) < 30.0:
		return false
	var module := registry.get("module_contract", {}) as Dictionary
	if str(module.get("asset_kind", "")) != "module_atlas" \
	or not bool(module.get("complete_motif", false)) \
	or not bool(module.get("module_not_seamless_wall_tile", false)) \
	or bool(module.get("module_owns_field_geometry", true)) \
	or int(module.get("field_or_backing_meshes", -1)) != 0 \
	or int(module.get("tier_count", 0)) != 3 \
	or str(module.get("internal_mullion_cadence", "")) != "unknown_not_encoded" \
	or module.get("nominal_bounds_m", []) != [6.8, 9.4]:
		return false
	var placement_policy := registry.get("placement_policy", {}) as Dictionary
	var placement := registry.get("placement", {}) as Dictionary
	if int(placement_policy.get("placement_count", 0)) != 1 \
	or bool(placement_policy.get("runtime_attachment", true)) \
	or str(placement.get("placement_id", "")) != "CAL-SSE-BAY-01" \
	or _int_array(placement.get("exact_ordered_runs", []) as Array) != [7] \
	or int(placement.get("anchor_run", -1)) != 7 \
	or not is_equal_approx(float(placement.get("along_run_center_m", 0.0)), 15.894477) \
	or bool(placement.get("surveyed_dimensions", true)) \
	or bool(placement.get("surveyed_coordinates", true)) \
	or bool(placement.get("surveyed_count", true)) \
	or bool(placement.get("surveyed_cadence", true)) \
	or bool(placement.get("completed_elevation", true)) \
	or bool(placement.get("whole_building_accepted", true)) \
	or bool(placement.get("runtime_attachment", true)):
		return false
	var false_claims := registry.get("preserved_false_claims", {}) as Dictionary
	for key in ["surveyed_dimensions", "surveyed_coordinates", "surveyed_material_scale", "surveyed_real_bay_count", "surveyed_or_inferred_cadence", "architectural_pattern_tile", "completed_SSE_elevation", "cross_side_transfer", "whole_building_accepted", "live_attachment", "lifecycle_promotion"]:
		if bool(false_claims.get(key, true)):
			return false
	return true


func _materials_match(registry: Dictionary) -> bool:
	var field := registry.get("exact_field_scope", {}) as Dictionary
	var standalone := load(str(field.get("standalone_material_path", ""))) as ShaderMaterial
	var exact := load(str(field.get("exact_trial_material_path", ""))) as ShaderMaterial
	if standalone == null or exact == null or exact.shader == null \
	or FileAccess.get_sha256(str(field.get("exact_trial_material_path", ""))) != str(field.get("exact_trial_material_sha256", "")) \
	or FileAccess.get_sha256(str(field.get("shader_path", ""))) != str(field.get("shader_sha256", "")):
		return false
	for parameter in ["base_color", "secondary_color", "roughness_value", "field_kind", "primary_scale_m", "secondary_scale_m", "relief_strength", "color_variation", "filter_start_cycles_per_pixel", "filter_end_cycles_per_pixel"]:
		if standalone.get_shader_parameter(parameter) != exact.get_shader_parameter(parameter):
			return false
	var shader_source := FileAccess.get_file_as_string(str(field.get("shader_path", "")))
	return "dot(VERTEX.xz, wall_tangent)" in shader_source \
		and "VERTEX.y" in shader_source \
		and "fwidth(" in shader_source \
		and not "sampler2D" in shader_source \
		and not "TIME" in shader_source


func _field_geometry_matches(root_node: Node3D, resolved_scope: Dictionary) -> bool:
	var field := root_node.get_node_or_null("DetachedExactSSEFieldRuns06To10") as MeshInstance3D
	if field == null or not field.mesh is ArrayMesh \
	or field.material_override.resource_path != "res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres" \
	or field.get_meta("exact_ordered_runs", []) != [6, 7, 8, 9, 10] \
	or field.mesh.get_surface_count() != 1:
		return false
	var arrays := field.mesh.surface_get_arrays(0)
	if (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() != 20 \
	or (arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array).size() != 20 \
	or (arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array).size() != 20 \
	or (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() != 30 \
	or int(resolved_scope.get("triangles", 0)) != 10 \
	or float(resolved_scope.get("maximum_junction_phase_delta_m", 1.0)) > 0.0001:
		return false
	var run_records := resolved_scope.get("run_records", []) as Array
	if run_records.size() != 5:
		return false
	var lengths := [25.045, 31.789, 4.494, 3.915, 2.913]
	for index in 5:
		var run := run_records[index] as Dictionary
		if int(run.get("run_index", -1)) != index + 6 \
		or absf(float(run.get("length_m", 0.0)) - float(lengths[index])) > 0.001:
			return false
	return true


func _bay_geometry_matches(root_node: Node3D, resolved: Dictionary) -> bool:
	var bay := root_node.get_node_or_null("CAL_SSE_BAY_01") as Node3D
	if bay == null \
	or str(bay.get_meta("asset_kind", "")) != "module_atlas" \
	or not bool(bay.get_meta("complete_motif", false)) \
	or bool(bay.get_meta("module_owns_field_geometry", true)) \
	or bay.get_meta("exact_ordered_runs", []) != [7] \
	or _count_meshes(bay) != 15 \
	or _count_surfaces(bay) != 15 \
	or _count_triangles(bay) != 180:
		return false
	for child in bay.get_children():
		if child is MeshInstance3D:
			var lower_name := str(child.name).to_lower()
			if "field" in lower_name or "backing" in lower_name or "surround" in lower_name or "pier" in lower_name \
			or (child as MeshInstance3D).material_override is ShaderMaterial:
				return false
	var origin := _vector3(resolved.get("module_origin_world_m", []) as Array)
	var expected := Vector3(-145.95374, 8.415, 107.50892)
	return origin.distance_to(expected) < 0.0002 \
		and int(resolved.get("anchor_run", -1)) == 7 \
		and absf(float(resolved.get("anchor_run_fraction", 0.0)) - 0.5) < 0.00001 \
		and _count_meshes(root_node) == 16 \
		and _count_surfaces(root_node) == 16 \
		and _count_triangles(root_node) == 190 \
		and _count_type(root_node, CollisionObject3D) == 0 \
		and _count_type(root_node, CollisionShape3D) == 0 \
		and _count_type(root_node, NavigationRegion3D) == 0


func _standalone_bay_signature_matches(detached_root: Node3D) -> bool:
	var packed := load("res://game/scenes/world/facades/batch_06/w34313520_standalone_prototype_set.tscn") as PackedScene
	var standalone := packed.instantiate() as Node3D
	standalone.call("_build")
	var standalone_bay := standalone.get_node("PrototypeGeometry/W34313520_BAY") as Node3D
	var detached_bay := detached_root.get_node("CAL_SSE_BAY_01") as Node3D
	var matches := _module_child_signature(standalone_bay) == _module_child_signature(detached_bay)
	standalone.free()
	return matches


func _runtime_isolation_matches() -> bool:
	if not FileAccess.file_exists("res://game/scripts/world/facades/w34313520_live_modules.gd"):
		return false
	var builder := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	var accepted := FileAccess.get_file_as_string("res://game/scripts/world/facades/accepted_material_run_trials.gd")
	if "w34313520_live_modules.gd" not in builder or "W34313520-MAT-PALE" not in accepted:
		return false
	for marker in ["w34313520_exact_receiver_calibration.gd", "CAL-SSE-BAY-01"]:
		if marker in builder:
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
		var mesh_instance := node as MeshInstance3D
		var mesh := mesh_instance.mesh
		var size := Vector3.ZERO
		if mesh is BoxMesh:
			size = (mesh as BoxMesh).size
		var transform_value := mesh_instance.transform if include_global_transform else Transform3D(Basis.IDENTITY, mesh_instance.position)
		records.append("%s|%s|%s|%s|%s" % [str(node.name), str(transform_value), str(size), str(mesh_instance.material_override.resource_path), str(mesh.get_surface_count())])
	for child in node.get_children():
		_collect_geometry(child, records, include_global_transform)


func _count_meshes(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _count_meshes(child)
	return count


func _count_surfaces(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		count += (node as MeshInstance3D).mesh.get_surface_count()
	for child in node.get_children():
		count += _count_surfaces(child)
	return count


func _count_triangles(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		count += (node as MeshInstance3D).mesh.get_faces().size() / 3
	for child in node.get_children():
		count += _count_triangles(child)
	return count


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child in node.get_children():
		count += _count_type(child, node_type)
	return count


func _vector3(values: Array) -> Vector3:
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _free_result(result: Dictionary) -> void:
	if bool(result.get("ok", false)) and result.get("node") is Node:
		(result.node as Node).free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
