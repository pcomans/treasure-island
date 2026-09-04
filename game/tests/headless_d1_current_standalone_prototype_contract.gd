extends SceneTree

const PAIR_CONFIG_PATH := "res://game/resources/facades/d1_current/d1_current_standalone_pair.json"
const B201_CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b201_public_wsw.json"
const B225_CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b225_nnw_long.json"
const SCENE_PATH := "res://game/scenes/world/facades/d1_current/d1_current_standalone_prototype_pair.tscn"
const FACTORY_PATH := "res://game/scripts/world/facades/d1_current_standalone_prototypes.gd"
const RUN_MAPPING_PATH := "res://discovery/facades/BATCH_05_RUN_MAPPING.json"
const RECEIVER_INVENTORY_PATH := "res://discovery/FACADE_RECEIVER_INVENTORY.json"

const EXPECTED_FACTORY_SHA256 := "797bbb81e7f772f3fab3989d358772be4f1b16cb7e31a05571463e0d6ec31a5e"
const EXPECTED_SCENE_SHA256 := "0fdd5d356deb57664549db95fd04e123290c1fb9490b8024569e997616893d7f"
const EXPECTED_PAIR_CONFIG_SHA256 := "fdf00bba0562036f499a5a64e47e5e1b695d49d6cb4ada7acafd450b3dcfefb9"
const EXPECTED_B201_CONFIG_SHA256 := "30bc1f62e5fa44c60bdcfb1bfd4f6f679d391618fa213373e571080face6ec6c"
const EXPECTED_B225_CONFIG_SHA256 := "dc3591df4a68af19b5fa53f402ed15d5e3f83946c4a113f024d5b7d41f2f82b8"
const EXPECTED_RUN_MAPPING_SHA256 := "54a8f651a56a03a65747d511184afc9f8271bbfc4efe5614db94f3d5232b368b"
const EXPECTED_RECEIVER_INVENTORY_SHA256 := "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f"
const EXPECTED_B201_SIGNATURE := "57573bc19d6c6a45b946827e76a346c592d5238a310e923a30a41b149f963511"
const EXPECTED_B225_SIGNATURE := "179d898c4635917743e967819998256c7fe4938981da69e7d4664e1e7e13b58a"
const EXPECTED_PAIR_SIGNATURE := "17c560633517963489b76430729bb6476065bb0d9a6385b3a913103a778c32ad"

const EXPECTED_BATCH_COUNTS := {
	"w34313545": {
		"b201_warm_wall": 30,
		"shared_dark_glass": 18,
		"shared_pale_frame": 120,
		"b201_green_hierarchy": 4,
		"b201_muted_rust_post": 7,
		"b201_service_leaf": 3,
	},
	"w95934119": {
		"b225_aged_cladding": 4,
		"shared_deep_reveal": 14,
		"shared_dark_glass": 10,
		"shared_pale_frame": 80,
	},
}

