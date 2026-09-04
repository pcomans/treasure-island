extends SceneTree

const FACTORY := preload("res://game/scripts/world/facades/d2_1444_croaker_standalone_hero_prototype.gd")
const CONFIG_PATH := "res://game/resources/facades/d2_1444_croaker_standalone_hero_prototype.json"
const FACTORY_PATH := "res://game/scripts/world/facades/d2_1444_croaker_standalone_hero_prototype.gd"
const SCENE_PATH := "res://game/scenes/world/facades/site_12_housing/d2_1444_croaker_standalone_hero_prototype.tscn"
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_-1.json"
const PACKET_PATH := "res://discovery/facades/d2_reference_packets/w95934117_1444_croaker_court.md"
const EVIDENCE_PATH := "res://evidence/first-playable/d2-1444-croaker-standalone-hero-2026-09-04/capture-manifest.json"
const STUCCO_MATERIAL := "res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres"
const ROOF_MATERIAL := "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres"
const STUCCO_TEXTURE := "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png"
const PILOT_ONLY_STUCCO_TEXTURE := "res://game/resources/textures/world/genai_pilot_v1/warm_ivory_mineral_albedo_v2.png"
const ROOF_TEXTURE := "res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg"
const WALL_KEY := "building:w95934117:wall"
const ROOF_KEY := "building:w95934117:roof"
const EXPECTED_SIGNATURE := "8df0202796d56c019b6b3ddb72916808b72316d2d0edee0ba7425b77efa2b127"
const EXPECTED_CONFIG_SHA256 := "1176b20c7ab350733dc0f07cb7ab2d46b88077f6378bd9380af3756a069e9fae"
const EXPECTED_CHUNK_SHA256 := "6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2"
const EXPECTED_SOURCE_HASHES := {
	CONFIG_PATH: EXPECTED_CONFIG_SHA256,
	FACTORY_PATH: "0c5cada54350d0a8dcd37fb1ecd737d91c5eab3ce1c469e423683ab30285cfc8",
	SCENE_PATH: "eefd9d656b64ccf5e68f15c2eecf8b36790add43dc8b1ff6dd9a5526d6375ae1",
	CHUNK_PATH: EXPECTED_CHUNK_SHA256,
	PACKET_PATH: "51c70c213b055572447c8a7aebaf3a3da2b8e759d4bcd48aa65949ec0530fa90",
	"res://game/scripts/world/facades/site_12_housing_kit.gd": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
	STUCCO_MATERIAL: "9486ccf52e1f2aff9fc940f60644733d5cf9bf1cb03cebb5332bcc1d7c0aaaf6",
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres": "d97d7b4a442ffe8ad9a0b003e5c1d6466f9ef9effc7cdb2be8ef966195e66782",
	ROOF_MATERIAL: "389c01066767b085ef8ed8ae4c5e1b06062d9ffb135e3e6a7bfa968b963717d7",
	"res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres": "4159f82cc5c4c17c0d8173eddbc171120326fbd99578aa68012275b1274ce02d",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres": "eddc4900c351dc3a75d163bd380a8b3a39bf6a1c1c3647299e3af19634a60ead",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres": "75c13aa30a4e3c9f49980d78abe41f40c6c7ab270be6152c201eb8a72ebe8720",
	STUCCO_TEXTURE: "af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c",
	ROOF_TEXTURE: "fa09ed33d59c3bb90ef70d36352207e2e1ca5564cfc61295c0124d1a7d785808",
}
const RUNTIME_PATHS := [
	CONFIG_PATH,
	FACTORY_PATH,
	SCENE_PATH,
	CHUNK_PATH,
	"res://game/scripts/world/facades/site_12_housing_kit.gd",
	STUCCO_MATERIAL,
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
	ROOF_MATERIAL,
	"res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
	STUCCO_TEXTURE,
	ROOF_TEXTURE,
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mounted := "--mounted" in OS.get_cmdline_user_args()
	for path: String in RUNTIME_PATHS:
		_require(ResourceLoader.exists(path) or FileAccess.file_exists(path), "1444 runtime package closure is missing %s." % path)
	_require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256, "1444 package config bytes drifted.")
	_require(FileAccess.get_sha256(CHUNK_PATH) == EXPECTED_CHUNK_SHA256, "1444 packaged frozen chunk bytes drifted.")
	if mounted:
		_require(FileAccess.file_exists("res://project.binary"), "Mounted audit did not resolve an exported project.binary.")
		_require(not FileAccess.file_exists("res://project.godot"), "Mounted audit fell back to an unpacked source project.")
		_require(not ResourceLoader.exists(PACKET_PATH) and not FileAccess.file_exists(PACKET_PATH), "Mounted package contains the discovery-only 1444 packet.")
		_require(not ResourceLoader.exists(EVIDENCE_PATH) and not FileAccess.file_exists(EVIDENCE_PATH), "Mounted package contains 1444 review evidence.")
		_require(not ResourceLoader.exists(PILOT_ONLY_STUCCO_TEXTURE) and not FileAccess.file_exists(PILOT_ONLY_STUCCO_TEXTURE), "Mounted package contains the export-excluded pilot-only stucco path.")
	else:
		_run_source_boundary_checks()
	_require(_material_closure_matches(), "1444 package material/texture closure drifted.")
	var chunk := _json(CHUNK_PATH)
	var wall := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	_require(FACTORY.record_signature(wall) == FACTORY.EXPECTED_WALL_RECORD_SHA256, "1444 packaged wall record signature drifted.")
	_require(FACTORY.record_signature(roof) == FACTORY.EXPECTED_ROOF_RECORD_SHA256, "1444 packaged roof record signature drifted.")
	_require(FACTORY.matches_record_pair(wall, roof), "1444 package matcher rejected its exact wall/roof pair.")
	var packed := load(SCENE_PATH) as PackedScene
	_require(packed != null, "1444 package scene did not load.")
	if packed != null:
		var standalone := packed.instantiate() as Node3D
		_require(standalone != null, "1444 package scene did not instantiate.")
		if standalone != null:
			root.add_child(standalone)
			await process_frame
			_require(_prototype_matches(standalone), "1444 mounted prototype topology/truth/ownership contract drifted.")
			standalone.queue_free()
			await process_frame
	if not _failed:
		print("PASS: %s 1444 Croaker standalone package closure loads exact source pair, materials, signature, topology, and one structural shell without discovery/evidence payloads or live ownership" % ("mounted" if mounted else "source"))
	quit(1 if _failed else 0)


