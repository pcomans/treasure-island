extends SceneTree

## Source and direct-mounted-PCK boundary for fresh D2 1441 production evidence.
## The accepted authority remains v8 / 8-of-213. The mounted ordinary world may
## contain the reviewed live replacement through ordinary main, but this contract
## grants no credit and exposes no alternate standalone activation route.

const D2_LIVE := preload("res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd")
const D2_SOURCE_KEY := "w95934105"
const D2_WALL_KEY := "building:w95934105:wall"
const D2_ROOF_KEY := "building:w95934105:roof"
const D2_UNIT_ID := "physical-building:w95934105"
const D2_CAPTURE_PATH := "res://game/tests/d2_1441_production_attachment_capture.gd"
const D2_FOCUSED_PATH := "res://game/tests/headless_d2_1441_production_attachment_contract.gd"
const D2_PACKAGE_PATH := "res://game/tests/headless_d2_1441_production_attachment_package_contract.gd"
const D2_SOURCE_PACKAGE_PATH := "res://game/tests/headless_d2_1441_chinook_live_replacement_package_contract.gd"
const D2_CONFIG_PATH := "res://game/resources/facades/d2_1441_chinook_live_replacement.json"
const D2_ADAPTER_PATH := "res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd"
const D2_FACTORY_PATH := "res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd"
const D2_FACTORY_CONFIG_PATH := "res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json"
const D2_KIT_PATH := "res://game/scripts/world/facades/site_12_housing_kit.gd"
const D2_BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const D2_MAIN_SCRIPT_PATH := "res://game/scripts/main.gd"
const D2_MAIN_SCENE_PATH := "res://game/scenes/main.tscn"
const D2_WORLD_SCENE_PATH := "res://game/scenes/world/world_root.tscn"
const D2_CHUNK_PATH := "res://generated/world/chunks/x_-1__z_-1.json"
const D2_MANIFEST_PATH := "res://generated/world/manifest.json"
const D2_REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const D2_CONTRACTS_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const D2_CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const D2_SCHEMA_PATH := "res://discovery/facades/facade-recognition-catalog.schema.json"
const D2_LOADER_PATH := "res://game/scripts/world/facades/facade_runtime_registry_loader.gd"
const D2_COMPILER_PATH := "res://tools/build_facade_recognition_registry.mjs"
const D2_EXPORT_PRESET_PATH := "res://export_presets.cfg"
const D2_PRODUCTION_WORLD := {"rows": 735, "meshes": 959, "surfaces": 974, "triangles": 69252, "bodies": 466, "shapes": 466}
const D2_CAPTURE_TIME_METRIC := "8/213"
const D2_CONFIG_SHA256 := "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111"
const D2_ADAPTER_SHA256 := "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1"
const D2_BUILDER_SHA256 := "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a"
const D2_MAIN_SHA256 := "1c284eb4d8ee5954500fe36c3ab6845bc7233728da26f5f6848dd8de9a627232"
const D2_CHUNK_SHA256 := "5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b"
const D2_REGISTRY_SHA256 := "109f83f40450e9c71ef6d39f1659e76eac5f1457fcfab772538b471cc74c0051"
const D2_CONTRACTS_SHA256 := "dd2d13e3b0f6eee1f8c5f2957927c4f3caba43b31883beea925f9a91b826d65c"
const D2_CATALOG_SHA256 := "d95be7bec8f0eabe97a9b5f7fefe1ce54ec7cbf940d85d28518ff6979eeb16ea"
const D2_SCHEMA_SHA256 := "44584e92e1652fc930f47882b4a83304f5216c14173eb805bc9ce68ea9927cac"
const D2_LOADER_SHA256 := "12e6c64b23b0783ed240b3d6c02499c3940c2b6a14344caa29778b850db06c04"
const D2_COMPILER_SHA256 := "eee17772b1beb71b3d6bd87800035a0c1c47a7c80473014c578bb055a5ddf0c9"
const D2_MAPPED_RUNS: Array[int] = [10, 12, 13, 15]
const D2_PROTECTED_RUNS: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14]
const D2_REQUIRED_RUNTIME_CLOSURE := [
	D2_CONFIG_PATH,
	D2_ADAPTER_PATH,
	D2_FACTORY_PATH,
	D2_FACTORY_CONFIG_PATH,
	D2_KIT_PATH,
	"res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
	"res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
]
const D2_MOUNTED_EXCLUDED_PATHS := [
	D2_CATALOG_PATH,
	D2_SCHEMA_PATH,
	"res://discovery/",
	"res://evidence/",
	"res://source_assets/",
	"res://override.cfg",
	"res://game/scenes/world/facades/site_12_housing/d2_1441_chinook_standalone_hero_prototype.tscn",
	"res://game/tests/d2_1441_chinook_standalone_hero_capture.gd",
	"res://game/tests/d2_1441_chinook_standalone_hero_capture.gd.uid",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_contract.gd",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_contract.gd.uid",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_evidence_contract.gd",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_evidence_contract.gd.uid",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_package_contract.gd",
	"res://game/tests/headless_d2_1441_chinook_standalone_hero_package_contract.gd.uid",
]

