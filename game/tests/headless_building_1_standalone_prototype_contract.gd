extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/building_1_standalone_prototypes.json"
const EXPECTED_REGISTRY_SHA256 := "2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc"
const SCENE_PATH := "res://game/scenes/world/facades/building_1/building_1_standalone_prototype_set.tscn"
const CURRENT_RUNTIME_REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const CURRENT_RUNTIME_REGISTRY_SHA256 := "9c46c1a8c809aa9ded82008d35e9c1b257070e9c61f6d6e41f5650ca7b1c3f27"
const EXPECTED_HASHES := {
	"res://game/resources/materials/world/building_1/building_1_warm_ivory.tres": "572c3165cec91f74a49066873c31c071ae02333f85721bbd6b43981d814cdabb",
	"res://game/resources/materials/world/building_1/building_1_light_trim.tres": "6e543d57ff078c267e952f633f4cee232e0743e30218d2f341dc3f31e4a4c8d9",
	"res://game/resources/materials/world/building_1/building_1_rose_base.tres": "dd0ad6a95267c6be55ae415d8e044847b3ac53b7c1fceb823b12bb1a4fe44514",
	"res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres": "41c1c31d4a78da25d4abfac59e82fe919fbb539afa479ab7601d0fb51939d59f",
	"res://game/resources/materials/world/building_1/building_1_blue_door.tres": "6554b282d6a77bcc50859b03eaea4889c18868d1f3a1580dbaa4bc2a9a6ff361",
	"res://game/scripts/world/facades/building_1_standalone_prototypes.gd": "cf18bfcfa40c7770d92aad569cba05da7ac85fe0fc89c0fd8cba6167ef62fb1f",
	"res://game/scenes/world/facades/building_1/building_1_standalone_prototype_set.tscn": "1d205d4d6e176d4ed1e82746d1f1f8c4c2547910b1a71f87a213d9ada14967ef",
	"res://game/resources/materials/world/batch_02_04_aperiodic_field.gdshader": "324ba33a7c78f4b05038168a479ebb8e875c56704236492a050cee8da8e5f798",
}
const SOURCE_AND_ISOLATION_HASHES := {
	"res://discovery/facades/TREASURE_ISLAND_MUSEUM_BUILDING_1_REFERENCE_SPEC.md": "79fe7b7cc49ea5e40a8611313defacb07ec23fb1a1a711822e0378b8cc32ac5a",
	"res://discovery/facades/NEXT_COHORT_STREETVIEW_OBSERVATIONS.md": "aee175db92ec39b0ae4f0e2adfe286f297c93d303fee4249cb6f03c25ae12b2a",
	"res://discovery/facades/NEXT_COHORT_REFERENCE_INDEX.md": "b634412b0fa41cb0eada84c81f44113b30ff579edf0abddfceefbae61883eed8",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://generated/world/chunks/x_-1__z_2.json": "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	"res://game/resources/facades/batch_06_prototype_registry.json": "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132",
}
const PAUSED_R133351_PATHS := {
	"res://discovery/facades/R133351_PAUSED_WIP_HANDOFF.md": "",
	"res://discovery/facades/R133351_TARGET_SELECTION_AND_STANDALONE_SPEC.md": "",
	"res://game/resources/facades/r133351_standalone_prototypes.json": "ecde7b80ba595f61d03bfd21f57407956c3b8988e381f0457f95bfe1aa580ad9",
	"res://game/resources/materials/world/r133351/r133351_frame.tres": "e49560ac110ead76b38ea737599009843a2188a6853a9e825cf583f52e08f7a8",
	"res://game/resources/materials/world/r133351/r133351_glass.tres": "9341d310e5587a13844bb6ae12e9734f56caff4092b54cf013e8b2109125ab8f",
	"res://game/resources/materials/world/r133351/r133351_light_field.tres": "7e7a332b067268695eb102e82e35360322d5cf4fcb2c7c2d4f681351eb10d66e",
	"res://game/resources/materials/world/r133351/r133351_lower_field.tres": "6d2e7928f15d69864af25e1a0af36bc7082269eecd9600f20236cefaba69455a",
	"res://game/resources/materials/world/r133351/r133351_olive_field.tres": "c679dbd2002c4a9a66ef0727498f5b41f1cdd38e8d44ae30abf50fad2e6a9a8b",
	"res://game/scenes/world/facades/batch_06/r133351_standalone_prototype_set.tscn": "4bc35012542e0c6c6d8c1ebe2b18433c31b8cfcd57ff3a74c7ab6278d497df13",
	"res://game/scripts/world/facades/r133351_standalone_prototypes.gd": "34507e27e8cfe518c71a75c2a410b35e6cb335f2a88abbfb91624a537b1945f6",
	"res://game/scripts/world/facades/r133351_standalone_prototypes.gd.uid": "a7049d6d6a2c98606d6189ee22b77e06da5f7588383797c983e5bee4f392b2ee",
}
const MODULE_EXPECTATIONS := {
	"B1_WING_W": {"id": "B1-WING-W", "meshes": 7, "triangles": 84},
	"B1_CENTRAL_W": {"id": "B1-CENTRAL-W", "meshes": 9, "triangles": 108},
	"B1_PAV_W": {"id": "B1-PAV-W", "meshes": 13, "triangles": 156},
	"B1_BASE_O": {"id": "B1-BASE-O", "meshes": 6, "triangles": 72},
	"B1_DOOR_BLUE": {"id": "B1-DOOR-BLUE", "meshes": 5, "triangles": 60},
	"B1_BAND": {"id": "B1-BAND", "meshes": 3, "triangles": 36},
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Building 1 standalone registry bytes drifted.") \
	or not _require(_hashes_match(EXPECTED_HASHES), "A Building 1 standalone asset drifted.") \
	or not _require(_hashes_match(SOURCE_AND_ISOLATION_HASHES), "A source, runtime, generated, or inventory pin drifted.") \
		or not _require(_paths_absent(PAUSED_R133351_PATHS), "Paused r133351 WIP leaked from its dedicated branch into current main."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	if not _require(_registry_contract_matches(registry), "Building 1 classification, evidence boundary, scale labels, or blocked claims failed.") \
	or not _require(_material_contract_matches(), "Building 1 material/channel contract failed.") \
	or not _require(_runtime_isolation_matches(), "Building 1 standalone resources leaked into runtime or generated state."):
		_finish()
		return
	var packed := load(SCENE_PATH) as PackedScene
	if not _require(packed != null, "Building 1 standalone scene could not load."):
		_finish()
		return
	var first := packed.instantiate() as Node3D
	root.add_child(first)
	await process_frame
	if not _require(_scene_contract_matches(first), "Building 1 standalone geometry or isolation contract failed."):
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
	if not _require(first_signature == second_signature, "Fresh Building 1 prototype instances were not deterministic.") \
	or not _require(_scene_contract_matches(second), "Repeated Building 1 scene instance failed its contract."):
		second.queue_free()
		_finish()
		return
	second.queue_free()
	print("PASS: Building 1 retains one frozen isolated 40 m motif-free warm-ivory field plus six complete standalone module-atlas motifs at deterministic 44/44/528 topology; later exact/live field lifecycle is permitted without altering standalone assets, modules remain zero-live, generated bytes are pinned, and paused r133351 WIP remains absent from current main")
	_finish()


func _registry_contract_matches(registry: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.building-1-standalone-prototypes/1" \
	or str(registry.get("source_key", "")) != "r16681702" \
	or str(registry.get("receiver_key", "")) != "building:r16681702:wall" \
	or bool(registry.get("runtime_attachment", true)) \
	or bool(registry.get("exact_receiver_calibration", true)) \
	or int(registry.get("live_placement_count", -1)) != 0:
		return false
	var kinds := registry.get("asset_kind_inventory", {}) as Dictionary
	if int(kinds.get("homogeneous_material_tile", -1)) != 1 \
	or int(kinds.get("architectural_pattern_tile", -1)) != 0 \
	or int(kinds.get("module_atlas", -1)) != 6 \
	or int(kinds.get("unique_elevation", -1)) != 0:
		return false
	var receiver := registry.get("receiver_audit", {}) as Dictionary
	if int(receiver.get("wall_run_count", 0)) != 110 \
	or int(receiver.get("outer_run_count", 0)) != 100 \
	or int(receiver.get("inner_run_count", 0)) != 10 \
	or not is_equal_approx(float(receiver.get("height_m", 0.0)), 20.0) \
	or str(receiver.get("separate_excluded_tower_source", "")) != "w1222720021" \
	or str(receiver.get("exact_observed_outer_run_endpoint_mapping", "")) != "blocked_not_encoded":
		return false
	var fields := registry.get("materials", []) as Array
	var modules := registry.get("modules", []) as Array
	if fields.size() != 1 or modules.size() != 6:
		return false
	var field := fields[0] as Dictionary
	if str(field.get("asset_kind", "")) != "homogeneous_material_tile" \
	or bool(field.get("surveyed_color", true)) \
	or bool(field.get("surveyed_finish_scale", true)) \
	or bool(field.get("runtime_attachment", true)):
		return false
	var repeat := field.get("repeat_contract", {}) as Dictionary
	if str(repeat.get("finite_facade_motif_period", "")) != "none_by_design" \
	or bool(repeat.get("contains_facade_scale_motifs", true)) \
	or bool(repeat.get("contains_baked_lighting", true)) \
	or bool(repeat.get("contains_unique_stains", true)):
		return false
	var shared := registry.get("module_shared_contract", {}) as Dictionary
	for key in ["module_owns_field_geometry", "surveyed_dimensions", "surveyed_coordinates", "surveyed_count", "surveyed_cadence", "runtime_attachment"]:
		if bool(shared.get(key, true)):
			return false
	for key in ["module_owned_backing_meshes", "module_owned_collision_nodes", "module_owned_navigation_nodes", "module_owned_spray_nodes"]:
		if int(shared.get(key, -1)) != 0:
			return false
	var seen: Array[String] = []
	for module_value: Variant in modules:
		var module := module_value as Dictionary
		seen.append(str(module.get("motif_id", "")))
		if str(module.get("asset_kind", "")) != "module_atlas" \
		or not bool(module.get("complete_motif", false)) \
		or not bool(module.get("module_not_seamless_wall_tile", false)) \
		or int((module.get("prototype_topology", {}) as Dictionary).get("field_or_backing_meshes", -1)) != 0:
			return false
	seen.sort()
	if seen != ["B1-BAND", "B1-BASE-O", "B1-CENTRAL-W", "B1-DOOR-BLUE", "B1-PAV-W", "B1-WING-W"]:
		return false
	var blocked := JSON.stringify(registry.get("blocked_claims", [])).to_lower()
	for phrase in ["exact outer-run", "count", "main entrance", "emblems", "east or rear", "inner-ring", "separate tower", "massing", "completed elevation", "whole-building"]:
		if phrase not in blocked:
			return false
	return true


func _material_contract_matches() -> bool:
	var field := load("res://game/resources/materials/world/building_1/building_1_warm_ivory.tres") as ShaderMaterial
	if field == null or field.shader == null \
	or (field.get_shader_parameter("base_color") as Color).a != 1.0 \
	or float(field.get_shader_parameter("roughness_value")) != 0.82 \
	or float(field.get_shader_parameter("primary_scale_m")) != 1.1 \
	or float(field.get_shader_parameter("secondary_scale_m")) != 0.32 \
	or float(field.get_shader_parameter("filter_start_cycles_per_pixel")) >= float(field.get_shader_parameter("filter_end_cycles_per_pixel")):
		return false
	var shader := FileAccess.get_file_as_string("res://game/resources/materials/world/batch_02_04_aperiodic_field.gdshader")
	if "render_mode depth_draw_opaque, cull_back" not in shader or "field_position_m = VERTEX.xy" not in shader or "fwidth(" not in shader:
		return false
	for forbidden in ["sampler2D", "TIME", "SCREEN_TEXTURE", "discard", "ALPHA ="]:
		if forbidden in shader:
			return false
	for path in [
		"res://game/resources/materials/world/building_1/building_1_light_trim.tres",
		"res://game/resources/materials/world/building_1/building_1_rose_base.tres",
		"res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres",
		"res://game/resources/materials/world/building_1/building_1_blue_door.tres",
	]:
		var material := load(path) as StandardMaterial3D
		if material == null or material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED or material.albedo_color.a != 1.0 or material.emission_enabled:
			return false
	return true


func _scene_contract_matches(instance: Node3D) -> bool:
	if not bool(instance.get_meta("prototype_only", false)) \
	or bool(instance.get_meta("runtime_attachment", true)) \
	or bool(instance.get_meta("exact_receiver_calibration", true)):
		return false
	var geometry := instance.get_node_or_null("PrototypeGeometry") as Node3D
	if geometry == null \
	or geometry.get_meta("proof_dimensions_m", Vector2.ZERO) != Vector2(40.0, 10.0) \
	or str(geometry.get_meta("receiver_runs_available_not_eligible_placements", "")) != "outer_0_99_inner_100_109_exact_observed_endpoint_mapping_blocked" \
	or _count_meshes(geometry) != 44 \
	or _count_surfaces(geometry) != 44 \
	or _count_triangles(geometry) != 528:
		return false
	var host := geometry.get_node_or_null("WarmIvoryHostFieldMacroProof") as MeshInstance3D
	if host == null or not host.material_override is ShaderMaterial:
		return false
	for node_name: Variant in MODULE_EXPECTATIONS:
		var module := geometry.get_node_or_null(str(node_name)) as Node3D
		var expected := MODULE_EXPECTATIONS[node_name] as Dictionary
		if module == null \
		or str(module.get_meta("motif_id", "")) != str(expected.get("id", "")) \
		or str(module.get_meta("asset_kind", "")) != "module_atlas" \
		or not bool(module.get_meta("complete_motif", false)) \
		or not bool(module.get_meta("module_not_seamless_tile", false)) \
		or bool(module.get_meta("module_owns_field_geometry", true)) \
		or int(module.get_meta("module_owned_backing_meshes", -1)) != 0 \
		or str(module.get_meta("placement_state", "")) != "none_standalone_only" \
		or bool(module.get_meta("surveyed_dimensions", true)) \
		or bool(module.get_meta("surveyed_coordinates", true)) \
		or bool(module.get_meta("completed_elevation", true)) \
		or bool(module.get_meta("whole_building_acceptance", true)) \
		or _count_meshes(module) != int(expected.get("meshes", 0)) \
		or _count_surfaces(module) != int(expected.get("meshes", 0)) \
		or _count_triangles(module) != int(expected.get("triangles", 0)):
			return false
		for child in module.get_children():
			if child is MeshInstance3D:
				var lower_name := str(child.name).to_lower()
				if "field" in lower_name or "backing" in lower_name or (child as MeshInstance3D).material_override is ShaderMaterial:
					return false
	return _count_type(geometry, CollisionObject3D) == 0 \
		and _count_type(geometry, CollisionShape3D) == 0 \
		and _count_type(geometry, NavigationRegion3D) == 0 \
		and _count_type(geometry, Decal) == 0


func _runtime_isolation_matches() -> bool:
	var builder := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	var accepted := FileAccess.get_file_as_string("res://game/scripts/world/facades/accepted_material_run_trials.gd")
	var live_field := FileAccess.get_file_as_string("res://game/scripts/world/facades/building_1_live_field.gd")
	for token in ["building_1_standalone_prototype_set", "building_1_standalone_prototypes", "building_1_warm_ivory", "B1-WING-W", "B1-CENTRAL-W", "B1-PAV-W", "B1-BASE-O", "B1-DOOR-BLUE", "B1-BAND"]:
		if token in builder or token in accepted:
			return false
	for historical_adapter_token in [
		"BUILDING_1_EXACT_RECEIVER_CALIBRATION",
		"building_1_exact_receiver_calibration_scene",
		"BUILDING_1_LIVE_FIELD",
		"building_1_live_field",
		"BUILDING_1_RECOGNIZABLE_FACADE",
		"building_1_recognizable_facade",
	]:
		if historical_adapter_token in builder:
			return false
	for module_token in ["B1-WING-W", "B1-CENTRAL-W", "B1-PAV-W", "B1-BASE-O", "B1-DOOR-BLUE", "B1-BAND"]:
		if module_token in live_field:
			return false
	return builder.count('const BUILDING_1_HERO_MODEL := preload("res://game/scripts/world/facades/building_1_hero_model.gd")') == 1 \
		and builder.count("if not is_context and BUILDING_1_HERO_MODEL.matches_record(record):") == 1 \
		and builder.count("return BUILDING_1_HERO_MODEL.build_record(record)") == 1 \
		and "module_placements\": 0" in live_field \
		and _current_b1_registry_matches()


func _current_b1_registry_matches() -> bool:
	if FileAccess.get_sha256(CURRENT_RUNTIME_REGISTRY_PATH) != CURRENT_RUNTIME_REGISTRY_SHA256:
		return false
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CURRENT_RUNTIME_REGISTRY_PATH))
	if not registry_value is Dictionary:
		return false
	var registry := registry_value as Dictionary
	var metric := registry.get("recognition_metric", {}) as Dictionary
	if str(registry.get("schema_version", "")) != "ti.facade-runtime-registry/7" \
		or int(metric.get("numerator", -1)) != 7 \
		or int(metric.get("denominator", -1)) != 213 \
		or str(metric.get("display", "")) != "7/213":
		return false
	var expectations := {
		"building:r16681702:wall": {
			"adapter_id": "active-adapter:building-1-hero:building:r16681702:wall",
			"unit_id": "physical-building:r16681702",
			"run_count": 110,
			"review_id": "building-1-hero-2026-09-04:main",
			"receipt": "b12858438d6522b7f3cf42fa06392648d16ee3e0c418eb5e807a3ee1be770c2a",
			"manifest": "ebeef887b37c6845c6c8fa3f25e06706351fe7c1dab0e1a3b0eaf47dfb773017",
		},
		"building:w1222720021:wall": {
			"adapter_id": "active-adapter:building-1-hero:building:w1222720021:wall",
			"unit_id": "physical-building:w1222720021",
			"run_count": 10,
			"review_id": "building-1-tower-grounded-correction-2026-09-04",
			"receipt": "fb952a31151805078d1e386117ed965aa0649ffddcd17874d13493b5dd4239bb",
			"manifest": "dbe9745f5356b2309e820c2b47987ee4463518eaf4afd77fcd37df0edc8d437a",
		},
	}
	for receiver_value: Variant in expectations:
		var receiver := str(receiver_value)
		var expected := expectations[receiver_value] as Dictionary
		var adapter := _adapter_for(registry.get("active_runtime_adapters", []) as Array, receiver)
		var unit := _unit_for(registry.get("units", []) as Array, str(expected.unit_id))
		var scope := adapter.get("active_receiver_scope", {}) as Dictionary
		if str(adapter.get("adapter_id", "")) != str(expected.adapter_id) \
			or str(adapter.get("runtime_content_mode", "")) != "active_building_1_hero" \
			or str(adapter.get("review_status", "")) != "pending_independent_original_detail_review" \
			or str(adapter.get("review_status_scope", "")) != "runtime_asset_original_detail_provenance_only_not_reference_recognition" \
			or str(adapter.get("recognition_acceptance_authority", "")) != "physical_unit_claim_and_independent_acceptance_record" \
			or str(adapter.get("recognition_acceptance_status", "")) != "accepted" \
			or str(scope.get("coverage", "")) != "whole_direct_wall_receiver" \
			or int(scope.get("run_count", -1)) != int(expected.run_count) \
			or str((unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) != "accepted" \
			or not _has_acceptance_receipt(unit, expected):
			return false
	return true


func _adapter_for(adapters: Array, receiver_key: String) -> Dictionary:
	for value: Variant in adapters:
		var adapter := value as Dictionary
		if str(adapter.get("receiver_key", "")) == receiver_key:
			return adapter
	return {}


func _unit_for(units: Array, unit_id: String) -> Dictionary:
	for value: Variant in units:
		var unit := value as Dictionary
		if str(unit.get("unit_id", "")) == unit_id:
			return unit
	return {}


func _has_acceptance_receipt(unit: Dictionary, expected: Dictionary) -> bool:
	for value: Variant in unit.get("acceptance_records", []) as Array:
		var record := value as Dictionary
		if str(record.get("review_id", "")) == str(expected.review_id) \
			and str(record.get("review_kind", "")) == "independent_reference_recognition" \
			and str(record.get("status", "")) == "accept" \
			and str(record.get("review_receipt_sha256", "")) == str(expected.receipt) \
			and str(record.get("evidence_manifest_sha256", "")) == str(expected.manifest):
			return true
	return false


func _hashes_match(expected: Dictionary) -> bool:
	for path_value: Variant in expected:
		var path := str(path_value)
		if FileAccess.get_sha256(path) != str(expected[path_value]):
			return false
	return true


func _paths_absent(paths: Dictionary) -> bool:
	for path_value: Variant in paths:
		var path := str(path_value)
		if FileAccess.file_exists(path) or ResourceLoader.exists(path):
			return false
	return true


func _geometry_signature(node: Node) -> String:
	var records: Array[String] = []
	_collect_geometry_records(node, records)
	records.sort()
	return JSON.stringify(records).sha256_text()


func _collect_geometry_records(node: Node, records: Array[String]) -> void:
	if node is MeshInstance3D:
		var instance := node as MeshInstance3D
		var size := Vector3.ZERO
		if instance.mesh is BoxMesh:
			size = (instance.mesh as BoxMesh).size
		records.append("%s|%.6f,%.6f,%.6f|%.6f,%.6f,%.6f|%s" % [str(node.get_path()), instance.global_position.x, instance.global_position.y, instance.global_position.z, size.x, size.y, size.z, str(instance.material_override.resource_path)])
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


func _count_type(node: Node, type: Variant) -> int:
	var count := 1 if is_instance_of(node, type) else 0
	for child in node.get_children():
		count += _count_type(child, type)
	return count


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