func _run_source_boundary_checks() -> void:
	for path: String in EXPECTED_SOURCE_HASHES:
		_require(FileAccess.get_sha256(path) == str(EXPECTED_SOURCE_HASHES[path]), "1444 source/package input drifted: %s." % path)
	var executable_text := ""
	for path: String in [CONFIG_PATH, FACTORY_PATH, SCENE_PATH, STUCCO_MATERIAL, ROOF_MATERIAL]:
		executable_text += FileAccess.get_file_as_string(path).to_lower() + "\n"
	for token: String in ["res://discovery/", "res://evidence/", "https://", "http://", "file://", "/volumes/", "/users/"]:
		_require(token not in executable_text, "1444 executable closure contains forbidden source/runtime token %s." % token)
	var config := _json(CONFIG_PATH)
	var bindings := config.get("source_bindings", []) as Array
	var packet_binding := {}
	for value: Variant in bindings:
		var binding := value as Dictionary
		if str(binding.get("id", "")) == "D2-w95934117-packet":
			packet_binding = binding
	_require(str(packet_binding.get("authority_sha256", "")) == str(EXPECTED_SOURCE_HASHES[PACKET_PATH]), "1444 package-safe authority binding lost the exact packet hash.")
	for path: String in ["res://game/scripts/world/world_chunk_builder.gd", "res://game/scripts/main.gd", "res://game/resources/facades/facade-runtime-registry.json", "res://game/scripts/world/facades/facade_runtime_registry_loader.gd"]:
		var live_text := FileAccess.get_file_as_string(path)
		_require("d2_1444_croaker_standalone_hero_prototype" not in live_text and "D21444CroakerStandaloneHeroPrototype" not in live_text, "1444 standalone leaked into live route %s." % path)
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	for token: String in ["discovery/*", "discovery/**/*", "evidence/*", "evidence/**/*", "game/resources/textures/world/genai_pilot_v1/*", "game/resources/textures/world/genai_pilot_v1/**/*"]:
		_require(token in preset, "Private export preset lost source/evidence exclusion %s." % token)
	_require("game/resources/textures/world/site_12_housing/*" not in preset, "Canonical preset unexpectedly excludes the promoted Site-12 texture directory.")


