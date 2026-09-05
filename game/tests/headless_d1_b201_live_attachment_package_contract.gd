extends SceneTree

const ADAPTER := preload("res://game/scripts/world/facades/d1_b201_live_attachment.gd")
const BUILDER := preload("res://game/scripts/world/world_chunk_builder.gd")
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const CONTRACTS_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b201_live_attachment.json"
const ADAPTER_PATH := "res://game/scripts/world/facades/d1_b201_live_attachment.gd"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const METER_UV_PATH := "res://game/scripts/world/facades/facade_meter_uv_adapter.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-2.json"
const MANIFEST_PATH := "res://generated/world/manifest.json"
const PRIVATE_CATALOG := "res://discovery/facades/facade-recognition-catalog.json"
const PRIVATE_PACKET := "res://discovery/facades/d1_reference_packets/w34313545_building_201.md"
const PRIVATE_EVIDENCE := "res://evidence/first-playable/d1-b201-live-attachment-2026-09-04/capture-manifest.json"
const RECEIVER_KEY := "building:w34313545:wall"
const SOURCE_KEY := "w34313545"
const REGISTRY_SHA256 := "9c46c1a8c809aa9ded82008d35e9c1b257070e9c61f6d6e41f5650ca7b1c3f27"
const CONTRACTS_SHA256 := "f5c1a2fb73ac0343258d4fea35169e2b7efa98accbce0c834b3e2aab45fefafe"
const CATALOG_SHA256 := "a4d9dd474acb09a211f7e0e00d66aeaf7a669927880dd011e24e2f51d13bdd7d"
const REVIEW_STATUS_SCOPE := "runtime_asset_original_detail_provenance_only_not_reference_recognition"
const RECOGNITION_ACCEPTANCE_AUTHORITY := "physical_unit_claim_and_independent_acceptance_record"
const WORLD_TOPOLOGY_SCOPE := "current_integration_topology"
const EXPECTED_WORLD := {"rows": 735, "meshes": 950, "surfaces": 964, "triangles": 66636, "bodies": 466, "shapes": 466}
const EXPECTED_RUNTIME_ASSETS := {
	CONFIG_PATH: "0f3bf052688ec813b5fa58b077d74c963949574623fe4cf67c12c347e7257229",
	"res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres": "5bdd67e659a0cce14abe3605f5a7fbfd85b0374d0a38be23cda326017235fe13",
	"res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres": "be97cdfd7367cd73172c4429ca212db0d1fc68bed34f4db6ce307d02a5225b94",
	"res://game/resources/materials/world/d1_current/b201_service_leaf.tres": "de9895a808e4d64afc2c727e77ef92b590c9c718266ba118e64c489e84690cfd",
	"res://game/resources/materials/world/d1_current/b201_warm_wall.tres": "6f5f6835790ab338454e72be58c2956deb6e470086797e209be0fab4d37ec788",
	"res://game/resources/materials/world/d1_current/shared_dark_glass.tres": "ad8931db8954fd5ebc8fdd809f70afb279dd74a36e53e1d9ca907c44409f10d3",
	"res://game/resources/materials/world/d1_current/shared_pale_frame.tres": "9a2de298ff545cf80c5da0ed0aa37d9d4ebbf10fec8eb78810af7e4d012d1436",
	ADAPTER_PATH: "499f6d2657b593ee5b0801cf1205a2925a993f3b1836922d3656a6d00c51cc19",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mounted := FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot")
	var args := _mounted_arguments()
	if mounted:
		_require(not args.is_empty(), "Mounted B201 audit requires one absolute PCK path and its independently computed SHA-256.")
		if not args.is_empty():
			_require(_pck_matches(args), "Mounted B201 audit PCK identity drifted.")
		_require(not _exists(PRIVATE_CATALOG), "Source recognition catalog leaked into the mounted package.")
		_require(not _exists(PRIVATE_PACKET), "Discovery-only B201 packet leaked into the mounted package.")
		_require(not _exists(PRIVATE_EVIDENCE), "B201 evidence leaked into the mounted package.")
	else:
		_require(args.is_empty(), "Source B201 package contract received mounted-only arguments.")
		_source_boundary_checks()
	_require(not _exists("res://override.cfg"), "Temporary root capture override is present.")
	_require(FileAccess.get_sha256(REGISTRY_PATH) == REGISTRY_SHA256, "Runtime registry hash drifted.")
	_require(FileAccess.get_sha256(CONTRACTS_PATH) == CONTRACTS_SHA256, "Adapter-contract hash drifted.")
	_require(FileAccess.get_sha256(CONFIG_PATH) == str(EXPECTED_RUNTIME_ASSETS[CONFIG_PATH]), "B201 config hash drifted.")
	var registry := _json(REGISTRY_PATH)
	var contracts := _json(CONTRACTS_PATH)
	_require(_version_contract_matches(registry, contracts), "Catalog/registry/contracts/loader/compiler compatibility or exact counts drifted.")
	_validate_registry_closure(registry, contracts)
	_validate_mounted_resources()
	var chunk := _json(CHUNK_PATH)
	var record := _record_for(chunk.get("records", []) as Array, RECEIVER_KEY)
	_require(not record.is_empty() and bool(ADAPTER.validate_chunk_records(chunk).get("ok", false)), "Exact supplied B201 chunk pair failed closed preflight.")
	# Editor Godot remains feature-tagged as `editor` when `--main-pack` mounts an
	# exported PCK. Source-only raw hash checks in the production adapter and
	# GeneratedWorldContract therefore cannot truthfully run in that environment:
	# materials are remapped and the six private source inputs are intentionally
	# excluded. Source mode proves construction and measured whole-world topology;
	# mounted mode proves this exact PCK, compiled authority, exclusions, and every
	# remap-resolved asset. The exported main-scene smoke supplies the complementary
	# non-editor whole-world execution gate for these same frozen package bytes.
	if not mounted and not record.is_empty():
		var result := BUILDER.new()._build_record(record, false)
		_require(bool(result.get("ok", false)), "Packaged B201 receiver construction failed: %s" % str(result))
		if bool(result.get("ok", false)):
			var receiver := result.get("node") as Node3D
			_require(_receiver_matches(receiver, result), "Packaged B201 host partition, topology, or ownership drifted.")
			receiver.free()
	if not mounted:
		var world_result := await _whole_world_matches()
		_require(bool(world_result.get("ok", false)), str(world_result.get("message", "Packaged B201 world failed.")))
	if not _failed:
		if mounted:
			print("PASS: mounted B201 package is exact and remap-aware: explicit PCK identity, 7/213, catalog/runtime 7, contracts/loader 6, compiler 1.6.0, one whole-receiver 40-run adapter, exact eight-asset closure, 735/950/964/66636/466/466 behavior contract, generic loader unwired, private roots and override absent; runtime topology remains a packaged main-scene smoke gate")
		else:
			print("PASS: source B201 package is exact and remap-aware: 7/213, catalog/runtime 7, contracts/loader 6, compiler 1.6.0, one whole-receiver 40-run adapter, exact eight-asset closure, constructed 735/950/964/66636/466/466 topology, sole host collision/spray ownership, generic loader unwired, private roots and override absent")
	quit(1 if _failed else 0)


func _mounted_arguments() -> Dictionary:
	var parsed := {}
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mounted-b201-pck="):
			parsed["pck"] = argument.trim_prefix("--mounted-b201-pck=")
		elif argument.begins_with("--mounted-b201-pck-sha256="):
			parsed["sha256"] = argument.trim_prefix("--mounted-b201-pck-sha256=")
		else:
			push_error("Unknown mounted B201 package argument: %s" % argument)
			return {}
	return parsed if parsed.size() == 2 else {}


func _pck_matches(args: Dictionary) -> bool:
	var path := str(args.get("pck", ""))
	var expected := str(args.get("sha256", ""))
	return path.is_absolute_path() and expected.length() == 64 and FileAccess.file_exists(path) and FileAccess.get_sha256(path) == expected


func _source_boundary_checks() -> void:
	_require(FileAccess.get_sha256(PRIVATE_CATALOG) == CATALOG_SHA256, "Current source catalog hash drifted.")
	_require(FileAccess.get_sha256(BUILDER_PATH) == "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c", "B201 builder dispatch bytes drifted.")
	_require(FileAccess.get_sha256(METER_UV_PATH) == "47e710b9ea7c5de5122430199e4105cbba5f672d22f59832f13b8004f16c5a1d", "Meter-UV dependency bytes drifted.")
	var closure := ""
	for path_value: Variant in EXPECTED_RUNTIME_ASSETS:
		var path := str(path_value)
		_require(FileAccess.get_sha256(path) == str(EXPECTED_RUNTIME_ASSETS[path_value]), "Source B201 runtime asset hash drifted: %s." % path)
		closure += FileAccess.get_file_as_string(path).to_lower() + "\n"
	for token: String in ["res://" + "discovery/", "res://" + "evidence/", "http" + "://", "https" + "://", "file" + "://", "/" + "volumes/", "/" + "users/", "source_assets"]:
		_require(token not in closure, "B201 eight-asset executable closure contains forbidden token %s." % token)
	var builder := FileAccess.get_file_as_string(BUILDER_PATH)
	_require(builder.count(ADAPTER_PATH) == 1 and builder.count("D1_B201_LIVE_ATTACHMENT.claims_record(record)") == 1 and builder.count("D1_B201_LIVE_ATTACHMENT.build_prepared(record, b201_prepared)") == 1, "World builder does not carry one exact B201 dispatch seam.")
	_require("facade_runtime_registry_loader" not in builder, "Generic facade registry loader was wired into world construction.")
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	for boundary: String in ["discovery/*", "discovery/**/*", "evidence/*", "evidence/**/*"]:
		_require(boundary in preset, "Export preset lost private boundary %s." % boundary)


func _version_contract_matches(registry: Dictionary, contracts: Dictionary) -> bool:
	var compatibility := registry.get("compatibility_contract", {}) as Dictionary
	var build := contracts.get("build_contract", {}) as Dictionary
	var loader := contracts.get("loader_contract", {}) as Dictionary
	var metric := registry.get("recognition_metric", {}) as Dictionary
	return str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/7" \
		and str(compatibility.get("catalog_schema_version", "")) == "ti.facade-recognition-catalog/7" \
		and str(compatibility.get("compiler_version", "")) == "1.6.0" \
		and str(compatibility.get("loader_api_version", "")) == "ti.facade-runtime-registry-loader/6" \
		and not bool(compatibility.get("forward_compatible", true)) and str(compatibility.get("unknown_version_policy", "")) == "reject" \
		and str(contracts.get("schema_version", "")) == "ti.facade-runtime-adapter-contracts/6" \
		and str(build.get("authoring_catalog_sha256", "")) == CATALOG_SHA256 \
		and str(build.get("compiler_version", "")) == "1.6.0" and str(build.get("runtime_registry_schema_version", "")) == "ti.facade-runtime-registry/7" \
		and str(loader.get("api_version", "")) == "ti.facade-runtime-registry-loader/6" and not bool(loader.get("instantiation_authorized", true)) \
		and registry.get("units", []).size() == 213 and int((registry.get("counts", {}) as Dictionary).get("direct_wall_receivers", -1)) == 214 \
		and (registry.get("active_runtime_adapters", []) as Array).size() == 6 \
		and (contracts.get("plans", []) as Array).size() == 15 \
		and (contracts.get("plans", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("integration_state", "")) == "package_safe_ready_for_integration").size() == 9 \
		and int(metric.get("numerator", -1)) == 7 and int(metric.get("denominator", -1)) == 213 and str(metric.get("display", "")) == "7/213"


func _validate_registry_closure(registry: Dictionary, contracts: Dictionary) -> void:
	var adapters := _records_for_receiver(registry.get("active_runtime_adapters", []) as Array, RECEIVER_KEY)
	var plans := _records_for_receiver(contracts.get("plans", []) as Array, RECEIVER_KEY)
	_require(adapters.size() == 1 and plans.size() == 1, "B201 does not have exactly one active adapter and one package plan.")
	if adapters.size() != 1 or plans.size() != 1:
		return
	var adapter := adapters[0] as Dictionary
	var plan := plans[0] as Dictionary
	var scope := adapter.get("active_receiver_scope", {}) as Dictionary
	var unit := _unit_for(registry.get("units", []) as Array, "physical-building:w34313545")
	var unit_receivers := _records_for_receiver(unit.get("direct_receivers", []) as Array, RECEIVER_KEY)
	var claim_status := unit.get("claim_status", {}) as Dictionary
	var recognition_receipts := unit.get("acceptance_records", []) as Array
	var behavior := plan.get("behavior_contract", {}) as Dictionary
	var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	var ownership := behavior.get("ownership_contract", {}) as Dictionary
	_require(str(adapter.get("source_key", "")) == SOURCE_KEY and str(plan.get("source_key", "")) == SOURCE_KEY, "B201 source binding drifted.")
	_require(str(adapter.get("runtime_content_mode", "")) == "active_d1_b201_host_partition_attachment" and str(plan.get("content_mode", "")) == "active_d1_b201_host_partition_attachment", "B201 content mode drifted.")
	_require(not unit.is_empty() and unit_receivers.size() == 1, "B201 adapter does not cross-link to physical-building:w34313545.")
	_require(str(adapter.get("review_status", "")) == "independent_exact_current_live_pass" and str(adapter.get("review_status_scope", "")) == REVIEW_STATUS_SCOPE, "B201 review status or its non-recognition scope drifted.")
	_require(str(adapter.get("recognition_acceptance_authority", "")) == RECOGNITION_ACCEPTANCE_AUTHORITY and str(adapter.get("recognition_acceptance_status", "")) == "accepted" and str(adapter.get("recognition_acceptance_status", "")) == str(claim_status.get("reference_recognizable", "")), "B201 recognition acceptance is not derived from its physical-unit authority.")
	_require(recognition_receipts.size() == 1 and str((recognition_receipts[0] as Dictionary).get("review_kind", "")) == "independent_reference_recognition" and str((recognition_receipts[0] as Dictionary).get("status", "")) == "accept", "B201 physical unit lacks its independent recognition acceptance receipt.")
	_require(str(scope.get("coverage", "")) == "whole_direct_wall_receiver" and int(scope.get("run_count", -1)) == 40 and (adapter.get("accepted_run_scopes", []) as Array).is_empty(), "B201 whole-receiver 40-run active scope drifted.")
	_require(_asset_map(adapter.get("runtime_assets", []) as Array) == EXPECTED_RUNTIME_ASSETS and _asset_map(plan.get("runtime_assets", []) as Array) == EXPECTED_RUNTIME_ASSETS and EXPECTED_RUNTIME_ASSETS.size() == 8, "B201 registry/plan exact eight-asset closure drifted.")
	_require((adapter.get("runtime_asset_projections", []) as Array).is_empty() and (plan.get("projection_descriptor_ids", []) as Array).is_empty(), "B201 acquired a pathless projection.")
	var executable := plan.get("executable_assets", []) as Array
	_require(executable.size() == 1 and str((executable[0] as Dictionary).get("path", "")) == ADAPTER_PATH and str((executable[0] as Dictionary).get("sha256", "")) == str(EXPECTED_RUNTIME_ASSETS[ADAPTER_PATH]), "B201 executable subset drifted.")
	_require(str(acceptance.get("independent_live_review_receipt_sha256", "")) == "b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772" and str(acceptance.get("evidence_manifest_sha256", "")) == "f169085620a0a9ff0c685e4dfa98442c5c31e4e580f1decdbd80e84b09c74fe3" and str(acceptance.get("capture_time_recognition_metric", "")) == "6/213" and int(acceptance.get("numerator_effect", -1)) == 1, "B201 acceptance receipt or single-unit effect drifted.")
	_require(str(geometry.get("world_topology_scope", "")) == WORLD_TOPOLOGY_SCOPE and str(geometry.get("decorative_geometry_signature", "")) == ADAPTER.EXPECTED_DECORATIVE_GEOMETRY_SIGNATURE and int(geometry.get("host_triangles", -1)) == 80 and int(geometry.get("eligible_host_triangles", -1)) == 20 and int(geometry.get("protected_host_triangles", -1)) == 60 and int(geometry.get("decorative_triangles", -1)) == 2064 and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 950 and int(geometry.get("world_surfaces", -1)) == 964 and int(geometry.get("world_triangles", -1)) == 66636 and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466, "B201 current-integration behavior geometry contract drifted.")
	_require(bool(ownership.get("host_collision_owner_preserved", false)) and bool(ownership.get("host_spray_owner_preserved", false)) and int(ownership.get("structural_owner_count", -1)) == 1 and int(ownership.get("shape_count", -1)) == 1 and int(ownership.get("spray_owner_count", -1)) == 1 and int(ownership.get("decorative_collision_nodes", -1)) == 0 and int(ownership.get("decorative_navigation_nodes", -1)) == 0 and int(ownership.get("decorative_spray_nodes", -1)) == 0, "B201 behavior ownership contract drifted.")


func _validate_mounted_resources() -> void:
	for path_value: Variant in EXPECTED_RUNTIME_ASSETS:
		var path := str(path_value)
		if path.ends_with(".json"):
			_require(FileAccess.file_exists(path) and FileAccess.get_sha256(path) == str(EXPECTED_RUNTIME_ASSETS[path_value]), "Packaged raw B201 config is missing or hash-drifted.")
		else:
			_require(ResourceLoader.exists(path), "Packaged remapped B201 resource is missing: %s." % path)
			if ResourceLoader.exists(path):
				_require(ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) != null, "Packaged remapped B201 resource is not loadable: %s." % path)