var _d2_failed := false


func _initialize() -> void:
	call_deferred("_d2_run")


func _d2_run() -> void:
	var mounted := FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot")
	var arguments := _d2_mounted_arguments()
	if mounted:
		_d2_require(not arguments.is_empty(), "Mounted D2 production audit requires one absolute PCK path and exact independently computed SHA-256.")
		if not arguments.is_empty():
			_d2_require(_d2_pck_matches(arguments), "Mounted D2 production PCK identity drifted.")
	else:
		_d2_require(arguments.is_empty(), "Source D2 package contract received mounted-only arguments.")
		_d2_source_boundary_checks()
	_d2_require(not _d2_exists("res://override.cfg"), "Temporary capture override is present.")
	_d2_require(_d2_authority_matches(mounted), "Accepted authority drifted from exact registry/catalog v8, contracts/loader v7, compiler 1.7.0, or 8/213; 1441 must remain placeholder-owned and uncredited.")
	_d2_validate_package_resources(mounted)
	if mounted:
		for path: String in D2_MOUNTED_EXCLUDED_PATHS:
			_d2_require(not _d2_exists_with_remaps(path), "Mounted PCK exposes excluded authoring/evidence/standalone activation path: %s." % path)
	else:
		var ordinary := await _d2_ordinary_main_matches()
		_d2_require(bool(ordinary.get("ok", false)), str(ordinary.get("message", "D2 ordinary-main package check failed.")))
	if not _d2_failed:
		if mounted:
			print("PASS: mounted D2 1441 production PCK identity and closure are exact; ordinary main and its distinct live route are present, standalone activation/private routes are absent, authority stays v8 8/213, recognition_credit=false, additional_credit=false, promotion=false")
		else:
			print("PASS: source D2 1441 production package boundary is exact and export-ready; ordinary main is already integrated while v8 8/213 authority remains byte-frozen and recognition_credit=false, additional_credit=false, promotion=false")
	quit(1 if _d2_failed else 0)


func _d2_mounted_arguments() -> Dictionary:
	var parsed := {}
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mounted-d2-1441-production-pck="):
			if parsed.has("pck"):
				_d2_failed = true
				return {}
			parsed["pck"] = argument.trim_prefix("--mounted-d2-1441-production-pck=")
		elif argument.begins_with("--mounted-d2-1441-production-pck-sha256="):
			if parsed.has("sha256"):
				_d2_failed = true
				return {}
			parsed["sha256"] = argument.trim_prefix("--mounted-d2-1441-production-pck-sha256=")
		else:
			_d2_failed = true
			push_error("D2_1441_PRODUCTION_PACKAGE_FAIL: unknown mounted argument %s" % argument)
			return {}
	if parsed.is_empty():
		return {}
	if parsed.size() != 2 or not str(parsed.get("pck", "")).is_absolute_path() or not _d2_lower_sha256(str(parsed.get("sha256", ""))):
		_d2_failed = true
		return {}
	return parsed


func _d2_pck_matches(arguments: Dictionary) -> bool:
	var path := str(arguments.get("pck", ""))
	return FileAccess.file_exists(path) and FileAccess.get_sha256(path) == str(arguments.get("sha256", ""))


