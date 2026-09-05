extends SceneTree

## Source and direct-mounted-PCK boundary for the accepted B225 v8 authority.
## Source mode proves canonical construction and the exact current authority.
## Mounted mode proves the explicit export identity, remap-resolved production
## closure, and absence of every historical candidate activation route.

const ADAPTER := preload("res://game/scripts/world/facades/d1_b225_live_attachment.gd")
const BUILDER := preload("res://game/scripts/world/world_chunk_builder.gd")
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const CONTRACTS_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const SCHEMA_PATH := "res://discovery/facades/facade-recognition-catalog.schema.json"
const LOADER_PATH := "res://game/scripts/world/facades/facade_runtime_registry_loader.gd"
const FOCUSED_V8_CONTRACT_PATH := "res://game/tests/headless_d1_b225_postpromotion_v8_contract.gd"
const PACKAGE_CONTRACT_PATH := "res://game/tests/headless_d1_b225_postpromotion_v8_package_contract.gd"
const CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b225_live_attachment.json"
const ADAPTER_PATH := "res://game/scripts/world/facades/d1_b225_live_attachment.gd"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_-1.json"
const MANIFEST_PATH := "res://generated/world/manifest.json"
const MAIN_SCENE_PATH := "res://game/scenes/main.tscn"
const WALL_KEY := "building:w95934119:wall"
const ROOF_KEY := "building:w95934119:roof"
const SOURCE_KEY := "w95934119"
const EXPECTED_WORLD := {"rows": 735, "meshes": 952, "surfaces": 967, "triangles": 67716, "bodies": 466, "shapes": 466}
const REGISTRY_SHA256 := "109f83f40450e9c71ef6d39f1659e76eac5f1457fcfab772538b471cc74c0051"
const CONTRACTS_SHA256 := "dd2d13e3b0f6eee1f8c5f2957927c4f3caba43b31883beea925f9a91b826d65c"
const CATALOG_SHA256 := "d95be7bec8f0eabe97a9b5f7fefe1ce54ec7cbf940d85d28518ff6979eeb16ea"
const SCHEMA_SHA256 := "44584e92e1652fc930f47882b4a83304f5216c14173eb805bc9ce68ea9927cac"
const LOADER_SHA256 := "12e6c64b23b0783ed240b3d6c02499c3940c2b6a14344caa29778b850db06c04"
const FOCUSED_V8_CONTRACT_SHA256 := "fd63ced9552dd9a1749de0047d2cebd1b46a1b093ebe1645dd4fcace19186353"
const CONFIG_SHA256 := "80b42c33fce84361aa7512f64305f5bff273e8fed95640ca4f9c19d49d55621d"
const ADAPTER_SHA256 := "4b1defd92a77b23de692437f044dfaa579fa2ee5b3dee77465ec8404f1644ac9"
const BUILDER_SHA256 := "de4a2924d275a51dfd08aae1f0ef21daac33395b1fcfe98e260fbc90737dd725"
const B225_UNIT_ID := "physical-building:w95934119"
const B225_ADAPTER_ID := "active-adapter:d1-b225-live:building:w95934119:wall"
const B201_RECEIVER_KEY := "building:w34313545:wall"
const FROZEN_CAPTURE_MANIFEST_SHA256 := "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc"
const FROZEN_EVIDENCE_TREE_SHA256 := "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7"
const FROZEN_REVIEW_SHA256 := "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95"
const SIX_PRODUCTION_ASSETS := {
	CONFIG_PATH: CONFIG_SHA256,
	ADAPTER_PATH: ADAPTER_SHA256,
	"res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres": "7fa7f3165dee560c48f5a092f317900b87b0876f27bb6a0e937b9c406a8d4ea1",
	"res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png": "63e755e9fe5a5dcfb662b4265f1e769fc1b371987b55579b1ca4ffb63015015b",
	"res://game/resources/materials/world/d1_current/shared_dark_glass.tres": "ad8931db8954fd5ebc8fdd809f70afb279dd74a36e53e1d9ca907c44409f10d3",
	"res://game/resources/materials/world/d1_current/shared_pale_frame.tres": "9a2de298ff545cf80c5da0ed0aa37d9d4ebbf10fec8eb78810af7e4d012d1436",
}
const HISTORICAL_CANDIDATE_ROUTES := [
	"res://game/tests/support/d1_b225_" + "prepromotion_candidate_seam.gd",
	"res://game/tests/support/d1_b225_" + "prepromotion_candidate_seam.gd.uid",
	"res://game/tests/d1_b225_prepromotion_candidate_capture.gd",
	"res://game/tests/d1_b225_prepromotion_candidate_capture.gd.uid",
	"res://game/tests/headless_d1_b225_live_attachment_contract.gd",
	"res://game/tests/headless_d1_b225_live_attachment_contract.gd.uid",
]
const PRIVATE_PACKAGE_PATHS := [
	CATALOG_PATH,
	SCHEMA_PATH,
	"res://evidence/first-playable/d1-b225-prepromotion-candidate-r3-2026-09-05/capture-manifest.json",
	"res://evidence/first-playable/d1-b225-production-attachment-v7-staging-2026-09-05/capture-manifest.json",
	"res://evidence/reviews/d1-b225-prepromotion-candidate-r3-2026-09-05-INDEPENDENT_VISUAL_REVIEW.md",
	"res://evidence/reviews/d1-b225-production-attachment-v7-staging-2026-09-05-INDEPENDENT_VISUAL_REVIEW.md",
	"res://override.cfg",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mounted := FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot")
	var arguments := _mounted_arguments()
	if mounted:
		_require(not arguments.is_empty(), "Mounted B225 v8 audit requires one absolute PCK path and exact independently computed SHA-256.")
		if not arguments.is_empty():
			_require(_pck_matches(arguments), "Mounted B225 v8 PCK identity drifted.")
	else:
		_require(arguments.is_empty(), "Source B225 v8 package contract received mounted-only arguments.")
		_source_boundary_checks()
	_require(not _exists("res://override.cfg"), "Temporary capture override is present in source or mounted package scope.")
	_require(_authority_matches(mounted), "B225 postpromotion authority drifted from registry/catalog v8, contracts/loader v7, compiler 1.7.0, exact 8/213, one B225 acceptance/adapter, or sole current-topology ownership.")
	_validate_package_resources(mounted)
	if mounted:
		for path: String in PRIVATE_PACKAGE_PATHS:
			_require(not _exists(path), "Mounted PCK exposes excluded private/capture path: %s." % path)
		for path: String in _mounted_candidate_route_paths():
			_require(not _exists(path), "Mounted PCK exposes a historical B225 candidate activation route: %s." % path)
	else:
		var chunk := _json(CHUNK_PATH)
		var parents := {"ground": Node3D.new(), "roads": Node3D.new(), "buildings": Node3D.new()}
		var report := BUILDER.new().build_chunk(chunk, parents)
		_require(bool(report.get("ok", false)), "Canonical builder rejected exact B225 source chunk: %s." % report)
		if bool(report.get("ok", false)):
			var staging := report.get("node") as Node3D
			_require(_staged_chunk_matches(staging), "Canonical B225 chunk production topology, partition, or ownership drifted.")
			staging.free()
		for parent: Node3D in parents.values():
			parent.free()
		var world_result := await _whole_world_matches()
		_require(bool(world_result.get("ok", false)), str(world_result.get("message", "B225 source whole-world package check failed.")))
	if not _failed:
		if mounted:
			print("PASS: mounted B225 postpromotion v8 PCK is exact at 8/213: explicit PCK identity, exact six-asset closure, new v8 package contract and ordinary main present, candidate/private/override routes absent, and no downstream receipt feeds back into authority")
		else:
			print("PASS: source B225 postpromotion v8 package contract is exact at 8/213: canonical 735/952/967/67716/466/466 construction, exact six-asset closure, narrow exclusions declared, override absent, and no additional recognition credit")
	quit(1 if _failed else 0)


func _mounted_arguments() -> Dictionary:
	var parsed := {}
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mounted-b225-v8-pck="):
			if parsed.has("pck"):
				_failed = true
				push_error("Duplicate mounted B225 v8 PCK argument.")
				return {}
			parsed["pck"] = argument.trim_prefix("--mounted-b225-v8-pck=")
		elif argument.begins_with("--mounted-b225-v8-pck-sha256="):
			if parsed.has("sha256"):
				_failed = true
				push_error("Duplicate mounted B225 v8 PCK SHA-256 argument.")
				return {}
			parsed["sha256"] = argument.trim_prefix("--mounted-b225-v8-pck-sha256=")
		else:
			_failed = true
			push_error("Unknown mounted B225 v8 package argument: %s" % argument)
			return {}
	if parsed.is_empty():
		return {}
	if parsed.size() != 2 or str(parsed.get("pck", "")).is_empty() or not _lowercase_sha256(str(parsed.get("sha256", ""))):
		_failed = true
		push_error("Mounted B225 v8 package arguments are incomplete, empty, or malformed.")
		return {}
	return parsed


func _pck_matches(arguments: Dictionary) -> bool:
	var path := str(arguments.get("pck", ""))
	var expected_sha256 := str(arguments.get("sha256", ""))
	return path.is_absolute_path() \
		and _lowercase_sha256(expected_sha256) \
		and FileAccess.file_exists(path) \
		and FileAccess.get_sha256(path) == expected_sha256


func _mounted_candidate_route_paths() -> Array[String]:
	var paths: Array[String] = []
	for path: String in HISTORICAL_CANDIDATE_ROUTES:
		paths.append(path)
		if path.ends_with(".gd"):
			paths.append(path + ".remap")
			paths.append(path.trim_suffix(".gd") + ".gdc")
	return paths


func _source_boundary_checks() -> void:
	_require(FileAccess.get_sha256(CONFIG_PATH) == CONFIG_SHA256, "B225 production config bytes drifted.")
	_require(FileAccess.get_sha256(ADAPTER_PATH) == ADAPTER_SHA256, "B225 production adapter bytes drifted.")
	_require(FileAccess.get_sha256(BUILDER_PATH) == BUILDER_SHA256, "B225 production builder bytes drifted.")
	var direct_runtime_source := FileAccess.get_file_as_string(CONFIG_PATH) + "\n" + FileAccess.get_file_as_string(ADAPTER_PATH)
	for token: String in ["res://discovery/", "res://evidence/", "http://", "https://", "file://", "/Volumes/", "/Users/", "source_assets"]:
		_require(token not in direct_runtime_source, "B225 direct runtime closure contains forbidden token %s." % token)
	var builder_source := FileAccess.get_file_as_string(BUILDER_PATH)
	_require(builder_source.count('preload("%s")' % ADAPTER_PATH) == 1, "Canonical builder does not preload the B225 adapter exactly once.")
	_require(builder_source.count("D1_B225_LIVE_ATTACHMENT.validate_chunk_records(chunk)") == 1, "Canonical builder does not validate B225 chunk membership exactly once.")
	_require(builder_source.count("D1_B225_LIVE_ATTACHMENT.build_prepared(record, b225_prepared)") == 1, "Canonical builder does not attach B225 exactly once.")
	for token: String in ["ProjectSettings", "OS.get_environment", "OS.get_cmdline", "get_cmdline_user_args", "--d1-b225", "--b225"]:
		_require(token not in FileAccess.get_file_as_string(ADAPTER_PATH) and token not in FileAccess.get_file_as_string(CONFIG_PATH) and token not in builder_source, "B225 production route acquired override token %s." % token)
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	for boundary: String in ["discovery/*", "discovery/**/*", "evidence/*", "evidence/**/*"]:
		_require(boundary in preset, "Export preset lost private boundary %s." % boundary)
	for path: String in HISTORICAL_CANDIDATE_ROUTES:
		_require(path.trim_prefix("res://") in preset, "Export preset does not narrowly exclude historical candidate path %s." % path)


func _authority_matches(mounted: bool) -> bool:
	if FileAccess.get_sha256(REGISTRY_PATH) != REGISTRY_SHA256 or FileAccess.get_sha256(CONTRACTS_PATH) != CONTRACTS_SHA256:
		return false
	if not mounted and (FileAccess.get_sha256(CATALOG_PATH) != CATALOG_SHA256 \
	or FileAccess.get_sha256(SCHEMA_PATH) != SCHEMA_SHA256 \
	or FileAccess.get_sha256(LOADER_PATH) != LOADER_SHA256 \
	or FileAccess.get_sha256(FOCUSED_V8_CONTRACT_PATH) != FOCUSED_V8_CONTRACT_SHA256 \
	or FileAccess.get_file_as_string(SCHEMA_PATH).contains("\"candidates\"")):
		return false
	var registry := _json(REGISTRY_PATH)
	var contracts := _json(CONTRACTS_PATH)
	var compatibility := registry.get("compatibility_contract", {}) as Dictionary
	var build := contracts.get("build_contract", {}) as Dictionary
	var loader := contracts.get("loader_contract", {}) as Dictionary
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted_ids := metric.get("accepted_physical_unit_ids", []) as Array
	var unit := _record_for_id(registry.get("units", []) as Array, "unit_id", B225_UNIT_ID)
	var receiver := _record_for_id(unit.get("direct_receivers", []) as Array, "receiver_key", WALL_KEY)
	var receipts := unit.get("acceptance_records", []) as Array
	var adapters := registry.get("active_runtime_adapters", []) as Array
	var b225_adapters := _records_for_receiver(adapters, WALL_KEY)
	var b201_adapters := _records_for_receiver(adapters, B201_RECEIVER_KEY)
	var plans := contracts.get("plans", []) as Array
	var ready_plans := plans.filter(func(value: Variant) -> bool: return str((value as Dictionary).get("integration_state", "")) == "package_safe_ready_for_integration")
	if receipts.size() != 1 or b225_adapters.size() != 1 or b201_adapters.size() != 1:
		return false
	var receipt := receipts[0] as Dictionary
	var b225_adapter := b225_adapters[0] as Dictionary
	var b225_behavior := ((b225_adapter.get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary)
	var b225_acceptance := b225_behavior.get("acceptance_contract", {}) as Dictionary
	var b225_geometry := b225_behavior.get("geometry_contract", {}) as Dictionary
	var b201_geometry := (((b201_adapters[0] as Dictionary).get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary).get("geometry_contract", {}) as Dictionary
	var current_topology_owners := []
	for value: Variant in adapters:
		if not value is Dictionary:
			return false
		var adapter := value as Dictionary
		var active_contract_value: Variant = adapter.get("active_runtime_contract")
		if not active_contract_value is Dictionary:
			continue
		var behavior_value: Variant = (active_contract_value as Dictionary).get("behavior_contract")
		if not behavior_value is Dictionary:
			continue
		var behavior := behavior_value as Dictionary
		if str((behavior.get("geometry_contract", {}) as Dictionary).get("world_topology_scope", "")) == "current_integration_topology":
			current_topology_owners.append(str(adapter.get("adapter_id", "")))
	return str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/8" \
		and str(compatibility.get("catalog_schema_version", "")) == "ti.facade-recognition-catalog/8" \
		and str(compatibility.get("compiler_version", "")) == "1.7.0" \
		and str(compatibility.get("loader_api_version", "")) == "ti.facade-runtime-registry-loader/7" \
		and not bool(compatibility.get("forward_compatible", true)) \
		and str(contracts.get("schema_version", "")) == "ti.facade-runtime-adapter-contracts/7" \
		and str(build.get("compiler_version", "")) == "1.7.0" \
		and str(build.get("runtime_registry_schema_version", "")) == "ti.facade-runtime-registry/8" \
		and str(loader.get("api_version", "")) == "ti.facade-runtime-registry-loader/7" \
		and not bool(loader.get("instantiation_authorized", true)) \
		and int(metric.get("numerator", -1)) == 8 and int(metric.get("denominator", -1)) == 213 and str(metric.get("display", "")) == "8/213" \
		and accepted_ids.size() == 8 and accepted_ids.count(B225_UNIT_ID) == 1 \
		and (registry.get("units", []) as Array).size() == 213 and adapters.size() == 7 \
		and plans.size() == 16 and ready_plans.size() == 10 \
		and str((unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "accepted" \
		and (unit.get("active_runtime_adapter_ids", []) as Array) == [B225_ADAPTER_ID] \
		and not receiver.is_empty() and str(receiver.get("runtime_adapter_id", "")) == B225_ADAPTER_ID \
		and str(receiver.get("runtime_content_mode", "")) == "active_d1_b225_host_partition_attachment" \
		and str(b225_adapter.get("adapter_id", "")) == B225_ADAPTER_ID \
		and str(receipt.get("capture_time_recognition_metric", "")) == "7/213" \
		and str(receipt.get("evidence_manifest_sha256", "")) == FROZEN_CAPTURE_MANIFEST_SHA256 \
		and str(receipt.get("evidence_tree_sha256", "")) == FROZEN_EVIDENCE_TREE_SHA256 \
		and str(receipt.get("review_receipt_sha256", "")) == FROZEN_REVIEW_SHA256 \
		and int(receipt.get("numerator_effect", -1)) == 1 \
		and str(b225_acceptance.get("accepted_physical_unit_id", "")) == B225_UNIT_ID \
		and int(b225_acceptance.get("numerator_effect", -1)) == 1 \
		and _topology_matches(b225_geometry, "current_integration_topology", EXPECTED_WORLD) \
		and _topology_matches(b201_geometry, "pre_b225_integration_live_parity", {"rows": 735, "meshes": 950, "surfaces": 964, "triangles": 66636, "bodies": 466, "shapes": 466}) \
		and current_topology_owners == [B225_ADAPTER_ID]


func _validate_package_resources(mounted: bool) -> void:
	_require(_exists(MAIN_SCENE_PATH), "Package closure is missing ordinary main.tscn.")
	_require(_exists(PACKAGE_CONTRACT_PATH), "Package closure is missing the new B225 v8 package contract.")
	_require(get_script() != null and get_script().resource_path == PACKAGE_CONTRACT_PATH, "New B225 v8 package contract is not the loaded mounted/source script.")
	_require(_exists(FOCUSED_V8_CONTRACT_PATH), "Package closure is missing the focused B225 v8 bridge.")
	_require(ResourceLoader.load(FOCUSED_V8_CONTRACT_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) != null, "Focused B225 v8 bridge is not remap-loadable.")
	_require(_exists(BUILDER_PATH), "Package closure is missing canonical world builder.")
	_require(_exists(CHUNK_PATH) and _exists(MANIFEST_PATH), "Package closure is missing exact generated world/chunk.")
	_require(FileAccess.get_sha256(CONFIG_PATH) == CONFIG_SHA256, "Packaged raw B225 config is absent or hash-drifted.")
	for path_value: Variant in SIX_PRODUCTION_ASSETS:
		var path := str(path_value)
		_require(_exists(path), "Package closure is missing B225 production asset %s." % path)
		if not path.ends_with(".json") and _exists(path):
			_require(ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) != null, "Package B225 resource is not remap-loadable: %s." % path)
		if not mounted:
			_require(FileAccess.get_sha256(path) == str(SIX_PRODUCTION_ASSETS[path_value]), "Source B225 v8 production asset hash drifted: %s." % path)


func _staged_chunk_matches(staging: Node3D) -> bool:
	var walls := _nodes_for_key(staging, WALL_KEY)
	var roofs := _nodes_for_key(staging, ROOF_KEY)
	if walls.size() != 1 or roofs.size() != 1:
		return false
	var wall := walls[0]
	var roof := roofs[0]
	var mesh_instance := wall.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := wall.get_node_or_null("Collision") as StaticBody3D
	var shape_node := wall.get_node_or_null("Collision/Shape") as CollisionShape3D
	var attachment := wall.get_node_or_null("D1B225LiveAttachment") as Node3D
	var roof_mesh := roof.get_node_or_null("Mesh") as MeshInstance3D
	var roof_body := roof.get_node_or_null("Collision") as StaticBody3D
	return mesh != null and mesh.get_surface_count() == 2 \
		and mesh.surface_get_name(0) == "generated_record_protected_runs_0_9" \
		and mesh.surface_get_name(1) == "d1_b225_nnw_runs_10_13" \
		and _surface_triangles(mesh, 0) == 20 and _surface_triangles(mesh, 1) == 8 \
		and body != null and shape_node != null and shape_node.shape is ConcavePolygonShape3D \
		and (shape_node.shape as ConcavePolygonShape3D).get_faces().size() == 84 \
		and body.is_in_group("spray_receiver_wall") and str(body.get_meta("derived_object_key", "")) == WALL_KEY \
		and attachment != null and _count_type(attachment, MultiMeshInstance3D) == 2 \
		and _count_type(attachment, CollisionObject3D) == 0 and _count_type(attachment, CollisionShape3D) == 0 \
		and _count_type(attachment, NavigationRegion3D) == 0 and _count_type(attachment, Decal) == 0 \
		and str(attachment.get_meta("integration_stage", "")) == "production_runtime_attachment" \
		and not bool(attachment.get_meta("reference_recognizable", true)) \
		and roof_mesh != null and roof_body != null and not roof_body.is_in_group("spray_receiver_wall") \
		and roof.get_node_or_null("D1B225LiveAttachment") == null


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
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await process_frame
	var evidence := world.get_runtime_evidence()
	var actual := {"rows": evidence.playable_rows, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "bodies": evidence.static_bodies, "shapes": evidence.shapes}
	var attachments := 0
	for node: Node in world.find_children("*", "", true, false):
		if node.name == "D1B225LiveAttachment":
			attachments += 1
	var walls := _nodes_for_key(world, WALL_KEY)
	var roofs := _nodes_for_key(world, ROOF_KEY)
	var ok := failures.is_empty() and reports.size() == 1 and actual == EXPECTED_WORLD \
		and attachments == 1 and walls.size() == 1 and roofs.size() == 1 \
		and _staged_chunk_matches(_common_ancestor(walls[0], roofs[0]))
	var message := "B225 package world drift: failures=%s reports=%d wall/roof=%d/%d attachments=%d topology=%s" % [failures, reports.size(), walls.size(), roofs.size(), attachments, actual]
	root.remove_child(world)
	world.free()
	return {"ok": ok, "message": message}


func _common_ancestor(first: Node, second: Node) -> Node3D:
	var ancestor := first.get_parent()
	while ancestor != null:
		if ancestor.is_ancestor_of(second):
			return ancestor as Node3D
		ancestor = ancestor.get_parent()
	return null


func _nodes_for_key(root_node: Node, key: String) -> Array[Node]:
	var matches: Array[Node] = []
	if root_node == null:
		return matches
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if str(node.get_meta("derived_object_key", "")) == key \
		and node.get_node_or_null("Mesh") is MeshInstance3D:
			matches.append(node)
	return matches


func _records_for_receiver(records: Array, receiver_key: String) -> Array:
	var matches := []
	for value: Variant in records:
		if value is Dictionary and str((value as Dictionary).get("receiver_key", "")) == receiver_key:
			matches.append(value)
	return matches


func _record_for_id(records: Array, key: String, expected: String) -> Dictionary:
	for value: Variant in records:
		if value is Dictionary and str((value as Dictionary).get(key, "")) == expected:
			return value as Dictionary
	return {}


func _surface_triangles(mesh: ArrayMesh, surface_index: int) -> int:
	var arrays := mesh.surface_get_arrays(surface_index)
	return int((arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)


func _topology_matches(geometry: Dictionary, scope: String, expected: Dictionary) -> bool:
	return str(geometry.get("world_topology_scope", "")) == scope \
		and int(geometry.get("world_records", -1)) == int(expected.rows) \
		and int(geometry.get("world_mesh_instances", -1)) == int(expected.meshes) \
		and int(geometry.get("world_surfaces", -1)) == int(expected.surfaces) \
		and int(geometry.get("world_triangles", -1)) == int(expected.triangles) \
		and int(geometry.get("world_static_bodies", -1)) == int(expected.bodies) \
		and int(geometry.get("world_shapes", -1)) == int(expected.shapes)


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _exists(path: String) -> bool:
	return FileAccess.file_exists(path) or ResourceLoader.exists(path)


func _lowercase_sha256(value: String) -> bool:
	if value.length() != 64 or value != value.to_lower():
		return false
	for index in value.length():
		if value[index] not in "0123456789abcdef":
			return false
	return true


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("D1_B225_POSTPROMOTION_V8_PACKAGE_FAIL: %s" % message)
	return false