func _receiver_matches(receiver: Node3D, result: Dictionary) -> bool:
	var mesh_node := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_node.mesh as ArrayMesh if mesh_node != null else null
	var body := receiver.get_node_or_null("Collision") as StaticBody3D
	var shape_node := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var attachment := receiver.get_node_or_null("D1B201LiveAttachment") as Node3D
	return receiver.get_child_count() == 3 and mesh != null and mesh.get_surface_count() == 2 \
		and mesh.surface_get_name(0) == "generated_record_protected_runs_10_39" and mesh.surface_get_name(1) == "d1_b201_public_wsw_runs_0_9" \
		and int((mesh.surface_get_arrays(0) as Array)[Mesh.ARRAY_INDEX].size() / 3) == 60 and int((mesh.surface_get_arrays(1) as Array)[Mesh.ARRAY_INDEX].size() / 3) == 20 \
		and body != null and shape_node != null and shape_node.shape is ConcavePolygonShape3D and (shape_node.shape as ConcavePolygonShape3D).get_faces().size() == 240 \
		and body.is_in_group("spray_receiver_wall") and str(body.get_meta("derived_object_key", "")) == RECEIVER_KEY and body.get_meta("source_keys", []) == [SOURCE_KEY] \
		and attachment != null and str(attachment.get_meta("decorative_geometry_signature", "")) == ADAPTER.EXPECTED_DECORATIVE_GEOMETRY_SIGNATURE \
		and ADAPTER.render_topology(attachment) == {"mesh_instances": 6, "surfaces": 6, "triangles": 2064} \
		and _count_type(attachment, CollisionObject3D) == 0 and _count_type(attachment, CollisionShape3D) == 0 and _count_type(attachment, NavigationRegion3D) == 0 and not _any_group(attachment, "spray_receiver") and not _any_group(attachment, "spray_receiver_wall") \
		and int(result.get("mesh_instances", -1)) == 7 and int(result.get("surfaces", -1)) == 8 and int(result.get("triangles", -1)) == 2144