func _d2_source_boundary_checks() -> void:
	var exact := {
		D2_CONFIG_PATH: D2_CONFIG_SHA256,
		D2_ADAPTER_PATH: D2_ADAPTER_SHA256,
		D2_BUILDER_PATH: D2_BUILDER_SHA256,
		D2_MAIN_SCRIPT_PATH: D2_MAIN_SHA256,
		D2_CHUNK_PATH: D2_CHUNK_SHA256,
		D2_REGISTRY_PATH: D2_REGISTRY_SHA256,
		D2_CONTRACTS_PATH: D2_CONTRACTS_SHA256,
		D2_CATALOG_PATH: D2_CATALOG_SHA256,
		D2_SCHEMA_PATH: D2_SCHEMA_SHA256,
		D2_LOADER_PATH: D2_LOADER_SHA256,
		D2_COMPILER_PATH: D2_COMPILER_SHA256,
	}
	for path: String in exact:
		_d2_require(FileAccess.get_sha256(path) == str(exact[path]), "Source hash drifted: %s." % path)
	_d2_require(D2_LIVE.source_dependency_hashes_match(), "Reviewed D2 factory/material source bytes drifted.")
	_d2_require(D2_LIVE.runtime_dependency_closure_exists(), "D2 executable resource closure is incomplete.")
	var capture := FileAccess.get_file_as_string(D2_CAPTURE_PATH)
	_d2_require(capture.count('load(D2_MAIN_SCENE_PATH)') == 1, "Production capture does not load ordinary main exactly once.")
	for forbidden: String in ['preload("%s")' % D2_ADAPTER_PATH, 'load("%s")' % D2_ADAPTER_PATH, "ResourceLoader.load(D2_ADAPTER_PATH", 'preload("%s")' % D2_FACTORY_PATH, 'load("%s")' % D2_FACTORY_PATH, "ResourceLoader.load(D2_FACTORY_PATH", "load(D2_WORLD_SCENE_PATH)", "build_for_records(", "prepare_chunk_records(", "consume_record(", "_settle_and_aim(", "_aim_stock_camera(", "player.global_transform =", "player.global_position =", "camera.global_transform =", "camera.global_position =", "rig.rotation =", "arm.rotation ="]:
		_d2_require(forbidden not in capture, "Production capture acquired prohibited construction/transform token %s." % forbidden)
	for release_marker: String in ['Input.action_release("move_forward")', 'Input.action_release("run")', 'Input.action_release("jetpack")', "Input.action_release(D2_MOTION_INPUT_ACTION)"]:
		_d2_require(release_marker in capture, "Production capture lost input cleanup marker %s." % release_marker)
	var preset := FileAccess.get_file_as_string(D2_EXPORT_PRESET_PATH)
	for token: String in ["discovery/*", "discovery/**/*", "evidence/*", "evidence/**/*", "source_assets/*", "source_assets/**/*"]:
		_d2_require(token in preset, "Export preset lost private boundary %s." % token)
	for path: String in D2_MOUNTED_EXCLUDED_PATHS.slice(6):
		_d2_require(path.trim_prefix("res://") in preset, "Export preset does not narrowly exclude standalone activation route %s." % path)
	_d2_require(_d2_builder_seam_matches(), "Canonical D2 builder seam is no longer one ordered atomic direct route.")


func _d2_builder_seam_matches() -> bool:
	var source := FileAccess.get_file_as_string(D2_BUILDER_PATH)
	var markers := [
		'preload("%s")' % D2_ADAPTER_PATH,
		"D2_1441_CHINOOK_LIVE_REPLACEMENT.prepare_chunk_records(chunk)",
		"D2_1441_CHINOOK_LIVE_REPLACEMENT.build_chunk_plan(d2_1441_pair)",
		"D2_1441_CHINOOK_LIVE_REPLACEMENT.claims_record(record)",
		"D2_1441_CHINOOK_LIVE_REPLACEMENT.consume_record(record, d2_1441_plan)",
		"D2_1441_CHINOOK_LIVE_REPLACEMENT.plan_was_fully_consumed(d2_1441_plan)",
	]
	for marker: String in markers:
		if source.count(marker) != 1:
			return false
	var loop_at := source.find("for record_value: Variant in chunk.records:")
	return source.count("D2_1441_CHINOOK_LIVE_REPLACEMENT.free_unconsumed(d2_1441_plan)") == 3 \
		and loop_at >= 0 and source.find(markers[1]) < loop_at \
		and source.find(markers[2]) < loop_at \
		and source.find(markers[4]) > loop_at


