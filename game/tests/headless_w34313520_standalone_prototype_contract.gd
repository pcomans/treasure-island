extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/w34313520_standalone_prototypes.json"
const EXPECTED_REGISTRY_SHA256 := "ab80f0cd0424c22f7f24e5fc82211353e9aee7c95bea4903022681a48c5620a4"
const EXPECTED_ASSET_HASHES := {
	"res://game/resources/materials/world/w34313520/w34313520_pale_field.tres": "7944151fd5ab8e977e7052d0cdb8df20132c82f967d8ebfefff83ede8fcf07a4",
	"res://game/resources/materials/world/w34313520/w34313520_bay_frame.tres": "445d3bec9d2ef3130aab27c816b27e384c689af68298b2db5ada37e0178f249b",
	"res://game/resources/materials/world/w34313520/w34313520_bay_glass.tres": "40caf8b054b51ebf247a41286dec9efdbf925f09acf698a75285a4321a41bba6",
	"res://game/scripts/world/facades/w34313520_standalone_prototypes.gd": "1244f590ed0854219f50a25a4c7931f4f094ce19fb65cefcf2d61b8ce4cd8566",
	"res://game/scenes/world/facades/batch_06/w34313520_standalone_prototype_set.tscn": "4d0ee0e79ea6fd5a7e85b21cdf4a103d125818626b6c97875737cad44cc65785",
}
const EXPECTED_SOURCE_AND_ISOLATION_HASHES := {
	"res://discovery/facades/W34313520_REFERENCE_SPEC.md": "b81e453fc711626422e2770a943549c380e25b533d9544cf22d7dc400f597f2f",
	"res://discovery/facades/BATCH_06_STREETVIEW_OBSERVATIONS.md": "259e562e69b1186912fce2dfb466f4512fbc69cc8e64562574971c0a8c40028b",
	"res://discovery/facades/BATCH_06_RUN_MAPPING.json": "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d",
	"res://game/resources/facades/batch_06_prototype_registry.json": "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132",
	"res://discovery/FACADE_RECEIVER_INVENTORY.json": "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://generated/world/chunks/x_-1__z_0.json": "b935890b89202fa181248552176364668e506a7630f0024ec86f12a084743d86",
	"res://game/scripts/world/world_chunk_builder.gd": "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://game/scripts/world/facades/w34313520_live_modules.gd": "7675d651d834ac20328c12c9eb543bda1af453730cb3d8d8c8a41e899e63a8d2",
	"res://game/scripts/world/facades/w34313564_live_modules.gd": "5d0d7816a87e13907d571aaceb2d4af3c01980fd26a043e33d87e9b07f2b71ee",
	"res://game/scripts/world/facades/w34313515_live_modules.gd": "4420ad2d0a029f03da7a14fe84084d53edfa2323867a5c660c63f875c2a71ccb",
	"res://game/scripts/world/facades/w291196370_live_modules.gd": "e297d40ac9841485ee00a76b955f8ec454639b394c23759e8017e170aa84cbf8",
}
const EXPECTED_SCENE_PATH := "res://game/scenes/world/facades/batch_06/w34313520_standalone_prototype_set.tscn"
const FIELD_ID := "W34313520-MAT-PALE"
const BAY_ID := "W34313520-BAY"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "w34313520 standalone registry bytes drifted.") \
	or not _require(_hashes_match(EXPECTED_ASSET_HASHES), "A w34313520 standalone asset drifted.") \
	or not _require(_hashes_match(EXPECTED_SOURCE_AND_ISOLATION_HASHES), "An authoritative source, live runtime input, generated record, prior prototype registry, or canonical inventory drifted."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	if not _require(_registry_contract_matches(registry), "Classification, evidence boundary, inference labels, or blocked-claim contract failed.") \
	or not _require(_material_contract_matches(registry), "The pale field lost its opaque, meter-space, motif-free aperiodic contract.") \
	or not _require(_runtime_isolation_matches(), "The standalone package leaked into live runtime or created a calibration/live helper."):
		_finish()
		return
	var packed := load(EXPECTED_SCENE_PATH) as PackedScene
	if not _require(packed != null, "The w34313520 standalone scene did not load."):
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
	print("PASS: w34313520 retains exactly one byte-stable isolated 30 m motif-free pale homogeneous field and one complete 15-mesh three-tier BAY module-atlas prototype; both remain stylized unmeasured SSE-only standalone inferences with zero backing/collision/navigation/spray/generated ownership while the separately reviewed exact field and single live BAY adapter remain isolated")
	_finish()


func _registry_contract_matches(registry: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.w34313520-standalone-prototypes/1" \
	or str(registry.get("source_key", "")) != "w34313520" \
	or str(registry.get("receiver_key", "")) != "building:w34313520:wall" \
	or str(registry.get("review_status", "")) != "ready_for_independent_standalone_art_review_not_self_accepted" \
	or bool(registry.get("runtime_attachment", true)) \
	or bool(registry.get("exact_receiver_calibration", true)) \
	or int(registry.get("live_placement_count", -1)) != 0:
		return false
	var kinds := registry.get("asset_kind_inventory", {}) as Dictionary
	if int(kinds.get("homogeneous_material_tile", -1)) != 1 \
	or int(kinds.get("architectural_pattern_tile", -1)) != 0 \
	or int(kinds.get("module_atlas", -1)) != 1 \
	or int(kinds.get("unique_elevation", -1)) != 0:
		return false
	var eligible := (registry.get("decision_basis", {}) as Dictionary).get("eligible_region_not_placement", {}) as Dictionary
	if eligible.get("ordered_run_indices", []) != [6.0, 7.0, 8.0, 9.0, 10.0] \
	or not is_equal_approx(float(eligible.get("mapped_length_m", 0.0)), 68.156) \
	or str(eligible.get("placement_coordinates", "")) != "none" \
	or str(eligible.get("cadence", "")) != "unknown_not_encoded":
		return false
	var receiver := registry.get("receiver_audit", {}) as Dictionary
	if int(receiver.get("exterior_run_count", 0)) != 34 \
	or not is_equal_approx(float(receiver.get("height_m", 0.0)), 11.0) \
	or not is_equal_approx(float(receiver.get("perimeter_m", 0.0)), 376.239) \
	or int(receiver.get("mapped_run_count", 0)) != 5 \
	or int(receiver.get("protected_run_count", 0)) != 2:
		return false
	var materials := registry.get("materials", []) as Array
	var modules := registry.get("modules", []) as Array
	if materials.size() != 1 or modules.size() != 1:
		return false
	var field := materials[0] as Dictionary
	var bay := modules[0] as Dictionary
	if str(field.get("id", "")) != FIELD_ID \
	or str(field.get("asset_kind", "")) != "homogeneous_material_tile" \
	or bool(field.get("surveyed_color", true)) \
	or bool(field.get("surveyed_finish_scale", true)) \
	or bool(field.get("runtime_attachment", true)) \
	or bool((field.get("repeat_contract", {}) as Dictionary).get("contains_facade_scale_motifs", true)) \
	or str((field.get("repeat_contract", {}) as Dictionary).get("finite_facade_motif_period", "")) != "none_by_design":
		return false
	if str(bay.get("motif_id", "")) != BAY_ID \
	or str(bay.get("asset_kind", "")) != "module_atlas" \
	or not bool(bay.get("complete_motif", false)) \
	or not bool(bay.get("module_not_seamless_wall_tile", false)) \
	or bool(bay.get("opposite_edge_continuity_required", true)) \
	or bool(bay.get("module_owns_field_geometry", true)) \
	or int(bay.get("module_owned_backing_meshes", -1)) != 0 \
	or int(bay.get("tier_count", 0)) != 3 \
	or str(bay.get("internal_mullion_cadence", "")) != "unknown_not_encoded" \
	or bool(bay.get("surveyed_dimensions", true)) \
	or bool(bay.get("surveyed_coordinates", true)) \
	or bool(bay.get("surveyed_count", true)) \
	or bool(bay.get("surveyed_cadence", true)) \
	or bool(bay.get("runtime_attachment", true)):
		return false
	var blocked_text := JSON.stringify(registry.get("blocked_claims", [])).to_lower()
	for phrase in ["exact receiver placement", "architectural pattern", "complete sse elevation", "runs 20 and 21", "all ene, wsw and nnw", "whole-building"]:
		if not phrase in blocked_text:
			return false
	return true


func _material_contract_matches(registry: Dictionary) -> bool:
	var field_record := (registry.get("materials", []) as Array)[0] as Dictionary
	var material := load(str(field_record.get("path", ""))) as ShaderMaterial
	if material == null or material.shader == null \
	or (material.get_shader_parameter("base_color") as Color).a != 1.0 \
	or float(material.get_shader_parameter("roughness_value")) != 0.8 \
	or float(material.get_shader_parameter("primary_scale_m")) != 0.95 \
	or float(material.get_shader_parameter("filter_start_cycles_per_pixel")) >= float(material.get_shader_parameter("filter_end_cycles_per_pixel")):
		return false
	var shader_source := FileAccess.get_file_as_string(str(field_record.get("shader_path", "")))
	if FileAccess.get_sha256(str(field_record.get("shader_path", ""))) != str(field_record.get("shader_sha256", "")) \
	or not "render_mode depth_draw_opaque, cull_back" in shader_source \
	or not "field_position_m = VERTEX.xy" in shader_source \
	or not "fwidth(" in shader_source:
		return false
	for forbidden in ["sampler2D", "TIME", "SCREEN_TEXTURE", "discard", "ALPHA ="]:
		if forbidden in shader_source:
			return false
	return true


func _scene_contract_matches(instance: Node3D) -> bool:
	if not bool(instance.get_meta("prototype_only", false)) \
	or bool(instance.get_meta("runtime_attachment", true)) \
	or bool(instance.get_meta("exact_receiver_calibration", true)):
		return false
	var geometry := instance.get_node_or_null("PrototypeGeometry") as Node3D
	if geometry == null \
	or bool(geometry.get_meta("runtime_attachment", true)) \
	or str(geometry.get_meta("calibration_state", "")) != "not_started" \
	or geometry.get_meta("eligible_run_indices_not_placements", []) != [6, 7, 8, 9, 10] \
	or geometry.get_meta("proof_dimensions_m", Vector2.ZERO) != Vector2(30.0, 11.0):
		return false
	var host := geometry.get_node_or_null("ContinuousPaleHostFieldProof") as MeshInstance3D
	var bay := geometry.get_node_or_null("W34313520_BAY") as Node3D
	if host == null or not host.material_override is ShaderMaterial or bay == null:
		return false
	if str(bay.get_meta("asset_kind", "")) != "module_atlas" \
	or not bool(bay.get_meta("complete_motif", false)) \
	or not bool(bay.get_meta("module_not_seamless_tile", false)) \
	or bool(bay.get_meta("module_owns_field_geometry", true)) \
	or int(bay.get_meta("module_owned_backing_meshes", -1)) != 0 \
	or str(bay.get_meta("placement_state", "")) != "none_standalone_only" \
	or str(bay.get_meta("cadence_status", "")) != "unknown_not_encoded":
		return false
	if _count_meshes(geometry) != 16 or _count_surfaces(geometry) != 16 or _count_triangles(geometry) != 192 \
	or _count_meshes(bay) != 15 or _count_surfaces(bay) != 15 or _count_triangles(bay) != 180 \
	or _count_named_meshes(bay, "MutedGlazing") != 3 or _count_named_meshes(bay, "Frame") != 12:
		return false
	for child in bay.get_children():
		if child is MeshInstance3D:
			var lower_name := str(child.name).to_lower()
			if "field" in lower_name or "backing" in lower_name or "surround" in lower_name or "pier" in lower_name \
			or (child as MeshInstance3D).material_override is ShaderMaterial:
				return false
	return _count_type(geometry, CollisionObject3D) == 0 \
		and _count_type(geometry, CollisionShape3D) == 0 \
		and _count_type(geometry, NavigationRegion3D) == 0


func _runtime_isolation_matches() -> bool:
	if not FileAccess.file_exists("res://game/scripts/world/facades/w34313520_live_modules.gd") \
	or FileAccess.file_exists("res://game/resources/facades/w34313520_module_calibration.json"):
		return false
	var builder := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	var accepted := FileAccess.get_file_as_string("res://game/scripts/world/facades/accepted_material_run_trials.gd")
	if "w34313520_live_modules.gd" not in builder or "building:w34313520:wall" not in accepted:
		return false
	for leaked in ["w34313520_standalone_prototype_set.tscn", "w34313520_standalone_prototypes.gd"]:
		if leaked in builder or leaked in accepted:
			return false
	return true


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
		var mesh := mesh_instance.mesh
		var size := Vector3.ZERO
		if mesh is BoxMesh:
			size = (mesh as BoxMesh).size
		records.append("%s|%.6f,%.6f,%.6f|%.6f,%.6f,%.6f|%s" % [str(node.get_path()), mesh_instance.position.x, mesh_instance.position.y, mesh_instance.position.z, size.x, size.y, size.z, str(mesh_instance.material_override.resource_path)])
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