func _material_closure_matches() -> bool:
	var stucco := load(STUCCO_MATERIAL) as StandardMaterial3D
	var roof := load(ROOF_MATERIAL) as StandardMaterial3D
	return stucco != null and roof != null \
		and stucco.albedo_texture != null and roof.albedo_texture != null \
		and stucco.albedo_texture.resource_path == STUCCO_TEXTURE \
		and roof.albedo_texture.resource_path == ROOF_TEXTURE \
		and stucco.albedo_color.is_equal_approx(Color(0.78, 0.61, 0.42, 1.0)) \
		and is_equal_approx(stucco.roughness, 0.88) and is_zero_approx(stucco.metallic) \
		and stucco.normal_texture == null and stucco.roughness_texture == null \
		and roof.normal_texture == null and roof.roughness_texture == null \
		and is_equal_approx(stucco.uv1_scale.x, 0.333333) and is_equal_approx(stucco.uv1_scale.y, 0.333333) \
		and is_equal_approx(roof.uv1_scale.x, 0.2) and is_equal_approx(roof.uv1_scale.y, 0.2)


func _prototype_matches(node: Node3D) -> bool:
	var body := node.get_node_or_null("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	var shape_node := null if body == null else body.get_node_or_null("ExactFootprintStructuralShape") as CollisionShape3D
	var faces := PackedVector3Array() if shape_node == null or not (shape_node.shape is ConcavePolygonShape3D) else (shape_node.shape as ConcavePolygonShape3D).get_faces()
	return bool(node.get_meta("prototype_only", false)) \
		and not bool(node.get_meta("runtime_attachment", true)) \
		and str(node.get_meta("registry_status", "")) == "not_registered" \
		and str(node.get_meta("world_builder_status", "")) == "not_attached" \
		and not bool(node.get_meta("recognition_accepted", true)) \
		and not bool(node.get_meta("believability_accepted", true)) \
		and node.get_meta("mapped_public_run_indices", []) == [8, 9, 11, 12, 15, 16, 17] \
		and node.get_meta("protected_run_indices", []) == [0, 1, 2, 3, 4, 5, 6, 7, 10, 13, 14, 18, 19, 20, 21] \
		and int(node.get_meta("mesh_instances", -1)) == 11 \
		and int(node.get_meta("surfaces", -1)) == 11 \
		and int(node.get_meta("visual_triangles", -1)) == 798 \
		and int(node.get_meta("collision_triangles", -1)) == 54 \
		and str(node.get_meta("deterministic_signature", "")) == EXPECTED_SIGNATURE \
		and body != null and body.collision_layer == 1 and body.collision_mask == 0 \
		and str(body.get_meta("spray_ownership", "")) == "none_standalone" \
		and faces.size() == 162 \
		and _count_type(node, StaticBody3D) == 1 \
		and _count_type(node, CollisionShape3D) == 1 \
		and _count_type(node, NavigationRegion3D) == 0 \
		and not _any_spray_group(node)


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _any_spray_group(node: Node) -> bool:
	if node.is_in_group("spray_receiver") or node.is_in_group("spray_receiver_wall"):
		return true
	for child: Node in node.get_children():
		if _any_spray_group(child):
			return true
	return false


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("D2_1444_PACKAGE_FAIL: %s" % message)
	return false