func _d2_authority_matches(mounted: bool) -> bool:
	if FileAccess.get_sha256(D2_REGISTRY_PATH) != D2_REGISTRY_SHA256 or FileAccess.get_sha256(D2_CONTRACTS_PATH) != D2_CONTRACTS_SHA256:
		return false
	if not mounted and (FileAccess.get_sha256(D2_CATALOG_PATH) != D2_CATALOG_SHA256 or FileAccess.get_sha256(D2_SCHEMA_PATH) != D2_SCHEMA_SHA256 or FileAccess.get_sha256(D2_LOADER_PATH) != D2_LOADER_SHA256):
		return false
	var registry := _d2_json(D2_REGISTRY_PATH)
	var contracts := _d2_json(D2_CONTRACTS_PATH)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted := metric.get("accepted_physical_unit_ids", []) as Array
	var unit := _d2_record_for(registry.get("units", []) as Array, "unit_id", D2_UNIT_ID)
	var plans := contracts.get("plans", []) as Array
	var ready := plans.filter(func(value: Variant) -> bool: return str((value as Dictionary).get("integration_state", "")) == "package_safe_ready_for_integration")
	var adapters := registry.get("active_runtime_adapters", []) as Array
	var current_topology_owners: Array[String] = []
	for value: Variant in adapters:
		if not value is Dictionary:
			return false
		var active_value: Variant = (value as Dictionary).get("active_runtime_contract")
		if not active_value is Dictionary:
			continue
		var behavior_value: Variant = (active_value as Dictionary).get("behavior_contract")
		if not behavior_value is Dictionary:
			continue
		var behavior := behavior_value as Dictionary
		if str((behavior.get("geometry_contract", {}) as Dictionary).get("world_topology_scope", "")) == "current_integration_topology":
			current_topology_owners.append(str((value as Dictionary).get("adapter_id", "")))
	var compatibility := registry.get("compatibility_contract", {}) as Dictionary
	var build := contracts.get("build_contract", {}) as Dictionary
	var loader := contracts.get("loader_contract", {}) as Dictionary
	return str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/8" \
		and str(contracts.get("schema_version", "")) == "ti.facade-runtime-adapter-contracts/7" \
		and str(compatibility.get("catalog_schema_version", "")) == "ti.facade-recognition-catalog/8" \
		and str(compatibility.get("compiler_version", "")) == "1.7.0" \
		and str(compatibility.get("loader_api_version", "")) == "ti.facade-runtime-registry-loader/7" \
		and str(build.get("compiler_version", "")) == "1.7.0" \
		and str(loader.get("api_version", "")) == "ti.facade-runtime-registry-loader/7" \
		and int(metric.get("numerator", -1)) == 8 and int(metric.get("denominator", -1)) == 213 and str(metric.get("display", "")) == D2_CAPTURE_TIME_METRIC \
		and accepted.size() == 8 and D2_UNIT_ID not in accepted and (registry.get("units", []) as Array).size() == 213 \
		and adapters.size() == 7 and plans.size() == 16 and ready.size() == 10 \
		and not unit.is_empty() and unit.get("active_runtime_adapter_ids", []) == [] \
		and str(unit.get("runtime_content_mode", "")) == "all_receivers_generated_placeholder" \
		and str((unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "not_evaluated" \
		and (unit.get("acceptance_records", []) as Array).is_empty() \
		and current_topology_owners == ["active-adapter:d1-b225-live:building:w95934119:wall"]