func _whole_world_matches() -> Dictionary:
	var packed := load("res://game/scenes/world/world_root.tscn") as PackedScene
	if packed == null:
		return {"ok": false, "message": "WorldRoot did not load."}
	var world := packed.instantiate() as WorldLoader
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(world)
	world.load_world(MANIFEST_PATH)
	var started := Time.get_ticks_msec()
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 45000:
		await process_frame
	var evidence := world.get_runtime_evidence()
	var actual := {"rows": evidence.playable_rows, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "bodies": evidence.static_bodies, "shapes": evidence.shapes}
	var nodes := _nodes_for_key(world, RECEIVER_KEY)
	var ok := failures.is_empty() and reports.size() == 1 and actual == EXPECTED_WORLD and nodes.size() == 1 \
		and _receiver_matches(nodes[0] as Node3D, {"mesh_instances": 7, "surfaces": 8, "triangles": 2144})
	var message := "B201 package world drift: failures=%s reports=%d nodes=%d topology=%s" % [failures, reports.size(), nodes.size(), actual]
	root.remove_child(world)
	world.free()
	return {"ok": ok, "message": message}


func _records_for_receiver(records: Array, receiver: String) -> Array:
	var matches := []
	for value: Variant in records:
		if str((value as Dictionary).get("receiver_key", "")) == receiver:
			matches.append(value)
	return matches


