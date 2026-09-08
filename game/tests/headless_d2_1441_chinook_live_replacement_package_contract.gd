extends SceneTree

const ADAPTER := preload("res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd")
const CONFIG_PATH := "res://game/resources/facades/d2_1441_chinook_live_replacement.json"
const ADAPTER_PATH := "res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const MAIN_PATH := "res://game/scripts/main.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_-1.json"
const CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const CONTRACTS_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const LOADER_PATH := "res://game/scripts/world/facades/facade_runtime_registry_loader.gd"
const COMPILER_PATH := "res://tools/build_facade_recognition_registry.mjs"
const B225_FOCUSED_BRIDGE_PATH := "res://game/tests/headless_d1_b225_postpromotion_v8_contract.gd"
const B225_PACKAGE_BRIDGE_PATH := "res://game/tests/headless_d1_b225_postpromotion_v8_package_contract.gd"
const EXPECTED_SOURCE_HASHES := {
	CONFIG_PATH: "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111",
	ADAPTER_PATH: "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1",
	BUILDER_PATH: "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a",
	MAIN_PATH: "1c284eb4d8ee5954500fe36c3ab6845bc7233728da26f5f6848dd8de9a627232",
	CHUNK_PATH: "5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b",
	CATALOG_PATH: "d95be7bec8f0eabe97a9b5f7fefe1ce54ec7cbf940d85d28518ff6979eeb16ea",
	REGISTRY_PATH: "109f83f40450e9c71ef6d39f1659e76eac5f1457fcfab772538b471cc74c0051",
	CONTRACTS_PATH: "dd2d13e3b0f6eee1f8c5f2957927c4f3caba43b31883beea925f9a91b826d65c",
	LOADER_PATH: "12e6c64b23b0783ed240b3d6c02499c3940c2b6a14344caa29778b850db06c04",
	COMPILER_PATH: "eee17772b1beb71b3d6bd87800035a0c1c47a7c80473014c578bb055a5ddf0c9",
	B225_FOCUSED_BRIDGE_PATH: "68458d5923134f2cc8b050315a455698cf48863f066eda3479da00e0b1e596c9",
	B225_PACKAGE_BRIDGE_PATH: "713f6f84679dca723410031dfe45a96d4bc8136cb83bbca0d4e40ee274f9c434",
}
const PACKAGE_CLOSURE := [
	CONFIG_PATH,
	ADAPTER_PATH,
	"res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd",
	"res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json",
	"res://game/scripts/world/facades/site_12_housing_kit.gd",
	"res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
	"res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(_source_hashes_match(), "Live/package or frozen authority source hashes drifted.")
	_require(ADAPTER.source_dependency_hashes_match(), "Reviewed executable dependency bytes drifted.")
	_require(ADAPTER.runtime_dependency_closure_exists(), "Executable resource closure is incomplete.")
	_require(_direct_route_is_narrow(), "Canonical builder route is not one direct, unconditional, pair-validated adapter seam.")
	_require(_direct_closure_is_private_safe(), "Direct live closure contains a source/evidence/URL/private/scene-instantiation token.")
	_require(_export_boundary_matches(), "Private export preset no longer includes the live closure or excludes authoring/evidence inputs.")
	_require(_authority_is_unchanged(), "Uncredited 1441 candidate mutated or contradicted exact v8 8/213 authority.")
	_require(_compiler_lifecycle_seam_matches(), "Registry compiler no longer separates current semantic dispatch from accepted B225 provenance.")
	_require(_b225_bridge_lifecycle_matches(), "Current B225 bridges no longer separate accepted provenance from uncredited live topology.")
	_require(_package_resources_load(), "A packaged live dependency is missing or not loadable.")
	_require(_factory_builds_from_supplied_pair(), "Packaged factory/material semantics do not build solely from the supplied pair.")
	_finish()


func _source_hashes_match() -> bool:
	for path: String in EXPECTED_SOURCE_HASHES:
		if FileAccess.get_sha256(path) != str(EXPECTED_SOURCE_HASHES[path]):
			push_error("D2_1441_PACKAGE_HASH: %s expected=%s actual=%s" % [path, EXPECTED_SOURCE_HASHES[path], FileAccess.get_sha256(path)])
			return false
	return true


func _direct_route_is_narrow() -> bool:
	var builder := FileAccess.get_file_as_string(BUILDER_PATH)
	var adapter := FileAccess.get_file_as_string(ADAPTER_PATH)
	return builder.count('preload("%s")' % ADAPTER_PATH) == 1 \
		and builder.count("D2_1441_CHINOOK_LIVE_REPLACEMENT.prepare_chunk_records(chunk)") == 1 \
		and builder.count("D2_1441_CHINOOK_LIVE_REPLACEMENT.build_chunk_plan(d2_1441_pair)") == 1 \
		and builder.count("D2_1441_CHINOOK_LIVE_REPLACEMENT.consume_record(record, d2_1441_plan)") == 1 \
		and builder.count("D2_1441_CHINOOK_LIVE_REPLACEMENT.plan_was_fully_consumed(d2_1441_plan)") == 1 \
		and adapter.count('preload("res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd")') == 1 \
		and adapter.count("PROTOTYPE.build_for_records(wall, roof)") == 1 \
		and ".tscn" not in adapter \
		and "configure_from_frozen_source" not in adapter \
		and "CHUNK_PATH" not in adapter \
		and "ProjectSettings" not in adapter \
		and "OS.get_environment" not in adapter \
		and "OS.get_cmdline" not in adapter


func _direct_closure_is_private_safe() -> bool:
	var direct_text := (FileAccess.get_file_as_string(CONFIG_PATH) + "\n" + FileAccess.get_file_as_string(ADAPTER_PATH)).to_lower()
	for token: String in ["res://discovery", "res://evidence", "http://", "https://", "file://", "/volumes/", "/users/", "source_assets/", ".tscn"]:
		if token in direct_text:
			return false
	var config := _json(CONFIG_PATH)
	var package := config.get("package_boundary", {}) as Dictionary
	return not bool(package.get("standalone_scene_instantiated", true)) \
		and not bool(package.get("generic_registry_loader_used", true)) \
		and not bool(package.get("flag_or_environment_toggle", true)) \
		and not bool(package.get("missing_pair_member_loaded_from_disk", true)) \
		and not bool(package.get("source_or_evidence_paths_shipped", true)) \
		and not bool(package.get("reference_pixels_shipped", true))


func _export_boundary_matches() -> bool:
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	for token: String in ["discovery/*", "discovery/**/*", "evidence/*", "evidence/**/*", "source_assets/*", "source_assets/**/*", "game/resources/textures/world/genai_pilot_v1/*", "game/resources/textures/world/genai_pilot_v1/**/*"]:
		if token not in preset:
			return false
	return "game/resources/facades/d2_1441_chinook_live_replacement.json" not in preset \
		and "game/scripts/world/facades/d2_1441_chinook_live_replacement.gd" not in preset \
		and "game/resources/textures/world/site_12_housing/*" not in preset


func _authority_is_unchanged() -> bool:
	var registry := _json(REGISTRY_PATH)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted := metric.get("accepted_physical_unit_ids", []) as Array
	var unit := _unit_for(registry.get("units", []) as Array, "physical-building:w95934105")
	return str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/8" \
		and int(metric.get("numerator", -1)) == 8 and int(metric.get("denominator", -1)) == 213 \
		and str(metric.get("display", "")) == "8/213" and accepted.size() == 8 \
		and "physical-building:w95934105" not in accepted \
		and unit.get("active_runtime_adapter_ids", []) == [] \
		and str(unit.get("runtime_content_mode", "")) == "all_receivers_generated_placeholder" \
		and (unit.get("acceptance_records", []) as Array).is_empty()


func _compiler_lifecycle_seam_matches() -> bool:
	var compiler := FileAccess.get_file_as_string(COMPILER_PATH)
	return 'const COMPILER_VERSION = "1.7.0"' in compiler \
		and "acceptedWorldBuilderSha256: D1_B225_REVIEWED_WORLD_BUILDER_SHA256" in compiler \
		and "currentWorldBuilderSha256: sha256File(absolute(WORLD_CHUNK_BUILDER_PATH))" in compiler \
		and "function validateCurrentWorldBuilderDispatch(inputs)" in compiler \
		and "validateCurrentWorldBuilderDispatch(inputs);" in compiler \
		and compiler.count("dispatch_sha256: inputs.runtimeContracts.acceptedWorldBuilderSha256") == 6 \
		and compiler.count("world_chunk_builder_sha256: inputs.runtimeContracts.acceptedWorldBuilderSha256") == 1 \
		and "runtimeContracts.worldBuilderSha256" not in compiler


func _b225_bridge_lifecycle_matches() -> bool:
	var focused := FileAccess.get_file_as_string(B225_FOCUSED_BRIDGE_PATH)
	var package_bridge := FileAccess.get_file_as_string(B225_PACKAGE_BRIDGE_PATH)
	for source: String in [focused, package_bridge]:
		if source.count('const ACCEPTED_B225_BUILDER_SHA256 := "de4a2924d275a51dfd08aae1f0ef21daac33395b1fcfe98e260fbc90737dd725"') != 1 \
		or source.count('const ACCEPTED_B225_WORLD := {"rows": 735, "meshes": 952, "surfaces": 967, "triangles": 67716, "bodies": 466, "shapes": 466}') != 1 \
		or source.count('const CURRENT_LIVE_WORLD := {"rows": 735, "meshes": 959, "surfaces": 974, "triangles": 69252, "bodies": 466, "shapes": 466}') != 1 \
		or source.count("func _current_b225_builder_route_matches() -> bool:") != 1:
			return false
	return true


func _package_resources_load() -> bool:
	for path: String in PACKAGE_CLOSURE:
		if path.get_extension() == "json":
			if not FileAccess.file_exists(path) or _json(path).is_empty():
				return false
		elif path.get_extension() in ["gd", "tres", "png", "jpg"]:
			if not ResourceLoader.exists(path) or ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) == null:
				return false
		else:
			return false
	return true