func _d2_validate_package_resources(mounted: bool) -> void:
	for path: String in [D2_MAIN_SCENE_PATH, D2_WORLD_SCENE_PATH, D2_MANIFEST_PATH, D2_CHUNK_PATH, D2_REGISTRY_PATH, D2_CONTRACTS_PATH, D2_CAPTURE_PATH, D2_FOCUSED_PATH, D2_PACKAGE_PATH, D2_SOURCE_PACKAGE_PATH]:
		_d2_require(_d2_exists(path), "Package closure is missing %s." % path)
	_d2_require(get_script() != null and get_script().resource_path == D2_PACKAGE_PATH, "The new mounted D2 package contract is not the executing script.")
	for path: String in [D2_CAPTURE_PATH, D2_FOCUSED_PATH, D2_SOURCE_PACKAGE_PATH]:
		_d2_require(ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) != null, "Packaged script is not remap-loadable: %s." % path)
	_d2_require(FileAccess.get_sha256(D2_CONFIG_PATH) == D2_CONFIG_SHA256, "Raw D2 live config is absent or drifted.")
	for path: String in D2_REQUIRED_RUNTIME_CLOSURE:
		_d2_require(_d2_exists(path), "D2 runtime closure is missing %s." % path)
		if path.get_extension() != "json":
			_d2_require(ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) != null, "D2 runtime resource is not remap-loadable: %s." % path)
		elif not mounted:
			_d2_require(not _d2_json(path).is_empty(), "D2 source JSON is invalid: %s." % path)