func _asset_map(assets: Array) -> Dictionary:
	var mapped := {}
	for value: Variant in assets:
		var asset := value as Dictionary
		var path := str(asset.get("path", ""))
		if path.is_empty() or mapped.has(path):
			return {}
		mapped[path] = str(asset.get("sha256", ""))
	return mapped


func _record_for(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		if str((value as Dictionary).get("object_key", "")) == key:
			return value as Dictionary
	return {}


func _unit_for(units: Array, unit_id: String) -> Dictionary:
	for value: Variant in units:
		if str((value as Dictionary).get("unit_id", "")) == unit_id:
			return value as Dictionary
	return {}


func _nodes_for_key(root_node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if str(node.get_meta("derived_object_key", "")) == key and node.get_node_or_null("D1B201LiveAttachment") != null:
			result.append(node)
	return result


func _count_type(node: Node, type: Variant) -> int:
	var count := 1 if is_instance_of(node, type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, type)
	return count


func _any_group(node: Node, group: StringName) -> bool:
	if node.is_in_group(group):
		return true
	for child: Node in node.get_children():
		if _any_group(child, group):
			return true
	return false


func _exists(path: String) -> bool:
	return FileAccess.file_exists(path) or ResourceLoader.exists(path)


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("D1_B201_PACKAGE_FAIL: %s" % message)
	return false
