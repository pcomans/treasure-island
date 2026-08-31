extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/w34313525_standalone_prototypes.json"
const EXPECTED_REGISTRY_SHA256 := "86d3634e62f367f24bef98206fe1e6f34124023f0d9672bbd318c45c0a33b170"
const EXPECTED_SCENE_PATH := "res://game/scenes/world/facades/batch_06/w34313525_standalone_prototype_set.tscn"
const EXPECTED_ASSET_HASHES := {
	"res://game/resources/materials/world/w34313525/w34313525_pale_field.tres": "00ad40bbc932d7b7d4a3ce77d13a3798f25a35e908bd45a1a5f7f38ba4c80eff",
	"res://game/resources/materials/world/w34313525/w34313525_frame.tres": "2298f55a4129757eb69af498236e609384acb1565a2c0654e8200bc79e0ae21e",
	"res://game/resources/materials/world/w34313525/w34313525_rollup_pale.tres": "ded6d1de11ce4e77c71ee384be689257707c522718c9f8fad20fb3d1933fee47",
	"res://game/resources/materials/world/w34313525/w34313525_rollup_gray.tres": "b0beeb8e0cf894e3cafd8f7084e0d235074b67daf29c2a863f514d5386173b8a",
	"res://game/resources/materials/world/w34313525/w34313525_personnel.tres": "bcc6295ffe9229f6b7105c13896f0ff0cfcd5d3227e3b30046d9957c2272a88f",
	"res://game/resources/materials/world/w34313525/w34313525_high_group.tres": "68f56c35a7e2ef870dd395e5f2e38b8cc5d640b532de32339ae4b22ffbabadfb",
	"res://game/scripts/world/facades/w34313525_standalone_prototypes.gd": "a8e432b8cae545532aa976b095e2dc012454dd73648dccf09d55be550ccbcc76",
	"res://game/scenes/world/facades/batch_06/w34313525_standalone_prototype_set.tscn": "9259ab6f231fee7d3d3ad8bfea0a290a455b1490b291a1d05b7cd64df4965cbe",
	"res://game/tests/w34313525_standalone_prototype_capture.gd": "29b99ae3c159aceb79b4037a9419d80ec233b6ab0f018bc3d2bcabf19cb0b538",
}
const EXPECTED_SOURCE_AND_ISOLATION_HASHES := {
	"res://discovery/facades/W34313525_REFERENCE_SPEC.md": "c373708e12ef4aefaabfd678ac8aad455e0a846f9d833c710f569b39fdb1ab42",
	"res://discovery/facades/BATCH_06_STREETVIEW_OBSERVATIONS.md": "259e562e69b1186912fce2dfb466f4512fbc69cc8e64562574971c0a8c40028b",
	"res://discovery/facades/BATCH_06_REFERENCE_INDEX.md": "3808ca452c4ef3ed970a2d2a8d73077353160bc60d6847e5919aefc57a22d9ef",
	"res://discovery/facades/BATCH_06_RUN_MAPPING.json": "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d",
	"res://game/resources/facades/batch_06_prototype_registry.json": "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://generated/world/chunks/x_1__z_-1.json": "a952756b1c6d8d547669dffb89723c2be81d6c9a4b3afd2ae7f2dc3702a82b0d",
	"res://game/scripts/world/world_chunk_builder.gd": "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://game/scripts/world/facades/w34313525_live_modules.gd": "f9b31302eaf98fd4185aed4f28d3651794e2e50958ad2641c04aec0dd45f05e1",
	"res://game/scripts/world/facades/w34313520_live_modules.gd": "7675d651d834ac20328c12c9eb543bda1af453730cb3d8d8c8a41e899e63a8d2",
	"res://game/scripts/world/facades/w34313564_live_modules.gd": "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee",
	"res://game/scripts/world/facades/w34313515_live_modules.gd": "4420ad2d0a029f03da7a14fe84084d53edfa2323867a5c660c63f875c2a71ccb",
	"res://game/scripts/world/facades/w291196370_live_modules.gd": "e297d40ac9841485ee00a76b955f8ec454639b394c23759e8017e170aa84cbf8",
}
const MODULE_EXPECTATIONS := {
	"W34313525_ROLLUP_PALE": {"id": "W34313525-ROLLUP-PALE", "meshes": 13, "triangles": 156, "leaf": 1, "frame": 4, "slat": 8},
	"W34313525_ROLLUP_GRAY": {"id": "W34313525-ROLLUP-GRAY", "meshes": 13, "triangles": 156, "leaf": 1, "frame": 4, "slat": 8},
	"W34313525_PERSONNEL": {"id": "W34313525-PERSONNEL", "meshes": 5, "triangles": 60, "leaf": 1, "frame": 4, "slat": 0},
	"W34313525_HIGH_GROUP": {"id": "W34313525-HIGH-GROUP", "meshes": 7, "triangles": 84, "leaf": 1, "frame": 4, "slat": 0},
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "w34313525 standalone registry bytes drifted.") \
	or not _require(_hashes_match(EXPECTED_ASSET_HASHES), "A w34313525 standalone asset drifted.") \
	or not _require(_hashes_match(EXPECTED_SOURCE_AND_ISOLATION_HASHES), "An authoritative source, prior accepted runtime input, generated record, or canonical inventory drifted."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	if not _require(_registry_contract_matches(registry), "Classification, evidence boundary, inference labels, capture status, or blocked-claim contract failed.") \
	or not _require(_material_contract_matches(registry), "The pale field lost its opaque, meter-space, motif-free aperiodic contract.") \
	or not _require(_bounded_live_integration_matches(), "Current live integration is not the exact reviewed field/module adapter or leaked standalone proof geometry."):
		_finish()
		return
	var packed := load(EXPECTED_SCENE_PATH) as PackedScene
	if not _require(packed != null, "The w34313525 standalone scene did not load."):
		_finish()
		return
	var first := packed.instantiate() as Node3D
	root.add_child(first)
	await process_frame
	if not _require(_scene_contract_matches(first), "Standalone geometry, topology, module completeness, or zero-backing contract failed."):
		first.queue_free()
		_finish()
		return
	var first_signature := _geometry_signature(first)
	first.queue_free()
	await process_frame
	var second := packed.instantiate() as Node3D
	root.add_child(second)
	await process_frame
	var second_signature := _geometry_signature(second)
	if not _require(first_signature == second_signature, "Two fresh scene instances produced different deterministic geometry signatures.") \
	or not _require(_scene_contract_matches(second), "The repeated standalone scene instance failed its contract."):
		second.queue_free()
		_finish()
		return
	second.queue_free()
	print("PASS: w34313525 retains exactly one isolated 30 m motif-free pale homogeneous field and four complete standalone module-atlas motifs at deterministic 39/39/468 topology; every scale and placement remains unsurveyed production inference, modules own zero backing/collision/navigation/spray, immutable standalone bytes are preserved, and current runtime contains only the separately reviewed exact field/module adapter")
	_finish()


func _registry_contract_matches(registry: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.w34313525-standalone-prototypes/1" \
	or str(registry.get("source_key", "")) != "w34313525" \
	or str(registry.get("receiver_key", "")) != "building:w34313525:wall" \
	or str(registry.get("review_status", "")) != "native_capture_pending_owner_session" \
	or bool(registry.get("runtime_attachment", true)) \
	or bool(registry.get("exact_receiver_calibration", true)) \
	or int(registry.get("live_placement_count", -1)) != 0:
		return false
	var kinds := registry.get("asset_kind_inventory", {}) as Dictionary
	if int(kinds.get("homogeneous_material_tile", -1)) != 1 \
	or int(kinds.get("architectural_pattern_tile", -1)) != 0 \
	or int(kinds.get("module_atlas", -1)) != 4 \
	or int(kinds.get("unique_elevation", -1)) != 0:
		return false
	var receiver := registry.get("receiver_audit", {}) as Dictionary
	if int(receiver.get("exterior_run_count", 0)) != 30 \
	or not is_equal_approx(float(receiver.get("height_m", 0.0)), 5.0) \
	or not is_equal_approx(float(receiver.get("perimeter_m", 0.0)), 354.736) \
	or int(receiver.get("mapped_run_count", 0)) != 7 \
	or int(receiver.get("unmapped_run_count", 0)) != 15 \
	or int(receiver.get("protected_run_count", 0)) != 8:
		return false
	var regions := (registry.get("decision_basis", {}) as Dictionary).get("observed_regions", []) as Array
	if regions.size() != 2 \
	or (regions[0] as Dictionary).get("ordered_run_indices", []) != [8.0, 9.0, 10.0, 11.0, 12.0] \
	or (regions[1] as Dictionary).get("ordered_run_indices", []) != [26.0, 27.0] \
	or str((registry.get("decision_basis", {}) as Dictionary).get("cadence", "")) != "unknown_not_encoded":
		return false
	var materials := registry.get("materials", []) as Array
	var modules := registry.get("modules", []) as Array
	if materials.size() != 1 or modules.size() != 4:
		return false
	var scene_record := registry.get("prototype_scene", {}) as Dictionary
	if str(scene_record.get("native_capture_status", "")) != "native_capture_pending_owner_session" \
	or str(scene_record.get("native_capture_harness_path", "")) != "res://game/tests/w34313525_standalone_prototype_capture.gd":
		return false
	var field := materials[0] as Dictionary
	if str(field.get("id", "")) != "W34313525-MAT-PALE" \
	or str(field.get("asset_kind", "")) != "homogeneous_material_tile" \
	or bool(field.get("surveyed_color", true)) \
	or bool(field.get("surveyed_finish_scale", true)) \
	or bool(field.get("runtime_attachment", true)) \
	or bool((field.get("repeat_contract", {}) as Dictionary).get("contains_facade_scale_motifs", true)) \
	or bool((field.get("repeat_contract", {}) as Dictionary).get("contains_repair_patch_motifs", true)) \
	or str((field.get("repeat_contract", {}) as Dictionary).get("finite_facade_motif_period", "")) != "none_by_design":
		return false
	var seen: Array[String] = []
	for module_value: Variant in modules:
		var module := module_value as Dictionary
		var motif_id := str(module.get("motif_id", ""))
		seen.append(motif_id)
		if str(module.get("asset_kind", "")) != "module_atlas" \
		or not bool(module.get("complete_motif", false)) \
		or not bool(module.get("module_not_seamless_wall_tile", false)) \
		or bool(module.get("opposite_edge_continuity_required", true)) \
		or bool(module.get("module_owns_field_geometry", true)) \
		or int(module.get("module_owned_backing_meshes", -1)) != 0 \
		or int(module.get("module_owned_collision_nodes", -1)) != 0 \
		or int(module.get("module_owned_navigation_nodes", -1)) != 0 \
		or int(module.get("module_owned_spray_nodes", -1)) != 0 \
		or bool(module.get("surveyed_dimensions", true)) \
		or bool(module.get("surveyed_coordinates", true)) \
		or bool(module.get("surveyed_count", true)) \
		or bool(module.get("surveyed_cadence", true)) \
		or bool(module.get("runtime_attachment", true)):
			return false
	seen.sort()
	if seen != ["W34313525-HIGH-GROUP", "W34313525-PERSONNEL", "W34313525-ROLLUP-GRAY", "W34313525-ROLLUP-PALE"]:
		return false
	var blocked_text := JSON.stringify(registry.get("blocked_claims", [])).to_lower()
	for phrase in ["exact receiver placement", "architectural pattern", "repair patches", "projecting eave", "ene and wsw", "completed sse or nnw", "whole-building", "native art acceptance"]:
		if phrase not in blocked_text:
			return false
	return true


func _material_contract_matches(registry: Dictionary) -> bool:
	var field_record := (registry.get("materials", []) as Array)[0] as Dictionary
	var material := load(str(field_record.get("path", ""))) as ShaderMaterial
	if material == null or material.shader == null \
	or (material.get_shader_parameter("base_color") as Color).a != 1.0 \
	or float(material.get_shader_parameter("roughness_value")) != 0.82 \
	or float(material.get_shader_parameter("primary_scale_m")) != 0.88 \
	or float(material.get_shader_parameter("secondary_scale_m")) != 0.31 \
	or float(material.get_shader_parameter("filter_start_cycles_per_pixel")) >= float(material.get_shader_parameter("filter_end_cycles_per_pixel")):
		return false
	var shader_path := str(field_record.get("shader_path", ""))
	var shader_source := FileAccess.get_file_as_string(shader_path)
	if FileAccess.get_sha256(shader_path) != str(field_record.get("shader_sha256", "")) \
	or "render_mode depth_draw_opaque, cull_back" not in shader_source \
	or "field_position_m = VERTEX.xy" not in shader_source \
	or "fwidth(" not in shader_source:
		return false
	for forbidden in ["sampler2D", "TIME", "SCREEN_TEXTURE", "discard", "ALPHA ="]:
		if forbidden in shader_source:
			return false
	for path in [
		"res://game/resources/materials/world/w34313525/w34313525_frame.tres",
		"res://game/resources/materials/world/w34313525/w34313525_rollup_pale.tres",
		"res://game/resources/materials/world/w34313525/w34313525_rollup_gray.tres",
		"res://game/resources/materials/world/w34313525/w34313525_personnel.tres",
		"res://game/resources/materials/world/w34313525/w34313525_high_group.tres",
	]:
		var standard := load(path) as StandardMaterial3D
		if standard == null or standard.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED or standard.albedo_color.a != 1.0:
			return false
	return true


func _scene_contract_matches(instance: Node3D) -> bool:
	if not bool(instance.get_meta("prototype_only", false)) \
	or bool(instance.get_meta("runtime_attachment", true)) \
	or bool(instance.get_meta("exact_receiver_calibration", true)) \
	or str(instance.get_meta("native_capture_status", "")) != "native_capture_pending_owner_session":
		return false
	var geometry := instance.get_node_or_null("PrototypeGeometry") as Node3D
	if geometry == null \
	or bool(geometry.get_meta("runtime_attachment", true)) \
	or bool(geometry.get_meta("exact_receiver_calibration", true)) \
	or str(geometry.get_meta("native_capture_status", "")) != "native_capture_pending_owner_session" \
	or geometry.get_meta("eligible_run_indices_not_placements", []) != [8, 9, 10, 11, 12, 26, 27] \
	or geometry.get_meta("proof_dimensions_m", Vector2.ZERO) != Vector2(30.0, 5.0):
		return false
	var host := geometry.get_node_or_null("ContinuousAgedPaleHostFieldProof") as MeshInstance3D
	if host == null or not host.material_override is ShaderMaterial:
		return false
	if _count_meshes(geometry) != 39 or _count_surfaces(geometry) != 39 or _count_triangles(geometry) != 468:
		return false
	for node_name: Variant in MODULE_EXPECTATIONS:
		var module := geometry.get_node_or_null(str(node_name)) as Node3D
		var expected := MODULE_EXPECTATIONS[node_name] as Dictionary
		if module == null \
		or str(module.get_meta("motif_id", "")) != str(expected.get("id", "")) \
		or str(module.get_meta("asset_kind", "")) != "module_atlas" \
		or not bool(module.get_meta("complete_motif", false)) \
		or not bool(module.get_meta("module_not_seamless_tile", false)) \
		or bool(module.get_meta("opposite_edge_continuity_required", true)) \
		or bool(module.get_meta("module_owns_field_geometry", true)) \
		or int(module.get_meta("module_owned_backing_meshes", -1)) != 0 \
		or str(module.get_meta("placement_state", "")) != "none_standalone_only" \
		or str(module.get_meta("count_status", "")) != "unknown_not_encoded" \
		or str(module.get_meta("cadence_status", "")) != "unknown_not_encoded" \
		or bool(module.get_meta("surveyed_dimensions", true)) \
		or bool(module.get_meta("surveyed_coordinates", true)) \
		or _count_meshes(module) != int(expected.get("meshes", 0)) \
		or _count_surfaces(module) != int(expected.get("meshes", 0)) \
		or _count_triangles(module) != int(expected.get("triangles", 0)) \
		or _count_named_meshes(module, "Frame") != int(expected.get("frame", 0)):
			return false
		if "ROLLUP" in str(node_name) and (_count_named_meshes(module, "Leaf") != 1 or _count_named_meshes(module, "Slat") != 8):
			return false
		for child in module.get_children():
			if child is MeshInstance3D:
				var lower_name := str(child.name).to_lower()
				if "field" in lower_name or "backing" in lower_name or "surround" in lower_name or "repair" in lower_name \
				or (child as MeshInstance3D).material_override is ShaderMaterial:
					return false
	return _count_type(geometry, CollisionObject3D) == 0 \
		and _count_type(geometry, CollisionShape3D) == 0 \
		and _count_type(geometry, NavigationRegion3D) == 0 \
		and _count_type(geometry, Decal) == 0


func _bounded_live_integration_matches() -> bool:
	if FileAccess.file_exists("res://game/resources/facades/w34313525_module_calibration.json") \
	or FileAccess.file_exists("res://game/resources/facades/w34313525_live_modules.json"):
		return false
	var builder := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	var accepted := FileAccess.get_file_as_string("res://game/scripts/world/facades/accepted_material_run_trials.gd")
	return "w34313525_standalone_prototype_set.tscn" not in builder \
		and "w34313525_standalone_prototypes.gd" not in builder \
		and "w34313525_standalone_prototype_set.tscn" not in accepted \
		and "w34313525_standalone_prototypes.gd" not in accepted \
		and "w34313525_live_modules.gd" in builder \
		and "building:w34313525:wall" in accepted \
		and "trial_w34313525_pale_sse_runs" in accepted \
		and "trial_w34313525_pale_nnw_runs" in accepted


func _hashes_match(expected: Dictionary) -> bool:
	for path_value: Variant in expected:
		var path := str(path_value)
		if FileAccess.get_sha256(path) != str(expected[path_value]):
			return false
	return true


func _geometry_signature(node: Node) -> String:
	var records: Array[String] = []
	_collect_geometry_records(node, records)
	records.sort()
	return JSON.stringify(records).sha256_text()


func _collect_geometry_records(node: Node, records: Array[String]) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var size := Vector3.ZERO
		if mesh_instance.mesh is BoxMesh:
			size = (mesh_instance.mesh as BoxMesh).size
		records.append("%s|%.6f,%.6f,%.6f|%.6f,%.6f,%.6f|%s" % [str(node.get_path()), mesh_instance.global_position.x, mesh_instance.global_position.y, mesh_instance.global_position.z, size.x, size.y, size.z, str(mesh_instance.material_override.resource_path)])
	for child in node.get_children():
		_collect_geometry_records(child, records)


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


func _count_named_meshes(node: Node, fragment: String) -> int:
	var count := 1 if node is MeshInstance3D and fragment in str(node.name) else 0
	for child in node.get_children():
		count += _count_named_meshes(child, fragment)
	return count


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child in node.get_children():
		count += _count_type(child, node_type)
	return count


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