const MATERIAL_HASHES := {
	"res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres": "5bdd67e659a0cce14abe3605f5a7fbfd85b0374d0a38be23cda326017235fe13",
	"res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres": "be97cdfd7367cd73172c4429ca212db0d1fc68bed34f4db6ce307d02a5225b94",
	"res://game/resources/materials/world/d1_current/b201_service_leaf.tres": "de9895a808e4d64afc2c727e77ef92b590c9c718266ba118e64c489e84690cfd",
	"res://game/resources/materials/world/d1_current/b201_warm_wall.tres": "6f5f6835790ab338454e72be58c2956deb6e470086797e209be0fab4d37ec788",
	"res://game/resources/materials/world/d1_current/b225_aged_horizontal_cladding.tres": "49e2a7cb075707f1384106301583d295ffe955450d10c36a8526a7a87722f9f0",
	"res://game/resources/materials/world/d1_current/shared_dark_glass.tres": "ad8931db8954fd5ebc8fdd809f70afb279dd74a36e53e1d9ca907c44409f10d3",
	"res://game/resources/materials/world/d1_current/shared_deep_reveal.tres": "b15a82b4e37546cffac83d1b7c4e30f5e6828c7940a8da6581b218589cd908d5",
	"res://game/resources/materials/world/d1_current/shared_pale_frame.tres": "9a2de298ff545cf80c5da0ed0aa37d9d4ebbf10fec8eb78810af7e4d012d1436",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var pair := _load_json(PAIR_CONFIG_PATH)
	var b201 := _load_json(B201_CONFIG_PATH)
	var b225 := _load_json(B225_CONFIG_PATH)
	var mapping := _load_json(RUN_MAPPING_PATH)
	var inventory := _load_json(RECEIVER_INVENTORY_PATH)
	if pair.is_empty() or b201.is_empty() or b225.is_empty() or mapping.is_empty() or inventory.is_empty():
		_finish()
		return
	_require(FileAccess.get_sha256(FACTORY_PATH) == EXPECTED_FACTORY_SHA256, "D1 factory bytes drifted.")
	_require(FileAccess.get_sha256(SCENE_PATH) == EXPECTED_SCENE_SHA256, "D1 scene bytes drifted.")
	_require(FileAccess.get_sha256(PAIR_CONFIG_PATH) == EXPECTED_PAIR_CONFIG_SHA256, "D1 pair config bytes drifted.")
	_require(FileAccess.get_sha256(B201_CONFIG_PATH) == EXPECTED_B201_CONFIG_SHA256, "B201 config bytes drifted.")
	_require(FileAccess.get_sha256(B225_CONFIG_PATH) == EXPECTED_B225_CONFIG_SHA256, "B225 config bytes drifted.")
	_require(FileAccess.get_sha256(RUN_MAPPING_PATH) == EXPECTED_RUN_MAPPING_SHA256, "Canonical Batch 05 mapping drifted.")
	_require(FileAccess.get_sha256(RECEIVER_INVENTORY_PATH) == EXPECTED_RECEIVER_INVENTORY_SHA256, "Receiver inventory drifted.")
	_require(_configs_match(pair, b201, b225), "D1 pair/config scope or topology contract failed.")
	_require(_canonical_mapping_matches(b201, b225, mapping), "D1 exact observed-side/run mapping contract failed.")
	_require(_generated_receivers_match(b201, b225), "D1 generated receiver/run geometry contract failed.")
	_require(_inventory_bindings_match(b201, b225, inventory), "D1 frozen receiver inventory binding failed.")
	_require(_materials_match(pair), "D1 opaque local material/package contract failed.")
	_require(_factory_is_isolated(), "D1 factory leaked into a live attachment seam or contains forbidden stochastic/physics behavior.")

	var packed := load(SCENE_PATH) as PackedScene
	if not _require(packed != null, "D1 standalone pair scene did not load."):
		_finish()
		return
	var instance := packed.instantiate() as Node3D
	root.add_child(instance)
	await process_frame
	_require(_scene_contract_matches(instance), "D1 instantiated standalone pair geometry/topology/isolation contract failed.")
	var b201_node := instance.get_node_or_null("B201_w34313545") as Node3D
	var b225_node := instance.get_node_or_null("B225_w95934119") as Node3D
	print("D1_SIGNATURE_B201=%s" % str(b201_node.get_meta("geometry_signature", "")))
	print("D1_SIGNATURE_B225=%s" % str(b225_node.get_meta("geometry_signature", "")))
	print("D1_SIGNATURE_PAIR=%s" % str(instance.get_meta("geometry_signature", "")))
	if not EXPECTED_B201_SIGNATURE.is_empty():
		_require(str(b201_node.get_meta("geometry_signature", "")) == EXPECTED_B201_SIGNATURE, "B201 deterministic geometry signature drifted.")
	if not EXPECTED_B225_SIGNATURE.is_empty():
		_require(str(b225_node.get_meta("geometry_signature", "")) == EXPECTED_B225_SIGNATURE, "B225 deterministic geometry signature drifted.")
	if not EXPECTED_PAIR_SIGNATURE.is_empty():
		_require(str(instance.get_meta("geometry_signature", "")) == EXPECTED_PAIR_SIGNATURE, "D1 pair deterministic geometry signature drifted.")
	instance.queue_free()
	if not _failed:
		print("PASS: D1 B201 runs 0..9 and B225 runs 10..13 instantiate as a deterministic 290-box / 3480-triangle render-only standalone pair; exact receiver, identity-conflict, protected-region and no-live-attachment contracts hold")
	_finish()


func _configs_match(pair: Dictionary, b201: Dictionary, b225: Dictionary) -> bool:
	var pair_topology := pair.get("topology", {}) as Dictionary
	var pair_members := pair.get("prototypes", []) as Array
	var authority := pair.get("authoritative_pins", {}) as Dictionary
	if str(pair.get("review_status", "")) != "pending_independent_recognition_and_bar_review_not_self_accepted" \
	or bool(pair.get("runtime_attachment", true)) \
	or int(pair.get("live_placement_count", -1)) != 0 \
	or bool(pair.get("reference_pixels_stored_or_copied", true)) \
	or int(pair_topology.get("batch_count", -1)) != 10 \
	or int(pair_topology.get("box_instance_count", -1)) != 290 \
	or int(pair_topology.get("triangle_count", -1)) != 3480 \
	or int(pair_topology.get("collision_nodes", -1)) != 0 \
	or int(pair_topology.get("navigation_nodes", -1)) != 0 \
	or int(pair_topology.get("spray_nodes", -1)) != 0 \
	or pair_members.size() != 2 \
	or str((pair_members[0] as Dictionary).get("config_sha256", "")) != EXPECTED_B201_CONFIG_SHA256 \
	or str((pair_members[1] as Dictionary).get("config_sha256", "")) != EXPECTED_B225_CONFIG_SHA256 \
	or str(authority.get("source_provenance_receipt_id", "")) != "D1-PAIR-AUTHORITY" \
	or str(authority.get("source_provenance_receipt_sha256", "")) != "269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333":
		print("CONFIG_PAIR_DIAGNOSTIC topology=", pair_topology)
		return false
	for config: Dictionary in [b201, b225]:
		if str(config.get("schema_version", "")) != "ti.d1-current-standalone-side-prototype/1" \
		or str(config.get("review_status", "")) != "pending_independent_recognition_and_bar_review_not_self_accepted" \
		or bool(config.get("runtime_attachment", true)) \
		or int(config.get("live_placement_count", -1)) != 0 \
		or bool(config.get("reference_pixels_stored_or_copied", true)) \
		or bool(config.get("generated_or_external_texture_assets", true)) \
		or str((config.get("production_inference", {}) as Dictionary).get("truth_class", "")) != "reversible_production_inference_not_surveyed" \
		or str((config.get("live_integration_seam", {}) as Dictionary).get("status", "")) != "blocked_pending_independent_review_and_fresh_receiver_relative_layout":
			print("CONFIG_UNIT_DIAGNOSTIC source=", config.get("source_key", ""), " review=", config.get("review_status", ""), " inference=", config.get("production_inference", {}), " seam=", config.get("live_integration_seam", {}))
			return false
	var b201_topology := b201.get("render_topology", {}) as Dictionary
	var b225_topology := b225.get("render_topology", {}) as Dictionary
	var matches: bool = b201.get("source_key", "") == "w34313545" \
		and b225.get("source_key", "") == "w95934119" \
		and _numeric_dictionary_matches(b201_topology.get("batch_instance_counts", {}) as Dictionary, EXPECTED_BATCH_COUNTS["w34313545"] as Dictionary) \
		and _numeric_dictionary_matches(b225_topology.get("batch_instance_counts", {}) as Dictionary, EXPECTED_BATCH_COUNTS["w95934119"] as Dictionary) \
		and int(b201_topology.get("box_instance_count", 0)) == 182 \
		and int(b225_topology.get("box_instance_count", 0)) == 108
	if not matches:
		print("CONFIG_TOPOLOGY_DIAGNOSTIC b201=", b201_topology, " expected=", EXPECTED_BATCH_COUNTS["w34313545"], " b225=", b225_topology, " expected=", EXPECTED_BATCH_COUNTS["w95934119"])
	return matches


func _numeric_dictionary_matches(actual: Dictionary, expected: Dictionary) -> bool:
	if actual.size() != expected.size():
		return false
	for key_value: Variant in expected:
		if not actual.has(key_value) or int(actual[key_value]) != int(expected[key_value]):
			return false
	return true


func _canonical_mapping_matches(b201: Dictionary, b225: Dictionary, mapping: Dictionary) -> bool:
	for config: Dictionary in [b201, b225]:
		var target := _find_target(mapping.get("targets", []) as Array, str(config.get("source_key", "")))
		if target.is_empty():
			return false
		var eligible := config.get("eligible_region", {}) as Dictionary
		var canonical := _find_mapping(target.get("mappings", []) as Array, str(eligible.get("mapping_id", "")))
		if canonical.is_empty() \
		or canonical.get("run_indices", []) != eligible.get("ordered_run_indices", []) \
		or canonical.get("source_edge_indices", []) != eligible.get("source_edge_indices", []) \
		or str(canonical.get("classification", "")) != "material_only_safe" \
		or str(canonical.get("confidence", "")) != "high" \
		or not bool(canonical.get("contiguous", false)) \
		or canonical.get("chain_start_world_xz_m", []) != eligible.get("chain_start_world_xz_m", []) \
		or canonical.get("chain_end_world_xz_m", []) != eligible.get("chain_end_world_xz_m", []) \
		or not is_equal_approx(float(canonical.get("total_length_m", 0.0)), float(eligible.get("canonical_rounded_chain_length_m", -1.0))):
			return false
	return true


func _generated_receivers_match(b201: Dictionary, b225: Dictionary) -> bool:
	for config: Dictionary in [b201, b225]:
		var binding := config.get("binding", {}) as Dictionary
		var chunk_path := str(binding.get("chunk_path", ""))
		if FileAccess.get_sha256(chunk_path) != str(binding.get("chunk_sha256", "")):
			return false
		var chunk := _load_json(chunk_path)
		var record := _find_record(chunk.get("records", []) as Array, str(config.get("receiver_key_eligibility_only", "")))
		if record.is_empty() \
		or record.get("source_keys", []) != [str(config.get("source_key", ""))] \
		or str(record.get("feature_kind", "")) != "building_wall" \
		or str(record.get("receiver_kind", "")) != "building_wall" \
		or str(record.get("collision_kind", "")) != "world_solid" \
		or not bool(record.get("opaque", false)) \
		or int(record.get("exterior_foundation_segments", 0)) != int(binding.get("receiver_run_count", -1)) \
		or not is_equal_approx(float(record.get("flat_base_elevation_m", 0.0)), float(binding.get("base_elevation_m", -1.0))) \
		or not is_equal_approx(float(record.get("top_elevation_m", 0.0)), float(binding.get("top_elevation_m", -1.0))):
			print("GENERATED_RECORD_DIAGNOSTIC source=", config.get("source_key", ""), " record=", record)
			return false
		var eligible := config.get("eligible_region", {}) as Dictionary
		var vertices := record.get("vertices", []) as Array
		var run_indices := eligible.get("ordered_run_indices", []) as Array
		var run_lengths := eligible.get("ordered_run_lengths_m", []) as Array
		var measured_total := 0.0
		for offset in run_indices.size():
			var run_index := int(run_indices[offset])
			var base := run_index * 12
			var measured := Vector2(float(vertices[base]), float(vertices[base + 2])).distance_to(Vector2(float(vertices[base + 3]), float(vertices[base + 5])))
			if absf(measured - float(run_lengths[offset])) > 0.00002:
				print("GENERATED_LENGTH_DIAGNOSTIC source=", config.get("source_key", ""), " run=", run_index, " measured=", measured, " expected=", run_lengths[offset])
				return false
			measured_total += measured
		if absf(measured_total - float(eligible.get("exact_generated_chain_length_m", 0.0))) > 0.0001:
			print("GENERATED_TOTAL_DIAGNOSTIC source=", config.get("source_key", ""), " measured=", measured_total, " expected=", eligible.get("exact_generated_chain_length_m", 0.0))
			return false
	return true


func _inventory_bindings_match(b201: Dictionary, b225: Dictionary, inventory: Dictionary) -> bool:
	for config: Dictionary in [b201, b225]:
		var object := _find_inventory_object(inventory.get("objects", []) as Array, str(config.get("source_key", "")))
		var binding := config.get("binding", {}) as Dictionary
		var generated := object.get("generated_receiver", {}) as Dictionary
		var geometry := object.get("source_geometry", {}) as Dictionary
		var massing := object.get("current_generated_massing", {}) as Dictionary
		if object.is_empty() \
		or str(geometry.get("geometry_sha256", "")) != str(binding.get("source_geometry_sha256", "")) \
		or generated.get("direct_wall_object_keys", []) != [str(config.get("receiver_key_eligibility_only", ""))] \
		or generated.get("direct_roof_object_keys", []) != [str(config.get("roof_object_key_protected", ""))] \
		or not is_equal_approx(float(massing.get("height_m", 0.0)), 5.0) \
		or str(object.get("footprint_relationship", {}).get("kind", "")) != "standalone_building_footprint":
			return false
	return true


func _materials_match(pair: Dictionary) -> bool:
	var declared := pair.get("materials", []) as Array
	if declared.size() != MATERIAL_HASHES.size():
		return false
	for path_value: Variant in MATERIAL_HASHES:
		var path := str(path_value)
		if FileAccess.get_sha256(path) != str(MATERIAL_HASHES[path_value]):
			return false
		var material := load(path) as StandardMaterial3D
		if material == null \
		or material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED \
		or material.albedo_color.a != 1.0 \
		or material.albedo_texture != null \
		or material.normal_texture != null \
		or material.roughness_texture != null \
		or material.metallic_texture != null \
		or material.heightmap_enabled:
			return false
	var factory_source := FileAccess.get_file_as_string(FACTORY_PATH)
	for material_record_value: Variant in declared:
		var material_record := material_record_value as Dictionary
		var material_path := str(material_record.get("path", ""))
		if str(MATERIAL_HASHES.get(material_path, "")) != str(material_record.get("sha256", "")) \
		or material_path.trim_prefix("res://") not in factory_source:
			return false
	return true


func _factory_is_isolated() -> bool:
	var factory_source := FileAccess.get_file_as_string(FACTORY_PATH)
	for forbidden in ["RandomNumberGenerator", "randf(", "randi(", "FastNoise", "NoiseTexture", "CollisionShape3D.new", "StaticBody3D.new", "NavigationRegion3D.new", "Decal.new", "address plaque", "business sign"]:
		if forbidden in factory_source:
			return false
	for live_path in [
		"res://game/scripts/world/world_chunk_builder.gd",
		"res://game/scripts/world/facades/accepted_material_run_trials.gd",
		"res://game/scripts/world/facades/facade_runtime_registry_loader.gd",
	]:
		var live_source := FileAccess.get_file_as_string(live_path)
		if "d1_current_standalone_prototype_pair" in live_source or "d1_current_standalone_prototypes" in live_source:
			return false
	return true


func _scene_contract_matches(instance: Node3D) -> bool:
	if not bool(instance.get_meta("prototype_only", false)) \
	or bool(instance.get_meta("runtime_attachment", true)) \
	or bool(instance.get_meta("exact_receiver_layout", true)) \
	or not bool(instance.get_meta("standalone_side_length_calibrated", false)) \
	or str(instance.get_meta("review_status", "")) != "pending_independent_recognition_and_bar_review_not_self_accepted" \
	or int(instance.get_meta("box_instance_count", 0)) != 290 \
	or int(instance.get_meta("triangle_count", 0)) != 3480:
		return false
	var b201 := instance.get_node_or_null("B201_w34313545") as Node3D
	var b225 := instance.get_node_or_null("B225_w95934119") as Node3D
	if b201 == null or b225 == null \
	or b201.position != Vector3(-32.0, 0.0, 0.0) \
	or b225.position != Vector3(68.0, 0.0, 0.0) \
	or not _prototype_matches(b201, "w34313545", "building:w34313545:wall", "800I-PUBLIC-WSW", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 115.512661489, 182, 2184) \
	or not _prototype_matches(b225, "w95934119", "building:w95934119:wall", "14812-NNW-LONG", [10, 11, 12, 13], 46.261968372, 108, 1296):
		print("SCENE_PAIR_DIAGNOSTIC b201=", b201, " b225=", b225, " positions=", b201.position if b201 != null else Vector3.ZERO, "/", b225.position if b225 != null else Vector3.ZERO)
		return false
	return _count_type(instance, CollisionObject3D) == 0 \
		and _count_type(instance, CollisionShape3D) == 0 \
		and _count_type(instance, NavigationRegion3D) == 0 \
		and _count_type(instance, Decal) == 0


func _prototype_matches(prototype: Node3D, source_key: String, receiver_key: String, mapping_id: String, runs: Array, width_m: float, expected_boxes: int, expected_triangles: int) -> bool:
	if str(prototype.get_meta("source_key", "")) != source_key \
	or str(prototype.get_meta("receiver_key_eligibility_only", "")) != receiver_key \
	or str(prototype.get_meta("mapping_id", "")) != mapping_id \
	or prototype.get_meta("eligible_run_indices_not_placements", []) != runs \
	or not is_equal_approx(float(prototype.get_meta("side_length_m", 0.0)), width_m) \
	or not is_equal_approx(float(prototype.get_meta("height_m", 0.0)), 5.0) \
	or not bool(prototype.get_meta("production_inference", false)) \
	or not bool(prototype.get_meta("counts_cadence_dimensions_not_surveyed", false)) \
	or bool(prototype.get_meta("runtime_attachment", true)) \
	or bool(prototype.get_meta("exact_receiver_layout", true)) \
	or int(prototype.get_meta("box_instance_count", 0)) != expected_boxes \
	or int(prototype.get_meta("triangle_count", 0)) != expected_triangles:
		print("PROTOTYPE_META_DIAGNOSTIC source=", source_key, " metas=", prototype.get_meta_list().map(func(key: StringName) -> String: return "%s=%s" % [key, prototype.get_meta(key)]))
		return false
	var expected_counts := EXPECTED_BATCH_COUNTS[source_key] as Dictionary
	var batches := prototype.get_node_or_null("RenderOnlyBatches") as Node3D
	if batches == null or batches.get_child_count() != expected_counts.size():
		print("PROTOTYPE_BATCH_ROOT_DIAGNOSTIC source=", source_key, " batches=", batches, " expected_count=", expected_counts.size())
		return false
	var box_total := 0
	for material_key_value: Variant in expected_counts:
		var material_key := str(material_key_value)
		var expected_count := int(expected_counts[material_key_value])
		var batch := batches.get_node_or_null("Batch_%s" % material_key) as MultiMeshInstance3D
		if batch == null \
		or not bool(batch.get_meta("render_only", false)) \
		or str(batch.get_meta("material_key", "")) != material_key \
		or int(batch.get_meta("instance_count", 0)) != expected_count \
		or int(batch.get_meta("triangles", 0)) != expected_count * 12 \
		or batch.layers != 2 \
		or batch.multimesh == null \
		or batch.multimesh.instance_count != expected_count \
		or not (batch.multimesh.mesh is BoxMesh) \
		or batch.multimesh.mesh.get_faces().size() / 3 != 12:
			print("PROTOTYPE_BATCH_DIAGNOSTIC source=", source_key, " material=", material_key, " batch=", batch)
			return false
		box_total += expected_count
	return box_total == expected_boxes


func _find_target(targets: Array, source_key: String) -> Dictionary:
	for target_value: Variant in targets:
		var target := target_value as Dictionary
		if str(target.get("source_key", "")) == source_key:
			return target
	return {}


func _find_mapping(mappings: Array, mapping_id: String) -> Dictionary:
	for mapping_value: Variant in mappings:
		var mapping := mapping_value as Dictionary
		if str(mapping.get("mapping_id", "")) == mapping_id:
			return mapping
	return {}


func _find_record(records: Array, object_key: String) -> Dictionary:
	for record_value: Variant in records:
		var record := record_value as Dictionary
		if str(record.get("object_key", "")) == object_key:
			return record
	return {}


func _find_inventory_object(objects: Array, source_key: String) -> Dictionary:
	for object_value: Variant in objects:
		var object := object_value as Dictionary
		var source := object.get("source", {}) as Dictionary
		if str(source.get("source_key", "")) == source_key:
			return object
	return {}


func _count_type(node: Node, type: Variant) -> int:
	var count := 1 if is_instance_of(node, type) else 0
	for child in node.get_children():
		count += _count_type(child, type)
	return count


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		_fail("Missing JSON: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		_fail("Invalid JSON object: %s" % path)
		return {}
	return parsed as Dictionary


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	_failed = true
	push_error(message)


func _finish() -> void:
	quit(1 if _failed else 0)