func _d2_ordinary_main_matches() -> Dictionary:
	var packed := load(D2_MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		return {"ok": false, "message": "Ordinary main scene did not load."}
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var ready: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await process_frame
	var evidence := world.get_runtime_evidence()
	var actual := {"rows": evidence.playable_rows, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "bodies": evidence.static_bodies, "shapes": evidence.shapes}
	var walls := _d2_nodes_for_key(world, D2_WALL_KEY)
	var roofs := _d2_nodes_for_key(world, D2_ROOF_KEY)
	var valid := failures.is_empty() and ready.size() == 1 and actual == D2_PRODUCTION_WORLD and walls.size() == 1 and roofs.size() == 1
	if valid:
		valid = _d2_live_pair_matches(walls[0], roofs[0]) and _d2_collision_rays_match(walls[0], roofs[0])
	var message := "D2 mounted ordinary-main drift: failures=%s ready=%d wall/roof=%d/%d topology=%s" % [failures, ready.size(), walls.size(), roofs.size(), actual]
	main.queue_free()
	await process_frame
	return {"ok": valid, "message": message}


func _d2_live_pair_matches(wall: Node3D, roof: Node3D) -> bool:
	var wall_measure := _d2_measure(wall)
	var roof_measure := _d2_measure(roof)
	var wall_body := wall.get_node_or_null("Collision") as StaticBody3D
	var roof_body := roof.get_node_or_null("Collision") as StaticBody3D
	var wall_shape := wall.get_node_or_null("Collision/Shape") as CollisionShape3D
	var roof_shape := roof.get_node_or_null("Collision/Shape") as CollisionShape3D
	var metadata := wall.get_meta("d2_1441_chinook_live_replacement", {}) as Dictionary
	var relief_triangles := 0
	for node: Node in wall.find_children("*", "MeshInstance3D", true, false):
		var instance := node as MeshInstance3D
		if instance.name not in D2_LIVE.SOURCE_WALL_MESH_NAMES:
			relief_triangles += int(instance.mesh.get_faces().size() / 3)
	var chunk := _d2_json(D2_CHUNK_PATH)
	var wall_record := _d2_record_for(chunk.get("records", []) as Array, "object_key", D2_WALL_KEY)
	var roof_mesh := roof.get_node_or_null(D2_LIVE.ROOF_MESH_NAME) as MeshInstance3D
	var wall_face_match := wall_shape != null and wall_shape.shape is ConcavePolygonShape3D and _d2_face_signature((wall_shape.shape as ConcavePolygonShape3D).get_faces()) == _d2_expected_wall_face_signature(wall_record)
	var roof_face_match := roof_shape != null and roof_shape.shape is ConcavePolygonShape3D and roof_mesh != null and _d2_millimeter_face_signature((roof_shape.shape as ConcavePolygonShape3D).get_faces()) == _d2_millimeter_face_signature(roof_mesh.mesh.get_faces())
	var matches := wall.name == "D21441ChinookLiveWallReplacement" and roof.name == "D21441ChinookLiveRoofReplacement" \
		and wall.get_node_or_null("Mesh") == null and roof.get_node_or_null("Mesh") == null \
		and wall_measure == {"meshes": 8, "surfaces": 8, "triangles": 1568, "bodies": 1, "shapes": 1} \
		and roof_measure == {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1} \
		and wall_body != null and roof_body != null and wall_shape != null and roof_shape != null \
		and wall_shape.shape is ConcavePolygonShape3D and roof_shape.shape is ConcavePolygonShape3D \
		and (wall_shape.shape as ConcavePolygonShape3D).get_faces().size() == 96 \
		and (roof_shape.shape as ConcavePolygonShape3D).get_faces().size() == 30 \
		and wall_face_match and roof_face_match \
		and relief_triangles == 1536 and wall_body.is_in_group("spray_receiver_wall") \
		and wall_body.collision_layer == ((1 << 0) | (1 << 2)) and wall_body.collision_mask == 0 \
		and roof_body.collision_layer == ((1 << 0) | (1 << 2)) and roof_body.collision_mask == 0 \
		and not roof_body.is_in_group("spray_receiver_wall") and bool(roof_body.get_meta("roof_landing_world_solid", false)) \
		and str(metadata.get("geometry_signature", "")) == D2_LIVE.EXPECTED_GEOMETRY_SIGNATURE \
		and str(metadata.get("live_ownership_signature", "")) == D2_LIVE.EXPECTED_LIVE_OWNERSHIP_SIGNATURE \
		and str(metadata.get("accepted_authority_schema", "")) == "ti.facade-runtime-registry/8" \
		and str(metadata.get("accepted_recognition_metric", "")) == D2_CAPTURE_TIME_METRIC \
		and int(metadata.get("candidate_recognition_credit", -1)) == 0 \
		and not bool(metadata.get("recognition_accepted", true)) and not bool(metadata.get("believability_accepted", true)) \
		and D2_LIVE.material_semantics_match(wall, roof)
	if not matches:
		print("D2_1441_PACKAGE_PAIR_DIAGNOSTIC: wall=%s roof=%s relief=%d wall_face=%s roof_face=%s roof_shape_sig=%s roof_mesh_sig=%s metadata=%s wall_layer=%d roof_layer=%d material=%s" % [wall_measure, roof_measure, relief_triangles, wall_face_match, roof_face_match, _d2_face_signature((roof_shape.shape as ConcavePolygonShape3D).get_faces()) if roof_shape != null else "none", _d2_face_signature(roof_mesh.mesh.get_faces()) if roof_mesh != null else "none", metadata, wall_body.collision_layer if wall_body != null else -1, roof_body.collision_layer if roof_body != null else -1, D2_LIVE.material_semantics_match(wall, roof)])
	return matches


func _d2_collision_rays_match(wall: Node3D, roof: Node3D) -> bool:
	var chunk := _d2_json(D2_CHUNK_PATH)
	var record := _d2_record_for(chunk.get("records", []) as Array, "object_key", D2_WALL_KEY)
	var values := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var offset := 13 * 12
	if values.size() <= offset + 8 or normals.size() <= offset + 2:
		return false
	var wall_point := (Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2])) + Vector3(float(values[offset + 6]), float(values[offset + 7]), float(values[offset + 8]))) * 0.5
	var outward := Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()
	var wall_body := wall.get_node("Collision") as StaticBody3D
	var roof_body := roof.get_node("Collision") as StaticBody3D
	var roof_mesh := roof.get_node(D2_LIVE.ROOF_MESH_NAME) as MeshInstance3D
	var roof_faces := roof_mesh.mesh.get_faces()
	var roof_point := roof_mesh.to_global((roof_faces[0] + roof_faces[1] + roof_faces[2]) / 3.0)
	var space := wall.get_world_3d().direct_space_state
	var wall_solid := space.intersect_ray(PhysicsRayQueryParameters3D.create(wall_point + outward * 3.0, wall_point - outward, 1 << 0))
	var wall_spray := space.intersect_ray(PhysicsRayQueryParameters3D.create(wall_point + outward * 3.0, wall_point - outward, 1 << 2))
	var roof_solid := space.intersect_ray(PhysicsRayQueryParameters3D.create(roof_point + Vector3.UP * 3.0, roof_point - Vector3.UP, 1 << 0))
	var roof_spray := space.intersect_ray(PhysicsRayQueryParameters3D.create(roof_point + Vector3.UP * 3.0, roof_point - Vector3.UP, 1 << 2))
	return not wall_solid.is_empty() and wall_solid.get("collider") == wall_body \
		and not wall_spray.is_empty() and wall_spray.get("collider") == wall_body \
		and absf((wall_spray.get("normal") as Vector3).y) < 0.2 \
		and not roof_solid.is_empty() and roof_solid.get("collider") == roof_body \
		and not roof_spray.is_empty() and roof_spray.get("collider") == roof_body \
		and (roof_spray.get("normal") as Vector3).y > 0.4 \
		and str(roof_body.get_meta("receiver_kind", "invalid")) == "none"