func _factory_builds_from_supplied_pair() -> bool:
	var chunk := _json(CHUNK_PATH)
	var plan := ADAPTER.build_chunk_plan(ADAPTER.prepare_chunk_records(chunk))
	if not bool(plan.get("ok", false)):
		return false
	var host := Node3D.new()
	for value: Variant in chunk.records as Array:
		var record := value as Dictionary
		if not ADAPTER.claims_record(record):
			continue
		var result := ADAPTER.consume_record(record, plan)
		if not bool(result.get("ok", false)):
			host.free()
			ADAPTER.free_unconsumed(plan)
			return false
		host.add_child(result.node as Node3D)
	var wall := _child_with_key(host, ADAPTER.WALL_KEY)
	var roof := _child_with_key(host, ADAPTER.ROOF_KEY)
	var roof_mesh: MeshInstance3D = null
	if roof != null:
		roof_mesh = roof.get_node_or_null(ADAPTER.ROOF_MESH_NAME) as MeshInstance3D
	var matches := ADAPTER.plan_was_fully_consumed(plan) \
		and wall != null and roof != null \
		and roof_mesh != null and ADAPTER.roof_render_front_face_matches(roof_mesh) \
		and ADAPTER.material_semantics_match(wall, roof) \
		and wall.find_children("*", "MeshInstance3D", true, false).size() == 8 \
		and roof.find_children("*", "MeshInstance3D", true, false).size() == 1 \
		and wall.find_children("*", "StaticBody3D", true, false).size() == 1 \
		and roof.find_children("*", "StaticBody3D", true, false).size() == 1 \
		and not bool((wall.get_meta("d2_1441_chinook_live_replacement", {}) as Dictionary).get("recognition_accepted", true))
	host.free()
	return matches


func _child_with_key(root_node: Node, key: String) -> Node3D:
	for child: Node in root_node.get_children():
		if str(child.get_meta("derived_object_key", "")) == key:
			return child as Node3D
	return null


func _unit_for(units: Array, id: String) -> Dictionary:
	for value: Variant in units:
		var unit := value as Dictionary
		if str(unit.get("unit_id", "")) == id:
			return unit
	return {}


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _require(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error("D2_1441_PACKAGE_FAIL: %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("PASS: source 1441 live package closure is exact, private-safe, directly pair-mounted without scene/disk fallback/override, material-semantic, and explicitly uncredited under unchanged v8 8/213 authority")
		quit(0)
	else:
		push_error("D2_1441_PACKAGE_FAILURES: %s" % [_failures])
		quit(1)