func _d2_expected_wall_face_signature(record: Dictionary) -> String:
	var values := record.get("vertices", []) as Array
	var indices := record.get("indices", []) as Array
	var faces := PackedVector3Array()
	for offset in range(0, indices.size(), 3):
		for source_offset: int in [0, 2, 1]:
			var index := int(indices[offset + source_offset]) * 3
			faces.append(Vector3(float(values[index]), float(values[index + 1]), float(values[index + 2])))
	return _d2_face_signature(faces)


func _d2_face_signature(faces: PackedVector3Array) -> String:
	var triangles: Array[String] = []
	for offset in range(0, faces.size(), 3):
		var points := [
			"%.5f|%.5f|%.5f" % [faces[offset].x, faces[offset].y, faces[offset].z],
			"%.5f|%.5f|%.5f" % [faces[offset + 1].x, faces[offset + 1].y, faces[offset + 1].z],
			"%.5f|%.5f|%.5f" % [faces[offset + 2].x, faces[offset + 2].y, faces[offset + 2].z],
		]
		points.sort()
		triangles.append("/".join(points))
	triangles.sort()
	return "\n".join(triangles).sha256_text()


func _d2_millimeter_face_signature(faces: PackedVector3Array) -> String:
	var triangles: Array[String] = []
	for offset in range(0, faces.size(), 3):
		var points := [
			"%.3f|%.3f|%.3f" % [faces[offset].x, faces[offset].y, faces[offset].z],
			"%.3f|%.3f|%.3f" % [faces[offset + 1].x, faces[offset + 1].y, faces[offset + 1].z],
			"%.3f|%.3f|%.3f" % [faces[offset + 2].x, faces[offset + 2].y, faces[offset + 2].z],
		]
		points.sort()
		triangles.append("/".join(points))
	triangles.sort()
	return "\n".join(triangles).sha256_text()


func _d2_nodes_for_key(root_node: Node, key: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if node.has_meta("feature_kind") and str(node.get_meta("derived_object_key", "")) == key:
			result.append(node as Node3D)
	return result


func _d2_measure(root_node: Node) -> Dictionary:
	var result := {"meshes": 0, "surfaces": 0, "triangles": 0, "bodies": 0, "shapes": 0}
	for node: Node in _d2_all_nodes(root_node):
		if node is MeshInstance3D:
			var mesh := (node as MeshInstance3D).mesh
			result.meshes += 1
			result.surfaces += mesh.get_surface_count()
			result.triangles += int(mesh.get_faces().size() / 3)
		elif node is StaticBody3D:
			result.bodies += 1
		elif node is CollisionShape3D:
			result.shapes += 1
	return result


func _d2_all_nodes(root_node: Node) -> Array[Node]:
	var result: Array[Node] = [root_node]
	for child: Node in root_node.get_children():
		result.append_array(_d2_all_nodes(child))
	return result


func _d2_record_for(records: Array, field: String, expected: String) -> Dictionary:
	for value: Variant in records:
		if value is Dictionary and str((value as Dictionary).get(field, "")) == expected:
			return value as Dictionary
	return {}


func _d2_exists(path: String) -> bool:
	return FileAccess.file_exists(path) or ResourceLoader.exists(path)


func _d2_exists_with_remaps(path: String) -> bool:
	if path.ends_with("/"):
		return DirAccess.dir_exists_absolute(path)
	if _d2_exists(path):
		return true
	if path.ends_with(".gd"):
		return _d2_exists(path + ".remap") or _d2_exists(path.trim_suffix(".gd") + ".gdc")
	return false


func _d2_lower_sha256(value: String) -> bool:
	if value.length() != 64 or value != value.to_lower():
		return false
	for index in value.length():
		if value[index] not in "0123456789abcdef":
			return false
	return true


func _d2_json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _d2_require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_d2_failed = true
	push_error("D2_1441_PRODUCTION_PACKAGE_FAIL: %s" % message)
	return false
